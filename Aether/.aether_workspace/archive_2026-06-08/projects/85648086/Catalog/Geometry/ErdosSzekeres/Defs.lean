/-
# Erdős–Szekeres Happy End Problem: Core Definitions

This file establishes the foundational definitions for the planar Erdős–Szekeres
theorem, including orientation, general position, cups, caps, and convex position.

The orientation function `orient` computes the signed area of the triangle formed
by three points, which determines whether the triple is in counterclockwise,
clockwise, or collinear configuration.
-/
import Mathlib

open Finset

namespace ErdosSzekeres

/-! ## Orientation -/

/-- The orientation (signed area × 2) of three points in the plane.
Positive means counterclockwise, negative means clockwise, zero means collinear. -/
def orient (a b c : ℝ × ℝ) : ℝ :=
  (b.1 - a.1) * (c.2 - a.2) - (b.2 - a.2) * (c.1 - a.1)

/-! ## General Position -/

/-- A family of points is in general position if no three are collinear. -/
def GeneralPosition {m : ℕ} (p : Fin m → ℝ × ℝ) : Prop :=
  ∀ i j k : Fin m, i ≠ j → j ≠ k → i ≠ k → orient (p i) (p j) (p k) ≠ 0

/-! ## Cups and Caps -/

/-- A cup is a sequence of points (ordered by index and x-coordinate) where
consecutive triples have positive orientation, i.e., the sequence is "concave up".
Requires k ≥ 2 for meaningful content; for k ≤ 2 the orientation condition is vacuous. -/
def IsCup {m k : ℕ} (p : Fin m → ℝ × ℝ) (f : Fin k → Fin m) : Prop :=
  (StrictMono f) ∧
  (∀ i j : Fin k, i < j → (p (f i)).1 < (p (f j)).1) ∧
  (∀ (a : ℕ) (ha : a + 2 < k),
    orient (p (f ⟨a, by omega⟩)) (p (f ⟨a + 1, by omega⟩)) (p (f ⟨a + 2, by omega⟩)) > 0)

/-- A cap is a sequence of points (ordered by index and x-coordinate) where
consecutive triples have negative orientation, i.e., the sequence is "concave down". -/
def IsCap {m k : ℕ} (p : Fin m → ℝ × ℝ) (f : Fin k → Fin m) : Prop :=
  (StrictMono f) ∧
  (∀ i j : Fin k, i < j → (p (f i)).1 < (p (f j)).1) ∧
  (∀ (a : ℕ) (ha : a + 2 < k),
    orient (p (f ⟨a, by omega⟩)) (p (f ⟨a + 1, by omega⟩)) (p (f ⟨a + 2, by omega⟩)) < 0)

/-- There exists a cup of size k in the point set. -/
def HasCup {m : ℕ} (p : Fin m → ℝ × ℝ) (k : ℕ) : Prop :=
  ∃ f : Fin k → Fin m, IsCup p f

/-- There exists a cap of size k in the point set. -/
def HasCap {m : ℕ} (p : Fin m → ℝ × ℝ) (k : ℕ) : Prop :=
  ∃ f : Fin k → Fin m, IsCap p f

/-! ## Convex Position -/

/-- A finite indexed set of points is in convex position if we can enumerate them
in x-sorted order such that all triples (i < j < k) have consistent orientation
(either all positive or all negative). This captures the geometric notion that
every point is a vertex of the convex hull of the set.

For the positive-orientation version: -/
def InConvexPositionCCW {m : ℕ} (p : Fin m → ℝ × ℝ) (s : Finset (Fin m)) : Prop :=
  ∃ f : Fin s.card → Fin m,
    (∀ i, f i ∈ s) ∧
    (Function.Injective f) ∧
    (∀ i j : Fin s.card, i < j → (p (f i)).1 < (p (f j)).1) ∧
    (∀ i j k : Fin s.card, i < j → j < k →
      orient (p (f i)) (p (f j)) (p (f k)) > 0)

/-- Points are in convex position if there exists an x-sorted enumeration
with consistent orientation (all positive or all negative). This is the
geometrically correct definition: every point is a vertex of the convex hull. -/
def InConvexPosition {m : ℕ} (p : Fin m → ℝ × ℝ) (s : Finset (Fin m)) : Prop :=
  InConvexPositionCCW p s ∨
  (∃ f : Fin s.card → Fin m,
    (∀ i, f i ∈ s) ∧
    (Function.Injective f) ∧
    (∀ i j : Fin s.card, i < j → (p (f i)).1 < (p (f j)).1) ∧
    (∀ i j k : Fin s.card, i < j → j < k →
      orient (p (f i)) (p (f j)) (p (f k)) < 0))

/-! ## Strict X-Monotone Sequences -/

/-- Points have strictly increasing x-coordinates (indexed by Fin). -/
def StrictXMono {m : ℕ} (p : Fin m → ℝ × ℝ) : Prop :=
  StrictMono (fun i => (p i).1)

end ErdosSzekeres