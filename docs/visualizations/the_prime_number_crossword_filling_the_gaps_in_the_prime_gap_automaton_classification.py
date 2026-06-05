def classify_and_constrain(p: int) -> tuple:
    state = 0 if p % 6 == 1 else 1
    admissible = {0, 4} if state == 0 else {0, 2}
    return state, admissible