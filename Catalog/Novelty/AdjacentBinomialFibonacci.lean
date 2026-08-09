/-
# Singmaster's Fibonacci family of adjacent repetitions is complete

`Combinatorics.SingmasterFibonacci` produces the classical infinite family of adjacent
repetitions in Pascal's triangle,

`C(F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5}) = C(F_{2i+4}F_{2i+5} - 1, F_{2i+2}F_{2i+5} + 1)`,

and `Catalog.Novelty.AdjacentBinomialLucas` classifies *all* adjacent repetitions in
terms of consecutive Lucas numbers.  This file identifies the two descriptions and
concludes that the Fibonacci family is **exhaustive**: there are no other adjacent
repetitions at all.

## The bridge

The link between the Lucas parametrisation and the Fibonacci parametrisation is the pair
of identities

* `L_{2a+1} = 5 F_a F_{a+1} + (-1)^a`  (`luc_two_mul_add_one`),
* `L_{2a}   = 5 F_a² + 2(-1)^a`        (`luc_two_mul`),

proved by a single simultaneous induction whose inductive step is exactly **Cassini's
identity** `F_{a+1}² - F_a F_{a+2} = (-1)^a` (`fib_cassini`).  Feeding `a = 2i+4` into
them turns the Lucas classification into the Fibonacci one.

## Results

* `fib_cassini` — Cassini's identity over `ℤ`;
* `luc_two_mul`, `luc_two_mul_add_one` — the Lucas ↔ Fibonacci dictionary;
* `luc_famRow`, `luc_famGap` — the two identities specialised to the Singmaster family;
* `adjacent_iff_fib` — **completeness**: for `1 ≤ k` and `k + 2 ≤ n`,
  `C(n,k) = C(n-1,k+1)` holds *iff* `(n,k) = (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5})` for
  some `i`.  In particular the only adjacent repetitions are
  `(15,5), (104,39), (714,272), (4895,1869), …`.
-/
import Mathlib
import Combinatorics.SingmasterFibonacci
import Novelty.AdjacentBinomialLucas

open Finset

namespace Catalog.Novelty.AdjacentBinomialFib

open Singmaster Catalog.Novelty.AdjacentBinomial

/-! ## Cassini's identity -/

/-- **Cassini's identity** `F_{a+1}² - F_a F_{a+2} = (-1)^a`, over `ℤ`. -/
theorem fib_cassini (a : ℕ) :
    ((Nat.fib (a + 1) : ℤ)) ^ 2 - (Nat.fib a) * (Nat.fib (a + 2)) = (-1) ^ a := by
  induction a with
  | zero => norm_num
  | succ b ih =>
    have h1 : Nat.fib (b + 3) = Nat.fib (b + 1) + Nat.fib (b + 2) :=
      Nat.fib_add_two (n := b + 1)
    have h2 : Nat.fib (b + 2) = Nat.fib b + Nat.fib (b + 1) := Nat.fib_add_two (n := b)
    push_cast [h1, h2]
    push_cast [h2] at ih
    ring_nf
    ring_nf at ih
    linarith [ih, pow_succ (-1 : ℤ) b]

/-! ## The Lucas ↔ Fibonacci dictionary -/

/-- `L_{2a} = 5 F_a² + 2(-1)^a` and `L_{2a+1} = 5 F_a F_{a+1} + (-1)^a`, proved
simultaneously; the inductive step is Cassini's identity. -/
theorem luc_two_mul_and_succ (a : ℕ) :
    ((luc (2 * a) : ℤ) = 5 * (Nat.fib a) ^ 2 + 2 * (-1) ^ a) ∧
      ((luc (2 * a + 1) : ℤ) = 5 * (Nat.fib a) * (Nat.fib (a + 1)) + (-1) ^ a) := by
  induction a with
  | zero => constructor <;> norm_num
  | succ b ih =>
    obtain ⟨ihe, iho⟩ := ih
    have hcass := fib_cassini b
    have hf : Nat.fib (b + 2) = Nat.fib b + Nat.fib (b + 1) := Nat.fib_add_two (n := b)
    have e1 : luc (2 * b + 2) = luc (2 * b) + luc (2 * b + 1) := luc_add_two (2 * b)
    have e2 : luc (2 * b + 3) = luc (2 * b + 1) + luc (2 * b + 2) := luc_add_two (2 * b + 1)
    have hpow : ((-1 : ℤ)) ^ (b + 1) = -(-1) ^ b := by rw [pow_succ]; ring
    constructor
    · have hidx : 2 * (b + 1) = 2 * b + 2 := by ring
      rw [hidx]
      have : ((luc (2 * b + 2) : ℤ)) = (luc (2 * b) : ℤ) + (luc (2 * b + 1) : ℤ) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) e1
      rw [this, ihe, iho, hpow]
      nlinarith [hcass]
    · have hidx : 2 * (b + 1) + 1 = 2 * b + 3 := by ring
      rw [hidx]
      have h3 : ((luc (2 * b + 3) : ℤ)) = (luc (2 * b + 1) : ℤ) + (luc (2 * b + 2) : ℤ) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) e2
      have h2 : ((luc (2 * b + 2) : ℤ)) = (luc (2 * b) : ℤ) + (luc (2 * b + 1) : ℤ) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) e1
      rw [h3, h2, ihe, iho, hpow]
      push_cast [hf]
      nlinarith [hcass]

theorem luc_two_mul (a : ℕ) : ((luc (2 * a) : ℤ)) = 5 * (Nat.fib a) ^ 2 + 2 * (-1) ^ a :=
  (luc_two_mul_and_succ a).1

theorem luc_two_mul_add_one (a : ℕ) :
    ((luc (2 * a + 1) : ℤ)) = 5 * (Nat.fib a) * (Nat.fib (a + 1)) + (-1) ^ a :=
  (luc_two_mul_and_succ a).2

/-! ## The Singmaster family in Lucas coordinates -/

/-- `5 · F_{2i+4}F_{2i+5} + 1 = L_{4i+9}`. -/
theorem luc_famRow (i : ℕ) : 5 * famRow i + 1 = luc (4 * i + 9) := by
  have h := luc_two_mul_add_one (2 * i + 4)
  have hidx : 2 * (2 * i + 4) + 1 = 4 * i + 9 := by ring
  rw [hidx] at h
  have hsign : ((-1 : ℤ)) ^ (2 * i + 4) = 1 := by
    rw [show 2 * i + 4 = 2 * (i + 2) by ring, pow_mul]
    norm_num
  rw [hsign] at h
  have hrow : famRow i = Nat.fib (2 * i + 4) * Nat.fib (2 * i + 5) := rfl
  have : ((5 * famRow i + 1 : ℕ) : ℤ) = ((luc (4 * i + 9) : ℕ) : ℤ) := by
    push_cast [hrow]
    linarith [h]
  exact_mod_cast this

/-- The Fibonacci form of the "gap" `n - k` of the family. -/
theorem famRow_sub_famCol (i : ℕ) :
    famRow i - famCol i = Nat.fib (2 * i + 3) * Nat.fib (2 * i + 5) := by
  have hf : Nat.fib (2 * i + 4) = Nat.fib (2 * i + 2) + Nat.fib (2 * i + 3) :=
    Nat.fib_add_two (n := 2 * i + 2)
  have hrow : famRow i = Nat.fib (2 * i + 4) * Nat.fib (2 * i + 5) := rfl
  have hcol : famCol i = Nat.fib (2 * i + 2) * Nat.fib (2 * i + 5) := rfl
  rw [hrow, hcol, hf, Nat.add_mul]
  omega

/-- `5 · (F_{2i+4}F_{2i+5} - F_{2i+2}F_{2i+5}) = L_{4i+8} + 3`. -/
theorem luc_famGap (i : ℕ) : 5 * (famRow i - famCol i) = luc (4 * i + 8) + 3 := by
  have h := luc_two_mul (2 * i + 4)
  have hidx : 2 * (2 * i + 4) = 4 * i + 8 := by ring
  rw [hidx] at h
  have hsign : ((-1 : ℤ)) ^ (2 * i + 4) = 1 := by
    rw [show 2 * i + 4 = 2 * (i + 2) by ring, pow_mul]
    norm_num
  rw [hsign] at h
  -- Cassini at index `2i+3`: `F_{2i+3} F_{2i+5} = F_{2i+4}² + 1`
  have hcass := fib_cassini (2 * i + 3)
  have hsign' : ((-1 : ℤ)) ^ (2 * i + 3) = -1 := by
    rw [show 2 * i + 3 = 2 * (i + 1) + 1 by ring, pow_succ, pow_mul]
    norm_num
  rw [hsign'] at hcass
  have hgap := famRow_sub_famCol i
  have : ((5 * (famRow i - famCol i) : ℕ) : ℤ) = ((luc (4 * i + 8) + 3 : ℕ) : ℤ) := by
    push_cast [hgap]
    rw [show 2 * i + 3 + 1 = 2 * i + 4 by ring, show 2 * i + 3 + 2 = 2 * i + 5 by ring] at hcass
    linarith [h, hcass]
  exact_mod_cast this

/-! ## Completeness of the Fibonacci family -/

theorem famCol_lt_famRow (i : ℕ) : famCol i + 2 ≤ famRow i := by
  have hcol : famCol i = Nat.fib (2 * i + 2) * Nat.fib (2 * i + 5) := rfl
  have hgap := famRow_sub_famCol i
  have h1 : 1 ≤ Nat.fib (2 * i + 3) := Nat.fib_pos.2 (by omega)
  have h5 : 5 ≤ Nat.fib (2 * i + 5) := by
    have := Nat.fib_mono (show 5 ≤ 2 * i + 5 by omega)
    simpa using this
  have hmul : 5 ≤ Nat.fib (2 * i + 3) * Nat.fib (2 * i + 5) :=
    le_trans h5 (Nat.le_mul_of_pos_left _ h1)
  have hle : famCol i ≤ famRow i := by
    have hrow : famRow i = Nat.fib (2 * i + 4) * Nat.fib (2 * i + 5) := rfl
    have hf : Nat.fib (2 * i + 2) ≤ Nat.fib (2 * i + 4) := Nat.fib_mono (by omega)
    rw [hrow, hcol]
    exact Nat.mul_le_mul_right _ hf
  omega

theorem one_le_famCol (i : ℕ) : 1 ≤ famCol i := by
  have hcol : famCol i = Nat.fib (2 * i + 2) * Nat.fib (2 * i + 5) := rfl
  have h1 : 1 ≤ Nat.fib (2 * i + 2) := Nat.fib_pos.2 (by omega)
  have h2 : 1 ≤ Nat.fib (2 * i + 5) := Nat.fib_pos.2 (by omega)
  rw [hcol]
  exact Nat.one_le_iff_ne_zero.2 (by positivity)

/-- **Completeness of Singmaster's Fibonacci family.**  For `1 ≤ k` and `k + 2 ≤ n`, the
value `C(n,k)` repeats one row higher if and only if `(n,k)` is a member of the Fibonacci
family `n = F_{2i+4}F_{2i+5}`, `k = F_{2i+2}F_{2i+5}`.

Together with `Catalog.Novelty.AdjacentBinomial.six_le_mult_of_adjacent` this says: every
"extra pair" of occurrences produced by an adjacent repetition — the mechanism behind the
numbers occurring at least six times — comes from this single Fibonacci family. -/
theorem adjacent_iff_fib {n k : ℕ} (hk : 1 ≤ k) (hn : k + 2 ≤ n) :
    n.choose k = (n - 1).choose (k + 1) ↔ ∃ i : ℕ, n = famRow i ∧ k = famCol i := by
  rw [adjacent_iff_luc hk hn]
  constructor
  · rintro ⟨j, h1, h2⟩
    have hrow := luc_famRow j
    have hgap := luc_famGap j
    have hcol := famCol_lt_famRow j
    exact ⟨j, by omega, by omega⟩
  · rintro ⟨i, rfl, rfl⟩
    exact ⟨i, luc_famRow i, luc_famGap i⟩

/-- The smallest member of the (now complete) list of adjacent repetitions, obtained from
the classification rather than by computation: `C(15,5) = C(14,6) = 3003`. -/
theorem adjacent_fifteen_five : (15 : ℕ).choose 5 = (15 - 1).choose (5 + 1) := by
  have hrow : famRow 0 = 15 := by decide
  have hcol : famCol 0 = 5 := by decide
  exact (adjacent_iff_fib (n := 15) (k := 5) (by norm_num) (by norm_num)).2
    ⟨0, hrow.symm, hcol.symm⟩

end Catalog.Novelty.AdjacentBinomialFib