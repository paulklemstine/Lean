#!/usr/bin/env python3
"""
Stereographic Projection: Computational Verification Suite
===========================================================

Numerically verifies every theorem from the Lean formalization.
This serves as an independent cross-check of the machine-verified proofs.

Requirements: pip install numpy
"""

import numpy as np
from typing import Tuple, List

# ============================================================
# Core Definitions
# ============================================================

def sq_norm(y: np.ndarray) -> float:
    return float(np.sum(y**2))

def stereo_denom(y: np.ndarray) -> float:
    return 1.0 + sq_norm(y)

def inv_stereo_n(y: np.ndarray) -> np.ndarray:
    D = stereo_denom(y)
    S = sq_norm(y)
    first = 2 * y / D
    last = (S - 1) / D
    return np.append(first, last)

def stereo_n(x: np.ndarray) -> np.ndarray:
    return x[:-1] / (1 - x[-1])

def inv_stereo_s(y: np.ndarray) -> np.ndarray:
    D = stereo_denom(y)
    S = sq_norm(y)
    first = 2 * y / D
    last = (1 - S) / D
    return np.append(first, last)

def stereo_s(x: np.ndarray) -> np.ndarray:
    return x[:-1] / (1 + x[-1])

def dot_prod(y: np.ndarray, z: np.ndarray) -> float:
    return float(np.sum(y * z))

def conformal_factor(y: np.ndarray) -> float:
    return 2.0 / stereo_denom(y)

# ============================================================
# Verification Functions
# ============================================================

class TheoremVerifier:
    def __init__(self, tol=1e-12):
        self.tol = tol
        self.passed = 0
        self.failed = 0
        self.results = []
    
    def check(self, name: str, condition: bool, detail: str = ""):
        status = "✅ PASS" if condition else "❌ FAIL"
        self.results.append((name, condition, detail))
        if condition:
            self.passed += 1
        else:
            self.failed += 1
        print(f"  {status}: {name}" + (f" ({detail})" if detail else ""))
    
    def check_close(self, name: str, a: float, b: float, detail: str = ""):
        ok = abs(a - b) < self.tol
        self.check(name, ok, f"got {a:.15g}, expected {b:.15g}, diff={abs(a-b):.2e}")
    
    def summary(self):
        print(f"\n{'='*60}")
        print(f"Results: {self.passed} passed, {self.failed} failed, {self.passed+self.failed} total")
        print(f"{'='*60}")


def verify_basic(v: TheoremVerifier):
    """Verify Basic.lean theorems."""
    print("\n--- Basic.lean ---")
    np.random.seed(42)
    
    for N in [1, 2, 3, 5, 10]:
        for _ in range(10):
            y = np.random.randn(N) * 3
            x = inv_stereo_n(y)
            
            # invStereoN_norm_sq
            norm_sq = sum(xi**2 for xi in x)
            v.check_close(f"invStereoN_norm_sq (N={N})", norm_sq, 1.0)
            
            # invStereoN_last_ne_one
            v.check(f"invStereoN_last_ne_one (N={N})", abs(x[-1] - 1.0) > 1e-15)
            
            # stereoN_invStereoN
            y_back = stereo_n(x)
            v.check_close(f"stereoN_invStereoN (N={N})", np.max(np.abs(y_back - y)), 0.0)
    
    # invStereoN_injective
    y1 = np.array([1.0, 2.0, 3.0])
    y2 = np.array([1.0, 2.0, 3.0001])
    x1, x2 = inv_stereo_n(y1), inv_stereo_n(y2)
    v.check("invStereoN_injective", np.max(np.abs(x1 - x2)) > 0)


def verify_novel(v: TheoremVerifier):
    """Verify NovelTheorems.lean."""
    print("\n--- NovelTheorems.lean ---")
    np.random.seed(43)
    
    for N in [2, 3, 5]:
        y = np.random.randn(N) * 2
        x = inv_stereo_n(y)
        D = stereo_denom(y)
        S = sq_norm(y)
        
        # conformal_factor_eq_one_minus_last
        v.check_close(f"conformal_factor_eq_one_minus_last (N={N})", 2/D, 1 - x[-1])
        
        # energy_partition
        h_energy = sum(x[i]**2 for i in range(N))
        v_energy = x[-1]**2
        v.check_close(f"energy_partition (N={N})", h_energy + v_energy, 1.0)
        
        # invStereoN_neg_last_coord
        x_neg = inv_stereo_n(-y)
        v.check_close(f"invStereoN_neg_last_coord (N={N})", x_neg[-1], x[-1])
        
        # invStereoN_neg_first_coords
        for i in range(N):
            v.check_close(f"invStereoN_neg_first_coords (N={N}, i={i})", x_neg[i], -x[i])
        
        # invStereoN_scale_last
        r = 2.5
        ry = r * y
        x_scaled = inv_stereo_n(ry)
        expected_last = (r**2 * S - 1) / (1 + r**2 * S)
        v.check_close(f"invStereoN_scale_last (N={N})", x_scaled[-1], expected_last)
        
        # pythagorean_stereo_general
        v.check_close(f"pythagorean_stereo_general (N={N})", 4*S + (S-1)**2, (S+1)**2)
        
        # invStereoN_inversion_last (y != 0)
        if S > 1e-10:
            y_inv = y / S
            x_inv = inv_stereo_n(y_inv)
            v.check_close(f"invStereoN_inversion_last (N={N})", x_inv[-1], -x[-1])


def verify_south_pole(v: TheoremVerifier):
    """Verify SouthPole.lean."""
    print("\n--- SouthPole.lean ---")
    np.random.seed(44)
    
    for N in [2, 3, 5]:
        y = np.random.randn(N) * 2
        
        # invStereoS_norm_sq
        xs = inv_stereo_s(y)
        v.check_close(f"invStereoS_norm_sq (N={N})", sum(xi**2 for xi in xs), 1.0)
        
        # invStereoS_last_ne_neg_one
        v.check(f"invStereoS_last_ne_neg_one (N={N})", abs(xs[-1] + 1.0) > 1e-15)
        
        # invStereoN_invStereoS_first_coords
        xn = inv_stereo_n(y)
        for i in range(N):
            v.check_close(f"first_coords_agree (N={N}, i={i})", xn[i], xs[i])
        
        # invStereoS_last_neg_invStereoN
        v.check_close(f"invStereoS_last_neg (N={N})", xs[-1], -xn[-1])
        
        # stereoS_invStereoS
        y_back = stereo_s(xs)
        v.check_close(f"stereoS_invStereoS (N={N})", np.max(np.abs(y_back - y)), 0.0)
        
        # transition_map_is_inversion
        if sq_norm(y) > 0.1:
            trans = stereo_s(inv_stereo_n(y))
            expected = y / sq_norm(y)
            v.check_close(f"transition_is_inversion (N={N})", np.max(np.abs(trans - expected)), 0.0)
            
            # transition_map_involution
            trans2 = stereo_s(inv_stereo_n(trans))
            v.check_close(f"transition_involution (N={N})", np.max(np.abs(trans2 - y)), 0.0)


def verify_metric(v: TheoremVerifier):
    """Verify MetricGeometry.lean."""
    print("\n--- MetricGeometry.lean ---")
    np.random.seed(45)
    
    for N in [2, 3, 5]:
        y = np.random.randn(N) * 2
        z = np.random.randn(N) * 2
        
        Dy, Dz = stereo_denom(y), stereo_denom(z)
        Sy, Sz = sq_norm(y), sq_norm(z)
        xy, xz = inv_stereo_n(y), inv_stereo_n(z)
        
        # invStereoN_dot_product
        dot_sphere = dot_prod(xy, xz)
        expected_dot = (4 * dot_prod(y, z) + (Sy - 1) * (Sz - 1)) / (Dy * Dz)
        v.check_close(f"invStereoN_dot_product (N={N})", dot_sphere, expected_dot)
        
        # invStereoN_chordal_sq
        chordal_sq = sum((xy[i] - xz[i])**2 for i in range(N + 1))
        sq_dist = sum((y[i] - z[i])**2 for i in range(N))
        expected_chordal = 4 * sq_dist / (Dy * Dz)
        v.check_close(f"invStereoN_chordal_sq (N={N})", chordal_sq, expected_chordal)
        
        # angular_distance_identity
        v.check_close(f"angular_distance_identity (N={N})", 2 - 2*dot_sphere, chordal_sq)
        
        # stereoDenom_ge_one
        v.check(f"stereoDenom_ge_one (N={N})", Dy >= 1.0)
        
        # chordal_le_euclidean
        v.check(f"chordal_le_euclidean (N={N})", expected_chordal <= 4 * sq_dist + 1e-12)


def verify_conformal(v: TheoremVerifier):
    """Verify ConformalAnalysis.lean."""
    print("\n--- ConformalAnalysis.lean ---")
    np.random.seed(46)
    
    for N in [1, 2, 3, 5]:
        y = np.random.randn(N) * 2
        x = inv_stereo_n(y)
        cf = conformal_factor(y)
        
        # conformal_factor_pos
        v.check(f"conformal_factor_pos (N={N})", cf > 0)
        
        # conformal_factor_le_two
        v.check(f"conformal_factor_le_two (N={N})", cf <= 2.0 + 1e-15)
        
        # invStereoN_coord_bounded
        for i in range(N + 1):
            v.check(f"coord_bounded (N={N}, i={i})", abs(x[i]) <= 1.0 + 1e-15)
        
        # invStereoN_last_coord_range
        v.check(f"last_coord_range (N={N})", -1 <= x[-1] + 1e-15 and x[-1] < 1 - 1e-15)
        
        # Hemisphere characterization
        S = sq_norm(y)
        if S <= 1:
            v.check(f"unit_ball_to_southern (N={N})", x[-1] <= 1e-15)
        if abs(S - 1) < 1e-10:
            v.check_close(f"unit_sphere_to_equator (N={N})", x[-1], 0.0)
        if S > 1:
            v.check(f"exterior_to_northern (N={N})", x[-1] > -1e-15)
    
    # conformal_factor_at_zero
    v.check_close("conformal_factor_at_zero", conformal_factor(np.zeros(3)), 2.0)
    
    # Monotonicity
    y1 = np.array([0.5, 0.3])
    y2 = np.array([2.0, 1.5])
    if sq_norm(y1) <= sq_norm(y2):
        v.check("invStereoN_last_mono", inv_stereo_n(y1)[-1] <= inv_stereo_n(y2)[-1] + 1e-15)


def verify_rational(v: TheoremVerifier):
    """Verify RationalPoints.lean."""
    print("\n--- RationalPoints.lean ---")
    
    # invStereoN_zero_is_south_pole
    for N in [1, 2, 3, 5]:
        x0 = inv_stereo_n(np.zeros(N))
        v.check_close(f"invStereoN_zero_south_pole (N={N})", x0[-1], -1.0)
        for i in range(N):
            v.check_close(f"invStereoN_zero_first_coords (N={N}, i={i})", x0[i], 0.0)
    
    # invStereoN_1d_first and last
    for t in [0.0, 0.5, 1.0, 2.0, -1.0, 3.0]:
        x = inv_stereo_n(np.array([t]))
        v.check_close(f"invStereoN_1d_first (t={t})", x[0], 2*t/(1+t**2))
        v.check_close(f"invStereoN_1d_last (t={t})", x[1], (t**2-1)/(1+t**2))
    
    # pythagorean_from_rational_stereo
    for p, q in [(3,4), (5,12), (8,15), (7,24)]:
        a, b, c = 2*p*q, p**2 - q**2, p**2 + q**2
        v.check(f"pythagorean (p={p},q={q})", a**2 + b**2 == c**2)
    
    # brahmagupta_fibonacci
    for _ in range(10):
        a, b, c, d = np.random.randint(-20, 21, 4)
        lhs = (a**2 + b**2) * (c**2 + d**2)
        rhs = (a*c - b*d)**2 + (a*d + b*c)**2
        v.check(f"brahmagupta_fibonacci ({a},{b},{c},{d})", lhs == rhs)
    
    # sqNormFin_basis
    for N in [2, 3, 5]:
        for k in range(N):
            basis = np.zeros(N)
            basis[k] = 1.0
            v.check_close(f"sqNormFin_basis (N={N}, k={k})", sq_norm(basis), 1.0)
            x = inv_stereo_n(basis)
            v.check_close(f"basis_to_equator (N={N}, k={k})", x[-1], 0.0)


def verify_moebius(v: TheoremVerifier):
    """Verify MoebiusGroup.lean."""
    print("\n--- MoebiusGroup.lean ---")
    
    def moebius(a, b, c, d, z):
        return (a*z + b) / (c*z + d)
    
    # moebius_1d_id
    for z in [0, 1, -1, 3.14, 100]:
        v.check_close(f"moebius_1d_id (z={z})", moebius(1, 0, 0, 1, z), z)
    
    # moebius_1d_inversion
    for z in [1, 2, -3, 0.5]:
        v.check_close(f"moebius_1d_inversion (z={z})", moebius(0, 1, 1, 0, z), 1/z)
    
    # moebius_1d_translation
    for a, z in [(1, 2), (3, -1), (-2, 5)]:
        v.check_close(f"moebius_1d_translation (a={a},z={z})", moebius(1, a, 0, 1, z), z+a)
    
    # moebius_1d_scaling
    for s, z in [(2, 3), (0.5, -1), (3, 4)]:
        v.check_close(f"moebius_1d_scaling (s={s},z={z})", moebius(s, 0, 0, 1, z), s*z)
    
    # moebius_1d_composition
    a1, b1, c1, d1 = 2, 1, 1, 3
    a2, b2, c2, d2 = 1, -1, 2, 1
    for z in [0, 1, 2, 3]:
        denom_inner = c2*z + d2
        if abs(denom_inner) < 1e-10:
            continue
        inner = moebius(a2, b2, c2, d2, z)
        denom_outer = c1*inner + d1
        if abs(denom_outer) < 1e-10:
            continue
        composed = moebius(a1, b1, c1, d1, inner)
        matrix = moebius(a1*a2+b1*c2, a1*b2+b1*d2, c1*a2+d1*c2, c1*b2+d1*d2, z)
        v.check_close(f"moebius_composition (z={z})", composed, matrix)
    
    # cross_ratio_translation_invariant
    z1, z2, z3, z4 = 1.0, 2.0, 4.0, 7.0
    for a in [0, 1, -3, 10, 100]:
        orig = (z1-z3)*(z2-z4)
        trans = ((z1+a)-(z3+a))*((z2+a)-(z4+a))
        v.check_close(f"cross_ratio_translation (a={a})", trans, orig)
    
    # cayley_transform_real_to_circle
    for t in [0, 1, -1, 2, 10, 0.1]:
        x = (t**2 - 1) / (t**2 + 1)
        y = 2*t / (t**2 + 1)
        v.check_close(f"cayley_transform (t={t})", x**2 + y**2, 1.0)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Stereographic Projection: Theorem Verification Suite")
    print("=" * 60)
    
    v = TheoremVerifier()
    
    verify_basic(v)
    verify_novel(v)
    verify_south_pole(v)
    verify_metric(v)
    verify_conformal(v)
    verify_rational(v)
    verify_moebius(v)
    
    v.summary()
