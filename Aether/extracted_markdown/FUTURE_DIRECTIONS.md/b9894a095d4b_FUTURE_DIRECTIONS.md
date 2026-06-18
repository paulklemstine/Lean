# Future Directions: Tropical Discrete Convexity Under Truncation

## Synthesis

The results established in this cycle — that support contraction commutes with tropicalization and preserves M-convex exchange — open a systematic program for understanding tropical geometry through the lens of discrete convex analysis. The central theme is that **polyhedral operations on Newton polytopes preserve combinatorial exchange axioms**, and that this preservation can be tracked formally through tropicalization. The five directions below extend this theme along three axes: deepening the algebraic connection (Directions 1 and 2), broadening the geometric scope (Direction 3), and bridging to other mathematical domains (Directions 4 and 5).

---

## Direction 1: Valuated M-Convex Exchange Preservation Under Tropical Truncation

**Conjecture**: For every finite integer-valued tropical support `T` satisfying the valuated M-convex exchange inequality (the exchange axiom with weight constraints `w(α - eₖ + eⱼ) + w(β - eⱼ + eₖ) ≥ w(α) + w(β)`), the tropical truncation `tropicalTruncate(i, T)` also satisfies the valuated exchange inequality.

**The key insight is...** that the lifting argument used for unweighted exchange should extend to the weighted case, because the weight of a contracted vector is defined as the weight of its lift. The exchange witness in the original set produces a witness in the contracted set whose weight is inherited from the original, and the weight inequality should transfer through the lifting bijection.

**Why now?** The unweighted version (Theorem 2) is proved. The valuated version is the natural next step and would establish tropical truncation as an operation on valuated matroids, connecting to Dress–Wenzel theory. Computational experiments (500+ trials, no counterexamples) strongly support the conjecture.

**Test**: Prove the following in Lean:
```lean
theorem TropicalMConvex.tropicalTruncate [Fintype σ]
    {T : TropicalSupport σ} {i : σ}
    (hT : TropicalMConvex T) :
    TropicalMConvex (tropicalTruncate i T)
```

**Impact**: Would establish tropical truncation as a morphism in the category of valuated matroids. This is the gateway to tropical Plücker relations and tropical linear spaces.

**Catalog References**: `Catalog/Tropical/TropicalContraction.lean` (TropicalMConvex definition), `Catalog/Pythagorean/MConvexBridge.lean` (exchange property infrastructure).

**Proof Strategy**: Extend the lifting argument from `MConvexExchangeFinsupp.supportContract`. The weight transfer requires showing that the weight of the contracted exchange witness equals the weight of the lifted witness, which follows from the definition of `tropicalTruncate.weight`.

**Domain Bridges**: Valuated matroids → tropical Grassmannians → algebraic geometry.

**Lineage**: Direct extension of Theorem 2 in this cycle.

**Ambition**: 7/10 — Technically demanding but conceptually clear.

---

## Direction 2: Multi-Step Contraction and Higher Derivatives

**Conjecture**: Iterated support contraction `supportContract(i, supportContract(i, S))` equals the support of the second partial derivative `∂²f/∂xᵢ²` (up to scalar factors). More generally, `k`-fold contraction in direction `i` corresponds to the `k`-th partial derivative and to slicing the Newton polytope with `{xᵢ ≥ k}` and translating by `-k·eᵢ`.

**The key insight is...** that contraction is an involutive-like operation: each step removes one layer of the Newton polytope in a given direction. The tower of truncations `S ⊃ supportContract(i,S) ⊃ supportContract(i,supportContract(i,S)) ⊃ ...` is a filtration of the Newton polytope by "depth" in direction `i`, and M-convexity is preserved at every level.

**Why now?** Theorem 2 proves the single-step case. The multi-step version would connect to the full Taylor expansion of tropical polynomials and to the theory of depth filtrations on polytopes.

**Test**: Prove:
```lean
theorem supportContract_iterate_eq_filter (i : σ) (S : Finset (σ →₀ ℕ)) (k : ℕ) :
    (supportContract i)^[k] S = 
      (S.filter (fun m => k ≤ m i)).image (fun m => m.update i (m i - k))
```

**Impact**: Would give a complete formal theory of tropical Taylor expansion and connect Newton polytope geometry to differential operators.

**Catalog References**: `Catalog/Tropical/TropicalContraction.lean`.

**Proof Strategy**: Induction on `k`, using the single-step characterization `supportContract_mem_iff` at each level.

**Domain Bridges**: Differential algebra → tropical differential equations → D-module theory.

**Lineage**: Natural extension of Theorems 1 and 2.

**Ambition**: 5/10 — Should be provable with existing infrastructure.

---

## Direction 3: Tropical Minkowski Sums Preserve Exchange

**Conjecture**: If `S₁, S₂ ⊆ (σ →₀ ℕ)` both satisfy M-convex exchange, then their Minkowski sum `S₁ + S₂ = {a + b : a ∈ S₁, b ∈ S₂}` also satisfies M-convex exchange.

**The key insight is...** that Minkowski sums of M-convex sets correspond to convolutions of valuated matroids, and convolution should preserve exchange. Combined with contraction stability (Theorem 2), this would establish a full **tropical algebra of exchange-preserving operations**: contraction, Minkowski sum, and (conjecturally) mixed subdivision.

**Why now?** This is a classical result in discrete convex analysis (Murota, 2003, Theorem 6.15), but it has never been formally verified. With our Lean infrastructure for M-convex exchange on finitely supported functions, the formalization is now tractable.

**Test**: Prove:
```lean
theorem MConvexExchangeFinsupp.minkowskiSum [Fintype σ]
    {S₁ S₂ : Finset (σ →₀ ℕ)}
    (h₁ : MConvexExchangeFinsupp S₁) (h₂ : MConvexExchangeFinsupp S₂) :
    MConvexExchangeFinsupp (S₁.product S₂ |>.image (fun p => p.1 + p.2))
```

**Impact**: Would complete the tropical algebra of exchange-preserving operations and connect to the theory of generalized permutohedra (Postnikov).

**Catalog References**: `Catalog/Tropical/TropicalContraction.lean`, `Catalog/Pythagorean/MConvexBridge.lean`.

**Proof Strategy**: Use the simultaneous exchange characterization: given an imbalance in a + b, find the right component to exchange in. This requires carefully tracking which summand contributes the imbalance.

**Domain Bridges**: Combinatorial optimization → polyhedral geometry → algebraic combinatorics.

**Lineage**: Complementary to Theorem 2 (contraction); together they give a closed algebra.

**Ambition**: 8/10 — Known to be true but technically involved.

---

## Direction 4: Non-Archimedean Degeneration and Berkovich Skeleta

**Conjecture**: Tropical truncation, viewed as an operation on Newton complexes, corresponds to restriction along a torus orbit in the non-Archimedean analytification of a toric variety. Specifically, for a polynomial `f` over a non-Archimedean field `K`, the tropicalization of `∂f/∂xᵢ` equals the tropical truncation of `trop(f)` in direction `i`.

**The key insight is...** that tropicalization is a faithful functor from non-Archimedean geometry to polyhedral geometry, and differentiation on the algebraic side should map to truncation on the tropical side. Our Theorem 1 is the finite, combinatorial shadow of this principle. A full proof would require formalizing the Berkovich analytification and the tropicalization map.

**Why now?** Mathlib's valuation theory is maturing, and there is active work on non-Archimedean analysis. Our support-level result provides the combinatorial foundation; the analytic extension is the natural next step.

**Test**: Define a tropicalization functor from `MvPolynomial σ K` (where `K` is a non-Archimedean valued field) to `TropicalSupport σ`, and prove:
```lean
theorem trop_deriv_eq_truncate_trop
    (f : MvPolynomial σ K) (i : σ) :
    tropicalize (MvPolynomial.pderiv i f) = tropicalTruncate i (tropicalize f)
```

**Impact**: Would be the first formal theorem connecting tropical geometry to non-Archimedean analysis in a proof assistant.

**Catalog References**: `Catalog/Tropical/TropicalContraction.lean`, Mathlib's `Valuation` and `MvPolynomial.pderiv`.

**Proof Strategy**: Reduce to the support-level statement (Theorem 1) by showing that tropicalization commutes with the support map, and that `pderiv` acts on supports by contraction.

**Domain Bridges**: Tropical geometry → p-adic analysis → arithmetic geometry → Berkovich spaces.

**Lineage**: Grand challenge extending Theorem 1 to the analytic setting.

**Ambition**: 9/10 — Requires significant new infrastructure but would be groundbreaking.

---

## Direction 5: Tropical Stability in Statistical Mechanics

**Conjecture**: For a finite-state statistical mechanical system with energy function `E : ℕ^d → ℤ`, if the zero-temperature ground state manifold (the set of minimizers of `E(m) + m·x` for varying external field `x`) has M-convex structure, then removing an interaction mode (contracting in one direction) preserves this structure.

**The key insight is...** that the zero-temperature limit of a partition function is a tropical polynomial, and M-convexity of the ground state manifold ensures that phase transitions are "well-behaved" (no chaotic jumps in the ground state under perturbation). Our stability theorem (Theorem 2) says this good behavior survives mode deletion.

**Why now?** There is growing interest in tropical methods for statistical mechanics and machine learning (the connection between softmax/log-sum-exp and tropical polynomials). Formalizing the stability of ground-state structure would bridge formal mathematics to physics.

**Test**: Define a ground-state manifold and prove:
```lean
theorem ground_state_mconvex_stable
    (E : (σ →₀ ℕ) → ℤ) (i : σ)
    (hE : MConvexGroundState E) :
    MConvexGroundState (fun m => E (m.update i (m i + 1)))
```

**Impact**: Would connect tropical discrete convexity to statistical mechanics and open a formal theory of "tropical thermodynamics."

**Catalog References**: `Catalog/Tropical/TropicalContraction.lean`, `Catalog/Tropical/StatisticalMechanics/Basic.lean`.

**Proof Strategy**: Reduce to Theorem 2 by showing that M-convexity of the ground-state manifold is equivalent to M-convexity of the support at each linear functional, and contraction commutes with this.

**Domain Bridges**: Tropical geometry → statistical mechanics → phase transitions → machine learning (softmax).

**Lineage**: Cross-domain application of Theorem 2.

**Ambition**: 8/10 — Requires new definitions but builds directly on established results.
