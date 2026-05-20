/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Euler–Mascheroni Constant: Definitions

This file defines the harmonic numbers, the Euler–Mascheroni sequence, and the
Euler–Mascheroni constant γ as the limit of the sequence `H_n - log n`.

## Main definitions

* `EulerMascheroni.harmonic n` — the `n`-th harmonic number `H_n = ∑_{k=1}^{n} 1/k`
* `EulerMascheroni.eulerMascheroniSeq n` — the sequence `H_n - log n`
* `EulerMascheroni.eulerMascheroni` — the Euler–Mascheroni constant γ
-/

namespace EulerMascheroni

open Finset Filter Real

/-- The `n`-th harmonic number: `H_n = ∑_{k=1}^{n} 1/k`. -/
noncomputable def harmonic (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.Icc 1 n, (1 : ℝ) / k

/-- The Euler–Mascheroni sequence: `a_n = H_n - log(n)`. -/
noncomputable def eulerMascheroniSeq (n : ℕ) : ℝ :=
  harmonic n - Real.log n

@[simp]
theorem harmonic_zero : harmonic 0 = 0 := by
  simp [harmonic]

theorem harmonic_succ (n : ℕ) :
    harmonic (n + 1) = harmonic n + 1 / (n + 1 : ℝ) := by
  sorry

theorem harmonic_pos (n : ℕ) (hn : 1 ≤ n) : 0 < harmonic n := by
  sorry

end EulerMascheroni