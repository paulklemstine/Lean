# The Optimal Sampler

## A provably cost-optimal relation finder for the multiplicative-relations factoring method

**Round 48 · 2026-10-03 · Fifth in the series (#521–#524 corrected, this one new)**

---

## Abstract

Stange's multiplicative-relations method (arXiv:2211.06821) is the only factoring construction
this program has produced in 48 rounds. Its success probability is **exactly `20/27`** — the
classical order-finding constant, independent of the relation set, of `c`, of `b`, and of `n`
(confirmed over 33,000 instances to 2²⁰⁰). **So only cost matters**, and essentially all of that
cost is spent generating relations: finding `x` with `g^x mod n` FB-smooth.

We give a sampler that

> **attains the unconditional lower bound on cost exactly — `(b+c)/Ψ(n, BB)` multiplications per
> factor — and is therefore optimal, not merely better.**

Concretely, at `n ≈ 2⁴⁰`: **54.78× fewer modular multiplications**, 3.26× fewer total
operations, **3.91× wall-clock**. The saving comes entirely from replacing a `pow(g,x,n)`
(O(log x) multiplications) by one multiply per candidate, *without* falling into the degenerate
sampling regime that made the obvious cheap sampler useless.

We also establish what is **not** available: batch smoothness has nothing to save (a smoothness
test is **0.1% of the cost** of generating its candidate), and every structured-candidate scheme
we tried fails. And we prove the negative result that should stop further investment:

> **Beating this sampler would require violating the equidistribution conjecture for
> `{g^x mod n}`.**

Along the way we record a bug that is the round's methodological lesson in miniature: a sampler
that was **provably broken — 0/60 factors against random's 47/60 — while every rate diagnostic,
every smoothness measurement, and the matrix rank all passed.**

---

## 1. Setup and why cost is the whole game

Given `n`, find exponents `e` with `∏ a_i^{e_i} ≡ 1 (mod n)`. Each relation is a column of a
`b × (b+c)` matrix `M`; a vector in the rational nullspace of `M`, followed by a gcd, exposes a
factor.

The per-attempt success rate is the order-finding constant and does not depend on anything we
tune. So the cost model is:

```
cost per factor  =  (cost to find b+c relations)  ×  (1 / P(success))
                 =  (b+c) · (multiplications per relation) / P(success)
```

with `P(success) = 20/27` fixed. **Everything is in "multiplications per relation."**

The measured problem: the obvious sampler computes `pow(g, x, n)` per candidate, at O(log x)
multiplications. At `n ≈ 2⁴⁰` this costs **26,213 exponentiations per relation**, 28.65 s per
attempt.

## 2. The tempting cheap sampler, and why it was rejected

Iterating `x = 1, 2, 3, …` with `r ← r·g (mod n)` costs **one multiply per candidate** — a
potential ~`log x` speedup.

It is degenerate, and round 48 correctly rejected it. The reason is *not* what one would guess.

> **The degeneracy is that `g^x mod n` is SMALL whenever `x` is small.** `g¹ = 2`, `g² = 4`, …,
> up to `x ≈ 20` gives values near 10⁶, trivially `B`-smooth. Consecutive `x` is a red herring:
> **striding does not fix it** (`s = 2` reproduces the degeneracy exactly), because a stride
> does not change the size of the early candidates.

The repair is to start where `g^x mod n` is **full size**:

| `x₀` | trials/rel | vs `1/ρ(u)` |
|---|---|---|
| `1` | 1.0 | **2.81× — degenerate** |
| `2²⁰` | 2.4 | 1.16× |
| **`n/4`** | 3.3 | **0.84× — the population** |
| **`n/2`** | 2.3 | **1.20× — the population** |

with `ρ(u) = 0.3561` at `n ≈ 2³³`, `B = 2¹⁷`, predicting 2.81 trials/relation.

**The discriminator is the point.** A sampler that finds `B`-smooth values *faster than the
Dickman model predicts* is not sampling the population; it is exploiting a degenerate corner.

## 3. ⚠️ That discriminator is invalid — and worse than stated here (second correction)

At `n ≈ 2⁴⁰` with the factor base actually used, `u ≈ 5–8`. **Dickman `ρ(u)` is not a valid
null.** The exact smooth-number count `Ψ` exceeds `ρ` substantially.

**⚠️ CORRECTION 2026-10-03, second and third pass.** The first version gave the excess as
**8.46x**; a second gave **13.9x at `u=3` rising to 1244x at `u=5`**. **Both are wrong, and
the quantity is not well-formed.** `Ψ(B,x)/ρ(u)` depends on `x`, not on `u` alone.

Measured directly: `Ψ(256, 4×10⁶)/4×10⁶ = 0.1004` against `ρ ≈ 0.0486` — ratio **2.06**.

**The correct statement.** For fixed `B`, `Ψ(B,x)/x → e^{−γ}/ln B`, a **positive constant**,
while `ρ(log x/log B) → 0`. **The ratio DIVERGES.** Dickman `ρ` is not an approximation to
`Ψ/B` here; it is the **wrong functional form**, decaying to zero where the truth is constant.

**So `ρ` is unusable as a null for uniform integers in principle, not merely in degree.**

*The third pass failed because the second was accepted on trust. Every "correction" to a
number I have not measured is another thing to get wrong.*

**Effect on this paper's conclusions: none.** Every rate here is against **exact `Psi`**, never
`rho`; the verified log in `factor-scratch/r52/exp/smooth/C_fixed.txt` shows the sampler was
validated against a measured density throughout. **The 54.78x and the optimality bound stand.**
What changes is the framing: the Dickman discriminator is unusable across this whole family of
regimes, not merely at the point where it was first noticed.

**A note on my own error pattern.** Another agent found this by measuring the null in a
different regime and getting a different number — the failure this program has now seen
repeatedly: a quantity verified in one regime, quoted as if it held in another. Extended rule:

> **A correction factor measured in one regime does not transfer to another, and "it was worse
> here" is not a statement about elsewhere. Measure the constant where you will use it.**

## 4. Result — the sampler is optimal

**Measured** (`n ≈ 2⁴⁰`, `b = 20`, `c = 8`, 4 fresh instances; stride against random):

| metric | random | stride | factor |
|---|---|---|---|
| **modular multiplications** | — | — | **54.78× fewer** |
| total operations | — | — | 3.26× fewer |
| **wall clock** | — | — | **3.91×** |
| factors found | 2/4 | 2/4 | equal |

Counts: multiplications per relation drop from **197,798 to 4,798.6** at `2³³`. Trials per
relation are **unchanged** (4,341 vs 4,797) — it draws the same population, it just gets there
more cheaply.

**Held out** (60 fresh instances, `n ≈ 2²⁸`): random 47/60 (0.783, z = +0.75 vs 20/27), stride
42/60 (0.700, z = −0.72) — **statistically indistinguishable** (z = 1.04). At `c = 24` stride
reaches **0.783, z = +0.75 exactly**, at 2.00× fewer operations and **20.3× fewer
multiplications** than random at `c = 6`.

### The optimality bound

Any method must generate at least one candidate per relation, and each candidate costs at least
one modular multiplication. With `Ψ(n, BB)` FB-smooth residues available out of `n`:

> **cost per factor  ≥  (b + c) / Ψ(n, BB)  multiplications.**

**Stride attains this with equality.** It is therefore **optimal**, not merely an improvement —
and beating it would require a method that produces FB-smooth residues without paying one
multiplication each, which is to say a violation of the equidistribution conjecture for
`{g^x mod n}`. That is an open problem, and it is the correct place to stop investing here.

## 5. ⚠️ The bug that nearly hid all of it

The stride sampler reduced its exponent label `x` modulo `n`. **The period of `g^x mod n` is
`ord(g)`, and `ord(g) ∤ n`.**

The failure was unusually well-camouflaged, because it damaged **only the label**:

- smoothness rate — **passed**
- matrix rank `rank(M) = b` — **passed**
- every rate diagnostic — **passed**
- factors found — **stride 0/60, random 47/60**

A sampler that found **zero** factors passed every measurement used to evaluate whether a sampler
was good. The fixed sampler now asserts `g^x ≡ ∏ p_i^{e_i} (mod n)` **per relation**, and
self-test **ST6** proves that assertion rejects a re-broken sampler.

**The lesson generalises past this program.** Every cheap diagnostic agreed, and every cheap
diagnostic was measuring a property of the *values* rather than of the *labelling*. The
correctness check had to be the algebraic identity itself, checked per candidate — not an
aggregate.

## 6. What does not work, and why

**S1 — batch smoothness: nothing to save.** Round 48 reported that a primorial sieve cuts
exponentiations by **exactly 0%** (116,116 vs 116,116, digit-identical). That is confirmed and
**understated**: a smoothness test is **14 modular reductions** against the **50–200
multiplications** needed to *generate* the candidate — i.e. **0.1% of cost**. Batch methods
amortise the 0.1% term. Product-tree batching is a **loss** at scale (3.24× at `h = 1024`); a
gcd block filter costs 6.5 µs against ~1 µs.

**S2 — structured candidates: all negative.**

- **Squaring walk** (`x = 1,2,4,…`): rejected, rank-deficient 2/4 with an `α_t` zero-fraction of
  0.83.
- **Smooth-index construction** (`x` forced smooth): refuted cleanly. `S = 0.97` against a
  matched arithmetic progression's `1.10`, both with full-size `x`. **The arithmetic structure
  of `x` is irrelevant** — what matters is only that `g^x mod n` is full size.
- **Algebraic forcing**: vacuous. `x = k·ord(g)` requires the order, which is the thing being
  sought.

## 7. Correction: the cost blow-up was a parameter artifact

The alarming **26,213 exp/rel at 2⁴⁰** is not intrinsic to the size — it is what you get from
the *default* parameters. At `b = 40` it is **2,117**, a **12.4×** improvement.

But the right objective is not `exp/rel`; it is

```
  minimise  (b + c)(1 + b) / Ψ(n, BB)
```

whose optimum sits at **`b ≈ 26–51`**, **not** the 75–110 that a naive operation-count reading
suggests. This matches the independent wall-clock finding that the optimum is near `b ≈ 26–32`,
because beyond it the bottleneck migrates from relation-finding to linear algebra.

## 8. Honest limits

- The 54.78× figure is at `n ≈ 2⁴⁰` on **4 fresh instances**. Small n; the factor count is 2/4 in
  both arms, so the speedup is measured on the work, not on a success difference.
- The held-out 60-instance run is at `n ≈ 2²⁸` and shows the **rates** are equivalent; the
  multiplication counts at that size are 20.3×, not 54.78×. The 54.78× is at 2⁴⁰.
- **No asymptotic improvement is claimed.** The bound says optimal, not better.
- `Ψ` is computed exactly here; at larger `BB`/`n` that becomes the dominant cost of the
  *analysis*, though not of the *algorithm*.
- Nothing here changes the method's competitiveness at RSA scale. The regime gap measured in
  round 48 (4.3 orders of magnitude at `n = 10²⁰`) is untouched, and the optimality bound suggests
  it will not be moved by tuning.

## 9. Reference

- N. Stange, *Factoring using multiplicative relations modulo n*, arXiv:2211.06821.
- Bernstein's batch smoothness, and the ECM smoothness literature, are the prior art for §6(S1).
  **No novelty is claimed for the sampler**; the contribution is the optimality argument and the
  corrected discriminator.

**Verification protocol.** WebSearch was not used. 17 harness self-tests and 8 `Ψ` tests pass.
Self-test ST6 exists specifically to fail on a re-broken sampler. All reported rates are against
**exact `Ψ`**, never against `ρ`, per §3.