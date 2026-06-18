# Exact Identities for the Empirical Rademacher Complexity of Finite Function Classes

## Abstract

Rademacher complexity is the central data-dependent capacity measure of statistical
learning theory: it controls uniform deviation bounds and hence the generalization
gap between empirical and population risk. The standard literature develops it through
a sequence of inequalities. In this work we present a computation-first, *exact*
account of the **empirical Rademacher complexity** of a finite class of real-valued
functions evaluated on a fixed sample of size `m`. We model a hypothesis by its vector
of sample values `f : {1,…,m} → ℝ`, a sign assignment by `σ : {1,…,m} → {±1}`, and the
empirical complexity by an average, over all `2^m` sign vectors, of the best-correlating
class member. We establish: (i) a core combinatorial **cancellation** identity stating
that the signed indicator of any coordinate sums to zero over all sign vectors; (ii) the
**zero-mean** property of the correlation of any fixed function; (iii) the **oddness** of
the correlation functional; (iv) **monotonicity** of complexity under class inclusion;
(v) **nonnegativity** for any class containing the zero function; and, as the central
result, (vi) an *exact closed form* for the complexity of the symmetric pair `{f, −f}`
as the sample-normalized average of `|radSum f σ|`. The symmetric-pair identity exhibits
the absorption `max(a, −a) = |a|` that is the base case of Talagrand's contraction
principle. All results are proved as exact equalities or sharp inequalities and are
designed to serve as a verified substrate for the harder analytic layer of learning
theory (Massart's bound, the contraction lemma, homogeneity laws). We close with
algorithms for exact computation, numerical demonstrations, and a falsifiable research
program.

**Keywords:** Rademacher complexity, statistical learning theory, generalization,
capacity measures, finite function classes, contraction principle, symmetric pair.

---

## 1. Introduction

### 1.1 Motivation

The fundamental question of statistical learning is *generalization*: when does low
error on a finite training sample guarantee low error on unseen data? The answer is
governed by the *capacity* of the hypothesis class — its ability to fit arbitrary
labelings. Too little capacity and the class cannot represent the target; too much and
it overfits noise. Quantifying capacity precisely is therefore foundational.

Among capacity measures, **Rademacher complexity** is distinguished by being
*data-dependent*: it is defined directly in terms of the class's behavior on the actual
sample, rather than through worst-case combinatorial quantities such as the VC
dimension. This makes the resulting generalization bounds tighter and more informative.

The defining intuition is a correlation game. Draw a uniformly random sign vector
`σ ∈ {±1}^m` — pure noise — and ask how well the class can correlate with it. A class
that correlates strongly with random noise can fit anything, including meaningless
fluctuations, and will overfit; a class that cannot correlate with noise is constrained
and trustworthy. Rademacher complexity is the expected best correlation.

### 1.2 Contribution

The textbook development of Rademacher complexity proceeds through inequalities and
concentration arguments. We instead build an *exact*, combinatorial foundation for the
finite-class, finite-sample case, in which every statement is an equality (or a sharp
order relation with explicit constants). Our contributions are:

1. A clean formalization of the empirical Rademacher complexity over all `2^m` sign
   vectors (Section 2).
2. The core cancellation identity `Σ_σ radSign σ i = 0` via a fixed-point-free
   involution (Section 3).
3. Structural laws — zero mean, oddness, monotonicity, nonnegativity, and the
   vanishing complexity of singletons (Section 4).
4. The exact symmetric-pair formula, isolating the `max(a,−a)=|a|` absorption that is
   the atom of the contraction principle (Section 5).
5. Algorithms, complexity analysis, numerical demonstrations, and a falsifiable
   research program (Sections 6–8).

The exactness is the point: an exact foundation has no slack in which errors can hide,
and it furnishes a reliable base for the subsequent analytic theory.

---

## 2. Definitions

Throughout, `m ∈ ℕ` is the sample size. We identify the sample index set with
`Fin m = {0, 1, …, m−1}`.

**Definition 2.1 (Sample-value vector / hypothesis).** A hypothesis evaluated on the
sample is a function `f : Fin m → ℝ`, recording the value the hypothesis assigns at each
sample point. A **function class** is a finite set `F ⊆ (Fin m → ℝ)`, i.e. a term of
type `Finset (Fin m → ℝ)`.

**Definition 2.2 (Sign vector and Rademacher sign).** A sign vector is a function
`σ : Fin m → Bool`. Its associated **Rademacher sign** at coordinate `i` is

> `radSign σ i := if σ i then (1 : ℝ) else (−1 : ℝ)`.

There are exactly `2^m` sign vectors; each Boolean encodes a `±1` choice per coordinate.

**Definition 2.3 (Rademacher correlation).** The correlation of a sample-value vector
`f` with a sign vector `σ` is

> `radSum f σ := Σ_{i ∈ Fin m} (radSign σ i) · f(i)`.

**Definition 2.4 (Empirical Rademacher complexity).** For a nonempty class `F` with
witness `hF : F.Nonempty`, the **empirical Rademacher complexity** is

> `empRad F := (1/m) · (1/2^m) · Σ_{σ : Fin m → Bool} ( sup'_{f ∈ F} radSum f σ )`,

where `sup'` denotes the supremum (maximum) over the nonempty finite class `F`. The
factor `1/2^m` realizes the uniform average over all sign vectors (the expectation over
`σ`), and `1/m` is the per-sample normalization standard in learning theory.

*Remark.* In probabilistic notation, `empRad F = (1/m) · E_σ[ sup_{f∈F} Σ_i σ_i f(i) ]`
with `σ_i` i.i.d. uniform on `{±1}`. Our finite, explicit average makes the object
exactly computable for any concrete `F`.

---

## 3. The core cancellation identity

The entire theory rests on a single combinatorial fact.

**Theorem 3.1 (Cancellation).** For every fixed coordinate `i ∈ Fin m`,

> `Σ_{σ : Fin m → Bool} radSign σ i = 0`.

**Proof sketch.** Consider the involution `T` on the set of all sign vectors that flips
the `i`-th coordinate: `T(σ) := update σ i (¬ σ i)`. This map is:

- *Sign-reversing on coordinate `i`*: `radSign (T σ) i = − radSign σ i`, since flipping
  the Boolean swaps `+1` and `−1`.
- *Fixed-point-free*: `T(σ) ≠ σ` because the `i`-th coordinates differ (`¬σ i ≠ σ i`).
- *An involution*: `T(T(σ)) = σ`, since flipping twice restores the original.

Thus `T` partitions all `2^m` sign vectors into disjoint pairs `{σ, T σ}`, and within
each pair the two summands `radSign σ i` and `radSign (T σ) i = −radSign σ i` cancel.
Summing over all pairs yields `0`. Formally this is `Finset.sum_involution` applied to
`T`, with the four obligations (pairwise cancellation, no fixed points, involutivity,
membership) discharged as above. ∎

This is the discrete analogue of "a fair `±1` random variable has mean zero," but
established as an exact finite identity by symmetry rather than by probability.

---

## 4. Structural laws

**Theorem 4.1 (Zero mean of a fixed function).** For any `f : Fin m → ℝ`,

> `Σ_{σ : Fin m → Bool} radSum f σ = 0`.

**Proof sketch.** Expand `radSum f σ = Σ_i radSign σ i · f(i)` and exchange the order of
summation (`Finset.sum_comm`):
`Σ_σ Σ_i radSign σ i · f(i) = Σ_i ( Σ_σ radSign σ i ) · f(i)`.
The inner sum is `0` by Theorem 3.1, so every term vanishes. ∎

*Interpretation.* A single hypothesis, lacking freedom to adapt to the signs, has zero
expected correlation with noise. It carries no capacity to overfit.

**Theorem 4.2 (Oddness).** For all `f` and `σ`, `radSum (−f) σ = − radSum f σ`.

**Proof sketch.** `radSum (−f) σ = Σ_i radSign σ i · (−f(i)) = −Σ_i radSign σ i · f(i)`
by distributing the negation through the finite sum (`Finset.sum_neg_distrib`). ∎

This expresses that `radSum(·, σ)` is a linear functional in its function argument; the
sign‑reversal special case is what drives the symmetric‑pair identity.

**Theorem 4.3 (Singletons have zero complexity).** For any `f`,
`empRad {f} = 0`.

**Proof sketch.** For each `σ`, `sup'_{g ∈ {f}} radSum g σ = radSum f σ` (the supremum
over a singleton collapses to its single value). Substituting,
`empRad {f} = (1/m)(1/2^m) Σ_σ radSum f σ = 0` by Theorem 4.1. ∎

**Theorem 4.4 (Monotonicity).** If `F ⊆ G` and `F` is nonempty, then
`empRad F ≤ empRad G`.

**Proof sketch.** The normalization constant `(1/m)(1/2^m) ≥ 0`. It therefore suffices
to compare the sums termwise. For each fixed `σ`,
`sup'_{f ∈ F} radSum f σ ≤ sup'_{f ∈ G} radSum f σ` because the supremum over a subset
is dominated by the supremum over the superset (`Finset.sup'_mono`). Summing over `σ`
and multiplying by the nonnegative constant preserves the inequality
(`Finset.sum_le_sum`, `mul_le_mul_of_nonneg_left`). ∎

*Interpretation.* Every hypothesis added to the class is a new opportunity to correlate
with noise; capacity is monotone in the class. This is the quantitative form of "richer
models risk more overfitting."

**Theorem 4.5 (Nonnegativity).** If `0 ∈ F` (the all-zeros vector belongs to `F`), then
`0 ≤ empRad F`.

**Proof sketch.** `radSum 0 σ = 0` for every `σ`. Since `0 ∈ F`, the supremum dominates
this value: `0 = radSum 0 σ ≤ sup'_{g∈F} radSum g σ`. Each summand is therefore
nonnegative; multiplying the nonnegative sum by the nonnegative constant gives
`empRad F ≥ 0` (`Finset.sum_nonneg`, `mul_nonneg`). ∎

---

## 5. The symmetric pair: an exact formula

The smallest class exhibiting genuine capacity is the symmetric pair `{f, −f}`. It is the
atom from which the analytic theory is built.

**Theorem 5.1 (Exact symmetric-pair formula).** For any `f : Fin m → ℝ`,

> `empRad {f, −f} = (1/m) · (1/2^m) · Σ_{σ : Fin m → Bool} |radSum f σ|`.

**Proof sketch.** Fix `σ`. The supremum over the two-element class is

`sup'_{g ∈ {f,−f}} radSum g σ = max( radSum f σ, radSum (−f) σ )`

(`Finset.sup'_insert` then `Finset.sup'_singleton`). By oddness (Theorem 4.2),
`radSum (−f) σ = − radSum f σ`, so this equals `max( a, −a )` with `a = radSum f σ`. The
elementary identity `max(a, −a) = |a|` (`abs_eq_max_neg`) gives `|radSum f σ|`.
Substituting termwise inside the average yields the claim. The normalization constant is
untouched, so the equality is exact. ∎

**Corollary 5.2 (Unconditional nonnegativity of the symmetric pair).**
`0 ≤ empRad {f, −f}` for every `f`, *without* assuming the class contains the zero
vector.

**Proof sketch.** Immediate from Theorem 5.1: each `|radSum f σ| ≥ 0` and the
normalization constant is nonnegative, so the average is nonnegative. ∎

*Discussion.* Theorem 5.1 makes two things explicit. First, the symmetric pair measures
the *average magnitude* of correlation with noise, irrespective of direction — the
natural notion of "how much can `f` align with randomness." Second, and more deeply, the
absorption `max(a, −a) = |a|` is precisely the one-coordinate, `φ = |·|` instance of the
general **contraction (Talagrand) principle**, which states that post-composing a class
with a 1-Lipschitz map `φ` (with `φ(0)=0`) does not increase its Rademacher complexity.
The symmetric-pair formula is, literally, the base case of that induction. Isolating it
as an exact identity is what makes the contraction principle accessible as a future
target rather than a monolith.

---

## 6. Algorithms

The finite definition makes `empRad` exactly computable. We describe the algorithms used
in the accompanying demonstration code.

### 6.1 Brute-force exact complexity

**Goal.** Given a finite class `F` (a list of `m`-vectors) compute `empRad F` exactly by
enumerating all `2^m` sign vectors.

**Logic.** Enumerate each of the `2^m` sign vectors `σ` (as the bits of an integer in
`[0, 2^m)`). For each `σ`, compute `radSum f σ` for every `f ∈ F` and take the maximum.
Accumulate these maxima, then multiply by `(1/m)(1/2^m)`.

**Complexity.** Time `O(2^m · |F| · m)`; space `O(|F| · m)`. Exponential in `m`, as the
exact definition requires; tractable for the small `m` typical of pedagogical and
verification settings. The accompanying `demo.py` uses this routine and also exploits
the symmetric-pair closed form to cross-check results in `O(2^m · m)` time.

### 6.2 Symmetric-pair closed form

**Goal.** Compute `empRad {f, −f}` via Theorem 5.1.

**Logic.** Enumerate sign vectors, accumulate `|radSum f σ|`, and apply the
normalization. This avoids forming the class explicitly and serves as an independent
check on the brute-force routine.

**Complexity.** Time `O(2^m · m)`, space `O(m)`.

---

## 7. Numerical demonstrations

The companion `demo.py` verifies the theory on concrete examples. Representative
findings (exact rational/float arithmetic):

- **Singleton.** For any single vector, the brute-force `empRad` returns `0` (machine
  epsilon), confirming Theorem 4.3.
- **Symmetric pair.** For `f = (1, −2, 0.5)` with `m = 3`, the brute-force complexity of
  `{f, −f}` matches the closed-form average of `|radSum f σ|` to machine precision,
  confirming Theorem 5.1, and is strictly positive (Corollary 5.2).
- **Monotonicity.** Adding vectors to a class never decreases the computed complexity,
  confirming Theorem 4.4 across random trials.
- **Cancellation.** Summing `radSign σ i` over all `σ` returns exactly `0` for each
  coordinate (Theorem 3.1), and `Σ_σ radSum f σ = 0` for random `f` (Theorem 4.1).
- **Nonnegativity.** Classes containing the zero vector exhibit nonnegative complexity
  across random trials (Theorem 4.5).

---

## 8. Applications and discussion

**Generalization bounds.** The empirical Rademacher complexity is the quantity appearing
in the symmetrization bound: with probability at least `1 − δ`, the uniform gap between
empirical and population averages over `F` is bounded by `2 · empRad F` plus a
`O(√(log(1/δ)/m))` confidence term. Each structural law above has an operational
reading: monotonicity quantifies the cost of model richness; the zero-mean and singleton
laws certify that inflexible models incur no overfitting penalty; the symmetric-pair
formula is the engine of the contraction-based bounds used to control deep, composed
hypothesis classes.

**Why exactness matters.** Building generalization theory on exact identities — rather
than on chains of inequalities with implicit constants — yields a foundation with no
hidden slack. The symmetric-pair complexity is *equal to* an average of absolute
correlations; the coordinate cancellation is *exactly* zero. Subsequent analytic layers
can be erected on these beams with confidence that the base is sound.

**Relation to algebraic capacity theory.** These analytic identities complement
combinatorial/algebraic capacity measures (VC dimension, spectral complexity bounds).
The factor `8/3` appearing in the Rademacher-to-PAC conversion in such algebraic
developments is exactly the constant linking the analytic object defined here to a PAC
sample-complexity guarantee; the present exact `empRad` is the analytic quantity those
bounds approximate.

---

## 9. Future directions

The exact foundation invites a falsifiable program; each item names a concrete statement
settleable mechanically.

**(1) Massart's finite-class bound.** Conjecture: for a class `F` with uniformly bounded
correlations `radSum f σ ≤ B`, `empRad F ≤ (B/m) · √(2 log |F|) · (normalization)`, the
textbook `√(2 log N)` scaling converting cardinality into capacity. The maximal-correlation
supremum is controlled by a moment-generating-function (Jensen / Hoeffding-on-the-hypercube)
argument; Theorem 3.1 already supplies the exact first-moment vanishing on which the MGF
bound rests. The only missing analytic ingredient is a sub-Gaussian tail for `radSum`, a
self-contained hypercube estimate.

**(2) Contraction / Talagrand's lemma.** Conjecture: if `φ : ℝ → ℝ` is 1-Lipschitz with
`φ(0) = 0`, then `empRad (φ ∘ F) ≤ empRad F`. The absorption made explicit in
Theorem 5.1 (`max(a,−a)=|a|`) is the `φ = |·|` instance of the general principle; the
symmetric-pair formula is literally the base case of an induction over coordinates,
peeled coordinate-wise via the `sup'` API.

**(3) Homogeneity and translation invariance.** Conjecture: `empRad (c · F) = |c| · empRad F`
and `empRad (F + {b}) = empRad F` for fixed shift `b`. Both reduce to pushing scalars and
shifts through the supremum and reusing Theorem 4.1 (a constant shift averages to zero,
exactly as a constant feature is invisible to a learner); no new probabilistic content is
required.

**(4) Bridge to algebraic capacity theory.** Conjecture: for an evaluation hypothesis
class, the analytic `empRad` is bounded by the algebraic spectral complexity bound,
realizing the `8/3` Rademacher-to-PAC constant of the algebraic sample-complexity bound.

---

## 10. Conclusion

We have given an exact, computation-first foundation for the empirical Rademacher
complexity of finite function classes: a core cancellation identity, the zero-mean and
oddness laws, monotonicity, nonnegativity, the vanishing complexity of singletons, and
an exact closed form for the symmetric pair that isolates the absorption at the heart of
the contraction principle. Stated as equalities and sharp inequalities, these results
form a reliable substrate for the deeper analytic theory of generalization — and a set
of calibration marks for the meter by which we measure the difference between learning
and memorizing.
