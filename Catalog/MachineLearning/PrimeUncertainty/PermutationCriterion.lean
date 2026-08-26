/-
# A purely combinatorial criterion for Chebotarev's theorem

The Leibniz expansion of a minor of the DFT matrix of `ZMod p`,

`det (ω^{S j · T k})_{j,k} = ∑_{σ} sgn(σ) · ω^{E_σ}`,  `E_σ = ∑_j S (σ j) · T j ∈ ZMod p`,

is a signed sum of `p`-th roots of unity whose coefficients sum to `0` (for `n ≥ 2`).  By the
linear-independence lemma `rat_coeffs_const_of_sum_ez_eq_zero` such a sum vanishes **iff** every
parity-weighted exponent multiplicity vanishes.  This turns Chebotarev's theorem — equivalently,
by `chebotarev_iff_sumUncertainty`, Tao's additive uncertainty principle — into the finite
combinatorial statement

> for distinct `S` and distinct `T` there is a residue `r` hit by unequally many even and odd
> permutations, counted through `E_σ`.

`PrimeUncertainty.chebotarev_criterion` is exactly this equivalence, and
`PrimeUncertainty.det_ez_ne_zero_of_unique_perm` is the practical sufficient condition (some
permutation realising its exponent uniquely) that settles the `2 × 2` and `3 × 3` cases.
-/

import Mathlib
import MachineLearning.PrimeUncertainty.Chebotarev3

open Finset Polynomial FourierFA FourierCyclic
open scoped Real

namespace PrimeUncertainty

variable {p : ℕ}

section Criterion

variable [hp : Fact p.Prime] {n : ℕ}

/-- The character property in product form. -/
theorem ez_sum {ι : Type*} (s : Finset ι) (g : ι → ZMod p) :
    ez (∑ i ∈ s, g i) = ∏ i ∈ s, ez (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih => rw [Finset.sum_insert ha, Finset.prod_insert ha, ez_add, ih]

/-- The exponent attached to a permutation in the Leibniz expansion. -/
def permExp (S T : Fin n → ZMod p) (σ : Equiv.Perm (Fin n)) : ZMod p := ∑ j, S (σ j) * T j

/-- The parity-weighted multiplicity of a residue among the permutation exponents. -/
noncomputable def permCoeff (S T : Fin n → ZMod p) (r : ZMod p) : ℚ :=
  ∑ σ : Equiv.Perm (Fin n), if permExp S T σ = r then (Equiv.Perm.sign σ : ℚ) else 0

/-- **Leibniz expansion of a DFT minor** as a signed sum of roots of unity. -/
theorem det_ez_eq_sum_permCoeff (S T : Fin n → ZMod p) :
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det
      = ∑ r : ZMod p, (permCoeff S T r : ℂ) * ez r := by
  classical
  have hdet : (Matrix.of fun j k : Fin n => ez (S j * T k)).det
      = ∑ σ : Equiv.Perm (Fin n), ((Equiv.Perm.sign σ : ℤ) : ℂ) * ez (permExp S T σ) := by
    rw [Matrix.det_apply]
    refine Finset.sum_congr rfl fun σ _ => ?_
    rw [permExp, ez_sum]
    simp [Units.smul_def]
  rw [hdet]
  simp only [permCoeff]
  have hswap : ∑ r : ZMod p, ((∑ σ : Equiv.Perm (Fin n),
        if permExp S T σ = r then (Equiv.Perm.sign σ : ℚ) else 0 : ℚ) : ℂ) * ez r
      = ∑ σ : Equiv.Perm (Fin n), ∑ r : ZMod p,
          (if permExp S T σ = r then ((Equiv.Perm.sign σ : ℤ) : ℂ) else 0) * ez r := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun r _ => ?_
    push_cast
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl fun σ _ => ?_
    split_ifs <;> simp
  rw [hswap]
  refine Finset.sum_congr rfl fun σ _ => ?_
  rw [Finset.sum_eq_single_of_mem (permExp S T σ) (Finset.mem_univ _)]
  · simp
  · intro r _ hr
    simp [Ne.symm hr]

/-- For `n ≥ 2` the signed multiplicities sum to zero (half the permutations are even). -/
theorem sum_permCoeff_eq_zero (S T : Fin n → ZMod p) (hn : 2 ≤ n) :
    ∑ r : ZMod p, permCoeff S T r = 0 := by
  classical
  have hsigns : ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ) = 0 := by
    have h01 : (⟨0, by omega⟩ : Fin n) ≠ ⟨1, by omega⟩ := by
      simp [Fin.ext_iff]
    set τ : Equiv.Perm (Fin n) := Equiv.swap ⟨0, by omega⟩ ⟨1, by omega⟩ with hτ
    have hsgnτ : (Equiv.Perm.sign τ : ℚ) = -1 := by
      rw [hτ, Equiv.Perm.sign_swap h01]
      simp
    have hshift : ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ)
        = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign (σ * τ) : ℚ) :=
      (Fintype.sum_equiv (Equiv.mulRight τ) _ _ (fun σ => rfl)).symm
    have hneg : ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign (σ * τ) : ℚ)
        = -∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ) := by
      rw [← Finset.sum_neg_distrib]
      refine Finset.sum_congr rfl fun σ _ => ?_
      rw [map_mul]
      push_cast
      rw [hsgnτ]
      ring
    rw [hneg] at hshift
    linarith
  calc ∑ r : ZMod p, permCoeff S T r
      = ∑ σ : Equiv.Perm (Fin n), ∑ r : ZMod p,
          (if permExp S T σ = r then (Equiv.Perm.sign σ : ℚ) else 0) := by
        simp only [permCoeff]
        exact Finset.sum_comm
    _ = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ) := by
        refine Finset.sum_congr rfl fun σ _ => ?_
        rw [Finset.sum_eq_single_of_mem (permExp S T σ) (Finset.mem_univ _)]
        · simp
        · intro r _ hr
          simp [Ne.symm hr]
    _ = 0 := hsigns

/-- **The combinatorial criterion for Chebotarev's theorem.**  For `n ≥ 2` a minor of the DFT
matrix of `ZMod p` is nonsingular exactly when some residue is hit by unequally many even and
odd permutations through the exponent map `σ ↦ ∑_j S (σ j) T j`. -/
theorem chebotarev_criterion (S T : Fin n → ZMod p) (hn : 2 ≤ n) :
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det ≠ 0 ↔ ∃ r : ZMod p, permCoeff S T r ≠ 0 := by
  rw [det_ez_eq_sum_permCoeff]
  constructor
  · intro hne
    by_contra hall
    push_neg at hall
    exact hne (Finset.sum_eq_zero fun r _ => by rw [hall r]; simp)
  · rintro ⟨r, hr⟩
    exact sum_ez_ne_zero_of_coeff_ne_zero _ (sum_permCoeff_eq_zero S T hn) hr

/-- A practical sufficient condition: if some permutation realises its exponent uniquely, the
minor is nonsingular.  (Computationally this always happens for `n ≤ 3`, but it can fail for
`n ≥ 4`, which is precisely where the general theorem becomes hard.) -/
theorem det_ez_ne_zero_of_unique_perm (S T : Fin n → ZMod p) (hn : 2 ≤ n)
    (σ₀ : Equiv.Perm (Fin n))
    (huniq : ∀ σ : Equiv.Perm (Fin n), permExp S T σ = permExp S T σ₀ → σ = σ₀) :
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det ≠ 0 := by
  classical
  refine (chebotarev_criterion S T hn).2 ⟨permExp S T σ₀, ?_⟩
  have hval : permCoeff S T (permExp S T σ₀) = (Equiv.Perm.sign σ₀ : ℚ) := by
    simp only [permCoeff]
    rw [Finset.sum_eq_single_of_mem σ₀ (Finset.mem_univ _)]
    · simp
    · intro σ _ hσ
      exact if_neg fun h => hσ (huniq σ h)
  rw [hval]
  rcases Int.units_eq_one_or (Equiv.Perm.sign σ₀) with h | h <;> rw [h] <;> norm_num

omit hp in
/-- The parity-weighted multiplicity is the integer signed count of the fibre of the exponent
map over `r`. -/
theorem permCoeff_eq_intCast (S T : Fin n → ZMod p) (r : ZMod p) :
    permCoeff S T r
      = ((∑ σ ∈ Finset.univ.filter (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r),
            (Equiv.Perm.sign σ : ℤ) : ℤ) : ℚ) := by
  classical
  simp only [permCoeff, Finset.sum_filter]
  push_cast
  refine Finset.sum_congr rfl fun σ _ => ?_
  split <;> simp

omit hp in
/-- **Parity criterion.**  If the exponent map hits a residue an odd number of times, the
parity-weighted multiplicity there cannot vanish: a signed sum of an odd number of `±1`'s is
odd.  This strictly generalises the uniqueness condition (a fibre of size `1`). -/
theorem permCoeff_ne_zero_of_odd_fiber (S T : Fin n → ZMod p) (r : ZMod p)
    (hodd : Odd (Finset.univ.filter
      (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r)).card) :
    permCoeff S T r ≠ 0 := by
  classical
  set s := Finset.univ.filter (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r)
  have hmod : (∑ σ ∈ s, (Equiv.Perm.sign σ : ℤ)) % 2 = (s.card : ℤ) % 2 := by
    rw [Finset.sum_int_mod]
    congr 1
    have : ∀ σ ∈ s, ((Equiv.Perm.sign σ : ℤ)) % 2 = 1 := by
      intro σ _
      rcases Int.units_eq_one_or (Equiv.Perm.sign σ) with h | h <;> rw [h] <;> decide
    rw [Finset.sum_congr rfl this]
    simp
  have hcard : (s.card : ℤ) % 2 = 1 := by
    obtain ⟨k, hk⟩ := hodd
    rw [hk]
    push_cast
    omega
  have hne : (∑ σ ∈ s, (Equiv.Perm.sign σ : ℤ)) ≠ 0 := by
    intro h
    rw [h, hcard] at hmod
    simp at hmod
  rw [permCoeff_eq_intCast]
  exact_mod_cast hne

/-- A DFT minor is nonsingular as soon as some residue is realised by an odd number of
permutations. -/
theorem det_ez_ne_zero_of_odd_fiber (S T : Fin n → ZMod p) (hn : 2 ≤ n) (r : ZMod p)
    (hodd : Odd (Finset.univ.filter
      (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r)).card) :
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det ≠ 0 :=
  (chebotarev_criterion S T hn).2 ⟨r, permCoeff_ne_zero_of_odd_fiber S T r hodd⟩

end Criterion

end PrimeUncertainty