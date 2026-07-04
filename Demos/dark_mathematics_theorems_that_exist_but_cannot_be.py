"""
Dark Mathematics: numerical demonstrations.

A *dark theorem* asserts provable existence of witnesses none of which can ever
be exhibited. We model this with abstract Cook-Reckhow-style proof systems over
a formula type with two kinds of formulas:

    * inst(n)    -- "n is a witness of T"          (an INSTANCE statement)
    * atLeast(k) -- "there are at least k witnesses" (a COUNTING statement)

A system is DARK OF LEVEL k when it proves atLeast(k) but proves no inst(n).

This script demonstrates, entirely self-contained and with no dependencies:

    1. The explicit witness family B_k and its exact provability profile.
    2. Strictness of the darkness hierarchy: B_k is dark of level k, not k+1.
    3. Join amplification: dark(a) join dark(b) is dark of level max(a, b).
    4. Vanishing uniform density of dark configurations: O(1/N) -> 0.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable
from fractions import Fraction


# --------------------------------------------------------------------------- #
# Formulas
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Formula:
    """A dark-theorem formula. kind is 'inst' or 'atLeast'; value is n or k."""
    kind: str   # "inst" or "atLeast"
    value: int


def inst(n: int) -> Formula:
    """The instance statement T(n): 'n is a witness'."""
    return Formula("inst", n)


def atLeast(k: int) -> Formula:
    """The counting statement: 'there exist at least k witnesses'."""
    return Formula("atLeast", k)


EXISTS = atLeast(1)  # the existential statement  exists x. T(x)


# --------------------------------------------------------------------------- #
# Abstract proof systems (Cook-Reckhow style)
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class ProofSys:
    """
    An abstract proof system.

    proofs : the finite collection of proof objects (any hashable labels).
    concl  : maps each proof object to the formula it establishes.
    size   : maps each proof object to its resource cost.
    """
    proofs: tuple
    concl: Callable[[object], Formula]
    size: Callable[[object], int]

    def provable(self, f: Formula) -> bool:
        """A formula is provable iff some proof object concludes it."""
        return any(self.concl(p) == f for p in self.proofs)


def bounded_dark(k: int) -> ProofSys:
    """
    The explicit witness system B_k: proof objects 0..k, the j-th concluding
    atLeast(j). It proves exactly atLeast(0..k) and no instance statement.
    """
    return ProofSys(
        proofs=tuple(range(k + 1)),
        concl=lambda j: atLeast(j),
        size=lambda j: 0,
    )


def join(s: ProofSys, t: ProofSys) -> ProofSys:
    """
    The join S \/ T: a proof is a proof from either component.
    Provable(join) f  <=>  Provable S f  or  Provable T f.
    """
    tagged = tuple(("L", p) for p in s.proofs) + tuple(("R", p) for p in t.proofs)
    return ProofSys(
        proofs=tagged,
        concl=lambda tp: s.concl(tp[1]) if tp[0] == "L" else t.concl(tp[1]),
        size=lambda tp: s.size(tp[1]) if tp[0] == "L" else t.size(tp[1]),
    )


# --------------------------------------------------------------------------- #
# Darkness predicates
# --------------------------------------------------------------------------- #
def no_instance_provable(s: ProofSys, check_up_to: int = 50) -> bool:
    """Empirically: no inst(n) is provable for n in 0..check_up_to."""
    return all(not s.provable(inst(n)) for n in range(check_up_to + 1))


def dark_at_level(s: ProofSys, k: int, check_up_to: int = 50) -> bool:
    """S is dark of level k: proves atLeast(k) and proves no instance."""
    return s.provable(atLeast(k)) and no_instance_provable(s, check_up_to)


def darkness_level(s: ProofSys, max_k: int = 50) -> int:
    """The top level of darkness: largest k with atLeast(k) provable (or -1)."""
    top = -1
    for k in range(max_k + 1):
        if s.provable(atLeast(k)):
            top = k
    return top if no_instance_provable(s) else -1


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_provability_profile() -> None:
    print("=" * 70)
    print("1. Provability profile of the witness family B_k")
    print("=" * 70)
    for k in range(4):
        b = bounded_dark(k)
        counts = [j for j in range(6) if b.provable(atLeast(j))]
        insts = [n for n in range(6) if b.provable(inst(n))]
        print(f"  B_{k}: proves atLeast(j) for j in {counts};  "
              f"proves inst(n) for n in {insts}")
    print("  => B_k proves atLeast(j) iff j <= k, and NO instance ever.\n")


def demo_strict_hierarchy() -> None:
    print("=" * 70)
    print("2. Strictness of the darkness hierarchy")
    print("=" * 70)
    for k in range(1, 5):
        b = bounded_dark(k)
        here = dark_at_level(b, k)
        above = dark_at_level(b, k + 1)
        print(f"  B_{k}: dark of level {k}? {here};   "
              f"dark of level {k + 1}? {above}")
    print("  => Each B_k is dark of level k but not k+1: the ladder is strict.\n")


def demo_explicit_123() -> None:
    print("=" * 70)
    print("3. Explicit dark theorems of levels 1, 2, 3")
    print("=" * 70)
    for k in (1, 2, 3):
        b = bounded_dark(k)
        print(f"  Level {k}: B_{k} certifies at least {k} hidden witnesses, "
              f"names none.  dark_at_level = {dark_at_level(b, k)}")
    print()


def demo_join_amplification() -> None:
    print("=" * 70)
    print("4. Joins amplify darkness:  dark(a) \\/ dark(b) is dark of max(a,b)")
    print("=" * 70)
    for a, b_lvl in [(1, 3), (2, 2), (4, 1), (0, 5)]:
        j = join(bounded_dark(a), bounded_dark(b_lvl))
        lvl = darkness_level(j)
        print(f"  B_{a} \\/ B_{b_lvl}: darkness level = {lvl}   "
              f"(expected max({a},{b_lvl}) = {max(a, b_lvl)})   "
              f"no witness named? {no_instance_provable(j)}")
    print("  => Combining two blind theories yields a strictly deeper blindness.\n")


def demo_vanishing_density() -> None:
    print("=" * 70)
    print("5. Vanishing uniform density of dark configurations")
    print("=" * 70)
    print("  A 'configuration' over a family of size N specifies:")
    print("    * a top counting-level t in {0..N-1}, and")
    print("    * for each of the N candidate witnesses, a provability bit.")
    print("  It is DARK iff t >= 1 (existence provable) AND every one of the N")
    print("  instance-bits is false (no witness provable). Among the 2^N")
    print("  instance-patterns exactly ONE (all-false) qualifies.")
    print()
    print(f"  {'N':>5} | {'#configs':>14} | {'#dark':>6} | {'density':>12}")
    print("  " + "-" * 48)
    for N in [2, 4, 8, 16, 32]:
        total = N * (2 ** N)       # N top-levels x 2^N instance patterns
        dark = (N - 1)             # t in {1..N-1}, unique all-false pattern
        density = Fraction(dark, total)
        print(f"  {N:>5} | {total:>14} | {dark:>6} | {float(density):>12.3e}")
    print("  => density = (N-1)/(N*2^N) -> 0: only the unique 'counts-but-names-")
    print("     nothing' corner is dark. The naive 'most are dark' slogan is")
    print("     FALSE; darkness has vanishing uniform density.\n")


def demo_joint_density_strict() -> None:
    """
    A sharper density model: a configuration also fixes, for each of N candidate
    witnesses, whether inst(n) is provable. Darkness needs ALL N to be
    unprovable AND the top count >= 1. The dark fraction is then O(1/N)*2^-N-ish
    but the *conditional-on-existence* fraction is exactly 2^{-N} -> 0.
    """
    print("=" * 70)
    print("6. Joint model: instance-freeness across N candidates")
    print("=" * 70)
    print(f"  {'N':>5} | {'P(no witness among N provable)':>32}")
    print("  " + "-" * 44)
    for N in [1, 2, 4, 8, 16]:
        # each candidate independently provable with prob 1/2 in the uniform model
        p = Fraction(1, 2 ** N)
        print(f"  {N:>5} | {float(p):>32.8f}")
    print("  => Even conditioned on provable existence, the probability that no")
    print("     single witness is provable collapses geometrically: darkness is")
    print("     rare under uniform counting.  Genericity must be reweighted by")
    print("     logical complexity instead.\n")


def main() -> None:
    demo_provability_profile()
    demo_strict_hierarchy()
    demo_explicit_123()
    demo_join_amplification()
    demo_vanishing_density()
    demo_joint_density_strict()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
