# Computational Evidence

All computations below were run in Lean 4 (`#eval`, exact `ℤ`/`ℚ` arithmetic — no
floating point), before the formal proofs were written.  The final theorems in
`Catalog/Pythagorean/EMLBerggrenEnergyNeuron.lean` are proved symbolically, so
this file is orientation, not a substitute for proof.

## 1. Setup

* Euclid triple: `euclidTriple m n = (m² − n², 2mn, m² + n²)`.
* Barning–Hall matrices acting on `(a,b,c)`:
  `A = [[1,−2,2],[2,−1,2],[2,−2,3]]`, `B = [[1,2,2],[2,1,2],[2,2,3]]`,
  `C = [[−1,2,2],[−2,1,2],[−2,2,3]]`.
* Node energy: `E(a,b,c) = ½·log((c+a)/(c−a))`.  Since `c+a = 2m²`, `c−a = 2n²`,
  we have `exp(2E) = (m/n)²`, which is a *rational* invariant — so all checks
  below are exact rational identities.

## 2. Small-case calculations

Root `(m,n) = (2,1)`, triple `(3,4,5)`:

| branch | matrix image | Euclid params | ratio `r = m/n` | energy `log r` |
|---|---|---|---|---|
| `A` | `(5,12,13)`  | `(3,2)` | `3/2` | `0.4055` |
| `B` | `(21,20,29)` | `(5,2)` | `5/2` | `0.9163` |
| `C` | `(15,8,17)`  | `(4,1)` | `4`   | `1.3863` |

From `(5,2)` (triple `(21,20,29)`, `r = 5/2`):

| branch | matrix image | Euclid params | ratio | predicted `2 − 1/r`, `2 + 1/r`, `r + 2` |
|---|---|---|---|---|
| `A` | `(39,80,89)`    | `(8,5)`  | `8/5`  | `2 − 2/5 = 8/5`  ✓ |
| `B` | `(119,120,169)` | `(12,5)` | `12/5` | `2 + 2/5 = 12/5` ✓ |
| `C` | `(77,36,85)`    | `(9,2)`  | `9/2`  | `5/2 + 2 = 9/2`  ✓ |

Level 2 of the tree (9 triples), reproduced by both routes (matrix action and
Euclid substitution):
`(7,24,25) (55,48,73) (45,28,53) (39,80,89) (119,120,169) (77,36,85) (33,56,65)
(65,72,97) (35,12,37)`.

## 3. Exhaustive checks on the tree

Over **all 81 nodes of levels 0–4** (`(m,n)` generated from `(2,1)` by the three
Euclid substitutions), the following returned `true`:

1. `exp(2E) = (m/n)²` computed from the triple agrees with the Euclid ratio.
2. For every node and every branch,
   `exp(2E(child)) = (branch map applied to r)²` where the branch maps are
   `r ↦ 2 − 1/r`, `r ↦ 2 + 1/r`, `r ↦ r + 2` — i.e. exactly
   `E(child) = log(2 + σ·exp(ε·E(parent)))` with
   `(σ,ε) = (−1,−1), (1,−1), (1,1)`.
3. Strict uniform ordering `1 < 2 − 1/r < 2 + 1/r < r + 2` (equivalently
   `E_A < E_B < E_C`, all positive).
4. Every produced triple satisfies `a² + b² = c²` and `gcd(a,b) = 1`
   (primitivity).

## 4. Counterexample hunt

The universal claims to falsify were:

* *Step law*: no node in levels 0–4 (81 nodes × 3 branches = 243 steps) violates
  `E(child) = log(2 + σ exp(ε E(parent)))`.  No counterexample.
* *Range partition*: sampling `r ∈ {1.01, 1.1, 1.5, 2, 5, 100, 10⁴}` gives
  `2 − 1/r ∈ (1,2)`, `2 + 1/r ∈ (2,3)`, `r + 2 ∈ (3,∞)` in every case, i.e.
  child energies land in `(0,log 2)`, `(log 2,log 3)`, `(log 3,∞)`.  No overlap
  was found; the formal proof (`emlNeuron_image_A/B/C`) shows these images are
  *exactly* those intervals.
* *Root energy*: `log 2 = E(3,4,5)` was never attained as a child energy — the
  values `r' = 2` and `r' = 3` are provably unattainable (`2 − 1/r = 2` forces
  `1/r = 0`; `2 + 1/r = 2` likewise; `r + 2 = 2` forces `r = 0`; and `r' = 3`
  forces `r = 1`, excluded by `n < m`).

## 5. OEIS

No new integer sequence is introduced: the hypotenuses generated
(`5, 13, 29, 17, 25, 73, 53, 89, 169, 85, 65, 97, 37, …`) are the hypotenuses of
primitive Pythagorean triples in Berggren-tree order; the underlying set of
primitive hypotenuses is A008846. The Euclid parameters visited are exactly the
coprime pairs `m > n > 0` of opposite parity (A094192-type enumerations). The
mathematical content here is the analytic reformulation, not a new sequence.
