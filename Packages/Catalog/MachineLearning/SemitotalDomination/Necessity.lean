import Mathlib
import MachineLearning.SemitotalDomination.Sharpness

/-!
# Why the BFS layering is necessary

The algorithm of the paper does not merely compute *some* maximal independent set: it computes
the greedy maximal independent set **in BFS order**.  This file shows, by an explicit
counterexample, that this is essential.

Take the path with `7` vertices, realized as the unit disk graph of the points
`0, 1, 2, 3, 4, 5, 6` on a line.  The set `S = {0, 3, 6}` is a maximal independent set (hence a
dominating set), but it is *not* a semitotal dominating set: the vertex `0` has no other vertex
of `S` within distance `2`.

So "maximal independent set" alone gives no approximation guarantee for semitotal domination:
one needs the layered scan of `MachineLearning.SemitotalDomination.Greedy`, which is exactly what
`greedyMIS_isSemitotalSet` provides (the greedy BFS set on this graph is `{0,2,4,6}`).

-- !-- Lab Notes -- !--
## Hypothesis
"Any maximal independent set of a connected unit disk graph is semitotal" — **false**.

## Experimental outcome
Exhaustive enumeration (see `ComputationalEvidence.md`) shows that `P₇` has exactly `7` maximal
independent sets, of which `5` fail the semitotal condition:
`{0,2,5}, {0,3,5}, {0,3,6}, {1,3,6}, {1,4,6}`; only `{0,2,4,6}` and `{1,3,5}` are semitotal.
Failures already occur for smaller paths (`P₄`: `{0,3}`), so the phenomenon is generic rather
than an artefact of `P₇`.  Note that the failing set is not merely a *bad* solution: it is not a
feasible solution at all, so no approximation ratio can be attached to it.

## Insights
* The failure is *local at the ends*: `0` is separated by distance `3` from `3`.
* The BFS scan prevents this because a newly selected vertex `v` in layer `d` always has its
  parent in layer `d-1` already dominated by an earlier selected vertex.
-/

namespace SemitotalDomination

open Finset

/-- The `n` collinear unit-spaced points `0, 1, …, n-1` of the plane. -/
noncomputable def linePos (n : ℕ) : Fin n → ℂ := fun i => ((i.val : ℝ) : ℂ)

/-- The path `Pₙ` presented as a unit disk graph. -/
noncomputable def lineGraph (n : ℕ) : SimpleGraph (Fin n) := unitDiskGraph (linePos n)

lemma dist_linePos (n : ℕ) (i j : Fin n) :
    dist (linePos n i) (linePos n j) = |(i.val : ℝ) - (j.val : ℝ)| := by
  rw [dist_eq_norm]
  have h : linePos n i - linePos n j = ((((i.val : ℝ) - (j.val : ℝ)) : ℝ) : ℂ) := by
    simp [linePos]
  rw [h, Complex.norm_real, Real.norm_eq_abs]

/-- Adjacency in `lineGraph n` is "consecutive indices". -/
lemma lineGraph_adj_iff {n : ℕ} (i j : Fin n) :
    (lineGraph n).Adj i j ↔ (i.val + 1 = j.val ∨ j.val + 1 = i.val) := by
  constructor
  · rintro ⟨hne, hd⟩
    rw [dist_linePos] at hd
    have hv : i.val ≠ j.val := fun h => hne (Fin.ext h)
    rcases abs_le.mp hd with ⟨h1, h2⟩
    have n1 : i.val ≤ j.val + 1 := by exact_mod_cast (by linarith : (i.val : ℝ) ≤ (j.val : ℝ) + 1)
    have n2 : j.val ≤ i.val + 1 := by exact_mod_cast (by linarith : (j.val : ℝ) ≤ (i.val : ℝ) + 1)
    omega
  · intro h
    refine ⟨fun hc => by rw [hc] at h; omega, ?_⟩
    rw [dist_linePos, abs_le]
    rcases h with h | h
    · have hc : (j.val : ℝ) = (i.val : ℝ) + 1 := by exact_mod_cast h.symm
      constructor <;> linarith
    · have hc : (i.val : ℝ) = (j.val : ℝ) + 1 := by exact_mod_cast h.symm
      constructor <;> linarith

/-- Consecutive vertices are adjacent. -/
lemma lineGraph_adj_succ {n : ℕ} {k : ℕ} (hk : k + 1 < n) :
    (lineGraph n).Adj ⟨k, by omega⟩ ⟨k + 1, hk⟩ :=
  (lineGraph_adj_iff _ _).mpr (Or.inl rfl)

lemma lineGraph_reachable_zero (n : ℕ) (hn : 0 < n) :
    ∀ (k : ℕ) (hk : k < n), (lineGraph n).Reachable ⟨0, hn⟩ ⟨k, hk⟩ := by
  intro k
  induction k with
  | zero => intro _; exact SimpleGraph.Reachable.refl _
  | succ m ih =>
    intro hk
    exact (ih (by omega)).trans (lineGraph_adj_succ hk).reachable

theorem lineGraph_connected (n : ℕ) (hn : 0 < n) : (lineGraph n).Connected := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  refine ⟨fun u v => ?_⟩
  exact (lineGraph_reachable_zero n hn u.val u.isLt).symm.trans
    (lineGraph_reachable_zero n hn v.val v.isLt)

/-- `{0,3,6}` is an independent set of the seven-vertex path. -/
theorem P7_indep : (lineGraph 7).IsIndepSet (({0, 3, 6} : Finset (Fin 7)) : Set (Fin 7)) := by
  rw [isIndepSet_iff]
  simp only [lineGraph_adj_iff]
  decide

/-- `{0,3,6}` is a dominating set of the seven-vertex path, hence a *maximal* independent set. -/
theorem P7_dominating : IsDominatingSet (lineGraph 7) ({0, 3, 6} : Finset (Fin 7)) := by
  unfold IsDominatingSet
  simp only [lineGraph_adj_iff]
  decide

/-- But `{0,3,6}` is **not** semitotal: the vertex `0` has no other vertex of the set within
distance `2`. -/
theorem P7_not_semitotal :
    ¬ IsSemitotalSet (lineGraph 7) ({0, 3, 6} : Finset (Fin 7)) := by
  unfold IsSemitotalSet Within2
  simp only [lineGraph_adj_iff]
  decide

/-- **Necessity of the BFS layering.**  There is a connected unit disk graph together with a
maximal independent set (equivalently, an independent dominating set) which is *not* a semitotal
dominating set. -/
theorem exists_maximal_independent_not_semitotal :
    ∃ (n : ℕ) (pos : Fin n → ℂ) (S : Finset (Fin n)),
      (unitDiskGraph pos).Connected ∧
      IsDominatingSet (unitDiskGraph pos) S ∧
      (unitDiskGraph pos).IsIndepSet (S : Set (Fin n)) ∧
      ¬ IsSemitotalSet (unitDiskGraph pos) S :=
  ⟨7, linePos 7, {0, 3, 6}, lineGraph_connected 7 (by norm_num), P7_dominating, P7_indep,
    P7_not_semitotal⟩

end SemitotalDomination