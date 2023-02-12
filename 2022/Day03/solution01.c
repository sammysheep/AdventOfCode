// Sam Shepard - 2022

#include <stdio.h>
#include <stdlib.h>

int to_score(char item)
{
    if ('a' <= item && item <= 'z')
    {
        return (item - 'a') + 1;
    }
    else if ('A' <= item && item <= 'Z')
    {
        return (item - 'A') + 27;
    }
    else
    {
        printf("Something went wrong for item '%c'!", item);
        exit(1);
    }
}

char to_char(int score)
{
    if (1 <= score && score <= 26)
    {
        return (score - 1) + 'a';
    }
    else if (27 <= score && score <= 52)
    {
        return (score - 27) + 'A';
    }
    else
    {
        printf("Something went wrong for score '%d'!", score);
        exit(1);
    }
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("\nUsage:\n\t%s <file>\n\n", argv[0]);
        exit(1);
    }

    FILE *my_input = fopen(argv[1], "r");
    if (!my_input)
    {
        printf("Error opening file!\n");
        exit(1);
    }

    char *items = NULL;
    size_t buffer_size = 0;
    ssize_t line_size = 0;

    int sum_of_scores = 0;

    while ((line_size = getline(&items, &buffer_size, my_input)) != -1)
    {
        line_size--; // no newlines
        size_t mid = line_size / 2;

        // 52 + 1 for 1-based
        int scores_present_left[53] = {0};
        int scores_present_right[53] = {0};

        for (size_t i = 0; i < mid; i++)
        {
            printf("%c", items[i]);
            scores_present_left[to_score(items[i])] = 1;
        }
        printf("\n");

        for (size_t i = mid; i < line_size; i++)
        {
            printf("%c", items[i]);
            scores_present_right[to_score(items[i])] = 1;
        }
        printf("\n");

        for (int score = 1; score < 53; score++)
        {
            if (scores_present_left[score] && scores_present_right[score])
            {
                printf("Score for common '%c': %d", to_char(score), score);
                sum_of_scores += score;
            }
        }
        printf("\n\n");
    }

    printf("\nMy total score is: %d\n", sum_of_scores);

    fclose(my_input);
    free(items);
    exit(0);
}
