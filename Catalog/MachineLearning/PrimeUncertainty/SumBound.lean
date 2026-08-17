/-
# Towards Tao's additive uncertainty principle on `ZMod p`

The Donoho–Stark bound `|supp f| · |supp f̂| ≥ p` (`FourierCyclic.uncertainty_zmod`) holds for
every finite abelian group.  For groups of **prime** order Tao proved the strictly stronger
*additive* bound `|supp f| + |supp f̂| ≥ p + 1`.  This file proves the additive bound in two
large regimes, by the polynomial method, using only tools from
`Catalog.MachineLearning.PrimeUncertainty.RootsOfUnity`:

* `PrimeUncertainty.exists_dft_ne_zero_on_AP` : for `f ≠ 0` the Fourier transform `f̂` cannot
  vanish on an arithmetic progression of length `|supp f|`.  (This is the "arithmetic
  progression case" of Chebotarev's theorem on the nonsingularity of the minors of the DFT
  matrix, in analytic form.)
* `PrimeUncertainty.sum_bound_of_card_supp_le_two` : the additive uncertainty principle holds
  whenever `|supp f| ≤ 2`.
* `PrimeUncertainty.card_supp_dft_ge_of_supp_subset_AP` : if `supp f` is contained in an
  arithmetic progression of length `m` then `|supp f̂| ≥ p + 1 - m`; hence
  `PrimeUncertainty.sum_bound_of_supp_eq_AP`, the additive uncertainty principle for all
  functions supported on an arithmetic progression.
* `PrimeUncertainty.sum_bound_of_supp_dft_eq_AP` : the dual statement, for functions whose
  *spectrum* is an arithmetic progression.

Everything is stated for the classical DFT `FourierCyclic.dftZMod` of the shared catalog.
-/

import Mathlib
import Catalog.MachineLearning.PrimeUncertainty.RootsOfUnity

open Finset Polynomial FourierFA FourierCyclic
open scoped Real

namespace PrimeUncertainty

variable {p : ℕ}

section General

variable [NeZero p]

theorem card_univ_zmod : (Finset.univ : Finset (ZMod p)).card = p := by
  rw [Finset.card_univ]
  exact ZMod.card p

/-- The zero set of `f̂` and its support partition `ZMod p`. -/
theorem card_zeroSet_add_card_supp (f : ZMod p → ℂ) :
    (Finset.univ.filter (fun k : ZMod p => dftZMod f k = 0)).card
      + (supp (dftZMod f)).card = p := by
  classical
  have h : supp (dftZMod f) = Finset.univ.filter (fun k : ZMod p => ¬ dftZMod f k = 0) := by
    ext k; simp [supp]
  rw [h]
  rw [Finset.card_filter_add_card_filter_not (p := fun k : ZMod p => dftZMod f k = 0)]
  exact card_univ_zmod

end General

section Prime

variable [hp : Fact p.Prime]

instance : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩

/-! ## The Fourier transform cannot vanish on a short arithmetic progression -/

/-- **Chebotarev in the arithmetic-progression case (analytic form).**
For `f ≠ 0` on `ZMod p` with `p` prime, the DFT `f̂` cannot vanish at all the points
`a, a + d, …, a + (n-1)d` of an arithmetic progression of length `n = |supp f|` and nonzero
common difference `d`.

The proof is the polynomial method: writing `f̂(a + jd) = ∑_{x ∈ supp f} c_x z_x^j` with
`z_x = ω^{-dx}` pairwise distinct, vanishing on a window of length `|supp f|` forces all
coefficients `c_x = ω^{-ax} f(x)` to vanish (`eq_zero_of_sum_pow_eq_zero`). -/
theorem exists_dft_ne_zero_on_AP (f : ZMod p → ℂ) (hf : f ≠ 0) (a d : ZMod p) (hd : d ≠ 0) :
    ∃ j < (supp f).card, dftZMod f (a + (j : ZMod p) * d) ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  -- Set up the exponential-sum data.
  set A : Finset (ZMod p) := supp f with hA
  have hAne : A.Nonempty := by
    rcases Function.ne_iff.1 hf with ⟨x, hx⟩
    exact ⟨x, mem_supp.2 (by simpa using hx)⟩
  set z : ZMod p → ℂ := fun x => ez (-(d * x)) with hzdef
  set c : ZMod p → ℂ := fun x => ez (-(a * x)) * f x with hcdef
  have hz : Set.InjOn z A := by
    intro x _ y _ hxy
    have h1 : -(d * x) = -(d * y) := ez_injective hxy
    have h2 : d * x = d * y := neg_injective h1
    exact mul_left_cancel₀ hd h2
  have hsum : ∀ j < A.card, ∑ x ∈ A, c x * z x ^ j = 0 := by
    intro j hj
    have hterm : ∀ x : ZMod p, ez (-((a + (j : ZMod p) * d) * x)) * f x
        = if x ∈ A then c x * z x ^ j else 0 := by
      intro x
      by_cases hx : x ∈ A
      · simp only [hx, if_true, hcdef, hzdef]
        have hsplit : -((a + (j : ZMod p) * d) * x) = -(a * x) + (j : ZMod p) * (-(d * x)) := by
          ring
        rw [hsplit, ez_add, ez_natCast_mul]
        ring
      · have hfx : f x = 0 := by
          by_contra hne
          exact hx (mem_supp.2 hne)
        simp [hx, hfx]
    have := hcon j hj
    rw [dftZMod_eq_sum_ez] at this
    simp_rw [hterm] at this
    rwa [Finset.sum_ite_mem, Finset.univ_inter] at this
  have hzero := eq_zero_of_sum_pow_eq_zero A z c hz hsum
  obtain ⟨x₀, hx₀⟩ := hAne
  have := hzero x₀ hx₀
  exact (mul_ne_zero (ez_ne_zero _) (mem_supp.1 hx₀)) this

/-- Reformulation: no arithmetic progression of length `|supp f|` can lie in the zero set of
`f̂`. -/
theorem not_forall_dft_eq_zero_on_AP (f : ZMod p → ℂ) (hf : f ≠ 0) (a d : ZMod p) (hd : d ≠ 0)
    (hzero : ∀ j < (supp f).card, dftZMod f (a + (j : ZMod p) * d) = 0) : False := by
  obtain ⟨j, hj, hne⟩ := exists_dft_ne_zero_on_AP f hf a d hd
  exact hne (hzero j hj)

/-! ## The additive uncertainty principle for small supports -/

/-- **Additive uncertainty principle for supports of size at most two.**
If `f ≠ 0` on `ZMod p` (`p` prime) has at most two nonzero values, then
`|supp f| + |supp f̂| ≥ p + 1`. -/
theorem sum_bound_of_card_supp_le_two (f : ZMod p → ℂ) (hf : f ≠ 0)
    (hcard : (supp f).card ≤ 2) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  classical
  by_contra hcon
  push_neg at hcon
  set Z : Finset (ZMod p) := Finset.univ.filter (fun k : ZMod p => dftZMod f k = 0) with hZ
  have hpart := card_zeroSet_add_card_supp f
  rw [← hZ] at hpart
  have hAne : (supp f).Nonempty := by
    rcases Function.ne_iff.1 hf with ⟨x, hx⟩
    exact ⟨x, mem_supp.2 (by simpa using hx)⟩
  have hApos : 1 ≤ (supp f).card := Finset.card_pos.2 hAne
  have hZcard : (supp f).card ≤ Z.card := by omega
  have hmemZ : ∀ k ∈ Z, dftZMod f k = 0 := by
    intro k hk
    simpa [hZ] using (Finset.mem_filter.1 hk).2
  interval_cases h : (supp f).card
  · -- `|supp f| = 1`
    obtain ⟨a, ha⟩ : Z.Nonempty := Finset.card_pos.1 (by omega)
    refine not_forall_dft_eq_zero_on_AP f hf a 1 one_ne_zero ?_
    intro j hj
    rw [h] at hj
    interval_cases j
    simpa using hmemZ a ha
  · -- `|supp f| = 2`
    obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.1 (by omega : 1 < Z.card)
    refine not_forall_dft_eq_zero_on_AP f hf a (b - a) (sub_ne_zero.2 (Ne.symm hab)) ?_
    intro j hj
    rw [h] at hj
    interval_cases j
    · simpa using hmemZ a ha
    · have : a + ((1 : ℕ) : ZMod p) * (b - a) = b := by push_cast; ring
      rw [this]
      exact hmemZ b hb

/-! ## The additive uncertainty principle for supports inside an arithmetic progression -/

/-- If `supp f` is contained in an arithmetic progression of length `m ≤ p` with nonzero common
difference, then the spectrum is large: `|supp f̂| ≥ p + 1 - m`.

Proof: on such a support, `f̂(k) = ω^{-ka} · P(ω^{-kd})` for a nonzero polynomial `P` of degree
`< m`, and `k ↦ ω^{-kd}` is injective, so `f̂` has at most `m - 1` zeros. -/
theorem card_supp_dft_ge_of_supp_subset_AP (f : ZMod p → ℂ) (hf : f ≠ 0) (a d : ZMod p)
    (hd : d ≠ 0) (m : ℕ) (hm : m ≤ p)
    (hsub : supp f ⊆ (range m).image (fun j : ℕ => a + (j : ZMod p) * d)) :
    p + 1 ≤ m + (supp (dftZMod f)).card := by
  classical
  -- the progression is injectively parametrised
  have hinj : Set.InjOn (fun j : ℕ => a + (j : ZMod p) * d) (range m) := by
    intro i hi j hj hij
    simp only [Finset.coe_range, Set.mem_Iio] at hi hj
    have h1 : (i : ZMod p) * d = (j : ZMod p) * d := by
      have := hij
      simpa using add_left_cancel this
    have h2 : (i : ZMod p) = (j : ZMod p) := mul_right_cancel₀ hd h1
    have hi' : i < p := lt_of_lt_of_le hi hm
    have hj' : j < p := lt_of_lt_of_le hj hm
    have := congrArg ZMod.val h2
    rwa [ZMod.val_natCast_of_lt hi', ZMod.val_natCast_of_lt hj'] at this
  have hAne : (supp f).Nonempty := by
    rcases Function.ne_iff.1 hf with ⟨x, hx⟩
    exact ⟨x, mem_supp.2 (by simpa using hx)⟩
  have hmpos : 0 < m := by
    rcases hAne with ⟨x, hx⟩
    have := hsub hx
    rcases Finset.mem_image.1 this with ⟨j, hj, _⟩
    have : j < m := Finset.mem_range.1 hj
    omega
  -- the generating polynomial
  set P : ℂ[X] := ∑ j ∈ range m, C (f (a + (j : ZMod p) * d)) * X ^ j with hP
  have hcoeff : ∀ j < m, P.coeff j = f (a + (j : ZMod p) * d) := by
    intro j hj
    rw [hP, finset_sum_coeff]
    rw [Finset.sum_eq_single_of_mem j (Finset.mem_range.2 hj)]
    · simp
    · intro i _ hij
      simp [coeff_C_mul, coeff_X_pow, Ne.symm hij]
  have hPne : P ≠ 0 := by
    rcases hAne with ⟨x, hx⟩
    obtain ⟨j, hj, hjx⟩ := Finset.mem_image.1 (hsub hx)
    have hjm : j < m := Finset.mem_range.1 hj
    intro hP0
    have : P.coeff j = 0 := by rw [hP0]; simp
    rw [hcoeff j hjm, hjx] at this
    exact (mem_supp.1 hx) this
  have hPdeg : P.natDegree ≤ m - 1 := by
    rw [hP]
    refine natDegree_sum_le_of_forall_le _ _ fun j hj => ?_
    have hjm : j < m := Finset.mem_range.1 hj
    calc (C (f (a + (j : ZMod p) * d)) * X ^ j).natDegree
        ≤ (X ^ j : ℂ[X]).natDegree := natDegree_C_mul_le _ _
      _ = j := natDegree_X_pow j
      _ ≤ m - 1 := by omega
  -- the DFT is the polynomial evaluated at a root of unity
  have heval : ∀ k : ZMod p, dftZMod f k = ez (-(k * a)) * P.eval (ez (-(k * d))) := by
    intro k
    rw [dftZMod_eq_sum_ez]
    have hstep : ∑ x : ZMod p, ez (-(k * x)) * f x
        = ∑ x ∈ (range m).image (fun j : ℕ => a + (j : ZMod p) * d), ez (-(k * x)) * f x := by
      refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
      intro x _ hx
      have hfx : f x = 0 := by
        by_contra hne
        exact hx (hsub (mem_supp.2 hne))
      simp [hfx]
    rw [hstep, Finset.sum_image hinj]
    rw [hP, eval_finset_sum, Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    have hsplit : -(k * (a + (j : ZMod p) * d)) = -(k * a) + (j : ZMod p) * (-(k * d)) := by ring
    rw [hsplit, ez_add, ez_natCast_mul]
    simp [eval_mul, eval_pow]
    ring
  -- the zero set injects into the roots of `P`
  set Z : Finset (ZMod p) := Finset.univ.filter (fun k : ZMod p => dftZMod f k = 0) with hZ
  have hZroots : ∀ k ∈ Z, ez (-(k * d)) ∈ P.roots.toFinset := by
    intro k hk
    have hk0 : dftZMod f k = 0 := by simpa [hZ] using (Finset.mem_filter.1 hk).2
    have : ez (-(k * a)) * P.eval (ez (-(k * d))) = 0 := by rw [← heval k]; exact hk0
    have hev : P.eval (ez (-(k * d))) = 0 := by
      rcases mul_eq_zero.1 this with h | h
      · exact absurd h (ez_ne_zero _)
      · exact h
    simp only [Multiset.mem_toFinset, mem_roots hPne]
    exact hev
  have hZinj : Set.InjOn (fun k : ZMod p => ez (-(k * d))) Z := by
    intro x _ y _ hxy
    have h1 : -(x * d) = -(y * d) := ez_injective hxy
    have h2 : x * d = y * d := neg_injective h1
    exact mul_right_cancel₀ hd h2
  have hZcard : Z.card ≤ P.roots.toFinset.card :=
    Finset.card_le_card_of_injOn _ hZroots hZinj
  have hroots : P.roots.toFinset.card ≤ m - 1 :=
    le_trans (le_trans (Multiset.toFinset_card_le _) (P.card_roots' )) hPdeg
  have hpart := card_zeroSet_add_card_supp f
  rw [← hZ] at hpart
  omega

/-- **Additive uncertainty principle for functions supported on an arithmetic progression.** -/
theorem sum_bound_of_supp_eq_AP (f : ZMod p → ℂ) (hf : f ≠ 0) (a d : ZMod p) (hd : d ≠ 0)
    (m : ℕ) (hm : m ≤ p)
    (hsupp : supp f = (range m).image (fun j : ℕ => a + (j : ZMod p) * d)) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  have hcard : (supp f).card ≤ m := by
    rw [hsupp]
    exact le_trans (Finset.card_image_le) (by simp)
  have hmain := card_supp_dft_ge_of_supp_subset_AP f hf a d hd m hm (by rw [hsupp])
  -- `|supp f| = m`, since the progression is injectively parametrised
  have hinj : Set.InjOn (fun j : ℕ => a + (j : ZMod p) * d) (range m) := by
    intro i hi j hj hij
    simp only [Finset.coe_range, Set.mem_Iio] at hi hj
    have h1 : (i : ZMod p) * d = (j : ZMod p) * d := by simpa using add_left_cancel hij
    have h2 : (i : ZMod p) = (j : ZMod p) := mul_right_cancel₀ hd h1
    have hi' : i < p := lt_of_lt_of_le hi hm
    have hj' : j < p := lt_of_lt_of_le hj hm
    have := congrArg ZMod.val h2
    rwa [ZMod.val_natCast_of_lt hi', ZMod.val_natCast_of_lt hj'] at this
  have hcard' : (supp f).card = m := by
    rw [hsupp, Finset.card_image_of_injOn hinj, Finset.card_range]
  omega

/-! ## The dual statement -/

/-- The double transform reflects: `|supp f̂̂ | = |supp f|`. -/
theorem card_supp_dft_dft (f : ZMod p → ℂ) :
    (supp (dftZMod (dftZMod f))).card = (supp f).card := by
  classical
  have hp : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne p)
  have hset : supp (dftZMod (dftZMod f)) = (supp f).image (fun x : ZMod p => -x) := by
    ext k
    simp only [mem_supp, Finset.mem_image]
    constructor
    · intro hk
      refine ⟨-k, ?_, by ring⟩
      intro h0
      rw [dftZMod_dftZMod f k, h0, mul_zero] at hk
      exact hk rfl
    · rintro ⟨x, hx, rfl⟩
      rw [dftZMod_dftZMod]
      simpa using mul_ne_zero hp hx
  rw [hset, Finset.card_image_of_injective _ neg_injective]

theorem dft_ne_zero (f : ZMod p → ℂ) (hf : f ≠ 0) : dftZMod f ≠ 0 := by
  intro h0
  apply hf
  funext x
  have := dftZMod_dftZMod f (-x)
  rw [h0] at this
  simp only [dftZMod, Pi.zero_apply, mul_zero, Finset.sum_const_zero, neg_neg] at this
  have hp : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne p)
  have : (p : ℂ) * f x = 0 := this.symm
  simpa [hp] using this

/-- **Additive uncertainty principle for functions whose spectrum is an arithmetic
progression.** -/
theorem sum_bound_of_supp_dft_eq_AP (f : ZMod p → ℂ) (hf : f ≠ 0) (a d : ZMod p) (hd : d ≠ 0)
    (m : ℕ) (hm : m ≤ p)
    (hsupp : supp (dftZMod f) = (range m).image (fun j : ℕ => a + (j : ZMod p) * d)) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  have hg := sum_bound_of_supp_eq_AP (dftZMod f) (dft_ne_zero f hf) a d hd m hm hsupp
  rw [card_supp_dft_dft f] at hg
  omega

end Prime

end PrimeUncertainty