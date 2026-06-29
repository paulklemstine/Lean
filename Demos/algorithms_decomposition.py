#!/usr/bin/env python3
"""
Algorithms for Directional Decomposition of Dragon Curve Dynamics.

Implements efficient algorithms for:
1. Dragon turn sequence generation
2. Displacement computation (O(n) direct, O(1) via direction counting)
3. Orbit equivalence testing
4. Periodicity detection
5. Displacement-based path compression
"""

from typing import List, Tuple, Dict, Optional, Set
from collections import Counter
import math


# ─── Direction Arithmetic ───────────────────────────────────────────

DIR_VEC = {0: (1, 0), 1: (0, 1), 2: (-1, 0), 3: (0, -1)}
DIR_NAMES = {0: "E", 1: "N", 2: "W", 3: "S"}


def turn_dir(d: int, turn: bool) -> int:
    """Update direction: right=(d+3)%4, left=(d+1)%4. O(1)."""
    return (d + 3) % 4 if turn else (d + 1) % 4


# ─── Algorithm 1: Dragon Turn Sequence ──────────────────────────────

def dragon_turns(n: int) -> List[bool]:
    """
    Generate dragon curve turn sequence at iteration n.

    Algorithm: Recursive definition.
      dragon(0) = []
      dragon(n+1) = dragon(n) ++ [R] ++ reverse_complement(dragon(n))

    Time: O(2^n), Space: O(2^n)
    Output length: 2^n - 1

    >>> len(dragon_turns(5))
    31
    """
    if n == 0:
        return []
    prev = dragon_turns(n - 1)
    return prev + [True] + [not b for b in reversed(prev)]


# ─── Algorithm 2: Visited Directions ────────────────────────────────

def visited_dirs(d: int, turns: List[bool]) -> List[int]:
    """
    Compute the sequence of directions visited during a walk.

    Time: O(n), Space: O(n) where n = len(turns)

    >>> visited_dirs(0, [True, True])
    [0, 3]
    """
    result = []
    for t in turns:
        result.append(d)
        d = turn_dir(d, t)
    return result


def final_dir(d: int, turns: List[bool]) -> int:
    """
    Compute final direction after processing turns.

    Time: O(n), Space: O(1)

    >>> final_dir(0, [True, True, True, True])
    0
    """
    for t in turns:
        d = turn_dir(d, t)
    return d


# ─── Algorithm 3: Total Displacement ───────────────────────────────

def total_disp(d: int, turns: List[bool]) -> Tuple[int, int]:
    """
    Compute total displacement by summing direction vectors.

    This is the core of the decomposition theorem:
      finalPos = initPos + totalDisp(initDir, turns)

    Time: O(n), Space: O(1)

    >>> total_disp(0, dragon_turns(4))
    (-4, 1)
    """
    dx, dy = 0, 0
    for t in turns:
        vx, vy = DIR_VEC[d]
        dx += vx
        dy += vy
        d = turn_dir(d, t)
    return (dx, dy)


def total_disp_via_counts(d: int, turns: List[bool]) -> Tuple[int, int]:
    """
    Compute displacement via direction counting (weighted sum formula).

    Uses the totalDisp_as_weighted_sum theorem:
      totalDisp = ∑_{d'} count(d') * dirVec(d')

    Time: O(n), Space: O(1)

    >>> total_disp_via_counts(0, dragon_turns(4))
    (-4, 1)
    """
    counts = Counter(visited_dirs(d, turns))
    dx = sum(counts.get(dd, 0) * DIR_VEC[dd][0] for dd in range(4))
    dy = sum(counts.get(dd, 0) * DIR_VEC[dd][1] for dd in range(4))
    return (dx, dy)


# ─── Algorithm 4: Orbit Equivalence ────────────────────────────────

def are_orbit_equivalent(d: int, ts1: List[bool], ts2: List[bool]) -> bool:
    """
    Test whether two turn sequences produce the same displacement
    (and hence the same position action on all starting points).

    Uses fold_eq_of_totalDisp_eq: equal displacement ⟹ equal orbit.

    Time: O(n1 + n2), Space: O(1)

    >>> are_orbit_equivalent(0, [True, True], [True, False])
    True
    """
    return total_disp(d, ts1) == total_disp(d, ts2)


# ─── Algorithm 5: Periodicity Detection ────────────────────────────

def is_periodic(d: int, turns: List[bool]) -> bool:
    """
    Test whether a turn sequence returns the walker to its starting position.

    Uses fold_fixed_iff_totalDisp_eq_zero: periodic ⟺ totalDisp = (0,0).

    Time: O(n), Space: O(1)

    >>> is_periodic(0, [True, True, True, True])  # 4 right turns = square
    True
    >>> is_periodic(0, [True, True])
    False
    """
    return total_disp(d, turns) == (0, 0)


# ─── Algorithm 6: Minimal Periodic Extension ───────────────────────

def find_periodic_extension(d: int, turns: List[bool],
                            max_repeats: int = 1000) -> Optional[int]:
    """
    Find the minimal k such that repeating `turns` k times is periodic.

    Returns k if found, None otherwise.
    Uses the periodicity criterion: check if k * totalDisp = (0,0).

    Time: O(n + max_repeats), Space: O(1)
    """
    disp = total_disp(d, turns)
    if disp == (0, 0):
        return 1

    # If displacement is nonzero, k*disp = (0,0) only if k=0
    # (since ℤ² is torsion-free). So repetition never returns to start
    # unless we also account for direction rotation.
    # We need k*disp = (0,0) AND finalDir^k(d) = d.
    fd = final_dir(d, turns)
    curr_d = d
    acc_dx, acc_dy = 0, 0
    for k in range(1, max_repeats + 1):
        # Displacement of turns starting from curr_d
        kdisp = total_disp(curr_d, turns)
        acc_dx += kdisp[0]
        acc_dy += kdisp[1]
        curr_d = final_dir(curr_d, turns)
        if acc_dx == 0 and acc_dy == 0 and curr_d == d:
            return k
    return None


# ─── Algorithm 7: Path Compression ─────────────────────────────────

class CompressedPath:
    """
    Compressed representation of a dragon path segment.

    Instead of storing the full turn sequence, stores:
    - direction counts (4 integers)
    - initial and final direction
    - total displacement

    This captures all position-relevant information while
    compressing O(2^n) turns into O(1) space.
    """

    def __init__(self, init_dir: int, turns: List[bool]):
        dirs = visited_dirs(init_dir, turns)
        self.init_dir = init_dir
        self.final_dir = final_dir(init_dir, turns)
        self.counts = Counter(dirs)
        self.disp = total_disp(init_dir, turns)
        self.length = len(turns)

    def apply(self, pos: Tuple[int, int]) -> Tuple[int, int]:
        """Apply compressed path to a position. O(1)."""
        return (pos[0] + self.disp[0], pos[1] + self.disp[1])

    def compose(self, other: 'CompressedPath') -> 'CompressedPath':
        """
        Compose two compressed paths (concatenation).
        Uses totalDisp_append theorem.
        """
        result = CompressedPath.__new__(CompressedPath)
        result.init_dir = self.init_dir
        result.final_dir = other.final_dir
        result.counts = self.counts + other.counts
        result.disp = (self.disp[0] + other.disp[0],
                       self.disp[1] + other.disp[1])
        result.length = self.length + other.length
        return result

    def __repr__(self):
        c = {DIR_NAMES[d]: self.counts.get(d, 0) for d in range(4)}
        return (f"CompressedPath(len={self.length}, "
                f"dir={DIR_NAMES[self.init_dir]}→{DIR_NAMES[self.final_dir]}, "
                f"disp={self.disp}, counts={c})")


# ─── Algorithm 8: Displacement Lattice Analysis ────────────────────

def reachable_displacements(d: int, max_length: int) -> Set[Tuple[int, int]]:
    """
    Compute all displacements reachable by turn sequences up to given length.

    Shows that the reachable set is generated by direction vectors
    (exists_count_representation theorem).

    Time: O(2^max_length), Space: O(number of distinct displacements)
    """
    disps = {(0, 0)}  # empty word
    from itertools import product
    for length in range(1, max_length + 1):
        for turns in product([True, False], repeat=length):
            disps.add(total_disp(d, list(turns)))
    return disps


# ─── Main ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Dragon turns
    for n in range(1, 8):
        turns = dragon_turns(n)
        print(f"Dragon turns n={n}: length={len(turns)}, "
              f"disp={total_disp(0, turns)}")

    # Compression demo
    print("\n--- Path Compression ---")
    for n in range(1, 9):
        turns = dragon_turns(n)
        cp = CompressedPath(0, turns)
        print(f"  n={n}: {cp}")
        # Verify compression
        pos_direct = (0, 0)
        d = 0
        for t in turns:
            dx, dy = DIR_VEC[d]
            pos_direct = (pos_direct[0] + dx, pos_direct[1] + dy)
            d = turn_dir(d, t)
        assert cp.apply((0, 0)) == pos_direct, "Compression error!"

    # Periodicity
    print("\n--- Periodicity Detection ---")
    test_seqs = [
        ("4 rights", [True]*4),
        ("RLRL", [True, False, True, False]),
        ("RLLR", [True, False, False, True]),
        ("dragon(2)", dragon_turns(2)),
    ]
    for name, turns in test_seqs:
        p = is_periodic(0, turns)
        k = find_periodic_extension(0, turns)
        print(f"  {name}: periodic={p}, min_periodic_rep={k}")

    # Orbit classes
    print("\n--- Orbit Equivalence Classes (length 3, starting East) ---")
    from itertools import product
    classes: Dict[Tuple[int, int], List[str]] = {}
    for turns in product([True, False], repeat=3):
        tl = list(turns)
        disp = total_disp(0, tl)
        label = "".join("R" if t else "L" for t in tl)
        classes.setdefault(disp, []).append(label)
    for disp, words in sorted(classes.items()):
        print(f"  disp={disp}: {words}")

    # Reachable displacements
    print("\n--- Reachable Displacements (length ≤ 4, starting East) ---")
    disps = reachable_displacements(0, 4)
    print(f"  {len(disps)} distinct displacements reachable")
    print(f"  Range: x∈[{min(d[0] for d in disps)},{max(d[0] for d in disps)}], "
          f"y∈[{min(d[1] for d in disps)},{max(d[1] for d in disps)}]")
