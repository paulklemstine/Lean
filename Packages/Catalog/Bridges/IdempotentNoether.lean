import Mathlib
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Idempotent Noether Correspondence: Main Theorems

This file proves the main results of the Idempotent Noether Correspondence,
establishing a tropical/order-theoretic analogue of Noether's theorem for
closure-based dynamics on finite lattices.

## Main Results

### Structural Lemmas
* `descent_preserved` — Dynamics preserves descent sets of commuting symmetries
* `fixedPt_preserved` — Dynamics preserves fixed points of commuting symmetries
* `fixedPt_reflected` — Injective dynamics reflects fixed points
* `fixedPt_iff` — Full conservation: fixed-point membership is τ-invariant

### Conservation Theorems
* `monoid_conservation_cl_σ` — Charges invariant under σ and cl are invariant
  under all iterated compositions of cl ∘ σ
* `closure_factored_conservation` — Charges factoring through closure are
  conserved when closure commutes with dynamics
* `tropical_noether` — Main Noether theorem: σ+cl invariance yields τ-invariance

### Noether Correspondence
* `noether_correspondence` — Conserved Bool charge from symmetry
* `charge_separates` — Charge → symmetry reconstruction (injectivity)

### Duality
* `noether_duality` — Bool-valued charge duality for finite types
* `fixedPt_count_conserved` — Cardinality conservation of fixed-point sets
-/
import Logic.GraphTheory.Defs

namespace IdempotentNoether

/-! ## Part I: Structural Lemmas on Symmetries and Fixed Points -/

/-- **Descent Set Preservation**: If σ commutes with τ and τ is monotone,
then τ maps the descent set of σ into itself. -/
theorem descent_preserved {X : Type*} [Preorder X] {σ τ : X → X}
    (hcomm : Function.Commute σ τ) (hτ_mono : Monotone τ)
    {x : X} (hdesc : σ x ≤ x) : σ (τ x) ≤ τ x := by
  rw [hcomm x]; exact hτ_mono hdesc

/-- **Fixed-Point Preservation**: τ maps fixed points of commuting σ to fixed points. -/
theorem fixedPt_preserved {X : Type*} {σ τ : X → X}
    (hcomm : Function.Commute σ τ) {x : X} (hfix : σ x = x) :
    σ (τ x) = τ x := by
  rw [hcomm x, hfix]

/-- **Fixed-Point Reflection**: Injective τ reflects fixed points of commuting σ. -/
theorem fixedPt_reflected {X : Type*} {σ τ : X → X}
    (hcomm : Function.Commute σ τ) (hinj : Function.Injective τ)
    {x : X} (hfix : σ (τ x) = τ x) : σ x = x := by
  have h := hcomm x; rw [hfix] at h; exact hinj h.symm

/-- **Fixed-Point Conservation** (iff): For commuting maps with τ injective,
fixed-point membership is fully conserved — the idempotent Noether charge. -/
theorem fixedPt_iff {X : Type*} {σ τ : X → X}
    (hcomm : Function.Commute σ τ) (hinj : Function.Injective τ)
    (x : X) : σ x = x ↔ σ (τ x) = τ x :=
  ⟨fixedPt_preserved hcomm, fixedPt_reflected hcomm hinj⟩

/-- Fixed-point set membership is invariant under injective commuting dynamics. -/
theorem fixedPtSet_invariant {X : Type*} {σ τ : X → X}
    (hcomm : Function.Commute σ τ) (hinj : Function.Injective τ)
    (x : X) : x ∈ fixedPtSet σ ↔ τ x ∈ fixedPtSet σ := by
  simp only [fixedPtSet, Set.mem_setOf_eq]
  exact fixedPt_iff hcomm hinj x

/-- Descent set membership is preserved forward. -/
theorem descentSet_forward {X : Type*} [Preorder X] {σ τ : X → X}
    (hcomm : Function.Commute σ τ) (hτ_mono : Monotone τ)
    {x : X} (hx : x ∈ descentSet σ) : τ x ∈ descentSet σ :=
  descent_preserved hcomm hτ_mono hx

/-! ## Part II: Closure Operator Lemmas -/

/-- Closure of a closed element is itself. -/
theorem ClosureOp.cl_closed {X : Type*} [Preorder X] (C : ClosureOp X)
    {x : X} (hx : C.IsClosed x) : C.cl x = x := hx

/-- The closure of any element is closed. -/
theorem ClosureOp.cl_is_closed {X : Type*} [Preorder X] (C : ClosureOp X)
    (x : X) : C.IsClosed (C.cl x) := C.idem x

/-- If σ commutes with cl, then σ maps closed elements to closed elements. -/
theorem ClosureOp.sigma_maps_closed {X : Type*} [Preorder X]
    (C : ClosureOp X) {σ : X → X}
    (hcomm : Function.Commute σ C.cl) {x : X} (hclosed : C.IsClosed x) :
    C.IsClosed (σ x) := by
  show C.cl (σ x) = σ x
  rw [← hcomm x, hclosed]

/-! ## Part III: Monoid Conservation -/

/-- **Monoid Conservation (cl ∘ σ)**: A charge invariant under σ and cl is
invariant under all iterated compositions of cl ∘ σ. -/
theorem monoid_conservation_cl_σ {X Γ : Type*}
    (cl σ : X → X) (Q : X → Γ)
    (hQ_σ : ∀ x, Q (σ x) = Q x)
    (hQ_cl : ∀ x, Q (cl x) = Q x)
    (n : ℕ) (x : X) : Q ((cl ∘ σ)^[n] x) = Q x := by
  induction n generalizing x with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    simp only [Function.comp_apply]
    rw [hQ_cl, hQ_σ, ih]

/-- **Monoid Conservation (σ ∘ cl)**: Analogous for σ ∘ cl compositions. -/
theorem monoid_conservation_σ_cl {X Γ : Type*}
    (cl σ : X → X) (Q : X → Γ)
    (hQ_σ : ∀ x, Q (σ x) = Q x)
    (hQ_cl : ∀ x, Q (cl x) = Q x)
    (n : ℕ) (x : X) : Q ((σ ∘ cl)^[n] x) = Q x := by
  induction n generalizing x with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    simp only [Function.comp_apply]
    rw [hQ_σ, hQ_cl, ih]

/-- Mixed compositions preserve charge invariance. -/
theorem monoid_conservation_mixed {X Γ : Type*}
    (cl σ : X → X) (Q : X → Γ)
    (hQ_σ : ∀ x, Q (σ x) = Q x)
    (hQ_cl : ∀ x, Q (cl x) = Q x)
    (x : X) : Q (σ (cl x)) = Q x ∧ Q (cl (σ x)) = Q x :=
  ⟨by rw [hQ_σ, hQ_cl], by rw [hQ_cl, hQ_σ]⟩

/-! ## Part IV: Closure-Factored Conservation -/

/-- **Closure-Factored Conservation**: If cl commutes with τ and
Q₀ is conserved on closed elements, then Q₀ ∘ cl is fully conserved. -/
theorem closure_factored_conservation {X Γ : Type*} [Preorder X] [Preorder Γ]
    (C : ClosureOp X) (τ : X → X)
    (Q₀ : X → Γ)
    (hcl_τ : Function.Commute C.cl τ)
    (hQ₀_conserved : ∀ x, Q₀ (τ (C.cl x)) = Q₀ (C.cl x)) :
    ∀ x, Q₀ (C.cl (τ x)) = Q₀ (C.cl x) := by
  intro x
  rw [hcl_τ x]
  exact hQ₀_conserved x

/-! ## Part V: Main Conservation Theorem -/

/-- **Tropical Noether Theorem**: A charge that is invariant under both
symmetry σ and closure cl is conserved under any dynamics τ that equals
a composition of σ and cl.

This is the fundamental Noether principle in the idempotent setting:
σ-invariance + cl-invariance → τ-invariance when dynamics is generated
by the symmetry-closure monoid. -/
theorem tropical_noether {X Γ : Type*} [Preorder X]
    (C : ClosureOp X) (σ τ : X → X) (Q : X → Γ)
    (hQ_σ : ∀ x, Q (σ x) = Q x)
    (hQ_cl : ∀ x, Q (C.cl x) = Q x)
    (n : ℕ) (hτ : ∀ x, τ x = (C.cl ∘ σ)^[n] x) :
    ∀ x, Q (τ x) = Q x := by
  intro x
  rw [hτ x]
  exact monoid_conservation_cl_σ C.cl σ Q hQ_σ hQ_cl n x

/-! ## Part VI: Fixed-Point Charge for Finite Types -/

/-- The fixed-point indicator function. -/
def fixedPtIndicator {X : Type*} [DecidableEq X] (σ : X → X) : X → Bool :=
  fun x => decide (σ x = x)

/-- **Noether Correspondence** (Bool version): For bijective dynamics,
the fixed-point indicator is a conserved Bool-valued charge. -/
theorem noether_correspondence {X : Type*} [DecidableEq X]
    {σ τ : X → X}
    (hcomm : Function.Commute σ τ) (hbij : Function.Bijective τ) :
    ∀ x, fixedPtIndicator σ (τ x) = fixedPtIndicator σ x := by
  intro x
  simp only [fixedPtIndicator, decide_eq_decide]
  exact (fixedPt_iff hcomm hbij.injective x).symm

/-- **Noether Duality**: Establishes a bijection between the truth value
of fixed-point membership before and after dynamics. -/
theorem noether_duality {X : Type*} [DecidableEq X] [Fintype X]
    {τ : X → X} (hbij : Function.Bijective τ)
    (σ : X → X) (hcomm : Function.Commute σ τ) :
    ∀ x, decide (σ x = x) = decide (σ (τ x) = τ x) := by
  intro x
  simp only [decide_eq_decide]
  exact fixedPt_iff hcomm hbij.injective x

/-- **Fixed-Point Count Conservation**: The number of fixed points is
conserved — a natural-number-valued Noether charge. -/
theorem fixedPt_count_conserved {X : Type*} [DecidableEq X] [Fintype X]
    {σ τ : X → X} (hcomm : Function.Commute σ τ) (hbij : Function.Bijective τ) :
    (Finset.univ.filter (fun x => σ x = x)).card =
    (Finset.univ.filter (fun x => σ (τ x) = τ x)).card := by
  congr 1; ext x
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact fixedPt_iff hcomm hbij.injective x

/-! ## Part VII: Symmetry Monoid -/

/-- The identity is a closure symmetry. -/
def closureSymmetryId {X : Type*} [Preorder X] (C : ClosureOp X) (τ : X → X) :
    ClosureSymmetry X C τ where
  σ := id
  mono := monotone_id
  comm_τ := fun _ => rfl
  compat_cl := fun _ => le_refl _

/-- Closure symmetries with weak compatibility compose. -/
def closureSymmetryComp {X : Type*} [Preorder X] (C : ClosureOp X) (τ : X → X)
    (s₁ s₂ : ClosureSymmetry X C τ) :
    ClosureSymmetry X C τ where
  σ := s₁.σ ∘ s₂.σ
  mono := s₁.mono.comp s₂.mono
  comm_τ := s₁.comm_τ.comp_left s₂.comm_τ
  compat_cl := fun x =>
    le_trans (s₁.compat_cl (s₂.σ x)) (s₁.mono (s₂.compat_cl x))

/-- Strong symmetries compose. -/
def strongSymmetryComp {X : Type*} [Preorder X] (C : ClosureOp X) (τ : X → X)
    (s₁ s₂ : StrongClosureSymmetry X C τ) :
    StrongClosureSymmetry X C τ where
  σ := s₁.σ ∘ s₂.σ
  mono := s₁.mono.comp s₂.mono
  comm_τ := s₁.comm_τ.comp_left s₂.comm_τ
  compat_cl := by
    intro x; simp only [Function.comp_apply]
    rw [← s₁.comm_cl (s₂.σ x), ← s₂.comm_cl x]
  comm_cl := s₁.comm_cl.comp_left s₂.comm_cl

/-! ## Part VIII: Charge Algebra -/

/-- The supremum of two conserved charges is conserved. -/
theorem conserved_sup {X Γ : Type*} [Preorder X] [SemilatticeSup Γ]
    {τ : X → X} (Q₁ Q₂ : ConservedCharge X Γ τ) :
    ∀ x, (Q₁.Q x ⊔ Q₂.Q x) = (Q₁.Q (τ x) ⊔ Q₂.Q (τ x)) := by
  intro x; rw [Q₁.conserved x, Q₂.conserved x]

/-- Conserved charges compose with any function. -/
theorem conserved_comp {X Γ Δ : Type*} [Preorder X] [Preorder Γ] [Preorder Δ]
    {τ : X → X} (Q : ConservedCharge X Γ τ) (f : Γ → Δ) :
    ∀ x, f (Q.Q (τ x)) = f (Q.Q x) := by
  intro x; rw [Q.conserved x]

/-! ## Part IX: Certified Charge Extraction -/

/-- **Certified Extraction**: Given symmetries commuting with bijective dynamics,
extract conserved fixed-point indicators — all certified conserved. -/
theorem extractCharges_correct {X : Type*} [DecidableEq X]
    {τ : X → X} (hbij : Function.Bijective τ)
    (symmetries : Finset (X → X))
    (hcomm : ∀ σ ∈ symmetries, Function.Commute σ τ) :
    ∀ σ ∈ symmetries, ∀ x,
      fixedPtIndicator σ (τ x) = fixedPtIndicator σ x := by
  intro σ hσ
  exact noether_correspondence (hcomm σ hσ) hbij

/-- **Extraction Completeness**: Every Bool charge matching a
fixed-point indicator is captured. -/
theorem extraction_complete {X : Type*} [DecidableEq X]
    {σ τ : X → X}
    (hcomm : Function.Commute σ τ) (hbij : Function.Bijective τ)
    (Q : X → Bool) (hQ : Q = fixedPtIndicator σ) :
    ∀ x, Q (τ x) = Q x := by
  intro x; rw [hQ]; exact noether_correspondence hcomm hbij x

/-! ## Part X: Charge-to-Symmetry Reconstruction -/

/-- **Local Reconstruction**: The fixed-point set is exactly {x | Q(x) = true}. -/
theorem local_reconstruction {X : Type*} [DecidableEq X]
    {σ : X → X} (Q : X → Bool) (hQ : Q = fixedPtIndicator σ) :
    ∀ x, Q x = true ↔ σ x = x := by
  intro x; subst hQ; simp [fixedPtIndicator]

/-- **Charge Separates Symmetry Classes**: Distinct fixed-point profiles
yield distinct charges — injectivity of the Noether charge map. -/
theorem charge_separates {X : Type*} [DecidableEq X]
    {σ₁ σ₂ : X → X}
    (hdiff : ∃ x, (σ₁ x = x) ≠ (σ₂ x = x)) :
    fixedPtIndicator σ₁ ≠ fixedPtIndicator σ₂ := by
  intro heq
  obtain ⟨x, hx⟩ := hdiff
  have := congr_fun heq x
  simp [fixedPtIndicator] at this
  exact hx (propext this)

/-! ## Part XI: Weighted Charge Conservation -/

/-- **Weighted Charge**: A σ-invariant weight is conserved under σ-iterates. -/
theorem weighted_charge_iterate {X Γ : Type*}
    {σ : X → X} {w : X → Γ}
    (hw : ∀ x, w (σ x) = w x) (n : ℕ) :
    ∀ x, w (σ^[n] x) = w x := by
  intro x; induction n with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ', Function.comp_apply, hw, ih]

/-- If dynamics is an iterate of σ, then σ-invariant weights are conserved. -/
theorem weighted_charge_of_dynamics {X Γ : Type*}
    {σ τ : X → X} {w : X → Γ}
    (hw : ∀ x, w (σ x) = w x)
    (n : ℕ) (hτ : τ = σ^[n]) :
    ∀ x, w (τ x) = w x := by
  subst hτ; exact weighted_charge_iterate hw n

/-! ## Part XII: Full Noether Charge Data Construction -/

/-- Construct a complete Noether charge datum from a strong symmetry
and a base valuation satisfying invariance conditions. -/
noncomputable def noetherChargeDatum {X Γ : Type*} [Preorder X] [Preorder Γ]
    (C : ClosureOp X) (τ : X → X)
    (sym : StrongClosureSymmetry X C τ)
    (Q₀ : X → Γ) (hQ₀_mono : Monotone Q₀)
    (hQ₀_σ : ∀ x, Q₀ (sym.σ x) = Q₀ x)
    (hQ₀_τ : ∀ x, Q₀ (τ x) = Q₀ x) :
    NoetherChargeData X Γ C τ where
  sym := sym.toClosureSymmetry
  charge :=
    { Q := Q₀
      mono := hQ₀_mono
      conserved := hQ₀_τ }
  sym_invariant := hQ₀_σ

end IdempotentNoether