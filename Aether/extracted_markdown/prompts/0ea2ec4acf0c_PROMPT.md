

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## TASK: Lie-Algebraic Equivariant Learning — Irreducible Architecture Classification, Casimir-Certified Adversarial Robustness, and Root System Expressivity Bounds

### Mission Statement

Formalize and prove the foundational trilogy of Lie-algebraic equivariant learning theory, establishing the first verified bridge between semisimple Lie algebra representation theory and certified robust neural network architectures. This creates the rigorous infrastructure for *representation-theoretic adversarial certification*: computing Lipschitz bounds for equivariant networks purely from algebraic data (Casimir eigenvalues, root system rank), without gradient evaluation or empirical sampling.

---

### Domain Bridges

- **Bridge: Algebra → MachineLearning** — Irreducible decomposition classifies equivariant architectures (Clebsch-Gordan as architecture grammar)
- **Bridge: Physics (Quantum) → Cryptography** — Casimir certification mirrors quantum observable bounds; root system expressivity governs lattice-based equivariant cryptographic constructions
- **Bridge: RepresentationTheory → CertifiedRobustness** — Casimir eigenvalues yield deterministic Lipschitz certificates for equivariant layers

---

### Core Definitions (5+ Required)

```lean
/-- A g-equivariant neural network layer: a linear map intertwining two
    Lie algebra representations. Bridge: connects Algebra.LieAlgebra to
    MachineLearning.Equivariant. -/
structure EquivariantLayer (g : Type*) [LieRing g] [LieAlgebra g K]
    (V : Type*) [AddCommGroup V] [Module K V] [LieModule g K V]
    (W : Type*) [AddCommGroup W] [Module K W] [LieModule g K W] where
  toFun : V →ₗ[K] W
  intertwines : ∀ (x : g) (v : V), toFun (LieModule.smul x v) = LieModule.smul x (toFun v)

/-- The Casimir spectrum: assigns to each dominant weight the eigenvalue
    of the quadratic Casimir operator on the corresponding irreducible.
    Bridge: connects Physics.QuantumObservable to MachineLearning.LipschitzCertification. -/
structure CasimirSpectrum (g : Type*) [LieRing g] [LieAlgebra g K]
    [IsSemisimple g K] where
  eigenvalue : DominantWeight g → ℝ
  eigenvalue_pos : ∀ λ, 0 < eigenvalue λ
  acts_as_scalar : ∀ (λ : DominantWeight g) (V : IrreducibleRep g K λ) (v : V),
    CasimirOp g K V v = eigenvalue λ • v

/-- Certified Lipschitz bound derived from Casimir eigenvalues and
    intertwiner dimension. Bridge: connects Algebra.RepresentationTheory to
    MachineLearning.CertifiedRobustness. -/
structure CasimirLipschitzCertificate (g : Type*) [LieRing g] [LieAlgebra g K]
    [IsSemisimple g K] where
  sourceRep : Type* -- V with its g-module structure
  targetRep : Type* -- W with its g-module structure
  lipschitz_bound : ℝ
  certified : ∀ (φ : EquivariantLayer g K sourceRep targetRep),
    ‖(φ.toFun : sourceRep →ₗ[K] targetRep)‖ ≤ lipschitz_bound

/-- Root expressivity rank: the number of independent equivariant feature
    directions, equal to rank(Φ_g) + dim(center(g)).
    Bridge: connects Algebra.RootSystem to MachineLearning.Expressivity. -/
def rootExpressivityRank (g : Type*) [LieRing g] [LieAlgebra g K]
    [IsSemisimple g K] : ℕ :=
  rootSystemRank g + FiniteDimensional.finrank K (LieAlgebra.center g K)

/-- Intertwiner dimension: the dimension of the space of g-equivariant
    linear maps between two finite-dimensional representations.
    Equals Σ_λ min(m_λ(V), m_λ(W)) by Schur's lemma. -/
def intertwinerDim {g K : Type*} [Field K] [LieRing g] [LieAlgebra g K]
    [IsSemisimple g K] {V W : Type*} [AddCommGroup V] [Module K V]
    [LieModule g K V] [FiniteDimensional K V] [AddCommGroup W] [Module K W]
    [LieModule g K W] [FiniteDimensional K W] : ℕ :=
  Classical.choose <| intertwinerDimExists V W
```

---

### Theorem 1: Equivariant Architecture Classification (irreducible_decomposition_architecture)

**Statement**: Every g-equivariant finite-dimensional linear map between semisimple representations decomposes as a direct sum over irreducible constituents, with the intertwiner space dimension equal to the sum of min(m_λ(V), m_λ(W)) over all dominant weights λ.

```lean
/-- Bridge: connects Algebra.LieAlgebra to MachineLearning.Equivariant.
    The fundamental classification: equivariant layers are determined by
    Clebsch-Gordan multiplicities. -/
theorem irreducible_decomposition_architecture
    {g K : Type*} [Field K] [CharZero K] [LieRing g] [LieAlgebra g K]
    [IsSemisimple g K] {V W : Type*} [AddCommGroup V] [Module K V]
    [LieModule g K V] [FiniteDimensional K V] [IsSemisimpleModule g K V]
    [AddCommGroup W] [Module K W] [LieModule g K W] [FiniteDimensional K W]
    [IsSemisimpleModule g K W] :
    ∀ (φ : EquivariantLayer g K V W),
      ∃ (ι : Type*) [Fintype ι] (decompV : DirectSumDecomposition g K V ι)
        (decompW : DirectSumDecomposition g K W ι),
        ∀ i, ∃ (ψ_i : decompV.component i →ₗ[K] decompW.component i),
          φ.toFun = ∑ i, decompW.embed i ∘ₗ ψ_i ∘ₗ decompV.project i ∧
          IsEquivariant ψ_i ∧
          (Module.End.dim K (decompV.component i →ₗ[K] decompW.component i)) =
            min (multiplicity (weights V) i) (multiplicity (weights W) i)
```

**Proof Strategy A (Schur's Lemma + Complete Reducibility — RECOMMENDED)**:
1. **Step 1**: Prove `schur_lemma_semisimple`: For irreducible g-modules V, W over an algebraically closed field K, every g-equivariant map V →ₗ[K] W is either zero or an isomorphism. Use `by_contra` to show any nonzero equivariant map has trivial kernel (by irreducibility) and surjective image.
2. **Step 2**: Prove `intertwiner_decomposition_inductive`: By induction on the number of irreducible summands in V, decompose any φ ∈ Int(V,W) into components. The base case uses Schur's lemma directly. The inductive step uses the semisimplicity of V to project onto a summand.
3. **Step 3**: Prove `multiplicity_formula`: Show that `dim_K Int(V,W) = Σ_λ min(m_λ(V), m_λ(W))` by establishing a basis of the intertwiner space from pairs of irreducible subrepresentations sharing the same highest weight.
4. **Step 4**: Prove `clebsch_gordan_dimension`: Derive the Clebsch-Gordan coefficient formula as a corollary, specializing to V ⊗ W with known multiplicities.

**Proof Strategy B (Density Theorem + Double Commutant)**:
1. Use the Jacobson density theorem: the image of the universal enveloping algebra in End(V) is dense in the bicommutant.
2. Apply the double commutant theorem to characterize Int(V,W) as the commutant of the g-action.
3. Derive dimension from the structure of the bicommutant. Less direct but connects to von Neumann algebra techniques.

**Proof Strategy C (Character Theory)**:
1. Use characters χ_V, χ_W to compute dim Int(V,W) = ⟨χ_V, χ_W⟩ via orthogonality.
2. Reduce to the multiplicity formula via inner product of characters. Elegant but requires substantial character theory infrastructure.

**Key Lemmas**:
```lean
lemma schur_lemma_semisimple {g K V W : Type*} [Field K] [AlgebraicallyClosed K]
    [LieRing g] [LieAlgebra g K] [IsSemisimple g K]
    [AddCommGroup V] [Module K V] [LieModule g K V] [IsIrreducible g K V]
    [AddCommGroup W] [Module K W] [LieModule g K W] [IsIrreducible g K W]
    (φ : V →ₗ[K] W) (hφ : IsEquivariant φ) :
    (∀ v, φ v = 0) ∨ (∃ (ψ : V ≃ₗ[K] W), ∀ v, φ v = ψ v) :=
  by_contra fun h => ...

lemma intertwiner_dim_multiplicity {g K V W : Type*} [Field K] [CharZero K]
    [LieRing g] [LieAlgebra g K] [IsSemisimple g K]
    [AddCommGroup V] [Module K V] [LieModule g K V] [FiniteDimensional K V]
    [IsSemisimpleModule g K V]
    [AddCommGroup W] [Module K W] [LieModule g K W] [FiniteDimensional K W]
    [IsSemisimpleModule g K W] :
    intertwinerDim g K V W =
      Finset.sum (commonWeights V W)
        (fun λ => min (multiplicity V λ) (multiplicity W λ)) :=
  ...
```

---

### Theorem 2: Casimir-Certified Adversarial Robustness (casimir_lipschitz_certified_bound)

**Statement**: For a semisimple Lie algebra g with Killing form κ and quadratic Casimir C_Ω, any g-equivariant layer φ: V → W has operator norm bounded by √(c_W(λ_max) / c_V(μ_min)) · dim(Int(V,W)), where c_V(λ) is the Casimir eigenvalue on the λ-isotypic component.

```lean
/-- Bridge: connects Physics.QuantumObservable to MachineLearning.CertifiedRobustness.
    Casimir eigenvalues provide deterministic Lipschitz certificates for
    equivariant neural network layers — no gradient evaluation needed. -/
theorem casimir_lipschitz_certified_bound
    {g : Type*} [LieRing g] [LieAlgebra g ℝ]
    [IsSemisimple g ℝ] [FiniteDimensional ℝ g]
    {V W : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    [LieModule g ℝ V] [FiniteDimensional ℝ V] [IsSemisimpleModule g ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    [LieModule g ℝ W] [FiniteDimensional ℝ W] [IsSemisimpleModule g ℝ W]
    (φ : EquivariantLayer g ℝ V W)
    (hV : HasOrthogonalIrreducibleDecomposition V)
    (hW : HasOrthogonalIrreducibleDecomposition W) :
    let μ_min := Finset.min' (CasimirSpectrum.eigenvalues V) Finset.univ_nonempty
    let λ_max := Finset.max' (CasimirSpectrum.eigenvalues W) Finset.univ_nonempty
    let inter_dim := intertwinerDim g ℝ V W
    ‖(φ.toFun : V →ₗ[ℝ] W)‖ ≤ Real.sqrt (λ_max / μ_min) * inter_dim :=
  ...
```

**Proof Strategy (Casimir Diagonalization + Schur Norm Bound — RECOMMENDED)**:
1. **Step 1**: Prove `casimir_scalar_on_irreducible`: On each irreducible g-module V_λ, the Casimir C_Ω acts as c(λ) · Id where c(λ) = ⟨λ, λ + 2ρ⟩ / ⟨θ, θ⟩ with ρ the half-sum of positive roots. Use the fact that C_Ω is central in U(g), hence acts as a scalar on irreducibles by Schur's lemma. Prove the eigenvalue is positive using `linarith` + positivity of the Killing form restricted to the Cartan subalgebra.
2. **Step 2**: Prove `casimir_norm_bound_irreducible`: For any g-equivariant ψ: V_λ → W_μ between irreducibles, ‖ψ‖² ≤ c(μ)/c(λ) · dim(Hom_g(V_λ, W_μ)). If λ ≠ μ, this is 0 (by Schur). If λ = μ, this is c(λ)/c(λ) · 1 = 1. Use the fact that C_Ω is positive-definite on each isotypic component.
3. **Step 3**: Prove `intertwiner_norm_decomposition`: Decompose φ into components ψ_i on isotypic pieces using Theorem 1. Apply the triangle inequality and Step 2 to each piece. Sum over all irreducible constituents.
4. **Step 4**: Prove `multiplicity_bound`: Show that the number of nonzero components equals intertwinerDim g ℝ V W = Σ_λ min(m_λ(V), m_λ(W)). Combine with Step 3.
5. **Step 5**: Assemble the final bound using `linarith` and `Real.sqrt_le_sqrt`.

**Key Lemmas**:
```lean
lemma casimir_eigenvalue_positive {g : Type*} [LieRing g] [LieAlgebra g ℝ]
    [IsSemisimple g ℝ] {λ : DominantWeight g} :
    0 < CasimirSpectrum.eigenvalue λ :=
  linarith [killing_form_positive_definite_on_cartan λ]

lemma casimir_norm_bound_single {g : Type*} [LieRing g] [LieAlgebra g ℝ]
    [IsSemisimple g ℝ] {V W : IrreducibleRep g ℝ}
    (ψ : V →ₗ[ℝ] W) (hψ : IsEquivariant ψ) :
    ‖ψ‖ ≤ Real.sqrt (CasimirSpectrum.eigenvalue W.λ / CasimirSpectrum.eigenvalue V.λ)
        * (if V.λ = W.λ then 1 else 0) :=
  ...
```

---

### Theorem 3: Root System Expressivity Bounds (root_system_expressivity_tight_bound)

**Statement**: The number of linearly independent g-equivariant feature directions achievable by any g-equivariant network with semisimple g is exactly rank(Φ_g) + dim(center(g)). This equals the number of algebraically independent Casimir operators (fundamental invariants).

```lean
/-- Bridge: connects Algebra.RootSystem to MachineLearning.Expressivity.
    The expressivity gap: equivariant networks can realize at most
    rank(Φ_g) + dim(center(g)) independent equivariant feature directions,
    matching the number of fundamental invariants. -/
theorem root_system_expressivity_tight_bound
    (g : Type*) [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] :
    ∀ (n : ℕ) (arch : EquivariantNetwork g ℝ n),
      arch.equivariantFeatureDimension ≤ rootExpressivityRank g ℝ ∧
      ∃ (optimal : EquivariantNetwork g ℝ (rootExpressivityRank g ℝ)),
        optimal.equivariantFeatureDimension = rootExpressivityRank g ℝ :=
  ...
```

**Proof Strategy (Casimir Independence + Universal Envelope Center)**:
1. **Step 1**: Prove `casimir_independence_count`: The number of algebraically independent Casimir operators in Z(U(g)) equals rank(Φ_g) + dim(center(g)). This follows from the Harish-Chandra isomorphism Z(U(g)) ≅ S(h)^W where h is the Cartan and W the Weyl group. The invariant subring S(h)^W has transcendence degree equal to dim(h) = rank(Φ_g).
2. **Step 2**: Prove `equivariant_feature_bound_casimir`: Each g-equivariant feature direction must be an eigenspace of all Casimir operators. The number of independent Casimir eigenvalue specifications equals rank(Φ_g) + dim(center(g)). Use `omega` for the arithmetic on dimensions.
3. **Step 3**: Prove `expressivity_achievability`: Construct an explicit g-equivariant network achieving exactly rootExpressivityRank g ℝ independent features. Use the fundamental representations V(ω_1), ..., V(ω_r) as feature extractors.
4. **Step 4**: Prove the tightness claim by showing no g-equivariant construction can exceed this bound, using the algebraic independence of Casimir operators from Step 1.

**Key Lemmas**:
```lean
lemma harish_chandra_transcendence_degree (g : Type*) [LieRing g]
    [LieAlgebra g ℝ] [IsSemisimple g ℝ] [FiniteDimensional ℝ g] :
    Ring.TranscendenceDegree ℝ (Center (UniversalEnvelope g ℝ)) =
      rootSystemRank g + FiniteDimensional.finrank ℝ (LieAlgebra.center g ℝ) :=
  ...

lemma casimir_eigenspace_decomposition_independent
    {g : Type*} [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] (V : Type*) [AddCommGroup V] [Module ℝ V]
    [LieModule g ℝ V] [FiniteDimensional ℝ V] :
    ∀ (features : Finset (V →ₗ[ℝ] ℝ)),
      (∀ f ∈ features, IsEquivariant f) →
      features.card ≤ rootExpressivityRank g ℝ :=
  ...
```

---

### Supporting Infrastructure (10+ Theorems Required)

```lean
/-- Casimir operator is central in the universal enveloping algebra -/
theorem casimir_central {g K : Type*} [Field K] [CharZero K]
    [LieRing g] [LieAlgebra g K] [IsSemisimple g K]
    [FiniteDimensional K g] :
    ∃ (C : UniversalEnvelope g K), ∀ x, ⁅C, UniversalEnvelope.algebraMap x⁆ = 0

/-- Schur's lemma for algebraically closed fields -/
theorem schur_lemma_algebraically_closed
    {g K V W : Type*} [Field K] [AlgebraicallyClosed K]
    [LieRing g] [LieAlgebra g K] [IsSemisimple g K]
    [AddCommGroup V] [Module K V] [LieModule g K V] [IsIrreducible g K V]
    [AddCommGroup W] [Module K W] [LieModule g K W] [IsIrreducible g K W]
    (φ : V →ₗ[K] W) (hφ : IsEquivariant φ) :
    (∀ v, φ v = 0) ∨ IsLinearEquiv φ

/-- Complete reducibility for semisimple modules -/
theorem weyl_complete_reducibility
    {g K V : Type*} [Field K] [CharZero K]
    [LieRing g] [LieAlgebra g K] [IsSemisimple g K]
    [AddCommGroup V] [Module K V] [LieModule g K V] [FiniteDimensional K V]
    [IsSemisimpleModule g K V] :
    ∃ (ι : Type*) [Fintype ι] (decomp : DirectSumDecomposition g K V ι),
      ∀ i, IsIrreducible g K (decomp.component i)

/-- Intertwiner dimension equals multiplicity sum -/
theorem intertwiner_dim_multiplicity_sum
    {g K V W : Type*} [Field K] [CharZero K]
    [LieRing g] [LieAlgebra g K] [IsSemisimple g K]
    [AddCommGroup V] [Module K V] [LieModule g K V] [FiniteDimensional K V]
    [IsSemisimpleModule g K V]
    [AddCommGroup W] [Module K W] [LieModule g K W] [FiniteDimensional K W]
    [IsSemisimpleModule g K W] :
    Module.dim K (IntertwinerSpace g K V W) =
      Finset.sum (commonWeights V W)
        (fun λ => min (multiplicity V λ) (multiplicity W λ))

/-- Casimir eigenvalue is strictly positive on nontrivial irreducibles -/
theorem casimir_eigenvalue_strictly_positive
    {g : Type*} [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] {λ : DominantWeight g} (hλ : λ ≠ 0) :
    0 < CasimirSpectrum.eigenvalue λ

/-- Killing form is nondegenerate on semisimple Lie algebras (Cartan criterion) -/
theorem killing_form_nondegenerate_semisimple
    {g K : Type*} [Field K] [CharZero K]
    [LieRing g] [LieAlgebra g K] [IsSemisimple g K]
    [FiniteDimensional K g] :
    BilinForm.Nondeg (killingForm g K)

/-- Root system rank equals Cartan subalgebra dimension -/
theorem root_system_rank_eq_cartan_dim
    {g : Type*} [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] :
    rootSystemRank g = FiniteDimensional.finrank ℝ (CartanSubalgebra g ℝ)

/-- Lipschitz constant for equivariant layers on isotypic components -/
theorem isotypic_lipschitz_bound
    {g : Type*} [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] {V W : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    [LieModule g ℝ V] [FiniteDimensional ℝ V] [IsIsotypic g ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    [LieModule g ℝ W] [FiniteDimensional ℝ W] [IsIsotypic g ℝ W]
    (φ : EquivariantLayer g ℝ V W) :
    ‖φ.toFun‖ ≤ Real.sqrt (CasimirSpectrum.eigenvalue (highestWeight W) /
                           CasimirSpectrum.eigenvalue (highestWeight V)) *
                   min (multiplicity V (highestWeight V))
                       (multiplicity W (highestWeight W))

/-- Expressivity gap between equivariant and unconstrained architectures -/
theorem expressivity_gap_lower_bound
    {g : Type*} [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] {n : ℕ} :
    ∀ (arch : EquivariantNetwork g ℝ n),
      (unconstrainedFeatureDimension n -
       arch.equivariantFeatureDimension) ≥
        (n - rootExpressivityRank g ℝ)

/-- Certified robustness radius from Casimir data -/
theorem casimir_certified_robustness_radius
    {g : Type*} [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] {V W : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    [LieModule g ℝ V] [FiniteDimensional ℝ V] [IsSemisimpleModule g ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    [LieModule g ℝ W] [FiniteDimensional ℝ W] [IsSemisimpleModule g ℝ W]
    (φ : EquivariantLayer g ℝ V W) (margin : ℝ) (hmargin : 0 < margin) :
    let L := Real.sqrt (CasimirSpectrum.max_eigenvalue W /
                        CasimirSpectrum.min_eigenvalue V) *
              intertwinerDim g ℝ V W
    ∀ x y : V, ‖x - y‖ < margin / L →
      ‖φ.toFun x - φ.toFun y‖ < margin

/-- Weyl dimension formula for irreducible dimension -/
theorem weyl_dimension_formula
    {g : Type*} [LieRing g] [LieAlgebra g ℝ] [IsSemisimple g ℝ]
    [FiniteDimensional ℝ g] (λ : DominantWeight g) :
    FiniteDimensional.finrank ℝ (IrreducibleRep.mk λ) =
      ∏ ρ ∈ positiveRoots g, (⟪λ + ρ, ρ⟫ / ⟪ρ, ρ⟫ : ℝ).floor
```

---

### Computational Complexity Bounds

- **Intertwiner dimension computation**: O(dim(V) · dim(W)) via multiplicity counting (Theorem 1)
- **Casimir Lipschitz certification**: O(rank(g)²) — only requires root system data, not network parameters (Theorem 2)
- **Expressivity rank**: O(1) lookup from Lie algebra type (Theorem 3)

---

### Significance and Applications

1. **Certified Adversarial Robustness for Equivariant Networks**: Theorem 2 provides the first *representation-theoretic Lipschitz certificate* — given only the Lie algebra type and representation data, one can compute a deterministic upper bound on the Lipschitz constant of any equivariant layer. This eliminates the need for expensive gradient-based Lipschitz estimation.

2. **Architecture Search via Clebsch-Gordan**: Theorem 1 reduces equivariant architecture design to computing Clebsch-Gordan coefficients, enabling automated architecture search with provable completeness guarantees.

3. **Expressivity-Robustness Tradeoff**: Theorem 3 quantifies the fundamental cost of equivariance — exactly rank(g) + dim(center(g)) independent feature directions — enabling principled comparison between equivariant and unconstrained architectures.

4. **Post-Quantum Cryptographic Implications**: Root system expressivity bounds govern the security of lattice-based equivariant cryptographic constructions (e.g., Learning With Errors over Lie algebra representations).

5. **Quantum Observable Bounds**: The Casimir certification mirrors quantum mechanical bounds on observables — the same algebraic structure governs both equivariant network robustness and quantum uncertainty relations.

---

### FUTURE_DIRECTIONS.md Request

After completing the proofs, produce a structured FUTURE_DIRECTIONS.md with 3-5 concrete next steps:

1. **Tropical Casimir Certification**: Extend Theorem 2 to tropical (min-plus) semirings, yielding certified robustness for tropical equivariant networks with applications to lattice-based post-quantum cryptography.

2. **Quantum Lie Algebra Networks**: Formalize the correspondence between g-equivariant layers and quantum channels on representation spaces, proving that Casimir certification is equivalent to quantum channel capacity bounds.

3. **Equivariant Universal Approximation**: Prove that g-equivariant networks with depth O(rank(g) · log(1/ε)) can ε-approximate any continuous g-equivariant function, with the depth bound determined by root system data alone.

4. **Casimir Spectral Gaps in Adversarial Training**: Connect the Casimir eigenvalue ratio λ_max/μ_min to spectral gap analysis of adversarial training dynamics, proving convergence rates for equivariant adversarial training.

5. **Lie Superalgebra Expressivity**: Extend Theorem 3 to Lie superalgebras, characterizing the expressivity of supersymmetric neural networks with applications to quantum ML.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of Lie-algebraic equivariant learning theory by proving three foundational theorems that establish a precise correspondence between Lie algebra representation theory and equivariant neural network architectures, creating the first bridge between Algebra (5009 declarations) and MachineLearning (1417 declarations) which currently share 20+ structural concepts but have zero cross-domain files. Theorem 1 (Equivariant Architecture Classification): Every g-equivariant finite-dimensional neural network layer decomposes as a direct sum of irreducible g-representations, with the intertwiner space Int(V,W) having dimension equal to the multiplicity of common irreducible constituents, classifying all possible equivariant architectures via Clebsch-Gordan coefficients. Theorem 2 (Casimir Adversarial Certification): For a semisimple Lie algebra g with quadratic Casimir C_Ω, the operator norm of any g-equivariant layer φ: V → W is bounded by ∥φ∥ ≤ √(c_W(λ_max)/c_V(μ_min)) · dim(Int(V,W)), providing certified Lipschitz robustness bounds from representation-theoretic data alone without empirical evaluation. Theorem 3 (Root System Expressivity): The g-equivariant approximation capacity is tightly bounded by rank(Φ_g) + dim(center(g)): g-equivariant networks can approximate at most r independent equivariant feature directions where r = rank(Φ_g), characterizing the expressivity gap between equivariant and unconstrained architectures.

            ### Precise Mathematical Framing
            Let g be a finite-dimensional Lie algebra over K (char 0). A neural layer φ: V → W between finite-dimensional g-representations is g-equivariant if φ(g·v) = g·φ(v) for all g ∈ g, v ∈ V. When g is semisimple, every finite-dimensional representation decomposes as V ≅ ⊕_i V_{λ_i}^{⊕m_i} into irreducibles with highest weights λ_i and multiplicities m_i (Weyl's complete reducibility). By Schur's lemma, Int(V,W) = Hom_g(V,W) has dimension Σ_i min(m_i^V, m_i^W). The quadratic Casimir C_Ω = Σ_i x_i x^i acts as scalar c(λ) = ⟨λ, λ+2ρ⟩ on each irreducible V_λ. For any g-equivariant φ: V → W, the spectral norm bound ∥φ∥² ≤ (max_λ c_W(λ)/min_μ c_V(μ)) · dim(Int(V,W)) follows from eigenvalue comparison of C_Ω. For expressivity: the Cartan subalgebra h ⊂ g has dimension r = rank(Φ_g), and any g-equivariant architecture distinguishes at most r independent feature directions, giving the tight bound dim(Equiv_g) = rank(Φ_g) + dim(center(g)). This creates the first Algebra ↔ MachineLearning bridge, using Lie-theoretic invariants (Casimir eigenvalues, root system rank, intertwiner dimensions) to certify equivariant ML properties (robustness, expressivity, architecture design).



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `certified_robustness_from_margin_and_lipschitz` : theorem certified_robustness_from_margin_and_lipschitz
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `separating_implies_exists_feature_with_positive_gap` : theorem separating_implies_exists_feature_with_positive_gap
     (file: Bridges/TropicalSatakeMargin.lean)
  3. `certified_robustness_from_lipschitz_spectral` : theorem certified_robustness_from_lipschitz_spectral
     (file: Algebra/SpectralArithmetic/Core.lean)
  4. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  5. `cooling_gap_bounded` : theorem cooling_gap_bounded (beta : ℝ) (hbeta : 1 ≤ beta) :
     (file: Bridges/TropicalDeepLearningTheory.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Operadic Error-Correcting Codes: Symmetric Operad Algebra Composition, Singleton Bound Characterization, and Functorial Decoding Certification, Tropical Information Geometry: Min-Plus Fisher Information, Tropical Cramér-Rao Certification, and Idempotent Natural Gradient Descent, Algebraic Closure Unification: Ideal-Theoretic EML Instances, Galois Connection Fixed-Point Duality, and Noetherian Closure Certification


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
