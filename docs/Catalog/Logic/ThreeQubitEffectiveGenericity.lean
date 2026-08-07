import Mathlib
import Logic.ThreeQubitOrbitTopology

/-!
# Effective genericity of the GHZ SLOCC class

This file continues the three-qubit programme of
`Catalog/Combinatorics/ThreeQubitHyperdeterminant.lean`,
`Catalog/Logic/ThreeQubitGHZNormalForm.lean`,
`Catalog/Logic/ThreeQubitOrbitTopology.lean` and
`Catalog/Logic/ThreeQubitWOrbitClosure.lean`.

The previous cycle proved that the GHZ class `{ψ | hyperdet ψ ≠ 0}` is open and **dense**:
every amplitude tensor has arbitrarily close GHZ-class neighbours
(`ThreeQubitOrbit.exists_slocc_ghz_close`).  That argument was purely qualitative — it used
that a monic quartic has finitely many roots — and the resulting perturbation carried no
lower bound at all on `|hyperdet|`.  Conjecture C5 of the previous cycle asked for the
*quantitative* form.  It is proved here, with explicit constants and with a matching upper
bound showing that the exponent is optimal.

## The argument

Along the GHZ direction the hyperdeterminant of `pert a t = a + t·(|000⟩ + |111⟩)` is a monic
quartic in `t` (`ThreeQubitOrbit.hyperdet_pert`).  The fourth finite difference of a monic
quartic on any five equally spaced nodes equals `4! h⁴`, independently of the tensor `a`:

`hyperdet(pert a (-ε)) - 4 hyperdet(pert a (-ε/2)) + 6 hyperdet a
    - 4 hyperdet(pert a (ε/2)) + hyperdet(pert a ε) = (3/2) ε⁴`
(`hyperdet_pert_fourth_difference`).

The coefficients `1, 4, 6, 4, 1` sum to `16`, so one of the five values has modulus at least
`(3/2)ε⁴/16 = (3/32)ε⁴`.  All five nodes lie in the closed `ε`-ball around `a`, so:

**every tensor has a GHZ-class neighbour at distance `≤ ε` whose hyperdeterminant has modulus
at least `(3/32)ε⁴`** (`exists_slocc_ghz_effective`).

The exponent `4` cannot be improved: the hyperdeterminant is a quartic form, so on the
`ε`-ball around the zero tensor `|hyperdet| ≤ 32 ε⁴` (`hyperdet_norm_le_of_entries`, proved
through the pencil form `hyperdet = pencilB² − 4 d₀ d₁`).  Hence at the zero tensor the best
achievable modulus is squeezed between `(3/32)ε⁴` and `32 ε⁴` (`genericity_rate_sharp`), and
along the GHZ direction it is exactly `ε⁴` (`hyperdet_pert_zeroAmp`).

Finally the same monic quartic gives an *exceptional set* bound: at most four parameters `t`
fail (`exists_exceptional_finset`), so any five distinct parameters contain a good one
(`exists_good_param_of_five`).

## Main results

* `hyperdet_pert_fourth_difference` — the universal fourth-difference identity.
* `exists_hyperdet_norm_ge` — a real parameter `|x| ≤ ε` with `‖hyperdet (pert a x)‖ ≥ 3ε⁴/32`.
* `exists_slocc_ghz_effective` — effective density of the GHZ class, with the `ε⁴` rate.
* `hyperdet_norm_le_of_entries` — the matching quartic upper bound `32 M⁴`.
* `genericity_rate_sharp` — the exponent `4` is optimal.
* `hyperdet_lipschitz`, `slocc_ghz_of_close` — effective openness: on tensors with entries of
  modulus `≤ M` the hyperdeterminant is `128 M³`-Lipschitz, so a GHZ-class tensor keeps a
  stability ball of radius `‖hyperdet‖ / (128 M³)`.
* `exists_ghz_ball` — effective stratification: density and openness with explicit constants
  at the same time.
* `exists_exceptional_finset`, `exists_good_param_of_five` — at most four bad parameters.
-/

open Matrix

noncomputable section

namespace ThreeQubitEffective

open ThreeQubitGHZ ThreeQubitOrbit

/-! ## Elementary triangle-inequality helpers -/

/-- Triangle inequality for the alternating five-term combination with binomial
coefficients `1, 4, 6, 4, 1`, in strict form. -/
private theorem norm_five_lt {x₀ x₁ x₂ x₃ x₄ : ℂ} {c : ℝ}
    (h₀ : ‖x₀‖ < c) (h₁ : ‖x₁‖ < c) (h₂ : ‖x₂‖ < c) (h₃ : ‖x₃‖ < c) (h₄ : ‖x₄‖ < c) :
    ‖x₀ - 4 * x₁ + 6 * x₂ - 4 * x₃ + x₄‖ < 16 * c := by
  have e₁ : ‖(4 : ℂ) * x₁‖ = 4 * ‖x₁‖ := by simp
  have e₂ : ‖(6 : ℂ) * x₂‖ = 6 * ‖x₂‖ := by simp
  have e₃ : ‖(4 : ℂ) * x₃‖ = 4 * ‖x₃‖ := by simp
  have t₁ := norm_sub_le x₀ (4 * x₁)
  have t₂ := norm_add_le (x₀ - 4 * x₁) (6 * x₂)
  have t₃ := norm_sub_le (x₀ - 4 * x₁ + 6 * x₂) (4 * x₃)
  have t₄ := norm_add_le (x₀ - 4 * x₁ + 6 * x₂ - 4 * x₃) x₄
  rw [e₁] at t₁
  rw [e₂] at t₂
  rw [e₃] at t₃
  linarith

/-- Triangle inequality for a four-term alternating sum. -/
private theorem norm_four_le {w x y z : ℂ} {M : ℝ}
    (hw : ‖w‖ ≤ M) (hx : ‖x‖ ≤ M) (hy : ‖y‖ ≤ M) (hz : ‖z‖ ≤ M) :
    ‖w - x - y + z‖ ≤ 4 * M := by
  have t₁ := norm_sub_le w x
  have t₂ := norm_sub_le (w - x) y
  have t₃ := norm_add_le (w - x - y) z
  linarith

/-- Triangle inequality for a two-term difference. -/
private theorem norm_two_le {w x : ℂ} {M : ℝ} (hw : ‖w‖ ≤ M) (hx : ‖x‖ ≤ M) :
    ‖w - x‖ ≤ 2 * M := by
  have := norm_sub_le w x
  linarith

/-! ## The universal fourth-difference identity -/

/-- **The fourth finite difference of the hyperdeterminant along the GHZ direction is
universal.**  For every amplitude tensor `a` and every real step `ε`, the alternating
combination of the five equally spaced values equals `(3/2)ε⁴`, with no dependence on `a`
whatsoever.  This is the quantitative form of `ThreeQubitOrbit.pertPoly_monic`: the fourth
difference of a monic quartic on nodes of spacing `h = ε/2` is `4! h⁴ = (3/2)ε⁴`. -/
theorem hyperdet_pert_fourth_difference (a : Amp) (ε : ℝ) :
    hyperdet (pert a ((-ε : ℝ) : ℂ)) - 4 * hyperdet (pert a ((-(ε / 2) : ℝ) : ℂ))
        + 6 * hyperdet a - 4 * hyperdet (pert a ((ε / 2 : ℝ) : ℂ))
        + hyperdet (pert a ((ε : ℝ) : ℂ))
      = ((3 / 2 * ε ^ 4 : ℝ) : ℂ) := by
  rw [hyperdet_pert, hyperdet_pert, hyperdet_pert, hyperdet_pert, hyperdet_eq_discriminant]
  push_cast
  ring

/-- **Effective genericity along the GHZ line.**  For every tensor `a` and every `ε > 0`
there is a *real* parameter `x` with `|x| ≤ ε` such that the perturbed tensor has
`‖hyperdet‖ ≥ (3/32)ε⁴`.  The constant is uniform in `a`. -/
theorem exists_hyperdet_norm_ge (a : Amp) {ε : ℝ} (hε : 0 < ε) :
    ∃ x : ℝ, |x| ≤ ε ∧ 3 / 32 * ε ^ 4 ≤ ‖hyperdet (pert a ((x : ℝ) : ℂ))‖ := by
  by_contra hcon
  push_neg at hcon
  have hhalf : |(-(ε / 2) : ℝ)| ≤ ε := by rw [abs_neg, abs_of_pos (by linarith)]; linarith
  have hhalf' : |(ε / 2 : ℝ)| ≤ ε := by rw [abs_of_pos (by linarith)]; linarith
  have h₀ := hcon (-ε) (by rw [abs_neg, abs_of_pos hε])
  have h₁ := hcon (-(ε / 2)) hhalf
  have h₂ := hcon 0 (by rw [abs_zero]; linarith)
  have h₃ := hcon (ε / 2) hhalf'
  have h₄ := hcon ε (by rw [abs_of_pos hε])
  rw [show (((0 : ℝ) : ℂ)) = 0 by norm_num, pert_zero] at h₂
  have hd := hyperdet_pert_fourth_difference a ε
  have hnorm : ‖((3 / 2 * ε ^ 4 : ℝ) : ℂ)‖ = 3 / 2 * ε ^ 4 := by
    rw [Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg (by positivity)]
  have hlt := norm_five_lt h₀ h₁ h₂ h₃ h₄
  rw [hd, hnorm] at hlt
  linarith

/-- Entrywise smallness gives smallness in the sup metric (non-strict version of
`ThreeQubitOrbit.dist_amp_lt`). -/
theorem dist_amp_le {a b : Amp} {ε : ℝ} (hε : 0 ≤ ε) (h : ∀ i j k, ‖a i j k - b i j k‖ ≤ ε) :
    dist a b ≤ ε := by
  rw [dist_pi_le_iff hε]
  intro i
  rw [dist_pi_le_iff hε]
  intro j
  rw [dist_pi_le_iff hε]
  intro k
  rw [dist_eq_norm]
  exact h i j k

/-- **Effective density of the GHZ class.**  Every three-qubit amplitude tensor has, within
distance `ε`, a tensor that is SLOCC equivalent to GHZ *and* whose hyperdeterminant has
modulus at least `(3/32)ε⁴`.  This upgrades `ThreeQubitOrbit.exists_slocc_ghz_close`, which
produced a GHZ-class neighbour with no control on the invariant, to a statement with an
explicit rate. -/
theorem exists_slocc_ghz_effective (a : Amp) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ ≤ ε) ∧ dist b a ≤ ε ∧ SLOCC b ghz ∧
      3 / 32 * ε ^ 4 ≤ ‖hyperdet b‖ := by
  obtain ⟨x, hx, hge⟩ := exists_hyperdet_norm_ge a hε
  refine ⟨pert a ((x : ℝ) : ℂ), ?_, ?_, ?_, hge⟩
  · intro i j k
    rw [pert_sub]
    have hg : ghzBare i j k = 0 ∨ ghzBare i j k = 1 := by
      fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [ghzBare]
    rcases hg with h | h
    · rw [h]; simpa using hε.le
    · rw [h]; simpa [Complex.norm_real, Real.norm_eq_abs] using hx
  · refine dist_amp_le hε.le ?_
    intro i j k
    rw [pert_sub]
    have hg : ghzBare i j k = 0 ∨ ghzBare i j k = 1 := by
      fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [ghzBare]
    rcases hg with h | h
    · rw [h]; simpa using hε.le
    · rw [h]; simpa [Complex.norm_real, Real.norm_eq_abs] using hx
  · refine (slocc_ghz_iff_hyperdet_ne_zero _).2 ?_
    intro h0
    rw [h0] at hge
    simp only [norm_zero] at hge
    nlinarith [pow_pos hε 4]

/-! ## The matching upper bound: the exponent `4` is optimal -/

/-- Modulus bound for the determinant of an Alice slice. -/
theorem norm_d0_le {b : Amp} {M : ℝ} (h : ∀ i j k, ‖b i j k‖ ≤ M) : ‖d0 b‖ ≤ 2 * M ^ 2 := by
  have hM : 0 ≤ M := (norm_nonneg _).trans (h 0 0 0)
  have p₁ : ‖b 0 0 0 * b 0 1 1‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]
    exact mul_le_mul (h 0 0 0) (h 0 1 1) (norm_nonneg _) hM
  have p₂ : ‖b 0 0 1 * b 0 1 0‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]
    exact mul_le_mul (h 0 0 1) (h 0 1 0) (norm_nonneg _) hM
  simpa [d0] using norm_two_le p₁ p₂

theorem norm_d1_le {b : Amp} {M : ℝ} (h : ∀ i j k, ‖b i j k‖ ≤ M) : ‖d1 b‖ ≤ 2 * M ^ 2 := by
  have hM : 0 ≤ M := (norm_nonneg _).trans (h 0 0 0)
  have p₁ : ‖b 1 0 0 * b 1 1 1‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]
    exact mul_le_mul (h 1 0 0) (h 1 1 1) (norm_nonneg _) hM
  have p₂ : ‖b 1 0 1 * b 1 1 0‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]
    exact mul_le_mul (h 1 0 1) (h 1 1 0) (norm_nonneg _) hM
  simpa [d1] using norm_two_le p₁ p₂

theorem norm_pencilB_le {b : Amp} {M : ℝ} (h : ∀ i j k, ‖b i j k‖ ≤ M) :
    ‖pencilB b‖ ≤ 4 * M ^ 2 := by
  have hM : 0 ≤ M := (norm_nonneg _).trans (h 0 0 0)
  have p₁ : ‖b 0 0 0 * b 1 1 1‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]; exact mul_le_mul (h 0 0 0) (h 1 1 1) (norm_nonneg _) hM
  have p₂ : ‖b 0 0 1 * b 1 1 0‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]; exact mul_le_mul (h 0 0 1) (h 1 1 0) (norm_nonneg _) hM
  have p₃ : ‖b 0 1 0 * b 1 0 1‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]; exact mul_le_mul (h 0 1 0) (h 1 0 1) (norm_nonneg _) hM
  have p₄ : ‖b 0 1 1 * b 1 0 0‖ ≤ M ^ 2 := by
    rw [norm_mul, sq]; exact mul_le_mul (h 0 1 1) (h 1 0 0) (norm_nonneg _) hM
  simpa [pencilB] using norm_four_le p₁ p₂ p₃ p₄

/-- **The hyperdeterminant is a quartic form: an entrywise bound `M` forces
`‖hyperdet‖ ≤ 32 M⁴`.**  Proved through the pencil form `hyperdet = pencilB² − 4 d₀ d₁`. -/
theorem hyperdet_norm_le_of_entries {b : Amp} {M : ℝ} (h : ∀ i j k, ‖b i j k‖ ≤ M) :
    ‖hyperdet b‖ ≤ 32 * M ^ 4 := by
  have hM : 0 ≤ M := (norm_nonneg _).trans (h 0 0 0)
  have hB := norm_pencilB_le h
  have h0 := norm_d0_le h
  have h1 := norm_d1_le h
  have hsq : ‖pencilB b ^ 2‖ ≤ 16 * M ^ 4 := by
    rw [norm_pow]
    nlinarith [norm_nonneg (pencilB b), sq_nonneg M]
  have hprod : ‖4 * d0 b * d1 b‖ ≤ 16 * M ^ 4 := by
    rw [norm_mul, norm_mul]
    have : ‖(4 : ℂ)‖ = 4 := by norm_num
    rw [this]
    nlinarith [norm_nonneg (d0 b), norm_nonneg (d1 b), sq_nonneg M]
  have := norm_sub_le (pencilB b ^ 2) (4 * d0 b * d1 b)
  rw [hyperdet_eq_discriminant]
  linarith

/-- The zero amplitude tensor. -/
def zeroAmp : Amp := fun _ _ _ => 0

/-- Along the GHZ direction through the origin the hyperdeterminant is exactly `t⁴`: the
perturbation of the previous cycle really does realize the quartic rate. -/
theorem hyperdet_pert_zeroAmp (t : ℂ) : hyperdet (pert zeroAmp t) = t ^ 4 := by
  simp only [hyperdet, pert, zeroAmp, ghzBare, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- **The `ε⁴` rate is optimal.**  Near the zero tensor the best hyperdeterminant modulus
obtainable inside the closed `ε`-ball is at least `(3/32)ε⁴` and at most `32 ε⁴`; in
particular no rate `ε^p` with `p < 4` can hold and no rate `ε^p` with `p > 4` can fail for
trivial reasons — the exponent is exactly the degree of the invariant. -/
theorem genericity_rate_sharp {ε : ℝ} (hε : 0 < ε) :
    (∃ b : Amp, (∀ i j k, ‖b i j k - zeroAmp i j k‖ ≤ ε) ∧ 3 / 32 * ε ^ 4 ≤ ‖hyperdet b‖) ∧
      (∀ b : Amp, (∀ i j k, ‖b i j k - zeroAmp i j k‖ ≤ ε) → ‖hyperdet b‖ ≤ 32 * ε ^ 4) := by
  constructor
  · obtain ⟨b, hb, -, -, hge⟩ := exists_slocc_ghz_effective zeroAmp hε
    exact ⟨b, hb, hge⟩
  · intro b hb
    refine hyperdet_norm_le_of_entries ?_
    intro i j k
    simpa [zeroAmp] using hb i j k

/-- At the zero tensor the extremal modulus is realized exactly: the perturbation with
`t = ε` sits on the boundary sphere and has hyperdeterminant of modulus `ε⁴`. -/
theorem hyperdet_norm_pert_zeroAmp {ε : ℝ} (hε : 0 ≤ ε) :
    ‖hyperdet (pert zeroAmp ((ε : ℝ) : ℂ))‖ = ε ^ 4 := by
  rw [hyperdet_pert_zeroAmp, norm_pow, Complex.norm_real, Real.norm_eq_abs,
    abs_of_nonneg hε]

/-! ## Effective openness: a quantitative stability radius -/

/-- Stability of a product under perturbation of both factors. -/
private theorem norm_mul_sub_mul {x y x' y' : ℂ} {P q : ℝ}
    (hx : ‖x‖ ≤ P) (hy' : ‖y'‖ ≤ P) (hxx : ‖x - x'‖ ≤ q) (hyy : ‖y - y'‖ ≤ q) :
    ‖x * y - x' * y'‖ ≤ 2 * P * q := by
  have e : x * y - x' * y' = x * (y - y') + (x - x') * y' := by ring
  rw [e]
  have t := norm_add_le (x * (y - y')) ((x - x') * y')
  rw [norm_mul, norm_mul] at t
  have h1 : ‖x‖ * ‖y - y'‖ ≤ P * q :=
    mul_le_mul hx hyy (norm_nonneg _) ((norm_nonneg x).trans hx)
  have h2 : ‖x - x'‖ * ‖y'‖ ≤ q * P :=
    mul_le_mul hxx hy' (norm_nonneg _) ((norm_nonneg _).trans hxx)
  linarith

theorem norm_pencilB_sub_le {a b : Amp} {M r : ℝ}
    (ha : ∀ i j k, ‖a i j k‖ ≤ M) (hb : ∀ i j k, ‖b i j k‖ ≤ M)
    (hab : ∀ i j k, ‖b i j k - a i j k‖ ≤ r) : ‖pencilB b - pencilB a‖ ≤ 8 * M * r := by
  have e : pencilB b - pencilB a =
      (b 0 0 0 * b 1 1 1 - a 0 0 0 * a 1 1 1) - (b 0 0 1 * b 1 1 0 - a 0 0 1 * a 1 1 0)
        - (b 0 1 0 * b 1 0 1 - a 0 1 0 * a 1 0 1) + (b 0 1 1 * b 1 0 0 - a 0 1 1 * a 1 0 0) := by
    simp only [pencilB]; ring
  rw [e]
  have t₁ := norm_mul_sub_mul (hb 0 0 0) (ha 1 1 1) (hab 0 0 0) (hab 1 1 1)
  have t₂ := norm_mul_sub_mul (hb 0 0 1) (ha 1 1 0) (hab 0 0 1) (hab 1 1 0)
  have t₃ := norm_mul_sub_mul (hb 0 1 0) (ha 1 0 1) (hab 0 1 0) (hab 1 0 1)
  have t₄ := norm_mul_sub_mul (hb 0 1 1) (ha 1 0 0) (hab 0 1 1) (hab 1 0 0)
  have := norm_four_le t₁ t₂ t₃ t₄
  linarith

theorem norm_d0_sub_le {a b : Amp} {M r : ℝ}
    (ha : ∀ i j k, ‖a i j k‖ ≤ M) (hb : ∀ i j k, ‖b i j k‖ ≤ M)
    (hab : ∀ i j k, ‖b i j k - a i j k‖ ≤ r) : ‖d0 b - d0 a‖ ≤ 4 * M * r := by
  have e : d0 b - d0 a =
      (b 0 0 0 * b 0 1 1 - a 0 0 0 * a 0 1 1) - (b 0 0 1 * b 0 1 0 - a 0 0 1 * a 0 1 0) := by
    simp only [d0]; ring
  rw [e]
  have t₁ := norm_mul_sub_mul (hb 0 0 0) (ha 0 1 1) (hab 0 0 0) (hab 0 1 1)
  have t₂ := norm_mul_sub_mul (hb 0 0 1) (ha 0 1 0) (hab 0 0 1) (hab 0 1 0)
  have := norm_two_le t₁ t₂
  linarith

theorem norm_d1_sub_le {a b : Amp} {M r : ℝ}
    (ha : ∀ i j k, ‖a i j k‖ ≤ M) (hb : ∀ i j k, ‖b i j k‖ ≤ M)
    (hab : ∀ i j k, ‖b i j k - a i j k‖ ≤ r) : ‖d1 b - d1 a‖ ≤ 4 * M * r := by
  have e : d1 b - d1 a =
      (b 1 0 0 * b 1 1 1 - a 1 0 0 * a 1 1 1) - (b 1 0 1 * b 1 1 0 - a 1 0 1 * a 1 1 0) := by
    simp only [d1]; ring
  rw [e]
  have t₁ := norm_mul_sub_mul (hb 1 0 0) (ha 1 1 1) (hab 1 0 0) (hab 1 1 1)
  have t₂ := norm_mul_sub_mul (hb 1 0 1) (ha 1 1 0) (hab 1 0 1) (hab 1 1 0)
  have := norm_two_le t₁ t₂
  linarith

/-- **An explicit Lipschitz estimate for the hyperdeterminant on a ball.**  On tensors with
entries of modulus at most `M`, the hyperdeterminant is `128 M³`-Lipschitz for the entrywise
sup distance.  Again the proof goes through the pencil form. -/
theorem hyperdet_lipschitz {a b : Amp} {M r : ℝ}
    (ha : ∀ i j k, ‖a i j k‖ ≤ M) (hb : ∀ i j k, ‖b i j k‖ ≤ M)
    (hab : ∀ i j k, ‖b i j k - a i j k‖ ≤ r) :
    ‖hyperdet b - hyperdet a‖ ≤ 128 * M ^ 3 * r := by
  have hM : 0 ≤ M := (norm_nonneg _).trans (ha 0 0 0)
  have hr : 0 ≤ r := (norm_nonneg _).trans (hab 0 0 0)
  have hpB := norm_pencilB_sub_le ha hb hab
  have hd0 := norm_d0_sub_le ha hb hab
  have hd1 := norm_d1_sub_le ha hb hab
  have hsum : ‖pencilB b + pencilB a‖ ≤ 8 * M ^ 2 := by
    have t := norm_add_le (pencilB b) (pencilB a)
    have h1 := norm_pencilB_le hb
    have h2 := norm_pencilB_le ha
    linarith
  have e : hyperdet b - hyperdet a =
      (pencilB b + pencilB a) * (pencilB b - pencilB a)
        - 4 * (d0 b * d1 b - d0 a * d1 a) := by
    rw [hyperdet_eq_discriminant, hyperdet_eq_discriminant]; ring
  rw [e]
  have t₁ : ‖(pencilB b + pencilB a) * (pencilB b - pencilB a)‖ ≤ 8 * M ^ 2 * (8 * M * r) := by
    rw [norm_mul]
    exact mul_le_mul hsum hpB (norm_nonneg _) (by positivity)
  have t₂ : ‖d0 b * d1 b - d0 a * d1 a‖ ≤ 2 * (2 * M ^ 2) * (4 * M * r) :=
    norm_mul_sub_mul (norm_d0_le hb) (norm_d1_le ha) hd0 hd1
  have t₃ : ‖(4 : ℂ) * (d0 b * d1 b - d0 a * d1 a)‖ ≤ 4 * (2 * (2 * M ^ 2) * (4 * M * r)) := by
    rw [norm_mul, show ‖(4 : ℂ)‖ = 4 by norm_num]
    linarith
  have t₄ := norm_sub_le ((pencilB b + pencilB a) * (pencilB b - pencilB a))
    ((4 : ℂ) * (d0 b * d1 b - d0 a * d1 a))
  have e₁ : 8 * M ^ 2 * (8 * M * r) = 64 * M ^ 3 * r := by ring
  have e₂ : 4 * (2 * (2 * M ^ 2) * (4 * M * r)) = 64 * M ^ 3 * r := by ring
  linarith

/-- **Effective openness of the GHZ class.**  If `a` has entries of modulus at most `M` and
`‖hyperdet a‖ > 128 M³ r`, then every tensor `b` with entries of modulus at most `M` and
entrywise within `r` of `a` is again SLOCC equivalent to GHZ. -/
theorem slocc_ghz_of_close {a b : Amp} {M r : ℝ}
    (ha : ∀ i j k, ‖a i j k‖ ≤ M) (hb : ∀ i j k, ‖b i j k‖ ≤ M)
    (hab : ∀ i j k, ‖b i j k - a i j k‖ ≤ r)
    (hlt : 128 * M ^ 3 * r < ‖hyperdet a‖) : SLOCC b ghz := by
  refine (slocc_ghz_iff_hyperdet_ne_zero _).2 ?_
  intro h0
  have h := hyperdet_lipschitz ha hb hab
  rw [h0, zero_sub, norm_neg] at h
  linarith

/-- **Effective stratification.**  Within distance `ε` of an arbitrary tensor `a` with entries
bounded by `M` there is a GHZ-class tensor `b` that carries an explicit stability radius: the
whole entrywise ball of radius `3ε⁴ / (4096 (M + ε)³)` around `b`, inside the ball of entry
bound `M + ε`, consists of GHZ-class tensors.  Density (rate `ε⁴`) and openness (radius
`∼ δ / M³`) are thus both effective. -/
theorem exists_ghz_ball (a : Amp) {ε M : ℝ} (hε : 0 < ε) (ha : ∀ i j k, ‖a i j k‖ ≤ M) :
    ∃ b : Amp, dist b a ≤ ε ∧ SLOCC b ghz ∧ (∀ i j k, ‖b i j k‖ ≤ M + ε) ∧
      ∀ (r : ℝ) (c : Amp), r < 3 * ε ^ 4 / (4096 * (M + ε) ^ 3) →
        (∀ i j k, ‖c i j k‖ ≤ M + ε) → (∀ i j k, ‖c i j k - b i j k‖ ≤ r) → SLOCC c ghz := by
  have hM : 0 ≤ M := (norm_nonneg _).trans (ha 0 0 0)
  have hMe : 0 < M + ε := by linarith
  obtain ⟨b, hbe, hdist, hslocc, hge⟩ := exists_slocc_ghz_effective a hε
  have hbnd : ∀ i j k, ‖b i j k‖ ≤ M + ε := by
    intro i j k
    have h1 : ‖b i j k‖ ≤ ‖b i j k - a i j k‖ + ‖a i j k‖ := by
      simpa using norm_add_le (b i j k - a i j k) (a i j k)
    have := hbe i j k
    have := ha i j k
    linarith
  refine ⟨b, hdist, hslocc, hbnd, ?_⟩
  intro r c hr hc hcb
  refine slocc_ghz_of_close hbnd hc hcb ?_
  have hcube : (0 : ℝ) < 4096 * (M + ε) ^ 3 := by positivity
  have key : 128 * (M + ε) ^ 3 * r < 3 / 32 * ε ^ 4 := by
    have h1 : r * (4096 * (M + ε) ^ 3) < 3 * ε ^ 4 := by
      rw [← lt_div_iff₀ hcube]
      exact hr
    nlinarith
  linarith

/-! ## The exceptional set has at most four points -/

theorem pertPoly_natDegree (a : Amp) : (pertPoly a).natDegree = 4 := by
  unfold pertPoly
  compute_degree!

/-- **At most four parameters are exceptional.**  For every tensor `a` there is a set `S` of
at most four complex numbers such that `pert a t` lies in the GHZ class for every `t ∉ S`.
This is the sharp counting form of the density statement: the exceptional set is the root set
of the monic quartic `pertPoly a`. -/
theorem exists_exceptional_finset (a : Amp) :
    ∃ S : Finset ℂ, S.card ≤ 4 ∧ ∀ t ∉ S, hyperdet (pert a t) ≠ 0 := by
  refine ⟨(pertPoly a).roots.toFinset, ?_, ?_⟩
  · calc (pertPoly a).roots.toFinset.card ≤ Multiset.card (pertPoly a).roots :=
        (pertPoly a).roots.toFinset_card_le
    _ ≤ (pertPoly a).natDegree := (pertPoly a).card_roots'
    _ = 4 := pertPoly_natDegree a
  · intro t ht h0
    apply ht
    rw [Multiset.mem_toFinset, Polynomial.mem_roots (pertPoly_ne_zero a)]
    rw [Polynomial.IsRoot, pertPoly_eval]
    exact h0

/-- Any five distinct parameters contain a good one. -/
theorem exists_good_param_of_five (a : Amp) {T : Finset ℂ} (hT : 5 ≤ T.card) :
    ∃ t ∈ T, hyperdet (pert a t) ≠ 0 := by
  obtain ⟨S, hS, hgood⟩ := exists_exceptional_finset a
  by_contra hcon
  push_neg at hcon
  have hsub : T ⊆ S := by
    intro t htT
    by_contra htS
    exact hgood t htS (hcon t htT)
  have := Finset.card_le_card hsub
  omega

/-- Combining with the classification: any five distinct parameters contain one whose
perturbation is SLOCC equivalent to GHZ. -/
theorem exists_slocc_ghz_param_of_five (a : Amp) {T : Finset ℂ} (hT : 5 ≤ T.card) :
    ∃ t ∈ T, SLOCC (pert a t) ghz := by
  obtain ⟨t, htT, ht⟩ := exists_good_param_of_five a hT
  exact ⟨t, htT, (slocc_ghz_iff_hyperdet_ne_zero _).2 ht⟩

end ThreeQubitEffective