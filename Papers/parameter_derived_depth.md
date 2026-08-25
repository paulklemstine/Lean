# Computational Evidence — Parameter-derived depth

Status of this document: **exploratory**. Everything reported here was computed with a
throwaway script *before* formalisation, to select and sanity-check the conjectures. The
statements that are actually certified are the Lean theorems in
`Catalog/Physics/ParameterDepth/`, which are proved for *all* parameters, not just the
sampled ones.

## 1. The object

For a branching number `B ≥ 2` and threshold `T ≥ 1`:

```
foamCells B d = 1 + B + B² + ⋯ + B^d          (cells of a depth-d B-ary cascade)
supported d  ⟺ foamCells B d ≤ T
foamDepth B T = the largest supported d
```

## 2. Closed form: exhaustive check

Conjecture tested: `foamDepth B T = Nat.log B ((B-1)·T + 1) - 1`.

Range checked: `B ∈ [2, 11]`, `T ∈ [1, 3000]` (30 000 pairs) — **0 mismatches**.
Formalised and proved for all `B ≥ 2`, `T ≥ 1` in `TreeDepth.foamDepth_isGreatest`
together with `TreeDepth.foamCells_le_iff_le_foamDepth`.

Sample values (all reproduced as Lean theorems):

| B  | T       | foamCells B d (d = answer) | foamCells B (d+1) | foamDepth |
|----|---------|----------------------------|-------------------|-----------|
| 2  | 1000    | 511                        | 1023              | 8         |
| 3  | 100     | 40                         | 121               | 3         |
| 10 | 1000000 | 111111                     | 1111111           | 5         |

## 3. Deficit against the leaf-only model

Conjecture tested: `Nat.log B T - 1 ≤ foamDepth B T ≤ Nat.log B T`.
Range `B ∈ [2, 11]`, `T ∈ [1, 3000]` — **0 violations** (`TreeDepth.foamDepth_deficit`).

Counting the *lossy* budgets (deficit `= 1`) inside a scale block
`B^L ≤ T < B^(L+1)` gave, e.g. for `B = 2`: `1, 3, 7, 15, 31, …` at `L = 1,2,3,4,5`,
i.e. `2^L - 1` out of a block of size `2^L` — which is `foamCells 2 (L-1)`. The same
pattern (`count = foamCells B (L-1)`) held for `B = 3, 4, 5`. This is the observation
that became the self-similarity theorem `Deficit.lossy_card` and the density limit
`Deficit.lossy_density_tendsto` (limit `1/(B-1)²`; for `B = 2` the density tends to `1`).
The counts `2^L − 1` are the Mersenne numbers (OEIS A000225); the general block count
`(B^L − 1)/(B − 1)` is the base-`B` repunit family (OEIS A002275 for `B = 10`).

## 4. Composition (tensoring two budgets)

Conjecture tested: `d(T₁) + d(T₂) ≤ d(T₁·T₂) ≤ d(T₁) + d(T₂) + 2`.

* Superadditivity: `B ∈ [2,7]`, `T₁,T₂ ∈ [1,119]` — **0 counterexamples**.
* Excess `d(T₁T₂) − d(T₁) − d(T₂)`: maximum observed value `2`, attained e.g. at
  `B = 2, T₁ = 5, T₂ = 13` (`1 + 2 + 2 = 5`). This pinned the constant `+2` as sharp and
  produced the Lean witness `Composition.foamDepth_tensor_gap_attained`; the lower end is
  witnessed by `Composition.foamDepth_tensor_additive_example`.

## 5. Counterexample hunt

Two natural strengthenings were *refuted* numerically before any proof effort:

* `d(T₁·T₂) = d(T₁) + d(T₂)` — false (`B = 2, T₁ = 5, T₂ = 13` gives `5 ≠ 3`).
* `foamDepth B T = Nat.log B T` — false (`B = 2, T = 1000` gives `8 ≠ 9`); the exact
  criterion for equality is `Deficit`/`TreeDepth.foamDepth_eq_log_iff`.

Both refutations are reflected in the final statements: the theorems are stated with the
sharp constants rather than the tempting clean equalities.
