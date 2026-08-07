/-
# The complete `p`-biased Fourier expansion on the discrete cube

`Catalog/Combinatorics/BernoulliInfluenceSqrt.lean` developed the degree-`≤ 1`
part of `p`-biased Fourier analysis: the single-site characters `psi p v`, their
orthogonality relations, and Bessel's inequality for the family `{1} ∪ {ψ_v}`,
from which the `ℓ²` influence bound and the square-root law follow.

Bessel's inequality is an *inequality* precisely because the family `{1} ∪ {ψ_v}`
is incomplete.  This file completes it.  For each set of sites `S` we form the
character `psiSet p S η = ∏_{v ∈ S} ψ_v(η)` and prove:

* `expP_prod`: the product rule for the biased expectation — the expectation of a
  product of one-coordinate functions factorizes.  This is the formal statement
  that the Bernoulli measure is a product measure, and it is the engine of the
  whole file;
* `expP_psiSet_mul_psiSet`: full orthogonality,
  `E[ψ_S ψ_T] = [S = T] · (p(1-p))^{|S|}`;
* `fourierKernel_eq`: the reproducing-kernel identity
  `∑_S ∏_{v ∈ S} ψ_v(ξ)ψ_v(η)/(p(1-p)) = [ξ = η] / weight p η`, obtained by
  expanding a product of `|ι|` binomials;
* `fourier_expansion`: **completeness** — every real function on the cube is the
  sum of its Fourier series `f = ∑_S \hat f(S) ψ_S` for `0 < p < 1`;
* `parseval`: `E[f g] = ∑_S (p(1-p))^{|S|} \hat f(S) \hat g(S)`, and the variance
  form `expP_sq_sub_sq_expP`.

The applications sharpen the results of the previous file from inequalities to
identities:

* `signInd_energy_decomposition`: for an increasing event,
  `4 P(1-P) = 4 p(1-p) ∑_v I_v² + R`, where `R ≥ 0` is the Fourier energy of the
  levels `|S| ≥ 2`.  The `ℓ² `influence bound `sum_sq_influence_le` is exactly
  the statement `R ≥ 0`, so it is an equality precisely for events whose Fourier
  expansion has no term of degree `≥ 2`;
* `sum_sq_influence_eq_of_degree_le_one` and
  `sum_sq_influence_lt_of_degree_two`: the equality case and a strict
  improvement in the presence of a nonzero degree-`≥ 2` coefficient;
* `fourier_weight_sum`: the total Fourier energy of a `±1`-valued function is
  `1` — the biased Plancherel identity for Boolean functions.

Everything is finite algebra: the only inputs are `Finset.prod_univ_sum`,
`Finset.prod_add`, and the one-coordinate computations.
-/

import Combinatorics.BernoulliInfluenceSqrt

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The product rule for the biased expectation -/

/-- **The product rule.**  The Bernoulli measure is a product measure: the
expectation of a product of one-coordinate functions is the product of the
one-coordinate expectations. -/
theorem expP_prod (p : ℝ) (g : ι → Bool → ℝ) :
    expP p (fun η => ∏ v, g v (η v)) = ∏ v, (p * g v true + (1 - p) * g v false) := by
  classical
  have key := Finset.prod_univ_sum (fun _ : ι => (univ : Finset Bool))
      (fun (v : ι) (b : Bool) => (if b then p else 1 - p) * g v b)
  rw [Fintype.piFinset_univ] at key
  simp only [Fintype.sum_bool, if_true] at key
  have hsum : ∑ η : ι → Bool, weight p η * ∏ v, g v (η v)
      = ∑ η : ι → Bool, ∏ v, ((if η v then p else 1 - p) * g v (η v)) := by
    refine Finset.sum_congr rfl fun η _ => ?_
    rw [Finset.prod_mul_distrib, weight_eq_prod]
  rw [expP, hsum, ← key]
  exact Finset.prod_congr rfl fun v _ => by norm_num

/-! ## Characters of arbitrary sets of sites -/

/-- The one-coordinate character: `1 - p` at an open site, `-p` at a closed
site. -/
def psiB (p : ℝ) (b : Bool) : ℝ := if b then 1 - p else -p

omit [Fintype ι] [DecidableEq ι] in
theorem psi_eq_psiB (p : ℝ) (v : ι) (η : ι → Bool) : psi p v η = psiB p (η v) := rfl

/-- The biased Walsh character of a set of sites, `ψ_S = ∏_{v ∈ S} ψ_v`. -/
def psiSet (p : ℝ) (S : Finset ι) (η : ι → Bool) : ℝ := ∏ v ∈ S, psi p v η

omit [Fintype ι] [DecidableEq ι] in
theorem psiSet_empty (p : ℝ) (η : ι → Bool) : psiSet p (∅ : Finset ι) η = 1 := by
  simp [psiSet]

omit [Fintype ι] [DecidableEq ι] in
theorem psiSet_singleton (p : ℝ) (v : ι) (η : ι → Bool) :
    psiSet p {v} η = psi p v η := by
  simp [psiSet]

theorem psiSet_eq_prod_univ (p : ℝ) (S : Finset ι) (η : ι → Bool) :
    psiSet p S η = ∏ v : ι, (if v ∈ S then psiB p (η v) else 1) := by
  rw [psiSet, ← Finset.prod_subset (Finset.subset_univ S) (fun x _ hx => by simp [hx])]
  exact Finset.prod_congr rfl fun v hv => by simp [hv, psi_eq_psiB]

/-- **Full orthogonality of the biased characters.**  `E[ψ_S ψ_T]` vanishes
unless `S = T`, in which case it is `(p(1-p))^{|S|}`. -/
theorem expP_psiSet_mul_psiSet (p : ℝ) (S T : Finset ι) :
    expP p (fun η => psiSet p S η * psiSet p T η)
      = if S = T then (p * (1 - p)) ^ S.card else 0 := by
  classical
  have hfun : (fun η : ι → Bool => psiSet p S η * psiSet p T η)
      = fun η : ι → Bool => ∏ v : ι,
        ((if v ∈ S then psiB p (η v) else 1) * (if v ∈ T then psiB p (η v) else 1)) := by
    funext η
    rw [psiSet_eq_prod_univ, psiSet_eq_prod_univ, ← Finset.prod_mul_distrib]
  rw [hfun, expP_prod p
    (fun v b => (if v ∈ S then psiB p b else 1) * (if v ∈ T then psiB p b else 1))]
  by_cases hST : S = T
  · subst hST
    rw [if_pos rfl,
      ← Finset.prod_subset (Finset.subset_univ S) (fun x _ hx => by simp [hx]),
      Finset.prod_congr rfl (g := fun _ => p * (1 - p)) (fun v hv => by
        simp [hv, psiB]; ring), Finset.prod_const]
  · rw [if_neg hST]
    obtain ⟨v, hv⟩ : ∃ v, (v ∈ S) ≠ (v ∈ T) := by
      by_contra h
      push_neg at h
      exact hST (Finset.ext fun v => by
        have := h v; constructor <;> intro hx <;> [rw [← this]; rw [this]] <;> exact hx)
    refine Finset.prod_eq_zero (Finset.mem_univ v) ?_
    by_cases hS : v ∈ S
    · have hT : v ∉ T := by intro hT; exact hv (by simp [hS, hT])
      simp [hS, hT, psiB]; ring
    · have hT : v ∈ T := by
        by_contra hT; exact hv (by simp [hS, hT])
      simp [hS, hT, psiB]; ring

/-! ## Fourier coefficients, the reproducing kernel and completeness -/

/-- The `p`-biased Fourier coefficient of `f` at the set of sites `S`. -/
noncomputable def fcoeff (p : ℝ) (f : (ι → Bool) → ℝ) (S : Finset ι) : ℝ :=
  expP p (fun η => f η * psiSet p S η) / (p * (1 - p)) ^ S.card

theorem fcoeff_empty (p : ℝ) (f : (ι → Bool) → ℝ) :
    fcoeff p f ∅ = expP p f := by
  simp [fcoeff, psiSet_empty]

theorem expP_mul_psiSet (p : ℝ) (f : (ι → Bool) → ℝ) {S : Finset ι}
    (hq : (p * (1 - p)) ^ S.card ≠ 0) :
    expP p (fun η => f η * psiSet p S η) = fcoeff p f S * (p * (1 - p)) ^ S.card := by
  rw [fcoeff, div_mul_cancel₀ _ hq]

/-- Linearity of the biased expectation over a finite sum. -/
theorem expP_sum {κ : Type*} (p : ℝ) (s : Finset κ) (F : κ → (ι → Bool) → ℝ) :
    expP p (fun η => ∑ k ∈ s, F k η) = ∑ k ∈ s, expP p (F k) := by
  unfold expP
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun η _ => by rw [Finset.mul_sum]

/-- **The reproducing kernel of the biased Fourier basis.**  Summing the
normalized products of characters over all sets of sites gives a multiple of the
diagonal. -/
theorem fourierKernel_eq {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (ξ η : ι → Bool) :
    ∑ S : Finset ι, ∏ v ∈ S, (psi p v ξ * psi p v η / (p * (1 - p)))
      = if ξ = η then (weight p η)⁻¹ else 0 := by
  classical
  have hpne : p ≠ 0 := ne_of_gt hp0
  have hqne : (1 : ℝ) - p ≠ 0 := by linarith
  have hexp : ∑ S : Finset ι, ∏ v ∈ S, (psi p v ξ * psi p v η / (p * (1 - p)))
      = ∏ v : ι, (psi p v ξ * psi p v η / (p * (1 - p)) + 1) := by
    have h := Finset.prod_add (fun v : ι => psi p v ξ * psi p v η / (p * (1 - p)))
      (fun _ : ι => (1 : ℝ)) univ
    rw [Finset.powerset_univ] at h
    simp only [Finset.prod_const_one, mul_one] at h
    rw [← h]
  rw [hexp]
  by_cases h : ξ = η
  · subst h
    rw [if_pos rfl, weight_eq_prod, ← Finset.prod_inv_distrib]
    refine Finset.prod_congr rfl fun v _ => ?_
    rcases Bool.eq_false_or_eq_true (ξ v) with hv | hv <;>
      simp only [psi, hv, Bool.false_eq_true, if_true, if_false] <;>
      field_simp <;> try ring
  · obtain ⟨v, hv⟩ : ∃ v, ξ v ≠ η v := by
      by_contra hc
      push_neg at hc
      exact h (funext hc)
    rw [if_neg h]
    refine Finset.prod_eq_zero (Finset.mem_univ v) ?_
    rcases Bool.eq_false_or_eq_true (ξ v) with hx | hx <;>
      rcases Bool.eq_false_or_eq_true (η v) with hy | hy <;>
      rw [hx, hy] at hv <;>
      simp only [psi, hx, hy, Bool.false_eq_true, if_true, if_false] <;>
      first
        | exact absurd rfl hv
        | (field_simp; try ring)

/-- **Completeness of the biased Fourier basis.**  Every real function on the
cube equals the sum of its Fourier series. -/
theorem fourier_expansion {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f : (ι → Bool) → ℝ)
    (η : ι → Bool) :
    ∑ S : Finset ι, fcoeff p f S * psiSet p S η = f η := by
  classical
  have hpne : p ≠ 0 := ne_of_gt hp0
  have hqne : (1 : ℝ) - p ≠ 0 := by linarith
  have hq : (0 : ℝ) < p * (1 - p) := mul_pos hp0 (by linarith)
  have hstep : ∀ S : Finset ι, fcoeff p f S * psiSet p S η
      = ∑ ξ : ι → Bool, weight p ξ * f ξ * ∏ v ∈ S, (psi p v ξ * psi p v η / (p * (1 - p))) := by
    intro S
    have hqS : ((p * (1 - p)) ^ S.card : ℝ) ≠ 0 := by positivity
    rw [fcoeff, div_mul_eq_mul_div, eq_comm, eq_div_iff hqS, expP, Finset.sum_mul,
      Finset.sum_mul]
    refine Finset.sum_congr rfl fun ξ _ => ?_
    have hprod : (∏ v ∈ S, (psi p v ξ * psi p v η / (p * (1 - p)))) * (p * (1 - p)) ^ S.card
        = psiSet p S ξ * psiSet p S η := by
      rw [← Finset.prod_const, ← Finset.prod_mul_distrib, psiSet, psiSet,
        ← Finset.prod_mul_distrib]
      exact Finset.prod_congr rfl fun v _ => by field_simp
    calc weight p ξ * f ξ * (∏ v ∈ S, (psi p v ξ * psi p v η / (p * (1 - p))))
          * (p * (1 - p)) ^ S.card
        = weight p ξ * f ξ * ((∏ v ∈ S, (psi p v ξ * psi p v η / (p * (1 - p))))
            * (p * (1 - p)) ^ S.card) := by ring
      _ = weight p ξ * f ξ * (psiSet p S ξ * psiSet p S η) := by rw [hprod]
      _ = weight p ξ * (f ξ * psiSet p S ξ) * psiSet p S η := by ring
  rw [Finset.sum_congr rfl fun S (_ : S ∈ univ) => hstep S, Finset.sum_comm]
  have hterm : ∀ ξ : ι → Bool,
      ∑ S : Finset ι, weight p ξ * f ξ * ∏ v ∈ S, (psi p v ξ * psi p v η / (p * (1 - p)))
        = if ξ = η then f η else 0 := by
    intro ξ
    rw [← Finset.mul_sum, fourierKernel_eq hp0 hp1 ξ η]
    by_cases h : ξ = η
    · subst h
      rw [if_pos rfl, if_pos rfl]
      field_simp [ne_of_gt (weight_pos hp0 hp1 ξ)]
    · rw [if_neg h, if_neg h, mul_zero]
  rw [Finset.sum_congr rfl fun ξ (_ : ξ ∈ univ) => hterm ξ, Finset.sum_ite_eq' univ η,
    if_pos (Finset.mem_univ η)]

/-! ## Parseval's identity -/

/-- **Parseval's identity** for the `p`-biased Fourier basis. -/
theorem parseval {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f g : (ι → Bool) → ℝ) :
    expP p (fun η => f η * g η)
      = ∑ S : Finset ι, (p * (1 - p)) ^ S.card * (fcoeff p f S * fcoeff p g S) := by
  classical
  have hqne : ∀ S : Finset ι, ((p * (1 - p)) ^ S.card : ℝ) ≠ 0 := fun S =>
    pow_ne_zero _ (ne_of_gt (mul_pos hp0 (by linarith)))
  have hfun : (fun η : ι → Bool => f η * g η)
      = fun η : ι → Bool => ∑ S : Finset ι, fcoeff p f S * (psiSet p S η * g η) := by
    funext η
    rw [← fourier_expansion hp0 hp1 f η, Finset.sum_mul]
    exact Finset.sum_congr rfl fun S _ => by ring
  rw [hfun, expP_sum]
  refine Finset.sum_congr rfl fun S _ => ?_
  have : expP p (fun η => fcoeff p f S * (psiSet p S η * g η))
      = fcoeff p f S * expP p (fun η => g η * psiSet p S η) := by
    rw [← expP_const_mul]
    exact congrArg (expP p) (funext fun η => by ring)
  rw [this, expP_mul_psiSet p g (hqne S)]
  ring

/-- The variance form of Parseval: the variance of `f` is the Fourier energy of
its nonconstant part. -/
theorem expP_sq_sub_sq_expP {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f : (ι → Bool) → ℝ) :
    expP p (fun η => f η * f η) - (expP p f) ^ 2
      = ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
          (p * (1 - p)) ^ S.card * (fcoeff p f S) ^ 2 := by
  classical
  have hpar := parseval hp0 hp1 f f
  have hsplit : ∑ S : Finset ι, (p * (1 - p)) ^ S.card * (fcoeff p f S * fcoeff p f S)
      = (p * (1 - p)) ^ (∅ : Finset ι).card * (fcoeff p f ∅ * fcoeff p f ∅)
        + ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
            (p * (1 - p)) ^ S.card * (fcoeff p f S * fcoeff p f S) := by
    rw [← Finset.sum_filter_add_sum_filter_not univ (fun S : Finset ι => S = ∅)]
    have h1 : ∑ S ∈ univ.filter (fun S : Finset ι => S = ∅),
        (p * (1 - p)) ^ S.card * (fcoeff p f S * fcoeff p f S)
        = (p * (1 - p)) ^ (∅ : Finset ι).card * (fcoeff p f ∅ * fcoeff p f ∅) := by
      rw [Finset.filter_eq' univ (∅ : Finset ι), if_pos (Finset.mem_univ _),
        Finset.sum_singleton]
    rw [h1]
  rw [hpar, hsplit, fcoeff_empty]
  simp only [Finset.card_empty, pow_zero, one_mul, pow_two]
  ring

/-! ## Exact energy decomposition for increasing events -/

/-- The degree-one Fourier coefficient of the `±1`-indicator of an increasing
event is twice the influence of the site. -/
theorem fcoeff_signInd_singleton {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) (v : ι) :
    fcoeff p (signInd A) {v} = 2 * bernProb p (pivotalSet A v) := by
  have hq : (p * (1 - p)) ≠ 0 := ne_of_gt (mul_pos hp0 (by linarith))
  have hfun : (fun η : ι → Bool => signInd A η * psiSet p {v} η)
      = fun η : ι → Bool => signInd A η * psi p v η :=
    funext fun η => by rw [psiSet_singleton]
  have hpne : p ≠ 0 := ne_of_gt hp0
  have hqne : (1 : ℝ) - p ≠ 0 := by linarith
  rw [fcoeff, hfun, expP_signInd_mul_psi hA p v, Finset.card_singleton, pow_one]
  field_simp

/-- The Fourier coefficient at `∅` of the `±1`-indicator is `2P - 1`. -/
theorem fcoeff_signInd_empty (p : ℝ) (A : Set (ι → Bool)) :
    fcoeff p (signInd A) ∅ = 2 * bernProb p A - 1 := by
  rw [fcoeff_empty, expP_signInd]

/-- **The biased Plancherel identity for Boolean functions.**  The total Fourier
energy of a `±1`-valued function is `1`. -/
theorem fourier_weight_sum {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (A : Set (ι → Bool)) :
    ∑ S : Finset ι, (p * (1 - p)) ^ S.card * (fcoeff p (signInd A) S) ^ 2 = 1 := by
  have h := parseval hp0 hp1 (signInd A) (signInd A)
  rw [expP_signInd_sq] at h
  simp only [pow_two]
  exact h.symm

/-- The Fourier energy carried by the levels `|S| ≥ 2` of the `±1`-indicator. -/
noncomputable def highEnergy (p : ℝ) (A : Set (ι → Bool)) : ℝ :=
  ∑ S ∈ univ.filter (fun S : Finset ι => 2 ≤ S.card),
    (p * (1 - p)) ^ S.card * (fcoeff p (signInd A) S) ^ 2

theorem highEnergy_nonneg {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (A : Set (ι → Bool)) :
    0 ≤ highEnergy p A :=
  Finset.sum_nonneg fun S _ => mul_nonneg
    (pow_nonneg (le_of_lt (mul_pos hp0 (by linarith))) _) (sq_nonneg _)

/-- **Exact energy decomposition of an increasing event.**  The variance of the
`±1`-indicator splits into the influence (degree-one) part and the energy of the
higher levels:
`4 P (1 - P) = 4 p(1-p) ∑_v I_v² + highEnergy`.
The `ℓ²` influence bound `sum_sq_influence_le` is exactly the assertion that the
remainder is nonnegative. -/
theorem signInd_energy_decomposition {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    4 * (bernProb p A * (1 - bernProb p A))
      = 4 * (p * (1 - p)) * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2
        + highEnergy p A := by
  classical
  set c : Finset ι → ℝ := fun S => (p * (1 - p)) ^ S.card * (fcoeff p (signInd A) S) ^ 2 with hc
  have htot : ∑ S : Finset ι, c S = 1 := fourier_weight_sum hp0 hp1 A
  -- split the sum by the cardinality of `S`
  have hsplit : ∑ S : Finset ι, c S
      = c ∅ + ∑ v : ι, c {v} + ∑ S ∈ univ.filter (fun S : Finset ι => 2 ≤ S.card), c S := by
    have h1 : ∑ S : Finset ι, c S
        = ∑ S ∈ univ.filter (fun S : Finset ι => S.card ≤ 1), c S
          + ∑ S ∈ univ.filter (fun S : Finset ι => 2 ≤ S.card), c S := by
      rw [← Finset.sum_filter_add_sum_filter_not univ (fun S : Finset ι => S.card ≤ 1)]
      congr 1
      refine Finset.sum_congr (Finset.filter_congr fun S _ => by omega) fun S _ => rfl
    have hnot : (∅ : Finset ι) ∉ univ.image (fun v : ι => ({v} : Finset ι)) := by
      simp only [Finset.mem_image, Finset.mem_univ, true_and, not_exists]
      intro v hv
      exact (Finset.singleton_ne_empty v) hv
    have h2 : ∑ S ∈ univ.filter (fun S : Finset ι => S.card ≤ 1), c S
        = c ∅ + ∑ v : ι, c {v} := by
      have hins : univ.filter (fun S : Finset ι => S.card ≤ 1)
          = insert (∅ : Finset ι) (univ.image (fun v : ι => ({v} : Finset ι))) := by
        ext S
        simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
          Finset.mem_image]
        constructor
        · intro hS
          rcases Nat.lt_or_ge S.card 1 with hlt | hge
          · have hz : S.card = 0 := by omega
            exact Or.inl (Finset.card_eq_zero.mp hz)
          · have ho : S.card = 1 := le_antisymm hS hge
            obtain ⟨v, hv⟩ := Finset.card_eq_one.mp ho
            exact Or.inr ⟨v, hv.symm⟩
        · rintro (rfl | ⟨v, rfl⟩) <;> simp
      rw [hins, Finset.sum_insert hnot,
        Finset.sum_image (fun u _ v _ h => Finset.singleton_injective h)]
    rw [h1, h2, add_assoc]
  have hc0 : c ∅ = (2 * bernProb p A - 1) ^ 2 := by
    rw [hc]
    simp only [Finset.card_empty, pow_zero, one_mul]
    rw [fcoeff_signInd_empty]
  have hc1 : ∀ v : ι, c {v} = (p * (1 - p)) * (2 * bernProb p (pivotalSet A v)) ^ 2 := by
    intro v
    rw [hc]
    simp only [Finset.card_singleton, pow_one]
    rw [fcoeff_signInd_singleton hp0 hp1 hA v]
  have hsum1 : ∑ v : ι, c {v}
      = 4 * (p * (1 - p)) * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2 := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun v _ => by rw [hc1 v]; ring
  rw [hsplit, hc0, hsum1] at htot
  have hhigh : highEnergy p A = ∑ S ∈ univ.filter (fun S : Finset ι => 2 ≤ S.card), c S := rfl
  rw [hhigh]
  nlinarith [htot]

/-- **The equality case of the `ℓ²` influence bound.**  If the `±1`-indicator has
no Fourier energy above level one, the bound `p(1-p) ∑_v I_v² ≤ P(1-P)` is an
equality. -/
theorem sum_sq_influence_eq_of_degree_le_one {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) (hdeg : highEnergy p A = 0) :
    (p * (1 - p)) * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2
      = bernProb p A * (1 - bernProb p A) := by
  have h := signInd_energy_decomposition hp0 hp1 hA
  rw [hdeg] at h
  linarith

/-- **Strict improvement in the presence of a degree-`≥ 2` coefficient.**  If some
Fourier coefficient of the `±1`-indicator at a set of at least two sites is
nonzero, the `ℓ²` influence bound is strict. -/
theorem sum_sq_influence_lt_of_degree_two {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) {S : Finset ι} (hS : 2 ≤ S.card)
    (hne : fcoeff p (signInd A) S ≠ 0) :
    (p * (1 - p)) * ∑ v : ι, (bernProb p (pivotalSet A v)) ^ 2
      < bernProb p A * (1 - bernProb p A) := by
  classical
  have hq : (0 : ℝ) < p * (1 - p) := mul_pos hp0 (by linarith)
  have hpos : 0 < highEnergy p A := by
    refine Finset.sum_pos' (fun T _ => by positivity) ⟨S, Finset.mem_filter.mpr
      ⟨Finset.mem_univ S, hS⟩, ?_⟩
    have hsq : 0 < (fcoeff p (signInd A) S) ^ 2 :=
      lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 hne))
    positivity
  have h := signInd_energy_decomposition hp0 hp1 hA
  linarith

/-- **The grid instance.**  For the horizontal crossing event of the `n × n` grid
at density `1/2`, the variance decomposes exactly into the influence part and the
higher-level Fourier energy. -/
theorem crossing_energy_decomposition (n : ℕ) (hn : 0 < n) :
    4 * (bernProb (1 / 2 : ℝ) (crossingEvent n hn)
        * (1 - bernProb (1 / 2 : ℝ) (crossingEvent n hn)))
      = ∑ v : Fin n × Fin n,
          (bernProb (1 / 2 : ℝ) (pivotalSet (crossingEvent n hn) v)) ^ 2
        + highEnergy (1 / 2 : ℝ) (crossingEvent n hn) := by
  have h := signInd_energy_decomposition (ι := Fin n × Fin n) (p := (1 / 2 : ℝ))
    (by norm_num) (by norm_num) (crossingEvent_isIncreasing n hn)
  norm_num at h ⊢
  linarith

end BernoulliThresholdCoupling