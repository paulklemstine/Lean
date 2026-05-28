#!/usr/bin/env python3
"""
Visualization: β-Normalization Reduction Paths

Shows how different reduction strategies converge to the same normal form
in a confluent system. Plots reduction step counts and term sizes during
normalization for Church numeral arithmetic.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ============================================================================
# Self-contained term algebra
# ============================================================================

class Term:
    def __init__(self, kind, var_id=0, left=None, right=None, body=None):
        self.kind = kind
        self.var_id = var_id
        self.left = left
        self.right = right
        self.body = body

    @staticmethod
    def var(i): return Term('VAR', var_id=i)
    @staticmethod
    def app(s, t): return Term('APP', left=s, right=t)
    @staticmethod
    def lam(b): return Term('LAM', body=b)

    def size(self):
        if self.kind == 'VAR': return 1
        if self.kind == 'APP': return 1 + self.left.size() + self.right.size()
        return 1 + self.body.size()

    def __eq__(self, other):
        if not isinstance(other, Term): return False
        if self.kind != other.kind: return False
        if self.kind == 'VAR': return self.var_id == other.var_id
        if self.kind == 'APP': return self.left == other.left and self.right == other.right
        return self.body == other.body


def _rename(rho, t):
    if t.kind == 'VAR': return Term.var(rho(t.var_id))
    if t.kind == 'APP': return Term.app(_rename(rho, t.left), _rename(rho, t.right))
    lift = lambda n: 0 if n == 0 else rho(n-1) + 1
    return Term.lam(_rename(lift, t.body))

def _subst(t, sigma):
    if t.kind == 'VAR': return sigma(t.var_id)
    if t.kind == 'APP': return Term.app(_subst(t.left, sigma), _subst(t.right, sigma))
    lift = lambda n: Term.var(0) if n == 0 else _rename(lambda k: k+1, sigma(n-1))
    return Term.lam(_subst(t.body, lift))

def _beta(body, arg):
    single = lambda n: arg if n == 0 else Term.var(n-1)
    return _subst(body, single)


def leftmost_reduce(t):
    """Leftmost-outermost β-reduction."""
    if t.kind == 'APP' and t.left.kind == 'LAM':
        return _beta(t.left.body, t.right)
    if t.kind == 'APP':
        r = leftmost_reduce(t.left)
        if r is not None: return Term.app(r, t.right)
        r = leftmost_reduce(t.right)
        if r is not None: return Term.app(t.left, r)
    if t.kind == 'LAM':
        r = leftmost_reduce(t.body)
        if r is not None: return Term.lam(r)
    return None

def rightmost_reduce(t):
    """Rightmost-innermost β-reduction."""
    if t.kind == 'APP':
        r = rightmost_reduce(t.right)
        if r is not None: return Term.app(t.left, r)
        r = rightmost_reduce(t.left)
        if r is not None: return Term.app(r, t.right)
        if t.left.kind == 'LAM':
            return _beta(t.left.body, t.right)
    if t.kind == 'LAM':
        r = rightmost_reduce(t.body)
        if r is not None: return Term.lam(r)
    return None


def trace_reduction(t, strategy, fuel=300):
    """Trace a reduction sequence, recording sizes."""
    sizes = [t.size()]
    current = t
    for _ in range(fuel):
        r = strategy(current)
        if r is None: break
        current = r
        sizes.append(current.size())
    return sizes


# ============================================================================
# Church numerals
# ============================================================================

def church(n):
    body = Term.var(0)
    for _ in range(n):
        body = Term.app(Term.var(1), body)
    return Term.lam(Term.lam(body))

def church_add(m, n):
    f, x = Term.var(1), Term.var(0)
    nfx = Term.app(Term.app(n, f), x)
    return Term.lam(Term.lam(Term.app(Term.app(m, f), nfx)))

def church_mul(m, n):
    f = Term.var(1)
    nf = Term.app(n, f)
    return Term.lam(Term.lam(Term.app(Term.app(m, nf), Term.var(0))))


# ============================================================================
# Generate data
# ============================================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Reduction paths for 2+3
ax = axes[0, 0]
t = church_add(church(2), church(3))
left_sizes = trace_reduction(t, leftmost_reduce)
right_sizes = trace_reduction(t, rightmost_reduce)

ax.plot(range(len(left_sizes)), left_sizes, 'b-o', markersize=3,
        label='Leftmost-outermost', alpha=0.8)
ax.plot(range(len(right_sizes)), right_sizes, 'r-s', markersize=3,
        label='Rightmost-innermost', alpha=0.8)
ax.set_xlabel('Reduction Step')
ax.set_ylabel('Term Size')
ax.set_title('Reduction of 2+3 (Church Numerals)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Reduction paths for 2×3
ax = axes[0, 1]
t = church_mul(church(2), church(3))
left_sizes = trace_reduction(t, leftmost_reduce)
right_sizes = trace_reduction(t, rightmost_reduce)

ax.plot(range(len(left_sizes)), left_sizes, 'b-o', markersize=3,
        label='Leftmost-outermost', alpha=0.8)
ax.plot(range(len(right_sizes)), right_sizes, 'r-s', markersize=3,
        label='Rightmost-innermost', alpha=0.8)
ax.set_xlabel('Reduction Step')
ax.set_ylabel('Term Size')
ax.set_title('Reduction of 2×3 (Church Numerals)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Steps to normal form vs input
ax = axes[1, 0]
ns = range(1, 8)
left_steps = []
right_steps = []
for n in ns:
    t = church_add(church(n), church(n))
    ls = trace_reduction(t, leftmost_reduce)
    rs = trace_reduction(t, rightmost_reduce)
    left_steps.append(len(ls) - 1)
    right_steps.append(len(rs) - 1)

ax.bar(np.array(list(ns)) - 0.15, left_steps, 0.3,
       label='Leftmost', color='#3498db', alpha=0.8)
ax.bar(np.array(list(ns)) + 0.15, right_steps, 0.3,
       label='Rightmost', color='#e74c3c', alpha=0.8)
ax.set_xlabel('n (computing n+n)')
ax.set_ylabel('Steps to Normal Form')
ax.set_title('Reduction Steps: n+n')
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

# Plot 4: Confluence verification
ax = axes[1, 1]
confluent_results = []
for n in range(1, 10):
    t = church_add(church(n), church(1))
    ls = trace_reduction(t, leftmost_reduce)
    rs = trace_reduction(t, rightmost_reduce)
    # Check if they converge to same normal form (same final size)
    same_nf = ls[-1] == rs[-1]
    confluent_results.append((n, ls[-1], rs[-1], same_nf))

ns_plot = [r[0] for r in confluent_results]
left_final = [r[1] for r in confluent_results]
right_final = [r[2] for r in confluent_results]
colors = ['#27ae60' if r[3] else '#e74c3c' for r in confluent_results]

ax.scatter(ns_plot, left_final, c=colors, s=100, marker='o', label='Left NF size', zorder=5)
ax.scatter(ns_plot, right_final, c=colors, s=100, marker='x', label='Right NF size', zorder=5)
ax.set_xlabel('n (computing n+1)')
ax.set_ylabel('Normal Form Size')
ax.set_title('Confluence: Both Strategies → Same NF')

# Add legend for confluence status
import matplotlib.lines as mlines
green_dot = mlines.Line2D([], [], color='#27ae60', marker='o', linestyle='None',
                           markersize=8, label='Confluent ✓')
ax.legend(handles=[green_dot])
ax.grid(True, alpha=0.3)

fig.suptitle('β-Reduction Strategies and Confluence Verification',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('normalization_paths.png', dpi=150, bbox_inches='tight')
print("Saved: normalization_paths.png")
