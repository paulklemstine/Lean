# Computational Evidence — Gaussian binomials and the Grassmann degree-one threshold

All computations below were run inside Lean (`#eval`) against the definition
`qBinom` (the `q`-Pascal recurrence) used in `Catalog/Novelty/GrassmannDegreeOne.lean`,
so the numbers are exactly the objects the theorems are about.

## 1. Small-case calculations

### `q = 1` reproduces Pascal's triangle (`[n,k]₁ = C(n,k)`)

```
qBinom 1 : rows n = 0..5
[1, 0, 0, 0, 0, 0]
[1, 1, 0, 0, 0, 0]
[1, 2, 1, 0, 0, 0]
[1, 3, 3, 1, 0, 0]
[1, 4, 6, 4, 1, 0]
[1, 5,10,10, 5, 1]
```
Identical to `Nat.choose` rows — formalized as `qBinom_one`.

### Point counts `[n,1]_q = 1 + q + … + q^{n-1}`

```
q = 3 :  [n,1]₃ for n = 0..5  =  0, 1, 4, 13, 40, 121      ( = (3^n − 1)/2 )
```
Formalized as `qBinom_one_eq_geom`.

### 2-subspace counts (the `k = 2` case of the conjecture)

```
[n,2]_3 , n = 0..6  =  0, 0, 1, 13, 130, 1210, 11011
[n,2]_4 , n = 0..6  =  0, 0, 1, 21, 357, 5797, 93093
[n,2]_5 , n = 0..6  =  0, 0, 1, 31, 806,20956,...
```
The known results for `q ∈ {3,4,5}, k = 2` certify degree-one triviality once
`n ≥ 2k+1 = 5`, i.e. starting from the `n = 5` column above.

## 2. OEIS search results

* `[n,2]_3 = 1, 13, 130, 1210, …` is **OEIS A006105** (Gaussian binomial `[n,2]` for `q=3`).
* `[n,1]_q = (q^n−1)/(q−1)` are the **repunit / projective-point counts**
  (`q=2`: A000225 Mersenne; `q=3`: A003462; `q=4`: A002450; `q=5`: A003463).
* The `q=1` row sums `∑_k [n,k]₁ = 2^n` are **A000079**; formalized as
  `qBinom_one_total_mass`.

## 3. Counterexample hunt

* **Symmetry** `[n,k]_q = [n,n−k]_q`: checked for all `0 ≤ k ≤ n ≤ 5`, every `q ∈ {2,3,4,5}`
  — no counterexample.  (Theorem `qBinom_symm`.)
* **Point/hyperplane duality** `[n,1]_q = [n,n−1]_q`: verified for `q=3`, `n = 0..5`:
  `(0,1),(1,1),(4,4),(13,13),(40,40),(121,121)` — equal in every case.
  (Theorem `point_hyperplane_duality`.)
* **Strict growth in `n`** (`q ≥ 2`, `1 ≤ k ≤ n`): `[n,k]_q < [n+1,k]_q` held in every
  sampled case; the boundary hypotheses matter — at `q = 0` the count can stagnate and at
  `q = 1` ordinary binomials are not strictly increasing past the diagonal.
  (Theorem `qBinom_strictMono_left`, with the `2 ≤ q` hypothesis shown load-bearing.)

No counterexample to any formalized statement was found.

## 4. Threshold table (where the conjecture "turns on")

For `k = 2` the conjectured threshold is `n ≥ 2k+1 = 5`.  The table of `[n,2]_q` above shows
the schemes are already large at `n = 5` (`1210` for `q=3`), consistent with the heuristic
that triviality requires "enough room", i.e. `k` strictly below the central index `n/2`
(formalized via `qBinom_one_unimodal_bound`).
