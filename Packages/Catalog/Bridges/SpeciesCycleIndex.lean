/-
# Fixed colourings and the classical cycle-counting identity

For a permutation `σ` of an `n`-element set, the colourings fixed by `σ` are exactly the
colourings that are constant on the cycles of `σ`, so there are `k^{c(σ)}` of them, where
`c(σ)` is the number of cycles (orbits of `⟨σ⟩`, fixed points included).

Combining this with `SpeciesEGF.Species.burnside_colour` yields the classical identity

    ∑_{σ ∈ Sym(n)} k^{c(σ)} = C(k+n-1, n) · n!   ( = k(k+1)⋯(k+n-1) ).
-/
import Bridges.SpeciesColourings

noncomputable section

namespace SpeciesEGF

open scoped BigOperators

namespace Species

variable {n : ℕ}

/-- The number of cycles of a permutation, counting fixed points: the number of orbits
of the cyclic group it generates. -/
def cycleCount (σ : Equiv.Perm (Fin n)) : ℕ :=
  Nat.card (Quotient (MulAction.orbitRel (Subgroup.zpowers σ) (Fin n)))

/-- A colouring fixed by `σ` is constant along the powers of `σ`. -/
theorem colour_fixed_zpow {k : ℕ} {σ : Equiv.Perm (Fin n)} {f : Fin n → Fin k}
    (hf : (colour k).map σ f = f) (z : ℤ) (x : Fin n) : f ((σ ^ z) x) = f x := by
  have hstep : ∀ y, f (σ y) = f y := by
    intro y
    have := congrFun hf (σ y)
    simpa using this.symm
  have hstep' : ∀ y, f (σ⁻¹ y) = f y := by
    intro y
    have := hstep (σ⁻¹ y)
    simpa using this.symm
  refine Int.induction_on z ?_ ?_ ?_
  · simp
  · intro m ih
    have hm : (σ ^ ((m : ℤ) + 1)) x = σ ((σ ^ (m : ℤ)) x) := by
      rw [show ((m : ℤ) + 1) = 1 + (m : ℤ) by ring, zpow_add, zpow_one]
      simp [Equiv.Perm.mul_apply]
    rw [hm, hstep, ih]
  · intro m ih
    have hm : (σ ^ (-(m : ℤ) - 1)) x = σ⁻¹ ((σ ^ (-(m : ℤ))) x) := by
      rw [show (-(m : ℤ) - 1) = -1 + -(m : ℤ) by ring, zpow_add, zpow_neg_one]
      simp [Equiv.Perm.mul_apply]
    rw [hm, hstep', ih]

/-- Colourings fixed by `σ` are the same thing as colourings of the set of cycles. -/
def fixedColourEquiv (k : ℕ) (σ : Equiv.Perm (Fin n)) :
    {f : Fin n → Fin k // (colour k).map σ f = f} ≃
      (Quotient (MulAction.orbitRel (Subgroup.zpowers σ) (Fin n)) → Fin k) where
  toFun f := Quotient.lift f.1 (by
    rintro a b ⟨⟨m, hm⟩, hmb⟩
    obtain ⟨z, rfl⟩ := hm
    have : (σ ^ z) b = a := hmb
    rw [← this, colour_fixed_zpow f.2])
  invFun F := ⟨fun a => F (Quotient.mk _ a), by
    funext a
    show F (Quotient.mk _ (σ.symm a)) = F (Quotient.mk _ a)
    refine congrArg F (Quotient.sound ?_)
    exact ⟨⟨σ⁻¹, Subgroup.mem_zpowers_iff.2 ⟨-1, by simp⟩⟩, rfl⟩⟩
  left_inv f := Subtype.ext rfl
  right_inv F := by
    funext q
    induction q using Quotient.inductionOn with
    | h a => rfl

/-- There are `k^{c(σ)}` colourings fixed by `σ`. -/
theorem card_fixed_colour (k : ℕ) (σ : Equiv.Perm (Fin n)) :
    Nat.card {f : Fin n → Fin k // (colour k).map σ f = f} = k ^ cycleCount σ := by
  classical
  letI : Fintype (Quotient (MulAction.orbitRel (Subgroup.zpowers σ) (Fin n))) :=
    Fintype.ofFinite _
  rw [Nat.card_congr (fixedColourEquiv k σ), Nat.card_eq_fintype_card, Fintype.card_fun,
    cycleCount, Nat.card_eq_fintype_card]
  simp

/-- **The cycle-counting identity.**  Summing `k` to the number of cycles over all
permutations of an `n`-element set gives `n!` times the number of multisets of size `n`
over `k` colours, i.e. the rising factorial `k(k+1)⋯(k+n-1)`. -/
theorem sum_pow_cycleCount (k n : ℕ) :
    ∑ σ : Equiv.Perm (Fin n), k ^ cycleCount σ = (k + n - 1).choose n * n.factorial := by
  rw [← burnside_colour k n]
  refine Finset.sum_congr rfl fun σ _ => ?_
  rw [← card_fixed_colour k σ]
  refine Nat.card_congr (Equiv.subtypeEquivRight fun f => ?_)
  constructor
  · intro h a
    exact congrFun h a
  · intro h
    funext a
    exact h a

/-- For `k = 1` the identity degenerates to `|Sym(n)| = n!`. -/
theorem sum_one_pow_cycleCount (n : ℕ) :
    ∑ _σ : Equiv.Perm (Fin n), (1 : ℕ) = n.factorial := by
  have h := sum_pow_cycleCount 1 n
  simpa using h

end Species

end SpeciesEGF