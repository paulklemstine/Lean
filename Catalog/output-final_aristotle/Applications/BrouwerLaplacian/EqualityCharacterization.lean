/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Partial spectra of the graph Laplacian and threshold graphs

This file develops the linear-algebraic infrastructure surrounding the
*Brouwer equality problem* for the graph Laplacian.  For a finite simple graph
`G` on `n` vertices with `m` edges, write `λ₁ ≥ λ₂ ≥ ⋯ ≥ λₙ` for the eigenvalues
of its Laplacian matrix `L = D - A`, and set

`  s_k(G) = λ₁ + ⋯ + λ_k`

for the sum of the `k` largest Laplacian eigenvalues.  Brouwer's conjecture
asserts `s_k(G) ≤ m + C(k+1, 2)`, with the extremal graphs believed to be exactly
the *threshold graphs* of clique number `k+1`.

We establish the exact, unconditional facts that anchor this circle of ideas:

* the Laplacian is symmetric, positive semidefinite, hence has real nonnegative
  eigenvalues (`lapMatrix_isHermitian`, `laplacian_eigenvalue_nonneg`,
  `eigenvalues₀_nonneg`);
* the **trace identity** `s_n(G) = 2m`, i.e. the sum of *all* Laplacian
  eigenvalues equals twice the number of edges
  (`laplacian_total_spectralSum_eq_two_mul_edges`);
* structural monotonicity of the partial sums `s_k`
  (`spectralSum_mono`) together with the global ceiling `s_k(G) ≤ 2m`
  (`spectralSum_le_two_mul_edges`), and the stabilization
  `s_k(G) = 2m` once `k ≥ n` (`spectralSum_eq_two_mul_edges_of_card_le`);
* a self-contained model of threshold graphs via *creation sequences*
  (`thresholdGraph`), with the two boundary identifications: the all-dominating
  sequence yields the complete graph (`thresholdGraph_top_eq_complete`) and the
  all-isolated sequence yields the empty graph
  (`thresholdGraph_bot_eq_empty`).

These are the honest, fully-proved building blocks on which the (open) Brouwer
equality characterization rests.

## Lab Notes -- team scientific loop

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer). The sum `s_k` of the `k` largest Laplacian
eigenvalues obeys `s_k = m + C(k+1,2)` exactly for threshold graphs of clique
number `k+1`.  The boldest sub-claims: (i) the *total* sum `s_n` is a pure edge
invariant `2m`; (ii) the extremal family (threshold graphs) has a purely
combinatorial creation-sequence description with clean spectral behaviour at the
boundaries (complete / empty).

Experiment (Experimenter). We formalised `s_k` through the descending eigenvalue
enumeration `eigenvalues₀`.  The trace route `trace L = ∑ deg = 2m` combined with
`trace = ∑ eigenvalues` yields `s_n = 2m` unconditionally.  Positive
semidefiniteness of `L` gives nonnegativity of every eigenvalue, which powers
monotonicity of `s_k` and the ceiling `s_k ≤ 2m`.  Threshold graphs were modelled
by a boolean creation sequence; the two extreme sequences were computed to be the
complete and empty graphs.

Analysis (Analyst). The unconditional pillars — trace identity, PSD
nonnegativity, monotonicity — are "true and provable".  The full biconditional
with clique number is "true but hard": it requires the majorization theory of
Grone–Merris/Bai and the conjugate-degree-sequence description of threshold
spectra, none of which is available off the shelf.  We therefore isolate the
provable spine and phrase the target as an explicit predicate.

Critique (Critic). None of the theorems is vacuous: each uses a genuine spectral
or combinatorial input (trace algebra, PSD, subset-sum monotonicity, graph
extensionality).  The boundary threshold identifications are non-trivial
equalities of graphs, not definitional unfoldings.  The open biconditional is
recorded as `BrouwerEquality`, not asserted.

Synthesis (PI). The file delivers the exact skeleton of Brouwer's equality
theory: `s_k` well-defined and sandwiched between `0` and `2m`, saturating to
`2m`, with the extremal family pinned down at its boundaries.
-/
import Mathlib

open Matrix Finset SimpleGraph

namespace BrouwerLaplacian

variable {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]

/-! ## The Laplacian as a Hermitian, positive semidefinite matrix -/

/-- The Laplacian matrix of a finite simple graph is Hermitian (over `ℝ`, symmetric). -/
theorem lapMatrix_isHermitian : (G.lapMatrix ℝ).IsHermitian := by
  rw [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
  exact G.isSymm_lapMatrix

/-- The (real) eigenvalues of the graph Laplacian are nonnegative:
the Laplacian is positive semidefinite. -/
theorem laplacian_eigenvalue_nonneg (i : Fin n) :
    0 ≤ (lapMatrix_isHermitian G).eigenvalues i :=
  (posSemidef_lapMatrix ℝ G).eigenvalues_nonneg i

/-- The descending eigenvalue enumeration of the Laplacian is nonnegative. -/
theorem eigenvalues₀_nonneg (i : Fin (Fintype.card (Fin n))) :
    0 ≤ (lapMatrix_isHermitian G).eigenvalues₀ i := by
  have h := (posSemidef_lapMatrix ℝ G).eigenvalues_nonneg
    ((Fintype.equivOfCardEq (Fintype.card_fin _)) i)
  unfold Matrix.IsHermitian.eigenvalues at h
  simpa using h

/-! ## Sum of the `k` largest Laplacian eigenvalues -/

/-- `spectralSum G k` is the sum of the `k` largest Laplacian eigenvalues of `G`,
i.e. Brouwer's quantity `s_k(G)`.  We use the descending enumeration
`eigenvalues₀` (which is antitone) and keep the top `k` indices. -/
noncomputable def spectralSum (k : ℕ) : ℝ :=
  ∑ i ∈ Finset.univ.filter (fun i : Fin (Fintype.card (Fin n)) => (i : ℕ) < k),
    (lapMatrix_isHermitian G).eigenvalues₀ i

/-- The total spectral sum (over all eigenvalues) equals the trace of the
Laplacian. -/
theorem sum_eigenvalues₀_eq_trace :
    ∑ i, (lapMatrix_isHermitian G).eigenvalues₀ i = (G.lapMatrix ℝ).trace := by
  rw [(lapMatrix_isHermitian G).trace_eq_sum_eigenvalues]
  unfold Matrix.IsHermitian.eigenvalues
  exact (Equiv.sum_comp (Fintype.equivOfCardEq (Fintype.card_fin _)).symm _).symm

/-- The trace of the Laplacian equals twice the number of edges. -/
theorem trace_lapMatrix_eq_two_mul_edges :
    (G.lapMatrix ℝ).trace = 2 * (G.edgeFinset.card : ℝ) := by
  unfold SimpleGraph.lapMatrix
  rw [Matrix.trace_sub]
  have hA : (G.adjMatrix ℝ).trace = 0 := by
    simp [Matrix.trace, Matrix.diag, adjMatrix_apply]
  have hD : (G.degMatrix ℝ).trace = ∑ i, (G.degree i : ℝ) := by
    simp [Matrix.trace, Matrix.diag, degMatrix]
  rw [hA, hD, sub_zero, ← Nat.cast_sum, G.sum_degrees_eq_twice_card_edges]
  push_cast; ring

/-- **Trace identity / total spectral sum.**  The sum of *all* Laplacian
eigenvalues of `G` equals twice the number of edges of `G`.  This is the `k = n`
boundary case of Brouwer's quantity: `s_n(G) = 2m`. -/
theorem laplacian_total_spectralSum_eq_two_mul_edges :
    ∑ i, (lapMatrix_isHermitian G).eigenvalues₀ i = 2 * (G.edgeFinset.card : ℝ) := by
  rw [sum_eigenvalues₀_eq_trace, trace_lapMatrix_eq_two_mul_edges]

/-- Once `k` reaches the number of vertices, `spectralSum` captures the full
spectrum. -/
theorem spectralSum_eq_sum_all (k : ℕ) (hk : n ≤ k) :
    spectralSum G k = ∑ i, (lapMatrix_isHermitian G).eigenvalues₀ i := by
  unfold spectralSum
  apply Finset.sum_congr _ (fun _ _ => rfl)
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
  have hi : (i : ℕ) < Fintype.card (Fin n) := i.2
  simp only [Fintype.card_fin] at hi
  omega

/-- For `k` at least the number of vertices, `spectralSum` equals `2m`. -/
theorem spectralSum_eq_two_mul_edges_of_card_le (k : ℕ) (hk : n ≤ k) :
    spectralSum G k = 2 * (G.edgeFinset.card : ℝ) := by
  rw [spectralSum_eq_sum_all G k hk, laplacian_total_spectralSum_eq_two_mul_edges]

/-- The partial spectral sums are monotone in `k`: adding more (nonnegative)
eigenvalues cannot decrease the sum. -/
theorem spectralSum_mono : Monotone (spectralSum G) := by
  intro k l hkl
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · intro i hi
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at *
    omega
  · intro i _ _; exact eigenvalues₀_nonneg G i

/-- Global ceiling: every partial spectral sum is bounded by the total `2m`. -/
theorem spectralSum_le_two_mul_edges (k : ℕ) :
    spectralSum G k ≤ 2 * (G.edgeFinset.card : ℝ) := by
  rw [← laplacian_total_spectralSum_eq_two_mul_edges]
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · intro i _; exact Finset.mem_univ i
  · intro i _ _; exact eigenvalues₀_nonneg G i

/-- Every partial spectral sum is nonnegative (a sum of nonnegative eigenvalues). -/
theorem spectralSum_nonneg (k : ℕ) : 0 ≤ spectralSum G k := by
  apply Finset.sum_nonneg
  intro i _; exact eigenvalues₀_nonneg G i

/-! ## Threshold graphs via creation sequences

A *threshold graph* is built one vertex at a time; each new vertex is either
*isolated* (joined to nothing so far) or *dominating* (joined to everything so
far).  Encoding the choice for vertex `v` by a boolean `b v` (`true` = dominating)
gives the following symmetric adjacency: two distinct vertices are adjacent iff
the later of the two was added as a dominating vertex. -/

/-- Adjacency relation of the threshold graph with creation sequence `b`. -/
def thresholdAdj (b : Fin n → Bool) (i j : Fin n) : Prop :=
  i ≠ j ∧ b (max i j) = true

/-- The threshold graph on `Fin n` determined by a creation sequence
`b : Fin n → Bool`. -/
def thresholdGraph (b : Fin n → Bool) : SimpleGraph (Fin n) where
  Adj := thresholdAdj b
  symm := by
    intro i j h
    exact ⟨h.1.symm, by rw [max_comm]; exact h.2⟩
  loopless := ⟨fun i h => h.1 rfl⟩

instance (b : Fin n → Bool) (i j : Fin n) : Decidable ((thresholdGraph b).Adj i j) :=
  inferInstanceAs (Decidable (i ≠ j ∧ b (max i j) = true))

/-- Boundary case: the all-dominating creation sequence produces the complete
graph. -/
theorem thresholdGraph_top_eq_complete :
    thresholdGraph (fun _ : Fin n => true) = (⊤ : SimpleGraph (Fin n)) := by
  ext i j
  simp [thresholdGraph, thresholdAdj, SimpleGraph.top_adj]

/-- Boundary case: the all-isolated creation sequence produces the empty
graph. -/
theorem thresholdGraph_bot_eq_empty :
    thresholdGraph (fun _ : Fin n => false) = (⊥ : SimpleGraph (Fin n)) := by
  ext i j
  simp [thresholdGraph, thresholdAdj]

/-! ## The Brouwer equality target

We record the inequality value and the equality set as explicit predicates, so
that the (open) Brouwer characterization can be phrased and specialized. -/

/-- The Brouwer bound value `m + C(k+1, 2)`. -/
def brouwerBound (k : ℕ) : ℝ :=
  (G.edgeFinset.card : ℝ) + (Nat.choose (k + 1) 2 : ℝ)

/-- `BrouwerEquality G k` states that `G` attains Brouwer's bound at level `k`. -/
def BrouwerEquality (k : ℕ) : Prop :=
  spectralSum G k = brouwerBound G k

/-- On the empty graph every Laplacian eigenvalue vanishes, so the partial
spectral sum is identically zero. -/
theorem spectralSum_bot_eq_zero (k : ℕ) :
    spectralSum (⊥ : SimpleGraph (Fin n)) k = 0 := by
      refine' le_antisymm _ _;
      · convert spectralSum_le_two_mul_edges ⊥ k using 2 ; norm_num [ zero_le ];
      · convert BrouwerLaplacian.spectralSum_nonneg _ _

/-- **Boundary characterization of the equality set.**  The edgeless graph
attains Brouwer's bound `m + C(k+1, 2)` at level `k` if and only if `k = 0`:
with `m = 0` and `s_k = 0`, equality forces the binomial term `C(k+1, 2)` to
vanish, which happens exactly at `k = 0`.  This pins down the target predicate
`BrouwerEquality` on the extreme (edgeless) member of the threshold family. -/
theorem brouwerEquality_bot_iff (k : ℕ) :
    BrouwerEquality (⊥ : SimpleGraph (Fin n)) k ↔ k = 0 := by
      refine' ⟨ fun hk => _, fun hk => _ ⟩;
      · unfold BrouwerEquality at hk;
        unfold brouwerBound at hk;
        rw [ BrouwerLaplacian.spectralSum_bot_eq_zero ] at hk;
        rcases k with ( _ | _ | k ) <;> norm_cast at hk ; simp_all +arith +decide [ Nat.choose ];
      · unfold BrouwerEquality;
        convert BrouwerLaplacian.spectralSum_bot_eq_zero ( n := n ) k using 1;
        unfold brouwerBound; aesop;

/-! ## Examples, generalizations, and boundary discussion (PEGB) -/

section Examples

/-- Example: the partial spectral sum is well defined and real-valued. -/
example : spectralSum (⊥ : SimpleGraph (Fin 3)) 2 = spectralSum (⊥ : SimpleGraph (Fin 3)) 2 := rfl

/-- Example: `brouwerBound` at level `k = 1` is `m + 1`. -/
example (G : SimpleGraph (Fin 4)) [DecidableRel G.Adj] :
    brouwerBound G 1 = (G.edgeFinset.card : ℝ) + 1 := by
  simp [brouwerBound]

#check @laplacian_total_spectralSum_eq_two_mul_edges
#check @spectralSum_le_two_mul_edges
#check @thresholdGraph_top_eq_complete
#check @brouwerEquality_bot_iff

/-- Example: the edgeless graph on `Fin 3` does *not* attain Brouwer's bound at
level `k = 1` (a strict-inequality boundary of the equality set). -/
example : ¬ BrouwerEquality (⊥ : SimpleGraph (Fin 3)) 1 := by
  rw [brouwerEquality_bot_iff]; decide

/-
Generalization.  The definition `spectralSum` and every result above are stated
for arbitrary finite simple graphs on `Fin n`; nothing is special to a fixed `n`.
The trace identity generalizes verbatim to any symmetric matrix realized as a
graph Laplacian, and the monotonicity/ceiling results generalize to any
positive-semidefinite Hermitian matrix's partial eigenvalue sums.  The threshold
model generalizes to weighted creation sequences and, more broadly, to the
degree-partition (Ferrers) description of threshold spectra.

Boundary cases.  The identity `s_k = 2m` is *not* the Brouwer bound `m + C(k+1,2)`
for general `k`: they coincide only at the extremal threshold graphs.  For the
empty graph (`m = 0`) all eigenvalues vanish, so `s_k = 0 < C(k+1,2)` for `k ≥ 1`
— a strict-inequality boundary showing the bound is far from tight off the
extremal family.  The complete graph saturates the bound precisely at `k = n-1`,
the limit case of the characterization.
-/

end Examples

end BrouwerLaplacian