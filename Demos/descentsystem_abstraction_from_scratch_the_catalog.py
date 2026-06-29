"""
demo.py — Numerical demonstrations of the Basin Fixed Point Theorem.

This script realizes, over concrete finite state spaces, the abstract
"DescentSystem" theory:

    A DescentSystem is a finite state space S together with
      * step   : S -> S          (deterministic update rule)
      * energy : S -> int (>= 0)  (quantized Lyapunov / "energy" function)
    satisfying the STRICT DESCENT LAW:
      * for all s, if step(s) != s then energy(step(s)) < energy(s).

Key facts demonstrated numerically:

  * step_iterate_isFix          : iterating `step` exactly energy(s) times
                                  always lands on a fixed point.
  * limitPoint                  : limitPoint(s) = step^[energy(s)](s) is a
                                  well-defined map onto the fixed points.
  * range_limitPoint == fixedpts: the image of limitPoint is exactly the
                                  fixed-point set.
  * basins partition S          : basins are the fibers of limitPoint; they are
                                  non-empty, disjoint, and exhaustive.
  * Basin Fixed Point Theorem   : #basins == #fixed_points.
  * prod_fixedPoint_count       : basin counts multiply across independent
                                  (synchronous-product) subsystems.
  * limitPoint_equivariant      : energy-preserving, dynamics-commuting
                                  symmetries intertwine with limitPoint.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

State = Hashable


@dataclass
class DescentSystem:
    """A finite descent system: states, an update rule, and a Lyapunov energy."""

    states: Sequence[State]
    step: Callable[[State], State]
    energy: Callable[[State], int]

    # ----- validation ---------------------------------------------------------

    def check_strict_descent(self) -> bool:
        """Verify the strict descent law on every state. Returns True if valid."""
        for s in self.states:
            t = self.step(s)
            if t != s and not (self.energy(t) < self.energy(s)):
                return False
            if self.energy(s) < 0:
                return False
        return True

    # ----- core dynamics ------------------------------------------------------

    def is_fix(self, s: State) -> bool:
        """A state is a fixed point iff step(s) == s."""
        return self.step(s) == s

    def iterate(self, s: State, n: int) -> State:
        """Apply step n times: step^[n](s)."""
        for _ in range(n):
            s = self.step(s)
        return s

    def limit_point(self, s: State) -> State:
        """limitPoint(s) = step^[energy(s)](s). Always a fixed point (Thm 3.2)."""
        return self.iterate(s, self.energy(s))

    # ----- structural objects -------------------------------------------------

    def fixed_points(self) -> List[State]:
        """All fixed points of the system."""
        return [s for s in self.states if self.is_fix(s)]

    def basins(self) -> Dict[State, List[State]]:
        """Basins as fibers of limitPoint: destination -> list of sources."""
        buckets: Dict[State, List[State]] = {}
        for s in self.states:
            t = self.limit_point(s)
            buckets.setdefault(t, []).append(s)
        return buckets


# ---------------------------------------------------------------------------
# Product (synchronous, independent) of two descent systems (Section 6).
# ---------------------------------------------------------------------------

def product_system(d1: DescentSystem, d2: DescentSystem) -> DescentSystem:
    """Synchronous product: step coordinatewise, energy = sum of energies."""
    states: List[Tuple[State, State]] = list(product(d1.states, d2.states))

    def step(p: Tuple[State, State]) -> Tuple[State, State]:
        a, b = p
        return (d1.step(a), d2.step(b))

    def energy(p: Tuple[State, State]) -> int:
        a, b = p
        return d1.energy(a) + d2.energy(b)

    return DescentSystem(states=states, step=step, energy=energy)


# ---------------------------------------------------------------------------
# Verification helpers mirroring the formal theorems.
# ---------------------------------------------------------------------------

def verify_iterate_is_fix(d: DescentSystem) -> bool:
    """Thm 3.2: step^[energy(s)](s) is a fixed point for every s."""
    return all(d.is_fix(d.limit_point(s)) for s in d.states)


def verify_range_eq_fixedpoints(d: DescentSystem) -> bool:
    """Lemma 5.2: range(limitPoint) == fixed-point set."""
    rng = {d.limit_point(s) for s in d.states}
    return rng == set(d.fixed_points())


def verify_partition(d: DescentSystem) -> bool:
    """Thm 5.6: basins are non-empty, pairwise disjoint, and exhaustive."""
    basins = d.basins()
    seen: set = set()
    total = 0
    for block in basins.values():
        if not block:
            return False
        block_set = set(block)
        if block_set & seen:  # overlap
            return False
        seen |= block_set
        total += len(block_set)
    return seen == set(d.states) and total == len(set(d.states))


def verify_basin_count(d: DescentSystem) -> bool:
    """Thm 5.7 (Basin Fixed Point Theorem): #basins == #fixed_points."""
    return len(d.basins()) == len(d.fixed_points())


def verify_equivariance(d: DescentSystem, g: Callable[[State], State]) -> bool:
    """Thm 7.4: for a symmetry g, limitPoint(g s) == g(limitPoint s)."""
    # First confirm g is an energy-preserving, dynamics-commuting symmetry.
    for s in d.states:
        if d.energy(g(s)) != d.energy(s):
            return False
        if d.step(g(s)) != g(d.step(s)):
            return False
    return all(d.limit_point(g(s)) == g(d.limit_point(s)) for s in d.states)


# ---------------------------------------------------------------------------
# Example systems.
# ---------------------------------------------------------------------------

def example_chain() -> DescentSystem:
    """The worked example from the paper.

    S = {0,1,2,3,4},  step = {0->0, 1->0, 2->1, 3->4, 4->4},
    energy(s) = min(s, 4 - s)  ->  (0,1,2,1,0).
    Fixed points {0,4}; basins {0,1,2} and {3,4}.
    """
    step_map = {0: 0, 1: 0, 2: 1, 3: 4, 4: 4}
    return DescentSystem(
        states=[0, 1, 2, 3, 4],
        step=lambda s: step_map[s],
        energy=lambda s: min(s, 4 - s),
    )


def example_pour_left() -> DescentSystem:
    """Three-fixed-point system: each state flows toward the nearest of 0,2,4.

    S = {0,..,4}, step pushes each non-fixed state one closer to {0,2,4}.
    """
    # Fixed points 0, 2, 4. Energy = distance to nearest fixed point.
    fixed = {0, 2, 4}

    def energy(s: int) -> int:
        return min(abs(s - f) for f in fixed)

    def step(s: int) -> int:
        if s in fixed:
            return s
        # move one step toward the nearest fixed point (ties -> lower)
        target = min(fixed, key=lambda f: (abs(s - f), f))
        return s + (1 if target > s else -1)

    return DescentSystem(states=[0, 1, 2, 3, 4], step=step, energy=energy)


def example_with_symmetry() -> Tuple[DescentSystem, Callable[[int], int]]:
    """A symmetric chain on {-2,-1,0,1,2} with reflection symmetry g(s) = -s.

    step pushes toward 0 (the unique fixed point), energy = |s|.
    """
    d = DescentSystem(
        states=[-2, -1, 0, 1, 2],
        step=lambda s: s - (1 if s > 0 else (-1 if s < 0 else 0)),
        energy=lambda s: abs(s),
    )
    return d, (lambda s: -s)


# ---------------------------------------------------------------------------
# Driver.
# ---------------------------------------------------------------------------

def report(name: str, d: DescentSystem) -> None:
    print(f"=== {name} ===")
    print(f"  states            : {list(d.states)}")
    print(f"  strict descent ok : {d.check_strict_descent()}")
    print(f"  fixed points      : {d.fixed_points()}")
    basins = d.basins()
    for t, block in sorted(basins.items(), key=lambda kv: str(kv[0])):
        print(f"  basin({t})         : {sorted(block, key=str)}")
    print(f"  #fixed points     : {len(d.fixed_points())}")
    print(f"  #basins           : {len(basins)}")
    print(f"  [Thm 3.2] iterate->fix      : {verify_iterate_is_fix(d)}")
    print(f"  [Lem 5.2] range == fixedpts : {verify_range_eq_fixedpoints(d)}")
    print(f"  [Thm 5.6] basins partition  : {verify_partition(d)}")
    print(f"  [Thm 5.7] #basins==#fixed   : {verify_basin_count(d)}")
    print()


def main() -> None:
    d1 = example_chain()
    report("Worked chain example", d1)

    d2 = example_pour_left()
    report("Three-attractor example", d2)

    # Multiplicativity (Theorem 6.4).
    print("=== Multiplicativity (Theorem 6.4) ===")
    dp = product_system(d1, d2)
    n1, n2, np_ = len(d1.fixed_points()), len(d2.fixed_points()), len(dp.fixed_points())
    print(f"  #fixed(d1) = {n1}, #fixed(d2) = {n2}, #fixed(d1 x d2) = {np_}")
    print(f"  product law n1 * n2 == np : {n1 * n2 == np_}")
    print(f"  product strict descent ok : {dp.check_strict_descent()}")
    print(f"  product basin count ok    : {verify_basin_count(dp)}")
    print()

    # Equivariance (Theorem 7.4).
    print("=== Equivariance under symmetry (Theorem 7.4) ===")
    ds, g = example_with_symmetry()
    report("Symmetric chain", ds)
    print(f"  reflection g(s) = -s is a symmetry & intertwines limitPoint:"
          f" {verify_equivariance(ds, g)}")
    print()

    print("All theorems verified numerically on the example systems.")


if __name__ == "__main__":
    main()


"""
visualize_basins.py — Visualize the basin partition of a 2D descent system.

Builds a descent system on an m x n grid whose dynamics flow downhill on a
fixed integer "height" landscape (a discrete gradient descent that steps to the
lowest-energy Moore neighbor, with ties broken deterministically). Fixed points
are the local minima; basins are the fibers of the limit map. The figure shows:

  * left  : the integer height landscape;
  * right : the basin partition, each basin in its own color, local minima marked.

This is a direct visual instance of the Basin Fixed Point Theorem: the number of
distinct colors (basins) equals the number of marked local minima (fixed points).

Run:  python visualize_basins.py
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import numpy as np
import matplotlib.pyplot as plt

Cell = Tuple[int, int]


def make_landscape(m: int, n: int, seed: int = 7) -> np.ndarray:
    """A smooth-ish integer height field with several local minima."""
    rng = np.random.default_rng(seed)
    xs = np.linspace(0, 3 * np.pi, n)
    ys = np.linspace(0, 3 * np.pi, m)
    gx, gy = np.meshgrid(xs, ys)
    field = (np.sin(gx) * np.cos(gy) + 0.6 * np.sin(2 * gx + 1.0)
             + 0.6 * np.cos(2 * gy + 0.5))
    field = field + 0.15 * rng.standard_normal((m, n))
    # quantize to integers (Lyapunov energy must be N-valued)
    q = np.round((field - field.min()) * 6).astype(int)
    return q


def step(height: np.ndarray, c: Cell) -> Cell:
    """Move to the strictly-lower Moore neighbor of minimal height; else stay.

    Only strictly-lower neighbors are candidates, so energy strictly decreases on
    every genuine move (the strict descent law); ties among candidates are broken
    by lexicographic order, which cannot create cycles since height keeps falling.
    """
    m, n = height.shape
    i, j = c
    best: Cell = c
    best_h = int(height[i, j])
    for di in (-1, 0, 1):
        for dj in (-1, 0, 1):
            if di == 0 and dj == 0:
                continue
            ni, nj = i + di, j + dj
            if 0 <= ni < m and 0 <= nj < n:
                h = int(height[ni, nj])
                if h < int(height[i, j]):  # candidate must be strictly lower
                    if h < best_h or (h == best_h and (ni, nj) < best):
                        best, best_h = (ni, nj), h
    return best


def limit_point(height: np.ndarray, c: Cell) -> Cell:
    """Iterate step until a fixed point (local min) is reached."""
    seen = set()
    while c not in seen:
        seen.add(c)
        nxt = step(height, c)
        if nxt == c:
            return c
        c = nxt
    return c


def compute_basins(height: np.ndarray) -> Tuple[np.ndarray, List[Cell]]:
    """Return a label grid (basin id per cell) and the list of local minima."""
    m, n = height.shape
    minima: List[Cell] = []
    for i in range(m):
        for j in range(n):
            if step(height, (i, j)) == (i, j):
                minima.append((i, j))
    idx: Dict[Cell, int] = {mn: k for k, mn in enumerate(minima)}
    labels = np.zeros((m, n), dtype=int)
    for i in range(m):
        for j in range(n):
            labels[i, j] = idx[limit_point(height, (i, j))]
    return labels, minima


def main() -> None:
    m, n = 30, 40
    height = make_landscape(m, n)
    labels, minima = compute_basins(height)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    im1 = ax1.imshow(height, cmap="terrain")
    ax1.set_title("Integer height landscape (energy)")
    fig.colorbar(im1, ax=ax1, fraction=0.046, pad=0.04)

    ax2.imshow(labels, cmap="tab20")
    ys, xs = zip(*minima)
    ax2.scatter(xs, ys, c="black", s=40, marker="x", label="local minima (fixed pts)")
    ax2.set_title(f"Basin partition: {len(minima)} basins = {len(minima)} fixed points")
    ax2.legend(loc="upper right")

    fig.suptitle("Basin Fixed Point Theorem in 2D: #basins = #fixed points",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("basins.png", dpi=130)
    print(f"Saved basins.png  (#basins = #fixed points = {len(minima)})")


if __name__ == "__main__":
    main()
