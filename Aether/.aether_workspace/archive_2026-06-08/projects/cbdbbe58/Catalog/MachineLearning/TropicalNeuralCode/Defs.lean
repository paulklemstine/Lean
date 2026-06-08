import Mathlib

/-!
# Tropical Neural Code Classification — Definitions

Foundational definitions for tropical neural code classification theory:
tropical points, separation predicates, tropical scores, and dominance patterns.
These bridge tropical geometry with computational neuroscience.
-/

noncomputable section

open Finset BigOperators

/-! ## Basic types -/

/-- A tropical point in `n`-dimensional space. -/
abbrev TropPoint (n : ℕ) := Fin n → ℝ

/-! ## Separation and Domination Predicates -/

/-- Point `x` dominates point `y` by margin `γ` in every coordinate. -/
def dominatesBy {n : ℕ} (γ : ℝ) (x y : TropPoint n) : Prop :=
  ∀ i, y i ≤ x i - γ

/-- Two points are separated by margin `γ` if there exists a coordinate
where the gap is at least `γ`. -/
def separatedBy {n : ℕ} (γ : ℝ) (x y : TropPoint n) : Prop :=
  ∃ i : Fin n, γ ≤ x i - y i

/-! ## Tropical Scores for Classification -/

/-- The coordinatewise gap from `x` to `y`: the infimum of `x i - y i`. -/
def coordGap {n : ℕ} [NeZero n] (x y : TropPoint n) : ℝ :=
  ⨅ i : Fin n, (x i - y i)

/-- The tropical generator score of a point `x` against a codebook `S`:
the supremum over generators of the coordinatewise infimum gap.
This measures how well the closest generator in `S` matches `x`. -/
def tropGeneratorScore {n : ℕ} [NeZero n] (S : Finset (TropPoint n))
    (x : TropPoint n) : ℝ :=
  if h : S.Nonempty then
    S.sup' h (fun s => coordGap x s)
  else
    0

/-- Binary classification: `x` is classified as class `A` against `B`. -/
def classifiesAs {n : ℕ} [NeZero n] (A B : Finset (TropPoint n))
    (x : TropPoint n) : Prop :=
  tropGeneratorScore A x ≥ tropGeneratorScore B x

/-! ## Tropical Convex Hull (Finitely Generated) -/

/-- The tropical convex hull of a nonempty finite set. A point `z` is in the hull if
there exist coefficients `w` with `sup w = 0` (normalization) such that for each
coordinate `z i = sup_s (w s + s i)`. We also include all original points. -/
def tropConvHull {n : ℕ} (S : Finset (TropPoint n)) : Set (TropPoint n) :=
  if h : S.Nonempty then
    { z | ∃ w : TropPoint n → ℝ,
      S.sup' h (fun s => w s) = 0 ∧
      ∀ i, z i = S.sup' h (fun s => w s + s i) }
  else ∅

/-! ## Separation Between Classes -/

/-- Two codebooks are tropically separated with margin `γ` if for every
generator pair, there exists a coordinate witnessing gap ≥ γ. -/
def tropicalSeparatesWithMargin {n : ℕ} (γ : ℝ) (A B : Finset (TropPoint n)) : Prop :=
  ∀ a ∈ A, ∀ b ∈ B, ∃ i : Fin n, γ ≤ a i - b i

/-- Uniform separation in a fixed coordinate. -/
def uniformTropicalSeparation {n : ℕ} (γ : ℝ) (A B : Finset (TropPoint n))
    (i₀ : Fin n) : Prop :=
  ∀ a ∈ A, ∀ b ∈ B, γ ≤ a i₀ - b i₀

/-! ## Dominance Patterns (Finite Combinatorial Invariants) -/

/-- The tropical cell assignment: for each generator `s` and coordinate `i`,
records whether `s` achieves the best gap at coordinate `i`.
This is decidable and induces a finite partition. -/
def tropicalCellAssignment {n : ℕ} (C : Finset (TropPoint n)) (x : TropPoint n) :
    TropPoint n → Fin n → Bool :=
  fun s i => decide (∀ s' ∈ C, x i - s i ≥ x i - s' i)

/-- The closest generator set: generators achieving the maximum tropical score. -/
def closestGeneratorSet {n : ℕ} [NeZero n] (C : Finset (TropPoint n))
    (x : TropPoint n) : Finset (TropPoint n) :=
  C.filter (fun s => coordGap x s = tropGeneratorScore C x)

end