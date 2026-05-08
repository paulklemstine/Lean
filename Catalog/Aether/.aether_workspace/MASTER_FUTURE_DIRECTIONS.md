# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-08 10:06*

## Breakthrough Opportunities (ranked by impact)

### 1. Full Tensor Coproduct Coassociativity

**Theorem Statement**: For all rooted trees t, (Δ ⊗ id) ∘ Δ(t) = (id ⊗ Δ) ∘ Δ(t) where Δ is the admissible cut coproduct on H_CK ⊗ H_CK via Mathlib's TensorProduct.

**Proof Strategy**:
- Define Δ as a linear map using `Finsupp` over pairs of forests
- Prove a "double-cut bijection" lemma: admissible cuts of R_c(t) correspond to two-stage cuts of t
- Use structural induction on `RTree`

**Why Revolutionary**: This would be the first machine-verified coalgebra structure on a concrete combinatorial Hopf algebra. It connects abstract category theory (Mac Lane coherence) to concrete physics (locality of counterterms).

**Catalog Leverage**: Build on `RTree.admCutCount`, `TripleSplitting`, `GradedCoalgebra`

**Research Mode**: prove
**Estimated Depth**: 4

### 2. Recursive Antipode Formula and Zimmermann Forest Formula

**Theorem Statement**: S(B₊(f)) = -B₊(f) - Σ S(P_c(f)) · R_c(f) for all forests f, where the sum is over proper admissible cuts.

**Proof Strategy**:
- Define S by well-founded recursion on tree depth
- Prove S * id = id * S = η ∘ ε (convolution inverse)
- Extract the explicit Zimmermann formula as a consequence

**Why Revolutionary**: The Zimmermann forest formula is the algorithmic core of renormalization. Verifying it would make every BPHZ computation in QFT rest on certified foundations.

**Catalog Leverage**: `antipodeCoeff`, `admCutCount_linear_chain`, `admCutCount_corolla`

**Research Mode**: prove
**Estimated Depth**: 5

### 3. Birkhoff Decomposition Existence and Uniqueness

**Theorem Statement**: For every character φ : H_CK → A with A a Rota-Baxter algebra of weight λ, there exist unique φ₋, φ₊ with φ = φ₋ ⋆ φ₊, where φ₋ = -R(φ ∘ B₊ ∘ (S ⋆ φ₊)) and φ₊ = (1-R)(φ ∘ B₊ ∘ (S ⋆ φ₊)).

**Proof Strategy**:
- Define the convolution product on characters
- Prove existence by recursion on the graded filtration
- Prove uniqueness using the Rota-Baxter identity and induction

**Why Revolutionary**: This is the algebraic Birkhoff-Wiener-Hopf decomposition — the mathematical heart of dimensional regularization. Certified uniqueness would prove that minimal subtraction is well-defined.

**Catalog Leverage**: `BirkhoffDecomp`, `rbBirkhoff`, `RotaBaxterOp` (from RotaBaxter.lean)

**Research Mode**: prove
**Estimated Depth**: 5

### 4. Free Hopf Universal Property

**Theorem Statement**: For any commutative Hopf algebra H with 1-cocycle L, ∃! φ : H_CK →ₐ H, φ ∘ B₊ = L ∘ φ.

**Proof Strategy**:
- Define φ by recursion: φ(B₊(f)) = L(φ(f))
- Verify φ preserves multiplication (using commutativity of H)
- Verify φ preserves coproduct (using the cocycle condition)
- Prove uniqueness by induction on tree depth

**Why Revolutionary**: Establishes H_CK as the universal renormalization scheme, proving that any consistent renormalization must factor through the tree algebra.

**Catalog Leverage**: `OneCocycle`, `CocycleMorphism`, `cocycleMorphism_preserves_cocycle_deg`

**Research Mode**: prove
**Estimated Depth**: 5

### 5. Non-Linear β-Function Fixed Points and Critical Exponents

**Theorem Statement**: For the non-linear RG flow T_NL(β)(n) = -Σ_{k+l=n} β(k)·φ₊(l)/(1+λ), there exist non-trivial fixed points when the coupling exceeds a critical value g_c.

**Proof Strategy**:
- Formalize the non-linear iteration operator
- Apply Schauder's fixed-point theorem (or Banach on a ball)
- Compute the critical exponent η = -log(g_c)/log(1+λ)

**Why Revolutionary**: Non-trivial RG fixed points correspond to conformal field theories (CFTs). Certified existence of CFTs from algebraic data would be unprecedented.

**Catalog Leverage**: `rgFlowOp_convergence`, `rg_fixed_point_unique`, `betaCoeff_bound`

**Research Mode**: prove
**Estimated Depth**: 4

### 6. Tropical Renormalization and Min-Plus Hopf Algebras

**Theorem Statement**: Define a tropical Connes-Kreimer algebra over (ℝ∪{∞}, min, +). Prove that the tropical coproduct is coassociative and the tropical antipode satisfies S(t) = depth(t) for linear chains.

**Proof Strategy**:
- Replace ring operations with tropical (min-plus) operations
- Show tropical admissible cuts have the same combinatorial structure
- Prove tropical coassociativity from the standard case

**Why Revolutionary**: Connects algebraic renormalization to tropical geometry, opening a new bridge between QFT and combinatorial optimization. The tropical β-function would give piecewise-linear RG flows.

**Catalog Leverage**: Tropical semiring infrastructure from `EML/EMLTropicalSemiring.lean`

**Research Mode**: discover
**Estimated Depth**: 3