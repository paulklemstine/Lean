import Mathlib

/-! # CatalogBuild.Bridges.IdempotentConvergence

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12
-/

noncomputable section

variable {K V α : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- An idempotent linear map satisfies f² - f = 0 -/
theorem idempotent_annihilating_poly (f : V →ₗ[K] V) (hf : f.comp f = f) :
    f.comp f - f = 0 := by
  rwa [sub_eq_zero]

/-- [Section: # CatalogBuild.Bridges.IdempotentConvergence
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem idempotent_complement (f : V →ₗ[K] V) (hf : f.comp f = f) :
    (LinearMap.id - f).comp (LinearMap.id - f) = LinearMap.id - f := by
  simp_all +decide [ LinearMap.ext_iff, LinearMap.comp_apply ]

/-- [Section: # CatalogBuild.Bridges.IdempotentConvergence
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem idempotent_ker_eq_range_complement (f : V →ₗ[K] V) (hf : f.comp f = f) :
    LinearMap.ker f = LinearMap.range (LinearMap.id - f) := by
  exact LinearMap.IsIdempotentElem.ker_eq_range hf

theorem idempotent_range_eq_ker_complement (f : V →ₗ[K] V) (hf : f.comp f = f) :
    LinearMap.range f = LinearMap.ker (LinearMap.id - f) := by
  simp_all +decide [ SetLike.ext_iff, LinearMap.ext_iff ];
  grind

/-- An idempotent function converges in 1 step -/
theorem idempotent_one_step (f : α → α) (hf : f ∘ f = f) (x : α) :
    f (f x) = f x :=
  congr_fun hf x

/-- Iterated application of an idempotent: f^[n+1] = f -/
theorem idempotent_iterate_succ (f : α → α) (hf : f ∘ f = f) (n : ℕ) :
    f^[n + 1] = f := by
  induction n with
  | zero => simp
  | succ n ih =>
    ext x
    show f^[n + 2] x = f x
    rw [Function.iterate_succ_apply']
    show f (f^[n + 1] x) = f x
    rw [show f^[n + 1] = f from ih]
    exact congr_fun hf x

/-- If f is idempotent and g commutes with f, then g preserves fixed points of f -/
theorem idempotent_comm_preserves_fixed (f g : α → α) (hf : f ∘ f = f)
    (hcomm : f ∘ g = g ∘ f) (x : α) (hx : f x = x) :
    f (g x) = g x := by
  have : (f ∘ g) x = (g ∘ f) x := congr_fun hcomm x
  simp [Function.comp_apply] at this
  rwa [hx] at this

theorem idempotent_projection_error (f : V →ₗ[K] V) (hf : f.comp f = f) (v : V) :
    f (v - f v) = 0 := by
  simp +decide [ ← LinearMap.comp_apply, hf ]

/-- An idempotent on a finite set has |range| ≤ |domain| -/
theorem idempotent_range_card_le {β : Type*} [Fintype β] [DecidableEq β]
    (f : β → β) (hf : f ∘ f = f) :
    (Finset.univ.image f).card ≤ Fintype.card β :=
  Finset.card_image_le.trans (le_of_eq Finset.card_univ)

theorem idempotent_full_range_is_id {β : Type*} [Fintype β] [DecidableEq β]
    (f : β → β) (hf : f ∘ f = f)
    (hfull : (Finset.univ.image f).card = Fintype.card β) :
    f = id := by
  -- Since image has full cardinality, f is surjective on a finite type, hence bijective.
  have h_surj : Function.Surjective f := by
    exact fun y => by have := Finset.eq_of_subset_of_card_le ( Finset.subset_univ ( Finset.image f Finset.univ ) ) ( by simp +decide [ hfull ] ) ; replace this := Finset.ext_iff.mp this y; aesop;
  exact funext fun x => by have := congr_fun hf ( h_surj x |> Classical.choose ) ; have := h_surj x |> Classical.choose_spec; aesop;

theorem commuting_idempotent_comp (f g : V →ₗ[K] V)
    (hf : f.comp f = f) (hg : g.comp g = g) (hcomm : f.comp g = g.comp f) :
    (f.comp g).comp (f.comp g) = f.comp g := by
  simp_all +decide [ LinearMap.ext_iff, Function.comp ]

theorem idempotent_zero_or_fixed [Nontrivial V] (f : V →ₗ[K] V) (hf : f.comp f = f) :
    f = 0 ∨ ∃ v : V, v ≠ 0 ∧ f v = v := by
  simp_all +decide [ LinearMap.ext_iff ];
  grind

end