def spectral_entropy(shifts: list[int]) -> int:
    return len(set(abs(s) for s in shifts))