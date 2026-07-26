/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cancellation of the leading correction in a spectral heat-kernel expansion

Consider a quantum system whose unperturbed Hamiltonian has a discrete spectrum
`E : Fin n → ℝ` and which is deformed by a small perturbation of strength `1/N`.
First-order (Rayleigh–Schrödinger / Feynman–Hellmann) perturbation theory shifts
each energy level by its diagonal matrix element `dᵢ = ⟨i|V|i⟩`, so the leading
`1/N` correction to the heat-kernel trace `Z(t) = Tr e^{-tH}` is the spectral
function

  `L(t) = ∑ᵢ dᵢ · e^{-t Eᵢ}`.

This file characterises **exactly when the leading `1/N` term cancels**, i.e. when
`L(t) = 0` for every inverse temperature `t`.

## Main results

* `heatKernelLeading_trace` — evaluating at `t = 0` recovers the trace of the
  perturbation: `L(0) = ∑ᵢ dᵢ`.
* `trace_zero_of_leading_vanishes` — if the leading term cancels for all `t`,
  then the perturbation is traceless.
* `diag_zero_of_leading_vanishes` — **(non-degenerate spectrum)** if the levels
  `Eᵢ` are distinct and the leading term cancels for all `t`, then *every*
  diagonal matrix element vanishes. The proof turns the analytic vanishing into
  a Vandermonde linear system by sampling `t = 0, 1, 2, …` and using the
  distinctness of `e^{-Eᵢ}`.
* `heatKernelLeading_vanishes_iff` — **(non-degenerate spectrum)** the leading
  term cancels for all `t` **iff** the perturbation is diagonal-free.
* `heatKernelLeading_vanishes_iff_levelSums` — **(general spectrum, allowing
  degeneracy)** the leading term cancels for all `t` **iff** the sum of diagonal
  matrix elements over each degenerate energy level is zero. This is the sharp
  form: cancellation happens level-by-level, not term-by-term.
* `leading_vanishes_of_level_antisymmetric` — a concrete two-level illustration:
  a degenerate doublet with opposite diagonal matrix elements cancels identically.

## Tags
heat kernel, spectral expansion, perturbation theory, leading term cancellation,
Vandermonde, degeneracy, large-N

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).**  In a large-`N` expansion of a heat-kernel trace,
the leading `1/N` correction is the spectral sum `L(t) = ∑ᵢ dᵢ e^{-tEᵢ}` with
`dᵢ` the first-order level shift. We conjectured that this leading term cannot
vanish "by accident": for a non-degenerate spectrum it must vanish term-by-term,
and in general the only mechanism is cancellation *within* each degenerate level.

**Experiment (Experimenter).**  Two-level check with `E = (a,a)` (degenerate) and
`d = (c, -c)`: `L(t) = c e^{-ta} - c e^{-ta} = 0` for all `t` ✓, even though no
individual `dᵢ` vanishes. With distinct levels `E = (0,1)` and `d = (1,-1)`:
`L(t) = 1 - e^{-t}`, which is nonzero for `t > 0` — cancellation fails, matching
the prediction that distinct levels forbid nontrivial cancellation.

**Analysis (Analyst).**  Sampling `L` at natural-number values of `t` converts
the transcendental identity into `∑ᵢ dᵢ xᵢ^k = 0` for all `k`, where
`xᵢ = e^{-Eᵢ}`. Distinct levels give distinct positive `xᵢ`, so the coefficient
vector lies in the kernel of an invertible Vandermonde matrix and must be zero.
Degeneracy is handled by pushing the identity forward to the (distinct) set of
energy values; the fibre sums become the new coefficients.

**Critique (Critic).**  The non-degenerate hypothesis is genuinely needed: the
two-level degenerate example is a nonzero coefficient vector with `L ≡ 0`, so
`diag_zero_of_leading_vanishes` is false without injectivity of `E`. The general
theorem `heatKernelLeading_vanishes_iff_levelSums` is the guarded, sharp version.
No result is vacuous: each direction is exhibited on explicit spectra above.

**Synthesis (PI).**  The leading `1/N` term is a linear combination of the
linearly-independent functions `t ↦ e^{-tEᵢ}` grouped by level; its cancellation
is equivalent to the vanishing of each level's aggregate diagonal shift. This is
a clean bridge between spectral analysis (exponential linear independence),
linear algebra (Vandermonde), and the combinatorics of spectral degeneracy.
-/
import Mathlib

open scoped BigOperators
open Matrix

namespace Catalog.Novelty.HeatKernelLeadingTerm

/-- The leading `1/N` correction to the heat-kernel trace: with unperturbed
energy levels `E` and first-order diagonal shifts `d`, this is the spectral
function `L(t) = ∑ᵢ dᵢ e^{-t Eᵢ}`. -/
noncomputable def heatKernelLeading {n : ℕ} (E d : Fin n → ℝ) (t : ℝ) : ℝ :=
  ∑ i, d i * Real.exp (-(t * E i))

/-- At `t = 0` the leading term is the trace of the perturbation. -/
theorem heatKernelLeading_trace {n : ℕ} (E d : Fin n → ℝ) :
    heatKernelLeading E d 0 = ∑ i, d i := by
  simp [heatKernelLeading]

/-- If the leading term cancels for all `t`, the perturbation is traceless. -/
theorem trace_zero_of_leading_vanishes {n : ℕ} (E d : Fin n → ℝ)
    (h : ∀ t : ℝ, heatKernelLeading E d t = 0) : ∑ i, d i = 0 := by
  rw [← heatKernelLeading_trace E d]; exact h 0

/-- **Core cancellation lemma (Vandermonde form).**  If the energy levels are
distinct and the leading spectral sum `∑ᵢ dᵢ e^{-tEᵢ}` vanishes for every `t`,
then every coefficient `dᵢ` is zero.  The transcendental identity is sampled at
`t = 0, 1, 2, …`, turning it into a Vandermonde linear system in the distinct
positive numbers `e^{-Eᵢ}`. -/
theorem diag_zero_of_leading_vanishes_fin {n : ℕ} (E d : Fin n → ℝ)
    (hE : Function.Injective E)
    (h : ∀ t : ℝ, ∑ i, d i * Real.exp (-(t * E i)) = 0) : ∀ i, d i = 0 := by
  classical
  set x : Fin n → ℝ := fun i => Real.exp (-E i) with hx
  have hxinj : Function.Injective x := by
    intro a b hab; apply hE; have := Real.exp_injective hab; linarith
  -- The identity, sampled at natural `t = k`, becomes a vanishing moment.
  have hmom : ∀ k : ℕ, ∑ i, x i ^ k * d i = 0 := by
    intro k
    have hk := h (k : ℝ); rw [← hk]
    apply Finset.sum_congr rfl; intro i _; rw [hx]
    have h2 : Real.exp (-(↑k * E i)) = Real.exp (-E i) ^ k := by
      rw [← Real.exp_nat_mul]; ring_nf
    rw [h2]; ring
  -- Assemble the (transposed) Vandermonde matrix and read off `M · d = 0`.
  set M : Matrix (Fin n) (Fin n) ℝ := (Matrix.vandermonde x)ᵀ with hM
  have hMv : M.mulVec d = 0 := by
    funext k
    rw [show M.mulVec d k = ∑ j, M k j * d j by simp [Matrix.mulVec, dotProduct]]
    simp only [hM, Matrix.transpose_apply, Matrix.vandermonde_apply, Pi.zero_apply]
    exact hmom k
  have hdet : M.det ≠ 0 := by
    rw [hM, Matrix.det_transpose, Matrix.det_vandermonde]
    apply Finset.prod_ne_zero_iff.mpr; intro i _
    apply Finset.prod_ne_zero_iff.mpr; intro j hj
    have hij : i ≠ j := by simp only [Finset.mem_Ioi] at hj; exact ne_of_lt hj
    exact sub_ne_zero.mpr (fun hxx => hij (hxinj hxx).symm)
  by_contra hcon
  push_neg at hcon
  obtain ⟨i0, hi0⟩ := hcon
  have hdne : d ≠ 0 := fun hd0 => hi0 (by rw [hd0]; rfl)
  have hex : ∃ v, v ≠ 0 ∧ M.mulVec v = 0 := ⟨d, hdne, hMv⟩
  rw [Matrix.exists_mulVec_eq_zero_iff] at hex
  exact hdet hex

/-- Fintype-indexed version of the core cancellation lemma, obtained by
transporting along an equivalence with `Fin (card ι)`. -/
theorem diag_zero_of_leading_vanishes_fintype {ι : Type*} [Fintype ι]
    (E d : ι → ℝ) (hE : Function.Injective E)
    (h : ∀ t : ℝ, ∑ i, d i * Real.exp (-(t * E i)) = 0) : ∀ i, d i = 0 := by
  classical
  set e := Fintype.equivFin ι with he
  set E' : Fin (Fintype.card ι) → ℝ := fun k => E (e.symm k) with hE'
  set d' : Fin (Fintype.card ι) → ℝ := fun k => d (e.symm k) with hd'
  have hE'inj : Function.Injective E' := by
    intro a b hab
    exact e.symm.injective (hE (show E (e.symm a) = E (e.symm b) from hab))
  have h' : ∀ t : ℝ, ∑ k, d' k * Real.exp (-(t * E' k)) = 0 := by
    intro t
    rw [← h t]
    exact Equiv.sum_comp e.symm (fun i => d i * Real.exp (-(t * E i)))
  have hcore := diag_zero_of_leading_vanishes_fin E' d' hE'inj h'
  intro i
  have := hcore (e i)
  simpa only [hd', Equiv.symm_apply_apply] using this

/-- Convenience restatement in terms of `heatKernelLeading` for a non-degenerate
spectrum. -/
theorem diag_zero_of_leading_vanishes {n : ℕ} (E d : Fin n → ℝ)
    (hE : Function.Injective E)
    (h : ∀ t : ℝ, heatKernelLeading E d t = 0) : ∀ i, d i = 0 :=
  diag_zero_of_leading_vanishes_fin E d hE h

/-- **Leading-term cancellation, non-degenerate spectrum.**  When all energy
levels are distinct, the leading `1/N` term cancels for every `t` if and only if
every diagonal matrix element of the perturbation vanishes. -/
theorem heatKernelLeading_vanishes_iff {n : ℕ} (E d : Fin n → ℝ)
    (hE : Function.Injective E) :
    (∀ t : ℝ, heatKernelLeading E d t = 0) ↔ (∀ i, d i = 0) := by
  constructor
  · exact diag_zero_of_leading_vanishes E d hE
  · intro hd t; simp [heatKernelLeading, hd]

/-- Fibrewise decomposition of the leading term by energy value: contributions
are grouped over each (possibly degenerate) energy level. -/
theorem heatKernelLeading_level_decomp {n : ℕ} (E d : Fin n → ℝ) (t : ℝ) :
    heatKernelLeading E d t
      = ∑ v ∈ Finset.univ.image E,
          Real.exp (-(t * v)) * ∑ j ∈ Finset.univ.filter (fun j => E j = v), d j := by
  rw [heatKernelLeading,
    ← Finset.sum_fiberwise_of_maps_to (t := Finset.univ.image E) (g := E)
        (f := fun i => d i * Real.exp (-(t * E i)))
        (fun i _ => Finset.mem_image_of_mem E (Finset.mem_univ i))]
  apply Finset.sum_congr rfl
  intro v _; rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj; simp only [Finset.mem_filter] at hj; rw [hj.2]; ring

/-- **Leading-term cancellation, general (possibly degenerate) spectrum.**  The
leading `1/N` term cancels for every `t` if and only if, for each energy level,
the aggregate diagonal shift over that level vanishes.  Cancellation is a
level-by-level phenomenon: it may occur without any single `dᵢ` being zero, but
only through exact balance inside each degeneracy subspace. -/
theorem heatKernelLeading_vanishes_iff_levelSums {n : ℕ} (E d : Fin n → ℝ) :
    (∀ t : ℝ, heatKernelLeading E d t = 0) ↔
    (∀ i, ∑ j ∈ Finset.univ.filter (fun j => E j = E i), d j = 0) := by
  classical
  constructor
  · intro h
    have hEhatinj : Function.Injective (fun v : ↥(Finset.univ.image E) => (v : ℝ)) :=
      fun a b hab => Subtype.ext hab
    have hsum : ∀ t : ℝ,
        ∑ v : ↥(Finset.univ.image E),
          (∑ j ∈ Finset.univ.filter (fun j => E j = (v : ℝ)), d j) *
            Real.exp (-(t * (v : ℝ))) = 0 := by
      intro t
      rw [Finset.sum_coe_sort (Finset.univ.image E)
        (fun r => (∑ j ∈ Finset.univ.filter (fun j => E j = r), d j) * Real.exp (-(t * r)))]
      rw [← (h t), heatKernelLeading_level_decomp E d t]
      apply Finset.sum_congr rfl
      intro v _; ring
    have hc := diag_zero_of_leading_vanishes_fintype
      (fun v : ↥(Finset.univ.image E) => (v : ℝ))
      (fun v => ∑ j ∈ Finset.univ.filter (fun j => E j = (v : ℝ)), d j) hEhatinj hsum
    intro i
    exact hc ⟨E i, Finset.mem_image_of_mem E (Finset.mem_univ i)⟩
  · intro hfib t
    rw [heatKernelLeading_level_decomp E d t]
    apply Finset.sum_eq_zero
    intro v hv
    simp only [Finset.mem_image] at hv
    obtain ⟨i, _, rfl⟩ := hv
    rw [hfib i]; ring

/-- Concrete degenerate illustration: a two-level doublet sharing a common energy
`a`, carrying opposite diagonal matrix elements `c` and `-c`, cancels the leading
term identically — a nontrivial cancellation with no individual coefficient zero
(for `c ≠ 0`). -/
theorem leading_vanishes_of_level_antisymmetric (a c : ℝ) :
    ∀ t : ℝ, heatKernelLeading (![a, a]) (![c, -c]) t = 0 := by
  intro t
  rw [heatKernelLeading, Fin.sum_univ_two]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- Sharpness: with **distinct** levels `0` and `1`, the antisymmetric doublet
`d = (1,-1)` does *not* cancel — the leading term is `1 - e^{-t}`, nonzero at
`t = 1`.  This shows the non-degeneracy hypothesis in
`heatKernelLeading_vanishes_iff` cannot be dropped. -/
theorem leading_nonvanishing_distinct_levels :
    ¬ (∀ t : ℝ, heatKernelLeading (![0, 1]) (![1, -1]) t = 0) := by
  intro h
  have h1 := h 1
  simp [heatKernelLeading, Fin.sum_univ_two] at h1
  -- h1 : 1 = Real.exp (-1)  (or similar); contradict via exp bound
  have : Real.exp (-1) < 1 := by
    have := Real.exp_lt_one_iff.mpr (by norm_num : (-1 : ℝ) < 0)
    linarith
  linarith [h1]

end Catalog.Novelty.HeatKernelLeadingTerm