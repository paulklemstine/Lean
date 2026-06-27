/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Proof Automation III: `spectral_bound` — Gershgorin eigenvalue estimates

Domain: Applications (Proof Automation for the Catalog).

This file develops the custom tactic `spectral_bound`, which mechanizes
**Gershgorin's circle theorem**: every eigenvalue `μ` of a square matrix `A`
lies in some closed disc centered at a diagonal entry `A k k` with radius the
off-diagonal absolute row sum `∑_{j ≠ k} ‖A k j‖`.

Given a hypothesis `hμ : Module.End.HasEigenvalue (Matrix.toLin' A) μ`, the tactic
invocation `spectral_bound hμ with k hk` introduces the Gershgorin index `k` and
the unpacked bound `hk : ‖μ - A k k‖ ≤ ∑_{j ≠ k} ‖A k j‖`, ready for a concrete
finishing computation (`fin_cases k`, `simp`, `linarith`).

Soundness is inherited from Mathlib's proved `eigenvalue_mem_ball`; we record it
as `spectral_bound_sound`. We then demonstrate:

* a sharp two-sided eigenvalue localization for an explicit symmetric matrix; and
* invertibility of a strictly diagonally dominant matrix (the determinant
  corollary of Gershgorin), via `det_ne_zero_of_sum_row_lt_diag`.

## Main results

* `spectral_bound` — the custom tactic.
* `spectral_bound_sound` — soundness witness (norm form of `eigenvalue_mem_ball`).
* `eigen_localization` — every eigenvalue of `!![2,1;1,2]` satisfies `|μ - 2| ≤ 1`.
* `eigen_in_interval` — hence every real eigenvalue lies in `[1, 3]`.
* `diag_dominant_invertible` — `!![5,1,1;1,5,1;1,1,5]` has nonzero determinant.
-/

namespace Catalog.ProofAutomation.Spectral

open Matrix Module.End

/-! ## The custom tactic -/

/-- `spectral_bound h with k hk` applies Gershgorin's circle theorem to an
eigenvalue hypothesis `h : Module.End.HasEigenvalue (Matrix.toLin' A) μ`,
introducing the Gershgorin index `k` and the unpacked norm bound
`hk : ‖μ - A k k‖ ≤ ∑_{j ≠ k} ‖A k j‖`. -/
macro "spectral_bound" h:term "with" ki:ident hi:ident : tactic =>
  `(tactic| (obtain ⟨$ki:ident, $hi:ident⟩ := eigenvalue_mem_ball $h;
             rw [Metric.mem_closedBall, dist_eq_norm] at $hi:ident))

/-! ## Soundness witness -/

/-- **Soundness of `spectral_bound`.** The norm form of Gershgorin's circle
theorem: any eigenvalue `μ` of `A` admits an index `k` with
`‖μ - A k k‖ ≤ ∑_{j ≠ k} ‖A k j‖`. This is exactly the fact the tactic exposes. -/
theorem spectral_bound_sound {K m : Type*} [NormedField K] [Fintype m] [DecidableEq m]
    {A : Matrix m m K} {μ : K} (hμ : HasEigenvalue (Matrix.toLin' A) μ) :
    ∃ k, ‖μ - A k k‖ ≤ ∑ j ∈ Finset.univ.erase k, ‖A k j‖ := by
  spectral_bound hμ with k hk
  exact ⟨k, hk⟩

/-! ## Demonstration: sharp eigenvalue localization -/

/-- The explicit symmetric matrix `!![2,1;1,2]` over `ℝ` (eigenvalues `1` and `3`). -/
noncomputable def A2 : Matrix (Fin 2) (Fin 2) ℝ := !![2, 1; 1, 2]

/-- **Eigenvalue localization via `spectral_bound`.** Every eigenvalue `μ` of
`A2` satisfies `|μ - 2| ≤ 1`. The Gershgorin radius of each row is exactly `1`. -/
theorem eigen_localization (μ : ℝ) (hμ : HasEigenvalue (Matrix.toLin' A2) μ) :
    |μ - 2| ≤ 1 := by
  spectral_bound hμ with k hk
  rw [Real.norm_eq_abs] at hk
  fin_cases k <;> simpa [A2, Fin.sum_univ_succ] using hk

/-- Consequently every eigenvalue of `A2` lies in the interval `[1, 3]`. -/
theorem eigen_in_interval (μ : ℝ) (hμ : HasEigenvalue (Matrix.toLin' A2) μ) :
    1 ≤ μ ∧ μ ≤ 3 := by
  have h := eigen_localization μ hμ
  rw [abs_le] at h
  constructor <;> linarith [h.1, h.2]

/-! ## Demonstration: diagonal dominance ⇒ invertibility

Gershgorin's determinant corollary: a strictly row-diagonally-dominant matrix is
nonsingular (no eigenvalue can reach `0`). -/

/-- A strictly diagonally dominant `3×3` matrix over `ℝ`. -/
noncomputable def D3 : Matrix (Fin 3) (Fin 3) ℝ := !![5, 1, 1; 1, 5, 1; 1, 1, 5]

/-- **Diagonal dominance ⇒ invertibility.** Since each off-diagonal row sum
(`= 2`) is strictly less than the diagonal entry (`= 5`), `D3` has nonzero
determinant. -/
theorem diag_dominant_invertible : D3.det ≠ 0 := by
  apply det_ne_zero_of_sum_row_lt_diag
  intro k
  fin_cases k <;> simp [D3, Fin.sum_univ_succ, Finset.sum_erase_eq_sub] <;> norm_num

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  Eigenvalue *estimates* (as opposed to exact spectra) recur across the Catalog's
  spectral / stability files. We conjecture a single Gershgorin-based tactic can
  turn "is `μ` an eigenvalue of `A`?" into a finite localization computation, and
  that its determinant corollary mechanizes invertibility-by-diagonal-dominance.

EXPERIMENT (Experimenter).
  Wrapped Mathlib's `eigenvalue_mem_ball` as `spectral_bound h with k hk`, using
  the user-supplied identifiers to escape macro hygiene (an anonymous `⟨k, hk⟩`
  is invisible to the following `fin_cases k`). Demonstrated a SHARP bound:
  `|μ - 2| ≤ 1` for `!![2,1;1,2]`, whose true eigenvalues are `1, 3` — the
  Gershgorin disc `[1,3]` is attained, so the estimate cannot be improved by this
  method. Then proved `det ≠ 0` for a `3×3` dominant matrix through
  `det_ne_zero_of_sum_row_lt_diag`.

ANALYSIS (Analyst).
  Survived: `spectral_bound_sound`, `eigen_localization`, `eigen_in_interval`,
  `diag_dominant_invertible`. Insight: Gershgorin is *tight* exactly when the
  matrix is "balanced" (equal off-diagonal magnitudes), as in `A2`; this explains
  why the two-sided interval `[1,3]` is best-possible here. Failure mode avoided:
  forgetting to expose `k` from the macro produces an `unknown identifier k`
  error downstream — fixed by parameterizing the macro on both identifiers.

CRITIQUE (Critic).
  * Trivial? No: `eigen_localization` needs the tactic + a per-row finite-sum
    computation; `diag_dominant_invertible` needs the dominance corollary, not a
    bare `decide`/`norm_num` (the determinant is symbolic).
  * 0 sorries? Yes.
  * Real estimate, not exact spectrum? Yes — we never compute eigenvalues; we
    bound any hypothetical eigenvalue, which is the point of `spectral_bound`.
  * Corner cases: empty index type makes `HasEigenvalue` impossible (handled
    inside Mathlib's theorem); our finite examples are nonempty.

SYNTHESIS (PI).
  `spectral_bound` reduces eigenvalue questions to finite norm computations and,
  via the determinant corollary, certifies invertibility from diagonal dominance
  — a sound, reusable bridge from spectra to elementary arithmetic.
-/

end Catalog.ProofAutomation.Spectral