# Computational Evidence

## Setup

Two matroids `M₁, M₂` on a common ground set `E` (edges of a coloured graph).
`rᵢ` is the rank of `Mᵢ`.  Objective
```
g(A) = r₁(A) + r₂(E \ A),   A ⊆ E.
```
By matroid-intersection weak duality, the maximum size of a common independent set
(= a total rainbow forest) is `≤ min_A g(A)`, so `min_A g(A) < t` is an obstruction to a
rainbow forest of size `t`.  The original conjecture claims the minimizing `A` is
**unique** for a minimal obstruction.

## 1. Small case: both matroids `= U₁,₂` on `E = {0,1}`

`rᵢ(A) = 0` if `A = ∅`, else `1` (indicator of non-emptiness).

| A       | r₁(A) | E\A     | r₂(E\A) | g(A) |
|---------|-------|---------|---------|------|
| ∅       | 0     | {0,1}   | 1       | 1    |
| {0}     | 1     | {1}     | 1       | 2    |
| {1}     | 1     | {0}     | 1       | 2    |
| {0,1}   | 1     | ∅       | 0       | 1    |

Minimum value `1` attained at **two** distinct sets `∅` and `{0,1}`.  With `t = 2`
this is an obstruction with a **non-unique** witness. → refutes uniqueness.

## 2. Small case: both matroids free (`rᵢ(A) = |A|`) on `E = {0,1}`

`g(A) = |A| + |E\A| = |E| = 2` for *every* `A`.  All four subsets are minimizers with
value `2`; with `t = 3` every subset is a witness.  (Degenerate but valid; the `U₁,₂`
example above is non-degenerate since `g` is non-constant.)

## 3. Why the minimizers still have structure (positive result)

Because `X ↦ r₂(E\X)` is submodular whenever `r₂` is (complementation is a lattice
anti-automorphism), `g` is submodular.  For submodular `g` the minimizer family is
closed under `∩` and `∪`:
if `g(A)=g(B)=m` (the minimum) then `g(A∪B)+g(A∩B) ≤ 2m` and both are `≥ m`, forcing
both `= m`.  Hence there is a **unique least** and **unique greatest** minimizer.
This is the correct replacement for the (false) uniqueness claim.

## 4. Counterexample hunt for the *minimal-obstruction* reading

Under the "delete an edge" reading of minimality, deleting an element can only
decrease the intersection number `min_A g(A)`, so once `E` is an obstruction every
subset is too; the only edge-minimal obstruction is `∅`.  Hence the "minimal
obstruction" hypothesis, read via edge deletion, is degenerate and cannot rescue
uniqueness.  See `FUTURE_DIRECTIONS.md` for the discussion.

## Conclusion

The uniqueness conjecture is **false**.  What survives, and is formalized, is:
weak duality (`rainbow_forest_inequality`), submodularity of `g`, the lattice
structure of minimizers, and the existence of unique least/greatest witnesses.
