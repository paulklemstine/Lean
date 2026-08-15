import Mathlib
import Novelty.SplitCountArity

/-!
# The arity-`r` constant: `n^r · IsR r n · log 2 − log n → r`

`SplitCountConstant.lean` proves, for the semiprime (arity two) fork,
`n² · Is n · log 2 − log n → 2`.  This file proves the arity-`r` version, for
every fixed arity `r ≥ 2`:

* `IsR_expansion` : the **exact cell expansion**
  `IsR r n · log 2 · n^{r+1} = ∑_{m=0}^{r} C(r,m) · Tterm n m`, where `Tterm n m`
  collects the two cells of the column with `m` non-splitting factors;
* `Tterm_zero`, `Tterm_one` : `Tterm n 0 = n log n` and
  `Tterm n 1 = (n−1) n log(n/(n−1))` — the only two columns that survive;
* `abs_Tterm_le` : `|Tterm n m| ≤ 6` for `2 ≤ m`, `n ≥ 3`: in every other column
  the two cells cancel to first order (`(−1)^m` against `−(−1)^m`);
* `IsR_arity_constant_bound` :
  `|n^r · IsR r n · log 2 − log n − r| ≤ 2r/(n−1) + 6·2^r/n`;
* `IsR_arity_constant` : hence `n^r · IsR r n · log 2 − log n → r`.

The arity-two case recovers the constant `2` of `SplitCountConstant.lean`.
-/

namespace SplitCountArityAsymp

open Finset Real Filter SplitCountLaw SplitCountArity

variable {r : ℕ} {n : ℝ}

/-! ## Two Taylor estimates -/

/-- `|log(1 + s) − s| ≤ 2 s²` on `[−1/2, 1/2]`. -/
lemma abs_log_one_add_sub_le {s : ℝ} (hs : |s| ≤ 1 / 2) :
    |Real.log (1 + s) - s| ≤ 2 * s ^ 2 := by
  have habs : |(-s)| < 1 := by
    rw [abs_neg]; linarith [hs]
  have h := Real.abs_log_sub_add_sum_range_le habs 1
  have hsum : (∑ i ∈ Finset.range 1, (-s) ^ (i + 1) / ((i : ℝ) + 1)) = -s := by
    simp
  rw [hsum] at h
  have h1 : (1 : ℝ) - |(-s)| ≥ 1 / 2 := by
    rw [abs_neg]; linarith
  have h2 : |(-s)| ^ (1 + 1) = s ^ 2 := by
    rw [abs_neg]
    norm_num [sq_abs]
  have h3 : |(-s)| ^ (1 + 1) / (1 - |(-s)|) ≤ 2 * s ^ 2 := by
    rw [h2, div_le_iff₀ (by linarith)]
    nlinarith [sq_nonneg s]
  have h4 : Real.log (1 + s) - s = -s + Real.log (1 - (-s)) := by
    rw [sub_neg_eq_add]; ring
  rw [h4]
  linarith

/-- `|(1 + s) log(1 + s) − s| ≤ 4 s²` on `[−1/2, 1/2]`. -/
lemma abs_g_sub_le {s : ℝ} (hs : |s| ≤ 1 / 2) :
    |(1 + s) * Real.log (1 + s) - s| ≤ 4 * s ^ 2 := by
  have hlog := abs_log_one_add_sub_le hs
  have hs' : |1 + s| ≤ 3 / 2 := by
    have := abs_le.mp hs
    rw [abs_le]; constructor <;> linarith [this.1, this.2]
  have hkey : (1 + s) * Real.log (1 + s) - s
      = (1 + s) * (Real.log (1 + s) - s) + s ^ 2 := by ring
  rw [hkey]
  have h1 : |(1 + s) * (Real.log (1 + s) - s)| ≤ 3 / 2 * (2 * s ^ 2) := by
    rw [abs_mul]
    exact mul_le_mul hs' hlog (abs_nonneg _) (by norm_num)
  have h2 : |s ^ 2| = s ^ 2 := abs_of_nonneg (sq_nonneg s)
  calc |(1 + s) * (Real.log (1 + s) - s) + s ^ 2|
      ≤ |(1 + s) * (Real.log (1 + s) - s)| + |s ^ 2| := abs_add_le _ _
    _ ≤ 3 / 2 * (2 * s ^ 2) + s ^ 2 := by rw [h2]; linarith
    _ = 4 * s ^ 2 := by ring

/-! ## The column contribution -/

/-- The contribution of the column with `m` non-splitting factors (both cells,
in nats, normalised by `C(r,m)/n^{r+1}`). -/
noncomputable def Tterm (n : ℝ) (m : ℕ) : ℝ :=
  ((n - 1) ^ m + (n - 1) * (-1) ^ m)
      * Real.log (((n - 1) ^ m + (n - 1) * (-1) ^ m) / (n - 1) ^ m)
    + (n - 1) * ((n - 1) ^ m - (-1) ^ m)
      * Real.log (((n - 1) ^ m - (-1) ^ m) / (n - 1) ^ m)

lemma Tterm_zero : Tterm n 0 = n * Real.log n := by
  have h1 : (n - 1) ^ 0 + (n - 1) * (-1 : ℝ) ^ 0 = n := by ring
  have h2 : (n - 1) ^ 0 - (-1 : ℝ) ^ 0 = 0 := by ring
  simp only [Tterm]
  rw [h1, h2]
  norm_num

lemma Tterm_one : Tterm n 1 = (n - 1) * n * Real.log (n / (n - 1)) := by
  have h1 : (n - 1) ^ 1 + (n - 1) * (-1 : ℝ) ^ 1 = 0 := by ring
  have h2 : (n - 1) ^ 1 - (-1 : ℝ) ^ 1 = n := by ring
  simp only [Tterm]
  rw [h1, h2, pow_one]
  simp

/-- Away from the two leading columns the two cells cancel to first order, so the
column contributes `O(1)` instead of `O(n)`. -/
lemma abs_Tterm_le (hn : 3 ≤ n) {m : ℕ} (hm : 2 ≤ m) : |Tterm n m| ≤ 6 := by
  have hu : (2:ℝ) ≤ n - 1 := by linarith
  have hu0 : (0:ℝ) < n - 1 := by linarith
  set u : ℝ := n - 1 with hudef
  have hum : u ^ 2 ≤ u ^ m := pow_le_pow_right₀ (by linarith) hm
  have hum0 : (0:ℝ) < u ^ m := by positivity
  have hu2 : (0:ℝ) < u ^ 2 := by positivity
  set e : ℝ := (-1 : ℝ) ^ m with hedef
  have he : e = 1 ∨ e = -1 := by
    rcases Nat.even_or_odd m with h | h
    · exact Or.inl h.neg_one_pow
    · exact Or.inr h.neg_one_pow
  have h2u : 2 * u ≤ u ^ 2 := by nlinarith
  have habs_e : |e| = 1 := by rcases he with h | h <;> simp [h]
  set s0 : ℝ := u * e / u ^ m with hs0
  set s1 : ℝ := -e / u ^ m with hs1
  have hs0abs : |s0| ≤ 1 / 2 := by
    have habs0 : |s0| = u / u ^ m := by
      rw [hs0, abs_div, abs_mul, habs_e, mul_one, abs_of_pos hu0, abs_of_pos hum0]
    rw [habs0, div_le_iff₀ hum0]
    linarith
  have hs1abs : |s1| ≤ 1 / 2 := by
    have habs1 : |s1| = 1 / u ^ m := by
      rw [hs1, abs_div, abs_neg, habs_e, abs_of_pos hum0]
    rw [habs1, div_le_iff₀ hum0]
    nlinarith
  have hval0 : u ^ m + u * e = u ^ m * (1 + s0) := by
    rw [hs0]; field_simp
  have hval1 : u ^ m - e = u ^ m * (1 + s1) := by
    rw [hs1]; field_simp; ring
  have hlog0 : (u ^ m + u * e) / u ^ m = 1 + s0 := by
    rw [hval0]; field_simp
  have hlog1 : (u ^ m - e) / u ^ m = 1 + s1 := by
    rw [hval1]; field_simp
  have hT : Tterm n m
      = u ^ m * ((1 + s0) * Real.log (1 + s0) - s0)
        + u ^ (m + 1) * ((1 + s1) * Real.log (1 + s1) - s1) := by
    simp only [Tterm, ← hudef, ← hedef]
    rw [hlog0, hlog1, hval0]
    have hx1 : u * (u ^ m - e) = u ^ (m + 1) * (1 + s1) := by
      rw [hval1, pow_succ]; ring
    rw [hx1]
    have hcancel : u ^ m * s0 + u ^ (m + 1) * s1 = 0 := by
      rw [hs0, hs1, pow_succ]
      field_simp
      ring
    have hrearrange : u ^ m * (1 + s0) * Real.log (1 + s0)
          + u ^ (m + 1) * (1 + s1) * Real.log (1 + s1)
        = u ^ m * ((1 + s0) * Real.log (1 + s0) - s0)
          + u ^ (m + 1) * ((1 + s1) * Real.log (1 + s1) - s1)
          + (u ^ m * s0 + u ^ (m + 1) * s1) := by ring
    rw [hrearrange, hcancel, add_zero]
  have hb0 := abs_g_sub_le hs0abs
  have hb1 := abs_g_sub_le hs1abs
  have hsq0 : s0 ^ 2 = u ^ 2 / (u ^ m) ^ 2 := by
    rw [hs0, div_pow, mul_pow]
    rcases he with h | h <;> rw [h] <;> norm_num
  have hsq1 : s1 ^ 2 = 1 / (u ^ m) ^ 2 := by
    rw [hs1, div_pow]
    rcases he with h | h <;> rw [h] <;> norm_num
  have hstep0 : |u ^ m * ((1 + s0) * Real.log (1 + s0) - s0)| ≤ 4 * u ^ 2 / u ^ m := by
    rw [abs_mul, abs_of_pos hum0]
    calc u ^ m * |(1 + s0) * Real.log (1 + s0) - s0| ≤ u ^ m * (4 * s0 ^ 2) :=
          mul_le_mul_of_nonneg_left hb0 hum0.le
      _ = 4 * u ^ 2 / u ^ m := by rw [hsq0]; field_simp
  have hstep1 : |u ^ (m + 1) * ((1 + s1) * Real.log (1 + s1) - s1)| ≤ 4 * u / u ^ m := by
    have hpos : (0:ℝ) < u ^ (m + 1) := by positivity
    rw [abs_mul, abs_of_pos hpos]
    calc u ^ (m + 1) * |(1 + s1) * Real.log (1 + s1) - s1| ≤ u ^ (m + 1) * (4 * s1 ^ 2) :=
          mul_le_mul_of_nonneg_left hb1 hpos.le
      _ = 4 * u / u ^ m := by rw [hsq1, pow_succ]; field_simp
  have hfin0 : 4 * u ^ 2 / u ^ m ≤ 4 := by
    rw [div_le_iff₀ hum0]; nlinarith
  have hfin1 : 4 * u / u ^ m ≤ 2 := by
    rw [div_le_iff₀ hum0]; nlinarith
  calc |Tterm n m| = |u ^ m * ((1 + s0) * Real.log (1 + s0) - s0)
        + u ^ (m + 1) * ((1 + s1) * Real.log (1 + s1) - s1)| := by rw [hT]
    _ ≤ |u ^ m * ((1 + s0) * Real.log (1 + s0) - s0)|
        + |u ^ (m + 1) * ((1 + s1) * Real.log (1 + s1) - s1)| := abs_add_le _ _
    _ ≤ 4 + 2 := by linarith
    _ = 6 := by norm_num

/-! ## The exact cell expansion -/

lemma cell_pair_log (hr : r ≠ 0) (hn : 2 ≤ n) (k : Fin (r + 1)) :
    (forkJointR r n 0 k * logb 2 (forkJointR r n 0 k
        / (rowMarg (forkJointR r n) 0 * colMarg (forkJointR r n) k))
      + forkJointR r n 1 k * logb 2 (forkJointR r n 1 k
        / (rowMarg (forkJointR r n) 1 * colMarg (forkJointR r n) k))) * Real.log 2
      = (r.choose (k : ℕ) : ℝ) * Tterm n (r - (k : ℕ)) / n ^ (r + 1) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hu0 : (0:ℝ) < n - 1 := by linarith
  have hl2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  have hum : (0:ℝ) < (n - 1) ^ (r - (k : ℕ)) := by positivity
  have hc : (0:ℝ) < (r.choose (k : ℕ) : ℝ) := by
    have : 0 < r.choose (k : ℕ) := Nat.choose_pos (Nat.lt_succ_iff.mp k.isLt)
    exact_mod_cast this
  have hnpow : (0:ℝ) < n ^ (r + 1) := by positivity
  set m : ℕ := r - (k : ℕ) with hm
  set c : ℝ := (r.choose (k : ℕ) : ℝ) with hcdef
  -- the two ratios
  have hratio0 : forkJointR r n 0 k
      / (rowMarg (forkJointR r n) 0 * colMarg (forkJointR r n) k)
      = ((n - 1) ^ m + (n - 1) * (-1) ^ m) / (n - 1) ^ m := by
    rw [forkJointR_zero_eq (ne_of_gt hn0), rowMarg_forkJointR_zero hr hn, colMarg_forkJointR hn]
    simp only [binomR, ← hm, ← hcdef, pow_succ]
    field_simp
  have hratio1 : forkJointR r n 1 k
      / (rowMarg (forkJointR r n) 1 * colMarg (forkJointR r n) k)
      = ((n - 1) ^ m - (-1) ^ m) / (n - 1) ^ m := by
    rw [forkJointR_one_eq (ne_of_gt hn0), rowMarg_forkJointR_one hr hn, colMarg_forkJointR hn]
    simp only [binomR, ← hm, ← hcdef, pow_succ]
    field_simp
  rw [hratio0, hratio1, forkJointR_zero_eq (ne_of_gt hn0), forkJointR_one_eq (ne_of_gt hn0)]
  simp only [Real.logb, ← hm, ← hcdef, Tterm]
  field_simp

/-- **The exact cell expansion of the arity-`r` channel.** -/
theorem IsR_expansion (hr : r ≠ 0) (hn : 2 ≤ n) :
    IsR r n * Real.log 2 * n ^ (r + 1)
      = ∑ m ∈ Finset.range (r + 1), (r.choose m : ℝ) * Tterm n m := by
  have hn0 : (0:ℝ) < n := by linarith
  have hnpow : (0:ℝ) < n ^ (r + 1) := by positivity
  have hstep : IsR r n * Real.log 2
      = ∑ k : Fin (r + 1), (r.choose (k : ℕ) : ℝ) * Tterm n (r - (k : ℕ)) / n ^ (r + 1) := by
    simp only [IsR, mutualInfo, Fin.sum_univ_two, ← Finset.sum_add_distrib, Finset.sum_mul]
    exact Finset.sum_congr rfl (fun k _ => cell_pair_log hr hn k)
  rw [hstep, ← Finset.sum_div, div_mul_cancel₀ _ (ne_of_gt hnpow)]
  rw [Fin.sum_univ_eq_sum_range (fun k => (r.choose k : ℝ) * Tterm n (r - k))]
  rw [← Finset.sum_range_reflect]
  refine Finset.sum_congr rfl (fun k hk => ?_)
  rw [Finset.mem_range] at hk
  have h0 : r + 1 - 1 - k = r - k := by omega
  rw [h0]
  have h1 : r - (r - k) = k := by omega
  have h2 : r.choose (r - k) = r.choose k := Nat.choose_symm (by omega)
  rw [h1, h2]

/-! ## The constant -/

/-- **The arity-`r` constant, with an explicit rate.** -/
theorem IsR_arity_constant_bound (hr : 2 ≤ r) (hn : 3 ≤ n) :
    |n ^ r * (IsR r n * Real.log 2) - Real.log n - r| ≤ 2 * r / (n - 1) + 6 * 2 ^ r / n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hu : (2:ℝ) ≤ n - 1 := by linarith
  have hu0 : (0:ℝ) < n - 1 := by linarith
  have hnpow : (0:ℝ) < n ^ r := by positivity
  -- split the expansion into the two leading columns and the rest
  have hsplit : ∑ m ∈ Finset.range (r + 1), (r.choose m : ℝ) * Tterm n m
      = Tterm n 0 + r * Tterm n 1
        + ∑ m ∈ Finset.Ico 2 (r + 1), (r.choose m : ℝ) * Tterm n m := by
    rw [Finset.range_eq_Ico,
      ← Finset.sum_Ico_consecutive _ (by omega : 0 ≤ 2) (by omega : 2 ≤ r + 1)]
    have h2 : ∑ m ∈ Finset.Ico 0 2, (r.choose m : ℝ) * Tterm n m
        = Tterm n 0 + r * Tterm n 1 := by
      rw [show Finset.Ico 0 2 = ({0, 1} : Finset ℕ) by decide]
      simp
    rw [h2]
  have hexp := IsR_expansion (by omega : r ≠ 0) (by linarith : (2:ℝ) ≤ n)
  rw [hsplit, Tterm_zero, Tterm_one] at hexp
  -- the tail
  set S : ℝ := ∑ m ∈ Finset.Ico 2 (r + 1), (r.choose m : ℝ) * Tterm n m with hS
  have hSbound : |S| ≤ 6 * 2 ^ r := by
    have h1 : |S| ≤ ∑ m ∈ Finset.Ico 2 (r + 1), |(r.choose m : ℝ) * Tterm n m| :=
      Finset.abs_sum_le_sum_abs _ _
    have h2 : ∀ m ∈ Finset.Ico 2 (r + 1), |(r.choose m : ℝ) * Tterm n m|
        ≤ (r.choose m : ℝ) * 6 := by
      intro m hm
      rw [Finset.mem_Ico] at hm
      rw [abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ (r.choose m : ℝ))]
      exact mul_le_mul_of_nonneg_left (abs_Tterm_le hn hm.1) (by positivity)
    have h3 : ∑ m ∈ Finset.Ico 2 (r + 1), (r.choose m : ℝ) * 6
        ≤ ∑ m ∈ Finset.range (r + 1), (r.choose m : ℝ) * 6 := by
      refine Finset.sum_le_sum_of_subset_of_nonneg ?_ (fun m _ _ => by positivity)
      intro m hm
      rw [Finset.mem_Ico] at hm
      exact Finset.mem_range.mpr hm.2
    have h4 : ∑ m ∈ Finset.range (r + 1), (r.choose m : ℝ) * 6 = 6 * 2 ^ r := by
      rw [← Finset.sum_mul]
      have : ∑ m ∈ Finset.range (r + 1), (r.choose m : ℝ) = 2 ^ r := by
        have := Nat.sum_range_choose r
        calc ∑ m ∈ Finset.range (r + 1), (r.choose m : ℝ)
            = ((∑ m ∈ Finset.range (r + 1), r.choose m : ℕ) : ℝ) := by push_cast; ring
          _ = 2 ^ r := by rw [this]; push_cast; ring
      rw [this]; ring
    calc |S| ≤ ∑ m ∈ Finset.Ico 2 (r + 1), |(r.choose m : ℝ) * Tterm n m| := h1
      _ ≤ ∑ m ∈ Finset.Ico 2 (r + 1), (r.choose m : ℝ) * 6 := Finset.sum_le_sum h2
      _ ≤ ∑ m ∈ Finset.range (r + 1), (r.choose m : ℝ) * 6 := h3
      _ = 6 * 2 ^ r := h4
  -- the log(n/(n−1)) term
  have hlogterm : |(n - 1) * Real.log (n / (n - 1)) - 1| ≤ 2 / (n - 1) := by
    have hs : |1 / (n - 1)| ≤ 1 / 2 := by
      rw [abs_of_pos (by positivity)]
      rw [div_le_div_iff₀ hu0 (by norm_num)]
      linarith
    have hrw : n / (n - 1) = 1 + 1 / (n - 1) := by field_simp; ring
    have h := abs_log_one_add_sub_le hs
    rw [← hrw] at h
    have hmul : |(n - 1) * (Real.log (n / (n - 1)) - 1 / (n - 1))|
        ≤ (n - 1) * (2 * (1 / (n - 1)) ^ 2) := by
      rw [abs_mul, abs_of_pos hu0]
      exact mul_le_mul_of_nonneg_left h hu0.le
    have hid : (n - 1) * (Real.log (n / (n - 1)) - 1 / (n - 1))
        = (n - 1) * Real.log (n / (n - 1)) - 1 := by
      field_simp
    rw [hid] at hmul
    have hfin : (n - 1) * (2 * (1 / (n - 1)) ^ 2) = 2 / (n - 1) := by
      field_simp
    rw [hfin] at hmul
    exact hmul
  -- assemble
  have hmain : n ^ r * (IsR r n * Real.log 2) - Real.log n - r
      = r * ((n - 1) * Real.log (n / (n - 1)) - 1) + S / n := by
    have hn1 : n ^ (r + 1) = n ^ r * n := by rw [pow_succ]
    have h := hexp
    rw [hn1] at h
    field_simp at h ⊢
    nlinarith [h]
  rw [hmain]
  have h1 : |r * ((n - 1) * Real.log (n / (n - 1)) - 1)| ≤ r * (2 / (n - 1)) := by
    rw [abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ (r:ℝ))]
    exact mul_le_mul_of_nonneg_left hlogterm (by positivity)
  have h2 : |S / n| ≤ 6 * 2 ^ r / n := by
    rw [abs_div, abs_of_pos hn0]
    gcongr
  calc |r * ((n - 1) * Real.log (n / (n - 1)) - 1) + S / n|
      ≤ |r * ((n - 1) * Real.log (n / (n - 1)) - 1)| + |S / n| := abs_add_le _ _
    _ ≤ r * (2 / (n - 1)) + 6 * 2 ^ r / n := by linarith
    _ = 2 * r / (n - 1) + 6 * 2 ^ r / n := by ring

/-- **The arity-`r` constant.** -/
theorem IsR_arity_constant (hr : 2 ≤ r) :
    Tendsto (fun x : ℝ => x ^ r * (IsR r x * Real.log 2) - Real.log x) atTop (nhds r) := by
  have hb : Tendsto (fun x : ℝ => 2 * (r : ℝ) / (x - 1) + 6 * 2 ^ r / x) atTop (nhds 0) := by
    have h1 : Tendsto (fun x : ℝ => 2 * (r : ℝ) / (x - 1)) atTop (nhds 0) := by
      have := (tendsto_atTop_add_const_right atTop (-1 : ℝ) tendsto_id)
      simpa using this.inv_tendsto_atTop.const_mul (2 * (r : ℝ))
    have h2 : Tendsto (fun x : ℝ => 6 * 2 ^ r / x) atTop (nhds 0) := by
      simpa using (tendsto_inv_atTop_zero.const_mul (6 * 2 ^ r : ℝ))
    simpa using h1.add h2
  rw [Metric.tendsto_atTop]
  intro ε hε
  rw [Metric.tendsto_atTop] at hb
  obtain ⟨N, hN⟩ := hb ε hε
  refine ⟨max N 3, fun x hx => ?_⟩
  have hx3 : (3:ℝ) ≤ x := le_trans (le_max_right N 3) hx
  have hxN : N ≤ x := le_trans (le_max_left N 3) hx
  have hbound := IsR_arity_constant_bound hr hx3
  have hb2 := hN x hxN
  rw [Real.dist_eq] at hb2 ⊢
  have hpos : (0:ℝ) ≤ 2 * (r : ℝ) / (x - 1) + 6 * 2 ^ r / x := by
    have : (0:ℝ) < x - 1 := by linarith
    positivity
  rw [sub_zero, abs_of_nonneg hpos] at hb2
  calc |x ^ r * (IsR r x * Real.log 2) - Real.log x - r|
      ≤ 2 * r / (x - 1) + 6 * 2 ^ r / x := hbound
    _ < ε := hb2

end SplitCountArityAsymp