/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The layered-star formula `Mformula` and its central-layer maximum

This file develops the counting machinery behind the *uniform layered-star*
VC-dimension construction (see `UniformVCStar.lean`).

* `layeredSum n d = ∑_{k=0}^{d} C(n,k)` is the Sauer–Shelah growth bound; we prove
  it is **monotone** in both the layer budget `d` (`layeredSum_mono_d`) and the
  number of points `n` (`layeredSum_mono_n`), and bounded above by `2 ^ n`.
* `starLayer d k = C(d,k)` is the size profile of star layer `k`; it attains its
  **maximum at `k = ⌊d/2⌋`** (`starLayer_max`), the middle binomial coefficient.
* `Mformula n d = C(n, ⌊d/2⌋)` is the size of the central uniform layer, a single
  summand of `layeredSum` (`Mformula_le_layeredSum`).

These statements correspond, via `import Mathlib`, to `Nat.choose_le_middle`,
`Nat.choose_mono`, and `Nat.sum_range_choose`; the companion thin wrappers live in
`Binomial.lean`.
-/
import Mathlib

open Finset

namespace Catalog.Novelty.LayeredStar

/-- `layeredSum n d = ∑_{k=0}^{d} C(n,k)`, the Sauer–Shelah growth bound. -/
def layeredSum (n d : ℕ) : ℕ := ∑ k ∈ Finset.range (d + 1), n.choose k

@[simp] theorem layeredSum_zero (n : ℕ) : layeredSum n 0 = 1 := by
  simp [layeredSum]

/-- **Monotonicity in the layer budget `d`.** -/
theorem layeredSum_mono_d {n d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    layeredSum n d₁ ≤ layeredSum n d₂ := by
  unfold layeredSum
  exact Finset.sum_le_sum_of_subset (Finset.range_mono (by omega))

/-- **Monotonicity in the number of points `n`.** -/
theorem layeredSum_mono_n {n₁ n₂ d : ℕ} (h : n₁ ≤ n₂) :
    layeredSum n₁ d ≤ layeredSum n₂ d := by
  unfold layeredSum
  exact Finset.sum_le_sum (fun k _ => Nat.choose_mono k h)

/-- The growth bound never exceeds `2 ^ n`. -/
theorem layeredSum_le_pow (n d : ℕ) (h : d ≤ n) : layeredSum n d ≤ 2 ^ n := by
  unfold layeredSum
  calc ∑ k ∈ Finset.range (d + 1), n.choose k
      ≤ ∑ k ∈ Finset.range (n + 1), n.choose k :=
        Finset.sum_le_sum_of_subset (Finset.range_mono (by omega))
    _ = 2 ^ n := Nat.sum_range_choose n

/-- The number of sets contributed by star layer `k` in a depth-`d` construction. -/
def starLayer (d k : ℕ) : ℕ := d.choose k

/-- **The star-layer profile attains its maximum at `k = ⌊d/2⌋`.**
This is the central (middle) binomial coefficient being maximal. -/
theorem starLayer_max (d k : ℕ) : starLayer d k ≤ starLayer d (d / 2) :=
  Nat.choose_le_middle k d

/-- `Mformula n d = C(n, ⌊d/2⌋)`, the size of the central uniform layer. -/
def Mformula (n d : ℕ) : ℕ := n.choose (d / 2)

theorem Mformula_eq (n d : ℕ) : Mformula n d = n.choose (d / 2) := rfl

/-- The central layer term is a single summand of `layeredSum`, hence bounded by it. -/
theorem Mformula_le_layeredSum (n d : ℕ) : Mformula n d ≤ layeredSum n d := by
  unfold Mformula layeredSum
  apply Finset.single_le_sum (f := fun k => n.choose k) (fun i _ => Nat.zero_le _)
  exact Finset.mem_range.mpr (by omega)

/-- `Mformula` is monotone in the number of points. -/
theorem Mformula_mono_n {n₁ n₂ d : ℕ} (h : n₁ ≤ n₂) :
    Mformula n₁ d ≤ Mformula n₂ d :=
  Nat.choose_mono _ h

end Catalog.Novelty.LayeredStar