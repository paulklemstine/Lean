> ## ⚠️ HEADLINE CLAIM REFUTED (round 112) — the α-table below is invalid
>
> **r111's conclusion that "the bound's shape is wrong" is REFUTED.** Measured
> at corrected (t,s), α=0.15 needs γ ≈ 0.62 ≈ **1.7× the proven 0.3676** — the
> same looseness r110 measured at α=0.10. Success is never observed below the
> proven threshold. So `γ > 4α(1−√α)` is **sufficient-but-loose by ≈1.6–1.7×**,
> and its functional form is **not** contradicted.
>
> **Why the α-table below is invalid:** the sweep used the reference's own
> `t = round((1−√α)m)` / `s = round(√α·m)` (`gifp.sage:339-340`). At m=4, `t`
> steps 3→2 at α≈0.145, collapsing `unknown_modular` by a full n=200 bits; and
> γ does not enter the modulus at all. The table therefore measured a
> two-variable parameter failure as if it were an α-dependent wall.
>
> **Three DISTINCT ceilings were merged into one "0/8 everywhere":**
> - **α ≤ 0.15** — parameter bug; fixed by (t,s), factors ~85–100%.
> - **α ≈ 0.17–0.18** — lattice healthy (27/28 vanishing) but **Gröbner never
>   closes**; no (t,s) fixes it.
> - **α ≥ 0.19–0.20** — **genuine geometric ceiling**: zero vanishing
>   polynomials at every (t,s,m,β,n) tried, stable to n=600. This one really
>   does bound the published construction.
>
> **Still standing from this document:** the m-rounding bug (t=ceil fixes it at
> α=0.10) and the m-scan. **Unreliable:** the intermediate `nz` counts — the
> sweeps used `M^m·N1^t` where `gifp.sage:341` uses `M^m·p1^t`, overstating by
> 28–99 bits. Accepted factors were ground-truth checked, so verdicts hold.
>
> Full detail: `factor-scratch/r112/gifp_wall/RESULT.md`,
> `factor-scratch/r112/LEAD_SYNTHESIS.md`.

# GIFP round 111 — the bound's shape is wrong, and m is a resonance knob

Builds on `GIFP_R110_RESULTS.md` (threshold verified end-to-end). Two new
questions, both answered with independently-verified counts.

## Q1: Is the looseness in γ > 4α(1−√α) constant across α?

At α=0.1 the bound holds but is ~1.6× loose. If the gap were constant, the
paper's *functional form* would be right and only the constant slack. It is not.

Ratio = γ / [4α(1−√α)], the proven threshold as 1.0×. n=200, m=4, 8 seeds/point:

| α \ ratio | 1.0× | 1.2× | 1.4× | 1.6× | 1.8× | 2.0× |
|---|---|---|---|---|---|---|
| 0.05 | 0/8 | 0/7 | 3/8 | **8/8** | 8/8 | 8/8 |
| 0.10 | 0/8 | 0/8 | 0/8 | **6/8** | 7/8 | – |
| 0.15 | 0/8 | 0/8 | 0/8 | 0/8 | 0/8 | infeasible |
| 0.20 | 0/8 | 0/8 | 0/8 | infeasible | – | – |

The transition ratio moves: ~1.4× at α=0.05, ~1.6× at α=0.10, and **never**
for α ≥ 0.15. The bound is not merely loose — its α-dependence does not track
the observed behaviour.

### The α ≥ 0.15 ceiling is real, not a grid artifact

I pushed γ to the maximum the bit budget allows (α+γ+β₂ < 1) at α = 0.15, 0.20,
0.25, and also tried m = 3…6:

- α=0.15: γ = 0.50…0.68 → **0/8 at every point**, including γ=0.68 (the last
  feasible value before the top-chunk headroom runs out).
- α=0.20: γ = 0.50, 0.60, 0.62 → 0/8.
- α=0.25: γ = 0.50 → 0/8.
- Raising m does **not** rescue α=0.15 at m ∈ {3,4,5,6}.

So for α ≥ 0.15 the attack does not merely need a bigger γ — it fails
throughout the feasible region at every m tested. That is a genuine ceiling in
this regime, not a sampling gap. (n=200, β₁=0.1, β₂=0.15.)

## Q2: m is a resonance knob, not a "bigger is better" dial

At α=0.10, γ=0.50 — a point where m=4 works — scanning m:

| m | 2 | 3 | **4** | 5 | 6 | **7** | 8 | **9** | **10** |
|---|---|---|---|---|---|---|---|---|---|
| verified | 0/6 | 0/6 | **6/6** | 0/6 | 0/6 | **6/6** | 0/6 | **6/6** | **6/6** |
| time/pt | 0.8s | 0.7s | 0.6s | 0.6s | 1.2s | 1.4s | 17.6s | 17.4s | 47.5s |

Intermittent in m, not monotone. Failing m return `no_gb` — the Gröbner basis
never reaches length ngens — while working m return `ok`.

### Mechanism

The script sets `t = round((1−√α)·m)` and `s = round(√α·m)`. These integers
drive the shift-polynomial weighting. Comparing the rounded `t` against the
ideal `(1−√α)m`: working m are those where the rounding does not undershoot.
Confirmed causally below.

**Working m are exactly those where `round` does not undershoot the ideal** —
`t ≥ ⌈ideal⌉`. At m=2,3,5,6,8 the rounding truncates and the balance required
by the size analysis is lost, so the short vectors never appear.

### Confirmed causally (not just correlated)

I flagged the converse as untested in the first write-up, then tested it: force
`t = ⌈ideal⌉` instead of `round(ideal)`, changing nothing else. At α=0.10,
γ=0.50, 4 seeds each:

| m | ideal t | t=round | t=ceil |
|---|---------|---------|---------|
| 3 | 2.05 | 2 → **0/4** | 3 → **4/4** |
| 4 | 2.74 | 3 → 3/3 | 3 → 4/4 |
| 5 | 3.42 | 3 → **0/4** | 4 → **0/4** |
| 6 | 4.10 | 4 → **0/4** | 5 → **4/4** |
| 8 | 5.47 | 5 → **0/4** | 6 → **4/4** |

m=3, 6 and 8 flip from 0/4 to 4/4 purely by removing the undershoot. So for
those m the resonance is **a rounding artefact in the reference implementation**,
not a property of the attack — `gifp.sage:339-340` computes `t` and `s` by
rounding the ideal balance, and that rounding is lossy. The full α×m grid below
shows this is only *part* of the story (m=5 and α=0.15 have separate causes).

Practical consequence: **do not tune m by trial and error** — compute
`t = ⌈(1−√α)·m⌉` directly. Every "m=4 works, m=5 doesn't" observation in the
literature on this construction may be this rounding, not the mathematics.

### The rounding effect and the α-ceiling are INDEPENDENT

Running both `t=round` and `t=ceil` at each (α, m) separates the two phenomena
(4 seeds/point, γ=0.50 for α≤0.10, γ=0.60 for α=0.15):

| α | m=3 | m=4 | m=5 | m=6 | m=7 | m=8 |
|---|---|---|---|---|---|---|
| 0.05 round | 0/4 | 4/4 | 4/4 | 4/4 | 4/4 | 4/4 |
| 0.05 ceil | **4/4** | 4/4 | 4/4 | 4/4 | 4/4 | 4/4 |
| 0.10 round | 0/4 | 4/4 | 0/4 | 0/4 | 4/4 | 0/4 |
| 0.10 ceil | **4/4** | 4/4 | **0/4** | **4/4** | 4/4 | **4/4** |
| 0.15 round | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 | 0/4 |
| 0.15 ceil | **0/4** | **0/4** | **0/4** | **0/4** | **0/4** | **0/4** |

Three things follow:

1. **α=0.05** — `t=round` already succeeds for m≥4; the undershoot only bit at
   m=3, and `t=ceil` fixes it. `t=ceil` never makes anything worse.
2. **α=0.10** — the rounding fixes m=3, 6, 8, but **m=5 fails at both t=3 and
   t=4**. So a second, distinct constraint exists at m=5 that is not the
   undershoot. Not isolated.
3. **α=0.15** — `t=ceil` rescues **nothing**: 0/4 at every m. The α≥0.15
   ceiling from Q1 is therefore **not** a rounding artefact. It is a genuine
   geometric/feasibility wall of this construction in the tested regime, and it
   is independent of the m-rounding bug.

So the two failures have different causes and should not be conflated: the
**m-resonance is an implementation rounding bug** (fixable), while the
**α≥0.15 wall is real** (not fixable by t, and not explained here).

## Harness notes (bugs that produced wrong numbers first)

- **The generator needs every bit budget to land on an exact integer.**
  `p1` has bit length `int(n(1−α−γ−β₁)) + int(nγ) + int(nβ₁)`, which equals
  `int(n(1−α))` only when the products are exact. With γ=0.2735 and n=200,
  `int(200γ)=54` loses a bit, N never reaches exactly 200 bits, and
  `generate_gifp_instance` returns `None` for **every** seed. My first α-sweep
  scored 0/0 everywhere for this reason. All γ,α,β are now snapped to the 1/n
  grid. Anyone reproducing this must do the same.
- `inverse_mod(N2, M^m·N1^t)` **raises** `ZeroDivisionError` when
  `gcd(N2, modular) ≠ 1`, which happens at some parameter points. That is an
  inapplicable construction, not a refutation — now skipped.
- The generator raises `ValueError: empty range` when the top chunk
  `n−αn−γn−β₂n` has 0–1 bits, at the feasibility boundary. Now guarded.

All three are properties of the authors' reference code, not of the attack.

## Files

- `gifp_verify_sage.sage` — pipeline + README gcd recovery + verification (r110).
- `gifp_threshold_sweep.sage` — γ sweep at α=0.1 (r110).
- `gifp_alpha_sweep.sage` — the α × ratio table above.
- `gifp_m_scan.sage` — the m-scan and the t-balance table.
- `gifp_t_rounding_test.sage` — the causal test that `t=ceil` rescues the
  failing m at α=0.10 (the "0/4 → 4/4" flips).
- `gifp_round_vs_ceil.sage` — the full α×m round-vs-ceil grid that separates the
  rounding bug from the independent α≥0.15 wall.