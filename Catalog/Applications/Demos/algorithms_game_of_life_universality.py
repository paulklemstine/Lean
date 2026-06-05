#!/usr/bin/env python3
"""
Algorithms for Simulation Morphism Theory and Game of Life

Provides type-hinted implementations of the core mathematical structures
and algorithms developed in the Lean 4 formalization.
"""

from dataclasses import dataclass, field
from typing import (
    TypeVar, Generic, Callable, Set, Tuple, Dict, List, Optional, FrozenSet
)
from functools import reduce
import operator

# ============================================================
# Core Types
# ============================================================

Cell = Tuple[int, int]
GridConfig = FrozenSet[Cell]

S = TypeVar('S')
T = TypeVar('T')
U = TypeVar('U')


MOORE_OFFSETS: List[Cell] = [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1),           (0, 1),
    (1, -1),  (1, 0),  (1, 1),
]


# ============================================================
# Discrete Dynamical System
# ============================================================

@dataclass(frozen=True)
class DiscreteDynSys(Generic[S]):
    """A discrete dynamical system: a step function on a state space."""
    step: Callable[[S], S]

    def orbit(self, s: S, n: int) -> List[S]:
        """Compute the orbit of s for n steps."""
        trajectory = [s]
        for _ in range(n):
            s = self.step(s)
            trajectory.append(s)
        return trajectory

    def iterate(self, s: S, n: int) -> S:
        """Apply step n times."""
        for _ in range(n):
            s = self.step(s)
        return s

    def is_fixed_point(self, s: S) -> bool:
        """Check if s is a fixed point."""
        return self.step(s) == s

    def find_period(self, s: S, max_steps: int = 10000) -> Optional[int]:
        """Find the period of s, or None if not found within max_steps."""
        current = s
        for i in range(1, max_steps + 1):
            current = self.step(current)
            if current == s:
                return i
        return None


# ============================================================
# Simulation Morphism
# ============================================================

@dataclass(frozen=True)
class SimMorphism(Generic[S, T]):
    """A simulation morphism from system A to system B.

    Satisfies:
    - faithful: B.step^[dilation](encode(s)) = encode(A.step(s))
    - retract: decode(encode(s)) = s
    """
    source: DiscreteDynSys[S]
    target: DiscreteDynSys[T]
    encode: Callable[[S], T]
    decode: Callable[[T], S]
    dilation: int  # positive

    def verify_faithful(self, s: S) -> bool:
        """Check faithfulness for a single state."""
        lhs = self.target.iterate(self.encode(s), self.dilation)
        rhs = self.encode(self.source.step(s))
        return lhs == rhs

    def verify_retract(self, s: S) -> bool:
        """Check retract for a single state."""
        return self.decode(self.encode(s)) == s

    def faithful_n(self, s: S, n: int) -> bool:
        """Verify multi-step faithfulness for n steps."""
        lhs = self.decode(self.target.iterate(self.encode(s), n * self.dilation))
        rhs = self.source.iterate(s, n)
        return lhs == rhs

    @staticmethod
    def identity(sys: DiscreteDynSys[S]) -> 'SimMorphism[S, S]':
        """The identity simulation morphism."""
        return SimMorphism(
            source=sys, target=sys,
            encode=lambda s: s, decode=lambda s: s,
            dilation=1
        )

    def compose(self, other: 'SimMorphism[T, U]') -> 'SimMorphism[S, U]':
        """Compose with another morphism. Dilation multiplies."""
        return SimMorphism(
            source=self.source,
            target=other.target,
            encode=lambda s: other.encode(self.encode(s)),
            decode=lambda t: self.decode(other.decode(t)),
            dilation=self.dilation * other.dilation
        )


# ============================================================
# Game of Life
# ============================================================

def live_neighbor_count(cfg: GridConfig, p: Cell) -> int:
    """Count live neighbors of cell p."""
    return sum(1 for dx, dy in MOORE_OFFSETS if (p[0]+dx, p[1]+dy) in cfg)


def gol_cell_update(cfg: GridConfig, p: Cell) -> bool:
    """GoL update rule for a single cell."""
    n = live_neighbor_count(cfg, p)
    if p in cfg:
        return n in (2, 3)
    else:
        return n == 3


def gol_step(cfg: GridConfig) -> GridConfig:
    """One step of Conway's Game of Life."""
    candidates: Set[Cell] = set()
    for x, y in cfg:
        candidates.add((x, y))
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
    return frozenset(p for p in candidates if gol_cell_update(cfg, p))


GoLSystem = DiscreteDynSys[GridConfig](step=gol_step)


# ============================================================
# GoL Patterns
# ============================================================

def block(corner: Cell = (0, 0)) -> GridConfig:
    """2x2 block still life."""
    x, y = corner
    return frozenset({(x,y), (x+1,y), (x,y+1), (x+1,y+1)})


def blinker_h(center: Cell = (0, 0)) -> GridConfig:
    """Horizontal blinker (period 2)."""
    x, y = center
    return frozenset({(x-1,y), (x,y), (x+1,y)})


def glider(corner: Cell = (0, 0)) -> GridConfig:
    """Glider (period 4, translates by (1,1))."""
    x, y = corner
    return frozenset({(x+1,y), (x+2,y+1), (x,y+2), (x+1,y+2), (x+2,y+2)})


def translate_config(cfg: GridConfig, d: Cell) -> GridConfig:
    """Translate configuration by offset d."""
    return frozenset((x+d[0], y+d[1]) for x, y in cfg)


# ============================================================
# Simulation Chain Analysis
# ============================================================

@dataclass
class SimChain:
    """A chain of simulation morphisms with tracked overhead."""
    layers: List[int]  # dilation of each layer

    @property
    def depth(self) -> int:
        return len(self.layers)

    @property
    def total_dilation(self) -> int:
        return reduce(operator.mul, self.layers, 1)

    def complexity_bound(self, max_dilation: int) -> int:
        """Upper bound: max_dilation^depth."""
        return max_dilation ** self.depth

    def verify_bound(self) -> bool:
        """Verify that product ≤ max^depth."""
        if not self.layers:
            return True
        d = max(self.layers)
        return self.total_dilation <= d ** self.depth


def dilation_chain_bound(dilations: List[int]) -> Tuple[int, int]:
    """
    Compute the exact dilation and the d^n upper bound.

    Returns (product, d^n) where d = max(dilations), n = len(dilations).
    Corresponds to theorem dilation_chain_bound.
    """
    if not dilations:
        return (1, 1)
    d = max(dilations)
    n = len(dilations)
    product = reduce(operator.mul, dilations, 1)
    bound = d ** n
    return (product, bound)


# ============================================================
# Non-Monotonicity Witness
# ============================================================

def find_non_monotonicity_witness() -> Optional[Tuple[GridConfig, GridConfig, Cell]]:
    """
    Find a constructive witness that GoL is not monotone.

    Returns (a, b, p) where a ⊆ b but golStep(a)(p) and not golStep(b)(p).
    """
    # Disk configuration
    a = frozenset((x,y) for x in range(-1,2) for y in range(-1,2) if x*x+y*y <= 1)
    b = a | frozenset({(1, 1)})

    stepped_a = gol_step(a)
    stepped_b = gol_step(b)

    for p in stepped_a:
        if p not in stepped_b:
            return (a, b, p)
    return None


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # Verify block is still life
    b = block()
    assert GoLSystem.is_fixed_point(b), "Block should be a still life"
    print("✓ Block is a still life")

    # Verify blinker period
    bl = blinker_h()
    period = GoLSystem.find_period(bl)
    assert period == 2, f"Blinker should have period 2, got {period}"
    print(f"✓ Blinker has period {period}")

    # Verify glider period (with translation)
    g = glider()
    g4 = GoLSystem.iterate(g, 4)
    assert g4 == translate_config(g, (1, 1)), "Glider should translate (1,1) in 4 steps"
    print("✓ Glider translates (1,1) in 4 steps")

    # Translation invariance
    d = (100, -50)
    cfg = blinker_h()
    assert gol_step(translate_config(cfg, d)) == translate_config(gol_step(cfg), d)
    print("✓ Translation invariance verified")

    # Non-monotonicity
    witness = find_non_monotonicity_witness()
    assert witness is not None, "Should find non-monotonicity witness"
    a, b, p = witness
    print(f"✓ Non-monotonicity witness: cell {p}")

    # Dilation chain bound
    product, bound = dilation_chain_bound([100, 50, 1000])
    assert product <= bound
    print(f"✓ Dilation chain: {product:,} ≤ {bound:,}")

    # Finite support preservation
    cfg = frozenset({(0,0), (1,0), (-1,1), (0,1), (0,2)})  # R-pentomino
    for t in range(100):
        cfg = gol_step(cfg)
        assert len(cfg) < 10**6, "Support should remain finite"
    print(f"✓ Finite support preserved over 100 steps (pop={len(cfg)})")

    print("\nAll algorithm tests passed!")
