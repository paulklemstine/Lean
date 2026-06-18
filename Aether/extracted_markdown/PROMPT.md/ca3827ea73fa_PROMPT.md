

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## FORMALIZE: Algebraic Learning Theory — Module-Theoretic VC Dimension, Spectral Rademacher Decomposition, and Certified Generalization

### The Vision

We open the field of **algebraic learning theory**: the systematic transfer of statistical learning theory (VC dimension, Rademacher complexity, PAC bounds) from vector spaces over ℝ to modules over arbitrary semirings. This creates the first rigorous bridge between commutative algebra and certified machine learning, with direct applications to:

- **Post-quantum cryptography**: Lattice-based security reductions via algebraic PAC bounds over ℤ-semimodules
- **Certified robustness**: Lipschitz-certified neural network bounds from Noetherian dimension
- **Tropical information theory**: Spectral decomposition of learning complexity over idempotent semirings

The central breakthrough: classical learning theory secretly depends only on the *algebraic* structure of hypothesis classes, not on the analytic structure of ℝ. By replacing vector spaces with modules and norms with spectral valuations, we obtain *strictly tighter* bounds for idempotent semirings (where d_S ≤ log₂(dim_ℝ(M⊗ℝ))) and *lattice-hard* lower bounds for ℤ-semimodules (connecting to worst-case lattice problems in post-quantum crypto).

---

### File 1: `AlgebraicLearningTheory/AlgebraicHypothesis.lean`

**Define the foundational structures.** Every definition must carry a doc comment connecting it to at least one other domain.

```lean
/-- An algebraic hypothesis class over a semiring S is a hypothesis class
    parametrized by an S-module M. When S = ℝ, this recovers the classical
    linear hypothesis class. Bridge: connects Module theory to ML hypothesis classes. -/
structure AlgebraicHypothesisClass (S : Type*) [CommSemiring S]
    (M : Type*) [AddCommMonoid M] [Module S M] (X : Type*) where
  /-- The embedding of module elements as functions X → S -/
  embed : M → (X → S)
  /-- Linearity: the embedding respects the S-module structure -/
  embed_smul : ∀ (r : S) (m : M) (x : X), embed (r • m) x = r * embed m x
  embed_add : ∀ (m₁ m₂ : M) (x : X), embed (m₁ + m₂) x = embed m₁ x + embed m₂ x

/-- The algebraic dimension of a hypothesis class is the minimal number of
    generators of the parametrizing module. For S = ℝ, this equals dim_ℝ(V).
    Bridge: connects Noetherian dimension to VC dimension. -/
noncomputable def algebraicDimension {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] : ℕ :=
  Module.minGenerators S M

/-- The shattering number of an algebraic hypothesis class on a finite set.
    This is the semiring analogue of the classical VC shattering condition,
    replacing sign patterns with S-valued pattern separation. -/
def algebraicShattering {S : Type*} [CommSemiring S] [DecidableEq S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (A : Finset X) : Prop :=
  ∀ (f : A → S), ∃ m : M, ∀ (x : A), H.embed m x.val = f x

/-- The module-theoretic VC dimension: the supremum of finite sets that can be
    algebraically shattered. Bridge: connects VC theory to commutative algebra. -/
noncomputable def moduleVCDimension {S : Type*} [CommSemiring S] [DecidableEq S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) : WithBot ℕ :=
  sSup {n | ∃ (A : Finset X), A.card = n ∧ algebraicShattering H A}
```

**Prove the following (10+ theorems, ZERO sorries):**

```lean
/-- Bridge: connects Noetherian algebra to VC dimension bounds.
    The algebraic dimension upper-bounds the module VC dimension.
    For S = ℝ, this recovers dim(V) ≥ VCdim(H_V).
    Proof strategy A: Induction on minimal generators using quotient modules.
    Proof strategy B: Contradiction — assume shattering exceeds generators,
    then linear dependence forces pattern collision.
    Strategy B is preferred: direct and constructive. -/
theorem algebraic_dimension_bounds_vc {S : Type*} [CommSemiring S] [DecidableEq S]
    {M : Type*} [AddCommMonoid M] [Module S M] [Module.Finite S M]
    {X : Type*} (H : AlgebraicHypothesisClass S M X) :
    moduleVCDimension H ≤ algebraicDimension := by
  -- Key lemma: if d generators, then any set of size d+1 cannot be shattered
  -- because generator dependence creates pattern collisions
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects field theory to learning theory.
    Over a field, algebraic dimension equals classical dimension. -/
theorem field_algebraic_dimension_eq_dim (K : Type*) [Field K]
    (V : Type*) [AddCommGroup V] [Module K V] [FiniteDimensional K V] :
    algebraicDimension = Module.finrank K V := by
  -- Use the fact that minGenerators over a field = finrank
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects Noetherian condition to finite VC dimension.
    Noetherian hypothesis classes have finite VC dimension.
    This is the algebraic analogue of the classical finiteness theorem. -/
theorem noetherian_implies_finite_vc {S : Type*} [CommSemiring S] [DecidableEq S]
    {M : Type*} [AddCommMonoid M] [Module S M] [IsNoetherian S M]
    {X : Type*} (H : AlgebraicHypothesisClass S M X) :
    ∃ (d : ℕ), moduleVCDimension H = d := by
  -- IsNoetherian implies Module.Finite, then apply algebraic_dimension_bounds_vc
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects module quotients to VC dimension reduction.
    Quotienting the module by a submodule reduces VC dimension
    by at most the rank of the submodule. -/
theorem quotient_vc_dimension_le {S : Type*} [CommSemiring S] [DecidableEq S]
    {M : Type*} [AddCommMonoid M] [Module S M]
    (N : Submodule S M) {X : Type*}
    (H : AlgebraicHypothesisClass S M X)
    (Hq : AlgebraicHypothesisClass S (M ⧸ N) X) :
    moduleVCDimension Hq + Module.minGenerators S N ≤
      moduleVCDimension H + Module.minGenerators S N := by
  -- Use the short exact sequence 0 → N → M → M/N → 0
  -- and the additivity of minimal generators
  sorry  -- REPLACE WITH FULL PROOF

/-- The fiber dimension formula: VC dimension decomposes over direct sums.
    Bridge: connects module direct sums to ensemble learning. -/
theorem vc_dimension_direct_sum {S : Type*} [CommSemiring S] [DecidableEq S]
    {M₁ M₂ : Type*} [AddCommMonoid M₁] [AddCommMonoid M₂]
    [Module S M₁] [Module S M₂] {X : Type*}
    (H₁ : AlgebraicHypothesisClass S M₁ X)
    (H₂ : AlgebraicHypothesisClass S M₂ X)
    (H : AlgebraicHypothesisClass S (M₁ × M₂) X) :
    moduleVCDimension H ≥ moduleVCDimension H₁ + moduleVCDimension H₂ := by
  -- Direct sum allows independent shattering of both components
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects idempotent semirings to tropical ML.
    For idempotent semirings (tropical), the algebraic dimension satisfies
    d_S ≤ log₂(dim_ℝ(M ⊗_S ℝ)), giving exponential compression.
    This is the key to certified robustness in tropical neural networks. -/
theorem idempotent_compression_bound {S : Type*} [CommSemiring S]
    [IsIdempotent S] {M : Type*} [AddCommMonoid M] [Module S M]
    [Module.Finite S M] :
    ∃ (V : Type*) [AddCommGroup V] [Module ℝ V] [FiniteDimensional ℝ V],
      algebraicDimension (S := S) (M := M) ≤
        Nat.log 2 (Module.finrank ℝ V) := by
  -- The idempotent law x + x = x collapses the module structure
  -- Each generator can only produce 2^d distinct patterns over ℝ
  -- so d_S ≤ log₂(dim_ℝ(M ⊗ ℝ))
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects lattice modules to post-quantum cryptography.
    For S = ℕ (the natural number semiring), algebraic VC dimension
    gives a lower bound on lattice covering radius, connecting
    learning theory to worst-case lattice hardness. -/
theorem lattice_vc_hardness_lower_bound {M : Type*} [AddCommGroup M] [Module ℤ M]
    [Module.Finite ℤ M] {X : Type*} [Fintype X]
    (H : AlgebraicHypothesisClass ℤ M X)
    (h_dim : moduleVCDimension H = d) (h_d_pos : 0 < d) :
    ∃ (L : Submodule ℤ M), L.rank = d ∧
      ∀ (ε : ℝ), ε > 0 →
        ∃ (v : M), ‖v‖ ≥ (d : ℝ)^(1/(2:ℝ)) ∧ ∀ u ∈ L, ‖v - u‖ ≥ ε := by
  -- VC dimension d implies d linearly independent shattered points
  -- These form a sublattice of rank d with large covering radius
  -- Connection to worst-case lattice problems (SVP, CVP)
  sorry  -- REPLACE WITH FULL PROOF
```

---

### File 2: `AlgebraicLearningTheory/SpectralRademacher.lean`

**Formalize the spectral decomposition of Rademacher complexity over the prime spectrum of a semiring.** This is the deepest result: the learning complexity of an algebraic hypothesis class decomposes as a *tropical integral* over Spec(S).

```lean
/-- The spectral valuation on Spec(S): assigns a tropical weight to each prime.
    Bridge: connects algebraic geometry (prime spectrum) to learning theory. -/
noncomputable def spectralValuation {S : Type*} [CommSemiring S]
    (p : PrimeSpectrum S) : ℝ≥0 :=
  -- Weight proportional to the "size" of the residue field at p
  -- For maximal ideals, this is the dimension of the fiber module
  (Module.minGenerators (ResidueField p) (ResidueFiber p p.asIdeal) : ℝ≥0)

/-- The fiber hypothesis class at a prime p: restrict H to the residue field.
    Bridge: connects localization in algebra to specialization in learning. -/
noncomputable def fiberHypothesisClass {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X)
    (p : PrimeSpectrum S) :
    AlgebraicHypothesisClass (ResidueField p) (M ⊗_S ResidueField p) X :=
  -- Localize the module at p, then quotient by the maximal ideal
  sorry  -- REMOVE: construct using Module.Localization and quotient

/-- The empirical Rademacher complexity of an algebraic hypothesis class.
    Classical definition: E_σ[sup_{h∈H} (1/n) Σ σᵢ h(xᵢ)] / n
    where σᵢ are i.i.d. Rademacher random variables. -/
noncomputable def empiricalRademacher {S : Type*} [CommSemiring S] [NormedCommRing S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X)
    (x : Fin n → X) : ℝ :=
  -- E over Rademacher variables σ of sup over h in H of (1/n) |Σ σᵢ h(xᵢ)|
  sorry  -- REMOVE: formalize expectation over Rademacher variables

/-- THE CENTRAL THEOREM: Spectral Rademacher Decomposition.
    The empirical Rademacher complexity decomposes as a tropical sum
    (min-plus) over the prime spectrum of S.

    R̂_n(H) = ⊕_{p ∈ Spec(S)} R̂_n(H_p) ⊗ μ(p)

    where ⊕ is tropical addition (min), ⊗ is tropical multiplication (+),
    H_p is the fiber hypothesis class, and μ is the spectral valuation.

    Bridge: connects tropical geometry to statistical learning theory.
    Impact: enables certified_robustness bounds via spectral decomposition.

    Proof Strategy A: Use the Chinese Remainder Theorem for modules over
    semirings to decompose M as a subdirect product of fiber modules,
    then apply subadditivity of Rademacher complexity.

    Proof Strategy B: Use the structure theorem for finitely generated
    modules over Noetherian semirings (generalizing the Smith normal form),
    reducing to the case where S is a field.

    Proof Strategy C (PREFERRED): Induction on the Krull dimension of S.
    Base case: dim(S) = 0 (field), trivial. Inductive step: use the
    filtration by prime ideals and the exact sequence
    0 → M/p → M → M_p → 0 to split the complexity. -/
theorem spectral_rademacher_decomposition
    {S : Type*} [CommSemiring S] [NormedCommRing S] [IsNoetherianRing S]
    {M : Type*} [AddCommMonoid M] [Module S M] [Module.Finite S M]
    {X : Type*} [MeasurableSpace X] [Fintype X]
    (H : AlgebraicHypothesisClass S M X)
    (x : Fin n → X)
    (h_finite_spec : (PrimeSpectrum S).Finite) :
    empiricalRademacher H x =
      sFinset.min (PrimeSpectrum S).toFinset (fun p =>
        empiricalRademacher (fiberHypothesisClass H p) x +
          (spectralValuation p : ℝ)) := by
  -- Main proof by induction on Krull dimension
  -- Key lemma: subadditivity of Rademacher over exact sequences
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects Krull dimension to sample complexity.
    The sample complexity is O(d_S · log(1/δ)/ε²) where d_S is
    the algebraic dimension (min generators of M). -/
theorem algebraic_pac_bound {S : Type*} [CommSemiring S] [NormedCommRing S]
    {M : Type*} [AddCommMonoid M] [Module S M] [Module.Finite S M]
    {X : Type*} [MeasurableSpace X] [Fintype X]
    (H : AlgebraicHypothesisClass S M X)
    (d : ℕ) (h_d : algebraicDimension (S := S) (M := M) = d)
    (ε δ : ℝ) (h_ε : 0 < ε) (h_δ : 0 < δ) (h_δ_lt : δ < 1) :
    ∃ (C : ℝ) (h_C : C = 8 / (3 : ℝ)),
      ∃ (n : ℕ),
        n ≤ Nat.ceil (C * d * Real.log (1 / δ) / ε^2) ∧
        ∀ (sample : Fin n → X) (h_sample : True),
          ∀ (h : M),
            Module.norm (h : X → S) ≤ 1 →
              Module.empiricalError H h sample ≤ ε ∨
                Module.trueError H h ≥ 1 - δ := by
  -- Use spectral_rademacher_decomposition + McDiarmid's inequality
  -- The key step: R̂_n ≤ d_S / n, then apply standard PAC conversion
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects tropical geometry to certified robustness.
    For idempotent semirings, the spectral decomposition simplifies
    because Spec(S) has a unique minimal prime (the tropical base point),
    giving a single-term tropical integral with improved bound. -/
theorem tropical_certified_robustness_bound {S : Type*} [CommSemiring S]
    [IsIdempotent S] [NormedCommRing S]
    {M : Type*} [AddCommMonoid M] [Module S M] [Module.Finite S M]
    {X : Type*} [MetricSpace X] [Fintype X]
    (H : AlgebraicHypothesisClass S M X)
    (d : ℕ) (h_d : algebraicDimension (S := S) (M := M) = d)
    (r : ℝ) (h_r : 0 < r) :
    ∃ (L : ℝ), L = d⁻¹ * r ∧
      ∀ (x y : X), dist x y ≤ L →
        ∀ (h : M), Module.lipschitz_certified H h r →
          Module.lipschitz_certified H h (r - dist x y) := by
  -- Idempotent semiring: d_S ≤ log₂(dim_ℝ(M ⊗ ℝ))
  -- gives Lipschitz constant L = d_S⁻¹ · r
  -- This is the certified robustness certificate for tropical networks
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects prime avoidance to hypothesis class decomposition.
    If two primes p, q ∈ Spec(S) are incomparable, then the
    fiber hypothesis classes H_p and H_q are "independent"
    in the sense that their Rademacher complexities multiply. -/
theorem incomparable_primes_fiber_independence {S : Type*} [CommSemiring S]
    [NormedCommRing S]
    {M : Type*} [AddCommMonoid M] [Module S M] [Module.Finite S M]
    {X : Type*} [Fintype X]
    (H : AlgebraicHypothesisClass S M X)
    (p q : PrimeSpectrum S)
    (h_incomp : ¬(p.asIdeal ≤ q.asIdeal) ∧ ¬(q.asIdeal ≤ p.asIdeal)) :
    empiricalRademacher (fiberHypothesisClass H p) default *
      empiricalRademacher (fiberHypothesisClass H q) default ≤
        empiricalRademacher H default := by
  -- Incomparable primes give orthogonal decompositions
  -- Rademacher of direct product ≤ product of Rademachers
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects Hilbert basis theorem to uniform convergence.
    Noetherian semirings have finite Krull dimension, which gives
    a uniform bound on Rademacher complexity over all fiber classes. -/
theorem noetherian_uniform_rademacher_bound {S : Type*} [CommSemiring S]
    [NormedCommRing S] [IsNoetherianRing S]
    {M : Type*} [AddCommMonoid M] [Module S M] [Module.Finite S M]
    {X : Type*} [Fintype X]
    (H : AlgebraicHypothesisClass S M X) :
    ∃ (B : ℝ), ∀ (n : ℕ) (x : Fin n → X),
      empiricalRademacher H x ≤ B * (Module.minGenerators S M : ℝ) /
        (n : ℝ) := by
  -- Krull dimension is finite for Noetherian semirings
  -- Each fiber contributes at most d_p/n where Σ d_p ≤ d_S
  sorry  -- REPLACE WITH FULL PROOF
```

---

### File 3: `AlgebraicLearningTheory/PostQuantumSecurity.lean`

**Bridge to post-quantum cryptography**: algebraic PAC bounds over ℤ-semimodules give hardness reductions for lattice-based cryptography.

```lean
/-- Bridge: connects algebraic PAC bounds to post-quantum lattice security.
    The algebraic dimension d_S of a ℤ-module M gives a direct lower bound
    on the shortest vector problem (SVP) in the corresponding lattice.
    This establishes: efficient learning over ℤ-modules ⟹ SVP is easy. -/
theorem post_quantum_learning_hardness {M : Type*} [AddCommGroup M] [Module ℤ M]
    [Module.Finite ℤ M] {X : Type*} [Fintype X]
    (H : AlgebraicHypothesisClass ℤ M X)
    (d : ℕ) (h_d : algebraicDimension (S := ℤ) (M := M) = d)
    (h_d_pos : 0 < d) :
    ∃ (L : Submodule ℤ M),
      L.rank = d ∧
      (∀ (ε δ : ℝ), ε > 0 → δ > 0 →
        ∃ (n : ℕ), n ≤ Nat.ceil (8 * d * Real.log (1/δ) / ε^2) ∧
          -- Learning over L requires at least Ω(d/ε²) samples
          -- which is polynomial, but breaking L-based crypto
          -- requires 2^{Ω(d)} time (worst-case lattice hardness)
          True) ∧
      -- The ratio 2^d / (d/ε²) is the security gap
      (2^d : ℝ) / (d * 8 / (1/16 : ℝ)) > (2 : ℝ)^(d/2 : ℝ) := by
  -- Algebraic PAC bound gives polynomial sample complexity
  -- But SVP over ℤ-lattices of rank d requires 2^{Ω(d)} time
  -- The gap between polynomial samples and exponential time = security
  sorry  -- REPLACE WITH FULL PROOF

/-- Bridge: connects module VC dimension to lattice covering radius.
    The VC dimension of a lattice module equals the covering dimension
    of the corresponding lattice, establishing a precise correspondence
    between learning complexity and geometric complexity. -/
theorem vc_dimension_equals_lattice_covering_dimension
    {M : Type*} [AddCommGroup M] [Module ℤ M] [Module.Finite ℤ M]
    {X : Type*} [Fintype X] [MetricSpace X]
    (H : AlgebraicHypothesisClass ℤ M X)
    (L : Submodule ℤ M) (h_L_rank : L.rank = moduleVCDimension H) :
    ∃ (ρ : ℝ), ρ = L.coveringRadius ∧
      ∀ (ε : ℝ), ε > 0 →
        ∃ (n : ℕ), n = Nat.ceil (8 * L.rank * Real.log (1/(ε/ρ)) / ε^2) := by
  -- The covering radius of the lattice equals the "resolution" of H
  -- This gives sample complexity in terms of lattice geometry
  sorry  -- REPLACE WITH FULL PROOF
```

---

### Proof Strategy Summary

**For `algebraic_dimension_bounds_vc`** (THE KEY THEOREM):
1. **Lemma: generator_collision**: If M has d generators and A ⊆ X has |A| = d+1, then for any S-valued pattern f : A → S in the image of H.embed, the map f ↦ (preimage in M) has fibers of size ≥ |S|^(d+1-d) by pigeonhole on generators.
2. **Lemma: shattering_requires_independence**: Shattering A requires that the restriction map M → (A → S) is surjective, which forces rank ≥ |A|.
3. **Main proof**: By `by_contra`, assume VCdim(H) > d. Then ∃ A with |A| = d+1 that is shattered. By `shattering_requires_independence`, the restriction map M → (A → S) is surjective, requiring ≥ d+1 generators. Contradiction with d generators.

**For `spectral_rademacher_decomposition`** (THE DEEPEST THEOREM):
1. **Lemma: rademacher_subadditive_exact**: If 0 → M₁ → M₂ → M₃ → 0 is exact, then R̂(M₂) ≤ R̂(M₁) + R̂(M₃).
2. **Lemma: krull_filtration_rademacher**: By induction on Krull dimension, decompose M along the prime filtration 0 = M₀ ⊂ M₁ ⊂ ... ⊂ Mₖ = M where Mᵢ₊₁/Mᵢ ≅ S/pᵢ.
3. **Main proof**: Combine (1) and (2) to get R̂(M) ≤ Σ R̂(S/pᵢ), then convert to tropical integral via the observation that min ≤ sum and the minimum is achieved at the "dominant" prime.

**For `idempotent_compression_bound`** (THE SURPRISE THEOREM):
1. **Lemma: idempotent_pattern_collapse**: In an idempotent semiring, x + x = x, so each generator can produce at most 2 distinct pattern values (0 or the generator itself).
2. **Lemma: exponential_pattern_bound**: With d generators, the number of distinct patterns is ≤ 2^d.
3. **Main proof**: Over ℝ, dim_ℝ(M ⊗ ℝ) ≥ 2^d (each pattern gives a distinct direction), so d ≤ log₂(dim_ℝ(M ⊗ ℝ)).

---

### Revolutionary Significance

This work opens **three new fields** simultaneously:

1. **Algebraic Statistical Learning Theory**: VC dimension, Rademacher complexity, and PAC bounds over arbitrary semirings — not just ℝ. This subsumes classical learning theory (S = ℝ), tropical learning theory (S = 𝕋), and boolean learning theory (S = 𝔹).

2. **Spectral Learning Complexity**: The decomposition of learning complexity over Spec(S) creates a precise analogy with spectral methods in representation theory. Each "irreducible representation" of S (i.e., each prime ideal) contributes independently to the learning complexity, exactly as characters contribute to representation dimensions.

3. **Post-Quantum Security from Algebraic Dimension**: The connection between algebraic PAC bounds and lattice hardness creates a new paradigm for proving security reductions: *learning efficiency over algebraic structures implies computational hardness of the corresponding lattice problems*.

---

### Required: FUTURE_DIRECTIONS.md

After completing the formalization, produce a structured `FUTURE_DIRECTIONS.md` with 5 concrete breakthrough-level next steps:

1. **Tropical Information Theory**: Prove that tropical mutual information satisfies the data processing inequality, establishing a tropical analogue of Shannon's theorem. This would enable certified robustness for tropical neural networks.

2. **Quantum Module-Theoretic Learning**: Extend to quantum hypothesis classes (modules over C*-algebras), connecting algebraic VC dimension to quantum PAC learning and quantum supremacy experiments.

3. **Homotopy-Theoretic Rademacher**: Use ∞-category theory to define Rademacher complexity for persistent hypothesis classes (over the simplex category), connecting stability of persistence diagrams to learning stability.

4. **Post-Quantum Reduction Completeness**: Prove that every polynomial-time learning algorithm over ℤ-modules gives a polynomial-time SVP algorithm, establishing the *learning-lattice equivalence* as a post-quantum security foundation.

5. **Algebraic Neural Architecture Search**: Use algebraic dimension to bound the expressive power of neural network architectures, giving certified bounds on the number of parameters needed for given VC dimension over arbitrary semirings.

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

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


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
            Open the field of algebraic learning theory by proving that classical statistical learning theory (VC dimension, Rademacher complexity, PAC bounds) generalizes to arbitrary algebraic structures. Theorem 1 (Module-Theoretic VC Bound): For a Noetherian semiring S and finitely generated S-module M, the VC dimension of the hypothesis class H_M = {f : X → S | f ∈ M} is bounded by the minimal number of generators of M, recovering the classical vector space bound when S = ℝ. Theorem 2 (Spectral Rademacher Decomposition): For a coherent commutative semiring S and algebraic hypothesis class H, the empirical Rademacher complexity R̂_n(H) decomposes as a tropical integral over Spec(S): R̂_n(H) = ⊕_{p ∈ Spec(S)} R̂_n(H_p) ⊗ μ(p), where H_p is the fiber at prime p and μ is the spectral valuation. Theorem 3 (Algebraic PAC Bound): For (ε,δ)-PAC learning over S with algebraic dimension d_S = min generators of M, the sample complexity satisfies n(ε,δ) ≤ C · d_S · log(1/δ)/ε² for universal constant C, with strictly tighter bounds for idempotent semirings where d_S ≤ log₂(dim_ℝ(M⊗ℝ)). This creates the first bridge between the Algebra domain (4487 declarations, 15 shared structures) and MachineLearning domain (760 declarations), which currently have no cross-domain bridge despite sharing category, field, functor, group, lattice, module, monoid, norm, ring, semiring, and tropical structures.

            ### Precise Mathematical Framing
            Classical PAC learning theory rests on the field structure of ℝ: VC dimension bounds rely on linear algebra over ℝ, Rademacher complexity uses ℝ-valued expectations, and PAC sample complexity depends on ℝ-valued loss. We show these results are NOT inherently field-dependent—they generalize to modules over arbitrary Noetherian semirings. The key insight is that prime spectra of semirings play the role of 'feature spaces' for learning, and spectral integration (tropical measure theory) replaces classical integration. Specifically: (1) The generator count of an S-module M bounds hypothesis capacity because S-linear combinations of generators produce all hypotheses, and the minimal generator count controls the shattering dimension. (2) Rademacher complexity decomposes spectrally because prime ideals separate the 'directions' in which hypotheses can vary, and the tropical integral over Spec(S) captures the supremum of correlation with noise. (3) PAC bounds tighten for idempotent semirings because max-plus arithmetic collapses the hypothesis space: idempotent addition (a ⊕ b = max(a,b)) means hypotheses are partially ordered, reducing effective capacity.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `agrees_on_generated_algebra_of_agrees_on_generators` : theorem agrees_on_generated_algebra_of_agrees_on_generators
     (file: MachineLearning/TropicalKME.lean)
  2. `beta_lifting_dimension_bound` : theorem beta_lifting_dimension_bound (d L : ℕ) (_hd : 1 ≤ d) :
     (file: MachineLearning/Neural/NeuralCompilationTeams.lean)
  3. `log_regret_bound` : theorem log_regret_bound (actual optimal : ℕ → ℝ)
     (file: MachineLearning/SelfImproving/LoopFoundations.lean)
  4. `bell_ineq_classical_bound_det` : theorem bell_ineq_classical_bound_det (a₀ a₁ b₀ b₁ : ℝ)
     (file: MachineLearning/ShefferFunction/PhotonEpistemicBridge.lean)
  5. `idempotent_spectral_tropical_bridge` : theorem idempotent_spectral_tropical_bridge {t : ℝ}
     (file: Tropical/SpectralIdempotentBridge.lean)

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



Recent successful concepts: Berggren Lattice Cryptography: Hyperbolic SVP Hardness, Factoring Reduction, and Post-Quantum Key Exchange via Pythagorean Geometry, Tropical Arithmetic Geometry: Cuspidal Factorization, Max-Plus Valuation Superadditivity, and Prime Decomposition Recovery on the Berggren Tree, Tropical Certified Robustness: Max-Plus Spectral Composition and Layerwise Verification Bounds for Deep Networks


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: MachineLearning
Research mode: formalize
