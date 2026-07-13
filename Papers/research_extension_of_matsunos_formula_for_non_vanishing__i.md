# Additivity of Iwasawa Invariants and a Matsuno-Type Twist Formula for Non-Vanishing $\mu$

## Abstract

We develop a self-contained algebraic model of the two classical Iwasawa
invariants $\mu$ and $\lambda$ of a characteristic element, realized on
the polynomial ring $\mathbb{Z}[X]$ as a computable stand-in for the
Iwasawa algebra $\Lambda = \mathbb{Z}_p[[T]]$. The two invariants are
recovered through genuinely different pieces of mathematics: the
$\mu$-invariant is the $p$-adic valuation of the *content* (the greatest
common divisor of the coefficients), a commutative-algebra object; the
$\lambda$-invariant is the *trailing degree* of the mod-$p$ reduction of
the *primitive part*, a finite-field combinatorial object. Our first main
results establish that both invariants are **additive under
multiplication**, with the $\mu$-additivity resting on Gauss's Lemma and
the additivity of the $p$-adic valuation, and the $\lambda$-additivity
resting on the additivity of the trailing degree in the integral domain
$\mathbb{F}_p[X]$ together with the multiplicativity of the primitive
part. Building on this additivity bridge, we model a quadratic-twist
factor $\text{twist}_{c,k} = p^{k} X^{c k}$ whose invariants satisfy
$\lambda = c\,\mu$, and we prove a **Matsuno-type twist formula**: twisting
shifts the $\lambda$-invariant by a term $c \cdot \mu$ literally
proportional to the $\mu$-invariant of the twist, which vanishes exactly
when $\mu = 0$ and is nonzero as soon as $\mu \neq 0$ and $c \neq 0$. This
isolates and proves the purely algebraic core underlying the expectation,
in the supersingular Iwasawa theory of Pollack and Sprung, that the
sharp/flat $\lambda$-difference under quadratic twist contains a
$\mu$-proportional term when $\mu \neq 0$.

**Keywords:** Iwasawa invariants, $\mu$-invariant, $\lambda$-invariant,
Weierstrass preparation, content, Gauss's Lemma, primitive part, trailing
degree, quadratic twist, supersingular reduction, Matsuno's formula.

---

## 1. Introduction

### 1.1 Background

Iwasawa theory attaches to an arithmetic object — classically an ideal
class group, and for us the arithmetic of an elliptic curve $E/\mathbb{Q}$
— a module over the *Iwasawa algebra*
$$\Lambda = \mathbb{Z}_p[[T]],$$
the ring of formal power series in one variable $T$ with coefficients in
the ring $\mathbb{Z}_p$ of $p$-adic integers. This ring is a regular local
ring of dimension two and, up to pseudo-isomorphism, finitely generated
torsion $\Lambda$-modules are classified by their *characteristic
element*, a nonzero $f \in \Lambda$. Two integer invariants of $f$ control
the coarse structure of the module and the growth of arithmetic
quantities in the associated $\mathbb{Z}_p$-tower: the **$\mu$-invariant**
and the **$\lambda$-invariant**.

Concretely, write a nonzero characteristic element as a power series
$$f = \sum_{i \ge 0} a_i\, T^i, \qquad a_i \in \mathbb{Z}_p,$$
and let $v_p$ denote the $p$-adic valuation on $\mathbb{Z}_p$. Then

$$
\mu_p(f) = \min_i v_p(a_i),
\qquad
\lambda_p(f) = \min\{\, i : v_p(a_i) = \mu_p(f)\,\}.
$$

The **Weierstrass preparation theorem** for $\Lambda$ gives the
equivalent factorization
$$f = p^{\mu} \cdot U \cdot P,$$
where $U \in \Lambda^{\times}$ is a unit and $P$ is a *distinguished
polynomial* (monic, with all lower coefficients divisible by $p$) of
degree exactly $\lambda$. Thus $\mu$ measures the uniform $p$-divisibility
of $f$, while $\lambda$ is the degree of the distinguished polynomial —
equivalently, the $T$-adic order of the reduction of $f/p^{\mu}$ modulo
$p$.

### 1.2 The supersingular setting and Matsuno's formula

When $E$ has *supersingular* reduction at $p$, the classical $p$-adic
$L$-function is not a single element of $\Lambda$; instead one works with
Pollack's $\pm$ $p$-adic $L$-functions and, more structurally, with the
sharp/flat ($\sharp/\flat$, or $\pm$) decomposition of Sprung. Each
component carries its own pair of invariants. Matsuno's formula compares
$\lambda$-invariants under a quadratic twist of $E$ by a square-free
integer $D$, and a natural refinement of the picture predicts that the
sharp/flat $\lambda$-difference should carry a term **proportional to the
$\mu$-invariant** precisely when $\mu \neq 0$.

### 1.3 Contribution

Rather than formalizing the full analytic apparatus, we isolate and prove
the **algebraic core** that makes the invariant bookkeeping work. We model
characteristic elements by polynomials in $\mathbb{Z}[X]$, where the two
invariants have transparent, computable descriptions, and we prove:

1. **Additivity bridge** (Section 3). Both $\mu$ and $\lambda$ are additive
   under multiplication of nonzero elements. The two proofs draw on two
   different areas of mathematics.
2. **Twist formula** (Section 4). For a modelled quadratic-twist factor
   $\text{twist}_{c,k} = p^{k} X^{c k}$, twisting shifts $\lambda$ by a
   term $c\cdot\mu(\text{twist})$ proportional to the $\mu$-invariant, and
   this term is nonzero exactly when $\mu \neq 0$ and $c \neq 0$.

All statements are elementary and self-contained.

---

## 2. Definitions and the algebraic model

We replace the power-series variable $T$ by a polynomial variable $X$ and
work in $\mathbb{Z}[X]$. This is faithful to the invariant theory: for a
polynomial the two Iwasawa invariants have exact finite descriptions, and
the multiplicative structure that drives Matsuno-type formulas is
identical.

Throughout, $p$ is a fixed prime.

### 2.1 Reduction modulo $p$

**Definition 2.1 (Reduction).** For $f \in \mathbb{Z}[X]$ we write
$\overline{f} \in \mathbb{F}_p[X]$ for the reduction of $f$ modulo $p$,
obtained by applying the ring homomorphism $\mathbb{Z} \to \mathbb{F}_p$
to each coefficient. Reduction is a ring homomorphism, so in particular
$$\overline{a \cdot b} = \overline{a}\cdot\overline{b}.$$

### 2.2 Content and primitive part

Every nonzero $f \in \mathbb{Z}[X]$ has a **content** $\operatorname{cont}(f)$,
the (normalized, nonnegative) greatest common divisor of its
coefficients, and a **primitive part** $\operatorname{pp}(f)$, satisfying
$$f = \operatorname{cont}(f)\cdot \operatorname{pp}(f),$$
with $\operatorname{pp}(f)$ *primitive*: the gcd of its coefficients is a
unit. A polynomial is primitive if and only if no prime divides all of
its coefficients. Two classical facts (Gauss's Lemma) are central:

- **Multiplicativity of content:**
  $\operatorname{cont}(f\cdot g) = \operatorname{cont}(f)\cdot\operatorname{cont}(g)$.
- **Multiplicativity of the primitive part:**
  $\operatorname{pp}(f \cdot g) = \operatorname{pp}(f)\cdot\operatorname{pp}(g)$.

### 2.3 The two invariants

**Definition 2.2 ($\mu$-invariant).** For nonzero $f \in \mathbb{Z}[X]$,
$$\mu_p(f) = v_p\big(\operatorname{cont}(f)\big),$$
the exact power of $p$ dividing the content. Equivalently, $\mu_p(f) =
\min_i v_p(a_i)$ where $f = \sum a_i X^i$.

**Definition 2.3 ($\lambda$-invariant).** For nonzero $f \in
\mathbb{Z}[X]$,
$$\lambda_p(f) = \operatorname{trdeg}\big(\overline{\operatorname{pp}(f)}\big),$$
the **trailing degree** (the exponent of the lowest-degree nonzero
monomial) of the mod-$p$ reduction of the primitive part. Equivalently,
$\lambda_p(f)$ is the first index $i$ at which $v_p(a_i)$ attains its
minimum $\mu_p(f)$.

The two definitions are engineered to mirror the Weierstrass
factorization: dividing by the content removes the factor $p^{\mu}$ (and
any further common integer factor), leaving the primitive part, whose
reduction modulo $p$ is a nonzero polynomial over the field
$\mathbb{F}_p$; the order of vanishing of that reduction at $X = 0$ is the
degree of the distinguished polynomial, i.e. $\lambda$.

### 2.4 A key non-degeneracy lemma

The definition of $\lambda$ only makes sense because the object whose
trailing degree we take is nonzero.

**Lemma 2.4 (Reduction of a primitive polynomial is nonzero).** For every
nonzero $f \in \mathbb{Z}[X]$, the reduction $\overline{\operatorname{pp}(f)}$
of the primitive part modulo $p$ is nonzero.

*Proof.* Suppose $\overline{\operatorname{pp}(f)} = 0$. Then every
coefficient of $\operatorname{pp}(f)$ reduces to $0$ in $\mathbb{F}_p$,
i.e. $p$ divides every coefficient. Equivalently, the constant polynomial
$p$ divides $\operatorname{pp}(f)$ in $\mathbb{Z}[X]$. But
$\operatorname{pp}(f)$ is primitive, so any divisor that divides all its
coefficients must be a unit; hence $p$ would be a unit in $\mathbb{Z}$, a
contradiction since $p \ge 2$. $\qquad\blacksquare$

---

## 3. The additivity bridge

The following two theorems are the technical heart of the paper. They say
that under multiplication the invariants add — but for two entirely
different reasons.

### 3.1 Additivity of $\mu$

**Theorem 3.1 ($\mu$ is additive).** For nonzero $f, g \in \mathbb{Z}[X]$,
$$\mu_p(f \cdot g) = \mu_p(f) + \mu_p(g).$$

*Proof.* By Gauss's Lemma the content is multiplicative:
$\operatorname{cont}(f\cdot g) = \operatorname{cont}(f)\cdot\operatorname{cont}(g)$.
Both contents are nonzero because $f, g$ are nonzero. The $p$-adic
valuation is additive on nonzero integers,
$v_p(mn) = v_p(m) + v_p(n)$, so
$$
\mu_p(f\cdot g)
= v_p\big(\operatorname{cont}(f)\cdot\operatorname{cont}(g)\big)
= v_p(\operatorname{cont}(f)) + v_p(\operatorname{cont}(g))
= \mu_p(f) + \mu_p(g).
$$
$\blacksquare$

This is the *arithmetic* side of the bridge: it takes place in
$\mathbb{Z}$ and $\mathbb{Z}_p$, and rests on the multiplicativity of the
gcd.

### 3.2 Additivity of $\lambda$

**Theorem 3.2 ($\lambda$ is additive).** For nonzero $f, g \in
\mathbb{Z}[X]$,
$$\lambda_p(f \cdot g) = \lambda_p(f) + \lambda_p(g).$$

*Proof.* By multiplicativity of the primitive part,
$\operatorname{pp}(f\cdot g) = \operatorname{pp}(f)\cdot\operatorname{pp}(g)$.
Reduction modulo $p$ is a ring homomorphism, so
$$
\overline{\operatorname{pp}(f\cdot g)}
= \overline{\operatorname{pp}(f)}\cdot\overline{\operatorname{pp}(g)}.
$$
By Lemma 2.4 both factors on the right are nonzero elements of
$\mathbb{F}_p[X]$. Since $\mathbb{F}_p$ is a field, $\mathbb{F}_p[X]$ is an
integral domain, and in an integral domain the trailing degree is additive
under multiplication:
$$\operatorname{trdeg}(u\cdot v) = \operatorname{trdeg}(u) + \operatorname{trdeg}(v)$$
for nonzero $u, v$ — the lowest-degree terms of $u$ and $v$ multiply to a
nonzero lowest-degree term of $u v$, with no cancellation. Therefore
$$
\lambda_p(f\cdot g)
= \operatorname{trdeg}\big(\overline{\operatorname{pp}(f)}\cdot\overline{\operatorname{pp}(g)}\big)
= \operatorname{trdeg}\big(\overline{\operatorname{pp}(f)}\big)
+ \operatorname{trdeg}\big(\overline{\operatorname{pp}(g)}\big)
= \lambda_p(f) + \lambda_p(g).
$$
$\blacksquare$

This is the *combinatorial* side of the bridge: it takes place entirely in
$\mathbb{F}_p[X]$, and rests on the absence of zero divisors in a
polynomial ring over a field.

### 3.3 Remark

Theorems 3.1 and 3.2 together are precisely the mechanism by which
factorizations of characteristic elements translate into additive
relations between Iwasawa invariants. Whenever a characteristic element
factors, e.g. $f = f_1 \cdots f_r$, the invariants split as
$\mu_p(f) = \sum_j \mu_p(f_j)$ and $\lambda_p(f) = \sum_j \lambda_p(f_j)$.
This additive bookkeeping is exactly what makes the twist computations of
the next section possible.

---

## 4. The Matsuno-type twist formula

### 4.1 Invariants of the building blocks

To model a twist we need the invariants of the two elementary factors that
build it: powers of the prime constant $p^k$, and powers of the variable
$X^n$.

**Lemma 4.1 (Constant $p^k$).** For $k \ge 0$,
$$\mu_p\big(p^k\big) = k, \qquad \lambda_p\big(p^k\big) = 0.$$

*Proof.* The content of the constant polynomial $p^k$ is $p^k$ itself, so
$\mu_p(p^k) = v_p(p^k) = k$. Its primitive part is $1$, whose reduction is
the constant $1 \in \mathbb{F}_p[X]$, of trailing degree $0$; hence
$\lambda_p(p^k) = 0$. $\qquad\blacksquare$

**Lemma 4.2 (Power $X^n$).** For $n \ge 0$,
$$\mu_p\big(X^n\big) = 0, \qquad \lambda_p\big(X^n\big) = n.$$

*Proof.* The content of $X^n$ is $1$ (its coefficients are $0$ and $1$,
gcd $1$), so $\mu_p(X^n) = v_p(1) = 0$. The polynomial $X^n$ is monic,
hence primitive, so its primitive part is $X^n$; its reduction modulo $p$
is $X^n \in \mathbb{F}_p[X]$, whose trailing degree is $n$. Thus
$\lambda_p(X^n) = n$. $\qquad\blacksquare$

### 4.2 The twist factor

**Definition 4.3 (Twist factor).** For nonnegative integers $c$ (the
proportionality constant) and $k$, define the modelled quadratic-twist
factor
$$\text{twist}_{c,k} = p^{k}\, X^{\,c\,k} \in \mathbb{Z}[X].$$
This factor is nonzero, since $p^k \neq 0$ and $X^{ck} \neq 0$ in the
domain $\mathbb{Z}[X]$.

**Proposition 4.4 (Invariants of the twist factor).**
$$\mu_p\big(\text{twist}_{c,k}\big) = k,
\qquad
\lambda_p\big(\text{twist}_{c,k}\big) = c\,k.$$
In particular
$$\lambda_p\big(\text{twist}_{c,k}\big) = c \cdot \mu_p\big(\text{twist}_{c,k}\big).$$

*Proof.* Apply additivity (Theorems 3.1, 3.2) to the factorization
$\text{twist}_{c,k} = p^k \cdot X^{ck}$ together with Lemmas 4.1 and 4.2:
$$
\mu_p(\text{twist}_{c,k}) = \mu_p(p^k) + \mu_p(X^{ck}) = k + 0 = k,
$$
$$
\lambda_p(\text{twist}_{c,k}) = \lambda_p(p^k) + \lambda_p(X^{ck}) = 0 + ck = ck.
$$
The final identity is immediate: $ck = c\cdot k = c\cdot\mu_p(\text{twist}_{c,k})$.
$\qquad\blacksquare$

### 4.3 The twist formula

**Theorem 4.5 (Matsuno-type twist formula).** Let $f \in \mathbb{Z}[X]$ be
nonzero. Then for all $c, k \ge 0$,
$$
\lambda_p\big(f \cdot \text{twist}_{c,k}\big)
= \lambda_p(f) + c \cdot \mu_p\big(\text{twist}_{c,k}\big).
$$
The correction term $c\cdot\mu_p(\text{twist}_{c,k}) = c k$ is literally
proportional to the $\mu$-invariant of the twist.

*Proof.* Since $\text{twist}_{c,k} \neq 0$, Theorem 3.2 gives
$$
\lambda_p\big(f\cdot\text{twist}_{c,k}\big)
= \lambda_p(f) + \lambda_p(\text{twist}_{c,k}).
$$
By Proposition 4.4, $\lambda_p(\text{twist}_{c,k}) = ck = c\cdot
\mu_p(\text{twist}_{c,k})$. Substituting gives the claim. $\qquad\blacksquare$

There is a companion statement for the $\mu$-invariant: by Theorem 3.1,
$$
\mu_p\big(f\cdot\text{twist}_{c,k}\big) = \mu_p(f) + \mu_p(\text{twist}_{c,k})
= \mu_p(f) + k,
$$
so the twist also shifts $\mu$ additively by $k$.

### 4.4 Non-vanishing of the $\mu$-proportional term

**Theorem 4.6 (Non-vanishing).** The correction term in Theorem 4.5,
$$
\lambda_p\big(f \cdot \text{twist}_{c,k}\big) - \lambda_p(f)
= c \cdot \mu_p\big(\text{twist}_{c,k}\big) = c\,k,
$$
is nonzero **if and only if** $c \neq 0$ and $\mu_p(\text{twist}_{c,k}) =
k \neq 0$.

*Proof.* This is the statement that a product of nonnegative integers
$c\,k$ is nonzero iff both factors are nonzero. Since
$\mu_p(\text{twist}_{c,k}) = k$ by Proposition 4.4, the condition
$k \neq 0$ is exactly $\mu_p(\text{twist}_{c,k}) \neq 0$. $\qquad\blacksquare$

Thus the $\lambda$-shift is *not* an artifact that disappears under
algebraic simplification: it is present exactly when the twist carries a
nonzero $\mu$-invariant (and the proportionality constant $c$ is nonzero).
This models the concept that, in the supersingular setting, the sharp/flat
$\lambda$-difference under quadratic twist should contain a
$\mu$-proportional term whenever $\mu \neq 0$.

---

## 5. Algorithms

The invariant computations are fully constructive on $\mathbb{Z}[X]$. We
summarize the two core procedures.

### 5.1 Computing the $\mu$-invariant

Given $f = \sum_i a_i X^i$:
1. Compute $g = \gcd_i(a_i)$, the content.
2. Return $v_p(g)$, the exponent of $p$ in the factorization of $g$.

Complexity: $O(d \cdot M)$ for a degree-$d$ polynomial with $M$ the cost of
integer gcd/valuation on the coefficients.

### 5.2 Computing the $\lambda$-invariant

Given $f = \sum_i a_i X^i \neq 0$:
1. Compute the content $g = \gcd_i(a_i)$ and set $b_i = a_i / g$ (the
   primitive part).
2. Reduce each $b_i$ modulo $p$.
3. Return the least index $i$ with $b_i \not\equiv 0 \pmod p$ (the trailing
   degree of the reduction).

Equivalently, without forming the primitive part, $\lambda_p(f)$ is the
least index $i$ with $v_p(a_i) = \mu_p(f)$.

Complexity: $O(d \cdot M)$, dominated by the coefficient valuations.

Both algorithms make the additivity theorems computationally verifiable:
one may compute the invariants of $f$, $g$, and $fg$ independently and
check that they add.

---

## 6. Applications and discussion

The additivity bridge and the twist formula, though proved in an
elementary model, capture the exact algebraic content used repeatedly in
the arithmetic of Iwasawa invariants:

- **Factorization bookkeeping.** Whenever a characteristic element factors
  — for instance into a $p$-part and a prime-to-$p$ part, or into local
  factors — its invariants split additively. This underlies the reduction
  of global invariant computations to local ones.
- **Twist stability.** The twist formula quantifies precisely how the
  $\lambda$-invariant responds to a multiplicative twist, and pinpoints
  the $\mu$-dependence. In the generic case $\mu = 0$ the twist leaves the
  extra term absent; in the non-generic case $\mu \neq 0$ the term is
  forced to appear.
- **A clean separation of concerns.** The proof cleanly separates the two
  invariants into two mathematical worlds — content/valuation for $\mu$,
  finite-field trailing degree for $\lambda$ — clarifying which classical
  fact is responsible for each half of any invariant identity.

### Relation to the literature

The supersingular Iwasawa theory of Pollack (the $\pm$ $p$-adic
$L$-functions) and Sprung (the sharp/flat, $\sharp/\flat$, decomposition),
together with Matsuno's comparison of $\lambda$-invariants under quadratic
twist and the study of non-vanishing $\mu$ phenomena, form the arithmetic
backdrop for this work. We do not formalize those analytic objects here.
Instead we isolate and prove the algebraic core — additivity of $\mu$ and
$\lambda$ and the resulting $\mu$-proportional shift under a multiplicative
twist — that underlies their invariant bookkeeping.

---

## 7. Future directions

1. **From $\mathbb{Z}[X]$ to the Iwasawa algebra $\Lambda =
   \mathbb{Z}_p[[T]]$.** Replace content by the $p$-adic valuation of a
   power series and trailing degree by the distinguished-polynomial degree
   from Weierstrass preparation, then reprove the additivity theorems in
   that setting. The standard theory of power series, monic polynomials,
   and Weierstrass preparation over complete local rings makes this the
   natural first extension.

2. **Model the sharp/flat pair honestly.** Introduce a two-component
   characteristic element $(f^{\sharp}, f^{\flat})$ and formalize the
   relation between the components coming from the logarithmic matrix of
   Pollack–Sprung, then derive the sharp/flat $\lambda$-difference formula
   directly, recovering the $\mu$-proportional term as a special case of the
   twist formula proved here.

3. **Explicit twist factors from quadratic characters.** Replace the
   modelled factor $p^k X^{ck}$ by the genuine twisting operator induced by
   a quadratic character attached to a square-free $D \equiv 1 \pmod 4$,
   and identify the constant $c$ with the arithmetic data (e.g. ramification
   / local behaviour at $2$) predicted by Matsuno's formula.

---

## 8. Conclusion

We have given a compact, fully self-contained proof that the two Iwasawa
invariants $\mu$ and $\lambda$ are additive under multiplication — one via
Gauss's Lemma and $p$-adic valuations, the other via trailing degrees in
$\mathbb{F}_p[X]$ — and used this bridge to establish a Matsuno-type twist
formula in which the $\lambda$-shift under a modelled quadratic twist
contains a term $c\cdot\mu$ proportional to the twist's $\mu$-invariant,
non-vanishing exactly when $\mu \neq 0$ and $c \neq 0$. This isolates the
precise algebraic reason a non-vanishing $\mu$-invariant leaves an
indelible, predictable fingerprint on the $\lambda$-invariant under
quadratic twist.
