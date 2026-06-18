# A Self-Contained Formalization of Empirical Rademacher Complexity for Finite Hypothesis Classes

## Abstract

We present a complete and elementary theory of the **empirical Rademacher
complexity** of a finite hypothesis class, developed under a minimal
"behavior-on-the-sample" representation in which each hypothesis is identified
with the vector of its outputs on the `n` sample points. Under this
representation a hypothesis class is a finite subset `F ⊆ ℝⁿ`, and the empirical
Rademacher complexity is the finite average, over all `2ⁿ` sign patterns
`σ ∈ {±1}ⁿ`, of the best correlation `sup_{v∈F} ⟨σ, v⟩`. We prove that this
quantity is governed entirely by a single combinatorial cancellation lemma:
the Rademacher signs at any fixed coordinate sum to zero over all sign patterns.
From this seed we derive that a singleton class has complexity exactly zero, that
containment of the zero hypothesis implies nonnegativity, that the complexity is
monotone under class inclusion, and that it admits the trivial uniform upper
bound `B` for `B`-bounded classes. We discuss the algorithmic content of these
results (the quantity is exactly computable in `O(2ⁿ · |F| · n)` time), give
worked numerical examples, and identify the Massart finite-class refinement —
which improves the uniform bound by a `√(log|F|/n)` factor — as the principal
open direction requiring sub-Gaussian concentration arguments beyond the present
order-theoretic toolkit.

**Keywords.** Rademacher complexity, statistical learning theory,
generalization, hypothesis class, sign patterns, formal verification.

---

## 1. Introduction

The central question of statistical learning theory is *generalization*: why does
a model that fits a finite training sample also perform well on unseen data? The
modern answer is given by complexity measures of the hypothesis class — quantities
that bound the worst-case gap between empirical and true risk uniformly over a
class. Among these, the **Rademacher complexity** is the most widely used,
because it is data-dependent, distribution-free in its derivation, and tight
enough to yield practical bounds for kernel methods, boosting, and neural
networks.

Informally, the Rademacher complexity of a class measures the extent to which the
class can correlate with random noise. If a learner, free to choose any
hypothesis in its class, can on average align well with random `±1` labelings of
the sample, then the class is "rich" and prone to overfitting; conversely, a
class that cannot fit noise is one whose fit to genuine data is meaningful.

This paper gives a fully rigorous, self-contained account of the *empirical*
Rademacher complexity in the cleanest possible setting: a finite hypothesis class
under the behavior-on-the-sample representation. We make three contributions.

1. **A minimal, computable model.** We represent each hypothesis purely by its
   output vector on the sample, reducing a hypothesis class to a finite subset of
   `ℝⁿ` and the empirical Rademacher complexity to an explicit finite sum. This
   removes all measure-theoretic overhead while remaining faithful to the textbook
   definition.

2. **A single structural engine.** We isolate one combinatorial identity — the
   per-coordinate cancellation of Rademacher signs — and show that every
   elementary property of the complexity reduces to it together with the
   order-theoretic monotonicity of suprema.

3. **A precise frontier.** We state the Massart finite-class refinement as an
   explicit conjecture and explain exactly which analytic ingredient (a
   sub-Gaussian / Hoeffding moment bound) the present development lacks.

---

## 2. Definitions

Throughout, fix a sample size `n : ℕ`. We work over the index set `Fin n`
(the points `0, 1, …, n−1`).

### 2.1 Rademacher signs

**Definition 2.1 (Sign).** For a Boolean `b`, define the *Rademacher sign*
```
sgn(b) = +1   if b = true,
sgn(b) = −1   if b = false.
```
We record the immediate facts `sgn(true) = 1`, `sgn(false) = −1`, the
*flip rule* `sgn(¬b) = −sgn(b)`, and the *unit-magnitude rule* `|sgn(b)| = 1`,
each by case analysis on `b`.

A **sign pattern** is a function `σ : Fin n → Bool`; there are exactly `2ⁿ` of
them. We think of `sgn(σᵢ) ∈ {+1, −1}` as the `i`-th Rademacher random sign.

### 2.2 Correlation

**Definition 2.2 (Correlation).** For a sign pattern `σ : Fin n → Bool` and a
behavior vector `v : Fin n → ℝ`, the *correlation* is
```
corr(σ, v) = Σ_{i ∈ Fin n} sgn(σᵢ) · vᵢ.
```
This is the inner product of the sign vector with `v`. It is large and positive
when `v` aligns coordinate-wise with the signs.

### 2.3 Empirical Rademacher complexity

**Definition 2.3 (Empirical Rademacher complexity).** Let `F ⊆ ℝⁿ` be a nonempty
finite hypothesis class (a `Finset (Fin n → ℝ)` with a nonemptiness witness `hF`).
The *empirical Rademacher complexity* of `F` is
```
empRad(F) = (1 / (2ⁿ · n)) · Σ_{σ : Fin n → Bool}  sup_{v ∈ F} corr(σ, v).
```
The inner `sup_{v∈F}` is the finite supremum (`Finset.sup'`) over the nonempty
class, well defined because `F` is nonempty and finite. The outer sum ranges over
all `2ⁿ` sign patterns, and the normalization `2ⁿ · n` averages over patterns and
per-coordinate.

This matches the standard empirical Rademacher complexity
`𝔼_σ [ sup_{f∈F} (1/n) Σᵢ σᵢ f(xᵢ) ]` once one notes that the expectation over
i.i.d. uniform `σᵢ ∈ {±1}` is exactly the uniform average `(1/2ⁿ) Σ_σ`.

---

## 3. The cancellation engine

Every elementary property below rests on the following identity.

**Lemma 3.1 (Per-coordinate sign cancellation, `signSum_coord_eq_zero`).**
For every coordinate `i : Fin n`,
```
Σ_{σ : Fin n → Bool}  sgn(σᵢ) = 0.
```

*Proof sketch.* Consider the coordinate-flip map
`Φ_i(σ) = update σ i (¬σᵢ)`, which leaves every coordinate of `σ` unchanged
except the `i`-th, which it negates. Applying `Φ_i` twice restores `σ`, so `Φ_i`
is an involution and hence a permutation `e` of the (finite) set of all sign
patterns. Reindexing a sum by a permutation does not change its value, so
```
Σ_σ sgn((e σ)ᵢ) = Σ_σ sgn(σᵢ).
```
But `(e σ)ᵢ = ¬σᵢ`, and by the flip rule `sgn(¬σᵢ) = −sgn(σᵢ)`. Hence the
left-hand side equals `−Σ_σ sgn(σᵢ)`. Writing `S = Σ_σ sgn(σᵢ)`, we obtain
`S = −S`, so `2S = 0` and `S = 0`. ∎

The formal proof packages the involution as `Function.Involutive.toPerm` and
invokes `Equiv.sum_comp` for the reindexing step; the negation is propagated with
`Finset.sum_neg_distrib`, and `linarith` closes `S = −S ⟹ S = 0`. The crucial
modeling choice — pairing patterns by a single coordinate flip — is what makes the
exponential sum collapse to a one-line argument.

---

## 4. Main results

### 4.1 A singleton class has zero complexity

**Theorem 4.1 (`empRad_singleton`).** For any behavior vector `v : Fin n → ℝ`,
```
empRad({v}) = 0.
```

*Proof sketch.* Over a singleton, the supremum is the unique value:
`sup_{w ∈ {v}} corr(σ, w) = corr(σ, v)` (by `Finset.sup'_singleton`). Hence the
numerator is `Σ_σ corr(σ, v) = Σ_σ Σ_i sgn(σᵢ) vᵢ`. Exchanging the two finite
sums (`Finset.sum_comm`) gives `Σ_i ( Σ_σ sgn(σᵢ) ) vᵢ`. By Lemma 3.1 each inner
factor `Σ_σ sgn(σᵢ)` is `0`, so every term vanishes and the numerator is `0`.
Dividing `0` by the denominator yields `empRad({v}) = 0`. ∎

**Interpretation.** Empirical Rademacher complexity measures the *richness of the
class*, not the intrinsic complexity of any single function. An arbitrarily
intricate but *fixed* hypothesis has zero capacity to chase noise on average; the
capacity arises only from the freedom to choose among many hypotheses. The
singleton is the base case of the entire theory.

### 4.2 Nonnegativity under containment of zero

**Theorem 4.2 (`empRad_nonneg`).** If the zero behavior `0 : Fin n → ℝ` belongs
to `F`, then `empRad(F) ≥ 0`.

*Proof sketch.* The denominator `2ⁿ · n` is nonnegative, so by `div_nonneg` it
suffices to show the numerator is nonnegative. For each fixed `σ`, since `0 ∈ F`,
the finite supremum dominates the value at `0`:
`corr(σ, 0) ≤ sup_{v∈F} corr(σ, v)` (by `Finset.le_sup'`). But
`corr(σ, 0) = Σ_i sgn(σᵢ)·0 = 0`. Hence each summand is `≥ 0`, and a sum of
nonnegative terms is nonnegative (`Finset.sum_nonneg`). ∎

**Interpretation.** Nonnegativity is a *containment* property, not an automatic
one: the zero hypothesis acts as a guaranteed fallback whose correlation with any
sign pattern is zero, providing a floor of `0` for the best achievable
correlation. The boundary case `n = 0` (vanishing denominator) is handled
uniformly because `div_nonneg` applies regardless.

### 4.3 Monotonicity under class inclusion

**Theorem 4.3 (`empRad_mono`).** If `F ⊆ G` (with nonemptiness witnesses `hF`,
`hG`), then `empRad(F) ≤ empRad(G)`.

*Proof sketch.* For each fixed `σ`, a supremum over a larger finite set is at
least the supremum over a subset:
`sup_{v∈F} corr(σ, v) ≤ sup_{v∈G} corr(σ, v)` (by `Finset.sup'_mono`). Summing
this inequality over all `σ` (`Finset.sum_le_sum`) gives the numerator inequality,
and dividing by the common nonnegative denominator preserves it; the division step
(including the `0 ≤` denominator side goal) is discharged by `gcongr`. ∎

**Interpretation.** Monotonicity is the structural backbone of the subject: it
permits bounding the complexity of a rich, complicated class by exhibiting a
simpler superset and bounding *that*. This is the engine behind essentially every
upper bound for expressive model families in learning theory.

### 4.4 The trivial uniform upper bound

**Theorem 4.4 (`empRad_le_of_bounded`).** Suppose every hypothesis in `F` is
coordinate-wise bounded by `B`: for all `v ∈ F` and all `i`, `|vᵢ| ≤ B`. Then
```
empRad(F) ≤ B.
```

*Proof sketch.* For each `σ` and each `v ∈ F`,
```
corr(σ, v) = Σ_i sgn(σᵢ) vᵢ ≤ Σ_i |sgn(σᵢ)| · |vᵢ| = Σ_i |vᵢ| ≤ n · B,
```
using `|sgn(σᵢ)| = 1` and the per-coordinate bound. Taking the supremum over
`v ∈ F` preserves the bound `sup_{v∈F} corr(σ, v) ≤ n·B`. Summing over the `2ⁿ`
patterns gives a numerator at most `2ⁿ · n · B`, so after dividing by `2ⁿ · n` we
obtain `empRad(F) ≤ B`. The degenerate case `n = 0` (empty sample, vanishing
denominator) is treated separately, where the bound holds trivially. ∎

**Interpretation.** This is the universal but blunt safety guarantee: bounded
outputs imply bounded capacity to overfit. Its weakness is that it ignores the
*cardinality* `|F|` of the class, which the refinement of Section 6 exploits.

---

## 4.5 A fully worked numerical example

To make the definitions concrete, fix `n = 3` (three sample points) and consider
the class
```
F = { v1 = ( 1, -1,  1),
      v2 = (-1,  1,  1),
      v3 = ( 1,  1, -1),
      v4 = ( 0,  0,  0) }.
```
There are `2^3 = 8` sign patterns. For each pattern `σ` we compute the best
correlation `max_{v∈F} corr(σ, v)`. Writing each pattern as a triple of signs:

| σ            | corr(σ,v1) | corr(σ,v2) | corr(σ,v3) | corr(σ,v4) | max |
|--------------|-----------:|-----------:|-----------:|-----------:|----:|
| (+,+,+)      | 1          | 1          | 1          | 0          | 1   |
| (+,+,−)      | −1         | −1         | 3          | 0          | 3   |
| (+,−,+)      | 3          | −1         | −1         | 0          | 3   |
| (+,−,−)      | 1          | −3         | 1          | 0          | 1   |
| (−,+,+)      | −1         | 3          | −1         | 0          | 3   |
| (−,+,−)      | −3         | 1          | 1          | 0          | 1   |
| (−,−,+)      | 1          | 1          | −3         | 0          | 1   |
| (−,−,−)      | −1         | −1         | −1         | 0          | 0   |

(For the all-negative pattern the maximum is attained at `v4 = 0`, giving `0`,
since `0 ≥ −1`.) Summing the per-pattern maxima gives
`1 + 3 + 3 + 1 + 3 + 1 + 1 + 0 = 13`, and dividing by `2^n · n = 8 · 3 = 24`
yields
```
empRad(F) = 13 / 24 ≈ 0.5417.
```
This class illustrates several theorems at once: it contains `0`, so by
Theorem 4.2 the value is nonnegative (indeed `0.5417 ≥ 0`); every coordinate is
bounded by `B = 1`, so by Theorem 4.4 the value is at most `1` (indeed
`0.5417 ≤ 1`); and dropping any hypothesis can only decrease the value, by
Theorem 4.3. Removing `v3`, `v4` leaves `F' = {v1, v2}`, whose per-pattern maxima
sum to `8` and give `empRad(F') = 8/24 = 1/3 ≈ 0.333 ≤ 0.5417`, confirming
monotonicity numerically.

## 5. Algorithmic content

Because the behavior-on-the-sample representation makes `empRad(F)` a finite sum,
it is exactly computable — no sampling or approximation required.

**Algorithm `empRad_exact`.** Enumerate all `2ⁿ` sign patterns. For each pattern
`σ`, compute `corr(σ, v)` for every `v ∈ F` and take the maximum. Sum these
maxima and divide by `2ⁿ · n`.

- **Correctness.** Direct from Definition 2.3.
- **Complexity.** `O(2ⁿ · |F| · n)` arithmetic operations and `O(|F| · n)` space.
  The exponential `2ⁿ` factor is intrinsic to the *exact* empirical complexity;
  in practice one replaces the full average over patterns by a Monte-Carlo
  average over sampled patterns, giving an unbiased estimator with cost
  `O(m · |F| · n)` for `m` sampled patterns.

The cancellation Lemma 3.1 also yields an exact *short-circuit* for singletons
(`empRad = 0`) and a closed-form check of the nonnegativity and monotonicity
properties without recomputation.

---

## 6. The frontier: the Massart finite-class refinement

The uniform bound of Theorem 4.4 is tight for adversarial classes but wasteful
for classes whose size is moderate relative to the sample. The classical
**Massart finite-class lemma** sharpens it.

**Conjecture 6.1 (Massart refinement, `empRad_massart_conjecture`).** Let `F` be
a finite class of behaviors each bounded coordinate-wise by `B`. Then
```
empRad(F) ≤ B · √(2 · log|F| / n).
```

*Why it is expected.* For fixed `σ`, the correlations `corr(σ, v)` across
`v ∈ F` are sums of bounded independent contributions, hence sub-Gaussian with
variance proxy `n · B²`. The expected maximum of `|F|` sub-Gaussian variables
with variance proxy `s²` is at most `s · √(2 log|F|)`. Setting `s² = n·B²` and
normalizing by `n` yields the stated bound.

*Why the present toolkit cannot reach it.* The proof requires a
moment-generating-function (Hoeffding) inequality and the maximal inequality for
sub-Gaussian variables — genuinely analytic ingredients. The development of
Sections 3–4 is purely *order-theoretic and combinatorial* (cancellation plus
monotonicity of suprema), and these tools cannot produce the `√(log|F|)`
concentration factor. Closing this gap is the natural next step, and it is the
seam along which a follow-up development should cut: build the sub-Gaussian /
Hoeffding layer, then derive Conjecture 6.1 as its first corollary.

---

## 6b. Relation to the standard theory

The quantity defined here is exactly the *empirical* (or *conditional*) Rademacher
complexity that appears in standard references, specialized to a finite class under
the behavior representation. In the classical formulation one writes
```
Rhat_S(F) = E_σ [ sup_{f∈F} (1/n) Σ_i σ_i f(x_i) ],
```
where `σ_i` are i.i.d. uniform Rademacher variables. Because the `σ_i` are uniform
and independent, the expectation over `σ` is precisely the uniform average
`(1/2^n) Σ_σ` over all sign patterns, and `f(x_i)` is exactly the `i`-th coordinate
of the behavior vector `v_f`. Thus `Rhat_S(F)` coincides with our `empRad(F)`. The
benefit of the behavior representation is twofold: it removes the need to reason
about the underlying function space `f`, and it renders the expectation a finite
sum, making `empRad` an exactly computable rational function of the data.

The broader significance is the *generalization bound* this quantity controls.
The symmetrization inequality of statistical learning theory shows that, with high
probability over a sample of size `n`, the worst-case gap between empirical and
true risk over a class `F` is bounded by `2·empRad(F)` plus a confidence term of
order `sqrt(log(1/δ)/n)`. Hence every property proved here translates directly
into a statement about overfitting: monotonicity says larger classes generalize
no better; the singleton result says a fixed predictor never overfits on average;
and the uniform bound caps the worst-case generalization penalty by the output
range `B`.

## 7. Discussion

The architecture of this development illustrates a recurring phenomenon in
formalized mathematics: a constellation of "obvious" facts about a complex object
often collapses onto a single non-obvious lemma. Here that lemma is the
per-coordinate sign cancellation (Lemma 3.1). Once it is in place, the singleton
theorem is immediate, and nonnegativity, monotonicity, and the uniform bound are
order-theoretic consequences of supremum monotonicity. The fact that automation
tactics close several goals more aggressively than anticipated is itself evidence
that the lemmas are stated in their "natural" form.

Two modeling decisions paid dividends. First, identifying a hypothesis with its
behavior vector turns a class into a finite subset of `ℝⁿ`, eliminating
measure theory and making the complexity computable. Second, encoding sign
patterns as Boolean functions `Fin n → Bool` made the decisive involution
(coordinate flip) trivial to define and to prove involutive, which in turn made
the permutation-reindexing argument clean.

The boundary case `n = 0` recurs as the only genuine subtlety: the denominator
`2ⁿ · n = 0` there, so statements about the *value* of `empRad` must be read with
care, while inequalities continue to hold because nonnegative divisions are
robust to a zero denominator.

---

## 8. Future work

Beyond Conjecture 6.1, several directions are natural:

1. **Sub-Gaussian infrastructure.** Formalize Hoeffding's lemma and the maximal
   inequality for sub-Gaussian variables, then derive the Massart bound and, from
   it, finite-class generalization bounds.

2. **Structural complexity (VC / growth function).** Relate `empRad` to
   combinatorial dimensions via Massart's lemma applied to the projection of `F`
   onto the sample, recovering VC-type bounds.

3. **Composition and contraction.** Prove the Lipschitz contraction (Talagrand)
   inequality so that `empRad` can be propagated through Lipschitz post-processing
   — the key to layer-by-layer bounds for neural networks.

4. **Spectral and norm-based bounds.** Specialize to linear classes
   `{x ↦ ⟨w, x⟩ : ‖w‖ ≤ R}` and prove the spectral/Frobenius-norm bounds that
   motivate the "spectral" framing of this line of work.

5. **From empirical to population complexity.** Add the symmetrization step
   linking empirical Rademacher complexity to the population quantity and to the
   generalization gap.

---

## 8b. On the methodology of formalization

A secondary lesson concerns the discipline of formal development. The proofs here
are short not because the statements are shallow but because the *encoding* was
chosen to make the key argument syntactically trivial. Representing sign patterns
as `Fin n → Bool` rather than as `Fin n → ℝ` (with a side condition `|σ_i| = 1`)
meant that the coordinate-flip map could be written with `Function.update` and
proved involutive by a two-case `simp`; had signs been encoded as reals, the
same involution would have required carrying and discharging the unit-magnitude
constraint at every step. Likewise, defining `empRad` with `Finset.sup'` (the
supremum of a nonempty finite set) rather than an `⨆` over a subtype made the
monotonicity proof a one-line appeal to `Finset.sup'_mono`. These choices are not
incidental; they are the reason a body of "obvious" facts admits clean machine-
checked proofs, and they are worth foregrounding for anyone extending the theory.

## 9. Conclusion

We have given a transparent, fully verified, and computable theory of the
empirical Rademacher complexity of finite hypothesis classes. The behavior-on-
the-sample representation reduces the object to a finite average over sign
patterns, and a single cancellation lemma — the per-coordinate vanishing of
Rademacher signs — drives every elementary property: zero complexity for
singletons, nonnegativity under containment of zero, monotonicity under
inclusion, and the uniform `B` bound for bounded classes. The Massart refinement
remains as a precisely identified next target, awaiting the sub-Gaussian
machinery that the present order-theoretic foundation deliberately sets up.
