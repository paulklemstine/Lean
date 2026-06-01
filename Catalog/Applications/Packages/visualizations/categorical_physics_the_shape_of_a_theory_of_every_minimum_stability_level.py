def min_stable_level(theories):
    REQUIRED = {'TQFT': 0, 'CFT': 1, 'String': 1, 'Gravity': 2}
    return max(REQUIRED[t] + 1 for t in theories) if theories else 0