/-
# Tropical Monotone Circuits: Main Theorems

This file proves the core structural theorems for tropical monotone circuits:

1. **Monotonicity** — Tropical circuits compute monotone functions.
2. **Boolean Embedding** — Boolean monotone formulas embed soundly via threshold decoding.
3. **Normal Form** — Every circuit evaluates as the minimum of its normal-form affine family.
4. **Min-Max Duality** — Negation interconverts min-plus and max-plus semantics.
-/

import Tropical.Circuits.Defs

open Finset BigOperators

noncomputable section

/-! ## Theorem 1: Monotonicity of Tropical Monotone Circuits -/

/-- Tropical monotone circuits compute coordinatewise monotone functions:
if `x i ≤ y i` for all inputs `i`, then `C.eval x ≤ C.eval y`. -/
theorem TropCircuit.eval_mono_pointwise
    {n : ℕ} (C : TropCircuit n) {x y : Fin n → ℝ}
    (hxy : ∀ i, x i ≤ y i) :
    TropCircuit.eval C x ≤ TropCircuit.eval C y := by
  induction C with
  | var i => exact hxy i
  | const c => rfl
  | add a b iha ihb => simp [TropCircuit.eval]; exact add_le_add iha ihb
  | min a b iha ihb => exact min_le_min iha ihb

/-! ## Theorem 2: Boolean-Tropical Embedding -/

/-- `encodeBool` produces values in `{0, 1}`. -/
theorem encodeBool_mem_zero_one (b : Bool) :
    encodeBool b = 0 ∨ encodeBool b = 1 := by
  cases b <;> simp [encodeBool]

/-- `encodeBool` always produces nonneg values. -/
theorem encodeBool_nonneg (b : Bool) : 0 ≤ encodeBool b := by
  cases b <;> simp [encodeBool]

/-
On Boolean-encoded inputs, the tropical evaluation is always nonneg.
-/
theorem eval_nonneg_of_bool_input
    {n : ℕ} (φ : BoolMonoFormula n) (σ : Fin n → Bool) :
    0 ≤ TropCircuit.eval (φ.toTropCircuit) (fun i => encodeBool (σ i)) := by
  induction' φ with a b ha hb ih_b;
  · exact encodeBool_nonneg _;
  · exact le_rfl;
  · exact zero_le_one;
  · exact TropCircuit.eval_add b.toTropCircuit ha.toTropCircuit _ ▸ add_nonneg hb ih_b;
  · exact le_min ‹_› ‹_›

/-
The decoded tropical evaluation equals the Boolean evaluation.
This is the corrected bridge theorem: using `decodeBool` (threshold at 0)
to decode the tropical value gives exactly the Boolean formula semantics.

The key insight is that on `{0,1}`-valued inputs:
- `min` correctly models `or` (both exactly on {0,1} values)
- `+` correctly models `and` after thresholding (sum is 0 iff both are 0)
-/
theorem boolean_formula_tropical_sound
    {n : ℕ} (φ : BoolMonoFormula n) (σ : Fin n → Bool) :
    decodeBool (TropCircuit.eval (φ.toTropCircuit) (fun i => encodeBool (σ i)))
      = BoolMonoFormula.eval φ σ := by
  induction' φ with _ _ ih1 ih2 <;> simp +decide [ *, decodeBool ];
  · erw [ TropCircuit.eval_var ] ; by_cases hi : σ ‹_› <;> simp +decide [ hi ];
    · simp +decide [ encodeBool, BoolMonoFormula.eval, hi ];
    · simp +decide [ encodeBool, BoolMonoFormula.eval ];
      grind;
  · simp +decide [ BoolMonoFormula.toTropCircuit ];
    rfl;
  · simp +decide [ BoolMonoFormula.eval, BoolMonoFormula.toTropCircuit ];
  · rename_i a ha;
    -- By definition of `decodeBool`, we know that `decodeBool (x) = true` if and only if `x ≤ 0`.
    have h_decode : ∀ x : ℝ, decodeBool x = (x ≤ 0) := by
      unfold decodeBool; aesop;
    simp_all +decide [ BoolMonoFormula.eval ];
    erw [ show ( a.and ih1 ).toTropCircuit = TropCircuit.add ( a.toTropCircuit ) ( ih1.toTropCircuit ) from rfl ] ; simp +decide [ *, TropCircuit.eval ] ;
    have h_nonneg : 0 ≤ a.toTropCircuit.eval (fun i => encodeBool (σ i)) ∧ 0 ≤ ih1.toTropCircuit.eval (fun i => encodeBool (σ i)) := by
      exact ⟨ eval_nonneg_of_bool_input a σ, eval_nonneg_of_bool_input ih1 σ ⟩;
    grind;
  · rename_i a b ha hb;
    -- By definition of `toTropCircuit`, we have `(a.or b).toTropCircuit = TropCircuit.min a.toTropCircuit b.toTropCircuit`.
    have h_or : (a.or b).toTropCircuit = TropCircuit.min a.toTropCircuit b.toTropCircuit := by
      rfl;
    unfold decodeBool at * ; aesop

/-! ## Theorem 3: Normal Form -/

/-- The normal form of any circuit is nonempty. -/
theorem normalForms_card_pos {n : ℕ} (C : TropCircuit n) :
    0 < Multiset.card (normalForms C) := by
  induction C <;> simp_all [normalForms]

/-
For any `a` in `normalForms C`, the circuit evaluation is at most `a.eval x`.
-/
theorem eval_le_normalForm_eval
    {n : ℕ} (C : TropCircuit n) (x : Fin n → ℝ)
    (a : TropAffine n) (ha : a ∈ normalForms C) :
    TropCircuit.eval C x ≤ TropAffine.eval a x := by
  -- By induction on the structure of C, we consider the following cases:
  induction' C with C1 C2 ih1 ih2 generalizing a;
  · unfold normalForms at ha;
    simp_all +decide [ TropAffine.eval ];
    rw [ Finset.sum_eq_single C1 ] <;> aesop;
  · cases ha;
    · simp [TropCircuit.eval, TropAffine.eval];
    · contradiction;
  · -- By definition of normalForms, we know that a is in the bind of the normalForms of ih1 and ih2.
    obtain ⟨fa, fb, hfa, hfb, rfl⟩ : ∃ fa fb, fa ∈ normalForms ih1 ∧ fb ∈ normalForms ih2 ∧ a = ⟨fun j => fa.coeff j + fb.coeff j, fa.const + fb.const⟩ := by
      simp_all +decide [ normalForms ];
      grind;
    convert add_le_add ( ‹∀ a ∈ normalForms ih1, ih1.eval x ≤ a.eval x› fa hfa ) ( ‹∀ a ∈ normalForms ih2, ih2.eval x ≤ a.eval x› fb hfb ) using 1;
    unfold TropAffine.eval; simp +decide [ Finset.sum_add_distrib, add_mul ] ; ring;
  · rename_i C1 C2 ih1 ih2;
    -- By definition of `normalForms`, we know that `a` is in either `normalForms C1` or `normalForms C2`.
    have ha_cases : a ∈ normalForms C1 ∨ a ∈ normalForms C2 := by
      exact Multiset.mem_add.mp ha;
    cases ha_cases <;> [ exact le_trans ( min_le_left _ _ ) ( ih1 _ ‹_› ) ; exact le_trans ( min_le_right _ _ ) ( ih2 _ ‹_› ) ]

/-
There exists an affine form in `normalForms C` that achieves the circuit's evaluation.
-/
theorem eval_eq_some_normalForm
    {n : ℕ} (C : TropCircuit n) (x : Fin n → ℝ) :
    ∃ a ∈ normalForms C,
      TropCircuit.eval C x = TropAffine.eval a x := by
  induction' C with a b ih_a ih_b2 generalizing x;
  · unfold TropCircuit.eval TropAffine.eval;
    simp +decide [ normalForms ];
    rw [ Finset.sum_eq_single a ] <;> aesop;
  · exact ⟨ ⟨ fun _ => 0, b ⟩, by tauto, by simp +decide [ TropAffine.eval, TropCircuit.eval ] ⟩;
  · rename_i ih_a ih_b2;
    obtain ⟨ a, ha, ha' ⟩ := ih_a x; obtain ⟨ b, hb, hb' ⟩ := ih_b2 x; use ⟨ fun j => a.coeff j + b.coeff j, a.const + b.const ⟩ ; simp_all +decide [ TropAffine.eval ] ;
    simp_all +decide [ add_mul, Finset.sum_add_distrib, add_assoc, add_left_comm ];
    exact Multiset.mem_bind.mpr ⟨ a, ha, Multiset.mem_map.mpr ⟨ b, hb, rfl ⟩ ⟩;
  · rename_i a b ih_a ih_b;
    cases le_total ( a.eval x ) ( b.eval x ) <;> [ obtain ⟨ a', ha', ha'' ⟩ := ih_a x; obtain ⟨ b', hb', hb'' ⟩ := ih_b x ] <;> simp_all +decide [ normalForms ];
    · exact ⟨ a', Or.inl ha', rfl ⟩;
    · exact ⟨ b', Or.inr hb', rfl ⟩

/-! ## Theorem 4: Min-Max Duality -/

/-- Duality theorem: a min-plus circuit on `x` equals the negation of its
dual max-plus circuit on `−x`. -/
theorem eval_duality
    {n : ℕ} (C : TropCircuit n) (x : Fin n → ℝ) :
    TropCircuit.eval C x =
      - (MaxTropCircuit.eval (C.dual) (fun i => - x i)) := by
  induction C with
  | var i => simp [TropCircuit.eval, TropCircuit.dual, MaxTropCircuit.eval]
  | const c => simp [TropCircuit.eval, TropCircuit.dual, MaxTropCircuit.eval]
  | add a b iha ihb =>
    simp only [TropCircuit.eval, TropCircuit.dual, MaxTropCircuit.eval]
    rw [iha, ihb]; ring
  | min a b iha ihb =>
    simp only [TropCircuit.eval, TropCircuit.dual, MaxTropCircuit.eval]
    rw [iha, ihb, neg_sup]

/-! ## Additional structural results -/

/-- Size is always positive. -/
theorem TropCircuit.size_pos {n : ℕ} (C : TropCircuit n) :
    0 < C.size := by
  cases C <;> simp [TropCircuit.size]

end