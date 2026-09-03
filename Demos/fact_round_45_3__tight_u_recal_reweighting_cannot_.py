"""
Numerical demonstration: the recalibration ceiling of small-prime footprints.

Everything here is exact rational arithmetic (``fractions.Fraction``) over the
finite residue-data space

    Omega_A = prod_{p in A} Z/pZ,   uniform probability,

with the *quadratic dials*

    dial_p(N) = #{ x in Z/pZ : x^2 = N }  in {0, 1, 2},

the centred dial features x_p = dial_p - 1, and the *structure correction*

    C(N) = prod_{p in A} (p - dial_p(N)) / (p - 1),

the exact multiplicative smoothness bias of the quadratic form x^2 - N.

The script verifies, by exhaustive enumeration:

  1. the dial design is exactly orthogonal, with variances (p-1)/p;
  2. cov(C, x_p) = -1/p exactly, optimal weights beta*_p = -1/(p-1);
  3. the recalibration ceiling equals sum_p 1/(p(p-1)) and is attained;
  4. Var C = prod_p (1 + 1/(p(p-1))) - 1, strictly above the ceiling;
  5. a target carried by mid primes has zero footprint covariance, so every
     nonzero refit strictly loses, and beta and -beta are indistinguishable;
  6. no *nonlinear* function of the footprint beats the constant predictor;
  7. the model-order recovery curve is the partial elementary-symmetric series.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Residue = Tuple[int, ...]  # a point of Omega_A, one residue per prime


# --------------------------------------------------------------------------
# 1. Dials and the structure correction
# --------------------------------------------------------------------------
def dial(p: int, n: int) -> int:
    """Number of square roots of ``n`` modulo the odd prime ``p`` (0, 1 or 2)."""
    return sum(1 for x in range(p) if (x * x - n) % p == 0)


def dial_feature(p: int, n: int) -> Fraction:
    """Centred dial feature x_p(N) = dial_p(N) - 1, taking values -1, 0, 1."""
    return Fraction(dial(p, n) - 1)


def local_factor(p: int, n: int) -> Fraction:
    """Local factor (p - dial_p(N)) / (p - 1) of the structure correction."""
    return Fraction(p - dial(p, n), p - 1)


def space(primes: Sequence[int]) -> List[Residue]:
    """All residue data: the product of Z/pZ over the given primes."""
    return [tuple(t) for t in product(*(range(p) for p in primes))]


def structure_correction(primes: Sequence[int]) -> Callable[[Residue], Fraction]:
    """C(N) = prod_p (p - dial_p(N))/(p - 1)."""

    def C(N: Residue) -> Fraction:
        out = Fraction(1)
        for p, n in zip(primes, N):
            out *= local_factor(p, n)
        return out

    return C


# --------------------------------------------------------------------------
# 2. Exact finite-sample statistics
# --------------------------------------------------------------------------
def avg(values: Iterable[Fraction], size: int) -> Fraction:
    return sum(values, Fraction(0)) / size


def mean(f: Callable[[Residue], Fraction], omega: Sequence[Residue]) -> Fraction:
    return avg((f(N) for N in omega), len(omega))


def variance(f: Callable[[Residue], Fraction], omega: Sequence[Residue]) -> Fraction:
    m = mean(f, omega)
    return avg(((f(N) - m) ** 2 for N in omega), len(omega))


def covariance_with_feature(
    f: Callable[[Residue], Fraction], omega: Sequence[Residue], primes: Sequence[int], j: int
) -> Fraction:
    """cov(f, x_{p_j}) = E[f * x_{p_j}]  (the features are already centred)."""
    return avg((f(N) * dial_feature(primes[j], N[j]) for N in omega), len(omega))


def mse(
    f: Callable[[Residue], Fraction],
    omega: Sequence[Residue],
    primes: Sequence[int],
    c: Fraction,
    beta: Sequence[Fraction],
) -> Fraction:
    """Mean squared error of the affine footprint predictor c + sum_p beta_p x_p."""
    total = Fraction(0)
    for N in omega:
        pred = c + sum(
            (b * dial_feature(p, n) for b, p, n in zip(beta, primes, N)), Fraction(0)
        )
        total += (f(N) - pred) ** 2
    return total / len(omega)


def footprint_energy(
    f: Callable[[Residue], Fraction], omega: Sequence[Residue], primes: Sequence[int]
) -> Fraction:
    """Recalibration ceiling: sum_p cov(f, x_p)^2 / v_p, with v_p = (p-1)/p."""
    out = Fraction(0)
    for j, p in enumerate(primes):
        v = Fraction(p - 1, p)
        out += covariance_with_feature(f, omega, primes, j) ** 2 / v
    return out


# --------------------------------------------------------------------------
# 3. Checks
# --------------------------------------------------------------------------
def check_orthogonal_design(primes: Sequence[int]) -> None:
    omega = space(primes)
    print(f"[1] Orthogonality of the dial design on primes {list(primes)}")
    for j, p in enumerate(primes):
        m = avg((dial_feature(p, N[j]) for N in omega), len(omega))
        v = avg((dial_feature(p, N[j]) ** 2 for N in omega), len(omega))
        assert m == 0 and v == Fraction(p - 1, p)
        print(f"    p={p:>3}:  E[x_p] = {m}   E[x_p^2] = {v} = (p-1)/p")
    for (j, p), (k, q) in combinations(list(enumerate(primes)), 2):
        c = avg(
            (dial_feature(p, N[j]) * dial_feature(q, N[k]) for N in omega), len(omega)
        )
        assert c == 0
    print("    all pairwise correlations vanish exactly\n")


def check_ceiling(primes: Sequence[int]) -> None:
    omega = space(primes)
    C = structure_correction(primes)
    print(f"[2] Structure correction on primes {list(primes)}")
    print(f"    E[C]      = {mean(C, omega)}   (theory 1)")
    for j, p in enumerate(primes):
        cov = covariance_with_feature(C, omega, primes, j)
        beta_star = cov / Fraction(p - 1, p)
        assert cov == Fraction(-1, p) and beta_star == Fraction(-1, p - 1)
        print(f"    p={p:>3}:  cov(C,x_p) = {cov} = -1/p    beta*_p = {beta_star} = -1/(p-1)")

    energy = footprint_energy(C, omega, primes)
    ceiling = sum((Fraction(1, p * (p - 1)) for p in primes), Fraction(0))
    var = variance(C, omega)
    prod = Fraction(1)
    for p in primes:
        prod *= 1 + Fraction(1, p * (p - 1))
    assert energy == ceiling and var == prod - 1
    print(f"    ceiling   = {energy} = sum 1/(p(p-1))          ~ {float(energy):.6f}")
    print(f"    variance  = {var} = prod (1+1/(p(p-1))) - 1  ~ {float(var):.6f}")
    print(f"    reachable share = {float(energy / var) * 100:.3f} %   "
          f"deficit = {float(var - energy):.6f}\n")

    # the ceiling really is attained by the optimal refit, and no refit beats it
    beta_star = [Fraction(-1, p - 1) for p in primes]
    zero_fit = mse(C, omega, primes, mean(C, omega), [Fraction(0)] * len(primes))
    best = mse(C, omega, primes, mean(C, omega), beta_star)
    assert zero_fit - best == energy
    print(f"    zero-fit loss  = {float(zero_fit):.6f}")
    print(f"    best refit     = {float(best):.6f}   gain = {float(zero_fit - best):.6f}")

    # a positive (2/p-shaped) profile is strictly worse than not refitting
    beta_theory = [Fraction(2, p) for p in primes]
    theory_loss = mse(C, omega, primes, mean(C, omega), beta_theory)
    assert theory_loss > zero_fit
    print(f"    2/p-shaped refit = {float(theory_loss):.6f}  -> gain "
          f"{float(zero_fit - theory_loss):+.6f} (strictly negative)\n")


def check_no_recovery_for_mid_prime_target(
    footprint: Sequence[int], mid: Sequence[int]
) -> None:
    primes = list(footprint) + list(mid)
    omega = space(primes)
    k = len(footprint)

    def G(N: Residue) -> Fraction:
        """A target carried entirely by the mid primes."""
        out = Fraction(1)
        for p, n in zip(mid, N[k:]):
            out *= local_factor(p, n)
        return out

    print(f"[3] Mid-prime target: footprint {list(footprint)}, mid primes {list(mid)}")
    for j, p in enumerate(footprint):
        cov = covariance_with_feature(G, omega, primes, j)
        assert cov == 0
    print("    cov(G, x_p) = 0 for every footprint prime -> ceiling 0")

    zero_fit = mse(G, omega, primes, mean(G, omega), [Fraction(0)] * len(primes))
    beta = [Fraction(0)] * len(primes)
    beta[0] = Fraction(1, 3)
    beta[min(1, len(primes) - 1)] = Fraction(-1, 5)
    refit = mse(G, omega, primes, mean(G, omega), beta)
    flipped = mse(G, omega, primes, mean(G, omega), [-b for b in beta])
    loss = sum(
        (Fraction(p - 1, p) * b ** 2 for p, b in zip(primes, beta)), Fraction(0)
    )
    assert refit == zero_fit + loss and refit == flipped
    print(f"    zero-fit loss = {float(zero_fit):.6f}")
    print(f"    refit loss    = {float(refit):.6f}  = zero-fit + sum v_p beta_p^2")
    print(f"    gain          = {float(zero_fit - refit):+.6f}  (never positive)")
    print("    beta and -beta give identical loss: the direction is unidentifiable\n")

    # nonlinear invisibility: the best possible function of the footprint half
    best_f: Dict[Tuple[int, ...], Fraction] = {}
    groups: Dict[Tuple[int, ...], List[Fraction]] = {}
    for N in omega:
        groups.setdefault(N[:k], []).append(G(N))
    for key, vals in groups.items():
        best_f[key] = sum(vals, Fraction(0)) / len(vals)
    assert len(set(best_f.values())) == 1
    print("[4] Nonlinear invisibility")
    print("    the conditional mean of the target given the whole footprint is")
    print(f"    constant, equal to {next(iter(best_f.values()))} = E[G]:")
    print("    no function of the footprint, linear or not, beats the constant.\n")


def recovery_curve(primes: Sequence[int]) -> None:
    """Partial elementary-symmetric recovery curve of the structure correction."""
    c = [Fraction(1, p * (p - 1)) for p in primes]
    total = Fraction(1)
    for ci in c:
        total *= 1 + ci
    total -= 1
    print(f"[5] Model-order recovery curve for primes {list(primes)}")
    running = Fraction(0)
    for d in range(1, len(primes) + 1):
        e_d = sum((_prod(sub) for sub in combinations(c, d)), Fraction(0))
        running += e_d
        print(
            f"    order <= {d}:  captured {float(running):.6f} of {float(total):.6f}"
            f"   ({float(running / total) * 100:6.3f} %)"
        )
    assert running == total
    print()


def _prod(xs: Iterable[Fraction]) -> Fraction:
    out = Fraction(1)
    for x in xs:
        out *= x
    return out


def main() -> None:
    print(__doc__.split("Run:")[0].strip())
    print("=" * 74, "\n")
    check_orthogonal_design([3, 5, 7])
    check_ceiling([3, 5, 7])
    check_ceiling([3, 5, 7, 11])
    check_no_recovery_for_mid_prime_target([3, 5], [7, 11])
    recovery_curve([3, 5, 7, 11])
    print("All exact identities verified.")


if __name__ == "__main__":
    main()
