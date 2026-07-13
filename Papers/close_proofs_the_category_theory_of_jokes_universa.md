# Computational Evidence: The Algebra of Surprise

We model a joke's *setup* as a finite nonempty set of resolutions `S ⊆ ℝ`, and its
*surprise* (humor) as the range `humor S = max S − min S`.

## 1. Small-case calculations (union / subadditivity)

| S          | T          | humor S | humor T | S ∪ T        | humor(S∪T) | shared pt? | humorS+humorT |
|------------|------------|---------|---------|--------------|------------|-----------|---------------|
| {0,1}      | {0,10}     | 1       | 10      | {0,1,10}     | 10         | yes (0)   | 11 (≥10 ✓)    |
| {0,1}      | {1,2}      | 1       | 1       | {0,1,2}      | 2          | yes (1)   | 2  (=2, tight)|
| {0,1}      | {5,6}      | 1       | 1       | {0,1,5,6}    | 6          | no        | 2  (6 > 2 ✗)  |
| {0,3}      | {3,4,10}   | 3       | 7       | {0,3,4,10}   | 10         | yes (3)   | 10 (=10 tight)|

Observations, all confirmed by the formal theorems:

* **Inflation** (`humor_union_ge_left/right`): `humor(S∪T) ≥ humor S` and `≥ humor T`
  in every row.
* **Subadditivity under shared context** (`humor_union_le_add_of_inter`): in every row
  with a shared point, `humor(S∪T) ≤ humor S + humor T`. Row 2 and row 4 show the bound
  is **tight** (equality is attained).
* **Necessity of the hypothesis**: row 3 has no shared point and `6 > 2`, so
  subadditivity *fails* without shared context. This is why the theorem carries the
  pivot hypothesis `c ∈ S`, `c ∈ T` — it is load-bearing, not cosmetic.

## 2. Restriction (intersection)

| S          | T          | S ∩ T   | humor(S∩T) | humor S | ≤ ? |
|------------|------------|---------|------------|---------|-----|
| {0,1,5}    | {1,5,9}    | {1,5}   | 4          | 5       | ✓   |
| {0,10}     | {0,3,10}   | {0,10}  | 10         | 10      | ✓   |

Confirms `humor_inter_le_left`: restricting to shared readings never increases surprise.

## 3. Functoriality (monotone refinement)

Refinement `S ⊆ T` always gives `humor S ≤ humor T`:
`{2,3} ⊆ {0,2,3,7}` gives `1 ≤ 7`; `{5} ⊆ {5}` gives `0 ≤ 0`. This is exactly the
content of `surpriseFunctor : Setup ⥤ ℝ` and `surprise_of_refinement`.

## 4. OEIS / counterexample hunt

No integer sequence is central here (the invariant is a real-valued range), so no OEIS
lookup applies. The counterexample hunt for *unconditional* subadditivity succeeded
(row 3 above), which is precisely why the formal statement restricts to setups sharing a
common resolution. Under that hypothesis, a sample of pairs with shared pivots produced
no counterexample, matching the proved theorem.
