"""
A tail-exponent measurement protocol for the attention budget
=============================================================

Numerical demonstration of every result in the accompanying paper.

Setting
-------
A positive attention profile w_0, w_1, ... on a context of length n.

    S(n) = sum_{i<n} w_i                    head mass
    p_i  = w_i / S(n)                       normalised profile
    M(k) = sum_{i<min(k,n)} p_i             retained mass of a top-k truncation
    T(k) = 1 - M(k)                         discarded (tail) mass
    k*(n,g) = min { k : M(k) >= g }         the knee / attention budget
    E(n) = sum_{i<n} p_i^2                  l2-energy (collision probability)
    H_2  = -log E                           collision (Renyi-2) entropy
    H_1  = -sum p_i log p_i                 Shannon entropy

Results demonstrated
--------------------
1.  Budget sandwich            g^2 / E <= k*(n,g) <= n
2.  Hartley floor refuted      spike profile: k* = 1 but g^2 n = 17/4
3.  Shannon floor refuted      spike profile: H_1 = 3 log 2, g^2 e^{H_1} = 2 > 1 = k*
4.  Entropy chain              H_2 <= H_1
5.  Resolution limit           (g^2/E)/n <= g^2, from n E >= 1
6.  Divergence rate            k* >= g^2 S(n) / w_0        (sorted profiles)
7.  Critical Zipf law          k* >= g^2 log(n+1)
8.  Exact geometric energy     E = (1-r)(1+r^n)/((1+r)(1-r^n))
9.  Geometric floor and pin    g^2/(3(1-r)) <= k* <= GeoBudget(r,g)
10. Mixture law                E(w1+w2) <= max(E(w1), E(w2)); floors obey a min law
11. Tail fit / reported budget k*(n,tau) <= Budget(C,r,tau), monotone in the fit box
12. Two-point estimator        exact on a geometric tail; d-th-root error damping
13. Sharpness                  exact tail => Budget = k*  (slack at most one key)

Run:  python3 demo.py        (standard library only)
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------


def head_mass(w: Sequence[float], n: int) -> float:
    """S(n) = sum of the first n weights."""
    return float(sum(w[:n]))


def normalised(w: Sequence[float], n: int) -> List[float]:
    """The probability profile p_i = w_i / S(n) on the first n positions."""
    s = head_mass(w, n)
    return [wi / s for wi in w[:n]]


def retained(w: Sequence[float], n: int, k: int) -> float:
    """M(k): the fraction of attention mass kept by a top-k truncation."""
    return head_mass(w, min(k, n)) / head_mass(w, n)


def tail_mass(w: Sequence[float], n: int, k: int) -> float:
    """T(k) = 1 - M(k): the discarded mass."""
    return 1.0 - retained(w, n, k)


def kstar(w: Sequence[float], n: int, g: float) -> int:
    """The knee: least k with M(k) >= g.  Always exists and is at most n."""
    for k in range(n + 1):
        if retained(w, n, k) >= g - 1e-15:
            return k
    return n


def energy(w: Sequence[float], n: int) -> float:
    """E(n) = sum_i p_i^2, the collision probability of the normalised profile."""
    return float(sum(p * p for p in normalised(w, n)))


def collision_entropy(w: Sequence[float], n: int) -> float:
    """H_2 = -log E."""
    return -math.log(energy(w, n))


def shannon_entropy(w: Sequence[float], n: int) -> float:
    """H_1 = -sum p_i log p_i."""
    return -float(sum(p * math.log(p) for p in normalised(w, n) if p > 0.0))


def energy_floor(w: Sequence[float], n: int, g: float) -> float:
    """The lower certificate g^2 / E."""
    return g * g / energy(w, n)


# ----------------------------------------------------------------------------
# The fitted tail law and the reported budget
# ----------------------------------------------------------------------------


def budget_of_fit(C: float, r: float, tau: float) -> int:
    """Budget(C, r, tau) = max(ceil(log((1-tau)/C) / log r), 1)."""
    return max(math.ceil(math.log((1.0 - tau) / C) / math.log(r)), 1)


def geometric_budget(r: float, g: float) -> int:
    """The closed-form budget of a geometrically decaying profile: fit C = 1/(1-r)."""
    return budget_of_fit(1.0 / (1.0 - r), r, g)


def fit_ratio(t1: float, t2: float, d: int) -> float:
    """Two-point estimator of the tail ratio: r_hat = (t2/t1)^(1/d)."""
    return (t2 / t1) ** (1.0 / d)


def fit_const(t1: float, r: float, k1: int) -> float:
    """Two-point estimator of the amplitude: C_hat = t1 / r^{k1}."""
    return t1 / r ** k1


# ----------------------------------------------------------------------------
# Standard profiles
# ----------------------------------------------------------------------------


def zipf_profile(s: float, n: int) -> List[float]:
    """Zipf profile w_i = (i+1)^{-s}; s = 1 is the critical exponent."""
    return [(i + 1.0) ** (-s) for i in range(n)]


def geometric_profile(r: float, n: int) -> List[float]:
    """Geometric profile w_i = r^i."""
    return [r ** i for i in range(n)]


def spike_profile() -> List[float]:
    """The 17-key spike: one key of weight 16, sixteen keys of weight 1."""
    return [16.0] + [1.0] * 16


def flat_profile(n: int) -> List[float]:
    """The uniform profile w_i = 1."""
    return [1.0] * n


def merge(w1: Sequence[float], w2: Sequence[float]) -> List[float]:
    """Position-wise merging of two heads."""
    return [a + b for a, b in zip(w1, w2)]


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# 1. The budget sandwich
# ----------------------------------------------------------------------------


def demo_sandwich() -> None:
    banner("1. The budget sandwich   g^2 / E  <=  k*(n,g)  <=  n")
    g = 0.98
    print(f"gate g = {g}")
    print()
    print(f"{'profile':<22}{'n':>5}{'E':>12}{'floor':>12}{'k*':>8}{'n':>8}  ok")
    cases: List[Tuple[str, List[float]]] = [
        ("flat", flat_profile(512)),
        ("geometric r=0.90", geometric_profile(0.90, 512)),
        ("geometric r=0.99", geometric_profile(0.99, 512)),
        ("Zipf s=1.0 (critical)", zipf_profile(1.0, 512)),
        ("Zipf s=1.5", zipf_profile(1.5, 512)),
        ("Zipf s=0.7", zipf_profile(0.7, 512)),
        ("spike (17 keys)", spike_profile()),
    ]
    for name, w in cases:
        n = len(w)
        E = energy(w, n)
        floor = energy_floor(w, n, g)
        ks = kstar(w, n, g)
        ok = (floor <= ks + 1e-9) and (ks <= n)
        print(f"{name:<22}{n:>5}{E:>12.6f}{floor:>12.3f}{ks:>8}{n:>8}  {ok}")
    print()
    print("The floor is valid in every row; the ceiling n is the trivial one.")


# ----------------------------------------------------------------------------
# 2-4. Entropy cannot certify a budget
# ----------------------------------------------------------------------------


def demo_entropy_refutations() -> None:
    banner("2-4. Entropy alone cannot certify a budget (the 17-key spike)")
    w = spike_profile()
    n, g = 17, 0.5
    E = energy(w, n)
    H2 = collision_entropy(w, n)
    H1 = shannon_entropy(w, n)
    ks = kstar(w, n, g)

    print(f"profile           w = (16, 1, 1, ..., 1) on n = {n} keys, gate g = {g}")
    print(f"head mass         S = {head_mass(w, n):.0f}   (so p_0 = 1/2, p_i = 1/32)")
    print(f"true knee         k* = {ks}          (one key already carries half the mass)")
    print()
    print(f"energy            E   = {E:.6f}   (exactly 17/64 = {17/64:.6f})")
    print(f"collision entropy H_2 = {H2:.6f}   (= log(64/17) = {math.log(64/17):.6f})")
    print(f"Shannon entropy   H_1 = {H1:.6f}   (= 3 log 2   = {3*math.log(2):.6f})")
    print(f"entropy chain     H_2 <= H_1 ?  {H2 <= H1}")
    print()
    collision_floor = g * g / E
    shannon_floor = g * g * math.exp(H1)
    hartley_floor = g * g * n
    print(f"collision floor   g^2 e^H_2 = g^2/E = {collision_floor:.6f}  <= k* ?  "
          f"{collision_floor <= ks}   <-- VALID")
    print(f"Shannon  floor    g^2 e^H_1        = {shannon_floor:.6f}  <= k* ?  "
          f"{shannon_floor <= ks}  <-- REFUTED")
    print(f"Hartley  floor    g^2 n            = {hartley_floor:.6f}  <= k* ?  "
          f"{hartley_floor <= ks}  <-- REFUTED")
    print()
    print("Entropy measures how spread the WHOLE distribution is; the budget only")
    print("cares how much mass sits on the HEAD.  Only the l2-energy sees the head.")


# ----------------------------------------------------------------------------
# 5. The resolution limit
# ----------------------------------------------------------------------------


def demo_resolution() -> None:
    banner("5. Intrinsic resolution:   n E >= 1,   hence (g^2/E)/n <= g^2")
    print(f"{'profile':<22}{'n':>5}{'n E':>12}{'(g^2/E)/n':>14}{'g^2':>10}  ok")
    for g in (0.5, 0.9, 0.98):
        print(f"-- gate g = {g}")
        for name, w in (
            ("flat", flat_profile(256)),
            ("geometric r=0.95", geometric_profile(0.95, 256)),
            ("Zipf s=1.0", zipf_profile(1.0, 256)),
        ):
            n = len(w)
            E = energy(w, n)
            ratio = (g * g / E) / n
            print(f"{name:<22}{n:>5}{n*E:>12.4f}{ratio:>14.6f}{g*g:>10.4f}  "
                  f"{ratio <= g*g + 1e-12 and n*E >= 1 - 1e-12}")
    print()
    print("At g = 0.98 the two ends of the sandwich differ by at most a factor 1.04.")


# ----------------------------------------------------------------------------
# 6-7. The divergence rate and the critical Zipf law
# ----------------------------------------------------------------------------


def demo_divergence_rate() -> None:
    banner("6-7. Divergence rate  k* >= g^2 S(n)/w_0,  and  k* >= g^2 log(n+1) at s=1")
    g = 0.9
    print(f"gate g = {g};  Zipf profile w_i = 1/(i+1)  (critical exponent s = 1)")
    print()
    print(f"{'n':>8}{'S(n)=H_n':>12}{'g^2 S/w_0':>12}{'g^2 log(n+1)':>15}{'k*':>8}  ok")
    for n in (16, 64, 256, 1024, 4096):
        w = zipf_profile(1.0, n)
        S = head_mass(w, n)
        rate = g * g * S / w[0]
        loglaw = g * g * math.log(n + 1)
        ks = kstar(w, n, g)
        ok = loglaw <= rate + 1e-9 <= ks + 1e-9
        print(f"{n:>8}{S:>12.4f}{rate:>12.4f}{loglaw:>15.4f}{ks:>8}  {ok}")
    print()
    print("Both lower bounds hold, and the budget grows without bound: at the critical")
    print("exponent no fixed budget survives, and the growth is logarithmic in order.")
    print()
    print("Contrast, a summable profile (s = 1.5) whose budget stabilises:")
    print(f"{'n':>8}{'S(n)':>12}{'g^2 S/w_0':>12}{'k*':>8}")
    for n in (16, 64, 256, 1024, 4096):
        w = zipf_profile(1.5, n)
        S = head_mass(w, n)
        print(f"{n:>8}{S:>12.4f}{g*g*S/w[0]:>12.4f}{kstar(w, n, g):>8}")


# ----------------------------------------------------------------------------
# 8-9. The geometric profile: exact energy, floor, and two-sided pin
# ----------------------------------------------------------------------------


def demo_geometric() -> None:
    banner("8-9. Geometric profile: exact energy, floor g^2/(3(1-r)), and the pin")
    g = 0.9
    n = 4000
    print(f"gate g = {g}, context n = {n}")
    print()
    print(f"{'r':>7}{'E (measured)':>15}{'E (formula)':>15}{'limit':>10}"
          f"{'floor':>10}{'k*':>7}{'GeoBudget':>11}  pin")
    for r in (0.5, 0.8, 0.9, 0.95, 0.99, 0.999):
        w = geometric_profile(r, n)
        E_meas = energy(w, n)
        rn = r ** n
        E_form = (1 - r) * (1 + rn) / ((1 + r) * (1 - rn))
        lim = (1 - r) / (1 + r)
        floor = g * g / (3 * (1 - r))
        ks = kstar(w, n, g)
        gb = geometric_budget(r, g)
        decayed = rn <= 0.5
        pin = (floor <= ks <= gb) if decayed else "n/a (r^n > 1/2)"
        print(f"{r:>7}{E_meas:>15.8f}{E_form:>15.8f}{lim:>10.6f}"
              f"{floor:>10.2f}{ks:>7}{gb:>11}  {pin}")
    print()
    print("The measured energy matches the closed form to machine precision, and the")
    print("knee is trapped between c/(1-r) and the fit-based budget: the geometric knee")
    print("is Theta(1/(1-r)), pinned from both sides up to a logarithmic factor.")


# ----------------------------------------------------------------------------
# 10. The mixture law
# ----------------------------------------------------------------------------


def demo_mixture() -> None:
    banner("10. Mixture law:  E(w1+w2) <= max(E(w1),E(w2));  floors obey a min law")
    g, n = 0.95, 256
    pairs: List[Tuple[str, List[float], str, List[float]]] = [
        ("geometric r=0.7", geometric_profile(0.7, n),
         "Zipf s=1.0", zipf_profile(1.0, n)),
        ("geometric r=0.5", geometric_profile(0.5, n),
         "flat", flat_profile(n)),
        ("Zipf s=2.0", zipf_profile(2.0, n),
         "Zipf s=0.6", zipf_profile(0.6, n)),
    ]
    for n1, w1, n2, w2 in pairs:
        wm = merge(w1, w2)
        E1, E2, Em = energy(w1, n), energy(w2, n), energy(wm, n)
        f1, f2, fm = (g * g / E1, g * g / E2, g * g / Em)
        print(f"{n1} + {n2}")
        print(f"   E1 = {E1:.6f}   E2 = {E2:.6f}   E(merged) = {Em:.6f}"
              f"   <= max ?  {Em <= max(E1, E2) + 1e-12}")
        print(f"   floors: {f1:.3f}, {f2:.3f}  ->  merged floor {fm:.3f}"
              f"   >= min ?  {fm >= min(f1, f2) - 1e-9}")
        print(f"   knees:  {kstar(w1, n, g)}, {kstar(w2, n, g)}"
              f"  ->  merged knee {kstar(wm, n, g)}")
    print()
    print("The worst head governs both ends of the sandwich: a diffuse head cannot be")
    print("economised away by merging it into a sharp one.")


# ----------------------------------------------------------------------------
# 11. The fitted tail law and the reported budget
# ----------------------------------------------------------------------------


def demo_tail_fit() -> None:
    banner("11. The upper certificate:  k*(n,tau) <= Budget(C,r,tau), monotone in the box")
    tau, n = 0.98, 2000
    print(f"reporting gate tau = {tau}, context n = {n}")
    print()
    print(f"{'r':>7}{'C=1/(1-r)':>12}{'k*':>7}{'Budget':>9}{'valid':>8}"
          f"{'Budget(1.2C,r+)':>18}{'monotone':>10}")
    for r in (0.6, 0.8, 0.9, 0.95, 0.99):
        w = geometric_profile(r, n)
        C = 1.0 / (1.0 - r)
        b = budget_of_fit(C, r, tau)
        ks = kstar(w, n, tau)
        rp = min(r + 0.005, 0.999)
        bplus = budget_of_fit(1.2 * C, rp, tau)
        print(f"{r:>7}{C:>12.3f}{ks:>7}{b:>9}{str(ks <= b):>8}"
              f"{bplus:>18}{str(b <= bplus):>10}")
    print()
    print("Every reported budget upper-bounds the true knee, and inflating the fit box")
    print("only inflates the report: quoting the upper corner certifies the whole box.")

    print()
    print("Falsification test (a fit is refuted if its budget falls below the floor):")
    g = 0.95
    w = geometric_profile(0.95, n)
    floor = energy_floor(w, n, g)
    honest = budget_of_fit(1.0 / 0.05, 0.95, g)
    dishonest = budget_of_fit(0.05, 0.30, g)  # a wildly over-optimistic fit
    print(f"   measured energy floor      = {floor:.3f}")
    print(f"   honest fit (C=20, r=0.95)  -> budget {honest:>4}   "
          f"{'consistent' if honest >= floor else 'REFUTED'}")
    print(f"   optimistic fit (C=.05,r=.3)-> budget {dishonest:>4}   "
          f"{'consistent' if dishonest >= floor else 'REFUTED'}")


# ----------------------------------------------------------------------------
# 12. The two-point estimator: exactness and error damping
# ----------------------------------------------------------------------------


def demo_two_point() -> None:
    banner("12. Two-point estimator: exact on a geometric tail, error damped by d-th root")
    C_true, r_true, k1 = 3.0, 0.85, 5
    print(f"true tail law T(k) = {C_true} * {r_true}^k, first probe at k1 = {k1}")
    print()
    print(f"{'d':>5}{'r_hat':>12}{'C_hat':>12}{'Budget(hat)':>13}{'Budget(true)':>14}  exact")
    for d in (1, 4, 16, 64):
        t1 = C_true * r_true ** k1
        t2 = C_true * r_true ** (k1 + d)
        rh = fit_ratio(t1, t2, d)
        ch = fit_const(t1, rh, k1)
        bh = budget_of_fit(ch, rh, 0.99)
        bt = budget_of_fit(C_true, r_true, 0.99)
        print(f"{d:>5}{rh:>12.9f}{ch:>12.9f}{bh:>13}{bt:>14}  {bh == bt}")
    print()
    print("No bias is introduced by the pipeline: all uncertainty comes from the data.")
    print()
    print("Now with multiplicative data error eps: the fitted ratio is off by at most")
    print("((1+eps)/(1-eps))^(1/d).")
    print()
    print(f"{'eps':>7}{'d':>5}{'bound':>12}{'worst r_hat/r':>16}{'ok':>6}")
    for eps in (0.05, 0.2, 0.5):
        for d in (1, 4, 16, 64):
            t1 = C_true * r_true ** k1
            t2 = C_true * r_true ** (k1 + d)
            s1 = (1 - eps) * t1          # worst case: t1 under-measured
            s2 = (1 + eps) * t2          # worst case: t2 over-measured
            bound = ((1 + eps) / (1 - eps)) ** (1.0 / d)
            observed = fit_ratio(s1, s2, d) / fit_ratio(t1, t2, d)
            print(f"{eps:>7}{d:>5}{bound:>12.6f}{observed:>16.6f}"
                  f"{str(observed <= bound + 1e-12):>6}")
    print()
    print("The precision of the fit is set by the experiment design (the probe")
    print("separation d), not by the noise level.")


# ----------------------------------------------------------------------------
# 13. Sharpness of the report; energy-error propagation
# ----------------------------------------------------------------------------


def demo_sharpness_and_error() -> None:
    banner("13. Sharpness: on an exact geometric tail the report EQUALS the knee")

    def profile_with_exact_tail(C: float, r: float, n: int) -> List[float]:
        """Weights whose truncation tails are exactly T(k) = C r^k for 1 <= k < n."""
        # M(k) = 1 - C r^k, so p_k = M(k+1) - M(k) = C r^k (1 - r) for k >= 1,
        # and p_0 = M(1) = 1 - C r.
        p = [1.0 - C * r] + [C * (r ** k) * (1 - r) for k in range(1, n - 1)]
        p.append(max(1.0 - sum(p), 1e-18))
        return p

    tau = 0.995
    print(f"reporting gate tau = {tau}")
    print()
    print(f"{'C':>6}{'r':>7}{'n':>7}{'k*':>7}{'Budget':>9}{'slack':>8}")
    for C, r in ((0.5, 0.8), (0.9, 0.9), (0.3, 0.95), (0.8, 0.7)):
        n = 400
        w = profile_with_exact_tail(C, r, n)
        b = budget_of_fit(C, r, tau)
        ks = kstar(w, n, tau)
        print(f"{C:>6}{r:>7}{n:>7}{ks:>7}{b:>9}{b - ks:>8}")
    print()
    print("The slack is 0 or 1 key: exactly the ceiling rounding, and no more.")

    banner("13b. Energy-error propagation:  E <= E_hat <= (1+eta) E  costs 1/(1+eta)")
    g, n = 0.98, 512
    w = zipf_profile(1.0, n)
    E = energy(w, n)
    ks = kstar(w, n, g)
    print(f"critical Zipf, n = {n}, gate g = {g}, true E = {E:.6f}, k* = {ks}")
    print()
    print(f"{'eta':>7}{'E_hat':>12}{'floor(E_hat)':>15}{'(1/(1+eta))*floor(E)':>23}"
          f"{'<= k* ?':>10}")
    for eta in (0.0, 0.05, 0.2, 1.0):
        Eh = (1 + eta) * E
        fh = g * g / Eh
        pred = (1.0 / (1 + eta)) * (g * g / E)
        print(f"{eta:>7}{Eh:>12.6f}{fh:>15.4f}{pred:>23.4f}"
              f"{str(fh <= ks):>10}")
    print()
    print("Only an OVER-estimate of the energy is ever needed, and the degradation is")
    print("exactly linear: no amplification of measurement error.")


# ----------------------------------------------------------------------------
# End-to-end protocol
# ----------------------------------------------------------------------------


def fit_is_admissible(w: Sequence[float], n: int, C: float, r: float) -> bool:
    """Check the fitted law T(k) <= C r^k on every truncation below the context."""
    return all(tail_mass(w, n, k) <= C * r ** k + 1e-12 for k in range(n))


def run_protocol(
    w: Sequence[float],
    n: int,
    g: float,
    tau: float,
    k1: int,
    d: int,
    eta: float = 0.05,
    eps: float = 0.10,
) -> Tuple[float, int, bool]:
    """The full pipeline: conservative energy floor + inflated fit-based ceiling.

    Returns (floor, ceiling, admissible), where `admissible` records whether the
    inflated geometric fit really does dominate the measured tail curve.  The
    upper certificate is only claimed when it does.
    """
    E_hat = (1.0 + eta) * energy(w, n)
    floor = g * g / E_hat
    t1, t2 = tail_mass(w, n, k1), tail_mass(w, n, k1 + d)
    r_hat = fit_ratio(t1, t2, d)
    r_plus = min(r_hat * ((1 + eps) / (1 - eps)) ** (1.0 / d), 0.9999)
    C_plus = fit_const(t1, r_plus, k1) * (1 + eps)
    ceil_ = min(budget_of_fit(C_plus, r_plus, tau), n)
    return floor, ceil_, fit_is_admissible(w, n, C_plus, r_plus)


def demo_protocol() -> None:
    banner("End-to-end protocol:   [g^2/E_hat,  Budget(C+, r+, tau)]")
    g, tau, n = 0.95, 0.95, 1024
    print(f"gates g = tau = {g}; context n = {n}; energy error eta = 5%; "
          f"tail-probe error eps = 10%")
    print()
    print(f"{'profile':<22}{'floor':>10}{'k*':>7}{'ceiling':>10}{'fit ok':>9}"
          f"   {'reported':<28}")
    for name, w in (
        ("geometric r=0.90", geometric_profile(0.90, n)),
        ("geometric r=0.98", geometric_profile(0.98, n)),
        ("Zipf s=1.5", zipf_profile(1.5, n)),
        ("Zipf s=1.0", zipf_profile(1.0, n)),
    ):
        floor, ceil_, admissible = run_protocol(w, n, g, tau, k1=8, d=32)
        ks = kstar(w, n, g)
        if admissible:
            assert floor <= ks <= ceil_, "certificate violated"
            report = f"[{floor:.1f}, {ceil_}]"
        else:
            report = f"[{floor:.1f}, {n}]  (fit rejected)"
        print(f"{name:<22}{floor:>10.2f}{ks:>7}{ceil_:>10}{str(admissible):>9}"
              f"   {report:<28}")
    print()
    print("Each accepted row is a certified interval containing the true knee, computed")
    print("from a single linear pass plus two tail probes.  A geometric law does not")
    print("dominate a heavy (Zipf) tail, so the fit is rejected and only the energy")
    print("floor and the trivial ceiling n are reported: the certificate never lies.")


def main() -> None:
    print(__doc__)
    demo_sandwich()
    demo_entropy_refutations()
    demo_resolution()
    demo_divergence_rate()
    demo_geometric()
    demo_mixture()
    demo_tail_fit()
    demo_two_point()
    demo_sharpness_and_error()
    demo_protocol()
    print()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
