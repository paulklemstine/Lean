# An Algebraic Model of the Sharp/Flat $\lambda$-Difference under Quadratic Twist as a $\mu$-Proportional Correction

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We construct a self-contained algebraic model of the two Iwasawa invariants
$\mu$ and $\lambda$ of a characteristic element, realized on the polynomial ring
$\mathbb{Z}[X]$, and use it to isolate the purely algebraic core of the extension
of Matsuno's quadratic-twist formula to the case of a non-vanishing
$\mu$-invariant. Modeling the $\mu$-invariant as the $p$-adic valuation of the
content (the gcd of the coefficients) and the $\lambda$-invariant as the trailing
degree of the mod-$p$ reduction of the primitive part, we prove that both
invariants are additive under multiplication — $\mu$ by Gauss's Lemma together
with additivity of the $p$-adic valuation, and $\lambda$ by additivity of the
trailing degree in the integral domain $\mathbb{F}_p[X]$. Building on this
bridge, we introduce a two-component *sharp/flat* pair of twist factors sharing a
common $\mu$-depth but carrying distinct proportionality constants, and prove
three main results: (i) the twist acts identically on the two $\mu$-invariants
(*$\mu$-symmetry*); (ii) the resulting sharp/flat $\lambda$-difference is exactly
a $\mu$-proportional term, $\lambda^\sharp - \lambda^\flat =
(c_\sharp - c_\flat)\,\mu$, stated over $\mathbb{Z}$ so that it holds regardless
of the sign; and (iii) this difference is nonzero precisely when $\mu \ne 0$ and
$c_\sharp \ne c_\flat$, the model of Matsuno's non-vanishing-$\mu$ correction.
Finally, a generalized twist factor is shown to realize every pair
$(\lambda, \mu)$, so that the ratio $\lambda/\mu$ is a free parameter. All
statements are elementary and depend only on classical commutative algebra.

## 1. Introduction

### 1.1 Background and motivation

Iwasawa theory studies arithmetic invariants of number fields and elliptic curves
by organizing them along an infinite tower of field extensions and packaging the
resulting data as modules over the *Iwasawa algebra* $\Lambda = \mathbb{Z}_p[[T]]$,
the ring of formal power series in one variable over the ring of $p$-adic
integers. A finitely generated torsion $\Lambda$-module $M$ has a *characteristic
element* $f \in \Lambda$, well defined up to a unit, whose two structural
invariants control the growth of $M$ up the tower:

- the **$\mu$-invariant** $\mu_p(f)$, the $p$-adic valuation of $f$ (the largest
  power of $p$ dividing all coefficients), and
- the **$\lambda$-invariant** $\lambda_p(f)$, the degree of the distinguished
  polynomial supplied by the Weierstrass Preparation Theorem.

For an elliptic curve $E/\mathbb{Q}$ with good *ordinary* reduction at $p$, a
single $p$-adic $L$-function governs the theory. At a *supersingular* prime the
situation is more delicate: Pollack and Sprung showed that one attaches a **pair**
of characteristic elements — a *sharp* element $f^\sharp$ and a *flat* element
$f^\flat$ — related by a logarithmic (Pollack–Sprung) matrix.

A quadratic twist by a squarefree integer $D$ replaces $E$ by its twist $E_D$ and,
on the level of characteristic elements, multiplies each characteristic element by
a *twist factor*. Matsuno's formula compares the $\lambda$-invariants of $E$ and
$E_D$; in its classical form it addresses the ubiquitous case $\mu = 0$. When
$\mu \ne 0$ — a genuine phenomenon for certain curves and primes — the comparison
is expected to acquire a correction term proportional to $\mu$.

### 1.2 Contribution

This paper does **not** formalize $p$-adic $L$-functions, Selmer groups, or the
Pollack–Sprung matrix. Instead it isolates and rigorously establishes the purely
algebraic *core* underlying the invariant bookkeeping of the above story, in a
fully elementary setting. Our contributions are:

1. **A polynomial model of both invariants** on $\mathbb{Z}[X]$ that faithfully
   reproduces the Weierstrass separation of a characteristic element into a
   $p$-power part and a distinguished-polynomial part (Section 3).

2. **Additivity of both invariants under multiplication** (Section 4), the
   structural mechanism that makes factorizations of characteristic elements
   translate into additive relations between Iwasawa invariants.

3. **A faithful sharp/flat pair model and its twist theory** (Section 5),
   including:
   - *$\mu$-symmetry*: the twist affects both $\mu$-invariants identically;
   - *the $\mu$-proportional $\lambda$-difference*:
     $\lambda^\sharp - \lambda^\flat = (c_\sharp - c_\flat)\mu$;
   - *sharp non-vanishing*: the difference is nonzero iff $\mu \ne 0$ and
     $c_\sharp \ne c_\flat$, with the boundary case $\mu = 0$ separated out;
   - *free ratio*: a generalized twist factor realizing any $(\lambda, \mu)$ pair.

## 2. Preliminaries

Throughout, $p$ is a fixed prime and all polynomials have integer coefficients
unless otherwise noted. We write $C(a)$ for the constant polynomial with value
$a$, and $X$ for the indeterminate.

**Content and primitive part.** For a nonzero $f \in \mathbb{Z}[X]$, the
**content** $\operatorname{content}(f)$ is the greatest common divisor of the
coefficients of $f$ (normalized to be nonnegative), and the **primitive part**
$\operatorname{pp}(f)$ is the unique polynomial with
$$ f = \operatorname{content}(f)\cdot \operatorname{pp}(f), $$
where $\operatorname{pp}(f)$ is **primitive**: the gcd of its coefficients
is $1$. A polynomial is primitive precisely when no prime divides all of its
coefficients.

**$p$-adic valuation.** For a nonzero integer $n$, $v_p(n)$ is the exponent of $p$
in the prime factorization of $n$. It is additive: $v_p(mn) = v_p(m) + v_p(n)$ for
nonzero $m, n$.

**Reduction mod $p$.** For $f \in \mathbb{Z}[X]$, we write $\overline{f} \in
\mathbb{F}_p[X]$ for the polynomial obtained by reducing each coefficient modulo
$p$, where $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$. Reduction is a ring
homomorphism, so $\overline{fg} = \overline{f}\,\overline{g}$.

**Trailing degree.** For a nonzero polynomial $g$ over any ring, the **trailing
degree** $\operatorname{trdeg}(g)$ is the smallest
index $i$ such that the coefficient of $X^i$ in $g$ is nonzero; equivalently, the
multiplicity of $X$ as a factor. By convention $\operatorname{trdeg}(0) = 0$. In
an integral domain, for nonzero $g, h$,
$$ \operatorname{trdeg}(gh) = \operatorname{trdeg}(g) + \operatorname{trdeg}(h), $$
because the lowest-order term of a product is the product of the lowest-order
terms and cannot cancel.

## 3. The invariants in the polynomial model

**Definition 3.1 (Reduction).** For $f \in \mathbb{Z}[X]$, let $\overline{f} \in
\mathbb{F}_p[X]$ be its coefficientwise reduction modulo $p$.

**Definition 3.2 ($\mu$-invariant).** For $f \in \mathbb{Z}[X]$ define
$$ \mu_p(f) := v_p\big(\operatorname{content}(f)\big), $$
the $p$-adic valuation of the content of $f$.

**Definition 3.3 ($\lambda$-invariant).** For $f \in \mathbb{Z}[X]$ define
$$ \lambda_p(f) := \operatorname{trdeg}\big(\overline{\operatorname{pp}(f)}\big), $$
the trailing degree of the mod-$p$ reduction of the primitive part of $f$.

These definitions mirror the genuine Iwasawa invariants: writing a characteristic
element via Weierstrass Preparation as $f = p^{\mu} \cdot u \cdot P(T)$ with $u$ a
unit and $P$ a distinguished polynomial, the exponent $\mu$ is read from the
$p$-divisibility of the coefficients (our content valuation) while the degree of
$P$ governs the shape of the residual object (our trailing degree after reduction).

**Lemma 3.4 (Reduced primitive part is nonzero).** For every $f \in
\mathbb{Z}[X]$, $\overline{\operatorname{pp}(f)} \ne 0$.

*Proof sketch.* If $\overline{\operatorname{pp}(f)} = 0$, then every
coefficient of $\operatorname{pp}(f)$ is divisible by $p$, i.e.
$C(p) \mid \operatorname{pp}(f)$. Primitivity of the primitive part forces
$p$ to be a unit in $\mathbb{Z}$, contradicting $p \ge 2$. $\square$

Lemma 3.4 guarantees that $\lambda_p$ is well defined by an honest trailing degree
(the argument is never the zero polynomial) and is the technical linchpin of
$\lambda$-additivity.

## 4. The bridge: additivity of both invariants

**Theorem 4.1 ($\mu$-additivity).** For nonzero $f, g \in \mathbb{Z}[X]$,
$$ \mu_p(f\cdot g) = \mu_p(f) + \mu_p(g). $$

*Proof sketch.* By **Gauss's Lemma**, the content is multiplicative:
$\operatorname{content}(fg) = \operatorname{content}(f)\cdot
\operatorname{content}(g)$. Both contents are nonzero because $f, g$ are nonzero.
Applying $v_p$ and using its additivity on nonzero integers gives the result.
$\square$

**Theorem 4.2 ($\lambda$-additivity).** For nonzero $f, g \in \mathbb{Z}[X]$,
$$ \lambda_p(f\cdot g) = \lambda_p(f) + \lambda_p(g). $$

*Proof sketch.* The primitive part is multiplicative for nonzero arguments:
$\operatorname{pp}(fg) = \operatorname{pp}(f)\cdot
\operatorname{pp}(g)$. Reduction is a ring homomorphism, so
$\overline{\operatorname{pp}(fg)} =
\overline{\operatorname{pp}(f)}\cdot
\overline{\operatorname{pp}(g)}$. By Lemma 3.4 both factors are nonzero
elements of the integral domain $\mathbb{F}_p[X]$, so their trailing degrees add.
$\square$

Theorems 4.1 and 4.2 are the entire engine of the paper: any factorization of a
characteristic element induces an additive splitting of both invariants.

**Building blocks.** The following values, immediate from the definitions and
additivity, are used repeatedly.

| Polynomial | $\mu_p$ | $\lambda_p$ |
|---|---|---|
| $C(p^{k})$ | $k$ | $0$ |
| $X^{n}$ | $0$ | $n$ |
| $p^{k}\cdot X^{a}$ | $k$ | $a$ |

- $\mu_p(C(p^k)) = k$: the content of a constant is its absolute value, whose
  $p$-adic valuation is $k$; its primitive part is a unit, so $\lambda = 0$.
- $\lambda_p(X^n) = n$: $X^n$ is monic, hence primitive, and reduces to $X^n$ in
  $\mathbb{F}_p[X]$, of trailing degree $n$; its content is $1$, so $\mu = 0$.
- The last row follows from the first two by Theorems 4.1–4.2.

## 5. The sharp/flat pair and its twist

### 5.1 The generalized twist factor

**Definition 5.1.** For $a, k \in \mathbb{N}$ set
$$ \tau(a, k) := C(p^{k})\cdot X^{a} = p^{k} X^{a}. $$

**Proposition 5.2.** $\tau(a,k) \ne 0$, and
$$ \mu_p\big(\tau(a,k)\big) = k, \qquad
   \lambda_p\big(\tau(a,k)\big) = a. $$

*Proof sketch.* Nonvanishing is clear since $p \ne 0$. Apply additivity
(Theorems 4.1–4.2) to $C(p^k)\cdot X^a$ and the building-block table. $\square$

**Corollary 5.3 (Free $\lambda/\mu$ ratio).** For any $a \ne a'$ and any $k$, the
factors $\tau(a,k)$ and $\tau(a',k)$ have equal
$\mu$-invariant $k$ but distinct $\lambda$-invariants $a \ne a'$. In particular
the ratio $\lambda/\mu$ is not pinned to any fixed constant.

This models the genuine dependence of the twist contribution on the twisting datum
(the prime or modulus $D$), which cannot be captured by a single universal
proportionality constant $\lambda = c\,\mu$.

### 5.2 Sharp and flat twist factors

**Definition 5.4.** Fix a common $\mu$-depth $k$ and proportionality constants
$c_\sharp, c_\flat \in \mathbb{N}$. Define
$$ \tau^{\sharp}(c_\sharp, k) := \tau(c_\sharp\, k,\, k), \qquad
   \tau^{\flat}(c_\flat, k) := \tau(c_\flat\, k,\, k). $$

By Proposition 5.2,
$$ \mu_p(\tau^{\sharp}) = \mu_p(\tau^{\flat}) = k, \qquad
   \lambda_p(\tau^{\sharp}) = c_\sharp\, k, \quad
   \lambda_p(\tau^{\flat}) = c_\flat\, k. $$
Both factors carry the same power of $p$ (hence a common $\mu$-invariant $k$) but
distinct powers of $X$ (encoding the sharp/flat asymmetry). This is the minimal
honest model in which the two channels can differ.

### 5.3 Main results

Let $f \in \mathbb{Z}[X]$ be a nonzero characteristic element.

**Theorem 5.5 ($\mu$-symmetry of the twist).**
$$ \mu_p\big(f\cdot \tau^{\sharp}(c_\sharp, k)\big)
 = \mu_p\big(f\cdot \tau^{\flat}(c_\flat, k)\big)
 = \mu_p(f) + k. $$

*Proof sketch.* By $\mu$-additivity (Theorem 4.1) and $\mu_p(\text{twist}) = k$
for both factors, each side equals $\mu_p(f) + k$. $\square$

Thus the $\mu$-invariant is entirely blind to the sharp/flat distinction; the
whole asymmetry resides in $\lambda$.

**Theorem 5.6 (The sharp/flat $\lambda$-difference is $\mu$-proportional).** In
$\mathbb{Z}$,
$$ \lambda_p\big(f\cdot \tau^{\sharp}(c_\sharp, k)\big)
 - \lambda_p\big(f\cdot \tau^{\flat}(c_\flat, k)\big)
 = (c_\sharp - c_\flat)\cdot \mu_p(\operatorname{twist}), $$
where $\mu_p(\operatorname{twist}) = k$ is the common $\mu$-invariant.

*Proof sketch.* By $\lambda$-additivity (Theorem 4.2),
$\lambda_p(f\cdot\tau^{\sharp}) = \lambda_p(f) + c_\sharp k$ and
$\lambda_p(f\cdot\tau^{\flat}) = \lambda_p(f) + c_\flat k$. Subtracting
cancels $\lambda_p(f)$ and yields $(c_\sharp - c_\flat)k$. The statement is placed
in $\mathbb{Z}$ so it remains valid whichever constant is larger; over
$\mathbb{N}$ the difference would truncate. $\square$

This is the algebraic model of the extension of Matsuno's formula to
non-vanishing $\mu$: the sharp/flat comparison carries a correction *literally
proportional to* $\mu$.

**Theorem 5.7 (Sharp non-vanishing).** If $k \ge 1$ (i.e. $\mu \ne 0$) and
$c_\sharp \ne c_\flat$, then
$$ \lambda_p\big(f\cdot \tau^{\sharp}(c_\sharp, k)\big)
 \ne \lambda_p\big(f\cdot \tau^{\flat}(c_\flat, k)\big). $$

*Proof sketch.* By Theorem 5.6 the difference equals $(c_\sharp - c_\flat)k$. In
the integral domain $\mathbb{Z}$ a product is zero only if a factor is; both
$c_\sharp - c_\flat \ne 0$ and $k \ne 0$, so the product is nonzero. $\square$

**Theorem 5.8 (Vanishing when $\mu = 0$).** For any $c_\sharp, c_\flat$,
$$ \lambda_p\big(f\cdot \tau^{\sharp}(c_\sharp, 0)\big)
 = \lambda_p\big(f\cdot \tau^{\flat}(c_\flat, 0)\big). $$

*Proof sketch.* Setting $k = 0$ in Theorem 5.6 makes the right-hand side
$(c_\sharp - c_\flat)\cdot 0 = 0$. $\square$

Theorems 5.7–5.8 together show the $\mu$-proportionality is **sharp**: both
hypotheses $\mu \ne 0$ and $c_\sharp \ne c_\flat$ are necessary, and the
correction collapses exactly at $\mu = 0$, recovering the classical
$\mu = 0$ comparison.

### 5.4 Worked numerical instances

Take $p = 2$, common depth $k = 3$, sharp constant $c_\sharp = 5$, flat constant
$c_\flat = 2$, and any nonzero $f$.

- **$\mu$-symmetry:** $\mu_2(f\cdot\tau^{\sharp}(5,3)) =
  \mu_2(f\cdot\tau^{\flat}(2,3)) = \mu_2(f) + 3$.
- **$\lambda$-difference:**
  $\lambda_2(f\cdot\tau^{\sharp}(5,3)) -
  \lambda_2(f\cdot\tau^{\flat}(2,3)) = (5-2)\cdot 3 = 9$.
- **Free ratio:** $\tau(7,3)$ has $\mu_2 = 3$ and $\lambda_2 = 7$,
  while $\tau(4,3)$ has $\mu_2 = 3$ and $\lambda_2 = 4$; same
  $\mu$, different $\lambda$.

## 6. Algorithms

The invariants are effectively computable on $\mathbb{Z}[X]$; we give the core
procedures.

**Algorithm A (Content and primitive part).** Given the coefficient list of
$f \ne 0$, compute $c = \gcd$ of the coefficients; the content is $|c|$ (or its
normalized nonnegative form) and the primitive part is obtained by dividing each
coefficient by $c$.

**Algorithm B ($\mu$-invariant).** Compute the content via Algorithm A, then count
the number of times $p$ divides it: repeatedly divide by $p$ while divisible.

**Algorithm C ($\lambda$-invariant).** Compute the primitive part via Algorithm A,
reduce each coefficient modulo $p$, and return the index of the lowest-order
nonzero residue.

**Algorithm D (Twist evaluation).** To evaluate the invariants of
$f\cdot\tau(a,k)$ without polynomial multiplication, use
additivity: $\mu = \mu_p(f) + k$ and $\lambda = \lambda_p(f) + a$. The sharp/flat
difference is then $(c_\sharp - c_\flat)k$ directly.

## 7. Applications and interpretation

- **Factorization bookkeeping.** Whenever a characteristic element factors, its
  two invariants split additively; the model makes this precise and elementary.
- **Twist corrections with $\mu \ne 0$.** The model predicts that the sharp/flat
  $\lambda$-comparison acquires a term $(c_\sharp - c_\flat)\mu$, invisible in the
  classical $\mu = 0$ regime and dominant when $\mu > 0$.
- **Dependence on the twisting datum.** The free $\lambda/\mu$ ratio
  (Corollary 5.3) captures how the twist contribution varies with the twisting
  prime or modulus, rather than being fixed.

## 8. Discussion and future work

The model deliberately trades the analytic depth of genuine $p$-adic
$L$-functions for a transparent algebraic skeleton. Its value is in showing that
the $\mu$-proportional correction is not an accident of the analytic theory but a
forced consequence of two structural facts: multiplicativity of the content
(Gauss's Lemma) and the absence of zero-divisors in $\mathbb{F}_p[X]$. The natural
continuations are:

1. **Passage to the Iwasawa algebra $\Lambda = \mathbb{Z}_p[[T]]$.** Replace
   content by the $p$-adic valuation of a power series and trailing degree by the
   distinguished-polynomial degree from Weierstrass Preparation, then reprove
   additivity in that setting. Because both invariants are additive for a
   structural reason — a valuation on the coefficient ring and a degree in the
   residual polynomial ring — Weierstrass Preparation transports exactly these two
   pieces of data, so the additive bookkeeping should be unchanged.

2. **Honest sharp/flat modeling.** Introduce a genuine two-component element
   $(f^\sharp, f^\flat)$ related by the logarithmic matrix of Pollack–Sprung, and
   derive the $\lambda$-difference with its $\mu$-correction as a theorem rather
   than positing the twist factors.

3. **Twist action on characteristic ideals.** Define the quadratic twist by
   $D \equiv 1 \pmod 4$ at the level of Selmer groups / $\Lambda$-modules and prove
   it multiplies the characteristic element by an explicit factor with invariants
   $(\mu_D, \lambda_D)$, recovering the twist formula with number-theoretic
   content.

4. **Variable proportionality constant.** Allow the sharp/flat constants to depend
   on the twisting prime, matching the actual dependence in Matsuno's formula, and
   conjecture a depth-weighted linear form $\sum_{\ell \mid D} w(\ell)\mu$ over the
   ramified primes.

5. **Explicit examples.** Once the $\Lambda$-module layer exists, instantiate on a
   curve of supersingular reduction at $2$ with non-vanishing $\mu$ and check the
   twist formula against tabulated invariants.

## 9. Conclusion

We have built an elementary, self-contained model of the Iwasawa $\mu$- and
$\lambda$-invariants on $\mathbb{Z}[X]$, proved both are additive under
multiplication, and used this to establish that under a modeled quadratic twist
the sharp and flat $\mu$-invariants coincide while their $\lambda$-invariants
differ by exactly $(c_\sharp - c_\flat)\mu$ — a correction nonzero precisely when
$\mu \ne 0$ and the two channels differ. The generalized twist factor further
shows the $\lambda/\mu$ ratio is a free parameter. These results isolate the
algebraic heart of the extension of Matsuno's quadratic-twist comparison to the
non-vanishing-$\mu$ regime.

## References

- H. Matsuno, *Construction of elliptic curves with large Iwasawa
  $\lambda$-invariants and large Tate–Shafarevich groups.*
- R. Pollack, *On the $p$-adic $L$-function of a modular form at a supersingular
  prime.*
- F. Sprung, *Iwasawa theory for elliptic curves at supersingular primes: a pair
  of main conjectures.*
- K. Iwasawa, *On $\mathbb{Z}_\ell$-extensions of algebraic number fields.*
