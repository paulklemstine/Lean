/-
# MASTER-TABLE (paper 119) — the large-degree limit of the table

The master table stops at degree `6`, but the closed forms of
`Algebra.MasterTable.Cyclic` and `Algebra.MasterTable.Dihedral` let us read off
what happens as the degree grows:

* `pinEnt_bounds` — `0 ≤ pinEnt n ≤ ((n-1)⁻¹ + ln(n-1)/n) / ln 2` for `n ≥ 2`;
* `pinEnt_pos` — the pinning entropy is strictly positive for `n ≥ 2`;
* `tendsto_pinEnt` — **`pinEnt n → 0`**: the cyclic root-count channel, and the
  dihedral non-abelian residue `pinEnt(n)/2`, both vanish as the degree grows;
* `abelian_saturation_odd` — along odd degrees `n = 2k + 3`, the share of the
  dihedral type information carried by the abelian (rotation-character) dial,
  `I(rotSign ; T) / H(T)`, tends to `1`: the non-abelian part of the type channel
  is asymptotically invisible, yet (`nonabelian_residue_pos_odd`) it never vanishes
  at any finite odd degree.
-/
import Algebra.MasterTable.Dihedral

namespace MasterTable

open CyclicTypeChannel D6TypeChannel DihedralGroup Finset Filter Topology

/-- Two-sided analytic bounds on the pinning entropy. -/
theorem pinEnt_bounds {n : ℕ} (hn : 2 ≤ n) :
    0 ≤ pinEnt n ∧ pinEnt n ≤
      (((n : ℝ) - 1)⁻¹ + Real.log ((n : ℝ) - 1) / (1 * ((n : ℝ) - 1) + 1)) / Real.log 2 := by
  have hn1 : (1 : ℝ) ≤ (n : ℝ) - 1 := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn
    linarith
  have hnpos : (0 : ℝ) < n := by linarith
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hl : 0 ≤ Real.log ((n : ℝ) - 1) := Real.log_nonneg hn1
  have hmono : Real.log ((n : ℝ) - 1) ≤ Real.log n := Real.log_le_log (by linarith) (by linarith)
  have hdiff : Real.log n - Real.log ((n : ℝ) - 1) ≤ ((n : ℝ) - 1)⁻¹ := by
    rw [← Real.log_div hnpos.ne' (by linarith)]
    have := Real.log_le_sub_one_of_pos (show (0 : ℝ) < n / ((n : ℝ) - 1) by positivity)
    have e : (n : ℝ) / ((n : ℝ) - 1) - 1 = ((n : ℝ) - 1)⁻¹ := by field_simp; ring
    linarith
  have key : pinEnt n
      = ((Real.log n - Real.log ((n : ℝ) - 1)) + Real.log ((n : ℝ) - 1) / n) / Real.log 2 := by
    simp only [pinEnt, Real.logb]
    field_simp
    ring
  rw [key, show (1 * ((n : ℝ) - 1) + 1) = n by ring]
  constructor
  · apply div_nonneg _ h2.le
    have : 0 ≤ Real.log ((n : ℝ) - 1) / n := div_nonneg hl hnpos.le
    linarith
  · apply div_le_div_of_nonneg_right _ h2.le
    linarith

/-- The pinning entropy is strictly positive from `n = 2` on. -/
theorem pinEnt_pos {n : ℕ} (hn : 2 ≤ n) : 0 < pinEnt n := by
  have hn1 : (1 : ℝ) ≤ (n : ℝ) - 1 := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn
    linarith
  have hnpos : (0 : ℝ) < n := by linarith
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hl : 0 ≤ Real.log ((n : ℝ) - 1) := Real.log_nonneg hn1
  have hstrict : Real.log ((n : ℝ) - 1) < Real.log n :=
    Real.log_lt_log (by linarith) (by linarith)
  have key : pinEnt n
      = ((Real.log n - Real.log ((n : ℝ) - 1)) + Real.log ((n : ℝ) - 1) / n) / Real.log 2 := by
    simp only [pinEnt, Real.logb]
    field_simp
    ring
  rw [key]
  apply div_pos _ h2
  have : 0 ≤ Real.log ((n : ℝ) - 1) / n := div_nonneg hl hnpos.le
  linarith

/-- **The pinning entropy vanishes in the large-degree limit.** -/
theorem tendsto_pinEnt : Tendsto pinEnt atTop (𝓝 0) := by
  have hlim : Tendsto (fun x : ℝ => (x⁻¹ + Real.log x / (1 * x + 1)) / Real.log 2)
      atTop (𝓝 0) := by
    have h1 := Real.tendsto_pow_log_div_mul_add_atTop 1 1 1 one_ne_zero
    simp only [pow_one] at h1
    simpa using (tendsto_inv_atTop_zero.add h1).div_const (Real.log 2)
  have hsub : Tendsto (fun n : ℕ => (n : ℝ) - 1) atTop atTop :=
    tendsto_atTop_add_const_right _ (-1) tendsto_natCast_atTop_atTop
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds (hlim.comp hsub) ?_ ?_
  · filter_upwards [eventually_ge_atTop 2] with n hn using (pinEnt_bounds hn).1
  · filter_upwards [eventually_ge_atTop 2] with n hn using (pinEnt_bounds hn).2

/-- The cyclic root-count channel vanishes in the large-degree limit. -/
theorem tendsto_rootCountEntropy : Tendsto rootCountEntropy atTop (𝓝 0) := by
  refine tendsto_pinEnt.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  exact (rootCountEntropy_eq_pinEnt hn).symm

instance oddDegree_neZero (k : ℕ) : NeZero (2 * k + 3) := ⟨by omega⟩

/-- At every odd degree the non-abelian residue `H(T | rotSign)` is strictly
positive: no abelian dial pins the dihedral splitting type. -/
theorem nonabelian_residue_pos_odd {n : ℕ} [NeZero n] (hn : Odd n) (h3 : 3 ≤ n) :
    0 < condEnt (univ : Finset (DihedralGroup n)) fixCount rotSign := by
  rw [condEnt_rotSign_odd hn]
  have := pinEnt_pos (show 2 ≤ n by omega)
  positivity

/-- **Asymptotic abelian saturation.** Along the odd degrees `n = 2k + 3`, the
fraction of the dihedral type entropy carried by the abelian dial tends to `1`. -/
theorem abelian_saturation_odd :
    Tendsto (fun k : ℕ => mutInfo (univ : Finset (DihedralGroup (2 * k + 3))) fixCount rotSign
      / typeEntropyDn (2 * k + 3)) atTop (𝓝 1) := by
  have hodd : ∀ k : ℕ, Odd (2 * k + 3) := fun k => ⟨k + 1, by ring⟩
  have hform : (fun k : ℕ => mutInfo (univ : Finset (DihedralGroup (2 * k + 3))) fixCount rotSign
      / typeEntropyDn (2 * k + 3)) = fun k => (1 + pinEnt (2 * k + 3) / 2)⁻¹ := by
    funext k
    rw [mutInfo_rotSign_odd (hodd k) (by omega), typeEntropyDn_odd (hodd k) (by omega), one_div]
  rw [hform]
  have hdeg : Tendsto (fun k : ℕ => 2 * k + 3) atTop atTop :=
    tendsto_atTop_mono (fun k => show id k ≤ 2 * k + 3 by simp only [id]; omega) tendsto_id
  have hp : Tendsto (fun k : ℕ => pinEnt (2 * k + 3)) atTop (𝓝 0) := tendsto_pinEnt.comp hdeg
  have := ((tendsto_const_nhds (x := (1 : ℝ))).add (hp.div_const 2)).inv₀ (by norm_num)
  simpa using this

end MasterTable