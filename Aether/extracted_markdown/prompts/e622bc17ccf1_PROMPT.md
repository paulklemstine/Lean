Complete the Lean 4 file developing the threshold-profile valuation on binary words over ZMod 2.

Target file: Catalog/Algebra/ThresholdProfile.lean

You should preserve the existing core setup:
- support (x : Fin n → ZMod 2) : Finset (Fin n) := Finset.univ.filter (fun i => x i ≠ 0)
- tprof (x : Fin n → ZMod 2) : ℕ := (support x).sup (fun i => i.val + 1)
- mem_support_iff
- tprof_le_iff
and then finish the development rigorously.

Precise goals:
1. Prove tprof_eq_zero_iff : tprof x = 0 ↔ x = 0.
2. Prove tprof_add_le_max : tprof (x + y) ≤ max (tprof x) (tprof y).
3. Prove the main strict-max theorem
   tprof_add_eq_max_of_ne (h : tprof x ≠ tprof y) :
     tprof (x + y) = max (tprof x) (tprof y).

Recommended proof strategy:
- Use tprof_le_iff as the main engine.
- For tprof_eq_zero_iff, one direction should use tprof_le_iff with t = 0; the other is immediate by ext and simp.
- For tprof_add_le_max, show any coordinate i with max (tprof x) (tprof y) ≤ i.val must satisfy x i = 0 and y i = 0 by tprof_le_iff, hence (x + y) i = 0.
- For tprof_add_eq_max_of_ne, combine tprof_add_le_max with a lower bound.
  Split on lt_or_gt_of_ne h.
  In the case hxy : tprof x < tprof y:
  * Obtain a witness i : Fin n with y i ≠ 0 and tprof y = i.val + 1. You may prove an auxiliary lemma giving a top-support witness for nonzero words/support-supremum, e.g. from Finset.exists_mem_eq_sup' or by using Finset.max' on support y once support y is nonempty.
  * Show x i = 0 because i.val + 1 = tprof y and hxy implies i.val ≥ tprof x; equivalently derive tprof x ≤ i.val and apply tprof_le_iff to threshold i.val.
  * Conclude (x + y) i ≠ 0; over ZMod 2 this is just by simp [hx, hy].
  * Deduce tprof y ≤ tprof (x + y), e.g. by contradiction using tprof_le_iff at threshold tprof y, or by a direct support/sup lower-bound lemma.
  * Together with tprof_add_le_max, conclude equality with max.
  The case tprof y < tprof x is symmetric.

Implementation guidance:
- Prefer a short auxiliary lemma if needed, such as:
  * tprof_pos_of_ne_zero
  * exists_active_of_tprof_pos
  * exists_eq_tprof_of_ne_zero : x ≠ 0 → ∃ i, x i ≠ 0 ∧ tprof x = i.val + 1
  Any of these is acceptable if it helps extract the maximal active coordinate cleanly.
- Keep the file self-contained and avoid unnecessary abstractions.
- Eliminate all incomplete tactic blocks and parser issues.
- Ensure the final file compiles without sorry.

This is a formalization task, not an exploratory one: the objective is a clean, complete finite combinatorial valuation theory for binary words, culminating in the strict-max law for addition when profiles differ.