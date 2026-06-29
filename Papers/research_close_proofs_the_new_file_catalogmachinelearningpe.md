# Perturbation-Stable Generalization Bounds: An Exact, Additive Bridge Between Compression and Robustness

## Abstract

We establish an exact compositional relationship between two pillars of
statistical learning theory that are usually developed in isolation:
*compression-based (Occam / minimum-description-length) generalization bounds*
and *Lipschitz perturbation stability*. The clean Occam bound certifies the true
risk of a learned hypothesis as its empirical risk plus a square-root capacity
penalty governed by description length. We show that certifying the true risk
under bounded adversarial input perturbations requires exactly one modification:
the empirical-risk argument is shifted by a single scalar `L · ρ`, the product of
the loss's Lipschitz constant `L` and the perturbation radius `ρ`. We call the
result the **perturbation-stable Occam bound**. We prove (i) a per-point
perturbation inequality, (ii) a dataset-level robustness inequality validating the
robust empirical risk as a genuine upper bound, (iii) a clean two-term gap
decomposition into a robustness term and a capacity penalty, (iv) a collapse
property recovering the clean bound when there is no perturbation, (v) a
consistency theorem showing the bound converges to an *irreducible robustness
floor* `R + L · ρ` at the unchanged `1/√n` rate, (vi) a sample-complexity
inversion of identical shape to the clean theory, and (vii) preservation of
overparameterization invariance. The central structural finding is that
robustness and generalization compose **additively and without coupling**:
statistical efficiency and adversarial fragility occupy orthogonal axes that meet
only through scalar addition.

**Keywords.** Generalization bounds, compression, minimum description length,
Occam's razor, Lipschitz continuity, adversarial robustness, PAC learning, sample
complexity, overparameterization.

---

## 1. Introduction

### 1.1 Two puzzles, two literatures

Modern machine learning is haunted by two questions that have historically been
studied with disjoint toolkits.

The **generalization puzzle** concerns why heavily overparameterized models, with
far more parameters than training examples, nonetheless generalize. Classical
capacity measures — VC dimension, Rademacher complexity, parameter counts — grow
with model size and therefore predict catastrophic overfitting that does not
occur. The most satisfying modern resolution replaces these measures by the
*description length* of the learned solution: a compression bound. A model that
compresses to a short description generalizes well *regardless* of how many raw
parameters it nominally has.

The **robustness puzzle** concerns the fragility of high-performing models to
imperceptible input perturbations. Its central quantity is the Lipschitz constant
`L` of the loss as a function of the input: a speed limit on how fast the loss can
change. Certified robustness asks for guarantees on model behavior when the input
is adversarially perturbed within a radius `ρ`.

These literatures speak different languages. This paper shows they share an exact
algebraic skeleton.

### 1.2 Contribution

We prove that the robust analogue of the compression generalization bound is
obtained by a single, surgical edit: replace the empirical risk `R` with the
*robust empirical risk* `R + L · ρ`, leaving every other component — the
complexity term, the sample-size dependence, the confidence dependence — exactly
as it was. From this one observation we derive a complete suite of structural
theorems (Section 4) that together establish a clean **decoupling**: the
statistical axis (data, description length) and the adversarial axis
(sensitivity, radius) interact only through scalar addition.

---

## 2. Preliminaries and Definitions

Throughout, `R, C, L, ρ, δ, ε ∈ ℝ` are real parameters and `n ∈ ℕ` is the sample
size. `ln` denotes the natural logarithm and `√` the real square root (extended
by `√t = 0` for `t < 0`, as is standard in the underlying formalization).

### 2.1 The compression (Occam) bound

We take as given the compression-based generalization bound, the analytic core of
minimum-description-length learning theory.

**Definition 2.1 (Occam bound).**
For empirical risk `R`, complexity `C` (in nats), sample size `n`, and confidence
parameter `δ`,
$$
\mathrm{occamBound}(R, C, n, \delta) \;=\; R + \sqrt{\frac{C + \ln(1/\delta)}{2n}}.
$$
The square-root term is the **capacity penalty**. `C` is a description length:
a hypothesis stored in `b` bits has complexity `C = b \cdot \ln 2`.

We rely on three established properties of this bound, all elementary:

- **(P1) Monotonicity in risk.** If `R₁ ≤ R₂` then
  `occamBound(R₁, C, n, δ) ≤ occamBound(R₂, C, n, δ)`. (The risk enters
  additively.)
- **(P2) Consistency.** For fixed `R, C, δ`, the gap
  `occamBound(R, C, n, δ) − R → 0` as `n → ∞`, since the capacity penalty is
  `√(Θ(1/n))`.
- **(P3) Sample-complexity inversion.** If `ε > 0`,
  `0 ≤ C + ln(1/δ)`, and `n ≥ (C + ln(1/δ)) / (2ε²)`, then
  `occamBound(R, C, n, δ) ≤ R + ε`.

We also use that the certified bound depends only on the *empirical risk* and the
*complexity (description length)* — never on raw parameter count
(**overparameterization invariance**).

### 2.2 Lipschitz losses

Let `(X, dist)` be a (pseudo)metric space and `ℓ : X → ℝ` a loss function. We say
`ℓ` is `L`-Lipschitz (with `L ≥ 0`) if
$$
|\ell(x) - \ell(y)| \le L \cdot \mathrm{dist}(x, y) \qquad \text{for all } x, y \in X.
$$

### 2.3 The new definitions

**Definition 2.2 (Robust empirical risk).**
$$
\mathrm{robustEmpRisk}(R, L, \rho) \;=\; R + L \cdot \rho.
$$
This is the clean empirical risk inflated by the worst-case loss increase a
`ρ`-perturbation can induce against an `L`-Lipschitz loss.

**Definition 2.3 (Perturbation-stable Occam bound).**
$$
\mathrm{perturbedOccamBound}(R, C, L, \rho, n, \delta)
  \;=\; \mathrm{occamBound}\big(\mathrm{robustEmpRisk}(R, L, \rho),\, C,\, n,\, \delta\big)
  \;=\; (R + L\rho) + \sqrt{\frac{C + \ln(1/\delta)}{2n}}.
$$

The entire theory below is the study of this one object.

---

## 3. The Robustness Core

### 3.1 Per-point perturbation bound

**Theorem 3.1 (`lipschitz_perturbation_le`).**
Let `ℓ : X → ℝ` be `L`-Lipschitz with `L ≥ 0`. For any `x, y ∈ X` and `ρ ∈ ℝ`
with `dist(x, y) ≤ ρ`,
$$
\ell(y) \;\le\; \ell(x) + L \cdot \rho.
$$

*Proof sketch.* The Lipschitz property gives
`|ℓ(x) − ℓ(y)| ≤ L · dist(x, y)`. In particular
`ℓ(y) − ℓ(x) ≤ |ℓ(x) − ℓ(y)| ≤ L · dist(x, y)`. Since `L ≥ 0`, monotonicity of
multiplication yields `L · dist(x, y) ≤ L · ρ`. Chaining,
`ℓ(y) − ℓ(x) ≤ L · ρ`, i.e. `ℓ(y) ≤ ℓ(x) + L · ρ`. ∎

This is the atom from which all robustness statements are built: locally, the
cost of a `ρ`-perturbation is at most `L · ρ`.

### 3.2 Dataset-level robustness

**Theorem 3.2 (`robust_empRisk_valid`).**
Let `ℓ` be `L`-Lipschitz with `L ≥ 0`. Let `s` be a finite index set and
`x, y : ι → X` two assignments of inputs. If `dist(x_i, y_i) ≤ ρ` for every
`i ∈ s`, then
$$
\sum_{i \in s} \ell(y_i) \;\le\; \Big(\sum_{i \in s} \ell(x_i)\Big) + |s| \cdot (L \cdot \rho).
$$

*Proof sketch.* Apply Theorem 3.1 termwise: for each `i ∈ s`,
`ℓ(y_i) ≤ ℓ(x_i) + L · ρ`. Summing the pointwise inequalities over `s` (monotonicity
of finite sums) gives `∑ ℓ(y_i) ≤ ∑ (ℓ(x_i) + L·ρ)`. Distributing the sum and
collecting the `|s|` copies of the constant `L·ρ` yields the claim. ∎

Dividing by `|s|` shows the *mean* perturbed loss exceeds the mean clean loss by
at most `L · ρ`. This is precisely the statement that the robust empirical risk
`R + L·ρ` (Definition 2.2) is a genuine upper bound on the worst-case perturbed
empirical risk — the formal justification for plugging it into the Occam bound.

---

## 4. Structure of the Perturbation-Stable Bound

### 4.1 Monotonicity: perturbation only loosens

**Theorem 4.1 (`perturbed_ge_clean`).**
If `0 ≤ L · ρ` then
$$
\mathrm{occamBound}(R, C, n, \delta) \;\le\; \mathrm{perturbedOccamBound}(R, C, L, \rho, n, \delta).
$$

*Proof sketch.* Unfolding the definitions, the two sides differ only in their
risk arguments, `R` versus `R + L·ρ`. Since `L·ρ ≥ 0`, we have `R ≤ R + L·ρ`, and
the claim is monotonicity (P1) of the Occam bound in its risk slot. Concretely,
both sides share the same capacity penalty, so the inequality is the scalar
inequality `R ≤ R + L·ρ`. ∎

Robustness is never free and never beneficial to the certificate: requiring a
guarantee against perturbations can only raise the certified true risk.

### 4.2 The gap decomposition

**Theorem 4.2 (`perturbed_gap_decomposition`).**
$$
\mathrm{perturbedOccamBound}(R, C, L, \rho, n, \delta) - R
  \;=\; L \cdot \rho \;+\; \sqrt{\frac{C + \ln(1/\delta)}{2n}}.
$$

*Proof sketch.* Expand both definitions:
`perturbedOccamBound = (R + L·ρ) + √(·)`. Subtract `R`; the result is
`L·ρ + √(·)` by pure algebra. ∎

This is the conceptual heart of the paper made into an identity. Measured against
the clean training error `R`, the certified excess is the sum of two named,
non-interacting contributions:

- the **robustness term** `L · ρ`, depending only on sensitivity and radius; and
- the **capacity penalty** `√((C + ln(1/δ)) / (2n))`, depending only on
  description length, data, and confidence.

There is no cross-term. The adversarial axis and the statistical axis are
orthogonal and combine by addition.

### 4.3 Collapse to the clean bound

**Theorem 4.3 (`perturbed_collapse`).**
If `L · ρ = 0` (in particular, if `ρ = 0` or `L = 0`) then
$$
\mathrm{perturbedOccamBound}(R, C, L, \rho, n, \delta) = \mathrm{occamBound}(R, C, n, \delta).
$$

*Proof sketch.* The robust empirical risk reduces to `R + 0 = R`, so the perturbed
bound's risk argument equals the clean risk and the two bounds coincide
definitionally. ∎

The perturbed theory strictly generalizes the clean one: with no adversary
(`ρ = 0`) or a perturbation-insensitive loss (`L = 0`), the classical Occam bound
is recovered exactly.

---

## 5. Consistency and Sample Complexity

### 5.1 The irreducible robustness floor

**Theorem 5.1 (`perturbed_bound_tendsto`, Consistency).**
For fixed `R, C, L, ρ, δ`,
$$
\lim_{n \to \infty} \mathrm{perturbedOccamBound}(R, C, L, \rho, n, \delta) \;=\; R + L \cdot \rho.
$$

*Proof sketch.* Write `R' = robustEmpRisk(R, L, ρ) = R + L·ρ`. By consistency of
the clean bound (P2), the gap `occamBound(R', C, n, δ) − R' → 0` as `n → ∞`.
Adding the constant `R'` to a sequence tending to `0` gives a sequence tending to
`R'`. Since `perturbedOccamBound = occamBound(R', C, n, δ) =
(occamBound(R', C, n, δ) − R') + R'`, the perturbed bound tends to `R' = R + L·ρ`. ∎

The contrast with the clean theory is the sharpest formulation of the
decoupling. The clean bound converges to `R`; the perturbed bound converges to
`R + L·ρ`. The capacity penalty still vanishes at the unchanged `1/√n` rate — but
what remains is an **irreducible robustness floor** `L·ρ`. More data defeats
statistical uncertainty; it does *not* defeat the adversary. Lowering the floor
requires either reducing the model's sensitivity `L` or shrinking the threat
radius `ρ`; it can never be bought with samples alone. This mirrors, on the
robustness side, the catalog's memorization boundary in which complexity growing
linearly in `n` leaves an irreducible statistical gap — here the irreducible gap
is adversarial rather than statistical.

### 5.2 Sample complexity

**Theorem 5.2 (`perturbed_sample_complexity`, inversion).**
Let `ε > 0`, suppose `0 ≤ C + ln(1/δ)`, and let
$$
n \;\ge\; \frac{C + \ln(1/\delta)}{2\varepsilon^2}.
$$
Then
$$
\mathrm{perturbedOccamBound}(R, C, L, \rho, n, \delta) \;\le\; R + L\rho + \varepsilon.
$$

*Proof sketch.* Apply the clean sample-complexity inversion (P3) with the robust
empirical risk `R' = R + L·ρ` in place of `R`. The hypothesis on `n` is exactly
P3's hypothesis (it does not involve the risk argument), so P3 gives
`occamBound(R', C, n, δ) ≤ R' + ε = R + L·ρ + ε`, which is the claim. ∎

The shape of the sample-complexity law — quadratic in `1/ε`, linear in the
description length (after substituting `C = b · ln 2`) — is completely unaffected
by robustness. The adversary translates the *target* from `R` to `R + L·ρ`; the
*difficulty* of approaching the target within `ε` is governed by the same
statistical law as in the clean theory.

---

## 6. The Bridge and Overparameterization

### 6.1 The clean-data robustness certificate

The pieces above combine into the operational bridge theorem. Suppose we compute,
on *clean* training data, the clean empirical risk `R` and the model's Lipschitz
constant `L`. Theorem 3.2 shows the worst-case perturbed empirical risk over any
`ρ`-perturbed dataset is at most `R + L·ρ`. Monotonicity of the Occam bound in its
risk slot (P1) then lifts this to the level of the *certified true risk*:

**Theorem 6.1 (`perturbed_certificate`, the bridge).**
The clean-data certificate `R + L·ρ`, fed through the compression bound, dominates
the Occam bound evaluated on the empirical risk of *any* `ρ`-perturbed dataset.
Equivalently, the perturbation-stable Occam bound computed from clean quantities
is a valid certificate against all admissible adversarial perturbations.

*Proof sketch.* For any perturbed dataset with empirical risk `R_pert`, Theorem
3.2 (averaged) gives `R_pert ≤ R + L·ρ`. By P1,
`occamBound(R_pert, C, n, δ) ≤ occamBound(R + L·ρ, C, n, δ) =
perturbedOccamBound(R, C, L, ρ, n, δ)`. Thus the perturbed bound, computable from
clean data and the single constant `L·ρ`, upper-bounds the certified true risk on
every admissible perturbation. ∎

This is what makes the result usable: no adversarial training set, no inner
maximization, no perturbed evaluation is required to obtain the certificate. The
clean quantities plus one scalar suffice.

### 6.2 Overparameterization invariance survives

**Theorem 6.2 (`perturbed_overparam_invariance`).**
The perturbation-stable bound depends only on the empirical risk, the complexity
(description length), and the perturbation budget `L·ρ` — never on the raw
parameter count. Two networks differing only in redundant weights, but agreeing on
empirical risk, description length, sensitivity, and radius, receive identical
perturbed certificates.

*Proof sketch.* Parameter count does not appear in Definition 2.3. The risk slot
holds `R + L·ρ`, which involves no parameter count; the capacity penalty involves
only `C, n, δ`. Hence the perturbed bound factors through exactly the same
quantities as the clean bound plus the scalar `L·ρ`, and is invariant under
adding redundant parameters. ∎

The robustness extension does *not* reintroduce a dependence on parameter count.
A massively overparameterized but well-compressing network keeps its small
certified bound, robustness term included. This closes the loop: the property that
explained clean overparameterized generalization is preserved verbatim under
adversarial perturbation.

---

## 7. Discussion

### 7.1 Why the composition is exact

The reason robustness and generalization compose without coupling is that they act
on *different arguments* of the same bound. Robustness modifies the empirical-risk
input; generalization is the map from that input (plus complexity, data, and
confidence) to a certified true risk. Because the Occam bound is *affine* in its
risk argument — the risk enters by simple addition, untouched by the square-root
penalty — composing a robustness shift with the bound is exact and produces a pure
translation by `L·ρ`. Had the bound coupled risk and complexity multiplicatively,
the composition would have produced cross-terms. It does not, and so it does not.

### 7.2 Practical reading

For a practitioner the theory offers a single honest knob. To certify robustness
against an `ℓ`-radius `ρ`:

1. Train and measure clean empirical risk `R` and compressed description length
   `C` (hence the clean bound `R + √((C + ln(1/δ))/(2n))`).
2. Bound the loss's Lipschitz constant `L` (via spectral-norm products of layers,
   randomized smoothing certificates, or direct estimation).
3. Add `L·ρ` to the empirical-risk term. Read off the same generalization bound.

Two separate budgets — a *data budget* (how many samples to drive the capacity
penalty below `ε`) and a *robustness budget* (`L·ρ`) — can be reasoned about
independently and then summed.

### 7.3 Limitations

The bound is an upper bound and is only as tight as the Lipschitz estimate `L`.
Global Lipschitz constants of deep networks are notoriously loose; local or
data-dependent sensitivity estimates would yield tighter, though more intricate,
floors. The robustness floor `L·ρ` is irreducible *within this model class*: it
reflects a genuine fundamental limit given the sensitivity, but a better
architecture (smaller `L`) changes the limit. Finally, the perturbation model is a
metric-ball threat; structured or semantic perturbations require a different
geometry.

---

## 8. Future Directions

A natural next step is the **heterogeneous** generalization in which each example
carries its own sensitivity `L_i` and radius `ρ_i`; the per-example perturbation
bound sums to a robust empirical risk of `R + (1/n) ∑ L_i ρ_i`, and the boundary
behavior of this average seeds questions about adversaries with non-uniform power.
Other directions include: replacing global Lipschitz constants with local or
distribution-dependent sensitivity to tighten the floor; composing the perturbed
bound with PAC-Bayes posteriors to obtain robustness certificates for stochastic
predictors; and studying the interaction of the robustness floor `L·ρ` with the
memorization boundary, where complexity grows with `n`, to map the joint
statistical–adversarial phase diagram. (See the dedicated Future Directions
discussion bundled with this package.)

---

## 8.5 A Worked Numerical Illustration

To make the structural theorems concrete, consider a single running example with
fixed parameters: a model with empirical risk `R = 0.05`, a compressed
description length of `8192` bits (so `C = 8192 · ln 2 ≈ 5678.0` nats), a loss
Lipschitz constant `L = 1.6`, a perturbation radius `ρ = 0.1`, and confidence
`δ = 0.05` (hence `ln(1/δ) ≈ 2.996`).

**The robustness term.** The robust empirical risk is
`R + L·ρ = 0.05 + 1.6 · 0.1 = 0.21`. The robustness floor — the value the
certified true risk approaches as data grows without bound — is therefore `0.21`,
in contrast to the clean floor of `0.05`. The single scalar `L·ρ = 0.16` is the
entire adversarial surcharge.

**The gap decomposition at finite n.** Take `n = 50000`. The capacity penalty is
`√((5678.0 + 2.996) / (2 · 50000)) = √(5681.0 / 100000) = √0.05681 ≈ 0.2384`.
By Theorem 4.2, the certified true-risk bound is
`perturbedOccamBound = (R + L·ρ) + 0.2384 = 0.21 + 0.2384 = 0.4484`, and the
excess over the clean training error decomposes as
`0.4484 − 0.05 = 0.16 (robustness) + 0.2384 (capacity) = 0.3984`, exactly the
identity of Theorem 4.2 with no cross-term.

**Collapse.** Setting `ρ = 0` (or `L = 0`) removes the robustness term, returning
the clean bound `0.05 + 0.2384 = 0.2884`, in agreement with Theorem 4.3.

**Consistency.** Increasing the sample size drives the capacity penalty toward
zero: at `n = 10^6` it is `≈ 0.0533`, giving a bound of `≈ 0.2633`; at `n = 10^9`
it is `≈ 0.00169`, giving a bound of `≈ 0.2117`. The values march steadily toward
the floor `0.21`, never below it — the numerical signature of Theorem 5.1.

**Sample complexity.** To certify the bound within `ε = 0.01` of the floor,
Theorem 5.2 requires `n ≥ (5678.0 + 2.996) / (2 · 0.01²) = 5681.0 / 0.0002 ≈
2.84 × 10^7`. At that sample size the bound is `0.21 + 0.01 = 0.22`, exactly the
promised `R + L·ρ + ε`. Note that the robustness budget `L·ρ` does not enter the
sample-count formula at all — it shifts the target, not the difficulty.

**Overparameterization.** Replace the model by one with `10^9` parameters but the
same `8192`-bit compressed description and the same empirical risk. Every number
above is unchanged: the certificate is identical, confirming Theorem 6.2. A
rival model that compresses to `2048` bits with empirical risk `0.04` yields
`C = 2048 · ln 2 ≈ 1419.6` and, at `n = 50000`, a strictly smaller bound — the
overparameterized-can-beat-small phenomenon, preserved verbatim under
perturbation.

This single example exhibits, in arithmetic, every qualitative claim of the
theory: an additive robustness surcharge, a clean two-term decomposition, a
collapse to the classical bound, convergence to an irreducible floor, an
unchanged sample-complexity law, and invariance to parameter count.

## 9. Conclusion

We have shown that perturbation-stable generalization is, structurally, the
ordinary compression generalization bound with its empirical-risk slot shifted by
a single scalar `L·ρ`. From this one observation flow a per-point robustness
inequality, a dataset-level validation of the robust empirical risk, an exact
two-term gap decomposition, a collapse to the clean bound, a consistency theorem
exhibiting an irreducible robustness floor, an unchanged sample-complexity law,
an operational clean-data certificate, and preservation of overparameterization
invariance. The unifying message is a clean decoupling: statistical efficiency and
adversarial robustness are orthogonal axes that meet only through addition.
Robustness costs exactly one number, added once.
