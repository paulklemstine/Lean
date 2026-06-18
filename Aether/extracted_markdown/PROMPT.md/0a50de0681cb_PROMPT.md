Create a self-contained Lean 4 file that defines binary combination trees (OpTree) and proves the Kraft identity and structural bounds.

## Definitions Required

1. `OpTree (K : Type)` — inductive type with constructors `leaf : K → OpTree K` and `node : OpTree K → OpTree K → OpTree K`

2. `numLeaves : OpTree K → ℕ` — count leaves: `numLeaves (leaf _) = 1`, `numLeaves (node l r) = numLeaves l + numLeaves r`

3. `height : OpTree K → ℕ` — tree height: `height (leaf _) = 0`, `height (node l r) = max (height l) (height r) + 1`

4. `maxLeafDepth : OpTree K → ℕ` — maximum depth of any leaf: `maxLeafDepth (leaf _) = 0`, `maxLeafDepth (node l r) = max (maxLeafDepth l + 1) (maxLeafDepth r + 1)`

5. `leafDepths : OpTree K → List ℕ` — list of all leaf depths, where depth of a leaf in a subtree rooted at depth d is computed as: `leafDepths (leaf _) = [0]`, `leafDepths (node l r) = (leafDepths l).map (· + 1) ++ (leafDepths r).map (· + 1)`

## Theorems to Prove (with complete proof terms, NO sorry)

1. `theorem numLeaves_pos (t : OpTree K) : numLeaves t ≥ 1` — by induction on t, using `Nat.add_pos`

2. `theorem leafDepths_length (t : OpTree K) : (leafDepths t).length = numLeaves t` — by induction, using `List.length_map`, `List.length_append`

3. `theorem maxLeafDepth_le_height (t : OpTree K) : maxLeafDepth t ≤ height t` — by induction, using `Nat.add_le_add_left`, `Nat.max_le_max`

4. `theorem height_le_maxLeafDepth (t : OpTree K) : height t ≤ maxLeafDepth t` — by induction, symmetric argument

5. `theorem kraft_sum (t : OpTree K) : (leafDepths t).foldr (fun d acc => (1 : ℚ) / 2 ^ d + acc) 0 = 1` — the Kraft identity. Prove by induction on t. Base case: leaf has leafDepths = [0], foldr gives 1/2^0 = 1. Inductive step: for node l r, leafDepths (node l r) = (leafDepths l).map (·+1) ++ (leafDepths r).map (·+1). The foldr of the concatenation splits, and each mapped term contributes half of the corresponding subtree's kraft_sum (since 1/2^(d+1) = (1/2) * (1/2^d)). Use `List.foldr_append`, `List.foldr_map`, and the inductive hypotheses.

6. `theorem clog_numLeaves_le_height (t : OpTree K) : Nat.clog 2 (numLeaves t) ≤ height t + 1` — by induction using the super-additivity of Nat.clog: `Nat.clog 2 (m + n) ≤ max (Nat.clog 2 m) (Nat.clog 2 n) + 1`

## IMPORTANT CONSTRAINTS
- Do NOT mix prose commentary into the Lean code. All documentation goes in doc-comments (/- ... -/) only.
- Every theorem must have a COMPLETE proof — no truncated `induction t with` without a body.
- Use `sorry` ONLY if a lemma is genuinely stuck, and mark it with a TODO comment explaining what's needed.
- Import only `Mathlib` and standard Mathlib modules.
- Place the file at `Catalog/Bridges/OpTreeKraft.lean`.
- The namespace should be `OpTreeKraft`.