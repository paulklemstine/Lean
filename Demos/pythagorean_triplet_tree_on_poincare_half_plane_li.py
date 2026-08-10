"""
Stars, Lines and Curves: the Berggren tree of Pythagorean triples in the
Poincare half-plane.

A self-contained numerical demonstration of the results of the accompanying
paper.  Every function is inlined; the only dependency is the standard library.

The dictionary under study
--------------------------
A *Euclid seed* is a pair of integers (m, n) with 0 < n < m, gcd(m, n) = 1 and
m + n odd.  It encodes the primitive Pythagorean triple

    (a, b, c) = (m^2 - n^2, 2mn, m^2 + n^2).

We embed it in the Poincare upper half-plane by

    z(m, n) = (n + i)/m,

and take i as base point.  The central identity is

    cosh d(i, z(m,n)) = (m^2 + n^2 + 1) / (2m) = (c + 1)/(2m),

so the hypotenuse of the triangle is the numerator of a hyperbolic cosine.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from math import acosh, asinh, cosh, exp, gcd, log, sinh, sqrt
from typing import Dict, Iterator, List, Optional, Tuple

Seed = Tuple[int, int]


# ----------------------------------------------------------------------------
# 1.  Seeds, moves, and the basic geometry
# ----------------------------------------------------------------------------

def is_seed(m: int, n: int) -> bool:
    """A pair (m, n) is a Euclid seed iff 0 < n < m, gcd = 1 and m + n is odd."""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def triple(m: int, n: int) -> Tuple[int, int, int]:
    """Euclid's parametrisation: the primitive triple attached to the seed."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def B1(s: Seed) -> Seed:
    """The Berggren move that preserves the 1-charge u = m - n."""
    m, n = s
    return (2 * m - n, m)


def B2(s: Seed) -> Seed:
    """The Berggren move whose orbit is the Pell spine."""
    m, n = s
    return (2 * m + n, m)


def B3(s: Seed) -> Seed:
    """The Berggren move that preserves the 0-charge n."""
    m, n = s
    return (m + 2 * n, n)


def hypotenuse(s: Seed) -> int:
    m, n = s
    return m * m + n * n


def radius(s: Seed) -> float:
    """Hyperbolic distance from the base point i to the node z(m, n)."""
    m, n = s
    return acosh((m * m + n * n + 1) / (2.0 * m))


def node_distance(s: Seed, t: Seed) -> float:
    """Exact hyperbolic distance between two nodes, via the seed cross product."""
    m, n = s
    mp, npp = t
    num = (n * mp - npp * m) ** 2 + m * m + mp * mp
    return acosh(num / (2.0 * m * mp))


def residual(s: Seed) -> float:
    """rho = d - (1/2) log c, the position of a node inside its annulus."""
    return radius(s) - 0.5 * log(hypotenuse(s))


def slope_model(s: Seed) -> float:
    """The slope model (1/2) log(1 + t^2) of the residual, t = n/m."""
    m, n = s
    return 0.5 * log(1.0 + (n / m) ** 2)


def gap_bounds(s: Seed) -> Tuple[float, float]:
    """Certified enclosure n^2/(c^2 + n^2) <= rho - rho_as <= n^2/(c(c-1))."""
    m, n = s
    c = hypotenuse(s)
    return (n * n / (c * c + n * n), n * n / (c * (c - 1)))


def parent(s: Seed) -> Optional[Seed]:
    """Inverse of the Berggren moves, by the slope trichotomy.  None at the root."""
    m, n = s
    if (m, n) == (2, 1):
        return None
    if m > 3 * n:
        return (m - 2 * n, n)
    if 2 * n < m <= 3 * n:
        return (n, m - 2 * n)
    return (n, 2 * n - m)


def address(s: Seed) -> str:
    """The address word in {1,2,3}* of a seed, read from the root downwards."""
    word: List[str] = []
    cur: Optional[Seed] = s
    while cur is not None and cur != (2, 1):
        m, n = cur
        word.append("3" if m > 3 * n else ("2" if m > 2 * n else "1"))
        cur = parent(cur)
    return "".join(reversed(word))


def enumerate_seeds(limit: int) -> Iterator[Seed]:
    """All Euclid seeds with m <= limit, in lexicographic order."""
    for m in range(2, limit + 1):
        for n in range(1, m):
            if is_seed(m, n):
                yield (m, n)


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# 2.  Demonstrations
# ----------------------------------------------------------------------------

def demo_radial_law() -> None:
    """cosh d = (c+1)/(2m), and 1/2 log c <= d <= 1/2 log(2(c+1))."""
    banner("1.  The radial law:  the hypotenuse is (essentially) the radius")
    print(f"{'seed':>10} {'triple':>18} {'c':>7} {'d':>10} {'0.5 log c':>10} "
          f"{'rho':>10} {'slope mdl':>10}")
    worst = 0.0
    for s in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4), (8, 1), (9, 4), (12, 5),
              (29, 12), (99, 70)]:
        c = hypotenuse(s)
        d = radius(s)
        r = residual(s)
        worst = max(worst, r)
        print(f"{str(s):>10} {str(triple(*s)):>18} {c:>7} {d:>10.6f} "
              f"{0.5 * log(c):>10.6f} {r:>10.6f} {slope_model(s):>10.6f}")
    print(f"\nlargest residual seen: {worst:.6f}   window bound (1/2)log 2 = "
          f"{0.5 * log(2):.6f}")

    # verified sandwich over a large range
    lo_ok = hi_ok = gap_ok = True
    for s in enumerate_seeds(400):
        c, d = hypotenuse(s), radius(s)
        lo_ok &= d >= 0.5 * log(c) - 1e-12
        hi_ok &= d <= 0.5 * log(2 * (c + 1)) + 1e-12
        g = residual(s) - slope_model(s)
        lo, hi = gap_bounds(s)
        gap_ok &= lo - 1e-12 <= g <= hi + 1e-12
    print(f"lower bound holds for all seeds m <= 400 : {lo_ok}")
    print(f"upper bound holds for all seeds m <= 400 : {hi_ok}")
    print(f"gap enclosure holds for all seeds m<=400 : {gap_ok}")


def demo_star_lines() -> None:
    """1 - Re z = (m-n) Im z and Re z = n Im z; charges are hypercycle widths."""
    banner("2.  The two stars:  every node lies on one line through 1 and one "
           "through 0")
    print(f"{'seed':>10} {'Re z':>10} {'Im z':>10} {'u=m-n':>7} "
          f"{'(1-Re)/Im':>11} {'Re/Im':>8} {'arsinh u':>10} {'arsinh n':>10}")
    for s in [(2, 1), (5, 2), (4, 1), (7, 4), (9, 4), (11, 4), (16, 5)]:
        m, n = s
        re, im = n / m, 1.0 / m
        print(f"{str(s):>10} {re:>10.6f} {im:>10.6f} {m - n:>7} "
              f"{(1 - re) / im:>11.6f} {re / im:>8.3f} "
              f"{asinh(m - n):>10.6f} {asinh(n):>10.6f}")
    print("\nThe two ratio columns reproduce u = m-n and n exactly: the node is the")
    print("intersection of the 1-star line of charge u with the 0-star line of")
    print("charge n.  The last two columns are the hyperbolic distances from the")
    print("node to the geodesics (1,inf) and (0,inf) -- the charges are widths.")

    banner("2b. A B1-arm stays on one line of the 1-star; a B3-arm on one line "
           "of the 0-star")
    s: Seed = (5, 2)
    print(f"B1-arm from {s}: charge u should stay {s[0] - s[1]}")
    cur = s
    for k in range(5):
        m, n = cur
        print(f"   k={k}  seed={cur:}  u={m - n}  n={n}  d(i,.)={radius(cur):.6f}")
        cur = B1(cur)
    cur = s
    print(f"B3-arm from {s}: charge n should stay {s[1]}")
    for k in range(5):
        m, n = cur
        print(f"   k={k}  seed={cur:}  u={m - n}  n={n}  d(i,.)={radius(cur):.6f}")
        cur = B3(cur)


def demo_quantisation_and_totient() -> None:
    """The 1-star has only odd charges; each line of charge q carries phi(2q) arms."""
    banner("3.  Quantisation of the stars, and the totient law for the arms")

    def totient(k: int) -> int:
        result, x, p = k, k, 2
        while p * p <= x:
            if x % p == 0:
                while x % p == 0:
                    x //= p
                result -= result // p
            p += 1
        if x > 1:
            result -= result // x
        return result

    print("charge q | occurs in 1-star? | occurs in 0-star? | arms of a line "
          "| phi(2q)")
    for q in range(1, 13):
        in_one = any(is_seed(n + q, n) for n in range(1, 200))
        in_zero = any(is_seed(m, q) for m in range(q + 1, q + 200))
        arms_zero = sum(1 for m in range(q + 1, 3 * q + 1)
                        if gcd(m, q) == 1 and (m + q) % 2 == 1)
        print(f"{q:>8} | {str(in_one):>17} | {str(in_zero):>17} | "
              f"{arms_zero:>14} | {totient(2 * q):>7}")
    print("\nOnly odd charges occur in the 1-star; all charges occur in the 0-star.")
    print("The two stars are therefore NOT isometric pictures.")

    print("\nArms of the 0-star line of charge 5 (the residues m in [6,15]):")
    print("   ", [m for m in range(6, 16) if gcd(m, 5) == 1 and (m + 5) % 2 == 1])
    print("    phi(10) = 4, as predicted.")


def demo_boundary_dynamics() -> None:
    """Parabolic 1/k convergence to rational tips vs 4^-k to the silver slope."""
    banner("4.  Boundary dynamics:  two parabolic cusps and one hyperbolic axis")
    t0 = 0.37
    silver_slope = sqrt(2.0) - 1.0

    def sL(t: float) -> float:
        return 1.0 / (2.0 - t)

    def sM(t: float) -> float:
        return 1.0 / (2.0 + t)

    def sR(t: float) -> float:
        return t / (1.0 + 2.0 * t)

    print(f"start slope t0 = {t0}, silver slope = sqrt(2)-1 = {silver_slope:.12f}\n")
    print(f"{'k':>4} {'B1^k t':>14} {'k(1-B1^k t)':>14} {'B3^k t':>14} "
          f"{'k B3^k t':>12} {'|B2^k t - s|':>14} {'4^-k':>10}")
    a = b = m = t0
    for k in range(1, 13):
        a, b, m = sL(a), sR(b), sM(m)
        print(f"{k:>4} {a:>14.10f} {k * (1 - a):>14.10f} {b:>14.10f} "
              f"{k * b:>12.10f} {abs(m - silver_slope):>14.3e} {4.0 ** -k:>10.3e}")
    print("\nThe outer moves crawl to the RATIONAL tips 1 and 0 at rate Theta(1/k),")
    print("with k(1 - t_k) -> 1 and k t_k -> 1/2.  The middle move races to the")
    print("IRRATIONAL point sqrt(2)-1 at rate 4^-k: it is not a star centre.")


def demo_step_trichotomy() -> None:
    """Steps -> 0 along a star arm; steps -> log(1+sqrt 2) along the Pell spine."""
    banner("5.  The step-length trichotomy")
    log_silver = log(1.0 + sqrt(2.0))
    print(f"translation length of the middle move: log(1+sqrt 2) = "
          f"{log_silver:.12f}\n")
    print(f"{'k':>4} {'B1-arm step':>14} {'B3-arm step':>14} {'spine step':>14} "
          f"{'spine - log sil':>16}")
    arm1: Seed = (5, 2)
    arm3: Seed = (5, 2)
    spine: Seed = (2, 1)
    for k in range(10):
        n1, n3, ns = B1(arm1), B3(arm3), B2(spine)
        d1, d3, ds = (node_distance(arm1, n1), node_distance(arm3, n3),
                      node_distance(spine, ns))
        print(f"{k:>4} {d1:>14.10f} {d3:>14.10f} {ds:>14.10f} "
              f"{ds - log_silver:>16.3e}")
        arm1, arm3, spine = n1, n3, ns
    print("\nArm steps shrink to zero (the arm is a curve gliding into the")
    print("boundary); spine steps lock onto log(1+sqrt 2) (a geodesic traversed")
    print("at constant speed).")

    print("\nThe Pell spine and its invariant m^2 - 2mn - n^2 = (-1)^(k+1):")
    s: Seed = (2, 1)
    for k in range(7):
        m, n = s
        print(f"   k={k}  seed={s}  m^2-2mn-n^2 = {m * m - 2 * m * n - n * n:>3}"
              f"   ratio m_(k+1)/m_k = {B2(s)[0] / m:.10f}")
        s = B2(s)
    print(f"   silver ratio 1 + sqrt 2 = {1 + sqrt(2.0):.10f}")


def demo_circles_and_volume() -> None:
    """d(i,z) <= R  <=>  (m - cosh R)^2 + n^2 <= sinh^2 R;  count ~ 0.130238 e^{2R}."""
    banner("6.  The circles of the picture, and the volume growth")
    print("Check of the circle theorem on all seeds with m <= 200, R = 1..6:")
    ok = True
    for R in [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]:
        for s in enumerate_seeds(200):
            lhs = radius(s) <= R
            m, n = s
            rhs = (m - cosh(R)) ** 2 + n * n <= sinh(R) ** 2 + 1e-9
            ok &= (lhs == rhs)
    print(f"   agreement: {ok}")

    print("\nBall counts and the conjectured constant (pi+2)/(4 pi^2) = "
          f"{(math.pi + 2) / (4 * math.pi ** 2):.8f}")
    print(f"{'R':>4} {'#B(R)':>10} {'#B(R)/e^{2R}':>14}")
    for R in [3.0, 4.0, 5.0, 6.0, 7.0]:
        bound = int(cosh(R) + sinh(R)) + 2
        count = 0
        for m in range(2, bound + 1):
            for n in range(1, m):
                if (m - cosh(R)) ** 2 + n * n <= sinh(R) ** 2 and is_seed(m, n):
                    count += 1
        print(f"{R:>4.0f} {count:>10} {count / exp(2 * R):>14.6f}")
    print("\nProved: e^{2R}/300 <= #B(R) <= 4 e^{2R}.  The ratios above converge")
    print("visibly to the conjectured 0.13023806..., which is still open.")


def demo_limit_set() -> None:
    """Dyadic seeds show every point of [0,1] is a limit of nodes."""
    banner("7.  The limit set is all of [0,1]:  dyadic seeds")
    print("For odd n < 2^K, the pair (2^K, n) is automatically a Euclid seed.")
    print(f"{'target t':>10} {'K':>4} {'seed':>16} {'slope':>12} "
          f"{'|slope - t|':>12} {'height 1/m':>12}")
    for t in [0.0, 1.0 / 3.0, 1.0 / math.sqrt(2.0), 0.9]:
        for K in [6, 12]:
            N = 2 ** K
            n = max(1, min(N - 1, int(round(t * N))))
            if n % 2 == 0:
                n += 1
            if n >= N:
                n = N - 1
            assert is_seed(N, n), (N, n)
            print(f"{t:>10.6f} {K:>4} {str((N, n)):>16} {n / N:>12.6f} "
                  f"{abs(n / N - t):>12.3e} {1 / N:>12.3e}")
    print("\nSo the two visible stars are only the most conspicuous directions:")
    print("the tree accumulates on EVERY ideal point of [0,1].")


def demo_collisions() -> None:
    """Colliding nodes factor N -- and are pushed apart by the divisor."""
    banner("8.  Collisions:  Euler factorisation, and why geometry does not help")

    def collisions_up_to(limit: int) -> Dict[int, List[Seed]]:
        table: Dict[int, List[Seed]] = {}
        for s in enumerate_seeds(limit):
            table.setdefault(hypotenuse(s), []).append(s)
        return {c: v for c, v in table.items() if len(v) >= 2}

    found = collisions_up_to(60)
    print(f"{'N':>8} {'seed 1':>10} {'seed 2':>10} {'pivot P':>9} {'g':>5} "
          f"{'N/g':>6} {'d(z1,z2)':>10} {'log g - log 2':>14}")
    for N in sorted(found)[:12]:
        (m1, n1), (m2, n2) = found[N][0], found[N][1]
        P = m1 * m2 + n1 * n2
        g = gcd(N, P)
        d = node_distance((m1, n1), (m2, n2))
        print(f"{N:>8} {str((m1, n1)):>10} {str((m2, n2)):>10} {P:>9} {g:>5} "
              f"{N // g:>6} {d:>10.6f} {log(g) - log(2):>14.6f}")
    print("\nIn every row the true separation exceeds the guaranteed log g - log 2:")
    print("the divisor the collision reveals is exactly what pushes the two")
    print("witnesses apart.")

    print("\nThe no-free-lunch count.  A collision for N sits at radius about")
    print("R = 0.5 log N + log 2, and the ball of that radius already contains")
    print("Theta(e^{2R}) = Theta(N) nodes:")
    print(f"{'N':>12} {'R':>8} {'e^{2R}':>14} {'~0.1302 e^{2R}':>16} "
          f"{'sqrt(N) (trial)':>16}")
    for N in [10 ** 3, 10 ** 5, 10 ** 7, 10 ** 9]:
        R = 0.5 * log(N) + log(2)
        print(f"{N:>12} {R:>8.4f} {exp(2 * R):>14.4g} "
              f"{0.13023806 * exp(2 * R):>16.4g} {sqrt(N):>16.4g}")
    print("\nSearching the guaranteed ball costs ~N; trial enumeration costs")
    print("~sqrt(N).  The geometry offers no shortcut.")


def demo_tree_addresses() -> None:
    """Descent to the root; depth is not controlled by hyperbolic distance."""
    banner("9.  Tree addresses, and depth versus distance")
    print(f"{'seed':>10} {'triple':>18} {'address':>14} {'depth':>6} "
          f"{'d(i,.)':>10}")
    for s in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4), (8, 1), (9, 4), (12, 5),
              (20, 9), (29, 12), (52, 51)]:
        w = address(s)
        shown = w if w else "(root)"
        if len(shown) > 14:
            shown = shown[:11] + "..."
        print(f"{str(s):>10} {str(triple(*s)):>18} "
              f"{shown:>14} {len(w):>6} {radius(s):>10.6f}")
    print("\nThe left spine (k+2, k+1) has depth k but hypotenuse only")
    print("2k^2+6k+5, so its distance is Theta(log k) while its depth is")
    print("Theta(sqrt c):  depth is NOT controlled by hyperbolic distance.")
    print(f"{'k':>5} {'seed':>12} {'depth':>6} {'d(i,.)':>10} "
          f"{'depth/d':>10}")
    for k in [1, 5, 20, 50, 100]:
        s = (k + 2, k + 1)
        print(f"{k:>5} {str(s):>12} {k:>6} {radius(s):>10.6f} "
              f"{k / radius(s):>10.3f}")


def main() -> None:
    print(__doc__)
    demo_radial_law()
    demo_star_lines()
    demo_quantisation_and_totient()
    demo_boundary_dynamics()
    demo_step_trichotomy()
    demo_circles_and_volume()
    demo_limit_set()
    demo_collisions()
    demo_tree_addresses()
    banner("Done.")


if __name__ == "__main__":
    main()
