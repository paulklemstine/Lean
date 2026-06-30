# Computational Evidence — Concrete Weil/Tate Pairings

This note records the small-case computations that motivated and sanity-checked
the two pairing constructions in `WeilPairingConcrete.lean` and
`WeilPairingConcreteSecurity.lean`.

## 1. The determinant (Weil) pairing on `(ℤ/5)²`

Exponent map `wd(p,q) = p₁·q₂ − p₂·q₁` (so `e(p,q) = ζ^{wd(p,q)}`):

| `p`     | `q`     | `wd(p,q)` mod 5 | note                          |
|---------|---------|-----------------|-------------------------------|
| (1,0)   | (0,1)   | 1               | basis pairing generates `μ₅`  |
| (0,1)   | (1,0)   | 4 = −1          | antisymmetry `e(q,p)=e(p,q)⁻¹`|
| (2,1)   | (2,1)   | 0               | alternating `e(p,p)=1`        |
| (1,1)   | (2,3)   | 1               | generic bilinear value        |

Observations confirmed:
* **Alternating**: `wd(p,p) = 0` for every sampled `p`.
* **Antisymmetric**: `wd(p,q) + wd(q,p) = 0`.
* **Nondegenerate**: testing an unknown `p` against `(0,1)` and `(1,0)` returns
  `p₁` and `−p₂`, so `e(p,·)≡1 ⇒ p = 0`.

## 2. Fixed-slot degeneracy of the symmetric (Weil) pairing

For any nonzero `g`, `wd(g,g) = 0`, i.e. `e(g,g) = 1` with `g ≠ 0`.  Hence the
"nondegenerate against a fixed generator" property used by the BLS-unforgeability
reduction **fails** for the symmetric pairing — the counterexample is `a = g`
itself.  This drove the switch to a non-alternating pairing for the security
file.

## 3. The Tate-like pairing `t(a,b)=ζ^{a·b}` on a prime field

On `ℤ/7`, take generator `g = 3`.  The MOV self-pairing exponent is `g² = 2`.
Additive multiples of `2` mod 7:

`[0, 2, 4, 6, 1, 3, 5]`  — all 7 residues, so `addOrderOf 2 = 7`.

Therefore `orderOf (t g g) = 7`, the full field size, which is exactly the
quantitative input that lets the MOV reduction recover the discrete log on the
whole range `[0,7)`.  (Caution: the *multiplicative* powers of `2` mod 7 are
`[1,2,4,1,2,4,…]` of order 3 — irrelevant here, since the target group is the
*additive* `ℤ/7` written multiplicatively via `ofAdd`.)

Over a prime field `t(a,g)=1 ⇒ a·g = 0 ⇒ a = 0` for `g ≠ 0` (no zero divisors),
so fixed-slot nondegeneracy holds and BLS binding/unforgeability instantiate.

## Counterexample hunt

* Fixed-slot nondegeneracy on the **composite** modulus `ℤ/6` with the Tate
  pairing fails: `t(2,3) = ζ^{6} = ζ^{0} = 1` although `2 ≠ 0`.  This is why the
  prime-field hypothesis `[Fact p.Prime]` is load-bearing and stated explicitly.
* No counterexample was found to alternation, antisymmetry, or full bilinear
  nondegeneracy of the determinant pairing across all sampled inputs.
