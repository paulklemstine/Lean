/-! # CatalogBuild.Physics.PrimeMod6Structure

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 12
-/

import Mathlib

/-- [Section: # Prime Modular Structure
Formal proofs about the mod 6 structure of primes and prime pairs.
## Main results
- `prime_mod6` — p > 3 prime implies p ≡ 1 or 5 (mod 6)
- `twin_prime_mod6` — Twin prime p > 3 implies p ≡ 5 (mod 6)
- `cousin_prime_mod6` — Cousin prime p > 3 implies p ≡ 1 (mod 6)
- `gap_residue_mod6` — General gap-residue theorem for prime pairs
- `sexy_prime_both_residues` — Sexy primes can have either residue] -/
theorem prime_mod6 (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p) :
    p % 6 = 1 ∨ p % 6 = 5 := by
      by_contra! h_contra;
      have := Nat.Prime.eq_two_or_odd hp; ( have := Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 by omega ) ; rw [ hp.dvd_iff_eq ] at this <;> linarith; )


/-- [Section: # CatalogBuild.Physics.PrimeMod6Structure
Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 12] -/
theorem twin_prime_mod6 (p : ℕ) (hp : Nat.Prime p) (hp2 : Nat.Prime (p + 2))
    (hp3 : 3 < p) : p % 6 = 5 := by
      -- By prime_mod6, p ≡ 1 or 5 (mod 6).
      have h1 : p % 6 = 1 ∨ p % 6 = 5 := prime_mod6 p hp hp3;
      exact h1.resolve_left fun h => by have := Nat.dvd_of_mod_eq_zero ( by omega : ( p + 2 ) % 3 = 0 ) ; rw [ hp2.dvd_iff_eq ] at this <;> linarith;


theorem cousin_prime_mod6 (p : ℕ) (hp : Nat.Prime p) (hp4 : Nat.Prime (p + 4))
    (hp3 : 3 < p) : p % 6 = 1 := by
      cases prime_mod6 p hp hp3 <;> simp_all +arith +decide;
      exact absurd ( Nat.dvd_of_mod_eq_zero ( show ( p + 4 ) % 3 = 0 from by omega ) ) ( by rw [ hp4.dvd_iff_eq ] <;> linarith )


/-- Sexy primes (gap 6) can have either residue mod 6. -/
theorem sexy_prime_both_residues :
    -- (5, 11): 5 % 6 = 5
    (Nat.Prime 5 ∧ Nat.Prime 11 ∧ 11 = 5 + 6 ∧ 5 % 6 = 5) ∧
    -- (7, 13): 7 % 6 = 1
    (Nat.Prime 7 ∧ Nat.Prime 13 ∧ 13 = 7 + 6 ∧ 7 % 6 = 1) := by
  refine ⟨⟨?_, ?_, ?_, ?_⟩, ⟨?_, ?_, ?_, ?_⟩⟩ <;> decide


theorem gap_residue_mod6_case2 (p g : ℕ) (hp : Nat.Prime p) (hpg : Nat.Prime (p + g))
    (hp3 : 3 < p) (hg : g % 6 = 2) : p % 6 = 5 := by
      -- By prime_mod6, p % 6 ∈ {1, 5}.
      have h_p_mod6 : p % 6 = 1 ∨ p % 6 = 5 := prime_mod6 p hp hp3;
      exact h_p_mod6.resolve_left fun h => by have := Nat.dvd_of_mod_eq_zero ( show ( p + g ) % 3 = 0 from by omega ) ; rw [ hpg.dvd_iff_eq ] at this <;> linarith;


theorem gap_residue_mod6_case4 (p g : ℕ) (hp : Nat.Prime p) (hpg : Nat.Prime (p + g))
    (hp3 : 3 < p) (hg : g % 6 = 4) : p % 6 = 1 := by
      -- By prime_mod6, p % 6 ∈ {1, 5}.
      have h_p_mod6 : p % 6 = 1 ∨ p % 6 = 5 := prime_mod6 p hp hp3;
      cases h_p_mod6 <;> simp_all +decide [ Nat.add_mod ];
      exact absurd ( Nat.dvd_of_mod_eq_zero ( show ( p + g ) % 3 = 0 by omega ) ) ( by rw [ hpg.dvd_iff_eq ] <;> omega )


/-- Cousin prime count below 1000 is 41. -/
theorem cousin_prime_count_1000 :
    ((Finset.range 999).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 4))).card = 41 := by
  native_decide


/-- Sexy prime count below 1000 is 74. -/
theorem sexy_prime_count_1000 :
    ((Finset.range 999).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 6))).card = 74 := by
  native_decide


/-- All twin primes > 3 below 200 satisfy p ≡ 5 (mod 6). -/
theorem twin_prime_mod6_verified :
    ∀ p ∈ (Finset.Icc 5 200).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 2)),
      p % 6 = 5 := by
  native_decide


/-- All cousin primes > 3 below 200 satisfy p ≡ 1 (mod 6). -/
theorem cousin_prime_mod6_verified :
    ∀ p ∈ (Finset.Icc 5 200).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 4)),
      p % 6 = 1 := by
  native_decide


/-- Gap-8 primes: if p > 3, p and p+8 are both prime, then p ≡ 5 (mod 6)
(since 8 ≡ 2 mod 6). -/
theorem gap8_prime_mod6_verified :
    ∀ p ∈ (Finset.Icc 5 500).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 8)),
      p % 6 = 5 := by
  native_decide


/-- Gap-10 primes: if p > 3, p and p+10 are both prime, then p ≡ 1 (mod 6)
(since 10 ≡ 4 mod 6). -/
theorem gap10_prime_mod6_verified :
    ∀ p ∈ (Finset.Icc 5 500).filter (fun p => Nat.Prime p ∧ Nat.Prime (p + 10)),
      p % 6 = 1 := by
  native_decide

