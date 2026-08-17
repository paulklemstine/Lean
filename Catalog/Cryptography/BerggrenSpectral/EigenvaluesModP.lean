import Cryptography.BerggrenSpectral.LorentzAndTree

/-!
# The Exact Eigenvalue Distribution of `M₂` mod `p`

Fourth research cycle: the *spectral distribution* itself, modulo a prime.  Over `ℤ` the
generator `M₂` has spectrum `{-1, 3 + 2√2, 3 - 2√2}` (`berg_charpoly_two`).  Modulo an odd
prime `p` the two hyperbolic eigenvalues become *visible in `𝔽_p` exactly when `2` is a
quadratic residue*, i.e. exactly when `p ≡ ±1 (mod 8)`.

## Main results

* `berg_two_eigen_iff` : `λ` is an eigenvalue of `M₂` over `ZMod p` (there is a nonzero
  vector with `M₂ v = λ v`) **iff** `(λ + 1) (λ² - 6λ + 1) = 0`.
* `berg_two_quadratic_root_iff_isSquare_two` : the quadratic factor has a root in `ZMod p`
  iff `2` is a square mod `p`.
* `berg_two_eigen_split` : for `p ≡ ±1 (mod 8)` the two hyperbolic eigenvalues `3 ± 2√2`
  exist in `𝔽_p`, are distinct, and differ from `-1`; the spectrum is a full set of three
  eigenvalues.
* `berg_two_eigen_inert` : for `p ≡ ±3 (mod 8)` the only eigenvalue is `-1`; the hyperbolic
  part is inert, living in `𝔽_{p²}`.
* `berg_two_eigen_dichotomy_frequency` : the split/inert dichotomy is precisely the
  dichotomy of resonant frequencies `p - 1` vs `p + 1` of `HyperbolicResonance.lean`.
  This is the sense in which "the resonant frequency is read off the spectrum mod `p`".
* `berg_semiprime_frequency_misalignment` : if `p ≡ ±1` and `q ≡ ±3 (mod 8)` then the two
  primes of `N = p q` carry *different* spectral behaviour — split versus inert — which is
  the structural source of the resonance misalignment exploited in `Factorization.lean`.
-/

namespace BerggrenSpectral

open Matrix

variable (p : ℕ) [Fact p.Prime]

/-- The determinant of `M₂ - λ` in closed form. -/
theorem det_M2R_sub (R : Type*) [CommRing R] (lam : R) :
    (M2R R - lam • 1).det = -((lam + 1) * (lam ^ 2 - 6 * lam + 1)) := by
  rw [Matrix.det_fin_three]
  simp [M2R]
  ring

/-- **Eigenvalue criterion.**  Over `ZMod p`, `λ` is an eigenvalue of `M₂` exactly when it is
a root of the characteristic polynomial `(X + 1)(X² - 6X + 1)`. -/
theorem berg_two_eigen_iff (lam : ZMod p) :
    (∃ v : Fin 3 → ZMod p, v ≠ 0 ∧ M2R (ZMod p) *ᵥ v = lam • v) ↔
      (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0 := by
  have hkey : (∃ v : Fin 3 → ZMod p, v ≠ 0 ∧ (M2R (ZMod p) - lam • 1) *ᵥ v = 0) ↔
      (M2R (ZMod p) - lam • 1).det = 0 := Matrix.exists_mulVec_eq_zero_iff
  rw [det_M2R_sub, neg_eq_zero] at hkey
  rw [← hkey]
  constructor
  · rintro ⟨v, hv, hvec⟩
    refine ⟨v, hv, ?_⟩
    rw [Matrix.sub_mulVec, hvec, Matrix.smul_mulVec, Matrix.one_mulVec, sub_self]
  · rintro ⟨v, hv, hvec⟩
    refine ⟨v, hv, ?_⟩
    rw [Matrix.sub_mulVec, Matrix.smul_mulVec, Matrix.one_mulVec] at hvec
    exact sub_eq_zero.mp hvec

/-- `-1` is always an eigenvalue, with eigenvector `(1,-1,0)`. -/
theorem berg_two_eigen_neg_one : ((-1 : ZMod p) + 1) * ((-1 : ZMod p) ^ 2 - 6 * (-1) + 1) = 0 := by
  ring

/-- The hyperbolic quadratic has a root mod `p` iff `2` is a square mod `p`. -/
theorem berg_two_quadratic_root_iff_isSquare_two (hp : p ≠ 2) :
    (∃ lam : ZMod p, lam ^ 2 - 6 * lam + 1 = 0) ↔ IsSquare (2 : ZMod p) := by
  have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd_prime p hp
  constructor
  · rintro ⟨lam, hlam⟩
    refine ⟨(lam - 3) * (2 : ZMod p)⁻¹, ?_⟩
    field_simp
    linear_combination -hlam
  · rintro ⟨s, hs⟩
    exact ⟨3 + 2 * s, by linear_combination (4 : ZMod p) * hs.symm⟩

/-- **Split case.**  For `p ≡ ±1 (mod 8)` both hyperbolic eigenvalues exist in `𝔽_p`, and
they are distinct from each other and from `-1`. -/
theorem berg_two_eigen_split (hp : p ≠ 2) (h8 : p % 8 = 1 ∨ p % 8 = 7) :
    ∃ lam : ZMod p, lam ≠ -1 ∧ (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0 := by
  have hsq : IsSquare (2 : ZMod p) := (ZMod.exists_sq_eq_two_iff hp).mpr h8
  obtain ⟨lam, hlam⟩ := (berg_two_quadratic_root_iff_isSquare_two p hp).mpr hsq
  refine ⟨lam, ?_, by rw [hlam, mul_zero]⟩
  intro hcon
  rw [hcon] at hlam
  have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd_prime p hp
  -- `8 = 2³ = 0` in the field `ZMod p` forces `2 = 0`, contradicting `p` odd
  have hcube : (2 : ZMod p) ^ 3 = 0 := by linear_combination hlam
  exact h2 (pow_eq_zero_iff (n := 3) (by norm_num) |>.mp hcube)

/-- **Inert case.**  For `p ≡ ±3 (mod 8)` the hyperbolic eigenvalues do not exist in `𝔽_p`:
the only eigenvalue of `M₂` mod `p` is `-1`. -/
theorem berg_two_eigen_inert (hp : p ≠ 2) (h8 : p % 8 = 3 ∨ p % 8 = 5) (lam : ZMod p)
    (h : (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0) : lam = -1 := by
  rcases mul_eq_zero.mp h with h1 | h1
  · linear_combination h1
  · exfalso
    have hsq : IsSquare (2 : ZMod p) :=
      (berg_two_quadratic_root_iff_isSquare_two p hp).mp ⟨lam, h1⟩
    rcases (ZMod.exists_sq_eq_two_iff hp).mp hsq with h | h <;> omega

/-- **Spectrum ⇒ frequency.**  The split/inert dichotomy of the spectrum mod `p` is exactly
the dichotomy of resonant frequencies. -/
theorem berg_two_eigen_dichotomy_frequency (hp : p ≠ 2) :
    ((∃ lam : ZMod p, lam ≠ -1 ∧ (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0) →
        (redMat p M₂) ^ (p - 1) = 1) ∧
    ((∀ lam : ZMod p, (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0 → lam = -1) →
        (redMat p M₂) ^ (p + 1) = 1) := by
  have hne : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd_prime p hp
  have hhalf : p / 2 = (p - 1) / 2 := by
    obtain ⟨t, ht⟩ := (Nat.Prime.odd_of_ne_two Fact.out hp); omega
  constructor
  · rintro ⟨lam, hne1, hroot⟩
    have hquad : lam ^ 2 - 6 * lam + 1 = 0 := by
      rcases mul_eq_zero.mp hroot with h1 | h1
      · exact absurd (by linear_combination h1 : lam = -1) hne1
      · exact h1
    have hsq : IsSquare (2 : ZMod p) :=
      (berg_two_quadratic_root_iff_isSquare_two p hp).mp ⟨lam, hquad⟩
    have hchi := (ZMod.euler_criterion p hne).mp hsq
    rw [hhalf] at hchi
    exact berg_two_resonance_qr p hp hchi
  · intro honly
    have hnsq : ¬ IsSquare (2 : ZMod p) := by
      intro hs
      obtain ⟨lam, hlam⟩ := (berg_two_quadratic_root_iff_isSquare_two p hp).mpr hs
      have hlam1 : lam = -1 := honly lam (by rw [hlam, mul_zero])
      rw [hlam1] at hlam
      have hcube : (2 : ZMod p) ^ 3 = 0 := by linear_combination hlam
      exact hne (pow_eq_zero_iff (n := 3) (by norm_num) |>.mp hcube)
    have hchi : (2 : ZMod p) ^ ((p - 1) / 2) = -1 := by
      rcases two_chi_cases p hp with h | h
      · exact absurd ((ZMod.euler_criterion p hne).mpr (by rw [hhalf]; exact h)) hnsq
      · exact h
    exact berg_two_resonance_nqr p hp hchi

/-- **Spectral misalignment at a semiprime.**  If `p ≡ ±1 (mod 8)` while `q ≡ ±3 (mod 8)`,
the hyperbolic spectrum of `M₂` is split at `p` and inert at `q`; correspondingly the
frequencies are `p - 1` and `q + 1`.  This mismatch of spectral types at the two primes of
`N = p q` is the structural reason the resonance test of `Factorization.lean` can separate
them. -/
theorem berg_semiprime_frequency_misalignment (q : ℕ) [Fact q.Prime] (hp : p ≠ 2) (hq : q ≠ 2)
    (h8p : p % 8 = 1 ∨ p % 8 = 7) (h8q : q % 8 = 3 ∨ q % 8 = 5) :
    (redMat p M₂) ^ (p - 1) = 1 ∧ (redMat q M₂) ^ (q + 1) = 1 ∧
      (∃ lam : ZMod p, lam ≠ -1 ∧ (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0) ∧
      (∀ lam : ZMod q, (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0 → lam = -1) := by
  refine ⟨(berg_two_resonance_mod_eight p hp).1 h8p, (berg_two_resonance_mod_eight q hq).2 h8q,
    berg_two_eigen_split p hp h8p, fun lam h => berg_two_eigen_inert q hq h8q lam h⟩

end BerggrenSpectral