#!/usr/bin/env python3
"""
Visualization: Critical Pair Analysis Heatmap

Visualizes the number of critical pairs found at different size bounds
for multiple benchmark rewrite systems. Shows how overlap complexity
grows with term size — the key parameter for bounded completion.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ============================================================================
# Inline term algebra (self-contained, no local imports)
# ============================================================================

class HOTerm:
    def __init__(self, kind, var_id=0, left=None, right=None, body=None):
        self.kind = kind
        self.var_id = var_id
        self.left = left
        self.right = right
        self.body = body

    @staticmethod
    def var(i): return HOTerm('VAR', var_id=i)
    @staticmethod
    def app(s, t): return HOTerm('APP', left=s, right=t)
    @staticmethod
    def lam(b): return HOTerm('LAM', body=b)

    def size(self):
        if self.kind == 'VAR': return 1
        if self.kind == 'APP': return 1 + self.left.size() + self.right.size()
        return 1 + self.body.size()

    def subterms(self):
        yield self
        if self.kind == 'APP':
            yield from self.left.subterms()
            yield from self.right.subterms()
        elif self.kind == 'LAM':
            yield from self.body.subterms()

    def __eq__(self, other):
        if not isinstance(other, HOTerm): return False
        if self.kind != other.kind: return False
        if self.kind == 'VAR': return self.var_id == other.var_id
        if self.kind == 'APP': return self.left == other.left and self.right == other.right
        return self.body == other.body

    def __hash__(self):
        if self.kind == 'VAR': return hash(('V', self.var_id))
        if self.kind == 'APP': return hash(('A', hash(self.left), hash(self.right)))
        return hash(('L', hash(self.body)))


def syntactic_overlap(p, t):
    if p.kind == 'VAR' or t.kind == 'VAR': return True
    if p.kind != t.kind: return False
    if p.kind == 'APP': return syntactic_overlap(p.left, t.left) and syntactic_overlap(p.right, t.right)
    if p.kind == 'LAM': return syntactic_overlap(p.body, t.body)
    return False


def count_critical_pairs(rules, bound):
    count = 0
    for r1_lhs, r1_rhs in rules:
        for r2_lhs, r2_rhs in rules:
            for sub in r1_lhs.subterms():
                if syntactic_overlap(sub, r2_lhs) and r1_lhs.size() + r2_lhs.size() <= bound:
                    count += 1
    return count


# ============================================================================
# Benchmark systems
# ============================================================================

def make_systems():
    x0, x1, x2, x3 = [HOTerm.var(i) for i in range(4)]

    map_fusion = [
        (HOTerm.app(HOTerm.app(x0, x1), HOTerm.app(HOTerm.app(x0, x2), x3)),
         HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.app(x2, HOTerm.app(x3, HOTerm.var(0))))), x3)),
        (HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.var(0))), x1), x1),
    ]

    beta_admin = [
        (HOTerm.app(HOTerm.lam(HOTerm.var(0)), x1), x1),
    ]

    cps = [
        (HOTerm.app(HOTerm.app(x0, x1), x2), HOTerm.app(x2, x1)),
    ]

    double_app = [
        (HOTerm.app(HOTerm.app(x0, x1), x1), HOTerm.app(x0, x1)),
        (HOTerm.app(HOTerm.lam(HOTerm.var(0)), x1), x1),
    ]

    return {
        'Map Fusion': map_fusion,
        'β-Admin': beta_admin,
        'CPS Transform': cps,
        'Double-App + β': double_app,
    }


# ============================================================================
# Generate heatmap data
# ============================================================================

systems = make_systems()
bounds = list(range(5, 36, 1))
system_names = list(systems.keys())

data = np.zeros((len(system_names), len(bounds)))
for i, name in enumerate(system_names):
    rules = systems[name]
    for j, b in enumerate(bounds):
        data[i, j] = count_critical_pairs(rules, b)

# ============================================================================
# Plot
# ============================================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Heatmap
im = ax1.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax1.set_yticks(range(len(system_names)))
ax1.set_yticklabels(system_names)
ax1.set_xlabel('Size Bound')
ax1.set_ylabel('Rewrite System')
ax1.set_title('Critical Pair Count by Size Bound')

# Set x-tick labels to show bounds
tick_positions = range(0, len(bounds), 5)
ax1.set_xticks(list(tick_positions))
ax1.set_xticklabels([bounds[i] for i in tick_positions])

plt.colorbar(im, ax=ax1, label='Number of Critical Pairs')

# Line plot
for i, name in enumerate(system_names):
    ax2.plot(bounds, data[i], 'o-', label=name, markersize=3)

ax2.set_xlabel('Size Bound')
ax2.set_ylabel('Number of Critical Pairs')
ax2.set_title('Critical Pair Growth vs. Size Bound')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('critical_pairs_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: critical_pairs_analysis.png")
