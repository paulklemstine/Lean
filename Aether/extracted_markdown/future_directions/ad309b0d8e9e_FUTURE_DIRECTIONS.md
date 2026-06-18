# Future Directions: Functorial Entropy

## Synthesis

This research cycle established a complete, machine-verified theory of **functorial entropy** for functions between finite types. The central achievement is the **post-composition monotonicity theorem** — H(g ∘ f) ≥ H(f) — proved via the superadditivity of x·log(x), which serves as the combinatorial analog of the data processing inequality. Alongside this, we proved the **entropy defect chain rule** δ(f, h∘g) = δ(g∘f, h) + δ(f, g), the **bijective vanishing theorem** δ(f,g) = 0 when g is bijective, and parallel monotonicity results for collision entropy (H₂ = Σ n_b²) and tropical entropy (H_trop = max n_b). All 16 theorems are fully machine-verified with no sorries.

The most promising cross-domain connections emerged in three areas. First, the **entropy defect chain rule** reveals that δ behaves as a 1-cocycle on the nerve of the category FinSet, suggesting deep connections to cohomological obstruction theory — this connects to the Catalog's existing work on sheaf cohomology depth (`MachineLearning/SheafCohomologyDepth.lean`) and Čech contextuality (`Physics/CechContextualityCore.lean`). Second, the **tropical entropy monotonicity** provides a max-plus analog of the data processing inequality, bridging to the Catalog's extensive tropical algebra infrastructure (`Tropical/` directory, `Physics/Landauer.lean`). Third, the **Landauer cost formalization** connects our pure-mathematical framework to the physics of computation, extending the Catalog's `reversible_zero_entropy_cost` results.

The highest breakthrough potential lies in Direction 1 (Equality Characterization), which would provide a complete classification of when composition preserves entropy — effectively characterizing all "information-preserving" compositions. Direction 3 (Entropy Rate Convergence) has the most novel mathematical content, potentially establishing functorial entropy rate as a topological conjugacy invariant for dynamical systems on finite types.

---

### Direction 1: Complete Equality Characterization for Post-Composition Monotonicity

**Conjecture**: For f : α → β and g : β → γ between finite nonempty types, H(g ∘ f) = H(f) if and only if g is injective on the image of f. That is, the defect δ(f,g) = 0 iff g restricted to f(α) ⊆ β is injective.

**Test**: Enumerate all functions f : Fin 3 → Fin 3 and g : Fin 3 → Fin 3, compute H(g ∘ f) and H(f), and verify that equality holds precisely when g is injective on Im(f). This is a finite computation with 3^3 × 3^3 = 729 pairs.

**Impact**: If true, this completely characterizes when post-composition preserves information — it says that the only way to avoid information loss is for g to behave injectively on the "live" part of β. This would refine the bijective vanishing theorem (which requires global bijectivity) to a local condition. If false, the failure would reveal exotic function pairs where information is preserved despite non-injectivity on the image, suggesting a more subtle algebraic condition.

**Catalog References**: `Physics/FunctorialEntropy.lean` (entropyDefect_eq_zero_of_bijective, fiberEntropy_comp_le)

**Proof Strategy**: For the forward direction, assume g is injective on Im(f). Then fiberCard(g ∘ f, c) = fiberCard(f, g⁻¹(c)) for c in Im(g∘f), and the reindexing preserves each term. For the reverse direction, assume g(b₁) = g(b₂) for b₁ ≠ b₂ in Im(f). Then the fibers of f at b₁ and b₂ merge under composition, and by the strict superadditivity of x·log(x) for positive arguments, the entropy strictly increases.

**Domain Bridges**: Information Theory (data processing inequality equality conditions) ↔ Algebraic Geometry (fiber preservation under morphisms) ↔ Category Theory (conservative functors)

**Lineage**: Builds on fiberEntropy_comp_le and entropyDefect_eq_zero_of_bijective from this cycle.

**Ambition**: extension

---

### Direction 2: Cohomological Interpretation of the Entropy Defect

**Conjecture**: The entropy defect δ defines a nontrivial 1-cocycle in the first cohomology group H¹(N(FinSet_n), ℝ≥₀) of the nerve of the full subcategory of FinSet on objects of cardinality ≤ n, with coefficients in (ℝ≥₀, +). Moreover, the cohomology class [δ] is nontrivial (i.e., δ is not a coboundary — there is no function μ on objects such that δ(f,g) = μ(target of g∘f) − μ(target of f)).

**Test**: For FinSet restricted to {Fin 1, Fin 2, Fin 3}, compute δ for all composable pairs and verify the cocycle condition. Then check whether δ can be written as differences of a function on objects (coboundary test). If δ(f, g) = μ(γ) − μ(β) for some μ, then δ would be trivial. Compute whether such μ exists by solving the linear system.

**Impact**: If nontrivial, this establishes entropy as a *topological* invariant of the category of finite sets — it cannot be localized to objects but is an intrinsic property of morphism composition. This would connect information theory to algebraic topology in a new way, potentially yielding new invariants of categories. If trivial (δ is a coboundary), this would mean information loss can be fully attributed to the codomain, which would be a surprising structural result.

**Catalog References**: `MachineLearning/SheafCohomologyDepth.lean` (complete_data_zero_defect), `Physics/CechContextualityCore.lean`

**Proof Strategy**: First formalize the nerve of FinSet_n as a simplicial set. Define the cochain complex with real coefficients. Show δ satisfies the cocycle condition (already proved as entropyDefect_chain). For nontriviality, construct explicit f : Fin 2 → Fin 1 and compute δ; show no function μ on {Fin 1, Fin 2} satisfies the coboundary condition.

**Domain Bridges**: Information Theory (entropy defect) ↔ Algebraic Topology (group cohomology) ↔ Category Theory (nerve of a category)

**Lineage**: Builds on entropyDefect_chain and entropyDefect_nonneg from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Entropy Rate Convergence for Iterated Composition

**Conjecture**: For any function f : α → α on a finite type with |α| = n ≥ 2, the entropy rate h(f) = lim_{k→∞} H(f^k)/k exists and equals H(f^p)/p where p is the period of the eventual periodic structure of f (specifically, the period of the permutation that f induces on its eventual image).

**Test**: For f : Fin 4 → Fin 4 defined by f(0)=1, f(1)=2, f(2)=1, f(3)=0, compute H(f^k) for k = 1, ..., 20 and verify that H(f^k)/k converges. Compare with the predicted value from the permutation on the eventual image {0,1,2}.

**Impact**: If true, this establishes the entropy rate as a dynamical invariant — it depends only on the eventual periodic behavior of f, not on the transient. This would connect functorial entropy to ergodic theory and topological dynamics, potentially yielding a new proof that topological entropy for finite dynamical systems is always rational. If false, the failure pattern would reveal whether entropy can grow superlinearly under iteration, which would be remarkable.

**Catalog References**: `Physics/FunctorialEntropy.lean` (fiberEntropy_comp_le), `Computation/PadicValuationDepth.lean` (ValuationDepthMeasure)

**Proof Strategy**: Key steps: (1) Show that f eventually maps into a subset S ⊆ α that is closed under f, and f|_S is a permutation. (2) For k larger than the transient length, H(f^k) depends only on k mod p where p is the period of f|_S. (3) The limit exists because the sequence H(f^k) is eventually periodic (not just subadditive). Need: orbit structure theory for functions on finite sets, which should be formalizable from scratch.

**Domain Bridges**: Dynamical Systems (entropy rate, topological entropy) ↔ Combinatorics (orbit structure of finite functions) ↔ Number Theory (periodicity, p-adic valuation)

**Lineage**: Builds on fiberEntropy_comp_le from this cycle; connects to ValuationDepthMeasure for depth/complexity analysis.

**Ambition**: grand_challenge

---

### Direction 4: Tropical-Shannon Duality via Maslov Dequantization

**Conjecture**: There exists a one-parameter family of entropies H_t(f) indexed by t > 0, with H_t(f) = (1/t) · log(Σ_b exp(t · n_b · log(n_b))), such that:
- lim_{t→0⁺} H_t(f) = H(f) (recovers fiber entropy)
- lim_{t→∞} H_t(f) = H_trop(f) = max_b n_b · log(n_b) (recovers tropical entropy)

Moreover, H_t satisfies the post-composition monotonicity H_t(g ∘ f) ≥ H_t(f) for all t > 0.

**Test**: For f : Fin 4 → Fin 2 with fibers of size 1 and 3, compute H_t(f) numerically for t = 0.01, 0.1, 1, 10, 100 and verify convergence to H(f) and H_trop(f) at the limits. Verify monotonicity for a specific composition.

**Impact**: If true, this establishes a continuous interpolation between Shannon and tropical information theory, mediated by Maslov dequantization. This would provide a mathematical framework for understanding when tropical methods approximate classical information theory, with applications to optimization and machine learning. The monotonicity at all scales would be a new inequality.

**Catalog References**: `Tropical/` (tropical algebra infrastructure), `Physics/Landauer.lean` (tropical_landauer_finite), `Physics/FunctorialEntropy.lean` (fiberEntropy_comp_le, tropicalEntropy_comp_le)

**Proof Strategy**: Define H_t using the log-sum-exp formula. The t→0 limit is the weighted average (by the softmax argument). The t→∞ limit extracts the maximum. Monotonicity should follow from the monotonicity of log-sum-exp under the grouping operation induced by composition.

**Domain Bridges**: Tropical Geometry (Maslov dequantization) ↔ Information Theory (Rényi entropy) ↔ Statistical Physics (free energy at temperature 1/t)

**Lineage**: Builds on both fiberEntropy_comp_le and tropicalEntropy_comp_le from this cycle; extends tropical algebra work in Catalog.

**Ambition**: extension

---

### Direction 5: Surjective Pre-Composition and the Entropy Product Formula

**Conjecture**: For f : α → β and surjective h : γ → α between finite nonempty types:

    H(f ∘ h) = H(f) + H(h) + Σ_b fiberCard(f, b) · log(fiberCard(f, b)) · [H(h|_{h⁻¹(f⁻¹(b))}) - H(h)]

where H(h|_S) denotes the fiber entropy of h restricted to the preimage of S. In the special case where h has uniform fiber sizes (|h⁻¹(a)| = m for all a), this simplifies to H(f ∘ h) = H(f) + |β| · m · log(m).

**Test**: Take f : Fin 4 → Fin 2 with fibers {0,1} and {2,3}, and h : Fin 8 → Fin 4 with uniform fibers of size 2. Compute H(f ∘ h), H(f), H(h) and verify the uniform formula. Then try non-uniform h and check the general formula.

**Impact**: If true, this provides the missing "pre-composition" complement to the post-composition monotonicity theorem. Together, they would give a complete algebra of fiber entropy under arbitrary compositions. The product formula would decompose the total information loss of f ∘ h into the loss from f, the loss from h, and a correction term measuring how h's fiber structure interacts with f's partition.

**Catalog References**: `Physics/FunctorialEntropy.lean` (fiberEntropy_comp_le, fiberCard_comp)

**Proof Strategy**: Decompose the fibers of f ∘ h using the composition formula. Each fiber of f ∘ h over b is the preimage under h of the fiber of f over b. If h is surjective, this preimage is nonempty. Express the resulting entropy using the law of total entropy and the partition of γ induced by f ∘ h.

**Domain Bridges**: Information Theory (chain rule for entropy) ↔ Measure Theory (disintegration of measures) ↔ Category Theory (fiber products and pullbacks)

**Lineage**: Builds on fiberCard_comp and fiberEntropy_comp_le from this cycle.

**Ambition**: extension
