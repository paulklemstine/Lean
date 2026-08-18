/-
# The price of universality, I: codes, entropy and per-source redundancy

This file sets up the basic apparatus used throughout the *price of universality*
development:

* length functions and the Kraft inequality (`IsCode`),
* Shannon entropy, relative entropy (Kullback-Leibler divergence) and
  expected code length, all measured in **bits**,
* Gibbs' inequality (`kl_nonneg`),
* the source coding lower bound `entropy_le_expLen`, i.e. *redundancy is
  nonnegative*, and
* the Shannon code, showing the per-source optimum is within one bit of the
  entropy (`exists_code_redundancy_le_one`).

Everything is finitary and completely self-contained.
-/
import Mathlib

namespace PriceOfUniversality

open Finset Real

variable {A : Type*} [Fintype A]

/-! ## Codes -/

/-- The Kraft sum `∑ 2 ^ (-L a)` of a length function. -/
noncomputable def kraftSum (L : A → ℕ) : ℝ := ∑ a, ((2 : ℝ) ⁻¹) ^ (L a)

/-- A length function is a *code* when it satisfies Kraft's inequality; by the
Kraft-McMillan theorem this is exactly the constraint satisfied by uniquely
decodable codes. -/
def IsCode (L : A → ℕ) : Prop := kraftSum L ≤ 1

/-- A probability mass function on a finite alphabet. -/
structure IsPMF (p : A → ℝ) : Prop where
  nonneg : ∀ a, 0 ≤ p a
  total : ∑ a, p a = 1

/-! ## Information quantities (in bits) -/

/-- Shannon entropy, in bits. -/
noncomputable def entropy (p : A → ℝ) : ℝ := ∑ a, -(p a * logb 2 (p a))

/-- Relative entropy (KL divergence), in bits. -/
noncomputable def kl (p q : A → ℝ) : ℝ := ∑ a, p a * logb 2 (p a / q a)

/-- Expected code length, in bits. -/
noncomputable def expLen (p : A → ℝ) (L : A → ℕ) : ℝ := ∑ a, p a * (L a : ℝ)

/-- The redundancy of the code `L` on the source `p`: the number of bits spent
above the entropy of `p`. -/
noncomputable def redundancy (p : A → ℝ) (L : A → ℕ) : ℝ := expLen p L - entropy p

/-! ## Gibbs' inequality -/

private lemma log_ratio_le (x y : ℝ) (hx : 0 ≤ x) (hy : 0 < y) :
    x * Real.log (y / x) ≤ y - x := by
  rcases eq_or_lt_of_le hx with h | hx'
  · simp [← h, hy.le]
  · have h1 : Real.log (y / x) ≤ y / x - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have := mul_le_mul_of_nonneg_left h1 hx
    calc x * Real.log (y / x) ≤ x * (y / x - 1) := this
      _ = y - x := by field_simp
    
/-- **Gibbs' inequality**: relative entropy is nonnegative, for `p` a probability
distribution and `q` a strictly positive sub-probability weight. -/
theorem kl_nonneg {p q : A → ℝ} (hp : IsPMF p) (hq : ∀ a, 0 < q a)
    (hq1 : ∑ a, q a ≤ 1) : 0 ≤ kl p q := by
  have key : ∑ a, p a * Real.log (q a / p a) ≤ 0 := by
    have h1 : ∀ a ∈ (univ : Finset A), p a * Real.log (q a / p a) ≤ q a - p a := by
      intro a _
      exact log_ratio_le _ _ (hp.nonneg a) (hq a)
    calc ∑ a, p a * Real.log (q a / p a) ≤ ∑ a, (q a - p a) := Finset.sum_le_sum h1
      _ = (∑ a, q a) - 1 := by rw [Finset.sum_sub_distrib, hp.total]
      _ ≤ 0 := by linarith
  have hswap : ∀ a, p a * logb 2 (p a / q a) = -((p a * Real.log (q a / p a)) / Real.log 2) := by
    intro a
    rcases eq_or_lt_of_le (hp.nonneg a) with h | h
    · simp [← h]
    · have : p a / q a = (q a / p a)⁻¹ := by
        field_simp
      rw [logb, this, Real.log_inv]
      ring
  have h2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [kl]
  simp only [hswap, ← neg_div]
  rw [← Finset.sum_div, Finset.sum_neg_distrib]
  exact div_nonneg (by linarith) h2.le

/-! ## Source coding lower bound -/

/-- Redundancy decomposes as a relative entropy against the coding distribution
`2 ^ (-L a)`. -/
theorem redundancy_eq_kl {p : A → ℝ} (hp : IsPMF p) (L : A → ℕ) :
    redundancy p L = kl p (fun a => ((2:ℝ)⁻¹) ^ (L a)) := by
  rw [redundancy, expLen, entropy, kl, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl ?_
  intro a _
  rcases eq_or_lt_of_le (hp.nonneg a) with h | h
  · simp [← h]
  · have hpow : (0:ℝ) < ((2:ℝ)⁻¹) ^ (L a) := by positivity
    have : logb 2 (p a / ((2:ℝ)⁻¹) ^ (L a)) = logb 2 (p a) + (L a : ℝ) := by
      rw [Real.logb_div (ne_of_gt h) (ne_of_gt hpow)]
      have hL2 : logb 2 (((2:ℝ)⁻¹) ^ (L a)) = -(L a : ℝ) := by
        rw [Real.logb_pow, Real.logb_inv]
        simp
      rw [hL2]; ring
    rw [this]; ring

/-- **Shannon's source coding lower bound**: no code beats the entropy. -/
theorem entropy_le_expLen {p : A → ℝ} (hp : IsPMF p) {L : A → ℕ} (hL : IsCode L) :
    entropy p ≤ expLen p L := by
  have := kl_nonneg hp (q := fun a => ((2:ℝ)⁻¹) ^ (L a)) (fun a => by positivity) hL
  rw [← redundancy_eq_kl hp L] at this
  rw [redundancy] at this
  linarith

/-- Redundancy is always nonnegative. -/
theorem redundancy_nonneg {p : A → ℝ} (hp : IsPMF p) {L : A → ℕ} (hL : IsCode L) :
    0 ≤ redundancy p L := by
  have := entropy_le_expLen hp hL
  rw [redundancy]; linarith

/-! ## The Shannon code: the per-source optimum costs at most one extra bit -/

lemma IsPMF.le_one {p : A → ℝ} (hp : IsPMF p) (a : A) : p a ≤ 1 := by
  have h := Finset.single_le_sum (f := p) (fun b _ => hp.nonneg b) (Finset.mem_univ a)
  rw [hp.total] at h
  exact h

/-- The Shannon code for a source `p`: give `a` the length `⌈log₂ (1 / p a)⌉`. -/
noncomputable def shannonCode (p : A → ℝ) : A → ℕ := fun a => ⌈-logb 2 (p a)⌉₊

private lemma two_inv_pow_eq_rpow (k : ℕ) : ((2:ℝ)⁻¹) ^ k = (2:ℝ) ^ (-(k : ℝ)) := by
  rw [Real.rpow_neg (by norm_num), Real.rpow_natCast, inv_pow]

/-- The Shannon code satisfies Kraft's inequality. -/
theorem shannonCode_isCode {p : A → ℝ} (hp : IsPMF p) (hpos : ∀ a, 0 < p a) :
    IsCode (shannonCode p) := by
  have hle : ∀ a : A, ((2:ℝ)⁻¹) ^ (shannonCode p a) ≤ p a := by
    intro a
    rw [two_inv_pow_eq_rpow]
    have hceil : -logb 2 (p a) ≤ (⌈-logb 2 (p a)⌉₊ : ℝ) := Nat.le_ceil _
    have hexp : -((shannonCode p a : ℝ)) ≤ logb 2 (p a) := by
      simp only [shannonCode]; linarith
    calc (2:ℝ) ^ (-(shannonCode p a : ℝ))
        ≤ (2:ℝ) ^ (logb 2 (p a)) :=
          Real.rpow_le_rpow_of_exponent_le (by norm_num) hexp
      _ = p a := Real.rpow_logb (by norm_num) (by norm_num) (hpos a)
  calc kraftSum (shannonCode p) ≤ ∑ a, p a := Finset.sum_le_sum (fun a _ => hle a)
    _ = 1 := hp.total

/-- **The per-source optimum is within one bit of the entropy.** For every source there
is a code whose redundancy on that source is at most one bit. -/
theorem exists_code_redundancy_le_one {p : A → ℝ} (hp : IsPMF p) (hpos : ∀ a, 0 < p a) :
    ∃ L : A → ℕ, IsCode L ∧ redundancy p L ≤ 1 := by
  refine ⟨shannonCode p, shannonCode_isCode hp hpos, ?_⟩
  have hlen : ∀ a : A, (shannonCode p a : ℝ) ≤ -logb 2 (p a) + 1 := by
    intro a
    have hnn : 0 ≤ -logb 2 (p a) := by
      have : logb 2 (p a) ≤ 0 := Real.logb_nonpos (by norm_num) (hpos a).le (hp.le_one a)
      linarith
    exact (Nat.ceil_lt_add_one hnn).le
  have hstep : expLen p (shannonCode p) ≤ ∑ a, p a * (-logb 2 (p a) + 1) := by
    refine Finset.sum_le_sum (fun a _ => ?_)
    exact mul_le_mul_of_nonneg_left (hlen a) (hp.nonneg a)
  have hsplit : ∑ a, p a * (-logb 2 (p a) + 1) = entropy p + 1 := by
    have hsp : ∑ a, p a * (-logb 2 (p a) + 1)
        = (∑ a, -(p a * logb 2 (p a))) + ∑ a, p a := by
      rw [← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl (fun a _ => by ring)
    rw [hsp, hp.total, entropy]
  rw [redundancy]
  linarith [hstep, hsplit.le, hsplit.ge]

end PriceOfUniversality