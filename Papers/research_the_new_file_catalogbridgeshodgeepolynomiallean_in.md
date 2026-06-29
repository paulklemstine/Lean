# The Hodge–Deligne E-polynomial as a Bridge to Arithmetic: Functional Equations from a Single Reflection

## Abstract

We introduce a fully abstract, coefficient-field-agnostic theory of the two-variable
**Hodge–Deligne E-polynomial**

> `E(X; u, v) = Σ_{0 ≤ p, q ≤ n} (−1)^{p+q} h^{p,q} u^p v^q`

attached to an abstract **Hodge diamond** `X` (a complex dimension `n` together with
a table of integer Hodge numbers `h^{p,q}`). We prove two genuine functional
equations: a **mirror functional equation**, `E(mirror X; u, v) = (−1)^n u^n E(X; 1/u, v)`,
holding unconditionally for every diamond and every nonzero `u`; and a
**Serre/Poincaré functional equation**, `E(X; u, v) = (uv)^n E(X; 1/u, 1/v)`, holding
under Serre duality of `X` and for nonzero `u, v`. We show that the E-polynomial is a
strict refinement of the topological Euler characteristic — `E(X; 1, 1) = χ(X)` — and
deduce the classical **mirror sign law** `χ(mirror X) = (−1)^n χ(X)` as the
`(u, v) = (1, 1)` specialization of the mirror functional equation. We also record the
mirror-invariance of the total Hodge dimension and the stability of Calabi–Yau data
under mirroring. The unifying mechanism is that both the mirror involution
`(p,q) ↦ (n−p, q)` and Serre duality `(p,q) ↦ (n−p, n−q)` are built from a single
index reflection `j ↦ n − j`, so that one combinatorial principle — invariance of a
finite sum under reversal of its index — drives every functional equation; the
prefactors `(−1)^n` and `(uv)^n` are precisely the parity- and exponent-bookkeeping of
that reflection. All results are established over an arbitrary field, opening a route
toward an arithmetic interpretation via specialization at primes.

**Keywords.** Hodge diamond, E-polynomial, Hodge–Deligne polynomial, mirror symmetry,
Serre duality, Poincaré duality, Euler characteristic, functional equation, Calabi–Yau,
Weil conjectures.

---

## 1. Introduction

### 1.1 Background and motivation

To a smooth projective complex variety `M` of complex dimension `n` one associates its
**Hodge numbers** `h^{p,q} = dim H^q(M, Ω^p_M)`, the dimensions of the Dolbeault
cohomology groups. Arranged in a square grid for `0 ≤ p, q ≤ n`, these numbers form
the **Hodge diamond** of `M`. The Hodge diamond is the central combinatorial shadow of
the variety's complex geometry: its row sums recover the Betti numbers
`b_k = Σ_{p+q=k} h^{p,q}`, and its signed total recovers the topological **Euler
characteristic** `χ(M) = Σ_{p,q} (−1)^{p+q} h^{p,q}`.

Two classical symmetries act on the Hodge diamond. **Serre duality** (a consequence of
Poincaré duality together with complex conjugation on cohomology) gives
`h^{p,q} = h^{n−p, n−q}`, a half-turn symmetry of the grid. **Mirror symmetry**, the
prediction emerging from string theory in the late 1980s, posits that Calabi–Yau
varieties occur in pairs `(M, M^∨)` whose Hodge diamonds are related by a transposition
exchanging "complex-structure" and "Kähler" moduli; combined with Serre duality this
manifests, at the numerical level, as a reflection of one index. For Calabi–Yau
threefolds the most celebrated instance is the quintic, with `h^{1,1} = 1` and
`h^{2,1} = 101`, whose mirror reverses these to `h^{1,1} = 101`, `h^{2,1} = 1`,
flipping the Euler characteristic from `−200` to `+200`.

The **E-polynomial** (Hodge–Deligne polynomial) is the natural two-variable generating
function that records the entire diamond rather than collapsing it to a single integer.
Over the complex numbers it is a fundamental motivic invariant: additive in long exact
sequences, multiplicative under products, and specializing to both the Euler
characteristic (at `u = v = 1`) and, conjecturally via the Weil conjectures, to
point-counts of finite-field reductions (at `u = v = q`).

### 1.2 Contribution

The folklore statement "the mirror flips the diamond and changes the Euler
characteristic by `(−1)^n`" is, in this paper, refined and proved as a *polynomial*
functional equation. Working with a deliberately minimal abstraction — a Hodge diamond
is *only* a dimension and an integer-valued table, with no variety attached — we show:

1. **(Refinement)** `E(X; 1, 1) = χ(X)`: the E-polynomial recovers the Euler
   characteristic on the diagonal `u = v = 1`.
2. **(Mirror functional equation)** `E(mirror X; u, v) = (−1)^n u^n E(X; 1/u, v)`,
   unconditionally, for `u ≠ 0`.
3. **(Serre/Poincaré functional equation)** `E(X; u, v) = (uv)^n E(X; 1/u, 1/v)` for
   Serre-self-dual `X` and `u, v ≠ 0`.
4. **(Mirror sign law)** `χ(mirror X) = (−1)^n χ(X)`, recovered as the
   `(u, v) = (1, 1)` shadow of (2).
5. **(Total-dimension invariance)** `totalDim(mirror X) = totalDim(X)`.
6. **(Calabi–Yau stability)** the mirror of a Serre-self-dual ("Calabi–Yau") diamond
   is again Serre-self-dual.

The decisive structural observation is that (2) and (3) are *not independent*: both
descend from a single reflection of a finite index range, and (3) follows from (2)
applied to the mirror diamond together with Serre duality. Because the entire theory is
phrased over an abstract field of coefficients, the same identities specialize at
primes, which is the basis for the arithmetic program sketched in §7.

### 1.3 Organization

§2 fixes the abstract structures and invariants. §3 records the two geometric
involutions and their elementary properties. §4 proves the refinement
`E(X;1,1) = χ(X)`. §5 proves the mirror functional equation and §6 the Serre/Poincaré
functional equation, with the corollaries on Euler characteristic and total dimension.
§7 discusses applications and the arithmetic descent program. §8 gives algorithms for
computation. §9 discusses limitations and future work.

---

## 2. Definitions

Throughout, `ℕ = {0, 1, 2, …}` and `ℤ` denotes the integers. For invariants taking
values in a coefficient ring we work over an arbitrary field `K` (e.g. `ℚ`, `ℝ`, `ℂ`,
or a finite field `F_q`).

### Definition 2.1 (Hodge diamond)

A **Hodge diamond** is a pair `X = (n, h)` consisting of:

- a complex dimension `n ∈ ℕ`;
- a function `h : ℕ × ℕ → ℤ`, written `h^{p,q}`.

Only the values with `0 ≤ p, q ≤ n` (the **support**) are regarded as mathematically
meaningful; values outside the support are treated as padding. We write `X.n` and
`X.h(p,q)` for the two components.

This abstraction discards all geometry: `X` is nothing more than a dimension and a
table of integers. Every theorem below is therefore a statement of pure combinatorial
algebra, valid for *any* such table, geometric or not.

### Definition 2.2 (E-polynomial)

For `X` a Hodge diamond and `u, v ∈ K`, the **Hodge–Deligne E-polynomial** is

> `E(X; u, v) := Σ_{p=0}^{n} Σ_{q=0}^{n} (−1)^{p+q} · h^{p,q} · u^p · v^q ∈ K`,

where the integer `h^{p,q}` is mapped into `K` via the canonical ring homomorphism
`ℤ → K`. (The double sum ranges over the support `0 ≤ p, q ≤ n`.)

### Definition 2.3 (Euler characteristic)

The **Euler characteristic** of `X` is the integer

> `χ(X) := Σ_{p=0}^{n} Σ_{q=0}^{n} (−1)^{p+q} · h^{p,q} ∈ ℤ`.

### Definition 2.4 (Total Hodge dimension)

The **total Hodge dimension** (total Betti number) is

> `totalDim(X) := Σ_{p=0}^{n} Σ_{q=0}^{n} h^{p,q} ∈ ℤ`.

### Definition 2.5 (Mirror)

The **mirror** of `X = (n, h)` is the Hodge diamond

> `mirror X := (n, (p, q) ↦ h^{n−p, q})`,

i.e. it reflects the first index, `h^{p,q} ↦ h^{n−p, q}`. (Here `n − p` is truncated
natural-number subtraction; on the support `p ≤ n` it is the ordinary reflection.) Note
`(mirror X).n = X.n` and `(mirror X)^{p,q} = X^{n−p, q}` definitionally.

### Definition 2.6 (Serre duality)

`X` is **Serre self-dual** (written `SerreDual X`) if

> for all `p, q` with `p ≤ n` and `q ≤ n`,  `h^{p,q} = h^{n−p, n−q}`.

Geometrically this is the half-turn symmetry of the Hodge diamond.

### Remark 2.7 (Calabi–Yau data)

A **Calabi–Yau diamond** is a Hodge diamond that is Serre self-dual (the relevant
structural input for the functional equations below). The total Hodge dimension and the
Euler characteristic are the principal numerical invariants of such data.

---

## 3. The two involutions and their basic properties

The two coordinate operations of interest are the **mirror** `(p,q) ↦ (n−p, q)` and
**Serre duality** `(p,q) ↦ (n−p, n−q)`. Both are built from the single **reflection**
`ρ_n : j ↦ n − j` of the index range `{0, 1, …, n}`. The reflection `ρ_n` is an
involution on the support and is the combinatorial engine of every result.

### Lemma 3.1 (Mirror fixes the dimension and reflects one index)

`(mirror X).n = X.n` and `(mirror X)^{p,q} = X^{n−p, q}`.

*Proof.* Immediate from Definition 2.5 (both equalities hold definitionally). ∎

### Lemma 3.2 (Mirror is an involution on the support)

For `p ≤ n` and any `q`, `(mirror (mirror X))^{p,q} = X^{p,q}`.

*Proof.* `(mirror (mirror X))^{p,q} = (mirror X)^{n−p, q} = X^{n−(n−p), q} = X^{p,q}`,
using `n − (n − p) = p` for `p ≤ n`. (Outside the support this can fail because of
truncated subtraction, which is why involutivity is stated on the support and, at the
level of the E-polynomial, in Corollary 5.4.) ∎

### Lemma 3.3 (Reflection principle)

For any function `f : {0, …, n} → K`,

> `Σ_{j=0}^{n} f(j) = Σ_{j=0}^{n} f(n − j)`.

*Proof.* The map `j ↦ n − j` is a bijection of `{0, …, n}` onto itself; reindexing the
sum along this bijection leaves the total unchanged. ∎

Lemma 3.3 is the entire combinatorial content behind the functional equations; the
remaining work is algebraic bookkeeping of signs and powers.

---

## 4. The E-polynomial refines the Euler characteristic

### Theorem 4.1 (Specialization at `(1, 1)`)

For every Hodge diamond `X`, `E(X; 1, 1) = χ(X)` (the right-hand integer mapped into
`K`).

*Proof sketch.* Substituting `u = v = 1` into Definition 2.2 collapses each monomial
`u^p v^q` to `1`, leaving `Σ_{p,q} (−1)^{p+q} h^{p,q}`, which is exactly the image of
`χ(X)` under `ℤ → K`. Formally one pushes the ring homomorphism through the finite
double sum and simplifies `1^p = 1^q = 1`. ∎

Theorem 4.1 is the anchor of the theory: every numerical consequence about `χ` is a
specialization of a polynomial statement about `E`. In particular the mirror sign law
(Corollary 5.3) is recovered from the mirror functional equation by setting
`u = v = 1`.

---

## 5. The mirror functional equation

### Theorem 5.1 (Mirror functional equation)

For every Hodge diamond `X` and every `u, v ∈ K` with `u ≠ 0`,

> `E(mirror X; u, v) = (−1)^n · u^n · E(X; 1/u, v)`,   where `n = X.n`.

*Proof sketch.* Expand the left side using Lemma 3.1:

> `E(mirror X; u, v) = Σ_{p,q} (−1)^{p+q} X^{n−p, q} u^p v^q`.

Apply the reflection principle (Lemma 3.3) to the `p`-sum, substituting `p ↦ n − p`.
This sends `X^{n−p, q} ↦ X^{p, q}`, the sign `(−1)^{p+q} ↦ (−1)^{(n−p)+q}`, and the
power `u^p ↦ u^{n−p}`. Now perform the two bookkeeping factorizations valid for `u ≠ 0`:

- **Parity shift:** `(−1)^{(n−p)+q} = (−1)^n · (−1)^{p+q}`, because
  `(−1)^{(n−p)+q} = (−1)^{n−p} (−1)^q` and `(−1)^{n−p} = (−1)^n (−1)^p` (using
  `(−1)^p (−1)^p = 1`), hence the global factor `(−1)^n` separates out.
- **Exponent shift:** `u^{n−p} = u^n · u^{−p} = u^n · (1/u)^p`, valid since `u ≠ 0`.

Substituting both yields

> `Σ_{p,q} (−1)^n (−1)^{p+q} X^{p,q} u^n (1/u)^p v^q
>   = (−1)^n u^n · Σ_{p,q} (−1)^{p+q} X^{p,q} (1/u)^p v^q
>   = (−1)^n u^n · E(X; 1/u, v)`,

which is the claim. Formally the reflection step is implemented as a bijective
reindexing of the `range (n+1)` summation; injectivity uses `n − p₁ = n − p₂ ⟹ p₁ = p₂`
on the support, and surjectivity uses `n − (n − p) = p`. ∎

### Corollary 5.2 (Mirror is unconditional)

Theorem 5.1 requires no symmetry hypothesis on `X` whatsoever — only `u ≠ 0`. The
mirror operation is intrinsically defined by reflecting one index, and the functional
equation is the algebraic identity that records this reflection.

### Corollary 5.3 (Mirror sign law)

For every Hodge diamond `X`, `χ(mirror X) = (−1)^n χ(X)`.

*Proof.* Specialize Theorem 5.1 at `u = v = 1` (legitimate since `1 ≠ 0`). The prefactor
becomes `(−1)^n · 1^n = (−1)^n`, the argument `1/u = 1` is unchanged, and Theorem 4.1
turns both sides into Euler characteristics:
`χ(mirror X) = E(mirror X; 1, 1) = (−1)^n E(X; 1, 1) = (−1)^n χ(X)`. (One may also prove
this directly by reflecting the `p`-index inside Definition 2.3, the parity shift
`(−1)^{(n−p)+q} = (−1)^n (−1)^{p+q}` producing the global sign.) ∎

In particular, when `n` is odd the mirror reverses the sign of `χ`, and when `n` is even
it preserves `χ`. For the quintic threefold (`n = 3`), `χ = −200 ↦ +200`; for the K3
surface (`n = 2`), `χ = 24 ↦ 24`.

### Corollary 5.4 (Involutivity at the polynomial level)

`E(mirror (mirror X); u, v) = E(X; u, v)` for `u ≠ 0`.

*Proof.* Apply Theorem 5.1 twice:
`E(mirror(mirror X); u, v) = (−1)^n u^n E(mirror X; 1/u, v)
   = (−1)^n u^n · (−1)^n (1/u)^n E(X; u, v) = (−1)^{2n} u^n u^{−n} E(X; u, v) = E(X; u, v)`,
since `(−1)^{2n} = 1` and `u^n u^{−n} = 1`. ∎

### Corollary 5.5 (Total-dimension invariance)

`totalDim(mirror X) = totalDim(X)`.

*Proof.* `totalDim` is the *unsigned* double sum (Definition 2.4); reflecting the
`p`-index by Lemma 3.3 reindexes the sum without introducing any sign, so the total is
unchanged. (Equivalently, `totalDim(X) = Σ_{p,q} |·|`-style sum is invariant under the
bijection `p ↦ n − p`.) ∎

---

## 6. The Serre/Poincaré functional equation

### Theorem 6.1 (Serre/Poincaré functional equation)

If `X` is Serre self-dual (Definition 2.6) then for all `u, v ∈ K` with `u, v ≠ 0`,

> `E(X; u, v) = (u · v)^n · E(X; 1/u, 1/v)`,   where `n = X.n`.

*Proof sketch.* The cleanest route is to deduce it from the mirror equation. Apply
Theorem 5.1 to the diamond `mirror X` (legal, `u ≠ 0`):

> `E(mirror(mirror X); u, v) = (−1)^n u^n E(mirror X; 1/u, v)`.

The left side is `E(X; u, v)` by Corollary 5.4. For the right side, expand
`E(mirror X; 1/u, v)` and apply the reflection principle to the *second* index `q`,
substituting `q ↦ n − q`. Serre self-duality `X^{p,q} = X^{n−p, n−q}` lets us rewrite the
reflected coefficients back in terms of `X`, while the second reflection contributes a
further parity factor `(−1)^n` and an exponent factor `v^n`. Collecting:

- The two parity factors multiply to `(−1)^{2n} = 1`.
- The exponent factors assemble to `u^n v^n = (uv)^n`.
- Both variables are inverted, `u ↦ 1/u` and `v ↦ 1/v`.

The result is `E(X; u, v) = (uv)^n E(X; 1/u, 1/v)`. Formally, the second reflection is
again a bijective reindexing of `range (n+1)`, and Serre duality is invoked exactly once
per term, in the form `X^{i, n−j} = X^{n−i, j}` after both reflections. ∎

### Interpretation 6.2

Theorem 6.1 is the polynomial face of **Poincaré duality**: it states that `E(X; ·, ·)`
is *palindromic* up to the twist `(uv)^n`. Writing `E(X; u, v) = Σ c_{p,q} u^p v^q`, the
identity is equivalent to the coefficient symmetry `c_{p,q} = c_{n−p, n−q}`, i.e. the
half-turn symmetry of the diamond promoted to the level of the generating polynomial.
Combined with Theorem 5.1, the E-polynomial is constrained by *two* commuting
involutions `u ↦ 1/u` and `v ↦ 1/v`, which generate a `(ℤ/2) × (ℤ/2)` symmetry group
acting (up to explicit prefactors) on `E`.

### Corollary 6.3 (Calabi–Yau stability)

If `X` is Serre self-dual then so is `mirror X`; hence the mirror of Calabi–Yau data is
Calabi–Yau data.

*Proof.* For `p, q ≤ n`, `(mirror X)^{p,q} = X^{n−p, q}` and
`(mirror X)^{n−p, n−q} = X^{n−(n−p), n−q} = X^{p, n−q}`. Serre duality of `X` gives
`X^{n−p, q} = X^{p, n−q}` (apply `X^{a,b} = X^{n−a, n−b}` with `a = n−p`, `b = q`).
Hence `(mirror X)^{p,q} = (mirror X)^{n−p, n−q}`, i.e. `mirror X` is Serre self-dual. ∎

---

## 7. Applications

### 7.1 A complete invariant up to duality symmetry

By Theorems 5.1 and 6.1, the E-polynomial of a Serre-self-dual diamond is determined by,
and determines, its coefficient table up to the `(ℤ/2)×(ℤ/2)` action generated by
`u ↦ 1/u`, `v ↦ 1/v`. Consequently any invariant of Hodge diamonds that is required to
respect both mirror symmetry and Poincaré duality must factor through the
symmetry-invariant data of `E`. This positions `E` as a canonical packaging of the
diamond, strictly finer than `χ` (which forgets all off-diagonal structure): two
diamonds with equal `χ` but different `E` are distinguished immediately, while the
functional equations guarantee that `E` carries no *redundant* freedom beyond the
expected dualities.

### 7.2 Mirror pairs and the Euler characteristic ledger

The mirror sign law (Corollary 5.3) gives an instant consistency check for any proposed
mirror pair `(X, Y = mirror X)`: their Euler characteristics must satisfy
`χ(Y) = (−1)^n χ(X)`. For odd `n` this forces `χ(X) + χ(Y) = 0`; the quintic/mirror-quintic
pair (`−200`, `+200`) is the textbook case. Total-dimension invariance (Corollary 5.5)
supplies a second ledger entry: `totalDim(X) = totalDim(Y)` (both `208` for the quintic
pair). Together these are necessary numerical conditions any candidate mirror
construction must obey.

### 7.3 Arithmetic descent: specialization at primes

Because the entire theory is field-agnostic, the mirror functional equation holds with
`K = F_p` (or `K = ℚ` followed by reduction). The Weil-conjecture philosophy predicts
that for a diamond realized by a smooth projective variety over `F_p` with `N` rational
points, point-counts are governed by the E-polynomial evaluated at the prime. Reducing
the identity `E(mirror X; u, v) = (−1)^n u^n E(X; 1/u, v)` at `(u, v) = (p, 1)` modulo
`p` then predicts a **mirror congruence** between the point-counts of a variety and its
mirror, of the shape `N_X ≡ (−1)^n N_Y (mod p)`. The polynomial sign `(−1)^n` proved
here is precisely the source of that congruence after reduction. This is the bridge from
geometry/topology to arithmetic advertised in the title; it is the subject of Future
Direction 3 (§9).

### 7.4 Toward a zeta function

The graded data packaged by `E` is exactly what is needed to define a formal zeta-type
product `Z(X; t) = Π_{p,q} (1 − t^p)^{(−1)^{p+q+1} h^{p,q}}`. Its logarithmic derivative
is a generating series whose value at `t = 1` is `χ(X)`, so Corollary 5.3 is the
*infinitesimal* shadow of a conjectural functional equation `Z(mirror X; t) = Z(X; t)^{(−1)^n}`
(up to an explicit monomial), a formal analogue of the Weil zeta functional equation
(Future Direction 5, §9).

---

## 8. Algorithms

We summarize the computational primitives; full type-hinted implementations accompany
this work.

### Algorithm 8.1 (E-polynomial evaluation)

**Input.** A Hodge diamond `X = (n, h)` and field elements `u, v`.
**Output.** `E(X; u, v) ∈ K`.

```
function EPOLY(X, u, v):
    total <- 0
    for p in 0..n:
        for q in 0..n:
            sign  <- (-1)^(p+q)
            total <- total + sign * h(p,q) * u^p * v^q
    return total
```

Complexity: `Θ(n²)` field operations (with naive powering; `Θ(n²)` with incremental
powers). Exact when `K = ℚ` via rational arithmetic.

### Algorithm 8.2 (Functional-equation verifier)

**Input.** A diamond `X`, field elements `u ≠ 0`, `v ≠ 0`.
**Output.** Booleans certifying the mirror and (if Serre-self-dual) Serre equations.

```
function VERIFY(X, u, v):
    mirror_ok <- ( EPOLY(MIRROR(X), u, v)
                   == (-1)^n * u^n * EPOLY(X, 1/u, v) )
    serre_ok  <- true
    if SERRE_DUAL(X):
        serre_ok <- ( EPOLY(X, u, v)
                      == (u*v)^n * EPOLY(X, 1/u, 1/v) )
    return (mirror_ok, serre_ok)
```

Using exact rational arithmetic the comparisons are decidable equalities, so VERIFY is a
sound certificate generator. Complexity `Θ(n²)`.

### Algorithm 8.3 (Mirror sign / total-dimension ledger)

**Input.** A diamond `X`.
**Output.** The pair `(χ(X), χ(mirror X))` and `(totalDim(X), totalDim(mirror X))`,
with the predicted relations checked.

```
function LEDGER(X):
    chi   <- sum over (p,q) of (-1)^(p+q) h(p,q)
    chi_m <- sum over (p,q) of (-1)^(p+q) h(n-p,q)
    assert chi_m == (-1)^n * chi              # Corollary 5.3
    td    <- sum over (p,q) of h(p,q)
    td_m  <- sum over (p,q) of h(n-p,q)
    assert td_m == td                         # Corollary 5.5
    return (chi, chi_m, td, td_m)
```

---

## 9. Discussion, limitations, and future work

### 9.1 Limitations

- **Abstraction over geometry.** A `HodgeDiamond` is only a dimension and an integer
  table; the theorems are statements of combinatorial algebra. Realizing a given table
  by an actual variety, and verifying that table is the variety's true Hodge diamond, is
  outside the scope here.
- **Truncated subtraction.** Because `h` is stored on all of `ℕ × ℕ`, the index
  reflection `p ↦ n − p` uses truncated subtraction; involutivity of `mirror` therefore
  holds on the support `p ≤ n` (Lemma 3.2) and at the level of the E-polynomial
  (Corollary 5.4), rather than as a definitional identity of structures.
- **Serre dependence.** The Serre/Poincaré functional equation requires Serre
  self-duality; without it only the unconditional mirror equation survives.

### 9.2 Future directions

**(1) The E-polynomial as the universal additive mirror invariant.** Conjecture: every
`ℚ`-valued invariant `I` of Hodge diamonds that is additive under (orthogonal) direct
sums and multiplicative under products factors through `E` — there is a fixed rational
function `Φ` with `I(X) = Φ(E(X; ·, ·))`. The two functional equations pin down `E` up
to the `(ℤ/2)×(ℤ/2)` symmetry generated by `u ↦ 1/u`, `v ↦ 1/v`, so any invariant
respecting both dualities must be a symmetric function of the coefficient vector. The
falsifiable test is to exhibit an additive invariant *not* recoverable from `E`.

**(2) Positivity and unimodality of mirror-averaged Betti numbers.** Conjecture: for any
diamond `X` the symmetrized sequence `b̄_k = (b_k(X) + b_k(mirror X))/2` is unimodal with
peak at `k = n`. Total-dimension invariance shows symmetrization redistributes mass
without changing the sum; combined with Poincaré symmetry `b_k = b_{2n−k}` this forces a
symmetric sequence, and the conjecture asserts mirror-averaging cannot destroy
unimodality — a "hard-Lefschetz shadow" at the combinatorial level. Small-`n`
enumeration can falsify it.

**(3) Arithmetic descent: `E(X; p, 1) mod p` governs point counts.** Conjecture: if `X`
is realized by a smooth projective variety over `F_p` with `N` rational points then
`N ≡ E(X; p, 1) (mod p)`, and the mirror congruence `N_X ≡ (−1)^n N_Y (mod p)` follows
from the mirror functional equation evaluated at `(u, v) = (p, 1)` and reduced mod `p`.
The mirror sign `(−1)^n` proved here *is* the finite-field congruence after reduction.

**(4) A finite symmetry group on the Calabi–Yau diamond zoo.** Conjecture: Serre
duality, Hodge symmetry `(p,q) ↦ (q,p)`, and the mirror `(p,q) ↦ (n−p, q)` generate a
finite group `G_n` (order dividing 8) acting on Calabi–Yau diamonds, and the number of
`G_n`-orbits with total dimension `≤ D` is quasi-polynomial in `D`. The three
involutions are now available explicitly, so the group is a finite, decidable
computation for small `n`.

**(5) A zeta function with a provable functional equation.** Conjecture: the formal
product `Z(X; t) = Π_{p,q} (1 − t^p)^{(−1)^{p+q+1} h^{p,q}}` satisfies
`Z(mirror X; t) = Z(X; t)^{(−1)^n}` up to an explicit `t`-power, a formal analogue of the
Weil zeta functional equation. The logarithmic derivative evaluated at `t = 1` is `χ`,
so Corollary 5.3 is its infinitesimal shadow. The quintic mirror pair
(`h^{1,1} = 1, h^{2,1} = 101`) gives a finite-truncation falsification test.

### 9.3 Summary

A single reflection `j ↦ n − j` of a finite index range, dressed in the right sign- and
exponent-bookkeeping, simultaneously produces the mirror functional equation, the
Serre/Poincaré functional equation, the mirror sign law for the Euler characteristic,
and total-dimension invariance. Refusing to collapse the Hodge diamond to a single
integer — keeping instead the full two-variable E-polynomial — converts a numerical
coincidence of mirror symmetry into a structural law, and, because the law is proved
over an arbitrary field, points the way from geometry through topology to the
arithmetic of finite fields.
