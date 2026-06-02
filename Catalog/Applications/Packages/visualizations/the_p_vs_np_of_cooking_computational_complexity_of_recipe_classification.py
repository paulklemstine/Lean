def classify_recipe(r):
    if r.verify_time >= r.cook_time:
        return 'IMPOSSIBLE'
    elif r.cook_time <= 2 * r.verify_time:
        return 'EASY'
    elif r.cook_time <= 4 * r.verify_time:
        return 'MODERATE'
    else:
        return 'HARD'