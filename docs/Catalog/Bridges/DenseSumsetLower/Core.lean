/-
# Dense sets always *contain* large sumsets: the greedy shift core

This file develops the *lower bound* companion to the sharpness constructions of
`Bridges.DeltaDenseSumsetAvoidance` and `Bridges.GAPSumsetAvoidance`.

Those files construct, for each `0 < δ < 1` and large `n`, a set `S ⊆ [n]` with `|S| ≥ δn`
containing **no** sumset `A + B` of two arithmetic progressions of length
`≥ 3 log n / log (1/δ)`.  The natural question raised by such a construction is how far the
constant `3` can be pushed down.  Here we prove an unconditional obstruction: *no*
`δ`-dense set can avoid **all** sumsets `A + B` with `min(|A|,|B|)` of order
`log n / log (1/δ)`.  Every `δ`-dense subset of `[n]` contains a sumset `A + B` with
`|A| = |B| = k` for `k` as large as `(1 - o(1)) log n / log (4/δ)`.

The engine is a *greedy shift* argument, carried out abstractly:

* `DenseSumsetLower.sum_card_filter_shift` — the averaging identity
  `∑_{a ∈ D} #{u ∈ U : u + a ∈ S} = |U| · |S|`, valid whenever the "shift domain" `D`
  contains all differences of `S`;
* `DenseSumsetLower.exists_good_shift` — one greedy step: an unused shift `a` retaining a
  `(|S| - |F|)/|D|` proportion of the current set;
* `DenseSumsetLower.exists_greedy_family` — the iteration, producing `k` distinct shifts;
* `DenseSumsetLower.exists_sumset_of_counting` — the abstract conclusion `A + B ⊆ S`;
* `DenseSumsetLower.exists_sumset_group` — the finite abelian group instance
  (shift domain `univ`, no loss);
* `DenseSumsetLower.exists_sumset_int_Ico` and `DenseSumsetLower.exists_sumset_nat_range` —
  the integer-interval instances (shift domain `(-n, n)`, a factor `2` loss).

Everything here is exact finitary counting: no probability, no asymptotics.
-/
import Mathlib

namespace DenseSumsetLower

open Finset Pointwise

/-! ## The abstract greedy shift argument -/

variable {G : Type*} [AddCommGroup G] [DecidableEq G]

/-- **Averaging identity.**  If the shift domain `D` contains every difference `s - u` of
elements of `S`, then summing, over `a ∈ D`, the number of `u ∈ U ⊆ S` with `u + a ∈ S`
gives exactly `|U| · |S|`. -/
theorem sum_card_filter_shift {S D U : Finset G} (hUS : U ⊆ S)
    (hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D) :
    ∑ a ∈ D, (U.filter (fun u => u + a ∈ S)).card = U.card * S.card := by
  have h1 : ∀ a ∈ D, (U.filter (fun u => u + a ∈ S)).card
      = ∑ u ∈ U, if u + a ∈ S then 1 else 0 := by
    intro a _; rw [Finset.card_filter]
  rw [Finset.sum_congr rfl h1, Finset.sum_comm]
  have key : ∀ u ∈ U, (∑ a ∈ D, if u + a ∈ S then 1 else 0) = S.card := by
    intro u hu
    rw [← Finset.card_filter]
    apply Finset.card_bij (fun a _ => u + a)
    · intro a ha; simpa using (Finset.mem_filter.mp ha).2
    · intro a _ b _ hab; simpa using hab
    · intro s hs
      exact ⟨s - u, Finset.mem_filter.mpr ⟨hD u (hUS hu) s hs, by simpa using hs⟩, by simp⟩
  rw [Finset.sum_congr rfl key]
  simp [Finset.sum_const]

/-- **One greedy step.**  Given a current set `U ⊆ S` and a finite set `F` of already used
shifts with `|F| < |D|`, there is a fresh shift `a ∈ D \ F` for which the surviving set
`{u ∈ U : u + a ∈ S}` has size at least `|U| (|S| - |F|) / |D|`, written here without
subtraction. -/
theorem exists_good_shift {S D U F : Finset G} (hUS : U ⊆ S)
    (hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D) (hFD : F.card < D.card) :
    ∃ a ∈ D, a ∉ F ∧
      U.card * S.card ≤ D.card * (U.filter (fun u => u + a ∈ S)).card + F.card * U.card := by
  classical
  set f : G → ℕ := fun a => (U.filter (fun u => u + a ∈ S)).card with hf
  have hsum : ∑ a ∈ D, f a = U.card * S.card := sum_card_filter_shift hUS hD
  have hne : (D \ F).Nonempty := by
    rw [← Finset.card_pos]
    have := Finset.card_le_card_sdiff_add_card (s := D) (t := F)
    omega
  obtain ⟨a₀, ha₀, hmax⟩ := Finset.exists_max_image (D \ F) f hne
  refine ⟨a₀, (Finset.mem_sdiff.mp ha₀).1, (Finset.mem_sdiff.mp ha₀).2, ?_⟩
  have hsplit : ∑ a ∈ D ∩ F, f a + ∑ a ∈ D \ F, f a = ∑ a ∈ D, f a :=
    Finset.sum_inter_add_sum_diff D F f
  have h2 : ∑ a ∈ D \ F, f a ≤ (D \ F).card * f a₀ := by
    calc ∑ a ∈ D \ F, f a ≤ ∑ _a ∈ D \ F, f a₀ := Finset.sum_le_sum (fun a ha => hmax a ha)
      _ = (D \ F).card * f a₀ := by simp
  have h3 : ∑ a ∈ D ∩ F, f a ≤ F.card * U.card := by
    calc ∑ a ∈ D ∩ F, f a ≤ ∑ _a ∈ D ∩ F, U.card :=
          Finset.sum_le_sum (fun a _ => Finset.card_filter_le _ _)
      _ = (D ∩ F).card * U.card := by simp
      _ ≤ F.card * U.card := Nat.mul_le_mul_right _ (Finset.card_le_card Finset.inter_subset_right)
  have h4 : (D \ F).card ≤ D.card := Finset.card_le_card Finset.sdiff_subset
  calc U.card * S.card = ∑ a ∈ D ∩ F, f a + ∑ a ∈ D \ F, f a := by rw [hsplit, hsum]
    _ ≤ F.card * U.card + D.card * f a₀ :=
        Nat.add_le_add h3 (le_trans h2 (Nat.mul_le_mul_right _ h4))
    _ = D.card * f a₀ + F.card * U.card := by ring

/-- **The greedy iteration.**  After `j ≤ k` steps we have `j` distinct shifts `A ⊆ D` and a
surviving set `U ⊆ S` with `U + A ⊆ S` and `|U| ≥ |S| ((|S| - k)/|D|)^j`. -/
theorem exists_greedy_family {S D : Finset G} (hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D)
    {k : ℕ} (hkS : k ≤ S.card) (hkD : k ≤ D.card) :
    ∀ j ≤ k, ∃ A U : Finset G, A ⊆ D ∧ A.card = j ∧ U ⊆ S ∧
      (∀ a ∈ A, ∀ u ∈ U, u + a ∈ S) ∧
      S.card * (S.card - k) ^ j ≤ U.card * D.card ^ j := by
  intro j
  induction j with
  | zero => intro _; exact ⟨∅, S, by simp, by simp, Finset.Subset.refl S, by simp, by simp⟩
  | succ j ih =>
      intro hj
      obtain ⟨A, U, hAD, hAcard, hUS, hAU, hbound⟩ := ih (Nat.le_of_succ_le hj)
      have hAcd : A.card < D.card := by omega
      obtain ⟨a, haD, haA, hstep⟩ := exists_good_shift hUS hD hAcd
      set U' := U.filter (fun u => u + a ∈ S) with hU'
      refine ⟨insert a A, U', Finset.insert_subset haD hAD, ?_,
        (Finset.filter_subset _ _).trans hUS, ?_, ?_⟩
      · rw [Finset.card_insert_of_notMem haA, hAcard]
      · intro b hb u hu
        rcases Finset.mem_insert.mp hb with rfl | hbA
        · exact (Finset.mem_filter.mp hu).2
        · exact hAU b hbA u (Finset.mem_filter.mp hu).1
      · have hkey : U.card * (S.card - k) ≤ D.card * U'.card := by
          have h1 : U.card * (S.card - k) + A.card * U.card ≤ U.card * S.card := by
            rw [hAcard]
            have hjs : (S.card - k) + j ≤ S.card := by omega
            calc U.card * (S.card - k) + j * U.card = U.card * ((S.card - k) + j) := by ring
              _ ≤ U.card * S.card := Nat.mul_le_mul_left _ hjs
          omega
        calc S.card * (S.card - k) ^ (j + 1)
            = (S.card * (S.card - k) ^ j) * (S.card - k) := by ring
          _ ≤ (U.card * D.card ^ j) * (S.card - k) := Nat.mul_le_mul_right _ hbound
          _ = (U.card * (S.card - k)) * D.card ^ j := by ring
          _ ≤ (D.card * U'.card) * D.card ^ j := Nat.mul_le_mul_right _ hkey
          _ = U'.card * D.card ^ (j + 1) := by ring

/-- **Abstract sumset existence.**  If `D` absorbs all differences of `S` and the counting
condition `k |D|^k ≤ |S| (|S| - k)^k` holds, then `S` contains a sumset `A + B` with
`|A| = |B| = k` and all shifts drawn from `D`. -/
theorem exists_sumset_of_counting {S D : Finset G} (hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D)
    {k : ℕ} (hkS : k ≤ S.card) (hkD : k ≤ D.card)
    (hcond : k * D.card ^ k ≤ S.card * (S.card - k) ^ k) :
    ∃ A B : Finset G, A ⊆ D ∧ A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  obtain ⟨A, U, hAD, hAcard, hUS, hAU, hbound⟩ := exists_greedy_family hD hkS hkD k le_rfl
  have hDpos : 0 < D.card ^ k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp
    · exact Nat.pow_pos (by omega)
  have hUk : k ≤ U.card :=
    Nat.le_of_mul_le_mul_right (le_trans hcond hbound) hDpos
  obtain ⟨B, hBU, hBcard⟩ := Finset.exists_subset_card_eq hUk
  refine ⟨A, B, hAD, hAcard, hBcard, ?_⟩
  intro x hx
  obtain ⟨a, ha, b, hb, rfl⟩ := Finset.mem_add.mp hx
  have := hAU a ha b (hBU hb)
  rwa [add_comm] at this

/-! ## Instance 1: finite abelian groups -/

/-- **Every dense subset of a finite abelian group contains a large sumset.**
If `k ≤ |S|` and `k · |G|^k ≤ |S| (|S| - k)^k`, then `S` contains `A + B` with
`|A| = |B| = k`.  For `|S| ≥ δ|G|` this is satisfied as soon as
`k (1/δ)^k ≲ δ |G|`, i.e. for `k` up to `(1 - o(1)) log |G| / log (1/δ)`. -/
theorem exists_sumset_group [Fintype G] {S : Finset G} {k : ℕ} (hkS : k ≤ S.card)
    (hcond : k * (Fintype.card G) ^ k ≤ S.card * (S.card - k) ^ k) :
    ∃ A B : Finset G, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  have hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ (Finset.univ : Finset G) := by
    intro u _ s _; exact Finset.mem_univ _
  have hcard : (Finset.univ : Finset G).card = Fintype.card G := Finset.card_univ
  have hkD : k ≤ (Finset.univ : Finset G).card :=
    le_trans hkS (Finset.card_le_univ S)
  obtain ⟨A, B, _, hA, hB, hAB⟩ :=
    exists_sumset_of_counting hD hkS hkD (by rwa [hcard])
  exact ⟨A, B, hA, hB, hAB⟩

/-! ## Instance 2: integer intervals -/

/-- **Integer interval version.**  A set `S ⊆ [0, n) ⊆ ℤ` satisfying the counting condition
`k (2n)^k ≤ |S| (|S| - k)^k` contains a sumset `A + B` with `|A| = |B| = k` and all elements
of `A` in the window `(-n, n)`. -/
theorem exists_sumset_int_Ico {n : ℕ} {S : Finset ℤ} (hS : S ⊆ Finset.Ico (0 : ℤ) n)
    {k : ℕ} (hkS : k ≤ S.card) (hcond : k * (2 * n) ^ k ≤ S.card * (S.card - k) ^ k) :
    ∃ A B : Finset ℤ, A ⊆ Finset.Ioo (-(n : ℤ)) n ∧ A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  classical
  set D : Finset ℤ := Finset.Ioo (-(n : ℤ)) n with hDdef
  have hDcard : D.card = 2 * n - 1 := by
    rw [hDdef, Int.card_Ioo]
    omega
  have hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D := by
    intro u hu s hs
    have hu' := Finset.mem_Ico.mp (hS hu)
    have hs' := Finset.mem_Ico.mp (hS hs)
    exact Finset.mem_Ioo.mpr ⟨by omega, by omega⟩
  have hSn : S.card ≤ n := by
    have := Finset.card_le_card hS
    rwa [Int.card_Ico, show ((n : ℤ) - 0).toNat = n by omega] at this
  have hkD : k ≤ D.card := by omega
  have hcond' : k * D.card ^ k ≤ S.card * (S.card - k) ^ k := by
    refine le_trans (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left ?_ k)) hcond
    omega
  exact exists_sumset_of_counting hD hkS hkD hcond'

/-- **Natural-number interval version.**  Every `S ⊆ [0, n) ⊆ ℕ` satisfying
`k (2n)^k ≤ |S| (|S| - k)^k` contains a sumset `A + B` of two `k`-element sets of naturals.
This is the finitary lower bound matching the `Θ(log n / log (1/δ))` sharpness
constructions. -/
theorem exists_sumset_nat_range {n : ℕ} {S : Finset ℕ} (hS : S ⊆ Finset.range n)
    {k : ℕ} (hkS : k ≤ S.card) (hcond : k * (2 * n) ^ k ≤ S.card * (S.card - k) ^ k) :
    ∃ A B : Finset ℕ, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  classical
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · exact ⟨∅, ∅, by simp, by simp, by simp⟩
  have hcast : Function.Injective (fun s : ℕ => (s : ℤ)) := fun a b h => by simpa using h
  have hS'card : (S.image (fun s : ℕ => (s : ℤ))).card = S.card :=
    Finset.card_image_of_injective _ hcast
  have hS'sub : S.image (fun s : ℕ => (s : ℤ)) ⊆ Finset.Ico (0 : ℤ) n := by
    intro x hx
    obtain ⟨s, hs, rfl⟩ := Finset.mem_image.mp hx
    have := Finset.mem_range.mp (hS hs)
    exact Finset.mem_Ico.mpr ⟨by positivity, by exact_mod_cast this⟩
  obtain ⟨A, B, _, hAcard, hBcard, hAB⟩ :=
    exists_sumset_int_Ico (k := k) hS'sub (by rwa [hS'card]) (by rwa [hS'card])
  have hAne : A.Nonempty := Finset.card_pos.mp (by omega)
  set t : ℤ := A.min' hAne with ht
  have htA : t ∈ A := A.min'_mem hAne
  have hAt : ∀ a ∈ A, t ≤ a := fun a ha => A.min'_le a ha
  have hmemS' : ∀ a ∈ A, ∀ b ∈ B, a + b ∈ S.image (fun s : ℕ => (s : ℤ)) := by
    intro a ha b hb
    exact hAB (Finset.add_mem_add ha hb)
  have hBt : ∀ b ∈ B, 0 ≤ b + t := by
    intro b hb
    obtain ⟨m, _, hm⟩ := Finset.mem_image.mp
      (show t + b ∈ S.image (fun s : ℕ => (s : ℤ)) from hmemS' t htA b hb)
    omega
  refine ⟨A.image (fun a => (a - t).toNat), B.image (fun b => (b + t).toNat), ?_, ?_, ?_⟩
  · refine (Finset.card_image_of_injOn ?_).trans hAcard
    intro a ha b hb hab
    have h1 := hAt a ha; have h2 := hAt b hb
    simp only at hab
    omega
  · refine (Finset.card_image_of_injOn ?_).trans hBcard
    intro a ha b hb hab
    have h1 := hBt a ha; have h2 := hBt b hb
    simp only at hab
    omega
  · intro x hx
    obtain ⟨p, hp, q, hq, rfl⟩ := Finset.mem_add.mp hx
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hp
    obtain ⟨b, hb, rfl⟩ := Finset.mem_image.mp hq
    obtain ⟨m, hmS, hm⟩ := Finset.mem_image.mp
      (show a + b ∈ S.image (fun s : ℕ => (s : ℤ)) from hmemS' a ha b hb)
    have h1 : t ≤ a := hAt a ha
    have h2 : 0 ≤ b + t := hBt b hb
    have hsum : (a - t).toNat + (b + t).toNat = m := by omega
    rwa [hsum]

end DenseSumsetLower