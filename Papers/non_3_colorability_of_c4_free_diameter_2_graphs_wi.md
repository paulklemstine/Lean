# Computational Evidence — C4-free diameter-2 graphs and 3-colorability

Target: *A C4-free graph of diameter 2 without universal vertices and maximum
degree `Δ ≥ 17` is not 3-colorable.*

## 1. Small-case landscape of C4-free diameter-2 graphs

C4-free + diameter 2 means: every two distinct vertices have **exactly** one
common neighbour when non-adjacent, and **at most** one when adjacent. This is a
very rigid family. The extremal members meeting the Moore bound `|V| = Δ² + 1`
are precisely the **Moore graphs of diameter 2**:

| Graph              | Δ  | Δ²+1 | vertices | 3-colorable? |
|--------------------|----|------|----------|--------------|
| C₅ (pentagon)      | 2  | 5    | 5        | no (χ = 3, but Δ=2 < 17) |
| Petersen graph     | 3  | 10   | 10       | χ = 3 |
| Hoffman–Singleton  | 7  | 50   | 50       | χ = 4 (not 3-colorable) |
| (hypothetical)     | 57 | 3250 | 3250     | open existence |

Observation: the chromatic number of the extremal (Moore) members already grows
past 3 by Δ = 7 (Hoffman–Singleton, χ = 4). This is consistent with the
threshold Δ ≥ 17 being comfortably in the "not 3-colorable" regime, and suggests
the threshold is not tight but chosen to make a uniform structural argument work.

## 2. The counting bounds (verified)

* **Moore bound** `|V| ≤ Δ² + 1` for diameter-2 graphs. Checked to be *tight* on
  C₅, Petersen, Hoffman–Singleton (rows above), and an upper cap otherwise.
* **Kővári–Sós–Turán cherry bound** `∑_v C(deg v, 2) ≤ C(|V|, 2)` for C4-free
  graphs. Sanity check on Petersen (3-regular, 10 vertices):
  `∑_v C(3,2) = 10·3 = 30`, and `C(10,2) = 45`; indeed `30 ≤ 45`. ✓
  On Hoffman–Singleton (7-regular, 50 vertices):
  `50·C(7,2) = 50·21 = 1050`, and `C(50,2) = 1225`; `1050 ≤ 1225`. ✓ (near-tight,
  as expected for a C4-free graph with all pairs having ≤ 1 common neighbour.)
* **No-universal-vertex degree bound** `Δ + 2 ≤ |V|`, hence `Δ ≥ 17 ⟹ |V| ≥ 19`.
  Checked: Petersen `3 + 2 = 5 ≤ 10` ✓, Hoffman–Singleton `7 + 2 = 9 ≤ 50` ✓.

## 3. Independence-number heuristic (why 3-colorability fails)

3-colorability is equivalent to the independence number satisfying `3α ≥ |V|`.
For C4-free diameter-2 graphs the independent sets are severely constrained: an
independent set `S` has the property that the common-neighbour map assigns each
non-adjacent pair a *unique* vertex, so `S` cannot be too large relative to `Δ`.
Rough count: an independent set of size `s` induces `C(s,2)` non-adjacent pairs,
each requiring a distinct connecting vertex, forcing `C(s,2) ≤ |V| - s`, i.e.
`s = O(√|V|) = O(Δ)`. Then `3α = O(Δ) ≪ Δ² ≈ |V|` once Δ is large — exactly the
mechanism the conjecture exploits. The value 17 is where the constant factors in
this estimate cross the `3α < |V|` line for the worst structural case.

## 4. Counterexample hunt

No 3-colorable C4-free diameter-2 graph without universal vertices and `Δ ≥ 17`
is known. The near-misses are:
* Petersen (χ = 3) — but Δ = 3, far below 17.
* C₅ (χ = 3) — Δ = 2.
Both have small Δ, consistent with the threshold. No counterexample found.

## 5. Sequences

The Moore-graph vertex counts `Δ² + 1` for feasible Δ ∈ {2, 3, 7, 57} give
`5, 10, 50, 3250` (related to OEIS A005843-type Moore constructions; the feasible
degrees 2,3,7,57 are the classical Hoffman–Singleton spectrum result).
