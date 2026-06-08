/-
# Prime Gap Crossword: Modular Admissibility and Forcing Patterns

This module formalizes a "prime crossword" framework where prime gaps are
studied through modular sieve constraints. The key idea: fix a finite set S
of small primes. A gap word (list of positive even integers) is S-admissible
if there exists a starting residue mod ∏S such that:
  - every cumulative "prime position" avoids all primes in S,
  - every intermediate position is divisible by at least one prime in S.

This creates a finite-state symbolic dynamics on prime gap patterns.
A gap word is "forcing" if it has a unique admissible next gap.
-/

import Mathlib

open Finset Nat

namespace PrimeCrossword

/-! ## Core Definitions -/

/-- Cumulative sums of a gap word, starting from 0. -/
def gapWordPositions (gaps : List ℕ) : List ℕ :=
  gaps.scanl (· + ·) 0

/-- The set of all integers strictly between consecutive cumulative positions. -/
def interiorSet (gaps : List ℕ) : Finset ℕ :=
  let positions := gapWordPositions gaps
  let pairs := positions.zip positions.tail
  pairs.foldl (fun acc (p : ℕ × ℕ) =>
    acc ∪ (Finset.Ioo p.1 p.2)) ∅

/-- A number avoids all primes in a finite set S. -/
def AvoidsPrimes (S : Finset ℕ) (n : ℕ) : Prop :=
  ∀ q ∈ S, ¬(q ∣ n)

/-- A number is hit by at least one prime in S. -/
def HitByPrimes (S : Finset ℕ) (n : ℕ) : Prop :=
  ∃ q ∈ S, q ∣ n

instance (S : Finset ℕ) (n : ℕ) : Decidable (AvoidsPrimes S n) :=
  inferInstanceAs (Decidable (∀ q ∈ S, ¬(q ∣ n)))

instance (S : Finset ℕ) (n : ℕ) : Decidable (HitByPrimes S n) :=
  inferInstanceAs (Decidable (∃ q ∈ S, q ∣ n))

/-- A gap word is S-admissible at residue a. -/
def AdmissibleAt (S : Finset ℕ) (gaps : List ℕ) (a : ℕ) : Prop :=
  (∀ t ∈ gapWordPositions gaps, AvoidsPrimes S (a + t)) ∧
  (∀ u ∈ interiorSet gaps, HitByPrimes S (a + u))

instance (S : Finset ℕ) (gaps : List ℕ) (a : ℕ) : Decidable (AdmissibleAt S gaps a) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- A gap word is S-admissible if some starting residue works. -/
def AdmissibleOver (S : Finset ℕ) (gaps : List ℕ) : Prop :=
  ∃ a : ℕ, AdmissibleAt S gaps a

/-- A gap g is an admissible next gap after word w over sieve S. -/
def NextGapAdmissibleOver (S : Finset ℕ) (w : List ℕ) (g : ℕ) : Prop :=
  AdmissibleOver S (w ++ [g])

/-- The avoidance-only part of admissibility (no interior constraint). -/
def AvoidanceAdmissibleAt (S : Finset ℕ) (gaps : List ℕ) (a : ℕ) : Prop :=
  ∀ t ∈ gapWordPositions gaps, AvoidsPrimes S (a + t)

/-- Avoidance-only admissibility. -/
def AvoidanceAdmissible (S : Finset ℕ) (gaps : List ℕ) : Prop :=
  ∃ a : ℕ, AvoidanceAdmissibleAt S gaps a

/-- A bounded next-gap g is "forcing" for word w over S with bound B:
    g is the unique positive admissible next gap ≤ B. -/
def ForcingNextOver (S : Finset ℕ) (B : ℕ) (w : List ℕ) (g : ℕ) : Prop :=
  NextGapAdmissibleOver S w g ∧
  ∀ h : ℕ, 0 < h → h ≤ B → NextGapAdmissibleOver S w h → h = g

/-! ## Theorem 1: Prime gaps beyond 3 are even

    This is the first "grammar rule" of the prime crossword: all gaps
    in the alphabet are even numbers. -/

theorem prime_gap_even
    {p q : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (h3 : 3 ≤ p) (hpq : p < q)
    (_hnext : ∀ n, p < n → n < q → ¬ Nat.Prime n) :
    Even (q - p) := by
  cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;>
    simp_all +arith +decide [Nat.even_sub hpq.le]
  all_goals grind

/-! ## Theorem 2: AvoidsPrimes / HitByPrimes basic properties -/

/-- AvoidsPrimes is anti-monotone in S. -/
theorem avoidsPrimes_mono {S T : Finset ℕ} {n : ℕ}
    (hST : S ⊆ T) (h : AvoidsPrimes T n) : AvoidsPrimes S n :=
  fun x hx => h x (hST hx)

/-- HitByPrimes is monotone in S. -/
theorem hitByPrimes_mono {S T : Finset ℕ} {n : ℕ}
    (hST : S ⊆ T) (h : HitByPrimes S n) : HitByPrimes T n :=
  ⟨h.choose, hST h.choose_spec.1, h.choose_spec.2⟩

/-! ## Theorem 3: Avoidance-admissibility is anti-monotone -/

/-- Adding more primes to the sieve makes avoidance harder. -/
theorem avoidanceAdmissible_anti_mono
    {S T : Finset ℕ} {gaps : List ℕ}
    (hST : S ⊆ T) :
    AvoidanceAdmissible T gaps → AvoidanceAdmissible S gaps := by
  intro ⟨a, ha⟩
  exact ⟨a, fun t ht => avoidsPrimes_mono hST (ha t ht)⟩

/-! ## Theorem 4: Forcing transfer lemma -/

/-
If S-forcing holds and every T-admissible extension is also S-admissible,
    then T-forcing holds. This is the key composable lemma for proving
    forcing strengthens when the sieve is refined.
-/
theorem forcing_transfer
    {S T : Finset ℕ} {w : List ℕ} {g : ℕ} {B : ℕ}
    (hforce : ForcingNextOver S B w g)
    (hadm : NextGapAdmissibleOver T w g)
    (htrans : ∀ h, 0 < h → h ≤ B → NextGapAdmissibleOver T w h →
              NextGapAdmissibleOver S w h) :
    ForcingNextOver T B w g := by
  exact ⟨ hadm, fun h h_pos h_leB hh => hforce.2 h h_pos h_leB ( htrans h h_pos h_leB hh ) ⟩

/-! ## Theorem 5: Admissibility is periodic in residue -/

/-
If a gap word is admissible at residue a, then it is also
    admissible at a + M when M is divisible by all primes in S.
    This key periodicity is what makes admissibility a finite-state property.
-/
theorem admissibleAt_periodic {S : Finset ℕ} {gaps : List ℕ} {a M : ℕ}
    (hM : M > 0)
    (hdvd : ∀ q ∈ S, q ∣ M)
    (h : AdmissibleAt S gaps a) :
    AdmissibleAt S gaps (a + M) := by
  constructor;
  · intro t ht;
    intro q hq;
    convert h.1 t ht q hq using 1;
    rw [ add_right_comm, Nat.dvd_add_left ( hdvd q hq ) ];
  · intro u hu; obtain ⟨ q, hqS, hqu ⟩ := h.2 u hu; exact ⟨ q, hqS, by convert Nat.dvd_add hqu ( hdvd q hqS ) using 1; ring ⟩ ;

/-! ## Theorem 6: Infinite realizations via periodicity -/

/-
If a gap word is S-admissible, then there exist infinitely many
    starting positions realizing the pattern.
-/
theorem admissible_infinite_realizations
    {S : Finset ℕ} {gaps : List ℕ}
    (hS : ∀ q ∈ S, 0 < q)
    (hadm : AdmissibleOver S gaps) :
    ∃ a M, M > 0 ∧ ∀ k : ℕ, AdmissibleAt S gaps (a + k * M) := by
  -- Set M = S.prod id � (�but need M > 0). S.prod id is the product of all elements of S. If S = ∅, this is 1. If S is nonempty, since all elements are positive (hS), the product is positive. So M > 0.
  set M := (S.prod id) with hM_eq
  have hM_pos : 0 < M := by
    exact Finset.prod_pos hS;
  -- Prove ∀ q ∈ S �,� q M by Finset.dvd_prod_of_mem.
  have hM_div : ∀ q ∈ S, q ∣ M := by
    exact fun q hq => Finset.dvd_prod_of_mem _ hq;
  exact ⟨ hadm.choose, M, hM_pos, fun k => Nat.recOn k ( by simpa using hadm.choose_spec ) fun n ihn => by simpa [ add_mul, ← add_assoc ] using admissibleAt_periodic hM_pos hM_div ihn ⟩

/-! ## Theorem 7: Explicit forcing patterns -/

/-
Over the sieve {2, 3} with gap bound 6, the word [2] forces next gap 4
    (among positive gaps). Only a ≡ 5 (mod 6) works for [2], and extending
    by positive gap h ≤ 6, only h = 4 produces a valid configuration.
-/
theorem explicit_forcing_23 :
    ForcingNextOver {2, 3} 6 [2] 4 := by
  constructor;
  · use 5; simp +decide [ AdmissibleAt ] ;
  · -- By definition of `NextGapAdmissibleOver`, we need to show that for any `h` in the range 1 to 6, if `NextGapAdmissibleOver {2, 3} [2] h` holds, then `h = 4`.
    intro h h_pos h_le_6 h_adm
    obtain ⟨a, ha⟩ := h_adm;
    interval_cases h <;> simp_all +decide [ AdmissibleAt ];
    · simp +decide [ gapWordPositions, interiorSet ] at ha;
      cases Nat.mod_two_eq_zero_or_one a <;> simp_all +decide [ Nat.add_mod, AvoidsPrimes ];
    · simp_all +decide [ gapWordPositions, interiorSet, AvoidsPrimes, HitByPrimes ];
      grind;
    · simp_all +decide [ gapWordPositions, interiorSet, AvoidsPrimes, HitByPrimes ];
      grind;
    · unfold gapWordPositions interiorSet at ha; simp_all +decide [ AvoidsPrimes, HitByPrimes ] ;
      grind;
    · unfold gapWordPositions interiorSet at ha ; simp_all +arith +decide [ AvoidsPrimes, HitByPrimes ];
      unfold gapWordPositions at ha ; simp_all +arith +decide [ Nat.add_mod, Nat.mul_mod ];
      have := ha.2 1; have := ha.2 2; have := ha.2 3; have := ha.2 4; have := ha.2 5; have := ha.2 6; have := ha.2 7; norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.add_mod ] at *; omega;

/-
Over {2, 3} with bound 6, [4] forces next gap 2.
-/
theorem explicit_forcing_23_alt :
    ForcingNextOver {2, 3} 6 [4] 2 := by
  constructor;
  · refine' ⟨ 1, _, _ ⟩ <;> simp +decide [ AdmissibleAt ];
  · intro h h_pos h_le admissible
    obtain ⟨a, ha⟩ := admissible;
    interval_cases h <;> simp_all +decide [ AdmissibleAt ];
    · simp_all +decide [ gapWordPositions, interiorSet, AvoidsPrimes, HitByPrimes ];
      omega;
    · unfold gapWordPositions interiorSet at ha ; simp_all +decide [ AvoidsPrimes, HitByPrimes ];
      lia;
    · simp_all +decide [ gapWordPositions, interiorSet, AvoidsPrimes, HitByPrimes ];
      grind;
    · unfold gapWordPositions interiorSet at ha ; simp_all +decide [ AvoidsPrimes, HitByPrimes ];
      grind;
    · simp_all +decide [ Finset.ext_iff, AvoidsPrimes, HitByPrimes ];
      simp_all +decide [ Nat.dvd_iff_mod_eq_zero, Nat.add_mod ];
      have := Nat.mod_lt a zero_lt_two; have := Nat.mod_lt a zero_lt_three; interval_cases a % 2 <;> interval_cases a % 3 <;> simp_all +decide ;

/-! ## Theorem 8: Existence of forcing patterns -/

/-
There exist nontrivial forcing patterns: a sieve set of primes,
    a nonempty gap word, and a uniquely forced positive next gap.
-/
theorem exists_forcing_pattern :
    ∃ (S : Finset ℕ) (w : List ℕ) (g B : ℕ),
      (∀ q ∈ S, Nat.Prime q) ∧
      w ≠ [] ∧
      0 < g ∧
      ForcingNextOver S B w g := by
  use { 2, 3 }, [ 2 ], 4, 6;
  exact ⟨ by norm_num, by decide, by decide, explicit_forcing_23 ⟩

end PrimeCrossword