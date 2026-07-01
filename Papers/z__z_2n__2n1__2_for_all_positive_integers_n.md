# Computational Evidence: β(Z₂ × Z_{2ⁿ})

We study β(G), the minimum number of elements of a finite poset whose
order-automorphism group is isomorphic to G, for the family G = Z₂ × Z_{2ⁿ}.
The mission conjecture is β(Z₂ × Z_{2ⁿ}) = 2^{n+1} + 2 for **all** n ≥ 1.

## 1. Exhaustive small-case search

We enumerated **every labelled partial order** on k elements (reflexive,
antisymmetric, transitive relations) and computed the full order-automorphism
group of each by brute force over all k! permutations, classifying the group by
(order, abelian?, multiset of element orders).

Labelled poset counts used (OEIS A001035): k = 0,1,2,3,4,5 → 1, 1, 3, 19, 219, 4231.

### Target n = 1: G = Z₂ × Z₂ (Klein four-group), formula predicts 6

| k | any poset with Aut ≅ Z₂ × Z₂ ? |
|---|--------------------------------|
| 1 | none |
| 2 | none |
| 3 | none |
| 4 | **YES** |

Witness at k = 4: the complete bipartite poset K_{2,2} with covering relations
0 < 2, 0 < 3, 1 < 2, 1 < 3 (minimal elements {0,1}, maximal elements {2,3}).
Its automorphism group is S₂ × S₂ ≅ Z₂ × Z₂ (independently swap the two minimal
elements and the two maximal elements; levels cannot be exchanged).

**Conclusion: β(Z₂ × Z₂) = 4.**  The formula's prediction of 6 is wrong at n = 1.

### Target n = 2: G = Z₂ × Z₄, formula predicts 10

Signature of Z₂ × Z₄: order 8, abelian, element orders {1,2,2,2,4,4,4,4}.

| k | any poset with Aut ≅ Z₂ × Z₄ ? |
|---|--------------------------------|
| 1 | none |
| 2 | none |
| 3 | none |
| 4 | none |
| 5 | none |

So β(Z₂ × Z₄) ≥ 6.  (The exact value requires searching k ≥ 6, which exceeds the
naive enumeration budget; but the ≥ 6 bound already shows the small cases behave
very differently from the n ≥ 3 regime, consistent with n = 2 being genuinely
exceptional.)

## 2. The Lagrange obstruction

A poset on k points has automorphism group embedding into the symmetric group
S_k, so |Aut| divides k!.  For |G| = 4 this forces 4 ∣ k!, i.e. k ≥ 4 — matching
the search exactly and giving a clean, non-computational lower bound β(Z₂×Z₂) ≥ 4.

More generally, for |G| = 2^{n+1} the bound reads 2^{n+1} ∣ k!, a 2-adic valuation
condition: k must be large enough that k! absorbs 2^{n+1}.  By Legendre's formula
v₂(k!) = k − s₂(k) (s₂ = binary digit sum), the least such k grows only linearly in
n, far below 2^{n+1} + 2.  So the divisibility obstruction is very slack for large
n — the true content of the paper's theorem for n ≥ 3 is a *construction* forcing
the automorphism group to be small, not a counting obstruction.

## 3. Summary table

| n | G           | formula 2^{n+1}+2 | true / bound (search) |
|---|-------------|-------------------|-----------------------|
| 1 | Z₂ × Z₂     | 6                 | **4** (exact)         |
| 2 | Z₂ × Z₄     | 10                | ≥ 6                   |

The formula is **refuted at n = 1**.  This is the result formalized in
`BetaKleinFour.lean` (β = 4, both bounds), supported by the general Lagrange
lower-bound framework in `PosetRealization.lean`.
