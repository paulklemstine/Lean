import Tropical.SmoothSelfHintInformationBounds

/-!
# Exactly when does the symmetric statistic leak?

The asymmetric statistic never leaks (`miF_asym_zero`), whatever the target set `A`.
For the symmetric statistic the answer depends on `A`, and this file gives the complete
criterion: the leak vanishes **iff the fibre counts are constant**, i.e. iff the
autocorrelation `n ↦ |A ∩ n·A⁻¹|` of `A` is constant — the defining property of a
perfect difference set (`sym_fiber_card_incl_excl` turns one into the other).

* `SmoothSelfHint.symJointG` — the joint law of (residue `n`, symmetric event) for a
  uniformly random ordered pair in a finite group.
* `SmoothSelfHint.symJointG_sum_one` — it is a probability distribution.
* `SmoothSelfHint.miF_symJointG_eq_zero_iff` — **the classification**:
  `I = 0 ↔ ∀ n m, |symFiber A n| = |symFiber A m|`.
* `SmoothSelfHint.miF_symJointG_eq_zero_iff_autocorrelation` — the same criterion phrased
  through the autocorrelation `|A ∩ n·A⁻¹|`.
* `SmoothSelfHint.miF_symJointG_pos_singleton` — for the singleton `A = {1}` in a group
  with at least two elements the criterion fails, so the leak is strictly positive: the
  arithmetic case `A = {1} ⊆ (ZMod l)ˣ` of the divisibility dichotomy.
-/

open Finset

namespace SmoothSelfHint

section Group

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

theorem symFiber_card_le (A : Finset G) (n : G) : (symFiber A n).card ≤ Fintype.card G := by
  have hsub : symFiber A n ⊆ (Finset.univ : Finset (G × G)).filter (fun ab => ab.1 * ab.2 = n) := by
    intro ab hab
    simp only [symFiber, Finset.mem_filter] at hab
    simp [hab.2.1]
  calc (symFiber A n).card
      ≤ ((Finset.univ : Finset (G × G)).filter (fun ab => ab.1 * ab.2 = n)).card :=
        Finset.card_le_card hsub
    _ = Fintype.card G := fiber_card n

/-- The joint law of (the product `n = a·b`, the symmetric event `a ∈ A ∨ b ∈ A`) for a
uniformly random ordered pair `(a, b) ∈ G × G`. -/
noncomputable def symJointG (A : Finset G) (n : G) (e : Bool) : ℝ :=
  (cond e ((symFiber A n).card : ℝ) ((Fintype.card G : ℝ) - (symFiber A n).card))
    / (Fintype.card G : ℝ) ^ 2

omit [DecidableEq G] in
theorem card_pos_real : (0 : ℝ) < (Fintype.card G : ℝ) := by
  exact_mod_cast (Fintype.card_pos : 0 < Fintype.card G)

theorem symJointG_nonneg (A : Finset G) (n : G) (e : Bool) : 0 ≤ symJointG A n e := by
  have hle : ((symFiber A n).card : ℝ) ≤ (Fintype.card G : ℝ) := by
    exact_mod_cast symFiber_card_le A n
  unfold symJointG
  cases e
  · simp only [Bool.cond_false]
    exact div_nonneg (by linarith) (by positivity)
  · simp only [Bool.cond_true]
    exact div_nonneg (by positivity) (by positivity)

theorem symJointG_row (A : Finset G) (n : G) :
    ∑ e : Bool, symJointG A n e = 1 / (Fintype.card G : ℝ) := by
  have hg : (0 : ℝ) < (Fintype.card G : ℝ) := card_pos_real
  rw [Fintype.sum_bool]
  unfold symJointG
  simp only [Bool.cond_true, Bool.cond_false]
  field_simp
  ring

theorem symJointG_sum_one (A : Finset G) :
    ∑ n : G, ∑ e : Bool, symJointG A n e = 1 := by
  have hg : (0 : ℝ) < (Fintype.card G : ℝ) := card_pos_real
  rw [Finset.sum_congr rfl (fun n _ => symJointG_row A n), Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul]
  field_simp

theorem symJointG_col_true (A : Finset G) :
    ∑ n : G, symJointG A n true
      = (∑ n : G, ((symFiber A n).card : ℝ)) / (Fintype.card G : ℝ) ^ 2 := by
  unfold symJointG
  simp only [Bool.cond_true]
  rw [← Finset.sum_div]

/-- If all symmetric fibre counts agree, the joint law is a product law, so the leak is
exactly zero. -/
theorem miF_symJointG_eq_zero_of_const (A : Finset G) (k : ℕ)
    (hk : ∀ n : G, (symFiber A n).card = k) : miF (symJointG A) = 0 := by
  have hg : (0 : ℝ) < (Fintype.card G : ℝ) := card_pos_real
  have hkle : (k : ℝ) ≤ (Fintype.card G : ℝ) := by
    have := symFiber_card_le A (1 : G)
    rw [hk 1] at this
    exact_mod_cast this
  have hprod : symJointG A = fun (n : G) (e : Bool) =>
      (1 / (Fintype.card G : ℝ)) *
        (cond e ((k : ℝ) / (Fintype.card G : ℝ))
          (((Fintype.card G : ℝ) - k) / (Fintype.card G : ℝ))) := by
    funext n e
    unfold symJointG
    rw [hk n]
    cases e <;> simp only [Bool.cond_true, Bool.cond_false] <;> field_simp
  rw [hprod]
  refine miF_of_product _ _ ?_ ?_
  · rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp
  · rw [Fintype.sum_bool]
    simp only [Bool.cond_true, Bool.cond_false]
    field_simp
    ring

private theorem aux_div_mul (c S : ℝ) (hc : c ≠ 0) : (1 / c) * (S / c ^ 2) = S / c ^ 3 := by
  field_simp

private theorem aux_div_cancel {x y c : ℝ} (hc : c ≠ 0) (h : x / c ^ 2 = y / c ^ 2) : x = y := by
  field_simp at h
  exact h

/-- If two symmetric fibre counts differ, the joint law is not a product law, so the leak
is strictly positive. -/
theorem miF_symJointG_pos_of_ne (A : Finset G) {n₀ m₀ : G}
    (hne : (symFiber A n₀).card ≠ (symFiber A m₀).card) : 0 < miF (symJointG A) := by
  have hg : (0 : ℝ) < (Fintype.card G : ℝ) := card_pos_real
  have hgne : (Fintype.card G : ℝ) ≠ 0 := ne_of_gt hg
  have hcell : ∀ n : G, symJointG A n true
      = ((symFiber A n).card : ℝ) / (Fintype.card G : ℝ) ^ 2 := by
    intro n
    unfold symJointG
    simp only [Bool.cond_true]
  have hfactor : ∀ n : G, (∑ e : Bool, symJointG A n e) * (∑ x : G, symJointG A x true)
      = (∑ x : G, ((symFiber A x).card : ℝ)) / (Fintype.card G : ℝ) ^ 3 := by
    intro n
    rw [symJointG_row A n, symJointG_col_true A, aux_div_mul _ _ hgne]
  by_cases hfac : symJointG A n₀ true
      = (∑ e : Bool, symJointG A n₀ e) * (∑ x : G, symJointG A x true)
  · refine miF_pos_of_not_product _ (symJointG_nonneg A) (symJointG_sum_one A)
      (x₀ := m₀) (y₀ := true) ?_
    intro hfac'
    rw [hcell, hfactor] at hfac hfac'
    have heq : ((symFiber A n₀).card : ℝ) / (Fintype.card G : ℝ) ^ 2
        = ((symFiber A m₀).card : ℝ) / (Fintype.card G : ℝ) ^ 2 := by
      rw [hfac, hfac']
    exact hne (by exact_mod_cast aux_div_cancel hgne heq)
  · exact miF_pos_of_not_product _ (symJointG_nonneg A) (symJointG_sum_one A)
      (x₀ := n₀) (y₀ := true) hfac

/-- **Classification of the symmetric leak.**  It vanishes exactly when the symmetric
fibre counts are constant. -/
theorem miF_symJointG_eq_zero_iff (A : Finset G) :
    miF (symJointG A) = 0 ↔ ∀ n m : G, (symFiber A n).card = (symFiber A m).card := by
  constructor
  · intro h n m
    by_contra hne
    exact absurd h (ne_of_gt (miF_symJointG_pos_of_ne A hne))
  · intro h
    exact miF_symJointG_eq_zero_of_const A ((symFiber A 1).card) (fun n => h n 1)

/-- The same criterion in terms of the autocorrelation of `A`: the leak vanishes exactly
when `|A ∩ n·A⁻¹|` does not depend on `n` — the difference-set condition. -/
theorem miF_symJointG_eq_zero_iff_autocorrelation (A : Finset G) :
    miF (symJointG A) = 0 ↔
      ∀ n m : G, (A ∩ A.image (fun b => n * b⁻¹)).card = (A ∩ A.image (fun b => m * b⁻¹)).card := by
  have hcard : ∀ n : G, (symFiber A n).card = 2 * A.card - (A ∩ A.image (fun b => n * b⁻¹)).card :=
    fun n => sym_fiber_card_incl_excl A n
  have hle : ∀ n : G, (A ∩ A.image (fun b => n * b⁻¹)).card ≤ A.card := fun n =>
    Finset.card_le_card Finset.inter_subset_left
  rw [miF_symJointG_eq_zero_iff]
  constructor
  · intro h n m
    have := h n m
    rw [hcard n, hcard m] at this
    have h1 := hle n
    have h2 := hle m
    omega
  · intro h n m
    rw [hcard n, hcard m, h n m]

/-- For a singleton target in a group with more than one element the criterion fails, so
the symmetric statistic leaks: this is the divisibility dichotomy for `A = {1}`. -/
theorem miF_symJointG_pos_singleton (h : 1 < Fintype.card G) :
    0 < miF (symJointG ({1} : Finset G)) := by
  obtain ⟨x, hx⟩ := Fintype.exists_ne_of_one_lt_card h (1 : G)
  refine miF_symJointG_pos_of_ne _ (n₀ := 1) (m₀ := x) ?_
  rw [sym_fiber_card_one, sym_fiber_card_one, if_pos rfl, if_neg hx]
  omega

end Group

/-- The arithmetic instance: for every odd prime `l`, the symmetric divisibility event
leaks strictly positive information about `N mod l`. -/
theorem miF_symJointG_pos_units (l : ℕ) [Fact (Nat.Prime l)] (hl : 2 < l) :
    0 < miF (symJointG ({1} : Finset (ZMod l)ˣ)) := by
  refine miF_symJointG_pos_singleton ?_
  rw [card_units_zmod l]
  omega

end SmoothSelfHint