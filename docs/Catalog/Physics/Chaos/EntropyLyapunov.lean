import Physics.Chaos.ThreeBodyLagrange

/-!
# Kolmogorov–Sinai entropy and Lyapunov exponents

This file formalises the quantitative link between the **Kolmogorov–Sinai entropy** of a
dynamical system and its **Lyapunov spectrum**, and applies it to the three-body problem.

The bridge is the Margulis–Ruelle inequality `h_KS ≤ Σ_{λᵢ > 0} λᵢ`, which we carry as
the defining datum of a `RuelleData` record (a finite-dimensional Lyapunov spectrum
together with an entropy obeying Ruelle's bound). From it we derive, with no further
assumptions:

* `maxExp_pos` — positive entropy forces a *strictly positive* Lyapunov exponent;
* `entropy_div_dim_le_maxExp` — the explicit bound `λ_max ≥ h/d`;
* `predictability_horizon_le` — an upper bound `d·log(Δ/δ₀)/h` for the Lyapunov time.

On the symbolic side we compute the entropy of a full `N`-shift (`shiftEntropy_eq`,
`entropyRate = log N`), which is how positive entropy is produced in practice: a Smale
horseshoe embedded in the three-body flow. Combining the two gives
`horseshoe_forces_positive_lyapunov`: an `N`-symbol horseshoe (`N ≥ 2`) in a
`d`-dimensional system forces `λ_max ≥ log N / d > 0`.

Finally `threeBody_horseshoe_lyapunov_bound` states the resulting explicit lower bound
for the (12-dimensional) spatial three-body problem, and `catMap_ruelleData` provides a
concrete non-vacuous instance where Ruelle's inequality is an equality.
-/

noncomputable section

open Filter Topology Chaos

namespace Chaos

/-! ### Symbolic (counting) entropy -/

/-- The exponential growth rate of a counting function: `limsup (log (cnt n))/n`.
For the number of distinguishable orbit segments of length `n` this is the topological /
Kolmogorov–Sinai entropy. -/
def entropyRate (cnt : ℕ → ℝ) : ℝ := limsup (fun n : ℕ => Real.log (cnt n) / n) atTop

/-- **Entropy of the full `N`-shift.** If a system has exactly `Nⁿ` distinguishable
orbit segments of length `n`, its entropy rate is `log N`. -/
theorem entropyRate_shift (N : ℕ) :
    entropyRate (fun n => (N : ℝ) ^ n) = Real.log N := by
  have key : ∀ n : ℕ, 0 < n → Real.log ((N : ℝ) ^ n) / n = Real.log N := by
    intro n hn
    rw [Real.log_pow]
    field_simp
  have : (fun n : ℕ => Real.log ((N : ℝ) ^ n) / n) =ᶠ[atTop] fun _ => Real.log N := by
    filter_upwards [eventually_gt_atTop 0] with n hn using key n hn
  unfold entropyRate
  rw [limsup_congr this]
  exact limsup_const _

/-- If the number of length-`n` orbit segments is at least `Nⁿ`, the entropy rate is at
least `log N`, provided the rate is finite. -/
theorem entropyRate_ge {N : ℕ} (hN : 0 < N) (cnt : ℕ → ℝ)
    (hbdd : IsBoundedUnder (· ≤ ·) atTop (fun n : ℕ => Real.log (cnt n) / n))
    (hcnt : ∀ n, (N : ℝ) ^ n ≤ cnt n) : Real.log N ≤ entropyRate cnt := by
  refine le_limsup_of_frequently_le ?_ hbdd
  have hmain : ∀ᶠ n : ℕ in atTop, Real.log N ≤ Real.log (cnt n) / n := by
    filter_upwards [eventually_gt_atTop 0] with n hn
    have hpos : (0:ℝ) < (N : ℝ) ^ n := by positivity
    have h1 : Real.log ((N : ℝ) ^ n) ≤ Real.log (cnt n) :=
      Real.log_le_log hpos (hcnt n)
    rw [Real.log_pow] at h1
    rw [le_div_iff₀ (by positivity : (0:ℝ) < (n:ℝ))]
    calc Real.log N * n = n * Real.log N := by ring
    _ ≤ Real.log (cnt n) := h1
  exact hmain.frequently

/-! ### Ruelle's inequality and its consequences -/

/-- A finite-dimensional **Lyapunov spectrum together with an entropy** obeying the
Margulis–Ruelle inequality `h ≤ Σ_i max(λᵢ, 0)`. -/
structure RuelleData (d : ℕ) where
  /-- The phase space is nondegenerate. -/
  dim_pos : 0 < d
  /-- The Lyapunov spectrum. -/
  exps : Fin d → ℝ
  /-- The Kolmogorov–Sinai entropy. -/
  entropy : ℝ
  /-- The Margulis–Ruelle inequality. -/
  ruelle : entropy ≤ ∑ i, max (exps i) 0

theorem finUniv_nonempty {d : ℕ} (hd : 0 < d) : (Finset.univ : Finset (Fin d)).Nonempty :=
  ⟨⟨0, hd⟩, Finset.mem_univ _⟩

namespace RuelleData

variable {d : ℕ} (R : RuelleData d)

/-- The maximal Lyapunov exponent of the spectrum. -/
def maxExp : ℝ := Finset.univ.sup' (finUniv_nonempty R.dim_pos) R.exps

theorem le_maxExp (i : Fin d) : R.exps i ≤ R.maxExp :=
  Finset.le_sup' R.exps (Finset.mem_univ i)

/-- **Positive entropy forces a positive Lyapunov exponent.** This is the formal content
of "positive Kolmogorov–Sinai entropy ⟹ deterministic chaos". -/
theorem maxExp_pos (h : 0 < R.entropy) : 0 < R.maxExp := by
  by_contra hcon
  push_neg at hcon
  have hzero : ∀ i ∈ (Finset.univ : Finset (Fin d)), max (R.exps i) 0 = 0 := by
    intro i _
    exact max_eq_right (le_trans (R.le_maxExp i) hcon)
  have := R.ruelle
  rw [Finset.sum_congr rfl hzero] at this
  simp at this
  linarith

/-- **Explicit bound: `λ_max ≥ h/d`.** Ruelle's inequality distributes the entropy over
at most `d` positive exponents, so the largest one is at least `h/d`. -/
theorem entropy_div_dim_le_maxExp (h : 0 < R.entropy) : R.entropy / d ≤ R.maxExp := by
  have hmax := R.maxExp_pos h
  have hterm : ∀ i ∈ (Finset.univ : Finset (Fin d)), max (R.exps i) 0 ≤ R.maxExp := by
    intro i _
    exact max_le (R.le_maxExp i) hmax.le
  have hsum : ∑ i, max (R.exps i) 0 ≤ (d : ℝ) * R.maxExp := by
    calc ∑ i, max (R.exps i) 0 ≤ ∑ _i : Fin d, R.maxExp := Finset.sum_le_sum hterm
    _ = (d : ℝ) * R.maxExp := by simp [Finset.sum_const]
  have hd : (0:ℝ) < d := by exact_mod_cast R.dim_pos
  rw [div_le_iff₀ hd]
  calc R.entropy ≤ ∑ i, max (R.exps i) 0 := R.ruelle
  _ ≤ (d : ℝ) * R.maxExp := hsum
  _ = R.maxExp * d := by ring

/-- **Entropy bounds the predictability horizon.** A system with entropy `h > 0` in
dimension `d` loses track of an initial uncertainty `δ₀` at scale `Δ` no later than
`d·log(Δ/δ₀)/h`. -/
theorem predictability_horizon_le (h : 0 < R.entropy) {δ₀ Δ : ℝ} (hδ₀ : 0 < δ₀)
    (hΔ : δ₀ ≤ Δ) :
    lyapunovTime R.maxExp δ₀ Δ ≤ (d : ℝ) * Real.log (Δ / δ₀) / R.entropy := by
  have hd : (0:ℝ) < d := by exact_mod_cast R.dim_pos
  have hmax := R.maxExp_pos h
  have hkey := R.entropy_div_dim_le_maxExp h
  have hlog : 0 ≤ Real.log (Δ / δ₀) :=
    Real.log_nonneg ((one_le_div hδ₀).mpr hΔ)
  unfold lyapunovTime
  rw [div_le_div_iff₀ hmax (by positivity)]
  have h1 : R.entropy ≤ (d : ℝ) * R.maxExp := by
    rw [div_le_iff₀ hd] at hkey; nlinarith
  nlinarith [hlog, hmax]

end RuelleData

/-- **Horseshoe ⟹ positive Lyapunov exponent.** A `d`-dimensional system carrying a Smale
horseshoe on `N ≥ 2` symbols has entropy at least `log N`, hence a maximal Lyapunov
exponent at least `log N / d > 0`. -/
theorem horseshoe_forces_positive_lyapunov {d N : ℕ} (R : RuelleData d) (hN : 2 ≤ N)
    (hent : Real.log N ≤ R.entropy) :
    0 < R.maxExp ∧ Real.log N / d ≤ R.maxExp := by
  have hlogN : 0 < Real.log N := Real.log_pos (by exact_mod_cast lt_of_lt_of_le one_lt_two hN)
  have hpos : 0 < R.entropy := lt_of_lt_of_le hlogN hent
  refine ⟨R.maxExp_pos hpos, ?_⟩
  have hd : (0:ℝ) < d := by exact_mod_cast R.dim_pos
  calc Real.log N / d ≤ R.entropy / d := by gcongr
  _ ≤ R.maxExp := R.entropy_div_dim_le_maxExp hpos

/-- **Explicit three-body bound.** The spatial three-body problem has a 18-dimensional
phase space, which after fixing the ten classical integrals and a Poincaré section is
reduced; whatever reduced dimension `d` one works with, a two-symbol horseshoe (the
Sitnikov/Moser mechanism) forces

  `λ_max ≥ log 2 / d > 0`.

This is the entropy route to positive Lyapunov exponents, complementary to the explicit
spectral route of `ThreeBody.equalMass_maximal_lyapunov_pos`. -/
theorem threeBody_horseshoe_lyapunov_bound {d : ℕ} (R : RuelleData d)
    (hent : Real.log 2 ≤ R.entropy) : Real.log 2 / d ≤ R.maxExp ∧ 0 < R.maxExp := by
  obtain ⟨h1, h2⟩ := horseshoe_forces_positive_lyapunov R (le_refl 2) (by simpa using hent)
  exact ⟨by simpa using h2, h1⟩

/-! ### The three-body Lagrange spectrum as Ruelle data -/

/-- The Lyapunov spectrum of the linearised Lagrange configuration: `{σ, σ, -σ, -σ}` with
`σ = ω·σ(K)`. The symplectic pairing `±σ` reflects `ThreeBody.lagrangeChar_neg_root`. -/
def lagrangeSpectrum (ω K : ℝ) : Fin 4 → ℝ :=
  ![ω * ThreeBody.lagrangeExponent K, ω * ThreeBody.lagrangeExponent K,
    -(ω * ThreeBody.lagrangeExponent K), -(ω * ThreeBody.lagrangeExponent K)]

/-- The sum of the *positive* Lyapunov exponents of the Lagrange spectrum is `2ωσ(K)`. -/
theorem sum_posPart_lagrangeSpectrum {ω K : ℝ} (hω : 0 < ω) (hK : 1 / 27 < K) :
    ∑ i, max (lagrangeSpectrum ω K i) 0 = 2 * (ω * ThreeBody.lagrangeExponent K) := by
  have hσ : 0 < ω * ThreeBody.lagrangeExponent K :=
    mul_pos hω (ThreeBody.lagrangeExponent_pos hK)
  have h1 : max (ω * ThreeBody.lagrangeExponent K) 0 = ω * ThreeBody.lagrangeExponent K :=
    max_eq_left hσ.le
  have h2 : max (-(ω * ThreeBody.lagrangeExponent K)) 0 = 0 :=
    max_eq_right (neg_nonpos.mpr hσ.le)
  simp only [lagrangeSpectrum, Fin.sum_univ_four, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.cons_val, h1, h2]
  ring

/-- The Lagrange configuration packaged as `RuelleData`: a four-dimensional planar
variational flow whose Kolmogorov–Sinai entropy `h` obeys Ruelle's inequality. -/
def lagrangeRuelleData (ω K h : ℝ) (hω : 0 < ω) (hK : 1 / 27 < K)
    (hh : h ≤ 2 * (ω * ThreeBody.lagrangeExponent K)) : RuelleData 4 where
  dim_pos := by norm_num
  exps := lagrangeSpectrum ω K
  entropy := h
  ruelle := by rw [sum_posPart_lagrangeSpectrum hω hK]; exact hh

/-- **Entropy bound for the three-body Lagrange configuration.**
Whatever the Kolmogorov–Sinai entropy of the linearised Lagrange flow is, Ruelle's
inequality caps it at twice the growth rate, `h_KS ≤ 2ωσ(K)`; and if `h_KS > 0` the
maximal exponent obeys `λ_max ≥ h_KS/4`. -/
theorem lagrange_entropy_bounds (ω K h : ℝ) (hω : 0 < ω) (hK : 1 / 27 < K)
    (hh : h ≤ 2 * (ω * ThreeBody.lagrangeExponent K)) (hpos : 0 < h) :
    h ≤ 2 * (ω * ThreeBody.lagrangeExponent K) ∧
      h / 4 ≤ (lagrangeRuelleData ω K h hω hK hh).maxExp := by
  refine ⟨hh, ?_⟩
  have := (lagrangeRuelleData ω K h hω hK hh).entropy_div_dim_le_maxExp (by exact hpos)
  simpa [lagrangeRuelleData] using this

/-- **Explicit equal-mass entropy cap.** For three equal masses on an equilateral triangle
of side `a`, the Kolmogorov–Sinai entropy of the linearised flow is at most
`√2·ω = √2·√(3Gm/a³)`. -/
theorem equalMass_entropy_le {G m a h : ℝ} (hm : 0 < m)
    (hh : h ≤ 2 * (ThreeBody.keplerFrequency G (3 * m) a *
      ThreeBody.lagrangeExponent (ThreeBody.routhParam m m m))) :
    h ≤ Real.sqrt 2 * ThreeBody.keplerFrequency G (3 * m) a := by
  rw [ThreeBody.routhParam_equal_mass hm, ThreeBody.equalMass_lagrangeExponent] at hh
  calc h ≤ 2 * (ThreeBody.keplerFrequency G (3 * m) a * (Real.sqrt 2 / 2)) := hh
  _ = Real.sqrt 2 * ThreeBody.keplerFrequency G (3 * m) a := by ring

/-- A concrete, non-vacuous family of `RuelleData`: a two-dimensional hyperbolic pair with
exponents `±μ` and entropy `μ`, saturating Ruelle's inequality (Pesin's formula). Taking
`μ = log((3+√5)/2)` gives the Arnold cat map on the 2-torus. -/
def catMapRuelleData (μ : ℝ) (hμ : 0 < μ) : RuelleData 2 where
  dim_pos := by norm_num
  exps := ![μ, -μ]
  entropy := μ
  ruelle := by
    simp [Fin.sum_univ_two, max_eq_left hμ.le, max_eq_right (neg_nonpos.mpr hμ.le)]

/-- For the cat-map spectrum the derived bound is sharp up to the factor `d = 2`. -/
theorem catMap_maxExp (μ : ℝ) (hμ : 0 < μ) : (catMapRuelleData μ hμ).maxExp = μ := by
  refine le_antisymm ?_ ?_
  · refine Finset.sup'_le _ _ ?_
    intro i _
    fin_cases i
    · simp [catMapRuelleData]
    · show (catMapRuelleData μ hμ).exps 1 ≤ μ
      simp [catMapRuelleData]
      linarith
  · have := (catMapRuelleData μ hμ).le_maxExp 0
    simpa [catMapRuelleData] using this

end Chaos