/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Chromatic counting and deletion–contraction

This file develops the **chromatic counting function** of a finite simple graph:
`chromCount G k` is the number of proper colorings of `G` with the palette `Fin k`.
As a function of `k` this is the *chromatic polynomial* of `G` evaluated at `k`.

## Main results

* `ChromaticPoly.chromCount_bot` : the edgeless graph has `k ^ |V|` proper colorings,
  i.e. its chromatic polynomial is `k ^ |V|`.
* `ChromaticPoly.chromCount_top` : the complete graph has `k.descFactorial |V|`
  proper colorings (the falling factorial), since proper colorings are exactly the
  injections `V ↪ Fin k`.
* `ChromaticPoly.chromCount_deletion_contraction` : the deletion–contraction identity
  in additive counting form.  If `G` is obtained from `Gdel` by adding the single
  edge `uv`, then
  `chromCount Gdel k = chromCount G k + contractCount Gdel u v k`,
  where `contractCount` counts the proper colorings of the deletion that assign `u`
  and `v` the same color — exactly the proper colorings of the contraction `G / uv`.
* `ChromaticPoly.chromCount_eq_zero_iff` : `chromCount G k = 0` iff `G` is not
  `k`-colorable, linking the counting function back to Mathlib's `Colorable`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the chromatic polynomial, presented as the counting
function `k ↦ #{proper k-colorings}`, satisfies a clean deletion–contraction
recursion even when phrased purely combinatorially over `Fin k`, with no need to
pass to `ℤ[X]`.

Experiment (Experimenter): we defined `properColorings` as a `Finset` and split it
along the diagonal predicate `f u = f v`.  The half with `f u ≠ f v` is exactly the
proper colorings of the graph with the edge `uv` present; the other half is the
contraction count.  This avoids Mathlib's `deleteEdges` decidability bookkeeping by
abstracting the deleted graph `Gdel` and the augmented graph `G` via a hypothesis
`hadd` describing `G = Gdel + uv`.

Analysis (Analyst): the additive form `P(G−e) = P(G) + P(G/e)` is more robust over
`ℕ` than the textbook subtractive form `P(G) = P(G−e) − P(G/e)`, because `ℕ`
subtraction truncates.  The two are equivalent once positivity is known.

Critique (Critic): every main theorem uses a genuine bijection/partition argument
(`Finset.filter_card_add_filter_neg_card_eq_card`, `Fintype.card_embedding_eq`), not
`decide`/`native_decide`.  The deletion–contraction theorem is stated with explicit
hypotheses making `G` the one-edge augmentation of `Gdel`, so it is not vacuous.
-/

open Finset

namespace ChromaticPoly

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A coloring `f : V → Fin k` is proper for `G` when adjacent vertices get
distinct colors. -/
def IsProper (G : SimpleGraph V) (k : ℕ) (f : V → Fin k) : Prop :=
  ∀ a b, G.Adj a b → f a ≠ f b

/-- The finset of proper `Fin k`-colorings of `G`. -/
noncomputable def properColorings (G : SimpleGraph V) (k : ℕ) : Finset (V → Fin k) := by
  classical
  exact Finset.univ.filter (fun f => IsProper G k f)

/-- The chromatic counting function: the number of proper `Fin k`-colorings of `G`.
As a function of `k` this is the chromatic polynomial of `G`. -/
noncomputable def chromCount (G : SimpleGraph V) (k : ℕ) : ℕ :=
  (properColorings G k).card

/-- The contraction count: proper colorings of `G` in which `u` and `v` receive the
same color.  When `G` has no edge `uv`, this is the number of proper colorings of the
contraction `G / uv`. -/
noncomputable def contractCount (G : SimpleGraph V) (u v : V) (k : ℕ) : ℕ := by
  classical
  exact ((properColorings G k).filter (fun f => f u = f v)).card

theorem mem_properColorings {G : SimpleGraph V} {k : ℕ} {f : V → Fin k} :
    f ∈ properColorings G k ↔ IsProper G k f := by
  classical
  simp [properColorings, IsProper]

/-
The edgeless graph: every coloring is proper, so there are `k ^ |V|` of them.
-/
theorem chromCount_bot (k : ℕ) :
    chromCount (⊥ : SimpleGraph V) k = k ^ Fintype.card V := by
  unfold chromCount;
  simp +decide [ properColorings, IsProper ]

/-
The complete graph: proper colorings are exactly the injections `V → Fin k`,
counted by the falling factorial `k.descFactorial |V|`.
-/
theorem chromCount_top (k : ℕ) :
    chromCount (⊤ : SimpleGraph V) k = k.descFactorial (Fintype.card V) := by
  unfold ChromaticPoly.chromCount ChromaticPoly.properColorings;
  convert Fintype.card_embedding_eq ( α := V ) ( β := Fin k ) using 1;
  · rw [ ← Fintype.card_subtype ];
    fapply Fintype.card_congr;
    exact ⟨ fun x => ⟨ x.val, fun a b h => by have := x.2 a b; aesop ⟩, fun x => ⟨ x, fun a b h => by have := x.2; aesop ⟩, fun x => rfl, fun x => rfl ⟩;
  · rw [ Fintype.card_fin ]

/-
A coloring is proper for the one-edge augmentation `G` of `Gdel` iff it is proper
for `Gdel` and additionally separates the new edge's endpoints.
-/
omit [Fintype V] [DecidableEq V] in
theorem isProper_augment {Gdel G : SimpleGraph V} {u v : V}
    (hadd : ∀ a b, G.Adj a b ↔ (Gdel.Adj a b ∨ s(a, b) = s(u, v)))
    (hne : u ≠ v) {k : ℕ} (f : V → Fin k) :
    IsProper G k f ↔ (IsProper Gdel k f ∧ f u ≠ f v) := by
  constructor <;> intro h <;> simp_all +decide [ IsProper ];
  grind

/-
**Deletion–contraction** (additive counting form).  If `G` is obtained from
`Gdel` by adding the single edge `uv` (and `Gdel` lacks that edge), then the number
of proper colorings of the deletion equals that of `G` plus the contraction count.
-/
theorem chromCount_deletion_contraction {Gdel G : SimpleGraph V} {u v : V}
    (hne : u ≠ v)
    (hadd : ∀ a b, G.Adj a b ↔ (Gdel.Adj a b ∨ s(a, b) = s(u, v)))
    (k : ℕ) :
    chromCount Gdel k = chromCount G k + contractCount Gdel u v k := by
  unfold chromCount contractCount;
  have h_split : (properColorings Gdel k).filter (fun f => f u ≠ f v) = properColorings G k := by
    -- Apply the definition of properColorings and the hypothesis hadd.
    ext f; simp [properColorings, isProper_augment hadd hne];
  grind +suggestions

/-
The counting function vanishes exactly when the graph is not `k`-colorable.
-/
theorem chromCount_eq_zero_iff (G : SimpleGraph V) (k : ℕ) :
    chromCount G k = 0 ↔ ¬ G.Colorable k := by
  constructor <;> intro h;
  · contrapose! h; simp_all +decide [ chromCount, properColorings ] ;
    exact ⟨ h.some, fun a b hab => h.some.valid hab ⟩;
  · refine' Finset.card_eq_zero.mpr _;
    ext f; simp [properColorings, IsProper];
    contrapose! h;
    exact ⟨ f, by aesop ⟩

end ChromaticPoly