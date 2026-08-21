/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The deletion method for the Ramsey lower bound, as pure counting

`Catalog/Bridges/ErdosProbabilisticRamsey.lean` proves Erdős' bound `R(k,k) > 2^{k/2}` by the
union bound: if `2·C(n,k) < 2^{C(k,2)}` then *some* 2-colouring of `K_n` has **no**
monochromatic `K_k`.

This file formalizes the *deletion method*, the standard refinement of that argument: instead of
asking for a colouring with no bad clique, average to get a colouring with **few** bad cliques,
then delete one vertex from each of them.  The averaging step is again a finite double count
(`sum_card_mono_eq`), and the deletion step is an explicit transversal
(`exists_transversal`) — so the whole argument stays inside the `Finset` framework and produces
an explicit graph.

Main results:

* `exists_transversal` — every finite family of finite sets has a transversal of size at most
  the number of sets (take the minimum of each set).
* `sum_card_mono_eq` — the double count `∑_S #{bad K for S} = ∑_K #{S bad on K}`.
* `exists_colouring_few_mono` — averaging: if `2·C(n,k) < (t+1)·2^{C(k,2)}` then some colouring
  has at most `t` monochromatic `k`-sets.
* `ramsey_deletion` — **the deletion bound**: under the same hypothesis there is a graph on
  `n − t` vertices with `G` and `Gᶜ` both `K_k`-free, i.e. `R(k,k) > n − t`.
* `ramsey_deletion_lt_of_isRamsey` — the same statement phrased through `IsRamsey`.
* `ramsey_union_bound_of_deletion` — the union bound of the previous file is the case `t = 0`,
  so the deletion bound is a genuine strengthening.
-/

import Mathlib
import Bridges.ErdosProbabilisticRamsey

open Finset SimpleGraph
open scoped BigOperators

namespace RamseyDeletion

open ErdosProbabilisticRamsey

variable {n k : ℕ}

/-! ## Step 1: an explicit transversal -/

/-- **Explicit transversal.**  Taking the minimum of every member of a finite family `B` of
finite sets produces a set `T` of size at most `#B` meeting every nonempty member of `B`. -/
lemma exists_transversal {α : Type*} [DecidableEq α] [LinearOrder α] (B : Finset (Finset α)) :
    ∃ T : Finset α, #T ≤ #B ∧ ∀ K ∈ B, K.Nonempty → (K ∩ T).Nonempty := by
  classical
  refine ⟨B.biUnion (fun K => if hK : K.Nonempty then {K.min' hK} else ∅), ?_, ?_⟩
  · refine le_trans Finset.card_biUnion_le ?_
    calc ∑ K ∈ B, #(if hK : K.Nonempty then {K.min' hK} else ∅) ≤ ∑ _K ∈ B, 1 := by
          refine Finset.sum_le_sum ?_
          intro K _
          split <;> simp
      _ = #B := by simp
  · intro K hK hne
    exact ⟨K.min' hne, Finset.mem_inter.2 ⟨K.min'_mem hne,
      Finset.mem_biUnion.2 ⟨K, hK, by simp [hne]⟩⟩⟩

/-! ## Step 2: averaging over all colourings -/

/-- The number of `k`-sets on which the colouring `S` is monochromatic. -/
def monoCount (k : ℕ) (S : Finset (Finset (Fin n))) : ℕ :=
  #((powersetCard k (univ : Finset (Fin n))).filter (fun K => MonoOn S K))

/-- **The double count.**  Summing the number of bad `k`-sets over all colourings is the same as
summing, over all `k`-sets, the number of colourings that are bad on it. -/
lemma sum_card_mono_eq (n k : ℕ) :
    ∑ S ∈ (pairs n).powerset, monoCount k S
      = ∑ K ∈ powersetCard k (univ : Finset (Fin n)), #(badFor K) := by
  classical
  simp only [monoCount, badFor, Finset.card_filter]
  exact Finset.sum_comm

/-- **Averaging.**  If `2·C(n,k) < (t+1)·2^{C(k,2)}` then some colouring of `K_n` has at most `t`
monochromatic `k`-sets.  (`t = 0` is the union bound.) -/
lemma exists_colouring_few_mono (hkn : k ≤ n) {t : ℕ}
    (h : 2 * n.choose k < (t + 1) * 2 ^ (k.choose 2)) :
    ∃ S ⊆ pairs n, monoCount k S ≤ t := by
  classical
  by_contra hcon
  push_neg at hcon
  have hlow : ∀ S ∈ (pairs n).powerset, t + 1 ≤ monoCount k S := by
    intro S hS
    exact hcon S (mem_powerset.1 hS)
  have hsum_low : #((pairs n).powerset) * (t + 1) ≤ ∑ S ∈ (pairs n).powerset, monoCount k S := by
    calc #((pairs n).powerset) * (t + 1)
        = ∑ _S ∈ (pairs n).powerset, (t + 1) := by rw [Finset.sum_const, smul_eq_mul]
      _ ≤ ∑ S ∈ (pairs n).powerset, monoCount k S := Finset.sum_le_sum hlow
  have hsum_high : ∑ S ∈ (pairs n).powerset, monoCount k S
      ≤ n.choose k * (2 * 2 ^ (n.choose 2 - k.choose 2)) := by
    rw [sum_card_mono_eq]
    calc ∑ K ∈ powersetCard k (univ : Finset (Fin n)), #(badFor K)
        ≤ ∑ _K ∈ powersetCard k (univ : Finset (Fin n)), 2 * 2 ^ (n.choose 2 - k.choose 2) := by
          refine Finset.sum_le_sum ?_
          intro K hK
          have hcard : #K = k := (mem_powersetCard.1 hK).2
          simpa [hcard] using card_badFor_le K
      _ = n.choose k * (2 * 2 ^ (n.choose 2 - k.choose 2)) := by
          rw [Finset.sum_const, card_powersetCard, card_univ, Fintype.card_fin, smul_eq_mul]
  have hpow : #((pairs n).powerset) = 2 ^ (n.choose 2) := by
    rw [card_powerset, card_pairs]
  have hchoose : k.choose 2 ≤ n.choose 2 := Nat.choose_le_choose 2 hkn
  have hsplit : 2 ^ (n.choose 2) = 2 ^ (n.choose 2 - k.choose 2) * 2 ^ (k.choose 2) := by
    rw [← pow_add, Nat.sub_add_cancel hchoose]
  rw [hpow] at hsum_low
  have hkey : 2 ^ (n.choose 2 - k.choose 2) * ((t + 1) * 2 ^ (k.choose 2))
      ≤ 2 ^ (n.choose 2 - k.choose 2) * (2 * n.choose k) := by
    calc 2 ^ (n.choose 2 - k.choose 2) * ((t + 1) * 2 ^ (k.choose 2))
        = 2 ^ (n.choose 2) * (t + 1) := by rw [hsplit]; ring
      _ ≤ n.choose k * (2 * 2 ^ (n.choose 2 - k.choose 2)) := le_trans hsum_low hsum_high
      _ = 2 ^ (n.choose 2 - k.choose 2) * (2 * n.choose k) := by ring
  have hpos : 0 < 2 ^ (n.choose 2 - k.choose 2) := Nat.two_pow_pos _
  have := Nat.le_of_mul_le_mul_left hkey hpos
  omega

/-! ## Step 3: clique-freeness of an induced subgraph -/

/-- If no `k`-subset of `W` is monochromatic for `S`, then pulling `graphOf S` back along any
embedding into `W` gives a graph with both it and its complement `K_k`-free. -/
theorem cliqueFree_comap_of_good_on {m : ℕ} {S : Finset (Finset (Fin n))} {W : Finset (Fin n)}
    (f : Fin m ↪ Fin n) (hf : ∀ i, f i ∈ W)
    (hS : ∀ K ⊆ W, #K = k → ¬ MonoOn S K) :
    ((graphOf S).comap f).CliqueFree k ∧ ((graphOf S).comap f)ᶜ.CliqueFree k := by
  classical
  have himage : ∀ T : Finset (Fin m), #T = k → (T.image f) ⊆ W ∧ #(T.image f) = k := by
    intro T hT
    refine ⟨?_, ?_⟩
    · intro v hv
      obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hv
      exact hf i
    · rw [Finset.card_image_of_injective _ f.injective, hT]
  constructor
  · intro T hT
    obtain ⟨hTclique, hTcard⟩ := hT
    obtain ⟨hsub, hcard⟩ := himage T hTcard
    refine hS _ hsub hcard ?_
    left
    intro e he
    rw [mem_pairsIn] at he
    obtain ⟨u, v, huv, rfl⟩ := Finset.card_eq_two.1 he.2
    have hu : u ∈ T.image f := he.1 (by simp)
    have hv : v ∈ T.image f := he.1 (by simp)
    obtain ⟨i, hi, rfl⟩ := Finset.mem_image.1 hu
    obtain ⟨j, hj, rfl⟩ := Finset.mem_image.1 hv
    have hij : i ≠ j := fun hEq => huv (by rw [hEq])
    have hadj := hTclique hi hj hij
    rw [SimpleGraph.comap_adj] at hadj
    exact (graphOf_adj.1 hadj).2
  · intro T hT
    obtain ⟨hTclique, hTcard⟩ := hT
    obtain ⟨hsub, hcard⟩ := himage T hTcard
    refine hS _ hsub hcard ?_
    right
    rw [Finset.disjoint_right]
    intro e he heS
    rw [mem_pairsIn] at he
    obtain ⟨u, v, huv, rfl⟩ := Finset.card_eq_two.1 he.2
    have hu : u ∈ T.image f := he.1 (by simp)
    have hv : v ∈ T.image f := he.1 (by simp)
    obtain ⟨i, hi, rfl⟩ := Finset.mem_image.1 hu
    obtain ⟨j, hj, rfl⟩ := Finset.mem_image.1 hv
    have hij : i ≠ j := fun hEq => huv (by rw [hEq])
    have hadj := hTclique hi hj hij
    rw [SimpleGraph.compl_adj, SimpleGraph.comap_adj] at hadj
    exact hadj.2 (graphOf_adj.2 ⟨huv, heS⟩)

/-! ## Step 4: the deletion bound -/

/-- **The deletion method.**  If `2·C(n,k) < (t+1)·2^{C(k,2)}` and `1 ≤ k ≤ n`, then there is a
2-colouring of the complete graph on `n − t` vertices with no monochromatic `K_k`; that is,
`R(k,k) > n − t`.  Taking `t = 0` recovers the union bound of `ErdosProbabilisticRamsey`, and
taking `t > 0` allows a *larger* `n`, which is precisely the gain of the deletion method. -/
theorem ramsey_deletion (hk : 1 ≤ k) (hkn : k ≤ n) {t : ℕ}
    (h : 2 * n.choose k < (t + 1) * 2 ^ (k.choose 2)) :
    ∃ G : SimpleGraph (Fin (n - t)), G.CliqueFree k ∧ Gᶜ.CliqueFree k := by
  classical
  obtain ⟨S, -, hS⟩ := exists_colouring_few_mono hkn h
  set B := (powersetCard k (univ : Finset (Fin n))).filter (fun K => MonoOn S K) with hB
  obtain ⟨T, hTcard, hTmeet⟩ := exists_transversal B
  set W := (univ : Finset (Fin n)) \ T with hW
  have hWcard : n - t ≤ #W := by
    have h1 : #W = n - #T := by
      rw [hW, Finset.card_univ_diff, Fintype.card_fin]
    have h2 : #T ≤ t := le_trans hTcard hS
    omega
  have hgood : ∀ K ⊆ W, #K = k → ¬ MonoOn S K := by
    intro K hKW hKcard hmono
    have hKB : K ∈ B := by
      rw [hB, mem_filter]
      exact ⟨mem_powersetCard.2 ⟨subset_univ K, hKcard⟩, hmono⟩
    have hKne : K.Nonempty := Finset.card_pos.1 (by omega)
    obtain ⟨v, hv⟩ := hTmeet K hKB hKne
    have hvK : v ∈ K := (Finset.mem_inter.1 hv).1
    have hvT : v ∈ T := (Finset.mem_inter.1 hv).2
    have : v ∈ W := hKW hvK
    rw [hW, Finset.mem_sdiff] at this
    exact this.2 hvT
  obtain ⟨W', hW'sub, hW'card⟩ := Finset.exists_subset_card_eq hWcard
  let e := W'.orderIsoOfFin hW'card
  have hinj : Function.Injective (fun i : Fin (n - t) => (e i : Fin n)) := by
    intro i j hij
    exact e.injective (Subtype.ext hij)
  let f : Fin (n - t) ↪ Fin n := ⟨fun i => (e i : Fin n), hinj⟩
  have hfW : ∀ i, f i ∈ W := fun i => hW'sub (e i).2
  exact ⟨(graphOf S).comap f, cliqueFree_comap_of_good_on (W := W) f hfW hgood⟩

/-- The deletion bound in the `IsRamsey` language: `R(k,k) > n − t`. -/
theorem ramsey_deletion_lt_of_isRamsey {m : ℕ} (hk : 1 ≤ k) (hkn : k ≤ n) {t : ℕ}
    (h : 2 * n.choose k < (t + 1) * 2 ^ (k.choose 2)) (hR : IsRamsey m k) : n - t < m := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨G, hG, hGc⟩ := ramsey_deletion hk hkn h
  exact not_isRamsey_of_le hcon ⟨G, hG, hGc⟩ hR

/-- The union bound of `ErdosProbabilisticRamsey` is the `t = 0` case of the deletion bound. -/
theorem ramsey_union_bound_of_deletion (hk : 1 ≤ k) (hkn : k ≤ n)
    (h : 2 * n.choose k < 2 ^ (k.choose 2)) :
    ∃ G : SimpleGraph (Fin n), G.CliqueFree k ∧ Gᶜ.CliqueFree k := by
  have := ramsey_deletion (t := 0) hk hkn (by simpa using h)
  simpa using this

/-! ## A verified quantitative gain over the union bound -/

/-- At `k = 6` the deletion method strictly beats the union bound as formalized in
`ErdosProbabilisticRamsey`: deleting one vertex from a colouring of `K_19` with at most one
monochromatic `K_6` produces a Ramsey colouring on `18` vertices, whereas the union bound is
already false at `n = 18` (`2·C(18,6) = 37128 ≥ 32768 = 2^{C(6,2)}`). -/
theorem ramsey_six_gt_eighteen :
    ∃ G : SimpleGraph (Fin 18), G.CliqueFree 6 ∧ Gᶜ.CliqueFree 6 := by
  have h := ramsey_deletion (k := 6) (n := 19) (t := 1) (by norm_num) (by norm_num)
    (by norm_num [Nat.choose])
  simpa using h

/-- The union bound is *not* available at `n = 18`, `k = 6`: the counting hypothesis
`2·C(n,k) < 2^{C(k,2)}` fails there.  Together with `ramsey_six_gt_eighteen` this shows the
deletion bound is a strict improvement, not a reformulation. -/
theorem union_bound_fails_at_eighteen : 2 ^ (Nat.choose 6 2) ≤ 2 * Nat.choose 18 6 := by
  norm_num [Nat.choose]

/-- `R(6,6) > 18`, by the deletion method. -/
theorem eighteen_lt_of_isRamsey_six {m : ℕ} (hR : IsRamsey m 6) : 18 < m := by
  by_contra hcon
  push_neg at hcon
  exact not_isRamsey_of_le hcon ramsey_six_gt_eighteen hR

end RamseyDeletion