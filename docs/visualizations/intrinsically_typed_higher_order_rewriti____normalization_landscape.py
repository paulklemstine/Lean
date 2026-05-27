#!/usr/bin/env python3
"""
visualize_rewriting.py — Visualizes the structure of βη-reduction on typed λ-terms.

Shows a heatmap of term sizes before and after βη-normalization across different
type complexities, illustrating how η-contraction and β-reduction interact to
simplify higher-order terms.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ============================================================================
# Inline all needed types and functions (self-contained)
# ============================================================================

class Ty: pass

class Base(Ty):
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Base) and self.index == o.index
    def __hash__(self): return hash(('Base', self.index))
    def __repr__(self): return f"b{self.index}"
    def order(self): return 0

class Arr(Ty):
    def __init__(self, d, c): self.dom, self.cod = d, c
    def __eq__(self, o): return isinstance(o, Arr) and self.dom == o.dom and self.cod == o.cod
    def __hash__(self): return hash(('Arr', self.dom, self.cod))
    def __repr__(self): return f"({self.dom}→{self.cod})"
    def order(self): return max(self.dom.order() + 1, self.cod.order())

B0 = Base(0)

class Tm: pass

class Var(Tm):
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Var) and self.index == o.index
    def __hash__(self): return hash(('Var', self.index))
    def size(self): return 1

class App(Tm):
    def __init__(self, f, a): self.fun, self.arg = f, a
    def __eq__(self, o): return isinstance(o, App) and self.fun == o.fun and self.arg == o.arg
    def __hash__(self): return hash(('App', self.fun, self.arg))
    def size(self): return 1 + self.fun.size() + self.arg.size()

class Lam(Tm):
    def __init__(self, ty, b): self.dom_ty, self.body = ty, b
    def __eq__(self, o): return isinstance(o, Lam) and self.dom_ty == o.dom_ty and self.body == o.body
    def __hash__(self): return hash(('Lam', self.dom_ty, self.body))
    def size(self): return 1 + self.body.size()

def rename(rho, t):
    if isinstance(t, Var): return Var(rho(t.index))
    elif isinstance(t, App): return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        return Lam(t.dom_ty, rename(lambda i, r=rho: 0 if i==0 else r(i-1)+1, t.body))

def shift(t): return rename(lambda i: i+1, t)

def subst_single(body, arg):
    def sigma(i):
        if i == 0: return arg
        return Var(i-1)
    return subst(sigma, body)

def subst(sigma, t):
    if isinstance(t, Var): return sigma(t.index)
    elif isinstance(t, App): return App(subst(sigma, t.fun), subst(sigma, t.arg))
    elif isinstance(t, Lam):
        def lifted(i, s=sigma):
            if i == 0: return Var(0)
            return shift(s(i-1))
        return Lam(t.dom_ty, subst(lifted, t.body))

def is_shifted(t):
    if isinstance(t, Var): return Var(t.index-1) if t.index > 0 else None
    elif isinstance(t, App):
        f, a = is_shifted(t.fun), is_shifted(t.arg)
        return App(f, a) if f is not None and a is not None else None
    return None

def beta_step(t):
    if isinstance(t, App):
        if isinstance(t.fun, Lam): return subst_single(t.fun.body, t.arg)
        r = beta_step(t.fun)
        if r: return App(r, t.arg)
        r = beta_step(t.arg)
        if r: return App(t.fun, r)
    elif isinstance(t, Lam):
        r = beta_step(t.body)
        if r: return Lam(t.dom_ty, r)
    return None

def eta_step(t):
    if isinstance(t, Lam):
        if isinstance(t.body, App) and isinstance(t.body.arg, Var) and t.body.arg.index == 0:
            u = is_shifted(t.body.fun)
            if u is not None: return u
        r = eta_step(t.body)
        if r: return Lam(t.dom_ty, r)
    elif isinstance(t, App):
        r = eta_step(t.fun)
        if r: return App(r, t.arg)
        r = eta_step(t.arg)
        if r: return App(t.fun, r)
    return None

def normalize(t, max_steps=500):
    steps_beta, steps_eta = 0, 0
    for _ in range(max_steps):
        r = beta_step(t)
        if r: t = r; steps_beta += 1; continue
        r = eta_step(t)
        if r: t = r; steps_eta += 1; continue
        break
    return t, steps_beta, steps_eta

def generate_terms(ctx, ty, max_size):
    if max_size <= 0: return []
    results = []
    for i, ct in enumerate(ctx):
        if ct == ty: results.append(Var(i))
    if isinstance(ty, Arr) and max_size >= 2:
        new_ctx = (ty.dom,) + ctx
        for body in generate_terms(new_ctx, ty.cod, max_size - 1):
            results.append(Lam(ty.dom, body))
    if max_size >= 3:
        for a_ty in [B0, Arr(B0, B0)]:
            fun_ty = Arr(a_ty, ty)
            for s1 in range(1, max_size - 1):
                s2 = max_size - 1 - s1
                for f in generate_terms(ctx, fun_ty, s1):
                    for a in generate_terms(ctx, a_ty, s2):
                        results.append(App(f, a))
    return results

# ============================================================================
# Visualization
# ============================================================================

# Generate types of increasing complexity
types = [
    B0,
    Arr(B0, B0),
    Arr(B0, Arr(B0, B0)),
    Arr(Arr(B0, B0), B0),
    Arr(Arr(B0, B0), Arr(B0, B0)),
]
type_labels = ["b₀", "b₀→b₀", "b₀→b₀→b₀", "(b₀→b₀)→b₀", "(b₀→b₀)→b₀→b₀"]

# Collect data
max_sizes = list(range(3, 10))
data_reduction = np.zeros((len(types), len(max_sizes)))
data_beta_steps = np.zeros((len(types), len(max_sizes)))
data_eta_steps = np.zeros((len(types), len(max_sizes)))
data_term_counts = np.zeros((len(types), len(max_sizes)))

ctx = (B0,)  # One base-type variable

for i, ty in enumerate(types):
    for j, ms in enumerate(max_sizes):
        terms = generate_terms(ctx, ty, ms)
        if not terms:
            continue
        data_term_counts[i, j] = len(terms)
        total_reduction = 0
        total_beta = 0
        total_eta = 0
        for t in terms[:100]:
            orig_size = t.size()
            nf, sb, se = normalize(t)
            nf_size = nf.size()
            total_reduction += (orig_size - nf_size) / max(orig_size, 1)
            total_beta += sb
            total_eta += se
        n = min(len(terms), 100)
        data_reduction[i, j] = total_reduction / n if n > 0 else 0
        data_beta_steps[i, j] = total_beta / n if n > 0 else 0
        data_eta_steps[i, j] = total_eta / n if n > 0 else 0

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Size reduction ratio
im1 = axes[0].imshow(data_reduction, aspect='auto', cmap='YlOrRd',
                      interpolation='nearest')
axes[0].set_xticks(range(len(max_sizes)))
axes[0].set_xticklabels(max_sizes)
axes[0].set_yticks(range(len(types)))
axes[0].set_yticklabels(type_labels)
axes[0].set_xlabel('Max Term Size')
axes[0].set_ylabel('Type')
axes[0].set_title('Average Size Reduction\nby βη-Normalization')
plt.colorbar(im1, ax=axes[0], label='Fraction reduced')

# Plot 2: Average β-steps
im2 = axes[1].imshow(data_beta_steps, aspect='auto', cmap='Blues',
                      interpolation='nearest')
axes[1].set_xticks(range(len(max_sizes)))
axes[1].set_xticklabels(max_sizes)
axes[1].set_yticks(range(len(types)))
axes[1].set_yticklabels(type_labels)
axes[1].set_xlabel('Max Term Size')
axes[1].set_title('Average β-Reduction\nSteps to Normal Form')
plt.colorbar(im2, ax=axes[1], label='Steps')

# Plot 3: Average η-steps
im3 = axes[2].imshow(data_eta_steps, aspect='auto', cmap='Greens',
                      interpolation='nearest')
axes[2].set_xticks(range(len(max_sizes)))
axes[2].set_xticklabels(max_sizes)
axes[2].set_yticks(range(len(types)))
axes[2].set_yticklabels(type_labels)
axes[2].set_xlabel('Max Term Size')
axes[2].set_title('Average η-Contraction\nSteps to Normal Form')
plt.colorbar(im3, ax=axes[2], label='Steps')

fig.suptitle('βη-Normalization Landscape for Simply Typed λ-Terms', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('visualization_betaeta.png', dpi=150, bbox_inches='tight')
print("Saved visualization_betaeta.png")
