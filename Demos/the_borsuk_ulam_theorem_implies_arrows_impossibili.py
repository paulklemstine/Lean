"""
demo.py — Numerical demonstrations for
"The Borsuk-Ulam Route to Arrow-Style Impossibility: Social Choice Is Topology"

This self-contained script illustrates, numerically, the central results:

  1. One-dimensional Borsuk-Ulam: every continuous 2*pi-periodic function f
     has an antipodal coincidence f(theta) = f(theta + pi).
  2. The continuous Arrow-style impossibility: any continuous,
     reversal-respecting social welfare function (SWF) is forced to a tie.
  3. Non-vacuity: sin satisfies continuity + reversal (but not decisiveness);
     the constant rule satisfies continuity + decisiveness (but not reversal).
  4. Continuity is load-bearing: the discontinuous square-wave rule is decisive
     and reversal-respecting, and its forced discontinuity is detected.
  5. Structural cause: the Z/2 antipodal involution is free (no fixed point).

Run:  python demo.py
No third-party dependencies (only the standard library).
"""

from __future__ import annotations

import math
from typing import Callable, List, Optional, Tuple

PI: float = math.pi
TWO_PI: float = 2.0 * math.pi


# ---------------------------------------------------------------------------
# Core: the antipodal-difference bisection (constructive 1-D Borsuk-Ulam)
# ---------------------------------------------------------------------------

def antipodal_difference(f: Callable[[float], float]) -> Callable[[float], float]:
    """Return g(theta) = f(theta) - f(theta + pi), the 'antipodal difference'.

    For a 2*pi-periodic f, one has g(pi) = f(pi) - f(2pi) = f(pi) - f(0) = -g(0),
    so g changes sign over [0, pi] and must have a zero (Borsuk-Ulam coincidence).
    """
    return lambda theta: f(theta) - f(theta + PI)


def find_antipodal_coincidence(
    f: Callable[[float], float],
    tol: float = 1e-12,
    max_iter: int = 200,
) -> Tuple[float, float]:
    """Locate theta in [0, pi] with f(theta) ~= f(theta + pi) via bisection.

    Returns (theta, residual) where residual = |f(theta) - f(theta + pi)|.
    Complexity: O(log(1/tol)) evaluations of f.
    """
    g = antipodal_difference(f)
    a, b = 0.0, PI
    ga, gb = g(a), g(b)
    # By periodicity gb = -ga; if either endpoint is already (near) a root, return it.
    if abs(ga) <= tol:
        return a, abs(ga)
    if abs(gb) <= tol:
        return b, abs(gb)
    # Ensure a sign change; for periodic f this is guaranteed (gb = -ga).
    if ga * gb > 0:
        raise ValueError("No sign change detected; f may not be 2*pi-periodic.")
    for _ in range(max_iter):
        m = 0.5 * (a + b)
        gm = g(m)
        if abs(gm) <= tol or 0.5 * (b - a) <= tol:
            return m, abs(gm)
        if ga * gm <= 0:
            b, gb = m, gm
        else:
            a, ga = m, gm
    m = 0.5 * (a + b)
    return m, abs(g(m))


# ---------------------------------------------------------------------------
# Candidate social welfare functions
# ---------------------------------------------------------------------------

def swf_sin(theta: float) -> float:
    """Continuous, 2*pi-periodic, reversal-respecting SWF: sin(theta + pi) = -sin theta.
    NOT decisive: it has zeros (ties)."""
    return math.sin(theta)


def swf_constant(theta: float) -> float:
    """Continuous, decisive SWF (always +1). NOT reversal-respecting (1 != -1).
    Models a fixed dictatorial verdict 'A always wins'."""
    return 1.0


def social_wave(theta: float) -> float:
    """Discontinuous square-wave rule: (-1)^floor(theta / pi).

    Decisive (values in {+1, -1}, never 0) and reversal-respecting
    (advancing by pi flips the sign). Provably discontinuous by the impossibility
    theorem."""
    return (-1.0) ** math.floor(theta / PI)


def swf_two_harmonics(theta: float) -> float:
    """A richer continuous reversal-respecting SWF: sin(theta) + 0.5 sin(3 theta).

    Each odd harmonic flips sign under theta -> theta + pi, so the whole function
    is reversal-respecting; hence (by the theorem) it must have a zero."""
    return math.sin(theta) + 0.5 * math.sin(3.0 * theta)


# ---------------------------------------------------------------------------
# Property checks
# ---------------------------------------------------------------------------

def is_reversal_respecting(
    f: Callable[[float], float], samples: int = 2000, tol: float = 1e-9
) -> bool:
    """Numerically test f(theta + pi) == -f(theta) over the circle."""
    for k in range(samples):
        theta = TWO_PI * k / samples
        if abs(f(theta + PI) - (-f(theta))) > tol:
            return False
    return True


def min_abs_value(
    f: Callable[[float], float], samples: int = 20000
) -> Tuple[float, float]:
    """Return (theta_min, min |f|) over a fine sampling of the circle.

    A near-zero minimum certifies a (near) tie, i.e. failure of decisiveness."""
    best_theta, best_val = 0.0, float("inf")
    for k in range(samples):
        theta = TWO_PI * k / samples
        v = abs(f(theta))
        if v < best_val:
            best_theta, best_val = theta, v
    return best_theta, best_val


def detect_discontinuity(
    f: Callable[[float], float], samples: int = 4000, jump_thresh: float = 0.5
) -> List[Tuple[float, float]]:
    """Scan the circle for large jumps between adjacent samples.

    Returns a list of (theta, jump_magnitude). For the square-wave rule this
    finds the mandated sign-flip boundaries, operationalizing the *deduced*
    existence of a discontinuity."""
    jumps: List[Tuple[float, float]] = []
    prev_theta = 0.0
    prev_val = f(prev_theta)
    for k in range(1, samples + 1):
        theta = TWO_PI * k / samples
        val = f(theta)
        if abs(val - prev_val) > jump_thresh:
            jumps.append((0.5 * (prev_theta + theta), abs(val - prev_val)))
        prev_theta, prev_val = theta, val
    return jumps


# ---------------------------------------------------------------------------
# The free Z/2 antipodal involution (algebraic obstruction)
# ---------------------------------------------------------------------------

def zmod2_add(a: int, b: int) -> int:
    """Addition in Z/2."""
    return (a + b) % 2


def antipodal_action_is_free() -> bool:
    """Verify the nonzero element of Z/2 acts without fixed points:
    for g != 0 and all x, g + x != x. This is the algebraic shadow of the
    forced social tie."""
    for g in (1,):  # the unique nonzero element
        for x in (0, 1):
            if zmod2_add(g, x) == x:
                return False
    return True


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo() -> None:
    print("=" * 72)
    print("  Social Choice Is Topology: Borsuk-Ulam => Arrow (numerical demo)")
    print("=" * 72)

    print("\n[1] One-dimensional Borsuk-Ulam: antipodal coincidences")
    print("-" * 72)
    for name, f in [
        ("sin(theta)", swf_sin),
        ("sin + 0.5 sin(3.)", swf_two_harmonics),
        ("cos(theta) (even, periodic)", math.cos),
    ]:
        theta, res = find_antipodal_coincidence(f)
        print(f"  f = {name:28s} -> theta* = {theta:8.5f}, "
              f"|f(t)-f(t+pi)| = {res:.2e}")

    print("\n[2] Forced tie for continuous reversal-respecting SWFs")
    print("-" * 72)
    for name, f in [("sin", swf_sin), ("sin + 0.5 sin(3.)", swf_two_harmonics)]:
        rev = is_reversal_respecting(f)
        theta, mv = min_abs_value(f)
        print(f"  SWF = {name:20s} reversal-respecting={rev}  "
              f"min|swf| ~= {mv:.2e} at theta={theta:.4f}  => TIE")

    print("\n[3] Non-vacuity: each axiom is individually satisfiable")
    print("-" * 72)
    # sin: continuity + reversal, NOT decisive
    _, mv_sin = min_abs_value(swf_sin)
    print(f"  sin       : continuous={True}, reversal={is_reversal_respecting(swf_sin)},"
          f" decisive={mv_sin > 1e-6}  (continuity+reversal, not decisive)")
    # constant: continuity + decisive, NOT reversal
    _, mv_const = min_abs_value(swf_constant)
    print(f"  constant 1: continuous={True}, "
          f"reversal={is_reversal_respecting(swf_constant)}, "
          f"decisive={mv_const > 1e-6}  (continuity+decisive, not reversal)")

    print("\n[4] Continuity is load-bearing: the square-wave escape hatch")
    print("-" * 72)
    rev_wave = is_reversal_respecting(social_wave)
    _, mv_wave = min_abs_value(social_wave)
    jumps = detect_discontinuity(social_wave)
    print(f"  socialWave: reversal-respecting={rev_wave}, "
          f"decisive(min|.|={mv_wave:.2f}>0)={mv_wave > 1e-6}")
    print(f"  => satisfies reversal + decisiveness, so MUST be discontinuous.")
    print(f"  Detected {len(jumps)} jump(s); first at theta ~= {jumps[0][0]:.4f} "
          f"(jump magnitude {jumps[0][1]:.2f})" if jumps else "  No jumps found.")

    print("\n[5] Structural cause: the Z/2 antipodal involution is free")
    print("-" * 72)
    print(f"  For all g != 0 and all x in Z/2: g + x != x  ->  {antipodal_action_is_free()}")
    print("  The forced analytic tie is the shadow of this fixed-point-free action.")

    print("\n" + "=" * 72)
    print("  Conclusion: no continuous, reversal-respecting, decisive SWF exists.")
    print("  Social choice, in its continuous form, is topology.")
    print("=" * 72)


if __name__ == "__main__":
    demo()
