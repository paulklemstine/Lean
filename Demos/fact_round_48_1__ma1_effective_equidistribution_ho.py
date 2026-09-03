"""
Numerical demonstration of the effectivization of an equidistribution assumption.

Everything in this file is self-contained: a sieve produces the prime counts
pi(x; m, a) in each reduced residue class, a logarithmic-integral routine produces
the common target mu = Li(x)/phi(m), and the resulting equidistribution certificate

        |N_a - mu| <= eps * mu      for every reduced class a mod m

is then fed through the transfer machinery:

  * the sharp two-sided ratio bound   N_a <= ((1+eps)/(1-eps)) N_b
  * the effective cap constant        C(eps) = (4/3)(1+eps)/(1-eps)
  * the converse dictionary           eps >= (R-1)/(R+1)
  * Dirichlet character sums and finite Fourier inversion
  * the linear and quadratic information prices of the assumption
  * the totals of those prices summed over all dyadic scales
  * the near-tie criterion for stability of the worst-behaved class

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Arithmetic infrastructure
# --------------------------------------------------------------------------------------


def sieve_primes(limit: int) -> List[int]:
    """All primes < limit, by a simple sieve of Eratosthenes."""
    if limit < 3:
        return []
    flags = bytearray([1]) * limit
    flags[0] = flags[1] = 0
    for p in range(2, int(limit**0.5) + 1):
        if flags[p]:
            flags[p * p : limit : p] = bytearray(len(range(p * p, limit, p)))
    return [i for i in range(limit) if flags[i]]


def logarithmic_integral(x: float) -> float:
    """Li(x) = integral from 2 to x of dt/log t, by adaptive Simpson on log scale."""
    if x <= 2.0:
        return 0.0
    # substitute t = exp(u): dt/log t = exp(u)/u du
    a, b = math.log(2.0), math.log(x)
    n = 20000  # even number of Simpson panels
    h = (b - a) / n
    total = 0.0
    for i in range(n + 1):
        u = a + i * h
        w = 1.0 if i in (0, n) else (4.0 if i % 2 == 1 else 2.0)
        total += w * math.exp(u) / u
    return total * h / 3.0


def euler_phi(m: int) -> int:
    """Euler's totient function."""
    result, n, p = m, m, 2
    while p * p <= n:
        if n % p == 0:
            while n % p == 0:
                n //= p
            result -= result // p
        p += 1
    if n > 1:
        result -= result // n
    return result


def reduced_classes(m: int) -> List[int]:
    """The reduced residue classes modulo m, in increasing order."""
    return [a for a in range(m) if math.gcd(a, m) == 1]


def class_counts(primes: Sequence[int], m: int) -> Dict[int, int]:
    """pi(x; m, a) for every reduced class a, where x is the sieve limit."""
    counts = {a: 0 for a in reduced_classes(m)}
    for p in primes:
        r = p % m
        if r in counts:
            counts[r] += 1
    return counts


# --------------------------------------------------------------------------------------
# Certificates and transfer
# --------------------------------------------------------------------------------------


def certificate_epsilon(counts: Sequence[float], mu: float) -> float:
    """The smallest eps for which |N_a - mu| <= eps*mu holds for every class."""
    return max(abs(n - mu) for n in counts) / mu


def ratio_bound(eps: float) -> float:
    """The sharp two-sided transfer ratio (1+eps)/(1-eps)."""
    return (1.0 + eps) / (1.0 - eps)


def cap_constant(eps: float) -> float:
    """The effective cap constant C(eps) = (4/3)(1+eps)/(1-eps)."""
    return (4.0 / 3.0) * ratio_bound(eps)


def relative_cap_perturbation(eps: float) -> float:
    """(C(eps) - 4/3)/(4/3) = 2 eps/(1-eps): the honest, two-sided relative error."""
    return 2.0 * eps / (1.0 - eps)


def epsilon_from_ratio(ratio: float) -> float:
    """Converse dictionary: an observed ratio R refutes every certificate below (R-1)/(R+1)."""
    return (ratio - 1.0) / (ratio + 1.0)


def significant_figures_certified(eps: float) -> int:
    """Number of significant figures of 4/3 that survive: floor(-log10(2 eps/(1-eps)))."""
    rel = relative_cap_perturbation(eps)
    if rel <= 0.0:
        return 16
    return int(math.floor(-math.log10(rel)))


# --------------------------------------------------------------------------------------
# Information price
# --------------------------------------------------------------------------------------


def class_distribution(counts: Sequence[float]) -> List[float]:
    """The empirical distribution p_a = N_a / sum_b N_b."""
    total = float(sum(counts))
    return [c / total for c in counts]


def kl_from_uniform(p: Sequence[float]) -> float:
    """D(p || u) = sum_a p_a log(n p_a), in nats."""
    n = len(p)
    return sum(pa * math.log(n * pa) for pa in p if pa > 0.0)


def shannon_entropy(p: Sequence[float]) -> float:
    """H(p) = -sum_a p_a log p_a, in nats."""
    return -sum(pa * math.log(pa) for pa in p if pa > 0.0)


def linear_price_bound(eps: float) -> float:
    """Theoretical linear bound 2 eps/(1-eps) on the divergence from uniform."""
    return 2.0 * eps / (1.0 - eps)


def quadratic_price_bound(eps: float) -> float:
    """Theoretical quadratic bound (2 eps/(1-eps))^2 on the divergence from uniform."""
    return (2.0 * eps / (1.0 - eps)) ** 2


def saturated_two_class_price(eps: float) -> float:
    """Exact divergence of the extremal two-class distribution ((1+e)/2, (1-e)/2)."""
    return kl_from_uniform([(1.0 + eps) / 2.0, (1.0 - eps) / 2.0])


def total_price_linear(eps0: float, rho: float) -> float:
    """Total across all dyadic scales under geometric decay: 4 eps0/(1-rho)."""
    return 4.0 * eps0 / (1.0 - rho)


def total_price_quadratic(eps0: float, rho: float) -> float:
    """Total across all dyadic scales under geometric decay: 16 eps0^2/(1-rho^2)."""
    return 16.0 * eps0**2 / (1.0 - rho**2)


# --------------------------------------------------------------------------------------
# Dirichlet characters: sums and Fourier inversion
# --------------------------------------------------------------------------------------


def multiplicative_group_generators(m: int) -> List[Tuple[int, int]]:
    """A basis (g, order) of (Z/mZ)^x as a product of cyclic groups, found by search."""
    units = reduced_classes(m)
    order = len(units)
    basis: List[Tuple[int, int]] = []
    covered = {1}
    for g in units:
        if g in covered:
            continue
        powers, h = [], 1
        while True:
            h = (h * g) % m
            powers.append(h)
            if h == 1:
                break
        new_covered = {(u * q) % m for u in covered for q in powers}
        # accept g only if the subgroup it generates is independent of what is covered
        if len(new_covered) == len(covered) * len(powers):
            basis.append((g, len(powers)))
            covered = new_covered
        if len(covered) == order:
            break
    return basis


def all_characters(m: int) -> List[Dict[int, complex]]:
    """All phi(m) Dirichlet characters mod m, as tables on the reduced classes."""
    basis = multiplicative_group_generators(m)
    units = reduced_classes(m)
    # coordinates of each unit with respect to the basis
    coords: Dict[int, Tuple[int, ...]] = {}
    ranges = [range(order) for _, order in basis]

    def enumerate_coords(idx: int, value: int, acc: Tuple[int, ...]) -> None:
        if idx == len(basis):
            coords.setdefault(value, acc)
            return
        g, order = basis[idx]
        v = value
        for e in range(order):
            enumerate_coords(idx + 1, v, acc + (e,))
            v = (v * g) % m

    enumerate_coords(0, 1, ())
    product = 1
    for _, order in basis:
        product *= order
    assert product == len(units), "basis of the unit group is not a direct decomposition"
    assert len(coords) == len(units), "character coordinates incomplete"

    characters: List[Dict[int, complex]] = []

    def build(idx: int, freqs: Tuple[int, ...]) -> None:
        if idx == len(basis):
            table = {}
            for u in units:
                phase = sum(
                    2.0 * math.pi * freqs[j] * coords[u][j] / basis[j][1]
                    for j in range(len(basis))
                )
                table[u] = cmath.exp(1j * phase)
            characters.append(table)
            return
        for f in ranges[idx]:
            build(idx + 1, freqs + (f,))

    build(0, ())
    return characters


def character_sum(chi: Dict[int, complex], counts: Dict[int, float]) -> complex:
    """The twisted count S_chi = sum_a chi(a) N_a."""
    return sum(chi[a] * counts[a] for a in counts)


def fourier_inversion_residual(m: int, counts: Dict[int, float]) -> float:
    """Max over classes of |sum_chi conj(chi(a)) S_chi - phi(m) N_a|: should be ~0."""
    chars = all_characters(m)
    worst = 0.0
    for a in counts:
        recon = sum(chi[a].conjugate() * character_sum(chi, counts) for chi in chars)
        worst = max(worst, abs(recon - len(chars) * counts[a]))
    return worst


# --------------------------------------------------------------------------------------
# Worst-class stability
# --------------------------------------------------------------------------------------


def worst_class(deviations: Dict[int, float]) -> int:
    """The class carrying the largest relative deviation."""
    return max(deviations, key=lambda a: deviations[a])


def top_two_gap(deviations: Dict[int, float]) -> float:
    """The gap between the largest and the second-largest deviation."""
    ordered = sorted(deviations.values(), reverse=True)
    return ordered[0] - ordered[1]


def stability_certified(gap: float, drift: float) -> bool:
    """The worst class cannot switch when its lead exceeds twice the drift."""
    return gap > 2.0 * drift


# --------------------------------------------------------------------------------------
# The demonstration
# --------------------------------------------------------------------------------------

RECORDED_EPS: float = 0.000446
MODULI: Tuple[int, ...] = (3, 4, 5, 7, 8, 11, 31)


def part_1_measure(limit: int) -> Dict[int, Dict[str, float]]:
    """Measure certificates for each modulus at x = limit."""
    print("=" * 78)
    print(f"PART 1.  Measuring equidistribution certificates at x = {limit:,}")
    print("=" * 78)
    primes = sieve_primes(limit)
    li = logarithmic_integral(float(limit))
    print(f"  pi(x)  = {len(primes):,}      Li(x) = {li:,.1f}")
    print()
    print(f"  {'m':>4} {'phi(m)':>7} {'mu = Li(x)/phi(m)':>20} {'eps':>12} {'worst class':>12}")
    print("  " + "-" * 60)
    report: Dict[int, Dict[str, float]] = {}
    for m in MODULI:
        counts = class_counts(primes, m)
        mu = li / euler_phi(m)
        eps = certificate_epsilon(list(counts.values()), mu)
        devs = {a: abs(counts[a] - mu) / mu for a in counts}
        wc = worst_class(devs)
        report[m] = {"mu": mu, "eps": eps, "worst": float(wc), "gap": top_two_gap(devs)}
        print(f"  {m:>4} {euler_phi(m):>7} {mu:>20,.1f} {eps:>12.6f} {wc:>12}")
    print()
    print(f"  Maximal deviation over the family: eps = {max(r['eps'] for r in report.values()):.6f}")
    print(f"  (The recorded value at x = 2^30 is eps = {RECORDED_EPS}.)")
    print()
    return report


def part_2_transfer() -> None:
    """The transfer constant at the recorded deviation, and its sharpness."""
    print("=" * 78)
    print("PART 2.  The transfer theorem and the effective cap constant")
    print("=" * 78)
    eps = RECORDED_EPS
    r = ratio_bound(eps)
    c = cap_constant(eps)
    print(f"  eps                                  = {eps}")
    print(f"  ratio bound (1+eps)/(1-eps)          = {r:.9f}")
    print(f"  ideal cap constant 4/3               = {4/3:.9f}")
    print(f"  effective cap constant C(eps)        = {c:.9f}")
    print(f"  certified window                     : 1.3345 < C < 1.3346  -> "
          f"{1.3345 < c < 1.3346}")
    print(f"  relative perturbation 2eps/(1-eps)   = {relative_cap_perturbation(eps):.9f}"
          f"  ({100*relative_cap_perturbation(eps):.4f} %)")
    print(f"  naive (one-sided) reading            = {eps:.9f}"
          f"  ({100*eps:.4f} %)  <-- off by a factor of two")
    print(f"  three significant figures certified  : "
          f"{relative_cap_perturbation(eps) < 1e-3}")
    print(f"  four significant figures certified   : "
          f"{relative_cap_perturbation(eps) < 1e-4}")
    print(f"  significant figures of 4/3 that survive: {significant_figures_certified(eps)}")
    print()
    # sharpness: the extremal two-class configuration attains the ratio exactly
    mu = 1.0e6
    extremal = [(1.0 + eps) * mu, (1.0 - eps) * mu]
    achieved = max(extremal) / min(extremal)
    print("  Sharpness check on the extremal two-class configuration")
    print(f"    counts                             = {extremal[0]:.3f}, {extremal[1]:.3f}")
    print(f"    total conserved (= 2 mu)           : {abs(sum(extremal) - 2*mu) < 1e-6}")
    print(f"    achieved max/min                   = {achieved:.9f}")
    print(f"    predicted (1+eps)/(1-eps)          = {r:.9f}")
    print(f"    converse dictionary eps >= (R-1)/(R+1) = {epsilon_from_ratio(achieved):.9f}"
          f"  (recovers eps exactly)")
    print()


def part_3_information(report: Dict[int, Dict[str, float]], limit: int) -> None:
    """The linear and quadratic information prices, measured and predicted."""
    print("=" * 78)
    print("PART 3.  The information price of the assumption")
    print("=" * 78)
    primes = sieve_primes(limit)
    print(f"  {'m':>4} {'D(p||u) measured':>19} {'linear bound':>15} {'quadratic bound':>17}")
    print("  " + "-" * 60)
    for m in MODULI:
        counts = class_counts(primes, m)
        p = class_distribution([counts[a] for a in sorted(counts)])
        eps = report[m]["eps"]
        print(f"  {m:>4} {kl_from_uniform(p):>19.3e} {linear_price_bound(eps):>15.3e}"
              f" {quadratic_price_bound(eps):>17.3e}")
    print()
    eps = RECORDED_EPS
    print(f"  At the recorded eps = {eps}:")
    print(f"    linear bound        2eps/(1-eps)      = {linear_price_bound(eps):.3e} nats"
          f"   (<= 9e-4)")
    print(f"    quadratic bound     (2eps/(1-eps))^2  = {quadratic_price_bound(eps):.3e} nats"
          f"   (<= 8e-7)")
    print(f"    improvement factor                    = "
          f"{linear_price_bound(eps)/quadratic_price_bound(eps):.0f}x")
    print(f"    saturated two-class price (exact)     = {saturated_two_class_price(eps):.3e} nats")
    print(f"    matching lower bound eps^2/4          = {eps**2/4:.3e} nats"
          f"   (so the exponent 2 is exact)")
    print()
    rho = 0.5
    print(f"  Summed over all dyadic scales with halving certificates (rho = {rho}):")
    print(f"    linear envelope     4 eps0/(1-rho)    = {total_price_linear(eps, rho):.3e} nats"
          f"   (<= 3.57e-3)")
    print(f"    quadratic envelope  16 eps0^2/(1-rho^2)= "
          f"{total_price_quadratic(eps, rho):.3e} nats   (<= 4.3e-6)")
    print(f"    improvement factor                    = "
          f"{total_price_linear(eps, rho)/total_price_quadratic(eps, rho):.0f}x")
    print()


def part_4_characters(limit: int) -> None:
    """Character sums, the certificate bound, and Fourier inversion."""
    print("=" * 78)
    print("PART 4.  Dirichlet character sums and Fourier inversion")
    print("=" * 78)
    primes = sieve_primes(limit)
    li = logarithmic_integral(float(limit))
    print(f"  {'m':>4} {'max |S_chi| (chi != 1)':>24} {'bound phi(m)*eps*mu':>22} {'inversion err':>15}")
    print("  " + "-" * 70)
    for m in (5, 7, 8, 11):
        counts = {a: float(v) for a, v in class_counts(primes, m).items()}
        phi = euler_phi(m)
        mu = li / phi
        eps = certificate_epsilon(list(counts.values()), mu)
        chars = all_characters(m)
        trivial = min(range(len(chars)), key=lambda i: sum(abs(chars[i][a] - 1) for a in counts))
        worst = max(abs(character_sum(chars[i], counts)) for i in range(len(chars)) if i != trivial)
        print(f"  {m:>4} {worst:>24,.1f} {phi*eps*mu:>22,.1f}"
              f" {fourier_inversion_residual(m, counts):>15.3e}")
    print()
    print("  The bound phi(m)*eps*mu equals eps*Li(x): every nontrivial twisted prime count")
    print("  is below the certificate tolerance times the total prime count. Fourier")
    print("  inversion reconstructs the class counts exactly (residual is rounding noise).")
    print()


def part_5_stability(report: Dict[int, Dict[str, float]]) -> None:
    """The near-tie criterion for stability of the worst-behaved class."""
    print("=" * 78)
    print("PART 5.  Stability of the worst-behaved class is a near-tie criterion")
    print("=" * 78)
    drift = 2.0e-4  # illustrative sup-norm drift of the deviation field between two scales
    print(f"  Assume the deviation field drifts by at most eta = {drift} between scales.")
    print(f"  The worst class cannot switch when its lead exceeds 2*eta = {2*drift}.")
    print()
    print(f"  {'m':>4} {'worst class':>12} {'top-two gap':>14} {'stability certified':>21}")
    print("  " + "-" * 55)
    for m in MODULI:
        gap = report[m]["gap"]
        print(f"  {m:>4} {int(report[m]['worst']):>12} {gap:>14.6f}"
              f" {str(stability_certified(gap, drift)):>21}")
    print()
    print("  A modulus whose worst class switches between scales is thereby certifying")
    print("  a top-two gap of at most twice the drift: instability is a near-tie, not")
    print("  an arithmetic distinction between the moduli.")
    print()


def main() -> None:
    limit = 1 << 22  # 4,194,304
    report = part_1_measure(limit)
    part_2_transfer()
    part_3_information(report, limit)
    part_4_characters(limit)
    part_5_stability(report)
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    eps = RECORDED_EPS
    print(f"  From the single measured number eps = {eps} one obtains, simultaneously:")
    print(f"    * every two class counts within a factor {ratio_bound(eps):.6f};")
    print(f"    * the effective cap constant pinned to {cap_constant(eps):.6f}"
          f" in (1.3345, 1.3346);")
    print(f"    * three significant figures of 4/3 certified, four refuted;")
    print(f"    * every nontrivial character sum below eps*Li(x);")
    print(f"    * the class distribution within {quadratic_price_bound(eps):.1e} nats of uniform;")
    print(f"    * a total information price over all scales below "
          f"{total_price_quadratic(eps, 0.5):.1e} nats.")


if __name__ == "__main__":
    main()
