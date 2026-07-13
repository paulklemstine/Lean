"""
Additive Cellular Automata on Cyclic Lattices: Wolfram meets Grothendieck
==========================================================================

Numerical demonstrations of the main theorem:

    The additive elementary cellular automaton  new_cell = old_cell + right_neighbour
    on the cyclic lattice Z/n is GLOBALLY NILPOTENT (every configuration reaches the
    all-zero state) IF AND ONLY IF n is a power of two.

Algebraic encoding
------------------
A configuration (s_0, ..., s_{n-1}) over F_2 is encoded as the polynomial
    s(X) = sum_i s_i X^i  in  R_n = F_2[X] / (X^n - 1).
One time step is multiplication by the ring element u = 1 + X.
Global nilpotency of the dynamics  <=>  u is nilpotent in R_n  <=>  n = 2^k.

Everything below is self-contained: polynomials over F_2 are represented as
Python integers (bit i = coefficient of X^i); addition is XOR.
"""

from __future__ import annotations

from typing import List, Set, Tuple


# ---------------------------------------------------------------------------
# F_2[X] arithmetic on bitmask-encoded polynomials
# ---------------------------------------------------------------------------

def f2_mul(a: int, b: int) -> int:
    """Multiply two polynomials over F_2 (carry-less / XOR multiplication)."""
    result = 0
    while b:
        if b & 1:
            result ^= a
        a <<= 1
        b >>= 1
    return result


def f2_mod(a: int, m: int) -> int:
    """Reduce polynomial a modulo polynomial m over F_2."""
    if m == 0:
        raise ZeroDivisionError("division by zero polynomial")
    deg_m = m.bit_length() - 1
    while a.bit_length() - 1 >= deg_m and a:
        shift = (a.bit_length() - 1) - deg_m
        a ^= m << shift
    return a


def f2_mulmod(a: int, b: int, m: int) -> int:
    """Multiply a*b in F_2[X]/(m)."""
    return f2_mod(f2_mul(a, b), m)


def f2_powmod(base: int, exp: int, m: int) -> int:
    """Compute base**exp in F_2[X]/(m) by fast exponentiation."""
    result = f2_mod(1, m)
    base = f2_mod(base, m)
    while exp:
        if exp & 1:
            result = f2_mulmod(result, base, m)
        base = f2_mulmod(base, base, m)
        exp >>= 1
    return result


def poly_str(p: int) -> str:
    """Human-readable rendering of an F_2 polynomial bitmask."""
    if p == 0:
        return "0"
    terms: List[str] = []
    for i in range(p.bit_length()):
        if (p >> i) & 1:
            terms.append("1" if i == 0 else ("X" if i == 1 else f"X^{i}"))
    return " + ".join(reversed(terms))


# ---------------------------------------------------------------------------
# The cyclic-lattice modulus  X^n - 1  (== X^n + 1 over F_2)
# ---------------------------------------------------------------------------

def modulus(n: int) -> int:
    """The polynomial X^n - 1 = X^n + 1 over F_2, as a bitmask."""
    return (1 << n) | 1


def ca_unit() -> int:
    """The CA element u = 1 + X, bitmask 0b11 = 3."""
    return 0b11


# ---------------------------------------------------------------------------
# Dynamics
# ---------------------------------------------------------------------------

def ca_step(state: int, n: int) -> int:
    """One automaton step on Z/n: state -> (1 + X) * state  mod (X^n - 1)."""
    return f2_mulmod(state, ca_unit(), modulus(n))


def orbit(state: int, n: int, max_steps: int = 10_000) -> Tuple[List[int], bool]:
    """
    Return the forward orbit of `state` until it repeats, and whether it dies
    (reaches 0).  Because R_n is finite the orbit is eventually periodic.
    """
    seen: Set[int] = set()
    history: List[int] = []
    s = state % (1 << n)
    for _ in range(max_steps):
        if s == 0:
            history.append(0)
            return history, True
        if s in seen:
            return history, False
        seen.add(s)
        history.append(s)
        s = ca_step(s, n)
    return history, False


def is_globally_nilpotent_bruteforce(n: int) -> bool:
    """Exhaustively check that EVERY configuration on Z/n dies (O(2^n))."""
    for state in range(1 << n):
        _, dies = orbit(state, n)
        if not dies:
            return False
    return True


# ---------------------------------------------------------------------------
# Algebraic tests
# ---------------------------------------------------------------------------

def is_power_of_two(n: int) -> bool:
    """True iff n = 2^k for some k >= 0."""
    return n > 0 and (n & (n - 1)) == 0


def unit_nilpotency_index(n: int) -> int | None:
    """
    Least N with u^N = 0 in R_n, or None if u is not nilpotent.
    By the theorem this is n when n = 2^k and None otherwise.
    """
    m = modulus(n)
    power = f2_mod(1, m)  # u^0
    u = ca_unit()
    for N in range(1, 4 * n + 2):
        power = f2_mulmod(power, u, m)
        if power == 0:
            return N
    return None


def frobenius_collapse_holds(k: int) -> bool:
    """Verify the freshman's dream  (X+1)^(2^k) = X^(2^k) + 1  over F_2."""
    n = 2 ** k
    lhs = f2_powmod_full(ca_unit(), n)  # full (non-reduced) power
    rhs = (1 << n) | 1                  # X^n + 1
    return lhs == rhs


def f2_powmod_full(base: int, exp: int) -> int:
    """Full polynomial power in F_2[X] (no reduction)."""
    result = 1
    while exp:
        if exp & 1:
            result = f2_mul(result, base)
        base = f2_mul(base, base)
        exp >>= 1
    return result


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_dichotomy(max_n: int = 20) -> None:
    print("=" * 70)
    print("MAIN THEOREM: global nilpotency  <=>  n is a power of two")
    print("=" * 70)
    print(f"{'n':>3} | {'power of 2?':>11} | {'u nilpotent (index)':>20} | "
          f"{'all die (algebra)':>17}")
    print("-" * 70)
    for n in range(1, max_n + 1):
        p2 = is_power_of_two(n)
        idx = unit_nilpotency_index(n)
        nil = idx is not None
        assert nil == p2, f"MISMATCH at n={n}"
        idx_str = str(idx) if idx is not None else "-- (immortal)"
        print(f"{n:>3} | {str(p2):>11} | {idx_str:>20} | {str(nil):>17}")
    print()


def demo_bruteforce_check(ns: Tuple[int, ...] = (3, 4, 5, 6, 8)) -> None:
    print("=" * 70)
    print("BRUTE-FORCE CROSS-CHECK: simulate EVERY configuration")
    print("=" * 70)
    for n in ns:
        bf = is_globally_nilpotent_bruteforce(n)
        alg = is_power_of_two(n)
        assert bf == alg, f"MISMATCH at n={n}"
        verdict = "MORTAL (all die)" if bf else "IMMORTAL (some cycles forever)"
        print(f"  n = {n:>2}:  {verdict}   [matches n=2^k test: {alg}]")
    print()


def demo_single_cell_orbit(n: int = 8) -> None:
    print("=" * 70)
    print(f"SPACE-TIME DIAGRAM: single black cell on Z/{n} (n = 2^k)")
    print("=" * 70)
    hist, dies = orbit(1, n)
    for t, s in enumerate(hist):
        row = "".join("#" if (s >> i) & 1 else "." for i in range(n))
        print(f"  t={t:>2}: {row}   {poly_str(s)}")
    print(f"  -> dies at step {len(hist) - 1} = n = {n}   (nilpotency index)")
    print()


def demo_immortal_orbit(n: int = 3) -> None:
    print("=" * 70)
    print(f"IMMORTAL ORBIT: single black cell on Z/{n} (n not a power of 2)")
    print("=" * 70)
    hist, dies = orbit(1, n)
    for t, s in enumerate(hist):
        row = "".join("#" if (s >> i) & 1 else "." for i in range(n))
        print(f"  t={t:>2}: {row}   {poly_str(s)}")
    print(f"  -> orbit cycles forever (period detected), never reaches 0")
    print()


def demo_frobenius() -> None:
    print("=" * 70)
    print("FROBENIUS COLLAPSE (freshman's dream):  (X+1)^(2^k) = X^(2^k) + 1")
    print("=" * 70)
    for k in range(0, 5):
        n = 2 ** k
        lhs = f2_powmod_full(ca_unit(), n)
        ok = frobenius_collapse_holds(k)
        assert ok
        print(f"  k={k}: (X+1)^{n:<3} = {poly_str(lhs)}")
    print()


if __name__ == "__main__":
    demo_dichotomy(max_n=20)
    demo_bruteforce_check()
    demo_single_cell_orbit(8)
    demo_immortal_orbit(3)
    demo_frobenius()
    print("All demonstrations agree with the theorem: mortality <=> n = 2^k.")
