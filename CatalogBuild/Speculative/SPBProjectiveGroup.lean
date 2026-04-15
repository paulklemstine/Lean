/-! # CatalogBuild.Speculative.SPBProjectiveGroup

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 18
-/

import Mathlib

noncomputable section

/-- Identity is [0:1]. -/
theorem proj_id_right (x₁ x₂ : ℝ) : proj x₁ x₂ 0 1 = (x₁, x₂) := by
  simp [proj]


/-- [Section: ## Section 1: Projective SPB Group] -/
theorem proj_id_left (x₁ x₂ : ℝ) : proj 0 1 x₁ x₂ = (x₁, x₂) := by
  simp [proj]


/-- Commutativity. -/
theorem proj_comm (x₁ x₂ y₁ y₂ : ℝ) : proj x₁ x₂ y₁ y₂ = proj y₁ y₂ x₁ x₂ := by
  simp only [proj, Prod.mk.injEq]; constructor <;> ring


/-- Inverse of [x₁:x₂] is [-x₁:x₂]. -/
theorem proj_inv (x₁ x₂ : ℝ) :
    proj x₁ x₂ (-x₁) x₂ = (0, x₂ ^ 2 + x₁ ^ 2) := by
  simp only [proj, Prod.mk.injEq]; constructor <;> ring


/-- Associativity of projective SPB (always holds, no singularity conditions!). -/
theorem proj_assoc (x₁ x₂ y₁ y₂ z₁ z₂ : ℝ) :
    let p := proj x₁ x₂ y₁ y₂
    proj p.1 p.2 z₁ z₂ =
    let q := proj y₁ y₂ z₁ z₂
    proj x₁ x₂ q.1 q.2 := by
  simp only [proj, Prod.mk.injEq]; constructor <;> ring


/-- The projective "norm" x₁² + x₂² is multiplicative:
N([x₁:x₂] ⊕ [y₁:y₂]) = N([x₁:x₂]) · N([y₁:y₂]). -/
theorem proj_norm_mul (x₁ x₂ y₁ y₂ : ℝ) :
    (proj x₁ x₂ y₁ y₂).1 ^ 2 + (proj x₁ x₂ y₁ y₂).2 ^ 2 =
    (x₁ ^ 2 + x₂ ^ 2) * (y₁ ^ 2 + y₂ ^ 2) := by
  simp only [proj]; ring


/-- [Section: ## Section 2: Connection to Affine SPB] -/
theorem proj_to_affine (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (proj x 1 y 1).1 / (proj x 1 y 1).2 = spb x y := by
  unfold proj spb; aesop;


/-- The projective norm of [x:1] is 1 + x² = x² + 1. -/
theorem proj_affine_norm (x : ℝ) :
    x ^ 2 + 1 ^ 2 = 1 + x ^ 2 := by ring


/-- [1:0] represents ∞. SPB with ∞:
[1:0] ⊕ [y:1] = [1·1 + 0·y : 0·1 - 1·y] = [1:-y]. -/
theorem proj_infinity (y : ℝ) : proj 1 0 y 1 = (1, -y) := by
  simp [proj]


/-- In affine coordinates, spb(∞, y) = -1/y (for y ≠ 0). -/
theorem proj_infinity_affine (y : ℝ) (hy : y ≠ 0) :
    (proj 1 0 y 1).1 / (proj 1 0 y 1).2 = -1 / y := by
  simp [proj]; ring


/-- ∞ ⊕ ∞ = [1:0] ⊕ [1:0] = [0:-1] = [0:1] (i.e., 0). -/
theorem proj_infinity_self : proj 1 0 1 0 = (0, -1) := by
  simp [proj]


/-- n-fold projective SPB: repeated application. -/
def projIter (x₁ x₂ : ℝ) : ℕ → ℝ × ℝ
  | 0 => (0, 1)  -- identity [0:1]
  | n + 1 => proj x₁ x₂ (projIter x₁ x₂ n).1 (projIter x₁ x₂ n).2


/-- [Section: ## Section 4: n-fold Projective SPB] -/
theorem projIter_zero (x₁ x₂ : ℝ) : projIter x₁ x₂ 0 = (0, 1) := rfl


theorem projIter_one (x₁ x₂ : ℝ) : projIter x₁ x₂ 1 = (x₁, x₂) := by
  simp [projIter, proj]


theorem projIter_norm (x₁ x₂ : ℝ) (n : ℕ) :
    (projIter x₁ x₂ n).1 ^ 2 + (projIter x₁ x₂ n).2 ^ 2 =
    (x₁ ^ 2 + x₂ ^ 2) ^ n := by
  induction' n with n ih;
  · norm_num [ projIter ];
  · convert proj_norm_mul x₁ x₂ ( projIter x₁ x₂ n |> Prod.fst ) ( projIter x₁ x₂ n |> Prod.snd ) using 1 ; ring;
    linear_combination -ih * ( x₁ ^ 2 + x₂ ^ 2 )


/-- The projective SPB is literally Gaussian integer multiplication:
(x₂ + x₁·i)(y₂ + y₁·i) = (x₂y₂ - x₁y₁) + (x₁y₂ + x₂y₁)·i
Reading off: real part = second component, imag part = first component. -/
theorem proj_is_gaussian_mul (x₁ x₂ y₁ y₂ : ℤ) :
    let z := (⟨x₂, x₁⟩ : GaussianInt) * ⟨y₂, y₁⟩
    z.re = (x₂ * y₂ - x₁ * y₁ : ℤ) ∧ z.im = (x₁ * y₂ + x₂ * y₁ : ℤ) := by
  constructor <;> simp [GaussianInt, Zsqrtd.ext_iff, Zsqrtd.mul_re, Zsqrtd.mul_im] <;> ring


/-- The form Q(x₁, x₂) = x₁² + x₂² is the norm form of ℤ[i].
SPB composition preserves this form multiplicatively:
Q(a ⊕ b) = Q(a) · Q(b). -/
theorem quadratic_form_multiplicative (x₁ x₂ y₁ y₂ : ℝ) :
    (x₁ * y₂ + x₂ * y₁) ^ 2 + (x₂ * y₂ - x₁ * y₁) ^ 2 =
    (x₁ ^ 2 + x₂ ^ 2) * (y₁ ^ 2 + y₂ ^ 2) := by ring


/-- Specialising to integers, this is the Brahmagupta-Fibonacci identity. -/
theorem brahmagupta_fibonacci_proj (a b c d : ℤ) :
    (a * d + b * c) ^ 2 + (b * d - a * c) ^ 2 =
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) := by ring


end
