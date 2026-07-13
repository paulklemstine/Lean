# Computational Evidence — Factorial ↔ Mixed-Radix Bridge

The connector theorem identifies the **factorial number system** (factoradic)
with the **general mixed-radix positional system** at bases `b i = i + 1`.

## Small-case check of `value_eq`

Mixed-radix value with bases `b i = i+1` uses running products
`radixProd b i = ∏_{j<i}(j+1) = i!`, so it must equal the factoradic value
`∑_{i<k} c i · i!`.

| digits `c = (c0,c1,c2,c3)` | factoradic `∑ cᵢ·i!` | mixed-radix `∑ cᵢ·∏(j+1)` |
|---|---|---|
| (0,1,2,3) | 0·1+1·1+2·2+3·6 = 23 | same running products 1,1,2,6 → 23 |
| (0,0,1,1) | 0+0+2+6 = 8            | 8 |
| (0,1,1,0) | 0+1+2+0 = 3            | 3 |

The running products `1,1,2,6,24,…` are the factorials `i!` (OEIS A000142),
confirming `radixProd (·+1) = i!` term by term.

## Validity check of `valid_iff`

Mixed-radix validity is `c i < b i = i + 1`; factoradic validity is `c i ≤ i`.
These are literally equivalent by `Nat.lt_succ_iff` (`c i < i+1 ↔ c i ≤ i`),
so no counterexample can exist. Spot-check `i = 3`: allowed digits `{0,1,2,3}`
under both readings.

## Counterexample hunt

No counterexample is possible: `value_eq` and `valid_iff` are pointwise
identities/equivalences on ℕ, and `factorial_value_unique_via_mixed` is a
transport of the already-proved general uniqueness theorem
`MixedRadix.value_unique`. All three compile with only the standard axioms
`propext, Classical.choice, Quot.sound` (no `sorryAx`).

## Conclusion

The factorial number system is exactly the `b i = i+1` instance of the mixed-radix
family, and its uniqueness theorem is a genuine corollary of the general one —
a clean cross-domain bridge between combinatorial numeration (factoradics) and
general positional number systems.
