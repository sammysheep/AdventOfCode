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
    local best_score = {}
    for t=1, 32 do
        best_score[t] = 0
    end

    -- recursive depth-first search
    local function simulate_round(t, ho, hc, hs, hg, bo, bc, bs, bg)
        if t == 32 then
            return hg + bg
        else
            -- maximum 2-digit bots
            local score = hg * 100
            if score == 0 then
                score = bs
            end

            -- if beginning of round t (having done t-1 rounds) is better than the best score, update
            if score > best_score[t] then
                best_score[t] = score
            -- starting with the beginning of round 3, if the beginning of round
            -- t is worse than the beginning of round t - 3, stop
            elseif t > 3 and score < best_score[t-3] then
                    return 0
            end

            -- heuristics to avoid over spending time on ore and clay
            local can_buy_ore = ho >= ore_ore and bc < 3
            local can_buy_cla = ho >= cla_ore and bs < 3
            local can_buy_obs = ho >= obs_ore and hc >= obs_cla
            local can_buy_geo = ho >= geo_ore and hs >= geo_obs

            local max_geo_if = simulate_round(t+1, ho + bo, hc + bc, hs + bs, hg + bg, bo, bc, bs, bg)

            if can_buy_geo then
                local geo = simulate_round(t+1, ho + bo - geo_ore, hc + bc, hs + bs - geo_obs, hg + bg, bo, bc, bs, bg +1)
                if geo > max_geo_if then
                    max_geo_if = geo
                end
            end

            if can_buy_obs then
                local geo = simulate_round(t+1, ho + bo - obs_ore, hc + bc - obs_cla, hs + bs, hg + bg, bo, bc, bs +1, bg)
                if geo > max_geo_if then
                    max_geo_if = geo
                end
            end

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

            return max_geo_if
        end
    end

    --                         t ho hc hs hg bo bc bs bg
    local geo = simulate_round(1, 0, 0, 0, 0, 1, 0, 0, 0)
    print( "Result: " .. geo)

    return geo
end

local total = 1
local pattern = "print (%d+):[A-Za-z ]+(%d+) ore. [A-Za-z ]+(%d+) ore. [A-Za-z ]+(%d+) ore and (%d+) clay. [A-Za-z ]+(%d+) ore and (%d+) obsidian."
for bp, oo, co, so, sc, go, gs in string.gmatch(data,pattern) do
    print( "Input: " .. oo .. " " .. co .. " " .. so .. " " .. sc .. " " .. go .. " " .. gs)
    local geo = sim(tonumber(oo),tonumber(co),tonumber(so),tonumber(sc),tonumber(go),tonumber(gs))
    total = total * geo
    if tonumber(bp) >= 3 then
        break
    end
end
print(total)