import Novelty.Cyclic

/-!
# Contrarian tests for stable Kneser colourings

This file tests two bold extensions around Meunier's formula.  At the tight
boundary `n = s*k`, the concrete case `s = k = 3` already has the predicted
three colours: three cyclically stable triples form a clique, while the
canonical construction gives a three-colouring.  On the negative side, the
canonical colouring need not remain proper if its numerical packing threshold
is dropped.
-/

namespace StableKneser

/-- Properness for a colouring of every cyclically stable `k`-set in `[0,n)`.
The codomain `Fin q` records that exactly `q` colours are available. -/
def ProperCyclicColoring (n s k q : ℕ) (c : Finset ℕ → Fin q) : Prop :=
  ∀ A B : Finset ℕ,
    A.card = k → B.card = k →
    CyclicStable n s A → CyclicStable n s B →
    Disjoint A B → c A ≠ c B

private def R0 : Finset ℕ := {0, 3, 6}
private def R1 : Finset ℕ := {1, 4, 7}
private def R2 : Finset ℕ := {2, 5, 8}

lemma residue_triples_data :
    R0.card = 3 ∧ R1.card = 3 ∧ R2.card = 3 ∧
    CyclicStable 9 3 R0 ∧ CyclicStable 9 3 R1 ∧ CyclicStable 9 3 R2 ∧
    Disjoint R0 R1 ∧ Disjoint R0 R2 ∧ Disjoint R1 R2 := by
  simp +decide [ R0, R1, R2, CyclicStable ];
  grind

/-
The three residue-class triples force at least three colours at `n=s=k=3`.
-/
theorem no_two_coloring_3stable_9_3 :
    ¬ ∃ c : Finset ℕ → Fin 2, ProperCyclicColoring 9 3 3 2 c := by
  by_contra! h;
  obtain ⟨ c, hc ⟩ := h
  have hR0 : CyclicStable 9 3 R0 := (residue_triples_data).right.right.right.left
  have hR1 : CyclicStable 9 3 R1 := (residue_triples_data).right.right.right.right.left
  have hR2 : CyclicStable 9 3 R2 := (residue_triples_data).right.right.right.right.right.left;
  have hR0R1 : c R0 ≠ c R1 := by
    exact hc R0 R1 ( by decide ) ( by decide ) hR0 hR1 ( by decide )
  have hR0R2 : c R0 ≠ c R2 := by
    exact hc _ _ ( by decide ) ( by decide ) hR0 hR2 ( by decide )
  have hR1R2 : c R1 ≠ c R2 := by
    exact hc R1 R2 ( by decide ) ( by decide ) hR1 hR2 ( by decide );
  grind

/-
The canonical construction supplies three colours at `n=s*k=9`.
-/
theorem exists_three_coloring_3stable_9_3 :
    ∃ c : Finset ℕ → Fin 3, ProperCyclicColoring 9 3 3 3 c := by
  refine' ⟨ _, _ ⟩;
  exact fun A => if h : A.Nonempty then Fin.mk ( canonicalColor 3 A h ) ( by have := canonicalColor_lt 3 ( by omega ) A h; exact this ) else 0;
  intro A B hA hB hA' hB' hAB; have := cyclicStable_canonicalColor_proper 9 3 3 3 ( by decide ) ( by decide ) ( by decide ) ( by decide ) A B; aesop;

/-- Exact boundary result: the cyclic 3-stable Kneser graph on triples of
`[9]` needs three colours (expressed without depending on a graph-chromatic API). -/
theorem exact_three_colors_3stable_9_3 :
    (∃ c : Finset ℕ → Fin 3, ProperCyclicColoring 9 3 3 3 c) ∧
    (¬ ∃ c : Finset ℕ → Fin 2, ProperCyclicColoring 9 3 3 2 c) := by
  exact ⟨exists_three_coloring_3stable_9_3, no_two_coloring_3stable_9_3⟩

/-
A tempting strengthening is false: without the sharp relation
`n = r + s*(k-1)`, the capped-minimum colouring can assign the same colour to
disjoint stable sets.
-/
theorem canonicalColor_without_threshold_counterexample :
    let A : Finset ℕ := {1, 4}
    let B : Finset ℕ := {2, 5}
    A.card = 2 ∧ B.card = 2 ∧
    LinearStable 3 A ∧ LinearStable 3 B ∧
    (∀ x ∈ A, x < 7) ∧ (∀ x ∈ B, x < 7) ∧
    Disjoint A B ∧
    canonicalColor 2 A (by decide) = canonicalColor 2 B (by decide) := by
  simp +decide [LinearStable];
  grind

end StableKneser