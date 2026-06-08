/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Generation of SL₂(𝔽_p) by Unipotent Matrices

This file proves that the upper and lower unipotent matrices u = [[1,1],[0,1]]
and v = [[1,0],[1,1]] generate the full special linear group SL₂(𝔽_p)
for every odd prime p via Gaussian elimination.

## Main Results

* `sl2_closure_unipotent_eq_top` — u and v generate all of SL₂(𝔽_p) for odd p
* `sl2_upper_mem_closure` — all upper unipotents are in ⟨u,v⟩
* `sl2_lower_mem_closure` — all lower unipotents are in ⟨u,v⟩
* `sl2_weyl_mem_closure` — the Weyl element [[0,-1],[1,0]] is in ⟨u,v⟩
* `sl2_gaussian_factorization` — SL₂ Gaussian elimination factorization

## Keywords

SL₂(𝔽_p), generation, unipotent matrices, Gaussian elimination
-/
import Mathlib
import Pythagorean.CayleyExpander.SL2Defs

open Matrix Finset BigOperators

/-! ## Basic setup -/

abbrev SL2FpGroup (p : ℕ) [Fact p.Prime] := SpecialLinearGroup (Fin 2) (ZMod p)

noncomputable def sl2_u_elem (p : ℕ) [Fact p.Prime] : SL2FpGroup p :=
  ⟨sl2_u_mat p, sl2_u_mat_det p⟩

noncomputable def sl2_v_elem (p : ℕ) [Fact p.Prime] : SL2FpGroup p :=
  ⟨sl2_v_mat p, sl2_v_mat_det p⟩

noncomputable def sl2UV (p : ℕ) [Fact p.Prime] : Subgroup (SL2FpGroup p) :=
  Subgroup.closure ({sl2_u_elem p, sl2_v_elem p} : Set (SL2FpGroup p))

theorem sl2_u_mem_closure (p : ℕ) [Fact p.Prime] : sl2_u_elem p ∈ sl2UV p :=
  Subgroup.subset_closure (Set.mem_insert _ _)

theorem sl2_v_mem_closure (p : ℕ) [Fact p.Prime] : sl2_v_elem p ∈ sl2UV p :=
  Subgroup.subset_closure (Set.mem_insert_iff.mpr (Or.inr (Set.mem_singleton _)))

theorem sl2_u_zpow_mem_closure (p : ℕ) [Fact p.Prime] (n : ℤ) :
    sl2_u_elem p ^ n ∈ sl2UV p :=
  Subgroup.zpow_mem _ (sl2_u_mem_closure p) n

theorem sl2_v_zpow_mem_closure (p : ℕ) [Fact p.Prime] (n : ℤ) :
    sl2_v_elem p ^ n ∈ sl2UV p :=
  Subgroup.zpow_mem _ (sl2_v_mem_closure p) n

/-! ## SL₂ element constructors -/

/-- Upper unipotent [[1,a],[0,1]] as an SL₂ element. -/
noncomputable def sl2_upper (p : ℕ) [Fact p.Prime] (a : ZMod p) : SL2FpGroup p :=
  ⟨!![1, a; 0, 1], by simp [det_fin_two]⟩

/-- Lower unipotent [[1,0],[a,1]] as an SL₂ element. -/
noncomputable def sl2_lower (p : ℕ) [Fact p.Prime] (a : ZMod p) : SL2FpGroup p :=
  ⟨!![1, 0; a, 1], by simp [det_fin_two]⟩

/-! ## Upper/lower unipotent membership in closure -/

/-
u^n gives the upper unipotent with parameter n.
-/
theorem sl2_u_elem_pow_val (p : ℕ) [Fact p.Prime] (n : ℕ) :
    (sl2_u_elem p ^ n).1 = !![1, (n : ZMod p); 0, 1] := by
  induction n <;> simp_all +decide [ pow_succ', mul_assoc ];
  · exact Matrix.one_fin_two;
  · simp +decide [ ← Matrix.ext_iff, Fin.forall_fin_two, sl2_u_elem, sl2_u_mat ]

/-
v^n gives the lower unipotent with parameter n.
-/
theorem sl2_v_elem_pow_val (p : ℕ) [Fact p.Prime] (n : ℕ) :
    (sl2_v_elem p ^ n).1 = !![1, 0; (n : ZMod p), 1] := by
  refine' Nat.recOn n _ _ <;> simp_all +decide [ pow_succ, mul_assoc ];
  · exact Matrix.one_fin_two;
  · simp +decide [ ← List.ofFn_inj, sl2_v_elem ];
    simp +decide [ sl2_v_mat, Matrix.vecMul ]

/-- u^(a.val) equals the upper unipotent with parameter a. -/
theorem sl2_u_pow_eq_upper (p : ℕ) [Fact p.Prime] (a : ZMod p) :
    sl2_u_elem p ^ (ZMod.val a) = sl2_upper p a := by
  apply Subtype.ext
  rw [sl2_u_elem_pow_val]
  simp [sl2_upper]

/-- v^(a.val) equals the lower unipotent with parameter a. -/
theorem sl2_v_pow_eq_lower (p : ℕ) [Fact p.Prime] (a : ZMod p) :
    sl2_v_elem p ^ (ZMod.val a) = sl2_lower p a := by
  apply Subtype.ext
  rw [sl2_v_elem_pow_val]
  simp [sl2_lower]

/-- All upper unipotent elements are in the closure of {u,v}. -/
theorem sl2_upper_mem_closure (p : ℕ) [Fact p.Prime] (a : ZMod p) :
    sl2_upper p a ∈ sl2UV p := by
  rw [← sl2_u_pow_eq_upper]
  exact Subgroup.pow_mem _ (sl2_u_mem_closure p) _

/-- All lower unipotent elements are in the closure of {u,v}. -/
theorem sl2_lower_mem_closure (p : ℕ) [Fact p.Prime] (a : ZMod p) :
    sl2_lower p a ∈ sl2UV p := by
  rw [← sl2_v_pow_eq_lower]
  exact Subgroup.pow_mem _ (sl2_v_mem_closure p) _

/-! ## Weyl element -/

/-- The Weyl element w = [[0,-1],[1,0]] of SL₂. -/
noncomputable def sl2_weyl (p : ℕ) [Fact p.Prime] : SL2FpGroup p :=
  ⟨!![0, -1; 1, 0], by simp [det_fin_two]⟩

/-- The Weyl element equals v · u⁻¹ · v.
    Computed via: adjugate [[1,1],[0,1]] = [[1,-1],[0,1]], then
    [[1,0],[1,1]] * [[1,-1],[0,1]] * [[1,0],[1,1]] = [[0,-1],[1,0]]. -/
theorem sl2_weyl_eq_vuinvv (p : ℕ) [Fact p.Prime] :
    sl2_weyl p = sl2_v_elem p * (sl2_u_elem p)⁻¹ * sl2_v_elem p := by
  apply Subtype.ext
  -- For SpecialLinearGroup, g⁻¹.1 = adjugate g.1 (by rfl)
  simp only [SpecialLinearGroup.coe_mul, adjugate_fin_two,
    sl2_weyl, sl2_v_elem, sl2_u_elem, sl2_v_mat, sl2_u_mat]
  ext i j; fin_cases i <;> fin_cases j <;> simp [mul_apply, Fin.sum_univ_two] <;> ring

/-- The Weyl element is in the closure of {u,v}. -/
theorem sl2_weyl_mem_closure (p : ℕ) [Fact p.Prime] :
    sl2_weyl p ∈ sl2UV p := by
  rw [sl2_weyl_eq_vuinvv]
  exact Subgroup.mul_mem _ (Subgroup.mul_mem _ (sl2_v_mem_closure p)
    (Subgroup.inv_mem _ (sl2_u_mem_closure p))) (sl2_v_mem_closure p)

/-! ## Gaussian elimination factorization -/

/-
For c ≠ 0, every matrix [[a,b],[c,d]] with ad-bc=1 factors as
    upper((a-1)/c) · lower(c) · upper((d-1)/c).

    This is the Gaussian elimination step for SL₂: every element with
    nonzero lower-left entry can be decomposed into three unipotent factors.
-/
theorem sl2_gaussian_factorization (p : ℕ) [Fact p.Prime]
    (a b c d : ZMod p) (hc : c ≠ 0)
    (hdet : a * d - b * c = 1) :
    (⟨!![a, b; c, d], by simp [det_fin_two]; linear_combination hdet⟩ : SL2FpGroup p) =
      sl2_upper p ((a - 1) / c) * sl2_lower p c * sl2_upper p ((d - 1) / c) := by
  ext i j fin_cases i ; fin_cases j <;> simp +decide [ *, mul_assoc, Matrix.mul_apply ] ; ring!;
  · fin_cases i <;> simp +decide [ *, sl2_lower, sl2_upper ] ; ring!;
    grind;
  · fin_cases i <;> simp +decide [ *, sl2_upper, sl2_lower ] ; ring!;
    · grind +ring;
    · rw [ mul_div_cancel₀ _ hc, sub_add_cancel ]

/-! ## Main generation theorem -/

/-
**Main Generation Theorem**: For odd prime p, the unipotent matrices
    u = [[1,1],[0,1]] and v = [[1,0],[1,1]] generate all of SL₂(𝔽_p).

    The proof proceeds by Gaussian elimination:
    1. Every element with nonzero c-entry factors as upper · lower · upper
    2. For c = 0 elements, multiply by the Weyl element to make c nonzero
    3. All upper/lower unipotents and the Weyl element are in ⟨u,v⟩
-/
theorem sl2_closure_unipotent_eq_top (p : ℕ) [hp : Fact p.Prime]
    (hpodd : p ≠ 2) :
    sl2UV p = ⊤ := by
  refine' eq_top_iff.mpr fun g hg => _;
  -- By Gaussian elimination, we can write any element of SL₂(𝔽_p) as a product of upper and lower unipotent matrices.
  obtain ⟨a, b, c, d, hc⟩ : ∃ a b c d : ZMod p, g.1 = !![a, b; c, d] ∧ a * d - b * c = 1 := by
    refine' ⟨ g.1 0 0, g.1 0 1, g.1 1 0, g.1 1 1, _, _ ⟩;
    · ext i j; fin_cases i <;> fin_cases j <;> rfl;
    · convert g.2 using 1;
      rw [ Matrix.det_fin_two ];
  by_cases hc : c ≠ 0;
  · convert Subgroup.mul_mem _ ( Subgroup.mul_mem _ ( sl2_upper_mem_closure p ( ( a - 1 ) / c ) ) ( sl2_lower_mem_closure p c ) ) ( sl2_upper_mem_closure p ( ( d - 1 ) / c ) ) using 1;
    exact sl2_gaussian_factorization p a b c d hc ( by tauto ) ▸ by aesop;
  · -- Since $c = 0$, we have $a * d = 1$. We can use the Weyl element to transform $g$ into a matrix with a non-zero lower-left entry.
    have h_weyl : (sl2_weyl p * g).1 1 0 ≠ 0 := by
      simp_all +decide [ sl2_weyl ];
      grind +revert;
    -- By Gaussian elimination, we can write $sl2_weyl p * g$ as a product of upper and lower unipotent matrices.
    obtain ⟨a', b', c', d', hc'⟩ : ∃ a' b' c' d' : ZMod p, (sl2_weyl p * g).1 = !![a', b'; c', d'] ∧ a' * d' - b' * c' = 1 ∧ c' ≠ 0 := by
      simp_all +decide [ sl2_weyl ];
      rw [ mul_comm, ‹ ( g : Matrix ( Fin 2 ) ( Fin 2 ) ( ZMod p ) ) = !![ a, b; 0, d ] ∧ a * d = 1 ›.2 ];
    have h_gauss : sl2_weyl p * g = sl2_upper p ((a' - 1) / c') * sl2_lower p c' * sl2_upper p ((d' - 1) / c') := by
      convert sl2_gaussian_factorization p a' b' c' d' hc'.2.2 hc'.2.1 using 1;
      exact Subtype.ext hc'.1;
    have h_gauss : sl2_weyl p * g ∈ sl2UV p := by
      exact h_gauss.symm ▸ Subgroup.mul_mem _ ( Subgroup.mul_mem _ ( sl2_upper_mem_closure p _ ) ( sl2_lower_mem_closure p _ ) ) ( sl2_upper_mem_closure p _ );
    simpa using Subgroup.mul_mem _ ( Subgroup.inv_mem _ ( sl2_weyl_mem_closure p ) ) h_gauss