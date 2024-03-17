def rate_activity(Age, workouts) -> float:
    moderate_activity = 0
    vigorous_activity = 0
    muscle_activity = 0
    muscle_days = set()

    #TODO make code to extract activity time by type

    cardio_score = min([1 - ((150 - moderate_activity - (vigorous_activity * 2)) / 150), 1])
    muscle_score = min([len(muscle_days) / 2, 1])
    score = 0.7 * cardio_score + 0.3 * muscle_score
    return min([score, 1])