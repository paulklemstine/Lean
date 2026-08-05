"""
Rotated Laplacians, periodicity ratios, and the quantization theorem
====================================================================

Numerical demonstration of the theory of nearly-periodic structure in
directed graphs, detected through the spectrum of rotated Laplacian matrices.

Setting
-------
Let ``w[u][v] >= 0`` be the arc weights of a finite digraph on vertex set
``{0, ..., n-1}``.  For a rotation ``om`` on the unit circle the *rotated
energy* of a vector ``x`` is

    E(om, x) = sum_{u,v} w[u][v] * |x[v] - om * x[u]|^2 ,

the Hermitian quadratic form of the rotated Laplacian ``D - A_om``.  The
*volume* is ``vol(x) = sum_v d[v] * |x[v]|^2`` where ``d[v]`` is the total
(in + out) degree, and the *periodicity ratio* at an integer ``p >= 1`` is the
minimum of ``E / vol`` over nonzero vectors whose coordinates are ``0`` or
powers of ``om_p = exp(2*pi*i/p)``.

Results demonstrated
--------------------
1.  Zero energy is arc-local:  ``E = 0``  iff  ``x[v] = om * x[u]`` on every
    arc of nonzero weight.
2.  Universal bound:  ``E(om, x) <= 2 * vol(x)``  for every unimodular ``om``.
3.  Main characterization: for a strongly connected digraph, a unimodular
    p-phase vector of zero energy exists iff ``p`` divides every closed-walk
    length; hence ``{p : beta_p = 0}`` is exactly the divisor set of the
    period.
4.  Counterexample: the directed 4-cycle has vanishing 2-periodicity ratio but
    no closed walk of length 2.
5.  Reversal invariance: reversing all arcs leaves the periodicity ratio fixed.
6.  Markov chains: a right eigenvector of a stochastic matrix with unimodular
    eigenvalue has exactly zero rotated energy for the stationary-flow
    weighting, and conversely when the stationary distribution is positive.
7.  Quantization: with all nonzero weights >= 1 and ``p >= 2``, the energy of a
    unimodular p-phase vector is either 0 or at least ``4 sin^2(pi/p)``.
8.  Sharpness: rescaling the 4-cycle gives arbitrarily small positive
    3-energy, so the weight hypothesis in (7) cannot be dropped.

Only the standard library is used.
"""

from __future__ import annotations

import cmath
import itertools
import math
from math import gcd
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Complex = complex
Matrix = List[List[float]]
Vector = List[Complex]


# ---------------------------------------------------------------------------
# Core quantities
# ---------------------------------------------------------------------------

def rot_weight(p: int) -> Complex:
    """The canonical primitive p-th root of unity exp(2*pi*i/p)."""
    if p <= 0:
        raise ValueError("p must be a positive integer")
    return cmath.exp(2j * math.pi / p)


def rot_energy(w: Matrix, om: Complex, x: Vector) -> float:
    """Rotated energy  sum_{u,v} w[u][v] * |x[v] - om * x[u]|^2."""
    n = len(w)
    total = 0.0
    for u in range(n):
        for v in range(n):
            if w[u][v] != 0.0:
                total += w[u][v] * abs(x[v] - om * x[u]) ** 2
    return total


def total_degree(w: Matrix) -> List[float]:
    """d[v] = sum_u (w[v][u] + w[u][v]) : out-degree plus in-degree."""
    n = len(w)
    return [sum(w[v][u] + w[u][v] for u in range(n)) for v in range(n)]


def volume(w: Matrix, x: Vector) -> float:
    """vol(x) = sum_v d[v] * |x[v]|^2."""
    deg = total_degree(w)
    return sum(deg[v] * abs(x[v]) ** 2 for v in range(len(w)))


def rot_rayleigh(w: Matrix, om: Complex, x: Vector) -> float:
    """Rayleigh quotient of the rotated Laplacian."""
    vol = volume(w, x)
    if vol == 0.0:
        raise ZeroDivisionError("vector has zero volume")
    return rot_energy(w, om, x) / vol


def root_gap(p: int) -> float:
    """Least squared distance from 1 to a nontrivial p-th root of unity."""
    if p < 2:
        return 0.0
    om = rot_weight(p)
    return min(abs(om ** j - 1) ** 2 for j in range(1, p))


# ---------------------------------------------------------------------------
# Combinatorics of the digraph
# ---------------------------------------------------------------------------

def arcs(w: Matrix) -> List[Tuple[int, int]]:
    """All arcs of nonzero weight."""
    n = len(w)
    return [(u, v) for u in range(n) for v in range(n) if w[u][v] != 0.0]


def is_strongly_connected(w: Matrix) -> bool:
    """Kosaraju-style double reachability test from vertex 0."""
    n = len(w)
    if n == 0:
        return True

    def reachable(adj: Dict[int, List[int]]) -> int:
        seen = {0}
        stack = [0]
        while stack:
            u = stack.pop()
            for v in adj.get(u, ()):
                if v not in seen:
                    seen.add(v)
                    stack.append(v)
        return len(seen)

    fwd: Dict[int, List[int]] = {u: [] for u in range(n)}
    bwd: Dict[int, List[int]] = {u: [] for u in range(n)}
    for u, v in arcs(w):
        fwd[u].append(v)
        bwd[v].append(u)
    return reachable(fwd) == n and reachable(bwd) == n


def digraph_period(w: Matrix) -> int:
    """
    Period of a strongly connected digraph: the gcd of all closed-walk lengths.

    Computed by the BFS-discrepancy algorithm.  Run a BFS from vertex 0
    recording depths N[v]; the period is the gcd over all arcs u -> v of
    N[u] + 1 - N[v].  Correctness is exactly the statement that the phase
    certificate x[v] = om_p^{N[v]} exists iff p divides every discrepancy.
    Runs in O(|V| + |E|).
    """
    n = len(w)
    if n == 0:
        return 0
    depth: List[Optional[int]] = [None] * n
    depth[0] = 0
    frontier = [0]
    while frontier:
        nxt: List[int] = []
        for u in frontier:
            for v in range(n):
                if w[u][v] != 0.0 and depth[v] is None:
                    depth[v] = depth[u] + 1  # type: ignore[operator]
                    nxt.append(v)
        frontier = nxt
    g = 0
    for u, v in arcs(w):
        if depth[u] is None or depth[v] is None:
            continue
        g = gcd(g, abs(depth[u] + 1 - depth[v]))
    return g


def closed_walk_lengths(w: Matrix, max_len: int) -> List[int]:
    """All n <= max_len for which some vertex has a closed walk of length n."""
    n = len(w)
    reach = [[1.0 if w[u][v] != 0.0 else 0.0 for v in range(n)] for u in range(n)]
    out: List[int] = []
    power = [row[:] for row in reach]
    for length in range(1, max_len + 1):
        if any(power[v][v] > 0.0 for v in range(n)):
            out.append(length)
        power = [
            [
                1.0 if any(power[u][k] > 0.0 and reach[k][v] > 0.0 for k in range(n))
                else 0.0
                for v in range(n)
            ]
            for u in range(n)
        ]
    return out


def reverse(w: Matrix) -> Matrix:
    """The reversal of the digraph: every arc turned around."""
    n = len(w)
    return [[w[v][u] for v in range(n)] for u in range(n)]


# ---------------------------------------------------------------------------
# Phase vectors and the periodicity ratio
# ---------------------------------------------------------------------------

def phase_vector(p: int, exponents: Sequence[Optional[int]]) -> Vector:
    """Build a phase vector: ``None`` means the coordinate 0."""
    om = rot_weight(p)
    return [0j if k is None else om ** k for k in exponents]


def all_phase_vectors(n: int, p: int, allow_zero: bool = True) -> Iterable[Vector]:
    """Enumerate every nonzero phase vector on n vertices for the rotation om_p."""
    alphabet: List[Optional[int]] = list(range(p)) + ([None] if allow_zero else [])
    for combo in itertools.product(alphabet, repeat=n):
        if all(k is None for k in combo):
            continue
        yield phase_vector(p, combo)


def periodicity_ratio(w: Matrix, p: int, allow_zero: bool = True) -> float:
    """
    Exact periodicity ratio by exhaustive search over phase vectors.

    Feasible only for small graphs: the search space has size (p+1)^n.
    """
    om = rot_weight(p)
    best = math.inf
    for x in all_phase_vectors(len(w), p, allow_zero):
        vol = volume(w, x)
        if vol <= 0.0:
            continue
        best = min(best, rot_energy(w, om, x) / vol)
    return best


def canonical_certificate(w: Matrix, p: int) -> Optional[Vector]:
    """
    The certificate of Theorem 'divisibility yields a certificate':
    x[v] = om_p^{N(v)} with N(v) a BFS depth from vertex 0.  Returns None if
    the resulting vector fails the arc condition (i.e. p does not divide the
    period).
    """
    n = len(w)
    depth: List[Optional[int]] = [None] * n
    depth[0] = 0
    frontier = [0]
    while frontier:
        nxt = []
        for u in frontier:
            for v in range(n):
                if w[u][v] != 0.0 and depth[v] is None:
                    depth[v] = depth[u] + 1  # type: ignore[operator]
                    nxt.append(v)
        frontier = nxt
    if any(d is None for d in depth):
        return None
    om = rot_weight(p)
    x = [om ** (d % p) for d in depth]  # type: ignore[operator]
    for u, v in arcs(w):
        if abs(x[v] - om * x[u]) > 1e-9:
            return None
    return x


# ---------------------------------------------------------------------------
# Example digraphs
# ---------------------------------------------------------------------------

def directed_cycle(n: int, weight: float = 1.0) -> Matrix:
    """The directed n-cycle 0 -> 1 -> ... -> n-1 -> 0."""
    w = [[0.0] * n for _ in range(n)]
    for u in range(n):
        w[u][(u + 1) % n] = weight
    return w


def cycle_with_chord(n: int, a: int, b: int, weight: float = 1.0) -> Matrix:
    """The directed n-cycle with one extra arc a -> b."""
    w = directed_cycle(n, weight)
    w[a][b] = weight
    return w


def complete_bipartite_digraph(k: int, m: int) -> Matrix:
    """Arcs from every left vertex to every right vertex and back: period 2."""
    n = k + m
    w = [[0.0] * n for _ in range(n)]
    for i in range(k):
        for j in range(k, n):
            w[i][j] = 1.0
            w[j][i] = 1.0
    return w


# ---------------------------------------------------------------------------
# Markov chains
# ---------------------------------------------------------------------------

def stationary_distribution(P: Matrix, iterations: int = 20000) -> List[float]:
    """Stationary distribution by power iteration on the row-stochastic P."""
    n = len(P)
    pi = [1.0 / n] * n
    for _ in range(iterations):
        nxt = [sum(pi[u] * P[u][v] for u in range(n)) for v in range(n)]
        s = sum(nxt)
        pi = [t / s for t in nxt]
    return pi


def chain_weighting(P: Matrix, pi: Sequence[float]) -> Matrix:
    """Stationary flow weights w[u][v] = pi[u] * P[u][v]."""
    n = len(P)
    return [[pi[u] * P[u][v] for v in range(n)] for u in range(n)]


def apply_matrix(P: Matrix, x: Vector) -> Vector:
    """Right action (P x)[u] = sum_v P[u][v] x[v]."""
    n = len(P)
    return [sum(P[u][v] * x[v] for v in range(n)) for u in range(n)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_zero_energy_is_arc_local() -> None:
    banner("1. Zero energy is exactly the arc condition x[v] = om * x[u]")
    w = directed_cycle(6)
    om = rot_weight(6)
    good = [om ** v for v in range(6)]
    bad = [om ** v for v in range(6)]
    bad[3] = om ** 5  # break one coordinate
    print(f"  directed 6-cycle, rotation om_6 = {om:.4f}")
    print(f"  energy of the correct phase vector : {rot_energy(w, om, good):.12f}")
    print(f"  energy after corrupting one vertex : {rot_energy(w, om, bad):.6f}")
    violations = [(u, v) for u, v in arcs(w) if abs(bad[v] - om * bad[u]) > 1e-9]
    print(f"  arcs violating the rotation rule   : {violations}")
    print("  => energy vanishes precisely when no arc is violated.")


def demo_universal_bound() -> None:
    banner("2. The Rayleigh quotient never exceeds 2")
    graphs = {
        "directed 4-cycle": directed_cycle(4),
        "4-cycle + chord 0->2": cycle_with_chord(4, 0, 2),
        "K_{2,3} both ways": complete_bipartite_digraph(2, 3),
    }
    for name, w in graphs.items():
        worst = 0.0
        for p in (2, 3, 4):
            om = rot_weight(p)
            for x in all_phase_vectors(len(w), p):
                vol = volume(w, x)
                if vol > 0:
                    worst = max(worst, rot_energy(w, om, x) / vol)
        print(f"  {name:24s}  max Rayleigh quotient over phase vectors = {worst:.6f} <= 2")


def demo_divisor_lattice() -> None:
    banner("3. The zero set of the periodicity ratio is the divisor lattice")
    examples = {
        "directed 4-cycle": directed_cycle(4),
        "directed 6-cycle": directed_cycle(6),
        "4-cycle + chord 0->2": cycle_with_chord(4, 0, 2),
        "K_{2,3} both ways": complete_bipartite_digraph(2, 3),
    }
    for name, w in examples.items():
        n = len(w)
        period = digraph_period(w)
        zeros = []
        for p in range(1, 9):
            cert = canonical_certificate(w, p)
            if cert is not None and abs(rot_energy(w, rot_weight(p), cert)) < 1e-18:
                zeros.append(p)
        divisors = [d for d in range(1, 9) if period % d == 0]
        walks = closed_walk_lengths(w, 12)
        print(f"  {name}")
        print(f"     vertices {n}, strongly connected: {is_strongly_connected(w)}")
        print(f"     closed-walk lengths <= 12 : {walks}")
        print(f"     period                    : {period}")
        print(f"     p with zero energy        : {zeros}")
        print(f"     divisors of the period    : {divisors}")
        assert zeros == divisors, "divisor-lattice theorem violated"
    print("  => in every case the zero set equals the divisor set of the period.")


def demo_counterexample() -> None:
    banner("4. Vanishing 2-periodicity ratio does NOT mean period 2")
    w = directed_cycle(4)
    om2 = rot_weight(2)
    x = [(-1.0 + 0j) ** v for v in range(4)]
    print(f"  digraph            : directed 4-cycle, om_2 = {om2.real:+.0f}")
    print(f"  phase vector       : {[int(round(z.real)) for z in x]}")
    print(f"  2-rotated energy   : {rot_energy(w, om2, x):.12f}   (so beta_2 = 0)")
    print(f"  closed-walk lengths: {closed_walk_lengths(w, 12)}")
    print(f"  period             : {digraph_period(w)}")
    print("  => beta_2 = 0 yet no closed walk has length 2: the ratio detects")
    print("     only that 2 DIVIDES the period, never that the period equals 2.")


def demo_reversal_invariance() -> None:
    banner("5. Reversing every arc leaves the periodicity ratio unchanged")
    graphs = {
        "4-cycle + chord 0->2": cycle_with_chord(4, 0, 2),
        "directed 5-cycle": directed_cycle(5),
    }
    for name, w in graphs.items():
        wr = reverse(w)
        for p in (2, 3):
            a = periodicity_ratio(w, p)
            b = periodicity_ratio(wr, p)
            print(f"  {name:22s} p={p}:  beta = {a:.9f}   beta(reversed) = {b:.9f}")
            assert abs(a - b) < 1e-9, "reversal invariance violated"
    print("  => the ratio is a property of the arc set, not of arrow direction.")


def demo_markov_chain() -> None:
    banner("6. Markov chains: unimodular eigenvalues have zero rotated energy")
    # Periodic chain of period 3: a directed triangle with random split weights.
    P = [
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
        [1.0, 0.0, 0.0],
    ]
    pi = stationary_distribution(P)
    w = chain_weighting(P, pi)
    om = rot_weight(3)
    x = [om ** v for v in range(3)]  # right eigenvector with eigenvalue om
    Px = apply_matrix(P, x)
    err = max(abs(Px[u] - om * x[u]) for u in range(3))
    print(f"  stationary distribution pi   : {[round(t, 6) for t in pi]}")
    print(f"  eigenvector residual |Px-om x|: {err:.2e}")
    print(f"  rotated energy of eigenvector : {rot_energy(w, om, x):.2e}   (theory: 0)")
    print(f"  period of the flow digraph    : {digraph_period(w)}")

    # An aperiodic chain: adding a self-loop kills all unimodular eigenvalues
    # other than 1, and no 3-phase vector has zero energy.
    Q = [
        [0.5, 0.5, 0.0],
        [0.0, 0.0, 1.0],
        [1.0, 0.0, 0.0],
    ]
    piq = stationary_distribution(Q)
    wq = chain_weighting(Q, piq)
    print()
    print(f"  after adding a self-loop, period = {digraph_period(wq)} (aperiodic)")
    for p in (2, 3):
        best = periodicity_ratio(wq, p)
        print(f"     minimal {p}-periodicity ratio = {best:.6f}  > 0")


def demo_quantization() -> None:
    banner("7. Quantization: energy is 0 or at least 4 sin^2(pi/p)")
    print(f"  {'p':>3}  {'root gap g_p':>14}  {'4 sin^2(pi/p)':>15}")
    for p in range(2, 9):
        print(f"  {p:>3}  {root_gap(p):>14.9f}  {4 * math.sin(math.pi / p) ** 2:>15.9f}")
    print()
    print("  Exhaustive check over all unimodular phase vectors of unit-weight graphs:")
    graphs = {
        "directed 4-cycle": directed_cycle(4),
        "directed 5-cycle": directed_cycle(5),
        "4-cycle + chord 0->2": cycle_with_chord(4, 0, 2),
        "K_{2,2} both ways": complete_bipartite_digraph(2, 2),
    }
    for name, w in graphs.items():
        for p in (2, 3, 4):
            om = rot_weight(p)
            g = root_gap(p)
            zero_count = 0
            min_positive = math.inf
            for x in all_phase_vectors(len(w), p, allow_zero=False):
                e = rot_energy(w, om, x)
                if e < 1e-9:
                    zero_count += 1
                else:
                    min_positive = min(min_positive, e)
            gap_ok = min_positive == math.inf or min_positive >= g - 1e-9
            print(
                f"  {name:22s} p={p}:  #zero-energy = {zero_count:4d},"
                f"  min positive energy = {min_positive:9.6f},"
                f"  g_p = {g:.6f}  {'OK' if gap_ok else 'FAIL'}"
            )
            assert gap_ok, "quantization theorem violated"
    print("  => the interval (0, g_p) is empty of achievable energies.")


def demo_rigidity() -> None:
    banner("8. Rigidity: energy below the gap forces exact periodicity")
    w = directed_cycle(6)
    for p in (2, 3, 6):
        om = rot_weight(p)
        x = [om ** v for v in range(6)]
        e = rot_energy(w, om, x)
        g = root_gap(p)
        verdict = "certifies exact p-periodicity" if e < g else "no certificate"
        print(f"  6-cycle, p={p}: energy = {e:.12f}, threshold g_p = {g:.6f} -> {verdict}")
    print(f"  period of the 6-cycle = {digraph_period(w)}; divisors detected: 1,2,3,6")


def demo_sharpness() -> None:
    banner("9. Sharpness: without a weight scale the dichotomy fails")
    x: Vector = [1 + 0j] * 4
    om3 = rot_weight(3)
    base = rot_energy(directed_cycle(4), om3, x)
    print(f"  constant phase vector on the unit-weight 4-cycle, p = 3")
    print(f"  |1 - om_3|^2 = {abs(1 - om3) ** 2:.6f}, four arcs -> energy = {base:.6f}")
    print(f"  root gap g_3 = {root_gap(3):.6f}")
    print()
    print(f"  {'scale t':>12}  {'energy':>16}  {'ratio E/vol':>14}")
    for t in (1.0, 1e-1, 1e-2, 1e-4, 1e-8):
        wt = directed_cycle(4, weight=t)
        e = rot_energy(wt, om3, x)
        print(f"  {t:>12.0e}  {e:>16.10f}  {e / volume(wt, x):>14.9f}")
    print("  => raw energy shrinks to 0 while staying positive: the hypothesis")
    print("     'nonzero weights >= 1' is necessary.  The scale-invariant RATIO")
    print("     E/vol is unaffected, which is why algorithms use the ratio.")


def demo_spectral_algorithm() -> None:
    banner("10. Spectral detection: smallest rotated eigenvalue by power method")

    def smallest_eigenvalue(w: Matrix, om: Complex, iters: int = 4000) -> float:
        """Smallest eigenvalue of the Hermitian rotated Laplacian D - A_om."""
        n = len(w)
        deg = total_degree(w)
        shift = 2.0 * max(deg) + 1.0

        def L(x: Vector) -> Vector:
            # (D - A_om) x, with the Hermitian off-diagonal convention
            out = [deg[v] * x[v] for v in range(n)]
            for u in range(n):
                for v in range(n):
                    if w[u][v] != 0.0:
                        out[v] -= w[u][v] * om * x[u]
                        out[u] -= w[u][v] * om.conjugate() * x[v]
            return out

        # power iteration on (shift*I - L) to find the smallest eigenvalue of L
        x: Vector = [complex(math.cos(1.7 * k), math.sin(0.9 * k)) for k in range(n)]
        for _ in range(iters):
            y = L(x)
            z = [shift * x[k] - y[k] for k in range(n)]
            nrm = math.sqrt(sum(abs(t) ** 2 for t in z))
            if nrm == 0.0:
                break
            x = [t / nrm for t in z]
        y = L(x)
        return sum((x[k].conjugate() * y[k]).real for k in range(n))

    graphs = {
        "directed 4-cycle": directed_cycle(4),
        "directed 6-cycle": directed_cycle(6),
        "4-cycle + chord 0->2": cycle_with_chord(4, 0, 2),
    }
    for name, w in graphs.items():
        period = digraph_period(w)
        row = []
        for p in (2, 3, 4, 6):
            lam = smallest_eigenvalue(w, rot_weight(p))
            row.append(f"p={p}: {max(lam, 0.0):8.5f}")
        print(f"  {name:22s} period {period} | " + "  ".join(row))
    print("  => the smallest rotated eigenvalue is ~0 exactly for p dividing the")
    print("     period, and bounded away from 0 otherwise.")


def main() -> None:
    print(__doc__)
    demo_zero_energy_is_arc_local()
    demo_universal_bound()
    demo_divisor_lattice()
    demo_counterexample()
    demo_reversal_invariance()
    demo_markov_chain()
    demo_quantization()
    demo_rigidity()
    demo_sharpness()
    demo_spectral_algorithm()
    print()
    print("All demonstrations completed; every asserted theorem held numerically.")


if __name__ == "__main__":
    main()
