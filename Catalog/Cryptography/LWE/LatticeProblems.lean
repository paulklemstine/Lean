/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Worst-Case Lattice Problems: Successive Minima, GapSVP, SIVP

This module formalizes the *worst-case* lattice problems that sit on the hard end
of the Regev worst-case-to-average-case reduction for Learning with Errors (LWE):
the decisional **GapSVP** (approximate shortest vector) and the search **SIVP**
(shortest independent vectors).  Both are phrased through the *successive minima*
spectrum `λ₁ ≤ λ₂ ≤ ⋯ ≤ λ_d` of a `d`-dimensional lattice.

Rather than re-develop the full geometry of numbers, we abstract a lattice by its
successive-minima spectrum: a strictly positive, monotone family
`lam : Fin d → ℝ`.  This is faithful — successive minima of an honest lattice are
always positive and nondecreasing — and it isolates exactly the ordering data on
which the elementary lattice-problem relations depend.

## Main results

* `LatticeSpectrum.lambda1_le_lam` / `lam_le_lambdaN` — `λ₁` is the minimum and
  `λ_d` the maximum of the spectrum.
* `LatticeSpectrum.sum_lam_ge` / `sum_lam_le` — the trace of the spectrum is
  sandwiched: `d·λ₁ ≤ Σ λ_i ≤ d·λ_d`.
* `LatticeSpectrum.gapSVP_promise_disjoint` — the YES and NO promises of
  `GapSVP_γ` are genuinely disjoint whenever `γ ≥ 1`.
* `LatticeSpectrum.sivp_factor_ge_one` — any `SIVP_γ` solution forces `γ ≥ 1`.
* `LatticeSpectrum.bdd_uniqueness_gap` — the decoding radius `α·λ₁` with `α < 1/2`
  is strictly below `λ₁`, the uniqueness condition behind Bounded Distance
  Decoding (the average-case target of the reduction).

## References

* Regev, "On Lattices, Learning with Errors, Random Linear Codes, and
  Cryptography", STOC 2005 / JACM 2009.
* Micciancio & Regev, "Worst-Case to Average-Case Reductions Based on Gaussian
  Measures", SIAM J. Comput. 2007.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the elementary content of the lattice problems
GapSVP and SIVP is *entirely order-theoretic* once we fix the successive-minima
spectrum; the geometry only enters when relating the spectrum to Gaussian
measures (handled in `DiscreteGaussian.lean`).

Experiment (Experimenter): encode a lattice as a positive monotone spectrum
`lam : Fin d → ℝ`; derive min/max characterisations of `λ₁, λ_d`; the trace
sandwich; promise-disjointness of `GapSVP_γ`; and the BDD uniqueness gap.

Analysis (Analyst): all five survive with `monotone`/`nlinarith`/`omega`
reasoning.  Deeper transference inequalities (`λ₁(L)·λ_d(L*) ≤ d`) need the dual
lattice and are *true but hard* at this abstraction level — flagged for
`FUTURE_DIRECTIONS`.

Critique (Critic): `sum_lam_ge/le` are non-trivial (they combine the min/max
lemmas with `Finset.sum_le_sum`); `sivp_factor_ge_one` extracts a genuine
inequality on `γ`.  None reduce to `rfl`/`decide`.

Synthesis (PI): the spectrum abstraction cleanly packages the worst-case side of
the reduction and feeds the parameter arithmetic in `RegevParameters.lean`.
-- !-- Lab Notes -- !--
-/

open Finset BigOperators

noncomputable section

/-- A `d`-dimensional lattice, abstracted by its successive-minima spectrum:
a strictly positive, monotone family `λ₁ ≤ λ₂ ≤ ⋯ ≤ λ_d`. -/
structure LatticeSpectrum (d : ℕ) where
  /-- The successive minima `λ₁, …, λ_d`. -/
  lam : Fin d → ℝ
  /-- Every successive minimum is strictly positive. -/
  pos : ∀ i, 0 < lam i
  /-- The successive minima are nondecreasing. -/
  mono : Monotone lam

namespace LatticeSpectrum

variable {d : ℕ} (L : LatticeSpectrum d)

/-- The first minimum `λ₁`, the length of a shortest nonzero lattice vector. -/
def lambda1 (hd : 0 < d) : ℝ := L.lam ⟨0, hd⟩

/-- The last minimum `λ_d`, the smallest radius containing `d` independent
lattice vectors. -/
def lambdaN (hd : 0 < d) : ℝ := L.lam ⟨d - 1, by omega⟩

theorem lambda1_pos (hd : 0 < d) : 0 < L.lambda1 hd := L.pos _

theorem lambdaN_pos (hd : 0 < d) : 0 < L.lambdaN hd := L.pos _

/-- `λ₁` is the minimum of the spectrum. -/
theorem lambda1_le_lam (hd : 0 < d) (i : Fin d) : L.lambda1 hd ≤ L.lam i := by
  apply L.mono; exact Fin.mk_le_of_le_val (Nat.zero_le _)

/-- `λ_d` is the maximum of the spectrum. -/
theorem lam_le_lambdaN (hd : 0 < d) (i : Fin d) : L.lam i ≤ L.lambdaN hd := by
  apply L.mono
  refine Fin.le_def.mpr ?_
  have : i.val ≤ d - 1 := by omega
  simpa using this

/-- The shortest vector is no longer than the longest successive minimum. -/
theorem lambda1_le_lambdaN (hd : 0 < d) : L.lambda1 hd ≤ L.lambdaN hd :=
  L.lambda1_le_lam hd _

/-- Trace lower bound: `d·λ₁ ≤ Σ λ_i`. -/
theorem sum_lam_ge (hd : 0 < d) : (d : ℝ) * L.lambda1 hd ≤ ∑ i, L.lam i := by
  calc (d : ℝ) * L.lambda1 hd = ∑ _i : Fin d, L.lambda1 hd := by
        rw [Finset.sum_const]; simp
    _ ≤ ∑ i, L.lam i := Finset.sum_le_sum (fun i _ => L.lambda1_le_lam hd i)

/-- Trace upper bound: `Σ λ_i ≤ d·λ_d`. -/
theorem sum_lam_le (hd : 0 < d) : ∑ i, L.lam i ≤ (d : ℝ) * L.lambdaN hd := by
  calc ∑ i, L.lam i ≤ ∑ _i : Fin d, L.lambdaN hd :=
          Finset.sum_le_sum (fun i _ => L.lam_le_lambdaN hd i)
    _ = (d : ℝ) * L.lambdaN hd := by rw [Finset.sum_const]; simp

/-! ## GapSVP: the decisional approximate shortest vector problem -/

/-- A `GapSVP_γ` YES instance (relative to threshold `β`): the shortest vector has
length at most `β`. -/
def GapSVPyes (hd : 0 < d) (β : ℝ) : Prop := L.lambda1 hd ≤ β

/-- A `GapSVP_γ` NO instance (relative to threshold `β`): the shortest vector has
length strictly greater than `γ·β`. -/
def GapSVPno (hd : 0 < d) (β γ : ℝ) : Prop := γ * β < L.lambda1 hd

/-- **Promise disjointness.**  For any gap factor `γ ≥ 1` and positive threshold,
no lattice is simultaneously a YES and a NO instance of `GapSVP_γ`: the promise
gap is well-defined. -/
theorem gapSVP_promise_disjoint (hd : 0 < d) (β γ : ℝ) (hβ : 0 < β) (hγ : 1 ≤ γ)
    (hyes : L.GapSVPyes hd β) (hno : L.GapSVPno hd β γ) : False := by
  unfold GapSVPyes GapSVPno at *
  nlinarith

/-! ## SIVP: the shortest independent vectors problem -/

/-- A candidate solution to `SIVP_γ`: a bundle of `d` independent lattice vectors,
recorded by their maximum length `maxLen`.  Independence forces the max length to
be at least `λ_d`; the `SIVP_γ` guarantee caps it at `γ·λ_d`. -/
structure SIVPSolution (hd : 0 < d) (γ : ℝ) where
  /-- The largest length among the `d` returned independent vectors. -/
  maxLen : ℝ
  /-- Independence lower bound: `d` independent vectors reach out to at least
  `λ_d`. -/
  indep_lb : L.lambdaN hd ≤ maxLen
  /-- Approximation guarantee: all returned vectors are within `γ·λ_d`. -/
  approx_ub : maxLen ≤ γ * L.lambdaN hd

/-- Any `SIVP_γ` solution witnesses `γ ≥ 1`: you cannot approximate the last
minimum below itself. -/
theorem sivp_factor_ge_one (hd : 0 < d) (γ : ℝ) (sol : L.SIVPSolution hd γ) :
    1 ≤ γ := by
  have h1 := sol.indep_lb
  have h2 := sol.approx_ub
  have hpos := L.lambdaN_pos hd
  nlinarith

/-! ## BDD: the average-case decoding target -/

/-- **Bounded Distance Decoding uniqueness gap.**  When the decoding radius is
`α·λ₁` with `α < 1/2`, the diameter `2·α·λ₁` of the ambiguity ball is strictly
below `λ₁`, so a closest lattice point is unique.  This is precisely the
correctness condition for the LWE decoding oracle that the reduction invokes. -/
theorem bdd_uniqueness_gap (hd : 0 < d) (α : ℝ) (hα2 : α < 1 / 2) :
    2 * α * L.lambda1 hd < L.lambda1 hd := by
  have := L.lambda1_pos hd
  nlinarith

end LatticeSpectrum

end