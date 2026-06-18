# Future Directions: Discrete Information Theory and the Entropy Method

## Synthesis of this cycle

This cycle established a clean, measure-theory-free core of discrete information
theory and used it as a bridge into additive combinatorics. Two Lean files were
produced, both proven with `sorry = 0` and depending only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

- `MachineLearning/InfoTheory/Divergence.lean`
  - `kl_pointwise` / `kl_pointwise_strict`: the scalar Gibbs slack
    `a - b ≤ a·log(a/b)` and its strict refinement when `a ≠ b`.
  - `kl_nonneg`: **Gibbs' inequality** `KL(p‖q) ≥ 0` for discrete probability
    vectors.
  - `kl_eq_zero_iff`: the **sharp equality case** `KL(p‖q) = 0 ↔ p = q on s`.
  - `entropy_le_log_card`: the **maximum-entropy theorem** `H(p) ≤ log|s|`,
    obtained as a one-line corollary by comparing `p` against the uniform law.

- `MachineLearning/InfoTheory/SumsetEntropy.lean`
  - `shannonEntropy_uniform`: the maximum-entropy bound is **tight** — the
    uniform distribution has entropy exactly `log|s|`.
  - `sumset_entropy_lower_bound`: an **entropic discrete Brunn–Minkowski
    inequality** `log(|A|+|B|-1) ≤ H(uniform on A+B)` for finite `A, B ⊆ ℤ`,
    combining the tightness result with Mathlib's additive Cauchy–Davenport bound.

The unifying mechanism is that a single elementary scalar inequality,
`log t ≤ t - 1`, lifted pointwise and summed, controls nonnegativity, the
equality case, and (via the uniform comparison) the maximum-entropy theorem;
the equality case then makes `log` of a cardinality literally an entropy, which
is exactly what lets a combinatorial sumset bound be read information-theoretically.

## Research directions

### 1. Pinsker's inequality from the same scalar engine
The natural quantitative strengthening of `kl_nonneg` is Pinsker's inequality
`KL(p‖q) ≥ (1/2)·‖p − q‖₁²`, turning the qualitative gap `KL = 0 ↔ p = q` into a
stability estimate. The key insight is that the per-coordinate Gibbs slack
`a·log(a/b) − (a − b)` is bounded below by `(3/(a+2b))·(a−b)²/2`-type quadratics,
so summing a pointwise quadratic lower bound and applying Cauchy–Schwarz against
the L¹ norm yields the global inequality without any new analytic input.
**Why now?** `kl_pointwise` already isolates the exact scalar quantity to be
lower-bounded; only an elementary one-variable quadratic estimate (provable by
`nlinarith`/`polyrith`) needs to be added, after which the summation pattern is
identical to `kl_nonneg`.

### 2. Subadditivity of entropy and the entropic data-processing bound
The next structural theorem is subadditivity: for a joint law `r` on a product
`s × t` with marginals `p, q`, `H(r) ≤ H(p) + H(q)`, with equality iff `r` is a
product. The key insight is that the mutual information `I = H(p)+H(q)−H(r)` is a
KL divergence `KL(r ‖ p⊗q)`, so it is `≥ 0` by `kl_nonneg` and `= 0` iff
independence by `kl_eq_zero_iff` — both theorems apply verbatim to the product
index set. **Why now?** Both ingredients already exist in `Divergence.lean`; the
only new work is the bookkeeping identity `I = KL(r ‖ p⊗q)`, which is a finite
`Finset.sum_product` rearrangement.

### 3. A sharp entropic Cauchy–Davenport / equality classification over ℤ
`sumset_entropy_lower_bound` gives `log(|A|+|B|-1) ≤ H(uniform on A+B)`; the
falsifiable refinement is the equality classification: equality holds iff `A`
and `B` are arithmetic progressions with the same common difference. The key
insight is that the entropy gap `H(uniform on A+B) − log(|A|+|B|-1)` equals
`log(|A+B|/(|A|+|B|-1))`, so the entropic equality case is *exactly* the
combinatorial equality case of Cauchy–Davenport, which is already a known rigid
structure theorem. **Why now?** The reduction to a pure cardinality equality is
immediate from `shannonEntropy_uniform`, isolating a self-contained finite
combinatorics lemma about when `|A+B| = |A|+|B|-1` in ℤ.

### 4. Rényi divergence nonnegativity and the entropy ladder
Replace `log t` by the power means underlying Rényi divergence
`D_α(p‖q) = (1/(α−1))·log ∑ p^α q^{1−α}` and prove `D_α ≥ 0` for `α ∈ (0,1)∪(1,∞)`,
recovering `kl_nonneg` as the `α → 1` limit. The key insight is that the single
convexity fact powering `kl_pointwise` (`log t ≤ t − 1`) generalizes to Jensen
for the strictly convex/concave map `t ↦ t^α`, so the entire pointwise-then-sum
architecture transfers with `inner_le_nnorm`-style Hölder bounds already in
Mathlib. **Why now?** Rényi divergence is a finite sum of powers — no logs of
sums of measures — making it more elementary to formalize than the continuous
theory, and the `α=2` (collision) case reduces to a `nlinarith`-friendly
quadratic that can validate the framework before the general `α`.

### 5. The uniform law as the unique entropy maximizer
`entropy_le_log_card` proves the bound and `shannonEntropy_uniform` proves it is
attained; the missing piece is **uniqueness**: `H(p) = log|s|` forces
`p = uniformDist s`. The key insight is that `log|s| − H(p) = KL(p ‖ uniform)`
exactly, so the uniqueness of the maximizer is *literally* the equality case
`kl_eq_zero_iff` specialized to the uniform comparison distribution — no new
inequality is needed. **Why now?** Every component (the KL identity for the gap,
the equality characterization) is already proven in this cycle; assembling them
gives a complete `H(p) = log|s| ↔ p = uniformDist s` characterization, closing
the maximum-entropy story.
