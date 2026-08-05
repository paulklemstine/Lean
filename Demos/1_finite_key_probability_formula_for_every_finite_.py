"""
Numerical demonstration of the uniform threshold coupling on a finite site set.
==============================================================================

Setting
-------
Let ``iota`` be a finite set of *sites*.  Attach to each site v an independent
random *key* x_v drawn uniformly from [0, 1].  For a threshold p in [0, 1]
define the configuration

    Theta_p(x)_v = 1  (open)   if  x_v <= p,
    Theta_p(x)_v = 0  (closed) if  x_v >  p.

This single random key realises the Bernoulli product measure of *every*
density p at once, and raising p only ever opens sites.

Results demonstrated here
-------------------------
1.  Finite-key probability formula
        P(Theta_p(x) = eta) = p^|open(eta)| * (1-p)^|closed(eta)| .
2.  Bernoulli realisation:  P(Theta_p(x) in A) = pi_A(p), the Bernoulli
    polynomial of the event A.
3.  Pointwise monotonicity of the coupling and monotonicity of pi_A for
    increasing events A.
4.  Strict monotonicity on (0,1) for nondegenerate increasing events, together
    with the explicit separating-box lower bound on the increment.
5.  The finite Russo formula   pi_A'(p) = sum over sites v of pi_{Piv_v(A)}(p),
    checked against exact symbolic differentiation.
6.  The Harris/FKG inequality  pi_A(p) * pi_B(p) <= pi_{A and B}(p), together
    with the exact log-modularity identity of the Bernoulli weight and the
    product form of the square-root trick.
7.  Grid crossing probabilities theta_n(p): exact polynomials, exact values and
    derivatives at p = 1/2, and the half-probability densities p_n.
8.  The bond analogue: connectivity probabilities on a finite graph.

All exact arithmetic is done with ``fractions.Fraction``, so every printed
rational number is exact.  Monte-Carlo checks use only ``random``.

Run with:  python3 demo.py
"""

from __future__ import annotations

import random
from fractions import Fraction
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

Site = Tuple[int, int]
Config = Tuple[bool, ...]
Poly = List[Fraction]  # coefficient list, index = power of p


# ---------------------------------------------------------------------------
# Exact polynomial arithmetic in the density p
# ---------------------------------------------------------------------------


def poly_add(a: Poly, b: Poly) -> Poly:
    """Sum of two polynomials given as coefficient lists."""
    n = max(len(a), len(b))
    out = [Fraction(0)] * n
    for i, c in enumerate(a):
        out[i] += c
    for i, c in enumerate(b):
        out[i] += c
    return out


def poly_mul(a: Poly, b: Poly) -> Poly:
    """Product of two polynomials given as coefficient lists."""
    out = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, ca in enumerate(a):
        if ca:
            for j, cb in enumerate(b):
                out[i + j] += ca * cb
    return out


def poly_eval(a: Poly, x: Fraction) -> Fraction:
    """Horner evaluation of a polynomial at an exact rational point."""
    acc = Fraction(0)
    for c in reversed(a):
        acc = acc * x + c
    return acc


def poly_diff(a: Poly) -> Poly:
    """Formal derivative of a polynomial."""
    return [Fraction(i) * c for i, c in enumerate(a)][1:] or [Fraction(0)]


def poly_str(a: Poly, var: str = "p") -> str:
    """Human-readable rendering of a polynomial."""
    terms: List[str] = []
    for i, c in enumerate(a):
        if c == 0:
            continue
        if i == 0:
            terms.append(f"{c}")
        elif i == 1:
            terms.append(f"{c}*{var}")
        else:
            terms.append(f"{c}*{var}^{i}")
    return " + ".join(terms).replace("+ -", "- ") if terms else "0"


# ---------------------------------------------------------------------------
# Bernoulli weights and Bernoulli polynomials of events
# ---------------------------------------------------------------------------


def weight_poly(eta: Config) -> Poly:
    """The Bernoulli weight p^|open| (1-p)^|closed| as an exact polynomial."""
    k = sum(1 for b in eta if b)
    m = len(eta) - k
    out: Poly = [Fraction(1)]
    for _ in range(k):
        out = poly_mul(out, [Fraction(0), Fraction(1)])          # multiply by p
    for _ in range(m):
        out = poly_mul(out, [Fraction(1), Fraction(-1)])         # multiply by 1-p
    return out


def weight_at(eta: Config, p: Fraction) -> Fraction:
    """The Bernoulli weight evaluated at a rational density."""
    k = sum(1 for b in eta if b)
    return p ** k * (1 - p) ** (len(eta) - k)


def all_configs(n_sites: int) -> Iterable[Config]:
    """Enumerate all 2^n_sites configurations."""
    return product((False, True), repeat=n_sites)


def bern_poly(n_sites: int, member: Callable[[Config], bool]) -> Poly:
    """The Bernoulli polynomial pi_A(p) of the event A = {eta : member(eta)}."""
    acc: Poly = [Fraction(0)]
    for eta in all_configs(n_sites):
        if member(eta):
            acc = poly_add(acc, weight_poly(eta))
    return acc


# ---------------------------------------------------------------------------
# The grid, its crossing event, and connectivity
# ---------------------------------------------------------------------------


def grid_sites(n: int) -> List[Site]:
    """The sites of the n x n grid, ordered row by row."""
    return [(i, j) for i in range(n) for j in range(n)]


def grid_neighbours(n: int, s: Site) -> List[Site]:
    """The lattice neighbours of a site inside the n x n grid."""
    i, j = s
    out = []
    for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        a, b = i + di, j + dj
        if 0 <= a < n and 0 <= b < n:
            out.append((a, b))
    return out


def has_crossing(n: int, eta: Config) -> bool:
    """True iff open sites contain a path from row 0 to row n-1."""
    sites = grid_sites(n)
    index = {s: k for k, s in enumerate(sites)}
    stack = [s for s in sites if s[0] == 0 and eta[index[s]]]
    seen = set(stack)
    while stack:
        s = stack.pop()
        if s[0] == n - 1:
            return True
        for t in grid_neighbours(n, s):
            if eta[index[t]] and t not in seen:
                seen.add(t)
                stack.append(t)
    return False


def crossing_poly(n: int) -> Poly:
    """The exact crossing polynomial theta_n(p) of the n x n grid."""
    return bern_poly(n * n, lambda eta: has_crossing(n, eta))


# ---------------------------------------------------------------------------
# Pivotality and the finite Russo formula
# ---------------------------------------------------------------------------


def flip(eta: Config, v: int, b: bool) -> Config:
    """The configuration eta with site v forced to state b."""
    lst = list(eta)
    lst[v] = b
    return tuple(lst)


def is_pivotal(member: Callable[[Config], bool], eta: Config, v: int) -> bool:
    """True iff opening v realises the event and closing v destroys it."""
    return member(flip(eta, v, True)) and not member(flip(eta, v, False))


def russo_derivative(n_sites: int, member: Callable[[Config], bool]) -> Poly:
    """Sum over sites of the Bernoulli polynomial of the pivotal set."""
    acc: Poly = [Fraction(0)]
    for v in range(n_sites):
        acc = poly_add(acc, bern_poly(n_sites, lambda eta, v=v: is_pivotal(member, eta, v)))
    return acc


# ---------------------------------------------------------------------------
# Lattice operations on configurations (for log-modularity / Harris)
# ---------------------------------------------------------------------------


def meet(eta: Config, xi: Config) -> Config:
    """Coordinatewise minimum: open only where both are open."""
    return tuple(a and b for a, b in zip(eta, xi))


def join(eta: Config, xi: Config) -> Config:
    """Coordinatewise maximum: open where either is open."""
    return tuple(a or b for a, b in zip(eta, xi))


# ---------------------------------------------------------------------------
# The threshold coupling itself
# ---------------------------------------------------------------------------


def threshold_config(keys: Sequence[float], p: float) -> Tuple[bool, ...]:
    """Theta_p(x): a site is open exactly when its key is at most p."""
    return tuple(x <= p for x in keys)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_fibre_formula(seed: int = 20260805) -> None:
    """Result 1: Monte-Carlo check of P(Theta_p = eta) = p^k (1-p)^(N-k)."""
    print("=" * 78)
    print("1.  FINITE-KEY PROBABILITY FORMULA")
    print("=" * 78)
    rng = random.Random(seed)
    n_sites, p, trials = 4, 0.37, 400_000
    counts: Dict[Tuple[bool, ...], int] = {}
    for _ in range(trials):
        keys = [rng.random() for _ in range(n_sites)]
        eta = threshold_config(keys, p)
        counts[eta] = counts.get(eta, 0) + 1
    print(f"  sites = {n_sites},  p = {p},  trials = {trials:,}")
    print("  configuration        empirical      p^k (1-p)^(N-k)     |error|")
    worst = 0.0
    for eta in all_configs(n_sites):
        emp = counts.get(eta, 0) / trials
        k = sum(1 for b in eta if b)
        exact = p ** k * (1 - p) ** (n_sites - k)
        worst = max(worst, abs(emp - exact))
        tag = "".join("O" if b else "." for b in eta)
        print(f"    {tag:<16}  {emp:10.6f}      {exact:12.6f}    {abs(emp-exact):9.6f}")
    print(f"  worst absolute error over all 2^{n_sites} configurations: {worst:.6f}")
    print()


def demo_monotone_coupling(seed: int = 7) -> None:
    """Result 3: one key, many densities, nested open sets."""
    print("=" * 78)
    print("2.  POINTWISE MONOTONICITY OF THE COUPLING (ONE KEY, MANY DENSITIES)")
    print("=" * 78)
    rng = random.Random(seed)
    n = 3
    sites = grid_sites(n)
    keys = [rng.random() for _ in sites]
    print("  keys on the 3x3 grid (one draw, used for every density):")
    for i in range(n):
        print("    " + "  ".join(f"{keys[i*n+j]:.3f}" for j in range(n)))
    print()
    prev: FrozenSet[int] = frozenset()
    for p in (0.0, 0.2, 0.4, 0.6, 0.8, 1.0):
        eta = threshold_config(keys, p)
        opens = frozenset(k for k, b in enumerate(eta) if b)
        assert prev <= opens, "open sets must be nested"
        prev = opens
        rows = ["".join("O" if eta[i * n + j] else "." for j in range(n)) for i in range(n)]
        cross = "crossing" if has_crossing(n, eta) else "no crossing"
        print(f"    p = {p:.1f}   {rows[0]} | {rows[1]} | {rows[2]}   ->  {cross}")
    print("  open sets are nested for every key: raising p never closes a site.")
    print()


def demo_crossing_polynomials(max_n: int = 3) -> None:
    """Results 2, 4, 7: exact crossing polynomials and strict monotonicity."""
    print("=" * 78)
    print("3.  EXACT CROSSING POLYNOMIALS OF THE n x n GRID")
    print("=" * 78)
    half = Fraction(1, 2)
    for n in range(1, max_n + 1):
        theta = crossing_poly(n)
        dtheta = poly_diff(theta)
        val = poly_eval(theta, half)
        der = poly_eval(dtheta, half)
        print(f"  n = {n}:  theta_{n}(p) = {poly_str(theta)}")
        print(f"           theta_{n}(1/2)  = {val}  = {float(val):.6f}")
        print(f"           theta_{n}'(1/2) = {der}  = {float(der):.6f}")
        # strict monotonicity on a grid of densities
        pts = [Fraction(k, 12) for k in range(1, 12)]
        vals = [poly_eval(theta, p) for p in pts]
        strict = all(a < b for a, b in zip(vals, vals[1:]))
        print(f"           strictly increasing at 11 sample densities in (0,1): {strict}")
        # unique half-probability density
        lo, hi = 0.0, 1.0
        f = lambda x: sum(float(c) * x ** i for i, c in enumerate(theta)) - 0.5
        for _ in range(200):
            mid = (lo + hi) / 2
            if f(mid) < 0:
                lo = mid
            else:
                hi = mid
        print(f"           unique p_n with theta_{n}(p_n) = 1/2 :  {lo:.6f}")
        print()


def demo_russo(max_n: int = 3) -> None:
    """Result 5: Russo's formula checked against exact differentiation."""
    print("=" * 78)
    print("4.  THE FINITE RUSSO FORMULA")
    print("=" * 78)
    print("     theta_n'(p)  =  sum over sites v of  P_p(v is pivotal for a crossing)")
    for n in range(1, max_n + 1):
        theta = crossing_poly(n)
        analytic = poly_diff(theta)
        census = russo_derivative(n * n, lambda eta, n=n: has_crossing(n, eta))
        # normalise lengths before comparing
        L = max(len(analytic), len(census))
        analytic += [Fraction(0)] * (L - len(analytic))
        census += [Fraction(0)] * (L - len(census))
        agree = analytic == census
        print(f"  n = {n}:  derivative of the polynomial  ==  pivotal census :  {agree}")
        print(f"           common value at p = 1/2 : {poly_eval(census, Fraction(1,2))}")
    print("  Every pivotal probability is >= 0, which re-proves monotonicity;")
    print("  and it is > 0 on (0,1), which re-proves strict monotonicity.")
    print()


def demo_harris(n: int = 3) -> None:
    """Result 6: log-modularity, Harris positive correlation, square-root trick."""
    print("=" * 78)
    print("5.  LOG-MODULARITY AND THE HARRIS / FKG INEQUALITY")
    print("=" * 78)
    n_sites = n * n
    half = Fraction(1, 2)

    # (a) exact log-modularity of the Bernoulli weight
    worst = Fraction(0)
    tested = 0
    rng = random.Random(11)
    for _ in range(2000):
        eta = tuple(rng.random() < 0.5 for _ in range(n_sites))
        xi = tuple(rng.random() < 0.5 for _ in range(n_sites))
        lhs = weight_at(eta, half) * weight_at(xi, half)
        rhs = weight_at(meet(eta, xi), half) * weight_at(join(eta, xi), half)
        worst = max(worst, abs(lhs - rhs))
        tested += 1
    print(f"  (a) w_p(eta) w_p(xi) = w_p(eta and xi) w_p(eta or xi)")
    print(f"      largest discrepancy over {tested} random pairs at p = 1/2 : {worst}")

    # (b) Harris for the crossing event and the event "a given site is open"
    cross = lambda eta: has_crossing(n, eta)
    centre = (n // 2) * n + (n // 2)
    openv = lambda eta: eta[centre]
    pi_A = crossing_poly(n)
    pi_B = bern_poly(n_sites, openv)
    pi_AB = bern_poly(n_sites, lambda eta: cross(eta) and openv(eta))
    print("  (b) Harris:  pi_A(p) * pi_B(p) <= pi_{A and B}(p)")
    print("      A = 'horizontal crossing',  B = 'the centre site is open'")
    print("        p      pi_A       pi_B     product   pi_{A and B}   slack")
    for k in range(1, 10):
        p = Fraction(k, 10)
        a, b, ab = poly_eval(pi_A, p), poly_eval(pi_B, p), poly_eval(pi_AB, p)
        slack = ab - a * b
        assert slack >= 0
        print(f"      {float(p):5.2f} {float(a):9.5f} {float(b):9.5f} "
              f"{float(a*b):9.5f} {float(ab):12.5f} {float(slack):9.5f}")
    print("      pi_B(p) = p exactly:",
          poly_str(pi_B), " (matches the theory)")
    print("      Conditioned on a crossing, the centre site is open with")
    print("      probability at least p -- crossings and open sites help each other.")

    # (c) square-root trick, product form
    print("  (c) Square-root trick:  prod_k (1 - pi_{A_k}) <= 1 - pi_{union}")
    events = [
        ("centre open", lambda eta: eta[centre]),
        ("corner open", lambda eta: eta[0]),
        ("crossing", cross),
    ]
    for k in range(1, 10, 2):
        p = Fraction(k, 10)
        prod = Fraction(1)
        for _, mem in events:
            prod *= 1 - poly_eval(bern_poly(n_sites, mem), p)
        uni = poly_eval(
            bern_poly(n_sites, lambda eta: any(mem(eta) for _, mem in events)), p)
        assert prod <= 1 - uni + Fraction(0)
        print(f"      p = {float(p):.1f}:  prod = {float(prod):.6f}  <=  "
              f"1 - pi_union = {float(1-uni):.6f}")
    print()


def demo_bond(seed: int = 3) -> None:
    """Result 8: the bond analogue on a small graph."""
    print("=" * 78)
    print("6.  THE BOND ANALOGUE: CONNECTIVITY ON A FINITE GRAPH")
    print("=" * 78)
    # the 3-cycle with a pendant vertex:  0-1, 1-2, 2-0, 2-3
    edges = [(0, 1), (1, 2), (2, 0), (2, 3)]
    n_edges = len(edges)

    def connected(omega: Config, u: int, v: int) -> bool:
        """u and v joined by open edges."""
        seen, stack = {u}, [u]
        while stack:
            a = stack.pop()
            if a == v:
                return True
            for k, (s, t) in enumerate(edges):
                if not omega[k]:
                    continue
                for x, y in ((s, t), (t, s)):
                    if x == a and y not in seen:
                        seen.add(y)
                        stack.append(y)
        return v in seen

    pi03 = bern_poly(n_edges, lambda om: connected(om, 0, 3))
    print("  graph: edges 0-1, 1-2, 2-0, 2-3")
    print(f"  P_p(0 <-> 3) = {poly_str(pi03)}")
    vals = [poly_eval(pi03, Fraction(k, 10)) for k in range(11)]
    print("  values at p = 0.0 .. 1.0 :",
          "  ".join(f"{float(v):.4f}" for v in vals))
    print("  nondecreasing:", all(a <= b for a, b in zip(vals, vals[1:])))
    print("  strictly increasing on (0,1):",
          all(a < b for a, b in zip(vals[1:-1], vals[2:-1])))
    census = russo_derivative(n_edges, lambda om: connected(om, 0, 3))
    analytic = poly_diff(pi03)
    L = max(len(analytic), len(census))
    analytic += [Fraction(0)] * (L - len(analytic))
    census += [Fraction(0)] * (L - len(census))
    print("  Russo's formula holds for edges too:", analytic == census)
    print(f"  expected number of pivotal edges at p = 1/2 : "
          f"{poly_eval(census, Fraction(1,2))}")
    print()


def demo_strict_box(seed: int = 99) -> None:
    """Result 4: the explicit separating box behind strict monotonicity."""
    print("=" * 78)
    print("7.  THE SEPARATING BOX BEHIND STRICT MONOTONICITY")
    print("=" * 78)
    n = 2
    n_sites = n * n
    p, q = Fraction(2, 5), Fraction(3, 5)
    theta = crossing_poly(n)
    inc = poly_eval(theta, q) - poly_eval(theta, p)

    # a minimal crossing configuration of the 2x2 grid: one full column open
    eta = (True, False, True, False)  # sites (0,0),(0,1),(1,0),(1,1)
    assert has_crossing(n, eta)
    v = 2                              # closing site (1,0) breaks the crossing
    assert not has_crossing(n, flip(eta, v, False))
    a = sum(1 for k, b in enumerate(eta) if b and k != v)
    b_ = sum(1 for b in eta if not b)
    box = (q - p) * p ** a * (1 - q) ** b_
    print(f"  grid 2x2,  p = {p},  q = {q}")
    print(f"  minimal crossing configuration: {''.join('O' if x else '.' for x in eta)}")
    print(f"  pivotal site index {v}: closing it destroys the crossing")
    print(f"  separating box volume  (q-p) p^{a} (1-q)^{b_}  =  {box} = {float(box):.6f}")
    print(f"  actual increment theta_2(q) - theta_2(p)       =  {inc} = {float(inc):.6f}")
    print(f"  box volume is a valid lower bound: {box <= inc}")

    # Monte-Carlo confirmation that the box has the claimed effect
    rng = random.Random(seed)
    hits = both = neither = 0
    trials = 200_000
    for _ in range(trials):
        keys = [rng.random() for _ in range(n_sites)]
        lo = has_crossing(n, threshold_config(keys, float(p)))
        hi = has_crossing(n, threshold_config(keys, float(q)))
        assert not (lo and not hi), "coupling monotonicity violated"
        if hi and not lo:
            hits += 1
        elif hi and lo:
            both += 1
        else:
            neither += 1
    print(f"  Monte-Carlo over {trials:,} keys:")
    print(f"    crossing at both p and q : {both/trials:.5f}")
    print(f"    crossing at q only       : {hits/trials:.5f}   "
          f"(exact value {float(inc):.5f})")
    print(f"    crossing at neither      : {neither/trials:.5f}")
    print("    crossing at p only       : 0.00000   (impossible by the coupling)")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE UNIFORM THRESHOLD COUPLING ON A FINITE SITE SET")
    print("#  Bernoulli realisation, monotonicity, Russo's formula, Harris")
    print("#" * 78)
    print()
    demo_fibre_formula()
    demo_monotone_coupling()
    demo_crossing_polynomials(max_n=3)
    demo_russo(max_n=3)
    demo_harris(n=3)
    demo_bond()
    demo_strict_box()
    print("=" * 78)
    print("All demonstrations completed; every assertion above held.")
    print("=" * 78)


if __name__ == "__main__":
    main()
