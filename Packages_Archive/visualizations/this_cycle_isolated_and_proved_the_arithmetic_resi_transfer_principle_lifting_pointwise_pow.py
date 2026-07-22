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

def pointwise_law_holds(j: int, k: int, m: int) -> bool:
    """Finite check: m | x^j - x^k for every residue x mod m."""
    return all((pow(x, j, m) - pow(x, k, m)) % m == 0 for x in range(m))

def transfer_congruence(j: int, k: int, m: int, n: int) -> int:
    """Certify m | sigma_j(n) - sigma_k(n); return the quotient."""
    if not pointwise_law_holds(j, k, m):
        raise ValueError(f'pointwise law fails for j={j}, k={k}, m={m}')
    total = sum(d ** j - d ** k for d in divisors(n))
    assert total % m == 0
    return total // m

if __name__ == '__main__':
    for n in range(1, 11):
        q = transfer_congruence(7, 3, 120, n)
        print(f'n={n:2d}  (sigma_7-sigma_3)/120 = {q}')
