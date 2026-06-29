"""
Numerical / computational demonstration of the Logic-Physics Bridge.

This script makes the abstract theorems of the framework concrete by building
tiny, finite proof systems and semantics over a small sentence space and
*checking* each theorem by exhaustive evaluation.

The framework (all over a finite sentence type S):

  ProofSystem:  bot in S, Proves: (frozenset[S], S) -> bool,
                closed under weakening + assumption.
  Semantics:    a list of worlds, sat: (world, S) -> bool,
                with no world satisfying bot.
  Consistent(T)            := not Proves(T, bot)
  HasModel(T)              := exists world satisfying every phi in T
  PhysicallyConsistent(T)  := HasModel(T)
  Sound                    := every proved sentence true in every model of premises
  FalsumSound              := the same, restricted to phi = bot

We demonstrate:
  * consistency_antimono        (Theorem 2.3)
  * proper_extension_new_theorem(Theorem 2.4)
  * model_implies_consistency   (Theorems 4.1, 4.3, 4.4 -- the bridge)
  * sound_implies_falsum_sound  (Theorem 4.2)
  * falsum_sound_strictly_weaker(Theorem 5.1)
  * math_consistency_not_sufficient (Theorem 6.1 -- separation, empty world)
  * completeness_collapse       (Theorem 7.2)

Everything is self-contained: no imports beyond the standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import chain, combinations
from typing import Callable, FrozenSet, Iterable, List, Sequence, Tuple

Sentence = int
Theory = FrozenSet[Sentence]


# --------------------------------------------------------------------------- #
# Core structures
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class ProofSystem:
    """An abstract proof system over a finite sentence space."""

    bot: Sentence
    sentences: Tuple[Sentence, ...]
    proves: Callable[[Theory, Sentence], bool]

    def consistent(self, theory: Theory) -> bool:
        """Consistent(T) := not (T |- bot)."""
        return not self.proves(theory, self.bot)


@dataclass(frozen=True)
class Semantics:
    """A semantics ('physics') for a proof system: worlds + satisfaction."""

    worlds: Tuple[int, ...]
    sat: Callable[[int, Sentence], bool]

    def has_model(self, theory: Theory) -> bool:
        """HasModel(T) := exists a world satisfying every sentence of T."""
        return any(
            all(self.sat(w, phi) for phi in theory) for w in self.worlds
        )

    # PhysicallyConsistent is, by definition, HasModel.
    physically_consistent = has_model


def powerset(items: Sequence[Sentence]) -> Iterable[Theory]:
    """All subsets of `items`, as frozensets (theories)."""
    return (
        frozenset(combo)
        for r in range(len(items) + 1)
        for combo in combinations(items, r)
    )


# --------------------------------------------------------------------------- #
# Soundness / falsum-soundness checkers (exhaustive)
# --------------------------------------------------------------------------- #
def is_sound(ps: ProofSystem, sem: Semantics) -> bool:
    """Sound: for every Gamma, phi, world w, if Gamma|-phi and w models Gamma
    then w |= phi."""
    for gamma in powerset(ps.sentences):
        for phi in ps.sentences:
            if not ps.proves(gamma, phi):
                continue
            for w in sem.worlds:
                if all(sem.sat(w, psi) for psi in gamma) and not sem.sat(w, phi):
                    return False
    return True


def is_falsum_sound(ps: ProofSystem, sem: Semantics) -> bool:
    """FalsumSound: the soundness condition restricted to phi = bot."""
    for gamma in powerset(ps.sentences):
        if not ps.proves(gamma, ps.bot):
            continue
        for w in sem.worlds:
            if all(sem.sat(w, psi) for psi in gamma) and not sem.sat(w, ps.bot):
                return False
    return True


# --------------------------------------------------------------------------- #
# Example 1: a classical, sound propositional-style system
# --------------------------------------------------------------------------- #
# Sentences: 0 = bot, 1 = "p", 2 = "q".  Rule: from {p} derive p (assumption
# only) -- a minimal honest system; bot is only provable if bot in Gamma.
def classical_proves(gamma: Theory, phi: Sentence) -> bool:
    return phi in gamma  # assumption + weakening; nothing else derivable


CLASSICAL = ProofSystem(bot=0, sentences=(0, 1, 2), proves=classical_proves)

# Two worlds: world 0 satisfies {p}, world 1 satisfies {p, q}; neither bot.
def classical_sat(w: int, phi: Sentence) -> bool:
    table = {0: {1}, 1: {1, 2}}
    return phi in table[w]


CLASSICAL_SEM = Semantics(worlds=(0, 1), sat=classical_sat)


# --------------------------------------------------------------------------- #
# Example 2: falsum-sound but NOT sound (Theorem 5.1)
# --------------------------------------------------------------------------- #
# bot = 0; extra unsound rule "from 1, conclude 2".  One world: only 1 is true.
def weak_proves(gamma: Theory, phi: Sentence) -> bool:
    return (phi in gamma) or (1 in gamma and phi == 2)


WEAK = ProofSystem(bot=0, sentences=(0, 1, 2), proves=weak_proves)


def weak_sat(w: int, phi: Sentence) -> bool:
    return phi == 1  # the single world satisfies only sentence 1


WEAK_SEM = Semantics(worlds=(0,), sat=weak_sat)


# --------------------------------------------------------------------------- #
# Example 3: empty-world semantics (Theorem 6.1, separation)
# --------------------------------------------------------------------------- #
EMPTY_SEM = Semantics(worlds=(), sat=lambda w, phi: False)


# --------------------------------------------------------------------------- #
# Theorem checks
# --------------------------------------------------------------------------- #
def check_consistency_antimono(ps: ProofSystem) -> bool:
    """Theorem 2.3: Gamma <= Delta and Consistent(Delta) => Consistent(Gamma)."""
    for delta in powerset(ps.sentences):
        if not ps.consistent(delta):
            continue
        for gamma in powerset(tuple(delta)):
            if not ps.consistent(gamma):
                return False
    return True


def check_proper_extension(ps: ProofSystem) -> bool:
    """Theorem 2.4: not(T|-phi) => phi not in T and (insert phi T)|-phi."""
    for theory in powerset(ps.sentences):
        for phi in ps.sentences:
            if not ps.proves(theory, phi):
                if phi in theory:
                    return False
                if not ps.proves(theory | {phi}, phi):
                    return False
    return True


def check_bridge(ps: ProofSystem, sem: Semantics) -> bool:
    """Theorems 4.1/4.3/4.4: if falsum-sound and HasModel(T) then Consistent(T)."""
    if not is_falsum_sound(ps, sem):
        return True  # hypothesis fails; theorem says nothing
    for theory in powerset(ps.sentences):
        if sem.has_model(theory) and not ps.consistent(theory):
            return False
    return True


def check_sound_implies_falsum_sound(ps: ProofSystem, sem: Semantics) -> bool:
    """Theorem 4.2."""
    return (not is_sound(ps, sem)) or is_falsum_sound(ps, sem)


def check_completeness_collapse(ps: ProofSystem, sem: Semantics) -> bool:
    """Theorem 7.2: if sound AND complete then Consistent <-> PhysicallyConsistent."""
    complete = all(
        sem.has_model(t) for t in powerset(ps.sentences) if ps.consistent(t)
    )
    if not (is_sound(ps, sem) and complete):
        return True  # hypotheses fail; theorem says nothing
    return all(
        ps.consistent(t) == sem.physically_consistent(t)
        for t in powerset(ps.sentences)
    )


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 68)
    print("LOGIC-PHYSICS BRIDGE: computational demonstration")
    print("=" * 68)

    print("\n[Theorem 2.3] consistency is anti-monotone (classical system):")
    print("   verified:", check_consistency_antimono(CLASSICAL))

    print("\n[Theorem 2.4] unprovable sentence => proper new-theorem extension:")
    print("   verified (classical):", check_proper_extension(CLASSICAL))
    print("   verified (weak):     ", check_proper_extension(WEAK))

    print("\n[Theorem 4.2] full soundness => falsum-soundness:")
    print("   classical sound? ", is_sound(CLASSICAL, CLASSICAL_SEM))
    print("   classical f-sound?", is_falsum_sound(CLASSICAL, CLASSICAL_SEM))
    print("   implication holds:", check_sound_implies_falsum_sound(CLASSICAL, CLASSICAL_SEM))

    print("\n[Theorems 4.1/4.3/4.4] bridge: model => consistency (classical):")
    print("   verified:", check_bridge(CLASSICAL, CLASSICAL_SEM))
    T = frozenset({1, 2})
    print(f"   theory {set(T)}: has_model={CLASSICAL_SEM.has_model(T)}, "
          f"consistent={CLASSICAL.consistent(T)}")

    print("\n[Theorem 5.1] falsum-sound STRICTLY weaker than sound (weak system):")
    print("   weak f-sound? ", is_falsum_sound(WEAK, WEAK_SEM))
    print("   weak sound?   ", is_sound(WEAK, WEAK_SEM), " (expected False)")
    print("   witness: {1} |- 2 while world models 1 but not 2:",
          weak_proves(frozenset({1}), 2) and weak_sat(0, 1) and not weak_sat(0, 2))

    print("\n[Theorem 6.1] separation: consistent but NO model (empty world):")
    empty_theory: Theory = frozenset()
    print("   empty theory consistent?           ", CLASSICAL.consistent(empty_theory))
    print("   empty theory physically consistent?",
          EMPTY_SEM.physically_consistent(empty_theory), " (expected False)")
    print("   => mathematical consistency does NOT imply physical consistency")

    print("\n[Theorem 7.2] completeness collapse (classical sound+complete):")
    complete = all(
        CLASSICAL_SEM.has_model(t)
        for t in powerset(CLASSICAL.sentences)
        if CLASSICAL.consistent(t)
    )
    print("   classical complete?", complete)
    print("   collapse verified: ", check_completeness_collapse(CLASSICAL, CLASSICAL_SEM))

    print("\n" + "=" * 68)
    print("All checks completed.")
    print("=" * 68)


if __name__ == "__main__":
    main()
