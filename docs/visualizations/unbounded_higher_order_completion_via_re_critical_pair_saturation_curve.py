#!/usr/bin/env python3
"""
Visualization: Critical Pair Saturation Curve

Shows how the number of critical pairs grows with the size bound N,
and where stabilization occurs. The flat region after stabilization
is what our theorem exploits to prove global confluence.

Uses only matplotlib (no local imports).
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass


# ============================================================================
# Inline term algebra (fully self-contained)
# ============================================================================

@dataclass(frozen=True)
class Var:
    index: int
    def size(self): return 1

@dataclass(frozen=True)
class App:
    func: 'Term'
    arg: 'Term'
    def size(self): return 1 + self.func.size() + self.arg.size()

@dataclass(frozen=True)
class Lam:
    body: 'Term'
    def size(self): return 1 + self.body.size()

Term = Var | App | Lam

@dataclass
class Rule:
    lhs: Term
    rhs: Term
    name: str = ""

def subterms(t):
    result = [t]
    if isinstance(t, App):
        result.extend(subterms(t.func))
        result.extend(subterms(t.arg))
    elif isinstance(t, Lam):
        result.extend(subterms(t.body))
    return result

def syn_match(p, t):
    if isinstance(p, Var) or isinstance(t, Var): return True
    if type(p) != type(t): return False
    if isinstance(p, App): return syn_match(p.func, t.func) and syn_match(p.arg, t.arg)
    if isinstance(p, Lam): return syn_match(p.body, t.body)
    return False

def enum_cps(rules, N):
    pairs, seen = [], set()
    for r1 in rules:
        for r2 in rules:
            for sub in subterms(r1.lhs):
                if syn_match(sub, r2.lhs) and r1.lhs.size() + r2.lhs.size() <= N:
                    key = (id(r1), id(r2), repr(sub))
                    if key not in seen:
                        seen.add(key)
                        pairs.append((r1.rhs, r2.rhs))
    return pairs


# ============================================================================
# Define benchmark systems
# ============================================================================

def make_systems():
    systems = {}
    
    # System 1: Map Fusion
    systems["Map Fusion"] = [
        Rule(App(App(Var(0), Var(1)), App(App(Var(0), Var(2)), Var(3))),
             App(App(Var(0), Lam(App(Var(2), App(Var(3), Var(0))))), Var(3))),
        Rule(App(App(Var(0), Lam(Var(0))), Var(1)), Var(1)),
    ]
    
    # System 2: Idempotent
    systems["Idempotent: f²=f"] = [
        Rule(App(Var(0), App(Var(0), Var(1))), App(Var(0), Var(1))),
    ]
    
    # System 3: Associativity
    systems["Associativity"] = [
        Rule(App(App(Var(0), App(App(Var(0), Var(1)), Var(2))), Var(3)),
             App(App(Var(0), Var(1)), App(App(Var(0), Var(2)), Var(3)))),
    ]
    
    # System 4: Two idempotent rules
    systems["Double Idemp."] = [
        Rule(App(Var(0), App(Var(0), Var(1))), App(Var(0), Var(1)), "f²=f"),
        Rule(App(Var(1), App(Var(1), Var(0))), App(Var(1), Var(0)), "g²=g"),
    ]
    
    return systems


# ============================================================================
# Generate saturation data
# ============================================================================

max_level = 20
systems = make_systems()

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("Critical Pair Saturation Curves", fontsize=16, fontweight='bold')

colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']

for idx, (name, rules) in enumerate(systems.items()):
    ax = axes[idx // 2][idx % 2]
    
    levels = list(range(1, max_level + 1))
    counts = []
    stab_level = None
    
    prev = -1
    for N in levels:
        cps = enum_cps(rules, N)
        c = len(cps)
        counts.append(c)
        if c == prev and stab_level is None and N > 1:
            stab_level = N
        prev = c
    
    ax.plot(levels, counts, 'o-', color=colors[idx], linewidth=2, markersize=6)
    
    if stab_level:
        ax.axvline(x=stab_level, color='red', linestyle='--', alpha=0.7, linewidth=1.5)
        ax.fill_betweenx([min(counts)-0.5, max(counts)+1], stab_level, max_level,
                         alpha=0.1, color='green')
        ax.annotate(f'Stabilized\nat N={stab_level}',
                   xy=(stab_level, counts[stab_level-1]),
                   xytext=(stab_level + 2, max(counts) * 0.7 + 0.5),
                   arrowprops=dict(arrowstyle='->', color='red'),
                   fontsize=10, color='red', fontweight='bold')
    
    ax.set_title(name, fontsize=13, fontweight='bold')
    ax.set_xlabel('Size Bound N', fontsize=11)
    ax.set_ylabel('# Critical Pairs', fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0.5, max_level + 0.5)

plt.tight_layout()
plt.savefig('saturation_curves.png', dpi=150, bbox_inches='tight')
print("Saved saturation_curves.png")
