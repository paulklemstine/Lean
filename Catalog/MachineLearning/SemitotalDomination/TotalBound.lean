import MachineLearning.SemitotalDomination.Defs

/-!
# The universal bound `γ_t2(G) ≤ γ_t(G) ≤ 2 γ(G)`

The 5-approximation algorithm of *Semitotal domination in unit disk graphs* compares the
size of the computed set with the **semitotal** optimum `γ_t2(G)`.  A natural adversarial
question raised during the review of the previous cycle is whether the *structural*
corollary we derived from it, `γ_t2 ≤ 5 γ` for unit disk graphs, is the best one can do.
It is not: for every graph without isolated vertices one has the much stronger, and
completely general, chain

`γ(G) ≤ γ_t2(G) ≤ γ_t(G) ≤ 2 γ(G)`.

This file proves the missing link `γ_t ≤ 2 γ` by an explicit "pair up each dominating
vertex with a private neighbour" construction, and records the consequences.  The bound is
sharp: for a star `γ = 1` and `γ_t2 = γ_t = 2` (see `Instances.lean`).

The point of the exercise is a *boundary clarification*: the paper's factor `5` is an
approximation guarantee against `γ_t2` itself, computed in linear time; it is **not** a
statement about the ratio `γ_t2 / γ`, which is always at most `2`.
-/

namespace SemitotalDomination

open Finset

variable {V : Type*} {G : SimpleGraph V}

/-- **Pairing construction.** If `G` has no isolated vertex, any dominating set `D` can be
turned into a *total* dominating set of size at most `2|D|` by adding, for each `d ∈ D`,
one neighbour of `d`. -/
theorem exists_totalDominatingSet_card_le_two_mul [DecidableEq V]
    (hiso : ∀ v : V, ∃ u, G.Adj u v) {D : Finset V} (hD : IsDominatingSet G D) :
    ∃ S : Finset V, IsTotalDominatingSet G S ∧ S.card ≤ 2 * D.card := by
  classical
  choose f hf using hiso
  refine ⟨D ∪ D.image f, ?_, ?_⟩
  · intro v
    rcases hD v with hv | ⟨d, hd, hadj⟩
    · exact ⟨f v, Finset.mem_union_right _ (Finset.mem_image_of_mem f hv), hf v⟩
    · exact ⟨d, Finset.mem_union_left _ hd, hadj⟩
  · calc (D ∪ D.image f).card ≤ D.card + (D.image f).card := Finset.card_union_le _ _
      _ ≤ D.card + D.card := Nat.add_le_add_left Finset.card_image_le _
      _ = 2 * D.card := by ring

/-- The infimum defining `γ(G)` is attained (the whole vertex set is dominating). -/
theorem exists_dominating_card_eq [Fintype V] :
    ∃ D : Finset V, IsDominatingSet G D ∧ D.card = dominationNumber G := by
  have hne : {k | ∃ D : Finset V, IsDominatingSet G D ∧ D.card = k}.Nonempty :=
    ⟨Finset.univ.card, Finset.univ, fun v => Or.inl (Finset.mem_univ v), rfl⟩
  obtain ⟨D, hD, hcard⟩ := Nat.sInf_mem hne
  exact ⟨D, hD, hcard⟩

/-- **`γ_t(G) ≤ 2 γ(G)`** for every finite graph without isolated vertices. -/
theorem totalDominationNumber_le_two_mul_dominationNumber [Fintype V] [DecidableEq V]
    (hiso : ∀ v : V, ∃ u, G.Adj u v) :
    totalDominationNumber G ≤ 2 * dominationNumber G := by
  obtain ⟨D, hD, hcard⟩ := exists_dominating_card_eq (G := G)
  obtain ⟨S, hS, hle⟩ := exists_totalDominatingSet_card_le_two_mul hiso hD
  exact le_trans (Nat.sInf_le ⟨S, hS, rfl⟩) (hcard ▸ hle)

/-- **`γ_t2(G) ≤ 2 γ(G)`** for every finite graph without isolated vertices.  This is
strictly stronger than the unit-disk corollary `γ_t2 ≤ 5 γ` obtained from the
approximation algorithm, and it needs no geometry at all. -/
theorem semitotalDominationNumber_le_two_mul_dominationNumber [Fintype V] [DecidableEq V]
    (hiso : ∀ v : V, ∃ u, G.Adj u v) :
    semitotalDominationNumber G ≤ 2 * dominationNumber G := by
  obtain ⟨D, hD, hcard⟩ := exists_dominating_card_eq (G := G)
  obtain ⟨S, hS, hle⟩ := exists_totalDominatingSet_card_le_two_mul hiso hD
  exact le_trans (semitotalDominationNumber_le_card hS.isSemitotalDominatingSet) (hcard ▸ hle)

/-- The full chain `γ ≤ γ_t2 ≤ γ_t ≤ 2 γ` in a single statement. -/
theorem dominationNumber_chain [Fintype V] [DecidableEq V]
    (hiso : ∀ v : V, ∃ u, G.Adj u v) :
    dominationNumber G ≤ semitotalDominationNumber G ∧
      semitotalDominationNumber G ≤ totalDominationNumber G ∧
      totalDominationNumber G ≤ 2 * dominationNumber G := by
  obtain ⟨D, hD, -⟩ := exists_dominating_card_eq (G := G)
  obtain ⟨S, hS, -⟩ := exists_totalDominatingSet_card_le_two_mul hiso hD
  refine ⟨dominationNumber_le_semitotalDominationNumber ⟨S, hS.isSemitotalDominatingSet⟩,
    semitotalDominationNumber_le_totalDominationNumber ⟨S, hS⟩,
    totalDominationNumber_le_two_mul_dominationNumber hiso⟩

/-- A degree-based lower bound for the semitotal domination number: `n ≤ (Δ+1) γ_t2`. -/
theorem card_le_maxDegree_succ_mul_semitotalDominationNumber [Fintype V] [DecidableEq V]
    [DecidableRel G.Adj] (hex : ∃ S : Finset V, IsSemitotalDominatingSet G S) :
    Fintype.card V ≤ (G.maxDegree + 1) * semitotalDominationNumber G := by
  refine le_trans (domination_card_lower_bound G) ?_
  exact Nat.mul_le_mul_left _ (dominationNumber_le_semitotalDominationNumber hex)

end SemitotalDomination