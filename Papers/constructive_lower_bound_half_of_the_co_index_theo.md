# Computational Evidence — Join law for the ℤ₂-coindex

This cycle formalizes the **join bifunctor** on free ℤ₂-complexes and the sharp join law on the
octahedral tower. The claims are small, exact, and combinatorial, so the evidence below is a set of
finite calculations that fully determine the general statements.

## 1. The model

- `Oct n = Sⁿ` is the boundary of the `(n+1)`-cross-polytope; its vertices are the `2(n+1)` signed
  axes `±e₀,…,±eₙ`, i.e. `SVert n = Fin (n+1) × Bool`.
- The join `Oct m ⋆ Oct n` has vertex set `SVert m ⊕ SVert n`, of size `2(m+1) + 2(n+1)`.
- Concatenating the axis sets gives `(m+1) + (n+1) = (m+n+1)+1` axes, i.e. exactly `Oct (m+n+1)`.

| m | n | #axes of Oct m ⋆ Oct n | axes of Oct(m+n+1) | m+n+1 |
|---|---|------------------------|--------------------|-------|
| 0 | 0 | 1+1 = 2                | 2                  | 1     |
| 1 | 0 | 2+1 = 3                | 3                  | 2     |
| 1 | 1 | 2+2 = 4                | 4                  | 3     |
| 2 | 1 | 3+2 = 5                | 5                  | 4     |

The axis count matches `Oct (m+n+1)` in every case, giving the vertex-level bijection
`octJoinEquiv : Oct m ⋆ Oct n ≅ Oct (m+n+1)` used in the proof.

## 2. Coindex values (from `coind_Oct : coind (Oct n) = n`)

Using the base-file criterion `Nonempty (Z2Map m n) ↔ m ≤ n` (Borsuk–Ulam upper bound + constructive
lower bound), `coind (Oct n) = n`. Then the join law predicts:

| m | n | coind(Oct m) | coind(Oct n) | predicted coind(Oct m ⋆ Oct n) = m+n+1 |
|---|---|--------------|--------------|-----------------------------------------|
| 0 | 0 | 0            | 0            | 1  (S⁰ ⋆ S⁰ = S¹)                        |
| 1 | 0 | 1            | 0            | 2  (S¹ ⋆ S⁰ = S² : one suspension)       |
| 1 | 1 | 1            | 1            | 3  (S¹ ⋆ S¹ = S³)                        |
| 2 | 3 | 2            | 3            | 6  (S² ⋆ S³ = S⁶)                        |

This is exactly `S^m ⋆ S^n = S^{m+n+1}`, the classical join-of-spheres formula, and is verified as
`coind_octJoin : coind (Oct m ⋆ Oct n) = m + n + 1`.

## 3. Suspension as the special case `L = S⁰`

`coind (Oct m ⋆ Oct 0) = m + 1` (`coind_join_S0`), recovering the suspension jump proved in the base
tower file: joining with `S⁰` is one suspension.

## 4. Monoid structure

`coind_join_comm`, `coind_join_left`/`coind_join_right` (`= m+n+k+2`), and `coind_join_assoc` confirm
the octahedral spheres form a commutative, associative join-monoid at the level of the coindex — the
numerical shadow of `Oct m ⋆ Oct n ≅ Oct (m+n+1)`.

## 5. Counterexample hunt (scope of the sharp law)

The *sharp equality* `coind(K ⋆ L) = coind(K) + coind(L) + 1` for **arbitrary** free ℤ₂-complexes
requires an upper-bound obstruction (equivariant cohomology) not available in this purely
combinatorial model. We therefore prove:
- the **lower bound** `coind(K ⋆ L) ≥ coind(K) + coind(L) + 1` constructively for all `K, L`
  (`coindex_join_lower_bound`); and
- the **exact** law on the octahedral tower, where `coind = dim` makes the upper bound automatic.
No counterexample to the lower bound exists (it is proved); the equality is left open in full
generality and settled here on the tower.
