"""
demo.py -- Rational star pencils of the Berggren tree in the Poincare half-plane.

Self-contained numerical demonstration of the results of the paper
"Stars at Every Rational: the Berggren Tree of Pythagorean Triples in the
Poincare Half-Plane".

Everything is elementary: primitive Pythagorean triples are parametrised by
Euclid seeds (m, n) with 0 < n < m, gcd(m, n) = 1 and m + n odd, and each seed
is plotted at the point z(m, n) = (n + i)/m of the upper half-plane.

The demonstrations below verify, numerically:

  1. the radial law            cosh d(i, z(m,n)) = (m^2 + n^2 + 1) / (2m);
  2. the ray identity          p/q - Re z = (charge / q) * Im z;
  3. the hypercycle law        dist(z, geodesic over p/q) = arsinh(|charge| / q);
  4. parity quantisation       p, q both odd  =>  every charge is odd;
  5. the axis dichotomy        the centre ray carries a node iff p + q is odd;
  6. the unimodular ray parametrisation and the totient window law
                               2 phi(|k|) nodes per 2|k| consecutive parameters;
  7. the approximation dictionary and the Farey property of the innermost ray;
  8. the visibility law        adjacent rays are y/q apart at height y, so the
                               resolved star centres are the Farey fractions of
                               level floor(y / eps), counted by sum phi(q);
  9. star transport            each tree move permutes the fans, and the parity
                               of p + q is a transport invariant.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import asinh, acosh, gcd, log, sqrt
from typing import Dict, Iterator, List, Sequence, Tuple

Seed = Tuple[int, int]

# --------------------------------------------------------------------------
# 1. Euclid seeds and the Berggren moves
# --------------------------------------------------------------------------


def is_seed(m: int, n: int) -> bool:
    """A Euclid seed: 0 < n < m, coprime, of opposite parity."""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def seeds_up_to(mmax: int) -> List[Seed]:
    """All Euclid seeds with first coordinate at most mmax."""
    return [(m, n) for m in range(2, mmax + 1) for n in range(1, m) if is_seed(m, n)]


def triple(m: int, n: int) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple attached to a Euclid seed."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def move_B1(s: Seed) -> Seed:
    m, n = s
    return (2 * m - n, m)


def move_B2(s: Seed) -> Seed:
    m, n = s
    return (2 * m + n, m)


def move_B3(s: Seed) -> Seed:
    m, n = s
    return (m + 2 * n, n)


MOVES = (move_B1, move_B2, move_B3)


# --------------------------------------------------------------------------
# 2. Hyperbolic geometry of the embedding z(m, n) = (n + i)/m
# --------------------------------------------------------------------------


def zpoint(m: int, n: int) -> Tuple[float, float]:
    """The half-plane point (Re z, Im z) attached to the seed (m, n)."""
    return (n / m, 1.0 / m)


def hyp_dist(z: Tuple[float, float], w: Tuple[float, float]) -> float:
    """Hyperbolic distance in the upper half-plane."""
    dx, dy = z[0] - w[0], z[1] - w[1]
    return acosh(1.0 + (dx * dx + dy * dy) / (2.0 * z[1] * w[1]))


def dist_to_vertical(z: Tuple[float, float], x: float) -> float:
    """Distance from z to the complete geodesic joining x to infinity."""
    return asinh(abs(z[0] - x) / z[1])


def radial_law(m: int, n: int) -> Tuple[float, float]:
    """(exact cosh of the radius, the radius) of the node (m, n) about i."""
    ch = (m * m + n * n + 1) / (2 * m)
    return ch, acosh(ch)


# --------------------------------------------------------------------------
# 3. Charges: the rational star pencils
# --------------------------------------------------------------------------


def charge(p: int, q: int, m: int, n: int) -> int:
    """The charge of the seed (m, n) at the ideal point p/q: the form p*m - q*n."""
    return p * m - q * n


def ray(p: int, q: int, k: int, mmax: int) -> List[Seed]:
    """All seeds with first coordinate <= mmax lying on the ray of charge k at p/q."""
    return [s for s in seeds_up_to(mmax) if charge(p, q, s[0], s[1]) == k]


def realised_charges(p: int, q: int, mmax: int, bound: int) -> List[int]:
    """The charges of absolute value <= bound realised at p/q by seeds m <= mmax."""
    found = {charge(p, q, m, n) for (m, n) in seeds_up_to(mmax)}
    return sorted(k for k in found if abs(k) <= bound)


# --------------------------------------------------------------------------
# 4. The unimodular parametrisation of a single ray
# --------------------------------------------------------------------------


def bezout(p: int, q: int) -> Tuple[int, int]:
    """Return (a, b) with p*b - q*a = 1, for coprime p, q."""
    # extended Euclid on (p, q)
    old_r, r = p, q
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        quot = old_r // r
        old_r, r = r, old_r - quot * r
        old_s, s = s, old_s - quot * s
        old_t, t = t, old_t - quot * t
    # old_s * p + old_t * q = 1  =>  b = old_s, a = -old_t
    b, a = old_s, -old_t
    assert p * b - q * a == 1
    return a, b


def star_seed(p: int, q: int, k: int, a: int, b: int, s: int) -> Tuple[int, int]:
    """The integral pair of parameter s on the ray of charge k at p/q."""
    return (k * b + s * q, k * a + s * p)


def totient(n: int) -> int:
    """Euler's totient function."""
    if n == 0:
        return 0
    result, x, d = n, n, 2
    while d * d <= x:
        if x % d == 0:
            while x % d == 0:
                x //= d
            result -= result // d
        d += 1
    if x > 1:
        result -= result // x
    return result


def window_count(p: int, q: int, k: int, N: int) -> int:
    """Number of genuine seeds among the parameters s in [N, N + 2|k|)."""
    a, b = bezout(p, q)
    count = 0
    for s in range(N, N + 2 * abs(k)):
        m, n = star_seed(p, q, k, a, b, s)
        if is_seed(m, n):
            count += 1
    return count


# --------------------------------------------------------------------------
# 5. Farey visibility
# --------------------------------------------------------------------------


def farey_stars(Q: int) -> List[Tuple[int, int]]:
    """Star centres p/q in (0, 1] in lowest terms with q <= Q."""
    return [(p, q) for q in range(1, Q + 1) for p in range(1, q + 1) if gcd(p, q) == 1]


def farey_count(Q: int) -> int:
    return sum(totient(q) for q in range(1, Q + 1))


# --------------------------------------------------------------------------
# 6. Star transport
# --------------------------------------------------------------------------


def trans_L(v: Tuple[int, int]) -> Tuple[int, int]:
    p, q = v
    return (2 * p - q, p)


def trans_M(v: Tuple[int, int]) -> Tuple[int, int]:
    p, q = v
    return (2 * p - q, -p)


def trans_R(v: Tuple[int, int]) -> Tuple[int, int]:
    p, q = v
    return (p, q - 2 * p)


TRANSPORTS = (trans_L, trans_M, trans_R)


def transport_word(word: Sequence[int], v: Tuple[int, int]) -> Tuple[int, int]:
    for i in word:
        v = TRANSPORTS[i](v)
    return v


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_radial_law() -> None:
    banner("1. The radial law:  cosh d(i, z(m,n)) = (m^2 + n^2 + 1) / (2m)")
    print(f"{'seed':>10} {'triple':>18} {'c':>7} {'d':>10} {'d - log(c)/2':>13}")
    for (m, n) in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4), (8, 1), (12, 5), (29, 12)]:
        ch, d = radial_law(m, n)
        num = hyp_dist((0.0, 1.0), zpoint(m, n))
        assert abs(num - d) < 1e-12
        c = m * m + n * n
        print(f"{str((m, n)):>10} {str(triple(m, n)):>18} {c:>7} {d:>10.6f}"
              f" {d - 0.5 * log(c):>13.6f}")
    print("all residuals lie in [0, (1/2)log 2) = [0, 0.346574)")


def demo_ray_identity() -> None:
    banner("2. Fixed charge = one Euclidean ray, and that ray is a hypercycle")
    for (p, q, k) in [(1, 3, 1), (1, 3, 3), (1, 2, 3), (0, 1, 2), (1, 1, 3)]:
        nodes = ray(p, q, k, 200)[:6]
        level = asinh(abs(k) / q)
        print(f"\n  star p/q = {p}/{q},  charge k = {k},  "
              f"predicted hypercycle level arsinh(|k|/q) = {level:.6f}")
        for (m, n) in nodes:
            z = zpoint(m, n)
            lhs = p / q - z[0]
            rhs = (k / q) * z[1]
            d = dist_to_vertical(z, p / q)
            print(f"    seed {str((m, n)):>10}   p/q - Re z = {lhs:+.8f}"
                  f"   (k/q) Im z = {rhs:+.8f}   dist = {d:.6f}")
            assert abs(lhs - rhs) < 1e-12 and abs(d - level) < 1e-12


def demo_quantisation() -> None:
    banner("3. Parity quantisation and the axis dichotomy")
    print(f"{'p/q':>8} {'p+q':>6}  realised charges with |k| <= 8 (seeds m <= 600)")
    for (p, q) in [(0, 1), (1, 1), (1, 2), (1, 3), (1, 5), (2, 5), (3, 5), (1, 4)]:
        par = "odd " if (p + q) % 2 == 1 else "even"
        ks = realised_charges(p, q, 600, 8)
        print(f"{f'{p}/{q}':>8} {par:>6}  {ks}")
    print("\n  p + q even  =>  only odd charges  (half the rays are switched off)")
    print("  p + q odd   =>  every charge, including 0 (a node on the axis)")
    print("\n  axis nodes (charge 0), which must be the seed (q, p):")
    for (p, q) in [(1, 2), (1, 4), (2, 5), (1, 3), (1, 5)]:
        ok = is_seed(q, p)
        print(f"    star {p}/{q}: candidate seed (q,p) = {(q, p)}  "
              f"{'is a seed  -> axis occupied' if ok else 'not a seed -> axis empty'}")
    print(f"    the axis node of the star at 1/2 is {(2, 1)}, the root of the tree,"
          f" giving the triple {triple(2, 1)}")


def demo_window_law() -> None:
    banner("4. The totient window law: 2 phi(|k|) nodes per 2|k| parameters")
    print(f"{'p/q':>6} {'k':>4} {'window':>16} {'nodes':>7} {'2 phi(|k|)':>11}"
          f" {'density':>9}")
    for (p, q) in [(1, 3), (1, 5), (3, 5)]:
        for k in [1, 3, 5, 9, 15]:
            a, b = bezout(p, q)
            N = 4 * (abs(k * a) + abs(k * b) + abs(k * (b - a)) + 1)
            cnt = window_count(p, q, k, N)
            pred = 2 * totient(abs(k))
            print(f"{f'{p}/{q}':>6} {k:>4} {f'[{N},{N + 2 * abs(k)})':>16}"
                  f" {cnt:>7} {pred:>11} {totient(abs(k)) / abs(k):>9.4f}")
            assert cnt == pred
    print("\n  the window count is exactly 2 phi(|k|): a ray of charge k has")
    print("  arithmetic density phi(|k|)/|k| in its parameter, so rays of highly")
    print("  composite charge are visibly sparser (density 1 for k prime power 1,")
    print("  2/3 for k = 3, 8/15 for k = 15).")


def demo_approximation() -> None:
    banner("5. Charge = quality of rational approximation; the Farey innermost ray")
    print("  n/m - p/q = - charge / (q m):")
    for (p, q, m, n) in [(1, 3, 5, 2), (1, 3, 8, 3), (1, 2, 5, 2), (2, 5, 7, 3)]:
        k = charge(p, q, m, n)
        lhs = n / m - p / q
        rhs = -k / (q * m)
        print(f"    p/q = {p}/{q}, seed {(m, n)}: charge {k:+d},"
              f"  {lhs:+.8f} = {rhs:+.8f}")
        assert abs(lhs - rhs) < 1e-12
    print("\n  innermost ray (|charge| = 1) at 1/3: Farey neighbours of 1/3.")
    for (m, n) in ray(1, 3, -1, 40):
        print(f"    seed {str((m, n)):>9}  slope {n / m:.6f}  "
              f"error 1/(q m) = {1 / (3 * m):.6f}  "
              f"mediant denominator q + m = {3 + m}")
    print("\n  every seed is on the innermost ray of two stars of denominator < m:")
    for (m, n) in [(5, 2), (8, 3), (12, 5), (9, 4)]:
        low = [(p, q) for q in range(1, m) for p in range(0, q + 1)
               if gcd(p, q) == 1 and abs(charge(p, q, m, n)) == 1]
        print(f"    seed {str((m, n)):>8}: {[f'{p}/{q}' for (p, q) in low][:4]}")


def demo_visibility() -> None:
    banner("6. The visibility law: only Farey fractions of low level are resolved")
    y = 0.5
    print(f"  at plot height y = {y}, adjacent rays of the star at p/q are y/q apart:")
    for q in [1, 2, 3, 5, 8, 20, 100]:
        print(f"    q = {q:>4}   gap = {y / q:.6f}")
    for eps in [0.1, 0.05, 0.01]:
        Q = int(y / eps)
        stars = farey_stars(Q)
        assert len(stars) == farey_count(Q)
        print(f"\n  resolution eps = {eps}:  Q = floor(y/eps) = {Q}, "
              f"{len(stars)} centres in (0,1] (plus the centre 0)")
        print(f"    sum_(q<=Q) phi(q) = {farey_count(Q)}")
        if Q <= 6:
            print("    " + ", ".join(f"{p}/{q}" for (p, q) in stars))
    print("\n  the count grows like (3/pi^2) Q^2:")
    for Q in [10, 50, 100, 500, 1000]:
        print(f"    Q = {Q:>5}   sum phi = {farey_count(Q):>9}   "
              f"ratio/Q^2 = {farey_count(Q) / Q ** 2:.6f}   (3/pi^2 = 0.303964)")


def demo_transport() -> None:
    banner("7. Star transport: the tree permutes the fans, parity is invariant")
    print("  covariance  charge_(p,q)(B_i(m,n)) = charge_(T_i(p,q))(m,n):")
    for (p, q) in [(1, 3), (2, 5)]:
        for (m, n) in [(5, 2), (8, 3)]:
            for i, (mv, tr) in enumerate(zip(MOVES, TRANSPORTS)):
                M, N = mv((m, n))
                lhs = charge(p, q, M, N)
                P, Q_ = tr((p, q))
                rhs = charge(P, Q_, m, n)
                print(f"    star {p}/{q}, seed {(m, n)}, move B{i + 1}: "
                      f"{lhs:+d} = {rhs:+d}")
                assert lhs == rhs
    print("\n  the ladder star k/(k+1) is carried to the 0-star by B1^k:")
    for k in range(1, 6):
        v = transport_word([0] * k, (k, k + 1))
        print(f"    k = {k}:  transport of ({k},{k + 1}) by B1^{k} = {v}")
        assert v == (0, 1)
    print("\n  parity of p + q is invariant, so the 0-star (p+q odd) and the")
    print("  1-star (p+q even) lie in different transport classes: the visual")
    print("  asymmetry between them can never be undone by the tree.")


def demo_picture_summary() -> None:
    banner("8. Summary: what a plot of the tree actually shows")
    nodes = seeds_up_to(120)
    print(f"  {len(nodes)} nodes with m <= 120")
    counts: Dict[str, int] = {}
    for (p, q) in [(0, 1), (1, 1), (1, 2), (1, 3), (2, 3), (1, 5)]:
        low = sum(1 for (m, n) in nodes if abs(charge(p, q, m, n)) <= 3)
        counts[f"{p}/{q}"] = low
    for name, c in counts.items():
        print(f"    nodes on the three innermost rays of the star at {name:>4}: {c}")
    print("\n  the Pell spine, the B2-orbit of the root, is a genuine geodesic:")
    s = (2, 1)
    prev = zpoint(*s)
    for _ in range(7):
        s = move_B2(s)
        cur = zpoint(*s)
        print(f"    seed {str(s):>12}   step length {hyp_dist(prev, cur):.6f}")
        prev = cur
    print(f"    steps converge to log(1 + sqrt 2) = {log(1 + sqrt(2)):.6f}")


def main() -> None:
    demo_radial_law()
    demo_ray_identity()
    demo_quantisation()
    demo_window_law()
    demo_approximation()
    demo_visibility()
    demo_transport()
    demo_picture_summary()
    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
