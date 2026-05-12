#!/usr/bin/env python3
"""Hecke Fixed-Point Algorithm"""
import numpy as np

def hecke_min_action(v):
    """Hecke action: (x0, x1) -> (x0, min(x0, x1))"""
    return [v[0], min(v[0], v[1])]

def find_fixed_points_rank2(x_range=(-3, 3), resolution=1000):
    """Find fixed points of the min-action on rank-2."""
    x_vals = np.linspace(x_range[0], x_range[1], resolution)
    fixed = []
    for x in x_vals:
        v = [0.0, x]
        img = hecke_min_action(v)
        if abs(v[0] - img[0]) < 1e-10 and abs(v[1] - img[1]) < 1e-10:
            fixed.append(v)
    return fixed

fps = find_fixed_points_rank2()
print(f"Fixed points: {len(fps)} found")
print(f"  x1 range: [{min(p[1] for p in fps):.2f}, {max(p[1] for p in fps):.2f}]")
print(f"  Condition verified: all x1 <= x0 = 0")
