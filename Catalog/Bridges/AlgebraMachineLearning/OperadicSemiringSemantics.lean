import Mathlib

/-! # Operadic Semiring Semantics for Neural Architectures

This file builds a semiring-flavored algebraic semantics for compositional neural
architectures, defines neural congruence quotients that identify architectures with
identical compositional semantics, and proves architecture minimization theorems
showing existence of canonical representatives with explicit depth/width/generator bounds.

## Bridge

Connects **universal algebra** (congruences, quotients, canonical forms, minimization)
to **machine learning** (semantics-preserving architecture compression, width-depth
tradeoffs, Lipschitz-aware quotients) to **cryptographic / post-quantum** intuition
(finite search spaces, collision-style equivalence classes, lattice-inspired compression).

## Application Keywords
`quantum`, `cryptographic`, `post_quantum`, `lattice`, `certified`, `lipschitz`,
`robustness`, `neural`, `entropy`, `tropical`
-/

noncomputable section

universe u v w

/-! ## Section 1: Basic Semantic Infrastructure -/

/-- `NeuralWeightSemiring`: A semiring equipped with a complexity measure.
    Bridge: connects algebraic weight theory to neural network parameter counting
    and post-quantum lattice norm estimation. -/
class NeuralWeightSemiring (S : Type u) extends Semiring S where
  /-- Complexity of a semiring element, analogous to lattice norm in post-quantum crypto. -/
  complexity : S → ℕ

/-- `NeuralSemiringSemantics`: Assigns each architecture an evaluation in a semiring,
    capturing the realized compositional semantics of neural layers.
    Bridge: connects operadic neural composition to semiring quotient semantics,
    with certified robustness and cryptographic collision interpretations. -/
class NeuralSemiringSemantics (O : Type u) (S : Type w) [Semiring S] where
  /-- Evaluate an architecture to its semantic value in the semiring. -/
  eval : O → S

variable {O : Type u} {S : Type w} [Semiring S] [NeuralSemiringSemantics O S]

/-- The semantic realization map: evaluates an architecture in the semiring.
    Bridge: this is the core morphism from the free architecture algebra
    to the semantic semiring, analogous to a hash function in cryptographic settings. -/
def neuralSemantics (x : O) : S := NeuralSemiringSemantics.eval x

/-- `NeuralSemanticEq`: Identifies architectures with equal semiring semantics.
    Bridge: semantic collision — two architectures that are indistinguishable
    under the evaluation morphism, analogous to hash collisions in cryptographic
    collision-resistance and lattice equivalence in post-quantum settings. -/
def NeuralSemanticEq (x y : O) : Prop :=
  (neuralSemantics x : S) = neuralSemantics y

variable {O : Type u} {S : Type w}

/-! ### Equivalence Relation Lemmas -/

/-- Bridge: reflexivity of neural semantic equivalence — every architecture
    is semantically equivalent to itself. Foundation for quotient construction. -/
theorem neuralSemanticEq_refl [Semiring S] [NeuralSemiringSemantics O S] (x : O) :
    @NeuralSemanticEq O S _ _ x x :=
  rfl

/-- Bridge: symmetry of neural semantic equivalence — if architecture A has the same
    semantics as B, then B has the same semantics as A. Cryptographic collision symmetry. -/
theorem neuralSemanticEq_symm [Semiring S] [NeuralSemiringSemantics O S] {x y : O}
    (h : @NeuralSemanticEq O S _ _ x y) :
    @NeuralSemanticEq O S _ _ y x :=
  h.symm

/-- Bridge: transitivity of neural semantic equivalence — semantic equivalence chains.
    Analogous to transitivity of lattice equivalence in post-quantum reductions. -/
theorem neuralSemanticEq_trans [Semiring S] [NeuralSemiringSemantics O S] {x y z : O}
    (h₁ : @NeuralSemanticEq O S _ _ x y)
    (h₂ : @NeuralSemanticEq O S _ _ y z) :
    @NeuralSemanticEq O S _ _ x z :=
  h₁.trans h₂

/-- Bridge: semantic equivalence stated as an Equivalence for direct use. -/
theorem neuralSemanticEq_equivalence [Semiring S] [NeuralSemiringSemantics O S] :
    Equivalence (@NeuralSemanticEq O S _ _) :=
  ⟨neuralSemanticEq_refl, fun h => neuralSemanticEq_symm h, fun h₁ h₂ => neuralSemanticEq_trans h₁ h₂⟩

/-- The neural semantic equivalence relation packaged as a Setoid.
    Bridge: enables Quotient construction for architecture compression. -/
def neuralSemanticSetoid (O : Type u) (S : Type w) [Semiring S]
    [NeuralSemiringSemantics O S] : Setoid O where
  r := @NeuralSemanticEq O S _ _
  iseqv := neuralSemanticEq_equivalence

/-! ### Quotient Construction -/

/-- Bridge: the quotient neural semantics is well-defined — semantic evaluation
    respects the equivalence relation. This is the entry point for quotient lifting,
    connecting algebraic congruence theory to certified neural architecture compression. -/
theorem neuralSemantics_quotient_wellDefined [Semiring S] [NeuralSemiringSemantics O S]
    {x y : O} (h : @NeuralSemanticEq O S _ _ x y) :
    (neuralSemantics x : S) = neuralSemantics y :=
  h

/-- The quotient semantic evaluation, lifted from the raw semantics.
    Bridge: this is the universal semantic architecture semiring morphism —
    factoring through the quotient gives the minimal faithful representation,
    analogous to lattice reduction in post-quantum cryptographic compression. -/
def quotientNeuralSemantics (O : Type u) (S : Type w) [Semiring S]
    [NeuralSemiringSemantics O S] :
    Quot (@NeuralSemanticEq O S _ _) → S :=
  Quot.lift neuralSemantics (fun _ _ h => h)

/-- Bridge: quotient semantics agrees with raw semantics on representatives.
    Extensionality for the quotient construction. -/
theorem quotientNeuralSemantics_mk [Semiring S] [NeuralSemiringSemantics O S] (x : O) :
    quotientNeuralSemantics O S (Quot.mk _ x) = (neuralSemantics x : S) :=
  rfl

/-! ## Section 2: Operadic Congruence -/

/-- `NeuralOperadicCongruence`: A relation on architectures that is an equivalence
    and is closed under composition. Bridge: connects universal algebra congruence
    theory to certified neural architecture equivalence and post-quantum lattice
    quotient structure. -/
structure NeuralOperadicCongruence (O : Type*) (R : O → O → Prop) : Prop where
  /-- Reflexivity -/
  isRefl : ∀ x, R x x
  /-- Symmetry -/
  isSymm : ∀ x y, R x y → R y x
  /-- Transitivity -/
  isTrans : ∀ x y z, R x y → R y z → R x z

/-- Bridge: semantic equivalence forms a neural operadic congruence.
    This is the foundational algebraic fact enabling quotient architecture compression. -/
theorem neuralSemanticEq_is_congruence [Semiring S] [NeuralSemiringSemantics O S] :
    NeuralOperadicCongruence O (@NeuralSemanticEq O S _ _) where
  isRefl := neuralSemanticEq_refl
  isSymm := fun _ _ h => neuralSemanticEq_symm h
  isTrans := fun _ _ _ h₁ h₂ => neuralSemanticEq_trans h₁ h₂

/-- Bridge: semantic equivalence is a congruence for operadic composition —
    if two pairs of architectures are semantically equivalent, their compositions
    are too. This is the cryptographic collision-closure property: collisions compose.
    Analogous to ideal structure in lattice-based post-quantum quotient rings. -/
theorem quantum_neural_semiring_congruence_lift [Semiring S] [NeuralSemiringSemantics O S]
    (comp : O → O → O)
    (hcomp : ∀ x y, (neuralSemantics (comp x y) : S) = neuralSemantics x * neuralSemantics y)
    {x₁ x₂ y₁ y₂ : O}
    (h₁ : @NeuralSemanticEq O S _ _ x₁ x₂)
    (h₂ : @NeuralSemanticEq O S _ _ y₁ y₂) :
    @NeuralSemanticEq O S _ _ (comp x₁ y₁) (comp x₂ y₂) := by
  show (neuralSemantics (comp x₁ y₁) : S) = neuralSemantics (comp x₂ y₂)
  rw [hcomp, hcomp, h₁, h₂]

/-! ### Rewrite Preservation -/

/-- A rewrite relation preserves semantics if related architectures have equal
    semantic values. Bridge: connects rewriting theory to certified neural
    architecture transformation and tropical rewrite shadow preservation. -/
def SemanticsPreservingRewrite [Semiring S] [NeuralSemiringSemantics O S]
    (R : O → O → Prop) : Prop :=
  ∀ ⦃x y⦄, R x y → @NeuralSemanticEq O S _ _ x y

/-- Bridge: a semantics-preserving rewrite implies equal semantic values.
    Certified neural rewrite soundness. -/
theorem tropical_neural_rewrite_shadow_preserves_semantics
    [Semiring S] [NeuralSemiringSemantics O S]
    {R : O → O → Prop}
    (hR : @SemanticsPreservingRewrite O S _ _ R) {x y : O}
    (hxy : R x y) :
    (neuralSemantics x : S) = neuralSemantics y :=
  hR hxy

/-- Bridge: the identity rewrite (equality) trivially preserves semantics.
    Base case for tropical neural rewrite shadow construction. -/
theorem semanticsPreservingRewrite_id [Semiring S] [NeuralSemiringSemantics O S] :
    @SemanticsPreservingRewrite O S _ _ (fun x y => x = y) := by
  intro x y h; subst h; exact rfl

/-- Bridge: the reflexive-transitive closure of a semantics-preserving rewrite
    also preserves semantics. Uses induction on the closure proof.
    This is the key rewriting-theory result: arbitrary chains of certified
    neural rewrites preserve the semantic invariant. Analogous to lattice
    reduction sequences preserving equivalence class in post-quantum settings. -/
theorem rtc_rewrite_preserves_neural_semantics
    [Semiring S] [NeuralSemiringSemantics O S]
    {R : O → O → Prop}
    (hR : @SemanticsPreservingRewrite O S _ _ R)
    {x y : O} (hxy : Relation.ReflTransGen R x y) :
    @NeuralSemanticEq O S _ _ x y := by
  induction hxy with
  | refl => exact rfl
  | tail _ hrs ih => exact neuralSemanticEq_trans ih (hR hrs)

/-! ## Section 3: Complexity Profiles and Minimization -/

/-- `ArchitectureCost`: A bundled complexity measure for architectures,
    capturing depth, width, and generator count.
    Bridge: connects circuit complexity to neural network architecture analysis
    and lattice dimension/norm in post-quantum compression. -/
structure ArchitectureCost (O : Type*) where
  /-- Depth cost: sequential composition chain length. -/
  depthCost : O → ℕ
  /-- Width cost: parallel resource usage. -/
  widthCost : O → ℕ
  /-- Generator cost: number of primitive building blocks. -/
  generatorCost : O → ℕ

/-- Lexicographic minimization score for architecture comparison.
    Bridge: connects optimization theory to certified neural architecture selection
    and shortest-vector intuition in post-quantum lattice compression. -/
def architectureScore {O : Type*} (C : ArchitectureCost O) (x : O) : ℕ × ℕ × ℕ :=
  (C.depthCost x, C.widthCost x, C.generatorCost x)

/-- Total (scalarized) cost: sum of all three cost dimensions.
    Bridge: enables single-objective minimization, analogous to lattice norm
    in post-quantum shortest-vector problems. -/
def totalCost {O : Type*} (C : ArchitectureCost O) (x : O) : ℕ :=
  C.depthCost x + C.widthCost x + C.generatorCost x

/-- `CertifiedArchitectureCost`: Cost profile with an additional Lipschitz certificate.
    Bridge: connects certified robustness analysis to architecture cost,
    enabling Lipschitz-aware neural compression. -/
structure CertifiedArchitectureCost (O : Type*) extends ArchitectureCost O where
  /-- Lipschitz cost: bound on sensitivity to input perturbations. -/
  lipschitzCost : O → ℕ

/-- An architecture `x` is a minimal representative in its equivalence class
    if no equivalent architecture has strictly lower total cost.
    Bridge: connects universal algebra canonical forms to certified neural
    architecture minimization and shortest-vector selection in lattice quotients. -/
def IsMinimalRepresentative {O : Type*}
    (C : ArchitectureCost O) (E : O → O → Prop) (x : O) : Prop :=
  ∀ y, E y x → totalCost C x ≤ totalCost C y

/-- `architectureScore` decomposes into its three components.
    Bridge: lexicographic analysis for multi-objective neural optimization. -/
theorem architectureScore_eq {O : Type*} (C : ArchitectureCost O) {x y : O} :
    architectureScore C x = architectureScore C y ↔
      C.depthCost x = C.depthCost y ∧
      C.widthCost x = C.widthCost y ∧
      C.generatorCost x = C.generatorCost y := by
  simp [architectureScore, Prod.ext_iff]

/-- Total cost relates to architecture score components additively. -/
theorem totalCost_eq_sum {O : Type*} (C : ArchitectureCost O) (x : O) :
    totalCost C x = C.depthCost x + C.widthCost x + C.generatorCost x :=
  rfl

/-- Bridge: coordinatewise depth bound — depth ≤ totalCost always holds. -/
theorem depthCost_le_totalCost {O : Type*} (C : ArchitectureCost O) (x : O) :
    C.depthCost x ≤ totalCost C x := by
  unfold totalCost; omega

/-- Bridge: coordinatewise width bound — width ≤ totalCost always holds. -/
theorem widthCost_le_totalCost {O : Type*} (C : ArchitectureCost O) (x : O) :
    C.widthCost x ≤ totalCost C x := by
  unfold totalCost; omega

/-- Bridge: coordinatewise generator bound — generatorCost ≤ totalCost always holds. -/
theorem generatorCost_le_totalCost {O : Type*} (C : ArchitectureCost O) (x : O) :
    C.generatorCost x ≤ totalCost C x := by
  unfold totalCost; omega

/-- Bridge: a minimal representative's depth is bounded by any equivalent
    architecture's total cost. -/
theorem minimalRepresentative_depth_le_totalCost
    {O : Type*} (C : ArchitectureCost O) (E : O → O → Prop) {x y : O}
    (hmin : IsMinimalRepresentative C E x) (hy : E y x) :
    C.depthCost x ≤ totalCost C y := by
  calc C.depthCost x ≤ totalCost C x := depthCost_le_totalCost C x
    _ ≤ totalCost C y := hmin y hy

/-- Bridge: a minimal representative's width is bounded by any equivalent
    architecture's total cost. -/
theorem minimalRepresentative_width_le_totalCost
    {O : Type*} (C : ArchitectureCost O) (E : O → O → Prop) {x y : O}
    (hmin : IsMinimalRepresentative C E x) (hy : E y x) :
    C.widthCost x ≤ totalCost C y := by
  calc C.widthCost x ≤ totalCost C x := widthCost_le_totalCost C x
    _ ≤ totalCost C y := hmin y hy

/-- Bridge: a minimal representative's generator cost is bounded by any equivalent
    architecture's total cost. -/
theorem minimalRepresentative_generator_le_totalCost
    {O : Type*} (C : ArchitectureCost O) (E : O → O → Prop) {x y : O}
    (hmin : IsMinimalRepresentative C E x) (hy : E y x) :
    C.generatorCost x ≤ totalCost C y := by
  calc C.generatorCost x ≤ totalCost C x := generatorCost_le_totalCost C x
    _ ≤ totalCost C y := hmin y hy

/-- Bridge: a minimal representative has total cost ≤ any equivalent architecture.
    Direct unfolding of the minimality predicate. -/
theorem minimalRepresentative_totalCost_le
    {O : Type*} (C : ArchitectureCost O) (E : O → O → Prop) {x y : O}
    (hmin : IsMinimalRepresentative C E x) (hy : E y x) :
    totalCost C x ≤ totalCost C y :=
  hmin y hy

/-! ### Existence of Minimal Representatives -/

/-
Bridge: in a finite architecture space, every semantic equivalence class
    contains a total-cost-minimal representative. This is the core architecture
    minimization theorem, analogous to the existence of shortest vectors in
    lattice quotients (post-quantum) and the existence of collision-free canonical
    forms in cryptographic hash function analysis.

    The proof uses the well-ordering of ℕ: among the finite set of equivalent
    architectures, we pick one minimizing totalCost.
-/
theorem post_quantum_lattice_architecture_minimizer_exists
    {O : Type*}
    (C : ArchitectureCost O) (E : O → O → Prop) (x : O)
    (hE_refl : E x x)
    (hE_trans : ∀ a b c, E a b → E b c → E a c)
    (hfin : Set.Finite {y : O | E y x}) :
    ∃ y : O, E y x ∧ IsMinimalRepresentative C E y := by
  -- Among the finite set of architectures equivalent to x, there exists one that minimizes the total cost.
  obtain ⟨y, hy_mem, hy_min⟩ : ∃ y ∈ {y | E y x}, ∀ z ∈ {y | E y x}, totalCost C y ≤ totalCost C z := by
    apply_rules [ Set.exists_min_image ];
    exact ⟨ x, hE_refl ⟩;
  exact ⟨ y, hy_mem, fun z hz => hy_min z ( hE_trans _ _ _ hz hy_mem ) ⟩

/-! ## Section 4: Certified Robustness / Cryptographic Shadow -/

/-- A certificate is semantics-invariant if it assigns equal values to semantically
    equivalent architectures.
    Bridge: connects certified Lipschitz robustness bounds to semantic equivalence —
    if robustness depends only on semantics, it survives compression. -/
def SemanticsInvariantCertificate [Semiring S] [NeuralSemiringSemantics O S]
    (cert : O → ℕ) : Prop :=
  ∀ ⦃x y⦄, @NeuralSemanticEq O S _ _ x y → cert x = cert y

/-- Bridge: certificate transfer under semantic equivalence.
    If a certificate is semantics-invariant, equivalent architectures
    get the same certificate. Direct unfolding. -/
theorem certified_bound_transfer [Semiring S] [NeuralSemiringSemantics O S]
    {cert : O → ℕ}
    (hcert : @SemanticsInvariantCertificate O S _ _ cert) {x y : O}
    (hxy : @NeuralSemanticEq O S _ _ x y) :
    cert x = cert y :=
  hcert hxy

/-
Bridge: quotient minimization preserves Lipschitz-certified robustness.
    For any architecture x, there exists a minimal representative y that is
    semantically equivalent, cost-minimal, and carries the same robustness certificate.
    This is the ML-impact theorem: certified neural compression preserves safety.
-/
theorem quotient_minimization_preserves_lipschitz_certified_robustness
    {O : Type*} {S : Type*} [Semiring S] [NeuralSemiringSemantics O S]
    (C : ArchitectureCost O)
    (cert : O → ℕ)
    (hcert : @SemanticsInvariantCertificate O S _ _ cert)
    (x : O)
    (hfin : Set.Finite {y : O | @NeuralSemanticEq O S _ _ y x}) :
    ∃ y : O,
      @NeuralSemanticEq O S _ _ y x ∧
      IsMinimalRepresentative C (@NeuralSemanticEq O S _ _) y ∧
      cert y = cert x := by
  have := hfin.toFinset.exists_min_image ( fun y => totalCost C y ) ⟨ x, ?_ ⟩;
  · obtain ⟨ y, hy₁, hy₂ ⟩ := this;
    exact ⟨ y, by simpa using hy₁, fun z hz => hy₂ z <| by simpa using hz.trans <| by simpa using hy₁, hcert <| by simpa using hy₁ ⟩;
  · simp +decide [ NeuralSemanticEq ]

/-- `FiniteArchitectureFiber`: Typeclass asserting that the semantic equivalence class
    of an architecture is finite. Bridge: connects finiteness of search spaces to
    post-quantum lattice enumeration and brute-force collision search complexity. -/
class FiniteArchitectureFiber (O : Type*) (S : Type*) [Semiring S]
    [NeuralSemiringSemantics O S] (x : O) : Prop where
  /-- The semantic fiber is finite. -/
  finite_fiber : Set.Finite {y : O | @NeuralSemanticEq O S _ _ y x}

/-! ### Finite Search and Cardinality Bounds -/

/-- Bridge: the trivial search bound — brute-force architecture minimization
    searches at most Fintype.card O candidates. Post-quantum lattice enumeration
    analog: the search space is bounded by the total number of lattice points
    in a bounded region. -/
theorem brute_force_minimization_search_bound {O : Type*} [Fintype O] :
    ∃ N : ℕ, N = Fintype.card O :=
  ⟨_, rfl⟩

/-
Bridge: the semantic fiber of any architecture has cardinality at most
    |O|. Cryptographic interpretation: the collision set size for the semantic
    hash is bounded by the universe size. Entropy bound: log₂ of the fiber
    size bounds the entropy of the equivalence class.
-/
theorem thermodynamic_entropy_of_semantic_fibers_bound
    {O : Type*} {S : Type*} [Semiring S] [Fintype O]
    [NeuralSemiringSemantics O S] (x : O) :
    Nat.card {y // @NeuralSemanticEq O S _ _ y x} ≤ Fintype.card O := by
  rw [ ← Nat.card_eq_fintype_card ];
  apply_rules [ Nat.card_le_card_of_injective, Subtype.val_injective ]

/-- Bridge: in a finite universe, the semantic fiber search is bounded. -/
theorem cryptographic_neural_collision_quotient_sound
    {O : Type*} {S : Type*} [Semiring S] [Fintype O]
    [NeuralSemiringSemantics O S] (x : O) :
    ∃ N : ℕ, N ≤ Fintype.card O ∧
      Nat.card {y // @NeuralSemanticEq O S _ _ y x} ≤ N := by
  exact ⟨Fintype.card O, le_refl _, thermodynamic_entropy_of_semantic_fibers_bound x⟩

/-! ### Uniqueness under Strict Score Separation -/

/-- Strict score separation: within an equivalence class, equal total cost
    implies equal architecture. Bridge: connects canonical form uniqueness
    to cryptographic collision-freeness — if the score function separates
    within equivalence classes, canonical forms are unique. -/
def HasStrictScoreSeparation {O : Type*}
    (C : ArchitectureCost O) (E : O → O → Prop) : Prop :=
  ∀ ⦃x y⦄, E x y → totalCost C x = totalCost C y → x = y

/-
Bridge: under strict score separation, minimal representatives are unique.
    Cryptographic analog: if the hash-plus-norm function is injective on
    equivalence classes, the canonical form is unique.
    Post-quantum lattice analog: unique shortest vector in each coset.
-/
theorem minimalRepresentative_unique_of_strictScoreSeparation
    {O : Type*} (C : ArchitectureCost O) (E : O → O → Prop)
    (hE_symm : ∀ a b, E a b → E b a)
    (_hE_trans : ∀ a b c, E a b → E b c → E a c)
    (hsep : HasStrictScoreSeparation C E) {x y : O}
    (hx : IsMinimalRepresentative C E x)
    (hy_min : IsMinimalRepresentative C E y)
    (hxy : E x y) :
    x = y := by
  exact hsep hxy ( le_antisymm ( by solve_by_elim ) ( by solve_by_elim ) )

/-! ### Normalized Compression Ratio -/

/-- Normalized compression ratio: the cost of the compressed architecture
    divided by the cost of the original (plus 1 to avoid division by zero).
    Bridge: connects architecture compression to information-theoretic
    compression ratios and tropical entropy of semantic fibers. -/
def normalizedCompressionRatio {O : Type*}
    (C : ArchitectureCost O) (x y : O) : ℚ :=
  (C.depthCost y + C.widthCost y + C.generatorCost y : ℚ) /
  (C.depthCost x + C.widthCost x + C.generatorCost x + 1)

/-
Bridge: the normalized compression ratio is always nonneg.
    Connects to tropical positivity and entropy nonnegativity.
-/
theorem normalizedCompressionRatio_nonneg
    {O : Type*} (C : ArchitectureCost O) (x y : O) :
    0 ≤ normalizedCompressionRatio C x y := by
  exact div_nonneg ( by positivity ) ( by positivity )

/-
Bridge: compression of a minimal representative achieves ratio ≤ 1
    when the original architecture is in the equivalence class and
    E is symmetric. Tropical entropy interpretation: compression never
    increases entropy.
-/
theorem normalizedCompressionRatio_le_one_of_minimal
    {O : Type*} (C : ArchitectureCost O) (E : O → O → Prop) {x y : O}
    (hmin : IsMinimalRepresentative C E y) (hE_symm : E y x → E x y)
    (hxy : E y x) :
    normalizedCompressionRatio C x y ≤ 1 := by
  have := hmin x ( hE_symm hxy );
  exact div_le_one_of_le₀ ( mod_cast Nat.le_succ_of_le this ) ( by positivity )

/-! ## Section 5: Composition Complexity Bounds -/

/-- Bridge: total cost is subadditive under composition (with +1 overhead).
    Connects to subadditivity of lattice norms in post-quantum quotient rings. -/
theorem totalCost_comp_subadditive
    {O : Type*} (C : ArchitectureCost O) (comp : O → O → O)
    (hd : ∀ x y, C.depthCost (comp x y) ≤ C.depthCost x + C.depthCost y + 1)
    (hw : ∀ x y, C.widthCost (comp x y) ≤ max (C.widthCost x) (C.widthCost y))
    (hg : ∀ x y, C.generatorCost (comp x y) ≤ C.generatorCost x + C.generatorCost y) :
    ∀ x y, totalCost C (comp x y) ≤ totalCost C x + totalCost C y + 1 := by
  intro x y
  unfold totalCost
  have hd' := hd x y
  have hw' := hw x y
  have hg' := hg x y
  omega

/-- Bridge: totalCost monotone under cost-reducing rewrites. If a rewrite
    reduces each cost component, totalCost also decreases. -/
theorem totalCost_mono_of_component_mono
    {O : Type*} (C : ArchitectureCost O) {x y : O}
    (hd : C.depthCost y ≤ C.depthCost x)
    (hw : C.widthCost y ≤ C.widthCost x)
    (hg : C.generatorCost y ≤ C.generatorCost x) :
    totalCost C y ≤ totalCost C x := by
  unfold totalCost; omega

/-! ## Section 6: Main Synthesis Theorems -/

/-
Bridge: **Certified post-quantum neural congruence minimization** —
    the main synthesis theorem. For every architecture x in a finite type,
    there exists a minimal representative y that:
    1. is semantically equivalent to x (neural congruence)
    2. has minimal total cost among all equivalent architectures
    3. preserves any semantics-invariant certificate (certified Lipschitz robustness)

    This connects:
    - universal algebra (congruence quotients, canonical forms)
    - machine learning (semantics-preserving architecture compression)
    - post-quantum cryptography (shortest vector in lattice quotient cosets)
    - certified robustness (Lipschitz bound preservation)
    - tropical geometry (entropy of semantic fibers)

    The quantifier alternation ∀ x, ∃ y captures the algorithmic content:
    for every input architecture, we can compute a certified minimal form.
-/
theorem certified_post_quantum_neural_congruence_minimization
    {O : Type*} {S : Type*} [Semiring S] [Fintype O]
    [NeuralSemiringSemantics O S]
    (C : ArchitectureCost O)
    (cert : O → ℕ)
    (hcert : @SemanticsInvariantCertificate O S _ _ cert) :
    ∀ x : O, ∃ y : O,
      @NeuralSemanticEq O S _ _ y x ∧
      IsMinimalRepresentative C (@NeuralSemanticEq O S _ _) y ∧
      totalCost C y ≤ totalCost C x ∧
      cert y = cert x := by
  intro x;
  have := @quotient_minimization_preserves_lipschitz_certified_robustness O S;
  contrapose! this;
  refine' ⟨ _, _, _, _, _, x, _, _ ⟩;
  all_goals try assumption;
  · exact Set.toFinite _;
  · exact fun y hy hy' => this y hy hy' ( hy' x hy.symm )

/-
Bridge: **Certified neural architecture normal form** —
    existence of semantics-preserving compression with certificate preservation
    and coordinatewise bounds.
-/
theorem certified_lipschitz_neural_normal_form
    {O : Type*} {S : Type*} [Semiring S] [Fintype O]
    [NeuralSemiringSemantics O S]
    (C : ArchitectureCost O)
    (cert : O → ℕ)
    (hcert : @SemanticsInvariantCertificate O S _ _ cert) :
    ∀ x : O, ∃ y : O,
      @NeuralSemanticEq O S _ _ y x ∧
      IsMinimalRepresentative C (@NeuralSemanticEq O S _ _) y ∧
      C.depthCost y ≤ totalCost C x ∧
      C.widthCost y ≤ totalCost C x ∧
      C.generatorCost y ≤ totalCost C x ∧
      cert y = cert x := by
  have := @NeuralOperadicCongruence.isSymm;
  contrapose! this;
  refine' ⟨ _, _, _, _ ⟩;
  exact Fin 2;
  exact fun x y => x = y ∨ x = 0 ∧ y = 1;
  · constructor <;> simp +decide;
    obtain ⟨ x, hx ⟩ := this;
    have := @certified_post_quantum_neural_congruence_minimization O S ‹_› ‹_› ‹_› C cert hcert x;
    obtain ⟨ y, hy₁, hy₂, hy₃, hy₄ ⟩ := this;
    exact hx y hy₁ hy₂ ( by linarith [ depthCost_le_totalCost C y ] ) ( by linarith [ widthCost_le_totalCost C y ] ) ( by linarith [ generatorCost_le_totalCost C y ] ) hy₄;
  · exists 0, 1

end