"""Reference implementations of the three algorithms bundled with the package.

Each function is self-contained and depends only on the standard library.
Running this file executes a small self-test of all three algorithms.
"""

from __future__ import annotations

import math
from typing import Dict, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# Algorithm 1: Ambiguity-annotated augmentation report
# ---------------------------------------------------------------------------


def ambiguity_annotated_report(p: Sequence[float], x: Sequence[float],
                               z: Sequence[float], y: Sequence[float]) -> Dict[str, float]:
    """Full augmentation report with the exact sign-blind ambiguity attached.

    Returns the three variance-share readings, the correlation triple product and
    its sign bit, the true increment, the value a sign-blind reader could not
    exclude, the ambiguity amplitude, and the universal ceiling.
    """
    def ip(f: Sequence[float], g: Sequence[float]) -> float:
        return sum(pi * fi * gi for pi, fi, gi in zip(p, f, g))

    def mean(f: Sequence[float]) -> float:
        return sum(pi * fi for pi, fi in zip(p, f))

    def cov(f: Sequence[float], g: Sequence[float]) -> float:
        return ip(f, g) - mean(f) * mean(g)

    vx, vy, vz = cov(x, x), cov(y, y), cov(z, z)
    if min(vx, vy, vz) <= 0.0:
        raise ValueError("every feature must have strictly positive variance")

    rho_xy = cov(x, y) / math.sqrt(vx * vy)
    rho_xz = cov(x, z) / math.sqrt(vx * vz)
    rho_zy = cov(z, y) / math.sqrt(vz * vy)
    a, c, e = rho_xy ** 2, rho_zy ** 2, rho_xz ** 2
    if e >= 1.0 - 1e-15:
        raise ValueError("degenerate: the feature is an affine function of the footprint")

    P = rho_xy * rho_xz * rho_zy
    s = 1.0 if P >= 0.0 else -1.0
    absP = math.sqrt(max(a * c * e, 0.0))
    increment = (c + a * e - 2.0 * s * absP) / (1.0 - e)
    shadow = (c + a * e + 2.0 * s * absP) / (1.0 - e)
    amplitude = 4.0 * absP / (1.0 - e)
    ceiling = 2.0 * math.sqrt(e) / (1.0 + math.sqrt(e))
    return {
        "R2_xy": a, "R2_zy": c, "R2_xz": e,
        "triple_product": P, "sign_bit": s,
        "increment": increment,
        "sign_blind_shadow_value": shadow,
        "ambiguity_amplitude": amplitude,
        "universal_ceiling": ceiling,
        "total_share": a + increment,
        "gram_slack": 1.0 - a - c - e + 2.0 * P,
    }


# ---------------------------------------------------------------------------
# Algorithm 2: Adversarial dashboard-identical pair generator
# ---------------------------------------------------------------------------


def adversarial_pair(gap: float) -> Optional[Tuple[List[float], List[float], float]]:
    """Construct two four-key targets with identical readings and prescribed gap.

    Solves 4 g t^2 + (45 g - 80) t + 100 g = 0 for t = u^2 (with b = 1) so that the
    active member's increment equals `gap`, then returns the two target vectors
    together with the realised gap.  Feasible exactly for 0 < gap <= 16/17.
    """
    if not (0.0 < gap <= 16.0 / 17.0 + 1e-15):
        return None
    A, B, C = 4.0 * gap, 45.0 * gap - 80.0, 100.0 * gap
    disc = B * B - 4.0 * A * C
    if disc < 0.0:
        disc = 0.0
    t = (-B - math.sqrt(disc)) / (2.0 * A)      # the smaller positive root
    if t <= 0.0:
        t = (-B + math.sqrt(disc)) / (2.0 * A)
    u = math.sqrt(t)
    b = 1.0
    foot = [1.0, 2.0, 3.0, 4.0]
    eps = [1.0, -1.0, -1.0, 1.0]
    zt = [-0.1, 0.3, -0.3, 0.1]
    kB, kC = u + 5.0 * b * b / u, u - 5.0 * b * b / u
    yB = [b * f + kB * ev for f, ev in zip(foot, eps)]
    yC = [b * f + kC * ev + 20.0 * b * zi for f, ev, zi in zip(foot, eps, zt)]
    realised = 80.0 * b * b * t / (5.0 * b * b * t + 4.0 * (t + 5.0 * b * b) ** 2)
    return yB, yC, realised


# ---------------------------------------------------------------------------
# Algorithm 3: Legacy dashboard auditor
# ---------------------------------------------------------------------------


def audit_legacy_dashboard(a: float, c: float, e: float,
                           threshold: float) -> Dict[str, object]:
    """Decide whether a sign-blind report can certify a decision at a threshold.

    Given only the three readings, returns the two admissible increments, their
    exact separation, the universal ceiling, and a verdict: CERTIFIED when the
    separation cannot move the decision, INDETERMINATE otherwise.
    """
    if not (0.0 <= e < 1.0):
        raise ValueError("the collinearity reading must lie in [0, 1)")
    absP = math.sqrt(max(a * c * e, 0.0))
    lo = (c + a * e - 2.0 * absP) / (1.0 - e)
    hi = (c + a * e + 2.0 * absP) / (1.0 - e)
    amplitude = hi - lo
    both_sides = (lo < threshold) != (hi < threshold)
    return {
        "admissible_low": lo,
        "admissible_high": hi,
        "ambiguity_amplitude": amplitude,
        "universal_ceiling": 2.0 * math.sqrt(e) / (1.0 + math.sqrt(e)),
        "verdict": "INDETERMINATE" if both_sides else "CERTIFIED",
        "reason": ("the two admissible increments straddle the decision threshold"
                   if both_sides else
                   "both admissible increments fall on the same side of the threshold"),
    }


if __name__ == "__main__":
    pU = [0.25] * 4
    foot = [1.0, 2.0, 3.0, 4.0]
    feat = [1.0, 1.0, 0.0, 0.0]
    yB = [0.7, -0.4, -0.3, 1.0]
    yC = [0.3, 0.4, -0.7, 1.0]
    for name, y in (("y_B", yB), ("y_C", yC)):
        rep = ambiguity_annotated_report(pU, foot, feat, y)
        print(name, {k: round(v, 6) for k, v in rep.items()})
    for g in (0.1, 0.5, 0.9, 16 / 17):
        out = adversarial_pair(g)
        assert out is not None
        _, _, realised = out
        print(f"requested gap {g:.6f} -> realised {realised:.6f}")
    print(audit_legacy_dashboard(5 / 149, 4 / 149, 0.8, threshold=0.10))
    print(audit_legacy_dashboard(0.01, 0.0000001, 0.3, threshold=0.10))
