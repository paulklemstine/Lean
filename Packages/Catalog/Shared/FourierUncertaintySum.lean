/-
# Tao's additive uncertainty principle for cyclic groups of prime order

For a nonzero function `f : ZMod p → ℂ` with `p` prime, Tao's uncertainty principle states

  `|supp f| + |supp f̂| ≥ p + 1`.

This is strictly stronger than the classical multiplicative bound
`|supp f| * |supp f̂| ≥ p` (`FourierCyclic.uncertainty_zmod`), which holds for every modulus:
for `p = 13` the pair `|supp f| = |supp f̂| = 4` satisfies `4 * 4 ≥ 13` but violates
`4 + 4 ≥ 14`.  The additive bound genuinely uses primality, via Chebotarev's theorem
(`Chebotarev.det_pow_ne_zero`) that every minor of the prime-order DFT matrix is nonzero.

Main results:

* `FourierCyclic.uncertainty_sum_zmod` : the additive uncertainty principle.
* `FourierCyclic.uncertainty_sum_imp_product` : the additive bound implies the multiplicative one.
* `FourierCyclic.uncertainty_sum_strictly_stronger` : an explicit regime (`p = 13`,
  `|supp f| = |supp f̂| = 4`) allowed by the product bound but excluded by the sum bound.
* `FourierCyclic.uncertainty_sum_sharp_delta`, `uncertainty_sum_sharp_const` : sharpness.
-/

import Mathlib
import Catalog.Shared.FourierCyclic
import Catalog.Shared.ChebotarevMinors

open Finset FourierFA

namespace FourierCyclic

variable {p : ℕ}

/-! ## The root of unity underlying the DFT matrix -/

/-- The primitive `p`-th root of unity `e^{-2πi/p}` appearing in the DFT. -/
noncomputable def zetaNeg (p : ℕ) : ℂ := Complex.exp (-(2 * Real.pi * Complex.I) / p)

theorem zetaNeg_pow (p n : ℕ) :
    (zetaNeg p) ^ n = Complex.exp (-(2 * Real.pi * Complex.I * n) / p) := by
  rw [zetaNeg, ← Complex.exp_nat_mul]
  congr 1
  field_simp

theorem zetaNeg_isPrimitiveRoot (hp : 0 < p) : IsPrimitiveRoot (zetaNeg p) p := by
  have h := Complex.isPrimitiveRoot_exp p (by omega)
  have he : zetaNeg p = (Complex.exp (2 * Real.pi * Complex.I / p))⁻¹ := by
    rw [zetaNeg, ← Complex.exp_neg]
    congr 1
    ring
  rw [he]
  exact h.inv

variable [NeZero p]

/-- The DFT written through the root of unity `ζ = e^{-2πi/p}`. -/
theorem dftZMod_eq_zeta (f : ZMod p → ℂ) (k : ZMod p) :
    dftZMod f k = ∑ x : ZMod p, (zetaNeg p) ^ (k.val * x.val) * f x := by
  rw [dftZMod]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [zetaNeg_pow]
  push_cast
  ring_nf

/-- The DFT only sees the support of `f`. -/
theorem dftZMod_eq_sum_finset (f : ZMod p → ℂ) (k : ZMod p) {S : Finset (ZMod p)}
    (hS : supp f ⊆ S) :
    dftZMod f k = ∑ x ∈ S, (zetaNeg p) ^ (k.val * x.val) * f x := by
  rw [dftZMod_eq_zeta]
  refine (Finset.sum_subset (Finset.subset_univ S) (fun x _ hx => ?_)).symm
  have hfx : f x = 0 := by
    by_contra h0
    exact hx (hS (mem_supp.2 h0))
  rw [hfx, mul_zero]

omit [NeZero p] in
/-- Reindexing a sum over a finset through an enumeration. -/
theorem sum_finset_eq_sum_fin {n : ℕ} (S : Finset (ZMod p)) (e : S ≃ Fin n) (g : ZMod p → ℂ) :
    ∑ x ∈ S, g x = ∑ j : Fin n, g ((e.symm j : S) : ZMod p) := by
  rw [← Finset.sum_coe_sort S g]
  exact (Equiv.sum_comp e.symm (fun x : S => g (x : ZMod p))).symm

/-! ## The additive uncertainty principle -/

/-- **Tao's uncertainty principle.**  For `p` prime and `f : ZMod p → ℂ` nonzero,
`|supp f| + |supp f̂| ≥ p + 1`. -/
theorem uncertainty_sum_zmod (hp : p.Prime) (f : ZMod p → ℂ) (hf : f ≠ 0) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  by_contra hcon
  push_neg at hcon
  set A : Finset (ZMod p) := supp f with hAdef
  set B : Finset (ZMod p) := supp (dftZMod f) with hBdef
  set α : ℕ := A.card with hα
  -- `A` is nonempty because `f ≠ 0`.
  have hAne : A.Nonempty := by
    rcases Function.ne_iff.1 hf with ⟨x, hx⟩
    exact ⟨x, mem_supp.2 (by simpa using hx)⟩
  -- The zero set of `f̂` is large enough to contain `α` points.
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have hcompl : α ≤ (Bᶜ).card := by
    rw [Finset.card_compl, hcard]
    omega
  obtain ⟨T, hTsub, hTcard⟩ := Finset.exists_subset_card_eq hcompl
  -- Enumerate `A` and `T`.
  let eA := A.equivFinOfCardEq hα.symm
  let eT := T.equivFinOfCardEq hTcard
  let v : Fin α → ZMod p := fun j => ((eA.symm j : A) : ZMod p)
  let u : Fin α → ZMod p := fun i => ((eT.symm i : T) : ZMod p)
  have hvinj : Function.Injective v := fun x y h => eA.symm.injective (Subtype.ext h)
  have huinj : Function.Injective u := fun x y h => eT.symm.injective (Subtype.ext h)
  -- The associated exponent vectors.
  set a : Fin α → ℕ := fun i => (u i).val with hadef
  set b : Fin α → ℕ := fun j => (v j).val with hbdef
  have hainj : Function.Injective a := fun x y h => huinj (ZMod.val_injective p h)
  have hbinj : Function.Injective b := fun x y h => hvinj (ZMod.val_injective p h)
  -- Chebotarev: the corresponding minor is nonsingular.
  have hdet : (Matrix.of fun i j => (zetaNeg p) ^ (a i * b j)).det ≠ 0 :=
    Chebotarev.det_pow_ne_zero hp (zetaNeg_isPrimitiveRoot hp.pos) a b
      (fun i => ZMod.val_lt (u i)) (fun j => ZMod.val_lt (v j)) hainj hbinj
  -- But it annihilates the nonzero vector `f|_A`.
  have hmul : (Matrix.of fun i j => (zetaNeg p) ^ (a i * b j)).mulVec (fun j => f (v j)) = 0 := by
    funext i
    have hsum : ∑ j : Fin α, (zetaNeg p) ^ ((u i).val * (v j).val) * f (v j)
        = dftZMod f (u i) := by
      rw [dftZMod_eq_sum_finset f (u i) (le_refl A),
        sum_finset_eq_sum_fin A eA (fun x => (zetaNeg p) ^ ((u i).val * x.val) * f x)]
    have hzero : dftZMod f (u i) = 0 := by
      have hmem : u i ∈ Bᶜ := hTsub (Finset.coe_mem _)
      rw [Finset.mem_compl, hBdef] at hmem
      by_contra h0
      exact hmem (mem_supp.2 h0)
    simp only [Matrix.mulVec, Matrix.of_apply, dotProduct, Pi.zero_apply]
    rw [hadef, hbdef, hsum, hzero]
  have hwne : (fun j => f (v j)) ≠ (0 : Fin α → ℂ) := by
    obtain ⟨x, hx⟩ := hAne
    intro h
    have h2 : f (v (eA ⟨x, hx⟩)) = 0 := congrFun h (eA ⟨x, hx⟩)
    rw [show v (eA ⟨x, hx⟩) = x from by simp [v]] at h2
    exact (mem_supp.1 hx) h2
  exact hdet (Matrix.exists_mulVec_eq_zero_iff.1 ⟨_, hwne, hmul⟩)

/-! ## Comparison with the multiplicative bound -/

/-- The additive bound implies the multiplicative bound `|supp f| * |supp f̂| ≥ p`. -/
theorem uncertainty_sum_imp_product {α β P : ℕ} (hα : 1 ≤ α) (hβ : 1 ≤ β)
    (h : P + 1 ≤ α + β) : P ≤ α * β := by
  nlinarith [Nat.sub_add_cancel hα, Nat.sub_add_cancel hβ]

/-- The multiplicative bound is genuinely weaker: `|supp f| = |supp f̂| = 4` for `p = 13`
satisfies `4 * 4 ≥ 13` but is excluded by the additive bound. -/
theorem uncertainty_sum_strictly_stronger :
    (13 ≤ 4 * 4) ∧ ∀ f : ZMod 13 → ℂ, f ≠ 0 →
      ¬ ((supp f).card = 4 ∧ (supp (dftZMod f)).card = 4) := by
  refine ⟨by norm_num, fun f hf hcon => ?_⟩
  have h := uncertainty_sum_zmod (p := 13) (by norm_num) f hf
  rw [hcon.1, hcon.2] at h
  omega

/-! ## Full sharpness: every admissible splitting is realised -/

/-- **Converse to the additive uncertainty principle.**  For every pair of subsets `A, B` of
`ZMod p` with `|A| + |B| = p + 1` there is a function with support exactly `A` whose Fourier
transform has support exactly `B`.  Hence the bound `p + 1` is attained for *every* admissible
splitting, not just at the two extremes. -/
theorem exists_supp_eq_of_card_add_card (hp : p.Prime) (A B : Finset (ZMod p))
    (hAB : A.card + B.card = p + 1) :
    ∃ f : ZMod p → ℂ, supp f = A ∧ supp (dftZMod f) = B := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have hBle : B.card ≤ p := by simpa [hcard] using Finset.card_le_univ B
  have hAle : A.card ≤ p := by simpa [hcard] using Finset.card_le_univ A
  obtain ⟨m, hm⟩ : ∃ m, A.card = m + 1 := ⟨A.card - 1, by omega⟩
  -- the complement of `B` has exactly `m` elements
  have hZcard : (Bᶜ).card = m := by
    rw [Finset.card_compl, hcard]; omega
  let eZ := (Bᶜ).equivFinOfCardEq hZcard
  let eA := A.equivFinOfCardEq hm
  let z : Fin m → ZMod p := fun i => ((eZ.symm i : (Bᶜ : Finset (ZMod p))) : ZMod p)
  let v : Fin (m + 1) → ZMod p := fun j => ((eA.symm j : A) : ZMod p)
  -- a square system with a zero row: it has a nonzero kernel vector
  let M : Matrix (Fin (m + 1)) (Fin (m + 1)) ℂ := Matrix.of fun i j =>
    if h : (i : ℕ) < m then (zetaNeg p) ^ ((z ⟨i, h⟩).val * (v j).val) else 0
  have hMdet : M.det = 0 := by
    refine Matrix.det_eq_zero_of_row_eq_zero (Fin.last m) fun j => ?_
    simp [M]
  obtain ⟨w, hwne, hw⟩ := Matrix.exists_mulVec_eq_zero_iff.2 hMdet
  -- transport the kernel vector to a function on `ZMod p`
  let f : ZMod p → ℂ := fun x => if h : x ∈ A then w (eA ⟨x, h⟩) else 0
  have hfv : ∀ j, f (v j) = w j := by
    intro j
    have hmem : v j ∈ A := Finset.coe_mem _
    simp only [f, dif_pos hmem]
    congr 1
    exact Equiv.apply_symm_apply eA j
  have hsuppA : supp f ⊆ A := by
    intro x hx
    by_contra hxA
    exact (mem_supp.1 hx) (by simp [f, dif_neg hxA])
  have hfne : f ≠ 0 := by
    rcases Function.ne_iff.1 hwne with ⟨j, hj⟩
    intro h0
    exact hj (by rw [← hfv j, h0]; rfl)
  -- the transform vanishes off `B`
  have hdftzero : ∀ k ∈ Bᶜ, dftZMod f k = 0 := by
    intro k hk
    set i : Fin m := eZ ⟨k, hk⟩ with hi
    have hzk : z i = k := by
      simp only [z, hi, Equiv.symm_apply_apply]
    have hrow := congrFun hw (Fin.castSucc i)
    have hlt : ((Fin.castSucc i : Fin (m + 1)) : ℕ) < m := i.isLt
    have hMrow : ∀ j, M (Fin.castSucc i) j = (zetaNeg p) ^ (k.val * (v j).val) := by
      intro j
      simp only [M, Matrix.of_apply, dif_pos hlt]
      congr 2
      rw [show (⟨(Fin.castSucc i : Fin (m+1)), hlt⟩ : Fin m) = i from rfl, hzk]
    rw [dftZMod_eq_sum_finset f k hsuppA,
      sum_finset_eq_sum_fin A eA (fun x => (zetaNeg p) ^ (k.val * x.val) * f x)]
    have : ∑ j : Fin (m + 1), (zetaNeg p) ^ (k.val * (v j).val) * f (v j) = 0 := by
      simp only [← hMrow, hfv]
      simpa [Matrix.mulVec, dotProduct] using hrow
    exact this
  have hsuppB : supp (dftZMod f) ⊆ B := by
    intro k hk
    by_contra hkB
    exact (mem_supp.1 hk) (hdftzero k (Finset.mem_compl.2 hkB))
  -- the uncertainty principle now forces both supports to be full
  have hlow := uncertainty_sum_zmod hp f hfne
  have h1 := Finset.card_le_card hsuppA
  have h2 := Finset.card_le_card hsuppB
  refine ⟨f, Finset.eq_of_subset_of_card_le hsuppA (by omega),
    Finset.eq_of_subset_of_card_le hsuppB (by omega)⟩

/-! ## Sharpness -/

/-- The Dirac delta attains equality in the additive uncertainty principle. -/
theorem uncertainty_sum_sharp_delta (hp : p.Prime) (c : ZMod p) :
    (supp (delta c)).card + (supp (dftZMod (delta c))).card = p + 1 := by
  have hne : (delta c : ZMod p → ℂ) ≠ 0 := by
    intro h
    have h2 : (delta c : ZMod p → ℂ) c = 0 := by rw [h]; rfl
    simp [delta] at h2
  have hlow := uncertainty_sum_zmod hp (delta c) hne
  have hprod := uncertainty_zmod_sharp (n := p) c
  have hd : (supp (delta c : ZMod p → ℂ)).card = 1 := by
    have hs : supp (delta c : ZMod p → ℂ) = {c} := by
      ext x
      simp only [mem_supp, Finset.mem_singleton, delta]
      constructor
      · intro h; by_contra hxc; simp [hxc] at h
      · intro h; simp [h]
    rw [hs, Finset.card_singleton]
  rw [hd, one_mul] at hprod
  omega

/-- A constant function attains equality in the additive uncertainty principle: its
transform is supported at the single frequency `0`. -/
theorem uncertainty_sum_sharp_const (hp : p.Prime) :
    (supp (fun _ : ZMod p => (1 : ℂ))).card + (supp (dftZMod (fun _ : ZMod p => (1 : ℂ)))).card
      = p + 1 := by
  have hne : (fun _ : ZMod p => (1 : ℂ)) ≠ 0 := by
    intro h
    exact one_ne_zero (congrFun h 0)
  have hlow := uncertainty_sum_zmod hp _ hne
  have hsupp : (supp (fun _ : ZMod p => (1 : ℂ))) = Finset.univ := by
    ext x; simp [mem_supp]
  -- the transform of the constant function vanishes off the zero frequency
  have hzero : ∀ k : ZMod p, k ≠ 0 → dftZMod (fun _ : ZMod p => (1 : ℂ)) k = 0 := by
    intro k hk
    rw [dftZMod_eq (n := p), dft]
    have hchr0 : (chr (0 : ZMod p)) = 1 := by
      simp only [chr, map_zero]
      ext x
      simp
    have hchr : chr k ≠ 1 := by
      intro h
      exact hk (chr_injective (by rw [h, hchr0]))
    have : ∑ x : ZMod p, (starRingEnd ℂ) (chr k x) = 0 := by
      rw [← map_sum]
      rw [AddChar.sum_eq_zero_of_ne_one hchr]
      simp
    simpa using this
  have hle : (supp (dftZMod (fun _ : ZMod p => (1 : ℂ)))).card ≤ 1 := by
    have hsub : supp (dftZMod (fun _ : ZMod p => (1 : ℂ))) ⊆ {0} := by
      intro k hk
      rw [Finset.mem_singleton]
      by_contra h0
      exact (mem_supp.1 hk) (hzero k h0)
    simpa using Finset.card_le_card hsub
  rw [hsupp, Finset.card_univ, ZMod.card] at hlow ⊢
  omega

end FourierCyclic