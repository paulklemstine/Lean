import Probability.PRNGEnumerationL1

/-!
# An improved counting bound: the zero-seed collapse

The general rarity bound `card_lfsrWords_le` counts one file per (taps, seed)
pair, i.e. `q^{2L}` files of length `n`.  That count is never attained for
`L ≥ 1`, because the `q^L` pairs with zero seed all produce the *same* file, the
all-zero one (`lfsr_pref_zero`).  Removing this collapse gives

```
|lfsrWords K L n| ≤ q^{2L} - q^L + 1        (`card_lfsrWords_le_zero_seed`)
```

which is a strict improvement (`card_lfsrWords_lt_pow_two_L`) and is **exactly
attained at `L = 1`** (`card_lfsrWords_one_eq_zero_seed_bound`), where the
order-one enumeration `card_lfsrWords_one` gives `q² - q + 1`.  At `L = 2` over
`GF(2)` the bound gives `13` against the true value `11`
(`card_lfsrWords_two_two_four`), so the remaining slack is exactly the
higher-order degeneracy that conjecture C1 predicts.
-/

namespace Catalog.Probability.SeedRec

open Finset

variable {K : Type*} [CommRing K] [Fintype K] [DecidableEq K]

/-- The (taps, seed) pairs with zero seed: `q^L` of them, all producing the
all-zero file. -/
def zeroSeedPairs (K : Type*) [CommRing K] [Fintype K] [DecidableEq K] (L : ℕ) :
    Finset ((Fin L → K) × (Fin L → K)) :=
  Finset.univ.image fun c : Fin L → K => (c, fun _ => (0 : K))

theorem card_zeroSeedPairs (L : ℕ) :
    (zeroSeedPairs K L).card = Fintype.card K ^ L := by
  rw [zeroSeedPairs, Finset.card_image_of_injective _ (fun c c' h => (Prod.mk.injEq _ _ _ _ ▸ h).1)]
  simp [Finset.card_univ]

/-- **Improved rarity bound.**  At most `q^{2L} - q^L + 1` files of length `n`
have linear complexity `≤ L`: the `q^L` zero-seed generators are all wasted on a
single file. -/
theorem card_lfsrWords_le_zero_seed (L n : ℕ) :
    (lfsrWords K L n).card ≤ Fintype.card K ^ (2 * L) - Fintype.card K ^ L + 1 := by
  classical
  set f : (Fin L → K) × (Fin L → K) → (Fin n → K) := fun p => (lfsrPRNG p.1).pref n p.2 with hf
  have hcardTotal : (Finset.univ : Finset ((Fin L → K) × (Fin L → K))).card
      = Fintype.card K ^ (2 * L) := by
    simp [Finset.card_univ, two_mul, pow_add]
  have hsub : zeroSeedPairs K L ⊆ (Finset.univ : Finset ((Fin L → K) × (Fin L → K))) :=
    Finset.subset_univ _
  have hsplit : (Finset.univ : Finset ((Fin L → K) × (Fin L → K)))
      = zeroSeedPairs K L ∪ (Finset.univ \ zeroSeedPairs K L) := by
    rw [Finset.union_sdiff_of_subset hsub]
  have himg : (zeroSeedPairs K L).image f ⊆ {(fun _ => (0 : K) : Fin n → K)} := by
    intro x hx
    rw [Finset.mem_image] at hx
    obtain ⟨p, hp, rfl⟩ := hx
    rw [zeroSeedPairs, Finset.mem_image] at hp
    obtain ⟨c, _, rfl⟩ := hp
    simpa [hf] using lfsr_pref_zero K c n
  have hone : ((zeroSeedPairs K L).image f).card ≤ 1 :=
    (Finset.card_le_card himg).trans (by simp)
  have hrest : ((Finset.univ \ zeroSeedPairs K L).image f).card
      ≤ Fintype.card K ^ (2 * L) - Fintype.card K ^ L := by
    refine Finset.card_image_le.trans ?_
    rw [Finset.card_sdiff, Finset.inter_univ, hcardTotal, card_zeroSeedPairs]
  have hwords : lfsrWords K L n = (Finset.univ : Finset ((Fin L → K) × (Fin L → K))).image f := rfl
  calc (lfsrWords K L n).card
      = ((zeroSeedPairs K L ∪ (Finset.univ \ zeroSeedPairs K L)).image f).card := by
        rw [hwords, ← hsplit]
    _ ≤ ((zeroSeedPairs K L).image f).card + ((Finset.univ \ zeroSeedPairs K L).image f).card := by
        rw [Finset.image_union]
        exact Finset.card_union_le _ _
    _ ≤ 1 + (Fintype.card K ^ (2 * L) - Fintype.card K ^ L) := Nat.add_le_add hone hrest
    _ = Fintype.card K ^ (2 * L) - Fintype.card K ^ L + 1 := Nat.add_comm _ _

/-- The improved bound is strictly better than `q^{2L}` whenever there is a
nonzero seed to waste. -/
theorem card_lfsrWords_lt_pow_two_L (L n : ℕ) (hL : 0 < L) (hK : 2 ≤ Fintype.card K) :
    (lfsrWords K L n).card < Fintype.card K ^ (2 * L) := by
  have hle := card_lfsrWords_le_zero_seed (K := K) L n
  have h1 : Fintype.card K ^ L ≤ Fintype.card K ^ (2 * L) :=
    Nat.pow_le_pow_right (by omega) (by omega)
  have h2 : 2 ≤ Fintype.card K ^ L := by
    calc 2 ≤ Fintype.card K := hK
      _ = Fintype.card K ^ 1 := (pow_one _).symm
      _ ≤ Fintype.card K ^ L := Nat.pow_le_pow_right (by omega) hL
  omega

/-- **The improved bound is sharp at order one**: the order-one enumeration
`q² - q + 1` is exactly `q^{2·1} - q^1 + 1`. -/
theorem card_lfsrWords_one_eq_zero_seed_bound (F : Type*) [Field F] [Fintype F] [DecidableEq F]
    (n : ℕ) (hn : 2 ≤ n) :
    (lfsrWords F 1 n).card = Fintype.card F ^ (2 * 1) - Fintype.card F ^ 1 + 1 := by
  have h := card_lfsrWords_one F n hn
  obtain ⟨m, hm⟩ : ∃ m, Fintype.card F = m + 1 :=
    ⟨Fintype.card F - 1, by have := Fintype.card_pos (α := F); omega⟩
  have e1 : (m + 1) * (m + 1) = (m + 1) * m + (m + 1) := by ring
  rw [h, hm, pow_one, show 2 * 1 = 2 from rfl, pow_two, e1]
  simp

end Catalog.Probability.SeedRec