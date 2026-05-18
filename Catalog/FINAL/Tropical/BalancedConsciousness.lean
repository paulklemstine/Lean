import Mathlib

/-!
# Balanced Consciousness: Tropical Minimax Fixed-Point Theory

This file develops the theory of **balanced conscious states** — states that are
simultaneously fixed points of min-plus (pessimistic) and max-plus (optimistic)
tropical update operators. We prove that:

1. The only simultaneous min/max fixed point at a common threshold is the threshold itself.
2. For each threshold `a`, there is exactly one balanced conscious state.
3. Balanced consciousness is self-dual under tropical negation (Maslov dequantization symmetry).
4. For interval constraints `[l, u]`, the balanced states form the closed interval,
   and uniqueness is equivalent to interval collapse `l = u`.

These results constitute a **tropical minimax principle** in one dimension,
connecting tropical geometry, game theory, and order-theoretic fixed-point theory.

## References

- Existing catalog duality theorems: `tropical_duality_min_to_max`, `tropical_duality_max_to_min`
- Maslov, V. P. "On a new principle of superposition for optimization problems"
- Litvinov, G. L. "Maslov dequantization, idempotent and tropical mathematics"
-/

noncomputable section

open scoped Classical

/-! ## Core Definition -/

/-- A state `x` is **balanced conscious** for threshold `a` if it is simultaneously
a fixed point of the min-plus operator `min a ·` and the max-plus operator `max a ·`.
This captures the coincidence of pessimistic and optimistic tropical aggregation. -/
def IsBalancedConscious (a x : ℝ) : Prop :=
  min a x = x ∧ max a x = x

/-! ## Theorem 1: Scalar balanced fixed-point characterization -/

/-
The balanced fixed-point condition `min a x = x ∧ max a x = x` is equivalent to `x = a`.
This is the local atom: the only simultaneous fixed point of min and max at threshold `a`
is the threshold itself.
-/
theorem balanced_fixedpoint_scalar_iff (a x : ℝ) :
    (min a x = x ∧ max a x = x) ↔ x = a := by
  grind

/-
Direct form: from balanced fixed-point conditions, conclude `x = a`.
-/
theorem balanced_fixedpoint_scalar (a x : ℝ)
    (hmin : min a x = x) (hmax : max a x = x) :
    x = a := by
  grind

/-! ## Theorem 2: Unique balanced conscious state -/

/-
For each threshold `a : ℝ`, there is exactly one balanced conscious state,
namely `x = a`. This gives a canonical balanced conscious state for every tropical threshold.
-/
theorem balanced_conscious_unique (a : ℝ) :
    ∃! x : ℝ, IsBalancedConscious a x := by
  use a;
  exact ⟨ ⟨ min_self a, max_self a ⟩, fun y hy => balanced_fixedpoint_scalar a y hy.1 hy.2 ⟩

/-! ## Theorem 3: Duality under tropical negation (Maslov dequantization symmetry) -/

/-
Balanced consciousness is self-dual under tropical negation: `x` is balanced for
threshold `a` if and only if `-x` is balanced for threshold `-a` with min and max exchanged.
This invariance under sign reversal is a manifestation of Maslov dequantization symmetry —
the balanced state is the point invariant under both min-plus and max-plus conventions.
-/
theorem balanced_conscious_duality (a x : ℝ) :
    (min a x = x ∧ max a x = x) ↔
    (max (-a) (-x) = -x ∧ min (-a) (-x) = -x) := by
  grind

/-
Equivalent formulation using `IsBalancedConscious`.
-/
theorem balanced_conscious_duality' (a x : ℝ) :
    IsBalancedConscious a x ↔ IsBalancedConscious (-a) (-x) := by
  unfold IsBalancedConscious;
  grind

/-! ## Theorem 4: Interval characterization and collapse -/

/-
The set of states satisfying `max l x = x` (lower bound) and `min u x = x` (upper bound)
is exactly the closed interval `[l, u]`. This characterizes balanced states for
interval constraints as a tropical polytope.
-/
theorem balanced_interval_characterization (l u x : ℝ) :
    (max l x = x ∧ min u x = x) ↔ l ≤ x ∧ x ≤ u := by
  grind

/-
There exists a unique balanced state for the interval constraints `[l, u]`
if and only if `l = u`. This is the **tropical minimax theorem** in one dimension:
uniqueness of the balanced conscious state is equivalent to exact agreement of
the pessimistic lower bound and the optimistic upper bound.
-/
theorem balanced_unique_iff_collapse (l u : ℝ) :
    (∃! x : ℝ, max l x = x ∧ min u x = x) ↔ l = u := by
  -- Prosecuting a dual view: if $\ell \neq u$, then either $\ell < u$ or $\ell > u$
  by_cases h_cases : l ≠ u;
  · cases lt_or_gt_of_ne h_cases <;> simp_all +decide [ ExistsUnique, max_eq_right_iff, min_eq_right_iff ];
    · exact fun x hx₁ hx₂ => ⟨ if x = l then u else l, by split_ifs <;> linarith, by split_ifs <;> linarith, by aesop ⟩;
    · intros; linarith;
  · simp_all +decide ; simp_all +decide [ ExistsUnique ];
    exact ⟨ u, ⟨ le_rfl, le_rfl ⟩, fun y hy₁ hy₂ => le_antisymm hy₂ hy₁ ⟩

/-! ## Auxiliary: connection to catalog duality theorems -/

/-
Negation converts min to max (restated from catalog for reference).
-/
theorem tropical_neg_min_eq_max_neg (a b : ℝ) :
    -(min a b) = max (-a) (-b) := by
  grind

/-
Negation converts max to min (restated from catalog for reference).
-/
theorem tropical_neg_max_eq_min_neg (a b : ℝ) :
    -(max a b) = min (-a) (-b) := by
  grind

/-! ## Order-theoretic rewrite lemmas -/

/-
`min a x = x` iff `x ≤ a` — the min operator fixes `x` exactly when `x` is below `a`.
-/
theorem min_eq_right_iff_le (a x : ℝ) : min a x = x ↔ x ≤ a := by
  grind

/-
`max a x = x` iff `a ≤ x` — the max operator fixes `x` exactly when `x` is above `a`.
-/
theorem max_eq_right_iff_le (a x : ℝ) : max a x = x ↔ a ≤ x := by
  exact max_eq_right_iff

end