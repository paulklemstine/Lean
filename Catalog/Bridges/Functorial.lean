/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.SpectralNuclei.BasicOpen

/-! # Functoriality: Pullback of Prime Elements

A frame homomorphism `f : L →ₛ M` (preserving meets, top, and all joins)
induces a map `Spec(M) → Spec(L)` on prime spectra via the right adjoint.

The **right adjoint** `g : M → L` of a frame homomorphism `f` is defined by
`g(b) = sSup {a : L | f a ≤ b}`. The key property is that `g` sends prime
elements to prime elements, because the adjunction `f(x) ≤ p ↔ x ≤ g(p)`
reduces primality of `g(p)` to primality of `p`.

## Main results

* `rightAdjoint` : the right adjoint of a frame homomorphism
* `gc_frameHom` : the Galois connection `f ⊣ g`
* `PrimeElement.comap` : pullback of primes via the right adjoint
* `preimage_basicOpen` : `comap f ⁻¹' D(k) = D(f k)`
-/

open Set Order

universe u

variable {L M : Type u} [Order.Frame L] [Order.Frame M]

/-! ### Right adjoint of a frame homomorphism -/

/-- The **right adjoint** of a frame homomorphism `f : L → M`.
For each `b : M`, `g(b) = sSup {a : L | f a ≤ b}`. -/
noncomputable def rightAdjoint (f : FrameHom L M) (b : M) : L :=
  sSup {a : L | f a ≤ b}

/-- The Galois connection: `f a ≤ b ↔ a ≤ g b` where `g` is the right adjoint. -/
theorem gc_frameHom (f : FrameHom L M) :
    GaloisConnection f (rightAdjoint f) := by
  intro a b
  constructor
  · intro h
    exact le_sSup h
  · intro h
    calc f a ≤ f (rightAdjoint f b) := by
          exact OrderHomClass.mono f h
      _ = f (sSup {a : L | f a ≤ b}) := rfl
      _ = sSup (f '' {a : L | f a ≤ b}) := by
          exact map_sSup f {a | f a ≤ b}
      _ ≤ b := by
          apply sSup_le
          rintro _ ⟨c, hc, rfl⟩
          exact hc

/-- The right adjoint sends ⊤ to ⊤. -/
theorem rightAdjoint_top (f : FrameHom L M) :
    rightAdjoint f ⊤ = ⊤ := by
  apply top_le_iff.mp
  exact (gc_frameHom f).le_u (le_top)

/-- The right adjoint preserves meets. This follows from being a right adjoint
(right adjoints preserve all limits/meets). -/
theorem rightAdjoint_preserves_inf (f : FrameHom L M) (a b : M) :
    rightAdjoint f (a ⊓ b) = rightAdjoint f a ⊓ rightAdjoint f b := by
  exact (gc_frameHom f).u_inf

/-! ### Pullback of prime elements -/

/-- **Pullback of prime elements**: the right adjoint of a frame homomorphism
sends prime elements to prime elements.

Proof: Let `g = rightAdjoint f`. For the primality of `g(p)`:
if `x ⊓ y ≤ g(p)`, then by adjunction `f(x ⊓ y) ≤ p`. Since `f` preserves
meets, `f(x) ⊓ f(y) ≤ p`. By primality of `p`, `f(x) ≤ p` or `f(y) ≤ p`,
so by adjunction, `x ≤ g(p)` or `y ≤ g(p)`. -/
noncomputable def PrimeElement.comap
    (f : FrameHom L M) (p : PrimeElement M) : PrimeElement L where
  val := rightAdjoint f p.val
  ne_top := by
    intro h
    apply p.ne_top
    apply top_le_iff.mp
    calc ⊤ = f ⊤ := (map_top f).symm
      _ ≤ f (rightAdjoint f p.val) := by
          exact OrderHomClass.mono f (h ▸ le_refl _)
      _ ≤ p.val := (gc_frameHom f).l_u_le p.val
  prime := by
    intro x y hxy
    have hfxy : f x ⊓ f y ≤ p.val := by
      calc f x ⊓ f y = f (x ⊓ y) := (map_inf f x y).symm
        _ ≤ f (rightAdjoint f p.val) := OrderHomClass.mono f hxy
        _ ≤ p.val := (gc_frameHom f).l_u_le p.val
    exact (p.prime hfxy).imp
      ((gc_frameHom f).le_u ·)
      ((gc_frameHom f).le_u ·)

/-- The basic-open preimage law: pulling back a basic open along a frame
homomorphism's comap gives a basic open.

`comap f ⁻¹' D(k) = D(f k)`

Proof: `p ∈ comap f ⁻¹' D(k)` iff `¬(k ≤ g(p.val))` iff (by adjunction)
`¬(f(k) ≤ p.val)` iff `p ∈ D(f k)`. -/
theorem preimage_basicOpen
    (f : FrameHom L M) (k : L) :
    PrimeElement.comap f ⁻¹' basicOpen L k = basicOpen M (f k) := by
  ext p
  simp only [mem_preimage, basicOpen, mem_setOf_eq, PrimeElement.comap]
  constructor
  · intro h hfk
    exact h ((gc_frameHom f).le_u hfk)
  · intro h hkg
    exact h ((gc_frameHom f).l_u_le p.val |>.trans' (OrderHomClass.mono f hkg))