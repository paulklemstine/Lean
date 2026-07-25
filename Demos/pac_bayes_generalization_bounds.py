#!/usr/bin/env python3
"""Numerical demonstrations for finite PAC-Bayes and Gaussian certificates.

The script uses only the Python standard library. It audits the finite
change-of-measure inequality, computes McAllester and Catoni scalar expressions,
and studies isotropic Gaussian perturbation complexity.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, isfinite, log, sqrt
from typing import Iterable, Sequence


@dataclass(frozen=True)
class VariationalAudit:
    expectation: float
    kl: float
    log_partition: float
    upper_bound: float
    slack: float
    tilted_distribution: tuple[float, ...]


@dataclass(frozen=True)
class GaussianCertificate:
    kl: float
    penalty: float
    bound: float


def _validate_probability(weights: Sequence[float], name: str) -> None:
    if not weights:
        raise ValueError(f"{name} must be nonempty")
    if any(x <= 0.0 or not isfinite(x) for x in weights):
        raise ValueError(f"{name} must contain finite, strictly positive masses")
    if abs(sum(weights) - 1.0) > 1e-10:
        raise ValueError(f"{name} must sum to one")


def finite_kl(q: Sequence[float], p: Sequence[float]) -> float:
    """Return KL(q || p) for finite strictly positive distributions."""
    if len(q) != len(p):
        raise ValueError("q and p must have equal length")
    _validate_probability(q, "q")
    _validate_probability(p, "p")
    return sum(qi * log(qi / pi) for qi, pi in zip(q, p))


def gibbs_tilt(p: Sequence[float], scores: Sequence[float]) -> tuple[float, ...]:
    """Return p_i exp(score_i) divided by its partition function."""
    if len(p) != len(scores):
        raise ValueError("p and scores must have equal length")
    _validate_probability(p, "p")
    weighted = [pi * exp(ai) for pi, ai in zip(p, scores)]
    partition = sum(weighted)
    return tuple(value / partition for value in weighted)


def audit_change_of_measure(
    q: Sequence[float], p: Sequence[float], scores: Sequence[float]
) -> VariationalAudit:
    """Numerically audit E_q[a] <= KL(q||p) + log E_p[exp(a)]."""
    if len(q) != len(p) or len(p) != len(scores):
        raise ValueError("q, p, and scores must have equal length")
    _validate_probability(q, "q")
    _validate_probability(p, "p")
    expectation = sum(qi * ai for qi, ai in zip(q, scores))
    divergence = finite_kl(q, p)
    partition = sum(pi * exp(ai) for pi, ai in zip(p, scores))
    upper = divergence + log(partition)
    tilt = gibbs_tilt(p, scores)
    return VariationalAudit(
        expectation=expectation,
        kl=divergence,
        log_partition=log(partition),
        upper_bound=upper,
        slack=upper - expectation,
        tilted_distribution=tilt,
    )


def gaussian_kl(dimension: int, norm_w: float, sigma_q: float, sigma_p: float) -> float:
    """KL between N(w, sigma_q^2 I) and N(0, sigma_p^2 I)."""
    if dimension < 0:
        raise ValueError("dimension must be nonnegative")
    if sigma_q <= 0.0 or sigma_p <= 0.0:
        raise ValueError("Gaussian scales must be positive")
    ratio = (sigma_q * sigma_q) / (sigma_p * sigma_p)
    shift = norm_w * norm_w / (2.0 * sigma_p * sigma_p)
    mismatch = dimension / 2.0 * (ratio - 1.0 - log(ratio))
    return shift + mismatch


def mcallester_bound(empirical_risk: float, kl: float, n: int, delta: float) -> float:
    """Compute the McAllester scalar expression on its standard domain."""
    if n <= 1:
        raise ValueError("n must exceed one")
    if not 0.0 < delta < 1.0:
        raise ValueError("delta must lie in (0, 1)")
    radicand = (kl + log(2.0 * sqrt(n) / delta)) / (2.0 * (n - 1.0))
    if radicand < 0.0:
        raise ValueError("square-root argument is negative")
    return empirical_risk + sqrt(radicand)


def catoni_bound(
    empirical_risk: float, kl: float, n: int, delta: float, temperature: float
) -> float:
    """Compute Catoni's scalar exponential expression."""
    if n <= 0:
        raise ValueError("n must be positive")
    if not 0.0 < delta < 1.0:
        raise ValueError("delta must lie in (0, 1)")
    if temperature <= 0.0:
        raise ValueError("temperature must be positive")
    exponent = -temperature * empirical_risk - (kl + log(1.0 / delta)) / n
    return (1.0 - exp(exponent)) / (1.0 - exp(-temperature))


def gaussian_mcallester_certificate(
    dimension: int,
    norm_w: float,
    sigma_q: float,
    sigma_p: float,
    empirical_risk: float,
    n: int,
    delta: float,
) -> GaussianCertificate:
    """Insert isotropic Gaussian KL into the McAllester expression."""
    divergence = gaussian_kl(dimension, norm_w, sigma_q, sigma_p)
    bound = mcallester_bound(empirical_risk, divergence, n, delta)
    return GaussianCertificate(divergence, bound - empirical_risk, bound)


def best_catoni_temperature(
    empirical_risk: float,
    kl: float,
    n: int,
    delta: float,
    temperatures: Iterable[float],
) -> tuple[float, float]:
    """Return the grid temperature giving the smallest Catoni expression."""
    candidates = [
        (catoni_bound(empirical_risk, kl, n, delta, lam), lam)
        for lam in temperatures
    ]
    if not candidates:
        raise ValueError("temperature grid must be nonempty")
    value, lam = min(candidates)
    return lam, value


def demo_variational_identity() -> None:
    print("\n1. FINITE CHANGE OF MEASURE")
    p = (0.50, 0.30, 0.20)
    scores = (-0.25, 0.60, 1.10)
    q = (0.20, 0.35, 0.45)
    audit = audit_change_of_measure(q, p, scores)
    print(f"posterior expectation : {audit.expectation:.8f}")
    print(f"KL + log partition   : {audit.upper_bound:.8f}")
    print(f"nonnegative slack    : {audit.slack:.8f}")
    equality = audit_change_of_measure(audit.tilted_distribution, p, scores)
    print(f"Gibbs-tilt slack     : {equality.slack:.3e}")
    assert audit.slack >= -1e-12
    assert abs(equality.slack) < 1e-12


def demo_gaussian_certificates() -> None:
    print("\n2. GAUSSIAN MCALLESTER CERTIFICATES")
    for n in (100, 1_000, 10_000, 100_000):
        cert = gaussian_mcallester_certificate(
            dimension=50,
            norm_w=2.0,
            sigma_q=1.0,
            sigma_p=1.0,
            empirical_risk=0.08,
            n=n,
            delta=0.05,
        )
        print(
            f"n={n:6d}  KL={cert.kl:7.4f}  "
            f"penalty={cert.penalty:8.5f}  bound={cert.bound:8.5f}"
        )


def demo_variance_and_temperature() -> None:
    print("\n3. VARIANCE MISMATCH AND CATONI TEMPERATURE")
    for sigma_q in (0.5, 0.75, 1.0, 1.5, 2.0):
        value = gaussian_kl(100, 1.5, sigma_q, 1.0)
        print(f"sigma_q={sigma_q:4.2f}  Gaussian KL={value:10.5f}")
    kl = gaussian_kl(100, 1.5, 1.0, 1.0)
    grid = (0.05, 0.1, 0.2, 0.5, 1.0, 2.0, 5.0)
    lam, value = best_catoni_temperature(0.10, kl, 2_000, 0.05, grid)
    print(f"best grid temperature={lam:.2f}, Catoni expression={value:.6f}")


def main() -> None:
    demo_variational_identity()
    demo_gaussian_certificates()
    demo_variance_and_temperature()


if __name__ == "__main__":
    main()
