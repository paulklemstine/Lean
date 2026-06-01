def tqft_oracle_level(d: int) -> tuple[int, int]:
    if d <= 3:
        return (0, 0)
    return (d - 3, d - 3)