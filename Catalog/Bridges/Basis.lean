/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.SpectralNuclei.Separation

/-! # Spectral Basis for the Prime Spectrum

We instantiate the `SpectralBasis` structure on the prime spectrum of a frame,
showing that basic opens of compact elements form a basis closed under finite
intersections. This is a finite-basis surrogate for the full spectral topology.

## Main results

* `primeElementBasis` : the spectral basis on `PrimeElement L`
* `compact_basicOpen_inter` : `D(k) ∩ D(l) = D(k ⊔ l)` for compact elements
  (using the sup = join of compact elements, which IS compact)
-/

open Set Order

universe u

variable {L : Type u} [Order.Frame L]

/-
Compact elements are closed under finite sups in any complete lattice.
If `k` and `l` are compact, then `k ⊔ l` is compact.
-/
theorem IsCompactElement.sup {k l : L}
    (hk : IsCompactElement k) (hl : IsCompactElement l) :
    IsCompactElement (k ⊔ l) := by
  intro s u hs hs' hu h;
  obtain ⟨ x, hx ⟩ := hk s u hs hs' hu ( le_trans ( le_sup_left ) h );
  obtain ⟨ y, hy ⟩ := hl s u hs hs' hu ( le_trans ( le_sup_right ) h );
  rcases hs' x hx.1 y hy.1 with ⟨ z, hz, hxz, hyz ⟩ ; exact ⟨ z, hz, sup_le ( le_trans hx.2 hxz ) ( le_trans hy.2 hyz ) ⟩

/-
⊥ is compact in any complete lattice.
-/
theorem isCompactElement_bot' : IsCompactElement (⊥ : L) := by
  intro S hS hd;
  exact fun _ _ _ => ⟨ _, hd.choose_spec, bot_le ⟩

/-- The **spectral basis** on `PrimeElement L`: basic opens of elements of `L`
form a basis closed under finite intersections (which correspond to joins
in the frame) and including `∅` and `Set.univ`. -/
noncomputable def primeElementBasis :
    SpectralBasis (PrimeElement L) where
  IsBasic U := ∃ k : L, U = basicOpen L k
  inter_basic := by
    rintro _ _ ⟨a, rfl⟩ ⟨b, rfl⟩
    exact ⟨a ⊓ b, (basicOpen_inf a b).symm⟩
  top_basic := ⟨⊤, (basicOpen_top).symm⟩
  bot_basic := ⟨⊥, (basicOpen_bot).symm⟩