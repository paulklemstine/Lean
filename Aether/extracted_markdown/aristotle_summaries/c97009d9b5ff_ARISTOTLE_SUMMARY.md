# Summary of changes for run 1724f149-c22a-4a56-b678-76d346837f1f
# Tropical Karchmer–Wigderson Games — Completed

## What was built

Created `Bridges/TropicalKarchmerWigderson.lean`: a self-contained formalization establishing a bridge from tropical/max-plus piecewise-affine classifiers to the Karchmer–Wigderson communication game framework. All 7 theorems are fully proved (zero sorries, standard axioms only).

## Theorem declarations and status

1. **`tropical_witness_exists`** (proved) — For any tropical threshold classifier, if x is classified true and y false, there exists an affine piece index separating them. The argmax piece for x automatically works because all pieces are ≤ threshold for y.

2. **`tropicalTree_to_protocol_valid`** (proved) — A sound tropical decision tree yields a valid KW protocol. The protocol correctly outputs separating witnesses for all input pairs.

3. **`tropicalTree_to_protocol_depth`** (proved) — The extracted protocol preserves the decision tree depth exactly, enabling direct transfer of depth lower bounds.

4. **`tropical_kw_leaf_bound`** (proved) — Any protocol of depth d has ≤ 2^d distinct leaf labels, providing the information-theoretic backbone for depth lower bounds.

5. **`TropKWProto.run_mem_leafLabels`** (proved) — Protocol output is always a leaf label.

6. **`TropKWProto.card_leafLabels_le`** (proved) — Structural leaf count bound via induction.

7. **`tropicallySeparated_implies_witness`** (proved) — The stronger geometric notion of tropical separation (piece achieves maximum + exceeds threshold) implies the algebraic KW witness condition.

## Key definitions

- `IntAffinePiece n` — integer affine function on ℤ^n
- `TropicalClassifier n m` — threshold classifier with m affine pieces
- `TropKWProto n m` — KW protocol tree with Alice/Bob nodes
- `TropDecTree n m` — tropical decision tree with branch tests on affine pieces
- `TropicalKWWitness` / `TropicallySeparated` — witness predicates

## Architecture

The bridge pipeline is: **tropical classifier → decision tree → KW protocol → depth lower bound**. This connects tropical geometry (piecewise-affine structure) to communication complexity (protocol depth).

## Files produced

- `Bridges/TropicalKarchmerWigderson.lean` — main formalization (266 lines, 7 proved theorems)
- `FUTURE_DIRECTIONS.md` — 5 research directions with falsifiable hypotheses

## Critique (strongest assumption)

The main limitation is that the pipeline only produces Alice-only protocols (since Alice can evaluate any affine piece on her input). This means the framework captures decision tree depth but not the full power of two-player communication. Direction 4 in FUTURE_DIRECTIONS.md addresses this with a concrete conjecture about two-player tropical classifiers where both players contribute tropical polynomials.