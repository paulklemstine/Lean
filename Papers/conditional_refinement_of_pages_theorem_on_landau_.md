# Computational Evidence: Repulsion Threshold for Exceptional Characters

We test the quantitative heart of the formalized result — that the compatibility
condition `C > 2·Q₀^{-ε}·log M` is the correct barrier separating "uniqueness" from
"possible coexistence" of exceptional characters.

## 1. Small-case threshold values

The threshold `T(ε, Q₀, M) = 2·Q₀^{-ε}·log M` (uniqueness holds when `C > T`):

| ε   | Q₀  | M    | Q₀^{-ε}   | log M   | T = 2·Q₀^{-ε}·log M |
|-----|-----|------|-----------|---------|---------------------|
| 1.0 | 2   | 2    | 0.5000    | 0.6931  | 0.6931              |
| 1.0 | 10  | 10   | 0.1000    | 2.3026  | 0.4605              |
| 1.0 | 100 | 100  | 0.0100    | 4.6052  | 0.0921              |
| 0.5 | 100 | 100  | 0.1000    | 4.6052  | 0.9210              |
| 1.0 | 10  | 1000 | 0.1000    | 6.9078  | 1.3816              |
| 2.0 | 100 | 100  | 0.0001    | 4.6052  | 0.0009              |

Observations consistent with the theorem:
- With a fixed narrow window (`M = Q₀`), `T → 0` as `Q₀ → ∞`, so any fixed repulsion
  constant `C > 0` eventually guarantees uniqueness — the "large conductor" regime.
- Widening the window (`M ≫ Q₀`) raises `T`, demanding stronger repulsion, exactly the
  obstruction to a global (all-conductor) statement.
- Larger `ε` (a wider exceptional neighbourhood `[1 − q^{-ε}, 1)`) shrinks `T`
  dramatically, since `Q₀^{-ε}` decays fast.

## 2. Coexistence test below the threshold

Take `ε = 1`, `Q₀ = 2`, `M = 3`, and a deliberately weak repulsion `C = 0.1`
(so `C < T = 2·(1/2)·log 3 ≈ 1.0986`). Construct
`χ₁ = (2, 0.5)` and `χ₂ = (3, 0.6667)`:
- `χ₁` is exceptional: `0.5 ≥ 1 − 2^{-1} = 0.5`. ✓
- `χ₂` is exceptional: `0.6667 ≥ 1 − 3^{-1} ≈ 0.6667`. ✓
- Repulsion is *satisfiable*: `min(0.5, 0.6667) = 0.5 ≤ 1 − 0.1/log 6 ≈ 0.9442`. ✓

So two distinct exceptional characters coexist under weak repulsion — confirming the
threshold is load-bearing and the conclusion fails without it.

## 3. Contradiction above the threshold (sanity of the proof)

Take `ε = 1`, `Q₀ = 2`, `M = 2`, `C = 1.0` (so `C > T ≈ 0.6931`). Any two exceptional
characters must have conductor `= 2`, real zero `≥ 0.5`, so
`min ≥ 0.5 = 1 − Q₀^{-ε}`; repulsion would force `min ≤ 1 − C/log 4 ≈ 0.2787`, a
contradiction unless the two characters coincide. This is precisely the chain the
formal proof follows.

## 4. Sequence note

No integer sequence arises directly; the object is a real-analytic threshold surface
`T(ε, Q₀, M)`. An OEIS search is therefore not applicable. The evidence above is the
relevant numerical validation.

## Conclusion

The numerics confirm (a) the threshold direction, (b) that it is sharp enough to be
load-bearing (coexistence below, contradiction above), and (c) the asymptotic
behaviour matching the "at most one exceptional character of large conductor"
heuristic. These directly support the formalized theorems `at_most_one_exceptional`
and `card_le_one_of_repulsion`.
