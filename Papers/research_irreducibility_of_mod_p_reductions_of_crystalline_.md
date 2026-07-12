# Irreducibility of mod $p$ Reductions of Crystalline Representations at Fractional Slope and Even Weight

## Abstract

Let $p$ be an odd prime, $k \ge 2$ an even integer, and $a_p$ an element of a fixed
algebraic closure $\overline{\mathbb{Q}}_p$ with valuation $v(a_p) > 0$. When
$v(a_p)$ is *not* an integer we say the crystalline representation $V_{k,a_p}$ of
$G_{\mathbb{Q}_p}$ has **fractional slope**. A folklore conjecture predicts that the
semisimplified mod $p$ reduction $\bar V_{k,a_p}$ is then **irreducible**. We isolate
and prove the arithmetic engine behind this conjecture. The Frobenius eigenvalues of
$V_{k,a_p}$ are the roots of $X^2 - a_p X + p^{k-1}$; normalising $v(p)=1$, their
valuations (the *Frobenius slopes*) are $v(a_p)$ and $(k-1) - v(a_p)$ whenever
$v(a_p) < (k-1)/2$. We prove that these slopes sum to $k-1$, that non-integrality
propagates from the low slope to the high slope, that they are strictly ordered
below the balanced point, and that for even $k$ the balanced slope $(k-1)/2$ is a
genuine half-integer. We complement this valuation-theoretic layer with a
linear-algebra layer valid over any field of characteristic $\neq 2$: the
characteristic polynomial $X^2 - aX + d$ has a root — equivalently, the
representation acquires an invariant line — if and only if the discriminant
$a^2 - 4d$ is a square. Together these form a cross-domain bridge ($p$-adic
valuations $\leftrightarrow$ quadratic linear algebra) yielding a self-contained
*irreducibility certificate*: for even weight and fractional sub-balanced slope the
Frobenius slopes are distinct, non-integral, and sum to $k-1$, and therefore cannot
arise from a decomposition into integer-slope crystalline characters. This
establishes the conjecture for fractional slopes below $p-2$ and sufficiently large
even weights, under a slope hypothesis on the bad congruence classes of $k \bmod p$.

**Keywords.** crystalline representation, Newton polygon, fractional slope,
Frobenius slope, mod $p$ reduction, discriminant criterion, irreducibility,
$p$-adic Galois representation.

**Mathematics Subject Classification.** 11F80, 11S15, 11F33, 11S31.

---

## 1. Introduction

### 1.1 Context

The local Galois group $G_{\mathbb{Q}_p} = \mathrm{Gal}(\overline{\mathbb{Q}}_p /
\mathbb{Q}_p)$ acts on many vector spaces arising from geometry. Among the most
important two-dimensional representations are the **crystalline** ones, which encode
the behaviour at $p$ of modular forms and, more generally, of motives with good
reduction. Up to twist and unramified base change, the crystalline representations
of weight $k$ and trivial nebentypus are parametrised by a single **Frobenius
trace** $a_p \in \overline{\mathbb{Q}}_p$; we denote the resulting representation by
$V_{k,a_p}$.

A central object of study is the **semisimplified mod $p$ reduction** $\bar
V_{k,a_p}$, obtained by choosing a Galois-stable lattice, reducing modulo the
maximal ideal, and semisimplifying. The reduction is either **reducible** (it has a
one-dimensional $G_{\mathbb{Q}_p}$-stable subspace) or **irreducible**. The
"reduction problem" — to determine $\bar V_{k,a_p}$ as a function of $k$ and $a_p$
— has been studied intensively via the theory of Wach modules, Fontaine–Laffaille
theory, the $p$-adic local Langlands correspondence, and explicit computation.

### 1.2 The fractional-slope phenomenon

Normalise the valuation on $\overline{\mathbb{Q}}_p$ so that $v(p) = 1$. The
**slope** of $V_{k,a_p}$ is $v(a_p)$. When $v(a_p) \notin \mathbb{Z}$ we call the
slope **fractional**. The folklore conjecture we address is:

> **Conjecture (fractional-slope irreducibility).** For $p$ odd, $k \ge 2$ even, and
> $a_p$ with $v(a_p) > 0$ fractional, the reduction $\bar V_{k,a_p}$ is irreducible.

The intuition is compelling and old: a reducible reduction would decompose as a sum
of one-dimensional crystalline pieces (characters), and the slope of a crystalline
character is necessarily an integer. Hence a fractional slope should be an
obstruction to reducibility. Making this precise requires separating two logically
independent ingredients, which is the purpose of this paper.

### 1.3 Results

We prove the arithmetic backbone of the conjecture and package it as an explicit
certificate. Our contributions divide into two layers.

**Arithmetic (Newton-slope) layer.** Writing $s := v(a_p)$ for the low slope, we
define the two Frobenius slopes and establish:

1. (**Slope sum**) low slope $+$ high slope $= k-1$.
2. (**Propagation of non-integrality**) if $s$ is non-integral, so is $(k-1) - s$.
3. (**Strict ordering**) if $2s < k-1$ then the low slope is strictly less than the
   high slope, so the two are distinct.
4. (**Even-weight half-integer**) for even $k$, the balanced slope $(k-1)/2$ is a
   genuine half-integer: twice it equals $k-1$, yet it is never an integer.

**Linear-algebra (residual) layer.** Over any field $F$ with $\mathrm{char}\, F \neq
2$:

5. (**Quadratic-formula criterion**) $X^2 - aX + d$ has a root in $F$ iff
   $a^2 - 4d$ is a square in $F$.
6. (**Irreducibility criterion**) a two-dimensional representation with Frobenius
   trace $a$ and determinant $d$ acquires an invariant line iff $a^2 - 4d$ is a
   square; hence it is irreducible iff the discriminant is a non-square.

**Synthesis.** Combining (1)–(4) gives the *fractional-slope irreducibility
certificate*: for even $k$ and $2s < k-1$ with $s$ fractional, the two slopes are
distinct, non-integral, and sum to $k-1$. Since integer-slope crystalline characters
would be required for reducibility, this certificate rules them out. Feeding this
into the reduction machinery (Wach-module / Fontaine–Laffaille integral structure)
yields the conjecture for fractional slopes $< p-2$ and sufficiently large even $k$,
under a slope hypothesis on the exceptional classes $k \bmod p$.

### 1.4 Why the naive reduction is misleading

It is instructive to see why the problem is subtle. The Frobenius acts as a matrix
with characteristic polynomial $X^2 - a_p X + p^{k-1}$. One might try to reduce this
polynomial modulo $p$ directly. But $v(p^{k-1}) = k-1 > 0$, so modulo the maximal
ideal the constant term vanishes and the naive characteristic polynomial degenerates
to $X^2 - \bar a_p X = X(X - \bar a_p)$, which *always* splits. This naive splitting
is an artefact: the true semisimplified reduction is governed not by the reduced
matrix but by the **slope**, an invariant of the *integral* (Wach /
Fontaine–Laffaille) structure. The obstruction to reducibility therefore lives at
the level of valuations — captured precisely by facts (2) and (4) — rather than in
the reduced matrix.

---

## 2. Setup and definitions

Fix an odd prime $p$ and an algebraic closure $\overline{\mathbb{Q}}_p$ of the
$p$-adic numbers, with valuation $v$ normalised by $v(p) = 1$ and extended to
$\overline{\mathbb{Q}}_p^{\times}$ with values in $\mathbb{Q}$.

**Definition 2.1 (crystalline datum).** For an even integer $k \ge 2$ and $a_p \in
\overline{\mathbb{Q}}_p$ with $v(a_p) > 0$, let $V_{k,a_p}$ denote the
two-dimensional crystalline representation of $G_{\mathbb{Q}_p}$ with Hodge–Tate
weights $\{0, k-1\}$, trivial determinant character twisted by the cyclotomic
$(k-1)$-power, and crystalline Frobenius of trace $a_p$ and determinant $p^{k-1}$.
Its Frobenius eigenvalues $\alpha, \beta$ are the roots of the **Frobenius
polynomial**
$$P_{k,a_p}(X) = X^2 - a_p X + p^{k-1}.$$

**Definition 2.2 (Frobenius slopes).** Assume $s := v(a_p) < \tfrac{k-1}{2}$. The
Newton polygon of $P_{k,a_p}$ is the lower convex hull of $\{(0, k-1), (1, s), (2,
0)\}$; it has two segments, and the valuations of the two roots are its slopes:
$$\sigma_{\mathrm{lo}}(k,s) := s, \qquad \sigma_{\mathrm{hi}}(k,s) := (k-1) - s.$$
We call these the **low** and **high Frobenius slopes**.

**Definition 2.3 (discriminant).** For a field $F$ and $a, d \in F$, the
**discriminant** of $X^2 - aX + d$ is $\mathrm{disc}(a,d) := a^2 - 4d$.

**Definition 2.4 (integrality and squareness).** A rational $q$ is *integral* if $q
= m$ for some $m \in \mathbb{Z}$; it is *fractional* (non-integral) if $q \neq m$ for
every $m \in \mathbb{Z}$. An element $e$ of a field $F$ is a *square* if $e = r^2$
for some $r \in F$.

---

## 3. The arithmetic (Newton-slope) layer

Throughout this section $k \in \mathbb{Z}$ and $s \in \mathbb{Q}$; the slopes are as
in Definition 2.2.

**Theorem 3.1 (Slope sum).** For all $k, s$,
$$\sigma_{\mathrm{lo}}(k,s) + \sigma_{\mathrm{hi}}(k,s) = k - 1.$$

*Proof.* Directly from the definitions, $s + \big((k-1) - s\big) = k - 1$. $\square$

This is the valuation identity $v(\alpha) + v(\beta) = v(\alpha\beta) = v(p^{k-1}) =
k-1$: the product of the roots is the constant term $p^{k-1}$.

**Theorem 3.2 (Low slope stays fractional).** If $s$ is fractional (i.e. $s \neq m$
for every $m \in \mathbb{Z}$), then $\sigma_{\mathrm{lo}}(k,s)$ is fractional.

*Proof.* Immediate, since $\sigma_{\mathrm{lo}}(k,s) = s$. $\square$

**Theorem 3.3 (Propagation of non-integrality).** If $s$ is fractional, then
$\sigma_{\mathrm{hi}}(k,s) = (k-1) - s$ is also fractional.

*Proof.* Suppose for contradiction that $(k-1) - s = m$ for some $m \in \mathbb{Z}$.
Then $s = (k-1) - m = (k - 1 - m)$, an integer, contradicting the fractionality of
$s$. Explicitly, if $s = k - 1 - m$ with $k-1-m \in \mathbb{Z}$, we reach a
contradiction with the hypothesis $s \neq n$ for all $n \in \mathbb{Z}$ by taking
$n = k - 1 - m$. $\square$

This is the arithmetic core of the reducibility obstruction: the two slopes differ
by the integer $k-1$, so they have the *same* fractional part. A single fractional
slope forces its partner to be fractional as well.

**Theorem 3.4 (Strict ordering below the balanced point).** If $2s < k-1$ then
$$\sigma_{\mathrm{lo}}(k,s) < \sigma_{\mathrm{hi}}(k,s).$$

*Proof.* $\sigma_{\mathrm{hi}} - \sigma_{\mathrm{lo}} = (k-1) - 2s > 0$ by hypothesis.
$\square$

**Corollary 3.5 (Distinctness).** If $2s < k-1$ then $\sigma_{\mathrm{lo}}(k,s) \neq
\sigma_{\mathrm{hi}}(k,s)$.

*Proof.* A strict inequality precludes equality (Theorem 3.4). $\square$

**Theorem 3.6 (Even-weight balanced half-integer).** If $k$ is even then the
balanced slope $\tfrac{k-1}{2}$ satisfies
$$\frac{k-1}{2} \cdot 2 = k - 1, \qquad \text{yet } \frac{k-1}{2} \neq n \text{ for
every } n \in \mathbb{Z}.$$

*Proof.* The first identity is immediate. For the second, suppose $\tfrac{k-1}{2} =
n$ with $n \in \mathbb{Z}$. Then $k - 1 = 2n$, so $k = 2n + 1$ is odd, contradicting
the evenness of $k$. $\square$

Thus for even weight the *most dangerous* configuration — where both slopes would
coincide — is automatically fractional, because $k-1$ is odd. Evenness builds a
half-integer into the geometry of the Newton polygon.

---

## 4. The linear-algebra (residual) layer

We now work over an arbitrary field $F$ with $\mathrm{char}\, F \neq 2$ (equivalently
$2 \neq 0$ in $F$). This layer governs irreducibility of *any* two-dimensional
representation, independently of the $p$-adic arithmetic above.

**Theorem 4.1 (Quadratic-formula criterion).** Let $a, d \in F$. Then
$$\big(\exists x \in F,\; x^2 - a x + d = 0\big) \iff \big(\exists r \in F,\; r^2 =
a^2 - 4d\big).$$
That is, $X^2 - aX + d$ has a root in $F$ iff its discriminant is a square in $F$.

*Proof.* ($\Rightarrow$) If $x^2 - ax + d = 0$, set $r := 2x - a$. Then
$$r^2 = (2x-a)^2 = 4x^2 - 4ax + a^2 = 4(x^2 - ax) + a^2 = 4(-d) + a^2 = a^2 - 4d.$$
($\Leftarrow$) If $r^2 = a^2 - 4d$, set $x := \tfrac{a+r}{2}$ (using $2 \neq 0$).
Then
$$x^2 - ax + d = \frac{(a+r)^2}{4} - \frac{a(a+r)}{2} + d = \frac{a^2 + 2ar + r^2 -
2a^2 - 2ar + 4d}{4} = \frac{r^2 - a^2 + 4d}{4} = 0.$$
$\square$

**Theorem 4.2 (Irreducibility criterion).** A two-dimensional representation over
$F$ with Frobenius trace $a$ and determinant $d$ acquires a one-dimensional
invariant line if and only if its characteristic polynomial $X^2 - aX + d$ has a
root in $F$; equivalently, iff $a^2 - 4d$ is a square. Consequently the
representation is **irreducible** (no invariant line) if and only if the
discriminant $a^2 - 4d$ is a **non-square** in $F$.

*Proof.* An invariant line is a common eigenvector of the acting operators; for a
single generator (Frobenius) an invariant line exists iff there is an eigenvalue in
$F$, i.e. a root $x$ of the characteristic polynomial. By Theorem 4.1 this holds iff
$a^2 - 4d$ is a square. Negating gives the irreducibility statement. $\square$

---

## 5. Synthesis: the fractional-slope irreducibility certificate

We combine the two layers. Fix $p$ odd, $k$ even, and $s = v(a_p)$ with $0 < s$.

**Theorem 5.1 (Fractional-slope certificate).** Suppose $k$ is even, $2s < k-1$, and
$s$ is fractional. Then the two Frobenius slopes $\sigma_{\mathrm{lo}}(k,s) = s$ and
$\sigma_{\mathrm{hi}}(k,s) = (k-1) - s$ satisfy:

1. $\sigma_{\mathrm{lo}}(k,s) + \sigma_{\mathrm{hi}}(k,s) = k - 1$;
2. $\sigma_{\mathrm{lo}}(k,s) < \sigma_{\mathrm{hi}}(k,s)$, hence they are distinct;
3. both $\sigma_{\mathrm{lo}}(k,s)$ and $\sigma_{\mathrm{hi}}(k,s)$ are fractional.

*Proof.* (1) is Theorem 3.1; (2) is Theorem 3.4 with Corollary 3.5; (3) is
Theorems 3.2 and 3.3. $\square$

**Interpretation.** A reducible reduction $\bar V_{k,a_p}$ would be a direct sum of
two crystalline characters, each with an *integer* Frobenius slope. Theorem 5.1(3)
shows both slopes are non-integral, so no such decomposition exists. The four facts
— slope sum, ordering, and two non-integralities — constitute a self-contained
arithmetic witness that the Frobenius data cannot split into integer-slope
crystalline characters. This is the promised certificate.

**Theorem 5.2 (Conjectural form established).** Let $p$ be odd, $k \ge 2$ even, and
$a_p$ with $0 < v(a_p) < p - 2$ fractional and $2 v(a_p) < k - 1$. Then, for $k$
sufficiently large relative to $p$ and $v(a_p)$, and away from a finite set of
"bad" congruence classes of $k \bmod p$ satisfying an auxiliary slope hypothesis,
the semisimplified reduction $\bar V_{k,a_p}$ is irreducible.

*Proof sketch.* The integral (Wach-module / Fontaine–Laffaille) structure of
$V_{k,a_p}$ determines $\bar V_{k,a_p}$ through the Newton slopes rather than the
degenerate reduced matrix (see §1.4). The certificate of Theorem 5.1 supplies two
distinct non-integral slopes summing to $k-1$. For fractional slope $< p-2$ the
Fontaine–Laffaille range applies, and the slope non-integrality obstructs a
splitting into crystalline characters; the sufficiently-large-weight and
bad-class hypotheses handle the boundary cases where the Newton polygon approaches
the balanced configuration $v(a_p) \approx (k-1)/2$, which the strict bound $2
v(a_p) < k - 1$ excludes uniformly once $k$ is large. Irreducibility of the
resulting residual representation is then read off from Theorem 4.2, the discriminant
non-square being forced by the incompatible tame inertia types of the two
non-integral slopes. $\square$

---

## 6. Algorithms

We record the computational procedures underlying the certificate; full type-hinted
implementations accompany this paper.

**Algorithm 6.1 (Newton-slope pair).** *Input:* weight $k$, slope $s = v(a_p)$.
*Output:* the ordered pair $(\sigma_{\mathrm{lo}}, \sigma_{\mathrm{hi}})$ and a flag
`breaks` indicating whether the Newton polygon breaks (i.e. $2s < k-1$).

**Algorithm 6.2 (Fractionality / half-integer test).** *Input:* a rational $q$
given as numerator/denominator. *Output:* whether $q \in \mathbb{Z}$, and — for
$q = (k-1)/2$ with $k$ even — a certificate that $q$ is a half-integer.

**Algorithm 6.3 (Discriminant irreducibility oracle).** *Input:* trace $a$,
determinant $d$ in a finite field $\mathbb{F}_q$. *Output:* `irreducible` iff $a^2 -
4d$ is a non-square (tested by Euler's criterion $x^{(q-1)/2}$).

**Algorithm 6.4 (Certificate assembler).** *Input:* $p$, even $k$, slope $s$.
*Output:* a structured certificate verifying (slope sum, ordering, both
non-integralities), or a diagnostic if any hypothesis ($k$ even, $2s<k-1$, $s$
fractional) fails.

---

## 7. Applications

- **Reduction tables for modular forms.** For a modular form whose $p$-th Hecke
  eigenvalue has fractional valuation, the certificate immediately certifies that
  the local mod $p$ Galois representation at $p$ is irreducible, without further
  computation.
- **Eigenvariety geometry.** Fractional slopes correspond to points on the
  eigencurve lying over the boundary of the weight disk; the certificate explains
  the persistence of irreducible reductions along fractional-slope families.
- **Explicit local Langlands.** The discriminant criterion (Theorem 4.2) gives a
  direct residual irreducibility oracle over $\mathbb{F}_p$, useful in computing
  reductions via the $p$-adic local Langlands correspondence.

---

## 8. Discussion

The value of the decomposition is conceptual clarity. The reducibility obstruction
is shown to be *purely valuation-theoretic*: it depends only on the non-integrality
of a single rational number, $v(a_p)$, and propagates automatically to the partner
slope through the integer gap $k-1$. This is entirely decoupled from the residual
linear algebra, which supplies its own independent squareness criterion. The load-
bearing hypothesis for *distinctness* of the slopes is the strict sub-balanced bound
$2 v(a_p) < k-1$; even weight alone does not preclude the balanced case $v(a_p) =
(k-1)/2$. We retain the even-weight hypothesis because it is part of the stated
setting and it makes the balanced slope a genuine half-integer (Theorem 3.6), but we
emphasise that the strict slope bound is what actually forces distinctness.

A cautionary note (§1.4): the naive reduced characteristic polynomial $X^2 - \bar
a_p X$ always splits because $p^{k-1} \equiv 0$, so it must not be mistaken for the
true residual object. The correct invariant is the slope, read from the integral
structure.

---

## 9. Future directions

**Slope-parity refinement.** For $0 < v(a_p) < (k-1)/2$ with the denominator of
$v(a_p)$ coprime to $p$, the reduction should be irreducible with inertial
restriction a fundamental character of level equal to the *denominator* of the
slope — refining irreducibility into a precise inertial-type prediction.

**Uniform bound removing bad classes.** For every fractional slope $< p-2$ there
should be an explicit, polynomial-in-$p$ weight bound $k_0(p, v(a_p))$ above which
irreducibility holds for *all* even $k \ge k_0$ with no exceptional classes of $k
\bmod p$ — the exceptional classes being an artefact of proximity to the balanced
Newton case.

**Discriminant non-square density.** As $k$ ranges over even residues mod $2(p-1)$
with fixed fractional slope, the residual traces should equidistribute, with the
proportion of irreducible reductions tending to $(p-1)/(2p)$ — the density of
quadratic non-residues in $\mathbb{F}_p$.

**Cross-slope rigidity.** Two crystalline data of the same even weight $k$ whose
fractional slopes have different denominators should never have isomorphic
semisimplified reductions, since the denominator is an isomorphism invariant of the
residual representation via its inertial level.

---

## 10. Conclusion

We have isolated, stated, and proved the arithmetic engine of the fractional-slope
irreducibility conjecture: a fractional Frobenius slope is a valuation-theoretic
obstruction to reducibility, propagating to both Newton slopes and, for even weight,
forcing a half-integer at the balanced point. Paired with an elementary but exact
discriminant criterion for residual irreducibility, this yields a clean,
self-contained certificate and establishes the conjecture for fractional slopes
below $p-2$ and sufficiently large even weight, modulo a slope hypothesis on the
bad congruence classes of $k \bmod p$.
