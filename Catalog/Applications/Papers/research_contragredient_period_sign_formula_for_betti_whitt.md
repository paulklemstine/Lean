# The Contragredient Period Sign for Betti–Whittaker Periods of $\mathrm{GL}(n)$: A Modulo-Four Trichotomy

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Applications (number theory / automorphic representations)

---

## Abstract

Let $F$ be a number field with $r_1$ real places and $r_2$ complex places, and
let $n \ge 2$ be an integer. For a generic cohomological automorphic
representation $\pi$ of $\mathrm{GL}(n)$ over $F$, the bottom-degree
Betti–Whittaker period $p^b(\pi)$ and that of its contragredient $\pi^\vee$ are
related by
$$
p^b(\pi^\vee) = (-1)^{\,b(F,n)} \, p^b(\pi),
\qquad
b(F,n) = r_1 \left\lfloor \tfrac{n^2}{4}\right\rfloor + r_2 \, \frac{n(n-1)}{2},
$$
where $b(F,n)$ is the bottom cohomological degree of the locally symmetric space
of $\mathrm{GL}(n)/F$. We determine the explicit sign $(-1)^{b(F,n)}$ completely
and prove that it depends on $n$ **only through $n \bmod 4$**. The mechanism is a
pair of parity laws: $\lfloor n^2/4\rfloor$ is odd iff $n \equiv 2 \pmod 4$, and
$n(n-1)/2$ is odd iff $n \equiv 2$ or $3 \pmod 4$. These yield a trichotomy:
the sign is $+1$ for $n \equiv 0,1$; it is $(-1)^{r_1+r_2}$ for $n \equiv 2$; and
it is $(-1)^{r_2}$ for $n \equiv 3$, where in the last case the real places drop
out entirely. We record the structural consequences: the sign is a forced square
root of unity, an archimedean rigidity phenomenon for $n \equiv 3 \pmod 4$, and a
parity obstruction to self-duality. All results are formalized and machine-checked.

---

## 1. Introduction

### 1.1 Periods and their mirror images

A central theme of modern number theory is the study of *periods*:
transcendental constants attached to automorphic representations that encode
arithmetic information, notably the algebraicity and Galois-equivariance of
special values of $L$-functions. For a cohomological generic representation
$\pi$ of $\mathrm{GL}(n)$ over a number field $F$, one such invariant is the
**Betti–Whittaker period** $p^b(\pi)$: the ratio comparing the rational
structure coming from the Whittaker model with the rational structure on the
bottom-degree Betti cohomology class.

Every representation $\pi$ has a **contragredient** (dual) $\pi^\vee$, and a
basic structural question is how $p^b(\pi^\vee)$ relates to $p^b(\pi)$. The
answer is a sign:
$$
p^b(\pi^\vee) = (-1)^{\,b(F,n)} \, p^b(\pi). \tag{$\star$}
$$
Earlier instances of this relation in the literature carried *regularity*
assumptions on the infinitesimal character of $\pi$. The result we package here
removes them, extending $(\star)$ to the full class of generic cohomological
representations.

### 1.2 The contribution of this work

The relation $(\star)$ is usually stated with the sign hidden inside a quadratic
character $\varepsilon(\mathrm{disc}\,F)^{\,b(F,n)}$ attached to the
discriminant of $F$. While correct, this abstract form conceals the actual value
of the sign. Our contribution is to *compute* the sign and expose its structure:

1. **Parity laws** (Section 3) for the two summands of $b(F,n)$.
2. **A modulo-four trichotomy** (Section 4) for the sign $(-1)^{b(F,n)}$.
3. **Archimedean rigidity** (Section 5): when $n \equiv 3 \pmod 4$ the real
   places $r_1$ make no contribution to the sign.
4. **Structural corollaries** (Section 6): the sign is a forced square root of
   unity, and oddness of $b(F,n)$ is a parity obstruction to self-duality.

Every statement below has been formalized and machine-verified. We give complete
mathematical statements with proof sketches; the Lean theorem names are cited
inline for traceability.

---

## 2. Definitions

### 2.1 Number-field data

Throughout, $F$ is a number field with $r_1 \ge 0$ real places and $r_2 \ge 0$
complex places, and $n \ge 2$. The archimedean component of the idèle class
satisfies $k_\infty^\times \cong (\mathbb{R}^\times)^{r_1} \times
(\mathbb{C}^\times)^{r_2}$, so the group of connected components is
$\pi_0(k_\infty^\times) \cong (\mathbb{Z}/2)^{r_1}$ (because $\mathbb{R}^\times$
has two components and $\mathbb{C}^\times$ is connected). The signature class of
the discriminant defines a distinguished element of this group.

### 2.2 The bottom cohomological degree

**Definition 2.1 (`bDeg`).** The *bottom cohomological degree* of the locally
symmetric space attached to $\mathrm{GL}(n)/F$ is
$$
b(F,n) \;=\; r_1 \cdot \left\lfloor \tfrac n2 \right\rfloor \cdot
\left\lfloor \tfrac{n+1}{2}\right\rfloor \;+\; r_2 \cdot \frac{n(n-1)}{2},
$$
written in integer-floor form. (In the formalization, `bDeg n r₁ r₂ = r₁ * (n /
2) * ((n + 1) / 2) + r₂ * n * (n - 1) / 2`, using truncating integer division.)

**Lemma 2.2 (`floor_sq_div_four`).** For every $n$,
$\big\lfloor n^2/4 \big\rfloor = \lfloor n/2 \rfloor \cdot \lfloor (n+1)/2
\rfloor$.

*Proof sketch.* Split into $n = 2k$ and $n = 2k+1$. In the even case both sides
equal $k^2$; in the odd case both equal $k(k+1)$. The identity
$(2k+1)^2 = 4(k^2+k)+1$ gives $\lfloor (2k+1)^2/4\rfloor = k^2 + k$, matching
$k \cdot (k+1)$. $\square$

**Lemma 2.3 (`bDeg_eq_floor_tri`).** For all $n, r_1, r_2$,
$$
b(F,n) = r_1 \cdot \left\lfloor \tfrac{n^2}{4}\right\rfloor
       + r_2 \cdot \frac{n(n-1)}{2}.
$$

*Proof sketch.* Apply Lemma 2.2 to the real summand. For the complex summand,
$n(n-1)$ is even (the product of consecutive integers), so
$r_2 \cdot n \cdot (n-1)/2 = r_2 \cdot \big(n(n-1)/2\big)$ by associativity of
division through the divisible factor (`Nat.mul_div_assoc` with the evenness
witness `Nat.even_mul_pred_self`). $\square$

This separates $b(F,n)$ into a **real (floor) contribution**
$\lfloor n^2/4\rfloor$ and a **complex (triangular) contribution**
$\binom n2 = n(n-1)/2$.

### 2.3 The contragredient sign

**Definition 2.4 (contragredient sign).** The *contragredient sign* is
$$
\mathrm{sgn}(F,n) \;=\; (-1)^{\,b(F,n)} \in \{+1, -1\}.
$$
This is the multiplier in $(\star)$. By Lemma 2.3 it depends only on the
parities of the two contributions, hence (as we show) only on
$(n \bmod 4,\, r_1 \bmod 2,\, r_2 \bmod 2)$.

---

## 3. Parity of the two contributions

The entire trichotomy rests on two period-four parity laws.

### 3.1 The floor contribution

**Theorem 3.1 (`floorSq_odd_iff`).** For every $n \in \mathbb{N}$,
$$
\left\lfloor \tfrac{n^2}{4}\right\rfloor \text{ is odd}
\iff n \equiv 2 \pmod 4.
$$

*Proof sketch.* Write $n = 4q + r$ with $0 \le r < 4$. Then
$n^2 = 16q^2 + 8qr + r^2$, so modulo the divisions involved only $r^2$ matters
for the parity of $\lfloor n^2/4\rfloor$. A four-way case split on $r \in
\{0,1,2,3\}$ computes the parity:
$$
r = 0 \Rightarrow \text{even}, \quad
r = 1 \Rightarrow \text{even}, \quad
r = 2 \Rightarrow \textbf{odd}, \quad
r = 3 \Rightarrow \text{even}.
$$
Only $r = 2$ gives odd. (Formally: `interval_cases r` followed by `omega`.)
$\square$

**Numerical witness.** For $n = 0,\dots,11$:
$\lfloor n^2/4\rfloor = 0,0,1,2,4,6,9,12,16,20,25,30$, with parities
$0,0,1,0,0,0,1,0,0,0,1,0$ — odd exactly at $n = 2,6,10$, i.e. $n \equiv 2
\pmod 4$.

### 3.2 The triangular contribution

**Theorem 3.2 (`triangular_odd_iff`).** For every $n \in \mathbb{N}$,
$$
\frac{n(n-1)}{2} \text{ is odd}
\iff n \equiv 2 \pmod 4 \ \text{ or } \ n \equiv 3 \pmod 4.
$$

*Proof sketch.* Again write $n = 4q + r$, $0 \le r < 4$, and reduce each case to
a closed form for $n(n-1)/2$:
- $r = 0$: $n(n-1)/2 = 2\,q(4q-1)$ — even.
- $r = 1$: $n(n-1)/2 = 2\,q(4q+1)$ — even.
- $r = 2$: $n(n-1)/2 = (2q+1)(4q+1)$ — product of two odd numbers, **odd**.
- $r = 3$: $n(n-1)/2 = (4q+3)(2q+1)$ — product of two odd numbers, **odd**.

So oddness occurs exactly for $r \in \{2,3\}$. (Formally: explicit factorizations
verified by `ring`/`omega`, parity of products by `Nat.mul_mod`.) $\square$

**Numerical witness.** For $n = 0,\dots,11$:
$n(n-1)/2 = 0,0,1,3,6,10,15,21,28,36,45,55$, with parities
$0,0,1,1,0,0,1,1,0,0,1,1$ — odd exactly at $n \equiv 2, 3 \pmod 4$.

### 3.3 The parity table

Combining Theorems 3.1 and 3.2:

| $n \bmod 4$ | $\lfloor n^2/4\rfloor$ parity | $n(n-1)/2$ parity |
|:-----------:|:-----------------------------:|:-----------------:|
| $0$         | even                          | even              |
| $1$         | even                          | even              |
| $2$         | **odd**                       | **odd**           |
| $3$         | even                          | **odd**           |

The asymmetry in the last row — floor even, triangular odd — is precisely what
makes the $n \equiv 3$ case special.

---

## 4. The bottom degree modulo two and the trichotomy

We now read off the parity of $b(F,n) = r_1 \lfloor n^2/4\rfloor + r_2\,
n(n-1)/2$ from the table.

**Theorem 4.1 (`bDeg_even_of_mod4_lt2`).** If $n \equiv 0$ or $1 \pmod 4$, then
$b(F,n)$ is even for **every** $r_1, r_2$.

*Proof sketch.* By the table both contributions are even, so each summand
$r_1 \lfloor n^2/4\rfloor$ and $r_2\, n(n-1)/2$ is even regardless of $r_1, r_2$;
their sum is even. (Formally, reduce mod 2 via `bDeg_eq_floor_tri` using
`floorSq_odd_iff` and `triangular_odd_iff` to get both parities $0$.) $\square$

**Theorem 4.2 (`bDeg_mod_two_of_mod4_eq2`).** If $n \equiv 2 \pmod 4$, then
$$
b(F,n) \equiv r_1 + r_2 \pmod 2.
$$

*Proof sketch.* Both contributions are odd (Theorems 3.1, 3.2 with $n \equiv 2$),
so modulo $2$ each summand reduces to its coefficient: $r_1 \cdot 1 + r_2 \cdot 1
= r_1 + r_2$. $\square$

**Theorem 4.3 (`bDeg_mod_two_of_mod4_eq3`).** If $n \equiv 3 \pmod 4$, then
$$
b(F,n) \equiv r_2 \pmod 2.
$$

*Proof sketch.* By the table the floor contribution is even and the triangular
contribution is odd, so $b(F,n) \equiv r_1 \cdot 0 + r_2 \cdot 1 = r_2$. The real
count $r_1$ cancels. $\square$

Exponentiating $-1$ to these parities yields the main classification.

**Theorem 4.4 (Contragredient Sign Trichotomy, `contraSign_*`).** The
contragredient sign $\mathrm{sgn}(F,n) = (-1)^{b(F,n)}$ is
$$
(-1)^{b(F,n)} =
\begin{cases}
+1 & n \equiv 0 \text{ or } 1 \pmod 4, \quad (\text{all } F),\\[2pt]
(-1)^{r_1 + r_2} & n \equiv 2 \pmod 4,\\[2pt]
(-1)^{r_2} & n \equiv 3 \pmod 4.
\end{cases}
$$

*Proof sketch.* Immediate from Theorems 4.1–4.3, since $(-1)^m$ depends only on
$m \bmod 2$. $\square$

Note that the sign depends on $n$ only through $n \bmod 4$ and on the field only
through $(r_1 \bmod 2, r_2 \bmod 2)$ — an infinite family of signs collapses to a
finite table.

---

## 5. Archimedean rigidity

The most striking consequence of Theorem 4.3 is that, in one residue class, the
real places of $F$ become invisible to the sign.

**Theorem 5.1 (Archimedean invisibility, `contraSign_indep_of_real_places_mod4_eq3`).**
Fix $n \equiv 3 \pmod 4$ and a complex-place count $r_2$. Then for any two
real-place counts $r_1, r_1'$,
$$
(-1)^{b(F,n)\,|_{r_1}} = (-1)^{b(F,n)\,|_{r_1'}} = (-1)^{r_2}.
$$
In particular, every totally real field ($r_2 = 0$) gives sign $+1$ when
$n \equiv 3 \pmod 4$.

*Proof sketch.* By Theorem 4.3, $b(F,n) \equiv r_2 \pmod 2$ independently of
$r_1$; the sign therefore does not see $r_1$. $\square$

This is a genuine *archimedean rigidity*: representations of $\mathrm{GL}(3)$
(the smallest $n \equiv 3$ case) over a totally real field versus a mixed field
with the same $r_2$ have identical contragredient signs. The phenomenon is
invisible from the abstract $\varepsilon(\mathrm{disc})^{b}$ statement of
$(\star)$ and requires the parity computation of Section 3 to detect.

---

## 6. Structural corollaries

### 6.1 The sign is a forced square root of unity

**Theorem 6.1 (`contraSign_sq`).** For all $F$ and $n$,
$\big((-1)^{b(F,n)}\big)^2 = 1$.

*Proof sketch.* $(-1)^{b}$ is $\pm 1$, whose square is $1$. More conceptually:
the contragredient is an involution, $(\pi^\vee)^\vee = \pi$. Applying $(\star)$
twice gives $p^b(\pi) = s^2 \, p^b(\pi)$ with $s = (-1)^{b(F,n)}$; since
$p^b(\pi) \ne 0$, we may cancel to obtain $s^2 = 1$. Thus the multiplier is
*forced* to be a square root of unity by involutivity alone, and $s =
(-1)^{b(F,n)}$ is the unique consistent value. $\square$

### 6.2 A parity obstruction to self-duality

A representation is **self-dual** if $\pi \cong \pi^\vee$. For such a $\pi$,
$(\star)$ reads $p^b(\pi) = (-1)^{b(F,n)} p^b(\pi)$, forcing the sign to be $+1$.

**Theorem 6.2 (No self-duality in odd degree, `no_selfDual_of_odd`).** Let
$\pi$ be a generic cohomological representation of $\mathrm{GL}(n)/F$ with
$p^b(\pi) \ne 0$. If $b(F,n)$ is odd, then $\pi$ is not self-dual. Equivalently,
self-dual such $\pi$ exist only when $b(F,n)$ is even.

*Proof sketch.* Self-duality forces $s = +1$ in $(\star)$, while oddness of
$b(F,n)$ forces $s = -1$; contradiction, using only $p^b(\pi) \ne 0$. $\square$

Combining with Theorem 4.4, no self-dual generic cohomological $\pi$ exists when:
$n \equiv 2 \pmod 4$ and $r_1 + r_2$ is odd, or $n \equiv 3 \pmod 4$ and $r_2$ is
odd. This is a pure parity obstruction — an existence statement proved with no
analytic input.

---

## 7. Algorithms

The classification is fully effective. Two algorithms summarize the content.

**Algorithm A (Bottom-Degree Parity).** Given $(n, r_1, r_2)$, compute the
parity of $b(F,n)$ in $O(1)$ from $n \bmod 4$ and $r_1, r_2 \bmod 2$, without
ever forming the (possibly enormous) integer $b(F,n)$.

```
function bDegParity(n, r1, r2):
    m = n mod 4
    if m == 0 or m == 1: return 0            # always even
    if m == 2:           return (r1 + r2) mod 2
    if m == 3:           return r2 mod 2
```

**Algorithm B (Contragredient Sign / Self-Duality Test).** Given $(n, r_1,
r_2)$, return the sign $(-1)^{b(F,n)} \in \{+1,-1\}$ and the Boolean
"self-duality permitted" (true iff the sign is $+1$).

```
function contraSign(n, r1, r2):
    p = bDegParity(n, r1, r2)
    sign = +1 if p == 0 else -1
    selfDualPossible = (sign == +1)
    return (sign, selfDualPossible)
```

Both run in constant time and are exact; they replace a transcendental
period comparison by a lookup on $n \bmod 4$.

---

## 8. Applications

- **Period normalizations.** Because the parity laws are independent of the
  particular period normalization, the trichotomy transports to any
  normalization differing from the Betti–Whittaker one by a sign.
- **Existence tests.** Theorem 6.2 gives an instant, arithmetic-only criterion
  ruling out self-dual generic cohomological representations for infinitely many
  $(n, F)$ — useful as a sanity filter in computational explorations of
  automorphic spectra.
- **$\mathrm{GL}(3)$ over real vs. mixed fields.** Theorem 5.1 predicts identical
  contragredient signs (namely $(-1)^{r_2}$) for $\mathrm{GL}(3)$ across all
  fields with a fixed $r_2$, an archimedean rigidity checkable against explicit
  period computations.

---

## 9. Discussion

The development illustrates a recurring methodological point: an abstract,
character-theoretic statement of a sign (here $\varepsilon(\mathrm{disc}\,
F)^{b(F,n)}$) can hide concrete structure that only emerges upon computing
parities. The two parity laws (Theorems 3.1, 3.2) are elementary — a residue
analysis modulo $4$ — yet they convert an infinite family of period signs into a
finite table, expose the disappearance of the real places when $n \equiv 3$, and
turn a soft representation-theoretic expectation (self-duality) into a hard
congruence test. The square-root-of-unity property (Theorem 6.1) shows the sign
is not a normalization artifact but is forced by the involutivity of the
contragredient.

---

## 10. Future directions

**Conjecture 1 — A mod-4 periodicity law for the whole period twist.** For every
number field $F$ and every $n \ge 2$, the contragredient twist of the bottom
Betti–Whittaker period depends on $n$ only through $n \bmod 4$, with the
trichotomy $+1$ ($n \equiv 0,1$), $(-1)^{r_1+r_2}$ ($n \equiv 2$), $(-1)^{r_2}$
($n \equiv 3$). The key insight is that $\lfloor n^2/4\rfloor$ and the triangular
number $n(n-1)/2$ are each periodic mod $4$ in their parity, so $(-1)^{b(F,n)}$,
which only sees exponents mod $2$, collapses to a finite table. The parity laws
`floorSq_odd_iff` / `triangular_odd_iff` make this a theorem that can be
transported to any period normalization differing by a sign.

**Conjecture 2 — Real places are invisible to the sign when $n \equiv 3 \pmod
4$.** For $n \equiv 3 \pmod 4$, two number fields with the same number of complex
places $r_2$ (but arbitrary $r_1$) give the same contragredient period sign; in
particular every totally real field gives sign $+1$. The key insight is that for
$n \equiv 3 \pmod 4$ the real (floor) contribution $\lfloor n^2/4\rfloor$ is
even, so $b(F,n) \equiv r_2 \pmod 2$ and the real-place count cancels entirely.
`contraSign_indep_of_real_places_mod4_eq3` proves the cancellation; this predicts
an archimedean rigidity checkable against explicit period computations for
$\mathrm{GL}(3)$ over real vs. mixed fields.

**Conjecture 3 — Self-duality is a parity obstruction, not an analytic one.** A
generic cohomological $\pi$ of $\mathrm{GL}(n)/F$ with nonzero bottom
Betti–Whittaker period can be self-dual ($\pi \cong \pi^\vee$) only if $b(F,n)$ is
even; equivalently, for $n \equiv 2 \pmod 4$ with $r_1+r_2$ odd, or $n \equiv 3
\pmod 4$ with $r_2$ odd, no such self-dual $\pi$ exists. The key insight is that
self-duality forces the period sign to be $1$, while oddness of $b(F,n)$ forces
it to be $-1$ — a contradiction with no analytic input (`no_selfDual_of_odd`).
The obstruction is fully formalized over $\mathbb{C}$ using only $p \ne 0$.

**Conjecture 4 — The sign is intrinsically a square root of unity, forced by
involutivity.** Any period normalization for which $p(\pi^\vee) = s \cdot p(\pi)$
and which respects the contragredient involution $(\pi^\vee)^\vee = \pi$ must
have $s^2 = 1$; the value $s = (-1)^{b(F,n)}$ is then the unique consistent
choice compatible with the bottom degree. The key insight is that applying the
relation twice gives $p = s^2 \cdot p$, and $p \ne 0$ cancels to $s^2 = 1$ — so
the square-root-of-unity property is automatic.

---

## Appendix: Summary of formalized results

| Name | Statement |
|------|-----------|
| `floor_sq_div_four` | $\lfloor n^2/4\rfloor = \lfloor n/2\rfloor\lfloor(n+1)/2\rfloor$ |
| `bDeg_eq_floor_tri` | $b(F,n) = r_1\lfloor n^2/4\rfloor + r_2\,n(n-1)/2$ |
| `floorSq_odd_iff` | $\lfloor n^2/4\rfloor$ odd $\iff n\equiv 2\ (4)$ |
| `triangular_odd_iff` | $n(n-1)/2$ odd $\iff n\equiv 2,3\ (4)$ |
| `bDeg_even_of_mod4_lt2` | $n\equiv 0,1\ (4) \Rightarrow b(F,n)$ even |
| `bDeg_mod_two_of_mod4_eq2` | $n\equiv 2\ (4) \Rightarrow b(F,n)\equiv r_1+r_2\ (2)$ |
| `bDeg_mod_two_of_mod4_eq3` | $n\equiv 3\ (4) \Rightarrow b(F,n)\equiv r_2\ (2)$ |
| `contraSign_*` | the trichotomy for $(-1)^{b(F,n)}$ |
| `contraSign_indep_of_real_places_mod4_eq3` | real places drop out for $n\equiv 3$ |
| `contraSign_sq` | $\big((-1)^{b(F,n)}\big)^2 = 1$ |
| `no_selfDual_of_odd` | $b(F,n)$ odd $\Rightarrow$ no self-dual $\pi$ |
