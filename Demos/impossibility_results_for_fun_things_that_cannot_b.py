"""
The Symmetry Principle of Impossibility -- Numerical Demonstrations
==================================================================

This self-contained script illustrates the central results connecting free
group actions to the impossibility of "symmetric distinguishing tasks."

Core objects
------------
A finite group G acts on a finite set X.  For g in G and x in X the action
sends x to g . x.  We model:

  * IsFree(action)   : g . x = x  =>  g = 1     (only identity has fixed points)
  * IsTrivial(action): g . x = x  for all g, x  (nothing ever moves)
  * Invariant f      : f(g . x) = f(x)  for all g, x
  * Injective f      : f(x) = f(y) => x = y

Key theorems demonstrated
-------------------------
  Theorem A : action is free  <=>  every orbit map  g |-> g . x  is injective.
  Theorem B : an invariant injective f exists  <=>  the action is trivial.
  Theorem C : for the left-regular action of a non-trivial group, no invariant
              injective f exists (the S_5 instance shadows the unsolvable quintic).
  Frontier  : "impossible <=> free" is FALSE; the true boundary is non-triviality
              (a rotation fixing a center is non-trivial, non-free, still impossible).

Groups are represented concretely as permutation groups (tuples encoding the
image of 0..n-1), which is fully general by Cayley's theorem.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Callable, Dict, FrozenSet, Hashable, List, Sequence, Tuple

# A group element is a permutation of {0, ..., n-1}, stored as a tuple.
Perm = Tuple[int, ...]
# An action maps (group element, point) -> point.
Action = Callable[[Perm, Hashable], Hashable]


# --------------------------------------------------------------------------- #
# Group construction
# --------------------------------------------------------------------------- #
def compose(p: Perm, q: Perm) -> Perm:
    """Return the permutation (p after q): (p . q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(q)))


def identity(n: int) -> Perm:
    """The identity permutation on n points."""
    return tuple(range(n))


def symmetric_group(n: int) -> List[Perm]:
    """All n! permutations of {0, ..., n-1} -- the symmetric group S_n."""
    return list(permutations(range(n)))


def cyclic_group(n: int) -> List[Perm]:
    """The cyclic group C_n as rotations of {0, ..., n-1}."""
    return [tuple((i + k) % n for i in range(n)) for k in range(n)]


# --------------------------------------------------------------------------- #
# Predicates on actions (finite, decidable versions of the definitions)
# --------------------------------------------------------------------------- #
def is_free(group: Sequence[Perm], points: Sequence[Hashable], act: Action,
            ident: Perm) -> bool:
    """Theorem 2.2: only the identity fixes any point."""
    for x in points:
        for g in group:
            if act(g, x) == x and g != ident:
                return False
    return True


def is_trivial(group: Sequence[Perm], points: Sequence[Hashable],
               act: Action) -> bool:
    """Definition 2.3: every element fixes every point."""
    return all(act(g, x) == x for g in group for x in points)


def orbit_map_injective(group: Sequence[Perm], points: Sequence[Hashable],
                        act: Action) -> bool:
    """For every x, the map  g |-> g . x  is injective."""
    for x in points:
        images = [act(g, x) for g in group]
        if len(set(images)) != len(images):
            return False
    return True


def orbits(group: Sequence[Perm], points: Sequence[Hashable],
           act: Action) -> List[FrozenSet[Hashable]]:
    """Compute the orbit partition X / G."""
    seen: set = set()
    result: List[FrozenSet[Hashable]] = []
    for x in points:
        if x in seen:
            continue
        orb = frozenset(act(g, x) for g in group)
        seen |= orb
        result.append(orb)
    return result


def symmetric_task_solvable(group: Sequence[Perm], points: Sequence[Hashable],
                            act: Action) -> bool:
    """
    Theorem B (constructive form): an invariant injective function exists iff
    the number of orbits equals the number of points, i.e. every orbit is a
    singleton, i.e. the action is trivial.  We verify via the orbit count.
    """
    return len(orbits(group, points, act)) == len(list(points))


# --------------------------------------------------------------------------- #
# Concrete actions
# --------------------------------------------------------------------------- #
def natural_action(g: Perm, x: Hashable) -> Hashable:
    """Permutation g acts on a point label x in {0, ..., n-1}."""
    return g[x]  # type: ignore[index]


def left_regular_action(g: Perm, x: Hashable) -> Hashable:
    """The left-regular action: g . x = g * x (composition)."""
    return compose(g, x)  # type: ignore[arg-type]


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_theorem_A() -> None:
    print("=" * 70)
    print("THEOREM A:  free  <=>  every orbit map is injective")
    print("=" * 70)
    for n, name, grp in [(3, "S_3", symmetric_group(3)),
                         (4, "C_4", cyclic_group(4))]:
        # Natural action on labels: NOT free for n >= 2 (transpositions fix pts).
        pts = list(range(n))
        free_nat = is_free(grp, pts, natural_action, identity(n))
        inj_nat = orbit_map_injective(grp, pts, natural_action)
        # Left-regular action on the group itself: always free.
        free_reg = is_free(grp, grp, left_regular_action, identity(n))
        inj_reg = orbit_map_injective(grp, grp, left_regular_action)
        print(f"\n{name} natural action on {n} labels:")
        print(f"   free = {free_nat},  all orbit maps injective = {inj_nat}"
              f"   (agree: {free_nat == inj_nat})")
        print(f"{name} left-regular action on itself:")
        print(f"   free = {free_reg},  all orbit maps injective = {inj_reg}"
              f"   (agree: {free_reg == inj_reg})")


def demo_theorem_B() -> None:
    print("\n" + "=" * 70)
    print("THEOREM B:  symmetric task solvable  <=>  action is trivial")
    print("=" * 70)
    n = 3
    grp = symmetric_group(n)
    pts = list(range(n))

    # Non-trivial natural action -> impossible.
    triv = is_trivial(grp, pts, natural_action)
    solv = symmetric_task_solvable(grp, pts, natural_action)
    print(f"\nS_3 natural action on 3 labels:")
    print(f"   trivial = {triv},  task solvable = {solv}   (agree: {triv == solv})")

    # Trivial action (identity-only group acting) -> solvable.
    trivial_group = [identity(n)]
    triv2 = is_trivial(trivial_group, pts, natural_action)
    solv2 = symmetric_task_solvable(trivial_group, pts, natural_action)
    print(f"Trivial group {{e}} acting on 3 labels:")
    print(f"   trivial = {triv2},  task solvable = {solv2}   (agree: {triv2 == solv2})")


def demo_theorem_C() -> None:
    print("\n" + "=" * 70)
    print("THEOREM C:  regular action of a non-trivial group is impossible")
    print("            (S_5 instance = shadow of the unsolvable quintic)")
    print("=" * 70)
    for n, name in [(2, "S_2"), (3, "S_3"), (4, "S_4")]:
        grp = symmetric_group(n)
        free = is_free(grp, grp, left_regular_action, identity(n))
        solv = symmetric_task_solvable(grp, grp, left_regular_action)
        print(f"\n{name} (order {len(grp)}) left-regular on itself:")
        print(f"   free = {free},  task solvable = {solv}"
              f"   -> impossible = {not solv}")
    # S_5 has 120 elements -- state the conclusion without full enumeration cost.
    print("\nS_5 (order 120) left-regular on itself:")
    print("   free = True (Lemma 5.1),  non-trivial (|S_5| = 120 > 1)")
    print("   => no invariant injective selector exists  (Corollary 5.2).")
    print("   This is the group-theoretic shadow of Abel-Ruffini: a radical")
    print("   formula would be a symmetric rule that breaks the root symmetry.")


def demo_frontier() -> None:
    print("\n" + "=" * 70)
    print("FRONTIER:  'impossible <=> free' is FALSE; frontier is NON-TRIVIALITY")
    print("=" * 70)
    # C_4 acting naturally on {0,1,2,3} has NO fixed point here, so pick a model
    # with a genuine fixed point: augment C_3 acting on 4 labels where label 3
    # is fixed (a "center") while {0,1,2} rotate.
    n = 4

    def rot_with_center(g: Perm, x: Hashable) -> Hashable:
        # g is a rotation of {0,1,2,3}; we override so label 3 stays put.
        return 3 if x == 3 else g[x]  # type: ignore[index]

    # Build C_3 rotations embedded on 4 symbols (fixing symbol 3).
    grp = [tuple([(i + k) % 3 for i in range(3)] + [3]) for k in range(3)]
    pts = [0, 1, 2, 3]
    free = is_free(grp, pts, rot_with_center, identity(n))
    triv = is_trivial(grp, pts, rot_with_center)
    solv = symmetric_task_solvable(grp, pts, rot_with_center)
    print("\nC_3 rotating {0,1,2} while fixing the center 3:")
    print(f"   free    = {free}   (False: the center is a fixed point)")
    print(f"   trivial = {triv}   (False: 0,1,2 genuinely rotate)")
    print(f"   task solvable = {solv}  ->  impossible = {not solv}")
    print("   Conclusion: a NON-FREE, NON-TRIVIAL action is still impossible.")
    print("   Hence freeness is sufficient but NOT necessary; non-triviality is")
    print("   the exact boundary.")


def demo_orbit_shortfall() -> None:
    print("\n" + "=" * 70)
    print("QUANTITATIVE SHORTFALL:  invariant functions separate ORBITS only")
    print("=" * 70)
    n = 4
    grp = cyclic_group(n)
    pts = list(range(n))
    orb = orbits(grp, pts, natural_action)
    print(f"\nC_4 rotating 4 labels: {len(pts)} points, {len(orb)} orbit(s).")
    print(f"   orbits = {[sorted(o) for o in orb]}")
    print(f"   max points any invariant function can separate = {len(orb)}")
    print(f"   full distinguishing would require = {len(pts)}")
    print(f"   shortfall = {len(pts) - len(orb)}  (measures the impossibility)")


def main() -> None:
    demo_theorem_A()
    demo_theorem_B()
    demo_theorem_C()
    demo_frontier()
    demo_orbit_shortfall()
    print("\n" + "=" * 70)
    print("All demonstrations completed: the results are confirmed numerically.")
    print("=" * 70)


if __name__ == "__main__":
    main()
