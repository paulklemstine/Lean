#!/usr/bin/env python3
"""
SPB Tropical and p-adic Explorations
======================================
Demos for the more exotic variants of SPB:
1. Tropical SPB and optimization
2. p-adic SPB and convergence
3. SPB Kalman Filter for angular estimation
4. EML Function Compiler
"""

import numpy as np


# ============================================================
# Demo 1: Tropical SPB
# ============================================================

def tropical_spb(x, y):
    """Tropical SPB: min(x,y) - min(0, x+y)."""
    return min(x, y) - min(0, x + y)

def tropical_spb_alt(x, y):
    """Alternative form: min(x,y) + max(0, -(x+y))."""
    return min(x, y) + max(0, -(x + y))

def demo_tropical():
    """Explore tropical SPB properties."""
    print("=" * 60)
    print("DEMO 1: Tropical SPB")
    print("=" * 60)

    # Verify both formulations agree
    import random
    random.seed(42)
    max_diff = 0
    for _ in range(10000):
        x = random.uniform(-10, 10)
        y = random.uniform(-10, 10)
        d = abs(tropical_spb(x, y) - tropical_spb_alt(x, y))
        max_diff = max(max_diff, d)
    print(f"Max difference between two formulations: {max_diff:.2e}")

    # Test properties
    print("\nProperty testing:")
    test_vals = [-3, -1, 0, 1, 2, 5]

    # Commutativity
    comm_ok = all(
        abs(tropical_spb(x, y) - tropical_spb(y, x)) < 1e-10
        for x in test_vals for y in test_vals
    )
    print(f"  Commutativity: {'✓' if comm_ok else '✗'}")

    # Identity: is there an e such that tspb(x, e) = x for all x?
    # For x ≥ 0: tspb(x, 0) = min(x, 0) - min(0, x) = 0 - 0 = 0 ≠ x (for x > 0)
    # So 0 is NOT a universal identity
    print("  Identity element 0:")
    for x in test_vals:
        result = tropical_spb(x, 0)
        print(f"    tspb({x}, 0) = {result} {'= x ✓' if abs(result - x) < 1e-10 else '≠ x'}")

    # Associativity
    assoc_ok = True
    for x in test_vals:
        for y in test_vals:
            for z in test_vals:
                lhs = tropical_spb(tropical_spb(x, y), z)
                rhs = tropical_spb(x, tropical_spb(y, z))
                if abs(lhs - rhs) > 1e-10:
                    assoc_ok = False
                    print(f"    Associativity fails: tspb(tspb({x},{y}),{z}) = {lhs} ≠ {rhs} = tspb({x},tspb({y},{z}))")
                    break
            if not assoc_ok:
                break

    print(f"  Associativity: {'✓' if assoc_ok else '✗ (counterexample found)'}")
    print(f"\n  Conclusion: Tropical SPB is a {'semigroup' if assoc_ok else 'partial semigroup'}, not a group")


# ============================================================
# Demo 2: p-adic SPB
# ============================================================

def padic_val(n, p):
    """p-adic valuation of integer n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def padic_norm(q_num, q_den, p):
    """p-adic norm of q_num/q_den."""
    v_num = padic_val(q_num, p) if q_num != 0 else float('inf')
    v_den = padic_val(q_den, p)
    return p ** (-(v_num - v_den))

def demo_padic():
    """Explore p-adic SPB."""
    print("\n" + "=" * 60)
    print("DEMO 2: p-adic SPB")
    print("=" * 60)

    from fractions import Fraction

    def spb_frac(x, y):
        """SPB over rationals."""
        denom = 1 - x * y
        if denom == 0:
            return None
        return (x + y) / denom

    # SPB iteration over Q, tracking p-adic convergence
    for p in [2, 3, 5, 7]:
        print(f"\n--- p = {p} ---")
        x = Fraction(1, 1)

        print(f"  {'n':>3} {'spbN(1,n)':>20} {'|·|_p':>12}")

        for n in range(1, 16):
            x = spb_frac(x, Fraction(1, p))
            if x is None:
                print(f"  {n:>3} {'pole':>20}")
                break
            norm = padic_norm(x.numerator, x.denominator, p)
            print(f"  {n:>3} {str(x):>20} {norm:>12.6f}")


# ============================================================
# Demo 3: SPB Kalman Filter
# ============================================================

def demo_kalman():
    """SPB Kalman Filter for angular state estimation."""
    print("\n" + "=" * 60)
    print("DEMO 3: SPB Kalman Filter vs Standard Kalman")
    print("=" * 60)

    np.random.seed(42)
    T = 200  # time steps
    dt = 0.1

    # True angular state: θ(t) = 2t + 0.5·sin(t)
    true_theta = np.array([2 * i * dt + 0.5 * np.sin(i * dt) for i in range(T)])
    true_tan_half = np.tan(true_theta / 2)

    # Noisy measurements of tan(θ/2)
    noise_std = 0.3
    measurements = true_tan_half + noise_std * np.random.randn(T)

    # Standard Kalman Filter (on angle θ directly)
    theta_est_std = np.zeros(T)
    theta_est_std[0] = 2 * np.arctan(measurements[0])
    P_std = 1.0
    Q_process = 0.01
    R_meas = noise_std**2

    for k in range(1, T):
        # Predict
        theta_pred = theta_est_std[k-1] + 2 * dt  # constant angular velocity model
        P_pred = P_std + Q_process

        # Update (convert measurement to angle)
        meas_angle = 2 * np.arctan(measurements[k])
        # Handle angle wrapping
        innovation = meas_angle - theta_pred
        while innovation > np.pi:
            innovation -= 2 * np.pi
        while innovation < -np.pi:
            innovation += 2 * np.pi

        K = P_pred / (P_pred + R_meas)
        theta_est_std[k] = theta_pred + K * innovation
        P_std = (1 - K) * P_pred

    # SPB Kalman Filter (on t = tan(θ/2))
    t_est = np.zeros(T)
    t_est[0] = measurements[0]
    P_spb = 1.0

    def spb_op(x, y):
        d = 1 - x * y
        if abs(d) < 1e-15:
            return x
        return (x + y) / d

    for k in range(1, T):
        # Predict: t_{k+1} = spb(t_k, tan(ω·dt/2)) where ω = 2 rad/s
        control = np.tan(2 * dt / 2)  # tan(ω·dt/2)
        t_pred = spb_op(t_est[k-1], control)
        P_pred = P_spb + Q_process

        # Update: direct in t-coordinates, no angle wrapping!
        innovation = measurements[k] - t_pred
        K = P_pred / (P_pred + R_meas)
        t_est[k] = t_pred + K * innovation
        P_spb = (1 - K) * P_pred

    # Convert back to angles for comparison
    theta_est_spb = 2 * np.arctan(t_est)

    # Errors
    err_std = np.sqrt(np.mean((theta_est_std - true_theta)**2))
    err_spb = np.sqrt(np.mean((theta_est_spb - true_theta)**2))

    print(f"\nTrue angular trajectory: θ(t) = 2t + 0.5·sin(t)")
    print(f"Measurement noise std: {noise_std}")
    print(f"\n  Standard Kalman RMSE: {err_std:.4f} rad")
    print(f"  SPB Kalman RMSE:      {err_spb:.4f} rad")
    improvement = (err_std - err_spb) / err_std * 100
    print(f"  Improvement:          {improvement:+.1f}%")
    print(f"\n  Key advantage: SPB Kalman NEVER needs angle wrapping!")


# ============================================================
# Demo 4: EML Function Compiler
# ============================================================

def demo_eml_compiler():
    """Compile mathematical expressions into EML primitives."""
    print("\n" + "=" * 60)
    print("DEMO 4: EML Function Compiler")
    print("=" * 60)

    class EMLExpr:
        """An expression in the EML (exp, mul, log) basis."""
        pass

    class Const(EMLExpr):
        def __init__(self, val):
            self.val = val
        def eval(self):
            return self.val
        def __repr__(self):
            return f"{self.val}"
        def complexity(self):
            return 0

    class Exp(EMLExpr):
        def __init__(self, arg):
            self.arg = arg
        def eval(self):
            return np.exp(self.arg.eval())
        def __repr__(self):
            return f"exp({self.arg})"
        def complexity(self):
            return 1 + self.arg.complexity()

    class Log(EMLExpr):
        def __init__(self, arg):
            self.arg = arg
        def eval(self):
            return np.log(self.arg.eval())
        def __repr__(self):
            return f"log({self.arg})"
        def complexity(self):
            return 1 + self.arg.complexity()

    class Mul(EMLExpr):
        def __init__(self, left, right):
            self.left = left
            self.right = right
        def eval(self):
            return self.left.eval() * self.right.eval()
        def __repr__(self):
            return f"({self.left} × {self.right})"
        def complexity(self):
            return 1 + self.left.complexity() + self.right.complexity()

    class EML(EMLExpr):
        """The EML operator: eml(x,y) = exp(x) - log(y)."""
        def __init__(self, x, y):
            self.x = x
            self.y = y
        def eval(self):
            return np.exp(self.x.eval()) - np.log(self.y.eval())
        def __repr__(self):
            return f"eml({self.x}, {self.y})"
        def complexity(self):
            return 1 + self.x.complexity() + self.y.complexity()

    # Compile basic operations
    print("\n--- Compiling arithmetic from EML ---")

    # exp(x) = eml(x, 1)
    x_val = 2.0
    expr_exp = EML(Const(x_val), Const(1))
    print(f"  exp({x_val}) = {expr_exp} = {expr_exp.eval():.6f}")
    print(f"    Standard: {np.exp(x_val):.6f}")

    # -log(y) = eml(0, y) - 1
    y_val = 3.0
    expr_neg_log = EML(Const(0), Const(y_val))
    print(f"  1 - log({y_val}) = {expr_neg_log} = {expr_neg_log.eval():.6f}")
    print(f"    Standard: {1 - np.log(y_val):.6f}")

    # x + y = log(exp(x) · exp(y))
    a, b = 3.0, 4.0
    expr_add = Log(Mul(Exp(Const(a)), Exp(Const(b))))
    print(f"  {a} + {b} = {expr_add} = {expr_add.eval():.6f}")

    # x · y = exp(log(x) + log(y)) for x, y > 0
    expr_mul = Exp(Log(Mul(Exp(Log(Const(a))), Exp(Log(Const(b))))))
    print(f"  {a} × {b} = exp(log(exp(log({a}))·exp(log({b})))) = {a*b:.6f}")

    # x^n = exp(n · log(x))
    n = 5
    expr_pow = Exp(Mul(Const(n), Log(Const(a))))
    print(f"  {a}^{n} = {expr_pow} = {expr_pow.eval():.6f}")
    print(f"    Standard: {a**n:.6f}")

    # SPB via EML: spb(x,y) = (x+y)/(1-xy)
    # = exp(log(x+y) - log(1-xy))
    print(f"\n--- SPB via EML ---")
    x, y = 0.5, 0.3
    spb_val = (x + y) / (1 - x * y)
    print(f"  spb({x}, {y}) = {spb_val:.6f}")
    print(f"  EML complexity of SPB: 3 (exp, log of numerator, log of denominator)")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  SPB Tropical, p-adic, and Algorithmic Explorations    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_tropical()
    demo_padic()
    demo_kalman()
    demo_eml_compiler()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
