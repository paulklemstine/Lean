import Mathlib
import Novelty.TransmissionDominationTree

/-!
# Semitotal domination: definitions and the fundamental chain `γ ≤ γ_t2 ≤ γ_t`

This file sets up the vocabulary needed to formalize the results of the paper
*Semitotal domination in unit disk graphs*.

A set `S ⊆ V` is a **semitotal dominating set** of `G = (V,E)` if

* every vertex outside `S` has a neighbour in `S` (`S` is dominating), and
* every vertex of `S` is within distance `2` of *another* vertex of `S`.

We reuse the catalog definition `IsDominatingSet` / `dominationNumber` from
`Novelty.TransmissionDominationTree` rather than re-inventing it.

Distance-at-most-two is formalized combinatorially as `Within2` (equality, adjacency, or a
common neighbour) instead of via `SimpleGraph.dist`; this is equivalent for reachable pairs
and avoids the degenerate convention `dist u v = 0` for unreachable `u ≠ v`, which would make
the semitotal condition vacuously satisfiable in disconnected graphs.
-/

namespace SemitotalDomination

open Finset

variable {V : Type*} {G : SimpleGraph V}

/-- `Within2 G u v` says that `u` and `v` are at graph distance at most `2`. -/
def Within2 (G : SimpleGraph V) (u v : V) : Prop :=
  u = v ∨ G.Adj u v ∨ ∃ w, G.Adj u w ∧ G.Adj w v

@[refl] lemma Within2.refl (G : SimpleGraph V) (v : V) : Within2 G v v := Or.inl rfl

lemma Within2.symm {u v : V} (h : Within2 G u v) : Within2 G v u := by
  rcases h with h | h | ⟨w, h1, h2⟩
  · exact Or.inl h.symm
  · exact Or.inr (Or.inl h.symm)
  · exact Or.inr (Or.inr ⟨w, h2.symm, h1.symm⟩)

lemma Within2.of_adj {u v : V} (h : G.Adj u v) : Within2 G u v := Or.inr (Or.inl h)

lemma Within2.of_adj_adj {u w v : V} (h1 : G.Adj u w) (h2 : G.Adj w v) : Within2 G u v :=
  Or.inr (Or.inr ⟨w, h1, h2⟩)

/-- `Within2` really is "graph distance at most two" whenever the two vertices are reachable. -/
lemma within2_iff_dist_le_two {u v : V} (h : G.Reachable u v) :
    Within2 G u v ↔ G.dist u v ≤ 2 := by
  constructor
  · rintro (rfl | hadj | ⟨w, h1, h2⟩)
    · simp
    · simpa using (SimpleGraph.dist_eq_one_iff_adj.mpr hadj).le.trans (by norm_num)
    · calc G.dist u v ≤ G.dist u w + G.dist w v :=
            (SimpleGraph.Reachable.dist_triangle_right h2.reachable u)
      _ = 2 := by
            rw [SimpleGraph.dist_eq_one_iff_adj.mpr h1, SimpleGraph.dist_eq_one_iff_adj.mpr h2]
  · intro hd
    obtain ⟨p, hp⟩ := h.exists_walk_length_eq_dist
    interval_cases hlen : G.dist u v
    · left
      have : p.length = 0 := by omega
      exact (SimpleGraph.Walk.eq_of_length_eq_zero this).symm ▸ rfl
    · exact Or.inr (Or.inl (SimpleGraph.dist_eq_one_iff_adj.mp hlen))
    · right; right
      have hp2 : p.length = 2 := by omega
      match p, hp2 with
      | SimpleGraph.Walk.cons h1 (SimpleGraph.Walk.cons h2 SimpleGraph.Walk.nil), _ =>
        exact ⟨_, h1, h2⟩

/-- Every vertex of `S` is within distance two of another vertex of `S`. -/
def IsSemitotalSet (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ v ∈ S, ∃ u ∈ S, u ≠ v ∧ Within2 G u v

/-- A **semitotal dominating set**: dominating, plus the semitotal condition. -/
def IsSemitotalDominatingSet (G : SimpleGraph V) (S : Finset V) : Prop :=
  IsDominatingSet G S ∧ IsSemitotalSet G S

/-- A **total dominating set**: *every* vertex (including those of `S`) has a neighbour in `S`. -/
def IsTotalDominatingSet (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ v, ∃ u ∈ S, G.Adj u v

/-- The semitotal domination number `γ_t2(G)`. -/
noncomputable def semitotalDominationNumber [Fintype V] (G : SimpleGraph V) : ℕ :=
  sInf {k | ∃ S : Finset V, IsSemitotalDominatingSet G S ∧ S.card = k}

/-- The total domination number `γ_t(G)`. -/
noncomputable def totalDominationNumber [Fintype V] (G : SimpleGraph V) : ℕ :=
  sInf {k | ∃ S : Finset V, IsTotalDominatingSet G S ∧ S.card = k}

section Basic

lemma IsDominatingSet.mono {S T : Finset V} (h : IsDominatingSet G S) (hST : S ⊆ T) :
    IsDominatingSet G T := by
  intro v
  rcases h v with hv | ⟨d, hd, hadj⟩
  · exact Or.inl (hST hv)
  · exact Or.inr ⟨d, hST hd, hadj⟩

lemma IsSemitotalSet.mono_of_subset {S T : Finset V} (h : IsSemitotalSet G S) (hST : S ⊆ T) :
    ∀ v ∈ S, ∃ u ∈ T, u ≠ v ∧ Within2 G u v := by
  intro v hv
  obtain ⟨u, hu, hne, hw⟩ := h v hv
  exact ⟨u, hST hu, hne, hw⟩

/-- A total dominating set is a semitotal dominating set. -/
theorem IsTotalDominatingSet.isSemitotalDominatingSet {S : Finset V}
    (h : IsTotalDominatingSet G S) : IsSemitotalDominatingSet G S := by
  refine ⟨fun v => Or.inr (h v), fun v _ => ?_⟩
  obtain ⟨u, hu, hadj⟩ := h v
  exact ⟨u, hu, hadj.ne, Within2.of_adj hadj⟩

/-- If `G` has no isolated vertex, the whole vertex set is a semitotal dominating set,
so semitotal dominating sets exist. -/
theorem exists_semitotalDominatingSet [Fintype V] (h : ∀ v : V, ∃ u, G.Adj u v) :
    ∃ S : Finset V, IsSemitotalDominatingSet G S := by
  refine ⟨Finset.univ, IsTotalDominatingSet.isSemitotalDominatingSet ?_⟩
  intro v
  obtain ⟨u, hu⟩ := h v
  exact ⟨u, Finset.mem_univ u, hu⟩

/-- Every semitotal dominating set of a nonempty graph has at least two vertices. -/
theorem two_le_card_of_isSemitotalDominatingSet [DecidableEq V] [Nonempty V] {S : Finset V}
    (h : IsSemitotalDominatingSet G S) : 2 ≤ S.card := by
  obtain ⟨hdom, hst⟩ := h
  obtain ⟨v⟩ := ‹Nonempty V›
  have hv : ∃ x, x ∈ S := by
    rcases hdom v with hv | ⟨d, hd, _⟩
    · exact ⟨v, hv⟩
    · exact ⟨d, hd⟩
  obtain ⟨x, hx⟩ := hv
  obtain ⟨u, hu, hne, -⟩ := hst x hx
  have : ({u, x} : Finset V) ⊆ S := by
    intro y hy
    simp only [Finset.mem_insert, Finset.mem_singleton] at hy
    rcases hy with rfl | rfl <;> assumption
  calc 2 = ({u, x} : Finset V).card := by rw [Finset.card_insert_of_notMem (by simpa using hne),
            Finset.card_singleton]
  _ ≤ S.card := Finset.card_le_card this

/-- `γ_t2(G) ≥ 2` for a nonempty graph admitting a semitotal dominating set. -/
theorem two_le_semitotalDominationNumber [Fintype V] [DecidableEq V] [Nonempty V]
    (hex : ∃ S : Finset V, IsSemitotalDominatingSet G S) :
    2 ≤ semitotalDominationNumber G := by
  have hne : {k | ∃ S : Finset V, IsSemitotalDominatingSet G S ∧ S.card = k}.Nonempty := by
    obtain ⟨S, hS⟩ := hex
    exact ⟨S.card, S, hS, rfl⟩
  obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem hne
  have := two_le_card_of_isSemitotalDominatingSet hS
  simpa [semitotalDominationNumber, hcard] using this

/-- **Domination ≤ semitotal domination.** -/
theorem dominationNumber_le_semitotalDominationNumber [Fintype V]
    (hex : ∃ S : Finset V, IsSemitotalDominatingSet G S) :
    dominationNumber G ≤ semitotalDominationNumber G := by
  have hne : {k | ∃ S : Finset V, IsSemitotalDominatingSet G S ∧ S.card = k}.Nonempty := by
    obtain ⟨S, hS⟩ := hex
    exact ⟨S.card, S, hS, rfl⟩
  obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem hne
  have : dominationNumber G ≤ S.card := Nat.sInf_le ⟨S, hS.1, rfl⟩
  simpa [semitotalDominationNumber, hcard] using this

/-- **Semitotal domination ≤ total domination.** -/
theorem semitotalDominationNumber_le_totalDominationNumber [Fintype V]
    (hex : ∃ S : Finset V, IsTotalDominatingSet G S) :
    semitotalDominationNumber G ≤ totalDominationNumber G := by
  have hne : {k | ∃ S : Finset V, IsTotalDominatingSet G S ∧ S.card = k}.Nonempty := by
    obtain ⟨S, hS⟩ := hex
    exact ⟨S.card, S, hS, rfl⟩
  obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem hne
  have : semitotalDominationNumber G ≤ S.card :=
    Nat.sInf_le ⟨S, hS.isSemitotalDominatingSet, rfl⟩
  simpa [totalDominationNumber, hcard] using this

/-- Any semitotal dominating set gives an upper bound for `γ_t2`. -/
theorem semitotalDominationNumber_le_card [Fintype V] {S : Finset V}
    (hS : IsSemitotalDominatingSet G S) :
    semitotalDominationNumber G ≤ S.card :=
  Nat.sInf_le ⟨S, hS, rfl⟩

/-- The infimum defining `γ_t2` is attained. -/
theorem exists_semitotal_card_eq [Fintype V]
    (hex : ∃ S : Finset V, IsSemitotalDominatingSet G S) :
    ∃ S : Finset V, IsSemitotalDominatingSet G S ∧ S.card = semitotalDominationNumber G := by
  have hne : {k | ∃ S : Finset V, IsSemitotalDominatingSet G S ∧ S.card = k}.Nonempty := by
    obtain ⟨S, hS⟩ := hex
    exact ⟨S.card, S, hS, rfl⟩
  obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem hne
  exact ⟨S, hS, hcard⟩

end Basic

end SemitotalDomination