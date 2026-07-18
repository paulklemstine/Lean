#!/usr/bin/env python3
"""Numerical experiments for logic-encoded jigsaw solution spaces.

The program represents a literal as ``(variable_index, polarity)``.  Polarity
``True`` means a positive literal and ``False`` a negated literal.  A formula is
a list of clauses, and a clause is a list of literals.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Literal = Tuple[int, bool]
Clause = Sequence[Literal]
Formula = Sequence[Clause]
Assignment = Tuple[bool, ...]


def literal_satisfied(assignment: Assignment, literal: Literal) -> bool:
    """Return whether the assignment makes the literal true."""
    variable, polarity = literal
    value = assignment[variable] if variable < len(assignment) else False
    return value == polarity


def clause_satisfied(assignment: Assignment, clause: Clause) -> bool:
    """Return whether at least one literal in a clause is true."""
    return any(literal_satisfied(assignment, literal) for literal in clause)


def formula_satisfied(assignment: Assignment, formula: Formula) -> bool:
    """Return whether every clause in a formula is satisfied."""
    return all(clause_satisfied(assignment, clause) for clause in formula)


def clause_piece_fits(assignment: Assignment, clause: Clause) -> bool:
    """Evaluate the abstract clause-piece interface condition.

    The construction specifies that a clause piece fits exactly when one of its
    literal inputs is active, so this function intentionally has the same truth
    condition as ``clause_satisfied``.
    """
    return any(literal_satisfied(assignment, literal) for literal in clause)


def puzzle_assembled(assignment: Assignment, formula: Formula) -> bool:
    """Return whether all abstract clause pieces fit the chosen assignment."""
    return all(clause_piece_fits(assignment, clause) for clause in formula)


def all_assignments(variable_count: int) -> Iterable[Assignment]:
    """Generate all Boolean assignments in lexicographic order."""
    return product((False, True), repeat=variable_count)


def satisfying_assignments(variable_count: int, formula: Formula) -> List[Assignment]:
    """Enumerate all satisfying assignments."""
    return [
        assignment
        for assignment in all_assignments(variable_count)
        if formula_satisfied(assignment, formula)
    ]


def assembly_recipes(variable_count: int, formula: Formula) -> List[Assignment]:
    """Enumerate all valid abstract assembly recipes."""
    return [
        assignment
        for assignment in all_assignments(variable_count)
        if puzzle_assembled(assignment, formula)
    ]


def complement_assignment(assignment: Assignment) -> Assignment:
    """Negate every Boolean value."""
    return tuple(not value for value in assignment)


def complement_formula(formula: Formula) -> List[List[Literal]]:
    """Reverse every literal polarity."""
    return [
        [(variable, not polarity) for variable, polarity in clause]
        for clause in formula
    ]


def piece_count(variable_count: int, formula: Formula) -> int:
    """Count two variable pieces, one piece per clause, and two corners."""
    return 2 * variable_count + len(formula) + 2


def bits(assignment: Assignment) -> str:
    """Format an assignment as a compact bit string."""
    return "".join("1" if value else "0" for value in assignment)


def truth_table(variable_count: int, formula: Formula) -> List[Dict[str, object]]:
    """Build rows comparing formula satisfaction and abstract assembly."""
    return [
        {
            "assignment": bits(assignment),
            "satisfies": formula_satisfied(assignment, formula),
            "assembles": puzzle_assembled(assignment, formula),
        }
        for assignment in all_assignments(variable_count)
    ]


def run_demo() -> None:
    """Run the example and assert the counting and complement theorems."""
    formula: Formula = (
        ((0, True), (1, True), (2, False)),
        ((0, False), (2, True)),
    )
    variable_count = 3
    solutions = satisfying_assignments(variable_count, formula)
    recipes = assembly_recipes(variable_count, formula)
    complemented = complement_formula(formula)
    complement_solutions = satisfying_assignments(variable_count, complemented)

    print("Logic-Encoded Jigsaw Demonstration")
    print("=" * 40)
    print(f"Variables: {variable_count}")
    print(f"Clauses: {len(formula)}")
    print(f"Pieces: {piece_count(variable_count, formula)}")
    print("\nTruth table (assignment | formula | puzzle):")
    for row in truth_table(variable_count, formula):
        print(
            f"  {row['assignment']} | "
            f"{'SAT' if row['satisfies'] else '---':3} | "
            f"{'FIT' if row['assembles'] else '---':3}"
        )

    print(f"\nSatisfying assignments ({len(solutions)}):", [bits(a) for a in solutions])
    print(f"Assembly recipes ({len(recipes)}):", [bits(a) for a in recipes])
    print(
        "Complemented solutions:",
        [bits(a) for a in complement_solutions],
    )

    # Exact witness preservation: the lists agree assignment by assignment.
    assert solutions == recipes
    # Complementation transports the complete solution set bijectively.
    transported = {complement_assignment(a) for a in solutions}
    assert transported == set(complement_solutions)
    # Complementation is an involution on both assignments and formulas.
    assert all(complement_assignment(complement_assignment(a)) == a for a in solutions)
    assert complement_formula(complemented) == [list(c) for c in formula]
    # The explicit witness from the paper is both satisfying and assembling.
    witness = (False, True, False)
    assert formula_satisfied(witness, formula)
    assert puzzle_assembled(witness, formula)

    print("\nAll exact-count, witness, and complementation checks passed.")


if __name__ == "__main__":
    run_demo()
