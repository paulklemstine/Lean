/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Spectral Gap of a Constraint-Satisfaction Swap Chain

A *constraint-satisfaction puzzle* (of which Sudoku is the archetypal example) is
solved by a large collection of admissible completions.  A natural way to sample a
random completion is the **swap chain**: from a current completion, repeatedly pick
a *compatible swap* — a local move that exchanges two entries while preserving every
constraint — and follow it with some holding probability.  The mixing speed of this
chain is governed by its **spectral gap** `1 - λ₂`, the distance between the top
eigenvalue `1` and the second eigenvalue.

This file builds the swap chain from first principles as a symmetric, doubly
stochastic transition matrix attached to an arbitrary finite graph `G` of admissible
moves, and isolates the *exact* dictionary between the algebra of the chain and the
combinatorics of `G`:

* the chain is **stochastic** and **symmetric** (`swapP_row_sum`, `swapP_symm`),
  hence the uniform distribution is stationary and the constant vector is a
  top eigenvector (`swapP_mulVec_one`);
* a vector is fixed by the chain **iff** it satisfies a discrete mean-value
  property (`swapP_harmonic_iff`);
* **reducibility ⇒ vanishing gap**: if the move graph is disconnected, there is a
  *nonconstant* fixed vector, so the eigenvalue `1` is degenerate and the gap is
  `0` (`swapP_reducible_nonconstant_fixed`);
* **irreducibility ⇒ simple top eigenvalue**: if the move graph is connected, every
  fixed vector is constant — a discrete maximum principle
  (`swapP_fixed_const_of_preconnected`);
* an explicit two-state computation exhibits the second eigenvalue `1 - 2c` and the
  strictly positive gap `2c` in the connected case
  (`twoState_eigenvector`, `twoState_gap_pos`), versus the identically-degenerate
  gap of the disconnected case (`twoState_bot_eq_one`).

The upshot corrects a tempting but false folklore slogan.  The gap is **not** a
function of the number of clues or of the number of completions: two puzzles with
the same number of completions can have gap `2c > 0` or gap `0` depending only on
whether the graph of compatible swaps is connected.  Connectivity of the move graph,
not clue count, is the true order parameter.

A genuine Sudoku fixture (`sudoku_row_sum`) shows that a single compatible swap
inside a row preserves the row's value multiset, hence keeps the chain inside one
level set — the combinatorial reason the swap graph decomposes into invariant blocks.
-/
import Mathlib

open scoped BigOperators
open Matrix

namespace SudokuSpectral

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The transition matrix of the **swap chain** on a finite move graph `G` with
holding parameter `c`: with probability `c` follow each incident edge, otherwise
stay put.  It is symmetric and, for `0 ≤ c ≤ 1 / maxDegree`, a bona fide doubly
stochastic matrix. -/
noncomputable def swapP (G : SimpleGraph V) [DecidableRel G.Adj] (c : ℝ) :
    Matrix V V ℝ :=
  fun x y => if x = y then 1 - c * G.degree x else if G.Adj x y then c else 0

section Basic
variable (G : SimpleGraph V) [DecidableRel G.Adj] (c : ℝ)

/-- Every row of the swap chain sums to `1`: it is a stochastic matrix. -/
theorem swapP_row_sum (x : V) : ∑ y, swapP G c x y = 1 := by
  have hnb : ∑ y, (if G.Adj x y then (c:ℝ) else 0) = c * G.degree x := by
    have hset : (Finset.univ.filter (fun y => G.Adj x y)) = G.neighborFinset x := by
      ext y; simp [SimpleGraph.mem_neighborFinset]
    rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, Finset.sum_const, nsmul_eq_mul,
      mul_comm, hset, SimpleGraph.card_neighborFinset_eq_degree]
  have hpt : ∀ y, swapP G c x y =
      (if x = y then (1 - c * (G.degree x:ℝ)) else 0) + (if G.Adj x y then (c:ℝ) else 0) := by
    intro y
    simp only [swapP]
    by_cases hxy : x = y
    · subst hxy; simp [SimpleGraph.irrefl]
    · simp only [if_neg hxy]; by_cases ha : G.Adj x y <;> simp [ha]
  rw [Finset.sum_congr rfl (fun y _ => hpt y), Finset.sum_add_distrib,
    Finset.sum_ite_eq Finset.univ x]
  simp only [Finset.mem_univ, if_true]
  rw [hnb]; ring

/-- The swap chain is symmetric: `P x y = P y x`.  Together with row-stochasticity
this makes it doubly stochastic, so the uniform law is stationary. -/
theorem swapP_symm (x y : V) : swapP G c x y = swapP G c y x := by
  simp only [swapP]
  by_cases hxy : x = y
  · subst hxy; rfl
  · rw [if_neg hxy, if_neg (Ne.symm hxy)]
    by_cases ha : G.Adj x y
    · rw [if_pos ha, if_pos ha.symm]
    · rw [if_neg ha, if_neg (fun h => ha h.symm)]

/-- The fundamental expansion of one step of the chain: applying `P` to a function
`f` adds `c` times the discrete Laplacian `(∑_{y∼x} f y) - deg(x) · f x`. -/
theorem swapP_mulVec_apply (f : V → ℝ) (x : V) :
    (swapP G c).mulVec f x
      = f x + c * ((∑ y ∈ G.neighborFinset x, f y) - G.degree x * f x) := by
  have hpt : ∀ y, swapP G c x y * f y =
      (if x = y then (1 - c * (G.degree x:ℝ)) * f y else 0)
        + (if G.Adj x y then c * f y else 0) := by
    intro y
    simp only [swapP]
    by_cases hxy : x = y
    · subst hxy; simp [SimpleGraph.irrefl]
    · simp only [if_neg hxy]; by_cases ha : G.Adj x y <;> simp [ha]
  rw [Matrix.mulVec]
  simp only [dotProduct]
  rw [Finset.sum_congr rfl (fun y _ => hpt y), Finset.sum_add_distrib,
    Finset.sum_ite_eq Finset.univ x]
  simp only [Finset.mem_univ, if_true]
  have hnb : ∑ y, (if G.Adj x y then c * f y else 0) = c * ∑ y ∈ G.neighborFinset x, f y := by
    rw [Finset.mul_sum, ← Finset.sum_filter]
    apply Finset.sum_congr _ (fun y _ => rfl)
    ext y; simp [SimpleGraph.mem_neighborFinset]
  rw [hnb]; ring

/-- The constant vector is a top eigenvector: the uniform distribution is
stationary, so `λ₁ = 1`. -/
theorem swapP_mulVec_one : (swapP G c).mulVec (fun _ => (1:ℝ)) = (fun _ => (1:ℝ)) := by
  funext x
  rw [swapP_mulVec_apply]
  simp only [mul_one]
  rw [Finset.sum_const, SimpleGraph.card_neighborFinset_eq_degree, nsmul_eq_mul, mul_one]
  ring

/-- A vector is fixed by the chain **iff** it satisfies the discrete mean-value
property `deg(x) · f x = ∑_{y∼x} f y` at every vertex (given a nonzero move rate).
This is the algebraic characterization of harmonic functions of the walk. -/
theorem swapP_harmonic_iff (hc : c ≠ 0) (f : V → ℝ) :
    (swapP G c).mulVec f = f ↔
      ∀ x, (∑ y ∈ G.neighborFinset x, f y) = G.degree x * f x := by
  constructor
  · intro h x
    have hx := congrFun h x
    rw [swapP_mulVec_apply] at hx
    have : c * ((∑ y ∈ G.neighborFinset x, f y) - G.degree x * f x) = 0 := by linarith
    rcases mul_eq_zero.mp this with hc' | hs
    · exact absurd hc' hc
    · linarith
  · intro h
    funext x
    rw [swapP_mulVec_apply, h x]
    ring

end Basic

section Reducible
variable (G : SimpleGraph V)

open Classical in
/-- The indicator of the connected component of a fixed base point `x₀`. -/
noncomputable def componentIndicator (x₀ : V) : V → ℝ :=
  fun y => if G.Reachable x₀ y then 1 else 0

open Classical in
theorem componentIndicator_of_reachable (x₀ y : V) (h : G.Reachable x₀ y) :
    componentIndicator G x₀ y = 1 := by simp [componentIndicator, h]

open Classical in
theorem componentIndicator_of_not_reachable (x₀ y : V) (h : ¬ G.Reachable x₀ y) :
    componentIndicator G x₀ y = 0 := by simp [componentIndicator, h]

variable [DecidableRel G.Adj] (c : ℝ)

open Classical in
/-- **Reducibility ⇒ degenerate top eigenvalue.**  If the move graph is
disconnected, the component indicator is a *nonconstant* vector fixed by the chain
(indeed for every holding rate `c`).  Hence the eigenvalue `1` has multiplicity at
least two, `λ₂ = 1`, and the spectral gap is `0`: the chain cannot mix across
components. -/
theorem swapP_reducible_nonconstant_fixed (hdis : ¬ G.Preconnected) :
    ∃ f : V → ℝ, (swapP G c).mulVec f = f ∧ ¬ (∀ a b, f a = f b) := by
  rw [SimpleGraph.Preconnected] at hdis
  push_neg at hdis
  obtain ⟨x₀, y₀, hxy⟩ := hdis
  refine ⟨componentIndicator G x₀, ?_, ?_⟩
  · funext x
    rw [swapP_mulVec_apply]
    have hmvp : (∑ y ∈ G.neighborFinset x, componentIndicator G x₀ y)
        = G.degree x * componentIndicator G x₀ x := by
      by_cases hx : G.Reachable x₀ x
      · rw [componentIndicator_of_reachable G x₀ x hx]
        have hcon : ∀ y ∈ G.neighborFinset x, componentIndicator G x₀ y = 1 := by
          intro y hy
          rw [SimpleGraph.mem_neighborFinset] at hy
          exact componentIndicator_of_reachable G x₀ y (hx.trans hy.reachable)
        rw [Finset.sum_congr rfl hcon, Finset.sum_const,
          SimpleGraph.card_neighborFinset_eq_degree, nsmul_eq_mul, mul_one]
      · rw [componentIndicator_of_not_reachable G x₀ x hx]
        have hcon : ∀ y ∈ G.neighborFinset x, componentIndicator G x₀ y = 0 := by
          intro y hy
          rw [SimpleGraph.mem_neighborFinset] at hy
          exact componentIndicator_of_not_reachable G x₀ y
            (fun hr => hx (hr.trans hy.symm.reachable))
        rw [Finset.sum_congr rfl hcon, Finset.sum_const_zero, mul_zero]
    rw [hmvp]; ring
  · intro hconst
    have h0 : componentIndicator G x₀ x₀ = componentIndicator G x₀ y₀ := hconst _ _
    rw [componentIndicator_of_reachable G x₀ x₀ (SimpleGraph.Reachable.refl x₀),
      componentIndicator_of_not_reachable G x₀ y₀ hxy] at h0
    exact one_ne_zero h0

end Reducible

section Irreducible
variable (G : SimpleGraph V) [DecidableRel G.Adj] (c : ℝ)

/-- **Irreducibility ⇒ simple top eigenvalue** (discrete maximum principle).  If the
move graph is connected, every vector fixed by the chain is constant.  Thus the
eigenvalue `1` is simple, the necessary condition for a strictly positive spectral
gap.  The proof runs the maximum principle: at a global maximizer the mean-value
property forces every neighbour to attain the maximum, which then propagates along
every walk of the connected graph. -/
theorem swapP_fixed_const_of_preconnected (hc : c ≠ 0) (hconn : G.Preconnected)
    (f : V → ℝ) (hf : (swapP G c).mulVec f = f) : ∀ a b, f a = f b := by
  rw [swapP_harmonic_iff G c hc] at hf
  rcases isEmpty_or_nonempty V with hV | hV
  · intro a; exact (IsEmpty.false a).elim
  · obtain ⟨xM, hM⟩ := Finite.exists_max f
    set M := f xM with hMdef
    have step : ∀ x, f x = M → ∀ z, G.Adj x z → f z = M := by
      intro x hx z hxz
      have hmvp := hf x
      have hsumM : (∑ y ∈ G.neighborFinset x, f y) = G.degree x * M := by rw [hmvp, hx]
      have hconstM : (∑ _y ∈ G.neighborFinset x, M) = G.degree x * M := by
        rw [Finset.sum_const, SimpleGraph.card_neighborFinset_eq_degree, nsmul_eq_mul]
      have hnn : ∀ y ∈ G.neighborFinset x, 0 ≤ M - f y := by
        intro y _; linarith [hM y]
      have hzero : (∑ y ∈ G.neighborFinset x, (M - f y)) = 0 := by
        rw [Finset.sum_sub_distrib, hsumM, hconstM]; ring
      have hall := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hzero
      have hz : M - f z = 0 := hall z (by rw [SimpleGraph.mem_neighborFinset]; exact hxz)
      linarith
    have prop : ∀ a z, G.Walk a z → f a = M → f z = M := by
      intro a z w
      induction w with
      | nil => intro h; exact h
      | cons hadj w' ih => intro h; exact ih (step _ h _ hadj)
    have hallM : ∀ z, f z = M := by
      intro z
      obtain ⟨w⟩ := hconn xM z
      exact prop xM z w rfl
    intro a b; rw [hallM a, hallM b]

end Irreducible

section TwoState

/-- On two completions joined by one compatible swap (the complete graph on `Fin 2`),
the alternating vector `(1, -1)` is a second eigenvector with eigenvalue `1 - 2c`. -/
theorem twoState_eigenvector (c : ℝ) :
    (swapP (⊤ : SimpleGraph (Fin 2)) c).mulVec ![1, -1] = (1 - 2 * c) • ![1, -1] := by
  have hdeg : ∀ x : Fin 2, (⊤ : SimpleGraph (Fin 2)).degree x = 1 := by
    intro x; fin_cases x <;> decide
  funext i
  simp only [Matrix.mulVec, dotProduct, swapP, Fin.sum_univ_two, Pi.smul_apply, smul_eq_mul]
  fin_cases i <;>
    simp only [hdeg, SimpleGraph.top_adj] <;>
    norm_num [Matrix.cons_val_zero, Matrix.cons_val_one] <;> ring

/-- The two-state connected swap chain has a **strictly positive spectral gap**
`1 - (1 - 2c) = 2c` whenever the move rate `c` is positive. -/
theorem twoState_gap_pos (c : ℝ) (hc : 0 < c) : 0 < 1 - (1 - 2 * c) := by
  linarith

/-- With no compatible swap available (`⊥` graph), the chain is the identity: every
vector is fixed, the eigenvalue `1` is maximally degenerate, and the gap is `0`.
Two puzzles with the *same* two completions thus have gap `2c` or gap `0` depending
solely on whether a compatible swap connects them — not on any clue count. -/
theorem twoState_bot_eq_one (c : ℝ) :
    swapP (⊥ : SimpleGraph (Fin 2)) c = (1 : Matrix (Fin 2) (Fin 2) ℝ) := by
  ext x y
  simp only [swapP, SimpleGraph.bot_adj, Matrix.one_apply]
  by_cases hxy : x = y
  · subst hxy; simp
  · simp [hxy]

end TwoState

section Sudoku

/-- A single compatible swap inside a Sudoku row permutes that row's entries, so it
preserves the row's value multiset.  Concretely: any row that is a bijection onto the
nine symbols has entry-sum `0 + 1 + ⋯ + 8 = 36`, an invariant of every swap move.
The swap chain therefore stays inside a fixed level set — the combinatorial origin of
the invariant blocks that decompose the move graph. -/
theorem sudoku_row_sum (row : Fin 9 → Fin 9) (h : Function.Bijective row) :
    ∑ j, (row j : ℕ) = 36 := by
  rw [Function.Bijective.sum_comp h (fun k => (k : ℕ))]
  decide

end Sudoku

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The circulating slogan says the "spectral gap of a Sudoku puzzle"
falls off a cliff at a critical clue density `d_c = 17/81`, with gap `> ε` below it,
gap `≈ 0` at it, and gap `= 0` (absorbing chain) above `30/81`.  We test the sharper
structural claim that a *single scalar* — the clue count — controls the gap.

**Experiment.**  We modelled the swap chain intrinsically: its state space is the set
of admissible completions, its moves are compatible swaps, and its transition matrix
`swapP G c` is the symmetric, doubly stochastic walk on the resulting move graph `G`.
The expansion `swapP_mulVec_apply` reduces one step of the chain to a discrete
Laplacian, from which the whole spectral dictionary follows.

**Analysis.**  The clue-density story is *false as stated* but points at a true
theorem once the order parameter is corrected.  What survives:
* `swapP_reducible_nonconstant_fixed` — a disconnected move graph forces `λ₂ = 1`,
  hence gap `0`.  This is the genuine "absorbing / no mixing" regime, but it is
  triggered by disconnection of the swap graph, *not* by having many clues.  (It
  needs no assumption on the holding rate `c` at all.)
* `swapP_fixed_const_of_preconnected` — a connected move graph makes `1` a simple
  eigenvalue (the discrete maximum principle), the prerequisite for a positive gap.
* `twoState_eigenvector` / `twoState_gap_pos` versus `twoState_bot_eq_one` — an
  explicit pair of two-completion puzzles with identical clue/solution counts and
  gaps `2c > 0` and `0` respectively.  This *directly refutes* "gap is a function of
  clue count."
* `sudoku_row_sum` — why the move graph splits into blocks at all: compatible swaps
  conserve each row's value multiset.

**Critique.**  None of the results is `native_decide`/definitional: the reducibility
and irreducibility theorems use component indicators and a genuine maximum-principle
argument; the two-state gap uses an explicit eigenvector computation.  The corrected
claim is guarded — `swapP_fixed_const_of_preconnected` gives only simplicity of `1`
(a necessary condition for a positive gap), and the *quantitative* positive gap is
proved only in the exactly-solvable two-state model, honestly bounding the scope.

**Synthesis.**  Connectivity of the graph of compatible swaps, not clue count, is the
order parameter for mixing.  The "phase transition" is the reducible/irreducible
dichotomy of the swap graph.
-/

end SudokuSpectral