"""
Reference implementations of the three procedures induced by the two-scale drift law.

All routines run in O(n) time and O(n) space on an output space of size n, use only
the Python standard library, and are numerically stable for every beta > 0.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Dict, List, Sequence, Tuple

Vector = List[float]


# ============================================================================
# Shared numerical primitives
# ============================================================================


def _normalise(v: Sequence[float]) -> Vector:
    total = sum(v)
    if total <= 0.0:
        raise ValueError("cannot normalise a vector of nonpositive total mass")
    return [x / total for x in v]


def _mean(p: Sequence[float], f: Sequence[float]) -> float:
    return sum(pi * fi for pi, fi in zip(p, f))


def _sd(p: Sequence[float], f: Sequence[float]) -> float:
    mu = _mean(p, f)
    return math.sqrt(sum(pi * (fi - mu) ** 2 for pi, fi in zip(p, f)))


def _mad(p: Sequence[float], f: Sequence[float]) -> float:
    mu = _mean(p, f)
    return sum(pi * abs(fi - mu) for pi, fi in zip(p, f))


def _l1(f: Sequence[float], g: Sequence[float]) -> float:
    return sum(abs(fi - gi) for fi, gi in zip(f, g))


def _mix(gamma: float, p: Sequence[float], d: Sequence[float]) -> Vector:
    return [(1.0 - gamma) * pi + gamma * di for pi, di in zip(p, d)]


# ============================================================================
# Algorithm A -- Stabilised Gibbs Tilt of the Pretraining-Mixture Anchor
# ============================================================================


def ptx_optimum(
    p: Sequence[float],
    d: Sequence[float],
    r: Sequence[float],
    beta: float,
    gamma: float,
) -> Vector:
    """
    Compute the exact maximiser of  q |-> E_q[r] - beta * KL(q || p_gamma), where
    p_gamma = (1 - gamma) p + gamma d, namely

        q*(y)  =  p_gamma(y) exp(r(y)/beta) / sum_z p_gamma(z) exp(r(z)/beta).

    The maximum of r is subtracted inside the exponential; the resulting factor
    exp(-max r / beta) cancels identically in the normalisation, so the output is
    exact while every exponential argument is nonpositive and overflow is
    impossible for any beta > 0.

    Complexity: O(n) time, O(n) space, two passes over the data.
    """
    if beta <= 0.0:
        raise ValueError("beta must be strictly positive")
    if not 0.0 <= gamma <= 1.0:
        raise ValueError("gamma must lie in [0, 1]")
    anchor = _mix(gamma, p, d)
    rmax = max(r)
    weights = [ai * math.exp((ri - rmax) / beta) for ai, ri in zip(anchor, r)]
    return _normalise(weights)


# ============================================================================
# Algorithm B -- Training-Free Two-Sided Drift Certificate
# ============================================================================


@dataclass(frozen=True)
class DriftCertificate:
    """A rigorous bracket on the alignment drift, with its two constituent scales."""

    floor: float          # gamma * ||d - p||_1, the beta-independent scale
    envelope: float       # e^{(M-L)/beta} * sigma_{p_gamma}(r) / beta
    lower: float          # certified lower bound on ||q* - p||_1
    upper: float          # certified upper bound on ||q* - p||_1

    def contains(self, value: float, tol: float = 1e-12) -> bool:
        return self.lower - tol <= value <= self.upper + tol


def drift_certificate(
    p: Sequence[float],
    d: Sequence[float],
    r: Sequence[float],
    beta: float,
    gamma: float,
) -> DriftCertificate:
    """
    Bracket ||q*_{beta,gamma} - p||_1 without performing any optimisation, using

        | ||q* - p||_1 - gamma ||d - p||_1 |  <=  e^{(M-L)/beta} sigma_{p_gamma}(r) / beta.

    The lower end is clipped at zero because an l1 distance is nonnegative.

    Complexity: O(n) time, O(n) space.  The bracket is valid for every beta > 0,
    not only asymptotically, and its width shrinks like 1/beta.
    """
    if beta <= 0.0:
        raise ValueError("beta must be strictly positive")
    anchor = _mix(gamma, p, d)
    floor = gamma * _l1(d, p)
    lo, hi = min(r), max(r)
    envelope = math.exp((hi - lo) / beta) * _sd(anchor, r) / beta
    return DriftCertificate(
        floor=floor,
        envelope=envelope,
        lower=max(0.0, floor - envelope),
        upper=floor + envelope,
    )


# ============================================================================
# Algorithm C -- Asymptotic Panel of the Two-Scale Expansion
# ============================================================================


def asymptotic_panel(
    p: Sequence[float],
    d: Sequence[float],
    r: Sequence[float],
    gamma: float,
    tol: float = 1e-12,
) -> Dict[str, object]:
    """
    Compute every asymptotic constant of the two-scale expansion in a single O(n) pass:

        floor                = gamma * ||d - p||_1
                               the beta-independent residual displacement;
        anchor_mad           = MAD_{p_gamma}(r)
                               the sharp constant of beta * ||q* - p_gamma||_1;
        anchor_sd            = sigma_{p_gamma}(r)
                               the classical (lossy) upper bound on that constant;
        sandwich             = (sigma^2/(M-L), sigma), the exact bracket for the MAD;
        dispersion_ratio     = sigma/(M-L), the dimensionless factor by which the
                               Theta(sigma/beta) reading is two-sided;
        drift_coefficient    = the exact 1/beta coefficient of the TOTAL drift,
                               sum_y sgn(p_gamma(y) - p(y)) p_gamma(y) (r(y) - E[r]),
                               with an absolute value on degenerate coordinates
                               (those with p_gamma(y) = p(y));
        degenerate           = the list of degenerate coordinates;
        reward_tax           = gamma * (E_d[r] - E_p[r]), the beta-independent shift
                               in achieved reward;
        reward_limit         = E_p[r] + reward_tax.

    Together these predict ||q* - p||_1 to o(1/beta) and E_{q*}[r] to o(1) with no
    optimisation performed at all.

    Complexity: O(n) time, O(n) space.
    """
    anchor = _mix(gamma, p, d)
    lo, hi = min(r), max(r)
    rng = hi - lo
    sd_val = _sd(anchor, r)
    mad_val = _mad(anchor, r)
    mu = _mean(anchor, r)

    degenerate: List[int] = []
    coefficient = 0.0
    for i, (ai, pi, ri) in enumerate(zip(anchor, p, r)):
        if abs(ai - pi) <= tol:
            degenerate.append(i)
            coefficient += ai * abs(ri - mu)
        else:
            coefficient += (1.0 if ai > pi else -1.0) * ai * (ri - mu)

    tax = gamma * (_mean(d, r) - _mean(p, r))
    sandwich: Tuple[float, float] = (
        (sd_val**2 / rng if rng > 0.0 else 0.0),
        sd_val,
    )
    return {
        "floor": gamma * _l1(d, p),
        "anchor_mad": mad_val,
        "anchor_sd": sd_val,
        "sandwich": sandwich,
        "dispersion_ratio": (sd_val / rng if rng > 0.0 else 0.0),
        "drift_coefficient": coefficient,
        "degenerate": degenerate,
        "reward_tax": tax,
        "reward_limit": _mean(p, r) + tax,
    }


def predicted_drift(panel: Dict[str, object], beta: float) -> float:
    """The two-term prediction floor + coefficient/beta from an asymptotic panel."""
    return float(panel["floor"]) + float(panel["drift_coefficient"]) / beta


# ============================================================================
# Self-check
# ============================================================================


if __name__ == "__main__":
    p = _normalise([0.40, 0.25, 0.20, 0.10, 0.05])
    d = _normalise([0.10, 0.15, 0.22, 0.23, 0.30])
    r = [3.0, 1.0, 0.0, -1.0, -2.0]
    gamma = 0.20

    panel = asymptotic_panel(p, d, r, gamma)
    print("asymptotic panel")
    for key, value in panel.items():
        print(f"    {key:20s} {value}")

    print()
    print(f"    {'beta':>10} {'actual':>12} {'predicted':>12} {'cert lo':>12} {'cert hi':>12} {'ok':>4}")
    for beta in (1.0, 10.0, 100.0, 1000.0, 10000.0):
        q = ptx_optimum(p, d, r, beta, gamma)
        actual = _l1(q, p)
        cert = drift_certificate(p, d, r, beta, gamma)
        print(
            f"    {beta:10.1f} {actual:12.8f} {predicted_drift(panel, beta):12.8f}"
            f" {cert.lower:12.8f} {cert.upper:12.8f} {'yes' if cert.contains(actual) else 'NO':>4}"
        )
