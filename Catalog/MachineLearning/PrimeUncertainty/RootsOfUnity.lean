/-
# Roots of unity toolkit for the prime-order uncertainty principle

This file provides the infrastructure needed to attack Tao's *additive* uncertainty
principle `|supp f| + |supp f̂| ≥ p + 1` on `ZMod p` (`p` prime), which refines the
multiplicative Donoho–Stark bound `|supp f| · |supp f̂| ≥ p` proved in
`Catalog.Shared.FourierCyclic` (`FourierCyclic.uncertainty_zmod`).

Main contents:

* `PrimeUncertainty.om` : the standard primitive `p`-th root of unity `e^{2πi/p}`.
* `PrimeUncertainty.ez` : the canonical character `a ↦ ω^{a}` of `ZMod p`, with additivity,
  the power rule and injectivity (for `p` prime).
* `PrimeUncertainty.dftZMod_eq_sum_ez` : the classical DFT rewritten with `ez`.
* `PrimeUncertainty.dftZMod_dftZMod` : the Fourier duality `f̂̂ (k) = p · f (-k)`.
* `PrimeUncertainty.eq_zero_of_sum_pow_eq_zero` : *the polynomial-method core*: an exponential
  sum `∑_{i ∈ A} c i · z i ^ j` with pairwise distinct bases `z i` that vanishes for the
  `|A|` exponents `j = 0, …, |A| - 1` must have all coefficients zero (Lagrange interpolation
  form of Vandermonde nonsingularity).
-/

import Mathlib
import Catalog.Shared.FourierCyclic

open Finset Polynomial FourierFA FourierCyclic
open scoped Real

namespace PrimeUncertainty

/-! ## The polynomial-method core -/

/-- **Vandermonde nonvanishing, Lagrange form.**  If the bases `z i` (`i ∈ A`) are pairwise
distinct and the generalised exponential sum `∑_{i ∈ A} c i * z i ^ j` vanishes for all
`j < |A|`, then every coefficient `c i` vanishes.

This is the linear-algebraic heart of every uncertainty statement below: `|A|` distinct
geometric sequences are already linearly independent on a window of length `|A|`. -/
theorem eq_zero_of_sum_pow_eq_zero {ι : Type*} [DecidableEq ι] (A : Finset ι) (z c : ι → ℂ)
    (hz : Set.InjOn z A) (h : ∀ j < A.card, ∑ i ∈ A, c i * z i ^ j = 0) :
    ∀ i ∈ A, c i = 0 := by
  intro i₀ hi₀
  -- The Lagrange-type polynomial vanishing at every node except `z i₀`.
  set L : ℂ[X] := ∏ i ∈ A.erase i₀, (X - C (z i)) with hL
  have hmonic : ∀ i ∈ A.erase i₀, (X - C (z i)).Monic := fun i _ => monic_X_sub_C _
  have hdeg : L.natDegree = A.card - 1 := by
    rw [hL, natDegree_prod_of_monic _ _ hmonic]
    simp [Finset.card_erase_of_mem hi₀]
  have hcardpos : 0 < A.card := Finset.card_pos.2 ⟨i₀, hi₀⟩
  have hlt : L.natDegree < A.card := by omega
  -- Expanding `L` in the monomial basis and using the hypothesis kills the whole sum.
  have key : ∑ i ∈ A, c i * L.eval (z i) = 0 := by
    have hev : ∀ i, L.eval (z i) = ∑ j ∈ range A.card, L.coeff j * z i ^ j := fun i =>
      eval_eq_sum_range' hlt _
    simp_rw [hev, Finset.mul_sum]
    rw [Finset.sum_comm]
    refine Finset.sum_eq_zero fun j hj => ?_
    have hj' := h j (Finset.mem_range.1 hj)
    calc ∑ i ∈ A, c i * (L.coeff j * z i ^ j)
        = L.coeff j * ∑ i ∈ A, c i * z i ^ j := by
          rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun i _ => by ring
      _ = 0 := by rw [hj', mul_zero]
  -- Only the `i₀` term survives.
  have hsingle : ∑ i ∈ A, c i * L.eval (z i) = c i₀ * L.eval (z i₀) := by
    refine Finset.sum_eq_single_of_mem i₀ hi₀ fun i hi hne => ?_
    have hzero : L.eval (z i) = 0 := by
      rw [hL, eval_prod]
      refine Finset.prod_eq_zero (Finset.mem_erase.2 ⟨hne, hi⟩) ?_
      simp
    rw [hzero, mul_zero]
  have hne : L.eval (z i₀) ≠ 0 := by
    rw [hL, eval_prod]
    refine Finset.prod_ne_zero_iff.2 fun i hi => ?_
    have hiA : i ∈ A := Finset.mem_of_mem_erase hi
    have hii : i ≠ i₀ := (Finset.mem_erase.1 hi).1
    simp only [eval_sub, eval_X, eval_C, sub_ne_zero]
    exact fun heq => hii (hz hiA hi₀ heq.symm)
  rw [hsingle] at key
  exact (mul_eq_zero.1 key).resolve_right hne

/-! ## The canonical root of unity -/

variable {p : ℕ}

/-- The standard primitive `p`-th root of unity `e^{2πi/p}`. -/
noncomputable def om (p : ℕ) : ℂ := Complex.exp (2 * Real.pi * Complex.I / p)

/-- The canonical character `a ↦ ω^{a}` of `ZMod p`. -/
noncomputable def ez (a : ZMod p) : ℂ := om p ^ a.val

theorem om_isPrimitiveRoot [NeZero p] : IsPrimitiveRoot (om p) p :=
  Complex.isPrimitiveRoot_exp p (NeZero.ne p)

theorem om_pow_p [NeZero p] : om p ^ p = 1 := om_isPrimitiveRoot.pow_eq_one

theorem om_ne_zero [NeZero p] : om p ≠ 0 := by
  intro h
  have hp := om_pow_p (p := p)
  rw [h, zero_pow (NeZero.ne p)] at hp
  exact zero_ne_one hp

/-- `ω^m` only depends on `m` modulo `p`. -/
theorem om_pow_congr [NeZero p] {m n : ℕ} (h : m % p = n % p) : om p ^ m = om p ^ n := by
  conv_lhs => rw [← Nat.div_add_mod m p]
  conv_rhs => rw [← Nat.div_add_mod n p]
  simp [pow_add, pow_mul, om_pow_p, h]

/-- `ω^m = e^{2πi m/p}`. -/
theorem om_pow_eq_exp [NeZero p] (m : ℕ) :
    om p ^ m = Complex.exp (2 * Real.pi * Complex.I * m / p) := by
  rw [om, ← Complex.exp_nat_mul]
  congr 1
  field_simp

theorem ez_ne_zero [NeZero p] (a : ZMod p) : ez a ≠ 0 := pow_ne_zero _ om_ne_zero

@[simp] theorem ez_zero [NeZero p] : ez (0 : ZMod p) = 1 := by simp [ez]

/-- `ez` is a character: it turns addition in `ZMod p` into multiplication. -/
theorem ez_add [NeZero p] (a b : ZMod p) : ez (a + b) = ez a * ez b := by
  rw [ez, ez, ez, ← pow_add]
  refine om_pow_congr ?_
  rw [ZMod.val_add, Nat.mod_mod_of_dvd _ dvd_rfl]

theorem ez_neg [NeZero p] (a : ZMod p) : ez (-a) = (ez a)⁻¹ := by
  have h : ez a * ez (-a) = 1 := by rw [← ez_add]; simp
  exact (inv_eq_of_mul_eq_one_right h).symm

/-- Powers of the character: `ez (n * a) = (ez a)^n`. -/
theorem ez_natCast_mul [NeZero p] (a : ZMod p) (n : ℕ) : ez ((n : ZMod p) * a) = ez a ^ n := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep : ((k + 1 : ℕ) : ZMod p) * a = (k : ZMod p) * a + a := by push_cast; ring
      rw [hstep, ez_add, ih, pow_succ]

/-- The value of `ez` on a product, as a power of `ω`. -/
theorem ez_mul_eq_om_pow [NeZero p] (k x : ZMod p) : ez (k * x) = om p ^ (k.val * x.val) := by
  rw [ez]
  refine om_pow_congr ?_
  rw [ZMod.val_mul, Nat.mod_mod_of_dvd _ dvd_rfl]

/-- The canonical character is injective, i.e. `ω` is a primitive `p`-th root of unity. -/
theorem ez_injective [NeZero p] : Function.Injective (ez : ZMod p → ℂ) := by
  intro a b hab
  have ha : a.val < p := ZMod.val_lt a
  have hb : b.val < p := ZMod.val_lt b
  have hval := (om_isPrimitiveRoot (p := p)).pow_inj ha hb hab
  have := congrArg (fun n : ℕ => (n : ZMod p)) hval
  simpa [ZMod.natCast_val, ZMod.cast_id] using this

/-! ## The DFT in terms of `ez` -/

/-- The classical DFT of `Catalog.Shared.FourierCyclic`, rewritten via the character `ez`. -/
theorem dftZMod_eq_sum_ez [NeZero p] (f : ZMod p → ℂ) (k : ZMod p) :
    dftZMod f k = ∑ x : ZMod p, ez (-(k * x)) * f x := by
  rw [dftZMod]
  refine Finset.sum_congr rfl fun x _ => ?_
  congr 1
  rw [ez_neg, ez_mul_eq_om_pow, om_pow_eq_exp, ← Complex.exp_neg]
  congr 1
  push_cast
  ring

/-- **Fourier duality**: applying the classical DFT twice reflects and multiplies by `p`. -/
theorem dftZMod_dftZMod [NeZero p] (f : ZMod p → ℂ) (k : ZMod p) :
    dftZMod (dftZMod f) k = (p : ℂ) * f (-k) := by
  have hp : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne p)
  have hinv := dftZMod_inversion f (-k)
  have hstep : ∀ j : ZMod p,
      Complex.exp (2 * Real.pi * Complex.I * (j.val * (-k).val) / p) * dftZMod f j
        = ez (-(k * j)) * dftZMod f j := by
    intro j
    congr 1
    have h1 : ez (j * (-k)) = om p ^ (j.val * (-k).val) := ez_mul_eq_om_pow j (-k)
    have h2 : ez (-(k * j)) = ez (j * (-k)) := by ring_nf
    rw [h2, h1, om_pow_eq_exp]
    push_cast
    ring_nf
  rw [dftZMod_eq_sum_ez]
  calc ∑ j : ZMod p, ez (-(k * j)) * dftZMod f j
      = (p : ℂ) * ((p : ℂ)⁻¹ * ∑ j : ZMod p,
          Complex.exp (2 * Real.pi * Complex.I * (j.val * (-k).val) / p) * dftZMod f j) := by
        rw [← mul_assoc, mul_inv_cancel₀ hp, one_mul]
        exact (Finset.sum_congr rfl fun j _ => (hstep j).symm)
    _ = (p : ℂ) * f (-k) := by rw [← hinv]

end PrimeUncertainty