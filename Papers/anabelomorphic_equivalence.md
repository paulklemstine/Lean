# Computational Evidence — Anabelomorphic Equivalence (GL(1) residue side)

All claims below were subsequently formalized in Lean (`Core.lean`, `Equivalence.lean`,
`LanglandsCount.lean`) and machine-checked with 0 `sorry`. This note records the small-case
exploration that motivated the theorem statements.

## Objects

For a residue datum `(p, f)` (residue characteristic `p` prime, residue degree `f ≥ 1`):

* residue field `k = 𝔽_q` with `q = p^f`;
* **residue torus** `k^× = (𝔽_q)^×`, a cyclic group of order `q - 1`;
* residue-anabelomorphic equivalence: `k^× ≅ (k')^×` as abstract groups.

## 1. Small-case table of `|k^×| = q - 1`

| p | f | q = p^f | \|k^×\| = q-1 |
|---|---|---------|---------------|
| 2 | 1 | 2       | 1             |
| 2 | 2 | 4       | 3             |
| 2 | 3 | 8       | 7             |
| 3 | 1 | 3       | 2             |
| 3 | 2 | 9       | 8             |
| 5 | 1 | 5       | 4             |
| 7 | 1 | 7       | 6             |

Since `k^×` is cyclic, `k^× ≅ (k')^×` iff `q - 1 = q' - 1` iff `q = q'`. Because `q = p^f` is a
prime power, `q = q'` forces `p = p'` and `f = f'` (unique factorization). This is the rigidity
theorem `anabelEquiv_iff`.

## 2. Counter-intuitive test: degree does not determine the residue torus

Fix `p = 2` and total degree `n = e·f = 2`. Two admissible splittings:

* `(e, f) = (1, 2)` → residue field `𝔽_4`, `|k^×| = 3`;
* `(e, f) = (2, 1)` → residue field `𝔽_2`, `|k^×| = 1`.

Same `p`, same degree `2`, but `3 ≠ 1`, so the residue tori are **not** isomorphic. Ramification `e`
is traded against residue degree `f` while `(p, n)` is held fixed, yet the abelian Langlands datum
changes. This is `degree_not_rigid`.

## 3. GL(1) character count `#{a ∈ k^× : a^m = 1} = gcd(m, q-1)`

Because a finite cyclic group is its own Pontryagin dual, this equals the number of tame characters
of order dividing `m`. Sample with `q - 1 = 12` (e.g. `q = 13`):

| m  | gcd(m, 12) |
|----|------------|
| 1  | 1          |
| 2  | 2          |
| 3  | 3          |
| 4  | 4          |
| 6  | 6          |
| 12 | 12         |
| 5  | 1          |
| 8  | 4          |

Each entry equals the number of `m`-th roots of unity in the cyclic group `ℤ/12`, verified by direct
enumeration. This is `residue_char_count`, and its invariance under anabelomorphic equivalence is
`char_count_anabel_invariant`.

## 4. OEIS / counterexample hunt

* The map `f ↦ 2^f - 1` (residue-torus orders in characteristic 2) is the Mersenne sequence
  A000225 (`0, 1, 3, 7, 15, 31, …`).
* Counterexample hunt for the rigidity claim: we searched all prime powers `p^f, p'^{f'} ≤ 10^4`
  for a collision `p^f = p'^{f'}` with `(p,f) ≠ (p',f')`; none exist, consistent with unique
  factorization and with `anabelEquiv_iff`.
