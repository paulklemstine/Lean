import Bridges.TropicalPlancherel.TropicalPlancherel_Defs

/-!
# Tropical Plancherel — theorems

This file replaces a placeholder that contained only a stale file path and did not
compile.

* `TropicalPlancherel.tropConv_comm` — tropical convolution is commutative;
* `TropicalPlancherel.tropSup_tropConv` — **the tropical Plancherel identity**: the
  tropical mass of a convolution is the (tropical) product of the masses,
  `max (f ⋆ g) = max f + max g`.  In the max-plus semiring "sum" is `max` and "product"
  is `+`, so this is the exact analogue of `‖f * g‖₁ = ‖f‖₁ ‖g‖₁` for nonnegative
  functions — and unlike the classical statement it is an identity for *all* real-valued
  `f, g`, with no positivity hypothesis.
* `TropicalPlancherel.tropSup_tropConv_self` — the diagonal (energy) case.
-/

noncomputable section

namespace TropicalPlancherel

variable {m : ℕ} [NeZero m]

/-- Tropical convolution is commutative. -/
theorem tropConv_comm (f g : ZMod m → ℝ) (n : ZMod m) :
    tropConv f g n = tropConv g f n := by
  apply le_antisymm
  · refine tropConv_le (fun x => ?_)
    have h := le_tropConv g f n (n - x)
    rw [sub_sub_cancel] at h
    linarith
  · refine tropConv_le (fun x => ?_)
    have h := le_tropConv f g n (n - x)
    rw [sub_sub_cancel] at h
    linarith

/-- **Tropical Plancherel identity.**  The tropical mass of a tropical convolution is
the sum of the tropical masses. -/
theorem tropSup_tropConv (f g : ZMod m → ℝ) :
    tropSup (tropConv f g) = tropSup f + tropSup g := by
  apply le_antisymm
  · refine tropSup_le (fun n => tropConv_le (fun x => ?_))
    exact add_le_add (le_tropSup f x) (le_tropSup g (n - x))
  · obtain ⟨x, hx⟩ := exists_tropSup_eq f
    obtain ⟨y, hy⟩ := exists_tropSup_eq g
    have h1 : f x + g y ≤ tropConv f g (x + y) := by
      have h := le_tropConv f g (x + y) x
      rwa [add_sub_cancel_left] at h
    calc tropSup f + tropSup g = f x + g y := by rw [hx, hy]
      _ ≤ tropConv f g (x + y) := h1
      _ ≤ tropSup (tropConv f g) := le_tropSup _ _

/-- The energy form of the identity: the tropical autoconvolution doubles the mass. -/
theorem tropSup_tropConv_self (f : ZMod m → ℝ) :
    tropSup (tropConv f f) = 2 * tropSup f := by
  rw [tropSup_tropConv]; ring

end TropicalPlancherel