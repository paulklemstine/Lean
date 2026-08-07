import Mathlib

/-!
# Reciprocal-Zero Harmonics I: the multiplicity-sensitive, conjugate-symmetric harmonic sum

This file defines the *harmonic sum* of a multiset of nonzero complex numbers,

  `H(s) = Σ_{ρ ∈ s} 1/ρ`,

together with the finite-window ("cutoff `T`") version

  `H(Z, T) = Σ_{ρ ∈ Z, |Im ρ| ≤ T} 1/ρ`

used in the Reciprocal-Zero Harmonics programme.  Working with a `Multiset` rather than a
`Finset` makes the statistic **multiplicity sensitive**: a zero of multiplicity `m` contributes
`m/ρ`, exactly as in the classical sum `Σ_ρ 1/ρ` over the zeros of `ζ`.

## Main results

* `harmonicSum_eq_neg_deriv_div` — **Vieta invariance.** If `P = C a · ∏_{r ∈ s} (X - r)` with
  `a ≠ 0` and no root is `0`, then `H(s) = -P'(0)/P(0)`.  The reciprocal sum of a root multiset
  is therefore a *ratio of two coefficients*, not a transcendental function of the individual
  roots.
* `conj_harmonicSum` and `windowSum_real` — **conjugate pairing makes `H` real.**  If the zero
  multiset is invariant under complex conjugation then every symmetric window `|Im ρ| ≤ T`
  is again conjugation invariant, and `H(Z,T)` is a real number.
* `criticalZero_pair_inv` — the conjugate pair `1/2 ± i t` contributes the *positive real*
  quantity `1/(1/4 + t²)`; this is the renormalisation that converts a conditionally organised
  complex sum into an absolutely convergent real spectral statistic.
* `harmonicSum_pairedOrdinates` — the window sum over a conjugate-paired family of critical-line
  zeros with ordinates `S` equals `Σ_{t ∈ S} 1/(1/4 + t²)`.
* `harmonicSum_pairedOrdinates_pos` — that statistic is strictly positive as soon as `S ≠ 0`,
  so `H` can vanish only on empty windows.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** `Σ_{|Im ρ| ≤ T} 1/ρ` is a *real* number for any conjugation
  symmetric zero multiset, and equals a Vieta-type coefficient ratio whenever the multiset is
  the full root multiset of a polynomial.
* **Experiment (Experimenter).** The Vieta identity is proved by `Multiset.induction_on` on the
  root multiset using `derivative_mul`: the inductive step is exactly the logarithmic-derivative
  recursion `P'(0)/P(0) = -1/a + Q'(0)/Q(0)` for `P = (X - a)·Q`.  Reality is proved by showing
  the conjugation-invariance of the window filter.
* **Analysis (Analyst).** Two independent mechanisms appear: an *algebraic* one (Vieta) that
  identifies the value, and an *analytic/symmetry* one (conjugation) that constrains it to `ℝ`.
  Both are insensitive to repetitions, i.e. they hold verbatim for multisets with multiplicity.
* **Critique (Critic).** The hypothesis `0 ∉ s` is genuinely needed: `0⁻¹ = 0` in Lean, so the
  identity `H = -P'(0)/P(0)` fails without it (both sides are then unrelated).  The reality
  statement is not vacuous — `harmonicSum_pairedOrdinates_pos` exhibits nonzero values.
-/

namespace ReciprocalZeroHarmonics

open Polynomial

/-! ## The harmonic sum of a multiset of zeros -/

/-- The **harmonic sum** (reciprocal sum) of a multiset of complex numbers,
`H(s) = Σ_{ρ ∈ s} ρ⁻¹`.  Using a multiset makes the statistic multiplicity sensitive. -/
noncomputable def harmonicSum (s : Multiset ℂ) : ℂ := (s.map fun r => r⁻¹).sum

@[simp] theorem harmonicSum_zero : harmonicSum 0 = 0 := by simp [harmonicSum]

@[simp] theorem harmonicSum_cons (a : ℂ) (s : Multiset ℂ) :
    harmonicSum (a ::ₘ s) = a⁻¹ + harmonicSum s := by simp [harmonicSum]

theorem harmonicSum_add (s t : Multiset ℂ) :
    harmonicSum (s + t) = harmonicSum s + harmonicSum t := by
  simp [harmonicSum]

/-- The monic polynomial with root multiset `s`. -/
noncomputable def rootPoly (s : Multiset ℂ) : ℂ[X] := (s.map fun r => X - C r).prod

theorem rootPoly_eval_zero (s : Multiset ℂ) : (rootPoly s).eval 0 = (s.map fun r => -r).prod := by
  simp [rootPoly, Polynomial.eval_multiset_prod, Multiset.map_map, Function.comp]

theorem rootPoly_eval_zero_ne (s : Multiset ℂ) (h : ∀ r ∈ s, r ≠ 0) :
    (rootPoly s).eval 0 ≠ 0 := by
  rw [rootPoly_eval_zero]
  refine Multiset.prod_ne_zero ?_
  simp only [Multiset.mem_map]
  rintro ⟨r, hr, hr0⟩
  exact h r hr (by simpa using neg_eq_zero.mp hr0)

/-- **Logarithmic-derivative recursion at the origin.**  For the monic polynomial with root
multiset `s` (all roots nonzero) one has `P'(0) = -H(s)·P(0)`. -/
theorem deriv_rootPoly_eval_zero (s : Multiset ℂ) (h : ∀ r ∈ s, r ≠ 0) :
    (derivative (rootPoly s)).eval 0 = -harmonicSum s * (rootPoly s).eval 0 := by
  induction s using Multiset.induction_on with
  | empty => simp [rootPoly]
  | cons a s ih =>
      have ha : a ≠ 0 := h a (Multiset.mem_cons_self a s)
      have hs : ∀ r ∈ s, r ≠ 0 := fun r hr => h r (Multiset.mem_cons_of_mem hr)
      have hp : rootPoly (a ::ₘ s) = (X - C a) * rootPoly s := by simp [rootPoly]
      rw [hp]
      simp only [derivative_mul, derivative_sub, derivative_X, derivative_C, eval_add, eval_mul,
        eval_sub, eval_X, eval_C, sub_zero, one_mul, zero_sub]
      rw [ih hs, harmonicSum_cons, rootPoly_eval_zero]
      field_simp

/-- **Vieta invariance of the harmonic sum.**  If `P = C a · ∏_{r ∈ s}(X - r)` with `a ≠ 0` and
every root is nonzero, then the reciprocal sum of the roots is the coefficient ratio
`-P'(0)/P(0)`.  In particular it only depends on the two lowest coefficients of `P`. -/
theorem harmonicSum_eq_neg_deriv_div (P : ℂ[X]) (s : Multiset ℂ) (a : ℂ) (ha : a ≠ 0)
    (hP : P = C a * rootPoly s) (h : ∀ r ∈ s, r ≠ 0) :
    harmonicSum s = -((derivative P).eval 0) / P.eval 0 := by
  subst hP
  rw [derivative_mul, derivative_C]
  simp only [eval_mul, eval_C, zero_mul, zero_add]
  rw [deriv_rootPoly_eval_zero s h]
  have h0 := rootPoly_eval_zero_ne s h
  field_simp

/-! ## Conjugate symmetry: `H` is a real spectral statistic -/

theorem conj_harmonicSum (s : Multiset ℂ) :
    (starRingEnd ℂ) (harmonicSum s) = harmonicSum (s.map (starRingEnd ℂ)) := by
  simp [harmonicSum, Multiset.map_map, Function.comp, map_multiset_sum]

/-- A multiset of zeros is *conjugation symmetric* when it is invariant under `ρ ↦ conj ρ`
(with multiplicities). -/
def ConjSymm (Z : Multiset ℂ) : Prop := Z.map (starRingEnd ℂ) = Z

section Window

open Classical

/-- The **finite-window harmonic sum** `H(Z,T) = Σ_{ρ ∈ Z, |Im ρ| ≤ T} 1/ρ`, computed with
multiplicities. -/
noncomputable def windowSum (Z : Multiset ℂ) (T : ℝ) : ℂ :=
  harmonicSum (Z.filter fun r => |r.im| ≤ T)

/-- A symmetric window of a conjugation-symmetric multiset is again conjugation symmetric. -/
theorem window_conjSymm (Z : Multiset ℂ) (hZ : ConjSymm Z) (T : ℝ) :
    ConjSymm (Z.filter fun r => |r.im| ≤ T) := by
  unfold ConjSymm at hZ ⊢
  conv_rhs => rw [← hZ]
  rw [Multiset.filter_map]
  exact congrArg _ (Multiset.filter_congr fun x _ => by simp [Function.comp]).symm

/-- **Conjugate pairing turns `H(T)` into a real number.**  For a conjugation-symmetric multiset
of zeros, every symmetric cutoff `|Im ρ| ≤ T` gives a real harmonic sum. -/
theorem windowSum_real (Z : Multiset ℂ) (hZ : ConjSymm Z) (T : ℝ) : (windowSum Z T).im = 0 := by
  have h := conj_harmonicSum (Z.filter fun r => |r.im| ≤ T)
  rw [window_conjSymm Z hZ T] at h
  have h2 := congrArg Complex.im h
  simp [Complex.conj_im, windowSum] at h2 ⊢
  linarith

end Window

/-! ## The critical-line pairing -/

/-- For any `z`, the conjugate pair `z, z̄` contributes the real number `2·Re z/|z|²`. -/
theorem inv_add_conj_inv (z : ℂ) :
    z⁻¹ + ((starRingEnd ℂ) z)⁻¹ = ((2 * z.re / Complex.normSq z : ℝ) : ℂ) := by
  rw [Complex.inv_def, Complex.inv_def]
  simp [Complex.normSq_conj, Complex.ext_iff]
  ring_nf

/-- The critical-line point `1/2 + i t`. -/
noncomputable def criticalZero (t : ℝ) : ℂ := ⟨1 / 2, t⟩

@[simp] theorem criticalZero_re (t : ℝ) : (criticalZero t).re = 1 / 2 := rfl
@[simp] theorem criticalZero_im (t : ℝ) : (criticalZero t).im = t := rfl

theorem criticalZero_ne_zero (t : ℝ) : criticalZero t ≠ 0 := by
  simp [criticalZero, Complex.ext_iff]

theorem criticalZero_conj (t : ℝ) : (starRingEnd ℂ) (criticalZero t) = criticalZero (-t) := by
  simp [criticalZero, Complex.ext_iff]

/-- **The renormalising identity.**  The conjugate pair of critical-line zeros with ordinates
`±t` contributes the positive real number `1/(1/4 + t²)`.  This is the mechanism by which a
conditionally organised complex sum becomes an absolutely convergent real one. -/
theorem criticalZero_pair_inv (t : ℝ) :
    (criticalZero t)⁻¹ + (criticalZero (-t))⁻¹ = ((1 / (1 / 4 + t ^ 2) : ℝ) : ℂ) := by
  rw [← criticalZero_conj t, inv_add_conj_inv]
  norm_num [criticalZero, Complex.normSq_apply]
  ring_nf

/-- The conjugation-symmetric multiset of critical-line zeros with ordinate multiset `S`
(each `t ∈ S` contributing the pair `1/2 ± i t`). -/
noncomputable def pairedOrdinates (S : Multiset ℝ) : Multiset ℂ :=
  S.map criticalZero + S.map fun t => criticalZero (-t)

theorem pairedOrdinates_conjSymm (S : Multiset ℝ) : ConjSymm (pairedOrdinates S) := by
  unfold ConjSymm pairedOrdinates
  rw [Multiset.map_add, Multiset.map_map, Multiset.map_map]
  have h1 : ((starRingEnd ℂ) ∘ criticalZero) = fun t => criticalZero (-t) := by
    funext t; simpa using criticalZero_conj t
  have h2 : ((starRingEnd ℂ) ∘ fun t => criticalZero (-t)) = criticalZero := by
    funext t; simpa using criticalZero_conj (-t)
  rw [h1, h2, add_comm]

/-- **The paired harmonic sum is a real spectral statistic.**  Over a conjugate-paired family of
critical-line zeros the complex sum `Σ 1/ρ` collapses to `Σ_t 1/(1/4 + t²)`. -/
theorem harmonicSum_pairedOrdinates (S : Multiset ℝ) :
    harmonicSum (pairedOrdinates S) = (((S.map fun t => 1 / (1 / 4 + t ^ 2)).sum : ℝ) : ℂ) := by
  have h1 : harmonicSum (pairedOrdinates S)
      = (S.map fun t => (criticalZero t)⁻¹ + (criticalZero (-t))⁻¹).sum := by
    simp [harmonicSum, pairedOrdinates, Multiset.map_add, Multiset.map_map, Function.comp,
      Multiset.sum_map_add]
  rw [h1]
  have h2 : (S.map fun t => (criticalZero t)⁻¹ + (criticalZero (-t))⁻¹)
      = S.map fun t => ((1 / (1 / 4 + t ^ 2) : ℝ) : ℂ) :=
    Multiset.map_congr rfl fun t _ => criticalZero_pair_inv t
  rw [h2, show (S.map fun t => ((1 / (1 / 4 + t ^ 2) : ℝ) : ℂ))
      = (S.map fun t => (1 / (1 / 4 + t ^ 2) : ℝ)).map (fun x : ℝ => (x : ℂ)) by
    rw [Multiset.map_map]; rfl]
  exact (map_multiset_sum Complex.ofRealHom _).symm

/-- **Nonvanishing.**  A nonempty conjugate-paired critical-line window has strictly positive
harmonic sum; in particular `H` detects the presence of zeros and cannot vanish accidentally. -/
theorem harmonicSum_pairedOrdinates_pos (S : Multiset ℝ) (hS : S ≠ 0) :
    0 < (harmonicSum (pairedOrdinates S)).re := by
  rw [harmonicSum_pairedOrdinates, Complex.ofReal_re]
  obtain ⟨t, ht⟩ := Multiset.exists_mem_of_ne_zero hS
  have hpos : ∀ x ∈ S.map fun t => 1 / (1 / 4 + t ^ 2), 0 < x := by
    intro x hx
    obtain ⟨u, _, rfl⟩ := Multiset.mem_map.mp hx
    positivity
  have hmem : (1 : ℝ) / (1 / 4 + t ^ 2) ∈ S.map fun t => 1 / (1 / 4 + t ^ 2) :=
    Multiset.mem_map_of_mem _ ht
  have hnn : ∀ x ∈ S.map fun t => 1 / (1 / 4 + t ^ 2), 0 ≤ x := fun x hx => (hpos x hx).le
  exact lt_of_lt_of_le (by positivity) (Multiset.single_le_sum hnn _ hmem)

end ReciprocalZeroHarmonics