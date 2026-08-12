import Mathlib
import Computation.FourierTransformInversion

/-!
# The Coherent Comb: why the quantum Fourier transform produces a sharp peak

This file formalises the *quantum* side of the quantum–classical boundary in
period finding.  After the modular-exponentiation register of Shor's circuit is
measured (or simply traced out), the input register is left in the **coherent
comb** state

  `|x₀⟩ + |x₀ + r⟩ + |x₀ + 2r⟩ + ⋯ + |x₀ + (m-1) r⟩`,  where `n = m · r`,

an equal superposition supported on an arithmetic progression of step `r`.  The
quantum Fourier transform of this state is computed here exactly:

* `combDFT_eq` — the transform factors as a phase times a geometric sum;
* `combDFT_norm` — **sharp peak theorem**: the amplitude has modulus `m = n / r`
  at every frequency divisible by `m`, and is *exactly zero* everywhere else;
* `combDFT_energy` — Parseval bookkeeping: all of the energy `n · m` sits on the
  `r` peak frequencies;
* `peak_card` — there are exactly `r` peaks in `range n`;
* `combDFT_harmonics_equal` — the `r` peaks all carry the *same* modulus, so
  there is no distinguished "fundamental" bin even in the coherent case;
* `period_from_peak` — Shor's classical post-processing: a peak `k = j·m` with
  `gcd j r = 1` determines `r` as the denominator of the reduced fraction `k/n`.

The Fourier mathematics is *identical* to the classical DFT: the engine is the
character orthogonality already verified in
`Computation.FourierTransformInversion` (`geom_root_sum`), which we import and
reuse verbatim.  What differs is the *state* the transform is applied to: a
coherent comb (here) versus `K` independent classical samples of `x ↦ aˣ mod N`
(file `SpectralHiding.lean`).

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): the entire quantum advantage in period finding is
  the ability to present the Fourier transform with a *comb*, i.e. an indicator
  of an arithmetic progression, rather than with the value signal
  `x ↦ aˣ mod N`.  Concretely: the comb spectrum should be a perfect Dirac comb
  (zero off the peaks), while the value signal spectrum should be diffuse.
* Experiment (Experimenter): computed `combDFT` exactly.  The reduction
  `ζ_{mr}^{r} = ζ_m` collapses the double index, and `geom_root_sum` (imported
  from the DFT-inversion file) kills every non-peak bin *identically*, not
  merely approximately.  Confirmed `‖combDFT‖ ∈ {0, m}`.
* Analysis (Analyst): the peak height `m = n/r` is the largest possible value of
  a sum of `m` unit-modulus terms, so the comb saturates the triangle
  inequality: coherence is exactly the statement that the `m` phases align.
  Notably the `r` peaks are *equal*, so peak-ranking alone never singles out the
  fundamental; Shor does not need it, because continued fractions recover `r`
  from any `j·m` with `gcd(j,r)=1` (`period_from_peak`).
* Critique (Critic): the theorem needs `r ∣ n` (exact comb).  This is the
  idealised Shor setting; with `r ∤ n` the peaks broaden into Dirichlet kernels
  and the statement becomes approximate.  We therefore state the *exact*
  hypothesis explicitly rather than hiding it, and `m ≠ 0`, `r ≠ 0` are genuine
  (for `m = 0` the state is empty).
* Synthesis (PI): coherence converts "`K ≥ r` samples" into "one query", because
  the comb is produced by a single evaluation of `aˣ mod N` on a superposition.
-/

namespace QuantumClassicalBoundary

open Finset

/-! ## The `n`-th root of unity -/

/-- The standard primitive `n`-th root of unity `exp(2πi/n)`. -/
noncomputable def zeta (n : ℕ) : ℂ := Complex.exp (2 * Real.pi * Complex.I / n)

theorem zeta_isPrimitiveRoot {n : ℕ} (hn : n ≠ 0) : IsPrimitiveRoot (zeta n) n :=
  Complex.isPrimitiveRoot_exp n hn

theorem norm_zeta (n : ℕ) : ‖zeta n‖ = 1 := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · simp [zeta, hn]
  · have : (2 * (Real.pi : ℂ) * Complex.I / n) = ((2 * Real.pi / n : ℝ) : ℂ) * Complex.I := by
      push_cast; ring
    rw [zeta, this, Complex.norm_exp_ofReal_mul_I]

theorem norm_zeta_pow (n k : ℕ) : ‖zeta n ^ k‖ = 1 := by
  rw [norm_pow, norm_zeta, one_pow]

/-- Collapsing the comb spacing: `ζ_{m·r}^r = ζ_m`. -/
theorem zeta_pow_spacing (m r : ℕ) (hr : r ≠ 0) : zeta (m * r) ^ r = zeta m := by
  rcases Nat.eq_zero_or_pos m with hm | hm
  · simp [zeta, hm]
  · rw [zeta, zeta, ← Complex.exp_nat_mul]
    congr 1
    have hm' : (m : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hm.ne'
    have hr' : (r : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hr
    push_cast
    field_simp

/-! ## The comb state and its transform -/

/-- The (unnormalised) quantum Fourier amplitude at frequency `k` of the coherent
comb `∑_{j<m} |x₀ + j·r⟩` living in a register of dimension `n = m · r`. -/
noncomputable def combDFT (m r x0 k : ℕ) : ℂ :=
  ∑ j ∈ range m, zeta (m * r) ^ ((x0 + j * r) * k)

/-- The geometric core: the character sum over the comb teeth. -/
theorem comb_geom_sum {m : ℕ} (hm : m ≠ 0) (k : ℕ) :
    ∑ j ∈ range m, (zeta m ^ k) ^ j = if m ∣ k then (m : ℂ) else 0 := by
  by_cases hdvd : m ∣ k
  · have h1 : zeta m ^ k = 1 := ((zeta_isPrimitiveRoot hm).pow_eq_one_iff_dvd k).mpr hdvd
    rw [h1]; simp [hdvd]
  · have h1 : zeta m ^ k ≠ 1 := fun h =>
      hdvd (((zeta_isPrimitiveRoot hm).pow_eq_one_iff_dvd k).mp h)
    have h2 : (zeta m ^ k) ^ m = 1 := by
      rw [← pow_mul, mul_comm, pow_mul, (zeta_isPrimitiveRoot hm).pow_eq_one, one_pow]
    simp [hdvd, FourierTransformInversion.geom_root_sum _ h2 h1]

/-- **Factorisation of the comb transform**: a global phase times the geometric
character sum over the `m` teeth. -/
theorem combDFT_eq {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 k : ℕ) :
    combDFT m r x0 k = zeta (m * r) ^ (x0 * k) * (if m ∣ k then (m : ℂ) else 0) := by
  rw [combDFT, ← comb_geom_sum hm k, mul_sum]
  refine sum_congr rfl fun j _ => ?_
  have h : (x0 + j * r) * k = x0 * k + r * (j * k) := by ring
  rw [h, pow_add]
  congr 1
  rw [pow_mul, zeta_pow_spacing m r hr, ← pow_mul, Nat.mul_comm j k]

/-- **Sharp peak theorem.**  The quantum Fourier transform of a coherent comb of
`m = n/r` teeth is a perfect Dirac comb: its modulus is `m` at every frequency
divisible by `m`, and *identically zero* at every other frequency. -/
theorem combDFT_norm {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 k : ℕ) :
    ‖combDFT m r x0 k‖ = if m ∣ k then (m : ℝ) else 0 := by
  rw [combDFT_eq hm hr, norm_mul, norm_zeta_pow]
  by_cases hdvd : m ∣ k <;> simp [hdvd]

/-- Off-peak bins vanish exactly. -/
theorem combDFT_offpeak {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 k : ℕ) (hk : ¬ m ∣ k) :
    combDFT m r x0 k = 0 := by
  rw [combDFT_eq hm hr]; simp [hk]

/-- On-peak bins saturate the triangle inequality: coherence aligns all `m`
phases, giving the maximum possible modulus for a sum of `m` unit vectors. -/
theorem combDFT_peak {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 j : ℕ) :
    ‖combDFT m r x0 (j * m)‖ = (m : ℝ) := by
  rw [combDFT_norm hm hr]; simp [dvd_mul_left m j]

/-- The comb transform can never exceed `m`; the peaks attain this bound. -/
theorem combDFT_norm_le {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 k : ℕ) :
    ‖combDFT m r x0 k‖ ≤ (m : ℝ) := by
  rw [combDFT_norm hm hr]
  by_cases hdvd : m ∣ k <;> simp [hdvd]

/-- **Equal harmonics.**  All `r` peaks carry exactly the same modulus, so no
amount of peak *ranking* can single out the fundamental frequency `n/r`, even in
the perfectly coherent quantum case. -/
theorem combDFT_harmonics_equal {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 j1 j2 : ℕ) :
    ‖combDFT m r x0 (j1 * m)‖ = ‖combDFT m r x0 (j2 * m)‖ := by
  rw [combDFT_peak hm hr, combDFT_peak hm hr]

/-! ## Counting the peaks and the energy -/

/-- There are exactly `r` peak frequencies inside the register `range (m·r)`. -/
theorem peak_card (m r : ℕ) (hm : m ≠ 0) :
    ((range (m * r)).filter (fun k => m ∣ k)).card = r := by
  classical
  have hm' : 0 < m := Nat.pos_of_ne_zero hm
  have hset : ((range (m * r)).filter (fun k => m ∣ k)) = (range r).image (fun j => j * m) := by
    ext k
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hk, c, rfl⟩
      exact ⟨c, by nlinarith [hk], by ring⟩
    · rintro ⟨j, hj, rfl⟩
      exact ⟨by nlinarith, dvd_mul_left m j⟩
  rw [hset, card_image_of_injective _ (fun a b hab => Nat.eq_of_mul_eq_mul_right hm' hab),
    card_range]

/-- **Energy bookkeeping (Parseval).**  The total spectral energy `n · m` of the
comb is carried entirely by the `r` peaks, each of weight `m²`. -/
theorem combDFT_energy {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 : ℕ) :
    ∑ k ∈ range (m * r), ‖combDFT m r x0 k‖ ^ 2 = (m * r : ℝ) * m := by
  classical
  have h1 : ∀ k ∈ range (m * r), ‖combDFT m r x0 k‖ ^ 2
      = if m ∣ k then ((m : ℝ) ^ 2) else 0 := by
    intro k _
    rw [combDFT_norm hm hr]
    by_cases hdvd : m ∣ k <;> simp [hdvd]
  rw [sum_congr rfl h1, ← sum_filter, sum_const, peak_card m r hm, nsmul_eq_mul]
  ring

/-! ## Shor's classical post-processing: peak ↦ period -/

/-- **Period extraction.**  A measured peak `k = j·m` in a register of size
`n = m·r`, with `j` coprime to `r`, determines the period: the reduced fraction
`k / n` has denominator exactly `r`.  This is the continued-fraction step of
Shor's algorithm, and it works from *any* harmonic — the fundamental plays no
special role. -/
theorem period_from_peak {m r j : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (hj : Nat.Coprime j r) :
    ((j * m : ℕ) / (m * r : ℕ) : ℚ).den = r := by
  have hm' : (m : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hm
  have hr' : (r : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hr
  have hfrac : ((j * m : ℕ) / (m * r : ℕ) : ℚ) = (j : ℚ) / (r : ℚ) := by
    push_cast
    field_simp
  have hb : (0:ℤ) < (r:ℤ) := by positivity
  have hden := Rat.den_div_eq_of_coprime (a := (j:ℤ)) (b := (r:ℤ)) hb (by simpa using hj)
  push_cast at hden
  rw [hfrac]
  exact_mod_cast hden

end QuantumClassicalBoundary