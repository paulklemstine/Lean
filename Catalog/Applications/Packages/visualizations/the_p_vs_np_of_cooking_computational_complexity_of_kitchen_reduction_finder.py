def find_reduction(r1, r2):
    cook_oh = max(0, r1.cook_time - r2.cook_time)
    verify_oh = max(0, r1.verify_time - r2.verify_time)
    return max(cook_oh, verify_oh)