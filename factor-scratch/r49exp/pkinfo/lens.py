#!/usr/bin/env python3
"""
The archimedean capacity gamma_inf(E_inf) of a lens, by Theorem 3.5 of arXiv:2111.14180.

Transcribed from the p.7 page IMAGE (pdftotext flattens the exponents in (3.9)/(3.10)):

  Theorem 3.5. Suppose E_v is the intersection in F_v = C of two closed disks, one of which
  is centered at the origin. Then there is a non-zero complex number xi such that
  E_v = xi . V where V = D(0,r) n D(1,s) for some r,s >= 0. One has
        gamma_v(E_v) = (|xi| . gamma_inf(V))^[K_v:R]
  where gamma_inf(V) is the classical transfinite diameter of V, computed as:
        if V = empty or r + s = 1          -> gamma_inf(V) = 0
        if r >= 1 + s                      -> gamma_inf(V) = s
        if s >= 1 + r                      -> gamma_inf(V) = r
        otherwise, the boundaries meet at u (upper half plane) and ubar, the angle between
        them at the crossing is alpha in (0,pi), and
            zeta = ((ubar - r)/(u - r))^(pi/(2pi - alpha))                 (3.9)
            gamma_inf(V) = (1/(2 Im(zeta))) . (pi/(2 pi - alpha)) . |ubar - u|   (3.10)

The branch matters and is stated explicitly: "when we compute the complex exponential using
the branch of log with imaginary part lying in [0, 2 pi]".  Python's cmath.log returns the
principal branch with imaginary part in (-pi, pi], so the argument must be lifted by 2*pi*i
when it is negative.  Getting this wrong silently produced NEGATIVE capacities, which is the
signature that the branch is wrong.

Verified against Remark 3.7 (s -> 1+r from below must give gamma_inf -> r) and against the
paper's own special cases, in validate_lens.py.
"""

import cmath
import math


def gamma_inf_disk(R):
    return float(R)


def _crossing_points(R1, R2, c):
    """The two points where |z| = R1 and |z - c| = R2 meet; c real >= 0, c > 0."""
    x = (R1 * R1 + c * c - R2 * R2) / (2 * c)
    sq = R1 * R1 - x * x
    if sq < 0:
        return None
    y = math.sqrt(sq)
    return complex(x, y), complex(x, -y)


def gamma_inf_lens(R1, R2, c):
    """gamma_inf of  D(0,R1) n D(c,R2),  c = real non-negative distance between centres.

    Theorem 3.5 normalises: E = xi . V with V = D(0,r) n D(1,s), so r = R1/c, s = R2/c,
    |xi| = c, and  gamma_inf(E) = c . gamma_inf(V).

    IMPORTANT (a bug this file had): EVERYTHING -- the crossing points, alpha, the
    (ubar - r)/(u - r) cross ratio -- must be computed in the NORMALISED frame where the
    second disk is centred at 1.  Computing u,ubar for the original disks while using the
    normalised radius r mixes two frames and silently returns a wrong (even negative or
    > min(R1,R2)) capacity.  The scaling identity gamma(R1,R2,c) == c*gamma(R1/c,R2/c,1)
    is checked in validate_lens.py and pins this down."""
    R1 = float(R1); R2 = float(R2); c = float(c)
    # Degeneracies, stated by Theorem 3.5 in the normalised frame:
    #   r + s = 1  <=>  (R1+R2)/c = 1  <=>  c = R1+R2   (V empty or tangent)  -> 0
    #   s >= 1+r  <=>  R2 >= R1 + c   (V = D(0,r), cap = r)  -> |xi|*r = R1
    #   r >= 1+s  <=>  R1 >= R2 + c   (V = D(1,s), cap = s)  -> |xi|*s = R2
    if c >= R1 + R2:
        return 0.0
    if R2 >= R1 + c:
        return R1
    if R1 >= R2 + c:
        return R2
    if c == 0.0:
        return min(R1, R2)
    # ---- normalise: centres at 0 and 1 ----
    r = R1 / c
    s = R2 / c
    pts = _crossing_points(r, s, 1.0)
    if pts is None:
        return 0.0
    u, ub = pts
    # alpha = "the angle between the boundary of D(0,r) and the boundary of D(1,s) at the
    # intersection point" (Theorem 3.5).  The paper's PROOF settles which angle this is: the
    # cross-ratio map w is conformal, so "fractional linear transformations also preserve
    # angles" carries this angle to the angle of the image ray L.  Hence alpha is the angle
    # between the two boundary ARCS, i.e. the lens's INTERIOR angle at the vertex -- which is
    # the SUPPLEMENT of the angle between the two outward normals.
    #
    # Getting this backwards is silent but wrong: for the canonical lens D(0,1) n D(1,1) it
    # yields 0.5464 instead of 0.6495.  Settled numerically in validate_lens.py T5, where the
    # only branch whose implied capacity d_n / n^(1/(n-1)) converges to 1 -- the known limit
    # for a smooth convex set -- is the interior-angle one (0.990 -> 1, vs 1.18 for the other).
    n1 = u / abs(u)
    n2 = (u - 1.0) / abs(u - 1.0)
    cosang = max(-1.0, min(1.0, n1.real * n2.real + n1.imag * n2.imag))
    alpha = math.pi - math.acos(cosang)
    if alpha <= 0.0 or alpha >= math.pi:
        return 0.0
    expnt = math.pi / (2 * math.pi - alpha)
    # zeta = ((ubar - r)/(u - r))^(pi/(2pi-alpha)), log branch with Im in [0, 2pi)
    logratio = cmath.log((ub - r) / (u - r))
    if logratio.imag < 0.0:
        logratio += 2j * math.pi
    zeta = cmath.exp(expnt * logratio)
    if zeta.imag <= 0.0:
        return 0.0
    cap_v = (1.0 / (2 * zeta.imag)) * expnt * abs(ub - u)
    return c * cap_v


def gamma_archimedean(p, d1, d2, d3, X, Y):
    """gamma_inf(E_∞) alone, for g1 = (d1 x + d2 y + d3)/p, d1 > 0, over F = Q, J = pZ.

    Definition 3.1(ii):  E_∞ = { y : |y| <= Y  and  |b2 y + b3| <= |b1| X }
        = D(0,Y)  n  D(-b3/b2, |b1| X / |b2|),
    viewed as a subset of C (the paper identifies the archimedean place with C)."""
    X = float(X); Y = float(Y)
    R1 = Y
    if d2 == 0:
        return R1 if abs(d3) <= abs(d1) * X else 0.0
    R2 = abs(d1) * X / abs(d2)
    c = abs(-d3 / d2)
    return gamma_inf_lens(R1, R2, c)


def gamma_full(p, d1, d2, d3, X, Y):
    """gamma(E) for g1 = (d1 x + d2 y + d3)/p, d1 > 0, over F = Q, J = pZ.

    Definition 3.1(ii) gives E_∞ = { y : |y| <= Y and |b2 y + b3| <= |b1| X }
        = D(0,Y)  n  D(-b3/b2, |b1| X / |b2|).
    Lemma 3.11: the finite-place product is  ∏_{v finite} |d1|_v = d1^{-1}  (product formula).
    Hence  gamma(E) = gamma_inf(E_∞) / d1."""
    X = float(X); Y = float(Y)
    R1 = Y
    if d2 == 0:
        return (R1 if abs(d3) <= abs(d1) * X else 0.0) / d1
    R2 = abs(d1) * X / abs(d2)
    c = abs(-d3 / d2)
    return gamma_inf_lens(R1, R2, c) / d1
