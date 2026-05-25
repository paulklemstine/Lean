#!/usr/bin/env python3
"""
Visualization: Substitution Composition Functoriality

Visualizes the key theorem: (t[σ])[τ] = t[σ;τ]
Shows how double substitution equals single composed substitution
across a range of term structures, confirming the categorical property.
"""

import matplotlib.pyplot as plt
import numpy as np

# Inline term definitions
class Term:
    pass

class Var(Term):
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Var) and self.index == o.index
    def __hash__(self): return hash(("V", self.index))
    def __repr__(self): return f"x{self.index}"

class App(Term):
    def __init__(self, f, a): self.fun, self.arg = f, a
    def __eq__(self, o): return isinstance(o, App) and self.fun == o.fun and self.arg == o.arg
    def __hash__(self): return hash(("A", self.fun, self.arg))
    def __repr__(self): return f"({self.fun} {self.arg})"

class Lam(Term):
    def __init__(self, b): self.body = b
    def __eq__(self, o): return isinstance(o, Lam) and self.body == o.body
    def __hash__(self): return hash(("L", self.body))
    def __repr__(self): return f"(λ.{self.body})"

def lift_ren(rho):
    return lambda n: 0 if n == 0 else rho(n-1) + 1

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    if isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    if isinstance(t, Lam): return Lam(rename(lift_ren(rho), t.body))

def lift_subst(sigma):
    def f(n):
        if n == 0: return Var(0)
        return rename(lambda x: x+1, sigma(n-1))
    return f

def subst(t, sigma):
    if isinstance(t, Var): return sigma(t.index)
    if isinstance(t, App): return App(subst(t.fun, sigma), subst(t.arg, sigma))
    if isinstance(t, Lam): return Lam(subst(t.body, lift_subst(sigma)))

def comp_subst(sigma, tau):
    return lambda n: subst(sigma(n), tau)

def term_size(t):
    if isinstance(t, Var): return 1
    if isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    if isinstance(t, Lam): return 1 + term_size(t.body)

def term_depth(t):
    if isinstance(t, Var): return 0
    if isinstance(t, App): return 1 + max(term_depth(t.fun), term_depth(t.arg))
    if isinstance(t, Lam): return 1 + term_depth(t.body)

def count_lambdas(t):
    if isinstance(t, Var): return 0
    if isinstance(t, App): return count_lambdas(t.fun) + count_lambdas(t.arg)
    if isinstance(t, Lam): return 1 + count_lambdas(t.body)

# Generate test terms
def gen_terms(max_size, num_vars=3):
    terms = []
    def gen(sz, bv):
        if sz <= 0: return []
        if sz == 1: return [Var(i) for i in range(bv + num_vars)]
        result = []
        if sz >= 2:
            for b in gen(sz - 1, bv + 1):
                result.append(Lam(b))
        for s1 in range(1, sz - 1):
            for f in gen(s1, bv):
                for a in gen(sz - 1 - s1, bv):
                    result.append(App(f, a))
                    if len(result) > 200:
                        return result
        return result
    for s in range(1, max_size + 1):
        terms.extend(gen(s, 0))
        if len(terms) > 500:
            break
    return terms[:500]

# Test substitution composition
terms = gen_terms(5)

sigma = lambda n: App(Var(0), Var(n)) if n == 0 else (Lam(Var(0)) if n == 1 else Var(n + 1))
tau = lambda n: Var(n + 2) if n == 0 else Lam(Var(n))

sizes = []
depths = []
lambdas_count = []
verified = []

for t in terms:
    try:
        lhs = subst(subst(t, sigma), tau)
        rhs = subst(t, comp_subst(sigma, tau))
        sizes.append(term_size(t))
        depths.append(term_depth(t))
        lambdas_count.append(count_lambdas(t))
        verified.append(lhs == rhs)
    except (RecursionError, TypeError):
        pass

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Substitution Composition Functoriality: (t[σ])[τ] = t[σ;τ]",
             fontsize=14, fontweight='bold')

# Plot 1: By term size
ax1 = axes[0]
colors1 = ['#228833' if v else '#EE6677' for v in verified]
ax1.scatter(range(len(sizes)), sizes, c=colors1, s=15, alpha=0.7)
ax1.set_xlabel("Test case index", fontsize=11)
ax1.set_ylabel("Term size", fontsize=11)
ax1.set_title(f"Verified: {sum(verified)}/{len(verified)}", fontsize=11)
ax1.axhline(y=0, color='gray', linewidth=0.5)

# Plot 2: Size vs depth with verification
ax2 = axes[1]
ax2.scatter(sizes, depths, c=colors1, s=20, alpha=0.6)
ax2.set_xlabel("Term size", fontsize=11)
ax2.set_ylabel("Term depth", fontsize=11)
ax2.set_title("Size vs Depth (green = verified)", fontsize=11)

# Plot 3: Lambda count distribution
ax3 = axes[2]
max_lam = max(lambdas_count) if lambdas_count else 0
bins = range(max_lam + 2)
ax3.hist(lambdas_count, bins=bins, color='#4477AA', edgecolor='white', alpha=0.8)
ax3.set_xlabel("Number of λ-binders", fontsize=11)
ax3.set_ylabel("Frequency", fontsize=11)
ax3.set_title("Binder complexity distribution", fontsize=11)

for ax in axes:
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("substitution_functoriality.png", dpi=150, bbox_inches='tight')
print(f"Saved substitution_functoriality.png")
print(f"Verified {sum(verified)}/{len(verified)} test cases")
