def total_persistence(intervals):
    return sum(d - b for b, d in intervals)