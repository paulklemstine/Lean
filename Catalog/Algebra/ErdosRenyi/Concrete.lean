/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Concrete `G(n, p)` on `Fin n`: edge, isolated–vertex and triangle counts

Building on `Catalog.Algebra.ErdosRenyi.Model`, we instantiate the Erdős–Rényi
law on the complete graph on `Fin n`, whose edges are the ordered pairs `i < j`.
We compute the three first–moment quantities that govern the classical thresholds:

* `ErdosRenyiConcrete.expectation_count` — general linearity of expectation: the
  expected number of events (indexed by a finset `I`) that occur equals the sum of
  their probabilities.
* `ErdosRenyiConcrete.card_edge` — there are `C(n,2)` potential edges.
* `ErdosRenyiConcrete.expected_edges` — `𝔼[#edges] = C(n,2) · p`.
* `ErdosRenyiConcrete.card_incident` — every vertex is incident to `n − 1` edges.
* `ErdosRenyiConcrete.expected_isolated` — `𝔼[#isolated vertices] = n · (1−p)^{n−1}`,
  the quantity whose first/second moments pin the connectivity threshold `ln n / n`.
* `ErdosRenyiConcrete.card_triEdges` — a `3`-set spans exactly `3` edges.
* `ErdosRenyiConcrete.expected_triangles` — `𝔼[#triangles] = C(n,3) · p³`, whose
  threshold sits at `p = 1/n`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): all three classical first moments (`C(n,2)p`,
  `n(1−p)^{n−1}`, `C(n,3)p³`) are a single linearity-of-expectation identity
  `expectation_count` evaluated at three different event families, with the only
  genuinely combinatorial input being three cardinalities: `#edges = C(n,2)`,
  `#incident = n−1`, `#triEdges = 3`.
Experiment (Stage 2): `card_incident` is the bijection `e ↦ (other endpoint)`
  onto `{u | u ≠ v}` (card `n−1`); `card_triEdges` is the bijection
  `e ↦ {e.1.1, e.1.2}` onto the `2`-subsets of the triangle (card `C(3,2)=3`);
  `card_edge` counts `i<j` pairs as `∑_j #{i<j} = ∑_j j = C(n,2)`.  Edges plug into
  `expectation_subgraphCount` (singleton copies), isolated vertices into
  `expectation_count` with `allAbsent`, triangles into `expectation_count` with
  `allPresent` over the `3`-subsets `Finset.univ.powersetCard 3`.
Analysis (Stage 3): the dual independence lemmas `prob_allPresent`/`prob_allAbsent`
  from `Model.lean` are exactly what makes present-events (triangles) and
  absent-events (isolated vertices) symmetric; the `n−1` exponent for isolated
  vertices is the *degree* of the complete graph, which is why the connectivity
  threshold lives at `ln n / n` (so that `n(1−p)^{n−1} → const`).
Critique (Stage 4): every result is an exact identity proved by bijection/`omega`/
  `Finset` algebra, not `decide` (the statements are uniform in `n`).  The
  cardinalities are load-bearing and separately verified.
Synthesis (Stage 5): these exact expectations feed `firstMoment` (vanishing below
  threshold) and `second_moment_zero` (appearance above threshold); the asymptotic
  sharp thresholds are stated as conjectures in `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Algebra.ErdosRenyi.Model

open Finset BigOperators ErdosRenyi

namespace ErdosRenyiConcrete

variable {n : ℕ}

/-- General linearity of expectation: the expected number of events from a finite
family `A` (indexed by `i ∈ I`) that occur on a configuration equals the sum of
the probabilities of the events.
-/
theorem expectation_count {E ι : Type*} [Fintype E] [DecidableEq E] [DecidableEq ι]
    (p : ℝ) (I : Finset ι) (A : ι → Finset (E → Bool)) :
    expectation p (fun g => ((I.filter (fun i => g ∈ A i)).card : ℝ))
      = ∑ i ∈ I, prob p (A i) := by
  unfold expectation prob; simp +decide ;
  simp +decide only [card_filter, Nat.cast_sum];
  simp +decide only [Finset.mul_sum _ _ _];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop

/-! ### The complete graph on `Fin n` -/

/-- Edges of the complete graph on `Fin n`: ordered pairs `i < j`. -/
abbrev Edge (n : ℕ) := {e : Fin n × Fin n // e.1 < e.2}

/-- There are `C(n,2)` potential edges on `n` labelled vertices. -/
theorem card_edge : Fintype.card (Edge n) = n.choose 2 := by
  convert Finset.card_filter ( fun e : Fin n × Fin n => e.1 < e.2 ) Finset.univ using 1;
  · convert Fintype.card_subtype _;
  · convert Nat.choose_two_right n using 1;
    convert Finset.sum_range_id n using 1;
    erw [ Finset.sum_product ] ; simp +decide [ Finset.sum_range ];
    simp +decide [ Finset.filter_lt_eq_Ioi ];
    conv_rhs => rw [ ← Finset.sum_range fun i => i ];
    rw [ ← Finset.sum_range_reflect, Finset.sum_range ]

/-- The expected number of present edges in `G(n,p)` is `C(n,2) · p`. -/
theorem expected_edges (p : ℝ) :
    expectation p (fun g => (subgraphCount (fun e : Edge n => ({e} : Finset (Edge n))) g : ℝ))
      = (n.choose 2 : ℝ) * p := by
  rw [ expectation_subgraphCount ];
  simp +decide [ ← card_edge ]

/-- The set of edges incident to a vertex `v`. -/
def incident (v : Fin n) : Finset (Edge n) :=
  Finset.univ.filter (fun e => e.1.1 = v ∨ e.1.2 = v)

/-- Every vertex of the complete graph on `Fin n` is incident to `n − 1` edges. -/
theorem card_incident (v : Fin n) : (incident v).card = n - 1 := by
  simp_all +decide [ incident ];
  revert v;
  intro v
  have h_card : Finset.card (Finset.univ.filter (fun e : Fin n × Fin n => (e.1 = v ∨ e.2 = v) ∧ e.1 < e.2)) = n - 1 := by
    rw [ show ( Finset.univ.filter fun e : Fin n × Fin n => ( e.1 = v ∨ e.2 = v ) ∧ e.1 < e.2 ) = Finset.image ( fun x : Fin n => if x < v then ( x, v ) else ( v, x ) ) ( Finset.univ.erase v ) from ?_, Finset.card_image_of_injOn ];
    · simp +decide;
    · intro x hx y hy; aesop;
    · grind;
  convert h_card using 1;
  rw [ ← Finset.card_image_of_injective _ Subtype.coe_injective ] ; congr ; ext ; aesop

/-- The expected number of isolated vertices in `G(n,p)` is `n · (1 − p)^{n−1}`.
A vertex is isolated when all `n − 1` of its incident edges are absent.
-/
theorem expected_isolated (p : ℝ) :
    expectation p
        (fun g => ((Finset.univ.filter
          (fun v : Fin n => g ∈ allAbsent (incident v))).card : ℝ))
      = (n : ℝ) * (1 - p) ^ (n - 1) := by
  convert expectation_count p Finset.univ ( fun v : Fin n => allAbsent ( incident v ) ) using 1;
  rw [ Finset.sum_congr rfl fun _ _ => prob_allAbsent p _ ];
  simp +decide [ card_incident ]

/-! ### Triangles -/

/-- The edge set spanned by a vertex set `T` (the edges with both endpoints in `T`). -/
def triEdges (T : Finset (Fin n)) : Finset (Edge n) :=
  Finset.univ.filter (fun e => e.1.1 ∈ T ∧ e.1.2 ∈ T)

/-- A `3`-element vertex set spans exactly `3` edges. -/
theorem card_triEdges (T : Finset (Fin n)) (hT : T.card = 3) :
    (triEdges T).card = 3 := by
  have h_card : (triEdges T).card = Finset.card (Finset.powersetCard 2 T) := by
    have h_bij : Finset.image (fun e : Edge n => {e.1.1, e.1.2} : Edge n → Finset (Fin n)) (triEdges T) = Finset.powersetCard 2 T := by
      ext;
      constructor;
      · grind +locals;
      · simp +decide [ Finset.mem_image, triEdges ];
        intro h₁ h₂; rw [ Finset.card_eq_two ] at h₂; obtain ⟨ a, b, hab, rfl ⟩ := h₂; cases lt_trichotomy a b <;> aesop;
    rw [ ← h_bij, Finset.card_image_of_injOn ];
    intro e he e' he' h; simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ] ;
    grind;
  aesop

/-- The expected number of triangles in `G(n,p)` is `C(n,3) · p³`.
Triangles are indexed by the `3`-element vertex subsets.
-/
theorem expected_triangles (p : ℝ) :
    expectation p
        (fun g : Edge n → Bool => (((Finset.univ.powersetCard 3).filter
          (fun T => g ∈ allPresent (triEdges T))).card : ℝ))
      = (n.choose 3 : ℝ) * p ^ 3 := by
  have h_sum_congr : ∀ T ∈ Finset.powersetCard 3 (Finset.univ : Finset (Fin n)), (prob p (allPresent (triEdges T))) = p ^ 3 := by
    intro T hT; rw [ prob_allPresent ] ; rw [ card_triEdges T ( Finset.mem_powersetCard.mp hT |>.2 ) ] ;
  convert expectation_count p ( Finset.powersetCard 3 Finset.univ ) ( fun T => allPresent ( triEdges T ) ) using 1;
  rw [ Finset.sum_congr rfl h_sum_congr, Finset.sum_const, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul ]

end ErdosRenyiConcrete