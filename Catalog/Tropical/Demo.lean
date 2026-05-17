/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Demonstration Theorems for the Tropical Reflection Tactic

This file contains nontrivial tropical identities proved through two methods:
1. **Manual reflection**: explicitly reifying and applying `cnormalize_ca_eq_implies_semantic_eq`
2. **The `tropical` tactic**: automatic reification and normalization

Each theorem is a certified identity in the min-plus (tropical) semiring,
verified by a compile-time computation that checks canonical form equality.
-/

import Tropical.Tactic

open CTropExpr

/-! ## Manual Reflection Proofs -/

/-- Commutativity + associativity rearrangement with duplication. -/
theorem tropical_assoc_comm_example (a b c d : ℝ) :
    min (a + b) (min (c + d) (a + b)) = min (min (d + c) (b + a)) (a + b) :=
  cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.add (.var 0) (.var 1)) (.tmin (.add (.var 2) (.var 3)) (.add (.var 0) (.var 1))))
    (.tmin (.tmin (.add (.var 3) (.var 2)) (.add (.var 1) (.var 0))) (.add (.var 0) (.var 1)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | 2 => c | _ => d)

/-- Flattening nested mins into canonical right-associated form. -/
theorem tropical_flatten_example (a b c d : ℝ) :
    min (min a b) (min c d) = min a (min b (min c d)) :=
  cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.tmin (.var 0) (.var 1)) (.tmin (.var 2) (.var 3)))
    (.tmin (.var 0) (.tmin (.var 1) (.tmin (.var 2) (.var 3))))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | 2 => c | _ => d)

/-- Duplicate elimination: `min(x, min(x, y)) = min(y, x)`. -/
theorem tropical_duplicate_elim_example (a b c : ℝ) :
    min (a + b) (min (a + b) c) = min c (b + a) :=
  cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.add (.var 0) (.var 1)) (.tmin (.add (.var 0) (.var 1)) (.var 2)))
    (.tmin (.var 2) (.add (.var 1) (.var 0)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | _ => c)

/-- AC collapse: `min(a+(b+c), (c+b)+a) = a+(b+c)`. -/
theorem tropical_semiring_AC_normal_form (a b c : ℝ) :
    min (a + (b + c)) ((c + b) + a) = a + (b + c) :=
  cnormalize_ca_eq_implies_semantic_eq
    (.tmin (.add (.var 0) (.add (.var 1) (.var 2)))
           (.add (.add (.var 2) (.var 1)) (.var 0)))
    (.add (.var 0) (.add (.var 1) (.var 2)))
    (by native_decide)
    (fun n => match n with | 0 => a | 1 => b | _ => c)

/-! ## Tactic-based Proofs

The following theorems are proved entirely by the `tropical` tactic,
which automatically reifies the goal, normalizes, and checks equality. -/

/-- Simple commutativity of addition under min. -/
theorem tropical_tactic_comm (a b : ℝ) : min (a + b) (b + a) = a + b := by
  tropical

/-- Idempotence of min. -/
theorem tropical_tactic_idem (a : ℝ) : min a a = a := by
  tropical

/-- Nested idempotence. -/
theorem tropical_tactic_nested_idem (a : ℝ) : min (min a a) (min a a) = a := by
  tropical

/-- Associativity and commutativity combined. -/
theorem tropical_tactic_assoc_comm (a b c : ℝ) :
    min (min a b) c = min a (min b c) := by
  tropical

/-- Triple redundancy elimination. -/
theorem tropical_tactic_triple_redundancy (a b : ℝ) :
    min (a + b) (min (b + a) (a + b)) = a + b := by
  tropical

/-- Six sub-expression deduplication. -/
theorem tropical_tactic_six_subexpr (a b c d : ℝ) :
    min (min (a + b) (c + d)) (min (b + a) (d + c))
    = min (a + b) (c + d) := by
  tropical

/-- Five-variable identity. -/
theorem tropical_tactic_five_var (a b c d e : ℝ) :
    min (min (a + b) (c + d)) (min (d + c) (min (b + a) e))
    = min (min (a + b) e) (c + d) := by
  tropical

/-- Deep nesting with three variables. -/
theorem tropical_tactic_deep_nesting (a b c : ℝ) :
    min (min (a + b + c) (b + a + c)) (c + (b + a))
    = min (a + b + c) (c + (a + b)) := by
  tropical

/-- Six-variable tropical identity. -/
theorem tropical_tactic_six_var (a b c d e f : ℝ) :
    min (min (a + b) (min (c + d) (e + f)))
        (min (f + e) (min (d + c) (b + a)))
    = min (a + b) (min (c + d) (e + f)) := by
  tropical

/-- AC collapse demonstrated via tactic. -/
theorem tropical_tactic_ac_collapse (a b c : ℝ) :
    min (a + (b + c)) ((c + b) + a) = a + (b + c) := by
  tropical

/-- Flatten + reorder + deduplicate, all in one shot. -/
theorem tropical_tactic_complex (a b c d : ℝ) :
    min (min (a + b) (min (c + d) (a + b)))
        (min (d + c) (b + a))
    = min (a + b) (c + d) := by
  tropical