"""
Mind Tools: Mathematics as Cognitive Extension — numerical demonstrations.

This self-contained script illustrates, on finite computable models, the three
pillars of the theory:

  1. Formal systems as sets of theorems, the cognitive-power order, and the
     mind-tool relation.
  2. The Cantor/Goedel incompleteness engine: any *listed* stock of statements
     misses some statement (finite diagonalization), and a brain can always be
     strictly extended into a mind tool.
  3. Universality: one categorical theorem settles a whole family, while
     set-level work only ever settles finitely many instances — and the power
     order is neither total nor well-founded.

Statements are modelled as frozensets of natural numbers (finite stand-ins for
predicates on the naturals); a formal system is a set of such statements.
"""

from __future__ import annotations

from typing import Callable, FrozenSet, Iterable, List, Set, Tuple

Statement = FrozenSet[int]
System = Set[Statement]


# ---------------------------------------------------------------------------
# 1. The power order and the mind-tool relation
# ---------------------------------------------------------------------------

def le_pow(f: System, g: System) -> bool:
    """F <= G : G is at least as powerful as F (every theorem of F is in G)."""
    return f.issubset(g)


def lt_pow(f: System, g: System) -> bool:
    """F < G : G is strictly more powerful than F."""
    return f.issubset(g) and f != g


def is_mind_tool(brain: System, tool: System) -> bool:
    """`tool` is a mind tool relative to `brain` iff brain < tool."""
    return lt_pow(brain, tool)


def incomparable(f: System, g: System) -> bool:
    """Neither system extends the other."""
    return not le_pow(f, g) and not le_pow(g, f)


# ---------------------------------------------------------------------------
# 2. Incompleteness by diagonalization (finite Cantor)
# ---------------------------------------------------------------------------

def diagonal_missing_statement(listing: List[Statement], universe: int) -> Statement:
    """
    Given a finite `listing` e(0), e(1), ... of statements (subsets of
    {0,...,universe-1}), build a statement guaranteed not to appear among the
    first `universe` entries, by flipping membership of `i` against e(i).

    This is Cantor's diagonal in finite form: the built set differs from e(i)
    at point i, so it equals none of e(0..universe-1).
    """
    built: Set[int] = set()
    for i in range(universe):
        e_i = listing[i] if i < len(listing) else frozenset()
        if i not in e_i:            # differ from e(i) at coordinate i
            built.add(i)
    return frozenset(built)


def extend_to_mind_tool(brain: System, new_statement: Statement) -> System:
    """Adjoin one unprovable statement to a brain, producing a strict extension."""
    return set(brain) | {new_statement}


# ---------------------------------------------------------------------------
# 3. Universality: set-level vs categorical systems on a problem family
# ---------------------------------------------------------------------------

def prob(n: int) -> Statement:
    """Injective encoding of 'the problem for object n' as the singleton {n}."""
    return frozenset({n})


def set_level(solved: Iterable[int]) -> System:
    """Set-theoretic system: exactly the finite batch of instances solved."""
    return {prob(n) for n in solved}


def cat_level(bound: int) -> System:
    """
    Categorical system truncated to objects 0..bound-1 for display. Conceptually
    it proves prob(n) for *every* n; `bound` only limits what we print.
    """
    return {prob(n) for n in range(bound)}


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_order() -> None:
    print("=" * 70)
    print("1. THE POWER ORDER AND MIND TOOLS")
    print("=" * 70)
    brain: System = {frozenset({0}), frozenset({1})}
    tool: System = {frozenset({0}), frozenset({1}), frozenset({2, 3})}
    print(f"brain proves      : {sorted(map(sorted, brain))}")
    print(f"tool  proves      : {sorted(map(sorted, tool))}")
    print(f"brain <= tool     : {le_pow(brain, tool)}")
    print(f"brain <  tool     : {lt_pow(brain, tool)}")
    print(f"tool is mind tool : {is_mind_tool(brain, tool)}  (proves more than the brain)")
    # transitivity
    bigger = tool | {frozenset({4})}
    print(f"transitivity      : mind_tool(brain,tool) & mind_tool(tool,bigger) "
          f"=> mind_tool(brain,bigger) = "
          f"{is_mind_tool(brain, tool) and is_mind_tool(tool, bigger) and is_mind_tool(brain, bigger)}")
    print(f"irreflexivity     : is_mind_tool(brain, brain) = {is_mind_tool(brain, brain)}")


def demo_incompleteness() -> None:
    print("\n" + "=" * 70)
    print("2. INCOMPLETENESS: EVERY LISTING MISSES A STATEMENT")
    print("=" * 70)
    universe = 6
    # A brain that has 'listed' some statements over {0..5}
    listing: List[Statement] = [
        frozenset({0, 2, 4}),
        frozenset({1, 2, 3}),
        frozenset({0, 1}),
        frozenset({3, 4, 5}),
        frozenset({2, 5}),
        frozenset({0, 1, 2, 3, 4, 5}),
    ]
    brain: System = set(listing)
    missing = diagonal_missing_statement(listing, universe)
    print(f"brain's listing   :")
    for i, s in enumerate(listing):
        print(f"    e({i}) = {sorted(s)}")
    print(f"diagonal statement: {sorted(missing)}  (differs from e(i) at point i)")
    print(f"is it in brain?   : {missing in brain}  -> a true-but-unprovable statement")
    tool = extend_to_mind_tool(brain, missing)
    print(f"extend brain by it: brain < tool = {lt_pow(brain, tool)}  "
          f"(cognition is always extensible)")


def demo_universality() -> None:
    print("\n" + "=" * 70)
    print("3. UNIVERSALITY: ONE CATEGORICAL THEOREM VS INSTANCE-BY-INSTANCE")
    print("=" * 70)
    solved = [0, 1, 2, 5, 9]                 # a finite day's set-level labour
    S = set_level(solved)
    C = cat_level(bound=12)
    print(f"set-level solved  : {sorted(n for n in range(12) if prob(n) in S)}")
    print(f"categorical proves: {sorted(n for n in range(12) if prob(n) in C)} ... (all n)")
    print(f"Set[F] proves 7?  : {prob(7) in S}    Cat proves 7? : {prob(7) in C}")
    print(f"Set[F] < Cat      : {lt_pow(S, C)}  (categorical dominance)")
    print(f"|Set[F]| finite   : {len(S)};  Cat is infinite (truncated view only)")
    print("no finite catch-up: a finite pile of solved cases can never equal "
          "the infinite family")


def demo_not_wellorder() -> None:
    print("\n" + "=" * 70)
    print("4. THE HIERARCHY IS NOT A WELL-ORDER")
    print("=" * 70)
    # Non-totality: {emptyset} vs {universe-set} are incomparable
    F: System = {frozenset()}
    G: System = {frozenset(range(100))}      # stands in for the 'universal' statement
    print(f"F proves {{emptyset}}, G proves {{everything}}")
    print(f"incomparable(F,G) : {incomparable(F, G)}  (order is not total)")

    # Non-well-foundedness: tail systems T_n = {{m} : m >= n}, truncated
    top = 8

    def tail(n: int) -> System:
        return {frozenset({m}) for m in range(n, top)}

    chain = [tail(n) for n in range(top)]
    strict = all(lt_pow(chain[n + 1], chain[n]) for n in range(top - 1))
    print(f"tail systems T_0 > T_1 > ... strictly decreasing : {strict}")
    print("    " + "  >  ".join(f"T{n}({len(chain[n])})" for n in range(top)))
    print("=> an infinite strictly descending chain exists (not well-founded)")


def main() -> None:
    demo_order()
    demo_incompleteness()
    demo_universality()
    demo_not_wellorder()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
