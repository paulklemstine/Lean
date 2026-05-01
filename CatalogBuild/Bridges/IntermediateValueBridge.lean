/-! # CatalogBuild.Bridges.IntermediateValueBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 5
-/

import Mathlib

/-- The Intermediate Value Theorem: if f is continuous on [a,b] with
a ≤ b, then f maps [a,b] onto the interval [f(a), f(b)]. -/
theorem ivt_image {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Icc a b)) :
    Icc (f a) (f b) ⊆ f '' Icc a b :=
  intermediate_value_Icc hab hf


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


/-- Continuous image of compact interval is compact interval.
f''[a,b] = [inf f([a,b]), sup f([a,b])].
The output of a neural network on a bounded input is also bounded. -/
theorem continuous_image_Icc {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Icc a b)) :
    f '' Icc a b = Icc (sInf (f '' Icc a b)) (sSup (f '' Icc a b)) :=
  ContinuousOn.image_Icc hab hf


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

