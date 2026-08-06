import Catalog.Computation.FourierFunctor.Transform

/-!
# The uncertainty principle for the Fourier functor

The Fourier transform `fourierNatIso` of `Transform.lean` is an isomorphism of
functors `FinAb ⥤ ModuleCat ℂ`.  The **uncertainty principle** measures how far
it is from being an isomorphism of the finer structure of *supported* functions:
a function and its transform cannot both be concentrated.

Main results.

* `donoho_stark` — for every non-zero `f : G → ℂ` on a finite abelian group,
  `|G| ≤ |supp f| · |supp 𝓕f|`.
* `donoho_stark_sharp` — the bound is attained by Dirac masses, so no better
  universal inequality of this shape exists.
* `uncertainty_no_small_support` — the contrapositive form: if the transform is
  supported on fewer than `|G| / |supp f|` characters, then `f = 0`.
* `fourier_delta_support` — the transform of a Dirac mass is *everywhere*
  non-zero: maximal spreading.

-- !-- Lab Notes -- !--

* Hypothesizer: the categorical content of the uncertainty principle is that the
  natural isomorphism `𝓕` does **not** restrict to the sub-presheaf of functions
  supported in a proper subset: supports can only be traded, never jointly
  compressed below the "Planck cell" `|G|`.
* Experimenter: the proof is a two-sided `L^∞`/`L^1` interpolation.  Step 1
  (`norm_fourier_le_card_support_mul`) uses `‖ψ x‖ = 1` for every character of a
  *finite* group; step 2 re-injects Fourier inversion.  Both steps were verified
  in Lean; the only quantitative input beyond the transform itself is the
  triangle inequality.
* Analyst: the equality case is realised exactly by Dirac masses (and, by
  duality, by characters), so the inequality is sharp for every finite abelian
  group — the "quantum of information" is one group element times one character.
* Critic: `f ≠ 0` is necessary (`f = 0` gives `0 ≥ |G|`, false).  The result is
  *not* a statement about `ℝ`-variances, so no continuity or moment hypotheses
  are hidden; it is purely combinatorial.
-/

open CategoryTheory AddChar Finset

namespace FourierFunctor

section Uncertainty

variable {G : Type} [AddCommGroup G] [Fintype G]

open scoped Classical in
/-- The support of a complex-valued function on a finite type. -/
noncomputable def support (f : G → ℂ) : Finset G := Finset.univ.filter fun g => f g ≠ 0

open scoped Classical in
omit [AddCommGroup G] in
lemma mem_support {f : G → ℂ} {g : G} : g ∈ support f ↔ f g ≠ 0 := by
  simp [support]

open scoped Classical in
omit [AddCommGroup G] in
lemma support_nonempty_of_ne_zero {f : G → ℂ} (hf : f ≠ 0) : (support f).Nonempty := by
  by_contra h
  rw [Finset.not_nonempty_iff_eq_empty] at h
  refine hf (funext fun g => ?_)
  by_contra hg
  exact absurd (mem_support.2 hg) (by simp [h])

/-- Every value of the Fourier transform is bounded by the `ℓ¹` norm of `f`,
which in turn is bounded by `|supp f|` times the sup-norm. -/
theorem norm_fourier_le_card_support_mul (f : G → ℂ) (M : ℝ) (hM : ∀ g, ‖f g‖ ≤ M)
    (ψ : AddChar G ℂ) :
    ‖fourier f ψ‖ ≤ (support f).card * M := by
  classical
  have h1 : ‖fourier f ψ‖ ≤ ∑ g : G, ‖f g * ψ (-g)‖ := by
    rw [fourier_apply]; exact norm_sum_le _ _
  have h2 : ∀ g : G, ‖f g * ψ (-g)‖ = ‖f g‖ := by
    intro g
    rw [norm_mul, ψ.norm_apply, mul_one]
  have h3 : (∑ g : G, ‖f g * ψ (-g)‖) = ∑ g ∈ support f, ‖f g‖ := by
    rw [Finset.sum_congr rfl fun g _ => h2 g]
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro g _ hg
    have : f g = 0 := by
      by_contra hne
      exact hg (mem_support.2 hne)
    simp [this]
  have h4 : (∑ g ∈ support f, ‖f g‖) ≤ (support f).card • M :=
    Finset.sum_le_card_nsmul _ _ _ fun g _ => hM g
  calc ‖fourier f ψ‖ ≤ ∑ g : G, ‖f g * ψ (-g)‖ := h1
    _ = ∑ g ∈ support f, ‖f g‖ := h3
    _ ≤ (support f).card • M := h4
    _ = (support f).card * M := by simp [nsmul_eq_mul]

/-- Fourier inversion bounds the sup-norm of `f` by the `ℓ¹` norm of its
transform, divided by `|G|`. -/
theorem norm_le_card_support_fourier_mul (f : G → ℂ) (B : ℝ)
    (hB : ∀ ψ : AddChar G ℂ, ‖fourier f ψ‖ ≤ B) (g : G) :
    (Fintype.card G : ℝ) * ‖f g‖ ≤ (support (fourier f)).card * B := by
  classical
  have hinv : f g = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, fourier f ψ * ψ g := by
    conv_lhs => rw [← fourierInv_fourier f]
    rw [fourierInv_apply]
  have hnorm : ‖f g‖ = (Fintype.card G : ℝ)⁻¹ * ‖∑ ψ : AddChar G ℂ, fourier f ψ * ψ g‖ := by
    rw [hinv, norm_mul, norm_inv]
    simp
  have h1 : ‖∑ ψ : AddChar G ℂ, fourier f ψ * ψ g‖ ≤ ∑ ψ : AddChar G ℂ, ‖fourier f ψ * ψ g‖ :=
    norm_sum_le _ _
  have h2 : ∀ ψ : AddChar G ℂ, ‖fourier f ψ * ψ g‖ = ‖fourier f ψ‖ := by
    intro ψ; rw [norm_mul, ψ.norm_apply, mul_one]
  have h3 : (∑ ψ : AddChar G ℂ, ‖fourier f ψ * ψ g‖)
      = ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖ := by
    rw [Finset.sum_congr rfl fun ψ _ => h2 ψ]
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro ψ _ hψ
    have : fourier f ψ = 0 := by
      by_contra hne
      exact hψ (mem_support.2 hne)
    simp [this]
  have h4 : (∑ ψ ∈ support (fourier f), ‖fourier f ψ‖) ≤ (support (fourier f)).card • B :=
    Finset.sum_le_card_nsmul _ _ _ fun ψ _ => hB ψ
  have hcard : (0 : ℝ) < (Fintype.card G : ℝ) := by
    exact_mod_cast Fintype.card_pos_iff.2 ⟨(0 : G)⟩
  have key : ‖f g‖ ≤ (Fintype.card G : ℝ)⁻¹ * ((support (fourier f)).card * B) := by
    rw [hnorm]
    refine mul_le_mul_of_nonneg_left ?_ (by positivity)
    calc ‖∑ ψ : AddChar G ℂ, fourier f ψ * ψ g‖
        ≤ ∑ ψ : AddChar G ℂ, ‖fourier f ψ * ψ g‖ := h1
      _ = ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖ := h3
      _ ≤ (support (fourier f)).card • B := h4
      _ = (support (fourier f)).card * B := by simp [nsmul_eq_mul]
  calc (Fintype.card G : ℝ) * ‖f g‖
      ≤ (Fintype.card G : ℝ) * ((Fintype.card G : ℝ)⁻¹ * ((support (fourier f)).card * B)) :=
        mul_le_mul_of_nonneg_left key hcard.le
    _ = (support (fourier f)).card * B := by
        field_simp

/-- **The Donoho–Stark uncertainty principle.**  A non-zero function on a finite
abelian group and its Fourier transform cannot both be concentrated: the product
of the sizes of their supports is at least the order of the group. -/
theorem donoho_stark (f : G → ℂ) (hf : f ≠ 0) :
    Fintype.card G ≤ (support f).card * (support (fourier f)).card := by
  classical
  obtain ⟨g₀, -, hg₀⟩ :=
    Finset.exists_max_image (Finset.univ : Finset G) (fun g => ‖f g‖) ⟨0, Finset.mem_univ 0⟩
  set M : ℝ := ‖f g₀‖ with hMdef
  have hMpos : 0 < M := by
    rcases support_nonempty_of_ne_zero hf with ⟨g, hg⟩
    have h1 : 0 < ‖f g‖ := norm_pos_iff.2 (mem_support.1 hg)
    exact lt_of_lt_of_le h1 (hg₀ g (Finset.mem_univ g))
  have hM : ∀ g, ‖f g‖ ≤ M := fun g => hg₀ g (Finset.mem_univ g)
  have hB : ∀ ψ : AddChar G ℂ, ‖fourier f ψ‖ ≤ (support f).card * M :=
    fun ψ => norm_fourier_le_card_support_mul f M hM ψ
  have key := norm_le_card_support_fourier_mul f ((support f).card * M) hB g₀
  rw [← hMdef] at key
  have key2 : (Fintype.card G : ℝ) * M
      ≤ ((support f).card * (support (fourier f)).card : ℝ) * M := by
    calc (Fintype.card G : ℝ) * M
        ≤ (support (fourier f)).card * ((support f).card * M) := key
      _ = ((support f).card * (support (fourier f)).card : ℝ) * M := by ring
  have := le_of_mul_le_mul_right (by linarith [key2] : (Fintype.card G : ℝ) * M
      ≤ ((support f).card * (support (fourier f)).card : ℝ) * M) hMpos
  exact_mod_cast this

/-! ### Sharpness: Dirac masses -/

open scoped Classical in
/-- The Dirac mass at `a`. -/
noncomputable def delta (a : G) : G → ℂ := fun g => if g = a then 1 else 0

open scoped Classical in
lemma fourier_delta (a : G) (ψ : AddChar G ℂ) : fourier (delta a) ψ = ψ (-a) := by
  rw [fourier_apply]
  rw [Finset.sum_eq_single a]
  · simp [delta]
  · intro g _ hg; simp [delta, hg]
  · intro h; exact absurd (Finset.mem_univ a) h

open scoped Classical in
/-- The transform of a Dirac mass never vanishes: it is maximally spread out. -/
theorem fourier_delta_support (a : G) : support (fourier (delta a)) = Finset.univ := by
  classical
  refine Finset.eq_univ_iff_forall.2 fun ψ => ?_
  refine mem_support.2 ?_
  rw [fourier_delta]
  exact addChar_apply_ne_zero ψ (-a)

open scoped Classical in
omit [AddCommGroup G] in
lemma support_delta (a : G) : support (delta a) = {a} := by
  classical
  ext g
  simp [mem_support, delta]

open scoped Classical in
omit [AddCommGroup G] [Fintype G] in
lemma delta_ne_zero (a : G) : delta (G := G) a ≠ 0 := by
  intro h
  have := congrFun h a
  simp [delta] at this

/-- **Sharpness of the uncertainty principle**: for a Dirac mass the Donoho–Stark
inequality is an equality, so the constant `|G|` cannot be improved. -/
theorem donoho_stark_sharp (a : G) :
    (support (delta a)).card * (support (fourier (delta a))).card = Fintype.card G := by
  classical
  rw [support_delta, fourier_delta_support]
  simp [Finset.card_univ, AddChar.card_eq (α := G)]

/-- Contrapositive form: a function whose transform is supported on too few
characters must vanish identically. -/
theorem uncertainty_no_small_support (f : G → ℂ)
    (h : (support f).card * (support (fourier f)).card < Fintype.card G) : f = 0 := by
  by_contra hf
  exact absurd (donoho_stark f hf) (by omega)

/-- Quantitative form: if `f` is supported on a single point of `G`, its
transform is supported everywhere. -/
theorem full_spread_of_singleton_support (f : G → ℂ) (hf : f ≠ 0)
    (h : (support f).card = 1) : (support (fourier f)).card = Fintype.card G := by
  have h1 : Fintype.card G ≤ (support (fourier f)).card := by
    have := donoho_stark f hf
    rw [h, one_mul] at this
    exact this
  have h2 : (support (fourier f)).card ≤ Fintype.card (AddChar G ℂ) :=
    Finset.card_le_univ _
  rw [AddChar.card_eq (α := G)] at h2
  omega

/-- **The additive form of the uncertainty principle.**  By the arithmetic–
geometric mean inequality, the Donoho–Stark bound implies that the two supports
cannot both be smaller than `√|G|`. -/
theorem donoho_stark_add_form (f : G → ℂ) (hf : f ≠ 0) :
    2 * Real.sqrt (Fintype.card G)
      ≤ (support f).card + (support (fourier f)).card := by
  set a : ℝ := ((support f).card : ℝ) with ha
  set b : ℝ := ((support (fourier f)).card : ℝ) with hb
  have hane : 0 ≤ a := by positivity
  have hbne : 0 ≤ b := by positivity
  have hab : (Fintype.card G : ℝ) ≤ a * b := by
    rw [ha, hb, ← Nat.cast_mul]
    exact_mod_cast donoho_stark f hf
  have h1 : Real.sqrt (Fintype.card G) ≤ Real.sqrt (((a + b) / 2) ^ 2) :=
    Real.sqrt_le_sqrt (by nlinarith [sq_nonneg (a - b)])
  rw [Real.sqrt_sq (by linarith)] at h1
  linarith

/-- Consequently at least one of the two supports has at least `√|G|` elements. -/
theorem sqrt_card_le_max_card_support (f : G → ℂ) (hf : f ≠ 0) :
    Real.sqrt (Fintype.card G)
      ≤ max ((support f).card : ℝ) ((support (fourier f)).card : ℝ) := by
  have h := donoho_stark_add_form f hf
  rcases le_total ((support f).card : ℝ) ((support (fourier f)).card : ℝ) with hle | hle
  · rw [max_eq_right hle]; linarith
  · rw [max_eq_left hle]; linarith

end Uncertainty

/-! ### The categorical reading -/

/-- **The uncertainty principle, categorically.**  The natural isomorphism
`fourierNatIso : functionsFunctor ≅ dualFunctionsFunctor` cannot be refined to an
isomorphism that decreases supports: for every object `G` of `FinAb` and every
non-zero element `f` of `functionsFunctor.obj G`, the supports of `f` and of its
image under the component of `fourierNatIso` at `G` satisfy the Heisenberg-type
bound. -/
theorem fourierNatIso_uncertainty (G : FinAb) (f : FinAb.carrier G → ℂ) (hf : f ≠ 0) :
    Fintype.card (FinAb.carrier G)
      ≤ (support f).card * (support (ModuleCat.Hom.hom (fourierNatIso.hom.app G) f)).card := by
  simpa [fourierNatIso_hom_app] using donoho_stark f hf

end FourierFunctor