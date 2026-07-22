def certified_family_count(x: int) -> int:
    if x < 127: return 0
    count, value = 0, 127
    while value <= x:
        count += 1
        value = 1000 * value + 127
    return count
