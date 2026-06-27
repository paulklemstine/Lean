/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The fractional independence number `α*(H)` and its sparse-threshold bounds

The sparse threshold conjecture of Day & Sarkar predicts that the exponent and the extremal
graphon of the sparse subgraph-density problem are controlled by the **fractional independence
number** `α*(H)`: the value of the linear-programming relaxation of the independence number,

  `α*(H) = max { Σ_v x_v : 0 ≤ x_v ≤ 1, and x_u + x_v ≤ 1 for every edge uv }`.

This file gives a clean, self-contained Lean development of `α*` as a real supremum over the
feasible polytope of a finite simple graph, and proves the structural bounds that the threshold
theory needs:

* the polytope value is always bounded by the number of vertices (`alphaStar_le_card`);
* the all-`½` assignment is feasible, giving the universal lower bound `|V|/2 ≤ α*(H)`
  (`half_card_le_alphaStar`);
* a single edge already forces `α*(H) ≤ |V| - 1` (`alphaStar_le_card_sub_one_of_edge`), so a
  graph **without isolated vertices** never has the trivial value `|V|`;
* for the complete graph the universal lower bound is *tight*: `α*(K_n) = n/2`
  (`alphaStar_completeGraph`).

## Catalog connections
* `Fractional independence number α*(H)`: `alphaStar` is precisely this LP value, here built as a
  genuine `sSup` over the feasible set.
* `Day & Sarkar's sparse threshold conjecture`: `half_card_le_alphaStar` and
  `alphaStar_le_card_sub_one_of_edge` are the structural inputs that pin the conjectured exponent.
* `Three-step threshold graphon characterization`: the half-integral extremal structure of the
  `α*`-polytope mirrors the three-block structure of the extremal graphon.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `α*(H)` is sandwiched as `|V|/2 ≤ α*(H) ≤ |V|`, with the lower bound
  attained by the densest graphs (complete graphs) and the upper bound never attained once `H`
  has an edge.  The half-integral "all-½" point is the universal certificate for the lower bound.
Experiment (Experimenter): Defined feasibility (`0 ≤ x ≤ 1`, plus the edge constraints) and the
  value `Σ_v x_v`, then `alphaStar := sSup (valueSet)`.  Proved boundedness (`Σ x ≤ card`) and
  nonemptiness (`x = 0`), so the `sSup` is well-behaved.  Lower bound: the constant `½` assignment
  is feasible with value `card/2`, apply `le_csSup`.  Complete-graph upper bound: double count
  `Σ_u Σ_{v≠u} (x_u + x_v) ≤ n(n-1)` to get `(2n-2)·Σ x ≤ n(n-1)`, hence `Σ x ≤ n/2`.
Analysis (Analyst): The double-count is the LP-dual fractional vertex cover in disguise; the
  factor `2n-2` is `2(n-1)` because each vertex appears in `n-1` complete-graph edges.  The
  "no isolated vertices ⇒ α* < |V|" phenomenon is captured by the single-edge bound: one edge
  caps the two endpoints' joint contribution at `1` instead of `2`.
Critique (Critic): The `sSup` could be vacuous if the feasible set were empty or unbounded; both
  are ruled out (nonempty via `x=0`, bounded via `x ≤ 1`).  The complete-graph equality needs
  `2 ≤ n` (at `n=1`, `K_1` is edgeless and `α* = 1 ≠ 1/2`); we keep that hypothesis honestly.
Synthesis (PI): A reusable LP-style `α*` with the exact sandwich the threshold conjecture uses,
  feeding the exponent of `Catalog/Novelty/SparseThresholdVariational.lean`.
-/
import Mathlib

open Finset

namespace SparseThreshold

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A point of the fractional-independence polytope of `G`: each coordinate lies in `[0,1]` and
each edge constraint `x u + x v ≤ 1` holds. -/
def FracIndepFeasible (G : SimpleGraph V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v ∧ x v ≤ 1) ∧ ∀ u v, G.Adj u v → x u + x v ≤ 1

/-- The value `Σ_v x_v` of a fractional-independence point. -/
def fracIndepValue (x : V → ℝ) : ℝ := ∑ v, x v

/-- The set of achievable values of the fractional-independence LP. -/
def fracIndepValueSet (G : SimpleGraph V) : Set ℝ :=
  {s | ∃ x, FracIndepFeasible G x ∧ s = fracIndepValue x}

/-- The **fractional independence number** `α*(G)`: the value of the LP relaxation of the
independence number, defined as the supremum over the feasible polytope. -/
noncomputable def alphaStar (G : SimpleGraph V) : ℝ := sSup (fracIndepValueSet G)

omit [DecidableEq V] in
lemma fracIndepValueSet_nonempty (G : SimpleGraph V) : (fracIndepValueSet G).Nonempty :=
  ⟨_, ⟨0, ⟨fun _ => ⟨by norm_num, by norm_num⟩, fun _ _ _ => by norm_num⟩, rfl⟩⟩

omit [DecidableEq V] in
lemma fracIndepValue_le_card {G : SimpleGraph V} {x : V → ℝ} (hx : FracIndepFeasible G x) :
    fracIndepValue x ≤ (Fintype.card V : ℝ) := by
  simpa using Finset.sum_le_sum fun v (_ : v ∈ Finset.univ) => hx.1 v |>.2

omit [DecidableEq V] in
lemma fracIndepValueSet_bddAbove (G : SimpleGraph V) : BddAbove (fracIndepValueSet G) :=
  ⟨Fintype.card V, by rintro _ ⟨x, hx, rfl⟩; exact fracIndepValue_le_card hx⟩

omit [DecidableEq V] in
/-- `α*(G) ≤ |V|`. -/
theorem alphaStar_le_card (G : SimpleGraph V) : alphaStar G ≤ (Fintype.card V : ℝ) :=
  csSup_le (fracIndepValueSet_nonempty G) fun x hx => by
    obtain ⟨y, hy, rfl⟩ := hx; exact fracIndepValue_le_card hy

omit [Fintype V] [DecidableEq V] in
/-- The all-`½` assignment is feasible. -/
lemma half_feasible (G : SimpleGraph V) : FracIndepFeasible G (fun _ => (1:ℝ)/2) := by
  constructor <;> norm_num

omit [DecidableEq V] in
/-- **Universal lower bound:** `|V|/2 ≤ α*(G)`, certified by the all-`½` point. -/
theorem half_card_le_alphaStar (G : SimpleGraph V) :
    (Fintype.card V : ℝ) / 2 ≤ alphaStar G := by
      have h_card_half_mem : (Fintype.card V : ℝ) / 2 ∈ fracIndepValueSet G := by
        use fun _ => (1:ℝ)/2;
        exact ⟨ half_feasible G, by unfold fracIndepValue; simp +decide [ div_eq_mul_inv ] ⟩;
      exact le_csSup ( fracIndepValueSet_bddAbove G ) h_card_half_mem

/-- A single edge already caps the value at `|V| - 1`: graphs without isolated vertices never
attain the trivial value `|V|`. -/
theorem alphaStar_le_card_sub_one_of_edge {G : SimpleGraph V} {a b : V} (hab : G.Adj a b) :
    alphaStar G ≤ (Fintype.card V : ℝ) - 1 := by
      have h_feasible : ∀ x : V → ℝ, (FracIndepFeasible G x) → (∑ v : V, x v) ≤ (Fintype.card V : ℝ) - 1 := by
        intro x hx; have := hx.2 a b hab; simp_all +decide ;
        have h_split : ∑ v ∈ Finset.univ \ {a, b}, x v ≤ (Fintype.card V - 2 : ℝ) := by
          refine' le_trans ( Finset.sum_le_sum fun v hv => hx.1 v |>.2 ) _ ; simp +decide [ Finset.card_sdiff, * ];
          rw [ Nat.cast_sub ] <;> norm_num [ Finset.card_insert_of_notMem, hab.ne ] ; linarith [ show Fintype.card V ≥ 2 from Fintype.one_lt_card_iff_nontrivial.mpr ⟨ a, b, hab.ne ⟩ ] ;
        rw [ ← Finset.sum_sdiff ( Finset.subset_univ { a, b } ) ] ; simp +decide [ Finset.sum_pair hab.ne ] at * ; linarith;
      exact csSup_le ( fracIndepValueSet_nonempty G ) fun s hs => hs.choose_spec.2.symm ▸ h_feasible _ hs.choose_spec.1

/-
**The complete-graph value is `n/2`.** The universal lower bound is tight precisely for the
densest graph.
-/
theorem alphaStar_completeGraph (h : 2 ≤ Fintype.card V) :
    alphaStar (⊤ : SimpleGraph V) = (Fintype.card V : ℝ) / 2 := by
      refine' le_antisymm _ _;
      · refine' csSup_le _ _;
        · exact fracIndepValueSet_nonempty _;
        · rintro _ ⟨ x, hx, rfl ⟩;
          -- Consider the sum $\sum_{u \neq v} (x_u + x_v)$. Since $x$ is feasible, we have $x_u + x_v \leq 1$ for all $u \neq v$.
          have h_sum_bound : ∑ u : V, ∑ v ∈ Finset.univ.erase u, (x u + x v) ≤ ∑ u : V, ∑ v ∈ Finset.univ.erase u, 1 := by
            exact Finset.sum_le_sum fun u hu => Finset.sum_le_sum fun v hv => hx.2 u v <| by aesop;
          simp_all +decide [ Finset.sum_add_distrib ];
          rw [ ← Finset.mul_sum _ _ _ ] at h_sum_bound ; rw [ Nat.cast_pred ( by linarith ) ] at h_sum_bound ; nlinarith [ show ( Fintype.card V : ℝ ) ≥ 2 by norm_cast, show ( fracIndepValue x : ℝ ) = ∑ v, x v from rfl ] ;
      · grind +suggestions

end SparseThreshold