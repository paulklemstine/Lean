#!/usr/bin/env python3
"""Finite Boolean demonstrations of strange loops and abstract incompleteness.

The two Boolean truth values form the implication order False <= True.  A
unary table P models a provability operator.  This script exhaustively
classifies all four such operators and checks the finite instances of the
fixed-point, reflection, consistency, completeness, and antichain results.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Iterable, Sequence

BoolOperator = Callable[[bool], bool]


@dataclass(frozen=True)
class OperatorReport:
    """Complete property report for one unary Boolean operator."""

    name: str
    table: tuple[bool, bool]
    monotone: bool
    fixed_points: tuple[bool, ...]
    syntactically_complete: bool
    consistent: bool
    reflective: bool
    semantically_complete: bool


def implies(a: bool, b: bool) -> bool:
    """Return the classical implication a -> b."""
    return (not a) or b


def operator_from_table(table: tuple[bool, bool]) -> BoolOperator:
    """Create P with table entries (P(False), P(True))."""
    return lambda value: table[int(value)]


def is_monotone(operator: BoolOperator) -> bool:
    """Check whether implication a -> b entails P(a) -> P(b)."""
    return all(
        not implies(a, b) or implies(operator(a), operator(b))
        for a, b in product((False, True), repeat=2)
    )


def fixed_points(operator: BoolOperator) -> tuple[bool, ...]:
    """Find all g satisfying g = not P(g)."""
    return tuple(g for g in (False, True) if g == (not operator(g)))


def is_syntactically_complete(operator: BoolOperator) -> bool:
    """Check P(a) or P(not a) for each Boolean proposition a."""
    return all(operator(a) or operator(not a) for a in (False, True))


def is_consistent(operator: BoolOperator) -> bool:
    """Check that falsehood is not certified: not P(False)."""
    return not operator(False)


def is_reflective(operator: BoolOperator) -> bool:
    """Check semantic reflection P(a) -> a."""
    return all(implies(operator(a), a) for a in (False, True))


def is_semantically_complete(operator: BoolOperator) -> bool:
    """Check semantic completeness a -> P(a)."""
    return all(implies(a, operator(a)) for a in (False, True))


def classify_operator(name: str, table: tuple[bool, bool]) -> OperatorReport:
    """Compute every property used in the demonstrations."""
    operator = operator_from_table(table)
    return OperatorReport(
        name=name,
        table=table,
        monotone=is_monotone(operator),
        fixed_points=fixed_points(operator),
        syntactically_complete=is_syntactically_complete(operator),
        consistent=is_consistent(operator),
        reflective=is_reflective(operator),
        semantically_complete=is_semantically_complete(operator),
    )


def enumerate_boolean_operators() -> tuple[OperatorReport, ...]:
    """Classify the four unary operators on the Boolean universe."""
    names = {
        (False, False): "constantly false",
        (False, True): "identity",
        (True, False): "negation",
        (True, True): "constantly true",
    }
    return tuple(classify_operator(names[table], table) for table in names)


def antichain_property(operator: BoolOperator) -> bool:
    """Check that comparable fixed points are equal in the Boolean order."""
    points = fixed_points(operator)
    return all(not implies(g, h) or implies(h, g) for g in points for h in points)


def reflected_fixed_point_witness(operator: BoolOperator) -> bool | None:
    """Return a true, uncertified fixed point when reflection supplies one."""
    if not is_reflective(operator):
        return None
    for g in fixed_points(operator):
        if g and not operator(g):
            return g
    return None


def verify_key_results(reports: Sequence[OperatorReport]) -> None:
    """Assert the finite instances and the two explicit countermodels."""
    by_name = {report.name: report for report in reports}

    identity = by_name["identity"]
    assert identity.monotone and not identity.fixed_points

    indiscriminate = by_name["constantly true"]
    assert indiscriminate.monotone
    assert indiscriminate.fixed_points == (False,)
    assert indiscriminate.syntactically_complete
    assert not indiscriminate.consistent
    assert not indiscriminate.reflective

    for report in reports:
        operator = operator_from_table(report.table)
        if report.monotone:
            assert antichain_property(operator)
        if report.reflective:
            assert report.consistent
            witness = reflected_fixed_point_witness(operator)
            if report.fixed_points:
                assert witness is True
                assert not report.semantically_complete


def yes_no(value: bool) -> str:
    """Format a Boolean property compactly."""
    return "yes" if value else "no"


def render_table(reports: Iterable[OperatorReport]) -> str:
    """Render a dependency-free text table."""
    header = (
        "operator         P(0),P(1)  mono  fixed points  syntactic complete  "
        "consistent  reflective  semantic complete"
    )
    rows = [header, "-" * len(header)]
    for report in reports:
        table = "".join("1" if value else "0" for value in report.table)
        points = "{" + ",".join("1" if value else "0" for value in report.fixed_points) + "}"
        rows.append(
            f"{report.name:<16} {table:^9}  {yes_no(report.monotone):<4}  "
            f"{points:<12}  {yes_no(report.syntactically_complete):<18}  "
            f"{yes_no(report.consistent):<10}  {yes_no(report.reflective):<10}  "
            f"{yes_no(report.semantically_complete)}"
        )
    return "\n".join(rows)


def main() -> None:
    """Run the exhaustive census and print its mathematical interpretation."""
    reports = enumerate_boolean_operators()
    verify_key_results(reports)
    print("BOOLEAN PROVABILITY-OPERATOR CENSUS")
    print(render_table(reports))
    print("\nKey observations:")
    print("1. Identity is monotone but has no solution of g = not P(g).")
    print("2. Constant truth has fixed point g=0 and is syntactically complete,")
    print("   but it is inconsistent and fails reflection.")
    print("3. Every reflective operator is consistent.")
    print("4. Every reflected fixed point in this census is true and uncertified,")
    print("   and therefore witnesses failure of semantic completeness.")
    print("5. Fixed points of every monotone operator pass the antichain audit.")


if __name__ == "__main__":
    main()
