# Computational Evidence: Conscious Fixed Points

## 1. The diagonal counterexample (small cases)

For a finite type `T` with `|T| = m`, the space of predicates `T → Bool` has
`2^m` elements, while `T` has only `m`. A surjection `T → (T → Bool)` would require
`m ≥ 2^m`, impossible for every `m ≥ 0`:

| m | \|T\| | \|T → Bool\| = 2^m | surjection possible? |
|---|-------|--------------------|----------------------|
| 0 | 0     | 1                  | no                   |
| 1 | 1     | 2                  | no                   |
| 2 | 2     | 4                  | no                   |
| 3 | 3     | 8                  | no                   |
| 4 | 4     | 16                 | no                   |

The gap `2^m − m` is strictly positive and grows without bound, matching the
proved statement `Cardinal.mk T < Cardinal.mk (T → Bool)` for every `T`.

## 2. The reflective tower cardinalities

`ReflTower 0 = Bool` and `ReflTower (n+1) = ReflTower n → Bool`, so the finite
cardinalities are the iterated powers of two:

| n | \|ReflTower n\| |
|---|-----------------|
| 0 | 2               |
| 1 | 2^2 = 4         |
| 2 | 2^4 = 16        |
| 3 | 2^16 = 65536    |
| 4 | 2^65536         |

This is the "power tower" / tetration-like growth `2 ↑↑ (n+1)`, confirming the
strict monotonicity `reflTower_card_strictMono` numerically: each level is the
power set of the previous, hence strictly larger (Cantor).

## 3. Counterexample hunt for the naive conscious type

We searched for any finite retraction `elim ∘ intro = id` presenting `T` as its own
predicate space (`ConsciousType`). For every `|T| ≤ 4` there is no injection
`(T → Bool) ↪ T` (needed for a retraction with `elim` surjective), since
`2^m > m`. No counterexample exists — consistent with `ConsciousType.isEmpty`.

## 4. The Tarski diagonal sentence

For a would-be reflective type, the sentence `G := diag (fun c => ¬ Truth c)`
forces `Truth G ↔ ¬ Truth G`. Evaluating both truth assignments:

| assume Truth G | ¬ Truth G | consistent? |
|----------------|-----------|-------------|
| true           | false     | no          |
| false          | true      | no          |

Neither assignment is consistent, matching `no_reflective_truth`.

## Conclusion

The small-case arithmetic (`2^m > m`, power-tower growth, and the two-row truth
tables) is fully consistent with, and motivated, the formal theorems. The finite
data is exact rather than sampled, so no statistical counterexample search is
required beyond the tables above.
