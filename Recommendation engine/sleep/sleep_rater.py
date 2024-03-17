def rate_sleep(Age, total_sleeptime, total_deep, total_REM, total_wakeup_diff, total_fallasleep_diff, target_tot=8) -> float:
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

    regscore = max([(21 - total_fallasleep_diff - total_wakeup_diff) / 21, 0])

    score = 0.25 * time_score + 0.25 * deep_score + 0.25 * REM_score + 0.25 * regscore
    return min([score, 1])