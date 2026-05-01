import Mathlib

/-! # Intermediate Value Bridge

Proves the Intermediate Value Theorem and its consequences for
neural network decision boundaries:

1. IVT: continuous f on [a,b] with f(a) ≤ c ≤ f(b) → ∃x, f(x) = c
2. Zero crossing: f(a) < 0 < f(b) → ∃x, f(x) = 0
3. Sign change implies adversarial example exists on the line segment
4. Continuous image of interval is interval (bounded outputs)

These connect to certified robustness: if a classifier output changes
sign between two inputs, there EXISTS an adversarial example on the
line segment between them.
-/

namespace IntermediateValueBridge

open Set

/-! ## Section 1: The Intermediate Value Theorem -/

/-- The Intermediate Value Theorem: if f is continuous on [a,b] with
    a ≤ b, then f maps [a,b] onto the interval [f(a), f(b)]. -/
theorem ivt_image {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Icc a b)) :
    Icc (f a) (f b) ⊆ f '' Icc a b :=
  intermediate_value_Icc hab hf

/-- The Intermediate Value Theorem: for any c with f(a) ≤ c ≤ f(b),
    there exists x ∈ [a,b] with f(x) = c.
    In neural network terms: any output between two observed outputs
    is attained somewhere in the input interval. -/
theorem ivt {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Icc a b)) {c : ℝ}
    (hca : f a ≤ c) (hcb : c ≤ f b) :
    ∃ x ∈ Icc a b, f x = c := by
  have := intermediate_value_Icc hab hf
  simp only [mem_Icc] at this ⊢
  exact this ⟨hca, hcb⟩

/-! ## Section 2: Zero-Crossing Theorems -/

/-- Zero crossing: if f(a) ≤ 0 ≤ f(b), then ∃x ∈ [a,b] with f(x) = 0.
    A neural network that outputs negative at a and positive at b
    MUST cross zero somewhere between a and b. -/
theorem zero_crossing {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Icc a b))
    (ha : f a ≤ 0) (hb : 0 ≤ f b) :
    ∃ x ∈ Icc a b, f x = 0 :=
  ivt hab hf ha hb

/-- Strict zero crossing: if f(a) < 0 < f(b), then ∃x ∈ [a,b] with f(x) = 0.
    This is the fundamental result for decision boundaries: if a classifier
    outputs different signs at two points, there exists an adversarial example
    on the line segment between them. -/
theorem strict_zero_crossing {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Icc a b))
    (ha : f a < 0) (hb : 0 < f b) :
    ∃ x ∈ Icc a b, f x = 0 :=
  zero_crossing hab hf ha.le hb.le

/-! ## Section 3: Continuous Image of Interval -/

/-- Continuous image of compact interval is compact interval.
    f''[a,b] = [inf f([a,b]), sup f([a,b])].
    The output of a neural network on a bounded input is also bounded. -/
theorem continuous_image_Icc {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Icc a b)) :
    f '' Icc a b = Icc (sInf (f '' Icc a b)) (sSup (f '' Icc a b)) :=
  ContinuousOn.image_Icc hab hf

/-! ## Section 4: Applications to Robustness -/

/-- Opposite signs imply root existence.
    If f is continuous and changes sign between a and b,
    there exists a decision boundary crossing.
    This directly implies: adversarial examples exist whenever
    the classifier output changes sign on the input interval. -/
theorem sign_change_implies_adversarial {f : ℝ → ℝ} {a b : ℝ}
    (hab : a ≤ b) (hf : ContinuousOn f (Icc a b))
    (ha : f a < 0) (hb : 0 < f b) :
    ∃ x, a ≤ x ∧ x ≤ b ∧ f x = 0 := by
  obtain ⟨x, ⟨hxa, hxb⟩, hfx⟩ := strict_zero_crossing hab hf ha hb
  exact ⟨x, hxa, hxb, hfx⟩

end IntermediateValueBridge
