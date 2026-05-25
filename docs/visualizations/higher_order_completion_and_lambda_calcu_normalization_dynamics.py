#!/usr/bin/env python3
"""
Visualization: β-Normalization Dynamics

Plots how term size and redex count evolve during β-normalization
for various Church numeral arithmetic expressions. Illustrates
the computational behavior that higher-order completion must tame.
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

class App(Term):
    def __init__(self, f, a): self.fun, self.arg = f, a
    def __eq__(self, o): return isinstance(o, App) and self.fun == o.fun and self.arg == o.arg
    def __hash__(self): return hash(("A", self.fun, self.arg))

class Lam(Term):
    def __init__(self, b): self.body = b
    def __eq__(self, o): return isinstance(o, Lam) and self.body == o.body
    def __hash__(self): return hash(("L", self.body))

def lift_ren(rho):
    return lambda n: 0 if n == 0 else rho(n-1)+1

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

def single_subst(s):
    return lambda n: s if n == 0 else Var(n-1)

def beta_contract(body, arg):
    return subst(body, single_subst(arg))

def leftmost_reduce(t):
    if isinstance(t, App):
        if isinstance(t.fun, Lam):
            return beta_contract(t.fun.body, t.arg)
        r = leftmost_reduce(t.fun)
        if r: return App(r, t.arg)
        r = leftmost_reduce(t.arg)
        if r: return App(t.fun, r)
    elif isinstance(t, Lam):
        r = leftmost_reduce(t.body)
        if r: return Lam(r)
    return None

def term_size(t):
    if isinstance(t, Var): return 1
    if isinstance(t, App): return 1 + term_size(t.fun) + term_size(t.arg)
    if isinstance(t, Lam): return 1 + term_size(t.body)

def count_redexes(t):
    if isinstance(t, Var): return 0
    if isinstance(t, App):
        extra = 1 if isinstance(t.fun, Lam) else 0
        return extra + count_redexes(t.fun) + count_redexes(t.arg)
    if isinstance(t, Lam): return count_redexes(t.body)

def church(n):
    body = Var(0)
    for _ in range(n):
        body = App(Var(1), body)
    return Lam(Lam(body))

# Church operations
add = Lam(Lam(Lam(Lam(App(App(Var(3), Var(1)), App(App(Var(2), Var(1)), Var(0)))))))
succ_fn = Lam(Lam(Lam(App(Var(1), App(App(Var(2), Var(1)), Var(0))))))

def trace_normalization(t, max_steps=60):
    sizes = [term_size(t)]
    redexes = [count_redexes(t)]
    for _ in range(max_steps):
        r = leftmost_reduce(t)
        if r is None:
            break
        t = r
        sizes.append(term_size(t))
        redexes.append(count_redexes(t))
    return sizes, redexes

# Create test expressions
expressions = {
    "succ(2)": App(succ_fn, church(2)),
    "succ(3)": App(succ_fn, church(3)),
    "2 + 2": App(App(add, church(2)), church(2)),
    "2 + 3": App(App(add, church(2)), church(3)),
    "3 + 3": App(App(add, church(3)), church(3)),
    "succ(succ(2))": App(succ_fn, App(succ_fn, church(2))),
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("β-Normalization Dynamics of Church Numeral Arithmetic",
             fontsize=14, fontweight='bold')

colors = ['#4477AA', '#EE6677', '#228833', '#CCBB44', '#AA3377', '#66CCEE']

for (name, expr), color in zip(expressions.items(), colors):
    sizes, redexes = trace_normalization(expr)
    steps = range(len(sizes))

    ax1.plot(steps, sizes, color=color, label=name, linewidth=2, marker='o',
             markersize=3, alpha=0.8)
    ax2.plot(steps, redexes, color=color, label=name, linewidth=2, marker='s',
             markersize=3, alpha=0.8)

ax1.set_xlabel("Reduction step", fontsize=12)
ax1.set_ylabel("Term size (# constructors)", fontsize=12)
ax1.set_title("Term Size During Normalization", fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

ax2.set_xlabel("Reduction step", fontsize=12)
ax2.set_ylabel("Number of β-redexes", fontsize=12)
ax2.set_title("Redex Count During Normalization", fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("normalization_dynamics.png", dpi=150, bbox_inches='tight')
print("Saved normalization_dynamics.png")
