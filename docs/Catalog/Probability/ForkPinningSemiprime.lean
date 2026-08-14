/-
# The semiprime level: a 100%-pinned prime-level fork collapses to a 0.07-bit dial

For the cyclic cubic field of conductor 7 the prime-level fork is *deterministic* given
`p mod 7`.  Take a semiprime `N = p q` with `p`, `q` independent.  What the residue of `N`
records is the **product** of the two cubic-residue characters, and the accessible fork is the
disjunction `OR = [p splits] ∨ [q splits]`.

The model is therefore the uniform measure on `C₃ × C₃` (the pair of Frobenius elements),
with

* observable `cubicClassOfN (a, b) = a + b`  (the cubic-residue class of `N` mod 7),
* fork `splitOR (a, b) = [a = 0 ∨ b = 0]`,
* factor label `firstFactorSplits (a, b) = [a = 0]`.

Results:

* `ForkPinning.semiprime_OR_mutualInfo` :
  `I(N mod 7 ; OR) = log 3 − (5/9) log 5 − (2/9) log 2` = 0.0728 bits
  (the measured value was 0.0718, the predicted 0.0728);
* `ForkPinning.semiprime_collapse` : the semiprime-level information is less than a twelfth of
  the prime-level information `log 3 − (2/3) log 2` = 0.9183 bits;
* `ForkPinning.which_factor_wall` : `I(N mod 7 ; which factor splits) = 0` — **exactly zero**,
  the "which-factor wall" (measured `0.0001`).
-/

import Probability.ForkPinningGalois

namespace ForkPinning

open Finset Real

/-! ## Sums over `C₃` -/

lemma sum_zmod3 (f : ZMod 3 → ℝ) : ∑ k : ZMod 3, f k = f 0 + f 1 + f 2 := by
  rw [show (univ : Finset (ZMod 3)) = {0, 1, 2} from by decide,
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  ring

variable {Ω : Type*} [Fintype Ω]

lemma H_zmod3 (X : Ω → ZMod 3) :
    H X = negMulLog (prb X 0) + negMulLog (prb X 1) + negMulLog (prb X 2) := by
  unfold H
  rw [sum_zmod3]

lemma H_joint_zmod3_bool (X : Ω → ZMod 3) (Y : Ω → Bool) :
    H (joint X Y) =
      (negMulLog (prb (joint X Y) (0, false)) + negMulLog (prb (joint X Y) (0, true)))
      + (negMulLog (prb (joint X Y) (1, false)) + negMulLog (prb (joint X Y) (1, true)))
      + (negMulLog (prb (joint X Y) (2, false)) + negMulLog (prb (joint X Y) (2, true))) := by
  rw [entropy_joint_eq, sum_zmod3, Fintype.sum_bool, Fintype.sum_bool, Fintype.sum_bool]
  ring

/-! ## The semiprime model -/

/-- The cubic-residue class of `N = p q`: the product of the two prime classes. -/
def cubicClassOfN (x : ZMod 3 × ZMod 3) : ZMod 3 := x.1 + x.2

/-- `OR = [p splits] ∨ [q splits]`. -/
def splitOR (x : ZMod 3 × ZMod 3) : Bool := decide (x.1 = 0 ∨ x.2 = 0)

/-- Which factor splits: the label the factoring problem actually needs. -/
def firstFactorSplits (x : ZMod 3 × ZMod 3) : Bool := decide (x.1 = 0)

lemma card_C3sq : Fintype.card (ZMod 3 × ZMod 3) = 9 := by decide

lemma prb_cubicClassOfN (k : ZMod 3) : prb cubicClassOfN k = 1 / 3 := by
  have h : ∀ k : ZMod 3, (fiber cubicClassOfN k).card = 3 := by decide
  rw [prb, card_C3sq, h k]
  norm_num

lemma prb_splitOR_true : prb splitOR true = 5 / 9 := by
  rw [prb, card_C3sq, show (fiber splitOR true).card = 5 from by decide]
  norm_num

lemma prb_splitOR_false : prb splitOR false = 4 / 9 := by
  rw [prb, card_C3sq, show (fiber splitOR false).card = 4 from by decide]
  norm_num

lemma prb_joint_OR_0t : prb (joint cubicClassOfN splitOR) (0, true) = 1 / 9 := by
  rw [prb, card_C3sq, show (fiber (joint cubicClassOfN splitOR) (0, true)).card = 1 from by decide]
  norm_num

lemma prb_joint_OR_0f : prb (joint cubicClassOfN splitOR) (0, false) = 2 / 9 := by
  rw [prb, card_C3sq, show (fiber (joint cubicClassOfN splitOR) (0, false)).card = 2 from by decide]
  norm_num

lemma prb_joint_OR_1t : prb (joint cubicClassOfN splitOR) (1, true) = 2 / 9 := by
  rw [prb, card_C3sq, show (fiber (joint cubicClassOfN splitOR) (1, true)).card = 2 from by decide]
  norm_num

lemma prb_joint_OR_1f : prb (joint cubicClassOfN splitOR) (1, false) = 1 / 9 := by
  rw [prb, card_C3sq, show (fiber (joint cubicClassOfN splitOR) (1, false)).card = 1 from by decide]
  norm_num

lemma prb_joint_OR_2t : prb (joint cubicClassOfN splitOR) (2, true) = 2 / 9 := by
  rw [prb, card_C3sq, show (fiber (joint cubicClassOfN splitOR) (2, true)).card = 2 from by decide]
  norm_num

lemma prb_joint_OR_2f : prb (joint cubicClassOfN splitOR) (2, false) = 1 / 9 := by
  rw [prb, card_C3sq, show (fiber (joint cubicClassOfN splitOR) (2, false)).card = 1 from by decide]
  norm_num

/-- The residue class of `N` is uniform on `C₃`: `H = log 3`. -/
theorem entropy_cubicClassOfN : H cubicClassOfN = Real.log 3 := by
  rw [H_zmod3, prb_cubicClassOfN, prb_cubicClassOfN, prb_cubicClassOfN,
    negMulLog_ratio 1 3 (by norm_num) (by norm_num), Real.log_one]
  ring

/-- **The semiprime-level dial.**  `I(N mod 7 ; OR) = log 3 − (5/9) log 5 − (2/9) log 2`,
i.e. `0.0728` bits (measured: `0.0718`). -/
theorem semiprime_OR_mutualInfo :
    mutualInfo cubicClassOfN splitOR
      = Real.log 3 - (5 / 9) * Real.log 5 - (2 / 9) * Real.log 2 := by
  rw [mutualInfo, H_zmod3, H_bool, H_joint_zmod3_bool,
    prb_cubicClassOfN, prb_cubicClassOfN, prb_cubicClassOfN,
    prb_splitOR_true, prb_splitOR_false,
    prb_joint_OR_0t, prb_joint_OR_0f, prb_joint_OR_1t, prb_joint_OR_1f,
    prb_joint_OR_2t, prb_joint_OR_2f,
    negMulLog_ratio 1 3 (by norm_num) (by norm_num),
    negMulLog_ratio 5 9 (by norm_num) (by norm_num),
    negMulLog_ratio 4 9 (by norm_num) (by norm_num),
    negMulLog_ratio 1 9 (by norm_num) (by norm_num),
    negMulLog_ratio 2 9 (by norm_num) (by norm_num), Real.log_one, log_four, log_nine]
  ring

/-- **The collapse.**  Even a 100%-pinned prime-level fork degenerates at the semiprime level:
twelve times the semiprime information is still less than the prime-level information. -/
theorem semiprime_collapse :
    12 * mutualInfo cubicClassOfN splitOR < mutualInfo (id : ZMod 3 → ZMod 3) forkC3 := by
  rw [semiprime_OR_mutualInfo, cyclicCubic_fork_mutualInfo]
  -- reduces to `3^33 < 2^6 · 5^20`
  have h1 : Real.log (5559060566555523) < Real.log (6103515625000000) :=
    Real.log_lt_log (by norm_num) (by norm_num)
  have h2 : Real.log (5559060566555523) = 33 * Real.log 3 := by
    rw [show (5559060566555523 : ℝ) = 3 ^ 33 by norm_num, Real.log_pow]
    push_cast; ring
  have h3 : Real.log (6103515625000000) = 6 * Real.log 2 + 20 * Real.log 5 := by
    rw [show (6103515625000000 : ℝ) = 2 ^ 6 * 5 ^ 20 by norm_num,
      Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow]
    push_cast; ring
  rw [h2, h3] at h1
  linarith

/-! ## The which-factor wall -/

lemma prb_firstFactorSplits_true : prb firstFactorSplits true = 1 / 3 := by
  rw [prb, card_C3sq, show (fiber firstFactorSplits true).card = 3 from by decide]
  norm_num

lemma prb_firstFactorSplits_false : prb firstFactorSplits false = 2 / 3 := by
  rw [prb, card_C3sq, show (fiber firstFactorSplits false).card = 6 from by decide]
  norm_num

/-- **The which-factor wall is exact.**  The residue of `N` is *independent* of which of the two
prime factors is the split one, so it carries exactly zero bits about the factorization
(the experiment measured `0.0001`). -/
theorem which_factor_wall : mutualInfo cubicClassOfN firstFactorSplits = 0 := by
  refine mutualInfo_eq_zero_of_indep _ _ (fun k b => ?_)
  have htrue : ∀ k : ZMod 3, (fiber (joint cubicClassOfN firstFactorSplits) (k, true)).card = 1 := by
    decide
  have hfalse : ∀ k : ZMod 3,
      (fiber (joint cubicClassOfN firstFactorSplits) (k, false)).card = 2 := by decide
  cases b with
  | false =>
      rw [prb, card_C3sq, hfalse k, prb_cubicClassOfN, prb_firstFactorSplits_false]
      norm_num
  | true =>
      rw [prb, card_C3sq, htrue k, prb_cubicClassOfN, prb_firstFactorSplits_true]
      norm_num

end ForkPinning