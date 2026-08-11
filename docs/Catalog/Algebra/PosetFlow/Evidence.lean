import Algebra.PosetFlow.HallMobius
import Algebra.PosetFlow.IntervalEuler
import Algebra.PosetFlow.OrderReflecting

/-!
# Computational evidence for the chain-replacement files

This file contains no theorems: it records the `#eval` computations that were used
to test the statements proved in `Algebra.PosetFlow.OrderComplexEuler`,
`Algebra.PosetFlow.ChainPoset`, `Algebra.PosetFlow.HallMobius` and
`Algebra.PosetFlow.OrderReflecting` before formalising them.  The numerical outputs
are tabulated in `ComputationalEvidence.md`.
-/

open PosetFlow Finset

section Evidence

-- Number of chains from `0` to `3` in the linear order `Fin 4`: `2 ^ 2 = 4`.
#eval (chainFinsets (0 : Fin 4) 3).card
-- Alternating sums in a linear order agree with `-μ`.
#eval (chainAltSum (0 : Fin 4) 3, chainAltSum (0 : Fin 4) 1)
#eval (IncidenceAlgebra.mu ℤ (0 : Fin 4) 3, IncidenceAlgebra.mu ℤ (0 : Fin 4) 1)
-- Philip Hall's theorem, checked exhaustively on `Fin 5`.
#eval decide (∀ x y : Fin 5, chainAltSum x y = -IncidenceAlgebra.mu ℤ x y)

-- Chains from `⊥` to `⊤` in the Boolean lattices `B₁, B₂, B₃`: `1, 3, 13`
-- (the ordered Bell numbers, OEIS A000670).
#eval ((chainFinsets (⊥ : Finset (Fin 1)) ⊤).card,
       (chainFinsets (⊥ : Finset (Fin 2)) ⊤).card,
       (chainFinsets (⊥ : Finset (Fin 3)) ⊤).card)
#eval (chainAltSum (⊥ : Finset (Fin 3)) ⊤, IncidenceAlgebra.mu ℤ (⊥ : Finset (Fin 3)) ⊤)
-- Philip Hall's theorem, checked exhaustively on the Boolean lattice `B₃`.
#eval decide (∀ x y : Finset (Fin 3), chainAltSum x y = -IncidenceAlgebra.mu ℤ x y)

-- Cone-point vanishing of the alternating face sum of the order complex.
#eval (∑ C ∈ orderComplex (Fin 4), (-1 : ℤ) ^ C.card,
       ∑ C ∈ orderComplex (Finset (Fin 2)), (-1 : ℤ) ^ C.card)

/-- The two-element antichain, as a subtype of the Boolean lattice `B₂`. -/
abbrev Crown2 := {s : Finset (Fin 2) // s.card = 1}

-- Without a cone point the alternating face sum need not vanish: for the
-- two-element antichain it is `-1` (two contractible components).
#eval ∑ C ∈ orderComplex Crown2, (-1 : ℤ) ^ C.card

-- Number of chains between the two points of the two-element antichain: none.
#eval ((chainFinsets (x := (⟨{0}, rfl⟩ : Crown2)) ⟨{1}, rfl⟩).card,
       (chainFinsets (x := (⟨{0}, rfl⟩ : Crown2)) ⟨{0}, rfl⟩).card)

-- Alternating face sum of the order complex of the open interval (⊥,⊤) of B₃,
-- which should equal -μ(⊥,⊤) = 1.
#eval ∑ F ∈ orderComplex (openInterval (⊥ : Finset (Fin 3)) ⊤), (-1 : ℤ) ^ F.card
#eval -IncidenceAlgebra.mu ℤ (⊥ : Finset (Fin 3)) (⊤ : Finset (Fin 3))
-- The interval (∅,{0,1}) of B₃ has 2 elements, forming an antichain: sum = -1 = -μ.
#eval (∑ F ∈ orderComplex (openInterval (⊥ : Finset (Fin 3)) {0, 1}), (-1 : ℤ) ^ F.card,
       -IncidenceAlgebra.mu ℤ (⊥ : Finset (Fin 3)) {0, 1})

end Evidence