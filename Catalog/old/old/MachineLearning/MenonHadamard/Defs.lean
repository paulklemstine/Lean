import Mathlib

/-!
# Difference Set Definitions and Sign Matrix

Core definitions for (v,k,λ)-difference sets in finite groups and the associated
sign matrix construction that bridges combinatorial design theory to Hadamard matrices.

## Main definitions

* `IsDifferenceSet` — A (v,k,λ)-difference set in a finite group
* `differenceSetSignMatrix` — The ±1 sign matrix derived from a difference set
-/

open Finset Fintype Matrix BigOperators

noncomputable section

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- A subset `D` of a finite group `G` is a `(v, k, lam)`-difference set if
    `|G| = v`, `|D| = k`, and for every non-identity element `g ∈ G`,
    there are exactly `lam` elements `d ∈ D` such that `g * d ∈ D`.

    This is equivalent to the standard definition requiring that every `g ≠ 1`
    has exactly `λ` representations as `d₁ * d₂⁻¹` with `d₁, d₂ ∈ D`. -/
structure IsDifferenceSet (D : Finset G) (v k lam : ℕ) : Prop where
  card_group : Fintype.card G = v
  card_set : D.card = k
  diff_count : ∀ g : G, g ≠ 1 →
    (D.filter (fun d => g * d ∈ D)).card = lam

/-- The sign matrix of a subset `D ⊆ G`, defined by `A(g,h) = +1` if `g⁻¹h ∈ D`
    and `A(g,h) = -1` otherwise. This is the `{±1}`-matrix whose Gram identity
    encodes the autocorrelation structure of `D`. -/
def differenceSetSignMatrix (D : Finset G) : Matrix G G ℤ :=
  fun g h => if g⁻¹ * h ∈ D then 1 else -1

end