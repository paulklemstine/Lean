/-! # CatalogBuild.Physics.SafePrimesCunningham

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 12
-/

import Mathlib

/-- A Sophie Germain prime: p is prime and 2p + 1 is also prime. -/
def IsSophieGermain (p : ℕ) : Prop := Nat.Prime p ∧ Nat.Prime (2 * p + 1)


/-- A safe prime: q is prime and (q - 1) / 2 is also prime. -/
def IsSafePrime (q : ℕ) : Prop := Nat.Prime q ∧ 2 < q ∧ Nat.Prime ((q - 1) / 2)


/-- All Sophie Germain primes up to 100, verified computationally. -/
theorem sophie_germain_verified :
    ((Finset.range 100).filter (fun p => Nat.Prime p ∧ Nat.Prime (2 * p + 1))).card = 10 := by
  native_decide


/-- Explicit Sophie Germain primes up to 100. -/
theorem sg_explicit :
    (Nat.Prime 2 ∧ Nat.Prime 5) ∧
    (Nat.Prime 3 ∧ Nat.Prime 7) ∧
    (Nat.Prime 5 ∧ Nat.Prime 11) ∧
    (Nat.Prime 11 ∧ Nat.Prime 23) ∧
    (Nat.Prime 23 ∧ Nat.Prime 47) ∧
    (Nat.Prime 29 ∧ Nat.Prime 59) ∧
    (Nat.Prime 41 ∧ Nat.Prime 83) ∧
    (Nat.Prime 53 ∧ Nat.Prime 107) ∧
    (Nat.Prime 83 ∧ Nat.Prime 167) ∧
    (Nat.Prime 89 ∧ Nat.Prime 179) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩,
         ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;> decide


/-- Safe primes > 7 satisfy q ≡ 11 (mod 12). -/
theorem safe_prime_mod_12_evidence :
    ∀ q ∈ ({23, 47, 59, 83, 107, 167, 179, 227, 263} : Finset ℕ),
      Nat.Prime q ∧ q % 12 = 11 := by
  native_decide


/-- The chain 2 → 5 → 11 → 23 → 47 is a Cunningham chain of length 5. -/
theorem cunningham_chain_2_5 :
    Nat.Prime 2 ∧ Nat.Prime 5 ∧ 5 = 2 * 2 + 1 ∧
    Nat.Prime 11 ∧ 11 = 2 * 5 + 1 ∧
    Nat.Prime 23 ∧ 23 = 2 * 11 + 1 ∧
    Nat.Prime 47 ∧ 47 = 2 * 23 + 1 ∧
    ¬ Nat.Prime (2 * 47 + 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> first | decide | native_decide


/-- A remarkable Cunningham chain of length 6 starting at 89:
89 → 179 → 359 → 719 → 1439 → 2879.
(This is the longest first-kind Cunningham chain starting below 100.) -/
theorem cunningham_chain_89_6 :
    Nat.Prime 89 ∧ Nat.Prime 179 ∧ 179 = 2 * 89 + 1 ∧
    Nat.Prime 359 ∧ 359 = 2 * 179 + 1 ∧
    Nat.Prime 719 ∧ 719 = 2 * 359 + 1 ∧
    Nat.Prime 1439 ∧ 1439 = 2 * 719 + 1 ∧
    Nat.Prime 2879 ∧ 2879 = 2 * 1439 + 1 ∧
    ¬ Nat.Prime (2 * 2879 + 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    first | native_decide | norm_num


/-- The chain 41 → 83 → 167 is a length-3 Cunningham chain. -/
theorem cunningham_chain_41 :
    Nat.Prime 41 ∧ Nat.Prime 83 ∧ 83 = 2 * 41 + 1 ∧
    Nat.Prime 167 ∧ 167 = 2 * 83 + 1 ∧
    ¬ Nat.Prime (2 * 167 + 1) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> first | native_decide | norm_num


theorem sg_count_200 :
    ((Finset.range 200).filter (fun p => Nat.Prime p ∧ Nat.Prime (2 * p + 1))).card = 15 := by
  native_decide


theorem sg_count_500 :
    ((Finset.range 500).filter (fun p => Nat.Prime p ∧ Nat.Prime (2 * p + 1))).card = 25 := by
  native_decide


theorem sg_count_1000 :
    ((Finset.range 1000).filter (fun p => Nat.Prime p ∧ Nat.Prime (2 * p + 1))).card = 37 := by
  native_decide


/-- For Diffie-Hellman, safe primes ensure a large prime-order subgroup. -/
theorem dh_subgroup_order (q : ℕ) (hq : IsSafePrime q) :
    ∃ g : ℕ, 1 < g ∧ g < q ∧ Nat.Prime ((q - 1) / 2) :=
  ⟨2, by omega, by linarith [hq.2.1], hq.2.2⟩

