# Computational Evidence: Subadditivity & the Correlated-Erasure Landauer Saving

This note records the small-case checks that preceded the formal development in
`Catalog/Physics/LandauerSubadditivity.lean`.

## 1. Mutual information as a relative entropy

For a joint PMF `p` on `X × Y` with marginals `pX`, `pY`, the mutual information is
`I(X;Y) = D(p ‖ pX⊗pY) = Σ_{x,y} p(x,y) · log( p(x,y) / (pX(x)·pY(y)) )`,
and the decomposition identity is `I(X;Y) = H(X) + H(Y) − H(X,Y)`.

## 2. Diagonal (perfectly correlated) two-bit memory

`p(b1,b2) = 1/2` if `b1 = b2`, else `0`.

| (b1,b2)        | p     | contribution to H |
|----------------|-------|-------------------|
| (false,false)  | 1/2   | −(1/2)·log(1/2)   |
| (false,true)   | 0     | 0                 |
| (true,false)   | 0     | 0                 |
| (true,true)    | 1/2   | −(1/2)·log(1/2)   |

- Marginals: `pX(b) = pY(b) = 1/2` (uniform).  → `H(X) = H(Y) = log 2`.
- Joint entropy: `H(X,Y) = 2 · (−(1/2)·log(1/2)) = log 2`.
- Mutual information: `I = log 2 + log 2 − log 2 = log 2 > 0`.
- Landauer saving: `kT·(H(X)+H(Y)) − kT·H(X,Y) = kT·I = kT·log 2 > 0`.

So joint erasure of a copied bit saves exactly one Landauer quantum `kT·log 2`.
Formalised as `mutualInfo_perfectlyCorrelated` and
`landauer_perfectlyCorrelated_strict_saving`.

## 3. Independent two-bit memory (sanity / equality case)

`p = pX⊗pY`  ⇒  `I = D(p‖p) = 0`  ⇒  joint cost = separate cost. No saving.
Formalised as `mutualInfo_indep_eq_zero`.

## 4. Subadditivity holds without strict positivity

A deterministic correlation has `p(x,y) = 0` on the off-diagonal, so the product of
marginals does **not** have full support is false here (marginals are uniform, full
support), but more general deterministic couplings *do* make `pX⊗pY` vanish where `p`
does. The strict-positivity Gibbs inequality already in the catalog is therefore
insufficient; the absolute-continuity strengthening `relativeEntropy_nonneg'` was needed
and is what gives subadditivity in full generality (`shannonEntropy_subadditive`).

## 5. Gibbs pointwise bound check

The backbone inequality `p·log(p/q) ≥ p − q` was checked at the boundary:
- `p = 0`: LHS `= 0 ≥ −q` since `q ≥ 0`. ✓
- `p,q > 0`: equivalent to `log(q/p) ≤ q/p − 1` (`Real.log_le_sub_one_of_pos`). ✓
Summing over the (finite) sample space and using `Σp = Σq = 1` gives `D(p‖q) ≥ 0`.

No counterexamples were found to any claim formalised in the file.
