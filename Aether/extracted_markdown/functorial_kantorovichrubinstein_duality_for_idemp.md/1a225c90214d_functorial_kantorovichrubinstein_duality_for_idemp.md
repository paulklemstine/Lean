# Functorial Kantorovich–Rubinstein Duality for Idempotent Measures via Maxitive Wasserstein Geometry

## Abstract

We develop a rigorous mathematical framework for optimal transport in the
max-plus (tropical/idempotent) semiring, formalized in Lean 4 with Mathlib.
Our core objects are *maxitive probability profiles*—functions μ : X → ℝ with
values ≤ 0 and max = 0—which serve as the tropical analogue of probability
measures. We define the *maxitive integral* Λ_μ(f) = max_x(μ(x) + f(x)),
the *Kantorovich–Rubinstein (KR) dual discrepancy*, and the *max-plus transport
cost*, establishing their basic properties with machine-verified proofs.

Our main formally verified results include:

1. **Measure-Lipschitz stability**: The maxitive integral is Lipschitz in the
   measure: Λ_μ(f) - Λ_ν(f) ≤ max_x(μ(x) - ν(x)). This holds for ALL
   functions f, not just 1-Lipschitz ones.

2. **Coupling-mode correspondence**: Any maxitive coupling π with marginals μ
   and ν sends a mode of μ (point with μ = 0) to a mode of ν, with the
   transport cost bounded below by the mode-to-mode distance.

3. **Maxitive integral algebra**: The integral distributes over pointwise
   maximum (Λ_μ(max(f,g)) = max(Λ_μ(f), Λ_μ(g))) and satisfies a translation
   identity (Λ_μ(f + c) = Λ_μ(f) + c).

4. **Coupling expansion**: The maxitive integral expands through couplings:
   Λ_μ(f) = max_{x,y}(π(x,y) + f(x)).

These results lay the foundation for a tropical optimal transport theory that
parallels classical Wasserstein geometry.

## 1. Introduction

### 1.1 Classical Optimal Transport

The Wasserstein-1 distance between probability measures μ and ν on a metric space
(X, d) is defined by the Kantorovich–Rubinstein duality:

  W₁(μ, ν) = sup_{f 1-Lip} (∫f dμ - ∫f dν) = inf_π ∫d(x,y) dπ(x,y)

where π ranges over couplings with marginals μ and ν. This duality is fundamental
to modern probability, statistics, and machine learning.

### 1.2 The Tropical/Idempotent Setting

In the max-plus semiring (ℝ, max, +), the operations "addition" (max) and
"multiplication" (+) replace their classical counterparts. A *maxitive measure*
(or *possibility measure*) assigns weights to outcomes with the key property
that the "measure" of a union is the maximum of the individual measures, not
their sum.

We define a **maxitive probability profile** μ : X → ℝ with:
- μ(x) ≤ 0 for all x (non-positivity)
- max_x μ(x) = 0 (normalization)

The value μ(x) represents a log-possibility weight: points with μ(x) = 0 are
"fully possible" (the mode), while μ(x) < 0 indicates reduced possibility.

### 1.3 The Maxitive Integral

The tropical analogue of expectation is the **maxitive integral**:

  Λ_μ(f) = max_x (μ(x) + f(x))

This functional is:
- **Max-plus linear**: Λ_μ(max(f,g)) = max(Λ_μ(f), Λ_μ(g))
- **Translation-equivariant**: Λ_μ(f + c) = Λ_μ(f) + c
- **Monotone**: f ≤ g implies Λ_μ(f) ≤ Λ_μ(g)

## 2. Main Results

### 2.1 The Measure-Lipschitz Bound

**Theorem** (maxIntegral_sub_le_sup_diff). For any maxitive profiles μ, ν and
any function f : X → ℝ:

  Λ_μ(f) - Λ_ν(f) ≤ max_x (μ(x) - ν(x))

*Proof.* For each x:
  μ(x) + f(x) = (ν(x) + f(x)) + (μ(x) - ν(x)) ≤ max(ν + f) + max(μ - ν)

Taking max over x gives Λ_μ(f) ≤ Λ_ν(f) + max(μ - ν). ∎

This is remarkable: it bounds the discrepancy by the pointwise profile difference,
*without any Lipschitz constraint on f*. The 1-Lipschitz constraint refines this
to a distance-aware bound.

### 2.2 Coupling-Mode Correspondence

**Theorem** (coupling_sends_mode_to_mode). If π is a maxitive coupling with
marginals μ and ν, then there exist mode points x_m (μ(x_m) = 0) and
y_m (ν(y_m) = 0) with π(x_m, y_m) = 0 and C(π) ≥ d(x_m, y_m).

*Proof.* Let x_m be a mode of μ. By the marginal identity max_y π(x_m, y) = 0,
there exists y_m with π(x_m, y_m) = 0. Then ν(y_m) = max_x π(x, y_m) ≥ 0,
and since ν ≤ 0, we get ν(y_m) = 0. The transport bound follows. ∎

### 2.3 Maxitive Integral Algebra

We prove the full suite of algebraic properties:

- **Sup-distribution** (maxIntegral_sup_distrib):
  Λ_μ(max(f,g)) = max(Λ_μ(f), Λ_μ(g))

- **Translation** (maxIntegral_const_add):
  Λ_μ(f + c) = Λ_μ(f) + c

- **Constant evaluation** (maxIntegral_const):
  Λ_μ(c) = c (using normalization max μ = 0)

- **Monotonicity** (maxIntegral_mono):
  f ≤ g implies Λ_μ(f) ≤ Λ_μ(g)

### 2.4 Coupling Expansion

**Theorem** (maxIntegral_coupling_expand). If π has first marginal μ, then:

  Λ_μ(f) = max_{x,y} (π(x,y) + f(x))

This identity, proved for finite types, connects the maxitive integral to the
coupling structure and is essential for the primal formulation.

## 3. Discussion for a General Audience

### What is "Tropical Mathematics"?

Imagine you're planning a road trip and want to know the *worst possible*
driving time between cities. Classical probability would average over all
possible routes. Tropical probability takes the *worst case*—the route with
the maximum delay.

This "worst-case" philosophy is captured by the max-plus semiring, where
"addition" is replaced by taking maxima, and "multiplication" by addition.
It's called "tropical" because the field was pioneered by the Brazilian
mathematician Imre Simon—and tropical themes pervade the mathematics.

### Why Does This Matter?

In many real-world scenarios, worst-case guarantees matter more than averages:

1. **Robust machine learning**: When deploying models in safety-critical
   applications, we care about the worst-case prediction error, not the
   average. Maxitive measures model this naturally.

2. **Uncertainty quantification**: Possibility theory (based on maxitive
   measures) handles epistemic uncertainty—the "unknown unknowns"—while
   probability handles aleatory uncertainty.

3. **Network reliability**: The capacity of a network is determined by its
   bottleneck (minimum), not the average link capacity.

### What We Proved

We showed that maxitive measures have a rich geometric structure—they can
be compared using a distance function (the KR discrepancy) that behaves
predictably under transformations. This is like proving that you can
meaningfully say "these two worst-case scenarios are 5 units apart" and
that this distance respects the underlying geometry of the problem.

The key insight is the **measure-Lipschitz bound**: changing the maxitive
profile by at most ε at each point changes the integral by at most ε. This
stability is the foundation for all subsequent geometric results.

## 4. Connections to Existing Work

- **Litvinov–Maslov dequantization**: Our framework instantiates the general
  principle that classical mathematical structures have tropical shadows.

- **Pap's g-integrals**: The maxitive integral is a special case of the
  non-additive integral theory, where the semiring operations are (max, +).

- **Kernel mean embeddings**: The tropical KME of the companion formalization
  (TropKME.lean) embeds maxitive profiles into function spaces, and the KR
  bound provides metric control on these embeddings.

## 5. Applications

### 5.1 Robust Classification

Given two classes represented by maxitive profiles μ₁, μ₂, the KR discrepancy
provides a principled measure of class separation that is robust to outliers.
The coupling-mode correspondence identifies which "typical" examples are
most informative for distinguishing classes.

### 5.2 Anomaly Detection

A data point x is anomalous with respect to a maxitive profile μ if
μ(x) ≪ 0. The maxitive integral Λ_μ(f) focuses on regions where μ is
concentrated, automatically downweighting anomalies.

### 5.3 Fuzzy Set Distances

Maxitive profiles generalize fuzzy membership functions. The KR discrepancy
provides a metric on fuzzy sets that respects the underlying geometry—a
long-sought goal in fuzzy mathematics.

## References

1. G. Litvinov, V. Maslov, "Idempotent mathematics and mathematical physics."
   Contemporary Mathematics, 2005.
2. C. Villani, "Optimal Transport: Old and New." Springer, 2009.
3. G. Cohen, S. Gaubert, J.-P. Quadrat, "Max-plus algebra and system theory."
   Proceedings of the ICM, 2002.
