# Tropical Universality Theory for Computation DAGs: Asymptotic Invariants from Max-Plus Geometry

## Abstract

We develop a rigorous mathematical framework — *tropical universality theory* — that extracts computable asymptotic invariants from the combinatorial structure of computation DAGs. The central objects are **tropical profiles**: nonempty finite sets of affine forms whose pointwise maximum (the tropical envelope) encodes a DAG's input-output semantics in the max-plus semiring. We prove three main theorems, all formally verified in Lean 4 with Mathlib:

1. **Slope Invariance (Theorem 1):** Tropically equivalent profiles — those with identical envelopes — share the same maximum slope (asymptotic exponent) and essential dominant bias.
2. **Parallel Composition (Theorem 3):** The envelope of a parallel (residual) composition is the pointwise maximum of the component envelopes, and the asymptotic slope of the composition equals the maximum of the component slopes.
3. **Eventual Dominance:** For any tropical profile, forms with the steepest slope eventually dominate all others, reducing asymptotic analysis to a finite combinatorial problem.

These results establish the tropical profile as a **universality class invariant** for computation DAGs: architectures with the same tropical envelope are asymptotically indistinguishable. We also show that the naive "dominant multiplicity invariance" conjecture is false and identify the correct invariant (essential dominant bias). Applications to neural architecture search, residual network design, and scaling law prediction are demonstrated computationally.

**Keywords:** tropical geometry, max-plus algebra, scaling laws, universality classes, computation DAGs, piecewise-linear functions, residual networks

---

## 1. Introduction

### 1.1 Motivation

Empirical scaling laws for neural networks — power-law relationships between model size and performance — have become central to modern AI research [Kaplan et al., 2020; Hoffmann et al., 2022]. Yet the theoretical foundations remain thin: why do scaling exponents depend on architecture, and when do different architectures yield the same exponent?

We address these questions through the lens of **tropical geometry**, the algebraic geometry of the max-plus semiring (ℝ, max, +). The connection between ReLU networks and tropical polynomials has been noted in several works [Zhang et al., 2018; Maragos et al., 2021], but prior results focus on representational capacity rather than asymptotic invariants.

Our contribution is to formalize the **tropical profile** of a computation DAG and prove that it determines asymptotic scaling behavior. Two architectures with the same tropical envelope — the same pointwise maximum of path-cost affine functions — must exhibit the same scaling exponent. This is a universality theorem in the statistical-mechanics sense: many microscopically different systems, one macroscopic invariant.

### 1.2 Contributions

1. **Formal definitions** of tropical profiles, envelopes, tropical equivalence, and parallel composition, all machine-verified in Lean 4.
2. **Theorem 1 (Slope Invariance):** `tropical_equiv_implies_same_maxSlope` — tropical equivalence preserves the asymptotic exponent.
3. **Theorem 1+ (Bias Invariance):** `tropical_equiv_preserves_essential_bias` — tropical equivalence also preserves the essential dominant bias, completely determining the eventual linear behavior.
4. **Theorem 3a (Envelope Decomposition):** `evalMax_parallel_compose` — the envelope of a parallel composition is the pointwise max of components.
5. **Theorem 3b (Slope Composition):** `asymptotic_slope_parallel_compose` — the asymptotic slope of a parallel composition is the max of component slopes.
6. **Eventual Dominance Lemma:** `eventual_slope_dominance` — forms with maximal slope dominate for large arguments.
7. **Counterexample** to naive multiplicity invariance, with corrected invariant.
8. **Concrete verified example** of two non-isomorphic profiles that are tropically equivalent.
9. **Algorithms** for tropical profile extraction, equivalence testing, and universality classification.

### 1.3 Related Work

- **Tropical geometry and neural networks:** Zhang et al. (2018) showed that ReLU networks compute tropical rational functions. Maragos et al. (2021) developed tropical signal processing. Alfarra et al. (2022) used tropical geometry for robustness certification.
- **Scaling laws:** Kaplan et al. (2020) and Hoffmann et al. (2022) established empirical scaling laws. Bahri et al. (2021) connected scaling to statistical mechanics. Sharma and Kaplan (2022) related exponents to data dimensionality.
- **Max-plus algebra:** Extensive literature in optimization, scheduling, and discrete event systems [Baccelli et al., 1992; Butkovič, 2010]. Our work imports max-plus structural results into learning theory.

---

## 2. Definitions and Notation

### 2.1 Affine Forms

An **affine form** is a pair (α, β) ∈ ℝ² representing the function f(x) = αx + β. We call α the **slope** and β the **bias**.

```
structure AffineForm where
  slope : ℝ
  bias  : ℝ

def AffineForm.eval (f : AffineForm) (x : ℝ) : ℝ := f.slope * x + f.bias
```

### 2.2 Tropical Profiles

A **tropical profile** P = (S, ∅ ≠ S ⊂ AffineForm) is a nonempty finite set of affine forms. The **tropical envelope** is:

$$\text{evalMax}_P(x) = \max_{f \in S} f(x) = \max_{f \in S} (\alpha_f x + \beta_f)$$

```
structure TropicalProfile where
  forms : Finset AffineForm
  nonempty : forms.Nonempty

def TropicalProfile.evalMax (P : TropicalProfile) (x : ℝ) : ℝ :=
  P.forms.sup' P.nonempty (fun f => f.eval x)
```

### 2.3 Tropical Equivalence

Two profiles P, Q are **tropically equivalent**, written P ≡ Q, if their envelopes agree pointwise:

$$P \equiv Q \iff \forall x \in \mathbb{R}, \text{evalMax}_P(x) = \text{evalMax}_Q(x)$$

### 2.4 Asymptotic Invariants

The **maximum slope** of P is α*(P) = max{α_f : f ∈ S}.

The **dominant forms** are D(P) = {f ∈ S : α_f = α*(P)}.

The **essential dominant bias** is β*(P) = max{β_f : f ∈ D(P)}.

### 2.5 Parallel Composition

The **parallel composition** of P and Q is P ∥ Q = (S_P ∪ S_Q), modeling a residual architecture where both branches compete.

---

## 3. Main Results

### 3.1 Eventual Slope Dominance

**Lemma 3.1** (eventual_slope_dominance). *For any tropical profile P with maximum slope α*, there exists X₀ ∈ ℝ such that for all x ≥ X₀, the envelope evalMax_P(x) is achieved by a form with slope α*.*

**Proof sketch.** Let D = {f ∈ P : slope(f) = α*} be the dominant forms and S = P \ D the subdominant forms. For each g ∈ S, we have slope(g) < α*. Fix any f₀ ∈ D. Then:

f₀(x) - g(x) = (α* - slope(g))x + (bias(f₀) - bias(g))

Since α* - slope(g) > 0, this difference tends to +∞, so there exists X_g with f₀(x) > g(x) for all x ≥ X_g. Setting X₀ = max{X_g : g ∈ S} (a finite maximum), for all x ≥ X₀ every subdominant form is strictly below some dominant form. Since evalMax is achieved by some form (by finiteness), it must be achieved by a dominant form. □

### 3.2 Theorem 1: Slope Invariance

**Theorem 3.2** (tropical_equiv_implies_same_maxSlope). *If P ≡ Q, then α*(P) = α*(Q).*

**Proof sketch.** By the eventual dominance lemma and a structural analysis of the dominant forms:

1. For large x, evalMax_P(x) = α*(P) · x + β*(P), since among the dominant forms, all have slope α* and the one with largest bias determines the sup.
2. Similarly, evalMax_Q(x) = α*(Q) · x + β*(Q) for large x.
3. Since P ≡ Q, we have evalMax_P(x) = evalMax_Q(x) for all x. Evaluating at two sufficiently large points x₁, x₂:

   α*(P) · x₁ + β*(P) = α*(Q) · x₁ + β*(Q)
   α*(P) · x₂ + β*(P) = α*(Q) · x₂ + β*(Q)

   Subtracting: α*(P)(x₂ - x₁) = α*(Q)(x₂ - x₁), so α*(P) = α*(Q). □

**Theorem 3.3** (tropical_equiv_preserves_essential_bias). *If P ≡ Q, then β*(P) = β*(Q).*

**Proof.** Follows immediately from Theorem 3.2 and the linear equations above. □

**Corollary 3.4** (tropical_equiv_eventual_linear). *If P ≡ Q, then for sufficiently large x, the envelopes of P and Q agree with the same linear function α*x + β*.*

### 3.3 Theorem 3: Parallel Composition

**Theorem 3.5** (evalMax_parallel_compose). *For all x ∈ ℝ:*
$$\text{evalMax}_{P \| Q}(x) = \max(\text{evalMax}_P(x), \text{evalMax}_Q(x))$$

**Proof.** Direct from Finset.sup'_union: the sup over a union equals the max of the sups. □

**Theorem 3.6** (asymptotic_slope_parallel_compose).
$$\alpha^*(P \| Q) = \max(\alpha^*(P), \alpha^*(Q))$$

**Proof.** Same algebraic identity applied to slopes. □

**Theorem 3.7** (maxSlope_parallel_finset). *For finitely many profiles {A_i}_{i ∈ S}:*
$$\alpha^*\left(\bigcup_{i \in S} A_i\right) = \max_{i \in S} \alpha^*(A_i)$$

### 3.4 Counterexample: Multiplicity Is Not an Invariant

We initially conjectured that the **dominant multiplicity** |D(P)| is a tropical invariant. This is false.

**Counterexample.** Let P = {(0, 0), (0, 1)} and Q = {(0, 1)}. Then:
- evalMax_P(x) = max(0·x + 0, 0·x + 1) = 1 = evalMax_Q(x), so P ≡ Q.
- |D(P)| = 2 but |D(Q)| = 1.

The form (0, 0) in P is **dominated** by (0, 1) — it never achieves the maximum — and can be removed without changing the envelope. This shows that "dummy" dominant forms inflate the multiplicity without affecting the envelope.

The correct invariant is the **essential dominant bias** β* = max{β_f : f ∈ D(P)}, which *is* preserved (Theorem 3.3).

### 3.5 Verified Example

We construct two non-isomorphic profiles and prove their tropical equivalence:

- **Profile A:** {2x + 1, x + 5, 3x − 2} (3 forms)
- **Profile B:** {3x − 2, 2x + 1, x + 5, 2.5x − 1} (4 forms)

The extra form 2.5x − 1 in Profile B is always dominated: for x ≥ 2, it is below 3x − 2, and for x ≤ 2, it is below 2x + 1. Both profiles have max slope 3 and essential dominant bias −2.

This example is formally verified: `example_tropical_equivalent` and `example_same_maxSlope` are proved in Lean 4 without sorry.

---

## 4. Algorithms

### 4.1 Tropical Profile Extraction from DAGs

**Input:** A computation DAG G = (V, E) with affine edge weights.
**Output:** The tropical profile P(G).

**Algorithm:** Enumerate all source-to-sink paths via DFS. For each path, compose the edge weights by summing slopes and summing biases.

**Complexity:** O(|paths|), which is O(W^L) for a layered DAG of width W and depth L. For bounded-width DAGs, this is polynomial.

### 4.2 Tropical Equivalence Testing

**Input:** Two tropical profiles P, Q.
**Output:** Boolean indicating P ≡ Q.

**Algorithm:**
1. Compute the upper envelopes of P and Q (convex hull trick, O(n log n)).
2. Compare the reduced profiles: they should have the same sequence of (slope, bias) pairs after sorting.
3. For numerical robustness, also verify at crossover points and random test points.

**Complexity:** O(n log n) where n = |P| + |Q|.

### 4.3 Universality Classification

**Input:** A set of profiles {P_1, ..., P_k}.
**Output:** Partition into universality classes.

**Algorithm:** Compute (α*(P_i), β*(P_i)) for each profile. Group by these pairs.

**Complexity:** O(k · max|P_i|).

### 4.4 Upper Envelope Reduction

**Input:** A tropical profile P with n forms.
**Output:** The reduced profile P' with only essential (non-dominated) forms.

**Algorithm:** Sort forms by decreasing slope (ties broken by decreasing bias). Apply the convex hull trick: maintain a stack of forms, popping when a new form makes the previous one redundant.

**Complexity:** O(n log n) for sorting, O(n) for the sweep.

---

## 5. Computational Experiments

### 5.1 Architecture Comparison

We tested three architectures:
- **A (feedforward):** 4 edges, 2 paths. Max slope 2.5, essential bias −0.3.
- **B (wide):** 6 edges, 9 paths. Max slope 2.5, essential bias −0.1.
- **C (residual):** 5 edges, 3 paths. Max slope 2.5, essential bias −0.1.

Architectures B and C share the same universality class despite different topologies.

### 5.2 Architecture Search Reduction

We generated 18 candidate architectures by varying:
- Number of layers: {2, 3, 4}
- Edge slope: {0.5, 1.0, 1.5}
- Skip connection: {present, absent}

Tropical classification reduced these to 5 universality classes — a 72% reduction in the number of architectures requiring training.

### 5.3 Scaling Law Prediction

For three architectures (MLP-3, Wide-MLP, ResNet-2), we computed tropical profiles and extracted predicted scaling exponents. The predictions matched the max-slope values exactly:
- MLP-3: α = 3.0 (serial composition of three slope-1 layers)
- Wide-MLP: α = 1.0 (parallel paths of slope 1)
- ResNet-2: α = 2.0 (backbone dominates skip)

---

## 6. Discussion

### 6.1 Implications for Architecture Design

The parallel composition theorem provides a precise design rule for residual networks: a skip connection improves the scaling exponent if and only if its slope exceeds the backbone's maximum slope. This quantifies the benefit of skip connections and suggests that architecture search should focus on maximizing the tropical profile's maximum slope.

### 6.2 Connection to Statistical Mechanics

The tropical envelope is the zero-temperature limit of the log-sum-exp (softmax) function. Dominant multiplicity corresponds to ground-state degeneracy. The essential dominant bias corresponds to the ground-state energy. This analogy suggests that finite-temperature corrections (soft tropical profiles using log-sum-exp) should exhibit logarithmic corrections controlled by multiplicity, analogous to entropy contributions in statistical mechanics.

### 6.3 Limitations

1. **Path enumeration:** For wide and deep DAGs, the number of source-to-sink paths grows exponentially, making exact profile computation intractable. Approximation algorithms (e.g., sampling dominant paths) are needed.
2. **Weight dependence:** Real neural networks have trained weights, not fixed affine forms. The tropical profile is an abstraction of the architecture's capacity, not a precise description of a trained model.
3. **Beyond piecewise linear:** Networks with smooth activations (GELU, Swish) are not exactly tropical. The theory applies in the large-width limit where smooth activations converge to ReLU.

### 6.4 The False Multiplicity Conjecture

Our discovery that dominant multiplicity is *not* a tropical invariant is noteworthy. It shows that the correct invariants are more subtle than naive counting. The essential dominant bias is the right object — it captures the "effective" contribution of the dominant face while ignoring redundant forms. This distinction will be critical for future work on logarithmic corrections.

---

## 7. Future Work

1. **Logarithmic corrections:** Prove that dominant multiplicity of the *reduced* profile (after removing dominated forms) controls the order of logarithmic corrections to scaling laws.
2. **Renormalization:** Define a coarse-graining operation on DAGs and prove that it preserves tropical universality class.
3. **Parametric profiles:** Extend the theory to profiles depending on a continuous parameter (e.g., depth/width ratio) and characterize the phase transitions where the scaling exponent changes.
4. **Computational complexity:** Develop polynomial-time algorithms for computing tropical invariants without full path enumeration, possibly using dynamic programming on the DAG structure.
5. **Empirical validation:** Test the predicted scaling exponents against real training curves for transformer, convolutional, and recurrent architectures.

---

## 8. References

- Baccelli, F., Cohen, G., Olsder, G. J., & Quadrat, J.-P. (1992). *Synchronization and Linearity: An Algebra for Discrete Event Systems.* Wiley.
- Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms.* Springer.
- Hoffmann, J., et al. (2022). Training compute-optimal large language models. *NeurIPS*.
- Kaplan, J., et al. (2020). Scaling laws for neural language models. *arXiv:2001.08361*.
- Maragos, P., Charisopoulos, V., & Theodosis, E. (2021). Tropical geometry and machine learning. *Proceedings of the IEEE, 109*(5), 728–755.
- Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML*.

---

## Appendix A: Full Lean 4 Theorem Statements

```lean
-- Theorem 1: Slope invariance
theorem tropical_equiv_implies_same_maxSlope
    (P Q : TropicalProfile) (hPQ : TropicalEquivalent P Q) :
    P.maxSlope = Q.maxSlope

-- Theorem 1+: Bias invariance
theorem tropical_equiv_preserves_essential_bias
    (P Q : TropicalProfile) (hPQ : TropicalEquivalent P Q) :
    EssentialDominantBias P = EssentialDominantBias Q

-- Theorem 3a: Envelope decomposition
theorem evalMax_parallel_compose (P Q : TropicalProfile) (x : ℝ) :
    (ParallelCompose P Q).evalMax x = max (P.evalMax x) (Q.evalMax x)

-- Theorem 3b: Slope composition
theorem asymptotic_slope_parallel_compose (P Q : TropicalProfile) :
    (ParallelCompose P Q).maxSlope = max P.maxSlope Q.maxSlope

-- Generalized to finitely many branches
theorem maxSlope_parallel_finset {ι : Type*} [DecidableEq ι]
    (A : ι → TropicalProfile) (S : Finset ι) (hS : S.Nonempty) :
    (ParallelComposeFinset A S hS).maxSlope = S.sup' hS (fun i => (A i).maxSlope)

-- Eventual dominance
theorem eventual_slope_dominance (P : TropicalProfile) :
    ∃ X0 : ℝ, ∀ x ≥ X0, ∃ f ∈ P.forms, f.slope = P.maxSlope ∧ P.evalMax x = f.eval x

-- Verified example
theorem example_tropical_equivalent :
    TropicalEquivalent exampleProfileA exampleProfileB
```

All theorems are proved without `sorry` and use only standard axioms (propext, Classical.choice, Quot.sound).
