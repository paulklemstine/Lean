# Round 112 — final synthesis and the most important finding of the night

## ⚠️ The GIFP r110 headline has a fatal framing flaw

The adversarial verifier found it and I confirmed it directly:

| small factor \|q\| | PARI `factor(N)` |
|---|---|
| 20 bits | **0.006 s** |
| 30 bits | 0.017 s |
| 40 bits | 0.096 s |
| 60 bits | 1.53 s |
| 80 bits | 8.74 s |

In every GIFP instance in r110/r111, `|q₂| = α·n`. At **n=200, α=0.1 that is
20 bits** — so `N₂` is trivially factorable in 6 milliseconds with zero GIFP
knowledge. **"GIFP recovers p₂ and q₂" at n=200 therefore has no discriminating
content**: the statement is true but uninformative, and r111's 47.5 s/point at
m=10 is ~8000× *slower* than doing nothing clever at all.

This is a framing error, not a math error, and it means:

- **The r110 "20/20 verified" is real but vacuous as evidence for GIFP.**
- **The r111 α-table and my r112 re-measurements inherit the same flaw** — they
  were all run at n=200, where the ground truth is free.

### The decisive test the verifier ran

At **n=800** (\|q₂\| = 80 bits, where generic factoring is *not* instant), the
attack still recovered p₂ in **3/3**, while PARI `factor` on the same instance ran
**>4 minutes without success** (n=600 factorises in 3.9 s).

**So the GIFP mechanism is real — it just needs n ≥ ~800 to mean anything.** The
verifier's leak controls confirm this is not an artefact: 6/6 recover the true
instance's p₂ and **0/6** recover an unrelated instance's N₂; 0/10 on random
polynomials, with 7/10 still reaching GB length 4 (measuring, not pigeonholing).

**What I should have done in r110 and did not: state the generic-factoring
baseline next to every "verified" count.** Without it, a reader cannot tell a
real attack from a free answer.

## Second correction: "t = ceil" is unsafe advice

My r111c/r112 wrote that `t = ⌈(1−√α)m⌉` fixes the rounding. The verifier shows
that is **not a one-directional fix**:

- m=3, 6, 8: `round` fails → `ceil` works (0/4 → 4/4) — my observation, correct
- **m=4 and m=7: `round` works → `ceil` breaks them (4/4 → 0/4)**

The balance is two-sided. My lead_scaling note already caught the shadow of this
(at α=0.10, m=4, raising `s` alongside `t` broke it) but I still published the
one-sided recipe. **Correct rule: search (t, s) jointly; there is no closed-form
fix.**

## Third: the α-dependence claim was never testable at n=200

The verifier: at α=0.20 the largest feasible ratio to threshold is **1.4×**, so
r111's "0/8 at α=0.20" was mostly the generator failing, not the attack. A shape
claim needs ratios above threshold at *every* α, and n=200 with β₂=0.15 cannot
supply them. Combined with the n=200 triviality, **r111's headline is not merely
refuted — it was never a well-posed experiment.**

I separately found the α ∈ (0.15, 0.17] lattice decay (mean nz: 8.0 → 6.25 → 5.0
→ 4.38 → 1.25 → 0.38), which is a *real* gradual transition — but also measured
at n=200, so it inherits the same caveat.

## Novel mechanisms: 8 candidates, 7 closed, 0 improvements

| # | Candidate | Verdict |
|---|---|---|
| A | unbalanced RSA is easier | **SUPPORTED negative** — threshold is `X = N^{β²}`, tracks `log N` not `log p`. Imbalance buys nothing. |
| B | Legendre decision oracle | **REFUTED** — cost 1.10×√p vs rho 0.72×√p; CI [1.37, 2.68]. Cyclic-of-known-order buys nothing without smoothness. |
| C | recombination via nullspace structure | **INCONCLUSIVE** — the 0.9897 collision rate is a **pigeonhole** (left-nullspace vectors are even by construction). Untested, not closed. |
| D | `p+q` / Fermat lattice | **REFUTED** — `~N^{1/4}`-class, dominated by rho |
| E | auxiliary-info amplifiers | **BLOCKED** on wall-clock; partial: multiplier 0/12 vs control 4/9 |
| F | special-form moduli | **REFUTED as predicted** — 0/300 at 256 bits; density ≤2⁻⁶⁴ |
| G | v2-mismatch as a trigger | **REFUTED as a mechanism** — it needs the orders, i.e. needs factoring first. Confirms Stange T7. |

Candidate A is the only positive and it is a *negative for a hypothesis we had
listed as untested*. I verified its control independently (`A2_control_and_seed2.py`,
seed 7): pb=64 → 31/32 at the wall, pb=42 → 13 works / 14, 20, 21 fail. Prediction
A (`β²·log2N`) matches; prediction B is refuted by 8× in the unknown-bit budget.

## What the round actually produced

**No new factoring algorithm. No exponent improved.** What it produced:

1. **A vacuous-evidence finding** that retroactively weakens r110's headline and
   every n=200 experiment in r111/r112 — the most useful thing here, because it
   invalidates a result I was about to build on.
2. **Two self-corrections** (the "shape is wrong" claim; the "t=ceil" recipe).
3. **A killed standing result** (Stange's 75% is the classical 20/27).
4. **A closed hypothesis** (unbalanced RSA is not easier).
5. **A located α-transition** (0.15→0.17 lattice decay, caveated).

## The honest methodological summary

This round found **nine** instances of confident-wrong measurement — two broken
feasibility probes, a `g`-mismatch, four underpowered seed counts, a
`M^m·N1^t` vs `M^m·p1^t` modulus error, a misattributed `27/28`, and the n=200
triviality. Every one was caught only by adding a control or an independent
re-measurement. The campaign's kill-is-success discipline worked exactly as
designed — but the thing it caught most often was **me**, not the mathematics.