# Computational Evidence — Alexander polynomials of torus knots and the divisor spectrum

All claims below were tested numerically *before* formalization; the ones that survived are
now Lean theorems in `Catalog/Computation/AlexanderTorusKnot/`. The spectra and totient data
are additionally re-verified inside Lean by kernel evaluation (`by decide` examples at the
end of `GeneralTorus.lean`), so they are machine-checked, not just scratch computations.

## 1. Divisor spectra `S(a,b) = {d : d ∣ ab, d ∤ a, d ∤ b}`

| `(a,b)` | `S(a,b)` | `#S` | `(τa−1)(τb−1)` | `∑_{d∈S} φ(d)` | `(a−1)(b−1)` |
|---|---|---|---|---|---|
| (2,3) | {6} | 1 | 1 | 2 | 2 |
| (3,5) | {15} | 1 | 1 | 8 | 8 |
| (2,9) | {6,18} | 2 | 2 | 8 | 8 |
| (4,9) | {6,12,18,36} | 4 | 4 | 24 | 24 |
| (3,7) | {21} | 1 | 1 | 12 | 12 |
| (5,12) | 5 elements | 5 | 5 | 44 | 44 |
| (2,15) | {6,10,30} | 3 | 3 | 14 | 14 |
| (2,143) | {22,26,286} | 3 | 3 | 142 | 142 |
| (11,13) | {143} | 1 | 1 | 120 | 120 |

Both closed forms — `#S = (τa−1)(τb−1)` and `∑ φ = (a−1)(b−1)` — held on every sample and
are now proved (`torusAlexander_card_factors`, `torusAlexander_natDegree`).

## 2. Semiprime degree spectra for the `T(2,N)` pencil

`N ↦ {φ(d) : d ∣ N, d > 1}`, with `φ(N) = max`, `s = N + 1 − φ(N)`, and `p,q` from the
quadratic formula:

| `N` | degree multiset | `φ(N)` | `s` | recovered `(p,q)` |
|---|---|---|---|---|
| 15 | {2,4,8} | 8 | 8 | (3,5) ✓ |
| 21 | {2,6,12} | 12 | 10 | (3,7) ✓ |
| 33 | {2,10,20} | 20 | 14 | (3,11) ✓ |
| 35 | {4,6,24} | 24 | 12 | (5,7) ✓ |
| 143 | {10,12,120} | 120 | 24 | (11,13) ✓ |
| 323 | {16,18,288} | 288 | 36 | (17,19) ✓ |

In every case `∑ degrees + 1 = N` (the degree of `A_N` is `N−1`).

## 3. Counterexample hunt for the gcd conjecture

Conjecture tested: **`gcd(A_M, A_N) = A_{gcd(M,N)}`** in `ℚ[X]`, where
`A_N(X) = 1 − X + X² − ⋯ + X^{N−1}`.

Monic polynomial gcds were computed by the Euclidean algorithm over `ℚ` for the pairs

`(9,15), (15,21), (21,35), (105,45), (11,13), (27,9), (25,35)`

covering coprime pairs, nested pairs, prime powers and pairs with a nontrivial common
factor. **No counterexample found**: in all seven cases the monic gcd equalled `A_{gcd(M,N)}`
exactly. The statement is now proved (`alexanderQ_gcd`), together with the sharper
divisibility characterization `f ∣ A_M ∧ f ∣ A_N ↔ f ∣ A_{gcd(M,N)}`.

## 4. Claims that had to be corrected

* The cost bound `2·deg Δ_{p,q} + 1 ≥ pq` is **false for `p = 2`** (`2·2+1 = 5 < 6` for
  `T(2,3)`). It holds for `2 < p < q`, and the Lean statement
  `torus_semiprime_pipeline_cost` carries that hypothesis.
* Palindromicity `Δ_{a,b}.reverse = Δ_{a,b}` was first attempted factorwise (self-reciprocity
  of each `Φ_d`, which Mathlib does not have); the sign computation
  `(X^n − 1).reverse = −(X^n − 1)` makes the defining identity do the work instead.

## 5. Sequences

The degree sequence `deg Δ_{a,b} = (a−1)(b−1)` is just the product of the two "reduced"
parameters; the factor-count sequence `(τa−1)(τb−1)` is the multiplicative divisor-count
shift. No new OEIS entry is claimed — both are elementary multiplicative functions of the
pair `(a,b)`, and this is exactly the point: the topological invariant is a repackaging of
the divisor lattice of `ab`.

## 6. Cycles 8–11: determinants, semigroup gaps, readout, Jones

**Determinants (cycle 8).** `Δ_{a,b}(−1)` computed from the cancelled identity
`Δ_{a,b}(X^a − 1) = (∑_{i<a} X^{bi})(X − 1)`:

| `(a,b)` | `Δ_{a,b}(−1)` | knot | classical determinant |
|---|---|---|---|
| `(3,2)` | `3` | trefoil `3₁` | `3` |
| `(5,2)` | `5` | cinquefoil `5₁` | `5` |
| `(7,2)` | `7` | `7₁` | `7` |
| `(3,5)` | `1` | `10₁₂₄` | `1` |
| `(3,7)` | `1` | `T(3,7)` | `1` |

All five agree with the classical values; the general law is
`torus_determinant_trichotomy` (the determinant is `1` when both parameters are odd, and the
odd parameter otherwise). No counterexample was found, and the theorem now covers all cases.

**Semigroup gaps (cycle 9).** Checked by `decide` inside the Lean file:
`gaps 3 5 = {1,2,4,7}` (conductor `8`, Frobenius number `7`, genus `4 = 8/2`) and
`gaps 4 5 = {1,2,3,6,7,11}` (conductor `12`, genus `6`). These match the coefficient
patterns `Φ₁₅ = X⁸ − X⁷ + X⁵ − X⁴ + X³ − X + 1` and `Δ_{4,5} = Φ₁₀Φ₂₀` term by term via
`coeff_n = [n ∈ ⟨a,b⟩] − [n−1 ∈ ⟨a,b⟩]`.

**Readout (cycle 10).** For `T(3,5)`: the least positive index with coefficient `+1` is `3`
(`= min(3,5)`), and `deg Δ / (3−1) + 1 = 8/2 + 1 = 5 = max(3,5)`. For the pencil `T(2,N)` the
same recipe returns `2` and `N` — the inputs, never a factor.

**Jones (cycle 11).** The claimed `O(1)` sparsity of the Jones polynomial is **false**. The
normalized Jones polynomials computed (and verified in Lean) are

| `(a,b)` | `J_{a,b}` | nonzero coefficients |
|---|---|---|
| `(3,2)` | `1 + X² − X³` | 3 |
| `(3,5)` | `1 + X² − X⁶` | 3 |
| `(5,7)` | `1 + X² + X⁴ − X⁸ − X¹⁰` | 5 |
| `(7,9)` | `1 + X² + X⁴ + X⁶ − X¹⁰ − X¹² − X¹⁴` | 7 |

The count grows like `a`, so only the four-term *numerator* is `O(1)`. What survives is the
degree separation `deg J = a + b − 2` versus `deg Δ = (a−1)(b−1)`, and the Vieta pair
`a + b = deg J + 2`, `ab = deg Δ + deg J + 1`.

**Gap runs and the support law (cycles 12–13).** The run count `β(a,b) = #downJumps a b`
is computable inside Lean (`IsRep` has a decidability instance), and `#eval` gives

| `(a,b)` | `β(a,b)` | `#supp Δ_{a,b} = 2β+1` | `max(a,b)` |
|---|---|---|---|
| `(2,9)` | 4 | 9 | 9 |
| `(3,7)` | 4 | 9 | 7 |
| `(5,7)` | 8 | 17 | 7 |
| `(9,10)` | 8 | 17 | 10 |

matching independent enumeration of `⟨a,b⟩`. The values confirm both proved statements —
`#supp = 2β + 1` (`torusAlexander_support_card`) and `#supp ≥ max(a,b)`
(`torusAlexander_support_card_ge`) — and show the second is tight on `(2,N)` and on
`(a, a+1)`, where `β = a − 1`.

For the *conjectural* Apéry closed form of `β` recorded in `FUTURE_DIRECTIONS.md`
(Conjecture 1), direct enumeration agrees with the formula on all 69 coprime pairs
`2 ≤ a < b ≤ 19`. That check was done by exhaustive enumeration outside Lean, so it is
evidence only; the Lean development proves just the inequality `b − 1 ≤ 2β`.

### Cycle 14: tightness of the support bound on the pencil `T(2,N)`

Direct expansion of `A_N = (X^N+1)/(X+1)` for odd `N` gives the alternating polynomial
`X^{N-1} - X^{N-2} + ... - X + 1`, whose support has exactly `N` elements:

| `N` | 3 | 5 | 7 | 9 | 11 | 13 | 15 |
|---|---|---|---|---|---|---|---|
| `#supp A_N` | 3 | 5 | 7 | 9 | 11 | 13 | 15 |

The gaps of `⟨2,N⟩` are the odd numbers `1, 3, …, N-2`, so every maximal gap run has length
one and the run count is `β(2,N) = (N-1)/2`; the support law `#supp = 2β + 1` then gives `N`.
This is now a Lean theorem (`torusAlexander_two_support_card`), not merely tabulated data, so
the general lower bound `#supp Δ_{a,b} ≥ max(a,b)` is sharp.

### Cycle 15: the staircase family `T(a, a+1)`

Enumerating `⟨a, a+1⟩` directly gives the gap runs

| `a` | gaps of `⟨a,a+1⟩` | runs | `β` | `#supp Δ_{a,a+1}` |
|---|---|---|---|---|
| 3 | 1, 2, 5 | {1,2}, {5} | 2 | 5 |
| 4 | 1, 2, 3, 6, 7, 11 | {1,2,3}, {6,7}, {11} | 3 | 7 |
| 5 | 1,2,3,4, 6,7,8, 11,12, 16 | four runs | 4 | 9 |

so `β(a,a+1) = a−1` and `#supp = 2a−1`. This is now a Lean theorem
(`torusAlexander_staircase_support`), proved from the closed membership test
`n ∈ ⟨a,a+1⟩ ↔ n % a ≤ n / a`, and not merely tabulated. Note `2a − 1 > a + 1 = max(a,a+1)`
for `a ≥ 3`, so the general Cycle 13 bound is strict off the pencil, while `2a − 1 =
a + (a+1) − 2` matches the value `a + b − 2` realised by `T(2,N)`.
