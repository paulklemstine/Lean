#!/usr/bin/env python3
"""Tropical Relation Locus Algorithm"""
import numpy as np

class MinPlusExpr:
    pass

class Const(MinPlusExpr):
    def __init__(self, c): self.c = c
    def eval(self, v): return self.c

class Var(MinPlusExpr):
    def __init__(self, i): self.i = i
    def eval(self, v): return v[self.i]

class TropAdd(MinPlusExpr):
    def __init__(self, e1, e2): self.e1, self.e2 = e1, e2
    def eval(self, v): return min(self.e1.eval(v), self.e2.eval(v))

class TropMul(MinPlusExpr):
    def __init__(self, e1, e2): self.e1, self.e2 = e1, e2
    def eval(self, v): return self.e1.eval(v) + self.e2.eval(v)

def compute_locus_2d(relations, base=0, x_range=(-3, 3), resolution=500):
    """Compute normalized tropical relation locus for n=2."""
    x_vals = np.linspace(x_range[0], x_range[1], resolution)
    locus = []
    for x in x_vals:
        v = [0.0, x] if base == 0 else [x, 0.0]
        if all(abs(lhs.eval(v) - rhs.eval(v)) < 1e-10 for lhs, rhs in relations):
            locus.append(v)
    return locus

# Example: Rank-2 Satake skeleton
relations = [(TropAdd(Var(0), Var(1)), Var(1))]
locus = compute_locus_2d(relations)
print(f"Rank-2 Satake skeleton: {len(locus)} points")
if locus:
    print(f"  x1 range: [{min(p[1] for p in locus):.2f}, {max(p[1] for p in locus):.2f}]")
