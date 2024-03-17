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