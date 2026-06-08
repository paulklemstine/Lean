/-
# Dreamtime Algebra: Main Theorems

This module contains the main theorems about DreamtimeAlgebras, including:
- The marriage map is a fixed-point-free involution
- Marriage compatibility is a coset condition
- The alternating generations theorem
- The Dreamtime operator properties
- Kariera and Aranda system structural results
- The kinship spectrum counting theorem
-/

import Applications.DreamtimeAlgebra.Defs

open Finset ZMod DreamtimeAlgebra

/-! ## Theorem 1: Marriage Map is a Fixed-Point-Free Involution -/

/-
The marriage map is an involution: applying it twice returns to the original section.
-/

theorem marriageCompatible_iff_diff (D : DreamtimeAlgebra) (g h : D.G) :
    marriageCompatible D g h ↔ h - g = D.marryGen := by
  constructor <;> intro h' <;> simp_all +decide [ sub_eq_iff_eq_add ];
  · rw [ h', add_comm ];
  · exact Eq.symm ( add_comm _ _ )

/-
No section is marriage-compatible with itself (exogamy).
-/