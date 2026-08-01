#!/usr/bin/env python3
"""Numerical demonstrations of finite-test tropical Gröbner completion.

The demo models each tested nonzero polynomial by its name and chosen leading
exponent. Ideal membership is explicit Boolean data. This is exactly the
finite information used by the completion theorem: a basis leader covers a
tested leader when it divides it componentwise.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence

Exponent = tuple[int, ...]


@dataclass(frozen=True)
class TestedPolynomial:
    """A finite-test polynomial record with a selected leading exponent."""

    name: str
    leading_exponent: Exponent | None
    in_ideal: bool = True

    @property
    def is_zero(self) -> bool:
        """The zero polynomial has no leading exponent."""
        return self.leading_exponent is None


def monomial_divides(a: Exponent, b: Exponent) -> bool:
    """Return whether x^a divides x^b, i.e. a <= b componentwise."""
    if len(a) != len(b):
        raise ValueError("Exponent vectors must have the same dimension")
    return all(left <= right for left, right in zip(a, b))


def is_leading_reducible(
    polynomial: TestedPolynomial,
    basis: Sequence[TestedPolynomial],
) -> bool:
    """Test whether a basis leading exponent divides the polynomial leader."""
    if polynomial.is_zero:
        return False
    assert polynomial.leading_exponent is not None
    return any(
        not generator.is_zero
        and generator.leading_exponent is not None
        and monomial_divides(generator.leading_exponent, polynomial.leading_exponent)
        for generator in basis
    )


def obstructions(
    universe: Sequence[TestedPolynomial],
    basis: Sequence[TestedPolynomial],
) -> list[TestedPolynomial]:
    """List nonzero tested ideal members not covered by the current basis."""
    return [
        polynomial
        for polynomial in universe
        if polynomial.in_ideal
        and not polynomial.is_zero
        and not is_leading_reducible(polynomial, basis)
    ]


def finite_buchberger_completion(
    universe: Sequence[TestedPolynomial],
    initial_basis: Iterable[TestedPolynomial],
) -> tuple[list[TestedPolynomial], list[list[str]]]:
    """Complete a valid basis by repeatedly adjoining the first obstruction.

    Returns the completed basis and a history of basis-name snapshots. The
    deterministic input order supplies the obstruction-selection rule.
    """
    universe_list = list(universe)
    basis = list(dict.fromkeys(initial_basis))
    universe_set = set(universe_list)
    if any(generator not in universe_set for generator in basis):
        raise ValueError("Every initial basis member must lie in the universe")
    if any(not generator.in_ideal for generator in basis):
        raise ValueError("Every initial basis member must lie in the ideal")

    history = [[generator.name for generator in basis]]
    while True:
        unresolved = obstructions(universe_list, basis)
        if not unresolved:
            return basis, history
        chosen = unresolved[0]
        # Self-reducibility guarantees that an obstruction is not already in G.
        assert chosen not in basis
        basis.append(chosen)
        history.append([generator.name for generator in basis])
        # The finite theorem gives the uniform bound |U|.
        assert len(history) - 1 <= len(universe_list)


def coverage_certificate(
    universe: Sequence[TestedPolynomial],
    basis: Sequence[TestedPolynomial],
) -> dict[str, str]:
    """Map each relevant tested polynomial to a basis divisor certificate."""
    certificate: dict[str, str] = {}
    for polynomial in universe:
        if polynomial.is_zero or not polynomial.in_ideal:
            continue
        assert polynomial.leading_exponent is not None
        for generator in basis:
            if generator.leading_exponent is not None and monomial_divides(
                generator.leading_exponent, polynomial.leading_exponent
            ):
                certificate[polynomial.name] = generator.name
                break
        else:
            raise ValueError(f"No basis leader covers {polynomial.name}")
    return certificate


def run_example() -> None:
    """Run and validate a two-variable finite completion example."""
    universe = [
        TestedPolynomial("p20", (2, 0)),
        TestedPolynomial("p11", (1, 1)),
        TestedPolynomial("p03", (0, 3)),
        TestedPolynomial("p31", (3, 1)),
        TestedPolynomial("p22", (2, 2)),
        TestedPolynomial("zero", None),
        TestedPolynomial("external", (0, 0), in_ideal=False),
    ]
    completed, history = finite_buchberger_completion(universe, [universe[0]])
    certificate = coverage_certificate(universe, completed)

    print("Finite tropical Buchberger completion")
    print("=======================================")
    for step, names in enumerate(history):
        unresolved = obstructions(universe, [p for p in universe if p.name in names])
        print(f"Step {step}: G = {names}")
        print(f"        unresolved = {[p.name for p in unresolved]}")
    print(f"Completed after {len(history) - 1} additions; |U| = {len(universe)}.")
    print("Coverage certificate (tested polynomial <- basis divisor):")
    for polynomial, generator in certificate.items():
        print(f"  {polynomial} <- {generator}")

    assert len(history) - 1 <= len(universe)
    assert not obstructions(universe, completed)
    assert finite_buchberger_completion(universe, completed)[0] == completed
    assert certificate == {
        "p20": "p20",
        "p11": "p11",
        "p03": "p03",
        "p31": "p20",
        "p22": "p20",
    }
    print("All theorem-inspired checks passed.")


if __name__ == "__main__":
    run_example()
