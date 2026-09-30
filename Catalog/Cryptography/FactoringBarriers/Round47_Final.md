# Round 47 — FINAL. The method reduces to one open lattice problem.

**2026-09-29. Everything is now costed. The axis is not closed, but it has been reduced to a
single question, and the fallback is provably worse than the GNFS.**

---

## What the method is, in one paragraph

Given `N = pq` with `p ≡ q ≡ 3 (mod 4)` and `f = X³ + PX + Q` with `f(m) ≡ 0 (mod N)`:
enumerate coprime `(u,v)` to height `H`; the cone `g₁² + 2g₀g₂ − Pg₂² = 0` makes
`l(α) = g²` automatic; keep those with `l(m) = w²`; **verify `w² ≡ g(m)² (mod N)`**; compute
`chi_P = Jacobi(C(t)·y, N)`; at `chi_P = −1` output `gcd(w − g(m), N)`.

**No descent, and `N` is never factored** — proven by AST audit plus a live tripwire on
`isprime`/`factorint`. The `chi_P = −1` gate is a **perfect** split predictor: `136/136`,
against `0/182` on the `+1` side.

## Everything, costed

| | |
|---|---|
| trial | `O(H²)` ≈ 20–60 ms, no descent |
| supply, **measured** | `rate = exp(3.2111)·N^{−0.25}`, **R² = 0.997** over 5 sizes, 400 `f` each |
| **crossover if selection were FREE** | **191.5 bits** (`N ≈ 10^58`) |
| **lattice selection** | **60 µs, `poly(log N)`** — but returns `m ~ N`, the **dead cell** (0% supply) |
| **scan to `N^{1/4}`** | **`N^{3/4}` probes — crosses over GNFS at 13 bits** |
| GNFS | `L[1/3, 1.923]` |

## The close, in one paragraph

> **`N^{3/4}` is a polynomial in `N`; `L[1/3, 1.923]` is subexponential. So a
> polynomial-cost selector is eventually *worse* than the GNFS at every useful size — the
> crossover sits at 13 bits. The one cheap selector, the lattice, lands in a region where the
> supply is exactly zero. And the 191.5-bit figure is an **upper bound on the competitive
> range that holds only if selection is free, which it is not.**

**The method's viability reduces to a single question:**

> ### **Is there a `poly(log N)` algorithm that returns `f = X³ + PX + Q` with small
> ### coefficients and `m ~ N^{1/3}`?**

This is a **lattice problem with a size constraint that LLL does not handle**: the standard
construction optimises the *coefficients* and lets `m` fall where it may (and it falls at `N`),
whereas this method needs `m` *small* — it needs the relation curve to have a rational point
at height `~10`, which happens only in a narrow `m`-window. It is the exact analogue of a
problem the NFS already solves, with a different objective, which is both encouraging (the
shape is familiar) and a warning (it may be hard for the same reason).

## What was wrong on the way here, and the rule it earned

| the "negative" | what it actually was |
|---|---|
| "8/8 escapes to `chi_P = −1`" | a sign error — the curve for a **different field** |
| "`∞` sec/factor at 32+ bits" | a `continue` that **never advanced `m`** |
| "0 `f` found above 23 bits" | a probe budget **below** the threshold `N/(2·c_max)` |
| "EMPTY, decisively" | **4–5 `f` at a rate of 8%** — 0 is what you must expect |
| a green control reading **"0/0 instances agree. PASS"** | **it ran zero instances** |
| a monitor firing on a `grep -c` of a **header row** | it counted a header, not data |

> **A run that reads as a negative is a suspect instrument first; a run that reads as an
> absence is a suspect *sample* first; and a control that reports success over zero instances
> is worse than no control, because it is green.** Six times today. Each would have closed a
> live direction.

## The round, in five lines

1. The relations of the square-relation NFS are **the rational points of a genus-1 curve**,
   with an explicit Jacobian, an explicit character, and a **perfect** split gate. *(New — the
   genus arithmetic is a rediscovery of Humbert–Edge; the identification is not.)*
2. That gives a **factorisation-free, descent-free factoring method** — the first positive
   artefact in 47 rounds.
3. It **dies where the selector puts it.** `poly(log N)` selection lands in a dead region; the
   polynomial-cost alternative is worse than the GNFS.
4. The supply decays as **`N^{−1/4}`** (measured), not the `N^{−1/6}` the density model
   predicts — the model is flagged failed, not repaired.
5. **One open question remains: a `poly(log N)` small-`m` selector.**

Two corrections survive into the record and are on issue #515: the "half the moduli are dead"
claim (a frozen selector, refuted over 11,638 `f`) and the 336-bit crossover (a model exponent;
measured, it is 191.5 bits — and that too is an upper bound, conditional on free selection).
