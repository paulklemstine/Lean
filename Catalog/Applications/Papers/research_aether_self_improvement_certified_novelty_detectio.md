# Certified Novelty Detection via Theorem Embedding Uniqueness

## Abstract

We introduce a formally verified framework for certifying the novelty of mathematical theorems relative to a finite catalog of known results. The framework embeds theorem descriptors into a pseudo-metric space and proves that distance from the catalog beyond an equivalence radius constitutes a sound novelty certificate. We formalize the core certification theorem, a nearest-neighbor novelty score, finite minimizer existence, multi-feature obstruction principles, and a concrete descriptor structure with coordinate-gap non-equivalence theorems. All results are machine-verified with no unproven assumptions beyond standard foundations. This establishes the first rigorous architecture for automated non-derivativeness certification in formal mathematics.

## 1. Introduction

### 1.1 Motivation

As formal mathematics libraries grow to hundreds of thousands of theorems, a fundamental question arises: given a candidate theorem, is it genuinely new, or merely a reformulation of an existing result? This question is currently answered by human judgment—reviewers, editors, and colleagues assess novelty informally. No mathematical criterion exists for certifying that a result is not equivalent to anything in a given corpus.

We address this gap by constructing a metric-geometric certification architecture. The key insight is that if we embed theorem descriptors into a metric space such that equivalent theorems map to nearby points, then sufficient distance from the catalog provides a provable novelty guarantee.

### 1.2 Related Work

**Formal libraries and deduplication.** Large proof libraries (Mathlib, AFP, Mizar) contain informal deduplication via naming conventions and namespace organization, but no formal novelty criterion.

**Plagiarism detection.** Text similarity metrics (TF-IDF, BLEU, embedding cosine similarity) detect near-copies in natural language but lack mathematical soundness guarantees.

**Metric semantics for proofs.** Prior work on proof complexity and proof mining extracts quantitative information from proofs but does not address the novelty question.

**Error-correcting codes.** Our framework has a precise analogy to minimum-distance decoding in coding theory, where codewords are catalog theorems and the decoding radius corresponds to the equivalence tolerance.

### 1.3 Contributions

1. **Novelty Certification Theorem** (Theorem 3.1): Sound certification of non-equivalence via metric separation.
2. **Nearest-Neighbor Score** (Theorem 3.3): A computable novelty score with formal soundness guarantee.
3. **Multi-Feature Obstruction** (Theorem 3.5): Joint certification via multiple independent features.
4. **Concrete Descriptor Model** (Section 4): An explicit six-dimensional descriptor with coordinate-gap theorems.
5. **Monotonicity and Structural Properties** (Section 5): The novelty score decreases under catalog expansion.
6. **Complete formal verification**: All results machine-checked with only standard axioms (propext, Classical.choice, Quot.sound).

## 2. Definitions and Notation

### 2.1 Setup

Let σ be a type of **theorem descriptors**—abstract certificates representing mathematical statements at a chosen granularity. Let (α, d) be a pseudo-metric space and E : σ → α an **embedding** mapping descriptors to metric feature space.

Let **Equivalent** : σ → σ → Prop be a predicate capturing when two descriptors represent "the same" theorem up to the chosen certification granularity (e.g., modulo variable renaming, definitional unfolding, or logical equivalence).

Let K ⊆ σ be a finite **catalog** of known theorem descriptors, represented as a Finset σ.

### 2.2 Core Definitions

**Definition 2.1 (Novelty).** A descriptor x is *novel* with respect to catalog K and equivalence relation Equivalent if:

$$\text{Novel}(K, x) \iff \forall a \in K,\ \neg\text{Equivalent}(x, a)$$

**Definition 2.2 (Nearest Distance).** For nonempty K, the nearest distance is:

$$\text{nearestDist}(x, K) := \inf_{a \in K} d(E(x), E(a))$$

Formally, this is `K.inf' hK (fun a => dist (E x) (E a))` using Finset.inf'.

### 2.3 Assumptions

The framework requires one assumption relating the embedding to the equivalence:

**Embedding Soundness (ES).** ∀ x y, Equivalent(x, y) → d(E(x), E(y)) ≤ δ.

This states that equivalent descriptors embed within distance δ. The parameter δ > 0 is the **equivalence radius**—it quantifies the maximum metric distortion that equivalence can produce.

Note: We do *not* assume the converse (completeness). Close embeddings need not correspond to equivalent theorems. This one-sided assumption yields a sound but possibly incomplete certification system.

## 3. Main Results

### 3.1 Sound Novelty Certification

**Theorem 3.1** (novelty_of_far_from_catalog). *Assume (ES). For any candidate x, if*

$$\forall a \in K,\ \delta < d(E(x), E(a)),$$

*then Novel(K, x).*

*Proof sketch.* Suppose toward contradiction that Equivalent(x, a) for some a ∈ K. By (ES), d(E(x), E(a)) ≤ δ. But d(E(x), E(a)) > δ by hypothesis. Contradiction. □

This is the foundational soundness theorem. Its proof is a single contrapositive step, but its significance lies in establishing the mathematical interface between metric geometry and logical novelty.

### 3.2 Existence of Nearest Catalog Element

**Theorem 3.2** (exists_nearest_in_finset). *For nonempty K, there exists a ∈ K achieving the minimum distance:*

$$\exists a \in K,\ \forall b \in K,\ d(E(x), E(a)) \leq d(E(x), E(b)).$$

*Proof.* Direct application of Finset.exists_min_image, which provides a minimizer for any real-valued function on a nonempty finite set. □

### 3.3 Nearest-Neighbor Novelty Score

**Theorem 3.3** (novelty_of_nearestDist_gt). *Assume (ES). If K is nonempty and*

$$\delta < \text{nearestDist}(x, K),$$

*then Novel(K, x).*

*Proof sketch.* Since nearestDist is K.inf', we have nearestDist(x,K) ≤ d(E(x), E(a)) for all a ∈ K. Combined with δ < nearestDist, this gives δ < d(E(x), E(a)) for all a ∈ K. Apply Theorem 3.1. □

### 3.4 Coordinate-Gap Obstruction

**Theorem 3.4** (not_equivalent_of_coordinate_gap). *Let f : σ → ℝ be any feature extractor. Suppose Equivalent(x,y) implies |f(x) - f(y)| ≤ δ. Then if |f(x) - f(y)| > δ, we have ¬Equivalent(x, y).*

*Proof.* Direct contrapositive. □

### 3.5 Multi-Feature Obstruction

**Theorem 3.5** (not_equivalent_of_any_feature_gap). *Given n feature extractors f_i : σ → ℝ with tolerances δ_i, if Equivalent(x,y) implies |f_i(x) - f_i(y)| ≤ δ_i for all i, then a gap in any single feature suffices:*

$$\exists i,\ \delta_i < |f_i(x) - f_i(y)| \implies \neg\text{Equivalent}(x, y).$$

*Proof.* Obtain the witnessing index i. The single-feature obstruction (Theorem 3.4) applied to f_i yields the result. □

### 3.6 Partial Completeness

**Theorem 3.6** (catalog_separation_implies_novelty_or_unique_match). *If the novelty certification fails (i.e., it is not the case that every catalog element is farther than δ), then there exists a catalog element within distance δ:*

$$\neg(\forall a \in K,\ \delta < d(E(x), E(a))) \implies \exists a \in K,\ d(E(x), E(a)) \leq \delta.$$

*Proof.* Push the negation through the universal quantifier. □

This is the "partial completeness" direction: failure to certify novelty implies proximity to the catalog. Combined with Theorem 3.1, this gives a two-sided characterization of the certification boundary.

## 4. Concrete Descriptor Model

### 4.1 The TheoremDescriptor Structure

We define a concrete descriptor type with six features:

```
TheoremDescriptor :=
  { arity : ℕ,           -- number of free variables
    symbolCount : ℕ,      -- total symbol count
    quantifierDepth : ℕ,  -- max quantifier nesting
    dependencyCount : ℕ,  -- number of imported lemmas
    hasInduction : Bool,  -- uses induction?
    hasContradiction : Bool }  -- uses contradiction?
```

### 4.2 Coordinate-Gap Theorems

For each numeric coordinate, we prove a specialized gap theorem:

**Theorem 4.1** (nonequiv_of_symbolCount_gap). If Equivalent preserves symbol count within tolerance δs, then |(x.symbolCount : ℝ) - y.symbolCount| > δs implies ¬Equivalent(x, y).

**Theorem 4.2** (nonequiv_of_arity_gap). Analogous for arity.

**Theorem 4.3** (nonequiv_of_quantifierDepth_gap). Analogous for quantifier depth.

These are instances of the general coordinate-gap obstruction (Theorem 3.4), specialized to the concrete descriptor.

## 5. Structural Properties

### 5.1 Non-negativity

**Theorem 5.1** (nearestDist_nonneg). *The novelty score is non-negative:*

$$0 \leq \text{nearestDist}(x, K).$$

*Proof.* The infimum of non-negative values (distances) is non-negative. □

### 5.2 Monotonicity Under Catalog Expansion

**Theorem 5.2** (nearestDist_insert_le). *Adding an element to the catalog can only decrease or maintain the novelty score:*

$$\text{nearestDist}(x, K \cup \{b\}) \leq \text{nearestDist}(x, K).$$

*Proof.* The infimum over a larger set is at most the infimum over a subset. □

This has an important practical consequence: as the catalog grows, novelty certificates become *harder* to obtain. A theorem that is certified novel today remains meaningful even as the catalog expands.

### 5.3 Equal Distances for Joint Minimizers

**Theorem 5.3** (unique_nearest_of_strict_dist). *If both a and b achieve the minimum distance to x among all catalog elements, then d(E(x), E(a)) = d(E(x), E(b)).*

*Proof.* By mutual inequality from the minimality conditions. □

## 6. Algorithms

### 6.1 Novelty Certification Algorithm

```
Algorithm: CertifyNovelty(x, K, δ, E)
Input: candidate descriptor x, catalog K, tolerance δ, embedding E
Output: NOVEL or UNCERTAIN

1. For each a ∈ K:
   a. Compute d(E(x), E(a))
   b. If d(E(x), E(a)) ≤ δ: return UNCERTAIN
2. Return NOVEL
```

**Complexity:** O(|K| · d) where d is the dimension of the embedding space.

**Soundness:** By Theorem 3.1, if the algorithm returns NOVEL, then ¬Equivalent(x, a) for all a ∈ K.

### 6.2 Nearest-Neighbor Novelty Score

```
Algorithm: NoveltyScore(x, K, E)
Input: candidate descriptor x, catalog K, embedding E
Output: nearest distance score

1. min_dist ← ∞
2. For each a ∈ K:
   a. d ← dist(E(x), E(a))
   b. If d < min_dist: min_dist ← d
3. Return min_dist
```

**Complexity:** O(|K| · d).

### 6.3 Multi-Feature Certification

```
Algorithm: MultiFeatureCertify(x, y, features, tolerances)
Input: descriptors x, y; feature extractors; tolerances
Output: NOT_EQUIVALENT or UNCERTAIN

1. For each (f_i, δ_i) in zip(features, tolerances):
   a. If |f_i(x) - f_i(y)| > δ_i: return NOT_EQUIVALENT
2. Return UNCERTAIN
```

**Soundness:** By Theorem 3.5.

## 7. Applications

### 7.1 Library Deduplication

Given a formal mathematics library with N theorems, compute pairwise novelty scores. Theorems with nearestDist ≤ δ are candidate duplicates. Theorems with nearestDist > δ are certified unique in the catalog.

### 7.2 Research Novelty Assessment

A researcher submitting a new theorem can compute its novelty score against a standard catalog. A high score provides objective evidence of non-derivativeness. A low score flags potential overlap for further investigation.

### 7.3 AI-Generated Mathematics Audit

As AI systems produce mathematical conjectures and proofs, novelty certification provides a machine-checkable audit: is this AI-generated result genuinely new, or a reformulation of training data?

## 8. Computational Experiments

We implement the framework in Python and demonstrate it on a catalog of elementary theorems. See the accompanying `demo.py` for full details.

**Experiment 1: Catalog of 5 elementary theorems.** We embed descriptors for the Pythagorean theorem, Euclid's infinitude of primes, the fundamental theorem of calculus, Fermat's little theorem, and the quadratic formula. With δ = 2.0, the system correctly certifies novel candidates (e.g., a complex analysis result) and identifies structurally similar candidates (e.g., a number theory result close to Fermat's little theorem).

**Experiment 2: Feature-gap analysis.** We demonstrate that even a single coordinate gap (e.g., symbol count difference of 30 vs. tolerance of 5) suffices for certification.

**Experiment 3: Catalog growth dynamics.** As the catalog grows from 5 to 50 theorems, we track how novelty scores decrease, illustrating Theorem 5.2.

## 9. Discussion

### 9.1 Limitations

The framework certifies *structural* non-equivalence, not *semantic* novelty. Two semantically identical theorems with different syntactic structure may both receive novelty certificates. This is a fundamental limitation of any feature-based approach and motivates the development of semantic embeddings.

The choice of δ is critical: too small and the system issues false novelty certificates (unsound); too large and it never certifies anything (useless). In practice, δ must be calibrated by testing on known equivalences.

### 9.2 Coding-Theoretic Interpretation

The catalog K is formally a codebook in the sense of information theory. Each codeword (known theorem) occupies a ball of radius δ in feature space. The novelty score is the minimum distance from a candidate to any codeword. Novelty certification is equivalent to determining that a received signal does not match any codeword—it lies outside the decoding region.

This analogy suggests that results from coding theory (sphere-packing bounds, Gilbert-Varshamov bounds, Shannon capacity) may have direct implications for the capacity of theorem catalogs.

### 9.3 Connections to Reconstruction Uniqueness

The framework connects to reconstruction principles: if theorem features uniquely determine theorem identity (up to equivalence), then distinct identities must map to separated feature regions. This is the formal backbone that makes embedding-based certification meaningful.

## 10. Future Work

1. **Semantic embeddings** via dependency graphs and logical structure.
2. **Learned embeddings** from neural networks with formal soundness wrappers.
3. **Dynamic catalog certification** with amortized novelty score updates.
4. **Packing bounds** on the number of certifiable novelty regions under complexity budgets.
5. **Cryptographic commitments** to theorem identity for priority claims.

## References

1. Shannon, C.E. "A Mathematical Theory of Communication." Bell System Technical Journal, 1948.
2. Hamming, R.W. "Error Detecting and Error Correcting Codes." Bell System Technical Journal, 1950.
3. The Mathlib Community. "The Lean Mathematical Library." CPP 2020.
