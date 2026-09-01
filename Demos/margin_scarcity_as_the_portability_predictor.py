"""
Margin Scarcity as the Portability Predictor
============================================

Numerical demonstration of the results on certified forward-pass screens for
block transplantation.

The setting.  A block of layers is moved from a donor network into a host
network.  At each position x of a held-out set the resulting hybrid produces a
score vector, commits to its argmax, and we measure the *damage fraction*: the
fraction of positions whose decision differs from the reference decision.

Two candidate predictors of damage are compared:

  * the NORM route -- the entrywise weight-space distance between the two
    copies of the block, via the Lipschitz estimate |logit_A - logit_B| <=
    k * delta * B;
  * the MARGIN route -- the fraction of positions carrying no margin
    certificate, i.e. whose top-1 gap fails to exceed twice the drift budget.

The results demonstrated here:

  1.  damage <= margin-uncertified fraction        (the margin screen)
  2.  a distance-D transplant with damage 0 next to a distance-d transplant
      with damage 1, for any 0 < d < D              (norm route refuted)
  3.  cov(margin, damage) = +1/4 while cov(distance, damage) = -(D-d)/4
      on the SAME two-block family                  (opposite covariance signs)
  4.  cov(pred, dam) >= Var(dam) - (eta/2) sqrt(Var(dam))
                                                    (correlation theorem)
  5.  diffuse fraction <= uncertified fraction      (Renyi-2 obstruction)
  6.  damage <= (G - mu) / (G - 2 eps)              (two-scalar bound)

Everything is self-contained: standard library plus a tiny amount of arithmetic.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
#  Section 0.  Core statistics
# --------------------------------------------------------------------------- #


def argmax(scores: Sequence[float]) -> int:
    """Index of the largest entry (first one wins ties)."""
    best_i, best_v = 0, scores[0]
    for i, v in enumerate(scores):
        if v > best_v:
            best_i, best_v = i, v
    return best_i


def is_strict_top(scores: Sequence[float], j: int) -> bool:
    """True iff `scores[j]` strictly dominates every other coordinate."""
    return all(scores[i] < scores[j] for i in range(len(scores)) if i != j)


def top1_gap(scores: Sequence[float]) -> float:
    """Difference between the largest and second-largest score."""
    ordered = sorted(scores, reverse=True)
    return ordered[0] - ordered[1] if len(ordered) > 1 else float("inf")


def damage_fraction(hybrid: Sequence[int], reference: Sequence[int]) -> float:
    """Fraction of positions at which the two decision maps disagree."""
    n = len(reference)
    return sum(1 for a, b in zip(hybrid, reference) if a != b) / n


def margin_certified(
    u: Sequence[float], v: Sequence[float], d: int, eps: float
) -> bool:
    """Definition of a margin certificate at drift budget `eps`.

    Two clauses: the donor's top-1 gap at the reference class exceeds 2*eps,
    and the drift from the donor scores `u` to the hybrid scores `v` is within
    `eps` in every coordinate.
    """
    gap_ok = all(u[d] - u[j] > 2.0 * eps for j in range(len(u)) if j != d)
    drift_ok = all(abs(u[j] - v[j]) <= eps for j in range(len(u)))
    return gap_ok and drift_ok


def uncertified_fraction(
    U: Sequence[Sequence[float]],
    V: Sequence[Sequence[float]],
    D: Sequence[int],
    eps: float,
) -> float:
    """Margin scarcity: the fraction of positions with no margin certificate."""
    n = len(U)
    return sum(1 for x in range(n) if not margin_certified(U[x], V[x], D[x], eps)) / n


def collision_mass(p: Sequence[float]) -> float:
    """Sum of squared scores; the exponential of minus the Renyi-2 entropy."""
    return sum(pk * pk for pk in p)


def renyi2(p: Sequence[float]) -> float:
    """Renyi-2 entropy of a (nonnegative) score vector."""
    c = collision_mass(p)
    return -math.log(c) if c > 0 else float("inf")


def diffuse_fraction(U: Sequence[Sequence[float]], eps: float) -> float:
    """Fraction of positions whose collision mass is at most 4*eps^2."""
    n = len(U)
    return sum(1 for x in range(n) if collision_mass(U[x]) <= 4.0 * eps * eps) / n


def low_margin_fraction(g: Sequence[float], eps: float) -> float:
    """Fraction of positions whose gap surrogate falls below 2*eps."""
    return sum(1 for gx in g if gx <= 2.0 * eps) / len(g)


# --------------------------------------------------------------------------- #
#  Section 0b.  Family (cross-block) statistics
# --------------------------------------------------------------------------- #


def fam_mean(f: Sequence[float]) -> float:
    return sum(f) / len(f)


def fam_cov(f: Sequence[float], g: Sequence[float]) -> float:
    mf, mg = fam_mean(f), fam_mean(g)
    return sum((a - mf) * (b - mg) for a, b in zip(f, g)) / len(f)


def fam_var(f: Sequence[float]) -> float:
    return fam_cov(f, f)


# --------------------------------------------------------------------------- #
#  Section 0c.  The linear block model
# --------------------------------------------------------------------------- #

Matrix = List[List[float]]


def block_logit(W: Matrix, feat: Sequence[float]) -> List[float]:
    """logit_W(x)_j = sum_i W[j][i] * feat[i]."""
    return [sum(W[j][i] * feat[i] for i in range(len(feat))) for j in range(len(W))]


def entrywise_distance(WA: Matrix, WB: Matrix) -> float:
    """max_{j,i} |WA[j][i] - WB[j][i]|."""
    return max(abs(WA[j][i] - WB[j][i]) for j in range(len(WA)) for i in range(len(WA[0])))


def lipschitz_logit_bound(k: int, delta: float, B: float) -> float:
    """The norm route's logit perturbation budget k * delta * B."""
    return k * delta * B


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# --------------------------------------------------------------------------- #
#  Demo 1.  The margin screen:  damage <= uncertified fraction
# --------------------------------------------------------------------------- #


def demo_margin_screen(n: int = 4000, m: int = 8, eps: float = 0.35,
                       seed: int = 20260901) -> None:
    banner("DEMO 1 -- The margin screen:  damage  <=  margin-uncertified fraction")

    rng = random.Random(seed)
    donor: List[List[float]] = []
    hybrid: List[List[float]] = []
    reference: List[int] = []

    for _ in range(n):
        # A donor score vector with a heterogeneous top-1 gap: sometimes a clear
        # winner, sometimes a near-tie (the "diffuse tail" of the distribution).
        base = [rng.gauss(0.0, 1.0) for _ in range(m)]
        winner = argmax(base)
        # Inflate the winner by a random amount, producing a spread of gaps.
        base[winner] += rng.choice([0.05, 0.15, 0.4, 0.9, 2.0]) * rng.random() * 2.0
        donor.append(base)
        reference.append(argmax(base))
        # The transplant perturbs each logit by at most eps (the drift budget).
        hybrid.append([b + rng.uniform(-eps, eps) for b in base])

    hybrid_decisions = [argmax(v) for v in hybrid]

    dam = damage_fraction(hybrid_decisions, reference)
    unc = uncertified_fraction(donor, hybrid, reference, eps)

    print(f"  positions              n     = {n}")
    print(f"  classes                m     = {m}")
    print(f"  drift budget           eps   = {eps}")
    print()
    print(f"  measured damage fraction     = {dam:.4f}   (requires the transplant)")
    print(f"  margin-uncertified fraction  = {unc:.4f}   (one forward pass only)")
    print(f"  screen slack  unc - damage   = {unc - dam:.4f}")
    print()
    print(f"  Theorem (margin screen):  damage <= unc  ...  "
          f"{'HOLDS' if dam <= unc + 1e-12 else 'VIOLATED'}")

    # Screening at a tolerance tau.
    for tau in (0.10, 0.25, 0.50, 0.75):
        verdict = "ACCEPT (damage certified <= tau)" if unc <= tau else "no certificate"
        print(f"    tolerance tau = {tau:.2f}:  {verdict}")


# --------------------------------------------------------------------------- #
#  Demo 2.  Weight distance is refuted:  distance D / damage 0
#           beside distance d / damage 1
# --------------------------------------------------------------------------- #


def dead_direction_pair(D: float) -> Tuple[Matrix, Matrix]:
    """Weight pair differing by exactly D, entirely in a dead feature column."""
    return [[1.0, 0.0], [0.0, 0.0]], [[1.0, D], [0.0, 0.0]]


def live_direction_pair(d: float) -> Tuple[Matrix, Matrix]:
    """Weight pair differing by exactly d, straight along the live column."""
    return [[d / 2, 0.0], [-d / 2, 0.0]], [[-d / 2, 0.0], [d / 2, 0.0]]


DEAD_FEAT: List[float] = [1.0, 0.0]  # second coordinate is invisible to the logits


def demo_norm_refuted(d: float = 0.001, D: float = 1000.0, n: int = 500) -> None:
    banner("DEMO 2 -- Weight-space distance is not a predictor of damage")

    WA, WB = dead_direction_pair(D)
    WAp, WBp = live_direction_pair(d)

    lA, lB = block_logit(WA, DEAD_FEAT), block_logit(WB, DEAD_FEAT)
    lAp, lBp = block_logit(WAp, DEAD_FEAT), block_logit(WBp, DEAD_FEAT)

    dam_dead = damage_fraction([argmax(lB)] * n, [argmax(lA)] * n)
    dam_live = damage_fraction([argmax(lBp)] * n, [argmax(lAp)] * n)

    print(f"  features are (1, 0) at every position: the second coordinate is DEAD.")
    print()
    print("  BLOCK 1 (dead direction):")
    print(f"    W_A = {WA},  W_B = {WB}")
    print(f"    entrywise weight distance  = {entrywise_distance(WA, WB):.4f}")
    print(f"    donor logits  = {lA},  hybrid logits = {lB}")
    print(f"    measured damage            = {dam_dead:.4f}")
    print()
    print("  BLOCK 2 (live direction):")
    print(f"    W_A' = {WAp},  W_B' = {WBp}")
    print(f"    entrywise weight distance  = {entrywise_distance(WAp, WBp):.6f}")
    print(f"    donor logits  = {lAp},  hybrid logits = {lBp}")
    print(f"    measured damage            = {dam_live:.4f}")
    print()
    print(f"  distance ratio  D/d = {D / d:,.0f}  ...  yet the FAR block is harmless")
    print("  and the NEAR block flips every single decision.")
    print()
    print("  Corollary: any damage bound g(delta) depending on the weight distance")
    print("  alone must satisfy g(delta) >= 1 for every delta > 0, i.e. it is the")
    print("  trivial bound.  Instantiate the live-direction pair at scale delta:")
    for delta in (1e-6, 1e-3, 1.0, 1e3):
        WAd, WBd = live_direction_pair(delta)
        dm = damage_fraction([argmax(block_logit(WBd, DEAD_FEAT))] * n,
                             [argmax(block_logit(WAd, DEAD_FEAT))] * n)
        print(f"    delta = {delta:>10.6g}   forced lower bound on g(delta) = {dm:.1f}")
    print()
    print("  For contrast, the norm route as a SUFFICIENT condition is sound:")
    k, B = 2, 1.0
    for delta, gap in ((0.01, 1.0), (0.30, 1.0)):
        budget = 2 * lipschitz_logit_bound(k, delta, B)
        ok = gap > budget
        print(f"    delta = {delta:.2f}: gap {gap:.2f} vs 2*k*delta*B = {budget:.2f}"
              f"  ->  {'zero damage CERTIFIED' if ok else 'no certificate'}")


# --------------------------------------------------------------------------- #
#  Demo 3.  Opposite covariance signs on the same two-block family
# --------------------------------------------------------------------------- #


def demo_opposite_signs(d: float = 0.5, D: float = 4.0) -> None:
    banner("DEMO 3 -- Same data, opposite covariance signs")

    # Block statistics from Demo 2, at drift budget eps = 0.
    margin_stat = [0.0, 1.0]   # dead-direction block, live-direction block
    distance = [D, d]
    damage = [0.0, 1.0]

    cov_margin = fam_cov(margin_stat, damage)
    cov_norm = fam_cov(distance, damage)

    print(f"  two-block family, 0 < d = {d} < D = {D}")
    print()
    print(f"  {'block':<22}{'margin stat':>14}{'distance':>12}{'damage':>10}")
    for name, ms, ds, dm in zip(("dead direction", "live direction"),
                                margin_stat, distance, damage):
        print(f"  {name:<22}{ms:>14.4f}{ds:>12.4f}{dm:>10.4f}")
    print()
    print(f"  cov(margin statistic, damage) = {cov_margin:+.6f}"
          f"   (theory: +1/4 = {0.25:+.6f})")
    print(f"  cov(weight distance,  damage) = {cov_norm:+.6f}"
          f"   (theory: -(D-d)/4 = {-(D - d) / 4:+.6f})")
    print()
    print("  The forward-pass statistic ranks the blocks by portability correctly;")
    print("  the weight-space distance ranks them exactly backwards.")

    # Sanity check of the closed form cov((a,b),(c,e)) = (a-b)(c-e)/4.
    a, b, c, e = 1.7, -0.3, 2.5, 0.25
    assert abs(fam_cov([a, b], [c, e]) - (a - b) * (c - e) / 4) < 1e-12
    print()
    print("  (closed form  cov((a,b),(c,e)) = (a-b)(c-e)/4  verified numerically)")


# --------------------------------------------------------------------------- #
#  Demo 4.  The correlation theorem across a family of blocks
# --------------------------------------------------------------------------- #


def demo_correlation(seed: int = 7) -> None:
    banner("DEMO 4 -- Correlation theorem:  cov(pred, dam) >= Var(dam) - (eta/2) sd(dam)")

    # (a) The two measured arms.
    dam_measured = [0.4557, 0.1615]
    var = fam_var(dam_measured)
    sd = math.sqrt(var)
    print("  (a) the two measured transplant arms")
    print(f"      damages            = {dam_measured}")
    print(f"      mean               = {fam_mean(dam_measured):.4f}")
    print(f"      Var(dam)           = {var:.6f}")
    print(f"      sd  = sqrt(Var)    = {sd:.5f}")
    print(f"      covariance certified positive for any screen slack eta < "
          f"{2 * sd:.5f}")
    print()

    # (b) Random block families: check the bound and the positivity criterion.
    rng = random.Random(seed)
    print("  (b) randomised check over synthetic block families")
    print(f"      {'L':>3} {'eta':>7} {'sd(dam)':>9} {'lower bound':>13} "
          f"{'cov(pred,dam)':>15} {'bound ok':>9} {'sign ok':>8}")
    for trial in range(8):
        L = rng.randint(2, 12)
        eta = rng.choice([0.0, 0.02, 0.08, 0.2, 0.5])
        dam = [rng.random() for _ in range(L)]
        pred = [min(1.0, dx + rng.uniform(0.0, eta)) for dx in dam]
        cov = fam_cov(pred, dam)
        s = math.sqrt(fam_var(dam))
        lower = fam_var(dam) - (eta / 2.0) * s
        bound_ok = cov >= lower - 1e-12
        sign_ok = (cov > 0) if s > eta / 2.0 else True
        print(f"      {L:>3} {eta:>7.2f} {s:>9.4f} {lower:>13.6f} "
              f"{cov:>15.6f} {str(bound_ok):>9} {str(sign_ok):>8}")
    print()
    print("      'bound ok'  = the correlation lower bound holds")
    print("      'sign ok'   = whenever sd(dam) > eta/2 the covariance is positive")


# --------------------------------------------------------------------------- #
#  Demo 5.  Renyi-2 diffuseness as a certified obstruction
# --------------------------------------------------------------------------- #


def demo_entropy_obstruction(n: int = 3000, m: int = 10, eps: float = 0.30,
                             seed: int = 4242) -> None:
    banner("DEMO 5 -- Renyi-2 diffuseness:  diffuse fraction  <=  uncertified fraction")

    rng = random.Random(seed)
    donor: List[List[float]] = []
    hybrid: List[List[float]] = []
    reference: List[int] = []

    for _ in range(n):
        # Nonnegative score vectors (probabilities), with a mixture of peaked
        # and diffuse positions.
        if rng.random() < 0.4:
            raw = [rng.random() ** 6 for _ in range(m)]   # peaked
        else:
            raw = [0.8 + 0.4 * rng.random() for _ in range(m)]  # diffuse
        s = sum(raw)
        p = [r / s for r in raw]
        donor.append(p)
        reference.append(argmax(p))
        hybrid.append([max(0.0, pk + rng.uniform(-eps, eps) * 0.2) for pk in p])

    diff = diffuse_fraction(donor, eps)
    unc = uncertified_fraction(donor, hybrid, reference, eps)
    dam = damage_fraction([argmax(v) for v in hybrid], reference)

    print(f"  positions n = {n}, classes m = {m}, drift budget eps = {eps}")
    print(f"  diffuseness threshold: collision mass C <= 4*eps^2 = {4 * eps ** 2:.4f}")
    print(f"  equivalently Renyi-2 entropy H2 >= 2 log(1/(2 eps)) = "
          f"{2 * math.log(1 / (2 * eps)):.4f}")
    print()
    print(f"  diffuse fraction             = {diff:.4f}   (lower bound on the screen)")
    print(f"  margin-uncertified fraction  = {unc:.4f}   (the screen)")
    print(f"  measured damage fraction     = {dam:.4f}   (bounded by the screen)")
    print()
    print(f"  sandwich  diffuse <= unc :  "
          f"{'HOLDS' if diff <= unc + 1e-12 else 'VIOLATED'}")
    print(f"  screen    damage  <= unc :  "
          f"{'HOLDS' if dam <= unc + 1e-12 else 'VIOLATED'}")
    print()
    print("  Consequence (concentration is necessary): a block certified portable")
    print("  below tau must be tau-concentrated, so a block that is 40% diffuse can")
    print("  never be certified below 40% damage by the margin route.")

    # The entropy form of the criterion, verified position by position.
    mismatches = 0
    for p in donor:
        by_mass = collision_mass(p) <= 4 * eps ** 2
        by_entropy = renyi2(p) >= 2 * math.log(1.0 / (2 * eps)) - 1e-12
        mismatches += int(by_mass != by_entropy)
    print()
    print(f"  collision-mass criterion vs Renyi-2 criterion: "
          f"{n - mismatches}/{n} positions agree")


# --------------------------------------------------------------------------- #
#  Demo 6.  Two scalars bound the damage (reverse Markov)
# --------------------------------------------------------------------------- #


def two_scalar_bound(G: float, mu: float, eps: float) -> float:
    """The reverse-Markov damage bound (G - mu) / (G - 2 eps)."""
    if not 2.0 * eps < G:
        raise ValueError("the bound requires 2*eps < G")
    return (G - mu) / (G - 2.0 * eps)


def demo_two_scalar(n: int = 5000, eps: float = 0.16, G: float = 5.0,
                    seed: int = 99) -> None:
    banner("DEMO 6 -- Two forward-pass scalars bound the damage")

    rng = random.Random(seed)
    gaps = [min(G, abs(rng.gauss(2.2, 1.4))) for _ in range(n)]
    mu = sum(gaps) / n

    bound = two_scalar_bound(G, mu, eps)
    lmf = low_margin_fraction(gaps, eps)

    print(f"  gap cap        G    = {G}")
    print(f"  mean gap       mu   = {mu:.4f}")
    print(f"  drift budget   eps  = {eps}   (2*eps = {2 * eps})")
    print()
    print(f"  reverse-Markov bound  (G - mu)/(G - 2 eps) = {bound:.4f}")
    print(f"  actual low-margin fraction                 = {lmf:.4f}")
    print(f"  bound holds: {'YES' if lmf <= bound + 1e-12 else 'NO'}")
    print()
    print("  Sharpness: on two positions with gaps (2 eps, G) the bound is attained.")
    sharp_gaps = [2 * eps, G]
    sharp_mu = (2 * eps + G) / 2
    print(f"    gaps = {sharp_gaps},  mean = {sharp_mu:.4f}")
    print(f"    bound = {two_scalar_bound(G, sharp_mu, eps):.4f},  "
          f"low-margin fraction = {low_margin_fraction(sharp_gaps, eps):.4f}")
    print()
    print("  The falsifiable consequence.  A measured damage of 0.4557 forces")
    print("  mu <= G - 0.4557 * (G - 2 eps):")
    for GG, ee in ((5.0, 0.16), (3.0, 0.16), (5.0, 0.50), (8.0, 0.25)):
        cap = GG - 0.4557 * (GG - 2 * ee)
        print(f"    G = {GG:>4.1f}, eps = {ee:>4.2f}  ->  mean top-1 gap <= {cap:.4f} nats")


# --------------------------------------------------------------------------- #
#  Demo 7.  The screen is one-sided, and it is attained
# --------------------------------------------------------------------------- #


def demo_boundaries(n: int = 100) -> None:
    banner("DEMO 7 -- The exact boundary of the margin screen")

    # Conservative: uncertified fraction 1, damage 0.
    u_cons = [[1.0, 0.0]] * n
    v_cons = [[1.0, 0.0]] * n
    d_cons = [0] * n
    dh_cons = [0] * n
    print("  (a) the screen is only SUFFICIENT (uncertified = 1, damage = 0)")
    print(f"      u = v = (1, 0),  eps = 1:  gap 1 does not exceed 2*eps = 2")
    print(f"      uncertified fraction = "
          f"{uncertified_fraction(u_cons, v_cons, d_cons, 1.0):.4f}")
    print(f"      damage fraction      = {damage_fraction(dh_cons, d_cons):.4f}")
    print("      -> margin scarcity is a CEILING, never an estimate.")
    print()

    # Attained: uncertified fraction 1, damage 1.
    u_att = [[1.0, 0.0]] * n
    v_att = [[0.0, 1.0]] * n
    d_att = [0] * n
    dh_att = [1] * n
    print("  (b) the screen is ATTAINED (uncertified = 1, damage = 1)")
    print(f"      u = (1, 0), v = (0, 1),  eps = 1")
    print(f"      uncertified fraction = "
          f"{uncertified_fraction(u_att, v_att, d_att, 1.0):.4f}")
    print(f"      damage fraction      = {damage_fraction(dh_att, d_att):.4f}")
    print("      -> no constant c < 1 with damage <= c * uncertified can exist.")
    print()

    # Diffuse but undamaged: the sandwich cannot be closed.
    print("  (c) the entropy sandwich cannot be closed (diffuse = 1, damage = 0)")
    print(f"      u = v = (1, 0),  eps = 1:  C = 1 <= 4 = 4*eps^2")
    print(f"      diffuse fraction     = {diffuse_fraction(u_cons, 1.0):.4f}")
    print(f"      damage fraction      = {damage_fraction(dh_cons, d_cons):.4f}")
    print("      -> diffuseness bounds the CERTIFICATE, not the damage.")


# --------------------------------------------------------------------------- #
#  Main
# --------------------------------------------------------------------------- #


def main() -> None:
    print(__doc__)
    demo_margin_screen()
    demo_norm_refuted()
    demo_opposite_signs()
    demo_correlation()
    demo_entropy_obstruction()
    demo_two_scalar()
    demo_boundaries()
    banner("All demonstrations complete.")


if __name__ == "__main__":
    main()
