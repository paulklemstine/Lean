"""
Registers, gap graphs, and the failure of strong connectivity for
frozen-bass first-species counterpoint.

Self-contained numerical demonstration of every quantitative claim:

  1. The register partition of the consonance ladder {0,3,4,7,8,9,12}
     into the four blocks {0}, {3,4}, {7,8,9}, {12}.
  2. Register completeness: a legal frozen-bass motion i -> j exists iff
     register(i) == register(j).
  3. Idempotence of transitive closure, and the census 15 reachable /
     34 unreachable ordered pairs out of 49.
  4. The sharp threshold: strong connectivity holds iff the melodic step
     width w satisfies w >= 3.
  5. The general gap criterion on arbitrary finite integer sets, applied
     to several tunings to compute their critical melodic widths.
  6. The free-bass repair: an explicit contrary-motion spine realizing all
     seven consonances, verified against the full first-species rule set.
  7. The exact free-bass distance from unison to octave: exactly 3 motions
     (breadth-first search, matching the 4-semitones-per-step potential bound).

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# The pitch model
# ---------------------------------------------------------------------------

Dyad = Tuple[int, int]  # (lower voice pitch, upper voice pitch), in semitones

CONSONANCE_NAMES: List[str] = [
    "unison",
    "minor third",
    "major third",
    "perfect fifth",
    "minor sixth",
    "major sixth",
    "octave",
]

LADDER: List[int] = [0, 3, 4, 7, 8, 9, 12]
PERFECT: Set[int] = {0, 7, 12}
SEMITONES: Dict[str, int] = dict(zip(CONSONANCE_NAMES, LADDER))

STEP_WIDTH: int = 2  # classical first-species melodic bound: a whole tone


def vertical_interval(x: Dyad) -> int:
    """The vertical interval of a dyad: upper voice minus lower voice."""
    return x[1] - x[0]


def is_consonant(x: Dyad) -> bool:
    """A dyad is consonant when its vertical interval is a simple consonance."""
    return vertical_interval(x) in set(LADDER)


def is_perfect(x: Dyad) -> bool:
    """Perfect consonances: unison, perfect fifth, octave."""
    return vertical_interval(x) in PERFECT


def is_stepwise(x: Dyad, y: Dyad, width: int = STEP_WIDTH) -> bool:
    """Each voice moves melodically by at most `width` semitones."""
    return abs(y[0] - x[0]) <= width and abs(y[1] - x[1]) <= width


def is_similar_motion(x: Dyad, y: Dyad) -> bool:
    """Both voices move strictly in the same direction."""
    d_lo = y[0] - x[0]
    d_hi = y[1] - x[1]
    return (d_lo > 0 and d_hi > 0) or (d_lo < 0 and d_hi < 0)


def permitted_motion(x: Dyad, y: Dyad, width: int = STEP_WIDTH) -> bool:
    """The full first-species one-step rule.

    Both sonorities consonant, both voices stepwise, and no similar motion
    into a perfect consonance (no direct or parallel fifths and octaves).
    """
    if not is_consonant(x) or not is_consonant(y):
        return False
    if not is_stepwise(x, y, width):
        return False
    if is_perfect(y) and is_similar_motion(x, y):
        return False
    return True


# ---------------------------------------------------------------------------
# 1-3.  Frozen bass: registers, completeness, census
# ---------------------------------------------------------------------------


def canonical(name: str) -> Dyad:
    """Canonical representative of an interval: lower voice frozen at pitch 0."""
    return (0, SEMITONES[name])


def canonical_motion(i: str, j: str) -> bool:
    """One legal motion between canonical (frozen-bass) representatives."""
    return permitted_motion(canonical(i), canonical(j))


def register_blocks(ladder: Sequence[int], width: int) -> List[List[int]]:
    """Partition a sorted integer ladder at every consecutive gap exceeding `width`.

    These blocks are exactly the connected components of the gap graph.
    """
    values = sorted(ladder)
    blocks: List[List[int]] = [[values[0]]]
    for prev, nxt in zip(values, values[1:]):
        if nxt - prev > width:
            blocks.append([nxt])
        else:
            blocks[-1].append(nxt)
    return blocks


def register_of(interval: int, blocks: Sequence[Sequence[int]]) -> int:
    """Index of the block containing a given interval."""
    for index, block in enumerate(blocks):
        if interval in block:
            return index
    raise ValueError(f"{interval} is not on the ladder")


def transitive_closure(
    states: Sequence[str], edge: "object"
) -> Set[Tuple[str, str]]:
    """Reflexive-transitive closure of a binary relation on a finite state set."""
    pairs: Set[Tuple[str, str]] = {(s, s) for s in states}
    for a, b in product(states, repeat=2):
        if edge(a, b):  # type: ignore[operator]
            pairs.add((a, b))
    changed = True
    while changed:
        changed = False
        for (a, b), (c, d) in product(list(pairs), repeat=2):
            if b == c and (a, d) not in pairs:
                pairs.add((a, d))
                changed = True
    return pairs


def demo_registers_and_census() -> None:
    print("=" * 72)
    print("1-3.  FROZEN BASS: REGISTERS, COMPLETENESS, CENSUS")
    print("=" * 72)

    gaps = [b - a for a, b in zip(LADDER, LADDER[1:])]
    print(f"consonance ladder      : {LADDER}")
    print(f"consecutive gaps       : {gaps}   (maximum {max(gaps)})")

    blocks = register_blocks(LADDER, STEP_WIDTH)
    print(f"registers at width {STEP_WIDTH}   : {blocks}")
    assert blocks == [[0], [3, 4], [7, 8, 9], [12]]
    assert len(blocks) == 4

    # Register completeness on the whole 7x7 table.
    for i, j in product(CONSONANCE_NAMES, repeat=2):
        same = register_of(SEMITONES[i], blocks) == register_of(SEMITONES[j], blocks)
        assert canonical_motion(i, j) == same, (i, j)
    print("register completeness  : verified on all 49 ordered pairs")

    # The one-step table is already an equivalence relation.
    refl = all(canonical_motion(i, i) for i in CONSONANCE_NAMES)
    symm = all(
        canonical_motion(i, j) == canonical_motion(j, i)
        for i, j in product(CONSONANCE_NAMES, repeat=2)
    )
    trans = all(
        not (canonical_motion(i, j) and canonical_motion(j, k)) or canonical_motion(i, k)
        for i, j, k in product(CONSONANCE_NAMES, repeat=3)
    )
    print(f"one-step relation      : reflexive={refl} symmetric={symm} transitive={trans}")
    assert refl and symm and trans

    one_step = {
        (i, j) for i, j in product(CONSONANCE_NAMES, repeat=2) if canonical_motion(i, j)
    }
    closed = transitive_closure(CONSONANCE_NAMES, canonical_motion)
    print(f"closure is idempotent  : {closed == one_step}")
    assert closed == one_step

    total = len(CONSONANCE_NAMES) ** 2
    reachable = len(closed)
    print(f"reachable ordered pairs: {reachable} of {total}")
    print(f"unreachable pairs      : {total - reachable}")
    assert (reachable, total - reachable) == (15, 34)
    assert reachable == sum(len(b) ** 2 for b in blocks)

    print(f"unison -> octave       : reachable = {('unison', 'octave') in closed}")
    assert ("unison", "octave") not in closed

    print("\nreachability table (rows = source, '*' = reachable):")
    head = "              " + " ".join(f"{n[:4]:>4}" for n in CONSONANCE_NAMES)
    print(head)
    for i in CONSONANCE_NAMES:
        row = " ".join(f"{'*' if (i, j) in closed else '.':>4}" for j in CONSONANCE_NAMES)
        print(f"{i:>13} {row}")
    print()


# ---------------------------------------------------------------------------
# 4-5.  The threshold and the general gap criterion
# ---------------------------------------------------------------------------


def gap_graph_connected(ladder: Sequence[int], width: int) -> bool:
    """Is the gap graph on `ladder` with hop bound `width` connected?

    Computed by explicit breadth-first search, independently of the criterion.
    """
    values = sorted(ladder)
    if not values:
        return True
    seen = {values[0]}
    frontier = [values[0]]
    while frontier:
        current = frontier.pop()
        for candidate in values:
            if candidate not in seen and abs(candidate - current) <= width:
                seen.add(candidate)
                frontier.append(candidate)
    return len(seen) == len(values)


def critical_width(ladder: Sequence[int]) -> int:
    """Least hop bound making the gap graph connected: the maximal consecutive gap."""
    values = sorted(ladder)
    return max((b - a for a, b in zip(values, values[1:])), default=0)


def demo_threshold() -> None:
    print("=" * 72)
    print("4-5.  SHARP THRESHOLD AND THE GENERAL GAP CRITERION")
    print("=" * 72)

    for w in range(7):
        connected = gap_graph_connected(LADDER, w)
        blocks = register_blocks(LADDER, w)
        flag = "connected" if connected else f"{len(blocks)} components"
        print(f"  width w = {w}: {flag:<15} predicted connected: {w >= 3}")
        assert connected == (w >= 3)

    print(f"\ncritical width of the classical ladder = {critical_width(LADDER)}")
    assert critical_width(LADDER) == 3
    print("historical first-species width = 2, i.e. one semitone subcritical\n")

    tunings: Dict[str, List[int]] = {
        "classical simple consonances": LADDER,
        "triadic subset {0,4,7,12}": [0, 4, 7, 12],
        "diatonic scale (major)": [0, 2, 4, 5, 7, 9, 11, 12],
        "pentatonic scale": [0, 2, 4, 7, 9, 12],
        "whole-tone scale": [0, 2, 4, 6, 8, 10, 12],
        "chromatic scale": list(range(13)),
        "octatonic scale": [0, 2, 3, 5, 6, 8, 9, 11, 12],
    }
    print("critical melodic width of assorted pitch sets (max consecutive gap):")
    for name, pitches in tunings.items():
        w_c = critical_width(pitches)
        # the criterion agrees with brute-force search at w_c and at w_c - 1
        assert gap_graph_connected(pitches, w_c)
        assert w_c == 0 or not gap_graph_connected(pitches, w_c - 1)
        print(f"  {name:<30} critical width = {w_c}")
    print()


# ---------------------------------------------------------------------------
# 6-7.  The free-bass repair and the exact unison-to-octave distance
# ---------------------------------------------------------------------------

SPINE: List[Dyad] = [(0, 0), (-1, 2), (-1, 3), (-2, 5), (-2, 6), (-2, 7), (-3, 9)]
GEODESIC: List[Dyad] = [(0, 0), (-2, 2), (-4, 4), (-6, 6)]


def check_path(path: Sequence[Dyad]) -> bool:
    """Is every consecutive transition of a dyad path a permitted motion?"""
    return all(permitted_motion(x, y) for x, y in zip(path, path[1:]))


def bfs_interval_distance(
    start: Dyad, target_interval: int, bound: int = 14
) -> Optional[int]:
    """Fewest permitted motions from `start` to any dyad of the target interval.

    Search is restricted to dyads whose voices lie within +-`bound` semitones of
    the origin; the potential bound of 4 semitones of interval change per motion
    guarantees no shorter path escapes this window.
    """
    if vertical_interval(start) == target_interval:
        return 0
    frontier: List[Dyad] = [start]
    seen: Set[Dyad] = {start}
    distance = 0
    while frontier:
        distance += 1
        nxt: List[Dyad] = []
        for x in frontier:
            for d_lo, d_hi in product(range(-STEP_WIDTH, STEP_WIDTH + 1), repeat=2):
                y = (x[0] + d_lo, x[1] + d_hi)
                if abs(y[0]) > bound or abs(y[1]) > bound or y in seen:
                    continue
                if not permitted_motion(x, y):
                    continue
                if vertical_interval(y) == target_interval:
                    return distance
                seen.add(y)
                nxt.append(y)
        frontier = nxt
    return None


def max_interval_change() -> int:
    """Largest interval change achievable in one permitted motion."""
    best = 0
    for x in [(b, b + s) for b in range(-3, 4) for s in LADDER]:
        for d_lo, d_hi in product(range(-STEP_WIDTH, STEP_WIDTH + 1), repeat=2):
            y = (x[0] + d_lo, x[1] + d_hi)
            if permitted_motion(x, y):
                best = max(best, abs(vertical_interval(y) - vertical_interval(x)))
    return best


def demo_free_bass() -> None:
    print("=" * 72)
    print("6-7.  FREE BASS: REPAIR AND EXACT DISTANCE")
    print("=" * 72)

    intervals = [vertical_interval(x) for x in SPINE]
    print(f"contrary-motion spine  : {SPINE}")
    print(f"vertical intervals     : {intervals}")
    assert intervals == LADDER
    print(f"every transition legal : {check_path(SPINE)}")
    assert check_path(SPINE)

    # Symmetry of the one-step rule, hence of reachability.
    symmetric = all(
        permitted_motion(x, y) == permitted_motion(y, x)
        for x, y in zip(SPINE, SPINE[1:])
    )
    print(f"spine is retrogradable : {symmetric}")
    assert symmetric
    print("=> all seven consonances are mutually reachable with a free bass\n")

    print(f"max interval change per motion (search) : {max_interval_change()}")
    assert max_interval_change() == 4
    print("potential bound: after n motions the interval has moved at most 4n,")
    print("so joining interval 0 to interval 12 requires n >= 3.")

    print(f"\ngeodesic path          : {GEODESIC}")
    print(f"vertical intervals     : {[vertical_interval(x) for x in GEODESIC]}")
    assert [vertical_interval(x) for x in GEODESIC] == [0, 4, 8, 12]
    assert check_path(GEODESIC)

    d = bfs_interval_distance((0, 0), 12)
    print(f"breadth-first distance unison -> octave : {d}")
    assert d == 3
    print("matches the lower bound: the free-bass distance is exactly 3.\n")

    print("free-bass distance from the unison to every consonance:")
    for name in CONSONANCE_NAMES:
        print(f"  unison -> {name:<14} : {bfs_interval_distance((0, 0), SEMITONES[name])}")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_registers_and_census()
    demo_threshold()
    demo_free_bass()
    print("=" * 72)
    print("All assertions passed: every numerical claim above is confirmed.")
    print("=" * 72)


if __name__ == "__main__":
    main()
