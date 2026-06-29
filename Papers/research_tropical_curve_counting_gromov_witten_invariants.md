# Functional Equations of the Hodge–Deligne E-Polynomial: Mirror Symmetry and Serre Duality as Index Reflections

**Author:** Aristotle
**Date:** 2026-06-18
**Domain:** Bridges (duality / representation theory ↔ arithmetic geometry)

---

## Abstract

We study an abstract combinatorial model of a Hodge diamond — a complex dimension
`n ∈ ℕ` together with a table of Hodge numbers `h^{p,q} ∈ ℤ` — and the two-variable
**Hodge–Deligne E-polynomial** `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} u^p v^q`
attached to it, evaluated over an arbitrary field `K`. We prove two genuine functional
equations. First, an *unconditional* mirror functional equation
`E(mirror X; u, v) = (-1)^n u^n E(X; u^{-1}, v)`, where `mirror` is the reflection
`(p,q) ↦ (n-p, q)`. Second, a *Serre/Poincaré* functional equation
`E(X; u, v) = (uv)^n E(X; u^{-1}, v^{-1})` valid whenever `X` satisfies Serre duality
`h^{p,q} = h^{n-p,n-q}`. Specialising at `u = v = 1` recovers the Euler characteristic
`χ(X) = Σ (-1)^{p+q} h^{p,q}` (Theorem 1), and the mirror equation degenerates to the
numerical identity `χ(mirror X) = (-1)^n χ(X)` (Theorem 4). The proofs rest on a single
combinatorial principle — reflection of a summation index `p ↦ n - p` — together with
the parity bookkeeping `(-1)^{(n-p)+q} = (-1)^n (-1)^{p+q}` and the exponent bookkeeping
`u^{n-p} = u^n (u^{-1})^p`. All statements are formalised in Lean 4 / Mathlib over an
arbitrary field; this paper gives the mathematical content and proof sketches.

---

## 1. Introduction

The Hodge diamond of a smooth compact Kähler manifold `X` of complex dimension `n`
records the dimensions `h^{p,q} = dim H^q(X, Ω^p_X)` of its Dolbeault cohomology. These
numbers satisfy two fundamental symmetries:

- **Serre duality**, `h^{p,q} = h^{n-p,n-q}`, a half-turn rotation of the diamond; and
- **mirror symmetry** (conjecturally, for Calabi–Yau manifolds), which exchanges a
  manifold with a topologically distinct mirror partner whose diamond is reflected.

A standard way to package the diamond is the **Hodge–Deligne E-polynomial**, a
two-variable generating function whose specialisations recover the Euler characteristic,
the Poincaré polynomial, and (over finite fields) point counts. The purpose of this
paper is to isolate, in a deliberately minimal abstract setting, the precise sense in
which both symmetries are **functional equations** of the E-polynomial, and to show that
both — together with the classical numerical fact `χ(mirror) = (-1)^n χ` — follow from a
single combinatorial move: reflecting a summation index.

Our contribution is fourfold:

1. A field-agnostic definition of the abstract Hodge diamond, its E-polynomial, Euler
   characteristic and total dimension (§2).
2. The mirror functional equation `E(mirror X) = (-1)^n u^n E(X; u^{-1}, v)`, proved
   unconditionally (Theorem 2).
3. The Serre/Poincaré functional equation `E(X) = (uv)^n E(X; u^{-1}, v^{-1})` under
   Serre duality (Theorem 3).
4. The numerical corollary `χ(mirror X) = (-1)^n χ(X)` obtained by specialising at
   `u = v = 1` (Theorems 1 and 4).

Everything is proved over an arbitrary field `K`, so the results apply uniformly to the
topological (`K = ℂ`), real, rational, and finite-field (arithmetic) incarnations of the
invariant.

---

## 2. Definitions

Throughout, `K` is a field and `range (n+1) = {0, 1, …, n}`. Subtraction `n - p` is
truncated natural-number subtraction (so `n - p = 0` when `p > n`).

> **Definition 1 (Hodge diamond).** A *Hodge diamond* is a pair `X = (n, h)` consisting
> of a complex dimension `n ∈ ℕ` and a function `h : ℕ × ℕ → ℤ`, written `h^{p,q}`. Only
> the values with `p, q ≤ n` are mathematically meaningful; the remaining values are
> treated as padding and never enter any sum below.

> **Definition 2 (Hodge–Deligne E-polynomial).** For a field `K` and `u, v ∈ K`,
> `E(X; u, v) := Σ_{p ∈ range (n+1)} Σ_{q ∈ range (n+1)} (-1)^{p+q} (h^{p,q} : K) u^p v^q.`

> **Definition 3 (mirror).** The *mirror* of `X = (n, h)` is `mirror X := (n, h')` with
> `h'^{p,q} := h^{n-p,\, q}`. Thus `(mirror X).n = X.n` and
> `(mirror X).h\,p\,q = X.h\,(n-p)\,q` (the simp lemmas `mirror_n`, `mirror_h`).

> **Definition 4 (Serre duality).** `X` is *Serre self-dual*, written `SerreDual X`, if
> `h^{p,q} = h^{n-p,\, n-q}` for all `p, q ≤ n`.

> **Definition 5 (Euler characteristic).**
> `χ(X) := Σ_{p ∈ range (n+1)} Σ_{q ∈ range (n+1)} (-1)^{p+q} h^{p,q} ∈ ℤ.`

> **Definition 6 (total dimension).**
> `b(X) := Σ_{p ∈ range (n+1)} Σ_{q ∈ range (n+1)} h^{p,q} ∈ ℤ`, the total Betti number.

A remark on the abstract setting: because `h` is defined on all of `ℕ × ℕ`, the mirror
map is an involution only on the support `p ≤ n` (outside it, `n - p = 0` collapses
information). We therefore state involutivity at the level of the support
(`mirror_mirror_h`) and of the E-polynomial (`epoly_mirror_mirror`), rather than as a
definitional equality of structures. The file also records `totalDim_mirror` (total
dimension is mirror-invariant) and packages the involution as Calabi–Yau data
(`CalabiYauData.mirror`).

---

## 3. Main results

### 3.1 Specialisation to the Euler characteristic

> **Theorem 1 (`epoly_one_one_eq_eulerChar`).** For any field `K`,
> `E(X; 1, 1) = (χ(X) : K).`

*Proof sketch.* Substituting `u = v = 1` makes every monomial `u^p v^q = 1`, so each
summand of `E(X;1,1)` becomes `(-1)^{p+q} (h^{p,q} : K)`. The double sum is then the
image under the ring homomorphism `ℤ → K` of the integer double sum defining `χ(X)`;
pushing the cast through the finite sums (it commutes with `+` and `·`) gives the claim.
∎

This theorem is the **specialisation bridge** that converts every polynomial identity
below into a numerical one by setting `u = v = 1`.

### 3.2 The mirror functional equation

> **Theorem 2 (`epoly_mirror_functional_equation`).** For `u ≠ 0` and any `v`,
> `E(mirror X; u, v) = (-1)^n · u^n · E(X; u^{-1}, v).`

*Proof sketch.* Expand the left-hand side using `mirror_h`:
`E(mirror X; u, v) = Σ_{p,q} (-1)^{p+q} (h^{n-p,q} : K) u^p v^q.`
Reflect the outer index by the bijection `p ↦ n - p` on `range (n+1)` (formally a
`Finset.sum_bij`; injectivity is `tsub_right_inj`, surjectivity sends `b ↦ n-b`). After
reflection the summand carries `h^{p,q}` (the reflected `h^{n-(n-p),q} = h^{p,q}` on the
support) with weight `(-1)^{(n-p)+q} u^{n-p} v^q`. Now apply the two bookkeeping
identities, valid because `p ≤ n`:

- exponent: `u^{n-p} = u^n / u^p = u^n · (u^{-1})^p`, using `u ≠ 0`
  (`pow_ne_zero`, `eq_div_iff`, `pow_add`, `Nat.add_sub_of_le`);
- parity: `(-1)^{(n-p)+q} = (-1)^n · (-1)^{p+q}`, using `(-1)^{n-p}(-1)^p = (-1)^n`
  (`Nat.sub_add_cancel`).

Factoring out the constants `(-1)^n u^n` leaves exactly
`Σ_{p,q} (-1)^{p+q} (h^{p,q}:K) (u^{-1})^p v^q = E(X; u^{-1}, v)`. ∎

The hypothesis `u ≠ 0` is genuinely needed: the equation inverts the `u`-variable, so it
lives on the punctured line `u ≠ 0`. No symmetry of `X` is required — Theorem 2 is
unconditional.

### 3.3 The Serre/Poincaré functional equation

> **Theorem 3 (`epoly_serre_functional_equation`).** If `SerreDual X`, then for
> `u ≠ 0`, `v ≠ 0`,
> `E(X; u, v) = (u·v)^n · E(X; u^{-1}, v^{-1}).`

*Proof sketch.* The cleanest route is to relate `X` to `mirror X` and invoke Theorem 2.
Concretely, one compares `E(X; u, v)` with `E(mirror X; u, v)` term by term and applies
Theorem 2 to `mirror X` (whose mirror equation reflects the `u`-axis), then reflects the
`v`-axis directly inside the sum via `Finset.sum_flip` (the reflection `q ↦ n - q`). The
Serre hypothesis `h^{p,q} = h^{n-p,n-q}` is exactly what identifies the doubly-reflected
table with the original. The two sign factors combine as `(-1)^{2n} = 1`, and the two
exponent factors as `u^n v^n = (uv)^n`, with the per-variable bookkeeping
`v^n = v^{n-q} v^q` (`Nat.sub_add_cancel`) handling the `v`-axis. The result is the
two-variable inversion `E(X; u, v) = (uv)^n E(X; u^{-1}, v^{-1})`. ∎

This is the polynomial form of Poincaré duality: it is precisely the symmetry of a
closed oriented `2n`-manifold under `H^k ↔ H^{2n-k}`, refined to bigraded Hodge data.

### 3.4 The numerical mirror sign

> **Theorem 4 (`eulerChar_mirror_sign`).** `χ(mirror X) = (-1)^n · χ(X).`

*Proof sketch (two ways).* (i) Specialise Theorem 2 at `u = v = 1` (legal since `1 ≠ 0`)
and apply Theorem 1 to both sides: `χ(mirror X) = (-1)^n · 1^n · χ(X)`. (ii) Directly:
reflect the outer index `p ↦ n - p` in Definition 5; the reflected summand carries the
sign `(-1)^{(n-p)+q} = (-1)^n (-1)^{p+q}`, and factoring `(-1)^n` out of the integer
double sum yields the identity. The Lean proof uses the direct route via a
`Finset.sum_bij`. ∎

Theorem 4 is the headline numerical consequence: the topological Euler characteristic of
the mirror diamond is `(-1)^n` times the original. It is, literally, the `u = v = 1`
shadow of the polynomial-level mirror functional equation.

---

## 4. The single combinatorial engine

All four theorems are instances of one principle.

> **Reflection principle.** Let `f : {0,…,n} → A` take values in a commutative ring `A`.
> Then `Σ_{p=0}^n f(p) = Σ_{p=0}^n f(n - p)` (`Finset.sum_range_reflect`).

Applying the reflection `p ↦ n - p` to a summand of the form
`(-1)^{p+q} h^{p,q} u^p v^q` produces a summand with three changes, each a one-line
identity valid for `p ≤ n`:

| quantity | before | after reflection | identity used |
|---|---|---|---|
| Hodge weight | `h^{p,q}` | `h^{n-p,q}` (or `h^{n-p,n-q}`) | `mirror_h` / `SerreDual` |
| sign | `(-1)^{p+q}` | `(-1)^{(n-p)+q} = (-1)^n(-1)^{p+q}` | `Nat.sub_add_cancel` |
| monomial | `u^p` | `u^{n-p} = u^n (u^{-1})^p` | `pow_add`, `Nat.add_sub_of_le`, `u≠0` |

The constant factors `(-1)^n` and `u^n` (and, in the two-axis case, `v^n`) pull out of
the sum, and what remains is the E-polynomial of the original diamond with inverted
variable(s). The Serre equation is the mirror equation applied in both axes; the Euler
identity is the mirror equation with the variables switched off. This is why a single
proof idea organises Serre duality, Poincaré duality, mirror symmetry, and the Euler
characteristic into one coherent family.

---

## 5. Worked examples

We verify the theorems on standard diamonds. (These are the numerical demonstrations
implemented in `demo.py`.)

**Genus-`g` curve (`n = 1`).** Nonzero entries `h^{0,0}=1, h^{1,0}=g, h^{0,1}=g,
h^{1,1}=1`; `E(X;u,v) = 1 - g u - g v + uv`; `χ = 2 - 2g` (Theorem 1).
Mirror: `h'^{0,0}=g, h'^{1,0}=1, h'^{0,1}=1, h'^{1,1}=g`, so
`E(mirror X;u,v) = g - u - v + g uv`. Theorem 2: `(-1)^1 u^1 E(X; u^{-1}, v) =
-u(1 - g/u - g v + v/u) = g - u - v + g uv` ✓. Theorem 4: `χ(mirror) = 2g-2 =
(-1)^1(2-2g)` ✓.

**Projective plane `ℙ²` (`n = 2`).** `h^{0,0}=h^{1,1}=h^{2,2}=1`;
`E = 1 + uv + u²v²`; `χ = 3`. Serre self-dual, so Theorem 3:
`(uv)^2 E(u^{-1},v^{-1}) = u²v²(1 + (uv)^{-1} + (uv)^{-2}) = u²v² + uv + 1 = E` ✓.

**K3 surface (`n = 2`).** `h^{0,0}=h^{2,0}=h^{0,2}=h^{2,2}=1, h^{1,1}=20`;
`E = 1 + u² + v² + 20uv + u²v²`; `χ = 24`. Serre self-dual; Theorem 3 returns `E` ✓.
Since `n` is even, Theorem 4 gives `χ(mirror) = χ = 24`.

**Quintic Calabi–Yau threefold (`n = 3`).** Nonzero entries include
`h^{0,0}=h^{3,3}=h^{3,0}=h^{0,3}=1, h^{1,1}=h^{2,2}=1, h^{2,1}=h^{1,2}=101`;
`χ = -200`. Serre self-dual, so Theorem 3 holds; `n` odd, so Theorem 4 gives
`χ(mirror) = +200`. The mirror quintic has `h^{1,1}=101, h^{2,1}=1`, exhibiting the
Hodge-number exchange characteristic of mirror symmetry.

---

## 6. Algorithms

The results are entirely effective. We record the two principal procedures (full
type-hinted implementations appear in `demo.py` and in the package `algorithms` field).

**Algorithm A (E-polynomial assembly).** Given a diamond as a dictionary
`{(p,q): h^{p,q}}` and dimension `n`, build the coefficient table of
`E(u,v) = Σ (-1)^{p+q} h^{p,q} u^p v^q` in `O(n²)` monomial operations. Specialising at
`u=v=1` and summing yields `χ` in `O(n²)`.

**Algorithm B (functional-equation verifier).** Given a diamond, form the mirror /
Serre-inverted polynomial symbolically and test the relevant functional equation by
evaluating both sides at a panel of rational sample points `(u, v)` with `u, v ≠ 0`. A
polynomial identity of bidegree `≤ (2n, 2n)` is certified by agreement at
`(2n+1)²` generic points; in practice a handful of random rationals suffices to expose
any discrepancy. Complexity `O(n² · #points)`.

---

## 7. Applications and significance

- **Topology from algebra.** Theorem 1 packages the Euler characteristic as a single
  evaluation of `E`, and Theorem 4 then derives the mirror sign rule with no extra work.
- **Mirror symmetry bookkeeping.** Theorem 2 is the diamond-level statement of the
  Hodge-number exchange under mirror symmetry; it holds for any table, making it a clean
  combinatorial test that a proposed mirror pair is consistent.
- **Poincaré duality, refined.** Theorem 3 is the bigraded refinement of Poincaré
  duality and is exactly the functional equation satisfied by E-polynomials of smooth
  projective varieties.
- **Arithmetic.** Because everything is proved over an arbitrary field, the same
  identities govern E-polynomials counting `𝔽_q`-points, where `u, v` specialise to
  Frobenius eigenvalue weights. This is the "bridge to arithmetic" of the title.

---

## 8. Discussion and future work

The abstract model trades geometric content for generality: it knows nothing about
manifolds, only about a table of integers and the reflection `j ↦ n - j`. This is a
feature — it pinpoints exactly which inputs each theorem needs (Theorem 2: nothing;
Theorem 3: Serre duality; Theorems 1, 4: only the definitions). It also exposes the
boundary phenomenon that the mirror is an involution only on the support `p, q ≤ n`,
which is why involutivity is stated pointwise on the support and at the level of `E`
rather than as an equality of structures.

Natural next steps include: (i) the Poincaré-polynomial specialisation `u = v` and the
signature specialisation `u = -1`, both immediate from the reflection engine; (ii) a full
`CalabiYauData` layer making the mirror an honest involution by quotienting to the
support; and (iii) connecting the finite-field specialisation to motivic measures, where
the same functional equations become statements about zeta functions.

---

## Appendix: index of formal results

| Name | Kind | Statement |
|---|---|---|
| `HodgeDiamond` | structure | `(n : ℕ, h : ℕ → ℕ → ℤ)` |
| `HodgeDiamond.mirror` | def | `(mirror X).h p q = X.h (n-p) q` |
| `HodgeDiamond.SerreDual` | def | `∀ p q ≤ n, h^{p,q} = h^{n-p,n-q}` |
| `HodgeDiamond.EPoly` | def | `Σ (-1)^{p+q} h^{p,q} u^p v^q` |
| `HodgeDiamond.eulerChar` | def | `Σ (-1)^{p+q} h^{p,q}` |
| `HodgeDiamond.totalDim` | def | `Σ h^{p,q}` |
| `epoly_one_one_eq_eulerChar` | theorem | `E(X;1,1) = (χ X : K)` |
| `epoly_mirror_functional_equation` | theorem | `E(mirror X;u,v) = (-1)^n u^n E(X;u⁻¹,v)` |
| `epoly_serre_functional_equation` | theorem | `SerreDual → E(X;u,v) = (uv)^n E(X;u⁻¹,v⁻¹)` |
| `eulerChar_mirror_sign` | theorem | `χ(mirror X) = (-1)^n χ(X)` |
