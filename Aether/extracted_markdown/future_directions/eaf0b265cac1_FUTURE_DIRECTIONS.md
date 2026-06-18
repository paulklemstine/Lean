# Future Directions: Compression Complexity Under Products

## Synthesis

The theorems established here — sub-additivity, lower bounds, conditional additivity, and multiplicativity of distinguishability — form the foundation of a **compression geometry** on finite presheaf models. The product structure theorem `max(κ₁, κ₂) ≤ κ(M₁ × M₂) ≤ κ₁ + κ₂` places compression complexity in the same functional class as entropy, dimension, and channel capacity. The computational evidence shows that universal additivity *fails*: the compression defect δ(M₁, M₂) = κ₁ + κ₂ − κ(M₁ × M₂) can be strictly positive. This opens a rich structure theory.

The five directions below form a coherent research program: Direction 1 classifies the defect, Direction 2 connects it to graph theory, Direction 3 probes asymptotic behavior, Direction 4 links to algebraic K-theory, and Direction 5 addresses the computational frontier.

---

## Direction 1: Defect Classification Conjecture

**Conjecture.** For finite presheaf models with identity self-restrictions (res(Y,Y) = id), the compression defect satisfies δ(M₁, M₂) = κ(M₁) + κ(M₂) − max(κ(M₁), κ(M₂)) = min(κ(M₁), κ(M₂)), i.e., κ(M₁ × M₂) = max(κ(M₁), κ(M₂)).

**Test.** Enumerate all models with ≤ 4 objects, fibers ≤ 4, identity self-restriction, and compute defects. Check whether δ = min(κ₁, κ₂) universally holds for this subclass.

**Impact.** If true, this would show that identity-on-diagonal models have "dimensional" behavior where products behave like taking the max — like covering dimension under Cartesian products. If false, the counterexample would reveal exactly what makes compression non-dimensional.

**Catalog References.** `Pythagorean/ProbeComplexity/CompressionProduct.lean` (compressionDefect, compression_prod_le, max_le_compression_prod).

**Proof Strategy.** For the upper bound, use the existing sub-additivity proof. For the lower bound, show that when res(Y,Y) = id, any probe that separates at Y in M₁ also works in the product (via identity self-restriction), so probes can be "shared" across factors. Formalize the sharing lemma as a new helper.

**Domain Bridges.** Covering dimension theory (dim(X × Y) ≤ dim(X) + dim(Y), with equality for well-behaved spaces); Krull dimension of tensor products of rings.

**Lineage.** Directly extends `compression_prod_le` and `max_le_compression_prod`.

**Ambition.** ★★★ (Paradigm-classifying: would determine whether κ is dimension-like or entropy-like.)

---

## Direction 2: Confusability Graph Correspondence

**Conjecture.** There exists a natural graph invariant γ such that κ(M) = γ(G_M) for all finite presheaf models M, where G_M is the "confusability graph" whose vertices are global sections and edges connect observationally indistinguishable pairs. Specifically, γ is the minimum clique cover number of the "total separation graph."

**Test.** For each model M with ≤ 3 objects, construct the separation graph at each object Y (vertices = F(Y), edges = pairs separated by at least one probe). Compute clique cover numbers, chromatic numbers, and independence numbers. Compare each candidate γ with κ(M).

**Impact.** Would establish a formal dictionary between presheaf compression and zero-error information theory / graph capacity theory. Product of models would correspond to strong product of graphs, connecting κ-additivity to the deep open problem of Shannon capacity additivity.

**Catalog References.** `Pythagorean/ProbeComplexity/CompressionProduct.lean` (distinguishabilityCardAt, probeIndistinguishable_prod_iff, distinguishabilityCardAt_prod).

**Proof Strategy.** Define the confusability graph formally in Lean. Show that probe families correspond to graph colorings of the complement. The minimum family size equals the chromatic number of the complement = clique cover number of the original.

**Domain Bridges.** Shannon capacity of graphs (Lovász theta function); zero-error information theory; Ramsey theory.

**Lineage.** Builds on `distinguishabilityCardAt_prod` (multiplicativity = strong graph product capacity).

**Ambition.** ★★★★ (Grand challenge: connects to major open problems in graph theory.)

---

## Direction 3: Asymptotic Additivity

**Conjecture.** For any finite presheaf model M with κ(M) > 0,

lim_{n→∞} κ(M^{×n}) / n = κ(M).

That is, even if single-shot additivity fails, the asymptotic rate converges to κ(M).

**Test.** For small models (2 objects, 2-3 fibers), compute κ(M), κ(M×M), κ(M×M×M) and check whether κ(M^{×n})/n → κ(M). Plot the convergence rate.

**Impact.** Would establish κ as an "operational capacity" in the information-theoretic sense. Even if one-shot compression is subadditive, the rate might be additive — mirroring the distinction between one-shot and asymptotic channel capacity.

**Catalog References.** `Pythagorean/ProbeComplexity/CompressionProduct.lean` (compression_prod_le gives κ(M^{×n}) ≤ n·κ(M)).

**Proof Strategy.** The upper bound κ(M^{×n}) ≤ n·κ(M) follows by iterating sub-additivity. For the lower bound, use distinguishability multiplicativity: the number of distinguishable states grows as d^n, requiring Ω(n·log d / log |Ob|) probes. Fekete's lemma on subadditive sequences gives convergence of κ(M^{×n})/n.

**Domain Bridges.** Shannon capacity; subadditive ergodic theory; Fekete's lemma for subadditive sequences.

**Lineage.** Direct iteration of `compression_prod_le`.

**Ambition.** ★★★ (Solid extension with potential for deep connections.)

---

## Direction 4: K-Theoretic Compression Invariant

**Conjecture.** The compression complexity κ defines a ring homomorphism from the Grothendieck group K₀(FinPresheaf) of finite presheaf models (under ×) to (ℤ, +), making it a K-theoretic invariant of observational systems.

**Test.** Verify that κ respects all identities required of a group homomorphism on the K₀ completion: κ(M₁ × M₂) = κ(M₁) + κ(M₂) up to the defect, and check whether the defect itself factors through a secondary invariant (akin to K₁).

**Impact.** Would place compression complexity in the framework of algebraic K-theory, connecting it to virtual Euler characteristics, Wall's finiteness obstruction, and motivic measures. This is the deepest algebraic direction.

**Catalog References.** `Pythagorean/ProbeComplexity/CompressionProduct.lean` (all product theorems); `Pythagorean/ProbeComplexity/ToposCompressionDefs.lean` (CompressionEquiv).

**Proof Strategy.** Show that compression-compatible equivalences (CompressionEquiv) form a symmetric monoidal equivalence relation on FinPresheaf. Define K₀ as the group completion. Prove κ descends to a well-defined group homomorphism using Morita invariance + product structure.

**Domain Bridges.** Algebraic K-theory; motivic integration; Euler characteristics of categories.

**Lineage.** Extends `compressionNumber_eq_of_equiv'` (Morita invariance) from the ToposCompressionInvariant file.

**Ambition.** ★★★★★ (Grand challenge: would found a new K-theoretic framework.)

---

## Direction 5: Computational Complexity of κ

**Conjecture.** Computing κ(M) is NP-hard in general (as a function of the total input size |Ob| + Σ|F(Y)| + number of restriction entries). Specifically, it reduces from Set Cover.

**Test.** Show a polynomial-time reduction from minimum set cover to compression complexity computation. Construct, for each set cover instance, a presheaf model whose κ equals the minimum cover size.

**Impact.** Would establish the computational landscape of compression complexity, motivating approximation algorithms and fixed-parameter tractability results. Combined with the product theorems, this gives complexity of computing κ for product models.

**Catalog References.** `Pythagorean/ProbeComplexity/Defs.lean` (ProbeFamily.IsSeparating); `Pythagorean/ProbeComplexity/CompressionProduct.lean` (product construction).

**Proof Strategy.** Given a universe U and collection S₁,...,Sₘ ⊆ U, construct a model with objects = {s₁,...,sₘ}, fibers F(sᵢ) = U, restriction res(sᵢ, sⱼ)(u) = u if u ∈ Sⱼ, else * (collapse). A probe family P separates iff ⋃_{sᵢ ∈ P} Sᵢ = U.

**Domain Bridges.** Computational complexity theory; approximation algorithms; fixed-parameter tractability.

**Lineage.** Independent but informed by the algorithmic implementations in `algorithms.py`.

**Ambition.** ★★ (Solid extension; standard reduction technique.)
