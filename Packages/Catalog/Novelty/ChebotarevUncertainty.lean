/-
# Consequences of Chebotarev's theorem: the prime-order uncertainty principle

Building on `ChebotarevDFT.det_ne_zero` (every square submatrix of the `p × p` DFT matrix is
nonsingular for `p` prime) we derive:

* `ChebotarevDFT.uncertainty` : Tao's uncertainty principle, `#supp Φ + #supp (𝓕 Φ) ≥ p + 1`
  for every nonzero `Φ : ZMod p → ℂ`;
* `ChebotarevDFT.uncertainty_sharp_delta` : the bound is attained by a Dirac mass;
* `ChebotarevDFT.sparse_recovery` : a `k`-sparse signal on `ZMod p` is determined by *any*
  `2 * k` of its Fourier coefficients (exact recovery in compressed sensing);
* `ChebotarevDFT.singular_submatrix_of_composite` : for the composite modulus `4` the analogous
  statement fails, so primality is essential.
-/
import Mathlib
import Novelty.ChebotarevDFT

namespace ChebotarevDFT

open Finset Matrix Complex ZMod
open scoped ZMod

variable {p : ℕ} [NeZero p]

/-- The support of a function on `ZMod p`. -/
noncomputable def supp (Φ : ZMod p → ℂ) : Finset (ZMod p) :=
  Finset.univ.filter fun x => Φ x ≠ 0

theorem mem_supp {Φ : ZMod p → ℂ} {x : ZMod p} : x ∈ supp Φ ↔ Φ x ≠ 0 := by
  simp [supp]

/-! ## The standard additive character as a power of a primitive root -/

/-- `stdAddChar (-1)` is a primitive `p`-th root of unity. -/
theorem isPrimitiveRoot_stdAddChar (p : ℕ) [NeZero p] :
    IsPrimitiveRoot (ZMod.stdAddChar (-1 : ZMod p)) p := by
  have h : ZMod.stdAddChar (-1 : ZMod p)
      = Complex.exp (2 * Real.pi * Complex.I * (-1 : ℤ) / p) := by
    rw [← ZMod.stdAddChar_coe]; norm_num
  rw [h, show (2 * (Real.pi : ℂ) * Complex.I * (-1 : ℤ) / p)
      = -(2 * Real.pi * Complex.I / p) by push_cast; ring, Complex.exp_neg]
  exact (Complex.isPrimitiveRoot_exp p (NeZero.ne p)).inv

/-- The kernel of the discrete Fourier transform is a power of `stdAddChar (-1)`. -/
theorem stdAddChar_neg_mul (p : ℕ) [NeZero p] (x k : ZMod p) :
    ZMod.stdAddChar (-(x * k)) = (ZMod.stdAddChar (-1 : ZMod p)) ^ (x.val * k.val) := by
  rw [← AddChar.map_nsmul_eq_pow]
  congr 1
  push_cast [nsmul_eq_mul]
  rw [ZMod.natCast_zmod_val, ZMod.natCast_zmod_val]
  ring

/-! ## The uncertainty principle -/

/-- **Tao's uncertainty principle for cyclic groups of prime order.** If `Φ : ZMod p → ℂ` is
nonzero and `p` is prime, then the supports of `Φ` and of its discrete Fourier transform
together have at least `p + 1` elements. -/
theorem uncertainty (hp : p.Prime) (Φ : ZMod p → ℂ) (hΦ : Φ ≠ 0) :
    p + 1 ≤ (supp Φ).card + (supp (𝓕 Φ)).card := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  by_contra hcon
  push_neg at hcon
  set A := supp Φ with hA
  set k := A.card with hk
  have hk1 : 1 ≤ k := by
    rw [hk, Nat.one_le_iff_ne_zero, ← Nat.pos_iff_ne_zero, Finset.card_pos]
    obtain ⟨x, hx⟩ := Function.ne_iff.mp hΦ
    exact ⟨x, mem_supp.mpr hx⟩
  have hcompl : k ≤ ((supp (𝓕 Φ))ᶜ).card := by
    rw [Finset.card_compl, ZMod.card]
    omega
  obtain ⟨B, hBsub, hBcard⟩ := Finset.exists_subset_card_eq hcompl
  -- enumerate the two sets
  set eA : {x // x ∈ A} ≃ Fin k := A.equivFin with heA
  set eB : {x // x ∈ B} ≃ Fin k := B.equivFin.trans (finCongr hBcard) with heB
  set α : Fin k → ZMod p := fun i => (eA.symm i : ZMod p) with hα
  set β : Fin k → ZMod p := fun j => (eB.symm j : ZMod p) with hβ
  have hαmem : ∀ i, α i ∈ A := fun i => (eA.symm i).2
  have hβmem : ∀ j, β j ∈ B := fun j => (eB.symm j).2
  have hαinj : Function.Injective α := by
    intro i₁ i₂ h
    exact eA.symm.injective (Subtype.ext h)
  have hβinj : Function.Injective β := by
    intro j₁ j₂ h
    exact eB.symm.injective (Subtype.ext h)
  -- the associated integer data
  set a : Fin k → ℕ := fun i => (α i).val with ha
  set b : Fin k → ℕ := fun j => (β j).val with hb
  have hainj : Function.Injective a := fun i₁ i₂ h => hαinj ((ZMod.val_injective p) h)
  have hbinj : Function.Injective b := fun j₁ j₂ h => hβinj ((ZMod.val_injective p) h)
  have halt : ∀ i, a i < p := fun i => ZMod.val_lt _
  have hblt : ∀ j, b j < p := fun j => ZMod.val_lt _
  -- Chebotarev: the submatrix is nonsingular
  have hdet := det_ne_zero (n := k) (p := p) hp (isPrimitiveRoot_stdAddChar p) a b
    hainj halt hbinj hblt
  -- the restriction of `Φ` is in the kernel
  set v : Fin k → ℂ := fun i => Φ (α i) with hv
  have hvec : v ᵥ* (Matrix.of fun i j : Fin k =>
      (ZMod.stdAddChar (-1 : ZMod p)) ^ (a i * b j)) = 0 := by
    funext j
    have hsum : ∑ i : Fin k, Φ (α i) * (ZMod.stdAddChar (-1 : ZMod p)) ^ (a i * b j)
        = 𝓕 Φ (β j) := by
      have h1 : ∑ i : Fin k, Φ (α i) * (ZMod.stdAddChar (-1 : ZMod p)) ^ (a i * b j)
          = ∑ x ∈ A, Φ x * (ZMod.stdAddChar (-1 : ZMod p)) ^ (x.val * (β j).val) := by
        rw [← Finset.sum_coe_sort A
          (fun x => Φ x * (ZMod.stdAddChar (-1 : ZMod p)) ^ (x.val * (β j).val))]
        simpa [hα, ha, hb] using Equiv.sum_comp eA.symm
          (fun y : {x // x ∈ A} =>
            Φ (y : ZMod p) * (ZMod.stdAddChar (-1 : ZMod p)) ^ ((y : ZMod p).val * (β j).val))
      rw [h1, ZMod.dft_apply]
      rw [← Finset.sum_subset (Finset.subset_univ A)]
      · exact Finset.sum_congr rfl fun x _ => by
          rw [stdAddChar_neg_mul, smul_eq_mul, mul_comm]
      · intro x _ hx
        have : Φ x = 0 := by
          by_contra h
          exact hx (mem_supp.mpr h)
        simp [this]
    have hzero : 𝓕 Φ (β j) = 0 := by
      have := hBsub (hβmem j)
      simp only [Finset.mem_compl] at this
      by_contra h
      exact this (mem_supp.mpr h)
    simp only [Matrix.vecMul, dotProduct, Matrix.of_apply, Pi.zero_apply, hv]
    exact hsum.trans hzero
  have hv0 : v = 0 := Matrix.eq_zero_of_vecMul_eq_zero hdet hvec
  have : Φ (α ⟨0, hk1⟩) = 0 := congrFun hv0 ⟨0, hk1⟩
  exact (mem_supp.mp (hαmem ⟨0, hk1⟩)) this

/-! ## Sharpness -/

/-- The Dirac mass at `0`. -/
noncomputable def dirac (p : ℕ) : ZMod p → ℂ := fun x => if x = 0 then 1 else 0

theorem supp_dirac (p : ℕ) [NeZero p] : supp (dirac p) = {0} := by
  ext x
  simp [supp, dirac, Finset.mem_filter]

theorem dft_dirac (p : ℕ) [NeZero p] : 𝓕 (dirac p) = fun _ => 1 := by
  funext t
  rw [ZMod.dft_apply]
  rw [Finset.sum_eq_single (0 : ZMod p)]
  · simp [dirac]
  · intro x _ hx; simp [dirac, hx]
  · intro h; exact absurd (Finset.mem_univ _) h

/-- The uncertainty inequality is sharp: for the Dirac mass the two supports have exactly
`p + 1` elements in total. -/
theorem uncertainty_sharp_delta (p : ℕ) [NeZero p] :
    (supp (dirac p)).card + (supp (𝓕 (dirac p))).card = p + 1 := by
  rw [supp_dirac, dft_dirac]
  have : supp (fun _ : ZMod p => (1 : ℂ)) = Finset.univ := by
    ext x; simp [supp]
  rw [this, Finset.card_univ, ZMod.card, Finset.card_singleton]
  omega

/-- There is a nonzero function supported in `A` whose Fourier transform vanishes on any
prescribed set `S` with `#S = #A - 1` (pure linear algebra: a square matrix with a zero
column is singular). -/
theorem exists_supported_vanishing (A S : Finset (ZMod p)) (hcard : A.card = S.card + 1) :
    ∃ f : ZMod p → ℂ, f ≠ 0 ∧ (∀ x, x ∉ A → f x = 0) ∧ ∀ s ∈ S, 𝓕 f s = 0 := by
  classical
  set m := S.card with hm
  set eA : {x // x ∈ A} ≃ Fin (m + 1) := A.equivFin.trans (finCongr hcard) with heA
  set eS : {x // x ∈ S} ≃ Fin m := S.equivFin with heS
  set α : Fin (m + 1) → ZMod p := fun i => (eA.symm i : ZMod p) with hα
  set σ : Fin m → ZMod p := fun j => (eS.symm j : ZMod p) with hσ
  set M : Matrix (Fin (m + 1)) (Fin (m + 1)) ℂ := Matrix.of fun i j =>
    if h : (j : ℕ) < m then ZMod.stdAddChar (-(α i * σ ⟨j, h⟩)) else 0 with hM
  have hdet : M.det = 0 := by
    apply Matrix.det_eq_zero_of_column_eq_zero (Fin.last m)
    intro i
    simp [hM]
  obtain ⟨v, hv0, hvM⟩ := Matrix.exists_vecMul_eq_zero_iff.mpr hdet
  refine ⟨fun x => if h : x ∈ A then v (eA ⟨x, h⟩) else 0, ?_, ?_, ?_⟩
  · intro hzero
    obtain ⟨i, hi⟩ := Function.ne_iff.mp hv0
    apply hi
    have := congrFun hzero (α i)
    simpa [hα, Subtype.coe_eta] using this
  · intro x hx; simp [hx]
  · intro s hs
    have hsj : s = σ (eS ⟨s, hs⟩) := by simp [hσ]
    set j : Fin m := eS ⟨s, hs⟩ with hj
    have hj' : ((⟨j, by omega⟩ : Fin (m + 1)) : ℕ) < m := j.isLt
    have hvj := congrFun hvM (⟨j, by omega⟩ : Fin (m + 1))
    rw [ZMod.dft_apply]
    rw [← Finset.sum_subset (Finset.subset_univ A) (by intro x _ hx; simp [hx])]
    rw [← Finset.sum_coe_sort A (fun x => ZMod.stdAddChar (-(x * s)) •
      (if h : x ∈ A then v (eA ⟨x, h⟩) else 0))]
    rw [← Equiv.sum_comp eA.symm]
    simp only [Matrix.vecMul, dotProduct, hM, Matrix.of_apply, Pi.zero_apply] at hvj
    rw [← hvj]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hee : (eA (eA.symm i)) = i := by simp
    simp only [dif_pos (eA.symm i).2, hee, smul_eq_mul]
    rw [dif_pos hj', mul_comm]
    congr 2
    rw [← hsj]

/-- **The uncertainty principle is sharp on every prescribed support.** For any nonempty
`A ⊆ ZMod p` there is a function whose support is exactly `A` and for which
`#supp f + #supp (𝓕 f) = p + 1`. -/
theorem uncertainty_sharp (hp : p.Prime) (A : Finset (ZMod p)) (hA : A.Nonempty) :
    ∃ f : ZMod p → ℂ, supp f = A ∧ (supp f).card + (supp (𝓕 f)).card = p + 1 := by
  classical
  have hApos : 1 ≤ A.card := Finset.card_pos.mpr hA
  have hAle : A.card ≤ p := by simpa [ZMod.card] using Finset.card_le_card (Finset.subset_univ A)
  obtain ⟨S, -, hScard⟩ := Finset.exists_subset_card_eq
    (show A.card - 1 ≤ (Finset.univ : Finset (ZMod p)).card by simp [ZMod.card]; omega)
  obtain ⟨f, hf0, hfsupp, hfvan⟩ := exists_supported_vanishing A S (by omega)
  have hsub : supp f ⊆ A := by
    intro x hx
    by_contra h
    exact (mem_supp.mp hx) (hfsupp x h)
  have h1 : (supp f).card ≤ A.card := Finset.card_le_card hsub
  have hSsub : S ⊆ (supp (𝓕 f))ᶜ := by
    intro s hs
    simp only [Finset.mem_compl, mem_supp, not_not]
    exact hfvan s hs
  have h2 : (supp (𝓕 f)).card ≤ p - (A.card - 1) := by
    have hle := Finset.card_le_card hSsub
    rw [Finset.card_compl, ZMod.card, hScard] at hle
    have h3 : (supp (𝓕 f)).card ≤ p := by
      simpa [ZMod.card] using Finset.card_le_card (Finset.subset_univ (supp (𝓕 f)))
    omega
  have hunc := uncertainty hp f hf0
  have hcards : (supp f).card = A.card := by omega
  exact ⟨f, Finset.eq_of_subset_of_card_le hsub (le_of_eq hcards.symm), by omega⟩

/-- **Rigidity of the extremal kernel.** If `#A = #S + 1`, then the space of functions
supported in `A` whose Fourier transform vanishes on `S` is at most one-dimensional: any two
such functions are proportional. Together with `exists_supported_vanishing` this pins the
space down to exactly a line. -/
theorem extremal_kernel_unique (hp : p.Prime) (A S : Finset (ZMod p))
    (hcard : A.card = S.card + 1) (f g : ZMod p → ℂ)
    (hf : ∀ x ∉ A, f x = 0) (hg : ∀ x ∉ A, g x = 0)
    (hfv : ∀ s ∈ S, 𝓕 f s = 0) (hgv : ∀ s ∈ S, 𝓕 g s = 0) (hf0 : f ≠ 0) :
    ∃ c : ℂ, g = c • f := by
  classical
  haveI : NeZero p := ⟨hp.ne_zero⟩
  obtain ⟨a₀, ha₀⟩ := Function.ne_iff.mp hf0
  have hfa : f a₀ ≠ 0 := ha₀
  have ha₀A : a₀ ∈ A := by
    by_contra h
    exact ha₀ (by simpa using hf a₀ h)
  refine ⟨g a₀ / f a₀, ?_⟩
  set c : ℂ := g a₀ / f a₀ with hc
  set h : ZMod p → ℂ := g - c • f with hh
  have hha₀ : h a₀ = 0 := by
    simp only [hh, Pi.sub_apply, Pi.smul_apply, smul_eq_mul, hc]
    field_simp [hfa]
    ring
  have hsupp : supp h ⊆ A.erase a₀ := by
    intro x hx
    rw [mem_supp] at hx
    refine Finset.mem_erase.mpr ⟨?_, ?_⟩
    · rintro rfl; exact hx hha₀
    · by_contra hxA
      exact hx (by simp [hh, hf x hxA, hg x hxA])
  have hdft : 𝓕 h = 𝓕 g - c • 𝓕 f := by simp [hh]
  have hzero : h = 0 := by
    by_contra hne
    have hc1 : (supp h).card ≤ S.card := by
      have := Finset.card_le_card hsupp
      rw [Finset.card_erase_of_mem ha₀A] at this
      omega
    have hSsub : S ⊆ (supp (𝓕 h))ᶜ := by
      intro s hs
      simp only [Finset.mem_compl, mem_supp, not_not, hdft]
      simp [hfv s hs, hgv s hs]
    have hc2 : (supp (𝓕 h)).card ≤ p - S.card := by
      have h1 := Finset.card_le_card hSsub
      rw [Finset.card_compl, ZMod.card] at h1
      have h2 : (supp (𝓕 h)).card ≤ p := by
        simpa [ZMod.card] using Finset.card_le_card (Finset.subset_univ (supp (𝓕 h)))
      omega
    have hSp : S.card ≤ p := by
      simpa [ZMod.card] using Finset.card_le_card (Finset.subset_univ S)
    have := uncertainty hp h hne
    omega
  have := sub_eq_zero.mp (by simpa [hh] using hzero)
  exact this

/-! ## Exact recovery of sparse signals -/

/-- **Sparse recovery.** Over `ZMod p` with `p` prime, a `k`-sparse signal is uniquely
determined by any `2 * k` of its Fourier coefficients. -/
theorem sparse_recovery (hp : p.Prime) {k : ℕ} (Φ Ψ : ZMod p → ℂ)
    (hΦ : (supp Φ).card ≤ k) (hΨ : (supp Ψ).card ≤ k)
    (S : Finset (ZMod p)) (hS : 2 * k ≤ S.card) (heq : ∀ s ∈ S, 𝓕 Φ s = 𝓕 Ψ s) :
    Φ = Ψ := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  by_contra hne
  have hsub : supp (Φ - Ψ) ⊆ supp Φ ∪ supp Ψ := by
    intro x hx
    rw [mem_supp] at hx
    simp only [Finset.mem_union, mem_supp]
    by_contra h
    push_neg at h
    exact hx (by simp [Pi.sub_apply, h.1, h.2])
  have hcard1 : (supp (Φ - Ψ)).card ≤ 2 * k :=
    le_trans (Finset.card_le_card hsub) (le_trans (Finset.card_union_le _ _) (by omega))
  have hdftsub : 𝓕 (Φ - Ψ) = 𝓕 Φ - 𝓕 Ψ := by
    simp
  have hSdisj : S ⊆ (supp (𝓕 (Φ - Ψ)))ᶜ := by
    intro s hs
    simp only [Finset.mem_compl, mem_supp, not_not, hdftsub]
    simp [heq s hs]
  have hcard2 : (supp (𝓕 (Φ - Ψ))).card ≤ p - 2 * k := by
    have h1 : S.card ≤ ((supp (𝓕 (Φ - Ψ)))ᶜ).card := Finset.card_le_card hSdisj
    rw [Finset.card_compl, ZMod.card] at h1
    have h2 : (supp (𝓕 (Φ - Ψ))).card ≤ p := by
      simpa [ZMod.card] using Finset.card_le_card (Finset.subset_univ (supp (𝓕 (Φ - Ψ))))
    omega
  have hSp : S.card ≤ p := by
    simpa [ZMod.card] using Finset.card_le_card (Finset.subset_univ S)
  have hnz : Φ - Ψ ≠ 0 := sub_ne_zero_of_ne hne
  have hunc := uncertainty hp (Φ - Ψ) hnz
  omega

/-- **Optimality of the `2 * k` sample bound.** With only `2 * k - 1` prescribed frequencies
there are always two distinct `k`-sparse signals with the same Fourier coefficients on that
set, so `sparse_recovery` cannot be improved. -/
theorem sparse_recovery_optimal (k : ℕ) (hk1 : 1 ≤ k) (hk : 2 * k ≤ p)
    (S : Finset (ZMod p)) (hS : S.card = 2 * k - 1) :
    ∃ f g : ZMod p → ℂ, f ≠ g ∧ (supp f).card ≤ k ∧ (supp g).card ≤ k ∧
      ∀ s ∈ S, 𝓕 f s = 𝓕 g s := by
  classical
  obtain ⟨A, -, hAcard⟩ := Finset.exists_subset_card_eq
    (show 2 * k ≤ (Finset.univ : Finset (ZMod p)).card by simpa [ZMod.card] using hk)
  obtain ⟨h, hh0, hhsupp, hhvan⟩ := exists_supported_vanishing A S (by omega)
  obtain ⟨A₁, hA₁sub, hA₁card⟩ := Finset.exists_subset_card_eq (show k ≤ A.card by omega)
  set A₂ : Finset (ZMod p) := A \ A₁ with hA₂
  have hA₂card : A₂.card = k := by
    rw [hA₂, Finset.card_sdiff, Finset.inter_eq_left.mpr hA₁sub, hAcard, hA₁card]
    omega
  refine ⟨fun x => if x ∈ A₁ then h x else 0,
    fun x => -(if x ∈ A₂ then h x else 0), ?_, ?_, ?_, ?_⟩
  · -- the difference of the two signals is `h ≠ 0`
    intro hfg
    apply hh0
    funext x
    have := congrFun hfg x
    by_cases hx : x ∈ A
    · by_cases hx1 : x ∈ A₁
      · have hx2 : x ∉ A₂ := by simp [hA₂, hx1]
        simpa [hx1, hx2] using this
      · have hx2 : x ∈ A₂ := by simp [hA₂, hx, hx1]
        simp only [if_neg hx1, if_pos hx2] at this
        simpa using this.symm
    · simp [hhsupp x hx]
  · refine le_trans (Finset.card_le_card ?_) (le_of_eq hA₁card)
    intro x hx
    rw [mem_supp] at hx
    by_contra hx1
    exact hx (by simp [hx1])
  · refine le_trans (Finset.card_le_card ?_) (le_of_eq hA₂card)
    intro x hx
    rw [mem_supp] at hx
    by_contra hx2
    exact hx (by simp [hx2])
  · intro s hs
    have hsum : (fun x => if x ∈ A₁ then h x else 0)
        - (fun x => -(if x ∈ A₂ then h x else 0)) = h := by
      funext x
      by_cases hx : x ∈ A
      · by_cases hx1 : x ∈ A₁
        · have hx2 : x ∉ A₂ := by simp [hA₂, hx1]
          simp [hx1, hx2]
        · have hx2 : x ∈ A₂ := by simp [hA₂, hx, hx1]
          simp [hx1, hx2]
      · have hx1 : x ∉ A₁ := fun hc => hx (hA₁sub hc)
        have hx2 : x ∉ A₂ := by simp [hA₂, hx]
        simp [hx1, hx2, hhsupp x hx]
    have hdft : 𝓕 (fun x => if x ∈ A₁ then h x else 0) s
        - 𝓕 (fun x => -(if x ∈ A₂ then h x else 0)) s = 0 := by
      have : 𝓕 ((fun x => if x ∈ A₁ then h x else 0)
          - (fun x => -(if x ∈ A₂ then h x else 0))) s = 0 := by
        rw [hsum]; exact hhvan s hs
      simpa using this
    linear_combination hdft

/-! ## Primality is essential -/

/-- For the composite modulus `4` the `2 × 2` submatrix of the DFT matrix indexed by the
distinct residues `{0, 2}` (rows and columns) is **singular**: Chebotarev's theorem genuinely
needs `p` prime. -/
theorem singular_submatrix_of_composite :
    (Matrix.of fun i j : Fin 2 => (Complex.I) ^ (![0, 2] i * ![0, 2] j)).det = 0 ∧
      IsPrimitiveRoot (Complex.I) 4 ∧ Function.Injective (![0, 2] : Fin 2 → ℕ) := by
  refine ⟨?_, ?_, ?_⟩
  · rw [Matrix.det_fin_two]
    norm_num [Matrix.of_apply, pow_succ, Complex.I_mul_I]
  · refine IsPrimitiveRoot.mk_of_lt _ (by norm_num) (by simp [Complex.I_pow_four]) ?_
    intro l hl0 hl4
    interval_cases l <;> norm_num [pow_succ, Complex.ext_iff]
  · intro i j h
    fin_cases i <;> fin_cases j <;> simp_all

end ChebotarevDFT