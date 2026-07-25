import Mathlib

/-!
# Local arithmetic framework for the sequence `n² + 1`

This file formalizes the *local* (i.e. congruence-theoretic) arithmetic ingredients
underlying the study of the sequence `n² + 1`.  These are the elementary,
unconditional foundation stones that any sieve-theoretic or heuristic analysis of
`n² + 1` rests upon.  Everything here is proven from Mathlib's existing
formalization of quadratic reciprocity / Legendre symbols; there are no circular
dependencies on conjectural sieve machinery.

## Main results

* `NSquaredPlusOneLocal.solvable_iff`: for a prime `p`, the congruence
  `x² + 1 ≡ 0 (mod p)` is solvable iff `p ≢ 3 (mod 4)`.  (This is the statement
  that `-1` is a quadratic residue mod `p` iff `p ≢ 3 (mod 4)`.)

* `NSquaredPlusOneLocal.card_solSet_of_ne` / `card_solSet_of_three`: the congruence
  has **exactly 2** solutions in `ZMod p` when `p` is an odd prime with
  `p ≢ 3 (mod 4)`, and **0** solutions when `p ≡ 3 (mod 4)`.

* `NSquaredPlusOneLocal.legendre_neg_one_eq_one_iff`: the connection to Mathlib's
  Legendre symbol, `legendreSym p (-1) = 1 ↔ p ≡ 1 (mod 4)`.

* `NSquaredPlusOneLocal.not_dvd_of_three_mod_four`: **no** prime `p ≡ 3 (mod 4)`
  ever divides `n² + 1`.  This is the elementary reason that the local densities
  vanish at primes `≡ 3 (mod 4)`.

* `NSquaredPlusOneLocal.count_with_bad_prime_factor_eq_zero`: consequently, the
  number of `n < X` for which `n² + 1` has a prime factor `≡ 3 (mod 4)` is exactly
  `0`.  (Part 3 of the task: the elementary truth that makes the proportion `0`,
  controlled by the Legendre-symbol obstruction above, with no analytic input
  needed.)

* `NSquaredPlusOneLocal.nu`: the local density factor
  `ν_p(n) = #{x (mod p) : x² + 1 ≡ 0 (mod p), gcd(x, n) = 1}`, with its basic
  bounds `nu_le_two`, and its vanishing `nu_eq_zero_of_three`.

## Note on the singular series and the `C · X / √(log X)` heuristic

The *singular series* `S = ∏_p ν_p / p` and the resulting main term of the shape
`C · X / √(log X)` belong to the conjectural (Bateman–Horn / Landau) heuristic for
`n² + 1`; that asymptotic is **not** an unconditional theorem and is therefore
**not** asserted here.  What *is* unconditional — and is what we formalize — are the
local factors `ν_p / p` (`localFactor`) and their exact values, which are the only
rigorously available ingredients of the singular series.
-/

namespace NSquaredPlusOneLocal

open scoped Classical

/-- The set of solutions of `x² + 1 ≡ 0 (mod p)`, as a `Finset` of `ZMod p`. -/
def solSet (p : ℕ) [NeZero p] : Finset (ZMod p) :=
  Finset.univ.filter (fun x => x ^ 2 + 1 = 0)

@[simp] lemma mem_solSet {p : ℕ} [NeZero p] (x : ZMod p) :
    x ∈ solSet p ↔ x ^ 2 + 1 = 0 := by
  simp [solSet]

/-! ### Part 1: the local solvability criterion -/

/--
**Local solvability criterion.** For a prime `p`, the congruence
`x² + 1 ≡ 0 (mod p)` is solvable iff `p ≢ 3 (mod 4)`.
-/
theorem solvable_iff (p : ℕ) [Fact p.Prime] :
    (∃ x : ZMod p, x ^ 2 + 1 = 0) ↔ p % 4 ≠ 3 := by
  constructor;
  · rintro ⟨ x, hx ⟩ h;
    have := ZMod.exists_sq_eq_neg_one_iff ( p := p );
    exact absurd ( this.mp ⟨ x, by linear_combination' hx.symm ⟩ ) ( by simp +decide [ h ] );
  · intro hp_mod; have := ZMod.exists_sq_eq_neg_one_iff ( p := p ) ; simp_all +decide
    exact Exists.elim this fun x hx => ⟨ x, by rw [ sq, ← hx ] ; ring ⟩

/--
When `p` is an odd prime with `p ≢ 3 (mod 4)`, the congruence `x² + 1 ≡ 0`
has **exactly two** solutions in `ZMod p`.
-/
theorem card_solSet_of_ne (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (h : p % 4 ≠ 3) :
    (solSet p).card = 2 := by
  obtain ⟨i, hi⟩ : ∃ i : ZMod p, i^2 = -1 := by
    obtain ⟨ x, hx ⟩ := solvable_iff p |>.2 h;
    exact ⟨ x, eq_neg_of_add_eq_zero_left hx ⟩;
  -- To show that `solSet p` has exactly two elements, we note that `i` and `-i` are distinct because `p` is odd and `i ≠ 0`.
  have h_distinct : i ≠ -i := by
    by_contra h_eq;
    rw [ eq_neg_iff_add_eq_zero ] at h_eq;
    simp_all +decide [ ← two_mul ];
    exact absurd ( h_eq.resolve_left ( by erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two ( lt_of_le_of_ne ( Nat.Prime.two_le Fact.out ) ( Ne.symm hp2 ) ) ) ) ( by aesop )
  have h_solSet : solSet p = {i, -i} := by
    ext x; simp [solSet];
    exact ⟨ fun hx => eq_or_eq_neg_of_sq_eq_sq _ _ <| by linear_combination hx - hi, by rintro ( rfl | rfl ) <;> linear_combination hi ⟩
  rw [h_solSet, Finset.card_pair h_distinct]

/--
When `p ≡ 3 (mod 4)` the congruence `x² + 1 ≡ 0` has **no** solutions.
-/
theorem card_solSet_of_three (p : ℕ) [Fact p.Prime] (h : p % 4 = 3) :
    (solSet p).card = 0 := by
  contrapose! h;
  obtain ⟨ x, hx ⟩ := Finset.card_pos.mp ( Nat.pos_of_ne_zero h ) ; have := solvable_iff p; aesop;

/-! ### Part 4: connection to Mathlib's Legendre symbol -/

/--
The Legendre symbol form of the solvability criterion: `(-1/p) = 1` iff
`p ≡ 1 (mod 4)`.
-/
theorem legendre_neg_one_eq_one_iff (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    legendreSym p (-1) = 1 ↔ p % 4 = 1 := by
  rw [ legendreSym.at_neg_one ];
  · rw [ ZMod.χ₄_nat_mod_four ] ; have := Nat.mod_lt p zero_lt_four; interval_cases _ : p % 4 <;> simp_all +decide ;
  · assumption

/--
The Legendre symbol obstruction: `(-1/p) = -1` iff `p ≡ 3 (mod 4)`.
-/
theorem legendre_neg_one_eq_neg_one_iff (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    legendreSym p (-1) = -1 ↔ p % 4 = 3 := by
  rw [ legendreSym.at_neg_one ];
  · rw [ ZMod.χ₄_nat_mod_four ] ; have := Nat.mod_lt p zero_lt_four; interval_cases _ : p % 4 <;> simp_all +decide ;
  · assumption

/-! ### Part 3: the elementary asymptotics -/

/--
**The Legendre-symbol obstruction.** No prime `p ≡ 3 (mod 4)` divides
`n² + 1`, for any `n`.  (If `p ∣ n² + 1` then `-1` would be a square mod `p`,
contradicting the solvability criterion.)
-/
theorem not_dvd_of_three_mod_four {p : ℕ} (hp : p.Prime) (h : p % 4 = 3) (n : ℕ) :
    ¬ (p ∣ n ^ 2 + 1) := by
  haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;
  intro H; have := solvable_iff p; simp_all +decide ;

/--
**Elementary asymptotics (Part 3).** Among `n < X`, the number of `n` for which
`n² + 1` has a prime factor `≡ 3 (mod 4)` is exactly `0`.  Hence the proportion is
`0`, with no analytic (prime number theorem) input required — the bound is forced
entirely by the Legendre-symbol obstruction `not_dvd_of_three_mod_four`.
-/
theorem count_with_bad_prime_factor_eq_zero (X : ℕ) :
    ((Finset.range X).filter
      (fun n => ∃ p, p.Prime ∧ p % 4 = 3 ∧ p ∣ n ^ 2 + 1)).card = 0 := by
  rw [ Finset.card_eq_zero ];
  exact Finset.filter_eq_empty_iff.mpr fun n hn => fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => not_dvd_of_three_mod_four hp₁ hp₂ n hp₃

/-! ### Part 2: the local density factors `ν_p(n)` -/

/-- The local density factor
`ν_p(n) = #{x (mod p) : x² + 1 ≡ 0 (mod p), gcd(x, n) = 1}`. -/
def nu (p n : ℕ) [NeZero p] : ℕ :=
  (Finset.univ.filter
    (fun x : ZMod p => x ^ 2 + 1 = 0 ∧ Nat.gcd x.val n = 1)).card

/-- The local factor `ν_p(n) / p` appearing in the singular series `∏_p ν_p / p`.
(Only the individual local factors are unconditional; see the file header note on
the `C · X / √(log X)` heuristic.) -/
noncomputable def localFactor (p n : ℕ) [NeZero p] : ℝ := (nu p n : ℝ) / p

/--
`ν_p(n)` counts a subset of the full solution set, hence is bounded by its
cardinality.
-/
theorem nu_le_card_solSet (p n : ℕ) [NeZero p] : nu p n ≤ (solSet p).card := by
  refine Finset.card_mono ?_ ; aesop_cat;

/--
At an odd prime `p ≢ 3 (mod 4)`, `ν_p(n) ≤ 2`.
-/
theorem nu_le_two {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) (n : ℕ) : nu p n ≤ 2 := by
  by_cases h : p % 4 = 3;
  · exact le_trans ( nu_le_card_solSet p n ) ( by rw [ card_solSet_of_three p h ] ; norm_num );
  · exact le_trans ( nu_le_card_solSet p n ) ( by rw [ card_solSet_of_ne p hp2 h ] )

/--
At a prime `p ≡ 3 (mod 4)` the local factor vanishes: `ν_p(n) = 0`.
-/
theorem nu_eq_zero_of_three {p : ℕ} [Fact p.Prime] (h : p % 4 = 3) (n : ℕ) :
    nu p n = 0 := by
  refine Finset.card_eq_zero.mpr ?_;
  -- By `card_solSet_of_three`, `(solSet p).card = 0`.
  have h_solSet_card : (solSet p).card = 0 := by
    exact card_solSet_of_three p h;
  simp_all +decide [ Finset.ext_iff,solSet ]

end NSquaredPlusOneLocal