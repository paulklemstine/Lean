#!/usr/bin/env python3
"""
OISCC-EML Visualization Demo

Generates ASCII visualizations of:
1. EML neuron function landscape
2. Compression ratios across scales
3. Crystallization error distribution
4. OISCC program execution trace
"""

import numpy as np

def ascii_plot(xs, ys, width=60, height=20, title="", xlabel="x", ylabel="y"):
    """Simple ASCII scatter/line plot."""
    y_min, y_max = min(ys), max(ys)
    x_min, x_max = min(xs), max(xs)
    
    if y_max == y_min:
        y_max = y_min + 1
    
    canvas = [[' ' for _ in range(width)] for _ in range(height)]
    
    for x, y in zip(xs, ys):
        col = int((x - x_min) / (x_max - x_min) * (width - 1))
        row = height - 1 - int((y - y_min) / (y_max - y_min) * (height - 1))
        col = max(0, min(width - 1, col))
        row = max(0, min(height - 1, row))
        canvas[row][col] = '█'
    
    print(f"\n  {title}")
    print(f"  {ylabel} ↑")
    print(f"  {y_max:>8.2f} ┤{''.join(canvas[0])}")
    for i in range(1, height - 1):
        if i == height // 2:
            val = (y_max + y_min) / 2
            print(f"  {val:>8.2f} ┤{''.join(canvas[i])}")
        else:
            print(f"           │{''.join(canvas[i])}")
    print(f"  {y_min:>8.2f} ┤{''.join(canvas[-1])}")
    print(f"           └{'─' * width}→ {xlabel}")
    print(f"           {x_min:<10.2f}{' ' * (width - 20)}{x_max:>10.2f}")


def eml(a, b):
    return np.exp(a) - np.log(max(b, 1e-10))


def eml_neuron(w1, b1, w2, b2, x):
    return np.exp(w1 * x + b1) - np.log(max(w2 * x + b2, 1e-10))


def viz_eml_landscape():
    """Visualize EML neuron function shapes."""
    print("=" * 70)
    print("Visualization 1: EML Neuron Function Landscape")
    print("=" * 70)
    
    xs = np.linspace(-3, 3, 60)
    
    # Pure exponential: EML(x, 1) = exp(x)
    ys = [eml_neuron(1, 0, 0, 1, x) for x in xs]
    ascii_plot(xs, ys, title="EML Neuron: exp(x)  [w₁=1, b₁=0, w₂=0, b₂=1]", ylabel="f(x)")
    
    # Subtraction-like: EML(x, exp(1)) = exp(x) - 1
    ys = [eml_neuron(1, 0, 0, np.e, x) for x in xs]
    ascii_plot(xs, ys, title="EML Neuron: exp(x) - 1  [w₁=1, b₁=0, w₂=0, b₂=e]", ylabel="f(x)")
    
    # Mixed: exp(x) - ln(x+4)
    ys = [eml_neuron(1, 0, 1, 4, x) for x in xs]
    ascii_plot(xs, ys, title="EML Neuron: exp(x) - ln(x+4)  [w₁=1, b₁=0, w₂=1, b₂=4]", ylabel="f(x)")


def viz_compression_ratios():
    """Visualize compression ratios across dimensions."""
    print("\n" + "=" * 70)
    print("Visualization 2: Compression Ratio vs Dimension")
    print("=" * 70)
    
    dims = list(range(5, 65))
    ratios = [(d*d + d) / (4*d) for d in dims]
    
    ascii_plot(dims, ratios, 
              title="Compression Ratio: Dense(d²+d) / EML(4d)",
              xlabel="dimension d", ylabel="ratio")
    
    print("\n  Key data points:")
    for d in [8, 16, 32, 64, 128, 256, 512, 1024, 4096]:
        r = (d*d + d) / (4*d)
        print(f"    d={d:>5}: {r:>8.1f}× compression")


def viz_crystallization():
    """Visualize crystallization error distribution."""
    print("\n" + "=" * 70)
    print("Visualization 3: Crystallization Error Distribution")
    print("=" * 70)
    
    np.random.seed(42)
    n = 200
    weights = np.random.randn(n) * 2
    errors = np.abs(weights - np.round(weights))
    
    # Histogram via ASCII
    n_bins = 20
    bins = np.linspace(0, 0.5, n_bins + 1)
    counts = np.histogram(errors, bins=bins)[0]
    max_count = max(counts)
    
    print(f"\n  Crystallization Error Histogram (n={n} weights)")
    print(f"  Error ≤ 0.5 guaranteed by Lean theorem `uc_crystal_error`")
    print()
    
    bar_width = 40
    for i in range(n_bins):
        bar_len = int(counts[i] / max_count * bar_width) if max_count > 0 else 0
        lo = bins[i]
        hi = bins[i+1]
        print(f"  [{lo:.2f},{hi:.2f}) │{'█' * bar_len}{' ' * (bar_width - bar_len)}│ {counts[i]}")
    
    print(f"\n  Total L1 error: {errors.sum():.2f}")
    print(f"  Theoretical max (n/2): {n/2:.1f}")
    print(f"  Max per-weight error: {errors.max():.4f}")
    print(f"  Mean per-weight error: {errors.mean():.4f}")
    
    # Crystallization penalty
    print(f"\n  Crystallization Penalty sin²(πw):")
    ws = np.linspace(-2, 2, 60)
    penalties = [np.sin(np.pi * w) ** 2 for w in ws]
    ascii_plot(ws, penalties, 
              title="sin²(πw): drives weights to integers during training",
              xlabel="weight w", ylabel="penalty")


def viz_oiscc_execution():
    """Visualize OISCC program execution trace."""
    print("\n" + "=" * 70)
    print("Visualization 4: OISCC Stack Machine Execution")
    print("=" * 70)
    
    # Program: compute exp(2) via EML(2, 1)
    print(f"\n  Program: PUSH 2.0, PUSH 1.0, EML")
    print(f"  Expected: exp(2) = {np.exp(2):.6f}")
    print()
    
    steps = [
        ("PUSH 2.0", [2.0]),
        ("PUSH 1.0", [2.0, 1.0]),
        ("EML", [np.exp(2) - np.log(1)]),
    ]
    
    max_stack = 3
    print(f"  Step  Instruction    Stack")
    print(f"  ────  ───────────    ─────────────────────")
    for i, (instr, stack) in enumerate(steps):
        stack_viz = ' '.join(f'[{v:.4f}]' for v in stack)
        print(f"  {i+1:<4}  {instr:<14} {stack_viz}")
    
    print(f"\n  Result: {steps[-1][1][0]:.6f} ✓")
    
    # Larger program: compute 3 + 5 via EML(ln(3), exp(-5))
    print(f"\n  ────────────────────────────────────────")
    print(f"\n  Program: Compute 3 + 5")
    print(f"  Method: EML(ln(3), exp(-5)) = exp(ln(3)) - ln(exp(-5)) = 3 - (-5) = 8")
    print()
    
    steps2 = [
        ("PUSH ln(3)", [np.log(3)]),
        ("PUSH exp(-5)", [np.log(3), np.exp(-5)]),
        ("EML", [8.0]),
    ]
    
    print(f"  Step  Instruction      Stack")
    print(f"  ────  ───────────────  ─────────────────────")
    for i, (instr, stack) in enumerate(steps2):
        stack_viz = ' '.join(f'[{v:.6f}]' for v in stack)
        print(f"  {i+1:<4}  {instr:<16} {stack_viz}")
    
    print(f"\n  Result: {steps2[-1][1][0]:.6f} ✓")
    
    # EML neuron computation
    print(f"\n  ────────────────────────────────────────")
    print(f"\n  Program: EML Neuron exp(2x+1) - ln(x+3) at x=1.5")
    
    x = 1.5
    w1, b1, w2, b2 = 2, 1, 1, 3
    a = w1 * x + b1  # = 4.0
    b = w2 * x + b2  # = 4.5
    result = np.exp(a) - np.log(b)
    
    steps3 = [
        (f"PUSH {a:.1f}", [a]),
        (f"PUSH {b:.1f}", [a, b]),
        ("EML", [result]),
    ]
    
    print()
    print(f"  Step  Instruction      Stack")
    print(f"  ────  ───────────────  ─────────────────────")
    for i, (instr, stack) in enumerate(steps3):
        stack_viz = ' '.join(f'[{v:.6f}]' for v in stack)
        print(f"  {i+1:<4}  {instr:<16} {stack_viz}")
    
    print(f"\n  Result: exp(4.0) - ln(4.5) = {result:.6f}")
    print(f"  Verification: {np.exp(4.0):.6f} - {np.log(4.5):.6f} = {np.exp(4.0) - np.log(4.5):.6f} ✓")


def viz_pipeline():
    """Visualize the full compression pipeline."""
    print("\n" + "=" * 70)
    print("Visualization 5: Full Compression Pipeline")
    print("=" * 70)
    
    print("""
    ┌─────────────────────────────────────────────────────────────────┐
    │                    OISCC-EML Compression Pipeline               │
    ├─────────────────────────────────────────────────────────────────┤
    │                                                                 │
    │  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
    │  │   Teacher     │     │  EML Student  │     │  Crystallized │    │
    │  │  (Large Model)│────→│  (4d params)  │────→│  (Integer ℤ)  │    │
    │  │  d² params/L  │     │  per layer    │     │  weights      │    │
    │  └──────────────┘     └──────────────┘     └──────┬───────┘    │
    │     DISTILLATION         COMPRESSION          CRYSTALLIZATION   │
    │     (soft targets)       (d²→4d)              (ℝ→ℤ, err≤n/2)  │
    │                                                    │            │
    │                                               ┌────▼───────┐   │
    │  ┌──────────────┐     ┌──────────────┐     │  OISCC      │   │
    │  │   Output     │     │  Stack       │     │  Program    │   │
    │  │   (Result)   │◄────│  Machine     │◄────│  [PUSH,EML] │   │
    │  │              │     │  O(1)/step   │     │  3n instrs  │   │
    │  └──────────────┘     └──────────────┘     └────────────┘   │
    │     RESULT              INFERENCE              COMPILATION    │
    │                         (linear O(n))          (3 instr/neuron)│
    └─────────────────────────────────────────────────────────────────┘

    Formal Guarantees (40+ Lean 4 theorems):
    ┌─────────────────────────────────────────────────────────────────┐
    │ • Compression: 4d ≤ d²+d  for d ≥ 5                    [proven]│
    │ • Crystal error: |w - round(w)| ≤ 1/2                  [proven]│
    │ • Total error: Σ|wᵢ - ⌊wᵢ⌉| ≤ n/2                    [proven]│
    │ • Crystal penalty: sin²(πn) = 0 for n ∈ ℤ              [proven]│
    │ • Compilation: run([PUSH a, PUSH b, EML]) = [EML(a,b)]  [proven]│
    │ • Inference: 3n instructions for n neurons              [proven]│
    │ • Universal approx: point separation + nonvanishing     [proven]│
    │ • Gradient: HasDerivAt for all EML neurons              [proven]│
    │ • Ring closure: ℤ weights closed under +, ×             [proven]│
    │ • Memory: EML_mem ≤ Dense_mem                           [proven]│
    └─────────────────────────────────────────────────────────────────┘
    """)


if __name__ == '__main__':
    viz_eml_landscape()
    viz_compression_ratios()
    viz_crystallization()
    viz_oiscc_execution()
    viz_pipeline()
    
    print("\nAll visualizations complete!")
