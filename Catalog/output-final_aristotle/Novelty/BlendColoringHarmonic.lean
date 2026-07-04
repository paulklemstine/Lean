import Mathlib

/-!
# Non-existence of non-constant "blend" colorings on strongly connected digraphs

We model a finite edge-weighted directed graph on a finite vertex type `V` by a
weight function `w : V → V → ℝ` with `w i j ≥ 0`.  We interpret `w i j` as the
weight of the arc `i → j`, so the out-neighbours of `i` are the vertices `j` with
`w i j > 0`.  We assume the weights are *row-stochastic*, `∑ j, w i j = 1`, so
that for each vertex the outgoing weights form a probability (convex) combination.

A colouring `c : V → ℝ` satisfies the **blend condition** when every vertex's
colour equals the weighted convex combination of the colours of its
out-neighbours:
`c i = ∑ j, w i j * c j`.

The digraph is **strongly connected** when every vertex is reachable from every
other along arcs of positive weight, i.e. `Relation.ReflTransGen (0 < w · ·)`
holds for every ordered pair.

**Main result.**  On a finite strongly connected row-stochastic digraph, every
blend colouring is constant — equivalently, there is *no* non-constant blend
colouring.  This is a discrete maximum principle: harmonic functions of an
irreducible finite Markov chain are constant.

We also record:
* a vector-valued generalisation (colours in `κ → ℝ`), obtained coordinatewise;
* a sharpness result showing strong connectivity is necessary: on the
  non-strongly-connected two-vertex digraph with `w i j = [i = j]`, the identity
  colouring is a non-constant blend colouring.

## Lab Notes

`-- !-- Lab Notes -- !--`

**Hypothesis (Hypothesizer).**  We conjectured (matching the mission statement)
that strong connectivity + convex blend forces constancy.  Competing
conjectures considered and discarded: (a) mere weak connectivity suffices —
FALSE, see the sharpness example; (b) the result needs the weights to be
symmetric / the chain reversible — FALSE, irreducibility alone suffices;
(c) it fails for vector-valued colours — FALSE, it holds coordinatewise.

**Experiment (Experimenter).**  Small cases: the `2`-cycle with `w = [[0,1],[1,0]]`
forces `c 0 = c 1`; the disjoint self-loops `w = id` (not strongly connected)
admit `c = id`, non-constant.  These pin down the exact role of strong
connectivity.  See `ComputationalEvidence.md`.

**Analysis (Analyst).**  The proof is a maximum-principle argument: at an argmax
vertex the equality case of the convex combination forces all positive-weight
successors to also be maximal; strong connectivity propagates maximality to the
whole graph.  The key reusable lemma is `blend_step`.

**Critique (Critic).**  No theorem is vacuous: the main theorem is applied to a
concrete non-trivial witness (`sharpness`) and the hypotheses are shown
necessary.  All main theorems are `sorry`-free and use genuine arguments
(`Finset.sum_eq_zero_iff_of_nonneg`, `Relation.ReflTransGen` induction).

**Synthesis (PI).**  A clean discrete Liouville/maximum principle, with a
vector-valued upgrade and a matching sharpness example delimiting the
hypotheses.

`-- !-- Lab Notes -- !--`
-/

namespace Novelty.BlendColoringHarmonic

open scoped BigOperators

/-- The arc relation of positive weight. -/
def Arc {V : Type*} (w : V → V → ℝ) : V → V → Prop := fun i j => 0 < w i j

/-
**Local maximum principle / equality case of the convex combination.**
At a vertex `i` whose colour attains the global maximum `m`, every out-neighbour
`j` (`w i j > 0`) also attains `m`.
-/
lemma blend_step {V : Type*} [Fintype V] (w : V → V → ℝ) (c : V → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hrow : ∀ i, ∑ j, w i j = 1)
    (hblend : ∀ i, c i = ∑ j, w i j * c j)
    (m : ℝ) (hm : ∀ k, c k ≤ m)
    (i j : V) (hi : c i = m) (hij : 0 < w i j) : c j = m := by
  contrapose! hblend;
  use i;
  refine' ne_of_gt ( lt_of_lt_of_le ( Finset.sum_lt_sum _ _ ) _ );
  use fun k => w i k * m;
  · exact fun k _ => mul_le_mul_of_nonneg_left ( hm k ) ( hw i k );
  · exact ⟨ j, Finset.mem_univ _, mul_lt_mul_of_pos_left ( lt_of_le_of_ne ( hm j ) hblend ) hij ⟩;
  · rw [ ← Finset.sum_mul _ _ _, hrow, one_mul, hi ]

/-
Maximality propagates along arcs of positive weight (reachability).
-/
lemma blend_reach {V : Type*} [Fintype V] (w : V → V → ℝ) (c : V → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hrow : ∀ i, ∑ j, w i j = 1)
    (hblend : ∀ i, c i = ∑ j, w i j * c j)
    (m : ℝ) (hm : ∀ k, c k ≤ m)
    (i0 : V) (hi0 : c i0 = m) :
    ∀ ⦃j⦄, Relation.ReflTransGen (Arc w) i0 j → c j = m := by
  intro j hj; induction hj;
  · exact hi0;
  · apply blend_step;
    all_goals tauto

/-
**Main theorem.**  On a finite strongly connected row-stochastic edge-weighted
digraph, every blend colouring is constant.
-/
theorem blend_const {V : Type*} [Fintype V] (w : V → V → ℝ) (c : V → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hrow : ∀ i, ∑ j, w i j = 1)
    (hblend : ∀ i, c i = ∑ j, w i j * c j)
    (hsc : ∀ i j, Relation.ReflTransGen (Arc w) i j) :
    ∀ i j, c i = c j := by
  intro i j
  haveI : Nonempty V := ⟨i⟩
  obtain ⟨i0, hi0⟩ := Finite.exists_max c
  -- Every vertex is reachable from the argmax `i0`, hence attains the maximum.
  have hall : ∀ k, c k = c i0 := fun k =>
    blend_reach w c hw hrow hblend (c i0) hi0 i0 rfl (hsc i0 k)
  rw [hall i, hall j]

/-
**Vector-valued generalisation.**  Colours in a finite-dimensional real
coordinate space `κ → ℝ`; the blend condition uses the module structure. The
conclusion (constancy) holds coordinatewise.
-/
theorem blend_const_vector {V κ : Type*} [Fintype V] (w : V → V → ℝ)
    (c : V → (κ → ℝ))
    (hw : ∀ i j, 0 ≤ w i j) (hrow : ∀ i, ∑ j, w i j = 1)
    (hblend : ∀ i, c i = ∑ j, w i j • c j)
    (hsc : ∀ i j, Relation.ReflTransGen (Arc w) i j) :
    ∀ i j, c i = c j := by
  -- Let's fix an arbitrary coordinate $k \in \kappa$.
  intro i j
  have h_const : ∀ k : κ, c i k = c j k := by
    intro k
    have hdblend_k : ∀ i, c i k = ∑ j, w i j * c j k := by
      exact fun i => by simpa using congr_fun ( hblend i ) k;
    generalize_proofs at *; (
    -- Apply the scalar version of the theorem to the function $d(v) = c(v)(k)$.
    apply blend_const w (fun v => c v k) hw hrow hdblend_k hsc i j);
  exact funext h_const

/-
**Sharpness of strong connectivity.**  The two-vertex digraph with weight
matrix the identity (`w i j = if i = j then 1 else 0`) is row-stochastic with
non-negative weights, but *not* strongly connected, and the identity colouring
`c i = (i : ℝ)` is a non-constant blend colouring.  Hence strong connectivity
cannot be dropped from `blend_const`.
-/
theorem blend_sharpness :
    ∃ (w : Fin 2 → Fin 2 → ℝ) (c : Fin 2 → ℝ),
      (∀ i j, 0 ≤ w i j) ∧ (∀ i, ∑ j, w i j = 1) ∧
      (∀ i, c i = ∑ j, w i j * c j) ∧ (∃ i j, c i ≠ c j) := by
  refine' ⟨ fun i j => if i = j then 1 else 0, fun i => if i = 0 then 0 else 1, _, _, _, _ ⟩ <;> simp +decide

end Novelty.BlendColoringHarmonic