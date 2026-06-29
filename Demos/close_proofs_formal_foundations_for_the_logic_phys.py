"""
demo.py — Numerical demonstrations of the Logic–Physics Bridge.

This script realizes, over *finite* state spaces, the abstract notions from the
formal development:

    Theory S      := set of laws (predicates S -> bool)
    IsModel T s   := s satisfies every law in T
    Realizable T  := exists s, IsModel T s
    Entails T phi := for all s, IsModel T s -> phi s
    Consistent T  := not Entails T False

and verifies the headline theorem and its structural corollaries by exhaustive
search over the (finite) state space:

    Theorem  realizable_iff_consistent : Realizable T  <->  Consistent T
    Cor.     not_realizable_entails_all : ¬Realizable T -> Entails T phi
    Cor.     entails_false_iff_not_realizable
    Cor.     realizable_of_subset       : T ⊆ T', Realizable T' -> Realizable T
    Cor.     contradiction_not_realizable
    Cor.     product_realizable_iff     : Realizable (T×T') <-> Realizable T ∧ Realizable T'

It also illustrates the dynamical bridge: a *serial* step relation with a
nonempty initial set admits an infinite (here: arbitrarily long) trajectory.

Everything is self-contained (standard library only) and fully type-hinted.
"""

from __future__ import annotations

from itertools import product as iproduct
from typing import Callable, Iterable, List, Sequence, Tuple, TypeVar

S = TypeVar("S")
T = TypeVar("T")

# A law over a finite state space is a predicate; a theory is a list of laws.
Law = Callable[[S], bool]
Theory = List[Law]


# --------------------------------------------------------------------------- #
# Core semantic notions (finite, decidable versions of the Lean definitions)
# --------------------------------------------------------------------------- #
def is_model(theory: Theory[S], s: S) -> bool:
    """IsModel T s := s satisfies every law of T."""
    return all(law(s) for law in theory)


def realizable(theory: Theory[S], space: Sequence[S]) -> bool:
    """Realizable T := exists s in space, IsModel T s."""
    return any(is_model(theory, s) for s in space)


def entails(theory: Theory[S], phi: Law[S], space: Sequence[S]) -> bool:
    """Entails T phi := for all models s of T, phi s holds."""
    return all(phi(s) for s in space if is_model(theory, s))


def consistent(theory: Theory[S], space: Sequence[S]) -> bool:
    """Consistent T := not (Entails T False)."""
    false_law: Law[S] = lambda _s: False
    return not entails(theory, false_law, space)


# --------------------------------------------------------------------------- #
# Product theory on S x S'
# --------------------------------------------------------------------------- #
def product_theory(
    theory: Theory[S], theory2: Theory[T]
) -> Theory[Tuple[S, T]]:
    """Lift each law of T to the first coordinate and each law of T' to the second."""
    lifted: Theory[Tuple[S, T]] = []
    for law in theory:
        lifted.append(lambda x, law=law: law(x[0]))
    for law2 in theory2:
        lifted.append(lambda x, law2=law2: law2(x[1]))
    return lifted


def product_space(
    space: Sequence[S], space2: Sequence[T]
) -> List[Tuple[S, T]]:
    return list(iproduct(space, space2))


# --------------------------------------------------------------------------- #
# Dynamical bridge: serial relation -> infinite trajectory
# --------------------------------------------------------------------------- #
def is_serial(step: Callable[[S, S], bool], space: Sequence[S]) -> bool:
    """Serial: from every state at least one successor exists."""
    return all(any(step(s, t) for t in space) for s in space)


def build_trajectory(
    init: Sequence[S],
    step: Callable[[S, S], bool],
    space: Sequence[S],
    length: int,
) -> List[S]:
    """Construct a finite prefix of an eternal trajectory by choosing successors.

    Mirrors the Lean proof: choose s0 in init, then repeatedly choose a legal
    successor (the 'choice function' next : S -> S)."""
    assert init, "initial set must be nonempty"
    assert is_serial(step, space), "step relation must be serial"
    traj: List[S] = [next(iter(init))]
    for _ in range(length - 1):
        s = traj[-1]
        successor = next(t for t in space if step(s, t))  # Axiom-of-choice step
        traj.append(successor)
    return traj


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_central_bridge() -> None:
    banner("1. Central bridge:  Realizable T  <->  Consistent T")
    space: List[int] = list(range(-3, 4))  # states are integers -3..3

    cases: List[Tuple[str, Theory[int]]] = [
        ("positive AND even (realizable: s=2)", [lambda s: s > 0, lambda s: s % 2 == 0]),
        ("positive AND negative (contradiction)", [lambda s: s > 0, lambda s: s < 0]),
        ("equals 5 (no such state in -3..3)", [lambda s: s == 5]),
        ("any integer (empty theory)", []),
    ]
    for name, theory in cases:
        r = realizable(theory, space)
        c = consistent(theory, space)
        status = "OK" if r == c else "MISMATCH!"
        print(f"  {name:42s} | Realizable={r!s:5} Consistent={c!s:5} [{status}]")
    print("  => Realizable and Consistent agree in every case.")


def demo_explosion_and_duality() -> None:
    banner("2. Explosion & duality on an unrealizable theory")
    space: List[int] = list(range(-3, 4))
    theory: Theory[int] = [lambda s: s > 0, lambda s: s < 0]  # unrealizable
    print(f"  Realizable = {realizable(theory, space)}")
    # Explosion: unrealizable theory entails every predicate.
    test_preds: List[Tuple[str, Law[int]]] = [
        ("s == 42", lambda s: s == 42),
        ("s is prime", lambda s: s in (2, 3, 5, 7)),
        ("False", lambda _s: False),
    ]
    for name, phi in test_preds:
        print(f"  Entails (phi = {name:10s}) = {entails(theory, phi, space)}")
    # Duality: Entails False  <->  not Realizable
    ef = entails(theory, lambda _s: False, space)
    nr = not realizable(theory, space)
    print(f"  Entails False = {ef}, not Realizable = {nr}, equal = {ef == nr}")


def demo_monotonicity() -> None:
    banner("3. Monotonicity: T ⊆ T', Realizable T' -> Realizable T")
    space: List[int] = list(range(0, 10))
    law_even: Law[int] = lambda s: s % 2 == 0
    law_gt4: Law[int] = lambda s: s > 4
    big: Theory[int] = [law_even, law_gt4]          # realized by 6, 8
    small: Theory[int] = [law_even]                  # superset of models
    print(f"  Realizable(T')={realizable(big, space)} (T' = even AND >4)")
    print(f"  Realizable(T) ={realizable(small, space)} (T  = even)")
    print("  Dropping the law '>4' preserves a model => monotonicity holds.")


def demo_compositionality() -> None:
    banner("4. Compositionality: Realizable(T×T') <-> Realizable T ∧ Realizable T'")
    space_a: List[int] = list(range(0, 5))
    space_b: List[str] = ["red", "green", "blue"]
    t_a: Theory[int] = [lambda s: s % 2 == 0]        # realizable (0,2,4)
    t_b_ok: Theory[str] = [lambda c: c.startswith("g")]   # realizable (green)
    t_b_bad: Theory[str] = [lambda c: c == "purple"]      # unrealizable

    for label, t_b in [("realizable T'", t_b_ok), ("unrealizable T'", t_b_bad)]:
        prod = product_theory(t_a, t_b)
        psp = product_space(space_a, space_b)
        lhs = realizable(prod, psp)
        rhs = realizable(t_a, space_a) and realizable(t_b, space_b)
        print(f"  [{label:16s}] Realizable(T×T')={lhs!s:5} | "
              f"Realizable T ∧ Realizable T'={rhs!s:5} | equal={lhs == rhs}")


def demo_physics_energy() -> None:
    banner("5. Physics instantiation: energy conservation & two-level no-go")
    # Discretized energy levels of a system.
    space: List[float] = [0.0, 1.0, 2.0, 3.0]
    energy: Callable[[float], float] = lambda s: s  # observable E(s) = s

    # Conservation at e0 = 2.0 is realizable: state s = 2.0 attains it.
    e0 = 2.0
    conservation: Theory[float] = [lambda s: abs(energy(s) - e0) < 1e-9]
    print(f"  Conservation E=={e0}: Realizable={realizable(conservation, space)} "
          f"(witness s={e0})")

    # Over-constrained two-level demand: E==2 AND E!=2  -> contradiction.
    contradictory: Theory[float] = [
        lambda s: abs(energy(s) - e0) < 1e-9,
        lambda s: not (abs(energy(s) - e0) < 1e-9),
    ]
    print(f"  Demand E==2 AND E!=2: Realizable={realizable(contradictory, space)} "
          f"(no-go theorem fires)")


def demo_temporal() -> None:
    banner("6. Dynamical bridge: serial law -> eternal trajectory")
    space: List[int] = list(range(0, 6))
    # Cyclic successor: never stuck (serial).
    step: Callable[[int, int], bool] = lambda s, t: t == (s + 1) % 6
    init: List[int] = [0]
    print(f"  Serial(step) = {is_serial(step, space)}")
    traj = build_trajectory(init, step, space, length=12)
    print(f"  Trajectory prefix (len 12): {traj}")
    # Verify legality of the constructed trajectory.
    legal = traj[0] in init and all(step(traj[i], traj[i + 1]) for i in range(len(traj) - 1))
    print(f"  Trajectory legal = {legal}")


def main() -> None:
    demo_central_bridge()
    demo_explosion_and_duality()
    demo_monotonicity()
    demo_compositionality()
    demo_physics_energy()
    demo_temporal()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
