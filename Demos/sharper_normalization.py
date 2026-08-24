"""
Sharper normalization: numerical demonstrations of the attained factor-1/2
theory of total variation distance.

Everything in this file is self-contained (standard library only) and verifies,
on concrete finite distributions, the results of the accompanying paper:

  1. Event-supremum characterization
         d_TV(p, q) = max_A ( p(A) - q(A) ),   attained at A* = {x : q(x) <= p(x)}
     checked against brute-force enumeration of all 2^N events.

  2. Randomization does not help: random [0,1]-valued tests never beat A*.

  3. Factor-two dichotomy: sup over [0,1]-tests is d_TV, sup over [-1,1]-tests
     is 2 d_TV = ||p - q||_1.

  4. Maximal coupling: c*(x,y) = min(p,q)(x)[x=y] + p#(x) q#(y) / d_TV
     is a coupling with P[X != Y] = d_TV exactly, and no coupling does better
     (checked against random couplings and against the independent coupling).

  5. Two-point testing: the least average error over all 2^N Boolean tests
     equals (1 - d_TV)/2.

  6. Data processing: random stochastic channels never increase d_TV.

  7. n-sample amplification: exact d_TV(p^n, q^n) versus the geometric bound
     1 - (1 - d_TV)^n and the hybrid bound n * d_TV.

  8. Pinsker bridge: d_TV <= sqrt(KL/2), and the converse certificate
     KL >= 2 * gap^2 for every event.

  9. Shtarkov sum = multi-hypothesis testing optimum: the least uniform-prior
     error of an m-ary rule equals 1 - C_S / m, checked by brute force over all
     m^N decision rules, with the binary case reproducing (1 - d_TV)/2.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Iterable, Sequence

Vec = Sequence[float]
Mat = Sequence[Sequence[float]]

TOL = 1e-9


# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------


def tv_distance(p: Vec, q: Vec) -> float:
    """d_TV(p, q) = (1/2) * sum_x |p(x) - q(x)| -- the sharp normalization."""
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


def l1_distance(p: Vec, q: Vec) -> float:
    """||p - q||_1 = 2 * d_TV(p, q) -- the coarse normalization."""
    return sum(abs(a - b) for a, b in zip(p, q))


def event_gap(p: Vec, q: Vec, event: Iterable[int]) -> float:
    """p(A) - q(A) for an event A given as a collection of indices."""
    idx = list(event)
    return sum(p[i] for i in idx) - sum(q[i] for i in idx)


def separating_event(p: Vec, q: Vec) -> list[int]:
    """The likelihood-ratio (Neyman-Pearson) event A* = {x : q(x) <= p(x)}."""
    return [i for i in range(len(p)) if q[i] <= p[i]]


def shared_mass(p: Vec, q: Vec) -> float:
    """sum_x min(p(x), q(x)) = 1 - d_TV(p, q)."""
    return sum(min(a, b) for a, b in zip(p, q))


def all_events(n: int) -> Iterable[tuple[int, ...]]:
    """Enumerate every subset of {0, ..., n-1} as a tuple of indices."""
    for mask in range(1 << n):
        yield tuple(i for i in range(n) if mask >> i & 1)


def brute_force_max_gap(p: Vec, q: Vec) -> tuple[float, tuple[int, ...]]:
    """max_A (p(A) - q(A)) by enumerating all 2^N events."""
    best_value = -math.inf
    best_event: tuple[int, ...] = ()
    for event in all_events(len(p)):
        value = event_gap(p, q, event)
        if value > best_value:
            best_value, best_event = value, event
    return best_value, best_event


# ----------------------------------------------------------------------------
# Couplings
# ----------------------------------------------------------------------------


def maximal_coupling(p: Vec, q: Vec) -> list[list[float]]:
    """The maximal coupling: shared mass on the diagonal, leftovers paired
    independently and rescaled by t = d_TV(p, q)."""
    n = len(p)
    t = tv_distance(p, q)
    m = [min(a, b) for a, b in zip(p, q)]
    p_sharp = [p[i] - m[i] for i in range(n)]
    q_sharp = [q[i] - m[i] for i in range(n)]
    c = [[0.0] * n for _ in range(n)]
    for x in range(n):
        c[x][x] += m[x]
    if t > TOL:
        for x in range(n):
            if p_sharp[x] == 0.0:
                continue
            for y in range(n):
                c[x][y] += p_sharp[x] * q_sharp[y] / t
    return c


def independent_coupling(p: Vec, q: Vec) -> list[list[float]]:
    """The product coupling c(x, y) = p(x) q(y)."""
    return [[a * b for b in q] for a in p]


def is_coupling(c: Mat, p: Vec, q: Vec) -> bool:
    """Check nonnegativity and both marginal constraints."""
    n = len(p)
    if any(c[x][y] < -TOL for x in range(n) for y in range(n)):
        return False
    if any(abs(sum(c[x]) - p[x]) > 1e-8 for x in range(n)):
        return False
    if any(abs(sum(c[x][y] for x in range(n)) - q[y]) > 1e-8 for y in range(n)):
        return False
    return True


def disagreement_probability(c: Mat) -> float:
    """P_c[X != Y] = sum over off-diagonal entries."""
    n = len(c)
    return sum(c[x][y] for x in range(n) for y in range(n) if x != y)


def random_coupling(p: Vec, q: Vec, rng: random.Random, steps: int = 400) -> list[list[float]]:
    """A random point of the transport polytope, produced by starting at the
    independent coupling and applying random mass-preserving 2x2 rotations."""
    n = len(p)
    c = [row[:] for row in independent_coupling(p, q)]
    for _ in range(steps):
        x1, x2 = rng.randrange(n), rng.randrange(n)
        y1, y2 = rng.randrange(n), rng.randrange(n)
        if x1 == x2 or y1 == y2:
            continue
        delta = min(c[x1][y1], c[x2][y2]) * rng.random()
        c[x1][y1] -= delta
        c[x2][y2] -= delta
        c[x1][y2] += delta
        c[x2][y1] += delta
    return c


# ----------------------------------------------------------------------------
# Testing
# ----------------------------------------------------------------------------


def bayes_error(p: Vec, q: Vec, accept_q: Iterable[int]) -> float:
    """Uniform-prior average error of the Boolean test that declares 'q'
    exactly on the index set accept_q."""
    a = set(accept_q)
    err_under_p = sum(p[i] for i in a)
    err_under_q = sum(q[i] for i in range(len(q)) if i not in a)
    return 0.5 * (err_under_p + err_under_q)


def brute_force_min_bayes_error(p: Vec, q: Vec) -> float:
    """Least uniform-prior average error over all 2^N Boolean tests."""
    return min(bayes_error(p, q, event) for event in all_events(len(p)))


def shtarkov_sum(sources: Mat) -> float:
    """C_S = sum_x max_theta p_theta(x)."""
    n = len(sources[0])
    return sum(max(src[x] for src in sources) for x in range(n))


def m_ary_error(sources: Mat, rule: Sequence[int]) -> float:
    """Uniform-prior error of the decision rule x -> rule[x]."""
    m, n = len(sources), len(sources[0])
    total = 0.0
    for theta in range(m):
        total += sum(sources[theta][x] for x in range(n) if rule[x] != theta)
    return total / m


def brute_force_min_m_ary_error(sources: Mat) -> float:
    """Least uniform-prior error over all m^N decision rules."""
    m, n = len(sources), len(sources[0])
    return min(m_ary_error(sources, rule) for rule in itertools.product(range(m), repeat=n))


# ----------------------------------------------------------------------------
# Products, channels, divergence
# ----------------------------------------------------------------------------


def product_law(p: Vec, n: int) -> list[float]:
    """p^{tensor n} as a flat vector over X^n in lexicographic order."""
    out = [1.0]
    for _ in range(n):
        out = [w * pi for w in out for pi in p]
    return out


def push_forward(p: Vec, kernel: Mat) -> list[float]:
    """(pK)(y) = sum_x p(x) K(x, y)."""
    n_out = len(kernel[0])
    return [sum(p[x] * kernel[x][y] for x in range(len(p))) for y in range(n_out)]


def random_channel(n_in: int, n_out: int, rng: random.Random) -> list[list[float]]:
    """A random row-stochastic matrix."""
    rows = []
    for _ in range(n_in):
        row = [rng.random() + 1e-3 for _ in range(n_out)]
        s = sum(row)
        rows.append([v / s for v in row])
    return rows


def kl_divergence(qq: Vec, pp: Vec) -> float:
    """KL(Q || P) in nats, with the convention 0 log 0 = 0."""
    total = 0.0
    for a, b in zip(qq, pp):
        if a > 0.0:
            if b <= 0.0:
                return math.inf
            total += a * math.log(a / b)
    return total


def random_law(n: int, rng: random.Random) -> list[float]:
    raw = [rng.random() + 1e-3 for _ in range(n)]
    s = sum(raw)
    return [v / s for v in raw]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_event_supremum(p: Vec, q: Vec) -> None:
    banner("1. Event supremum:  d_TV = max_A (p(A) - q(A)), attained at {q <= p}")
    t = tv_distance(p, q)
    best_value, best_event = brute_force_max_gap(p, q)
    star = separating_event(p, q)
    print(f"p                       = {[round(v, 4) for v in p]}")
    print(f"q                       = {[round(v, 4) for v in q]}")
    print(f"d_TV(p, q)              = {t:.10f}")
    print(f"||p - q||_1             = {l1_distance(p, q):.10f}   (= 2 d_TV, strictly lossy)")
    print(f"max over all 2^N events = {best_value:.10f}   attained at A = {best_event}")
    print(f"likelihood-ratio event  = {tuple(star)}, gap = {event_gap(p, q, star):.10f}")
    print(f"shared mass sum min(p,q)= {shared_mass(p, q):.10f}   (= 1 - d_TV)")
    assert abs(best_value - t) < 1e-9
    assert abs(event_gap(p, q, star) - t) < 1e-9
    assert abs(shared_mass(p, q) - (1 - t)) < 1e-9
    print("OK: the supremum is attained and equals the sharp distance.")


def demo_randomized_tests(p: Vec, q: Vec, rng: random.Random) -> None:
    banner("2-3. Randomization does not help; the factor-two dichotomy")
    t = tv_distance(p, q)
    n = len(p)
    best_soft = -math.inf
    best_signed = -math.inf
    for _ in range(200_000):
        g = [rng.random() for _ in range(n)]
        best_soft = max(best_soft, sum((p[i] - q[i]) * g[i] for i in range(n)))
        h = [2 * rng.random() - 1 for _ in range(n)]
        best_signed = max(best_signed, sum((p[i] - q[i]) * h[i] for i in range(n)))
    sign_test = [math.copysign(1.0, p[i] - q[i]) for i in range(n)]
    print(f"best random [0,1]-test advantage  = {best_soft:.6f}   <= d_TV      = {t:.6f}")
    print(f"best random [-1,1]-test advantage = {best_signed:.6f}   <= 2 d_TV    = {2 * t:.6f}")
    print(f"sign pattern sgn(p - q) advantage = "
          f"{sum((p[i] - q[i]) * sign_test[i] for i in range(n)):.10f}   (= 2 d_TV exactly)")
    assert best_soft <= t + 1e-9
    assert best_signed <= 2 * t + 1e-9
    assert abs(sum((p[i] - q[i]) * sign_test[i] for i in range(n)) - 2 * t) < 1e-9
    print("OK: [0,1]-tests cap at d_TV; [-1,1]-tests cap at 2 d_TV, attained at the sign pattern.")


def demo_coupling(p: Vec, q: Vec, rng: random.Random) -> None:
    banner("4. Maximal coupling:  min over couplings of P[X != Y] = d_TV")
    t = tv_distance(p, q)
    c_star = maximal_coupling(p, q)
    c_ind = independent_coupling(p, q)
    print(f"maximal coupling is a valid coupling : {is_coupling(c_star, p, q)}")
    print(f"P_c*[X != Y]                         = {disagreement_probability(c_star):.10f}")
    print(f"d_TV(p, q)                           = {t:.10f}")
    print(f"independent coupling P[X != Y]       = {disagreement_probability(c_ind):.10f}")
    assert is_coupling(c_star, p, q)
    assert abs(disagreement_probability(c_star) - t) < 1e-9
    worst = math.inf
    for _ in range(2_000):
        c = random_coupling(p, q, rng)
        assert is_coupling(c, p, q)
        worst = min(worst, disagreement_probability(c))
    print(f"best of 2000 random couplings        = {worst:.10f}   >= d_TV")
    assert worst >= t - 1e-9
    print("OK: no coupling beats d_TV, and the explicit maximal coupling attains it.")


def demo_testing(p: Vec, q: Vec) -> None:
    banner("5. Two-point testing:  min error = (1 - d_TV)/2")
    t = tv_distance(p, q)
    best = brute_force_min_bayes_error(p, q)
    print(f"least error over all 2^N tests = {best:.10f}")
    print(f"(1 - d_TV)/2                   = {(1 - t) / 2:.10f}")
    print(f"lossy surrogate (1 - ||p-q||_1)/2 = {(1 - l1_distance(p, q)) / 2:+.10f}"
          f"{'   <-- VACUOUS (negative)' if 1 - l1_distance(p, q) < 0 else ''}")
    assert abs(best - (1 - t) / 2) < 1e-9
    print("OK: the sharp normalization gives the exact optimum; the lossy one can go negative.")


def demo_data_processing(p: Vec, q: Vec, rng: random.Random) -> None:
    banner("6. Data processing: channels never increase d_TV")
    t = tv_distance(p, q)
    worst_ratio = 0.0
    for _ in range(5_000):
        k = random_channel(len(p), 3, rng)
        after = tv_distance(push_forward(p, k), push_forward(q, k))
        assert after <= t + 1e-9
        worst_ratio = max(worst_ratio, after / t if t > 0 else 0.0)
    print(f"d_TV(p, q)                                  = {t:.10f}")
    print(f"largest d_TV after 5000 random channels     = {worst_ratio * t:.10f}")
    print(f"largest ratio d_TV(pK, qK) / d_TV(p, q)     = {worst_ratio:.10f}   (<= 1)")
    print("OK: post-processing can only destroy distinguishability, never create it.")


def demo_amplification(p: Vec, q: Vec, max_n: int = 6) -> None:
    banner("7. n-sample amplification: exact vs geometric vs hybrid bound")
    t = tv_distance(p, q)
    print(f"single-sample d_TV = {t:.6f}")
    print()
    print(f"{'n':>2} | {'exact d_TV(p^n,q^n)':>20} | {'1-(1-d)^n':>12} | {'n*d':>10} | slack")
    print("-" * 74)
    for n in range(1, max_n + 1):
        exact = tv_distance(product_law(p, n), product_law(q, n))
        geometric = 1 - (1 - t) ** n
        hybrid = n * t
        assert exact <= geometric + 1e-9
        assert geometric <= hybrid + 1e-9
        print(f"{n:>2} | {exact:>20.10f} | {geometric:>12.8f} | {hybrid:>10.6f} |"
              f" {geometric - exact:.8f}")
    print()
    print("The geometric bound never exceeds 1; the hybrid bound goes vacuous once n >= 1/d_TV.")
    print("Residual slack (last column) is the gap that an exactly multiplicative")
    print("quantity such as the Hellinger affinity would be needed to close.")


def demo_pinsker(rng: random.Random, trials: int = 20_000) -> None:
    banner("8. Pinsker bridge: d_TV <= sqrt(KL/2), and KL >= 2 * gap^2")
    worst_slack = math.inf
    worst_pair = None
    for _ in range(trials):
        n = rng.choice([2, 3, 4])
        qq = random_law(n, rng)
        pp = random_law(n, rng)
        kl = kl_divergence(qq, pp)
        t = tv_distance(qq, pp)
        bound = math.sqrt(kl / 2)
        assert t <= bound + 1e-9
        for event in all_events(n):
            gap = event_gap(qq, pp, event)
            assert 2 * gap * gap <= kl + 1e-9
        if bound - t < worst_slack:
            worst_slack, worst_pair = bound - t, (qq, pp, t, kl)
    assert worst_pair is not None
    qq, pp, t, kl = worst_pair
    print(f"tightest instance found in {trials} random trials:")
    print(f"  Q            = {[round(v, 4) for v in qq]}")
    print(f"  P            = {[round(v, 4) for v in pp]}")
    print(f"  d_TV(Q, P)   = {t:.10f}")
    print(f"  sqrt(KL/2)   = {math.sqrt(kl / 2):.10f}")
    print(f"  KL(Q || P)   = {kl:.10f}   >=  2*d_TV^2 = {2 * t * t:.10f}")
    print()
    print("Where the normalization decides non-vacuity:")
    print(f"{'KL':>6} | {'sharp (1-sqrt(KL/2))/2':>24} | {'lossy (1-sqrt(2KL))/2':>24}")
    print("-" * 62)
    for kl_val in (0.05, 0.125, 0.25, 0.5, 1.0, 2.0):
        sharp = (1 - math.sqrt(kl_val / 2)) / 2
        lossy = (1 - math.sqrt(2 * kl_val)) / 2
        flag = "  <-- lossy vacuous" if lossy <= 0 < sharp else ""
        print(f"{kl_val:>6.3f} | {sharp:>24.6f} | {lossy:>24.6f}{flag}")
    print("OK: every event obeys the Pinsker bound and certifies a KL lower bound.")


def demo_multihypothesis(rng: random.Random) -> None:
    banner("9. Shtarkov sum = multi-hypothesis optimum:  min error = 1 - C_S / m")
    for m, n in ((2, 4), (3, 3), (4, 3)):
        sources = [random_law(n, rng) for _ in range(m)]
        cs = shtarkov_sum(sources)
        predicted = 1 - cs / m
        actual = brute_force_min_m_ary_error(sources)
        ml_rule = [max(range(m), key=lambda th: sources[th][x]) for x in range(n)]
        ml_error = m_ary_error(sources, ml_rule)
        print(f"m = {m}, |X| = {n}:  C_S = {cs:.8f},  1 - C_S/m = {predicted:.10f},"
              f"  brute force = {actual:.10f},  ML rule = {ml_error:.10f}")
        assert abs(predicted - actual) < 1e-9
        assert abs(ml_error - actual) < 1e-9
    print()
    print("Binary consistency check (C_S = 1 + d_TV, so 1 - C_S/2 = (1 - d_TV)/2):")
    for _ in range(3):
        p, q = random_law(4, rng), random_law(4, rng)
        cs = shtarkov_sum([p, q])
        t = tv_distance(p, q)
        print(f"  d_TV = {t:.8f},  C_S = {cs:.8f},  1 + d_TV = {1 + t:.8f},"
              f"  1 - C_S/2 = {1 - cs / 2:.8f},  (1 - d_TV)/2 = {(1 - t) / 2:.8f}")
        assert abs(cs - (1 + t)) < 1e-9
        assert abs((1 - cs / 2) - (1 - t) / 2) < 1e-9
    print("OK: the universal-coding price and the testing optimum are the same number.")


def main() -> None:
    rng = random.Random(20260824)

    # A running example on a five-letter alphabet.
    p = [0.35, 0.25, 0.20, 0.15, 0.05]
    q = [0.10, 0.30, 0.10, 0.25, 0.25]

    demo_event_supremum(p, q)
    demo_randomized_tests(p, q, rng)
    demo_coupling(p, q, rng)
    demo_testing(p, q)
    demo_data_processing(p, q, rng)
    demo_amplification([0.7, 0.3], [0.4, 0.6], max_n=8)
    demo_pinsker(rng, trials=4_000)
    demo_multihypothesis(rng)

    banner("A near-singular pair, where the lossy normalization fails outright")
    p2 = [0.98, 0.01, 0.01]
    q2 = [0.01, 0.98, 0.01]
    t2 = tv_distance(p2, q2)
    print(f"p = {p2},  q = {q2}")
    print(f"d_TV        = {t2:.6f}         -> optimal test error (1 - d_TV)/2 = {(1 - t2) / 2:.6f}")
    print(f"||p - q||_1 = {l1_distance(p2, q2):.6f}   -> lossy surrogate "
          f"(1 - ||p-q||_1)/2 = {(1 - l1_distance(p2, q2)) / 2:+.6f}  (meaningless)")
    print(f"maximal coupling agrees with probability {1 - t2:.6f} = 1 - d_TV")
    print()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
