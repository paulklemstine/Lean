import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.ZMod.Basic
import Mathlib.LinearAlgebra.Dimension.Finite

/-!
# Sharpness of finite-group cocycle averaging

The finite-group averaging argument requires the group order to be invertible in the
coefficient field.  This file shows that this is not merely a proof artifact: in every
prime characteristic, the cyclic group of that prime order has a degree-one cocycle
for the trivial action which is not a coboundary.
-/

namespace GreenbergMuZeroSharpness

/-- The cyclic group of order `p`, written multiplicatively. -/
abbrev CyclicPrimeGroup (p : ℕ) := Multiplicative (ZMod p)

/-- The trivial linear action of the cyclic group on its coefficient field. -/
def trivialAction (p : ℕ) :
    CyclicPrimeGroup p → (ZMod p →ₗ[ZMod p] ZMod p) :=
  fun _ ↦ LinearMap.id

/-- The additive coordinate on `ZMod p`, viewed as a function from the same cyclic
 group written multiplicatively. -/
def identityCocycle (p : ℕ) : CyclicPrimeGroup p → ZMod p :=
  fun g ↦ Multiplicative.toAdd g

/-- The identity coordinate is a degree-one cocycle for the trivial action. -/
theorem identityCocycle_cocycle (p : ℕ) :
    ∀ g h : CyclicPrimeGroup p,
      identityCocycle p (g * h) =
        identityCocycle p g + trivialAction p g (identityCocycle p h) := by
  intro g h
  simp [identityCocycle, trivialAction]

/-- In prime characteristic, the identity cocycle is not a coboundary.  Thus the
usual averaging conclusion can genuinely fail when the characteristic divides the
group order. -/
theorem identityCocycle_not_coboundary (p : ℕ) [Fact p.Prime] :
    ¬ ∃ v : ZMod p, ∀ g : CyclicPrimeGroup p,
      identityCocycle p g = v - trivialAction p g v := by
  rintro ⟨v, hv⟩
  have h := hv (Multiplicative.ofAdd (1 : ZMod p))
  simp [identityCocycle, trivialAction] at h

/-- A uniform family of counterexamples to the bold conjecture that finite-group
cocycle averaging might work without invertibility of the group order.  The witness
has group order zero in the coefficient field, satisfies the cocycle law, and is not
a coboundary. -/
theorem counterexample_to_unconditional_averaging (p : ℕ) [Fact p.Prime] :
    (Nat.card (CyclicPrimeGroup p) : ZMod p) = 0 ∧
    (∀ g h : CyclicPrimeGroup p,
      identityCocycle p (g * h) =
        identityCocycle p g + trivialAction p g (identityCocycle p h)) ∧
    ¬ ∃ v : ZMod p, ∀ g : CyclicPrimeGroup p,
      identityCocycle p g = v - trivialAction p g v := by
  refine ⟨?_, identityCocycle_cocycle p, identityCocycle_not_coboundary p⟩
  rw [Nat.card_congr
    (Multiplicative.toAdd : Multiplicative (ZMod p) ≃ ZMod p)]
  rw [Nat.card_zmod]
  exact ZMod.natCast_self p

end GreenbergMuZeroSharpness