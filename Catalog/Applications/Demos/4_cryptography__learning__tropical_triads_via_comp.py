#!/usr/bin/env python3
"""
Applications of Triadic Hardness Transport

Real-world application scenarios demonstrating how learning-theoretic
certificates transfer to cryptographic security bounds.
"""

import numpy as np


def triadic_transfer(B: float, constants: list[tuple[float, float]]) -> float:
    """
    General n-step affine transfer.
    
    Args:
        B: Learning lower bound
        constants: List of (c_i, a_i) pairs for each morphism
    
    Returns:
        Security lower bound after composing all morphisms
    """
    c_prod = 1.0
    a_total = 0.0
    for c, a in constants:
        a_total += c_prod * a
        c_prod *= c
    return (B - a_total) / c_prod


# ═══════════════════════════════════════════════════════════════
# Application 1: Neural Network Security Certification
# ═══════════════════════════════════════════════════════════════

def neural_network_security_audit():
    """
    Simulate a security audit for a neural network-based system.
    
    Scenario: A company deploys a neural network classifier that also 
    interfaces with a cryptographic authentication module. The question is:
    does the classifier's robustness guarantee any minimum security level?
    """
    print("=" * 65)
    print("APPLICATION 1: Neural Network Security Audit")
    print("=" * 65)
    print()
    
    # Network parameters
    layers = [
        {"name": "Conv1", "lipschitz": 0.8},
        {"name": "Conv2", "lipschitz": 0.9},
        {"name": "Conv3", "lipschitz": 0.7},
        {"name": "Dense1", "lipschitz": 0.85},
        {"name": "Dense2", "lipschitz": 0.95},
    ]
    margin = 3.5  # Measured classification margin
    
    # Compute total Lipschitz constant
    total_lip = 1.0
    for layer in layers:
        total_lip *= layer["lipschitz"]
    
    robustness_radius = margin / total_lip
    
    print(f"Network Architecture: {len(layers)} layers")
    for layer in layers:
        print(f"  {layer['name']:10s}: Lipschitz = {layer['lipschitz']}")
    print(f"\nTotal Lipschitz constant: {total_lip:.6f}")
    print(f"Classification margin:    {margin}")
    print(f"Certified robustness:     {robustness_radius:.4f}")
    
    # Transfer chain
    constants = [
        (1.2, 0.05),  # Learning → Arithmetic height
        (1.8, 0.03),  # Arithmetic height → Tropical dimension
        (1.0, 0.01),  # Tropical dimension → Security parameter
    ]
    
    security_bound = triadic_transfer(robustness_radius, constants)
    
    print(f"\nTransfer chain constants:")
    labels = ["Learning → Height", "Height → Tropical", "Tropical → Security"]
    for label, (c, a) in zip(labels, constants):
        print(f"  {label:25s}: c = {c}, a = {a}")
    
    print(f"\n{'─' * 50}")
    print(f"CERTIFIED SECURITY PARAMETER ≥ {security_bound:.4f}")
    print(f"{'─' * 50}")
    
    # Security level interpretation
    if security_bound >= 128:
        print("Security level: EXCELLENT (≥ 128-bit equivalent)")
    elif security_bound >= 80:
        print("Security level: GOOD (≥ 80-bit equivalent)")
    elif security_bound >= 40:
        print("Security level: MODERATE (≥ 40-bit equivalent)")
    else:
        print("Security level: INSUFFICIENT (< 40-bit equivalent)")


# ═══════════════════════════════════════════════════════════════
# Application 2: Depth Optimization for Security
# ═══════════════════════════════════════════════════════════════

def depth_optimization():
    """
    Find the optimal network depth that maximizes the security bound
    while maintaining training feasibility.
    """
    print()
    print("=" * 65)
    print("APPLICATION 2: Depth Optimization for Security")
    print("=" * 65)
    print()
    
    margin = 5.0
    K_per_layer = 0.85  # Per-layer Lipschitz constant
    
    constants = [
        (1.5, 0.1),
        (2.0, 0.05),
        (1.0, 0.02),
    ]
    
    print(f"Margin: {margin}")
    print(f"Per-layer Lipschitz: {K_per_layer}")
    print()
    
    print(f"{'Depth':>6} │ {'Eff. Lipschitz':>15} │ {'Robustness':>12} │ {'Security LB':>12}")
    print("─" * 55)
    
    best_depth = 1
    best_security = -np.inf
    
    for depth in range(1, 21):
        eff_lip = K_per_layer ** depth
        robustness = margin / eff_lip
        security = triadic_transfer(robustness, constants)
        
        if security > best_security:
            best_security = security
            best_depth = depth
        
        marker = " ◀ best so far" if depth == best_depth else ""
        print(f"{depth:6d} │ {eff_lip:15.8f} │ {robustness:12.2f} │ {security:12.4f}{marker}")
    
    print(f"\nConclusion: Security bound increases monotonically with depth")
    print(f"(because K < 1 means deeper = more contractive = more robust)")


# ═══════════════════════════════════════════════════════════════
# Application 3: Comparative Domain Analysis
# ═══════════════════════════════════════════════════════════════

def comparative_analysis():
    """
    Compare how different learning architectures translate to 
    different security bounds through the triadic chain.
    """
    print()
    print("=" * 65)
    print("APPLICATION 3: Comparative Architecture Analysis")
    print("=" * 65)
    print()
    
    architectures = [
        {"name": "Shallow MLP",      "margin": 2.0, "lip": 3.0,  "depth": 2},
        {"name": "Deep Conv (small)", "margin": 1.5, "lip": 0.9,  "depth": 8},
        {"name": "Deep Conv (large)", "margin": 4.0, "lip": 0.85, "depth": 12},
        {"name": "ResNet-50",         "margin": 3.0, "lip": 0.95, "depth": 50},
        {"name": "Transformer",       "margin": 5.0, "lip": 1.2,  "depth": 6},
    ]
    
    constants = [
        (1.5, 0.1),
        (2.0, 0.05),
        (1.0, 0.02),
    ]
    
    print(f"{'Architecture':>22} │ {'Margin':>7} │ {'K/layer':>8} │ {'Depth':>6} │ "
          f"{'Robust. Radius':>15} │ {'Security LB':>12}")
    print("─" * 85)
    
    for arch in architectures:
        if arch["lip"] < 1.0:
            eff_lip = arch["lip"] ** arch["depth"]
        else:
            eff_lip = arch["lip"] ** arch["depth"]
        
        radius = arch["margin"] / eff_lip
        security = triadic_transfer(radius, constants)
        
        print(f"{arch['name']:>22} │ {arch['margin']:7.1f} │ {arch['lip']:8.2f} │ "
              f"{arch['depth']:6d} │ {radius:15.4f} │ {security:12.4f}")
    
    print()
    print("Key insight: Contractive architectures (K < 1) with sufficient depth")
    print("produce the strongest security bounds, even with smaller margins.")


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    neural_network_security_audit()
    depth_optimization()
    comparative_analysis()


#!/usr/bin/env python3
"""
Triadic Hardness Transport — Interactive Demo

Demonstrates the core mathematical results with concrete numerical examples:
1. Affine bound composition (2-step and 3-step)
2. Lower-bound inversion
3. Triadic security transfer with explicit constants
4. Depth-enhanced security for contractive networks
"""

import numpy as np


def affine_compose_2(c1: float, a1: float, c2: float, a2: float) -> tuple[float, float]:
    """Compose two affine morphisms: (c1, a1) ∘ (c2, a2) → (c1*c2, a1 + c1*a2)"""
    return (c1 * c2, a1 + c1 * a2)


def affine_compose_3(c1: float, a1: float,
                     c2: float, a2: float,
                     c3: float, a3: float) -> tuple[float, float]:
    """Compose three affine morphisms into one."""
    c12, a12 = affine_compose_2(c1, a1, c2, a2)
    return affine_compose_2(c12, a12, c3, a3)


def security_lower_bound(B: float,
                         c1: float, a1: float,
                         c2: float, a2: float,
                         c3: float, a3: float) -> float:
    """
    Compute the security lower bound from the triadic transfer theorem.
    
    Given B ≤ learnInv, with three affine morphisms (ci, ai), returns:
        (B - a1 - c1*a2 - c1*c2*a3) / (c1*c2*c3)
    """
    numerator = B - a1 - c1 * a2 - c1 * c2 * a3
    denominator = c1 * c2 * c3
    return numerator / denominator


def depth_security(delta: float, K: float, L: int) -> float:
    """Compute robustness-derived security bound: δ / K^L"""
    return delta / (K ** L)


# ═══════════════════════════════════════════════════════════════
# Demo 1: Affine Composition
# ═══════════════════════════════════════════════════════════════
print("=" * 65)
print("DEMO 1: Affine Morphism Composition")
print("=" * 65)
print()

# Three morphisms with realistic constants
morphisms = [
    ("Learning → Height",   1.5, 0.10),
    ("Height → Tropical",   2.0, 0.05),
    ("Tropical → Security", 1.0, 0.02),
]

print("Individual morphisms (c_i, a_i):")
for name, c, a in morphisms:
    print(f"  {name}: c = {c}, a = {a}")

c_comp, a_comp = affine_compose_3(
    morphisms[0][1], morphisms[0][2],
    morphisms[1][1], morphisms[1][2],
    morphisms[2][1], morphisms[2][2],
)
print(f"\nComposed morphism (Learning → Security):")
print(f"  c = {c_comp:.4f}")
print(f"  a = {a_comp:.4f}")
print(f"  Meaning: learnInv ≤ {c_comp} · secInv + {a_comp}")

# ═══════════════════════════════════════════════════════════════
# Demo 2: Triadic Security Transfer
# ═══════════════════════════════════════════════════════════════
print()
print("=" * 65)
print("DEMO 2: Triadic Security Lower Bound")
print("=" * 65)
print()

learning_bounds = [5.0, 10.0, 20.0, 50.0, 100.0]
c1, a1 = 1.5, 0.10
c2, a2 = 2.0, 0.05
c3, a3 = 1.0, 0.02

print(f"Transfer constants: C₁={c1}, A₁={a1}, C₂={c2}, A₂={a2}, C₃={c3}, A₃={a3}")
print()
print(f"{'Learning LB':>12} │ {'Security LB':>12} │ {'Efficiency':>10}")
print("─" * 42)
for B in learning_bounds:
    sec = security_lower_bound(B, c1, a1, c2, a2, c3, a3)
    eff = sec / B * 100
    print(f"{B:12.2f} │ {sec:12.4f} │ {eff:9.1f}%")

print()
print("Note: Efficiency = (security LB) / (learning LB) × 100%")
print("As the learning lower bound grows, efficiency approaches 1/C₁C₂C₃ = "
      f"{1/(c1*c2*c3)*100:.1f}%")

# ═══════════════════════════════════════════════════════════════
# Demo 3: Depth-Enhanced Security
# ═══════════════════════════════════════════════════════════════
print()
print("=" * 65)
print("DEMO 3: Depth-Enhanced Security (Contractive Networks)")
print("=" * 65)
print()

delta = 2.0
K = 0.5

print(f"Parameters: δ = {delta}, K = {K} (contractive)")
print()
print(f"{'Depth L':>8} │ {'K^L':>12} │ {'δ/K^L':>12} │ {'Security LB':>12}")
print("─" * 52)
for L in range(1, 11):
    KL = K ** L
    rob = depth_security(delta, K, L)
    sec = security_lower_bound(rob, c1, a1, c2, a2, c3, a3)
    print(f"{L:8d} │ {KL:12.6f} │ {rob:12.2f} │ {sec:12.4f}")

# ═══════════════════════════════════════════════════════════════
# Demo 4: Margin-Lipschitz Security Certificate
# ═══════════════════════════════════════════════════════════════
print()
print("=" * 65)
print("DEMO 4: Margin-Lipschitz Security Certificate")
print("=" * 65)
print()

margins = [1.0, 2.0, 5.0, 10.0]
lipschitz_constants = [0.1, 0.5, 1.0, 2.0]

print(f"{'δ (margin)':>12} │ {'K (Lipschitz)':>14} │ {'δ/K (radius)':>13} │ {'Certified':>10}")
print("─" * 58)
for delta in margins:
    for K in lipschitz_constants:
        radius = delta / K
        eps = radius * 0.5  # test perturbation at half the radius
        robust = delta - K * eps >= 0
        print(f"{delta:12.2f} │ {K:14.2f} │ {radius:13.2f} │ {'✓' if robust else '✗':>10}")

print()
print("All entries are certified robust (δ - K·ε ≥ 0 for ε ≤ δ/K)")
print("The robustness radius δ/K directly bounds the security parameter")
print("through the triadic transfer chain.")

# ═══════════════════════════════════════════════════════════════
# Demo 5: Sensitivity Analysis
# ═══════════════════════════════════════════════════════════════
print()
print("=" * 65)
print("DEMO 5: Sensitivity Analysis — How Constants Affect Transfer")
print("=" * 65)
print()

B = 50.0
print(f"Fixed learning lower bound B = {B}")
print()

# Vary C₁
print("Varying C₁ (learning-to-height stretch):")
print(f"{'C₁':>8} │ {'Security LB':>12}")
print("─" * 24)
for c1_var in [0.5, 1.0, 1.5, 2.0, 3.0, 5.0]:
    sec = security_lower_bound(B, c1_var, a1, c2, a2, c3, a3)
    print(f"{c1_var:8.1f} │ {sec:12.4f}")

print()
print("Key insight: larger C₁ (more distortion in the first morphism)")
print("reduces the final security bound, since the denominator grows as C₁·C₂·C₃.")


#!/usr/bin/env python3
"""
Visualizations for Triadic Hardness Transport

Generates publication-quality figures showing:
1. Transfer chain diagram
2. Security bound vs. learning bound
3. Depth-security relationship
4. Sensitivity heatmap
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def security_lower_bound(B, c1, a1, c2, a2, c3, a3):
    num = B - a1 - c1*a2 - c1*c2*a3
    den = c1 * c2 * c3
    return num / den


# ═══════════════════════════════════════════════════════════════
# Figure 1: Security Bound vs Learning Lower Bound
# ═══════════════════════════════════════════════════════════════

def plot_security_vs_learning():
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    
    B = np.linspace(0.5, 100, 500)
    
    configs = [
        ((1.0, 0.0, 1.0, 0.0, 1.0, 0.0), "Identity (no distortion)", "#2196F3"),
        ((1.5, 0.1, 2.0, 0.05, 1.0, 0.02), "Moderate (C₁=1.5, C₂=2.0)", "#4CAF50"),
        ((2.0, 0.2, 3.0, 0.1, 1.5, 0.05), "Aggressive (C₁=2, C₂=3, C₃=1.5)", "#FF9800"),
        ((5.0, 0.5, 5.0, 0.5, 2.0, 0.1), "Lossy (C₁=5, C₂=5, C₃=2)", "#F44336"),
    ]
    
    for params, label, color in configs:
        sec = security_lower_bound(B, *params)
        ax.plot(B, sec, label=label, color=color, linewidth=2)
    
    ax.set_xlabel("Learning Lower Bound (B)", fontsize=12)
    ax.set_ylabel("Security Lower Bound", fontsize=12)
    ax.set_title("Triadic Transfer: How Learning Bounds Map to Security", fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 100)
    ax.axhline(y=0, color='black', linewidth=0.5)
    
    fig.savefig('/workspace/request-project/fig_security_vs_learning.png', 
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Figure 2: Depth-Enhanced Security
# ═══════════════════════════════════════════════════════════════

def plot_depth_security():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: robustness radius vs depth
    depths = np.arange(1, 16)
    delta = 2.0
    K_values = [0.5, 0.7, 0.85, 0.95]
    
    for K in K_values:
        radii = delta / (K ** depths)
        ax1.semilogy(depths, radii, 'o-', label=f"K = {K}", markersize=5)
    
    ax1.set_xlabel("Network Depth (L)", fontsize=12)
    ax1.set_ylabel("Robustness Radius (δ/K^L)", fontsize=12)
    ax1.set_title("Robustness Grows with Depth\n(for contractive networks, K < 1)", fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: security bound vs depth
    c1, a1 = 1.5, 0.1
    c2, a2 = 2.0, 0.05
    c3, a3 = 1.0, 0.02
    
    for K in K_values:
        radii = delta / (K ** depths)
        sec = security_lower_bound(radii, c1, a1, c2, a2, c3, a3)
        ax2.semilogy(depths, sec, 's-', label=f"K = {K}", markersize=5)
    
    ax2.set_xlabel("Network Depth (L)", fontsize=12)
    ax2.set_ylabel("Security Lower Bound", fontsize=12)
    ax2.set_title("Security Bound After Triadic Transfer", fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_depth_security.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Figure 3: Transfer Chain Diagram
# ═══════════════════════════════════════════════════════════════

def plot_transfer_chain():
    fig, ax = plt.subplots(1, 1, figsize=(12, 4))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-1.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Domain boxes
    domains = [
        (1.0, 0.5, "Learning\nTheory", "#E3F2FD", "#1565C0"),
        (3.5, 0.5, "Arithmetic\nHeight", "#E8F5E9", "#2E7D32"),
        (6.0, 0.5, "Tropical\nGeometry", "#FFF3E0", "#E65100"),
        (8.5, 0.5, "Cryptographic\nSecurity", "#FCE4EC", "#C62828"),
    ]
    
    for x, y, label, facecolor, edgecolor in domains:
        rect = mpatches.FancyBboxPatch(
            (x - 0.8, y - 0.5), 1.6, 1.0,
            boxstyle="round,pad=0.1",
            facecolor=facecolor, edgecolor=edgecolor, linewidth=2
        )
        ax.add_patch(rect)
        ax.text(x, y, label, ha='center', va='center', fontsize=10, fontweight='bold',
                color=edgecolor)
    
    # Arrows with labels
    arrows = [
        (1.8, 0.5, 2.7, 0.5, "(C₁, A₁)", "#666"),
        (4.3, 0.5, 5.2, 0.5, "(C₂, A₂)", "#666"),
        (6.8, 0.5, 7.7, 0.5, "(C₃, A₃)", "#666"),
    ]
    
    for x1, y1, x2, y2, label, color in arrows:
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle="-|>", color=color, lw=2))
        ax.text((x1+x2)/2, y1 + 0.35, label, ha='center', fontsize=9,
                color=color, style='italic')
    
    # Composed arrow at bottom
    ax.annotate("", xy=(8.5, -0.7), xytext=(1.0, -0.7),
                arrowprops=dict(arrowstyle="-|>", color="#9C27B0", lw=2.5,
                               connectionstyle="arc3,rad=0.15"))
    ax.text(4.75, -1.15, "Composed: (C₁C₂C₃,  A₁ + C₁A₂ + C₁C₂A₃)", 
            ha='center', fontsize=10, color="#9C27B0", fontweight='bold')
    
    # Title
    ax.text(4.75, 1.8, "Triadic Hardness Transport Chain", ha='center',
            fontsize=14, fontweight='bold', color='#333')
    ax.text(4.75, 1.4, "Lower bounds propagate left-to-right through composable affine morphisms",
            ha='center', fontsize=10, color='#666', style='italic')
    
    fig.savefig('/workspace/request-project/fig_transfer_chain.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Figure 4: Sensitivity Heatmap
# ═══════════════════════════════════════════════════════════════

def plot_sensitivity_heatmap():
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    c1_vals = np.linspace(0.5, 5.0, 50)
    c2_vals = np.linspace(0.5, 5.0, 50)
    
    B = 50.0
    a1, a2, a3 = 0.1, 0.05, 0.02
    c3 = 1.0
    
    C1, C2 = np.meshgrid(c1_vals, c2_vals)
    Z = security_lower_bound(B, C1, a1, C2, a2, c3, a3)
    
    im = ax.contourf(C1, C2, Z, levels=30, cmap='RdYlGn')
    contours = ax.contour(C1, C2, Z, levels=[5, 10, 15, 20, 25], colors='black',
                          linewidths=0.5)
    ax.clabel(contours, inline=True, fontsize=8, fmt='%.0f')
    
    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label('Security Lower Bound', fontsize=11)
    
    ax.set_xlabel('C₁ (Learning → Height stretch)', fontsize=12)
    ax.set_ylabel('C₂ (Height → Tropical stretch)', fontsize=12)
    ax.set_title(f'Security Bound vs. Transfer Constants\n(B = {B}, C₃ = {c3})', fontsize=13)
    
    fig.savefig('/workspace/request-project/fig_sensitivity.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Generate all figures
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating figures...")
    
    b64_1 = plot_security_vs_learning()
    print(f"  fig_security_vs_learning.png — {len(b64_1)} chars")
    
    b64_2 = plot_depth_security()
    print(f"  fig_depth_security.png — {len(b64_2)} chars")
    
    b64_3 = plot_transfer_chain()
    print(f"  fig_transfer_chain.png — {len(b64_3)} chars")
    
    b64_4 = plot_sensitivity_heatmap()
    print(f"  fig_sensitivity.png — {len(b64_4)} chars")
    
    print("\nAll figures generated successfully.")
    
    # Save base64 data for JSON package
    with open('/workspace/request-project/viz_data.txt', 'w') as f:
        f.write("FIGURE_1_B64\n")
        f.write(b64_1 + "\n")
        f.write("FIGURE_2_B64\n")
        f.write(b64_2 + "\n")
        f.write("FIGURE_3_B64\n")
        f.write(b64_3 + "\n")
        f.write("FIGURE_4_B64\n")
        f.write(b64_4 + "\n")
