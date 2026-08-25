"""
Positional-stratum measure framework: numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type-hinted.

The script demonstrates, numerically:

  1. The r-bar identity        EC = P * rbar_R + (1 - P) * rbar_C   (exact, universal).
  2. The booking factor Theta  = rbar_R / centre(R): Theta = 1 on uniform cells,
     Theta = 1 does NOT imply uniformity on a single cell.
  3. Unbounded failure of the booked (uniform-cells) value law.
  4. The sharp booked envelope, attained at both ends.
  5. Majorization: a descending weight beats the baseline C0 = (M+1)/2, strictly
     unless flat.
  6. Pigeonhole on a k-bit filter and the master inequality.
  7. The certified block law S(mu, P) = 1 / (mu*P + (1-mu)(1-P)); baseline
     conditionality; an adversarial locus undercut.
  8. The feasibility test mu <= 1/S and the anchor-table erratum
     (0.02, 0.9853) -> 29.3152..., not 29.0698... .
  9. Composition: 1/S is a Bernoulli agreement probability; strict
     submultiplicativity.
 10. The canonical reporting prior b(r) = 0.5 * r^{-3/2} and its exactly linear
     capture curve.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple
import math
import random

# ----------------------------------------------------------------------------
# Core framework
# ----------------------------------------------------------------------------


def expected_cost(cost: Sequence[float], weight: Sequence[float]) -> float:
    """EC = sum_i c(i) w(i) over the positional space {1, ..., M}."""
    return sum(c * w for c, w in zip(cost, weight))


def mass(weight: Sequence[float], stratum: Sequence[int]) -> float:
    """Total weight carried by a stratum, given as 0-based indices."""
    return sum(weight[i] for i in stratum)


def rbar(cost: Sequence[float], weight: Sequence[float], stratum: Sequence[int]) -> float:
    """Conditional mean cost inside a stratum: rbar_R = sum_R c w / mass_R."""
    m = mass(weight, stratum)
    if m == 0.0:
        raise ValueError("degenerate stratum: zero mass")
    return sum(cost[i] * weight[i] for i in stratum) / m


def cell_centre(cost: Sequence[float], stratum: Sequence[int]) -> float:
    """Unweighted mean of the cost kernel on a stratum."""
    return sum(cost[i] for i in stratum) / len(stratum)


def theta(cost: Sequence[float], weight: Sequence[float], stratum: Sequence[int]) -> float:
    """Booking factor Theta_R = rbar_R / centre(R)."""
    return rbar(cost, weight, stratum) / cell_centre(cost, stratum)


def scan_kernel(M: int) -> List[float]:
    """Scan cost kernel c(i) = i on slots 1..M (returned 0-based)."""
    return [float(i + 1) for i in range(M)]


def booked_ec(M: int, m: int, P: float) -> float:
    """Uniform-within-cells booked expected scan cost for a head stratum of size m."""
    return P * ((m + 1) / 2.0) + (1.0 - P) * (m + (M - m + 1) / 2.0)


def envelope(M: int, m: int, P: float) -> Tuple[float, float]:
    """Sharp two-sided booked envelope for EC given only the bookings (M, m, P)."""
    lower = P * 1.0 + (1.0 - P) * (m + 1)
    upper = P * m + (1.0 - P) * M
    return lower, upper


def head_witness(m: int) -> List[float]:
    """Lower-envelope witness on M = 2m slots: mass 1-1/m at slot 1, 1/m at slot m+1."""
    M = 2 * m
    w = [0.0] * M
    w[0] = 1.0 - 1.0 / m
    w[m] = 1.0 / m
    return w


def tail_witness(M: int, m: int, P: float) -> List[float]:
    """Upper-envelope witness: mass P at slot m, mass 1-P at slot M."""
    w = [0.0] * M
    w[m - 1] += P
    w[M - 1] += 1.0 - P
    return w


def baseline_c0(M: int) -> float:
    """Descending baseline C0 = (M+1)/2."""
    return (M + 1) / 2.0


# ----------------------------------------------------------------------------
# The certified block law
# ----------------------------------------------------------------------------


def agreement(mu: float, P: float) -> float:
    """D(mu, P) = mu P + (1-mu)(1-P): the Bernoulli agreement probability = 1/S."""
    return mu * P + (1.0 - mu) * (1.0 - P)


def certified_value(mu: float, P: float) -> float:
    """S(mu, P) = 1 / D(mu, P), the value against the full-scan-M baseline."""
    return 1.0 / agreement(mu, P)


def block_ec(M: float, mu: float, P: float) -> float:
    """Simultaneous-commitment expected cost: M * D(mu, P)."""
    return M * agreement(mu, P)


def desc_value(M: float, mu: float, P: float) -> float:
    """Value of the same algorithm against the descending baseline C0 = (M+1)/2."""
    return ((M + 1.0) / 2.0) / block_ec(M, mu, P)


def feasibility_slack(mu: float, P: float) -> float:
    """D(mu,P) - mu = (1-P)(1-2mu): nonnegative on the admissible half-box mu <= 1/2."""
    return agreement(mu, P) - mu


# ----------------------------------------------------------------------------
# Canonical reporting prior
# ----------------------------------------------------------------------------


def canonical_kernel(r: float) -> float:
    """b(r) = 1 / (2 r sqrt r) = 0.5 * r^{-3/2}."""
    return 1.0 / (2.0 * r * math.sqrt(r))


def capture_cdf(R: float) -> float:
    """x(R) = 1 - R^{-1/2}: the primitive of the canonical kernel, x(1) = 0."""
    return 1.0 - 1.0 / math.sqrt(R)


def capture_prob(Rmax: float, R: float) -> float:
    """Capture curve of the canonical prior, normalised on [1, Rmax]."""
    return capture_cdf(R) / capture_cdf(Rmax)


def numeric_integral(f: Callable[[float], float], a: float, b: float, n: int = 200000) -> float:
    """Composite Simpson rule (n even)."""
    if n % 2:
        n += 1
    h = (b - a) / n
    total = f(a) + f(b)
    for i in range(1, n):
        total += (4.0 if i % 2 else 2.0) * f(a + i * h)
    return total * h / 3.0


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_rbar_identity() -> None:
    print("=" * 78)
    print("1. The r-bar identity  EC = P*rbar_R + (1-P)*rbar_C   (exact, universal)")
    print("=" * 78)
    rng = random.Random(20260825)
    worst = 0.0
    for trial in range(8):
        M = rng.randint(4, 40)
        raw = [rng.random() ** rng.choice([0.3, 1.0, 3.0]) for _ in range(M)]
        tot = sum(raw)
        w = [x / tot for x in raw]
        # an arbitrary (even non-monotone) cost kernel
        c = [rng.uniform(0.5, 10.0) * (i + 1) ** rng.choice([0.5, 1.0]) for i in range(M)]
        k = rng.randint(1, M - 1)
        R = list(range(k))
        C = list(range(k, M))
        P = mass(w, R)
        lhs = expected_cost(c, w)
        rhs = P * rbar(c, w, R) + (1.0 - P) * rbar(c, w, C)
        err = abs(lhs - rhs) / abs(lhs)
        worst = max(worst, err)
        print(f"  M={M:3d}  |R|={k:3d}  P={P:.4f}   EC={lhs:10.5f}   "
              f"P*rbar_R+(1-P)*rbar_C={rhs:10.5f}   rel.err={err:.2e}")
    print(f"  -> worst relative error over 8 random cells: {worst:.3e} (identity, exact)")
    print()


def demo_theta() -> None:
    print("=" * 78)
    print("2. The booking factor Theta = rbar_R / centre(R)")
    print("=" * 78)
    M = 8
    c = scan_kernel(M)
    uniform = [1.0 / M] * M
    R = list(range(M))
    print(f"  uniform weight on 8 slots:  Theta = {theta(c, uniform, R):.12f}  (= 1 exactly)")

    # Single-cell converse fails: (1/2, 0, 1/2) on three slots has Theta = 1.
    c3 = scan_kernel(3)
    w3 = [0.5, 0.0, 0.5]
    print(f"  weight (1/2, 0, 1/2) on 3 slots: rbar = {rbar(c3, w3, [0, 1, 2]):.6f}, "
          f"centre = {cell_centre(c3, [0, 1, 2]):.6f}, Theta = {theta(c3, w3, [0,1,2]):.12f}")
    print("  -> Theta = 1 on ONE cell does not certify uniformity (w1 = 1/2 != 0 = w2).")

    # Theta == 1 on all pairs does force uniformity: check the pair criterion.
    print("  pair test on the non-uniform weight above, R = {1,2}: "
          f"Theta = {theta(c3, [0.5, 0.0, 0.5], [0, 1]):.6f} != 1  "
          "(so the all-cells criterion correctly rejects it)")
    print()


def demo_value_universality_fails() -> None:
    print("=" * 78)
    print("3. Value-universality fails, unboundedly (head witness on M = 2m)")
    print("=" * 78)
    print("     m      P = 1-1/m     true EC   booked EC   booked/true")
    for m in (4, 8, 32, 128, 1024, 8192):
        M = 2 * m
        w = head_witness(m)
        c = scan_kernel(M)
        P = 1.0 - 1.0 / m
        true_ec = expected_cost(c, w)
        bk = booked_ec(M, m, P)
        print(f"  {m:6d}   {P:.8f}   {true_ec:9.5f}   {bk:9.2f}   {bk/true_ec:11.2f}")
    print("  -> true EC is exactly 2 for every m; the booked prediction is (m+3)/2.")
    print("     The ratio is unbounded, so the booked value law is not an upper bound.")
    print()


def demo_envelope() -> None:
    print("=" * 78)
    print("4. The sharp booked envelope, attained at both ends")
    print("=" * 78)
    m, M = 16, 32
    P = 1.0 - 1.0 / m
    lo, hi = envelope(M, m, P)
    c = scan_kernel(M)
    ec_head = expected_cost(c, head_witness(m))
    ec_tail = expected_cost(c, tail_witness(M, m, P))
    bk = booked_ec(M, m, P)
    print(f"  bookings (M, m, P) = ({M}, {m}, {P:.6f})")
    print(f"  envelope      : [{lo:.6f}, {hi:.6f}]   (width {hi-lo:.6f})")
    print(f"  head witness  : EC = {ec_head:.6f}   (lower end, gap {abs(ec_head-lo):.2e})")
    print(f"  tail witness  : EC = {ec_tail:.6f}   (upper end, gap {abs(ec_tail-hi):.2e})")
    print(f"  booked value  : EC = {bk:.6f}   inside envelope: {lo <= bk <= hi}")

    # random admissible weights all land inside
    rng = random.Random(7)
    inside = 0
    trials = 2000
    for _ in range(trials):
        head = [rng.random() for _ in range(m)]
        tail = [rng.random() for _ in range(M - m)]
        hs, ts = sum(head), sum(tail)
        w = [P * x / hs for x in head] + [(1 - P) * x / ts for x in tail]
        ec = expected_cost(c, w)
        inside += (lo - 1e-9 <= ec <= hi + 1e-9)
    print(f"  {inside}/{trials} random admissible weights inside the envelope "
          f"({100.0*inside/trials:.1f}%)")
    print()


def demo_majorization() -> None:
    print("=" * 78)
    print("5. Majorization: a descending weight beats C0 = (M+1)/2, strictly unless flat")
    print("=" * 78)
    M = 32
    c = scan_kernel(M)
    C0 = baseline_c0(M)
    flat = [1.0 / M] * M
    print(f"  flat weight        : EC = {expected_cost(c, flat):.6f}   C0 = {C0:.6f}  "
          f"(equality)")
    rng = random.Random(11)
    worst_defect = 0.0
    for label, gen in (
        ("geometric  p=0.9", lambda i: 0.9 ** i),
        ("power law  1/i^2", lambda i: 1.0 / (i + 1) ** 2),
        ("linear ramp     ", lambda i: float(M - i)),
    ):
        raw = [gen(i) for i in range(M)]
        s = sum(raw)
        w = [x / s for x in raw]
        ec = expected_cost(c, w)
        worst_defect = max(worst_defect, C0 - ec)
        print(f"  {label}: EC = {ec:9.6f}   defect C0 - EC = {C0 - ec:9.6f}  (> 0)")
    # rearrangement: sorting descending is optimal
    raw = [rng.random() for _ in range(M)]
    s = sum(raw)
    w_sorted = sorted((x / s for x in raw), reverse=True)
    best = expected_cost(c, w_sorted)
    worse = min(expected_cost(c, random.Random(k).sample(w_sorted, M)) for k in range(200))
    print(f"  rearrangement: sorted EC = {best:.6f} <= best of 200 shuffles = {worse:.6f}")
    print()


def demo_master_inequality() -> None:
    print("=" * 78)
    print("6. Pigeonhole on a k-bit filter and the master inequality")
    print("=" * 78)
    M, k = 4096, 5
    rng = random.Random(3)
    buckets: Dict[int, int] = {}
    for i in range(M):
        b = rng.randrange(2 ** k)
        buckets[b] = buckets.get(b, 0) + 1
    largest = max(buckets.values())
    print(f"  M = {M} slots into 2^{k} = {2**k} buckets: largest bucket = {largest} "
          f">= M/2^k = {M / 2**k:.1f}   (pigeonhole holds: {largest >= M / 2**k})")
    lam, th, qhat = 1.2, 0.95, 0.30
    Cdesc = 1000.0
    branch_q = 1.0 / (lam * th * qhat)
    branch_k = (2.0 ** k) / (lam * th)
    cap = min(branch_q, branch_k)
    CA = max(lam * th * qhat * Cdesc, M / 2 ** k)
    S = Cdesc / CA
    print(f"  bookings Lambda={lam}, Theta={th}, qhat={qhat}, k={k}")
    print(f"  branch 1: 1/(L*T*q)   = {branch_q:.6f}")
    print(f"  branch 2: 2^k/(L*T)   = {branch_k:.6f}")
    print(f"  master cap = min      = {cap:.6f};  realised S = {S:.6f};  "
          f"S <= cap: {S <= cap + 1e-12}")
    print()


def demo_certified_law_and_baseline() -> None:
    print("=" * 78)
    print("7. The certified block law, and its baseline conditionality")
    print("=" * 78)
    mu, P = 0.05, 0.85
    print(f"  anchor (mu, P) = ({mu}, {P}):  D = {agreement(mu, P):.6f}, "
          f"S = {certified_value(mu, P):.10f}  (= 200/37)")
    print("      M      S_full-scan     S_descending     ratio (M+1)/(2M)")
    for M in (10, 100, 1000, 10 ** 6):
        S = certified_value(mu, P)
        Sd = desc_value(float(M), mu, P)
        print(f"  {M:8d}   {S:12.6f}   {Sd:14.6f}   {(M+1)/(2*M):16.8f}")
    print("  -> S/2 < S_descending < S always; the certified number asymptotically")
    print("     DOUBLES the value the same algorithm has against C0 = (M+1)/2.")

    print()
    print("  Adversarial locus (same prior, mu nudged from 0.050 to 0.052):")
    print(f"    S(0.050, 0.85) = {certified_value(0.05, 0.85):.6f}")
    print(f"    S(0.052, 0.85) = {certified_value(0.052, 0.85):.6f}   "
          f"undercut: {certified_value(0.052, 0.85) < certified_value(0.05, 0.85)}")
    print()


def demo_feasibility_and_erratum() -> None:
    print("=" * 78)
    print("8. Feasibility test and the anchor-table erratum")
    print("=" * 78)
    stored = Fraction(9853, 10000)
    rounded = Fraction(985, 1000)
    mu = Fraction(2, 100)

    def exact_S(m: Fraction, p: Fraction) -> Fraction:
        return 1 / (m * p + (1 - m) * (1 - p))

    S_stored = exact_S(mu, stored)
    S_rounded = exact_S(mu, rounded)
    print(f"  stored  P-hat = 0.9853 :  S = {S_stored} = {float(S_stored):.6f}")
    print(f"  rounded P     = 0.985  :  S = {S_rounded} = {float(S_rounded):.6f}")
    print("  the printed table entry 29.0698... is the ROUNDED value; the correct")
    print(f"  entry at the stored measurement is {float(S_stored):.4f}   "
          f"(shift {float(S_stored - S_rounded):.4f})")
    print()
    print("  Feasibility  mu <= 1/S  on the admissible half-box (slack = (1-P)(1-2mu)):")
    for m_, p_ in ((0.02, 0.9853), (0.02, 0.985), (0.05, 0.85), (0.115, 0.87),
                   (0.30, 0.60), (0.50, 0.99)):
        slack = feasibility_slack(m_, p_)
        print(f"    mu={m_:5.3f}  P={p_:6.4f}  S={certified_value(m_, p_):8.4f}  "
              f"1/S={1/certified_value(m_, p_):.6f}  slack={slack:+.6f}  "
              f"feasible={slack >= -1e-15}")
    print("  -> the verdict never flips: it is insensitive to the precision of P-hat.")
    print()
    print("  Superseded / stale readings:")
    for label, val in (("drafted 5.19 window", 5.1948), ("certified anchor", 5.4054)):
        print(f"    {label:22s}: {val}")
    print(f"    stale locus (0.115, 0.87): S = {certified_value(0.115, 0.87):.4f}")
    print()


def demo_composition() -> None:
    print("=" * 78)
    print("9. Composition: 1/S is a Bernoulli agreement probability")
    print("=" * 78)
    # Monte-Carlo check that D is an agreement probability.
    rng = random.Random(99)
    mu, P = 0.37, 0.71
    n = 400000
    agree = sum(1 for _ in range(n) if (rng.random() < mu) == (rng.random() < P))
    print(f"  D({mu}, {P}) = {agreement(mu, P):.6f}   Monte-Carlo agreement rate = "
          f"{agree/n:.6f}   (n = {n})")
    print()
    print("  Strict submultiplicativity  S(mu1*mu2, P1*P2) < S1 * S2:")
    print("      (mu1,P1)      (mu2,P2)     composite      product      slack")
    for (a, b, c_, d) in ((0.5, 0.9, 0.5, 0.999), (0.2, 0.8, 0.4, 0.7),
                          (0.05, 0.85, 0.1, 0.9), (0.3, 0.6, 0.3, 0.6)):
        comp = certified_value(a * c_, b * d)
        prod = certified_value(a, b) * certified_value(c_, d)
        print(f"   ({a:.2f},{b:.3f})  ({c_:.2f},{d:.3f})  {comp:10.6f}  {prod:10.6f}  "
              f"{prod - comp:+.6f}")
    print("  boundary case (mu1,P1)=(1/2,9/10), (mu2,P2)=(1/2,1): "
          f"composite = {certified_value(0.25, 0.9):.6f}, product = "
          f"{certified_value(0.5, 0.9) * certified_value(0.5, 1.0):.6f}")
    print("  -> reporting a composed guarantee as a product is conservative, never")
    print("     optimistic.")
    print()


def demo_canonical_prior() -> None:
    print("=" * 78)
    print("10. The canonical reporting prior b(r) = 0.5 r^{-3/2}")
    print("=" * 78)
    for R in (1.5, 2.0, 4.0, 10.0, 100.0):
        num = numeric_integral(canonical_kernel, 1.0, R, 20000)
        print(f"  R = {R:7.2f}:  integral_1^R b = {num:.8f}   1 - R^(-1/2) = "
              f"{capture_cdf(R):.8f}   (balance-interval length)")
    print()
    Rmax = 25.0
    print(f"  Capture curve is exactly linear in mu = 1 - R^(-1/2)  (Rmax = {Rmax}):")
    print("       R        mu        P(R)      mu/(1-Rmax^(-1/2))")
    slope_den = 1.0 - 1.0 / math.sqrt(Rmax)
    for R in (1.0, 2.0, 5.0, 12.0, 25.0):
        mu_ = capture_cdf(R)
        print(f"  {R:7.2f}  {mu_:8.6f}  {capture_prob(Rmax, R):8.6f}  "
              f"{mu_/slope_den:18.6f}")
    print()
    print("  A non-canonical (uniform) prior fails the linearity test:")
    unif = (2.0 - 1.0) / (4.0 - 1.0)
    print(f"    uniform on [1,4], capture at R=2 : {unif:.6f}")
    print(f"    canonical         capture at R=2 : {capture_prob(4.0, 2.0):.6f}  "
          f"(= 2 - sqrt 2)")
    print("  -> linear capture curve IFF canonical kernel.")
    print()


def main() -> None:
    print()
    print("POSITIONAL-STRATUM MEASURE FRAMEWORK -- NUMERICAL DEMONSTRATIONS")
    print()
    demo_rbar_identity()
    demo_theta()
    demo_value_universality_fails()
    demo_envelope()
    demo_majorization()
    demo_master_inequality()
    demo_certified_law_and_baseline()
    demo_feasibility_and_erratum()
    demo_composition()
    demo_canonical_prior()
    print("=" * 78)
    print("Summary: the r-bar identity is exact and universal; the booked value law")
    print("is a reporting convention whose failure is unbounded; the envelope and the")
    print("master inequality are the guarded statements that survive; and every value")
    print("claim is conditional on a named baseline and a pinned locus.")
    print("=" * 78)


if __name__ == "__main__":
    main()
