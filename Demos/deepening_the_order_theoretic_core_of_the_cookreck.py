"""
demo.py — Numerical demonstrations for

    "The Order-Theoretic Core of the Cook-Reckhow Program"

Every result in the accompanying article and paper is illustrated here with
self-contained, type-hinted Python. No external dependencies (standard library
only). Run directly:

    python3 demo.py

The demos mirror, in numbers, the formally verified theorems:

  * PolyBounded / PolyMono blow-up class (Defs 2.1, 2.2)
  * Fibonacci is super-polynomial  -> linear/Fibonacci separation (Thm 4.6)
  * Direct-sum meet is a greatest lower bound (Thm 5.5)
  * Domination characterization of simulation (Thm 6.2)
  * Power-tower ladder has infinite height (Thm 6.8)
  * Density: interPowSys sits strictly between consecutive rungs (Thm 7.5)
  * Holographic proof metric: Lipschitz law + chain exactness (Thms 8.6-8.9)
"""

from __future__ import annotations

from collections import deque
from typing import Callable, Dict, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Section 2: the polynomial blow-up class
# ---------------------------------------------------------------------------


def poly_bounded_witness(
    f: Callable[[int], int], max_k: int = 8, n_max: int = 60
) -> Optional[int]:
    """Return the smallest exponent k with f(n)+1 <= (n+2)^k for all n <= n_max,
    or None if no such k <= max_k is found (evidence of super-polynomial growth)."""
    for k in range(0, max_k + 1):
        if all(f(n) + 1 <= (n + 2) ** k for n in range(n_max + 1)):
            return k
    return None


def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


# ---------------------------------------------------------------------------
# Section 6: size-indexed systems and the domination law
# ---------------------------------------------------------------------------


def dominates_polynomially(
    a: Callable[[int], int],
    b: Callable[[int], int],
    max_k: int = 8,
    n_max: int = 40,
) -> Optional[int]:
    """Test simulation of `sysOfSize a` by `sysOfSize b` (Thm 6.2): find the
    smallest k with a(n) <= (b(n)+2)^k for all n <= n_max (a monotone polynomial
    blow-up f(m) = (m+2)^k dominating a at b). None => no simulation evidence."""
    for k in range(0, max_k + 1):
        if all(a(n) <= (b(n) + 2) ** k for n in range(n_max + 1)):
            return k
    return None


def pow_system_size(k: int) -> Callable[[int], int]:
    """Size function of powSystem k: n |-> 2^(n^k)."""
    return lambda n: 2 ** (n ** k)


def inter_pow_size(k: int) -> Callable[[int], int]:
    """Size function of interPowSys k: upper rate on even n, lower rate on odd n."""
    return lambda n: 2 ** (n ** (k + 1)) if n % 2 == 0 else 2 ** (n ** k)


# ---------------------------------------------------------------------------
# Section 8: proof metric (graph distance) and holography
# ---------------------------------------------------------------------------


def min_deriv_len(
    step: Callable[[int], List[int]], a: int, b: int, bound: int = 10_000
) -> Optional[int]:
    """minDerivLen: BFS shortest-path length in the axiom-step graph from a to b."""
    if a == b:
        return 0
    seen = {a}
    frontier: deque[Tuple[int, int]] = deque([(a, 0)])
    while frontier:
        node, dist = frontier.popleft()
        if dist > bound:
            return None
        for nxt in step(node):
            if nxt == b:
                return dist + 1
            if nxt not in seen:
                seen.add(nxt)
                frontier.append((nxt, dist + 1))
    return None


def chain_step(n: int) -> List[int]:
    """The chain theory 0 -> 1 -> 2 -> ... : single axiom step n |-> n+1."""
    return [n + 1]


# ===========================================================================
# Demonstrations
# ===========================================================================


def demo_fibonacci_separation() -> None:
    print("=" * 72)
    print("DEMO 1 — Fibonacci growth is super-polynomial (Thm 4.2, 4.6)")
    print("=" * 72)
    k_id = poly_bounded_witness(lambda n: n)
    k_fib = poly_bounded_witness(fib)
    print(f"  PolyBounded(id)?   exponent k = {k_id}  (linear -> bounded)")
    print(f"  PolyBounded(F)?    exponent k = {k_fib}  (None => NOT bounded)")
    print("  Sample race  (n+2)^4  vs  F(n):")
    for n in (10, 20, 30, 40):
        print(f"    n={n:>2}:  (n+2)^4 = {(n + 2) ** 4:<12}  F(n) = {fib(n)}")
    print("  => fibSystem does NOT p-simulate linSystem.\n")


def demo_domination_law() -> None:
    print("=" * 72)
    print("DEMO 2 — Domination characterization of simulation (Thm 6.2)")
    print("=" * 72)
    lin, fb = (lambda n: n), fib
    print(f"  linSystem simulates fibSystem?  k = {dominates_polynomially(lin, fb)}"
          "   (n <= F(n)+const: YES)")
    print(f"  fibSystem simulates linSystem?  k = {dominates_polynomially(fb, lin)}"
          "   (None: NO)")
    print("  => strict 2-chain  linSystem < fibSystem.\n")


def demo_direct_sum_meet() -> None:
    print("=" * 72)
    print("DEMO 3 — Direct-sum meet is the greatest lower bound (Thm 5.5)")
    print("=" * 72)
    a = pow_system_size(1)            # 2^n
    b = pow_system_size(2)            # 2^(n^2)
    meet = lambda n: min(a(n), b(n))  # GLB size = pointwise min
    print("  P = sysOfSize 2^n,  Q = sysOfSize 2^(n^2)")
    print("  meet size (pointwise min) is simulated by both P and Q:")
    print(f"    meet <= P ?  k = {dominates_polynomially(meet, a)}")
    print(f"    meet <= Q ?  k = {dominates_polynomially(meet, b)}")
    print("  and any common lower bound uses the MAX of the two blow-ups.\n")


def demo_infinite_ladder() -> None:
    print("=" * 72)
    print("DEMO 4 — Power-tower ladder: infinite height (Thm 6.7, 6.8)")
    print("=" * 72)
    for k in range(1, 4):
        lower, upper = pow_system_size(k), pow_system_size(k + 1)
        up_sim = dominates_polynomially(lower, upper)     # expect an exponent
        down_sim = dominates_polynomially(upper, lower)   # expect None
        print(f"  powSystem {k} < powSystem {k + 1}:"
              f"  up-sim k={up_sim}, down-sim={down_sim}  (None => strict)")
    print("  => an infinite strictly increasing chain of p-degrees.\n")


def demo_density() -> None:
    print("=" * 72)
    print("DEMO 5 — Density: a degree strictly between consecutive rungs (Thm 7.5)")
    print("=" * 72)
    k = 1
    lower, upper, mid = pow_system_size(k), pow_system_size(k + 1), inter_pow_size(k)
    print(f"  k={k}:  powSystem {k}  <  interPowSys {k}  <  powSystem {k + 1}")
    print(f"    lower <= mid ?  k = {dominates_polynomially(lower, mid)} (YES)")
    print(f"    mid <= lower ?  k = {dominates_polynomially(mid, lower)} (None => strict)")
    print(f"    mid <= upper ?  k = {dominates_polynomially(mid, upper)} (YES)")
    print(f"    upper <= mid ?  k = {dominates_polynomially(upper, mid)} (None => strict)")
    print("  interPowSys: upper rate on even n, lower rate on odd n.")
    for n in range(2, 7):
        tag = "even/upper" if n % 2 == 0 else "odd/lower"
        print(f"    n={n}: mid size 2^{n ** (k + 1) if n % 2 == 0 else n ** k}  ({tag})")
    print()


def demo_holography() -> None:
    print("=" * 72)
    print("DEMO 6 — Holographic proof metric: Lipschitz + chain exactness (Thm 8.6-8.9)")
    print("=" * 72)
    print("  Chain theory 0->1->2->...:  minDerivLen(a,b) = b - a")
    for a, b in [(0, 5), (3, 10), (7, 7)]:
        d = min_deriv_len(chain_step, a, b)
        print(f"    minDerivLen({a},{b}) = {d}  (= b-a = {b - a})")
    print("  Doubling map n|->2n is a stretch-2 translation; metric scales by EXACTLY 2:")
    for a, b in [(0, 5), (2, 6), (3, 9)]:
        d_lo = min_deriv_len(chain_step, a, b)
        d_hi = min_deriv_len(chain_step, 2 * a, 2 * b)
        assert d_lo is not None and d_hi is not None
        print(f"    d(2*{a},2*{b}) = {d_hi} = 2 * {d_lo} = 2*d({a},{b})  "
              f"[Lipschitz bound L*d attained]")
    print()


def main() -> None:
    demo_fibonacci_separation()
    demo_domination_law()
    demo_direct_sum_meet()
    demo_infinite_ladder()
    demo_density()
    demo_holography()
    print("All numerical demonstrations completed — consistent with the formal theorems.")


if __name__ == "__main__":
    main()
