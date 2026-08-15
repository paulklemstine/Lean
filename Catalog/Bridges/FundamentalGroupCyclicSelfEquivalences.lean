/-
# `K(ℤ/n,1)` has exactly `φ(n)` self-homotopy-equivalences

Using the main theorem of `Catalog/Bridges/FundamentalGroupOuterAutomorphisms.lean` — the
homotopy self-equivalence group of a `K(G,1)` is `Out G` — we compute this group for the
infinite family of cyclic fundamental groups.  Since a cyclic group is abelian, `Out` is
the full automorphism group, and `Aut(ℤ/n) ≅ (ℤ/n)ˣ`.  Hence

  `hAut(K(ℤ/n,1)) ≅ (ℤ/n)ˣ`  and  `#hAut(K(ℤ/n,1)) = φ(n)`

(`hEndUnitsCyclicMulEquivUnits`, `card_hEnd_units_cyclicModel`), a bridge between homotopy
theory and elementary number theory: the number of homotopy classes of self-homotopy
equivalences of the infinite lens-space-like `K(ℤ/n,1)` is Euler's totient of `n`.

We also record the additive/multiplicative dictionary `mulAutMultiplicativeMulEquivAddAut`
identifying `Aut(Multiplicative A)` with `Aut(A)` for an additive group `A`.
-/
import Mathlib
import Bridges.FundamentalGroupOuterAutomorphisms
open CategoryTheory
open FundamentalGroupOut

namespace FundamentalGroupCyclic

/-- Automorphisms of the multiplicative copy of an additive group are its additive
automorphisms. -/
def mulAutMultiplicativeMulEquivAddAut (A : Type*) [AddGroup A] :
    MulAut (Multiplicative A) ≃* AddAut A where
  toFun e := AddEquiv.toMultiplicative.symm e
  invFun e := AddEquiv.toMultiplicative e
  left_inv e := by simp
  right_inv e := by simp
  map_mul' e f := by ext a; rfl

/-- The algebraic model of `K(ℤ/n,1)`: the one-object groupoid of the cyclic group of
order `n`. -/
abbrev CyclicModel (n : ℕ) : Type := SingleObj (Multiplicative (ZMod n))

/-- **The homotopy self-equivalence group of `K(ℤ/n,1)` is the unit group `(ℤ/n)ˣ`.** -/
noncomputable def hEndUnitsCyclicMulEquivUnits (n : ℕ) :
    (HEnd (CyclicModel n))ˣ ≃* (ZMod n)ˣ :=
  ((hEndUnitsSingleObjMulEquivMulAut (Multiplicative (ZMod n))
      (fun x y => mul_comm x y)).trans
    (mulAutMultiplicativeMulEquivAddAut (ZMod n))).trans (ZMod.AddAutEquivUnits n)

/-- **`K(ℤ/n,1)` has exactly `φ(n)` homotopy classes of self-homotopy-equivalences.** -/
theorem card_hEnd_units_cyclicModel (n : ℕ) [NeZero n] :
    Nat.card ((HEnd (CyclicModel n))ˣ) = n.totient := by
  rw [Nat.card_congr (hEndUnitsCyclicMulEquivUnits n).toEquiv, Nat.card_eq_fintype_card,
    ZMod.card_units_eq_totient]

/-- `K(ℤ/1,1)` and `K(ℤ/2,1)` are homotopy rigid: their only self-homotopy-equivalence up
to homotopy is the identity. -/
theorem card_hEnd_units_cyclicModel_two : Nat.card ((HEnd (CyclicModel 2))ˣ) = 1 := by
  rw [card_hEnd_units_cyclicModel 2]
  decide

/-- `K(ℤ/5,1)` has four homotopy classes of self-homotopy-equivalences. -/
theorem card_hEnd_units_cyclicModel_five : Nat.card ((HEnd (CyclicModel 5))ˣ) = 4 := by
  rw [card_hEnd_units_cyclicModel 5]
  decide

/-- For a prime `p`, `K(ℤ/p,1)` has exactly `p - 1` homotopy classes of
self-homotopy-equivalences. -/
theorem card_hEnd_units_cyclicModel_prime (p : ℕ) (hp : p.Prime) :
    Nat.card ((HEnd (CyclicModel p))ˣ) = p - 1 := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  rw [card_hEnd_units_cyclicModel p, Nat.totient_prime hp]

end FundamentalGroupCyclic