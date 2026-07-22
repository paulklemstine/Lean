"""Search for local obstructions, reduced to prime powers (Thm 3.3 + 3.6)."""
from __future__ import annotations


def residue_sums(n: int, s: int, m: int) -> set[int]:
    powers = {pow(x, n, m) for x in range(m)}
    reachable: set[int] = {0}
    for _ in range(s):
        reachable = {(r + p) % m for r in reachable for p in powers}
    return reachable


def prime_powers_up_to(bound: int) -> list[int]:
    out: list[int] = []
    for p in range(2, bound + 1):
        if all(p % q for q in range(2, int(p ** 0.5) + 1)):
            pe = p
            while pe <= bound:
                out.append(pe)
                pe *= p
    return out


def find_obstructions(n: int, s: int, bound: int = 64) -> list[tuple[int, list[int]]]:
    """Return (prime power, missing residues) for each obstructing prime power."""
    obstructions: list[tuple[int, list[int]]] = []
    for m in prime_powers_up_to(bound):
        reached = residue_sums(n, s, m)
        missing = sorted(set(range(m)) - reached)
        if missing:
            obstructions.append((m, missing))
    return obstructions


if __name__ == "__main__":
    print("three cubes obstructions:", find_obstructions(3, 3))
    print("two squares obstructions:", find_obstructions(2, 2))
    print("four 4th powers obstructions:", find_obstructions(4, 4))
