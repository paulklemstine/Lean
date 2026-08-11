# Computational Evidence — Magma Monoid `Bin(X)` as a transformation monoid

All numbers below were produced by `#eval` inside Lean 4 (mathlib v4.28.0) on
`X = Fin 2`, where `Bin(X)` is the monoid of binary operations under
`(f * g)(a,b) = g(f a b, f b a)`.

## 1. Small-case census, `|X| = 2`

`|Bin(Fin 2)| = 2^(2^2) = 16`.

| quantity | value | code |
|---|---|---|
| elements | 16 | `#eval (univ : Finset Op).card` |
| idempotents (`f * f = f`) | 7 | `filter (fun f => prod2 f f = f)` |
| von Neumann regular elements (`∃ g, f*g*f = f`) | 14 | `filter (fun f => ∃ g, prod2 (prod2 f g) f = f)` |
| units (`∃ g, f*g = 1 ∧ g*f = 1`) | 4 | `filter ...` |
| `f` with `pairmorph f` bijective | 4 | `filter (fun f => Function.Bijective (pairmorph f))` |

The last two rows agree, which is the first (numerical) evidence for
`IsUnit f ↔ Bijective (pairmorph f)`.

The unit count also matches the centralizer prediction: `swap` on `X × X`
(`|X| = n = 2`) is an involution with `n = 2` fixed points and
`m = n(n-1)/2 = 1` transposition, so its centralizer in `Sym(X × X)` has order
`n! · 2^m · m! = 2 · 2 · 1 = 4`. ✓

Likewise `|C_{T(X×X)}(swap)| = n^n · (n^2)^m = 2^2 · 4^1 = 16 = |Bin(X)|`, the
numerical shadow of the isomorphism `Bin(X) ≅ C_{T(X×X)}(swap)ᵐᵒᵖ`.

## 2. Counterexample hunt: is `Bin(X)` a regular monoid?

`T(Y)` is always a regular monoid, so one might expect the same for `Bin(X)`.
It is **false** already for `|X| = 2`: exactly `16 - 14 = 2` elements are
non-regular, namely (writing `((f 0 0, f 0 1), (f 1 0, f 1 1))`)

```
{((0, 1), 1, 0), ((1, 0), 0, 1)}
```

i.e. `XOR` and `XNOR`. Both are *commutative* operations whose off-diagonal
value is never attained on the diagonal — precisely the obstruction isolated by
the criterion below. This is formalized as `xor_not_regular` /
`not_forall_isRegular`.

## 3. Testing the regularity criterion

Conjecture: `IsRegular f ↔ commutativeImage f = diagonalImage f`, equivalently
`∀ x y, f x y = f y x → ∃ z, f z z = f x y`.

```
#eval (univ.filter (fun f => ∀ x y : Fin 2, f x y = f y x → ∃ z, f z z = f x y)).card
-- 14
```

which matches the brute-force regular count 14 exactly (and the two failing
operations are the two non-regular ones found above). The criterion is proved in
full generality (arbitrary `X`, no finiteness) in `Regularity.lean` as
`isRegular_iff_commutativeImage_eq_diagonalImage`.

## 4. The centre, computed by brute force

```
#eval ((univ : Finset Op).filter (fun f => ∀ g : Op, prod2 f g = prod2 g f)).image show4
-- {((0, 0), 1, 1), ((0, 1), 0, 1)}
```

i.e. exactly `leftZero` (`f a b = a`) and `rightZero` (`f a b = b`).  This is the
`n = 2` instance of the theorem `isCentral_iff` proved for arbitrary `X` with at
least two elements.

## 5. Regular elements are not closed under multiplication

```
#eval (((univ : Finset Op) ×ˢ univ).filter
        (fun p => reg p.1 ∧ reg p.2 ∧ ¬ reg (prod2 p.1 p.2))).card
-- 8
```

Eight ordered pairs of regular operations have a non-regular product; one of
them, `f = ((0,0),(1,0))`, `g = ((0,1),(1,1))`, is used as the explicit witness
in the theorem `regular_not_mul_closed`.

## 6. Sequence remarks

`|Bin(Fin n)| = n^(n^2)`: `1, 16, 19683, ...` (A002884-like tower, here
`n^(n^2)`, OEIS A053763-adjacent; the plain sequence `n^(n^2)` is OEIS A002489).
The unit-group orders `n! · 2^(n(n-1)/2) · (n(n-1)/2)!` give
`1, 4, 6·8·6 = 288, ...` for `n = 1, 2, 3`.
No OEIS lookup was performed online; these are direct evaluations.  The unit
counts `4` (n = 2) and `288` (n = 3) are now *theorems*
(`card_units_bin_fin_two`, `card_units_bin_fin_three`), derived from the general
formula rather than from enumeration; the `n = 2` value agrees with the
brute-force census above, which is an independent check of the general proof.
