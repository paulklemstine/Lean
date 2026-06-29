"""
demo.py — Neural Network Training as Renormalization-Group (RG) Flow.

Numerical demonstrations of the five core theorems proved in
`RGFlowTraining.lean`, all in the Neural Tangent Kernel (NTK) regime:

  Definition  gain(eta, lam)        = 1 - eta * lam                 (per-mode gain)
  Definition  rgStep(eta, lam, v)_i = gain(eta, lam_i) * v_i        (one training step)

  Theorem 1 (rgStep_iterate)     (rgStep)^[k](v)_i = gain_i^k * v_i
  Theorem 2 (rgStep_semigroup)   iterate(k+m) = iterate(k) o iterate(m)
  Theorem 3 (rg_scale_separation) |gain_i| < |gain_j|  =>  |x_i(k)|/|x_j(k)| -> 0
  Theorem 4 (rgStep_fixed_iff)   rgStep(v)=v  <=>  lam_i * v_i = 0  for all i   (eta != 0)
  Theorem 5 (rg_flow_tendsto_zero) all |gain_i| < 1  =>  x(k) -> 0

This script is fully self-contained: it depends only on the Python standard library.
Run:  python demo.py
"""

from __future__ import annotations

from typing import List, Sequence


# --------------------------------------------------------------------------- #
# Core definitions (mirror the Lean development).
# --------------------------------------------------------------------------- #

def gain(eta: float, lam: float) -> float:
    """Per-mode gain of one training step: g = 1 - eta * lam (Definition 2.1)."""
    return 1.0 - eta * lam


def rg_step(eta: float, lam: Sequence[float], v: Sequence[float]) -> List[float]:
    """One renormalization-group / training step: rescale each mode by its gain."""
    return [gain(eta, lam_i) * v_i for lam_i, v_i in zip(lam, v)]


def rg_iterate(eta: float, lam: Sequence[float], v: Sequence[float], k: int) -> List[float]:
    """Apply rg_step k times by literal iteration (the definition of (rgStep)^[k])."""
    out = list(v)
    for _ in range(k):
        out = rg_step(eta, lam, out)
    return out


def rg_closed_form(eta: float, lam: Sequence[float], v: Sequence[float], k: int) -> List[float]:
    """Closed form from Theorem 3.1: mode i = gain_i^k * v_i."""
    return [gain(eta, lam_i) ** k * v_i for lam_i, v_i in zip(lam, v)]


# --------------------------------------------------------------------------- #
# Demo 1 — Closed form matches literal iteration (Theorem 3.1).
# --------------------------------------------------------------------------- #

def demo_closed_form() -> None:
    print("=" * 72)
    print("Demo 1: Closed form of the RG flow  (Theorem rgStep_iterate)")
    print("=" * 72)
    eta = 0.1
    lam = [0.5, 2.0, 5.0, 9.0]
    v = [1.0, 1.0, 1.0, 1.0]
    print(f"  learning rate eta = {eta}")
    print(f"  NTK eigenvalues   = {lam}")
    print(f"  gains g_i         = {[round(gain(eta, l), 4) for l in lam]}")
    print()
    for k in (0, 1, 5, 20):
        it = rg_iterate(eta, lam, v, k)
        cf = rg_closed_form(eta, lam, v, k)
        max_err = max(abs(a - b) for a, b in zip(it, cf))
        print(f"  k={k:>3}: iterate={[f'{x:.4e}' for x in it]}")
        print(f"        closed ={[f'{x:.4e}' for x in cf]}   max|diff|={max_err:.2e}")
    print()


# --------------------------------------------------------------------------- #
# Demo 2 — Semigroup law (Theorem 3.2).
# --------------------------------------------------------------------------- #

def demo_semigroup() -> None:
    print("=" * 72)
    print("Demo 2: RG semigroup law  (Theorem rgStep_semigroup)")
    print("=" * 72)
    eta = 0.05
    lam = [0.3, 1.1, 4.0]
    v = [2.0, -1.5, 0.7]
    k, m = 7, 11
    lhs = rg_iterate(eta, lam, v, k + m)
    rhs = rg_iterate(eta, lam, rg_iterate(eta, lam, v, m), k)
    max_err = max(abs(a - b) for a, b in zip(lhs, rhs))
    print(f"  iterate(k+m)        = {[f'{x:.4e}' for x in lhs]}")
    print(f"  iterate(k)(iterate(m)) = {[f'{x:.4e}' for x in rhs]}")
    print(f"  k={k}, m={m}:  max|diff| = {max_err:.2e}  (scale is additive)")
    print()


# --------------------------------------------------------------------------- #
# Demo 3 — Separation of scales (Theorem 3.3).
# --------------------------------------------------------------------------- #

def demo_scale_separation() -> None:
    print("=" * 72)
    print("Demo 3: Separation of scales  (Theorem rg_scale_separation)")
    print("=" * 72)
    eta = 0.1
    # Mode i is "fast" (large eigenvalue -> small gain), mode j is "slow".
    lam = [8.0, 0.5]
    v = [1.0, 1.0]
    gi, gj = abs(gain(eta, lam[0])), abs(gain(eta, lam[1]))
    print(f"  fast mode i: lam={lam[0]}, |gain|={gi:.4f}")
    print(f"  slow mode j: lam={lam[1]}, |gain|={gj:.4f}   (need |g_i| < |g_j|: {gi < gj})")
    print()
    for k in (0, 5, 10, 25, 50, 100):
        x = rg_closed_form(eta, lam, v, k)
        ratio = abs(x[0]) / abs(x[1]) if x[1] != 0 else 0.0
        print(f"  k={k:>4}: |x_i|/|x_j| = {ratio:.6e}")
    print("  -> the fast (high-frequency) mode is integrated out relative to the slow one.")
    print()


# --------------------------------------------------------------------------- #
# Demo 4 — Fixed points are the NTK kernel (Theorem 3.4).
# --------------------------------------------------------------------------- #

def is_fixed_point(eta: float, lam: Sequence[float], v: Sequence[float],
                   tol: float = 1e-12) -> bool:
    stepped = rg_step(eta, lam, v)
    return all(abs(a - b) <= tol for a, b in zip(stepped, v))


def in_ntk_kernel(lam: Sequence[float], v: Sequence[float], tol: float = 1e-12) -> bool:
    return all(abs(lam_i * v_i) <= tol for lam_i, v_i in zip(lam, v))


def demo_fixed_points() -> None:
    print("=" * 72)
    print("Demo 4: IR fixed points = NTK kernel  (Theorem rgStep_fixed_iff, eta != 0)")
    print("=" * 72)
    eta = 0.1
    lam = [0.0, 0.0, 3.0]   # modes 0,1 are in the kernel; mode 2 is active
    print(f"  eta = {eta},  eigenvalues = {lam}")
    candidates = {
        "v=(1,1,0) in kernel ": [1.0, 1.0, 0.0],
        "v=(1,1,1) not kernel": [1.0, 1.0, 1.0],
        "v=(0,5,0) in kernel ": [0.0, 5.0, 0.0],
        "v=(0,0,2) not kernel": [0.0, 0.0, 2.0],
    }
    for label, v in candidates.items():
        fp = is_fixed_point(eta, lam, v)
        ker = in_ntk_kernel(lam, v)
        match = "OK" if fp == ker else "MISMATCH!"
        print(f"  {label}: fixed_point={fp!s:>5}  in_kernel={ker!s:>5}  [{match}]")
    print("  -> a residual rests iff it lives in ker(Theta) (lam_i * v_i = 0 for all i).")
    print()


# --------------------------------------------------------------------------- #
# Demo 5 — Global convergence when all gains contract (Theorem 3.5).
# --------------------------------------------------------------------------- #

def demo_global_convergence() -> None:
    print("=" * 72)
    print("Demo 5: Flow to the IR fixed point  (Theorem rg_flow_tendsto_zero)")
    print("=" * 72)
    eta = 0.1
    lam = [1.0, 3.0, 6.0, 9.0]            # all gains |1 - eta*lam| < 1
    v = [1.0, -2.0, 0.5, 3.0]
    gains = [abs(gain(eta, l)) for l in lam]
    print(f"  eta={eta}, eigenvalues={lam}")
    print(f"  |gains| = {[round(g, 4) for g in gains]}   all < 1: {all(g < 1 for g in gains)}")
    print()
    for k in (0, 10, 25, 50, 100, 200):
        x = rg_closed_form(eta, lam, v, k)
        norm = sum(xi * xi for xi in x) ** 0.5
        print(f"  k={k:>4}: ||x(k)|| = {norm:.6e}")
    print("  -> a well-conditioned (positive-definite) NTK drives the residual to 0.")
    print()


# --------------------------------------------------------------------------- #
# Bonus — loss-curve scaling governed by the slowest mode (future direction).
# --------------------------------------------------------------------------- #

def demo_loss_scaling() -> None:
    print("=" * 72)
    print("Bonus: Loss curve L_k = sum_i (g_i^k v_i)^2 dominated by the slowest mode")
    print("=" * 72)
    eta = 0.1
    lam = [0.5, 2.0, 7.0]
    v = [1.0, 1.0, 1.0]
    g_max = max(abs(gain(eta, l)) for l in lam)   # slowest-contracting gain
    print(f"  eta={eta}, eigenvalues={lam}, g_max={g_max:.4f}")
    print()
    for k in (1, 5, 10, 20, 40, 80):
        x = rg_closed_form(eta, lam, v, k)
        loss = sum(xi * xi for xi in x)
        rescaled = loss / (g_max ** (2 * k))
        print(f"  k={k:>3}: L_k = {loss:.6e}   L_k / g_max^(2k) = {rescaled:.6f}")
    print("  -> the rescaled loss approaches a mode-count constant (scaling collapse).")
    print()


def main() -> None:
    demo_closed_form()
    demo_semigroup()
    demo_scale_separation()
    demo_fixed_points()
    demo_global_convergence()
    demo_loss_scaling()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
