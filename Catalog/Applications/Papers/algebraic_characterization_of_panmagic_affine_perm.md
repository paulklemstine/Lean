# Computational Evidence: Panmagic Affine Permutations over `ZMod n`

Object of study: affine maps `σ_{a,b}(x) = a·x + b` on `ZMod n` with `a` a unit.

* `σ` is **panmagic** iff `x ↦ σ(x)`, `x ↦ σ(x) − x`, and `x ↦ σ(x) + x` are all
  permutations of `ZMod n`. Algebraically (proved in `Catalog/Algebra/PanmagicAffine.lean`):
  panmagic ⇔ `a`, `a−1`, `a+1` are all units.

All claims below are *proved* in the Lean file (`decide` for the small modular facts,
explicit witnesses + ring-hom reductions for existence); the table is the small-case
evidence that motivated the formalization.

## 1. Small-case calculation: does a panmagic affine permutation of `ZMod n` exist?

For each `n`, we ask whether some unit `a` has `a, a−1, a+1` all units (take `b = 0`).

| n  | gcd(n,6) | panmagic affine perm exists? | smallest working `a` |
|----|----------|------------------------------|----------------------|
| 1  | 1        | yes (trivial ring)           | 0                    |
| 2  | 2        | no                           | —                    |
| 3  | 3        | no                           | —                    |
| 4  | 2        | no                           | —                    |
| 5  | 1        | yes                          | a = 2 (1,2,3 units)  |
| 6  | 6        | no                           | —                    |
| 7  | 1        | yes                          | a = 2                |
| 8  | 2        | no                           | —                    |
| 9  | 3        | no                           | —                    |
| 10 | 2        | no                           | —                    |
| 11 | 1        | yes                          | a = 2                |
| 25 | 1        | yes                          | a = 2                |
| 35 | 1        | yes                          | a = 2                |
| 49 | 1        | yes                          | a = 2                |

**Pattern:** "exists" exactly matches `gcd(n,6) = 1`. The witness `a = 2` always works
when it exists (then `a−1 = 1` is automatically a unit, `a = 2` and `a+1 = 3` are units
because `n` is coprime to 6). This is the content of `exists_panmagic_iff_coprime_six`.

## 2. Companion thresholds (one diagonal only)

* **Orthomorphism** (`σ` and `σ(x)−x` permutations): needs `a, a−1` units. Exists iff
  `n` is **odd** (`gcd(n,2)=1`); witness `a = 2`, `b = 0`.
* **Complete mapping** (`σ` and `σ(x)+x` permutations): needs `a, a+1` units. Exists iff
  `n` is **odd**; witness `a = 1`, `b = 0`.

| n  | odd? | affine orthomorphism? | affine complete mapping? |
|----|------|-----------------------|--------------------------|
| 2  | no   | no                    | no                       |
| 3  | yes  | yes (a=2)             | yes (a=1)                |
| 4  | no   | no                    | no                       |
| 5  | yes  | yes                   | yes                      |
| 9  | yes  | yes                   | yes                      |
| 15 | yes  | yes                   | yes                      |

This matches the classical Hall–Paige criterion for cyclic groups: `Z_n` admits a
complete mapping iff `n` is odd. Proved as `exists_orthomorphism_iff_coprime_two`
and `exists_completeMapping_iff_coprime_two`.

## 3. Counterexample hunt

The universal claim tested was: "for every `n`, panmagic affine permutation exists ⇔
`gcd(n,6)=1`." No counterexample found in `n ≤ 200` (checked via the algebraic
characterization); the equivalence is then proved for *all* `n` in Lean, so the
exhaustive check is subsumed.

## 4. OEIS note

The indicator of "panmagic affine permutation exists" is the characteristic function of
{ n : gcd(n,6)=1 } = {1,5,7,11,13,17,19,23,25,...}, i.e. numbers coprime to 6 (A007310,
the 6k±1 numbers, after 1). No new sequence is introduced; the evidence simply confirms
the closed-form threshold.
