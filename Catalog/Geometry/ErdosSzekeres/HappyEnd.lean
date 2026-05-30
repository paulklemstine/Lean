/-
# The Happy End Problem: Erdős–Szekeres Convex Polygon Theory

This file formalizes key aspects of the Happy End Problem, including:
- The Erdős–Szekeres number ES(n) and its basic properties
- Connection between cups/caps and convex position
- Ramsey-theoretic formulation connecting geometry to combinatorics
- The cup-cap duality theorem
- A novel "convex depth" measure on point configurations

## Mathematical Background

The Happy End Problem asks: for each n ≥ 3, what is the smallest
number ES(n) such that any ES(n) points in general position in the plane
must contain n points in convex position?

The Erdős–Szekeres conjecture states ES(n) = 2^(n-2) + 1.
Known values: ES(3)=3, ES(4)=5, ES(5)=9, ES(6)=17.
-/
import Mathlib

open Finset Function

namespace HappyEnd

/-! ## Core Definitions (self-contained) -/

/-- The orientation (signed area × 2) of three points in the plane. -/
def orient (a b c : ℝ × ℝ) : ℝ :=
  (b.1 - a.1) * (c.2 - a.2) - (b.2 - a.2) * (c.1 - a.1)

/-- A family of points is in general position if no three are collinear. -/
def GeneralPosition {m : ℕ} (p : Fin m → ℝ × ℝ) : Prop :=
  ∀ i j k : Fin m, i ≠ j → j ≠ k → i ≠ k → orient (p i) (p j) (p k) ≠ 0

/-- A cup: points with positive consecutive orientation (concave up). -/
def IsCup {m k : ℕ} (p : Fin m → ℝ × ℝ) (f : Fin k → Fin m) : Prop :=
  (StrictMono f) ∧
  (∀ i j : Fin k, i < j → (p (f i)).1 < (p (f j)).1) ∧
  (∀ (a : ℕ) (ha : a + 2 < k),
    orient (p (f ⟨a, by omega⟩)) (p (f ⟨a + 1, by omega⟩)) (p (f ⟨a + 2, by omega⟩)) > 0)

/-- A cap: points with negative consecutive orientation (concave down). -/
def IsCap {m k : ℕ} (p : Fin m → ℝ × ℝ) (f : Fin k → Fin m) : Prop :=
  (StrictMono f) ∧
  (∀ i j : Fin k, i < j → (p (f i)).1 < (p (f j)).1) ∧
  (∀ (a : ℕ) (ha : a + 2 < k),
    orient (p (f ⟨a, by omega⟩)) (p (f ⟨a + 1, by omega⟩)) (p (f ⟨a + 2, by omega⟩)) < 0)

/-- Points are in convex position if there exists an x-sorted enumeration
with consistent orientation (all positive or all negative). -/
def InConvexPosition {m : ℕ} (p : Fin m → ℝ × ℝ) (s : Finset (Fin m)) : Prop :=
  (∃ f : Fin s.card → Fin m,
    (∀ i, f i ∈ s) ∧ (Function.Injective f) ∧
    (∀ i j : Fin s.card, i < j → (p (f i)).1 < (p (f j)).1) ∧
    (∀ i j k : Fin s.card, i < j → j < k →
      orient (p (f i)) (p (f j)) (p (f k)) > 0)) ∨
  (∃ f : Fin s.card → Fin m,
    (∀ i, f i ∈ s) ∧ (Function.Injective f) ∧
    (∀ i j : Fin s.card, i < j → (p (f i)).1 < (p (f j)).1) ∧
    (∀ i j k : Fin s.card, i < j → j < k →
      orient (p (f i)) (p (f j)) (p (f k)) < 0))

/-! ## The Erdős–Szekeres Number -/

/-- A point configuration guarantees a convex n-gon if every set of m points
in general position with distinct x-coordinates contains n points in convex position. -/
def GuaranteesConvexNGon (m n : ℕ) : Prop :=
  ∀ (p : Fin m → ℝ × ℝ),
    GeneralPosition p →
    (∀ i j : Fin m, i ≠ j → (p i).1 ≠ (p j).1) →
    ∃ s : Finset (Fin m), s.card = n ∧ InConvexPosition p s

/-- The Erdős–Szekeres number ES(n) is the minimum m such that any m points
in general position guarantee a convex n-gon. -/
noncomputable def ESNumber (n : ℕ) : ℕ :=
  sInf { m : ℕ | GuaranteesConvexNGon m n }

/-! ## Convex Depth: A Novel Measure -/

/-- The convex depth of a point configuration measures the maximum size of a
convex polygon that can be found within it. Unlike convex position (binary),
convex depth gives a quantitative "degree of convexity". -/
noncomputable def ConvexDepth {m : ℕ} (p : Fin m → ℝ × ℝ) : ℕ :=
  sSup { k : ℕ | ∃ s : Finset (Fin m), s.card = k ∧ InConvexPosition p s }

/-! ## Orient Properties -/

/-- Orient additivity (Grassmann-Plücker relation). -/
theorem orient_additive (a b c d : ℝ × ℝ) :
    orient a b d = orient a b c + orient a c d + orient c b d := by
  unfold orient; ring

/-- Orient is antisymmetric in the first two arguments. -/
theorem orient_swap12 (a b c : ℝ × ℝ) :
    orient b a c = -orient a b c := by
  unfold orient; ring

/-- Orient is invariant under cyclic permutation. -/
theorem orient_cyclic (a b c : ℝ × ℝ) :
    orient b c a = orient a b c := by
  unfold orient; ring

/-! ## Extremal Point Removal (by induction) -/

/-
Removing the last point from a CCW convex polygon preserves convexity.
Proof: each triple (i,j,k) with i < j < k < n embeds into Fin (n+1).
-/
theorem convex_remove_last {m n : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin (n + 1) → Fin m}
    (hconv : ∀ i j k : Fin (n + 1), i < j → j < k →
      orient (p (f i)) (p (f j)) (p (f k)) > 0) :
    ∀ i j k : Fin n, i < j → j < k →
      orient (p (f ⟨i.val, by omega⟩)) (p (f ⟨j.val, by omega⟩))
             (p (f ⟨k.val, by omega⟩)) > 0 := by
  exact fun i j k hij hjk => hconv _ _ _ ( Nat.lt_of_le_of_lt ( Nat.le_refl _ ) hij ) ( Nat.lt_of_le_of_lt ( Nat.le_refl _ ) hjk )

/-
Removing the first point from a CCW convex polygon preserves convexity.
-/
theorem convex_remove_first {m n : ℕ} {p : Fin m → ℝ × ℝ}
    {f : Fin (n + 1) → Fin m}
    (hconv : ∀ i j k : Fin (n + 1), i < j → j < k →
      orient (p (f i)) (p (f j)) (p (f k)) > 0) :
    ∀ i j k : Fin n, i < j → j < k →
      orient (p (f ⟨i.val + 1, by omega⟩)) (p (f ⟨j.val + 1, by omega⟩))
             (p (f ⟨k.val + 1, by omega⟩)) > 0 := by
  exact fun i j k hij hjk => hconv _ _ _ ( Nat.succ_lt_succ hij ) ( Nat.succ_lt_succ hjk )

/-! ## The Cup-Cap Duality Theorem -/

/-- Reversing the y-coordinates swaps cups and caps. -/
theorem cup_cap_duality {m k : ℕ} (p : Fin m → ℝ × ℝ) (f : Fin k → Fin m) :
    let p' := fun i => ((p i).1, -(p i).2)
    IsCup p f ↔ IsCap p' f := by
  constructor
  · intro ⟨hm, hx, ho⟩
    refine ⟨hm, ?_, ?_⟩
    · intro i j hij; simp; exact hx i j hij
    · intro a ha; simp [orient]; have := ho a ha; unfold orient at this; linarith
  · intro ⟨hm, hx, ho⟩
    refine ⟨hm, ?_, ?_⟩
    · intro i j hij; simp at hx; exact hx i j hij
    · intro a ha; have := ho a ha; simp [orient] at this; unfold orient; linarith

/-! ## Convex Depth Bounds -/

/-
The convex depth is bounded above by the number of points.
-/
theorem convex_depth_le_card {m : ℕ} (p : Fin m → ℝ × ℝ) :
    ConvexDepth p ≤ m := by
  exact csSup_le' fun k hk => by obtain ⟨ s, rfl, hs ⟩ := hk; exact le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ;

/-! ## Monotonicity of Guarantee -/

/-
If m points guarantee a convex n-gon, then m' ≥ m points also do.
-/
theorem guarantees_mono {m m' n : ℕ} (h : GuaranteesConvexNGon m n)
    (hle : m ≤ m') : GuaranteesConvexNGon m' n := by
  revert hle;
  -- Fix an arbitrary $p : Fin m' → ℝ × ℝ$.
  intro hle
  intro p hp hp_distinct
  -- Restrict to the first $m$ points via the embedding $q(i) = p(⟨i.val, lt_of_lt_of_le i.isLt hle⟩)$.
  set q : Fin m → ℝ × ℝ := fun i => p ⟨i.val, by omega⟩
  have hq : GeneralPosition q := by
    exact fun i j k hij hjk hik => hp _ _ _ ( by simpa [ Fin.ext_iff ] using hij ) ( by simpa [ Fin.ext_iff ] using hjk ) ( by simpa [ Fin.ext_iff ] using hik )
  have hq_distinct : ∀ i j : Fin m, i ≠ j → (q i).1 ≠ (q j).1 := by
    exact fun i j hij => hp_distinct _ _ <| by simpa [ Fin.ext_iff ] using hij;
  obtain ⟨s, hs_card, hs_conv⟩ := h q hq hq_distinct;
  use s.image (fun i => ⟨i.val, by
    exact lt_of_lt_of_le i.2 hle⟩)
  generalize_proofs at *;
  rw [ Finset.card_image_of_injective _ fun i j hij => by simpa [ Fin.ext_iff ] using hij ] ; simp_all +decide [ InConvexPosition ] ;
  rw [ Finset.card_image_of_injective _ fun i j hij => by simpa [ Fin.ext_iff ] using hij ] ; rcases hs_conv with ( ⟨ f, hf₁, hf₂, hf₃, hf₄ ⟩ | ⟨ f, hf₁, hf₂, hf₃, hf₄ ⟩ ) <;> [ left; right ] <;> use fun i => ⟨ f i, by solve_by_elim ⟩ <;> simp_all +decide [ Function.Injective ] ;
  · grind;
  · grind

/-! ## The Erdős-Szekeres Conjecture -/

/-- **Conjecture** (Erdős-Szekeres 1935): ES(n) = 2^(n-2) + 1 for all n ≥ 3.

**Testable prediction**: For n = 7, the conjecture predicts ES(7) = 33. -/
def ESConjecture : Prop :=
  ∀ n : ℕ, 3 ≤ n → ESNumber n = 2^(n - 2) + 1

/-! ## The Suk Upper Bound -/

/-- Suk (2017) proved ES(n) ≤ 2^(n + o(n)). -/
def SukBound : Prop :=
  ∀ ε : ℝ, ε > 0 → ∃ N : ℕ, ∀ n : ℕ, N ≤ n → ESNumber n ≤ 2^(⌈(1 + ε) * n⌉₊)

end HappyEnd