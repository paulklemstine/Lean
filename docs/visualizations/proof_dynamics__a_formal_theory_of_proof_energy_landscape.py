#!/usr/bin/env python3
"""
Visualization: Proof Energy Landscape

Visualizes the energy descent along proof refinement trajectories,
showing how complexity monotonically decreases like a physical system
cooling to its ground state. Multiple proof sketches are shown as
separate trajectories converging toward minimal-energy normal forms.

This demonstrates the discrete Lyapunov theorem: no periodic orbits
exist because energy strictly decreases at each refinement step.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass
from typing import Optional


# ── Self-contained proof sketch implementation ────────────────

class TheoremLabel(Enum):
    IrrationalSqrt2 = auto()
    EvenPlusEvenEven = auto()
    DvdTrans = auto()
    ParityLemma = auto()

@dataclass
class ProofSketch: pass

@dataclass
class Axiom(ProofSketch):
    label: TheoremLabel

@dataclass
class Lemma(ProofSketch):
    label: TheoremLabel
    sub: ProofSketch

@dataclass
class Trans(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Cases(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Redundant(ProofSketch):
    inner: ProofSketch

@dataclass
class Duplicate(ProofSketch):
    inner: ProofSketch

def size(p):
    if isinstance(p, Axiom): return 1
    if isinstance(p, Lemma): return 1 + size(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + size(p.left) + size(p.right)
    if isinstance(p, (Redundant, Duplicate)): return 1 + size(p.inner)

def depth(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + depth(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + max(depth(p.left), depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 1 + depth(p.inner)

def lemma_count(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + lemma_count(p.sub)
    if isinstance(p, (Trans, Cases)): return lemma_count(p.left) + lemma_count(p.right)
    if isinstance(p, (Redundant, Duplicate)): return lemma_count(p.inner)

def score(p): return size(p) + depth(p) + lemma_count(p)

def step_once(p):
    if isinstance(p, Redundant): return p.inner
    if isinstance(p, Duplicate): return p.inner
    if isinstance(p, Lemma):
        if isinstance(p.sub, Redundant): return Lemma(p.label, p.sub.inner)
        if isinstance(p.sub, Axiom): return Axiom(p.label)
        s = step_once(p.sub)
        return Lemma(p.label, s) if s else None
    if isinstance(p, Trans):
        s = step_once(p.left)
        if s: return Trans(s, p.right)
        s = step_once(p.right)
        return Trans(p.left, s) if s else None
    if isinstance(p, Cases):
        s = step_once(p.left)
        if s: return Cases(s, p.right)
        s = step_once(p.right)
        return Cases(p.left, s) if s else None
    return None

def get_scores(p):
    scores = [score(p)]
    while True:
        nxt = step_once(p)
        if nxt is None: return scores
        p = nxt
        scores.append(score(p))


# ── Build trajectories ───────────────────────────────────────

trajectories = {
    "√2 bloated": Redundant(Duplicate(Redundant(
        Lemma(TheoremLabel.IrrationalSqrt2,
            Trans(Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)),
                  Duplicate(Axiom(TheoremLabel.DvdTrans))))))),
    "Deep nesting": Redundant(Redundant(Redundant(Redundant(
        Redundant(Axiom(TheoremLabel.ParityLemma)))))),
    "Duplicate chain": Duplicate(Duplicate(Duplicate(
        Axiom(TheoremLabel.DvdTrans)))),
    "Mixed": Lemma(TheoremLabel.EvenPlusEvenEven,
        Redundant(Duplicate(
            Lemma(TheoremLabel.DvdTrans,
                Axiom(TheoremLabel.ParityLemma))))),
}


# ── Create figure ─────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

# Left panel: Energy trajectories
for (name, sketch), color in zip(trajectories.items(), colors):
    scores = get_scores(sketch)
    steps = list(range(len(scores)))
    ax1.plot(steps, scores, 'o-', color=color, linewidth=2,
             markersize=8, label=name, alpha=0.85)
    # Mark normal form (ground state)
    ax1.plot(steps[-1], scores[-1], 's', color=color,
             markersize=12, markeredgecolor='black', markeredgewidth=1.5,
             zorder=5)

ax1.set_xlabel('Refinement Step', fontsize=13)
ax1.set_ylabel('Energy (Complexity Score)', fontsize=13)
ax1.set_title('Energy Descent: Proof Refinement Trajectories', fontsize=14,
              fontweight='bold')
ax1.legend(fontsize=10, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0)

# Annotate ground state region
ax1.axhspan(0, 2, color='#2ecc71', alpha=0.1)
ax1.text(0.5, 1.5, 'Ground States\n(Normal Forms)', fontsize=9,
         ha='center', style='italic', color='#27ae60')

# Right panel: Energy drops per step (bar chart)
ax2_data = []
for (name, sketch), color in zip(trajectories.items(), colors):
    scores = get_scores(sketch)
    drops = [scores[i] - scores[i+1] for i in range(len(scores)-1)]
    ax2_data.append((name, drops, color))

max_steps = max(len(d[1]) for d in ax2_data)
bar_width = 0.2
for idx, (name, drops, color) in enumerate(ax2_data):
    x = np.arange(len(drops)) + idx * bar_width
    ax2.bar(x, drops, bar_width, color=color, alpha=0.7,
            label=name, edgecolor='black', linewidth=0.5)

ax2.set_xlabel('Step Index', fontsize=13)
ax2.set_ylabel('Energy Drop (ΔE)', fontsize=13)
ax2.set_title('Energy Dissipation per Step', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3, axis='y')

# Annotate: all drops > 0 ⟹ Lyapunov
ax2.text(0.98, 0.95, 'All ΔE > 0 ⟹ Lyapunov\n(no periodic orbits)',
         transform=ax2.transAxes, fontsize=9, ha='right', va='top',
         style='italic', color='#c0392b',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='#fadbd8', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")
