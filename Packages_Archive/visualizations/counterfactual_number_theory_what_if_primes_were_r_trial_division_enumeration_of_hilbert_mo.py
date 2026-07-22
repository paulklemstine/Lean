import math

def hilbert_factor_pairs(n: int) -> list[tuple[int, int]]:
    pairs: list[tuple[int, int]] = []
    for d in range(5, math.isqrt(n) + 1, 4):
        if n % d == 0 and (n // d) % 4 == 1:
            pairs.append((d, n // d))
    return pairs

def is_hilbert_prime(n: int) -> bool:
    return n >= 2 and n % 4 == 1 and not hilbert_factor_pairs(n)

def enumerate_hilbert_primes(bound: int) -> list[int]:
    return [n for n in range(5, bound + 1, 4) if is_hilbert_prime(n)]

if __name__ == "__main__":
    print(enumerate_hilbert_primes(100))
    assert all(is_hilbert_prime(n) for n in (9, 21, 49))
    assert 9 * 49 == 21 * 21 == 441
    print("441 has distinct Hilbert-prime factorizations 9*49 and 21*21")
