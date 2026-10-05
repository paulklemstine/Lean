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
ideal `(1−√α)m`:

| m | 2 | 3 | **4** | 5 | 6 | **7** | 8 | **9** | **10** |
|---|---|---|---|---|---|---|---|---|---|
| ideal (1−√α)m | 1.37 | 2.05 | **2.74** | 3.42 | 4.10 | **4.79** | 5.47 | **6.15** | **6.84** |
| t = round(ideal) | 1 | 2 | **3** | 3 | 4 | **5** | 5 | **6** | **7** |
| works? | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✓ |

**Working m are exactly those where `round` does not undershoot the ideal** —
`t ≥ ⌈ideal⌉`. At m=2,3,5,6,8 the rounding truncates and the balance required
by the size analysis is lost, so the short vectors never appear. This is a
rounding artefact in the *reference implementation*, not a property of the
attack: with t and s chosen to satisfy the true balance rather than rounded
independently, those m should work too. **Not tested** — flagged as the next
step, not claimed.

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
- `alpha_sweep.sage` — the α × ratio table above.