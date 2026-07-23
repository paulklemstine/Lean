# Computational Evidence — Mutually Orthogonal Latin Squares and the Euler–MacNeish Bound

This note records the small-case exploration carried out before formalizing the
`n − 1` ceiling on families of mutually orthogonal Latin squares (MOLS).

## 1. The claim under test

For order `n ≥ 2`, a family of pairwise-orthogonal **reduced** Latin squares
(first row equal to the identity `0, 1, …, n−1`) has at most `n − 1` members.
Equivalently, the number `N(n)` of MOLS of order `n` satisfies `N(n) ≤ n − 1`.

## 2. Small-case values of the maximum MOLS count

| `n` | `n − 1` (upper bound) | `N(n)` (known maximum) | attains bound? |
|-----|-----------------------|------------------------|----------------|
| 2   | 1                     | 1                      | yes            |
| 3   | 2                     | 2                      | yes            |
| 4   | 3                     | 3                      | yes            |
| 5   | 4                     | 4                      | yes            |
| 6   | 5                     | 1                      | no (Euler)     |
| 7   | 6                     | 6                      | yes            |
| 8   | 7                     | 7                      | yes            |
| 9   | 8                     | 8                      | yes            |
| 10  | 9                     | ≥ 2                    | open/no        |

The bound `n − 1` is met with equality whenever `n` is a prime power, and fails
to be met at `n = 6` (Euler's famous "36 officers" impossibility) and `n = 10`.
Crucially, the *upper bound* itself holds for **every** `n` — that universal
inequality is what is proved here. The sequence of maxima `N(n)` is
[OEIS A001438](https://oeis.org/A001438) (with the convention that the largest
complete-set orders are the prime powers).

## 3. The order-three witness (formalized)

The two reduced squares over the symbols `{0,1,2}`:

```
L0(i,j) = i + j (mod 3)      L1(i,j) = 2i + j (mod 3)
    0 1 2                         0 1 2
    1 2 0                         2 0 1
    2 0 1                         1 2 0
```

Their superposition `(L0, L1)` visits all nine ordered pairs exactly once:

```
(0,0) (1,1) (2,2)
(1,2) (2,0) (0,1)
(2,1) (0,2) (1,0)
```

so the pair is orthogonal, both are reduced, and the family has size
`2 = n − 1`. This is the certificate `order_three_two_mols`, discharged by finite
evaluation, showing the bound is tight and the hypotheses are satisfiable.

## 4. The pivot invariant (the seed of the proof)

For a reduced square, the entry in cell `(1, 0)` — the "pivot" — is never `0`
(because `0` already occupies cell `(0,0)` in that column). Tabulating pivots
across an orthogonal family shows they are always **distinct and nonzero**:

- `L0` pivot: `L0(1,0) = 1`
- `L1` pivot: `L1(1,0) = 2`

Two nonzero, distinct symbols out of `{1, 2}`, i.e. `n − 1 = 2` slots — exactly
saturated. A quick check over all reduced order-4 and order-5 orthogonal pairs
confirms the pivots never collide and never equal `0`, which is precisely the
mechanism the formal proof isolates and turns into a cardinality embedding.

## 5. Counterexample hunt

We searched for a *reduced* orthogonal family violating `k ≤ n − 1` at small
orders by attempting to add an `n`-th square with a pivot forced to repeat or to
equal `0`; every attempt fails at the pivot step, matching the theorem. No
counterexample exists, consistent with the proved universal bound.
