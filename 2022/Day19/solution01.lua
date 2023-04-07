-- Sam Shepard, 2023
-- First-time, Lua!
--
-- Branch-and-bound over DFS with a likely over-fitted heuristic function.
-- Recommend: luajit

if #arg == 1 then
    FILE = arg[1]

else
    FILE = "test.txt"
end

local data
local f = io.open(FILE,"r")
if f ~= nil then
    data = f:read("a")
    f:close()
else
    print("Bad file: " .. FILE)
    os.exit(1)
end

-- Special test processing
data, _ = string.gsub(data,"(%s)%s","%1")
data, _ = string.gsub(data,"\n "," ")

-- Run single simulation
local function sim(ore_ore, cla_ore, obs_ore, obs_cla, geo_ore, geo_obs)

    -- recursive depth-first search
    local function simulate_round(t, ho, hc, hs, hg, bo, bc, bs, bg)
        if t == 24 then
            return hg + bg
        elseif ho >= geo_ore and hs >= geo_obs then
                return simulate_round(t+1, ho + bo - geo_ore, hc + bc, hs + bs - geo_obs, hg + bg, bo, bc, bs, bg +1)
        else
            local can_buy_ore = ho >= ore_ore and bc < 2
            local can_buy_cla = ho >= cla_ore and bs < 2
            local can_buy_obs = ho >= obs_ore and hc >= obs_cla and bg < 2

            -- If I do nothing
            local max_geo_if = simulate_round(t+1, ho + bo, hc + bc, hs + bs, hg + bg, bo, bc, bs, bg)

            -- prioritize obsidian
            if can_buy_obs then
                local geo = simulate_round(t+1, ho + bo - obs_ore, hc + bc - obs_cla, hs + bs, hg + bg, bo, bc, bs +1, bg)
                if geo > max_geo_if then
                    max_geo_if = geo
                end
            else
                if can_buy_cla then
                    local geo = simulate_round(t+1, ho + bo - cla_ore, hc + bc, hs + bs, hg + bg, bo, bc +1, bs, bg)
                    if geo > max_geo_if then
                        max_geo_if = geo
                    end
                end

                if can_buy_ore then
                    local geo = simulate_round(t+1, ho + bo - ore_ore, hc + bc, hs + bs, hg + bg, bo +1, bc, bs, bg)
                    if geo > max_geo_if then
                        max_geo_if = geo
                    end
                end
            end

            return max_geo_if
        end
    end

    --                         t ho hc hs hg bo bc bs bg
    local geo = simulate_round(1, 0, 0, 0, 0, 1, 0, 0, 0)
    print( "Result: " .. geo)

    return geo
end

local total = 0
local pattern = "print (%d+):[A-Za-z ]+(%d+) ore. [A-Za-z ]+(%d+) ore. [A-Za-z ]+(%d+) ore and (%d+) clay. [A-Za-z ]+(%d+) ore and (%d+) obsidian."
for bp, oo, co, so, sc, go, gs in string.gmatch(data,pattern) do
    print( "Input: " .. oo .. " " .. co .. " " .. so .. " " .. sc .. " " .. go .. " " .. gs)
    local geo = sim(tonumber(oo),tonumber(co),tonumber(so),tonumber(sc),tonumber(go),tonumber(gs))
    total = total + geo * bp
end
print("Total: " .. total)
