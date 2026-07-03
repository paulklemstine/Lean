"""
Numerical demonstrations for:

    Fan-Structure in Selmer Rank Distributions:
    Parity Rigidity and Gaussian-Binomial Layers

This self-contained script illustrates the two structural mechanisms:

  1. Parity rigidity of rank walks (sequences of +/-1 steps):
     w(n) == w(0) + n  (mod 2), regardless of the step directions,
     and the even-loop corollary.

  2. The Selmer fan of Gaussian binomial coefficients [n,k]_q, the number
     of k-dimensional subspaces of F_q^n, defined by the forward q-Pascal
     recurrence, with:
        - finite support ([n,k]_q = 0 for k > n),
        - the dual q-Pascal recurrence,
        - self-duality [n,k]_q = [n,n-k]_q,
        - the classical limit [n,k]_1 = C(n,k),
        - the rank-one layer [n,1]_q = 1 + q + ... + q^(n-1).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from math import comb
from typing import List, Tuple


# ---------------------------------------------------------------------------
# 1. Rank walks and parity rigidity
# ---------------------------------------------------------------------------

def build_rank_walk(start: int, steps: List[int]) -> List[int]:
    """Build a rank walk from a start value and a list of +/-1 steps."""
    if any(s not in (1, -1) for s in steps):
        raise ValueError("every step must be +1 or -1")
    walk: List[int] = [start]
    for s in steps:
        walk.append(walk[-1] + s)
    return walk


def is_rank_walk(walk: List[int]) -> bool:
    """Check that consecutive terms differ by exactly +/-1."""
    return all(abs(walk[i + 1] - walk[i]) == 1 for i in range(len(walk) - 1))


def parity_oracle(start: int, n: int) -> int:
    """Predicted parity of w(n): (start + n) mod 2, independent of directions."""
    return (start + n) % 2


def verify_parity_rigidity(start: int, n: int) -> bool:
    """Check w(n) == start + n (mod 2) for ALL 2^n sign patterns of length n."""
    for signs in product((1, -1), repeat=n):
        walk = build_rank_walk(start, list(signs))
        if walk[n] % 2 != parity_oracle(start, n):
            return False
    return True


def closed_walks_have_even_length(start: int, max_len: int) -> List[Tuple[int, bool]]:
    """For each length, report whether every returning walk has even length."""
    results: List[Tuple[int, bool]] = []
    for n in range(1, max_len + 1):
        returning_lengths_all_even = True
        for signs in product((1, -1), repeat=n):
            walk = build_rank_walk(start, list(signs))
            if walk[n] == start and n % 2 != 0:
                returning_lengths_all_even = False
        results.append((n, returning_lengths_all_even))
    return results


# ---------------------------------------------------------------------------
# 2. Gaussian binomial coefficients (the Selmer fan)
# ---------------------------------------------------------------------------

def gauss_binom(q: int, n: int, k: int) -> int:
    """Gaussian binomial [n,k]_q via the forward q-Pascal recurrence.

        [0,0]_q = 1,  [0,k+1]_q = 0,  [n+1,0]_q = 1,
        [n+1,k+1]_q = [n,k]_q + q^(k+1) * [n,k+1]_q.
    """
    if k < 0 or k > n:
        return 0
    # dynamic-programming row build
    row: List[int] = [1] + [0] * n  # [m,0], [m,1], ...
    for m in range(1, n + 1):
        new = [1] + [0] * n
        for j in range(1, m + 1):
            new[j] = row[j - 1] + (q ** j) * row[j]
        row = new
    return row[k]


def fan(q: int, n: int) -> List[int]:
    """The Selmer fan: the layer sequence [n,0]_q, ..., [n,n]_q."""
    return [gauss_binom(q, n, k) for k in range(n + 1)]


def gauss_binom_dual(q: int, n: int, k: int) -> int:
    """Right-hand side of the dual recurrence for [n+1,k+1]_q."""
    return (q ** (n - k)) * gauss_binom(q, n, k) + gauss_binom(q, n, k + 1)


def q_integer(q: int, n: int) -> int:
    """The q-integer [n]_q = 1 + q + ... + q^(n-1)."""
    return sum(q ** i for i in range(n))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("PART 1  Parity rigidity of rank walks")
    print("=" * 70)
    for start, n in [(0, 2), (0, 5), (3, 7), (-2, 6)]:
        ok = verify_parity_rigidity(start, n)
        print(f"  start={start:>3}, n={n}:  w(n) == start+n (mod2) for all "
              f"{2**n} walks?  {ok}   predicted parity = {parity_oracle(start, n)}")

    print("\n  The four rank walks of length 2 starting at 0:")
    for signs in product((1, -1), repeat=2):
        w = build_rank_walk(0, list(signs))
        print(f"    {w}   -> end {w[-1]} (mod2 = {w[-1] % 2})")

    print("\n  Even-loop obstruction (every returning walk has even length):")
    for n, ok in closed_walks_have_even_length(0, 6):
        print(f"    length {n}: all returning walks even-length? {ok}")

    print("\n" + "=" * 70)
    print("PART 2  The Selmer fan of Gaussian binomial coefficients")
    print("=" * 70)
    for q, n in [(2, 4), (3, 3), (3, 4), (5, 3)]:
        f = fan(q, n)
        print(f"  q={q}, n={n}:  {f}   (sum = {sum(f)})")

    print("\n  Self-duality  [n,k]_q = [n,n-k]_q:")
    for q, n in [(2, 4), (3, 5), (5, 4)]:
        f = fan(q, n)
        sym = all(f[k] == f[n - k] for k in range(n + 1))
        print(f"    q={q}, n={n}: {f}  self-dual? {sym}")

    print("\n  Dual recurrence agrees with the forward definition:")
    ok_dual = all(
        gauss_binom(q, n + 1, k + 1) == gauss_binom_dual(q, n, k)
        for q in range(2, 6) for n in range(0, 7) for k in range(0, 7)
    )
    print(f"    [n+1,k+1]_q == q^(n-k)[n,k]_q + [n,k+1]_q  for q<=5,n,k<=6:  {ok_dual}")

    print("\n  Classical limit  [n,k]_1 = C(n,k):")
    ok_one = all(
        gauss_binom(1, n, k) == comb(n, k)
        for n in range(0, 8) for k in range(0, n + 1)
    )
    print(f"    holds for n<=7:  {ok_one}")
    print(f"    example: [4,.]_1 = {fan(1, 4)}  vs  C(4,.) = {[comb(4, k) for k in range(5)]}")

    print("\n  Rank-one layer is the q-integer  [n,1]_q = 1+q+...+q^(n-1):")
    for q, n in [(3, 4), (2, 6), (5, 3)]:
        print(f"    q={q}, n={n}: [n,1]_q = {gauss_binom(q, n, 1)}  "
              f"= [n]_q = {q_integer(q, n)}")


if __name__ == "__main__":
    main()
