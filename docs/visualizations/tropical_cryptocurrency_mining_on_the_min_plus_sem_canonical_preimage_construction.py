def canonical_preimage(y: int, h: list[int]) -> list[int]:
    return [y - hi for hi in h]