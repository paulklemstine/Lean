import Mathlib

/-!
# Fourier as a functor, cycle 1: correct naturality domain and a genuine uncertainty principle

This file continues `Catalog/Bridges/FourierAsFunctor.lean`. That file established a
finite-coordinate categorical model of character duality and proved two *negative* results:

* the discrete Fourier matrices are **not** a natural endomorphism of the identity functor on a
  category whose arrows are all linear maps, and
* contravariant duality alone does **not** force any support uncertainty bound.

Both negative results are answered here positively, with substantive hypotheses.

## Main results

* `FourierUncertainty.dftNatIso` : the discrete Fourier transform on `ZMod N` **is** a natural
  isomorphism once the arrows are restricted to the multiplicative-unit automorphisms of
  `ZMod N`, i.e. between the pullback representation functor and its inverse twist, both viewed
  as functors `SingleObj (ZMod N)ˣ ⥤ ModuleCat ℂ`. This identifies the correct naturality domain.
* `FourierUncertainty.donoho_stark` : the Donoho–Stark uncertainty principle
  `N ≤ |supp Φ| * |supp (𝓕 Φ)|` for every nonzero `Φ : ZMod N → ℂ`. This is the substantive
  replacement for the disproved "contravariance implies uncertainty" claim.
* `FourierUncertainty.donoho_stark_sharp` : the bound is attained exactly, by delta functions.
* `FourierUncertainty.donoho_stark_am_gm` : the additive form `4 * N ≤ (|supp Φ| + |supp 𝓕Φ|)^2`.
* `FourierUncertainty.dualMap_comp` and `FourierUncertainty.doubleDualEmb_natural` : arrow-level
  functoriality of the character dual and naturality of the biduality evaluation map, together
  with `doubleDualEquiv_natural`, the natural-isomorphism form for finite abelian groups.
-/

open CategoryTheory Finset ZMod AddChar

namespace FourierUncertainty

/-! ## 1. The correct naturality domain for the discrete Fourier transform -/

section Naturality

variable {N : ℕ} [NeZero N]

/-- Pullback of a function on `ZMod N` along multiplication by a unit, as a linear equivalence. -/
noncomputable def unitPullback (u : (ZMod N)ˣ) : (ZMod N → ℂ) ≃ₗ[ℂ] (ZMod N → ℂ) where
  toFun Φ := fun j => Φ (u.val * j)
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
  invFun Φ := fun j => Φ (u⁻¹.val * j)
  left_inv Φ := by
    funext j
    simp [← mul_assoc]
  right_inv Φ := by
    funext j
    simp [← mul_assoc]

omit [NeZero N] in
@[simp]
theorem unitPullback_apply (u : (ZMod N)ˣ) (Φ : ZMod N → ℂ) (j : ZMod N) :
    unitPullback u Φ j = Φ (u.val * j) := rfl

omit [NeZero N] in
/-- Pullback is multiplicative in the unit: this is the group action making
`ZMod N → ℂ` a representation of `(ZMod N)ˣ`. -/
theorem unitPullback_mul (u v : (ZMod N)ˣ) (Φ : ZMod N → ℂ) :
    unitPullback (u * v) Φ = unitPullback u (unitPullback v Φ) := by
  funext j
  simp [mul_assoc, mul_comm u.val v.val]

/-- The coordinate space of `ZMod N`, as an object of `ModuleCat ℂ`. -/
noncomputable abbrev coordSpace (N : ℕ) : ModuleCat ℂ := ModuleCat.of ℂ (ZMod N → ℂ)

/-- The pullback action of the unit group on the coordinate space, as a monoid homomorphism
into endomorphisms. -/
noncomputable def pullbackRep (N : ℕ) [NeZero N] : (ZMod N)ˣ →* End (coordSpace N) where
  toFun u := ModuleCat.ofHom (unitPullback u).toLinearMap
  map_one' := by
    refine ModuleCat.hom_ext (LinearMap.ext fun Φ => ?_)
    funext j
    show unitPullback (1 : (ZMod N)ˣ) Φ j = Φ j
    simp
  map_mul' u v := by
    refine ModuleCat.hom_ext (LinearMap.ext fun Φ => ?_)
    funext j
    exact congrFun (unitPullback_mul u v Φ) j

/-- The inverse-twisted pullback action: the target of Fourier naturality. -/
noncomputable def dualPullbackRep (N : ℕ) [NeZero N] : (ZMod N)ˣ →* End (coordSpace N) where
  toFun u := ModuleCat.ofHom (unitPullback u⁻¹).toLinearMap
  map_one' := by
    refine ModuleCat.hom_ext (LinearMap.ext fun Φ => ?_)
    funext j
    show unitPullback (1 : (ZMod N)ˣ)⁻¹ Φ j = Φ j
    simp
  map_mul' u v := by
    refine ModuleCat.hom_ext (LinearMap.ext fun Φ => ?_)
    funext j
    rw [mul_inv_rev, mul_comm]
    exact congrFun (unitPullback_mul u⁻¹ v⁻¹ Φ) j

/-- The pullback representation of the unit group, as a functor out of the one-object
category of `(ZMod N)ˣ`. -/
noncomputable def pullbackFunctor (N : ℕ) [NeZero N] :
    SingleObj (ZMod N)ˣ ⥤ ModuleCat ℂ :=
  SingleObj.functor (pullbackRep N)

/-- The inverse-twisted pullback representation, as a functor. -/
noncomputable def dualPullbackFunctor (N : ℕ) [NeZero N] :
    SingleObj (ZMod N)ˣ ⥤ ModuleCat ℂ :=
  SingleObj.functor (dualPullbackRep N)

/-- **Fourier naturality, correct domain.** The Fourier transform intertwines the pullback
action of the units of `ZMod N` with its inverse twist. Contrast with the disproof of
unrestricted naturality in `FourierAsFunctor.unrestricted_fourier_naturality_false`. -/
theorem dft_unitPullback (u : (ZMod N)ˣ) (Φ : ZMod N → ℂ) :
    𝓕 (unitPullback u Φ) = unitPullback u⁻¹ (𝓕 Φ) := by
  funext k
  exact ZMod.dft_comp_unitMul Φ u k

/-- The Fourier transform as an isomorphism of `ℂ`-modules. -/
noncomputable def dftIso (N : ℕ) [NeZero N] : coordSpace N ≅ coordSpace N :=
  (ZMod.dft (N := N) (E := ℂ)).toModuleIso

/-- **The Fourier transform is a natural isomorphism** between the pullback representation of
`(ZMod N)ˣ` and its inverse twist. This is the positive counterpart of the previous cycle's
disproof: naturality holds precisely over the measure-compatible automorphisms, not over all
linear maps. -/
noncomputable def dftNatIso (N : ℕ) [NeZero N] :
    pullbackFunctor N ≅ dualPullbackFunctor N :=
  NatIso.ofComponents (fun _ => dftIso N) (by
    intro _ _ u
    ext Φ
    exact dft_unitPullback u Φ)

end Naturality

/-! ## 2. The Donoho–Stark uncertainty principle -/

section Uncertainty

variable {N : ℕ} [NeZero N]

open scoped Classical in
/-- The support of a function on `ZMod N`, as a finite set. -/
noncomputable def fsupport (Φ : ZMod N → ℂ) : Finset (ZMod N) :=
  Finset.univ.filter fun j => Φ j ≠ 0

open scoped Classical in
@[simp]
theorem mem_fsupport {Φ : ZMod N → ℂ} {j : ZMod N} : j ∈ fsupport Φ ↔ Φ j ≠ 0 := by
  simp [fsupport]

/-- Every Fourier coefficient is bounded by the size of the support times the sup norm. -/
theorem norm_dft_le (Φ : ZMod N → ℂ) (M : ℝ) (hM : ∀ j, ‖Φ j‖ ≤ M) (k : ZMod N) :
    ‖𝓕 Φ k‖ ≤ (fsupport Φ).card * M := by
  classical
  rw [ZMod.dft_apply]
  have hsum : ∑ j : ZMod N, stdAddChar (-(j * k)) • Φ j
      = ∑ j ∈ fsupport Φ, stdAddChar (-(j * k)) • Φ j := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have : Φ x = 0 := by
      by_contra h
      exact hx (mem_fsupport.2 h)
    simp [this]
  rw [hsum]
  calc ‖∑ j ∈ fsupport Φ, stdAddChar (-(j * k)) • Φ j‖
      ≤ ∑ j ∈ fsupport Φ, ‖stdAddChar (-(j * k)) • Φ j‖ := norm_sum_le _ _
    _ ≤ ∑ _j ∈ fsupport Φ, M := by
        refine Finset.sum_le_sum fun i _ => ?_
        rw [smul_eq_mul, norm_mul, AddChar.norm_apply, one_mul]
        exact hM i
    _ = (fsupport Φ).card * M := by rw [Finset.sum_const, nsmul_eq_mul]

/-- A function supported in `{a, b}` has a two-term Fourier transform. -/
theorem dft_of_support_pair {Φ : ZMod N → ℂ} {a b : ZMod N} (hab : a ≠ b)
    (hsub : ∀ j, j ≠ a → j ≠ b → Φ j = 0) (k : ZMod N) :
    𝓕 Φ k = stdAddChar (-(a * k)) * Φ a + stdAddChar (-(b * k)) * Φ b := by
  rw [ZMod.dft_apply]
  have hsum : ∑ j : ZMod N, stdAddChar (-(j * k)) • Φ j
      = ∑ j ∈ ({a, b} : Finset (ZMod N)), stdAddChar (-(j * k)) • Φ j := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hx
    simp [hsub x hx.1 hx.2]
  rw [hsum, Finset.sum_pair hab]
  simp [smul_eq_mul]

/-- **The Donoho–Stark uncertainty principle on `ZMod N`.** A nonzero function and its discrete
Fourier transform cannot both be concentrated: the product of the sizes of their supports is at
least `N`. This is the substantive uncertainty statement whose *unhypothesised* version was
disproved in the previous cycle. -/
theorem donoho_stark (Φ : ZMod N → ℂ) (hΦ : Φ ≠ 0) :
    N ≤ (fsupport Φ).card * (fsupport (𝓕 Φ)).card := by
  classical
  obtain ⟨j₀, -, hj₀⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (ZMod N)) (fun j => ‖Φ j‖) ⟨0, mem_univ 0⟩
  set M : ℝ := ‖Φ j₀‖ with hMdef
  have hM : ∀ j, ‖Φ j‖ ≤ M := fun j => hj₀ j (mem_univ j)
  have hMpos : 0 < M := by
    rcases lt_or_eq_of_le (norm_nonneg (Φ j₀)) with h | h
    · exact h
    · exfalso
      apply hΦ
      funext j
      have : ‖Φ j‖ ≤ 0 := by rw [hMdef, ← h] at hM; exact hM j
      simpa using le_antisymm this (norm_nonneg _)
  -- bound on the Fourier side
  have h1 : ∀ k, ‖𝓕 Φ k‖ ≤ (fsupport Φ).card * M := norm_dft_le Φ M hM
  -- bound on the double transform
  have h2 : ‖𝓕 (𝓕 Φ) (-j₀)‖ ≤ (fsupport (𝓕 Φ)).card * ((fsupport Φ).card * M) :=
    norm_dft_le (𝓕 Φ) _ h1 (-j₀)
  have h3 : 𝓕 (𝓕 Φ) (-j₀) = (N : ℂ) • Φ j₀ := by
    have := congrFun (ZMod.dft_dft Φ) (-j₀)
    simpa using this
  rw [h3, norm_smul] at h2
  have h4 : (N : ℝ) * M ≤ (fsupport (𝓕 Φ)).card * ((fsupport Φ).card * M) := by
    simpa using h2
  have h6 : (N : ℝ) * M ≤ ((fsupport Φ).card * (fsupport (𝓕 Φ)).card : ℝ) * M := by
    nlinarith [h4]
  have h5 : (N : ℝ) ≤ (fsupport Φ).card * (fsupport (𝓕 Φ)).card :=
    le_of_mul_le_mul_right h6 hMpos
  exact_mod_cast h5

/-- Additive (AM–GM) form of the uncertainty principle. -/
theorem donoho_stark_am_gm (Φ : ZMod N → ℂ) (hΦ : Φ ≠ 0) :
    4 * N ≤ ((fsupport Φ).card + (fsupport (𝓕 Φ)).card) ^ 2 := by
  have h := donoho_stark Φ hΦ
  zify at h ⊢
  nlinarith [sq_nonneg (((fsupport Φ).card : ℤ) - ((fsupport (𝓕 Φ)).card : ℤ)), h]

/-- The delta function at `a`. -/
noncomputable def delta (a : ZMod N) : ZMod N → ℂ := fun j => if j = a then 1 else 0

theorem dft_delta (a k : ZMod N) : 𝓕 (delta a) k = stdAddChar (-(a * k)) := by
  classical
  rw [ZMod.dft_apply]
  rw [Finset.sum_eq_single a]
  · simp [delta]
  · intro b _ hb
    simp [delta, hb]
  · intro h
    exact absurd (mem_univ a) h

theorem fsupport_delta (a : ZMod N) : fsupport (delta a) = {a} := by
  classical
  ext j
  simp only [mem_fsupport, Finset.mem_singleton, delta]
  constructor
  · intro h
    by_contra hj
    simp [hj] at h
  · rintro rfl
    simp

theorem fsupport_dft_delta (a : ZMod N) : fsupport (𝓕 (delta a)) = Finset.univ := by
  classical
  ext k
  simp only [mem_fsupport, Finset.mem_univ, iff_true, dft_delta]
  intro h
  have : ‖stdAddChar (-(a * k))‖ = 1 := AddChar.norm_apply _ _
  rw [h] at this
  simp at this

/-- **Sharpness of the uncertainty principle.** For a delta function the Donoho–Stark bound is an
equality, so the constant `N` cannot be improved. -/
theorem donoho_stark_sharp (a : ZMod N) :
    (fsupport (delta a)).card * (fsupport (𝓕 (delta a))).card = N := by
  rw [fsupport_delta, fsupport_dft_delta]
  simp [ZMod.card]

/-- Regression against the previous cycle. In `FourierAsFunctor` the *identity* transform on a
two-point space gave support product `1 < 2`; with the genuine two-point Fourier transform the
product is at least `2` for every nonzero function. -/
theorem two_point_uncertainty (Φ : ZMod 2 → ℂ) (hΦ : Φ ≠ 0) :
    2 ≤ (fsupport Φ).card * (fsupport (𝓕 Φ)).card :=
  donoho_stark Φ hΦ

end Uncertainty

/-! ## 3. Arrow-level biduality: functoriality and naturality of the evaluation map -/

section Biduality

variable {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]

/-- The character dual of a homomorphism: precomposition, bundled as a homomorphism of the
character groups. This is the contravariant `Hom(-, ℂ)` operation on arrows. -/
def dualMap (f : A →+ B) : AddChar B ℂ →+ AddChar A ℂ where
  toFun ψ := ψ.compAddMonoidHom f
  map_zero' := by ext a; simp
  map_add' ψ χ := by ext a; simp

@[simp]
theorem dualMap_apply (f : A →+ B) (ψ : AddChar B ℂ) (a : A) : dualMap f ψ a = ψ (f a) := rfl

/-- The dual of an identity is an identity. -/
theorem dualMap_id : dualMap (AddMonoidHom.id A) = AddMonoidHom.id (AddChar A ℂ) := by
  ext ψ a
  simp

/-- **Contravariant functoriality of character duality**, at the level of arrows. -/
theorem dualMap_comp (f : A →+ B) (g : B →+ C) :
    dualMap (g.comp f) = (dualMap f).comp (dualMap g) := by
  ext ψ a
  simp

/-- **Naturality of the biduality evaluation map.** The evaluation morphism
`a ↦ (χ ↦ χ a)` is a natural transformation from the identity functor to the double character
dual. -/
theorem doubleDualEmb_natural (f : A →+ B) (a : A) :
    (doubleDualEmb (f a) : AddChar (AddChar B ℂ) ℂ)
      = dualMap (dualMap f) (doubleDualEmb a) := by
  ext ψ
  simp [dualMap]

section Finite

variable [Finite A] [Finite B]

/-- On finite abelian groups the evaluation map is bijective, so the naturality statement above
upgrades to a **natural isomorphism between the identity and the double dual**: this is the
finite-group form of Pontryagin biduality, in the exact categorical shape produced by the
finite-free transpose equivalence of the previous cycle. -/
theorem doubleDualEquiv_natural (f : A →+ B) (a : A) :
    (doubleDualEquiv (f a) : AddChar (AddChar B ℂ) ℂ)
      = dualMap (dualMap f) (doubleDualEquiv a) := by
  simpa [coe_doubleDualEquiv] using doubleDualEmb_natural f a

theorem doubleDualEmb_bij : Function.Bijective (doubleDualEmb : A → AddChar (AddChar A ℂ) ℂ) :=
  AddChar.doubleDualEmb_bijective

end Finite

end Biduality



/-! ## 4. A prime refinement: Tao's `|supp Φ| + |supp 𝓕Φ| ≥ p + 1` for two-element supports

Donoho–Stark is sharp in general, but for prime modulus Tao's uncertainty principle gives the
strictly stronger additive bound `|supp Φ| + |supp 𝓕Φ| ≥ p + 1`. We prove this bound
unconditionally in the two-element-support case, where it is equivalent to the statement that a
nonzero two-term exponential sum vanishes at most once. -/

section PrimeRefinement

open scoped Classical

variable {p : ℕ} [Fact p.Prime] {Φ : ZMod p → ℂ} {a b : ZMod p}

/-- The Fourier transform of a two-term function vanishes at most once: the exponential
`k ↦ χ((b - a) k)` is injective, so it can take the single obstructing value only once. -/
theorem card_dft_zeros_le_one (hab : a ≠ b) (ha : Φ a ≠ 0)
    (hsub : ∀ j, j ≠ a → j ≠ b → Φ j = 0) :
    ((Finset.univ.filter fun k => 𝓕 Φ k = 0) : Finset (ZMod p)).card ≤ 1 := by
  refine Finset.card_le_one.2 fun k₁ h₁ k₂ h₂ => ?_
  simp only [Finset.mem_filter] at h₁ h₂
  -- from vanishing at `k` we read off the value of the character at `(b - a) * k`
  have key : ∀ k : ZMod p, 𝓕 Φ k = 0 → stdAddChar ((b - a) * k) * Φ a = -Φ b := by
    intro k hk
    have hsplit : stdAddChar (-(a * k)) = stdAddChar (-(b * k)) * stdAddChar ((b - a) * k) := by
      rw [← AddChar.map_add_eq_mul]
      congr 1
      ring
    rw [dft_of_support_pair hab hsub k, hsplit] at hk
    have hne : (stdAddChar (-(b * k)) : ℂ) ≠ 0 := by
      intro h
      have : ‖stdAddChar (-(b * k))‖ = 1 := AddChar.norm_apply _ _
      rw [h] at this
      simp at this
    have : stdAddChar (-(b * k)) * (stdAddChar ((b - a) * k) * Φ a + Φ b) = 0 := by
      rw [← hk]; ring
    rcases mul_eq_zero.1 this with h | h
    · exact absurd h hne
    · linear_combination h
  have e1 := key k₁ h₁.2
  have e2 := key k₂ h₂.2
  have hchar : stdAddChar ((b - a) * k₁) = stdAddChar ((b - a) * k₂) := by
    have : stdAddChar ((b - a) * k₁) * Φ a = stdAddChar ((b - a) * k₂) * Φ a := by
      rw [e1, e2]
    exact mul_right_cancel₀ ha this
  have harg : (b - a) * k₁ = (b - a) * k₂ := ZMod.injective_stdAddChar hchar
  have hba : b - a ≠ 0 := sub_ne_zero.2 (Ne.symm hab)
  exact mul_left_cancel₀ hba harg

/-- **Tao's uncertainty bound, two-element case.** For prime modulus, a function supported on
exactly two points has Fourier support of size at least `p - 1`; equivalently the sum of the two
support sizes is at least `p + 1`. -/
theorem tao_dft_support_ge (hab : a ≠ b) (ha : Φ a ≠ 0)
    (hsub : ∀ j, j ≠ a → j ≠ b → Φ j = 0) :
    p - 1 ≤ (fsupport (𝓕 Φ)).card := by
  have hcompl : fsupport (𝓕 Φ) = (Finset.univ.filter fun k => 𝓕 Φ k = 0)ᶜ := by
    ext k
    simp [fsupport]
  have hcard : (fsupport (𝓕 Φ)).card
      = p - ((Finset.univ.filter fun k => 𝓕 Φ k = 0) : Finset (ZMod p)).card := by
    rw [hcompl, Finset.card_compl]
    simp [ZMod.card]
  rw [hcard]
  have := card_dft_zeros_le_one hab ha hsub
  omega

theorem fsupport_of_pair (hab : a ≠ b) (ha : Φ a ≠ 0) (hb : Φ b ≠ 0)
    (hsub : ∀ j, j ≠ a → j ≠ b → Φ j = 0) :
    fsupport Φ = {a, b} := by
  ext j
  simp only [mem_fsupport, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro h
    by_contra hj
    push_neg at hj
    exact h (hsub j hj.1 hj.2)
  · rintro (rfl | rfl)
    · exact ha
    · exact hb

/-- **Tao's additive uncertainty principle, two-element case.** -/
theorem tao_uncertainty_pair (hab : a ≠ b) (ha : Φ a ≠ 0) (hb : Φ b ≠ 0)
    (hsub : ∀ j, j ≠ a → j ≠ b → Φ j = 0) :
    p + 1 ≤ (fsupport Φ).card + (fsupport (𝓕 Φ)).card := by
  have hp : 1 ≤ p := (Fact.out (p := p.Prime)).one_lt.le.trans' (by norm_num)
  have h2 : (fsupport Φ).card = 2 := by
    rw [fsupport_of_pair hab ha hb hsub, Finset.card_insert_of_notMem (by simpa using hab),
      Finset.card_singleton]
  have := tao_dft_support_ge hab ha hsub
  omega

/-- For `p ≥ 5` the prime bound is *strictly stronger* than what Donoho–Stark gives for a
two-element support: Donoho–Stark only yields `|supp 𝓕Φ| ≥ p / 2`. -/
theorem tao_beats_donoho_stark (hp : 5 ≤ p) (hab : a ≠ b) (ha : Φ a ≠ 0) (hb : Φ b ≠ 0)
    (hsub : ∀ j, j ≠ a → j ≠ b → Φ j = 0) :
    2 * (fsupport (𝓕 Φ)).card > p := by
  have h2 : (fsupport Φ).card = 2 := by
    rw [fsupport_of_pair hab ha hb hsub, Finset.card_insert_of_notMem (by simpa using hab),
      Finset.card_singleton]
  have := tao_dft_support_ge hab ha hsub
  omega

end PrimeRefinement


/-! ## 5. Primality is essential: a composite counterexample to the Tao bound

For `N = 4` the indicator function of the subgroup `{0, 2}` is a fixed point of the Fourier
transform up to scale: both it and its transform have support of size two. Hence the additive
bound `|supp Φ| + |supp 𝓕Φ| ≥ N + 1` **fails** for composite modulus, while Donoho–Stark
`|supp Φ| * |supp 𝓕Φ| ≥ N` holds with equality. So the extremals of the multiplicative bound are
not only delta functions: subgroup indicators are extremal too. -/

section CompositeCounterexample

open scoped Classical

/-- The indicator function of the subgroup `{0, 2} ⊆ ZMod 4`. -/
noncomputable def subgroupIndicator : ZMod 4 → ℂ := fun j => if j = 0 ∨ j = 2 then 1 else 0

theorem stdAddChar_two_four : ZMod.stdAddChar (2 : ZMod 4) = -1 := by
  rw [show (2 : ZMod 4) = ((2 : ℤ) : ZMod 4) by norm_num, ZMod.stdAddChar_coe]
  rw [show (2 * (Real.pi : ℂ) * Complex.I * ((2 : ℤ) : ℂ) / (4 : ℕ) : ℂ)
      = (Real.pi : ℂ) * Complex.I by push_cast; ring]
  exact Complex.exp_pi_mul_I

theorem dft_subgroupIndicator (k : ZMod 4) :
    𝓕 subgroupIndicator k = 1 + stdAddChar (-(2 * k)) := by
  have h := dft_of_support_pair (Φ := subgroupIndicator) (a := 0) (b := 2) (by decide)
    (by intro j h1 h2; simp [subgroupIndicator, h1, h2]) k
  simp [subgroupIndicator] at h
  rw [h]

theorem cases_zmod_four : ∀ k : ZMod 4, k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 := by decide

theorem dft_subgroupIndicator_zero : 𝓕 subgroupIndicator 0 ≠ 0 := by
  rw [dft_subgroupIndicator, show (-(2 * (0 : ZMod 4))) = 0 from by decide,
    AddChar.map_zero_eq_one]
  norm_num

theorem dft_subgroupIndicator_two : 𝓕 subgroupIndicator 2 ≠ 0 := by
  rw [dft_subgroupIndicator, show (-(2 * (2 : ZMod 4))) = 0 from by decide,
    AddChar.map_zero_eq_one]
  norm_num

theorem dft_subgroupIndicator_one : 𝓕 subgroupIndicator 1 = 0 := by
  rw [dft_subgroupIndicator, show (-(2 * (1 : ZMod 4))) = 2 from by decide, stdAddChar_two_four]
  ring

theorem dft_subgroupIndicator_three : 𝓕 subgroupIndicator 3 = 0 := by
  rw [dft_subgroupIndicator, show (-(2 * (3 : ZMod 4))) = 2 from by decide, stdAddChar_two_four]
  ring

theorem fsupport_subgroupIndicator : fsupport subgroupIndicator = {0, 2} := by
  ext k
  simp only [mem_fsupport, Finset.mem_insert, Finset.mem_singleton, subgroupIndicator]
  rcases cases_zmod_four k with rfl | rfl | rfl | rfl <;> norm_num <;> decide

theorem fsupport_dft_subgroupIndicator : fsupport (𝓕 subgroupIndicator) = {0, 2} := by
  ext k
  simp only [mem_fsupport, Finset.mem_insert, Finset.mem_singleton]
  rcases cases_zmod_four k with rfl | rfl | rfl | rfl
  · simp [dft_subgroupIndicator_zero]
  · simp [dft_subgroupIndicator_one]; decide
  · simp [dft_subgroupIndicator_two]
  · simp [dft_subgroupIndicator_three]; decide

theorem card_fsupport_subgroupIndicator : (fsupport subgroupIndicator).card = 2 := by
  rw [fsupport_subgroupIndicator]
  decide

theorem card_fsupport_dft_subgroupIndicator : (fsupport (𝓕 subgroupIndicator)).card = 2 := by
  rw [fsupport_dft_subgroupIndicator]
  decide

/-- **Donoho–Stark is attained by a non-delta extremal.** -/
theorem donoho_stark_sharp_subgroup :
    (fsupport subgroupIndicator).card * (fsupport (𝓕 subgroupIndicator)).card = 4 := by
  rw [card_fsupport_subgroupIndicator, card_fsupport_dft_subgroupIndicator]

/-- **Primality is essential in the Tao bound.** For the composite modulus `N = 4` there is a
nonzero function with `|supp Φ| + |supp 𝓕Φ| = 4 < N + 1`, so `tao_uncertainty_pair` cannot be
extended from primes to arbitrary moduli. -/
theorem tao_bound_fails_for_composite :
    (fsupport subgroupIndicator).card + (fsupport (𝓕 subgroupIndicator)).card < 4 + 1 := by
  rw [card_fsupport_subgroupIndicator, card_fsupport_dft_subgroupIndicator]
  norm_num

end CompositeCounterexample

end FourierUncertainty