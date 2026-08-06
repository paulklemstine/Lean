import Catalog.Computation.FourierFunctor.Duality

/-!
# The Fourier transform as a natural isomorphism of functors

We realise the Fourier transform of a finite abelian group as a *natural
transformation* between two functors `FinAb ⥤ ModuleCat ℂ`:

* `functionsFunctor : FinAb ⥤ ModuleCat ℂ` sends `G` to the group algebra
  `ℂ[G] = (G → ℂ)`; a homomorphism `φ : G ⟶ H` acts by **integration along the
  fibres** (pushforward of measures), `f ↦ (h ↦ ∑_{φ g = h} f g)`;
* `dualFunctionsFunctor : FinAb ⥤ ModuleCat ℂ` sends `G` to functions on the
  dual group `(Ĝ → ℂ)`; a homomorphism `φ : G ⟶ H` acts by **restriction of
  characters** along `φ̂ : Ĥ → Ĝ`;
* `fourierNatTrans : functionsFunctor ⟶ dualFunctionsFunctor` is the Fourier
  transform, `𝓕 f (ψ) = ∑_g f g · ψ(-g)`.

The naturality square is exactly the *Poisson-type* statement "the Fourier
transform turns integration along the fibres of `φ` into restriction along
`φ̂`", and Fourier inversion says that this natural transformation is a natural
**isomorphism** (`fourierNatIso`).

-- !-- Lab Notes -- !--

* Hypothesizer: `𝓕` is not merely a family of linear isomorphisms but a natural
  isomorphism, *provided* the covariant functoriality on the source is taken to
  be fibrewise summation (pushforward), not pullback.
* Experimenter: taking pullback on both sides fails on type-checking grounds —
  `φ̂` points the wrong way — which is the categorical reason the Fourier
  transform must be paired with pushforward.  The naturality proof reduces to a
  `Finset.sum_comm` plus a `Finset.sum_eq_single` collapse of the fibre sum.
* Analyst: the two orthogonality relations (`AddChar.sum_apply_eq_ite` over the
  dual, `AddChar.sum_eq_ite` over the group) are exactly the two triangle-like
  identities needed for `𝓕` and `𝓕⁻¹` to be mutually inverse; they are the
  analytic incarnation of the two triangle identities of `pontryagin`.
* Critic: the normalisation `|G|⁻¹` is forced; without it `𝓕` is still natural
  but no longer an isomorphism of the *same* two functors on the nose.  The
  hypothesis `Fintype G` is essential (an infinite discrete group has no finite
  Haar normalisation).
-/

open CategoryTheory AddChar Finset

namespace FourierFunctor

section Core

variable {G H : Type} [AddCommGroup G] [Fintype G] [AddCommGroup H] [Fintype H]

/-! ### Pushforward of functions along a homomorphism -/

open scoped Classical in
/-- Integration along the fibres: `(φ_* f) h = ∑_{φ g = h} f g`. -/
noncomputable def pushforward (φ : G →+ H) : (G → ℂ) →ₗ[ℂ] (H → ℂ) where
  toFun f := fun h => ∑ g : G, if φ g = h then f g else 0
  map_add' f₁ f₂ := by
    funext h
    simp only [Pi.add_apply]
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun g _ => by split <;> simp
  map_smul' c f := by
    funext h
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    exact Finset.sum_congr rfl fun g _ => by split <;> simp

open scoped Classical in
omit [Fintype H] in
lemma pushforward_apply (φ : G →+ H) (f : G → ℂ) (h : H) :
    pushforward φ f h = ∑ g : G, if φ g = h then f g else 0 := rfl

open scoped Classical in
/-- Pushing forward along the identity does nothing. -/
theorem pushforward_id : pushforward (AddMonoidHom.id G) = LinearMap.id := by
  refine LinearMap.ext fun f => funext fun g => ?_
  rw [pushforward_apply]
  simp only [AddMonoidHom.id_apply, LinearMap.id_coe, id_eq]
  rw [Finset.sum_ite_eq' Finset.univ g f]
  simp

open scoped Classical in
/-- Pushforward is functorial: summing over fibres of a composite equals
iterated summation over fibres. -/
theorem pushforward_comp {K : Type} [AddCommGroup K] [Fintype K] (φ : G →+ H) (ψ : H →+ K) :
    pushforward (ψ.comp φ) = (pushforward ψ).comp (pushforward φ) := by
  refine LinearMap.ext fun f => funext fun k => ?_
  simp only [pushforward_apply, LinearMap.coe_comp, Function.comp_apply, AddMonoidHom.coe_comp]
  rw [show (∑ h : H, if ψ h = k then (∑ g : G, if φ g = h then f g else 0) else 0)
      = ∑ h : H, ∑ g : G, if ψ h = k then (if φ g = h then f g else 0) else 0 from
    Finset.sum_congr rfl fun h _ => by split <;> simp]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun g _ => ?_
  rw [Finset.sum_eq_single (φ g)]
  · simp
  · intro h _ hne
    by_cases hk : ψ h = k <;> simp [hk, Ne.symm hne]
  · simp

/-! ### The Fourier transform and its inverse -/

/-- The **Fourier transform** `𝓕 f (ψ) = ∑_g f g · ψ(-g)`. -/
noncomputable def fourier : (G → ℂ) →ₗ[ℂ] (AddChar G ℂ → ℂ) where
  toFun f := fun ψ => ∑ g : G, f g * ψ (-g)
  map_add' f₁ f₂ := by
    funext ψ
    simp only [Pi.add_apply]
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun g _ => by ring
  map_smul' c f := by
    funext ψ
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    exact Finset.sum_congr rfl fun g _ => by ring

lemma fourier_apply (f : G → ℂ) (ψ : AddChar G ℂ) :
    fourier f ψ = ∑ g : G, f g * ψ (-g) := rfl

/-- The **inverse Fourier transform** `𝓕⁻¹ F (g) = |G|⁻¹ ∑_ψ F ψ · ψ g`. -/
noncomputable def fourierInv : (AddChar G ℂ → ℂ) →ₗ[ℂ] (G → ℂ) where
  toFun F := fun g => (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, F ψ * ψ g
  map_add' F₁ F₂ := by
    funext g
    simp only [Pi.add_apply]
    rw [← mul_add, ← Finset.sum_add_distrib]
    exact congrArg _ (Finset.sum_congr rfl fun ψ _ => by ring)
  map_smul' c F := by
    funext g
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    have h : ∀ ψ : AddChar G ℂ, (c * F ψ) * ψ g = c * (F ψ * ψ g) := fun ψ => by ring
    rw [Finset.sum_congr rfl fun ψ _ => h ψ, ← Finset.mul_sum]
    ring

lemma fourierInv_apply (F : AddChar G ℂ → ℂ) (g : G) :
    fourierInv F g = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, F ψ * ψ g := rfl

lemma card_ne_zero_complex : ((Fintype.card G : ℂ)) ≠ 0 := by
  exact_mod_cast Nat.cast_ne_zero.2 (Fintype.card_ne_zero (α := G))

/-- **Fourier inversion.** -/
theorem fourierInv_fourier (f : G → ℂ) : fourierInv (fourier (G := G) f) = f := by
  classical
  funext g
  rw [fourierInv_apply]
  have step : ∀ ψ : AddChar G ℂ, fourier f ψ * ψ g = ∑ h : G, f h * ψ (g - h) := by
    intro ψ
    rw [fourier_apply, Finset.sum_mul]
    refine Finset.sum_congr rfl fun h _ => ?_
    rw [sub_eq_add_neg, ψ.map_add_eq_mul]
    ring
  rw [Finset.sum_congr rfl fun ψ _ => step ψ, Finset.sum_comm]
  have inner : ∀ h : G, (∑ ψ : AddChar G ℂ, f h * ψ (g - h))
      = f h * (if g - h = 0 then (Fintype.card G : ℂ) else 0) := by
    intro h
    rw [← Finset.mul_sum, AddChar.sum_apply_eq_ite]
  rw [Finset.sum_congr rfl fun h _ => inner h]
  have : ∀ h : G, f h * (if g - h = 0 then (Fintype.card G : ℂ) else 0)
      = if h = g then f h * (Fintype.card G : ℂ) else 0 := by
    intro h
    by_cases hh : h = g
    · simp [hh]
    · rw [if_neg hh, if_neg (by simpa [sub_eq_zero] using fun hgh => hh hgh.symm), mul_zero]
  rw [Finset.sum_congr rfl fun h _ => this h, Finset.sum_ite_eq' Finset.univ g]
  simp only [Finset.mem_univ, if_true]
  field_simp

/-- **Plancherel/inversion in the other order**: the Fourier transform is
surjective onto functions on the dual group. -/
theorem fourier_fourierInv (F : AddChar G ℂ → ℂ) : fourier (fourierInv (G := G) F) = F := by
  classical
  funext ψ
  rw [fourier_apply]
  have step : ∀ g : G, fourierInv F g * ψ (-g)
      = (Fintype.card G : ℂ)⁻¹ * ∑ χ : AddChar G ℂ, F χ * ((χ - ψ) g) := by
    intro g
    rw [fourierInv_apply, mul_assoc, Finset.sum_mul]
    refine congrArg _ (Finset.sum_congr rfl fun χ _ => ?_)
    rw [AddChar.sub_apply]
    ring
  rw [Finset.sum_congr rfl fun g _ => step g, ← Finset.mul_sum, Finset.sum_comm]
  have inner : ∀ χ : AddChar G ℂ, (∑ g : G, F χ * ((χ - ψ) g))
      = F χ * (if χ = ψ then (Fintype.card G : ℂ) else 0) := by
    intro χ
    rw [← Finset.mul_sum, AddChar.sum_eq_ite (χ - ψ)]
    by_cases h : χ = ψ <;> simp [h, sub_eq_zero]
  rw [Finset.sum_congr rfl fun χ _ => inner χ]
  have : ∀ χ : AddChar G ℂ, F χ * (if χ = ψ then (Fintype.card G : ℂ) else 0)
      = if χ = ψ then F χ * (Fintype.card G : ℂ) else 0 := by
    intro χ; by_cases h : χ = ψ <;> simp [h]
  rw [Finset.sum_congr rfl fun χ _ => this χ, Finset.sum_ite_eq' Finset.univ ψ]
  simp only [Finset.mem_univ, if_true]
  field_simp

/-- The Fourier transform as a linear equivalence `ℂ[G] ≃ ℂ[Ĝ]`. -/
noncomputable def fourierEquiv : (G → ℂ) ≃ₗ[ℂ] (AddChar G ℂ → ℂ) where
  toLinearMap := fourier
  invFun := fourierInv
  left_inv := fourierInv_fourier
  right_inv := fourier_fourierInv

/-! ### Naturality -/

/-- **The naturality identity for the Fourier transform.**  Transforming a
pushed-forward function is the same as restricting the transform along the dual
homomorphism: `𝓕_H (φ_* f) = (𝓕_G f) ∘ φ̂`. -/
theorem fourier_pushforward (φ : G →+ H) (f : G → ℂ) (ψ : AddChar H ℂ) :
    fourier (pushforward φ f) ψ = fourier f (dualHom φ ψ) := by
  classical
  rw [fourier_apply, fourier_apply]
  have step : ∀ h : H, (pushforward φ f h) * ψ (-h)
      = ∑ g : G, if φ g = h then f g * ψ (-h) else 0 := by
    intro h
    rw [pushforward_apply, Finset.sum_mul]
    exact Finset.sum_congr rfl fun g _ => by split <;> simp
  rw [Finset.sum_congr rfl fun h _ => step h, Finset.sum_comm]
  refine Finset.sum_congr rfl fun g _ => ?_
  rw [Finset.sum_eq_single (φ g)]
  · simp [map_neg]
  · intro h _ hne
    simp [Ne.symm hne]
  · simp

end Core

/-! ### The two functors and the natural isomorphism -/

/-- `G ↦ ℂ[G]`, with pushforward (integration along fibres) as functorial
action. -/
noncomputable def functionsFunctor : FinAb ⥤ ModuleCat.{0} ℂ where
  obj G := ModuleCat.of ℂ (FinAb.carrier G → ℂ)
  map {G H} f := ModuleCat.ofHom (pushforward (FinAb.hom f))
  map_id G := by
    apply ModuleCat.hom_ext
    simpa using pushforward_id (G := FinAb.carrier G)
  map_comp {G H K} f g := by
    apply ModuleCat.hom_ext
    simpa using pushforward_comp (FinAb.hom f) (FinAb.hom g)

/-- `G ↦ ℂ[Ĝ]`, with restriction of characters as functorial action. -/
noncomputable def dualFunctionsFunctor : FinAb ⥤ ModuleCat.{0} ℂ where
  obj G := ModuleCat.of ℂ (AddChar (FinAb.carrier G) ℂ → ℂ)
  map {G H} f := ModuleCat.ofHom (LinearMap.funLeft ℂ ℂ (dualHom (FinAb.hom f)))
  map_id G := by
    apply ModuleCat.hom_ext
    refine LinearMap.ext fun F => funext fun ψ => ?_
    rfl
  map_comp {G H K} f g := by
    apply ModuleCat.hom_ext
    refine LinearMap.ext fun F => funext fun ψ => ?_
    rfl

/-- **The Fourier transform is a natural transformation** from the group-algebra
functor to the functor of functions on the dual group. -/
noncomputable def fourierNatTrans : functionsFunctor ⟶ dualFunctionsFunctor where
  app G := ModuleCat.ofHom (fourier (G := FinAb.carrier G))
  naturality {G H} f := by
    apply ModuleCat.hom_ext
    refine LinearMap.ext fun u => funext fun ψ => ?_
    exact fourier_pushforward (FinAb.hom f) u ψ

/-- **The Fourier transform is a natural isomorphism**: Fourier inversion,
functorially.  This is the categorical form of "Fourier analysis is an
equivalence between the group algebra and functions on the dual group". -/
noncomputable def fourierNatIso : functionsFunctor ≅ dualFunctionsFunctor :=
  NatIso.ofComponents
    (fun G => (fourierEquiv (G := FinAb.carrier G)).toModuleIso)
    (fun f => fourierNatTrans.naturality f)

lemma fourierNatIso_hom_app (G : FinAb) :
    (fourierNatIso.hom.app G).hom = fourier (G := FinAb.carrier G) := rfl

end FourierFunctor