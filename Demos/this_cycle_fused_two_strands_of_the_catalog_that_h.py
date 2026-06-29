"""
Conserved Quantities along Reduction Paths -- numerical demonstrations.

This self-contained script illustrates, with concrete numbers, the six results
that unify cryptographic security reductions with Fibonacci divisibility:

  1. pathLength            -- the length functional on a discrete walk.
  2. endpoint_bound        -- dist(f0, fn) <= pathLength  (generalized hybrid argument).
  3. concatenation         -- pathLength splits additively at any cut point.
  4. lipschitz_contraction -- a K-Lipschitz reduction scales path length by <= K.
  5. end_to_end_bound      -- dist(phi f0, phi fn) <= K * pathLength.
  6. fib gcd conservation  -- gcd(F m, F n) = F(gcd m n)  and the primitivity bridge.

No external dependencies; runs under any CPython 3.8+.
"""

from __future__ import annotations

from math import gcd, hypot
from typing import Callable, List, Sequence, Tuple

Point = Tuple[float, float]


# --------------------------------------------------------------------------
# 1. The length functional on a discrete path (pseudo-metric = Euclidean plane)
# --------------------------------------------------------------------------

def euclidean(x: Point, y: Point) -> float:
    """Distance in the Euclidean plane: a concrete pseudo-metric."""
    return hypot(x[0] - y[0], x[1] - y[1])


def path_length(f: Sequence[Point], n: int, dist: Callable[[Point, Point], float]) -> float:
    """pathLength(f, n) = sum_{i<n} dist(f(i), f(i+1))."""
    return sum(dist(f[i], f[i + 1]) for i in range(n))


# --------------------------------------------------------------------------
# 2. Endpoint bound (generalized hybrid argument)
# --------------------------------------------------------------------------

def endpoint_bound_holds(f: Sequence[Point], n: int,
                         dist: Callable[[Point, Point], float]) -> bool:
    """Theorem 3.1: dist(f0, fn) <= pathLength(f, n)."""
    return dist(f[0], f[n]) <= path_length(f, n, dist) + 1e-12


# --------------------------------------------------------------------------
# 3. Concatenation additivity
# --------------------------------------------------------------------------

def concatenation_residual(f: Sequence[Point], k: int, n: int,
                           dist: Callable[[Point, Point], float]) -> float:
    """Theorem 3.2: pathLength(f,n) - [pathLength(f,k) + tail(k..n)] should be 0."""
    tail = sum(dist(f[i], f[i + 1]) for i in range(k, n))
    return path_length(f, n, dist) - (path_length(f, k, dist) + tail)


# --------------------------------------------------------------------------
# 4 & 5. Lipschitz reduction: phi(x) = (K*x0, K*x1) is K-Lipschitz (Euclidean)
# --------------------------------------------------------------------------

def scale_reduction(K: float) -> Callable[[Point], Point]:
    """A K-Lipschitz map of the plane (a dilation by K)."""
    return lambda p: (K * p[0], K * p[1])


def lipschitz_contraction_check(f: Sequence[Point], n: int, K: float) -> Tuple[float, float]:
    """Theorem 3.3: pathLength(phi o f) vs K * pathLength(f)."""
    phi = scale_reduction(K)
    reduced = [phi(p) for p in f]
    return path_length(reduced, n, euclidean), K * path_length(f, n, euclidean)


def end_to_end_bound_check(f: Sequence[Point], n: int, K: float) -> Tuple[float, float]:
    """Theorem 3.4: dist(phi f0, phi fn) vs K * pathLength(f)."""
    phi = scale_reduction(K)
    lhs = euclidean(phi(f[0]), phi(f[n]))
    rhs = K * path_length(f, n, euclidean)
    return lhs, rhs


# --------------------------------------------------------------------------
# 6. Fibonacci gcd conservation and the primitivity bridge
# --------------------------------------------------------------------------

def fib(n: int) -> int:
    """n-th Fibonacci number, F(0)=0, F(1)=1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_gcd_conservation(m: int, n: int) -> Tuple[int, int]:
    """Theorem 4.1: gcd(F m, F n) should equal F(gcd m n)."""
    return gcd(fib(m), fib(n)), fib(gcd(m, n))


def proper_divisors(n: int) -> List[int]:
    """Positive divisors d of n with 0 < d < n."""
    return [d for d in range(1, n) if n % d == 0]


def primitivity_bridge_witnesses(n: int, p: int) -> List[int]:
    """
    Theorem 4.2 verification helper.

    Given n>0 and p | F(n) such that p divides F(d) for NO proper divisor d of n,
    the bridge guarantees p divides F(k) for no 0<k<n.  This returns any
    counterexample indices k (it should always be empty when the hypothesis holds).
    """
    assert n > 0 and fib(n) % p == 0, "require n>0 and p | F(n)"
    # hypothesis: p divides no F(d) for proper divisors d
    if any(fib(d) % p == 0 for d in proper_divisors(n)):
        raise ValueError("hypothesis violated: p divides F(d) for some proper divisor d")
    # conclusion claims: no 0<k<n has p | F(k)
    return [k for k in range(1, n) if fib(k) % p == 0]


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Conserved Quantities along Reduction Paths -- numerical demo")
    print("=" * 70)

    # A sample discrete path (chain of games / waypoints) in the plane.
    f: List[Point] = [(0.0, 0.0), (1.0, 2.0), (3.0, 1.0), (4.0, 4.0), (7.0, 3.0)]
    n = len(f) - 1

    print("\n[1] Path length functional")
    print(f"    path f = {f}")
    print(f"    pathLength(f, {n}) = {path_length(f, n, euclidean):.6f}")

    print("\n[2] Endpoint bound (hybrid argument):  dist(f0, fn) <= pathLength")
    print(f"    dist(f0, fn)      = {euclidean(f[0], f[n]):.6f}")
    print(f"    pathLength(f, n)  = {path_length(f, n, euclidean):.6f}")
    print(f"    inequality holds  = {endpoint_bound_holds(f, n, euclidean)}")

    print("\n[3] Concatenation additivity (residual should be ~0)")
    for k in range(0, n + 1):
        print(f"    cut k={k}: residual = {concatenation_residual(f, k, n, euclidean):.2e}")

    print("\n[4] Lipschitz contraction:  pathLength(phi o f) <= K * pathLength(f)")
    for K in (0.5, 1.0, 2.0, 3.5):
        lhs, rhs = lipschitz_contraction_check(f, n, K)
        # For a pure dilation equality holds (sharpness witness).
        print(f"    K={K:>4}:  pathLength(phi o f)={lhs:9.6f}   K*pathLength={rhs:9.6f}"
              f"   <= holds: {lhs <= rhs + 1e-9}")

    print("\n[5] End-to-end reduction bound:  dist(phi f0, phi fn) <= K * pathLength(f)")
    for K in (0.5, 1.0, 2.0, 3.5):
        lhs, rhs = end_to_end_bound_check(f, n, K)
        print(f"    K={K:>4}:  dist={lhs:9.6f}   bound={rhs:9.6f}   <= holds: {lhs <= rhs + 1e-9}")

    print("\n[6a] Fibonacci gcd conservation:  gcd(F m, F n) = F(gcd m n)")
    for (m, mn) in [(12, 8), (15, 10), (21, 14), (100, 60)]:
        lhs, rhs = fib_gcd_conservation(m, mn)
        print(f"    m={m:>4}, n={mn:>4}:  gcd(F m, F n)={lhs:<14}  F(gcd)={rhs:<14}  equal: {lhs == rhs}")

    print("\n[6b] Primitivity bridge:  local non-divisibility => global non-divisibility")
    # F(7) = 13 is prime and primitive to index 7.
    n, p = 7, 13
    witnesses = primitivity_bridge_witnesses(n, p)
    print(f"    n={n}, p={p} (p | F({n})={fib(n)});  proper divisors of n: {proper_divisors(n)}")
    print(f"    p divides F(d) for no proper divisor d -> bridge predicts no k<n with p|F(k)")
    print(f"    actual counterexample indices k: {witnesses}  (empty confirms the bridge)")

    # F(12) = 144; its primitive prime is none (12 is exceptional!), illustrate 19 | F(18).
    n, p = 18, 19
    witnesses = primitivity_bridge_witnesses(n, p)
    print(f"    n={n}, p={p} (p | F({n})={fib(n)});  counterexample indices: {witnesses}")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
