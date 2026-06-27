# Computational Evidence — Transition Endomorphisms

Object under study: for a sequence of endomorphisms `f : ℕ → (V →ₗ[K] V)`,
the *transition endomorphism* `transEndo f i n = f(i+n-1) ∘ ⋯ ∘ f(i)`
(window of length `n` starting at index `i`), with `transEndo f i 0 = id`.

## Small-case sanity checks (composition law)

For a fixed sequence `f`, the window operator satisfies, by direct unfolding:

- `transEndo f i 0 = id`
- `transEndo f i 1 = f i`
- `transEndo f i 2 = f(i+1) ∘ f i`
- `transEndo f i 3 = f(i+2) ∘ f(i+1) ∘ f i`

Splitting a window of length `m+n` after its first `n` factors:

  `transEndo f i (m+n)` = `[f(i+m+n-1)∘…∘f(i+n)] ∘ [f(i+n-1)∘…∘f(i)]`
                        = `transEndo f (i+n) m  ∘  transEndo f i n`.

This is the cocycle identity, confirmed for all the small cases above and
proved in general by induction on `m` (`transEndo_add`).

## Rank experiment

Take `K = ℚ`, `V = ℚ²`, and the constant sequence `f k = P` where `P` is the
rank-1 projection `(x,y) ↦ (x,0)`. Then:

| n | transEndo f 0 n | rank |
|---|-----------------|------|
| 0 | id              | 2    |
| 1 | P               | 1    |
| 2 | P∘P = P         | 1    |
| 3 | P               | 1    |

The rank sequence `2,1,1,1,…` is (weakly) decreasing, never increasing — matching
the predicted antitonicity (`finrank_range_transEndo_antitone`). With a nilpotent
shift `N(x,y)=(y,0)` the sequence is `2,1,0,0,…`, again antitone and eventually
absorbing. No counterexample to monotone-decrease was found across the projection,
nilpotent, identity, and invertible (rotation) sequences tested.

## Counterexample hunt

Searched for any sequence making the rank strictly increase from one window length
to the next: impossible, since `transEndo f i (n+1) = f(i+n) ∘ transEndo f i n` is
a composite and `range(g∘h) = g '' range h` cannot exceed `dim (range h)`
(`Submodule.finrank_map_le`). This is exactly why no new Sylvester-type inequality
is needed: the existing image-dimension bound already forces antitonicity.

## Conclusion

The computational landscape is consistent: the cocycle law holds in every finite
case and the rank sequence is antitone. We then proceed to the formal proofs.
