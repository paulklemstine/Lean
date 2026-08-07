import Algebra.ReciprocalZeroHarmonics.Core
import Novelty.IharaZeta

/-!
# Reciprocal-Zero Harmonics II: arithmetic classification of finite spectral harmonics

Direction 2 of the Reciprocal-Zero Harmonics programme asks which algebraic multisets have
rational, algebraic-irrational, or transcendental reciprocal sum.  The Vieta identity proved in
`Core.lean` settles the question for *full* root multisets and reduces everything else to the
arithmetic of the individual roots.

## Main results

* `harmonicSum_roots_rat` — **the reciprocal sum of the complete complex root multiset of a
  rational polynomial `P` with `P(0) ≠ 0` is the rational number `-P'(0)/P(0)`.**  Consequently
  it is *never* irrational and never transcendental: the "musical" statistic of a full Euler
  factor is a Vieta invariant of the coefficients.
* `harmonicSum_sqrtTwo_singleton_irrational` — the sharp boundary: the Galois-unstable
  sub-multiset `{√2}` of the roots of `X² - 2` has irrational reciprocal sum, while the full
  multiset has reciprocal sum `0` (`harmonicSum_roots_X_sq_sub_two`).  Rationality is therefore
  a property of *Galois stability*, not of the size of the multiset.
* `quadratic_singleton_chord_rat_iff` — degree-2 classification: for a rational quadratic
  `X² - sX + p` with `p ≠ 0`, a single root contributes a rational reciprocal iff the root
  itself is rational, whereas the conjugate pair always contributes the rational number `s/p`
  (`quadratic_pair_chord`).
* `localFactor_chord` — **the graph-zeta prototype.**  For the Ihara/Bass local factor
  `p(λ,q,u) = 1 - λu + qu²` catalogued in `Novelty/IharaZeta.lean`, the two zeros are `α⁻¹, β⁻¹`
  for the Frobenius-type pair `α + β = λ`, `αβ = q`, and their reciprocal sum — the *chord
  value* of the factor — equals the adjacency eigenvalue `λ` exactly.  Hence the chord spectrum
  of a regular graph is rational iff its adjacency spectrum is.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Rationality of a reciprocal sum should be equivalent to a
  Galois-invariant coefficient ratio, and should fail exactly for Galois-unstable selections.
* **Experiment (Experimenter).** Over `ℂ` every rational polynomial splits, so
  `Polynomial.Splits.eq_prod_roots` puts it in the shape required by the Vieta lemma; the value
  is then transported back to `ℚ` through `Polynomial.derivative_map` and `eval_map`.  For the
  boundary example we used `irrational_sqrt_two.inv`.
* **Analysis (Analyst).** The experiment *refutes* the naive expectation that reciprocal sums of
  algebraic multisets exhibit a rich rational/irrational/transcendental trichotomy: for full
  root multisets of rational polynomials the answer is always rational.  The trichotomy only
  reappears for proper sub-multisets, where it is governed by the field of definition of the
  selection (degree 2 fully classified here).
* **Critique (Critic).** All statements carry the necessary `P(0) ≠ 0` / `p ≠ 0` hypotheses
  (without them the reciprocals are undefined and Lean's `0⁻¹ = 0` convention would make the
  claims false-but-provable-looking).  Nothing is proved by `decide` or `rfl`.
-/

namespace ReciprocalZeroHarmonics

open Polynomial

/-! ## Full root multisets of rational polynomials -/

/-- **Rationality of the complete reciprocal sum.**  For `P ∈ ℚ[X]` with `P(0) ≠ 0` the sum of
the reciprocals of *all* complex roots of `P`, counted with multiplicity, is the rational number
`-P'(0)/P(0)`. -/
theorem harmonicSum_roots_rat (P : ℚ[X]) (hP : P.eval 0 ≠ 0) :
    harmonicSum (P.map (algebraMap ℚ ℂ)).roots
      = ((-((derivative P).eval 0) / P.eval 0 : ℚ) : ℂ) := by
  set Q : ℂ[X] := P.map (algebraMap ℚ ℂ) with hQ
  have hQ0 : Q.eval 0 = ((P.eval 0 : ℚ) : ℂ) := by
    simp [hQ, Polynomial.eval_map, ← coeff_zero_eq_eval_zero]
  have hPne : ((P.eval 0 : ℚ) : ℂ) ≠ 0 := by exact_mod_cast hP
  have hQne : Q ≠ 0 := fun h => hPne (by rw [← hQ0, h]; simp)
  have hroots : ∀ r ∈ Q.roots, r ≠ 0 := by
    intro r hr hr0
    subst hr0
    rw [mem_roots hQne] at hr
    exact hPne (by rw [← hQ0]; exact hr)
  rw [harmonicSum_eq_neg_deriv_div Q Q.roots Q.leadingCoeff (leadingCoeff_ne_zero.2 hQne)
    (IsAlgClosed.splits Q).eq_prod_roots hroots, hQ0, hQ, derivative_map]
  simp [Polynomial.eval_map, ← coeff_zero_eq_eval_zero]

/-- The reciprocal sum of a full rational root multiset is rational — never irrational, never
transcendental. -/
theorem harmonicSum_roots_isRational (P : ℚ[X]) (hP : P.eval 0 ≠ 0) :
    ∃ c : ℚ, harmonicSum (P.map (algebraMap ℚ ℂ)).roots = (c : ℂ) :=
  ⟨_, harmonicSum_roots_rat P hP⟩

/-! ## The Galois-stability boundary -/

/-- The complete reciprocal sum of the roots of `X² - 2` is `0`. -/
theorem harmonicSum_roots_X_sq_sub_two :
    harmonicSum (((X ^ 2 - C 2 : ℚ[X]).map (algebraMap ℚ ℂ)).roots) = 0 := by
  have hP : ((X ^ 2 - C 2 : ℚ[X])).eval 0 ≠ 0 := by simp
  rw [harmonicSum_roots_rat _ hP]
  simp

/-- `√2` is a root of `X² - 2` over `ℂ`. -/
theorem sqrtTwo_isRoot :
    ((X ^ 2 - C 2 : ℚ[X]).map (algebraMap ℚ ℂ)).IsRoot ((Real.sqrt 2 : ℝ) : ℂ) := by
  have h2 : (Real.sqrt 2 : ℝ) ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  simp only [IsRoot, Polynomial.eval_map, eval₂_sub, eval₂_C, eval₂_X_pow]
  norm_num
  rw [show (((Real.sqrt 2 : ℝ) : ℂ)) ^ 2 = (((Real.sqrt 2 : ℝ) ^ 2 : ℝ) : ℂ) by push_cast; ring, h2]
  norm_num

/-- **The Galois-unstable half is irrational.**  The sub-multiset `{√2}` of the roots of
`X² - 2` has irrational reciprocal sum, in contrast with the rational (indeed zero) value
obtained from the full, Galois-stable multiset. -/
theorem harmonicSum_sqrtTwo_singleton_irrational :
    ¬ ∃ c : ℚ, harmonicSum {((Real.sqrt 2 : ℝ) : ℂ)} = (c : ℂ) := by
  rintro ⟨c, hc⟩
  have h1 : harmonicSum {((Real.sqrt 2 : ℝ) : ℂ)} = (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) := by
    simp [harmonicSum]
  rw [h1] at hc
  have h2 : ((Real.sqrt 2)⁻¹ : ℝ) = (c : ℝ) := by exact_mod_cast hc
  exact (irrational_sqrt_two.inv) ⟨c, h2.symm⟩

/-! ## Complete classification in degree two -/

/-- For a rational quadratic `X² - sX + p` with `p ≠ 0`, the reciprocal of a root is rational
iff the root itself is rational.  Hence a one-element (Galois-unstable) selection has rational
chord value exactly when the quadratic has a rational root. -/
theorem quadratic_singleton_chord_rat_iff (s p : ℚ) (hp : p ≠ 0) (r : ℂ)
    (hr : r ^ 2 - (s : ℂ) * r + (p : ℂ) = 0) :
    (∃ c : ℚ, r⁻¹ = (c : ℂ)) ↔ ∃ c : ℚ, r = (c : ℂ) := by
  have hpc : ((p : ℚ) : ℂ) ≠ 0 := by exact_mod_cast hp
  have hr0 : r ≠ 0 := by
    intro h
    rw [h] at hr
    simp at hr
    exact hpc (by exact_mod_cast hr)
  have hinv : r⁻¹ = ((s : ℂ) - r) / (p : ℂ) := by
    field_simp
    linear_combination hr
  constructor
  · rintro ⟨c, hc⟩
    refine ⟨s - p * c, ?_⟩
    have h : ((s : ℂ) - r) / (p : ℂ) = (c : ℂ) := by rw [← hinv, hc]
    field_simp at h
    push_cast
    linear_combination -h
  · rintro ⟨c, hc⟩
    refine ⟨(s - c) / p, ?_⟩
    rw [hinv, hc]
    push_cast
    ring

/-- The conjugate pair of roots of `X² - sX + p` always has the rational chord value `s/p`. -/
theorem quadratic_pair_chord (s p : ℚ) (hp : p ≠ 0) (r₁ r₂ : ℂ)
    (hsum : r₁ + r₂ = (s : ℂ)) (hprod : r₁ * r₂ = (p : ℂ)) :
    harmonicSum {r₁, r₂} = ((s / p : ℚ) : ℂ) := by
  have hpc : ((p : ℚ) : ℂ) ≠ 0 := by exact_mod_cast hp
  have h1 : r₁ ≠ 0 := by rintro rfl; simp at hprod; exact hpc hprod.symm
  have h2 : r₂ ≠ 0 := by rintro rfl; simp at hprod; exact hpc hprod.symm
  have : harmonicSum {r₁, r₂} = r₁⁻¹ + r₂⁻¹ := by simp [harmonicSum]
  rw [this, inv_add_inv h1 h2, hsum, hprod]
  push_cast
  ring

/-! ## The graph-zeta prototype: chord value of an Ihara local factor -/

open Novelty.IharaZeta in
/-- The zeros of the Bass–Ihara local factor `p(λ,q,u) = 1 - λu + qu²` are the reciprocals
`α⁻¹, β⁻¹` of the Frobenius-type pair `α + β = λ`, `αβ = q`. -/
theorem localFactor_root_inv (l q α β : ℂ) (hs : α + β = l) (hp : α * β = q) (ha : α ≠ 0) :
    localFactor l q α⁻¹ = 0 := by
  rw [localFactor_factor l q α⁻¹ α β hs hp, mul_inv_cancel₀ ha, sub_self, zero_mul]

open Novelty.IharaZeta in
/-- **Chord value of a graph-zeta local factor.**  The reciprocal sum of the two zeros of
`1 - λu + qu²` equals the adjacency eigenvalue `λ`.  The "musical" statistic of an Ihara Euler
factor is thus exactly its Frobenius trace — a Vieta invariant, not a property of the individual
zeros. -/
theorem localFactor_chord (l q α β : ℂ) (hs : α + β = l) (hp : α * β = q) (ha : α ≠ 0)
    (hb : β ≠ 0) :
    localFactor l q α⁻¹ = 0 ∧ localFactor l q β⁻¹ = 0 ∧ harmonicSum {α⁻¹, β⁻¹} = l := by
  refine ⟨localFactor_root_inv l q α β hs hp ha,
    localFactor_root_inv l q β α (by rw [← hs]; ring) (by rw [← hp]; ring) hb, ?_⟩
  simp [harmonicSum, inv_inv, hs]

open Novelty.IharaZeta in
/-- **Rational chord spectrum ⟺ rational trace.**  The chord value of an Ihara local factor is
rational precisely when the underlying eigenvalue is; this is the exact form taken by the
"Galois-invariant coefficient ratio" criterion in the quadratic case. -/
theorem localFactor_chord_rat_iff (l q α β : ℂ) (hs : α + β = l) (hp : α * β = q) (ha : α ≠ 0)
    (hb : β ≠ 0) :
    (∃ c : ℚ, harmonicSum {α⁻¹, β⁻¹} = (c : ℂ)) ↔ ∃ c : ℚ, l = (c : ℂ) := by
  rw [(localFactor_chord l q α β hs hp ha hb).2.2]

end ReciprocalZeroHarmonics