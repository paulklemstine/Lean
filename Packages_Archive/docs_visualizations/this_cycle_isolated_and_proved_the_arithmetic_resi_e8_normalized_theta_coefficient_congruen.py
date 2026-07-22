from typing import List

def divisors(n: int) -> List[int]:
    ds: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            if d != n // d:
                ds.append(n // d)
        d += 1
    return sorted(ds)

def sigma(k: int, n: int) -> int:
    return sum(d ** k for d in divisors(n))

def e8_normalized_congruence(n: int) -> int:
    """Certify 28800 | 240*sigma_7(n) - 240*sigma_3(n); return the quotient."""
    diff = 240 * sigma(7, n) - 240 * sigma(3, n)
    assert diff % 28800 == 0
    return diff // 28800

if __name__ == '__main__':
    for n in range(1, 11):
        print(f'n={n:2d}  (240 s7 - 240 s3)/28800 = {e8_normalized_congruence(n)}')
