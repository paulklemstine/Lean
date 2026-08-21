/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: Erdős–Szekeres counting ↔ Erdős' probabilistic bound — a two-sided Ramsey sandwich

`Bridges/ErdosProbabilisticRamsey.lean` supplies the *lower* bound `R(k,k) > 2^{k/2}` by a
counting (de-randomised probabilistic) argument.  This file supplies the matching *upper* bound
by the Erdős–Szekeres neighbourhood recursion, and combines the two into a single two-sided
statement.

## Main results

* `exists_clique_or_indep` : the **Erdős–Szekeres theorem** in Finset form — inside any vertex
  set `W` with `#W ≥ (s+t).choose s`, every graph has an `(s+1)`-clique or an `(t+1)`-independent
  set.  Proved by the double induction on `(s,t)` via the neighbourhood/non-neighbourhood split
  of a single vertex.
* `isRamsey_choose` : hence `(2(k-1)).choose (k-1)` has the diagonal Ramsey property for `k`.
* `central_choose_le_four_pow` : `(2m).choose m ≤ 4 ^ m`.
* `ramsey_sandwich` : for `k ≥ 3` and any `n` with `n ^ 2 ≤ 2 ^ k` there is an `m` with the
  diagonal Ramsey property such that `n < m ≤ 4 ^ (k-1)`; i.e. `2^{k/2} < R(k,k) ≤ 4^{k-1}`.

## Catalog connections
* `Bridges/ErdosProbabilisticRamsey.lean` : the probabilistic lower bound consumed here.
-/
import Mathlib
import Bridges.ErdosProbabilisticRamsey

open Finset SimpleGraph

namespace RamseySandwich

variable {V : Type*} [DecidableEq V]

/-- **Erdős–Szekeres.**  If a vertex set `W` has at least `(s+t).choose s` elements, then any
graph either has an `(s+1)`-clique inside `W`, or an independent set of size `t+1` inside `W`.

The proof is the classical neighbourhood recursion: pick `v ∈ W`, split `W \ {v}` into the
neighbours `N` and non-neighbours `M` of `v`; one of them is large enough for the inductive
hypothesis, and `v` extends the clique (resp. independent set) found there. -/
theorem exists_clique_or_indep (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∀ (s t : ℕ) (W : Finset V), (s + t).choose s ≤ #W →
      ∃ S ⊆ W, G.IsNClique (s + 1) S ∨ Gᶜ.IsNClique (t + 1) S := by
  intro s
  induction s with
  | zero =>
    intro t W hW
    simp only [Nat.zero_add, Nat.choose_zero_right] at hW
    obtain ⟨v, hv⟩ := Finset.card_pos.1 (lt_of_lt_of_le Nat.zero_lt_one hW)
    exact ⟨{v}, by simpa using hv, Or.inl ⟨by simp, by simp⟩⟩
  | succ s ihs =>
    intro t
    induction t with
    | zero =>
      intro W hW
      simp only [Nat.add_zero, Nat.choose_self] at hW
      obtain ⟨v, hv⟩ := Finset.card_pos.1 (lt_of_lt_of_le Nat.zero_lt_one hW)
      exact ⟨{v}, by simpa using hv, Or.inr ⟨by simp, by simp⟩⟩
    | succ t iht =>
      intro W hW
      classical
      -- Pascal's rule for the two branches of the recursion
      have hbin : (s + 1 + (t + 1)).choose (s + 1)
          = (s + (t + 1)).choose s + (s + 1 + t).choose (s + 1) := by
        have h1 : s + 1 + (t + 1) = (s + t + 1) + 1 := by ring
        have h2 : s + (t + 1) = s + t + 1 := by ring
        have h3 : s + 1 + t = s + t + 1 := by ring
        rw [h1, h2, h3, Nat.choose_succ_succ]
      have hpos : 0 < #W :=
        lt_of_lt_of_le (Nat.choose_pos (by omega)) hW
      obtain ⟨v, hv⟩ := Finset.card_pos.1 hpos
      set N : Finset V := (W.erase v).filter (fun u => G.Adj v u) with hN
      set M : Finset V := (W.erase v).filter (fun u => ¬ G.Adj v u) with hM
      have hsplit : #N + #M = #(W.erase v) := by
        rw [hN, hM]
        exact Finset.card_filter_add_card_filter_not _
      have herase : #(W.erase v) = #W - 1 := Finset.card_erase_of_mem hv
      have hchoice : (s + (t + 1)).choose s ≤ #N ∨ (s + 1 + t).choose (s + 1) ≤ #M := by
        by_contra hcon
        push_neg at hcon
        omega
      have hNsub : N ⊆ W := fun u hu => Finset.mem_of_mem_erase (Finset.mem_filter.1 hu).1
      have hMsub : M ⊆ W := fun u hu => Finset.mem_of_mem_erase (Finset.mem_filter.1 hu).1
      rcases hchoice with hcase | hcase
      · obtain ⟨S, hSsub, hS⟩ := ihs (t + 1) N hcase
        rcases hS with hS | hS
        · -- extend the clique by `v`
          have hvS : v ∉ S := by
            intro hmem
            have := hSsub hmem
            rw [hN, Finset.mem_filter] at this
            exact (Finset.notMem_erase v W) this.1
          have hadj : ∀ b ∈ S, G.Adj v b := by
            intro b hb
            have := hSsub hb
            rw [hN, Finset.mem_filter] at this
            exact this.2
          refine ⟨insert v S, ?_, Or.inl (hS.insert hadj)⟩
          exact Finset.insert_subset hv (hSsub.trans hNsub)
        · exact ⟨S, hSsub.trans hNsub, Or.inr hS⟩
      · obtain ⟨S, hSsub, hS⟩ := iht M hcase
        rcases hS with hS | hS
        · exact ⟨S, hSsub.trans hMsub, Or.inl hS⟩
        · -- extend the independent set by `v`
          have hadj : ∀ b ∈ S, Gᶜ.Adj v b := by
            intro b hb
            have hbM := hSsub hb
            rw [hM, Finset.mem_filter] at hbM
            have hne : v ≠ b := fun h => (Finset.notMem_erase v W) (h ▸ hbM.1)
            exact ⟨hne, hbM.2⟩
          refine ⟨insert v S, ?_, Or.inr (hS.insert hadj)⟩
          exact Finset.insert_subset hv (hSsub.trans hMsub)

/-- The diagonal Erdős–Szekeres bound: `(2(k-1)).choose (k-1)` vertices force a monochromatic
`K_k` in any two-colouring. -/
theorem isRamsey_choose (k : ℕ) (hk : 1 ≤ k) :
    ErdosProbabilisticRamsey.IsRamsey ((k - 1 + (k - 1)).choose (k - 1)) k := by
  classical
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  intro G hG
  obtain ⟨S, -, hS⟩ :=
    exists_clique_or_indep G j j (univ : Finset (Fin ((j + j).choose j))) (by simp)
  rcases hS with hS | hS
  · exact hG.1 S hS
  · exact hG.2 S hS

/-- `(2m).choose m ≤ 4 ^ m`: the central binomial coefficient is at most `4 ^ m`. -/
theorem central_choose_le_four_pow (m : ℕ) : (m + m).choose m ≤ 4 ^ m := by
  have hmem : m ∈ Finset.range (m + m + 1) := Finset.mem_range.2 (by omega)
  have hle : (m + m).choose m ≤ ∑ i ∈ Finset.range (m + m + 1), (m + m).choose i :=
    Finset.single_le_sum (f := fun i => (m + m).choose i) (fun i _ => Nat.zero_le _) hmem
  rw [Nat.sum_range_choose] at hle
  calc (m + m).choose m ≤ 2 ^ (m + m) := hle
    _ = 4 ^ m := by rw [← two_mul, pow_mul]; norm_num

/-- **The Ramsey sandwich.**  For `k ≥ 3`, every `n` with `n ^ 2 ≤ 2 ^ k` (i.e. `n ≤ 2^{k/2}`)
is strictly below some number `m ≤ 4 ^ (k-1)` which already forces a monochromatic `K_k`:
`2^{k/2} < R(k,k) ≤ 4^{k-1}`.  The lower half is the counting/probabilistic argument, the upper
half the Erdős–Szekeres recursion. -/
theorem ramsey_sandwich {k n : ℕ} (hk : 3 ≤ k) (hn : n ^ 2 ≤ 2 ^ k) :
    ∃ m : ℕ, ErdosProbabilisticRamsey.IsRamsey m k ∧ n < m ∧ m ≤ 4 ^ (k - 1) := by
  refine ⟨(k - 1 + (k - 1)).choose (k - 1), isRamsey_choose k (by omega), ?_, ?_⟩
  · exact ErdosProbabilisticRamsey.lt_of_isRamsey hk hn (isRamsey_choose k (by omega))
  · exact central_choose_le_four_pow (k - 1)

end RamseySandwich