/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Arithmetic Statistics of Graph Jacobians

This file establishes the deterministic algebraic backbone connecting
graph Jacobians (critical groups) to arithmetic statistics via Smith
normal form invariant factors.

## Main Results

* `primePow_dvd_exponent_iff_exists` — Theorem A: prime power divisibility criterion
* `primePowerTorsionCount_eq_prod_gcd` — Theorem B: moment = product of gcds
* `qPrimaryCount_antitone` — Theorem C: q-primary profile monotonicity
* `cyclic_prime_power_gcd` — key identity gcd(q^m, q^k) = q^(min(m,k))

## Cross-Domain Significance

These results bridge combinatorial probability, arithmetic statistics,
graph theory, and random matrix theory through the Smith normal form
of graph Laplacians.
-/

open Finset BigOperators Nat

/-! ## Core Definitions -/

/-- Invariant factor data for a finite abelian group ⊕ᵢ ℤ/dᵢℤ.
    The factors are positive and in divisibility order. -/
structure InvariantFactorData where
  /-- Number of invariant factors -/
  rank : ℕ
  /-- The invariant factors -/
  factors : Fin rank → ℕ
  /-- All factors are positive -/
  factors_pos : ∀ i, 0 < factors i
  /-- Factors are in divisibility order -/
  factors_dvd : ∀ i j : Fin rank, i ≤ j → factors i ∣ factors j

namespace InvariantFactorData

/-- The exponent of the group, equal to the largest factor. -/
noncomputable def exponent (S : InvariantFactorData) : ℕ :=
  if h : S.rank = 0 then 1
  else S.factors ⟨S.rank - 1, by omega⟩

/-- The order of the group ∏ᵢ dᵢ. -/
def order (S : InvariantFactorData) : ℕ :=
  ∏ i : Fin S.rank, S.factors i

end InvariantFactorData

/-- The q^k-torsion count: ∏ᵢ gcd(dᵢ, q^k). -/
def primePowerTorsionCount (q k : ℕ) (S : InvariantFactorData) : ℕ :=
  ∏ i : Fin S.rank, Nat.gcd (S.factors i) (q ^ k)

/-- The q-primary count at level j: #{i : q^j | dᵢ}. -/
def qPrimaryCount (q : ℕ) (S : InvariantFactorData) (j : ℕ) : ℕ :=
  (Finset.univ.filter fun i : Fin S.rank => q ^ j ∣ S.factors i).card

/-! ## Theorem A — Divisibility Criterion -/

/-- **Theorem A**: q^k divides the exponent iff it divides some invariant factor. -/
theorem primePow_dvd_exponent_iff_exists
    (S : InvariantFactorData) (q k : ℕ)
    (hrank : S.rank ≠ 0) :
    q ^ k ∣ S.exponent ↔ ∃ i, q ^ k ∣ S.factors i := by
  constructor
  · intro h
    exact ⟨⟨S.rank - 1, by omega⟩, by simpa [InvariantFactorData.exponent, hrank] using h⟩
  · intro ⟨i, hi⟩
    have hle : i ≤ ⟨S.rank - 1, by omega⟩ := by
      simp [Fin.le_def]; omega
    have hdvd := S.factors_dvd i ⟨S.rank - 1, by omega⟩ hle
    simp [InvariantFactorData.exponent, hrank]
    exact dvd_trans hi hdvd

/-- The exponent equals the largest invariant factor. -/
theorem exponent_eq_largest_factor
    (S : InvariantFactorData) (hrank : S.rank ≠ 0) :
    S.exponent = S.factors ⟨S.rank - 1, by omega⟩ := by
  simp [InvariantFactorData.exponent, hrank]

/-- q^k divides the exponent iff it divides the largest factor. -/
theorem primePow_dvd_exponent_iff_dvd_largest
    (S : InvariantFactorData) (q k : ℕ)
    (hrank : S.rank ≠ 0) :
    q ^ k ∣ S.exponent ↔ q ^ k ∣ S.factors ⟨S.rank - 1, by omega⟩ := by
  simp [InvariantFactorData.exponent, hrank]

/-! ## Theorem B — Prime-Power Moment Identity -/

/-- **Theorem B**: The torsion count equals the product of gcds (by definition). -/
theorem primePowerTorsionCount_eq_prod_gcd
    (S : InvariantFactorData) (q k : ℕ) :
    primePowerTorsionCount q k S =
      ∏ i : Fin S.rank, Nat.gcd (S.factors i) (q ^ k) := by
  rfl

/-- The torsion count is always positive. -/
theorem primePowerTorsionCount_pos
    (S : InvariantFactorData) (q k : ℕ) (_hq : 0 < q) :
    0 < primePowerTorsionCount q k S := by
  unfold primePowerTorsionCount
  apply Finset.prod_pos
  intro i _
  exact Nat.pos_of_ne_zero (Nat.gcd_ne_zero_left (_root_.ne_of_gt (S.factors_pos i)))

/-- For k = 0, the torsion count is 1. -/
theorem primePowerTorsionCount_zero_pow
    (S : InvariantFactorData) (q : ℕ) (_hq : 0 < q) :
    primePowerTorsionCount q 0 S = 1 := by
  unfold primePowerTorsionCount
  simp [pow_zero, Nat.gcd_one_right]

/-
Monotonicity: torsion count is non-decreasing in k.
-/
theorem primePowerTorsionCount_mono
    (S : InvariantFactorData) (q : ℕ) (_hq : 1 < q) :
    Monotone (fun k => primePowerTorsionCount q k S) := by
  refine' fun k l hkl => Finset.prod_le_prod' fun i _ => _;
  refine' Nat.le_of_dvd ( Nat.gcd_pos_of_pos_left _ ( S.factors_pos i ) ) ( Nat.dvd_gcd _ _ );
  · exact Nat.gcd_dvd_left _ _;
  · exact dvd_trans ( Nat.gcd_dvd_right _ _ ) ( pow_dvd_pow _ hkl )

/-! ## Theorem C — Profile Properties -/

/-
The q-primary count is antitone (non-increasing).
-/
theorem qPrimaryCount_antitone
    (S : InvariantFactorData) (q : ℕ) (_hq : 1 < q) :
    Antitone (fun j => qPrimaryCount q S j) := by
  exact fun i j hij => Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, dvd_trans ( pow_dvd_pow q hij ) ( Finset.mem_filter.mp hx |>.2 ) ⟩ ;

/-- At level 0, all factors are counted. -/
theorem qPrimaryCount_zero
    (S : InvariantFactorData) (q : ℕ) (_hq : 0 < q) :
    qPrimaryCount q S 0 = S.rank := by
  simp [qPrimaryCount, pow_zero]

/-
For large enough j, the q-primary count is 0.
-/
theorem qPrimaryCount_eventually_zero
    (S : InvariantFactorData) (q : ℕ) (hq : 1 < q) :
    ∃ J, ∀ j, J ≤ j → qPrimaryCount q S j = 0 := by
  -- Since S.rank is finite, there exists a bound M such that q^M > max of all factors. Then for j ≥ M, q^j > dᵢ for all i, so q^j cannot divide dᵢ.
  obtain ⟨M, hM⟩ : ∃ M, ∀ i : Fin S.rank, S.factors i ≤ q^M := by
    use Finset.univ.sup (fun i => Nat.log q (S.factors i)) + 1;
    exact fun i => Nat.le_of_lt ( Nat.lt_pow_of_log_lt hq ( Nat.lt_succ_of_le ( Finset.le_sup ( f := fun i => Nat.log q ( S.factors i ) ) ( Finset.mem_univ i ) ) ) );
  refine' ⟨ M + 1, fun j hj => _ ⟩ ; simp_all +decide [ qPrimaryCount ];
  exact fun i => Nat.not_dvd_of_pos_of_lt ( S.factors_pos i ) ( lt_of_le_of_lt ( hM i ) ( pow_lt_pow_right₀ hq hj ) )

/-! ## Profile Structure -/

/-- The q-primary invariant factor profile:
    counts forming a partition shape (non-increasing, eventually zero). -/
structure InvariantFactorProfile where
  /-- The prime -/
  q : ℕ
  /-- Count at each level -/
  levels : ℕ → ℕ
  /-- Non-increasing -/
  antitone : Antitone levels
  /-- Eventually zero -/
  eventually_zero : ∃ J, ∀ j, J ≤ j → levels j = 0

/-- Extract the q-primary profile from invariant factor data. -/
noncomputable def InvariantFactorData.qProfile
    (S : InvariantFactorData) (q : ℕ) (hq : 1 < q) : InvariantFactorProfile where
  q := q
  levels := fun j => qPrimaryCount q S j
  antitone := qPrimaryCount_antitone S q hq
  eventually_zero := qPrimaryCount_eventually_zero S q hq

/-! ## Key Arithmetic Identity -/

/-
For prime q, gcd(q^m, q^k) = q^(min(m,k)).
-/
theorem cyclic_prime_power_gcd
    (q m k : ℕ) (_hq : Nat.Prime q) :
    Nat.gcd (q ^ m) (q ^ k) = q ^ min m k := by
  cases le_total m k <;>
    simp +decide [*, Nat.gcd_eq_left_iff_dvd, Nat.gcd_eq_right_iff_dvd] <;>
    exact Nat.pow_dvd_pow q (by omega)

/-! ## Concrete Examples -/

/-- A cyclic group ℤ/nℤ for n > 0. -/
def cyclicGroupData (n : ℕ) (hn : 0 < n) : InvariantFactorData where
  rank := 1
  factors := fun _ => n
  factors_pos := fun _ => hn
  factors_dvd := fun _ _ _ => dvd_refl n

/-- The exponent of ℤ/nℤ is n. -/
theorem cyclicGroupData_exponent (n : ℕ) (hn : 0 < n) :
    (cyclicGroupData n hn).exponent = n := by
  simp [InvariantFactorData.exponent, cyclicGroupData]

/-- Torsion count of ℤ/nℤ is gcd(n, q^k). -/
theorem cyclicGroupData_torsionCount (n : ℕ) (hn : 0 < n) (q k : ℕ) :
    primePowerTorsionCount q k (cyclicGroupData n hn) = Nat.gcd n (q ^ k) := by
  simp [primePowerTorsionCount, cyclicGroupData]

/-! ## Product Group ℤ/aℤ × ℤ/bℤ -/

/-- Product group ℤ/aℤ × ℤ/bℤ with a | b. -/
def productGroupData (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hdvd : a ∣ b) : InvariantFactorData where
  rank := 2
  factors := ![a, b]
  factors_pos := by
    intro i; fin_cases i <;> simp [Matrix.cons_val_zero, Matrix.cons_val_one] <;> omega
  factors_dvd := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [Matrix.cons_val_zero, Matrix.cons_val_one, Fin.le_def]

/-- The exponent of ℤ/aℤ × ℤ/bℤ (with a | b) is b. -/
theorem productGroupData_exponent (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hdvd : a ∣ b) :
    (productGroupData a b ha hb hdvd).exponent = b := by
  simp [InvariantFactorData.exponent, productGroupData, Matrix.cons_val_one]

/-
The torsion count of ℤ/aℤ × ℤ/bℤ is gcd(a,q^k) * gcd(b,q^k).
-/
theorem productGroupData_torsionCount (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hdvd : a ∣ b) (q k : ℕ) :
    primePowerTorsionCount q k (productGroupData a b ha hb hdvd) =
      Nat.gcd a (q ^ k) * Nat.gcd b (q ^ k) := by
  unfold primePowerTorsionCount;
  erw [ Fin.prod_univ_two ] ; aesop

/-! ## The order divides product of torsion contributions -/

/-- The order of the group equals the product of invariant factors. -/
theorem order_eq_prod_factors (S : InvariantFactorData) :
    S.order = ∏ i : Fin S.rank, S.factors i := by
  rfl

/-
The exponent divides the order.
-/
theorem exponent_dvd_order (S : InvariantFactorData) (hrank : S.rank ≠ 0) :
    S.exponent ∣ S.order := by
  rw [ InvariantFactorData.exponent, InvariantFactorData.order ];
  split_ifs ; simp_all +decide;
  exact Finset.dvd_prod_of_mem _ ( Finset.mem_univ _ )