# Stability certification (self-contained)
import numpy as np
from itertools import combinations

def cut_weight(W, S):
    n = W.shape[0]
    V = set(range(n))
    return sum(W[i,j] for i in S for j in V-S)

def separating_cuts(n, s, t):
    others = [v for v in range(n) if v != s and v != t]
    cuts = []
    for r in range(len(others)+1):
        for c in combinations(others, r):
            cuts.append({s}|set(c))
    return cuts

def certify(W, s, t, eps):
    n = W.shape[0]
    C = n**2
    cuts = separating_cuts(n, s, t)
    weights = sorted(cut_weight(W, S) for S in cuts)
    gap = weights[1] - weights[0] if len(weights) >= 2 else 0
    threshold = gap / (2*C) if C > 0 else float('inf')
    return 2*C*eps < gap, threshold

# Example
W = np.array([[0,1,10,10],[1,0,10,10],[10,10,0,1],[10,10,1,0.]], dtype=float)
stable, threshold = certify(W, 0, 3, 0.1)
print(f"Stable: {stable}, threshold: {threshold:.4f}")
