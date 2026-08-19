/-
# The algebra of extremal functions, and extremal probability distributions

Building on the classification of the extremals of the Donoho–Stark uncertainty principle
(`Catalog.Probability.FourierExtremalConverse`), this file exploits the classification in both
directions to establish *closure* properties of the extremal class and a probabilistic corollary.

Main results:

* `FourierFA.dft_coset_modulation` : the explicit Fourier transform of a coset modulation
  `c · χ · 1_{a + K}`, showing it is itself a coset modulation on the dual group.
* `FourierFA.inter_coset` : the intersection of two cosets is empty or a coset of the
  intersection of the two subgroups.
* `FourierFA.isExtremal_mul` : the pointwise product of two extremal functions is either `0` or
  extremal — a closure property that is *false* for arbitrary functions and which uses both
  directions of the classification.
* `FourierFA.isExtremal_prob_uniform_on_coset` : an extremal *probability distribution* is the
  uniform distribution on a coset.
-/

import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality
import Shared.FourierExtremals
import Probability.FourierExtremalConverse

open Finset ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The Fourier transform of a coset modulation -/

/-- The Fourier transform of `c · χ · 1_{a + K}` is `c · conj ((ψ - χ) a) · |K|` on the coset
`χ + K^⊥` of the dual group, and `0` elsewhere. -/
theorem dft_coset_modulation (K : AddSubgroup G) [DecidablePred (· ∈ K)] (c : ℂ)
    (χ : AddChar G ℂ) (a : G) (ψ : AddChar G ℂ) :
    dft (c • modul χ (transl a (indic K))) ψ
      = if ψ - χ ∈ annih K then c * conj ((ψ - χ) a) * ((subFinset K).card : ℂ) else 0 := by
  rw [dft_smul, Pi.smul_apply, smul_eq_mul, dft_modul, dft_transl, dft_indic]
  by_cases h : ψ - χ ∈ annih K
  · rw [if_pos h, if_pos h]; ring
  · rw [if_neg h, if_neg h]; ring

/-! ## Intersections of cosets -/

omit [Fintype G] [DecidableEq G] in
/-- The intersection of a coset of `K` and a coset of `K'` is either empty or a coset of
`K ⊓ K'`. -/
theorem inter_coset {K K' : AddSubgroup G} {a a' b : G} (hb : b - a ∈ K) (hb' : b - a' ∈ K')
    (x : G) : (x - a ∈ K ∧ x - a' ∈ K') ↔ x - b ∈ K ⊓ K' := by
  constructor
  · rintro ⟨hx, hx'⟩
    refine AddSubgroup.mem_inf.2 ⟨?_, ?_⟩
    · have h : x - b = (x - a) - (b - a) := by abel
      rw [h]; exact K.sub_mem hx hb
    · have h : x - b = (x - a') - (b - a') := by abel
      rw [h]; exact K'.sub_mem hx' hb'
  · intro hx
    obtain ⟨h1, h2⟩ := AddSubgroup.mem_inf.1 hx
    constructor
    · have h : x - a = (x - b) + (b - a) := by abel
      rw [h]; exact K.add_mem h1 hb
    · have h : x - a' = (x - b) + (b - a') := by abel
      rw [h]; exact K'.add_mem h2 hb'

/-! ## Closure of the extremal class under pointwise multiplication -/

/-- **The extremal class is closed under pointwise products.** If `u` and `v` both attain
equality in the uncertainty principle, then `u · v` is either identically zero (their supports,
being cosets, may be disjoint) or again extremal. -/
theorem isExtremal_mul {u v : G → ℂ} (hu0 : u ≠ 0) (hv0 : v ≠ 0)
    (hu : IsExtremal u) (hv : IsExtremal v) :
    (fun x => u x * v x) = 0 ∨ IsExtremal (fun x => u x * v x) := by
  classical
  obtain ⟨K, χ, a, c, hc, h1, h2⟩ := exists_coset_modulation_of_isExtremal u hu0 hu
  obtain ⟨K', χ', a', c', hc', h1', h2'⟩ := exists_coset_modulation_of_isExtremal v hv0 hv
  by_cases hem : ∃ b : G, b - a ∈ K ∧ b - a' ∈ K'
  · right
    obtain ⟨b, hb, hb'⟩ := hem
    have hchar : ∀ (ξ : AddChar G ℂ) (x : G), ξ x ≠ 0 := by
      intro ξ x h0
      have := AddChar.norm_apply ξ x
      rw [h0] at this
      simp at this
    have hwb : u b * v b ≠ 0 := by
      rw [h1 b hb, h1' b hb']
      exact mul_ne_zero (mul_ne_zero hc (hchar χ b)) (mul_ne_zero hc' (hchar χ' b))
    have hw0 : (fun x => u x * v x) ≠ 0 := by
      intro h
      exact hwb (by simpa using congrFun h b)
    rw [isExtremal_iff_coset_modulation _ hw0]
    refine ⟨K ⊓ K', χ + χ', b, c * c', mul_ne_zero hc hc', ?_, ?_⟩
    · intro x hx
      obtain ⟨hxK, hxK'⟩ := (inter_coset hb hb' x).2 hx
      rw [h1 x hxK, h1' x hxK', AddChar.add_apply]
      ring
    · intro x hx
      have hnot : ¬ (x - a ∈ K ∧ x - a' ∈ K') := fun h => hx ((inter_coset hb hb' x).1 h)
      rcases not_and_or.1 hnot with h | h
      · rw [h2 x h, zero_mul]
      · rw [h2' x h, mul_zero]
  · left
    push_neg at hem
    funext x
    by_cases hx : x - a ∈ K
    · rw [h2' x (hem x hx), mul_zero]
      rfl
    · rw [h2 x hx, zero_mul]
      rfl

/-! ## Extremal probability distributions -/

/-- **An extremal probability distribution is uniform on a coset.** If a probability
distribution `p` on a finite abelian group attains equality in the uncertainty principle, then
`p` is the uniform distribution on a coset of a subgroup. -/
theorem isExtremal_prob_uniform_on_coset (p : G → ℝ) (hp0 : ∀ x, 0 ≤ p x)
    (hp1 : ∑ x, p x = 1) (hext : IsExtremal (fun x => (p x : ℂ))) :
    ∃ (a : G) (K : AddSubgroup G) (S : Finset G),
      (∀ x, x ∈ S ↔ x - a ∈ K) ∧ (∀ x, p x = if x ∈ S then (S.card : ℝ)⁻¹ else 0) := by
  classical
  set f : G → ℂ := fun x => (p x : ℂ) with hf
  have hf0 : f ≠ 0 := by
    intro h
    have : ∑ x, p x = 0 := by
      have hx : ∀ x, p x = 0 := by
        intro x
        have := congrFun h x
        simp [hf] at this
        exact this
      simp [hx]
    rw [hp1] at this
    exact one_ne_zero this
  obtain ⟨K, χ, a, c, hc, h1, h2⟩ := exists_coset_modulation_of_isExtremal f hf0 hext
  refine ⟨a, K, supp f, ?_, ?_⟩
  · intro x
    constructor
    · intro hx
      by_contra hxK
      exact (mem_supp.1 hx) (h2 x hxK)
    · intro hx
      refine mem_supp.2 ?_
      rw [h1 x hx]
      refine mul_ne_zero hc ?_
      intro h0
      have := AddChar.norm_apply χ x
      rw [h0] at this
      simp at this
  · -- on the support `p` is the constant `‖c‖`, and the constant is forced by `∑ p = 1`
    have hvalue : ∀ x ∈ supp f, p x = ‖c‖ := by
      intro x hx
      have hxK : x - a ∈ K := by
        by_contra hxK
        exact (mem_supp.1 hx) (h2 x hxK)
      have hnorm : ‖f x‖ = ‖c‖ := by
        rw [h1 x hxK, norm_mul, AddChar.norm_apply, mul_one]
      have : |p x| = ‖c‖ := by
        rw [← hnorm, hf]
        simp
      rwa [abs_of_nonneg (hp0 x)] at this
    have hzero : ∀ x, x ∉ supp f → p x = 0 := by
      intro x hx
      have : f x = 0 := by
        by_contra h
        exact hx (mem_supp.2 h)
      have h' : ((p x : ℝ) : ℂ) = 0 := this
      exact_mod_cast h'
    have hsum : ((supp f).card : ℝ) * ‖c‖ = 1 := by
      rw [← hp1]
      rw [← Finset.sum_subset (Finset.subset_univ (supp f)) (fun x _ hx => hzero x hx)]
      rw [Finset.sum_congr rfl hvalue, Finset.sum_const, nsmul_eq_mul]
    have hcardpos : (0 : ℝ) < (supp f).card := by
      have : (supp f).Nonempty := supp_nonempty_of_ne_zero hf0
      exact_mod_cast Finset.card_pos.2 this
    have hcval : ‖c‖ = ((supp f).card : ℝ)⁻¹ := by
      field_simp at hsum ⊢
      linarith [hsum]
    intro x
    by_cases hx : x ∈ supp f
    · rw [if_pos hx, hvalue x hx, hcval]
    · rw [if_neg hx, hzero x hx]

end FourierFA