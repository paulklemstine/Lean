/-! # CatalogBuild.Bridges.IdempotentCollapse

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14
-/

import Mathlib

noncomputable section

theorem idempotent_image_eq_fixedPoints (f : α → α) (hf : f ∘ f = f) :
    range f = {x | f x = x} := by
  ext x;
  exact ⟨ by rintro ⟨ y, rfl ⟩ ; exact congr_fun hf y, fun hx => ⟨ x, hx ⟩ ⟩

/-
An idempotent function fixes every element in its range.
-/

theorem idempotent_fixes_range (f : α → α) (hf : f ∘ f = f) :
    ∀ y ∈ range f, f y = y := by
  simp_all +decide [ funext_iff ]

/-
Composing an idempotent with itself any positive number of times yields itself.
-/

theorem idempotent_iterate (f : α → α) (hf : f ∘ f = f) (n : ℕ) (hn : 0 < n) :
    f^[n] = f := by
  induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ]

/-
If two idempotent functions commute, their composition is also idempotent.
-/

theorem commuting_idempotents_compose (f g : α → α)
    (hf : f ∘ f = f) (hg : g ∘ g = g) (hcomm : f ∘ g = g ∘ f) :
    (f ∘ g) ∘ (f ∘ g) = f ∘ g := by
  simp_all +decide [ funext_iff, forall_const ]

/-
The identity function is idempotent.
-/

theorem id_idempotent' : (id : α → α) ∘ id = id := by
  rfl

/-
A constant function is idempotent.
-/

theorem const_idempotent (a : α) : (fun _ : α => a) ∘ (fun _ : α => a) = (fun _ : α => a) := by
  rfl

/-! ## Idempotent on Finite Types -/

/-
For a finite type, the number of fixed points of an idempotent equals
    the cardinality of its range (as a Finset).
-/

theorem idempotent_card_fixedPoints_eq_range {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : f ∘ f = f) :
    (Finset.univ.filter (fun x => f x = x)).card = (Finset.univ.image f).card := by
  exact congr_arg Finset.card ( Finset.ext fun x => ⟨ fun hx => Finset.mem_image.2 ⟨ x, Finset.mem_univ _, by simpa using hx ⟩, fun hx => by obtain ⟨ y, _, hy ⟩ := Finset.mem_image.1 hx; have := congr_fun hf y; aesop ⟩ )

/-! ## Tropical Idempotence -/

/-
max is idempotent: max(x, x) = x. This is the idempotent law for tropical addition.
-/

theorem tropical_min_idempotent (x : ℝ) : min x x = x := by
  exact min_self x

/-
ReLU is idempotent: ReLU(ReLU(x)) = ReLU(x).
-/

theorem clamp_idempotent (x : ℝ) :
    max 0 (min 1 (max 0 (min 1 x))) = max 0 (min 1 x) := by
  grind

/-! ## Lattice Idempotence -/

variable {L : Type*}

/-
In a semilattice, the operation a ⊓ · applied twice is the same as once.
-/

theorem idempotent_lattice_inf [SemilatticeInf L] (a : L) :
    (fun x => a ⊓ x) ∘ (fun x => a ⊓ x) = fun x => a ⊓ x := by
  grind +splitImp

/-
In a semilattice, the operation a ⊔ · applied twice is the same as once.
-/

theorem idempotent_lattice_sup [SemilatticeSup L] (a : L) :
    (fun x => a ⊔ x) ∘ (fun x => a ⊔ x) = fun x => a ⊔ x := by
  ext x;
  simp +decide [ sup_assoc ]

/-! ## Linear Algebra: Idempotent Endomorphisms -/

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-
An idempotent linear map restricted to its range is the identity.
-/

theorem idempotent_linear_map_range_id (f : V →ₗ[K] V) (hf : f.comp f = f) :
    ∀ v ∈ LinearMap.range f, f v = v := by
  simp_all +decide [ LinearMap.ext_iff ]

/-
The range and kernel of an idempotent linear map are complementary.
-/

theorem idempotent_range_ker_compl (f : V →ₗ[K] V) (hf : f.comp f = f) :
    LinearMap.range f ⊓ LinearMap.ker f = ⊥ := by
  simp_all +decide [ Submodule.eq_bot_iff ];
  simp_all +decide [ LinearMap.ext_iff ]

/-
Every vector decomposes as f(v) + (v - f(v)) where f(v) ∈ range f and
    v - f(v) ∈ ker f.
-/

theorem idempotent_decomposition (f : V →ₗ[K] V) (hf : f.comp f = f) (v : V) :
    f (v - f v) = 0 := by
  rw [ map_sub, sub_eq_zero ];
  exact LinearMap.congr_fun hf.symm v


end
