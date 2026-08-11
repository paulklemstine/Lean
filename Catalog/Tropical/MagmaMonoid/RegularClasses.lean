import Tropical.MagmaMonoid.GreenD
import Tropical.MagmaMonoid.Structure

/-!
# Regularity is a class function for Green's relations

Combining the regularity criterion (`Regularity.lean`) with the descriptions of
Green's relations (`Green.lean`, `GreenD.lean`) we show that regularity in the
magma monoid is constant on `D`-classes, hence on `L`- and `R`-classes:

* `IsRegular.of_greenD`, `isRegular_congr_greenL`, `isRegular_congr_greenR`.

The proof is purely structural: a swap-equivariant injection matches diagonal
points with diagonal points in both directions, so the diagonal obstruction is
transported along Green's relations.  In particular the two non-regular
operations on a two-element set form a union of `D`-classes.
-/

namespace MagmaMonoid

variable {X : Type*}

theorem GreenL.symm {f g : Operation X} (h : GreenL f g) : GreenL g f := ⟨h.2, h.1⟩

theorem GreenR.symm {f g : Operation X} (h : GreenR f g) : GreenR g f := ⟨h.2, h.1⟩

/-- **Regularity is a `D`-class invariant.** -/
theorem IsRegular.of_greenD {f g : Operation X} (h : GreenD f g) (hf : IsRegular f) :
    IsRegular g := by
  rw [isRegular_iff_commutativeImage_eq_diagonalImage] at hf ⊢
  obtain ⟨β, hβ, hinj, himg, hdiag⟩ := (greenD_iff f g).1 h
  refine subset_antisymm ?_ ?_
  · rintro q ⟨hq, ⟨x, hx⟩⟩
    -- `q` is a diagonal point of the image of `g`
    have hqswap : swap q = q := by rw [← hx]; rfl
    have hβq : β q ∈ commutativeImage f := by
      refine ⟨?_, ?_⟩
      · rw [← himg]
        exact ⟨q, hq, rfl⟩
      · refine ⟨(β q).1, ?_⟩
        have : swap (β q) = β q := by rw [← hβ.apply_swap q, hqswap]
        exact Prod.ext rfl (congrArg Prod.fst this).symm
    rw [hf, ← hdiag] at hβq
    obtain ⟨d, hd, hdq⟩ := hβq
    have hdmem : d ∈ pairImage g := by
      obtain ⟨z, hz⟩ := hd
      exact ⟨(z, z), hz⟩
    rwa [hinj hdmem hq hdq] at hd
  · rintro q ⟨z, rfl⟩
    exact ⟨⟨(z, z), rfl⟩, ⟨g z z, rfl⟩⟩

/-- Regularity is constant on `L`-classes. -/
theorem isRegular_congr_greenL {f g : Operation X} (h : GreenL f g) :
    IsRegular f ↔ IsRegular g :=
  ⟨fun hf ↦ hf.of_greenD h.greenD, fun hg ↦ hg.of_greenD h.symm.greenD⟩

/-- Regularity is constant on `R`-classes. -/
theorem isRegular_congr_greenR {f g : Operation X} (h : GreenR f g) :
    IsRegular f ↔ IsRegular g :=
  ⟨fun hf ↦ hf.of_greenD h.greenD, fun hg ↦ hg.of_greenD h.symm.greenD⟩

/-- The magma monoid on an `n`-element set has `n^(n²)` elements, of which only
`n! · 2^(n(n-1)/2) · (n(n-1)/2)!` are invertible. -/
theorem card_bin_fin (n : ℕ) : Nat.card (Bin (Fin n)) = n ^ (n * n) := by
  have : Nat.card (Bin (Fin n)) = Nat.card (Fin n → Fin n → Fin n) := rfl
  rw [this, Nat.card_eq_fintype_card]
  simp [pow_mul]

end MagmaMonoid