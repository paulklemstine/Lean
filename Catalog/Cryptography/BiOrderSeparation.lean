import Mathlib

/-!
# Bounded right traces of binary words

This module supplies the finite-word separation facts used by the universal
poset and coherent-composition developments.  A word is a finite binary list.
Its bounded right trace consists of its extensions whose total length is at
most the bound.  Two words that themselves lie under the bound are determined
by these traces.
-/

/-- Finite binary words. -/
abbrev Word := List Bool

/-- The bounded set of right extensions of a word. -/
def rightTraceWord (R : ℕ) (w : Word) : Set Word :=
  {z | z.length ≤ R ∧ ∃ t, z = w ++ t}

/-- Two lists that are prefixes of one another are equal. -/
theorem mutual_prefix_eq {α : Type*} {x y : List α}
    (hxy : ∃ t, x = y ++ t) (hyx : ∃ t, y = x ++ t) : x = y := by
  obtain ⟨t, ht⟩ := hxy
  obtain ⟨u, hu⟩ := hyx
  have hxyLen : y.length ≤ x.length := by
    rw [ht, List.length_append]
    omega
  have hyxLen : x.length ≤ y.length := by
    rw [hu, List.length_append]
    omega
  have hlen : x.length = y.length := Nat.le_antisymm hyxLen hxyLen
  have htLen : t.length = 0 := by
    have := congrArg List.length ht
    simp only [List.length_append] at this
    omega
  have htNil : t = [] := by
    cases t with
    | nil => rfl
    | cons a t => simp at htLen
  simpa [htNil] using ht

/-- Within the bound, equality of bounded right traces forces equality of words. -/
theorem rightTrace_eq_imp_eq {R : ℕ} {x y : Word}
    (hx : x.length ≤ R) (hy : y.length ≤ R)
    (htrace : rightTraceWord R x = rightTraceWord R y) : x = y := by
  have hxx : x ∈ rightTraceWord R x := ⟨hx, [], by simp⟩
  have hyy : y ∈ rightTraceWord R y := ⟨hy, [], by simp⟩
  rw [htrace] at hxx
  rw [← htrace] at hyy
  exact mutual_prefix_eq hxx.2 hyy.2