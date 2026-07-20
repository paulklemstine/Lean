import Mathlib

/-!
# List choosability

A graph is `k`-choosable when every assignment of at least `k` permitted natural-number
colours to each vertex admits a proper colouring selected from those lists.
-/

open SimpleGraph Finset

namespace ListChoosability

/-- List choosability for finite graphs, using natural numbers as a common colour universe. -/
def Choosable {V : Type*} (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∀ L : V → Finset ℕ, (∀ v, k ≤ (L v).card) →
    ∃ c : V → ℕ, (∀ v, c v ∈ L v) ∧ ∀ u v, G.Adj u v → c u ≠ c v

end ListChoosability