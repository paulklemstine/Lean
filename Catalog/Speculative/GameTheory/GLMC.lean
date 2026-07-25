import Mathlib

/-!
# The Global Label Min-Cut (GLMC) problem

This file gives a faithful, machine-checked formalization of the **Global Label
Min-Cut** combinatorial problem, together with its true, foundational theory:
the objective is well defined, bounded by the number of labels, attained by an
optimal proper cut, and equals the genuine minimum (i.e. a brute-force search is
correct). All statements below are proved without `sorry`.

## Status of the runtime conjecture

The originating request conjectured a *deterministic algorithm solving GLMC on
genus-`g` surface-embedded graphs in time `2^{O(g)} · n^{O(1)} · p^{O(1)}`,*
to be proved via (1) a grid-minor treewidth bound `O(√(g·n))`, (2) a tree-
decomposition dynamic program, (3) composition. After investigation, that
program **cannot be carried out as stated**, for the following reasons. None of
these depend on the GLMC problem itself (no circularity).

1. **Missing foundations.** The cited "recent advances in the formalization of
   graph minor theory (especially the grid minor theorem) and tree decomposition
   algorithms in Lean 4's Mathlib" do not exist in the Mathlib used here (or, to
   our knowledge, in any released Mathlib). There is no treewidth, no tree
   decomposition, no graph-minor relation, no grid-minor theorem, and no genus /
   surface-embedding theory available to build on. The structural ingredients
   (1)–(3) therefore have no formal basis to invoke.

2. **Internal inconsistency of the claimed running time.** The proposed strategy,
   *even if all foundations existed,* would yield
   `2^{O(√(g·n))} · p^{O(√(g·n))} · n^{O(1)}`, which for fixed `g` is
   *quasi-polynomial* in `n` (and `p`). This does **not** match the conjectured
   `2^{O(g)} · n^{O(1)} · p^{O(1)}`, which for fixed `g` is *polynomial* in `n`
   and `p`. The conjectured bound is strictly stronger than what the strategy
   produces; the request's own step (3) derives only the weaker quasi-polynomial
   bound. The two cannot both follow from this argument.

3. **The treewidth bound is false as stated.** A graph of (Euler) genus `g` on
   `n` vertices has treewidth `O(√((g+1)·n))`, *not* `O(√(g·n))`. The `+1` is
   essential: at `g = 0` (planar graphs) the stated bound `O(√(g·n))` collapses
   to `0`, yet the planar `√n × √n` grid has treewidth `Θ(√n)`. So step (1) is
   incorrect for planar inputs.

4. **Plausibility caution.** Minimum-label cut problems are generally NP-hard.
   If GLMC is NP-hard already on planar graphs, then an algorithm polynomial in
   `n` and `p` for fixed `g` (the conjectured bound at `g = 0`) would imply
   `P = NP`, which makes the conjectured polynomial-in-`n` bound implausible. The
   strategy's quasi-polynomial bound is consistent with hardness; the
   conjecture's polynomial bound is not. (Stated as a caution, not a proof.)

What *is* formalized and proved below is the well-posed mathematical core: the
GLMC objective and the correctness of an exhaustive (exponential-time) solver,
which is the rigorous, foundation-independent content of the problem.

## Model

We fix a finite vertex type `V` and a finite label type `L`. An instance is a
finite set of labeled edges `edges : Finset (V × V × L)`, where `(u, v, ℓ)` is an
edge `{u, v}` carrying label `ℓ`. A cut is a vertex subset `A : Finset V`; the
edge `(u, v, ℓ)` *crosses* `A` when exactly one of `u, v` lies in `A`. (Storing
an edge as `(u, v, ℓ)` versus `(v, u, ℓ)` does not change whether it crosses nor
its label, so this directed encoding faithfully models the undirected problem.)
A *proper* cut requires both sides nonempty, matching "partition `(A, V \ A)`".
-/

open Finset

namespace GLMC

variable {V L : Type*} [Fintype V] [DecidableEq V] [Fintype L] [DecidableEq L]

/-- The set of labels appearing on edges that cross the cut `(A, Aᶜ)`. An edge
`(u, v, ℓ)` crosses when exactly one of `u, v` lies in `A`. -/
def cutLabels (edges : Finset (V × V × L)) (A : Finset V) : Finset L :=
  (edges.filter (fun e => (e.1 ∈ A) ≠ (e.2.1 ∈ A))).image (fun e => e.2.2)

/-- The GLMC objective for a fixed cut: the number of *distinct* labels that
cross `(A, Aᶜ)`. -/
def cutValue (edges : Finset (V × V × L)) (A : Finset V) : ℕ :=
  (cutLabels edges A).card

/-- The proper (nontrivial) cuts of `V`: vertex subsets with both sides nonempty,
i.e. genuine partitions `(A, V \ A)`. -/
def properCuts (V : Type*) [Fintype V] [DecidableEq V] : Finset (Finset V) :=
  univ.filter (fun A => A.Nonempty ∧ A ≠ univ)

/-- The GLMC optimum: the minimum number of distinct labels crossing any proper
cut. By convention it is `0` when there is no proper cut (i.e. `|V| ≤ 1`). This
definition is a finite computation, hence is an explicit (exponential-time)
brute-force solver; `glmcOpt_le_of_proper` and `glmcOpt_attained` below certify
that it returns the genuine minimum. -/
def glmcOpt (edges : Finset (V × V × L)) : ℕ :=
  ((properCuts V).image (cutValue edges)).min.getD 0

omit [Fintype V] in
/-- The number of labels crossing any cut is at most the total number of labels
`p = |L|`. -/
theorem cutValue_le_numLabels (edges : Finset (V × V × L)) (A : Finset V) :
    cutValue edges A ≤ Fintype.card L := by
  exact Finset.card_le_univ _

/-- When `V` has at least two vertices, a proper cut exists. -/
theorem properCuts_nonempty (h : 2 ≤ Fintype.card V) :
    (properCuts V).Nonempty := by
  obtain ⟨ a, b, hab ⟩ := Fintype.one_lt_card_iff.mp h;
  refine' ⟨ { a }, _ ⟩ ; simp +decide [ *, properCuts ];
  simp +decide [ Finset.ext_iff ];
  exact ⟨ b, hab.symm ⟩

/-- Membership in `properCuts` is exactly being nonempty and not everything. -/
theorem mem_properCuts {A : Finset V} :
    A ∈ properCuts V ↔ A.Nonempty ∧ A ≠ univ := by
  unfold properCuts; aesop

/-- The GLMC optimum is at most the total number of labels `p = |L|`. -/
theorem glmcOpt_le_numLabels (edges : Finset (V × V × L)) :
    glmcOpt edges ≤ Fintype.card L := by
  unfold glmcOpt;
  cases h : Finset.min ( image ( cutValue edges ) ( properCuts V ) ) <;> simp_all +decide;
  · exact Nat.zero_le _;
  · have := Finset.mem_of_min h;
    rw [ Finset.mem_image ] at this; obtain ⟨ A, hA, rfl ⟩ := this; exact cutValue_le_numLabels edges A;

omit [Fintype L] in
/-- Correctness, lower-bound half: the optimum does not exceed the value of any
proper cut. Together with `glmcOpt_attained`, this says `glmcOpt` is the genuine
minimum number of distinct cut labels. -/
theorem glmcOpt_le_of_proper (edges : Finset (V × V × L)) {A : Finset V}
    (hA : A ∈ properCuts V) : glmcOpt edges ≤ cutValue edges A := by
  unfold glmcOpt;
  have := Finset.min_le ( Finset.mem_image_of_mem ( cutValue edges ) hA );
  cases h : Finset.min ( Finset.image ( cutValue edges ) ( properCuts V ) ) <;> aesop

omit [Fintype L] in
/-- Correctness, attainment half: when a proper cut exists, the optimum is
realized by some proper cut. -/
theorem glmcOpt_attained (h : 2 ≤ Fintype.card V) (edges : Finset (V × V × L)) :
    ∃ A ∈ properCuts V, cutValue edges A = glmcOpt edges := by
  obtain ⟨A, hA⟩ : ∃ A ∈ properCuts V, ∀ B ∈ properCuts V, cutValue edges A ≤ cutValue edges B := by
    exact Finset.exists_min_image _ _ ( properCuts_nonempty h );
  unfold glmcOpt;
  rw [ Finset.min_eq_inf_withTop ];
  rw [ Finset.inf_image ];
  rw [ show ( properCuts V ).inf ( WithTop.some ∘ cutValue edges ) = WithTop.some ( cutValue edges A ) from ?_ ];
  · exact ⟨ A, hA.1, rfl ⟩;
  · exact le_antisymm ( Finset.inf_le hA.1 ) ( Finset.le_inf fun B hB => WithTop.coe_le_coe.mpr ( hA.2 B hB ) )

omit [Fintype L] in
/-- If some proper cut has no crossing edges (e.g. the graph is disconnected and
`A` is a union of connected components), then the GLMC optimum is `0`. -/
theorem glmcOpt_eq_zero_of_separated (edges : Finset (V × V × L)) {A : Finset V}
    (hA : A ∈ properCuts V)
    (hsep : ∀ e ∈ edges, ¬ ((e.1 ∈ A) ≠ (e.2.1 ∈ A))) :
    glmcOpt edges = 0 := by
  refine' le_antisymm ( glmcOpt_le_of_proper edges hA |> le_trans <| _ ) ( Nat.zero_le _ );
  simp +decide [ cutValue, cutLabels ]
  grind

end GLMC