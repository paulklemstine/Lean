"""Exhaustive-ish search over periodic drifting paths.

A candidate is a cyclic sequence of cell-steps (m_k,n_k) in the 8 king
directions, k=0..T-1, with total drift D != 0, such that the visited cells
c_0,...,c_{T-1} (c_0 = (0,0), c_{k+1} = c_k + step_k) are pairwise distinct
modulo translation by D (so the infinite periodic path uses each cell once).

For such a candidate we minimise, over offsets r_k in [0,1]^2 (with
r_T = r_0), the longest edge
    L = max_k |(m_k + a_{k+1} - a_k, n_k + b_{k+1} - b_k)| .
This is a convex problem; we solve it by projected subgradient descent with
random restarts.  min over candidates of L is (an upper bound for, and
conjecturally equal to) the critical radius R_min.
"""
import itertools
import math
import random

STEPS = [(m, n) for m in (-1, 0, 1) for n in (-1, 0, 1) if (m, n) != (0, 0)]


def cells_ok(seq):
    c = (0, 0)
    cs = [c]
    for (m, n) in seq:
        c = (c[0] + m, c[1] + n)
        cs.append(c)
    D = cs[-1]
    if D == (0, 0):
        return None
    # cells c_0..c_{T-1} pairwise distinct modulo the lattice Z*D
    T = len(seq)
    for i in range(T):
        for j in range(T):
            if i == j:
                continue
            dx = cs[i][0] - cs[j][0]
            dy = cs[i][1] - cs[j][1]
            # is (dx,dy) a multiple of D ?
            for t in range(-T - 2, T + 3):
                if (dx, dy) == (t * D[0], t * D[1]):
                    return None
    return D


def optimise(seq, iters=4000, restarts=6):
    T = len(seq)
    best = float("inf")
    for _ in range(restarts):
        r = [[random.random(), random.random()] for _ in range(T)]
        for it in range(iters):
            step = 0.3 / (1 + it * 0.01)
            # find worst edge
            worst, wi, wvec = -1.0, 0, (0.0, 0.0)
            for k in range(T):
                m, n = seq[k]
                k2 = (k + 1) % T
                du = m + r[k2][0] - r[k][0]
                dv = n + r[k2][1] - r[k][1]
                nrm = math.hypot(du, dv)
                if nrm > worst:
                    worst, wi, wvec = nrm, k, (du, dv)
            if worst < 1e-9:
                break
            gx, gy = wvec[0] / worst, wvec[1] / worst
            k, k2 = wi, (wi + 1) % T
            r[k2][0] -= step * gx
            r[k2][1] -= step * gy
            r[k][0] += step * gx
            r[k][1] += step * gy
            for q in (k, k2):
                r[q][0] = min(1.0, max(0.0, r[q][0]))
                r[q][1] = min(1.0, max(0.0, r[q][1]))
        # final evaluation
        worst = max(
            math.hypot(seq[k][0] + r[(k + 1) % T][0] - r[k][0],
                       seq[k][1] + r[(k + 1) % T][1] - r[k][1])
            for k in range(T))
        if worst < best:
            best, bestr = worst, [tuple(x) for x in r]
    return best, bestr


def main():
    random.seed(0)
    overall = (float("inf"), None, None)
    for T in (2, 3, 4):
        for seq in itertools.product(STEPS, repeat=T):
            D = cells_ok(list(seq))
            if D is None:
                continue
            val, r = optimise(list(seq), iters=1500, restarts=3)
            if val < overall[0] - 1e-9:
                overall = (val, seq, r)
                print(f"T={T} new best L={val:.6f} seq={seq} offsets={[(round(a,4),round(b,4)) for a,b in r]}")
    print("best overall:", overall[0])


if __name__ == "__main__":
    main()


"""Random sampling of longer periods (T = 5,6,7,8) for the same search as
search_periodic.py."""
import random
from search_periodic import STEPS, cells_ok, optimise

random.seed(1)
best = (float("inf"), None, None)
for T in (5, 6, 7, 8):
    tried = 0
    while tried < 1500:
        seq = [random.choice(STEPS) for _ in range(T)]
        if cells_ok(seq) is None:
            continue
        tried += 1
        val, r = optimise(seq, iters=1500, restarts=2)
        if val < best[0] - 1e-9:
            best = (val, tuple(seq), r)
            print(f"T={T} new best L={val:.6f} seq={tuple(seq)} "
                  f"offsets={[(round(a,4),round(b,4)) for a,b in r]}", flush=True)
print("best overall:", best[0])


"""Search for the minimal radius R admitting an infinite connected path in
the 'one uniform point per unit cell of Z^2' model.

State = offset (a,b) of the current point inside its cell, discretized.
Edge  = a cell step (m,n) in {-1,0,1}^2 \\ {(0,0)} with
        (m + a' - a)^2 + (n + b' - b)^2 <= R^2.
A cycle in this labelled graph whose labels sum to a nonzero vector yields a
periodic path with nonzero drift, hence (if the cells of one period are
distinct) an infinite component.
Absence of such a cycle (up to discretization error) is evidence that no
infinite path exists.
"""
import sys
from collections import deque


def has_drift_cycle(R, K):
    h = 1.0 / K
    nodes = [(i, j) for i in range(K + 1) for j in range(K + 1)]
    idx = {p: k for k, p in enumerate(nodes)}
    steps = [(m, n) for m in (-1, 0, 1) for n in (-1, 0, 1) if (m, n) != (0, 0)]
    adj = [[] for _ in nodes]
    R2 = R * R
    for (i, j) in nodes:
        a, b = i * h, j * h
        for (i2, j2) in nodes:
            a2, b2 = i2 * h, j2 * h
            for (m, n) in steps:
                du = m + a2 - a
                dv = n + b2 - b
                if du * du + dv * dv <= R2 + 1e-12:
                    adj[idx[(i, j)]].append((idx[(i2, j2)], m, n))
    label = [None] * len(nodes)
    for s in range(len(nodes)):
        if label[s] is not None:
            continue
        label[s] = (0, 0)
        q = deque([s])
        while q:
            u = q.popleft()
            lu = label[u]
            for (v, m, n) in adj[u]:
                lv = (lu[0] + m, lu[1] + n)
                if label[v] is None:
                    label[v] = lv
                    q.append(v)
                elif label[v] != lv:
                    return True, (nodes[u], nodes[v], lv, label[v])
    return False, None


if __name__ == "__main__":
    K = int(sys.argv[1]) if len(sys.argv) > 1 else 20
    for R in [0.30, 0.34, 0.40, 0.45, 0.48, 0.499, 0.501, 0.55, 0.60, 0.71]:
        res, w = has_drift_cycle(R, K)
        print(f"K={K} R={R:.3f}  drift cycle: {res}  {w if res else ''}")
