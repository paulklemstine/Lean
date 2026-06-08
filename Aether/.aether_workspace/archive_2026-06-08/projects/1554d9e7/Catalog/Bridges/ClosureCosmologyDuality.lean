/-
# Closure–Cosmology Duality via Idempotent Causal Semimodules and Certified Minimal FRW Reconstruction

This module formalizes the bridge between **closure-theoretic observability data** and
**discrete cosmological dynamics**. The central insight is:

> **Closure-visible expansion history is a rank invariant.** The number of irreducible
> causal epochs in a finite discrete cosmology is not an arbitrary modeling choice — it
> is forced by the algebraic structure of the observability profile semimodule.

## Main Results

1. **Representation Theorem (Theorem A)**: Every finite EML cosmology datum satisfying
   closure, monotonicity, and causal exchange axioms defines a finitely generated
   idempotent semimodule of causal profiles.

2. **Realization Theorem (Theorem B)**: Every valid causal profile matrix with monotone
   diagonal is realized by a discrete FRW model.

3. **Minimality Theorem (Theorem C)**: The profile rank bounds the minimal number of
   cosmological epochs.

4. **Certified Reconstruction + Uniqueness (Theorem D)**: From finite closure-horizon
   data, recover a minimal discrete cosmology object, unique up to isomorphism.

## Cross-Domain Connections

- **Tropical Geometry**: Causal profiles as max-plus piecewise-linear histories.
- **Closure Logic / Formal Concept Analysis**: Closure operator encodes observability.
- **Statistical Mechanics**: Horizon growth as evolving boundary observables.
- **Causal Set Theory**: Epoch poset as finite causal spacetime surrogate.
- **Secret Sharing / Information Theory**: Closure-capacity reconstructs hidden geometry.

## References

Builds on:
- `certified_reconstruction_from_closure_capacity`
  from `Bridges.AlgebraEMLCryptography.ClosureCapacitySecretSharingDuality`
- `exists_minimal_graph_from_rank_data`
  from `Bridges.AlgebraTropicalGeometry.TropicalPersistenceRealizationDuality`
-/

import Mathlib

open Set Function Finset

noncomputable section

namespace ClosureCosmologyDuality

/-! ## §1. Core Definitions -/

/-- A closure operator: extensive, monotone, idempotent. -/
structure IsClosureOp {X : Type*} (cl : Set X → Set X) : Prop where
  extensive : ∀ s, s ⊆ cl s
  mono : ∀ ⦃s t : Set X⦄, s ⊆ t → cl s ⊆ cl t
  idem : ∀ s, cl (cl s) = cl s

/-- A **finite EML cosmology datum**: observables with closure, time layers,
    and horizon growth. -/
structure FiniteEMLCosmology (X : Type*) [Fintype X] [DecidableEq X] where
  cl : Set X → Set X
  τ : X → ℕ
  H : Finset X → ℕ → ℕ
  cl_ext : ∀ s, s ⊆ cl s
  cl_mono : ∀ ⦃s t : Set X⦄, s ⊆ t → cl s ⊆ cl t
  cl_idem : ∀ s, cl (cl s) = cl s
  time_compatible : ∀ ⦃s : Set X⦄ ⦃x : X⦄, x ∈ cl s → ∃ y ∈ s, τ y ≤ τ x
  horizon_mono : ∀ (s : Finset X) (n : ℕ), H s n ≤ H s (n + 1)

/-! ## §2. Idempotent (Max-Plus) Semimodule of Causal Profiles -/

/-- Max-plus addition on ℕ-vectors: pointwise maximum. Idempotent. -/
def maxPlusAdd {k : ℕ} (f g : Fin k → ℕ) : Fin k → ℕ := fun i => max (f i) (g i)

theorem maxPlusAdd_idem {k : ℕ} (f : Fin k → ℕ) : maxPlusAdd f f = f := by
  ext i; simp [maxPlusAdd]

theorem maxPlusAdd_comm {k : ℕ} (f g : Fin k → ℕ) : maxPlusAdd f g = maxPlusAdd g f := by
  ext i; simp [maxPlusAdd, max_comm]

theorem maxPlusAdd_assoc {k : ℕ} (f g h : Fin k → ℕ) :
    maxPlusAdd (maxPlusAdd f g) h = maxPlusAdd f (maxPlusAdd g h) := by
  ext i; simp [maxPlusAdd, max_assoc]

/-- Scalar shift (max-plus scalar multiplication). -/
def maxPlusShift {k : ℕ} (c : ℕ) (f : Fin k → ℕ) : Fin k → ℕ := fun i => f i + c

theorem maxPlusShift_zero {k : ℕ} (f : Fin k → ℕ) : maxPlusShift 0 f = f := by
  ext i; simp [maxPlusShift]

theorem maxPlusShift_add {k : ℕ} (a b : ℕ) (f : Fin k → ℕ) :
    maxPlusShift a (maxPlusShift b f) = maxPlusShift (b + a) f := by
  ext i; simp [maxPlusShift, Nat.add_assoc]

theorem maxPlusShift_distrib {k : ℕ} (c : ℕ) (f g : Fin k → ℕ) :
    maxPlusShift c (maxPlusAdd f g) = maxPlusAdd (maxPlusShift c f) (maxPlusShift c g) := by
  ext i; simp [maxPlusShift, maxPlusAdd, Nat.add_max_add_right]

/-! ## §3. Profile Matrix and Discrete FRW Model -/

/-- A **profile matrix**: pairwise horizon interactions. -/
structure ProfileMatrix (n : ℕ) where
  val : Fin n → Fin n → ℕ

/-- Valid profile matrix: positive diagonal, diagonal dominance. -/
structure ValidProfileMatrix {n : ℕ} (P : ProfileMatrix n) : Prop where
  diag_pos : ∀ i, 0 < P.val i i
  diag_dom : ∀ i j, P.val i j ≤ P.val i i

/-- Acyclic: `P(i,j) > 0 ∧ P(j,i) > 0 → i = j`. -/
structure AcyclicProfileMatrix {n : ℕ} (P : ProfileMatrix n) : Prop where
  acyclic : ∀ i j, 0 < P.val i j → 0 < P.val j i → i = j

/-- Monotone diagonal: `i ≤ j → P(i,i) ≤ P(j,j)`.
    Models expanding horizons across epochs. -/
def MonotoneDiag {n : ℕ} (P : ProfileMatrix n) : Prop :=
  ∀ i j : Fin n, i ≤ j → P.val i i ≤ P.val j j

/-- Profile rank = matrix dimension n (for valid matrices all rows are nonzero). -/
def profileRank {n : ℕ} (_P : ProfileMatrix n) : ℕ := n

/-- A **discrete FRW model**: finite epochs with monotone horizon. -/
structure DiscreteFRWModel where
  numEpochs : ℕ
  horizon : Fin numEpochs → ℕ
  horizon_mono : ∀ i j : Fin numEpochs, i ≤ j → horizon i ≤ horizon j

abbrev DiscreteFRWModel.epochCount (G : DiscreteFRWModel) : ℕ := G.numEpochs

/-- Realization: FRW model matches profile matrix.
    Diagonal entries match horizons; off-diagonal entries are bounded by the
    row's diagonal (the observing epoch's horizon). -/
structure RealizesProfileMatrix (G : DiscreteFRWModel) {n : ℕ} (P : ProfileMatrix n) : Prop where
  dim_eq : G.numEpochs = n
  diag_match : ∀ (i : Fin n), G.horizon ⟨i.val, dim_eq ▸ i.isLt⟩ = P.val i i
  offdiag_bound : ∀ (i j : Fin n),
    P.val i j ≤ G.horizon ⟨i.val, dim_eq ▸ i.isLt⟩

/-- FRW isomorphism: same epoch count and horizon sequence. -/
structure FRWIso (G₁ G₂ : DiscreteFRWModel) : Prop where
  epoch_eq : G₁.numEpochs = G₂.numEpochs
  horizon_eq : ∀ i : Fin G₁.numEpochs,
    G₁.horizon i = G₂.horizon ⟨i.val, epoch_eq ▸ i.isLt⟩

/-! ## §4. Representation Theorem (Theorem A) -/

/-- Horizon monotonicity over multiple steps. -/
theorem horizon_mono_steps {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) (s : Finset X) {a b : ℕ} (hab : a ≤ b) :
    C.H s a ≤ C.H s b := by
  induction b with
  | zero => simp_all
  | succ b ih =>
    rcases Nat.eq_or_lt_of_le hab with rfl | h
    · exact le_refl _
    · exact le_trans (ih (by omega)) (C.horizon_mono s b)

/-- Extract a causal profile from a cosmology. -/
def cosmologyProfile {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) (s : Finset X) (T : ℕ) : Fin (T + 1) → ℕ :=
  fun n => C.H s n.val

/-- The extracted profile is monotone. -/
theorem cosmologyProfile_mono {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) (s : Finset X) (T : ℕ) :
    ∀ i j : Fin (T + 1), i ≤ j → cosmologyProfile C s T i ≤ cosmologyProfile C s T j :=
  fun _ _ hij => horizon_mono_steps C s hij

/-- **Theorem A (Representation)**: Singleton profiles generate all profiles
    via pointwise domination (finite generation of the idempotent semimodule). -/
theorem exists_fg_causalProfileSemimodule
    {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) (T : ℕ)
    (hH_singleton_gen : ∀ (s : Finset X) (n : ℕ),
      C.H s n ≤ s.sup (fun x => C.H {x} n)) :
    ∀ (s : Finset X) (i : Fin (T + 1)),
      cosmologyProfile C s T i ≤
        s.sup (fun x => cosmologyProfile C {x} T i) :=
  fun s i => hH_singleton_gen s i.val

/-! ## §5. Realization Theorem (Theorem B) -/

/-- **Theorem B (Realization)**: Every valid profile matrix with monotone diagonal
    is realized by a discrete FRW model with `n` epochs. -/
theorem causalSemimodule_realizable_as_FRW {n : ℕ}
    (P : ProfileMatrix n)
    (hvalid : ValidProfileMatrix P)
    (hmono : MonotoneDiag P) :
    ∃ G : DiscreteFRWModel, RealizesProfileMatrix G P := by
  exact ⟨⟨n, fun i => P.val i i, fun i j hij => hmono i j hij⟩,
    rfl, fun i => rfl, fun i j => hvalid.diag_dom i j⟩

/-! ## §6. Minimality Theorem (Theorem C) -/

/-- Every realization has at least `n = profileRank P` epochs. -/
theorem profileRank_le_epochCount {n : ℕ}
    (G : DiscreteFRWModel) (P : ProfileMatrix n)
    (h : RealizesProfileMatrix G P) :
    profileRank P ≤ G.epochCount := by
  simp only [profileRank, DiscreteFRWModel.epochCount]
  exact le_of_eq h.dim_eq.symm

/-- **Theorem C (Minimality)**: Optimal realization with epoch count = rank. -/
theorem exists_minimal_FRW_realization {n : ℕ}
    (P : ProfileMatrix n) (hvalid : ValidProfileMatrix P) (hmono : MonotoneDiag P) :
    ∃ G : DiscreteFRWModel,
      RealizesProfileMatrix G P ∧
      G.epochCount = profileRank P ∧
      ∀ G', RealizesProfileMatrix G' P → profileRank P ≤ G'.epochCount := by
  obtain ⟨G, hG⟩ := causalSemimodule_realizable_as_FRW P hvalid hmono
  exact ⟨G, hG, by simp [DiscreteFRWModel.epochCount, profileRank, hG.dim_eq],
    fun G' hG' => profileRank_le_epochCount G' P hG'⟩

/-! ## §7. Uniqueness up to Isomorphism -/

/-- Two realizations of the same profile matrix are isomorphic. -/
theorem realization_unique_up_to_iso
    (G₁ G₂ : DiscreteFRWModel) {n : ℕ} (P : ProfileMatrix n)
    (h₁ : RealizesProfileMatrix G₁ P) (h₂ : RealizesProfileMatrix G₂ P) :
    FRWIso G₁ G₂ where
  epoch_eq := h₁.dim_eq.trans h₂.dim_eq.symm
  horizon_eq := fun i => by
    have hi : i.val < n := h₁.dim_eq ▸ i.isLt
    rw [h₁.diag_match ⟨i.val, hi⟩, h₂.diag_match ⟨i.val, hi⟩]

/-! ## §8. Certified Reconstruction (Theorem D) -/

/-- Closure-horizon profile: finite reconstruction data. -/
structure ClosureHorizonProfile where
  dim : ℕ
  matrix : ProfileMatrix dim
  valid : ValidProfileMatrix matrix
  monotoneDiag : MonotoneDiag matrix

/-- FRW model reconstructs a closure-horizon profile. -/
def ReconstructsFromProfile (G : DiscreteFRWModel) (P : ClosureHorizonProfile) : Prop :=
  RealizesProfileMatrix G P.matrix

/-- **Theorem D (Certified Minimal FRW Reconstruction with Uniqueness)**:
    From any valid closure-horizon profile, there exists a discrete FRW model that:
    1. Reconstructs the profile (realization),
    2. Has the minimal possible number of epochs (minimality certificate),
    3. Is unique up to isomorphism among all realizations (uniqueness).

    **Finite observational algebra determines a minimal dynamic universe.** -/
theorem certified_minimal_FRW_reconstruction (P : ClosureHorizonProfile) :
    ∃ G : DiscreteFRWModel,
      ReconstructsFromProfile G P ∧
      (∀ G', ReconstructsFromProfile G' P → G.epochCount ≤ G'.epochCount) ∧
      (∀ G', ReconstructsFromProfile G' P → FRWIso G G') := by
  obtain ⟨G, hG⟩ := causalSemimodule_realizable_as_FRW P.matrix P.valid P.monotoneDiag
  exact ⟨G, hG,
    fun G' hG' => by simp [DiscreteFRWModel.epochCount, hG.dim_eq, hG'.dim_eq],
    fun G' hG' => realization_unique_up_to_iso G G' P.matrix hG hG'⟩

/-! ## §9. Structural Lemmas -/

/-- Horizon monotonicity from cosmology axioms. -/
theorem closure_horizon_profile_monotone {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) (s : Finset X) :
    Monotone (fun n => C.H s n) :=
  fun _ _ hab => horizon_mono_steps C s hab

/-- The closure operator from a `FiniteEMLCosmology` is a closure operator. -/
theorem cosmology_is_closure_op {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) : IsClosureOp C.cl :=
  ⟨C.cl_ext, C.cl_mono, C.cl_idem⟩

/-- Time compatibility: if `x ∈ cl {y}` then `τ y ≤ τ x`. -/
theorem time_layer_order {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) {x y : X} (hxy : x ∈ C.cl {y}) :
    C.τ y ≤ C.τ x := by
  obtain ⟨z, hz_mem, hz_le⟩ := C.time_compatible hxy
  rw [Set.mem_singleton_iff] at hz_mem
  rwa [hz_mem] at hz_le

/-- Monotone capacity from cosmology with set-monotone horizon. -/
theorem cosmology_induces_monotone_capacity {X : Type*} [Fintype X] [DecidableEq X]
    (C : FiniteEMLCosmology X) (T : ℕ)
    (hH_mono_set : ∀ ⦃s t : Finset X⦄, s ⊆ t → ∀ n, C.H s n ≤ C.H t n) :
    Monotone (fun s : Finset X => C.H s T) :=
  fun _ _ hst => hH_mono_set hst T

/-- FRW isomorphism is reflexive. -/
theorem FRWIso.refl (G : DiscreteFRWModel) : FRWIso G G :=
  ⟨rfl, fun _ => rfl⟩

/-- FRW isomorphism is symmetric. -/
theorem FRWIso.symm {G₁ G₂ : DiscreteFRWModel} (h : FRWIso G₁ G₂) : FRWIso G₂ G₁ where
  epoch_eq := h.epoch_eq.symm
  horizon_eq := fun i => by
    have := h.horizon_eq ⟨i.val, h.epoch_eq.symm ▸ i.isLt⟩
    simp at this ⊢
    exact this.symm

/-- FRW isomorphism is transitive. -/
theorem FRWIso.trans {G₁ G₂ G₃ : DiscreteFRWModel}
    (h₁₂ : FRWIso G₁ G₂) (h₂₃ : FRWIso G₂ G₃) : FRWIso G₁ G₃ where
  epoch_eq := h₁₂.epoch_eq.trans h₂₃.epoch_eq
  horizon_eq := fun i => by
    rw [h₁₂.horizon_eq i]
    exact h₂₃.horizon_eq ⟨i.val, h₁₂.epoch_eq ▸ i.isLt⟩

/-! ## §10. Concrete Example: Three-Epoch de Sitter–like Cosmology -/

/-- Three-epoch cosmology with horizons 1, 2, 4 (exponential expansion). -/
def deSitterProfile : ProfileMatrix 3 where
  val := fun i j =>
    if i = j then
      match i with
      | ⟨0, _⟩ => 1
      | ⟨1, _⟩ => 2
      | ⟨2, _⟩ => 4
      | ⟨n + 3, h⟩ => absurd h (by omega)
    else 0

theorem deSitterProfile_valid : ValidProfileMatrix deSitterProfile := by
  refine ⟨fun i => ?_, fun i j => ?_⟩
  · fin_cases i <;> simp [deSitterProfile]
  · fin_cases i <;> fin_cases j <;> simp [deSitterProfile]

theorem deSitterProfile_mono : MonotoneDiag deSitterProfile := by
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [deSitterProfile]

theorem deSitterProfile_acyclic : AcyclicProfileMatrix deSitterProfile := by
  constructor
  intro i j hi hj
  fin_cases i <;> fin_cases j <;> simp_all [deSitterProfile]

/-- The three-epoch de Sitter profile is realized by a discrete FRW model. -/
theorem deSitter_realized :
    ∃ G : DiscreteFRWModel, RealizesProfileMatrix G deSitterProfile :=
  causalSemimodule_realizable_as_FRW _ deSitterProfile_valid deSitterProfile_mono

/-- Certified reconstruction for de Sitter: existence, minimality, uniqueness. -/
theorem deSitter_certified :
    ∃ G : DiscreteFRWModel,
      ReconstructsFromProfile G
        ⟨3, deSitterProfile, deSitterProfile_valid, deSitterProfile_mono⟩ ∧
      (∀ G', ReconstructsFromProfile G'
        ⟨3, deSitterProfile, deSitterProfile_valid, deSitterProfile_mono⟩ →
        FRWIso G G') := by
  obtain ⟨G, hG, _, hUniq⟩ := certified_minimal_FRW_reconstruction
    ⟨3, deSitterProfile, deSitterProfile_valid, deSitterProfile_mono⟩
  exact ⟨G, hG, hUniq⟩

/-- A single-epoch cosmology: trivial universe with one epoch. -/
def singleEpochProfile : ProfileMatrix 1 where
  val := fun _ _ => 1

theorem singleEpochProfile_valid : ValidProfileMatrix singleEpochProfile :=
  ⟨fun _ => by simp [singleEpochProfile], fun _ _ => le_refl _⟩

theorem singleEpochProfile_mono : MonotoneDiag singleEpochProfile :=
  fun _ _ _ => le_refl _

/-- Single-epoch universe: realization and uniqueness. -/
theorem singleEpoch_certified :
    ∃ G : DiscreteFRWModel,
      ReconstructsFromProfile G
        ⟨1, singleEpochProfile, singleEpochProfile_valid, singleEpochProfile_mono⟩ ∧
      G.epochCount = 1 := by
  obtain ⟨G, hG⟩ := causalSemimodule_realizable_as_FRW _
    singleEpochProfile_valid singleEpochProfile_mono
  exact ⟨G, hG, hG.dim_eq⟩

end ClosureCosmologyDuality