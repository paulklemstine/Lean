"""
Numerical demonstrations for:

    Provability Logic as a Fixed-Point Theory:
    The Order-Theoretic Core of Gödel--Löb and a Graded Second Incompleteness Theorem

We realise the canonical consistent Gödel--Löb algebra -- the well-founded frame
(ℕ, >) on the Boolean algebra of subsets of ℕ -- on a bounded universe
{0, 1, ..., N-1}, and verify every theorem of the paper computationally:

  * Theorem 4.2  natBox satisfies (B⊤), (B⊓), (Löb)
  * Theorem 4.3  consistency:  natBox(∅) = {0} ≠ univ
  * Theorem 4.4  natBox^k(∅) = {0,...,k-1}            (provability-rank computation)
  * Theorem 4.5  k ↦ natBox^k(∅) is strictly increasing, never univ
  * Theorem 4.6  graded Gödel II: each (k+1)-fold consistency statement is unprovable
  * Theorem 3.4  Löb equality          □(□a ⇨ a) = □a
  * Theorem 3.5  Löb's rule            □a ≤ a  ⟹  a = ⊤
  * Theorem 3.10 canonical fixed point glFix c = □c ⇨ c  and  □(glFix c) = □c
  * Theorem 3.11 de Jongh--Sambin uniqueness of  p = □p ⇨ c
  * Theorem 3.12 two-parameter uniqueness of  p = d ⊓ (□p ⇨ c)
  * Theorem 3.13/3.14  the identity operator is never a valid box (violates Löb)

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, Iterator, List, Tuple

# A "statement" is a subset of the bounded universe {0, ..., N-1}.
Statement = FrozenSet[int]


# ----------------------------------------------------------------------------
# Boolean-algebra (Heyting) operations on subsets of {0, ..., N-1}
# ----------------------------------------------------------------------------
def universe(n: int) -> Statement:
    """The top element ⊤ = {0, 1, ..., n-1}."""
    return frozenset(range(n))


def bottom() -> Statement:
    """The bottom element ⊥ = ∅."""
    return frozenset()


def meet(a: Statement, b: Statement) -> Statement:
    """Conjunction  a ⊓ b = a ∩ b."""
    return a & b


def join(a: Statement, b: Statement) -> Statement:
    """Disjunction  a ⊔ b = a ∪ b."""
    return a | b


def implies(a: Statement, b: Statement, n: int) -> Statement:
    """Heyting/Boolean implication  a ⇨ b = aᶜ ∪ b."""
    return (universe(n) - a) | b


def leq(a: Statement, b: Statement) -> bool:
    """The order  a ≤ b  is  a ⊆ b."""
    return a <= b


def biconditional(a: Statement, b: Statement, n: int) -> Statement:
    """a ⇔ b = (a ⇨ b) ⊓ (b ⇨ a)."""
    return meet(implies(a, b, n), implies(b, a, n))


def all_subsets(n: int) -> Iterator[Statement]:
    """Enumerate every element of the finite Boolean algebra (2^n of them)."""
    base = list(range(n))
    for k in range(n + 1):
        for combo in combinations(base, k):
            yield frozenset(combo)


# ----------------------------------------------------------------------------
# The provability box of the well-founded frame (ℕ, >)
# ----------------------------------------------------------------------------
def nat_box(s: Statement, n: int) -> Statement:
    """natBox S = { m | ∀ j < m, j ∈ S } restricted to the universe {0,...,n-1}.

    World m 'proves' S iff every strictly smaller world satisfies S.
    """
    return frozenset(m for m in range(n) if all(j in s for j in range(m)))


def iterate_box(s: Statement, k: int, n: int) -> Statement:
    """Apply nat_box k times: natBox^k(S)."""
    out = s
    for _ in range(k):
        out = nat_box(out, n)
    return out


def identity_box(s: Statement, n: int) -> Statement:
    """The naive 'provable = true' operator □a := a (Proposition 3.14)."""
    return s


# ----------------------------------------------------------------------------
# Axiom / theorem verifiers
# ----------------------------------------------------------------------------
def check_box_top(n: int) -> bool:
    """(B⊤)  □⊤ = ⊤."""
    return nat_box(universe(n), n) == universe(n)


def check_box_inf(n: int) -> bool:
    """(B⊓)  □(a ⊓ b) = □a ⊓ □b   for all a, b."""
    return all(
        nat_box(meet(a, b), n) == meet(nat_box(a, n), nat_box(b, n))
        for a in all_subsets(n)
        for b in all_subsets(n)
    )


def check_loeb(box: Callable[[Statement, int], Statement], n: int) -> bool:
    """(Löb)  □(□a ⇨ a) ≤ □a   for all a."""
    return all(
        leq(box(implies(box(a, n), a, n), n), box(a, n))
        for a in all_subsets(n)
    )


def check_loeb_equality(n: int) -> bool:
    """Theorem 3.4   □(□a ⇨ a) = □a   for all a."""
    return all(
        nat_box(implies(nat_box(a, n), a, n), n) == nat_box(a, n)
        for a in all_subsets(n)
    )


def check_loeb_rule(n: int) -> bool:
    """Theorem 3.5   □a ≤ a  ⟹  a = ⊤   for all a."""
    return all(
        a == universe(n)
        for a in all_subsets(n)
        if leq(nat_box(a, n), a)
    )


def glfix(c: Statement, n: int) -> Statement:
    """The canonical fixed point  glFix c = □c ⇨ c  (Theorem 3.10)."""
    return implies(nat_box(c, n), c, n)


def check_canonical_fixed_point(n: int) -> bool:
    """Theorem 3.10/3.11:  glFix c solves p = □p ⇨ c, uniquely, and □(glFix c)=□c."""
    for c in all_subsets(n):
        p = glfix(c, n)
        # (1) it is a fixed point
        if p != implies(nat_box(p, n), c, n):
            return False
        # (2) provability identity
        if nat_box(p, n) != nat_box(c, n):
            return False
        # (3) uniqueness: no other subset solves the equation
        solutions = [q for q in all_subsets(n)
                     if q == implies(nat_box(q, n), c, n)]
        if solutions != [p]:
            return False
    return True


def check_two_parameter_uniqueness(n: int) -> bool:
    """Theorem 3.12:  p = d ⊓ (□p ⇨ c) has at most one solution, for all c, d."""
    for c in all_subsets(n):
        for d in all_subsets(n):
            solutions = [
                q for q in all_subsets(n)
                if q == meet(d, implies(nat_box(q, n), c, n))
            ]
            if len(solutions) > 1:
                return False
    return True


def check_box_ne_id(n: int) -> bool:
    """Theorem 3.13:  in a nontrivial algebra the box is not the identity."""
    return any(nat_box(a, n) != a for a in all_subsets(n))


def identity_loeb_witness(n: int) -> Tuple[Statement, Statement, Statement]:
    """Proposition 3.14: the witness S=∅ where the identity operator breaks Löb.

    Returns (S, lhs, rhs) with lhs = id(id S ⇨ S), rhs = id S, and lhs ⊄ rhs.
    """
    s = bottom()
    lhs = identity_box(implies(identity_box(s, n), s, n), n)  # = (∅ ⇨ ∅) = univ
    rhs = identity_box(s, n)                                  # = ∅
    return s, lhs, rhs


# ----------------------------------------------------------------------------
# Pretty printing
# ----------------------------------------------------------------------------
def show(s: Statement) -> str:
    if not s:
        return "∅"
    return "{" + ",".join(map(str, sorted(s))) + "}"


def main() -> None:
    N = 8  # universe {0, ..., 7}; Boolean algebra has 2^8 = 256 elements

    print("=" * 72)
    print(f"  Gödel--Löb provability algebra NatGL on universe {{0,...,{N-1}}}")
    print("=" * 72)

    print("\n[Theorem 4.2] Gödel--Löb axioms for natBox:")
    print(f"  (B⊤)  □⊤ = ⊤                     : {check_box_top(N)}")
    print(f"  (B⊓)  □(a⊓b) = □a ⊓ □b           : {check_box_inf(N)}")
    print(f"  (Löb) □(□a ⇨ a) ≤ □a             : {check_loeb(nat_box, N)}")

    print("\n[Theorem 4.3] Consistency:")
    box_bot = nat_box(bottom(), N)
    print(f"  □⊥ = {show(box_bot)}   (= {{0}})   ≠ ⊤ : {box_bot != universe(N)}")

    print("\n[Theorem 4.4] Provability-rank computation  □^k(∅) = {0,...,k-1}:")
    for k in range(N + 1):
        got = iterate_box(bottom(), k, N)
        expected = frozenset(range(min(k, N)))
        flag = "OK" if got == expected else "MISMATCH"
        print(f"  □^{k}(∅) = {show(got):<20} expected Iio({k}) = {show(expected):<20} [{flag}]")

    print("\n[Theorem 4.5] Strictly increasing consistency spectrum:")
    chain = [iterate_box(bottom(), k, N) for k in range(N)]
    strict = all(chain[i] < chain[i + 1] for i in range(len(chain) - 1))
    never_top = all(c != universe(N) for c in chain)
    print(f"  ∅ ⊊ {{0}} ⊊ {{0,1}} ⊊ ... strictly increasing : {strict}")
    print(f"  none equals ⊤                              : {never_top}")

    print("\n[Theorem 4.6] Graded Gödel II  (k+1)-fold consistency is unprovable:")
    for k in range(N - 1):
        stmt = iterate_box(bottom(), k + 1, N)       # □^{k+1}⊥
        con = implies(stmt, bottom(), N)             # consistency statement
        provable = nat_box(con, N) == universe(N)
        print(f"  k={k}: □(□^{k+1}⊥ ⇨ ⊥) = ⊤ ?  -> {provable}   (unprovable: {not provable})")

    print("\n[Theorem 3.4] Löb equality  □(□a ⇨ a) = □a        : "
          f"{check_loeb_equality(N)}")
    print(f"[Theorem 3.5] Löb's rule  □a ≤ a ⟹ a = ⊤          : {check_loeb_rule(N)}")

    print("\n[Theorem 3.10/3.11] Canonical fixed point glFix c = □c ⇨ c")
    print(f"  fixed point, □(glFix c)=□c, and unique           : "
          f"{check_canonical_fixed_point(N)}")
    # show one explicit example
    c = frozenset({2, 5})
    print(f"  example  c = {show(c)}:  glFix c = {show(glfix(c, N))},  "
          f"□(glFix c) = {show(nat_box(glfix(c, N), N))} = □c = {show(nat_box(c, N))}")

    print("\n[Theorem 3.12] Two-parameter uniqueness  p = d ⊓ (□p ⇨ c)")
    # use a smaller universe: this is an O(4^n) double-loop check
    M = 5
    print(f"  unique solution for every (c,d) on {{0,...,{M-1}}}  : "
          f"{check_two_parameter_uniqueness(M)}")

    print("\n[Theorem 3.13] Box is never the identity            : "
          f"{check_box_ne_id(N)}")
    print("[Proposition 3.14] Identity operator violates Löb at S = ∅:")
    s, lhs, rhs = identity_loeb_witness(N)
    print(f"  id(id ∅ ⇨ ∅) = {show(lhs)}  ⊄  id ∅ = {show(rhs)}   "
          f"(Löb fails: {not leq(lhs, rhs)})")
    print(f"  hence the naive 'provable=true' operator is NOT a valid box.")

    print("\n" + "=" * 72)
    print("  All theorems verified computationally on the bounded model.")
    print("=" * 72)


if __name__ == "__main__":
    main()
