import Mathlib
import Logic.ThreeQubitGHZNormalForm

/-!
# Genericity and symmetry of the GHZ SLOCC orbit

This file continues the three-qubit programme of
`Catalog/Combinatorics/ThreeQubitHyperdeterminant.lean` and
`Catalog/Logic/ThreeQubitGHZNormalForm.lean`.  The previous cycle proved the
Dür–Vidal–Cirac classification: the GHZ SLOCC orbit is *exactly* the nonvanishing locus
`{hyperdet ψ ≠ 0}`, the W orbit is the genuinely entangled part of `{hyperdet ψ = 0}`, and
the remaining tensors are biseparable.  Two natural questions were left open there and are
answered here.

## 1.  Topology: the GHZ orbit is open and dense

`hyperdet` is a polynomial in the eight amplitudes, hence continuous, so the GHZ class is
open (`isOpen_ghzClass`).  Density is the interesting half: given an arbitrary tensor `a` we
perturb it along the *GHZ direction* `pert a t = a + t · (|000⟩ + |111⟩)` and show
(`hyperdet_pert`) that `t ↦ hyperdet (pert a t)` is a **monic quartic** in `t`
(`pertPoly`, `pertPoly_eval`, `pertPoly_monic`).  A nonzero polynomial has finitely many
roots, so arbitrarily small `t` avoid them: every tensor is an arbitrarily close limit of
GHZ-class tensors (`exists_slocc_ghz_close`, `dense_ghzClass`).  Consequently the degenerate
locus — the union of the W class and the biseparable tensors — is closed with empty interior
(`interior_degenerate_eq_empty`, `interior_wClass_eq_empty`,
`interior_biseparable_eq_empty`): the classification of the previous cycle is a genuine
stratification, with one open dense stratum.  This strictly generalizes
`wState_mem_closure_ghz_orbit`, which is the case `a = wState`.

## 2.  Symmetry: the stabilizer of GHZ

`stab_ghzBare_iff` computes the full stabilizer of `|000⟩ + |111⟩` in `GL(2)^{×3}`
(invertibility is *not* assumed — it is forced, `stab_det_sq_eq_one`): a triple `(A, B, C)`
fixes GHZ iff either all three matrices are diagonal with
`A₀₀B₀₀C₀₀ = A₁₁B₁₁C₁₁ = 1`, or all three are antidiagonal with
`A₀₁B₀₁C₀₁ = A₁₀B₁₀C₁₀ = 1`.  The two components are separated by the character
`(A,B,C) ↦ det A · det B · det C ∈ {1, -1}` (`stab_det_eq_one_or_neg_one`,
`stab_diagonal_iff_det_eq_one`).  In particular the antidiagonal component disappears inside
`SL(2)^{×3}`, where the stabilizer is exactly the two-dimensional torus
`(diag(l, l⁻¹), diag(m, m⁻¹), diag((lm)⁻¹, lm))` (`stab_ghzBare_sl_iff`).

## Main results

* `hyperdet_pert`, `pertPoly_eval`, `pertPoly_monic` — the GHZ-direction perturbation of any
  tensor has monic quartic hyperdeterminant.
* `exists_slocc_ghz_close` — every amplitude tensor is an entrywise-arbitrarily-close limit of
  tensors SLOCC equivalent to GHZ.
* `isOpen_ghzClass`, `dense_ghzClass` — the GHZ class is open and dense.
* `interior_degenerate_eq_empty`, `interior_wClass_eq_empty`, `interior_biseparable_eq_empty`.
* `stab_ghzBare_iff`, `stab_ghz_iff_stab_ghzBare` — the stabilizer of GHZ in `GL(2)^{×3}`.
* `stab_det_eq_one_or_neg_one`, `stab_diagonal_iff_det_eq_one` — its two components.
* `stab_ghzBare_sl_iff` — `Stab_{SL(2)^{×3}}(GHZ) ≅ (ℂ*)²`.
-/

open Matrix

noncomputable section

namespace ThreeQubitOrbit

open ThreeQubitGHZ

/-! ## The GHZ direction and its quartic -/

theorem hyperdet_ghzBare : hyperdet ghzBare = 1 := by
  simp [hyperdet, ghzBare]

/-- Perturbation of an arbitrary amplitude tensor in the direction of the unnormalized GHZ
tensor `|000⟩ + |111⟩`. -/
def pert (a : Amp) (t : ℂ) : Amp := fun i j k => a i j k + t * ghzBare i j k

theorem pert_zero (a : Amp) : pert a 0 = a := by
  funext i j k; simp [pert]

theorem pert_sub (a : Amp) (t : ℂ) (i j k : Fin 2) :
    pert a t i j k - a i j k = t * ghzBare i j k := by
  simp [pert]

/-- The hyperdeterminant along the GHZ direction, written through the Alice pencil. -/
theorem hyperdet_pert (a : Amp) (t : ℂ) :
    hyperdet (pert a t) =
      (pencilB a + (a 0 0 0 + a 1 1 1) * t + t ^ 2) ^ 2
        - 4 * (d0 a + a 0 1 1 * t) * (d1 a + a 1 0 0 * t) := by
  simp only [hyperdet_eq_discriminant, pert, pencilB, d0, d1, ghzBare, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  ring

/-- The monic quartic whose evaluation at `t` is `hyperdet (pert a t)`. -/
def pertPoly (a : Amp) : Polynomial ℂ :=
  Polynomial.X ^ 4
    + Polynomial.C (2 * (a 0 0 0 + a 1 1 1)) * Polynomial.X ^ 3
    + Polynomial.C ((a 0 0 0 + a 1 1 1) ^ 2 + 2 * pencilB a - 4 * (a 0 1 1 * a 1 0 0))
        * Polynomial.X ^ 2
    + Polynomial.C (2 * pencilB a * (a 0 0 0 + a 1 1 1)
        - 4 * (d0 a * a 1 0 0 + a 0 1 1 * d1 a)) * Polynomial.X
    + Polynomial.C (hyperdet a)

theorem pertPoly_eval (a : Amp) (t : ℂ) : (pertPoly a).eval t = hyperdet (pert a t) := by
  rw [hyperdet_pert]
  simp only [pertPoly, Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_pow,
    Polynomial.eval_C, Polynomial.eval_X]
  rw [hyperdet_eq_discriminant]
  ring

theorem pertPoly_monic (a : Amp) : (pertPoly a).Monic := by
  unfold pertPoly
  monicity!

theorem pertPoly_ne_zero (a : Amp) : pertPoly a ≠ 0 := (pertPoly_monic a).ne_zero

/-- **Every tensor has arbitrarily small GHZ-direction perturbations of nonzero
hyperdeterminant.**  The point is that the hyperdeterminant restricted to that line is a
*monic* quartic, hence a nonzero polynomial, hence has finitely many roots. -/
theorem exists_small_hyperdet_ne_zero (a : Amp) {ε : ℝ} (hε : 0 < ε) :
    ∃ t : ℂ, ‖t‖ < ε ∧ hyperdet (pert a t) ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  set f : ℕ → ℂ := fun n : ℕ => ((ε / ((n : ℝ) + 2) : ℝ) : ℂ) with hf
  have hinj : Function.Injective f := by
    intro m n hmn
    have h1 : (ε / ((m : ℝ) + 2)) = (ε / ((n : ℝ) + 2)) := Complex.ofReal_inj.mp hmn
    have hm : (0 : ℝ) < (m : ℝ) + 2 := by positivity
    have hn : (0 : ℝ) < (n : ℝ) + 2 := by positivity
    field_simp at h1
    have h3 : (m : ℝ) = (n : ℝ) := by linarith
    exact_mod_cast h3
  have hmem : ∀ n : ℕ, f n ∈ { x | (pertPoly a).IsRoot x } := by
    intro n
    have hn : (0 : ℝ) < (n : ℝ) + 2 := by positivity
    have hlt : ‖f n‖ < ε := by
      simp only [hf, Complex.norm_real, Real.norm_eq_abs]
      rw [abs_of_pos (by positivity)]
      rw [div_lt_iff₀ hn]
      nlinarith
    have := hcon (f n) hlt
    simpa [Polynomial.IsRoot, pertPoly_eval] using this
  have hinf : { x : ℂ | (pertPoly a).IsRoot x }.Infinite :=
    Set.infinite_of_injective_forall_mem hinj hmem
  exact hinf (Polynomial.finite_setOf_isRoot (pertPoly_ne_zero a))

/-- **The GHZ class is dense.**  Every three-qubit amplitude tensor is an entrywise
arbitrarily close limit of tensors that are SLOCC equivalent to GHZ. -/
theorem exists_slocc_ghz_close (a : Amp) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b ghz := by
  obtain ⟨t, ht, hne⟩ := exists_small_hyperdet_ne_zero a hε
  refine ⟨pert a t, ?_, ?_⟩
  · intro i j k
    rw [pert_sub]
    have hg : ghzBare i j k = 0 ∨ ghzBare i j k = 1 := by
      fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [ghzBare]
    rcases hg with h | h
    · rw [h]; simpa using hε
    · rw [h]; simpa using ht
  · exact (slocc_ghz_iff_hyperdet_ne_zero _).2 hne

/-! ## Topological form of the statements -/

theorem continuous_hyperdet : Continuous hyperdet := by
  unfold hyperdet
  fun_prop

/-- The GHZ SLOCC class is open. -/
theorem isOpen_ghzClass : IsOpen { a : Amp | SLOCC a ghz } := by
  have : { a : Amp | SLOCC a ghz } = hyperdet ⁻¹' {0}ᶜ := by
    ext a
    simp [slocc_ghz_iff_hyperdet_ne_zero]
  rw [this]
  exact (isOpen_compl_singleton).preimage continuous_hyperdet

/-- Entrywise smallness implies smallness in the sup metric of the amplitude space. -/
theorem dist_amp_lt {a b : Amp} {ε : ℝ} (hε : 0 < ε)
    (h : ∀ i j k, ‖a i j k - b i j k‖ < ε) : dist a b < ε := by
  rw [dist_pi_lt_iff hε]
  intro i
  rw [dist_pi_lt_iff hε]
  intro j
  rw [dist_pi_lt_iff hε]
  intro k
  rw [dist_eq_norm]
  exact h i j k

/-- The GHZ SLOCC class is dense. -/
theorem dense_ghzClass : Dense { a : Amp | SLOCC a ghz } := by
  intro a
  rw [Metric.mem_closure_iff]
  intro ε hε
  obtain ⟨b, hb, hslocc⟩ := exists_slocc_ghz_close a hε
  exact ⟨b, hslocc, dist_amp_lt hε fun i j k => by rw [norm_sub_rev]; exact hb i j k⟩

/-- The degenerate locus (W class together with the biseparable tensors) has empty interior. -/
theorem interior_degenerate_eq_empty :
    interior { a : Amp | hyperdet a = 0 } = ∅ := by
  have hsub : { a : Amp | hyperdet a = 0 } ⊆ { a : Amp | SLOCC a ghz }ᶜ := by
    intro a ha
    simp only [Set.mem_compl_iff, Set.mem_setOf_eq, slocc_ghz_iff_hyperdet_ne_zero]
    simpa using ha
  have := dense_ghzClass.interior_compl
  have h2 : interior { a : Amp | hyperdet a = 0 } ⊆
      interior { a : Amp | SLOCC a ghz }ᶜ := interior_mono hsub
  rw [this] at h2
  exact Set.subset_empty_iff.1 h2

theorem interior_wClass_eq_empty : interior { a : Amp | SLOCC a wState } = ∅ := by
  have hsub : { a : Amp | SLOCC a wState } ⊆ { a : Amp | hyperdet a = 0 } := by
    intro a ha
    exact ((slocc_wState_iff a).1 ha).2
  have := interior_mono hsub
  rw [interior_degenerate_eq_empty] at this
  exact Set.subset_empty_iff.1 this

theorem interior_biseparable_eq_empty : interior { a : Amp | ¬ Genuine a } = ∅ := by
  have hsub : { a : Amp | ¬ Genuine a } ⊆ { a : Amp | hyperdet a = 0 } := by
    intro a ha
    by_contra h
    exact ha (genuine_of_hyperdet_ne_zero h)
  have := interior_mono hsub
  rw [interior_degenerate_eq_empty] at this
  exact Set.subset_empty_iff.1 this

/-! ## The stabilizer of GHZ -/

theorem localAct_ghzBare_apply (A B C : Matrix (Fin 2) (Fin 2) ℂ) (i j k : Fin 2) :
    localAct A B C ghzBare i j k = A i 0 * B j 0 * C k 0 + A i 1 * B j 1 * C k 1 := by
  simp only [localAct, ghzBare, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- Invertibility of a stabilizing triple is automatic: the relative invariance of the
hyperdeterminant forces `(det A · det B · det C)² = 1`. -/
theorem stab_det_sq_eq_one {A B C : Matrix (Fin 2) (Fin 2) ℂ}
    (h : localAct A B C ghzBare = ghzBare) :
    (A.det * B.det * C.det) ^ 2 = 1 := by
  have := hyperdet_localAct A B C ghzBare
  rw [h, hyperdet_ghzBare] at this
  linear_combination -this

/-- **The stabilizer of the GHZ tensor in `GL(2)^{×3}`.** -/
theorem stab_ghzBare_iff (A B C : Matrix (Fin 2) (Fin 2) ℂ) :
    localAct A B C ghzBare = ghzBare ↔
      ((A 0 1 = 0 ∧ A 1 0 = 0 ∧ B 0 1 = 0 ∧ B 1 0 = 0 ∧ C 0 1 = 0 ∧ C 1 0 = 0) ∧
          A 0 0 * B 0 0 * C 0 0 = 1 ∧ A 1 1 * B 1 1 * C 1 1 = 1) ∨
      ((A 0 0 = 0 ∧ A 1 1 = 0 ∧ B 0 0 = 0 ∧ B 1 1 = 0 ∧ C 0 0 = 0 ∧ C 1 1 = 0) ∧
          A 0 1 * B 0 1 * C 0 1 = 1 ∧ A 1 0 * B 1 0 * C 1 0 = 1) := by
  constructor
  · intro h
    have e : ∀ i j k, A i 0 * B j 0 * C k 0 + A i 1 * B j 1 * C k 1 = ghzBare i j k := by
      intro i j k
      rw [← localAct_ghzBare_apply, h]
    have hdet := stab_det_sq_eq_one h
    have hprod : A.det * B.det * C.det ≠ 0 := by
      intro h0
      rw [h0] at hdet
      norm_num at hdet
    have hA : A.det ≠ 0 := fun h0 => hprod (by rw [h0]; ring)
    have hB : B.det ≠ 0 := fun h0 => hprod (by rw [h0]; ring)
    have hC : C.det ≠ 0 := fun h0 => hprod (by rw [h0]; ring)
    have hAd : A 0 0 * A 1 1 - A 0 1 * A 1 0 ≠ 0 := by
      rwa [Matrix.det_fin_two] at hA
    have hBd : B 0 0 * B 1 1 - B 0 1 * B 1 0 ≠ 0 := by
      rwa [Matrix.det_fin_two] at hB
    have hCd : C 0 0 * C 1 1 - C 0 1 * C 1 0 ≠ 0 := by
      rwa [Matrix.det_fin_two] at hC
    have e000 := e 0 0 0
    have e001 := e 0 0 1
    have e010 := e 0 1 0
    have e011 := e 0 1 1
    have e100 := e 1 0 0
    have e101 := e 1 0 1
    have e110 := e 1 1 0
    have e111 := e 1 1 1
    simp only [ghzBare, Matrix.cons_val_zero, Matrix.cons_val_one] at e000 e001 e010 e011 e100 e101 e110 e111
    -- the four "off-diagonal" products vanish
    have k1 : A 0 0 * B 1 0 = 0 := by
      have hz : (A 0 0 * B 1 0) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = 0 := by
        linear_combination (C 1 1) * e010 - (C 0 1) * e011
      exact (mul_eq_zero.mp hz).resolve_right hCd
    have k2 : A 0 1 * B 1 1 = 0 := by
      have hz : (A 0 1 * B 1 1) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = 0 := by
        linear_combination (-(C 1 0)) * e010 + (C 0 0) * e011
      exact (mul_eq_zero.mp hz).resolve_right hCd
    have k3 : A 1 0 * B 0 0 = 0 := by
      have hz : (A 1 0 * B 0 0) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = 0 := by
        linear_combination (C 1 1) * e100 - (C 0 1) * e101
      exact (mul_eq_zero.mp hz).resolve_right hCd
    have k4 : A 1 1 * B 0 1 = 0 := by
      have hz : (A 1 1 * B 0 1) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = 0 := by
        linear_combination (-(C 1 0)) * e100 + (C 0 0) * e101
      exact (mul_eq_zero.mp hz).resolve_right hCd
    -- the four "diagonal" products are determined
    have m1 : (A 0 0 * B 0 0) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = C 1 1 := by
      linear_combination (C 1 1) * e000 - (C 0 1) * e001
    have m2 : (A 0 1 * B 0 1) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = -C 1 0 := by
      linear_combination (-(C 1 0)) * e000 + (C 0 0) * e001
    have m3 : (A 1 0 * B 1 0) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = -C 0 1 := by
      linear_combination (C 1 1) * e110 - (C 0 1) * e111
    have m4 : (A 1 1 * B 1 1) * (C 0 0 * C 1 1 - C 0 1 * C 1 0) = C 0 0 := by
      linear_combination (-(C 1 0)) * e110 + (C 0 0) * e111
    by_cases hA00 : A 0 0 = 0
    · -- antidiagonal branch
      right
      have hA01 : A 0 1 ≠ 0 := by
        intro h0
        apply hAd
        rw [hA00, h0]; ring
      have hA10 : A 1 0 ≠ 0 := by
        intro h0
        apply hAd
        rw [hA00, h0]; ring
      have hB11 : B 1 1 = 0 := (mul_eq_zero.mp k2).resolve_left hA01
      have hB01 : B 0 1 ≠ 0 := by
        intro h0
        apply hBd
        rw [hB11, h0]; ring
      have hB10 : B 1 0 ≠ 0 := by
        intro h0
        apply hBd
        rw [hB11, h0]; ring
      have hA11 : A 1 1 = 0 := (mul_eq_zero.mp k4).resolve_right hB01
      have hB00 : B 0 0 = 0 := (mul_eq_zero.mp k3).resolve_left hA10
      have hC11 : C 1 1 = 0 := by
        rw [← m1, hA00]; ring
      have hC00 : C 0 0 = 0 := by
        rw [← m4, hA11]; ring
      have hCdet : -(C 0 1 * C 1 0) ≠ 0 := by
        intro h0
        apply hCd
        rw [hC00, hC11]
        linear_combination h0
      have hC01 : C 0 1 ≠ 0 := by
        intro h0; apply hCdet; rw [h0]; ring
      have hC10 : C 1 0 ≠ 0 := by
        intro h0; apply hCdet; rw [h0]; ring
      refine ⟨⟨hA00, hA11, hB00, hB11, hC00, hC11⟩, ?_, ?_⟩
      · have : (A 0 1 * B 0 1 * C 0 1 - 1) * C 1 0 = 0 := by
          rw [hC00, hC11] at m2
          linear_combination -m2
        rcases mul_eq_zero.mp this with h' | h'
        · linear_combination h'
        · exact absurd h' hC10
      · have : (A 1 0 * B 1 0 * C 1 0 - 1) * C 0 1 = 0 := by
          rw [hC00, hC11] at m3
          linear_combination -m3
        rcases mul_eq_zero.mp this with h' | h'
        · linear_combination h'
        · exact absurd h' hC01
    · -- diagonal branch
      left
      have hB10 : B 1 0 = 0 := (mul_eq_zero.mp k1).resolve_left hA00
      have hB00 : B 0 0 ≠ 0 := by
        intro h0
        apply hBd
        rw [hB10, h0]; ring
      have hB11 : B 1 1 ≠ 0 := by
        intro h0
        apply hBd
        rw [hB10, h0]; ring
      have hA01 : A 0 1 = 0 := (mul_eq_zero.mp k2).resolve_right hB11
      have hA11 : A 1 1 ≠ 0 := by
        intro h0
        apply hAd
        rw [hA01, h0]; ring
      have hB01 : B 0 1 = 0 := (mul_eq_zero.mp k4).resolve_left hA11
      have hA10 : A 1 0 = 0 := (mul_eq_zero.mp k3).resolve_right hB00
      have hC10 : C 1 0 = 0 := by
        have h0 : (0 : ℂ) = -C 1 0 := by rw [← m2, hA01]; ring
        linear_combination h0
      have hC01 : C 0 1 = 0 := by
        have h0 : (0 : ℂ) = -C 0 1 := by rw [← m3, hA10]; ring
        linear_combination h0
      have hCdet : C 0 0 * C 1 1 ≠ 0 := by
        intro h0
        apply hCd
        rw [hC01, hC10, h0]; ring
      have hC00 : C 0 0 ≠ 0 := fun h0 => hCdet (by rw [h0]; ring)
      have hC11 : C 1 1 ≠ 0 := fun h0 => hCdet (by rw [h0]; ring)
      refine ⟨⟨hA01, hA10, hB01, hB10, hC01, hC10⟩, ?_, ?_⟩
      · have : (A 0 0 * B 0 0 * C 0 0 - 1) * C 1 1 = 0 := by
          rw [hC01, hC10] at m1
          linear_combination m1
        rcases mul_eq_zero.mp this with h' | h'
        · linear_combination h'
        · exact absurd h' hC11
      · have : (A 1 1 * B 1 1 * C 1 1 - 1) * C 0 0 = 0 := by
          rw [hC01, hC10] at m4
          linear_combination m4
        rcases mul_eq_zero.mp this with h' | h'
        · linear_combination h'
        · exact absurd h' hC00
  · rintro (⟨⟨hA01, hA10, hB01, hB10, hC01, hC10⟩, h1, h2⟩ |
        ⟨⟨hA00, hA11, hB00, hB11, hC00, hC11⟩, h1, h2⟩)
    · funext i j k
      rw [localAct_ghzBare_apply]
      fin_cases i <;> fin_cases j <;> fin_cases k <;>
        simp only [ghzBare, Fin.isValue, Fin.zero_eta, Fin.mk_one, Matrix.cons_val_zero,
          Matrix.cons_val_one, hA01, hA10, hB01, hB10, hC01, hC10] <;>
        first
          | linear_combination h1
          | linear_combination h2
          | ring
    · funext i j k
      rw [localAct_ghzBare_apply]
      fin_cases i <;> fin_cases j <;> fin_cases k <;>
        simp only [ghzBare, Fin.isValue, Fin.zero_eta, Fin.mk_one, Matrix.cons_val_zero,
          Matrix.cons_val_one, hA00, hA11, hB00, hB11, hC00, hC11] <;>
        first
          | linear_combination h1
          | linear_combination h2
          | ring

/-- Stabilizing `ghz` and stabilizing the unnormalized `ghzBare` are the same condition. -/
theorem stab_ghz_iff_stab_ghzBare (A B C : Matrix (Fin 2) (Fin 2) ℂ) :
    localAct A B C ghz = ghz ↔ localAct A B C ghzBare = ghzBare := by
  have key : ∀ i j k, localAct A B C ghz i j k = c2 * localAct A B C ghzBare i j k := by
    intro i j k
    simp only [localAct, Fin.sum_univ_two, ghz_apply]
    ring
  constructor
  · intro h
    funext i j k
    have h1 : localAct A B C ghz i j k = ghz i j k := by rw [h]
    rw [key i j k, ghz_apply] at h1
    exact mul_left_cancel₀ c2_ne_zero h1
  · intro h
    funext i j k
    rw [key i j k, h, ghz_apply]

/-- The two components of the stabilizer are separated by the sign of
`det A · det B · det C`. -/
theorem stab_det_eq_one_or_neg_one {A B C : Matrix (Fin 2) (Fin 2) ℂ}
    (h : localAct A B C ghzBare = ghzBare) :
    A.det * B.det * C.det = 1 ∨ A.det * B.det * C.det = -1 := by
  rcases (stab_ghzBare_iff A B C).1 h with
      ⟨⟨hA01, hA10, hB01, hB10, hC01, hC10⟩, h1, h2⟩ |
      ⟨⟨hA00, hA11, hB00, hB11, hC00, hC11⟩, h1, h2⟩
  · left
    simp only [Matrix.det_fin_two, hA01, hA10, hB01, hB10, hC01, hC10]
    linear_combination (A 1 1 * B 1 1 * C 1 1) * h1 + h2
  · right
    simp only [Matrix.det_fin_two, hA00, hA11, hB00, hB11, hC00, hC11]
    linear_combination (-(A 1 0 * B 1 0 * C 1 0)) * h1 - h2

/-- Inside the stabilizer, being diagonal is exactly the condition `det A · det B · det C = 1`.
So the stabilizer has two connected components, exchanged by the simultaneous bit flip. -/
theorem stab_diagonal_iff_det_eq_one {A B C : Matrix (Fin 2) (Fin 2) ℂ}
    (h : localAct A B C ghzBare = ghzBare) :
    (A 0 1 = 0 ∧ A 1 0 = 0 ∧ B 0 1 = 0 ∧ B 1 0 = 0 ∧ C 0 1 = 0 ∧ C 1 0 = 0) ↔
      A.det * B.det * C.det = 1 := by
  constructor
  · rintro ⟨hA01, hA10, hB01, hB10, hC01, hC10⟩
    rcases (stab_ghzBare_iff A B C).1 h with
        ⟨_, h1, h2⟩ | ⟨⟨hA00, hA11, hB00, hB11, hC00, hC11⟩, h1, h2⟩
    · simp only [Matrix.det_fin_two, hA01, hA10, hB01, hB10, hC01, hC10]
      linear_combination (A 1 1 * B 1 1 * C 1 1) * h1 + h2
    · exfalso
      rw [hA01, hB01, hC01] at h1
      norm_num at h1
  · intro hd
    rcases (stab_ghzBare_iff A B C).1 h with
        ⟨hz, _, _⟩ | ⟨⟨hA00, hA11, hB00, hB11, hC00, hC11⟩, h1, h2⟩
    · exact hz
    · exfalso
      have hneg : A.det * B.det * C.det = -1 := by
        simp only [Matrix.det_fin_two, hA00, hA11, hB00, hB11, hC00, hC11]
        linear_combination (-(A 1 0 * B 1 0 * C 1 0)) * h1 - h2
      rw [hd] at hneg
      norm_num at hneg

/-- **The stabilizer of GHZ inside `SL(2)^{×3}` is the two-dimensional torus.**  The
antidiagonal component of the full stabilizer has `det A · det B · det C = -1`, so it does not
meet `SL(2)^{×3}`. -/
theorem stab_ghzBare_sl_iff {A B C : Matrix (Fin 2) (Fin 2) ℂ}
    (hA : A.det = 1) (hB : B.det = 1) (hC : C.det = 1) :
    localAct A B C ghzBare = ghzBare ↔
      ∃ l m : ℂ, l ≠ 0 ∧ m ≠ 0 ∧
        A = !![l, 0; 0, l⁻¹] ∧ B = !![m, 0; 0, m⁻¹] ∧ C = !![(l * m)⁻¹, 0; 0, l * m] := by
  constructor
  · intro h
    have hdiag : (A 0 1 = 0 ∧ A 1 0 = 0 ∧ B 0 1 = 0 ∧ B 1 0 = 0 ∧ C 0 1 = 0 ∧ C 1 0 = 0) := by
      rw [stab_diagonal_iff_det_eq_one h, hA, hB, hC]; ring
    obtain ⟨hA01, hA10, hB01, hB10, hC01, hC10⟩ := hdiag
    rcases (stab_ghzBare_iff A B C).1 h with ⟨_, h1, h2⟩ | ⟨⟨hA00, _, _, _, _, _⟩, h1, _⟩
    swap
    · exfalso
      rw [hA01, hB01, hC01] at h1
      norm_num at h1
    have hAdet : A 0 0 * A 1 1 = 1 := by
      rw [Matrix.det_fin_two, hA01, hA10] at hA
      linear_combination hA
    have hBdet : B 0 0 * B 1 1 = 1 := by
      rw [Matrix.det_fin_two, hB01, hB10] at hB
      linear_combination hB
    have hCdet : C 0 0 * C 1 1 = 1 := by
      rw [Matrix.det_fin_two, hC01, hC10] at hC
      linear_combination hC
    have hA00 : A 0 0 ≠ 0 := by
      intro h0; rw [h0] at hAdet; norm_num at hAdet
    have hB00 : B 0 0 ≠ 0 := by
      intro h0; rw [h0] at hBdet; norm_num at hBdet
    have hA11 : A 1 1 = (A 0 0)⁻¹ := by
      field_simp
      linear_combination hAdet
    have hB11 : B 1 1 = (B 0 0)⁻¹ := by
      field_simp
      linear_combination hBdet
    have hC00v : C 0 0 = (A 0 0 * B 0 0)⁻¹ := by
      have hab : A 0 0 * B 0 0 ≠ 0 := mul_ne_zero hA00 hB00
      field_simp
      linear_combination h1
    have hC11v : C 1 1 = A 0 0 * B 0 0 := by
      have hab : A 0 0 * B 0 0 ≠ 0 := mul_ne_zero hA00 hB00
      have : C 0 0 * C 1 1 = 1 := hCdet
      rw [hC00v] at this
      field_simp at this
      linear_combination this
    refine ⟨A 0 0, B 0 0, hA00, hB00, ?_, ?_, ?_⟩
    · ext i j
      fin_cases i <;> fin_cases j <;>
        simp [hA01, hA10, hA11]
    · ext i j
      fin_cases i <;> fin_cases j <;>
        simp [hB01, hB10, hB11]
    · ext i j
      fin_cases i <;> fin_cases j <;>
        simp [hC01, hC10, hC00v, hC11v]
  · rintro ⟨l, m, hl, hm, rfl, rfl, rfl⟩
    rw [stab_ghzBare_iff]
    left
    refine ⟨⟨by simp, by simp, by simp, by simp, by simp, by simp⟩, ?_, ?_⟩
    · simp
      field_simp
    · simp
      field_simp

end ThreeQubitOrbit

end