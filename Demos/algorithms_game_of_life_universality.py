#!/usr/bin/env python3
"""
Game of Life Universality — Core Algorithms

Type-hinted implementations of the key algorithms and data structures
used in the formalization.
"""

from typing import FrozenSet, Tuple, Optional, Dict, Set, List, Callable
from collections import Counter
from dataclasses import dataclass

# ═══════════════════════════════════════════
# Type Definitions
# ═══════════════════════════════════════════

Cell = Tuple[int, int]
Board = FrozenSet[Cell]
BoolFn = Callable[[Tuple[bool, ...]], bool]


# ═══════════════════════════════════════════
# Algorithm 1: Game of Life Evolution
# ═══════════════════════════════════════════

def gol_step(board: Board) -> Board:
    """
    Conway's Game of Life step function.

    Pseudocode:
        neighbors ← count adjacent alive cells for all cells near the board
        new_board ← { p : neighbors[p] == 3 or (neighbors[p] == 2 and p alive) }
        return new_board

    Time: O(|board|)
    Space: O(|board|)
    """
    neighbor_count: Counter = Counter()
    for (x, y) in board:
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                if dx or dy:
                    neighbor_count[(x + dx, y + dy)] += 1

    return frozenset(
        cell for cell, count in neighbor_count.items()
        if count == 3 or (count == 2 and cell in board)
    )


def gol_evolve(board: Board, steps: int) -> Board:
    """Iterate the step function."""
    for _ in range(steps):
        board = gol_step(board)
    return board


# ═══════════════════════════════════════════
# Algorithm 2: Light Cone Computation
# ═══════════════════════════════════════════

def chebyshev_distance(p: Cell, q: Cell) -> int:
    """Chebyshev (L∞) distance between two cells."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def chebyshev_ball(center: Cell, radius: int) -> Set[Cell]:
    """
    All cells within Chebyshev distance `radius` of `center`.

    Pseudocode:
        return { (x, y) : |x - cx| ≤ r and |y - cy| ≤ r }

    Size: (2r+1)²
    """
    cx, cy = center
    return {
        (x, y)
        for x in range(cx - radius, cx + radius + 1)
        for y in range(cy - radius, cy + radius + 1)
    }


def light_cone_check(board: Board, cell: Cell, t: int) -> bool:
    """
    Verify the light cone theorem: the state at `cell` after `t` steps
    depends only on cells within Chebyshev distance `t`.

    Creates a restricted board (only cells within the cone) and
    checks that evolution gives the same result.
    """
    cone = chebyshev_ball(cell, t)
    restricted = board & cone  # Only keep cells within the cone
    full_result = gol_evolve(board, t)
    restricted_result = gol_evolve(restricted, t)
    return (cell in full_result) == (cell in restricted_result)


# ═══════════════════════════════════════════
# Algorithm 3: Spaceship Detection
# ═══════════════════════════════════════════

@dataclass
class SpaceshipInfo:
    """Information about a detected spaceship."""
    period: int
    velocity: Cell
    speed: float  # max(|vx|, |vy|) / period

    @property
    def direction(self) -> str:
        vx, vy = self.velocity
        if vx == 0 and vy == 0:
            return "stationary"
        elif abs(vx) == abs(vy):
            return "diagonal"
        elif vx == 0 or vy == 0:
            return "orthogonal"
        else:
            return "oblique"


def translate_board(board: Board, v: Cell) -> Board:
    """Translate all cells by vector v."""
    return frozenset((x + v[0], y + v[1]) for (x, y) in board)


def detect_spaceship(
    board: Board,
    max_period: int = 100,
    max_speed: int = 1,
) -> Optional[SpaceshipInfo]:
    """
    Detect if a board pattern is a spaceship.

    Pseudocode:
        for t = 1 to max_period:
            current ← step^t(board)
            for each displacement v with |v|_∞ ≤ max_speed * t:
                if translate(current, -v) == board:
                    return SpaceshipInfo(t, v)
        return None

    Time: O(max_period² · |board|) average case
    """
    if not board:
        return None

    current = board
    for t in range(1, max_period + 1):
        current = gol_step(current)
        max_disp = max_speed * t
        for dx in range(-max_disp, max_disp + 1):
            for dy in range(-max_disp, max_disp + 1):
                if (dx, dy) != (0, 0):
                    shifted = frozenset((x - dx, y - dy) for (x, y) in current)
                    if shifted == board:
                        speed = max(abs(dx), abs(dy)) / t
                        return SpaceshipInfo(t, (dx, dy), speed)
    return None


# ═══════════════════════════════════════════
# Algorithm 4: Periodic Orbit Detection
# ═══════════════════════════════════════════

@dataclass
class OrbitInfo:
    """Information about an orbit."""
    period: Optional[int]
    is_still_life: bool
    orbit_size: int  # Number of distinct configurations in the orbit


def analyze_orbit(board: Board, max_steps: int = 500) -> OrbitInfo:
    """
    Analyze the orbit of a board configuration.

    Pseudocode:
        seen ← {board: 0}
        current ← board
        for t = 1 to max_steps:
            current ← step(current)
            if current in seen:
                period ← t - seen[current]
                return OrbitInfo(period, period == 1 and t == 1, t)
            seen[current] ← t
        return OrbitInfo(None, False, max_steps)
    """
    seen: Dict[Board, int] = {board: 0}
    current = board
    for t in range(1, max_steps + 1):
        current = gol_step(current)
        if current in seen:
            period = t - seen[current]
            is_still = (period == 1 and seen[current] == 0)
            return OrbitInfo(period, is_still, len(seen))
        seen[current] = t
    return OrbitInfo(None, False, len(seen))


# ═══════════════════════════════════════════
# Algorithm 5: Simulation Composition
# ═══════════════════════════════════════════

@dataclass
class SimulationSpec:
    """Specification of a CA simulation with overhead."""
    name: str
    source_ca: str
    target_ca: str
    time_overhead: int

    def compose(self, other: 'SimulationSpec') -> 'SimulationSpec':
        """
        Compose two simulations.

        Theorem (Lean 4 verified):
            compose(sim₁₂, sim₂₃).timeOverhead
            = sim₁₂.timeOverhead * sim₂₃.timeOverhead
        """
        assert self.target_ca == other.source_ca, \
            f"Cannot compose: {self.target_ca} ≠ {other.source_ca}"
        return SimulationSpec(
            name=f"{self.name} ∘ {other.name}",
            source_ca=self.source_ca,
            target_ca=other.target_ca,
            time_overhead=self.time_overhead * other.time_overhead,
        )


def compute_chain_overhead(sims: List[SimulationSpec]) -> int:
    """
    Compute the total overhead of a simulation chain.

    Theorem (Lean 4 verified): Composition is associative.
    """
    if not sims:
        return 1
    result = sims[0]
    for sim in sims[1:]:
        result = result.compose(sim)
    return result.time_overhead


# ═══════════════════════════════════════════
# Algorithm 6: Finite Orbit Bound (Pigeonhole)
# ═══════════════════════════════════════════

def finite_orbit_collision(
    f: Callable, x: object, max_states: int
) -> Tuple[int, int]:
    """
    Find a collision in the orbit of x under f.

    By the pigeonhole principle (Lean 4 verified),
    within max_states + 1 steps, two iterates must coincide.

    Returns (t1, t2) with t1 < t2 and f^t1(x) = f^t2(x).
    """
    seen: Dict = {}
    current = x
    for t in range(max_states + 1):
        key = current if isinstance(current, (int, str, tuple, frozenset)) else id(current)
        if key in seen:
            return (seen[key], t)
        seen[key] = t
        current = f(current)
    raise RuntimeError("Pigeonhole principle violated (impossible)")


if __name__ == "__main__":
    # Quick self-test
    glider = frozenset([(0, 0), (1, 0), (2, 0), (2, 1), (1, 2)])
    info = detect_spaceship(glider)
    assert info is not None
    assert info.speed <= 1.0, f"Speed bound violated: {info.speed}"
    print(f"Glider: period={info.period}, velocity={info.velocity}, speed={info.speed:.4f}")

    blinker = frozenset([(0, 0), (1, 0), (2, 0)])
    orbit = analyze_orbit(blinker)
    assert orbit.period == 2
    print(f"Blinker: period={orbit.period}, still_life={orbit.is_still_life}")

    block = frozenset([(0, 0), (0, 1), (1, 0), (1, 1)])
    orbit = analyze_orbit(block)
    assert orbit.period == 1 and orbit.is_still_life
    print(f"Block: period={orbit.period}, still_life={orbit.is_still_life}")

    # Simulation composition test
    sim1 = SimulationSpec("GoL→R110", "GoL", "Rule110", 1000)
    sim2 = SimulationSpec("R110→TM", "Rule110", "TM", 500)
    composed = sim1.compose(sim2)
    assert composed.time_overhead == 500000
    print(f"Composition: {composed.name}, overhead={composed.time_overhead}")

    print("All self-tests passed ✓")
