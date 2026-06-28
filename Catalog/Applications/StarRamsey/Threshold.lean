import Mathlib

/-!
# Exact multicolour Ramsey threshold for stars

This file proves the **exact degree threshold** for forcing a monochromatic star in a
`q`-edge-colouring.  A *monochromatic star* `K_{1,t j}` in colour `j` is a vertex with at
least `t j` incident edges of colour `j`.

The combinatorial heart of any star–Ramsey statement is a single vertex `v`: its incident
edges form a finite set `E`, and a colouring assigns each incident edge a colour in
`Fin q`.  We prove the sharp local dichotomy

* `forcingF`  — if `(∑ j, (t j - 1)) + 1 ≤ #E` then **every** colouring of `E` produces a
  colour `j` whose colour class at `v` has size `≥ t j` (a monochromatic `K_{1,t j}`);
* `avoidanceF` — if `#E ≤ ∑ j, (t j - 1)` then **some** colouring of `E` keeps every colour
  class below its threshold (no monochromatic star);

and assemble them into the exact biconditional `star_threshold`:

> every `q`-colouring of the edges at `v` yields a monochromatic star
> ⟺ `(∑ j, (t j - 1)) + 1 ≤ deg v`.

This is the star analogue of the monochromatic–matching pigeonhole proved in the catalog
file `Catalog/Novelty/AFLMatching/Basic.lean`
(`AFLMatching.IsMatching.exists_mono_of_card`): there the pigeonhole splits a matching, here
it splits the edges incident to a single vertex, and crucially we obtain a *sharp* threshold
in both directions, not just a one–sided bound.

The graph-level consequences live in `Graphs.lean`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The "exact Ramsey number for stars" should localise completely
to a single vertex.  Forcing a monochromatic `K_{1,t j}` is a pigeonhole on the incident
edges (cheap), and *avoiding* all of them simultaneously should be possible exactly when the
degree fits inside the total capacity `∑ (t j - 1)` of the colour classes.  Conjecture: the
threshold is `∑ (t j - 1) + 1` on the degree, with NO interaction between colours.

Experiment (Experimenter): Formalised the colour-count `cc`, proved `sum_cc`
(the counts partition `E`), `forcingF` (contrapositive pigeonhole + `omega`), and the harder
`avoidanceF`.  The avoidance construction packs the `#E` edges into the disjoint union of
"capacity slots" `Σ j, Fin (t j - 1)` via a cardinality embedding
(`Function.Embedding.nonempty_of_card_le`), then reads off the colour as the slot's first
coordinate; the per-colour fibre has exactly `t j - 1` slots (`sigma_fst_fiber_card`).  All
`sorry`-free.

Analysis (Analyst): The dichotomy is *clean*: colours genuinely do not interact at a vertex,
so the local threshold is exactly `∑ (t j - 1) + 1`.  This already contradicts a naive reading
of the proposed global formula `∑ (t j - 1) + max{2s, s + max_j t_j}` on the complete graph
(`s` minimal): there the per-vertex pigeonhole forces a star once the degree exceeds
`∑ (t j - 1)`, i.e. at `N - 1 ≥ ∑ (t j - 1) + 1`, with no extra `max_j t_j` slack.  The
`max_j t_j` term must therefore be a genuinely *global* (edge-sharing) phenomenon of
`s`-connector graphs, not visible at one vertex — exactly analogous to how the AFL/global
matching constant is invisible to the greedy/local bound in `AFLMatching/Bounds.lean`.

Critique (Critic): Both directions need `q > 0` (a colour must exist) for `avoidanceF`; the
threshold side needs `1 ≤ t j` so that "`t j ≤ count`" is a non-vacuous star.  We keep `t j = 0`
out of the *iff* (it would make a star trivial); `forcingF` itself needs neither hypothesis.

Synthesis (PI): A fully verified, two-sided, sharp local star–Ramsey threshold, stated over an
arbitrary finite incident-edge set so it transfers verbatim to graphs in `Graphs.lean`.
-/

open Finset

namespace StarRamsey

variable {α : Type*} [DecidableEq α] {q : ℕ}

/-- `cc E c j` is the number of elements of `E` (incident edges) coloured `j`. -/
def cc (E : Finset α) (c : α → Fin q) (j : Fin q) : ℕ :=
  (E.filter (fun i => c i = j)).card

/-- The colour classes partition `E`: summing the colour counts recovers `#E`. -/
theorem sum_cc (E : Finset α) (c : α → Fin q) : ∑ j, cc E c j = E.card := by
  classical
  unfold cc
  rw [← Finset.card_biUnion]
  · congr 1
    ext i
    simp only [Finset.mem_biUnion, Finset.mem_univ, Finset.mem_filter, true_and]
    constructor
    · rintro ⟨j, hj, _⟩; exact hj
    · intro hi; exact ⟨c i, hi, rfl⟩
  · intro x _ y _ hxy
    apply Finset.disjoint_left.2
    intro i hi hj
    simp only [Finset.mem_filter] at hi hj
    exact hxy (hi.2 ▸ hj.2)

/-- **Forcing (pigeonhole).** If a vertex has more than `∑ (t j - 1)` incident edges, then
every `q`-colouring of those edges contains a colour `j` whose class has size `≥ t j`, i.e. a
monochromatic star `K_{1,t j}`. -/
theorem forcingF (E : Finset α) (t : Fin q → ℕ) (c : α → Fin q)
    (hcard : (∑ j, (t j - 1)) + 1 ≤ E.card) : ∃ j, t j ≤ cc E c j := by
  by_contra h
  push_neg at h
  have hle : ∀ j, cc E c j ≤ t j - 1 := fun j => by have := h j; omega
  have : E.card ≤ ∑ j, (t j - 1) := by
    rw [← sum_cc E c]; exact Finset.sum_le_sum (fun j _ => hle j)
  omega

/-- The fibre of `Sigma.fst` over a colour `j` in the capacity-slot type
`Σ j, Fin (t j - 1)` has exactly `t j - 1` elements. -/
theorem sigma_fst_fiber_card (t : Fin q → ℕ) (j : Fin q) :
    (Finset.univ.filter (fun s : Σ j : Fin q, Fin (t j - 1) => s.1 = j)).card = t j - 1 := by
  have hset : (Finset.univ.filter (fun s : Σ j : Fin q, Fin (t j - 1) => s.1 = j))
      = Finset.univ.image (fun k : Fin (t j - 1) => (⟨j, k⟩ : Σ j : Fin q, Fin (t j - 1))) := by
    ext s
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · rintro rfl; exact ⟨s.2, by rfl⟩
    · rintro ⟨k, hk⟩; rw [← hk]
  rw [hset, Finset.card_image_of_injective]
  · simp
  · intro a b hab; simpa using hab

omit [DecidableEq α] in
/-- Counting a predicate over a finset equals counting it over the corresponding subtype. -/
theorem card_filter_subtype (E : Finset α) (P : α → Prop) [DecidablePred P] :
    (E.filter P).card = (Finset.univ.filter (fun x : {x // x ∈ E} => P x.1)).card := by
  rw [← Finset.card_attach (s := E.filter P)]
  apply Finset.card_bij (fun x _ => (⟨x.1, (Finset.mem_filter.mp x.2).1⟩ : {x // x ∈ E}))
  · intro a ha; simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact (Finset.mem_filter.mp a.2).2
  · intro a _ b _ hab; simp only [Subtype.mk.injEq] at hab; exact Subtype.ext hab
  · intro b hb
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hb
    exact ⟨⟨b.1, Finset.mem_filter.mpr ⟨b.2, hb⟩⟩, Finset.mem_attach _ _, rfl⟩

/-- **Avoidance (sharp construction).** If a vertex has at most `∑ (t j - 1)` incident edges,
then some `q`-colouring keeps every colour class below its threshold: no monochromatic star
`K_{1,t j}` appears. -/
theorem avoidanceF (E : Finset α) (t : Fin q → ℕ) (hq : 0 < q)
    (hcard : E.card ≤ ∑ j, (t j - 1)) :
    ∃ c : α → Fin q, ∀ j, cc E c j ≤ t j - 1 := by
  classical
  have hcardS : Fintype.card (Σ j : Fin q, Fin (t j - 1)) = ∑ j, (t j - 1) := by
    simp [Fintype.card_sigma]
  have hcle : Fintype.card {x // x ∈ E} ≤ Fintype.card (Σ j : Fin q, Fin (t j - 1)) := by
    rw [hcardS, Fintype.card_coe]; exact hcard
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcle
  refine ⟨fun i => if h : i ∈ E then (e ⟨i, h⟩).1 else ⟨0, hq⟩, fun j => ?_⟩
  unfold cc
  rw [card_filter_subtype]
  have hmap : (Finset.univ.filter
        (fun x : {x // x ∈ E} =>
          (if h : x.1 ∈ E then (e ⟨x.1, h⟩).1 else ⟨0, hq⟩) = j)).card
      ≤ (Finset.univ.filter (fun s : Σ j : Fin q, Fin (t j - 1) => s.1 = j)).card := by
    apply Finset.card_le_card_of_injOn (fun x => e x)
    · intro x hx
      simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq] at hx ⊢
      rw [dif_pos x.2] at hx
      exact hx
    · intro a _ b _ hab; exact e.injective hab
  rw [sigma_fst_fiber_card] at hmap
  exact hmap

/-- **Exact star–Ramsey threshold (local form).**  For thresholds `t j ≥ 1` and at least one
colour, every `q`-colouring of the `#E` edges incident to a vertex forces a monochromatic star
`K_{1,t j}` for some colour `j` **iff** `(∑ j, (t j - 1)) + 1 ≤ #E`. -/
theorem star_threshold (E : Finset α) (t : Fin q → ℕ) (ht : ∀ j, 1 ≤ t j) (hq : 0 < q) :
    (∀ c : α → Fin q, ∃ j, t j ≤ cc E c j) ↔ (∑ j, (t j - 1)) + 1 ≤ E.card := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    obtain ⟨c, hcj⟩ := avoidanceF E t hq (by omega)
    obtain ⟨j, hj⟩ := h c
    have h1 := hcj j
    have h2 := ht j
    omega
  · intro h c; exact forcingF E t c h

end StarRamsey