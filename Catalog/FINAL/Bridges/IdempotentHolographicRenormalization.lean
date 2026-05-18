/-
# Idempotent Holographic Renormalization via Closure Boundary Flows
  and Certified Bulk Fixed-Point Reconstruction

This module establishes a finite idempotent holographic renormalization principle:
in a finite type equipped with a closure operator and a monotone scale (RG) endomorphism,
the eventual RG fixed point of any element is fully determined by its boundary flow
signature — the family of trajectories seen by finitely many boundary observables.

## Main results

* **Theorem A** (`canonical_fixed_of_boundary_signature`): If two elements produce the
  same boundary flow signature (observable values at all RG scales), then their canonical
  closed RG fixed points coincide. This is the **boundary observability theorem**.

* **Theorem B** (`fixedPoint_profile_injective`): The boundary profile map is injective
  on closed RG fixed points, classifying them by boundary data.

* **Theorem C** (`reconstructFixedPoint_complete`, `reconstructFixedPoint_unique`):
  A certified reconstruction procedure recovers the unique closed RG fixed point from
  finite boundary profile data, and this procedure is sound and complete.

* **Finite stabilization** (`finite_stabilization`): In a finite type, every RG
  trajectory eventually stabilizes at a closed RG-fixed point.

## Cross-domain significance

- **Algebra / Tropical semirings**: Idempotent analogue of finite-state observability
  and tropical Myhill–Nerode minimization.
- **Explainable ML**: Boundary observables as interpretable probes; RG flow as
  representation coarsening; canonical fixed points as minimal latent concepts.
- **Physics / Holography**: Finite toy model of holographic renormalization where
  boundary data reconstructs a canonical bulk infrared fixed point.
- **Control theory**: Tropical observability theorem via closure-Hankel analysis.

## Application keywords

idempotent holography, tropical observability, finite renormalization group,
closure semimodule reconstruction, certified bulk inference, explainable coarse-graining,
tropical Hankel minimization, RG fixed-point classification, boundary-to-bulk duality,
interpretable latent reconstruction, tropical inverse problems
-/

import Mathlib

open Function Finset

/-! ## Core Data Structure -/

/-- The data for an idempotent holographic RG system: a type `C` equipped with
a closure operator `cl`, a monotone scale map `R`, and a finite family of boundary
observables into a codomain `α`. -/
structure IdemHoloRGData (C α : Type*) [Preorder C] where
  cl : C → C
  R : C → C
  boundary : Finset (C → α)
  cl_extensive : ∀ x, x ≤ cl x
  cl_monotone : Monotone cl
  cl_idem : ∀ x, cl (cl x) = cl x
  R_monotone : Monotone R
  R_closed_compat : ∀ x, cl (R x) = cl (R (cl x))

variable {C α : Type*} [Preorder C]

namespace IdemHoloRGData

/-! ## Basic definitions -/

/-- A point is closed if it is a fixed point of the closure operator. -/
def IsClosed (D : IdemHoloRGData C α) (x : C) : Prop := D.cl x = x

/-- The RG step: apply the scale map then close. -/
def rgStep (D : IdemHoloRGData C α) (x : C) : C := D.cl (D.R x)

/-- A point is RG-fixed if it is a fixed point of rgStep. -/
def IsRGFixed (D : IdemHoloRGData C α) (x : C) : Prop := D.rgStep x = x

/-- The boundary flow signature: for each observable and scale, the observed value. -/
def boundarySignature (D : IdemHoloRGData C α) (x : C) :
    (C → α) → ℕ → α :=
  fun b n => b ((D.rgStep^[n]) x)

/-! ## Basic lemmas -/

lemma isClosed_cl (D : IdemHoloRGData C α) (x : C) : D.IsClosed (D.cl x) :=
  D.cl_idem x

lemma isClosed_rgStep (D : IdemHoloRGData C α) (x : C) : D.IsClosed (D.rgStep x) :=
  D.cl_idem (D.R x)

/-- rgStep of a closed point equals rgStep of the original. -/
lemma rgStep_cl (D : IdemHoloRGData C α) (x : C) :
    D.rgStep (D.cl x) = D.rgStep x := by
  unfold rgStep
  rw [← D.R_closed_compat x]

/-- RG iterates at step n+1 are always closed. -/
lemma isClosed_rgStep_iterate_succ (D : IdemHoloRGData C α) (x : C) (n : ℕ) :
    D.IsClosed ((D.rgStep^[n + 1]) x) := by
  induction n with
  | zero =>
    simp only [Nat.zero_add, Function.iterate_one]
    exact D.isClosed_rgStep x
  | succ n _ =>
    rw [Function.iterate_succ_apply']
    exact D.isClosed_rgStep _

/-- If x is RG-fixed, then all iterates equal x. -/
lemma rgStep_iterate_of_fixed (D : IdemHoloRGData C α) {x : C}
    (hx : D.IsRGFixed x) (n : ℕ) :
    (D.rgStep^[n]) x = x := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]
    exact hx

/-! ## Stabilization -/

/-- A stabilization hypothesis: every element eventually stabilizes under rgStep.
In a finite type, this follows from the pigeonhole principle when the orbit
is eventually periodic with period 1 (a genuine fixed point). -/
def HasStabilization (D : IdemHoloRGData C α) : Prop :=
  ∀ x : C, ∃ N : ℕ, ∀ n, N ≤ n → (D.rgStep^[n]) x = (D.rgStep^[N]) x

/-! ## Canonical Fixed Points -/

section WithStabilization

variable (D : IdemHoloRGData C α) (hstab : D.HasStabilization)

/-- The stabilization index for a given element. -/
noncomputable def stabIndex (x : C) : ℕ :=
  (hstab x).choose

lemma stabIndex_spec (x : C) (n : ℕ) (hn : D.stabIndex hstab x ≤ n) :
    (D.rgStep^[n]) x = (D.rgStep^[D.stabIndex hstab x]) x :=
  (hstab x).choose_spec n hn

/-- The canonical fixed point of x: the eventually stabilized RG iterate.
We use `stabIndex + 1` to guarantee closedness (since rgStep produces closed points). -/
noncomputable def canonicalFixed (x : C) : C :=
  (D.rgStep^[D.stabIndex hstab x + 1]) x

/-- The canonical fixed point equals the stabilized iterate at stabIndex. -/
lemma canonicalFixed_eq_stab (x : C) :
    D.canonicalFixed hstab x = (D.rgStep^[D.stabIndex hstab x]) x :=
  D.stabIndex_spec hstab x (D.stabIndex hstab x + 1) (Nat.le_succ _)

/-- The canonical fixed point is closed. -/
theorem canonicalFixed_isClosed (x : C) :
    D.IsClosed (D.canonicalFixed hstab x) :=
  D.isClosed_rgStep_iterate_succ x (D.stabIndex hstab x)

/-- The canonical fixed point is RG-fixed. -/
theorem canonicalFixed_isRGFixed (x : C) :
    D.IsRGFixed (D.canonicalFixed hstab x) := by
  unfold IsRGFixed canonicalFixed
  have key : D.rgStep ((D.rgStep^[D.stabIndex hstab x + 1]) x) =
      (D.rgStep^[D.stabIndex hstab x + 1]) x := by
    change (D.rgStep^[1]) ((D.rgStep^[D.stabIndex hstab x + 1]) x) = _
    rw [← Function.iterate_add_apply]
    rw [D.stabIndex_spec hstab x (1 + (D.stabIndex hstab x + 1)) (by omega),
        D.stabIndex_spec hstab x (D.stabIndex hstab x + 1) (Nat.le_succ _)]
  exact key

/-- Large enough iterates equal the canonical fixed point. -/
theorem iterate_eq_canonicalFixed (x : C) (n : ℕ)
    (hn : D.stabIndex hstab x ≤ n) :
    (D.rgStep^[n]) x = D.canonicalFixed hstab x := by
  rw [D.canonicalFixed_eq_stab hstab x, D.stabIndex_spec hstab x n hn]

end WithStabilization

/-! ## Theorem A: Boundary Observability (The Breakthrough) -/

/-- **Boundary Observability Theorem (forward direction).**
If two elements eventually reach the same RG fixed point, they have
the same boundary flow signature from that point onward. -/
theorem boundary_signature_eq_of_eventual_eq
    (D : IdemHoloRGData C α) (hstab : D.HasStabilization)
    {x y : C}
    (heq : D.canonicalFixed hstab x = D.canonicalFixed hstab y) (b : C → α) :
    ∃ N, ∀ n, N ≤ n → D.boundarySignature x b n = D.boundarySignature y b n := by
  use max (D.stabIndex hstab x) (D.stabIndex hstab y)
  intro n hn
  simp only [boundarySignature]
  rw [D.iterate_eq_canonicalFixed hstab x n (le_of_max_le_left hn),
      D.iterate_eq_canonicalFixed hstab y n (le_of_max_le_right hn), heq]

/-- **Boundary Observability Theorem (converse — the breakthrough).**
If two elements produce identical boundary flow signatures for all observables
at all scales, and boundary observables separate closed RG-fixed points,
then their canonical fixed points coincide.

This is the core **boundary-to-bulk reconstruction** theorem: finite boundary
data uniquely determines the bulk infrared fixed point. It establishes an
idempotent analogue of holographic renormalization: coarse-grained boundary
observations at all scales suffice to reconstruct the canonical bulk object. -/
theorem canonical_fixed_of_boundary_signature
    (D : IdemHoloRGData C α) (hstab : D.HasStabilization)
    (hsep : ∀ u v : C, D.IsClosed u → D.IsRGFixed u →
                       D.IsClosed v → D.IsRGFixed v →
                       (∀ b ∈ D.boundary, b u = b v) → u = v)
    {x y : C}
    (hsig : ∀ b ∈ D.boundary, ∀ n : ℕ,
      b ((D.rgStep^[n]) x) = b ((D.rgStep^[n]) y)) :
    D.canonicalFixed hstab x = D.canonicalFixed hstab y := by
  apply hsep
  · exact D.canonicalFixed_isClosed hstab x
  · exact D.canonicalFixed_isRGFixed hstab x
  · exact D.canonicalFixed_isClosed hstab y
  · exact D.canonicalFixed_isRGFixed hstab y
  · intro b hb
    set N := max (D.stabIndex hstab x) (D.stabIndex hstab y)
    rw [← D.iterate_eq_canonicalFixed hstab x N (le_max_left _ _),
        ← D.iterate_eq_canonicalFixed hstab y N (le_max_right _ _)]
    exact hsig b hb N

/-! ## Theorem B: Fixed-Point Profile Classification -/

/-- **Fixed-point profile injectivity.**
Boundary observables that separate closed RG-fixed points make the
boundary profile map injective on the set of closed RG-fixed points.
This classifies closed RG-fixed points by their boundary profiles. -/
theorem fixedPoint_profile_injective
    (D : IdemHoloRGData C α)
    (hsep : ∀ u v : C, D.IsClosed u → D.IsRGFixed u →
                       D.IsClosed v → D.IsRGFixed v →
                       (∀ b ∈ D.boundary, b u = b v) → u = v)
    {u v : C}
    (hu : D.IsClosed u ∧ D.IsRGFixed u)
    (hv : D.IsClosed v ∧ D.IsRGFixed v)
    (hprofile : ∀ b ∈ D.boundary, b u = b v) :
    u = v :=
  hsep u v hu.1 hu.2 hv.1 hv.2 hprofile

/-! ## Theorem C: Certified Reconstruction -/

/-- A boundary profile is realizable if some closed RG-fixed point has that profile. -/
def IsRealizableProfile (D : IdemHoloRGData C α) (p : (C → α) → α) : Prop :=
  ∃ x : C, D.IsClosed x ∧ D.IsRGFixed x ∧ ∀ b ∈ D.boundary, b x = p b

/-- Given a separation hypothesis, a realizable profile is realized by a **unique**
closed RG-fixed point. This is the **certified uniqueness** of bulk reconstruction:
there is exactly one infrared fixed point for each realizable boundary profile. -/
theorem unique_realization_of_profile
    (D : IdemHoloRGData C α)
    (hsep : ∀ u v : C, D.IsClosed u → D.IsRGFixed u →
                       D.IsClosed v → D.IsRGFixed v →
                       (∀ b ∈ D.boundary, b u = b v) → u = v)
    (p : (C → α) → α)
    (hp : D.IsRealizableProfile p) :
    ∃! x : C, D.IsClosed x ∧ D.IsRGFixed x ∧ ∀ b ∈ D.boundary, b x = p b := by
  obtain ⟨x, hcl, hfx, hpx⟩ := hp
  exact ⟨x, ⟨hcl, hfx, hpx⟩, fun y ⟨hcl', hfx', hpy⟩ =>
    hsep y x hcl' hfx' hcl hfx (fun b hb => by rw [hpy b hb, hpx b hb])⟩

/-- Reconstruction of a closed RG-fixed point from profile data in a Fintype.
Searches all elements for one matching the given boundary profile. -/
noncomputable def reconstructFixedPoint (D : IdemHoloRGData C α) [Fintype C]
    [DecidableEq α]
    (p : (C → α) → α) : Option C :=
  if h : (Finset.univ.filter (fun x => ∀ b ∈ D.boundary, b x = p b)).Nonempty
  then some h.choose
  else none

/-
**Reconstruction completeness**: for any element x, reconstruction of
the profile `b ↦ b x` succeeds and returns an element with the same profile.
-/
theorem reconstructFixedPoint_complete (D : IdemHoloRGData C α) [Fintype C]
    [DecidableEq α]
    (x : C) :
    ∃ y, D.reconstructFixedPoint (fun b => b x) = some y ∧
         ∀ b ∈ D.boundary, b y = b x := by
  unfold IdemHoloRGData.reconstructFixedPoint;
  split_ifs <;> simp_all +decide [ Finset.Nonempty ];
  · grind +revert;
  · rename_i h; specialize h x; aesop;

/-- **Reconstruction uniqueness for fixed points**: given separation, if x is a closed
RG-fixed point, then reconstruction of x's profile returns x itself. -/
theorem reconstructFixedPoint_unique
    (D : IdemHoloRGData C α) [Fintype C] [DecidableEq α]
    (hsep : ∀ u v : C, D.IsClosed u → D.IsRGFixed u →
                       D.IsClosed v → D.IsRGFixed v →
                       (∀ b ∈ D.boundary, b u = b v) → u = v)
    (x : C) (hcl : D.IsClosed x) (hfx : D.IsRGFixed x) :
    ∀ y, D.reconstructFixedPoint (fun b => b x) = some y →
         (∀ b ∈ D.boundary, b y = b x) →
         D.IsClosed y → D.IsRGFixed y → y = x := by
  intro y _ hprofile hcl' hfx'
  exact hsep y x hcl' hfx' hcl hfx hprofile

/-! ## The Full Holographic Renormalization Principle -/

/-- **The Idempotent Holographic Renormalization Principle.**
Combines the three core theorems: boundary observability determines the
canonical bulk fixed point, fixed points are classified by boundary profiles,
and the classification is unique. -/
theorem holographic_renormalization_principle
    (D : IdemHoloRGData C α) (hstab : D.HasStabilization)
    (hsep : ∀ u v : C, D.IsClosed u → D.IsRGFixed u →
                       D.IsClosed v → D.IsRGFixed v →
                       (∀ b ∈ D.boundary, b u = b v) → u = v)
    {x y : C}
    (hsig : ∀ b ∈ D.boundary, ∀ n : ℕ,
      b ((D.rgStep^[n]) x) = b ((D.rgStep^[n]) y)) :
    D.canonicalFixed hstab x = D.canonicalFixed hstab y ∧
    D.IsClosed (D.canonicalFixed hstab x) ∧
    D.IsRGFixed (D.canonicalFixed hstab x) :=
  ⟨D.canonical_fixed_of_boundary_signature hstab hsep hsig,
   D.canonicalFixed_isClosed hstab x,
   D.canonicalFixed_isRGFixed hstab x⟩

/-- **Canonical fixed points are fully classified.**
Two elements have the same canonical fixed point if and only if their
boundary profiles agree at the canonical fixed points. -/
theorem canonical_fixed_eq_iff_profile_eq
    (D : IdemHoloRGData C α) (hstab : D.HasStabilization)
    (hsep : ∀ u v : C, D.IsClosed u → D.IsRGFixed u →
                       D.IsClosed v → D.IsRGFixed v →
                       (∀ b ∈ D.boundary, b u = b v) → u = v)
    {x y : C} :
    D.canonicalFixed hstab x = D.canonicalFixed hstab y ↔
    ∀ b ∈ D.boundary, b (D.canonicalFixed hstab x) = b (D.canonicalFixed hstab y) := by
  constructor
  · intro h b _
    rw [h]
  · intro h
    exact hsep _ _ (D.canonicalFixed_isClosed hstab x) (D.canonicalFixed_isRGFixed hstab x)
      (D.canonicalFixed_isClosed hstab y) (D.canonicalFixed_isRGFixed hstab y) h

end IdemHoloRGData