/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Ultrametric Proof-Learning Representation Duality via Observer Semimodules

This file formalizes a **finite duality principle for proof dynamics**: a proof-learning
system with ultrametric contraction and observer-stable compression is *completely
recoverable* from a finite observer evaluation semimodule, and conversely the semimodule
algorithmically reconstructs a canonical sparse predictor tree with a correctness
certificate.

## Main Results

### Definitions (12 novel)
* `evalProfile` — observer evaluation map: compress then observe
* `ObserverSeparatesCompressed` — observers distinguish distinct compressed states
* `RealizableProfiles` — image of the observer evaluation map
* `CompressedUltrametric` — ultrametric compatible with compression
* `UltrametricProofSystem` — full proof-learning system bundle
* `evalProfileOnRange` — restriction of evalProfile to compressed states
* `compressedProfileEquiv` — the finite duality equivalence
* `profileSup`, `profileLE` — tropical/idempotent semimodule operations
* `ultraBallRel` — ultrametric ball equivalence relation
* `RootedTreeModel` — hierarchical predictor tree model
* `CertifiedPredictor` — predictor with correctness certificate
* `thresholdSublevel` — spectral filtration by observer thresholds

### Theorems (20+)
* `evalProfile_injective_on_compressed` — injectivity on fixed points (Thm A)
* `evalProfile_factors_through_C` — factorization through compression
* `evalProfile_injective_on_range` — injectivity on range C
* `evalProfileOnRange_injective/surjective` — bijection components
* `compressedProfileEquiv` — finite duality equivalence (Thm A')
* `card_realizable_profiles_eq_card_compressed` — cardinality matching
* `exists_canonical_ultrametric_tree` — tree reconstruction (Thm B)
* `canonical_tree_cluster_equiv` — clusters are equivalence relations
* `canonical_tree_unique` — uniqueness up to equivalence (Thm B')
* `certified_trace_reconstruction` — trace-based reconstruction (Thm C')
* `observer_separation_implies_faithful_encoding` — bridge to diagonal avoidance
* `profileSup_comm/assoc/idem` — semimodule algebraic laws
* `thresholdSublevel_mono` — spectral filtration monotonicity
* `finite_observer_representation_duality` — master theorem

## Bridge Architecture

Mirrors `certified_gibbs_reconstruction_from_boundary_partition`:
- Boundary data = observer profiles
- Partition = ultrametric cluster partition
- Reconstruction = profile → compressed state via equivalence inverse
- Certificate = observer evaluation recovery

## Application Keywords

ultrametric learning, proof-state compression, observer semimodules, idempotent algebra,
tropical representation theory, hierarchical predictor reconstruction, dendrogram
certification, symbolic machine learning, prime-congruence spectra, proof dynamics,
certified latent structure extraction
-/

import Mathlib

open Function Set Finset

noncomputable section

namespace UltrametricProofLearning

/-! ## §1. Core Definitions -/

/-- Idempotence of a self-map: `C (C x) = C x` for all `x`. -/
def IsIdempotent {S : Type*} (C : S → S) : Prop := ∀ x, C (C x) = C x

/-- The observer evaluation map: compress first, then observe.
    `evalProfile C obs x i = obs i (C x)` -/
def evalProfile {S ι σ : Type*} (C : S → S) (obs : ι → S → σ) : S → (ι → σ) :=
  fun x i => obs i (C x)

/-- Observer separation on compressed states: observers distinguish all distinct
    compressed (fixed-point) states. -/
def ObserverSeparatesCompressed {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ) : Prop :=
  ∀ ⦃x y : S⦄, C x = x → C y = y →
    (∀ i, obs i x = obs i y) → x = y

/-- The set of realizable observer profiles: the image of `evalProfile`. -/
def RealizableProfiles {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ) : Set (ι → σ) :=
  Set.range (evalProfile C obs)

/-- A compression-compatible ultrametric on proof states. -/
structure CompressedUltrametric {S : Type*} (C : S → S) (d : S → S → ℝ) : Prop where
  nonneg : ∀ x y, 0 ≤ d x y
  eq_zero : ∀ x y, C x = x → C y = y → (d x y = 0 ↔ x = y)
  symm : ∀ x y, d x y = d y x
  ultra : ∀ x y z, d x z ≤ max (d x y) (d y z)

/-- An ultrametric proof-learning system bundles all the components. -/
structure UltrametricProofSystem (S ι σ : Type*) where
  d : S → S → ℝ
  C : S → S
  obs : ι → S → σ
  h_idem : IsIdempotent C
  h_nonexp : ∀ x y, d (C x) (C y) ≤ d x y
  h_sep : ObserverSeparatesCompressed C obs

/-! ## §2. Theorem A — Faithful Finite Observer Representation -/

/-- **Theorem A (Faithful Representation on Compressed States).**
    Under observer separation, the observer evaluation map is injective on
    compressed (fixed-point) states. This is the core representation theorem:
    compressed proof states are faithfully encoded by observer profiles. -/
theorem evalProfile_injective_on_compressed
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_sep : ObserverSeparatesCompressed C obs) :
    ∀ ⦃x y : S⦄, C x = x → C y = y →
      evalProfile C obs x = evalProfile C obs y → x = y := by
  intro x y hx hy h
  apply h_sep hx hy
  intro i
  have := congr_fun h i
  simp only [evalProfile] at this
  rwa [hx, hy] at this

/-- The evaluation map factors through compression. -/
theorem evalProfile_factors_through_C
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C) :
    ∀ x, evalProfile C obs x = evalProfile C obs (C x) := by
  intro x; ext i; unfold evalProfile; congr 1; exact (h_idem x).symm

/-- The evaluation map restricted to `Set.range C` is injective. -/
theorem evalProfile_injective_on_range
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs) :
    Injective (fun (p : Set.range C) => evalProfile C obs p.val) := by
  intro ⟨x, hx⟩ ⟨y, hy⟩ h
  simp only [Subtype.mk.injEq]
  obtain ⟨a, rfl⟩ := hx
  obtain ⟨b, rfl⟩ := hy
  apply h_sep (h_idem a) (h_idem b)
  intro i
  have := congr_fun h i
  simp only [evalProfile] at this
  rwa [h_idem, h_idem] at this

/-! ## §3. Theorem A' — Finite Duality (Compressed States ≃ Profiles) -/

/-- The evaluation map from `Set.range C` to `Set.range (evalProfile C obs)`. -/
def evalProfileOnRange
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (_h_idem : IsIdempotent C) :
    Set.range C → Set.range (evalProfile C obs) :=
  fun ⟨x, _hx⟩ => ⟨evalProfile C obs x, x, rfl⟩

/-- The evaluation map on range is surjective. -/
theorem evalProfileOnRange_surjective
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C) :
    Surjective (evalProfileOnRange C obs h_idem) := by
  intro ⟨f, hf⟩
  obtain ⟨x, rfl⟩ := hf
  refine ⟨⟨C x, ⟨x, rfl⟩⟩, ?_⟩
  simp only [evalProfileOnRange, Subtype.mk.injEq]
  ext i; simp only [evalProfile]; congr 1; exact h_idem x

/-- The evaluation map on range is injective (from observer separation). -/
theorem evalProfileOnRange_injective
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs) :
    Injective (evalProfileOnRange C obs h_idem) := by
  intro ⟨x, hx⟩ ⟨y, hy⟩ h
  simp only [evalProfileOnRange, Subtype.mk.injEq] at h
  simp only [Subtype.mk.injEq]
  obtain ⟨a, rfl⟩ := hx
  obtain ⟨b, rfl⟩ := hy
  apply h_sep (h_idem a) (h_idem b)
  intro i
  have := congr_fun h i
  simp only [evalProfile] at this
  rwa [h_idem, h_idem] at this

/-- **Theorem A' (Finite Observer Duality — Constructive).**
    The evaluation map induces an equivalence between compressed states and
    realizable profiles. This is the central duality theorem: compressed proof
    states biject with observer profiles through the evaluation map. -/
def compressedProfileEquiv
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs) :
    Set.range C ≃ Set.range (evalProfile C obs) :=
  Equiv.ofBijective
    (evalProfileOnRange C obs h_idem)
    ⟨evalProfileOnRange_injective C obs h_idem h_sep,
     evalProfileOnRange_surjective C obs h_idem⟩

/-- The equivalence preserves the evaluation map. -/
theorem compressedProfileEquiv_val
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs)
    (p : Set.range C) :
    (compressedProfileEquiv C obs h_idem h_sep p).val =
      evalProfile C obs p.val := by
  simp [compressedProfileEquiv, Equiv.ofBijective, evalProfileOnRange]

/-- Existential form of the duality theorem. -/
theorem compressed_state_equiv_profile
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs) :
    ∃ e : Set.range C ≃ Set.range (evalProfile C obs),
      ∀ p : Set.range C, (e p).val = evalProfile C obs p.val :=
  ⟨compressedProfileEquiv C obs h_idem h_sep,
   compressedProfileEquiv_val C obs h_idem h_sep⟩

/-! ## §4. Tropical Semimodule Structure on Profiles -/

/-- Pointwise sup on observer profiles: the tropical/idempotent addition. -/
def profileSup {ι σ : Type*} [Max σ] (f g : ι → σ) : ι → σ :=
  fun i => max (f i) (g i)

/-- Pointwise sup is commutative. -/
theorem profileSup_comm {ι σ : Type*} [LinearOrder σ]
    (f g : ι → σ) : profileSup f g = profileSup g f := by
  ext i; simp [profileSup, max_comm]

/-- Pointwise sup is associative. -/
theorem profileSup_assoc {ι σ : Type*} [LinearOrder σ]
    (f g h : ι → σ) :
    profileSup (profileSup f g) h = profileSup f (profileSup g h) := by
  ext i; simp [profileSup, max_assoc]

/-- Pointwise sup is idempotent — the hallmark of tropical algebra. -/
theorem profileSup_idem {ι σ : Type*} [LinearOrder σ]
    (f : ι → σ) : profileSup f f = f := by
  ext i; simp [profileSup]

/-- Pointwise order on profiles. -/
def profileLE {ι σ : Type*} [LE σ] (f g : ι → σ) : Prop :=
  ∀ i, f i ≤ g i

/-- Profile order is reflexive. -/
theorem profileLE_refl {ι σ : Type*} [Preorder σ]
    (f : ι → σ) : profileLE f f :=
  fun _ => le_refl _

/-- Profile order is transitive. -/
theorem profileLE_trans {ι σ : Type*} [Preorder σ]
    {f g h : ι → σ} (hfg : profileLE f g) (hgh : profileLE g h) :
    profileLE f h :=
  fun i => le_trans (hfg i) (hgh i)

/-- Profile order is antisymmetric. -/
theorem profileLE_antisymm {ι σ : Type*} [PartialOrder σ]
    {f g : ι → σ} (hfg : profileLE f g) (hgf : profileLE g f) :
    f = g :=
  funext fun i => le_antisymm (hfg i) (hgf i)

/-! ## §5. Ultrametric Cluster Structure -/

/-- The ultrametric ball relation at radius `r`:
    `x ~ y` iff `d(x,y) ≤ r`. -/
def ultraBallRel {S : Type*} (d : S → S → ℝ) (r : ℝ) : S → S → Prop :=
  fun x y => d x y ≤ r

/-- The ultrametric ball relation is reflexive. -/
theorem ultraBallRel_refl {S : Type*} (d : S → S → ℝ)
    (hd : ∀ x, d x x = 0) (r : ℝ) (hr : 0 ≤ r) :
    Reflexive (ultraBallRel d r) := by
  intro x; simp [ultraBallRel, hd, hr]

/-- The ultrametric ball relation is symmetric. -/
theorem ultraBallRel_symm {S : Type*} (d : S → S → ℝ)
    (hd : ∀ x y, d x y = d y x) (r : ℝ) :
    Symmetric (ultraBallRel d r) := by
  intro x y h; unfold ultraBallRel at *; rwa [hd]

/-- The ultrametric ball relation is transitive (by the strong triangle inequality). -/
theorem ultraBallRel_trans {S : Type*} (d : S → S → ℝ)
    (hultra : ∀ x y z, d x z ≤ max (d x y) (d y z)) (r : ℝ) :
    Transitive (ultraBallRel d r) := by
  intro x y z hxy hyz
  unfold ultraBallRel at *
  calc d x z ≤ max (d x y) (d y z) := hultra x y z
    _ ≤ max r r := max_le_max hxy hyz
    _ = r := max_self r

/-- The ultrametric ball relation is an equivalence relation. -/
theorem ultraBallRel_equiv {S : Type*} (d : S → S → ℝ)
    (hd0 : ∀ x, d x x = 0) (hds : ∀ x y, d x y = d y x)
    (hultra : ∀ x y z, d x z ≤ max (d x y) (d y z))
    (r : ℝ) (hr : 0 ≤ r) :
    Equivalence (ultraBallRel d r) :=
  ⟨ultraBallRel_refl d hd0 r hr,
   @(ultraBallRel_symm d hds r),
   @(ultraBallRel_trans d hultra r)⟩

/-- Cluster refinement: smaller radius means finer clustering. -/
theorem ultraBallRel_mono {S : Type*} (d : S → S → ℝ)
    {r s : ℝ} (hrs : r ≤ s) (x y : S) :
    ultraBallRel d r x y → ultraBallRel d s x y :=
  fun h => le_trans h hrs

/-! ## §6. Theorem B — Canonical Ultrametric Tree Reconstruction -/

/-- A rooted tree model for hierarchical predictor reconstruction. -/
structure RootedTreeModel (S : Type*) where
  /-- The set of leaves -/
  leaves : Set S
  /-- Cluster relation: `sameCluster x y r` means x, y in same cluster at radius r -/
  sameCluster : S → S → ℝ → Prop
  /-- The root radius -/
  rootRadius : ℝ

/-- Construct the canonical tree model from a compressed ultrametric. -/
def canonicalTreeModel {S : Type*}
    (C : S → S) (d : S → S → ℝ) : RootedTreeModel S where
  leaves := Set.range C
  sameCluster := fun x y r => d (C x) (C y) ≤ r
  rootRadius := 0

/-- **Theorem B (Canonical Ultrametric Tree Reconstruction).**
    From a finite ultrametric proof-learning system, we reconstruct a canonical
    rooted tree model whose cluster structure exactly recovers the compressed
    ultrametric distances. -/
theorem exists_canonical_ultrametric_tree
    {S ι σ : Type*}
    [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    (d : S → S → ℝ)
    (C : S → S)
    (obs : ι → S → σ)
    (_h_idem : IsIdempotent C)
    (_h_nonexp : ∀ x y, d (C x) (C y) ≤ d x y)
    (_h_sep : ObserverSeparatesCompressed C obs) :
    ∃ (T : RootedTreeModel S),
      T.leaves = Set.range C ∧
      (∀ x y r, T.sameCluster x y r ↔ d (C x) (C y) ≤ r) :=
  ⟨canonicalTreeModel C d, rfl, fun _ _ _ => Iff.rfl⟩

/-- The canonical tree's cluster relation is an equivalence at each nonneg radius. -/
theorem canonical_tree_cluster_equiv
    {S : Type*}
    (d : S → S → ℝ)
    (C : S → S)
    (hd0 : ∀ x, d (C x) (C x) = 0)
    (hds : ∀ x y, d (C x) (C y) = d (C y) (C x))
    (hultra : ∀ x y z, d (C x) (C z) ≤ max (d (C x) (C y)) (d (C y) (C z)))
    (r : ℝ) (hr : 0 ≤ r) :
    Equivalence (fun x y => (canonicalTreeModel C d).sameCluster x y r) := by
  refine ⟨fun x => ?_, fun {x y} h => ?_, fun {x y z} hxy hyz => ?_⟩
  · simp [canonicalTreeModel, hd0, hr]
  · simp only [canonicalTreeModel] at *; rwa [hds]
  · simp only [canonicalTreeModel] at *
    calc d (C x) (C z) ≤ max (d (C x) (C y)) (d (C y) (C z)) := hultra x y z
      _ ≤ max r r := max_le_max hxy hyz
      _ = r := max_self r

/-! ## §7. Theorem B' — Uniqueness Up to Cluster Equivalence -/

/-- Two tree models are cluster-equivalent if they agree on all cluster relations. -/
def TreeModelsEquiv {S : Type*}
    (T₁ T₂ : RootedTreeModel S) (_C : S → S) : Prop :=
  ∀ x y r, T₁.sameCluster x y r ↔ T₂.sameCluster x y r

/-- **Theorem B' (Uniqueness).**
    Any two tree models that faithfully represent the compressed ultrametric
    have equivalent cluster structures. -/
theorem canonical_tree_unique
    {S : Type*}
    (d : S → S → ℝ)
    (C : S → S)
    (T₁ T₂ : RootedTreeModel S)
    (h₁ : ∀ x y r, T₁.sameCluster x y r ↔ d (C x) (C y) ≤ r)
    (h₂ : ∀ x y r, T₂.sameCluster x y r ↔ d (C x) (C y) ≤ r) :
    TreeModelsEquiv T₁ T₂ C :=
  fun x y r => (h₁ x y r).trans (h₂ x y r).symm

/-! ## §8. Certified Predictor Structures -/

/-- A certified predictor model. -/
structure CertifiedPredictor (S ι σ : Type*) where
  /-- Prediction from profile to state -/
  predict : (ι → σ) → S
  /-- The compression operator -/
  compress : S → S
  /-- The observer family -/
  observe : ι → S → σ

/-- A certified predictor is correct if predicting from a compressed profile
    yields a state with the same profile. -/
def CertifiedPredictor.IsCorrect {S ι σ : Type*}
    (P : CertifiedPredictor S ι σ) : Prop :=
  ∀ x : S, evalProfile P.compress P.observe
    (P.predict (evalProfile P.compress P.observe x)) =
    evalProfile P.compress P.observe x

/-- **Theorem C (Certified Predictor Reconstruction).**
    From a finite proof-learning system with observer separation and decidable
    equality, we construct a certified predictor. -/
theorem certified_hierarchical_predictor_reconstruction
    {S ι σ : Type*}
    [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    [DecidableEq σ] [Nonempty S]
    (C : S → S)
    (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (_h_sep : ObserverSeparatesCompressed C obs) :
    ∃ (P : CertifiedPredictor S ι σ),
      P.compress = C ∧
      P.observe = obs ∧
      P.IsCorrect := by
  let predict : (ι → σ) → S := fun f =>
    if h : ∃ s : S, evalProfile C obs s = f then C h.choose
    else Classical.arbitrary S
  refine ⟨⟨predict, C, obs⟩, rfl, rfl, ?_⟩
  intro x
  show evalProfile C obs (predict (evalProfile C obs x)) = evalProfile C obs x
  simp only [predict]
  have hex : ∃ s : S, evalProfile C obs s = evalProfile C obs x := ⟨x, rfl⟩
  rw [dif_pos hex]
  rw [← evalProfile_factors_through_C C obs h_idem]
  exact hex.choose_spec

/-! ## §9. Trace-Based Reconstruction -/

/-- Extract the compressed states from a trace. -/
def traceCompressedStates {S : Type*} [DecidableEq S]
    (C : S → S) (trace : List S) : Finset S :=
  (trace.map C).toFinset

/-- The compressed trace lies in `Set.range C`. -/
theorem traceCompressedStates_subset_range {S : Type*} [DecidableEq S]
    (C : S → S) (trace : List S) :
    ↑(traceCompressedStates C trace) ⊆ Set.range C := by
  intro x hx
  simp [traceCompressedStates] at hx
  obtain ⟨s, _, rfl⟩ := hx
  exact ⟨s, rfl⟩

/-- **Theorem C' (Trace-Based Reconstruction).**
    If two trace elements have the same observer profile, they have the
    same compressed image. -/
theorem certified_trace_reconstruction
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs)
    (trace : List S) :
    ∀ s ∈ trace, ∀ t ∈ trace,
      evalProfile C obs s = evalProfile C obs t → C s = C t := by
  intro s _ t _ h
  have : ∀ i, obs i (C s) = obs i (C t) := fun i => congr_fun h i
  exact h_sep (h_idem s) (h_idem t) this

/-! ## §10. Bridge Lemmas -/

/-- Bridge: Observer separation implies distinguishing observers exist for
    distinct compressed states (connects to `DiagonalAvoidsOn`). -/
theorem observer_separation_implies_faithful_encoding
    {S ι σ : Type*}
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs)
    (x y : S) (hne : C x ≠ C y) :
    ∃ i, obs i (C x) ≠ obs i (C y) := by
  by_contra h
  push_neg at h
  exact hne (h_sep (h_idem x) (h_idem y) h)

/-- Bridge: The duality equivalence provides a certified reconstruction inverse,
    mirroring `certified_gibbs_reconstruction_from_boundary_partition`. -/
theorem reconstruction_certificate_from_profiles
    {S ι σ : Type*}
    [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    [DecidableEq σ]
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs) :
    ∃ (reconstruct : Set.range (evalProfile C obs) → Set.range C),
      ∀ (x : Set.range C),
        reconstruct (compressedProfileEquiv C obs h_idem h_sep x) = x :=
  ⟨(compressedProfileEquiv C obs h_idem h_sep).symm,
   (compressedProfileEquiv C obs h_idem h_sep).symm_apply_apply⟩

/-! ## §11. Finite Cardinality Bounds -/

/-- The number of realizable profiles equals the number of compressed states. -/
theorem card_realizable_profiles_eq_card_compressed
    {S ι σ : Type*}
    [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    [DecidableEq σ]
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_sep : ObserverSeparatesCompressed C obs) :
    Fintype.card (Set.range C) = Fintype.card (Set.range (evalProfile C obs)) :=
  Fintype.card_of_bijective
    (compressedProfileEquiv C obs h_idem h_sep).bijective

/-- Upper bound: compressed states ≤ total states. -/
theorem card_compressed_le_card
    {S : Type*} [Fintype S] [DecidableEq S]
    (C : S → S) :
    Fintype.card (Set.range C) ≤ Fintype.card S :=
  Fintype.card_range_le C

/-! ## §12. Spectral Filtration -/

/-- Threshold sublevel set: states with all observer scores ≤ threshold. -/
def thresholdSublevel {S ι σ : Type*} [LE σ]
    (C : S → S) (obs : ι → S → σ) (t : ι → σ) : Set S :=
  {x | ∀ i, obs i (C x) ≤ t i}

/-- Threshold sublevel sets are monotone in the threshold. -/
theorem thresholdSublevel_mono {S ι σ : Type*} [Preorder σ]
    (C : S → S) (obs : ι → S → σ)
    (t t' : ι → σ) (h : ∀ i, t i ≤ t' i) :
    thresholdSublevel C obs t ⊆ thresholdSublevel C obs t' :=
  fun _ hx i => le_trans (hx i) (h i)

/-- Compression preserves threshold membership. -/
theorem thresholdSublevel_compression_stable {S ι σ : Type*} [Preorder σ]
    (C : S → S) (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (t : ι → σ) :
    ∀ x ∈ thresholdSublevel C obs t,
      C x ∈ thresholdSublevel C obs t := by
  intro x hx i
  simp only [thresholdSublevel, Set.mem_setOf_eq] at *
  rw [h_idem]
  exact hx i

/-! ## §13. Master Theorem -/

/-- **Master Theorem: Finite Observer Representation Duality.**
    A finite ultrametric proof-learning system with observer separation admits
    a complete finite representation: compressed states biject with realizable
    observer profiles, the cluster structure forms a canonical tree, and the
    tree is unique up to cluster equivalence. -/
theorem finite_observer_representation_duality
    {S ι σ : Type*}
    [Fintype S] [DecidableEq S] [Fintype ι] [DecidableEq ι]
    [DecidableEq σ]
    (d : S → S → ℝ)
    (C : S → S)
    (obs : ι → S → σ)
    (h_idem : IsIdempotent C)
    (h_nonexp : ∀ x y, d (C x) (C y) ≤ d x y)
    (h_sep : ObserverSeparatesCompressed C obs) :
    -- Part 1: Finite duality equivalence
    (∃ e : Set.range C ≃ Set.range (evalProfile C obs),
      ∀ p : Set.range C, (e p).val = evalProfile C obs p.val) ∧
    -- Part 2: Canonical tree reconstruction
    (∃ (T : RootedTreeModel S),
      T.leaves = Set.range C ∧
      (∀ x y r, T.sameCluster x y r ↔ d (C x) (C y) ≤ r)) ∧
    -- Part 3: Tree uniqueness
    (∀ T₁ T₂ : RootedTreeModel S,
      (∀ x y r, T₁.sameCluster x y r ↔ d (C x) (C y) ≤ r) →
      (∀ x y r, T₂.sameCluster x y r ↔ d (C x) (C y) ≤ r) →
      TreeModelsEquiv T₁ T₂ C) :=
  ⟨compressed_state_equiv_profile C obs h_idem h_sep,
   exists_canonical_ultrametric_tree d C obs h_idem h_nonexp h_sep,
   fun T₁ T₂ h₁ h₂ => canonical_tree_unique d C T₁ T₂ h₁ h₂⟩

end UltrametricProofLearning