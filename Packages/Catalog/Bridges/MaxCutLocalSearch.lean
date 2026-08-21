/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The averaging bound for max-cut is a local-search algorithm

`Catalog/Bridges/MaxCutDerandomized.lean` proves that every graph has a cut containing at least
half of its edges by *counting*: the total cut size over all `2 ^ n` sides is exactly
`#edges · 2 ^ n / 2`.  That proof is an averaging argument and gives no algorithm beyond brute
force.  This file proves the same bound a second, genuinely algorithmic way, and quantifies the
running time of the algorithm:

* `cut_flip` — the exchange identity `cut (flip S v) + 2 · crossDeg S v = cut S + deg v`: moving a
  single vertex to the other side changes the cut by exactly `deg v − 2 · crossDeg S v`;
* `half_edges_le_two_mul_cut_of_locally_maximal` — hence **every locally maximal cut** (one that
  no single-vertex flip improves) already contains half of the edges;
* `improving_seq_le_card_edgeFinset` — and any strictly improving sequence of flips has length at
  most `#edges`, so the local-search algorithm terminates after at most `m` improvements.

Together these say that the Erdős-style expectation argument is a `1/2`-approximation algorithm
in disguise: the existence proof is the statement that local search cannot get stuck above the
average.

## Catalog connections
* `Bridges/MaxCutDerandomized.lean` : the counting proof of the same bound, and the definitions
  `crossPairs`, `cut`, `maxCut` reused here.
-/
import Mathlib
import Bridges.MaxCutDerandomized

open Finset

namespace MaxCutLocalSearch

open MaxCutDerandomized

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

lemma mem_crossPairs {S : Finset V} {p : V × V} :
    p ∈ crossPairs G S ↔ G.Adj p.1 p.2 ∧ p.1 ∈ S ∧ p.2 ∉ S := by
  simp [crossPairs, adjPairs]

/-- Moving the single vertex `v` to the other side of the cut. -/
def flip (S : Finset V) (v : V) : Finset V := if v ∈ S then S.erase v else insert v S

omit [Fintype V] in
lemma mem_flip_of_ne {S : Finset V} {v u : V} (h : u ≠ v) : u ∈ flip S v ↔ u ∈ S := by
  unfold flip
  split
  · simp [Finset.mem_erase, h]
  · simp [Finset.mem_insert, h]

omit [Fintype V] in
lemma mem_flip_self {S : Finset V} {v : V} : v ∈ flip S v ↔ v ∉ S := by
  unfold flip
  split <;> simp_all

/-- The number of neighbours of `v` lying on the other side of the cut `S`. -/
def crossDeg (S : Finset V) (v : V) : ℕ :=
  #((G.neighborFinset v).filter (fun u => if v ∈ S then u ∉ S else u ∈ S))

/-- The cut pairs that do not involve `v` are unaffected by flipping `v`. -/
lemma filter_crossPairs_ne_flip (S : Finset V) (v : V) :
    (crossPairs G (flip S v)).filter (fun p => p.1 ≠ v ∧ p.2 ≠ v) =
      (crossPairs G S).filter (fun p => p.1 ≠ v ∧ p.2 ≠ v) := by
  ext p
  simp only [Finset.mem_filter, mem_crossPairs]
  constructor
  · rintro ⟨⟨hadj, h1, h2⟩, hne1, hne2⟩
    exact ⟨⟨hadj, (mem_flip_of_ne hne1).1 h1, fun hc => h2 ((mem_flip_of_ne hne2).2 hc)⟩,
      hne1, hne2⟩
  · rintro ⟨⟨hadj, h1, h2⟩, hne1, hne2⟩
    exact ⟨⟨hadj, (mem_flip_of_ne hne1).2 h1, fun hc => h2 ((mem_flip_of_ne hne2).1 hc)⟩,
      hne1, hne2⟩

/-- The cut pairs that *do* involve `v` are exactly the cut edges at `v`. -/
lemma card_filter_crossPairs_eq_crossDeg (S : Finset V) (v : V) :
    #((crossPairs G S).filter (fun p => ¬(p.1 ≠ v ∧ p.2 ≠ v))) = crossDeg G S v := by
  classical
  by_cases hv : v ∈ S
  · -- the relevant pairs are `(v, u)` with `u ∉ S`
    have himg : (crossPairs G S).filter (fun p => ¬(p.1 ≠ v ∧ p.2 ≠ v)) =
        ((G.neighborFinset v).filter (fun u => u ∉ S)).image (fun u => (v, u)) := by
      ext p
      constructor
      · intro hp
        rw [Finset.mem_filter, mem_crossPairs] at hp
        obtain ⟨⟨hadj, h1, h2⟩, hor⟩ := hp
        have hp1 : p.1 = v := by
          by_contra hc
          have hp2 : p.2 = v := by
            by_contra hc2
            exact hor ⟨hc, hc2⟩
          rw [hp2] at h2
          exact h2 hv
        refine Finset.mem_image.2 ⟨p.2, ?_, ?_⟩
        · exact Finset.mem_filter.2
            ⟨(SimpleGraph.mem_neighborFinset _ _ _).2 (hp1 ▸ hadj), h2⟩
        · exact Prod.ext hp1.symm rfl
      · intro hp
        obtain ⟨u, hu, rfl⟩ := Finset.mem_image.1 hp
        rw [Finset.mem_filter, SimpleGraph.mem_neighborFinset] at hu
        refine Finset.mem_filter.2 ⟨mem_crossPairs G |>.2 ⟨hu.1, hv, hu.2⟩, ?_⟩
        rintro ⟨hne, -⟩
        exact hne rfl
    rw [himg, crossDeg, Finset.card_image_of_injective _ (fun a b hab => by simpa using hab)]
    congr 1
    refine Finset.filter_congr fun u _ => ?_
    simp [hv]
  · -- the relevant pairs are `(u, v)` with `u ∈ S`
    have himg : (crossPairs G S).filter (fun p => ¬(p.1 ≠ v ∧ p.2 ≠ v)) =
        ((G.neighborFinset v).filter (fun u => u ∈ S)).image (fun u => (u, v)) := by
      ext p
      constructor
      · intro hp
        rw [Finset.mem_filter, mem_crossPairs] at hp
        obtain ⟨⟨hadj, h1, h2⟩, hor⟩ := hp
        have hp2 : p.2 = v := by
          by_contra hc
          have hp1 : p.1 = v := by
            by_contra hc1
            exact hor ⟨hc1, hc⟩
          rw [hp1] at h1
          exact hv h1
        refine Finset.mem_image.2 ⟨p.1, ?_, ?_⟩
        · exact Finset.mem_filter.2
            ⟨(SimpleGraph.mem_neighborFinset _ _ _).2 (G.symm (hp2 ▸ hadj)), h1⟩
        · exact Prod.ext rfl hp2.symm
      · intro hp
        obtain ⟨u, hu, rfl⟩ := Finset.mem_image.1 hp
        rw [Finset.mem_filter, SimpleGraph.mem_neighborFinset] at hu
        refine Finset.mem_filter.2 ⟨mem_crossPairs G |>.2 ⟨G.symm hu.1, hu.2, hv⟩, ?_⟩
        rintro ⟨-, hne⟩
        exact hne rfl
    rw [himg, crossDeg, Finset.card_image_of_injective _ (fun a b hab => by simpa using hab)]
    congr 1
    refine Finset.filter_congr fun u _ => ?_
    simp [hv]

/-- Splitting the cut at a vertex: the cut is the pairs avoiding `v` plus the cut edges at `v`. -/
lemma cut_eq_add_crossDeg (S : Finset V) (v : V) :
    cut G S = #((crossPairs G S).filter (fun p => p.1 ≠ v ∧ p.2 ≠ v)) + crossDeg G S v := by
  rw [← card_filter_crossPairs_eq_crossDeg G S v, cut]
  exact (Finset.card_filter_add_card_filter_not (s := crossPairs G S)
    (p := fun p => p.1 ≠ v ∧ p.2 ≠ v)).symm

/-- Flipping `v` swaps the cut edges at `v` with the non-cut edges at `v`. -/
lemma crossDeg_flip_add (S : Finset V) (v : V) :
    crossDeg G (flip S v) v + crossDeg G S v = G.degree v := by
  classical
  have hcongr : (G.neighborFinset v).filter
      (fun u => if v ∈ flip S v then u ∉ flip S v else u ∈ flip S v) =
      (G.neighborFinset v).filter (fun u => ¬(if v ∈ S then u ∉ S else u ∈ S)) := by
    refine Finset.filter_congr fun u hu => ?_
    have hne : u ≠ v := G.ne_of_adj (G.symm ((SimpleGraph.mem_neighborFinset _ _ _).1 hu))
    have h1 : (u ∈ flip S v) ↔ (u ∈ S) := mem_flip_of_ne hne
    have h2 : (v ∈ flip S v) ↔ v ∉ S := mem_flip_self
    by_cases hu' : u ∈ S <;> by_cases hv' : v ∈ S <;> simp [h1, h2, hu', hv']
  rw [crossDeg, crossDeg, hcongr, add_comm,
    Finset.card_filter_add_card_filter_not, SimpleGraph.card_neighborFinset_eq_degree]

/-- **The exchange identity.**  Flipping the side of a single vertex `v` changes the cut by
exactly `deg v − 2 · crossDeg S v`, stated without natural subtraction. -/
theorem cut_flip (S : Finset V) (v : V) :
    cut G (flip S v) + 2 * crossDeg G S v = cut G S + G.degree v := by
  have h1 := cut_eq_add_crossDeg G (flip S v) v
  have h2 := cut_eq_add_crossDeg G S v
  have h3 := filter_crossPairs_ne_flip G S v
  have h4 := crossDeg_flip_add G S v
  rw [h3] at h1
  omega

/-- A cut is *locally maximal* when no single-vertex flip improves it. -/
def LocallyMaximal (S : Finset V) : Prop := ∀ v : V, cut G (flip S v) ≤ cut G S

/-- At a locally maximal cut every vertex has at least half of its edges cut. -/
lemma degree_le_two_mul_crossDeg_of_locallyMaximal {S : Finset V} (h : LocallyMaximal G S)
    (v : V) : G.degree v ≤ 2 * crossDeg G S v := by
  have := cut_flip G S v
  have hv := h v
  omega

/-- Twice the cut is the sum of the crossing degrees (each cut edge has two endpoints). -/
theorem two_mul_cut_eq_sum_crossDeg (S : Finset V) :
    2 * cut G S = ∑ v : V, crossDeg G S v := by
  classical
  have key : ∀ v : V, crossDeg G S v =
      #((crossPairs G S).filter (fun p => ¬(p.1 ≠ v ∧ p.2 ≠ v))) := fun v =>
    (card_filter_crossPairs_eq_crossDeg G S v).symm
  rw [Finset.sum_congr rfl (fun v _ => key v)]
  have hcard : ∀ v : V, #((crossPairs G S).filter (fun p => ¬(p.1 ≠ v ∧ p.2 ≠ v))) =
      ∑ p ∈ crossPairs G S, if p.1 = v ∨ p.2 = v then 1 else 0 := by
    intro v
    rw [← Finset.card_filter]
    congr 1
    apply Finset.filter_congr
    intro p _
    constructor
    · intro h
      by_cases h1 : p.1 = v
      · exact Or.inl h1
      · exact Or.inr (by
          by_contra h2
          exact h ⟨h1, h2⟩)
    · rintro (h | h) ⟨h1, h2⟩
      · exact h1 h
      · exact h2 h
  rw [Finset.sum_congr rfl (fun v _ => hcard v), Finset.sum_comm]
  have hpair : ∀ p ∈ crossPairs G S,
      (∑ v : V, if p.1 = v ∨ p.2 = v then 1 else 0) = 2 := by
    intro p hp
    rw [mem_crossPairs] at hp
    have hne : p.1 ≠ p.2 := G.ne_of_adj hp.1
    have hfil : (univ.filter (fun v : V => p.1 = v ∨ p.2 = v)) = {p.1, p.2} := by
      ext v
      simp only [Finset.mem_filter, mem_univ, true_and, Finset.mem_insert, Finset.mem_singleton]
      constructor
      · rintro (rfl | rfl) <;> simp
      · rintro (rfl | rfl) <;> simp
    rw [← Finset.card_filter, hfil, Finset.card_insert_of_notMem (by simpa using hne),
      Finset.card_singleton]
  rw [Finset.sum_congr rfl hpair, Finset.sum_const, smul_eq_mul, cut, mul_comm]

/-- **Local search cannot get stuck below the average.**  Every locally maximal cut contains at
least half of the edges — the algorithmic counterpart of the counting proof in
`Bridges/MaxCutDerandomized.lean`. -/
theorem half_edges_le_two_mul_cut_of_locally_maximal {S : Finset V} (h : LocallyMaximal G S) :
    #G.edgeFinset ≤ 2 * cut G S := by
  classical
  have hdeg : ∑ v : V, G.degree v ≤ ∑ v : V, 2 * crossDeg G S v :=
    Finset.sum_le_sum fun v _ => degree_le_two_mul_crossDeg_of_locallyMaximal G h v
  rw [G.sum_degrees_eq_twice_card_edges, ← Finset.mul_sum,
    ← two_mul_cut_eq_sum_crossDeg] at hdeg
  omega

/-- The maximiser of the exhaustive search is in particular locally maximal, so the local-search
bound recovers `MaxCutDerandomized.maxCut_ge_half_edges`. -/
theorem exists_locallyMaximal : ∃ S : Finset V, LocallyMaximal G S ∧ cut G S = maxCut G := by
  obtain ⟨S, hS⟩ := exists_cut_eq_maxCut G
  refine ⟨S, fun v => ?_, hS⟩
  rw [hS]
  exact cut_le_maxCut G (flip S v)

/-- No cut is larger than the number of edges. -/
lemma cut_le_card_edgeFinset (S : Finset V) : cut G S ≤ #G.edgeFinset := by
  classical
  rw [cut]
  refine Finset.card_le_card_of_injOn (fun p => s(p.1, p.2)) ?_ ?_
  · intro p hp
    simp only [Finset.mem_coe, mem_crossPairs] at hp
    exact SimpleGraph.mem_edgeFinset.2 hp.1
  · intro p hp q hq hpq
    simp only [Finset.mem_coe, mem_crossPairs] at hp hq
    rcases Sym2.eq_iff.1 hpq with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Prod.ext h1 h2
    · exact absurd (h1 ▸ hp.2.1) hq.2.2

/-- **Termination with an explicit iteration bound.**  A run of local search — any sequence of
sides whose cut strictly increases — has at most `#edges` steps. -/
theorem improving_seq_le_card_edgeFinset (f : ℕ → Finset V)
    (hf : ∀ i, cut G (f i) < cut G (f (i + 1))) (i : ℕ) : i ≤ #G.edgeFinset := by
  have hgrow : ∀ j, j ≤ cut G (f j) := by
    intro j
    induction j with
    | zero => exact Nat.zero_le _
    | succ k ih => exact Nat.succ_le_of_lt (lt_of_le_of_lt ih (hf k))
  exact (hgrow i).trans (cut_le_card_edgeFinset G (f i))

end MaxCutLocalSearch