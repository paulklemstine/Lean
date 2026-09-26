module

public import Mathlib

/-!
# UNIVERSAL-S3-TEST (paper 111): the affine family `AGL(1,q)` and its fixed-point moments

The dials `S₃` and `F₂₀` of the hint table are the Galois groups of `x³ - 2` and `x⁵ - 2`.
Both are members of one family: the affine group `AGL(1,q) = {x ↦ a x + b : a ≠ 0}` acting on
`𝔽_q`, with `AGL(1,3) ≅ S₃` and `AGL(1,5) = F₂₀`.  By Chebotarev, the average of
`(#roots of the polynomial mod p)^k` over primes is the average of `(#fixed points)^k` over
the Galois group.  This file computes those group averages *exactly and uniformly in `q`*:

* `affFix_card` — the fixed-point count of `x ↦ a x + b` is `q` (identity), `0` (nontrivial
  translation) or `1` (`a ≠ 1`).
* `affine_moment` — `∑_{a ≠ 0, b} fix(a,b)^k = q^k + q (q - 2)` for every `k ≥ 1`.
* `affine_moment_one`, `affine_moment_two`, `affine_moment_three` — the normalised moments are
  `1`, `2`, `q + 2`.  The first two are **universal** (independent of `q`: Burnside and
  2-transitivity); the third is the first moment that **reads off `q`**.
* `affine_third_moment_injective` — hence an accidental `x⁵ - 2` measurement (`q = 5`) is
  invisible to root-count means and variances of an intended `x³ - 2` (`q = 3`) test, and is
  detected exactly at the third moment (`5` vs `7`).
* `affineToPerm_bijective_three` — `AGL(1,3)` acts on `ZMod 3` as the full symmetric group,
  i.e. the S₃ dial *is* the `q = 3` member of the affine family.

-- !-- Lab Notes -- !--
Hypothesis: root-count moments of `x^q - 2` mod `p` over primes are universal in `q`.
Experiment: primes `7 ≤ p < 400` (75 primes; `ComputationalEvidence.md`):
  `x³-2`: root counts `0/1/3` in `26/38/11` primes; `x⁵-2`: `0/1/5` in `14/58/3` primes.
  Empirical moments  `x³-2`: `0.947, 1.83, 4.47`;  `x⁵-2`: `0.973, 1.77, 5.77`.
Analysis: group-theoretic predictions (this file) `1, 2, 5` and `1, 2, 7`.  Moments 1–2
  agree across `q` (universal), moment 3 separates.
-/

@[expose] public section

namespace UniversalS3Test

open Finset

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-- Fixed points of the affine map `x ↦ a x + b`. -/
def affFix (a b : F) : Finset F := univ.filter (fun x => a * x + b = x)

/-- Fixed-point count of an affine map of `𝔽_q`. -/
theorem affFix_card (a b : F) :
    (affFix a b).card = if a = 1 then (if b = 0 then Fintype.card F else 0) else 1 := by
  unfold affFix
  split_ifs with ha hb
  · subst ha hb; simp
  · subst ha
    rw [card_eq_zero, filter_eq_empty_iff]
    intro x _ h; apply hb; linear_combination h
  · rw [card_eq_one]
    refine ⟨b / (1 - a), ?_⟩
    have h1 : (1 - a) ≠ 0 := sub_ne_zero.mpr (Ne.symm ha)
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_singleton]
    constructor
    · intro h; field_simp; linear_combination -h
    · intro h; subst h; field_simp; ring

/-- Contribution of a fixed slope `a` to the `k`-th moment. -/
theorem slope_moment (a : F) (k : ℕ) (hk : k ≠ 0) :
    ∑ b : F, (affFix a b).card ^ k =
      if a = 1 then Fintype.card F ^ k else Fintype.card F := by
  simp_rw [affFix_card]
  split_ifs with ha
  · simp only [ite_pow, zero_pow hk]
    rw [sum_ite_eq' univ (0 : F)]; simp
  · simp

/-- **The affine moment law.** For every `k ≥ 1`,
`∑_{a ≠ 0} ∑_b fix(x ↦ a x + b)^k = q^k + q (q - 2)`. -/
theorem affine_moment (k : ℕ) (hk : k ≠ 0) :
    ∑ a ∈ univ.filter (fun a : F => a ≠ 0), ∑ b : F, (affFix a b).card ^ k =
      Fintype.card F ^ k + Fintype.card F * (Fintype.card F - 2) := by
  simp_rw [slope_moment _ k hk]
  have h1 : (1 : F) ∈ univ.filter (fun a : F => a ≠ 0) := by simp
  rw [← add_sum_erase _ _ h1, if_pos rfl, sum_congr rfl
    (g := fun _ => Fintype.card F) (fun a ha => by
      rw [if_neg (mem_erase.mp ha).1])]
  rw [sum_const, smul_eq_mul, card_erase_of_mem h1]
  have : (univ.filter (fun a : F => a ≠ 0)).card = Fintype.card F - 1 := by
    rw [filter_ne' univ (0 : F), card_erase_of_mem (mem_univ _), card_univ]
  rw [this, Nat.sub_sub, mul_comm]

/-- Order of `AGL(1,q)`: `q (q - 1)` affine maps. -/
theorem affine_order :
    (univ.filter (fun a : F => a ≠ 0) ×ˢ (univ : Finset F)).card =
      Fintype.card F * (Fintype.card F - 1) := by
  rw [card_product, filter_ne' univ (0 : F), card_erase_of_mem (mem_univ _), card_univ,
    mul_comm]

omit [DecidableEq F] in
lemma two_le_card : 2 ≤ Fintype.card F := by
  have := Fintype.one_lt_card (α := F); omega

/-- **Burnside (moment 1, universal):** total fixed points `= |AGL(1,q)|`, mean `1`. -/
theorem affine_moment_one :
    ∑ a ∈ univ.filter (fun a : F => a ≠ 0), ∑ b : F, (affFix a b).card =
      Fintype.card F * (Fintype.card F - 1) := by
  have h := affine_moment (F := F) 1 one_ne_zero
  simp only [pow_one] at h
  rw [h]
  have := two_le_card (F := F)
  obtain ⟨m, hm⟩ : ∃ m, Fintype.card F = m + 2 := ⟨_, (Nat.sub_add_cancel this).symm⟩
  rw [hm]; simp only [Nat.add_sub_cancel]
  rw [show m + 2 - 1 = m + 1 by omega]; ring

/-- **2-transitivity (moment 2, universal):** normalised second moment `2`. -/
theorem affine_moment_two :
    ∑ a ∈ univ.filter (fun a : F => a ≠ 0), ∑ b : F, (affFix a b).card ^ 2 =
      2 * (Fintype.card F * (Fintype.card F - 1)) := by
  rw [affine_moment 2 two_ne_zero]
  have := two_le_card (F := F)
  obtain ⟨m, hm⟩ : ∃ m, Fintype.card F = m + 2 := ⟨_, (Nat.sub_add_cancel this).symm⟩
  rw [hm, show m + 2 - 2 = m by omega, show m + 2 - 1 = m + 1 by omega]; ring

/-- **Moment 3 reads off `q`:** normalised third moment `q + 2`. -/
theorem affine_moment_three :
    ∑ a ∈ univ.filter (fun a : F => a ≠ 0), ∑ b : F, (affFix a b).card ^ 3 =
      (Fintype.card F + 2) * (Fintype.card F * (Fintype.card F - 1)) := by
  rw [affine_moment 3 (by norm_num)]
  have := two_le_card (F := F)
  obtain ⟨m, hm⟩ : ∃ m, Fintype.card F = m + 2 := ⟨_, (Nat.sub_add_cancel this).symm⟩
  rw [hm, show m + 2 - 2 = m by omega, show m + 2 - 1 = m + 1 by omega]; ring

lemma normalised_mul (c X : ℕ) (hX : X ≠ 0) : ((c * X : ℕ) : ℚ) / (X : ℚ) = c := by
  rw [Nat.cast_mul, mul_div_cancel_right₀]; exact_mod_cast hX

instance fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩

/-- The normalised moment `k = 1, 2` coincide for any two finite fields: the wrong polynomial
is invisible to the first two moments. -/
theorem affine_low_moments_universal (K : Type*) [Field K] [Fintype K] [DecidableEq K] :
    ((∑ a ∈ univ.filter (fun a : F => a ≠ 0), ∑ b : F, (affFix a b).card : ℕ) : ℚ) /
        (Fintype.card F * (Fintype.card F - 1) : ℕ) =
      ((∑ a ∈ univ.filter (fun a : K => a ≠ 0), ∑ b : K, (affFix a b).card : ℕ) : ℚ) /
        (Fintype.card K * (Fintype.card K - 1) : ℕ) ∧
    ((∑ a ∈ univ.filter (fun a : F => a ≠ 0), ∑ b : F, (affFix a b).card ^ 2 : ℕ) : ℚ) /
        (Fintype.card F * (Fintype.card F - 1) : ℕ) =
      ((∑ a ∈ univ.filter (fun a : K => a ≠ 0), ∑ b : K, (affFix a b).card ^ 2 : ℕ) : ℚ) /
        (Fintype.card K * (Fintype.card K - 1) : ℕ) := by
  have hF : Fintype.card F * (Fintype.card F - 1) ≠ 0 := by
    have := two_le_card (F := F); exact Nat.mul_ne_zero (by omega) (by omega)
  have hK : Fintype.card K * (Fintype.card K - 1) ≠ 0 := by
    have := two_le_card (F := K); exact Nat.mul_ne_zero (by omega) (by omega)
  rw [affine_moment_one, affine_moment_one, affine_moment_two, affine_moment_two,
    normalised_mul _ _ hF, normalised_mul _ _ hK]
  refine ⟨?_, rfl⟩
  rw [div_self (by exact_mod_cast hF), div_self (by exact_mod_cast hK)]

/-- **The third moment detects the field size.** If two affine dials have the same normalised
third moment, they have the same `q`. -/
theorem affine_third_moment_injective (K : Type*) [Field K] [Fintype K] [DecidableEq K]
    (h : ((∑ a ∈ univ.filter (fun a : F => a ≠ 0), ∑ b : F, (affFix a b).card ^ 3 : ℕ) : ℚ) /
        (Fintype.card F * (Fintype.card F - 1) : ℕ) =
      ((∑ a ∈ univ.filter (fun a : K => a ≠ 0), ∑ b : K, (affFix a b).card ^ 3 : ℕ) : ℚ) /
        (Fintype.card K * (Fintype.card K - 1) : ℕ)) :
    Fintype.card F = Fintype.card K := by
  have hF : Fintype.card F * (Fintype.card F - 1) ≠ 0 := by
    have := two_le_card (F := F); exact Nat.mul_ne_zero (by omega) (by omega)
  have hK : Fintype.card K * (Fintype.card K - 1) ≠ 0 := by
    have := two_le_card (F := K); exact Nat.mul_ne_zero (by omega) (by omega)
  rw [affine_moment_three, affine_moment_three, normalised_mul _ _ hF,
    normalised_mul _ _ hK] at h
  exact_mod_cast add_right_cancel (Nat.cast_injective h : _)

/-- The S₃ dial (`q = 3`) vs the accidental F₂₀ dial (`q = 5`): third moments `30 = 6·5` and
`140 = 20·7`, while first and second moments are `6, 12` and `20, 40`. -/
theorem s3_vs_f20_moments :
    (∑ a ∈ univ.filter (fun a : ZMod 3 => a ≠ 0), ∑ b : ZMod 3, (affFix a b).card ^ 3 = 30) ∧
    (∑ a ∈ univ.filter (fun a : ZMod 5 => a ≠ 0), ∑ b : ZMod 5, (affFix a b).card ^ 3 = 140) := by
  refine ⟨?_, ?_⟩ <;> rw [affine_moment_three] <;> simp [ZMod.card]

/-! ## `AGL(1,3) ≅ S₃` -/

/-- The permutation of `F` induced by `x ↦ a x + b`, `a ≠ 0`. -/
def affinePerm (a : Fˣ) (b : F) : Equiv.Perm F where
  toFun x := a * x + b
  invFun y := a⁻¹ * (y - b)
  left_inv x := by simp
  right_inv y := by simp

omit [Fintype F] [DecidableEq F] in
theorem affinePerm_injective :
    Function.Injective (fun p : Fˣ × F => affinePerm p.1 p.2) := by
  rintro ⟨a, b⟩ ⟨a', b'⟩ h
  have h0 := congrArg (fun f : Equiv.Perm F => f 0) h
  have h1 := congrArg (fun f : Equiv.Perm F => f 1) h
  simp [affinePerm] at h0 h1
  subst h0
  have : a = a' := Units.ext (by linear_combination h1)
  simp [this]

/-- **The S₃ dial is `AGL(1,3)`:** every permutation of `ZMod 3` is affine. -/
theorem affineToPerm_bijective_three :
    Function.Bijective (fun p : (ZMod 3)ˣ × ZMod 3 => affinePerm p.1 p.2) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  rw [Fintype.bijective_iff_injective_and_card]
  refine ⟨affinePerm_injective, ?_⟩
  rw [Fintype.card_prod, Fintype.card_perm, ZMod.card_units_eq_totient, ZMod.card]
  decide

/-- For `q ≥ 4` the affine group is a proper subgroup of `Sym(𝔽_q)` — in particular
`F₂₀ = AGL(1,5)` is not `S₅`: the accidental measurement is not "S₃ at higher degree". -/
theorem affinePerm_not_surjective (h4 : 4 ≤ Fintype.card F) :
    ¬ Function.Surjective (fun p : Fˣ × F => affinePerm p.1 p.2) := by
  intro hs
  have hle := Fintype.card_le_of_surjective _ hs
  rw [Fintype.card_prod, Fintype.card_perm, Fintype.card_units] at hle
  obtain ⟨m, hm⟩ : ∃ m, Fintype.card F = m + 4 := ⟨_, (Nat.sub_add_cancel h4).symm⟩
  rw [hm, show m + 4 - 1 = m + 3 by omega] at hle
  have e : (m + 4).factorial = ((m + 4) * (m + 3)) * (m + 2).factorial := by
    rw [show m + 4 = (m + 3) + 1 by rfl, Nat.factorial_succ, show m + 3 = (m + 2) + 1 by rfl,
      Nat.factorial_succ]; ring
  have h2 : 2 ≤ (m + 2).factorial :=
    calc 2 = Nat.factorial 2 := rfl
      _ ≤ (m + 2).factorial := Nat.factorial_le (by omega)
  have hA : 0 < (m + 4) * (m + 3) := by positivity
  rw [e] at hle
  nlinarith

end UniversalS3Test

end