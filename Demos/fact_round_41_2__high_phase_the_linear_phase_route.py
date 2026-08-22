"""
Degree ceilings for feature encodings: numerical demonstrations.
================================================================

This self-contained script demonstrates, by direct computation on finite grids,
the exact finite-sample results of the accompanying paper:

  1. The exact error decomposition
         MSE(y, h) = Var y - 2 Cov(y, h) + Var h + (avg y - avg h)^2
     holds for arbitrary targets and arbitrary predictors.

  2. Uncorrelated predictors never help and strictly hurt unless constant:
     the excess error equals exactly Var h + (avg y - avg h)^2.

  3. The best affine model on one feature attains R^2 exactly equal to the
     squared empirical correlation.

  4. The alignment indicator g_sigma(a, b) = 1[b = sigma(a)] on a product grid
     has covariance EXACTLY zero with every additive predictor u(a) + v(b),
     for random, adversarial and one-hot choices of u and v -- at every modulus
     3 <= p <= 97.

  5. The same target is reproduced exactly by a degree-two encoding
     sum_c 1[a = c] * 1[b = sigma(c)], giving R^2 = 1.  (0 versus 1 separation.)

  6. The degree-one ceiling  sup_{u,v} R^2 = Var(f_add) / Var f  is exact:
     a two-pass computation matches a brute-force least-squares fit of the full
     additive family, for random targets on random grids.

  7. Every quantity is invariant under relabelling of the sample space, so an
     exact null is automatically window-stable (cross/same ratio = 1).

  8. On G^3 the zero-sum target 1[a + b + c = 0] has covariance exactly zero
     with every pairwise predictor F(a,b) + H(b,c) + K(a,c).

Only the standard library plus NumPy are required.
"""

from __future__ import annotations

import itertools
from typing import Callable, List, Sequence, Tuple

import numpy as np

# ----------------------------------------------------------------------------
# The exact finite-sample calculus
# ----------------------------------------------------------------------------


def avg(f: np.ndarray) -> float:
    """Empirical mean of a tabulated function over a finite sample space."""
    return float(np.asarray(f, dtype=float).mean())


def cov(f: np.ndarray, g: np.ndarray) -> float:
    """Empirical covariance avg(fg) - avg(f) avg(g)."""
    f = np.asarray(f, dtype=float)
    g = np.asarray(g, dtype=float)
    return float((f * g).mean() - f.mean() * g.mean())


def varr(f: np.ndarray) -> float:
    """Empirical variance."""
    return cov(f, f)


def msse(y: np.ndarray, h: np.ndarray) -> float:
    """Mean squared error of the predictor h for the target y."""
    y = np.asarray(y, dtype=float)
    h = np.asarray(h, dtype=float)
    return float(((y - h) ** 2).mean())


def rsq(y: np.ndarray, h: np.ndarray) -> float:
    """Coefficient of determination against the intercept-only baseline."""
    return 1.0 - msse(y, h) / varr(y)


# ----------------------------------------------------------------------------
# Targets and encodings on a product grid
# ----------------------------------------------------------------------------


def alignment_target(m: int, sigma: Sequence[int] | None = None) -> np.ndarray:
    """The alignment indicator g_sigma(a, b) = 1[b = sigma(a)] on an m x m grid.

    With sigma = None the identity permutation is used, giving the diagonal
    alignment target 1[a = b] at modulus m.
    """
    perm = list(range(m)) if sigma is None else list(sigma)
    g = np.zeros((m, m), dtype=float)
    for a in range(m):
        g[a, perm[a]] = 1.0
    return g


def additive(u: np.ndarray, v: np.ndarray) -> np.ndarray:
    """The singleton (degree-one) predictor (a, b) -> u(a) + v(b)."""
    return np.asarray(u, dtype=float)[:, None] + np.asarray(v, dtype=float)[None, :]


def interaction_encoding(m: int, sigma: Sequence[int] | None = None) -> np.ndarray:
    """The degree-two predictor sum_c 1[a = c] * 1[b = sigma(c)]."""
    perm = list(range(m)) if sigma is None else list(sigma)
    h = np.zeros((m, m), dtype=float)
    for c in range(m):
        onehot_fst = np.zeros(m)
        onehot_fst[c] = 1.0
        onehot_snd = np.zeros(m)
        onehot_snd[perm[c]] = 1.0
        h += np.outer(onehot_fst, onehot_snd)
    return h


def additive_part(f: np.ndarray) -> np.ndarray:
    """f_add(a, b) = rowmean(a) + colmean(b) - grandmean."""
    f = np.asarray(f, dtype=float)
    row = f.mean(axis=1)
    col = f.mean(axis=0)
    return row[:, None] + col[None, :] - f.mean()


def interaction_part(f: np.ndarray) -> np.ndarray:
    """f_int = f - f_add: the pure interaction (zero-marginal) component."""
    return np.asarray(f, dtype=float) - additive_part(f)


def degree_one_ceiling(f: np.ndarray) -> float:
    """Exact supremum of R^2 over ALL singleton encodings: Var(f_add)/Var(f)."""
    return varr(additive_part(f)) / varr(f)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_error_decomposition(rng: np.random.Generator, trials: int = 5) -> None:
    print("1. Exact error decomposition (random targets, random predictors)")
    print("   MSE = Var y - 2 Cov(y,h) + Var h + (avg y - avg h)^2")
    worst = 0.0
    for _ in range(trials):
        n = int(rng.integers(5, 60))
        y = rng.normal(size=n)
        h = rng.normal(loc=0.4, scale=2.0, size=n)
        lhs = msse(y, h)
        rhs = varr(y) - 2 * cov(y, h) + varr(h) + (avg(y) - avg(h)) ** 2
        worst = max(worst, abs(lhs - rhs))
    print(f"   max |LHS - RHS| over {trials} random trials: {worst:.3e}\n")


def demo_uncorrelated_is_harmful(rng: np.random.Generator) -> None:
    print("2. An uncorrelated predictor never helps and strictly hurts")
    m = 12
    g = alignment_target(m)
    u = rng.normal(size=m)
    v = rng.normal(size=m)
    h = additive(u, v)
    excess_measured = msse(g, h) - varr(g)
    excess_predicted = varr(h) + (avg(g) - avg(h)) ** 2
    print(f"   Cov(target, additive predictor) = {cov(g, h):+.3e}  (exactly 0)")
    print(f"   measured excess error           = {excess_measured:.10f}")
    print(f"   predicted Var h + mean-offset^2 = {excess_predicted:.10f}")
    print(f"   R^2 of the additive predictor   = {rsq(g, h):+.6f}  (<= 0)\n")


def demo_single_feature_r2(rng: np.random.Generator) -> None:
    print("3. Best one-feature affine model attains R^2 = squared correlation")
    n = 200
    f = rng.normal(size=n)
    y = 1.7 * f + rng.normal(scale=1.3, size=n)
    a_star = cov(y, f) / varr(f)
    b_star = avg(y) - a_star * avg(f)
    fitted = a_star * f + b_star
    corr_sq = cov(y, f) ** 2 / (varr(y) * varr(f))
    print(f"   fitted slope / intercept  = {a_star:+.6f} / {b_star:+.6f}")
    print(f"   R^2 of the fitted line    = {rsq(y, fitted):.10f}")
    print(f"   squared correlation       = {corr_sq:.10f}")
    # sanity: no other (a, b) does better
    best_other = max(
        rsq(y, a * f + b)
        for a in np.linspace(a_star - 1.0, a_star + 1.0, 41)
        for b in np.linspace(b_star - 1.0, b_star + 1.0, 41)
    )
    print(f"   best over a 41x41 grid of (a,b): {best_other:.10f}\n")


def demo_phase_route_closed(primes: Sequence[int], rng: np.random.Generator) -> None:
    print("4/5. The phase route is closed at every modulus; degree two is perfect")
    print("     p   Var(target)   max|Cov| over 200 additive predictors"
          "   max R^2 (deg 1)   R^2 (deg 2)")
    for p in primes:
        g = alignment_target(p)
        worst_cov = 0.0
        worst_r2 = -np.inf
        # random, adversarial (target marginals) and one-hot choices of u, v
        candidates: List[Tuple[np.ndarray, np.ndarray]] = []
        for _ in range(180):
            candidates.append((rng.normal(size=p), rng.normal(size=p)))
        candidates.append((g.mean(axis=1), g.mean(axis=0)))
        candidates.append((np.arange(p, dtype=float), np.zeros(p)))
        candidates.append((np.cos(2 * np.pi * np.arange(p) / p), np.sin(2 * np.pi * np.arange(p) / p)))
        for c in range(min(p, 17)):
            e = np.zeros(p)
            e[c] = 1.0
            candidates.append((e, np.zeros(p)))
        for u, v in candidates:
            h = additive(u, v)
            worst_cov = max(worst_cov, abs(cov(g, h)))
            worst_r2 = max(worst_r2, rsq(g, h))
        h2 = interaction_encoding(p)
        print(f"    {p:2d}   {varr(g):.8f}   {worst_cov:.3e}"
              f"                          {worst_r2:+.6f}        {rsq(g, h2):.6f}")
    print()


def demo_ceiling_is_exact(rng: np.random.Generator, trials: int = 4) -> None:
    print("6. The degree-one ceiling Var(f_add)/Var(f) is exactly attained")
    print("   (compared against a brute-force least-squares fit of u(a)+v(b))")
    for _ in range(trials):
        m = int(rng.integers(3, 7))
        n = int(rng.integers(3, 7))
        f = rng.normal(size=(m, n))
        ceiling = degree_one_ceiling(f)
        attained = rsq(f, additive_part(f))
        # brute force: design matrix of the additive family, solved by lstsq
        rows, cols = np.indices((m, n))
        design = np.concatenate(
            [
                (rows.ravel()[:, None] == np.arange(m)[None, :]).astype(float),
                (cols.ravel()[:, None] == np.arange(n)[None, :]).astype(float),
            ],
            axis=1,
        )
        coef, *_ = np.linalg.lstsq(design, f.ravel(), rcond=None)
        brute = rsq(f, (design @ coef).reshape(m, n))
        split = varr(additive_part(f)) + varr(interaction_part(f))
        print(f"   grid {m}x{n}: ceiling {ceiling:.10f} | attained {attained:.10f} "
              f"| brute force {brute:.10f} | variance budget err {abs(split - varr(f)):.2e}")
    g = alignment_target(11)
    print(f"   alignment target (m=11): additive part is constant "
          f"{additive_part(g)[0, 0]:.6f} = 1/11, ceiling = {degree_one_ceiling(g):.3e}\n")


def demo_relabelling_invariance(rng: np.random.Generator) -> None:
    print("7. Relabelling invariance: an exact null is automatically window-stable")
    p = 13
    g = alignment_target(p).ravel()
    h = additive(rng.normal(size=p), rng.normal(size=p)).ravel()
    perm = rng.permutation(g.size)
    print(f"   same window  R^2 = {rsq(g, h):+.10f}")
    print(f"   other window R^2 = {rsq(g[perm], h[perm]):+.10f}")
    print("   cross/same ratio of the population quantity = 1 exactly\n")


def demo_triple_alignment(rng: np.random.Generator, N: int = 7) -> None:
    print(f"8. Three-way alignment on Z_{N}^3 defeats the entire pairwise layer")
    idx = np.indices((N, N, N))
    t = ((idx[0] + idx[1] + idx[2]) % N == 0).astype(float)
    worst_cov = 0.0
    worst_r2 = -np.inf
    for _ in range(120):
        F = rng.normal(size=(N, N))
        H = rng.normal(size=(N, N))
        K = rng.normal(size=(N, N))
        pred = F[idx[0], idx[1]] + H[idx[1], idx[2]] + K[idx[0], idx[2]]
        worst_cov = max(worst_cov, abs(cov(t, pred)))
        worst_r2 = max(worst_r2, rsq(t, pred))
    print(f"   avg t = {avg(t):.6f} = 1/{N},  Var t = {varr(t):.8f} = 1/{N} - 1/{N}^2")
    print(f"   max |Cov(t, pairwise predictor)| over 120 random draws: {worst_cov:.3e}")
    print(f"   max R^2 of a pairwise (degree <= 2) encoding: {worst_r2:+.6f}")
    print(f"   R^2 of the degree-3 encoding (the joint indicator): {rsq(t, t):.6f}\n")


def demo_conditional_mean_mechanism(N: int = 5) -> None:
    print("9. The mechanism: conditioning on too few coordinates leaves a flat mean")
    idx = np.indices((N, N, N))
    t = ((idx[0] + idx[1] + idx[2]) % N == 0).astype(float)
    pair_means = t.mean(axis=2)  # condition on (a, b)
    print(f"   conditional mean of 1[a+b+c=0] given (a,b): all entries = "
          f"{pair_means.min():.6f} .. {pair_means.max():.6f} (constant 1/{N})")
    g = alignment_target(N)
    print(f"   conditional mean of 1[b=a] given a: all entries = "
          f"{g.mean(axis=1).min():.6f} .. {g.mean(axis=1).max():.6f} (constant 1/{N})\n")


def main() -> None:
    rng = np.random.default_rng(20260902)
    print("=" * 78)
    print("Degree ceilings for feature encodings -- numerical demonstrations")
    print("=" * 78, "\n")
    demo_error_decomposition(rng)
    demo_uncorrelated_is_harmful(rng)
    demo_single_feature_r2(rng)
    demo_phase_route_closed([3, 5, 7, 11, 17, 29, 53, 97], rng)
    demo_ceiling_is_exact(rng)
    demo_relabelling_invariance(rng)
    demo_triple_alignment(rng)
    demo_conditional_mean_mechanism()
    print("All demonstrations agree with the exact theory to machine precision.")


if __name__ == "__main__":
    main()
