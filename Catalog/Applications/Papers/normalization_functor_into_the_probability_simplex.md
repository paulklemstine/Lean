# Computational Evidence — Normalization Functor into the Probability Simplex

The results in `NormalizationSimplexFunctor.lean` are universally-quantified algebraic
identities over finite index types, proved directly (no asymptotics or search). Evidence
here is therefore confirmatory rather than exploratory and is kept brief.

## Small-case sanity checks

- `normalize` on `ι = Fin 3`, `v = (1,1,2)`: total mass `4`, so
  `normalize v = (1/4, 1/4, 1/2)`, sum `= 1`. ✔ (`normalize_mem_stdSimplex`)
- Degenerate mass: `v = (0,0,0)` gives `normalize v = (0,0,0)` since `x/0 = 0` in Lean;
  both sides of `normalize_idem` and `normalize_pushforward` collapse to `0`. ✔
- Scale invariance: `v = (1,1,2)` vs `5•v = (5,5,10)` both normalize to `(1/4,1/4,1/2)`. ✔
  (`normalize_smul`)
- Pushforward / marginalization: `f : Fin 3 → Fin 2`, `f = (0,0,1)`, `v = (1,1,2)`:
  `pushforward f v = (2, 2)`, total mass `4 = ∑ v`. ✔ (`pushforward_mass`)
- Naturality: `pushforward f (normalize v) = (1/2, 1/2) = normalize (pushforward f v)`. ✔
  (`normalize_pushforward`)
- Functor laws: `pushforward id v = v`; with `g : Fin 2 → Fin 1`,
  `pushforward (g∘f) v = (4) = pushforward g (pushforward f v)`. ✔
  (`pushforward_id`, `pushforward_comp`)

## OEIS / counterexample hunt

No integer sequence arises (the objects are real probability vectors). A counterexample
hunt for naturality and idempotence over random small nonnegative integer vectors found
none, consistent with the unconditional Lean proofs. Membership genuinely requires
`0 < ∑ v` (the zero vector is the lone exception), matching the hypothesis used.
