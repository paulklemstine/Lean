# Round 54 — the decisive integer is not one integer

**2026-10-05. NO new factoring algorithm. Round 60's "single question that decides
whether an entire conditional route is alive" is RETIRED AS POSED — because it is
not one question.**

Paper: **`Papers/the_decisive_integer_is_not_one_integer.md`**.
Code: `factor-scratch/r54exp/umw_t/src/` (7 scripts, all seeded, all byte-identical
across two runs; `exp_verify.py` cross-checks every fast routine against brute force).

**Umans–Wang is CONDITIONAL on an unproved number-theoretic conjecture. Nothing here
is an unconditional factoring improvement.** All computation `n ≤ 2²⁷`, locally
generated.

---

## 1. `t` is three quantities, and they disagree

| Reading | Value |
|---|---|
| **`t` over arbitrary rank-2 gaps** | **`Θ(n^{1/3}/log n)`** — construction-exact |
| **`t` over random rank-2 gaps** | **2–3**, flat in `n` over `2¹⁵`–`2³⁰` |
| **`t` over `n`-divisor rank-2 gaps** — what the proof needs | **NOT DETERMINED** |

**So `"t = O(1) ⟹ route dead"` is FALSE as stated.** Rank-2 gaps with `t` as large as
the height budget permits **exist**, and `n^{1/3}/log n ≫ n^{1/6}` by an unbounded
factor.

## 2. The construction, and it is exact

`a₁ = 1`, `a₂ = M − 1` with `M` = product of the `k` smallest band primes. The
difference `(1,1)` gives **`D = 1 + (M−1) = M`**, so **all `k` band primes divide
it**, and `gcd(a₁,a₂) = 1` so nothing is dropped. Hence **`t = k` exactly.**

| `n` | `k` built | `t` measured | `k/n^{1/6}` |
|---|---|---|---|
| 2¹⁵ | 5 | **5** | 0.88 |
| 2¹⁸ | 10 | **10** | 1.25 |
| 2²¹ | 17 | **17** | 1.50 |
| 2²⁴ | 31 | **31** | **1.94** |
| 2²⁷ | 56 | **56** | **2.47** |

**Independently reproduced** by me from the description alone, no reference to the
agent's code: `D = M` exactly and `t = k` at all five sizes.

**Controls:** *positive* — `t ≥ k` in all 12 cells (3 sizes × 4 budget fractions);
*negative* — a random coprime `a₂` gives `t = 2–3` at the same size. So `t` is
**not saturated**; `31` vs `3` at one `n` is the whole point.

## 3. Random gaps look nothing like constructed ones

| `n` | `\|P\|` | `t_max` (random) | `frac t=0` | `frac t≥2` |
|---|---|---|---|---|
| 2²⁴ | 166 | **3** | 0.952 | 0.0010 |
| 2³⁰ | 1062 | **3** | 0.961 | 0.0008 |

**"How big is `t`" has no answer without a quantifier over which gaps.** Anyone
quoting "`t` is small" or "`t` is large" has quoted one reading and not the other.

## 4. ★ The source says this themselves — He–Sahai Remark 4.2, verbatim

> "A difference of two higher-rank generalized arithmetic progressions need not be
> a one-dimensional progression. The decisive step above uses
> `(u + ic) − (u + jc) = (i − j)c`. For a rank-two progression, the corresponding
> difference contains two independent coefficients, and **the at-most-one-
> intersection argument does not follow.**"

**The large-`t` construction is the obstruction they explicitly disclaim** — not a
loophole in their theorem. **Round 58's "the route survives on a knife edge" is
therefore better supported than the programme knew. The knife edge is wide.**

## 5. ⚠️ The honesty gate — where the rescue stops

He–Sahai's Lemma 2.1 needs the **`n`-divisor property** (for all `i ≤ n`, some
`a ∈ A` with `i | a`). **The constructed gap is not one.**

- **`b₀ = 0`:** contains 0, which **Remark 4.1** excludes — *"Allowing zero as a
  witness would make the condition vacuous."* **The exact vacuity trap this
  programme has been burned by before, and it fired here.**
- **`b₀ = 1` (repaired):** still not `n`-divisor. Coverage of `[1,5000]` runs
  **37.24% → 78.74% → 95.50% → 97.46%** at `2¹⁵, 2¹⁸, 2²¹, 2²⁴` — **never 100%.**

**Structural reason:** `A = {1 + i + (M−1)j}` concentrates in multiples of `M`; for
`d` coprime to `M` with `d > 2L`, the box misses it entirely. At `2²⁴`, **4457 of
the first 5000 integers are structurally unreachable.**

## 6. What is NOT determined

**Bounding `t` on `n`-divisor gaps may be no easier than the conjecture it would
settle** — `|A| ≤ n^{2/3}` + `n`-divisor + height `exp(n^{1/3})` **is** the Strong
`(1/3,1/3)` conjecture. **No progress on that is claimed.** Also open: whether such a
gap with large `t` exists; whether `t` is small enough for Round 60's H2 replacement
to bite; anything at RSA scale.

## 7. ⚠️ ERRORS — including one of mine, in my own dispatch

1. **A spectacular false result, caught only by brute force.** An off-by-`(L2−1)`
   index error made `t_max = |P|` on every input. **Nothing in the printed summary
   revealed it.** Caught only by an independent brute-force verifier.
   *A result that looks too good and that no control ever contradicts is the
   signature of a broken instrument, not a discovery.*
2. **A float round-trip destroyed an exact integer** (`M = round(exp(log M))`
   corrupts `M ~ e^{246}`). **Second time this project a float round-trip has broken
   an exact integer.**
3. **★★ MY OWN TASK BRIEF CONTAINED TWO FABRICATED arXiv IDs.** I wrote
   `2210.05496` (Umans–Wang) and `2210.03661` (He–Sahai). **Both are real papers and
   neither is about factoring** — they are *"Experiment Design for Identification of
   Marine Models"* and *"Inertia constants for individual power plants"*, both
   `eess.SY`. **The subagent fetched all four, found two off-discipline, and reported
   it rather than working around it.** **The correct IDs — `2608.06681`, `2511.10851`
   — were already in this programme's own Round 58 note. I should have grepped instead
   of typing from memory.** This is the fabricated-citation failure arriving through
   the prompt, and **I wrote the prompt.**
4. **A specific prediction was wrong** (`t_max ∈ [4,7]`, measured 3).
5. **★ FOUND BY ME: the §1 size-bound table was wrong.** It reported
   `log2(n^{1/3}/log n)` as if it were `t`. **`t` is a count, not a bit-length** — at
   `n = 2²⁰⁴⁸` the bound's base-2 logarithm is ≈ `4.5 × 10⁹⁴`, not `673`. **The error
   UNDERSTATED the bound by tens of orders of magnitude, so the conclusion survives
   and is stronger than reported.**

## 8. What this changes

**Round 60's question should be retired as posed** — not answered, but **not one
question.** **Round 58's knife edge is wider than recorded.** And a **negative
contribution to round 53's own target list:** one of the two integers it nominated as
highest-value is **the same difficulty as the open conjecture behind it.**