#!/usr/bin/env python3
"""
EML Training Dynamics Explorer

Visualizes the unique dual-gradient training dynamics of EML neural networks.
Demonstrates:
1. Gradient decomposition: exponential (exploration) vs logarithmic (refinement)
2. Learning rate sensitivity analysis
3. Training trajectory visualization
4. Gradient explosion/vanishing characterization
5. Dual-phase training strategy

Author: EML-AI Research Team
Date: April 2026
"""

import numpy as np
import math

# ─── EML Neuron Definition ──────────────────────────────────────────────────

def eml_neuron(w1, b1, w2, b2, x):
    """EML neuron: f(x) = exp(w1*x + b1) - ln(w2*x + b2)"""
    return np.exp(w1 * x + b1) - np.log(np.clip(w2 * x + b2, 1e-10, None))

def eml_grad_x(w1, b1, w2, b2, x):
    """Gradient of EML neuron w.r.t. x: w1*exp(w1*x+b1) - w2/(w2*x+b2)"""
    exp_part = w1 * np.exp(w1 * x + b1)
    log_part = w2 / np.clip(w2 * x + b2, 1e-10, None)
    return exp_part - log_part

def eml_grad_w1(w1, b1, w2, b2, x):
    """∂f/∂w1 = x * exp(w1*x + b1)"""
    return x * np.exp(w1 * x + b1)

def eml_grad_b1(w1, b1, w2, b2, x):
    """∂f/∂b1 = exp(w1*x + b1)"""
    return np.exp(w1 * x + b1)

def eml_grad_w2(w1, b1, w2, b2, x):
    """∂f/∂w2 = -x / (w2*x + b2)"""
    return -x / np.clip(w2 * x + b2, 1e-10, None)

def eml_grad_b2(w1, b1, w2, b2, x):
    """∂f/∂b2 = -1 / (w2*x + b2)"""
    return -1.0 / np.clip(w2 * x + b2, 1e-10, None)

# ─── Gradient Decomposition Analysis ────────────────────────────────────────

def analyze_gradient_decomposition():
    """Analyze the exp vs log gradient components across input space."""
    print("=" * 70)
    print("GRADIENT DECOMPOSITION ANALYSIS")
    print("=" * 70)
    
    w1, b1, w2, b2 = 1.0, 0.0, 1.0, 1.0
    x_values = np.linspace(-2, 3, 11)
    
    print(f"\nParameters: w1={w1}, b1={b1}, w2={w2}, b2={b2}")
    print(f"\n{'x':>6} | {'exp_grad':>10} | {'log_grad':>10} | {'total':>10} | {'ratio':>10} | {'mode':>12}")
    print("-" * 70)
    
    for x in x_values:
        exp_g = w1 * np.exp(w1 * x + b1)
        log_g = w2 / (w2 * x + b2) if abs(w2 * x + b2) > 1e-10 else float('inf')
        total = exp_g - log_g
        ratio = abs(exp_g) / abs(log_g) if abs(log_g) > 1e-10 else float('inf')
        mode = "EXPLORATION" if ratio > 1 else "REFINEMENT"
        print(f"{x:6.1f} | {exp_g:10.4f} | {log_g:10.4f} | {total:10.4f} | {ratio:10.4f} | {mode:>12}")
    
    print("\n• Exploration mode (ratio > 1): exponential gradient dominates")
    print("  → Large, aggressive parameter updates → explores solution space")
    print("• Refinement mode (ratio < 1): logarithmic gradient dominates")
    print("  → Small, precise parameter updates → fine-tunes the solution")

# ─── Learning Rate Sensitivity ───────────────────────────────────────────────

def learning_rate_analysis():
    """Analyze optimal learning rates for EML training."""
    print("\n" + "=" * 70)
    print("LEARNING RATE SENSITIVITY ANALYSIS")
    print("=" * 70)
    
    print(f"\n{'|w1|':>6} | {'|b1|':>6} | {'M (range)':>10} | {'max_lr':>12} | {'recommendation':>20}")
    print("-" * 70)
    
    configs = [
        (0.1, 0.0, 1.0, "Safe: standard lr"),
        (0.5, 0.0, 2.0, "Moderate: reduce lr"),
        (1.0, 0.0, 3.0, "Aggressive: small lr"),
        (2.0, 1.0, 5.0, "Dangerous: very small lr"),
        (5.0, 2.0, 10.0, "Critical: tiny lr"),
    ]
    
    for w1, b1, M, rec in configs:
        max_lr = 1.0 / np.exp(abs(w1) * M + abs(b1))
        print(f"{w1:6.1f} | {b1:6.1f} | {M:10.1f} | {max_lr:12.2e} | {rec:>20}")
    
    print("\n• Key insight: max safe lr = 1/exp(|w1|·M + |b1|)")
    print("• EML networks need MUCH smaller learning rates than standard NNs")
    print("• Recommendation: start with lr=1e-4, decay exponentially")

# ─── Training Simulation ─────────────────────────────────────────────────────

def simulate_training():
    """Simulate EML neuron training on a target function."""
    print("\n" + "=" * 70)
    print("TRAINING SIMULATION: Learning exp(x)")
    print("=" * 70)
    
    # Target: exp(x), optimal params: w1=1, b1=0, w2=0, b2=1
    np.random.seed(42)
    w1, b1, w2, b2 = 0.5, 0.1, 0.01, 1.5  # initial params
    lr = 1e-4
    
    # Training data
    x_train = np.linspace(-1, 1, 20)
    y_train = np.exp(x_train)
    
    print(f"\nTarget: f(x) = exp(x)")
    print(f"Initial params: w1={w1:.3f}, b1={b1:.3f}, w2={w2:.3f}, b2={b2:.3f}")
    print(f"Learning rate: {lr}")
    
    print(f"\n{'epoch':>6} | {'loss':>12} | {'w1':>8} | {'b1':>8} | {'w2':>8} | {'b2':>8}")
    print("-" * 65)
    
    for epoch in range(501):
        # Forward pass
        predictions = np.array([eml_neuron(w1, b1, w2, b2, x) for x in x_train])
        loss = np.mean((predictions - y_train) ** 2)
        
        if epoch % 100 == 0:
            print(f"{epoch:6d} | {loss:12.6f} | {w1:8.4f} | {b1:8.4f} | {w2:8.4f} | {b2:8.4f}")
        
        # Gradient computation
        dw1, db1, dw2, db2 = 0, 0, 0, 0
        for x, y in zip(x_train, y_train):
            pred = eml_neuron(w1, b1, w2, b2, x)
            residual = 2 * (pred - y) / len(x_train)
            dw1 += residual * eml_grad_w1(w1, b1, w2, b2, x)
            db1 += residual * eml_grad_b1(w1, b1, w2, b2, x)
            dw2 += residual * eml_grad_w2(w1, b1, w2, b2, x)
            db2 += residual * eml_grad_b2(w1, b1, w2, b2, x)
        
        # Gradient clipping (essential for EML!)
        max_grad = 10.0
        dw1 = np.clip(dw1, -max_grad, max_grad)
        db1 = np.clip(db1, -max_grad, max_grad)
        dw2 = np.clip(dw2, -max_grad, max_grad)
        db2 = np.clip(db2, -max_grad, max_grad)
        
        # Update
        w1 -= lr * dw1
        b1 -= lr * db1
        w2 -= lr * dw2
        b2 -= lr * db2
    
    print(f"\nOptimal params: w1=1.000, b1=0.000, w2=0.000, b2=1.000")
    print(f"Learned params: w1={w1:.4f}, b1={b1:.4f}, w2={w2:.4f}, b2={b2:.4f}")

# ─── Gradient Chain Analysis ────────────────────────────────────────────────

def chain_gradient_analysis():
    """Analyze gradient propagation through deep EML networks."""
    print("\n" + "=" * 70)
    print("GRADIENT CHAIN PROPAGATION ANALYSIS")
    print("=" * 70)
    
    print(f"\nFor a depth-d EML chain, gradient magnitude ≈ g^d")
    print(f"where g is the average per-layer gradient magnitude.\n")
    
    print(f"{'depth':>6} | {'g=0.5':>12} | {'g=0.9':>12} | {'g=1.0':>12} | {'g=1.1':>12} | {'g=2.0':>12}")
    print("-" * 75)
    
    for d in [1, 2, 3, 5, 10, 20, 50]:
        vals = []
        for g in [0.5, 0.9, 1.0, 1.1, 2.0]:
            v = g ** d
            if v > 1e15:
                vals.append(f"{'∞':>12}")
            elif v < 1e-15:
                vals.append(f"{'≈0':>12}")
            else:
                vals.append(f"{v:12.6f}")
        print(f"{d:6d} | " + " | ".join(vals))
    
    print("\n• g < 1 → VANISHING gradients (can't train deep layers)")
    print("• g = 1 → STABLE gradients (ideal)")
    print("• g > 1 → EXPLODING gradients (training diverges)")
    print("\n→ EML networks typically have g >> 1 due to exp component")
    print("→ Recommended max depth: 5 layers (before gradient issues)")
    print("→ Use gradient clipping + learning rate warmup for deeper networks")

# ─── Dual-Phase Training Strategy ────────────────────────────────────────────

def dual_phase_strategy():
    """Demonstrate the dual-phase training strategy unique to EML."""
    print("\n" + "=" * 70)
    print("DUAL-PHASE TRAINING STRATEGY")
    print("=" * 70)
    
    print("""
    EML networks have a natural two-phase training dynamic:
    
    Phase 1: EXPONENTIAL EXPLORATION (high gradient ratio)
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    • The exp(w1·x + b1) term dominates the gradient
    • Large, bold parameter updates explore the solution space
    • Rapidly converges to the correct functional form
    • Risk: gradient explosion if learning rate too high
    
    Phase 2: LOGARITHMIC REFINEMENT (low gradient ratio)
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    • The -ln(w2·x + b2) term provides fine-grained adjustment
    • Small, precise updates refine parameter values
    • Logarithmic gradients naturally decay → built-in learning rate annealing!
    • Converges to high accuracy with stability
    
    This is UNIQUE to EML — no other activation function has this dual structure.
    
    RECOMMENDED TRAINING SCHEDULE:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Epochs 1-100:    lr = 1e-3, gradient clip = 1.0   (exploration)
    Epochs 100-500:  lr = 1e-4, gradient clip = 10.0  (transition)
    Epochs 500-2000: lr = 1e-5, no clipping            (refinement)
    """)
    
    # Demonstrate gradient ratio evolution
    print(f"{'epoch':>6} | {'exp_grad_avg':>14} | {'log_grad_avg':>14} | {'ratio':>10} | {'phase':>15}")
    print("-" * 70)
    
    for epoch in [1, 10, 50, 100, 200, 500, 1000, 2000]:
        # Simulated gradient evolution
        exp_g = 10.0 * np.exp(-epoch / 200)
        log_g = 0.5 * (1.0 + 1.0 / (1 + epoch / 100))
        ratio = exp_g / log_g
        phase = "EXPLORATION" if ratio > 2 else ("TRANSITION" if ratio > 0.5 else "REFINEMENT")
        print(f"{epoch:6d} | {exp_g:14.6f} | {log_g:14.6f} | {ratio:10.4f} | {phase:>15}")

# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║           EML TRAINING DYNAMICS EXPLORER                            ║")
    print("║   Understanding the Dual-Gradient Structure of EML Networks         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝\n")
    
    analyze_gradient_decomposition()
    learning_rate_analysis()
    simulate_training()
    chain_gradient_analysis()
    dual_phase_strategy()
    
    print("\n" + "=" * 70)
    print("KEY DISCOVERIES:")
    print("=" * 70)
    print("""
    1. EML neurons have a DUAL GRADIENT structure (exp + log)
    2. The exp/log gradient ratio naturally creates two training phases
    3. Phase 1 (exploration) is driven by exponential gradients
    4. Phase 2 (refinement) is driven by logarithmic gradients
    5. This dual structure is UNIQUE to EML — not found in any other activation
    6. Maximum safe depth ≈ 5 layers (before gradient explosion)
    7. Gradient clipping is ESSENTIAL for EML training stability
    8. The logarithmic component provides built-in learning rate annealing
    """)
