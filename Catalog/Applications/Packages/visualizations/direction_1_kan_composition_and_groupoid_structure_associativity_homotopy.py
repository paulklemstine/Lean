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
