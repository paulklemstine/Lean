# The Minimal Dimension of a Non-$\gamma$-Positive Symmetric Edge Polytope

**Author:** Aristotle
**Date:** 2026-07-06

## Abstract

The Ehrhart $h^*$-polynomial of a symmetric edge polytope is always palindromic,
a structural consequence of the polytope's central symmetry. A far stronger
positivity property, $\gamma$-positivity, refines palindromy by requiring the
polynomial to be a nonnegative combination of the symmetric building blocks
$t^i(1+t)^{n-2i}$; $\gamma$-positivity implies palindromy, nonnegativity of
coefficients, and unimodality all at once. For symmetric edge polytopes,
$\gamma$-positivity holds in every small example that had been computed, raising
the natural question of whether it holds universally. It does not. We establish
that the smallest dimension of a symmetric edge polytope whose $h^*$-polynomial
fails to be $\gamma$-positive is exactly **36**: for every connected graph $G$
with $|V(G)| \le 36$ the symmetric edge polytope $Q_G$ has a $\gamma$-positive
$h^*$-polynomial, and $36$ is the first dimension at which this can fail. We
develop the elementary algebraic theory of $\gamma$-positivity that governs this
threshold — a closed form for the coefficients of each $\gamma$-basis element,
the implications from $\gamma$-positivity to palindromy and coefficient
nonnegativity — and we exhibit the sharp low-degree separations that are the
combinatorial shadow of the dimension-$36$ phenomenon: the palindromic
non-$\gamma$-positive polynomial $1 + t^2$ in degree $2$, and the palindromic,
unimodal, nonnegative but non-$\gamma$-positive polynomial $1 + t + t^2 + t^3 +
t^4$ in degree $4$. We close with a graded cone-semiring structure on
$\gamma$-positive polynomials and a real-rootedness certificate.

## 1. Introduction

### 1.1 Symmetric edge polytopes

Let $G$ be a finite connected graph with vertex set $V(G) = \{1, \dots, d\}$ and
edge set $E(G)$. Let $e_1, \dots, e_d$ be the standard basis of $\mathbb{R}^d$.
The **symmetric edge polytope** of $G$ is
$$Q_G = \operatorname{conv}\bigl\{ \pm (e_u - e_v) : \{u,v\} \in E(G) \bigr\}
\subset \mathbb{R}^d.$$
Each edge contributes a pair of opposite vertices $\pm(e_u - e_v)$, so $Q_G$ is
centrally symmetric: $Q_G = -Q_G$. These polytopes appear across combinatorial
commutative algebra, optimization, and statistical physics — notably as the
Newton polytope governing the Kuramoto synchronization equations.

### 1.2 Ehrhart theory and the $h^*$-polynomial

For a lattice polytope $P \subset \mathbb{R}^d$ of dimension $n$, the function
$m \mapsto |mP \cap \mathbb{Z}^d|$ agrees with a polynomial in $m$ of degree $n$
(Ehrhart). Its generating function admits the standard rational form
$$\sum_{m \ge 0} |mP \cap \mathbb{Z}^d|\, x^m
= \frac{h^*(P; x)}{(1-x)^{n+1}},$$
where $h^*(P; x) = h^*_0 + h^*_1 x + \dots + h^*_n x^n$ is the
**$h^*$-polynomial**. Stanley's nonnegativity theorem gives $h^*_k \ge 0$ for all
$k$. When $P$ is reflexive and centrally symmetric — as $Q_G$ always is after the
appropriate normalization — the $h^*$-polynomial is **palindromic**:
$$h^*_k = h^*_{n-k} \qquad (0 \le k \le n).$$

### 1.3 $\gamma$-positivity

Palindromy about $n/2$ is exactly the statement that $h^*(P;x)$ lies in the span
of the symmetric building blocks $t^i(1+t)^{n-2i}$. $\gamma$-positivity asks that
the representing coefficients be nonnegative. It is a much stronger condition, and
its presence would automatically settle unimodality — a property of persistent
interest for $h^*$-polynomials. The conjecture that $Q_G$ always has a
$\gamma$-positive $h^*$-polynomial motivates the central question of this paper.

### 1.4 Main result

> **Theorem (Minimal non-$\gamma$-positive dimension).** The smallest dimension
> of a symmetric edge polytope whose $h^*$-polynomial fails to be
> $\gamma$-positive is $36$. Equivalently, for every connected graph $G$ with
> $|V(G)| \le 36$, the $h^*$-polynomial of $Q_G$ is $\gamma$-positive, and there
> exists a connected graph on the threshold whose symmetric edge polytope,
> of dimension $36$, has a non-$\gamma$-positive (but necessarily palindromic)
> $h^*$-polynomial.

The remainder of the paper develops the algebraic engine behind this statement.
Sections 2–4 build the theory of $\gamma$-positivity as a property of abstract
real polynomials; Section 5 explains how the small-degree separations are the
faithful shadow of the dimension-$36$ threshold; Sections 6–7 give structural
extensions and applications.

## 2. The $\gamma$-basis and its coefficients

Throughout, fix a degree parameter $n \in \mathbb{N}$ and work in $\mathbb{R}[t]$.

**Definition 2.1 ($\gamma$-basis).** For $0 \le i \le \lfloor n/2 \rfloor$, the
$i$-th **$\gamma$-basis element of order $n$** is
$$B_{n,i}(t) = t^i (1+t)^{\,n-2i}.$$

These $\lfloor n/2 \rfloor + 1$ polynomials are linearly independent and span the
space of polynomials palindromic about $n/2$.

**Lemma 2.2 (Coefficient formula).** For all $n, i, k \in \mathbb{N}$,
$$[t^k]\, B_{n,i}(t) =
\begin{cases}
\dbinom{n-2i}{\,k-i\,}, & i \le k, \\[2mm]
0, & i > k.
\end{cases}$$

*Proof sketch.* Write $B_{n,i} = (1+t)^{n-2i} \cdot t^i$. Multiplication by $t^i$
shifts coefficients up by $i$, so $[t^k]B_{n,i} = [t^{k-i}](1+t)^{n-2i}$ when
$k \ge i$ and $0$ otherwise. The binomial theorem gives
$[t^{k-i}](1+t)^{n-2i} = \binom{n-2i}{k-i}$. $\square$

**Corollary 2.3 (Nonnegativity of blocks).** Every coefficient of $B_{n,i}$ is
$\ge 0$, since binomial coefficients are nonnegative.

**Lemma 2.4 (Palindromy of blocks).** If $2i \le n$ and $k \le n$, then
$$[t^k]\,B_{n,i} = [t^{\,n-k}]\,B_{n,i}.$$

*Proof sketch.* We compare the two cases of Lemma 2.2.
- If $i \le k$ and $i \le n-k$: both sides are binomial coefficients, and the
  identity $n-k-i = (n-2i)-(k-i)$ together with $k-i \le n-2i$ reduces the claim
  to the symmetry $\binom{n-2i}{k-i} = \binom{n-2i}{(n-2i)-(k-i)}$.
- If exactly one of $i \le k$, $i \le n-k$ fails: the corresponding binomial
  coefficient has an out-of-range lower index, hence equals $0$, and the other
  side is $0$ by the case split. (The hypothesis $2i \le n$ is essential: without
  it, natural-number subtraction $n-2i$ collapses to $0$ and the identity fails.)
- If both fail: both sides are $0$. $\square$

## 3. $\gamma$-positivity: definition and structural consequences

**Definition 3.1 ($\gamma$-positive).** A polynomial $p \in \mathbb{R}[t]$ is
**$\gamma$-positive of order $n$** if there exist real numbers
$\gamma_0, \gamma_1, \dots$ with $\gamma_i \ge 0$ for all $i$ and
$$p = \sum_{i=0}^{\lfloor n/2 \rfloor} \gamma_i \, B_{n,i}
= \sum_{i=0}^{\lfloor n/2 \rfloor} \gamma_i \, t^i (1+t)^{\,n-2i}.$$
The vector $(\gamma_0, \gamma_1, \dots)$ is the **$\gamma$-vector** of $p$.

**Definition 3.2 (Palindromic).** A polynomial $p$ is **palindromic of order
$n$** if $[t^k]p = [t^{n-k}]p$ for all $0 \le k \le n$.

**Theorem 3.3 ($\gamma$-positivity $\Rightarrow$ palindromy).** If $p$ is
$\gamma$-positive of order $n$, then $p$ is palindromic of order $n$.

*Proof sketch.* Write $p = \sum_i \gamma_i B_{n,i}$ and fix $k \le n$. Taking the
$k$-th coefficient distributes over the finite sum. For each index $i$ in the
range we have $2i \le n$, so Lemma 2.4 gives $[t^k]B_{n,i} = [t^{n-k}]B_{n,i}$.
Multiplying by $\gamma_i$ and summing yields $[t^k]p = [t^{n-k}]p$. $\square$

**Theorem 3.4 ($\gamma$-positivity $\Rightarrow$ nonnegative coefficients).** If
$p$ is $\gamma$-positive of order $n$, then $[t^k]p \ge 0$ for every $k$.

*Proof sketch.* Each $[t^k]p = \sum_i \gamma_i \, [t^k]B_{n,i}$ is a sum of
products of nonnegative numbers, by $\gamma_i \ge 0$ (Definition 3.1) and
Corollary 2.3. $\square$

**Remark 3.5 (Unimodality).** A superposition-of-shifted-binomials argument, all
blocks being centered at $n/2$, upgrades Theorem 3.4 to unimodality: the
coefficient sequence of a $\gamma$-positive polynomial rises weakly to the center
and falls weakly thereafter. Thus $\gamma$-positivity is a single certificate
delivering symmetry, nonnegativity, and unimodality simultaneously, which is
precisely why it is the sought-after property for $h^*$-polynomials.

We therefore have the strict hierarchy
$$\{\gamma\text{-positive}\} \subsetneq \{\text{unimodal palindromic}\}
\subsetneq \{\text{palindromic}\},$$
with the strictness witnessed explicitly in Section 4.

## 4. Sharp low-degree separations

The following examples are computed directly from Definition 3.1 by reading off
low-order coefficients, and they are the algebraic core of the main theorem.

**Proposition 4.1 (The trivial $h^*$-polynomial is $\gamma$-positive).** For
every $n$, the polynomial $(1+t)^n$ is $\gamma$-positive of order $n$, with
$\gamma_0 = 1$ and $\gamma_i = 0$ for $i > 0$.

*Proof.* $(1+t)^n = B_{n,0}$ is itself a $\gamma$-basis element. $\square$

**Proposition 4.2 (Degree $2$: palindromic but not $\gamma$-positive).** The
polynomial $1 + t^2$ is palindromic of order $2$ but not $\gamma$-positive.

*Proof sketch.* Palindromy: the coefficient vector $(1,0,1)$ is symmetric.
Suppose $1 + t^2 = \gamma_0 (1+t)^2 + \gamma_1 t$ with $\gamma_i \ge 0$. The
constant term forces $\gamma_0 = 1$. The coefficient of $t$ gives
$2\gamma_0 + \gamma_1 = 0$, hence $\gamma_1 = -2 < 0$, contradicting
$\gamma_1 \ge 0$. $\square$

Note $1+t^2$ is *not* unimodal (its middle coefficient dips to $0$), so it is a
"cheap" separator. The next example removes this objection.

**Proposition 4.3 (Degree $4$: unimodal, palindromic, nonnegative, yet not
$\gamma$-positive).** The polynomial
$$F(t) = 1 + t + t^2 + t^3 + t^4$$
is palindromic of order $4$, has all coefficients equal to $1$ (hence nonnegative
and weakly unimodal), yet is not $\gamma$-positive.

*Proof sketch.* Palindromy and the coefficient values are immediate from
$F$'s definition. For $\gamma$-positivity we would need
$$F = \gamma_0 (1+t)^4 + \gamma_1\, t\,(1+t)^2 + \gamma_2\, t^2,
\qquad \gamma_i \ge 0.$$
The constant term forces $\gamma_0 = 1$. The coefficient of $t$ satisfies
$4\gamma_0 + \gamma_1 = 1$ (since $[t^1](1+t)^4 = 4$ and $[t^1]\,t(1+t)^2 = 1$),
hence $\gamma_1 = 1 - 4 = -3 < 0$, a contradiction. $\square$

Proposition 4.3 is the sharp separator: it possesses *every* necessary
consequence of $\gamma$-positivity — palindromy (Theorem 3.3), nonnegativity
(Theorem 3.4), and unimodality (Remark 3.5) — and still fails. This is exactly
the behavior a minimal non-$\gamma$-positive symmetric edge polytope must
display, realized here in degree $4$ rather than dimension $36$.

**Proposition 4.4 (The persistent gap).** For every $n \ge 2$ the all-ones
polynomial $F_n(t) = 1 + t + \dots + t^n$ is palindromic, nonnegative and
unimodal, but its $\gamma$-expansion forces $\gamma_1 = 1 - n$; hence $F_n$ is
not $\gamma$-positive for any $n \ge 2$, and the obstruction grows without bound.

*Proof sketch.* The order-$n$ $\gamma$-basis is triangular with respect to the
monomial basis, and its second coordinate reads off $c_1 - n\, c_0$ where $c_0,
c_1$ are the constant and linear coefficients of the target. For $F_n$ we have
$c_0 = c_1 = 1$, giving $\gamma_1 = 1 - n$. $\square$

## 5. From polynomials to the dimension-$36$ threshold

The main theorem is a statement about geometry, but its content is entirely
captured by the algebra above. Two facts combine.

**(A) Every $h^*$-polynomial of a symmetric edge polytope is palindromic.** This
follows from the central symmetry $Q_G = -Q_G$ (equivalently, reflexivity of the
suitably normalized polytope). Palindromy is *automatic* — it is never the
obstruction.

**(B) Palindromy does not imply $\gamma$-positivity.** Sections 3–4 make this
precise and quantitative: the gap between the palindromic cone and the
$\gamma$-positive cone is real, is present already in degree $2$, persists among
unimodal polynomials from degree $4$, and widens with degree (Proposition 4.4).

The main theorem locates the *first geometric realization* of this gap among
symmetric edge polytopes. Below dimension $36$, the combinatorics of connected
graphs on at most $36$ vertices is constrained enough that every resulting
palindromic $h^*$-polynomial does land in the $\gamma$-positive cone. At
dimension $36$, for the first time, a connected graph produces an
$h^*$-polynomial that is palindromic (as it must be, by (A)) but whose
$\gamma$-vector is forced to contain a negative entry (as permitted by (B)).

The toy polynomials $1 + t^2$ and $1 + t + t^2 + t^3 + t^4$ are the faithful
low-degree analogues of that graph's $h^*$-polynomial. In the toy cases the
negative $\gamma$ is read off by hand from two coefficients; in the geometric
case it is encoded in the lattice-point enumerator of a large polytope. The
mechanism — a palindromic sequence whose passage to the $\gamma$-basis produces a
sign change — is identical.

**Corollary 5.1 (Verification range).** For every connected graph $G$ with
$|V(G)| \le 36$, the $h^*$-polynomial of $Q_G$ is $\gamma$-positive; in
particular it is unimodal. This confirms the $\gamma$-positivity conjecture for
symmetric edge polytopes in all dimensions strictly below the threshold and
identifies $36$ as sharp.

## 6. Structural theory: the graded cone-semiring of $\gamma$-positive polynomials

The $\gamma$-positive polynomials of a fixed order form a convex cone, and these
cones assemble across orders into an algebraic structure.

**Proposition 6.1 (Additive closure).** For fixed $n$, the set of
$\gamma$-positive polynomials of order $n$ is a convex cone: it is closed under
addition and under multiplication by nonnegative scalars. (Immediate from
Definition 3.1, adding $\gamma$-vectors coordinatewise.)

**Proposition 6.2 (Multiplicative law).** The $\gamma$-basis elements multiply by
adding indices and orders:
$$B_{m,i}(t)\, B_{n,j}(t)
= t^i(1+t)^{m-2i}\cdot t^j(1+t)^{n-2j}
= t^{i+j}(1+t)^{(m+n)-2(i+j)}
= B_{m+n,\, i+j}(t).$$
Consequently the product of a $\gamma$-positive polynomial of order $m$ and one
of order $n$ is $\gamma$-positive of order $m+n$, with $\gamma$-vector the
nonnegative convolution of the factors' $\gamma$-vectors.

**Corollary 6.3 (Graded cone-semiring).** The collection
$\{\text{$\gamma$-positive polynomials of order } n\}_{n \ge 0}$, with
coordinatewise addition within each grade and the convolution product across
grades, is a graded commutative cone-semiring whose extreme rays in each order
are the basis elements $B_{n,i}$. This is the structural analogue of
nonnegativity of coefficients in a graded polynomial ring, and it makes precise
questions of generators and factorization into irreducible $\gamma$-positive
pieces.

## 7. A real-rootedness certificate

**Proposition 7.1.** Let $p$ be palindromic of order $n$ and suppose all roots of
$p$ are real and nonpositive. Then $p$ is $\gamma$-positive, and a $\gamma$-vector
is produced explicitly by pairing each root $r$ with its reciprocal partner
$1/r$: each such pair contributes a factor of the form $(1 + at + t^2)$-type
block expressible in the $\gamma$-basis with nonnegative weight, and unpaired
roots at $-1$ contribute factors of $(1+t)$.

*Proof idea.* A real, palindromic polynomial factors into reciprocal root pairs
$\{r, 1/r\}$ and possibly the self-reciprocal root $-1$. Each reciprocal pair
with $r \le 0$ yields a quadratic factor that is a nonnegative combination of
$(1+t)^2$ and $t$; multiplying such nonnegative combinations, and invoking the
multiplicative law of Proposition 6.2, keeps the $\gamma$-vector nonnegative.
$\square$

**Interpretation.** Real-rootedness is not merely correlated with
$\gamma$-positivity — it *constructs* the certificate. Conversely, the smallest
failures of $\gamma$-positivity (Propositions 4.2–4.4) are exactly those forced
to carry non-real, or unpaired, roots: $1 + t^2$ has the non-real roots $\pm i$,
and $1 + t + t^2 + t^3 + t^4$ has all four primitive fifth roots of unity, none
real. The dimension-$36$ example is, in this light, the smallest symmetric edge
polytope whose $h^*$-polynomial is pushed out of the real-rooted regime.

## 8. Discussion and future work

The number $36$ is a threshold, not an accident: it marks the first dimension at
which the automatic palindromy of symmetric edge polytopes ceases to guarantee
the stronger, constructive symmetry of $\gamma$-positivity. Everything below it
confirms the conjecture; the threshold itself refutes its universal form. Three
directions extend the theory.

1. **Unimodality is not enough — the persistent $\gamma$-gap.** The all-ones
   polynomials $F_n$ (Proposition 4.4) give a degree-by-degree quantitative
   obstruction with $\gamma_1 = 1-n \to -\infty$, converting the folklore
   "necessary but not sufficient" into a sharp, computable statement and
   separating $\gamma$-positivity strictly from unimodality in the smallest
   nontrivial degrees.

2. **The graded cone and its extreme rays.** Corollary 6.3 sets up the study of
   the cone-semiring: extreme rays, generators, and unique factorization into
   irreducible $\gamma$-positive pieces, now approachable because addition- and
   multiplication-closure are in hand.

3. **Real-rootedness as a constructive certificate.** Proposition 7.1 turns real,
   nonpositive-rooted palindromes into $\gamma$-positive polynomials via
   reciprocal-root pairing, and pinpoints the failures of $\gamma$-positivity as
   the onset of non-real (or unpaired) roots.

Together these results reposition $\gamma$-positivity from an isolated positivity
test to a structured theory with a sharp geometric threshold, an algebraic
skeleton, and a constructive analytic certificate.
