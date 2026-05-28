#!/usr/bin/env python3
"""
applications.py — Real-world applications of finite-temperature tropical margins.

Demonstrates:
1. Certified robustness for neural network classifiers
2. Temperature scaling for confidence calibration
3. Continuation methods: smooth optimization → tropical solution
4. Phase diagram computation
"""

import numpy as np

# ─── Inline core functions (self-contained) ──────────────────────────────

def log_sum_exp(beta, a):
    scaled = beta * a
    m = np.max(scaled)
    return (1.0 / beta) * (m + np.log(np.sum(np.exp(scaled - m))))

def gibbs_weights(beta, a):
    s = beta * a
    s = s - np.max(s)
    w = np.exp(s)
    return w / np.sum(w)

def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]

def all_slacks(W):
    n = W.shape[0]
    return np.array([diag_ex_slack(W, i, j) for i in range(n) for j in range(n) if i != j])

def trop_margin(W):
    s = all_slacks(W)
    return float(np.min(s)) if len(s) > 0 else 0.0

def soft_margin(beta, W):
    s = all_slacks(W)
    return -log_sum_exp(beta, -s) if len(s) > 0 else 0.0


# ─── Application 1: Certified Robustness ────────────────────────────────

def certified_robustness_demo():
    """
    Demonstrate certified robustness radius computation.

    The soft margin provides a smooth, differentiable proxy for the
    tropical margin (robustness certificate). This enables gradient-based
    optimization of robustness while maintaining certified bounds.
    """
    print("=" * 60)
    print("Application 1: Certified Robustness")
    print("=" * 60)

    np.random.seed(42)
    n = 5

    # Simulate a weight matrix from a trained classifier
    W = np.random.randn(n, n) * 0.3
    for i in range(n):
        W[i, i] += 2.0  # diagonal dominance

    tm = trop_margin(W)
    print(f"Weight matrix shape: {W.shape}")
    print(f"Tropical robustness certificate: {tm:.4f}")
    print()

    # Show that soft margin is a smooth proxy
    print("Smooth approximation across temperatures:")
    for beta in [1, 5, 10, 50, 100]:
        sm = soft_margin(beta, W)
        gap = tm - sm
        bound = np.log(n*(n-1)) / beta
        print(f"  β={beta:4d}: soft_margin={sm:.6f}, gap={gap:.6f}, "
              f"bound={bound:.6f}, certified={gap <= bound + 1e-10}")

    # Perturbation analysis
    print("\nPerturbation stability (Lipschitz bound):")
    for eps in [0.01, 0.05, 0.1, 0.5]:
        dW = np.random.randn(n, n) * eps
        W_pert = W + dW
        for beta in [5, 50]:
            sm1 = soft_margin(beta, W)
            sm2 = soft_margin(beta, W_pert)
            delta_sm = abs(sm1 - sm2)
            # The Lipschitz constant for the slack map is 4 * max|dW|
            lip_bound = 4 * np.max(np.abs(dW))
            print(f"  ε={eps:.2f}, β={beta:3d}: |Δ soft_margin|={delta_sm:.6f}, "
                  f"4·‖δW‖∞={lip_bound:.6f}")


# ─── Application 2: Temperature Scaling ─────────────────────────────────

def temperature_scaling_demo():
    """
    Demonstrate temperature scaling for confidence calibration.

    In machine learning, softmax temperature controls the "sharpness"
    of predictions. Our theory provides certified bounds on how
    temperature affects the margin, enabling principled calibration.
    """
    print("\n" + "=" * 60)
    print("Application 2: Temperature Scaling for Calibration")
    print("=" * 60)

    # Simulated logits from a neural network
    logits = np.array([2.1, 5.3, 1.0, 0.5, 3.2])
    true_class = 1  # class with highest logit

    print(f"Logits: {logits}")
    print(f"True class: {true_class} (logit = {logits[true_class]:.1f})")
    print()

    print(f"{'β (1/T)':>8} {'T':>6} {'max_prob':>10} {'entropy':>10} {'margin_proxy':>14}")
    print("-" * 54)
    for beta in [0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        T = 1.0 / beta
        w = gibbs_weights(beta, logits)
        max_prob = w[true_class]
        entropy = -np.sum(w[w > 1e-300] * np.log(w[w > 1e-300]))
        lse = log_sum_exp(beta, logits)
        print(f"{beta:8.1f} {T:6.3f} {max_prob:10.6f} {entropy:10.6f} {lse:14.6f}")


# ─── Application 3: Continuation Method ─────────────────────────────────

def continuation_method_demo():
    """
    Demonstrate a continuation method: optimize smooth → tropical.

    Start with low β (smooth landscape), optimize, then increase β
    to approach the tropical solution. The monotonicity theorem
    guarantees the soft margin approaches the tropical margin.
    """
    print("\n" + "=" * 60)
    print("Application 3: Continuation Method")
    print("=" * 60)

    n = 4
    np.random.seed(17)

    # Start with a random matrix
    W = np.random.randn(n, n) * 0.5

    print(f"Initial tropical margin: {trop_margin(W):.4f}")
    print()

    # Simple gradient-free optimization: perturb diagonal to improve margin
    beta_schedule = [0.5, 1, 2, 5, 10, 50]

    for beta in beta_schedule:
        # Optimize soft margin by adjusting diagonal
        best_W = W.copy()
        best_sm = soft_margin(beta, W)

        for _ in range(100):
            # Random perturbation of diagonal
            delta = np.random.randn(n) * 0.05
            W_trial = W.copy()
            for i in range(n):
                W_trial[i, i] += delta[i]
            sm_trial = soft_margin(beta, W_trial)
            if sm_trial > best_sm:
                best_sm = sm_trial
                best_W = W_trial.copy()

        W = best_W
        tm = trop_margin(W)
        sm = soft_margin(beta, W)
        print(f"β={beta:5.1f}: soft_margin={sm:.4f}, trop_margin={tm:.4f}, gap={tm-sm:.4f}")


# ─── Application 4: Phase Diagram ───────────────────────────────────────

def phase_diagram_demo():
    """
    Compute a phase diagram showing how tropical and soft margins
    vary with a structural parameter.
    """
    print("\n" + "=" * 60)
    print("Application 4: Phase Diagram")
    print("=" * 60)

    n = 3
    # Parameterize by off-diagonal coupling strength
    couplings = np.linspace(-1, 2, 20)
    betas = [1, 5, 20]

    print(f"{'coupling':>10}", end="")
    print(f"{'trop':>10}", end="")
    for b in betas:
        print(f"{'β='+str(b):>10}", end="")
    print()
    print("-" * (10 + 10 + 10*len(betas)))

    for c in couplings:
        W = np.array([
            [2.0, c, c*0.5],
            [c, 1.8, c*0.3],
            [c*0.5, c*0.3, 2.2]
        ])
        tm = trop_margin(W)
        print(f"{c:10.3f}{tm:10.4f}", end="")
        for b in betas:
            sm = soft_margin(b, W)
            print(f"{sm:10.4f}", end="")
        print()


# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    certified_robustness_demo()
    temperature_scaling_demo()
    continuation_method_demo()
    phase_diagram_demo()
    print("\n✓ All applications completed successfully.")


#!/usr/bin/env python3
"""
demo.py — Interactive computation of finite-temperature tropical margins.

Computes and compares tropical margins vs. soft margins across a β-grid
for random matrices, demonstrating thermal sharpening and the certified
approximation bounds proved in Lean.

Usage: python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Core definitions ───────────────────────────────────────────────────

def diag_ex_slack(W, i, j):
    """Diagonal-exclusion slack: 2*W[i,j] - W[i,i] - W[j,j]."""
    return 2 * W[i, j] - W[i, i] - W[j, j]

def trop_margin(W):
    """Tropical margin: minimum diagonal-exclusion slack over distinct pairs."""
    n = W.shape[0]
    slacks = []
    for i in range(n):
        for j in range(n):
            if i != j:
                slacks.append(diag_ex_slack(W, i, j))
    return min(slacks) if slacks else 0.0

def log_sum_exp(beta, a):
    """Log-sum-exp: (1/β) * log(∑ exp(β * aᵢ))."""
    shifted = beta * a
    max_val = np.max(shifted)
    return (1.0 / beta) * (max_val + np.log(np.sum(np.exp(shifted - max_val))))

def soft_margin(beta, W):
    """Soft margin: -logSumExp(β, -slacks) = soft minimum of slacks."""
    n = W.shape[0]
    neg_slacks = []
    for i in range(n):
        for j in range(n):
            if i != j:
                neg_slacks.append(-diag_ex_slack(W, i, j))
    neg_slacks = np.array(neg_slacks)
    return -log_sum_exp(beta, neg_slacks)

def gibbs_weights(beta, a):
    """Gibbs/Boltzmann weights (softmax)."""
    shifted = beta * a
    shifted -= np.max(shifted)  # numerical stability
    w = np.exp(shifted)
    return w / np.sum(w)

# ─── Demo 1: Transition curves for n=8 ──────────────────────────────────

def demo_transition_curves(n=8):
    """Plot soft margin vs β for a random matrix."""
    np.random.seed(42)
    W = np.random.randn(n, n) * 0.5
    # Make diagonal dominant so tropical margin is positive
    for i in range(n):
        W[i, i] += 2.0

    tm = trop_margin(W)
    betas = [0.5, 1, 2, 5, 10, 20, 50, 100]
    soft_margins = [soft_margin(b, W) for b in betas]

    # Number of distinct pairs
    num_pairs = n * (n - 1)
    error_bounds = [np.log(num_pairs) / b for b in betas]

    print("=" * 60)
    print(f"Demo 1: Transition Curves (n={n})")
    print("=" * 60)
    print(f"Tropical margin: {tm:.6f}")
    print(f"Number of distinct pairs: {num_pairs}")
    print()
    print(f"{'β':>8}  {'softMargin':>12}  {'error':>12}  {'bound':>12}  {'within?':>8}")
    print("-" * 60)
    for b, sm, eb in zip(betas, soft_margins, error_bounds):
        err = abs(sm - tm)
        within = "YES" if err <= eb + 1e-10 else "NO"
        print(f"{b:8.1f}  {sm:12.6f}  {err:12.6f}  {eb:12.6f}  {within:>8}")

    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.axhline(y=tm, color='red', linestyle='--', linewidth=2, label=f'Tropical margin = {tm:.4f}')
    ax.plot(betas, soft_margins, 'bo-', linewidth=2, markersize=8, label='Soft margin')
    lower_bounds = [tm - eb for eb in error_bounds]
    ax.fill_between(betas, lower_bounds, [tm]*len(betas), alpha=0.2, color='green',
                     label='Certified approximation band')
    ax.set_xlabel('β (inverse temperature)', fontsize=14)
    ax.set_ylabel('Margin', fontsize=14)
    ax.set_title(f'Thermal Sharpening: Soft Margin → Tropical Margin (n={n})', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('transition_curves.png', dpi=150)
    print(f"\nPlot saved to transition_curves.png")

# ─── Demo 2: Monotonicity verification ──────────────────────────────────

def demo_monotonicity(n=6):
    """Verify that soft margin is monotonically increasing in β."""
    np.random.seed(123)
    W = np.random.randn(n, n)
    for i in range(n):
        W[i, i] += 3.0

    betas = np.linspace(0.1, 50, 200)
    sms = [soft_margin(b, W) for b in betas]
    tm = trop_margin(W)

    print("\n" + "=" * 60)
    print(f"Demo 2: Monotonicity Verification (n={n})")
    print("=" * 60)
    is_monotone = all(sms[i] <= sms[i+1] + 1e-12 for i in range(len(sms)-1))
    print(f"Soft margin is monotonically increasing in β: {is_monotone}")
    print(f"Min soft margin (β=0.1): {sms[0]:.6f}")
    print(f"Max soft margin (β=50): {sms[-1]:.6f}")
    print(f"Tropical margin: {tm:.6f}")

# ─── Demo 3: Gibbs weights concentration ────────────────────────────────

def demo_gibbs_concentration():
    """Show Gibbs weights concentrating on maximizer as β → ∞."""
    a = np.array([1.0, 2.5, 2.0, 0.5, 1.8])
    betas = [0.1, 0.5, 1, 2, 5, 10, 50]

    print("\n" + "=" * 60)
    print("Demo 3: Gibbs Weight Concentration")
    print("=" * 60)
    print(f"Values: {a}")
    print(f"Max at index {np.argmax(a)} (value {np.max(a)})")
    print()
    for b in betas:
        w = gibbs_weights(b, a)
        print(f"β={b:5.1f}: weights = [{', '.join(f'{x:.4f}' for x in w)}], sum = {np.sum(w):.6f}")

# ─── Demo 4: Lipschitz stability ────────────────────────────────────────

def demo_lipschitz(n=5):
    """Verify Lipschitz bound on perturbation."""
    np.random.seed(7)
    a = np.random.randn(n)
    perturbation = np.random.randn(n) * 0.1
    b = a + perturbation
    delta = np.max(np.abs(a - b))

    print("\n" + "=" * 60)
    print(f"Demo 4: Lipschitz Stability")
    print("=" * 60)

    for beta in [1, 5, 10, 50]:
        lse_a = log_sum_exp(beta, a)
        lse_b = log_sum_exp(beta, b)
        diff = abs(lse_a - lse_b)
        print(f"β={beta:3d}: |LSE(a)-LSE(b)| = {diff:.6f} ≤ δ = {delta:.6f}: {diff <= delta + 1e-10}")

# ─── Demo 5: Thermal width law test ─────────────────────────────────────

def demo_thermal_width():
    """Test the conjecture: β * width(β) should stabilize."""
    print("\n" + "=" * 60)
    print("Demo 5: Thermal Width Law (Phase Transition)")
    print("=" * 60)

    # Create a 1-parameter family crossing a phase boundary
    n = 4
    betas = [1, 2, 5, 10, 20, 50]

    def make_W(t):
        W = np.array([
            [t, 0.5, 0.3, 0.2],
            [0.5, 1.0, 0.4, 0.3],
            [0.3, 0.4, 0.8, 0.5],
            [0.2, 0.3, 0.5, 0.6]
        ])
        return W

    # Find approximate crossing point
    ts = np.linspace(-1, 3, 1000)
    margins = [trop_margin(make_W(t)) for t in ts]
    t_star_idx = np.argmin(np.abs(margins))
    t_star = ts[t_star_idx]

    print(f"Approximate tropical phase boundary at t* ≈ {t_star:.3f}")
    print(f"Tropical margin at t*: {margins[t_star_idx]:.6f}")
    print()

    for beta in betas:
        soft_ms = [soft_margin(beta, make_W(t)) for t in ts]
        # Compute width: interval where |soft - trop| > threshold
        threshold = 0.01
        diffs = [abs(sm - tm) for sm, tm in zip(soft_ms, margins)]
        significant = [i for i, d in enumerate(diffs) if d > threshold]
        if significant:
            width = ts[max(significant)] - ts[min(significant)]
        else:
            width = 0.0
        product = beta * width
        print(f"β={beta:3d}: width={width:.4f}, β·width={product:.4f}")

# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    demo_transition_curves(n=8)
    demo_monotonicity()
    demo_gibbs_concentration()
    demo_lipschitz()
    demo_thermal_width()
    print("\n✓ All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Gibbs Weight Concentration and Phase Transitions

This script visualizes how Gibbs/Boltzmann weights concentrate on the
maximizer as inverse temperature β increases. This is the statistical
mechanics interpretation: at low temperature, the system freezes into
its ground state. At high temperature, all states are equally likely.

The visualization shows both the weight evolution and the entropy decay,
connecting tropical geometry to statistical mechanics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def gibbs_weights(beta, a):
    s = beta * a
    s = s - np.max(s)
    w = np.exp(s)
    return w / np.sum(w)

def log_sum_exp(beta, a):
    scaled = beta * a
    m = np.max(scaled)
    return (1.0 / beta) * (m + np.log(np.sum(np.exp(scaled - m))))

# Data
a = np.array([1.0, 2.5, 2.3, 0.5, 1.8])
labels = [f'a[{i}]={a[i]}' for i in range(len(a))]
betas = np.logspace(-1, 2, 200)

# Compute weights and entropy
weights = np.array([gibbs_weights(b, a) for b in betas])
entropies = []
lse_values = []
for b in betas:
    p = gibbs_weights(b, a)
    H = -np.sum(p[p > 1e-300] * np.log(p[p > 1e-300]))
    entropies.append(H)
    lse_values.append(log_sum_exp(b, a))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: Gibbs weights vs β
ax = axes[0, 0]
colors = plt.cm.tab10(np.linspace(0, 1, len(a)))
for i in range(len(a)):
    ax.plot(betas, weights[:, i], linewidth=2, color=colors[i], label=labels[i])
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('Gibbs weight', fontsize=12)
ax.set_title('Gibbs Weights: Concentration → Ground State', fontsize=14)
ax.set_xscale('log')
ax.legend(fontsize=10, loc='center right')
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Top-right: Entropy vs β
ax = axes[0, 1]
ax.plot(betas, entropies, 'purple', linewidth=2.5)
ax.axhline(y=np.log(len(a)), color='gray', linestyle=':', label=f'Max entropy = log({len(a)}) = {np.log(len(a)):.2f}')
ax.axhline(y=0, color='gray', linestyle=':')
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('Shannon entropy H(p)', fontsize=12)
ax.set_title('Entropy Decay: Disorder → Order', fontsize=14)
ax.set_xscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-left: Free energy decomposition
ax = axes[1, 0]
energies = [np.sum(gibbs_weights(b, a) * a) for b in betas]
entropy_terms = [e / b for e, b in zip(entropies, betas)]
ax.plot(betas, lse_values, 'b-', linewidth=2.5, label='LSE (free energy)')
ax.plot(betas, energies, 'r--', linewidth=2, label='⟨a⟩ (Gibbs energy)')
ax.plot(betas, entropy_terms, 'g:', linewidth=2, label='H/β (entropy term)')
ax.axhline(y=np.max(a), color='k', linestyle='-.', alpha=0.5, label=f'max(a) = {np.max(a)}')
ax.set_xlabel('β (inverse temperature)', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Free Energy = Energy + Entropy/β', fontsize=14)
ax.set_xscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-right: Phase transition in a 2-state system
ax = axes[1, 1]
ts = np.linspace(-2, 2, 300)
for beta in [0.5, 1, 2, 5, 20]:
    vals = []
    for t in ts:
        a2 = np.array([0.0, t])
        vals.append(log_sum_exp(beta, a2))
    ax.plot(ts, vals, linewidth=2, label=f'β={beta}')
ax.plot(ts, np.maximum(0, ts), 'k--', linewidth=2.5, label='max(0, t) [β=∞]')
ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('LSE_β(0, t)', fontsize=12)
ax.set_title('Two-State Phase Transition: Thermal Rounding', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_gibbs_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_gibbs_concentration.png")


#!/usr/bin/env python3
"""
Visualization: Phase Diagram and Thermal Width Law

This script creates a phase diagram showing how the tropical and soft margins
vary as a structural parameter crosses a phase boundary. It also tests the
thermal width conjecture: the transition width scales as 1/β.

The visualization connects tropical geometry (sharp phase boundaries) to
statistical mechanics (thermal broadening) via the inverse temperature β.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def log_sum_exp(beta, a):
    scaled = beta * a
    m = np.max(scaled)
    return (1.0 / beta) * (m + np.log(np.sum(np.exp(scaled - m))))

def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]

def all_slacks(W):
    n = W.shape[0]
    return np.array([diag_ex_slack(W, i, j) for i in range(n) for j in range(n) if i != j])

def trop_margin(W):
    s = all_slacks(W)
    return float(np.min(s))

def soft_margin(beta, W):
    s = all_slacks(W)
    return -log_sum_exp(beta, -s)

def make_W(t, n=4):
    """1-parameter family crossing a phase boundary."""
    W = np.diag([2.0, 1.8, 1.6, 2.1])
    W[0, 1] = W[1, 0] = t
    W[0, 2] = W[2, 0] = 0.3
    W[0, 3] = W[3, 0] = 0.4
    W[1, 2] = W[2, 1] = 0.5
    W[1, 3] = W[3, 1] = 0.3
    W[2, 3] = W[3, 2] = 0.7
    return W

# Compute margin curves
ts = np.linspace(-0.5, 3.0, 500)
trop_margins = [trop_margin(make_W(t)) for t in ts]
betas = [1, 2, 5, 10, 20, 50]

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Left: Phase diagram
ax = axes[0]
ax.plot(ts, trop_margins, 'k-', linewidth=3, label='Tropical (β=∞)')
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(betas)))
for beta, color in zip(betas, colors):
    sms = [soft_margin(beta, make_W(t)) for t in ts]
    ax.plot(ts, sms, '-', linewidth=1.5, color=color, label=f'β={beta}')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Coupling parameter t', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title('Tropical Phase Diagram\nwith Thermal Smoothing', fontsize=14)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)

# Middle: Thermal broadening detail near crossing
t_star_idx = np.argmin(np.abs(trop_margins))
t_star = ts[t_star_idx]
window = 0.5
mask = (ts > t_star - window) & (ts < t_star + window)

ax = axes[1]
ax.plot(ts[mask], np.array(trop_margins)[mask], 'k-', linewidth=3, label='Tropical')
for beta, color in zip([2, 5, 10, 50], colors[1:5]):
    sms = [soft_margin(beta, make_W(t)) for t in ts[mask]]
    ax.plot(ts[mask], sms, '-', linewidth=2, color=color, label=f'β={beta}')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.axvline(x=t_star, color='red', linestyle='--', alpha=0.5, label=f't* ≈ {t_star:.2f}')
ax.set_xlabel('t (near phase boundary)', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title(f'Thermal Broadening\nnear t* ≈ {t_star:.2f}', fontsize=14)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Right: Thermal width vs 1/β
ax = axes[2]
widths = []
test_betas = np.logspace(np.log10(0.5), np.log10(100), 50)
for beta in test_betas:
    sms = np.array([soft_margin(beta, make_W(t)) for t in ts])
    diffs = np.abs(np.array(sms) - np.array(trop_margins))
    threshold = 0.05
    sig = np.where(diffs > threshold)[0]
    if len(sig) > 0:
        w = ts[sig[-1]] - ts[sig[0]]
    else:
        w = 0.0
    widths.append(w)

widths = np.array(widths)
products = test_betas * widths

ax.plot(test_betas, widths, 'b-', linewidth=2.5, label='Transition width')
ax.plot(test_betas, 2.0 / test_betas, 'r--', linewidth=2, label='Reference: 2/β')
ax.set_xlabel('β (inverse temperature)', fontsize=13)
ax.set_ylabel('Transition width', fontsize=13)
ax.set_title('Thermal Width Law:\nwidth ~ 1/β', fontsize=14)
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_diagram.png")


#!/usr/bin/env python3
"""
Visualization: Thermal Sharpening of Tropical Margins

This script visualizes how the soft margin (finite-temperature free energy)
converges to the tropical margin (zero-temperature limit) as the inverse
temperature β increases. The certified approximation band from the
sandwich theorem is shown as a shaded region.

Key insight: The soft margin lives in a band of width log(card)/β above
the tropical margin, and this band shrinks monotonically as temperature drops.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def log_sum_exp(beta, a):
    scaled = beta * a
    m = np.max(scaled)
    return (1.0 / beta) * (m + np.log(np.sum(np.exp(scaled - m))))

def diag_ex_slack(W, i, j):
    return 2.0 * W[i, j] - W[i, i] - W[j, j]

def all_slacks(W):
    n = W.shape[0]
    return np.array([diag_ex_slack(W, i, j) for i in range(n) for j in range(n) if i != j])

def trop_margin(W):
    s = all_slacks(W)
    return float(np.min(s))

def soft_margin(beta, W):
    s = all_slacks(W)
    return -log_sum_exp(beta, -s)

# Generate data
np.random.seed(42)
n = 8
W = np.random.randn(n, n) * 0.5
for i in range(n):
    W[i, i] += 2.5

tm = trop_margin(W)
num_pairs = n * (n - 1)

betas = np.logspace(-0.5, 2.5, 200)
soft_margins = [soft_margin(b, W) for b in betas]
upper_bounds = [tm for _ in betas]
lower_bounds = [tm - np.log(num_pairs) / b for b in betas]

# Create the figure
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Left panel: Margin vs β
ax = axes[0]
ax.fill_between(betas, lower_bounds, upper_bounds, alpha=0.15, color='green',
                label='Certified band: log(card)/β')
ax.plot(betas, soft_margins, 'b-', linewidth=2.5, label='Soft margin (β)')
ax.axhline(y=tm, color='red', linestyle='--', linewidth=2, label=f'Tropical margin = {tm:.3f}')
ax.set_xlabel('β (inverse temperature)', fontsize=13)
ax.set_ylabel('Margin', fontsize=13)
ax.set_title('Thermal Sharpening: Soft → Tropical', fontsize=15)
ax.set_xscale('log')
ax.legend(fontsize=11, loc='lower right')
ax.grid(True, alpha=0.3)
ax.set_ylim(tm - 1.5, tm + 0.5)

# Right panel: Error vs β (log-log)
ax = axes[1]
errors = [tm - sm for sm in soft_margins]
bounds_err = [np.log(num_pairs) / b for b in betas]
ax.loglog(betas, errors, 'b-', linewidth=2.5, label='Actual error')
ax.loglog(betas, bounds_err, 'r--', linewidth=2, label='Bound: log(card)/β')
ax.set_xlabel('β (inverse temperature)', fontsize=13)
ax.set_ylabel('|soft_margin - trop_margin|', fontsize=13)
ax.set_title('Approximation Error (O(1/β) decay)', fontsize=15)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('viz_thermal_sharpening.png', dpi=150, bbox_inches='tight')
print("Saved viz_thermal_sharpening.png")
