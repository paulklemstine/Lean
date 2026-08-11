/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A two-sided `k`-Sperner bracket for `La(n, P)` for an arbitrary finite poset `P`

This file generalizes `Catalog/Combinatorics/B3FreeKSperner.lean` from the Boolean lattice
posets `B_d` to **arbitrary finite posets** `P`, and quantifies the sharpening of the
catalog's Mirsky/Sperner bound.

The two ingredients are purely order-theoretic:

* a weak copy of `P` carries every chain of `P` to a chain of sets, so a family of small
  height is automatically weak `P`-free;
* conversely, Szpilrajn's linear-extension theorem embeds `P` into the chain
  `Fin |P|`, so a chain of `|P|` sets always contains a weak copy of `P`.

Feeding the two into Erdős' `k`-Sperner theorem (`card_le_central_layers_of_not_hasChain`)
gives the bracket

`∑ of the (h(P) − 1) largest C(n,i) ≤ La(n, P) ≤ ∑ of the (|P| − 1) largest C(n,i)`,

where `h(P)` is the height of `P`.  Both bounds are exact `k`-Sperner values, and they
coincide exactly when `P` is a chain — in which case `La(n, P)` is determined
(`La_eq_window_of_linearOrder`, `LaStar_eq_window_of_linearOrder`).

## Main results

* `exists_strictMono_fin_card` — Szpilrajn: every finite poset admits a strictly monotone
  map into `Fin |P|`.
* `weakFree_of_not_hasChain_of_chain`, `not_hasChain_of_weakFree_card` — the two directions
  relating `P`-freeness and height.
* `La_le_window_of_card`, `window_le_La_of_chain`, `La_poset_bracket` — the bracket.
* `La_eq_window_of_linearOrder`, `LaStar_eq_window_of_linearOrder` — the exact value of
  `La(n, P)` and `La*(n, P)` for every finite chain `P`.
* `choose_lt_choose_succ`, `sum_window_lt_mul` — the binomial row is strictly increasing
  below the middle, hence the sum of the `k` largest binomial coefficients is *strictly*
  smaller than `k · C(n, ⌊n/2⌋)` as soon as `3 ≤ k ≤ n + 1`.
* `La_boolLat_window_lt_mul` — consequently, for every `d ≥ 2` the new upper bound
  `La_boolLat_le_window` is a strict improvement of the catalog bound `La_boolLat_le`.
-/

import Mathlib
import Bridges.B3FreeFamilies
import Bridges.B3FreeFamiliesBounds
import Bridges.B3FreeFamiliesLevels
import Combinatorics.B3FreeAntichainMonotone
import Combinatorics.B3FreeKSperner

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Chains of a poset versus chains of sets -/

section GeneralPoset

variable {P : Type*} [PartialOrder P] [Fintype P]

omit [DecidableEq α] [Fintype α] [Fintype P] in
/-- A weak copy of `P` turns a chain of `k` elements of `P` into a chain of `k` sets. -/
theorem hasChain_of_weakCopy {F : Finset (Finset α)} {k : ℕ} {ι : P → Finset α}
    (hι : IsWeakCopy ι) (hmem : ∀ p, ι p ∈ F) {c : Fin k → P} (hc : StrictMono c) :
    HasChain F k :=
  ⟨fun i => ι (c i), fun _ _ hij => Finset.lt_iff_ssubset.2 (hι.2 _ _ (hc hij)), fun _ => hmem _⟩

omit [DecidableEq α] [Fintype α] [Fintype P] in
/-- **Height bound, general poset version.**  If `P` has a chain of `k` elements and `F`
has no chain of `k` sets, then `F` is weak `P`-free. -/
theorem weakFree_of_not_hasChain_of_chain {F : Finset (Finset α)} {k : ℕ} {c : Fin k → P}
    (hc : StrictMono c) (h : ¬ HasChain F k) : WeakFree F P := by
  rintro ⟨ι, hι, hmem⟩
  exact h (hasChain_of_weakCopy hι hmem hc)

/-- **Szpilrajn's theorem, quantitative form.**  Every finite poset `P` admits a strictly
monotone map into the chain `Fin |P|`: extend the order linearly and sort. -/
theorem exists_strictMono_fin_card :
    ∃ e : P → Fin (Fintype.card P), Function.Injective e ∧ StrictMono e := by
  classical
  letI : Fintype (LinearExtension P) := (inferInstance : Fintype P)
  have hcard : Fintype.card (LinearExtension P) = Fintype.card P := rfl
  refine ⟨fun p => (monoEquivOfFin (LinearExtension P) hcard).symm (toLinearExtension p),
    fun p q hEq => ?_, ?_⟩
  · exact (monoEquivOfFin (LinearExtension P) hcard).symm.injective hEq
  · intro p q hpq
    have h1 : toLinearExtension p ≤ toLinearExtension q := toLinearExtension.monotone hpq.le
    have h2 : toLinearExtension p ≠ toLinearExtension q := fun hEq => hpq.ne hEq
    exact (OrderIso.lt_iff_lt _).2 (lt_of_le_of_ne h1 h2)

omit [DecidableEq α] [Fintype α] in
/-- **A chain of `|P|` sets contains a weak copy of `P`**, via a linear extension of `P`.
Hence a weak `P`-free family has height at most `|P| − 1`. -/
theorem not_hasChain_of_weakFree_card {F : Finset (Finset α)} (h : WeakFree F P) :
    ¬ HasChain F (Fintype.card P) := by
  rintro ⟨c, hc, hmem⟩
  obtain ⟨e, hinj, he⟩ := exists_strictMono_fin_card (P := P)
  exact h ⟨fun p => c (e p), ⟨hc.injective.comp hinj,
    fun p q hpq => Finset.lt_iff_ssubset.1 (hc (he hpq))⟩, fun p => hmem _⟩

/-! ## The bracket -/

/-- **Upper bound for an arbitrary finite poset.**  `La(n, P)` is at most the sum of the
`|P| − 1` largest binomial coefficients. -/
theorem La_le_window_of_card [Nonempty P] (hP : Fintype.card P - 1 ≤ Fintype.card α + 1) :
    La α P ≤ (layers α (centralStart (Fintype.card α) (Fintype.card P - 1))
      (Fintype.card P - 1)).card := by
  classical
  have hpos : 0 < Fintype.card P := Fintype.card_pos
  refine Finset.sup_le fun F hF => ?_
  rw [Finset.mem_filter] at hF
  refine card_le_central_layers_of_not_hasChain (k := Fintype.card P - 1) hP ?_
  have hEq : Fintype.card P - 1 + 1 = Fintype.card P := by omega
  rw [hEq]
  exact not_hasChain_of_weakFree_card hF.2

omit [Fintype P] in
/-- **Lower bound for an arbitrary finite poset.**  If `P` has a chain of `k + 1` elements,
then `La(n, P)` is at least the sum of the `k` largest binomial coefficients. -/
theorem window_le_La_of_chain {k : ℕ} {c : Fin (k + 1) → P} (hc : StrictMono c) :
    (layers α (centralStart (Fintype.card α) k) k).card ≤ La α P :=
  card_le_La (weakFree_of_not_hasChain_of_chain hc (not_hasChain_layers _ _))

/-- **The `k`-Sperner bracket for a general finite poset.**  Both bounds are exact
`k`-Sperner values; they agree exactly when the height of `P` equals `|P|`, i.e. when `P`
is a chain. -/
theorem La_poset_bracket [Nonempty P] {k : ℕ} {c : Fin (k + 1) → P} (hc : StrictMono c)
    (hP : Fintype.card P - 1 ≤ Fintype.card α + 1) :
    (layers α (centralStart (Fintype.card α) k) k).card ≤ La α P ∧
      La α P ≤ (layers α (centralStart (Fintype.card α) (Fintype.card P - 1))
        (Fintype.card P - 1)).card :=
  ⟨window_le_La_of_chain hc, La_le_window_of_card hP⟩

end GeneralPoset

/-! ## The bracket collapses for chains -/

section Chains

variable {P : Type*} [LinearOrder P] [Fintype P] [Nonempty P]

/-- **The exact extremal number of an arbitrary finite chain.**  For a finite linear order
`P`, `La(n, P)` is the total size of the `|P| − 1` central layers.  This contains
`La_fin_eq` (the case `P = Fin (k+1)`) and, for `|P| = 2`, Sperner's theorem. -/
theorem La_eq_window_of_linearOrder (hP : Fintype.card P - 1 ≤ Fintype.card α + 1) :
    La α P = (layers α (centralStart (Fintype.card α) (Fintype.card P - 1))
      (Fintype.card P - 1)).card := by
  have hpos : 0 < Fintype.card P := Fintype.card_pos
  refine le_antisymm (La_le_window_of_card hP) ?_
  obtain ⟨k, hk⟩ : ∃ k, Fintype.card P = k + 1 := ⟨Fintype.card P - 1, by omega⟩
  have hiso := monoEquivOfFin P hk
  have hmono : StrictMono (fun i : Fin (k + 1) => hiso i) := fun i j hij =>
    (OrderIso.lt_iff_lt _).2 hij
  have := window_le_La_of_chain (α := α) (P := P) hmono
  rw [hk]
  simpa using this

/-- A chain of `k + 1` sets is a strong copy of any chain with `k + 1` elements, so the
strong extremal number of a finite chain agrees with the weak one. -/
theorem LaStar_eq_window_of_linearOrder (hP : Fintype.card P - 1 ≤ Fintype.card α + 1) :
    LaStar α P = (layers α (centralStart (Fintype.card α) (Fintype.card P - 1))
      (Fintype.card P - 1)).card := by
  classical
  have hpos : 0 < Fintype.card P := Fintype.card_pos
  obtain ⟨k, hk⟩ : ∃ k, Fintype.card P = k + 1 := ⟨Fintype.card P - 1, by omega⟩
  have hiso := monoEquivOfFin P hk
  have hmono : StrictMono (fun i : Fin (k + 1) => hiso i) := fun i j hij =>
    (OrderIso.lt_iff_lt _).2 hij
  refine le_antisymm (Finset.sup_le fun F hF => ?_) ?_
  · rw [Finset.mem_filter] at hF
    refine card_le_central_layers_of_not_hasChain (k := Fintype.card P - 1) hP ?_
    have hEq : Fintype.card P - 1 + 1 = Fintype.card P := by omega
    rw [hEq]
    -- a chain of `|P|` sets is even an *induced* copy of the chain `P`
    rintro ⟨c, hc, hmem⟩
    have hc' : StrictMono (fun i : Fin (k + 1) => c (Fin.cast hk.symm i)) := by
      intro i j hij
      exact hc (show (Fin.cast hk.symm i : Fin (Fintype.card P)) < Fin.cast hk.symm j from hij)
    refine hF.2 ⟨fun p => c (Fin.cast hk.symm (hiso.symm p)),
      ⟨hc'.injective.comp hiso.symm.injective,
      fun p q => ⟨fun hlt => ?_, fun hpq =>
        Finset.lt_iff_ssubset.1 (hc' ((OrderIso.lt_iff_lt _).2 hpq))⟩⟩, fun p => hmem _⟩
    rcases lt_trichotomy p q with h1 | h1 | h1
    · exact h1
    · exfalso
      rw [h1] at hlt
      exact (Finset.ssubset_iff_subset_ne.1 hlt).2 rfl
    · exact absurd hlt
        (asymm (Finset.lt_iff_ssubset.1 (hc' ((OrderIso.lt_iff_lt _).2 h1))))
  · have hfree : WeakFree (layers α (centralStart (Fintype.card α) k) k) P :=
      weakFree_of_not_hasChain_of_chain hmono (not_hasChain_layers _ _)
    have := card_le_LaStar (α := α) hfree.strongFree
    rw [hk]
    simpa using this

end Chains

/-! ## The sharpening is strict -/

/-- The binomial row is *strictly* increasing strictly below the middle. -/
theorem choose_lt_choose_succ {n k : ℕ} (h : 2 * k + 1 < n) : n.choose k < n.choose (k + 1) := by
  have hpos : 0 < n.choose k := Nat.choose_pos (by omega)
  have hEq : n.choose (k + 1) * (k + 1) = n.choose k * (n - k) := Nat.choose_succ_right_eq n k
  have h1 : n.choose k * (k + 2) ≤ n.choose k * (n - k) :=
    Nat.mul_le_mul_left _ (by omega)
  by_contra hcon
  push_neg at hcon
  have h2 : n.choose (k + 1) * (k + 1) ≤ n.choose k * (k + 1) :=
    Nat.mul_le_mul hcon (le_refl (k + 1))
  nlinarith [hEq, h1, h2, hpos]

omit [DecidableEq α] in
/-- **The sharpening is strict.**  For `3 ≤ k ≤ n + 1` the sum of the `k` largest binomial
coefficients is strictly smaller than `k · C(n, ⌊n/2⌋)`; the difference is at least
`C(n, ⌊n/2⌋) − C(n, a)` for the bottom level `a` of the central window. -/
theorem sum_window_lt_mul {k : ℕ} (hk3 : 3 ≤ k) (hk : k ≤ Fintype.card α + 1) :
    ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) k) (centralStart (Fintype.card α) k + k),
        (Fintype.card α).choose i < k * (Fintype.card α).choose (Fintype.card α / 2) := by
  classical
  set n := Fintype.card α with hn
  set a := centralStart n k with ha
  have ha2 : 2 * a + k ≤ n + 1 := by simp only [ha, centralStart]; omega
  have hstrict : n.choose a < n.choose (n / 2) :=
    lt_of_lt_of_le (choose_lt_choose_succ (by omega)) (Nat.choose_le_middle _ _)
  have hsplit : ∑ i ∈ Finset.Ico a (a + k), n.choose i
      = n.choose a + ∑ i ∈ Finset.Ico (a + 1) (a + k), n.choose i :=
    Finset.sum_eq_sum_Ico_succ_bot (by omega) _
  have hrest : ∑ i ∈ Finset.Ico (a + 1) (a + k), n.choose i ≤ (k - 1) * n.choose (n / 2) := by
    calc ∑ i ∈ Finset.Ico (a + 1) (a + k), n.choose i
        ≤ ∑ _i ∈ Finset.Ico (a + 1) (a + k), n.choose (n / 2) :=
          Finset.sum_le_sum fun i _ => Nat.choose_le_middle i n
      _ = (k - 1) * n.choose (n / 2) := by
          rw [Finset.sum_const, Nat.card_Ico, smul_eq_mul]
          congr 1
          omega
  have hk1 : (k - 1) * n.choose (n / 2) + n.choose (n / 2) = k * n.choose (n / 2) := by
    have hk1' : k - 1 + 1 = k := by omega
    calc (k - 1) * n.choose (n / 2) + n.choose (n / 2) = (k - 1 + 1) * n.choose (n / 2) := by ring
      _ = k * n.choose (n / 2) := by rw [hk1']
  calc ∑ i ∈ Finset.Ico a (a + k), n.choose i
      = n.choose a + ∑ i ∈ Finset.Ico (a + 1) (a + k), n.choose i := hsplit
    _ < n.choose (n / 2) + (k - 1) * n.choose (n / 2) := by omega
    _ = k * n.choose (n / 2) := by omega

/-- **The new upper bound strictly improves the catalog bound.**  For every `d ≥ 2` with
`2^d − 1 ≤ n + 1`, the `k`-Sperner bound of `La_boolLat_le_window` is strictly smaller than
the Mirsky/Sperner bound `(2^d − 1)·C(n, ⌊n/2⌋)` of `La_boolLat_le`. -/
theorem La_boolLat_window_lt_mul {d : ℕ} (hd2 : 2 ≤ d) (hd : 2 ^ d - 1 ≤ Fintype.card α + 1) :
    (layers α (centralStart (Fintype.card α) (2 ^ d - 1)) (2 ^ d - 1)).card
      < (2 ^ d - 1) * (Fintype.card α).choose (Fintype.card α / 2) := by
  have h4 : 4 ≤ 2 ^ d := by
    calc (4 : ℕ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ d := Nat.pow_le_pow_right (by norm_num) hd2
  rw [card_layers]
  exact sum_window_lt_mul (by omega) hd

/-- For the poset `B_3` of the paper this reads: on a ground set of size at least `6`, the
new bound beats the catalog bound `La(n, B_3) ≤ 7·C(n, ⌊n/2⌋)`. -/
theorem La_boolLat3_window_lt_mul (h : 6 ≤ Fintype.card α) :
    (layers α (centralStart (Fintype.card α) 7) 7).card
      < 7 * (Fintype.card α).choose (Fintype.card α / 2) := by
  have := La_boolLat_window_lt_mul (α := α) (d := 3) (by norm_num) (by norm_num; omega)
  norm_num at this
  exact this

end B3Free