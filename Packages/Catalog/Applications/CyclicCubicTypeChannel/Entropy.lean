/-
# The cyclic-cubic type channel: full pinning, and its failure for semiprimes

## Context (FACT round-32 #3, "THE-CYCLIC-CUBIC-IS-FULLY-PINNED", paper 122)

`Applications.CyclicCubicTypeChannel.Splitting` proves the arithmetic law: an
unramified prime `p` has residue degree `1` in `K = ℚ(ζ₇ + ζ₇⁻¹)` iff
`p ≡ ±1 (mod 7)`, and residue degree `3` otherwise — **two types only**.

This file turns that law into an information channel and computes its capacity
exactly, in bits, using the Shannon-entropy functional of
`Applications.LabelEntropyDeficit`.  Modelling `p mod 7` as uniform on the six
invertible residues (Chebotarev/Dirichlet equidistribution), we prove:

* `CyclicCubic.H_typeMarginal` — the type entropy is exactly
  `H(T) = log₂ 3 − 2/3 = 0.918296…` bits (experiment: `0.9179`);
* `CyclicCubic.mutualInfo_residue_type` — `I(p mod 7 ; T) = log₂ 3 − 2/3`, i.e.
  `I = H(T)` **exactly**: the type is fully pinned by the residue
  (`CyclicCubic.full_pinning`), and the channel leaks nothing more
  (`CyclicCubic.pinning_saturates`, `I ≤ H(T)` with equality);
* `CyclicCubic.mutualInfo_semiprime` — for a *semiprime* `N = p·q` the residue
  `N mod 7` retains only `log₂ 3 − 10/9 = 0.473852…` bits about the unordered
  type pair (experiment: `0.4747`): pinning is destroyed by multiplication;
* `CyclicCubic.which_factor_information_zero` — the *ordered* type pair carries
  exactly the same information as the unordered one, so the residue reveals
  **0.0000** bits about *which* factor has which type; the underlying exact
  symmetry is `CyclicCubic.countOrd_swap`.

All entropies are computed in closed form; numerical bounds
(`CyclicCubic.H_typeMarginal_bounds`, `CyclicCubic.mutualInfo_semiprime_bounds`)
are derived from kernel-checked integer inequalities `2^1584 < 3^1000 < 2^1585`.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.CyclicCubicTypeChannel.Splitting

open Finset LabelEntropy

namespace CyclicCubic

/-! ## Entropy of a finitely-valued distribution given in case form -/

section EntropyTools

variable {ι : Type*} [Fintype ι]

/-- Entropy of a distribution with two constant values on a decidable partition. -/
lemma H_ite_two (P : ι → Prop) [DecidablePred P] (a b : ℝ) :
    H Finset.univ (fun i => if P i then a else b)
      = (Finset.univ.filter P).card * nlp a
        + (Finset.univ.filter (fun i => ¬ P i)).card * nlp b := by
  unfold H
  simp only [apply_ite nlp]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const, nsmul_eq_mul, nsmul_eq_mul]

/-- Entropy of a distribution with three constant values. -/
lemma H_ite_three (P Q : ι → Prop) [DecidablePred P] [DecidablePred Q] (a b c : ℝ) :
    H Finset.univ (fun i => if P i then a else if Q i then b else c)
      = (Finset.univ.filter P).card * nlp a
        + (Finset.univ.filter (fun i => ¬ P i ∧ Q i)).card * nlp b
        + (Finset.univ.filter (fun i => ¬ P i ∧ ¬ Q i)).card * nlp c := by
  unfold H
  simp only [apply_ite nlp]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_ite, Finset.sum_const, Finset.sum_const,
    nsmul_eq_mul, nsmul_eq_mul, nsmul_eq_mul, Finset.filter_filter, Finset.filter_filter,
    add_assoc]

/-- Entropy of a distribution supported on a decidable set, constant there. -/
lemma H_ite_zero (P : ι → Prop) [DecidablePred P] (a : ℝ) :
    H Finset.univ (fun i => if P i then a else 0)
      = (Finset.univ.filter P).card * nlp a := by
  rw [H_ite_two P a 0]
  simp [nlp]

end EntropyTools

/-! ## Mutual information of a joint distribution -/

/-- Mutual information, in bits, of a joint distribution on a product of finite
types: `I(X;Y) = H(X) + H(Y) − H(X,Y)`. -/
noncomputable def MI {α β : Type*} [Fintype α] [Fintype β] (w : α × β → ℝ) : ℝ :=
  H Finset.univ (fun a : α => ∑ b : β, w (a, b))
    + H Finset.univ (fun b : β => ∑ a : α, w (a, b))
    - H Finset.univ w

/-! ## Logarithm values -/

private lemma logb_nine : Real.logb 2 9 = 2 * Real.logb 2 3 := by
  rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.logb_pow]; push_cast; ring

private lemma logb_six : Real.logb 2 6 = 1 + Real.logb 2 3 := by
  rw [show (6 : ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num)]
  simp

private lemma logb_eighteen : Real.logb 2 18 = 1 + 2 * Real.logb 2 3 := by
  rw [show (18 : ℝ) = 2 * 3 ^ 2 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_pow]
  simp

private lemma nlp_inv (n : ℝ) : nlp (1 / n) = (1 / n) * Real.logb 2 n := by
  rw [nlp, one_div, Real.logb_inv]; ring

private lemma nlp_one_sixth : nlp (1 / 6) = (1 + Real.logb 2 3) / 6 := by
  rw [nlp_inv 6, logb_six]; ring

private lemma nlp_one_ninth : nlp (1 / 9) = 2 * Real.logb 2 3 / 9 := by
  rw [nlp_inv 9, logb_nine]; ring

private lemma nlp_one_eighteenth : nlp (1 / 18) = (1 + 2 * Real.logb 2 3) / 18 := by
  rw [nlp_inv 18, logb_eighteen]; ring

private lemma nlp_one_third : nlp (1 / 3) = Real.logb 2 3 / 3 := by
  rw [nlp_inv 3]; ring

private lemma nlp_two_thirds : nlp (2 / 3) = (2 * Real.logb 2 3 - 2) / 3 := by
  have h : (2 : ℝ) / 3 = 1 / (3 / 2) := by norm_num
  rw [h, nlp_inv (3 / 2),
    show (3 : ℝ) / 2 = 3 / 2 from rfl, Real.logb_div (by norm_num) (by norm_num)]
  simp
  ring

private lemma nlp_four_ninths : nlp (4 / 9) = (2 * Real.logb 2 3 - 2) * 4 / 9 := by
  have h : (4 : ℝ) / 9 = 1 / (9 / 4) := by norm_num
  rw [h, nlp_inv (9 / 4), Real.logb_div (by norm_num) (by norm_num), logb_nine,
    show (4 : ℝ) = 2 ^ 2 by norm_num, Real.logb_pow]
  simp
  ring

private lemma nlp_two_ninths : nlp (2 / 9) = (2 * Real.logb 2 3 - 1) * 2 / 9 := by
  have h : (2 : ℝ) / 9 = 1 / (9 / 2) := by norm_num
  rw [h, nlp_inv (9 / 2), Real.logb_div (by norm_num) (by norm_num), logb_nine]
  simp
  ring

/-! ## Numerical bounds on `log₂ 3` -/

theorem log2_three_gt : 1.584 < Real.logb 2 3 := by
  have hnat : (2 : ℕ) ^ 1584 < 3 ^ 1000 := by decide +kernel
  have hr : (2 : ℝ) ^ (1584 : ℕ) < (3 : ℝ) ^ (1000 : ℕ) := by exact_mod_cast hnat
  have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hr
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)] at h
  push_cast at h
  linarith

theorem log2_three_lt : Real.logb 2 3 < 1.585 := by
  have hnat : (3 : ℕ) ^ 1000 < 2 ^ 1585 := by decide +kernel
  have hr : (3 : ℝ) ^ (1000 : ℕ) < (2 : ℝ) ^ (1585 : ℕ) := by exact_mod_cast hnat
  have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hr
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)] at h
  push_cast at h
  linarith

/-! ## The type map -/

/-- The **splitting type** of a residue class: `true` = split completely
(residue degree `1`), `false` = inert (residue degree `3`). -/
def resType (a : ZMod 7) : Bool := decide (a = 1 ∨ a = 6)

/-- The Boolean type map agrees with the residue degree of the arithmetic file. -/
theorem resType_iff_resDeg (a : ZMod 7) : resType a = true ↔ resDeg a = 1 := by
  unfold resType resDeg
  by_cases h : a = 1 ∨ a = 6 <;> simp [h]

/-- Only two types occur, matching `resDeg_eq_one_or_three`. -/
theorem resType_dichotomy (a : ZMod 7) :
    (resType a = true ∧ resDeg a = 1) ∨ (resType a = false ∧ resDeg a = 3) := by
  unfold resType resDeg
  by_cases h : a = 1 ∨ a = 6 <;> simp [h]

/-! ## The single-prime channel `p mod 7 ⟶ type` -/

/-- The six invertible residues mod `7`. -/
def units7 : Finset (ZMod 7) := Finset.univ.erase 0

/-- Number of invertible residues with residue `n` and type `b` (so `0` or `1`). -/
def countRT (n : ZMod 7) (b : Bool) : ℕ :=
  (units7.filter (fun u => u = n ∧ resType u = b)).card

lemma countRT_eq : ∀ n b, countRT n b = if n ≠ 0 ∧ resType n = b then 1 else 0 := by decide

lemma countRT_sum_type : ∀ n : ZMod 7, ∑ b : Bool, countRT n b = if n ≠ 0 then 1 else 0 := by
  decide

lemma countRT_sum_res : ∀ b : Bool, ∑ n : ZMod 7, countRT n b = if b then 2 else 4 := by decide

/-- Joint law of `(p mod 7, type of p)` under the uniform law on invertible
residues. -/
noncomputable def pRT (q : ZMod 7 × Bool) : ℝ := (countRT q.1 q.2 : ℝ) / 6

lemma pRT_eq (q : ZMod 7 × Bool) :
    pRT q = if q.1 ≠ 0 ∧ resType q.1 = q.2 then 1 / 6 else 0 := by
  simp only [pRT, countRT_eq]
  split <;> norm_num

/-- The joint law is a probability distribution. -/
theorem pRT_sum_one : ∑ q : ZMod 7 × Bool, pRT q = 1 := by
  have h : ∀ q : ZMod 7 × Bool, pRT q = ((countRT q.1 q.2 : ℕ) : ℝ) / 6 := fun _ => rfl
  simp only [h, ← Finset.sum_div]
  rw [show ∑ q : ZMod 7 × Bool, ((countRT q.1 q.2 : ℕ) : ℝ)
      = ((∑ q : ZMod 7 × Bool, countRT q.1 q.2 : ℕ) : ℝ) by push_cast; rfl]
  norm_num [show (∑ q : ZMod 7 × Bool, countRT q.1 q.2) = 6 from by decide]

/-- Residue marginal: uniform on the six invertible classes. -/
lemma pRT_marginal_res (n : ZMod 7) :
    (∑ b : Bool, pRT (n, b)) = if n ≠ 0 then 1 / 6 else 0 := by
  have h : (∑ b : Bool, pRT (n, b)) = ((∑ b : Bool, countRT n b : ℕ) : ℝ) / 6 := by
    simp only [pRT, ← Finset.sum_div]
    push_cast
    rfl
  rw [h, countRT_sum_type n]
  split <;> norm_num

/-- Type marginal: `1/3` split, `2/3` inert. -/
lemma pRT_marginal_type (b : Bool) :
    (∑ n : ZMod 7, pRT (n, b)) = if b then 1 / 3 else 2 / 3 := by
  have h : (∑ n : ZMod 7, pRT (n, b)) = ((∑ n : ZMod 7, countRT n b : ℕ) : ℝ) / 6 := by
    simp only [pRT, ← Finset.sum_div]
    push_cast
    rfl
  rw [h, countRT_sum_res b]
  cases b <;> norm_num

/-- **Type entropy.**  `H(T) = log₂ 3 − 2/3` bits. -/
theorem H_typeMarginal :
    H Finset.univ (fun b : Bool => ∑ n : ZMod 7, pRT (n, b)) = Real.logb 2 3 - 2 / 3 := by
  have hfun : (fun b : Bool => ∑ n : ZMod 7, pRT (n, b))
      = fun b : Bool => if b = true then (1 : ℝ) / 3 else 2 / 3 := by
    funext b
    rw [pRT_marginal_type b]
  rw [hfun, H_ite_two (fun b : Bool => b = true) (1 / 3) (2 / 3)]
  rw [show (Finset.univ.filter (fun b : Bool => b = true)).card = 1 from by decide,
    show (Finset.univ.filter (fun b : Bool => ¬ b = true)).card = 1 from by decide,
    nlp_one_third, nlp_two_thirds]
  push_cast
  ring

/-- Residue entropy: `log₂ 6`. -/
theorem H_resMarginal :
    H Finset.univ (fun n : ZMod 7 => ∑ b : Bool, pRT (n, b)) = 1 + Real.logb 2 3 := by
  have hfun : (fun n : ZMod 7 => ∑ b : Bool, pRT (n, b))
      = fun n : ZMod 7 => if n ≠ 0 then (1 : ℝ) / 6 else 0 := funext pRT_marginal_res
  rw [hfun, H_ite_zero (fun n : ZMod 7 => n ≠ 0) (1 / 6),
    show (Finset.univ.filter (fun n : ZMod 7 => n ≠ 0)).card = 6 from by decide, nlp_one_sixth]
  push_cast
  ring

/-- Joint entropy: also `log₂ 6`, because the type is a function of the residue. -/
theorem H_jointRT : H Finset.univ pRT = 1 + Real.logb 2 3 := by
  have hfun : pRT = fun q : ZMod 7 × Bool => if q.1 ≠ 0 ∧ resType q.1 = q.2 then (1 : ℝ) / 6
      else 0 := funext pRT_eq
  rw [hfun, H_ite_zero (fun q : ZMod 7 × Bool => q.1 ≠ 0 ∧ resType q.1 = q.2) (1 / 6),
    show (Finset.univ.filter
      (fun q : ZMod 7 × Bool => q.1 ≠ 0 ∧ resType q.1 = q.2)).card = 6 from by decide,
    nlp_one_sixth]
  push_cast
  ring

/-- **The type channel of the cyclic cubic field.**
`I(p mod 7 ; T) = log₂ 3 − 2/3 = 0.918296…` bits. -/
theorem mutualInfo_residue_type : MI pRT = Real.logb 2 3 - 2 / 3 := by
  unfold MI
  rw [H_resMarginal, H_typeMarginal, H_jointRT]
  ring

/-- **Full pinning.**  The mutual information equals the full type entropy:
knowing `p mod 7` determines the splitting type with no residual uncertainty. -/
theorem full_pinning :
    MI pRT = H Finset.univ (fun b : Bool => ∑ n : ZMod 7, pRT (n, b)) := by
  rw [mutualInfo_residue_type, H_typeMarginal]

/-- Numerical form: `H(T) = I(p mod 7; T) ∈ (0.917, 0.919)` bits. -/
theorem H_typeMarginal_bounds :
    0.917 < H Finset.univ (fun b : Bool => ∑ n : ZMod 7, pRT (n, b)) ∧
      H Finset.univ (fun b : Bool => ∑ n : ZMod 7, pRT (n, b)) < 0.919 := by
  rw [H_typeMarginal]
  constructor
  · linarith [log2_three_gt]
  · linarith [log2_three_lt]

/-! ## The semiprime channel `N = p·q mod 7 ⟶ unordered type pair` -/

/-- The `36` ordered pairs of invertible residues. -/
def pairs7 : Finset (ZMod 7 × ZMod 7) := Finset.univ.filter (fun q => q.1 ≠ 0 ∧ q.2 ≠ 0)

/-- How many of the two factors split (an unordered type pair). -/
def splitCount (u v : ZMod 7) : Fin 3 :=
  if resType u ∧ resType v then 2 else if resType u ∨ resType v then 1 else 0

/-- Count of factorisations of `n` with a given unordered type pair. -/
def countSemi (n : ZMod 7) (k : Fin 3) : ℕ :=
  (pairs7.filter (fun q => q.1 * q.2 = n ∧ splitCount q.1 q.2 = k)).card

/-- `n` is a nonzero class of "split" type (`n ≡ ±1`). -/
def clsA (n : ZMod 7) : Prop := n = 1 ∨ n = 6

/-- `n` is a nonzero class of "inert" type. -/
def clsB (n : ZMod 7) : Prop := n ≠ 0 ∧ n ≠ 1 ∧ n ≠ 6

instance (n : ZMod 7) : Decidable (clsA n) := by unfold clsA; infer_instance
instance (n : ZMod 7) : Decidable (clsB n) := by unfold clsB; infer_instance

lemma countSemi_eq : ∀ n k, countSemi n k =
    if (clsA n ∧ k = 0) ∨ (clsB n ∧ k = 1) then 4
    else if (clsA n ∧ k = 2) ∨ (clsB n ∧ k = 0) then 2 else 0 := by decide

lemma countSemi_sum_k : ∀ n : ZMod 7, ∑ k : Fin 3, countSemi n k = if n ≠ 0 then 6 else 0 := by
  decide

lemma countSemi_sum_n : ∀ k : Fin 3, ∑ n : ZMod 7, countSemi n k = if k = 2 then 4 else 16 := by
  decide

/-- Joint law of `(N mod 7, unordered type pair)` for `N = p·q` with `p, q`
independent and uniform on invertible residues. -/
noncomputable def pSemi (q : ZMod 7 × Fin 3) : ℝ := (countSemi q.1 q.2 : ℝ) / 36

lemma pSemi_eq (q : ZMod 7 × Fin 3) :
    pSemi q = if (clsA q.1 ∧ q.2 = 0) ∨ (clsB q.1 ∧ q.2 = 1) then 1 / 9
      else if (clsA q.1 ∧ q.2 = 2) ∨ (clsB q.1 ∧ q.2 = 0) then 1 / 18 else 0 := by
  simp only [pSemi, countSemi_eq]
  split
  · norm_num
  · split <;> norm_num

theorem pSemi_sum_one : ∑ q : ZMod 7 × Fin 3, pSemi q = 1 := by
  have h : ∀ q : ZMod 7 × Fin 3, pSemi q = ((countSemi q.1 q.2 : ℕ) : ℝ) / 36 := fun _ => rfl
  simp only [h, ← Finset.sum_div]
  rw [show ∑ q : ZMod 7 × Fin 3, ((countSemi q.1 q.2 : ℕ) : ℝ)
      = ((∑ q : ZMod 7 × Fin 3, countSemi q.1 q.2 : ℕ) : ℝ) by push_cast; rfl]
  norm_num [show (∑ q : ZMod 7 × Fin 3, countSemi q.1 q.2) = 36 from by decide]

lemma pSemi_marginal_res (n : ZMod 7) :
    (∑ k : Fin 3, pSemi (n, k)) = if n ≠ 0 then 1 / 6 else 0 := by
  have h : (∑ k : Fin 3, pSemi (n, k)) = ((∑ k : Fin 3, countSemi n k : ℕ) : ℝ) / 36 := by
    simp only [pSemi, ← Finset.sum_div]
    push_cast
    rfl
  rw [h, countSemi_sum_k n]
  split <;> norm_num

lemma pSemi_marginal_pair (k : Fin 3) :
    (∑ n : ZMod 7, pSemi (n, k)) = if k = 2 then 1 / 9 else 4 / 9 := by
  have h : (∑ n : ZMod 7, pSemi (n, k)) = ((∑ n : ZMod 7, countSemi n k : ℕ) : ℝ) / 36 := by
    simp only [pSemi, ← Finset.sum_div]
    push_cast
    rfl
  rw [h, countSemi_sum_n k]
  split <;> norm_num

theorem H_semi_res :
    H Finset.univ (fun n : ZMod 7 => ∑ k : Fin 3, pSemi (n, k)) = 1 + Real.logb 2 3 := by
  have hfun : (fun n : ZMod 7 => ∑ k : Fin 3, pSemi (n, k))
      = fun n : ZMod 7 => if n ≠ 0 then (1 : ℝ) / 6 else 0 := funext pSemi_marginal_res
  rw [hfun, H_ite_zero (fun n : ZMod 7 => n ≠ 0) (1 / 6),
    show (Finset.univ.filter (fun n : ZMod 7 => n ≠ 0)).card = 6 from by decide, nlp_one_sixth]
  push_cast
  ring

/-- Entropy of the unordered type pair: `2·log₂ 3 − 16/9` bits. -/
theorem H_semi_pair :
    H Finset.univ (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k))
      = 2 * Real.logb 2 3 - 16 / 9 := by
  have hfun : (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k))
      = fun k : Fin 3 => if k = 2 then (1 : ℝ) / 9 else 4 / 9 := funext pSemi_marginal_pair
  rw [hfun, H_ite_two (fun k : Fin 3 => k = 2) (1 / 9) (4 / 9),
    show (Finset.univ.filter (fun k : Fin 3 => k = 2)).card = 1 from by decide,
    show (Finset.univ.filter (fun k : Fin 3 => ¬ k = 2)).card = 2 from by decide,
    nlp_one_ninth, nlp_four_ninths]
  push_cast
  ring

/-- Joint entropy of `(N mod 7, unordered type pair)`: `2·log₂ 3 + 1/3`. -/
theorem H_semi_joint : H Finset.univ pSemi = 2 * Real.logb 2 3 + 1 / 3 := by
  have hfun : pSemi = fun q : ZMod 7 × Fin 3 =>
      if (clsA q.1 ∧ q.2 = 0) ∨ (clsB q.1 ∧ q.2 = 1) then (1 : ℝ) / 9
      else if (clsA q.1 ∧ q.2 = 2) ∨ (clsB q.1 ∧ q.2 = 0) then 1 / 18 else 0 := funext pSemi_eq
  rw [hfun, H_ite_three (fun q : ZMod 7 × Fin 3 => (clsA q.1 ∧ q.2 = 0) ∨ (clsB q.1 ∧ q.2 = 1))
      (fun q : ZMod 7 × Fin 3 => (clsA q.1 ∧ q.2 = 2) ∨ (clsB q.1 ∧ q.2 = 0)) (1 / 9) (1 / 18) 0,
    show (Finset.univ.filter (fun q : ZMod 7 × Fin 3 =>
      (clsA q.1 ∧ q.2 = 0) ∨ (clsB q.1 ∧ q.2 = 1))).card = 6 from by decide,
    show (Finset.univ.filter (fun q : ZMod 7 × Fin 3 =>
      ¬((clsA q.1 ∧ q.2 = 0) ∨ (clsB q.1 ∧ q.2 = 1)) ∧
        ((clsA q.1 ∧ q.2 = 2) ∨ (clsB q.1 ∧ q.2 = 0)))).card = 6 from by decide,
    nlp_one_ninth, nlp_one_eighteenth]
  simp only [nlp, Real.logb_zero, mul_zero, neg_zero, mul_zero, add_zero]
  push_cast
  ring

/-- **Pinning is destroyed by multiplication.**  For a semiprime `N = p·q`, the
residue `N mod 7` carries only `log₂ 3 − 10/9 = 0.473852…` bits about the
unordered pair of splitting types. -/
theorem mutualInfo_semiprime : MI pSemi = Real.logb 2 3 - 10 / 9 := by
  unfold MI
  rw [H_semi_res, H_semi_pair, H_semi_joint]
  ring

/-- The semiprime channel transmits strictly less than the full pair entropy:
pinning fails. -/
theorem semiprime_not_pinned :
    MI pSemi < H Finset.univ (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k)) := by
  rw [mutualInfo_semiprime, H_semi_pair]
  linarith [log2_three_gt]

theorem mutualInfo_semiprime_bounds : 0.472 < MI pSemi ∧ MI pSemi < 0.475 := by
  rw [mutualInfo_semiprime]
  constructor
  · linarith [log2_three_gt]
  · linarith [log2_three_lt]

/-! ## Which factor is which: exactly zero bits -/

/-- Count of factorisations of `n` with a given *ordered* pair of types. -/
def countOrd (n : ZMod 7) (b : Bool × Bool) : ℕ :=
  (pairs7.filter (fun q => q.1 * q.2 = n ∧ (resType q.1, resType q.2) = b)).card

/-- **The exact swap symmetry.**  For every residue `n`, exchanging the two
factors leaves the joint law unchanged. -/
theorem countOrd_swap : ∀ (n : ZMod 7) (b : Bool × Bool),
    countOrd n b = countOrd n (b.2, b.1) := by decide

lemma countOrd_eq : ∀ n b, countOrd n b =
    if clsA n ∧ b = (false, false) then 4
    else if (clsA n ∧ b = (true, true)) ∨ (clsB n ∧ b ≠ (true, true)) then 2 else 0 := by decide

lemma countOrd_sum_b : ∀ n : ZMod 7, ∑ b : Bool × Bool, countOrd n b = if n ≠ 0 then 6 else 0 := by
  decide

lemma countOrd_sum_n : ∀ b : Bool × Bool, ∑ n : ZMod 7, countOrd n b =
    if b = (true, true) then 4 else if b = (false, false) then 16 else 8 := by decide

/-- Joint law of `(N mod 7, ordered pair of types)`. -/
noncomputable def pOrd (q : ZMod 7 × (Bool × Bool)) : ℝ := (countOrd q.1 q.2 : ℝ) / 36

lemma pOrd_eq (q : ZMod 7 × (Bool × Bool)) :
    pOrd q = if clsA q.1 ∧ q.2 = (false, false) then 1 / 9
      else if (clsA q.1 ∧ q.2 = (true, true)) ∨ (clsB q.1 ∧ q.2 ≠ (true, true)) then 1 / 18
      else 0 := by
  simp only [pOrd, countOrd_eq]
  split
  · norm_num
  · split <;> norm_num

theorem pOrd_sum_one : ∑ q : ZMod 7 × (Bool × Bool), pOrd q = 1 := by
  have h : ∀ q : ZMod 7 × (Bool × Bool), pOrd q = ((countOrd q.1 q.2 : ℕ) : ℝ) / 36 := fun _ => rfl
  simp only [h, ← Finset.sum_div]
  rw [show ∑ q : ZMod 7 × (Bool × Bool), ((countOrd q.1 q.2 : ℕ) : ℝ)
      = ((∑ q : ZMod 7 × (Bool × Bool), countOrd q.1 q.2 : ℕ) : ℝ) by push_cast; rfl]
  norm_num [show (∑ q : ZMod 7 × (Bool × Bool), countOrd q.1 q.2) = 36 from by decide]

lemma pOrd_marginal_res (n : ZMod 7) :
    (∑ b : Bool × Bool, pOrd (n, b)) = if n ≠ 0 then 1 / 6 else 0 := by
  have h : (∑ b : Bool × Bool, pOrd (n, b)) = ((∑ b : Bool × Bool, countOrd n b : ℕ) : ℝ) / 36 := by
    simp only [pOrd, ← Finset.sum_div]
    push_cast
    rfl
  rw [h, countOrd_sum_b n]
  split <;> norm_num

lemma pOrd_marginal_pair (b : Bool × Bool) :
    (∑ n : ZMod 7, pOrd (n, b))
      = if b = (true, true) then 1 / 9 else if b = (false, false) then 4 / 9 else 2 / 9 := by
  have h : (∑ n : ZMod 7, pOrd (n, b)) = ((∑ n : ZMod 7, countOrd n b : ℕ) : ℝ) / 36 := by
    simp only [pOrd, ← Finset.sum_div]
    push_cast
    rfl
  rw [h, countOrd_sum_n b]
  split
  · norm_num
  · split <;> norm_num

theorem H_ord_res :
    H Finset.univ (fun n : ZMod 7 => ∑ b : Bool × Bool, pOrd (n, b)) = 1 + Real.logb 2 3 := by
  have hfun : (fun n : ZMod 7 => ∑ b : Bool × Bool, pOrd (n, b))
      = fun n : ZMod 7 => if n ≠ 0 then (1 : ℝ) / 6 else 0 := funext pOrd_marginal_res
  rw [hfun, H_ite_zero (fun n : ZMod 7 => n ≠ 0) (1 / 6),
    show (Finset.univ.filter (fun n : ZMod 7 => n ≠ 0)).card = 6 from by decide, nlp_one_sixth]
  push_cast
  ring

/-- Entropy of the *ordered* type pair: `2·log₂ 3 − 4/3` bits (exactly `4/9`
bits more than the unordered pair — the which-factor bit). -/
theorem H_ord_pair :
    H Finset.univ (fun b : Bool × Bool => ∑ n : ZMod 7, pOrd (n, b))
      = 2 * Real.logb 2 3 - 4 / 3 := by
  have hfun : (fun b : Bool × Bool => ∑ n : ZMod 7, pOrd (n, b))
      = fun b : Bool × Bool => if b = (true, true) then (1 : ℝ) / 9
        else if b = (false, false) then 4 / 9 else 2 / 9 := funext pOrd_marginal_pair
  rw [hfun, H_ite_three (fun b : Bool × Bool => b = (true, true))
      (fun b : Bool × Bool => b = (false, false)) (1 / 9) (4 / 9) (2 / 9),
    show (Finset.univ.filter (fun b : Bool × Bool => b = (true, true))).card = 1 from by decide,
    show (Finset.univ.filter (fun b : Bool × Bool =>
      ¬ b = (true, true) ∧ b = (false, false))).card = 1 from by decide,
    show (Finset.univ.filter (fun b : Bool × Bool =>
      ¬ b = (true, true) ∧ ¬ b = (false, false))).card = 2 from by decide,
    nlp_one_ninth, nlp_four_ninths, nlp_two_ninths]
  push_cast
  ring

/-- Joint entropy with the ordered pair: `2·log₂ 3 + 7/9`. -/
theorem H_ord_joint : H Finset.univ pOrd = 2 * Real.logb 2 3 + 7 / 9 := by
  have hfun : pOrd = fun q : ZMod 7 × (Bool × Bool) =>
      if clsA q.1 ∧ q.2 = (false, false) then (1 : ℝ) / 9
      else if (clsA q.1 ∧ q.2 = (true, true)) ∨ (clsB q.1 ∧ q.2 ≠ (true, true)) then 1 / 18
      else 0 := funext pOrd_eq
  rw [hfun, H_ite_three (fun q : ZMod 7 × (Bool × Bool) => clsA q.1 ∧ q.2 = (false, false))
      (fun q : ZMod 7 × (Bool × Bool) =>
        (clsA q.1 ∧ q.2 = (true, true)) ∨ (clsB q.1 ∧ q.2 ≠ (true, true))) (1 / 9) (1 / 18) 0,
    show (Finset.univ.filter (fun q : ZMod 7 × (Bool × Bool) =>
      clsA q.1 ∧ q.2 = (false, false))).card = 2 from by decide,
    show (Finset.univ.filter (fun q : ZMod 7 × (Bool × Bool) =>
      ¬(clsA q.1 ∧ q.2 = (false, false)) ∧
        ((clsA q.1 ∧ q.2 = (true, true)) ∨ (clsB q.1 ∧ q.2 ≠ (true, true))))).card = 14 from
      by decide,
    nlp_one_ninth, nlp_one_eighteenth]
  simp only [nlp, Real.logb_zero, mul_zero, neg_zero, add_zero]
  push_cast
  ring

/-- The ordered channel carries exactly as much information as the unordered
one: `I(N ; ordered pair) = log₂ 3 − 10/9`. -/
theorem mutualInfo_ordered : MI pOrd = Real.logb 2 3 - 10 / 9 := by
  unfold MI
  rw [H_ord_res, H_ord_pair, H_ord_joint]
  ring

/-- **Which-factor information is exactly zero.**  Knowing `N mod 7` tells you
the multiset of splitting types of the two factors as well as it possibly can,
but *nothing at all* about which factor carries which type. -/
theorem which_factor_information_zero : MI pOrd - MI pSemi = 0 := by
  rw [mutualInfo_ordered, mutualInfo_semiprime]
  ring

/-- The which-factor bit itself is not deterministic — it carries `4/9` bits of
raw entropy — yet the residue channel reveals none of it. -/
theorem which_factor_entropy_positive :
    H Finset.univ (fun b : Bool × Bool => ∑ n : ZMod 7, pOrd (n, b))
      - H Finset.univ (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k)) = 4 / 9 := by
  rw [H_ord_pair, H_semi_pair]
  ring

end CyclicCubic