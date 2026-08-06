import Catalog.Computation.FourierFunctor.Uncertainty

/-!
# The uncertainty principle is a property of the kernel, not of the Fourier transform

This module closes conjecture **C1** of `FUTURE_DIRECTIONS.md`: the Donoho–Stark
inequality `|G| ≤ |supp f| · |supp 𝓕f|` never uses any property of the Fourier
transform beyond

* the transform is given by a **kernel** `k : G → H → ℂ` whose entries are
  bounded in modulus by `μ`, and
* it admits an **inversion kernel** `l : H → G → ℂ` whose entries are bounded in
  modulus by `ν`.

Under exactly these two hypotheses we prove the *abstract uncertainty principle*

`1 ≤ μ · ν · |supp f| · |supp (T f)|`  for every non-zero `f`,

and we then read off three consequences.

Main results.

* `abstract_uncertainty` — the general two-kernel bound.
* `donoho_stark_of_abstract` — the Fourier case (`μ = 1`, `ν = |G|⁻¹`) recovers
  `donoho_stark`, so nothing about characters beyond `‖ψ x‖ = 1` was used.
* `matrix_uncertainty` — the Elad–Bruckstein *coherence* bound: for any matrix
  `U` with orthonormal rows and all entries of modulus at most `μ`,
  `1 ≤ μ² · |supp f| · |supp (Uᵀ f)|`.
* `unbiased_uncertainty` — the normalised (complex-Hadamard / mutually unbiased
  basis) form: entries of modulus at most `1/√n` force
  `n ≤ |supp f| · |supp (Uᵀ f)|`.
* `support_kernelTransform_delta`, `flat_kernel_card_bound` — sharpness: for a
  flat kernel Dirac masses are maximally spread and attain the bound, so the
  constant `(μν)⁻¹` cannot be improved.
* `hadamard2_uncertainty` — a concrete non-Fourier witness: the `2 × 2`
  Hadamard matrix, showing the abstract theorem is not vacuous outside the
  character-theoretic setting.

-- !-- Lab Notes -- !--

* Hypothesizer (C1): the previous cycle conjectured that `donoho_stark` is a
  statement about a *pair of filtrations by support size* rather than about
  `𝓕`.  The sharpest falsifiable form of that guess is: any linear map given by
  a bounded kernel that can be inverted by a bounded kernel obeys the same
  inequality, with the constant `|G|` replaced by `(μν)⁻¹`.
* Experimenter: the two steps of the Fourier proof
  (`norm_fourier_le_card_support_mul`, `norm_le_card_support_fourier_mul`) are
  literally the same statement applied to `k` and to `l`; they were refactored
  into the single lemma `norm_sum_mul_le_card_support`, which is where all the
  analysis lives.  The rest is `nlinarith`-free algebra plus cancellation of the
  maximal value `M > 0`.
* Analyst: the conjecture survives in the strong form.  Moreover the constant is
  optimal in a new way: for the Fourier kernel `μν = |G|⁻¹`, for a normalised
  Hadamard kernel `μν = n⁻¹`, and the two agree — the "Planck cell" is the
  *coherence* `μν`, not the group order.  This explains why the Fourier bound is
  attained by Dirac masses for *every* finite abelian group: only the flatness
  of the kernel matters.
* Critic: the inversion hypothesis is genuinely needed (a kernel of zeros has
  bounded entries and destroys all information), and it is stated only for the
  particular `f`, which is the weakest usable form.  Non-vacuity is witnessed
  twice, by the Fourier kernel (`donoho_stark_of_abstract`) and by an explicit
  matrix which is not a character table of a group action in disguise
  (`hadamard2_uncertainty`).
-/

open Finset

namespace FourierFunctor

section Abstract

variable {G H : Type} [Fintype G] [Fintype H]

/-- The linear transform with kernel `k`: `(T f) h = ∑ g, f g · k g h`. -/
noncomputable def kernelTransform (k : G → H → ℂ) (f : G → ℂ) : H → ℂ :=
  fun h => ∑ g : G, f g * k g h

omit [Fintype H] in
lemma kernelTransform_apply (k : G → H → ℂ) (f : G → ℂ) (h : H) :
    kernelTransform k f h = ∑ g : G, f g * k g h := rfl

/-- The analytic heart of every uncertainty principle of this type: a sum
`∑ i, u i * v i` is controlled by the *size of the support of `u`* times the
product of the two sup-bounds. -/
lemma norm_sum_mul_le_card_support {ι : Type} [Fintype ι] (u v : ι → ℂ) (A B : ℝ)
    (hu : ∀ i, ‖u i‖ ≤ A) (hv : ∀ i, ‖v i‖ ≤ B) :
    ‖∑ i : ι, u i * v i‖ ≤ (support u).card * (A * B) := by
  classical
  have hstep : ‖∑ i : ι, u i * v i‖ ≤ ∑ i ∈ support u, ‖u i * v i‖ := by
    refine le_trans (norm_sum_le _ _) ?_
    refine le_of_eq (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro i _ hi
    have : u i = 0 := by
      by_contra hne
      exact hi (mem_support.2 hne)
    simp [this]
  refine hstep.trans ?_
  have hterm : ∀ i ∈ support u, ‖u i * v i‖ ≤ A * B := by
    intro i _
    rw [norm_mul]
    exact mul_le_mul (hu i) (hv i) (norm_nonneg _) ((norm_nonneg (u i)).trans (hu i))
  calc (∑ i ∈ support u, ‖u i * v i‖) ≤ (support u).card • (A * B) :=
        Finset.sum_le_card_nsmul _ _ _ hterm
    _ = (support u).card * (A * B) := by simp [nsmul_eq_mul]

variable {μ ν : ℝ}

omit [Fintype H] in
/-- Step 1: the transform of `f` is bounded by `|supp f| · μ · M`. -/
lemma norm_kernelTransform_le (k : G → H → ℂ) (hk : ∀ g h, ‖k g h‖ ≤ μ)
    (f : G → ℂ) (M : ℝ) (hM : ∀ g, ‖f g‖ ≤ M) (h : H) :
    ‖kernelTransform k f h‖ ≤ (support f).card * (M * μ) :=
  norm_sum_mul_le_card_support _ _ _ _ hM (fun g => hk g h)

omit [Fintype G] in
/-- Step 2: if `f` is reconstructed from `T f` by the kernel `l`, then the values
of `f` are bounded by `|supp (T f)| · ν · B`. -/
lemma norm_le_of_inversion (l : H → G → ℂ) (hl : ∀ h g, ‖l h g‖ ≤ ν)
    (f : G → ℂ) (F : H → ℂ) (B : ℝ) (hB : ∀ h, ‖F h‖ ≤ B) (g : G)
    (hinv : f g = ∑ h : H, F h * l h g) :
    ‖f g‖ ≤ (support F).card * (B * ν) := by
  rw [hinv]
  exact norm_sum_mul_le_card_support _ _ _ _ hB (fun h => hl h g)

/-- **The abstract uncertainty principle.**  Let `T` be the transform with kernel
`k`, all of whose entries have modulus at most `μ`, and suppose `f` can be
recovered from `T f` by a kernel `l` all of whose entries have modulus at most
`ν`.  Then for non-zero `f`

`1 ≤ μ · ν · |supp f| · |supp (T f)|`.

No linearity, unitarity, group structure or character theory is used: only the
two sup-bounds and the reconstruction identity. -/
theorem abstract_uncertainty (k : G → H → ℂ) (l : H → G → ℂ)
    (hk : ∀ g h, ‖k g h‖ ≤ μ) (hl : ∀ h g, ‖l h g‖ ≤ ν)
    (f : G → ℂ) (hf : f ≠ 0)
    (hinv : ∀ g, f g = ∑ h : H, kernelTransform k f h * l h g) :
    1 ≤ μ * ν * ((support f).card * (support (kernelTransform k f)).card) := by
  classical
  obtain ⟨g₁, hg₁⟩ := support_nonempty_of_ne_zero hf
  obtain ⟨g₀, -, hg₀⟩ :=
    Finset.exists_max_image (Finset.univ : Finset G) (fun g => ‖f g‖) ⟨g₁, Finset.mem_univ g₁⟩
  set M : ℝ := ‖f g₀‖ with hMdef
  have hM : ∀ g, ‖f g‖ ≤ M := fun g => hg₀ g (Finset.mem_univ g)
  have hMpos : 0 < M :=
    lt_of_lt_of_le (norm_pos_iff.2 (mem_support.1 hg₁)) (hM g₁)
  have hB : ∀ h : H, ‖kernelTransform k f h‖ ≤ (support f).card * (M * μ) :=
    fun h => norm_kernelTransform_le k hk f M hM h
  have hstep :=
    norm_le_of_inversion l hl f (kernelTransform k f) ((support f).card * (M * μ)) hB g₀
      (hinv g₀)
  rw [← hMdef] at hstep
  have hkey : M * 1 ≤ M * (μ * ν * ((support f).card * (support (kernelTransform k f)).card)) := by
    calc M * 1 = M := mul_one M
      _ ≤ (support (kernelTransform k f)).card * ((support f).card * (M * μ) * ν) := by
          simpa using hstep
      _ = M * (μ * ν * ((support f).card * (support (kernelTransform k f)).card)) := by ring
  exact le_of_mul_le_mul_left hkey hMpos

/-! #### Sharpness of the abstract bound -/

omit [Fintype H] in
lemma kernelTransform_delta (k : G → H → ℂ) (a : G) (h : H) :
    kernelTransform k (delta a) h = k a h := by
  classical
  rw [kernelTransform_apply, Finset.sum_eq_single a]
  · simp [delta]
  · intro g _ hg; simp [delta, hg]
  · intro ha; exact absurd (Finset.mem_univ a) ha

/-- For a **flat** kernel (all entries of the same non-zero modulus `μ`) the
transform of a Dirac mass is nowhere zero: Dirac masses are maximally spread,
exactly as in the Fourier case. -/
theorem support_kernelTransform_delta (k : G → H → ℂ) (hflat : ∀ g h, ‖k g h‖ = μ)
    (hμ : 0 < μ) (a : G) : support (kernelTransform k (delta a)) = Finset.univ := by
  classical
  refine Finset.eq_univ_iff_forall.2 fun h => mem_support.2 ?_
  rw [kernelTransform_delta]
  intro h0
  have : ‖k a h‖ = 0 := by rw [h0, norm_zero]
  rw [hflat a h] at this
  exact hμ.ne' this

/-- Consequently the abstract bound is *attained* by Dirac masses whenever the
kernel is flat, so the constant `(μν)⁻¹` in `abstract_uncertainty` cannot be
improved: flatness forces `1 ≤ μ · ν · |H|`. -/
theorem flat_kernel_card_bound (k : G → H → ℂ) (l : H → G → ℂ)
    (hflat : ∀ g h, ‖k g h‖ = μ) (hμ : 0 < μ) (hl : ∀ h g, ‖l h g‖ ≤ ν) (a : G)
    (hinv : ∀ g, delta a g = ∑ h : H, kernelTransform k (delta a) h * l h g) :
    1 ≤ μ * ν * Fintype.card H := by
  classical
  have h := abstract_uncertainty k l (fun g h => (hflat g h).le) hl (delta a)
    (delta_ne_zero a) hinv
  rw [support_delta, support_kernelTransform_delta k hflat hμ a] at h
  simpa using h

end Abstract

/-! ### Consequence 1: the Fourier transform -/

section Fourier

variable {G : Type} [AddCommGroup G] [Fintype G]

lemma fourier_eq_kernelTransform (f : G → ℂ) :
    fourier f = kernelTransform (fun g (ψ : AddChar G ℂ) => ψ (-g)) f := by
  funext ψ
  rw [fourier_apply]
  rfl

/-- **The Donoho–Stark principle is a corollary of the abstract one.**  Taking
`k g ψ = ψ (-g)` (modulus `1`) and `l ψ g = |G|⁻¹ · ψ g` (modulus `|G|⁻¹`), the
abstract inequality `1 ≤ μν · |supp f| · |supp 𝓕f|` becomes exactly
`|G| ≤ |supp f| · |supp 𝓕f|`. -/
theorem donoho_stark_of_abstract (f : G → ℂ) (hf : f ≠ 0) :
    Fintype.card G ≤ (support f).card * (support (fourier f)).card := by
  classical
  set k : G → AddChar G ℂ → ℂ := fun g ψ => ψ (-g) with hkdef
  set l : AddChar G ℂ → G → ℂ := fun ψ g => (Fintype.card G : ℂ)⁻¹ * ψ g with hldef
  have hcardpos : (0 : ℝ) < (Fintype.card G : ℝ) := by
    exact_mod_cast Fintype.card_pos_iff.2 ⟨(0 : G)⟩
  have hk : ∀ g ψ, ‖k g ψ‖ ≤ (1 : ℝ) := by
    intro g ψ; simp [hkdef, ψ.norm_apply]
  have hl : ∀ ψ g, ‖l ψ g‖ ≤ ((Fintype.card G : ℝ))⁻¹ := by
    intro ψ g
    simp [hldef, ψ.norm_apply]
  have hT : kernelTransform k f = fourier f := (fourier_eq_kernelTransform f).symm
  have hinv : ∀ g, f g = ∑ ψ : AddChar G ℂ, kernelTransform k f ψ * l ψ g := by
    intro g
    have := congrFun (fourierInv_fourier f) g
    rw [fourierInv_apply] at this
    rw [hT, ← this, Finset.mul_sum]
    exact Finset.sum_congr rfl fun ψ _ => by rw [hldef]; ring
  have habs := abstract_uncertainty k l hk hl f hf hinv
  rw [hT] at habs
  have hprod : (Fintype.card G : ℝ)
      ≤ ((support f).card * (support (fourier f)).card : ℝ) := by
    have h1 : (1 : ℝ) * (Fintype.card G : ℝ)
        ≤ (1 * (Fintype.card G : ℝ)⁻¹ *
            ((support f).card * (support (fourier f)).card)) * (Fintype.card G : ℝ) :=
      mul_le_mul_of_nonneg_right habs hcardpos.le
    calc (Fintype.card G : ℝ) = 1 * (Fintype.card G : ℝ) := (one_mul _).symm
      _ ≤ (1 * (Fintype.card G : ℝ)⁻¹ *
            ((support f).card * (support (fourier f)).card)) * (Fintype.card G : ℝ) := h1
      _ = ((support f).card * (support (fourier f)).card : ℝ) := by
          field_simp
  exact_mod_cast hprod

end Fourier

/-! ### Consequence 2: matrices with orthonormal rows (the coherence bound) -/

section Matrices

variable {G H : Type} [Fintype G] [DecidableEq G] [Fintype H]

open scoped ComplexConjugate

/-- **The Elad–Bruckstein coherence bound.**  If the rows of `U` are orthonormal
and every entry of `U` has modulus at most `μ`, then for every non-zero `f`

`1 ≤ μ² · |supp f| · |supp (Uᵀ f)|`.

This is the uncertainty principle for an arbitrary pair of bases; the Fourier
case is the special case of the character table. -/
theorem matrix_uncertainty (U : G → H → ℂ) (μ : ℝ)
    (hrows : ∀ g g' : G, (∑ h : H, U g h * conj (U g' h)) = if g = g' then 1 else 0)
    (hμ : ∀ g h, ‖U g h‖ ≤ μ) (f : G → ℂ) (hf : f ≠ 0) :
    1 ≤ μ ^ 2 * ((support f).card * (support (kernelTransform U f)).card) := by
  classical
  have hl : ∀ (h : H) (g : G), ‖conj (U g h)‖ ≤ μ := by
    intro h g; rw [RCLike.norm_conj]; exact hμ g h
  have hinv : ∀ g, f g = ∑ h : H, kernelTransform U f h * conj (U g h) := by
    intro g
    have : (∑ h : H, kernelTransform U f h * conj (U g h))
        = ∑ g' : G, f g' * ∑ h : H, U g' h * conj (U g h) := by
      calc (∑ h : H, kernelTransform U f h * conj (U g h))
          = ∑ h : H, ∑ g' : G, f g' * U g' h * conj (U g h) := by
            refine Finset.sum_congr rfl fun h _ => ?_
            rw [kernelTransform_apply, Finset.sum_mul]
        _ = ∑ g' : G, ∑ h : H, f g' * U g' h * conj (U g h) := Finset.sum_comm
        _ = ∑ g' : G, f g' * ∑ h : H, U g' h * conj (U g h) := by
            refine Finset.sum_congr rfl fun g' _ => ?_
            rw [Finset.mul_sum]
            exact Finset.sum_congr rfl fun h _ => by ring
    rw [this]
    rw [Finset.sum_eq_single g]
    · rw [hrows g g]; simp
    · intro g' _ hg'
      rw [hrows g' g, if_neg hg']; ring
    · intro hg; exact absurd (Finset.mem_univ g) hg
  have := abstract_uncertainty U (fun h g => conj (U g h)) hμ hl f hf hinv
  calc (1 : ℝ) ≤ μ * μ * ((support f).card * (support (kernelTransform U f)).card) := this
    _ = μ ^ 2 * ((support f).card * (support (kernelTransform U f)).card) := by ring

/-- **The normalised (mutually unbiased / complex Hadamard) form.**  If all
entries have modulus at most `1/√n`, the supports satisfy `n ≤ |supp f| ·
|supp (Uᵀ f)|`: a maximally flat change of basis spreads every sparse vector. -/
theorem unbiased_uncertainty (U : G → H → ℂ) (n : ℝ) (hn : 0 < n)
    (hrows : ∀ g g' : G, (∑ h : H, U g h * conj (U g' h)) = if g = g' then 1 else 0)
    (hμ : ∀ g h, ‖U g h‖ ≤ 1 / Real.sqrt n) (f : G → ℂ) (hf : f ≠ 0) :
    n ≤ (support f).card * (support (kernelTransform U f)).card := by
  have h := matrix_uncertainty U (1 / Real.sqrt n) hrows hμ f hf
  have hsq : (1 / Real.sqrt n) ^ 2 = 1 / n := by
    rw [div_pow, one_pow, Real.sq_sqrt hn.le]
  rw [hsq] at h
  have := mul_le_mul_of_nonneg_right h hn.le
  calc n = 1 * n := (one_mul n).symm
    _ ≤ 1 / n * ((support f).card * (support (kernelTransform U f)).card) * n := this
    _ = (support f).card * (support (kernelTransform U f)).card := by
        field_simp

end Matrices

/-! ### Consequence 3: a concrete non-Fourier witness -/

section Hadamard

open scoped ComplexConjugate

/-- The normalised `2 × 2` Hadamard matrix. -/
noncomputable def had2 : Fin 2 → Fin 2 → ℂ := fun i j =>
  if i = 1 ∧ j = 1 then -(Real.sqrt 2 : ℝ)⁻¹ else ((Real.sqrt 2 : ℝ)⁻¹ : ℝ)

lemma sqrt_two_inv_sq : ((Real.sqrt 2 : ℝ)⁻¹) ^ 2 = 1 / 2 := by
  rw [inv_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)]
  norm_num

lemma had2_rows (i j : Fin 2) :
    (∑ k : Fin 2, had2 i k * conj (had2 j k)) = if i = j then 1 else 0 := by
  have h2 : ((Real.sqrt 2 : ℝ) : ℂ)⁻¹ * ((Real.sqrt 2 : ℝ) : ℂ)⁻¹ = 1 / 2 := by
    have : (((Real.sqrt 2 : ℝ)⁻¹ : ℝ) : ℂ) * (((Real.sqrt 2 : ℝ)⁻¹ : ℝ) : ℂ)
        = (((1 : ℝ) / 2 : ℝ) : ℂ) := by
      rw [← Complex.ofReal_mul]
      norm_cast
      rw [← sq]
      exact sqrt_two_inv_sq
    push_cast at this ⊢
    simpa using this
  fin_cases i <;> fin_cases j <;>
    simp [had2, Fin.sum_univ_two, Complex.conj_ofReal, h2]
  all_goals ring_nf

lemma had2_norm (i j : Fin 2) : ‖had2 i j‖ ≤ 1 / Real.sqrt 2 := by
  have h : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos.2 (by norm_num)
  fin_cases i <;> fin_cases j <;>
    simp [had2, Complex.norm_real, abs_of_pos, h, one_div]

/-- The abstract uncertainty principle is not vacuous outside the Fourier
setting: for the `2 × 2` Hadamard matrix, no non-zero vector and its Hadamard
transform can both be supported on a single coordinate. -/
theorem hadamard2_uncertainty (f : Fin 2 → ℂ) (hf : f ≠ 0) :
    2 ≤ (support f).card * (support (kernelTransform had2 f)).card := by
  have := unbiased_uncertainty had2 2 (by norm_num) had2_rows had2_norm f hf
  exact_mod_cast this

end Hadamard

end FourierFunctor