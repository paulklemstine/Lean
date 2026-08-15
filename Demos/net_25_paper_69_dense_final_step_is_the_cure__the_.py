"""
Dense Final-Step Inputs: numerical demonstrations.

Self-contained, dependency-free (standard library only) numerical examples for
the three halves of the dense-final-step law:

  1. TRANSITION HALF   -- the LSB-first base-b carry automaton satisfies the
     exact depth-uniform invariant  val(d,n) + c_n b^n = val(a,n) + val(b,n),
     and a learned step table that is pointwise correct on the 2*b^2 reachable
     triples (x, y, c), x, y < b, c <= 1, is automatically correct at EVERY
     depth.  A single local error is shown to break the chain immediately.

  2. BOUNDARY HALF     -- the end-of-sequence (EOS) vector acts on the cell only
     through v = W e.  For every width d >= 1 the realisable set of v is all of
     R^h (no expressivity gain), while gradient flow on the factors induces
        v_dot = -(||e||^2 I + W W^T) g,
     whose descent rate  <g, -v_dot> = ||e||^2 ||g||^2 + ||W^T g||^2  is at
     least d c^2 ||g||^2 -- linear in the EOS width.  Hence the quadratic
     boundary loss contracts like exp(-2 d c^2 t) and the sufficient training
     budget scales like 1/d.

  3. HORIZON HALF      -- a contractive cell (||A z|| <= lam ||z||, lam < 1)
     has a finite state horizon for every bounded linear readout, and a
     final-step gain m extends usable depth by only k >= log m / log(1/lam).

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]
StepTable = Dict[Tuple[int, int, int], Tuple[int, int]]

# ---------------------------------------------------------------------------
# Section 1 -- the carry automaton and local-to-global transfer
# ---------------------------------------------------------------------------


def carry_stream(base: int, a: Sequence[int], b: Sequence[int]) -> List[int]:
    """Carry states c_0 .. c_n of LSB-first base-`base` addition (c_0 = 0)."""
    c = 0
    out = [0]
    for x, y in zip(a, b):
        c = (x + y + c) // base
        out.append(c)
    return out


def digit_stream(base: int, a: Sequence[int], b: Sequence[int]) -> List[int]:
    """Digits d_0 .. d_{n-1} emitted by the carry automaton."""
    c = 0
    out: List[int] = []
    for x, y in zip(a, b):
        s = x + y + c
        out.append(s % base)
        c = s // base
    return out


def val(base: int, f: Sequence[int]) -> int:
    """Value of an LSB-first digit list: sum_i f_i * base^i."""
    return sum(d * base ** i for i, d in enumerate(f))


def check_invariant(base: int, a: Sequence[int], b: Sequence[int]) -> bool:
    """val(d, n) + c_n * base^n == val(a, n) + val(b, n) at depth n = len(a)."""
    n = len(a)
    d = digit_stream(base, a, b)
    c = carry_stream(base, a, b)
    return val(base, d) + c[n] * base ** n == val(base, a) + val(base, b)


def true_step_table(base: int) -> StepTable:
    """The exact transition on the 2 * base^2 reachable triples."""
    return {
        (x, y, c): ((x + y + c) % base, (x + y + c) // base)
        for x in range(base)
        for y in range(base)
        for c in (0, 1)
    }


def is_locally_correct(base: int, table: StepTable) -> bool:
    """Pointwise correctness on every reachable triple (x, y, c), x,y<base, c<=1."""
    truth = true_step_table(base)
    return all(table.get(k) == v for k, v in truth.items())


def run_step_table(
    base: int, table: StepTable, a: Sequence[int], b: Sequence[int]
) -> Tuple[List[int], int]:
    """Unroll a learned step table; returns (emitted digits, terminal carry)."""
    c = 0
    out: List[int] = []
    for x, y in zip(a, b):
        digit, c = table[(x, y, c)]
        out.append(digit)
    return out, c


def demo_transition(base: int = 10, seed: int = 0) -> None:
    print("=" * 78)
    print("1. TRANSITION HALF -- the carry chain is exactly length-general")
    print("=" * 78)
    rng = random.Random(seed)

    print(f"\nreachable triples for base {base}: {2 * base * base}"
          " (all exercised by depth >= 2 data)")
    print("\ninvariant  val(d,n) + c_n*b^n == val(a,n) + val(b,n)  at many depths:")
    for n in (1, 2, 5, 8, 16, 64, 256, 1024):
        ok = all(
            check_invariant(
                base,
                [rng.randrange(base) for _ in range(n)],
                [rng.randrange(base) for _ in range(n)],
            )
            for _ in range(50)
        )
        print(f"   depth n = {n:5d}   50 random pairs   invariant holds: {ok}")

    table = true_step_table(base)
    print(f"\nlearned table locally correct on all reachable triples: "
          f"{is_locally_correct(base, table)}")
    print("local-to-global transfer -> exact sum at every depth:")
    for n in (5, 6, 7, 8, 32, 512):
        a = [rng.randrange(base) for _ in range(n)]
        b = [rng.randrange(base) for _ in range(n)]
        d, c = run_step_table(base, table, a, b)
        lhs = val(base, d) + c * base ** n
        rhs = val(base, a) + val(base, b)
        print(f"   n = {n:4d}  model sum == true sum: {lhs == rhs}")

    # Sharpness: corrupt exactly one reachable triple.
    bad = dict(table)
    bad[(3, 4, 0)] = ((3 + 4) % base + 1, 0)
    print("\nsharpness -- corrupt ONE reachable triple (3,4,0):")
    a = [3] * 8
    b = [4] * 8
    d, c = run_step_table(base, bad, a, b)
    lhs = val(base, d) + c * base ** 8
    rhs = val(base, a) + val(base, b)
    print(f"   locally correct: {is_locally_correct(base, bad)}")
    print(f"   depth-8 sum correct: {lhs == rhs}  (a single local error breaks it)")


# ---------------------------------------------------------------------------
# Section 2 -- the boundary pathway
# ---------------------------------------------------------------------------


def mat_vec(matrix: Matrix, x: Vector) -> Vector:
    return [sum(row[j] * x[j] for j in range(len(x))) for row in matrix]


def matT_vec(matrix: Matrix, g: Vector) -> Vector:
    d = len(matrix[0])
    return [sum(matrix[i][j] * g[i] for i in range(len(matrix))) for j in range(d)]


def dot(x: Vector, y: Vector) -> float:
    return sum(xi * yi for xi, yi in zip(x, y))


def sq_norm(x: Vector) -> float:
    return dot(x, x)


def boundary_bias(matrix: Matrix, e: Vector) -> Vector:
    """v = W e -- the whole effect of the learned EOS vector on the cell."""
    return mat_vec(matrix, e)


def realise_boundary_bias(v: Vector, d: int) -> Tuple[Matrix, Vector]:
    """Constructive surjectivity: for ANY width d >= 1 produce (W, e) with W e = v."""
    if d < 1:
        raise ValueError("EOS width must be at least 1")
    matrix: Matrix = [[v[i] for _ in range(d)] for i in range(len(v))]
    e: Vector = [1.0] + [0.0] * (d - 1)
    return matrix, e


def boundary_drift(matrix: Matrix, e: Vector, g: Vector) -> Vector:
    """Induced velocity of v = W e under gradient flow on the factors (W, e)."""
    # W_dot = -g e^T, e_dot = -W^T g, v_dot = W_dot e + W e_dot
    term1 = [-g_i * dot(e, e) for g_i in g]
    term2 = [-x for x in mat_vec(matrix, matT_vec(matrix, g))]
    return [t1 + t2 for t1, t2 in zip(term1, term2)]


def boundary_drift_closed_form(matrix: Matrix, e: Vector, g: Vector) -> Vector:
    """-(||e||^2 I + W W^T) g."""
    wwt_g = mat_vec(matrix, matT_vec(matrix, g))
    return [-(sq_norm(e) * g_i + w_i) for g_i, w_i in zip(g, wwt_g)]


def boundary_gain(matrix: Matrix, e: Vector, g: Vector) -> float:
    """<g, -v_dot> = ||e||^2 ||g||^2 + ||W^T g||^2."""
    drift = boundary_drift(matrix, e, g)
    return sum(gi * (-di) for gi, di in zip(g, drift))


def random_matrix(h: int, d: int, scale: float, rng: random.Random) -> Matrix:
    return [[rng.gauss(0.0, scale) for _ in range(d)] for _ in range(h)]


def eos_vector(d: int, c: float, rng: random.Random) -> Vector:
    """Per-coordinate magnitude exactly c (random signs)."""
    return [c if rng.random() < 0.5 else -c for _ in range(d)]


def budget(loss0: float, eps: float, kappa: float) -> float:
    """Sufficient training time log(L0/eps) / (2 kappa)."""
    return math.log(loss0 / eps) / (2.0 * kappa)


def simulate_boundary_flow(
    h: int, d: int, c: float, steps: int, dt: float, seed: int
) -> List[float]:
    """Euler-integrate the factorised flow; return the boundary-loss trajectory."""
    rng = random.Random(seed)
    matrix = random_matrix(h, d, 0.0, rng)  # W = 0: the sharp case, gain = ||e||^2||g||^2
    e = eos_vector(d, c, rng)
    v: Vector = [rng.gauss(0.0, 1.0) for _ in range(h)]
    v_star: Vector = [0.0] * h
    trajectory: List[float] = []
    for _ in range(steps):
        g = [vi - si for vi, si in zip(v, v_star)]
        trajectory.append(0.5 * sq_norm(g))
        drift = boundary_drift(matrix, e, g)
        v = [vi + dt * di for vi, di in zip(v, drift)]
    return trajectory


def demo_boundary(h: int = 12, seed: int = 1) -> None:
    print()
    print("=" * 78)
    print("2. BOUNDARY HALF -- invisible to the class, visible to the optimiser")
    print("=" * 78)
    rng = random.Random(seed)
    target: Vector = [rng.gauss(0.0, 1.0) for _ in range(h)]

    print("\nexpressivity invariance: ANY target boundary bias is realisable at ANY width")
    for d in (1, 2, 20, 28, 384):
        matrix, e = realise_boundary_bias(target, d)
        err = max(abs(x - y) for x, y in zip(boundary_bias(matrix, e), target))
        print(f"   EOS width d = {d:4d}   max |W e - v*| = {err:.2e}")

    print("\nclosed form of the drift:  v_dot = -(||e||^2 I + W W^T) g")
    matrix = random_matrix(h, 20, 0.3, rng)
    e = eos_vector(20, 0.5, rng)
    g: Vector = [rng.gauss(0.0, 1.0) for _ in range(h)]
    lhs = boundary_drift(matrix, e, g)
    rhs = boundary_drift_closed_form(matrix, e, g)
    print(f"   max discrepancy: {max(abs(x - y) for x, y in zip(lhs, rhs)):.3e}")

    print("\nexact descent rate  <g,-v_dot> = ||e||^2||g||^2 + ||W^T g||^2,"
          "  bound  d c^2 ||g||^2")
    c = 0.5
    print(f"   {'d':>5} {'exact gain':>14} {'bound d c^2 |g|^2':>20} {'ratio':>8}")
    for d in (20, 28, 40, 64, 96, 160, 256, 384):
        matrix = random_matrix(h, d, 0.05, rng)
        e = eos_vector(d, c, rng)
        gain = boundary_gain(matrix, e, g)
        bound = d * c * c * sq_norm(g)
        print(f"   {d:5d} {gain:14.4f} {bound:20.4f} {gain / bound:8.3f}")

    print("\nsharpness at W = 0: gain equals ||e||^2 ||g||^2 exactly")
    zero: Matrix = [[0.0] * 20 for _ in range(h)]
    e = eos_vector(20, c, rng)
    print(f"   gain = {boundary_gain(zero, e, g):.6f}   "
          f"||e||^2||g||^2 = {sq_norm(e) * sq_norm(g):.6f}")

    print("\ncontraction  L(t) <= L(0) exp(-2 d c^2 t)  (Euler simulation, W = 0)")
    dt = 0.002
    for d in (20, 384):
        traj = simulate_boundary_flow(h, d, c, steps=400, dt=dt, seed=7)
        t_end = dt * (len(traj) - 1)
        predicted = traj[0] * math.exp(-2 * d * c * c * t_end)
        print(f"   d = {d:4d}   L(0) = {traj[0]:.4f}   L(T) = {traj[-1]:.3e}   "
              f"bound = {predicted:.3e}   holds: {traj[-1] <= predicted * 1.000001}")

    print("\n1/d budget law:  t_suff = log(L0/eps) / (2 d c^2)")
    loss0, eps = 1.0, 1e-6
    for d in (20, 28, 384):
        print(f"   d = {d:4d}   sufficient time = {budget(loss0, eps, d * c * c):9.4f}")
    print(f"   speed-up 20 -> 384: {budget(loss0, eps, 20 * c * c) / budget(loss0, eps, 384 * c * c):.2f}x"
          f"   (= 384/20 = {384 / 20:.1f})")


# ---------------------------------------------------------------------------
# Section 3 -- the state horizon
# ---------------------------------------------------------------------------


def state_horizon(lam: float, delta: float, readout_norm: float, gamma: float) -> int:
    """Least N with lam^N * delta * R < gamma (0 if already below margin)."""
    if lam <= 0.0:
        return 1
    dr = delta * readout_norm
    if dr < gamma:
        return 0
    return math.ceil(math.log(gamma / dr) / math.log(lam))


def depth_bought(lam: float, gain: float) -> int:
    """Extra usable depth from a final-step gain m: ceil(log m / log(1/lam))."""
    if gain <= 1.0:
        return 0
    return math.ceil(math.log(gain) / math.log(1.0 / lam))


def simulate_margin(lam: float, delta: float, readout_norm: float, depth: int) -> float:
    """Worst-case readout separation after `depth` steps: lam^depth * delta * R."""
    return lam ** depth * delta * readout_norm


def demo_horizon() -> None:
    print()
    print("=" * 78)
    print("3. HORIZON HALF -- contraction, margins, and logarithmic depth")
    print("=" * 78)
    delta, readout_norm, gamma = 1.0, 1.0, 0.05

    print("\nstate horizon N (least depth at which every margin gamma = 0.05 is lost)")
    for lam in (0.5, 0.7, 0.8, 0.9, 0.95):
        n = state_horizon(lam, delta, readout_norm, gamma)
        print(f"   lam = {lam:4.2f}   N = {n:3d}   "
              f"separation at N = {simulate_margin(lam, delta, readout_norm, n):.4f}"
              f"  (< gamma: {simulate_margin(lam, delta, readout_norm, n) < gamma})")

    print("\nseed-to-seed spread: a distribution of horizons, not a hard wall")
    rng = random.Random(11)
    horizons = []
    for _ in range(12):
        lam = rng.uniform(0.55, 0.92)
        horizons.append(state_horizon(lam, rng.uniform(0.6, 1.4), 1.0, gamma))
    print(f"   sampled horizons: {sorted(horizons)}")

    print("\nboundary gain buys depth only logarithmically:"
          "  k = ceil(log m / log(1/lam))")
    lam = 0.8
    print(f"   {'EOS width d':>12} {'gain m = d/20':>14} {'extra depth k':>15}")
    for d in (20, 28, 40, 64, 96, 160, 256, 384):
        m = d / 20.0
        print(f"   {d:12d} {m:14.2f} {depth_bought(lam, m):15d}")
    print("   -> usable depth grows like a + b*log d with b = 1/log(1/lam)"
          f" = {1.0 / math.log(1.0 / lam):.3f}")

    print("\nverification of the depth-shift inequality  lam^(N+k) * m * DR < gamma")
    n0 = state_horizon(lam, delta, readout_norm, gamma) - 1
    for d in (28, 96, 384):
        m = d / 20.0
        k = depth_bought(lam, m)
        lhs = lam ** (n0 + k) * m * delta * readout_norm
        print(f"   d = {d:4d}  N = {n0}, k = {k}:  lhs = {lhs:.5f} < gamma = {gamma}:"
              f" {lhs < gamma}")


# ---------------------------------------------------------------------------
# Section 4 -- the measured control, replayed
# ---------------------------------------------------------------------------


def demo_measured_table() -> None:
    print()
    print("=" * 78)
    print("4. THE MEASURED CONTROL (identical cell/head weights per seed)")
    print("=" * 78)
    rows: List[Tuple[str, int, int, List[float]]] = [
        ("padded, dense EOS", 384, 335_242, [1.0, 1.0, 1.0, 1.0]),
        ("padded, narrow EOS", 20, 334_878, [0.7441, 0.0259]),
        ("untrained random projection", 384, 335_242, [1.0, 1.0]),
        ("raw + position", 28, 129_830, [0.0049, 0.0049]),
        ("capacity-matched raw", 20, 471_582, [0.0078, 0.0063]),
        ("raw baseline", 20, 125_214,
         [0.0806, 0.6997, 0.0103, 0.0063, 0.0093, 0.0020, 0.0132]),
    ]
    print(f"\n{'arm':<30}{'EOS d':>7}{'params':>10}{'mean n=8 full':>16}{'seeds':>7}")
    for name, d, params, accs in rows:
        print(f"{name:<30}{d:>7}{params:>10,}{sum(accs) / len(accs):>16.4f}{len(accs):>7}")
    print("\nchance level at n = 8 is 1e-9; the final-carry probe is 0.86-0.99 in EVERY arm,")
    print("so the transition never lost length-generality -- only the digit readout did.")
    wide = 1.0
    narrow = max(0.7441, 0.0259)
    print(f"\nsingle-variable flip (EOS 20 -> 384, identical weights): "
          f"{narrow:.4f} -> {wide:.4f}")


def main() -> None:
    demo_transition()
    demo_boundary()
    demo_horizon()
    demo_measured_table()
    print()
    print("=" * 78)
    print("SUMMARY: the transition is exactly length-general; EOS width adds no")
    print("representable function but multiplies the guaranteed gradient-flow gain")
    print("by d; and a contractive readout converts that gain into depth only")
    print("logarithmically.  Boundary-condition richness is the lever.")
    print("=" * 78)


if __name__ == "__main__":
    main()
