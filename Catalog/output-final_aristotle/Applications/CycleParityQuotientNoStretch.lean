/-
Copyright (c) 2026. All rights reserved.

# No-stretching for GF(2) quotient labelings from edge partitions

Let `G` be a connected simple graph with an edge partition into `t` classes.  Associating a `GF(2)`
generator `gen i` with each class `i` and quotienting the ambient parity space `(Fin t → ZMod 2)` by
the *cycle-class parity space* `C` produces a labeling `ℓ : V → Q` into the abelian `2`-group
`Q = (Fin t → ZMod 2) ⧸ C`, whose dimension is `t - rank(A)` where `A` is the cycle-class parity
matrix and `rank(A) = dim C`.

The defining local property of this labeling is that adjacent vertices either receive the same label
or differ by a single class generator.  We prove the **no-stretching** property:

  `d_H(ℓ u, ℓ v) ≤ d_G(u, v)`,

where `H` is the **Cayley graph** of `Q` on the generating set `{gen i}`.  The labeling can only
contract distances (shortcuts), never stretch them.

The heart of the argument is a general fact about *edge-contracting* graph maps
(`dist_contract`): any vertex map that sends adjacent vertices to adjacent-or-equal vertices is
distance non-increasing.  This is the discrete analogue of a `1`-Lipschitz map and it directly
generalizes the hypercube no-stretching result in `Catalog/Applications/HypercubeNoStretch.lean` from
the coordinate hypercube to an arbitrary Cayley graph of an abelian `2`-group.

## Main results

* `dist_contract` — edge-contracting maps do not stretch graph distance.
* `cayley_no_stretch` — a labeling compatible with a symmetric generating set does not stretch
  distances into the Cayley graph.
* `cayley_no_stretch_partition` — the edge-partition / class-generator form of the theorem.
* `quotient_finrank` — the quotient target has dimension `t - rank(A)`.
* `tri_cayley_no_stretch` / `tri_hamming_stretches` — a concrete triangle showing that the naive
  *coordinate-hypercube* (Hamming) interpretation **stretches** distances, whereas the Cayley-graph
  interpretation does not.  This pins down the correct target graph `H`.
-/
import Mathlib

open SimpleGraph

namespace CycleParityQuotient

/-! ## Core: edge-contracting maps do not stretch distance -/

/-- A vertex map that sends each `G`-edge to a `H`-edge **or** to a single point turns any `G`-walk
into an `H`-walk of no greater length. -/
theorem contract_walk {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (φ : V → W) (hφ : ∀ ⦃a b⦄, G.Adj a b → H.Adj (φ a) (φ b) ∨ φ a = φ b)
    {u v : V} (p : G.Walk u v) : ∃ q : H.Walk (φ u) (φ v), q.length ≤ p.length := by
  induction p with
  | nil => exact ⟨Walk.nil, le_refl _⟩
  | @cons a b c hab p ih =>
    obtain ⟨q, hq⟩ := ih
    rcases hφ hab with h | h
    · exact ⟨Walk.cons h q, by simpa using Nat.succ_le_succ hq⟩
    · refine ⟨q.copy h.symm rfl, ?_⟩
      rw [Walk.length_copy]; simp only [Walk.length]; omega

/-- **Edge-contracting maps are distance non-increasing.**  For connected `G`, a map sending
adjacent vertices to adjacent-or-equal vertices satisfies `d_H(φ u, φ v) ≤ d_G(u, v)`. -/
theorem dist_contract {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (φ : V → W) (hφ : ∀ ⦃a b⦄, G.Adj a b → H.Adj (φ a) (φ b) ∨ φ a = φ b)
    (hG : G.Connected) (u v : V) : H.dist (φ u) (φ v) ≤ G.dist u v := by
  obtain ⟨p, hp⟩ := (hG.preconnected u v).exists_walk_length_eq_dist
  obtain ⟨q, hq⟩ := contract_walk φ hφ p
  calc H.dist (φ u) (φ v) ≤ q.length := SimpleGraph.dist_le q
    _ ≤ p.length := hq
    _ = G.dist u v := hp

/-! ## The Cayley graph of an abelian `2`-group -/

/-- The Cayley graph of an additive group on a symmetric generating set `S`: `x ~ y` iff
`x ≠ y` and `x - y ∈ S`. -/
def cayleyGraph {Q : Type*} [AddGroup Q] (S : Set Q) (hS : ∀ s ∈ S, -s ∈ S) :
    SimpleGraph Q where
  Adj x y := x ≠ y ∧ x - y ∈ S
  symm := by
    rintro x y ⟨hne, hmem⟩
    exact ⟨hne.symm, by have := hS _ hmem; simpa [neg_sub] using this⟩
  loopless := ⟨fun x h => h.1 rfl⟩

lemma cayleyGraph_adj {Q : Type*} [AddGroup Q] {S : Set Q} {hS : ∀ s ∈ S, -s ∈ S} {x y : Q} :
    (cayleyGraph S hS).Adj x y ↔ (x ≠ y ∧ x - y ∈ S) := Iff.rfl

/-! ## No-stretching of quotient labelings -/

/-- **No-stretching for quotient labelings.**  If `ℓ` is compatible with a symmetric generating set
`S` — adjacent vertices either share a label or differ by a generator — then the Cayley-graph
distance between labels never exceeds the graph distance. -/
theorem cayley_no_stretch {V Q : Type*} [AddGroup Q] {G : SimpleGraph V}
    {S : Set Q} (hS : ∀ s ∈ S, -s ∈ S) (ℓ : V → Q)
    (hℓ : ∀ ⦃u v : V⦄, G.Adj u v → ℓ u = ℓ v ∨ ℓ u - ℓ v ∈ S)
    (hG : G.Connected) (u v : V) :
    (cayleyGraph S hS).dist (ℓ u) (ℓ v) ≤ G.dist u v := by
  apply dist_contract ℓ _ hG
  intro a b hab
  rcases hℓ hab with h | h
  · exact Or.inr h
  · by_cases heq : ℓ a = ℓ b
    · exact Or.inr heq
    · exact Or.inl ⟨heq, h⟩

/-- **Edge-partition form.**  With `t` edge classes and class generators `gen : Fin t → Q` in an
abelian group, a labeling for which each edge realizes `ℓ u - ℓ v = gen i` for some class `i` does
not stretch distances into the Cayley graph on the generating set `range gen`. -/
theorem cayley_no_stretch_partition {V Q : Type*} [AddCommGroup Q] {G : SimpleGraph V}
    {t : ℕ} (gen : Fin t → Q) (hgen : ∀ i, -gen i ∈ Set.range gen)
    (ℓ : V → Q) (hℓ : ∀ ⦃u v : V⦄, G.Adj u v → ∃ i, ℓ u - ℓ v = gen i)
    (hG : G.Connected) (u v : V) :
    (cayleyGraph (Set.range gen)
      (by rintro s ⟨i, rfl⟩; exact hgen i)).dist (ℓ u) (ℓ v) ≤ G.dist u v := by
  refine cayley_no_stretch _ ℓ ?_ hG u v
  intro a b hab
  obtain ⟨i, hi⟩ := hℓ hab
  exact Or.inr ⟨i, hi.symm⟩

/-! ## The quotient dimension `t - rank(A)` -/

/-- **Quotient dimension.**  Over `GF(2)`, the target group `(Fin t → ZMod 2) ⧸ C` of the quotient
labeling has dimension `t - rank(A)`, where `rank(A) = dim C` is the rank of the cycle-class parity
space `C`. -/
theorem quotient_finrank (t : ℕ) (C : Submodule (ZMod 2) (Fin t → ZMod 2)) :
    Module.finrank (ZMod 2) ((Fin t → ZMod 2) ⧸ C) = t - Module.finrank (ZMod 2) C := by
  have h := Submodule.finrank_quotient_add_finrank C
  have ht : Module.finrank (ZMod 2) (Fin t → ZMod 2) = t := by simp
  omega

/-! ## A triangle: the Cayley target is right, the coordinate hypercube is wrong

The triangle `K₃` with all three edges in distinct classes has a one-dimensional cycle-class parity
space `C = ⟨(1,1,1)⟩`, so the quotient is `(ZMod 2)^2`.  The class generators become
`gen 0 = (1,0)`, `gen 1 = (0,1)`, `gen 2 = (1,1)`, and the quotient labeling is
`lab 0 = (0,0)`, `lab 1 = (1,0)`, `lab 2 = (1,1)`.

The edge `{0,2}` (class `2`) is a *single* Cayley step `gen 2 = (1,1)`, so `d_H(lab 0, lab 2) = 1`,
matching `d_G(0,2) = 1`.  But in the *coordinate hypercube* with Hamming distance,
`(0,0)` and `(1,1)` are at distance `2` — the labeling would appear to **stretch** an edge.  This is
why the correct target is the Cayley graph on the class generators, not the coordinate hypercube. -/

/-- Class generators of the triangle in the quotient `(ZMod 2)^2`. -/
def gen : Fin 3 → (Fin 2 → ZMod 2) := ![![1, 0], ![0, 1], ![1, 1]]

/-- The quotient labeling of the triangle's three vertices. -/
def lab : Fin 3 → (Fin 2 → ZMod 2) := ![![0, 0], ![1, 0], ![1, 1]]

lemma gen_symm : ∀ i, -gen i ∈ Set.range gen := fun i => ⟨i, by fin_cases i <;> decide⟩

lemma tri_edge_gen : ∀ ⦃u v : Fin 3⦄,
    (⊤ : SimpleGraph (Fin 3)).Adj u v → ∃ i, lab u - lab v = gen i := by
  intro u v; fin_cases u <;> fin_cases v <;> decide

/-- **No-stretching on the triangle (correct target).**  Into the Cayley graph on the class
generators, the quotient labeling of `K₃` never stretches distances. -/
theorem tri_cayley_no_stretch (u v : Fin 3) :
    (cayleyGraph (Set.range gen) (by rintro s ⟨i, rfl⟩; exact gen_symm i)).dist (lab u) (lab v)
      ≤ (⊤ : SimpleGraph (Fin 3)).dist u v :=
  cayley_no_stretch_partition gen gen_symm lab tri_edge_gen connected_top u v

/-- On the triangle the edge `{0,2}` is a single Cayley step: `lab 0` and `lab 2` are adjacent. -/
theorem tri_cayley_adj :
    (cayleyGraph (Set.range gen) (by rintro s ⟨i, rfl⟩; exact gen_symm i)).Adj (lab 0) (lab 2) := by
  rw [cayleyGraph_adj]
  exact ⟨by decide, ⟨2, by decide⟩⟩

/-- The graph distance across the edge `{0,2}` of the triangle is `1`. -/
theorem tri_graph_dist : (⊤ : SimpleGraph (Fin 3)).dist 0 2 = 1 := by
  have hadj : (⊤ : SimpleGraph (Fin 3)).Adj 0 2 := by simp [SimpleGraph.top_adj]
  refine le_antisymm ?_ ?_
  · calc (⊤ : SimpleGraph (Fin 3)).dist 0 2 ≤ (Walk.cons hadj Walk.nil).length :=
          SimpleGraph.dist_le _
      _ = 1 := by simp [Walk.length]
  · rw [Nat.one_le_iff_ne_zero]
    intro hc
    rw [SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable] at hc
    rcases hc with h | h
    · exact (by decide : (0 : Fin 3) ≠ 2) h
    · exact h (connected_top.preconnected 0 2)

/-- **The coordinate-hypercube interpretation stretches.**  The Hamming distance between the labels
of the adjacent vertices `0` and `2` is `2`, strictly larger than their graph distance `1`.  Since
the coordinate-hypercube graph distance equals the Hamming distance, reading `H` as the coordinate
hypercube would violate no-stretching. -/
theorem tri_hamming_stretches :
    (⊤ : SimpleGraph (Fin 3)).dist 0 2 < hammingDist (lab 0) (lab 2) := by
  rw [tri_graph_dist]
  have : hammingDist (lab 0) (lab 2) = 2 := by decide
  omega

end CycleParityQuotient

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  For a connected graph G with an edge partition into t classes, the GF(2) quotient labeling
  ℓ : V → (ZMod 2)^t ⧸ C (C = cycle-class parity space, dim = rank A) satisfies
  d_G(u,v) ≥ d_H(ℓ u, ℓ v). Bold sub-conjecture: H is literally the coordinate hypercube on
  (ZMod 2)^(t - rank A) with Hamming distance.

EXPERIMENT (Experimenter).
  Abstracted the mechanism to the reusable lemma `dist_contract`: any vertex map sending adjacent
  vertices to adjacent-OR-equal vertices is distance non-increasing (proved by walk induction with
  Walk.copy to absorb contracted edges). Instantiated it at the Cayley graph of an abelian 2-group
  (`cayley_no_stretch`, `cayley_no_stretch_partition`) and confirmed the dimension count
  `t - rank A` via rank–nullity (`quotient_finrank`).

ANALYSIS (Analyst).
  The general no-stretching theorem is TRUE and clean: each edge is exactly one generator step, so
  it maps to one Cayley edge (or a fixed point when the generator lies in C). The bold
  coordinate-hypercube sub-conjecture is FALSE. On K₃ with three singleton classes, C = ⟨(1,1,1)⟩,
  and gen 2 = (1,1) has Hamming weight 2. So the edge {0,2} — graph distance 1 — has label Hamming
  distance 2: a stretch. The failure is structural, not an artifact: a linear quotient of GF(2)^t is
  Hamming-non-expanding only when the generators map to coordinate directions, which fails whenever a
  cycle forces a generator to be a sum of others.

CRITIQUE (Critic).
  Is the counterexample vacuous? No: `tri_cayley_adj` shows the labels ARE Cayley-adjacent (distance
  ≤ 1) while `tri_hamming_stretches` shows Hamming distance 2 > graph distance 1, with
  `tri_graph_dist` proving the graph distance is genuinely 1 (not 0). So the same labeling
  simultaneously satisfies no-stretching in the Cayley target and violates it in the coordinate
  hypercube. The theorem `cayley_no_stretch` uses induction/rcases/by_cases (non-trivial), not
  `decide`. The concrete finite facts (`gen_symm`, `tri_edge_gen`, Hamming value) are discharged by
  `decide`, but they are lemmas feeding genuine theorems, not the main results.

SYNTHESIS (PI).
  The correct statement of the no-stretching property must take H to be the Cayley graph of the GF(2)
  quotient on the class generators; the coordinate-hypercube reading holds only in the corank-0
  (forest-like / partial-cube) regime where the generators stay independent. `dist_contract`
  generalizes the sibling result `HypercubeNoStretch.no_stretching` from Hamming to any Cayley
  target, unifying both under "edge-contracting maps don't stretch distance".
-/