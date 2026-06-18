# Categorical Deviation Theory: Surprise Subadditivity, Chain Bounds, and Functorial Monotonicity in Metric-Enriched Quivers

## Abstract

We introduce **Categorical Deviation Theory**, a framework for studying the algebraic properties of deviation from expected behavior in compositional systems. The central objects are *composable expectation quivers* — directed graphs where each hom-set carries a pseudometric, composition is nonexpansive, and each hom-set has a distinguished "expected" morphism. The *surprise functional* σ(f) = d(f, e) measures deviation of a morphism f from the expected morphism e.

Our main results establish that surprise is (1) subadditive under coherent expectations, (2) linearly bounded along chains of n compositions, (3) preserved as zero under nonexpansive expectation-preserving morphisms, and (4) stable under arbitrary iteration in deviation monoids. We prove a sharp characterization of coherence via vanishing coherence defects, construct the real line as a canonical coherent example, and develop graded deviation systems where intermediate elements modulate deviation accumulation.

All results are formalized and verified in Lean 4 with the Mathlib library.

## 1. Introduction

### 1.1 Motivation

In many mathematical and applied contexts, one works with compositional systems where each operation has an "expected" or "canonical" outcome, and the actual outcome may deviate from this expectation. Examples include:

- **Approximation theory**: Approximate maps compose, and errors propagate
- **Numerical analysis**: Each computational step introduces rounding errors
- **Control theory**: Actuator commands deviate from planned trajectories
- **Information geometry**: Statistical updates deviate from predicted posteriors
- **Network reliability**: Relay chains accumulate distortion

A common question across these domains is: *given bounds on individual deviations, what can we say about the deviation of a composed sequence?* Existing answers tend to be domain-specific. We provide a unified categorical framework.

### 1.2 Overview of Results

We define the following hierarchy of structures:

1. **MetricQuiver** (§2): A quiver with pseudometric hom-sets
2. **ExpectationQuiver** (§3): A MetricQuiver with expected morphisms and the surprise functional
3. **ComposableMetricQuiver** (§4): A MetricQuiver with nonexpansive composition
4. **ComposableExpectationQuiver** (§5): The full structure, supporting surprise analysis
5. **DeviationMonoid** (§7): The single-object case, connecting to monoid theory
6. **GradedDeviationSystem** (§8): An enrichment with grade-dependent deviation bounds

Our main theorems:

- **Theorem A** (Surprise Subadditivity, Thm 5.2): Under coherent expectations, σ(g∘f) ≤ σ(f) + σ(g).
- **Theorem B** (Chain Surprise Bound, Thm 6.1): For a chain of n+1 morphisms, σ(fₙ∘⋯∘f₁) ≤ Σᵢ σ(fᵢ).
- **Theorem C** (Zero-Surprise Closure, Thm 5.3): Zero-surprise morphisms form a sub-quiver closed under composition.
- **Theorem D** (Power Deviation Bound, Thm 7.3): In a deviation monoid, δ(aⁿ) ≤ n·δ(a).
- **Theorem E** (Surprise Monotonicity, Thm 9.1): Nonexpansive expectation-preserving maps decrease surprise.

## 2. Metric Quivers

**Definition 2.1** (MetricQuiver). A *metric quiver* Q = (Obj, Hom, d) consists of:
- A type Obj of objects
- For each pair a,b : Obj, a type Hom(a,b) of morphisms
- For each a,b, a function d : Hom(a,b) × Hom(a,b) → ℝ satisfying:
  - d(f,f) = 0 (reflexivity)
  - d(f,g) = d(g,f) (symmetry)
  - d(f,g) ≥ 0 (nonnegativity)
  - d(f,h) ≤ d(f,g) + d(g,h) (triangle inequality)

**Definition 2.2** (Separated). A metric quiver is *separated* if d(f,g) = 0 implies f = g.

**Remark 2.3**. Metric quivers are a special case of enriched categories over the monoidal category (PseudoMet, ⊗, {*}) of pseudometric spaces. Our treatment is self-contained and does not require the full enriched category machinery.

## 3. Expectation Systems and Surprise

**Definition 3.1** (ExpectationQuiver). An *expectation quiver* E = (Q, e) consists of a metric quiver Q and a family of expected morphisms e(a,b) ∈ Hom(a,b) for each pair a,b.

**Definition 3.2** (Surprise). The *surprise* of f ∈ Hom(a,b) is σ(f) = d(f, e(a,b)).

**Proposition 3.3**. For any expectation quiver:
1. σ(f) ≥ 0
2. σ(e(a,b)) = 0
3. In a separated quiver, σ(f) = 0 iff f = e(a,b)

**Theorem 3.4** (Surprise Lipschitz Property). |σ(f) - σ(g)| ≤ d(f,g).

*Proof.* From the triangle inequality: σ(f) = d(f,e) ≤ d(f,g) + d(g,e) = d(f,g) + σ(g), giving σ(f) - σ(g) ≤ d(f,g). By symmetry of d, σ(g) - σ(f) ≤ d(g,f) = d(f,g). ∎

**Remark 3.5**. The Lipschitz property means surprise is a 1-Lipschitz function on each hom-set with the pseudometric topology. In particular, it is continuous.

## 4. Composable Metric Quivers

**Definition 4.1** (ComposableMetricQuiver). A *composable metric quiver* extends a metric quiver with composition comp : Hom(b,c) × Hom(a,b) → Hom(a,c) satisfying *joint nonexpansiveness*:

d(comp(f₁,g₁), comp(f₂,g₂)) ≤ d(f₁,f₂) + d(g₁,g₂)

**Proposition 4.2**. Nonexpansiveness in each argument separately follows:
1. d(f₁∘g, f₂∘g) ≤ d(f₁,f₂)
2. d(f∘g₁, f∘g₂) ≤ d(g₁,g₂)

## 5. Composable Expectation Quivers

**Definition 5.1** (Coherence). Expectations are *coherent* if comp(e(b,c), e(a,b)) = e(a,c) for all a,b,c.

**Definition 5.2** (Coherence Defect). The coherence defect at (a,b,c) is δ(a,b,c) = d(comp(e(b,c), e(a,b)), e(a,c)).

**Theorem 5.3** (Surprise Subadditivity with Correction).
σ(g∘f) ≤ σ(g) + σ(f) + δ(a,b,c)

*Proof sketch.* Apply the triangle inequality to split d(g∘f, e(a,c)) through the intermediate point comp(e(b,c), e(a,b)), then use nonexpansiveness of composition. ∎

**Corollary 5.4** (Coherent Subadditivity). Under coherent expectations: σ(g∘f) ≤ σ(g) + σ(f).

**Theorem 5.5** (Zero-Surprise Closure). Under coherent expectations, if σ(f) = 0 and σ(g) = 0, then σ(g∘f) = 0.

*Proof.* σ(g∘f) ≤ σ(g) + σ(f) = 0, and σ(g∘f) ≥ 0, so σ(g∘f) = 0. ∎

**Theorem 5.6** (Coherence Characterization). In a separated quiver, coherence holds iff all coherence defects vanish.

**Theorem 5.7** (Expected Left Composition). Under coherence, composing with an expected morphism preserves the surprise bound: σ(e(b,c) ∘ g) ≤ σ(g).

## 6. Chain Surprise Bounds

**Definition 6.1** (MorphismChain). An (n+1)-morphism chain from a to b is a sequence f₁,...,fₙ₊₁ of composable morphisms.

**Definition 6.2** (Total Surprise). totalSurprise(chain) = Σᵢ σ(fᵢ).

**Theorem 6.3** (Chain Surprise Bound). Under coherent expectations:
σ(compose(chain)) ≤ totalSurprise(chain)

*Proof.* By induction on chain length, using coherent subadditivity at each step. ∎

**Corollary 6.4**. If each morphism in an (n+1)-chain has surprise ≤ ε, then the composed morphism has surprise ≤ (n+1)ε.

## 7. Deviation Monoids

**Definition 7.1** (DeviationMonoid). A *deviation monoid* M = (S, ·, 1, d) is a monoid (S, ·, 1) with a pseudometric d such that multiplication is jointly nonexpansive.

**Definition 7.2**. The *deviation* of a ∈ S is δ(a) = d(a, 1).

**Proposition 7.3**.
1. δ(a) ≥ 0
2. δ(1) = 0
3. δ(a·b) ≤ δ(a) + δ(b) (subadditivity)

**Theorem 7.4** (Power Deviation Bound). δ(aⁿ) ≤ n · δ(a).

*Proof.* By induction on n. Base case: δ(a⁰) = δ(1) = 0 ≤ 0. Inductive step: δ(aⁿ⁺¹) = δ(a · aⁿ) ≤ δ(a) + δ(aⁿ) ≤ δ(a) + n·δ(a) = (n+1)·δ(a). ∎

**Theorem 7.5** (Deviation Stability). If δ(a) = 0, then δ(aⁿ) = 0 for all n.

**Proposition 7.6** (Monoid-Quiver Correspondence). Every deviation monoid gives rise to a single-object composable expectation quiver, which is automatically coherent.

## 8. Graded Deviation Systems

**Definition 8.1** (GradedDeviationSystem). A *graded deviation system* G = (S, γ, d) consists of a carrier S, a grading γ : S → ℝ≥0, and a pseudometric d, such that:
- d satisfies standard pseudometric axioms
- Graded triangle: d(a,c) ≤ d(a,b) + d(b,c) + γ(b)

The graded triangle inequality says that high-grade intermediaries contribute additional deviation beyond what the standard triangle inequality allows.

**Theorem 8.2** (Chain Graded Bound). For four points a,b,c,d:
d(a,d) ≤ d(a,b) + d(b,c) + d(c,d) + γ(b) + γ(c)

**Theorem 8.3** (Zero-Grade Transparency). If γ(b) = 0, then d(a,c) ≤ d(a,b) + d(b,c) (standard triangle inequality).

## 9. Functoriality of Surprise

**Definition 9.1** (QuiverMorphism). A morphism φ : E₁ → E₂ between composable expectation quivers consists of maps on objects and morphisms that are nonexpansive and preserve expectations.

**Theorem 9.2** (Surprise Monotonicity). If φ : E₁ → E₂ is a quiver morphism, then σ₂(φ(f)) ≤ σ₁(f).

*Proof.* σ₂(φ(f)) = d₂(φ(f), e₂(φ(a),φ(b))) = d₂(φ(f), φ(e₁(a,b))) ≤ d₁(f, e₁(a,b)) = σ₁(f). ∎

**Corollary 9.3** (Zero Preservation). Quiver morphisms preserve zero-surprise: σ₁(f) = 0 implies σ₂(φ(f)) = 0.

## 10. The Real Line Example

**Construction 10.1**. The *real line quiver* has:
- Objects: ℝ
- Hom(a,b) = ℝ (jumps of any size)
- d(f,g) = |f - g|
- comp(f,g) = f + g (sequential jumps add)
- e(a,b) = b - a (direct displacement)

**Theorem 10.2**. The real line quiver is coherent: (b-a) + (c-b) = c-a.

**Theorem 10.3**. Surprise in the real line quiver equals |f - (b-a)|.

## 11. Discussion

### 11.1 Relationship to Enriched Category Theory

Composable expectation quivers are related to categories enriched over (PseudoMet, ⊕, {*}). The novel contribution is the expectation system and the resulting surprise functional, which has no direct analogue in standard enriched category theory.

### 11.2 Relationship to Wasserstein Distances

The nonexpansiveness condition on composition is reminiscent of the Kantorovich-Rubinstein duality in optimal transport. In fact, one can construct composable expectation quivers from optimal transport problems, where the expected morphism is the optimal transport map and surprise equals the excess transport cost.

### 11.3 Tightness of Bounds

The chain surprise bound σ(compose(chain)) ≤ Σᵢ σ(fᵢ) is tight: in the real line quiver, taking each jump to be exactly ε more than expected gives total surprise nε.

### 11.4 Open Questions

1. **Multiplicative bounds**: Under what conditions does surprise satisfy σ(g∘f) ≤ σ(g)·σ(f)?
2. **Spectral surprise**: Can the infimum and supremum of surprise over a hom-set be characterized algebraically?
3. **Higher coherence**: What role do higher-order coherence conditions play?
4. **Categorical limits**: How does surprise interact with categorical limits and colimits?

## 12. Conclusion

Categorical Deviation Theory provides a principled framework for analyzing how deviations from expected behavior accumulate under composition. The key insight — that nonexpansive composition paired with coherent expectations yields subadditive surprise — unifies diverse phenomena across mathematics and its applications.

The formalization in Lean 4 ensures that all results are rigorously verified, and the modular structure of the theory (MetricQuiver → ExpectationQuiver → ComposableExpectationQuiver → DeviationMonoid) provides clean interfaces for future extensions.

## References

1. Kelly, G.M. (1982). *Basic Concepts of Enriched Category Theory*. London Math. Soc. Lecture Note Series.
2. Lawvere, F.W. (1973). Metric spaces, generalized logic, and closed categories. *Rendiconti del Seminario Matematico e Fisico di Milano*.
3. Villani, C. (2009). *Optimal Transport: Old and New*. Springer.
4. Borceux, F. (1994). *Handbook of Categorical Algebra*. Cambridge University Press.
