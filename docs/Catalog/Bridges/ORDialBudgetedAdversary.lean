import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialClassification
import Bridges.ORDialWashoutInvariance
import Bridges.ORDialWashoutParity

/-!
# The budgeted multiplier adversary: the surviving dial is governed by the 2-part

`Bridges.ORDialWashoutParity` reduces the survival of a maximal OR channel under
multiplier randomisation to a parity condition: an `H`-invariant profile can attain the cap
`orCap` iff `[G : H]` is even (`washout_iff_even_index`).  This file answers the
optimisation question that criterion opens (direction 5 of the previous cycle's
`FUTURE_DIRECTIONS.md`):

> an adversary may randomise the sampler's multiplier over **any** subgroup `H` of the
> class group subject to a budget `Nat.card H ≤ B`; for which class groups does a maximal
> dial channel survive every such attack?

The answer is purely arithmetic and involves only the `2`-part of the class group:

* `odd_index_iff_twoPart_dvd`: `[G : H]` is odd **iff** the full `2`-part
  `twoPartCard G = 2 ^ v₂(|G|)` divides `|H|` (i.e. iff `H` contains a Sylow `2`-subgroup
  worth of `2`-power order);
* `even_index_forall_iff_lt_twoPart`: every subgroup of order at most `B` has even index
  **iff** `B < twoPartCard G`;
* `budgeted_dial_survives` / `budgeted_dial_breaks`: hence the dial survives every
  `B`-budgeted randomising adversary exactly when `B < 2 ^ v₂(|G|)`, and as soon as the
  budget reaches the `2`-part a single subgroup — a Sylow `2`-subgroup — drives *every*
  profile strictly below the cap;
* `budgeted_dial_dichotomy` packages the two halves as an iff, and
  `budget_criterion_units_zmod` reads it off on the arithmetic class group `(ℤ/p)ˣ`.

The design rule this proves is the one the experiment's fixed-`k` ladder needs: the usable
window is set by the *`2`-part* of the class group, not by its size — a class group of
order `2 · m` with `m` odd is broken by a budget of `2`, however large `m` is.
-/

open Real Finset

namespace ORDial

/-! ## Part I. The `2`-part of a finite group and odd-index subgroups -/

/-- The order of a Sylow `2`-subgroup of `G`, i.e. `2 ^ v₂(|G|)`. -/
noncomputable def twoPartCard (G : Type*) [Group G] : ℕ := 2 ^ ((Nat.card G).factorization 2)

lemma twoPartCard_pos (G : Type*) [Group G] : 0 < twoPartCard G :=
  pow_pos (by norm_num) _

/-- **Odd index is exactly containment of the full `2`-part.**  A subgroup of a finite
group has odd index iff its order is divisible by `2 ^ v₂(|G|)`. -/
theorem odd_index_iff_twoPart_dvd {G : Type*} [Group G] [Finite G] (H : Subgroup G) :
    Odd H.index ↔ twoPartCard G ∣ Nat.card H := by
  have ha : Nat.card H ≠ 0 := Nat.card_pos.ne'
  have hb : H.index ≠ 0 := Subgroup.index_ne_zero_of_finite
  have hprod : Nat.card H * H.index = Nat.card G := Subgroup.card_mul_index H
  have hfac : (Nat.card G).factorization 2
      = (Nat.card H).factorization 2 + H.index.factorization 2 := by
    rw [← hprod, Nat.factorization_mul ha hb]
    simp
  rw [twoPartCard, Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two ha, hfac]
  constructor
  · intro hodd
    have hnd : ¬ (2 ∣ H.index) := by
      have := Nat.odd_iff.mp hodd
      omega
    have h0 : H.index.factorization 2 = 0 :=
      (Nat.factorization_eq_zero_iff H.index 2).mpr (Or.inr (Or.inl hnd))
    omega
  · intro hle
    have h0 : H.index.factorization 2 = 0 := by omega
    have hnd : ¬ (2 ∣ H.index) := by
      intro hdvd
      have : 1 ≤ H.index.factorization 2 :=
        (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hb).mp (by simpa using hdvd)
      omega
    exact Nat.odd_iff.mpr (by omega)

/-- A Sylow `2`-subgroup exists: some subgroup has order exactly `twoPartCard G`. -/
theorem exists_subgroup_card_twoPart (G : Type*) [Group G] [Finite G] :
    ∃ H : Subgroup G, Nat.card H = twoPartCard G := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  exact Sylow.exists_subgroup_card_pow_prime (G := G) 2 (Nat.ordProj_dvd _ _)

/-- **The budget criterion.**  Every subgroup of order at most `B` has even index iff the
budget stays strictly below the `2`-part of the group order. -/
theorem even_index_forall_iff_lt_twoPart {G : Type*} [Group G] [Finite G] (B : ℕ) :
    (∀ H : Subgroup G, Nat.card H ≤ B → Even H.index) ↔ B < twoPartCard G := by
  constructor
  · intro h
    by_contra hB
    push_neg at hB
    obtain ⟨H, hH⟩ := exists_subgroup_card_twoPart G
    have hodd : Odd H.index := (odd_index_iff_twoPart_dvd H).mpr (by rw [hH])
    exact (Nat.not_even_iff_odd.mpr hodd) (h H (by rw [hH]; exact hB))
  · intro hB H hH
    rw [← Nat.not_odd_iff_even]
    intro hodd
    obtain ⟨c, hc⟩ := (odd_index_iff_twoPart_dvd H).mp hodd
    have hcpos : 0 < c := by
      rcases Nat.eq_zero_or_pos c with rfl | hc'
      · exact absurd (by simpa using hc) (Nat.card_pos (α := H)).ne'
      · exact hc'
    have : twoPartCard G ≤ Nat.card H := by
      rw [hc]
      exact Nat.le_mul_of_pos_right _ hcpos
    omega

/-! ## Part II. The dial under a budgeted adversary -/

section Dial

variable {G : Type*} [Fintype G] [CommGroup G]

/-- **A dial channel survives every `B`-budgeted adversary when `B` is below the
`2`-part.**  For any multiplier group `H` of order at most `B` there is a class-rate
profile, invariant under `H`, sitting exactly at the cap. -/
theorem budgeted_dial_survives {B : ℕ} (hB : B < twoPartCard G) (H : Subgroup G)
    (hH : Nat.card H ≤ B) :
    ∃ s : G → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧ InvariantUnder H s ∧ orInfo s = orCap :=
  (washout_iff_even_index H).mpr
    ((even_index_forall_iff_lt_twoPart B).mpr hB H hH)

/-- **At budget equal to the `2`-part the channel is gone.**  A Sylow `2`-subgroup fits in
the budget and its randomisation drives *every* profile strictly below the cap, while
leaving the mean class rate — the count statistic — untouched. -/
theorem budgeted_dial_breaks {B : ℕ} (hB : twoPartCard G ≤ B) :
    ∃ H : Subgroup G, Nat.card H ≤ B ∧
      (∀ s : G → ℝ, (∀ a, 0 ≤ s a) → (∀ a, s a ≤ 1) →
        orInfo (mix H s) < orCap ∧ avg (mix H s) = avg s) := by
  obtain ⟨H, hH⟩ := exists_subgroup_card_twoPart G
  refine ⟨H, by rw [hH]; exact hB, fun s hs0 hs1 => ⟨?_, avg_mix H s⟩⟩
  exact orInfo_mix_lt_orCap ((odd_index_iff_twoPart_dvd H).mpr (by rw [hH])) hs0 hs1

/-- **The budgeted dichotomy.**  A maximal OR channel survives every multiplier group of
order at most `B` **iff** `B < 2 ^ v₂(|G|)`: the design rule is a condition on the `2`-part
of the class group alone. -/
theorem budgeted_dial_dichotomy (B : ℕ) :
    (∀ H : Subgroup G, Nat.card H ≤ B →
        ∃ s : G → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧ InvariantUnder H s ∧ orInfo s = orCap)
      ↔ B < twoPartCard G := by
  constructor
  · intro h
    refine (even_index_forall_iff_lt_twoPart B).mp (fun H hH => ?_)
    exact (washout_iff_even_index H).mp (h H hH)
  · intro hB H hH
    exact budgeted_dial_survives hB H hH

/-- Size alone is no defence: a class group whose order is twice an odd number is broken by
a budget of `2`, however large the group is. -/
theorem budget_two_breaks_two_mul_odd (m : ℕ) (hm : ¬ (2 ∣ m))
    (hcard : Nat.card G = 2 * m) :
    ∃ H : Subgroup G, Nat.card H ≤ 2 ∧
      (∀ s : G → ℝ, (∀ a, 0 ≤ s a) → (∀ a, s a ≤ 1) →
        orInfo (mix H s) < orCap ∧ avg (mix H s) = avg s) := by
  refine budgeted_dial_breaks (B := 2) ?_
  have hm0 : m ≠ 0 := by rintro rfl; simp at hm
  have : (Nat.card G).factorization 2 = 1 := by
    rw [hcard, Nat.factorization_mul (by norm_num) hm0]
    simp [Nat.Prime.factorization_self Nat.prime_two,
      (Nat.factorization_eq_zero_iff m 2).mpr (Or.inr (Or.inl hm))]
  rw [twoPartCard, this, pow_one]

end Dial

/-! ## Part III. The arithmetic class group `(ℤ/p)ˣ` -/

/-- On `(ℤ/p)ˣ` (order `p - 1`) the surviving-budget threshold is the `2`-part of `p - 1`:
below it every budgeted adversary leaves a maximal channel, at or above it a single
multiplier group destroys the dial for every profile. -/
theorem budget_criterion_units_zmod (p : ℕ) [Fact p.Prime] (B : ℕ) :
    ((∀ H : Subgroup (ZMod p)ˣ, Nat.card H ≤ B →
        ∃ s : (ZMod p)ˣ → ℝ, (∀ a, 0 ≤ s a) ∧ (∀ a, s a ≤ 1) ∧
          InvariantUnder H s ∧ orInfo s = orCap)
      ↔ B < twoPartCard (ZMod p)ˣ) := budgeted_dial_dichotomy B

end ORDial