import Mathlib
import Novelty.SplitCountLaw

/-!
# The split-count law of a character-pinned fork

Fix a finite abelian character group of order `n ≥ 2` (a "residue dial": think of
`χ` a character mod `f` of order `n`, and of `split(p)` meaning `χ(p) = 1`).
For a semiprime `N = p q` with `χ(p), χ(q)` independent and uniform over the `n`
character values, the *split-count*

`s = [split p] + [split q] ∈ {0, 1, 2}`

is the complete symmetric observable of the fork. Conditioning on the residue
class of `N` only through the binary event `χ(N) = 1` (probability `1/n`) gives
the **order-universal split-count channel**

* `P(s | χ(N) = 1)   = ((n-1)/n, 0, 1/n)`
* `P(s | χ(N) ≠ 1)   = ((n-2)/n, 2/n, 0)`

and this file proves, with no `sorry`:

* `colMarg_forkJoint` : the split-count marginal is **exactly** `Bin(2, 1/n)`;
* `Is_eq_closedForm` : `Is n = H(Bin(2,1/n)) - (1/n) H(cond₁) - ((n-1)/n) H(cond₂)`;
* `Is_two : Is 2 = 1` and `Is_three : Is 3 = logb 2 3 - 10/9 ≈ 0.4739`;
* `Ior_two : Ior 2 = 3/2 - (3/4) logb 2 3 ≈ 0.3113`, the "OR cap", and
  `Ior_two_lt_Is_two`: the OR value is *strictly* below the full channel, so the
  OR cap is a projection artifact;
* `Ixor_two : Ixor 2 = 1 = Is 2`: at the quadratic characters XOR is complete;
* `Ior_le_Is`, `Iand_le_Is`, `Ixor_le_Is` : every Boolean face of the fork is
  dominated by the split-count (data processing);
* `Is_le_one` : the whole channel is capped at one bit, for every order `n`;
* `Ipair_eq_Is` : the *ordered* pair of split events carries exactly `Is n`,
  i.e. the split-count is a sufficient statistic — the symmetric fork channel is
  the split-count and nothing more;
* `Ifirst_eq_zero` : the which-factor wall — a *single* factor's split event is
  exactly independent of the class of `N`;
* `hierarchy_three` : `OR(3) < AND(3) < XOR(3) < Is(3)`, with exact closed forms;
* `hierarchy_eight` : `OR(8) < XOR(8) < AND(8) < Is(8)` — the naive chain fails
  from `n = 8`, AND overtaking XOR (settled by an exact integer certificate);
* `Is_pos` : the channel is never vacuous, `0 < Is n` for every `n ≥ 2`;
* `Is_lt_one` : for `n > 2` the cap is not attained, and `Is_tendsto_zero` :
  `Is n → 0` as the order grows.

All statements are for a real parameter `n ≥ 2`, which contains the integer
orders `n = 2, 3, 4, …` as special cases.
-/

namespace SplitCountChannel

open Finset Real SplitCountLaw

/-! ## The channel -/

/-- Prior on the two classes `χ(N) = 1` (weight `1/n`) and `χ(N) ≠ 1`. -/
noncomputable def prior (n : ℝ) : Fin 2 → ℝ := ![1 / n, (n - 1) / n]

/-- The conditional split-count laws: `((n-1)/n, 0, 1/n)` on the class `χ(N) = 1`
and `((n-2)/n, 2/n, 0)` on the class `χ(N) ≠ 1`. -/
noncomputable def cond (n : ℝ) : Fin 2 → Fin 3 → ℝ :=
  ![![(n - 1) / n, 0, 1 / n], ![(n - 2) / n, 2 / n, 0]]

/-- The joint law of (class of `N`, split-count of the fork). -/
noncomputable def forkJoint (n : ℝ) : Fin 2 → Fin 3 → ℝ := fun a s => prior n a * cond n a s

/-- The binomial law `Bin(2, 1/n)` on `{0,1,2}`. -/
noncomputable def binom2 (n : ℝ) : Fin 3 → ℝ := ![((n - 1) / n) ^ 2, 2 * (n - 1) / n ^ 2, 1 / n ^ 2]

/-- `Is n` : the information (in bits) that the split-count carries about the
residue class of `N`. -/
noncomputable def Is (n : ℝ) : ℝ := mutualInfo (forkJoint n)

variable {n : ℝ}

lemma prior_nonneg (hn : 2 ≤ n) : ∀ a, 0 ≤ prior n a := by
  have hn0 : (0:ℝ) < n := by linarith
  have h1 : (0:ℝ) ≤ 1 / n := by positivity
  have h2 : (0:ℝ) ≤ (n - 1) / n := div_nonneg (by linarith) hn0.le
  intro a
  fin_cases a
  · simpa [prior] using h1
  · simpa [prior] using h2

lemma prior_sum (hn : 2 ≤ n) : ∑ a, prior n a = 1 := by
  have hn0 : (0:ℝ) ≠ n := by intro h; linarith [h.symm ▸ hn]
  simp [prior, Fin.sum_univ_two]
  field_simp
  ring

lemma cond_nonneg (hn : 2 ≤ n) : ∀ a s, 0 ≤ cond n a s := by
  have hn0 : (0:ℝ) < n := by linarith
  have e1 : (0:ℝ) ≤ (n - 1) / n := div_nonneg (by linarith) hn0.le
  have e2 : (0:ℝ) ≤ 1 / n := by positivity
  have e3 : (0:ℝ) ≤ (n - 2) / n := div_nonneg (by linarith) hn0.le
  have e4 : (0:ℝ) ≤ 2 / n := by positivity
  intro a s
  fin_cases a <;> fin_cases s
  · simpa [cond] using e1
  · simp [cond]
  · simpa [cond] using e2
  · simpa [cond] using e3
  · simpa [cond] using e4
  · simp [cond]

lemma cond_sum (hn : 2 ≤ n) : ∀ a, ∑ s, cond n a s = 1 := by
  have hn0 : (0:ℝ) < n := by linarith
  intro a
  fin_cases a <;> simp [cond, Fin.sum_univ_three] <;> field_simp <;> ring

lemma forkJoint_nonneg (hn : 2 ≤ n) : ∀ a s, 0 ≤ forkJoint n a s :=
  fun a s => mul_nonneg (prior_nonneg hn a) (cond_nonneg hn a s)

lemma rowMarg_forkJoint (hn : 2 ≤ n) (a : Fin 2) : rowMarg (forkJoint n) a = prior n a := by
  simp only [rowMarg, forkJoint, ← Finset.mul_sum, cond_sum hn a, mul_one]

/-- **The split-count marginal is exactly `Bin(2, 1/n)`.** -/
theorem colMarg_forkJoint (hn : 2 ≤ n) : colMarg (forkJoint n) = binom2 n := by
  have hn0 : (0:ℝ) < n := by linarith
  funext s
  fin_cases s <;>
    simp [colMarg, forkJoint, prior, cond, binom2, Fin.sum_univ_two] <;> field_simp; ring

lemma binom2_pos (hn : 2 ≤ n) : ∀ s, 0 < binom2 n s := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  have b0 : (0:ℝ) < ((n - 1) / n) ^ 2 := pow_pos (div_pos hn1 hn0) 2
  have b1 : (0:ℝ) < 2 * (n - 1) / n ^ 2 := div_pos (by linarith) (by positivity)
  have b2 : (0:ℝ) < 1 / n ^ 2 := by positivity
  intro s
  fin_cases s
  · simpa [binom2] using b0
  · simpa [binom2] using b1
  · simpa [binom2] using b2

lemma colMarg_pos (hn : 2 ≤ n) : ∀ s, 0 < colMarg (forkJoint n) s := by
  rw [colMarg_forkJoint hn]; exact binom2_pos hn

/-- **The exact split-count law.**
`Is n = H(Bin(2,1/n)) - (1/n) H((n-1)/n, 0, 1/n) - ((n-1)/n) H((n-2)/n, 2/n, 0)`. -/
theorem Is_eq_closedForm (hn : 2 ≤ n) :
    Is n = entropyBits (binom2 n)
      - (1 / n) * entropyBits (cond n 0) - ((n - 1) / n) * entropyBits (cond n 1) := by
  have hcol : ∀ s, 0 < colMarg (fun a s => prior n a * cond n a s) s := colMarg_pos hn
  have h := mutualInfo_of_channel (prior n) (cond n) (prior_nonneg hn) (cond_nonneg hn)
    (cond_sum hn) hcol
  have hIs : Is n = mutualInfo (fun a s => prior n a * cond n a s) := rfl
  rw [hIs, h]
  have hc : colMarg (fun a s => prior n a * cond n a s) = binom2 n := colMarg_forkJoint hn
  rw [hc, Fin.sum_univ_two]
  simp only [prior, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-! ## Numerical values of the channel -/

private lemma logb_two_val : Real.logb 2 2 = 1 := by simp

private lemma logb_four : Real.logb 2 4 = 2 := by
  rw [show (4:ℝ) = 2 ^ (2:ℕ) by norm_num, Real.logb_pow]; simp

private lemma logb_nine : Real.logb 2 9 = 2 * Real.logb 2 3 := by
  rw [show (9:ℝ) = 3 ^ (2:ℕ) by norm_num, Real.logb_pow]; ring

private lemma logb_half : Real.logb 2 (1/2) = -1 := by
  rw [Real.logb_div (by norm_num) (by norm_num)]; simp

private lemma logb_quarter : Real.logb 2 (1/4) = -2 := by
  rw [Real.logb_div (by norm_num) (by norm_num), logb_four]; simp

private lemma logb_two_thirds : Real.logb 2 (2/3) = 1 - Real.logb 2 3 := by
  rw [Real.logb_div (by norm_num) (by norm_num)]; simp

private lemma logb_third : Real.logb 2 (1/3) = -Real.logb 2 3 := by
  rw [Real.logb_div (by norm_num) (by norm_num)]; simp

private lemma logb_four_ninths : Real.logb 2 (4/9) = 2 - 2 * Real.logb 2 3 := by
  rw [Real.logb_div (by norm_num) (by norm_num), logb_four, logb_nine]

private lemma logb_ninth : Real.logb 2 (1/9) = -(2 * Real.logb 2 3) := by
  rw [Real.logb_div (by norm_num) (by norm_num), logb_nine]; simp

private lemma logb_four_thirds : Real.logb 2 (4/3) = 2 - Real.logb 2 3 := by
  rw [Real.logb_div (by norm_num) (by norm_num), logb_four]

/-- At the quadratic characters (`n = 2`) the split-count channel carries a full bit. -/
theorem Is_two : Is 2 = 1 := by
  rw [Is_eq_closedForm (le_refl 2)]
  simp only [entropyBits, binom2, cond, Fin.sum_univ_three, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
  norm_num [logb_half, logb_quarter]

/-- The cubic-order value: `Is 3 = log₂ 3 - 10/9 ≈ 0.4739`. -/
theorem Is_three : Is 3 = Real.logb 2 3 - 10 / 9 := by
  rw [Is_eq_closedForm (by norm_num)]
  simp only [entropyBits, binom2, cond, Fin.sum_univ_three, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
  norm_num [logb_four_ninths, logb_ninth, logb_two_thirds, logb_third]
  ring

/-! ## Boolean faces of the fork -/

/-- OR of the two split events, as a function of the split-count. -/
def orMap : Fin 3 → Fin 2 := ![0, 1, 1]

/-- AND of the two split events, as a function of the split-count. -/
def andMap : Fin 3 → Fin 2 := ![0, 0, 1]

/-- XOR of the two split events, as a function of the split-count. -/
def xorMap : Fin 3 → Fin 2 := ![0, 1, 0]

/-- Information carried by the OR face. -/
noncomputable def Ior (n : ℝ) : ℝ := mutualInfo (push (forkJoint n) orMap)

/-- Information carried by the AND face. -/
noncomputable def Iand (n : ℝ) : ℝ := mutualInfo (push (forkJoint n) andMap)

/-- Information carried by the XOR face. -/
noncomputable def Ixor (n : ℝ) : ℝ := mutualInfo (push (forkJoint n) xorMap)

lemma rowMarg_pos (hn : 2 ≤ n) : ∀ a, 0 < rowMarg (forkJoint n) a := by
  have hn0 : (0:ℝ) < n := by linarith
  have h1 : (0:ℝ) < 1 / n := by positivity
  have h2 : (0:ℝ) < (n - 1) / n := div_pos (by linarith) hn0
  intro a
  rw [rowMarg_forkJoint hn]
  fin_cases a
  · simpa [prior] using h1
  · simpa [prior] using h2

/-- **Data processing for the fork.** Every Boolean face of the fork is dominated
by the split-count channel. -/
theorem face_le_Is (hn : 2 ≤ n) (g : Fin 3 → Fin 2) :
    mutualInfo (push (forkJoint n) g) ≤ Is n :=
  mutualInfo_map_le _ _ (forkJoint_nonneg hn) (rowMarg_pos hn) (colMarg_pos hn)

theorem Ior_le_Is (hn : 2 ≤ n) : Ior n ≤ Is n := face_le_Is hn orMap

theorem Iand_le_Is (hn : 2 ≤ n) : Iand n ≤ Is n := face_le_Is hn andMap

theorem Ixor_le_Is (hn : 2 ≤ n) : Ixor n ≤ Is n := face_le_Is hn xorMap

/-! ## The `n = 2` (quadratic character) values: the OR cap is a projection artifact -/

lemma push_fin3 (p : Fin 2 → Fin 3 → ℝ) (g : Fin 3 → Fin 2) (a t : Fin 2) :
    push p g a t = ∑ s : Fin 3, if g s = t then p a s else 0 := by
  simp [push, Finset.sum_filter]

lemma forkJoint_two : forkJoint 2 = ![![1/4, 0, 1/4], ![0, 1/2, 0]] := by
  funext a s
  fin_cases a <;> fin_cases s <;> norm_num [forkJoint, prior, cond]

lemma push_or_two : push (forkJoint 2) orMap = ![![1/4, 1/4], ![0, 1/2]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_two, orMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

lemma push_xor_two : push (forkJoint 2) xorMap = ![![1/2, 0], ![0, 1/2]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_two, xorMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

/-- The celebrated OR value at the quadratic characters: `g(2) = 3/2 - (3/4) log₂ 3 ≈ 0.3113`. -/
theorem Ior_two : Ior 2 = 3 / 2 - 3 / 4 * Real.logb 2 3 := by
  rw [Ior, push_or_two]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_two_thirds, logb_four_thirds]
  ring

/-- At the quadratic characters the XOR face is already complete: one full bit. -/
theorem Ixor_two : Ixor 2 = 1 := by
  rw [Ixor, push_xor_two]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num

lemma push_and_two : push (forkJoint 2) andMap = ![![1/4, 1/4], ![1/2, 0]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_two, andMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

/-- At the quadratic characters the AND face carries the same `0.3113…` bits as OR. -/
theorem Iand_two : Iand 2 = 3 / 2 - 3 / 4 * Real.logb 2 3 := by
  rw [Iand, push_and_two]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_two_thirds, logb_four_thirds]
  ring

/-- The two "one-sided" faces coincide at `n = 2`: the AND/OR gap opens only for `n ≥ 3`. -/
theorem Iand_two_eq_Ior_two : Iand 2 = Ior 2 := by rw [Iand_two, Ior_two]

lemma one_lt_logb_two_three : 1 < Real.logb 2 3 := by
  rw [show (1:ℝ) = Real.logb 2 2 by simp]
  exact Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)

/-- **The OR cap is a projection artifact.** At `n = 2` the OR face carries
`0.3113…` bits while the full split-count channel carries a whole bit. -/
theorem Ior_two_lt_Is_two : Ior 2 < Is 2 := by
  rw [Ior_two, Is_two]
  have := one_lt_logb_two_three
  linarith

/-- The XOR face is complete at `n = 2`: it attains the full split-count value. -/
theorem Ixor_two_eq_Is_two : Ixor 2 = Is 2 := by rw [Ixor_two, Is_two]

/-! ## Global bounds -/

/-- The split-count channel is nonnegative. -/
theorem Is_nonneg (hn : 2 ≤ n) : 0 ≤ Is n := by
  refine mutualInfo_nonneg _ (forkJoint_nonneg hn) (rowMarg_pos hn) (colMarg_pos hn) ?_
  rw [Finset.sum_congr rfl (fun a _ => rowMarg_forkJoint hn a)]
  exact prior_sum hn

/-- **The fork is never vacuous.** For every order `n ≥ 2` the split-count
channel carries strictly positive information: the cell `(χ(N) = 1, s = 1)` is
impossible while both its marginals are positive. -/
theorem Is_pos (hn : 2 ≤ n) : 0 < Is n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  have htot : ∑ a, rowMarg (forkJoint n) a = 1 := by
    rw [Finset.sum_congr rfl (fun a _ => rowMarg_forkJoint hn a)]
    exact prior_sum hn
  refine mutualInfo_pos (forkJoint n) (forkJoint_nonneg hn) (rowMarg_pos hn) (colMarg_pos hn)
    htot (a₀ := 0) (b₀ := 1) ?_
  have hzero : forkJoint n 0 1 = 0 := by
    simp [forkJoint, prior, cond]
  have hrow0 : rowMarg (forkJoint n) 0 = 1 / n := by
    rw [rowMarg_forkJoint hn]; simp [prior]
  have hcol1 : colMarg (forkJoint n) 1 = 2 * (n - 1) / n ^ 2 := by
    rw [colMarg_forkJoint hn]; simp [binom2]
  rw [hzero, hrow0, hcol1]
  have : 0 < 1 / n * (2 * (n - 1) / n ^ 2) := by positivity
  linarith

/-- **One-bit cap.** Whatever the order `n`, a character-pinned fork carries at most
one bit about the residue class of `N`; the bound is attained at `n = 2`. -/
theorem Is_le_one (hn : 2 ≤ n) : Is n ≤ 1 := by
  refine mutualInfo_le_one_of_binary _ (forkJoint_nonneg hn) (rowMarg_pos hn) (colMarg_pos hn) ?_
  rw [rowMarg_forkJoint hn, rowMarg_forkJoint hn]
  have hn0 : (0:ℝ) < n := by linarith
  simp only [prior, Matrix.cons_val_zero, Matrix.cons_val_one]
  field_simp
  ring

/-! ## Sufficiency: the ordered fork pair carries exactly the split-count -/

/-- The ordered pair of split events, coded as `0 = (F,F)`, `1 = (T,F)`, `2 = (F,T)`,
`3 = (T,T)`. -/
noncomputable def condPair (n : ℝ) : Fin 2 → Fin 4 → ℝ :=
  ![![(n - 1) / n, 0, 0, 1 / n], ![(n - 2) / n, 1 / n, 1 / n, 0]]

/-- Joint law of (class of `N`, ordered pair of split events). -/
noncomputable def pairJoint (n : ℝ) : Fin 2 → Fin 4 → ℝ := fun a e => prior n a * condPair n a e

/-- Information carried by the *ordered* fork pair. -/
noncomputable def Ipair (n : ℝ) : ℝ := mutualInfo (pairJoint n)

/-- Reading the split-count off the ordered pair. -/
def countMap : Fin 4 → Fin 3 := ![0, 1, 1, 2]

lemma condPair_nonneg (hn : 2 ≤ n) : ∀ a e, 0 ≤ condPair n a e := by
  have hn0 : (0:ℝ) < n := by linarith
  have e1 : (0:ℝ) ≤ (n - 1) / n := div_nonneg (by linarith) hn0.le
  have e2 : (0:ℝ) ≤ 1 / n := by positivity
  have e3 : (0:ℝ) ≤ (n - 2) / n := div_nonneg (by linarith) hn0.le
  intro a e
  fin_cases a <;> fin_cases e
  · simpa [condPair] using e1
  · simp [condPair]
  · simp [condPair]
  · simpa [condPair] using e2
  · simpa [condPair] using e3
  · simpa [condPair] using e2
  · simpa [condPair] using e2
  · simp [condPair]

lemma condPair_sum (hn : 2 ≤ n) : ∀ a, ∑ e, condPair n a e = 1 := by
  have hn0 : (0:ℝ) < n := by linarith
  intro a
  fin_cases a <;> simp [condPair, Fin.sum_univ_four] <;> field_simp <;> ring

/-- The split-count really is the pushforward of the ordered pair. -/
theorem push_pairJoint (hn : 2 ≤ n) : push (pairJoint n) countMap = forkJoint n := by
  have hn0 : (0:ℝ) < n := by linarith
  funext a s
  fin_cases a <;> fin_cases s <;>
    simp [push, Finset.sum_filter, Fin.sum_univ_four, pairJoint, condPair, forkJoint,
      prior, cond, countMap]; ring

/-- Column law of the ordered-pair channel. -/
noncomputable def pairMarg (n : ℝ) : Fin 4 → ℝ :=
  ![(n - 1) ^ 2 / n ^ 2, (n - 1) / n ^ 2, (n - 1) / n ^ 2, 1 / n ^ 2]

lemma colMarg_pairJoint (hn : 2 ≤ n) : colMarg (pairJoint n) = pairMarg n := by
  have hn0 : (0:ℝ) < n := by linarith
  funext e
  fin_cases e <;>
    simp [colMarg, pairJoint, prior, condPair, pairMarg, Fin.sum_univ_two] <;> field_simp; ring

lemma pairMarg_pos (hn : 2 ≤ n) : ∀ e, 0 < pairMarg n e := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  have b0 : (0:ℝ) < (n - 1) ^ 2 / n ^ 2 := div_pos (pow_pos hn1 2) (by positivity)
  have b1 : (0:ℝ) < (n - 1) / n ^ 2 := div_pos hn1 (by positivity)
  have b2 : (0:ℝ) < 1 / n ^ 2 := by positivity
  intro e
  fin_cases e
  · simpa [pairMarg] using b0
  · simpa [pairMarg] using b1
  · simpa [pairMarg] using b1
  · simpa [pairMarg] using b2

lemma Ipair_closedForm (hn : 2 ≤ n) :
    Ipair n = entropyBits (pairMarg n)
      - (1 / n) * entropyBits (condPair n 0) - ((n - 1) / n) * entropyBits (condPair n 1) := by
  have hcol : ∀ e, 0 < colMarg (fun a e => prior n a * condPair n a e) e := by
    intro e
    have : colMarg (fun a e => prior n a * condPair n a e) = pairMarg n := colMarg_pairJoint hn
    rw [this]; exact pairMarg_pos hn e
  have h := mutualInfo_of_channel (prior n) (condPair n) (prior_nonneg hn) (condPair_nonneg hn)
    (condPair_sum hn) hcol
  have hIp : Ipair n = mutualInfo (fun a e => prior n a * condPair n a e) := rfl
  have hc : colMarg (fun a b => prior n a * condPair n a b) = pairMarg n := colMarg_pairJoint hn
  rw [hIp, h, hc, Fin.sum_univ_two]
  simp only [prior, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- Doubling law for the `-x log x` cell. -/
lemma negMulLogb_two_mul {y : ℝ} (hy : 0 < y) :
    -(2 * y * Real.logb 2 (2 * y)) = 2 * -(y * Real.logb 2 y) - 2 * y := by
  rw [Real.logb_mul (by norm_num) (ne_of_gt hy), logb_two_val]
  ring

/-- **Sufficiency of the split-count.** The *ordered* pair of split events carries
exactly the same information as the split-count: the symmetric fork channel is the
split-count and nothing more. -/
theorem Ipair_eq_Is (hn : 2 ≤ n) : Ipair n = Is n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hn1 : (0:ℝ) < n - 1 := by linarith
  rw [Ipair_closedForm hn, Is_eq_closedForm hn]
  simp only [entropyBits, binom2, pairMarg, cond, condPair, Fin.sum_univ_three, Fin.sum_univ_four,
    Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two,
    Matrix.cons_val_three, Matrix.tail_cons]
  rw [show ((n - 1) / n) ^ 2 = (n - 1) ^ 2 / n ^ 2 by ring,
    show 2 * (n - 1) / n ^ 2 = 2 * ((n - 1) / n ^ 2) by ring,
    show (2:ℝ) / n = 2 * (1 / n) by ring,
    negMulLogb_two_mul (div_pos hn1 (by positivity)),
    negMulLogb_two_mul (by positivity : (0:ℝ) < 1 / n)]
  field_simp
  ring

/-! ## The which-factor wall: a single factor's split event is independent of `N` -/

/-- "The first factor splits", as a function of the ordered pair. -/
def firstMap : Fin 4 → Fin 2 := ![0, 1, 0, 1]

/-- Marginal law of a single factor's split event: Bernoulli `1/n`. -/
noncomputable def firstMarg (n : ℝ) : Fin 2 → ℝ := ![(n - 1) / n, 1 / n]

lemma firstMarg_nonneg (hn : 2 ≤ n) : ∀ t, 0 ≤ firstMarg n t := by
  have hn0 : (0:ℝ) < n := by linarith
  have h1 : (0:ℝ) ≤ (n - 1) / n := div_nonneg (by linarith) hn0.le
  have h2 : (0:ℝ) ≤ 1 / n := by positivity
  intro t
  fin_cases t
  · simpa [firstMarg] using h1
  · simpa [firstMarg] using h2

lemma firstMarg_sum (hn : 2 ≤ n) : ∑ t, firstMarg n t = 1 := by
  have hn0 : (0:ℝ) < n := by linarith
  simp [firstMarg, Fin.sum_univ_two]
  field_simp
  ring

lemma push_pairJoint_first (hn : 2 ≤ n) :
    push (pairJoint n) firstMap = fun a t => prior n a * firstMarg n t := by
  have hn0 : (0:ℝ) < n := by linarith
  funext a t
  fin_cases a <;> fin_cases t <;>
    simp [push, Finset.sum_filter, Fin.sum_univ_four, pairJoint, condPair, prior, firstMap,
      firstMarg]; field_simp; ring

/-- **The which-factor wall (barrier 2).** The split event of a *single* factor is
exactly independent of the residue class of `N`: it carries zero bits. All the
information of the fork is irreducibly joint. -/
theorem Ifirst_eq_zero (hn : 2 ≤ n) : mutualInfo (push (pairJoint n) firstMap) = 0 := by
  rw [push_pairJoint_first hn]
  exact mutualInfo_eq_zero_of_indep _ _ (prior_nonneg hn) (firstMarg_nonneg hn)
    (prior_sum hn) (firstMarg_sum hn)

/-! ## Exact values at `n = 3` and the strict hierarchy `OR < AND < XOR < split-count` -/

lemma forkJoint_three : forkJoint 3 = ![![2/9, 0, 1/9], ![2/9, 4/9, 0]] := by
  funext a s
  fin_cases a <;> fin_cases s <;> norm_num [forkJoint, prior, cond]

lemma push_or_three : push (forkJoint 3) orMap = ![![2/9, 1/9], ![2/9, 4/9]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_three, orMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

lemma push_and_three : push (forkJoint 3) andMap = ![![2/9, 1/9], ![2/3, 0]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_three, andMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

lemma push_xor_three : push (forkJoint 3) xorMap = ![![1/3, 0], ![2/9, 4/9]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_three, xorMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

private lemma logb_three_halves : Real.logb 2 (3/2) = Real.logb 2 3 - 1 := by
  rw [Real.logb_div (by norm_num) (by norm_num)]; simp

private lemma logb_three_fifths : Real.logb 2 (3/5) = Real.logb 2 3 - Real.logb 2 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num)]

private lemma logb_three_quarters : Real.logb 2 (3/4) = Real.logb 2 3 - 2 := by
  rw [Real.logb_div (by norm_num) (by norm_num), logb_four]

private lemma logb_six_fifths :
    Real.logb 2 (6/5) = 1 + Real.logb 2 3 - Real.logb 2 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num),
    show (6:ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb_two_val]

private lemma logb_nine_fifths :
    Real.logb 2 (9/5) = 2 * Real.logb 2 3 - Real.logb 2 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num), logb_nine]

private lemma logb_nine_eighths :
    Real.logb 2 (9/8) = 2 * Real.logb 2 3 - 3 := by
  rw [Real.logb_div (by norm_num) (by norm_num), logb_nine,
    show (8:ℝ) = 2 ^ (3:ℕ) by norm_num, Real.logb_pow, logb_two_val]
  norm_num

/-- OR at `n = 3`: `log₂ 3 - (5/9) log₂ 5 - 2/9 ≈ 0.0728`. -/
theorem Ior_three : Ior 3 = Real.logb 2 3 - 5/9 * Real.logb 2 5 - 2/9 := by
  rw [Ior, push_or_three]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_three_halves, logb_three_fifths, logb_three_quarters, logb_six_fifths]
  ring

/-- AND at `n = 3`: `(5/3) log₂ 3 - 22/9 ≈ 0.1972`. -/
theorem Iand_three : Iand 3 = 5/3 * Real.logb 2 3 - 22/9 := by
  rw [Iand, push_and_three]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_three_quarters, logb_nine_eighths]
  ring

/-- XOR at `n = 3`: `(4/3) log₂ 3 - (5/9) log₂ 5 - 4/9 ≈ 0.3789`. -/
theorem Ixor_three : Ixor 3 = 4/3 * Real.logb 2 3 - 5/9 * Real.logb 2 5 - 4/9 := by
  rw [Ixor, push_xor_three]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_nine_fifths, logb_three_fifths, logb_three_halves]
  ring

/-! ### Rational bounds for `log₂ 3` and `log₂ 5` -/

private lemma logb_lower {x : ℝ} {a b : ℕ} (h : (2:ℝ) ^ a < x ^ b) :
    (a : ℝ) < b * Real.logb 2 x := by
  have := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h
  rwa [Real.logb_pow, Real.logb_pow, logb_two_val, mul_one] at this

private lemma logb_upper {x : ℝ} (hx : 0 < x) {a b : ℕ} (h : x ^ b < (2:ℝ) ^ a) :
    (b : ℝ) * Real.logb 2 x < a := by
  have := Real.logb_lt_logb (b := 2) (by norm_num) (pow_pos hx b) h
  rwa [Real.logb_pow, Real.logb_pow, logb_two_val, mul_one] at this

lemma logb_three_gt : 19/12 < Real.logb 2 3 := by
  have h := logb_lower (x := (3:ℝ)) (a := 19) (b := 12) (by norm_num)
  push_cast at h
  linarith

lemma logb_three_lt : Real.logb 2 3 < 8/5 := by
  have h := logb_upper (x := (3:ℝ)) (by norm_num) (a := 8) (b := 5) (by norm_num)
  push_cast at h
  linarith

lemma logb_five_gt : 9/4 < Real.logb 2 5 := by
  have h := logb_lower (x := (5:ℝ)) (a := 9) (b := 4) (by norm_num)
  push_cast at h
  linarith

lemma logb_five_lt : Real.logb 2 5 < 7/3 := by
  have h := logb_upper (x := (5:ℝ)) (by norm_num) (a := 7) (b := 3) (by norm_num)
  push_cast at h
  linarith

/-- **Strict hierarchy at `n = 3`**: `OR < AND < XOR < split-count`. -/
theorem hierarchy_three : Ior 3 < Iand 3 ∧ Iand 3 < Ixor 3 ∧ Ixor 3 < Is 3 := by
  have l3l := logb_three_gt
  have l3u := logb_three_lt
  have l5l := logb_five_gt
  have l5u := logb_five_lt
  rw [Ior_three, Iand_three, Ixor_three, Is_three]
  refine ⟨by linarith, by linarith, by linarith⟩

/-! ## The honest hierarchy correction at `n = 8`: XOR and AND swap places -/

private lemma logb_pow_two (k : ℕ) : Real.logb 2 (2 ^ k) = k := by
  rw [Real.logb_pow, logb_two_val, mul_one]

private lemma logb_49_64 : Real.logb 2 (49/64) = 2 * Real.logb 2 7 - 6 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (49:ℝ) = 7 ^ (2:ℕ) by norm_num,
    show (64:ℝ) = 2 ^ (6:ℕ) by norm_num, Real.logb_pow, logb_pow_two]
  norm_num

private lemma logb_7_32 : Real.logb 2 (7/32) = Real.logb 2 7 - 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (32:ℝ) = 2 ^ (5:ℕ) by norm_num,
    logb_pow_two]
  norm_num

private lemma logb_1_64 : Real.logb 2 (1/64) = -6 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (64:ℝ) = 2 ^ (6:ℕ) by norm_num,
    logb_pow_two]
  norm_num

private lemma logb_7_8 : Real.logb 2 (7/8) = Real.logb 2 7 - 3 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (8:ℝ) = 2 ^ (3:ℕ) by norm_num,
    logb_pow_two]
  norm_num

private lemma logb_1_8 : Real.logb 2 (1/8) = -3 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (8:ℝ) = 2 ^ (3:ℕ) by norm_num,
    logb_pow_two]
  norm_num

private lemma logb_8_7 : Real.logb 2 (8/7) = 3 - Real.logb 2 7 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (8:ℝ) = 2 ^ (3:ℕ) by norm_num,
    logb_pow_two]
  norm_num

private lemma logb_8_15 : Real.logb 2 (8/15) = 3 - Real.logb 2 3 - Real.logb 2 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (8:ℝ) = 2 ^ (3:ℕ) by norm_num,
    logb_pow_two, show (15:ℝ) = 3 * 5 by norm_num,
    Real.logb_mul (by norm_num) (by norm_num)]
  push_cast
  ring

private lemma logb_48_49 : Real.logb 2 (48/49) = 4 + Real.logb 2 3 - 2 * Real.logb 2 7 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (48:ℝ) = 2 ^ (4:ℕ) * 3 by norm_num,
    Real.logb_mul (by positivity) (by norm_num), logb_pow_two,
    show (49:ℝ) = 7 ^ (2:ℕ) by norm_num, Real.logb_pow]
  push_cast
  ring

private lemma logb_16_15 : Real.logb 2 (16/15) = 4 - Real.logb 2 3 - Real.logb 2 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (16:ℝ) = 2 ^ (4:ℕ) by norm_num,
    logb_pow_two, show (15:ℝ) = 3 * 5 by norm_num,
    Real.logb_mul (by norm_num) (by norm_num)]
  push_cast
  ring

private lemma logb_8_9 : Real.logb 2 (8/9) = 3 - 2 * Real.logb 2 3 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (8:ℝ) = 2 ^ (3:ℕ) by norm_num,
    logb_pow_two, logb_nine]
  norm_num

private lemma logb_64_63 :
    Real.logb 2 (64/63) = 6 - 2 * Real.logb 2 3 - Real.logb 2 7 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (64:ℝ) = 2 ^ (6:ℕ) by norm_num,
    logb_pow_two, show (63:ℝ) = 9 * 7 by norm_num,
    Real.logb_mul (by norm_num) (by norm_num), logb_nine]
  push_cast
  ring

private lemma logb_32_25 : Real.logb 2 (32/25) = 5 - 2 * Real.logb 2 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (32:ℝ) = 2 ^ (5:ℕ) by norm_num,
    logb_pow_two, show (25:ℝ) = 5 ^ (2:ℕ) by norm_num, Real.logb_pow]
  push_cast
  ring

private lemma logb_24_25 :
    Real.logb 2 (24/25) = 3 + Real.logb 2 3 - 2 * Real.logb 2 5 := by
  rw [Real.logb_div (by norm_num) (by norm_num), show (24:ℝ) = 2 ^ (3:ℕ) * 3 by norm_num,
    Real.logb_mul (by positivity) (by norm_num), logb_pow_two,
    show (25:ℝ) = 5 ^ (2:ℕ) by norm_num, Real.logb_pow]
  push_cast
  ring

private lemma logb_eight : Real.logb 2 8 = 3 := by
  rw [show (8:ℝ) = 2 ^ (3:ℕ) by norm_num, logb_pow_two]
  norm_num

lemma forkJoint_eight : forkJoint 8 = ![![7/64, 0, 1/64], ![21/32, 7/32, 0]] := by
  funext a s
  fin_cases a <;> fin_cases s <;> norm_num [forkJoint, prior, cond]

lemma push_or_eight : push (forkJoint 8) orMap = ![![7/64, 1/64], ![21/32, 7/32]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_eight, orMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

lemma push_and_eight : push (forkJoint 8) andMap = ![![7/64, 1/64], ![7/8, 0]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_eight, andMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

lemma push_xor_eight : push (forkJoint 8) xorMap = ![![1/8, 0], ![21/32, 7/32]] := by
  funext a t
  fin_cases a <;> fin_cases t <;>
    norm_num [push_fin3, forkJoint_eight, xorMap, Fin.sum_univ_three, Matrix.cons_val_two,
      Matrix.tail_cons, Matrix.head_cons]

/-- Split-count value at `n = 8`. -/
theorem Is_eight : Is 8 = 117/32 + 21/32 * Real.logb 2 3 - 105/64 * Real.logb 2 7 := by
  rw [Is_eq_closedForm (by norm_num)]
  simp only [entropyBits, binom2, cond, Fin.sum_univ_three, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
  norm_num [logb_49_64, logb_7_32, logb_1_64, logb_7_8, logb_1_8, logb_three_quarters,
    logb_quarter]
  ring

/-- OR value at `n = 8`. -/
theorem Ior_eight :
    Ior 8 = 31/8 + 27/64 * Real.logb 2 3 - 15/64 * Real.logb 2 5 - 91/64 * Real.logb 2 7 := by
  rw [Ior, push_or_eight]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_8_7, logb_8_15, logb_48_49, logb_16_15]
  ring

/-- AND value at `n = 8`. -/
theorem Iand_eight : Iand 8 = 45/8 - 63/32 * Real.logb 2 3 - 7/8 * Real.logb 2 7 := by
  rw [Iand, push_and_eight]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_8_9, logb_eight, logb_64_63]
  ring

/-- XOR value at `n = 8`. -/
theorem Ixor_eight :
    Ixor 8 = 13/4 + 21/32 * Real.logb 2 3 - 25/16 * Real.logb 2 5 - 7/32 * Real.logb 2 7 := by
  rw [Ixor, push_xor_eight]
  simp only [mutualInfo, rowMarg, colMarg, Fin.sum_univ_two, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  norm_num [logb_32_25, logb_24_25, logb_8_7]
  ring

/-- Exact integer certificate `3^84 · 7^21 < 2^76 · 5^50` behind `XOR(8) < AND(8)`. -/
lemma logb_certificate_and_xor :
    84 * Real.logb 2 3 + 21 * Real.logb 2 7 < 76 + 50 * Real.logb 2 5 := by
  have h : (3:ℝ) ^ (84:ℕ) * 7 ^ (21:ℕ) < 2 ^ (76:ℕ) * 5 ^ (50:ℕ) := by norm_num
  have h2 := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h
  rw [Real.logb_mul (by positivity) (by positivity), Real.logb_mul (by positivity) (by positivity),
    Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow, logb_two_val] at h2
  push_cast at h2
  linarith

/-- Exact integer certificate `2^40 · 5^85 < 3^15 · 7^77` behind `OR(8) < XOR(8)`. -/
lemma logb_certificate_or_xor :
    40 + 85 * Real.logb 2 5 < 15 * Real.logb 2 3 + 77 * Real.logb 2 7 := by
  have h : (2:ℝ) ^ (40:ℕ) * 5 ^ (85:ℕ) < 3 ^ (15:ℕ) * 7 ^ (77:ℕ) := by norm_num
  have h2 := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h
  rw [Real.logb_mul (by positivity) (by positivity), Real.logb_mul (by positivity) (by positivity),
    Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow, logb_two_val] at h2
  push_cast at h2
  linarith

/-- Exact integer certificate `2^126 · 7^49 < 3^168` behind `AND(8) < split-count(8)`. -/
lemma logb_certificate_and_Is :
    126 + 49 * Real.logb 2 7 < 168 * Real.logb 2 3 := by
  have h : (2:ℝ) ^ (126:ℕ) * 7 ^ (49:ℕ) < 3 ^ (168:ℕ) := by norm_num
  have h2 := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h
  rw [Real.logb_mul (by positivity) (by positivity), Real.logb_pow, Real.logb_pow,
    Real.logb_pow, logb_two_val] at h2
  push_cast at h2
  linarith

/-- **The honest hierarchy correction.** At `n = 8` the naive chain
`Is ≥ XOR ≥ AND ≥ OR` fails: the true order is `OR < XOR < AND < split-count`,
i.e. AND overtakes XOR (contrast `hierarchy_three`). -/
theorem hierarchy_eight : Ior 8 < Ixor 8 ∧ Ixor 8 < Iand 8 ∧ Iand 8 < Is 8 := by
  have c1 := logb_certificate_or_xor
  have c2 := logb_certificate_and_xor
  have c3 := logb_certificate_and_Is
  rw [Ior_eight, Ixor_eight, Iand_eight, Is_eight]
  refine ⟨by linarith, by linarith, by linarith⟩

/-! ## Asymptotic factor-uselessness: the fork channel dies as the order grows -/

/-- The fork channel is bounded by the entropy of the class prior. -/
theorem Is_le_priorEntropy (hn : 2 ≤ n) : Is n ≤ entropyBits (prior n) := by
  have h := mutualInfo_le_rowEntropy (forkJoint n) (forkJoint_nonneg hn) (rowMarg_pos hn)
    (colMarg_pos hn)
  have hr : rowMarg (forkJoint n) = prior n := funext (rowMarg_forkJoint hn)
  rwa [hr] at h

lemma priorEntropy_eq (hn : 2 ≤ n) :
    entropyBits (prior n) = Real.binEntropy (1 / n) / Real.log 2 := by
  have h := entropyBits_binary_eq (prior n) (by
    simpa [prior, Fin.sum_univ_two] using prior_sum hn)
  simpa [prior] using h

/-- **The split-count channel vanishes as the character order grows.**
`Is n → 0` as `n → ∞`: a high-order fork is asymptotically information-free. -/
theorem Is_tendsto_zero : Filter.Tendsto Is Filter.atTop (nhds 0) := by
  have hbin : Filter.Tendsto (fun n : ℝ => Real.binEntropy (1 / n) / Real.log 2)
      Filter.atTop (nhds 0) := by
    have h0 : Filter.Tendsto (fun n : ℝ => 1 / n) Filter.atTop (nhds 0) := by
      simpa [one_div] using tendsto_inv_atTop_zero (𝕜 := ℝ)
    have h1 : Filter.Tendsto (fun n : ℝ => Real.binEntropy (1 / n)) Filter.atTop
        (nhds (Real.binEntropy 0)) := (Real.binEntropy_continuous.tendsto 0).comp h0
    rw [Real.binEntropy_zero] at h1
    simpa using h1.div_const (Real.log 2)
  refine squeeze_zero' (Filter.eventually_atTop.2 ⟨2, fun m hm => Is_nonneg hm⟩)
    (Filter.eventually_atTop.2 ⟨2, fun m hm => ?_⟩) hbin
  rw [← priorEntropy_eq hm]
  exact Is_le_priorEntropy hm

/-- **The one-bit cap is attained only at the quadratic characters.** For every
order `n > 2` the split-count channel is strictly below one bit. -/
theorem Is_lt_one (hn : 2 < n) : Is n < 1 := by
  have hn2 : (2:ℝ) ≤ n := le_of_lt hn
  have hn0 : (0:ℝ) < n := by linarith
  have hne : 1 / n ≠ 2⁻¹ := by
    intro h
    rw [eq_comm, inv_eq_iff_eq_inv, ← one_div] at h
    have : n = 2 := by
      field_simp at h
      linarith
    linarith
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hb : Real.binEntropy (1 / n) < Real.log 2 := Real.binEntropy_lt_log_two.2 hne
  calc Is n ≤ entropyBits (prior n) := Is_le_priorEntropy hn2
    _ = Real.binEntropy (1 / n) / Real.log 2 := priorEntropy_eq hn2
    _ < 1 := by rw [div_lt_one hl2]; exact hb

end SplitCountChannel