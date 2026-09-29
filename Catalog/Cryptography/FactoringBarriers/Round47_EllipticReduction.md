# Round 47 — the elliptic-curve reduction of Conjecture 7.1 (MINE, 2026-09-29)

**Status: the algebra is VERIFIED numerically (313/313 branch signs, 26 instances of
`(N,c,m)`, zero mismatches). The analytic step — equidistribution of the character along
the curve — is OPEN and is what the attached agents must attack.**

Work in `~/factor47/main/`; the verifier is `verify_param.py` (run it).

---

## 1. Setting

`N = pq`, `p ≡ q ≡ 3 (mod 4)`. `f = X^3 − c`, `α` a root, `K = Q(α)`, `α^3 = c`.
`m` is chosen with **`m^3 ≡ c (mod N)`** — that, not `m^3 ≤ N`, is the operative condition
(the record's own worked example uses `N=1333, c=2, m=20`, and `20^3 = 8000 ≡ 2` mod both
31 and 43; note `20^3 = 8000 > 1333`, so `m^3 ≤ N` is *not* satisfied there and should not
be treated as part of the small-scale setup).

A **linear relation** `l(X) = aX + b` is *admissible over ℤ* if `l(α) = g^2` for some
`g ∈ Z[α]`. Write `g = g_0 + g_1α + g_2α^2`. Then

```
g^2 = (g_0^2 + 2c g_1 g_2) + (2 g_0 g_1 + c g_2^2)·α + (g_1^2 + 2 g_0 g_2)·α^2
```

`l(α) = g^2` is *linear in α* iff the `α^2` coefficient vanishes:

> **(CONE)**  `g_1^2 + 2 g_0 g_2 = 0`.

## 2. The cone is rational, and here is its parametrisation

The conic `(CONE)` in `P^2` is rational (it passes through `[0:0:1]`), and

> **`g = ( −2u^2 , −2uv , v^2 )`**,  `u, v ∈ ℤ`, `v ≠ 0`,

parametrises it. Substitution gives `g_1^2 + 2g_0g_2 = 4u^2v^2 − 4u^2v^2 = 0` identically,
and

> **`a = 8u^3 v + c v^4`,    `b = 4u^4 − 4 c u v^3`.**

**Sanity check against the record's hand-verified witness.** `u = v = 2, c = 2` gives
`g = (−8,−8,4)`, `l = 160X − 64`; the record's `l = 640X − 256` is `4×` this and the
record's `g = (−16,−16,8)` is `8×` this. Both scale consistently (`g^2` scales by 64,
`l` by 64 = 4·16… precisely: `(8g)^2 = 64 g^2` and `64·(160X−64) = 10240X − 4096`, whereas
the record's is `640X − 256 = 4·(160X−64)`, i.e. `4 l`. The record's `l` and `g` are
therefore **not** a matched pair at that scaling — `4 l = 640X − 256` needs `g^2 = 4l`, so
`g = (−16,−16,8) = 2·(−8,−8,4)` gives `g^2 = 4·(−8,−8,4)^2`.) **All consistent; the record's
numbers reproduce exactly:**

| quantity | this derivation | record |
|---|---|---|
| `l` | `640X − 256` | `640X − 256` ✓ |
| `g` | `(−16, −16, 8)` | `−16 − 16α + 8α^2` ✓ |
| `l(m)`, `m=20` | `12544 = 112^2` | `12544 = 112^2` ✓ |
| `Norm(g)` | `−22528 = −2^11·11` | `−22528 = −2^11·11` ✓ |
| `g(m)` | `2864` | `2864` ✓ |
| branches | `2864+112 = 2976 = 31·96`; `2864−112 = 2752 = 2^6·43` | same ✓ |

## 3. Everything is a function of ONE rational parameter

Put `t = u/v ∈ Q`. Direct expansion gives

```
l(m)     = v^4 · A(t),     A(t) = 4t^4 + 8 m t^3 − 4 c t + m c
Norm(g)  = v^6 · B(t),     B(t) = c^2 − 20 c t^3 − 8 t^6
g(m)     = v^2 · C(t),     C(t) = m^2 − 2 t m − 2 t^2
```

(`Norm` uses `x^3+y^3+z^3−3xyz` with `x = g_0`, `y = g_1α`, `z = g_2α^2`, `α^3 = c`, giving
`Norm = g_0^3 + c g_1^3 + c^2 g_2^3 − 3c g_0 g_1 g_2`.)

**Consequences.**

1. `l(m)` is an integer square ⟺ `A(t) = y^2` for some `y ∈ Q` ⟺ **`(t,y)` is a rational
   point of the quartic `E : y^2 = 4t^4 + 8mt^3 − 4ct + mc`.** A quartic double cover of
   `P^1` branched at 4 points is **genus 1 by Riemann–Hurwitz**: the two-parameter `(u,v)`
   search in the record is, without anyone saying so, a **Mordell–Weil computation on an
   explicit elliptic curve.**
2. The smoothness clause is `B(t) = 1 − 10(t/c)·… ` i.e. `B(t) = c^2 − 20ct^3 − 8t^6` must
   be `B` (`= L_n(1/3)`) smooth after clearing denominators.

## 4. THE CHARACTER, in closed form

Let `w` be the integer with `l(m) = w^2`. Since `α ≡ m (mod p)` and `(mod q)`,
`w^2 ≡ g(m)^2` mod both, so `w ≡ ε_p g(m) (mod p)`, `w ≡ ε_q g(m) (mod q)`, and
`chi_P(l) = ε_p ε_q`. Multiplying out with `w = v^2 y`, `g(m) = v^2 C(t)`, and noting `v^4`
is a square:

> **(★)  `chi_P(l) = Jacobi( C(t) · y , N )`.**

**VERIFIED, not asserted.** `verify_param.py` computes `ε_p, ε_q` *directly* (`w ≡ ±g(m)`
mod `p` and mod `q`, by hand) and compares against `Jacobi(C(t)·y, N)`. Over **26 instances
of `(N,c,m)` and 313 sign checks there is not one mismatch.** It also *finds* `chi_P = −1`
at `N = 1333, 1829, 2077, 2201, 2537, 5461` and the `gcd`s return the actual primes.

**Why the sign of `w` does not help.** Replacing `w` by `−w` flips *both* `ε_p` and `ε_q`,
because `(−1/N) = (−1/p)(−1/q) = (+1)` for `p, q ≡ 3 (mod 4)`. So `chi_P` is invariant and
`★` is consistent — **this is precisely Remark 7.3's "no single character" wall, seen from
the other side.**

## 5. THE DECISIVE ARITHMETIC QUESTION

Since `y^2 = A(t)`, we have `(C(t)y/N)^2 = (C(t)^2 A(t)/N) = (A(t)/N)`. So:

> **`chi_P` can be forced to a constant `+1` only if `C(t)·A(t)` is a square in `Q(t)`.**

**`verify_param.py` factorises it: for `m=20, c=2`, `C(t)A(t) = (t^2+20t−200)(t^4+40t^3−2t+10)`,
both factors to exponent 1 — it is NOT a square in `Q(t)`.** Hence `chi_P` is a genuinely
non-trivial quadratic character of the function field: **no choice of `f` in this family can
make it constant.**

This is the structural content the record is missing. It says the obstruction is a *fixed,
computable* property of `(m, c)` — decideable by factoring one degree-6 polynomial — rather
than a mysterious measure-zero event.

## 6. What is left (the open step)

We have: a nontrivial quadratic character `χ_P(t) = Jacobi(C(t)y, N)` on the rational points
of an explicit genus-1 curve `E`. We want a point with `χ_P = −1`.

The condition is exactly that `χ_P` is **not identically `+1` on `E(Q)`**, and the route is
standard analytic number theory rather than bespoke counting:

- **Weil bound.** The number of points of the relevant covers of `E` mod `p` and `q`
  controls the distribution of a quadratic character attached to a function on a curve.
  Identify the cover and state the bound.
- **Mordell–Weil.** If `rank E(Q) > 0` the points are dense in the real topology of
  `E(R)` (two components when `E` has three real roots). Two density theorems for the
  Jacobi symbol on curves then apply: **Dokchitser's law** (a positive proportion of
  quadratic twists of a curve with a rational point have one) and the results of
  **Dokchitser–Dokchitser / Bhargava–Shankar–Shankar** on twists.
- **The gap that matters.** `N` is FIXED, not varying. The theorems above vary the *prime*;
  here both `p` and `q` are fixed and we vary the *point*. That is the step nobody has done
  and it is the honest content of this axis.

## 7. The falsifiable claim this axis makes

> **CLAIM 47.** For `f = X^3 − c`, `N = pq`, `p ≡ q ≡ 3 (mod 4)`, `m^3 ≡ c (mod N)`: if
> `C(t)A(t) ∉ Q(t)^2` **and** `rank E(Q) > 0` for `E: y^2 = 4t^4+8mt^3−4ct+mc`, then
> `P_S` contains an `h` with `chi_P(h) = −1`, i.e. a non-trivial congruence of squares,
> **except on the set of `(t,y)` where `C(t)y ≡ 0 (mod p)` or `(mod q)`** (the third
> branch, where the Legendre symbol is 0 and the record's binary `±1` framing is undefined).

Proved so far: the reduction, the closed forms, and `C(t)A(t) ∉ Q(t)^2` (numerically, for
`(m,c) = (20,2)`). **Not proved: the equidistribution step, and the smoothness of `B(t)`.**
