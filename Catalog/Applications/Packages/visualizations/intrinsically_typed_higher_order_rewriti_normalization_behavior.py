#!/usr/bin/env python3
"""
Visualization: Normalization Behavior

Shows how term size changes during βη-normalization for various starting terms.
Illustrates that normalization always terminates for simply typed terms,
and that terms converge to compact normal forms.

This connects to the strong normalization theorem and the practical importance
of βη-reduction for compiler optimization and proof simplification.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass

# --- Inline term representation ---

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

def hfv(t, v):
    match t:
        case V(i): return i==v
        case A(f,a): return hfv(f,v) or hfv(a,v)
        case L(b): return hfv(b,v+1)

def step(t):
    # β at top
    if isinstance(t, A) and isinstance(t.f, L):
        return sb(lambda i: t.a if i==0 else V(i-1), t.f.b)
    # η at top
    if isinstance(t, L) and isinstance(t.b, A) and t.b.a == V(0) and not hfv(t.b.f, 0):
        return rn(lambda i: i-1, t.b.f)
    # recurse
    match t:
        case A(f, a):
            r = step(f)
            if r is not None: return A(r, a)
            r = step(a)
            if r is not None: return A(f, r)
        case L(b):
            r = step(b)
            if r is not None: return L(r)
    return None

def trace_sizes(t, max_steps=200):
    """Record term sizes during normalization."""
    sizes = [t.sz()]
    for _ in range(max_steps):
        r = step(t)
        if r is None:
            break
        t = r
        sizes.append(t.sz())
    return sizes

# --- Test terms ---

# Build some interesting terms
id_tm = L(V(0))  # λx.x
K_tm = L(L(V(1)))  # λxy.x
S_body = A(A(V(2), V(0)), A(V(1), V(0)))
S_tm = L(L(L(S_body)))  # λxyz. xz(yz)

terms = {
    "id id": A(id_tm, id_tm),
    "K id id": A(A(K_tm, id_tm), id_tm),
    "S K K": A(A(S_tm, K_tm), K_tm),
    "λ.(id x₀)": L(A(id_tm, V(0))),
    "(λ.x₀ x₀)(λ.x₀)": A(L(A(V(0), V(0))), id_tm),
    "K (S K) id": A(A(K_tm, A(S_tm, K_tm)), id_tm),
    "η-redex λ.(x₁ x₀)": L(A(V(1), V(0))),
    "S id id x₀": A(A(A(S_tm, id_tm), id_tm), V(0)),
}

# --- Plot ---

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Size traces
ax1 = axes[0]
colors = plt.cm.Set2(np.linspace(0, 1, len(terms)))

for (name, t), color in zip(terms.items(), colors):
    sizes = trace_sizes(t)
    ax1.plot(range(len(sizes)), sizes, '-o', label=name, color=color,
             markersize=4, linewidth=1.5)

ax1.set_xlabel('Reduction Step', fontsize=11)
ax1.set_ylabel('Term Size (# nodes)', fontsize=11)
ax1.set_title('Term Size During βη-Normalization', fontsize=12, fontweight='bold')
ax1.legend(fontsize=7, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0)

# Panel 2: Initial vs final size
ax2 = axes[1]
names = list(terms.keys())
initial_sizes = [t.sz() for t in terms.values()]
final_sizes = []
for t in terms.values():
    sizes = trace_sizes(t)
    final_sizes.append(sizes[-1])
steps_to_nf = []
for t in terms.values():
    sizes = trace_sizes(t)
    steps_to_nf.append(len(sizes) - 1)

x = np.arange(len(names))
width = 0.3
bars1 = ax2.bar(x - width/2, initial_sizes, width, label='Initial size',
               color='#42A5F5', edgecolor='#1565C0')
bars2 = ax2.bar(x + width/2, final_sizes, width, label='Normal form size',
               color='#66BB6A', edgecolor='#2E7D32')

# Add step counts as text
for i, s in enumerate(steps_to_nf):
    ax2.text(i, max(initial_sizes[i], final_sizes[i]) + 0.3,
            f'{s} steps', ha='center', fontsize=7, color='#666')

ax2.set_xticks(x)
ax2.set_xticklabels(names, rotation=35, ha='right', fontsize=7)
ax2.set_ylabel('Size', fontsize=11)
ax2.set_title('Size Reduction via Normalization', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle("Strong Normalization: Simply Typed Terms Always Reach Normal Form",
            fontsize=13, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_normalization_sizes.png', dpi=150, bbox_inches='tight')
print("Saved viz_normalization_sizes.png")
