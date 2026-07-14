"""
Numerical demonstrations of the Signed Sperner Count and its consequences.

This self-contained script illustrates:
  1. The signed count identity   U - D = [c(n)] - [c(0)].
  2. The splitting identity        #F = U + D.
  3. The parity form of Sperner's lemma.
  4. Balanced crossings when endpoints agree.
  5. Oriented / unoriented existence.
  6. The discrete intermediate value theorems (upward and downward).
  7. The discrete Brouwer fixed point.
  8. Uniform Nash equilibria under constant-sum payoff tables,
     including the cyclic family (Matching Pennies, Rock-Paper-Scissors).

Run:  python demo.py
"""

from __future__ import annotations

import random
from typing import Callable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. Colorings and the signed count
# ---------------------------------------------------------------------------

def bool_val(b: bool) -> int:
    """Color value: True -> 1, False -> 0."""
    return 1 if b else 0


def up_count(c: Callable[[int], bool], n: int) -> int:
    """Number of False -> True transitions among edges 0..n-1."""
    return sum(1 for i in range(n) if (not c(i)) and c(i + 1))


def down_count(c: Callable[[int], bool], n: int) -> int:
    """Number of True -> False transitions among edges 0..n-1."""
    return sum(1 for i in range(n) if c(i) and (not c(i + 1)))


def fully_colored(c: Callable[[int], bool], n: int) -> List[int]:
    """Indices i < n with c(i) != c(i+1)."""
    return [i for i in range(n) if c(i) != c(i + 1)]


def signed_count_holds(c: Callable[[int], bool], n: int) -> bool:
    """Verify Theorem 3.1: U - D = [c(n)] - [c(0)]."""
    lhs = up_count(c, n) - down_count(c, n)
    rhs = bool_val(c(n)) - bool_val(c(0))
    return lhs == rhs


def splitting_holds(c: Callable[[int], bool], n: int) -> bool:
    """Verify Proposition 3.2: #F = U + D."""
    return len(fully_colored(c, n)) == up_count(c, n) + down_count(c, n)


# ---------------------------------------------------------------------------
# 2. Discrete intermediate value theorems and Brouwer fixed point
# ---------------------------------------------------------------------------

def discrete_ivt_up(f: Callable[[int], int], n: int) -> Optional[int]:
    """If f(0) <= 0 < f(n), return i with f(i) <= 0 and f(i+1) > 0."""
    assert f(0) <= 0 < f(n), "hypotheses of upward discrete IVT not met"
    for i in range(n):
        if f(i) <= 0 < f(i + 1):
            return i
    return None


def discrete_ivt_down(f: Callable[[int], int], n: int) -> Optional[int]:
    """If f(n) <= 0 < f(0), return i with f(i) > 0 and f(i+1) <= 0."""
    assert f(n) <= 0 < f(0), "hypotheses of downward discrete IVT not met"
    for i in range(n):
        if f(i) > 0 >= f(i + 1):
            return i
    return None


def discrete_brouwer(g: Callable[[int], int], n: int) -> Optional[int]:
    """
    Self-map g of {0,...,n} with g(0) > 0 and g(n) <= n has an index i < n
    with i < g(i) and g(i+1) <= i+1 (a diagonal crossing / approximate fixed point).
    """
    assert g(0) > 0 and g(n) <= n, "hypotheses of discrete Brouwer not met"
    return discrete_ivt_down(lambda k: g(k) - k, n)


# ---------------------------------------------------------------------------
# 3. Uniform Nash equilibria
# ---------------------------------------------------------------------------

Matrix = List[List[float]]


def row_sums(a: Matrix) -> List[float]:
    return [sum(row) for row in a]


def col_sums(b: Matrix) -> List[float]:
    n_cols = len(b[0])
    return [sum(b[i][j] for i in range(len(b))) for j in range(n_cols)]


def uniform_is_nash(a: Matrix, b: Matrix) -> Tuple[bool, Optional[float], Optional[float]]:
    """
    Check the constant-sum criterion (Theorem 6.1).
    Returns (is_nash, E1, E2) where E1 = S1/|J|, E2 = S2/|I| when applicable.
    """
    rs = row_sums(a)
    cs = col_sums(b)
    const_rows = all(abs(x - rs[0]) < 1e-12 for x in rs)
    const_cols = all(abs(x - cs[0]) < 1e-12 for x in cs)
    if const_rows and const_cols:
        num_cols = len(a[0])
        num_rows = len(a)
        return True, rs[0] / num_cols, cs[0] / num_rows
    return False, None, None


def cyclic_game(n: int, a: Callable[[int], float], b: Callable[[int], float]) -> Tuple[Matrix, Matrix]:
    """
    Cyclic game on Z/nZ: payoff of player 1 is a((j-i) mod n),
    payoff of player 2 is b((i-j) mod n).
    """
    A = [[a((j - i) % n) for j in range(n)] for i in range(n)]
    B = [[b((i - j) % n) for j in range(n)] for i in range(n)]
    return A, B


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_signed_count() -> None:
    print("=" * 70)
    print("1-2. Signed count  U - D = [c(n)] - [c(0)]  and  #F = U + D")
    print("=" * 70)
    random.seed(0)
    for trial in range(6):
        n = random.randint(1, 20)
        bits = [random.random() < 0.5 for _ in range(n + 1)]
        c = lambda i, bits=bits: bits[i]
        U, D = up_count(c, n), down_count(c, n)
        print(f"  n={n:2d}  U={U:2d}  D={D:2d}  U-D={U-D:+d}  "
              f"[c(n)]-[c(0)]={bool_val(c(n)) - bool_val(c(0)):+d}  "
              f"#F={len(fully_colored(c, n))}  "
              f"signed={signed_count_holds(c, n)}  split={splitting_holds(c, n)}")
    print()


def demo_parity_and_balance() -> None:
    print("=" * 70)
    print("3-4. Parity form and balanced crossings")
    print("=" * 70)
    # Endpoints differ  ->  #F odd; endpoints agree -> #F even and U == D
    c1 = lambda i: i >= 4          # 0,0,0,0,1,1,...  endpoints differ
    c2 = lambda i: (i // 2) % 2 == 1  # zig-zag, both endpoints depend on n
    n = 9
    print(f"  c1: #F={len(fully_colored(c1, n))} (should be odd since endpoints differ), "
          f"parity={len(fully_colored(c1, n)) % 2}")
    n2 = 8
    same = c2(0) == c2(n2)
    print(f"  c2: c(0)={c2(0)} c(n)={c2(n2)} same_endpoints={same}  "
          f"U={up_count(c2, n2)} D={down_count(c2, n2)}  balanced={up_count(c2, n2) == down_count(c2, n2)}")
    print()


def demo_ivt_and_brouwer() -> None:
    print("=" * 70)
    print("5-7. Discrete IVT (up/down) and discrete Brouwer fixed point")
    print("=" * 70)
    f = lambda k: k * k - 17     # f(0) = -17 <= 0 < f(5) = 8
    i = discrete_ivt_up(f, 5)
    print(f"  upward IVT of f(k)=k^2-17 on 0..5:  sign change at i={i} "
          f"(f(i)={f(i)}, f(i+1)={f(i+1)})")
    h = lambda k: 30 - k * k     # h(0)=30>0, h(6)=-6<=0
    j = discrete_ivt_down(h, 6)
    print(f"  downward IVT of h(k)=30-k^2 on 0..6: sign change at i={j} "
          f"(h(i)={h(j)}, h(i+1)={h(j+1)})")
    g = lambda k: min(k + 3, 10)  # self-map of {0,..,10}: g(0)=3>0, g(10)=10<=10
    b = discrete_brouwer(g, 10)
    print(f"  discrete Brouwer for g(k)=min(k+3,10) on 0..10: crossing at i={b} "
          f"(g(i)={g(b)} > i={b},  g(i+1)={g(b+1)} <= i+1={b+1})")
    print()


def demo_nash() -> None:
    print("=" * 70)
    print("8. Uniform Nash equilibria under constant sums (cyclic family)")
    print("=" * 70)
    # Matching Pennies (n=2): player 1 wants to match, player 2 to mismatch.
    # a(d)=+1 if d==0 else -1 ; b = -a  (zero sum)
    A, B = cyclic_game(2, lambda d: 1.0 if d == 0 else -1.0,
                          lambda d: -1.0 if d == 0 else 1.0)
    ok, e1, e2 = uniform_is_nash(A, B)
    print(f"  Matching Pennies (n=2): uniform is Nash={ok}, E1={e1}, E2={e2}")

    # Rock-Paper-Scissors (n=3): win beats next (d=1), loses to previous (d=2).
    def rps(d: int) -> float:
        return {0: 0.0, 1: 1.0, 2: -1.0}[d]
    A, B = cyclic_game(3, rps, rps)
    ok, e1, e2 = uniform_is_nash(A, B)
    print(f"  Rock-Paper-Scissors (n=3): uniform is Nash={ok}, E1={e1}, E2={e2}")

    # A larger cyclic game (n=5) with arbitrary a,b.
    A, B = cyclic_game(5, lambda d: float(d), lambda d: float(d * d))
    ok, e1, e2 = uniform_is_nash(A, B)
    S1 = sum(float(d) for d in range(5))
    S2 = sum(float(d * d) for d in range(5))
    print(f"  Cyclic n=5: uniform is Nash={ok}, E1={e1} (=S1/n={S1/5}), "
          f"E2={e2} (=S2/n={S2/5})")
    print()


def main() -> None:
    demo_signed_count()
    demo_parity_and_balance()
    demo_ivt_and_brouwer()
    demo_nash()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
