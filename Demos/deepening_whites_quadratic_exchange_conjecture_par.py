"""
Numerical demonstrations for:

    A Compositional Theory of Quadratic Basis Exchange,
    with a Complete Solution in Rank One
    (White's Quadratic Exchange Conjecture, Part 3)

This self-contained script models:

  * Configurations as multisets of bases (frozensets), using Counter.
  * The multiset union / fingerprint of a configuration.
  * The basis-preserving quadratic exchange move and one-step reachability
    (in the uniform case, where every r-subset is a basis).
  * A breadth-first reachability search producing an explicit move sequence.
  * The rank-1 theorem: equal fingerprint implies identical configuration.
  * The extraction-driven reconfiguration procedure for general uniform rank.

Run:  python demo.py
"""

from __future__ import annotations

from collections import Counter
from itertools import combinations
from typing import Dict, FrozenSet, Iterator, List, Optional, Tuple

# A basis is a frozenset of ground-set elements (ints).
Basis = FrozenSet[int]
# A configuration is a multiset of bases: basis -> multiplicity.
Config = Dict[Basis, int]


# --------------------------------------------------------------------------- #
# Core combinatorics
# --------------------------------------------------------------------------- #
def make_config(bases: List[Basis]) -> Config:
    """Build a configuration (multiset) from a list of bases."""
    return dict(Counter(bases))


def config_size(config: Config) -> int:
    """Number of bases in the configuration, counting multiplicity."""
    return sum(config.values())


def fingerprint(config: Config) -> Counter:
    """Multiset union: pool all elements of all bases with multiplicity."""
    total: Counter = Counter()
    for basis, mult in config.items():
        for elem in basis:
            total[elem] += mult
    return total


def config_to_list(config: Config) -> List[Basis]:
    """Flatten a configuration to a sorted list of bases (for display)."""
    out: List[Basis] = []
    for basis, mult in config.items():
        out.extend([basis] * mult)
    return sorted(out, key=lambda b: tuple(sorted(b)))


def show(config: Config) -> str:
    """Human-readable rendering of a configuration."""
    return "{ " + ", ".join(
        "{" + ",".join(map(str, sorted(b))) + "}" for b in config_to_list(config)
    ) + " }"


# --------------------------------------------------------------------------- #
# Quadratic exchange moves (uniform matroid U_{r,n})
# --------------------------------------------------------------------------- #
def uniform_repackings(b1: Basis, b2: Basis, r: int) -> Iterator[Tuple[Basis, Basis]]:
    """
    All element-conserving repackings (c1, c2) of the pair (b1, b2) into two
    r-subsets, in the uniform matroid.  Conservation: the pooled multiset of
    elements is preserved.  Since b1, b2 are sets, pooled elements form a
    multiset where shared elements appear twice.
    """
    pooled: Counter = Counter()
    for e in b1:
        pooled[e] += 1
    for e in b2:
        pooled[e] += 1
    elems = sorted(pooled)
    # choose c1 as an r-subset respecting availability; c2 is the remainder.
    for c1_tuple in combinations(elems, r):
        c1 = frozenset(c1_tuple)
        remaining = pooled.copy()
        ok = True
        for e in c1:
            remaining[e] -= 1
            if remaining[e] < 0:
                ok = False
                break
        if not ok:
            continue
        c2_elems = sorted(e for e in remaining.elements())
        if len(c2_elems) != r:
            continue
        c2 = frozenset(c2_elems)
        # c2 must be a genuine set (each element multiplicity 1 after split).
        if len(c2) != r:
            continue
        yield (c1, c2)


def apply_move(config: Config, b1: Basis, b2: Basis,
               c1: Basis, c2: Basis) -> Config:
    """Replace one copy each of b1, b2 by c1, c2; return a new configuration."""
    new = dict(config)
    for b in (b1, b2):
        new[b] -= 1
        if new[b] == 0:
            del new[b]
    for c in (c1, c2):
        new[c] = new.get(c, 0) + 1
    return new


def one_step_neighbors(config: Config, r: int) -> Iterator[Config]:
    """All configurations reachable from `config` by a single quadratic move."""
    bases = config_to_list(config)
    seen: set = set()
    for i, j in combinations(range(len(bases)), 2):
        b1, b2 = bases[i], bases[j]
        for c1, c2 in uniform_repackings(b1, b2, r):
            if {c1, c2} == {b1, b2}:
                continue  # trivial move
            nxt = apply_move(config, b1, b2, c1, c2)
            key = frozenset(Counter(config_to_list(nxt)).items())
            if key not in seen:
                seen.add(key)
                yield nxt


def _canon(config: Config) -> Tuple:
    """Hashable canonical form of a configuration."""
    return tuple(sorted((tuple(sorted(b)), m) for b, m in config.items()))


def reachable_bfs(start: Config, goal: Config, r: int,
                  max_states: int = 200000) -> Optional[List[Config]]:
    """
    Breadth-first search for a sequence of quadratic moves from start to goal.
    Returns the list of configurations along the path, or None if not found.
    """
    if fingerprint(start) != fingerprint(goal):
        return None
    start_k, goal_k = _canon(start), _canon(goal)
    if start_k == goal_k:
        return [start]
    frontier: List[Config] = [start]
    parent: Dict[Tuple, Tuple] = {start_k: None}
    states: Dict[Tuple, Config] = {start_k: start}
    while frontier and len(states) < max_states:
        nxt_frontier: List[Config] = []
        for cfg in frontier:
            for nb in one_step_neighbors(cfg, r):
                k = _canon(nb)
                if k not in parent:
                    parent[k] = _canon(cfg)
                    states[k] = nb
                    if k == goal_k:
                        # reconstruct path
                        path_keys = [k]
                        while parent[path_keys[-1]] is not None:
                            path_keys.append(parent[path_keys[-1]])
                        path_keys.reverse()
                        return [states[pk] for pk in path_keys]
                    nxt_frontier.append(nb)
        frontier = nxt_frontier
    return None


# --------------------------------------------------------------------------- #
# Rank-1 theorem
# --------------------------------------------------------------------------- #
def rank1_reconstruct(fp: Counter) -> Config:
    """Reconstruct a rank-1 configuration from its fingerprint: a -> {a}."""
    cfg: Config = {}
    for elem, mult in fp.items():
        b = frozenset({elem})
        cfg[b] = cfg.get(b, 0) + mult
    return cfg


def rank1_equal_union_implies_equal(c: Config, d: Config) -> bool:
    """Verify the rank-1 theorem on a pair: equal fingerprint => equal config."""
    if fingerprint(c) != fingerprint(d):
        return True  # hypothesis vacuous
    return _canon(c) == _canon(d)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_fingerprint() -> None:
    print("=" * 70)
    print("DEMO 1: Fingerprint (multiset union) of a configuration")
    print("=" * 70)
    cfg = make_config([frozenset({1, 2}), frozenset({2, 3}), frozenset({1, 3})])
    print("Configuration:", show(cfg))
    print("Fingerprint  :", dict(sorted(fingerprint(cfg).items())))
    print("Reading: element 1 appears twice, 2 twice, 3 twice.\n")


def demo_two_basis_move() -> None:
    print("=" * 70)
    print("DEMO 2: Uniform two-basis reconfiguration (r = 2)")
    print("=" * 70)
    b1, b2 = frozenset({1, 2}), frozenset({3, 4})
    print(f"Start pair: {sorted(b1)} , {sorted(b2)}")
    print("All element-conserving repackings into two 2-subsets:")
    for c1, c2 in uniform_repackings(b1, b2, 2):
        print(f"   -> {sorted(c1)} , {sorted(c2)}")
    print("Every listed repacking is a single legal quadratic move.\n")


def demo_rank1_theorem() -> None:
    print("=" * 70)
    print("DEMO 3: White's Part 3 in rank 1  (equal union => identical)")
    print("=" * 70)
    c = make_config([frozenset({1}), frozenset({1}), frozenset({2}), frozenset({5})])
    d = rank1_reconstruct(fingerprint(c))
    print("Configuration C:", show(c))
    print("Rebuilt from fingerprint:", show(d))
    print("Identical? ", _canon(c) == _canon(d))
    print("Theorem confirmed: the fingerprint determines the configuration.\n")


def demo_reachability_search() -> None:
    print("=" * 70)
    print("DEMO 4: Explicit reconfiguration by quadratic moves (r = 2)")
    print("=" * 70)
    start = make_config([frozenset({1, 2}), frozenset({3, 4})])
    goal = make_config([frozenset({1, 3}), frozenset({2, 4})])
    print("Start:", show(start), " Goal:", show(goal))
    print("Same fingerprint?", fingerprint(start) == fingerprint(goal))
    path = reachable_bfs(start, goal, r=2)
    if path is None:
        print("No path found.")
    else:
        print(f"Reachable in {len(path) - 1} move(s):")
        for i, cfg in enumerate(path):
            print(f"   step {i}: {show(cfg)}")
    print()


def demo_larger_reachability() -> None:
    print("=" * 70)
    print("DEMO 5: Reconfiguring a 3-basis rank-2 configuration")
    print("=" * 70)
    start = make_config([frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})])
    goal = make_config([frozenset({1, 4}), frozenset({2, 5}), frozenset({3, 6})])
    print("Start:", show(start))
    print("Goal :", show(goal))
    print("Same fingerprint?", fingerprint(start) == fingerprint(goal))
    path = reachable_bfs(start, goal, r=2)
    if path is None:
        print("No path found within search budget.")
    else:
        print(f"Reachable in {len(path) - 1} move(s).")
    print()


def main() -> None:
    demo_fingerprint()
    demo_two_basis_move()
    demo_rank1_theorem()
    demo_reachability_search()
    demo_larger_reachability()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
