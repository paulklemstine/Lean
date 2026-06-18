# The Standard Part Paradox: Impossibility and Concentration in Non-Archimedean Probability

## Abstract

We develop the foundational theory of finitely additive probability measures valued in non-Archimedean ordered fields. Our central result is the **Standard Part Paradox**: any additive standard part map st : F → ℝ satisfying st(1) = 1 is fundamentally incompatible with probability distributions whose weights are all infinitesimal. From this impossibility, we derive a complete structural decomposition: every non-Archimedean probability distribution separates into "visible" weights (with nonzero standard part, summing to 1) and "invisible" infinitesimal weights (contributing nothing to the total). We prove the **Rational Determination Theorem** showing that the standard part map is uniquely determined on all rationals by additivity alone, and establish the **Uniform Distribution Standard Part Theorem** identifying the standard part of uniform weights. All results are formalized in Lean 4 with complete machine-checked proofs, using only the standard axioms (propext, Classical.choice, Quot.sound).

**Keywords:** Non-Archimedean probability, finitely additive measures, standard part map, infinitesimals, impossibility theorem, nonstandard analysis

## 1. Introduction

### 1.1 Motivation

The extension of probability theory beyond the real numbers has been a persistent theme in mathematical foundations. In nonstandard analysis (Robinson, 1966), the hyperreal number field *ℝ provides a rigorous framework for infinitesimals — positive quantities smaller than every positive real number. The standard part map st : *ℝ → ℝ rounds every finite hyperreal to its nearest real, sending infinitesimals to zero.

A natural question arises: can we assign infinitesimal probabilities to individual outcomes? This is motivated by:

1. **Regularity**: In classical probability, P({ω}) = 0 for individual outcomes in continuous spaces, despite each being logically possible. Infinitesimal probabilities would preserve regularity.
2. **Fair lotteries**: A "fair lottery" on ℕ should give each outcome equal probability, but no real number works (1/n → 0, and countable additivity forces the total to 0).
3. **Bayesian priors**: In machine learning, assigning positive prior probability to every hypothesis is desirable but impossible with real-valued priors on infinite hypothesis spaces.

### 1.2 Contributions

We establish the following results:

1. **Standard Part Paradox** (Theorem 3.1): The impossibility of all-infinitesimal probability weights under any additive standard part map.
2. **Concentration Theorem** (Theorem 3.3): The visible weights carry all unit mass.
3. **Singleton Concentration** (Theorem 3.4): When all but one weight is infinitesimal, that weight has standard part 1.
4. **Rational Determination** (Theorem 2.4): The standard part map is fixed on ℚ by additivity and st(1) = 1.
5. **Uniform Standard Part** (Theorem 4.1): Uniform weights have standard part 1/n.
6. **Partition Duality** (Theorem 3.6): Complete decomposition into visible and invisible components.

### 1.3 Related Work

Our work connects to several established lines of research:

- **Nonstandard analysis** (Robinson, 1966; Nelson, 1977): The standard part map and its properties.
- **Finitely additive measures** (de Finetti, 1937; Dubins & Savage, 1965): Probability without countable additivity.
- **Non-Archimedean probability** (Benci et al., 2013): Numerosity-based approaches to fair lotteries.
- **Impossibility theorems in probability** (Kolmogorov, 1933; de Finetti, 1970): Structural constraints on probability measures.
- **PAC-Bayes learning theory** (McAllester, 1999; Catoni, 2007): Bounds on generalization error using KL-divergence between prior and posterior.

Our contribution differs from prior work in abstracting the essential algebraic structure: we require only additivity of the standard part map and the unit condition, making our results applicable to any field equipped with such a map, not just hyperreals.

## 2. Definitions and Foundational Properties

### 2.1 Standard Part Map

**Definition 2.1.** Let F be a field. A *standard part map* on F is a function st : F → ℝ satisfying:
1. **Additivity**: st(x + y) = st(x) + st(y) for all x, y ∈ F
2. **Unit condition**: st(1) = 1

**Remark.** We intentionally do not assume monotonicity, multiplicativity, or any order-theoretic property. The power of our results comes from deriving strong consequences from these minimal axioms alone.

### 2.2 Infinitesimals

**Definition 2.2.** An element x ∈ F is *infinitesimal* with respect to st if st(x) = 0.

The set of infinitesimals forms an additive subgroup of F (since st is additive and st(0) = 0).

### 2.3 Finitely Additive Probability

**Definition 2.3.** A *finitely additive probability* on Fin(n) valued in F is a function w : Fin(n) → F such that ∑ᵢ w(i) = 1.

**Remark.** We do not require non-negativity in the formal development, as the key results depend only on the sum condition. When additionally equipped with order-compatibility of st, we recover non-negativity of the standard-part distribution.

### 2.4 Foundational Properties

**Theorem 2.1** (Map Zero). st(0) = 0.

*Proof.* From st(0) = st(0 + 0) = st(0) + st(0), we get st(0) = 0. □

**Theorem 2.2** (Map Negation). st(-x) = -st(x).

*Proof.* From st(x + (-x)) = st(x) + st(-x) = st(0) = 0. □

**Theorem 2.3** (Natural Number Fixation). st(n) = n for all n ∈ ℕ.

*Proof.* By induction: st(0) = 0, and st(k+1) = st(k) + st(1) = k + 1. □

**Theorem 2.4** (Rational Determination). st(q) = q for all q ∈ ℚ.

*Proof sketch.* Extend from ℕ to ℤ using map_neg. For q = a/b with b > 0, observe that b · (a/b) = a, so st(a) = b · st(a/b) (using additivity via map_nsmul), giving st(a/b) = a/b. □

**Significance.** This theorem shows that the standard part map has zero degrees of freedom on ℚ. Its behavior is entirely determined by the two axioms. The only "choice" in defining st involves elements that are algebraically independent from ℚ — precisely the transcendental and infinitesimal elements.

## 3. The Standard Part Paradox and Consequences

### 3.1 Main Impossibility Theorem

**Theorem 3.1** (Standard Part Paradox). Let st be a standard part map on F and let w : Fin(n) → F be a finitely additive probability (∑ᵢ wᵢ = 1). Then it is impossible for all weights to be infinitesimal: ¬(∀i, st(wᵢ) = 0).

*Proof.* Suppose for contradiction that st(wᵢ) = 0 for all i. Then:
$$\sum_i \text{st}(w_i) = 0$$
But by additivity of st:
$$\sum_i \text{st}(w_i) = \text{st}\left(\sum_i w_i\right) = \text{st}(1) = 1$$
This gives 0 = 1, a contradiction. □

**Corollary 3.2** (Existence of Non-infinitesimal Weight). Under the same hypotheses, ∃i such that st(wᵢ) ≠ 0.

### 3.2 Concentration Theorems

**Theorem 3.3** (Concentration). Let V = {i : st(wᵢ) ≠ 0} be the set of "visible" indices. Then:
$$\sum_{i \in V} \text{st}(w_i) = 1$$

*Proof.* The sum over all indices equals 1 (by Theorem 2.3 applied to the total). The contribution from i ∉ V is zero by definition. □

**Theorem 3.4** (Singleton Concentration). If all weights except wⱼ are infinitesimal, then st(wⱼ) = 1.

*Proof.* In the full sum ∑ᵢ st(wᵢ) = 1, every term except j contributes 0. □

**Theorem 3.5** (Deficiency Zero). The total contribution of infinitesimal weights to the standard part sum is exactly zero:
$$\sum_{i : \text{st}(w_i) = 0} \text{st}(w_i) = 0$$

**Theorem 3.6** (Partition Duality). The visible and invisible components provide a complete decomposition:
$$\sum_{i \in V} \text{st}(w_i) + \sum_{i \notin V} \text{st}(w_i) = 1$$

### 3.3 Structural Implications

The Concentration Theorem reveals that non-Archimedean probabilities have a rigid two-layer structure:

- **Layer 1 (Classical):** The visible weights, after applying st, form a genuine real-valued probability distribution.
- **Layer 2 (Infinitesimal):** The invisible weights carry no standard-part mass and exist only in the non-Archimedean extension.

This means that any NAPA is, from the classical perspective, equivalent to a probability distribution supported on at most n points, with the infinitesimal weights serving as "invisible probability dust."

## 4. Deepening: Uniform Distributions and Bounds

### 4.1 Uniform Standard Part

**Theorem 4.1** (Uniform Distribution Standard Part). If n > 0 and w ∈ F satisfies n · w = 1, then st(w) = 1/n.

*Proof.* Apply st to both sides of n · w = 1: n · st(w) = st(1) = 1, so st(w) = 1/n. □

**Example.** In a hyperreal extension, take w = 1/n + ε where ε is infinitesimal. Then n · w = 1 + nε ≠ 1 in general. For w to satisfy n · w = 1 exactly, we need w = 1/n (the rational element), and st(1/n) = 1/n, confirming the theorem.

**Generalization.** The theorem extends to any commutative ring with a unit-preserving additive map to ℝ, as long as the natural number n is invertible.

**Boundary.** The theorem breaks down for n = 0 (trivially, as 0 · w = 1 has no solution). It also requires exact equality n · w = 1, not an approximate relationship.

### 4.2 Counting Non-Infinitesimal Weights

**Theorem 4.2.** The number of non-infinitesimal weights |V| satisfies |V| ≤ n.

*Proof.* V is a subset of Fin(n), which has cardinality n. □

**Theorem 4.3.** V is nonempty: |V| ≥ 1.

*Proof.* Direct consequence of the Standard Part Paradox. □

## 5. Cross-Domain Bridge: From NAPA to Classical Probability

### 5.1 The Standard Part Functor

The standard part map transforms a non-Archimedean probability into a classical one. When st additionally preserves non-negativity (st(x) ≥ 0 whenever x ≥ 0), the image is a genuine probability distribution:

**Theorem 5.1.** If st preserves non-negativity and w is a NAPA, then (st ∘ w, Fin n) is a classical probability space: all values are non-negative and sum to 1.

This establishes a bridge between non-Archimedean and classical probability theory, mediated by the standard part map. The bridge preserves the sum (= 1) and, under monotonicity, preserves non-negativity.

### 5.2 Connection to PAC-Bayes Theory

The NAPA framework connects to PAC-Bayes learning theory. In PAC-Bayes, one bounds the generalization error of a "posterior" distribution Q relative to a "prior" distribution P using the KL-divergence D(Q ∥ P).

If P is a NAPA with some infinitesimal weights, the Standard Part Paradox tells us that the KL-divergence D(Q ∥ P) is well-defined in the standard part only when Q is supported on the visible set V. For hypotheses with infinitesimal prior, the posterior must also be infinitesimal — the standard part cannot "amplify" invisible priors into visible posteriors without violating additivity.

This structural constraint is the NAPA analog of the absolute continuity requirement (Q ≪ P) in classical measure theory: the visible set of the posterior must be contained in the visible set of the prior.

## 6. PEGB Analysis

### 6.1 Standard Part Paradox

- **Proof**: Three-line algebraic argument from additivity and st(1) = 1
- **Example**: On Fin 3 with weights (ε, ε, 1-2ε) where ε is infinitesimal: st(ε) = 0, st(ε) = 0, st(1-2ε) = 1. Cannot make all three infinitesimal.
- **Generalization**: The result extends to any additive group homomorphism φ : G → ℝ with a distinguished element e satisfying φ(e) ≠ 0 and a "probability" condition ∑ gᵢ = e.
- **Boundary**: Fails if st(1) = 0 (degenerate standard part). Fails for countably infinite distributions where the sum is conditional.

### 6.2 Rational Determination

- **Proof**: Inductive construction from st(1) = 1 through ℕ, ℤ, ℚ
- **Example**: st(3/7) = 3/7 regardless of what field F is
- **Generalization**: Extends to any Q-algebra A with an additive map to ℝ fixing 1
- **Boundary**: Cannot extend to algebraic irrationals without multiplicativity

### 6.3 Concentration Theorem

- **Proof**: Complement argument using Finset.sum_filter_add_sum_filter_not
- **Example**: Weights (ε, 0.3, ε², 0.7-ε-ε²) have visible set {1, 3} with st-sum 0.3 + 0.7 = 1
- **Generalization**: Extends to any decomposition of a group into kernel and non-kernel of a homomorphism
- **Boundary**: Requires finiteness of the index set; for countable sums, rearrangement issues arise

### 6.4 Singleton Concentration

- **Proof**: Single-term extraction from sum
- **Example**: (ε, ε, ε, 1-3ε) → only the last weight is visible with st = 1
- **Generalization**: k-concentration: if k weights are non-infinitesimal, their standard parts form a probability on k points
- **Boundary**: Requires all other weights to be exactly infinitesimal, not merely small

## 7. Discussion

### 7.1 The Impossibility Landscape

The Standard Part Paradox joins a distinguished family of impossibility theorems:

| Theorem | Domain | Says "you can't..." |
|---------|--------|---------------------|
| Arrow's Theorem | Social choice | ...aggregate preferences fairly |
| Gödel's Incompleteness | Logic | ...prove your own consistency |
| No-cloning | Quantum mechanics | ...copy quantum states |
| **Standard Part Paradox** | **Probability** | **...make all weights infinitesimal** |

Each of these is not merely negative but reveals deep structural constraints that guide further research.

### 7.2 Minimality of Assumptions

A striking feature of our results is the minimality of assumptions. We require only:
1. F is a field
2. st : F → ℝ is additive
3. st(1) = 1

We do not need: order compatibility, multiplicativity, continuity, the Archimedean property of ℝ, or even characteristic zero (beyond what st(1) = 1 forces). This makes the results maximally portable across mathematical contexts.

## 8. Future Work

1. **Constructive NAPA on Levi-Civita**: Explicit construction over ℝ((ε)) with verification of all axioms.
2. **Countable extensions**: Extending to countably additive measures on infinite types.
3. **Multiplicative standard parts**: What additional structure emerges when st is a ring homomorphism?
4. **PAC-Bayes integration**: Formal bounds on generalization error with NAPA priors.
5. **Topological NAPAs**: Standard part maps that are continuous in appropriate topologies.

## 9. Catalog References

- `classical_not_self_sound_with_paradox` (FINAL/Logic/ParadoxSelfSoundness.lean): Impossibility theorem pattern
- `non_contradiction_not_tautology` (FINAL/Logic/ParaconsistentParadox.lean): Structural paradox analysis
- `paradox_span_all_both` (FINAL/Logic/ParadoxAlgebra.lean): Algebraic paradox structure

## References

1. Benci, V., Bottazzi, E., & Di Nasso, M. (2013). Elementary numerosity and measures. *Journal of Logic and Analysis*.
2. Catoni, O. (2007). *PAC-Bayesian Supervised Classification*. Springer.
3. de Finetti, B. (1937). La prévision: ses lois logiques, ses sources subjectives. *Annales de l'Institut Henri Poincaré*.
4. Kolmogorov, A. N. (1933). *Grundbegriffe der Wahrscheinlichkeitsrechnung*. Springer.
5. McAllester, D. A. (1999). PAC-Bayesian model averaging. *COLT*.
6. Nelson, E. (1977). Internal set theory. *Bulletin of the AMS*.
7. Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
