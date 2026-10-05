# Round 112 synthesis — three corrections to my own work

**Status: I published a wrong conclusion in r111c. The gifp_wall subagent found
it and I verified the correction independently. Recording it here rather than
quietly editing, because the error is instructive.**

## The error

r111c claimed, and I committed:

> "for α ≥ 0.15 the attack fails at every feasible γ and every m — a genuine
> wall, independent of the m-rounding bug" and "t=ceil rescues nothing there."

**That is wrong at α = 0.15.** The wall there is my own parameterization bug.

### Mechanism

`gifp.sage:339` sets `t = round((1−√α)·m)`. This is a *staircase* in α, and for
m=4 it steps down from 3 to 2 at α ≈ 0.145:

| α | t | log₂(unknown_modular), n=200 |
|---|---|---|
| α ≤ 0.145 | 3 | 640 |
| 0.145 < α ≤ 0.395 | **2** | **440** |

Since `unknown_modular = M^m · N1^t` and N1 is n=200 bits, dropping t by one
**removes a full 200 bits of modulus** — catastrophic when n=200. My r111 sweep
tested γ across its whole range at α ≥ 0.15 and saw no effect, because
**γ does not appear in the modulus at all**. It buys nothing this attack needs.
So "pushing γ to the limit" was always guaranteed to fail — I had tested a
knob that isn't connected.

## Independent verification (my own code, my own ground truth)

α=0.15, γ=0.6617, n=200:

| setting | verified | zero-polys at root |
|---|---|---|
| reference default (t=2) | **0/2** | 2 |
| **t=3, s=0** | **3/3** | 6,5,5 |
| t=3, s=0, m=6 | 2/3 | 5,5,5 |

`a·(N2/a) == N2` **and** `a ∈ {p₂,q₂}` checked on every accepted factor.

## Correction to r111c, precisely

- **α = 0.15 is an artefact.** Forcing `t=3, s=0` factors it 3/3, at m=4 and m=6.
- **α = 0.20 is REAL.** 0/3 at every (t, m, s) tried, with 0 vanishing
  polynomials — the root genuinely is not recoverable there.
- **My "t and s have opposite optima" finding (r112 lead_scaling) was itself
  measured at α=0.10, m=4** and does not generalise: the right rule is to choose
  (t,s) so the modulus does not collapse, and at α=0.15 that is t=3, s=0.

The honest version of the r111c claim: **"the α≥0.15 wall" was never one wall.
α=0.15 was a modulus-collapse bug in the reference default; α=0.20 is the real
boundary, and I have not explained it.** With one exception: γ genuinely cannot
rescue either, because γ is absent from the modulus — that part stands.

## Standing state of the GIFP line

- Threshold γ > 4α(1−√α) verified end-to-end (r110), 20/20 at γ=0.70, twice, on
  two Sage installs. **Stands.**
- The α-dependence claim in r111 ("the bound's shape is wrong") — **now
  suspect**, because it was measured through the t-collapse. It must be
  re-measured with t held at the non-collapsing value before it can be restated.
- α = 0.20 is a genuine unexplained wall.
- The m-rounding bug (r111c) is real and separate; `t=ceil` fixes it at α=0.10.

## What I got wrong, in the generalisable form

I ran a parameter sweep over **γ** to probe a failure whose cause was **t**, and
γ does not appear in the quantity that matters. The negative result was
internally consistent (0/8 everywhere, twice, seeded, ground-truth-checked) and
still wrong, because every point in the sweep shared the same hidden defect.

**Rule this adds:** when a sweep is uniformly null, suspect a shared defect in
the swept harness before believing the physics — then vary a knob you have *not*
been sweeping, to break the shared dependence. Every one of my nulls this round
(`no_gb` at α≥0.15, the two failed feasibility probes, the "no_factor" rows)
was the *same* t-collapse wearing different clothes.
## Appendendum: the α = 0.15 rescue is real, but do NOT read it at 4 seeds

I re-measured the retracted α-dependence claim at fixed `t=3`, got 0/4 at
α = 0.15, and briefly had a direct conflict with the wall agent's 3/3. Resolved
by sweeping 12 seeds per configuration:

| α=0.15 config | verified |
|---|---|
| γ=0.6617, m=4, t=3, s=0 | **11/12** |
| γ=0.6617, m=6, t=3, s=0 | **11/12** |
| γ=0.6617, m=4, t=3, s=1 | **12/12** |
| γ=0.66,   m=4, t=3, s=0 | **8/12** |
| γ=0.66,   m=6, t=3, s=0 | **12/12** |
| γ=0.66,   m=4, t=3, s=1 | **11/12** |

So α=0.15 with a non-collapsing `t` factors at **~85–100%** — the wall agent was
right and my 4-seed recheck was simply underpowered near the tight end of the
feasible γ range, where success is real but not certain.

This is the **fourth** time this round that a small seed count produced a wrong
conclusion — after 13/40→12/40, the two broken feasibility probes, and the
kernel/trivial `g` mismatch. Near a parameter boundary the success rate is
neither 0 nor 1, and 4 trials cannot tell those apart.

**Rule:** at any parameter point where the outcome is expected to be marginal,
use ≥12 seeds before writing a count, and report the rate rather than a
pass/fail. A 0/4 against someone's 3/3 is a seed problem until proven otherwise.

### Corrected α-dependence (measured at t=3, 4 seeds/point — read as coarse)

| α \ ratio | 1.4× | 1.6× | 1.8× |
|---|---|---|---|
| 0.05 | 3/4 | 3/4 | 4/4 |
| 0.10 | 0/4 | 0/4 | 4/4 |
| 0.15 | 0/4 | 0/4 | 0/4 |
| 0.20 | 0/4 | infeasible | infeasible |

The direction survives at coarse resolution (higher α needs higher γ), but at
α=0.15 the 1.8× point is 0/4 here and 11/12 at γ=0.6617 in the 12-seed sweep —
i.e. this grid is sitting exactly on the boundary and the 4-seed cells are not
trustworthy. **The r111 "shape is wrong" claim remains unresolved**, not
confirmed and not refuted; it needs the ≥12-seed treatment everywhere before it
should be restated in any document.
