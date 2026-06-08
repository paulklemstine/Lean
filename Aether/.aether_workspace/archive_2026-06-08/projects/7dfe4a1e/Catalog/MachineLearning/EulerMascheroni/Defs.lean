/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Euler–Mascheroni Constant: Core Definitions

This file defines the harmonic numbers and the Euler–Mascheroni sequence
`a_n = H_n - log(n)`, and establishes basic properties.

## Main definitions

* `EulerMascheroni.harmonic n` — the `n`-th harmonic number `H_n = ∑_{k=1}^{n} 1/k`
* `EulerMascheroni.eulerMascheroniSeq n` — the sequence `H_n - log(n)`

## Key results

* `harmonic_succ` — recurrence `H_{n+1} = H_n + 1/(n+1)`
* `harmonic_pos` — positivity for `n ≥ 1`
-/

namespace EulerMascheroni

open Finset Filter Real BigOperators

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
    harmonic (n + 1) = harmonic n + 1 / (↑(n + 1) : ℝ) := by
  exact mod_cast Finset.sum_Ioc_succ_top ( by norm_num ) _

theorem harmonic_one : harmonic 1 = 1 := by
  -- By definition of harmonic, we have harmonic 1 = ∑ k ∈ Finset.Icc 1 1, (1 : ℝ) / k.
  simp [harmonic]

theorem harmonic_pos (n : ℕ) (hn : 1 ≤ n) : 0 < harmonic n := by
  exact Finset.sum_pos ( fun x hx => one_div_pos.mpr <| Nat.cast_pos.mpr <| Finset.mem_Icc.mp hx |>.1 ) <| Finset.nonempty_Icc.mpr hn

end EulerMascheroni