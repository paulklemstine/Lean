"""
Erdos-Straus Conjecture: numerical demonstrations.

The Erdos-Straus conjecture states that for every integer n >= 2, the fraction
4/n can be written as a sum of three unit fractions:

    4/n = 1/x + 1/y + 1/z,   with x, y, z positive integers.

This script demonstrates, with exact rational arithmetic, the structural results
of the accompanying paper:

  * the arithmetic bridge (a cleared integer identity certifies a solution);
  * the four parametric families (even, multiples of three, n = 3 mod 4,
    n = 5 mod 8);
  * divisor inheritance (a solution for a divisor lifts to a multiple), and the
    failure of the false reverse direction;
  * the prime-core reduction to primes p = 1 mod 8;
  * a finite certification for all 2 <= n < 1000.

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Optional, Tuple

Triple = Tuple[int, int, int]


# ---------------------------------------------------------------------------
# The arithmetic bridge
# ---------------------------------------------------------------------------

def verify_cleared_identity(n: int, x: int, y: int, z: int) -> bool:
    """Check the denominator-cleared identity 4*x*y*z = n*(xy + yz + zx).

    By the bridge theorem (es_of_nat), positive x, y, z satisfying this identity
    certify that 4/n = 1/x + 1/y + 1/z.
    """
    return 4 * (x * y * z) == n * (x * y + y * z + z * x)


def verify_rational(n: int, triple: Triple) -> bool:
    """Check 4/n = 1/x + 1/y + 1/z exactly using rational arithmetic."""
    x, y, z = triple
    if min(x, y, z) <= 0 or n <= 0:
        return False
    return Fraction(4, n) == Fraction(1, x) + Fraction(1, y) + Fraction(1, z)


# ---------------------------------------------------------------------------
# The four parametric families
# ---------------------------------------------------------------------------

def family_even(n: int) -> Optional[Triple]:
    """Even denominators: n = 2m  ->  (m, m+1, m(m+1))."""
    if n % 2 != 0 or n < 2:
        return None
    m = n // 2
    return (m, m + 1, m * (m + 1))


def family_three_dvd(n: int) -> Optional[Triple]:
    """Multiples of three: n = 3m  ->  (m+1, m(m+1), 3m)."""
    if n % 3 != 0 or n < 1:
        return None
    m = n // 3
    return (m + 1, m * (m + 1), 3 * m)


def family_three_mod_four(n: int) -> Optional[Triple]:
    """Sierpinski: n = 3 mod 4, n+1 = 4k  ->  (k, 2kn, 2kn)."""
    if n % 4 != 3:
        return None
    k = (n + 1) // 4
    return (k, 2 * k * n, 2 * k * n)


def family_five_mod_eight(n: int) -> Optional[Triple]:
    """Komornik: n = 5 mod 8, n+3 = 8b  ->  (2b, 2bn, bn)."""
    if n % 8 != 5:
        return None
    b = (n + 3) // 8
    return (2 * b, 2 * b * n, b * n)


# ---------------------------------------------------------------------------
# Divisor inheritance
# ---------------------------------------------------------------------------

def lift_solution(triple: Triple, k: int) -> Triple:
    """Lift a solution for m to a solution for n = k*m by scaling denominators."""
    x, y, z = triple
    return (k * x, k * y, k * z)


# ---------------------------------------------------------------------------
# Prime-core reduction and the structured solver
# ---------------------------------------------------------------------------

def min_fac(n: int) -> int:
    """Smallest prime factor of n >= 2."""
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def search_prime_witness(p: int, bound: int = 200000) -> Optional[Triple]:
    """Brute-force a witness for a prime p (used for p = 1 mod 8).

    Searches x in a small range and solves the resulting two-unit-fraction
    sub-problem 4/p - 1/x = 1/y + 1/z exactly.
    """
    target = Fraction(4, p)
    # x must satisfy 1/x < 4/p, i.e. x > p/4; and 1/x >= (4/p)/3.
    x_lo = p // 4 + 1
    x_hi = min(bound, (3 * p) // 4 + 2)
    for x in range(x_lo, x_hi + 1):
        rem = target - Fraction(1, x)  # = 1/y + 1/z, must be positive
        if rem <= 0:
            continue
        # rem = a/c ; need 1/y + 1/z = a/c with y <= z.
        a, c = rem.numerator, rem.denominator
        # y ranges so that 1/y >= rem/2 and 1/y < rem.
        y_lo = c // a + 1
        y_hi = (2 * c) // a + 1
        for y in range(y_lo, y_hi + 1):
            second = rem - Fraction(1, y)  # = 1/z
            if second <= 0:
                continue
            if second.numerator == 1:
                z = second.denominator
                return (x, y, z)
    return None


def solve(n: int) -> Triple:
    """Structured solver: return a witness triple (x, y, z) for 4/n.

    Uses the four families directly, and the prime-core reduction otherwise.
    """
    if n < 2:
        raise ValueError("n must be >= 2")
    for fam in (family_even, family_three_dvd,
                family_three_mod_four, family_five_mod_eight):
        t = fam(n)
        if t is not None:
            return t
    # Remaining case: n and all its prime factors are = 1 mod 8.
    p = min_fac(n)
    if p == n:  # n is prime, p = 1 mod 8
        t = search_prime_witness(p)
        if t is None:
            raise RuntimeError(f"no witness found for prime {p}")
        return t
    # composite: lift a solution for the smallest prime factor.
    t = solve(p)
    return lift_solution(t, n // p)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_families() -> None:
    print("=" * 64)
    print("Parametric families (each verified exactly as a rational identity)")
    print("=" * 64)
    examples = [
        ("even          ", 10, family_even(10)),
        ("three_dvd     ", 21, family_three_dvd(21)),
        ("three_mod_four", 11, family_three_mod_four(11)),  # 11 = 3 mod 4
        ("five_mod_eight", 13, family_five_mod_eight(13)),  # 13 = 5 mod 8
    ]
    for name, n, t in examples:
        ok_rat = verify_rational(n, t)
        ok_int = verify_cleared_identity(n, *t)
        print(f"{name}: 4/{n:<4} = 1/{t[0]} + 1/{t[1]} + 1/{t[2]}"
              f"   rational={ok_rat}  cleared={ok_int}")


def demo_divisor_inheritance() -> None:
    print()
    print("=" * 64)
    print("Divisor inheritance and the false reverse direction")
    print("=" * 64)
    base_n = 11
    base = family_three_mod_four(base_n)
    print(f"Solution for n={base_n}: {base}, valid={verify_rational(base_n, base)}")
    for k in (2, 3, 5):
        n = k * base_n
        lifted = lift_solution(base, k)
        print(f"  lift x{k} -> n={n}: {lifted}, valid={verify_rational(n, lifted)}")
    print("Reverse direction is FALSE: ES(4) holds but ES(4/4)=ES(1) fails,")
    print("  since 4/1 = 4 > 1 + 1 + 1 = 3 (max of three unit fractions).")


def demo_prime_core() -> None:
    print()
    print("=" * 64)
    print("Prime-core reduction: the hard residue p = 1 mod 8")
    print("=" * 64)
    hard_primes = [17, 41, 73, 89, 97, 113]
    for p in hard_primes:
        t = search_prime_witness(p)
        ok = verify_rational(p, t) if t else False
        print(f"  p={p:<4} (p mod 8 = {p % 8}): witness {t}  valid={ok}")


def demo_finite_certification(limit: int = 1000) -> None:
    print()
    print("=" * 64)
    print(f"Finite certification: solving 4/n for all 2 <= n < {limit}")
    print("=" * 64)
    failures = 0
    for n in range(2, limit):
        t = solve(n)
        if not verify_rational(n, t):
            failures += 1
            print(f"  FAILURE at n={n}: {t}")
    if failures == 0:
        print(f"  All {limit - 2} cases verified: 4/n = 1/x + 1/y + 1/z exactly.")
    else:
        print(f"  {failures} failures found.")


def main() -> None:
    demo_families()
    demo_divisor_inheritance()
    demo_prime_core()
    demo_finite_certification(1000)


if __name__ == "__main__":
    main()


"""
Visualization: residue-class coverage of the Erdos-Straus conjecture.

Colors each integer 2 <= n < 300 by which structural rule solves 4/n:
even, multiple of three, n = 3 mod 4 (Sierpinski), n = 5 mod 8 (Komornik),
or reduction to a prime p = 1 mod 8 (the open core). The plot makes the
"great collapse" visible: almost every residue is covered, and the open
cases form a sparse set.
"""

from __future__ import annotations

from typing import List
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def min_fac(n: int) -> int:
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def classify(n: int) -> str:
    """Return the rule that first applies to n."""
    if n % 2 == 0:
        return "even"
    if n % 3 == 0:
        return "mult_of_3"
    if n % 4 == 3:
        return "sierpinski"   # n = 3 mod 4
    if n % 8 == 5:
        return "komornik"     # n = 5 mod 8
    # n = 1 mod 8 and odd, not divisible by 3:
    p = min_fac(n)
    return "prime_core" if p == n else "lift_to_core"


COLORS = {
    "even": "#4C72B0",
    "mult_of_3": "#55A868",
    "sierpinski": "#C44E52",
    "komornik": "#8172B3",
    "lift_to_core": "#CCB974",
    "prime_core": "#000000",
}
LABELS = {
    "even": "Even (n = 2m)",
    "mult_of_3": "Multiple of 3",
    "sierpinski": "Sierpinski (n = 3 mod 4)",
    "komornik": "Komornik (n = 5 mod 8)",
    "lift_to_core": "Lift to core prime",
    "prime_core": "Open core: prime = 1 mod 8",
}


def main() -> None:
    N = 300
    cols = 30
    fig, ax = plt.subplots(figsize=(12, 5))
    for n in range(2, N):
        cls = classify(n)
        row, col = divmod(n, cols)
        ax.add_patch(plt.Rectangle((col, -row), 0.92, 0.92,
                                   color=COLORS[cls]))
        ax.text(col + 0.46, -row + 0.46, str(n), ha="center", va="center",
                fontsize=5, color="white" if cls == "prime_core" else "black")
    ax.set_xlim(0, cols)
    ax.set_ylim(-(N // cols) - 1, 1)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Erdos-Straus: which rule solves 4/n  (2 <= n < 300)")
    handles: List[mpatches.Patch] = [
        mpatches.Patch(color=COLORS[k], label=LABELS[k]) for k in LABELS
    ]
    ax.legend(handles=handles, loc="lower center", ncol=3,
              bbox_to_anchor=(0.5, -0.18), fontsize=8)
    plt.tight_layout()
    plt.savefig("erdos_straus_coverage.png", dpi=150, bbox_inches="tight")
    print("Saved erdos_straus_coverage.png")


if __name__ == "__main__":
    main()
