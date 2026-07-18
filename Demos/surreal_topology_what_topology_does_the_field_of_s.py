#!/usr/bin/env python3
"""Finite numerical illustrations of infinitesimal clopen-cut arguments.

Real floating-point arithmetic cannot contain a positive epsilon whose every
natural multiple stays below a fixed positive gap. These demonstrations use
finite cutoffs to show the mechanism and, equally importantly, the exact point
at which Archimedean arithmetic differs from surreal arithmetic.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class FiniteScaleExperiment:
    """A finite analogue of a gap and an infinitesimal step."""

    gap: float
    cutoff: int
    epsilon: float
    multiples: tuple[float, ...]


def finite_scale_experiment(gap: float, cutoff: int) -> FiniteScaleExperiment:
    """Choose epsilon = gap/(cutoff+1) and list multiples through the cutoff."""
    if gap <= 0.0:
        raise ValueError("gap must be positive")
    if cutoff < 1:
        raise ValueError("cutoff must be at least 1")
    epsilon = gap / (cutoff + 1)
    multiples = tuple(n * epsilon for n in range(cutoff + 1))
    return FiniteScaleExperiment(gap, cutoff, epsilon, multiples)


def finite_step_membership(z: float, origin: float, epsilon: float, cutoff: int) -> bool:
    """Test membership below one of the first cutoff+1 finite thresholds."""
    if epsilon <= 0.0:
        raise ValueError("epsilon must be positive")
    if cutoff < 0:
        raise ValueError("cutoff must be nonnegative")
    return any(z < origin + n * epsilon for n in range(cutoff + 1))


def first_crossing(gap: float, epsilon: float) -> int:
    """Return the first natural n with n*epsilon >= gap in real arithmetic."""
    if gap <= 0.0 or epsilon <= 0.0:
        raise ValueError("gap and epsilon must be positive")
    n = int(gap / epsilon)
    while n * epsilon < gap:
        n += 1
    while n > 0 and (n - 1) * epsilon >= gap:
        n -= 1
    return n


def ascii_threshold_plot(values: Sequence[float], gap: float, width: int = 56) -> str:
    """Render finite multiples on a text scale from zero to the gap."""
    if gap <= 0.0 or width < 10:
        raise ValueError("invalid plot scale")
    rows: list[str] = []
    for n, value in enumerate(values):
        position = min(width - 1, max(0, round((value / gap) * (width - 1))))
        line = ["-"] * width
        line[position] = "●"
        line[-1] = "|"
        rows.append(f"n={n:2d}  {''.join(line)}  {value:.6g}")
    return "\n".join(rows)


def demonstrate_finite_window(gap: float = 1.0, cutoff: int = 12) -> None:
    """Print a finite imitation of natural multiples staying below a gap."""
    experiment = finite_scale_experiment(gap, cutoff)
    print("DEMO 1 — Finite window below a prescribed gap")
    print(f"gap d = {gap:g}, cutoff N = {cutoff}")
    print(f"epsilon = d/(N+1) = {experiment.epsilon:.8g}")
    print(f"All n*epsilon < d for 0 <= n <= N: "
          f"{all(v < gap for v in experiment.multiples)}")
    print(ascii_threshold_plot(experiment.multiples, gap))
    print(f"At n=N+1, n*epsilon = {(cutoff + 1) * experiment.epsilon:.8g}\n")


def demonstrate_separator(origin: float = 2.0, target: float = 5.0, cutoff: int = 10) -> None:
    """Show a cutoff finite-step lower ray containing origin but not target."""
    if target <= origin:
        raise ValueError("target must exceed origin")
    gap = target - origin
    epsilon = gap / (cutoff + 1)
    sample_points = (origin - 0.5, origin, origin + gap / 3, target, target + 0.5)
    print("DEMO 2 — Truncated finite-step separator")
    print(f"origin x = {origin:g}, target y = {target:g}, epsilon = {epsilon:.8g}")
    for z in sample_points:
        status = finite_step_membership(z, origin, epsilon, cutoff)
        print(f"z={z:8.4f}  belongs below a threshold: {status}")
    print("The finite model contains x and excludes y through cutoff N.\n")


def demonstrate_archimedean_contrast(gap: float = 1.0,
                                     steps: Iterable[float] = (0.2, 0.05, 0.001)) -> None:
    """Show that each fixed positive real step eventually crosses the gap."""
    print("DEMO 3 — The Archimedean contrast")
    print(f"gap d = {gap:g}")
    for epsilon in steps:
        crossing = first_crossing(gap, epsilon)
        print(f"epsilon={epsilon:.8g}: first crossing n={crossing}, "
              f"n*epsilon={crossing * epsilon:.8g}")
    print("Every positive real epsilon crosses eventually; the surreal theorem")
    print("asserts the existence of a positive infinitesimal that never does.")


def main() -> None:
    demonstrate_finite_window()
    demonstrate_separator()
    demonstrate_archimedean_contrast()


if __name__ == "__main__":
    main()
