# Computational Evidence — Universal Posets

All numbers below were produced by evaluating Lean programs (`#eval`) in this
project's toolchain.  They are *compiler-evaluated*, not kernel-checked, and are
therefore reported as **evidence**, not as verified theorems.  Everything that is
claimed as a theorem lives in `Catalog/Cryptography/UniversalPosets/*.lean` and
is proved with zero `sorry`s.

## 1. Small-case calculations: how many posets are there?

Enumerating all `R : Fin n → Fin n → Bool` and filtering for reflexive,
transitive, antisymmetric relations:

| n | # labelled partial orders on `Fin n` |
|---|--------------------------------------|
| 0 | 1    |
| 1 | 1    |
| 2 | 3    |
| 3 | 19   |
| 4 | 219  |

## 2. OEIS

The sequence `1, 1, 3, 19, 219, 4231, …` is **OEIS A001035** (number of partial
orders on a labelled `n`-set).  Its growth `2^{n²/4 + o(n²)}` is what drives the
counting lower bound formalised in `Bounds.lean`: a host of `N` points admits at
most `N^n` induced copies, whence `N ≥ 2^{n/4 - o(n)}`.

The formalised proof does not use A001035 itself; instead it uses the explicit
sub-family of *bipartite* orders (`bipRel`), of which there are exactly `2^{kl}`
on `k + l` points — a family whose size is provable in a dozen lines rather than
requiring the asymptotics of A001035.

## 3. Exhaustive search for the optimal host `U(n)`

`U(n)` = least `N` such that some poset on `N` points contains **all** posets on
`n` points as induced subposets.  Exhaustive search over all posets on `N`
points and all maps `Fin n → Fin N`:

| n | N tested | universal host exists? |
|---|----------|------------------------|
| 2 | 2        | **no**                 |
| 2 | 3        | **yes**                |
| 3 | 4        | **no**                 |
| 3 | 5        | **yes**                |

Hence, computationally, `U(1) = 1`, `U(2) = 3`, `U(3) = 5`.

* `U(2) = 3` is **proved** in `SmallCases.lean` / `MinSize.lean`
  (`minUniversalSize_two`).
* `U(3) = 5` is evidence only: replaying a search over `2^{25}` relations inside
  the kernel is not feasible, and `native_decide` is excluded by the project's
  rules.

The search was not pushed to `n = 4`: it would require enumerating posets on
`≥ 6` points, i.e. `2^{36}` candidate relations.

## 4. Counterexample hunt

The universal claims proved in this project were stress-tested before being
formalised:

* *Is the neighbourhood label alone enough for bipartite posets?*  **No.**  Two
  top elements with the same down-set need two distinct host points; the search
  at `n = 3` confirms that dropping the tag coordinate breaks universality.
  This is formalised as `bipHost_tag_needed`.
* *Is the counting bound tight?*  **No.**  At `n = 2` counting gives `N ≥ 2`
  while the truth is `3`; at `n = 3` counting gives `N ≥ 2` while the truth
  is `5`.  This is the finite shadow of the `n/4` vs `n/2` exponent gap.
* *Does `BipHost k l` beat the trivial `2^n` host on the full class?*  **No** —
  it is universal only for the bipartite (height `≤ 2`) subclass.  No claim of
  full universality is made for it, except at `k = l = 1`, where it is checked
  directly (`bipHost_one_one_isUniversalHost`).

## 5. Table: the two exponents

For `n = 2m` points, writing sizes as `2^{c·n}`:

| bound                                    | `c`      | status here |
|------------------------------------------|----------|-------------|
| counting lower bound (bipartite family)   | `1/4`    | proved      |
| explicit host for the balanced bipartite class | `1/2` (+ `log n` factor) | proved |
| Boolean lattice, full class               | `1`      | proved      |
| paper's theorem, full class               | `(1+η)/2`| not formalised (needs the regularity machinery) |

---

# Second cycle (continuation)

## 6. Exact small values, and what is now proved

| `n` | `U(n)` | status |
|-----|--------|--------|
| 0   | 0      | proved (`minUniversalSize_zero`) |
| 1   | 1      | proved (`minUniversalSize_one`) |
| 2   | 3      | proved (`minUniversalSize_two`) |
| 3   | 5      | **proved** (`minUniversalSize_three`) — was evidence only in cycle 1 |
| 4   | 8      | `7 ≤ U(4) ≤ 8` proved (`minUniversalSize_four_bounds`); `U(4) = 8` is evidence only |

## 7. Exhaustive searches performed in this cycle

All searches below were run outside Lean; wherever a *positive* answer was found
it has been re-verified inside Lean by a kernel `decide` (never `native_decide`),
so nothing about the external search is trusted.  Negative (nonexistence)
answers are recorded as evidence only, since replaying them in the kernel is
infeasible.

* **`n = 3`.**  All `4231` partial orders on five points were enumerated; exactly
  `300` of them contain all `19` partial orders on three points.  The sparsest
  such host (five comparable pairs) is the diamond `4 < 2, 3 < 1` together with
  an isolated point `0`; it is the host `host3Le` formalised in
  `ExactSmall.lean`, and its universality is re-verified by `decide`.
  No four-point host exists — this is now *proved* in Lean, without any search,
  by the chain-versus-antichain argument (`two_mul_sub_one_le_minUniversalSize`).

* **`n = 4`.**  All `96428` naturally labelled seven-point posets (that is, all
  transitively closed upper-triangular relations on `7` points, which covers
  every isomorphism class) were enumerated: **none** contains all `16`
  isomorphism types of four-element posets.  Hence, as evidence, `U(4) ≥ 8`.
  A randomised search over eight-point posets found hosts; the one used in
  `FourPoints.lean` is

  ```
  0 < 1, 3, 4, 5, 6, 7      1 < 5, 6, 7      2 < 7
  3 < 5, 6, 7               4 < 6            5 < 6
  ```

  and the kernel verifies that all `219` partial orders on `Fin 4` embed into it
  as induced subposets, giving the proved bound `U(4) ≤ 8`.

* **Deleting a maximal point.**  For each of the `300` five-point hosts above,
  deleting a maximal point leaves a four-point poset that is still universal for
  the two-element posets, as predicted by the argument now formalised as
  `isUniversalPosetOfSize_pred` (strict monotonicity of `U`).

## 8. The two lower bounds, numerically

`max(3n - ⌈n/2⌉ - 3, 2^{(n-1)/4})` is the best lower bound proved here (the
first term subsumes `2n-1` from `n = 6` on; both are recorded in
`linear_lower_bound`).  Values of the linear term:
`n = 0,…,11 : 0, 1, 3, 5, 7, 9, 12, 14, 17, 19, 22, 24`, which matches the exact
values `U(0..3) = 0, 1, 3, 5`.  The crossover
between its two terms:

| `n`  | `2n-1` | `2^{(n-1)/4}` (rounded) | dominant |
|------|--------|--------------------------|----------|
| 4    | 7      | 1.7                      | structural |
| 8    | 15     | 3.4                      | structural |
| 16   | 31     | 14                       | structural |
| 20   | 39     | 28                       | structural |
| 24   | 47     | 56                       | counting |
| 40   | 79     | 861                      | counting |

So the structural bound is the better one exactly in the range where exact
values are within reach, which is why it settles `n ≤ 3` and pins `n = 4` to
two possible values.

## 9. The geometric chain-union family (third cycle)

The superlinear bound of `ChainFamily.lean` uses, for `n = 4^k`, the family
`blockChains n (4^i)` (`0 ≤ i < k`): the disjoint union of `4^{k-i}` chains of
length `4^i`.  Its pairwise overlaps and the resulting guarantee
`U(4^k) ≥ 2k·4^k/3` compared with the linear bound of the previous cycle:

| `k` | `n = 4^k` | family bound `⌊2kn/3⌋` | linear bound `3n − ⌈n/2⌉ − 3` | counting bound `2^{(n−1)/4}` |
|-----|-----------|------------------------|-------------------------------|------------------------------|
| 1   | 4         | 2                      | 7                             | 1.7                          |
| 2   | 16        | 21                     | 37                            | 13.5                         |
| 3   | 64        | 128                    | 157                           | 5.5·10⁴                      |
| 4   | 256       | 682                    | 637                           | 1.6·10¹⁹                     |
| 5   | 1024      | 3413                   | 2557                          | 9.7·10⁷⁶                     |
| 6   | 4096      | 16384                  | 10237                         | 1.5·10³⁰⁸                    |

So the family bound overtakes every linear bound from `n = 256` on (as it must,
being `Θ(n log n)`), while the counting bound of `LogBounds.lean` dominates both
from `n = 24` on.  The interest of the family bound is therefore methodological:
it measures how far *structural incompatibility* alone can go.

Threshold experiment: repeating the computation with ratio `q` in place of `4`
(so block sizes `q^i`) gives a guarantee `≈ k·n·(1 − 1/(q−1))`; at `q = 2` the
factor is `0` — the overlaps exactly consume the gain — and the best constant
among integer ratios is at `q = 4` (per-`log₂ n` factors `0.455, 0.481, 0.466,
0.410` for `q = 3, 4, 5, 8`).  Every number in the table above is a value of a
formula that is *proved* in `ChainFamily.lean`; the ratio comparison is
arithmetic exploration only and is not formalised.
