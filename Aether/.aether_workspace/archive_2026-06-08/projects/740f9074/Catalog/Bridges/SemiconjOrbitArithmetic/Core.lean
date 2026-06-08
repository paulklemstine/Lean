/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the project LICENSE file.
-/
import Mathlib

/-!
# Semiconjugacy Orbit Arithmetic

## Bridge: Discrete Dynamics ↔ Finite Combinatorics ↔ Cryptographic State Compression

This file develops the **arithmetic theory of orbit transport through semiconjugacies**.
A semiconjugacy `h : α → β` between dynamical systems `f : α → α` and `g : β → β`
satisfies `h ∘ f = g ∘ h`. We prove that this commuting-diagram condition forces
sharp arithmetic constraints on periods and orbit structure.

### Main results

- `Function.Semiconj.isPeriodicPt_image`: periodic points descend through semiconjugacy.
- `Function.Semiconj.mapsTo_periodicPts_set`: setwise image inclusion for periodic-point sets.
- `Function.Semiconj.minimalPeriod_image_dvd`: minimal period of the image divides
  the minimal period upstairs.
- `Function.Semiconj.isPeriodicPt_iff_of_injective`: injective semiconjugacy reflects
  periodicity exactly.
- `Function.Semiconj.minimalPeriod_eq_of_injective`: injective semiconjugacy preserves
  minimal periods.
- `Function.Semiconj.mapsTo_periodicPts_n`: semiconjugacy maps periodic points of
  period `n` to periodic points of period `n`.
- `Function.Semiconj.exists_iterate_image_eq_of_finite`: finite-state orbit collision.

### Cross-domain significance

These results form the foundation for:
- **Cryptographic orbit analysis**: compressed observations of internal state machines
  inherit period-divisibility constraints.
- **Abstract interpretation**: factor maps in model checking preserve liveness properties.
- **Symbolic dynamics**: factor maps between subshifts preserve cycle structure.
- **Graph condensation**: functional digraph morphisms preserve cycle decompositions.

## References

* Brin, M. and Stuck, G., *Introduction to Dynamical Systems*, Cambridge University Press, 2002.
* Katok, A. and Hasselblatt, B., *Introduction to the Modern Theory of Dynamical Systems*,
  Cambridge University Press, 1995.
-/

open Function Set

namespace Function.Semiconj

variable {α β : Type*} {f : α → α} {g : β → β} {h : α → β}

/-! ## §1. Periodic point descent -/

/-- **Periodic points descend through semiconjugacy.**
If `h` semiconjugates `f` to `g` and `x` is a periodic point of `f` with period `n`,
then `h x` is a periodic point of `g` with the same period `n`.

This is the foundational orbit-transport theorem: the commuting diagram
`h ∘ f = g ∘ h` iterated `n` times gives `h ∘ f^[n] = g^[n] ∘ h`,
so `f^[n] x = x` implies `g^[n] (h x) = h (f^[n] x) = h x`. -/
theorem isPeriodicPt_image (hsc : Semiconj h f g) {x : α} {n : ℕ}
    (hx : IsPeriodicPt f n x) : IsPeriodicPt g n (h x) := by
  show g^[n] (h x) = h x
  rw [← hsc.iterate_right n x, hx.eq]

/-- **Semiconjugacy maps periodic points of period `n` to periodic points of period `n`.**
This is the set-theoretic formulation for a fixed period. -/
theorem mapsTo_periodicPts_n (hsc : Semiconj h f g) (n : ℕ) :
    MapsTo h {x | IsPeriodicPt f n x} {y | IsPeriodicPt g n y} :=
  fun _ hx => hsc.isPeriodicPt_image hx

/-- **Setwise periodic-point transport.**
The image of `periodicPts f` under a semiconjugacy lands in `periodicPts g`. -/
theorem mapsTo_periodicPts_set (hsc : Semiconj h f g) :
    MapsTo h (periodicPts f) (periodicPts g) :=
  fun _ ⟨n, hn, hx⟩ => ⟨n, hn, hsc.isPeriodicPt_image hx⟩

/-! ## §2. Minimal period divisibility -/

/-- **Minimal period divisibility under semiconjugacy.**
If `h` semiconjugates `f` to `g`, then the minimal period of `h x` under `g`
divides the minimal period of `x` under `f`.

This upgrades periodic-point descent from qualitative ("periodicity is preserved")
to quantitative ("the period can only shrink, and only by divisors").
Semiconjugacies can collapse cycles but only by integer factors. -/
theorem minimalPeriod_image_dvd (hsc : Semiconj h f g) (x : α) :
    minimalPeriod g (h x) ∣ minimalPeriod f x :=
  (hsc.isPeriodicPt_image (isPeriodicPt_minimalPeriod f x)).minimalPeriod_dvd

/-! ## §3. Injective semiconjugacy: periodicity reflection -/

/-- **Injective semiconjugacy reflects periodic points.**
If the factor map `h` is injective, then `h x` is periodic for `g` with period `n`
if and only if `x` is periodic for `f` with period `n`.

This is the rigidity theorem: injective semiconjugacies cannot collapse cycles. -/
theorem isPeriodicPt_iff_of_injective (hsc : Semiconj h f g)
    (hinj : Injective h) {x : α} {n : ℕ} :
    IsPeriodicPt g n (h x) ↔ IsPeriodicPt f n x := by
  constructor
  · intro hn
    have := hsc.iterate_right n
    exact hinj (by simpa [hn.eq] using this x)
  · exact fun a => hsc.isPeriodicPt_image a

/-- **Injective semiconjugacy preserves minimal periods exactly.**
When the factor map is injective, the minimal period is an invariant,
not merely a divisibility constraint. -/
theorem minimalPeriod_eq_of_injective (hsc : Semiconj h f g)
    (hinj : Injective h) (x : α) :
    minimalPeriod g (h x) = minimalPeriod f x := by
  apply Nat.dvd_antisymm (hsc.minimalPeriod_image_dvd x)
  exact ((hsc.isPeriodicPt_iff_of_injective hinj).mp
    (isPeriodicPt_minimalPeriod g (h x))).minimalPeriod_dvd

/-! ## §4. Finite-state orbit collisions -/

/-- **Finite-state orbit collision under semiconjugacy.**
When the codomain `β` is finite, the image orbit `n ↦ h (f^[n] x)` must
eventually collide: there exist `m < n` with `h (f^[m] x) = h (f^[n] x)`.

By semiconjugacy, this is equivalent to a collision in the `g`-orbit of `h x`,
which is forced by the pigeonhole principle on a finite type.

This is foundational for cryptographic orbit compression: any observation of an
internal state machine through a finite-codomain map must eventually repeat. -/
theorem exists_iterate_image_eq_of_finite [Finite β]
    (_hsc : Semiconj h f g) (x : α) :
    ∃ m n : ℕ, m < n ∧ h (f^[m] x) = h (f^[n] x) := by
  by_contra! htra
  have hfin : Set.Finite (Set.range (fun n => h (f^[n] x))) := Set.toFinite _
  exact hfin.not_infinite <| Set.infinite_range_of_injective fun m n hmn =>
    le_antisymm (le_of_not_gt fun h' => htra _ _ h' hmn.symm)
      (le_of_not_gt fun h' => htra _ _ h' hmn)

end Function.Semiconj