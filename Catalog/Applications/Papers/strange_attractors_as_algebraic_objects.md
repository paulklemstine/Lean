# Computational Evidence — Strange Attractors as Algebraic Objects

All evidence below was produced with `#eval` in Lean 4 (Mathlib) and is reflected
faithfully by the formal theorems in this directory.

## 1. The doubling tower `ℤ/2ⁿℤ` (the finite directed graphs)

Cardinality of the cyclic graph at stage `n` (`Fintype.card (ZMod (2^n))`):

| n      | 0 | 1 | 2 | 3 | 4 | 5 |
|--------|---|---|---|---|---|---|
| #ℤ/2ⁿ  | 1 | 2 | 4 | 8 | 16| 32|

The stages are finite at every level but their sizes are unbounded — the inverse
limit (`dyadicTower`) is therefore infinite (`dyadicTower_infinite`).

## 2. Compatible threads from integers (`intThread`)

Residues of the integer `13` mod `2ⁿ`:

```
#eval (List.range 6).map (fun n => (13 : ZMod (2^n)).val)
-- [0, 1, 1, 5, 13, 13]
```

Each entry is the previous one reduced mod `2ⁿ` (e.g. `13 mod 8 = 5`, `5 mod 4 = 1`),
i.e. the sequence is a genuine compatible thread of the inverse system. Distinct
integers give distinct threads (`intThread_injective`), giving the dense embedding
`ℤ ↪ ℤ₂`.

## 3. Unbounded denominators ⇒ `ℤ[1/2]` is not finitely generated

Denominators of `1/2ⁿ` (`((1:ℚ)/2^n).den`):

```
#eval (List.range 8).map (fun n => ((1 : ℚ) / 2^n).den)
-- [1, 2, 4, 8, 16, 32, 64, 128]
```

Any finite generating set has a maximal denominator-exponent `N`; every element it
generates lives in `boundedDen N` (denominator dividing `2ᴺ`). But `1/2^{N+1}` has
denominator `2^{N+1} ∤ 2ᴺ`, so it escapes — the **counterexample to finite
generation**, formalized as `Dyadic.not_fg`.

## 4. Doubling is invertible on `ℤ[1/2]`

```
#eval ((1:ℚ)/2^3 / 2).den   -- 16   (q/2 is still dyadic)
```

Division by two never leaves the dyadics: `Dyadic.two_divisible`. This is the
localization/colimit signature that the cohomology of any *finite* graph lacks.

## 5. Finite-nerve cohomology ranks (catalog cross-check)

From `Catalog/Physics/CechContextualityCore.lean`: the Peres–Mermin nerve has
`cohomRank = 4` and the Mermin–GHZ nerve has `cohomRank = 3` — finite ranks, so
their `H¹ ≅ ℤ^{β₁}` is finitely generated. No such finite-rank free group is
isomorphic to `ℤ[1/2]` (`solenoid_not_finite_nerve_cohomology`).

## OEIS

The denominator sequence `1, 2, 4, 8, 16, 32, …` is the powers of two, OEIS
[A000079](https://oeis.org/A000079). Its unboundedness is the arithmetic heart of
the non-finite-generation result.
