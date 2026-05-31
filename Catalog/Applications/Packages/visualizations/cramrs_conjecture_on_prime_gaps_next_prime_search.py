def next_prime(n: int) -> int:
    candidate = n + 1
    while not is_prime(candidate):
        candidate += 1
    return candidate