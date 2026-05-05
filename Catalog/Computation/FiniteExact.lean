/-
# Finite Exact Max-Plus Representation

Every function f : X → Y → ℝ on finite types can be exactly represented
as the pointwise maximum of at most |X| * |Y| separable max-plus terms.

This is the combinatorial heart of the tropical approximation theory:
every real matrix is a max-plus superposition of rank-1 separable potentials.
-/
import Computation.TropicalApprox.Defs

open Finset TropicalApprox

namespace TropicalApprox

/-! ## Anchored Term Properties -/

/-- At its anchor point, an anchored term evaluates to exactly f(x₀, y₀). -/
lemma anchoredTerm_eval_anchor {X Y : Type*} [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) (D : ℝ) (x₀ : X) (y₀ : Y) :
    (anchoredTerm f D x₀ y₀).eval x₀ y₀ = f x₀ y₀ := by
  unfold MaxPlusTerm.eval anchoredTerm
  grind

/-
Away from the anchor's x-coordinate, the term is suppressed by D
    (assuming D ≥ 0).
-/
lemma anchoredTerm_eval_ne_x {X Y : Type*} [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) (D : ℝ) (hD : 0 ≤ D) (x₀ : X) (y₀ : Y)
    (x : X) (y : Y) (hx : x ≠ x₀) :
    (anchoredTerm f D x₀ y₀).eval x y ≤ f x₀ y₀ - D := by
  unfold MaxPlusTerm.eval anchoredTerm;
  grind

/-
Away from the anchor's y-coordinate, the term is suppressed by D
    (assuming D ≥ 0).
-/
lemma anchoredTerm_eval_ne_y {X Y : Type*} [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) (D : ℝ) (hD : 0 ≤ D) (x₀ : X) (y₀ : Y)
    (x : X) (y : Y) (hy : y ≠ y₀) :
    (anchoredTerm f D x₀ y₀).eval x y ≤ f x₀ y₀ - D := by
  unfold MaxPlusTerm.eval anchoredTerm;
  grind

/-
If D ≥ 0 is at least the oscillation of f, then each anchored term
    is bounded above by f at every point.
-/
lemma anchoredTerm_le_f {X Y : Type*} [DecidableEq X] [DecidableEq Y]
    [Fintype X] [Fintype Y] [Nonempty X] [Nonempty Y]
    (f : X → Y → ℝ) (D : ℝ)
    (hD : ∀ x₁ y₁ x₂ y₂, f x₁ y₁ - f x₂ y₂ ≤ D)
    (x₀ : X) (y₀ : Y) (x : X) (y : Y) :
    (anchoredTerm f D x₀ y₀).eval x y ≤ f x y := by
  by_cases hx : x = x₀ <;> by_cases hy : y = y₀;
  · simpa [ hx, hy ] using anchoredTerm_eval_anchor f D x₀ y₀ |> le_of_eq;
  · simp +decide [ *, anchoredTerm, MaxPlusTerm.eval ];
    linarith [ hD x₀ y₀ x₀ y ];
  · unfold anchoredTerm; simp +decide [ *, MaxPlusTerm.eval ];
    linarith [ hD x₀ y₀ x y₀ ];
  · -- Since $D \geq 0$, we have $D - D = 0$.
    apply le_trans (anchoredTerm_eval_ne_x f D (by
    linarith [ hD x₀ y₀ x₀ y₀ ]) x₀ y₀ x y hx);
    linarith [ hD x₀ y₀ x y ]

/-! ## Finite Exact Representation Theorem -/

/-
**Finite Exact Max-Plus Representation Theorem.**

Every function f : X → Y → ℝ on finite nonempty types admits an exact
representation as the pointwise maximum of |X| * |Y| separable max-plus terms
c + a(x) + b(y).

The construction uses one anchored term per grid point (x₀, y₀),
with the localization constant D chosen to exceed the oscillation of f.
At each evaluation point (x, y), the anchor term for (x, y) achieves f(x, y)
while all other anchor terms are suppressed below f(x, y).
-/
theorem exists_exact_maxplus_representation_finite
    {X Y : Type*} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    [Nonempty X] [Nonempty Y]
    (f : X → Y → ℝ) :
    ∃ ts : Fin (Fintype.card X * Fintype.card Y) → MaxPlusTerm X Y,
      ∀ x y,
        (∀ i, (ts i).eval x y ≤ f x y) ∧
        (∃ i, (ts i).eval x y = f x y) := by
  obtain ⟨e, he⟩ : ∃ e : X × Y ≃ Fin (Fintype.card X * Fintype.card Y), True := by
    exact ⟨ Fintype.equivFinOfCardEq ( by simp +decide [ Fintype.card_prod ] ), trivial ⟩;
  refine' ⟨ fun i => anchoredTerm f ( Finset.univ.sup' ( Finset.univ_nonempty ) ( fun p : X × Y => f p.1 p.2 ) - Finset.univ.inf' ( Finset.univ_nonempty ) ( fun p : X × Y => f p.1 p.2 ) ) ( e.symm i |>.1 ) ( e.symm i |>.2 ), _ ⟩;
  refine' fun x y => ⟨ fun i => _, e ⟨ x, y ⟩, _ ⟩;
  · apply anchoredTerm_le_f;
    exact fun x₁ y₁ x₂ y₂ => sub_le_sub ( Finset.le_sup' ( fun p => f p.1 p.2 ) ( Finset.mem_univ ( x₁, y₁ ) ) ) ( Finset.inf'_le _ ( Finset.mem_univ ( x₂, y₂ ) ) );
  · unfold anchoredTerm MaxPlusTerm.eval; aesop;

end TropicalApprox