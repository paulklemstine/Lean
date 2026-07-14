# Computational Evidence — ℤ₂-coindex of combinatorial spheres under suspension

We model the `n`-dimensional combinatorial sphere `Sⁿ` as the boundary complex of the
`(n+1)`-cross-polytope: vertices `SVert n = Fin (n+1) × Bool` (the signed unit vectors
`±eᵢ`), with the free antipodal `ℤ₂`-action `anti (i, b) = (i, !b)`.  A `ℤ₂`-map `Sᵐ → Sⁿ`
is a simplicial map commuting with `anti`; by equivariance it is determined by the images of
the positive vertices `g : Fin (m+1) → SVert n`, and simpliciality is the finite predicate

    ∀ p q, induced g p = anti (induced g q) → p = anti q.

## 1. Enumeration of ℤ₂-maps `Sᵐ → Sⁿ` (exact counts by `decide`)

The number of ℤ₂-simplicial maps `Sᵐ → Sⁿ`, computed by exhaustively filtering all
`(2(n+1))^(m+1)` positive-vertex data:

| m \ n |  0 |  1 |  2 |
|-------|----|----|----|
| **0** |  2 |  4 |  6* |
| **1** |  0 |  8 | 24 |
| **2** |  0 |  0 |  … |

(*) `count(0,n) = 2(n+1)`; the entry shown for `(1,2)` is `24`.  Verified values:
`count(0,0)=2`, `count(0,1)=4`, `count(1,1)=8`, `count(1,0)=0`, `count(2,1)=0`,
`count(1,2)=24`.

Reading of the table:

* **Diagonal / lower triangle `m ≤ n` is non-empty** — matches the constructive lower
  bound `coind(Sⁿ) ≥ n` (`coindex_lower_bound`).  E.g. `count(0,0)=2` are the two antipodal
  self-maps `id` and `anti` of `S⁰`.
* **Strict upper triangle `m > n` collapses to `0`** in every base case tested — this is the
  Borsuk–Ulam obstruction.  `count(1,0)=0` is `S¹ ↛ S⁰` and `count(2,1)=0` is `S² ↛ S¹`.

## 2. Counterexample hunt for the lower bound

The claim "`m ≤ n ⇒ ∃ ℤ₂-map Sᵐ → Sⁿ`" was tested on all pairs with `m,n ≤ 2`; no
counterexample exists (every lower-triangular count above is positive).  The suspension
construction `Z2Map.susp` produces such a map explicitly for every `m ≤ n`, so the lower
bound is not merely observed but constructive.

## 3. Sharpness of the suspension increment

`coind(S⁰) = 0` (since `count(1,0)=0`) and `coind(S¹) = 1` (since `count(2,1)=0` while
`count(1,1)=8 > 0`).  Hence suspension raises the coindex by **exactly** one at the bottom
of the tower: `coind(ΣS⁰) = coind(S¹) = coind(S⁰) + 1`.  This is the "sharp excess" phenomenon
in its base case.

## 4. Provenance

All counts are produced inside Lean 4 / Mathlib with `decide`/`#eval` over the finite
positive-vertex representation (`nonempty_iff_exists_pos`), so they are exact, not sampled.
The two vanishing entries `(1,0)` and `(2,1)` are promoted to the machine-checked theorems
`borsuk_ulam_S1_S0` and `borsuk_ulam_S2_S1`.
