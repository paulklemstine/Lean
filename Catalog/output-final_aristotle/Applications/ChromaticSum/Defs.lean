/-
# Chromatic Sum of a finite simple graph — core definitions

This file develops, from scratch, the basic theory of the **chromatic sum**
(a.k.a. *minimum colour sum* / *vertex colouring sum*) `Σ(G)` of a finite simple
graph `G`.

The chromatic sum is the minimum, over all proper colourings `c : V → ℕ` using
positive integer colours, of `∑_v c(v)`.  Unlike the ordinary chromatic number
`χ(G)`, which only cares about the *number* of colours, the chromatic sum is
sensitive to how many vertices receive each colour, and its optimal colourings
can behave counter‑intuitively.

## Motivation

The research mission concerns the conjectured *complexity dichotomy* for the
Chromatic Sum problem on `H`-free graphs (polynomial when `H` is a forest,
NP‑complete when `H` contains a cycle).  Complexity‑theoretic statements are
outside what we formalise here; instead we build the combinatorial substrate:
a rigorous definition of `Σ(G)` and its fundamental structural properties,
on top of which the companion file `Dichotomy.lean` proves and *disproves*
several bold quantitative conjectures about `Σ`.

## Main definitions

* `ChromaticSum.IsProperColoring G c` — `c` is a proper colouring with positive
  colours.
* `ChromaticSum.colorSum c` — `∑_v c v`.
* `ChromaticSum.chromaticSum G` — the chromatic sum `Σ(G)`, defined as an `sInf`.

## Main results

* `ChromaticSum.exists_isProperColoring` — a proper colouring always exists
  (colour all vertices distinctly), so the defining set is non‑empty.
* `ChromaticSum.chromaticSum_mem` — the infimum is attained by an actual
  colouring.
* `ChromaticSum.chromaticSum_le_colorSum` / `ChromaticSum.le_chromaticSum` —
  the universal property of `Σ(G)` as a minimum.
* `ChromaticSum.card_le_chromaticSum` — `|V| ≤ Σ(G)`.
* `ChromaticSum.chromaticSum_bot` — `Σ(⊥) = |V|` (the edgeless graph).
* `ChromaticSum.chromaticSum_mono` — `Σ` is monotone under taking subgraphs
  (more edges ⇒ larger chromatic sum).
-/

import Mathlib

open Finset

namespace ChromaticSum

variable {V : Type*} [Fintype V] {G H : SimpleGraph V}

/-- A **proper colouring** of `G` with positive integer colours: every colour is
`≥ 1` and adjacent vertices receive different colours. -/
def IsProperColoring (G : SimpleGraph V) (c : V → ℕ) : Prop :=
  (∀ v, 1 ≤ c v) ∧ ∀ ⦃u v⦄, G.Adj u v → c u ≠ c v

/-- The colour sum `∑_v c v` of a colouring `c`. -/
def colorSum (c : V → ℕ) : ℕ := ∑ v, c v

/-- The set of achievable colour sums of proper colourings of `G`. -/
def ChromaticSumSet (G : SimpleGraph V) : Set ℕ :=
  {s | ∃ c, IsProperColoring G c ∧ colorSum c = s}

/-- The **chromatic sum** `Σ(G)`: the least colour sum of a proper colouring. -/
noncomputable def chromaticSum (G : SimpleGraph V) : ℕ := sInf (ChromaticSumSet G)

/-- Colouring every vertex with a distinct positive colour is proper for any graph. -/
theorem exists_isProperColoring (G : SimpleGraph V) : ∃ c, IsProperColoring G c := by
  classical
  refine ⟨fun v => (Fintype.equivFin V v : ℕ) + 1, ?_, ?_⟩
  · intro v; dsimp only; omega
  · intro u v huv h
    apply G.ne_of_adj huv
    dsimp only at h
    have h' : (Fintype.equivFin V u : ℕ) = (Fintype.equivFin V v : ℕ) := by omega
    exact (Fintype.equivFin V).injective (Fin.ext h')

/-- The set of achievable colour sums is non‑empty. -/
theorem chromaticSumSet_nonempty (G : SimpleGraph V) : (ChromaticSumSet G).Nonempty := by
  obtain ⟨c, hc⟩ := exists_isProperColoring G
  exact ⟨colorSum c, c, hc, rfl⟩

/-- The chromatic sum is attained by an actual proper colouring. -/
theorem chromaticSum_mem (G : SimpleGraph V) : chromaticSum G ∈ ChromaticSumSet G :=
  Nat.sInf_mem (chromaticSumSet_nonempty G)

/-- `Σ(G)` is a lower bound: any proper colouring has colour sum `≥ Σ(G)`. -/
theorem chromaticSum_le_colorSum {c : V → ℕ} (hc : IsProperColoring G c) :
    chromaticSum G ≤ colorSum c :=
  Nat.sInf_le ⟨c, hc, rfl⟩

/-- Universal lower bound property: if `k` bounds every proper colour sum from
below, then `k ≤ Σ(G)`. -/
theorem le_chromaticSum {k : ℕ}
    (h : ∀ c, IsProperColoring G c → k ≤ colorSum c) : k ≤ chromaticSum G := by
  obtain ⟨c, hc, hcs⟩ := chromaticSum_mem G
  rw [← hcs]; exact h c hc

/-- Every colouring with positive colours has colour sum at least `|V|`. -/
theorem card_le_colorSum {c : V → ℕ} (h : ∀ v, 1 ≤ c v) :
    Fintype.card V ≤ colorSum c := by
  unfold colorSum
  calc Fintype.card V = ∑ _v : V, 1 := by simp [Finset.card_univ]
    _ ≤ ∑ v, c v := Finset.sum_le_sum (fun v _ => h v)

/-- `|V| ≤ Σ(G)`: each of the `|V|` vertices contributes at least the colour `1`. -/
theorem card_le_chromaticSum (G : SimpleGraph V) : Fintype.card V ≤ chromaticSum G := by
  apply le_chromaticSum
  intro c hc
  exact card_le_colorSum hc.1

/-- The all‑ones colouring is proper for the edgeless graph. -/
theorem chromaticSum_bot : chromaticSum (⊥ : SimpleGraph V) = Fintype.card V := by
  apply le_antisymm
  · have hproper : IsProperColoring (⊥ : SimpleGraph V) (fun _ => 1) := by
      refine ⟨fun _ => le_refl 1, ?_⟩
      intro u v h; exact absurd h (by simp)
    calc chromaticSum (⊥ : SimpleGraph V) ≤ colorSum (fun _ => 1) :=
          chromaticSum_le_colorSum hproper
      _ = Fintype.card V := by simp [colorSum, Finset.card_univ]
  · exact card_le_chromaticSum _

/-- **Monotonicity.** A subgraph has chromatic sum no larger than the whole graph:
adding edges can only increase the chromatic sum. -/
theorem chromaticSum_mono (h : H ≤ G) : chromaticSum H ≤ chromaticSum G := by
  apply le_chromaticSum
  intro c hc
  apply chromaticSum_le_colorSum
  refine ⟨hc.1, ?_⟩
  intro u v huv
  exact hc.2 (h huv)

end ChromaticSum