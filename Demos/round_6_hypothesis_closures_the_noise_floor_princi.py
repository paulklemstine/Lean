"""
The Noise-Floor Principle and the Capacity Frontier of Spectral Learning
=========================================================================

Self-contained numerical demonstration (standard library only).

Setting
-------
A spectral learning problem is described by a nonnegative signal spectrum
``a = (a_0, ..., a_{n-1})`` and a per-mode noise level ``b > 0`` (in fixed-design
regression, ``b = sigma^2 / N``).  A *spectral filter* is a vector ``t`` of
per-mode shrinkage coefficients; its excess risk is

    R(t) = sum_i [ a_i (1 - t_i)^2 + b t_i^2 ].

Results demonstrated here
-------------------------
1.  Noise-Floor Principle:  min_t R(t) = N(a,b) = sum_i a_i b / (a_i + b),
    attained uniquely by the Wiener filter t_i = a_i/(a_i+b).
2.  Trace lemma:  d_eff = sum_i a_i/(a_i+b) = tr(A (A + b I)^{-1}).
3.  Capacity frontier:  d_eff <= sum_i log(1 + a_i/b) <= (sum_i a_i)/b, and in
    risk form  N <= b log det(I + A/b) <= tr A.  Strict at one mode at
    threshold: 1/2 < log 2 < 1.
4.  Head/tail sandwich:  (1/2) sum_i min(a_i,b) <= N <= sum_i min(a_i,b).
5.  Ridge rigidity and the sharp 4/3 gap on a = (1,0), b = 1.
6.  Early stopping vs matched ridge: factor 4 one way, unbounded the other.
7.  Minimax spectrum: the flat spectrum of energy S maximises N, with value
    S b n / (S + n b).
8.  Geometric spectrum scaling law:  N  ~  b log(1/b).
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------


def filter_risk(a: Sequence[float], b: float, t: Sequence[float]) -> float:
    """Excess risk of the spectral filter ``t``: bias + variance, mode by mode."""
    return sum(ai * (1.0 - ti) ** 2 + b * ti ** 2 for ai, ti in zip(a, t))


def wiener_filter(a: Sequence[float], b: float) -> List[float]:
    """The unique risk-minimising filter: t_i = a_i / (a_i + b)."""
    return [ai / (ai + b) for ai in a]


def eff_dim(a: Sequence[float], b: float) -> float:
    """Effective dimension d_eff = sum_i a_i / (a_i + b): a soft mode count."""
    return sum(ai / (ai + b) for ai in a)


def noise_floor(a: Sequence[float], b: float) -> float:
    """Irreducible risk N(a,b) = b * d_eff(a,b) = sum_i a_i b / (a_i + b)."""
    return b * eff_dim(a, b)


def capacity(a: Sequence[float], b: float) -> float:
    """Gaussian channel capacity C(a,b) = sum_i log(1 + a_i/b), in nats."""
    return sum(math.log1p(ai / b) for ai in a)


def min_sum(a: Sequence[float], b: float) -> float:
    """m(a,b) = sum_i min(a_i, b): the head/tail proxy for the floor."""
    return sum(min(ai, b) for ai in a)


def ridge_filter(mu: Sequence[float], lam: float) -> List[float]:
    """Ridge/Tikhonov filter t_i = mu_i / (mu_i + lam)."""
    return [m / (m + lam) for m in mu]


def grad_flow_filter(mu: Sequence[float], tau: float) -> List[float]:
    """Gradient-flow (early stopping) filter t_i = 1 - exp(-mu_i tau)."""
    return [1.0 - math.exp(-m * tau) for m in mu]


# ----------------------------------------------------------------------------
# Small dense linear algebra (no numpy): Jacobi eigenvalues, Cholesky logdet
# ----------------------------------------------------------------------------


def jacobi_eigenvalues(matrix: Sequence[Sequence[float]],
                       sweeps: int = 100,
                       tol: float = 1e-13) -> List[float]:
    """Eigenvalues of a real symmetric matrix by the cyclic Jacobi method."""
    n = len(matrix)
    A = [list(map(float, row)) for row in matrix]
    for _ in range(sweeps):
        off = math.sqrt(sum(A[p][q] ** 2 for p in range(n) for q in range(n) if p != q))
        if off < tol:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(A[p][q]) < tol:
                    continue
                theta = (A[q][q] - A[p][p]) / (2.0 * A[p][q])
                sign = 1.0 if theta >= 0 else -1.0
                t = sign / (abs(theta) + math.sqrt(theta * theta + 1.0))
                c = 1.0 / math.sqrt(t * t + 1.0)
                s = t * c
                for k in range(n):
                    akp, akq = A[k][p], A[k][q]
                    A[k][p] = c * akp - s * akq
                    A[k][q] = s * akp + c * akq
                for k in range(n):
                    apk, aqk = A[p][k], A[q][k]
                    A[p][k] = c * apk - s * aqk
                    A[q][k] = s * apk + c * aqk
    return sorted((A[i][i] for i in range(n)), reverse=True)


def cholesky_logdet(matrix: Sequence[Sequence[float]]) -> float:
    """log det of a symmetric positive definite matrix via Cholesky (stable)."""
    n = len(matrix)
    L = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1):
            s = sum(L[i][k] * L[j][k] for k in range(j))
            if i == j:
                L[i][i] = math.sqrt(matrix[i][i] - s)
            else:
                L[i][j] = (matrix[i][j] - s) / L[j][j]
    return 2.0 * sum(math.log(L[i][i]) for i in range(n))


def random_psd(n: int, rng: random.Random) -> List[List[float]]:
    """A random positive semidefinite matrix G G^T with G Gaussian."""
    G = [[rng.gauss(0.0, 1.0) for _ in range(n)] for _ in range(n)]
    return [[sum(G[i][k] * G[j][k] for k in range(n)) / n for j in range(n)]
            for i in range(n)]


def trace(matrix: Sequence[Sequence[float]]) -> float:
    return sum(matrix[i][i] for i in range(len(matrix)))


def add_scaled_identity(matrix: Sequence[Sequence[float]],
                        scale: float) -> List[List[float]]:
    """Return I + scale * matrix."""
    n = len(matrix)
    return [[(1.0 if i == j else 0.0) + scale * matrix[i][j] for j in range(n)]
            for i in range(n)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_noise_floor_principle() -> None:
    banner("1.  The Noise-Floor Principle: no filter beats b * d_eff")
    rng = random.Random(20260813)
    a = [4.0, 1.5, 0.6, 0.2, 0.05, 0.01]
    b = 0.25
    floor = noise_floor(a, b)
    w = wiener_filter(a, b)
    print(f"spectrum a = {a}")
    print(f"noise level b = {b}")
    print(f"d_eff      = {eff_dim(a, b):.6f}")
    print(f"noise floor= {floor:.6f}   (= b * d_eff)")
    print(f"R(Wiener)  = {filter_risk(a, b, w):.6f}   (equals the floor)")

    worst = math.inf
    for _ in range(200000):
        t = [rng.uniform(-0.5, 1.5) for _ in a]
        worst = min(worst, filter_risk(a, b, t))
    print(f"best of 200000 random filters = {worst:.6f}  (>= floor: {worst >= floor - 1e-12})")

    # perturbing the Wiener filter strictly increases the risk
    for eps in (1e-3, 1e-2, 1e-1):
        t = [wi + eps for wi in w]
        print(f"  R(Wiener + {eps:<6g}) - floor = {filter_risk(a, b, t) - floor:.3e}")


def demo_trace_lemma() -> None:
    banner("2.  Trace lemma: d_eff = tr(A (A + b I)^{-1}) for a covariance A")
    rng = random.Random(7)
    n = 5
    A = random_psd(n, rng)
    b = 0.3
    mu = jacobi_eigenvalues(A)
    print("eigenvalues of A:", "  ".join(f"{m:.5f}" for m in mu))
    print(f"d_eff from spectrum         = {eff_dim(mu, b):.10f}")
    # tr(A (A+bI)^{-1}) = n - b * tr((A+bI)^{-1}) = sum mu_i/(mu_i+b) via spectrum
    via_resolvent = n - b * sum(1.0 / (m + b) for m in mu)
    print(f"n - b*tr((A+bI)^-1)         = {via_resolvent:.10f}")
    print(f"trace A                     = {trace(A):.10f}")
    print(f"sum of eigenvalues          = {sum(mu):.10f}")


def demo_capacity_frontier() -> None:
    banner("3.  The capacity frontier:  N  <=  b log det(I + A/b)  <=  tr A")
    rng = random.Random(99)
    print(f"{'n':>3} {'b':>7} {'floor N':>12} {'b*capacity':>12} {'trace A':>12}  ordered")
    for trial in range(6):
        n = 3 + trial
        A = random_psd(n, rng)
        b = 10.0 ** rng.uniform(-1.5, 0.5)
        mu = [max(m, 0.0) for m in jacobi_eigenvalues(A)]
        floor = noise_floor(mu, b)
        cap_b = b * cholesky_logdet(add_scaled_identity(A, 1.0 / b))
        tr = trace(A)
        ok = floor <= cap_b + 1e-9 <= tr + 1e-9
        print(f"{n:>3} {b:>7.4f} {floor:>12.6f} {cap_b:>12.6f} {tr:>12.6f}  {ok}")

    print("\nAgreement of the two forms of the capacity (spectral vs log-det):")
    A = random_psd(6, random.Random(5))
    b = 0.4
    mu = [max(m, 0.0) for m in jacobi_eigenvalues(A)]
    print(f"  sum_i log(1 + mu_i/b) = {capacity(mu, b):.10f}")
    print(f"  log det(I + A/b)      = {cholesky_logdet(add_scaled_identity(A, 1/b)):.10f}")

    print("\nStrictness at one mode at the noise level (a = b = 1):")
    print(f"  d_eff = {eff_dim([1.0], 1.0):.6f}")
    print(f"  C     = {capacity([1.0], 1.0):.6f}   (= log 2)")
    print(f"  tr/b  = {1.0:.6f}")
    print("  0.5 < 0.693147 < 1  -> both inequalities are strict")

    print("\nHow lossy is the trace bound at high SNR?  (one mode, b = 1)")
    print(f"{'a':>10} {'d_eff':>10} {'capacity':>10} {'a/b':>12}")
    for a in (1.0, 10.0, 100.0, 1e4, 1e8):
        print(f"{a:>10.0f} {eff_dim([a],1.0):>10.6f} {capacity([a],1.0):>10.4f} {a:>12.0f}")


def demo_head_tail() -> None:
    banner("4.  Head/tail sandwich:  m/2 <= N <= m  with  m = b|head| + tail energy")
    b = 1.0
    spectra = {
        "all resolvable (a_i = 4)": [4.0] * 6,
        "all drowned  (a_i = 0.1)": [0.1] * 6,
        "mixed": [9.0, 4.0, 1.0, 0.5, 0.05, 0.001],
        "at threshold (a_i = b)": [1.0] * 6,
    }
    for name, a in spectra.items():
        head = [ai for ai in a if ai >= b]
        tail = [ai for ai in a if ai < b]
        m = b * len(head) + sum(tail)
        N = noise_floor(a, b)
        print(f"{name:<26} |head|={len(head)} tail_energy={sum(tail):.4f} "
              f"m={m:.4f}  N={N:.4f}  ratio N/m={N/m:.4f}")
    print("\nCorollary (no learning below the noise): with all a_i <= b,")
    a = [0.1] * 6
    print(f"  R(do nothing) = {filter_risk(a, b, [0.0]*6):.4f},  "
          f"N = {noise_floor(a,b):.4f},  ratio = {filter_risk(a,b,[0.0]*6)/noise_floor(a,b):.4f} <= 2")


def demo_ridge_gap() -> None:
    banner("5.  Ridge rigidity and the sharp 4/3 gap")
    a = [1.0, 0.0]
    mu = [1.0, 1.0]
    b = 1.0
    N = noise_floor(a, b)
    print(f"a = {a}, flat covariance mu = {mu}, b = {b}")
    print(f"noise floor = {N}   Wiener filter = {wiener_filter(a,b)}")
    best_c, best_r = None, math.inf
    for k in range(0, 10001):
        c = k / 10000.0
        r = filter_risk(a, b, [c, c])
        if r < best_r:
            best_c, best_r = c, r
    print(f"best constant (ridge) filter: c = {best_c:.4f}, risk = {best_r:.6f}")
    print(f"ratio to floor = {best_r / N:.6f}   (theory: exactly 4/3 = {4/3:.6f} at c = 1/3)")

    print("\nRidge attains the floor iff a_i * lam = mu_i * b for all i:")
    mu2 = [3.0, 0.5, 2.0]
    lam = 0.7
    b2 = 0.35
    a_iso = [m * b2 / lam for m in mu2]          # satisfies the isotropy relation
    a_gen = [1.0, 0.2, 0.05]                     # generic spectrum
    for label, aa in (("isotropy relation holds", a_iso), ("generic spectrum", a_gen)):
        r = filter_risk(aa, b2, ridge_filter(mu2, lam))
        print(f"  {label:<26} R(ridge)/N = {r / noise_floor(aa, b2):.6f}")


def demo_early_stopping() -> None:
    banner("6.  Early stopping vs matched ridge (lam = 1/tau)")
    rng = random.Random(2024)
    print("Random problems: ratio R(gradient flow) / R(matched ridge) -- theory says <= 4")
    worst = 0.0
    for _ in range(20000):
        n = rng.randint(1, 6)
        mu = [10.0 ** rng.uniform(-2, 2) for _ in range(n)]
        a = [10.0 ** rng.uniform(-3, 3) for _ in range(n)]
        b = 10.0 ** rng.uniform(-3, 1)
        tau = 10.0 ** rng.uniform(-2, 2)
        rg = filter_risk(a, b, grad_flow_filter(mu, tau))
        rr = filter_risk(a, b, ridge_filter(mu, 1.0 / tau))
        worst = max(worst, rg / rr)
    print(f"  worst observed ratio over 20000 random problems: {worst:.4f}  (<= 4)")

    print("\nThe converse fails: one mode, mu = 1, b = 1, a = e^20, tau = 10")
    a = [math.exp(20.0)]
    mu = [1.0]
    b, tau = 1.0, 10.0
    rg = filter_risk(a, b, grad_flow_filter(mu, tau))
    rr = filter_risk(a, b, ridge_filter(mu, 1.0 / tau))
    print(f"  early stopping risk = {rg:.6f}")
    print(f"  matched ridge risk  = {rr:.6f}")
    print(f"  ridge / early stop  = {rr / rg:.1f}   (theory: at least 100)")
    print(f"  both above the floor N = {noise_floor(a, b):.6f}: "
          f"{rg >= noise_floor(a,b) and rr >= noise_floor(a,b)}")


def demo_minimax() -> None:
    banner("7.  The hardest spectrum at fixed energy is the flat one")
    rng = random.Random(31337)
    n, S, b = 8, 4.0, 0.5
    predicted = S * b * n / (S + n * b)
    flat = noise_floor([S / n] * n, b)
    print(f"n = {n}, energy S = {S}, b = {b}")
    print(f"minimax value S b n / (S + n b) = {predicted:.6f}")
    print(f"floor at the flat spectrum      = {flat:.6f}")
    worst = 0.0
    for _ in range(200000):
        raw = [rng.random() for _ in range(n)]
        tot = sum(raw)
        a = [S * x / tot for x in raw]
        worst = max(worst, noise_floor(a, b))
    print(f"max over 200000 random spectra of energy S = {worst:.6f}  (<= minimax)")
    print("\nRegimes:")
    for b_val in (0.001, 0.05, 0.5, 5.0, 50.0):
        v = S * b_val * n / (S + n * b_val)
        print(f"  b = {b_val:<7} minimax = {v:.6f}   min(S, n b) = {min(S, n*b_val):.6f}")


def demo_scaling_law() -> None:
    banner("8.  Geometric spectrum: the derived log-corrected 1/N law")
    r = 0.5
    n = 60
    a = [r ** i for i in range(n)]
    print(f"a_i = {r}^i, i < {n}")
    print(f"{'b':>10} {'m':>4} {'lower':>10} {'floor N':>10} {'upper':>10} {'N/(b log(1/b))':>16}")
    for b in (0.5, 0.1, 0.01, 1e-3, 1e-4, 1e-5):
        m = 0
        while r ** (m + 1) > b:
            m += 1
        lower = b * (m + 1) / 2.0
        upper = b * (m + 1) + b / (1.0 - r)
        N = noise_floor(a, b)
        ref = b * math.log(1.0 / b)
        print(f"{b:>10.5f} {m:>4} {lower:>10.5f} {N:>10.5f} {upper:>10.5f} {N/ref:>16.5f}")
    print("\nThe stated example (r = 1/2, b = 1/10, n = 10 modes):")
    a10 = [0.5 ** i for i in range(10)]
    print(f"  0.2 <= N = {noise_floor(a10, 0.1):.6f} <= 0.6")


def main() -> None:
    demo_noise_floor_principle()
    demo_trace_lemma()
    demo_capacity_frontier()
    demo_head_tail()
    demo_ridge_gap()
    demo_early_stopping()
    demo_minimax()
    demo_scaling_law()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
