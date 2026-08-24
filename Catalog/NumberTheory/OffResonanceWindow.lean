/-
# Exact off-resonance window formula: the sinc law and its arithmetic shadow

A rectangularly windowed tone of detuning `ω`, observed on the symmetric window
`[-T, T]`, is the oscillatory integral

  `W(T, ω) = ∫_{-T}^{T} e^{i ω t} dt`.

This file proves the **exact** closed form

  `W(T, ω) = 2 sin(ω T) / ω`   (off resonance, `ω ≠ 0`),
  `W(T, 0) = 2 T`              (at resonance),

unified as `W(T, ω) = 2 T · sinc(ω T)`, and then extracts the quantitative
consequences that a bare "the peak is at `ω = 0`" statement cannot give:

* peak dominance `‖W(T, ω)‖ ≤ 2T`;
* sidelobe decay `‖W(T, ω)‖ ≤ 2/|ω|`, together with the *sharpness* of that
  envelope: equality holds at every `ω = (2k+1)π/(2T)`;
* the exact zero set `ω = kπ/T`, `k ≠ 0`, with strict positivity on the whole
  main lobe `0 < ωT < π` (so `π/T` really is the *first* zero);
* a quantitative main-lobe lower bound `‖W‖ ≥ 2T(1 - (ωT)²/4)` for `|ωT| ≤ 1`;
* a resolution bound: half-amplitude is only reached for `|ω| ≤ 2/T`.

The second half develops the **arithmetic** counterpart, the Weyl sum
`S_N(α) = ∑_{n<N} e(nα)`, which is the discrete (sampled) version of the same
window.  We prove the discrete sinc (Dirichlet kernel) law
`‖S_N(α)‖ = |sin(πNα)| / |sin(πα)|`, the resonance value `S_N(α) = N` for
`α ∈ ℤ`, and Weyl's `o(N)` cancellation for irrational `α`.

Finally a **sampling bridge** ties the two together: the continuous window over
`[0, N]` factors exactly as the Weyl sum times one sampling cell,

  `∫_0^N e(αs) ds = S_N(α) · ∫_0^1 e(αs) ds`,

which is the classical Dirichlet-kernel × sinc factorization, and the modulus of
the continuous window is invariant under recentring, `‖C_N(α)‖ = ‖W(N/2, 2πα)‖`.

Two further cycles exploit the sinc law.  A **Rayleigh bracket** pins the
time–bandwidth product at which two equal tones first become resolvable into
`4 < (ΔT)_crit ≤ 2π`, by proving the transcendental inequality
`sin x (2 - cos x) ≥ x` on all of `(0, 2]` and its reversal on `[π, ∞)`.  A
**Fejér identity** rewrites `‖S_N(α)‖²` as a triangularly weighted cosine
polynomial, which the sampling bridge transports to the continuous window.
-/
import Mathlib

noncomputable section

open Complex intervalIntegral Real Finset Filter Topology

namespace OffResonanceWindow

/-! ## The normalized cardinal sine -/

/-- The cardinal sine `sinc x = sin x / x`, extended by `sinc 0 = 1`. -/
def sincR (x : ℝ) : ℝ := if x = 0 then 1 else Real.sin x / x

@[simp] lemma sincR_zero : sincR 0 = 1 := by simp [sincR]

lemma sincR_of_ne {x : ℝ} (hx : x ≠ 0) : sincR x = Real.sin x / x := by
  simp [sincR, hx]

lemma sincR_neg (x : ℝ) : sincR (-x) = sincR x := by
  rcases eq_or_ne x 0 with rfl | hx
  · simp
  · rw [sincR_of_ne (neg_ne_zero.mpr hx), sincR_of_ne hx, Real.sin_neg]
    field_simp

/-- The cardinal sine is bounded by `1` in absolute value. -/
lemma abs_sincR_le_one (x : ℝ) : |sincR x| ≤ 1 := by
  rcases eq_or_ne x 0 with rfl | hx
  · simp
  · rw [sincR_of_ne hx, abs_div]
    rw [div_le_one (abs_pos.mpr hx)]
    exact abs_sin_le_abs

/-- A quantitative lower bound for the cardinal sine on `[-1, 1]`. -/
lemma sincR_ge_of_abs_le_one {x : ℝ} (hx : |x| ≤ 1) : 1 - x ^ 2 / 4 ≤ sincR x := by
  -- reduce to `0 < x ≤ 1` by evenness, then use `sin x > x - x³/4`
  have key : ∀ y : ℝ, 0 < y → y ≤ 1 → 1 - y ^ 2 / 4 ≤ sincR y := by
    intro y hy hy1
    rw [sincR_of_ne (ne_of_gt hy), le_div_iff₀ hy]
    nlinarith [Real.sin_gt_sub_cube hy hy1]
  rcases lt_trichotomy x 0 with h | h | h
  · have hx' : 0 < -x := by linarith
    have hx1 : -x ≤ 1 := by
      rw [abs_of_neg h] at hx; exact hx
    have := key (-x) hx' hx1
    rw [sincR_neg] at this
    nlinarith [this]
  · simp [h]
  · exact key x h (by rwa [abs_of_pos h] at hx)

/-! ## The rectangularly windowed tone -/

/-- The rectangularly windowed tone: a pure tone of detuning `ω` observed
through a rectangular window of half-width `T`. -/
def windowedTone (T ω : ℝ) : ℂ := ∫ t in (-T)..T, Complex.exp (Complex.I * ω * t)

/-- **Resonance value.** At zero detuning the windowed tone integrates to the
full window length `2T`. -/
theorem windowedTone_resonance (T : ℝ) : windowedTone T 0 = ((2 * T : ℝ) : ℂ) := by
  unfold windowedTone
  norm_num
  ring

/-- **Exact off-resonance formula.** For nonzero detuning the windowed tone is
the real number `2 sin(ωT)/ω`. -/
theorem windowedTone_off_resonance (T ω : ℝ) (hω : ω ≠ 0) :
    windowedTone T ω = ((2 * Real.sin (ω * T) / ω : ℝ) : ℂ) := by
  have hc : (Complex.I * ω : ℂ) ≠ 0 := by simp [Complex.ext_iff, hω]
  unfold windowedTone
  rw [integral_exp_mul_complex hc]
  have e1 : Complex.exp (Complex.I * ω * T)
      = Complex.cos ((ω : ℂ) * T) + Complex.sin ((ω : ℂ) * T) * Complex.I := by
    rw [show (Complex.I * ω * T : ℂ) = ((ω : ℂ) * T) * Complex.I by ring, Complex.exp_mul_I]
  have e2 : Complex.exp (Complex.I * ω * ((-T : ℝ) : ℂ))
      = Complex.cos ((ω : ℂ) * T) - Complex.sin ((ω : ℂ) * T) * Complex.I := by
    rw [show (Complex.I * ω * ((-T : ℝ) : ℂ) : ℂ) = (-((ω : ℂ) * T)) * Complex.I by
        push_cast; ring, Complex.exp_mul_I, Complex.cos_neg, Complex.sin_neg]
    ring
  rw [e1, e2]
  have hs : Complex.sin ((ω : ℂ) * T) = ((Real.sin (ω * T) : ℝ) : ℂ) := by
    rw [show ((ω : ℂ) * T) = ((ω * T : ℝ) : ℂ) by push_cast; ring, Complex.ofReal_sin]
  rw [hs]
  field_simp
  push_cast
  ring

/-- **The sinc law.** Uniformly in `ω` (resonant or not), the windowed tone is
`2T · sinc(ωT)`. -/
theorem windowedTone_eq_sinc (T ω : ℝ) :
    windowedTone T ω = ((2 * T * sincR (ω * T) : ℝ) : ℂ) := by
  rcases eq_or_ne ω 0 with rfl | hω
  · rw [windowedTone_resonance]; norm_num
  rcases eq_or_ne T 0 with rfl | hT
  · rw [windowedTone_off_resonance _ _ hω]; norm_num
  rw [windowedTone_off_resonance _ _ hω, sincR_of_ne (mul_ne_zero hω hT)]
  congr 1
  field_simp

/-- The windowed tone is real-valued (the window is symmetric). -/
theorem windowedTone_im (T ω : ℝ) : (windowedTone T ω).im = 0 := by
  rw [windowedTone_eq_sinc]; simp

/-- **Peak dominance.** The resonance value `2T` is the global maximum of the
modulus. -/
theorem norm_windowedTone_le_peak {T : ℝ} (hT : 0 ≤ T) (ω : ℝ) :
    ‖windowedTone T ω‖ ≤ 2 * T := by
  rw [windowedTone_eq_sinc, Complex.norm_real, Real.norm_eq_abs, abs_mul,
    abs_of_nonneg (by linarith : (0:ℝ) ≤ 2 * T)]
  nlinarith [abs_sincR_le_one (ω * T), abs_nonneg (sincR (ω * T))]

/-- **Sidelobe decay.** Off resonance the modulus decays like `2/|ω|`,
independently of the window length. -/
theorem norm_windowedTone_le_sidelobe (T : ℝ) {ω : ℝ} (hω : ω ≠ 0) :
    ‖windowedTone T ω‖ ≤ 2 / |ω| := by
  rw [windowedTone_off_resonance _ _ hω, Complex.norm_real, Real.norm_eq_abs, abs_div,
    abs_mul]
  have h1 : |Real.sin (ω * T)| ≤ 1 := Real.abs_sin_le_one _
  have h2 : (0:ℝ) < |ω| := abs_pos.mpr hω
  rw [div_le_div_iff_of_pos_right h2]
  simpa using h1

/-- **The sidelobe envelope is attained.**  At the half-integer detunings
`ω = (2k+1)π/(2T)` — exactly midway between consecutive zeros — the modulus of
the windowed tone equals `2/|ω|` on the nose.  So the bound
`norm_windowedTone_le_sidelobe` is not merely an envelope: it is *sharp*, touched
once inside every sidelobe. -/
theorem norm_windowedTone_sidelobe_peak {T : ℝ} (hT : 0 < T) (k : ℤ) :
    ‖windowedTone T ((2 * k + 1) * Real.pi / (2 * T))‖
      = 2 / |(2 * (k:ℝ) + 1) * Real.pi / (2 * T)| := by
  set ω : ℝ := (2 * (k:ℝ) + 1) * Real.pi / (2 * T) with hωdef
  have hk : (2 * (k:ℝ) + 1) ≠ 0 := by
    intro h
    have : (2 * k + 1 : ℤ) = 0 := by exact_mod_cast h
    omega
  have hω : ω ≠ 0 := by
    rw [hωdef]
    exact div_ne_zero (mul_ne_zero hk Real.pi_ne_zero) (by positivity)
  have hωT : ω * T = (k:ℝ) * Real.pi + Real.pi / 2 := by
    rw [hωdef]; field_simp
  have hsin : |Real.sin (ω * T)| = 1 := by
    rw [hωT, Real.sin_add, Real.sin_int_mul_pi, Real.cos_pi_div_two, Real.sin_pi_div_two]
    simp [Real.cos_int_mul_pi]
  rw [windowedTone_off_resonance _ _ hω, Complex.norm_real, Real.norm_eq_abs, abs_div,
    abs_mul, hsin]
  norm_num

/-- **Exact zero set.** The windowed tone vanishes precisely at the detunings
`ω = kπ/T` with `k` a nonzero integer. -/
theorem windowedTone_eq_zero_iff {T ω : ℝ} (hT : 0 < T) (hω : ω ≠ 0) :
    windowedTone T ω = 0 ↔ ∃ k : ℤ, k ≠ 0 ∧ ω = k * Real.pi / T := by
  rw [windowedTone_off_resonance _ _ hω]
  rw [show ((0:ℂ)) = ((0:ℝ) : ℂ) by norm_num, Complex.ofReal_inj]
  constructor
  · intro h
    have hsin : Real.sin (ω * T) = 0 := by
      field_simp at h; linarith [h]
    obtain ⟨k, hk⟩ := Real.sin_eq_zero_iff.mp hsin
    refine ⟨k, ?_, ?_⟩
    · rintro rfl
      simp at hk
      rcases hk with hk | hk
      · exact hω (by nlinarith)
      · exact absurd hk (ne_of_gt hT)
    · field_simp
      linarith [hk]
  · rintro ⟨k, hk, rfl⟩
    have : (k : ℝ) * Real.pi / T * T = k * Real.pi := by field_simp
    rw [this, Real.sin_int_mul_pi]
    simp

/-- **The main lobe carries no zero.** For `0 < ωT < π` the windowed tone is
strictly positive, so `π/T` is genuinely the first zero. -/
theorem windowedTone_pos_on_main_lobe {T ω : ℝ} (hT : 0 < T) (hω : 0 < ω)
    (h : ω * T < Real.pi) : 0 < (windowedTone T ω).re := by
  rw [windowedTone_off_resonance _ _ (ne_of_gt hω), Complex.ofReal_re]
  have hsin : 0 < Real.sin (ω * T) := Real.sin_pos_of_pos_of_lt_pi (by positivity) h
  positivity

/-- **Quantitative main lobe.** Inside `|ωT| ≤ 1` the modulus stays within a
quadratic of the peak. -/
theorem norm_windowedTone_main_lobe_lower {T ω : ℝ} (hT : 0 ≤ T) (h : |ω * T| ≤ 1) :
    2 * T * (1 - (ω * T) ^ 2 / 4) ≤ ‖windowedTone T ω‖ := by
  have hlow : 1 - (ω * T) ^ 2 / 4 ≤ sincR (ω * T) := sincR_ge_of_abs_le_one h
  have hsq : (ω * T) ^ 2 ≤ 1 := by
    have := abs_nonneg (ω * T)
    nlinarith [sq_abs (ω * T)]
  have hpos : 0 ≤ sincR (ω * T) := by linarith
  rw [windowedTone_eq_sinc, Complex.norm_real, Real.norm_eq_abs,
    abs_of_nonneg (by positivity : (0:ℝ) ≤ 2 * T * sincR (ω * T))]
  nlinarith

/-- **Resolution bound.** Half of the peak amplitude is only attained for
detunings `|ω| ≤ 2/T`: the peak has width `O(1/T)`. -/
theorem abs_le_of_norm_windowedTone_ge_half {T ω : ℝ} (hT : 0 < T)
    (h : T ≤ ‖windowedTone T ω‖) : |ω| ≤ 2 / T := by
  rcases eq_or_ne ω 0 with rfl | hω
  · simp only [abs_zero]
    positivity
  · have hb := norm_windowedTone_le_sidelobe T hω
    have h2 : T ≤ 2 / |ω| := le_trans h hb
    have hpos : (0:ℝ) < |ω| := abs_pos.mpr hω
    rw [le_div_iff₀ hpos] at h2
    rw [le_div_iff₀ hT]
    linarith

/-! ## The arithmetic shadow: Weyl sums and the discrete sinc -/

/-- The Weyl (exponential) sum `S_N(α) = ∑_{n<N} e(nα)`: the *sampled*
rectangular window of length `N`. -/
def weylSum (N : ℕ) (α : ℝ) : ℂ := ∑ n ∈ Finset.range N, Complex.exp (2 * Real.pi * Complex.I * n * α)

/-- **Discrete resonance.** At integer frequencies every sample is in phase and
the Weyl sum attains its peak value `N`. -/
theorem weylSum_resonance (N : ℕ) (k : ℤ) : weylSum N (k : ℝ) = (N : ℂ) := by
  unfold weylSum
  have h : ∀ n ∈ Finset.range N, Complex.exp (2 * Real.pi * Complex.I * n * (k : ℝ)) = 1 := by
    intro n _
    rw [show (2 * (Real.pi : ℂ) * Complex.I * n * ((k : ℝ) : ℂ))
        = ((n * k : ℤ) : ℂ) * (2 * Real.pi * Complex.I) by push_cast; ring]
    exact Complex.exp_int_mul_two_pi_mul_I _
  rw [Finset.sum_congr rfl h]
  simp

/-- Modulus of `e^{iθ} - 1`, the elementary trigonometric input to both the
continuous and the discrete formula. -/
lemma norm_exp_mul_I_sub_one (θ : ℝ) :
    ‖Complex.exp (θ * Complex.I) - 1‖ = 2 * |Real.sin (θ / 2)| := by
  have h : Complex.exp (θ * Complex.I) - 1
      = ((Real.cos θ - 1 : ℝ) : ℂ) + ((Real.sin θ : ℝ) : ℂ) * Complex.I := by
    rw [Complex.exp_mul_I, ← Complex.ofReal_cos, ← Complex.ofReal_sin]; push_cast; ring
  have hc : Real.cos θ = 1 - 2 * Real.sin (θ / 2) ^ 2 := by
    have h2 : Real.sin (θ / 2) ^ 2 + Real.cos (θ / 2) ^ 2 = 1 := Real.sin_sq_add_cos_sq _
    have h3 := Real.cos_two_mul (θ / 2)
    rw [show 2 * (θ / 2) = θ by ring] at h3
    nlinarith
  have hs : Real.sin θ ^ 2 = 1 - Real.cos θ ^ 2 := by
    have := Real.sin_sq_add_cos_sq θ; linarith
  rw [h, Complex.norm_add_mul_I, hs, hc,
    show (1 - 2 * Real.sin (θ/2)^2 - 1)^2 + (1 - (1 - 2 * Real.sin (θ/2)^2)^2)
        = (2 * |Real.sin (θ/2)|)^2 by rw [mul_pow, sq_abs]; ring]
  exact Real.sqrt_sq (by positivity)

/-- **Discrete sinc law (Dirichlet kernel).** Off resonance the Weyl sum has
modulus `|sin(πNα)| / |sin(πα)|`. -/
theorem norm_weylSum (N : ℕ) {α : ℝ} (hα : Real.sin (Real.pi * α) ≠ 0) :
    ‖weylSum N α‖ = |Real.sin (Real.pi * N * α)| / |Real.sin (Real.pi * α)| := by
  set z : ℂ := Complex.exp (((2 * Real.pi * α : ℝ) : ℂ) * Complex.I) with hzdef
  have hden : ‖z - 1‖ = 2 * |Real.sin (Real.pi * α)| := by
    rw [hzdef, norm_exp_mul_I_sub_one]; ring_nf
  have hz : z ≠ 1 := by
    intro h
    rw [h] at hden
    simp at hden
    tauto
  have hsum : weylSum N α = ∑ i ∈ Finset.range N, z ^ i := by
    unfold weylSum
    refine Finset.sum_congr rfl (fun n _ => ?_)
    rw [hzdef, ← Complex.exp_nat_mul]
    congr 1
    push_cast; ring
  have hzN : z ^ N = Complex.exp (((2 * Real.pi * N * α : ℝ) : ℂ) * Complex.I) := by
    rw [hzdef, ← Complex.exp_nat_mul]
    congr 1
    push_cast; ring
  rw [hsum, geom_sum_eq hz, norm_div, hzN, norm_exp_mul_I_sub_one, hden,
    show (2 * Real.pi * (N : ℝ) * α) / 2 = Real.pi * N * α by ring,
    mul_div_mul_left _ _ (by norm_num : (2:ℝ) ≠ 0)]

/-- **Discrete sidelobe bound.** Off resonance the Weyl sum is bounded
independently of `N`. -/
theorem norm_weylSum_le (N : ℕ) {α : ℝ} (hα : Real.sin (Real.pi * α) ≠ 0) :
    ‖weylSum N α‖ ≤ 1 / |Real.sin (Real.pi * α)| := by
  rw [norm_weylSum N hα]
  have hpos : (0:ℝ) < |Real.sin (Real.pi * α)| := abs_pos.mpr hα
  rw [div_le_div_iff_of_pos_right hpos]
  exact Real.abs_sin_le_one _

/-- Non-integer reals have `sin(πα) ≠ 0`. -/
lemma sin_pi_mul_ne_zero {α : ℝ} (hα : ∀ k : ℤ, α ≠ (k : ℝ)) :
    Real.sin (Real.pi * α) ≠ 0 := by
  intro h
  obtain ⟨n, hn⟩ := Real.sin_eq_zero_iff.mp h
  refine hα n ?_
  have hpi : (0:ℝ) < Real.pi := Real.pi_pos
  have hn' : (n : ℝ) * Real.pi = Real.pi * α := hn
  field_simp at hn'
  nlinarith [hn']

/-- **Weyl cancellation.** For any non-integer `α` the normalized Weyl sum tends
to `0`: complete cancellation off resonance. -/
theorem weylSum_div_tendsto_zero {α : ℝ} (hα : Real.sin (Real.pi * α) ≠ 0) :
    Tendsto (fun N : ℕ => ‖weylSum N α‖ / N) atTop (𝓝 0) := by
  apply squeeze_zero (fun n => div_nonneg (norm_nonneg _) (Nat.cast_nonneg n))
    (g := fun N : ℕ => (1 / |Real.sin (Real.pi * α)|) / N)
  · intro n
    have hn : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    gcongr
    exact norm_weylSum_le n hα
  · exact tendsto_const_div_atTop_nhds_zero_nat _

/-- **Weyl's criterion input.** For irrational `α` every nonzero harmonic
`h` exhibits full cancellation, which is exactly the hypothesis of Weyl's
equidistribution criterion for the sequence `nα mod 1`. -/
theorem weylSum_harmonic_tendsto_zero {α : ℝ} (hα : Irrational α) {h : ℤ} (hh : h ≠ 0) :
    Tendsto (fun N : ℕ => ‖weylSum N (h * α)‖ / N) atTop (𝓝 0) := by
  have hirr : Irrational ((h : ℝ) * α) := Irrational.intCast_mul hα hh
  exact weylSum_div_tendsto_zero (sin_pi_mul_ne_zero (fun k => hirr.ne_int k))

/-! ## The sampling bridge -/

/-- The continuous window over `[0, b]` at frequency `α` (cycles per unit). -/
def contTone (b α : ℝ) : ℂ := ∫ s in (0:ℝ)..b, Complex.exp (2 * Real.pi * Complex.I * α * s)

/-- One sampling cell, translated: `∫_c^{c+1} e(αs) ds = e(αc) ∫_0^1 e(αs) ds`. -/
lemma contTone_cell (c α : ℝ) :
    (∫ s in c..(c+1), Complex.exp (2 * Real.pi * Complex.I * α * s))
      = Complex.exp (2 * Real.pi * Complex.I * α * c) * contTone 1 α := by
  have h := intervalIntegral.integral_comp_add_left (a := 0) (b := 1) (d := c)
    (f := fun s : ℝ => Complex.exp (2 * Real.pi * Complex.I * α * s))
  simp only [add_zero] at h
  rw [← h]
  unfold contTone
  rw [← intervalIntegral.integral_const_mul]
  refine intervalIntegral.integral_congr (fun x _ => ?_)
  rw [← Complex.exp_add]
  congr 1
  push_cast; ring

/-- **Sampling bridge.** The continuous window of length `N` factors exactly as
the Weyl sum (discrete window) times a single sampling cell. -/
theorem contTone_eq_weylSum_mul (N : ℕ) (α : ℝ) :
    contTone (N : ℝ) α = weylSum N α * contTone 1 α := by
  have hcont : Continuous (fun s : ℝ => Complex.exp (2 * Real.pi * Complex.I * α * s)) := by
    fun_prop
  have hadj := intervalIntegral.sum_integral_adjacent_intervals
    (f := fun s : ℝ => Complex.exp (2 * Real.pi * Complex.I * α * s))
    (μ := MeasureTheory.volume) (a := fun k : ℕ => (k : ℝ)) (n := N)
    (fun k _ => hcont.intervalIntegrable _ _)
  simp only [Nat.cast_zero, Nat.cast_add, Nat.cast_one] at hadj
  unfold contTone weylSum
  rw [← hadj, Finset.sum_mul]
  refine Finset.sum_congr rfl (fun k _ => ?_)
  rw [contTone_cell (k : ℝ) α]
  unfold contTone
  congr 2
  push_cast; ring

/-- **Dirichlet × sinc factorization**, in modulus. -/
theorem norm_contTone_factorization (N : ℕ) (α : ℝ) :
    ‖contTone (N : ℝ) α‖ = ‖weylSum N α‖ * ‖contTone 1 α‖ := by
  rw [contTone_eq_weylSum_mul, norm_mul]

/-- Exact modulus of the continuous window: the sinc law again. -/
theorem norm_contTone (b : ℝ) {α : ℝ} (hα : α ≠ 0) :
    ‖contTone b α‖ = |Real.sin (Real.pi * α * b)| / (Real.pi * |α|) := by
  have hc : (2 * (Real.pi : ℂ) * Complex.I * α) ≠ 0 := by
    simp [Complex.ext_iff, hα, Real.pi_ne_zero]
  unfold contTone
  rw [integral_exp_mul_complex hc]
  simp only [Complex.ofReal_zero, mul_zero, Complex.exp_zero]
  rw [show (2 * (Real.pi : ℂ) * Complex.I * α * b) = ((2 * Real.pi * α * b : ℝ) : ℂ) * Complex.I by
      push_cast; ring]
  rw [norm_div, norm_exp_mul_I_sub_one,
    show (2 * Real.pi * α * b) / 2 = Real.pi * α * b by ring]
  have hnorm : ‖(2 * (Real.pi : ℂ) * Complex.I * α)‖ = 2 * (Real.pi * |α|) := by
    rw [show (2 * (Real.pi : ℂ) * Complex.I * α) = ((2 * Real.pi * α : ℝ) : ℂ) * Complex.I by
        push_cast; ring, norm_mul, Complex.norm_I, Complex.norm_real, Real.norm_eq_abs,
      mul_one, abs_mul, abs_mul, abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2),
      abs_of_nonneg Real.pi_pos.le]
    ring
  rw [hnorm, mul_div_mul_left _ _ (by norm_num : (2:ℝ) ≠ 0)]

/-- **Recentring invariance**: the `[0,N]` window and the symmetric `[-N/2,N/2]`
window have the same modulus, so the two halves of this file describe one and
the same spectral peak. -/
theorem norm_contTone_eq_norm_windowedTone (b : ℝ) (α : ℝ) :
    ‖contTone b α‖ = ‖windowedTone (b / 2) (2 * Real.pi * α)‖ := by
  rcases eq_or_ne α 0 with rfl | hα
  · have h1 : contTone b 0 = ((b : ℝ) : ℂ) := by
      unfold contTone; norm_num
    rw [h1, show (2 * Real.pi * (0:ℝ)) = 0 by ring, windowedTone_resonance]
    simp
    ring
  · have h2π : (2 * Real.pi * α) ≠ 0 := by
      have := Real.pi_ne_zero
      simp [hα, this]
    rw [norm_contTone b hα, windowedTone_off_resonance _ _ h2π, Complex.norm_real,
      Real.norm_eq_abs, abs_div, abs_mul,
      show (2 * Real.pi * α) * (b / 2) = Real.pi * α * b by ring]
    rw [abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2), abs_mul, abs_mul,
      abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2), abs_of_nonneg Real.pi_pos.le,
      show (2:ℝ) * Real.pi * |α| = 2 * (Real.pi * |α|) by ring,
      mul_div_mul_left _ _ (by norm_num : (2:ℝ) ≠ 0)]

/-! ## Cycle II: the discrete peak has width exactly `1/N`, and arithmetic resonance

The first half showed the continuous peak has half-amplitude width `O(1/T)`.  Here
we pin the *discrete* peak from both sides: a Jordan-inequality lower bound saying
the Weyl sum stays within `2/π` of its peak throughout `|α| ≤ 1/(2N)`, and the
classical `1/(2‖α‖)` upper bound saying it has collapsed once `α` leaves that
window.  Combining the lower bound with Dirichlet's approximation theorem yields
*arithmetic resonance*: for every real `α` some harmonic `q ≤ N` is coherent over
all window lengths `M ≤ (N+1)/2`. -/

/-- Distance from a real number to the nearest integer. -/
def intDist (α : ℝ) : ℝ := |α - round α|

lemma intDist_nonneg (α : ℝ) : 0 ≤ intDist α := abs_nonneg _

lemma intDist_le_half (α : ℝ) : intDist α ≤ 1 / 2 := abs_sub_round α

/-- On `|x| ≤ 1` the sine of `πx` has modulus `sin (π|x|)`. -/
lemma abs_sin_pi_mul (x : ℝ) (hx : |x| ≤ 1) :
    |Real.sin (Real.pi * x)| = Real.sin (Real.pi * |x|) := by
  have hpi : (0:ℝ) < Real.pi := Real.pi_pos
  rcases abs_cases x with ⟨h, _⟩ | ⟨h, _⟩
  · rw [h, abs_of_nonneg]
    exact Real.sin_nonneg_of_nonneg_of_le_pi (by nlinarith [abs_nonneg x])
      (by nlinarith [abs_nonneg x])
  · have hsin : Real.sin (Real.pi * x) ≤ 0 :=
      Real.sin_nonpos_of_nonpos_of_neg_pi_le (by nlinarith) (by nlinarith)
    rw [h, show Real.pi * -x = -(Real.pi * x) by ring, Real.sin_neg, abs_of_nonpos hsin]

/-- **Jordan's inequality for the circle**: `|sin(πα)| ≥ 2‖α‖`, where `‖α‖` is the
distance from `α` to the nearest integer. -/
theorem two_mul_intDist_le_abs_sin (α : ℝ) : 2 * intDist α ≤ |Real.sin (Real.pi * α)| := by
  unfold intDist
  set m : ℤ := round α with hm
  set t : ℝ := α - m with ht
  have ht2 : |t| ≤ 1 / 2 := abs_sub_round α
  have hpi : (0:ℝ) < Real.pi := Real.pi_pos
  have hs : Real.sin (Real.pi * α) = Real.sin (Real.pi * m) * Real.cos (Real.pi * t)
      + Real.cos (Real.pi * m) * Real.sin (Real.pi * t) := by
    rw [← Real.sin_add]; congr 1; rw [ht]; ring
  have h0 : Real.sin (Real.pi * (m:ℝ)) = 0 := by rw [mul_comm]; exact Real.sin_int_mul_pi m
  have h1 : |Real.cos (Real.pi * (m:ℝ))| = 1 := by rw [mul_comm]; exact abs_cos_int_mul_pi m
  rw [hs, h0, zero_mul, zero_add, abs_mul, h1, one_mul, abs_sin_pi_mul t (by nlinarith)]
  have hjordan : 2 / Real.pi * (Real.pi * |t|) ≤ Real.sin (Real.pi * |t|) :=
    Real.mul_le_sin (by positivity) (by nlinarith [abs_nonneg t])
  calc 2 * |t| = 2 / Real.pi * (Real.pi * |t|) := by field_simp
  _ ≤ Real.sin (Real.pi * |t|) := hjordan

/-- **Classical Weyl-sum bound.** Off resonance the sum is bounded by half the
reciprocal distance of the frequency to the nearest integer. -/
theorem norm_weylSum_le_intDist (N : ℕ) {α : ℝ} (hα : 0 < intDist α) :
    ‖weylSum N α‖ ≤ 1 / (2 * intDist α) := by
  have hs : 0 < |Real.sin (Real.pi * α)| :=
    lt_of_lt_of_le (by linarith) (two_mul_intDist_le_abs_sin α)
  have hsne : Real.sin (Real.pi * α) ≠ 0 := abs_pos.mp hs
  refine le_trans (norm_weylSum_le N hsne) ?_
  exact one_div_le_one_div_of_le (by linarith) (two_mul_intDist_le_abs_sin α)

/-- **Discrete main lobe (Jordan bound).** Throughout `|α| ≤ 1/(2N)` the Weyl sum
retains at least the fraction `2/π` of its peak value `N`. -/
theorem norm_weylSum_ge_jordan (N : ℕ) {α : ℝ} (hα : |α| ≤ 1 / (2 * N)) :
    2 / Real.pi * N ≤ ‖weylSum N α‖ := by
  have hpi : (0:ℝ) < Real.pi := Real.pi_pos
  have hpi2 : (2:ℝ) ≤ Real.pi := by linarith [Real.pi_gt_three]
  rcases eq_or_ne α 0 with rfl | h0
  · rw [show (0:ℝ) = ((0:ℤ):ℝ) by norm_num, weylSum_resonance, Complex.norm_natCast]
    have h1 : (2:ℝ) / Real.pi ≤ 1 := by rw [div_le_one hpi]; linarith
    nlinarith [Nat.cast_nonneg (α := ℝ) N]
  · have habs : 0 < |α| := abs_pos.mpr h0
    have hN : 1 ≤ N := by
      by_contra h
      push_neg at h
      interval_cases N
      · simp at hα; exact h0 hα
    have hNR : (1:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
    have hbound : (N:ℝ) * |α| ≤ 1 / 2 := by
      rw [le_div_iff₀ (by positivity)] at hα
      nlinarith
    have hden : |Real.sin (Real.pi * α)| = Real.sin (Real.pi * |α|) :=
      abs_sin_pi_mul α (by nlinarith)
    have hdenpos : 0 < Real.sin (Real.pi * |α|) :=
      Real.sin_pos_of_pos_of_lt_pi (by positivity) (by nlinarith)
    have hdenle : Real.sin (Real.pi * |α|) ≤ Real.pi * |α| := by
      have := Real.sin_le (le_of_lt (by positivity : (0:ℝ) < Real.pi * |α|))
      linarith [this]
    have hnumabs : |Real.sin (Real.pi * N * α)| = Real.sin (Real.pi * ((N:ℝ) * |α|)) := by
      rw [show Real.pi * (N:ℝ) * α = Real.pi * ((N:ℝ) * α) by ring,
        abs_sin_pi_mul _ (by rw [abs_mul, abs_of_nonneg (Nat.cast_nonneg (α := ℝ) N)]; nlinarith),
        abs_mul, abs_of_nonneg (Nat.cast_nonneg (α := ℝ) N)]
    have hnum : 2 * ((N:ℝ) * |α|) ≤ Real.sin (Real.pi * ((N:ℝ) * |α|)) := by
      have h := Real.mul_le_sin (x := Real.pi * ((N:ℝ) * |α|)) (by positivity) (by nlinarith)
      calc 2 * ((N:ℝ) * |α|) = 2 / Real.pi * (Real.pi * ((N:ℝ) * |α|)) := by field_simp
      _ ≤ _ := h
    have hsinne : Real.sin (Real.pi * α) ≠ 0 := by
      have : 0 < |Real.sin (Real.pi * α)| := by rw [hden]; exact hdenpos
      exact abs_pos.mp this
    rw [norm_weylSum N hsinne, hden, hnumabs, le_div_iff₀ hdenpos]
    have h2 : (2 / Real.pi * (N:ℝ)) * Real.sin (Real.pi * |α|)
        ≤ (2 / Real.pi * (N:ℝ)) * (Real.pi * |α|) :=
      mul_le_mul_of_nonneg_left hdenle (by positivity)
    have h3 : (2 / Real.pi * (N:ℝ)) * (Real.pi * |α|) = 2 * ((N:ℝ) * |α|) := by field_simp
    linarith

/-- The Weyl sum exactly at the edge of the main lobe, `α = 1/(2N)`. -/
theorem norm_weylSum_endpoint {N : ℕ} (hN : 0 < N) :
    ‖weylSum N (1 / (2 * N))‖ = 1 / Real.sin (Real.pi / (2 * N)) := by
  have hNR : (1:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  have hN0 : (0:ℝ) < (N:ℝ) := by linarith
  have hy : Real.pi * (1 / (2 * (N:ℝ))) = Real.pi / (2 * N) := by ring
  have hypos : 0 < Real.pi / (2 * (N:ℝ)) := by positivity
  have hylt : Real.pi / (2 * (N:ℝ)) < Real.pi := by
    rw [div_lt_iff₀ (by positivity)]
    nlinarith [Real.pi_pos]
  have hsin : 0 < Real.sin (Real.pi / (2 * (N:ℝ))) := Real.sin_pos_of_pos_of_lt_pi hypos hylt
  have hne : Real.sin (Real.pi * (1 / (2 * (N:ℝ)))) ≠ 0 := by rw [hy]; exact ne_of_gt hsin
  rw [norm_weylSum N hne, hy, abs_of_pos hsin]
  have hnum : Real.pi * (N:ℝ) * (1 / (2 * N)) = Real.pi / 2 := by field_simp
  rw [hnum, Real.sin_pi_div_two, abs_one]

/-- **The constant `2/π` is sharp.** At the edge of the main lobe the Weyl sum
exceeds `(2/π)N` by at most `1/N`, so no constant larger than `2/π` can appear in
`norm_weylSum_ge_jordan`. -/
theorem norm_weylSum_endpoint_le {N : ℕ} (hN : 0 < N) :
    ‖weylSum N (1 / (2 * N))‖ ≤ 2 / Real.pi * N + 1 / N := by
  have hNR : (1:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  have hN0 : (0:ℝ) < (N:ℝ) := by linarith
  have hpi0 : (0:ℝ) < Real.pi := Real.pi_pos
  have hypos : 0 < Real.pi / (2 * (N:ℝ)) := by positivity
  have hylt : Real.pi / (2 * (N:ℝ)) < Real.pi := by
    rw [div_lt_iff₀ (by positivity)]
    nlinarith
  have hsin : 0 < Real.sin (Real.pi / (2 * (N:ℝ))) := Real.sin_pos_of_pos_of_lt_pi hypos hylt
  have hC : 0 < 2 / Real.pi * (N:ℝ) + 1 / N := by positivity
  rw [norm_weylSum_endpoint hN, div_le_iff₀ hsin]
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.mpr hN.ne') with h1 | h2
  · -- `N = 1`: the sum is a single term of modulus one
    have hN1 : N = 1 := h1.symm
    subst hN1
    norm_num
    positivity
  · -- `N ≥ 2`: the cubic lower bound for `sin` suffices
    have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast h2
    have hNsq : (4:ℝ) ≤ (N:ℝ)^2 := by nlinarith
    have hpi' : Real.pi < 3.15 := Real.pi_lt_d2
    have hpi3 : (3:ℝ) < Real.pi := Real.pi_gt_three
    have hyle : Real.pi / (2 * (N:ℝ)) ≤ 1 := by
      rw [div_le_one (by positivity)]
      nlinarith
    have hs : Real.pi / (2 * (N:ℝ)) - (Real.pi / (2 * (N:ℝ)))^3 / 4
        < Real.sin (Real.pi / (2 * (N:ℝ))) := Real.sin_gt_sub_cube hypos hyle
    have key : (1:ℝ) ≤ (2 / Real.pi * (N:ℝ) + 1 / N)
        * (Real.pi / (2 * N) - (Real.pi / (2 * N))^3 / 4) := by
      have hkey : (2 / Real.pi * (N:ℝ) + 1 / N)
          * (Real.pi / (2 * N) - (Real.pi / (2 * N))^3 / 4)
          = 1 - Real.pi^2 / (16 * (N:ℝ)^2) + Real.pi / (2 * (N:ℝ)^2)
            - Real.pi^3 / (32 * (N:ℝ)^4) := by
        field_simp
        ring
      rw [hkey]
      have hcore : 2 * Real.pi * (N:ℝ)^2 + Real.pi^2 ≤ 16 * (N:ℝ)^2 := by nlinarith
      have hprod : (0:ℝ) ≤ 32 * Real.pi * (N:ℝ)^4
          * (16 * (N:ℝ)^2 - (2 * Real.pi * (N:ℝ)^2 + Real.pi^2)) :=
        mul_nonneg (by positivity) (by linarith)
      have h1 : Real.pi^2 / (16 * (N:ℝ)^2) + Real.pi^3 / (32 * (N:ℝ)^4)
          ≤ Real.pi / (2 * (N:ℝ)^2) := by
        rw [div_add_div _ _ (by positivity) (by positivity),
          div_le_div_iff₀ (by positivity) (by positivity)]
        nlinarith [hprod]
      linarith
    nlinarith [mul_lt_mul_of_pos_left hs hC]

/-- **Discrete resolution bound.** If the Weyl sum still holds half of its peak
value, the frequency must lie within `1/N` of an integer. -/
theorem intDist_le_of_norm_weylSum_ge {N : ℕ} (hN : 0 < N) {α : ℝ}
    (h : (N:ℝ) / 2 ≤ ‖weylSum N α‖) : intDist α ≤ 1 / N := by
  have hNR : (0:ℝ) < (N:ℝ) := by exact_mod_cast hN
  rcases eq_or_lt_of_le (intDist_nonneg α) with h0 | h0
  · rw [← h0]; positivity
  · have hb := norm_weylSum_le_intDist N h0
    have : (N:ℝ) / 2 ≤ 1 / (2 * intDist α) := le_trans h hb
    rw [div_le_div_iff₀ (by norm_num) (by positivity)] at this
    rw [le_div_iff₀ hNR]
    nlinarith

/-- Weyl sums are `1`-periodic in the frequency. -/
theorem weylSum_add_int (N : ℕ) (α : ℝ) (k : ℤ) : weylSum N (α + k) = weylSum N α := by
  unfold weylSum
  refine Finset.sum_congr rfl (fun n _ => ?_)
  rw [show (2 * (Real.pi:ℂ) * Complex.I * n * ((α + k : ℝ) : ℂ))
      = 2 * (Real.pi:ℂ) * Complex.I * n * α + ((n * k : ℤ) : ℂ) * (2 * Real.pi * Complex.I) by
    push_cast; ring, Complex.exp_add, Complex.exp_int_mul_two_pi_mul_I, mul_one]

/-- **Arithmetic resonance.** For every real `α` and every `N ≥ 1` there is a
harmonic `q ≤ N` whose frequency `qα` sits inside the main lobe for *all* window
lengths `M ≤ (N+1)/2` simultaneously, so the sampled tone stays coherent,
`‖S_M(qα)‖ ≥ (2/π) M`.  Dirichlet approximation meets the sinc main lobe. -/
theorem exists_harmonic_resonance (α : ℝ) {N : ℕ} (hN : 0 < N) :
    ∃ q : ℕ, 0 < q ∧ q ≤ N ∧
      ∀ M : ℕ, 2 * M ≤ N + 1 → 2 / Real.pi * M ≤ ‖weylSum M ((q : ℝ) * α)‖ := by
  obtain ⟨j, k, hk0, hkN, hjk⟩ := Real.exists_int_int_abs_mul_sub_le α hN
  have hkt : ((k.toNat : ℝ)) = (k : ℝ) := by
    exact_mod_cast Int.toNat_of_nonneg hk0.le
  refine ⟨k.toNat, by omega, by omega, ?_⟩
  intro M hM
  rcases Nat.eq_zero_or_pos M with rfl | hM0
  · simp [weylSum]
  · have hMR : (1:ℝ) ≤ (M:ℝ) := by exact_mod_cast hM0
    have hMN : 2 * (M:ℝ) ≤ (N:ℝ) + 1 := by exact_mod_cast hM
    rw [hkt, show ((k:ℝ) * α) = ((k:ℝ) * α - j) + (j : ℤ) by ring,
      weylSum_add_int]
    refine norm_weylSum_ge_jordan M ?_
    refine le_trans hjk ?_
    exact one_div_le_one_div_of_le (by positivity) hMN

/-! ## Cycle III: the Rayleigh criterion for the rectangular window

The sinc law lets us decide when two equal-amplitude tones separated by a
detuning `Δ` are *resolved*.  Superposing the two windowed responses, everything
reduces to the single transcendental inequality

  `sin x (2 - cos x)  ≥  x`,   `x = ΔT/2`,

which holds up to a critical `x* = 2.13918…` and fails afterwards.  We prove it on
`(0, 2.1]` and prove its strict reversal on `[2.2, ∞)`, both by recentring the
Maclaurin bounds at `π/2`, and deduce:

* if `ΔT ≤ 4.2` the response at the midpoint dominates the response at either
  tone centre — no central dip, the pair is **unresolved**;
* if `ΔT ≥ 4.4` the midpoint response is *strictly* below the tone centres — a
  genuine dip, the pair is **resolved**;
* at the separation `Δ = 2π/T` the midpoint response vanishes identically while
  each tone centre still carries the full peak `2T` — a **total dip**.

Together these bracket the resolution threshold of the rectangular window into
`4.2 < (ΔT)_crit ≤ 4.4`; the true value is `(ΔT)_crit = 4.27836…`, so the bracket
is within `5%`.  This replaces the classical Rayleigh heuristic `Δ ≈ 2π/T` by a
two-sided, fully formal statement with explicit constants. -/

/-- Superposition of two equal-amplitude tones separated by a detuning `Δ`,
observed at frequency offset `ω` from their midpoint. -/
def twoToneResponse (T Δ ω : ℝ) : ℂ :=
  windowedTone T (ω - Δ / 2) + windowedTone T (ω + Δ / 2)

/-- The sinc form of the two-tone response. -/
theorem twoToneResponse_eq (T Δ ω : ℝ) :
    twoToneResponse T Δ ω
      = ((2 * T * (sincR ((ω - Δ/2) * T) + sincR ((ω + Δ/2) * T)) : ℝ) : ℂ) := by
  unfold twoToneResponse
  rw [windowedTone_eq_sinc, windowedTone_eq_sinc]
  push_cast
  ring

/-- The analytic heart of the Rayleigh criterion, near range: `sin x (2 - cos x) ≥ x`
on `(0, 1]`, proved from the cubic bounds for `sin` and the half-angle identity. -/
lemma le_sin_mul_two_sub_cos {x : ℝ} (hx : 0 < x) (hx1 : x ≤ 1) :
    x ≤ Real.sin x * (2 - Real.cos x) := by
  have hx2 : x^2 ≤ 1 := by nlinarith
  have hx3 : x^3 ≤ x := by nlinarith [hx.le]
  have hx5 : x^5 ≤ x^3 := by nlinarith [pow_pos hx 3, pow_pos hx 5]
  have h1 : x - x^3/4 < Real.sin x := Real.sin_gt_sub_cube hx hx1
  have hu : 0 < x/2 := by linarith
  have h3 : x/2 - (x/2)^3/4 < Real.sin (x/2) := Real.sin_gt_sub_cube hu (by linarith)
  have h2 : Real.cos x = 1 - 2 * Real.sin (x/2)^2 := by
    have ha : Real.sin (x/2)^2 + Real.cos (x/2)^2 = 1 := Real.sin_sq_add_cos_sq _
    have hb := Real.cos_two_mul (x/2)
    rw [show 2*(x/2) = x by ring] at hb
    nlinarith
  have hApos : 0 < x/2 - x^3/32 := by linarith
  have hA : x/2 - x^3/32 < Real.sin (x/2) := by
    have e : (x/2)^3/4 = x^3/32 := by ring
    linarith [h3, e]
  have hB : (x/2 - x^3/32)^2 ≤ Real.sin (x/2)^2 := by nlinarith [hA, hApos]
  have hD : 0 < x - x^3/4 := by linarith
  have hC : x - x^3/4 ≤ Real.sin x := le_of_lt h1
  have hlow : 15*x/32 ≤ x/2 - x^3/32 := by linarith
  have hsq : (15*x/32)^2 ≤ (x/2 - x^3/32)^2 := by nlinarith [hlow, hx.le]
  have hB2 : (43:ℝ)/100 * x^2 ≤ 2*(x/2 - x^3/32)^2 := by nlinarith [hsq]
  have key : x ≤ (x - x^3/4) * (1 + 2*(x/2 - x^3/32)^2) := by
    nlinarith [hB2, hD, hx5, pow_pos hx 3, pow_pos hx 5]
  calc x ≤ (x - x^3/4) * (1 + 2*(x/2 - x^3/32)^2) := key
  _ ≤ Real.sin x * (1 + 2 * Real.sin (x/2)^2) :=
      mul_le_mul hC (by linarith) (by positivity) (by linarith)
  _ = Real.sin x * (2 - Real.cos x) := by rw [h2]; ring

/-- The same inequality on the harder middle range `[1, 2.1]`, where the Maclaurin
bounds at the origin are already too lossy.  Recentring at `π/2` turns the claim
into two polynomial inequalities in `y = x - π/2 ∈ [1 - π/2, 2.1 - π/2]`, solved
from `cos y ≥ 1 - y²/2` together with `sin y ≥ y` (for `y ≤ 0`) resp.
`sin y ≥ y - y³/4` (for `y ≥ 0`). -/
lemma le_sin_mul_two_sub_cos_mid {x : ℝ} (hx : 1 ≤ x) (hx2 : x ≤ 2.1) :
    x ≤ Real.sin x * (2 - Real.cos x) := by
  have hpi1 : (3.1415:ℝ) < Real.pi := Real.pi_gt_d4
  have hpi2 : Real.pi < 3.1416 := Real.pi_lt_d4
  set y : ℝ := x - Real.pi / 2 with hy
  have hxy : x = y + Real.pi / 2 := by rw [hy]; ring
  have hs : Real.sin x = Real.cos y := by rw [hxy, Real.sin_add_pi_div_two]
  have hc : Real.cos x = -Real.sin y := by rw [hxy, Real.cos_add_pi_div_two]
  rw [hs, hc]
  have hcy : 1 - y^2/2 ≤ Real.cos y := Real.one_sub_sq_div_two_le_cos
  rcases le_or_gt y 0 with hle | hgt
  · have hylow : -0.5708 ≤ y := by rw [hy]; linarith
    have hsy : y ≤ Real.sin y := Real.le_sin hle
    have hpos : (0:ℝ) < 1 - y^2/2 := by nlinarith
    have hmul : (1 - y^2/2) * (2 + y) ≤ Real.cos y * (2 - -Real.sin y) :=
      mul_le_mul hcy (by linarith) (by linarith) (by nlinarith [Real.cos_le_one y])
    nlinarith [hmul]
  · have hyup : y ≤ 0.5293 := by rw [hy]; linarith
    have hsy : y - y^3/4 ≤ Real.sin y := le_of_lt (Real.sin_gt_sub_cube hgt (by linarith))
    have hpos : (0:ℝ) < 1 - y^2/2 := by nlinarith
    have hy3 : y^3 ≤ y := by nlinarith
    have hmul : (1 - y^2/2) * (2 + (y - y^3/4)) ≤ Real.cos y * (2 - -Real.sin y) :=
      mul_le_mul hcy (by linarith) (by nlinarith) (by nlinarith [Real.cos_le_one y])
    nlinarith [hmul, pow_pos hgt 3, pow_pos hgt 5, sq_nonneg y]

/-- **The Rayleigh inequality on `(0, 2.1]`.**  Combining the two ranges more than
doubles the reach of the elementary estimate; the true breakdown point is
`x* = 2.13918…`, so `2.1` is within `2%` of optimal. -/
theorem le_sin_mul_two_sub_cos_extended {x : ℝ} (hx : 0 < x) (hx2 : x ≤ 2.1) :
    x ≤ Real.sin x * (2 - Real.cos x) := by
  rcases le_or_gt x 1 with h | h
  · exact le_sin_mul_two_sub_cos hx h
  · exact le_sin_mul_two_sub_cos_mid h.le hx2

/-- **Reverse Rayleigh inequality, crude range.**  Past `x = π` the inequality
fails irreparably: the left side is trapped in `[-3, 3]` while the right side has
already passed `π > 3`. -/
theorem sin_mul_two_sub_cos_lt_pi {x : ℝ} (hx : Real.pi ≤ x) :
    Real.sin x * (2 - Real.cos x) < x := by
  have h3 : Real.sin x * (2 - Real.cos x) ≤ 3 := by
    nlinarith [Real.sin_le_one x, Real.neg_one_le_sin x, Real.cos_le_one x,
      Real.neg_one_le_cos x]
  have : (3:ℝ) < Real.pi := Real.pi_gt_three
  linarith

/-- The degree-7 polynomial inequality certifying the reversal on `[2.2, π]`,
after recentring at `π/2`. -/
private lemma rayleigh_dip_poly {y : ℝ} (h1 : (0.6292:ℝ) ≤ y) (h2 : y ≤ 1.5708) :
    (1 - 2*(y/2 - (y/2)^3/4)^2) * (2 + y) < y + 1.57075 := by
  nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ y - 0.6292) (by linarith : (0:ℝ) ≤ 1.5708 - y),
    sq_nonneg (y - 1), sq_nonneg y, pow_pos (by linarith : (0:ℝ) < y) 3,
    pow_pos (by linarith : (0:ℝ) < y) 4, pow_pos (by linarith : (0:ℝ) < y) 5,
    pow_pos (by linarith : (0:ℝ) < y) 6, pow_pos (by linarith : (0:ℝ) < y) 7]

/-- A cubic *upper* bound for the cosine, obtained from the half-angle identity
`cos y = 1 - 2 sin²(y/2)` and Mathlib's cubic *lower* bound for the sine.  This
is the estimate the Maclaurin library lemmas do not supply directly. -/
private lemma cos_le_one_sub_two_mul_half_cubic {y : ℝ} (hy0 : 0 < y) (hy1 : y ≤ 1.5708) :
    Real.cos y ≤ 1 - 2 * (y/2 - (y/2)^3/4)^2 := by
  have hu : 0 < y/2 := by linarith
  have ht : y/2 ≤ 0.7854 := by linarith
  have hlow : y/2 - (y/2)^3/4 < Real.sin (y/2) := Real.sin_gt_sub_cube hu (by linarith)
  have ht2 : (y/2)^2 ≤ 0.62 := by nlinarith [hu, ht]
  have hcube : (y/2)^3 ≤ 0.62 * (y/2) := by nlinarith [ht2, hu.le]
  have hupos : 0 < y/2 - (y/2)^3/4 := by nlinarith [hu]
  have hcos2 : Real.cos y = 1 - 2 * Real.sin (y/2)^2 := by
    have ha : Real.sin (y/2)^2 + Real.cos (y/2)^2 = 1 := Real.sin_sq_add_cos_sq _
    have hb := Real.cos_two_mul (y/2)
    rw [show 2*(y/2) = y by ring] at hb
    nlinarith
  nlinarith [hcos2, hlow, hupos]

/-- The reversal on the delicate range `[2.2, π]`, where the crude `±3` bound is
still useless.  Recentring at `π/2` and feeding the cubic cosine upper bound into
a degree-7 polynomial certificate does it. -/
lemma sin_mul_two_sub_cos_lt_mid {x : ℝ} (hx : 2.2 ≤ x) (hxu : x ≤ Real.pi) :
    Real.sin x * (2 - Real.cos x) < x := by
  have hpi1 : (3.1415:ℝ) < Real.pi := Real.pi_gt_d4
  have hpi2 : Real.pi < 3.1416 := Real.pi_lt_d4
  set y : ℝ := x - Real.pi / 2 with hy
  have hxy : x = y + Real.pi / 2 := by rw [hy]; ring
  have hs : Real.sin x = Real.cos y := by rw [hxy, Real.sin_add_pi_div_two]
  have hc : Real.cos x = -Real.sin y := by rw [hxy, Real.cos_add_pi_div_two]
  have hylo : (0.6292:ℝ) ≤ y := by rw [hy]; linarith
  have hyhi : y ≤ 1.5708 := by rw [hy]; linarith
  rw [hs, hc]
  have hsy : Real.sin y ≤ y := Real.sin_le (by linarith)
  have hsin1 : (-1:ℝ) ≤ Real.sin y := Real.neg_one_le_sin y
  rcases le_or_gt (Real.cos y) 0 with hneg | hposc
  · nlinarith
  · have hB := cos_le_one_sub_two_mul_half_cubic (by linarith : (0:ℝ) < y) hyhi
    have hstep : Real.cos y * (2 - -Real.sin y) ≤ (1 - 2*(y/2 - (y/2)^3/4)^2) * (2 + y) :=
      mul_le_mul hB (by linarith) (by linarith) (by nlinarith)
    linarith [hstep, rayleigh_dip_poly hylo hyhi]

/-- **Reverse Rayleigh inequality.**  For every `x ≥ 2.2` the inequality
`sin x (2 - cos x) ≥ x` fails strictly.  Since it *holds* on `(0, 2.1]`, the
breakdown point is pinned inside `(2.1, 2.2)`; numerically it is `2.13918…`. -/
theorem sin_mul_two_sub_cos_lt {x : ℝ} (hx : 2.2 ≤ x) :
    Real.sin x * (2 - Real.cos x) < x := by
  rcases le_or_gt x Real.pi with h | h
  · exact sin_mul_two_sub_cos_lt_mid hx h
  · exact sin_mul_two_sub_cos_lt_pi h.le

/-- Closed form for the response at one of the two tone centres: the tone's own
peak `2T` plus the tail of its partner. -/
theorem twoToneResponse_center_re {T Δ : ℝ} (hΔ : 0 < Δ) :
    (twoToneResponse T Δ (Δ/2)).re
      = (4 * (Δ * T / 2) + 4 * Real.sin (Δ*T/2) * Real.cos (Δ*T/2)) / Δ := by
  unfold twoToneResponse
  rw [show Δ/2 - Δ/2 = (0:ℝ) by ring, show Δ/2 + Δ/2 = Δ by ring,
    windowedTone_resonance, windowedTone_off_resonance _ _ (ne_of_gt hΔ)]
  simp only [Complex.add_re, Complex.ofReal_re]
  have hdouble : Real.sin (Δ * T) = 2 * Real.sin (Δ*T/2) * Real.cos (Δ*T/2) := by
    have h := Real.sin_two_mul (Δ*T/2)
    rw [show 2*(Δ*T/2) = Δ*T by ring] at h
    exact h
  rw [hdouble]
  field_simp
  ring

/-- Closed form for the response at the midpoint of the two tones: twice the
common sidelobe value. -/
theorem twoToneResponse_mid_re {T Δ : ℝ} (hΔ : 0 < Δ) :
    (twoToneResponse T Δ 0).re = 8 * Real.sin (Δ*T/2) / Δ := by
  have hhalf : Δ / 2 ≠ 0 := by positivity
  have hneg : -(Δ / 2) ≠ 0 := neg_ne_zero.mpr hhalf
  unfold twoToneResponse
  rw [show (0:ℝ) - Δ/2 = -(Δ/2) by ring, show (0:ℝ) + Δ/2 = Δ/2 by ring,
    windowedTone_off_resonance _ _ hneg, windowedTone_off_resonance _ _ hhalf]
  simp only [Complex.add_re, Complex.ofReal_re]
  rw [show -(Δ/2) * T = -(Δ*T/2) by ring, show Δ/2 * T = Δ*T/2 by ring, Real.sin_neg]
  field_simp
  ring

/-- **Rayleigh criterion, unresolved side.** If the separation satisfies
`ΔT ≤ 4.2`, the midpoint of the two tones is *at least as bright* as either tone
centre: there is no central dip, so the pair cannot be resolved. -/
theorem rayleigh_no_central_dip {T Δ : ℝ} (hT : 0 < T) (hΔ : 0 < Δ) (h : Δ * T ≤ 4.2) :
    (twoToneResponse T Δ (Δ/2)).re ≤ (twoToneResponse T Δ 0).re := by
  rw [twoToneResponse_center_re hΔ, twoToneResponse_mid_re hΔ,
    div_le_div_iff_of_pos_right hΔ]
  have hxpos : 0 < Δ * T / 2 := by positivity
  have hxle : Δ * T / 2 ≤ 2.1 := by linarith
  nlinarith [le_sin_mul_two_sub_cos_extended hxpos hxle]

/-- **Rayleigh criterion, resolved side.** As soon as `ΔT ≥ 4.4` the midpoint
response is *strictly* below the response at either tone centre: a genuine
central dip appears and the pair is resolved. -/
theorem rayleigh_strict_dip {T Δ : ℝ} (hΔ : 0 < Δ) (h : 4.4 ≤ Δ * T) :
    (twoToneResponse T Δ 0).re < (twoToneResponse T Δ (Δ/2)).re := by
  rw [twoToneResponse_center_re hΔ, twoToneResponse_mid_re hΔ,
    div_lt_div_iff_of_pos_right hΔ]
  have hxge : (2.2:ℝ) ≤ Δ * T / 2 := by linarith
  nlinarith [sin_mul_two_sub_cos_lt hxge]

/-- **Rayleigh criterion, resolved side (exact null).** At the separation
`Δ = 2π/T` the midpoint response vanishes exactly while each tone centre still
carries the full peak `2T`: the two tones are separated by a total null. -/
theorem rayleigh_full_dip {T : ℝ} (hT : 0 < T) :
    (twoToneResponse T (2 * Real.pi / T) 0).re = 0 ∧
      (twoToneResponse T (2 * Real.pi / T) (Real.pi / T)).re = 2 * T := by
  have hpi : (0:ℝ) < Real.pi := Real.pi_pos
  have hhalf : (2 * Real.pi / T) / 2 = Real.pi / T := by field_simp
  constructor
  · unfold twoToneResponse
    rw [hhalf, show (0:ℝ) - Real.pi / T = -(Real.pi / T) by ring,
      show (0:ℝ) + Real.pi / T = Real.pi / T by ring,
      windowedTone_off_resonance _ _ (by positivity : Real.pi / T ≠ 0),
      windowedTone_off_resonance _ _ (neg_ne_zero.mpr (by positivity : Real.pi / T ≠ 0))]
    have h1 : Real.pi / T * T = Real.pi := by field_simp
    have h2 : -(Real.pi / T) * T = -Real.pi := by field_simp
    simp only [Complex.add_re, Complex.ofReal_re]
    rw [h1, h2, Real.sin_neg, Real.sin_pi]
    simp
  · unfold twoToneResponse
    rw [hhalf, show Real.pi / T - Real.pi / T = 0 by ring,
      show Real.pi / T + Real.pi / T = 2 * Real.pi / T by ring,
      windowedTone_resonance,
      windowedTone_off_resonance _ _ (by positivity : 2 * Real.pi / T ≠ 0)]
    have h1 : 2 * Real.pi / T * T = 2 * Real.pi := by field_simp
    simp only [Complex.add_re, Complex.ofReal_re]
    rw [h1, show (2:ℝ) * Real.pi = 2 * Real.pi by ring, Real.sin_two_pi]
    simp

/-- **Two-sided bracket for the Rayleigh threshold.**  For a rectangular window
of half-length `T`, the critical time–bandwidth product at which a central dip
first appears lies in the interval `(4.2, 4.4]`: no dip can occur while
`ΔT ≤ 4.2`, and a dip is guaranteed once `ΔT ≥ 4.4`.  The true value is
`(ΔT)_crit = 4.27836…`, so the bracket has relative width under `5%` and the
classical Rayleigh prescription `Δ = 2π/T` sits well on the resolved side. -/
theorem rayleigh_threshold_bracket {T : ℝ} (hT : 0 < T) :
    (∀ Δ : ℝ, 0 < Δ → Δ * T ≤ 4.2 →
        ¬ (twoToneResponse T Δ 0).re < (twoToneResponse T Δ (Δ/2)).re) ∧
      (∀ Δ : ℝ, 0 < Δ → 4.4 ≤ Δ * T →
        (twoToneResponse T Δ 0).re < (twoToneResponse T Δ (Δ/2)).re) :=
  ⟨fun _ hΔ h => not_lt.mpr (rayleigh_no_central_dip hT hΔ h),
    fun _ hΔ h => rayleigh_strict_dip hΔ h⟩

/-! ### Cycle VI: the exact Rayleigh threshold

The bracket above is closed completely by a monotonicity argument.  Writing
`G(x) = sin x (2 - cos x) - x`, a one-line computation gives

  `G'(x) = 2 cos x (1 - cos x)`,

which is *positive* on `(0, π/2)` and *negative* on `(π/2, π)`.  So `G` rises from
`G(0) = 0` to `G(π/2) = 2 - π/2 > 0` and then falls to `G(π) = -π < 0`, crossing
zero exactly once.  Past `π` it stays negative for trivial size reasons.  The two
numerical inequalities already proved, `G(2.1) ≥ 0` and `G(2.2) < 0`, then locate
the crossing inside `[2.1, 2.2)`. -/

/-- The Rayleigh gap function `G(x) = sin x (2 - cos x) - x`, whose sign decides
whether two tones at scaled separation `x = ΔT/2` are resolved. -/
def rayleighGap (x : ℝ) : ℝ := Real.sin x * (2 - Real.cos x) - x

lemma continuous_rayleighGap : Continuous rayleighGap := by
  unfold rayleighGap; fun_prop

/-- `G'(x) = 2 cos x (1 - cos x)`: the whole monotonicity analysis in one line. -/
lemma hasDerivAt_rayleighGap (x : ℝ) :
    HasDerivAt rayleighGap (2 * Real.cos x * (1 - Real.cos x)) x := by
  have h1 : HasDerivAt Real.sin (Real.cos x) x := Real.hasDerivAt_sin x
  have h2 : HasDerivAt (fun t : ℝ => 2 - Real.cos t) (Real.sin x) x := by
    simpa using ((Real.hasDerivAt_cos x).const_sub 2)
  have h3 := (h1.mul h2).sub (hasDerivAt_id x)
  convert h3 using 1
  nlinarith [Real.sin_sq_add_cos_sq x]

lemma strictMonoOn_rayleighGap : StrictMonoOn rayleighGap (Set.Icc 0 (Real.pi/2)) := by
  apply strictMonoOn_of_deriv_pos (convex_Icc _ _) continuous_rayleighGap.continuousOn
  intro x hx
  rw [interior_Icc] at hx
  rw [(hasDerivAt_rayleighGap x).deriv]
  have hc : 0 < Real.cos x := Real.cos_pos_of_mem_Ioo ⟨by linarith [hx.1, Real.pi_pos], hx.2⟩
  have hs : 0 < Real.sin x := Real.sin_pos_of_pos_of_lt_pi hx.1 (by linarith [hx.2, Real.pi_pos])
  have hc1 : Real.cos x < 1 := by nlinarith [Real.sin_sq_add_cos_sq x, mul_pos hs hs]
  nlinarith [hc, hc1]

lemma strictAntiOn_rayleighGap : StrictAntiOn rayleighGap (Set.Icc (Real.pi/2) Real.pi) := by
  apply strictAntiOn_of_deriv_neg (convex_Icc _ _) continuous_rayleighGap.continuousOn
  intro x hx
  rw [interior_Icc] at hx
  rw [(hasDerivAt_rayleighGap x).deriv]
  have hc : Real.cos x < 0 :=
    Real.cos_neg_of_pi_div_two_lt_of_lt hx.1 (by linarith [hx.2, Real.pi_pos])
  nlinarith [Real.neg_one_le_cos x]

lemma rayleighGap_zero : rayleighGap 0 = 0 := by simp [rayleighGap]

lemma rayleighGap_pi : rayleighGap Real.pi = -Real.pi := by simp [rayleighGap]

lemma rayleighGap_pi_div_two_pos : 0 < rayleighGap (Real.pi/2) := by
  simp [rayleighGap]; linarith [Real.pi_lt_d2]

/-- **The exact Rayleigh threshold.**  There is a single critical scale `xc`,
located in `[2.1, 2.2)`, such that `sin x (2 - cos x) ≥ x` holds strictly below
`xc`, with equality at `xc`, and fails strictly above it.  This upgrades the
two-sided bracket into a complete description of the sign of the Rayleigh gap. -/
theorem exists_rayleigh_critical_scale :
    ∃ xc : ℝ, 2.1 ≤ xc ∧ xc < 2.2 ∧
      (∀ x : ℝ, 0 < x → x < xc → x < Real.sin x * (2 - Real.cos x)) ∧
      Real.sin xc * (2 - Real.cos xc) = xc ∧
      (∀ x : ℝ, xc < x → Real.sin x * (2 - Real.cos x) < x) := by
  have hpi := Real.pi_pos
  have hpi3 : (3:ℝ) < Real.pi := Real.pi_gt_three
  have hle : Real.pi/2 ≤ Real.pi := by linarith
  -- locate the crossing by the intermediate value theorem
  obtain ⟨xc, hxcmem, hxc0⟩ : ∃ xc ∈ Set.Ioo (Real.pi/2) Real.pi, rayleighGap xc = 0 := by
    have hsub := intermediate_value_Ioo' hle continuous_rayleighGap.continuousOn
    have h0 : (0:ℝ) ∈ Set.Ioo (rayleighGap Real.pi) (rayleighGap (Real.pi/2)) :=
      ⟨by rw [rayleighGap_pi]; linarith, rayleighGap_pi_div_two_pos⟩
    obtain ⟨xc, hxc, hF⟩ := hsub h0
    exact ⟨xc, hxc, hF⟩
  have hxclo : Real.pi/2 < xc := hxcmem.1
  have hxchi : xc < Real.pi := hxcmem.2
  -- the gap is positive strictly below `xc`
  have hpos : ∀ x : ℝ, 0 < x → x < xc → 0 < rayleighGap x := by
    intro x hx0 hxlt
    rcases le_or_gt x (Real.pi/2) with h | h
    · have := strictMonoOn_rayleighGap (Set.left_mem_Icc.mpr (by linarith))
        (Set.mem_Icc.mpr ⟨hx0.le, h⟩) hx0
      rwa [rayleighGap_zero] at this
    · have := strictAntiOn_rayleighGap (Set.mem_Icc.mpr ⟨h.le, by linarith⟩)
        (Set.mem_Icc.mpr ⟨hxclo.le, hxchi.le⟩) hxlt
      rw [hxc0] at this; linarith
  -- and negative strictly above it
  have hneg : ∀ x : ℝ, xc < x → rayleighGap x < 0 := by
    intro x hxgt
    rcases le_or_gt x Real.pi with h | h
    · have := strictAntiOn_rayleighGap (Set.mem_Icc.mpr ⟨hxclo.le, hxchi.le⟩)
        (Set.mem_Icc.mpr ⟨by linarith, h⟩) hxgt
      rw [hxc0] at this; linarith
    · have h3 : Real.sin x * (2 - Real.cos x) ≤ 3 := by
        nlinarith [Real.sin_le_one x, Real.neg_one_le_sin x, Real.cos_le_one x,
          Real.neg_one_le_cos x]
      unfold rayleighGap; linarith
  -- the numeric inequalities already proved pin `xc` down to `[2.1, 2.2)`
  refine ⟨xc, ?_, ?_, ?_, ?_, ?_⟩
  · by_contra hcon
    push_neg at hcon
    have h1 := hneg 2.1 hcon
    have h2 := le_sin_mul_two_sub_cos_extended (by norm_num : (0:ℝ) < 2.1) le_rfl
    unfold rayleighGap at h1; linarith
  · by_contra hcon
    push_neg at hcon
    have h2 : Real.sin 2.2 * (2 - Real.cos 2.2) < 2.2 := sin_mul_two_sub_cos_lt le_rfl
    rcases eq_or_lt_of_le hcon with heq | hlt
    · rw [← heq] at hxc0; unfold rayleighGap at hxc0; linarith
    · have h1 := hpos 2.2 (by norm_num) hlt
      unfold rayleighGap at h1; linarith
  · intro x hx0 hxlt
    have := hpos x hx0 hxlt
    unfold rayleighGap at this
    linarith
  · have := hxc0
    unfold rayleighGap at this
    linarith
  · intro x hxgt
    have := hneg x hxgt
    unfold rayleighGap at this
    linarith

/-- **Sharp Rayleigh criterion for the rectangular window.**  There is an exact
critical time–bandwidth product `c ∈ [4.2, 4.4)` — numerically `4.27836…` — below
which the midpoint of two equal tones is strictly brighter than either tone
centre (unresolved) and above which it is strictly darker (resolved). -/
theorem rayleigh_threshold_exact {T : ℝ} (hT : 0 < T) :
    ∃ c : ℝ, 4.2 ≤ c ∧ c < 4.4 ∧
      (∀ Δ : ℝ, 0 < Δ → Δ * T < c →
        (twoToneResponse T Δ (Δ/2)).re < (twoToneResponse T Δ 0).re) ∧
      (∀ Δ : ℝ, 0 < Δ → c < Δ * T →
        (twoToneResponse T Δ 0).re < (twoToneResponse T Δ (Δ/2)).re) := by
  obtain ⟨xc, hlo, hhi, hpos, _, hneg⟩ := exists_rayleigh_critical_scale
  refine ⟨2 * xc, by linarith, by linarith, ?_, ?_⟩
  · intro Δ hΔ h
    rw [twoToneResponse_center_re hΔ, twoToneResponse_mid_re hΔ,
      div_lt_div_iff_of_pos_right hΔ]
    have hx0 : 0 < Δ * T / 2 := by positivity
    nlinarith [hpos (Δ * T / 2) hx0 (by linarith)]
  · intro Δ hΔ h
    rw [twoToneResponse_center_re hΔ, twoToneResponse_mid_re hΔ,
      div_lt_div_iff_of_pos_right hΔ]
    nlinarith [hneg (Δ * T / 2) (by linarith)]

/-! ## Cycle IV: Fejér's triangular identity and its transfer to the window

Squaring the Weyl sum and grouping index pairs by their difference turns the
modulus into a *positive* trigonometric polynomial with triangular weights: the
Fejér kernel.  The sampling bridge then carries the identity to the continuous
window verbatim, so the same triangular weights describe the energy of the
rectangularly windowed tone. -/

/-- The cross term produced by extending the Weyl sum by one sample. -/
lemma weylSum_mul_conj_re (N : ℕ) (α : ℝ) :
    (weylSum N α * (starRingEnd ℂ) (Complex.exp (2 * Real.pi * Complex.I * N * α))).re
      = ∑ n ∈ Finset.range N, Real.cos (2 * Real.pi * ((N:ℝ) - n) * α) := by
  unfold weylSum
  rw [Finset.sum_mul, Complex.re_sum]
  refine Finset.sum_congr rfl (fun n _ => ?_)
  rw [← Complex.exp_conj, ← Complex.exp_add]
  have hc : (starRingEnd ℂ) (2 * (Real.pi:ℂ) * Complex.I * N * α)
      = -(2 * (Real.pi:ℂ) * Complex.I * N * α) := by simp [Complex.ext_iff]
  rw [hc, show (2 * (Real.pi:ℂ) * Complex.I * n * α + -(2 * (Real.pi:ℂ) * Complex.I * N * α))
      = ((-(2 * Real.pi * ((N:ℝ) - n) * α) : ℝ) : ℂ) * Complex.I by push_cast; ring,
    Complex.exp_ofReal_mul_I_re, Real.cos_neg]

/-- Reflecting the index of a cosine sum. -/
lemma sum_cos_reflect (N : ℕ) (α : ℝ) :
    ∑ n ∈ Finset.range N, Real.cos (2 * Real.pi * ((N:ℝ) - n) * α)
      = ∑ d ∈ Finset.range N, Real.cos (2 * Real.pi * d * α)
        + Real.cos (2 * Real.pi * N * α) - 1 := by
  set g : ℕ → ℝ := fun k => Real.cos (2 * Real.pi * (k:ℝ) * α) with hg
  have h1 : ∑ n ∈ Finset.range N, Real.cos (2 * Real.pi * ((N:ℝ) - n) * α)
      = ∑ n ∈ Finset.range N, g (N - n) := by
    refine Finset.sum_congr rfl (fun n hn => ?_)
    have hle : n ≤ N := le_of_lt (Finset.mem_range.mp hn)
    rw [hg]; simp only; rw [Nat.cast_sub hle]
  have h2 : ∑ n ∈ Finset.range N, g (N - n) = ∑ n ∈ Finset.range N, g (n + 1) := by
    rw [← Finset.sum_range_reflect (fun j => g (j + 1)) N]
    refine Finset.sum_congr rfl (fun j hj => ?_)
    have hj' := Finset.mem_range.mp hj
    congr 1
    omega
  have h3 : ∑ n ∈ Finset.range N, g (n + 1) = (∑ n ∈ Finset.range (N + 1), g n) - g 0 := by
    rw [Finset.sum_range_succ']; ring
  rw [h1, h2, h3, Finset.sum_range_succ]
  simp [hg]

/-- **Fejér's triangular identity.** The squared modulus of a Weyl sum is the
triangular-weight cosine polynomial `2 ∑_{d<N} (N-d) cos(2πdα) - N`. -/
theorem weylSum_normSq_fejer (N : ℕ) (α : ℝ) :
    ‖weylSum N α‖ ^ 2
      = 2 * ∑ d ∈ Finset.range N, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α) - N := by
  induction N with
  | zero => simp [weylSum]
  | succ N ih =>
    have hstep : weylSum (N+1) α
        = weylSum N α + Complex.exp (2 * Real.pi * Complex.I * N * α) := by
      unfold weylSum; rw [Finset.sum_range_succ]
    have hnorm : ‖Complex.exp (2 * (Real.pi:ℂ) * Complex.I * (N:ℂ) * (α:ℂ))‖ = 1 := by
      rw [show (2 * (Real.pi:ℂ) * Complex.I * (N:ℂ) * (α:ℂ))
          = ((2 * Real.pi * (N:ℝ) * α : ℝ) : ℂ) * Complex.I by push_cast; ring]
      exact Complex.norm_exp_ofReal_mul_I _
    have hterm : ∀ d ∈ Finset.range N, ((N + 1 - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α)
        = ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α) + Real.cos (2 * Real.pi * d * α) := by
      intro d hd
      have hd' : d < N := Finset.mem_range.mp hd
      have he : N + 1 - d = (N - d) + 1 := by omega
      rw [he]; push_cast; ring
    have hRHS : ∑ d ∈ Finset.range (N+1), ((N + 1 - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α)
        = ∑ d ∈ Finset.range N, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α)
          + ∑ d ∈ Finset.range N, Real.cos (2 * Real.pi * d * α)
          + Real.cos (2 * Real.pi * N * α) := by
      rw [Finset.sum_range_succ, Finset.sum_congr rfl hterm, Finset.sum_add_distrib]
      have hlast : ((N + 1 - N : ℕ):ℝ) = 1 := by simp
      rw [hlast, one_mul]
    rw [hstep, Complex.sq_norm, Complex.normSq_add, ← Complex.sq_norm, ← Complex.sq_norm, ih,
      hnorm, weylSum_mul_conj_re, sum_cos_reflect, hRHS]
    push_cast
    ring

/-- **Fejér positivity.** The triangular cosine polynomial is nonnegative for
every frequency — it is a squared modulus. -/
theorem fejer_nonneg (N : ℕ) (α : ℝ) :
    0 ≤ 2 * ∑ d ∈ Finset.range N, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α) - N := by
  rw [← weylSum_normSq_fejer]
  positivity

/-- **Transfer of the Fejér identity to the continuous window** through the
sampling bridge: the energy of the window of length `N` is the triangular
polynomial times the energy of a single sampling cell. -/
theorem norm_contTone_sq_fejer (N : ℕ) (α : ℝ) :
    ‖contTone (N : ℝ) α‖ ^ 2
      = (2 * ∑ d ∈ Finset.range N, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α) - N)
        * ‖contTone 1 α‖ ^ 2 := by
  rw [contTone_eq_weylSum_mul, norm_mul, mul_pow, weylSum_normSq_fejer]

/-! ## Cycle VII: the exact `2/π` limit and the Fejér kernel as an approximate identity

Two residual questions from the previous cycles are settled here.  First, the
sharpness of the discrete main-lobe constant is upgraded from the quantitative
sandwich `2/π · N ≤ ‖S_N(1/(2N))‖ ≤ 2/π · N + 1/N` to the *exact* limit
`‖S_N(1/(2N))‖ / N → 2/π`, which shows that no constant larger than `2/π` is
available in `norm_weylSum_ge_jordan`.  Second, the triangular identity is
completed into the three defining properties of an approximate identity:
nonnegativity (already proved), unit total mass over one period, and
concentration — away from the integers the kernel is bounded by `1/(4δ²)`,
uniformly in `N`. -/

/-- **The `2/π` main-lobe constant is exactly attained in the limit.**  At the edge
`α = 1/(2N)` of the main lobe the normalized Weyl sum converges to `2/π`, so the
Jordan bound `norm_weylSum_ge_jordan` is asymptotically optimal. -/
theorem norm_weylSum_endpoint_ratio_tendsto :
    Filter.Tendsto (fun N : ℕ => ‖weylSum N (1 / (2 * N))‖ / N) Filter.atTop
      (nhds (2 / Real.pi)) := by
  have h1 : Filter.Tendsto (fun N : ℕ => (1:ℝ) / N) Filter.atTop (nhds 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hupper : Filter.Tendsto (fun N : ℕ => 2 / Real.pi + (1:ℝ)/N * (1/N)) Filter.atTop
      (nhds (2 / Real.pi)) := by
    simpa using (tendsto_const_nhds (x := 2 / Real.pi) (f := Filter.atTop (α := ℕ))).add (h1.mul h1)
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [Filter.eventually_gt_atTop 0] with N hN
    have hNR : (0:ℝ) < N := by exact_mod_cast hN
    rw [le_div_iff₀ hNR]
    have h := norm_weylSum_ge_jordan N (α := 1/(2*(N:ℝ)))
      (by rw [abs_of_nonneg (by positivity : (0:ℝ) ≤ 1/(2*(N:ℝ)))])
    linarith
  · filter_upwards [Filter.eventually_gt_atTop 0] with N hN
    have hNR : (0:ℝ) < N := by exact_mod_cast hN
    rw [div_le_iff₀ hNR]
    have h := norm_weylSum_endpoint_le (N := N) hN
    have he : (2 / Real.pi + (1:ℝ)/N * (1/N)) * N = 2/Real.pi * N + 1/N := by field_simp
    rw [he]
    exact h

/-- A pure harmonic has no mean over a full period. -/
lemma integral_cos_two_pi_mul_nat {d : ℕ} (hd : d ≠ 0) :
    ∫ α in (0:ℝ)..1, Real.cos (2 * Real.pi * d * α) = 0 := by
  have hdR : (0:ℝ) < d := by exact_mod_cast Nat.pos_of_ne_zero hd
  have hc : (2 * Real.pi * (d:ℝ)) ≠ 0 := by positivity
  have h := intervalIntegral.integral_comp_mul_left (a := (0:ℝ)) (b := 1)
      (c := 2 * Real.pi * (d:ℝ)) Real.cos hc
  have hs : Real.sin (2 * Real.pi * (d:ℝ)) = 0 := by
    rw [show 2 * Real.pi * (d:ℝ) = ((2 * d : ℤ):ℝ) * Real.pi by push_cast; ring]
    exact Real.sin_int_mul_pi _
  simp only [mul_one, mul_zero] at h
  rw [h, integral_cos, hs]
  simp

lemma intervalIntegrable_cos_two_pi_mul (d : ℕ) :
    IntervalIntegrable (fun α : ℝ => Real.cos (2 * Real.pi * d * α)) MeasureTheory.volume 0 1 :=
  (by fun_prop : Continuous fun α : ℝ => Real.cos (2 * Real.pi * d * α)).intervalIntegrable _ _

/-- **Total mass of the Fejér kernel.**  Over one period the triangular kernel
integrates to `N`, so its normalization `K_N/N` has unit mass — the second of the
three approximate-identity properties. -/
theorem fejer_kernel_mass (N : ℕ) :
    ∫ α in (0:ℝ)..1,
        (2 * ∑ d ∈ Finset.range N, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α) - N) = N := by
  have hint : ∀ d ∈ Finset.range N,
      IntervalIntegrable (fun α : ℝ => ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α))
        MeasureTheory.volume 0 1 := fun d _ => (intervalIntegrable_cos_two_pi_mul d).const_mul _
  have hsum : IntervalIntegrable
      (fun α : ℝ => ∑ d ∈ Finset.range N, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α))
      MeasureTheory.volume 0 1 := by
    apply Continuous.intervalIntegrable
    exact continuous_finset_sum _ (fun d _ => by fun_prop)
  rw [intervalIntegral.integral_sub (hsum.const_mul 2) intervalIntegrable_const,
    intervalIntegral.integral_const_mul, intervalIntegral.integral_finset_sum hint]
  have hterms : ∀ d ∈ Finset.range N,
      (∫ α in (0:ℝ)..1, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α))
        = if d = 0 then (N:ℝ) else 0 := by
    intro d _
    rw [intervalIntegral.integral_const_mul]
    by_cases h0 : d = 0
    · subst h0; simp
    · rw [integral_cos_two_pi_mul_nat h0, if_neg h0, mul_zero]
  rw [Finset.sum_congr rfl hterms]
  by_cases hN : N = 0
  · subst hN; simp
  · rw [Finset.sum_ite_eq' (Finset.range N) 0 (fun _ => (N:ℝ)),
      if_pos (Finset.mem_range.mpr (Nat.pos_of_ne_zero hN))]
    simp
    ring

/-- **Concentration of the Fejér kernel.**  At distance at least `δ` from the
integers the triangular kernel is bounded by `1/(4δ²)` *uniformly in `N`*, so its
normalization `K_N/N` vanishes off any neighbourhood of the integers.  Together
with `fejer_nonneg` and `fejer_kernel_mass` this exhibits `K_N/N` as a
nonnegative approximate identity on the circle. -/
theorem fejer_kernel_concentration (N : ℕ) {α δ : ℝ} (hδ : 0 < δ) (h : δ ≤ intDist α) :
    2 * ∑ d ∈ Finset.range N, ((N - d : ℕ):ℝ) * Real.cos (2 * Real.pi * d * α) - N
      ≤ 1 / (4 * δ ^ 2) := by
  have hpos : 0 < intDist α := lt_of_lt_of_le hδ h
  have hle : ‖weylSum N α‖ ≤ 1 / (2 * δ) := by
    refine (norm_weylSum_le_intDist N hpos).trans ?_
    apply one_div_le_one_div_of_le (by positivity)
    linarith
  rw [← weylSum_normSq_fejer]
  calc ‖weylSum N α‖ ^ 2 ≤ (1 / (2 * δ)) ^ 2 := pow_le_pow_left₀ (norm_nonneg _) hle 2
  _ = 1 / (4 * δ ^ 2) := by field_simp; ring

end OffResonanceWindow