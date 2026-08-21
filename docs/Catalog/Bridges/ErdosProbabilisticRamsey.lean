/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: the probabilistic method as pure counting — Erdős' Ramsey lower bound

Erdős' 1947 theorem `R(k,k) > 2^{k/2}` is the founding application of the probabilistic
method: colour the edges of `K_n` uniformly at random and show that the expected number of
monochromatic `K_k`'s is `< 1`.

This file deliberately **removes all probability** from that argument and replaces it by a
finite *counting* argument over `Finset`s: colourings of `K_n` are the subsets `S` of the set
`pairs n` of two-element subsets of `Fin n` (`S` = the red edges), and the union bound becomes
`Finset.card_biUnion_le`.  Nothing here uses measure theory, real numbers or `Classical.choice`
beyond what `Finset.filter`/decidability already provide, so the existence statement produced
is a genuine finite search: the good colouring is exhibited as an element of an explicitly
described, decidable, nonempty finite set.

## Main results

* `card_filter_superset` / `card_filter_disjoint` : the two elementary "half-space" counts
  `#{S ⊆ E | T ⊆ S} = #{S ⊆ E | S ∩ T = ∅} = 2 ^ (#E - #T)`.
* `card_monochromatic_le` : union bound — at most `n.choose k * (2 * 2 ^ (#pairs - k.choose 2))`
  colourings contain a monochromatic `k`-set.
* `exists_good_colouring` : if `2 * n.choose k < 2 ^ (k.choose 2)` there is a colouring with no
  monochromatic `k`-set.
* `exists_cliqueFree_and_compl_cliqueFree` : the graph-theoretic form — a graph `G` on `Fin n`
  with `G` and `Gᶜ` both `K_k`-free.
* `erdos_ramsey_bound` : the arithmetic engine `2 ^ (k + 2) < (k !)^2` turns the hypothesis
  `n ^ 2 ≤ 2 ^ k` (i.e. `n ≤ 2 ^ (k/2)`) into the counting hypothesis, giving Erdős' theorem.
* `lt_of_isRamsey` : the statement in Ramsey-number form, `R(k,k) > 2^{k/2}`: every `m` for
  which *every* graph on `Fin m` has a monochromatic `K_k` satisfies `n < m` whenever
  `n ^ 2 ≤ 2 ^ k` and `3 ≤ k`.

## Catalog connections
* Ramsey theory (`Bridges/RamseyTheory/*`): supplies the missing *lower* bound side.
* Probabilistic method: the expectation argument, de-randomised into a cardinality inequality.
-/
import Mathlib

open Finset

namespace ErdosProbabilisticRamsey

variable {n k : ℕ}

/-! ## Elementary subset counting -/

section Counting

variable {α : Type*} [DecidableEq α]

/-- The number of subsets of `E` that contain a fixed `T ⊆ E` is `2 ^ (#E - #T)`. -/
lemma card_filter_superset (E T : Finset α) (hT : T ⊆ E) :
    #(E.powerset.filter (fun S => T ⊆ S)) = 2 ^ (#E - #T) := by
  have h : #(E.powerset.filter (fun S => T ⊆ S)) = #((E \ T).powerset) := by
    refine Finset.card_bij' (fun S _ => S \ T) (fun U _ => U ∪ T) ?_ ?_ ?_ ?_
    · intro S hS
      simp only [mem_filter, mem_powerset] at hS
      simp only [mem_powerset]
      exact sdiff_subset_sdiff hS.1 (subset_refl _)
    · intro U hU
      simp only [mem_powerset] at hU
      have hUE : U ⊆ E := hU.trans sdiff_subset
      simp only [mem_filter, mem_powerset]
      exact ⟨union_subset hUE hT, subset_union_right⟩
    · intro S hS
      simp only [mem_filter, mem_powerset] at hS
      exact sdiff_union_of_subset hS.2
    · intro U hU
      simp only [mem_powerset] at hU
      have : Disjoint U T := (subset_sdiff.1 hU).2
      simp [union_sdiff_right, sdiff_eq_self_of_disjoint this]
  have hcard : #(E \ T) = #E - #T := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.2 hT]
  rw [h, card_powerset, hcard]

/-- The number of subsets of `E` disjoint from a fixed `T ⊆ E` is `2 ^ (#E - #T)`. -/
lemma card_filter_disjoint (E T : Finset α) (hT : T ⊆ E) :
    #(E.powerset.filter (fun S => Disjoint S T)) = 2 ^ (#E - #T) := by
  have h : E.powerset.filter (fun S => Disjoint S T) = (E \ T).powerset := by
    ext S
    simp only [mem_filter, mem_powerset, subset_sdiff]
  have hcard : #(E \ T) = #E - #T := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.2 hT]
  rw [h, card_powerset, hcard]

end Counting

/-! ## Colourings of the complete graph as subsets of the pair set -/

/-- `pairs n` is the edge set of the complete graph on `Fin n`: all two-element subsets. -/
def pairs (n : ℕ) : Finset (Finset (Fin n)) := powersetCard 2 (univ : Finset (Fin n))

/-- `pairsIn K` is the set of edges inside `K`. -/
def pairsIn (K : Finset (Fin n)) : Finset (Finset (Fin n)) := powersetCard 2 K

lemma card_pairs (n : ℕ) : #(pairs n) = n.choose 2 := by
  simp [pairs, Finset.card_powersetCard]

lemma card_pairsIn (K : Finset (Fin n)) : #(pairsIn K) = (#K).choose 2 :=
  card_powersetCard _ _

lemma pairsIn_subset (K : Finset (Fin n)) : pairsIn K ⊆ pairs n :=
  powersetCard_mono (subset_univ K)

lemma mem_pairsIn {K e : Finset (Fin n)} : e ∈ pairsIn K ↔ e ⊆ K ∧ #e = 2 := by
  simp [pairsIn, mem_powersetCard]

/-- A colouring `S` (the set of *red* edges) is *monochromatic on* `K` if all edges inside `K`
are red, or all are blue. -/
def MonoOn (S : Finset (Finset (Fin n))) (K : Finset (Fin n)) : Prop :=
  pairsIn K ⊆ S ∨ Disjoint S (pairsIn K)

instance (S : Finset (Finset (Fin n))) (K : Finset (Fin n)) : Decidable (MonoOn S K) := by
  unfold MonoOn; infer_instance

/-- Colourings monochromatic on a fixed `k`-set. -/
def badFor (K : Finset (Fin n)) : Finset (Finset (Finset (Fin n))) :=
  (pairs n).powerset.filter (fun S => MonoOn S K)

/-- Colourings monochromatic on *some* `k`-set. -/
def bad (n k : ℕ) : Finset (Finset (Finset (Fin n))) :=
  (pairs n).powerset.filter (fun S => ∃ K ∈ powersetCard k (univ : Finset (Fin n)), MonoOn S K)

/-- The count for one `k`-set: at most `2 · 2 ^ (#pairs - #pairsIn K)` colourings are
monochromatic on `K`.  This is the "expected value of one indicator" step. -/
lemma card_badFor_le (K : Finset (Fin n)) :
    #(badFor K) ≤ 2 * 2 ^ (n.choose 2 - (#K).choose 2) := by
  have hsub : badFor K ⊆ (pairs n).powerset.filter (fun S => pairsIn K ⊆ S) ∪
      (pairs n).powerset.filter (fun S => Disjoint S (pairsIn K)) := by
    intro S hS
    simp only [badFor, mem_filter, mem_powerset, MonoOn] at hS
    rcases hS.2 with h | h
    · exact mem_union_left _ (by simp only [mem_filter, mem_powerset]; exact ⟨hS.1, h⟩)
    · exact mem_union_right _ (by simp only [mem_filter, mem_powerset]; exact ⟨hS.1, h⟩)
  calc #(badFor K) ≤ _ := card_le_card hsub
    _ ≤ #((pairs n).powerset.filter (fun S => pairsIn K ⊆ S)) +
        #((pairs n).powerset.filter (fun S => Disjoint S (pairsIn K))) := card_union_le _ _
    _ = 2 * 2 ^ (n.choose 2 - (#K).choose 2) := by
        rw [card_filter_superset _ _ (pairsIn_subset K),
          card_filter_disjoint _ _ (pairsIn_subset K), card_pairs, card_pairsIn]
        ring

/-- Union bound: at most `n.choose k · 2 · 2 ^ (#pairs - k.choose 2)` colourings contain a
monochromatic `k`-set.  This is exactly "the expected number of monochromatic `K_k` is at most
`binom(n,k) · 2^{1 - binom(k,2)}`", cleared of denominators. -/
lemma card_monochromatic_le (n k : ℕ) :
    #(bad n k) ≤ n.choose k * (2 * 2 ^ (n.choose 2 - k.choose 2)) := by
  have hsub : bad n k ⊆ (powersetCard k (univ : Finset (Fin n))).biUnion badFor := by
    intro S hS
    simp only [bad, mem_filter, mem_powerset] at hS
    obtain ⟨K, hK, hmono⟩ := hS.2
    exact mem_biUnion.2 ⟨K, hK, by simp only [badFor, mem_filter, mem_powerset]; exact ⟨hS.1, hmono⟩⟩
  calc #(bad n k) ≤ #((powersetCard k (univ : Finset (Fin n))).biUnion badFor) := card_le_card hsub
    _ ≤ ∑ K ∈ powersetCard k (univ : Finset (Fin n)), #(badFor K) := card_biUnion_le
    _ ≤ ∑ _K ∈ powersetCard k (univ : Finset (Fin n)), 2 * 2 ^ (n.choose 2 - k.choose 2) := by
        refine sum_le_sum ?_
        intro K hK
        have hcard : #K = k := (mem_powersetCard.1 hK).2
        simpa [hcard] using card_badFor_le K
    _ = n.choose k * (2 * 2 ^ (n.choose 2 - k.choose 2)) := by
        rw [sum_const, card_powersetCard, card_univ, Fintype.card_fin, smul_eq_mul]

/-- **The expectation argument.**  If `2 · binom(n,k) < 2 ^ binom(k,2)` then not all colourings
are bad, so a colouring with no monochromatic `k`-set exists. -/
theorem exists_good_colouring (hkn : k ≤ n) (h : 2 * n.choose k < 2 ^ (k.choose 2)) :
    ∃ S ⊆ pairs n, ∀ K : Finset (Fin n), #K = k → ¬ MonoOn S K := by
  have hchoose : k.choose 2 ≤ n.choose 2 := Nat.choose_le_choose 2 hkn
  have hlt : #(bad n k) < #((pairs n).powerset) := by
    have h1 : #(bad n k) ≤ 2 ^ (n.choose 2 - k.choose 2) * (2 * n.choose k) := by
      have := card_monochromatic_le n k
      calc #(bad n k) ≤ n.choose k * (2 * 2 ^ (n.choose 2 - k.choose 2)) := this
        _ = 2 ^ (n.choose 2 - k.choose 2) * (2 * n.choose k) := by ring
    have h2 : 2 ^ (n.choose 2 - k.choose 2) * (2 * n.choose k) <
        2 ^ (n.choose 2 - k.choose 2) * 2 ^ (k.choose 2) :=
      mul_lt_mul_of_pos_left h (Nat.two_pow_pos _)
    have h3 : 2 ^ (n.choose 2 - k.choose 2) * 2 ^ (k.choose 2) = 2 ^ (n.choose 2) := by
      rw [← pow_add, Nat.sub_add_cancel hchoose]
    rw [card_powerset, card_pairs]
    omega
  have hne : (bad n k) ≠ (pairs n).powerset := by
    intro hEq; rw [hEq] at hlt; exact lt_irrefl _ hlt
  have hsub : bad n k ⊆ (pairs n).powerset := filter_subset _ _
  obtain ⟨S, hS, hSbad⟩ : ∃ S ∈ (pairs n).powerset, S ∉ bad n k := by
    by_contra hcon
    push_neg at hcon
    exact hne (Finset.Subset.antisymm hsub hcon)
  refine ⟨S, mem_powerset.1 hS, ?_⟩
  intro K hK hmono
  exact hSbad (by
    simp only [bad, mem_filter, mem_powerset]
    exact ⟨mem_powerset.1 hS, K, mem_powersetCard.2 ⟨subset_univ K, hK⟩, hmono⟩)

/-! ## The graph-theoretic form -/

/-- The graph whose edges are the red pairs of the colouring `S`. -/
def graphOf (S : Finset (Finset (Fin n))) : SimpleGraph (Fin n) :=
  SimpleGraph.fromRel (fun u v => ({u, v} : Finset (Fin n)) ∈ S)

lemma graphOf_adj {S : Finset (Finset (Fin n))} {u v : Fin n} :
    (graphOf S).Adj u v ↔ u ≠ v ∧ ({u, v} : Finset (Fin n)) ∈ S := by
  simp only [graphOf, SimpleGraph.fromRel_adj]
  constructor
  · rintro ⟨hne, h | h⟩
    · exact ⟨hne, h⟩
    · exact ⟨hne, by rwa [Finset.pair_comm]⟩
  · rintro ⟨hne, h⟩
    exact ⟨hne, Or.inl h⟩

/-- A colouring with no monochromatic `k`-set gives a graph with `G` and `Gᶜ` both `K_k`-free. -/
theorem cliqueFree_of_good {S : Finset (Finset (Fin n))}
    (hS : ∀ K : Finset (Fin n), #K = k → ¬ MonoOn S K) :
    (graphOf S).CliqueFree k ∧ (graphOf S)ᶜ.CliqueFree k := by
  constructor
  · intro T hT
    obtain ⟨hTclique, hTcard⟩ := hT
    have hmono : MonoOn S T := by
      left
      intro e he
      rw [mem_pairsIn] at he
      obtain ⟨u, v, huv, rfl⟩ := Finset.card_eq_two.1 he.2
      have hu : u ∈ T := he.1 (by simp)
      have hv : v ∈ T := he.1 (by simp)
      exact (graphOf_adj.1 (hTclique hu hv huv)).2
    exact hS T hTcard hmono
  · intro T hT
    obtain ⟨hTclique, hTcard⟩ := hT
    have hmono : MonoOn S T := by
      right
      rw [Finset.disjoint_right]
      intro e he heS
      rw [mem_pairsIn] at he
      obtain ⟨u, v, huv, rfl⟩ := Finset.card_eq_two.1 he.2
      have hu : u ∈ T := he.1 (by simp)
      have hv : v ∈ T := he.1 (by simp)
      have hadj := hTclique hu hv huv
      rw [SimpleGraph.compl_adj] at hadj
      exact hadj.2 (graphOf_adj.2 ⟨huv, heS⟩)
    exact hS T hTcard hmono

/-- **Existence of a Ramsey colouring** in graph form. -/
theorem exists_cliqueFree_and_compl_cliqueFree (hkn : k ≤ n)
    (h : 2 * n.choose k < 2 ^ (k.choose 2)) :
    ∃ G : SimpleGraph (Fin n), G.CliqueFree k ∧ Gᶜ.CliqueFree k := by
  obtain ⟨S, -, hS⟩ := exists_good_colouring hkn h
  exact ⟨graphOf S, cliqueFree_of_good hS⟩

/-! ## The arithmetic engine: `2 ^ (k+2) < (k !)^2` -/

/-- For `k ≥ 3`, `2^{k+2} < (k!)^2`; equivalently `2 · 2^{k/2} < k!`, the inequality that makes
Erdős' expectation bound work. -/
theorem two_pow_lt_factorial_sq : ∀ k : ℕ, 3 ≤ k → 2 ^ (k + 2) < (k.factorial) ^ 2 := by
  intro k hk
  induction k with
  | zero => omega
  | succ m ih =>
    rcases Nat.lt_or_ge m 3 with hm | hm
    · have hm2 : m = 2 := by omega
      subst hm2
      norm_num [Nat.factorial]
    · have hih := ih (by omega)
      have h1 : (m + 1).factorial ^ 2 = (m + 1) ^ 2 * (m.factorial) ^ 2 := by
        rw [Nat.factorial_succ]; ring
      have h2 : 2 ^ (m + 1 + 2) = 2 * 2 ^ (m + 2) := by ring
      have h3 : 2 * 2 ^ (m + 2) < 2 * m.factorial ^ 2 := by omega
      have h4 : 2 * m.factorial ^ 2 ≤ (m + 1) ^ 2 * m.factorial ^ 2 := by
        have : 2 ≤ (m + 1) ^ 2 := by nlinarith
        exact Nat.mul_le_mul_right _ this
      omega

/-- The core arithmetic step: `n ≤ 2 ^ (k/2)` (written `n ^ 2 ≤ 2 ^ k`) and `3 ≤ k` imply the
counting hypothesis `2 · binom(n,k) < 2 ^ binom(k,2)`. -/
theorem two_mul_choose_lt (hk : 3 ≤ k) (hn : n ^ 2 ≤ 2 ^ k) :
    2 * n.choose k < 2 ^ (k.choose 2) := by
  set F := k.factorial with hF
  have hFpos : 0 < F := Nat.factorial_pos k
  -- square both sides of `F * (2 * choose) < F * 2 ^ choose 2`
  have hdesc : F * n.choose k = n.descFactorial k := (Nat.descFactorial_eq_factorial_mul_choose n k).symm
  have key : (F * (2 * n.choose k)) ^ 2 < (F * 2 ^ (k.choose 2)) ^ 2 := by
    have hL : (F * (2 * n.choose k)) ^ 2 = 4 * (n.descFactorial k) ^ 2 := by
      rw [show F * (2 * n.choose k) = 2 * (F * n.choose k) by ring, hdesc]; ring
    have hb : (n.descFactorial k) ^ 2 ≤ (n ^ 2) ^ k := by
      have := Nat.descFactorial_le_pow n k
      calc (n.descFactorial k) ^ 2 ≤ (n ^ k) ^ 2 := Nat.pow_le_pow_left this 2
        _ = (n ^ 2) ^ k := by rw [← pow_mul, ← pow_mul, Nat.mul_comm]
    have hb2 : (n.descFactorial k) ^ 2 ≤ 2 ^ (k * k) := by
      calc (n.descFactorial k) ^ 2 ≤ (n ^ 2) ^ k := hb
        _ ≤ (2 ^ k) ^ k := Nat.pow_le_pow_left hn k
        _ = 2 ^ (k * k) := by rw [← pow_mul]
    have hR : (F * 2 ^ (k.choose 2)) ^ 2 = F ^ 2 * 2 ^ (k * (k - 1)) := by
      have h2 : 2 * k.choose 2 = k * (k - 1) := by
        rcases k with _ | k'
        · simp
        · rw [Nat.choose_two_right]
          have hmul : (k' + 1) * (k' + 1 - 1) = k' * (k' + 1) := by
            simp [Nat.mul_comm]
          rw [hmul]
          obtain ⟨c, hc⟩ := Nat.even_mul_succ_self k'
          rw [hc]
          omega
      calc (F * 2 ^ (k.choose 2)) ^ 2 = F ^ 2 * 2 ^ (2 * k.choose 2) := by
            rw [mul_pow, ← pow_mul, Nat.mul_comm (k.choose 2) 2]
        _ = F ^ 2 * 2 ^ (k * (k - 1)) := by rw [h2]
    have hFsq : 2 ^ (k + 2) < F ^ 2 := two_pow_lt_factorial_sq k hk
    have hkk : k * k = k * (k - 1) + k := by
      rcases k with _ | k'
      · simp
      · simp only [Nat.add_sub_cancel]
        ring
    have hL2 : 4 * (n.descFactorial k) ^ 2 ≤ 2 ^ (k * (k - 1)) * 2 ^ (k + 2) := by
      have : 4 * (n.descFactorial k) ^ 2 ≤ 4 * 2 ^ (k * k) := by
        exact Nat.mul_le_mul_left 4 hb2
      calc 4 * (n.descFactorial k) ^ 2 ≤ 4 * 2 ^ (k * k) := this
        _ = 4 * (2 ^ (k * (k - 1)) * 2 ^ k) := by rw [hkk, pow_add]
        _ = 2 ^ (k * (k - 1)) * 2 ^ (k + 2) := by rw [pow_add]; ring
    have hR2 : 2 ^ (k * (k - 1)) * 2 ^ (k + 2) < 2 ^ (k * (k - 1)) * F ^ 2 :=
      mul_lt_mul_of_pos_left hFsq (Nat.two_pow_pos _)
    rw [hL, hR]
    calc 4 * (n.descFactorial k) ^ 2 ≤ 2 ^ (k * (k - 1)) * 2 ^ (k + 2) := hL2
      _ < 2 ^ (k * (k - 1)) * F ^ 2 := hR2
      _ = F ^ 2 * 2 ^ (k * (k - 1)) := by ring
  have hlt : F * (2 * n.choose k) < F * 2 ^ (k.choose 2) := by
    by_contra hcon
    push_neg at hcon
    exact absurd (Nat.pow_le_pow_left hcon 2) (Nat.not_le.2 key)
  exact Nat.lt_of_mul_lt_mul_left hlt

/-! ## Erdős' theorem -/

/-- **Erdős (1947), de-randomised.**  If `3 ≤ k` and `n ^ 2 ≤ 2 ^ k` (that is, `n ≤ 2 ^ (k/2)`),
then there is a two-colouring of the edges of `K_n` with no monochromatic `K_k`; equivalently a
graph `G` on `n` vertices with `G` and its complement both `K_k`-free. -/
theorem erdos_ramsey_bound (hk : 3 ≤ k) (hn : n ^ 2 ≤ 2 ^ k) :
    ∃ G : SimpleGraph (Fin n), G.CliqueFree k ∧ Gᶜ.CliqueFree k := by
  rcases Nat.lt_or_ge n k with hlt | hge
  · exact ⟨⊥, SimpleGraph.cliqueFree_of_card_lt (by simpa using hlt),
      SimpleGraph.cliqueFree_of_card_lt (by simpa using hlt)⟩
  · exact exists_cliqueFree_and_compl_cliqueFree hge (two_mul_choose_lt hk hn)

/-- `IsRamsey m k` says that `m` is large enough for the diagonal Ramsey property: every graph
on `m` vertices has a `k`-clique or a `k`-independent set. -/
def IsRamsey (m k : ℕ) : Prop :=
  ∀ G : SimpleGraph (Fin m), ¬ (G.CliqueFree k ∧ Gᶜ.CliqueFree k)

/-- Ramsey witnesses are monotone downwards along induced subgraphs. -/
lemma not_isRamsey_of_le {m n k : ℕ} (hmn : m ≤ n)
    (h : ∃ G : SimpleGraph (Fin n), G.CliqueFree k ∧ Gᶜ.CliqueFree k) : ¬ IsRamsey m k := by
  obtain ⟨G, hG, hGc⟩ := h
  intro hR
  let f : Fin m ↪ Fin n := ⟨fun i => ⟨i.1, lt_of_lt_of_le i.2 hmn⟩, by
    intro a b hab
    simpa [Fin.ext_iff] using hab⟩
  have hinj : Function.Injective f := f.injective
  have h1 : (G.comap f).CliqueFree k :=
    SimpleGraph.CliqueFree.comap (SimpleGraph.Embedding.comap f G) hG
  have h2 : ((G.comap f)ᶜ).CliqueFree k := by
    have hEq : (G.comap f)ᶜ = (Gᶜ).comap f := by
      ext a b
      simp only [SimpleGraph.compl_adj, SimpleGraph.comap_adj]
      constructor
      · rintro ⟨hne, hnadj⟩
        exact ⟨fun hEq => hne (hinj hEq), hnadj⟩
      · rintro ⟨hne, hnadj⟩
        exact ⟨fun hEq => hne (congrArg f hEq), hnadj⟩
    rw [hEq]
    exact SimpleGraph.CliqueFree.comap (SimpleGraph.Embedding.comap f Gᶜ) hGc
  exact hR (G.comap f) ⟨h1, h2⟩

/-- **`R(k,k) > 2 ^ (k/2)`.**  Any `m` with the diagonal Ramsey property for `k` exceeds every
`n` with `n ^ 2 ≤ 2 ^ k`. -/
theorem lt_of_isRamsey {m : ℕ} (hk : 3 ≤ k) (hn : n ^ 2 ≤ 2 ^ k) (hR : IsRamsey m k) : n < m := by
  by_contra hcon
  push_neg at hcon
  exact not_isRamsey_of_le hcon (erdos_ramsey_bound hk hn) hR

/-! ## Lab notes: numerical checks of the counting hypothesis

The table below was produced with `#eval` (columns: `k`, the largest `n` with `n^2 ≤ 2^k`,
`2·binom(n,k)`, `2^binom(k,2)`, and whether the counting hypothesis of `two_mul_choose_lt`
holds):

```
k    n    2*C(n,k)        2^C(k,2)              holds?
3    2    0               8                     true
4    4    2               64                    true
5    5    2               1024                  true
6    8    56              32768                 true
7    11   660             2097152               true
8    16   25740           268435456             true
9    22   994840          68719476736           true
10   32   129024480       35184372088832        true
11   45   20301191820     36028797018963968     true
```

Two instances of that table are re-verified by the kernel below. -/

example : 2 ^ (3 + 2) < (Nat.factorial 3) ^ 2 := by decide

example : (16 : ℕ) ^ 2 ≤ 2 ^ 8 := by decide

example : 2 * (Nat.choose 16 8) < 2 ^ (Nat.choose 8 2) := by decide

end ErdosProbabilisticRamsey