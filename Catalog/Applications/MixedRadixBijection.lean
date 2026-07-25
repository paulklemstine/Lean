import Catalog.Computation.MixedRadixNumberSystem
import Catalog.Computation.FactorialNumberSystem

/-!
# The mixed-radix bijection and its concrete instances

Building on `Catalog/Computation/MixedRadixNumberSystem.lean`, this file packages
the uniqueness (`MixedRadix.value_unique`) and existence (`MixedRadix.value_digit`)
results into a single **bijection** (`Equiv`)

`Fin (radixProd b k) ≃ (∀ i : Fin k, Fin (b i))`

between the natural numbers below the running product `∏_{i<k} b i` and the
dependent tuples of valid digits.  This is the structural heart of every
positional numeral system: it says that "reading digits" and "evaluating a
numeral" are mutually inverse.

Two classical corollaries fall out by specialization:

* **Base-`N` numerals** (`b i = N`): every `n < N^k` has a *unique* string of
  `k` base-`N` digits (`baseN_value_unique`, `baseN_value_digit`,
  `equivFinBaseN`), the standard uniqueness/existence of positional notation.
* **Factoradics** (`b i = i + 1`): every `n < k!` has a unique factoradic
  representation, and there are exactly `k!` valid length-`k` factoradic tuples
  (`equivFinFactorial`, `card_factorial_tuples`).

The counting corollary `card_valid_tuples : Fintype.card (∀ i : Fin k, Fin (b i))
= radixProd b k` re-expresses `∏_{i<k} b i` as the number of valid digit tuples
— a purely combinatorial reading of the running product.

Everything here is derived *only* from the general mixed-radix theory; no result
below is used in the proof of the general uniqueness theorem, so there is no
circularity.
-/

namespace MixedRadix

open Finset

/-! ## Positivity of bases inside a positive running product -/

/-
If the running product `∏_{i<k} b i` is positive, then every individual base
`b i` with `i < k` is positive.
-/
theorem base_pos_of_radixProd_pos {b : Nat → Nat} {k : Nat}
    (h : 0 < radixProd b k) {i : Nat} (hi : i < k) : 0 < b i := by
      exact Nat.pos_of_ne_zero fun hi' => h.ne' <| Finset.prod_eq_zero ( Finset.mem_range.mpr hi ) hi'

/-! ## Extending a finite digit tuple to a total digit function -/

/-- Extend a `Fin k`-indexed tuple of valid digits to a total digit function
(padding with `0` outside the range). -/
def ofTuple {b : Nat → Nat} {k : Nat} (c : ∀ i : Fin k, Fin (b i)) : Nat → Nat :=
  fun i => if h : i < k then (c ⟨i, h⟩ : Nat) else 0

/-
The extension of a digit tuple is `Valid`.
-/
theorem ofTuple_valid {b : Nat → Nat} {k : Nat} (c : ∀ i : Fin k, Fin (b i)) :
    Valid b (ofTuple c) k := by
      intro i hi; unfold ofTuple; aesop;

/-
The `value` of an extended tuple is below the running product (a valid numeral).
-/
theorem value_ofTuple {b : Nat → Nat} {k : Nat} (c : ∀ i : Fin k, Fin (b i)) :
    value b (ofTuple c) k < radixProd b k := by
      convert MixedRadix.value_lt ( MixedRadix.ofTuple_valid c ) using 1

/-! ## The bijection -/

/-- Forward map of the bijection: read the mixed-radix digits of `n`. -/
def toTuple (b : Nat → Nat) (k : Nat) (n : Fin (radixProd b k)) :
    ∀ i : Fin k, Fin (b i) :=
  fun i => ⟨digit b n.val i, by
    have hpos : 0 < radixProd b k := lt_of_le_of_lt (Nat.zero_le _) n.isLt
    exact Nat.mod_lt _ (base_pos_of_radixProd_pos hpos i.isLt)⟩

/-
On the in-range indices, the padded tuple `ofTuple (toTuple b k n)` agrees
with the explicit digit extraction `digit b n.val`.
-/
theorem ofTuple_toTuple_eq_digit {b : Nat → Nat} {k : Nat}
    (n : Fin (radixProd b k)) {i : Nat} (hi : i < k) :
    ofTuple (toTuple b k n) i = digit b n.val i := by
      unfold ofTuple; aesop;

/-
**Left inverse**: reading the digits of `n` and re-evaluating returns `n`.
-/
theorem value_ofTuple_toTuple {b : Nat → Nat} {k : Nat} (n : Fin (radixProd b k)) :
    value b (ofTuple (toTuple b k n)) k = n.val := by
      convert value_digit n.isLt using 1;
      exact Finset.sum_congr rfl fun i hi => by rw [ ofTuple_toTuple_eq_digit n ( Finset.mem_range.mp hi ) ] ;

/-
**Right inverse**: evaluating a tuple then reading back its digits returns
the original tuple.
-/
theorem toTuple_value_ofTuple {b : Nat → Nat} {k : Nat} (c : ∀ i : Fin k, Fin (b i)) :
    toTuple b k ⟨value b (ofTuple c) k, value_ofTuple c⟩ = c := by
      -- Unfold the definitions of `toTuple` and `ofTuple`, and rewrite the digit-extraction `toTuple` using the `ofTuple_toTuple_eq_digit` lemma.
      -- This reduces the goal to showing that `digit b n j = (c j).val` for all `j < k`.
      ext i;
      simp [toTuple];
      convert value_unique _ _ _ i.val i.isLt using 1;
      rotate_left;
      exact b;
      exact fun i => if h : i < k then ( c ⟨ i, h ⟩ : ℕ ) else 0;
      · exact fun i hi => Nat.mod_lt _ ( base_pos_of_radixProd_pos ( by linarith [ MixedRadix.value_ofTuple c ] ) hi );
      · exact fun i hi => by aesop;
      · convert value_digit _;
        exact MixedRadix.value_lt ( MixedRadix.ofTuple_valid c );
      · aesop

/-- **The mixed-radix bijection.**  Natural numbers below `∏_{i<k} b i` are in
bijection with tuples of valid digits.  The forward map reads off digits; the
inverse map evaluates the numeral. -/
def equivFinPi (b : Nat → Nat) (k : Nat) :
    Fin (radixProd b k) ≃ (∀ i : Fin k, Fin (b i)) where
  toFun := toTuple b k
  invFun c := ⟨value b (ofTuple c) k, value_ofTuple c⟩
  left_inv n := Fin.ext (value_ofTuple_toTuple n)
  right_inv c := toTuple_value_ofTuple c

/-- **Counting corollary.**  The running product `∏_{i<k} b i` equals the number
of valid length-`k` digit tuples. -/
theorem card_valid_tuples (b : Nat → Nat) (k : Nat) :
    Fintype.card (∀ i : Fin k, Fin (b i)) = radixProd b k :=
  (Fintype.card_congr (equivFinPi b k).symm).trans (Fintype.card_fin _)

/-! ## Base-`N` numerals as a corollary -/

/-- **Uniqueness of base-`N` numerals.**  If two digit strings, each with digits
`< N`, have the same base-`N` value over `k` places, they are equal digit-by-digit. -/
theorem baseN_value_unique {N : Nat} {c d : Nat → Nat} {k : Nat}
    (hc : ∀ i < k, c i < N) (hd : ∀ i < k, d i < N)
    (hv : value (fun _ => N) c k = value (fun _ => N) d k) :
    ∀ i < k, c i = d i :=
  MixedRadix.value_unique hc hd hv

/-- **Existence of base-`N` numerals.**  Every `n < N^k` is the base-`N` value of
its own extracted digits. -/
theorem baseN_value_digit {N n k : Nat} (hn : n < N ^ k) :
    value (fun _ => N) (digit (fun _ => N) n) k = n :=
  MixedRadix.value_digit (by rw [baseN_radixProd]; exact hn)

/-- The base-`N` instance of the mixed-radix bijection:
`Fin (N^k) ≃ (Fin k → Fin N)`. -/
def equivFinBaseN (N k : Nat) : Fin (N ^ k) ≃ (Fin k → Fin N) :=
  (finCongr (baseN_radixProd N k).symm).trans (equivFinPi (fun _ => N) k)

/-! ## Factoradics as a corollary -/

/-- The factoradic instance of the mixed-radix bijection:
`Fin (k!) ≃ (∀ i : Fin k, Fin (i+1))`. -/
def equivFinFactorial (k : Nat) :
    Fin (k.factorial) ≃ (∀ i : Fin k, Fin (i.val + 1)) :=
  (finCongr (factorial_radixProd k).symm).trans (equivFinPi (fun i => i + 1) k)

/-- There are exactly `k!` valid length-`k` factoradic digit tuples. -/
theorem card_factorial_tuples (k : Nat) :
    Fintype.card (∀ i : Fin k, Fin (i.val + 1)) = k.factorial :=
  (card_valid_tuples (fun i => i + 1) k).trans (factorial_radixProd k)

end MixedRadix