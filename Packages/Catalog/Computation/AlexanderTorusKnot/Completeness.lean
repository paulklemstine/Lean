/-
# The Alexander polynomial is a complete invariant on torus knots — and reading it off is
# exactly a factoring problem

Cycle 1 (`Computation.AlexanderTorusKnot.GeneralTorus`) built the Alexander polynomial
`Δ_{a,b}` of the torus knot `T(a,b)` (`gcd(a,b) = 1`) as the cyclotomic product over the
divisor spectrum `S(a,b) = {d : d ∣ ab, d ∤ a, d ∤ b}`.

This file closes the loop in the *computational* direction:

* `cyclotomic_dvd_torusAlexander_iff` : `Φ_d ∣ Δ_{a,b} ↔ d ∈ S(a,b)` (for `d > 0`), so the
  polynomial and its divisor spectrum carry exactly the same information;
* `spectrum_max` : `max S(a,b) = a·b` — the *knot group order* is the top of the spectrum;
* `coSpectrum_max` and `coSpectrum_max_of_not_dvd` : the two torus parameters are recovered
  as the two maximal elements of the complement `D(ab) \ S(a,b)`;
* `torusAlexander_injective` : `Δ_{a,b} = Δ_{a',b'} → (a,b) = (a',b')` for `1 < a < b`
  coprime — the Alexander polynomial is a *complete* invariant of torus knots;
* `torusAlexander_recovers_factorization` : the recovery pipeline, stated as a single
  algorithm: from `Δ_{a,b}` alone one reads `ab`, then `b`, then `a`.

The "catch" is visible in the statement: every step of the recovery quantifies over the
divisors of `ab`, i.e. over the very factorization one is trying to find, and the object
`Δ_{a,b}` has degree `(a-1)(b-1)`, exponential in the bit length of `ab`.
-/
import Computation.AlexanderTorusKnot.GeneralTorus

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-! ## The spectrum is readable from the polynomial -/

lemma cyclotomic_prime_int {d : ℕ} (hd : 0 < d) : Prime (cyclotomic d ℤ) :=
  UniqueFactorizationMonoid.irreducible_iff_prime.1 (cyclotomic.irreducible hd)

/-- **The polynomial knows its spectrum.** For `d > 0`, `Φ_d` divides `Δ_{a,b}` exactly when
`d` lies in the divisor spectrum of `T(a,b)`. -/
theorem cyclotomic_dvd_torusAlexander_iff {a b d : ℕ} (hd : 0 < d) :
    cyclotomic d ℤ ∣ torusAlexander a b ↔ d ∈ spectrum a b := by
  constructor
  · intro hdvd
    obtain ⟨e, he, hde⟩ := (cyclotomic_prime_int hd).exists_mem_finset_dvd hdvd
    have hepos : 0 < e := by
      rcases Nat.eq_zero_or_pos e with rfl | h
      · exact absurd (mem_spectrum.1 he).1 (by simp [(mem_spectrum.1 he).2.1])
      · exact h
    have : cyclotomic d ℤ = cyclotomic e ℤ :=
      Bridges.AlexanderTorus.eq_of_monic_irreducible_dvd (cyclotomic.monic d ℤ)
        (cyclotomic.monic e ℤ) (cyclotomic.irreducible hd) (cyclotomic.irreducible hepos) hde
    have : d = e := cyclotomic_injective (R := ℤ) this
    rwa [this]
  · intro hd'
    exact Finset.dvd_prod_of_mem (fun d => cyclotomic d ℤ) hd'

/-- Two torus knots with the same Alexander polynomial have the same divisor spectrum. -/
theorem spectrum_eq_of_torusAlexander_eq {a b a' b' : ℕ}
    (h : torusAlexander a b = torusAlexander a' b') : spectrum a b = spectrum a' b' := by
  ext d
  rcases Nat.eq_zero_or_pos d with rfl | hd
  · constructor <;> intro hmem <;>
      exact absurd (mem_spectrum.1 hmem).1 (by simp [(mem_spectrum.1 hmem).2.1])
  · rw [← cyclotomic_dvd_torusAlexander_iff hd, ← cyclotomic_dvd_torusAlexander_iff hd, h]

/-! ## Recovering the torus parameters from the spectrum -/

lemma mul_mem_spectrum {a b : ℕ} (ha : 1 < a) (hb : 1 < b) : a * b ∈ spectrum a b := by
  refine mem_spectrum.2 ⟨dvd_rfl, by positivity, ?_, ?_⟩
  · intro h
    have := Nat.le_of_dvd (by omega) h
    nlinarith
  · intro h
    have := Nat.le_of_dvd (by omega) h
    nlinarith

/-- **Top of the spectrum.** The largest element of the divisor spectrum is `a·b`. -/
theorem spectrum_max {a b : ℕ} (ha : 1 < a) (hb : 1 < b) :
    (spectrum a b).max' ⟨a * b, mul_mem_spectrum ha hb⟩ = a * b := by
  refine le_antisymm (Finset.max'_le _ _ _ fun y hy => ?_)
    (Finset.le_max' _ _ (mul_mem_spectrum ha hb))
  have hy' := mem_spectrum.1 hy
  exact Nat.le_of_dvd (by positivity) hy'.1

/-- The complement of the spectrum inside the divisors of `ab`. -/
def coSpectrum (a b : ℕ) : Finset ℕ := (a * b).divisors \ spectrum a b

lemma mem_coSpectrum {a b d : ℕ} :
    d ∈ coSpectrum a b ↔ d ∣ a * b ∧ a * b ≠ 0 ∧ (d ∣ a ∨ d ∣ b) := by
  simp only [coSpectrum, Finset.mem_sdiff, Nat.mem_divisors, mem_spectrum, not_and, not_not]
  constructor
  · rintro ⟨⟨hdvd, hne⟩, h⟩
    refine ⟨hdvd, hne, ?_⟩
    by_cases hda : d ∣ a
    · exact Or.inl hda
    · by_cases hdb : d ∣ b
      · exact Or.inr hdb
      · exact absurd (h hdvd hne hda) hdb
  · rintro ⟨hdvd, hne, h⟩
    refine ⟨⟨hdvd, hne⟩, fun _ _ hna => ?_⟩
    rcases h with h | h
    · exact absurd h hna
    · exact h

lemma mem_coSpectrum_of_dvd_right {a b d : ℕ} (ha : 0 < a) (hb : 0 < b) (h : d ∣ b) :
    d ∈ coSpectrum a b :=
  mem_coSpectrum.2 ⟨h.mul_left a, by positivity, Or.inr h⟩

/-- **Second readout.** For `1 < a < b` coprime, the largest element of the complement is
the larger torus parameter `b`. -/
theorem coSpectrum_max {a b : ℕ} (ha : 1 < a) (hlt : a < b) :
    (coSpectrum a b).max' ⟨b, mem_coSpectrum_of_dvd_right (by omega) (by omega) dvd_rfl⟩ = b := by
  refine le_antisymm (Finset.max'_le _ _ _ fun y hy => ?_)
    (Finset.le_max' _ _ (mem_coSpectrum_of_dvd_right (by omega) (by omega) dvd_rfl))
  rcases (mem_coSpectrum.1 hy).2.2 with h | h
  · exact le_trans (Nat.le_of_dvd (by omega) h) (by omega)
  · exact Nat.le_of_dvd (by omega) h

lemma not_dvd_of_coprime_lt {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a) : ¬ a ∣ b := by
  intro h
  have : a = 1 := Nat.eq_one_of_dvd_coprimes hab dvd_rfl h
  omega

/-- **Third readout.** The smaller torus parameter `a` is the largest element of the
complement that does *not* divide `b`. -/
theorem coSpectrum_max_of_not_dvd {a b : ℕ} (hab : Nat.Coprime a b) (ha : 1 < a) (hlt : a < b) :
    ((coSpectrum a b).filter (fun d => ¬ d ∣ b)).max'
        ⟨a, Finset.mem_filter.2
          ⟨mem_coSpectrum.2 ⟨(dvd_refl a).mul_right b, Nat.mul_ne_zero (by omega) (by omega), Or.inl dvd_rfl⟩,
            not_dvd_of_coprime_lt hab ha⟩⟩ = a := by
  refine le_antisymm (Finset.max'_le _ _ _ fun y hy => ?_) (Finset.le_max' _ _ ?_)
  · obtain ⟨hy1, hy2⟩ := Finset.mem_filter.1 hy
    rcases (mem_coSpectrum.1 hy1).2.2 with h | h
    · exact Nat.le_of_dvd (by omega) h
    · exact absurd h hy2
  · exact Finset.mem_filter.2
      ⟨mem_coSpectrum.2 ⟨(dvd_refl a).mul_right b, Nat.mul_ne_zero (by omega) (by omega), Or.inl dvd_rfl⟩,
        not_dvd_of_coprime_lt hab ha⟩

/-- Maxima of equal finsets agree. -/
lemma max'_congr {s t : Finset ℕ} (h : s = t) (hs : s.Nonempty) (ht : t.Nonempty) :
    s.max' hs = t.max' ht := by subst h; rfl

/-! ## Completeness of the invariant -/

/-- **The Alexander polynomial is a complete invariant for torus knots.** If two torus knots
`T(a,b)`, `T(a',b')` with `1 < a < b`, `1 < a' < b'` (and coprime parameters) have the same
Alexander polynomial, they have the same parameters. -/
theorem torusAlexander_injective {a b a' b' : ℕ} (hab : Nat.Coprime a b)
    (hab' : Nat.Coprime a' b') (ha : 1 < a) (hlt : a < b) (ha' : 1 < a') (hlt' : a' < b')
    (h : torusAlexander a b = torusAlexander a' b') : a = a' ∧ b = b' := by
  have hspec := spectrum_eq_of_torusAlexander_eq h
  have hb : 1 < b := by omega
  have hb' : 1 < b' := by omega
  -- the products agree, since they are the maxima of the (equal) spectra
  have hprod : a * b = a' * b' := by
    have h1 := spectrum_max ha hb
    have h2 := spectrum_max ha' hb'
    rw [← h1, ← h2]
    exact max'_congr hspec _ _
  -- hence the complements agree
  have hco : coSpectrum a b = coSpectrum a' b' := by
    rw [coSpectrum, coSpectrum, hspec, hprod]
  have hbb : b = b' := by
    have h1 := coSpectrum_max ha hlt
    have h2 := coSpectrum_max ha' hlt'
    rw [← h1, ← h2]
    exact max'_congr hco _ _
  refine ⟨?_, hbb⟩
  have h1 := coSpectrum_max_of_not_dvd hab ha hlt
  have h2 := coSpectrum_max_of_not_dvd hab' ha' hlt'
  rw [← h1, ← h2]
  exact max'_congr (by rw [hco, hbb]) _ _

/-- **The recovery pipeline**, packaged: from the polynomial `Δ_{a,b}` one reads its
cyclotomic support `S`, whose maximum is the product `ab`; the maximum of the complementary
divisor set is `b`, and the maximum of the part of the complement not dividing `b` is `a`. -/
theorem torusAlexander_recovers_factorization {a b : ℕ} (hab : Nat.Coprime a b)
    (ha : 1 < a) (hlt : a < b) :
    (∀ d, 0 < d → (d ∈ spectrum a b ↔ cyclotomic d ℤ ∣ torusAlexander a b)) ∧
      (spectrum a b).max' ⟨a * b, mul_mem_spectrum ha (by omega)⟩ = a * b ∧
      (coSpectrum a b).max'
          ⟨b, mem_coSpectrum_of_dvd_right (by omega) (by omega) dvd_rfl⟩ = b ∧
      ((coSpectrum a b).filter (fun d => ¬ d ∣ b)).max'
          ⟨a, Finset.mem_filter.2
            ⟨mem_coSpectrum.2 ⟨(dvd_refl a).mul_right b, Nat.mul_ne_zero (by omega) (by omega),
                Or.inl dvd_rfl⟩,
              not_dvd_of_coprime_lt hab ha⟩⟩ = a :=
  ⟨fun d hd => (cyclotomic_dvd_torusAlexander_iff hd).symm, spectrum_max ha (by omega),
    coSpectrum_max ha hlt, coSpectrum_max_of_not_dvd hab ha hlt⟩

end Computation.AlexanderTorusKnot