def spectral_complexity(shifts: list[int]) -> int:
    return sum(abs(s) for s in shifts)