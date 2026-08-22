"""
Berggren-generated Pythagorean triples in a box: numerical demonstrations.

This self-contained script illustrates, with explicit computation, the results of
the accompanying paper:

  * The three Berggren matrices B1, B2, B3 acting on the seed (3,4,5) generate a
    ternary tree whose nodes are *exactly* the positive primitive Pythagorean
    triples (a,b,c) whose first leg a is odd.

  * Writing  bergBox(H) = { (a,b,c) in the tree : a,b,c <= H }, we have

        H / 100  <=  #bergBox(H)  <=  min( 4H, (floor(sqrt(H)) + 1)^2 )     (H >= 5)

    so #bergBox(H) = Theta(H); in particular #bergBox(H)/H^3 -> 0, i.e. tree
    triples are a vanishing fraction of the H^3 integer triples of the box.

  * #ppBox(H) = 2 * #bergBox(H), where ppBox(H) is the set of *all* ordered
    primitive Pythagorean triples in the box.  Hence the tree captures every
    primitive triple of the box up to swapping the two legs: the advertised
    proportion "1 - o(1)" is in fact exactly 1.

  * #bergBox(H) = #pairBox(H), the number of coprime, opposite-parity lattice
    points (n,m) with 0 < n < m and m^2 + n^2 <= H (a "visible point" count in a
    quarter disc).  Experimentally #bergBox(H)/H -> 1/(2*pi) = 0.159154...

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from math import gcd, isqrt, pi
from typing import Dict, Iterator, List, Tuple

Triple = Tuple[int, int, int]

# --------------------------------------------------------------------------- #
# 1. The three Berggren matrices
# --------------------------------------------------------------------------- #

B1: Tuple[Tuple[int, ...], ...] = ((1, -2, 2), (2, -1, 2), (2, -2, 3))
B2: Tuple[Tuple[int, ...], ...] = ((1, 2, 2), (2, 1, 2), (2, 2, 3))
B3: Tuple[Tuple[int, ...], ...] = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))

SEED: Triple = (3, 4, 5)


def apply_matrix(matrix: Tuple[Tuple[int, ...], ...], t: Triple) -> Triple:
    """Apply a 3x3 integer matrix to a triple, returning the image triple."""
    a, b, c = t
    return tuple(row[0] * a + row[1] * b + row[2] * c for row in matrix)  # type: ignore[return-value]


def children(t: Triple) -> List[Triple]:
    """The three Berggren children of a triple."""
    return [apply_matrix(B1, t), apply_matrix(B2, t), apply_matrix(B3, t)]


# --------------------------------------------------------------------------- #
# 2. Enumerating the tree inside a box
# --------------------------------------------------------------------------- #

def berg_box(H: int) -> List[Triple]:
    """All Berggren-generated triples (a,b,c) with 0 < a,b,c <= H.

    Because c > a and c > b for a Pythagorean triple, the box condition is just
    c <= H; and every Berggren step strictly increases c, so a depth-first search
    pruned at c > H is complete.
    """
    out: List[Triple] = []
    stack: List[Triple] = [SEED]
    while stack:
        t = stack.pop()
        if t[2] > H:
            continue
        out.append(t)
        stack.extend(children(t))
    return sorted(out)


def pp_box(H: int) -> List[Triple]:
    """All ordered primitive Pythagorean triples (a,b,c) with 0 < a,b,c <= H."""
    out: List[Triple] = []
    for c in range(1, H + 1):
        for a in range(1, c):
            b2 = c * c - a * a
            b = isqrt(b2)
            if b * b == b2 and 0 < b <= H and gcd(a, b) == 1:
                out.append((a, b, c))
    return sorted(out)


def pair_box(H: int) -> List[Tuple[int, int]]:
    """Coprime opposite-parity pairs (n,m), 0 < n < m, with m^2 + n^2 <= H."""
    out: List[Tuple[int, int]] = []
    mmax = isqrt(H)
    for m in range(2, mmax + 1):
        for n in range(1, m):
            if m * m + n * n <= H and gcd(n, m) == 1 and (n + m) % 2 == 1:
                out.append((n, m))
    return sorted(out)


def euclid(n: int, m: int) -> Triple:
    """Euclid's parametrisation: (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


# --------------------------------------------------------------------------- #
# 3. Demonstrations
# --------------------------------------------------------------------------- #

def show_tree(depth: int = 3) -> None:
    print("=" * 74)
    print("1.  The Berggren ternary tree rooted at (3,4,5)")
    print("=" * 74)
    level: List[Triple] = [SEED]
    for d in range(depth + 1):
        print(f"  depth {d}: " + ", ".join(str(t) for t in level[:9])
              + ("  ..." if len(level) > 9 else ""))
        nxt: List[Triple] = []
        for t in level:
            nxt.extend(children(t))
        level = nxt
    print()
    # every node is a primitive triple with odd first leg
    ok = all(
        a * a + b * b == c * c and gcd(a, b) == 1 and a % 2 == 1
        for a, b, c in berg_box(2000)
    )
    print(f"  every node with c <= 2000 is primitive Pythagorean with odd leg a: {ok}")
    print()


def show_counts(bounds: Tuple[int, ...] = (5, 10, 50, 100, 500, 1000, 5000, 20000)) -> None:
    print("=" * 74)
    print("2.  Counting: Theta(H) bounds, the factor 2, and the lattice bijection")
    print("=" * 74)
    header = (f"{'H':>7} {'#berg':>7} {'H/100':>7} {'4H':>8} {'(sqrt+1)^2':>11} "
              f"{'#pp':>7} {'#pair':>7} {'#berg/H':>9} {'#berg/H^3':>11}")
    print(header)
    print("-" * len(header))
    for H in bounds:
        bb = berg_box(H)
        pb = pair_box(H)
        pp = pp_box(H) if H <= 5000 else None
        lo = H / 100.0
        hi1 = 4 * H
        hi2 = (isqrt(H) + 1) ** 2
        assert H <= 100 * len(bb), "lower bound violated"
        assert len(bb) <= min(hi1, hi2), "upper bound violated"
        assert len(bb) == len(pb), "lattice bijection violated"
        if pp is not None:
            assert len(pp) == 2 * len(bb), "factor-two identity violated"
        print(f"{H:>7} {len(bb):>7} {lo:>7.1f} {hi1:>8} {hi2:>11} "
              f"{(len(pp) if pp is not None else -1):>7} {len(pb):>7} "
              f"{len(bb)/H:>9.5f} {len(bb)/H**3:>11.3e}")
    print()
    print(f"  conjectured limit of #berg/H :  1/(2*pi) = {1/(2*pi):.6f}")
    print()


def show_bijection(H: int = 200) -> None:
    print("=" * 74)
    print("3.  The bijection (n,m) -> (m^2-n^2, 2mn, m^2+n^2) with H =", H)
    print("=" * 74)
    pairs = pair_box(H)
    triples = set(berg_box(H))
    images = {euclid(n, m) for (n, m) in pairs}
    print(f"  #pairs = {len(pairs)},  #tree triples = {len(triples)},  "
          f"images = tree: {images == triples}")
    for (n, m) in pairs[:8]:
        print(f"    (n,m) = ({n},{m})  ->  {euclid(n, m)}")
    print()


def show_swap(H: int = 300) -> None:
    print("=" * 74)
    print("4.  Every primitive triple of the box is in the tree up to a leg swap")
    print("=" * 74)
    tree = set(berg_box(H))
    bad = [t for t in pp_box(H) if t not in tree and (t[1], t[0], t[2]) not in tree]
    print(f"  H = {H}:  #pp = {len(pp_box(H))},  #tree = {len(tree)},  "
          f"exceptions = {len(bad)}")
    odd_first = [t for t in pp_box(H) if t[0] % 2 == 1]
    print(f"  primitive triples with odd first leg = {len(odd_first)} "
          f"= #tree ({len(tree)}): {len(odd_first) == len(tree)}")
    print()


def show_depth_profile(H: int = 100000) -> None:
    print("=" * 74)
    print("5.  Depth profile: parabolic spine (quadratic) vs hyperbolic branch")
    print("=" * 74)
    # the B3-spine
    t: Triple = SEED
    spine: List[Triple] = [t]
    for _ in range(6):
        t = apply_matrix(B3, t)
        spine.append(t)
    print("  B3-spine from (3,4,5):")
    for k, s in enumerate(spine):
        print(f"    depth {k}: {s}   predicted c = 4(k+1)^2+1 = {4*(k+1)**2+1}")
    # the B2 branch
    t = SEED
    branch: List[Triple] = [t]
    for _ in range(6):
        t = apply_matrix(B2, t)
        branch.append(t)
    print("  B2-branch from (3,4,5): hypotenuses",
          [s[2] for s in branch], " (ratios ->", f"{3+2*math.sqrt(2):.4f})")
    # depth statistics inside the box
    depths: Dict[int, int] = {}
    stack: List[Tuple[Triple, int]] = [(SEED, 0)]
    maxdepth = 0
    total = 0
    weighted = 0
    while stack:
        u, d = stack.pop()
        if u[2] > H:
            continue
        depths[d] = depths.get(d, 0) + 1
        maxdepth = max(maxdepth, d)
        total += 1
        weighted += d
        for v in children(u):
            stack.append((v, d + 1))
    print(f"  H = {H}: nodes = {total}, max depth D(H) = {maxdepth} "
          f"(sqrt(H)/2 = {isqrt(H)/2:.1f}), mean depth = {weighted/total:.2f} "
          f"(log H = {math.log(H):.2f})")
    print()


def show_density_constant(H: int = 400000) -> None:
    print("=" * 74)
    print("6.  Towards the Lehmer-type constant  #bergBox(H)/H -> 1/(2*pi)")
    print("=" * 74)
    print(f"{'H':>8} {'#berg':>8} {'#berg/H':>10} {'1/(2pi)':>10} {'error*sqrt(H)':>15}")
    Hs = [H // 32, H // 16, H // 8, H // 4, H // 2, H]
    for h in Hs:
        c = len(pair_box(h))          # equal to #bergBox(h), by the bijection
        err = c / h - 1 / (2 * pi)
        print(f"{h:>8} {c:>8} {c/h:>10.6f} {1/(2*pi):>10.6f} "
              f"{err*math.sqrt(h):>15.4f}")
    print()


def main() -> None:
    show_tree()
    show_counts()
    show_bijection()
    show_swap()
    show_depth_profile()
    show_density_constant()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
