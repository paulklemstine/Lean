import Mathlib
import Novelty.SplitCountChannel

/-!
# The split-count law at every arity

`SplitCountChannel.lean` studies the semiprime (arity two) fork.  This file
builds the **arity `r` fork channel** and proves the structural facts that were
listed as open conjectures after the previous cycle.

Model.  A number `N = p₁ ⋯ p_r` whose factors have independent uniform classes
`χ(pᵢ)` in a cyclic character group of order `n`.  The split-count is
`s = #{i : χ(pᵢ) = 1} ∈ {0, …, r}`, and the observable class of `N` is the
binary event `χ(N) = 1`.  Writing `m = r − s` for the number of non-splitting
factors, the number of `m`-tuples of *non-identity* classes whose product is the
identity is `altCount n m = ((n−1)^m + (n−1)(−1)^m)/n`, so the joint law of
`(class of N, split-count)` is the table `forkJointR r n` below.

Main results (all with no `sorry`):

* `rowMarg_forkJointR_zero`, `rowMarg_forkJointR_one` — the class prior is
  `(1/n, (n−1)/n)` at **every** arity;
* `colMarg_forkJointR` — the split-count marginal is exactly `Bin(r, 1/n)`,
  again at every arity;
* `forkJointR_two` — at `r = 2` the table is literally the semiprime table of
  `SplitCountChannel`, so `IsR 2 = Is`;
* `IsR_le_one` — the one-bit cap holds at every arity;
* `IsR_two_eq_one` — at the quadratic characters (`n = 2`) the channel is
  *complete*, `IsR r 2 = 1` for every `r ≥ 1`: the parity of the split-count
  determines the class exactly;
* `mutualInfo_le_chiSquare` — a general χ²-bound for finite tables;
* `chiSquare_forkJointR` — the χ² divergence of the fork table is **exactly**
  `(n−1)^{1−r}`, an exact binomial identity;
* `IsR_le_geometric` — hence `IsR r n ≤ (n−1)/((n−1)^r log 2)`: the fork channel
  **decays at least geometrically in the arity**, so more factors never amplify
  the signal (`IsR_tendsto_zero_arity`), and for `n ≥ 3, r ≥ 2` the one-bit cap is
  never attained (`IsR_lt_one`).
-/

namespace SplitCountArity

open Finset Real SplitCountLaw

/-! ## A χ² bound for finite tables -/

section ChiSquare

variable {α β : Type*} [Fintype α] [Fintype β]

/-- χ² divergence between a joint table and the product of its marginals. -/
noncomputable def chiSquare (p : α → β → ℝ) : ℝ :=
  ∑ a, ∑ b, (p a b - rowMarg p a * colMarg p b) ^ 2 / (rowMarg p a * colMarg p b)

/-- **Mutual information is dominated by the χ² divergence** (in nats). -/
theorem mutualInfo_le_chiSquare (p : α → β → ℝ) (hp : ∀ a b, 0 ≤ p a b)
    (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b)
    (htot : ∑ a, rowMarg p a = 1) :
    mutualInfo p * Real.log 2 ≤ chiSquare p := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hcoltot : ∑ b, colMarg p b = 1 := by
    have : ∑ b, colMarg p b = ∑ a, rowMarg p a := by
      simp only [colMarg, rowMarg]; exact Finset.sum_comm
    rw [this, htot]
  -- cellwise bound
  have cell : ∀ a b, p a b * Real.log (p a b / (rowMarg p a * colMarg p b)) ≤
      (p a b - rowMarg p a * colMarg p b) ^ 2 / (rowMarg p a * colMarg p b)
        + (p a b - rowMarg p a * colMarg p b) := by
    intro a b
    set q := rowMarg p a * colMarg p b with hq
    have hq0 : 0 < q := mul_pos (hrow a) (hcol b)
    rcases eq_or_lt_of_le (hp a b) with h | h
    · rw [← h]
      simp only [zero_mul, zero_sub, neg_sq]
      rw [sq]
      rw [mul_div_assoc, div_self (ne_of_gt hq0)]
      simp
    · have hlog : Real.log (p a b / q) ≤ p a b / q - 1 :=
        Real.log_le_sub_one_of_pos (div_pos h hq0)
      have h1 : p a b * Real.log (p a b / q) ≤ p a b * (p a b / q - 1) :=
        mul_le_mul_of_nonneg_left hlog h.le
      have h2 : p a b * (p a b / q - 1) = (p a b - q) ^ 2 / q + (p a b - q) := by
        field_simp; ring
      linarith [h2 ▸ h1]
  have hsum : mutualInfo p * Real.log 2
      = ∑ a, ∑ b, p a b * Real.log (p a b / (rowMarg p a * colMarg p b)) := by
    simp only [mutualInfo, Real.logb, Finset.sum_mul]
    refine Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun b _ => ?_))
    field_simp
  have hzero : ∑ a, ∑ b, (p a b - rowMarg p a * colMarg p b) = 0 := by
    have : ∀ a, ∑ b, (p a b - rowMarg p a * colMarg p b)
        = rowMarg p a - rowMarg p a * ∑ b, colMarg p b := by
      intro a
      rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
      rfl
    rw [Finset.sum_congr rfl (fun a _ => this a)]
    simp [hcoltot]
  calc mutualInfo p * Real.log 2
      = ∑ a, ∑ b, p a b * Real.log (p a b / (rowMarg p a * colMarg p b)) := hsum
    _ ≤ ∑ a, ∑ b, ((p a b - rowMarg p a * colMarg p b) ^ 2 / (rowMarg p a * colMarg p b)
          + (p a b - rowMarg p a * colMarg p b)) :=
        Finset.sum_le_sum (fun a _ => Finset.sum_le_sum (fun b _ => cell a b))
    _ = chiSquare p := by
        simp only [chiSquare, Finset.sum_add_distrib]
        rw [hzero, add_zero]

end ChiSquare

/-! ## The arity-`r` fork channel -/

/-- `altCount n m` : the (normalised) number of `m`-tuples of non-identity
classes in a cyclic group of order `n` whose product is the identity, divided by
`n^{m}`-free normalisation; explicitly `((n−1)^m + (n−1)(−1)^m)/n`. -/
noncomputable def altCount (n : ℝ) (m : ℕ) : ℝ := ((n - 1) ^ m + (n - 1) * (-1) ^ m) / n

/-- The joint law of (class of `N`, split-count) for an arity-`r` fork. -/
noncomputable def forkJointR (r : ℕ) (n : ℝ) : Fin 2 → Fin (r + 1) → ℝ := fun a k =>
  if a = 0 then (r.choose k : ℝ) * altCount n (r - (k : ℕ)) / n ^ r
  else (r.choose k : ℝ) * ((n - 1) ^ (r - (k : ℕ)) - altCount n (r - (k : ℕ))) / n ^ r

/-- The information (in bits) carried by the split-count of an arity-`r` fork. -/
noncomputable def IsR (r : ℕ) (n : ℝ) : ℝ := mutualInfo (forkJointR r n)

/-- `Bin(r, 1/n)` on `{0, …, r}`. -/
noncomputable def binomR (r : ℕ) (n : ℝ) : Fin (r + 1) → ℝ := fun k =>
  (r.choose k : ℝ) * (n - 1) ^ (r - (k : ℕ)) / n ^ r

/-! ### Binomial sums -/

lemma sum_choose_pow (r : ℕ) (y : ℝ) :
    ∑ k : Fin (r + 1), (r.choose (k : ℕ) : ℝ) * y ^ (r - (k : ℕ)) = (1 + y) ^ r := by
  rw [Fin.sum_univ_eq_sum_range (fun k => (r.choose k : ℝ) * y ^ (r - k)), add_pow]
  exact Finset.sum_congr rfl (fun k _ => by ring)

/-! ### The entries of the table -/

variable {r : ℕ} {n : ℝ}

lemma forkJointR_zero_eq (hn : n ≠ 0) (k : Fin (r + 1)) :
    forkJointR r n 0 k =
      (r.choose (k : ℕ) : ℝ) * ((n - 1) ^ (r - (k : ℕ)) + (n - 1) * (-1) ^ (r - (k : ℕ)))
        / n ^ (r + 1) := by
  have h : forkJointR r n 0 k = (r.choose (k : ℕ) : ℝ) * altCount n (r - (k : ℕ)) / n ^ r := by
    simp [forkJointR]
  rw [h, altCount, pow_succ]
  field_simp

lemma forkJointR_one_eq (hn : n ≠ 0) (k : Fin (r + 1)) :
    forkJointR r n 1 k =
      (r.choose (k : ℕ) : ℝ) * ((n - 1) * ((n - 1) ^ (r - (k : ℕ)) - (-1) ^ (r - (k : ℕ))))
        / n ^ (r + 1) := by
  have h : forkJointR r n 1 k =
      (r.choose (k : ℕ) : ℝ) * ((n - 1) ^ (r - (k : ℕ)) - altCount n (r - (k : ℕ))) / n ^ r := by
    simp [forkJointR]
  rw [h, altCount, pow_succ]
  field_simp
  ring

/-- The two rows of a column add up to the `Bin(r,1/n)` weight. -/
lemma forkJointR_col_add (hn : n ≠ 0) (k : Fin (r + 1)) :
    forkJointR r n 0 k + forkJointR r n 1 k = binomR r n k := by
  rw [forkJointR_zero_eq hn, forkJointR_one_eq hn]
  simp only [binomR, pow_succ]
  field_simp
  ring

/-! ### Nonnegativity -/

lemma alt_nonneg (hn : 2 ≤ n) (m : ℕ) : 0 ≤ (n - 1) ^ m + (n - 1) * (-1 : ℝ) ^ m := by
  have hu : (1:ℝ) ≤ n - 1 := by linarith
  rcases Nat.even_or_odd m with he | ho
  · rw [he.neg_one_pow]
    have : (0:ℝ) ≤ (n - 1) ^ m := by positivity
    linarith
  · rw [ho.neg_one_pow]
    have h1 : (n - 1) ^ 1 ≤ (n - 1) ^ m :=
      pow_le_pow_right₀ hu ho.pos
    simp only [pow_one] at h1
    linarith

lemma alt_le (hn : 2 ≤ n) (m : ℕ) : 0 ≤ (n - 1) ^ m - (-1 : ℝ) ^ m := by
  have hu : (1:ℝ) ≤ n - 1 := by linarith
  have h1 : (1:ℝ) ≤ (n - 1) ^ m := one_le_pow₀ hu
  rcases Nat.even_or_odd m with he | ho
  · rw [he.neg_one_pow]; linarith
  · rw [ho.neg_one_pow]; linarith

lemma forkJointR_nonneg (hn : 2 ≤ n) : ∀ a k, 0 ≤ forkJointR r n a k := by
  have hn0 : (0:ℝ) < n := by linarith
  intro a k
  have hpow : (0:ℝ) < n ^ (r + 1) := by positivity
  have h0 : 0 ≤ forkJointR r n 0 k := by
    rw [forkJointR_zero_eq (ne_of_gt hn0)]
    have := alt_nonneg hn (r - (k : ℕ))
    positivity
  have h1 : 0 ≤ forkJointR r n 1 k := by
    rw [forkJointR_one_eq (ne_of_gt hn0)]
    have hh := alt_le hn (r - (k : ℕ))
    have h2 : (0:ℝ) ≤ n - 1 := by linarith
    positivity
  fin_cases a
  · exact h0
  · exact h1

/-! ### Marginals -/

/-- The class prior is `1/n` on `χ(N) = 1`, at every arity. -/
lemma rowMarg_forkJointR_zero (hr : r ≠ 0) (hn : 2 ≤ n) :
    rowMarg (forkJointR r n) 0 = 1 / n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hsplit : ∀ k : Fin (r + 1), forkJointR r n 0 k =
      ((r.choose (k : ℕ) : ℝ) * (n - 1) ^ (r - (k : ℕ))
        + (n - 1) * ((r.choose (k : ℕ) : ℝ) * (-1 : ℝ) ^ (r - (k : ℕ)))) / n ^ (r + 1) := by
    intro k; rw [forkJointR_zero_eq (ne_of_gt hn0)]; ring_nf
  simp only [rowMarg, hsplit, ← Finset.sum_div, Finset.sum_add_distrib, ← Finset.mul_sum,
    sum_choose_pow]
  have h0 : (1 : ℝ) + (-1) = 0 := by norm_num
  rw [h0, zero_pow hr]
  have hnn : (1 : ℝ) + (n - 1) = n := by ring
  rw [hnn]
  field_simp
  ring

/-- The class prior is `(n−1)/n` on `χ(N) ≠ 1`, at every arity. -/
lemma rowMarg_forkJointR_one (hr : r ≠ 0) (hn : 2 ≤ n) :
    rowMarg (forkJointR r n) 1 = (n - 1) / n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hsplit : ∀ k : Fin (r + 1), forkJointR r n 1 k =
      ((n - 1) * ((r.choose (k : ℕ) : ℝ) * (n - 1) ^ (r - (k : ℕ)))
        - (n - 1) * ((r.choose (k : ℕ) : ℝ) * (-1 : ℝ) ^ (r - (k : ℕ)))) / n ^ (r + 1) := by
    intro k; rw [forkJointR_one_eq (ne_of_gt hn0)]; ring_nf
  simp only [rowMarg, hsplit, ← Finset.sum_div, Finset.sum_sub_distrib, ← Finset.mul_sum,
    sum_choose_pow]
  have h0 : (1 : ℝ) + (-1) = 0 := by norm_num
  rw [h0, zero_pow hr]
  have hnn : (1 : ℝ) + (n - 1) = n := by ring
  rw [hnn]
  field_simp
  ring

/-- **The split-count marginal is exactly `Bin(r, 1/n)`, at every arity.** -/
theorem colMarg_forkJointR (hn : 2 ≤ n) : colMarg (forkJointR r n) = binomR r n := by
  have hn0 : (0:ℝ) < n := by linarith
  funext k
  simp only [colMarg, Fin.sum_univ_two]
  exact forkJointR_col_add (ne_of_gt hn0) k

lemma binomR_pos (hn : 2 ≤ n) (k : Fin (r + 1)) : 0 < binomR r n k := by
  have hn0 : (0:ℝ) < n := by linarith
  have hu : (0:ℝ) < n - 1 := by linarith
  have hc : (0:ℝ) < (r.choose (k : ℕ) : ℝ) := by
    have : 0 < r.choose (k : ℕ) := Nat.choose_pos (Nat.lt_succ_iff.mp k.isLt)
    exact_mod_cast this
  have : (0:ℝ) < (n - 1) ^ (r - (k : ℕ)) := by positivity
  have hp : (0:ℝ) < n ^ r := by positivity
  simp only [binomR]
  positivity

lemma colMarg_forkJointR_pos (hn : 2 ≤ n) (k : Fin (r + 1)) :
    0 < colMarg (forkJointR r n) k := by
  rw [colMarg_forkJointR hn]; exact binomR_pos hn k

lemma rowMarg_forkJointR_pos (hr : r ≠ 0) (hn : 2 ≤ n) (a : Fin 2) :
    0 < rowMarg (forkJointR r n) a := by
  have hn0 : (0:ℝ) < n := by linarith
  have h0 : 0 < rowMarg (forkJointR r n) 0 := by
    rw [rowMarg_forkJointR_zero hr hn]; positivity
  have h1 : 0 < rowMarg (forkJointR r n) 1 := by
    rw [rowMarg_forkJointR_one hr hn]
    exact div_pos (by linarith) hn0
  fin_cases a
  · exact h0
  · exact h1

lemma rowMarg_forkJointR_sum (hr : r ≠ 0) (hn : 2 ≤ n) :
    rowMarg (forkJointR r n) 0 + rowMarg (forkJointR r n) 1 = 1 := by
  have hn0 : (0:ℝ) < n := by linarith
  rw [rowMarg_forkJointR_zero hr hn, rowMarg_forkJointR_one hr hn]
  field_simp
  ring

/-- **The one-bit cap holds at every arity.** -/
theorem IsR_le_one (hr : r ≠ 0) (hn : 2 ≤ n) : IsR r n ≤ 1 :=
  mutualInfo_le_one_of_binary _ (forkJointR_nonneg hn) (rowMarg_forkJointR_pos hr hn)
    (colMarg_forkJointR_pos hn) (rowMarg_forkJointR_sum hr hn)

lemma IsR_nonneg (hr : r ≠ 0) (hn : 2 ≤ n) : 0 ≤ IsR r n :=
  mutualInfo_nonneg _ (forkJointR_nonneg hn) (rowMarg_forkJointR_pos hr hn)
    (colMarg_forkJointR_pos hn) (by
      have := rowMarg_forkJointR_sum hr hn
      simpa [Fin.sum_univ_two] using this)

/-! ## The exact χ² divergence of the fork table -/

lemma diff_zero_eq (hr : r ≠ 0) (hn : 2 ≤ n) (k : Fin (r + 1)) :
    forkJointR r n 0 k - rowMarg (forkJointR r n) 0 * colMarg (forkJointR r n) k
      = (r.choose (k : ℕ) : ℝ) * ((n - 1) * (-1) ^ (r - (k : ℕ))) / n ^ (r + 1) := by
  have hn0 : (0:ℝ) < n := by linarith
  rw [forkJointR_zero_eq (ne_of_gt hn0), rowMarg_forkJointR_zero hr hn,
    colMarg_forkJointR hn]
  simp only [binomR, pow_succ]
  field_simp
  ring

lemma diff_one_eq (hr : r ≠ 0) (hn : 2 ≤ n) (k : Fin (r + 1)) :
    forkJointR r n 1 k - rowMarg (forkJointR r n) 1 * colMarg (forkJointR r n) k
      = -((r.choose (k : ℕ) : ℝ) * ((n - 1) * (-1) ^ (r - (k : ℕ))) / n ^ (r + 1)) := by
  have hn0 : (0:ℝ) < n := by linarith
  rw [forkJointR_one_eq (ne_of_gt hn0), rowMarg_forkJointR_one hr hn,
    colMarg_forkJointR hn]
  simp only [binomR, pow_succ]
  field_simp
  ring

lemma neg_one_pow_sq (m : ℕ) : ((-1 : ℝ) ^ m) ^ 2 = 1 := by
  rw [← pow_mul, mul_comm, pow_mul]
  norm_num

/-- The χ² contribution of one column of the fork table. -/
lemma chiSquare_cell (hr : r ≠ 0) (hn : 2 ≤ n) (k : Fin (r + 1)) :
    (forkJointR r n 0 k - rowMarg (forkJointR r n) 0 * colMarg (forkJointR r n) k) ^ 2
        / (rowMarg (forkJointR r n) 0 * colMarg (forkJointR r n) k)
      + (forkJointR r n 1 k - rowMarg (forkJointR r n) 1 * colMarg (forkJointR r n) k) ^ 2
        / (rowMarg (forkJointR r n) 1 * colMarg (forkJointR r n) k)
      = ((n - 1) ^ 2 + (n - 1)) / n ^ (r + 1)
          * ((r.choose (k : ℕ) : ℝ) * (1 / (n - 1)) ^ (r - (k : ℕ))) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hu : (0:ℝ) < n - 1 := by linarith
  have hum : (0:ℝ) < (n - 1) ^ (r - (k : ℕ)) := by positivity
  have hc : (0:ℝ) < (r.choose (k : ℕ) : ℝ) := by
    have : 0 < r.choose (k : ℕ) := Nat.choose_pos (Nat.lt_succ_iff.mp k.isLt)
    exact_mod_cast this
  have hsq : ((r.choose (k : ℕ) : ℝ) * ((n - 1) * (-1) ^ (r - (k : ℕ))) / n ^ (r + 1)) ^ 2
      = (r.choose (k : ℕ) : ℝ) ^ 2 * (n - 1) ^ 2 / (n ^ (r + 1)) ^ 2 := by
    rw [div_pow, mul_pow, mul_pow, neg_one_pow_sq, mul_one]
  rw [diff_zero_eq hr hn, diff_one_eq hr hn, neg_sq, hsq,
    rowMarg_forkJointR_zero hr hn, rowMarg_forkJointR_one hr hn, colMarg_forkJointR hn]
  simp only [binomR, one_div, inv_pow]
  rw [pow_succ]
  field_simp
  ring

/-- **The χ² divergence of the arity-`r` fork table is exactly `(n−1)^{1−r}`.** -/
theorem chiSquare_forkJointR (hr : r ≠ 0) (hn : 2 ≤ n) :
    chiSquare (forkJointR r n) = (n - 1) / (n - 1) ^ r := by
  have hn0 : (0:ℝ) < n := by linarith
  have hu : (0:ℝ) < n - 1 := by linarith
  have hstep : chiSquare (forkJointR r n)
      = ∑ k : Fin (r + 1), ((n - 1) ^ 2 + (n - 1)) / n ^ (r + 1)
          * ((r.choose (k : ℕ) : ℝ) * (1 / (n - 1)) ^ (r - (k : ℕ))) := by
    simp only [chiSquare, Fin.sum_univ_two, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun k _ => chiSquare_cell hr hn k)
  rw [hstep, ← Finset.mul_sum, sum_choose_pow]
  rw [show (1 : ℝ) + 1 / (n - 1) = n / (n - 1) by field_simp; ring, div_pow]
  rw [pow_succ]
  field_simp
  ring

/-! ## Geometric decay in the arity -/

/-- **No amplification.**  The information a fork carries about the class of `N`
decays at least geometrically in the number of factors:
`IsR r n ≤ (n−1)^{1−r} / log 2`. -/
theorem IsR_le_geometric (hr : r ≠ 0) (hn : 2 ≤ n) :
    IsR r n ≤ (n - 1) / ((n - 1) ^ r * Real.log 2) := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hu : (0:ℝ) < n - 1 := by linarith
  have h := mutualInfo_le_chiSquare (forkJointR r n) (forkJointR_nonneg hn)
    (rowMarg_forkJointR_pos hr hn) (colMarg_forkJointR_pos hn)
    (by simpa [Fin.sum_univ_two] using rowMarg_forkJointR_sum hr hn)
  rw [chiSquare_forkJointR hr hn] at h
  rw [le_div_iff₀ (by positivity)]
  calc IsR r n * ((n - 1) ^ r * Real.log 2)
      = (IsR r n * Real.log 2) * (n - 1) ^ r := by ring
    _ ≤ ((n - 1) / (n - 1) ^ r) * (n - 1) ^ r := by
        exact mul_le_mul_of_nonneg_right h (by positivity)
    _ = n - 1 := by field_simp

/-- For `n ≥ 3` and arity at least two the one-bit cap is never attained. -/
theorem IsR_lt_one (hr : 2 ≤ r) (hn : 3 ≤ n) : IsR r n < 1 := by
  have hu : (2:ℝ) ≤ n - 1 := by linarith
  have hu0 : (0:ℝ) < n - 1 := by linarith
  have hl2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hpow : (n - 1) ^ 2 ≤ (n - 1) ^ r := pow_le_pow_right₀ (by linarith) hr
  have hbound := IsR_le_geometric (r := r) (n := n) (by omega) (by linarith)
  have key : (n - 1) / ((n - 1) ^ r * Real.log 2) < 1 := by
    rw [div_lt_one (by positivity)]
    have h1 : (n - 1) * 2 ≤ (n - 1) ^ 2 := by nlinarith
    nlinarith [mul_pos hu0 (by linarith : (0:ℝ) < Real.log 2)]
  linarith

/-- The fork channel vanishes as the number of factors grows (`n ≥ 3` fixed). -/
theorem IsR_tendsto_zero_arity (hn : 3 ≤ n) :
    Filter.Tendsto (fun r : ℕ => IsR (r + 1) n) Filter.atTop (nhds 0) := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hu : (1:ℝ) < n - 1 := by linarith
  have hpow : Filter.Tendsto (fun r : ℕ => (n - 1) ^ (r + 1)) Filter.atTop Filter.atTop := by
    have := tendsto_pow_atTop_atTop_of_one_lt hu
    exact this.comp (Filter.tendsto_add_atTop_nat 1)
  have hub : Filter.Tendsto
      (fun r : ℕ => (n - 1) / ((n - 1) ^ (r + 1) * Real.log 2)) Filter.atTop (nhds 0) := by
    have hmul : Filter.Tendsto (fun r : ℕ => (n - 1) ^ (r + 1) * Real.log 2)
        Filter.atTop Filter.atTop :=
      Filter.Tendsto.atTop_mul_const hl2 hpow
    have h0 := hmul.inv_tendsto_atTop.const_mul (n - 1)
    rw [mul_zero] at h0
    exact h0.congr (fun r => by simp [div_eq_mul_inv])
  refine squeeze_zero (fun r => IsR_nonneg (r := r + 1) (n := n) (by omega) (by linarith))
    (fun r => ?_) hub
  exact IsR_le_geometric (r := r + 1) (n := n) (by omega) (by linarith)

/-! ## Consistency with the semiprime channel -/

/-- At arity two the table is literally the semiprime fork table of
`SplitCountChannel`. -/
theorem forkJointR_two (hn : 2 ≤ n) : forkJointR 2 n = SplitCountChannel.forkJoint n := by
  have hn0 : (0:ℝ) < n := by linarith
  funext a k
  fin_cases a <;> fin_cases k <;>
    simp [forkJointR, altCount, SplitCountChannel.forkJoint, SplitCountChannel.prior,
      SplitCountChannel.cond] <;>
    (try field_simp) <;> ((try ring_nf); (try (exact Or.inl trivial)))

/-- Hence the arity-two case of the present channel is exactly `Is`. -/
theorem IsR_two_eq_Is (hn : 2 ≤ n) : IsR 2 n = SplitCountChannel.Is n := by
  rw [IsR, forkJointR_two hn, SplitCountChannel.Is]

/-! ## The quadratic characters: the channel is complete at every arity -/

/-- **At `n = 2` the split-count determines the class exactly, at every arity.**
The parity of the number of non-splitting factors *is* the class of `N`, so the
channel carries a full bit however many factors `N` has. -/
theorem IsR_two_eq_one (hr : r ≠ 0) : IsR r 2 = 1 := by
  have h2 : (2:ℝ) ≤ 2 := le_refl _
  have hrow0 : rowMarg (forkJointR r 2) 0 = 1 / 2 := by
    rw [rowMarg_forkJointR_zero hr h2]
  have hrow1 : rowMarg (forkJointR r 2) 1 = 1 / 2 := by
    rw [rowMarg_forkJointR_one hr h2]; norm_num
  have hcol : ∀ k : Fin (r + 1),
      colMarg (forkJointR r 2) k = (r.choose (k : ℕ) : ℝ) / 2 ^ r := by
    intro k; rw [colMarg_forkJointR h2]; norm_num [binomR]
  have hcell : ∀ k : Fin (r + 1),
      forkJointR r 2 0 k * logb 2 (forkJointR r 2 0 k
          / (rowMarg (forkJointR r 2) 0 * colMarg (forkJointR r 2) k))
        + forkJointR r 2 1 k * logb 2 (forkJointR r 2 1 k
          / (rowMarg (forkJointR r 2) 1 * colMarg (forkJointR r 2) k))
      = (r.choose (k : ℕ) : ℝ) / 2 ^ r := by
    intro k
    have hc : (0:ℝ) < (r.choose (k : ℕ) : ℝ) := by
      have : 0 < r.choose (k : ℕ) := Nat.choose_pos (Nat.lt_succ_iff.mp k.isLt)
      exact_mod_cast this
    have hp : (0:ℝ) < (2:ℝ) ^ r := by positivity
    have hhalf : (1/2 : ℝ) * ((r.choose (k : ℕ) : ℝ) / 2 ^ r)
        = (r.choose (k : ℕ) : ℝ) / 2 ^ (r + 1) := by
      rw [pow_succ]; ring
    have hratio : ((r.choose (k : ℕ) : ℝ) / 2 ^ r)
        / ((1/2 : ℝ) * ((r.choose (k : ℕ) : ℝ) / 2 ^ r)) = 2 := by
      rw [hhalf, pow_succ]
      field_simp
    rw [hrow0, hrow1, hcol, forkJointR_zero_eq (by norm_num), forkJointR_one_eq (by norm_num)]
    rcases Nat.even_or_odd (r - (k : ℕ)) with he | ho
    · have he1 : ((-1:ℝ)) ^ (r - (k : ℕ)) = 1 := he.neg_one_pow
      have hA : (r.choose (k : ℕ) : ℝ)
            * (((2:ℝ) - 1) ^ (r - (k : ℕ)) + ((2:ℝ) - 1) * (-1) ^ (r - (k : ℕ))) / 2 ^ (r + 1)
          = (r.choose (k : ℕ) : ℝ) / 2 ^ r := by
        rw [he1, pow_succ]; norm_num; ring
      have hB : (r.choose (k : ℕ) : ℝ)
            * (((2:ℝ) - 1) * (((2:ℝ) - 1) ^ (r - (k : ℕ)) - (-1) ^ (r - (k : ℕ)))) / 2 ^ (r + 1)
          = 0 := by
        rw [he1]; norm_num
      rw [hA, hB, hratio]
      simp [Real.logb_self_eq_one]
    · have he1 : ((-1:ℝ)) ^ (r - (k : ℕ)) = -1 := ho.neg_one_pow
      have hA : (r.choose (k : ℕ) : ℝ)
            * (((2:ℝ) - 1) ^ (r - (k : ℕ)) + ((2:ℝ) - 1) * (-1) ^ (r - (k : ℕ))) / 2 ^ (r + 1)
          = 0 := by
        rw [he1]; norm_num
      have hB : (r.choose (k : ℕ) : ℝ)
            * (((2:ℝ) - 1) * (((2:ℝ) - 1) ^ (r - (k : ℕ)) - (-1) ^ (r - (k : ℕ)))) / 2 ^ (r + 1)
          = (r.choose (k : ℕ) : ℝ) / 2 ^ r := by
        rw [he1, pow_succ]; norm_num; ring
      rw [hA, hB, hratio]
      simp [Real.logb_self_eq_one]
  have hsum : IsR r 2 = ∑ k : Fin (r + 1), (r.choose (k : ℕ) : ℝ) / 2 ^ r := by
    simp only [IsR, mutualInfo, Fin.sum_univ_two, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun k _ => hcell k)
  rw [hsum]
  have : ∑ k : Fin (r + 1), (r.choose (k : ℕ) : ℝ) / 2 ^ r
      = (∑ k : Fin (r + 1), (r.choose (k : ℕ) : ℝ) * (1:ℝ) ^ (r - (k : ℕ))) / 2 ^ r := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl (fun k _ => by simp)
  rw [this, sum_choose_pow]
  norm_num

end SplitCountArity