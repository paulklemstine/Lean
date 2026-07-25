/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Seymour's Second Neighborhood Conjecture: base cases and structured families

Seymour's Second Neighborhood Conjecture (SSNC) asserts that every finite
*oriented graph* (a directed graph with no loops and no digons, i.e. an
asymmetric relation) contains a **Seymour vertex** `v`: a vertex whose second
out-neighborhood is at least as large as its first out-neighborhood,
`|N⁺⁺(v)| ≥ |N⁺(v)|`.

The full conjecture is open.  Known unconditional results establish it for
several structured families and low-degree regimes; the literature that this
file is attached to (Dean–Latka 1995, Fisher 1996, Havet–Thomassé 2000,
Ai–Gerke–Gutin–Wang–Ye–Zhou 2024, and the min-out-degree ≤ 6/7 line of work)
proves it for tournaments and for oriented graphs of small minimum out-degree.

This file formalizes the two cleanest unconditional cases with fully checked
proofs:

* `exists_seymour_of_min_outdeg_le_one`: every finite oriented graph whose
  minimum out-degree is at most `1` has a Seymour vertex.  This is the genuine
  base case of the min-out-degree program: it shows a *minimal counterexample*
  to SSNC must have minimum out-degree at least `2`.

* `exists_seymour_of_transitive`: every finite (nonempty) transitive oriented
  graph has a Seymour vertex — namely a sink / maximal element, whose second
  out-neighborhood collapses by transitivity.

We work with a bare asymmetric relation `adj : V → V → Prop` on a finite type
`V`; asymmetry (`adj a b → ¬ adj b a`) simultaneously encodes "no loops" and
"no digons", which is exactly the oriented-graph hypothesis.
-/
import Mathlib

open Finset

set_option maxHeartbeats 1000000

namespace Catalog.Probability.SeymourSND

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The (first) out-neighborhood of `v`: the vertices `w` with an arc `v → w`. -/
noncomputable def outNbhd (adj : V → V → Prop) (v : V) : Finset V := by
  classical
  exact univ.filter (fun w => adj v w)

/-- The out-degree of `v` is the size of its out-neighborhood. -/
noncomputable def outDeg (adj : V → V → Prop) (v : V) : ℕ := (outNbhd adj v).card

/-- The **second out-neighborhood** of `v`: vertices at directed distance
exactly two, i.e. reachable by a length-2 directed walk but not equal to `v`
and not already a (first) out-neighbor of `v`. -/
noncomputable def secondOutNbhd (adj : V → V → Prop) (v : V) : Finset V := by
  classical
  exact univ.filter (fun w => w ≠ v ∧ w ∉ outNbhd adj v ∧ ∃ x, adj v x ∧ adj x w)

/-- A **Seymour vertex**: its second out-neighborhood is at least as large as
its first out-neighborhood. -/
def IsSeymour (adj : V → V → Prop) (v : V) : Prop :=
  outDeg adj v ≤ (secondOutNbhd adj v).card

omit [DecidableEq V] in
@[simp] lemma mem_outNbhd {adj : V → V → Prop} {v w : V} :
    w ∈ outNbhd adj v ↔ adj v w := by
  classical
  simp [outNbhd]

@[simp] lemma mem_secondOutNbhd {adj : V → V → Prop} {v w : V} :
    w ∈ secondOutNbhd adj v ↔
      w ≠ v ∧ w ∉ outNbhd adj v ∧ ∃ x, adj v x ∧ adj x w := by
  classical
  simp [secondOutNbhd]

omit [Fintype V] [DecidableEq V] in
/-- Irreflexivity is a consequence of asymmetry. -/
lemma irrefl_of_asymm {adj : V → V → Prop}
    (hasym : ∀ a b, adj a b → ¬ adj b a) (v : V) : ¬ adj v v :=
  fun h => hasym v v h h

/-- A sink (vertex with empty out-neighborhood) is a Seymour vertex. -/
lemma isSeymour_of_outNbhd_eq_empty {adj : V → V → Prop} {v : V}
    (h : outNbhd adj v = ∅) : IsSeymour adj v := by
  unfold IsSeymour outDeg
  simp [h]

/-
**Base case of the min-out-degree program.**  In a finite oriented graph
(asymmetric relation), if some vertex of minimum out-degree has out-degree at
most `1`, then the graph has a Seymour vertex.  Equivalently: a minimal
counterexample to Seymour's conjecture must have minimum out-degree at least
`2`.
-/
theorem exists_seymour_of_min_outdeg_le_one
    (adj : V → V → Prop) (hasym : ∀ a b, adj a b → ¬ adj b a) [Nonempty V]
    (hmin : ∃ u : V, (∀ v, outDeg adj u ≤ outDeg adj v) ∧ outDeg adj u ≤ 1) :
    ∃ s : V, IsSeymour adj s := by
  obtain ⟨ u, hu1, hu2 ⟩ := hmin; by_cases hu : outDeg adj u = 0 <;> simp_all +decide [ IsSeymour ] ;
  · exact ⟨ u, hu.le.trans ( Nat.zero_le _ ) ⟩;
  · -- Since outDeg adj u = 1, let w be the unique element in outNbhd adj u.
    obtain ⟨ w, hw ⟩ : ∃ w, outNbhd adj u = {w} := by
      exact Finset.card_eq_one.mp ( le_antisymm hu2 ( Nat.pos_of_ne_zero hu ) )
    have hw_adj : adj u w := by
      exact mem_outNbhd.mp ( hw.symm ▸ Finset.mem_singleton_self _ )
    have hw_out : outDeg adj w ≥ 1 := by
      exact Nat.pos_of_ne_zero ( by specialize hu1 w; aesop )
    have hw_nonempty : ∃ x, adj w x := by
      contrapose! hw_out; simp_all +decide [ outDeg, outNbhd ] ;
    obtain ⟨ x, hx ⟩ := hw_nonempty
    have hx_second : x ∈ secondOutNbhd adj u := by
      grind +suggestions
    use u
    simp_all +decide [ secondOutNbhd ];
    exact le_trans hu2 ( Finset.card_pos.mpr ⟨ x, by aesop ⟩ )

/-
Existence of a sink in a finite nonempty transitive oriented graph.
-/
omit [DecidableEq V] in
lemma exists_sink_of_transitive
    (adj : V → V → Prop) (hasym : ∀ a b, adj a b → ¬ adj b a) [Nonempty V]
    (htrans : ∀ a b c, adj a b → adj b c → adj a c) :
    ∃ m : V, outNbhd adj m = ∅ := by
  -- Set r : V → V → Prop := fun a b => adj b a (the flipped relation).
  let r : V → V → Prop := fun a b => adj b a;
  -- Then r is well-founded on the finite type: have hwf : WellFounded r := Finite.wellFounded_of_trans_of_irrefl r.
  have hwf : WellFounded r := by
    haveI : IsTrans V r := ⟨fun a b c hab hbc => htrans c b a hbc hab⟩
    haveI : Std.Irrefl r := ⟨fun a => irrefl_of_asymm hasym a⟩
    exact Finite.wellFounded_of_trans_of_irrefl r;
  obtain ⟨ m, hm ⟩ := hwf.has_min Set.univ ⟨ Classical.arbitrary V, Set.mem_univ _ ⟩ ; use m; ext w; aesop;

/-
**Transitive oriented graphs satisfy SSNC.**  Every finite nonempty
transitive oriented graph has a Seymour vertex: a maximal element is a sink,
and by transitivity its second out-neighborhood is empty.
-/
theorem exists_seymour_of_transitive
    (adj : V → V → Prop) (hasym : ∀ a b, adj a b → ¬ adj b a) [Nonempty V]
    (htrans : ∀ a b c, adj a b → adj b c → adj a c) :
    ∃ s : V, IsSeymour adj s := by
  obtain ⟨ m, hm ⟩ := exists_sink_of_transitive adj hasym htrans; use m; simp_all +decide [ IsSeymour, outDeg ] ;

/-
**Functional oriented graphs satisfy SSNC everywhere.**  If every vertex of a
finite oriented graph has out-degree exactly `1` (a functional oriented graph),
then *every* vertex is a Seymour vertex.  Indeed for each `v` its unique
out-neighbor `w` again has out-degree `1`, so `w` points to some `x`; asymmetry
forces `x ∉ {v, w}`, placing `x` in the second out-neighborhood of `v`.
-/
theorem functional_all_seymour
    (adj : V → V → Prop) (hasym : ∀ a b, adj a b → ¬ adj b a)
    (hfun : ∀ v, outDeg adj v = 1) :
    ∀ v : V, IsSeymour adj v := by
  intro v
  obtain ⟨ w, hw ⟩ := Finset.card_eq_one.mp (hfun v);
  obtain ⟨x, hx⟩ : ∃ x, adj w x := by
    have := hfun w; unfold outDeg at this; simp_all +decide [ outNbhd ] ;
    exact Exists.elim ( Finset.card_pos.mp ( by linarith ) ) fun x hx => ⟨ x, by simpa using hx ⟩;
  refine' le_trans _ ( Finset.card_pos.mpr ⟨ x, _ ⟩ );
  · exact hfun v ▸ le_rfl;
  · simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
    grind +splitImp

/-
**Necessity of the oriented hypothesis (Critic guard).**  Asymmetry cannot be
dropped from any of the results above: there is a two-vertex *symmetric*
digraph (a single digon) of constant out-degree `1` with **no** Seymour vertex.
Here `adj a b := a ≠ b` on `Bool` realizes the digon `true ↔ false`.
-/
theorem digon_has_no_seymour :
    ¬ ∃ s : Bool, IsSeymour (fun a b : Bool => a ≠ b) s := by
  unfold IsSeymour; simp +decide [ outDeg, outNbhd, secondOutNbhd ] ;

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
Candidate conjectures around Seymour's Second Neighborhood Conjecture (SSNC),
ranked by expected impact:
  1. (SURPRISING) A minimal counterexample to SSNC must have minimum
     out-degree >= 2 -- i.e. min-out-degree <= 1 already forces a Seymour vertex.
  2. Transitive oriented graphs satisfy SSNC via a sink whose second
     out-neighborhood collapses.
  3. (SURPRISING) In a transitive oriented graph the *only* Seymour vertices
     forced by our argument are sinks: transitivity makes N++ empty for every
     vertex, so a vertex is Seymour iff it is a sink.
  4. Every oriented graph with a sink satisfies SSNC (the sink is Seymour).
  5. Asymmetry alone (no digons, no loops) is exactly the right hypothesis:
     dropping it, a single digon u<->w with w a sink breaks the deg-1 argument.
  6. The deg-1 argument is tight: minimality of the chosen vertex is essential
     (max-out-degree vertices need not be Seymour).
  7. Second out-neighborhoods are not monotone in out-degree, so a naive
     'max out-degree vertex is Seymour' strategy fails.

## Experiment (Experimenter)
Computational sanity checks (see ComputationalEvidence.md): all oriented graphs
on <= 4 vertices contain a Seymour vertex; the directed 3-cycle has every
vertex Seymour; transitive tournaments are Seymour only at their sink. The
deg-<=1 argument was validated on the 'arrow' u->w->x.

## Analysis (Analyst)
Conjecture 1 formalized as `exists_seymour_of_min_outdeg_le_one`: the case
split on outDeg = 0 (sink) vs = 1 (a neighbor of the unique out-neighbor lands
in N++, using asymmetry to place it correctly) goes through. Conjecture 2/3
formalized as `exists_seymour_of_transitive` via `exists_sink_of_transitive`,
which extracts a maximal element from well-foundedness of a finite transitive
irreflexive relation (`Finite.wellFounded_of_trans_of_irrefl`). Failure mode:
extending the deg-1 argument to deg-2 is genuinely hard (the frontier the
attached min-out-degree <= 6/7 literature pushes on) and is NOT attempted here.

## Critique (Critic)
- No theorem is vacuous: `Nonempty V` is assumed and each conclusion asserts
  existence of a genuine Seymour vertex. Asymmetry `hasym` is load-bearing in
  the deg-1 case (used to show the length-2 endpoint differs from u and w).
- Proofs use real content (case analysis, `Finset.card_eq_one`, well-founded
  minimal element), not `native_decide` or definitional rfl.
- The Seymour condition is stated with the correct direction |N++| >= |N+|
  and N++ correctly excludes {v} together with N+(v).

## Synthesis (PI)
The results isolate which regimes of SSNC are unconditionally tractable:
minimum out-degree <= 1 and transitivity. Both reduce to existence of a
suitable low-degree or maximal vertex, clarifying why the difficulty of SSNC
concentrates in the min-out-degree >= 2 regime.
-/

end Catalog.Probability.SeymourSND