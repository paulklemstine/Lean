# Computational Evidence — The Reflective Tower

The reflective tower is defined by `L(0) = Bool` and `L(n+1) = L(n) → Bool`, so
each level is a finite type whose cardinality is that of the space of decidable
predicates over the previous level.

## 1. Small-case cardinalities

| level `n` | type            | cardinality `|L(n)|` |
|-----------|-----------------|----------------------|
| 0         | `Bool`          | 2                    |
| 1         | `Bool → Bool`   | 4                    |
| 2         | `L(1) → Bool`   | 16                   |
| 3         | `L(2) → Bool`   | 65536                |
| 4         | `L(3) → Bool`   | 2^65536              |

The recurrence `|L(n+1)| = 2^{|L(n)|}` is a strictly increasing (indeed
doubly-exponential) sequence, confirming `reflTower_card_strictMono` and hence the
cross-level separations `reflTower_no_surjection_of_lt`,
`reflTower_no_injection_of_lt`, and `reflTower_no_equiv_of_ne`.

This matches OEIS A014221 (`a(0)=1, a(n+1)=2^a(n)`) offset by the base value:
2, 4, 16, 65536, ... is `2^A014221`.

## 2. The truncation dichotomy, checked at the base

- **Self-reflection fails at every level.** For `n = 0`: the four maps
  `Bool → Bool` are `const false`, `const true`, `id`, `not`. The diagonal
  predicate `fun a => !(reflect a a)` is never in the image, because negation has
  no fixed point. This is `reflTower_no_self_reflection`.
- **Lower reflection succeeds.** For `m < n`, `|L(m) → Bool| = |L(m+1)| ≤ |L(n)|`,
  so a surjection `L(n) ↠ (L(m) → Bool)` exists. Concretely, `L(1) ↠ (L(0) → Bool)`
  is the identity (both have 4 elements); `L(2)` (16 elements) surjects onto
  `L(1) → Bool` (16 elements); and so on. This is `reflTower_lower_reflection`.

The transition occurs exactly at "reflect on your own level," giving the sharp
phase boundary the truncation conjecture predicts.

## 3. Fixed-point classification on the base

Enumerating the four self-maps of `Bool`, the only fixed-point-free one is `not`:

| `f`          | fixed points |
|--------------|--------------|
| `const false`| `{false}`    |
| `const true` | `{true}`     |
| `id`         | `{false,true}`|
| `not`        | `∅`          |

So "`f` is fixed-point free" characterizes `not` uniquely, matching
`boolSelfMap_fixedPointFree_iff_not`.

## Counterexample hunt

No counterexamples were found to any stated theorem: cross-level surjections,
injections, and equivalences are all obstructed by the strictly increasing
cardinality sequence, and the positive lower-reflection statement is witnessed by
an explicit construction at every gap `m < n`.
