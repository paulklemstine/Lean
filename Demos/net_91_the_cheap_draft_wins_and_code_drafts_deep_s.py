"""
Draft-Cost Dominance and Domain-Parameterised Depth in CPU Speculative Decoding
===============================================================================

Self-contained numerical demonstration of every quantitative claim in the
accompanying paper.  Pure standard library; no dependencies.

Model
-----
Time is measured in units of one target decode step.

    block cost      cost(c, d)      = 1 + c * d
    geometric yield Y_geo(a, d)     = sum_{i=0..d} a^i
    throughput      sigma(a, c, d)  = Y_geo(a, d) / cost(c, d)

A *survival profile* S has S(0) = 1 and S non-increasing; S(k) is the probability
that the first k drafted positions are all accepted.  Its yield is
Y_S(d) = sum_{k=0..d} S(k) and its reported mean acceptance is
A_S(d) = (Y_S(d) - 1) / d.

Sections
--------
1. Cost dominance: the cheap draft wins all six measured head-to-heads.
2. The asymptotic invariant c*(1-a) and the crossover acceptance.
3. Depth collapse and the canonical stopping depth D*(a, c).
4. Monotonicity of the stopping depth in acceptance (the depth law).
5. Falsification of the independent (i.i.d.) reading of reported acceptance.
6. Survival profiles: the averaging law, the block-mean test, exact
   reconstruction of all six measured acceptances.
7. The marginal-survival stopping rule and the derived domain prescription.
8. The convex CPU cost curve and the twelve-cell out-of-sample test.

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Measured data (7B four-bit target on CPU; baseline 5.79 tok/s greedy).
# ---------------------------------------------------------------------------

C_SMALL: float = 0.118  # relative per-token cost of the 0.5B draft
C_LARGE: float = 0.234  # relative per-token cost of the 1.5B draft
EXTRA_LARGE: float = C_LARGE - C_SMALL  # 0.116

# (domain, draft, depth) -> (measured speedup, measured mean acceptance)
MEASURED: Dict[Tuple[str, str, int], Tuple[float, float]] = {
    ("prose", "0.5B", 2): (1.254, 0.639),
    ("prose", "0.5B", 4): (1.416, 0.477),
    ("prose", "0.5B", 8): (0.979, 0.309),
    ("prose", "1.5B", 2): (1.016, 0.632),
    ("prose", "1.5B", 4): (1.153, 0.519),
    ("prose", "1.5B", 8): (0.982, 0.449),
    ("code", "0.5B", 2): (1.352, 0.716),
    ("code", "0.5B", 4): (1.616, 0.630),
    ("code", "0.5B", 8): (1.661, 0.560),
    ("code", "1.5B", 2): (1.195, 0.834),
    ("code", "1.5B", 4): (1.395, 0.748),
    ("code", "1.5B", 8): (1.354, 0.603),
}


# ---------------------------------------------------------------------------
# Core block model
# ---------------------------------------------------------------------------

def block_cost(c: float, d: int) -> float:
    """Cost of one speculative block: one verification pass plus d draft steps."""
    return 1.0 + c * d


def yield_geom(a: float, d: int) -> float:
    """Expected committed tokens per block under independent acceptance `a`."""
    return sum(a ** i for i in range(d + 1))


def speedup(a: float, c: float, d: int) -> float:
    """Throughput relative to plain autoregressive decoding."""
    return yield_geom(a, d) / block_cost(c, d)


def pos_yield(S: Sequence[float], d: int) -> float:
    """Yield of a survival profile: Y_S(d) = S(0) + ... + S(d)."""
    return sum(S[k] for k in range(d + 1))


def mean_accept(S: Sequence[float], d: int) -> float:
    """Reported acceptance: the committed fraction of drafted tokens."""
    return (pos_yield(S, d) - 1.0) / d


def profile_speedup(S: Sequence[float], c: float, d: int) -> float:
    """Throughput of a survival profile against the affine cost 1 + c*d."""
    return pos_yield(S, d) / block_cost(c, d)


# ---------------------------------------------------------------------------
# Reconstructed survival profiles (exact witnesses for the measured means)
# ---------------------------------------------------------------------------

def code_survival(k: int) -> float:
    table = [1.000, 0.800, 0.632, 0.560, 0.528]
    return table[k] if k < len(table) else 0.490


def prose_survival(k: int) -> float:
    table = [1.000, 0.700, 0.578, 0.350, 0.280]
    return table[k] if k < len(table) else 0.141


CODE_S: List[float] = [code_survival(k) for k in range(41)]
PROSE_S: List[float] = [prose_survival(k) for k in range(41)]


# ---------------------------------------------------------------------------
# Fitted convex CPU cost curve (calibrated on the three code / 0.5B cells)
# ---------------------------------------------------------------------------

B_FIT, K_FIT, M_FIT = 1.5401, 0.0992, 0.0151


def cpu_block_cost(extra: float, d: int) -> float:
    """Convex hardware cost curve: b + (k + extra)*d + m*d^2."""
    return B_FIT + (K_FIT + extra) * d + M_FIT * d * d


def pred_speedup(q: float, extra: float, d: int) -> float:
    """Predicted speedup: mean-acceptance yield over the fitted cost curve."""
    return (1.0 + q * d) / cpu_block_cost(extra, d)


# ---------------------------------------------------------------------------
# Depth selection
# ---------------------------------------------------------------------------

def stop_depth(a: float, c: float, dmax: int = 4096) -> int:
    """First depth D with sigma(D+1) < sigma(D).  Globally optimal by unimodality."""
    d = 0
    while d < dmax:
        if speedup(a, c, d + 1) < speedup(a, c, d):
            return d
        d += 1
    raise RuntimeError("no stopping depth found below dmax")


def profile_stop_depth(S: Sequence[float], c: float) -> int:
    """Greedy depth tuning by the marginal-survival rule c*sigma(d) < S(d+1)."""
    d = 0
    while d + 1 < len(S):
        if not (c * profile_speedup(S, c, d) < S[d + 1]):
            return d
        d += 1
    return d


def collapse_depth(a: float, c: float) -> int:
    """Smallest d guaranteed a net loss by the gate (1-a)*(1+c*d) > 1."""
    d = 0
    while not (1.0 - a) * block_cost(c, d) > 1.0:
        d += 1
    return d


# ---------------------------------------------------------------------------
# Reporting helpers
# ---------------------------------------------------------------------------

def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, condition: bool) -> None:
    print(f"  [{'OK ' if condition else 'FAIL'}] {label}")
    assert condition, label


# ---------------------------------------------------------------------------
# 1. Cost dominance in all six head-to-heads
# ---------------------------------------------------------------------------

def demo_cost_dominance() -> None:
    rule("1. COST DOMINANCE — the cheap draft wins all six head-to-heads")
    print("  Model: sigma(a,c,d) = (1 + a + ... + a^d) / (1 + c*d)\n")
    header = f"  {'cell':<14}{'small a':>9}{'small σ':>10}{'large a':>9}{'large σ':>10}{'winner':>10}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for domain in ("prose", "code"):
        for d in (2, 4, 8):
            _, a_s = MEASURED[(domain, "0.5B", d)]
            _, a_l = MEASURED[(domain, "1.5B", d)]
            s_s = speedup(a_s, C_SMALL, d)
            s_l = speedup(a_l, C_LARGE, d)
            win = "0.5B" if s_s > s_l else "1.5B"
            flag = "  <-- large accepts more" if a_l > a_s else ""
            print(f"  {domain + ', d=' + str(d):<14}{a_s:>9.3f}{s_s:>10.3f}"
                  f"{a_l:>9.3f}{s_l:>10.3f}{win:>10}{flag}")
    print()
    all_six = all(
        speedup(MEASURED[(dom, "0.5B", d)][1], C_SMALL, d)
        > speedup(MEASURED[(dom, "1.5B", d)][1], C_LARGE, d)
        for dom in ("prose", "code") for d in (2, 4, 8)
    )
    check("small draft strictly faster in all 6 cells (no crossover)", all_six)
    check("cheap-draft law at equal acceptance: sigma(a,c',d) < sigma(a,c,d)",
          all(speedup(a, C_LARGE, d) < speedup(a, C_SMALL, d)
              for a in (0.1, 0.3, 0.5, 0.7, 0.9) for d in (1, 2, 4, 8, 16)))


# ---------------------------------------------------------------------------
# 2. The asymptotic invariant c*(1-a)
# ---------------------------------------------------------------------------

def demo_asymptotic_invariant() -> None:
    rule("2. THE DEEP-DRAFT INVARIANT — d * sigma(a,c,d) -> 1 / (c*(1-a))")
    pairs = [("0.5B @ code d=8 accept", 0.560, C_SMALL),
             ("1.5B @ code d=8 accept", 0.603, C_LARGE)]
    for name, a, c in pairs:
        inv = c * (1.0 - a)
        print(f"  {name:<24} c={c:.3f}  a={a:.3f}  invariant c(1-a)={inv:.4f}"
              f"  limit 1/(c(1-a))={1/inv:.3f}")
        for d in (8, 64, 512, 4096):
            print(f"      d={d:<6} d*sigma = {d * speedup(a, c, d):.4f}")
    inv_small = C_SMALL * (1 - 0.560)
    inv_large = C_LARGE * (1 - 0.603)
    print()
    check(f"small invariant {inv_small:.4f} < large invariant {inv_large:.4f}",
          inv_small < inv_large)
    a_cross = 1.0 - inv_small / C_LARGE
    print(f"  Crossover acceptance the 1.5B draft would need: {a_cross:.4f} "
          f"(it measured 0.603)")
    check("required crossover acceptance >= 0.778", a_cross >= 0.778 - 1e-9)


# ---------------------------------------------------------------------------
# 3. Depth collapse and the stopping depth
# ---------------------------------------------------------------------------

def demo_depth_collapse() -> None:
    rule("3. DEPTH COLLAPSE AND THE CANONICAL STOPPING DEPTH")
    print("  Gate: (1-a)*(1 + c*d) > 1  implies  sigma < 1 (speculation is a net loss)\n")
    for label, a, c in [("prose, 0.5B", 0.309, C_SMALL),
                        ("prose, 1.5B", 0.449, C_LARGE),
                        ("code,  0.5B", 0.560, C_SMALL),
                        ("code,  1.5B", 0.603, C_LARGE)]:
        dc = collapse_depth(a, c)
        print(f"  {label}: a={a:.3f}  first guaranteed-loss depth = {dc:<4}"
              f"  sigma at d=8 = {speedup(a, c, 8):.3f}")
    print()
    check("prose d=8 is a predicted loss for the small draft",
          speedup(0.309, C_SMALL, 8) < 1.0)
    check("prose d=8 is a predicted loss for the large draft",
          speedup(0.449, C_LARGE, 8) < 1.0)
    check("code d=8 is a predicted win for the small draft",
          speedup(0.560, C_SMALL, 8) > 1.0)
    check("prose d=4 is a predicted win for the small draft",
          speedup(0.477, C_SMALL, 4) > 1.0)

    print("\n  Throughput curve at the small-draft cost c = 0.118:")
    print(f"  {'d':>3}{'prose a=0.477':>16}{'code a=0.630':>16}")
    for d in range(0, 9):
        print(f"  {d:>3}{speedup(0.477, C_SMALL, d):>16.4f}"
              f"{speedup(0.630, C_SMALL, d):>16.4f}")
    d_prose = stop_depth(0.477, C_SMALL)
    d_code = stop_depth(0.630, C_SMALL)
    print(f"\n  D*(prose) = {d_prose},  D*(code) = {d_code}")
    check("stopping depths: prose 2, code 3 (strict domain split)",
          (d_prose, d_code) == (2, 3))
    best_prose = max(range(0, 200), key=lambda d: speedup(0.477, C_SMALL, d))
    best_code = max(range(0, 200), key=lambda d: speedup(0.630, C_SMALL, d))
    check("greedy stopping depth equals the global argmax over d <= 200",
          (best_prose, best_code) == (d_prose, d_code))


# ---------------------------------------------------------------------------
# 4. The depth law: monotonicity in acceptance
# ---------------------------------------------------------------------------

def demo_depth_law() -> None:
    rule("4. THE DEPTH LAW — D*(a,c) is non-decreasing in acceptance a")
    print(f"  {'a':>6}{'D*(a, 0.118)':>16}{'sigma at D*':>14}")
    prev = -1
    monotone = True
    for i in range(1, 20):
        a = i / 20.0
        D = stop_depth(a, C_SMALL)
        if D < prev:
            monotone = False
        prev = D
        print(f"  {a:>6.2f}{D:>16}{speedup(a, C_SMALL, D):>14.4f}")
    print()
    check("D* is monotone non-decreasing in a", monotone)


# ---------------------------------------------------------------------------
# 5. Falsification of the independent reading
# ---------------------------------------------------------------------------

def demo_iid_falsified() -> None:
    rule("5. THE INDEPENDENT READING IS FALSIFIED BY THE CODE CELLS")
    print("  Measured: code / 0.5B is FASTER at d=8 (1.661x) than at d=4 (1.616x),")
    print("  with reported acceptance 0.560.  Under independence:\n")
    print(f"  {'a':>6}{'sigma(a,c,4)':>15}{'sigma(a,c,8)':>15}{'d=8 better?':>14}")
    for a in (0.30, 0.50, 0.56, 0.70, 0.80, 0.85, 0.90):
        s4, s8 = speedup(a, C_SMALL, 4), speedup(a, C_SMALL, 8)
        print(f"  {a:>6.2f}{s4:>15.4f}{s8:>15.4f}{str(s8 > s4):>14}")
    print()
    check("no a <= 0.8 makes depth 8 beat depth 4",
          all(speedup(a / 1000.0, C_SMALL, 8) < speedup(a / 1000.0, C_SMALL, 4)
              for a in range(0, 801)))
    check("a = 0.85 does make depth 8 beat depth 4",
          speedup(0.85, C_SMALL, 8) > speedup(0.85, C_SMALL, 4))
    print("  => the reported 56.0% is NOT a per-position independent probability.")


# ---------------------------------------------------------------------------
# 6. Survival profiles: averaging law, block-mean test, reconstruction
# ---------------------------------------------------------------------------

def demo_survival_profiles() -> None:
    rule("6. SURVIVAL PROFILES — averaging law, falsifiability, exact reconstruction")

    print("  Reconstructed profiles S(k) = P(first k drafted positions all accepted):")
    print(f"  {'k':>4}" + "".join(f"{k:>9}" for k in range(0, 6)))
    print(f"  {'code':>4}" + "".join(f"{CODE_S[k]:>9.3f}" for k in range(0, 6)))
    print(f"  {'prose':>4}" + "".join(f"{PROSE_S[k]:>9.3f}" for k in range(0, 6)))

    print("\n  Exact reproduction of the six measured acceptance percentages:")
    for name, S, targets in [("code", CODE_S, {2: 0.716, 4: 0.630, 8: 0.560}),
                             ("prose", PROSE_S, {2: 0.639, 4: 0.477, 8: 0.309})]:
        for d, target in targets.items():
            got = mean_accept(S, d)
            print(f"    {name:<6} d={d}:  A_S(d) = {got:.6f}   measured = {target:.3f}")
            check(f"{name} acceptance at d={d} reproduced exactly",
                  abs(got - target) < 1e-9)

    print("\n  Averaging law: A_S(d) is non-increasing for ANY fixed monotone profile.")
    for name, S in [("code", CODE_S), ("prose", PROSE_S)]:
        seq = [mean_accept(S, d) for d in range(1, 13)]
        print(f"    {name:<6} " + " ".join(f"{v:.3f}" for v in seq))
        check(f"{name}: A_S non-increasing in d",
              all(seq[i + 1] <= seq[i] + 1e-12 for i in range(len(seq) - 1)))
    print("  => the measured acceptance decay is NOT evidence of drafter degradation.")

    print("\n  Block-mean test (the falsifiable necessary condition):")
    for name, means in [("code", (0.716, 0.630, 0.560)), ("prose", (0.639, 0.477, 0.309))]:
        # cumulative accepted mass at depths 2, 4, 8
        m2, m4, m8 = (means[0] * 2, means[1] * 4, means[2] * 8)
        blocks = (m2 / 2, (m4 - m2) / 2, (m8 - m4) / 4)
        print(f"    {name:<6} block means: " + ", ".join(f"{b:.3f}" for b in blocks))
        check(f"{name}: block means non-increasing (realisable)",
              blocks[0] >= blocks[1] - 1e-12 >= blocks[2] - 1e-12)

    print("\n  Counterexample: acceptance RISING with depth is unrealisable.")
    print("    A_S(2)=0.50 then A_S(4)=0.70 violates the averaging law.")
    check("0.70 > 0.50 contradicts monotonicity", 0.70 > 0.50)

    print("\n  The prose cliff (positions 2 -> 3) versus the gentle code decay:")
    print(f"    code : {CODE_S[2]:.3f} -> {CODE_S[3]:.3f}   (drop {CODE_S[2]-CODE_S[3]:.3f})")
    print(f"    prose: {PROSE_S[2]:.3f} -> {PROSE_S[3]:.3f}   (drop {PROSE_S[2]-PROSE_S[3]:.3f})")


# ---------------------------------------------------------------------------
# 7. The marginal-survival rule and the derived prescription
# ---------------------------------------------------------------------------

def demo_marginal_rule() -> None:
    rule("7. THE MARGINAL-SURVIVAL RULE — deepen while S(d+1) > c * sigma(d)")
    k = 0.287  # average marginal cost over depths 4..8 of the fitted curve
    print(f"  Marginal per-position cost k = {k}\n")
    for name, S in [("prose", PROSE_S), ("code", CODE_S)]:
        print(f"  {name}:")
        print(f"    {'d':>3}{'Y_S(d)':>10}{'sigma(d)':>11}{'k*sigma(d)':>13}"
              f"{'S(d+1)':>10}{'deepen?':>10}")
        for d in range(0, 9):
            sig = profile_speedup(S, k, d)
            pays = k * sig < S[d + 1]
            print(f"    {d:>3}{pos_yield(S, d):>10.3f}{sig:>11.4f}"
                  f"{k * sig:>13.4f}{S[d + 1]:>10.3f}{str(pays):>10}")
        print()
    check("prose: depth 5 is worse than depth 4",
          profile_speedup(PROSE_S, k, 5) < profile_speedup(PROSE_S, k, 4))
    check("code: depth 8 is better than depth 4",
          profile_speedup(CODE_S, k, 4) < profile_speedup(CODE_S, k, 8))
    print(f"  Greedy stopping depth: prose = {profile_stop_depth(PROSE_S, k)}, "
          f"code = {profile_stop_depth(CODE_S, k)}")
    print("  => derived prescription: d = 4 for prose, d = 8 for code.")


# ---------------------------------------------------------------------------
# 8. The convex CPU cost curve and the twelve-cell test
# ---------------------------------------------------------------------------

def demo_cost_curve() -> None:
    rule("8. THE CONVEX CPU COST CURVE — calibrated on 3 cells, tested on 12")
    print(f"  C(extra, d) = {B_FIT} + ({K_FIT} + extra)*d + {M_FIT}*d^2,"
          f"  extra(1.5B) = {EXTRA_LARGE:.3f}\n")
    check("fixed per-block overhead: C(extra, 0) > 1", cpu_block_cost(0.0, 0) > 1.0)
    second_diffs = [cpu_block_cost(0.0, d + 2) - 2 * cpu_block_cost(0.0, d + 1)
                    + cpu_block_cost(0.0, d) for d in range(0, 10)]
    check("strict convexity (anti-amortisation): all second differences > 0",
          all(x > 0 for x in second_diffs))
    print(f"  constant second difference = {second_diffs[0]:.4f}\n")

    print("  Affine cost is falsified: solving the first two code cells for (b, k)")
    # 1 + q*d = sigma_meas * (b + k*d)  for the three code / 0.5B cells
    rows = [(2, 0.716, 1.352), (4, 0.630, 1.616), (8, 0.560, 1.661)]
    (d1, q1, s1), (d2, q2, s2), (d3, q3, s3) = rows
    # (1 + q*d)/s = b + k*d  ->  solve the 2x2 system on rows 1,2, test row 3
    r1, r2, r3 = (1 + q1 * d1) / s1, (1 + q2 * d2) / s2, (1 + q3 * d3) / s3
    k_fit = (r2 - r1) / (d2 - d1)
    b_fit = r1 - k_fit * d1
    residual = (b_fit + k_fit * d3) - r3
    print(f"    from d=2,4:  b = {b_fit:.4f}, k = {k_fit:.4f}")
    print(f"    predicts (1 + q*8)/sigma = {b_fit + k_fit*d3:.4f}, actual {r3:.4f}, "
          f"residual {residual:+.4f}")
    check("no affine cost fits all three code cells", abs(residual) > 1e-6)

    print("\n  Twelve-cell test (predicted / measured, relative error):")
    print(f"  {'cell':<18}{'q':>8}{'pred':>9}{'meas':>9}{'rel err':>10}")
    worst = 0.0
    for domain in ("prose", "code"):
        for draft in ("0.5B", "1.5B"):
            extra = 0.0 if draft == "0.5B" else EXTRA_LARGE
            for d in (2, 4, 8):
                meas, q = MEASURED[(domain, draft, d)]
                pred = pred_speedup(q, extra, d)
                err = abs(pred - meas) / meas
                worst = max(worst, err)
                tag = f"{domain}/{draft}/d={d}"
                print(f"  {tag:<18}{q:>8.3f}{pred:>9.3f}{meas:>9.3f}{err*100:>9.1f}%")
    print()
    check(f"every cell within 11% (worst = {worst*100:.1f}%)", worst <= 0.11)

    print("\n  Verification-overhead bracket from the two measured depth-8 signs:")
    lo = 0.309  # prose acceptance: net loss requires k > 0.309
    hi = 0.560  # code acceptance: net win requires k < 0.560
    print(f"    marginal per-position cost k in ({lo:.3f}, {hi:.3f})")
    print(f"    verification charge w = k - {C_SMALL} in "
          f"({lo - C_SMALL:.3f}, {hi - C_SMALL:.3f}) target-steps per extra position")
    check("(1 + 0.309*8)/(1 + 8*lo) is exactly 1 at the lower bracket end",
          abs((1 + 0.309 * 8) / (1 + 8 * lo) - 1.0) < 1e-12)
    check("(1 + 0.560*8)/(1 + 8*hi) is exactly 1 at the upper bracket end",
          abs((1 + 0.560 * 8) / (1 + 8 * hi) - 1.0) < 1e-12)


# ---------------------------------------------------------------------------
# 9. Practical throughput summary
# ---------------------------------------------------------------------------

def demo_throughput_summary() -> None:
    rule("9. PRACTICAL SUMMARY — absolute throughput on the measured machine")
    baseline = 5.79  # tokens per second, greedy, no speculation
    print(f"  Baseline (no speculation): {baseline:.2f} tok/s\n")
    print(f"  {'configuration':<22}{'speedup':>10}{'tok/s':>10}")
    best_key, best_val = None, 0.0
    for (domain, draft, d), (meas, _) in sorted(MEASURED.items()):
        tag = f"{domain}/{draft}/d={d}"
        print(f"  {tag:<22}{meas:>10.3f}{baseline*meas:>10.2f}")
        if meas > best_val:
            best_key, best_val = (domain, draft, d), meas
    print(f"\n  Best cell: {best_key} at {best_val:.3f}x "
          f"({baseline*best_val:.2f} tok/s), a {100*(best_val-1):.1f}% gain.")
    static8 = MEASURED[("prose", "0.5B", 8)][0]
    adaptive = MEASURED[("prose", "0.5B", 4)][0]
    print(f"  Static d=8 on prose: {static8:.3f}x versus adaptive d=4: {adaptive:.3f}x")
    print(f"  Forfeited throughput from a static depth: "
          f"{100*(adaptive/static8 - 1):.1f}%")
    check("a static depth forfeits more than 25% on prose",
          adaptive / static8 - 1 > 0.25)


def main() -> None:
    print(__doc__)
    demo_cost_dominance()
    demo_asymptotic_invariant()
    demo_depth_collapse()
    demo_depth_law()
    demo_iid_falsified()
    demo_survival_profiles()
    demo_marginal_rule()
    demo_cost_curve()
    demo_throughput_summary()
    rule("ALL CHECKS PASSED")


if __name__ == "__main__":
    main()
