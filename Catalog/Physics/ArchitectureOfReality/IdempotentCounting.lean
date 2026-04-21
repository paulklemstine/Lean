/-! # CatalogBuild.Physics.ArchitectureOfReality.IdempotentCounting

Auto-generated from theorem catalog database.
Domain: Physics/ArchitectureOfReality
Declarations: 28
-/

import Mathlib

noncomputable section

/-- The set of idempotents in ℤ/nℤ -/
def idemSet (n : ℕ) [NeZero n] : Finset (ZMod n) :=
  Finset.univ.filter (fun e => e * e = e)




/-- Count of idempotents in ℤ/nℤ -/
def idemCount (n : ℕ) [NeZero n] : ℕ := (idemSet n).card




/-- [Section: # CatalogBuild.Physics.ArchitectureOfReality.IdempotentCounting
Auto-generated from theorem catalog database.
Domain: Physics/ArchitectureOfReality
Declarations: 28] -/
theorem idem_count_1 : idemCount 1 = 1 := by native_decide



/-- [Section: # CatalogBuild.Physics.ArchitectureOfReality.IdempotentCounting
Auto-generated from theorem catalog database.
Domain: Physics/ArchitectureOfReality
Declarations: 28] -/
theorem idem_count_2 : idemCount 2 = 2 := by native_decide



theorem idem_count_3 : idemCount 3 = 2 := by native_decide



theorem idem_count_4 : idemCount 4 = 2 := by native_decide



theorem idem_count_5 : idemCount 5 = 2 := by native_decide



theorem idem_count_6 : idemCount 6 = 4 := by native_decide



theorem idem_count_7 : idemCount 7 = 2 := by native_decide



theorem idem_count_8 : idemCount 8 = 2 := by native_decide



theorem idem_count_9 : idemCount 9 = 2 := by native_decide



theorem idem_count_10 : idemCount 10 = 4 := by native_decide



theorem idem_count_12 : idemCount 12 = 4 := by native_decide



theorem idem_count_15 : idemCount 15 = 4 := by native_decide



theorem idem_count_30 : idemCount 30 = 8 := by native_decide



theorem idem_count_42 : idemCount 42 = 8 := by native_decide



theorem idem_count_105 : idemCount 105 = 8 := by native_decide



theorem idem_count_210 : idemCount 210 = 16 := by native_decide




/-- In a commutative ring, the product of idempotents is idempotent -/
theorem idem_mul {R : Type*} [CommRing R] {e f : R}
    (he : IsIdem e) (hf : IsIdem f) : IsIdem (e * f) := by
  unfold IsIdem at *
  rw [mul_mul_mul_comm, he, hf]




/-- The complement of an idempotent is idempotent -/
theorem idem_complement {R : Type*} [Ring R] {e : R} (he : IsIdem e) :
    IsIdem (1 - e) := by
  unfold IsIdem at *
  have h1 : (1 - e) * e = 0 := by rw [sub_mul, one_mul, he, sub_self]
  calc (1 - e) * (1 - e) = (1 - e) * 1 - (1 - e) * e := by rw [mul_sub]
    _ = (1 - e) - 0 := by rw [mul_one, h1]
    _ = 1 - e := by rw [sub_zero]




/-- 0 is always idempotent -/
theorem idem_zero {R : Type*} [MulZeroClass R] : IsIdem (0 : R) :=
  mul_zero 0




/-- 1 is always idempotent -/
theorem idem_one {R : Type*} [MulOneClass R] : IsIdem (1 : R) :=
  one_mul 1




/-- An idempotent and its complement are orthogonal -/
theorem idem_orthogonal {R : Type*} [Ring R] {e : R} (he : IsIdem e) :
    e * (1 - e) = 0 := by
  unfold IsIdem at he
  rw [mul_sub, mul_one, he, sub_self]




/-- Gaussian binomial coefficient [n choose k]_q -/
def gaussBinom : ℕ → ℕ → ℕ → ℕ
  | _, 0, _ => 1
  | 0, _ + 1, _ => 0
  | n + 1, k + 1, q => q^(k+1) * gaussBinom n k q + gaussBinom n (k+1) q




/-- At q=1, Gaussian binomials recover ordinary binomial coefficients -/
theorem gaussBinom_at_one (n k : ℕ) : gaussBinom n k 1 = n.choose k := by
  induction n generalizing k with
  | zero => cases k <;> simp [gaussBinom, Nat.choose]
  | succ n ih =>
    cases k with
    | zero => simp [gaussBinom, Nat.choose]
    | succ k =>
      simp only [gaussBinom, Nat.choose, one_pow, one_mul]
      rw [ih k, ih (k + 1)]




/-- Total idempotent-analog count for matrix rings: Σ [n choose k]_q -/
def totalProjections (n q : ℕ) : ℕ :=
  ∑ r ∈ Finset.range (n + 1), gaussBinom n r q




/-- At q=1: total projections = 2^n -/
theorem totalProjections_one (n : ℕ) : totalProjections n 1 = 2^n := by
  simp only [totalProjections, gaussBinom_at_one]
  exact Nat.sum_range_choose n




theorem boolean_ring_comm {R : Type*} [Ring R]
    (h : ∀ x : R, x * x = x) (a b : R) : a * b = b * a := by
  -- From (a+b)² = a+b and expanding: a*a + a*b + b*a + b*b = a+b, so a + a*b + b*a + b = a+b, giving a*b + b*a = 0.
  have h_ab : a * b + b * a = 0 := by
    have h_expand : (a + b) * (a + b) = a * a + a * b + b * a + b * b := by
      grobner;
    grind;
  -- By multiplying both sides of $a * b + b * a = 0$ by $a$, we get $a * a * b + a * b * a = 0$, which simplifies to $a * b + a * b * a = 0$.
  have h_mul_a : a * b + a * b * a = 0 := by
    convert congr_arg ( fun x => a * x ) h_ab using 1 <;> simp +decide [ mul_add, add_mul, mul_assoc ];
    rw [ ← mul_assoc, h ];
  simp_all +decide [ mul_assoc, add_eq_zero_iff_eq_neg ]




end
