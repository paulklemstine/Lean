def fux_allowed(a: int, b: int, m: str) -> bool:
    PERFECT = {0, 7}
    if b in PERFECT:
        return m != 'parallel'
    return True