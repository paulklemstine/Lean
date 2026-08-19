import Mathlib

/-! # CatalogBuild.Bridges.IdempotentCollapse

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14
-/

noncomputable section

open Set

variable {α L K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- [Section: # CatalogBuild.Bridges.IdempotentCollapse
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14] -/
theorem idempotent_image_eq_fixedPoints (f : α → α) (hf : f ∘ f = f) :
    range f = {x | f x = x} := by
  ext x;
  exact ⟨ by rintro ⟨ y, rfl ⟩ ; exact congr_fun hf y, fun hx => ⟨ x, hx ⟩ ⟩

/-- [Section: # CatalogBuild.Bridges.IdempotentCollapse
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14] -/
theorem idempotent_fixes_range (f : α → α) (hf : f ∘ f = f) :
    ∀ y ∈ range f, f y = y := by
  simp_all +decide [ funext_iff ]

theorem idempotent_iterate (f : α → α) (hf : f ∘ f = f) (n : ℕ) (hn : 0 < n) :
    f^[n] = f := by
  induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ]

theorem commuting_idempotents_compose (f g : α → α)
    (hf : f ∘ f = f) (hg : g ∘ g = g) (hcomm : f ∘ g = g ∘ f) :
    (f ∘ g) ∘ (f ∘ g) = f ∘ g := by
  simp_all +decide [ funext_iff, forall_const ]

theorem id_idempotent' : (id : α → α) ∘ id = id := by
  rfl

theorem const_idempotent (a : α) : (fun _ : α => a) ∘ (fun _ : α => a) = (fun _ : α => a) := by
  rfl

theorem idempotent_card_fixedPoints_eq_range {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : f ∘ f = f) :
    (Finset.univ.filter (fun x => f x = x)).card = (Finset.univ.image f).card := by
  exact congr_arg Finset.card ( Finset.ext fun x => ⟨ fun hx => Finset.mem_image.2 ⟨ x, Finset.mem_univ _, by simpa using hx ⟩, fun hx => by obtain ⟨ y, _, hy ⟩ := Finset.mem_image.1 hx; have := congr_fun hf y; aesop ⟩ )

theorem tropical_min_idempotent (x : ℝ) : min x x = x := by
  exact min_self x

theorem clamp_idempotent (x : ℝ) :
    max 0 (min 1 (max 0 (min 1 x))) = max 0 (min 1 x) := by
  grind

theorem idempotent_lattice_inf [SemilatticeInf L] (a : L) :
    (fun x => a ⊓ x) ∘ (fun x => a ⊓ x) = fun x => a ⊓ x := by
  grind +splitImp

theorem idempotent_lattice_sup [SemilatticeSup L] (a : L) :
    (fun x => a ⊔ x) ∘ (fun x => a ⊔ x) = fun x => a ⊔ x := by
  ext x;
  simp +decide [ sup_assoc ]

theorem idempotent_linear_map_range_id (f : V →ₗ[K] V) (hf : f.comp f = f) :
    ∀ v ∈ LinearMap.range f, f v = v := by
  simp_all +decide [ LinearMap.ext_iff ]

theorem idempotent_range_ker_compl (f : V →ₗ[K] V) (hf : f.comp f = f) :
    LinearMap.range f ⊓ LinearMap.ker f = ⊥ := by
  simp_all +decide [ Submodule.eq_bot_iff ];
  simp_all +decide [ LinearMap.ext_iff ]

theorem idempotent_decomposition (f : V →ₗ[K] V) (hf : f.comp f = f) (v : V) :
    f (v - f v) = 0 := by
  rw [ map_sub, sub_eq_zero ];
  exact LinearMap.congr_fun hf.symm v

end