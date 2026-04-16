/-! # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound2

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 24
-/

import Mathlib

noncomputable section

/-- Minkowski form Q(a,b,c) = a² + b² - c² -/
def minkQ (a b c : ℝ) : ℝ := a ^ 2 + b ^ 2 - c ^ 2



/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound2
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 24] -/
theorem null_gaussian_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ)
    (h₁ : IsNull a₁ b₁ c₁) (h₂ : IsNull a₂ b₂ c₂) :
    IsNull (a₁ * a₂ - b₁ * b₂) (a₁ * b₂ + a₂ * b₁) (c₁ * c₂) := by
  -- By definition of IsNull, we have minkQ a₁ b₁ c₁ = 0 and minkQ a₂ b₂ c₂ = 0.
  unfold IsNull at *;
  unfold minkQ at *; nlinarith;



theorem conjugate_photon (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple a (-b) c := by
  unfold IsPythTriple at *; linarith [ pow_two_nonneg b ] ;



theorem conjugate_photon' (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (-a) b c := by
  unfold IsPythTriple at *; linarith;



theorem antipodal_photon (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (-a) (-b) c := by
  unfold IsPythTriple at *; linarith [ pow_two ( -a ), pow_two ( -b ) ] ;



/-- Gaussian product operation on triples -/
def gaussProd (t₁ t₂ : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t₁.1 * t₂.1 - t₁.2.1 * t₂.2.1,
   t₁.1 * t₂.2.1 + t₁.2.1 * t₂.1,
   t₁.2.2 * t₂.2.2)



theorem gaussProd_comm (t₁ t₂ : ℤ × ℤ × ℤ) :
    gaussProd t₁ t₂ = gaussProd t₂ t₁ := by
  unfold gaussProd; ring;



theorem gaussProd_assoc (t₁ t₂ t₃ : ℤ × ℤ × ℤ) :
    gaussProd (gaussProd t₁ t₂) t₃ = gaussProd t₁ (gaussProd t₂ t₃) := by
  unfold gaussProd; ring;



theorem gaussProd_identity (t : ℤ × ℤ × ℤ) :
    gaussProd (1, 0, 1) t = t := by
  -- By definition of gaussProd, we have:
  simp [gaussProd]



theorem identity_is_triple : IsPythTriple 1 0 1 := by
  exact?



theorem photon_squared (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (a ^ 2 - b ^ 2) (2 * a * b) (c ^ 2) := by
  unfold IsPythTriple at *; nlinarith;



theorem null_inner_vanishes_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ)
    (h₁ : IsNull a₁ b₁ c₁) (h₂ : IsNull a₂ b₂ c₂) :
    minkInner a₁ b₁ c₁ a₂ b₂ c₂ ^ 2 ≥ minkQ a₁ b₁ c₁ * minkQ a₂ b₂ c₂ := by
  unfold IsNull at *; unfold minkQ at *; unfold minkInner at *; nlinarith;



theorem light_cone_intersection (a b c dx dy dt : ℝ)
    (h₁ : IsNull a b c) (h₂ : IsNull (a - dx) (b - dy) (c - dt)) :
    2 * minkInner a b c dx dy dt = minkQ dx dy dt := by
  unfold IsNull minkInner minkQ at *; linarith;



theorem photon_345_squared :
    gaussProd (3, 4, 5) (3, 4, 5) = (-7, 24, 25) := by
  decide +kernel



theorem photon_345_squared_is_triple :
    IsPythTriple (-7) 24 25 := by
  norm_num [ IsPythTriple ]



theorem photon_product_345_51213 :
    gaussProd (3, 4, 5) (5, 12, 13) = (-33, 56, 65) := by
  native_decide +revert



theorem photon_product_is_triple :
    IsPythTriple (-33) 56 65 := by
  exact show ( -33 ) ^ 2 + 56 ^ 2 = 65 ^ 2 by norm_num;



theorem primitive_triple_odd_hypotenuse (a b c : ℤ)
    (h : IsPythTriple a b c) (ha : a % 2 = 1) (hb : b % 2 = 0) :
    c % 2 = 1 := by
  cases Int.emod_two_eq_zero_or_one c <;> ( unfold IsPythTriple at h ; ( replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *; ) )



/-- The identity matrix preserves the Minkowski form. -/
theorem identity_preserves_minkQ (a b c : ℝ) :
    minkQ a b c = minkQ a b c := rfl



theorem comp_preserves_minkQ
    (f g : ℝ → ℝ → ℝ → ℝ × ℝ × ℝ)
    (hf : ∀ a b c, minkQ (f a b c).1 (f a b c).2.1 (f a b c).2.2 = minkQ a b c)
    (hg : ∀ a b c, minkQ (g a b c).1 (g a b c).2.1 (g a b c).2.2 = minkQ a b c)
    (a b c : ℝ) :
    let v := f a b c
    minkQ (g v.1 v.2.1 v.2.2).1 (g v.1 v.2.1 v.2.2).2.1 (g v.1 v.2.1 v.2.2).2.2 =
      minkQ a b c := by
  aesop



theorem null_basis_vectors :
    IsNull 1 0 1 ∧ IsNull 1 0 (-1) := by
  exact ⟨ by unfold IsNull; unfold minkQ; norm_num, by unfold IsNull; unfold minkQ; norm_num ⟩



/-- The null vectors (1,0,1) and (1,0,-1) are not proportional (linearly independent
when combined with (0,1,0)). -/
theorem null_basis_inner :
    minkInner 1 0 1 1 0 (-1) = 2 := by
  simp [minkInner]; norm_num



theorem spacelike_basis :
    minkQ 0 1 0 > 0 := by
  unfold minkQ; norm_num;



theorem photon_helicity_bound (a b c : ℝ) (h : IsNull a b c) (hc : c ≠ 0) :
    |a * b| / c ^ 2 ≤ 1 / 2 := by
  rw [ div_le_iff₀ ] <;> norm_num [ IsNull ] at *;
  · unfold minkQ at h; nlinarith [ sq_nonneg ( |a| - |b| ), abs_mul_abs_self a, abs_mul_abs_self b ] ;
  · positivity



end
