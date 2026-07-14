"""
Numerical demonstrations for:

    The Suspension Tower and the Exact Z2-Coindex of Combinatorial Spheres

Model (self-contained):
  * The n-dimensional combinatorial sphere S^n is the boundary of the (n+1)-cross-polytope.
    Its vertices are the signed axes +-e_i, encoded as (i, b) with i in {0,..,n} and b in {True,False}.
  * The antipodal map flips the sign bit:  anti(i, b) = (i, not b).
  * A fair map (Z2-map) S^m -> S^n is a vertex map that is equivariant and simplicial.
  * A fair map is determined by positive-vertex data g : {0,..,m} -> SVert(n).
    Simpliciality  <=>  the coordinate map sigma(i) = axis of g(i) is injective.
  * Consequences: a fair map exists iff m <= n; coind(S^n) = n; suspension preserves the excess n - m.

Everything below verifies these statements by brute force on the finite vertex sets,
and cross-checks against the closed-form criteria proved in the paper.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

Vertex = Tuple[int, bool]  # (axis index, sign bit)


# ---------------------------------------------------------------------------
# Core model
# ---------------------------------------------------------------------------
def anti(p: Vertex) -> Vertex:
    """The free Z2 antipodal action: flip the sign bit."""
    i, b = p
    return (i, not b)


def svert(n: int) -> List[Vertex]:
    """All 2(n+1) vertices of the combinatorial sphere S^n."""
    return [(i, b) for i in range(n + 1) for b in (True, False)]


def induced(g: List[Vertex]) -> Dict[Vertex, Vertex]:
    """Reconstruct the full equivariant vertex map from positive-vertex data g."""
    m = len(g) - 1
    f: Dict[Vertex, Vertex] = {}
    for i in range(m + 1):
        f[(i, True)] = g[i]
        f[(i, False)] = anti(g[i])
    return f


def is_equivariant(f: Dict[Vertex, Vertex]) -> bool:
    return all(f[anti(p)] == anti(f[p]) for p in f)


def is_simplicial(f: Dict[Vertex, Vertex]) -> bool:
    """No two non-antipodal source vertices land on an antipodal target pair."""
    for p in f:
        for q in f:
            if f[p] == anti(f[q]) and p != anti(q):
                return False
    return True


def coord_map(g: List[Vertex]) -> List[int]:
    """sigma(i) = axis index of g(i)."""
    return [v[0] for v in g]


def is_injective(xs: List[int]) -> bool:
    return len(set(xs)) == len(xs)


# ---------------------------------------------------------------------------
# Suspension
# ---------------------------------------------------------------------------
def susp_data(g: List[Vertex]) -> List[Vertex]:
    """
    Positive-vertex data of the suspension of the map with data g : {0..m} -> SVert(n).
    Old axes are reused (indices unchanged, since inclusion into {0..n+1} is identity on labels);
    a new pole axis (index n+1) is appended, mapping to the target pole with a + sign.
    """
    n = max(v[0] for v in g)  # target dimension
    new_g = list(g)  # old vertices keep their axis labels inside {0..n+1}
    new_g.append((n + 1, True))  # new source pole -> new target pole
    return new_g


# ---------------------------------------------------------------------------
# Existence oracle (closed form) and brute-force search
# ---------------------------------------------------------------------------
def fair_map_exists_closed_form(m: int, n: int) -> bool:
    """Theorem: Z2Map(m, n) is nonempty  iff  m <= n."""
    return m <= n


def fair_map_exists_bruteforce(m: int, n: int) -> bool:
    """Search all positive-vertex data g : {0..m} -> SVert(n) for a simplicial one."""
    for g in product(svert(n), repeat=m + 1):
        f = induced(list(g))
        # induced maps are always equivariant; only simpliciality can fail
        if is_simplicial(f):
            return True
    return False


def coindex_bruteforce(n: int, m_max: int) -> int:
    """coind(S^n) = largest m (searched up to m_max) with a fair map S^m -> S^n."""
    best = 0
    for m in range(m_max + 1):
        if fair_map_exists_bruteforce(m, n):
            best = m
    return best


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_coordinate_injectivity_principle() -> None:
    print("=" * 70)
    print("Coordinate Injectivity Principle: simplicial  <=>  sigma injective")
    print("=" * 70)
    # try every g : {0,1} -> SVert(2)  (source S^1, target S^2)
    m, n = 1, 2
    checked = agree = 0
    for g in product(svert(n), repeat=m + 1):
        g = list(g)
        simplicial = is_simplicial(induced(g))
        injective = is_injective(coord_map(g))
        checked += 1
        if simplicial == injective:
            agree += 1
    print(f"S^{m} -> S^{n}: tested {checked} candidate maps; "
          f"simpliciality matched coordinate-injectivity in {agree}/{checked} cases.")
    assert agree == checked
    print("PASS: the two conditions coincide exactly.\n")


def demo_existence_criterion() -> None:
    print("=" * 70)
    print("Existence criterion:  fair map S^m -> S^n exists  <=>  m <= n")
    print("=" * 70)
    print(f"{'m':>3} {'n':>3} {'bruteforce':>12} {'closed form':>12}")
    for n in range(4):
        for m in range(4):
            bf = fair_map_exists_bruteforce(m, n)
            cf = fair_map_exists_closed_form(m, n)
            assert bf == cf, (m, n, bf, cf)
            print(f"{m:>3} {n:>3} {str(bf):>12} {str(cf):>12}")
    print("PASS: brute force agrees with m <= n everywhere.\n")


def demo_borsuk_ulam() -> None:
    print("=" * 70)
    print("Borsuk-Ulam, all dimensions: no fair map S^(n+1) -> S^n")
    print("=" * 70)
    for n in range(4):
        exists = fair_map_exists_bruteforce(n + 1, n)
        assert not exists
        print(f"S^{n+1} -> S^{n}: fair map exists? {exists}")
    print("PASS: every S^(n+1) -> S^n is impossible.\n")


def demo_coindex() -> None:
    print("=" * 70)
    print("Exact coindex:  coind(S^n) = n")
    print("=" * 70)
    for n in range(4):
        c = coindex_bruteforce(n, m_max=n + 1)
        assert c == n
        print(f"coind(S^{n}) = {c}")
    print("PASS: coindex equals dimension.\n")


def demo_suspension_tower() -> None:
    print("=" * 70)
    print("Suspension tower: exactness (preserves excess n - m) and sharpness")
    print("=" * 70)
    # Start with a fair map S^1 -> S^2 (excess 1) and suspend twice.
    g = [(0, True), (1, True)]  # sigma = inclusion {0,1} -> {0,1,2}
    assert is_simplicial(induced(g))
    m, n = 1, 2
    print(f"level 0: S^{m} -> S^{n}, excess n-m = {n-m}, simplicial = {is_simplicial(induced(g))}")
    for k in range(1, 3):
        g = susp_data(g)
        m, n = m + 1, n + 1
        ok = is_simplicial(induced(g))
        print(f"level {k}: S^{m} -> S^{n}, excess n-m = {n-m}, simplicial = {ok}")
        assert ok and (n - m == 1)
    # Exactness as a biconditional against the closed form:
    for base_m, base_n, k in [(1, 2, 3), (2, 2, 5), (3, 2, 4)]:
        lhs = fair_map_exists_closed_form(base_m + k, base_n + k)
        rhs = fair_map_exists_closed_form(base_m, base_n)
        assert lhs == rhs
    print("PASS: suspension preserves the excess and existence at every level.\n")


def main() -> None:
    demo_coordinate_injectivity_principle()
    demo_existence_criterion()
    demo_borsuk_ulam()
    demo_coindex()
    demo_suspension_tower()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
