/-! # CatalogBuild.Physics.ArchitectureOfReality.TropicalLanglands

Auto-generated from theorem catalog database.
Domain: Physics/ArchitectureOfReality
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A tropical character of a group G is a group homomorphism G → (ℝ, +). -/
def IsTropChar {G : Type*} [Group G] (χ : G → ℝ) : Prop :=
  χ 1 = 0 ∧ ∀ g h, χ (g * h) = χ g + χ h


/-- The trivial tropical character sends everything to 0 -/
theorem trop_char_trivial {G : Type*} [Group G] :
    IsTropChar (fun (_ : G) => (0 : ℝ)) :=
  ⟨rfl, fun _ _ => (add_zero 0).symm⟩


/-- Tropical character of the inverse: χ(g⁻¹) = -χ(g) -/
theorem trop_char_inv {G : Type*} [Group G] (χ : G → ℝ) (hχ : IsTropChar χ)
    (g : G) : χ g⁻¹ = -χ g := by
  have h := hχ.2 g g⁻¹
  simp only [mul_inv_cancel] at h
  linarith [hχ.1]


/-- Tropical character of powers: χ(gⁿ) = n · χ(g) -/
theorem trop_char_pow {G : Type*} [Group G] (χ : G → ℝ) (hχ : IsTropChar χ)
    (g : G) (n : ℕ) : χ (g ^ n) = n * χ g := by
  induction n with
  | zero => simp [hχ.1]
  | succ n ih => rw [pow_succ, hχ.2, ih]; push_cast; ring


/-- [Section: ## Section 1: Tropical Characters] -/
theorem trop_char_finite_trivial {G : Type*} [Group G] [Fintype G]
    (χ : G → ℝ) (hχ : IsTropChar χ) (g : G) : χ g = 0 := by
  simp_all +decide [ IsTropChar ];
  -- By induction on $n$, we can show that $\chi(g^n) = n \cdot \chi(g)$ for any natural number $n$.
  have h_ind : ∀ n : ℕ, χ (g ^ n) = n * χ g := by
    intro n; induction n <;> simp_all +decide [ pow_succ, add_mul ] ;
  specialize h_ind ( Fintype.card G ) ; simp_all +decide [ pow_card_eq_one ] ;


/-- The sum of two tropical characters is a tropical character -/
theorem trop_char_add {G : Type*} [Group G] (χ ψ : G → ℝ)
    (hχ : IsTropChar χ) (hψ : IsTropChar ψ) :
    IsTropChar (fun g => χ g + ψ g) := by
  constructor
  · simp [hχ.1, hψ.1]
  · intro g h; simp [hχ.2 g h, hψ.2 g h]; ring


/-- Scaling a tropical character gives a tropical character -/
theorem trop_char_scale {G : Type*} [Group G] (χ : G → ℝ) (c : ℝ)
    (hχ : IsTropChar χ) :
    IsTropChar (fun g => c * χ g) := by
  constructor
  · simp [hχ.1]
  · intro g h; simp [hχ.2 g h, mul_add]


/-- The tropical Fourier transform of f at character χ. -/
def tropFourier {G : Type*} [Fintype G] [Nonempty G] [DecidableEq G]
    (f : G → ℝ) (χ : G → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun g => f g + χ g)


/-- The tropical convolution: (f ⊛ g)(h) = max_x {f(x) + g(x⁻¹h)} -/
def tropConv {G : Type*} [Group G] [Fintype G] [Nonempty G] [DecidableEq G]
    (f g : G → ℝ) (h : G) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun x => f x + g (x⁻¹ * h))


/-- A tropical Hecke operator acts on functions f : G → ℝ -/
structure TropHeckeOp (G : Type*) where
  action : (G → ℝ) → G → ℝ


/-- A tropical eigenform satisfies T f = c + f (additive shift) -/
def IsTropEigenform {G : Type*} (T : TropHeckeOp G) (f : G → ℝ) (eigenval : ℝ) : Prop :=
  ∀ g, T.action f g = eigenval + f g


/-- In the tropical semiring, every element is additively idempotent. -/
theorem tropical_universal_idempotent (a : ℝ) : max a a = a := max_self a


end
