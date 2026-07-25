/-
# Endpoint cardinality for one-dimensional discrete cube skeleta

This file formalizes the sharp counting mechanism behind the `n = 1, k = 0`
case of the endpoint-cardinality problem.  A zero-dimensional skeleton about an
integer center consists of the two endpoints `c-r` and `c+r`, with `r > 0`.
Recording those labelled endpoints is injective because their sum determines
the center.  Consequently, a finite endpoint set `B` covering a finite center
set `C` satisfies `|C| ≤ |B|²`.

The final theorem refutes the tempting stronger conjecture `|C| ≤ |B|`: four
carefully spaced endpoints cover six distinct centers.
-/
import Mathlib

namespace EndpointCubeSkeleta

open Finset

/-- Every center in `centers` has a positive-radius pair of endpoints in `points`. -/
def EndpointCovered (points centers : Finset ℤ) : Prop :=
  ∀ c ∈ centers, ∃ r : ℕ, 0 < r ∧ c - (r : ℤ) ∈ points ∧ c + (r : ℤ) ∈ points

/-- A choice of labelled endpoint pairs whose midpoint is the center is injective.
This is the midpoint estimate in its most elementary discrete form. -/
theorem labelled_endpoints_injective
    {centers : Finset ℤ} (left right : ℤ → ℤ)
    (hsum : ∀ c ∈ centers, left c + right c = 2 * c) :
    Set.InjOn (fun c => (left c, right c)) (↑centers : Set ℤ) := by
  intro a ha b hb hab
  have hl : left a = left b := congrArg Prod.fst hab
  have hr : right a = right b := congrArg Prod.snd hab
  have ha' := hsum a ha
  have hb' := hsum b hb
  omega

/-- **One-dimensional endpoint cardinality theorem.**
If a finite lattice set contains both endpoints of a positive-radius interval
about each center, then the number of centers is at most the square of the
number of available lattice points. -/
theorem card_centers_le_card_points_sq
    {points centers : Finset ℤ} (hcover : EndpointCovered points centers) :
    centers.card ≤ points.card ^ 2 := by
  classical
  let rad (c : ℤ) : ℕ :=
    if hc : c ∈ centers then Classical.choose (hcover c hc) else 0
  let left (c : ℤ) : ℤ := c - (rad c : ℤ)
  let right (c : ℤ) : ℤ := c + (rad c : ℤ)
  have hrad (c : ℤ) (hc : c ∈ centers) :
      0 < rad c ∧ left c ∈ points ∧ right c ∈ points := by
    have hs := Classical.choose_spec (hcover c hc)
    simpa [rad, left, right, hc] using hs
  have hsum : ∀ c ∈ centers, left c + right c = 2 * c := by
    intro c hc
    simp [left, right]
    ring
  have hmap : Set.MapsTo (fun c => (left c, right c))
      (↑centers : Set ℤ) (↑(points ×ˢ points) : Set (ℤ × ℤ)) := by
    intro c hc
    exact Finset.mem_product.mpr ⟨(hrad c hc).2.1, (hrad c hc).2.2⟩
  have hinj := labelled_endpoints_injective left right hsum
  calc
    centers.card ≤ (points ×ˢ points).card :=
      Finset.card_le_card_of_injOn _ hmap hinj
    _ = points.card * points.card := Finset.card_product _ _
    _ = points.card ^ 2 := by ring

/-- Four endpoints forming a small Sidon-type set. -/
def counterexamplePoints : Finset ℤ := {0, 2, 6, 14}

/-- The six pairwise midpoints of `counterexamplePoints`. -/
def counterexampleCenters : Finset ℤ := {1, 3, 4, 7, 8, 10}

/-- The proposed linear strengthening is false: these four endpoints cover six
integer centers by positive-radius endpoint pairs. -/
theorem linear_bound_counterexample :
    EndpointCovered counterexamplePoints counterexampleCenters ∧
      counterexamplePoints.card < counterexampleCenters.card := by
  constructor
  · intro c hc
    simp [counterexampleCenters] at hc
    rcases hc with rfl | rfl | rfl | rfl | rfl | rfl
    · refine ⟨1, by norm_num, ?_, ?_⟩ <;> simp [counterexamplePoints]
    · refine ⟨3, by norm_num, ?_, ?_⟩ <;> simp [counterexamplePoints]
    · refine ⟨2, by norm_num, ?_, ?_⟩ <;> simp [counterexamplePoints]
    · refine ⟨7, by norm_num, ?_, ?_⟩ <;> simp [counterexamplePoints]
    · refine ⟨6, by norm_num, ?_, ?_⟩ <;> simp [counterexamplePoints]
    · refine ⟨4, by norm_num, ?_, ?_⟩ <;> simp [counterexamplePoints]
  · native_decide

/-- Thus the universal conjecture `|centers| ≤ |points|` is false. -/
theorem not_all_endpoint_covers_are_linear :
    ¬ ∀ (points centers : Finset ℤ),
      EndpointCovered points centers → centers.card ≤ points.card := by
  intro h
  have hbad := h counterexamplePoints counterexampleCenters
    linear_bound_counterexample.1
  exact (Nat.not_lt_of_ge hbad) linear_bound_counterexample.2

/-- The exponent in the square-boundary (`n = 2`, `k = 1`) instance of the
paper's general formula is exactly `7/8`. -/
theorem square_boundary_exponent :
    (1 : ℚ) - (2 - 1) / (2 * 2 ^ 2) = 7 / 8 := by
  norm_num

end EndpointCubeSkeleta