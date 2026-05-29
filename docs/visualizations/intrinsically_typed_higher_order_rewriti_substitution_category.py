#!/usr/bin/env python3
"""
Visualization: The Substitution Category

Visualizes the category of contexts and substitutions, showing how
composition is associative and the identity substitution is the unit.
Displays a heatmap of substitution composition applied to various terms.

This illustrates the categorical structure underlying typed λ-calculus.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# --- Inline term definitions ---
from dataclasses import dataclass
from typing import Optional

@dataclass(frozen=True)
class V:
    i: int
    def sz(self): return 1
    def __repr__(self): return f"x{self.i}"

@dataclass(frozen=True)
class A:
    f: 'Trm'
    a: 'Trm'
    def sz(self): return 1 + self.f.sz() + self.a.sz()
    def __repr__(self): return f"({self.f} {self.a})"

@dataclass(frozen=True)
class L:
    b: 'Trm'
    def sz(self): return 1 + self.b.sz()
    def __repr__(self): return f"(λ.{self.b})"

Trm = V | A | L

def rn(f, t):
    match t:
        case V(i): return V(f(i))
        case A(g, a): return A(rn(f, g), rn(f, a))
        case L(b): return L(rn(lambda i: 0 if i==0 else f(i-1)+1, b))

def sb(s, t):
    match t:
        case V(i): return s(i)
        case A(f, a): return A(sb(s, f), sb(s, a))
        case L(b):
            def lf(i):
                return V(0) if i==0 else rn(lambda j: j+1, s(i-1))
            return L(sb(lf, b))

def comp(tau, sigma):
    return lambda i: sb(tau, sigma(i))

def id_sub(i): return V(i)

# --- Generate test data ---

# Various substitutions on a 3-variable context
subs = {
    "id": lambda i: V(i),
    "shift": lambda i: V(i+1),
    "swap01": lambda i: V(1) if i==0 else (V(0) if i==1 else V(i)),
    "dup0": lambda i: V(0),
    "lam_wrap": lambda i: L(V(i+1)),
}

# Test terms
terms = [
    V(0), V(1), V(2),
    A(V(0), V(1)),
    A(V(1), V(0)),
    L(V(0)),
    L(A(V(1), V(0))),
    A(L(V(0)), V(1)),
]

term_labels = [repr(t) for t in terms]
sub_names = list(subs.keys())

# --- Heatmap: term sizes after substitution ---

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Size after single substitution
sizes = np.zeros((len(sub_names), len(terms)))
for i, sn in enumerate(sub_names):
    for j, t in enumerate(terms):
        result = sb(subs[sn], t)
        sizes[i, j] = result.sz()

ax = axes[0]
im = ax.imshow(sizes, cmap='YlOrRd', aspect='auto')
ax.set_xticks(range(len(terms)))
ax.set_xticklabels(term_labels, rotation=45, ha='right', fontsize=7)
ax.set_yticks(range(len(sub_names)))
ax.set_yticklabels(sub_names, fontsize=9)
ax.set_xlabel('Input Term', fontsize=10)
ax.set_ylabel('Substitution', fontsize=10)
ax.set_title('Term Size After Substitution', fontsize=11, fontweight='bold')

for i in range(len(sub_names)):
    for j in range(len(terms)):
        ax.text(j, i, f'{int(sizes[i,j])}', ha='center', va='center',
                fontsize=8, color='white' if sizes[i,j] > sizes.max()*0.6 else 'black')

plt.colorbar(im, ax=ax, label='Size')

# Panel 2: Verify associativity — (υ∘τ)∘σ = υ∘(τ∘σ)
# Pick three substitutions and verify on all terms
combos = [
    ("id", "shift", "swap01"),
    ("swap01", "dup0", "id"),
    ("shift", "swap01", "lam_wrap"),
    ("dup0", "id", "shift"),
]

ax2 = axes[1]
n_combos = len(combos)
n_terms = len(terms)
assoc_check = np.zeros((n_combos, n_terms))

combo_labels = []
for ci, (s1, s2, s3) in enumerate(combos):
    sigma = subs[s1]
    tau = subs[s2]
    upsilon = subs[s3]
    combo_labels.append(f"({s3}∘{s2})∘{s1}\nvs\n{s3}∘({s2}∘{s1})")

    for ti, t in enumerate(terms):
        lhs = sb(comp(upsilon, tau), sb(sigma, t))
        rhs = sb(upsilon, sb(comp(tau, sigma), t))
        # Both should equal sb(comp(upsilon, comp(tau, sigma)), t)
        assoc_check[ci, ti] = 1.0 if repr(lhs) == repr(rhs) else 0.0

im2 = ax2.imshow(assoc_check, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
ax2.set_xticks(range(n_terms))
ax2.set_xticklabels(term_labels, rotation=45, ha='right', fontsize=7)
ax2.set_yticks(range(n_combos))
ax2.set_yticklabels(combo_labels, fontsize=7)
ax2.set_xlabel('Input Term', fontsize=10)
ax2.set_ylabel('Substitution Triple', fontsize=10)
ax2.set_title('Associativity Verification: (υ∘τ)∘σ = υ∘(τ∘σ)', fontsize=11, fontweight='bold')

for i in range(n_combos):
    for j in range(n_terms):
        symbol = '✓' if assoc_check[i,j] == 1.0 else '✗'
        color = '#1B5E20' if assoc_check[i,j] == 1.0 else '#B71C1C'
        ax2.text(j, i, symbol, ha='center', va='center', fontsize=14,
                color=color, fontweight='bold')

plt.suptitle("The Substitution Category: Composition and Associativity",
            fontsize=13, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_substitution_category.png', dpi=150, bbox_inches='tight')
print("Saved viz_substitution_category.png")
