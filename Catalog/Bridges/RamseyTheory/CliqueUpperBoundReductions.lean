import Mathlib

open Finset

namespace CliqueUpperBoundReductions

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- An upper-bound function is valid when it bounds every clique contained in the
queried vertex set. No monotonicity or computability assumption is needed. -/
def UpperBoundValid (G : SimpleGraph V) (upper : Finset V → ℕ) : Prop :=
  ∀ ⦃S C : Finset V⦄, C ⊆ S → G.IsClique (C : Set V) → C.card ≤ upper S

/-- Vertices adjacent to every vertex of a finite seed. -/
noncomputable def commonNeighbors (G : SimpleGraph V) (D : Finset V) : Finset V := by
  classical
  exact Finset.univ.filter fun v ↦ ∀ d ∈ D, G.Adj v d

/-- The upper-bound reduction test attached to a seed `D`. -/
def SeedReducible (G : SimpleGraph V) (upper : Finset V → ℕ)
    (k : ℕ) (D : Finset V) : Prop :=
  D.card + upper (commonNeighbors G D) ≤ k

/-- A clique containing a seed consists of the seed and a clique in its common
neighborhood. This is the counting principle behind generalized core and truss
reductions. -/
theorem clique_card_le_seed_add_bound
    {G : SimpleGraph V} {upper : Finset V → ℕ} (hu : UpperBoundValid G upper)
    {C D : Finset V} (hC : G.IsClique (C : Set V)) (hDC : D ⊆ C) :
    C.card ≤ D.card + upper (commonNeighbors G D) := by
  have hR_subset : (C \ D) ⊆ commonNeighbors G D := by
    intro v hv
    simp_all +decide [commonNeighbors]
    exact fun d hd => hC hv.1 (hDC hd) (by aesop)
  have hbound := hu hR_subset (hC.subset Finset.sdiff_subset)
  simp_all +decide [Finset.card_sdiff]
  rw [add_comm, Finset.inter_eq_left.mpr hDC] at hbound
  linarith

/-- A successful seed test proves that no clique larger than `k` contains that
seed. Thus deleting the seed (or one edge when the seed has two endpoints)
preserves every clique that could improve a size-`k` incumbent. -/
theorem seed_reduction_sound
    {G : SimpleGraph V} {upper : Finset V → ℕ} (hu : UpperBoundValid G upper)
    {k : ℕ} {C D : Finset V} (hC : G.IsClique (C : Set V))
    (hred : SeedReducible G upper k D) (hk : k < C.card) :
    ¬ D ⊆ C := by
  exact fun h => not_lt_of_ge (le_trans (clique_card_le_seed_add_bound hu hC h) hred) hk

/-- The upper-bound core rule: if the bound on a vertex neighborhood plus one
is at most `k`, no clique larger than `k` can contain the vertex. -/
theorem core_reduction_sound
    {G : SimpleGraph V} {upper : Finset V → ℕ} (hu : UpperBoundValid G upper)
    {k : ℕ} {C : Finset V} (hC : G.IsClique (C : Set V)) {v : V}
    (hred : 1 + upper (commonNeighbors G {v}) ≤ k) (hk : k < C.card) :
    v ∉ C := by
  convert seed_reduction_sound hu hC
    (show SeedReducible G upper k {v} from by simpa [SeedReducible] using hred) hk
  simp [Finset.singleton_subset_iff]

/-- The upper-bound truss rule: if the common-neighborhood bound of an edge,
plus its two endpoints, is at most `k`, no larger clique uses both endpoints. -/
theorem truss_reduction_sound
    {G : SimpleGraph V} {upper : Finset V → ℕ} (hu : UpperBoundValid G upper)
    {k : ℕ} {C : Finset V} (hC : G.IsClique (C : Set V)) {u v : V} (huv : u ≠ v)
    (hred : 2 + upper (commonNeighbors G {u, v}) ≤ k) (hk : k < C.card) :
    ¬ ({u, v} : Finset V) ⊆ C := by
  apply seed_reduction_sound hu hC
  simpa [SeedReducible, huv] using hred
  exact hk

/-- Simultaneously applying any family of successful seed reductions preserves
all cliques larger than the incumbent. This abstracts correctness of a peeling
pass independently of the order in which its tests are evaluated. -/
theorem reduction_family_preserves_large_cliques
    {G : SimpleGraph V} {upper : Finset V → ℕ} (hu : UpperBoundValid G upper)
    {k : ℕ} (rules : Finset (Finset V))
    (hrules : ∀ D ∈ rules, SeedReducible G upper k D)
    {C : Finset V} (hC : G.IsClique (C : Set V)) (hk : k < C.card) :
    ∀ D ∈ rules, ¬ D ⊆ C := by
  exact fun D hD => seed_reduction_sound hu hC (hrules D hD) hk

/-- If every putative clique larger than `k` contains a seed certified by the
upper-bound test, then `k` is a valid global clique upper bound. This is the
logical core of the reduction-based upper-bound improvement framework. -/
theorem certified_seed_cover_improves_upper_bound
    {G : SimpleGraph V} {upper : Finset V → ℕ} (hu : UpperBoundValid G upper)
    {k : ℕ} (rules : Finset (Finset V))
    (hrules : ∀ D ∈ rules, SeedReducible G upper k D)
    (hcover : ∀ C : Finset V, G.IsClique (C : Set V) → k < C.card →
      ∃ D ∈ rules, D ⊆ C) :
    ∀ C : Finset V, G.IsClique (C : Set V) → C.card ≤ k := by
  intro C hC
  by_contra hle
  have hk : k < C.card := Nat.lt_of_not_ge hle
  obtain ⟨D, hDrules, hDC⟩ := hcover C hC hk
  exact (reduction_family_preserves_large_cliques hu rules hrules hC hk D hDrules) hDC

end CliqueUpperBoundReductions