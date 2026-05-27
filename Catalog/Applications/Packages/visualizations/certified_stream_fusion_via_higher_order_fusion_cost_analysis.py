#!/usr/bin/env python3
"""
Visualization: Stream Fusion Cost Reduction

Visualizes how administrative complexity decreases during fusion normalization
for pipelines of increasing depth. Produces a plot showing:
1. Admin cost before/after fusion vs pipeline depth
2. Number of fusion steps vs pipeline depth
3. Cost savings (admin nodes eliminated)
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass, field
from typing import Optional, List


# Inline all needed types and functions
class TermKind(Enum):
    VAR = auto()
    STREAM = auto()
    UNSTREAM = auto()
    SMAP = auto()
    SFILTER = auto()
    COMP = auto()
    FOLDR = auto()

@dataclass
class Term:
    kind: TermKind
    children: list = field(default_factory=list)
    var_id: Optional[int] = None

def var(n): return Term(TermKind.VAR, var_id=n)
def stream(t): return Term(TermKind.STREAM, [t])
def unstream(t): return Term(TermKind.UNSTREAM, [t])
def smap(f, t): return Term(TermKind.SMAP, [f, t])

def admin_count(t):
    if t.kind == TermKind.VAR: return 0
    if t.kind in (TermKind.STREAM, TermKind.UNSTREAM):
        return 1 + admin_count(t.children[0])
    return sum(admin_count(c) for c in t.children)

def has_redex(t):
    if t.kind == TermKind.STREAM and t.children[0].kind == TermKind.UNSTREAM:
        return True
    if t.kind == TermKind.VAR: return False
    return any(has_redex(c) for c in t.children)

def reduce_once(t):
    if t.kind == TermKind.STREAM and t.children[0].kind == TermKind.UNSTREAM:
        return t.children[0].children[0]
    if t.kind == TermKind.VAR: return None
    if t.kind == TermKind.STREAM:
        r = reduce_once(t.children[0])
        return Term(TermKind.STREAM, [r]) if r else None
    if t.kind == TermKind.UNSTREAM:
        r = reduce_once(t.children[0])
        return Term(TermKind.UNSTREAM, [r]) if r else None
    for i, child in enumerate(t.children):
        r = reduce_once(child)
        if r is not None:
            nc = list(t.children); nc[i] = r
            return Term(t.kind, nc)
    return None

def normalize(t):
    steps = 0; current = t
    while True:
        result = reduce_once(current)
        if result is None: break
        current = result; steps += 1
    return current, steps


# Generate data
depths = list(range(1, 16))
admin_before = []
admin_after = []
step_counts = []

xs = var(0)
f = var(1)

for d in depths:
    term = xs
    for _ in range(d):
        term = unstream(smap(f, stream(term)))
    nf, steps = normalize(term)
    admin_before.append(admin_count(term))
    admin_after.append(admin_count(nf))
    step_counts.append(steps)

savings = [b - a for b, a in zip(admin_before, admin_after)]

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Admin cost before/after
ax1 = axes[0]
ax1.plot(depths, admin_before, 'o-', color='#e74c3c', linewidth=2,
         markersize=6, label='Before fusion')
ax1.plot(depths, admin_after, 's-', color='#27ae60', linewidth=2,
         markersize=6, label='After fusion')
ax1.fill_between(depths, admin_after, admin_before, alpha=0.15, color='#27ae60')
ax1.set_xlabel('Pipeline Depth', fontsize=12)
ax1.set_ylabel('Administrative Nodes', fontsize=12)
ax1.set_title('Admin Cost: Before vs After Fusion', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Steps required
ax2 = axes[1]
ax2.bar(depths, step_counts, color='#3498db', alpha=0.8, edgecolor='#2c3e50')
ax2.set_xlabel('Pipeline Depth', fontsize=12)
ax2.set_ylabel('Fusion Steps', fontsize=12)
ax2.set_title('Steps to Normalize', fontsize=13)
ax2.grid(True, alpha=0.3, axis='y')

# Plot 3: Cost savings
ax3 = axes[2]
ax3.plot(depths, savings, 'D-', color='#9b59b6', linewidth=2, markersize=6)
ax3.fill_between(depths, savings, alpha=0.2, color='#9b59b6')
ax3.set_xlabel('Pipeline Depth', fontsize=12)
ax3.set_ylabel('Nodes Eliminated', fontsize=12)
ax3.set_title('Administrative Cost Savings', fontsize=13)
ax3.grid(True, alpha=0.3)

# Add theorem annotation
ax3.annotate('Theorem: each step\nsaves ≥ 2 nodes',
            xy=(8, savings[7]), xytext=(10, savings[3]),
            arrowprops=dict(arrowstyle='->', color='#8e44ad'),
            fontsize=10, color='#8e44ad',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#f0e6ff'))

plt.suptitle('Certified Stream Fusion: Cost Analysis',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('fusion_cost_analysis.png', dpi=150, bbox_inches='tight')
print("Saved fusion_cost_analysis.png")
