# ⚠️ THE SHARED DICKMAN HARNESS IS BROKEN BEYOND u = 5

**Round 49. Found by the Shoup agent, confirmed by me. This invalidates a piece of
infrastructure I built and distributed to every agent in the round.**

## What happened

`factor-scratch/r48/_shared/dickman.py` was written by me early on, its self-tests made to
pass, and it was then distributed to **every round-48/49 agent** with the instruction:

> *"USE THE VALIDATED SHARED HARNESS … Its null reproduces Dickman ρ to 1.43σ."*

**It is valid only for `u ≤ 5` and silently wrong beyond.**

| u | this harness | measured truth (exact Ψ) |
|---|---|---|
| 6 | 2.224×10⁻⁵ | **~1.96×10⁻⁵ — harness 13% high, not wrong by 12×** |
| 8+ | ~10⁻⁶ | collapses |
| **20** | **6.666×10⁻⁷** | **~10⁻²⁷** |

> ### ⚠️ MY FIRST REPORT OF THIS BUG WAS ITSELF PARTLY WRONG
>
> I originally quoted the truth column as `e^{−u(ln u + ln ln u − 1)}` — the **de Bruijn
> asymptotic**, not the true Dickman value. At `u = 6` that asymptotic is badly off: the
> Shoup agent measured `ρ(6) ≈ 1.96×10⁻⁵` by exact `Ψ` at fixed `u`, **converging down onto
> the harness value from above** (17.8× → 6.9× → 3.4× → 2.8× as `y = 25…200`), while the
> de Bruijn column moves the *wrong way* (1.34 → 0.52 → 0.26 → 0.21).
>
> **So the error at `u = 6` is 13%, not a factor of 12.** The `u ≤ 5` guard is correct and
> slightly conservative. The **saturation above `u ≈ 7` is real** and is the actual defect.

**The RK4 step degenerates: the grid integration freezes near the floating-point floor
instead of continuing to decrease.** The curve saturates at ρ ≈ 6.7×10⁻⁷ for all large `u`.

## Why the self-test did not catch it

It probed `ρ(1.5)`, `ρ(2)`, `ρ(3)`, `ρ(4)` against the standard table, and checked the null
harness against the 48-bit calibration cells — **all at `u ≤ 4.2`**. It passed because it
tested exactly the regime where the function works.

This is **the same failure mode as every other instance in this round, and it is mine**:

> The defect is not in the tested range. It is in the range nobody tested.

The calibration cells used `u = 3.0` — inside the valid region. So the "1.43σ" claim I
repeated in briefs to every agent is true, and **irrelevant to the question**, because the
harness was never valid where it was most likely to be used.

## What this affects

- **Every Stange-regime number.** Round 48/49 agents were computing `u ≈ 5–8` there. The Shoup
  agent hit this and *deliberately refused to ship a replacement* after four attempts failed,
  including at 60 digits — reporting `ρ(u)` at RSA sizes as **unmeasured**. That was the right
  call and it should have been mine.
- **NFS operating points at `u ≈ 3–5`** are marginal — inside the guard but near its edge.
  Use exact `Ψ` or Monte Carlo there, not `ρ`.
- **The `13.9×–1244×` Ψ/ρ figures** in #523 §6.2 came from exact `Ψ`, not from `ρ`, so they
  survive. **The `8.46×` figure I originally recorded did not** — and was already corrected
  separately.

## The fix

`dickman.py` now carries a `VALID_U_MAX = 5.0` guard and **raises** rather than returning a
number outside the tested range:

```
ValueError: rho(u) requested at u=20, but this harness is only valid for u <= 5.0
(it saturates above that -- see VALID_U_LIMIT note). Use exact Psi, Monte Carlo,
or the de Bruijn closed form instead.
```

**A loud failure is worth more than a quiet wrong answer**, and that is the only reason the
harness is now safe to distribute at all. I have deliberately **not** attempted a fix: the
Shoup agent tried four times, including 60-digit arithmetic, and failed. Shipping a fifth
half-working replacement would repeat the original sin.

## The rule, now earned in its strongest form

> **A self-test that probes only the regime where the code works is a self-test that cannot
> fail.** Coverage of the *tested* range is not coverage of the *used* range.

And the version for anything you distribute to others:

> **If you hand an instrument to another agent with a claim of validation
> ("reproduces ρ to 1.43σ"), you are certifying the range you tested — not the range they
> will use. Say which range.**

This is the sixth instance of the round's standing failure mode, and the most expensive,
because it is the one I built the others' work on.

## Why no replacement was shipped

The Shoup agent attempted five formulations for a working `ρ` at large `u`: log-space
Simpson on the causal Volterra equation at 30–40 digits (h-converged to 0.014% at `u=5`,
**collapsing to an 85% spread at `u=8` and 19000% at `u=10`**), interval power series, direct
ρ-space ODE, implicit per-cell, and composite Simpson. **Raising precision to 140 digits did
not help** — which *proves* the limit is the scheme's truncation error, not round-off.

Its conclusion, which I agree with and am adopting:

> **Broken-but-guarded is the right call.**

Reproducing `ρ` at `u ≈ 20–25` needs a scheme representable across 20 octaves of decay, or a
literature-grade Dickman–de Bruijn implementation. Shipping a fifth half-working replacement
would repeat the original sin at greater cost.

## The agent's own audit bugs, recorded because they are the trusted kind

Its first two ρ-dependency checks were **regex source-scans**, and **both were wrong** — one
flagged a de Bruijn print table (`u=40`) that never calls ρ; the other flagged the audit's own
docstring. It replaced them with a **spy**: wrap `rho()` and count calls, then substitute a
function that *raises* and re-derive every load-bearing result.

> **A tripwire that always fires gets ignored.**

Under the raising `rho`, both load-bearing results still verify: the `2√2 → 2` improvement
(ratio `1.41350` against `√2`) and the `log u / log log n → ½` identity (to 1e-10). **Neither
touches ρ.** Its ρ usage is confined to the `c(u)` tightness diagnostic on `2 ≤ u ≤ 5`, where
the harness is sound. **51 PASS, 0 FAIL, 12 NULL.**
