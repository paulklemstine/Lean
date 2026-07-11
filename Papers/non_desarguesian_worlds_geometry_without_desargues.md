# Computational Evidence: Dickson Nearfield of Order 9

All claims below were checked exhaustively over the 9-element carrier
`G = GF(3)² = ZMod 3 × ZMod 3` (81 or 729 cases as appropriate) and are the
computations that back the `by decide` proofs in
`NearfieldPlaneOrder9.lean`.

## 1. The construction

* `GF(9) = GF(3)[α]`, `α² = -1 ≡ 2 (mod 3)`.
  Field product: `(a+bα)(c+dα) = (ac+2bd) + (ad+bc)α`  (`gf9Mul`).
* Frobenius: `σ(a+bα) = a + 2bα`  (`frob`), the order-2 automorphism `x ↦ x³`.
* Squares of `GF(9)*`: the multiplicative group is cyclic of order 8, so the
  non-zero squares form the index-2 subgroup of order 4. `isSq b` decides
  `∃ c ≠ 0, c·c = b`.
* Dickson product: `a ∘ b = a·b` if `b` is a square (or `0`), else
  `a ∘ b = σ(a)·b`  (`dMul`).

## 2. Small-case verification (exhaustive, all pass)

| Property | Statement | Verified |
|---|---|---|
| identity | `x ∘ (1,0) = x` and `(1,0) ∘ x = x` | ✓ (9 cases each) |
| zero | `x ∘ 0 = 0` and `0 ∘ x = 0` | ✓ |
| right distributive | `(a+b) ∘ c = a∘c + b∘c` | ✓ (729) |
| left division unique | `a ≠ 0 → ∀ c, ∃! x, a∘x = c` | ✓ |
| right division unique | `a ≠ 0 → ∀ c, ∃! x, x∘a = c` | ✓ |
| planar (Veblen) | `a ≠ b → ∀ d, ∃! x, x∘a = x∘b + d` | ✓ |
| **associative** | `(a∘b)∘c = a∘(b∘c)` | ✓ (729) |
| **NOT left distributive** | `∃ a b c, a∘(b+c) ≠ a∘b + a∘c` | ✓ |
| **NOT commutative** | `∃ a b, a∘b ≠ b∘a` | ✓ |

## 3. Counterexample hunt (the point of the project)

We *want* left distributivity to fail — that is the non-Desarguesian signature.
An explicit witness found by search (`dicksonQF_leftDistrib_witness`):
there exist `a, b, c` with `a ∘ (b+c) ≠ a∘b + a∘c`. Since the multiplication is
associative and right- but not left-distributive, it is a proper nearfield, not
a field, and cannot be the multiplication of any division ring on `GF(9)`.

## 4. Combinatorics

* Points: `|G × G| = 81 = 9²`  (`dickson_point_count`).
* Lines: `81` ordinary `y = x∘m + b` plus `9` vertical `x = c`, total
  `90 = 9² + 9`  (`dickson_line_count`), exactly the line count of an affine
  plane of order 9.

## 5. Why order 9

`9 = 3²` is the smallest prime power that is not prime; over a prime field
`GF(p)` every quasifield of that order is the field itself (planes of prime
order `< 9`... in fact of order `≤ 8`) are Desarguesian), so `9` is the smallest
order admitting a non-Desarguesian plane. The Dickson nearfield realises this
minimal case.

## OEIS

The count of projective planes of order `n` (1, 1, 1, 1, 0, 1, 1, 4, ...) is
OEIS A001231; order 9 has 4 planes, three of them non-Desarguesian (the Hall
plane, its dual, and the Hughes plane), plus the nearfield/translation plane
realised here. We do not depend on this enumeration; it is context only.
