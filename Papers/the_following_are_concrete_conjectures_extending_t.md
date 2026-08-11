# Computational Evidence

Small finite models were computed before formalizing, to test the two statements whose truth was
least obvious a priori: the closed form of the limit clock's *key* function (Conjecture 4) and the
closed form of the transfinite stages of the ITTM-style transition system (Conjecture 5).

All computations below were run as `#eval`s in Lean 4 (Mathlib) on finite surrogates. They are
*exploratory* evidence, not proofs; the corresponding proofs are the theorems in
`Catalog/Logic/ImmortalityHierarchy.lean` and `Catalog/Logic/ImmortalityITTMClock.lean`, which are
machine-checked and sorry-free.

## 1. The key function of the limit clock

The proof of `limitGame_value = ω ^ ω` rests on the map

```
limitKey ⟨k, a⟩ = ω ^ k + typein a      (a a moment of the k-fold clock, so typein a < ω ^ k)
```

being strictly monotone for the lexicographic order on `Σₗ k : ℕ, (natClock k).Moment`, with all
values below `ω ^ ω`. Replacing `ω` by a finite base `b` gives a computable surrogate: pairs
`(k, a)` with `k < K` and `a < b ^ k`, key `b ^ k + a`, target bound `b ^ K`.

| check | `(b, K)` values tested | result |
|---|---|---|
| key strictly increasing along the lex enumeration | (2,6), (3,5), (4,4), (5,4), (10,3) | all `true` |
| all keys `< b ^ K` | (2,6), (3,5), (4,4), (5,4), (10,3) | all `true` |

Number of pairs for `K = 0,…`:

* base 2: `0, 1, 3, 7, 15, 31` — i.e. `2^K − 1` (OEIS A000225);
* base 3: `0, 1, 4, 13, 40` — i.e. `(3^K − 1)/2` (OEIS A003462).

Keys for `b = 3, K = 3`, in lex order: `1, 3, 4, 5, 9, 10, 11, 12, 13, 14, 15, 16, 17` — strictly
increasing, all `< 27`, exactly as the ordinal argument predicts (the gaps are the "unused" keys
below `b^k`, which correspond to the fact that the surrogate sum `Σ_{k<K} b^k` is smaller than
`b^K`; in the ordinal case the sum is absorbed and the bound becomes sharp).

## 2. Stages of the transition system

The machine of `ImmortalityITTMClock` switches a cell on once all strictly earlier cells are on,
and takes unions at limits. The formalized closed form is

```
x ∈ stage α  ↔  arrival x ≤ α .
```

On the finite lex clock `{0,…,N−1} × {0,…,N−1}` (order type `N·N`), iterating the step operator
from the empty configuration and comparing with the predicted set `{x | rank x ≤ n}`:

| `N` | stages compared | agreement |
|---|---|---|
| 3 | `n = 0,…,11` | `true` |
| 4 | `n = 0,…,9` | `true` |

Sample trace for `N = 3`:

```
stage 0 = [(0,0)]
stage 1 = [(0,0), (0,1)]
stage 2 = [(0,0), (0,1), (0,2)]
stage 3 = [(0,0), (0,1), (0,2), (1,0)]
```

The first `n` with `stage n = ` everything is `n = 8 = 3·3 − 1`, i.e. the closure time equals the
order type of the clock (minus one, since finite stages are indexed from `0`). This is the finite
shadow of the theorem `isLeast_terminal : IsLeast {α | Terminal α} (ω ^ 2)`.

## 3. Counterexample hunt

The naive strengthening "refinement always strictly increases survival value" was tested against
the fixed-point computation `ω · ω^ω = ω^(1+ω) = ω^ω`. It fails, and the failure is now a theorem:
`ImmortalityHierarchy.not_forall_lt_extBy_value`, witnessed by `limitGame` refined by
`finiteGame`. The exact boundary is `ImmortalityStructure.refinementStable_opow_iff`:
inside the scale `ω ^ a`, refinement is a no-op exactly when `ω ≤ a`.
