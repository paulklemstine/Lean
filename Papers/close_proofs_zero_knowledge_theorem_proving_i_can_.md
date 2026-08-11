# Computational Evidence — Affine Σ-Protocols and Zero-Knowledge Provability

All numbers below were produced with `#eval` inside this Lean project (Lean 4.28.0 /
Mathlib), on the concrete instance `G = H = ZMod n`, public homomorphism `x ↦ a * x`,
public target `t`, i.e. the statement "`a * w = t` is solvable".

## 1. Witness count = kernel count

Witness counts of `4 * w = b` in `ZMod 12`, for `b = 0, …, 12`:

```
[(0,4), (1,0), (2,0), (3,0), (4,4), (5,0), (6,0), (7,0), (8,4), (9,0), (10,0), (11,0), (12,4)]
```

The count is either `0` (false statement) or exactly `4`, and `4 = |ker(x ↦ 4x)|`
in `ZMod 12`. Kernel sizes across further instances:

| `(n, a)` | `|ker|` | `gcd(a, n)` |
|---|---|---|
| (12, 4) | 4 | 4 |
| (12, 3) | 3 | 3 |
| (15, 5) | 5 | 5 |
| (16, 8) | 8 | 8 |
| (17, 4) | 1 | 1 |
| (100, 10) | 10 | 10 |

This is exactly the content of the formal theorem
`card_witnesses_eq_card_ker` (witness set is a coset of the kernel), and the
row `(17, 4)` — a unique witness — is the situation covered by
`unique_witness_still_perfect_zk`.

## 2. View size is independent of truth of the statement

Number of accepting transcripts `(commitment, response)` for each challenge bit,
in `ZMod 12` with `a = 4`:

| statement | challenge `false` | challenge `true` |
|---|---|---|
| `4w = 8` (true) | 12 | 12 |
| `4w = 1` (false) | 12 | 12 |

Always `12 = |G|`, independently of the challenge and of whether the statement
is true. Formalised as `accepting_ncard_eq_card_group` and
`accepting_ncard_challenge_independent`, and instantiated in
`example_view_size` / `example_view_size_false`.

## 3. Counterexample hunt for the extraction event

Number of commitments `A` at which *both* challenges admit an accepting
response (this is the event on which the extractor fires):

| statement | commitments admitting both answers |
|---|---|
| `4w = 8` (true)  | 3 (namely the image `{0, 4, 8}`) |
| `4w = 4` (true)  | 3 |
| `4w = 1` (false) | 0 |

No counterexample to soundness was found: for the unsolvable statement the
double-answer event is empty, exactly as proved in
`unprovable_no_double_answer`. For solvable statements the event is nonempty,
so the extraction theorem `special_soundness` is not vacuous.

## 4. Soundness error under parallel repetition

Predicted bound `(1/2)^n` on the fraction of challenge vectors a committed
prover can answer when no witness exists:

```
n : 0    1     2     3     4      5      6      7       8       9       10
    1   1/2   1/4   1/8   1/16   1/32   1/64   1/128   1/256   1/512   1/1024
```

Since the rigidity lemma `parallel_unique_of_no_witness` shows the accepting
challenge set has at most one element out of `2^n`, this bound is attained (not
merely an estimate) whenever the prover can answer one vector at all. The
`n = 10` instance is formalised as `falseStatement_soundness_10` (`≤ 1/1024`).

## 5. OR-composition: which-witness hiding

Brute force over `G = H = ZMod 6`, `f = (2 · ·)`, left statement `2w = 4`
(witness `2`), right statement `2w = 2` (witness `1`), randomness
`(r, z, d) ∈ ZMod 6 × ZMod 6 × Bool`:

| challenge `c` | left-witness transcripts | right-witness transcripts | multisets equal? | duplicates |
|---|---|---|---|---|
| `false` | 72 | 72 | yes | none (72 distinct) |
| `true`  | 72 | 72 | yes | none (72 distinct) |

The two strategies are exact reparametrisations of each other, matching the
formal theorem `or_witness_side_hiding` and the explicit bijection `orSwitch`.

## 6. Larger challenge spaces

For the linear protocol over `ZMod q` the bound is `(1/q)^n` per
`lin_soundness_error_le`:

| `q` \ `n` | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| 2 | 1/2 | 1/4 | 1/8 | 1/16 |
| 5 | 1/5 | 1/25 | 1/125 | 1/625 |

The `q = 5`, `n = 4` entry `1/625` is formalised as `zeroStatement_soundness_4`
for the unsolvable statement `0 · w = 1` over `ZMod 5`.

## 7. OEIS

The only sequences appearing are `2^n` (A000079) and `gcd(a, n)` patterns; no
new sequence arises, so no OEIS submission is warranted.
