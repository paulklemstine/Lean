/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Iteration & semigroup theory for set-local distortion of Hausdorff dimension

This file specialises the *composition* theory of
`Geometry/QuasiSymmetricComposition.lean` to the **self-map / iteration**
setting — the natural home of iterated function systems, dynamical attractors
and conjugacy semigroups.  Throughout, `f : X → X` maps an invariant piece `s`
into itself (`MapsTo f s s`), and we track how the iterate `f^[n]` distorts the
Hausdorff dimension of `s`.

Main results:

* `lipschitzOnWith_iterate` / `antilipschitzOnWith_iterate` — the (anti)Lipschitz
  constant of `f^[n]` on the invariant set `s` is `K^n`;
* `holderOnWith_iterate` — the Hölder exponent of `f^[n]` is the power `r^n`;
* `dimH_image_iterate_eq` (**main**) — a set-local bi-Lipschitz self-map preserves
  the Hausdorff dimension under *every* iterate: `dimH (f^[n] '' s) = dimH s`;
* `dimH_image_iterate_le` — the iterated Hölder distortion bound
  `dimH (f^[n] '' s) ≤ dimH s / r^n`;
* `dimH_image_iterate_const` — restatement of the main result as the assertion
  that `n ↦ dimH (f^[n] '' s)` is a *constant* sequence (a genuine fixed point of
  the iteration), the seed for an attractor-dimension fixed-point theory.

Everything reduces to the per-step composition lemmas
`LipschitzOnWith.comp`, `QuasiSymmetricComposition.AntilipschitzOnWith.comp`,
`HolderOnWith.comp` together with `Set.MapsTo.iterate`, by induction on `n`.
-/

import Catalog.Geometry.QuasiSymmetricComposition

open MeasureTheory Set Function
open scoped NNReal ENNReal

namespace QuasiSymmetricIterate

open QuasiSymmetricComposition

variable {X : Type*} [EMetricSpace X] {K K' C r : ℝ≥0} {f : X → X} {s : Set X}

/-
!-- Lab Notebook -- !--
Hypothesis:  On an invariant set (`MapsTo f s s`), the per-step composition
  estimates should iterate cleanly: the constant of `f^[n]` is the `n`-th power
  of the one-step constant, and bi-Lipschitz invariance should therefore hold
  for *every* iterate, not just `n = 1`.
Result:      All four iterate lemmas go through by induction with the single
  rewrite `Function.iterate_succ' : f^[n+1] = f ∘ f^[n]` paired with the matching
  exponent law (`pow_succ` / `pow_succ'`).  The main theorem `dimH_image_iterate_eq`
  is then a one-liner combining the two constant-power iterates through
  `QuasiSymmetricComposition.dimH_image_eq`.
Insight:     The dimension `n ↦ dimH (f^[n] '' s)` is *constant* for a set-local
  bi-Lipschitz self-map — the attractor's dimension is a genuine fixed point of
  the iteration.  This is precisely the structure that an open-set/separation
  condition would pin to the similarity dimension.
Failure:     The antilipschitz iterate must use `pow_succ` (`K^(n+1) = K^n * K`)
  to match the constant `Kf * Kg = K^n * K` produced by `AntilipschitzOnWith.comp`,
  whereas the Lipschitz/Hölder iterates use `pow_succ'` (`= K * K^n`); mixing
  them up produces a constant mismatch that `exact` rejects.
-/

/-
!-- Induct on `n`: base `f^[0] = id` is `1`-Lipschitz; step `f^[n+1] = f ∘ f^[n]`
via `LipschitzOnWith.comp` and `MapsTo.iterate`, with `K^(n+1) = K · K^n`. -!--

On an invariant set `s`, the iterate `f^[n]` is `K^n`-Lipschitz. -/
theorem lipschitzOnWith_iterate (h : LipschitzOnWith K f s) (hm : MapsTo f s s) :
    ∀ n, LipschitzOnWith (K ^ n) (f^[n]) s
  | 0 => by simpa using (LipschitzWith.id.lipschitzOnWith (s := s))
  | n + 1 => by
      rw [Function.iterate_succ', pow_succ']
      exact h.comp (lipschitzOnWith_iterate h hm n) (hm.iterate n)

/-
!-- Same induction with `AntilipschitzOnWith.comp`; the step uses
`K^(n+1) = K^n · K` to match the composite constant `Kf · Kg`. -!--

On an invariant set `s`, the iterate `f^[n]` is `K^n`-antilipschitz. -/
theorem antilipschitzOnWith_iterate (h : AntilipschitzOnWith K f s) (hm : MapsTo f s s) :
    ∀ n, AntilipschitzOnWith (K ^ n) (f^[n]) s
  | 0 => by intro x hx y hy; simp
  | n + 1 => by
      rw [Function.iterate_succ', pow_succ]
      exact h.comp (antilipschitzOnWith_iterate h hm n) (hm.iterate n)

/-
!-- Induct: base `f^[0] = id` is Hölder of exponent `1 = r^0`; step
`f^[n+1] = f ∘ f^[n]` via `HolderOnWith.comp`, multiplying exponents
`r · r^n = r^(n+1)` (the composite constant is tracked existentially). -!--

On an invariant set `s`, the iterate `f^[n]` is Hölder with exponent `r^n`
(for some constant). -/
theorem holderOnWith_iterate (h : HolderOnWith C r f s) (hm : MapsTo f s s) :
    ∀ n, ∃ C', HolderOnWith C' (r ^ n) (f^[n]) s
  | 0 => by
      refine ⟨1, ?_⟩
      rw [pow_zero]
      simpa using (LipschitzWith.id.lipschitzOnWith (s := s)).holderOnWith
  | n + 1 => by
      obtain ⟨C', hC'⟩ := holderOnWith_iterate h hm n
      refine ⟨C * C' ^ (r : ℝ), ?_⟩
      rw [Function.iterate_succ', pow_succ']
      exact h.comp hC' (hm.iterate n)

/-
!-- Combine the `K^n`-Lipschitz and `K'^n`-antilipschitz iterates through
`QuasiSymmetricComposition.dimH_image_eq`. -!--

**Main theorem.** A set-local bi-Lipschitz self-map of an invariant set `s`
preserves its Hausdorff dimension under *every* iterate. -/
theorem dimH_image_iterate_eq [Nonempty X] (hL : LipschitzOnWith K f s)
    (hA : AntilipschitzOnWith K' f s) (hm : MapsTo f s s) (n : ℕ) :
    dimH (f^[n] '' s) = dimH s :=
  dimH_image_eq (lipschitzOnWith_iterate hL hm n) (antilipschitzOnWith_iterate hA hm n)

/-
!-- Reading the main theorem at indices `m, n` and chaining the two equalities. -!--

The dimension of the orbit pieces is a *constant* sequence in `n`: for a
set-local bi-Lipschitz self-map, `dimH (f^[m] '' s) = dimH (f^[n] '' s)` for all
`m, n`.  The attractor's dimension is a fixed point of the iteration. -/
theorem dimH_image_iterate_const [Nonempty X] (hL : LipschitzOnWith K f s)
    (hA : AntilipschitzOnWith K' f s) (hm : MapsTo f s s) (m n : ℕ) :
    dimH (f^[m] '' s) = dimH (f^[n] '' s) := by
  rw [dimH_image_iterate_eq hL hA hm m, dimH_image_iterate_eq hL hA hm n]

/-
!-- Take the `r^n`-Hölder iterate and apply `HolderOnWith.dimH_image_le` with
`0 < r^n`. -!--

The iterated Hölder distortion bound: each iterate divides the dimension by the
power `r^n`. -/
theorem dimH_image_iterate_le (h : HolderOnWith C r f s) (hr : 0 < r)
    (hm : MapsTo f s s) (n : ℕ) :
    dimH (f^[n] '' s) ≤ dimH s / ((r ^ n : ℝ≥0) : ℝ≥0∞) := by
  obtain ⟨C', hC'⟩ := holderOnWith_iterate h hm n
  exact hC'.dimH_image_le (pow_pos hr n)

end QuasiSymmetricIterate