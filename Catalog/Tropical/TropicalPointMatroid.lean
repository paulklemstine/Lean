import Mathlib
import Tropical.TropicalCircuits
import Tropical.TropicalPointIdeal

/-!
# The matroid of the tropical ideal of a point is uniform in every degree

Combining
`Catalog/Tropical/TropicalPointIdeal.lean` (each finite-monomial truncation of
the vanishing set of a point is a tropical hyperplane) with
`Catalog/Tropical/TropicalCircuits.lean` (the circuits of a tropical hyperplane
with finite coefficients are exactly the pairs), we obtain the degreewise
matroid of the tropical ideal of a point: for every finite set `E` of at least
two monomials, the circuits of the truncated tropical ideal are exactly the
two-element sets of monomials, i.e. the underlying matroid is the uniform matroid
`U_{|E|-1,|E|}`.
-/

open MvPolynomial TropicalElimination

noncomputable section

namespace TropicalPointIdeal

variable {σ : Type*} (w : σ → ℚ) (E : Finset (σ →₀ ℕ))

/-- The truncation of the vanishing set of the point `w` to the monomial set `E`,
as a set of coefficient vectors. -/
def truncation : Set ({u // u ∈ E} → TropicalElimination.TT) :=
  {x | ∃ f : MvPolynomial σ TropCoeff, VanishesAt w f ∧ f.support ⊆ E ∧ coeffVec E f = x}

theorem pointVec_ne_top (u : {u // u ∈ E}) : pointVec w E u ≠ ⊤ := by
  rw [pointVec]
  exact WithTop.coe_ne_top

/-- **The tropical ideal of a point has uniform matroid in every degree.**

For a finite set `E` of at least two monomials, a set of monomials is a circuit
of the truncated vanishing ideal exactly when it has two elements. -/
theorem truncation_isCircuit_iff (hE : 1 < E.card) [DecidableEq {u // u ∈ E}]
    {C : Finset {u // u ∈ E}} :
    IsCircuit (truncation w E) C ↔ C.card = 2 := by
  classical
  obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.mp hE
  haveI : Nonempty {u // u ∈ E} := ⟨⟨p, hp⟩⟩
  have hEq : truncation w E = tropVanishing (pointVec w E) := by
    rw [truncation]
    exact truncation_eq_tropVanishing w E hE
  rw [hEq]
  exact tropVanishing_isCircuit_iff (pointVec w E) (pointVec_ne_top w E)

/-- In particular the truncated vanishing ideal of a point has circuits, so its
matroid is loopless and nontrivial. -/
theorem exists_isCircuit_truncation (hE : 1 < E.card) [DecidableEq {u // u ∈ E}] :
    ∃ C : Finset {u // u ∈ E}, IsCircuit (truncation w E) C := by
  classical
  obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.mp hE
  refine ⟨{⟨p, hp⟩, ⟨q, hq⟩}, (truncation_isCircuit_iff w E hE).mpr ?_⟩
  rw [Finset.card_insert_of_notMem (by simp [Subtype.ext_iff, hpq]), Finset.card_singleton]

end TropicalPointIdeal