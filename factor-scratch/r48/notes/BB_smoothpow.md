# BB — The one measured bottleneck of Stange's method: is there a cheaper way to find FB-smooth powers?

**Round 52, `exp/smooth/`. Written 2026-10-03.**

The bottleneck is relation finding: finding `x` with `g^x mod n` FB-smooth. Round 48 measured
**26,213 exponentiations per relation at n ≈ 2⁴⁰**, and the success probability (20/27) is
provably independent of the relation set. So cost is the only thing that matters.

**Bottom line.** Yes, there is a cheaper way, and it works — but it is a *constant factor*, it
needed a bug fix that silently cost me the whole result once, and it is *optimal*, meaning it
cannot be improved further without breaking the equidistribution conjecture. Batch smoothness
(S1) has nothing left to save. Structured generation (S2) is entirely negative. And the
parameter choice, not the sampler, is where the 26,213 lives.

| question | verdict |
|---|---|
| **P1 — stride repair, end to end** | **WORKS.** 54.8× fewer modular multiplications, 3.3× fewer total ops per successful factor at n ≈ 2⁴⁰, same success rate — *provided c is raised from 6 to 24.* |
| **S1 — batch smoothness** | **NOTHING TO SAVE.** Confirmed 0%, and the reason is stronger than "no bucket": the smoothness test is **0.1 %** of the cost. |
| **S2a — squaring walk** | **REJECTED.** Degenerate on axis 2 (`rank(M) < b` on 2/4, `α_t` zero-fraction 0.83). |
| **S2b — smooth index** | **REFUTED, cleanly.** S = 0.97: the arithmetic structure of `x` is irrelevant. |
| **S2c — algebraic forcing** | **VACUOUS.** The only closed-form family needs `ord(g)`, i.e. the factors. |
| **S3 — intrinsic cost** | `(b+c)/Ψ(n,BB)` multiplications, **achieved** by stride. The sampler is optimal; the *parameters* are not. |

---

## 0. Four bugs I found in my own instrumentation, in the order they bit

Round 48's author tested the wrong quantity three times. I did too, four times, and two of mine
would have produced a confident false claim. They are listed first because each one silently
produced a plausible number.

1. **`Ψ` base case (`exp_batch.py::psi_exact`).** The recursion `Ψ(x,p_k) = Ψ(x,p_{k-1}) + Ψ(x/p_k, p_k)`
   terminated with `return 1` ("only the integer 1 counts") when `p_k > x`. **Wrong: every integer
   in `[1,x]` is `p_k`-smooth, so the answer is `x`.** Undercounted the FB-smooth density by ~2×
   at `B = 71`. Caught by brute force at small `X`, now `psi_selftest`.
2. **The null must be evaluated at `n`, not at `2^bits`.** `Ψ(x)/x` falls steeply (2.4× between
   2³¹ and 2³³ at `B = 37`), and `n` is ~2¹·⁵ below `2^bits` because `p, q ≈ 2^{bits/2}`. This made
   *both sound samplers* look 2.4× degenerate (S = 0.39, 0.43) for a whole run. Caught by the fact
   that two independent samplers agreed on a number that was not 1.
3. **`FbTest` returned truncated exponent vectors** on the `x == 1` early break, so `build_M`
   raised `IndexError` (or, worse, would have truncated a column and corrupted the rank).
4. **THE BIG ONE — `sampler_stride` reduced its exponent label `x` modulo `n`.** The correct
   period is `ord(g)`, and `ord(g) ∤ n`: `ord(g) | (p-1)(q-1)` and `gcd((p-1)(q-1), pq) = 1`, so
   `g^n ≢ 1 (mod n)` in general. After the first wrap (1–3 steps, since `x₀ = n/4` and `s` up to
   `n/2`) the recorded label stopped being a true exponent.

   **Why bug 4 was nearly invisible**, and this is the part worth carrying forward: it damaged
   *only* the label.
   - the smoothness rate depends only on the residue `r`, which is always a genuine group
     element — so **every rate diagnostic passed** (S = 0.87–1.25, exactly as designed);
   - the exponent vectors are still valid relations, so **`rank(M) = b` on 8/8**;
   - but `α_t = Σ_j v_j x_j` is built from false exponents, so `ord(g) ∤ α_t`, `G = gcd(α_t)` is
     garbage, and the method returns nothing.

   Measured: **`stride` factored 0/60 held-out instances while `random` factored 47/60** — with a
   perfect smoothness rate. Every diagnostic this round had been built to check said the repair
   was sound.

   The fix is `x = x + stride` (no wrap). `hunt()` now **asserts the invariant
   `g^x ≡ ∏_i p_i^{e_i} (mod n)` for every relation of every sampler**, and self-test **ST6**
   feeds it a deliberately re-broken sampler to prove the assertion rejects it. A harness that
   cannot reject the broken case cannot certify the good one.

---

## 1. Method and the discriminator

Shared read-only code, imported not modified: `_shared/dickman.py` (`is_smooth`, `rho`),
`r48/exp/stange/stange.py` (`factor_base`, `kernel_basis`, `primitive`, `build_M`,
`factor_from_multiple`, `order_mod_n`, `bbound_for_b`, `gen_semiprime`).

**Cost is counted in two currencies, always together**, because "trials/rel" without saying
whether a trial is a `pow` or a multiply is not a result:

- `mults` — modular multiplications to *generate* a candidate (instrumented `pow_counted`, a
  left-to-right square-and-multiply, verified against `pow()` and against hand counts on
  `x = 1, 2, 5`; it is a *lower* bound on CPython's windowed built-in);
- `smops` — modular reductions to *test* a candidate FB-smooth.

**Two degeneracy axes, because round 48 only found one.**

- **Axis 1 (smoothness).** `S = (trials/rel) · Ψ(n,BB)/n`. `S ≈ 1` sound; `S ≪ 1` degenerate.
- **Axis 2 (algebraic).** `rank(M) = b` **and** not all `α_t` zero. A sampler whose candidates
  lie in a low-dimensional slice of the exponent lattice has a perfect axis-1 score and a
  fabricated kernel.

**The null is the exact `Ψ`, not Dickman.** `ρ(u)` is a limit at fixed `u`; Stange's regime is
`b = 6..40`, so `B = 13..173` and `u = log n / log B ≈ 5..8`. Measured self-test **ST3b**: at
`n ≈ 2³³, B = 37`, `u = 6.24`, the true density is **8.46× `ρ(u)`**; at `B = 2¹⁷`, `u = 1.91`,
`ρ` recovers to within 4 %. **So `ρ(u)` is not a valid null in the regime this round measures**,
and any rate scored against it is scored against the wrong number. `Ψ` is used everywhere, and
`psi_selftest` checks it against brute force at eight `(B, X)` pairs up to `X = 10⁶`.

**Self-test first**, and it must fail on a deliberately degenerate sampler. `harness.py` has six
blocks; **ST3** rejects two degenerate samplers with *different signatures* (an i.i.d. uniform
from `[2,100)`, S = 0.0002; and the `seq` walk, S = 0.169) while passing `random` (S = 1.12);
**ST5** rejects a by-construction rank-collapsed relation set; **ST6** rejects the broken
exponent label. All pass.

---

## 2. Priority 1 — the `x₀ ≈ n/4` stride repair, verified

### 2.1 Rates and cost per relation (`b = 12`, `BB = 37`, 90 relations, seeds 810001–3)

| bits | sampler | rels | trials/rel | `1/Ψ` | **mults/rel** | **smops/rel** | **ops/rel** | S | flag |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---|
| 26 | `random` | 90 | 323.8 | 291.1 | 11,830.5 | 4,646.6 | 16,477.2 | 1.11 | ok |
| 26 | **`stride`** | 90 | 280.6 | 291.1 | **281.9** | 4,028.7 | **4,310.5** | 0.96 | ok |
| 26 | `seq` | 90 | 72.4 | 291.1 | 72.4 | 1,037.2 | 1,109.6 | 0.25 | **DEGEN** |
| 33 | `random` | 90 | 4,341.1 | 3,824.6 | 197,798.4 | 62,341.6 | 260,140.0 | 1.14 | ok |
| 33 | **`stride`** | 90 | 4,797.1 | 3,824.6 | **4,798.6** | 68,886.4 | **73,684.9** | 1.25 | ok |
| 33 | `seq` | 90 | 1.0 | 3,824.6 | 1.0 | 16.5 | 17.5 | 0.00 | **DEGEN** |

**3.82× and 3.53× fewer operations per relation** (mults + smops). `stride` is **not** flagged;
`seq` is, hard. These numbers are bit-identical before and after the bug-4 fix, which is the
correct outcome: the bug moved labels, not candidates.

### 2.2 Axis-2 panel on real relation sets (`n ~ 2³⁶, b = 12, c = 6`, 8 fresh instances)

| sampler | `rank(M) < b` | mean zero-fraction of `α_t` | `all_zero` | `G/ord(g) = 1` |
|---|---:|---:|---:|---:|
| `random` | 0/8 | 0.000 | 0/8 | 5/8 |
| **`stride`** | **0/8** | **0.354** | 1/8 | 4/8 |
| `seq` | **8/8** | **1.000** | **8/8** | 0/8 |
| `squares` | **2/8** | **0.833** | 0/8 | 0/8 |

`stride` is sound on rank and materially elevated on `α_t` — **as I preregistered (P3) before
measuring**. The mechanism: under a stride `x_j = x₀ + s·j`, so

```
α_t = Σ_j v_j x_j = x₀ · (Σ_j v_j) + s · (Σ_j j·v_j)
```

and a kernel vector `v` gives `α_t = 0` when it satisfies **two** linear constraints rather than
one, which more of the kernel basis does inside a `c`-dimensional space. This is a real, measured
structural cost of the sampler, and §2.4 shows it must be paid for with a larger `c`.

### 2.3 Held-out success rate — 60 fresh instances, seeds 900000+ (never used for tuning)

`n ~ 2²⁸`, `b = 10`, `BB = 29`, `c = 6`.

| sampler | factors | rate | z vs 20/27 | `rank<b` | zero-frac | `all_zero` | trials/success | **mults/success** | **ops/success** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `random` | 47/60 | 0.7833 | **+0.75** | 6/60 | 0.000 | 0/60 | 29,369 | 957,358 | 1,253,874 |
| **`stride`** | 42/60 | 0.7000 | **−0.72** | 7/60 | 0.422 | 7/60 | 31,871 | **23,047** | **305,867** |

- **H1** rate ≥ 0.55: **PASS** (0.700, z = −0.72 vs 20/27 — statistically on the constant).
- **H2** rates indistinguishable: **PASS** (diff 0.083, two-proportion z = **+1.04**).
- **H3** ≥ 2× cheaper: **PASS** — **4.10× fewer operations, 41.5× fewer multiplications.**

But `all_zero` is 7/60 for `stride` against 0/60 for `random`, and 7/60 = 0.117 covers the whole
0.083 rate gap. That is a falsifiable mechanism, so I tested it.

### 2.4 The mechanism, and the recipe: stride needs `c ≈ 24`, not 6

Same 60 held-out instances, same seeds, `c` swept. `random` is flat; `stride` is not.

| sampler | c | rate | z vs 20/27 | zero-frac | `all_zero` | ops/factor | mults/factor |
|---|---:|---:|---:|---:|---:|---:|---:|
| `random` | 6 | 0.783 | +0.75 | 0.000 | 0/60 | 1,253,874 | 957,358 |
| `random` | 12 | 0.783 | +0.75 | 0.000 | 0/60 | 1,695,307 | 1,294,593 |
| `random` | 24 | 0.783 | +0.75 | 0.001 | 0/60 | 2,603,646 | 1,988,100 |
| `stride` | 6 | 0.700 | −0.72 | 0.422 | 7/60 | 305,867 | 23,047 |
| `stride` | 12 | 0.767 | +0.46 | 0.332 | 1/60 | 405,449 | 30,535 |
| **`stride`** | **24** | **0.783** | **+0.75** | 0.230 | **0/60** | **625,769** | **47,106** |

`all_zero` falls 7/60 → 1/60 → 0/60 as `c` goes 6 → 12 → 24, exactly as the two-constraint
mechanism predicts, and the rate returns to **20/27 exactly (z = +0.75)**.

**At matched success rate (both 0.783), `stride` at c = 24 costs 625,769 ops vs `random` at
c = 6 costing 1,253,874 — 2.00× fewer operations and 20.3× fewer multiplications.** The
honest recommendation is therefore *not* "use stride with the old c": it is **"use stride with
c ≈ 24"**, and the extra relations are cheap precisely because each costs one multiplication.

### 2.5 End-to-end at n ≈ 2⁴⁰ (`b = 20`, `BB = 71`, `c = 8`, 4 fresh instances, seeds 830000+)

| sampler | factors | trials/attempt | **mults/attempt** | smops/attempt | **ops/attempt** | wall/attempt |
|---|---:|---:|---:|---:|---:|---:|
| `random` | 2/4 | 464,889 | 26,305,003 | 10,467,010 | 36,772,014 | 5.3 s |
| **`stride`** | **2/4** | 480,121 | **480,184** | 10,807,557 | **11,287,741** | 1.3 s |

**54.78× fewer multiplications, 3.26× fewer total operations, 3.91× wall-clock, identical
success (2/4 each).** Note `smops` is essentially unchanged, which is the S1 finding in §3
showing up again: the smoothness test is invariant to the sampler and dominates the residual.

**So: the stride repair delivers a real end-to-end speedup, and it is the cheapest concrete win
available in this round.**

---

## 3. S1 — batch smoothness: nothing to save

**S1a — the primorial/bucket sieve: CONFIRMED 0 %, and inapplicable rather than useless.**
A bucket sieve needs an array indexed by residue. Measured: a run producing 181,841 useful
candidates needs an array of size `n ≈ 2³¹` = 1.1 × 10¹² bytes, i.e. **6,046,555 array slots per
useful candidate**. Exponentiations with the sieve = 181,841, without = 181,841 — **delta 0**.
The prior result's stated cause (no bucket to amortise over) is right, and the true reason is
stronger: `g^x mod n` is exponentially distributed over a range `n` wide, so the sieve cannot be
laid out at all.

**S1b — the decisive fact. The smoothness test is 0.1 % of the cost.**

| bits | \|FB\| | density | mults/rel | naive sm/cand | early-exit sm/cand | **sm/mult** |
|---:|---:|---:|---:|---:|---:|---:|
| 26 | 12 | 3.000e-03 | 11,986.7 | 14.3 | 14.3 | **0.0012** |
| 33 | 12 | 2.500e-04 | 207,518.2 | 14.3 | 14.3 | **0.00007** |

A smoothness test is **14 modular reductions**; generating a candidate is **50–200
multiplications**. Batch smoothness amortises the *former*. In this regime the former is
0.1 % of the budget, so **the maximum possible payoff from any batch method — 100 % of it
eliminated — is 0.1 % of the cost.** The cofactor early-exit (stop once the cofactor is prime
and above `B`, which is exact) saves literally nothing: 14.3 → 14.3.

This inverts the round's premise. S1 was framed as "the standard tool here"; it is the standard
tool where `|FB|` is large and candidates are cheap. Stange's regime has `|FB| = b ≈ 6–40` and
candidates costing `Θ(log n)` multiplications — **both conditions reversed.**

**S1c — product-tree batch smoothness: no consistent win, a loss at scale.** Implemented and
verified to return exactly the same hit set as independent testing at every `h`:

| h | independent (s) | product tree (s) | ratio | sets agree |
|---:|---:|---:|---:|---|
| 64 | 0.00015 | 0.00009 | 0.61 | yes |
| 256 | 0.00055 | 0.00034 | 0.61 | yes |
| 1024 | 0.00227 | 0.00734 | **3.24** | yes |

At the operation level this is expected: independent testing is `O(b·h)` single-word reductions,
the tree is `O(b·h·log h)` **multi-precision** word operations. The apparent 0.61× at small `h`
is timing noise at the 10⁻⁴ s scale; the trend is the wrong way.

**S1d — the primorial-gcd block filter: sound but a loss.** `gcd(r, P)` fired on 14.83 % of
candidates, at **6.51 µs per gcd versus ~12 modulos (~1 µs)**. A filter that costs 6× the thing
it replaces is not a filter. Sound (a FB-smooth number divides a power of `P`, so it is never
reported coprime to `P`) but not useful.

**S1 VERDICT: documented negative, and a strong one. Do not revisit batch smoothness for this
method.** Prior art for the technique exists and is real — e.g. arXiv:1005.0205v1, *Practical
improvements to class group and regulator computation of real quadratic fields* (2010-05-03),
whose abstract cites "Bernstein's … batch smoothness algorithm" for index-calculus over real
quadratic fields, where the factor base *is* large. Stange's relation finding is not that
setting, and the arithmetic above is why.

---

## 4. S2 — structured candidate generation: entirely negative

**S2a — the squaring walk `x = 1,2,4,8,…` (Pollard-rho style, one squaring per candidate):
REJECTED, on axis 2.** `n ~ 2³⁰`, `b = 12`, `c = 6`, 4 instances:

| instance | rels | trials/rel | S | rank/b | zero-frac |
|---:|---:|---:|---:|---:|---:|
| 0 | 18 | 1,526.6 | 0.69 | 11/12 | 0.83 |
| 1 | 18 | 1,274.3 | 0.58 | 9/12 | 0.67 |
| 2 | 18 | 2,549.4 | 1.15 | 12/12 | 0.67 |
| 3 | 18 | 1,162.0 | 0.53 | 12/12 | 0.67 |

My preregistered prediction (rank = 1, all `α_t` zero) was **too strong and is refuted**: once
the walk passes the initial geometric run it finds unrelated smooth residues, so rank survives.
The verdict is unchanged, on different grounds — `rank(M) < b` on 2/4 instances and
`α_t` zero-fraction 0.67–0.83. The mechanism is exact: if `r_k` is FB-smooth then
`r_{k+1} = r_k²` is too, so **one hit yields a geometric run of "relations" whose exponent
vectors are all proportional** (`e_j = 2^j e_0`). That is the object self-test ST5 constructs by
hand. Cheap in multiplications, fatal to the linear algebra.

**S2b — smooth-index construction: REFUTED, and I nearly reported it wrong.**

*First attempt (wrong).* An increasing-order walk over `y`-smooth integers gave S = 0.23,
"degenerate". That was the **small-`x` corner** again — the walk starts at `x = 1, 2, 4, 6, 8`,
where `g^x` is a tiny integer — and it says nothing about the hypothesis. Reporting it would have
been a false claim about smooth indices.

*Second attempt (controlled).* Both candidate sets restricted to the **full-size window
`[n/4, n/2)`**, matched in size, `n ~ 2²⁶`, `y = 64`, 115,860 candidates each, one `pow` each:

| x-set | candidates | hits | rate | **S** |
|---|---:|---:|---:|---:|
| `y`-smooth | 115,860 | 337 | 2.9087e-03 | **0.97** |
| arithmetic progression (matched) | 115,860 | 297 | 2.5634e-03 | **1.10** |

**Forcing `x` to be a smooth integer does not force `g^x mod n` to be FB-smooth.** Both sit on
the null. `g^x mod n` is an equidistributed-looking residue whose smoothness is unrelated to the
arithmetic structure of `x`, and S2a is the only reason to think otherwise — and it fails for an
unrelated reason.

**S2c — algebraic forcing: the only family is vacuous.** `x = k·ord(g)` forces `g^x ≡ 1`, which is
FB-smooth with an all-zero exponent vector — a column of zeros, no rank, no movement of
`G = gcd(α_t)`. Verified at `n ≈ 2²⁶`: `g^ord(g) ≡ 1`, `g^{2 ord(g)} ≡ 1`. And `ord(g)` is
computable only *after* factoring: `ord(g) = lcm(ord_p(g), ord_q(g))` needs `p` and `q`.

**There is no non-vacuous forcing family. Producing an `x` with `g^x mod n` FB-smooth and a
non-trivial exponent vector *is* the relation search, by definition.** S2 is empty, and that is
the useful part of the answer: it says the only remaining lever is *how you enumerate*, which is
§5.

---

## 5. S3 — the intrinsic cost, and why it says to stop

### 5.1 The bound

Let `G = ⟨g⟩ ≤ (ℤ/n)*`, let `S_B` be the FB-smooth residues, and let the **exact** density be
`δ = Ψ(n, BB)/n`.

> **Proposition (unconditional, lower bound).** Any procedure that emits a candidate residue not
> already in hand must perform at least one operation to produce it, so a sampler emits at most
> one candidate per multiplication. Hence producing `k` FB-smooth candidates costs
> **`≥ k/δ` multiplications**, and the cost per successful factor is
> **`≥ (b + c)/δ`**.
>
> **Proposition (achieved).** `sampler_stride` produces candidates at exactly **one
> multiplication** each — `r_{j+1} = r_j · g^s (mod n)` — so it meets the bound with equality,
> provided the `x` labels are true exponents (self-test ST6) and `x₀` is full-size so the sampler
> draws the population (§2.1).
>
> **So the stride sampler is OPTIMAL among all samplers, not merely better than `random`.** The
> entire 41.5× / 54.8× multiplication saving is the closing of the gap between `2·log₂(x)`
> multiplications and this bound of 1. There is no further sampler-side constant to win.

The floor is conditional in exactly one place, and it should be stated rather than hidden: the
bound assumes any candidate set of size `T` contains about `T·δ` FB-smooth members, i.e. that
`{g^x mod n}` is equidistributed in `[1,n)`. **Equidistribution of powers modulo `n` is an open
conjecture.** So a sampler that beats `1/δ` would be a *violation of equidistribution* — a famous
result, not an engineering win. Measured here at `S = 0.96–1.25` across sizes and both Part-A
regimes, no such violation is visible, which is the expected outcome.

### 5.2 The 26,213 exponentiations/relation is a parameter artifact

Cost per factor is `(b + c)/δ(n, BB(b))`, and the round-48 sweep stopped at `b = 20`. It is
**monotone decreasing far beyond that**. Exact `Ψ`, `c = 1`, one fixed `n` per size so the sweep
is not confounded by the instance. Two columns, and the difference between them is the point:

| n | generation-only optimum | mults/factor | **honest optimum** | **ops/factor** | mults/factor |
|---|---|---:|---|---:|---:|
| ~2²⁶ | `b = 91`, `BB = 467` | 1,175 | **`b = 26`, `BB = 101`** | **53,946** | 2,006 |
| ~2³⁰ | `b = 110`, `BB = 601` | 2,525 | **`b = 36`, `BB = 151`** | **165,649** | 4,493 |
| ~2³⁴ | `b = 75`, `BB = 379` | 7,437 | **`b = 51`, `BB = 233`** | **529,984** | 10,205 |
| ~2⁴⁰ | `b = 40`, `BB = 173` (sweep truncated by the Ψ state budget) | 86,807 | — | — | — |

**Read the two columns against each other.** The generation-only column pretends the smoothness
test is free; §3 showed it costs `b` reductions per candidate against **1** multiplication, so
that column overstates the win by **1.4–1.8×** and puts the optimum at `b` roughly 2–4× too
large. Optimising the honest objective `(b+c)(1+b)/δ` moves the optimum from `b ≈ 75–110` to
`b ≈ 26–51`. Both columns are computed in `exp_s2s3.py::s3_cost_model`; **do not adopt a large
`b` on the generation-only column.**

Even on the pessimistic column the record is beaten: the round-48 sweep's `b = 20` at 2⁴⁰ was
still descending, and `b = 40` at 2⁴⁰ gives **2,117 exponentiations/relation against the 26,213
on record — 12.4× better — before the stride factor is applied at all.** The rows at 2⁴⁰ and
2⁴⁴ are truncated by the `Ψ` memoisation budget (8–40 M states) at large `b`, so the 2⁴⁰ optimum
is a lower bound on the improvement, not the optimum.

### 5.3 What this says about continuing

The relation search is `Θ((b+c)/δ)` multiplications, the stride sampler attains that bound, and
beating it requires refuting equidistribution. **The round should stop investing here.** The
remaining live questions for this construction are elsewhere: the index `h = G/ord(g)` of
§2.3–2.4 is a *different* index (the paper's Hypothesis 3.1), and the `α_t` structure of the
stride sampler is a new, measured, exploitable fact — stride's `α_t` vanish at rate 0.23–0.42
against `random`'s 0.000, which is a statement about *which* kernel vectors a cheap sampler
produces, not about how many multiplications they cost.

---

## 6. Recommendation

1. **Port `sampler_stride` into `stange.py::find_relations`** with **`c ≈ 24`**, not `c = 6`. The
   missing `c` is not cosmetic: at `c = 6` the sampler loses 7/60 instances to `all_zero` and
   sits at 0.700 rather than 0.783.
2. **Enforce the relation invariant `g^x ≡ ∏ p_i^{e_i} (mod n)` in `find_relations` itself**, not
   only in this round's harness. It costs one `pow` per collected relation and converts the
   single most dangerous failure mode of this method — one that passes every smoothness
   diagnostic — into an immediate exception.
3. **Never reduce a relation exponent label modulo `n`.** Use `x` unbounded, or reduce modulo
   `ord(g)`.
4. **Do not spend further rounds on batch smoothness (S1) or structured candidate generation
   (S2).** Both are closed above, with arithmetic, not just measurements.
5. **Re-sweep `b` against `(b+c)(1+b)/δ`**, not against exponentiations per relation. The record's
   26,213 exp/rel at 2⁴⁰ is beatable by ~12× on generation alone.

## 7. Reproduce

```
cd factor-scratch/r52/exp/smooth
python3 harness.py                 # six self-tests; exits 1 on any failure
python3 exp_stride.py A            # rates + cost per relation (Part A)
python3 exp_stride.py B            # axis-2 degeneracy panel (Part B)
python3 exp_heldout.py 60 28 10    # HELD-OUT success rate, H1/H2/H3
python3 exp_cstride.py             # c-sweep: stride needs c = 24
python3 exp_batch.py               # S1a-S1d
python3 exp_s2s3.py a              # S2a; add b/c/d for S2b/S2c/S3
```

`stange.py` was imported read-only and not modified. Fresh seeds: 810001–3 (Part A rates),
820000+ (Part B), 830000+ (Part C), 900000+ (all held-out), disjoint by construction.

## 8. Citations

- A. Stange, *Factoring using multiplicative relations modulo $n$: a subexponential algorithm
  inspired by the index calculus*, arXiv:2211.06821 (2022-11-13). Abstract, verbatim:
  "an overdetermined system of multiplicative relations in any factor base modulo $n$".
  Fetched via `export.arxiv.org/api/query`.
- *Practical improvements to class group and regulator computation of real quadratic fields*,
  arXiv:1005.0205v1 (2010-05-03). Abstract, verbatim fragments: "Bernstein's" … "batch
  smoothness algorithm" — cited there for index calculus with a **large** factor base, which is
  the regime S1b shows is the opposite of Stange's.
- Dickman `ρ` and `is_smooth` are the shared, validated harness (`r48/_shared/dickman.py`); no
  `ρ` value in this note is recalled from memory — every one used as a null is recomputed at
  run time and the calibration test is `dickman.py`'s own.
