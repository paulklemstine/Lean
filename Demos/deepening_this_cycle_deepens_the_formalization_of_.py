"""
Numerical demonstrations for:

    "The Grounded Extension is the Least Complete Extension"

An *argumentation framework* is a pair (A, R) where A is a finite set of
arguments and R is an attack relation: R[a][b] means "argument a attacks
argument b".  We implement the defense (characteristic) operator F, compute
the grounded extension as the least fixed point of F by iteration from the
empty set, and verify --- on a battery of examples --- the central results:

    * F preserves conflict-freeness;
    * the grounded extension is conflict-free, admissible and complete;
    * the grounded extension is contained in every complete extension;
    * a set is complete iff it is a conflict-free fixed point of F.

Everything is self-contained and uses only the standard library.
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

# An argumentation framework: arguments plus an attack relation as a set of
# ordered pairs (attacker, target).
Argument = str
Attack = Tuple[Argument, Argument]
Framework = Tuple[Set[Argument], Set[Attack]]


def attackers(af: Framework, target: Argument) -> Set[Argument]:
    """All arguments that attack `target`."""
    _, attacks = af
    return {a for (a, b) in attacks if b == target}


def is_conflict_free(af: Framework, s: Set[Argument]) -> bool:
    """No member of `s` attacks a member of `s`."""
    _, attacks = af
    return not any((a in s and b in s) for (a, b) in attacks)


def defends(af: Framework, s: Set[Argument], a: Argument) -> bool:
    """`s` defends `a`: every attacker of `a` is counter-attacked from `s`."""
    for b in attackers(af, a):
        if not any((c in s and (c, b) in af[1]) for c in af[0]):
            return False
    return True


def defense_operator(af: Framework, s: Set[Argument]) -> Set[Argument]:
    """F(S): the set of all arguments defended by S."""
    arguments, _ = af
    return {a for a in arguments if defends(af, s, a)}


def is_admissible(af: Framework, s: Set[Argument]) -> bool:
    return is_conflict_free(af, s) and all(defends(af, s, a) for a in s)


def is_complete(af: Framework, s: Set[Argument]) -> bool:
    """Admissible and closed under defense: F(S) subset of S."""
    return is_admissible(af, s) and defense_operator(af, s) <= s


def grounded_extension(af: Framework) -> Set[Argument]:
    """Least fixed point of F, reached by iterating from the empty set.

    On a framework with n arguments the increasing chain stabilizes within
    n steps, so this terminates.
    """
    current: Set[Argument] = set()
    while True:
        nxt = defense_operator(af, current)
        if nxt == current:
            return current
        current = nxt


def all_subsets(arguments: Iterable[Argument]) -> Iterable[FrozenSet[Argument]]:
    arguments = list(arguments)
    return map(
        frozenset,
        chain.from_iterable(combinations(arguments, r) for r in range(len(arguments) + 1)),
    )


def all_complete_extensions(af: Framework) -> List[FrozenSet[Argument]]:
    """Brute-force enumeration of complete extensions (small frameworks only)."""
    return [s for s in all_subsets(af[0]) if is_complete(af, set(s))]


def grounded_iteration_trace(af: Framework) -> List[Set[Argument]]:
    """Return the sequence of approximants emptyset, F(emptyset), F^2(...), ..."""
    trace = [set()]
    while True:
        nxt = defense_operator(af, trace[-1])
        if nxt == trace[-1]:
            return trace
        trace.append(nxt)


# ---------------------------------------------------------------------------
# Example frameworks
# ---------------------------------------------------------------------------

def simple_chain() -> Framework:
    """a -> b -> c.  Grounded = {a, c}."""
    return ({"a", "b", "c"}, {("a", "b"), ("b", "c")})


def two_cycle() -> Framework:
    """a <-> b.  Grounded = {} (nothing forced); two extra complete/stable sets."""
    return ({"a", "b"}, {("a", "b"), ("b", "a")})


def three_cycle() -> Framework:
    """a -> b -> c -> a.  Grounded = {}, the unique complete extension."""
    return ({"a", "b", "c"}, {("a", "b"), ("b", "c"), ("c", "a")})


def reinstatement() -> Framework:
    """a -> b -> c: c is 'reinstated' because a defeats its attacker b.

    This is the same graph as simple_chain but named to stress the point:
    the grounded extension accepts c only because a (unattacked) defends it.
    """
    return ({"a", "b", "c"}, {("a", "b"), ("b", "c")})


def no_attacks() -> Framework:
    """Nobody attacks anybody: grounded = all of A, and it is a fixed point."""
    return ({"a", "b", "c"}, set())


def fmt(s: Iterable[Argument]) -> str:
    xs = sorted(s)
    return "{" + ", ".join(xs) + "}" if xs else "{}"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_grounded_by_iteration() -> None:
    print("=" * 70)
    print("Grounded extension as the least fixed point of the defense operator")
    print("=" * 70)
    for name, af in [
        ("chain a->b->c (reinstatement)", simple_chain()),
        ("2-cycle a<->b", two_cycle()),
        ("3-cycle a->b->c->a", three_cycle()),
        ("no attacks", no_attacks()),
    ]:
        trace = grounded_iteration_trace(af)
        steps = " -> ".join(fmt(t) for t in trace)
        g = grounded_extension(af)
        print(f"\n{name}")
        print(f"  approximants: {steps}")
        print(f"  grounded extension G = {fmt(g)}")
        assert is_conflict_free(af, g), "G must be conflict-free"
        assert is_complete(af, g), "G must be complete"
        print("  verified: G is conflict-free and complete.")


def demo_least_complete() -> None:
    print("\n" + "=" * 70)
    print("The grounded extension is the LEAST complete extension")
    print("=" * 70)
    for name, af in [
        ("chain a->b->c", simple_chain()),
        ("2-cycle a<->b", two_cycle()),
        ("3-cycle a->b->c->a", three_cycle()),
    ]:
        g = grounded_extension(af)
        completes = all_complete_extensions(af)
        print(f"\n{name}")
        print(f"  grounded extension G = {fmt(g)}")
        print(f"  all complete extensions: {[fmt(c) for c in completes]}")
        for c in completes:
            assert g <= set(c), "G must be contained in every complete extension"
        assert frozenset(g) in map(frozenset, completes)
        print("  verified: G is complete and contained in every complete extension.")


def demo_preservation_of_conflict_freeness() -> None:
    print("\n" + "=" * 70)
    print("The defense operator preserves conflict-freeness")
    print("=" * 70)
    checked = 0
    for name, af in [
        ("chain", simple_chain()),
        ("2-cycle", two_cycle()),
        ("3-cycle", three_cycle()),
        ("no attacks", no_attacks()),
    ]:
        for s in all_subsets(af[0]):
            if is_conflict_free(af, set(s)):
                fs = defense_operator(af, set(s))
                assert is_conflict_free(af, fs), (name, s, fs)
                checked += 1
    print(f"  verified on {checked} conflict-free sets across all example frameworks:")
    print("  if S is conflict-free then F(S) is conflict-free.")


def demo_fixed_point_characterization() -> None:
    print("\n" + "=" * 70)
    print("Complete  <=>  conflict-free fixed point of F")
    print("=" * 70)
    for name, af in [
        ("chain", simple_chain()),
        ("2-cycle", two_cycle()),
        ("3-cycle", three_cycle()),
        ("no attacks", no_attacks()),
    ]:
        for s in all_subsets(af[0]):
            ss = set(s)
            lhs = is_complete(af, ss)
            rhs = is_conflict_free(af, ss) and defense_operator(af, ss) == ss
            assert lhs == rhs, (name, s, lhs, rhs)
        print(f"  {name}: characterization holds for all {2 ** len(af[0])} subsets.")


def demo_non_least_fixed_point_can_conflict() -> None:
    print("\n" + "=" * 70)
    print("Why 'least' matters: a non-least fixed point of F may CONFLICT")
    print("=" * 70)
    # In the 2-cycle a <-> b the FULL set {a, b} is a fixed point of F:
    #   defends({a,b}, a): attacker b is counter-attacked by a  (a -> b),
    #   defends({a,b}, b): attacker a is counter-attacked by b  (b -> a),
    # so F({a,b}) = {a,b}.  Yet {a,b} contains the conflict a -> b.
    af: Framework = two_cycle()
    full = {"a", "b"}
    fs = defense_operator(af, full)
    print(f"  framework: A = {fmt(af[0])}, attacks = {sorted(af[1])}")
    print(f"  F({fmt(full)}) = {fmt(fs)}  (a fixed point)")
    print(f"  is {fmt(full)} conflict-free? {is_conflict_free(af, full)}")
    g = grounded_extension(af)
    print(f"  grounded extension G = {fmt(g)}  (conflict-free: {is_conflict_free(af, g)})")
    assert fs == full and not is_conflict_free(af, full)
    assert is_conflict_free(af, g)
    print("  verified: a non-least fixed point can be a conflict; the LEAST one never is.")


def main() -> None:
    demo_grounded_by_iteration()
    demo_least_complete()
    demo_preservation_of_conflict_freeness()
    demo_fixed_point_characterization()
    demo_non_least_fixed_point_can_conflict()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
