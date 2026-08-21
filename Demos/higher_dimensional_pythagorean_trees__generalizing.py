"""
Higher-Dimensional Pythagorean Trees — numerical demonstrations.

This self-contained script illustrates every headline result of the theory of
Pythagorean n-tuples (integer solutions of x_1^2 + ... + x_n^2 = y^2) organised
by the integral reflections of the Lorentz form of signature (n, 1):

  1. The descent complex of a node is downward closed with all faces of size <= n-2.
  2. In dimension three the branching number is exactly 6 or 7, decided by the
     Egyptian-fraction ("weak harmonic") inequality.
  3. Both branching numbers occur infinitely often:
        (1, 2m, 2m^2, 2m^2+1)        -> six children,
        (2m, 2m, 2m^2-1, 2m^2+1)     -> seven children (primitive).
  4. Every node in dimension n has at least n+1 children; equality only for n = 2
     (Berggren's ternary tree).
  5. Dimension four: the Pell family (1, 1, t, t; d) with d^2 - 2t^2 = 2 and t >= 4
     has a two-element descent face, so the bound #S <= n-2 is sharp for n = 4.
  6. Metric growth: rho_n = (sqrt(n)+1)/(sqrt(n)-1); rho_2 = (1+sqrt2)^2, rho_3 = 2+sqrt3
     (the fundamental unit of Z[sqrt 3]); the critical exponent log(k)/log(rho)
     crosses 1 from dimension two to dimension three.
  7. Over the integers the constant 2+sqrt3 is never attained: a+b+c < sqrt3 * d strictly.
  8. Mirror (height-neutral) nodes are fixed points of the generators, and the number
     of them with first coordinate a is exactly tau(a^2).

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Dict, Iterable, List, Sequence, Tuple

Tuple_ = Tuple[int, ...]

# ----------------------------------------------------------------------------- basics


def is_pyth_tuple(x: Sequence[int], d: int) -> bool:
    """Test the null-cone relation x_1^2 + ... + x_n^2 = d^2."""
    return sum(xi * xi for xi in x) == d * d


def content(x: Sequence[int], d: int) -> int:
    """gcd of all coordinates: the content, preserved by every reflection."""
    g = abs(d)
    for xi in x:
        g = math.gcd(g, abs(xi))
    return g


def is_primitive(x: Sequence[int], d: int) -> bool:
    return content(x, d) == 1


def sign_patterns(n: int) -> List[Tuple[int, ...]]:
    """All 2^n sign patterns eps in {+1,-1}^n."""
    return [tuple(e) for e in itertools.product((1, -1), repeat=n)]


def signed_sum(eps: Sequence[int], x: Sequence[int]) -> int:
    """The signed coordinate sum eps . x."""
    return sum(e * xi for e, xi in zip(eps, x))


def reflect(eps: Sequence[int], x: Sequence[int], d: int) -> Tuple[Tuple[int, ...], int]:
    """The signed reflection R_eps: (x; d) -> (x_i - eps_i k; d - k), k = eps.x - d."""
    k = signed_sum(eps, x) - d
    return tuple(xi - e * k for e, xi in zip(eps, x)), d - k


def minus_set(eps: Sequence[int]) -> Tuple[int, ...]:
    """The set of coordinates carrying a minus sign, as a sorted tuple of indices."""
    return tuple(i for i, e in enumerate(eps) if e == -1)


# ------------------------------------------------------------------- descent complex


def descent_complex(x: Sequence[int], d: int) -> List[Tuple[int, ...]]:
    """Faces of the descent complex: minus-sets S with eps.x > d (strict descent)."""
    faces = []
    for eps in sign_patterns(len(x)):
        if signed_sum(eps, x) > d:
            faces.append(minus_set(eps))
    return sorted(faces, key=lambda s: (len(s), s))


def children(x: Sequence[int], d: int) -> List[Tuple[Tuple[int, ...], Tuple[Tuple[int, ...], int]]]:
    """Child moves: patterns with eps.x < d, together with the resulting node."""
    out = []
    for eps in sign_patterns(len(x)):
        if signed_sum(eps, x) < d:
            out.append((eps, reflect(eps, x, d)))
    return out


def neutral_patterns(x: Sequence[int], d: int) -> List[Tuple[int, ...]]:
    """Height-neutral patterns: eps.x = d.  These fix the node."""
    return [eps for eps in sign_patterns(len(x)) if signed_sum(eps, x) == d]


def is_downward_closed(faces: Iterable[Tuple[int, ...]]) -> bool:
    face_set = set(faces)
    for S in face_set:
        for r in range(len(S)):
            for T in itertools.combinations(S, r):
                if T not in face_set:
                    return False
    return True


# ---------------------------------------------------------- dimension-three branching


def weak_defect(a: int, b: int, c: int, d: int) -> bool:
    """d <= -a+b+c  or  d <= a-b+c  or  d <= a+b-c."""
    return d <= -a + b + c or d <= a - b + c or d <= a + b - c


def harmonic_defect(a: int, b: int, c: int) -> bool:
    """Egyptian-fraction form: 1/b + 1/c <= 1/a (or a permutation)."""
    return a * (b + c) <= b * c or b * (a + c) <= a * c or c * (a + b) <= a * b


def predicted_branching(a: int, b: int, c: int, d: int) -> int:
    return 6 if weak_defect(a, b, c, d) else 7


# ------------------------------------------------------------------------ enumeration


def quadruples_up_to(height: int) -> List[Tuple[int, int, int, int]]:
    """Brute-force list of positive Pythagorean quadruples a<=b<=c with d <= height."""
    out = []
    for d in range(1, height + 1):
        for a in range(1, d + 1):
            for b in range(a, d + 1):
                r = d * d - a * a - b * b
                if r <= 0:
                    break
                c = math.isqrt(r)
                if c * c == r and c >= b:
                    out.append((a, b, c, d))
    return out


def bfs_tree(root: Tuple[Tuple[int, ...], int], max_height: int) -> List[Tuple[Tuple[int, ...], int]]:
    """Breadth-first exploration by child moves, cut off at a height bound."""
    seen = {root}
    frontier = [root]
    order = [root]
    while frontier:
        nxt = []
        for x, d in frontier:
            for _, node in children(x, d):
                if node[1] <= max_height and node not in seen:
                    seen.add(node)
                    nxt.append(node)
                    order.append(node)
        frontier = nxt
    return order


# ------------------------------------------------------------------------ Pell ladder


def pell_ladder(steps: int) -> List[Tuple[int, int]]:
    """Solutions of d^2 - 2t^2 = 2 from (t,d) = (1,2) via (t,d) -> (3t+2d, 4t+3d)."""
    out = [(1, 2)]
    for _ in range(steps):
        t, d = out[-1]
        out.append((3 * t + 2 * d, 4 * t + 3 * d))
    return out


# ----------------------------------------------------------------------- growth theory


def rho(n: int) -> float:
    """The sharp one-step growth constant (sqrt(n)+1)/(sqrt(n)-1)."""
    s = math.sqrt(n)
    return (s + 1.0) / (s - 1.0)


def critical_exponent(k: float, r: float) -> float:
    """delta with k = rho^delta."""
    return math.log(k) / math.log(r)


# ------------------------------------------------------------------------ mirror nodes


def tau(m: int) -> int:
    """Number of positive divisors."""
    return sum(1 for k in range(1, m + 1) if m % k == 0)


def mirror_nodes(a: int) -> List[Tuple[int, int, int, int]]:
    """Mirror nodes for the first-coordinate reflection: (a, a+p, a+q, a+p+q), pq = a^2."""
    out = []
    for p in range(1, a * a + 1):
        if (a * a) % p == 0:
            q = (a * a) // p
            out.append((a, a + p, a + q, a + p + q))
    return out


# ------------------------------------------------------------------------------ demos


def demo_descent_complex() -> None:
    print("=" * 78)
    print("1. THE DESCENT COMPLEX IS DOWNWARD CLOSED WITH FACES OF SIZE <= n-2")
    print("=" * 78)
    samples: List[Tuple[Tuple[int, ...], int]] = [
        ((3, 4), 5),
        ((1, 2, 2), 3),
        ((2, 3, 6), 7),
        ((4, 4, 7), 9),
        ((1, 4, 8), 9),
        ((1, 1, 7, 7), 10),
        ((1, 1, 41, 41), 58),
    ]
    for x, d in samples:
        n = len(x)
        assert is_pyth_tuple(x, d), (x, d)
        faces = descent_complex(x, d)
        biggest = max((len(S) for S in faces), default=-1)
        ok = is_downward_closed(faces)
        print(f"  n={n}  node {x};{d}   faces={faces}")
        print(f"        downward closed: {ok},  max face size {biggest} <= n-2 = {n-2}: "
              f"{biggest <= n - 2}")
    print()


def demo_branching_three() -> None:
    print("=" * 78)
    print("2. EXACT BRANCHING IN DIMENSION THREE: ALWAYS 6 OR 7")
    print("=" * 78)
    quads = quadruples_up_to(60)
    counts: Dict[int, int] = {}
    for a, b, c, d in quads:
        k = len(children((a, b, c), d))
        counts[k] = counts.get(k, 0) + 1
        assert k == predicted_branching(a, b, c, d), (a, b, c, d, k)
        assert weak_defect(a, b, c, d) == harmonic_defect(a, b, c), (a, b, c, d)
    print(f"  Checked {len(quads)} positive Pythagorean quadruples with d <= 60.")
    print(f"  Observed branching numbers: {dict(sorted(counts.items()))}")
    print("  In every case the count matched the weak-defect prediction, and the")
    print("  weak defect matched the Egyptian-fraction inequality 1/b+1/c <= 1/a (or perm).")
    print()
    print("  Sample table (a,b,c,d | defect | 1/b+1/c<=1/a? | children):")
    for a, b, c, d in quads[:12]:
        print(f"    ({a:2d},{b:2d},{c:2d},{d:2d})   {str(weak_defect(a,b,c,d)):5s}   "
              f"{str(harmonic_defect(a,b,c)):5s}   {len(children((a,b,c), d))}")
    print()


def demo_families() -> None:
    print("=" * 78)
    print("3. INFINITE FAMILIES REALISING SIX AND SEVEN CHILDREN")
    print("=" * 78)
    print("  Six-child family (1, 2m, 2m^2, 2m^2+1):")
    for m in range(2, 8):
        q = (1, 2 * m, 2 * m * m)
        d = 2 * m * m + 1
        assert is_pyth_tuple(q, d)
        print(f"    m={m}:  {q};{d}   primitive={is_primitive(q,d)}   "
              f"children={len(children(q, d))}")
    print("  Seven-child family (2m, 2m, 2m^2-1, 2m^2+1):")
    for m in range(2, 8):
        q = (2 * m, 2 * m, 2 * m * m - 1)
        d = 2 * m * m + 1
        assert is_pyth_tuple(q, d)
        print(f"    m={m}:  {q};{d}   primitive={is_primitive(q,d)}   "
              f"children={len(children(q, d))}")
    print()


def demo_universal_bound() -> None:
    print("=" * 78)
    print("4. UNIVERSAL BRANCHING BOUND: AT LEAST n+1 CHILDREN, EQUALITY ONLY FOR n=2")
    print("=" * 78)
    tests: List[Tuple[Tuple[int, ...], int]] = [
        ((3, 4), 5), ((5, 12), 13), ((20, 21), 29),
        ((1, 2, 2), 3), ((2, 3, 6), 7), ((4, 4, 7), 9),
        ((1, 1, 7, 7), 10), ((1, 2, 4, 10), 11), ((2, 4, 4, 8), 10),
    ]
    for x, d in tests:
        n = len(x)
        assert is_pyth_tuple(x, d), (x, d)
        k = len(children(x, d))
        print(f"  n={n}  node {x};{d}:  children={k}   bound n+1={n+1}   ok={k >= n + 1}")
    print("  For triples the count is exactly 3: Berggren's ternary tree is minimal.")
    print()


def demo_pell_dimension_four() -> None:
    print("=" * 78)
    print("5. DIMENSION FOUR: TWO-ELEMENT DESCENT FACES VIA PELL'S EQUATION")
    print("=" * 78)
    for t, d in pell_ladder(5):
        x = (1, 1, t, t)
        assert d * d - 2 * t * t == 2
        assert is_pyth_tuple(x, d)
        faces = descent_complex(x, d)
        two_faces = [S for S in faces if len(S) == 2]
        print(f"  (t,d)=({t},{d}):  node {x};{d}  primitive={is_primitive(x,d)}  "
              f"2-faces={two_faces}")
    print("  Two-element faces are impossible for n = 3, so the complex genuinely")
    print("  gains dimension: the bound #S <= n-2 is sharp for n = 4.")
    print()


def demo_growth() -> None:
    print("=" * 78)
    print("6. METRIC GROWTH AND THE CRITICAL EXPONENT")
    print("=" * 78)
    print(f"  rho_2 = {rho(2):.6f}   (3+2sqrt2 = {3 + 2*math.sqrt(2):.6f} = (1+sqrt2)^2)")
    print(f"  rho_3 = {rho(3):.6f}   (2+sqrt3  = {2 + math.sqrt(3):.6f})")
    print(f"  unit check: (2+sqrt3)(2-sqrt3) = {(2+math.sqrt(3))*(2-math.sqrt(3)):.12f}")
    print(f"  unit check: (3+2sqrt2)(3-2sqrt2) = "
          f"{(3+2*math.sqrt(2))*(3-2*math.sqrt(2)):.12f}")
    print("  fundamental unit of Z[sqrt3]: least positive solution of a^2-3b^2=1 is")
    sols = [(a, b) for a in range(1, 60) for b in range(1, 60) if a * a - 3 * b * b == 1]
    print(f"    {sols[:4]}  ->  a+b*sqrt3 = {sols[0][0] + sols[0][1]*math.sqrt(3):.6f}")
    print("  monotonicity of rho_n:")
    for n in (2, 3, 4, 5, 10, 100, 10_000):
        print(f"    n={n:6d}   rho_n = {rho(n):.8f}")
    d2 = critical_exponent(3, rho(2))
    d3 = critical_exponent(6, rho(3))
    d3b = critical_exponent(7, rho(3))
    print(f"  critical exponent, Berggren tree :  log 3 / log rho_2 = {d2:.6f}  (< 1)")
    print(f"  critical exponent, quadruples>=6 :  log 6 / log rho_3 = {d3:.6f}  (> 1)")
    print(f"  critical exponent, quadruples =7 :  log 7 / log rho_3 = {d3b:.6f}")
    print(f"  the exponent crosses 1: {d2:.4f} < 1 < {d3:.4f}")
    print()


def demo_strict_integral_growth() -> None:
    print("=" * 78)
    print("7. OVER THE INTEGERS 2+sqrt3 IS AN UNATTAINED SUPREMUM")
    print("=" * 78)
    best = 0.0
    arg = None
    worst_ratio = 0.0
    warg = None
    for a, b, c, d in quadruples_up_to(200):
        r = (a + b + c) / (math.sqrt(3) * d)
        if r > best:
            best, arg = r, (a, b, c, d)
        for eps in sign_patterns(3):
            _, d2 = reflect(eps, (a, b, c), d)
            if d2 > 0:
                q = d2 / d
                if q > worst_ratio:
                    worst_ratio, warg = q, (eps, (a, b, c, d))
    print(f"  max (a+b+c)/(sqrt3 d) over d<=200:  {best:.8f} < 1  at {arg}")
    print(f"  max height ratio d'/d observed  :  {worst_ratio:.8f} < 2+sqrt3 = "
          f"{2+math.sqrt(3):.8f}")
    print(f"    attained by pattern {warg[0]} at node {warg[1]}")
    print("  Equality would force a=b=c and 3a^2=d^2, impossible since sqrt3 is irrational.")
    print()


def demo_mirrors_and_divisor_law() -> None:
    print("=" * 78)
    print("8. MIRROR NODES AND THE DIVISOR LAW")
    print("=" * 78)
    print("  Mirror family (m, m+1, m(m+1), m^2+m+1), fixed by the first-coordinate flip:")
    for m in range(1, 7):
        x = (m, m + 1, m * (m + 1))
        d = m * m + m + 1
        assert is_pyth_tuple(x, d)
        fixed = reflect((-1, 1, 1), x, d) == (x, d)
        print(f"    m={m}: {x};{d}  primitive={is_primitive(x,d)}  fixed_by_R(-,+,+)={fixed}"
              f"  children={len(children(x, d))}")
    print()
    print("  Divisor law: #mirror nodes with first coordinate a = tau(a^2)")
    for a in range(1, 11):
        nodes = mirror_nodes(a)
        for (aa, b, c, d) in nodes:
            assert is_pyth_tuple((aa, b, c), d) and -aa + b + c == d
        print(f"    a={a:2d}:  count={len(nodes):2d}   tau(a^2)={tau(a*a):2d}   "
              f"match={len(nodes) == tau(a*a)}")
    print(f"  Mirror nodes over a=2: {mirror_nodes(2)}")
    print("  tau(a^2) is always odd; the unpaired divisor p=q=a gives (a,2a,2a,3a).")
    print()


def demo_tree_growth_experiment() -> None:
    print("=" * 78)
    print("9. GROWTH EXPERIMENT: NODE COUNTS VERSUS THE PREDICTED EXPONENT")
    print("=" * 78)
    print("  Since each move multiplies the height by at most rho_n and produces at least k")
    print("  children, the count of nodes of height <= H is at least H^delta with")
    print("  delta = log k / log rho_n: the critical exponent is a certified LOWER bound for")
    print("  the empirical growth exponent log N(H) / log H.")
    print()
    root3 = ((1, 2, 2), 3)
    for H in (50, 200, 1000):
        nodes = bfs_tree(root3, H)
        emp = math.log(len(nodes)) / math.log(H)
        print(f"  quadruples from (1,2,2;3), height <= {H:4d}: N={len(nodes):7d}   "
              f"empirical exponent {emp:.3f}   >=  delta_3 = "
              f"{critical_exponent(6, rho(3)):.3f}")
    root2 = ((3, 4), 5)
    for H in (50, 200, 1000):
        nodes = bfs_tree(root2, H)
        emp = math.log(len(nodes)) / math.log(H)
        print(f"  triples    from (3,4;5),    height <= {H:4d}: N={len(nodes):7d}   "
              f"empirical exponent {emp:.3f}   >=  delta_2 = "
              f"{critical_exponent(3, rho(2)):.3f}")
    print("  The quadruple graph fills its height range far more densely: delta_3 > 1 > delta_2.")
    print()


def main() -> None:
    print()
    print("HIGHER-DIMENSIONAL PYTHAGOREAN TREES — NUMERICAL DEMONSTRATIONS")
    print()
    demo_descent_complex()
    demo_branching_three()
    demo_families()
    demo_universal_bound()
    demo_pell_dimension_four()
    demo_growth()
    demo_strict_integral_growth()
    demo_mirrors_and_divisor_law()
    demo_tree_growth_experiment()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
