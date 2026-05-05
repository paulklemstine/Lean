import Mathlib

/-! # Kleene Fixed-Point Theorem: Abstract ω-Chain Theory

This file develops the Kleene fixed-point theorem for monotone, Scott-continuous
functions on complete lattices. The key results are:

1. **Monotonicity of the approximation chain**: `fun n => f^[n] ⊥` is monotone.
2. **Fixed-point property**: Under Scott continuity, `sSup (range (fun n => f^[n] ⊥))`
   is a fixed point of `f`.
3. **Least pre-fixed point**: This supremum equals `sInf {x | f x ≤ x}`.
4. **Stabilization/collapse**: If `f^[N+1] ⊥ = f^[N] ⊥`, the supremum collapses
   to `f^[N] ⊥`.

These form the order-theoretic backbone of the Lawvere–Kleene fixed-point
stratification for guarded trace semantics.
-/

open Set Function

noncomputable section

/-! ## Scott continuity -/

/-- Scott continuity for functions on complete lattices: a monotone function
that preserves directed suprema of ω-chains. -/
structure OmegaScottContinuous {α : Type*} [CompleteLattice α] (f : α → α) : Prop where
  /-- The function is monotone. -/
  mono : Monotone f
  /-- The function preserves suprema of monotone ω-chains. -/
  preserves_sSup_chain :
    ∀ c : ℕ → α, Monotone c →
      f (sSup (range c)) = sSup (range (f ∘ c))

/-! ## Monotonicity of the Kleene chain -/

/-- The Kleene chain `fun n => f^[n] ⊥` is monotone (non-decreasing). -/
theorem kleene_chain_mono {α : Type*} [CompleteLattice α]
    {f : α → α} (hf : Monotone f) :
    Monotone (fun n : ℕ => f^[n] (⊥ : α)) := by
  apply monotone_nat_of_le_succ
  intro n
  induction n with
  | zero =>
    show ⊥ ≤ f ⊥
    exact bot_le
  | succ n ih =>
    have h1 : f^[n + 1] (⊥ : α) = f (f^[n] ⊥) := iterate_succ_apply' f n ⊥
    have h2 : f^[n + 2] (⊥ : α) = f (f^[n + 1] ⊥) := iterate_succ_apply' f (n + 1) ⊥
    rw [h1, h2]
    exact hf ih

/-! ## Shifting lemma -/

/-- The range of the shifted chain `fun n => c (n+1)` has the same supremum
as the original chain when the chain is monotone. -/
lemma sSup_range_shift {α : Type*} [CompleteLattice α]
    {c : ℕ → α} (hc : Monotone c) :
    sSup (range (fun n : ℕ => c (n + 1))) = sSup (range c) := by
  apply le_antisymm
  · exact sSup_le_sSup (range_comp_subset_range _ _)
  · apply sSup_le
    rintro x ⟨n, rfl⟩
    exact le_trans (hc (Nat.le_succ n)) (le_sSup ⟨n, rfl⟩)

/-! ## The Kleene fixed-point equation -/

/-- **Kleene Fixed-Point Theorem (fixed-point equation)**:
Under Scott continuity, `sSup (range (fun n => f^[n] ⊥))` is a fixed point of `f`. -/
theorem kleene_fixed_point {α : Type*} [CompleteLattice α]
    {f : α → α} (hcont : OmegaScottContinuous f) :
    f (sSup (range (fun n : ℕ => f^[n] (⊥ : α)))) =
      sSup (range (fun n : ℕ => f^[n] (⊥ : α))) := by
  rw [hcont.preserves_sSup_chain _ (kleene_chain_mono hcont.mono)]
  show sSup (range (fun n => f (f^[n] (⊥ : α)))) = sSup (range (fun n => f^[n] (⊥ : α)))
  have : (fun n => f (f^[n] (⊥ : α))) = (fun n => f^[n + 1] (⊥ : α)) := by
    ext n; simp [iterate_succ_apply']
  rw [this]
  exact sSup_range_shift (kleene_chain_mono hcont.mono)

/-! ## Least pre-fixed point -/

/-- Every finite approximant is below any pre-fixed point. -/
lemma iterate_bot_le_of_prefixed {α : Type*} [CompleteLattice α]
    {f : α → α} (hf : Monotone f) {x : α} (hx : f x ≤ x) :
    ∀ n, f^[n] (⊥ : α) ≤ x := by
  intro n
  induction n with
  | zero => exact bot_le
  | succ n ih =>
    calc f^[n + 1] (⊥ : α) = f (f^[n] ⊥) := iterate_succ_apply' f n ⊥
    _ ≤ f x := hf ih
    _ ≤ x := hx

/-- The supremum of the Kleene chain is below any pre-fixed point. -/
theorem sSup_kleene_le_of_prefixed {α : Type*} [CompleteLattice α]
    {f : α → α} (hf : Monotone f) {x : α} (hx : f x ≤ x) :
    sSup (range (fun n : ℕ => f^[n] (⊥ : α))) ≤ x :=
  sSup_le (fun _ ⟨n, hn⟩ => hn ▸ iterate_bot_le_of_prefixed hf hx n)

/-- **Kleene Fixed-Point Theorem (least pre-fixed point)**:
The supremum of the Kleene chain equals the infimum of pre-fixed points. -/
theorem kleene_lfp {α : Type*} [CompleteLattice α]
    {f : α → α} (hcont : OmegaScottContinuous f) :
    sSup (range (fun n : ℕ => f^[n] (⊥ : α))) = sInf {x | f x ≤ x} := by
  apply le_antisymm
  · exact le_sInf (fun x hx => sSup_kleene_le_of_prefixed hcont.mono hx)
  · apply sInf_le
    show f (sSup (range (fun n => f^[n] (⊥ : α)))) ≤ sSup (range (fun n => f^[n] (⊥ : α)))
    exact le_of_eq (kleene_fixed_point hcont)

/-- The Kleene fixed point is below any fixed point of `f`. -/
theorem kleene_lfp_le {α : Type*} [CompleteLattice α]
    {f : α → α} (hf : Monotone f) {x : α} (hx : f x = x) :
    sSup (range (fun n : ℕ => f^[n] (⊥ : α))) ≤ x :=
  sSup_kleene_le_of_prefixed hf (le_of_eq hx)

/-! ## Stabilization / Collapse -/

/-
If the chain stabilizes at step N, all subsequent iterates are constant.
-/
lemma stabilization_tail_constant {α : Type*} [CompleteLattice α]
    {f : α → α} (_hf : Monotone f)
    {N : ℕ} (hstab : f^[N + 1] (⊥ : α) = f^[N] ⊥) :
    ∀ k, f^[N + k] (⊥ : α) = f^[N] ⊥ := by
  intro k;
  induction' k with k ih;
  · rfl;
  · rw [ Nat.add_succ, Function.iterate_succ_apply', ih, ← Function.iterate_succ_apply' f N ⊥, hstab ]

/-
**Collapse Theorem**: If the Kleene chain stabilizes at step N,
the supremum collapses to the N-th approximant.
-/
theorem sSup_kleene_eq_of_stabilization {α : Type*} [CompleteLattice α]
    {f : α → α} (hf : Monotone f)
    {N : ℕ} (hstab : f^[N + 1] (⊥ : α) = f^[N] ⊥) :
    sSup (range (fun n : ℕ => f^[n] (⊥ : α))) = f^[N] ⊥ := by
  refine' le_antisymm _ _;
  · grind +suggestions;
  · exact le_sSup ⟨ N, rfl ⟩

/-- **Stabilization implies fixed point**: If the chain stabilizes at N,
then `f^[N] ⊥` is a fixed point of `f`. -/
theorem stabilization_is_fixed_point {α : Type*} [CompleteLattice α]
    {f : α → α}
    {N : ℕ} (hstab : f^[N + 1] (⊥ : α) = f^[N] ⊥) :
    f (f^[N] (⊥ : α)) = f^[N] ⊥ := by
  have : f (f^[N] (⊥ : α)) = f^[N + 1] (⊥ : α) := (iterate_succ_apply' f N ⊥).symm
  rw [this]
  exact hstab

end