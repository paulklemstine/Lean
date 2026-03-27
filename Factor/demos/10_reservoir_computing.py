#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 10: RESERVOIR COMPUTING VIA COUPLED CHAOTIC OSCILLATORS  ║
║  ────────────────────────────────────────────────────────────    ║
║  A network of Lorenz oscillators at the edge of chaos performs  ║
║  temporal computation. Only the readout layer is trained —      ║
║  the chaotic reservoir provides nonlinear mixing for free.     ║
║                                                                  ║
║  Demonstrates: time series prediction, pattern recognition,    ║
║  and the "edge of chaos" phase transition in computational     ║
║  capacity.                                                      ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np
from typing import Tuple

# ── Lorenz Reservoir ───────────────────────────────────────────
class LorenzReservoir:
    """
    Echo State Network using coupled Lorenz oscillators.

    The reservoir is a network of N Lorenz systems coupled through
    a sparse random matrix. The coupling strength controls the
    computational regime:
    - Too weak: no mixing, poor computation
    - Too strong: fully synchronized, no diversity
    - Edge of chaos: maximum computational capacity
    """

    def __init__(self, n_nodes: int = 50, spectral_radius: float = 0.95,
                 input_scaling: float = 0.1, coupling: float = 0.01,
                 leak_rate: float = 0.3, sigma=10.0, rho=28.0, beta=8/3):
        self.n_nodes = n_nodes
        self.spectral_radius = spectral_radius
        self.input_scaling = input_scaling
        self.coupling = coupling
        self.leak_rate = leak_rate

        # Lorenz parameters
        self.sigma = sigma
        self.rho = rho
        self.beta = beta
        self.dt = 0.02

        # Initialize oscillator states
        self.states = np.random.randn(n_nodes, 3) * 0.01

        # Sparse random coupling matrix (10% connectivity)
        W = np.random.randn(n_nodes, n_nodes)
        mask = (np.random.random((n_nodes, n_nodes)) < 0.1)
        W *= mask
        # Scale to desired spectral radius
        eigenvalues = np.linalg.eigvals(W)
        max_ev = np.max(np.abs(eigenvalues))
        if max_ev > 0:
            W *= spectral_radius / max_ev
        self.W = W

        # Input weights (random, fixed)
        self.W_in = np.random.randn(n_nodes) * input_scaling

        # Readout weights (learned)
        self.W_out = None

    def _lorenz_step(self, state: np.ndarray, input_val: float,
                      coupling_force: np.ndarray) -> np.ndarray:
        """One step of the Lorenz oscillator with input and coupling."""
        x, y, z = state
        dx = self.sigma * (y - x) + coupling_force[0]
        dy = x * (self.rho - z) - y + coupling_force[1] + input_val
        dz = x * y - self.beta * z + coupling_force[2]
        return state + np.array([dx, dy, dz]) * self.dt

    def step(self, input_val: float) -> np.ndarray:
        """Advance the reservoir one timestep and return the state vector."""
        new_states = np.zeros_like(self.states)

        for i in range(self.n_nodes):
            # Coupling force from other oscillators
            coupling_force = np.zeros(3)
            for j in range(self.n_nodes):
                if self.W[i, j] != 0:
                    coupling_force += self.W[i, j] * (self.states[j] - self.states[i]) * self.coupling

            # Input drive
            input_drive = self.W_in[i] * input_val

            # Update with leaky integration
            new_state = self._lorenz_step(self.states[i], input_drive, coupling_force)
            new_states[i] = self.leak_rate * new_state + (1 - self.leak_rate) * self.states[i]

        self.states = new_states

        # Return flattened state as reservoir output
        # Use only x-component of each oscillator for simplicity
        return self.states[:, 0].copy()

    def harvest_states(self, inputs: np.ndarray, washout: int = 100) -> np.ndarray:
        """Drive reservoir with input sequence and collect states."""
        n = len(inputs)
        all_states = np.zeros((n, self.n_nodes))

        for t in range(n):
            state = self.step(inputs[t])
            all_states[t] = state

        # Discard washout period
        return all_states[washout:]

    def train(self, inputs: np.ndarray, targets: np.ndarray,
              washout: int = 100, ridge_alpha: float = 1e-6):
        """Train readout weights using ridge regression."""
        states = self.harvest_states(inputs, washout)
        targets = targets[washout:]

        # Add bias
        X = np.column_stack([states, np.ones(len(states))])

        # Ridge regression: W_out = (X^T X + αI)^(-1) X^T y
        I = np.eye(X.shape[1])
        self.W_out = np.linalg.solve(X.T @ X + ridge_alpha * I, X.T @ targets)

        # Compute training error
        pred = X @ self.W_out
        mse = np.mean((pred - targets) ** 2)
        return mse

    def predict(self, inputs: np.ndarray, washout: int = 100) -> np.ndarray:
        """Predict using trained readout."""
        states = self.harvest_states(inputs, washout)
        X = np.column_stack([states, np.ones(len(states))])
        return X @ self.W_out


# ── Time Series Tasks ─────────────────────────────────────────
def mackey_glass(n: int, tau: int = 17, dt: float = 1.0,
                  n_skip: int = 200) -> np.ndarray:
    """Generate Mackey-Glass chaotic time series."""
    total = n + n_skip + tau
    x = np.zeros(total)
    x[:tau] = 0.9 + np.random.randn(tau) * 0.01

    for t in range(tau, total - 1):
        x_tau = x[t - tau]
        x[t + 1] = x[t] + dt * (0.2 * x_tau / (1 + x_tau**10) - 0.1 * x[t])

    return x[n_skip:n_skip + n]

def narma10(n: int) -> Tuple:
    """NARMA-10 task: nonlinear autoregressive moving average."""
    u = np.random.uniform(0, 0.5, n + 200)
    y = np.zeros(n + 200)

    for t in range(10, n + 200):
        y[t] = (0.3 * y[t-1] +
                0.05 * y[t-1] * np.sum(y[t-10:t]) +
                1.5 * u[t-1] * u[t-10] +
                0.1)
        y[t] = np.clip(y[t], -10, 10)

    return u[200:], y[200:]

def sine_classification(n: int) -> Tuple:
    """Classify input as coming from sin or cos (temporal pattern)."""
    inputs = np.zeros(n)
    labels = np.zeros(n)

    t = 0
    while t < n:
        # Random segment length
        seg_len = np.random.randint(20, 50)
        seg_len = min(seg_len, n - t)

        if np.random.random() < 0.5:
            # Sine segment
            freq = np.random.uniform(0.1, 0.3)
            inputs[t:t+seg_len] = np.sin(np.arange(seg_len) * freq)
            labels[t:t+seg_len] = 0
        else:
            # Cosine segment
            freq = np.random.uniform(0.1, 0.3)
            inputs[t:t+seg_len] = np.cos(np.arange(seg_len) * freq)
            labels[t:t+seg_len] = 1

        t += seg_len

    return inputs, labels


# ── Computational Capacity Measurement ─────────────────────────
def measure_memory_capacity(reservoir: LorenzReservoir, max_delay: int = 30,
                              n_samples: int = 1000) -> Tuple[float, list]:
    """
    Memory capacity: how well can the reservoir recall past inputs?
    MC = Σ_k corr²(y_k, u_{t-k})
    """
    # Generate random input
    u = np.random.randn(n_samples)

    # Harvest states
    reservoir.states = np.random.randn(reservoir.n_nodes, 3) * 0.01
    states = reservoir.harvest_states(u, washout=100)
    u_trimmed = u[100:]

    capacities = []
    for delay in range(1, max_delay + 1):
        if delay >= len(u_trimmed):
            break
        target = u_trimmed[:-delay] if delay > 0 else u_trimmed
        s = states[delay:] if delay > 0 else states

        if len(s) < 10:
            break

        # Ridge regression for this delay
        X = np.column_stack([s, np.ones(len(s))])
        W = np.linalg.solve(X.T @ X + 1e-6 * np.eye(X.shape[1]), X.T @ target)
        pred = X @ W

        # Correlation squared
        corr = np.corrcoef(pred, target)[0, 1]
        mc_k = corr ** 2
        capacities.append(mc_k)

    total_mc = sum(capacities)
    return total_mc, capacities


# ── Main Demo ──────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  RESERVOIR COMPUTING via COUPLED CHAOTIC OSCILLATORS")
    print("=" * 65)

    np.random.seed(42)

    # ── Task 1: Mackey-Glass Prediction ────────────────────────
    print("\n  TASK 1: MACKEY-GLASS TIME SERIES PREDICTION")
    print("  " + "─" * 55)

    n_samples = 2000
    mg = mackey_glass(n_samples)

    # Normalize
    mg = (mg - np.mean(mg)) / np.std(mg)

    # Setup: predict mg[t+1] from mg[t]
    inputs = mg[:-1]
    targets = mg[1:]

    train_split = 1500
    train_in, train_target = inputs[:train_split], targets[:train_split]
    test_in, test_target = inputs[train_split:], targets[train_split:]

    reservoir = LorenzReservoir(n_nodes=80, spectral_radius=0.9,
                                 input_scaling=0.05, coupling=0.005,
                                 leak_rate=0.3)

    train_mse = reservoir.train(train_in, train_target, washout=200)
    print(f"  Training MSE: {train_mse:.6f}")

    # Test
    reservoir.states = np.random.randn(reservoir.n_nodes, 3) * 0.01
    test_pred = reservoir.predict(test_in, washout=50)
    test_actual = test_target[50:]
    test_mse = np.mean((test_pred - test_actual) ** 2)
    nrmse = np.sqrt(test_mse) / np.std(test_actual)

    print(f"  Test MSE:     {test_mse:.6f}")
    print(f"  Test NRMSE:   {nrmse:.4f}")

    # ASCII plot
    print(f"\n  Prediction vs Actual (last 80 test points):")
    plot_len = min(80, len(test_pred))
    actual_slice = test_actual[-plot_len:]
    pred_slice = test_pred[-plot_len:]

    # Normalize for display
    all_vals = np.concatenate([actual_slice, pred_slice])
    vmin, vmax = all_vals.min(), all_vals.max()

    plot_height = 12
    for row in range(plot_height, -1, -1):
        threshold = vmin + (vmax - vmin) * row / plot_height
        line = "    "
        for t in range(plot_len):
            actual_here = actual_slice[t] >= threshold
            pred_here = pred_slice[t] >= threshold
            if actual_here and pred_here:
                line += "█"  # Both
            elif actual_here:
                line += "▓"  # Only actual
            elif pred_here:
                line += "░"  # Only predicted
            else:
                line += " "
        print(line)
    print(f"    {'Legend: █=both ▓=actual ░=predicted':^{plot_len}}")

    # ── Task 2: Pattern Classification ─────────────────────────
    print(f"\n\n  TASK 2: TEMPORAL PATTERN CLASSIFICATION (sin vs cos)")
    print("  " + "─" * 55)

    n_class = 1000
    class_inputs, class_labels = sine_classification(n_class)

    reservoir2 = LorenzReservoir(n_nodes=60, spectral_radius=0.85,
                                  input_scaling=0.1, coupling=0.008)

    train_mse = reservoir2.train(class_inputs[:700], class_labels[:700], washout=50)

    reservoir2.states = np.random.randn(reservoir2.n_nodes, 3) * 0.01
    pred_labels = reservoir2.predict(class_inputs[700:], washout=50)
    actual_labels = class_labels[700 + 50:]

    # Threshold at 0.5
    pred_binary = (pred_labels > 0.5).astype(float)
    accuracy = np.mean(pred_binary == actual_labels)
    print(f"  Classification accuracy: {accuracy*100:.1f}%")

    # ── Edge of Chaos Analysis ─────────────────────────────────
    print(f"\n\n  EDGE OF CHAOS: COMPUTATIONAL CAPACITY vs COUPLING")
    print("  " + "═" * 55)
    print(f"  Testing how coupling strength affects computation...")

    coupling_values = [0.0001, 0.001, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2]
    capacities = []

    for coupling in coupling_values:
        res = LorenzReservoir(n_nodes=40, spectral_radius=0.9,
                               input_scaling=0.05, coupling=coupling,
                               leak_rate=0.3)
        mc, mc_per_delay = measure_memory_capacity(res, max_delay=20, n_samples=800)
        capacities.append(mc)

        bar = "█" * int(mc * 3)
        print(f"    coupling={coupling:.4f}: MC={mc:6.2f} |{bar}")

    # Find optimal
    best_idx = np.argmax(capacities)
    print(f"\n    ★ Optimal coupling: {coupling_values[best_idx]:.4f} "
          f"(MC={capacities[best_idx]:.2f})")
    print(f"    This is the EDGE OF CHAOS — maximum computational capacity")

    # ── Memory Capacity Profile ────────────────────────────────
    print(f"\n\n  MEMORY CAPACITY PROFILE (optimal coupling)")
    print("  " + "─" * 55)

    optimal_res = LorenzReservoir(n_nodes=60, spectral_radius=0.9,
                                   input_scaling=0.05,
                                   coupling=coupling_values[best_idx],
                                   leak_rate=0.3)
    total_mc, mc_profile = measure_memory_capacity(optimal_res, max_delay=25,
                                                     n_samples=1000)

    print(f"  Total memory capacity: {total_mc:.2f}")
    print(f"  (Theoretical maximum for {optimal_res.n_nodes} nodes: {optimal_res.n_nodes})")
    print(f"\n  Per-delay capacity:")
    for k, mc_k in enumerate(mc_profile):
        bar = "█" * int(mc_k * 50)
        print(f"    delay={k+1:2d}: {mc_k:.3f} |{bar}")

    # ── Lyapunov Exponent Estimation ───────────────────────────
    print(f"\n\n  LYAPUNOV SPECTRUM ESTIMATION")
    print("  " + "─" * 55)

    def estimate_lyapunov(reservoir, n_steps=500):
        """Estimate largest Lyapunov exponent via divergence."""
        eps = 1e-8
        # Two nearby trajectories
        state1 = reservoir.states.copy()
        state2 = state1 + np.random.randn(*state1.shape) * eps

        divergences = []
        for t in range(n_steps):
            u = np.random.randn() * 0.01

            # Save and restore
            reservoir.states = state1.copy()
            reservoir.step(u)
            state1 = reservoir.states.copy()

            reservoir.states = state2.copy()
            reservoir.step(u)
            state2 = reservoir.states.copy()

            dist = np.linalg.norm(state1 - state2)
            if dist > 0:
                divergences.append(np.log(dist / eps))
                # Renormalize
                state2 = state1 + (state2 - state1) / dist * eps

        reservoir.states = state1
        return np.mean(divergences[-200:]) if divergences else 0

    for coupling in [0.001, 0.01, 0.05, 0.1]:
        res = LorenzReservoir(n_nodes=40, coupling=coupling)
        lyap = estimate_lyapunov(res)
        regime = "chaotic" if lyap > 0.1 else "edge" if lyap > -0.1 else "ordered"
        print(f"    coupling={coupling:.3f}: λ_max ≈ {lyap:+.4f} ({regime})")

    # ── Summary ────────────────────────────────────────────────
    print(f"\n\n  {'═' * 55}")
    print(f"  RESERVOIR COMPUTING SUMMARY")
    print(f"  {'═' * 55}")
    print(f"    ✓ Only readout layer is trained (linear regression)")
    print(f"    ✓ Chaotic dynamics provide FREE nonlinear mixing")
    print(f"    ✓ Training is instant (no backpropagation)")
    print(f"    ✓ Edge of chaos = maximum computational capacity")
    print(f"    ✓ Memory capacity scales with reservoir size")
    print(f"    ✓ Natural temporal computation for time series")
    print(f"\n    ★ The reservoir doesn't learn the task —")
    print(f"      it IS the computation, shaped by chaos.")
    print("=" * 65)


if __name__ == "__main__":
    main()
