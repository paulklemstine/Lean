"""Certified decision procedure: residue-sum set R_{n,s}(m) (Theorem 4.1)."""
from __future__ import annotations
from itertools import product


def residue_sums(n: int, s: int, m: int) -> set[int]:
    """Efficient O(s*m*|P|) iterated Minkowski sum of n-th power residues."""
    powers = {pow(x, n, m) for x in range(m)}
    reachable: set[int] = {0}
    for _ in range(s):
        reachable = {(r + p) % m for r in reachable for p in powers}
    return reachable


def residue_sums_bruteforce(n: int, s: int, m: int) -> set[int]:
    """Literal Definition 2.5: O(m^s) enumeration over all s-tuples."""
    return {sum(pow(x, n, m) for x in tup) % m
            for tup in product(range(m), repeat=s)}


def locally_admissible(n: int, s: int, k: int, m: int) -> bool:
    return (k % m) in residue_sums(n, s, m)


if __name__ == "__main__":
    for n, s, m in [(2, 2, 8), (3, 3, 9), (4, 4, 16)]:
        assert residue_sums(n, s, m) == residue_sums_bruteforce(n, s, m)
        print(f"n={n} s={s} m={m}: |R|={len(residue_sums(n,s,m))}/{m}  (verified)")
