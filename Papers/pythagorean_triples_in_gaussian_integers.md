# Computational Evidence — Pythagorean Triples in Z[i]

Companion to `Logic/GaussianPythagorean.lean` and
`Logic/GaussianQuaternionBridge.lean`.

## 1. Small-case calculations

Gaussian integer `i = ⟨0,1⟩` satisfies `i^2 = -1` (checked by `decide`).

**Null (isotropic) triples** — solutions of `a^2 + b^2 = 0` with `a,b ≠ 0`:

| a | b | a^2+b^2 | note |
|---|---|---------|------|
| 1 | i  | 0 | `b = i·a` |
| 1 | -i | 0 | `b = -i·a` |
| 2 | 2i | 0 | scalar multiple |
| 1+i | 1-i | 0 | `(1+i)^2+(1-i)^2 = 2i + (-2i) = 0` |

This already shows the form `x^2+y^2` is **isotropic over Z[i]**, in contrast to
ℤ where the only solution is `(0,0)`. (Formalised: `gaussian_isotropic`,
`int_anisotropic`.)

The general isotropy pattern `a^2+b^2 = 0 ↔ a = ±i·b` was checked on the sample
above and proved in general (`gaussian_sq_add_sq_eq_zero_iff`).

## 2. Generative parametrisation (`s^2-t^2, 2st, s^2+t^2`)

Over ℤ ⊂ Z[i]:

| s | t | (s^2-t^2, 2st, s^2+t^2) |
|---|---|--------------------------|
| 2 | 1 | (3, 4, 5) |
| 3 | 2 | (5, 12, 13) |
| 4 | 1 | (15, 8, 17) |

All embed into Z[i] under `ℤ ↪ Z[i]` (`int_triple_to_gaussian`), reproducing the
classical triples that appear in `Pythagorean.BerggrenCompleteness`.

Over genuine Gaussian parameters, e.g. `s = 1+i, t = 1`:
`s^2 = 2i`, so `(s^2-t^2, 2st, s^2+t^2) = (2i-1, 2+2i, 2i+1)` and indeed
`(2i-1)^2 + (2+2i)^2 = (2i+1)^2` (each side `= 4i - 3`), a genuinely Gaussian
triple. (Identity proved generically: `param_identity`.)

## 3. Hyperbolic linearisation (field case)

Change of variables `(a,b) ↦ (p,q) = (a+ib, a-ib)` turns `a^2+b^2` into `p·q`.
Sample over the Gaussian rationals ℚ(i): `p=q=c` gives `a=c, b=0`; `p=c^2, q=1`
gives the parametrised non-degenerate solution. Every factorisation `p·q=c^2`
yields a triple and conversely (`triple_classification`).

## 4. Quaternion bridge — Brahmagupta–Fibonacci ⊂ Euler

`gaussToQuat (a+bi) = (a,b,0,0) ∈ ℍ(ℤ)`. Norm check:
`normSq(a,b,0,0) = a^2+b^2+0+0 = N(a+bi)`. Multiplicativity of quaternion norm
restricts to the two-square identity:

`(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2`

verified for `(a,b,c,d) = (2,1,3,2)`: LHS `= 5·13 = 65`,
RHS `= (6-2)^2 + (4+3)^2 = 16+49 = 65`. ✓ (Formalised: `brahmagupta_fibonacci`,
`gaussian_norm_mul_via_quaternion`.)

## 5. Counterexample hunt

- Claim "Z[i] is anisotropic": **FALSE**, refuted by `(1,i)` above — this is the
  whole point and is what distinguishes the Gaussian from the integer theory.
- Claim "the framing `N(a)^2 = N(b)^2 + N(c)^2 for a Gaussian Pythagorean triple
  with a^2 = b^2 + c^2`": **FALSE** in general; e.g. the null triple `(i,1,0)`
  has `N(i)=1, N(1)=1, N(0)=0` and `1 ≠ 1+0`... actually equal here, but
  `(2i-1, 2+2i, 2i+1)` has norms `5, 8, 5` and `5 ≠ 8 + 5`. So the naive
  "norm satisfies the Pythagorean relation" reading of the brief is incorrect;
  the correct invariant is multiplicativity `N(z^2) = N(z)^2`, used in the
  quaternion bridge. This motivated stating the *factorisation/linearisation*
  results instead.

All numeric checks above were reproduced inside Lean via `decide` / `ring` /
`norm_num` in the two source files; nothing here relies on external scripts.
