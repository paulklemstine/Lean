def tsha2(m: list[int], h: list[int], h2: list[int]) -> tuple[int, int]:
    return (tsha(m, h), tsha(m, h2))