import Algebra.SmoothWindows.Sidelobes
import Algebra.ReciprocalZeroHarmonics.WindowDichotomy

/-!
# Smooth windows IV: the Gaussian-windowed harmonic sum of a zero multiset

This file transplants the smooth-window machinery of the previous three files onto the actual
object of the Reciprocal-Zero Harmonics catalog: the multiplicity-sensitive harmonic sum
`H(Z) = Σ_{ρ ∈ Z} 1/ρ` of `Algebra.ReciprocalZeroHarmonics.Core`, whose finite-window version
`windowSum Z T = Σ_{|Im ρ| ≤ T} 1/ρ` uses a *rectangular* window in the ordinate variable.

## Main results

* `windowedSum` — the general **windowed harmonic sum** `Σ_{ρ ∈ Z} w(Im ρ)/ρ` for an arbitrary
  window `w : ℝ → ℂ`, linear in `w` and additive in `Z`.
* `windowedSum_rectWin` — the catalog's cutoff **is** the rectangular case:
  `windowedSum (1_{[-T,T]}) Z = windowSum Z T`.  Everything proved below is therefore a strict
  generalisation of the catalog.
* `gaussSum_pairedOrdinates` — the Gaussian window keeps the conjugate-pairing collapse:
  `Σ_ρ g_s(Im ρ)/ρ = Σ_t g_s(t)/(1/4 + t²)`, a *real* number (`gaussSum_real`).
* `gaussSum_pairedOrdinates_eq_zero_iff` — **no false nulls.**  Unlike the rectangular window,
  whose value vanishes identically below the first ordinate
  (`windowSum_pairedOrdinates_eq_zero_iff`), the Gaussian-windowed sum vanishes *only* for an
  empty zero family, for every width `s ≠ 0`.
* `gauss_detects_zero_missed_by_rect` — the sharp contrast, in one statement: a zero at ordinate
  `t` outside the rectangular window is invisible to the cutoff (`windowSum = 0`) but is detected
  by the Gaussian window (`gaussSum ≠ 0`).
* `gaborTransform`, `gaborTransform_translate`, `gaborTransform_modulate`,
  `gaborTransform_weyl` — the **modulation/translation identity for spectral data**: translating
  the ordinates by `c` translates the analysis point and multiplies by the phase `χ(-bc)`;
  modulating the amplitudes by `χ(η·)` shifts the analysis frequency; performing both in the two
  possible orders differs by exactly the Weyl phase `χ(-ηc)` of
  `Algebra.SmoothWindows.GaborOperators`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The rectangular window is not merely inconvenient, it is
  *logically weaker*: there are zero configurations it cannot see at all, while a Gaussian window
  sees every configuration, at every width.
* **Experiment (Experimenter).** Confirmed. `windowSum_pairedOrdinates_eq_zero_iff` (catalog)
  gives an exact vanishing criterion; `gaussSum_pairedOrdinates_eq_zero_iff` shows the Gaussian
  analogue is `S = 0`, independent of `s`.  Both proofs run through the same positivity mechanism
  `1/(1/4+t²) > 0`, the smooth window contributing the strictly positive factor `g_s(t)`.
* **Analysis (Analyst).** The structural reason is that the rectangular window has *zeros* (it is
  supported in a compact set) while the Gaussian window is nowhere vanishing.  Positivity of the
  window on the whole line, not smoothness, is what removes false nulls; smoothness is what
  removes sidelobes (previous file).  The two defects of the sharp cutoff are therefore
  independent, and the Gaussian repairs both.
* **Critique (Critic).** `gaussSum_pairedOrdinates_eq_zero_iff` needs `s ≠ 0` — at `s = 0` the
  Lean definition degenerates to the constant window `1` and the statement remains true but for a
  different reason.  The translation identity is stated for the *data*, not for the zeros
  themselves, since translating a zero changes `1/ρ` as well as its ordinate.
-/

namespace SmoothWindows

open Complex Real FourierTransform ReciprocalZeroHarmonics

open scoped Classical in
/-- The **windowed harmonic sum** `Σ_{ρ ∈ Z} w(Im ρ)/ρ` of a multiset of zeros, computed with
multiplicities. -/
noncomputable def windowedSum (w : ℝ → ℂ) (Z : Multiset ℂ) : ℂ :=
  (Z.map fun r => w r.im * r⁻¹).sum

@[simp] theorem windowedSum_zero (w : ℝ → ℂ) : windowedSum w 0 = 0 := by simp [windowedSum]

@[simp] theorem windowedSum_cons (w : ℝ → ℂ) (r : ℂ) (Z : Multiset ℂ) :
    windowedSum w (r ::ₘ Z) = w r.im * r⁻¹ + windowedSum w Z := by
  simp [windowedSum]

theorem windowedSum_add (w : ℝ → ℂ) (Y Z : Multiset ℂ) :
    windowedSum w (Y + Z) = windowedSum w Y + windowedSum w Z := by
  simp [windowedSum]

/-- The windowed sum is linear in the window. -/
theorem windowedSum_window_add (w v : ℝ → ℂ) (Z : Multiset ℂ) :
    windowedSum (w + v) Z = windowedSum w Z + windowedSum v Z := by
  unfold windowedSum
  rw [← Multiset.sum_map_add]
  exact congrArg Multiset.sum (Multiset.map_congr rfl fun r _ => by simp [add_mul])

/-- **The catalog's cutoff is the rectangular window.**  The finite-window harmonic sum of
`Algebra.ReciprocalZeroHarmonics.Core` is the windowed sum for `w = 1_{[-T,T]}`. -/
theorem windowedSum_rectWin (T : ℝ) (Z : Multiset ℂ) :
    windowedSum (rectWin T) Z = windowSum Z T := by
  classical
  induction Z using Multiset.induction_on with
  | empty => simp [windowSum, harmonicSum]
  | cons r Z ih =>
    have hval : rectWin T r.im = if |r.im| ≤ T then 1 else 0 := by
      by_cases h : |r.im| ≤ T
      · have hmem : r.im ∈ Set.Icc (-T) T := abs_le.mp h
        rw [rectWin, Set.indicator_of_mem hmem, if_pos h]
        rfl
      · have hmem : r.im ∉ Set.Icc (-T) T := fun hc => h (abs_le.mpr hc)
        rw [rectWin, Set.indicator_of_notMem hmem, if_neg h]
    by_cases h : |r.im| ≤ T
    · rw [windowedSum_cons, hval, if_pos h, ih, windowSum, windowSum,
        Multiset.filter_cons_of_pos (p := fun r : ℂ => |r.im| ≤ T) Z h, harmonicSum_cons, one_mul]
    · rw [windowedSum_cons, hval, if_neg h, ih, windowSum, windowSum,
        Multiset.filter_cons_of_neg (p := fun r : ℂ => |r.im| ≤ T) Z h, zero_mul, zero_add]

/-! ## The Gaussian-windowed harmonic sum -/

/-- The **Gaussian-windowed harmonic sum** `Σ_{ρ ∈ Z} g_s(Im ρ)/ρ`. -/
noncomputable def gaussSum (Z : Multiset ℂ) (s : ℝ) : ℂ := windowedSum (gaussC s) Z

theorem conj_gaussSum (Z : Multiset ℂ) (s : ℝ) :
    (starRingEnd ℂ) (gaussSum Z s) = gaussSum (Z.map (starRingEnd ℂ)) s := by
  unfold gaussSum windowedSum
  rw [map_multiset_sum, Multiset.map_map, Multiset.map_map]
  refine congrArg Multiset.sum (Multiset.map_congr rfl fun r _ => ?_)
  simp only [Function.comp_apply, map_mul, Complex.conj_im, gaussC, Complex.conj_ofReal,
    gaussWin_even]
  rw [map_inv₀]

/-- **The Gaussian-windowed sum of a conjugation-symmetric zero multiset is real.** -/
theorem gaussSum_real (Z : Multiset ℂ) (hZ : ConjSymm Z) (s : ℝ) : (gaussSum Z s).im = 0 := by
  have h := conj_gaussSum Z s
  rw [hZ] at h
  have h2 := congrArg Complex.im h
  rw [Complex.conj_im] at h2
  linarith

/-- **The paired-ordinate collapse survives the smooth window.**  On a conjugate-paired family of
critical-line zeros the Gaussian-windowed sum equals `Σ_t g_s(t)/(1/4 + t²)`. -/
theorem gaussSum_pairedOrdinates (S : Multiset ℝ) (s : ℝ) :
    gaussSum (pairedOrdinates S) s
      = (((S.map fun t => gaussWin s t / (1 / 4 + t ^ 2)).sum : ℝ) : ℂ) := by
  unfold gaussSum pairedOrdinates
  rw [windowedSum_add]
  unfold windowedSum
  rw [Multiset.map_map, Multiset.map_map, ← Multiset.sum_map_add]
  have hmap : (S.map fun t =>
        (gaussC s (criticalZero t).im * (criticalZero t)⁻¹
          + gaussC s (criticalZero (-t)).im * (criticalZero (-t))⁻¹))
      = S.map fun t => ((gaussWin s t / (1 / 4 + t ^ 2) : ℝ) : ℂ) := by
    refine Multiset.map_congr rfl fun t _ => ?_
    have hpair := criticalZero_pair_inv t
    simp only [criticalZero_im, gaussC, gaussWin_even]
    rw [← mul_add, hpair]
    push_cast
    ring
  simp only [Function.comp_apply]
  rw [hmap, show (S.map fun t => ((gaussWin s t / (1 / 4 + t ^ 2) : ℝ) : ℂ))
      = (S.map fun t => (gaussWin s t / (1 / 4 + t ^ 2) : ℝ)).map (fun x : ℝ => (x : ℂ)) by
    rw [Multiset.map_map]; rfl]
  exact (map_multiset_sum Complex.ofRealHom _).symm

/-- **Strict positivity: the smooth window never cancels.**  Any nonempty conjugate-paired family
of critical-line zeros has strictly positive Gaussian-windowed sum, *for every width*. -/
theorem gaussSum_pairedOrdinates_pos (S : Multiset ℝ) (hS : S ≠ 0) (s : ℝ) :
    0 < (gaussSum (pairedOrdinates S) s).re := by
  rw [gaussSum_pairedOrdinates, Complex.ofReal_re]
  obtain ⟨t, ht⟩ := Multiset.exists_mem_of_ne_zero hS
  have hpos : ∀ x ∈ S.map fun t => gaussWin s t / (1 / 4 + t ^ 2), 0 < x := by
    intro x hx
    obtain ⟨u, _, rfl⟩ := Multiset.mem_map.mp hx
    have := gaussWin_pos s u
    positivity
  have hmem : gaussWin s t / (1 / 4 + t ^ 2) ∈ S.map fun t => gaussWin s t / (1 / 4 + t ^ 2) :=
    Multiset.mem_map_of_mem _ ht
  exact lt_of_lt_of_le (hpos _ hmem)
    (Multiset.single_le_sum (fun x hx => (hpos x hx).le) _ hmem)

/-- **No false nulls.**  The Gaussian-windowed sum of a conjugate-paired critical-line family
vanishes exactly when the family is empty — in contrast with the rectangular window, which
vanishes for every cutoff below the first ordinate. -/
theorem gaussSum_pairedOrdinates_eq_zero_iff (S : Multiset ℝ) (s : ℝ) :
    gaussSum (pairedOrdinates S) s = 0 ↔ S = 0 := by
  constructor
  · intro h
    by_contra hS
    have hpos := gaussSum_pairedOrdinates_pos S hS s
    rw [h] at hpos
    simp at hpos
  · rintro rfl
    simp [gaussSum, pairedOrdinates]

/-- **The sharp contrast.**  A conjugate pair of critical-line zeros with ordinate `t` lying
outside the rectangular window `|Im ρ| ≤ T` is completely invisible to the sharp cutoff, while
the Gaussian window of *any* width detects it. -/
theorem gauss_detects_zero_missed_by_rect {t T : ℝ} (ht : T < |t|) (s : ℝ) :
    windowSum (pairedOrdinates {t}) T = 0 ∧ gaussSum (pairedOrdinates {t}) s ≠ 0 := by
  constructor
  · rw [windowSum_pairedOrdinates_eq_zero_iff]
    intro u hu
    rw [Multiset.mem_singleton.mp hu]
    exact ht
  · rw [Ne, gaussSum_pairedOrdinates_eq_zero_iff]
    simp

/-! ## The modulation/translation identity for spectral data -/

/-- **Spectral data**: a multiset of pairs (ordinate, amplitude).  The zero multiset `Z` gives the
data `(Im ρ, 1/ρ)`. -/
noncomputable def zeroData (Z : Multiset ℂ) : Multiset (ℝ × ℂ) := Z.map fun r => (r.im, r⁻¹)

/-- The **discrete Gabor transform** of spectral data with window `w`, analysing the phase-space
point `(a, b)`: `Σ_j χ(-b t_j) w(t_j - a) c_j`. -/
noncomputable def gaborTransform (D : Multiset (ℝ × ℂ)) (w : ℝ → ℂ) (a b : ℝ) : ℂ :=
  (D.map fun p => chi (-(b * p.1)) * w (p.1 - a) * p.2).sum

/-- At the origin of phase space the Gabor transform of the zero data is the windowed harmonic
sum: the new object extends the catalog's one. -/
theorem gaborTransform_zeroData_zero (Z : Multiset ℂ) (w : ℝ → ℂ) :
    gaborTransform (zeroData Z) w 0 0 = windowedSum w Z := by
  unfold gaborTransform zeroData windowedSum
  rw [Multiset.map_map]
  refine congrArg Multiset.sum (Multiset.map_congr rfl fun r _ => ?_)
  simp

/-- Translating all ordinates by `c` translates the analysis position by `c` and multiplies by the
phase `χ(-bc)`. -/
theorem gaborTransform_translate (D : Multiset (ℝ × ℂ)) (w : ℝ → ℂ) (a b c : ℝ) :
    gaborTransform (D.map fun p => (p.1 + c, p.2)) w a b
      = chi (-(b * c)) * gaborTransform D w (a - c) b := by
  unfold gaborTransform
  rw [Multiset.map_map, ← Multiset.sum_map_mul_left]
  refine congrArg Multiset.sum (Multiset.map_congr rfl fun p _ => ?_)
  simp only [Function.comp_apply]
  rw [show p.1 + c - a = p.1 - (a - c) by ring,
    show -(b * (p.1 + c)) = -(b * c) + -(b * p.1) by ring, chi_add]
  ring

/-- Modulating all amplitudes by `χ(η t)` shifts the analysis frequency by `η`. -/
theorem gaborTransform_modulate (D : Multiset (ℝ × ℂ)) (w : ℝ → ℂ) (a b η : ℝ) :
    gaborTransform (D.map fun p => (p.1, chi (η * p.1) * p.2)) w a b
      = gaborTransform D w a (b - η) := by
  unfold gaborTransform
  rw [Multiset.map_map]
  refine congrArg Multiset.sum (Multiset.map_congr rfl fun p _ => ?_)
  simp only [Function.comp_apply]
  rw [show -((b - η) * p.1) = -(b * p.1) + η * p.1 by ring, chi_add]
  ring

/-- **The modulation/translation identity for spectral data (Weyl form).**  Translating the
ordinates and modulating the amplitudes do not commute: the two orders differ by the Weyl phase
`χ(-ηc)`, exactly as for the operators `T_c` and `M_η` of
`Algebra.SmoothWindows.GaborOperators`. -/
theorem gaborTransform_weyl (D : Multiset (ℝ × ℂ)) (w : ℝ → ℂ) (a b c η : ℝ) :
    gaborTransform (((D.map fun p => (p.1, chi (η * p.1) * p.2))).map fun p => (p.1 + c, p.2))
        w a b
      = chi (-(η * c)) *
        gaborTransform (((D.map fun p => (p.1 + c, p.2))).map
          fun p => (p.1, chi (η * p.1) * p.2)) w a b := by
  simp only [gaborTransform_translate, gaborTransform_modulate]
  rw [show -(b * c) = -(η * c) + -((b - η) * c) by ring, chi_add, mul_assoc]

/-- The Gaussian Gabor transform of a paired critical-line family at the origin of phase space is
the (strictly positive) Gaussian-windowed harmonic sum. -/
theorem gaborTransform_zeroData_pairedOrdinates_pos (S : Multiset ℝ) (hS : S ≠ 0) (s : ℝ) :
    0 < (gaborTransform (zeroData (pairedOrdinates S)) (gaussC s) 0 0).re := by
  rw [gaborTransform_zeroData_zero]
  exact gaussSum_pairedOrdinates_pos S hS s

end SmoothWindows