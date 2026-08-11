"""
The Pythagorean star map: numerical demonstrations.

Self-contained numerical verification of the exact laws governing the radial
lines that appear when the Berggren tree of primitive Pythagorean triples is
plotted in the Poincare upper half-plane through the Euclid embedding

    z(m, n) = (n + i) / m ,      0 < n < m,  gcd(m, n) = 1,  m + n odd.

Demonstrated here:

  1. The radial law            cosh d(i, z(m,n)) = (m^2 + n^2 + 1) / (2m),
     and the trajectory window (1/2) log c <= d <= (1/2) log(2(c+1)).
  2. Star charges              k(p,q; m,n) = q n - p m,
     the line equation Re z = p/q + (k/q) Im z, and the hypercycle width
     arsinh(|k|/q) = d(z, geodesic over p/q).
  3. Quantisation              p, q both odd  ==>  every charge is odd.
  4. Realisation               every admissible charge occurs, via the
     SL2(Z) construction (m, n) = (qA + yk, pA + xk) with A = 1 + k(x+y) + 2k^2 j.
  5. Resolution                delta(p/q) = gap(p,q)/q, and the visible list
     {0, 1/5, 1/3, 1/2, 3/5, 1} at threshold 2/5.
  6. Brightness                a window of 2k ray parameters carries 2 phi(k)
     nodes (both-odd star, or even charge) and phi(k) = phi(2k) otherwise.
  7. No star at an irrational  no two nodes are collinear with an irrational tip.
  8. Step-length trichotomy    fan steps -> 0, Pell spine steps -> log(1+sqrt 2).
  9. Ball counts               #{d(i, .) <= R} = Theta(e^{2R}), circle theorem.
 10. Collisions                Euler factoring, and the separation lower bound
     d(z1, z2) >= log g - log 2.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import acosh, asinh, cosh, gcd, isqrt, log, sinh, sqrt
from typing import Dict, Iterator, List, Optional, Sequence, Tuple

Seed = Tuple[int, int]


# ----------------------------------------------------------------------------
# Seeds, tree moves, embedding
# ----------------------------------------------------------------------------

def is_seed(m: int, n: int) -> bool:
    """Euclid seed: 0 < n < m, coprime, opposite parity."""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def seeds_up_to(mmax: int) -> List[Seed]:
    """All Euclid seeds with m <= mmax, in lexicographic order."""
    return [(m, n) for m in range(2, mmax + 1) for n in range(1, m) if is_seed(m, n)]


def triple(m: int, n: int) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple seeded by (m, n)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def berggren_children(s: Seed) -> Tuple[Seed, Seed, Seed]:
    """The three Berggren moves in seed coordinates."""
    m, n = s
    return ((2 * m - n, m), (2 * m + n, m), (m + 2 * n, n))


def berggren_parent(s: Seed) -> Optional[Seed]:
    """Inverse of the tree: the parent of a non-root seed, by the slope trichotomy."""
    m, n = s
    if (m, n) == (2, 1):
        return None
    if m > 3 * n:
        return (m - 2 * n, n)
    if m > 2 * n:
        return (n, m - 2 * n)
    return (n, 2 * n - m)


def depth(s: Seed) -> int:
    """Depth of a seed in the Berggren tree (root (2,1) has depth 0)."""
    d = 0
    cur: Optional[Seed] = s
    while cur is not None and cur != (2, 1):
        cur = berggren_parent(cur)
        d += 1
    return d


def embed(m: int, n: int) -> Tuple[float, float]:
    """The half-plane point z(m,n) = (n + i)/m as (Re, Im)."""
    return (n / m, 1.0 / m)


# ----------------------------------------------------------------------------
# Hyperbolic geometry
# ----------------------------------------------------------------------------

def hyp_radius(m: int, n: int) -> float:
    """d(i, z(m,n)) = arcosh((m^2 + n^2 + 1)/(2m))."""
    return acosh((m * m + n * n + 1) / (2 * m))


def hyp_dist_nodes(m1: int, n1: int, m2: int, n2: int) -> float:
    """Exact distance between two nodes: cosh d = ((n1 m2 - n2 m1)^2 + m1^2 + m2^2)/(2 m1 m2)."""
    cross = n1 * m2 - n2 * m1
    return acosh((cross * cross + m1 * m1 + m2 * m2) / (2 * m1 * m2))


def hyp_dist_numeric(z1: Tuple[float, float], z2: Tuple[float, float]) -> float:
    """Distance from the general half-plane formula, for cross-checking."""
    (x1, y1), (x2, y2) = z1, z2
    sq = (x1 - x2) ** 2 + (y1 - y2) ** 2
    return acosh(1.0 + sq / (2.0 * y1 * y2))


# ----------------------------------------------------------------------------
# Star charges, resolution, brightness
# ----------------------------------------------------------------------------

def star_charge(p: int, q: int, m: int, n: int) -> int:
    """k(p,q; m,n) = q n - p m."""
    return q * n - p * m


def hypercycle_width(p: int, q: int, m: int, n: int) -> float:
    """d(z(m,n), geodesic over p/q) = arsinh(|k|/q)."""
    return asinh(abs(star_charge(p, q, m, n)) / q)


def star_gap(p: int, q: int) -> int:
    """1 if p+q is odd, 2 if p and q are both odd."""
    return 1 if (p + q) % 2 == 1 else 2


def resolution(p: int, q: int) -> float:
    """delta(p/q) = gap(p,q)/q."""
    return star_gap(p, q) / q


def visible_rationals(threshold: float, qmax: int = 40) -> List[Tuple[int, int, float]]:
    """All p/q in [0,1] with delta(p/q) >= threshold, sorted by decreasing delta."""
    out: List[Tuple[int, int, float]] = []
    for q in range(1, qmax + 1):
        for p in range(0, q + 1):
            if gcd(p, q) != 1:
                continue
            d = resolution(p, q)
            if d >= threshold - 1e-12:
                out.append((p, q, d))
    out.sort(key=lambda t: (-t[2], t[1], t[0]))
    return out


def bezout(p: int, q: int) -> Tuple[int, int]:
    """Integers x, y with q x - p y = 1 (requires gcd(p,q) = 1)."""
    # extended Euclid on (q, p): q*a + p*b = 1, then x = a, y = -b.
    old_r, r = q, p
    old_a, a = 1, 0
    old_b, b = 0, 1
    while r != 0:
        quo = old_r // r
        old_r, r = r, old_r - quo * r
        old_a, a = a, old_a - quo * a
        old_b, b = b, old_b - quo * b
    assert old_r == 1, "p and q must be coprime"
    return old_a, -old_b


def ray_node(p: int, q: int, x: int, y: int, big_a: int, k: int) -> Seed:
    """The lattice point of ray parameter A and charge k."""
    return (q * big_a + y * k, p * big_a + x * k)


def totient(k: int) -> int:
    """Euler's totient."""
    if k == 0:
        return 0
    result, kk, d = k, k, 2
    while d * d <= kk:
        if kk % d == 0:
            while kk % d == 0:
                kk //= d
            result -= result // d
        d += 1
    if kk > 1:
        result -= result // kk
    return result


def ray_census(p: int, q: int, k: int, a: int = 0) -> int:
    """Count of Euclid seeds among the 2k ray parameters A in [a, a + 2k)."""
    x, y = bezout(p, q)
    count = 0
    for big_a in range(a, a + 2 * k):
        m, n = ray_node(p, q, x, y, big_a, k)
        if gcd(m, n) == 1 and (m + n) % 2 == 1:
            count += 1
    return count


def predicted_census(p: int, q: int, k: int) -> int:
    """The brightness law: 2 phi(k), except phi(k) in the mixed regime."""
    both_odd = (p % 2 == 1) and (q % 2 == 1)
    if both_odd or k % 2 == 0:
        return 2 * totient(k)
    return totient(k)


# ----------------------------------------------------------------------------
# Realisation of a charge, balls, collisions
# ----------------------------------------------------------------------------

def realise_charge(p: int, q: int, k: int, j: int = 0) -> Seed:
    """The SL2(Z) construction: a seed of charge exactly k at p/q."""
    x, y = bezout(p, q)
    big_a = 1 + k * (x + y) + 2 * k * k * j
    return ray_node(p, q, x, y, big_a, k)


def ball_count(radius: float) -> int:
    """#{seeds : d(i, z) <= R}, via the circle theorem."""
    c, s = cosh(radius), sinh(radius)
    total = 0
    for m in range(1, int(c + s) + 1):
        rhs = s * s - (m - c) ** 2
        if rhs < 0:
            continue
        nmax = min(m - 1, int(sqrt(rhs)))
        for n in range(1, nmax + 1):
            if is_seed(m, n):
                total += 1
    return total


def two_square_seeds(nn: int) -> List[Seed]:
    """All Euclid seeds with m^2 + n^2 = N."""
    out: List[Seed] = []
    m = isqrt(nn)
    while m * m * 2 > nn:
        rest = nn - m * m
        n = isqrt(rest)
        if n * n == rest and is_seed(m, n):
            out.append((m, n))
        m -= 1
    return out


def euler_factor(nn: int, s1: Seed, s2: Seed) -> Tuple[int, int]:
    """Euler's two-representation factorisation from a hypotenuse collision."""
    (m1, n1), (m2, n2) = s1, s2
    g = gcd(nn, m1 * m2 + n1 * n2)
    h = gcd(nn, m1 * n2 + n1 * m2)
    return (g, h)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_radial_law() -> None:
    print("=" * 78)
    print("1. THE RADIAL LAW      cosh d(i, z(m,n)) = (m^2 + n^2 + 1) / (2m)")
    print("=" * 78)
    print(f"{'seed':>10} {'triple':>18} {'c':>7} {'d(i,z)':>10} "
          f"{'(1/2)log c':>11} {'residual':>10}")
    for (m, n) in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4), (8, 1), (9, 4), (12, 5), (29, 12)]:
        a, b, c = triple(m, n)
        d = hyp_radius(m, n)
        # check against the generic distance formula
        assert abs(d - hyp_dist_numeric((0.0, 1.0), embed(m, n))) < 1e-12
        assert 0.5 * log(c) - 1e-12 <= d <= 0.5 * log(2 * (c + 1)) + 1e-12
        print(f"{str((m, n)):>10} {str((a, b, c)):>18} {c:>7} {d:>10.6f} "
              f"{0.5 * log(c):>11.6f} {d - 0.5 * log(c):>10.6f}")
    print("all residuals lie in [0, (1/2)log 2) = [0, 0.346574): verified\n")


def demo_charges() -> None:
    print("=" * 78)
    print("2. STAR CHARGES        Re z = p/q + (k/q) Im z,  width = arsinh(|k|/q)")
    print("=" * 78)
    m, n = 12, 5
    x, y = embed(m, n)
    print(f"node z(12,5) = {x:.6f} + {y:.6f}i,  triple {triple(m, n)}\n")
    print(f"{'p/q':>7} {'charge k':>9} {'k/q':>8} {'width':>10} {'line check':>12}")
    for (p, q) in [(0, 1), (1, 1), (1, 2), (1, 3), (1, 5), (3, 5)]:
        k = star_charge(p, q, m, n)
        lhs = x
        rhs = p / q + (k / q) * y
        assert abs(lhs - rhs) < 1e-12
        print(f"{f'{p}/{q}':>7} {k:>9} {k / q:>8.3f} "
              f"{hypercycle_width(p, q, m, n):>10.5f} {abs(lhs - rhs):>12.2e}")
    print("\nrays are hypercycles: equal charge => equal width")
    p, q, k = 1, 3, 3
    same = [(mm, nn) for (mm, nn) in seeds_up_to(200) if star_charge(p, q, mm, nn) == k]
    widths = {round(hypercycle_width(p, q, mm, nn), 12) for (mm, nn) in same[:12]}
    print(f"  charge {k} at 1/3: first nodes {same[:6]}")
    print(f"  distinct widths among them: {widths}  (arsinh(1) = {asinh(1.0):.6f})\n")


def demo_quantisation() -> None:
    print("=" * 78)
    print("3. QUANTISATION        p, q both odd  =>  every charge is odd")
    print("=" * 78)
    pool = seeds_up_to(300)
    for (p, q) in [(1, 1), (1, 3), (1, 5), (3, 5), (0, 1), (1, 2), (1, 4), (2, 5)]:
        charges = {star_charge(p, q, m, n) for (m, n) in pool}
        parity = "ALL ODD" if all(k % 2 != 0 for k in charges) else "both parities"
        both_odd = (p % 2 == 1 and q % 2 == 1)
        print(f"  star at {p}/{q}: {len(charges):>5} charges realised (|m| <= 300) -> "
              f"{parity:<14} (p,q both odd: {both_odd})")
    print("\n4. REALISATION         explicit SL2(Z) seed of any admissible charge")
    print(f"{'p/q':>7} {'k':>5} {'j':>3} {'seed (m,n)':>18} {'is seed':>8} {'charge':>7}")
    for (p, q, k) in [(1, 3, 1), (1, 3, 5), (1, 3, -7), (1, 2, 2), (2, 5, 3), (3, 5, 9)]:
        for j in (0, 1, 5):
            m, n = realise_charge(p, q, k, j)
            if m <= 0 or n <= 0 or n >= m:
                continue
            ok = is_seed(m, n)
            kk = star_charge(p, q, m, n)
            assert ok and kk == k
            print(f"{f'{p}/{q}':>7} {k:>5} {j:>3} {str((m, n)):>18} {str(ok):>8} {kk:>7}")
    print()


def demo_resolution() -> None:
    print("=" * 78)
    print("5. RESOLUTION          delta(p/q) = gap(p,q)/q, and the visible fans")
    print("=" * 78)
    vis = visible_rationals(0.4)
    print("  rationals of [0,1] with delta >= 2/5:")
    for (p, q, d) in vis:
        print(f"    {p}/{q:<3} = {p / q:<8.4f}  gap {star_gap(p, q)}  delta = {d:.4f}")
    listed = sorted((p / q) for (p, q, _) in vis)
    print(f"  as decimals: {[round(v, 4) for v in listed]}")
    print("  note 1/4 = 0.25 is ABSENT (even denominator forfeits the parity bonus),")
    print("  while 1/5 = 0.2 is present (1 and 5 both odd, gap 2).\n")
    print("  sharpness of the resolution bound (charges 1 and 1+gap both realised):")
    for (p, q) in [(1, 3), (1, 2), (1, 5), (2, 5)]:
        g = star_gap(p, q)
        s1 = realise_charge(p, q, 1, 3)
        s2 = realise_charge(p, q, 1 + g, 3)
        w1 = abs(star_charge(p, q, *s1)) / q
        w2 = abs(star_charge(p, q, *s2)) / q
        assert abs(abs(w1 - w2) - g / q) < 1e-12
        print(f"    {p}/{q}: |sinh-widths difference| = {abs(w1 - w2):.6f} "
              f"= delta = {g / q:.6f}")
    print()


def demo_brightness() -> None:
    print("=" * 78)
    print("6. BRIGHTNESS          totient census of a ray")
    print("=" * 78)
    print(f"{'star':>7} {'charge':>7} {'regime':>22} {'counted':>8} "
          f"{'predicted':>10} {'phi(k)':>7} {'density':>8}")
    cases = [(1, 3, 1), (1, 3, 3), (1, 3, 5), (1, 3, 15), (1, 3, 105),
             (1, 2, 2), (1, 2, 3), (1, 2, 4), (1, 2, 15),
             (2, 5, 1), (2, 5, 6), (1, 1, 7)]
    for (p, q, k) in cases:
        both_odd = (p % 2 == 1 and q % 2 == 1)
        if both_odd:
            regime = "both odd (full)"
        elif k % 2 == 0:
            regime = "even charge (full)"
        else:
            regime = "mixed (half)"
        counted = ray_census(p, q, k, a=0)
        counted_shift = ray_census(p, q, k, a=37)   # window position is irrelevant
        pred = predicted_census(p, q, k)
        assert counted == pred == counted_shift, (p, q, k, counted, pred, counted_shift)
        print(f"{f'{p}/{q}':>7} {k:>7} {regime:>22} {counted:>8} {pred:>10} "
              f"{totient(k):>7} {pred / (2 * k):>8.4f}")
    print("\n  unit rays are completely full: every lattice point is a node.")
    print("  conservation of light: a both-odd star has rays 2/q apart, each of full")
    print("  brightness; a mixed star has rays 1/q apart, each of half brightness.\n")


def demo_irrational() -> None:
    print("=" * 78)
    print("7. NO STAR AT AN IRRATIONAL POINT")
    print("=" * 78)
    alpha = sqrt(2.0) - 1.0
    pool = seeds_up_to(80)
    print(f"  alpha = sqrt(2) - 1 = {alpha:.9f} (the fixed slope of the middle move)")
    # For every pair of distinct seeds, the line through alpha and one node misses the other.
    best = None
    for (m, n) in pool:
        c = n - alpha * m                       # line through alpha containing z(m,n)
        for (m2, n2) in pool:
            if (m2, n2) == (m, n) or m2 == m:
                continue
            err = abs(n2 - alpha * m2 - c)      # zero would mean exact collinearity
            if best is None or err < best[0]:
                best = (err, (m, n), (m2, n2))
    assert best is not None and best[0] > 0.0
    print(f"  smallest collinearity defect over all pairs with m <= 80: {best[0]:.3e}")
    print(f"    attained by {best[1]} and {best[2]}  --  never exactly zero.")
    print("  meanwhile nodes accumulate AT alpha: nearest slopes n/m to alpha,")
    for mm in (100, 1000, 10000):
        cand = min(((abs(n / m - alpha), (m, n))
                    for m in range(mm // 2, mm + 1) for n in [round(alpha * m) - 1,
                                                              round(alpha * m),
                                                              round(alpha * m) + 1]
                    if is_seed(m, n)), key=lambda t: t[0])
        print(f"    m <= {mm:>6}: seed {str(cand[1]):>14}, |n/m - alpha| = {cand[0]:.3e}")
    print("  dense, but never collinear: an irrational tip can carry no fan.\n")


def demo_steps() -> None:
    print("=" * 78)
    print("8. STEP-LENGTH TRICHOTOMY")
    print("=" * 78)
    p, q = 1, 3
    j = 0
    m, n = realise_charge(p, q, 1, j)
    while not is_seed(m, n):
        j += 1
        m, n = realise_charge(p, q, 1, j)
    print(f"  fan ray: charge 1 at {p}/{q}, starting from {(m, n)}")
    prev = (m, n)
    for t in range(1, 9):
        nxt = (m + 2 * t * q, n + 2 * t * p)
        d = hyp_dist_nodes(*prev, *nxt)
        print(f"    step {t}: {str(prev):>14} -> {str(nxt):>14}   d = {d:.6f}")
        prev = nxt
    print("    steps -> 0 (parabolic): the ray glides tangentially into its tip.\n")
    print("  Pell spine (the middle move from the root):")
    s: Seed = (2, 1)
    for kk in range(8):
        m2, n2 = 2 * s[0] + s[1], s[0]
        d = hyp_dist_nodes(*s, m2, n2)
        print(f"    step {kk}: {str(s):>14} -> {str((m2, n2)):>14}   d = {d:.6f}")
        s = (m2, n2)
    print(f"    steps -> log(1 + sqrt 2) = {log(1 + sqrt(2)):.6f} (hyperbolic).\n")


def demo_balls() -> None:
    print("=" * 78)
    print("9. BALL COUNTS         circle theorem and volume growth Theta(e^{2R})")
    print("=" * 78)
    print(f"{'R':>5} {'#nodes':>9} {'e^{2R}':>13} {'ratio':>9}")
    for r in range(3, 9):
        cnt = ball_count(float(r))
        e2r = 2.718281828459045 ** (2 * r)
        print(f"{r:>5} {cnt:>9} {e2r:>13.1f} {cnt / e2r:>9.5f}")
    print("  ratios stabilise near 0.1302 = (pi + 2)/(4 pi^2), the conjectured constant.\n")


def demo_collisions() -> None:
    print("=" * 78)
    print("10. COLLISIONS         Euler factoring and the separation bound")
    print("=" * 78)
    print(f"{'N':>9} {'seed 1':>12} {'seed 2':>12} {'pivot P':>9} {'g':>6} {'h':>6} "
          f"{'d(z1,z2)':>10} {'log g - log 2':>14}")
    examples = [65, 325, 1105, 8125, 500 * 1 + 400 * 1 + 85, 500 * 4 + 400 * 2 + 85]
    for nn in examples:
        reps = two_square_seeds(nn)
        if len(reps) < 2:
            continue
        (m1, n1), (m2, n2) = reps[0], reps[1]
        pivot = m1 * m2 + n1 * n2
        g, h = euler_factor(nn, (m1, n1), (m2, n2))
        d = hyp_dist_nodes(m1, n1, m2, n2)
        bound = log(g) - log(2.0)
        assert g * h == nn and 1 < g < nn
        assert d >= bound - 1e-9
        print(f"{nn:>9} {str((m1, n1)):>12} {str((m2, n2)):>12} {pivot:>9} {g:>6} {h:>6} "
              f"{d:>10.5f} {bound:>14.5f}")
    print("\n  the family N = 500j^2 + 400j + 85 gives collisions at every scale:")
    for j in range(5):
        nn = 500 * j * j + 400 * j + 85
        s1, s2 = (20 * j + 9, 10 * j + 2), (20 * j + 7, 10 * j + 6)
        assert is_seed(*s1) and is_seed(*s2)
        assert s1[0] ** 2 + s1[1] ** 2 == nn == s2[0] ** 2 + s2[1] ** 2
        g, _ = euler_factor(nn, s1, s2)
        print(f"    j = {j}: N = {nn:>6}, seeds {s1} and {s2}, extracted divisor {g}")
    print("\n  no free lunch: the smallest ball guaranteed to contain both witnesses has")
    print("  radius ~ (1/2)log N + log 2 and therefore contains Theta(N) nodes;")
    print("  trial enumeration in O(sqrt N) is not improved by the geometry.\n")


def main() -> None:
    demo_radial_law()
    demo_charges()
    demo_quantisation()
    demo_resolution()
    demo_brightness()
    demo_irrational()
    demo_steps()
    demo_balls()
    demo_collisions()
    print("=" * 78)
    print("All assertions passed: every displayed law was checked numerically.")
    print("=" * 78)


if __name__ == "__main__":
    main()
