# Computational Evidence — Kernel of the Sign Invariant

Notation: `s = √Q`, eigensystem = list of nonzero eigenvalues stable (as a multiset)
under `α ↦ Q/α`; sign `ε = ∏α / s^d`; `-Q` fixed point = eigenvalue `-s`.
"Old moves" = permutations, insert/delete `(-s,-s)`, even-degree twist `α ↦ -α`.
"Dual-pair moves" = permutations, insert/delete `(β, Q/β)`.

Every number in the tables follows from Lean theorems that build with no `sorry`
(named in brackets). No table entry comes from an unchecked script.

## 1. Small cases: the sign formula `ε = (-1)^{#(-s)}` [`sign_eq`]

| eigensystem | d | #(-s) | ε |
|---|---|---|---|
| `[s]` | 1 | 0 | +1 |
| `[-s]` | 1 | 1 | −1 |
| `[s, -s]` | 2 | 1 | −1 |
| `[2s, s/2]` | 2 | 0 | +1 |
| `[3s, s/3]` | 2 | 0 | +1 |
| `[s, s, s]` | 3 | 0 | +1 |
| `[s, -s, -s]` | 3 | 2 | +1 |
| `[n s, s/n, s, …, s]` | k+2 | 0 | +1 [`fam_sign`] |

## 2. Counterexample hunt for completeness of the old moves

| degree d | completeness of old moves? | witness |
|---|---|---|
| 0 | holds | — [`conjectureInDegree_le_one`] |
| 1 | holds | — [`conjectureInDegree_le_one`] |
| 2 | **fails** | `[2s, s/2]` vs `[3s, s/3]` [`not_conjectureInDegree`] |
| 3 | **fails** | `[2s, s/2, s]` vs `[3s, s/3, s]`; also core-free `[s,s,s]` vs `[s,-s,-s]` [`coreFree_odd_counterexample`] |
| 4 | **fails** | `[2s, s/2, s, s]` vs `[3s, s/3, s, s]` |
| d ≥ 2 | **fails** | `fam s 2 (d-2)` vs `fam s 3 (d-2)` |

Exact boundary: completeness holds in degree `d` **iff `d ≤ 1`** [`conjectureInDegree_iff`].

## 3. How many move classes does one sign class contain?

* Sign class `ε = +1`, degree 2: the systems `[n s, s/n]` (`n = 2, 3, 4, …`) are pairwise
  not related by old moves [`fam_moves_iff`], so there are **infinitely many** old-move classes.
* Core-free systems `[s]^a [-s]^b`, `a + b = d` (follows from `moves_iff_core`):

| d | core-free systems | sign classes | old-move classes |
|---|---|---|---|
| 1 | 2 | 2 | 2 |
| 2 | 3 | 2 | 2 |
| 3 | 4 | 2 | 4 |
| 4 | 5 | 2 | 2 |
| 5 | 6 | 2 | 6 |

  (odd `d`: `a` is an invariant, so there are `d + 1` classes; even `d`: only the
  parities matter, so there are 2 classes) [`complete_coreFree_even`, `Moves.relO`].
* With **dual-pair moves**, every degree has exactly 2 classes per degree (one for each sign)
  [`sign_eq_iff_dualMoves`]; the normal forms are `[]`, `[s,-s]` (even degree) and
  `[s]`, `[-s]` (odd degree) [`dual_normal_form`].

## 4. OEIS

The sequences in this problem (2, 2, 4, 2, 6, … for core-free old-move classes) are
elementary (`d+1` for odd `d`, `2` for even `d`). We did not run an OEIS search.
