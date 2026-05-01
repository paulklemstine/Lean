/-! # CatalogBuild.Speculative.Other.NewTheorems

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 45
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.NewTheorems
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 46] -/
theorem idempotent_count_3 : idempotentCount 3 = 2 := by native_decide


/-- [Section: # CatalogBuild.Speculative.Other.NewTheorems
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 46] -/
theorem idempotent_count_4 : idempotentCount 4 = 2 := by native_decide


/-- [Section: # CatalogBuild.Speculative.Other.NewTheorems
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 46] -/
theorem idempotent_count_5 : idempotentCount 5 = 2 := by native_decide


theorem idempotent_count_10 : idempotentCount 10 = 4 := by native_decide


theorem idempotent_count_12 : idempotentCount 12 = 4 := by native_decide


theorem idempotent_count_15 : idempotentCount 15 = 4 := by native_decide


theorem idempotent_count_210 : idempotentCount 210 = 16 := by native_decide


theorem idem_meet {e f : R} (he : IsIdem e) (hf : IsIdem f) :
    IsIdem (e * f) := by
  unfold IsIdem at *; rw [mul_mul_mul_comm, he, hf]


theorem idem_join {e f : R} (he : IsIdem e) (hf : IsIdem f) :
    IsIdem (e + f - e * f) := by
  unfold IsIdem at *; ring_nf at *; simp_all +decide [ mul_assoc, sq ] ;
  grind


theorem idem_complement_orthogonal {e : R} (he : IsIdem e) :
    e * (1 - e) = 0 := by
  rw [ mul_sub, mul_one, he, sub_self ]


theorem orthogonal_idem_sum {e f : R} (he : IsIdem e) (hf : IsIdem f) (hef : e * f = 0) :
    IsIdem (e + f) := by
  unfold IsIdem at *; ring_nf at *; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;


structure CompleteOrthogonalSystem (n : ℕ) (R : Type*) [Ring R] where
  idems : Fin n → R
  is_idem : ∀ i, idems i * idems i = idems i
  orthogonal : ∀ i j, i ≠ j → idems i * idems j = 0
  complete : ∑ i : Fin n, idems i = 1


def trivialSystem : CompleteOrthogonalSystem 1 R where
  idems := fun _ => 1
  is_idem := fun _ => mul_one 1
  orthogonal := fun i j hij => absurd (Fin.ext_iff.mpr (by omega)) hij
  complete := by simp


theorem peirce_full_decomp {n : ℕ} (sys : CompleteOrthogonalSystem n R) (x : R) :
    x = ∑ i : Fin n, ∑ j : Fin n, sys.idems i * x * sys.idems j := by
  have h_expand : x = (∑ i, sys.idems i) * x * (∑ j, sys.idems j) := by
    rw [ sys.complete, one_mul, mul_one ];
  exact h_expand.trans ( by simp +decide [ Finset.sum_mul _ _ _, Finset.mul_sum, mul_assoc ] )


theorem tropical_max_idem (a : ℝ) : max a a = a := max_self a


theorem tropical_min_idem (a : ℝ) : min a a = a := min_self a


theorem tropical_max_distrib_min (a b c : ℝ) :
    max a (min b c) = min (max a b) (max a c) :=
  max_min_distrib_left a b c


theorem reluFn_idem : ∀ x, reluFn (reluFn x) = reluFn x := by
  intro x; unfold reluFn
  rcases le_total 0 x with h | h
  · simp [max_eq_right (le_refl 0), max_eq_right h]
  · simp [max_eq_left h]


theorem reluFn_preserves_max (a b : ℝ) :
    reluFn (max a b) = max (reluFn a) (reluFn b) := by
  unfold reluFn; simp [max_assoc, max_comm, max_left_comm]


theorem reluFn_master : range reluFn = {x : ℝ | reluFn x = x} := by
  ext y; constructor
  · rintro ⟨x, rfl⟩; exact reluFn_idem x
  · intro hy; exact ⟨y, hy⟩


def vandermondeProd (n : ℕ) (v : Fin n → ℝ) : ℝ :=
  ∏ i : Fin n, ∏ j ∈ (Finset.univ.filter (· > i)), (v j - v i)


theorem vandermonde_collision {n : ℕ} (v : Fin n → ℝ)
    {i j : Fin n} (hij : i < j) (hcoll : v i = v j) :
    vandermondeProd n v = 0 := by
  unfold vandermondeProd
  apply Finset.prod_eq_zero (Finset.mem_univ i)
  apply Finset.prod_eq_zero (i := j)
  · simp [Finset.mem_filter, hij]
  · simp [hcoll]


def gueJointDensity (n : ℕ) (v : Fin n → ℝ) : ℝ :=
  (vandermondeProd n v) ^ 2 * Real.exp (-∑ i : Fin n, v i ^ 2 / 2)


theorem gue_vanishes_collision {n : ℕ} (v : Fin n → ℝ)
    {i j : Fin n} (hij : i < j) (hcoll : v i = v j) :
    gueJointDensity n v = 0 := by
  unfold gueJointDensity; rw [vandermonde_collision v hij hcoll]; simp


theorem gue_nonneg (n : ℕ) (v : Fin n → ℝ) : 0 ≤ gueJointDensity n v :=
  mul_nonneg (sq_nonneg _) (le_of_lt (Real.exp_pos _))


structure MathBridge' (C D : Type*) [Category C] [Category D] where
  fwd : C ⥤ D
  bwd : D ⥤ C


def MathBridge'.comp {C D E : Type*} [Category C] [Category D] [Category E]
    (B₁ : MathBridge' C D) (B₂ : MathBridge' D E) : MathBridge' C E where
  fwd := B₁.fwd ⋙ B₂.fwd
  bwd := B₂.bwd ⋙ B₁.bwd


def MathBridge'.idBridge (C : Type*) [Category C] : MathBridge' C C where
  fwd := 𝟭 C
  bwd := 𝟭 C


def MathBridge'.IsIdem {C : Type*} [Category C] (B : MathBridge' C C) : Prop :=
  Nonempty ((B.comp B).fwd ≅ B.fwd)


theorem mathbridge_id_idempotent (C : Type*) [Category C] :
    (MathBridge'.idBridge C).IsIdem :=
  ⟨Functor.leftUnitor _⟩


structure KaroubiObj (C : Type*) [Category C] where
  obj : C
  idem : obj ⟶ obj
  idem_eq : idem ≫ idem = idem


structure KaroubiHom {C : Type*} [Category C] (X Y : KaroubiObj C) where
  hom : X.obj ⟶ Y.obj
  compat_left : X.idem ≫ hom = hom
  compat_right : hom ≫ Y.idem = hom


def karoubiEmbed {C : Type*} [Category C] (X : C) : KaroubiObj C where
  obj := X
  idem := 𝟙 X
  idem_eq := Category.id_comp _


def karoubiId {C : Type*} [Category C] (X : KaroubiObj C) : KaroubiHom X X where
  hom := X.idem
  compat_left := X.idem_eq
  compat_right := X.idem_eq


def idemLE (e f : R) : Prop :=
  e * e = e ∧ f * f = f ∧ e * f = e ∧ f * e = e


theorem idemLE_refl (e : R) (he : e * e = e) : idemLE e e := ⟨he, he, he, he⟩


theorem idemLE_trans (e f g : R)
    (hef : idemLE e f) (hfg : idemLE f g) : idemLE e g := by
  obtain ⟨he, _, hef1, hef2⟩ := hef
  obtain ⟨_, hg, hfg1, hfg2⟩ := hfg
  refine ⟨he, hg, ?_, ?_⟩
  · calc e * g = e * f * g := by rw [hef1]
      _ = e * (f * g) := by rw [mul_assoc]
      _ = e * f := by rw [hfg1]
      _ = e := hef1
  · calc g * e = g * (f * e) := by rw [hef2]
      _ = (g * f) * e := by rw [← mul_assoc]
      _ = f * e := by rw [hfg2]
      _ = e := hef2


theorem idemLE_zero (e : R) (he : e * e = e) : idemLE 0 e :=
  ⟨by simp, he, by simp, by simp⟩


theorem idemLE_one (e : R) (he : e * e = e) : idemLE e 1 :=
  ⟨he, one_mul 1, mul_one e, one_mul e⟩


def tropicalFourier {G : Type*} [Fintype G] [Nonempty G] [DecidableEq G]
    (f : G → ℝ) (χ : G → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun g => f g + χ g)


theorem idem_identity_on_image {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : y ∈ range O) : O y = y := by
  rw [master_equation' O hO] at hy; exact hy


theorem idem_comp_comm {X : Type*} (O₁ O₂ : X → X)
    (h1 : ∀ x, O₁ (O₁ x) = O₁ x)
    (h2 : ∀ x, O₂ (O₂ x) = O₂ x)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    ∀ x, (O₁ ∘ O₂) ((O₁ ∘ O₂) x) = (O₁ ∘ O₂) x := by
  grind


theorem image_comp_subset {X : Type*} (O₁ O₂ : X → X) :
    range (O₁ ∘ O₂) ⊆ range O₁ := by
  rintro y ⟨x, rfl⟩; exact ⟨O₂ x, rfl⟩


theorem inf_universal_idem {S : Type*} [SemilatticeInf S] (a : S) : a ⊓ a = a := inf_idem a


theorem sup_universal_idem {S : Type*} [SemilatticeSup S] (a : S) : a ⊔ a = a := sup_idem a


end
