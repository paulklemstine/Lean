/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Pythagorean.GraphTheory.CliqueSum

/-!
# Sharpness and boundaries for clique-sum bounds

This file contains the *adversarial* half of the clique-sum development in
`CliqueSum.lean`. Three explicit finite witnesses delimit exactly how far the
positive results can be pushed.

## Witness A (`WA`), a clique sum along a `2`-clique

`V = Fin 4`, `s = {0,1,2}`, `t = {0,1,3}`, `K = {0,1}`,
`G₁` = path `2 — 1 — 0`, `G₂` = path `1 — 0 — 3`, `G = G₁ ⊔ G₂` = path `2—1—0—3`.

Here `α₁ = α₂ = 2` but `α(G) = 2`, so

* `alpha_sub_one_fails` : the naive bound `α(G) ≥ α₁ + α₂ - 1` is **false** already
  for `k = |K| = 2`; the mistake is that two maximum independent sets, one on each
  side, need not glue to an independent set even though they overlap in ≤ 1 vertex.
* `alpha_sub_two_sharp` : the bound `α(G) ≥ α₁ + α₂ - 2` proved in
  `IsCliqueSum.indepNumOn_add_le_add_two` is **attained**, hence sharp.

## Witness B (`WB`), a *weak* clique sum with `n < k`

`V = Fin 3`, `s = t = K = {0,1,2}`, `G₁` = the single edge `0—1`,
`G₂` = the path `0—2—1`, `G = G₁ ⊔ G₂ = ⊤` = the triangle.

`K` is a `3`-clique of `G`, but its edges are *split* between the two sides, so `K`
is a clique on neither side, and each side is `2`-colourable: `n = 2 < 3 = k`.

* `chromaticNumber_max_fails_of_weak` : `χ(G) = 3 > 2 = max (χ G₁) (χ G₂)`.
* `alpha_sub_two_fails_of_weak` : even `α(G) ≥ α₁ + α₂ - 2` fails for weak clique sums.

Thus the hypothesis "`K` is a clique on each side", equivalently (by
`IsCliqueSum.card_le_of_colorable`) the numerical hypothesis `n ≥ k`, is not
removable from either theorem.
-/

namespace Catalog.Pythagorean.CliqueSum

open Finset SimpleGraph

/-! ## Witness A: a clique sum along a 2-clique -/

namespace WA

/-- Edge relation of the left side: `0—1` and `1—2`. -/
def r₁ : Fin 4 → Fin 4 → Prop := fun a b => (a, b) = ((0 : Fin 4), (1 : Fin 4)) ∨
  (a, b) = ((1 : Fin 4), (2 : Fin 4))

/-- Edge relation of the right side: `0—1` and `0—3`. -/
def r₂ : Fin 4 → Fin 4 → Prop := fun a b => (a, b) = ((0 : Fin 4), (1 : Fin 4)) ∨
  (a, b) = ((0 : Fin 4), (3 : Fin 4))

instance : DecidableRel r₁ := fun a b => by unfold r₁; infer_instance
instance : DecidableRel r₂ := fun a b => by unfold r₂; infer_instance

/-- Left side of the clique sum: the path `2 — 1 — 0`. -/
def G₁ : SimpleGraph (Fin 4) := SimpleGraph.fromRel r₁

/-- Right side of the clique sum: the path `1 — 0 — 3`. -/
def G₂ : SimpleGraph (Fin 4) := SimpleGraph.fromRel r₂

/-- The clique sum: the path `2 — 1 — 0 — 3`. -/
def G : SimpleGraph (Fin 4) := G₁ ⊔ G₂

instance : DecidableRel G₁.Adj := fun a b =>
  decidable_of_iff (a ≠ b ∧ (r₁ a b ∨ r₁ b a)) (SimpleGraph.fromRel_adj ..).symm

instance : DecidableRel G₂.Adj := fun a b =>
  decidable_of_iff (a ≠ b ∧ (r₂ a b ∨ r₂ b a)) (SimpleGraph.fromRel_adj ..).symm

instance : DecidableRel G.Adj := fun a b =>
  decidable_of_iff (G₁.Adj a b ∨ G₂.Adj a b) Iff.rfl

/-- Left vertex set. -/
def s : Finset (Fin 4) := {0, 1, 2}
/-- Right vertex set. -/
def t : Finset (Fin 4) := {0, 1, 3}
/-- The glueing clique. -/
def K : Finset (Fin 4) := {0, 1}

theorem card_K : K.card = 2 := by decide

theorem isCliqueSum : IsCliqueSum G G₁ G₂ s t K where
  sup_eq := rfl
  union_eq := by decide
  inter_eq := by decide
  mem_left := by
    intro a b hab
    exact (by decide : ∀ a b : Fin 4, G₁.Adj a b → a ∈ s ∧ b ∈ s) a b hab
  mem_right := by
    intro a b hab
    exact (by decide : ∀ a b : Fin 4, G₂.Adj a b → a ∈ t ∧ b ∈ t) a b hab
  isClique_left := by
    intro a ha b hb hab
    exact (by decide : ∀ a ∈ K, ∀ b ∈ K, a ≠ b → G₁.Adj a b) a (by simpa using ha) b
      (by simpa using hb) hab
  isClique_right := by
    intro a ha b hb hab
    exact (by decide : ∀ a ∈ K, ∀ b ∈ K, a ≠ b → G₂.Adj a b) a (by simpa using ha) b
      (by simpa using hb) hab

theorem indepNumOn_left : indepNumOn G₁ s = 2 := by
  refine le_antisymm (indepNumOn_le ?_) ?_
  · exact (by decide : ∀ A : Finset (Fin 4), A ⊆ s → IsIndepFinset G₁ A → A.card ≤ 2)
  · have h : ({0, 2} : Finset (Fin 4)).card = 2 := by decide
    have := card_le_indepNumOn (G := G₁) (s := s) (A := {0, 2}) (by decide) (by decide)
    omega

theorem indepNumOn_right : indepNumOn G₂ t = 2 := by
  refine le_antisymm (indepNumOn_le ?_) ?_
  · exact (by decide : ∀ A : Finset (Fin 4), A ⊆ t → IsIndepFinset G₂ A → A.card ≤ 2)
  · have h : ({1, 3} : Finset (Fin 4)).card = 2 := by decide
    have := card_le_indepNumOn (G := G₂) (s := t) (A := {1, 3}) (by decide) (by decide)
    omega

theorem indepNumOn_total : indepNumOn G Finset.univ = 2 := by
  refine le_antisymm (indepNumOn_le ?_) ?_
  · exact (by decide : ∀ A : Finset (Fin 4), A ⊆ Finset.univ → IsIndepFinset G A → A.card ≤ 2)
  · have h : ({2, 3} : Finset (Fin 4)).card = 2 := by decide
    have := card_le_indepNumOn (G := G) (s := Finset.univ) (A := {2, 3}) (by decide) (by decide)
    omega

end WA

/-- **The bound `α(G) ≥ α₁ + α₂ - 1` fails for clique sums along a `2`-clique.**
Witness A has `α₁ = α₂ = α(G) = 2`, so `α₁ + α₂ = 4 > 3 = α(G) + 1`. -/
theorem alpha_sub_one_fails :
    ¬ ∀ (G G₁ G₂ : SimpleGraph (Fin 4)) (s t K : Finset (Fin 4)),
        IsCliqueSum G G₁ G₂ s t K →
        indepNumOn G₁ s + indepNumOn G₂ t ≤ indepNumOn G Finset.univ + 1 := by
  intro hcon
  have := hcon WA.G WA.G₁ WA.G₂ WA.s WA.t WA.K WA.isCliqueSum
  rw [WA.indepNumOn_left, WA.indepNumOn_right, WA.indepNumOn_total] at this
  omega

/-- **The bound `α(G) ≥ α₁ + α₂ - 2` is sharp**: Witness A attains it. -/
theorem alpha_sub_two_sharp :
    indepNumOn WA.G₁ WA.s + indepNumOn WA.G₂ WA.t = indepNumOn WA.G Finset.univ + 2 := by
  rw [WA.indepNumOn_left, WA.indepNumOn_right, WA.indepNumOn_total]

/-! ## Witness B: a weak clique sum whose clique is split between the sides (`n < k`) -/

namespace WB

/-- Edge relation of the left side: the single edge `0—1`. -/
def r₁ : Fin 3 → Fin 3 → Prop := fun a b => (a, b) = ((0 : Fin 3), (1 : Fin 3))

/-- Edge relation of the right side: the edges `0—2` and `1—2`. -/
def r₂ : Fin 3 → Fin 3 → Prop := fun a b => (a, b) = ((0 : Fin 3), (2 : Fin 3)) ∨
  (a, b) = ((1 : Fin 3), (2 : Fin 3))

instance : DecidableRel r₁ := fun a b => by unfold r₁; infer_instance
instance : DecidableRel r₂ := fun a b => by unfold r₂; infer_instance

/-- Left side: a single edge. -/
def G₁ : SimpleGraph (Fin 3) := SimpleGraph.fromRel r₁
/-- Right side: a path. -/
def G₂ : SimpleGraph (Fin 3) := SimpleGraph.fromRel r₂

instance : DecidableRel G₁.Adj := fun a b =>
  decidable_of_iff (a ≠ b ∧ (r₁ a b ∨ r₁ b a)) (SimpleGraph.fromRel_adj ..).symm

instance : DecidableRel G₂.Adj := fun a b =>
  decidable_of_iff (a ≠ b ∧ (r₂ a b ∨ r₂ b a)) (SimpleGraph.fromRel_adj ..).symm

/-- The glued graph is the triangle. -/
theorem sup_eq_top : (⊤ : SimpleGraph (Fin 3)) = G₁ ⊔ G₂ := by
  ext a b
  revert a b
  decide

theorem isWeakCliqueSum :
    IsWeakCliqueSum (⊤ : SimpleGraph (Fin 3)) G₁ G₂ Finset.univ Finset.univ Finset.univ where
  sup_eq := sup_eq_top
  union_eq := by decide
  inter_eq := by decide
  mem_left := by intro a b _; exact ⟨Finset.mem_univ a, Finset.mem_univ b⟩
  mem_right := by intro a b _; exact ⟨Finset.mem_univ a, Finset.mem_univ b⟩
  isClique := by intro a _ b _ hab; exact hab

theorem card_K : (Finset.univ : Finset (Fin 3)).card = 3 := by decide

/-- The left side is `2`-colourable. -/
theorem colorable_left : G₁.Colorable 2 := by
  refine ⟨SimpleGraph.Coloring.mk (fun v => if v = 1 then 1 else 0) ?_⟩
  intro a b hab
  exact (by decide : ∀ a b : Fin 3, G₁.Adj a b →
    (if a = 1 then (1 : Fin 2) else 0) ≠ (if b = 1 then 1 else 0)) a b hab

/-- The right side is `2`-colourable. -/
theorem colorable_right : G₂.Colorable 2 := by
  refine ⟨SimpleGraph.Coloring.mk (fun v => if v = 2 then 1 else 0) ?_⟩
  intro a b hab
  exact (by decide : ∀ a b : Fin 3, G₂.Adj a b →
    (if a = 2 then (1 : Fin 2) else 0) ≠ (if b = 2 then 1 else 0)) a b hab

theorem not_colorable_one_left : ¬ G₁.Colorable 1 := by
  rintro ⟨c⟩
  have hadj : G₁.Adj 0 1 := by decide
  exact c.valid hadj (Subsingleton.elim _ _)

theorem not_colorable_one_right : ¬ G₂.Colorable 1 := by
  rintro ⟨c⟩
  have hadj : G₂.Adj 0 2 := by decide
  exact c.valid hadj (Subsingleton.elim _ _)

theorem chromaticNumber_left : G₁.chromaticNumber = 2 := by
  rw [show ((2 : ℕ∞)) = ((1 : ℕ) : ℕ∞) + 1 by rfl,
    SimpleGraph.chromaticNumber_eq_iff_colorable_not_colorable]
  exact ⟨colorable_left, not_colorable_one_left⟩

theorem chromaticNumber_right : G₂.chromaticNumber = 2 := by
  rw [show ((2 : ℕ∞)) = ((1 : ℕ) : ℕ∞) + 1 by rfl,
    SimpleGraph.chromaticNumber_eq_iff_colorable_not_colorable]
  exact ⟨colorable_right, not_colorable_one_right⟩

theorem chromaticNumber_top : (⊤ : SimpleGraph (Fin 3)).chromaticNumber = 3 := by
  rw [SimpleGraph.chromaticNumber_top]
  simp

theorem indepNumOn_left : indepNumOn G₁ Finset.univ = 2 := by
  refine le_antisymm (indepNumOn_le ?_) ?_
  · exact (by decide : ∀ A : Finset (Fin 3), A ⊆ Finset.univ → IsIndepFinset G₁ A → A.card ≤ 2)
  · have h : ({0, 2} : Finset (Fin 3)).card = 2 := by decide
    have := card_le_indepNumOn (G := G₁) (s := Finset.univ) (A := {0, 2}) (by decide) (by decide)
    omega

theorem indepNumOn_right : indepNumOn G₂ Finset.univ = 2 := by
  refine le_antisymm (indepNumOn_le ?_) ?_
  · exact (by decide : ∀ A : Finset (Fin 3), A ⊆ Finset.univ → IsIndepFinset G₂ A → A.card ≤ 2)
  · have h : ({0, 1} : Finset (Fin 3)).card = 2 := by decide
    have := card_le_indepNumOn (G := G₂) (s := Finset.univ) (A := {0, 1}) (by decide) (by decide)
    omega

theorem indepNumOn_total : indepNumOn (⊤ : SimpleGraph (Fin 3)) Finset.univ = 1 := by
  refine le_antisymm (indepNumOn_le ?_) ?_
  · exact (by decide : ∀ A : Finset (Fin 3), A ⊆ Finset.univ →
      IsIndepFinset (⊤ : SimpleGraph (Fin 3)) A → A.card ≤ 1)
  · have h : ({0} : Finset (Fin 3)).card = 1 := by decide
    have := card_le_indepNumOn (G := (⊤ : SimpleGraph (Fin 3))) (s := Finset.univ) (A := {0})
      (by decide) (by decide)
    omega

end WB

/-- **`χ(G) = max (χ G₁) (χ G₂)` fails for weak clique sums.**
In Witness B the glueing set `K` is a `3`-clique of `G` whose edges are split between
the two sides, so each side only needs `n = 2 < 3 = k` colours, while `G` (a triangle)
needs `3`. -/
theorem chromaticNumber_max_fails_of_weak :
    ¬ ∀ (G G₁ G₂ : SimpleGraph (Fin 3)) (s t K : Finset (Fin 3)),
        IsWeakCliqueSum G G₁ G₂ s t K →
        G.chromaticNumber = max G₁.chromaticNumber G₂.chromaticNumber := by
  intro hcon
  have := hcon (⊤ : SimpleGraph (Fin 3)) WB.G₁ WB.G₂ Finset.univ Finset.univ Finset.univ
    WB.isWeakCliqueSum
  rw [WB.chromaticNumber_top, WB.chromaticNumber_left, WB.chromaticNumber_right] at this
  simp at this

/-- **Even the weaker bound `α(G) ≥ α₁ + α₂ - 2` fails for weak clique sums**:
Witness B has `α₁ = α₂ = 2` but `α(G) = 1`. -/
theorem alpha_sub_two_fails_of_weak :
    ¬ ∀ (G G₁ G₂ : SimpleGraph (Fin 3)) (s t K : Finset (Fin 3)),
        IsWeakCliqueSum G G₁ G₂ s t K →
        indepNumOn G₁ s + indepNumOn G₂ t ≤ indepNumOn G Finset.univ + 2 := by
  intro hcon
  have := hcon (⊤ : SimpleGraph (Fin 3)) WB.G₁ WB.G₂ Finset.univ Finset.univ Finset.univ
    WB.isWeakCliqueSum
  rw [WB.indepNumOn_left, WB.indepNumOn_right, WB.indepNumOn_total] at this
  omega

/-- The numerical boundary in Witness B: the glueing clique has `k = 3` vertices while
both sides are colourable with `n = 2 < k` colours. By `IsCliqueSum.card_le_of_colorable`
this can never happen for a genuine clique sum. -/
theorem weak_witness_colors_lt_clique_size :
    WB.G₁.Colorable 2 ∧ WB.G₂.Colorable 2 ∧ 2 < (Finset.univ : Finset (Fin 3)).card :=
  ⟨WB.colorable_left, WB.colorable_right, by decide⟩

/-! ## Witnesses C and D: the small-`k` regimes of the uniform bound are attained -/

section EdgelessWitnesses

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- An edgeless clique sum along `K = s ∩ t`. -/
theorem isCliqueSum_bot_of_card_le_one {s t K : Finset V} (hst : s ∪ t = Finset.univ)
    (hK : s ∩ t = K) (hcard : K.card ≤ 1) :
    IsCliqueSum (⊥ : SimpleGraph V) (⊥ : SimpleGraph V) (⊥ : SimpleGraph V) s t K where
  sup_eq := by simp
  union_eq := hst
  inter_eq := hK
  mem_left := by intro a b hab; exact absurd hab (by simp)
  mem_right := by intro a b hab; exact absurd hab (by simp)
  isClique_left := by
    intro a ha b hb hab
    exact absurd (Finset.card_le_one.1 hcard a (by simpa using ha) b (by simpa using hb)) hab
  isClique_right := by
    intro a ha b hb hab
    exact absurd (Finset.card_le_one.1 hcard a (by simpa using ha) b (by simpa using hb)) hab

theorem indepNumOn_bot (s : Finset V) : indepNumOn (⊥ : SimpleGraph V) s = s.card := by
  refine le_antisymm (indepNumOn_le fun A hA _ => Finset.card_le_card hA) ?_
  exact card_le_indepNumOn (Finset.Subset.refl s) (by intro a _ b _; simp)

end EdgelessWitnesses

/-- **Witness C**: for `k = 1` the bound `α₁ + α₂ ≤ α(G) + 1` is attained
(`2 + 2 = 3 + 1`), so `IsCliqueSum.indepNumOn_add_le_add_one` is sharp. -/
theorem alpha_sub_one_sharp_of_card_one :
    ∃ (s t K : Finset (Fin 3)),
      IsCliqueSum (⊥ : SimpleGraph (Fin 3)) ⊥ ⊥ s t K ∧ K.card = 1 ∧
      indepNumOn (⊥ : SimpleGraph (Fin 3)) s + indepNumOn (⊥ : SimpleGraph (Fin 3)) t =
        indepNumOn (⊥ : SimpleGraph (Fin 3)) Finset.univ + 1 := by
  refine ⟨{0, 1}, {0, 2}, {0}, isCliqueSum_bot_of_card_le_one (by decide) (by decide) (by decide),
    by decide, ?_⟩
  rw [indepNumOn_bot, indepNumOn_bot, indepNumOn_bot]
  decide

/-- **Witness D**: for `k = 0` (a disjoint union) the independence numbers add exactly,
so `IsCliqueSum.indepNumOn_add_le_of_card_eq_zero` is sharp. -/
theorem alpha_add_exact_of_card_zero :
    ∃ (s t K : Finset (Fin 2)),
      IsCliqueSum (⊥ : SimpleGraph (Fin 2)) ⊥ ⊥ s t K ∧ K.card = 0 ∧
      indepNumOn (⊥ : SimpleGraph (Fin 2)) s + indepNumOn (⊥ : SimpleGraph (Fin 2)) t =
        indepNumOn (⊥ : SimpleGraph (Fin 2)) Finset.univ := by
  refine ⟨{0}, {1}, ∅, isCliqueSum_bot_of_card_le_one (by decide) (by decide) (by decide),
    by decide, ?_⟩
  rw [indepNumOn_bot, indepNumOn_bot, indepNumOn_bot]
  decide

end Catalog.Pythagorean.CliqueSum