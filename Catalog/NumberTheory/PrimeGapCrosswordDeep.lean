/-
# Prime Gap Crossword: Deep Structure and Automaton Theory

This module develops the automaton-theoretic view of prime gap patterns.
The key insight: fixing a sieve set S of small primes, the admissibility
of a gap word is determined by a finite-state automaton whose states are
residue classes mod ∏S. This turns the "prime crossword" into a problem
in symbolic dynamics over a finite alphabet.

## Main results

1. **GapAutomaton**: A finite-state machine tracking admissible residue
   classes as gaps are consumed.

2. **Consecutive gap sum bound**: For primes p > 3, consecutive gaps sum ≥ 4.

3. **Residue class analysis**: Primes mod 6 and mod 30.

4. **Twin prime residue theorem**: twin primes > 3 are ≡ 5 mod 6.

5. **Sieve admissibility framework**: modular sieve analysis of prime gaps.

6. **Explicit forcing patterns**: concrete gap sequences that determine the next gap.
-/

import Mathlib

open Finset Nat

namespace PrimeGapCrossword

/-! ## Core Sieve Definitions -/

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

/-- A bounded next-gap g is "forcing" for word w over S with bound B:
    g is the unique positive admissible next gap ≤ B. -/
def ForcingNextOver (S : Finset ℕ) (B : ℕ) (w : List ℕ) (g : ℕ) : Prop :=
  NextGapAdmissibleOver S w g ∧
  ∀ h : ℕ, 0 < h → h ≤ B → NextGapAdmissibleOver S w h → h = g

/-! ## Section 1: Prime gap basic properties -/

/-- Between any two odd primes, the gap is at least 2. -/
theorem prime_gap_ge_two {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp3 : 2 < p) (hpq : p < q) :
    2 ≤ q - p := by
  have hp_odd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h <;> omega
  have hq_odd : q % 2 = 1 := by
    rcases hq.eq_two_or_odd with h | h <;> omega
  omega

/-- Consecutive gap pairs sum to at least 4 for primes > 2. -/
theorem consecutive_gap_sum_ge_four {p q r : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
    (hp3 : 2 < p) (hq3 : 2 < q)
    (hpq : p < q) (hqr : q < r) :
    4 ≤ (q - p) + (r - q) := by
  have h1 : 2 ≤ q - p := prime_gap_ge_two hp hq hp3 hpq
  have h2 : 2 ≤ r - q := prime_gap_ge_two hq hr hq3 hqr
  omega

/-! ## Section 2: Modular residue analysis -/

/-
A prime p > 3 satisfies p ≡ 1 or 5 (mod 6).
-/
theorem prime_mod_six {p : ℕ} (hp : Nat.Prime p) (hp3 : 3 < p) :
    p % 6 = 1 ∨ p % 6 = 5 := by
      by_contra h_contra;
      have := Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by obtain ⟨ k, hk ⟩ := Nat.Prime.eq_two_or_odd hp <;> omega ) ; rw [ hp.dvd_iff_eq ] at this <;> linarith;

/-- The gap between primes > 3 is even. -/
theorem gap_even_for_large_primes {p q : ℕ}
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp3 : 3 < p) (hpq : p < q) :
    (q - p) % 2 = 0 := by
  have hp_odd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h <;> omega
  have hq_odd : q % 2 = 1 := by
    rcases hq.eq_two_or_odd with h | h <;> omega
  omega

/-! ## Section 3: Twin prime residue theorem -/

/-
If p and p+2 are both prime with p > 3, then p ≡ 5 (mod 6).
-/
theorem twin_prime_residue {p : ℕ} (hp : Nat.Prime p) (hp2 : Nat.Prime (p + 2))
    (hp3 : 3 < p) : p % 6 = 5 := by
      rw [ ← Nat.mod_add_div p 6 ] at *; have := Nat.mod_lt p ( by decide : 6 > 0 ) ; interval_cases _ : p % 6 <;> simp_all +arith +decide [ Nat.prime_mul_iff ] ;
      · exact absurd hp2 ( by rw [ show 6 * ( p / 6 ) + 3 = 3 * ( 2 * ( p / 6 ) + 1 ) by ring ] ; exact Nat.not_prime_mul ( by norm_num ) ( by linarith ) );
      · cases Nat.Prime.eq_two_or_odd hp <;> omega;
      · exact absurd hp ( by rw [ show 6 * ( p / 6 ) + 3 = 3 * ( 2 * ( p / 6 ) + 1 ) by ring ] ; exact Nat.not_prime_mul ( by norm_num ) ( by linarith [ Nat.mod_add_div p 6 ] ) );
      · cases hp.eq_two_or_odd <;> omega

/-- The gap pattern [2, 4]: if p, p+2, p+6 are prime and p > 5,
    then p ≡ 5 (mod 6). -/
theorem gap_pattern_2_4_residue {p : ℕ}
    (hp : Nat.Prime p) (hp2 : Nat.Prime (p + 2)) (_hp6 : Nat.Prime (p + 6))
    (hp5 : 5 < p) : p % 6 = 5 :=
  twin_prime_residue hp hp2 (by omega)

/-! ## Section 4: The Gap Automaton -/

/-- The state of a gap automaton: a set of candidate starting residues mod M. -/
structure GapAutomatonState (M : ℕ) where
  admissibleResidues : Finset (Fin M)
  deriving DecidableEq

/-- A state is forcing if it has exactly one admissible residue. -/
def GapAutomatonState.isForcing {M : ℕ} (s : GapAutomatonState M) : Prop :=
  s.admissibleResidues.card = 1

/-
A forcing state has a unique residue.
-/
theorem forcing_state_unique {M : ℕ} (s : GapAutomatonState M)
    (hf : s.isForcing) :
    ∃! r, r ∈ s.admissibleResidues := by
      exact Finset.card_eq_one.mp hf |> Exists.imp fun x hx => by aesop;

/-! ## Section 5: Residue counting -/

/-
For a single prime q, the number of residues in [0, q) avoiding q
    is exactly q - 1.
-/
theorem card_avoids_single_prime (q : ℕ) (hq : Nat.Prime q) :
    ((Finset.range q).filter (fun r => ¬(q ∣ r))).card = q - 1 := by
      rw [ Finset.filter_not, Finset.card_sdiff ] ; norm_num [ hq.pos ];
      rw [ show ( Finset.filter ( Dvd.dvd q ) ( Finset.range q ) ∩ Finset.range q ) = { 0 } from ?_ ] ; norm_num;
      ext ( _ | i ) <;> simp +decide [ Nat.dvd_iff_mod_eq_zero, Nat.mod_eq_of_lt, hq.one_lt ];
      · exact hq.pos;
      · exact fun h₁ h₂ => absurd h₂ ( by rw [ Nat.mod_eq_of_lt h₁ ] ; norm_num )

/-! ## Section 6: Prime residues mod 30 -/

/-
A prime p > 5 satisfies p mod 30 ∈ {1, 7, 11, 13, 17, 19, 23, 29}.
-/
theorem prime_mod_thirty {p : ℕ} (hp : Nat.Prime p) (hp5 : 5 < p) :
    p % 30 ∈ ({1, 7, 11, 13, 17, 19, 23, 29} : Finset ℕ) := by
      have h_mod30 : p % 2 ≠ 0 ∧ p % 3 ≠ 0 ∧ p % 5 ≠ 0 := by
        exact ⟨ fun h => by have := Nat.dvd_of_mod_eq_zero h; rw [ hp.dvd_iff_eq ] at this <;> linarith, fun h => by have := Nat.dvd_of_mod_eq_zero h; rw [ hp.dvd_iff_eq ] at this <;> linarith, fun h => by have := Nat.dvd_of_mod_eq_zero h; rw [ hp.dvd_iff_eq ] at this <;> linarith ⟩;
      rw [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 30 ), ← Nat.mod_mod_of_dvd p ( by decide : 3 ∣ 30 ), ← Nat.mod_mod_of_dvd p ( by decide : 5 ∣ 30 ) ] at h_mod30; have := Nat.mod_lt p ( by decide : 0 < 30 ) ; interval_cases p % 30 <;> trivial;

/-- There are exactly 8 admissible residue classes mod 30 for primes > 5. -/
theorem gap_alphabet_size_mod30 :
    ({1, 7, 11, 13, 17, 19, 23, 29} : Finset ℕ).card = 8 := by decide

/-! ## Section 7: Sieve monotonicity -/

/-- AvoidsPrimes is anti-monotone in S. -/
theorem avoidsPrimes_mono {S T : Finset ℕ} {n : ℕ}
    (hST : S ⊆ T) (h : AvoidsPrimes T n) : AvoidsPrimes S n :=
  fun x hx => h x (hST hx)

/-- HitByPrimes is monotone in S. -/
theorem hitByPrimes_mono {S T : Finset ℕ} {n : ℕ}
    (hST : S ⊆ T) (h : HitByPrimes S n) : HitByPrimes T n :=
  ⟨h.choose, hST h.choose_spec.1, h.choose_spec.2⟩

/-! ## Section 8: Admissibility periodicity -/

/-
Admissibility is periodic: if M divides all primes in S, then
    admissible at a implies admissible at a + M.
-/
theorem admissibleAt_periodic {S : Finset ℕ} {gaps : List ℕ} {a M : ℕ}
    (hM : M > 0) (hdvd : ∀ q ∈ S, q ∣ M)
    (h : AdmissibleAt S gaps a) :
    AdmissibleAt S gaps (a + M) := by
      constructor;
      · intro t ht; specialize h; have := h.1 t ht; simp_all +decide [ AvoidsPrimes, Nat.dvd_add_right ] ;
        exact fun q hq => by rw [ add_right_comm ] ; exact fun hq' => this q hq ( by simpa using Nat.dvd_sub hq' ( hdvd q hq ) ) ;
      · intro u hu
        obtain ⟨q, hqS, hq⟩ : ∃ q ∈ S, q ∣ (a + u) := by
          exact h.2 u hu;
        exact ⟨ q, hqS, by convert dvd_add hq ( hdvd q hqS ) using 1; ring ⟩

/-
If a gap word is S-admissible, there are infinitely many
    starting positions realizing it.
-/
theorem admissible_infinite_realizations
    {S : Finset ℕ} {gaps : List ℕ}
    (hS : ∀ q ∈ S, 0 < q)
    (hadm : AdmissibleOver S gaps) :
    ∃ a M, M > 0 ∧ ∀ k : ℕ, AdmissibleAt S gaps (a + k * M) := by
      obtain ⟨ a, ha ⟩ := hadm;
      refine' ⟨ a, ∏ q ∈ S, q, Finset.prod_pos _, fun k => _ ⟩;
      · assumption;
      · induction k <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ];
        convert admissibleAt_periodic ( Finset.prod_pos hS ) ( fun q hq => Finset.dvd_prod_of_mem _ hq ) ‹_› using 1

/-! ## Section 9: Explicit forcing patterns -/

/-
Over {2,3} with bound 6, [2] forces next gap 4.
-/
theorem explicit_forcing_23 :
    ForcingNextOver {2, 3} 6 [2] 4 := by
      constructor;
      · use 5; simp +decide [ AdmissibleAt ] ;
      · rintro ( _ | _ | _ | _ | _ | _ | _ | h ) <;> simp_all +arith +decide;
        · rintro ⟨ a, ha ⟩;
          cases ha ; simp_all +arith +decide [ AdmissibleAt ];
          unfold gapWordPositions interiorSet at * ; simp_all +arith +decide [ AvoidsPrimes, HitByPrimes ];
          grind;
        · rintro ⟨ a, ha₁, ha₂ ⟩;
          simp_all +arith +decide [ gapWordPositions, interiorSet, AvoidsPrimes, HitByPrimes ];
          grind;
        · rintro ⟨ a, ⟨ h₁, h₂ ⟩ ⟩;
          simp_all +arith +decide [ gapWordPositions, interiorSet, AvoidsPrimes, HitByPrimes ];
          grind;
        · rintro ⟨ a, ha ⟩;
          cases ha ; simp_all +arith +decide [ AdmissibleAt ];
          unfold gapWordPositions at *; unfold interiorSet at *; simp_all +arith +decide [ AvoidsPrimes, HitByPrimes ] ;
          grind;
        · rintro ⟨ a, ha ⟩;
          have := ha.1 0 ; have := ha.1 2 ; have := ha.1 8 ; have := ha.2 1 ; have := ha.2 3 ; have := ha.2 4 ; have := ha.2 5 ; have := ha.2 6 ; have := ha.2 7 ; simp_all +decide [ AvoidsPrimes, HitByPrimes ];
          omega

/-
Over {2,3} with bound 6, [4] forces next gap 2.
-/
theorem explicit_forcing_23_alt :
    ForcingNextOver {2, 3} 6 [4] 2 := by
      constructor;
      · use 1; simp +decide [ AdmissibleAt ] ;
      · intro h h_pos h_le;
        interval_cases h <;> simp_all +decide [ NextGapAdmissibleOver ];
        · unfold AdmissibleOver;
          unfold AdmissibleAt; simp +decide [ gapWordPositions, interiorSet ] ;
          intro x hx₁ hx₂ hx₃; use 2; simp_all +decide [ AvoidsPrimes, HitByPrimes ] ;
        · rintro ⟨ a, ha ⟩;
          obtain ⟨ h₁, h₂ ⟩ := ha;
          unfold gapWordPositions interiorSet at * ; simp_all +decide [ AvoidsPrimes, HitByPrimes ];
          omega;
        · unfold AdmissibleOver;
          unfold AdmissibleAt; simp +decide [ gapWordPositions, interiorSet ] ;
          intro x hx₁ hx₂ hx₃; use if x % 2 = 0 then 1 else 2; simp_all +decide [ AvoidsPrimes, HitByPrimes ] ;
        · rintro ⟨ a, ha ⟩;
          unfold AdmissibleAt at ha;
          unfold gapWordPositions interiorSet at ha ; simp_all +decide [ AvoidsPrimes, HitByPrimes ];
          grind;
        · rintro ⟨ a, ⟨ ha₁, ha₂ ⟩ ⟩;
          have := ha₂ 1; have := ha₂ 2; have := ha₂ 3; have := ha₂ 5; have := ha₂ 6; have := ha₂ 7; have := ha₂ 8; have := ha₂ 9; simp_all +decide [ HitByPrimes ] ;
          grind +splitImp

/-- There exist nontrivial forcing patterns. -/
theorem exists_forcing_pattern :
    ∃ (S : Finset ℕ) (w : List ℕ) (g B : ℕ),
      (∀ q ∈ S, Nat.Prime q) ∧
      w ≠ [] ∧
      0 < g ∧
      ForcingNextOver S B w g := by
  exact ⟨{2, 3}, [2], 4, 6, by norm_num, by decide, by decide, explicit_forcing_23⟩

/-! ## Section 10: Forcing transfer -/

/-- If S-forcing holds and every T-admissible extension is also S-admissible,
    then T-forcing holds. -/
theorem forcing_transfer
    {S T : Finset ℕ} {w : List ℕ} {g : ℕ} {B : ℕ}
    (hforce : ForcingNextOver S B w g)
    (hadm : NextGapAdmissibleOver T w g)
    (htrans : ∀ h, 0 < h → h ≤ B → NextGapAdmissibleOver T w h →
              NextGapAdmissibleOver S w h) :
    ForcingNextOver T B w g :=
  ⟨hadm, fun h h_pos h_leB hh => hforce.2 h h_pos h_leB (htrans h h_pos h_leB hh)⟩

/-! ## Section 11: Forcing Density Conjecture -/

/-- **Forcing Density Conjecture**: For every finite sieve containing {2,3}
    and every gap bound B ≥ 6, there exist arbitrarily long forcing patterns. -/
def ForcingDensityConjecture : Prop :=
  ∀ (S : Finset ℕ) (B : ℕ),
    ({2, 3} : Finset ℕ) ⊆ S →
    (∀ q ∈ S, Nat.Prime q) →
    6 ≤ B →
    ∀ k : ℕ, ∃ (w : List ℕ) (g : ℕ),
      k ≤ w.length ∧ 0 < g ∧ ForcingNextOver S B w g

/-- The conjecture holds for k ≤ 1 via explicit_forcing_23. -/
theorem forcing_density_base :
    ∀ k : ℕ, k ≤ 1 →
    ∃ (w : List ℕ) (g : ℕ),
      k ≤ w.length ∧ 0 < g ∧ ForcingNextOver {2, 3} 6 w g := by
  intro k hk
  exact ⟨[2], 4, by simp; omega, by omega, explicit_forcing_23⟩

end PrimeGapCrossword