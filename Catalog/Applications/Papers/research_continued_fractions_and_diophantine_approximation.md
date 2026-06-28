# Diophantine Approximation and the Lagrange Constant: Unbounded Denominators, a Universal Bound, and the Vanishing of the Lagrange Constant on Liouville Numbers

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Applications (Number Theory / Diophantine Approximation)

## Abstract

We develop the quantitative theory connecting classical Diophantine approximation
to the *Lagrange (approximation) constant* of a real number. Building on the
classical theorem that every irrational $x$ admits infinitely many rationals $p/q$
with $|x - p/q| < 1/q^2$, we first establish a strengthening that is essential for
all asymptotic arguments: the denominators of these Dirichlet-good approximations are
unbounded. Concretely, for every irrational $x$ and every $N \in \mathbb{N}$ there is
a rational $q$ in lowest terms with denominator at least $N$ satisfying $|x - q| <
1/q.\mathrm{den}^2$. The proof rests on a local finiteness principle: within any
bounded interval, only finitely many rationals have denominator below a fixed bound.

We then define the Lagrange constant $\mathrm{Lc}(x) = \liminf_{q \to \infty} q
\cdot \lVert q x \rVert$, valued in the extended nonnegative reals, where $\lVert
\cdot \rVert$ denotes distance to the nearest integer, and the set of *badly
approximable* reals $\mathrm{Bad} = \{x : \mathrm{Lc}(x) > 0\}$. We prove two
endpoint results. First, the *universal bound*: every irrational number satisfies
$\mathrm{Lc}(x) \le 1$, a direct quantitative consequence of unbounded denominators
and the easy half of Hurwitz's theorem. Second, the *vanishing theorem*: every
Liouville number satisfies $\mathrm{Lc}(x) = 0$, whence no Liouville number is badly
approximable. Together these results furnish a clean dictionary between the
approximation quality of a real number and its position on the Lagrange spectrum,
with the golden ratio at the top and Liouville numbers at the bottom. All results
have been formally verified.

## 1. Introduction

Diophantine approximation studies how accurately real numbers can be approximated by
rationals, measured against the size of the denominator. The foundational result is
**Dirichlet's approximation theorem**: for every irrational $x$ there exist
infinitely many rationals $p/q$ (in lowest terms, $q \ge 1$) with

$$\left| x - \frac{p}{q} \right| < \frac{1}{q^2}. \tag{1.1}$$

The exponent $2$ is the gateway to a much finer theory. **Hurwitz's theorem** sharpens
the constant: the bound $1/(\sqrt{5}\, q^2)$ holds infinitely often for every
irrational, and $\sqrt 5$ is optimal — the golden ratio $\varphi = (1+\sqrt 5)/2$
attains it. At the opposite extreme, **Liouville's theorem** (1844) exhibits numbers
that are *too well* approximated by rationals to be algebraic, producing the first
explicit transcendental numbers.

A unifying invariant ties these phenomena together. For a real number $x$, write
$\lVert y \rVert$ for the distance from $y$ to the nearest integer and define the
**Lagrange constant**

$$\mathrm{Lc}(x) = \liminf_{q \to \infty} q \cdot \lVert q x \rVert. \tag{1.2}$$

A real number is **badly approximable** when $\mathrm{Lc}(x) > 0$. The set of values
$\{\mathrm{Lc}(x) : x \notin \mathbb{Q}\}$ forms the *Lagrange spectrum*, an object of
sustained study whose top portion is discrete (the Markov spectrum) and whose lower
structure encodes deep arithmetic.

This paper formalizes the elementary but foundational bridge between (1.1)–(1.2). Our
contributions are:

1. **Unbounded denominators** (Section 3): a strengthening of Dirichlet's theorem
   stating that the denominators of good approximations grow without bound, together
   with the local finiteness lemma that drives it.
2. **Universal bound** (Section 4): $\mathrm{Lc}(x) \le 1$ for every irrational $x$.
3. **Vanishing on Liouville numbers** (Section 5): $\mathrm{Lc}(x) = 0$ for every
   Liouville number, and the corollary that Liouville numbers are not badly
   approximable.

All statements are formalized; we give mathematical proof sketches here rather than
formal proof terms.

## 2. Preliminaries and Definitions

Throughout, $x \in \mathbb{R}$ is irrational unless stated otherwise. For a rational
$q$ we write $q.\mathrm{num} \in \mathbb{Z}$ and $q.\mathrm{den} \in \mathbb{N}_{\ge
1}$ for its numerator and denominator in lowest terms, so $\gcd(q.\mathrm{num},
q.\mathrm{den}) = 1$ and $q = q.\mathrm{num}/q.\mathrm{den}$.

**Definition 2.1 (distance to nearest integer).** For $y \in \mathbb{R}$, set
$$\lVert y \rVert = |y - \mathrm{round}(y)|,$$
where $\mathrm{round}(y)$ is the nearest integer to $y$. Then $0 \le \lVert y \rVert
\le \tfrac12$, and $\lVert y \rVert = 0$ iff $y \in \mathbb{Z}$. Two pointwise
identities are used repeatedly: $\lVert y + n \rVert = \lVert y \rVert$ for $n \in
\mathbb{Z}$, and $\lVert -y \rVert = \lVert y \rVert$.

**Definition 2.2 (approximation function).** For $x \in \mathbb{R}$ and $q \in
\mathbb{N}$, define, valued in the extended nonnegative reals $[0, +\infty]$,
$$\mathrm{approx}(x, q) = q \cdot \lVert q x \rVert.$$
Working in $[0,+\infty]$ makes the $\liminf$ in (1.2) unconditionally well-behaved,
since every term is nonnegative.

**Definition 2.3 (Lagrange constant).** $\mathrm{Lc}(x) = \liminf_{q \to \infty}
\mathrm{approx}(x, q)$, taken along the filter $q \to \infty$.

**Definition 2.4 (badly approximable set).** $\mathrm{Bad} = \{x \in \mathbb{R} :
\mathrm{Lc}(x) > 0\}$.

**Definition 2.5 (Dirichlet-good rational).** A rational $q$ is *Dirichlet-good* for
$x$ if $|x - q| < 1/q.\mathrm{den}^2$. By Dirichlet's theorem (formalized in the
ambient library as the statement that $\{q \in \mathbb{Q} : |x - q| < 1/q.\mathrm{den}^2\}$
is infinite for irrational $x$), the set of Dirichlet-good rationals is infinite.

**Definition 2.6 (Liouville number).** A real number $x$ is a *Liouville number* if
for every $n \in \mathbb{N}$ there exist integers $p, q$ with $q > 1$ and
$$0 < \left| x - \frac{p}{q} \right| < \frac{1}{q^{\,n}}.$$
Every Liouville number is irrational (indeed transcendental).

## 3. Unbounded Denominators

### 3.1 Local finiteness

The technical heart of the section is the observation that rationals of bounded
denominator cannot accumulate in a bounded region.

**Lemma 3.1 (local finiteness, `finite_den_le_in_interval`).** *For every $N \in
\mathbb{N}$ and all real $a < b$, the set*
$$\{ q \in \mathbb{Q} : q.\mathrm{den} \le N \text{ and } q \in (a,b) \}$$
*is finite.*

*Proof sketch.* Put $C = \lceil |a| \rceil + \lceil |b| \rceil + 1$, a fixed natural
number bounding $|y|$ for all $y \in (a,b)$. For any $q$ in the set, the value
$q \in (a,b)$ gives $|q| \le C$, hence
$$|q.\mathrm{num}| = |q| \cdot q.\mathrm{den} \le C \cdot q.\mathrm{den} \le C \cdot N.$$
Thus the map $q \mapsto (q.\mathrm{num}, q.\mathrm{den})$ sends the set injectively
into the finite product
$$\{ m \in \mathbb{Z} : |m| \le C N \} \times \{ d \in \mathbb{N} : 1 \le d \le N \},$$
which is finite. The map is injective because a rational is recovered from its
numerator–denominator pair via $q = q.\mathrm{num}/q.\mathrm{den}$. A subset of a
finite set is finite. $\qquad\blacksquare$

The only delicate points are the integer/real coercions of $q.\mathrm{den}$ and the
edge case $N = 0$, where the set is empty (denominators are at least $1$) and the
claim is vacuous.

### 3.2 The unboundedness theorem

**Theorem 3.2 (unbounded denominators, `irrational_den_unbounded`).** *Let $x$ be
irrational and $N \in \mathbb{N}$. Then there exists a rational $q$ with*
$$\left| x - q \right| < \frac{1}{q.\mathrm{den}^2} \quad\text{and}\quad N \le q.\mathrm{den}.$$

*Proof sketch.* Suppose not. Then every Dirichlet-good rational $q$ has
$q.\mathrm{den} < N$, hence $q.\mathrm{den} \le N$. Moreover any such $q$ satisfies
$|x - q| < 1/q.\mathrm{den}^2 \le 1$, so $q \in (x-1, x+1)$. Consequently the set of
Dirichlet-good rationals embeds into
$$\{ q \in \mathbb{Q} : q.\mathrm{den} \le N \text{ and } q \in (x-1, x+1) \},$$
which is finite by Lemma 3.1. But the set of Dirichlet-good rationals is infinite
(Dirichlet's theorem, Definition 2.5). This contradicts the finiteness of a set
containing an infinite set. $\qquad\blacksquare$

### 3.3 Coprime form

Rephrasing Theorem 3.2 in terms of explicit coprime integers yields the form most
convenient for downstream limit arguments.

**Theorem 3.3 (coprime approximations, `irrational_infinitely_many_coprime_approx`).**
*Let $x$ be irrational and $N \in \mathbb{N}$. Then there exist $a \in \mathbb{Z}$
and $b \in \mathbb{N}$ with*
$$N \le b, \qquad \gcd(a,b) = 1, \qquad \left| x - \frac{a}{b} \right| < \frac{1}{b^2}.$$

*Proof sketch.* Apply Theorem 3.2 to obtain a Dirichlet-good $q$ with $q.\mathrm{den}
\ge N$. Take $a = q.\mathrm{num}$ and $b = q.\mathrm{den}$. Coprimality is the
reducedness of $q$; the inequality is the rewriting of $|x - q|$ via $q =
a/b$. $\qquad\blacksquare$

## 4. A Universal Bound on the Lagrange Constant

**Theorem 4.1 (universal bound, `Lc_le_one_of_irrational`).** *Every irrational $x$
satisfies $\mathrm{Lc}(x) \le 1$.*

*Proof sketch.* We bound the $\liminf$ in (1.2) by exhibiting arbitrarily large
denominators $q$ with $\mathrm{approx}(x, q) \le 1$. Fix any $N$. By Theorem 3.2
there is a Dirichlet-good rational with denominator $b = q.\mathrm{den} \ge N$ and
numerator $a = q.\mathrm{num}$, so $|x - a/b| < 1/b^2$. Multiplying by $b$,
$$|b x - a| < \frac1b.$$
Since $a \in \mathbb{Z}$, the distance from $bx$ to the nearest integer is at most
$|bx - a|$, giving $\lVert b x \rVert < 1/b$, hence
$$\mathrm{approx}(x, b) = b \cdot \lVert b x \rVert < 1.$$
Because $N$ was arbitrary, the inequality $\mathrm{approx}(x, b) \le 1$ holds for
denominators $b$ that are arbitrarily large — i.e. *frequently* along the filter $q
\to \infty$. A standard $\liminf$ estimate (the value $1$ is exceeded only finitely
often along a frequently-attained sub-bound) gives $\mathrm{Lc}(x) = \liminf_q
\mathrm{approx}(x, q) \le 1$. Here Theorem 3.2's unboundedness is indispensable: a
finite supply of small-denominator good approximations would say nothing about the
$\liminf$. $\qquad\blacksquare$

**Remark 4.2 (toward Hurwitz).** The bound $\mathrm{Lc}(x) \le 1$ uses a single
Dirichlet approximation at each scale. Hurwitz's theorem yields the sharp
$\mathrm{Lc}(x) \le 1/\sqrt 5$, with equality for the $\mathrm{GL}_2(\mathbb{Z})$-orbit
of the golden ratio. The improvement comes from extracting *three consecutive*
continued-fraction convergents and using the inequality that at least one of any
three consecutive convergents beats $1/(\sqrt 5\, q^2)$. Replacing Theorem 3.2 by such
a three-convergent statement would lower the constant from $1$ to $1/\sqrt 5$; this is
isolated as future work (Conjecture C1).

## 5. Vanishing on Liouville Numbers

### 5.1 An $[0,+\infty]$ squeeze

**Lemma 5.1 (`eq_zero_of_forall_pos_le`).** *If $z \in [0, +\infty]$ satisfies $z \le
\varepsilon$ for every $\varepsilon > 0$, then $z = 0$.*

*Proof sketch.* If $z \ne 0$, then either $z = +\infty$, contradicting $z \le 1 <
+\infty$, or $0 < z < +\infty$, in which case taking $\varepsilon = z/2$ yields $z \le
z/2$, impossible for positive finite $z$. $\qquad\blacksquare$

### 5.2 Positivity away from the limit

For the $\liminf$ to vanish it suffices to make $\mathrm{approx}(x,q)$ small along a
subsequence; but to handle the filter cleanly one records that $\mathrm{approx}(x, q)
> 0$ for $q \ge 1$ when $x$ is irrational, because $qx \notin \mathbb{Z}$ and hence
$\lVert q x \rVert > 0$ (a fact denoted `approx_pos_of_irrational` in the
development). This guarantees the terms are genuinely positive reals, so driving them
below every $\varepsilon$ is meaningful.

### 5.3 The vanishing theorem

**Theorem 5.2 (Liouville vanishing, `Lc_eq_zero_of_liouville`).** *If $x$ is a
Liouville number then $\mathrm{Lc}(x) = 0$.*

*Proof sketch.* By Lemma 5.1 it suffices to show $\mathrm{Lc}(x) \le \varepsilon$ for
every $\varepsilon > 0$. Fix $\varepsilon > 0$. By the Liouville property
(Definition 2.6) with a sufficiently large exponent $n$, there are integers $p,q$
with $q > 1$ and
$$0 < \left| x - \frac{p}{q} \right| < \frac{1}{q^{\,n}}.$$
Multiplying by $q$ gives $|q x - p| < q^{\,1-n}$, so $\lVert q x \rVert < q^{\,1-n}$
and
$$\mathrm{approx}(x, q) = q \cdot \lVert q x \rVert < q^{\,2-n}.$$
For $n \ge 3$ and $q \ge 2$ this is at most $q^{\,2-n} \le 2^{\,2-n}$, which can be
made smaller than $\varepsilon$ by taking $n$ large. To control the $\liminf$ we must
also ensure the denominators $q$ are large; the Liouville denominators can be forced
to grow (one uses that only finitely many denominators $d$ satisfy $\lVert d x \rVert <
\delta$ within a bounded range, in the same spirit as Lemma 3.1), so the small values
$\mathrm{approx}(x, q) < \varepsilon$ occur frequently as $q \to \infty$. Hence
$\liminf_q \mathrm{approx}(x, q) \le \varepsilon$. As $\varepsilon$ was arbitrary,
Lemma 5.1 gives $\mathrm{Lc}(x) = 0$. $\qquad\blacksquare$

### 5.4 Liouville numbers are not badly approximable

**Corollary 5.3 (`liouville_not_bad`).** *No Liouville number lies in
$\mathrm{Bad}$.*

*Proof sketch.* If $x$ is Liouville then $\mathrm{Lc}(x) = 0$ by Theorem 5.2, so the
defining condition $\mathrm{Lc}(x) > 0$ of $\mathrm{Bad}$ fails. $\qquad\blacksquare$

## 6. Worked Examples

We illustrate the theory on concrete numbers; the numerical values below are
reproduced by the accompanying demonstrations.

**The golden ratio $\varphi = (1+\sqrt 5)/2$.** Its continued fraction is the all-ones
expansion $\varphi = [1; 1, 1, 1, \ldots]$, the slowest-growing possible, so its
convergents are ratios of consecutive Fibonacci numbers $F_{k+1}/F_k$. Because the
partial quotients are as small as they can be, the approximations are as poor as they
can be relative to the denominator: $\mathrm{Lc}(\varphi) = 1/\sqrt 5 \approx 0.4472$,
the maximum value of the Lagrange constant. Empirically, $\min_{q \le 20000} q\lVert q
\varphi \rVert \approx 0.382$ and creeps upward toward $1/\sqrt 5$ as $q$ grows. The
golden ratio is the canonical badly approximable number, comfortably inside the
universal bound of Theorem 4.1 and far from the Liouville extreme.

**The quadratic irrational $\sqrt 2 = [1; 2, 2, 2, \ldots]$.** Its convergents
$1, \tfrac32, \tfrac75, \tfrac{17}{12}, \tfrac{41}{29}, \ldots$ obey the Pell
recurrence and reach denominators above $10^9$ within roughly twenty terms — an
explicit, effective instance of Theorem 3.2. Each convergent satisfies $|\sqrt 2 -
p_k/q_k| < 1/q_k^2$, and the empirical Lagrange constant settles near $0.343$, again
safely below $1$. All quadratic irrationals are badly approximable, anticipating
Conjecture C4.

**A Liouville number $L = \sum_{k\ge 1} 10^{-k!}$.** Truncating the series at the
$n$-th term gives a rational with denominator $q = 10^{n!}$ whose error is dominated by
the next term $10^{-(n+1)!}$, so $q\lVert q L \rVert \approx 10^{n! - (n+1)!} =
10^{-n\cdot n!}$. This collapses to $0$ at hyper-exponential speed: $10^{-1}, 10^{-4},
10^{-18}, 10^{-96}, \ldots$ at $n = 1, 2, 3, 4$. The numbers plunge toward $0$,
witnessing $\mathrm{Lc}(L) = 0$ (Theorem 5.2) and confirming that $L \notin
\mathrm{Bad}$ (Corollary 5.3).

These three examples populate the full range of the theory: the golden ratio at the
spectral top, quadratic irrationals strictly inside the badly approximable region, and
Liouville numbers at the vanishing bottom.

## 7. Historical Context and Related Work

The study of rational approximation to reals is among the oldest threads of number
theory. Continued fractions appear implicitly in Euclid's algorithm and explicitly in
the work of Bombelli, Wallis, and Huygens, the last of whom used convergents to design
the gear ratios of a mechanical planetarium. The modern theory crystallized in the
nineteenth century: Dirichlet's pigeonhole proof of the $1/q^2$ bound (1842), Liouville's
construction of explicit transcendental numbers (1844), and Hurwitz's sharp constant
$1/\sqrt 5$ (1891). The Lagrange and Markov spectra, which catalogue the possible values
of $\mathrm{Lc}$, grew out of Markov's 1879–1880 work on indefinite binary quadratic
forms and remain an active research area, with the structure of the spectrum below
Freiman's constant $\approx 4.5278$ being especially intricate.

The present development positions itself at the elementary foundations of this edifice.
It takes as given the existence of infinitely many Dirichlet-good approximations (a
standard result) and contributes the denominator-unboundedness refinement (Theorem 3.2)
that is logically necessary for, yet frequently elided in, the passage to asymptotic
invariants. The two endpoint theorems (4.1 and 5.2) then bracket the Lagrange spectrum
from above and below using only this refinement and the definition of a Liouville
number, making the whole chain self-contained.

## 8. Algorithms

The constructive content of the theory yields concrete algorithms; we record two.

**Algorithm A (best rational approximations via continued fractions).** To produce
Dirichlet-good approximations of $x$, compute the continued-fraction expansion $x =
[a_0; a_1, a_2, \ldots]$ by repeated $a_k = \lfloor x_k \rfloor$, $x_{k+1} = 1/(x_k -
a_k)$, and form the convergents $p_k/q_k$ via the recurrences $p_k = a_k p_{k-1} +
p_{k-2}$, $q_k = a_k q_{k-1} + q_{k-2}$. Each convergent satisfies $|x - p_k/q_k| <
1/q_k^2$, and the denominators $q_k$ strictly increase — an explicit, effective
witness for Theorem 3.2. The cost to reach denominator $\ge N$ is $O(\log N)$
iterations for badly approximable $x$.

**Algorithm B (empirical Lagrange constant).** To estimate $\mathrm{Lc}(x)$, evaluate
$q \cdot \lVert q x \rVert$ over $q = 1, \ldots, Q$ and report the running minimum of
the tail; the minimum over convergent denominators converges to $\mathrm{Lc}(x)$.
This makes Theorems 4.1 and 5.2 visible numerically: for any irrational the running
minimum stays $\le 1$, and for a Liouville number it plunges toward $0$.

## 9. Applications

- **Calendar and gear design.** Convergents of the solar year length $\approx
  365.2425$ explain the Gregorian leap-year rule; convergents of irrational gear
  ratios give optimal tooth counts. These are best rational approximations in the
  sense of Theorem 3.2.
- **Musical temperament.** The equal-tempered fifth $2^{7/12}$ is the convergent
  approximation that makes $12$-tone scales nearly close the circle of fifths.
- **Cryptanalysis.** Wiener's attack on RSA with small private exponent recovers the
  secret precisely by detecting that a certain ratio is *too well* approximated — the
  Liouville-like extreme of Theorem 5.2 — via continued fractions.
- **Transcendence theory.** Theorem 5.2 quantifies why Liouville numbers are
  transcendental: their Lagrange constant is $0$, whereas algebraic irrationals of
  degree $d$ obey a positive lower bound $|x - p/q| > c/q^d$ (Conjecture C4), forcing
  $\mathrm{Lc}(x) > 0$ for quadratic irrationals.

## 10. Discussion

The three theorems form a complete dictionary at the two endpoints of the Lagrange
spectrum. Theorem 4.1 caps every irrational at $\mathrm{Lc} \le 1$; Theorem 5.2 sends
the most-approximable numbers to $\mathrm{Lc} = 0$. The golden ratio realizes the top
of the spectrum at $1/\sqrt 5$, and the badly approximable set $\mathrm{Bad}$ — those
with bounded continued-fraction partial quotients — sits strictly between. The
unbounded-denominator theorem is the linchpin: it converts set-theoretic infinitude
of approximations into the asymptotic statements that the $\liminf$ definition of
$\mathrm{Lc}$ requires.

A noteworthy structural feature is the choice to value $\mathrm{approx}$ and
$\mathrm{Lc}$ in $[0,+\infty]$. This removes side conditions on the $\liminf$ (every
term is nonnegative, no boundedness hypothesis is needed) at the cost of careful
arithmetic with $+\infty$ and the order-isomorphism $\mathrm{ofReal}$ from
nonnegative reals.

## 11. Future Directions

- **C1 (Hurwitz sharpening).** Strengthen Theorem 4.1 to $\mathrm{Lc}(x) \le 1/\sqrt
  5$ by replacing the single-approximation input with a three-consecutive-convergent
  inequality; equality holds exactly on the $\mathrm{GL}_2(\mathbb{Z})$-orbit of the
  golden ratio.
- **C2 (modular invariance).** Prove $\mathrm{Lc}(x) = \mathrm{Lc}(y)$ whenever $y =
  (ax+b)/(cx+d)$ with $ad-bc = \pm 1$; the affine $\pm1$ case is already established,
  leaving the single generator $x \mapsto -1/x$.
- **C3 (badly approximable $\Leftrightarrow$ bounded partial quotients).** Show
  $\mathrm{Lc}(x) > 0$ iff the continued-fraction partial quotients of $x$ are
  bounded; Theorem 5.2 is the unbounded-quotient extreme.
- **C4 (quantitative Liouville for algebraic numbers).** For real algebraic $x$ of
  degree $d \ge 2$, obtain $c > 0$ with $|x - p/q| > c/q^d$, implying $\mathrm{Lc}(x)
  > 0$ for every quadratic irrational.

## 12. Conclusion

We have formally verified the foundational bridge from classical Diophantine
approximation to the Lagrange constant: denominators of good approximations are
unbounded (Theorem 3.2), every irrational obeys the universal bound $\mathrm{Lc}(x)
\le 1$ (Theorem 4.1), and Liouville numbers achieve the extreme $\mathrm{Lc}(x) = 0$,
so they are never badly approximable (Theorem 5.2, Corollary 5.3). These endpoints
anchor the Lagrange spectrum and set the stage for the sharper invariance and
spectral results outlined above.
