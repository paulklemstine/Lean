"""
Cellular Automata as Algebraic Varieties over GF(2)
===================================================

Numerical demonstration of the results:

  * Each elementary cellular automaton (ECA) rule is a degree <= 3 polynomial
    map over the binary field GF(2) = {0, 1}.
  * The configurations fixed by a rule form its fixed-point variety V(g).
  * The naive conjecture "dynamical complexity = fixed-point dimension" is
    FALSE and in fact inverted: the Turing-complete Rule 110 fixes only the
    all-zero configuration (dimension 0), while the trivial identity Rule 204
    fixes the whole space (dimension n).
  * The additive rules 90 and 150 have LINEAR varieties whose dimensions are
    controlled by elementary arithmetic (Pisano period 3, parity).

Everything below is self-contained standard-library Python with type hints.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Tuple

# A local rule maps (left, cell, right) in GF(2)^3 to a new cell in GF(2).
LocalRule = Callable[[int, int, int], int]


# --------------------------------------------------------------------------- #
# The landmark rules as multilinear polynomials over GF(2) (all arithmetic %2)
# --------------------------------------------------------------------------- #
def rule0(a: int, b: int, c: int) -> int:
    return 0


def rule204(a: int, b: int, c: int) -> int:  # identity
    return b


def rule51(a: int, b: int, c: int) -> int:  # global complement
    return (b + 1) % 2


def rule170(a: int, b: int, c: int) -> int:  # left shift
    return c


def rule240(a: int, b: int, c: int) -> int:  # right shift
    return a


def rule90(a: int, b: int, c: int) -> int:  # additive, Sierpinski
    return (a + c) % 2


def rule150(a: int, b: int, c: int) -> int:  # additive
    return (a + b + c) % 2


def rule110(a: int, b: int, c: int) -> int:  # Turing-complete cubic
    return (b + c + b * c + a * b * c) % 2


LANDMARKS: List[Tuple[str, LocalRule]] = [
    ("Rule 0   (null)", rule0),
    ("Rule 204 (identity)", rule204),
    ("Rule 51  (complement)", rule51),
    ("Rule 170 (left shift)", rule170),
    ("Rule 240 (right shift)", rule240),
    ("Rule 90  (additive)", rule90),
    ("Rule 150 (additive)", rule150),
    ("Rule 110 (universal)", rule110),
]


# --------------------------------------------------------------------------- #
# Core: the global step on a cyclic lattice and its fixed points
# --------------------------------------------------------------------------- #
def step(g: LocalRule, s: Tuple[int, ...]) -> Tuple[int, ...]:
    """One synchronous update of configuration s on a cycle of length len(s)."""
    n = len(s)
    return tuple(g(s[(i - 1) % n], s[i], s[(i + 1) % n]) for i in range(n))


def fixed_configs(g: LocalRule, n: int) -> List[Tuple[int, ...]]:
    """Brute-force enumerate all configurations s in GF(2)^n with step(g,s)=s."""
    return [s for s in product((0, 1), repeat=n) if step(g, s) == s]


def fixed_count(g: LocalRule, n: int) -> int:
    return len(fixed_configs(g, n))


def is_linear_variety(g: LocalRule, n: int) -> bool:
    """A subset of GF(2)^n is a linear subspace iff it contains 0 and is closed
    under coordinatewise addition mod 2."""
    fixed = set(fixed_configs(g, n))
    zero = tuple(0 for _ in range(n))
    if zero not in fixed:
        return False
    for x in fixed:
        for y in fixed:
            xy = tuple((xi + yi) % 2 for xi, yi in zip(x, y))
            if xy not in fixed:
                return False
    return True


def dimension(g: LocalRule, n: int) -> str:
    """If the variety is linear, |V| = 2^dim gives the dimension exactly."""
    c = fixed_count(g, n)
    if is_linear_variety(g, n):
        return str(c.bit_length() - 1)  # log2 of a power of two
    return f"(nonlinear, |V|={c})"


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_fixed_counts() -> None:
    print("=" * 70)
    print("Fixed-point counts |V(g)| for the landmark rules on cycles n=2..8")
    print("=" * 70)
    header = f"{'rule':<24}" + "".join(f"n={n:<4}" for n in range(2, 9))
    print(header)
    for name, g in LANDMARKS:
        row = f"{name:<24}"
        for n in range(2, 9):
            row += f"{fixed_count(g, n):<6}"
        print(row)


def demo_refutation() -> None:
    print("\n" + "=" * 70)
    print("Refutation: universal Rule 110 vs. trivial identity Rule 204")
    print("=" * 70)
    print(f"{'n':<4}{'|V(110)|':<12}{'|V(204)|=2^n':<16}{'ratio':<10}")
    for n in range(2, 11):
        v110 = fixed_count(rule110, n)
        v204 = fixed_count(rule204, n)
        print(f"{n:<4}{v110:<12}{v204:<16}{v204 // v110:<10}")
    print("Rule 110 (Class 4, universal): dimension 0  -- smallest possible.")
    print("Rule 204 (Class 2, trivial):   dimension n  -- largest possible.")
    print("The conjecture 'complexity = dimension' is inverted.")


def demo_dimensions() -> None:
    print("\n" + "=" * 70)
    print("Dimension / linearity of each variety (n = 6)")
    print("=" * 70)
    for name, g in LANDMARKS:
        lin = "LINEAR" if is_linear_variety(g, 6) else "nonlinear"
        print(f"{name:<24} dim = {dimension(g, 6):<18} [{lin}]")


def demo_rule90_pisano() -> None:
    print("\n" + "=" * 70)
    print("Rule 90 and the Pisano period 3 (Fibonacci mod 2)")
    print("=" * 70)
    print("Fibonacci sequence mod 2 (period 3): ", end="")
    a, b = 0, 1
    seq = []
    for _ in range(12):
        seq.append(a % 2)
        a, b = b, (a + b)
    print(seq)
    print(f"{'n':<4}{'|V(90)|':<10}{'3 | n ?':<10}{'dim':<6}")
    for n in range(2, 13):
        c = fixed_count(rule90, n)
        print(f"{n:<4}{c:<10}{str(n % 3 == 0):<10}{c.bit_length() - 1:<6}")
    print("Nontrivial fixed points exist exactly when 3 | n (dim jumps 0 -> 2).")


def demo_companion_matrix() -> None:
    print("\n" + "=" * 70)
    print("Fibonacci companion matrix T = [[0,1],[1,1]] over GF(2): order 3")
    print("=" * 70)

    def matmul(A, B):  # 2x2 over GF(2)
        return [[(A[i][0] * B[0][j] + A[i][1] * B[1][j]) % 2
                 for j in range(2)] for i in range(2)]

    T = [[0, 1], [1, 1]]
    I = [[1, 0], [0, 1]]
    P = I
    for k in range(1, 5):
        P = matmul(P, T)
        print(f"T^{k} = {P}   {'= I' if P == I else ''}")
    print("orderOf(T) = 3 = Pisano period pi(2); T^n = I  <=>  3 | n.")


def demo_rule150_parity() -> None:
    print("\n" + "=" * 70)
    print("Rule 150 and two-periodicity: dimension by parity of n")
    print("=" * 70)
    print(f"{'n':<4}{'|V(150)|':<10}{'parity':<10}{'dim':<6}")
    for n in range(2, 11):
        c = fixed_count(rule150, n)
        parity = "even" if n % 2 == 0 else "odd"
        print(f"{n:<4}{c:<10}{parity:<10}{c.bit_length() - 1:<6}")
    print("Even n: even/odd sublattices independent (dim 2).")
    print("Odd  n: two-periodicity forces constancy (dim 1).")


if __name__ == "__main__":
    demo_fixed_counts()
    demo_refutation()
    demo_dimensions()
    demo_rule90_pisano()
    demo_companion_matrix()
    demo_rule150_parity()
