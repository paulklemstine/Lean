# Computational Evidence — Seidel higher spectral moments under edge flips

## Setup
The Seidel matrix `S` of a graph has `0` on the diagonal, `-1` on adjacent pairs,
`+1` on non-adjacent distinct pairs. Deleting one edge `{a,b}` flips the two
symmetric entries `S a b, S b a` from `-1` to `+1`, i.e.
`S' = S + 2·(E_{ab}+E_{ba})`.

The established foundations show the second moment is **blind** to this:
`tr(S²) = n(n-1)` for every graph on `n` vertices. The question here is whether a
*higher* moment can see the flip.

## Predicted formula
For any real symmetric zero-diagonal `M`, `a ≠ b`, and `P = c·(E_{ab}+E_{ba})`:

    tr((M+P)³) − tr(M³) = 6·c·(M²)_{a b}.

(The `tr(P³)` and `tr(M P²)` contributions vanish because `M` has zero diagonal.)
For an edge deletion `c = 2`, so the change is `12·(S²)_{a b}`.

## Small-case check: K₃ vs K₃ − e (= path P₃)
- `S(K₃) = [[0,-1,-1],[-1,0,-1],[-1,-1,0]]`, `tr(S³) = -6`.
- `S(P₃) = [[0,-1,-1],[-1,0,1],[-1,1,0]]` (edge {1,2} deleted), `tr(S³) = +6`.
- `tr(S²)` is the **same** for both (`= 6 = n(n-1)`).
- `(S(K₃)²)_{1,2} = 1`, so the formula predicts change `= 12·1 = 12`, and
  indeed `6 − (−6) = 12`. ✓

All four facts were verified in Lean via `simp`/`norm_num` on explicit `Fin 3`
matrices, and are re-proved in `SeidelHigherMoments.lean`.

## Conclusion
The third spectral moment is generically **not** invariant under edge deletion,
in sharp contrast to the second moment. This provides an exact, elementary
"moment-level" version of the rank-two edge-flip perturbation formula
(Conjecture 3): the sign and size of the third-moment change are controlled by
the single graph-theoretic quantity `(S²)_{a b}`.

## Bonus: complement invariance
Complementing a graph negates the Seidel matrix (`S(Ḡ) = −S(G)`), hence preserves
the Seidel energy. This is verified for the definitions in the file and shows
Seidel energy cannot be a monotone function of the edge count.
