# Certified Robustness for Multiclass Classifiers via Tropical Satake Margins

**A Formally Verified Framework for GL₃ Hecke Score Classification**

---

## Abstract

We establish a formally verified robustness certificate for multiclass linear score classifiers whose weight vectors arise from finite tropical Satake test families attached to GL₃ Hecke data. The core result is a Lipschitz transfer lemma showing that coordinatewise ε-perturbation of a feature vector changes the score by at most ‖w‖₁ · ε, leading to an explicit margin-preservation criterion for argmax invariance. The representation-theoretic content enters through the injectivity (separation) of the tropical Satake test map, ensuring that certified margins witness genuine distinctions between finitely supported dominant Hecke data rather than artifacts of duplicated class vectors. All results are formalized and machine-verified in Lean 4 using the Mathlib library, with proofs depending only on standard axioms (propext, Classical.choice, Quot.sound).

---

## 1. Introduction

### 1.1 Motivation

Multiclass linear classifiers assign a label to an input φ ∈ ℝⁿ by computing scores ⟨w_c, φ⟩ for each class c and selecting the argmax. In applications ranging from signal processing to automorphic form classification, one needs to know: *how much can the input be perturbed before the classification changes?*

This question has a clean answer when perturbations are measured coordinatewise: if every coordinate changes by at most ε, the score changes by at most ‖w‖₁ · ε. When the original classification margin exceeds this perturbation budget for every competitor class, the argmax is guaranteed to be preserved.

### 1.2 The Tropical Satake Connection

The framework becomes representation-theoretically meaningful when the weight vectors are not arbitrary but arise from a structured mathematical construction. In the GL₃ setting, the *tropical Satake test family* provides a finite collection of test vectors

T(h) ∈ ℝⁿ

for each finitely supported dominant Hecke datum h, where coordinates correspond to:
- Simple coroot edge valuations (α₁, α₂)  
- Rank-2 Levi mixed moments
- Additional finite support coordinates from partial reconstruction

The GL₃ separation theorem guarantees that T is injective: distinct Hecke data produce distinct test vectors. This injectivity is precisely what prevents the robustness certificate from becoming vacuous.

### 1.3 Contributions

1. **Lipschitz transfer lemma** (Theorem 1): A tight perturbation bound for linear scores under coordinatewise perturbation.

2. **Pairwise margin preservation** (Theorem 2): If the original margin exceeds (‖w_a‖₁ + ‖w_b‖₁) · ε, score ordering is preserved.

3. **Multiclass argmax certificate** (Theorem 3): Extension to κ-class classifiers with per-competitor margin conditions.

4. **Separation bridge** (Theorem 4): Injectivity of the tropical Satake test map ensures non-vacuity of certified margins.

5. **Full formal verification** in Lean 4 with Mathlib, using only standard axioms.

---

## 2. Mathematical Framework

### 2.1 Setup

Let n, κ ∈ ℕ. We work with:

- **Test vectors**: elements of ℝⁿ (functions Fin n → ℝ)
- **Score**: score(w, φ) = Σᵢ wᵢ · φᵢ
- **ℓ¹ norm**: ‖w‖₁ = Σᵢ |wᵢ|
- **Weight family**: W : Fin κ → ℝⁿ assigning a weight vector to each class

### 2.2 Perturbation Model

We consider *coordinatewise bounded perturbations*: ψ is an ε-perturbation of φ if

∀ i : Fin n, |φᵢ - ψᵢ| ≤ ε.

This is weaker than requiring ‖φ - ψ‖_∞ ≤ ε (which would use the sup-norm on the full vector), but in the finite-dimensional setting they are equivalent. The coordinatewise formulation avoids any dependence on norm API specifics in the formalization.

---

## 3. Main Theorems

### Theorem 1: Lipschitz Transfer Lemma

**Statement.** For any w, φ, ψ : Fin n → ℝ,

|score(w, φ) - score(w, ψ)| ≤ Σᵢ |wᵢ| · |φᵢ - ψᵢ|.

If additionally ∀ i, |φᵢ - ψᵢ| ≤ ε, then

|score(w, φ) - score(w, ψ)| ≤ ‖w‖₁ · ε.

**Proof sketch.** By linearity, score(w, φ) - score(w, ψ) = Σᵢ wᵢ(φᵢ - ψᵢ). Apply the triangle inequality for sums and factor |wᵢ(φᵢ - ψᵢ)| = |wᵢ| · |φᵢ - ψᵢ|. Under the ε-bound, each term is at most |wᵢ| · ε, and summing gives ‖w‖₁ · ε. ∎

This bound is tight: equality holds when φᵢ - ψᵢ = ε · sgn(wᵢ).

### Theorem 2: Pairwise Margin Preservation

**Statement.** Let wₐ, w_b, φ, ψ : Fin n → ℝ with 0 ≤ ε and ∀ i, |φᵢ - ψᵢ| ≤ ε. If

score(wₐ, φ) - score(w_b, φ) > (‖wₐ‖₁ + ‖w_b‖₁) · ε,

then score(wₐ, ψ) > score(w_b, ψ).

**Proof.** Apply Theorem 1 separately to wₐ and w_b:

score(wₐ, ψ) ≥ score(wₐ, φ) - ‖wₐ‖₁ · ε  
score(w_b, ψ) ≤ score(w_b, φ) + ‖w_b‖₁ · ε

Subtracting:

score(wₐ, ψ) - score(w_b, ψ) ≥ [score(wₐ, φ) - score(w_b, φ)] - (‖wₐ‖₁ + ‖w_b‖₁) · ε > 0. ∎

### Theorem 3: Multiclass Argmax Certificate

**Statement.** Let W : Fin κ → Fin n → ℝ. If class a has margin

score(W(a), φ) - score(W(b), φ) > (‖W(a)‖₁ + ‖W(b)‖₁) · ε

over every competitor b ≠ a, then

∀ b ≠ a, score(W(a), ψ) > score(W(b), ψ)

for any ψ with coordinatewise perturbation at most ε.

**Proof.** Apply Theorem 2 for each competitor b ≠ a. ∎

### Theorem 4: Separation Bridge

**Statement.** If T : H → Fin n → ℝ is injective and hₐ ≠ h_b, then:
1. T(hₐ) ≠ T(h_b) (distinct test vectors)
2. ∃ i, T(hₐ)ᵢ ≠ T(h_b)ᵢ (distinguishing coordinate exists)
3. ∃ φ, score(T(hₐ), φ) ≠ score(T(h_b), φ) (scores are genuinely distinct)

**Proof.** (1) is immediate from injectivity. (2) follows because equal functions agree on all coordinates (contrapositive of funext). (3) uses the basis vector at a distinguishing coordinate as a witness. ∎

### Final Bridge Theorem

**Tropical Satake Multiclass Certificate.** Let T : H → Fin n → ℝ be a separating (injective) tropical test map, and cls : Fin κ → H assign Hecke data to classes. If the margin condition holds at φ for class a, then a remains the strict argmax at any ε-perturbation ψ.

This also admits a *normalized margin* formulation: the argmax is preserved whenever

ε < min_{b ≠ a} [score(T(cls(a)), φ) - score(T(cls(b)), φ)] / [‖T(cls(a))‖₁ + ‖T(cls(b))‖₁],

provided the denominators are positive (which follows from separation when class data are distinct).

---

## 4. Formal Verification

### 4.1 Lean 4 Implementation

All definitions and theorems are formalized in Lean 4 using Mathlib. The file `TropicalSatakeMargin.lean` contains:

- 5 definitions (`score`, `l1Norm`, `pairwiseMargin`, `argmaxInvariant`, `Separating`)
- 12 theorems, all proved without `sorry`
- Axiom audit: only `propext`, `Classical.choice`, and `Quot.sound` are used

The proof architecture follows the mathematical structure closely:

```
abs_score_sub_le_sum
  └─> abs_score_sub_le_l1_mul_eps' / abs_score_sub_le_l1_mul_eps
        └─> score_gap_lower_bound
              └─> pairwise_margin_preserved
                    └─> multiclass_argmax_invariant
                          └─> tropical_satake_multiclass_certificate
                                └─> tropical_satake_multiclass_certificate_normalized
```

### 4.2 Design Choices

**Coordinatewise bounds vs norms.** We use `∀ i, |φ i - ψ i| ≤ ε` rather than `‖φ - ψ‖_∞ ≤ ε`. This avoids the overhead of establishing the sup-norm API on `Fin n → ℝ` and makes the proofs more direct.

**Finset sums.** All sums are over `Fin n`, which is finite. This avoids any convergence issues and allows direct use of `Finset.sum_le_sum`, `Finset.abs_sum_le_sum_abs`, etc.

**Separation as injectivity.** The `Separating` predicate is simply `Function.Injective T`. This is mathematically transparent and avoids introducing unnecessary abstractions.

---

## 5. Applications

### 5.1 Certified Robust Classification

The primary application is *certifying that a classifier's decision will not change under bounded perturbation*. Given:
- A trained classifier with weight vectors W₁, ..., W_κ
- A test input φ
- A perturbation budget ε (e.g., measurement noise)

compute the certified radius

ε* = min_{b ≠ a} [score(Wₐ, φ) - score(W_b, φ)] / [‖Wₐ‖₁ + ‖W_b‖₁]

If ε ≤ ε*, the classification is *provably* invariant. This is the tightest possible bound for ℓ∞ perturbations of linear classifiers.

### 5.2 Automorphic Form Classification

In the tropical Satake setting, coordinates of the test vectors encode representation-theoretic data: coroot valuations, Levi moments, and reconstruction coordinates. The certified radius then quantifies *how much noise in these representation-theoretic features can be tolerated before the Hecke-data classification changes*.

### 5.3 Adversarial Robustness

For machine learning systems, this framework provides deterministic (not probabilistic) robustness guarantees. Unlike randomized smoothing or other statistical methods, the margin certificate is exact: if the margin condition is satisfied, the guarantee holds with certainty.

### 5.4 Signal Processing

Any system that classifies signals based on linear features (matched filters, correlation detectors) can use this framework to certify robustness against bounded additive noise.

---

## 6. Discussion: What This Really Means

*A Scientific American-style explanation*

Imagine you're sorting mail into boxes using a simple rule: weigh each letter against several reference templates, add up the scores, and put it in the box with the highest total score. Now suppose the scale has some jitter — each measurement can be off by up to ε grams. Will you still sort the letter into the right box?

The answer depends on *how decisively* the right box was winning. If the winning box beat every competitor by a huge margin, a little jitter won't matter. If the race was tight, even tiny noise could flip the result.

Our theorem makes this intuition precise. The "jitter tolerance" of any box depends on exactly two things:
1. **The margin**: how much the winner beat each competitor on the clean measurement.
2. **The template complexity**: measured by the ℓ¹ norm (sum of absolute template values), which controls how much the scores amplify input noise.

The formula is beautifully simple: the classification is safe as long as

ε < margin / (complexity_winner + complexity_competitor)

for every competitor. The ratio on the right is the *normalized margin* — a single number that tells you exactly how robust each classification decision is.

What makes this more than just a nice formula is the *provenance* of the template vectors. In our setting, they don't come from arbitrary training — they come from the *tropical Satake transform*, a mathematical construction rooted in the representation theory of the group GL₃. This means:

- The templates aren't arbitrary: they encode genuine mathematical structure (coroot valuations, Levi moments).
- The *separation theorem* guarantees that distinct mathematical objects always produce different templates. So the robustness certificate isn't certifying stability of a degenerate classifier — it's certifying stability of one that genuinely distinguishes everything it's supposed to.
- The constant in the bound is exactly 1. No hidden constants, no asymptotic approximations.

We proved all of this in Lean 4, a programming language designed for mathematical proof verification. The computer checked every logical step — from the triangle inequality to the final multiclass certificate. The proofs use only the most basic axioms of mathematics (propositional extensionality, the axiom of choice, and the soundness of quotient types). This means the results are as certain as mathematics can be.

### Historical Context

The idea of certified robustness has deep roots. In control theory, Lyapunov stability analysis has provided rigorous perturbation bounds since the 1890s. In machine learning, the quest for adversarial robustness certificates began around 2017 with the work of Hein and Andriushchenko on linear classifiers and has since expanded to neural networks via randomized smoothing, abstract interpretation, and mixed-integer programming.

Our contribution sits at an unusual intersection: we use the specific mathematical structure of tropical geometry and automorphic forms to build classifiers with *built-in* robustness certificates, rather than trying to retrofit robustness onto a black-box model. The separation theorem acts as a *structural guarantee* that the classifier is doing something meaningful in the first place.

### Future Directions

1. **Extension to GLₙ**: The framework generalizes naturally to GL_n for any n, with richer Levi moments and larger test families.

2. **Tropical Hecke architectures**: Composing multiple layers of tropical Satake transforms could yield deeper classifiers with compositional robustness certificates.

3. **Non-linear extensions**: The Lipschitz framework extends to Lipschitz-continuous score functions beyond linear; the tropical structure may provide natural Lipschitz bounds.

4. **Computational certificates**: The certified radius is computable in O(κn) time, making it practical for real-time certification of classification decisions.

---

## 7. Conclusion

We have formalized and machine-verified a complete robustness certification framework for multiclass linear score classifiers built from GL₃ tropical Satake test families. The framework provides:

- An exact, tight Lipschitz bound for score perturbation (‖w‖₁ · ε)
- An explicit argmax-preservation criterion with sharp constant 1
- A representation-theoretic bridge ensuring non-vacuity via the GL₃ separation theorem
- Full formal verification in Lean 4 with only standard axioms

The result demonstrates that tropical Satake geometry provides not just a classification method but a *certifiably robust* one, where the robustness radius has a closed-form expression tied directly to the representation-theoretic content of the classifier.

---

## References

1. Hein, M. & Andriushchenko, M. (2017). Formal guarantees on the robustness of a classifier against adversarial manipulation. *NeurIPS*.

2. Cohen, J., Rosenfeld, E., & Kolter, J.Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.

3. The Mathlib Community (2020-2026). *Mathlib: the Lean mathematical library*. https://github.com/leanprover-community/mathlib4

4. Macdonald, I.G. (2003). *Affine Hecke algebras and orthogonal polynomials*. Cambridge University Press.

5. Gross, B.H. (1998). On the Satake isomorphism. In *Galois representations in arithmetic algebraic geometry*, London Math. Soc. Lecture Notes 254.
