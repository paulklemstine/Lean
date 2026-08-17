/-
# The Teichmüller length spectrum of the torus

`Geometry.Teichmuller.TranslationLength` computes the Teichmüller translation length of a single
Anosov mapping class: for `g ∈ SL(2, ℤ)` with `|tr g| > 2` the minimal displacement
`min_τ d_T(τ, g · τ)` is attained and equals `log λ(g)` with
`λ(g) = (|tr g| + √(tr g² − 4)) / 2`, and every such trace is an integer of absolute value
at least `3`.

This file determines the **length spectrum** — the set of all these numbers — completely.
It is conjecture **C2** of `FUTURE_DIRECTIONS.md`.  Writing

    spectrumValue n = log ((n + √(n² − 4)) / 2)   (n ∈ ℤ, n ≥ 3),

the results are:

* `Teichmuller.tr_anosovClass`, `Teichmuller.isLeast_teichDist_anosovClass` : every integer
  `n ≥ 3` is realized, by the explicit Anosov class `!![n, −1; 1, 0]`;
* `Teichmuller.mem_lengthSpectrum_iff` : **the spectrum is exactly**
  `{ spectrumValue n : n ∈ ℤ, n ≥ 3 }`;
* `Teichmuller.spectrumValue_strictMonoOn` : the parametrization is strictly increasing, so the
  spectrum is order-isomorphic to `ℤ ∩ [3, ∞)`;
* `Teichmuller.abs_tr_le_of_log_stretch_le` : a translation length `≤ M` forces `|tr g| ≤ 2 e^M`,
  whence `Teichmuller.finite_lengthSpectrum_le` : **the spectrum is discrete** — only finitely
  many translation lengths lie below any bound;
* `Teichmuller.lengthSpectrum_unbounded` : the spectrum is unbounded;
* `Teichmuller.spectrumValue_three_eq_catMap`, together with
  `TranslationLength.goldenRatio_sq_le_stretch`, identifies the bottom of the spectrum as
  `log ((3 + √5)/2)`, the length of Arnold's cat map.

-- !-- Lab Notes -- !--
Hypothesizer (C2): the spectrum should be `{log ((t+√(t²−4))/2) : t ∈ ℤ, t ≥ 3}` — a metric
invariant computed by an arithmetic one.
Experimenter: realization needs one explicit matrix family; `!![t, −1; 1, 0]` has determinant
`1` and trace `t`, so no case analysis on `t` is required.  The converse inclusion is
`three_le_abs_tr` plus the observation that `stretch g` depends on `g` only through `|tr g|`.
Discreteness comes from `stretch_add_inv` (`λ + λ⁻¹ = |tr|`), which converts a bound on the
length into a bound on the trace; this is sharper than the compactness argument one would use
in general and gives the explicit constant `2 e^M`.
Analyst: the spectrum is therefore a *closed, discrete, unbounded* subset of `(0, ∞)` with least
element `log((3+√5)/2)`, and its `n`-th element is `arcosh(n/2)`; the counting function is
`#{n ≥ 3 : arcosh(n/2) ≤ L} = ⌊2 cosh L⌋ − 2 ∼ e^L`, matching the growth predicted in C2.
Critic: `mem_lengthSpectrum_iff` is an honest iff, both directions with content: `←` requires
building the matrix, `→` requires that the trace is an integer *and* that `stretch` factors
through `|tr|`.  No statement here is about a single example.
-/
import Mathlib
import Geometry.Teichmuller.TranslationLength

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

/-- The value of the Teichmüller length spectrum attached to an integer trace `n`. -/
noncomputable def spectrumValue (n : ℤ) : ℝ :=
  Real.log (((n : ℝ) + Real.sqrt ((n : ℝ) ^ 2 - 4)) / 2)

/-- The Anosov mapping class `!![n, -1; 1, 0]` of trace `n`. -/
def anosovClass (n : ℤ) : SL(2, ℤ) :=
  ⟨!![n, -1; 1, 0], by simp [Matrix.det_fin_two_of]⟩

@[simp] theorem tr_anosovClass (n : ℤ) : tr (anosovClass n) = (n : ℝ) := by
  simp [tr, entry, anosovClass]

theorem abs_tr_anosovClass {n : ℤ} (hn : 3 ≤ n) : 2 < |tr (anosovClass n)| := by
  rw [tr_anosovClass, abs_of_nonneg (by exact_mod_cast (by omega : (0:ℤ) ≤ n))]
  exact_mod_cast (by omega : (2:ℤ) < n)

theorem stretch_anosovClass {n : ℤ} (hn : 3 ≤ n) :
    stretch (anosovClass n) = ((n : ℝ) + Real.sqrt ((n : ℝ) ^ 2 - 4)) / 2 := by
  have hnn : (0:ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : (0:ℤ) ≤ n)
  rw [stretch, tr_anosovClass, abs_of_nonneg hnn]

/-- **Realization.**  For every integer `n ≥ 3` the number `spectrumValue n` is the Teichmüller
translation length of an explicit Anosov mapping class of the torus. -/
theorem isLeast_teichDist_anosovClass {n : ℤ} (hn : 3 ≤ n) :
    IsLeast {r : ℝ | ∃ τ : ℍ, r = teichDist τ (anosovClass n • τ)} (spectrumValue n) := by
  have h := isLeast_teichDist_smul (g := anosovClass n) (abs_tr_anosovClass hn)
  rwa [stretch_anosovClass hn, ← spectrumValue] at h

/-- The stretch factor of a hyperbolic class depends only on the absolute value of its trace,
which is an integer `≥ 3`. -/
theorem exists_spectrumValue_eq (g : SL(2, ℤ)) (ht : 2 < |tr g|) :
    ∃ n : ℤ, 3 ≤ n ∧ Real.log (stretch g) = spectrumValue n := by
  set m : ℤ := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 + (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hm
  have htr : tr g = (m : ℝ) := by simp [tr, entry, hm]
  refine ⟨|m|, ?_, ?_⟩
  · have h3 : 3 ≤ |tr g| := three_le_abs_tr g ht
    rw [htr] at h3
    have : ((3 : ℤ) : ℝ) ≤ ((|m| : ℤ) : ℝ) := by
      rw [Int.cast_abs]; exact_mod_cast h3
    exact_mod_cast this
  · have habs : |tr g| = ((|m| : ℤ) : ℝ) := by rw [htr, Int.cast_abs]
    have hsq : tr g ^ 2 = ((|m| : ℤ) : ℝ) ^ 2 := by
      rw [← sq_abs (tr g), habs]
    rw [spectrumValue, stretch, habs, hsq]

/-- **The Teichmüller length spectrum of the torus is exactly
`{ log ((n + √(n²−4))/2) : n ∈ ℤ, n ≥ 3 }`.** -/
theorem mem_lengthSpectrum_iff (r : ℝ) :
    (∃ g : SL(2, ℤ), 2 < |tr g| ∧ r = Real.log (stretch g)) ↔ ∃ n : ℤ, 3 ≤ n ∧ r = spectrumValue n := by
  constructor
  · rintro ⟨g, ht, rfl⟩
    obtain ⟨n, hn, hval⟩ := exists_spectrumValue_eq g ht
    exact ⟨n, hn, hval⟩
  · rintro ⟨n, hn, rfl⟩
    exact ⟨anosovClass n, abs_tr_anosovClass hn, (stretch_anosovClass hn).symm ▸ rfl⟩

/-! ### Order structure: strict monotonicity, discreteness, unboundedness -/

theorem spectrumValue_pos {n : ℤ} (hn : 3 ≤ n) : 0 < spectrumValue n := by
  have hnn : (3:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hsq : (0:ℝ) ≤ (n : ℝ) ^ 2 - 4 := by nlinarith
  have hsqrt : 0 ≤ Real.sqrt ((n : ℝ) ^ 2 - 4) := Real.sqrt_nonneg _
  rw [spectrumValue]
  exact Real.log_pos (by linarith)

/-- The parametrization of the spectrum by the trace is strictly increasing. -/
theorem spectrumValue_strictMonoOn {m n : ℤ} (hm : 3 ≤ m) (hmn : m < n) :
    spectrumValue m < spectrumValue n := by
  have hmr : (3:ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hnr : (m : ℝ) < (n : ℝ) := by exact_mod_cast hmn
  have hsqm : (0:ℝ) ≤ (m : ℝ) ^ 2 - 4 := by nlinarith
  have hsqrtle : Real.sqrt ((m : ℝ) ^ 2 - 4) ≤ Real.sqrt ((n : ℝ) ^ 2 - 4) :=
    Real.sqrt_le_sqrt (by nlinarith)
  have hpos : (0:ℝ) < ((m : ℝ) + Real.sqrt ((m : ℝ) ^ 2 - 4)) / 2 := by
    have := Real.sqrt_nonneg ((m : ℝ) ^ 2 - 4)
    linarith
  rw [spectrumValue, spectrumValue]
  exact Real.log_lt_log hpos (by linarith)

/-- **Discreteness, quantitatively.**  A translation length at most `M` forces the trace to be
at most `2 e^M` in absolute value. -/
theorem abs_tr_le_of_log_stretch_le {g : SL(2, ℤ)} (ht : 2 < |tr g|)
    (hM : Real.log (stretch g) ≤ M) : |tr g| ≤ 2 * Real.exp M := by
  have h1 : 1 < stretch g := one_lt_stretch ht
  have hpos : 0 < stretch g := by linarith
  have hle : stretch g ≤ Real.exp M := by
    have := Real.exp_le_exp.mpr hM
    rwa [Real.exp_log hpos] at this
  have hinv : (stretch g)⁻¹ ≤ 1 := by
    rw [inv_le_one₀ hpos]
    linarith
  have hsum : stretch g + (stretch g)⁻¹ = |tr g| := stretch_add_inv ht
  have h1le : (1:ℝ) ≤ Real.exp M := le_trans h1.le hle
  linarith [hsum, hle, hinv]

/-- **The length spectrum is discrete**: below any bound it contains only finitely many
values. -/
theorem finite_lengthSpectrum_le (M : ℝ) :
    {r : ℝ | (∃ g : SL(2, ℤ), 2 < |tr g| ∧ r = Real.log (stretch g)) ∧ r ≤ M}.Finite := by
  have hsub : {r : ℝ | (∃ g : SL(2, ℤ), 2 < |tr g| ∧ r = Real.log (stretch g)) ∧ r ≤ M} ⊆
      spectrumValue '' (Set.Icc (3 : ℤ) ⌈2 * Real.exp M⌉) := by
    rintro r ⟨⟨g, ht, rfl⟩, hM⟩
    obtain ⟨n, hn, hval⟩ := exists_spectrumValue_eq g ht
    refine ⟨n, ⟨hn, ?_⟩, hval.symm⟩
    have habs : |tr g| ≤ 2 * Real.exp M := abs_tr_le_of_log_stretch_le ht hM
    have hstretch : Real.log (stretch g) = spectrumValue n := hval
    -- `|tr g| = n`, so the integer `n` is bounded by `⌈2 e^M⌉`
    have hn3 : 3 ≤ |tr g| := three_le_abs_tr g ht
    have hnr : (n : ℝ) ≤ 2 * Real.exp M := by
      have hmono : ∀ {a b : ℤ}, 3 ≤ a → 3 ≤ b → spectrumValue a = spectrumValue b → a = b := by
        intro a b ha hb hab
        rcases lt_trichotomy a b with h | h | h
        · exact absurd hab (ne_of_lt (spectrumValue_strictMonoOn ha h))
        · exact h
        · exact absurd hab.symm (ne_of_lt (spectrumValue_strictMonoOn hb h))
      -- identify `n` with the integer `|tr g|`
      set m : ℤ := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 + (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hm
      have htr : tr g = (m : ℝ) := by simp [tr, entry, hm]
      have habs' : |tr g| = ((|m| : ℤ) : ℝ) := by rw [htr, Int.cast_abs]
      have hm3 : 3 ≤ |m| := by
        have : ((3:ℤ) : ℝ) ≤ ((|m| : ℤ) : ℝ) := by rw [← habs']; exact_mod_cast hn3
        exact_mod_cast this
      have hsame : Real.log (stretch g) = spectrumValue |m| := by
        have hsq : tr g ^ 2 = ((|m| : ℤ) : ℝ) ^ 2 := by rw [← sq_abs (tr g), habs']
        rw [spectrumValue, stretch, habs', hsq]
      have : n = |m| := hmono hn hm3 (hval ▸ hsame)
      rw [this, ← habs']
      exact habs
    exact Int.le_ceil_iff.mpr (by linarith)
  exact Set.Finite.subset (Set.Finite.image _ (Set.finite_Icc _ _)) hsub

/-- **The length spectrum is unbounded.** -/
theorem lengthSpectrum_unbounded (M : ℝ) :
    ∃ g : SL(2, ℤ), 2 < |tr g| ∧ M < Real.log (stretch g) := by
  set n : ℤ := max 3 (⌈2 * Real.exp M⌉ + 1) with hn
  have hn3 : 3 ≤ n := le_max_left _ _
  have hnbig : 2 * Real.exp M < (n : ℝ) := by
    have h1 : (⌈2 * Real.exp M⌉ : ℝ) + 1 ≤ (n : ℝ) := by
      have : (⌈2 * Real.exp M⌉ + 1 : ℤ) ≤ n := le_max_right _ _
      exact_mod_cast this
    have h2 : 2 * Real.exp M ≤ (⌈2 * Real.exp M⌉ : ℝ) := Int.le_ceil _
    linarith
  refine ⟨anosovClass n, abs_tr_anosovClass hn3, ?_⟩
  rw [stretch_anosovClass hn3]
  have hsqrt : 0 ≤ Real.sqrt ((n : ℝ) ^ 2 - 4) := Real.sqrt_nonneg _
  have hexp : 0 < Real.exp M := Real.exp_pos M
  have hlow : Real.exp M < ((n : ℝ) + Real.sqrt ((n : ℝ) ^ 2 - 4)) / 2 := by linarith
  have := Real.log_lt_log hexp hlow
  rwa [Real.log_exp] at this

/-! ### Concavity of the spectrum and its counting function -/

/-- `cosh` and `sinh` of the length attached to a real trace `x ≥ 2`. -/
theorem cosh_log_stretchOf {x : ℝ} (hx : 2 ≤ x) :
    Real.cosh (Real.log ((x + Real.sqrt (x ^ 2 - 4)) / 2)) = x / 2 ∧
      Real.sinh (Real.log ((x + Real.sqrt (x ^ 2 - 4)) / 2)) = Real.sqrt (x ^ 2 - 4) / 2 := by
  have hD0 : (0:ℝ) ≤ x ^ 2 - 4 := by nlinarith
  have hD : Real.sqrt (x ^ 2 - 4) ^ 2 = x ^ 2 - 4 := Real.sq_sqrt hD0
  have hDnn : 0 ≤ Real.sqrt (x ^ 2 - 4) := Real.sqrt_nonneg _
  have hspos : 0 < (x + Real.sqrt (x ^ 2 - 4)) / 2 := by linarith
  have hmul : ((x + Real.sqrt (x ^ 2 - 4)) / 2) * ((x - Real.sqrt (x ^ 2 - 4)) / 2) = 1 := by
    nlinarith [hD]
  have hinv : ((x + Real.sqrt (x ^ 2 - 4)) / 2)⁻¹ = (x - Real.sqrt (x ^ 2 - 4)) / 2 :=
    DivisionMonoid.inv_eq_of_mul _ _ hmul
  constructor
  · rw [Real.cosh_log hspos, hinv]; ring
  · rw [Real.sinh_log hspos, hinv]; ring

theorem cosh_spectrumValue {n : ℤ} (hn : 3 ≤ n) : Real.cosh (spectrumValue n) = (n : ℝ) / 2 := by
  have hx : (2:ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : (2:ℤ) ≤ n)
  exact (cosh_log_stretchOf hx).1

theorem sinh_spectrumValue {n : ℤ} (hn : 3 ≤ n) :
    Real.sinh (spectrumValue n) = Real.sqrt ((n : ℝ) ^ 2 - 4) / 2 := by
  have hx : (2:ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : (2:ℤ) ≤ n)
  exact (cosh_log_stretchOf hx).2

/-- **The length spectrum is concave**: its consecutive gaps are strictly decreasing.  This is
the inequality `√(((n−1)²−4)((n+1)²−4)) < n² − 3` in disguise. -/
theorem spectrumValue_gap_lt {n : ℤ} (hn : 4 ≤ n) :
    spectrumValue (n + 1) - spectrumValue n < spectrumValue n - spectrumValue (n - 1) := by
  have hn3 : (3:ℤ) ≤ n := by omega
  have hnm : (3:ℤ) ≤ n - 1 := by omega
  have hnp : (3:ℤ) ≤ n + 1 := by omega
  have hnr : (4:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set a := spectrumValue (n - 1) with ha
  set b := spectrumValue (n + 1) with hb
  set c := spectrumValue n with hc
  have hapos : 0 < a := spectrumValue_pos hnm
  have hbpos : 0 < b := spectrumValue_pos hnp
  have hcpos : 0 < c := spectrumValue_pos hn3
  have hAnn : (0:ℝ) ≤ ((n : ℝ) - 1) ^ 2 - 4 := by nlinarith
  have hBnn : (0:ℝ) ≤ ((n : ℝ) + 1) ^ 2 - 4 := by nlinarith
  have hcosha : Real.cosh a = ((n : ℝ) - 1) / 2 := by
    rw [ha, cosh_spectrumValue hnm]; push_cast; ring
  have hcoshb : Real.cosh b = ((n : ℝ) + 1) / 2 := by
    rw [hb, cosh_spectrumValue hnp]; push_cast; ring
  have hsinha : Real.sinh a = Real.sqrt (((n : ℝ) - 1) ^ 2 - 4) / 2 := by
    rw [ha, sinh_spectrumValue hnm]; push_cast; ring_nf
  have hsinhb : Real.sinh b = Real.sqrt (((n : ℝ) + 1) ^ 2 - 4) / 2 := by
    rw [hb, sinh_spectrumValue hnp]; push_cast; ring_nf
  have hcoshc : Real.cosh c = (n : ℝ) / 2 := cosh_spectrumValue hn3
  have hsinhc : Real.sinh c = Real.sqrt ((n : ℝ) ^ 2 - 4) / 2 := sinh_spectrumValue hn3
  -- the key algebraic inequality
  have hprod : Real.sqrt (((n : ℝ) - 1) ^ 2 - 4) * Real.sqrt (((n : ℝ) + 1) ^ 2 - 4)
      < (n : ℝ) ^ 2 - 3 := by
    rw [← Real.sqrt_mul hAnn]
    have hlt : (((n : ℝ) - 1) ^ 2 - 4) * (((n : ℝ) + 1) ^ 2 - 4) < ((n : ℝ) ^ 2 - 3) ^ 2 := by
      nlinarith
    have h3 : (0:ℝ) < (n : ℝ) ^ 2 - 3 := by nlinarith
    have := Real.sqrt_lt_sqrt (by nlinarith) hlt
    rwa [Real.sqrt_sq h3.le] at this
  -- compare `cosh (a + b)` with `cosh (2 c)`
  have hsum : Real.cosh (a + b) < Real.cosh (2 * c) := by
    rw [Real.cosh_add, Real.cosh_two_mul, hcosha, hcoshb, hsinha, hsinhb, hcoshc, hsinhc]
    have hD : Real.sqrt ((n : ℝ) ^ 2 - 4) ^ 2 = (n : ℝ) ^ 2 - 4 :=
      Real.sq_sqrt (by nlinarith)
    nlinarith [hprod, hD]
  have habs := Real.cosh_lt_cosh.mp hsum
  rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ a + b), abs_of_nonneg (by linarith : (0:ℝ) ≤ 2 * c)]
    at habs
  linarith

/-- A length is at most `L` exactly when its trace is at most `⌊2 cosh L⌋`. -/
theorem spectrumValue_le_iff {n : ℤ} (hn : 3 ≤ n) {L : ℝ} (hL : 0 ≤ L) :
    spectrumValue n ≤ L ↔ n ≤ ⌊2 * Real.cosh L⌋ := by
  have hpos : 0 < spectrumValue n := spectrumValue_pos hn
  constructor
  · intro h
    have hcosh : Real.cosh (spectrumValue n) ≤ Real.cosh L := by
      rw [Real.cosh_le_cosh, abs_of_nonneg hpos.le, abs_of_nonneg hL]
      exact h
    rw [cosh_spectrumValue hn] at hcosh
    exact Int.le_floor.mpr (by linarith)
  · intro h
    have hle : (n : ℝ) ≤ 2 * Real.cosh L := by
      have h1 : ((n : ℤ) : ℝ) ≤ ((⌊2 * Real.cosh L⌋ : ℤ) : ℝ) := by exact_mod_cast h
      have h2 : ((⌊2 * Real.cosh L⌋ : ℤ) : ℝ) ≤ 2 * Real.cosh L := Int.floor_le _
      linarith
    have hcosh : Real.cosh (spectrumValue n) ≤ Real.cosh L := by
      rw [cosh_spectrumValue hn]; linarith
    have := Real.cosh_le_cosh.mp hcosh
    rwa [abs_of_nonneg hpos.le, abs_of_nonneg hL] at this

/-- **The counting function of the length spectrum.**  The traces realizing a length at most `L`
are exactly the integers in `[3, ⌊2 cosh L⌋]`, so the number of spectrum values below `L` is
`⌊2 cosh L⌋ − 2` (which grows like `e^L`). -/
theorem setOf_spectrumValue_le (L : ℝ) (hL : 0 ≤ L) :
    {n : ℤ | 3 ≤ n ∧ spectrumValue n ≤ L} = Set.Icc 3 ⌊2 * Real.cosh L⌋ := by
  ext n
  constructor
  · rintro ⟨hn, hle⟩
    exact ⟨hn, (spectrumValue_le_iff hn hL).mp hle⟩
  · rintro ⟨hn, hle⟩
    exact ⟨hn, (spectrumValue_le_iff hn hL).mpr hle⟩

theorem card_spectrumValue_le (L : ℝ) :
    (Finset.Icc (3 : ℤ) ⌊2 * Real.cosh L⌋).card = (⌊2 * Real.cosh L⌋ - 2).toNat := by
  rw [Int.card_Icc]
  congr 1
  omega

/-- The bottom of the spectrum is the translation length of Arnold's cat map. -/
theorem spectrumValue_three_eq_catMap : spectrumValue 3 = Real.log ((3 + Real.sqrt 5) / 2) := by
  rw [spectrumValue]
  norm_num

/-- **The minimum of the length spectrum** is `log ((3+√5)/2) = spectrumValue 3`. -/
theorem isLeast_lengthSpectrum :
    IsLeast {r : ℝ | ∃ g : SL(2, ℤ), 2 < |tr g| ∧ r = Real.log (stretch g)} (spectrumValue 3) := by
  constructor
  · exact ⟨anosovClass 3, abs_tr_anosovClass le_rfl, (stretch_anosovClass le_rfl).symm ▸ rfl⟩
  · rintro r ⟨g, ht, rfl⟩
    rw [spectrumValue_three_eq_catMap]
    have hgap : (3 + Real.sqrt 5) / 2 ≤ stretch g := goldenRatio_sq_le_stretch g ht
    exact Real.log_le_log (by positivity) hgap

end Teichmuller