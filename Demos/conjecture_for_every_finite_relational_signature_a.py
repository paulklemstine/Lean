"""
The Analogy Distance on Finite Probabilistic Transition Systems
================================================================

A self-contained numerical companion to the theory of epsilon-approximate
structural analogies between finite probabilistic transition systems.

Everything is implemented from scratch with the Python standard library only
(no numpy, no scipy), so the script runs anywhere.

What is demonstrated
--------------------
1.  The overlap defect  1 - sum_t min(P_t, Q_t)  equals the total variation
    distance  (1/2) * sum_t |P_t - Q_t|  of two probability vectors.
2.  The transport theorem: along an epsilon-approximate analogy the truth
    probability of a depth-d formula moves by at most  1 - (1 - eps)^d,
    and this geometric modulus is attained by an explicit two-state family.
3.  The conjectured linear modulus  d * eps  is a valid but strictly weaker
    bound for d >= 2, sharp only to first order in eps.
4.  The analogy distance  d(M, N) = min over atom-preserving renamings of the
    worst-case one-step overlap defect: an attained minimum, a metric, with
    zero set exactly isomorphism.
5.  The exact value  d(exact, leaky(eps)) = eps  on the extremal family.
6.  The approximate Hennessy-Milner constant  n * eta / 2  and its optimality.
7.  The resolution gap: two systems with identical modal truth probabilities
    at every depth but analogy distance 1.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import permutations
from typing import Callable, Dict, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]

TOL = 1e-9


# ----------------------------------------------------------------------------
# 1. Probability vectors, overlap defect, total variation
# ----------------------------------------------------------------------------

def overlap_defect(p: Sequence[float], q: Sequence[float]) -> float:
    """The overlap defect  1 - sum_t min(p_t, q_t)  of two vectors."""
    return 1.0 - sum(min(a, b) for a, b in zip(p, q))


def total_variation(p: Sequence[float], q: Sequence[float]) -> float:
    """Total variation distance  (1/2) * sum_t |p_t - q_t|."""
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


# ----------------------------------------------------------------------------
# 2. Probabilistic modal structures and their formulas
# ----------------------------------------------------------------------------

class PSystem:
    """A finite probabilistic modal structure.

    `step[s][t]` is the probability of moving from world s to world t; every
    row is a probability vector.  `val[p][s]` in [0,1] is the truth
    probability of the atom p at the world s.
    """

    def __init__(self, step: Matrix, val: Dict[str, Vector], name: str = "M") -> None:
        self.n: int = len(step)
        self.step: Matrix = [list(row) for row in step]
        self.val: Dict[str, Vector] = {p: list(v) for p, v in val.items()}
        self.name: str = name
        for s, row in enumerate(self.step):
            assert len(row) == self.n, "kernel must be square"
            assert all(x >= -TOL for x in row), "kernel must be nonnegative"
            assert abs(sum(row) - 1.0) < 1e-8, f"row {s} of {name} is not stochastic"
        for p, v in self.val.items():
            assert all(-TOL <= x <= 1.0 + TOL for x in v), f"atom {p} out of [0,1]"


# Formulas are nested tuples:
#   ("atom", p) | ("neg", phi) | ("conj", phi, psi) | ("next", phi)
Formula = tuple


def atom(p: str) -> Formula:
    return ("atom", p)


def neg(phi: Formula) -> Formula:
    return ("neg", phi)


def conj(phi: Formula, psi: Formula) -> Formula:
    return ("conj", phi, psi)


def nxt(phi: Formula) -> Formula:
    return ("next", phi)


def next_iter(d: int, phi: Formula) -> Formula:
    """The modality `next` applied d times."""
    for _ in range(d):
        phi = nxt(phi)
    return phi


def depth(phi: Formula) -> int:
    """Modal depth: the number of nested one-step observations."""
    kind = phi[0]
    if kind == "atom":
        return 0
    if kind == "neg":
        return depth(phi[1])
    if kind == "conj":
        return max(depth(phi[1]), depth(phi[2]))
    if kind == "next":
        return depth(phi[1]) + 1
    raise ValueError(f"unknown formula {phi!r}")


def evaluate(m: PSystem, phi: Formula, s: int) -> float:
    """Truth probability of phi at the world s of m."""
    kind = phi[0]
    if kind == "atom":
        return m.val[phi[1]][s]
    if kind == "neg":
        return 1.0 - evaluate(m, phi[1], s)
    if kind == "conj":
        return min(evaluate(m, phi[1], s), evaluate(m, phi[2], s))
    if kind == "next":
        return sum(m.step[s][t] * evaluate(m, phi[1], t) for t in range(m.n))
    raise ValueError(f"unknown formula {phi!r}")


# ----------------------------------------------------------------------------
# 3. Approximate analogies and the analogy distance
# ----------------------------------------------------------------------------

def preserves_atoms(m: PSystem, n: PSystem, f: Sequence[int]) -> bool:
    """Does the renaming f of worlds preserve every atomic truth probability?"""
    if set(m.val) != set(n.val):
        return False
    return all(
        abs(n.val[p][f[s]] - m.val[p][s]) < 1e-9
        for p in m.val
        for s in range(m.n)
    )


def analogy_cost(m: PSystem, n: PSystem, f: Sequence[int]) -> float:
    """Worst-case one-step overlap defect produced by the renaming f."""
    return max(
        overlap_defect(m.step[s], [n.step[f[s]][f[t]] for t in range(m.n)])
        for s in range(m.n)
    )


def analogy_distance(m: PSystem, n: PSystem) -> Tuple[float, Tuple[int, ...] | None]:
    """The analogy distance and an optimal renaming attaining it.

    d(M, N) = min { analogy_cost(M, N, f) : f an atom-preserving renaming },
    with the junk value 1 (and no witness) if no such renaming exists.
    Brute force over all n! renamings; feasible for n <= 8.
    """
    assert m.n == n.n, "systems must have the same number of worlds"
    best: float = 1.0
    witness: Tuple[int, ...] | None = None
    found = False
    for f in permutations(range(m.n)):
        if not preserves_atoms(m, n, f):
            continue
        c = analogy_cost(m, n, f)
        if not found or c < best:
            best, witness, found = c, f, True
    return (best, witness) if found else (1.0, None)


def is_isomorphism(m: PSystem, n: PSystem, f: Sequence[int]) -> bool:
    """Does f preserve atoms and carry the kernel of m onto that of n exactly?"""
    if not preserves_atoms(m, n, f):
        return False
    return all(
        abs(n.step[f[s]][f[t]] - m.step[s][t]) < 1e-9
        for s in range(m.n)
        for t in range(m.n)
    )


# ----------------------------------------------------------------------------
# 4. The extremal two-state family
# ----------------------------------------------------------------------------

def exact_system() -> PSystem:
    """Two absorbing worlds; the atom holds at world 1 and fails at world 0."""
    return PSystem(step=[[1.0, 0.0], [0.0, 1.0]],
                   val={"a": [0.0, 1.0]}, name="exact")


def leaky_system(eps: float) -> PSystem:
    """As above, but mass eps leaks out of world 1 into the absorbing world 0."""
    return PSystem(step=[[1.0, 0.0], [eps, 1.0 - eps]],
                   val={"a": [0.0, 1.0]}, name=f"leaky({eps})")


def geometric_modulus(eps: float, d: int) -> float:
    return 1.0 - (1.0 - eps) ** d


def linear_modulus(eps: float, d: int) -> float:
    return d * eps


# ----------------------------------------------------------------------------
# 5. The Hennessy-Milner extremal family on n = 2m worlds
# ----------------------------------------------------------------------------

def nominal_uniform(m: int) -> PSystem:
    """Uniform kernel on n = 2m worlds, with one nominal atom per world."""
    n = 2 * m
    step = [[1.0 / n] * n for _ in range(n)]
    val = {f"w{j}": [1.0 if i == j else 0.0 for i in range(n)] for j in range(n)}
    return PSystem(step, val, name=f"uniform({n})")


def nominal_tilted(m: int, eta: float) -> PSystem:
    """As above, but mass eta is moved from each 'negative' world to a
    'positive' one.  Worlds 0..m-1 are positive, worlds m..2m-1 negative."""
    n = 2 * m
    row = [1.0 / n + (eta if j < m else -eta) for j in range(n)]
    step = [list(row) for _ in range(n)]
    val = {f"w{j}": [1.0 if i == j else 0.0 for i in range(n)] for j in range(n)}
    return PSystem(step, val, name=f"tilted({n},{eta})")


# ----------------------------------------------------------------------------
# 6. The resolution gap
# ----------------------------------------------------------------------------

def identity_system() -> PSystem:
    """Two worlds, each with a self-loop; the single atom is true everywhere."""
    return PSystem(step=[[1.0, 0.0], [0.0, 1.0]], val={"a": [1.0, 1.0]}, name="two loops")


def swap_system() -> PSystem:
    """Two worlds forming a 2-cycle; the single atom is true everywhere."""
    return PSystem(step=[[0.0, 1.0], [1.0, 0.0]], val={"a": [1.0, 1.0]}, name="2-cycle")


def all_formulas(atoms: Sequence[str], max_depth: int) -> List[Formula]:
    """All formulas over the given atoms up to the given modal depth
    (a finite generating family: atoms, negations, conjunctions, nexts)."""
    level: List[Formula] = [atom(p) for p in atoms]
    out: List[Formula] = list(level)
    for _ in range(max_depth):
        new: List[Formula] = []
        for phi in level:
            new.append(nxt(phi))
            new.append(neg(phi))
        for i, phi in enumerate(level):
            for psi in level[i:]:
                new.append(conj(phi, psi))
        level = new
        out.extend(new)
    return out


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_overlap_is_total_variation() -> None:
    rule("1.  Overlap defect = total variation distance")
    pairs = [
        ([0.5, 0.5], [0.5, 0.5]),
        ([1.0, 0.0], [0.0, 1.0]),
        ([0.6, 0.3, 0.1], [0.2, 0.5, 0.3]),
        ([0.25, 0.25, 0.25, 0.25], [0.4, 0.1, 0.4, 0.1]),
    ]
    print(f"{'P':<28}{'Q':<28}{'1-sum min':>10}{'TV':>10}")
    for p, q in pairs:
        print(f"{str(p):<28}{str(q):<28}{overlap_defect(p, q):>10.4f}"
              f"{total_variation(p, q):>10.4f}")
        assert abs(overlap_defect(p, q) - total_variation(p, q)) < 1e-12
    print("\nThe two agree exactly, as the theory predicts.")


def demo_transport_sharpness() -> None:
    rule("2.  Transport modulus: geometric, attained, and strictly below d*eps")
    eps = 0.15
    m, n = exact_system(), leaky_system(eps)
    f = (0, 1)  # the identity renaming is the optimal analogy here
    print(f"epsilon = {eps},  one-step defect at the leaking world "
          f"= {analogy_cost(m, n, f):.4f}\n")
    print(f"{'d':>3}{'|truth gap|':>14}{'1-(1-eps)^d':>14}{'d*eps':>10}{'slack':>10}")
    for d in range(0, 9):
        phi = next_iter(d, atom("a"))
        gap = abs(evaluate(m, phi, 1) - evaluate(n, phi, 1))
        geo = geometric_modulus(eps, d)
        lin = linear_modulus(eps, d)
        print(f"{d:>3}{gap:>14.6f}{geo:>14.6f}{lin:>10.6f}{lin - geo:>10.6f}")
        assert abs(gap - geo) < 1e-12, "geometric modulus must be attained"
        assert gap <= lin + 1e-12, "linear bound must hold"
    print("\nThe gap equals 1-(1-eps)^d exactly at every depth: the geometric")
    print("modulus is the true modulus of continuity.  The linear bound d*eps")
    print("holds but is strictly larger from depth 2 on.")


def demo_first_order_sharpness() -> None:
    rule("3.  The linear bound is sharp to first order in eps")
    d = 5
    print(f"depth d = {d};  gap between the two moduli, and the quadratic bound")
    print(f"{'eps':>10}{'d*eps - geo':>16}{'d(d-1)/2*eps^2':>18}")
    for eps in [0.2, 0.1, 0.05, 0.02, 0.01, 0.001]:
        diff = linear_modulus(eps, d) - geometric_modulus(eps, d)
        quad = d * (d - 1) / 2 * eps ** 2
        print(f"{eps:>10.4f}{diff:>16.8f}{quad:>18.8f}")
        assert diff <= quad + 1e-12
    print("\nThe discrepancy is O(d^2 eps^2): the two moduli have the same")
    print("derivative at eps = 0, so no bound linear in eps can beat d*eps.")


def demo_distance_extremal() -> None:
    rule("4.  The analogy distance of the extremal family is exactly eps")
    print(f"{'eps':>8}{'d(exact, leaky)':>18}{'optimal renaming':>20}")
    for eps in [0.0, 0.05, 0.25, 0.5, 0.9, 1.0]:
        dist, f = analogy_distance(exact_system(), leaky_system(eps))
        print(f"{eps:>8.2f}{dist:>18.6f}{str(f):>20}")
        assert abs(dist - eps) < 1e-9
    print("\nThe atomic valuation pins the renaming to the identity, and the")
    print("worst-case one-step defect is exactly the leak eps.")


def demo_metric_axioms() -> None:
    rule("5.  The analogy distance is an attained metric")
    systems = [
        PSystem([[0.9, 0.1], [0.2, 0.8]], {"a": [0.0, 1.0]}, "A"),
        PSystem([[0.7, 0.3], [0.4, 0.6]], {"a": [0.0, 1.0]}, "B"),
        PSystem([[0.5, 0.5], [0.5, 0.5]], {"a": [0.0, 1.0]}, "C"),
        PSystem([[1.0, 0.0], [0.0, 1.0]], {"a": [0.0, 1.0]}, "D"),
    ]
    names = [s.name for s in systems]
    print("pairwise analogy distances\n")
    print("      " + "".join(f"{nm:>9}" for nm in names))
    table: List[List[float]] = []
    for x in systems:
        row = [analogy_distance(x, y)[0] for y in systems]
        table.append(row)
        print(f"{x.name:>5} " + "".join(f"{v:>9.4f}" for v in row))

    print("\nchecks:")
    for i, x in enumerate(systems):
        assert abs(table[i][i]) < 1e-12
    print("  d(M,M) = 0                       ok")
    for i in range(len(systems)):
        for j in range(len(systems)):
            assert abs(table[i][j] - table[j][i]) < 1e-9
    print("  d(M,N) = d(N,M)                  ok")
    worst = 0.0
    for i in range(len(systems)):
        for j in range(len(systems)):
            for k in range(len(systems)):
                slack = table[i][j] + table[j][k] - table[i][k]
                worst = min(worst, slack) if slack < worst else worst
                assert slack > -1e-9
    print("  d(M,K) <= d(M,N) + d(N,K)        ok")
    for i in range(len(systems)):
        for j in range(len(systems)):
            _, f = analogy_distance(systems[i], systems[j])
            zero = table[i][j] < 1e-12
            iso = f is not None and is_isomorphism(systems[i], systems[j], f)
            assert zero == iso
    print("  d(M,N) = 0  <=>  isomorphism     ok")
    print("\nEvery distance above is a minimum, attained by an explicit renaming:")
    print("the infimum over renamings is over a finite set, so it is realised.")


def demo_optimal_transport() -> None:
    rule("6.  Transport with the optimal renaming and the optimal constant")
    m = PSystem([[0.95, 0.05], [0.10, 0.90]], {"a": [0.0, 1.0]}, "M")
    n = PSystem([[0.90, 0.10], [0.05, 0.95]], {"a": [0.0, 1.0]}, "N")
    dist, f = analogy_distance(m, n)
    assert f is not None
    print(f"d(M, N) = {dist:.6f} with optimal renaming {f}\n")
    print(f"{'d':>3}{'world 0 gap':>14}{'world 1 gap':>14}{'1-(1-d)^depth':>16}")
    for d in range(0, 7):
        phi = next_iter(d, atom("a"))
        gaps = [abs(evaluate(m, phi, s) - evaluate(n, phi, f[s])) for s in (0, 1)]
        bound = geometric_modulus(dist, d)
        print(f"{d:>3}{gaps[0]:>14.6f}{gaps[1]:>14.6f}{bound:>16.6f}")
        assert max(gaps) <= bound + 1e-12
    print("\nThe map 'system -> vector of depth-d truth probabilities' is")
    print("uniformly continuous with modulus  1 - (1 - d(M,N))^d.")


def demo_hennessy_milner() -> None:
    rule("7.  Approximate Hennessy-Milner: the dimension factor n/2 is optimal")
    print(f"{'m':>3}{'n=2m':>6}{'eta':>10}{'depth-1 gap':>14}"
          f"{'n*eta/2':>10}{'d(M,N)':>10}")
    for m_half in (1, 2, 3):
        n_worlds = 2 * m_half
        eta = 1.0 / (2 * n_worlds)  # admissible: eta <= 1/(2m) with 2m = n
        u, t = nominal_uniform(m_half), nominal_tilted(m_half, eta)
        gaps = {round(abs(evaluate(u, nxt(atom(f"w{j}")), s)
                          - evaluate(t, nxt(atom(f"w{j}")), s)), 12)
                for j in range(n_worlds) for s in range(n_worlds)}
        dist, _ = analogy_distance(u, t)
        predicted = n_worlds * eta / 2
        print(f"{m_half:>3}{n_worlds:>6}{eta:>10.5f}{max(gaps):>14.5f}"
              f"{predicted:>10.5f}{dist:>10.5f}")
        assert len(gaps) == 1 and abs(max(gaps) - eta) < 1e-12
        assert abs(dist - predicted) < 1e-9
    print("\nEvery depth-one observation differs by exactly eta, yet the least")
    print("possible analogy defect is exactly n*eta/2: recovering the kernel")
    print("from depth-one observations is Lipschitz with constant exactly n/2.")


def demo_resolution_gap() -> None:
    rule("8.  The resolution gap: modal equality without analogy")
    m, n = identity_system(), swap_system()
    forms = all_formulas(["a"], 4)
    worst = max(abs(evaluate(m, phi, s) - evaluate(n, phi, s))
                for phi in forms for s in (0, 1))
    dist, f = analogy_distance(m, n)
    print(f"formulas tested (depth <= 4): {len(forms)}")
    print(f"largest truth-probability discrepancy: {worst:.12f}")
    print(f"analogy distance d(two loops, 2-cycle): {dist:.4f}"
          f"   (optimal renaming {f})")
    assert worst < 1e-12
    assert abs(dist - 1.0) < 1e-9
    print("\nEvery modal observation gives the same answer in both systems, yet")
    print("the analogy distance is maximal.  Truth-probability equivalence is")
    print("strictly coarser than structural analogy: transport has no converse.")
    print("The observation that does separate them is self-reference,")
    print(f"  'the current world is a possible successor':"
          f"  step[0][0] = {m.step[0][0]} vs {n.step[0][0]}.")


def demo_network_holonomy() -> None:
    rule("9.  Networks: defects add, holonomy accumulates geometrically")
    chain = [
        PSystem([[1.0, 0.0], [0.00, 1.00]], {"a": [0.0, 1.0]}, "M0"),
        PSystem([[1.0, 0.0], [0.05, 0.95]], {"a": [0.0, 1.0]}, "M1"),
        PSystem([[1.0, 0.0], [0.12, 0.88]], {"a": [0.0, 1.0]}, "M2"),
        PSystem([[1.0, 0.0], [0.20, 0.80]], {"a": [0.0, 1.0]}, "M3"),
    ]
    local = [analogy_distance(chain[i], chain[i + 1])[0] for i in range(3)]
    print("local defects along the chain: "
          + ", ".join(f"{e:.4f}" for e in local))
    total = sum(local)
    direct = analogy_distance(chain[0], chain[3])[0]
    print(f"sum of local defects       = {total:.4f}")
    print(f"direct distance d(M0, M3)  = {direct:.4f}   (triangle inequality)")
    assert direct <= total + 1e-9
    print(f"\n{'d':>3}{'|truth gap M0 vs M3|':>24}{'1-(1-sum eps)^d':>20}")
    for d in range(0, 6):
        phi = next_iter(d, atom("a"))
        gap = abs(evaluate(chain[0], phi, 1) - evaluate(chain[3], phi, 1))
        print(f"{d:>3}{gap:>24.6f}{geometric_modulus(total, d):>20.6f}")
        assert gap <= geometric_modulus(total, d) + 1e-12
    print("\nTraversing a cycle of exact analogies would return every truth")
    print("probability to its starting value: exact cycles have zero holonomy.")


def main() -> None:
    print(__doc__)
    demo_overlap_is_total_variation()
    demo_transport_sharpness()
    demo_first_order_sharpness()
    demo_distance_extremal()
    demo_metric_axioms()
    demo_optimal_transport()
    demo_hennessy_milner()
    demo_resolution_gap()
    demo_network_holonomy()
    print("\n" + "=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
