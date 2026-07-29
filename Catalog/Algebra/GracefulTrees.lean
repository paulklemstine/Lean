import Mathlib

/-!
# Graceful labelings of paths and their decomposition connection

The Graceful Tree Conjecture is open.  This file formalizes the standard notion and proves
an infinite established case: every finite path is graceful.  It also proves the elementary
counting theorem used when graceful copies partition the edges of a complete graph.
-/

open Finset SimpleGraph

namespace GracefulTrees

/-- `f` gracefully labels `G` with edge parameter `m`: vertices get distinct labels in
`0,…,m`, every edge has a difference in `1,…,m`, and every such difference occurs. -/
def IsGraceful {V : Type*} (G : SimpleGraph V) (m : ℕ) (f : V → ℕ) : Prop :=
  Function.Injective f ∧
  (∀ v, f v ≤ m) ∧
  (∀ ⦃u v⦄, G.Adj u v → Nat.dist (f u) (f v) ∈ Finset.Icc 1 m) ∧
  (∀ d ∈ Finset.Icc 1 m, ∃ u v, G.Adj u v ∧ Nat.dist (f u) (f v) = d)

/-- A graph has a graceful labeling with parameter `m`. -/
def HasGracefulLabeling {V : Type*} (G : SimpleGraph V) (m : ℕ) : Prop :=
  ∃ f : V → ℕ, IsGraceful G m f

/-- The usual alternating graceful labeling of the path on `n+1` vertices:
`0,n,1,n-1,2,n-2,…`. -/
def pathLabel (n : ℕ) (i : Fin (n + 1)) : ℕ :=
  if Even i.1 then i.1 / 2 else n - i.1 / 2

/-- Every alternating path label lies between zero and `n`. -/
theorem pathLabel_le (n : ℕ) (i : Fin (n + 1)) : pathLabel n i ≤ n := by
  unfold pathLabel
  split_ifs <;> omega

/-- The alternating path labeling is injective. -/
theorem pathLabel_injective (n : ℕ) : Function.Injective (pathLabel n) := by
  intro i j hij
  rw [pathLabel, pathLabel] at hij
  rcases Nat.even_or_odd i.1 with ⟨ki, hki⟩ | ⟨ki, hki⟩ <;>
  rcases Nat.even_or_odd j.1 with ⟨kj, hkj⟩ | ⟨kj, hkj⟩ <;>
  simp_all
  · -- both even
    omega
  · -- i even, j odd
    omega
  · -- i odd, j even
    omega
  · -- both odd
    omega

/-- Consecutive labels have differences `n,n-1,…,1`. -/
theorem pathLabel_consecutive (n : ℕ) (i : Fin (n + 1)) (hi : i.1 + 1 < n + 1) :
    Nat.dist (pathLabel n i) (pathLabel n ⟨i.1 + 1, hi⟩) = n - i.1 := by
  unfold pathLabel
  by_cases heven : Even i.1
  · -- i is even, so i+1 is odd
    have hodd : ¬Even (i.1 + 1) := by simp [heven, parity_simps]
    simp [heven, hodd]
    obtain ⟨k, hk⟩ := heven
    have hi2 : (i.1 + 1) / 2 = i.1 / 2 := by omega
    rw [hi2]
    simp [Nat.dist]
    omega
  · -- i is odd, so i+1 is even
    have heven_succ : Even (i.1 + 1) := by simp [heven, parity_simps]
    simp [heven, heven_succ]
    obtain ⟨k, hk⟩ := heven_succ
    simp [Nat.dist]
    omega

/-- The standard alternating labeling is graceful on Mathlib's path graph. -/
theorem pathGraph_isGraceful (n : ℕ) :
    IsGraceful (pathGraph (n + 1)) n (pathLabel n) := by
  refine ⟨pathLabel_injective n, pathLabel_le n, ?_, ?_⟩
  · intro u v huv
    rw [pathGraph_adj] at huv
    rcases huv with huv | hvu
    · have hi : u.1 + 1 < n + 1 := by omega
      have hv : v = ⟨u.1 + 1, hi⟩ := Fin.ext huv.symm
      subst v
      rw [pathLabel_consecutive n u hi, Finset.mem_Icc]
      omega
    · have hi : v.1 + 1 < n + 1 := by omega
      have hu : u = ⟨v.1 + 1, hi⟩ := Fin.ext hvu.symm
      subst u
      rw [Nat.dist_comm, pathLabel_consecutive n v hi, Finset.mem_Icc]
      omega
  · intro d hd
    rw [Finset.mem_Icc] at hd
    let i : Fin (n + 1) := ⟨n - d, by omega⟩
    have hi : i.1 + 1 < n + 1 := by simp [i]; omega
    refine ⟨i, ⟨i.1 + 1, hi⟩, ?_, ?_⟩
    · rw [pathGraph_adj]
      exact Or.inl rfl
    · rw [pathLabel_consecutive n i hi]
      simp [i]
      omega

/-- Every finite path admits a graceful labeling. -/
theorem pathGraph_hasGracefulLabeling (n : ℕ) :
    HasGracefulLabeling (pathGraph (n + 1)) n :=
  ⟨pathLabel n, pathGraph_isGraceful n⟩

/-- A finite family of edge sets partitions a host graph when every host edge belongs to
exactly one member. -/
def EdgePartition {W : Type*} [Fintype W] (K : SimpleGraph W) [Fintype K.edgeSet]
    (ι : Type*) [Fintype ι] (pieces : ι → Finset (Sym2 W)) : Prop :=
  (∀ i, pieces i ⊆ K.edgeFinset) ∧
  (∀ e ∈ K.edgeFinset, ∃! i, e ∈ pieces i)

/-- **Decomposition counting theorem.** If copies partition a finite host graph and every
copy has `m` edges, then the host has `|ι|·m` edges.  In particular this supplies the
necessary divisibility condition in complete-graph decomposition constructions arising
from graceful labelings. -/
theorem edgePartition_card {W : Type*} [Fintype W] [DecidableEq W]
    (K : SimpleGraph W) [Fintype K.edgeSet] (ι : Type*) [Fintype ι]
    (pieces : ι → Finset (Sym2 W)) (m : ℕ)
    (hpart : EdgePartition K ι pieces) (hcard : ∀ i, (pieces i).card = m) :
    K.edgeFinset.card = Fintype.card ι * m := by
  classical
  have hunion : Finset.univ.biUnion pieces = K.edgeFinset := by
    ext e
    constructor
    · intro he
      rw [Finset.mem_biUnion] at he
      obtain ⟨i, _, hei⟩ := he
      exact hpart.1 i hei
    · intro he
      obtain ⟨i, hei, _⟩ := hpart.2 e he
      rw [Finset.mem_biUnion]
      exact ⟨i, Finset.mem_univ _, hei⟩
  have hdisj : ((Finset.univ : Finset ι) : Set ι).PairwiseDisjoint pieces := by
    intro i _ j _ hij
    change Disjoint (pieces i) (pieces j)
    rw [Finset.disjoint_left]
    intro e hei hej
    obtain ⟨k, hk, huniq⟩ := hpart.2 e (hpart.1 i hei)
    exact hij ((huniq i hei).trans (huniq j hej).symm)
  have hsum : K.edgeFinset.card = ∑ i, (pieces i).card := by
    rw [← hunion, Finset.card_biUnion hdisj]
  rw [hsum]
  simp [hcard]

end GracefulTrees