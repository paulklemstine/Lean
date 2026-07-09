# Computational Evidence — Elementary cellular automata as varieties over GF(2)

We view each elementary cellular automaton (ECA) rule as a degree-≤3 polynomial
map over the binary field `GF(2)`. A configuration on a cyclic lattice of length
`n` is a vector `s ∈ GF(2)^n`, and the fixed-point set

    V(g) = { s : s_i = g(s_{i-1}, s_i, s_{i+1}) for all i }

is the set of `GF(2)`-points of an affine variety. Below we tabulate the size
`|V(g)|` (which, for a linear variety, equals `2^{dim V}`) for several landmark
rules on small cycles. All numbers were computed by exhaustive enumeration over
`GF(2)^n`.

## 1. Small-case counts `|V(g)|`

Cycle length `n`:            1   2   3   4   5   6   7   8 … 14

| Rule            | polynomial `g(a,b,c)`      | counts by `n`                         |
|-----------------|----------------------------|---------------------------------------|
| 204 (identity)  | `b`                        | `2,4,8,16,32,64,128,…` = `2^n`        |
| 90  (additive)  | `a + c`                    | `1,1,4,1,1,4,1,…`                     |
| 150 (additive)  | `a + b + c`                | `2,4,2,4,2,4,2,…`                     |
| 110 (universal) | `b + c + bc + abc`         | `1,1,1,1,1,1,1,…,1` (up to n=14)      |
| 0   (null)      | `0`                        | `1,1,1,1,1,…` = `1`                   |
| 51  (complement)| `b + 1`                    | `0,0,0,0,0,…` = `0`                   |

## 2. Patterns identified

* **Rule 90 ↔ Fibonacci / Pisano period.** The count is `4` when `3 ∣ n` and `1`
  otherwise. The fixed-point equation rearranges over `GF(2)` to the Fibonacci
  recurrence `s_{i+1} = s_i + s_{i-1}`, whose companion matrix
  `T = [[0,1],[1,1]]` satisfies `T^3 = I` (order `3`). A nonzero cyclic solution
  exists iff `T^n = I` iff `3 ∣ n`; then `dim V = 2`, else `dim V = 0`. The
  number `3` is exactly the Pisano period `π(2)` of the Fibonacci sequence
  modulo `2`: `0,1,1,0,1,1,…`.

* **Rule 150 ↔ parity.** The count is `4` for even `n` and `2` for odd `n`. The
  fixed-point equation reduces to two-periodicity `s_{i+2} = s_i`. For odd `n`,
  `2` generates the cycle so only constants survive (`dim V = 1`); for even `n`,
  the even and odd sublattices are independent (`dim V = 2`).

* **Rule 110 collapse.** The Turing-complete rule has `|V| = 1` for every tested
  `n` up to `14`: the *only* fixed configuration is all-zeros (`dim V = 0`). The
  fixed-point equation factors as `s_{i+1}·(1 + s_i(1 + s_{i-1})) = 0`; a zero
  cell forces its right neighbour to be zero, so on a cycle a single zero
  propagates everywhere, while the all-ones state is never fixed.

## 3. Counterexample hunt for the headline conjecture

Conjecture (mission brief): *fixed-point dimension increases with Wolfram
complexity class; Rule 110 (Class 4) attains the maximal dimension `n`.*

**Refuted.** The data invert the claim:

* Rule 204 (Class 2, dynamically trivial identity): `dim V = n` (maximal).
* Rule 110 (Class 4, Turing-complete): `dim V = 0` (minimal).

So the *most* complex rule has the *smallest* fixed-point variety, and a *simple*
rule has the largest. The honest structural invariant separating the tractable
rules is *linearity of the variety* (rules 0, 90, 150, 170, 204, 240 are linear;
Rule 110 is a genuine cubic), not its dimension.

## 4. OEIS notes

* Fibonacci modulo `2`: `0,1,1,0,1,1,0,1,1,…` — the period-`3` reduction
  underlying the Rule 90 counts (Pisano period `π(2)=3`).
* Rule 90 fixed-count sequence `1,1,4,1,1,4,…` is the indicator `3 ∣ n` scaled to
  `{1,4}`; Rule 150 count `2,4,2,4,…` is the parity of `n` scaled to `{2,4}`.

All patterns in §2–§3 that are stated as theorems are proved unconditionally in
`Basic.lean`, `Counts.lean`, and `Bridge.lean`; the tabulated counts above are the
computational evidence that motivated those proofs.
