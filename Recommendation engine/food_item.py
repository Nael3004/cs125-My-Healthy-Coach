from math import sqrt

class food():
    def __init__(self, name, fat, sat_fat, chol, carbs, sodium, fiber, prot, sugar, filter_cat=[]) -> None:
        self.name = name
        self.fat = fat
        self.sat_fat = sat_fat
        self.chol = chol
        self.carbs = carbs
        self.sodium = sodium
        self.fiber = fiber 
        self.prot = prot
        self.sugar = sugar
        self.filter_cat = filter_cat

def cosine_sim(food1, food2):
    dot = food1.fat * food2.fat + food1.carbs * food2.carbs + food1.sat_fat * food2.sat_fat + food1.chol * food2.chol + food1.sodium * food2.sodium + food1.fiber * food2.fiber + food1.prot * food2.prot + food1.sugar * food2.sugar
    f1_mag = sqrt((food1.fat ** 2) + (food1.sat_fat ** 2) + (food1.chol ** 2) + (food1.carbs ** 2) + (food1.sodium ** 2) + (food1.fiber ** 2) + (food1.prot ** 2) + (food1.sugar ** 2))
    f2_mag = sqrt((food2.fat ** 2) + (food2.sat_fat ** 2) + (food2.chol ** 2) + (food2.carbs ** 2) + (food2.sodium ** 2) + (food2.fiber ** 2) + (food2.prot ** 2) + (food2.sugar ** 2))
    return (dot) / (f1_mag * f2_mag)

basefoods = [food("", 0, 0, 0, 0, 0, 0, 0, 0)]