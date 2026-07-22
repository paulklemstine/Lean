def mask(message: int, randomness: int) -> int:
    if message not in (0, 1) or randomness not in (0, 1):
        raise ValueError("inputs must be bits")
    return message ^ randomness

for message in (0, 1):
    for ciphertext in (0, 1):
        fiber = [r for r in (0, 1) if mask(message, r) == ciphertext]
        assert len(fiber) == 1
        assert mask(ciphertext, fiber[0]) == message
        print(message, ciphertext, fiber)
