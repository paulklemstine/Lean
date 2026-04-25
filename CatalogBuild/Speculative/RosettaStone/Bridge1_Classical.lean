/-! # CatalogBuild.Speculative.RosettaStone.Bridge1_Classical

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 7
-/

import Mathlib

/-- Idempotent orthogonality: e(1-e) = 0. -/
theorem idempotent_orthogonal (e : R) (he : e * e = e) :
    e * (1 - e) = 0 := by
  rw [mul_sub, mul_one, he, sub_self]


/-- The complementary orthogonality: (1-e)e = 0. -/
theorem idempotent_orthogonal' (e : R) (he : e * e = e) :
    (1 - e) * e = 0 := by
  rw [sub_mul, one_mul, he, sub_self]


/-- Double complement: 1-(1-e) = e. -/
theorem idempotent_double_complement (e : R) :
    1 - (1 - e) = e := by simp


/-- Idempotent power stability: eⁿ = e for all n ≥ 1. -/
theorem idempotent_pow (e : R) (he : e * e = e) :
    ∀ n : ℕ, n ≥ 1 → e ^ n = e := by
  intro n hn
  induction n with
  | zero => omega
  | succ n ih =>
    cases n with
    | zero => simp
    | succ n =>
      rw [pow_succ, ih (by omega)]
      exact he


/-- In a commutative ring, if e² = e, then (ea)² = e · a². -/
theorem idempotent_ideal (e a : S) (he : e * e = e) :
    (e * a) * (e * a) = e * (a * a) := by
  rw [mul_mul_mul_comm, he]


/-- In ℤ/2ℤ, every element is idempotent. -/
theorem zmod2_idempotents :
    ∀ e : ZMod 2, e * e = e := by decide


/-- In ℤ/6ℤ, there are exactly 4 idempotents. -/
theorem zmod6_idempotent_count :
    (Finset.univ.filter (fun e : ZMod 6 => e * e = e)).card = 4 := by decide


