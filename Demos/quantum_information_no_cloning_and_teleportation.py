#!/usr/bin/env python3
"""Numerical demonstrations of teleportation and W-state monogamy.

The script uses only Python's standard library.  It constructs the teleportation
circuit amplitude by amplitude, checks all four corrected measurement branches,
and evaluates concurrence tangles for representative normalized W states.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, sqrt
from typing import Callable, Dict, Iterable, Tuple

Bit = int
Qubit = Tuple[complex, complex]
Triple = Tuple[Bit, Bit, Bit]
AmplitudeTable = Dict[Triple, complex]


def bell_amplitude(b: Bit, c: Bit) -> complex:
    """Return the amplitude of |bc> in (|00> + |11>)/sqrt(2)."""
    return complex(1.0 / sqrt(2.0)) if b == c else 0j


def teleport_initial(psi: Qubit) -> AmplitudeTable:
    """Construct |psi> tensored with Alice and Bob's Bell pair."""
    return {
        (a, b, c): psi[a] * bell_amplitude(b, c)
        for a in (0, 1)
        for b in (0, 1)
        for c in (0, 1)
    }


def apply_cnot12(table: AmplitudeTable) -> AmplitudeTable:
    """Apply CNOT with wire 1 controlling wire 2."""
    return {
        (a, b, c): table[(a, a ^ b, c)]
        for a in (0, 1)
        for b in (0, 1)
        for c in (0, 1)
    }


def apply_hadamard1(table: AmplitudeTable) -> AmplitudeTable:
    """Apply Hadamard to the first wire of a three-qubit amplitude table."""
    s = 1.0 / sqrt(2.0)
    out: AmplitudeTable = {}
    for b in (0, 1):
        for c in (0, 1):
            out[(0, b, c)] = s * (table[(0, b, c)] + table[(1, b, c)])
            out[(1, b, c)] = s * (table[(0, b, c)] - table[(1, b, c)])
    return out


def pauli_x(v: Qubit) -> Qubit:
    """Apply the Pauli-X amplitude swap."""
    return (v[1], v[0])


def pauli_z(v: Qubit) -> Qubit:
    """Apply the Pauli-Z phase flip."""
    return (v[0], -v[1])


def teleport_branch(psi: Qubit, a: Bit, b: Bit) -> Qubit:
    """Return Bob's unnormalized state after Alice observes bits (a,b)."""
    final_table = apply_hadamard1(apply_cnot12(teleport_initial(psi)))
    return (final_table[(a, b, 0)], final_table[(a, b, 1)])


def correct_branch(branch: Qubit, a: Bit, b: Bit) -> Qubit:
    """Apply X according to b, followed by Z according to a."""
    corrected = pauli_x(branch) if b else branch
    return pauli_z(corrected) if a else corrected


def squared_norm(v: Qubit) -> float:
    """Compute the squared Euclidean norm of a qubit amplitude pair."""
    return abs(v[0]) ** 2 + abs(v[1]) ** 2


def close_complex(x: complex, y: complex, tolerance: float = 1e-12) -> bool:
    """Compare complex values with an absolute numerical tolerance."""
    return abs(x - y) <= tolerance


def demonstrate_teleportation(psi: Qubit) -> None:
    """Print and verify all four teleportation branches for an input qubit."""
    expected = (psi[0] / 2.0, psi[1] / 2.0)
    print("Teleportation branch check")
    print(f"  input amplitudes: {psi}")
    for a in (0, 1):
        for b in (0, 1):
            branch = teleport_branch(psi, a, b)
            corrected = correct_branch(branch, a, b)
            probability = squared_norm(branch)
            valid = all(close_complex(x, y) for x, y in zip(corrected, expected))
            print(
                f"  outcome ({a},{b}): raw={branch}, corrected={corrected}, "
                f"probability={probability:.12f}, identity={valid}"
            )
            assert valid


@dataclass(frozen=True)
class WTangles:
    """Entanglement measures for a W-sector amplitude triple."""

    one_tangle_a_bc: float
    concurrence_sq_ab: float
    concurrence_sq_ac: float

    @property
    def residual(self) -> float:
        """Return the difference in the monogamy equality."""
        return self.one_tangle_a_bc - self.concurrence_sq_ab - self.concurrence_sq_ac


def w_tangles(a: complex, b: complex, c: complex) -> WTangles:
    """Calculate the A|BC one-tangle and both pairwise squared concurrences."""
    qa, qb, qc = abs(a) ** 2, abs(b) ** 2, abs(c) ** 2
    return WTangles(
        one_tangle_a_bc=4.0 * qa * (qb + qc),
        concurrence_sq_ab=4.0 * qa * qb,
        concurrence_sq_ac=4.0 * qa * qc,
    )


def normalize_w(a: complex, b: complex, c: complex) -> Tuple[complex, complex, complex]:
    """Normalize a nonzero W-sector amplitude triple."""
    norm = sqrt(abs(a) ** 2 + abs(b) ** 2 + abs(c) ** 2)
    if norm == 0.0:
        raise ValueError("At least one W-state amplitude must be nonzero")
    return (a / norm, b / norm, c / norm)


def demonstrate_w_monogamy(states: Iterable[Tuple[str, Tuple[complex, complex, complex]]]) -> None:
    """Print and verify monogamy saturation and the unit one-tangle bound."""
    print("\nW-state monogamy check")
    for name, raw in states:
        a, b, c = normalize_w(*raw)
        values = w_tangles(a, b, c)
        normalized_weight = abs(a) ** 2 + abs(b) ** 2 + abs(c) ** 2
        saturated = isclose(
            values.concurrence_sq_ab + values.concurrence_sq_ac,
            values.one_tangle_a_bc,
            abs_tol=1e-12,
        )
        bounded = values.one_tangle_a_bc <= 1.0 + 1e-12
        print(f"  {name}: normalization={normalized_weight:.12f}")
        print(
            f"    C_AB^2={values.concurrence_sq_ab:.12f}, "
            f"C_AC^2={values.concurrence_sq_ac:.12f}, "
            f"tau_A|BC={values.one_tangle_a_bc:.12f}, "
            f"residual={values.residual:.3e}"
        )
        assert saturated and bounded


def main() -> None:
    """Run representative numerical checks."""
    psi = normalize_w(1.0 + 1.0j, -0.5 + 0.25j, 0j)[:2]
    demonstrate_teleportation(psi)

    demonstrate_w_monogamy(
        [
            ("symmetric W state", (1.0, 1.0, 1.0)),
            ("unit-bound saturating state", (1.0, 1.0, 0.0)),
            ("complex-phase state", (1.0j, 2.0, -1.0 + 1.0j)),
        ]
    )


if __name__ == "__main__":
    main()
