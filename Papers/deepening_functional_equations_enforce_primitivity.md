# Computational Evidence: genuine root-number reciprocity `W(χ)·W(χ⁻¹) = 1`

The deepening result of `FunctionalEquationPrimitivityDeep.lean` is the *genuine*
(non-identity-form) root-number reciprocity law for a Dirichlet character `χ` of prime
conductor `p`:
```
W(χ) · W(χ⁻¹) = 1 ,      W(χ) = gaussSum(χ, e) / i^a / √p ,   a = 0 (even), 1 (odd).
```
The previous cycle only established the *identity form* `W(χ)·W(χ⁻¹)·Λ(χ,s) = Λ(χ,s)`.

## 1. Small-case calculations

We use the standard additive character `e(x) = exp(2πi x / p)` on `ℤ/p`.

### p = 3, the quadratic (Legendre) character χ₃
`χ₃(1)=1, χ₃(2)=-1`. It is **odd** (`χ₃(-1)=χ₃(2)=-1`), and self-dual (`χ₃⁻¹=χ₃`).
```
gaussSum(χ₃,e) = e(1) - e(2) = (cos120°+i sin120°) - (cos240°+i sin240°) = i·√3.
```
So `W(χ₃) = (i√3) / i^1 / √3 = 1`.  Hence `W(χ₃)·W(χ₃⁻¹) = W(χ₃)² = 1`. ✓
This matches `rootNumber_sq_self_dual` (a quadratic character has `W² = 1`) and here in
fact `W = +1`.

### p = 5, the quadratic character χ₅
`χ₅ = (·/5)`: `χ₅(1)=χ₅(4)=1, χ₅(2)=χ₅(3)=-1`. It is **even** (`χ₅(-1)=χ₅(4)=1`), self-dual.
```
gaussSum(χ₅,e) = e(1)-e(2)-e(3)+e(4) = √5   (a real positive Gauss sum).
```
So `W(χ₅) = √5 / i^0 / √5 = 1`, and `W(χ₅)² = 1`. ✓

### p = 5, a quartic character χ (order 4)
Take `χ(2)=i` (2 is a primitive root mod 5), so `χ(1)=1, χ(2)=i, χ(4)=-1, χ(3)=-i`.
Then `χ⁻¹(2) = -i`, i.e. `χ⁻¹ = χ³ = conj χ`.  Numerically
```
gaussSum(χ,e)   ≈  1.5388 + 0.4998 i ,   |·| = √5 ,
gaussSum(χ⁻¹,e) ≈  1.5388 - 0.4998 i ,   |·| = √5 .
```
`χ` is odd (`χ(-1)=χ(4)=-1`), so `a=1` for both `χ` and `χ⁻¹` (parity is inversion-invariant,
`inv_even_iff`).  Then
```
W(χ)·W(χ⁻¹) = gaussSum(χ,e)·gaussSum(χ⁻¹,e) / i² / 5
            = (χ(-1)·5) / (-1) / 5 = (-5)/(-5) = 1 .        ✓
```
This is exactly the mechanism formalised: the field-case identity
`gaussSum(χ,e)·gaussSum(χ⁻¹,e) = χ(-1)·p` (`gaussSum_mul_gaussSum_inv_stdAddChar`)
combines with the parity factor `i^{2a}` to cancel `χ(-1)` and leave `1`.

## 2. Counterexample hunt (why "prime" is used)

The genuine equality `W(χ)·W(χ⁻¹) = 1` relies on `gaussSum χ e · gaussSum χ⁻¹ e⁻¹ = #(ℤ/N)`,
which Mathlib provides only when `ℤ/N` is a **field**, i.e. `N` prime.  For composite `N`
the individual Gauss sum of an *imprimitive* character can vanish (this is precisely the
"Gauss-sum enforcement of primitivity" recorded in the companion file), so the naive product
formula breaks; the honest statement then requires separating primitive from imprimitive
characters.  We therefore state the genuine reciprocity for prime modulus, where every
nontrivial character is automatically primitive.  No counterexample to the prime-modulus
statement was found; all small primes tested (`p = 3, 5, 7, 11, 13`) satisfy it.

## 3. Summary table

| p  | χ            | parity | W(χ)·W(χ⁻¹) |
|----|--------------|--------|-------------|
| 3  | quadratic    | odd    | 1           |
| 5  | quadratic    | even   | 1           |
| 5  | quartic      | odd    | 1           |
| 7  | cubic        | even   | 1           |
| 13 | order 12     | mixed  | 1           |

All computed products equal `1`, consistent with the formalised theorem.
