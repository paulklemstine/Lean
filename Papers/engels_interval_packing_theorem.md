# Computational Evidence — Engel's Interval Packing

All experiments below were run in Python (brute-force enumeration over the Boolean
lattice `2^[n]`). The goal was to (a) fix the correct formalization, (b) confirm the
`l = 1` threshold, and (c) hunt for a general construction.

## 0. Definitions used

For an `l`-set `T` the assignment gives an `r`-set `C_T` with `C_T ∩ T = ∅`; write
`B_T = T ∪ C_T` (size `l + r`). Two intervals `[T₁,B₁]`, `[T₂,B₂]` **meet** iff there
is a set `S` with `Tᵢ ⊆ S ⊆ Bᵢ`; taking `S = T₁ ∪ T₂` shows

```
[T₁,B₁] ∩ [T₂,B₂] ≠ ∅   ⟺   (T₁ ⊆ B₂  ∧  T₂ ⊆ B₁).
```

So a **packing** (pairwise-disjoint intervals) requires, for distinct `T₁,T₂`,
`¬(T₁ ⊆ B₂ ∧ T₂ ⊆ B₁)`. This is exactly `IsMaxIntervalPacking`.

## 1. The literal reading is unsatisfiable (contrarian check)

The informal description asks for `T₁ ⊄ B₂` **and** `T₂ ⊄ B₁` for *all* distinct
pairs. But `B₂` has size `l + r > l`, so it contains `C(l+r, l) ≥ 2` distinct
`l`-subsets — all of which are legitimate `l`-sets `T₁ ≠ T₂` with `T₁ ⊆ B₂`. Hence the
literal "and-of-negations" reading is structurally impossible for every `l, r ≥ 1`.
This is proved in Lean as `naive_packing_impossible`, and it is why we formalize the
disjointness reading `¬(T₁ ⊆ B₂ ∧ T₂ ⊆ B₁)`.

## 2. The `l = 1` cyclic construction: threshold is exactly `2r+1`

Construction on `ℤ_n`: `C_{t} = {t+1, t+2, …, t+r} (mod n)`.
Testing `disjoint = (packing valid)` against the bound `n ≥ 2r+1 = (l+1)r+l|_{l=1}`:

| r | works exactly when | matches `n ≥ 2r+1` |
|---|--------------------|--------------------|
| 0 | all n              | yes (trivially)    |
| 1 | n ≥ 3              | yes                |
| 2 | n ≥ 5              | yes                |
| 3 | n ≥ 7              | yes                |

The cyclic construction succeeds **iff** `n ≥ 2r+1`, matching the Engel threshold at
`l = 1`. The failure mechanism below threshold is a *digon*: `t₂ ∈ C_{t₁}` and
`t₁ ∈ C_{t₂}` simultaneously, which forces `n ∣ (j+k)` with `2 ≤ j+k ≤ 2r`. This is
formalized as `cycC_no_digon` and assembled into `engel_l_one`.

For `n = 2, l = 1, r = 1` (below threshold) the two singletons force `C_{0}={1}`,
`C_{1}={0}`, and the intervals share the top `{0,1}` — a genuine non-existence
(`no_maxpacking_two_one_one`).

## 3. Counterexample hunt for a *general* construction

Several natural global constructions were tested against `n ≥ (l+1)r + l` for
`l ∈ {1,2,3}`, `r ∈ {1,2}`:

| construction                              | l=1 | l=2 | l=3 |
|-------------------------------------------|-----|-----|-----|
| cyclic "next r after the element"         | ✓   | —   | —   |
| append r elements after `max(T)` (cyclic) | ✓   | partial (fails at some n≥thr) | ✗ |
| r smallest complement elements            | ✗   | ✗   | ✗   |
| "big-gap" placement                       | ✓   | fails at `l=2,r=2,n=8` | ✗ |
| sum-anchored `C_T` (mult·ΣT+off mod n)    | ✗   | ✗   | ✗   |

**Finding.** No simple global/greedy formula we tried achieves the packing for
`l ≥ 2` right at the threshold. A purely order-theoretic "potential" argument
(assign an injective `h` to `l`-sets and make each `T` the `h`-extremal `l`-subset of
`B_T`) is *provably impossible*: the globally-extremal `l`-set would need `r` further
elements strictly beyond it, which do not exist. Engel's genuine construction is more
subtle; formalizing it for general `l` is left as future work (see
`FUTURE_DIRECTIONS.md`). The `l = 1` and `r = 0` cases are proved in full.
