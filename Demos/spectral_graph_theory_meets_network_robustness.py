#!/usr/bin/env python3
"""Numerical illustrations of spectral connectivity and robustness bounds.

The program uses only Python's standard library.  Numerical sampling illustrates
exact formulas but is not a substitute for a global analytical hypothesis.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, sqrt
from typing import Callable, Iterable, Sequence


@dataclass(frozen=True)
class Certificate:
    """Computed state, end-to-end, and radius bounds."""

    state_lipschitz: float
    output_lipschitz: float
    certified_radius: float


def two_node_energy(connectivity: float, u: float, v: float) -> float:
    """Return (connectivity / 2) times squared node disagreement."""
    return connectivity * (u - v) ** 2 / 2.0


def two_node_variance(u: float, v: float) -> float:
    """Return variance in the unique two-node disagreement mode."""
    return (u - v) ** 2 / 2.0


def spectral_certificate(
    connectivity: float, state_gain: float, readout_gain: float, margin: float
) -> Certificate:
    """Compute G/sqrt(lambda), KG/sqrt(lambda), and m sqrt(lambda)/(KG)."""
    if connectivity <= 0.0:
        raise ValueError("connectivity must be positive")
    if state_gain <= 0.0 or readout_gain <= 0.0 or margin <= 0.0:
        raise ValueError("state gain, readout gain, and margin must be positive")
    state_lipschitz = state_gain / sqrt(connectivity)
    output_lipschitz = readout_gain * state_lipschitz
    return Certificate(
        state_lipschitz=state_lipschitz,
        output_lipschitz=output_lipschitz,
        certified_radius=margin / output_lipschitz,
    )


def check_spectral_state_samples(
    state: Callable[[float], float],
    samples: Sequence[float],
    connectivity: float,
    state_gain: float,
    tolerance: float = 1e-12,
) -> tuple[bool, float]:
    """Test the squared state inequality on all sampled pairs.

    Returns whether all pairs pass and the greatest value of left minus right.
    A nonpositive maximum means every sampled pair passes (up to tolerance).
    """
    if connectivity <= 0.0 or state_gain < 0.0 or tolerance < 0.0:
        raise ValueError("invalid connectivity, gain, or tolerance")
    worst = float("-inf")
    for i, x in enumerate(samples):
        for y in samples[i:]:
            lhs = connectivity * (state(x) - state(y)) ** 2
            rhs = state_gain**2 * (x - y) ** 2
            worst = max(worst, lhs - rhs)
    if worst == float("-inf"):
        worst = 0.0
    return worst <= tolerance, worst


def radius_counterexample(radius: float) -> tuple[Callable[[float], float], float]:
    """Return f(x)=radius/2-x and a point inside radius where f is zero."""
    if radius <= 0.0:
        raise ValueError("radius must be positive")
    return lambda x: radius / 2.0 - x, radius / 2.0


def lipschitz_counterexample(bound: float) -> Callable[[float], float]:
    """Return f(x)=(bound+1)x, which violates proposed nonnegative bound."""
    if bound < 0.0:
        raise ValueError("bound must be nonnegative")
    return lambda x: (bound + 1.0) * x


def grid(start: float, stop: float, count: int) -> list[float]:
    """Return count equally spaced points, including both endpoints."""
    if count < 2:
        raise ValueError("count must be at least two")
    step = (stop - start) / (count - 1)
    return [start + i * step for i in range(count)]


def format_rows(rows: Iterable[tuple[str, float]]) -> str:
    """Format named floating-point values as an aligned table."""
    return "\n".join(f"  {name:<28} {value:>10.6f}" for name, value in rows)


def demonstrate_two_node_identity() -> None:
    """Evaluate the exact energy-variance identity at several states."""
    connectivity = 3.5
    pairs = [(-2.0, 1.0), (0.0, 0.0), (1.25, -0.75)]
    print("1. TWO-NODE SPECTRAL IDENTITY")
    for u, v in pairs:
        energy = two_node_energy(connectivity, u, v)
        spectral_variance = connectivity * two_node_variance(u, v)
        assert isclose(energy, spectral_variance, rel_tol=1e-12, abs_tol=1e-12)
        print(
            f"  (u,v)=({u:5.2f},{v:5.2f}): "
            f"energy={energy:8.4f}, lambda*variance={spectral_variance:8.4f}"
        )


def demonstrate_certificate() -> None:
    """Compute a certificate and sample a sharp affine score around its center."""
    connectivity, state_gain, readout_gain, margin = 4.0, 2.0, 3.0, 1.5
    cert = spectral_certificate(connectivity, state_gain, readout_gain, margin)
    print("\n2. SPECTRAL ROBUSTNESS CERTIFICATE")
    print(
        format_rows(
            [
                ("state Lipschitz bound", cert.state_lipschitz),
                ("output Lipschitz bound", cert.output_lipschitz),
                ("certified open radius", cert.certified_radius),
            ]
        )
    )

    state = lambda x: state_gain / sqrt(connectivity) * x
    score = lambda x: margin - readout_gain * state(x)
    sample_points = grid(-0.99 * cert.certified_radius, 0.99 * cert.certified_radius, 9)
    passed, worst = check_spectral_state_samples(
        state, sample_points, connectivity, state_gain
    )
    assert passed
    assert all(score(x) > 0.0 for x in sample_points)
    boundary = cert.certified_radius
    assert isclose(score(boundary), 0.0, abs_tol=1e-12)
    print(f"  sampled spectral inequality passes: {passed} (worst residual {worst:.2e})")
    print("  every sampled point strictly inside the radius has positive score")
    print(f"  sharp affine score at boundary x={boundary:.6f}: {score(boundary):.6f}")


def demonstrate_square_root_scaling() -> None:
    """Show that quadrupling connectivity doubles the certified radius."""
    print("\n3. SQUARE-ROOT CONNECTIVITY SCALING")
    state_gain, readout_gain, margin = 2.0, 3.0, 1.5
    for connectivity in (1.0, 4.0, 9.0, 16.0):
        radius = spectral_certificate(
            connectivity, state_gain, readout_gain, margin
        ).certified_radius
        print(f"  lambda={connectivity:5.1f}, sqrt(lambda)={sqrt(connectivity):4.1f}, radius={radius:.4f}")


def demonstrate_counterexamples() -> None:
    """Construct uniform witnesses against connectivity-only conclusions."""
    print("\n4. CONNECTIVITY-ONLY COUNTEREXAMPLES")
    proposed_radius = 2.4
    score, witness = radius_counterexample(proposed_radius)
    assert abs(witness) < proposed_radius and score(0.0) > 0.0 and score(witness) == 0.0
    print(
        f"  radius R={proposed_radius:.2f}: f(0)={score(0.0):.2f}, "
        f"but f(R/2)={score(witness):.2f} at distance {abs(witness):.2f}<R"
    )

    proposed_bound = 7.0
    steep_score = lipschitz_counterexample(proposed_bound)
    observed_slope = abs(steep_score(1.0) - steep_score(0.0))
    assert observed_slope > proposed_bound
    print(
        f"  proposed Lipschitz bound B={proposed_bound:.2f}: "
        f"change from 0 to 1 is {observed_slope:.2f}>B"
    )


def main() -> None:
    """Run every numerical illustration."""
    demonstrate_two_node_identity()
    demonstrate_certificate()
    demonstrate_square_root_scaling()
    demonstrate_counterexamples()


if __name__ == "__main__":
    main()
