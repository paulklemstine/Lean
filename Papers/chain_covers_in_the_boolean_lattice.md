# Computational Evidence — Chain Covers in the Boolean Lattice

We study the minimum number of chains needed to cover the Boolean lattice
`B_n = (2^{[n]}, ⊆)`, and two lower bounds for it:

- **Sperner/Dilworth bound:** `#chains ≥ C(n, ⌊n/2⌋)` (width = size of the middle layer).
- **Length/counting bound:** `2^n ≤ (n+1)·#chains`, i.e. `#chains ≥ ⌈2^n/(n+1)⌉`,
  because every chain in `B_n` has at most `n+1` elements.

## 1. Small-case table

Columns: `n`, middle binomial `C(n,⌊n/2⌋)`, total subsets `2^n`, and the counting
lower bound `⌈2^n/(n+1)⌉`.

| n | C(n,⌊n/2⌋) | 2^n | ⌈2^n/(n+1)⌉ |
|---|-----------|-----|-------------|
| 0 | 1  | 1   | 1  |
| 1 | 1  | 2   | 1  |
| 2 | 2  | 4   | 2  |
| 3 | 3  | 8   | 2  |
| 4 | 6  | 16  | 4  |
| 5 | 10 | 32  | 6  |
| 6 | 20 | 64  | 10 |
| 7 | 35 | 128 | 16 |
| 8 | 70 | 256 | 29 |

(Computed with `#eval (List.range 9).map (fun n => (n, Nat.choose n (n/2), 2^n, (2^n+n)/(n+1)))`.)

Observations:
- The middle binomial `C(n,⌊n/2⌋)` is always `≥` the counting bound `⌈2^n/(n+1)⌉`
  — consistent with the fact that the Sperner width is the *exact* minimum chain
  cover (Dilworth + symmetric chain decomposition), which must dominate any other
  lower bound. This is the empirical shadow of `middle_choose_mul_ge`
  (`2^n ≤ (n+1)·C(n,⌊n/2⌋)`).
- Both quantities grow like `2^n` up to a polynomial `n` factor:
  `C(n,⌊n/2⌋) = Θ(2^n / √n)` (central binomial), while the crude counting bound
  is `Θ(2^n / n)`. So the log-scale gap between the two lower bounds is
  `½ log₂ n + O(1)` — a genuinely *logarithmic* deficit, matching the "logarithmic
  approximation" theme.

## 2. Sanity checks of the extremal antichain (middle layer)

- n=2: middle layer = `{ {0}, {1} }`, size `2 = C(2,1)`; it is an antichain, and
  `B_2` is covered by the two chains `∅ ⊂ {0} ⊂ {0,1}` and `{1}` — so 2 chains
  are necessary (this antichain) and sufficient. Minimum = 2 = C(2,1). ✓
- n=3: middle layer = all 3 singletons and (for `⌊3/2⌋=1`) the size-1 sets;
  `C(3,1)=3`. A symmetric chain decomposition of `B_3` uses exactly 3 chains. ✓
- n=4: `C(4,2)=6`; symmetric chain decomposition uses exactly 6 chains. ✓

## 3. Counterexample hunt

- Claim "`2^n ≤ (n+1)·C(n,⌊n/2⌋)`" tested for `n ≤ 8`: holds in every row
  (`1≤1, 2≤2, 4≤6, 8≤12, 16≤30, 32≤60, 64≤140, 128≤280, 256≤630`). No
  counterexample. This is the finite reflection of the proved theorem
  `middle_choose_mul_ge`.
- Claim "every chain in `B_n` has `≤ n+1` elements" — a chain is strictly
  monotone in cardinality, and cardinalities lie in `{0,…,n}`, so at most `n+1`
  values; no counterexample possible (proved as `chain_card_le`).

## 4. OEIS

The middle-binomial sequence `1, 1, 2, 3, 6, 10, 20, 35, 70, …` is
**OEIS A001405** (central binomial coefficients `C(n, ⌊n/2⌋)`), which is exactly
the minimum number of chains in a chain cover / the maximum antichain size of the
Boolean lattice `B_n`.

## Conclusion

The computations corroborate all four formalized results and, in particular, the
ordering `⌈2^n/(n+1)⌉ ≤ C(n,⌊n/2⌋) ≤ minimum chain cover`, with a logarithmic
`Θ(√n)` multiplicative gap between the two lower bounds.
