def tower(base: int, height: int) -> int:
    if height == 0:
        return 1
    return base ** tower(base, height - 1)