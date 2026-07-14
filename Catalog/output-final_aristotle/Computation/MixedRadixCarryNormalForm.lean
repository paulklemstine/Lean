import Mathlib

/-!
# Carry-free additivity and the length-independent normal form for mixed-radix systems

Fix a base sequence `b : ℕ → ℕ`.  A length-`k` mixed-radix numeral is a digit
function `c : ℕ → ℕ` with value

`value b c k = ∑_{i < k} c i · radixProd b i`,   `radixProd b k = ∏_{i<k} b i`,

subject to validity `c i < b i`.  Digits are extracted explicitly by
`digit b n i = (n / radixProd b i) % b i`.

This file is **self-contained**: it re-establishes the core mixed-radix
machinery (running products, value, validity, the value bound, the Euclidean
splitting identities, uniqueness and existence) and then proves two new results
of the mixed-radix program.

## Conjecture 4 — digit extraction is a length-independent normal form

`digit b n i` is defined without reference to any length `k`.  The mathematical
content is that **truncation and extraction commute**:

* `digit_mod_radixProd_succ` : `digit b (n % radixProd b (i+1)) i = digit b n i`.
* `digit_truncation` : for `i < k`, `digit b (n % radixProd b k) i = digit b n i`
  — extending the length `k` never alters an already-computed digit, so the
  infinite digit stream `fun i => digit b n i` is a canonical object.
* `value_digit_mod` : `value b (digit b n) k = n % radixProd b k` (master law).

## Conjecture 2 — carry-free additivity

* `digit_value` : a valid digit function is recovered by extraction.
* `value_add` : evaluation is additive digitwise (always).
* `digit_add_carryFree` : if the local base exceeds the digit sum everywhere
  (`c i + d i < b i`), addition is carry-free — the digits of the sum are exactly
  the pointwise digit sums.
* `not_valid_of_carry` : a position with `b i ≤ c i + d i` is exactly where the
  pointwise sum fails to be a valid digit — the carry.
-/

namespace MixedRadixCarry

open Finset

/-! ## Core mixed-radix machinery (self-contained) -/

/-- The running product of the first `k` bases, `∏_{i<k} b i`. -/
def radixProd (b : Nat → Nat) (k : Nat) : Nat :=
  ∏ i ∈ Finset.range k, b i

/-- The length-`k` mixed-radix value of a digit function `c` under bases `b`. -/
def value (b c : Nat → Nat) (k : Nat) : Nat :=
  ∑ i ∈ Finset.range k, c i * radixProd b i

/-- A digit function is valid up to length `k` if `c i < b i` for all `i < k`. -/
def Valid (b c : Nat → Nat) (k : Nat) : Prop := ∀ i < k, c i < b i

/-- Explicit mixed-radix digit extraction for a natural number `n`. -/
def digit (b : Nat → Nat) (n : Nat) (i : Nat) : Nat := (n / radixProd b i) % (b i)

@[simp] theorem radixProd_zero (b : Nat → Nat) : radixProd b 0 = 1 := by
  simp [radixProd]

theorem radixProd_succ (b : Nat → Nat) (k : Nat) :
    radixProd b (k + 1) = radixProd b k * b k := by
  simp [radixProd, Finset.prod_range_succ]

@[simp] theorem value_zero (b c : Nat → Nat) : value b c 0 = 0 := by
  simp [value]

theorem value_succ (b c : Nat → Nat) (k : Nat) :
    value b c (k + 1) = value b c k + c k * radixProd b k := by
  simp [value, Finset.sum_range_succ]

theorem Valid.of_succ {b c : Nat → Nat} {k : Nat} (h : Valid b c (k + 1)) :
    Valid b c k := fun i hi => h i (Nat.lt_succ_of_lt hi)

theorem radixProd_pos_of_valid {b c : Nat → Nat} {k : Nat} (h : Valid b c (k + 1)) :
    0 < radixProd b k :=
  Finset.prod_pos fun i hi => by
    linarith [h i (by linarith [Finset.mem_range.mp hi])]

theorem value_lt {b c : Nat → Nat} {k : Nat} :
    Valid b c k → value b c k < radixProd b k := by
  induction' k with k ih
  · aesop
  · intro h_valid
    have h_ind : value b c k < radixProd b k :=
      ih fun i hi => h_valid i (Nat.lt_succ_of_lt hi)
    nlinarith! [h_valid k (Nat.lt_succ_self k), value_succ b c k, radixProd_succ b k]

theorem splitting_div {b c : Nat → Nat} {k : Nat} :
    Valid b c (k + 1) → value b c (k + 1) / radixProd b k = c k := by
  intro h
  convert Nat.add_mul_div_right _ _ (radixProd_pos_of_valid h) using 1
  rw [value_succ]
  rw [Nat.div_eq_of_lt (value_lt (Valid.of_succ h)), zero_add]

theorem value_unique {b c d : Nat → Nat} {k : Nat} :
    Valid b c k → Valid b d k → value b c k = value b d k → ∀ i < k, c i = d i := by
  intro hc hd hv
  induction' k with k ih
  · tauto
  · have h_top : c k = d k := by
      rw [← splitting_div hc, ← splitting_div hd, hv]
    have h_tail : value b c k = value b d k := by
      simp_all +decide [value_succ]
    exact fun i hi =>
      if hi' : i = k then hi'.symm ▸ h_top
      else ih (fun i hi => hc i (Nat.lt_succ_of_lt hi))
        (fun i hi => hd i (Nat.lt_succ_of_lt hi)) h_tail i
        (lt_of_le_of_ne (Nat.le_of_lt_succ hi) hi')

theorem value_digit {b : Nat → Nat} {n k : Nat}
    (hn : n < radixProd b k) : value b (digit b n) k = n := by
  have key (m : ℕ) : n = (∑ i ∈ Finset.range m,
      (n / radixProd b i) % (b i) * radixProd b i) +
      (n / radixProd b m) * radixProd b m := by
    induction' m with m ih
    · simp +decide [radixProd]
    · rw [Finset.sum_range_succ, radixProd_succ]
      convert ih using 1
      rw [← Nat.div_add_mod (n / radixProd b m) (b m)]; ring_nf
      norm_num [Nat.div_div_eq_div_mul, mul_assoc, mul_comm, mul_left_comm]
  unfold value digit
  nlinarith [key k, Nat.div_eq_of_lt hn]

/-! ## Conjecture 4: length-independent normal form -/

/-
`radixProd b (i+1)` divides `radixProd b k` whenever `i < k`
(the running products form a divisibility chain).
-/
theorem radixProd_succ_dvd_radixProd {b : Nat → Nat} {i k : Nat} (hik : i < k) :
    radixProd b (i + 1) ∣ radixProd b k := by
  apply_rules [ Finset.prod_dvd_prod_of_subset, Finset.range_subset.mpr ];
  grind

/-
The `i`-th digit of `n` depends only on `n` modulo `radixProd b (i+1)`:
truncating `n` to the first `i+1` place-values does not change digit `i`.
-/
theorem digit_mod_radixProd_succ (b : Nat → Nat) (n i : Nat) :
    digit b (n % radixProd b (i + 1)) i = digit b n i := by
  -- Write `P = radixProd b i` and `B = b i`.
  set P := radixProd b i
  set B := b i

  -- The definition of `digit` is `digit b n i = (n / P) % B`.
  unfold digit;
  cases eq_or_ne B 0 <;> simp_all +decide [ radixProd_succ ];
  · aesop;
  · rw [ Nat.mod_mul ];
    cases h : radixProd b i <;> simp_all +decide [ Nat.add_mul_div_left ]

/-
**Truncation commutes with extraction.** For `i < k`, the `i`-th digit of the
truncation `n % radixProd b k` equals the `i`-th digit of `n`.  Hence lengthening
`k` never alters an already-computed digit, and the infinite digit stream
`fun i => digit b n i` is a well-defined canonical normal form.
-/
theorem digit_truncation {b : Nat → Nat} {i k : Nat} (hik : i < k) (n : Nat) :
    digit b (n % radixProd b k) i = digit b n i := by
  rw [ ← digit_mod_radixProd_succ b ( n % radixProd b k ) i, Nat.mod_mod_of_dvd n ( radixProd_succ_dvd_radixProd hik ), digit_mod_radixProd_succ ]

/-
**Master reconstruction law.** The value of the extracted digit stream, read
to length `k`, is `n` reduced modulo the capacity `radixProd b k`.
-/
theorem value_digit_mod (b : Nat → Nat) (n k : Nat) :
    value b (digit b n) k = n % radixProd b k := by
  -- Let's prove the key identity by induction on `m`.
  have key (m : ℕ) : n = (∑ i ∈ Finset.range m, (n / radixProd b i) % (b i) * radixProd b i) + (n / radixProd b m) * radixProd b m := by
    induction' m with m ih;
    · simp +decide [ radixProd ];
    · rw [ Finset.sum_range_succ, radixProd_succ ];
      convert ih using 1;
      rw [ ← Nat.div_add_mod ( n / radixProd b m ) ( b m ) ] ; ring_nf;
      norm_num [ Nat.div_div_eq_div_mul, mul_assoc, mul_comm, mul_left_comm ];
  rw [ Nat.mod_eq_sub_mul_div ];
  exact eq_tsub_of_add_eq ( by linarith! [ key k, show value b ( digit b n ) k = ∑ i ∈ Finset.range k, ( n / radixProd b i ) % b i * radixProd b i from rfl ] )

/-! ## Conjecture 2: carry-free additivity -/

/-
**Digit recovery (uniqueness of digits).** A valid digit function is
recovered exactly by extraction from the value it denotes.
-/
theorem digit_value {b c : Nat → Nat} {k : Nat} (hc : Valid b c k) {i : Nat}
    (hi : i < k) : digit b (value b c k) i = c i := by
  -- By `value_unique`, the digit stream `digits` is valid up to `k`.
  have h_valid_digits : Valid b (digit b (value b c k)) k := by
    intro i hi; exact Nat.mod_lt _ ( by linarith [ hc i hi ] ) ;
  have := value_unique h_valid_digits hc ?_ i hi;
  · exact this;
  · rw [ value_digit_mod, Nat.mod_eq_of_lt ( value_lt hc ) ]

/-
**Evaluation is additive digitwise** — unconditionally, regardless of any
carry.  This is pure linearity of the place-value sum.
-/
theorem value_add (b c d : Nat → Nat) (k : Nat) :
    value b (fun i => c i + d i) k = value b c k + value b d k := by
  unfold value; simp +decide [ add_mul, Finset.sum_add_distrib ] ;

/-
**Carry-free additivity.** If at every position below `k` the local base
exceeds the sum of the two digits (`c i + d i < b i`), then addition is
carry-free: the `i`-th digit of the sum is exactly the pointwise digit sum
`c i + d i`.
-/
theorem digit_add_carryFree {b c d : Nat → Nat} {k : Nat}
    (hcarry : ∀ i < k, c i + d i < b i) {i : Nat} (hi : i < k) :
    digit b (value b c k + value b d k) i = c i + d i := by
  rw [ ← value_add ];
  exact digit_value ( fun i hi => hcarry i hi ) hi

/-- **Characterization of a carry.** A position `i` where the local base does not
exceed the digit sum (`b i ≤ c i + d i`) is exactly a position where the
pointwise sum fails to be a valid digit — i.e. where a carry is forced. -/
theorem not_valid_of_carry {b c d : Nat → Nat} {i : Nat} (h : b i ≤ c i + d i) :
    ¬ (c i + d i < b i) := not_lt.mpr h

end MixedRadixCarry