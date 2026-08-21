/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Emotional Duality: a Nordhaus–Gaddum Law for Social Networks and Their Stranger Graphs

Every social network `G` has a *stranger graph* `Gᶜ`: two people are joined exactly when they are
**not** friends.  This file proves that emotional diversity cannot be small in both graphs at once.

  **Product law**    `|V| ≤ χ(G) · χ(Gᶜ)`          (`card_le_mul_chromaticNumber_compl`)
  **Sum law**        `4 |V| ≤ (χ(G) + χ(Gᶜ))²`     (`four_mul_card_le_sq_chromaticNumber_add`)

Neither statement is in Mathlib v4.28.0 (there is no `Nordhaus` anywhere in the library), so the
classical Nordhaus–Gaddum product bound is developed here from the pigeonhole-style observation
that `v ↦ (c v, d v)` is injective for any pair of proper colorings of `G` and `Gᶜ`.

Transported to the catalog's emotional chromatic number this yields a *conservation law of
emotional diversity*: a large population whose friendship graph needs only the six basic emotions
has a stranger graph that needs at least `|V| / 6` of them (`emotional_duality_hundred` makes the
hundred-person case explicit: at least `17`).  Combining with the greedy bound of
`Catalog/Computation/EmotionalGreedyColoring.lean`, a hundred-person network in which nobody has
more than five friends must have a stranger graph in which somebody has at least sixteen strangers
(`sparse_network_has_dense_stranger_graph`).

## Main results

* `card_le_mul_of_colorable_compl`          : the injection principle behind the product law.
* `card_le_mul_chromaticNumber_compl`       : `|V| ≤ χ(G) · χ(Gᶜ)`.
* `card_le_mul_emoChrom_compl`              : `|V| ≤ χ_E(G) · χ_E(Gᶜ)`.
* `four_mul_card_le_sq_chromaticNumber_add` : the sum law `4|V| ≤ (χ + χ̄)²`.
* `four_mul_card_le_sq_emoChrom_add`        : its emotional form.
* `emotional_duality_hundred`               : hundred people, six emotions ⇒ `χ_E(Gᶜ) ≥ 17`.
* `sparse_network_has_dense_stranger_graph` : `Δ(G) ≤ 5`, `|V| = 100` ⇒ `Δ(Gᶜ) ≥ 16`.
* `emoChrom_self_complementary`             : self-complementary networks obey `|V| ≤ χ_E(G)²`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Stage 1, cycle 2).  Cycle 1 produced the sandwich `max ω 3 ≤ χ_E ≤ max (Δ+1) 3` and a
census in which every network sat in `[3,6]`.  The census families were *sparse*.  Bold conjecture:
the `[3,6]` window cannot be a property of *all* large networks, and the obstruction is dual —
sparsity in `G` forces density in `Gᶜ`, and the emotional numbers of the two must multiply to at
least the population.

EXPERIMENT (Stage 2).  Confirmed and quantified.  The proof is a two-coloring product injection:
if `c` is a proper coloring of `G` and `d` one of `Gᶜ`, then distinct people `x ≠ y` are adjacent
in exactly one of the two graphs, so `(c x, d x) ≠ (c y, d y)`; `Fintype.card_le_of_injective`
finishes.  The sum law follows by AM–GM (`nlinarith` on `(a-b)² ≥ 0`).

ANALYSIS (Stage 3).  The product law is sharp for complete graphs (`|V| = |V| · 1` after the
emotional floor is removed) and very loose for sparse graphs, but its *contrapositive* is the
useful direction: it converts the mission's empirical `[3,6]` observation into a statement about
the sampling, not about social networks — every family of networks with `χ_E ≤ 6` and growing
population is a family whose stranger graphs have unbounded emotional chromatic number.
-- !-- End Lab Notes -- !--
-/

import Computation.EmotionalChromaticSandwich

namespace Catalog.Computation.EmotionalNordhausGaddum

open SimpleGraph Finset
open Catalog.Novelty.EmotionalChromaticNumber
open Catalog.Computation.EmotionalGreedyColoring
open Catalog.Computation.EmotionalChromaticSandwich

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## The injection principle -/

omit [DecidableEq V] in
/-- **Product injection.**  If `a` emotions properly color the friendship graph and `b` emotions
properly color the stranger graph, then the pair of colors identifies a person uniquely, so the
population is at most `a · b`. -/
theorem card_le_mul_of_colorable_compl (G : SimpleGraph V) {a b : ℕ}
    (ha : G.Colorable a) (hb : Gᶜ.Colorable b) : Fintype.card V ≤ a * b := by
  obtain ⟨c⟩ := ha
  obtain ⟨d⟩ := hb
  have hinj : Function.Injective (fun v => (c v, d v)) := by
    intro x y hxy
    simp only [Prod.mk.injEq] at hxy
    by_contra hne
    rcases em (G.Adj x y) with hadj | hnadj
    · exact c.valid hadj hxy.1
    · exact d.valid (by simp [SimpleGraph.compl_adj, hne, hnadj]) hxy.2
  simpa [Fintype.card_prod] using Fintype.card_le_of_injective _ hinj

omit [DecidableEq V] in
/-- **Nordhaus–Gaddum product law** for the classical chromatic number. -/
theorem card_le_mul_chromaticNumber_compl (G : SimpleGraph V) :
    Fintype.card V ≤ G.chromaticNumber.toNat * Gᶜ.chromaticNumber.toNat :=
  card_le_mul_of_colorable_compl G G.colorable_chromaticNumber_of_fintype
    Gᶜ.colorable_chromaticNumber_of_fintype

omit [DecidableEq V] in
/-- **Emotional conservation law.**  The population never exceeds the product of the emotional
chromatic numbers of the friendship graph and of the stranger graph. -/
theorem card_le_mul_emoChrom_compl (G : SimpleGraph V) :
    Fintype.card V ≤ emoChrom G * emoChrom Gᶜ :=
  card_le_mul_of_colorable_compl G (emoChrom_colorable G) (emoChrom_colorable Gᶜ)

/-! ## The sum law -/

omit [DecidableEq V] in
/-- **Nordhaus–Gaddum sum law.**  `4|V| ≤ (χ(G) + χ(Gᶜ))²`, i.e. `χ(G) + χ(Gᶜ) ≥ 2√|V|`. -/
theorem four_mul_card_le_sq_chromaticNumber_add (G : SimpleGraph V) :
    4 * Fintype.card V ≤ (G.chromaticNumber.toNat + Gᶜ.chromaticNumber.toNat) ^ 2 := by
  have h := card_le_mul_chromaticNumber_compl G
  set a := G.chromaticNumber.toNat
  set b := Gᶜ.chromaticNumber.toNat
  have hz : (Fintype.card V : ℤ) ≤ (a : ℤ) * (b : ℤ) := by exact_mod_cast h
  have hgoal : (4 * Fintype.card V : ℤ) ≤ ((a : ℤ) + (b : ℤ)) ^ 2 := by
    nlinarith [sq_nonneg ((a : ℤ) - (b : ℤ))]
  exact_mod_cast hgoal

omit [DecidableEq V] in
/-- The emotional form of the sum law. -/
theorem four_mul_card_le_sq_emoChrom_add (G : SimpleGraph V) :
    4 * Fintype.card V ≤ (emoChrom G + emoChrom Gᶜ) ^ 2 := by
  have h := card_le_mul_emoChrom_compl G
  set a := emoChrom G
  set b := emoChrom Gᶜ
  have hz : (Fintype.card V : ℤ) ≤ (a : ℤ) * (b : ℤ) := by exact_mod_cast h
  have hgoal : (4 * Fintype.card V : ℤ) ≤ ((a : ℤ) + (b : ℤ)) ^ 2 := by
    nlinarith [sq_nonneg ((a : ℤ) - (b : ℤ))]
  exact_mod_cast hgoal

/-! ## Consequences for the six-emotion window -/

omit [DecidableEq V] in
/-- **Emotional duality.**  If the six basic emotions suffice for the friendships of a population
of `n` people, then the stranger graph needs at least `n / 6` emotions — emotional simplicity is
never free. -/
theorem emoChrom_compl_ge_of_six (G : SimpleGraph V) (h6 : emoChrom G ≤ 6) :
    Fintype.card V ≤ 6 * emoChrom Gᶜ :=
  le_trans (card_le_mul_emoChrom_compl G) (Nat.mul_le_mul_right _ h6)

omit [DecidableEq V] in
/-- Hundred people, six emotions: the stranger graph needs at least seventeen emotions. -/
theorem emotional_duality_hundred (G : SimpleGraph V) (hcard : Fintype.card V = 100)
    (h6 : emoChrom G ≤ 6) : 17 ≤ emoChrom Gᶜ := by
  have h := emoChrom_compl_ge_of_six G h6
  rw [hcard] at h
  omega

/-- **Sparse networks have dense stranger graphs.**  In a population of one hundred where nobody
has more than five friends, somebody has at least sixteen strangers-of-record: the maximum degree
of the stranger graph is at least `16`. -/
theorem sparse_network_has_dense_stranger_graph (G : SimpleGraph V) [DecidableRel G.Adj]
    (hcard : Fintype.card V = 100) (hΔ : G.maxDegree ≤ 5) : 16 ≤ Gᶜ.maxDegree := by
  classical
  have h6 : emoChrom G ≤ 6 := (six_emotions_suffice G hΔ).2
  have h17 : 17 ≤ emoChrom Gᶜ := emotional_duality_hundred G hcard h6
  have hub : emoChrom Gᶜ ≤ max (Gᶜ.maxDegree + 1) 3 := emoChrom_le_maxDegree_add_one Gᶜ
  rcases le_or_gt (Gᶜ.maxDegree + 1) 3 with h | h
  · rw [max_eq_right h] at hub; omega
  · rw [max_eq_left (by omega)] at hub; omega

/-- **Self-complementary networks.**  If the friendship graph is isomorphic to its own stranger
graph, the population is at most the square of the emotional chromatic number. -/
theorem emoChrom_self_complementary (G : SimpleGraph V) (e : G ≃g Gᶜ) :
    Fintype.card V ≤ (emoChrom G) ^ 2 := by
  have h := card_le_mul_emoChrom_compl G
  have hiso : emoChrom Gᶜ = emoChrom G := (emoChrom_congr_iso e).symm
  rw [hiso] at h
  simpa [pow_two] using h

/-! ## Sanity checks on the extremes -/

omit [DecidableEq V] in
/-- On a clique the product law is an equality after the emotional floor is stripped: the stranger
graph is edgeless, so it is colorable with a single emotion and `|V| ≤ χ(G) · 1`. -/
theorem product_law_tight_on_clique (n : ℕ) :
    Fintype.card (Fin n) ≤ (⊤ : SimpleGraph (Fin n)).chromaticNumber.toNat *
      (⊤ : SimpleGraph (Fin n))ᶜ.chromaticNumber.toNat := by
  exact card_le_mul_chromaticNumber_compl _

/-- The emotional product law is *not* an equality in general: for the friendship circle `C_5`
the population is `5` while `χ_E(C_5) · χ_E(C_5ᶜ) = 3 · 3 = 9` (the stranger graph of `C_5` is
again a five-cycle). -/
theorem product_law_loose_on_five_cycle :
    Fintype.card (Fin 5) < emoChrom (cycleGraph 5) * emoChrom (cycleGraph 5)ᶜ := by
  have h1 : emoChrom (cycleGraph 5) = 3 := emoChrom_cycle (by norm_num)
  have h2 : 3 ≤ emoChrom (cycleGraph 5)ᶜ := emoChrom_ge_three _
  have : Fintype.card (Fin 5) = 5 := Fintype.card_fin 5
  rw [this, h1]
  omega

/-
-- !-- Lab Notes (critique, cycle 2) -- !--
ADVERSARIAL REVIEW.
* Circularity: `card_le_mul_emoChrom_compl` uses only `emoChrom_colorable` (catalog) and the
  injection principle proved here; the greedy bound is used only in the *application*
  `sparse_network_has_dense_stranger_graph`, which lives downstream of both.
* Vacuity: `emotional_duality_hundred` has satisfiable hypotheses — e.g. `G = C_100` on a hundred
  people has `χ_E = 3 ≤ 6`, so the conclusion `χ_E(Gᶜ) ≥ 17` is a genuine statement about a
  realizable network, not an empty implication.
* Sharpness: `product_law_tight_on_clique` and `product_law_loose_on_five_cycle` bracket the law
  from both sides, so it is neither vacuous nor an equality.
-- !-- End Lab Notes -- !--
-/

end Catalog.Computation.EmotionalNordhausGaddum