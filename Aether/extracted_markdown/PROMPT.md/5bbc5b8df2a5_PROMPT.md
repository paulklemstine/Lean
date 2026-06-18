Produce one complete Lean 4 file formalizing a tightly scoped result about finite pseudometric spaces and Rips-threshold edge counts. Do not introduce unrelated bridge frameworks, theory morphisms, neural-network material, tropical generalities, or declaration skeletons. The file must compile with no `sorry`.

Target development:

1. Setup.
   - Work with a type `α` equipped with `[Fintype α] [DecidableEq α] [PseudoMetricSpace α]`.
   - Use distances valued in `ℝ` via `dist`.

2. Core definitions.
   - Define the thresholded Rips edge predicate at scale `r : ℝ`:
     `RipsEdge r x y := x ≠ y ∧ dist x y ≤ r`.
   - Define `edgeCount (r : ℝ) : ℕ` as the number of unordered vertex pairs satisfying `RipsEdge r`.
     Important: choose an implementation that is easy to prove with in Lean. For example, if a canonical unordered-pair type is awkward, count ordered pairs and define
     `orientedEdgeCount r := card { (x,y) | x ≠ y ∧ dist x y ≤ r }`
     and prove it is even; then define `edgeCount r := orientedEdgeCount r / 2`.
     If there is a simpler existing finite-pair API in Mathlib, use it instead.
   - Define `edgeBirthSup : ℝ` as the supremum of realized distances:
     `sSup {t : ℝ | ∃ x y : α, t = dist x y}`.
     Since `α` is finite, also prove or use a finite-maximum characterization if helpful.

3. Main theorems to prove completely.
   - Monotonicity:
     `theorem edgeCount_mono {r s : ℝ} (h : r ≤ s) : edgeCount r ≤ edgeCount s`
   - Vanishing below zero:
     `theorem edgeCount_eq_zero_of_lt_zero {r : ℝ} (hr : r < 0) : edgeCount r = 0`
     using nonnegativity of distances.
   - Saturation above the birth supremum:
     `theorem edgeCount_eq_top_of_edgeBirthSup_le {r : ℝ} (h : edgeBirthSup ≤ r) : edgeCount r = Nat.choose (Fintype.card α) 2`
     or, if unordered-pair implementation is inconvenient, state and prove the oriented version
     `orientedEdgeCount r = card α * (card α - 1)`
     and then derive the unordered formula when possible.
     The proof idea is: every distinct pair has distance ≤ `edgeBirthSup`, hence ≤ `r`, so every possible edge is present.

4. Optional lightweight valuation packaging, only if the above is already complete and short.
   - Define `edgeCountValuation (r : ℝ) : ℝ≥0∞ := edgeCount r`
   - Prove monotonicity as a map into `ℝ≥0∞`.
   This is optional and should not jeopardize completion.

5. Style constraints.
   - Keep the file self-contained and focused.
   - Prefer `Catalog/FINAL/` imports when relevant, but only if genuinely useful for finite counting or pseudometric facts.
   - No placeholders, no theorem headers without bodies, no unrelated abstractions.
   - Include brief module docstrings explaining the mathematical meaning.

If the unordered-pair counting route becomes technically heavy, pivot explicitly to the oriented-edge version and fully complete that version instead of leaving partial definitions. A complete oriented-edge theorem suite is preferable to an incomplete unordered-edge formalization.