"""
The Kernel/Game Bridge: numerical demonstrations.

This self-contained script demonstrates the three-way identity

    stable extension of R  =  kernel of flip(R)  =  solution of the game flip(R)

together with:
  * the odd-cycle obstruction (the directed 3-cycle has no kernel /
    no stable extension), and
  * well-founded determinacy (a well-founded digraph has a unique kernel,
    computed by the standard game recursion).

Everything is implemented from scratch with only the standard library.
Relations are represented as sets of (source, target) ordered pairs over a
finite vertex set.
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

Vertex = int
Relation = Set[Tuple[Vertex, Vertex]]


# ---------------------------------------------------------------------------
# Core relational primitives
# ---------------------------------------------------------------------------

def flip(rel: Relation) -> Relation:
    """Transpose: reverse every edge.  (flip R) a b  <->  R b a."""
    return {(b, a) for (a, b) in rel}


def out_neighbours(rel: Relation, a: Vertex) -> Set[Vertex]:
    """All b with an edge a -> b."""
    return {b for (x, b) in rel if x == a}


def powerset(vertices: Iterable[Vertex]) -> Iterable[FrozenSet[Vertex]]:
    xs = list(vertices)
    return (
        frozenset(c)
        for c in chain.from_iterable(combinations(xs, k) for k in range(len(xs) + 1))
    )


# ---------------------------------------------------------------------------
# The three definitions (over a common carrier)
# ---------------------------------------------------------------------------

def is_conflict_free(rel: Relation, s: FrozenSet[Vertex]) -> bool:
    """No member of s attacks another member of s."""
    return all((a, b) not in rel for a in s for b in s)


def is_stable(rel: Relation, verts: Iterable[Vertex], s: FrozenSet[Vertex]) -> bool:
    """Stable extension: conflict-free and attacks every outsider."""
    if not is_conflict_free(rel, s):
        return False
    return all(any((b, a) in rel for b in s) for a in verts if a not in s)


def is_independent(dig: Relation, s: FrozenSet[Vertex]) -> bool:
    """No edge joins two members of s."""
    return all((a, b) not in dig for a in s for b in s)


def is_absorbing(dig: Relation, verts: Iterable[Vertex], s: FrozenSet[Vertex]) -> bool:
    """Every vertex outside s has an edge INTO s."""
    return all(any((a, b) in dig for b in s) for a in verts if a not in s)


def is_kernel(dig: Relation, verts: Iterable[Vertex], s: FrozenSet[Vertex]) -> bool:
    """Kernel: independent and absorbing."""
    return is_independent(dig, s) and is_absorbing(dig, verts, s)


# A game solution is, by definition, a kernel of the move relation.
def is_game_solution(move: Relation, verts: Iterable[Vertex], p: FrozenSet[Vertex]) -> bool:
    return is_kernel(move, verts, p)


# ---------------------------------------------------------------------------
# Brute-force enumeration of stable extensions / kernels
# ---------------------------------------------------------------------------

def all_stable(rel: Relation, verts: List[Vertex]) -> List[FrozenSet[Vertex]]:
    return [s for s in powerset(verts) if is_stable(rel, verts, s)]


def all_kernels(dig: Relation, verts: List[Vertex]) -> List[FrozenSet[Vertex]]:
    return [s for s in powerset(verts) if is_kernel(dig, verts, s)]


# ---------------------------------------------------------------------------
# Well-founded game recursion (Zermelo / retrograde analysis)
# ---------------------------------------------------------------------------

def is_acyclic(move: Relation, verts: List[Vertex]) -> bool:
    """DFS-based cycle test; well-founded (finite) <=> acyclic here."""
    colour: Dict[Vertex, int] = {v: 0 for v in verts}  # 0=white,1=grey,2=black

    def visit(u: Vertex) -> bool:
        colour[u] = 1
        for w in out_neighbours(move, u):
            if colour[w] == 1:
                return False
            if colour[w] == 0 and not visit(w):
                return False
        colour[u] = 2
        return True

    return all(colour[v] != 0 or visit(v) for v in verts)


def losing_positions(move: Relation, verts: List[Vertex]) -> FrozenSet[Vertex]:
    """
    Compute {a : isLoss(a)} for an acyclic (well-founded) move relation by the
    recursion  isLoss(a) <-> every move a->b lands in a non-loss.
    Implemented with memoised recursion.
    """
    memo: Dict[Vertex, bool] = {}

    def is_loss(a: Vertex) -> bool:
        if a in memo:
            return memo[a]
        # Guard against accidental reuse on cyclic input.
        memo[a] = False
        result = all(not is_loss(b) for b in out_neighbours(move, a))
        memo[a] = result
        return result

    return frozenset(v for v in verts if is_loss(v))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_dictionary() -> None:
    print("=" * 70)
    print("DEMO 1: The dictionary  Stable(R) = Kernel(flip R) = GameSolution(flip R)")
    print("=" * 70)
    verts = [0, 1, 2, 3]
    # R: 0 attacks 1, 1 attacks 2, 3 attacks 2   (a small acyclic debate)
    R: Relation = {(0, 1), (1, 2), (3, 2)}
    print(f"Attack relation R = {sorted(R)}")
    stables = all_stable(R, verts)
    kernels = all_kernels(flip(R), verts)
    print(f"Stable extensions of R          : {[sorted(s) for s in stables]}")
    print(f"Kernels of flip(R)              : {[sorted(s) for s in kernels]}")
    match = set(stables) == set(kernels)
    print(f"Do the two collections coincide? {match}")
    # Also verify the game-solution reading agrees, set by set.
    all_agree = all(
        is_stable(R, verts, s) == is_game_solution(flip(R), verts, s)
        for s in powerset(verts)
    )
    print(f"Stable(R,S) == GameSolution(flip R, S) for ALL S? {all_agree}")


def demo_odd_cycle() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2: The odd-cycle obstruction (directed 3-cycle)")
    print("=" * 70)
    verts = [0, 1, 2]
    cyc3: Relation = {(a, (a + 1) % 3) for a in verts}  # 0->1->2->0
    print(f"cyc3 = {sorted(cyc3)}")
    kernels = all_kernels(cyc3, verts)
    stables = all_stable(cyc3, verts)
    print(f"Kernels of cyc3           : {[sorted(s) for s in kernels]}  (expected: [])")
    print(f"Stable extensions of cyc3 : {[sorted(s) for s in stables]}  (expected: [])")
    print("Enumerating why each of the 8 candidate sets fails:")
    for s in powerset(verts):
        ind = is_independent(cyc3, s)
        ab = is_absorbing(cyc3, verts, s)
        reason = []
        if not ind:
            reason.append("not independent")
        if not ab:
            reason.append("not absorbing")
        print(f"  {sorted(s)!s:12} -> kernel={is_kernel(cyc3, verts, s)}  ({', '.join(reason) or 'KERNEL'})")


def demo_even_cycle_contrast() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3: Contrast -- the even (4-)cycle DOES have kernels")
    print("=" * 70)
    verts = [0, 1, 2, 3]
    cyc4: Relation = {(a, (a + 1) % 4) for a in verts}  # 0->1->2->3->0
    kernels = all_kernels(cyc4, verts)
    print(f"cyc4 = {sorted(cyc4)}")
    print(f"Kernels of cyc4 : {[sorted(s) for s in kernels]}")
    print("Odd cycles obstruct; even cycles do not.")


def demo_wellfounded_determinacy() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4: Well-founded determinacy (unique kernel via game recursion)")
    print("=" * 70)
    # A subtraction game: positions 0..7, may remove 1 or 2 tokens.
    verts = list(range(8))
    move: Relation = set()
    for n in verts:
        for d in (1, 2):
            if n - d >= 0:
                move.add((n, n - d))
    print(f"Subtraction-game move relation (remove 1 or 2), positions 0..7")
    print(f"Acyclic / well-founded? {is_acyclic(move, verts)}")
    L = losing_positions(move, verts)
    print(f"Losing positions (game recursion): {sorted(L)}")
    kernels = all_kernels(move, verts)
    print(f"All kernels (brute force)        : {[sorted(k) for k in kernels]}")
    print(f"Unique kernel equals recursion?  {kernels == [L]}")
    # Sanity: losing positions are exactly n % 3 == 0.
    print(f"Matches 'n divisible by 3'?       {sorted(L) == [n for n in verts if n % 3 == 0]}")


def demo_wellfounded_argumentation() -> None:
    print("\n" + "=" * 70)
    print("DEMO 5: Well-founded framework has a UNIQUE stable extension")
    print("=" * 70)
    verts = [0, 1, 2, 3, 4]
    # An acyclic attack relation (well-founded).
    R: Relation = {(0, 1), (1, 2), (2, 3), (3, 4), (0, 3)}
    print(f"Well-founded attack relation R = {sorted(R)}")
    print(f"R acyclic? {is_acyclic(R, verts)}")
    stables = all_stable(R, verts)
    print(f"Stable extensions of R: {[sorted(s) for s in stables]}")
    # Compute it via the transpose + game recursion route.
    via_game = losing_positions(flip(R), verts)
    print(f"Computed via transpose+recursion: {sorted(via_game)}")
    print(f"Exactly one stable extension?     {len(stables) == 1}")
    print(f"Two routes agree?                 {set(stables) == {via_game}}")


if __name__ == "__main__":
    demo_dictionary()
    demo_odd_cycle()
    demo_even_cycle_contrast()
    demo_wellfounded_determinacy()
    demo_wellfounded_argumentation()
    print("\nAll demonstrations complete.")
