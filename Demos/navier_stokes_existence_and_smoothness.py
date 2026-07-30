#!/usr/bin/env python3
"""Numerical illustrations of epsilon-regularity screening and modal transfer.

The script uses only the Python standard library. Its finite scale tests are
one-sided: finding a sub-threshold excess certifies the premise of an abstract
regularity criterion, while not finding one does not prove singularity.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Dict, Iterable, List, Mapping, Sequence, Tuple

Vector = Sequence[float]


@dataclass(frozen=True)
class ExcessReport:
    """Result of screening a sampled excess profile against a threshold."""

    point: str
    epsilon: float
    witness_scale: float | None
    minimum_sampled_excess: float

    @property
    def certified_regular(self) -> bool:
        return self.witness_scale is not None


def screen_excess_profile(
    point: str, profile: Mapping[float, float], epsilon: float
) -> ExcessReport:
    """Find a positive sampled scale with excess strictly below epsilon.

    Raises:
        ValueError: if epsilon is not positive, the profile is empty, or a
            supplied scale is nonpositive.
    """
    if epsilon <= 0.0:
        raise ValueError("epsilon must be positive")
    if not profile:
        raise ValueError("the sampled profile must be nonempty")
    if any(radius <= 0.0 for radius in profile):
        raise ValueError("all sampled radii must be positive")

    witnesses = [r for r, value in profile.items() if value < epsilon]
    witness = max(witnesses) if witnesses else None
    return ExcessReport(point, epsilon, witness, min(profile.values()))


def dot(left: Vector, right: Vector) -> float:
    """Return the Euclidean inner product of equally sized vectors."""
    if len(left) != len(right):
        raise ValueError("vectors must have equal dimensions")
    return sum(x * y for x, y in zip(left, right))


def modal_transfers(states: Sequence[Vector], interactions: Sequence[Vector]) -> List[float]:
    """Compute tau_i = <N_i, u_i> for every mode."""
    if len(states) != len(interactions):
        raise ValueError("states and interactions must have equal mode counts")
    return [dot(interaction, state) for state, interaction in zip(states, interactions)]


def transfer_into(transfers: Sequence[float], band: Iterable[int]) -> float:
    """Sum modal transfers over a validated collection of mode indices."""
    indices = set(band)
    if any(index < 0 or index >= len(transfers) for index in indices):
        raise IndexError("band contains an index outside the truncation")
    return sum(transfers[index] for index in indices)


def audit_complementary_transfer(
    states: Sequence[Vector],
    interactions: Sequence[Vector],
    band: Iterable[int],
    tolerance: float = 1e-12,
) -> Dict[str, float | bool]:
    """Audit total conservation and equal-opposite band transfer."""
    transfers = modal_transfers(states, interactions)
    selected = set(band)
    complement = set(range(len(transfers))) - selected
    band_transfer = transfer_into(transfers, selected)
    complement_transfer = transfer_into(transfers, complement)
    total = sum(transfers)
    return {
        "total_transfer": total,
        "band_transfer": band_transfer,
        "complement_transfer": complement_transfer,
        "balance_residual": complement_transfer + band_transfer,
        "conservative": isclose(total, 0.0, abs_tol=tolerance),
        "equal_and_opposite": isclose(
            complement_transfer, -band_transfer, abs_tol=tolerance
        ),
    }


def conservative_completion(partial_transfers: Sequence[float]) -> List[float]:
    """Append the unique balancing transfer that makes the total zero."""
    return [*partial_transfers, -sum(partial_transfers)]


def ascii_transfer_bars(transfers: Sequence[float], width: int = 24) -> str:
    """Create a dependency-free signed bar chart of modal transfers."""
    maximum = max((abs(value) for value in transfers), default=1.0) or 1.0
    rows: List[str] = []
    for index, value in enumerate(transfers):
        length = round(width * abs(value) / maximum)
        bar = ("+" if value >= 0 else "-") * length
        rows.append(f"mode {index:2d}: {value:8.3f} {bar}")
    return "\n".join(rows)


def run_demo() -> None:
    """Print three reproducible examples and assert their key identities."""
    epsilon = 0.1
    profiles = {
        "point a": {1.0: 0.42, 0.5: 0.18, 0.25: 0.08, 0.125: 0.04},
        "point b": {1.0: 0.31, 0.5: 0.21, 0.25: 0.14, 0.125: 0.11},
    }
    print("EPSILON-REGULARITY SCREEN (sampled scales)")
    for point, profile in profiles.items():
        report = screen_excess_profile(point, profile, epsilon)
        if report.certified_regular:
            print(
                f"  {point}: certified by r={report.witness_scale:g}; "
                f"minimum sampled excess={report.minimum_sampled_excess:g}"
            )
        else:
            print(
                f"  {point}: unresolved concentration candidate; this is "
                "not a singularity verdict"
            )

    states = [(1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (2.0, -1.0)]
    interactions = [(2.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (-1.0, 0.0)]
    transfers = modal_transfers(states, interactions)
    audit = audit_complementary_transfer(states, interactions, {0, 1})
    print("\nCONSERVATIVE FOUR-MODE EXCHANGE")
    print(ascii_transfer_bars(transfers))
    for key, value in audit.items():
        print(f"  {key}: {value}")
    assert audit["conservative"] is True
    assert audit["equal_and_opposite"] is True
    assert audit["band_transfer"] == 3.0
    assert audit["complement_transfer"] == -3.0

    completed = conservative_completion([1.5, -0.25, 2.0, -4.0])
    print("\nCONSERVATIVE COMPLETION")
    print(f"  transfers={completed}")
    print(f"  total={sum(completed):g}")
    assert isclose(sum(completed), 0.0, abs_tol=1e-12)


if __name__ == "__main__":
    run_demo()
