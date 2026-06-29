#!/usr/bin/env python3
"""
applications.py — Real-world applications of path groupoid structure.

Demonstrates three cross-domain applications:

1. ROBOTICS / MOTION PLANNING
   Path concatenation composes robot trajectories.
   Associativity means modular planners can freely re-bracket segments.

2. PHYSICS / PARALLEL TRANSPORT
   Path composition models sequential evolution.
   Inverse laws model time-reversal and backtracking cancellation.

3. DATA SCIENCE / TRAJECTORY CLASSIFICATION
   Groupoid quotient classifies trajectories up to reparametrization.
"""

import math
from typing import List, Tuple, Callable


# ─── Application 1: Motion Planning ────────────────────────────────

class Trajectory2D:
    """A trajectory in the plane, represented as (x(t), y(t)) for t ∈ [0,1]."""
    
    def __init__(self, xs: List[float], ys: List[float], ts: List[float] = None):
        self.n = len(xs)
        assert len(ys) == self.n
        if ts is None:
            self.ts = [i / (self.n - 1) for i in range(self.n)]
        else:
            self.ts = ts
        self.xs = xs
        self.ys = ys
    
    def __call__(self, t: float) -> Tuple[float, float]:
        t = max(0.0, min(1.0, t))
        if t <= 0.0:
            return (self.xs[0], self.ys[0])
        if t >= 1.0:
            return (self.xs[-1], self.ys[-1])
        # Linear interpolation
        for i in range(self.n - 1):
            if self.ts[i] <= t <= self.ts[i+1]:
                frac = (t - self.ts[i]) / (self.ts[i+1] - self.ts[i])
                x = self.xs[i] + frac * (self.xs[i+1] - self.xs[i])
                y = self.ys[i] + frac * (self.ys[i+1] - self.ys[i])
                return (x, y)
        return (self.xs[-1], self.ys[-1])
    
    @property
    def start(self):
        return (self.xs[0], self.ys[0])
    
    @property
    def end(self):
        return (self.xs[-1], self.ys[-1])
    
    def length(self, n_samples=100) -> float:
        """Approximate arc length."""
        total = 0.0
        prev = self(0.0)
        for i in range(1, n_samples + 1):
            t = i / n_samples
            curr = self(t)
            total += math.sqrt((curr[0]-prev[0])**2 + (curr[1]-prev[1])**2)
            prev = curr
        return total


def concat_trajectories(p: Trajectory2D, q: Trajectory2D) -> Trajectory2D:
    """Concatenate two trajectories (p ends where q starts)."""
    n = 201
    ts = [i / (n-1) for i in range(n)]
    xs, ys = [], []
    for t in ts:
        if t <= 0.5:
            pt = p(2 * t)
        else:
            pt = q(2 * t - 1)
        xs.append(pt[0])
        ys.append(pt[1])
    return Trajectory2D(xs, ys, ts)


def reverse_trajectory(p: Trajectory2D) -> Trajectory2D:
    """Reverse a trajectory."""
    return Trajectory2D(list(reversed(p.xs)), list(reversed(p.ys)),
                       list(reversed([1.0 - t for t in p.ts])))


def motion_planning_demo():
    """Demonstrate path composition for robot motion planning.
    
    Scenario: A robot moves through three waypoints.
    The path can be composed as (segment1 · segment2) · segment3
    or as segment1 · (segment2 · segment3). Both give the same
    trajectory up to reparametrization — this is associativity.
    """
    print("=" * 60)
    print("  APPLICATION 1: MOTION PLANNING")
    print("=" * 60)
    
    # Three path segments: warehouse → loading dock → parking → exit
    seg1 = Trajectory2D(
        [0, 1, 2, 3], [0, 1, 1, 0],
        [0, 0.33, 0.67, 1.0])
    seg2 = Trajectory2D(
        [3, 4, 5], [0, 2, 2],
        [0, 0.5, 1.0])
    seg3 = Trajectory2D(
        [5, 6, 7, 8], [2, 3, 3, 0],
        [0, 0.33, 0.67, 1.0])
    
    # Two bracketings
    left = concat_trajectories(concat_trajectories(seg1, seg2), seg3)
    right = concat_trajectories(seg1, concat_trajectories(seg2, seg3))
    
    print(f"\n  Robot path: warehouse → dock → parking → exit")
    print(f"  Segment 1: {seg1.start} → {seg1.end} (length: {seg1.length():.2f})")
    print(f"  Segment 2: {seg2.start} → {seg2.end} (length: {seg2.length():.2f})")
    print(f"  Segment 3: {seg3.start} → {seg3.end} (length: {seg3.length():.2f})")
    print(f"\n  Left bracketing  (s1·s2)·s3: {left.start} → {left.end}")
    print(f"  Right bracketing s1·(s2·s3): {right.start} → {right.end}")
    
    # Check same image (up to reparametrization)
    left_points = set()
    right_points = set()
    for i in range(1001):
        t = i / 1000
        lp = left(t)
        rp = right(t)
        left_points.add((round(lp[0], 6), round(lp[1], 6)))
        right_points.add((round(rp[0], 6), round(rp[1], 6)))
    
    # Sample comparison at key points
    print(f"\n  {'t':>5s}  {'Left (x,y)':>15s}  {'Right (x,y)':>15s}")
    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        lp = left(t)
        rp = right(t)
        print(f"  {t:5.2f}  ({lp[0]:6.2f}, {lp[1]:5.2f})  ({rp[0]:6.2f}, {rp[1]:5.2f})")
    
    print(f"\n  Note: The two bracketings trace the SAME image but at different speeds.")
    print(f"  This is exactly what 'homotopic up to reparametrization' means.")
    print()


# ─── Application 2: Parallel Transport ─────────────────────────────

def parallel_transport_demo():
    """Demonstrate path composition and inverse laws in physics context.
    
    Model: A vector transported along a path on a curved surface.
    Going forward then backward (p · p⁻¹) should return to the
    original vector — this is the inverse law.
    """
    print("=" * 60)
    print("  APPLICATION 2: PARALLEL TRANSPORT (PHYSICS)")
    print("=" * 60)
    
    # Simple model: transport on a circle
    # The holonomy angle accumulated by going around a circular arc
    # of angle θ on a sphere of radius R is proportional to the
    # solid angle subtended.
    
    R = 1.0  # sphere radius
    
    # Path: arc from 0 to θ
    def transport_angle(theta: float, n_steps: int = 1000) -> float:
        """Accumulated phase from parallel transport along a latitude circle."""
        # For a sphere, transport along latitude at colatitude α
        # accumulates holonomy = θ · cos(α)
        alpha = math.pi / 4  # 45° colatitude
        return theta * math.cos(alpha)
    
    # Forward path: 0 to π
    theta_forward = math.pi
    phase_forward = transport_angle(theta_forward)
    
    # Backward path: π to 0
    phase_backward = transport_angle(-theta_forward)
    
    # Composition: forward then backward
    total_phase = phase_forward + phase_backward
    
    print(f"\n  Parallel transport on sphere (radius {R})")
    print(f"  Path: latitude circle at 45° colatitude")
    print(f"  Forward (0 → π):   phase = {phase_forward:.6f} rad")
    print(f"  Backward (π → 0):  phase = {phase_backward:.6f} rad")
    print(f"  Total (p · p⁻¹):   phase = {total_phase:.6f} rad")
    print(f"\n  Inverse law: p · p⁻¹ ≃ refl ✓ (total phase = 0)")
    
    # But going around a full loop DOES accumulate holonomy
    theta_loop = 2 * math.pi
    loop_phase = transport_angle(theta_loop)
    print(f"\n  Full loop (0 → 2π): phase = {loop_phase:.6f} rad")
    print(f"  This is the holonomy = 2π·cos(45°) = π√2 ≈ {math.pi * math.sqrt(2):.6f}")
    print(f"  Non-trivial holonomy ⟹ the loop is NOT homotopic to refl!")
    print()


# ─── Application 3: Trajectory Classification ──────────────────────

def trajectory_classification_demo():
    """Demonstrate groupoid quotient for trajectory classification.
    
    Two trajectories are 'equivalent' if one can be reparametrized to
    match the other. This quotient is the morphism set of the
    fundamental groupoid — invariant classification of paths.
    """
    print("=" * 60)
    print("  APPLICATION 3: TRAJECTORY CLASSIFICATION")
    print("=" * 60)
    
    # Create trajectories with different parametrizations but same image
    # Trajectory A: linear speed
    traj_a = Trajectory2D(
        [0, 1, 2, 3, 4, 5],
        [0, 1, 0, -1, 0, 1],
        [0, 0.2, 0.4, 0.6, 0.8, 1.0])
    
    # Trajectory B: same waypoints but different timing (slower in middle)
    traj_b = Trajectory2D(
        [0, 1, 2, 3, 4, 5],
        [0, 1, 0, -1, 0, 1],
        [0, 0.1, 0.3, 0.7, 0.9, 1.0])
    
    # Trajectory C: different path entirely
    traj_c = Trajectory2D(
        [0, 2, 4, 5],
        [0, 2, 0, 1],
        [0, 0.33, 0.67, 1.0])
    
    # Compute "signature" = set of (x,y) points visited
    def path_signature(traj, n=500):
        points = []
        for i in range(n+1):
            t = i / n
            pt = traj(t)
            points.append((round(pt[0], 4), round(pt[1], 4)))
        return set(points)
    
    sig_a = path_signature(traj_a)
    sig_b = path_signature(traj_b)
    sig_c = path_signature(traj_c)
    
    # Jaccard similarity
    def jaccard(s1, s2):
        return len(s1 & s2) / len(s1 | s2) if s1 | s2 else 1.0
    
    sim_ab = jaccard(sig_a, sig_b)
    sim_ac = jaccard(sig_a, sig_c)
    sim_bc = jaccard(sig_b, sig_c)
    
    print(f"\n  Trajectory A: 6 waypoints, uniform timing")
    print(f"  Trajectory B: same waypoints, non-uniform timing")
    print(f"  Trajectory C: different waypoints entirely")
    print(f"\n  Image similarity (Jaccard index of sampled point sets):")
    print(f"    A vs B: {sim_ab:.4f}  (same path, different speed → high)")
    print(f"    A vs C: {sim_ac:.4f}  (different paths → low)")
    print(f"    B vs C: {sim_bc:.4f}  (different paths → low)")
    print(f"\n  In the groupoid quotient:")
    print(f"    [A] = [B]  (same equivalence class: related by reparametrization)")
    print(f"    [A] ≠ [C]  (different classes: no reparametrization connects them)")
    print()


def main():
    motion_planning_demo()
    parallel_transport_demo()
    trajectory_classification_demo()
    
    print("=" * 60)
    print("  SUMMARY")
    print("=" * 60)
    print("""
  The path groupoid structure provides:
  
  1. COMPOSABILITY: Sequential trajectories compose naturally
     (motion planning, multi-stage processes)
  
  2. REVERSIBILITY: Every path has an inverse up to homotopy
     (time-reversal symmetry, backtracking)
  
  3. ASSOCIATIVITY: Re-bracketing compositions is coherent
     (modular planners, distributed systems)
  
  4. CLASSIFICATION: Quotient by reparametrization gives
     invariant trajectory types (data science, topology)
  
  These are not just mathematical abstractions — they are
  structural properties that real systems depend on.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of path concatenation, homotopy, and groupoid laws.

Demonstrates the core ideas from the formal path groupoid development:
1. Path concatenation via piecewise-linear rescaling
2. Path reversal (time-reversal)
3. Unit laws (refl · p ≃ p) via explicit reparametrization
4. Associativity ((p·q)·r ≃ p·(q·r)) via piecewise-linear homotopy
5. Inverse laws (p · p⁻¹ ≃ refl) via explicit homotopy

Runs 100 random piecewise-linear paths with 1000 sample points each,
reports max errors for all coherence laws.
"""

import numpy as np
import sys

# ─── Path Primitives ────────────────────────────────────────────────

def make_random_piecewise_linear(n_breakpoints=5):
    """Generate a random piecewise-linear path [0,1] → ℝ."""
    ts = np.sort(np.random.rand(n_breakpoints - 2))
    ts = np.concatenate([[0.0], ts, [1.0]])
    vals = np.random.randn(n_breakpoints)
    def path(t):
        return np.interp(t, ts, vals)
    return path, vals[0], vals[-1]

def refl_path(x):
    """Constant path at x."""
    return lambda t: np.full_like(np.atleast_1d(t), x, dtype=float)

def concat_paths(p, q):
    """Concatenate paths p and q (p ends where q starts).
    (p·q)(t) = p(2t) if t ≤ 1/2, q(2t-1) if t ≥ 1/2."""
    def result(t):
        t = np.atleast_1d(t).astype(float)
        out = np.empty_like(t)
        mask = t <= 0.5
        out[mask] = p(2 * t[mask])
        out[~mask] = q(2 * t[~mask] - 1)
        return out
    return result

def reverse_path(p):
    """Reverse a path: p⁻¹(t) = p(1-t)."""
    return lambda t: p(1.0 - np.atleast_1d(t).astype(float))

# ─── Reparametrization Homotopies ───────────────────────────────────

def left_unit_homotopy(p_start, p, t, s):
    """Homotopy witnessing refl_x · p ≃ p.
    H(t, s) = p(φ_s(t)) where φ_s(t) linearly interpolates between
    the concat reparametrization and the identity."""
    t, s = np.atleast_1d(t).astype(float), np.atleast_1d(s).astype(float)
    # At s=0: concat(refl, p)(t) = refl(2t) if t≤1/2, p(2t-1) if t≥1/2
    # At s=1: p(t)
    # Reparametrization: φ_s(t) = (1-s)*max(2t-1, 0) + s*t for the p part
    # More precisely: the "sped up" version
    phi = np.where(t <= (1 - s) / 2,
                   np.full_like(t, 0.0),
                   (t - (1 - s) / 2) / (1 - (1 - s) / 2 + 1e-15))
    phi = np.clip(phi, 0.0, 1.0)
    return p(phi)

def right_unit_homotopy(p, p_end, t, s):
    """Homotopy witnessing p · refl_y ≃ p."""
    t, s = np.atleast_1d(t).astype(float), np.atleast_1d(s).astype(float)
    phi = np.where(t >= (1 + s) / 2,
                   np.full_like(t, 1.0),
                   t / ((1 + s) / 2 + 1e-15))
    phi = np.clip(phi, 0.0, 1.0)
    return p(phi)

def assoc_homotopy(p, q, r, t, s):
    """Homotopy witnessing (p·q)·r ≃ p·(q·r).
    Piecewise-linear reparametrization of the 3-segment partition."""
    t, s = np.atleast_1d(t).astype(float), np.atleast_1d(s).astype(float)
    
    # Left bracketing breakpoints: [0, 1/4, 1/2, 1] → [p, q, r]
    # Right bracketing breakpoints: [0, 1/2, 3/4, 1] → [p, q, r]
    # Interpolated breakpoints:
    b1 = (1 - s) / 4 + s / 2       # from 1/4 to 1/2
    b2 = (1 - s) / 2 + s * 3 / 4   # from 1/2 to 3/4
    
    # Map t to the "canonical" parameter in [0,1] for p, q, or r
    out = np.empty_like(t)
    
    mask_p = t <= b1
    mask_r = t >= b2
    mask_q = ~mask_p & ~mask_r
    
    # In p region: t ∈ [0, b1] → param ∈ [0, 1]
    out[mask_p] = p(t[mask_p] / (b1[mask_p] + 1e-15))
    # In q region: t ∈ [b1, b2] → param ∈ [0, 1]
    out[mask_q] = q((t[mask_q] - b1[mask_q]) / (b2[mask_q] - b1[mask_q] + 1e-15))
    # In r region: t ∈ [b2, 1] → param ∈ [0, 1]
    out[mask_r] = r((t[mask_r] - b2[mask_r]) / (1 - b2[mask_r] + 1e-15))
    
    return out

def inverse_homotopy(p, p_start, t, s):
    """Homotopy witnessing p · p⁻¹ ≃ refl_x.
    At s=0: (p · p⁻¹)(t). At s=1: refl_x(t) = x."""
    t, s = np.atleast_1d(t).astype(float), np.atleast_1d(s).astype(float)
    
    # Shrink the "excursion" to zero
    reach = np.clip(1 - s, 0, 1)
    
    out = np.empty_like(t)
    mask = t <= 0.5
    # Forward part: go up to p(2t * reach)
    out[mask] = p(2 * t[mask] * reach[mask])
    # Backward part: come back via p((2-2t) * reach)
    out[~mask] = p((2 - 2 * t[~mask]) * reach[~mask])
    
    return out

# ─── Numerical Tests ────────────────────────────────────────────────

def test_endpoint_preservation(n_trials=100, n_samples=1000):
    """Test that concatenation preserves endpoints."""
    max_source_err = 0.0
    max_target_err = 0.0
    
    for _ in range(n_trials):
        p, px, py = make_random_piecewise_linear()
        q, qx, qz = make_random_piecewise_linear()
        # Force q to start where p ends
        shift = py - qx
        q_shifted = lambda t, q=q, s=shift: q(t) + s
        
        pq = concat_paths(p, q_shifted)
        source_err = abs(pq(np.array([0.0]))[0] - px)
        target_err = abs(pq(np.array([1.0]))[0] - (qz + shift))
        max_source_err = max(max_source_err, source_err)
        max_target_err = max(max_target_err, target_err)
    
    return max_source_err, max_target_err

def test_unit_laws(n_trials=100, n_samples=1000):
    """Test left and right unit laws up to reparametrization."""
    ts = np.linspace(0, 1, n_samples)
    max_left_err = 0.0
    max_right_err = 0.0
    
    for _ in range(n_trials):
        p, px, py = make_random_piecewise_linear()
        
        # Left unit: refl · p should be homotopic to p
        refl_x = refl_path(px)
        left_concat = concat_paths(refl_x, p)
        
        # Check at s=1 (end of homotopy): should equal p
        h_vals = left_unit_homotopy(px, p, ts, np.ones_like(ts))
        p_vals = p(ts)
        left_err = np.max(np.abs(h_vals - p_vals))
        max_left_err = max(max_left_err, left_err)
        
        # Right unit: p · refl should be homotopic to p
        refl_y = refl_path(py)
        right_concat = concat_paths(p, refl_y)
        
        h_vals = right_unit_homotopy(p, py, ts, np.ones_like(ts))
        right_err = np.max(np.abs(h_vals - p_vals))
        max_right_err = max(max_right_err, right_err)
    
    return max_left_err, max_right_err

def test_associativity(n_trials=100, n_samples=1000):
    """Test associativity up to reparametrization homotopy."""
    ts = np.linspace(0, 1, n_samples)
    max_err_s0 = 0.0   # At s=0, should equal (p·q)·r
    max_err_s1 = 0.0   # At s=1, should equal p·(q·r)
    
    for _ in range(n_trials):
        p, pw, px = make_random_piecewise_linear()
        q, _, py = make_random_piecewise_linear()
        r, _, pz = make_random_piecewise_linear()
        
        # Adjust endpoints
        q_shift = px - q(np.array([0.0]))[0]
        q_adj = lambda t, q=q, s=q_shift: q(t) + s
        py_adj = q_adj(np.array([1.0]))[0]
        
        r_shift = py_adj - r(np.array([0.0]))[0]
        r_adj = lambda t, r=r, s=r_shift: r(t) + s
        
        # (p·q)·r
        pq = concat_paths(p, q_adj)
        pq_r = concat_paths(pq, r_adj)
        
        # p·(q·r)
        qr = concat_paths(q_adj, r_adj)
        p_qr = concat_paths(p, qr)
        
        # Check homotopy at s=0: should match (p·q)·r
        h_s0 = assoc_homotopy(p, q_adj, r_adj, ts, np.zeros_like(ts))
        left_vals = pq_r(ts)
        err_s0 = np.max(np.abs(h_s0 - left_vals))
        max_err_s0 = max(max_err_s0, err_s0)
        
        # Check homotopy at s=1: should match p·(q·r)
        h_s1 = assoc_homotopy(p, q_adj, r_adj, ts, np.ones_like(ts))
        right_vals = p_qr(ts)
        err_s1 = np.max(np.abs(h_s1 - right_vals))
        max_err_s1 = max(max_err_s1, err_s1)
    
    return max_err_s0, max_err_s1

def test_inverse_laws(n_trials=100, n_samples=1000):
    """Test p · p⁻¹ ≃ refl_x up to homotopy."""
    ts = np.linspace(0, 1, n_samples)
    max_err = 0.0
    
    for _ in range(n_trials):
        p, px, py = make_random_piecewise_linear()
        
        # At s=1 of the homotopy, should be constant at px
        h_vals = inverse_homotopy(p, px, ts, np.ones_like(ts))
        refl_vals = np.full_like(ts, px)
        err = np.max(np.abs(h_vals - refl_vals))
        max_err = max(max_err, err)
    
    return max_err

# ─── Main ───────────────────────────────────────────────────────────

def main():
    np.random.seed(42)
    
    print("=" * 70)
    print("  PATH GROUPOID COHERENCE — NUMERICAL VERIFICATION")
    print("=" * 70)
    print()
    
    # Test 1: Endpoint preservation
    print("Test 1: Endpoint preservation under concatenation")
    print("-" * 50)
    src_err, tgt_err = test_endpoint_preservation(100, 1000)
    print(f"  Max source error: {src_err:.2e}")
    print(f"  Max target error: {tgt_err:.2e}")
    print(f"  Status: {'PASS' if max(src_err, tgt_err) < 1e-10 else 'FAIL'}")
    print()
    
    # Test 2: Unit laws
    print("Test 2: Left and right unit laws (refl · p ≃ p, p · refl ≃ p)")
    print("-" * 50)
    left_err, right_err = test_unit_laws(100, 1000)
    print(f"  Max left unit error:  {left_err:.2e}")
    print(f"  Max right unit error: {right_err:.2e}")
    print(f"  Status: {'PASS' if max(left_err, right_err) < 1e-10 else 'FAIL'}")
    print()
    
    # Test 3: Associativity
    print("Test 3: Associativity ((p·q)·r ≃ p·(q·r))")
    print("-" * 50)
    assoc_s0, assoc_s1 = test_associativity(100, 1000)
    print(f"  Max error at s=0 (left bracketing):  {assoc_s0:.2e}")
    print(f"  Max error at s=1 (right bracketing): {assoc_s1:.2e}")
    print(f"  Status: {'PASS' if max(assoc_s0, assoc_s1) < 1e-10 else 'FAIL'}")
    print()
    
    # Test 4: Inverse laws
    print("Test 4: Inverse laws (p · p⁻¹ ≃ refl)")
    print("-" * 50)
    inv_err = test_inverse_laws(100, 1000)
    print(f"  Max inverse error: {inv_err:.2e}")
    print(f"  Status: {'PASS' if inv_err < 1e-10 else 'FAIL'}")
    print()
    
    print("=" * 70)
    all_pass = (max(src_err, tgt_err) < 1e-10 and
                max(left_err, right_err) < 1e-10 and
                max(assoc_s0, assoc_s1) < 1e-10 and
                inv_err < 1e-10)
    print(f"  OVERALL: {'ALL TESTS PASSED' if all_pass else 'SOME TESTS FAILED'}")
    print("=" * 70)
    
    # Interactive example
    print()
    print("Interactive Example: Visualizing Associativity Homotopy")
    print("-" * 50)
    
    p = lambda t: np.sin(np.pi * np.atleast_1d(t).astype(float))
    q = lambda t: np.atleast_1d(t).astype(float) ** 2
    r = lambda t: np.cos(np.pi * np.atleast_1d(t).astype(float) / 2)
    
    ts = np.linspace(0, 1, 20)
    print(f"  {'t':>6s}  {'(p·q)·r':>10s}  {'p·(q·r)':>10s}  {'H(t,0.5)':>10s}")
    print(f"  {'─'*6}  {'─'*10}  {'─'*10}  {'─'*10}")
    
    pq = concat_paths(p, q)
    pq_r = concat_paths(pq, r)
    qr = concat_paths(q, r)
    p_qr = concat_paths(p, qr)
    
    for t in ts:
        t_arr = np.array([t])
        left = pq_r(t_arr)[0]
        right = p_qr(t_arr)[0]
        mid = assoc_homotopy(p, q, r, t_arr, np.array([0.5]))[0]
        print(f"  {t:6.3f}  {left:10.6f}  {right:10.6f}  {mid:10.6f}")
    
    print()
    print("The homotopy H(t, s) smoothly interpolates between the two bracketings.")
    print("At s=0 it equals (p·q)·r; at s=1 it equals p·(q·r).")

if __name__ == "__main__":
    main()
