import Mathlib

/-!
# Euclidean norm-ratio spectrum of real 2×2 unimodular matrices

For a real `2×2` matrix `M`, let `k v` be the Euclidean norm of `v : Fin 2 → ℝ`.
The *ratio spectrum* of `M` is the set of values `k (M.mulVec v) / k v` over nonzero `v`.

The main result is that whenever `M.det ^ 2 = 1` (i.e. `M` is unimodular up to sign),
there is a nonzero vector `v` with `k (M.mulVec v) = k v`; in other words `1` lies in the
ratio spectrum.  Consequently the degenerate interval `[1,1]` is contained in the closure of
the ratio spectrum.
-/

namespace MatrixNormRatioSpectrum

open Matrix

/-- The Euclidean norm of a vector in `ℝ²`. -/
noncomputable def k (v : Fin 2 → ℝ) : ℝ := Real.sqrt ((v 0) ^ 2 + (v 1) ^ 2)

/-- The set of Euclidean norm-ratios `k (M v) / k v` over nonzero `v`. -/
noncomputable def ratioSpectrum (M : Matrix (Fin 2) (Fin 2) ℝ) : Set ℝ :=
  {r | ∃ v : Fin 2 → ℝ, v ≠ 0 ∧ r = k (M.mulVec v) / k v}

/-
Discriminant nonnegativity for a unimodular form.
-/
lemma disc_nonneg (a b c d : ℝ) (h : (a * d - b * c) ^ 2 = 1) :
    0 ≤ (a * b + c * d) ^ 2 - (a ^ 2 + c ^ 2 - 1) * (b ^ 2 + d ^ 2 - 1) := by
  nlinarith [ sq_nonneg ( a - d ), sq_nonneg ( b + c ), sq_nonneg ( a + d ), sq_nonneg ( b - c ) ]

/-
Core algebraic statement: for arbitrary reals with `(ad-bc)^2 = 1`, the quadratic form
`(ax+by)^2 + (cx+dy)^2 - (x^2+y^2)` has a nontrivial zero.
-/
theorem core_exists (a b c d : ℝ) (h : (a * d - b * c) ^ 2 = 1) :
    ∃ x y : ℝ, ¬ (x = 0 ∧ y = 0) ∧
      (a * x + b * y) ^ 2 + (c * x + d * y) ^ 2 = x ^ 2 + y ^ 2 := by
  by_cases hA : a^2 + c^2 - 1 = 0;
  · exact ⟨ 1, 0, by norm_num, by nlinarith ⟩;
  · -- Let $s = \sqrt{B^2 - AC}$.
    set s := Real.sqrt ((a * b + c * d) ^ 2 - (a ^ 2 + c ^ 2 - 1) * (b ^ 2 + d ^ 2 - 1)) with hs_def
    have hs : s ^ 2 = (a * b + c * d) ^ 2 - (a ^ 2 + c ^ 2 - 1) * (b ^ 2 + d ^ 2 - 1) := by
      exact Real.sq_sqrt <| by nlinarith [ sq_nonneg ( a * d - b * c - 1 ), sq_nonneg ( a * d - b * c + 1 ), disc_nonneg a b c d h ] ;
    -- Take $x = (-B + s)/A$ and $y = 1$.
    use (- (a * b + c * d) + s) / (a ^ 2 + c ^ 2 - 1), 1;
    grind

/-
Main theorem: every real `2×2` matrix with `det^2 = 1` fixes the Euclidean norm of some
nonzero vector.
-/
theorem exists_unit_ratio :
    ∀ M : Matrix (Fin 2) (Fin 2) ℝ, M.det ^ 2 = 1 →
      ∃ v : Fin 2 → ℝ, v ≠ 0 ∧ k (M.mulVec v) = k v := by
  intro M hM
  by_contra h_contra
  push_neg at h_contra;
  -- Set a = M 0 0, b = M 0 1, c = M 1 0, d = M 1 1.
  set a := M 0 0
  set b := M 0 1
  set c := M 1 0
  set d := M 1 1

  -- By core_exists, there exist x v ≠ 0 such that (ax+by)^2+(cx+dy)^2 = x^2+y^2.
  obtain ⟨x, y, hxy⟩ : ∃ x y : ℝ, ¬ (x = 0 ∧ y = 0) ∧ (a * x + b * y) ^ 2 + (c * x + d * y) ^ 2 = x ^ 2 + y ^ 2 := by
    convert core_exists a b c d _ ; rw [ Matrix.det_fin_two ] at hM ; linarith!;
  exact h_contra ( fun i => if i = 0 then x else y ) ( by intro h; exact hxy.1 <| by have := congr_fun h 0; have := congr_fun h 1; aesop ) ( congr_arg Real.sqrt <| by simpa [ Matrix.mulVec, dotProduct, Fin.sum_univ_two ] using hxy.2 )

theorem one_mem_ratioSpectrum (M : Matrix (Fin 2) (Fin 2) ℝ) (hM : M.det ^ 2 = 1) :
    1 ∈ ratioSpectrum M := by
  obtain ⟨ v, hv, hk ⟩ := exists_unit_ratio M hM;
  refine' ⟨ v, hv, _ ⟩;
  rw [ hk, div_self ];
  exact ne_of_gt <| Real.sqrt_pos.mpr <| by exact not_le.mp fun h => hv <| by ext i; fin_cases i <;> norm_num <;> nlinarith!;

theorem ratioSpectrum_dense_Icc (M : Matrix (Fin 2) (Fin 2) ℝ) (hM : M.det ^ 2 = 1) :
    Set.Icc (1 : ℝ) 1 ⊆ closure (ratioSpectrum M) := by
  convert subset_closure ( one_mem_ratioSpectrum M hM ) using 1;
  grind +revert

end MatrixNormRatioSpectrum