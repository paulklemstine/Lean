#!/usr/bin/env python3
"""Numerical demonstrations for fixed-phase complex-weighted random graphs.

Requirements: Python 3.10+ and NumPy. Matplotlib is optional and used only when
--plot is supplied. The calculations separate the real Bernoulli probability p
from the complex edge amplitude z.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from math import log, sqrt
from typing import Sequence

import numpy as np
from numpy.typing import NDArray

FloatMatrix = NDArray[np.float64]
ComplexVector = NDArray[np.complex128]


@dataclass(frozen=True)
class SpectralReport:
    """Summary diagnostics for one weighted graph spectrum."""

    n: int
    p: float
    z: complex
    max_modulus: float
    proposed_radius: float
    radius_ratio: float
    maximum_phase_residual: float
    normality_residual: float


def sample_undirected_indicator(
    n: int, p: float, rng: np.random.Generator
) -> FloatMatrix:
    """Sample a loopless symmetric Bernoulli adjacency matrix."""
    if n < 1:
        raise ValueError("n must be positive")
    if not 0.0 <= p <= 1.0:
        raise ValueError("p must lie in [0, 1]")
    upper = np.triu((rng.random((n, n)) < p).astype(np.float64), k=1)
    return upper + upper.T


def transported_spectrum(b: FloatMatrix, z: complex) -> ComplexVector:
    """Compute the weighted spectrum from the symmetric real spectrum."""
    if b.ndim != 2 or b.shape[0] != b.shape[1]:
        raise ValueError("b must be square")
    if not np.allclose(b, b.T):
        raise ValueError("b must be symmetric")
    real_eigenvalues = np.linalg.eigvalsh(b)
    return np.asarray(z * real_eigenvalues, dtype=np.complex128)


def phase_residual(eigenvalues: ComplexVector, z: complex) -> float:
    """Measure departure from the exact phase line zR."""
    if z == 0:
        return float(np.max(np.abs(eigenvalues), initial=0.0))
    numerators = np.abs(np.imag(eigenvalues * np.conjugate(z)))
    denominators = abs(z) * np.maximum(1.0, np.abs(eigenvalues))
    return float(np.max(numerators / denominators, initial=0.0))


def normality_residual(a: NDArray[np.complex128]) -> float:
    """Return a relative Frobenius norm of AA* - A*A."""
    adjoint = a.conjugate().T
    defect = a @ adjoint - adjoint @ a
    scale = max(1.0, float(np.linalg.norm(a, ord="fro") ** 2))
    return float(np.linalg.norm(defect, ord="fro") / scale)


def random_graph_report(
    n: int = 1000,
    p: float | None = None,
    z: complex = 0.5 + 0.3j,
    seed: int = 20260718,
) -> tuple[SpectralReport, FloatMatrix, ComplexVector]:
    """Sample the headline model and report phase and radius diagnostics."""
    probability = log(n) / n if p is None else p
    rng = np.random.default_rng(seed)
    b = sample_undirected_indicator(n, probability, rng)
    eigenvalues = transported_spectrum(b, z)
    a = np.asarray(z * b, dtype=np.complex128)
    max_modulus = float(np.max(np.abs(eigenvalues), initial=0.0))
    radius = abs(z) * sqrt(n)
    ratio = max_modulus / radius if radius > 0 else 0.0
    report = SpectralReport(
        n=n,
        p=probability,
        z=z,
        max_modulus=max_modulus,
        proposed_radius=radius,
        radius_ratio=ratio,
        maximum_phase_residual=phase_residual(eigenvalues, z),
        normality_residual=normality_residual(a),
    )
    return report, b, eigenvalues


def complete_graph_witness(
    n: int = 4, z: complex = 0.5 + 0.3j
) -> tuple[ComplexVector, float, float]:
    """Return the exact K_n spectrum and compare its outlier with |z| sqrt(n)."""
    if n < 2:
        raise ValueError("n must be at least 2")
    spectrum = np.asarray([(n - 1) * z] + [-z] * (n - 1), dtype=np.complex128)
    outlier_modulus = abs((n - 1) * z)
    proposed_radius = abs(z) * sqrt(n)
    return spectrum, outlier_modulus, proposed_radius


def weighted_pattern_expectation(
    pattern_edge_counts: Sequence[int], p: float, z: complex
) -> complex:
    """Compute z times the expected count of prescribed edge patterns."""
    if not 0.0 <= p <= 1.0:
        raise ValueError("p must lie in [0, 1]")
    if any(k < 0 for k in pattern_edge_counts):
        raise ValueError("edge counts must be nonnegative")
    return z * sum(p**k for k in pattern_edge_counts)


def monte_carlo_pattern_expectation(
    patterns: Sequence[Sequence[int]],
    edge_count: int,
    p: float,
    z: complex,
    trials: int = 100_000,
    seed: int = 20260718,
) -> complex:
    """Estimate the weighted count expectation for explicit edge-index patterns."""
    if edge_count < 0 or trials < 1:
        raise ValueError("edge_count must be nonnegative and trials positive")
    if any(any(e < 0 or e >= edge_count for e in pattern) for pattern in patterns):
        raise ValueError("pattern edge index outside the edge universe")
    rng = np.random.default_rng(seed)
    total = 0.0
    batch_size = 10_000
    completed = 0
    while completed < trials:
        batch = min(batch_size, trials - completed)
        graphs = rng.random((batch, edge_count)) < p
        counts = np.zeros(batch, dtype=np.float64)
        for pattern in patterns:
            counts += np.all(graphs[:, list(pattern)], axis=1) if pattern else 1.0
        total += float(np.sum(counts))
        completed += batch
    return z * (total / trials)


def save_spectrum_plot(
    eigenvalues: ComplexVector, z: complex, n: int, filename: str
) -> None:
    """Save a plot showing the phase line and proposed square-root disk."""
    try:
        import matplotlib.pyplot as plt
    except ImportError as exc:
        raise RuntimeError("plotting requires matplotlib") from exc

    radius = abs(z) * sqrt(n)
    theta = np.linspace(0.0, 2.0 * np.pi, 600)
    bound = max(radius, float(np.max(np.abs(eigenvalues), initial=1.0))) * 1.08
    if z != 0:
        direction = z / abs(z)
        line = np.asarray([-bound * direction, bound * direction])
    else:
        line = np.asarray([0j, 0j])

    fig, ax = plt.subplots(figsize=(7.2, 7.2))
    ax.scatter(eigenvalues.real, eigenvalues.imag, s=11, alpha=0.65,
               color="#5b3cc4", label="weighted eigenvalues")
    ax.plot((radius * np.cos(theta)), (radius * np.sin(theta)), "--",
            color="#e4572e", label=r"radius $|z|\sqrt{n}$")
    ax.plot(line.real, line.imag, color="#1b998b", linewidth=1.4,
            label=r"phase line $z\mathbb{R}$")
    ax.axhline(0.0, color="0.8", linewidth=0.7)
    ax.axvline(0.0, color="0.8", linewidth=0.7)
    ax.set_aspect("equal", adjustable="box")
    ax.set_xlabel("real part")
    ax.set_ylabel("imaginary part")
    ax.set_title("Fixed-Phase Undirected Spectrum: Rotation, Not a Disk")
    ax.legend(loc="best")
    fig.tight_layout()
    fig.savefig(filename, dpi=180)
    plt.close(fig)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--n", type=int, default=1000)
    parser.add_argument("--p", type=float, default=None,
                        help="edge probability; default is log(n)/n")
    parser.add_argument("--z-real", type=float, default=0.5)
    parser.add_argument("--z-imag", type=float, default=0.3)
    parser.add_argument("--seed", type=int, default=20260718)
    parser.add_argument("--plot", type=str, default=None,
                        help="optional output PNG path")
    args = parser.parse_args()
    z = complex(args.z_real, args.z_imag)

    report, _, eigenvalues = random_graph_report(args.n, args.p, z, args.seed)
    print("RANDOM UNDIRECTED FIXED-PHASE GRAPH")
    for key, value in report.__dict__.items():
        print(f"  {key}: {value}")
    print("  conclusion: eigenvalues are phase-locked to zR; disk containment alone")
    print("              would not imply a circular spectral distribution")

    spectrum, outlier, radius = complete_graph_witness(4, z)
    print("\nCOMPLETE FOUR-VERTEX WITNESS")
    print(f"  exact spectrum: {spectrum}")
    print(f"  |3z| = {outlier:.12g}")
    print(f"  |z| sqrt(4) = {radius:.12g}")
    print(f"  outside proposed disk: {outlier > radius}")

    patterns = [(0, 1), (1, 2, 3), (0, 3)]
    counts = [len(pattern) for pattern in patterns]
    exact = weighted_pattern_expectation(counts, 0.4, z)
    estimate = monte_carlo_pattern_expectation(patterns, 4, 0.4, z,
                                                trials=100_000, seed=args.seed)
    print("\nWEIGHTED PATTERN EXPECTATION")
    print(f"  exact z * sum(p^|S|): {exact}")
    print(f"  Monte Carlo estimate: {estimate}")
    print(f"  absolute error: {abs(estimate - exact):.6g}")

    if args.plot:
        save_spectrum_plot(eigenvalues, z, args.n, args.plot)
        print(f"\nSaved spectrum plot to {args.plot}")


if __name__ == "__main__":
    main()
