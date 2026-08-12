import Mathlib
import Computation.QuantumClassicalBoundary.SpectralHiding

/-!
# Cycle 3: a general criterion for the fundamental being spectrally hidden

`SpectralHiding.lean` proved Barrier 2 for the single instance `N = 15, a = 7`.
This file generalises that computation to *every* modulus and base of order `4`:
the two competing bins of the value signal are computed in closed form,

  `‖V̂(1)‖ = √((v₀-v₂)² + (v₁-v₃)²)`,  `‖V̂(2)‖ = √((v₀-v₁+v₂-v₃)²)`,

where `vᵢ = aⁱ mod N`.  This turns "is the period hidden in the harmonics?" into
an elementary integer inequality (`fundamental_dominated_criterion`) which can be
checked for any concrete instance by `norm_num`, and which the exhaustive scan in
`ComputationalEvidence.md` shows holds for `684` of the `1870` order-`4`
instances with `N < 500` (36.6%).

Instances verified here: `(15,7)`, `(20,13)`, `(39,31)`, `(15,13)`.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): the `N = 15` failure is not a coincidence of one
  instance but the generic behaviour; there should be a closed-form criterion.
* Experiment (Experimenter): computed both bins symbolically from `ζ₄ = i` with
  the residues left as free naturals.  The fundamental is a genuinely complex
  number with real part `v₀-v₂` and imaginary part `v₁-v₃`; the second harmonic
  is *real*, equal to the alternating sum.  The criterion is therefore
  `(v₀-v₁+v₂-v₃)² > (v₀-v₂)² + (v₁-v₃)²`, an inequality between integers.
* Analysis (Analyst): the criterion says the fundamental loses whenever the
  residues pair up "antipodally" (`v₀ ≈ v₂`, `v₁ ≈ v₃`) while the alternating
  sum stays large — precisely the pseudorandom behaviour of `aˣ mod N`.
* Critique (Critic): the criterion is exact and general for order `4`; for
  general order the analogous statement requires `r`-th roots of unity and is
  left as a future direction.  No asymptotic claim is made here.
* Synthesis (PI): Barrier 2 upgraded from a single example to a decidable family
  criterion plus four verified instances.
-/

namespace QuantumClassicalBoundary

open Finset FourierTransformInversion

/-- The residues `aⁱ mod N` of the value signal, as reals. -/
noncomputable def resid (N a i : ℕ) : ℝ := ((a ^ i % N : ℕ) : ℝ)

/-- Closed form of the fundamental bin of an order-`4` value signal. -/
theorem dft_order_four_one (N a : ℕ) :
    DFT (zeta 4) (modExpSignal N a 4) 1 =
      ((resid N a 0 - resid N a 2 : ℝ) : ℂ)
        + ((resid N a 1 - resid N a 3 : ℝ) : ℂ) * Complex.I := by
  simp [DFT, modExpSignal, Fin.sum_univ_four, zeta_four, pow_succ, Complex.I_mul_I, resid]
  ring

/-- Closed form of the second harmonic of an order-`4` value signal: it is real,
equal to the alternating sum of the residues. -/
theorem dft_order_four_two (N a : ℕ) :
    DFT (zeta 4) (modExpSignal N a 4) 2 =
      ((resid N a 0 - resid N a 1 + resid N a 2 - resid N a 3 : ℝ) : ℂ) := by
  simp [DFT, modExpSignal, Fin.sum_univ_four, zeta_four, pow_succ, Complex.I_mul_I, resid]
  ring

/-- Modulus of the fundamental bin. -/
theorem norm_dft_order_four_one (N a : ℕ) :
    ‖DFT (zeta 4) (modExpSignal N a 4) 1‖ =
      Real.sqrt ((resid N a 0 - resid N a 2) ^ 2 + (resid N a 1 - resid N a 3) ^ 2) := by
  rw [dft_order_four_one, Complex.norm_def, Complex.normSq_apply]
  simp
  ring_nf

/-- Modulus of the second harmonic. -/
theorem norm_dft_order_four_two (N a : ℕ) :
    ‖DFT (zeta 4) (modExpSignal N a 4) 2‖ =
      Real.sqrt ((resid N a 0 - resid N a 1 + resid N a 2 - resid N a 3) ^ 2) := by
  rw [dft_order_four_two, Complex.norm_real, Real.sqrt_sq_eq_abs, Real.norm_eq_abs]

/-- **General criterion for spectral hiding at order 4.**  The fundamental bin of
the value signal `x ↦ aˣ mod N` is strictly dominated by the second harmonic
exactly when the integer inequality `(v₀-v₁+v₂-v₃)² > (v₀-v₂)² + (v₁-v₃)²` holds
for the residues `vᵢ = aⁱ mod N`. -/
theorem fundamental_dominated_criterion (N a : ℕ)
    (h : (resid N a 0 - resid N a 2) ^ 2 + (resid N a 1 - resid N a 3) ^ 2
      < (resid N a 0 - resid N a 1 + resid N a 2 - resid N a 3) ^ 2) :
    ‖DFT (zeta 4) (modExpSignal N a 4) 1‖ < ‖DFT (zeta 4) (modExpSignal N a 4) 2‖ := by
  rw [norm_dft_order_four_one, norm_dft_order_four_two]
  exact Real.sqrt_lt_sqrt (by positivity) h

/-- The criterion is *sharp in the other direction* too: when the inequality is
reversed the fundamental does dominate, so the criterion decides the comparison. -/
theorem harmonic_dominated_criterion (N a : ℕ)
    (h : (resid N a 0 - resid N a 1 + resid N a 2 - resid N a 3) ^ 2
      < (resid N a 0 - resid N a 2) ^ 2 + (resid N a 1 - resid N a 3) ^ 2) :
    ‖DFT (zeta 4) (modExpSignal N a 4) 2‖ < ‖DFT (zeta 4) (modExpSignal N a 4) 1‖ := by
  rw [norm_dft_order_four_one, norm_dft_order_four_two]
  exact Real.sqrt_lt_sqrt (by positivity) h

/-! ## Verified instances -/

/-- `N = 15, a = 7`: residues `1, 7, 4, 13`; `45 < 225`. -/
theorem hidden_15_7 :
    ‖DFT (zeta 4) (modExpSignal 15 7 4) 1‖ < ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖ := by
  refine fundamental_dominated_criterion 15 7 ?_
  norm_num [resid]

/-- `N = 15, a = 13`: residues `1, 13, 4, 7`; `45 < 225`. -/
theorem hidden_15_13 :
    ‖DFT (zeta 4) (modExpSignal 15 13 4) 1‖ < ‖DFT (zeta 4) (modExpSignal 15 13 4) 2‖ := by
  refine fundamental_dominated_criterion 15 13 ?_
  norm_num [resid]

/-- `N = 20, a = 13`: residues `1, 13, 9, 17`; `80 < 400`. -/
theorem hidden_20_13 :
    ‖DFT (zeta 4) (modExpSignal 20 13 4) 1‖ < ‖DFT (zeta 4) (modExpSignal 20 13 4) 2‖ := by
  refine fundamental_dominated_criterion 20 13 ?_
  norm_num [resid]

/-- `N = 39, a = 31`: residues `1, 31, 25, 34`; `585 < 1521`. -/
theorem hidden_39_31 :
    ‖DFT (zeta 4) (modExpSignal 39 31 4) 1‖ < ‖DFT (zeta 4) (modExpSignal 39 31 4) 2‖ := by
  refine fundamental_dominated_criterion 39 31 ?_
  norm_num [resid]

/-- All four instances really have multiplicative order `4`, so the signals are
genuine period-`4` signals and the comparison is meaningful. -/
theorem verified_instances_have_order_four :
    (7 ^ 4 % 15 = 1 ∧ 7 ^ 2 % 15 ≠ 1) ∧ (13 ^ 4 % 15 = 1 ∧ 13 ^ 2 % 15 ≠ 1) ∧
      (13 ^ 4 % 20 = 1 ∧ 13 ^ 2 % 20 ≠ 1) ∧ (31 ^ 4 % 39 = 1 ∧ 31 ^ 2 % 39 ≠ 1) := by
  refine ⟨⟨by norm_num, by norm_num⟩, ⟨by norm_num, by norm_num⟩,
    ⟨by norm_num, by norm_num⟩, ⟨by norm_num, by norm_num⟩⟩

end QuantumClassicalBoundary