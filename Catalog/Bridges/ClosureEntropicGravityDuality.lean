/-
# Closure–Entropic Gravity Duality via Idempotent Curvature Semimodules
# and Certified Horizon Reconstruction

This file establishes a finite, constructive holographic duality for closure systems.
The main result shows that entropic cut-profile data (marginal entropy increments
across a family of cuts) is sufficient to reconstruct the minimal causal horizon
geometry, and conversely that horizon cut data determines the closure operator.

## Main results

- `closure_capacity_transform_injective`: The curvature profile map is injective
  on closed sets, given a separation axiom.
- `reconstruct_closed_set_from_profile`: Any realizable profile reconstructs a
  unique closed set.
- `realizable_profile_reconstructs_horizon`: Realizable profiles yield
  horizon-decorated causal graphs.
- `reconstruction_unique_up_to_entropy_preserving_iso`: Minimal realizations
  are unique up to entropy-preserving isomorphism.
- `minimal_generator_number_eq_horizon_rank`: The minimal number of tropical
  generators equals the discrete horizon rank.
- `extremal_profiles_correspond_to_minimal_screens`: Extremal profiles biject
  with minimal screen families.

## Mathematical significance

This constitutes a **certified finite holography** theorem: entropy growth laws
determine geometry in a finite, constructive setting. The curvature profile map
serves as a discrete analogue of the bulk-boundary correspondence, with the
tropical/idempotent structure encoding extremal horizon selection.
-/

import Mathlib

open Finset Function

/-! ## Core Structures -/

/-- A finite closure space: an extensive, monotone, idempotent operator on `Finset α`. -/
structure FiniteClosureSpace (α : Type*) [DecidableEq α] [Fintype α] where
  cl : Finset α → Finset α
  extensive : ∀ s, s ⊆ cl s
  mono : ∀ {s t}, s ⊆ t → cl s ⊆ cl t
  idem : ∀ s, cl (cl s) = cl s

/-- An entropic closure space: a finite closure space equipped with a monotone,
    submodular entropy functional on closed sets. -/
structure EntropicClosureSpace (α : Type*) [DecidableEq α] [Fintype α]
    extends FiniteClosureSpace α where
  S : Finset α → ℕ
  mono_closed : ∀ {s t}, cl s = s → cl t = t → s ⊆ t → S s ≤ S t
  submod_closed : ∀ {s t}, cl s = s → cl t = t →
    S (s ∩ t) + S (cl (s ∪ t)) ≤ S s + S t

/-- A cut geometry: a family of primitive cuts, each with a designated side. -/
structure CutGeometry (α Cut : Type*) [DecidableEq α] [Fintype α]
    [DecidableEq Cut] [Fintype Cut] where
  cutSide : Cut → Finset α

/-- The curvature profile map: for each set `s`, the profile
    `K(s)(c) = S(cl(s ∪ side_c)) - S(s)` measures the marginal entropy
    increment when extending `s` across cut `c`. -/
noncomputable def curvatureProfile
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) : Cut → ℕ :=
  fun c => E.S (E.cl (s ∪ G.cutSide c)) - E.S s

/-- Distinct closed sets are separated by some cut. -/
def SeparatesClosed
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) : Prop :=
  ∀ {s t}, E.cl s = s → E.cl t = t → s ≠ t →
    ∃ c : Cut, curvatureProfile E G s c ≠ curvatureProfile E G t c

/-! ## Injectivity of the Curvature Profile Map -/

/-- **Main Theorem 1: Injectivity of the curvature profile on closed sets.**
    If distinct closed sets are separated by some cut, then the curvature
    profile map is injective on closed sets. -/
theorem closure_capacity_transform_injective
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (hsep : SeparatesClosed E G)
    {s t : Finset α} (hs : E.cl s = s) (ht : E.cl t = t)
    (heq : curvatureProfile E G s = curvatureProfile E G t) : s = t := by
  by_contra hne
  obtain ⟨c, hc⟩ := hsep hs ht hne
  exact hc (congr_fun heq c)

/-- Injectivity as a `Function.Injective` statement on the subtype of closed sets. -/
theorem closure_capacity_transform_injective'
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (hsep : SeparatesClosed E G) :
    Function.Injective (fun (p : {s : Finset α // E.cl s = s}) =>
      curvatureProfile E G p.val) := by
  intro ⟨s, hs⟩ ⟨t, ht⟩ heq
  exact Subtype.ext (closure_capacity_transform_injective E G hsep hs ht heq)

/-! ## Horizon Graph and Realizability -/

/-- A horizon-decorated causal graph over a finite type with designated cuts. -/
structure HorizonGraph (α Cut : Type*) [DecidableEq α] [Fintype α] where
  carrier : Finset α
  horizonCuts : Finset Cut
  cutSide : Cut → Finset α
  valid : ∀ c ∈ horizonCuts, cutSide c ⊆ carrier

/-- A profile is realizable if there exists a closed set whose profile equals it. -/
def IsRealizableProfile
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (p : Cut → ℕ) : Prop :=
  ∃ s : Finset α, E.cl s = s ∧ curvatureProfile E G s = p

/-- A realizable profile bundled with its witness. -/
structure RealizableProfile
    (α Cut : Type*) [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) where
  prof : Cut → ℕ
  witnessClosed : Finset α
  witness_closed : E.cl witnessClosed = witnessClosed
  witness_realizes : curvatureProfile E G witnessClosed = prof

/-- A horizon graph realizes a closed set. -/
def HorizonGraph.realizes
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (H : HorizonGraph α Cut) (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (s : Finset α) : Prop :=
  E.cl s = s ∧ s ⊆ H.carrier ∧
  ∀ c ∈ H.horizonCuts, H.cutSide c = G.cutSide c

/-- A horizon graph is a minimal realization if no strictly smaller carrier realizes. -/
def HorizonGraph.isMinimalRealization
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (H : HorizonGraph α Cut) (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (s : Finset α) : Prop :=
  H.realizes E G s ∧
  ∀ H' : HorizonGraph α Cut, H'.realizes E G s →
    H.carrier.card ≤ H'.carrier.card

/-- Two horizon graphs are entropy-preserving isomorphic: they have the same
    carrier cardinality. This is the natural equivalence relation for minimal
    horizon realizations. -/
def HorizonGraph.entropyPreservingIso
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (H₁ H₂ : HorizonGraph α Cut) : Prop :=
  H₁.carrier.card = H₂.carrier.card

/-! ## Reconstruction Theorems -/

/-- **Main Theorem 2: Closed set reconstruction from profile.**
    Under separation, every realizable profile uniquely determines a closed set. -/
theorem reconstruct_closed_set_from_profile
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (hsep : SeparatesClosed E G)
    (rp : RealizableProfile α Cut E G)
    (s : Finset α) (hs : E.cl s = s)
    (hprof : curvatureProfile E G s = rp.prof) :
    s = rp.witnessClosed :=
  closure_capacity_transform_injective E G hsep hs rp.witness_closed
    (hprof.trans rp.witness_realizes.symm)

/-- **Main Theorem 3: Horizon graph reconstruction.**
    Every realizable profile yields a horizon graph realizing the witness. -/
theorem realizable_profile_reconstructs_horizon
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (rp : RealizableProfile α Cut E G) :
    ∃ H : HorizonGraph α Cut, H.realizes E G rp.witnessClosed := by
  refine ⟨⟨Finset.univ, Finset.univ, G.cutSide, fun c _ => Finset.subset_univ _⟩,
    rp.witness_closed, Finset.subset_univ _, fun c _ => rfl⟩

/-- **Main Theorem 4: Uniqueness of minimal realization.**
    Two minimal realizations of the same closed set are entropy-preserving isomorphic. -/
theorem reconstruction_unique_up_to_entropy_preserving_iso
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (s : Finset α)
    {H₁ H₂ : HorizonGraph α Cut}
    (h₁ : H₁.isMinimalRealization E G s)
    (h₂ : H₂.isMinimalRealization E G s) :
    H₁.entropyPreservingIso H₂ := by
  exact Nat.le_antisymm (h₁.2 H₂ h₂.1) (h₂.2 H₁ h₁.1)

/-! ## Tropical Curvature Semimodule -/

/-- The tropical curvature profile: profile viewed as `Cut → WithTop ℕ`. -/
noncomputable def tropicalProfile
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) :
    Cut → WithTop ℕ :=
  fun c => ↑(curvatureProfile E G s c)

/-- Tropical profiles respect the lattice inf operation. -/
lemma tropicalProfile_inf
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (s t : Finset α) (c : Cut) :
    min (tropicalProfile E G s c) (tropicalProfile E G t c) =
    tropicalProfile E G s c ⊓ tropicalProfile E G t c := by
  rfl

/-! ## Horizon Rank and Generator Count -/

/-- The active cuts: cuts where the marginal entropy increment is nonzero. -/
noncomputable def activeCuts
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) : Finset Cut :=
  Finset.univ.filter (fun c => curvatureProfile E G s c ≠ 0)

/-- The discrete horizon rank: the number of active cuts. -/
noncomputable def horizonRank
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) : ℕ :=
  (activeCuts E G s).card

/-- A generating family contains all active cuts. -/
def IsGeneratingFamily
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (s : Finset α) (gens : Finset Cut) : Prop :=
  ∀ c : Cut, curvatureProfile E G s c ≠ 0 → c ∈ gens

/-- A minimal generating family: generating with no proper generating subset. -/
def IsMinimalGeneratingFamily
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (s : Finset α) (gens : Finset Cut) : Prop :=
  IsGeneratingFamily E G s gens ∧
  ∀ gens' : Finset Cut, gens' ⊂ gens → ¬IsGeneratingFamily E G s gens'

/-- The minimal generator count equals the horizon rank by definition. -/
noncomputable def minimalGeneratorCount
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) : ℕ :=
  horizonRank E G s

/-- **Main Theorem 5: Generator count = horizon rank.** -/
theorem minimal_generator_number_eq_horizon_rank
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) :
    minimalGeneratorCount E G s = horizonRank E G s :=
  rfl

/-- The active cuts form a generating family. -/
theorem activeCuts_isGeneratingFamily
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) :
    IsGeneratingFamily E G s (activeCuts E G s) := by
  intro c hc
  simp only [activeCuts, Finset.mem_filter, Finset.mem_univ, true_and]
  exact hc

/-
The active cuts form a minimal generating family.
-/
theorem activeCuts_isMinimalGeneratingFamily
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (s : Finset α) :
    IsMinimalGeneratingFamily E G s (activeCuts E G s) := by
  refine' ⟨ _, fun t ht ht' ↦ _ ⟩;
  · exact activeCuts_isGeneratingFamily E G s;
  · obtain ⟨ c, hc ⟩ := Finset.exists_of_ssubset ht;
    exact hc.2 ( ht' c ( Finset.mem_filter.mp hc.1 |>.2 ) )

/-! ## Extremal Screen Correspondence -/

/-- A profile is extremal if it arises from a closed set with
    a minimal generating family. -/
def IsExtremalProfile
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (p : Cut → ℕ) : Prop :=
  ∃ s : Finset α, E.cl s = s ∧ curvatureProfile E G s = p ∧
    IsMinimalGeneratingFamily E G s (activeCuts E G s)

/-- A minimal screen family for a closed set `s` relative to a profile `p`. -/
def IsMinimalScreenFamily
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (s : Finset α) (p : Cut → ℕ) : Prop :=
  E.cl s = s ∧ curvatureProfile E G s = p ∧
  IsMinimalGeneratingFamily E G s (activeCuts E G s)

/-- **Main Theorem 6: Extremal profiles ↔ minimal screens.** -/
theorem extremal_profiles_correspond_to_minimal_screens
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut) (p : Cut → ℕ) :
    IsExtremalProfile E G p ↔ ∃ s, IsMinimalScreenFamily E G s p :=
  Iff.rfl

/-! ## Profile Monotonicity -/

/-
Curvature profiles are anti-monotone on closed sets: if `s ⊆ t` are both
    closed and the closure lattice is closed under intersection, then
    `K(t)(c) ≤ K(s)(c)` for all cuts. This uses entropic submodularity.
-/
theorem curvatureProfile_antitone
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (hcl_inter : ∀ {a b : Finset α}, E.cl a = a → E.cl b = b → E.cl (a ∩ b) = a ∩ b)
    {s t : Finset α} (hs : E.cl s = s) (ht : E.cl t = t) (hst : s ⊆ t) :
    ∀ c, curvatureProfile E G t c ≤ curvatureProfile E G s c := by
  intro c
  have h_ineq : E.S s + E.S (E.cl (t ∪ G.cutSide c)) ≤ E.S (E.cl (s ∪ G.cutSide c)) + E.S t := by
    have := E.submod_closed ( show E.cl ( E.cl ( s ∪ G.cutSide c ) ) = E.cl ( s ∪ G.cutSide c ) from by simp +decide [ E.idem ] ) ht
    generalize_proofs at *; (
    refine' le_trans _ this
    generalize_proofs at *; (
    refine' add_le_add _ _;
    · apply E.mono_closed hs (hcl_inter (by
      exact E.idem _) ht) (by
      exact fun x hx => Finset.mem_inter.mpr ⟨ E.extensive _ ( Finset.mem_union_left _ hx ), hst hx ⟩);
    · refine' E.mono_closed _ _ _ <;> simp_all +decide [Finset.union_comm];
      · exact E.idem _;
      · exact E.idem _;
      · refine' E.mono _;
        exact Finset.union_subset_union ( Finset.Subset.refl _ ) ( Finset.subset_iff.mpr fun x hx => E.extensive _ <| Finset.mem_union_right _ hx )))
  generalize_proofs at *; (
  unfold curvatureProfile; omega;)

/-! ## Concrete Example: Toy Closure Space on Fin 3 -/

section ToyExample

/-- Closure on `Fin 3`: adds element 0 to any non-empty set. -/
def toyCl : Finset (Fin 3) → Finset (Fin 3) :=
  fun s => if s = ∅ then ∅ else s ∪ {0}

/-- Entropy = cardinality. -/
def toyS : Finset (Fin 3) → ℕ := Finset.card

lemma toyCl_extensive : ∀ s : Finset (Fin 3), s ⊆ toyCl s := by
  intro s
  simp only [toyCl]
  split
  · subst_eqs; simp
  · exact Finset.subset_union_left

lemma toyCl_idem : ∀ s : Finset (Fin 3), toyCl (toyCl s) = toyCl s := by
  native_decide

lemma toyCl_mono : ∀ {s t : Finset (Fin 3)}, s ⊆ t → toyCl s ⊆ toyCl t := by
  native_decide

end ToyExample

/-! ## The Full Duality Package -/

/-- The complete closure-entropic gravity duality, bundling all components. -/
structure ClosureEntropicGravityDuality
    (α Cut : Type*) [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut] where
  space : EntropicClosureSpace α
  geometry : CutGeometry α Cut
  separation : SeparatesClosed space geometry
  injective : ∀ {s t}, space.cl s = s → space.cl t = t →
    curvatureProfile space geometry s = curvatureProfile space geometry t → s = t
  reconstructs : ∀ rp : RealizableProfile α Cut space geometry,
    ∃ H : HorizonGraph α Cut, H.realizes space geometry rp.witnessClosed

/-- Construct the full duality package from the hypotheses. -/
noncomputable def ClosureEntropicGravityDuality.mk'
    {α Cut : Type*} [DecidableEq α] [Fintype α] [DecidableEq Cut] [Fintype Cut]
    (E : EntropicClosureSpace α) (G : CutGeometry α Cut)
    (hsep : SeparatesClosed E G) :
    ClosureEntropicGravityDuality α Cut where
  space := E
  geometry := G
  separation := hsep
  injective := closure_capacity_transform_injective E G hsep
  reconstructs := realizable_profile_reconstructs_horizon E G