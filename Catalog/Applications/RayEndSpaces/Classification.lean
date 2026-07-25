/-
# Ray spaces, relabelling, and ultrametric clusters

A ray through a coordinate tree is an infinite sequence all of whose finite
initial segments belong to the tree.  This file establishes a combinatorial
classification principle: a bijective relabelling of every edge label induces
a homeomorphism of ray spaces.  It also links the strong triangle law for a
`p`-adic local multiplicity to the transitivity of the resulting nested
clusters.

The definitions isolate a concrete fragment of the ray-space classification
programme in which the combinatorial witness itself constructs the
homeomorphism.
-/
import Mathlib
import Catalog.Novelty.NumberTheory.LocalMultiplicityUltrametric

open Set
open GiampietroDarmon

namespace RayEndSpaces

/-- A coordinate tree is a prefix-closed family of finite words. -/
structure CoordinateTree (α : Type*) where
  nodes : Set (List α)
  nil_mem : [] ∈ nodes
  prefix_closed : ∀ {u v : List α}, u <+: v → v ∈ nodes → u ∈ nodes

/-- The length-`n` initial segment of an infinite sequence. -/
def initialSegment {α : Type*} (x : ℕ → α) (n : ℕ) : List α :=
  List.ofFn fun i : Fin n => x i

/-- The ray space of a coordinate tree, with its subspace topology inherited
from the product of the discrete coordinate spaces. -/
def RaySpace {α : Type*} [TopologicalSpace α] (T : CoordinateTree α) :=
  {x : ℕ → α // ∀ n, initialSegment x n ∈ T.nodes}

instance {α : Type*} [TopologicalSpace α] (T : CoordinateTree α) :
    TopologicalSpace (RaySpace T) :=
  TopologicalSpace.induced (fun x : RaySpace T => x.1) inferInstance

/-- Relabel every node of a coordinate tree along an equivalence. -/
def CoordinateTree.relabel {α β : Type*} (T : CoordinateTree α) (e : α ≃ β) :
    CoordinateTree β where
  nodes := {u | u.map e.symm ∈ T.nodes}
  nil_mem := by simpa using T.nil_mem
  prefix_closed := by
    intro u v huv hv
    exact T.prefix_closed (huv.map e.symm) hv

/-
Mapping a finite initial segment is the initial segment of the mapped ray.
-/
lemma initialSegment_map {α β : Type*} (f : α → β) (x : ℕ → α) (n : ℕ) :
    (initialSegment x n).map f = initialSegment (fun i => f (x i)) n := by
  unfold initialSegment
  exact Eq.symm (List.ofFn_comp' (fun i => x ↑i) f)

/-
Coordinatewise relabelling carries finite initial segments to relabelled
finite initial segments.
-/
lemma initialSegment_comp_equiv {α β : Type*} (e : α ≃ β) (x : ℕ → α) (n : ℕ) :
    (initialSegment (fun i => e (x i)) n).map e.symm = initialSegment x n := by
  refine' List.ext_get _ _ <;> simp +decide [ e.symm_apply_apply, initialSegment ]

/-
Coordinatewise relabelling preserves the ray condition.
-/
lemma relabel_preserves_ray {α β : Type*} [TopologicalSpace α] [TopologicalSpace β]
    (T : CoordinateTree α) (e : α ≃ β) (x : RaySpace T) :
    ∀ n, initialSegment (fun i => e (x.1 i)) n ∈ (T.relabel e).nodes := by
  intro n
  unfold CoordinateTree.relabel
  simp [initialSegment_comp_equiv] at *;
  grind +locals

/-- A homeomorphic coordinate relabelling induces a homeomorphism of ray
spaces.  The result provides a direct combinatorial certificate for a
homeomorphism rather than merely an abstract existence statement. -/
def raySpaceHomeomorph {α β : Type*} [TopologicalSpace α] [TopologicalSpace β]
    (T : CoordinateTree α) (e : α ≃ₜ β) :
    RaySpace T ≃ₜ RaySpace (T.relabel e.toEquiv) where
  toFun x := ⟨fun n => e (x.1 n), relabel_preserves_ray T e.toEquiv x⟩
  invFun y := ⟨fun n => e.symm (y.1 n), by
    intro n
    have hy := y.2 n
    simpa [CoordinateTree.relabel, initialSegment_map] using hy⟩
  left_inv x := by apply Subtype.ext; funext n; simp
  right_inv y := by apply Subtype.ext; funext n; simp
  continuous_toFun := by
    apply Continuous.subtype_mk
    apply continuous_pi
    intro n
    exact e.continuous.comp ((continuous_apply n).comp continuous_subtype_val)
  continuous_invFun := by
    apply Continuous.subtype_mk
    apply continuous_pi
    intro n
    exact e.symm.continuous.comp ((continuous_apply n).comp continuous_subtype_val)

/-- The `p`-adic multiplicity ball of radius threshold `k`, centred at `x`. -/
def valuationCluster (p : ℕ) (k : ℤ) (x : ℚ) : Set ℚ :=
  {y | y = x ∨ (x ≠ y ∧ k ≤ localMult p x y)}

/-
Ultrametric multiplicity balls are transitive: two points in the same
threshold cluster around a centre lie in the corresponding cluster around one
another.
-/
theorem valuationCluster_trans (p : ℕ) [Fact p.Prime] (k : ℤ) (x y z : ℚ)
    (hy : y ∈ valuationCluster p k x) (hz : z ∈ valuationCluster p k x) :
    z ∈ valuationCluster p k y := by
  cases eq_or_ne z y <;> cases eq_or_ne x y <;> cases eq_or_ne x z <;> simp_all +decide;
  · exact Or.inl rfl;
  · exact Or.inr ⟨ by tauto, by simpa [ GiampietroDarmon.localMult_symm ] using hy.resolve_left ( by tauto ) |>.2 ⟩;
  · cases hy <;> cases hz <;> simp_all +decide;
    -- Apply the ultrametric inequality to conclude that $k \leq \text{localMult } p y z$.
    have h_ultrametric : localMult p y z ≥ min (localMult p y x) (localMult p x z) := by
      apply localMult_ultrametric; aesop;
    exact Or.inr ⟨ by tauto, by cases min_cases ( localMult p y x ) ( localMult p x z ) <;> linarith [ GiampietroDarmon.localMult_symm p y x ] ⟩

/-
Increasing the threshold makes a valuation cluster smaller.
-/
theorem valuationCluster_antitone (p : ℕ) (x : ℚ) :
    Antitone (fun k : ℤ => valuationCluster p k x) := by
  intro k l hkl y hy
  unfold valuationCluster at *
  grind

/-
Any point of an ultrametric cluster can serve as its centre.  Thus the
threshold clusters form a laminar hierarchy rather than a family of
overlapping ordinary metric balls.
-/
theorem valuationCluster_eq_of_mem (p : ℕ) [Fact p.Prime] (k : ℤ) (x y : ℚ)
    (hy : y ∈ valuationCluster p k x) :
    valuationCluster p k y = valuationCluster p k x := by
  apply Set.eq_of_subset_of_subset;
  · intro z hz;
    apply valuationCluster_trans p k y x z;
    · exact valuationCluster_trans p k x y x hy ( Or.inl rfl );
    · assumption;
  · exact fun z hz => valuationCluster_trans p k x y z hy hz

/-- The binary full coordinate tree. -/
def binaryFullTree : CoordinateTree (Fin 2) where
  nodes := Set.univ
  nil_mem := Set.mem_univ _
  prefix_closed := by intros; exact Set.mem_univ _

example : RaySpace binaryFullTree := by
  refine ⟨fun _ : ℕ => (0 : Fin 2), ?_⟩
  intro n
  exact Set.mem_univ _

example : (2 : ℚ) ∈ valuationCluster 2 1 0 := by
  right
  constructor
  · norm_num
  · unfold localMult
    norm_num [padicValRat.neg]
    have h : padicValRat 2 (2 : ℚ) = 1 := padicValRat.self (p := 2) (by norm_num)
    exact h.ge

#check raySpaceHomeomorph
#check valuationCluster_trans

-- !-- Lab Notes -- !--
/-
Hypothesis. Seven falsifiable targets were ranked by prospective impact:
(1) arbitrary homeomorphic edge-label changes classify the associated
coordinate ray spaces; (2) coherent levelwise tree isomorphisms suffice for
homeomorphism; (3) every completely ultrametrizable space admits a coordinate
ray presentation; (4) graph end spaces admit presentations invariant under
cofinal subtree replacement; (5) threshold balls of a non-Archimedean
multiplicity form a rooted laminar hierarchy; (6) every scattered subspace of
an end space below the continuum is itself an end space; and (7) generalized
ray spaces strictly contain ordinary ray spaces. Targets (2), (3), and (6) are
the broadest classification conjectures.

Experiment. The first target survives in the explicit relabelling regime: the
coordinatewise equivalence and its inverse preserve every finite initial
segment and are continuous in the product topology.  The fifth target survives
at the local level: the imported strong triangle inequality forces cluster
transitivity, while threshold monotonicity supplies nesting.  The binary full
tree and the 2-adic cluster at threshold one give concrete examples.

Analysis. Both results exhibit the same structural pattern.  Infinite objects
are controlled by compatible finite data: prefixes for rays and threshold
clusters for valuations.  This suggests a broader inverse-limit
 generalization in which coherent finite partitions replace literal words.

Critique. The relabelling theorem is a sufficient classification criterion,
not the paper's full necessary-and-sufficient characterization.  The cluster
result does not claim that all clusters are graph ends.  Equality cases and
zero differences are boundary cases; the disjunct `y = x` makes centres belong
to their own clusters without assigning an artificial valuation to zero.
No finite computation can test the universal topological statements, so the
examples serve only as boundary checks rather than evidence of completeness.

Synthesis. A combinatorial relabelling certificate has been converted into an
explicit ray-space homeomorphism, and a number-theoretic ultrametric law has
been converted into the nesting relation that underlies rooted end models.
The natural extension is from one fixed coordinate equivalence to coherent
levelwise equivalences and then to inverse systems of clopen partitions.
-/

end RayEndSpaces