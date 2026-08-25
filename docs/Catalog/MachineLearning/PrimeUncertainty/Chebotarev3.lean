/-
# A combinatorial criterion for Chebotarev, and the `3 × 3` case

Expanding a minor `det (ω^{s_j t_k})` of the DFT matrix by the Leibniz formula writes it as
`∑_σ sgn(σ) ω^{E_σ}` with `E_σ = ∑_j s_j t_{σ(j)} ∈ ZMod p`.  Because the only ℚ-linear relation
between the `p` powers `1, ω, …, ω^{p-1}` is `1 + ω + ⋯ + ω^{p-1} = 0`, such a signed sum of
roots of unity vanishes **iff** the parity-weighted multiset of exponents cancels identically.
That gives a purely combinatorial criterion for Chebotarev's theorem, which this file
establishes and then uses to settle the `3 × 3` case in full — a case *not* covered by the
arithmetic-progression results of `Chebotarev.lean` (a three element set of `ZMod p` need not
be an arithmetic progression).

* `PrimeUncertainty.rat_coeffs_const_of_sum_ez_eq_zero` : the linear-independence input.
* `PrimeUncertainty.sum_ez_ne_zero_of_coeff_ne_zero` : the criterion.
* `PrimeUncertainty.det_fin_three_ne_zero` : **all `3 × 3` minors of the DFT matrix of
  `ZMod p` are nonsingular**.
* `PrimeUncertainty.sum_bound_of_card_supp_le_three` : consequently the additive uncertainty
  principle `|supp f| + |supp f̂| ≥ p + 1` holds for every `f` with at most three nonzero
  values, and dually for at most three nonzero Fourier coefficients.
-/

import Mathlib
import MachineLearning.PrimeUncertainty.Synthesis

open Finset Polynomial FourierFA FourierCyclic
open scoped Real

namespace PrimeUncertainty

variable {p : ℕ}

section Independence

variable [hp : Fact p.Prime]

/-- Rewriting a sum over `ZMod p` of powers of `ω` as a sum over `range p`. -/
theorem sum_ez_eq_sum_range (c : ZMod p → ℚ) :
    ∑ r : ZMod p, (c r : ℂ) * ez r = ∑ m ∈ range p, (c (m : ZMod p) : ℂ) * om p ^ m := by
  refine Finset.sum_nbij' (fun r => ZMod.val r) (fun m => (m : ZMod p)) ?_ ?_ ?_ ?_ ?_
  · intro r _; exact Finset.mem_range.2 (ZMod.val_lt r)
  · intro m _; exact Finset.mem_univ _
  · intro r _; simp [ZMod.natCast_val, ZMod.cast_id]
  · intro m hm; exact ZMod.val_natCast_of_lt (Finset.mem_range.1 hm)
  · intro r _
    simp only [ez, ZMod.natCast_val, ZMod.cast_id]

/-- **Linear independence of the `p`-th roots of unity.**  If a rational combination
`∑_r c_r ω^{r}` over all residues vanishes, then all the coefficients `c_r` are equal:
the only relation is `1 + ω + ⋯ + ω^{p-1} = 0`. -/
theorem rat_coeffs_const_of_sum_ez_eq_zero (c : ZMod p → ℚ)
    (hzero : ∑ r : ZMod p, (c r : ℂ) * ez r = 0) :
    ∀ r r' : ZMod p, c r = c r' := by
  classical
  have hppos : 0 < p := (Fact.out : p.Prime).pos
  set P : ℚ[X] := ∑ m ∈ range p, C (c (m : ZMod p)) * X ^ m with hP
  have hPcoeff : ∀ m < p, P.coeff m = c (m : ZMod p) := by
    intro m hm
    rw [hP, finset_sum_coeff, Finset.sum_eq_single_of_mem m (Finset.mem_range.2 hm)]
    · simp
    · intro i _ him
      simp [coeff_C_mul, coeff_X_pow, Ne.symm him]
  have hPdeg : P.natDegree ≤ p - 1 := by
    rw [hP]
    refine natDegree_sum_le_of_forall_le _ _ fun m hm => ?_
    have hm' : m < p := Finset.mem_range.1 hm
    calc (C (c ((m : ℕ) : ZMod p)) * X ^ m).natDegree ≤ (X ^ m : ℚ[X]).natDegree :=
          natDegree_C_mul_le _ _
      _ = m := natDegree_X_pow m
      _ ≤ p - 1 := by omega
  -- `ω` is a root of `P`
  have hprim : IsPrimitiveRoot (om p) p := om_isPrimitiveRoot
  have haeval : (aeval (om p)) P = 0 := by
    rw [hP, map_sum]
    rw [← hzero, sum_ez_eq_sum_range c]
    refine Finset.sum_congr rfl fun m _ => ?_
    simp
  have hcyc : cyclotomic p ℚ = minpoly ℚ (om p) := cyclotomic_eq_minpoly_rat hprim hppos
  have hdvd : cyclotomic p ℚ ∣ P := by
    rw [hcyc]; exact minpoly.dvd ℚ (om p) haeval
  obtain ⟨Q, hQ⟩ := hdvd
  have hcycdeg : (cyclotomic p ℚ).natDegree = p - 1 := by
    rw [natDegree_cyclotomic, Nat.totient_prime (Fact.out : p.Prime)]
  have hcycne : cyclotomic p ℚ ≠ 0 := cyclotomic_ne_zero p ℚ
  -- the quotient is a constant
  have hkey : ∀ m < p, P.coeff m = Q.coeff 0 := by
    intro m hm
    by_cases hQ0 : Q = 0
    · rw [hQ, hQ0, mul_zero]
      simp
    · have hQdeg : Q.natDegree = 0 := by
        have hPne : P ≠ 0 := by
          rw [hQ]
          exact mul_ne_zero hcycne hQ0
        have := natDegree_mul hcycne hQ0
        rw [← hQ] at this
        omega
      obtain ⟨k, hk⟩ := natDegree_eq_zero.1 hQdeg
      have hcoeffcyc : (cyclotomic p ℚ).coeff m = 1 := by
        rw [cyclotomic_prime ℚ p, finset_sum_coeff,
          Finset.sum_eq_single_of_mem m (Finset.mem_range.2 hm)]
        · simp
        · intro i _ him
          simp [coeff_X_pow, Ne.symm him]
      rw [hQ, ← hk, coeff_mul_C, hcoeffcyc, one_mul, coeff_C_zero]
  intro r r'
  have h1 := hkey r.val (ZMod.val_lt r)
  have h2 := hkey r'.val (ZMod.val_lt r')
  rw [hPcoeff r.val (ZMod.val_lt r)] at h1
  rw [hPcoeff r'.val (ZMod.val_lt r')] at h2
  simp only [ZMod.natCast_val, ZMod.cast_id] at h1 h2
  rw [h1, h2]

/-- **The criterion.**  A signed sum of `p`-th roots of unity whose coefficients sum to zero
vanishes only if all coefficients vanish. -/
theorem sum_ez_ne_zero_of_coeff_ne_zero (c : ZMod p → ℚ) (hsum : ∑ r : ZMod p, c r = 0)
    {r₀ : ZMod p} (hc : c r₀ ≠ 0) : ∑ r : ZMod p, (c r : ℂ) * ez r ≠ 0 := by
  intro hzero
  have hconst := rat_coeffs_const_of_sum_ez_eq_zero c hzero
  have hall : ∀ r, c r = c r₀ := fun r => hconst r r₀
  have : ∑ r : ZMod p, c r = (p : ℚ) * c r₀ := by
    rw [Finset.sum_congr rfl fun r _ => hall r]
    rw [Finset.sum_const, card_univ_zmod, nsmul_eq_mul]
  rw [hsum] at this
  have hp0 : (p : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Fact.out : p.Prime).ne_zero
  rcases mul_eq_zero.1 this.symm with h | h
  · exact hp0 h
  · exact hc h

end Independence

/-! ## The `3 × 3` case of Chebotarev's theorem -/

section Three

variable [hp : Fact p.Prime]

/-- Auxiliary: a six-term signed sum of roots of unity is nonzero as soon as one of the negative
exponents differs from all three positive ones. -/
theorem six_term_ne_zero (e₁ e₂ e₃ f₁ f₂ f₃ : ZMod p)
    (h₁ : f₁ ≠ e₁) (h₂ : f₁ ≠ e₂) (h₃ : f₁ ≠ e₃) :
    ez e₁ + ez e₂ + ez e₃ - ez f₁ - ez f₂ - ez f₃ ≠ 0 := by
  classical
  set c : ZMod p → ℚ := fun r =>
    ((if e₁ = r then 1 else 0) + (if e₂ = r then 1 else 0) + (if e₃ = r then 1 else 0)
      - (if f₁ = r then 1 else 0) - (if f₂ = r then 1 else 0) - (if f₃ = r then 1 else 0)) with hc
  have hexpand : ∑ r : ZMod p, (c r : ℂ) * ez r
      = ez e₁ + ez e₂ + ez e₃ - ez f₁ - ez f₂ - ez f₃ := by
    have hsplit : ∀ r : ZMod p, (c r : ℂ) * ez r
        = ((if e₁ = r then (1:ℂ) else 0) * ez r + (if e₂ = r then 1 else 0) * ez r
            + (if e₃ = r then 1 else 0) * ez r - (if f₁ = r then 1 else 0) * ez r
            - (if f₂ = r then 1 else 0) * ez r - (if f₃ = r then 1 else 0) * ez r) := by
      intro r
      rw [hc]
      push_cast
      split_ifs <;> ring
    rw [Finset.sum_congr rfl fun r _ => hsplit r]
    simp [Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.sum_ite_eq]
  have hsum : ∑ r : ZMod p, c r = 0 := by
    have : ∀ r : ZMod p, c r =
        ((if e₁ = r then (1:ℚ) else 0) + (if e₂ = r then 1 else 0) + (if e₃ = r then 1 else 0)
          - (if f₁ = r then 1 else 0) - (if f₂ = r then 1 else 0) - (if f₃ = r then 1 else 0)) :=
      fun r => rfl
    rw [Finset.sum_congr rfl fun r _ => this r]
    simp [Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.sum_ite_eq]
  have hcf : c f₁ ≠ 0 := by
    have h1 : (if e₁ = f₁ then (1:ℚ) else 0) = 0 := if_neg (Ne.symm h₁)
    have h2 : (if e₂ = f₁ then (1:ℚ) else 0) = 0 := if_neg (Ne.symm h₂)
    have h3 : (if e₃ = f₁ then (1:ℚ) else 0) = 0 := if_neg (Ne.symm h₃)
    have hval : c f₁
        = 0 + 0 + 0 - 1 - (if f₂ = f₁ then (1:ℚ) else 0) - (if f₃ = f₁ then (1:ℚ) else 0) := by
      simp only [hc]
      rw [h1, h2, h3]
      simp
    have b2 : (if f₂ = f₁ then (1:ℚ) else 0) = 0 ∨ (if f₂ = f₁ then (1:ℚ) else 0) = 1 := by
      split_ifs <;> simp
    have b3 : (if f₃ = f₁ then (1:ℚ) else 0) = 0 ∨ (if f₃ = f₁ then (1:ℚ) else 0) = 1 := by
      split_ifs <;> simp
    rw [hval]
    rcases b2 with hb2 | hb2 <;> rcases b3 with hb3 | hb3 <;> rw [hb2, hb3] <;> norm_num
  have := sum_ez_ne_zero_of_coeff_ne_zero c hsum hcf
  rw [hexpand] at this
  exact this

/-- **Chebotarev's theorem for `3 × 3` minors.**  For distinct rows `S` and distinct columns `T`
the minor `(ω^{S j · T k})` of the DFT matrix of `ZMod p` is nonsingular. -/
theorem det_fin_three_ne_zero (S T : Fin 3 → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    (Matrix.of fun j k : Fin 3 => ez (S j * T k)).det ≠ 0 := by
  have hSne : ∀ i j : Fin 3, i ≠ j → S i - S j ≠ 0 := fun i j hij =>
    sub_ne_zero.2 fun h => hij (hS h)
  have hTne : ∀ i j : Fin 3, i ≠ j → T i - T j ≠ 0 := fun i j hij =>
    sub_ne_zero.2 fun h => hij (hT h)
  rw [Matrix.det_fin_three]
  simp only [Matrix.of_apply]
  -- rewrite the six products of roots of unity as roots of unity of the summed exponents
  have hprod : ∀ a b c : ZMod p, ez a * ez b * ez c = ez (a + b + c) := by
    intro a b c; rw [ez_add, ez_add]
  rw [hprod, hprod, hprod, hprod, hprod, hprod]
  set e₁ := S 0 * T 0 + S 1 * T 1 + S 2 * T 2 with he₁
  set e₂ := S 0 * T 1 + S 1 * T 2 + S 2 * T 0 with he₂
  set e₃ := S 0 * T 2 + S 1 * T 0 + S 2 * T 1 with he₃
  set f₁ := S 0 * T 0 + S 1 * T 2 + S 2 * T 1 with hf₁
  set f₂ := S 0 * T 1 + S 1 * T 0 + S 2 * T 2 with hf₂
  set f₃ := S 0 * T 2 + S 1 * T 1 + S 2 * T 0 with hf₃
  have hgoal : ez e₁ + ez e₂ + ez e₃ - ez f₁ - ez f₂ - ez f₃ ≠ 0 := by
    refine six_term_ne_zero e₁ e₂ e₃ f₁ f₂ f₃ ?_ ?_ ?_
    · -- `f₁ ≠ e₁`, since `e₁ - f₁ = (S 1 - S 2)(T 1 - T 2)`
      intro h
      have hzero : (S 1 - S 2) * (T 1 - T 2) = 0 := by
        rw [he₁, hf₁] at h
        linear_combination -h
      rcases mul_eq_zero.1 hzero with h' | h'
      · exact hSne 1 2 (by decide) h'
      · exact hTne 1 2 (by decide) h'
    · -- `f₁ ≠ e₂`, since `e₂ - f₁ = (S 0 - S 2)(T 1 - T 0)`
      intro h
      have hzero : (S 0 - S 2) * (T 1 - T 0) = 0 := by
        rw [he₂, hf₁] at h
        linear_combination -h
      rcases mul_eq_zero.1 hzero with h' | h'
      · exact hSne 0 2 (by decide) h'
      · exact hTne 1 0 (by decide) h'
    · -- `f₁ ≠ e₃`, since `e₃ - f₁ = (S 0 - S 1)(T 2 - T 0)`
      intro h
      have hzero : (S 0 - S 1) * (T 2 - T 0) = 0 := by
        rw [he₃, hf₁] at h
        linear_combination -h
      rcases mul_eq_zero.1 hzero with h' | h'
      · exact hSne 0 1 (by decide) h'
      · exact hTne 2 0 (by decide) h'
  intro hdet
  apply hgoal
  rw [← hdet]
  ring

/-! ## The additive uncertainty principle for supports of size at most three -/

/-- **Additive uncertainty principle for supports of size at most three.**
For `p` prime and `f ≠ 0` on `ZMod p` with at most three nonzero values,
`|supp f| + |supp f̂| ≥ p + 1`.  Unlike `sum_bound_of_supp_eq_AP` this places *no* structural
restriction on the support: a three-element subset of `ZMod p` need not be an arithmetic
progression. -/
theorem sum_bound_of_card_supp_le_three (f : ZMod p → ℂ) (hf : f ≠ 0)
    (hcard : (supp f).card ≤ 3) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  rcases Nat.lt_or_ge (supp f).card 3 with h | h
  · exact sum_bound_of_card_supp_le_two f hf (by omega)
  · have hc3 : (supp f).card = 3 := le_antisymm hcard h
    refine sum_bound_of_chebotarev_at f hf ?_
    rw [hc3]
    exact fun S T hS hT => det_fin_three_ne_zero S T hS hT

/-- Dual version: at most three nonzero Fourier coefficients. -/
theorem sum_bound_of_card_supp_dft_le_three (f : ZMod p → ℂ) (hf : f ≠ 0)
    (hcard : (supp (dftZMod f)).card ≤ 3) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  have hg := sum_bound_of_card_supp_le_three (dftZMod f) (dft_ne_zero f hf) hcard
  rw [card_supp_dft_dft f] at hg
  omega

/-- **Large supports.**  If `f` has at least `p - 3` nonzero values the additive bound also
holds: either the spectrum is small (and the dual case applies) or it already has at least
four points. -/
theorem sum_bound_of_card_supp_ge (f : ZMod p → ℂ) (hf : f ≠ 0)
    (hcard : p - 3 ≤ (supp f).card) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  by_cases h : (supp (dftZMod f)).card ≤ 3
  · exact sum_bound_of_card_supp_dft_le_three f hf h
  · push_neg at h
    have hle : (supp f).card ≤ p := by
      calc (supp f).card ≤ (Finset.univ : Finset (ZMod p)).card :=
            Finset.card_le_card (subset_univ _)
        _ = p := card_univ_zmod
    have hleB : (supp (dftZMod f)).card ≤ p := by
      calc (supp (dftZMod f)).card ≤ (Finset.univ : Finset (ZMod p)).card :=
            Finset.card_le_card (subset_univ _)
        _ = p := card_univ_zmod
    omega

/-- **Master theorem of this development.**  The additive uncertainty principle
`|supp f| + |supp f̂| ≥ p + 1` is proved here in five regimes: at most three nonzero values,
at most three nonzero Fourier coefficients, at least `p - 3` nonzero values, support an
arithmetic progression, spectrum an arithmetic progression. -/
theorem sum_bound_known_regimes (f : ZMod p → ℂ) (hf : f ≠ 0)
    (h : (supp f).card ≤ 3 ∨ (supp (dftZMod f)).card ≤ 3 ∨ p - 3 ≤ (supp f).card ∨
      (∃ a d : ZMod p, ∃ m : ℕ, d ≠ 0 ∧ m ≤ p ∧
        supp f = (range m).image (fun j : ℕ => a + (j : ZMod p) * d)) ∨
      (∃ a d : ZMod p, ∃ m : ℕ, d ≠ 0 ∧ m ≤ p ∧
        supp (dftZMod f) = (range m).image (fun j : ℕ => a + (j : ZMod p) * d))) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  rcases h with h | h | h | ⟨a, d, m, hd, hm, hAP⟩ | ⟨a, d, m, hd, hm, hAP⟩
  · exact sum_bound_of_card_supp_le_three f hf h
  · exact sum_bound_of_card_supp_dft_le_three f hf h
  · exact sum_bound_of_card_supp_ge f hf h
  · exact sum_bound_of_supp_eq_AP f hf a d hd m hm hAP
  · exact sum_bound_of_supp_dft_eq_AP f hf a d hd m hm hAP

end Three

end PrimeUncertainty