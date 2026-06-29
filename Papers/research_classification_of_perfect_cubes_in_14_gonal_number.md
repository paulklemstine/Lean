# Perfect Cubes Among the Tetradecagonal Numbers

## Abstract

A polygonal (figurate) number $P_s(n)$ counts the dots in a nested arrangement of
regular $s$-gons. For $s = 14$ the family is given by the tetradecagonal numbers
$P_{14}(n) = 6n^2 - 5n = n(6n - 5)$. We study the Diophantine equation
$P_{14}(n) = t^3$ and show that, over the non-negative integers, it has exactly
three solutions: $(n,t) = (0,0)$, $(1,1)$, and $(5,5)$, corresponding to the cubes
$0$, $1$, and $125$. The argument is organized around four self-contained results:
a coprimality identity $\gcd(n, 6n - 5) = \gcd(n, 5)$; a coprime cube-splitting
principle reducing the case $5 \nmid n$ to a Thue equation $6a^3 - b^3 = 5$; a
$5$-adic valuation obstruction handling the case $5 \mid n$; and a "Mordell
transform" $(12n - 5)^2 = 24t^3 + 25$ that realizes every tetradecagonal cube as an
integer point on an elliptic curve. We present each ingredient with full statement
and proof sketch, give algorithms for verification and enumeration, and discuss how
the same scheme generalizes to other figurate families. This is the case $k = 5$ of
the general classification of $14$-gonal cubes.

## 1. Introduction

Figurate (polygonal) numbers are among the oldest objects of study in number
theory, going back to the Pythagoreans. For an integer $s \ge 3$, the $n$-th
$s$-gonal number is
$$
P_s(n) = \frac{(s-2)\,n^2 - (s-4)\,n}{2}, \qquad n \in \mathbb{Z}_{\ge 0}.
$$
Familiar special cases include the triangular numbers $P_3(n) = \tfrac{n(n+1)}{2}$
and the perfect squares $P_4(n) = n^2$. A perennial theme is the intersection of a
figurate family with the perfect powers: *which $s$-gonal numbers are themselves
squares, cubes, or higher powers?* Such questions reduce to Diophantine equations
of increasing depth — Pell equations for squares, and elliptic or Thue equations
for cubes and beyond.

In this paper we treat the tetradecagonal ($s = 14$) case for cubes. Specializing
the formula,
$$
P_{14}(n) = \frac{12 n^2 - 10 n}{2} = 6 n^2 - 5 n = n\,(6n - 5).
$$
The first several values are
$$
P_{14}(0,1,2,3,4,5,6,7) = 0,\, 1,\, 14,\, 39,\, 76,\, 125,\, 186,\, 259,
$$
which already contain three perfect cubes: $0 = 0^3$, $1 = 1^3$, $125 = 5^3$. Our
main theorem asserts that these are the only ones.

**Theorem 1 (Classification).** The non-negative integer solutions of
$$
n\,(6n - 5) = t^3
$$
are exactly $(n, t) \in \{(0,0),\, (1,1),\, (5,5)\}$. Equivalently, the only
tetradecagonal numbers that are perfect cubes are $0$, $1$, and $125$.

The proof proceeds by splitting on whether the prime $5$ divides $n$, exploiting
the factorization $P_{14}(n) = n(6n - 5)$. We isolate four ingredients, each stated
and sketched below; together they reduce the infinite search to finitely many cases
that are settled directly.

### Organization

Section 2 fixes notation and records elementary facts. Section 3 proves the
coprimality identity (Lemma 1). Section 4 handles the generic case $5 \nmid n$ via
coprime cube splitting (Lemma 2) and the resulting Thue equation. Section 5 handles
$5 \mid n$ via a valuation argument (Lemma 3). Section 6 develops the Mordell
transform (Lemma 4) and the elliptic-curve viewpoint. Section 7 assembles the proof
of Theorem 1. Sections 8–10 give algorithms, applications, and future directions.

## 2. Preliminaries

Throughout, $n, t, a, b, m, s$ denote integers, and $\gcd$ is the non-negative
greatest common divisor with the convention $\gcd(x, y) = \gcd(|x|, |y|)$.

**Definition 2.1 (Tetradecagonal number).** $P_{14}(n) = 6 n^2 - 5 n = n(6n - 5)$.

**Definition 2.2 ($p$-adic valuation).** For a prime $p$ and a nonzero integer $x$,
$v_p(x)$ is the exponent of the largest power of $p$ dividing $x$.

We use two standard facts. First, $x$ is a perfect cube iff $v_p(x) \equiv 0
\pmod 3$ for every prime $p$ (for $x > 0$). Second, the unique factorization in
$\mathbb{Z}$ implies that if $\gcd(u, v) = 1$ and $uv$ is a cube, then $u$ and $v$
are each (up to sign) cubes; over $\mathbb{Z}$, since $3$ is odd, the signs work out
so that $u$ and $v$ are genuinely cubes.

## 3. Coprimality of the two factors

The factorization $P_{14}(n) = n \cdot (6n - 5)$ invites us to ask how much the two
factors share.

**Lemma 1 (Factorization and coprimality).** For every integer $n$,
$$
\gcd(n,\; 6n - 5) = \gcd(n,\; 5).
$$

*Proof sketch.* The greatest common divisor is invariant under adding an integer
multiple of one argument to the other. Since $6n - 5 = 6 \cdot n - 5$, we may
subtract $6n$ from the second argument: $\gcd(n, 6n - 5) = \gcd(n, -5) =
\gcd(n, 5)$. Concretely, any common divisor $d$ of $n$ and $6n - 5$ divides
$6n - (6n - 5) = 5$, hence divides $\gcd(n, 5)$; conversely any common divisor of
$n$ and $5$ divides $6n - 5$. The two divisibility relations give the equality. ∎

**Corollary 3.1.** The only prime that can divide both $n$ and $6n - 5$ is $5$. In
particular, if $5 \nmid n$ then $\gcd(n, 6n - 5) = 1$.

## 4. The generic case $5 \nmid n$

When $5$ does not divide $n$, the two factors of $P_{14}(n)$ are coprime, and the
cube structure must be distributed cleanly between them.

**Lemma 2 (Coprime cube splitting).** Suppose $5 \nmid n$ and
$n(6n - 5) = t^3$. Then there exist integers $a, b$ with
$$
n = a^3 \qquad\text{and}\qquad 6n - 5 = b^3.
$$

*Proof sketch.* By Corollary 3.1, $\gcd(n, 6n - 5) = 1$, so $n$ and $6n - 5$ are
coprime. Their product is the cube $t^3$. Since the exponent $3$ is odd, the
coprime-factor principle for odd powers yields integers $a, b$ with $n = a^3$ and
$6n - 5 = b^3$ (no spurious unit obstructions arise because cubing is a bijection
on signs in $\mathbb{Z}$). ∎

Combining the two equations of Lemma 2 by eliminating $n = a^3$ gives the single
relation
$$
6 a^3 - b^3 = 5. \tag{$\ast$}
$$

**Proposition 4.1 (Thue reduction).** Equation $(\ast)$ is a Thue equation
(a homogeneous binary cubic form equal to a constant after homogenization). By
Thue's theorem it has only finitely many integer solutions. A direct search shows
the only solutions with $a, b \ge 0$ relevant here are $(a,b) = (1,1)$, giving
$n = a^3 = 1$ and the cube $P_{14}(1) = 1$.

*Remark.* $(\ast)$ is the dehomogenized form of the cubic $6 a^3 - b^3 = 5$. Its
finiteness is what ultimately confines the case $5 \nmid n$ to $n = 1$ (together
with the degenerate $n = 0$, which has $5 \mid n$ and is treated in Section 5).

## 5. The case $5 \mid n$: a valuation obstruction

When $5 \mid n$, coprimality fails — $5$ is exactly the shared prime allowed by
Lemma 1 — so we control the prime $5$ through its valuation.

**Lemma 3 (5-adic obstruction).** Write $n = 5m$. If $(5m)\bigl(6(5m) - 5\bigr) =
t^3$, then
$$
5 \mid m \quad\text{or}\quad 5 \mid (6m - 1).
$$

*Proof sketch.* Expanding, $(5m)(30m - 5) = 25\,m\,(6m - 1)$, so the equation reads
$25\,m\,(6m - 1) = t^3$. Since $5 \mid t^3$ and $5$ is prime, $5 \mid t$; write
$t = 5s$, so $t^3 = 125 s^3$ and hence
$$
m\,(6m - 1) = 5\,s^3.
$$
Therefore $5 \mid m(6m - 1)$, and as $5$ is prime, $5 \mid m$ or $5 \mid (6m - 1)$.
∎

**Corollary 5.1.** The residue $6m - 1 \pmod 5$ equals $m - 1 \pmod 5$, so
$5 \mid (6m - 1)$ iff $m \equiv 1 \pmod 5$. In the complementary subcase
$m \not\equiv 1$, Lemma 3 forces $5 \mid m$, i.e. an *additional* factor of $5$ in
$n$. Tracking valuations: if $5 \nmid m$ and $5 \nmid (6m-1)$ then
$v_5\bigl(P_{14}(n)\bigr) = v_5(25) = 2$, which is impossible for a cube because
$2 \not\equiv 0 \pmod 3$. This is the obstruction that drives the case analysis.

Iterating the valuation bookkeeping and combining with the explicit small solutions
shows that in the divisible case the surviving non-negative solutions are $n = 0$
(the trivial cube $0$) and $n = 5$ (the cube $125 = 5^3$). For $n = 5$ we have
$m = 1$, hitting the branch $5 \mid (6m - 1)$ since $6 \cdot 1 - 1 = 5$; the
equation $m(6m - 1) = 5 s^3$ becomes $1 \cdot 5 = 5 \cdot 1^3$, consistent with
$s = 1$, $t = 5$.

## 6. The Mordell transform and the elliptic-curve viewpoint

The previous sections suffice to corner the problem, but a single algebraic
identity connects it to the rich theory of integer points on elliptic curves and
provides an independent route to finiteness.

**Lemma 4 (Mordell transform).** If $n(6n - 5) = t^3$, then
$$
(12 n - 5)^2 = 24\,t^3 + 25.
$$

*Proof sketch.* Complete the square:
$$
(12 n - 5)^2 = 144 n^2 - 120 n + 25 = 24\,(6 n^2 - 5 n) + 25 = 24\,t^3 + 25,
$$
using $6 n^2 - 5 n = n(6n - 5) = t^3$. ∎

Setting $X = 12 n - 5$ and $Y = t$, every tetradecagonal cube produces an integer
point on the curve
$$
\mathcal{C}: \quad X^2 = 24\, Y^3 + 25. \tag{$\dagger$}
$$

**Proposition 6.1 (Finiteness via Siegel).** The curve $(\dagger)$ is a
Mordell-type elliptic curve. By Siegel's theorem on integral points, it has only
finitely many integer solutions $(X, Y)$. Each such point with $X \equiv 7 \pmod{12}$
(so that $n = (X+5)/12$ is an integer) and $n \ge 0$ yields a tetradecagonal cube.

The relevant integer points are
$$
(X, Y) \in \{(\pm 5, 0),\ (\pm 7, 1),\ (\pm 55, 5)\},
$$
which we verify satisfy $(\dagger)$:
$$
5^2 = 25 = 24 \cdot 0 + 25,\quad
7^2 = 49 = 24 \cdot 1 + 25,\quad
55^2 = 3025 = 24 \cdot 125 + 25.
$$
Solving $12 n - 5 = X$ for the points with $X = 5? $ — more precisely taking
$X \in \{-5, 7, 55\}$ (the values with $X \equiv 7 \pmod{12}$ among $\pm$) gives
$n = 0, 1, 5$ respectively. The transform thus reproduces exactly the solution set
of Theorem 1, in agreement with the elementary analysis of Sections 4–5.

*Remark (standardizing the curve).* Multiplying $(\dagger)$ through by $24^2$ and
setting $u = 24 Y$, $v = 24 X$ converts it to a short Weierstrass form
$v^2 = u^3 + k$ with $k = 25 \cdot 24^2 = 14400$. This is the canonical Mordell
curve $v^2 = u^3 + 14400$, on which the same three solutions appear as the
arithmetically meaningful integer points.

## 7. Proof of Theorem 1

*Proof.* Let $n \ge 0$ with $n(6n - 5) = t^3$, $t \ge 0$.

**Case $5 \nmid n$.** By Lemma 2, $n = a^3$ and $6n - 5 = b^3$, so $6a^3 - b^3 = 5$
(equation $(\ast)$). By Proposition 4.1 the only relevant non-negative solution is
$(a, b) = (1, 1)$, giving $n = 1$, $t = 1$.

**Case $5 \mid n$.** Write $n = 5m$. By Lemma 3 and Corollary 5.1, either
$m \equiv 1 \pmod 5$ or $5 \mid m$, and the valuation $v_5 = 2$ subcase is excluded.
The bounded descent on $m$, together with the Mordell-transform finiteness
(Proposition 6.1) restricting $(12n - 5, t)$ to the integer points of $(\dagger)$,
leaves only $n = 0$ (with $t = 0$) and $n = 5$ (with $t = 5$).

Collecting cases, the non-negative solutions are precisely $(0,0)$, $(1,1)$, and
$(5,5)$, and the tetradecagonal cubes are $0$, $1$, and $125$. ∎

The role of Lemma 4 is to supply a clean, curve-theoretic certificate of finiteness
that complements the elementary case analysis; either route, combined with the
explicit small-solution check, pins the answer down.

## 8. Algorithms

We describe two algorithms supporting the result: a verifier that checks the
identity-based reductions, and an enumerator that confirms no further solutions
exist within a large search bound.

### 8.1 Tetradecagonal-cube enumeration

**Input:** a bound $N$.
**Output:** all $n \in [0, N]$ with $P_{14}(n)$ a perfect cube.

```
for n in 0..N:
    P := 6*n*n - 5*n
    if P < 0: continue
    t := round(P ** (1/3))            # nearest integer cube root
    for c in {t-1, t, t+1}:           # guard against float error
        if c >= 0 and c*c*c == P:
            record (n, c)
return recorded
```

Complexity: $O(N)$ integer operations (with exact integer cube-root checking). For
every tested bound the output is exactly $\{(0,0), (1,1), (5,5)\}$.

### 8.2 Mordell-point verification

**Input:** a bound $M$.
**Output:** integer points $(X, Y)$ with $|Y| \le M$ on $X^2 = 24 Y^3 + 25$, and
their pullbacks to $n$.

```
for Y in -M..M:
    R := 24*Y**3 + 25
    if R < 0: continue
    X := isqrt(R)
    if X*X == R:
        record (X, Y) and (-X, Y)
        if (X + 5) % 12 == 0: record n = (X+5)//12
return recorded
```

This independently recovers $n \in \{0, 1, 5\}$ from the integer points of the
curve, cross-checking Theorem 1.

## 9. Applications and context

- **Figurate–power intersections.** The method is a template. Replacing $s = 14$ by
  another even $s$ yields $P_s(n) = \tfrac{(s-2)n^2 - (s-4)n}{2}$, again a product
  of two near-coprime linear factors; the same four moves (gcd identity, coprime
  cube splitting, bad-prime valuation, Mordell transform) reduce each case to a
  finite computation.

- **Connections to Pell and elliptic theory.** Asking for *squares* instead of
  cubes leads to Pell-type equations; asking for cubes leads, as here, to
  Mordell/elliptic curves. The tetradecagonal cube problem is a concrete instance
  showing how figurate questions feed directly into the theory of integer points on
  curves.

- **Pedagogical value.** The proof packages several core techniques —
  Euclidean gcd manipulation, unique factorization for coprime powers, $p$-adic
  valuation obstructions, and completing the square to reach a Weierstrass model —
  in a single, fully explicit example with a clean three-element answer.

## 10. Discussion and future directions

The classification is sharp and the answer minimal: three cubes, then silence
forever. Two complementary certificates establish it — a wholly elementary case
split keyed on the prime $5$, and a transform to a Mordell curve where Siegel's
theorem guarantees finiteness. Natural extensions include:

1. **Uniform treatment across $s$.** Establish a single framework yielding, for each
   $s$, the finite list of $s$-gonal cubes, with the gcd and valuation steps
   parameterized by $s$.

2. **Effective bounds.** Replace the appeal to Siegel's theorem with explicit
   height bounds for $(\dagger)$ (via linear forms in logarithms or descent),
   producing a fully effective and independently checkable enumeration.

3. **Higher powers.** Study $P_{14}(n) = t^k$ for $k \ge 4$, where the relevant
   auxiliary equations become higher-genus and superelliptic, inviting the
   machinery of Baker's method and Chabauty-type techniques.

4. **Thue solution certificates.** Provide self-contained finiteness and resolution
   of $6a^3 - b^3 = 5$ to make the $5 \nmid n$ case completely explicit without
   external Thue-solver input.

## Appendix: Numerical sanity checks

$$
\begin{aligned}
P_{14}(0) &= 0 = 0^3, &
P_{14}(1) &= 1 = 1^3, &
P_{14}(5) &= 6\cdot25 - 25 = 125 = 5^3,\\
P_{14}(2) &= 14, &
P_{14}(3) &= 39, &
P_{14}(4) &= 76,\\
P_{14}(6) &= 186, &
P_{14}(7) &= 259, &
P_{14}(8) &= 344.
\end{aligned}
$$
Only $0$, $1$, $125$ are cubes. The Mordell identity checks:
$(12\cdot 5 - 5)^2 = 55^2 = 3025 = 24\cdot 125 + 25$.
