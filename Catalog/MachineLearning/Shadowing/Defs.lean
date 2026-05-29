import Mathlib

/-!
# Shadowing Lemma: Definitions and Core Properties

This file establishes the foundational definitions for the shadowing lemma
in dynamical systems: pseudo-orbits, shadowing orbits, the shadowing property,
expanding maps, the logistic map, the tent map, and the topological conjugacy
between them.

## Main Definitions

* `IsPseudoOrbit` — A δ-pseudo-orbit of f: each step deviates from f by at most δ
* `ShadowsOrbit` — A true orbit y ε-shadows a pseudo-orbit x
* `HasShadowingProperty` — A map f has the shadowing property
* `IsExpanding` — An expanding map with expansion factor λ > 1
* `logistic` — The logistic map f(x) = 4x(1−x)
* `tentMap` — The tent map T(y) = 2·min(y, 1−y)
* `chaosConj` — The conjugacy h(y) = sin²(πy/2)
-/

noncomputable section

open Real Set Metric

/-- A δ-pseudo-orbit of f: each step deviates from f by at most δ -/
def IsPseudoOrbit {X : Type*} [MetricSpace X] (f : X → X) (δ : ℝ)
    {n : ℕ} (x : Fin (n + 1) → X) : Prop :=
  ∀ i : Fin n, dist (x (Fin.castSucc i + 1)) (f (x (Fin.castSucc i))) < δ

/-- A true orbit y ε-shadows a pseudo-orbit x -/
def ShadowsOrbit {X : Type*} [MetricSpace X] (f : X → X) (ε : ℝ)
    {n : ℕ} (x : Fin (n + 1) → X) (y : Fin (n + 1) → X) : Prop :=
  (∀ i : Fin n, y (Fin.castSucc i + 1) = f (y (Fin.castSucc i))) ∧
  (∀ i : Fin (n + 1), dist (x i) (y i) < ε)

/-- A map f has the shadowing property if every pseudo-orbit is shadowed -/
def HasShadowingProperty {X : Type*} [MetricSpace X] (f : X → X) : Prop :=
  ∀ ε > 0, ∃ δ > 0, ∀ n : ℕ, ∀ x : Fin (n + 1) → X,
    IsPseudoOrbit f δ x → ∃ y : Fin (n + 1) → X, ShadowsOrbit f ε x y

/-- An expanding map with expansion factor λ > 1 -/
def IsExpanding {X : Type*} [MetricSpace X] (f : X → X) (expFactor : ℝ) : Prop :=
  expFactor > 1 ∧ ∀ x y, dist (f x) (f y) ≥ expFactor * dist x y

/-- The logistic map on [0,1] -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

/-- The tent map on [0,1] -/
def tentMap (y : ℝ) : ℝ := 2 * min y (1 - y)

/-- The topological conjugacy h : [0,1] → [0,1] with h ∘ tentMap = logistic ∘ h -/
def chaosConj (y : ℝ) : ℝ := (sin (π * y / 2)) ^ 2

end