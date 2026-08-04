/-
# Closed walks in a Cayley graph are relations in the connection set

`Catalog/Bridges/GraphTheory/CayleyCharacterSpectra.lean` proves, for finite *abelian*
groups, that the number of closed `k`-walks in a Cayley graph equals `|G|` times the
number of length-`k` additive relations in the connection set, via Fourier analysis on
the Pontryagin dual.

This file proves the counting half of that statement for **every** finite group, abelian
or not, by a direct bijective/inductive argument: for any base point `x`,

```
#{closed k-walks at x} = #{(s₁,…,s_k) ∈ Sᵏ : s₁ ⋯ s_k = 1}.
```

In particular the count does not depend on the base point (a quantitative form of
vertex-transitivity), and summing over `x` gives
`#{closed k-walks} = |G| · #{length-k relations in S}`.

Together the two files say: for the whole census of Cayley graphs of finite groups, the
cycle statistics of the graph are exactly the relation counts of the connection set, and
in the abelian case those counts are computed by character sums.
-/

import Mathlib.Tactic
import Mathlib.Combinatorics.SimpleGraph.AdjMatrix
import Mathlib.Data.Fintype.Pi
import Mathlib.GroupTheory.Perm.Fin

open Finset

namespace CayleyWalkRelations

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-! ## The Cayley graph of an arbitrary finite group -/

/-- The Cayley graph of a finite group with respect to a symmetric connection set `S`
avoiding the identity. -/
def cayleyGraph (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S) (h1 : (1 : G) ∉ S) :
    SimpleGraph G where
  Adj x y := x⁻¹ * y ∈ S
  symm := by
    intro x y h
    have := hsymm _ h
    simpa using this
  loopless := ⟨fun x h => h1 (by simpa using h)⟩

instance instDecidableAdj (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S) (h1 : (1 : G) ∉ S) :
    DecidableRel (cayleyGraph S hsymm h1).Adj :=
  fun x y => decidable_of_iff (x⁻¹ * y ∈ S) Iff.rfl

omit [Fintype G] [DecidableEq G] in
@[simp] lemma cayleyGraph_adj (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S) (h1 : (1 : G) ∉ S)
    (x y : G) : (cayleyGraph S hsymm h1).Adj x y ↔ x⁻¹ * y ∈ S := Iff.rfl

/-! ## Step tuples, relations, and path counts -/

/-- All `k`-tuples of steps taken from `S`. -/
def stepTuples (S : Finset G) (k : ℕ) : Finset (Fin k → G) := Fintype.piFinset fun _ => S

/-- The number of length-`k` relations in `S`: tuples `(s₁,…,s_k) ∈ Sᵏ` whose product,
taken in order, is the identity. -/
def relationCount (S : Finset G) (k : ℕ) : ℕ :=
  ((stepTuples S k).filter fun p => (List.ofFn p).prod = 1).card

/-- The number of `k`-step routes from `x` to `y` with all steps in `S`. -/
def pathCount (S : Finset G) (k : ℕ) (x y : G) : ℕ :=
  ((stepTuples S k).filter fun p => x * (List.ofFn p).prod = y).card

omit [Fintype G] [DecidableEq G] in
/-- Prepending a step multiplies the route product on the left. -/
@[simp] lemma prod_ofFn_cons {k : ℕ} (s : G) (p : Fin k → G) :
    (List.ofFn (Fin.cons s p : Fin (k + 1) → G)).prod = s * (List.ofFn p).prod := by
  simp [List.ofFn_succ]

omit [Group G] [Fintype G] [DecidableEq G] in
@[simp] lemma mem_stepTuples {k : ℕ} {S : Finset G} {p : Fin k → G} :
    p ∈ stepTuples S k ↔ ∀ i, p i ∈ S := by
  simp [stepTuples]

omit [Fintype G] in
/-- Peeling off the first step of a route. -/
lemma pathCount_succ (S : Finset G) (k : ℕ) (x y : G) :
    pathCount S (k + 1) x y = ∑ s ∈ S, pathCount S k (x * s) y := by
  unfold pathCount stepTuples
  simp only [Fintype.piFinset]
  let f := fun p : (Fin (k + 1) → G) => (p 0, fun i => p (Fin.succ i))
  -- rewrite the product condition by peeling the first coordinate
  have h_prod : ∀ p : Fin (k + 1) → G, x * (List.ofFn p).prod = y ↔
      x * (f p).1 * (List.ofFn (f p).2).prod = y := by
    intro p
    have hp_eq : p = Fin.cons (p 0) (fun i => p i.succ) := by ext i; cases i using Fin.cases <;> rfl
    simp only [f]
    conv_lhs => rw [hp_eq, prod_ofFn_cons]
    rw [mul_assoc]
  let L := {p ∈ stepTuples S (k + 1) | x * (List.ofFn p).prod = y}
  have h_goal_lhs : {p ∈ Fintype.piFinset fun _ : Fin (k + 1) => S | x * (List.ofFn p).prod = y} = L := by
    ext p; simp [L]
  convert congr_arg Finset.card h_goal_lhs using 1
  have h_L_eq_biUnion : L = S.biUnion fun s => Finset.image (fun q : Fin k → G => Fin.cons s q)
      ((stepTuples S k).filter fun q => x * s * (List.ofFn q).prod = y) := by
    ext p
    simp only [Finset.mem_biUnion, Finset.mem_image]
    constructor
    · intro hp
      have hp' := Finset.mem_filter.mp hp
      rw [mem_stepTuples] at hp'
      refine ⟨p 0, ?_, fun i => p i.succ, ?_, ?_⟩
      · exact hp'.1 0
      · have h_mem_succ := mem_stepTuples.mpr (fun i => hp'.1 i.succ)
        have h_prod_succ : x * p 0 * (List.ofFn (fun i => p i.succ)).prod = y := by
          have := hp'.2
          rw [h_prod p] at this
          show x * (f p).1 * (List.ofFn (f p).2).prod = y
          convert this
        exact Finset.mem_filter.mpr ⟨h_mem_succ, h_prod_succ⟩
      · ext i; cases i using Fin.cases <;> rfl
    · rintro ⟨s, hs, q, hq, rfl⟩
      simp only [L, Finset.mem_filter]
      have hq' := Finset.mem_filter.mp hq
      rw [mem_stepTuples] at hq'
      refine ⟨?_, ?_⟩
      · rw [mem_stepTuples]
        intro i; cases i using Fin.cases <;> [exact hs; exact hq'.1 _]
      · rw [prod_ofFn_cons, ← mul_assoc]; exact hq'.2
  rw [h_L_eq_biUnion, Finset.card_biUnion]
  · apply Finset.sum_congr rfl
    intro s hs
    rw [Finset.card_image_of_injective _ (fun _ _ h => by simpa [Fin.cons] using h)]
    rfl
  · intro s hs t ht hst
    simp only [Function.onFun, Finset.disjoint_left]
    intro a ha ht_a
    simp only [Finset.mem_image] at ha ht_a
    obtain ⟨q1, _, rfl⟩ := ha
    obtain ⟨q2, _, hr⟩ := ht_a
    have h0 := congrArg (fun f => f 0) hr
    simp at h0
    exact hst h0.symm

omit [Fintype G] in
/-- Routes of length `0`. -/
lemma pathCount_zero (S : Finset G) (x y : G) :
    pathCount S 0 x y = if x = y then 1 else 0 := by
  unfold pathCount stepTuples
  simp [List.ofFn]
  split_ifs <;> simp

/-- Neighbourhoods of a Cayley graph are translates of the connection set. -/
lemma neighborFinset_eq_image (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S) (h1 : (1 : G) ∉ S)
    (x : G) : (cayleyGraph S hsymm h1).neighborFinset x = S.image (fun s => x * s) := by
  ext y
  simp [SimpleGraph.mem_neighborFinset, cayleyGraph_adj]

/-- **Powers of the adjacency matrix count routes.** -/
lemma adjMatrix_pow_apply_eq_pathCount (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : G) ∉ S) (k : ℕ) (x y : G) :
    (((cayleyGraph S hsymm h1).adjMatrix ℕ) ^ k) x y = pathCount S k x y := by
  induction k generalizing x with
  | zero => simp [pathCount_zero, Matrix.one_apply]
  | succ k ih =>
    rw [pow_succ', SimpleGraph.adjMatrix_mul_apply, pathCount_succ, neighborFinset_eq_image,
      Finset.sum_image (by intro a _ b _ h; exact mul_left_cancel h)]
    exact Finset.sum_congr rfl fun s _ => ih (x * s)

omit [Fintype G] in
/-- Closed routes at `x` are exactly the relations in `S`, independently of `x`. -/
lemma pathCount_self (S : Finset G) (k : ℕ) (x : G) :
    pathCount S k x x = relationCount S k := by
  simp [pathCount, relationCount]

/-! ## The bridge -/

/-- **Main theorem.**  For every finite group and every base point, the number of closed
`k`-walks at that point in a Cayley graph equals the number of length-`k` relations in
the connection set. -/
theorem card_closedWalk_eq_relationCount (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : G) ∉ S) (k : ℕ) (x : G) :
    Fintype.card {p : (cayleyGraph S hsymm h1).Walk x x | p.length = k} =
      relationCount S k := by
  have h := SimpleGraph.adjMatrix_pow_apply_eq_card_walk (α := ℕ) (G := cayleyGraph S hsymm h1) k x x
  simp_all [adjMatrix_pow_apply_eq_pathCount, pathCount_self]

/-- Closed-walk counts of a Cayley graph are independent of the base point. -/
theorem card_closedWalk_eq_card_closedWalk (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : G) ∉ S) (k : ℕ) (x y : G) :
    Fintype.card {p : (cayleyGraph S hsymm h1).Walk x x | p.length = k} =
      Fintype.card {p : (cayleyGraph S hsymm h1).Walk y y | p.length = k} := by
  rw [card_closedWalk_eq_relationCount S hsymm h1 k x,
    card_closedWalk_eq_relationCount S hsymm h1 k y]

/-- **Cross-domain corollary, general case.**  The total number of closed `k`-walks in
the Cayley graph of any finite group is `|G|` times the number of length-`k` relations
in the connection set. -/
theorem closedWalk_count_eq_card_mul_relationCount (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : G) ∉ S) (k : ℕ) :
    ∑ x : G, Fintype.card {p : (cayleyGraph S hsymm h1).Walk x x | p.length = k} =
      Fintype.card G * relationCount S k := by
  rw [Finset.sum_congr rfl fun x _ => card_closedWalk_eq_relationCount S hsymm h1 k x]
  simp [mul_comm]

/-- If `S` has no length-`k` relation, the Cayley graph has no closed `k`-walk.  For
`k = 3` this is the product-free criterion for triangle-freeness. -/
theorem isEmpty_closedWalk_of_relationCount_eq_zero (S : Finset G) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : G) ∉ S) (k : ℕ) (h : relationCount S k = 0) (x : G) :
    IsEmpty {p : (cayleyGraph S hsymm h1).Walk x x | p.length = k} :=
  Fintype.card_eq_zero_iff.mp (by rw [card_closedWalk_eq_relationCount S hsymm h1 k x, h])

/-! ## A nonabelian worked example -/

/-- The three transpositions of `S₃`. -/
def transS3 : Finset (Equiv.Perm (Fin 3)) := Finset.univ.filter (fun g => g ≠ 1 ∧ g * g = 1)

lemma transS3_symm : ∀ s ∈ transS3, s⁻¹ ∈ transS3 := by decide

lemma transS3_one_notMem : (1 : Equiv.Perm (Fin 3)) ∉ transS3 := by decide

/-- The Cayley graph of `S₃` on its transpositions is `K_{3,3}`; it has `162 = 6 · 27`
closed walks of length `4`, one factor `6 = |S₃|` and one factor `27` counting the
ordered products of four transpositions equal to the identity. -/
theorem s3_closedWalk_count_four :
    ∑ x : Equiv.Perm (Fin 3),
      Fintype.card {p : (cayleyGraph transS3 transS3_symm transS3_one_notMem).Walk x x |
        p.length = 4} = 162 := by
  rw [closedWalk_count_eq_card_mul_relationCount]
  decide

/-- No product of three transpositions is the identity, so the Cayley graph of `S₃` on
its transpositions has no closed `3`-walk: it is triangle-free. -/
theorem s3_no_closed_walk_three (x : Equiv.Perm (Fin 3)) :
    IsEmpty {p : (cayleyGraph transS3 transS3_symm transS3_one_notMem).Walk x x |
      p.length = 3} :=
  isEmpty_closedWalk_of_relationCount_eq_zero transS3 transS3_symm transS3_one_notMem 3
    (by decide) x

end CayleyWalkRelations