#!/usr/bin/env python3
"""
Entropic Decay Dynamics (EDD) — The Mathematics of Ubik
========================================================
Inspired by Philip K. Dick's Ubik (1969).

This demo simulates:
1. Super-linear reality decay and finite-time collapse
2. The Ubik Stabilizer: existence and uniqueness
3. Archaeological ordering of object reversion
4. Half-life consciousness decay in cold-pac

Run: python ubik_decay.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import matplotlib.patches as mpatches


def ubik_decay(C0, alpha, beta, t_array):
    """
    Solve dC/dt = -α·C^β analytically.
    For β > 1: C(t) = (C0^(1-β) + α(β-1)t)^(1/(1-β))
    Collapses to 0 at T_collapse = C0^(1-β) / (α(β-1))
    """
    T_collapse = C0 ** (1 - beta) / (alpha * (beta - 1))
    C = np.zeros_like(t_array, dtype=float)
    for i, t in enumerate(t_array):
        if t < T_collapse:
            inner = C0 ** (1 - beta) + alpha * (beta - 1) * t
            if inner > 0:
                C[i] = inner ** (1 / (1 - beta))
            else:
                C[i] = 0
        else:
            C[i] = 0
    return C, T_collapse


def ubik_stabilized(C0, alpha, beta, C_target, t_array):
    """
    Solve dC/dt = -α·C^β + u*(t)
    where u*(t) = α·C_target^β (the Ubik stabilizer).
    After reaching C_target, capacity stays constant.
    """
    u_star = alpha * C_target ** beta
    dt = t_array[1] - t_array[0]
    C = np.zeros_like(t_array, dtype=float)
    C[0] = C0

    for i in range(1, len(t_array)):
        dCdt = -alpha * C[i - 1] ** beta + u_star
        C[i] = max(C[i - 1] + dCdt * dt, 0)

    return C, u_star


def demo_finite_time_collapse():
    """Demo 1: Super-linear decay causes finite-time collapse."""
    print("=" * 60)
    print("DEMO 1: FINITE-TIME REALITY COLLAPSE")
    print("Super-linear decay (β > 1) → reality reaches zero in finite time")
    print("=" * 60)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    t = np.linspace(0, 5, 1000)
    C0 = 1.0
    alpha = 0.5

    # Compare different β values
    ax = axes[0]
    betas = [1.0, 1.5, 2.0, 2.5, 3.0]
    colors = plt.cm.inferno(np.linspace(0.2, 0.9, len(betas)))

    for beta, color in zip(betas, colors):
        if beta == 1.0:
            # Linear decay: exponential
            C = C0 * np.exp(-alpha * t)
            T_c = float('inf')
            label = f'β=1.0 (exponential, T_collapse=∞)'
        else:
            C, T_c = ubik_decay(C0, alpha, beta, t)
            label = f'β={beta:.1f} (T_collapse={T_c:.2f})'

        ax.plot(t, C, color=color, linewidth=2.5, label=label)
        if T_c < 5:
            ax.axvline(x=T_c, color=color, linestyle=':', alpha=0.5)
            ax.plot(T_c, 0, 'v', color=color, markersize=12)

    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Reality Channel Capacity C(t)', fontsize=12)
    ax.set_title('Ubik Decay: Linear vs Super-Linear', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.1)

    # Collapse time as function of β
    ax = axes[1]
    beta_range = np.linspace(1.01, 4.0, 200)
    T_collapses = [C0 ** (1 - b) / (alpha * (b - 1)) for b in beta_range]

    ax.plot(beta_range, T_collapses, 'r-', linewidth=2.5)
    ax.fill_between(beta_range, 0, T_collapses, alpha=0.1, color='red')
    ax.set_xlabel('Decay Exponent β', fontsize=12)
    ax.set_ylabel('Collapse Time T_collapse', fontsize=12)
    ax.set_title('How Fast Does Reality Die?', fontsize=12)
    ax.set_ylim(0, 10)
    ax.grid(True, alpha=0.3)

    # Annotate
    ax.annotate('Ubik β ≈ 2:\nReality collapses\nin finite time',
                xy=(2.0, C0 ** (1 - 2.0) / (alpha * (2.0 - 1))),
                xytext=(2.8, 5), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='darkred'),
                color='darkred')

    plt.suptitle('UBIK: Finite-Time Reality Collapse Under Super-Linear Decay',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo5_ubik_collapse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo5_ubik_collapse.png")
    _, T_c = ubik_decay(1.0, 0.5, 2.0, t)
    print(f"  With β=2.0, α=0.5: T_collapse = {T_c:.4f}")
    print(f"  Formula: T = C₀^(1-β) / [α(β-1)] = 1.0^(-1) / [0.5·1] = {T_c:.4f}")
    print()


def demo_ubik_stabilizer():
    """Demo 2: The Ubik Stabilizer — existence and uniqueness."""
    print("=" * 60)
    print("DEMO 2: THE UBIK STABILIZER")
    print("The unique optimal intervention that halts reality decay")
    print("=" * 60)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    t = np.linspace(0, 5, 2000)
    C0, alpha, beta = 1.0, 0.5, 2.0

    ax = axes[0]
    # Without Ubik
    C_decay, T_c = ubik_decay(C0, alpha, beta, t)
    ax.plot(t, C_decay, 'r-', linewidth=2.5, label='Without Ubik (collapse)')
    ax.axvline(x=T_c, color='red', linestyle=':', alpha=0.5)

    # With Ubik at different target levels
    targets = [0.8, 0.5, 0.3, 0.1]
    colors = plt.cm.Greens(np.linspace(0.3, 0.9, len(targets)))

    for C_target, color in zip(targets, colors):
        C_stab, u_star = ubik_stabilized(C0, alpha, beta, C_target, t)
        ax.plot(t, C_stab, color=color, linewidth=2,
                label=f'Ubik (target={C_target}, u*={u_star:.3f})')

    ax.set_xlabel('Time', fontsize=12)
    ax.set_ylabel('Reality Capacity C(t)', fontsize=12)
    ax.set_title('The Ubik Spray: Stabilizing Reality', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.1)

    # Ubik dosage curve
    ax = axes[1]
    C_targets = np.linspace(0.01, 1.0, 200)
    u_stars = alpha * C_targets ** beta
    ax.plot(C_targets, u_stars, 'green', linewidth=2.5)
    ax.fill_between(C_targets, 0, u_stars, alpha=0.1, color='green')
    ax.set_xlabel('Target Reality Level C_target', fontsize=12)
    ax.set_ylabel('Required Ubik Dosage u*', fontsize=12)
    ax.set_title('Ubik Dosage: u* = α · C_target^β', fontsize=12)
    ax.grid(True, alpha=0.3)

    ax.annotate('Higher reality quality\nrequires more Ubik',
                xy=(0.8, alpha * 0.8 ** beta), xytext=(0.3, 0.4),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='darkgreen'),
                color='darkgreen')

    plt.suptitle('UBIK: The Unique Optimal Stabilizer (Theorem 3.2)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo6_ubik_stabilizer.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo6_ubik_stabilizer.png")
    print(f"  Ubik stabilizer formula: u* = α · C_target^β")
    print(f"  For C_target=0.5: u* = {alpha * 0.5 ** beta:.4f}")
    print(f"  For C_target=0.8: u* = {alpha * 0.8 ** beta:.4f}")
    print(f"  Theorem: this stabilizer is UNIQUE and L²-optimal")
    print()


def demo_archaeological_ordering():
    """Demo 3: Objects decay in strict chronological order."""
    print("=" * 60)
    print("DEMO 3: ARCHAEOLOGICAL ORDERING")
    print("High-tech objects revert to historical forms in strict order")
    print("=" * 60)

    # Objects with their information content and era
    objects = [
        ('Smartphone (2024)', 1.0, 2024),
        ('Laptop (2005)', 0.85, 2005),
        ('TV (1960)', 0.55, 1960),
        ('Radio (1925)', 0.35, 1925),
        ('Telegraph (1845)', 0.15, 1845),
        ('Quill Pen (1400)', 0.05, 1400),
    ]

    t = np.linspace(0, 3, 1000)
    alpha, beta = 0.5, 2.0

    fig, ax = plt.subplots(figsize=(12, 7))
    colors = plt.cm.coolwarm(np.linspace(0.1, 0.9, len(objects)))

    for (name, C0, era), color in zip(objects, colors):
        C, T_c = ubik_decay(C0, alpha, beta, t)
        ax.plot(t, C, color=color, linewidth=2.5, label=f'{name}')
        ax.plot(T_c, 0, 'v', color=color, markersize=10)
        ax.annotate(f'  Dies: t={T_c:.2f}', xy=(T_c, 0.02),
                    fontsize=8, color=color, rotation=45)

    # Draw horizontal lines showing reversion thresholds
    for i in range(len(objects) - 1):
        ax.axhline(y=objects[i + 1][1], color='gray', linestyle=':', alpha=0.3)
        ax.text(3.05, objects[i + 1][1], f'← {objects[i + 1][0]} level',
                fontsize=7, va='center', color='gray')

    ax.set_xlabel('Time Since Decay Began', fontsize=12)
    ax.set_ylabel('Information Content', fontsize=12)
    ax.set_title('Archaeological Ordering: High-Tech Dies First', fontsize=13)
    ax.legend(loc='upper right', fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 3.5)
    ax.set_ylim(-0.05, 1.1)

    # Add annotation
    ax.annotate('A smartphone reverts through\nlaptop → TV → radio → telegraph\nbefore a radio reaches telegraph level',
                xy=(0.8, 0.5), xytext=(1.5, 0.85), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8),
                arrowprops=dict(arrowstyle='->', color='black'))

    plt.suptitle('UBIK: Objects Decay in Strict Archaeological Order (Theorem 3.3)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo7_archaeological_ordering.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo7_archaeological_ordering.png")
    print("  Objects decay to historical predecessors in strict chronological order:")
    for name, C0, era in objects:
        _, T_c = ubik_decay(C0, alpha, beta, t)
        print(f"    {name}: T_collapse = {T_c:.4f}")
    print()


def demo_cold_pac_consciousness():
    """Demo 4: Half-life consciousness decay in cold-pac."""
    print("=" * 60)
    print("DEMO 4: COLD-PAC HALF-LIFE")
    print("Consciousness decay in cryonic suspension (Ubik ch. 1-3)")
    print("=" * 60)

    # Multiple people in cold-pac with different initial consciousness levels
    np.random.seed(42)
    n_people = 6
    names = ['Runciter', 'Jory', 'Ella', 'Von Vogelsang', 'Al', 'Wendy']
    C0s = [0.95, 0.8, 0.7, 0.5, 0.3, 0.15]

    t = np.linspace(0, 4, 1000)
    alpha, beta = 0.3, 1.8

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Individual decay curves
    ax = axes[0]
    colors = plt.cm.Set2(np.linspace(0, 1, n_people))
    collapse_times = []

    for i, (name, C0) in enumerate(zip(names, C0s)):
        C, T_c = ubik_decay(C0, alpha, beta, t)
        ax.plot(t, C, color=colors[i], linewidth=2.5, label=f'{name} (C₀={C0})')
        collapse_times.append(T_c)

    # Communication threshold
    comm_threshold = 0.2
    ax.axhline(y=comm_threshold, color='red', linestyle='--', alpha=0.7,
               label=f'Communication threshold ({comm_threshold})')
    ax.fill_between(t, 0, comm_threshold, alpha=0.05, color='red')
    ax.set_xlabel('Time in Cold-Pac', fontsize=12)
    ax.set_ylabel('Consciousness Level', fontsize=12)
    ax.set_title('Individual Consciousness Decay', fontsize=12)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)

    # Jory's parasitic absorption
    ax = axes[1]
    # Jory grows by absorbing others' decaying consciousness
    jory_base, _ = ubik_decay(0.8, alpha, beta, t)
    total_consciousness = np.zeros_like(t)

    for C0 in C0s:
        C, _ = ubik_decay(C0, alpha, beta, t)
        total_consciousness += C

    jory_parasitic = jory_base + 0.2 * (total_consciousness - jory_base)
    jory_parasitic = np.clip(jory_parasitic, 0, 1.5)

    ax.plot(t, total_consciousness / n_people, 'b-', linewidth=2,
            label='Average consciousness', alpha=0.7)
    ax.plot(t, jory_parasitic, 'r-', linewidth=2.5,
            label="Jory (parasitic: absorbs others')")
    ax.fill_between(t, jory_base, jory_parasitic, alpha=0.15, color='red',
                     label='Stolen consciousness')
    ax.set_xlabel('Time in Cold-Pac', fontsize=12)
    ax.set_ylabel('Consciousness Level', fontsize=12)
    ax.set_title("Jory's Parasitic Absorption", fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.suptitle('UBIK: Cold-Pac Half-Life and Parasitic Consciousness',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demo8_cold_pac.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo8_cold_pac.png")
    print("  Consciousness decay follows super-linear dynamics:")
    for name, T_c in zip(names, collapse_times):
        print(f"    {name}: consciousness extinguished at t = {T_c:.3f}")
    print("  Jory's parasitic absorption: ∫(others' decay) feeds his consciousness")
    print()


if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  ENTROPIC DECAY DYNAMICS — THE MATHEMATICS OF UBIK         ║")
    print("║  'I am Ubik. Before the universe was, I am.'               ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_finite_time_collapse()
    demo_ubik_stabilizer()
    demo_archaeological_ordering()
    demo_cold_pac_consciousness()

    print("=" * 60)
    print("ALL UBIK DEMOS COMPLETE")
    print("'Use only as directed.' — Ubik")
    print("=" * 60)
