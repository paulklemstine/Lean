#!/usr/bin/env python3
"""
Visualization: Critical Pair Growth Analysis

Visualizes how the number of critical pairs grows with the size bound N
for different benchmark rewrite systems. This illustrates the computational
tractability of the bounded completion approach.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from typing import Optional
from enum import Enum, auto


# ============================================================================
# Inline term implementation (self-contained)
# ============================================================================

class TK(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()

@dataclass(frozen=True)
class T:
    kind: TK
    idx: int = 0
    l: Optional['T'] = None
    r: Optional['T'] = None
    b: Optional['T'] = None

    @staticmethod
    def v(i): return T(TK.VAR, idx=i)
    @staticmethod
    def a(s, t): return T(TK.APP, l=s, r=t)
    @staticmethod
    def la(body): return T(TK.LAM, b=body)

    def size(self):
        if self.kind == TK.VAR: return 1
        elif self.kind == TK.APP: return 1 + self.l.size() + self.r.size()
        else: return 1 + self.b.size()

    def subterms(self):
        result = [self]
        if self.kind == TK.APP:
            result.extend(self.l.subterms())
            result.extend(self.r.subterms())
        elif self.kind == TK.LAM:
            result.extend(self.b.subterms())
        return result

def syn_match(p, t):
    if p.kind == TK.VAR or t.kind == TK.VAR: return True
    if p.kind != t.kind: return False
    if p.kind == TK.APP: return syn_match(p.l, t.l) and syn_match(p.r, t.r)
    if p.kind == TK.LAM: return syn_match(p.b, t.b)
    return False

@dataclass
class Rule:
    name: str
    lhs: T
    rhs: T

@dataclass
class System:
    name: str
    rules: list

def count_cps(system, bound):
    count = 0
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if syn_match(sub, r2.lhs) and r1.lhs.size() + r2.lhs.size() <= bound:
                    count += 1
    return count

# ============================================================================
# Benchmark systems
# ============================================================================

map_fusion_sys = System("Map Fusion + Id", [
    Rule("fusion", T.a(T.a(T.v(0), T.v(1)), T.a(T.a(T.v(0), T.v(2)), T.v(3))),
         T.a(T.a(T.v(0), T.la(T.a(T.v(2), T.a(T.v(3), T.v(0))))), T.v(3))),
    Rule("map-id", T.a(T.a(T.v(0), T.la(T.v(0))), T.v(1)), T.v(1))
])

fold_build_sys = System("Fold/Build", [
    Rule("fold-build",
         T.a(T.a(T.a(T.v(0), T.v(1)), T.v(2)), T.a(T.v(3), T.v(4))),
         T.a(T.a(T.v(4), T.v(1)), T.v(2)))
])

cps_sys = System("CPS Admin", [
    Rule("admin-beta", T.a(T.la(T.v(0)), T.v(1)), T.v(1))
])

# ============================================================================
# Generate data
# ============================================================================

bounds = list(range(3, 40))
systems = [map_fusion_sys, fold_build_sys, cps_sys]
colors = ['#2196F3', '#FF5722', '#4CAF50']
markers = ['o', 's', '^']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Critical pairs vs bound
for sys, color, marker in zip(systems, colors, markers):
    counts = [count_cps(sys, N) for N in bounds]
    ax1.plot(bounds, counts, color=color, marker=marker, markersize=4,
             linewidth=2, label=sys.name)

ax1.set_xlabel('Size Bound N', fontsize=12)
ax1.set_ylabel('Number of Critical Pairs', fontsize=12)
ax1.set_title('Critical Pair Growth vs Size Bound', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Ratio CPs / N
for sys, color, marker in zip(systems, colors, markers):
    counts = [count_cps(sys, N) for N in bounds]
    ratios = [c / N if N > 0 else 0 for c, N in zip(counts, bounds)]
    ax2.plot(bounds, ratios, color=color, marker=marker, markersize=4,
             linewidth=2, label=sys.name)

ax2.set_xlabel('Size Bound N', fontsize=12)
ax2.set_ylabel('CPs / N (normalized)', fontsize=12)
ax2.set_title('Critical Pair Density (CPs per unit bound)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('critical_pairs_growth.png', dpi=150, bbox_inches='tight')
print("Saved: critical_pairs_growth.png")
