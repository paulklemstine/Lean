def compute_min_stable_level(theories: set) -> int:
    level = 0
    if 'TQFT' in theories: level = max(level, 1)
    if 'CFT' in theories or 'String' in theories: level = max(level, 2)
    if 'Gravity' in theories: level = max(level, 3)
    return level