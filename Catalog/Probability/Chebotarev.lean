/-
# Conjecture A: the parity gap of the exponent counter never closes

Let `p` be a prime, `n ≥ 0`, and let `S, T : Fin n → ZMod p` be injective.  Attached to a
permutation `σ` of `Fin n` is the exponent `E_σ = ∑_j S (σ j) * T j ∈ ZMod p`
(`PrimeUncertainty.permExp`), and the *parity-weighted exponent counter*

  `permCoeff S T r = ∑_{σ : E_σ = r} sgn σ`

(`PrimeUncertainty.permCoeff`) records the excess of even over odd permutations realising the
residue `r`.  **Conjecture A** asserts that this counter is nonzero somewhere; equivalently, that
the corresponding minor of the DFT matrix of `ZMod p` is nonsingular (Chebotarev's theorem).

This file proves it.  The proof is entirely self-contained apart from `Mathlib`:

1. Work in `ParityGap.CycRing p = ℤ[X]/(Φ_p)`, an honest characteristic-zero model of `ℤ[ζ_p]`
   (see `Catalog.Probability.ParityGap.CyclotomicRing`), and form the matrix
   `M j k = ζ ^ (S j * T k)`.
2. If `det M = 0`, the matrix has a nonzero kernel vector over the domain `CycRing p`; after
   dividing by the largest possible power of the ramified prime `π = ζ - 1`
   (`ParityGap.exists_primitive_scaling`) at least one coordinate `w k` survives the reduction
   `red : ℤ[ζ_p] → 𝔽_p`, `ζ ↦ 1`.
3. The polynomial `f = ∑_k w k · X ^ (T k).val` vanishes at the `n` pairwise distinct points
   `ζ ^ (S j).val`, so `∏_j (X - ζ ^ (S j).val)` divides `f`.  Reducing mod `π` turns every
   factor into `X - 1`, so `(X - 1) ^ n` divides the reduced polynomial `f̄ ≠ 0`, which has at
   most `n` terms and degree `< p`.
4. That contradicts `ParityGap.lt_card_support_of_X_sub_one_pow_dvd`.

Main results:

* `ParityGap.det_zetaPow_ne_zero` — Chebotarev's theorem over `ℤ[ζ_p]`;
* `ParityGap.exists_permCoeff_ne_zero` — **Conjecture A** (the parity gap never closes);
* `ParityGap.exists_minimal_length_witness` — the sharpening asked for in Conjecture A: the
  witnessing residue is realised by a permutation of minimal Coxeter length in its fibre;
* `ParityGap.det_ez_ne_zero` — Chebotarev's theorem for the complex DFT minors of the catalog.
-/

import Mathlib
import Probability.SupportMultiplicity
import Probability.CyclotomicRing
import MachineLearning.PrimeUncertainty.PermutationCriterion

open Polynomial Finset

namespace ParityGap

variable {p : ℕ} [hp : Fact p.Prime] {n : ℕ}

/-! ## The character `r ↦ ζ ^ r` of `ZMod p` with values in `ℤ[ζ_p]` -/

/-- The canonical character `ZMod p → ℤ[ζ_p]`, `r ↦ ζ ^ r`. -/
noncomputable def zpow (p : ℕ) [Fact p.Prime] (r : ZMod p) : CycRing p := zeta p ^ r.val

theorem zeta_pow_mod (k : ℕ) : zeta p ^ (k % p) = zeta p ^ k := by
  have h : zeta p ^ (k % orderOf (zeta p)) = zeta p ^ k := pow_mod_orderOf _ _
  rwa [orderOf_zeta p] at h

@[simp] theorem zpow_zero_eq_one : zpow p 0 = 1 := by
  simp [zpow]

theorem zpow_add (a b : ZMod p) : zpow p (a + b) = zpow p a * zpow p b := by
  have hval : (a + b).val = (a.val + b.val) % p := ZMod.val_add a b
  rw [zpow, zpow, zpow, hval, zeta_pow_mod, pow_add]

theorem zpow_mul_eq (a b : ZMod p) : zpow p (a * b) = zeta p ^ (a.val * b.val) := by
  have hval : (a * b).val = (a.val * b.val) % p := ZMod.val_mul a b
  rw [zpow, hval, zeta_pow_mod]

theorem zpow_sum {ι : Type*} (s : Finset ι) (g : ι → ZMod p) :
    zpow p (∑ i ∈ s, g i) = ∏ i ∈ s, zpow p (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih => rw [Finset.sum_insert ha, Finset.prod_insert ha, zpow_add, ih]

/-- Powers `ζ ^ r` for distinct residues `r` are distinct. -/
theorem zpow_injective : Function.Injective (zpow p) := by
  intro a b hab
  have := zeta_pow_injective p (ZMod.val_lt a) (ZMod.val_lt b) hab
  exact (ZMod.val_injective p) this

@[simp] theorem red_zpow (r : ZMod p) : red p (zpow p r) = 1 := by
  simp [zpow]

/-! ## Chebotarev's theorem over `ℤ[ζ_p]` -/

/-- A polynomial with distinct roots is divisible by the product of the corresponding linear
factors (valid over any integral domain). -/
theorem prod_X_sub_C_dvd_of_eval_eq_zero {R : Type*} [CommRing R] [IsDomain R]
    (s : Finset R) : ∀ f : R[X], (∀ z ∈ s, f.eval z = 0) → (∏ z ∈ s, (X - C z)) ∣ f := by
  classical
  induction s using Finset.induction with
  | empty => intro f _; simp
  | @insert a s ha ih =>
    intro f h
    have hfa : f.eval a = 0 := h a (Finset.mem_insert_self a s)
    obtain ⟨g, hg⟩ := (dvd_iff_isRoot).mpr hfa
    have hgz : ∀ z ∈ s, g.eval z = 0 := by
      intro z hz
      have hz' : f.eval z = 0 := h z (Finset.mem_insert_of_mem hz)
      rw [hg] at hz'
      simp only [eval_mul, eval_sub, eval_X, eval_C] at hz'
      rcases mul_eq_zero.mp hz' with h1 | h2
      · have hza : z = a := sub_eq_zero.mp h1
        exact absurd (hza ▸ hz) ha
      · exact h2
    obtain ⟨q, hq⟩ := ih g hgz
    refine ⟨q, ?_⟩
    rw [Finset.prod_insert ha, hg, hq]
    ring

/-- **Chebotarev's theorem, integral form.**  For injective `S, T : Fin n → ZMod p` the matrix
`(ζ ^ (S j * T k))` is nonsingular over `ℤ[ζ_p]`. -/
theorem det_zetaPow_ne_zero (S T : Fin n → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    (Matrix.of fun j k : Fin n => zpow p (S j * T k)).det ≠ 0 := by
  classical
  intro hdet
  set M : Matrix (Fin n) (Fin n) (CycRing p) := Matrix.of fun j k => zpow p (S j * T k) with hM
  -- a nonzero kernel vector over the domain `ℤ[ζ_p]`
  obtain ⟨v, hv, hvker⟩ := Matrix.exists_mulVec_eq_zero_iff.mpr hdet
  have hvne : ∃ k, v k ≠ 0 := by
    by_contra hall
    push_neg at hall
    exact hv (funext hall)
  -- scale so that some coordinate survives reduction mod `π`
  obtain ⟨m, w, hvw, i₀, hi₀⟩ := exists_primitive_scaling p v hvne
  have hrel : ∀ j : Fin n, ∑ k, w k * zeta p ^ ((S j).val * (T k).val) = 0 := by
    intro j
    have hj : ∑ k, zpow p (S j * T k) * v k = 0 := congrFun hvker j
    have hj' : pi p ^ m * ∑ k, w k * zeta p ^ ((S j).val * (T k).val) = 0 := by
      rw [Finset.mul_sum, ← hj]
      refine Finset.sum_congr rfl fun k _ => ?_
      rw [hvw k, zpow_mul_eq]
      ring
    rcases mul_eq_zero.mp hj' with h1 | h2
    · exact absurd h1 (pow_ne_zero _ (pi_ne_zero p))
    · exact h2
  -- the sparse polynomial with coefficients `w`
  set f : (CycRing p)[X] := ∑ k, C (w k) * X ^ (T k).val with hf
  have hroots : ∀ j : Fin n, f.eval (zeta p ^ (S j).val) = 0 := by
    intro j
    rw [hf]
    simp only [eval_finset_sum, eval_mul, eval_C, eval_pow, eval_X]
    rw [← hrel j]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [← pow_mul]
  -- the `n` evaluation points are pairwise distinct
  set Z : Finset (CycRing p) := Finset.image (fun j : Fin n => zeta p ^ (S j).val) univ with hZ
  have hZinj : Function.Injective (fun j : Fin n => zeta p ^ (S j).val) := by
    intro j₁ j₂ h
    have := zeta_pow_injective p (ZMod.val_lt (S j₁)) (ZMod.val_lt (S j₂)) h
    exact hS (ZMod.val_injective p this)
  have hZcard : Z.card = n := by
    rw [hZ, Finset.card_image_of_injective _ hZinj, Finset.card_univ, Fintype.card_fin]
  have hdvd : (∏ z ∈ Z, (X - C z)) ∣ f := by
    refine prod_X_sub_C_dvd_of_eval_eq_zero Z f ?_

    intro z hz
    obtain ⟨j, -, rfl⟩ := Finset.mem_image.mp hz
    exact hroots j
  -- reduce modulo `π`
  set fbar : (ZMod p)[X] := f.map (red p) with hfbar
  have hdvdbar : ((X : (ZMod p)[X]) - 1) ^ n ∣ fbar := by
    have hmapdvd : ((∏ z ∈ Z, (X - C z)).map (red p)) ∣ fbar := Polynomial.map_dvd _ hdvd
    have hprod : (∏ z ∈ Z, (X - C z)).map (red p) = ((X : (ZMod p)[X]) - 1) ^ n := by
      rw [Polynomial.map_prod]
      have hterm : ∀ z ∈ Z, ((X : (CycRing p)[X]) - C z).map (red p)
          = (X : (ZMod p)[X]) - 1 := by
        intro z hz
        obtain ⟨j, -, rfl⟩ := Finset.mem_image.mp hz
        have : red p (zeta p ^ (S j).val) = 1 := by
          rw [map_pow, red_zeta, one_pow]
        rw [Polynomial.map_sub, Polynomial.map_X, Polynomial.map_C, this, map_one]
      rw [Finset.prod_congr rfl hterm, Finset.prod_const, hZcard]
    rwa [hprod] at hmapdvd
  have hfbar_eq : fbar = ∑ k, C (red p (w k)) * X ^ (T k).val := by
    rw [hfbar, hf, Polynomial.map_sum]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [Polynomial.map_mul, Polynomial.map_C, Polynomial.map_pow, Polynomial.map_X]
  -- `f̄` is nonzero, sparse and of small degree
  have hcoeff : ∀ l : Fin n, fbar.coeff (T l).val = red p (w l) := by
    intro l
    rw [hfbar_eq, Polynomial.finset_sum_coeff]
    rw [Finset.sum_eq_single l]
    · simp [coeff_C_mul, coeff_X_pow]
    · intro k _ hk
      have hne : (T k).val ≠ (T l).val := fun h => hk (hT (ZMod.val_injective p h))
      simp [coeff_C_mul, coeff_X_pow, Ne.symm hne]
    · intro h; exact absurd (Finset.mem_univ l) h
  have hfbar_ne : fbar ≠ 0 := by
    intro h0
    have := hcoeff i₀
    rw [h0] at this
    simp only [coeff_zero] at this
    exact hi₀ this.symm
  have hdeg : fbar.natDegree < p := by
    have hle : fbar.natDegree ≤ p - 1 := by
      rw [hfbar_eq]
      refine Polynomial.natDegree_sum_le_of_forall_le _ _ fun k _ => ?_
      refine le_trans (Polynomial.natDegree_C_mul_le _ _) ?_
      rw [Polynomial.natDegree_X_pow]
      have := ZMod.val_lt (T k)
      omega
    have := hp.out.two_le
    omega
  have hcard : fbar.support.card ≤ n := by
    have hsub : fbar.support ⊆ Finset.image (fun k : Fin n => (T k).val) univ := by
      intro l hl
      rw [mem_support_iff, hfbar_eq, Polynomial.finset_sum_coeff] at hl
      by_contra hnot
      apply hl
      refine Finset.sum_eq_zero fun k _ => ?_
      have hne : (T k).val ≠ l := by
        intro h
        exact hnot (Finset.mem_image.mpr ⟨k, Finset.mem_univ k, h⟩)
      simp [coeff_C_mul, coeff_X_pow, Ne.symm hne]
    calc fbar.support.card ≤ (Finset.image (fun k : Fin n => (T k).val) univ).card :=
          Finset.card_le_card hsub
      _ ≤ (univ : Finset (Fin n)).card := Finset.card_image_le
      _ = n := by simp
  have := lt_card_support_of_X_sub_one_pow_dvd n fbar hfbar_ne hdeg hdvdbar
  omega

/-! ## Conjecture A -/

open PrimeUncertainty in
/-- The Leibniz expansion of the integral DFT minor in terms of the parity-weighted counter. -/
theorem det_zetaPow_eq_sum_permCoeff (S T : Fin n → ZMod p) :
    (Matrix.of fun j k : Fin n => zpow p (S j * T k)).det
      = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℤ) • zpow p (permExp S T σ) := by
  classical
  rw [Matrix.det_apply]
  refine Finset.sum_congr rfl fun σ _ => ?_
  rw [permExp, zpow_sum]
  simp [Units.smul_def]

open PrimeUncertainty in
/-- **Conjecture A (parity-gap conjecture).**  For injective `S, T : Fin n → ZMod p` the
parity-weighted exponent counter is nonzero at some residue: some residue is realised by
unequally many even and odd permutations. -/
theorem exists_permCoeff_ne_zero (S T : Fin n → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    ∃ r : ZMod p, permCoeff S T r ≠ 0 := by
  classical
  by_contra hall
  push_neg at hall
  refine det_zetaPow_ne_zero S T hS hT ?_
  -- group the permutations according to their exponent
  have hsplit : ∑ r : ZMod p, (∑ σ ∈ univ.filter (fun σ : Equiv.Perm (Fin n) =>
        permExp S T σ = r), (Equiv.Perm.sign σ : ℤ)) • zpow p r
      = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℤ) • zpow p (permExp S T σ) := by
    have hterm : ∀ r : ZMod p, (∑ σ ∈ univ.filter (fun σ : Equiv.Perm (Fin n) =>
          permExp S T σ = r), (Equiv.Perm.sign σ : ℤ)) • zpow p r
        = ∑ σ : Equiv.Perm (Fin n),
            if permExp S T σ = r then (Equiv.Perm.sign σ : ℤ) • zpow p r else 0 := by
      intro r
      rw [Finset.sum_filter, Finset.sum_smul]
      refine Finset.sum_congr rfl fun σ _ => ?_
      split_ifs <;> simp
    rw [Finset.sum_congr rfl fun r _ => hterm r, Finset.sum_comm]
    refine Finset.sum_congr rfl fun σ _ => ?_
    rw [Finset.sum_eq_single (permExp S T σ)]
    · simp
    · intro r _ hr; simp [Ne.symm hr]
    · intro h; exact absurd (Finset.mem_univ (permExp S T σ)) h
  rw [det_zetaPow_eq_sum_permCoeff, ← hsplit]
  refine Finset.sum_eq_zero fun r _ => ?_
  have h0 : ((∑ σ ∈ univ.filter (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r),
      (Equiv.Perm.sign σ : ℤ) : ℤ) : ℚ) = 0 := by
    rw [← permCoeff_eq_intCast]
    exact hall r
  have hz : (∑ σ ∈ univ.filter (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r),
      (Equiv.Perm.sign σ : ℤ)) = 0 := by exact_mod_cast h0
  rw [hz, zero_smul]

open PrimeUncertainty in
/-- **The sharpening of Conjecture A.**  The witnessing residue is of the form `∑_j S (σ j) T j`,
and `σ` may be chosen of minimal Coxeter length (number of inversions, `Equiv.Perm.length`
being measured here by `Finset.card` of the inversion set) among all permutations realising the
same exponent. -/
theorem exists_minimal_length_witness (S T : Fin n → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) (len : Equiv.Perm (Fin n) → ℕ) :
    ∃ σ : Equiv.Perm (Fin n), permCoeff S T (permExp S T σ) ≠ 0 ∧
      ∀ τ : Equiv.Perm (Fin n), permExp S T τ = permExp S T σ → len σ ≤ len τ := by
  classical
  obtain ⟨r, hr⟩ := exists_permCoeff_ne_zero S T hS hT
  -- the fibre over `r` is nonempty, otherwise the counter would vanish there
  have hfib : (univ.filter (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r)).Nonempty := by
    rw [Finset.nonempty_iff_ne_empty]
    intro hempty
    apply hr
    rw [permCoeff_eq_intCast, hempty]
    simp
  -- choose an element of the fibre with minimal length
  obtain ⟨σ₀, hσ₀mem, hσ₀min⟩ := Finset.exists_min_image _ len hfib
  have hσ₀ : permExp S T σ₀ = r := (Finset.mem_filter.mp hσ₀mem).2
  refine ⟨σ₀, by rw [hσ₀]; exact hr, fun τ hτ => ?_⟩
  refine hσ₀min τ ?_
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ τ, by rw [hτ, hσ₀]⟩

open PrimeUncertainty in
/-- **Chebotarev's theorem** in the analytic normalisation of the catalog: every minor of the
DFT matrix of `ZMod p` with distinct rows and distinct columns is nonsingular. -/
theorem det_ez_ne_zero (S T : Fin n → ZMod p) (hn : 2 ≤ n) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det ≠ 0 :=
  (chebotarev_criterion S T hn).2 (exists_permCoeff_ne_zero S T hS hT)

end ParityGap