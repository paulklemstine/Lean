/-
# Sparse polynomials in characteristic `p` cannot have a very degenerate root at `1`

This file proves the finite-field engine behind Chebotarev's theorem on roots of unity:

> If `f ∈ 𝔽_p[X]` is nonzero, has `natDegree < p`, and is divisible by `(X - 1) ^ n`,
> then `f` has **more than `n`** nonzero coefficients.

The proof is a descent on `n`.  After factoring out the largest power of `X` (which does not
change the number of terms, and is coprime to `(X - 1) ^ n`) the polynomial has a nonzero
constant term; its formal derivative then loses that term but keeps all the others — here the
hypothesis `natDegree f < p` is essential, since it guarantees that no exponent is divisible by
`p`, so no term is destroyed by differentiation — while the multiplicity of the root `1` drops
by at most one.

The main result is `ParityGap.lt_card_support_of_X_sub_one_pow_dvd`.
-/

import Mathlib

open Polynomial Finset

namespace ParityGap

variable {R : Type*} [CommRing R]

/-- Multiplying by a power of `X` does not change the number of nonzero coefficients. -/
theorem card_support_X_pow_mul (a : ℕ) (h : R[X]) :
    ((X : R[X]) ^ a * h).support.card = h.support.card := by
  classical
  have himg : ((X : R[X]) ^ a * h).support = h.support.image (· + a) := by
    ext k
    simp only [mem_support_iff, Finset.mem_image]
    constructor
    · intro hk
      by_cases hka : a ≤ k
      · refine ⟨k - a, ?_, by omega⟩
        have hc : ((X : R[X]) ^ a * h).coeff (k - a + a) = h.coeff (k - a) :=
          coeff_X_pow_mul h a (k - a)
        rw [Nat.sub_add_cancel hka] at hc
        rw [← hc]; exact hk
      · exfalso
        apply hk
        have hdvd : (X : R[X]) ^ a ∣ (X : R[X]) ^ a * h := Dvd.intro h rfl
        exact (X_pow_dvd_iff.mp hdvd) k (by omega)
    · rintro ⟨d, hd, rfl⟩
      rw [coeff_X_pow_mul h a d]
      exact hd
  rw [himg]
  exact Finset.card_image_of_injective _ (fun x y hxy => by omega)

/-- `X` and `X - 1` are coprime. -/
theorem isCoprime_X_X_sub_one : IsCoprime (X : R[X]) (X - 1) :=
  ⟨1, -1, by ring⟩

/-- **Sparse polynomials have small root multiplicity at `1` in characteristic `p`.**
A nonzero polynomial over `ZMod p` of degree `< p` divisible by `(X - 1) ^ n` has strictly
more than `n` nonzero coefficients. -/
theorem lt_card_support_of_X_sub_one_pow_dvd {p : ℕ} [Fact p.Prime] :
    ∀ (n : ℕ) (f : (ZMod p)[X]), f ≠ 0 → f.natDegree < p →
      ((X : (ZMod p)[X]) - 1) ^ n ∣ f → n < f.support.card := by
  intro n
  induction n with
  | zero =>
    intro f hf _ _
    simpa using (Polynomial.support_nonempty.mpr hf).card_pos
  | succ n ih =>
    intro f hf hdeg hdvd
    -- factor out the largest power of `X`
    set a := f.natTrailingDegree with ha
    have hXa : (X : (ZMod p)[X]) ^ a ∣ f :=
      X_pow_dvd_iff.mpr fun d hd => coeff_eq_zero_of_lt_natTrailingDegree hd
    obtain ⟨h, hfh⟩ := hXa
    have hh0 : h ≠ 0 := by
      rintro rfl; rw [mul_zero] at hfh; exact hf hfh
    have hcard : f.support.card = h.support.card := by
      rw [hfh, card_support_X_pow_mul]
    -- the constant coefficient of `h` is nonzero
    have hcoeff0 : h.coeff 0 ≠ 0 := by
      have hc := coeff_X_pow_mul h a 0
      simp only [Nat.zero_add] at hc
      rw [← hfh] at hc
      rw [← hc, ha]
      exact trailingCoeff_nonzero_iff_nonzero.mpr hf
    -- the divisibility passes to `h`
    have hdvdh : ((X : (ZMod p)[X]) - 1) ^ (n + 1) ∣ h := by
      have hcop : IsCoprime (((X : (ZMod p)[X]) - 1) ^ (n + 1)) ((X : (ZMod p)[X]) ^ a) :=
        isCoprime_X_X_sub_one.symm.pow
      refine hcop.dvd_of_dvd_mul_left ?_
      rw [← hfh]; exact hdvd
    have hdegh : h.natDegree < p := by
      have hle : h.natDegree ≤ f.natDegree := by
        rw [hfh, natDegree_mul (pow_ne_zero _ X_ne_zero) hh0]
        omega
      omega
    -- `h` is not constant
    have hdpos : 0 < h.natDegree := by
      rcases Nat.eq_zero_or_pos h.natDegree with hd0 | hd0
      · exfalso
        have hle := Polynomial.natDegree_le_of_dvd hdvdh hh0
        have hX1 : ((X : (ZMod p)[X]) - 1).natDegree = 1 := by
          simpa using natDegree_X_sub_C (1 : ZMod p)
        rw [natDegree_pow, hX1] at hle
        omega
      · exact hd0
    -- pass to the derivative
    set g := derivative h with hg
    have hgdvd : ((X : (ZMod p)[X]) - 1) ^ n ∣ g := by
      obtain ⟨q, hq⟩ := hdvdh
      refine ⟨((n + 1 : ℕ) : (ZMod p)[X]) * q + ((X : (ZMod p)[X]) - 1) * derivative q, ?_⟩
      rw [hg, hq, derivative_mul, derivative_pow]
      simp only [derivative_sub, derivative_X, derivative_one, sub_zero, mul_one,
        Nat.add_sub_cancel, Polynomial.C_eq_natCast]
      ring
    have hg0 : g ≠ 0 := by
      intro hgz
      have hcd : g.coeff (h.natDegree - 1) = h.coeff h.natDegree * (h.natDegree : ZMod p) := by
        rw [hg, coeff_derivative]
        obtain ⟨e, he⟩ : ∃ e, h.natDegree = e + 1 := ⟨h.natDegree - 1, by omega⟩
        rw [he]
        simp
      rw [hgz] at hcd
      simp only [coeff_zero] at hcd
      have hlead : h.coeff h.natDegree ≠ 0 :=
        Polynomial.leadingCoeff_ne_zero.mpr hh0
      have hnd : (h.natDegree : ZMod p) ≠ 0 := by
        intro hz
        have hdvdp := (ZMod.natCast_eq_zero_iff h.natDegree p).mp hz
        have := Nat.le_of_dvd hdpos hdvdp
        omega
      exact (mul_ne_zero hlead hnd) hcd.symm
    have hgdeg : g.natDegree < p := lt_trans (natDegree_derivative_lt (by omega)) hdegh
    -- the derivative has one term fewer
    have hgcard : g.support.card + 1 ≤ h.support.card := by
      have hsub : g.support ⊆ (h.support.erase 0).image (· - 1) := by
        intro k hk
        simp only [mem_support_iff, hg, coeff_derivative] at hk
        have hk1 : h.coeff (k + 1) ≠ 0 := fun hz => hk (by rw [hz]; ring)
        refine Finset.mem_image.mpr ⟨k + 1, ?_, by omega⟩
        exact Finset.mem_erase.mpr ⟨by omega, mem_support_iff.mpr hk1⟩
      have hcard1 : g.support.card ≤ (h.support.erase 0).card :=
        le_trans (Finset.card_le_card hsub) Finset.card_image_le
      have h0mem : (0 : ℕ) ∈ h.support := mem_support_iff.mpr hcoeff0
      have hce : (h.support.erase 0).card + 1 = h.support.card := by
        rw [Finset.card_erase_of_mem h0mem]
        have := Finset.card_pos.mpr ⟨0, h0mem⟩
        omega
      omega
    have := ih g hg0 hgdeg hgdvd
    omega

end ParityGap