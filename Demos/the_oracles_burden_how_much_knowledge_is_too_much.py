"""
The Oracle's Burden: numerical demonstrations of relativized computability
and the strictness of the Turing-jump hierarchy.

This standalone script illustrates, with concrete finite computations, the
central phenomena of the paper:

  1. Diagonalization producing a function no program in a given enumeration
     computes  (the seed of non-triviality: some function is not computable).
  2. Countable programs vs. uncountable functions  (the cardinality gap that
     forces a non-computable function to exist).
  3. The strictly increasing, never-repeating jump tower
        A  <_T  J(A)  <_T  J^2(A)  <_T  ...
     modelled on the arithmetical/jump hierarchy, with an order embedding of
     (N, <) into a chain of degrees.
  4. The join {f, g} as the least upper bound of two oracles.
  5. The contrarian facts: a *computable* oracle adds nothing, and the jump is
     never idempotent.

Everything is self-contained: no imports beyond the standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# 1. Diagonalization: build a function that differs from every listed program.
# ---------------------------------------------------------------------------
def diagonal_out_of_enumeration(
    programs: Sequence[Callable[[int], int]]
) -> Callable[[int], int]:
    """Return a total function d with d(n) != programs[n](n) for every n.

    This is Cantor/Turing diagonalization: whatever countable list of
    "computable" functions you supply, d escapes all of them on the diagonal.
    It is the finite skeleton of the proof that a non-computable function
    exists.
    """

    def d(n: int) -> int:
        if n < len(programs):
            return programs[n](n) + 1
        return 0

    return d


def demo_diagonalization() -> None:
    print("=" * 70)
    print("1. Diagonalization escapes every enumerated program")
    print("=" * 70)
    programs: List[Callable[[int], int]] = [
        lambda n: 0,
        lambda n: n,
        lambda n: n * n,
        lambda n: 2 * n + 1,
        lambda n: n % 3,
    ]
    d = diagonal_out_of_enumeration(programs)
    for i, p in enumerate(programs):
        assert d(i) != p(i)
        print(f"   d({i}) = {d(i):>3}   program_{i}({i}) = {p(i):>3}   differ = True")
    print("   => d is not any of these programs. Add d to the list and repeat")
    print("      forever: no countable list captures all functions.\n")


# ---------------------------------------------------------------------------
# 2. Cardinality gap: count programs of bounded size vs. functions on a domain.
# ---------------------------------------------------------------------------
def count_programs_up_to_length(alphabet_size: int, max_len: int) -> int:
    """Number of program strings of length <= max_len over a finite alphabet.

    Programs are finite strings, hence (letting max_len -> infinity) countable.
    """
    return sum(alphabet_size**k for k in range(max_len + 1))


def count_functions_on_finite_domain(domain: int, codomain: int) -> int:
    """Number of functions {0,...,domain-1} -> {0,...,codomain-1} = codomain**domain.

    As the domain grows this outstrips any fixed program budget: the full
    space of functions N -> N is uncountable (cardinality 2^aleph0), while the
    programs stay countable.
    """
    return codomain**domain


def demo_cardinality_gap() -> None:
    print("=" * 70)
    print("2. Countable programs cannot exhaust the functions")
    print("=" * 70)
    print(f"   {'domain':>6} | {'#Boolean functions':>20} | {'#programs(len<=12)':>20}")
    programs_budget = count_programs_up_to_length(alphabet_size=2, max_len=12)
    for domain in range(2, 16, 2):
        n_functions = count_functions_on_finite_domain(domain, codomain=2)
        print(f"   {domain:>6} | {n_functions:>20} | {programs_budget:>20}")
    print("   => the Boolean-function count 2^domain overtakes any fixed")
    print("      program budget; in the limit functions are uncountable while")
    print("      programs remain countable, so some function is uncomputable.\n")


# ---------------------------------------------------------------------------
# 3. The jump tower: a strictly increasing chain of degrees.
# ---------------------------------------------------------------------------
# We model an "oracle" by its computational strength as a natural number level;
# a "degree" is that level, ordered by <=. The jump J adds exactly one level,
# faithfully reproducing A <_T J(A) and the never-repeating tower.
Degree = int


def turing_jump(level: Degree) -> Degree:
    """Abstract jump: strictly increases the degree by one level.

    Satisfies the two jump axioms in this model:
      preservation : level <= J(level)   (in fact level < J(level))
      strict ascent: not (J(level) <= level)
    """
    return level + 1


def jump_tower(base: Degree, height: int) -> List[Degree]:
    """The iterated tower base, J(base), J^2(base), ..., J^height(base)."""
    tower = [base]
    for _ in range(height):
        tower.append(turing_jump(tower[-1]))
    return tower


def is_strictly_increasing(seq: Sequence[Degree]) -> bool:
    return all(a < b for a, b in zip(seq, seq[1:]))


def demo_jump_tower() -> None:
    print("=" * 70)
    print("3. The jump tower is strictly increasing and never repeats")
    print("=" * 70)
    tower = jump_tower(base=0, height=6)
    labels = ["0", "0'", "0''", "0'''", "0''''", "0'''''", "0''''''"]
    chain = "  <_T  ".join(labels[: len(tower)])
    print(f"   degrees : {tower}")
    print(f"   tower   : {chain}")
    print(f"   strictly increasing : {is_strictly_increasing(tower)}")
    print(f"   all levels distinct : {len(set(tower)) == len(tower)}")
    # Order embedding: n < m  <=>  deg(J^n) < deg(J^m)
    embedding: Dict[int, Degree] = {n: tower[n] for n in range(len(tower))}
    faithful = all(
        (n < m) == (embedding[n] < embedding[m])
        for n in embedding
        for m in embedding
    )
    print(f"   n |-> deg(J^n) is an order embedding of (N,<) : {faithful}\n")


# ---------------------------------------------------------------------------
# 4. Joins: the least upper bound of two oracles.
# ---------------------------------------------------------------------------
def join(f: Degree, g: Degree) -> Degree:
    """Least upper bound of two degrees (their join)."""
    return max(f, g)


def is_upper_bound(h: Degree, f: Degree, g: Degree) -> bool:
    return f <= h and g <= h


def demo_join_lub() -> None:
    print("=" * 70)
    print("4. The join {f, g} is the least upper bound")
    print("=" * 70)
    f, g = 3, 5
    j = join(f, g)
    print(f"   f = {f},  g = {g},  join(f,g) = {j}")
    print(f"   join is an upper bound        : {is_upper_bound(j, f, g)}")
    # Least: any common upper bound h dominates the join.
    least = all(j <= h for h in range(max(f, g), max(f, g) + 6) if is_upper_bound(h, f, g))
    print(f"   join <= every common upper bound h : {least}\n")


# ---------------------------------------------------------------------------
# 5a. Contrarian: a computable oracle adds nothing.
# ---------------------------------------------------------------------------
def relativize_with_computable_oracle(base_class: Set[int], oracle: int) -> Set[int]:
    """Model Rec({g}) when g is already computable (g in base_class).

    Adjoining an oracle already in the class leaves the class unchanged --
    the computability-theoretic fact  Rec({g}) = Partrec  for computable g.
    """
    if oracle in base_class:
        return set(base_class)  # nothing new is gained
    return base_class | {oracle}  # a genuinely new (non-computable) oracle adds power


def demo_computable_oracle_useless() -> None:
    print("=" * 70)
    print("5a. A computable oracle adds nothing; a non-computable one does")
    print("=" * 70)
    partrec: Set[int] = {0, 1, 2, 3}  # a stand-in for the computable functions
    unchanged = relativize_with_computable_oracle(partrec, oracle=2)
    grown = relativize_with_computable_oracle(partrec, oracle=99)  # 99 = a halting oracle
    print(f"   Partrec              : {sorted(partrec)}")
    print(f"   Rec({{computable g=2}}) : {sorted(unchanged)}   (unchanged = {unchanged == partrec})")
    print(f"   Rec({{halting  H=99}}) : {sorted(grown)}   (strictly larger = {grown > partrec})\n")


# ---------------------------------------------------------------------------
# 5b. Contrarian: the jump is never idempotent.
# ---------------------------------------------------------------------------
def demo_jump_not_idempotent() -> None:
    print("=" * 70)
    print("5b. The jump is never idempotent: J(J(A)) is strictly above J(A)")
    print("=" * 70)
    for a in range(4):
        ja = turing_jump(a)
        jja = turing_jump(ja)
        print(f"   A={a}:  J(A)={ja},  J(J(A))={jja},  J(A) <_T J(J(A)) = {ja < jja}")
    print()


def main() -> None:
    demo_diagonalization()
    demo_cardinality_gap()
    demo_jump_tower()
    demo_join_lub()
    demo_computable_oracle_useless()
    demo_jump_not_idempotent()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
