#!/usr/bin/env python3
"""
Compensation works on the real floors: GPTQ / Optimal Brain Surgeon as a Schur complement.

Self-contained numerical companion (pure Python standard library, no NumPy needed).

Sections
  1. Exact identities of the quadratic layer model  L(u, v) = [u; v]^T H [u; v]
     with H = [[A, B], [B^T, D]], D positive definite:
       - completion of the square (OBS split)
       - optimal update v* = -D^{-1} B^T u attains the Schur-complement loss, uniquely
       - compensation never hurts; the gain is exactly ||D^{-1} B^T u||_D^2
       - strict gain iff B^T u != 0
       - single-column GPTQ cost e^2 / [H^{-1}]_qq, and H_qq [H^{-1}]_qq >= 1
       - wider compensation windows never hurt
       - the compensated / uncompensated ratio is invariant under rescaling the error
  2. The tail-share criterion
  3. A synthetic layer: per-channel RTN -> grouped RTN -> grouped GPTQ, at 4 and 3 bits
  4. The measured ladder on a 0.5B-parameter language model, in exact rational arithmetic
  5. A spectral heuristic for the compensation lever (open conjecture, numerics only)
"""
from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Vec = List[float]
Mat = List[List[float]]


# ----------------------------------------------------------------------------------------
# Minimal dense linear algebra
# ----------------------------------------------------------------------------------------
def zeros(r: int, c: int) -> Mat:
    return [[0.0] * c for _ in range(r)]


def eye(n: int) -> Mat:
    m = zeros(n, n)
    for i in range(n):
        m[i][i] = 1.0
    return m


def transpose(a: Mat) -> Mat:
    return [list(col) for col in zip(*a)]


def matmul(a: Mat, b: Mat) -> Mat:
    bt = transpose(b)
    return [[sum(x * y for x, y in zip(row, col)) for col in bt] for row in a]


def matvec(a: Mat, x: Sequence[float]) -> Vec:
    return [sum(aij * xj for aij, xj in zip(row, x)) for row in a]


def dot(x: Sequence[float], y: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(x, y))


def qf(h: Mat, x: Sequence[float]) -> float:
    """Quadratic form x^T H x (the layer-output loss of an error vector x)."""
    return dot(x, matvec(h, x))


def inverse(a: Mat) -> Mat:
    """Gauss-Jordan inverse with partial pivoting."""
    n = len(a)
    m = [row[:] + e for row, e in zip(a, eye(n))]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(m[r][c]))
        if abs(m[p][c]) < 1e-14:
            raise ValueError("singular matrix")
        m[c], m[p] = m[p], m[c]
        piv = m[c][c]
        m[c] = [x / piv for x in m[c]]
        for r in range(n):
            if r != c and m[r][c] != 0.0:
                f = m[r][c]
                m[r] = [x - f * y for x, y in zip(m[r], m[c])]
    return [row[n:] for row in m]


def cholesky_upper(a: Mat) -> Mat:
    """Upper-triangular U with a = U^T U (a must be symmetric positive definite)."""
    n = len(a)
    low = zeros(n, n)
    for i in range(n):
        for j in range(i + 1):
            s = a[i][j] - sum(low[i][k] * low[j][k] for k in range(j))
            if i == j:
                if s <= 0.0:
                    raise ValueError("matrix not positive definite")
                low[i][j] = math.sqrt(s)
            else:
                low[i][j] = s / low[j][j]
    return transpose(low)


def block(h: Mat, rows: Sequence[int], cols: Sequence[int]) -> Mat:
    return [[h[i][j] for j in cols] for i in rows]


def random_spd(n: int, rng: random.Random, correlation: float = 0.8, samples: int = 0) -> Mat:
    """Gram matrix of correlated random features (a stand-in for a calibration curvature X X^T)."""
    samples = samples or 4 * n
    mix = [[rng.gauss(0, 1) for _ in range(n)] for _ in range(n)]
    xs: Mat = []
    for _ in range(samples):
        z = [rng.gauss(0, 1) for _ in range(n)]
        common = matvec(mix, z)
        xs.append([correlation * c + (1 - correlation) * rng.gauss(0, 1) * 3 for c in common])
    h = zeros(n, n)
    for x in xs:
        for i in range(n):
            xi = x[i]
            row = h[i]
            for j in range(n):
                row[j] += xi * x[j]
    for i in range(n):
        for j in range(n):
            h[i][j] /= samples
        h[i][i] += 1e-3
    return h


# ----------------------------------------------------------------------------------------
# 1. Schur-complement identities
# ----------------------------------------------------------------------------------------
def split(h: Mat, k: int) -> Tuple[Mat, Mat, Mat]:
    """Split H into A (k x k quantized block), B (k x rest), D (rest x rest free block)."""
    n = len(h)
    q, f = list(range(k)), list(range(k, n))
    return block(h, q, q), block(h, q, f), block(h, f, f)


def schur(a: Mat, b: Mat, d: Mat) -> Mat:
    bdb = matmul(matmul(b, inverse(d)), transpose(b))
    return [[x - y for x, y in zip(r1, r2)] for r1, r2 in zip(a, bdb)]


def v_star(b: Mat, d: Mat, u: Vec) -> Vec:
    """Optimal compensating update of the free weights: v* = -D^{-1} B^T u."""
    return [-x for x in matvec(inverse(d), matvec(transpose(b), u))]


def section_identities(rng: random.Random) -> None:
    print("=" * 78)
    print("1. Exact identities of the quadratic layer model")
    print("=" * 78)
    n, k = 10, 3
    h = random_spd(n, rng)
    a, b, d = split(h, k)
    s = schur(a, b, d)
    u = [rng.uniform(-0.5, 0.5) for _ in range(k)]
    v = [rng.uniform(-0.5, 0.5) for _ in range(n - k)]

    # OBS split: L(u,v) = ||D^{-1}B^T u + v||_D^2 + u^T S u
    w = [x + y for x, y in zip(matvec(inverse(d), matvec(transpose(b), u)), v)]
    lhs = qf(h, u + v)
    rhs = qf(d, w) + qf(s, u)
    print(f"  completion of the square : L(u,v) = {lhs:.10f}   split = {rhs:.10f}")

    vs = v_star(b, d, u)
    l_star, l_schur, l_rtn = qf(h, u + vs), qf(s, u), qf(a, u)
    print(f"  attainment               : L(u,v*) = {l_star:.10f}   u^T S u = {l_schur:.10f}")
    worst = min(qf(h, u + [x + rng.gauss(0, 0.1) for x in vs]) for _ in range(200))
    print(f"  lower bound              : best of 200 perturbed updates = {worst:.10f} >= {l_schur:.10f}")
    gain = qf(d, matvec(inverse(d), matvec(transpose(b), u)))
    print(f"  exact gain               : RTN - Schur = {l_rtn - l_schur:.10f}   ||D^-1 B^T u||_D^2 = {gain:.10f}")
    print(f"  compensation ratio       : Schur / RTN = {l_schur / l_rtn:.4f}  (<= 1)")

    # strictness iff B^T u != 0: build a B whose transpose kills a chosen u
    u0 = [1.0, -2.0, 0.5]
    b0 = [row[:] for row in b]
    # project each column of B onto the orthogonal complement of u0
    nu = dot(u0, u0)
    for j in range(n - k):
        col = [b0[i][j] for i in range(k)]
        c = dot(col, u0) / nu
        for i in range(k):
            b0[i][j] = col[i] - c * u0[i]
    h0 = zeros(n, n)
    for i in range(n):
        for j in range(n):
            if i < k and j < k:
                h0[i][j] = a[i][j]
            elif i < k:
                h0[i][j] = b0[i][j - k]
            elif j < k:
                h0[i][j] = b0[j][i - k]
            else:
                h0[i][j] = d[i - k][j - k]
    a0, bb, d0 = split(h0, k)
    print(f"  strictness               : if B^T u = 0 then RTN - Schur = "
          f"{qf(a0, u0) - qf(schur(a0, bb, d0), u0):.2e}  (no gain, as predicted)")

    # single column formula and diagonal inequality
    a1, b1, d1 = split(h, 1)
    e = 0.37
    hinv = inverse(h)
    l1 = qf(h, [e] + v_star(b1, d1, [e]))
    print(f"  GPTQ column cost         : L = {l1:.10f}   e^2/[H^-1]_qq = {e * e / hinv[0][0]:.10f}"
          f"   RTN cost H_qq e^2 = {h[0][0] * e * e:.6f}")
    prods = [h[i][i] * hinv[i][i] for i in range(n)]
    print(f"  H_qq [H^-1]_qq >= 1      : min over q = {min(prods):.4f}, max = {max(prods):.4f}")

    # wider window never hurts
    narrow = [schur(a, block(b, range(k), range(j)), block(d, range(j), range(j))) if j else a
              for j in range(n - k + 1)]
    losses = [qf(m, u) for m in narrow]
    mono = all(x >= y - 1e-12 for x, y in zip(losses, losses[1:]))
    print("  window monotonicity      : loss vs window size =",
          " ".join(f"{x:.4f}" for x in losses), f"-> non-increasing: {mono}")

    # scale invariance
    for t in (0.5, 2.0, 8.0):
        tu = [t * x for x in u]
        print(f"  scale invariance t={t:<4}: Schur/RTN = {qf(s, tu) / qf(a, tu):.10f}")
    print()


# ----------------------------------------------------------------------------------------
# 2. Tail-share criterion
# ----------------------------------------------------------------------------------------
def tail_share(core_rtn: float, tail_rtn: float, core_gain: float, tail_gain: float) -> Tuple[float, float]:
    before = tail_rtn / (core_rtn + tail_rtn)
    after = (tail_rtn - tail_gain) / ((core_rtn - core_gain) + (tail_rtn - tail_gain))
    return before, after


def section_tail_share() -> None:
    print("=" * 78)
    print("2. Tail-share criterion: share drops iff tail's relative gain > core's")
    print("=" * 78)
    for core_rel, tail_rel in ((0.50, 0.70), (0.55, 0.55), (0.60, 0.40)):
        a, b = 0.25, 0.07
        before, after = tail_share(a, b, core_rel * a, tail_rel * b)
        print(f"  core gain {core_rel:.0%}, tail gain {tail_rel:.0%}:  "
              f"tail share {before:.3f} -> {after:.3f}  "
              f"({'drops' if after < before else 'rises' if after > before else 'unchanged'})")
    print()


# ----------------------------------------------------------------------------------------
# 3. Quantizers and the GPTQ algorithm on a synthetic layer
# ----------------------------------------------------------------------------------------
def minmax_grid(vals: Sequence[float], bits: int) -> Callable[[float], float]:
    """Asymmetric min-max uniform grid with 2^bits levels; returns the rounding map."""
    lo, hi = min(min(vals), 0.0), max(max(vals), 0.0)
    levels = 2 ** bits - 1
    scale = (hi - lo) / levels if hi > lo else 1.0
    zero = round(-lo / scale)

    def rnd(x: float) -> float:
        qv = min(max(round(x / scale) + zero, 0), levels)
        return (qv - zero) * scale

    return rnd


def rtn_row(w: Vec, bits: int, group: int) -> Vec:
    out: Vec = []
    for g0 in range(0, len(w), group):
        seg = w[g0:g0 + group]
        rnd = minmax_grid(seg, bits)
        out.extend(rnd(x) for x in seg)
    return out


def gptq_row(w: Vec, hinv_u: Mat, bits: int, group: int) -> Vec:
    """Column-sequential GPTQ for one output row.

    hinv_u is the upper Cholesky factor of H^{-1}.  Group scales are fixed when the
    sweep reaches the start of each group, using the *already compensated* weights.
    """
    w = w[:]
    n = len(w)
    q_out = [0.0] * n
    rnd: Callable[[float], float] = lambda x: x
    for q in range(n):
        if q % group == 0:
            rnd = minmax_grid(w[q:q + group], bits)
        q_out[q] = rnd(w[q])
        err = (w[q] - q_out[q]) / hinv_u[q][q]
        row = hinv_u[q]
        for j in range(q + 1, n):
            w[j] -= err * row[j]
    return q_out


def layer_loss(h: Mat, w: Mat, wq: Mat) -> float:
    return sum(qf(h, [x - y for x, y in zip(r, rq)]) for r, rq in zip(w, wq))


def section_ladder(rng: random.Random) -> None:
    print("=" * 78)
    print("3. Synthetic layer ladder: per-channel RTN -> grouped RTN -> grouped GPTQ")
    print("=" * 78)
    n, rows, group = 64, 12, 16
    h = random_spd(n, rng, correlation=0.85)
    # a few outlier input channels with large activations
    for c in (5, 41):
        for j in range(n):
            h[c][j] *= 3.0
            h[j][c] *= 3.0
    damp = 0.01 * sum(h[i][i] for i in range(n)) / n
    hd = [[h[i][j] + (damp if i == j else 0.0) for j in range(n)] for i in range(n)]
    u_chol = cholesky_upper(inverse(hd))
    w = [[rng.gauss(0, 1) * (4.0 if rng.random() < 0.03 else 1.0) for _ in range(n)]
         for _ in range(rows)]
    print(f"  layer: {rows} rows x {n} inputs, group size {group}, outlier inputs at columns 5 and 41")
    for bits in (4, 3):
        per_ch = layer_loss(h, w, [rtn_row(r, bits, n) for r in w])
        grp = layer_loss(h, w, [rtn_row(r, bits, group) for r in w])
        gq = layer_loss(h, w, [gptq_row(r, u_chol, bits, group) for r in w])
        print(f"  {bits}-bit: per-channel RTN {per_ch:9.4f} | grouped RTN {grp:8.4f} | "
              f"grouped GPTQ {gq:8.4f}   levers x{per_ch / grp:.2f}, x{grp / gq:.2f}")
    # telescoping check: GPTQ loss equals sum of per-column costs e_q^2 / U_qq^2 (no clipping changes)
    r = w[0]
    wq = gptq_row(r, u_chol, 4, group)
    wcur, tele = r[:], 0.0
    for q in range(n):
        e = wcur[q] - wq[q]
        tele += (e / u_chol[q][q]) ** 2
        err = e / u_chol[q][q]
        for j in range(q + 1, n):
            wcur[j] -= err * u_chol[q][j]
    print(f"  telescoping (one row, damped curvature): actual {qf(hd, [x - y for x, y in zip(r, wq)]):.6f}"
          f"  sum of column costs {tele:.6f}")
    print()


# ----------------------------------------------------------------------------------------
# 4. Measured ladder in exact arithmetic
# ----------------------------------------------------------------------------------------
def section_measured() -> None:
    print("=" * 78)
    print("4. Measured ladder (0.5B model, context 512), exact rational arithmetic")
    print("=" * 78)
    per4, grp4, gq4, core4 = Fraction(788, 1000), Fraction(318, 1000), Fraction(1512, 10000), Fraction(1235, 10000)
    per3, grp3, gq3 = Fraction(923, 100), Fraction(272, 100), Fraction(11932, 10000)
    print(f"  P1 bar 0.15 vs GPTQ 4-bit {float(gq4)}: exceeds by {gq4 - Fraction(15, 100)} "
          f"= {float(gq4 - Fraction(15, 100))}  -> bar missed in exact arithmetic")
    inc = gq4 - core4
    print(f"  tail increment ALL - CORE = {inc} = {float(inc)};  tail share = {float(inc / gq4):.4f} "
          f"(in (1/6, 1/5): {Fraction(1, 6) < inc / gq4 < Fraction(1, 5)}; below 1/4)")
    l4, l3 = grp4 / gq4, grp3 / gq3
    print(f"  compensation lever: 4-bit {float(l4):.4f}, 3-bit {float(l3):.4f}, drift {float(l3 / l4):.4f}")
    g4, g3 = per4 / grp4, per3 / grp3
    print(f"  grouping lever    : 4-bit {float(g4):.4f}, 3-bit {float(g3):.4f}, drift {float(g3 / g4):.4f}")
    print(f"  compounded lever  : 4-bit {float(per4 / gq4):.3f}, 3-bit {float(per3 / gq3):.3f}")
    print("  => a single quadratic model with rescaled errors would force equal compensation levers;")
    print(f"     they differ ({float(l4):.4f} != {float(l3):.4f}), so the error *shape* changed.")
    print()


# ----------------------------------------------------------------------------------------
# 5. Spectral heuristic (conjecture; numerics only)
# ----------------------------------------------------------------------------------------
def section_spectral(rng: random.Random) -> None:
    print("=" * 78)
    print("5. Spectral heuristic for the lever (open conjecture; illustration only)")
    print("=" * 78)
    n = 24
    for corr in (0.2, 0.6, 0.9):
        h = random_spd(n, rng, correlation=corr)
        hinv = inverse(h)
        predicted = sum(1.0 / hinv[i][i] for i in range(n)) / sum(h[i][i] for i in range(n))
        u_chol = cholesky_upper(hinv)
        seq = sum(u_chol[i][i] ** -2 for i in range(n)) / sum(h[i][i] for i in range(n))
        print(f"  feature correlation {corr:.1f}: one-shot column ratio tr(diag(H^-1)^-1)/tr H = "
              f"{predicted:.4f};  sequential pivot ratio = {seq:.4f}")
    print()


def main() -> None:
    rng = random.Random(53)
    section_identities(rng)
    section_tail_share()
    section_ladder(rng)
    section_measured()
    section_spectral(rng)


if __name__ == "__main__":
    main()
