import Catalog.NumberTheory.RecursiveMixedRadix

/-!
# Tower-base representations

At position `k` the radix is `2^(towerWeight k)`.  Thus the alphabet itself grows
recursively.  This gives very few *digit positions*, but each high-position digit
comes from an enormous alphabet; the final theorem records the corresponding
bit-cost bound and prevents interpreting position count alone as compression.
-/

namespace TowerBaseRepresentation

open RecursiveMixedRadix

/-- Recursive place values for the tower-base system. -/
def towerWeight : ℕ → ℕ
  | 0 => 1
  | k + 1 => 2 ^ towerWeight k * towerWeight k

/-- The radix available at position `k`. -/
def towerRadix (k : ℕ) : ℕ := 2 ^ towerWeight k

/-- The abstract mixed-radix weights coincide with the explicit recursive weights. -/
theorem weight_eq_towerWeight (k : ℕ) :
    weight towerRadix k = towerWeight k := by
  induction k with
  | zero => rfl
  | succ k ih => simp [weight_succ, towerWeight, towerRadix, ih]

/-- Every tower radix is positive (indeed, at least two). -/
theorem towerRadix_pos (k : ℕ) : 0 < towerRadix k := by
  exact pow_pos (by decide : (0 : ℕ) < 2) (towerWeight k)

/-- Tower place values strictly increase. -/
theorem towerWeight_strictMono : StrictMono towerWeight := by
  apply strictMono_nat_of_lt_succ
  intro k
  show towerWeight k < towerWeight (k + 1)
  simp [towerWeight]
  have hpos : 0 < towerWeight k := by
    induction k with
    | zero => simp [towerWeight]
    | succ m ih => simp [towerWeight, ih, pow_pos]
  have h2 : 1 < 2 ^ towerWeight k := by
    exact one_lt_pow₀ (by norm_num : 1 < 2) (by omega)
  calc towerWeight k = 1 * towerWeight k := by ring
    _ < 2 ^ towerWeight k * towerWeight k := Nat.mul_lt_mul_of_pos_right h2 hpos

/-- In particular, the `k`th place value exceeds `k`. -/
theorem index_lt_towerWeight (k : ℕ) : k < towerWeight k := by
  induction k with
  | zero => simp [towerWeight]
  | succ k ih =>
    have hgrow : towerWeight k < towerWeight (k + 1) :=
      towerWeight_strictMono (Nat.lt_succ_self k)
    omega

/-- Canonical tower-base digits. -/
def digit (n i : ℕ) : ℕ := RecursiveMixedRadix.digit towerRadix n i

/-- Value of a finite tower-base digit string. -/
def value (c : ℕ → ℕ) (k : ℕ) : ℕ :=
  RecursiveMixedRadix.value towerRadix c k

/-- Validity of a finite tower-base digit string. -/
def Valid (c : ℕ → ℕ) (k : ℕ) : Prop :=
  RecursiveMixedRadix.Valid towerRadix c k

/-- Every natural has a canonical tower-base representation, already at length `n+1`. -/
theorem exists_representation (n : ℕ) :
    Valid (digit n) (n + 1) ∧ value (digit n) (n + 1) = n := by
  constructor
  · exact RecursiveMixedRadix.digit_valid towerRadix_pos n (n + 1)
  · apply RecursiveMixedRadix.value_digit
    rw [weight_eq_towerWeight]
    exact lt_trans (index_lt_towerWeight n)
      (towerWeight_strictMono (Nat.lt_succ_self n))

/-- Valid tower-base representations of a fixed length are unique. -/
theorem representation_unique {c d : ℕ → ℕ} {k : ℕ}
    (hc : Valid c k) (hd : Valid d k) (hval : value c k = value d k) :
    ∀ i < k, c i = d i := by
  exact RecursiveMixedRadix.value_unique (fun i => towerRadix_pos i) hc hd hval

/-- The local alphabet has exactly the power-of-two bound that its definition
advertises.  Consequently a digit at position `i` can require up to
`towerWeight i` binary bits; low position count alone is not a bit-compression
result. -/
theorem digit_bit_cost_bound (n i : ℕ) :
    digit n i < 2 ^ towerWeight i := by
  exact Nat.mod_lt _ (towerRadix_pos i)

end TowerBaseRepresentation