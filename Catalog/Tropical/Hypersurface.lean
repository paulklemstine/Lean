/-
# Tropical Hypersurfaces via Corner Loci

This file formalizes the foundational structural theorem of tropical geometry:
the tropical hypersurface of a polynomial (the locus where the maximum is attained
at least twice) is exactly the union of pairwise competition cells where two
affine forms tie and dominate all others.

## Main definitions
- `TropMonomial n` : a tropical monomial with real coefficient and exponent vector
- `TropMonomial.eval` : evaluation of a tropical monomial as an affine form
- `tropPolyEval` : evaluation of a tropical polynomial (finite set of monomials) via `Finset.sup'`
- `IsTropRoot` : the tropical root condition (max attained by ≥ 2 distinct monomials)
- `TropHypersurface` : the set of tropical roots
- `PairCell` : competition cell where two monomials tie and dominate all others

## Main results
- `isTropRoot_iff_pairwise_dominating_tie` : the structural theorem characterizing
  tropical roots as points in some pairwise competition cell
- `tropHypersurface_eq_iUnion_pairCells` : set-level formulation
- `eval_le_tropPolyEval` : each monomial evaluation is bounded by the polynomial evaluation
- `exists_mem_eval_eq_tropPolyEval` : the sup is attained by some monomial
- `isClosed_tropHypersurface` : the tropical hypersurface is a closed set

## References
The corner locus paradigm is the foundational viewpoint of tropical geometry.
See Maclagan–Sturmfels "Introduction to Tropical Geometry" for background.
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-- A tropical monomial in `n` variables consists of a real coefficient
    and an exponent vector in `Fin n → ℕ`. -/
structure TropMonomial (n : ℕ) where
  coeff : ℝ
  exp   : Fin n → ℕ
  deriving DecidableEq

/-- Evaluate a tropical monomial at a point `x : Fin n → ℝ`.
    This gives the affine form `c + ∑ᵢ αᵢ · xᵢ`. -/
def TropMonomial.eval {n : ℕ} (m : TropMonomial n) (x : Fin n → ℝ) : ℝ :=
  m.coeff + ∑ i, (m.exp i : ℝ) * x i

/-- Evaluate a nonempty tropical polynomial (given as a nonempty `Finset` of monomials)
    at a point, returning the maximum of all monomial evaluations. -/
def tropPolyEval {n : ℕ} (p : Finset (TropMonomial n)) (hp : p.Nonempty)
    (x : Fin n → ℝ) : ℝ :=
  p.sup' hp (fun m => m.eval x)

/-
Each monomial's evaluation is at most the polynomial's evaluation.
-/
theorem eval_le_tropPolyEval {n : ℕ} (p : Finset (TropMonomial n)) (hp : p.Nonempty)
    (m : TropMonomial n) (hm : m ∈ p) (x : Fin n → ℝ) :
    m.eval x ≤ tropPolyEval p hp x := by
  exact Finset.le_sup' ( fun m => m.eval x ) hm

/-
The supremum is attained by some monomial in the polynomial.
-/
theorem exists_mem_eval_eq_tropPolyEval {n : ℕ} (p : Finset (TropMonomial n))
    (hp : p.Nonempty) (x : Fin n → ℝ) :
    ∃ m ∈ p, m.eval x = tropPolyEval p hp x := by
  -- Let `s` be `fun m => m.eval x` and `H` be `hp`. Apply the provided lemma `exists_mem_eq_sup'`.
  have hfunc : ∃ i ∈ p, p.sup' hp (fun m => m.eval x) = (fun m => m.eval x) i := by
      -- Use the `Finset.exists_mem_eq_sup'` lemma which takes the function `f : ι → α` and
      -- the set `s` as a `Finset`.
    let s := (fun m : TropMonomial n => m.eval x)
    apply Finset.exists_mem_eq_sup' hp s;
  exact ⟨ hfunc.choose, hfunc.choose_spec.1, hfunc.choose_spec.2.symm ⟩

/-- A point `x` is a tropical root of polynomial `p` if the maximum value
    is attained by at least two distinct monomials. -/
def IsTropRoot {n : ℕ} (p : Finset (TropMonomial n)) (hp : p.Nonempty)
    (x : Fin n → ℝ) : Prop :=
  ∃ m₁ ∈ p, ∃ m₂ ∈ p, m₁ ≠ m₂ ∧
    m₁.eval x = tropPolyEval p hp x ∧
    m₂.eval x = tropPolyEval p hp x

/-- The tropical hypersurface is the set of all tropical roots. -/
def TropHypersurface {n : ℕ} (p : Finset (TropMonomial n)) (hp : p.Nonempty) :
    Set (Fin n → ℝ) :=
  {x | IsTropRoot p hp x}

/-- A pair cell is the set of points where monomials `m₁` and `m₂` tie
    and dominate all other monomials in the polynomial. -/
def PairCell {n : ℕ} (p : Finset (TropMonomial n))
    (m₁ m₂ : TropMonomial n) : Set (Fin n → ℝ) :=
  {x | m₁ ∈ p ∧ m₂ ∈ p ∧ m₁ ≠ m₂ ∧
       m₁.eval x = m₂.eval x ∧
       ∀ m ∈ p, m.eval x ≤ m₁.eval x}

/-
**Main Structural Theorem**: A point is a tropical root if and only if
    there exist two distinct monomials that tie and dominate all others.
    This characterizes the tropical hypersurface as a union of pairwise
    competition cells.
-/
theorem isTropRoot_iff_pairwise_dominating_tie {n : ℕ}
    (p : Finset (TropMonomial n)) (hp : p.Nonempty) (x : Fin n → ℝ) :
    IsTropRoot p hp x ↔
      ∃ m₁ ∈ p, ∃ m₂ ∈ p, m₁ ≠ m₂ ∧
        m₁.eval x = m₂.eval x ∧
        (∀ m ∈ p, m.eval x ≤ m₁.eval x) := by
  refine' ⟨ _, _ ⟩;
  · rintro ⟨ m₁, hm₁, m₂, hm₂, hne, h₁, h₂ ⟩;
    exact ⟨ m₁, hm₁, m₂, hm₂, hne, h₁.trans h₂.symm, fun m hm => h₁.symm ▸ Finset.le_sup' ( fun m => m.eval x ) hm ⟩;
  · rintro ⟨ m₁, hm₁, m₂, hm₂, hne, heq, hle ⟩;
    refine' ⟨ m₁, hm₁, m₂, hm₂, hne, _, _ ⟩;
    · exact le_antisymm ( Finset.le_sup' ( fun m => m.eval x ) hm₁ ) ( Finset.sup'_le _ _ fun m hm => hle m hm );
    · exact le_antisymm ( Finset.le_sup' ( fun m => m.eval x ) hm₂ ) ( by simpa [ heq ] using Finset.sup'_le _ _ fun m hm => hle m hm )

/-
The tropical hypersurface equals the union of all pairwise competition cells.
-/
theorem tropHypersurface_eq_iUnion_pairCells {n : ℕ}
    (p : Finset (TropMonomial n)) (hp : p.Nonempty) :
    TropHypersurface p hp =
      ⋃ m₁ ∈ p, ⋃ m₂ ∈ p, PairCell p m₁ m₂ := by
  ext x;
  simp +decide [ isTropRoot_iff_pairwise_dominating_tie, TropHypersurface, PairCell ];
  grind

/-
Tropical monomial evaluation is a continuous function.
-/
theorem continuous_tropMonomial_eval {n : ℕ} (m : TropMonomial n) :
    Continuous (fun x : Fin n → ℝ => m.eval x) := by
  exact continuous_const.add ( continuous_finset_sum _ fun _ _ => continuous_const.mul ( continuous_apply _ ) )

/-
**Geometric Theorem**: The tropical hypersurface is a closed subset
    of `Fin n → ℝ`. This follows because it is a finite union of
    intersections of closed sets defined by continuous (in)equalities.
-/
theorem isClosed_tropHypersurface {n : ℕ}
    (p : Finset (TropMonomial n)) (hp : p.Nonempty) :
    IsClosed (TropHypersurface p hp) := by
  convert Set.Finite.isClosed_biUnion ( p.finite_toSet ) fun m₁ hm₁ => Set.Finite.isClosed_biUnion ( p.finite_toSet ) fun m₂ hm₂ => ?_;
  rotate_left;
  exact fun m₁ m₂ => { x : Fin n → ℝ | m₁ ∈ p ∧ m₂ ∈ p ∧ m₁ ≠ m₂ ∧ m₁.eval x = m₂.eval x ∧ ∀ m ∈ p, m.eval x ≤ m₁.eval x };
  · by_cases h : m₁ = m₂ <;> simp_all +decide [ Set.setOf_and, Set.setOf_forall ];
    exact IsClosed.inter ( isClosed_eq ( continuous_tropMonomial_eval m₁ ) ( continuous_tropMonomial_eval m₂ ) ) ( isClosed_biInter fun i hi => isClosed_le ( continuous_tropMonomial_eval i ) ( continuous_tropMonomial_eval m₁ ) );
  · convert tropHypersurface_eq_iUnion_pairCells p hp

end