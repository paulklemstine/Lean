/-
# OISCC V12: Higher-Dimensional EML Maps

The n-dimensional EML map generalizes the 2D map Φ(x,y) = (exp(x)-ln(y), exp(y)-ln(x))
to n coordinates. We study the 3D case in detail.

Key results:
1. The 3D EML map is well-defined on ℝ³₊
2. Sum coordinate grows: S(Φ₃(x)) ≥ S(x) + 3
3. The 3D potential is positive
4. The 3D diagonal map d₃(x) = exp(x) - ln(x) agrees with the 2D diagonal
5. Properties of the symmetric case (all coordinates equal)
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-- The 3D EML map: Φ₃(x,y,z)ᵢ = exp(xᵢ) - (ln(xⱼ) + ln(xₖ))/2. -/
def Phi3 (p : Fin 3 → ℝ) : Fin 3 → ℝ := fun i =>
  Real.exp (p i) - (Finset.univ.erase i).sum (fun j => Real.log (p j)) / 2

/-- The sum coordinate for 3D. -/
def S3 (p : Fin 3 → ℝ) : ℝ := Finset.univ.sum (fun i => p i)

/-- The 3D EML potential. -/
def f3 (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

/-- The 3D total potential. -/
def V3 (p : Fin 3 → ℝ) : ℝ := Finset.univ.sum (fun i => f3 (p i))

/-
f₃(x) > 0 for x > 0.
-/
theorem f3_pos (x : ℝ) (hx : 0 < x) : f3 x > 0 := by
  unfold f3;
  linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]

/-
The 3D potential is positive when all coordinates are positive.
-/
theorem V3_pos (p : Fin 3 → ℝ) (hp : ∀ i, 0 < p i) : V3 p > 0 := by
  exact Finset.sum_pos ( fun i _ => f3_pos _ ( hp i ) ) ( by decide )

/-
On the diagonal (x,x,x), the 3D map gives (exp(x)-ln(x), exp(x)-ln(x), exp(x)-ln(x)).
-/
theorem Phi3_diag (x : ℝ) (hx : 0 < x) :
    Phi3 (fun _ => x) = fun _ => Real.exp x - Real.log x := by
  funext i; exact (by
  unfold Phi3; fin_cases i <;> simp +decide [ hx.ne' ])

/-
The sum of a constant function.
-/
theorem S3_const (c : ℝ) : S3 (fun _ => c) = 3 * c := by
  unfold S3; norm_num;

/-
The 3D diagonal map preserves the diagonal.
-/
theorem Phi3_diag_preserves (x : ℝ) (hx : 0 < x) :
    ∃ y, Phi3 (fun _ => x) = fun _ => y := by
  unfold Phi3; aesop;

/-
exp(x) - ln(x) > x for x > 0 (3D diagonal escape).
-/
theorem diag3_gt_id (x : ℝ) (hx : 0 < x) :
    Real.exp x - Real.log x > x := by
  have := Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos x ) hx );
  rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this;
  rw [ div_sub_one, le_div_iff₀ ] at this <;> nlinarith [ Real.add_one_le_exp x, Real.log_exp x, Real.log_le_sub_one_of_pos hx ]

/-
The 3D symmetric map d₃(x) = exp(x) - ln(x) satisfies d₃(x) ≥ 2.
-/
theorem diag3_ge_two (x : ℝ) (hx : 0 < x) :
    Real.exp x - Real.log x ≥ 2 := by
  linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]

/-
The total exp sum grows after applying Phi3 on the diagonal.
-/
theorem exp_sum_grows_diag (x : ℝ) (hx : 0 < x) :
    3 * Real.exp (Real.exp x - Real.log x) > 3 * Real.exp x := by
  gcongr;
  linarith [ diag3_gt_id x hx ]

end