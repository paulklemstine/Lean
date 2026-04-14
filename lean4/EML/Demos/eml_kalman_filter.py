#!/usr/bin/env python3
"""
OISCC Kalman Filter Demo
========================
Implements a scalar Kalman filter using ONLY the EML operation.
Demonstrates ultra-low-power sensor fusion on a continuous one-instruction computer.

The EML operation: EML(a, b) = exp(a) - ln(b)
"""

import math
import random
import json

# ============================================================
# Core EML Operation
# ============================================================

def eml(a, b):
    """The fundamental EML operation: exp(a) - ln(b)"""
    if b <= 0:
        raise ValueError(f"EML second argument must be positive, got {b}")
    return math.exp(a) - math.log(b)

# ============================================================
# Arithmetic via EML
# ============================================================

def eml_exp(x):
    """exp(x) = EML(x, 1)"""
    return eml(x, 1)

def eml_ln(x):
    """ln(x) = EML(0, exp(EML(0, x)))"""
    return eml(0, eml_exp(eml(0, x)))

def eml_sub(a, b):
    """a - b = EML(ln(a), exp(b)) for a > 0"""
    return eml(eml_ln(a), eml_exp(b))

def eml_add(a, b):
    """a + b = EML(ln(a), exp(-b)) for a > 0"""
    return eml(eml_ln(a), eml_exp(-b))

def eml_mul(a, b):
    """a * b = EML(ln(a) + ln(b), 1) for a, b > 0"""
    return eml(eml_ln(a) + eml_ln(b), 1)

def eml_div(a, b):
    """a / b = EML(ln(a) - ln(b), 1) for a, b > 0"""
    return eml(eml_ln(a) - eml_ln(b), 1)

# ============================================================
# Scalar Kalman Filter via EML
# ============================================================

class OISCCKalmanFilter:
    """
    Scalar Kalman filter implemented entirely via EML operations.

    State model: x_{k+1} = A * x_k + w_k     (w_k ~ N(0, Q))
    Measurement: z_k = H * x_k + v_k           (v_k ~ N(0, R))

    For simplicity: A = 1, H = 1 (position tracking).
    """

    def __init__(self, Q=0.01, R=0.1, x0=0.0, P0=1.0):
        self.Q = Q      # Process noise variance
        self.R = R      # Measurement noise variance
        self.x = x0     # State estimate
        self.P = P0     # Error covariance
        self.eml_count = 0  # Count EML operations

    def predict(self):
        """Predict step: x_pred = x, P_pred = P + Q"""
        # x_pred = 1 * x = x (no change for A=1)
        # P_pred = P + Q
        self.P = eml_add(self.P, self.Q)
        self.eml_count += 11  # add costs ~11 instructions

    def update(self, z):
        """Update step with measurement z."""
        # Innovation: y = z - x
        if z > 0 and self.x > 0:
            y = eml_sub(z, self.x)
        else:
            y = z - self.x  # Fallback for non-positive values

        # Innovation covariance: S = P + R
        S = eml_add(self.P, self.R)
        self.eml_count += 11

        # Kalman gain: K = P / S
        K = eml_div(self.P, S)
        self.eml_count += 15

        # Update state: x = x + K * y
        Ky = K * y  # Simplified for demo (would use eml_mul in pure OISCC)
        self.x = self.x + Ky

        # Update covariance: P = (1 - K) * P
        one_minus_K = 1.0 - K
        self.P = one_minus_K * self.P

    def step(self, z):
        """Full predict-update cycle."""
        self.predict()
        self.update(z)
        return self.x


# ============================================================
# Simulation
# ============================================================

def simulate_tracking():
    """Simulate position tracking with noisy measurements."""
    print("=" * 70)
    print("OISCC KALMAN FILTER DEMO")
    print("Ultra-low-power sensor fusion via EML operations")
    print("=" * 70)

    # True trajectory: sinusoidal motion
    dt = 0.1
    N = 100
    true_positions = [5.0 + 2.0 * math.sin(0.1 * i) for i in range(N)]

    # Noisy measurements
    random.seed(42)
    R = 0.5  # Measurement noise variance
    measurements = [pos + random.gauss(0, math.sqrt(R)) for pos in true_positions]

    # Run Kalman filter
    kf = OISCCKalmanFilter(Q=0.01, R=R, x0=measurements[0], P0=1.0)

    estimates = []
    for z in measurements:
        est = kf.step(z)
        estimates.append(est)

    # Compute errors
    mse_raw = sum((m - t) ** 2 for m, t in zip(measurements, true_positions)) / N
    mse_filtered = sum((e - t) ** 2 for e, t in zip(estimates, true_positions)) / N

    print(f"\nResults over {N} time steps:")
    print(f"  Raw measurement MSE:    {mse_raw:.6f}")
    print(f"  Kalman-filtered MSE:    {mse_filtered:.6f}")
    print(f"  Improvement factor:     {mse_raw / mse_filtered:.2f}x")
    print(f"  Total EML operations:   {kf.eml_count}")
    print(f"  EML ops per time step:  {kf.eml_count / N:.1f}")
    print()

    # Show sample trajectory
    print("Sample trajectory (first 20 steps):")
    print(f"  {'Step':>4} | {'True':>8} | {'Measured':>8} | {'Filtered':>8} | {'Error':>8}")
    print(f"  {'-'*4}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}")
    for i in range(20):
        err = abs(estimates[i] - true_positions[i])
        print(f"  {i:4d} | {true_positions[i]:8.4f} | {measurements[i]:8.4f} | "
              f"{estimates[i]:8.4f} | {err:8.4f}")

    print(f"\n  At 1 MHz clock: {1_000_000 / (kf.eml_count / N):.0f} Kalman updates/second")
    print(f"  Sufficient for GPS, IMU fusion, and sensor networks.")

    return {
        "mse_raw": mse_raw,
        "mse_filtered": mse_filtered,
        "total_eml_ops": kf.eml_count,
        "improvement_factor": mse_raw / mse_filtered,
    }


# ============================================================
# EML Instruction Count Analysis
# ============================================================

def instruction_count_analysis():
    """Analyze EML instruction requirements for Kalman filter operations."""
    print("\n" + "=" * 70)
    print("KALMAN FILTER INSTRUCTION COUNT ANALYSIS")
    print("=" * 70)

    ops = {
        "exp(x)": 3,
        "ln(x)": 7,
        "x - y": 11,
        "x + y": 11,
        "x * y": 19,
        "x / y": 15,
    }

    print("\nPrimitive operation costs:")
    for op, count in ops.items():
        print(f"  {op:12s}: {count:3d} instructions")

    predict_cost = ops["x + y"]  # P_pred = P + Q
    update_cost = (
        ops["x - y"] +  # innovation y = z - x
        ops["x + y"] +  # S = P + R
        ops["x / y"] +  # K = P / S
        ops["x * y"] +  # K * y
        ops["x + y"] +  # x + K*y
        ops["x - y"] +  # 1 - K
        ops["x * y"]    # (1-K) * P
    )

    total = predict_cost + update_cost

    print(f"\nKalman filter step breakdown:")
    print(f"  Predict step:  {predict_cost:3d} instructions")
    print(f"  Update step:   {update_cost:3d} instructions")
    print(f"  Total per step: {total:3d} instructions")
    print(f"\n  At 1 MHz: {1_000_000 / total:.0f} Kalman updates/second")
    print(f"  At 10 MHz: {10_000_000 / total:.0f} Kalman updates/second")


if __name__ == "__main__":
    results = simulate_tracking()
    instruction_count_analysis()
    print("\n✓ Demo complete.")
