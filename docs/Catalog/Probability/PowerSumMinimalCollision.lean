/-
# The minimal collision size `m(N, K)` of the finite moment problem

`Probability.PowerSumSharpness` and `Probability.PowerSumNewtonThreshold` establish the two
rigidity mechanisms for the finite moment problem on `{0, …, N}` (Vandermonde in the alphabet,
Newton in the size) together with sharpness witnesses.  This file turns those scattered bounds
into a *single numerical invariant* and computes it exactly in the cases that the previous
files bound from both sides.

For an alphabet bound `N` and an agreement order `K`, a **collision** is a pair of different
data sets `s ≠ t` of naturals bounded by `N` whose power sums agree for all orders `k ≤ K`.
Define

  `m(N, K) = minCollisionCard N K = sInf { card s | s, t is a collision }`.

Main results.

* `collisionSizes_eq_empty_of_le` / `minCollisionCard_eq_zero_iff` — collisions exist exactly
  when `K < N`, so `m(N, K) = 0` (the junk value of `sInf ∅`) precisely in the rigid regime.
* `lt_minCollisionCard` — the Prouhet–Tarry–Escott bound `K < m(N, K)` in the non-rigid regime.
* `minCollisionCard_antitone_alphabet` — `m(·, K)` is non-increasing in the alphabet: widening
  the alphabet can only make collisions cheaper.
* `minCollisionCard_critical` — **at the critical window `K = N − 1` the invariant is
  exactly `2^(N−1)`**, the largest value it can take.
* `minCollisionCard_one`, `minCollisionCard_two`, `minCollisionCard_three` — off the critical
  window the invariant collapses to the PTE floor `K + 1`: `m(N,1) = 2` for `N ≥ 2`,
  `m(N,2) = 3` for `N ≥ 4` and `m(N,3) = 4` for `N ≥ 11`.
* `minCollisionCard_strict_drop`, `minCollisionCard_two_table` — the exact drop profile at
  `K = 2`: `m(2,2) = 0`, `m(3,2) = 4`, `m(N,2) = 3` for all `N ≥ 4`.  This settles the
  `K = 2` case of sub-conjecture **S1** of `FUTURE_DIRECTIONS.md`.
* `isCollision_sub_of_isCollision`, `exists_disjoint_minimal_collision` — a collision of least
  size can always be taken *disjoint*: deleting the common part `s ∩ t` preserves agreement in
  every order and can only shrink the data sets.
-/
import Mathlib
import Probability.PowerSumSharpness
import Probability.PowerSumNewtonThreshold

namespace PowerSumMinCollision

open Multiset

/-! ## 1. Collisions and the invariant `m(N, K)` -/

/-- `IsCollision N K s t` says: `s` and `t` are different data sets of naturals bounded by `N`
whose power sums agree in all orders `k ≤ K`. -/
def IsCollision (N K : ℕ) (s t : Multiset ℕ) : Prop :=
  (∀ x ∈ s, x ≤ N) ∧ (∀ x ∈ t, x ≤ N) ∧
    (∀ k ≤ K, (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum) ∧ s ≠ t

/-- The set of sizes of collisions with parameters `(N, K)`. -/
def collisionSizes (N K : ℕ) : Set ℕ :=
  {n | ∃ s t : Multiset ℕ, IsCollision N K s t ∧ Multiset.card s = n}

/-- `m(N, K)`: the least size of a collision over the alphabet `{0, …, N}` at agreement
order `K`.  By convention (`sInf ∅ = 0` in `ℕ`) it is `0` when no collision exists, which by
`minCollisionCard_eq_zero_iff` happens exactly in the rigid regime `N ≤ K`. -/
noncomputable def minCollisionCard (N K : ℕ) : ℕ := sInf (collisionSizes N K)

/-! ## 2. Existence and non-existence of collisions -/

/-- In the rigid regime `N ≤ K` there are no collisions at all: this is the Vandermonde
rigidity theorem `PowerSumSharpness.multiset_determined_by_powerSums`. -/
theorem collisionSizes_eq_empty_of_le {N K : ℕ} (hK : N ≤ K) : collisionSizes N K = ∅ := by
  ext n
  simp only [Set.mem_empty_iff_false, iff_false]
  rintro ⟨s, t, ⟨hs, ht, hagree, hne⟩, -⟩
  exact hne (PowerSumSharpness.multiset_determined_by_powerSums hs ht
    fun k hk => hagree k (le_trans hk hK))

/-- Below the critical order there *are* collisions: the even and odd halves of the binomial
weights, of size `2^(N-1)`. -/
theorem collisionSizes_nonempty {N K : ℕ} (hK : K < N) : (collisionSizes N K).Nonempty := by
  obtain ⟨he, ho, hagree, hne, hcard⟩ :=
    PowerSumSharpness.collision_card_bound_sharp (N := N) (by omega)
  exact ⟨2 ^ (N - 1), PowerSumSharpness.evenMultiset N, PowerSumSharpness.oddMultiset N,
    ⟨he, ho, fun k hk => hagree k (by omega), hne⟩, hcard⟩

/-- A collision size is realised by an actual collision (in the non-rigid regime). -/
theorem exists_minimal_collision {N K : ℕ} (hK : K < N) :
    ∃ s t : Multiset ℕ, IsCollision N K s t ∧ Multiset.card s = minCollisionCard N K :=
  Nat.sInf_mem (collisionSizes_nonempty hK)

/-! ## 3. General bounds on `m(N, K)` -/

/-- **The Prouhet–Tarry–Escott floor.**  Every collision at agreement order `K` has more than
`K` elements, hence `K < m(N, K)` whenever a collision exists. -/
theorem lt_minCollisionCard {N K : ℕ} (hK : K < N) : K < minCollisionCard N K := by
  obtain ⟨s, t, ⟨-, -, hagree, hne⟩, hcard⟩ := exists_minimal_collision hK
  have := PowerSumNewton.collision_card_gt_degree hagree hne
  omega

/-- `m(N, K) = 0` exactly in the rigid regime. -/
theorem minCollisionCard_eq_zero_iff {N K : ℕ} : minCollisionCard N K = 0 ↔ N ≤ K := by
  constructor
  · intro h
    by_contra hcon
    have := lt_minCollisionCard (N := N) (K := K) (by omega)
    omega
  · intro hK
    simp [minCollisionCard, collisionSizes_eq_empty_of_le hK, Nat.sInf_empty]

/-- **Widening the alphabet makes collisions cheaper.**  `m(·, K)` is non-increasing in the
alphabet bound, on the range where collisions exist. -/
theorem minCollisionCard_antitone_alphabet {N N' K : ℕ} (hK : K < N) (hNN' : N ≤ N') :
    minCollisionCard N' K ≤ minCollisionCard N K := by
  obtain ⟨s, t, ⟨hs, ht, hagree, hne⟩, hcard⟩ := exists_minimal_collision hK
  refine Nat.sInf_le ⟨s, t, ⟨fun x hx => le_trans (hs x hx) hNN',
    fun x hx => le_trans (ht x hx) hNN', hagree, hne⟩, hcard⟩

/-- An explicit collision bounds `m(N, K)` from above. -/
theorem minCollisionCard_le {N K n : ℕ} {s t : Multiset ℕ} (h : IsCollision N K s t)
    (hcard : Multiset.card s = n) : minCollisionCard N K ≤ n :=
  Nat.sInf_le ⟨s, t, h, hcard⟩

/-- A universal lower bound on collision sizes bounds `m(N, K)` from below. -/
theorem le_minCollisionCard {N K n : ℕ} (hK : K < N)
    (h : ∀ s t : Multiset ℕ, IsCollision N K s t → n ≤ Multiset.card s) :
    n ≤ minCollisionCard N K := by
  obtain ⟨s, t, hcol, hcard⟩ := exists_minimal_collision hK
  exact hcard ▸ h s t hcol

/-! ## 4. The critical window `K = N - 1`: the invariant is exactly `2^(N-1)` -/

/-- **The invariant at the critical window.**  For every `N ≥ 1`,
`m(N, N − 1) = 2^(N−1)`: the lower bound is
`PowerSumSharpness.multiset_collision_card_lower_bound` and it is attained by the even/odd
binomial halves (`PowerSumSharpness.collision_card_bound_sharp`). -/
theorem minCollisionCard_critical {N : ℕ} (hN : 1 ≤ N) :
    minCollisionCard N (N - 1) = 2 ^ (N - 1) := by
  refine le_antisymm ?_ ?_
  · obtain ⟨he, ho, hagree, hne, hcard⟩ :=
      PowerSumSharpness.collision_card_bound_sharp (N := N) hN
    exact minCollisionCard_le
      (s := PowerSumSharpness.evenMultiset N) (t := PowerSumSharpness.oddMultiset N)
      ⟨he, ho, fun k hk => hagree k (by omega), hne⟩ hcard
  · refine le_minCollisionCard (by omega) ?_
    rintro s t ⟨hs, ht, hagree, hne⟩
    exact PowerSumSharpness.multiset_collision_card_lower_bound hN hs ht
      (fun k hk => hagree k (by omega)) hne

/-- `m(2, 1) = 2`, `m(3, 2) = 4`, `m(4, 3) = 8`: the critical values grow like `2^(N-1)`. -/
theorem minCollisionCard_critical_small :
    minCollisionCard 2 1 = 2 ∧ minCollisionCard 3 2 = 4 ∧ minCollisionCard 4 3 = 8 :=
  ⟨minCollisionCard_critical (by norm_num), minCollisionCard_critical (by norm_num),
    minCollisionCard_critical (by norm_num)⟩

/-! ## 5. Off the critical window: the invariant collapses to the floor `K + 1` -/

/-- `m(N, 1) = 2` for every `N ≥ 2`: the witness is the classical pair `{0,2}` vs `{1,1}`. -/
theorem minCollisionCard_one {N : ℕ} (hN : 2 ≤ N) : minCollisionCard N 1 = 2 := by
  refine le_antisymm ?_ ?_
  · obtain ⟨hs, ht, hagree, -, hne⟩ := PowerSumSharpness.multiset_zero_two_ne_one_one
    exact minCollisionCard_le (s := ({0, 2} : Multiset ℕ)) (t := ({1, 1} : Multiset ℕ))
      ⟨fun x hx => le_trans (hs x hx) hN, fun x hx => le_trans (ht x hx) hN, hagree, hne⟩
      (by decide)
  · have := lt_minCollisionCard (N := N) (K := 1) (by omega)
    omega

/-- **`m(N, 2) = 3` for every `N ≥ 4`.**  The lower bound is the PTE floor `K < m(N,K)`; the
witness attaining it is the ideal solution `{0,3,3}` vs `{1,1,4}`
(`PowerSumNewton.ideal_pte_degree_two`). -/
theorem minCollisionCard_two {N : ℕ} (hN : 4 ≤ N) : minCollisionCard N 2 = 3 := by
  refine le_antisymm ?_ ?_
  · obtain ⟨hs, ht, hagree, -, hcard, hne⟩ := PowerSumNewton.ideal_pte_degree_two
    exact minCollisionCard_le (s := ({0, 3, 3} : Multiset ℕ)) (t := ({1, 1, 4} : Multiset ℕ))
      ⟨fun x hx => le_trans (hs x hx) hN, fun x hx => le_trans (ht x hx) hN, hagree, hne⟩ hcard
  · have := lt_minCollisionCard (N := N) (K := 2) (by omega)
    omega

/-- **`m(N, 3) = 4` for every `N ≥ 11`**, attained by the ideal solution `{0,4,7,11}` vs
`{1,2,9,10}` (`PowerSumNewton.ideal_pte_degree_three`). -/
theorem minCollisionCard_three {N : ℕ} (hN : 11 ≤ N) : minCollisionCard N 3 = 4 := by
  refine le_antisymm ?_ ?_
  · obtain ⟨hs, ht, hagree, -, hcard, hne⟩ := PowerSumNewton.ideal_pte_degree_three
    exact minCollisionCard_le
      (s := ({0, 4, 7, 11} : Multiset ℕ)) (t := ({1, 2, 9, 10} : Multiset ℕ))
      ⟨fun x hx => le_trans (hs x hx) hN, fun x hx => le_trans (ht x hx) hN, hagree, hne⟩ hcard
  · have := lt_minCollisionCard (N := N) (K := 3) (by omega)
    omega

/-! ## 6. The drop profile at `K = 2` -/

/-- **The strict drop.**  One extra letter of alphabet strictly cheapens the minimal
collision at agreement order `2`: `m(3,2) = 4 > 3 = m(4,2)`. -/
theorem minCollisionCard_strict_drop :
    minCollisionCard 4 2 < minCollisionCard 3 2 := by
  rw [minCollisionCard_two (by norm_num), minCollisionCard_critical (N := 3) (by norm_num)]
  norm_num

/-- **The complete profile of `m(·, 2)`** (sub-conjecture S1 of `FUTURE_DIRECTIONS.md` for
`K = 2`).  For `N ≤ 2` the problem is rigid and there is no collision; at the critical
alphabet `N = 3` the minimum is `2^2 = 4`; from `N = 4` on it sits at the PTE floor `3`
forever.  In particular the invariant takes no intermediate value. -/
theorem minCollisionCard_two_table (N : ℕ) :
    minCollisionCard N 2 = if N ≤ 2 then 0 else if N = 3 then 4 else 3 := by
  by_cases h : N ≤ 2
  · simp [h, minCollisionCard_eq_zero_iff.mpr h]
  · rcases eq_or_ne N 3 with rfl | h3
    · simpa using minCollisionCard_critical (N := 3) (by norm_num)
    · have h4 : 4 ≤ N := by omega
      simp [h, h3, minCollisionCard_two h4]

/-! ## 7. Minimal collisions are disjoint -/

/-- **Cancelling the common part.**  If `s` and `t` collide, so do `s - t` and `t - s`, and
the latter two share no element.  The common part `s ∩ t` contributes equally to both sides of
every power sum, so deleting it preserves agreement while shrinking the data sets. -/
theorem isCollision_sub_of_isCollision {N K : ℕ} {s t : Multiset ℕ} (h : IsCollision N K s t) :
    IsCollision N K (s - t) (t - s) ∧ (s - t) ∩ (t - s) = 0 := by
  obtain ⟨hs, ht, hagree, hne⟩ := h
  have hsplit : ∀ (u v : Multiset ℕ) (k : ℕ),
      ((u - v).map (fun x => x ^ k)).sum + ((u ∩ v).map (fun x => x ^ k)).sum
        = (u.map (fun x => x ^ k)).sum := by
    intro u v k
    rw [← Multiset.sum_add, ← Multiset.map_add, Multiset.sub_add_inter]
  refine ⟨⟨fun x hx => hs x (Multiset.mem_of_le (Multiset.sub_le_self s t) hx),
      fun x hx => ht x (Multiset.mem_of_le (Multiset.sub_le_self t s) hx), ?_, ?_⟩, ?_⟩
  · intro k hk
    have e1 := hsplit s t k
    have e2 := hsplit t s k
    rw [Multiset.inter_comm s t] at e1
    have e3 := hagree k hk
    omega
  · intro hcon
    refine hne ?_
    calc s = s - t + s ∩ t := (Multiset.sub_add_inter s t).symm
      _ = t - s + t ∩ s := by rw [hcon, Multiset.inter_comm]
      _ = t := Multiset.sub_add_inter t s
  · ext x
    simp only [Multiset.count_inter, Multiset.count_sub, Multiset.count_zero]
    omega

/-- **The minimum is attained by a disjoint pair.**  A collision of least size can always be
chosen with `s ∩ t = 0`: no element occurs on both sides.  Hence `m(N, K)` is also the least
size of a *disjoint* collision, which is the form in which the invariant is computed by the
kernel search of `ComputationalEvidence.md` §12. -/
theorem exists_disjoint_minimal_collision {N K : ℕ} (hK : K < N) :
    ∃ s t : Multiset ℕ, IsCollision N K s t ∧ Multiset.card s = minCollisionCard N K ∧
      s ∩ t = 0 := by
  obtain ⟨s, t, hcol, hcard⟩ := exists_minimal_collision hK
  obtain ⟨hsub, hdisj⟩ := isCollision_sub_of_isCollision hcol
  refine ⟨s - t, t - s, hsub, ?_, hdisj⟩
  have hle : Multiset.card (s - t) ≤ Multiset.card s :=
    Multiset.card_le_card (Multiset.sub_le_self s t)
  have hge : minCollisionCard N K ≤ Multiset.card (s - t) := minCollisionCard_le hsub rfl
  omega

end PowerSumMinCollision