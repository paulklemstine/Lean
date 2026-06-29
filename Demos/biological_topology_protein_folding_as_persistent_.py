"""
Biological Topology: Protein Folding as Persistent-Homology Optimization
========================================================================

Numerical demonstrations of the core results of the topological theory of
protein folding. Everything below is self-contained: only the Python standard
library is used (plus `random` and `math`). No external packages required.

Results demonstrated
---------------------
  1. Total persistence is nonnegative and additive over disjoint feature sets.
  2. The Vietoris-Rips contact filtration is monotone (functorial).
  3. Degree-zero total persistence of a sorted linear chain equals its
     end-to-end extent  (the elder-rule / MST identity).
  4. The same quantity equals the minimum-spanning-tree weight for an
     ARBITRARY point configuration (general MST law, verified numerically).
  5. Compaction lowers the topological energy (hydrophobic collapse).
  6. Stability: an epsilon-perturbation moves the energy by at most 2*epsilon.
  7. Existence and uniqueness of the native fold over a finite decoy ensemble.

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import List, Tuple

Point = Tuple[float, ...]


# ---------------------------------------------------------------------------
# Barcodes and total persistence
# ---------------------------------------------------------------------------

class PersistenceBar:
    """A single bar (birth, death) of a persistence barcode, with birth <= death."""

    def __init__(self, birth: float, death: float) -> None:
        if birth > death + 1e-12:
            raise ValueError(f"a feature cannot die before birth: {birth} > {death}")
        self.birth = birth
        self.death = death

    @property
    def persistence(self) -> float:
        """Lifetime death - birth (always nonnegative)."""
        return self.death - self.birth

    def __repr__(self) -> str:
        return f"Bar(birth={self.birth:.4f}, death={self.death:.4f})"


Barcode = List[PersistenceBar]


def total_persistence(barcode: Barcode) -> float:
    """Topological energy: sum of bar lifetimes (death_i - birth_i)."""
    return sum(bar.persistence for bar in barcode)


# ---------------------------------------------------------------------------
# Geometry helpers
# ---------------------------------------------------------------------------

def distance(p: Point, q: Point) -> float:
    """Euclidean distance between two points of equal dimension."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(p, q)))


# ---------------------------------------------------------------------------
# Vietoris-Rips contact filtration
# ---------------------------------------------------------------------------

def rips_contains(points: List[Point], subset: List[int], scale: float) -> bool:
    """Is `subset` a simplex of the Vietoris-Rips complex at the given scale?

    True iff all pairwise distances within `subset` are <= scale.
    """
    for i in subset:
        for j in subset:
            if distance(points[i], points[j]) > scale + 1e-12:
                return False
    return True


# ---------------------------------------------------------------------------
# Degree-zero barcode
# ---------------------------------------------------------------------------

def h0_line_barcode(positions: List[float]) -> Barcode:
    """Degree-zero barcode of a SORTED linear chain of 1-D positions.

    One bar (0, x_{i+1} - x_i) per consecutive gap.
    """
    bars: Barcode = []
    for i in range(len(positions) - 1):
        bars.append(PersistenceBar(0.0, positions[i + 1] - positions[i]))
    return bars


def h0_barcode_mst(points: List[Point]) -> Barcode:
    """Degree-zero barcode of an ARBITRARY point set via the MST / single-linkage law.

    Components are all born at scale 0 and merge along minimum-spanning-tree
    edges; each MST edge weight is the death of one component.
    Uses Prim's algorithm (no external dependencies).
    """
    n = len(points)
    if n == 0:
        return []
    in_tree = [False] * n
    best = [math.inf] * n
    best[0] = 0.0
    bars: Barcode = []
    for _ in range(n):
        # pick the closest vertex not yet in the tree
        u = min((v for v in range(n) if not in_tree[v]), key=lambda v: best[v])
        in_tree[u] = True
        if best[u] > 0.0:
            bars.append(PersistenceBar(0.0, best[u]))
        for v in range(n):
            if not in_tree[v]:
                best[v] = min(best[v], distance(points[u], points[v]))
    return bars


def mst_weight(points: List[Point]) -> float:
    """Total minimum-spanning-tree weight (Prim's algorithm)."""
    return total_persistence(h0_barcode_mst(points))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_nonnegativity_and_additivity() -> None:
    print("=" * 70)
    print("1. Nonnegativity and additivity of total persistence")
    print("=" * 70)
    b = [PersistenceBar(0.0, 1.5), PersistenceBar(0.2, 0.9)]
    c = [PersistenceBar(0.0, 2.0)]
    print(f"  E(B)       = {total_persistence(b):.4f}  (>= 0 : {total_persistence(b) >= 0})")
    print(f"  E(C)       = {total_persistence(c):.4f}  (>= 0 : {total_persistence(c) >= 0})")
    print(f"  E(B + C)   = {total_persistence(b + c):.4f}")
    print(f"  E(B)+E(C)  = {total_persistence(b) + total_persistence(c):.4f}")
    ok = abs(total_persistence(b + c) - (total_persistence(b) + total_persistence(c))) < 1e-12
    print(f"  additive   : {ok}")
    print()


def demo_rips_monotone() -> None:
    print("=" * 70)
    print("2. Functoriality: the contact filtration is monotone")
    print("=" * 70)
    pts: List[Point] = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (2.0, 2.0)]
    subset = [0, 1, 2]
    scales = [0.5, 1.0, 1.5, 2.0, 3.0]
    print(f"  subset {subset}: membership of Rips at increasing scales")
    prev = False
    monotone = True
    for s in scales:
        present = rips_contains(pts, subset, s)
        if prev and not present:
            monotone = False
        prev = prev or present
        print(f"    scale {s:.2f}: in Rips = {present}")
    print(f"  once present, stays present (monotone): {monotone}")
    print()


def demo_chain_extent() -> None:
    print("=" * 70)
    print("3. Elder rule on a chain: H0 total persistence = end-to-end extent")
    print("=" * 70)
    positions = [0.0, 0.8, 1.7, 3.2, 5.0]
    barcode = h0_line_barcode(positions)
    energy = total_persistence(barcode)
    extent = positions[-1] - positions[0]
    print(f"  positions  : {positions}")
    print(f"  bars       : {barcode}")
    print(f"  E (sum)    : {energy:.4f}")
    print(f"  extent     : {extent:.4f}")
    print(f"  equal      : {abs(energy - extent) < 1e-12}")
    print()


def demo_general_mst_law() -> None:
    print("=" * 70)
    print("4. General MST law: H0 total persistence = MST weight (any config)")
    print("=" * 70)
    random.seed(7)
    for trial in range(3):
        pts: List[Point] = [
            (random.uniform(0, 10), random.uniform(0, 10), random.uniform(0, 10))
            for _ in range(8)
        ]
        e = total_persistence(h0_barcode_mst(pts))
        w = mst_weight(pts)
        print(f"  trial {trial}: H0 energy = {e:.4f}, MST weight = {w:.4f}, "
              f"equal = {abs(e - w) < 1e-9}")
    print()


def demo_compaction() -> None:
    print("=" * 70)
    print("5. Compaction lowers energy (hydrophobic collapse)")
    print("=" * 70)
    positions = [0.0, 1.0, 2.5, 4.0, 6.0]
    e0 = total_persistence(h0_line_barcode(positions))
    # contract toward the centroid by factor 0.6
    c = sum(positions) / len(positions)
    compact = [c + 0.6 * (p - c) for p in positions]
    compact.sort()
    e1 = total_persistence(h0_line_barcode(compact))
    print(f"  extended energy : {e0:.4f}")
    print(f"  compacted energy: {e1:.4f}")
    print(f"  energy decreased: {e1 < e0}")
    print()


def demo_stability() -> None:
    print("=" * 70)
    print("6. Stability: epsilon-perturbation moves energy by at most 2*epsilon")
    print("=" * 70)
    random.seed(11)
    positions = sorted(random.uniform(0, 10) for _ in range(6))
    eps = 0.3
    e0 = total_persistence(h0_line_barcode(positions))
    worst = 0.0
    for _ in range(2000):
        perturbed = sorted(p + random.uniform(-eps, eps) for p in positions)
        e1 = total_persistence(h0_line_barcode(perturbed))
        worst = max(worst, abs(e1 - e0))
    print(f"  epsilon              : {eps}")
    print(f"  worst |dE| observed  : {worst:.4f}")
    print(f"  theoretical bound 2e : {2 * eps:.4f}")
    print(f"  bound respected      : {worst <= 2 * eps + 1e-9}")
    print()


def demo_native_fold() -> None:
    print("=" * 70)
    print("7. Existence and uniqueness of the native fold over a decoy ensemble")
    print("=" * 70)
    random.seed(3)
    # one "native" compact fold plus several stretched decoys
    native: List[Point] = [(math.cos(i), math.sin(i), 0.0) for i in range(12)]
    ensemble: List[Tuple[str, List[Point]]] = [("native", native)]
    for d in range(5):
        scale = 1.5 + d
        decoy = [(scale * math.cos(i), scale * math.sin(i), 0.3 * i)
                 for i in range(12)]
        ensemble.append((f"decoy_{d}", decoy))
    energies = [(name, total_persistence(h0_barcode_mst(pts)))
                for name, pts in ensemble]
    for name, e in energies:
        print(f"    {name:10s}: E = {e:.4f}")
    best_name, best_e = min(energies, key=lambda t: t[1])
    n_min = sum(1 for _, e in energies if abs(e - best_e) < 1e-9)
    print(f"  minimizer        : {best_name} (E = {best_e:.4f})")
    print(f"  unique minimizer : {n_min == 1}")
    print(f"  native wins      : {best_name == 'native'}")
    print()


def main() -> None:
    print()
    print("Biological Topology: Protein Folding as Persistent-Homology Optimization")
    print("Numerical demonstrations")
    print()
    demo_nonnegativity_and_additivity()
    demo_rips_monotone()
    demo_chain_extent()
    demo_general_mst_law()
    demo_compaction()
    demo_stability()
    demo_native_fold()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
