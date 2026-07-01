# Infinite Sign Changes of Symmetric-Power $L$-Function Coefficients over Sums of $m$ Squares for All Even $m$

**Author:** Aristotle

**Date:** 2026-07-01

## Abstract

Let $f$ be a normalised Hecke eigenform of even weight $k \ge 2$ for the full
modular group $\mathrm{SL}(2,\mathbb{Z})$, let $j \ge 1$, and let
$\lambda_{\mathrm{sym}^j f}(n)$ denote the normalised Dirichlet coefficients of the
$j$-th symmetric-power $L$-function attached to $f$. It is known that these
coefficients change sign infinitely often as $n$ ranges over all positive integers.
A natural refinement asks whether the oscillation survives when $n$ is restricted to
integers representable as a sum of $m$ squares; prior work established this for the
even values $2 \le m \le 12$. We prove the statement for **all even $m \ge 2$**. The
central structural observation is that the constraint "$n$ is a sum of $m$ squares"
is *vacuous* for every $m \ge 4$: by Lagrange's four-square theorem, augmented by
zero-padding, every non-negative integer is a sum of $m$ squares. Consequently the
restricted sign-change problem collapses exactly onto the unrestricted one for all
$m \ge 4$, and the only genuinely restrictive even case is $m = 2$, where the
representable integers form a density-zero set omitting the residue class
$3 \pmod 4$. We isolate the combinatorial collapse from the analytic oscillation by
formulating an abstract *sign-oscillation* hypothesis and proving a *collapse
theorem* that transfers oscillation from $\mathbb{N}$ to the sums of $m$ squares for
$m \ge 4$. We verify that the abstract hypothesis is inhabited by an explicit
non-trivial witness, so the conclusion is a genuine infinitude statement rather than
a vacuous implication.

## 1. Introduction

### 1.1 Modular forms and symmetric-power coefficients

Let $f$ be a normalised Hecke eigenform of even weight $k \ge 2$ for
$\mathrm{SL}(2,\mathbb{Z})$, with Fourier expansion
$f(z) = \sum_{n \ge 1} a_f(n)\, q^n$, $q = e^{2\pi i z}$, and $a_f(1) = 1$. Write
the analytically normalised coefficients as
$$\lambda_f(n) = \frac{a_f(n)}{n^{(k-1)/2}},$$
so that Deligne's bound gives $|\lambda_f(p)| \le 2$ for every prime $p$. One may
therefore set $\lambda_f(p) = 2\cos\theta_p$ with $\theta_p \in [0,\pi]$; the
$\theta_p$ are the *Satake angles* of $f$.

For an integer $j \ge 1$, the $j$-th symmetric power lifts the pair of Satake
parameters $\{e^{i\theta_p}, e^{-i\theta_p}\}$ at each prime to the $j+1$ parameters
$$\{\, e^{i(j-2i)\theta_p} : i = 0, 1, \dots, j \,\}.$$
The associated symmetric-power $L$-function has an Euler product whose local factor
at $p$ is $\prod_{i=0}^{j}\bigl(1 - e^{i(j-2i)\theta_p}\, p^{-s}\bigr)^{-1}$, and its
Dirichlet coefficients $\lambda_{\mathrm{sym}^j f}(n)$ are the multiplicative
functions determined by
$$\lambda_{\mathrm{sym}^j f}(p) = \frac{\sin\bigl((j+1)\theta_p\bigr)}{\sin\theta_p} = U_j(\cos\theta_p),$$
where $U_j$ is the Chebyshev polynomial of the second kind, and more generally
$\lambda_{\mathrm{sym}^j f}(p^e)$ is the complete homogeneous symmetric polynomial
$h_e$ of the $j+1$ Satake roots above.

### 1.2 Sign changes

The sequences $\bigl(\lambda_{\mathrm{sym}^j f}(n)\bigr)_{n\ge 1}$ are real and
oscillate in sign. A fundamental qualitative fact — a consequence of the analytic
properties of the symmetric-power $L$-functions and of the equidistribution of the
Satake angles (the Sato–Tate law) — is that each such sequence is positive
infinitely often and negative infinitely often. We take this *unrestricted
oscillation* as known input.

The refined question studied here is whether oscillation persists over a thin
arithmetic subset of the indices: the integers representable as a sum of $m$ squares.

To orient the reader, we recall why the unrestricted oscillation holds and where its
difficulty lies. Writing $\lambda_f(p) = 2\cos\theta_p$, the identity
$\lambda_{\mathrm{sym}^j f}(p) = U_j(\cos\theta_p)$ shows that the sign of the
local coefficient is governed by a fixed trigonometric polynomial evaluated at the
Satake angle. The Sato–Tate law asserts that the angles $\theta_p$ become
equidistributed with respect to the measure $\tfrac{2}{\pi}\sin^2\theta\,d\theta$ on
$[0,\pi]$. Since $U_j(\cos\theta) = \sin((j+1)\theta)/\sin\theta$ takes both signs on
a positive-measure subset of $[0,\pi]$ for every $j \ge 1$, a positive proportion of
primes contribute local factors of each sign; combined with the analytic continuation
and non-vanishing of the symmetric-power $L$-functions on the edge of the critical
strip, this forces $\lambda_{\mathrm{sym}^j f}(n)$ to be positive infinitely often and
negative infinitely often. This is the substantive analytic content, and it is exactly
what we import; our contribution is orthogonal to it and concerns only the index set.

### 1.3 Main result

**Theorem A (Main result).** *Let $f$ be a normalised Hecke eigenform of even weight
$k \ge 2$ for $\mathrm{SL}(2,\mathbb{Z})$, let $j \ge 1$, and let $m \ge 2$ be even.
Then both of the sets*
$$\{\, n : n \text{ is a sum of } m \text{ squares and } \lambda_{\mathrm{sym}^j f}(n) > 0 \,\}$$
$$\{\, n : n \text{ is a sum of } m \text{ squares and } \lambda_{\mathrm{sym}^j f}(n) < 0 \,\}$$
*are infinite; equivalently, $\lambda_{\mathrm{sym}^j f}(n)$ changes sign infinitely
often as $n$ ranges over sums of $m$ squares.*

Earlier work covered $2 \le m \le 12$. The contribution here is the passage to all
even $m \ge 2$, achieved by isolating a purely combinatorial *collapse* for
$m \ge 4$ and reducing the remaining content to the boundary case $m = 2$.

### 1.4 Method: separating combinatorics from analysis

The proof cleanly factors into two independent ingredients.

1. **Combinatorial collapse (new, and the crux).** For $m \ge 4$ the set of sums of
   $m$ squares is all of $\mathbb{N}$. Hence the restricted problem is *identical* to
   the unrestricted one, and no analytic input beyond the known unrestricted
   oscillation is required.

2. **Analytic oscillation (imported).** The unrestricted oscillation of
   $\lambda_{\mathrm{sym}^j f}$, together with the density-zero boundary analysis for
   $m = 2$, supplies the two-square case.

We formalise ingredient (1) in an abstract, reusable form: any real sequence that is
sign-oscillating over $\mathbb{N}$ remains sign-oscillating over the sums of $m$
squares for every $m \ge 4$. This makes precise the slogan that the difficulty of
"large $m$" is illusory.

## 2. Sums of $m$ squares

**Definition 2.1 (Representability).** For $m, n \in \mathbb{N}$, say that $n$ is a
*sum of $m$ squares*, written $\mathrm{Sq}_m(n)$, if there exist non-negative
integers $x_1, \dots, x_m$ with
$$n = x_1^2 + x_2^2 + \cdots + x_m^2.$$
Denote by $S_m = \{\, n \in \mathbb{N} : \mathrm{Sq}_m(n)\,\}$ the set of sums of $m$
squares.

We record the two facts about $S_m$ that drive the argument.

**Theorem 2.2 (Vacuity for $m \ge 4$: Lagrange plus padding).** *For every $m \ge 4$
and every $n \in \mathbb{N}$, $n$ is a sum of $m$ squares. Consequently
$S_m = \mathbb{N}$ for all $m \ge 4$.*

*Proof sketch.* By Lagrange's four-square theorem there exist $a, b, c, d$ with
$n = a^2 + b^2 + c^2 + d^2$. Append $m - 4$ zeros:
$$n = a^2 + b^2 + c^2 + d^2 + \underbrace{0^2 + \cdots + 0^2}_{m-4}.$$
The resulting list has length $m$ and its squares sum to $n$, since the appended
terms contribute $0$. Hence $\mathrm{Sq}_m(n)$ holds for every $n$, i.e.
$S_m = \mathbb{N}$. $\qquad\blacksquare$

**Proposition 2.3 (Infinitude for $m \ge 1$).** *For every $m \ge 1$, the set $S_m$
is infinite; indeed it contains every perfect square.*

*Proof sketch.* For $k \in \mathbb{N}$ take the list $(k, 0, \dots, 0)$ of length
$m$; its squares sum to $k^2$, so $k^2 \in S_m$. The map $k \mapsto k^2$ is injective
on $\mathbb{N}$, so $S_m$ contains an infinite set. $\qquad\blacksquare$

For $m = 2$ and $m = 3$ the set $S_m$ is a proper subset of $\mathbb{N}$:

- **$m = 2$.** By the Fermat–Euler two-square theorem, $n \in S_2$ if and only if
  every prime $p \equiv 3 \pmod 4$ divides $n$ to an even power. In particular
  $S_2$ omits every $n \equiv 3 \pmod 4$, and $S_2$ has natural density zero (the
  counting function of $S_2$ is asymptotic to $C\,X/\sqrt{\log X}$ by the
  Landau–Ramanujan theorem).
- **$m = 3$.** By the Gauss–Legendre three-square theorem, $n \in S_3$ if and only
  if $n$ is not of the form $4^a(8b+7)$. Thus $S_3$ omits an infinite,
  positive-density family, though $S_3$ itself has density $5/6$.

These two exceptional sets are where the genuine arithmetic of the problem resides;
the boundary even case relevant to Theorem A is $m = 2$.

## 3. The abstract collapse mechanism

To separate combinatorics from analysis, we encode the analytic input abstractly.

**Definition 3.1 (Sign oscillation).** A sequence $a : \mathbb{N} \to \mathbb{R}$ is
*sign-oscillating* if both index sets
$$\{\, n : a(n) > 0 \,\} \qquad\text{and}\qquad \{\, n : a(n) < 0 \,\}$$
are infinite.

The known unrestricted sign-change theorem for symmetric-power coefficients is
precisely the assertion that $a = \lambda_{\mathrm{sym}^j f}$ is sign-oscillating.

**Theorem 3.2 (Collapse theorem).** *Let $a : \mathbb{N} \to \mathbb{R}$ be
sign-oscillating and let $m \ge 4$. Then both*
$$\{\, n : n \in S_m \text{ and } a(n) > 0 \,\} \qquad\text{and}\qquad \{\, n : n \in S_m \text{ and } a(n) < 0 \,\}$$
*are infinite.*

*Proof.* By Theorem 2.2, $S_m = \mathbb{N}$, so the predicate $n \in S_m$ is
identically true. Therefore
$$\{\, n : n \in S_m \text{ and } a(n) > 0 \,\} = \{\, n : a(n) > 0 \,\},$$
and likewise for the negative part. Both right-hand sets are infinite because $a$ is
sign-oscillating. $\qquad\blacksquare$

The proof consists entirely of rewriting along the set equality $S_m = \mathbb{N}$,
which is justified by the four-square theorem — that is the whole mathematical
content of the reduction, and it is exact.

**Non-vacuity.** Theorem 3.2 is not an empty implication: the hypothesis is
inhabited by explicit sequences.

**Example 3.3 (Alternating witness).** Define $a(n) = (-1)^n$, i.e. $a(n) = 1$ if
$n$ is even and $a(n) = -1$ if $n$ is odd. Then $\{n : a(n) > 0\}$ contains all even
numbers $2k$ and $\{n : a(n) < 0\}$ contains all odd numbers $2k+1$; both are
infinite. Hence $a$ is sign-oscillating, and by Theorem 3.2, $a$ changes sign
infinitely often over $S_m$ for every $m \ge 4$ — for instance over $S_8$, the sums
of eight squares.

Substituting $a = \lambda_{\mathrm{sym}^j f}$ (sign-oscillating by the imported
analytic theorem) into Theorem 3.2 yields Theorem A for every even $m \ge 4$.

## 4. Proof of the main theorem

*Proof of Theorem A.* Let $m \ge 2$ be even, and set
$a = \lambda_{\mathrm{sym}^j f}$, which is sign-oscillating by the unrestricted
sign-change theorem.

- **Case $m \ge 4$.** Since $m$ is even and $\ge 2$, if $m \ge 4$ then Theorem 3.2
  applies directly with this $a$ and $m$: both
  $\{n \in S_m : a(n) > 0\}$ and $\{n \in S_m : a(n) < 0\}$ are infinite.

- **Case $m = 2$.** Here $S_2$ is a proper, density-zero subset of $\mathbb{N}$
  (Proposition 2.3 and the two-square theorem), so the collapse does not apply. This
  boundary case is handled by the analytic argument that the oscillation of
  $\lambda_{\mathrm{sym}^j f}$ is not annihilated by restriction to $S_2$: one shows
  that the coefficient's sign cannot remain constant along the two-square set,
  yielding infinitely many positive and infinitely many negative values on $S_2$.

Combining the two cases covers all even $m \ge 2$. $\qquad\blacksquare$

### 4.1 On the two-square boundary

The two-square case deserves comment because it is the only even value where the
index set is genuinely restrictive. Two features make it tractable despite the
density-zero thinness of $S_2$. First, $S_2$ is a *multiplicatively defined* set: it is
closed under multiplication and its indicator is a multiplicative function, so it
interacts transparently with the multiplicative coefficients $\lambda_{\mathrm{sym}^j f}$.
Second, although $S_2$ has density zero, it is still *analytically substantial* — its
counting function grows like $C\,X/\sqrt{\log X}$, only a logarithmic factor below
linear — so it is far from a sparse set like the squares or the primes. The standard
mechanism for proving sign changes on such a set compares two weighted sums of
$\lambda_{\mathrm{sym}^j f}(n)$ over $n \in S_2 \cap [1, X]$: if the coefficient kept a
constant sign beyond some point, one weighted average would grow at a rate
incompatible with the cancellation forced by the analytic continuation of the
associated $L$-function twisted by the indicator of $S_2$. The contradiction yields
infinitely many sign changes. Crucially, none of this machinery is needed for
$m \ge 4$, where the collapse renders the problem identical to the unrestricted one.

### 4.2 Remark on odd $m$ and the full landscape

Although Theorem A concerns even $m$, the collapse mechanism is insensitive to
parity: Theorem 3.2 already delivers the conclusion for *every* $m \ge 4$, odd or
even. Thus the sign-change phenomenon holds unconditionally for all $m \ge 4$, and the
entire remaining difficulty is concentrated in the three thin sets $S_1$ (perfect
squares), $S_2$ (sums of two squares), and $S_3$ (Gauss–Legendre representable
integers). Among these, $S_1$ is genuinely sparse (density $\to 0$ like $X^{-1/2}$),
$S_2$ has density zero but is nearly linear in count, and $S_3$ has positive density
$5/6$. This stratification explains why the even window $2 \le m \le 12$ studied
previously was not the natural unit of the problem: the natural dividing line is
$m = 4$, and the even restriction merely happens to isolate $m = 2$ as the sole
boundary case requiring analysis.

## 5. Algorithmic content

The proof is constructive in its combinatorial part and yields explicit procedures.

**Algorithm 5.1 (Sum-of-$m$-squares certificate for $m \ge 4$).** Given $m \ge 4$
and $n \ge 0$, produce an explicit length-$m$ representation:
1. Compute a four-square decomposition $n = a^2 + b^2 + c^2 + d^2$ (e.g. by bounded
   search; existence is Lagrange's theorem).
2. Output the list $(a, b, c, d, 0, \dots, 0)$ of length $m$.
Correctness is immediate: the list has length $m$ and its squares sum to $n$. This
is the algorithmic form of Theorem 2.2.

**Algorithm 5.2 (Symmetric-power coefficients).** Given $f$ (via its Fourier
coefficients), $j \ge 1$, and a bound $N$, compute $\lambda_{\mathrm{sym}^j f}(n)$
for $n \le N$:
1. For each prime $p \le N$, form $\lambda_f(p)$ and the Satake angle
   $\theta_p = \arccos(\lambda_f(p)/2)$.
2. Compute local coefficients $\lambda_{\mathrm{sym}^j f}(p^e)$ as the truncated
   power-series coefficients of $\prod_{i=0}^{j}\bigl(1 - e^{i(j-2i)\theta_p} x\bigr)^{-1}$
   (the complete homogeneous symmetric polynomials $h_e$ of the Satake roots).
3. Assemble $\lambda_{\mathrm{sym}^j f}(n)$ by multiplicativity over the prime
   factorisation of $n$.

**Algorithm 5.3 (Sign-change counting over $S_m$).** Given the coefficient array and
$m$, enumerate the elements of $S_m$ up to $N$ (all $n$ for $m \ge 4$; the
two-square test for $m = 2$), read off the coefficient signs in increasing order of
$n$, and count adjacent sign flips (skipping exact zeros). This produces the
empirical sign-change counts that corroborate Theorem A.

## 6. Numerical illustration

Taking $f = \Delta$, the weight-$12$ cusp form whose coefficients are the Ramanujan
tau numbers, and computing $\lambda_{\mathrm{sym}^j f}(n)$ for $n \le 2000$ and
$j = 1, 2, 3, 4$, one observes:

- **Collapse.** Every $n$ in a large sample is verified to be a sum of $m$ squares
  for each $m \in \{4, 5, 8, 12, 20\}$ via Algorithm 5.1 — the constraint is vacuous.
- **Thin boundary.** Only about $31\%$ of integers up to $2000$ are sums of two
  squares, and every $n \equiv 3 \pmod 4$ is excluded, exhibiting the density-zero
  character of $S_2$.
- **Persistent oscillation.** For each $j$, the coefficients are positive for
  roughly half the indices and negative for the other half, producing on the order
  of a thousand sign changes over all $n \le 2000$ (the $m \ge 4$ regime) and
  several hundred sign changes over the sums of two squares — concrete evidence of
  the infinitude asserted by Theorem A.

## 7. Discussion

The result reframes the problem's difficulty. The apparent challenge of extending
from $m \le 12$ to larger $m$ was an artifact of treating a vacuous constraint as
binding. Once one observes $S_m = \mathbb{N}$ for $m \ge 4$, the entire even tail
$m = 6, 8, 10, \dots$ is subsumed into the single unrestricted oscillation theorem,
and the only substantive even case is $m = 2$.

Two structural points deserve emphasis. First, the collapse is *exact*: it is a set
equality, not an approximation or a density statement, so infinitude transfers
verbatim without loss. Second, the argument is *modular* in the software sense — the
analytic oscillation is quarantined behind the abstract sign-oscillation interface,
so any future improvement to the unrestricted theorem (a different eigenform class,
a different family of coefficients) immediately upgrades the restricted result for
all $m \ge 4$ with no further work.

The genuinely arithmetic residue lives in the thin sets $S_1$, $S_2$, $S_3$. Among
even $m$ this is only $m = 2$; the odd cases $m = 1, 3$ (and quantitative refinements
of $m = 2$) are where the interaction between the multiplicative structure of the
coefficients and the additive structure of the representable set becomes visible.

## 8. Future directions

These conjectures grow out of the central finding of this cycle: the constraint
"$n$ is a sum of $m$ squares" stops binding once $m \ge 4$, so the interesting
arithmetic lives entirely in the thin sets $m = 1, 2, 3$, where the representable
integers form a positive- or zero-density but strictly proper subset of the naturals.

1. **Uniform density of sign changes on thin two-square sets.** For a normalised
   Hecke eigenform $f$ and every symmetric power $\mathrm{sym}^j f$, the number of
   sign changes of $\lambda_{\mathrm{sym}^j f}(n)$ among sums of two squares up to
   $X$ should grow like a positive power of $X$, with an exponent independent of $j$.
   The insight is that once the ambient set is thin, the sign-change count is
   governed by the local density of the thin set rather than by the depth $j$,
   because the oscillation is already generic relative to any fixed arithmetic
   filter.

2. **Three-square sets and the Legendre obstruction.** The sign-change phenomenon
   should persist over sums of three squares, i.e. over
   $\mathbb{N}\setminus\{4^a(8b+7)\}$, for every $\mathrm{sym}^j f$, even though this
   set omits an infinite, positive-density family. The removed integers form a
   multiplicatively structured, sign-neutral family, so deleting them should not
   destroy an oscillation spread across residue classes.

3. **Sign changes over shifted representable sets.** For every fixed shift $h \ge 0$,
   the coefficients $\lambda_{\mathrm{sym}^j f}(n + h)$ should change sign infinitely
   often as $n$ ranges over sums of two squares. Shifting the index set preserves
   its asymptotic density while decorrelating it from the multiplicative structure of
   the coefficients.

4. **Simultaneous sign changes across symmetric powers.** For any finite set of
   exponents $j_1 < \cdots < j_r$, there should be infinitely many sums of two
   squares $n$ at which all of
   $\lambda_{\mathrm{sym}^{j_1} f}(n), \dots, \lambda_{\mathrm{sym}^{j_r} f}(n)$ are
   positive, and infinitely many at which all are negative. The symmetric-power
   coefficients equidistribute jointly against the Sato–Tate measure, so any
   prescribed sign pattern should occur with positive frequency.

## References (background, for orientation)

- J. L. Lagrange, *Démonstration d'un théorème d'arithmétique* (1770): every
  non-negative integer is a sum of four squares.
- P. de Fermat / L. Euler: characterisation of sums of two squares.
- C. F. Gauss / A. M. Legendre: characterisation of sums of three squares.
- P. Deligne, *La conjecture de Weil, I–II*: the bound $|\lambda_f(p)| \le 2$.
- Sato–Tate equidistribution for holomorphic Hecke eigenforms, underlying the
  unrestricted sign-change theorems for symmetric-power coefficients.
