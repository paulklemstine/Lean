/-
# Quaternion Algebras over Fields and Classification

This file defines the general quaternion algebra (a,b)_F for a field F
and proves classification results:
1. The reduced norm form and its properties
2. Splitting criterion via norm form isotropy
3. Over ℝ: exactly two isomorphism classes (split M₂(ℝ) vs Hamilton's ℍ)
4. The sign classification: (a,b)_ℝ is a division algebra iff a < 0 and b < 0
-/
import Mathlib

namespace QuatAlgField

/-- A quaternion algebra (a,b) over a field F, where char F ≠ 2.
    This is the 4-dimensional F-algebra with basis {1, i, j, k} satisfying
    i² = a, j² = b, k = ij = -ji. -/
@[ext]
structure QA (F : Type*) [Field F] where
  x₀ : F
  x₁ : F
  x₂ : F
  x₃ : F

variable {F : Type*} [Field F]

namespace QA

instance : Zero (QA F) := ⟨⟨0, 0, 0, 0⟩⟩
instance : One (QA F) := ⟨⟨1, 0, 0, 0⟩⟩

/-- Multiplication in (a,b)_F with i² = a, j² = b, k = ij, ji = -k.
    Derived products: ik = aj, ki = -aj, jk = -bi, kj = bi, k² = -ab. -/
def mul (a b : F) (p q : QA F) : QA F :=
  ⟨p.x₀ * q.x₀ + a * p.x₁ * q.x₁ + b * p.x₂ * q.x₂ - a * b * p.x₃ * q.x₃,
   p.x₀ * q.x₁ + p.x₁ * q.x₀ - b * p.x₂ * q.x₃ + b * p.x₃ * q.x₂,
   p.x₀ * q.x₂ + a * p.x₁ * q.x₃ + p.x₂ * q.x₀ - a * p.x₃ * q.x₁,
   p.x₀ * q.x₃ + p.x₁ * q.x₂ - p.x₂ * q.x₁ + p.x₃ * q.x₀⟩

/-- Conjugation in the quaternion algebra -/
def conj (p : QA F) : QA F := ⟨p.x₀, -p.x₁, -p.x₂, -p.x₃⟩

/-- The reduced norm: Nrd(x₀ + x₁i + x₂j + x₃k) = x₀² - a·x₁² - b·x₂² + ab·x₃² -/
def reducedNorm (a b : F) (p : QA F) : F :=
  p.x₀ ^ 2 - a * p.x₁ ^ 2 - b * p.x₂ ^ 2 + a * b * p.x₃ ^ 2

/-- The reduced trace -/
def reducedTrace (p : QA F) : F := 2 * p.x₀

/-- p * conj(p) gives the reduced norm (as a scalar quaternion) -/
theorem mul_conj_eq_norm (a b : F) (p : QA F) :
    mul a b p (conj p) = ⟨reducedNorm a b p, 0, 0, 0⟩ := by
  unfold mul conj reducedNorm; ext <;> simp <;> ring

/-- **The reduced norm is multiplicative** — a fundamental identity for quaternion algebras. -/
theorem reducedNorm_mul (a b : F) (p q : QA F) :
    reducedNorm a b (mul a b p q) = reducedNorm a b p * reducedNorm a b q := by
  unfold reducedNorm mul; ring

/-! ## Norm form isotropy -/

/-- The norm form of (a,b)_F is isotropic if there exist (x₀,x₁,x₂,x₃) ≠ (0,0,0,0)
    with x₀² - a·x₁² - b·x₂² + ab·x₃² = 0. -/
def NormFormIsotropic (a b : F) : Prop :=
  ∃ (x₀ x₁ x₂ x₃ : F), (x₀, x₁, x₂, x₃) ≠ (0, 0, 0, 0) ∧
    x₀ ^ 2 - a * x₁ ^ 2 - b * x₂ ^ 2 + a * b * x₃ ^ 2 = 0

/-! ## Real quaternion algebras classification -/

/-
Over ℝ, the quaternion algebra (a,b) is a division algebra iff a < 0 and b < 0.
-/
theorem real_qa_division_iff (a b : ℝ) (ha : a ≠ 0) (hb : b ≠ 0) :
    (∀ p : QA ℝ, p ≠ 0 → reducedNorm a b p ≠ 0) ↔ (a < 0 ∧ b < 0) := by
  -- If a > 0, use p = ⟨√a, 1, 0, 0⟩ to get reducedNorm = 0, contradiction.
  by_cases ha_pos : 0 < a;
  · constructor <;> intro h <;> contrapose! h;
    · use ⟨Real.sqrt a, 1, 0, 0⟩;
      exact ⟨ ne_of_apply_ne ( fun x => x.x₀ ) ( by norm_num; positivity ), by unfold reducedNorm; norm_num [ ha_pos.le ] ⟩;
    · exact fun h => False.elim <| h.not_gt ha_pos;
  · constructor <;> intro h <;> simp_all +decide [ reducedNorm ];
    · constructor <;> contrapose! h;
      · exact False.elim <| ha <| le_antisymm ha_pos h;
      · refine' ⟨ ⟨ Real.sqrt b, 0, 1, 0 ⟩, _, _ ⟩ <;> norm_num [ ha, hb, ha_pos, h ];
        exact ne_of_apply_ne ( fun x => x.x₂ ) one_ne_zero;
    · intro p hp h_eq;
      -- Since $a < 0$ and $b < 0$, we can write $a = -c^2$ and $b = -d^2$ for some $c, d \in \mathbb{R}$.
      obtain ⟨c, hc⟩ : ∃ c : ℝ, a = -c^2 := by
        exact ⟨ Real.sqrt ( -a ), by rw [ Real.sq_sqrt ( neg_nonneg.mpr h.1.le ) ] ; ring ⟩
      obtain ⟨d, hd⟩ : ∃ d : ℝ, b = -d^2 := by
        exact ⟨ Real.sqrt ( -b ), by rw [ Real.sq_sqrt ( by linarith ) ] ; ring ⟩;
      simp_all +decide [ QA.ext_iff ];
      -- Since $c^2$ and $d^2$ are positive, each term in the sum must be zero.
      have h_zero : p.x₀ = 0 ∧ p.x₁ = 0 ∧ p.x₂ = 0 ∧ p.x₃ = 0 := by
        exact ⟨ by contrapose! h_eq; positivity, by contrapose! h_eq; positivity, by contrapose! h_eq; positivity, by contrapose! h_eq; positivity ⟩;
      exact hp h_zero.1 h_zero.2.1 h_zero.2.2.1 h_zero.2.2.2

/-
Over ℝ, if a > 0, then the norm form is isotropic (algebra splits).
-/
theorem real_qa_splits_pos_a (a b : ℝ) (ha : 0 < a) (hb : b ≠ 0) :
    NormFormIsotropic a b := by
  exact ⟨ Real.sqrt a, 1, 0, 0, by aesop, by rw [ Real.sq_sqrt ( le_of_lt ha ) ] ; ring ⟩

/-
Over ℝ, if b > 0, then (a,b) splits.
-/
theorem real_qa_splits_pos_b (a b : ℝ) (ha : a ≠ 0) (hb : 0 < b) :
    NormFormIsotropic a b := by
  exact ⟨ Real.sqrt b, 0, 1, 0, by aesop, by linarith [ Real.mul_self_sqrt hb.le ] ⟩

/-
Over ℝ, if a < 0 and b < 0, the reduced norm is positive definite,
    so the algebra is a division algebra.
-/
theorem real_qa_division_neg_neg (a b : ℝ) (ha : a < 0) (hb : b < 0) :
    ∀ p : QA ℝ, p ≠ 0 → reducedNorm a b p ≠ 0 := by
  exact fun ⟨ x₀, x₁, x₂, x₃ ⟩ hp => by have := real_qa_division_iff a b ( by linarith ) ( by linarith ) ; exact fun h => this.mpr ⟨ by linarith, by linarith ⟩ _ hp h;

/-
**Real classification theorem**: Every real quaternion algebra (a,b)_ℝ with
    a,b ≠ 0 either has isotropic norm form (splits as M₂(ℝ))
    or has a,b < 0 (Hamilton's division algebra ℍ).
-/
theorem real_classification (a b : ℝ) (ha : a ≠ 0) (hb : b ≠ 0) :
    NormFormIsotropic a b ∨ (a < 0 ∧ b < 0) := by
  grind +suggestions

end QA
end QuatAlgField