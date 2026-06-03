def helly_intervals(intervals):
    max_lower = max(a for a, _ in intervals)
    min_upper = min(b for _, b in intervals)
    if max_lower <= min_upper:
        return True, max_lower
    return False, None