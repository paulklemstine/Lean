/-
# Chebotarev's nonsingular-minor property and the additive uncertainty principle

Tao's additive uncertainty principle on `ZMod p` is *equivalent* to Chebotarev's theorem that
every square submatrix of the DFT matrix `(ω^{st})_{s,t}` is nonsingular.  This file makes the
equivalence formal and unconditional in the modulus:

* `PrimeUncertainty.SumUncertainty p` : `|supp f| + |supp f̂| ≥ p + 1` for all `f ≠ 0`.
* `PrimeUncertainty.ChebotarevProperty p` : all square minors of the DFT matrix of `ZMod p`
  are nonsingular.
* `PrimeUncertainty.chebotarev_iff_sumUncertainty` : **the two properties are equivalent**
  for every modulus `p ≥ 1`.  One direction turns a singular minor into an extremal function,
  the other turns an extremal function into a singular minor.
* `PrimeUncertainty.det_ne_zero_of_AP_rows` : the *unconditional* half of Chebotarev proved
  here — every minor whose row index set is an arithmetic progression is nonsingular
  (a generalised Vandermonde determinant).
* `PrimeUncertainty.not_chebotarevProperty_four` : Chebotarev's property genuinely fails for
  the composite modulus `4`, as it must by `sum_bound_fails_zmod_four`.
-/

import Mathlib
import Catalog.MachineLearning.PrimeUncertainty.Boundary

open Finset Polynomial FourierFA FourierCyclic
open scoped Real

namespace PrimeUncertainty

variable {p : ℕ}

/-- Tao's additive uncertainty principle, as a property of the modulus `p`. -/
def SumUncertainty (p : ℕ) [NeZero p] : Prop :=
  ∀ f : ZMod p → ℂ, f ≠ 0 → p + 1 ≤ (supp f).card + (supp (dftZMod f)).card

/-- Chebotarev's property: every square submatrix `(ω^{s t})_{s ∈ S, t ∈ T}` of the DFT matrix
of `ZMod p`, indexed by injective families `S` and `T`, is nonsingular. -/
def ChebotarevProperty (p : ℕ) [NeZero p] : Prop :=
  ∀ (n : ℕ) (S T : Fin n → ZMod p), Function.Injective S → Function.Injective T →
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det ≠ 0

section General

variable [NeZero p]

/-- The *local* form of the reduction: if all minors of the size `|supp f|` are nonsingular,
then `f` obeys the additive bound. -/
theorem sum_bound_of_chebotarev_at (f : ZMod p → ℂ) (hf : f ≠ 0)
    (H : ∀ S T : Fin (supp f).card → ZMod p, Function.Injective S → Function.Injective T →
      (Matrix.of fun j k : Fin (supp f).card => ez (S j * T k)).det ≠ 0) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  classical
  by_contra hcon
  push_neg at hcon
  set A : Finset (ZMod p) := supp f with hA
  set Zs : Finset (ZMod p) := Finset.univ.filter (fun k : ZMod p => dftZMod f k = 0) with hZs
  have hpart : Zs.card + (supp (dftZMod f)).card = p := card_zeroSet_add_card_supp f
  have hAne : A.Nonempty := by
    rcases Function.ne_iff.1 hf with ⟨x, hx⟩
    exact ⟨x, mem_supp.2 (by simpa using hx)⟩
  have hnle : A.card ≤ Zs.card := by omega
  obtain ⟨T', hT'sub, hT'card⟩ := Finset.exists_subset_card_eq hnle
  -- enumerate the support and the chosen part of the zero set
  set TA : Fin A.card → ZMod p := fun k => (A.equivFin.symm k : ZMod p) with hTA
  set TZ : Fin A.card → ZMod p :=
    fun j => (T'.equivFin.symm (Fin.cast hT'card.symm j) : ZMod p) with hTZ
  have hTAmem : ∀ k, TA k ∈ A := fun k => (A.equivFin.symm k).2
  have hTZmem : ∀ j, TZ j ∈ T' := fun j => (T'.equivFin.symm _).2
  have hTAinj : Function.Injective TA := by
    intro a b hab
    have : A.equivFin.symm a = A.equivFin.symm b := Subtype.ext hab
    simpa using congrArg A.equivFin this
  have hTZinj : Function.Injective TZ := by
    intro a b hab
    have h1 : T'.equivFin.symm (Fin.cast hT'card.symm a)
        = T'.equivFin.symm (Fin.cast hT'card.symm b) := Subtype.ext hab
    have h2 := congrArg T'.equivFin h1
    simp only [Equiv.apply_symm_apply] at h2
    exact Fin.cast_injective _ h2
  have hSinj : Function.Injective (fun j => -(TZ j)) := fun a b hab => hTZinj (neg_injective hab)
  -- the kernel vector
  set v : Fin A.card → ℂ := fun k => f (TA k) with hv
  have hvne : v ≠ 0 := by
    have hk : Nonempty (Fin A.card) := ⟨⟨0, Finset.card_pos.2 hAne⟩⟩
    obtain ⟨k⟩ := hk
    intro h0
    have : v k = 0 := by rw [h0]; rfl
    exact (mem_supp.1 (hTAmem k)) this
  set M : Matrix (Fin A.card) (Fin A.card) ℂ :=
    Matrix.of fun j k => ez ((fun j => -(TZ j)) j * TA k) with hM
  have hMv : M.mulVec v = 0 := by
    funext j
    have hsum : ∑ k : Fin A.card, ez (-(TZ j) * TA k) * f (TA k)
        = ∑ x ∈ A, ez (-(TZ j * x)) * f x := by
      have h1 : ∑ k : Fin A.card, ez (-(TZ j) * TA k) * f (TA k)
          = ∑ x : A, ez (-(TZ j) * (x : ZMod p)) * f (x : ZMod p) :=
        Fintype.sum_equiv A.equivFin.symm _ _ (fun k => rfl)
      rw [h1, Finset.sum_coe_sort A (fun x => ez (-(TZ j) * x) * f x)]
      exact Finset.sum_congr rfl fun x _ => by rw [neg_mul]
    have hfull : ∑ x ∈ A, ez (-(TZ j * x)) * f x = dftZMod f (TZ j) := by
      rw [dftZMod_eq_sum_ez]
      refine Finset.sum_subset (Finset.subset_univ _) ?_
      intro x _ hx
      have hfx : f x = 0 := by
        by_contra hne
        exact hx (mem_supp.2 hne)
      simp [hfx]
    have hz : dftZMod f (TZ j) = 0 := by
      have := hT'sub (hTZmem j)
      simpa [hZs] using (Finset.mem_filter.1 this).2
    show (∑ k : Fin A.card, ez (-(TZ j) * TA k) * f (TA k)) = 0
    rw [hsum, hfull, hz]
  have hdet : M.det = 0 := Matrix.exists_mulVec_eq_zero_iff.1 ⟨v, hvne, hMv⟩
  exact H (fun j => -(TZ j)) TA hSinj hTAinj hdet

/-- Turning a Chebotarev-type nonsingularity statement into an uncertainty statement:
if all minors of the DFT matrix are nonsingular then the additive bound holds. -/
theorem sumUncertainty_of_chebotarev (H : ChebotarevProperty p) : SumUncertainty p :=
  fun f hf => sum_bound_of_chebotarev_at f hf (fun S T hS hT => H _ S T hS hT)

/-- Conversely, the additive uncertainty principle forces all minors of the DFT matrix to be
nonsingular: a singular minor is exactly an extremal pair of supports. -/
theorem chebotarev_of_sumUncertainty (H : SumUncertainty p) : ChebotarevProperty p := by
  classical
  intro n S T hS hT hdet
  obtain ⟨v, hv0, hMv⟩ := Matrix.exists_mulVec_eq_zero_iff.2 hdet
  -- the function supported on the range of `T` with coefficients `v`
  set f : ZMod p → ℂ := fun x => ∑ k : Fin n, if T k = x then v k else 0 with hf
  have hfT : ∀ k₀ : Fin n, f (T k₀) = v k₀ := by
    intro k₀
    rw [hf]
    simp only
    rw [Finset.sum_eq_single_of_mem k₀ (Finset.mem_univ k₀)]
    · simp
    · intro k _ hk
      exact if_neg fun h => hk (hT h)
  have hsupp : supp f ⊆ Finset.image T Finset.univ := by
    intro x hx
    by_contra hxr
    have hzero : f x = 0 := by
      rw [hf]
      refine Finset.sum_eq_zero fun k _ => ?_
      exact if_neg fun h => hxr (Finset.mem_image.2 ⟨k, Finset.mem_univ k, h⟩)
    exact (mem_supp.1 hx) hzero
  obtain ⟨k₁, hk₁⟩ := Function.ne_iff.1 hv0
  have hfne : f ≠ 0 := by
    intro h0
    have : f (T k₁) = 0 := by rw [h0]; rfl
    rw [hfT k₁] at this
    exact hk₁ (by simpa using this)
  -- the transform vanishes on the `n` points `-(S j)`
  have hzero : ∀ j : Fin n, dftZMod f (-(S j)) = 0 := by
    intro j
    rw [dftZMod_eq_sum_ez]
    have hrestrict : ∑ x : ZMod p, ez (-(-(S j) * x)) * f x
        = ∑ x ∈ Finset.image T Finset.univ, ez (-(-(S j) * x)) * f x := by
      refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
      intro x _ hx
      have hfx : f x = 0 := by
        by_contra hne
        exact hx (hsupp (mem_supp.2 hne))
      simp [hfx]
    rw [hrestrict, Finset.sum_image (fun a _ b _ hab => hT hab)]
    have hval : ∀ k : Fin n, ez (-(-(S j) * T k)) * f (T k) = ez (S j * T k) * v k := by
      intro k
      rw [hfT k]
      congr 2
      ring
    simp_rw [hval]
    have := congrFun hMv j
    simpa [Matrix.mulVec, dotProduct] using this
  -- counting: the support is small and the zero set is large
  set Zs : Finset (ZMod p) := Finset.univ.filter (fun k : ZMod p => dftZMod f k = 0) with hZs
  have hpart : Zs.card + (supp (dftZMod f)).card = p := card_zeroSet_add_card_supp f
  have hZcard : n ≤ Zs.card := by
    have hsub : Finset.image (fun j => -(S j)) Finset.univ ⊆ Zs := by
      intro x hx
      obtain ⟨j, _, rfl⟩ := Finset.mem_image.1 hx
      exact Finset.mem_filter.2 ⟨Finset.mem_univ _, hzero j⟩
    have hcard : (Finset.image (fun j => -(S j)) Finset.univ).card = n := by
      rw [Finset.card_image_of_injective _ (fun a b hab => hS (neg_injective hab))]
      simp
    calc n = (Finset.image (fun j => -(S j)) Finset.univ).card := hcard.symm
      _ ≤ Zs.card := Finset.card_le_card hsub
  have hAcard : (supp f).card ≤ n := by
    calc (supp f).card ≤ (Finset.image T Finset.univ).card := Finset.card_le_card hsupp
      _ ≤ (Finset.univ : Finset (Fin n)).card := Finset.card_image_le
      _ = n := by simp
  have := H f hfne
  omega

/-- **The additive uncertainty principle is exactly Chebotarev's theorem.** -/
theorem chebotarev_iff_sumUncertainty : ChebotarevProperty p ↔ SumUncertainty p :=
  ⟨sumUncertainty_of_chebotarev, chebotarev_of_sumUncertainty⟩

/-- Chebotarev's property fails for the composite modulus `4`. -/
theorem not_chebotarevProperty_four : ¬ ChebotarevProperty 4 := by
  intro H
  obtain ⟨f, hf, _, hlt⟩ := sum_bound_fails_zmod_four
  have := sumUncertainty_of_chebotarev H f hf
  omega

end General

/-! ## The unconditional half of Chebotarev: arithmetic progression minors -/

section Prime

variable [hp : Fact p.Prime]

/-- **Generalised Vandermonde minors.**  Any minor of the DFT matrix whose *rows* are indexed by
an arithmetic progression `a, a + d, …` with `d ≠ 0` is nonsingular, for arbitrary distinct
columns `T`.  This is the case of Chebotarev's theorem that the polynomial method settles
unconditionally. -/
theorem det_ne_zero_of_AP_rows {n : ℕ} (a d : ZMod p) (hd : d ≠ 0) (T : Fin n → ZMod p)
    (hT : Function.Injective T) :
    (Matrix.of fun j k : Fin n => ez ((a + ((j : ℕ) : ZMod p) * d) * T k)).det ≠ 0 := by
  classical
  set z : Fin n → ℂ := fun k => ez (d * T k) with hz
  set c : Fin n → ℂ := fun k => ez (a * T k) with hc
  have hzinj : Function.Injective z := by
    intro x y hxy
    exact hT (mul_left_cancel₀ hd (ez_injective hxy))
  have hfactor : (Matrix.of (fun j k : Fin n => ez ((a + ((j : ℕ) : ZMod p) * d) * T k)))
      = (Matrix.vandermonde z).transpose * Matrix.diagonal c := by
    ext j k
    rw [Matrix.mul_diagonal]
    simp only [Matrix.of_apply, Matrix.transpose_apply, Matrix.vandermonde_apply, hz, hc]
    have hsplit : (a + ((j : ℕ) : ZMod p) * d) * T k
        = a * T k + ((j : ℕ) : ZMod p) * (d * T k) := by ring
    rw [hsplit, ez_add, ez_natCast_mul]
    ring
  rw [hfactor, Matrix.det_mul, Matrix.det_transpose, Matrix.det_diagonal]
  refine mul_ne_zero (Matrix.det_vandermonde_ne_zero_iff.2 hzinj) ?_
  exact Finset.prod_ne_zero_iff.2 fun k _ => ez_ne_zero _

/-- The transposed statement: minors whose *columns* are indexed by an arithmetic progression
are nonsingular as well. -/
theorem det_ne_zero_of_AP_cols {n : ℕ} (a d : ZMod p) (hd : d ≠ 0) (S : Fin n → ZMod p)
    (hS : Function.Injective S) :
    (Matrix.of (fun j k : Fin n => ez (S j * (a + ((k : ℕ) : ZMod p) * d)))).det ≠ 0 := by
  have hEq : (Matrix.of (fun j k : Fin n => ez (S j * (a + ((k : ℕ) : ZMod p) * d)))).transpose
      = Matrix.of (fun j k : Fin n => ez ((a + ((j : ℕ) : ZMod p) * d) * S k)) := by
    ext j k
    simp only [Matrix.transpose_apply, Matrix.of_apply]
    congr 1
    ring
  rw [← Matrix.det_transpose, hEq]
  exact det_ne_zero_of_AP_rows a d hd S hS

end Prime

end PrimeUncertainty