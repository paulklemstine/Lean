/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Applications.Z2CoindexJoinClassification

/-!
# Finite composition law for the ℤ₂ co-index

This development connects equivariant topology with the additive bookkeeping of finite composite
systems.  A `FiniteFreeSystem` is a nonempty finite free ℤ₂-system.  Its binary composition is the
simplicial join, and `composeMany` is the right-associated composition of an arbitrary finite list.

The principal result, `coind_composeMany`, proves the exact many-body law

`coind (K₀ ⋆ K₁ ⋆ ⋯ ⋆ Kᵣ) = ∑ᵢ coind Kᵢ + r`.

Thus the shifted quantity `coind K + 1` is extensive: it is exactly additive under composition.
This simultaneously extends the two-factor classification theorem from the catalog and the earlier
multi-join theorem, which was restricted to octahedral spheres.
-/

namespace Z2CoindexFiniteComposition

open Z2CoindexJoin

/-- A finite, nonempty free ℤ₂-system.  The chosen vertex records nonemptiness; no basepoint is
preserved by morphisms or used in the invariant. -/
structure FiniteFreeSystem where
  /-- The underlying free ℤ₂-set. -/
  space : FreeZ2
  /-- Finiteness of the vertex set. -/
  finiteV : Fintype space.V
  /-- A witness that the system is nonempty. -/
  vertex : space.V

attribute [instance] FiniteFreeSystem.finiteV

/-- Binary composition of finite free systems is their equivariant simplicial join. -/
def FiniteFreeSystem.compose (A B : FiniteFreeSystem) : FiniteFreeSystem where
  space := A.space ⋆ B.space
  finiteV := instFintypeJoinV A.space B.space
  vertex := Sum.inl A.vertex

/-- Right-associated composition of a head system with a list of further systems. -/
def composeMany : FiniteFreeSystem → List FiniteFreeSystem → FiniteFreeSystem
  | A, [] => A
  | A, B :: Bs => A.compose (composeMany B Bs)

/-- The list of co-indices of the tail systems. -/
noncomputable def tailCoindices (As : List FiniteFreeSystem) : List ℕ := As.map (fun A => Z2CoindexJoin.coind A.space)

/-- The number of vertices in a finite composite is the sum of the vertex counts of its factors.
-/
theorem card_composeMany (A : FiniteFreeSystem) (As : List FiniteFreeSystem) :
    Fintype.card (composeMany A As).space.V =
      Fintype.card A.space.V + (As.map (fun B => Fintype.card B.space.V)).sum := by
  induction' As with B Bs ih generalizing A;
  · rfl;
  · convert congr_arg₂ ( · + · ) rfl ( ih B ) using 1;
    convert Fintype.card_sum

/-- **Exact finite composition law.**  For arbitrary finite nonempty free ℤ₂-systems, the co-index
of a right-associated join is the sum of the factor co-indices plus one for every join operation.
Unlike the octahedral multi-join law, no sphere hypothesis is imposed on any factor.
-/
theorem coind_composeMany (A : FiniteFreeSystem) (As : List FiniteFreeSystem) :
    Z2CoindexJoin.coind (composeMany A As).space =
      Z2CoindexJoin.coind A.space + (tailCoindices As).sum + As.length := by
  revert A As;
  intro A As
  induction' As with B As ih generalizing A;
  · aesop;
  · convert coind_join_eq_general A.vertex ( composeMany B As ).vertex using 1;
    simp +arith +decide [ ih, tailCoindices ]

/-- The shifted co-index is extensive under an arbitrary finite composition: it converts joins into
ordinary addition.
-/
theorem shifted_coind_composeMany (A : FiniteFreeSystem) (As : List FiniteFreeSystem) :
    Z2CoindexJoin.coind (composeMany A As).space + 1 =
      (Z2CoindexJoin.coind A.space + 1) + (As.map (fun B => Z2CoindexJoin.coind B.space + 1)).sum := by
  induction As <;> simp_all +decide [ add_assoc, List.sum_cons ];
  · rfl;
  · rename_i k hk ih; rw [ coind_composeMany ] ; simp +arith +decide [*] ;
    rfl

/-- Vertex counting and co-index extensivity agree exactly on every finite composite system.
-/
theorem two_mul_shifted_coind_eq_card (A : FiniteFreeSystem) (As : List FiniteFreeSystem) :
    2 * (Z2CoindexJoin.coind (composeMany A As).space + 1) =
      Fintype.card (composeMany A As).space.V := by
  exact Z2CoindexJoin.two_mul_coind_succ_eq_card (composeMany A As).vertex

/-!
-- !-- Lab Notes -- !--

**Target category.** Cross-domain bridge: equivariant topology is connected to finite orbit
combinatorics and to the extensive-variable calculus of composite physical systems.

**Hypothesis.** The two-body sharp join law should iterate for arbitrary finite free ℤ₂-systems,
not only for the octahedral tower.  Equivalently, shifting co-index by one should turn the join into
an additive composition law.

**Experiment.** Finite nonempty systems were bundled so that every intermediate join retains the
finiteness and nonemptiness required by the two-factor classification theorem.  Right-associated
list composition then exposes a direct structural induction.  Independently, vertex cardinalities
were propagated through the same recursion.

**Analysis.** Both quantities obey the same recursion: vertex pairs add under disjoint union, while
co-indices add with one extra unit under join.  Hence `coind + 1` is extensive, and twice this
quantity equals the number of vertices at every stage.  The shared recursion unifies the topological
invariant with orbit counting.

**Critique.** Nonemptiness is explicit and indispensable: without it the supremum defining co-index
has a degenerate empty case.  The theorem does not claim an upper bound for more general simplicial
complexes; it applies to the octahedral free-set model inherited from the classification theorem.
The main law is not a restatement of the binary case, since it quantifies over an unbounded list and
requires preservation of all side conditions through recursive composition.

**Synthesis.** The many-body law identifies `coind + 1` as the natural extensive invariant of finite
free ℤ₂-systems.  Join composition, antipodal orbit count, and shifted co-index are three equivalent
additive descriptions of the same structure.
-/

end Z2CoindexFiniteComposition