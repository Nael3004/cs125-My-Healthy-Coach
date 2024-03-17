from workout import *
from food_item import *

def recommend(fat, sat_fat, chol, carbs, sodium, fiber, prot, sugar, moderate_activity, vigorous_activity, total_sleeptime, total_deep, total_REM, ideal, foods, workouts, food_rate, workout_rate, restrictions):
    nut_score = rate_nutrition(fat, sat_fat, chol, carbs, sodium, fiber, prot, sugar)
    act_score = rate_activity(moderate_activity, vigorous_activity)
    sleep_score = rate_sleep(total_sleeptime, total_deep, total_REM, ideal)
    if nut_score <= act_score and nut_score <= sleep_score:
        sub_scores = []
        sub_scores.append(("fiber", min([max([(13 - (28 - fiber)) / 13, 0]), max([(18 - (fiber - 28)) / 18, 0])])))
        sub_scores.append(("fat", min([max([(53 - (78 - fat)) / 53, 0]), max([(15 - (fat - 78)) / 15, 0])])))
        sub_scores.append(("sat_fat", min([max([(15 - (20 - sat_fat)) / 15, 0]), max([(10 - (sat_fat - 20)) / 10, 0])])))
        sub_scores.append(("chol", min([max([(100 - (300 - chol)) / 100, 0]), max([(25 - (chol - 300)) / 25, 0])])))
        sub_scores.append(("carbs", min([max([(53 - (78 - fat)) / 53, 0]), max([(15 - (fat - 78)) / 15, 0])])))
        sub_scores.append(("sodium", min([max([(53 - (78 - fat)) / 53, 0]), max([(15 - (fat - 78)) / 15, 0])])))
        sub_scores.append(("prot", min([max([(53 - (78 - fat)) / 53, 0]), max([(15 - (fat - 78)) / 15, 0])])))
        sub_scores.append(("sugar", min([max([(53 - (78 - fat)) / 53, 0]), max([(15 - (fat - 78)) / 15, 0])])))
        cat = (sub_scores.sort(lambda x: x[1]))[0]

    elif act_score <= nut_score and act_score <= sleep_score:

    elif sleep_score <= nut_score and sleep_score <= act_score:




def rate_nutrition(fat, sat_fat, chol, carbs, sodium, fiber, prot, sugar) -> float:
    fiber_score = min([max([(13 - (28 - fiber)) / 13, 0]), max([(18 - (fiber - 28)) / 18, 0])])
    
    fat_score = min([max([(53 - (78 - fat)) / 53, 0]), max([(15 - (fat - 78)) / 15, 0])])

    sat_fat_score = min([max([(15 - (20 - sat_fat)) / 15, 0]), max([(10 - (sat_fat - 20)) / 10, 0])])

    chol_score = min([max([(100 - (300 - chol)) / 100, 0]), max([(25 - (chol - 300)) / 25, 0])])

    carbs_score = min([max([(175 - (275 - carbs)) / 175, 0]), max([(75 - (carbs - 275)) / 75, 0])])

    sodium_score = min([max([(700 - (2300 - sodium)) / 700, 0]), max([(350 - (sodium - 2300)) / 350, 0])])

    prot_score = min([max([(15 - (50 - prot)) / 15, 0]), max([(20 - (prot - 50)) / 20, 0])])

    sugar_score = min([max([(25 - (50 - sugar)) / 25, 0]), max([(15 - (sugar - 50)) / 15, 0])])

    score = 0.125 * fiber_score + 0.125 * fat_score + 0.125 * sat_fat_score + 0.125 * chol_score + 0.125 * carbs_score + 0.125 * sodium_score + 0.125 * prot_score + 0.125 * sugar_score
    return min([score, 1])

def rate_activity(moderate_activity, vigorous_activity, muscle_activity=0) -> float:
    moderate_activity = 0
    vigorous_activity = 0
    muscle_activity = 0
    muscle_days = set()



    cardio_score = min([1 - ((150 - moderate_activity - (vigorous_activity * 2)) / 150), 1])
    muscle_score = min([len(muscle_days) / 2, 1])
    score = 0.7 * cardio_score + 0.3 * muscle_score
    return min([score, 1])

def rate_sleep(total_sleeptime, total_deep, total_REM, target_tot=8) -> float:
    avg_sleeptime = 0
    percentage_deep = 0
    percentage_REM = 0

    if avg_sleeptime >= (target_tot-1) * 3600 and avg_sleeptime <= (target_tot+1) * 3600:
        time_score = 1
    else:
        if avg_sleeptime < 7 * 3600:
            time_score = (5 - (7 - avg_sleeptime)) / 5
        else:
            time_score = (5 - (avg_sleeptime - 9)) / 5
        if time_score < 0:
            time_score = 0

    percentage_deep = total_deep / total_sleeptime
    deep_score = (0.10 - abs(0.25 - percentage_deep)) / 0.1
    if abs(0.25 - percentage_deep) > 0.1:
        deep_score = 0

    percentage_REM = total_REM / total_sleeptime
    REM_score = (0.10 - abs(0.25 - percentage_REM)) / 0.1
    if abs(0.25 - percentage_REM) > 0.1:
        REM_score = 0


    score = 0.33 * time_score + 0.33 * deep_score + 0.33 * REM_score
    return min([score, 1])