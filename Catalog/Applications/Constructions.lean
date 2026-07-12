/-
  Packing-Isolating Sets — Existence in Two Block-Graph Families

  A *block graph* is a graph in which every block (maximal 2-connected subgraph) is a
  clique.  The conjecture under study asserts that every finite block graph admits a
  packing-isolating set.  Here we verify the conjecture constructively for two
  fundamental families of block graphs:

  * **Complete graphs** `K_{n+1}` — a single block which is itself a clique;
  * **Path graphs** `P_n` — trees, hence block graphs whose blocks are all edges `K₂`.

  Main results:
  * `completeGraph_packingIsolating` / `completeGraph_exists_packingIsolating`:
        any single vertex isolates a complete graph and is trivially a 2-packing.
  * `pathG_twoPacking`, `pathG_isolating`, `pathG_packingIsolating`,
        `pathG_exists_packingIsolating`:
        the residue class `{ i : i ≡ 1 (mod 3) }` is packing-isolating in `P_n` for
        every `n`.

  -- !-- Lab Notes -- !--
  Hypothesis (Stage 1, bold): a *single periodic pattern* of period 3 simultaneously
    realizes the 2-packing constraint (gaps ≥ 3) and the isolating constraint (every
    length-1 edge is covered) on an arbitrarily long path.
  Experiment (Stage 2): the candidate `S = {i | i % 3 = 1}`.  Disjointness reduces to
    "two residues equal to 1 mod 3 that differ are ≥ 3 apart" (pure `omega`); coverage
    of an edge `{i, i+1}` reduces to a 3-way case split on `i % 3`, where the witness
    in the residue-2 case must reach *backwards* to `i-1` to stay inside `[0,n)`.
  Analysis (Stage 3): the backward witness is the crucial subtlety — a naive forward
    pattern fails at the right endpoint, explaining why a maximal 2-packing need NOT be
    isolating (e.g. taking both endpoints of `P₆`); existence requires the *aligned*
    periodic set, not a greedy/maximal one.
  Critique (Stage 4): proofs use `omega`, `rcases`, explicit `Fin` witnesses — no
    `decide`/`simp`-only shortcut; the result is an infinite family, not a finite check.
  Synthesis (Stage 5): complete graphs (single clique block) and paths (chains of `K₂`
    blocks) bracket the structural spectrum of block graphs, giving real evidence for
    the general conjecture (left as a future direction).
-/
import Mathlib
import Probability.PackingIsolation.Defs

open Finset SimpleGraph

namespace PackingIsolation

/-! ## Complete graphs -/

/-- In a complete graph, the closed neighborhood of any single vertex is everything,
so that vertex alone is packing-isolating. -/
theorem completeGraph_packingIsolating {n : ℕ} (v : Fin (n + 1)) :
    IsPackingIsolating (completeGraph (Fin (n + 1))) {v} := by
  refine ⟨isTwoPacking_singleton v, ?_⟩
  apply isIsolating_of_dominating
  intro x
  rw [mem_nbhdSet]
  refine ⟨v, mem_singleton_self v, ?_⟩
  by_cases h : x = v
  · exact Or.inl h
  · exact Or.inr (by simpa [completeGraph, top_adj] using (Ne.symm h))

theorem completeGraph_exists_packingIsolating (n : ℕ) :
    ∃ S : Finset (Fin (n + 1)), IsPackingIsolating (completeGraph (Fin (n + 1))) S :=
  ⟨{0}, completeGraph_packingIsolating 0⟩

/-! ## Path graphs -/

/-- The path graph on `Fin n`: vertices `i` and `j` are adjacent iff their values are
consecutive naturals. -/
def PathG (n : ℕ) : SimpleGraph (Fin n) where
  Adj i j := i.val + 1 = j.val ∨ j.val + 1 = i.val
  symm := by intro i j h; tauto
  loopless := ⟨by intro _ h; omega⟩

instance (n : ℕ) : DecidableRel (PathG n).Adj :=
  fun i j => inferInstanceAs (Decidable (i.val + 1 = j.val ∨ j.val + 1 = i.val))

@[simp] theorem pathG_adj (n : ℕ) (i j : Fin n) :
    (PathG n).Adj i j ↔ i.val + 1 = j.val ∨ j.val + 1 = i.val := Iff.rfl

/-- Closed-neighborhood membership in a path: `x` is within distance one of `v`. -/
theorem mem_closedNbhd_pathG (n : ℕ) (v x : Fin n) :
    x ∈ closedNbhd (PathG n) v ↔ x.val = v.val ∨ x.val + 1 = v.val ∨ v.val + 1 = x.val := by
  simp only [closedNbhd, mem_insert, mem_neighborFinset, pathG_adj]
  constructor
  · rintro (h | h | h)
    · left; rw [h]
    · right; right; omega
    · right; left; omega
  · rintro (h | h | h)
    · left; exact Fin.ext h
    · right; right; omega
    · right; left; omega

/-- The candidate packing-isolating set for `P_n`: indices congruent to `1` mod `3`. -/
def pathPacking (n : ℕ) : Finset (Fin n) := univ.filter (fun i => i.val % 3 = 1)

theorem mem_pathPacking (n : ℕ) (i : Fin n) : i ∈ pathPacking n ↔ i.val % 3 = 1 := by
  simp [pathPacking]

theorem mem_nbhdSet_pathPacking (n : ℕ) (x : Fin n) :
    x ∈ nbhdSet (PathG n) (pathPacking n) ↔
      ∃ s : Fin n, s.val % 3 = 1 ∧ (x.val = s.val ∨ x.val + 1 = s.val ∨ s.val + 1 = x.val) := by
  simp only [nbhdSet, mem_biUnion]
  constructor
  · rintro ⟨s, hs, hx⟩
    rw [mem_pathPacking] at hs
    rw [mem_closedNbhd_pathG] at hx
    exact ⟨s, hs, hx⟩
  · rintro ⟨s, hs, hx⟩
    exact ⟨s, (mem_pathPacking n s).mpr hs, (mem_closedNbhd_pathG n s x).mpr hx⟩

/-- **2-packing.**  Two indices congruent to `1` mod `3` that differ are at distance
`≥ 3`, so their closed neighborhoods are disjoint. -/
theorem pathG_twoPacking (n : ℕ) : IsTwoPacking (PathG n) (pathPacking n) := by
  intro u hu v hv huv
  rw [mem_pathPacking] at hu hv
  rw [Finset.disjoint_left]
  intro x hxu hxv
  rw [mem_closedNbhd_pathG] at hxu hxv
  have : u.val ≠ v.val := fun h => huv (Fin.ext h)
  omega

/-- Coverage of a single edge `{a, a+1}`: a residue-`1`-mod-`3` vertex lies within
distance one of one of the two endpoints. -/
theorem pathPacking_cover (n : ℕ) (a b : Fin n) (h : a.val + 1 = b.val) :
    a ∈ nbhdSet (PathG n) (pathPacking n) ∨ b ∈ nbhdSet (PathG n) (pathPacking n) := by
  rw [mem_nbhdSet_pathPacking, mem_nbhdSet_pathPacking]
  have h3 : a.val % 3 = 0 ∨ a.val % 3 = 1 ∨ a.val % 3 = 2 := by omega
  rcases h3 with h0 | h1 | h2
  · -- `a ≡ 0`, so `b = a+1 ≡ 1`: cover via `b`.
    right; exact ⟨b, by omega, Or.inl rfl⟩
  · -- `a ≡ 1`: cover via `a` itself.
    left; exact ⟨a, h1, Or.inl rfl⟩
  · -- `a ≡ 2`, so `a-1 ≡ 1` and `a ≥ 2`: cover via the backward witness `a-1`.
    left
    refine ⟨⟨a.val - 1, by omega⟩, by simp only []; omega, ?_⟩
    right; right; simp only []; omega

/-- **Isolating.**  Every edge of the path is covered by `pathPacking n`. -/
theorem pathG_isolating (n : ℕ) : IsIsolating (PathG n) (pathPacking n) := by
  intro u v huv
  rcases huv with h | h
  · exact pathPacking_cover n u v h
  · exact (pathPacking_cover n v u h).symm

/-- **Main path result.**  Every path graph has a packing-isolating set. -/
theorem pathG_packingIsolating (n : ℕ) : IsPackingIsolating (PathG n) (pathPacking n) :=
  ⟨pathG_twoPacking n, pathG_isolating n⟩

theorem pathG_exists_packingIsolating (n : ℕ) :
    ∃ S : Finset (Fin n), IsPackingIsolating (PathG n) S :=
  ⟨pathPacking n, pathG_packingIsolating n⟩

end PackingIsolation