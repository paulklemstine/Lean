You are repairing the existing file `Catalog/Bridges/OpTreeKraft.lean`. Do not change the mathematical topic. Keep the current definitions of `OpTree`, `numLeaves`, `height`, `maxLeafDepth`, and `leafDepths`, and focus on completing the missing core results with clean Lean proofs.

Main task:
1. Formalize the Kraft identity in a way that is easy to prove in Lean. Work over `ℚ` (preferred) or `ℝ` if necessary, and define a helper such as
   `kraftWeight (t : OpTree K) : ℚ := ((leafDepths t).map (fun d => (1 : ℚ) / 2^d)).sum`.
   Then prove `kraftWeight t = 1` for all `t`.

Recommended proof strategy for `kraftWeight`:
- First prove a list lemma that `List.sum` over an appended list splits.
- In the node case, unfold `leafDepths`; after mapping depths by `d ↦ d+1`, rewrite
  `(1 : ℚ) / 2^(d+1) = ((1 : ℚ) / 2) * ((1 : ℚ) / 2^d)`.
- Use the induction hypotheses for the left and right subtrees.
- Finish with ring/field simplification to show the total is `1`.

2. Prove the structural exponential bound
   `numLeaves t ≤ 2 ^ height t`.
   This should be by induction on `t`; in the node case use
   `numLeaves l + numLeaves r ≤ 2^(height l) + 2^(height r) ≤ 2^(max (height l) (height r) + 1)`.
   Simple monotonicity of powers of 2 and `2^m + 2^m = 2^(m+1)` should suffice.

3. Derive the logarithmic corollary
   `Nat.clog 2 (numLeaves t) ≤ height t`.
   Use the previous theorem `numLeaves t ≤ 2 ^ height t` together with an appropriate `Nat.clog` monotonicity/characterization lemma from Mathlib. Avoid brittle calc blocks; prove this as a short consequence of the exponential bound.

4. Preserve and reuse the already valid results (`numLeaves_pos`, `leafDepths_length`, `maxLeafDepth_le_height`, `height_le_maxLeafDepth`) if they help, but do not spend time generalizing them.

Implementation constraints:
- Stay in the same file and namespace if possible.
- Prefer small helper lemmas over complicated tactic scripts.
- If the original theorem name `kraft_sum` is retained, make it state the precise weighted sum over `ℚ`; otherwise introduce `kraftWeight` and then prove `kraft_sum` as a wrapper theorem.
- Do not introduce `sorry`.
- The output should compile.

Deliverable:
A corrected `Catalog/Bridges/OpTreeKraft.lean` where the main theorem (Kraft identity) and the logarithmic height bound are fully proved, ideally via the stronger intermediate theorem `numLeaves t ≤ 2 ^ height t`.