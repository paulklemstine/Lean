# Alien Number Systems: Negative, Complex, and Irrational Bases

## Abstract

Positional numeral systems are almost always presented over a positive integer
base $b > 1$, an accident of convention that obscures how much of arithmetic
survives when the base is chosen more adventurously. We study two non-standard
positional systems and establish their central structural theorems. First, the
**negative base** $-2$ ("negabinary") represents *every* integer — positive,
negative, and zero — with the digits $\{0,1\}$, and does so *uniquely*, with no
sign symbol; we prove this bijection between canonical bit strings and
$\mathbb{Z}$ from first principles. The proof isolates the sole base-specific
ingredient as a termination measure: absolute value fails to decrease under the
base-$(-2)$ successor step, and a zig-zag interleaving of the two half-lines of
$\mathbb{Z}$ is required. Second, the **golden-ratio base** $\varphi =
(1+\sqrt5)/2$ ("phinary") represents integers with digits $\{0,1\}$ and no two
consecutive $1$s; we show this feature is the positional shadow of the single
identity $\varphi^2 = \varphi+1$, expressed as the carry rule
$\varphi^n + \varphi^{n+1} = \varphi^{n+2}$. We connect phinary to the Fibonacci
sequence (natural-exponent values lie in $\mathbb{Z}+\mathbb{Z}\varphi$ with
Fibonacci-sum coordinates), to the Lucas numbers (symmetric golden/conjugate
power sums are integers), and to the irrationality of $\varphi$ (which alone
guarantees uniqueness of phinary coordinates over $\mathbb{Q}$). We close with
conjectures generalizing these results to all bases $b \le -2$, to the complex
base $i-1$ over the Gaussian integers, and to a uniqueness characterization of
$\varphi$ among real bases.

**Keywords:** negabinary, base $-2$, golden ratio base, phinary, Fibonacci
numbers, Lucas numbers, Zeckendorf representation, positional numeral systems,
irrationality.

---

## 1. Introduction

The decimal system is a fact of human anatomy, not of mathematics. Once we
detach "base" from the number ten and even from the positive integers, a
menagerie of consistent arithmetics appears, each highlighting a structural
feature invisible in ordinary notation. This paper develops two of them
rigorously.

A **negative base** trades the sign symbol for alternating-sign place values.
Base $-2$ uses only the digits $\{0,1\}$ yet represents all of $\mathbb{Z}$,
because the powers $(-2)^i$ furnish negative contributions automatically. The
main theorem (Section 3) is that this representation is not merely possible but
*canonically unique*: the value map from bit strings with no redundant trailing
zero to $\mathbb{Z}$ is a bijection.

An **irrational base** seems paradoxical but yields the most elegant system of
all. Base $\varphi$, with $\varphi = (1+\sqrt5)/2$, represents integers with
digits $\{0,1\}$ subject to a forbidden pattern: no two consecutive $1$s. We
show (Section 4) that this restriction is *not* an ad hoc rule but a direct
consequence of $\varphi^2=\varphi+1$, and we expose the Fibonacci/Lucas
structure lurking in phinary coordinates as well as the role played by the
irrationality of $\varphi$.

Throughout, our emphasis is on the *mechanism* behind each phenomenon: what
minimal algebraic or order-theoretic fact makes the system work, and where the
familiar positive-base intuition breaks down.

---

## 2. Preliminaries and Notation

We write $\mathbb{N} = \{0,1,2,\ldots\}$ and $\mathbb{Z}$ for the integers. The
Fibonacci sequence is $F_0 = 0$, $F_1 = 1$, $F_{n+2} = F_{n+1}+F_n$. The golden
ratio and its conjugate are the two roots of $x^2 = x+1$:
$$\varphi = \frac{1+\sqrt5}{2}, \qquad \psi = \frac{1-\sqrt5}{2},$$
so that $\varphi + \psi = 1$, $\varphi\psi = -1$, and both satisfy
$x^2 = x+1$. We freely use Binet's identity in the form
$$\varphi^{\,n} = F_n\,\varphi + F_{n-1}, \qquad \varphi\,F_{n+1} + F_n = \varphi^{\,n+1},$$
and its conjugate analogue with $\psi$ in place of $\varphi$.

### 2.1 Positional value

Given a base $\beta$ and a finite digit sequence $(d_0, d_1, \ldots, d_k)$ listed
least-significant first, its **value** is
$$\mathrm{val}_\beta(d_0,\ldots,d_k) = \sum_{i=0}^{k} d_i\,\beta^{\,i}.$$
It is convenient to evaluate this by Horner's rule, which for a bit list gives the
recursion
$$\mathrm{nval}(\,) = 0, \qquad \mathrm{nval}(d :: t) = d + \beta\cdot \mathrm{nval}(t).$$
For negabinary $\beta = -2$ and digits $d \in \{0,1\}$ (encoding a bit as $0$ or
$1$). For phinary $\beta = \varphi$ and we also permit negative exponents,
writing $\sum_i d_i \varphi^{\,i}$ for $i$ ranging over a finite set of integers.

---

## 3. Negabinary: the base $-2$

### 3.1 Definitions

A **negabinary string** is a finite list of bits $\ell = (b_0, b_1, \ldots,
b_k)$, least-significant first, with each $b_i \in \{0,1\}$. Its value is
$$\mathrm{nval}(\ell) = \sum_{i=0}^{k} b_i\,(-2)^{\,i},$$
equivalently $\mathrm{nval}(b :: t) = b + (-2)\cdot\mathrm{nval}(t)$ with
$\mathrm{nval}(\,) = 0$.

A string is **canonical** if it is empty or its top (most significant) bit is
$1$ — i.e. it carries no redundant trailing zero. Canonicity removes the only
source of trivial non-uniqueness (appending zeros to the high end), so that
distinct canonical strings should name distinct integers.

### 3.2 Worked values

$$
\begin{array}{c|c}
\text{string (lsb first)} & \text{value} \\ \hline
() & 0 \\
(1) & 1 \\
(0,1) & -2 \\
(1,1) & -1 \\
(0,0,1) & 4 \\
(1,0,1) & 5 \\
(0,1,1) & 2 \\
(1,1,1) & 3 \\
\end{array}
$$

Note how $-1$ and $-2$ appear without any sign symbol.

### 3.3 The main theorem

> **Theorem 1 (Negabinary Representation).** The map $\mathrm{nval}$ from
> canonical bit strings to $\mathbb{Z}$ is a bijection. Equivalently, every
> integer has exactly one representation in base $-2$ with digits $\{0,1\}$ and
> no redundant leading zero.

The theorem splits into **uniqueness** (injectivity) and **existence**
(surjectivity).

#### 3.3.1 Uniqueness via parity

**Lemma 1 (Parity pins the last digit).** For any bit list,
$$\mathrm{nval}(b :: t) \equiv b \pmod 2.$$

*Proof.* $\mathrm{nval}(b :: t) = b + (-2)\,\mathrm{nval}(t)$, and $(-2)\,
\mathrm{nval}(t)$ is even. $\qquad\blacksquare$

**Uniqueness.** Suppose two canonical strings share a value $n$. By Lemma 1
their least-significant bits are both $\equiv n \pmod 2$, hence equal; call the
common bit $b$. Subtracting $b$ and dividing by $-2$ (an invertible operation on
$\mathbb{Z}$ here because $n - b$ is even) shows the two tails have equal value.
Since a canonical string's tail is again canonical, structural induction on
length forces the tails equal, hence the strings equal. The empty string is the
unique representation of $0$. $\qquad\blacksquare$

The key point: at every position the digit is *forced* by the residue of the
current value modulo $2$; there is no branching, so representations cannot
diverge.

#### 3.3.2 Existence via an interleaving measure

The natural greedy algorithm computes digits by
$$b_0 = n \bmod 2, \qquad n' = \frac{n - b_0}{-2},$$
then recurses on $n'$. Existence is the claim that this recursion terminates
for every $n$.

**The obstruction.** Ranking integers by $|n|$ does *not* work: for $n = -1$ we
get $b_0 = 1$, $n' = (-1-1)/(-2) = 1$, and then for $n = 1$ we get $b_0 = 1$,
$n' = (1-1)/(-2) = 0$. So $-1 \mapsto 1 \mapsto 0$ does terminate — but the
absolute value *increased* on the first step ($|-1| = 1 = |1|$, no decrease),
and in general $|\,\cdot\,|$ is not a valid termination measure. A measure that
provably decreases is required.

**The measure.** Define the interleaving $\mu : \mathbb{Z} \to \mathbb{N}$ by
$$\mu(n) = \begin{cases} 2n & n \ge 0, \\ -2n - 1 & n < 0, \end{cases}$$
the standard bijection realizing the enumeration $0, -1, 1, -2, 2, \ldots$
Concretely $\mu(0)=0$, $\mu(-1)=1$, $\mu(1)=2$, $\mu(-2)=3$, $\mu(2)=4$, …

**Lemma 2 (Progress).** For $n \ne 0$, the successor $n' = (n - (n\bmod 2))/(-2)$
satisfies $\mu(n') < \mu(n)$.

*Proof sketch.* One checks the four sign/parity cases. Roughly, $|n'| \approx
|n|/2$, and while a single step can flip sign, the interleaving $\mu$ grows like
$2|n|$, so halving the magnitude strictly decreases $\mu$ except at the fixed
point $n=0$. Explicitly, for $n>0$: if $n$ even, $n' = -n/2$ and $\mu(n') =
n - 1 < 2n = \mu(n)$; if $n$ odd, $n' = (1-n)/2 \le 0$ and $\mu(n') = n-2 < 2n$.
The cases $n<0$ are symmetric. $\qquad\blacksquare$

**Existence.** By strong induction on $\mu(n)$: the base case $n=0$ is the empty
string, and for $n \ne 0$ Lemma 2 lets us prepend $b_0 = n \bmod 2$ to a
representation of $n'$ obtained inductively. Discarding a trailing zero if
necessary yields a canonical string. $\qquad\blacksquare$

Together, uniqueness and existence give Theorem 1. The proof uses no cardinality
argument; the entire subtlety of negative bases resides in the measure $\mu$.

---

## 4. Phinary: the golden-ratio base

### 4.1 The carry rule

> **Theorem 2 (Base-$\varphi$ carry / collapse).** For every $n$,
> $$\varphi^{\,n} + \varphi^{\,n+1} = \varphi^{\,n+2}.$$

*Proof.* Factor $\varphi^{\,n}(1 + \varphi) = \varphi^{\,n}\varphi^2 =
\varphi^{\,n+2}$, using $1+\varphi = \varphi^2$. $\qquad\blacksquare$

In digit-string form this reads $011 = 100$: two consecutive $1$s in places $n,
n+1$ collapse to a single $1$ in place $n+2$. Iterating the rule from the top
down eliminates every occurrence of the pattern $11$.

> **Corollary (No-Consecutive-Ones).** Every positive integer admits a base-$\varphi$
> representation with digits $\{0,1\}$ in which no two $1$s are adjacent.

*Sketch.* Start from any finite $\{0,1\}$-expansion of the integer (one exists
because $\varphi > 1$ and the place values are unbounded and dense enough via the
greedy algorithm). Whenever a pattern $11$ occurs, apply the carry rule
$011\to100$ to move the higher $1$ up. Each application strictly increases the
position of the highest $1$ or reduces the count of adjacent pairs, and the
process terminates in a representation free of adjacent $1$s. Uniqueness of the
resulting canonical form is the classical Zeckendorf phenomenon. $\qquad\blacksquare$

### 4.2 A concrete expansion

> **Proposition 3.** $\ \varphi^{2} + \varphi^{-2} = 3.$
> Equivalently, $3 = 100.01_{(\varphi)}$: a phinary integer using one positive
> and one negative power, digits $\{0,1\}$, no two consecutive $1$s.

*Proof.* $\varphi^2 = \varphi + 1$ and $\varphi^{-2} = (\varphi^2)^{-1} =
(\varphi+1)^{-1}$. Since $\varphi^{-1} = \varphi - 1$ (from $\varphi^2 = \varphi
+1$ divided by $\varphi$), we get $\varphi^{-2} = (\varphi-1)^2 = \varphi^2 -
2\varphi + 1 = (\varphi+1) - 2\varphi + 1 = 2 - \varphi$. Hence
$\varphi^2 + \varphi^{-2} = (\varphi+1) + (2-\varphi) = 3$. $\qquad\blacksquare$

This explains why an *integer* generally needs digits on both sides of the
phinary point: see Section 4.4.

### 4.3 The Fibonacci-coordinate bridge

Every phinary value assembled from *non-negative* powers of $\varphi$ lands in
the ring $\mathbb{Z} + \mathbb{Z}\varphi$, and its two coordinates are sums of
Fibonacci numbers.

> **Theorem 4 (Fibonacci coordinates).** For any finite set $S \subseteq
> \mathbb{N}$,
> $$\sum_{i\in S}\varphi^{\,i+1} = \Big(\sum_{i\in S} F_{i+1}\Big)\varphi \;+\;
> \sum_{i\in S} F_i.$$

*Proof.* By Binet's identity in the form $\varphi\,F_{i+1} + F_i = \varphi^{\,i+1}$,
each term $\varphi^{\,i+1}$ equals $F_{i+1}\varphi + F_i$. Summing over $i\in S$
and splitting the sum into its $\varphi$-part and constant part gives the claim.
$\qquad\blacksquare$

Thus the "coordinates" of a natural-exponent phinary value are the pair of
Fibonacci sums $\big(\sum_{i\in S}F_{i+1},\ \sum_{i\in S}F_i\big)$.

### 4.4 The Lucas integrality identity

The symmetric combination of a golden-ratio power and its conjugate is always an
integer — a Lucas number.

> **Theorem 5 (Lucas integers).** For every $n \ge 0$,
> $$\varphi^{\,n+1} + \psi^{\,n+1} = F_{n+2} + F_n.$$

*Proof.* Add Binet's identity $\varphi^{\,n+1} = F_{n+1}\varphi + F_n$ to its
conjugate $\psi^{\,n+1} = F_{n+1}\psi + F_n$. The sum is $F_{n+1}(\varphi+\psi) +
2F_n = F_{n+1} + 2F_n$, using $\varphi + \psi = 1$. Finally $F_{n+1} + 2F_n =
(F_{n+1}+F_n) + F_n = F_{n+2} + F_n$. $\qquad\blacksquare$

The quantity $L_{n+1} := F_{n+2} + F_n$ is the $(n{+}1)$-th Lucas number
$2,1,3,4,7,11,\ldots$ These are exactly the integer values reachable
*symmetrically*, which is why representing a generic integer with the one-sided
digits of Theorem 4 fails: the $\varphi$-coordinate $\sum_{i\in S}F_{i+1}$ must
vanish for integrality, and to hit a nonzero integer one is driven to negative
exponents in a symmetric (Lucas) pattern — precisely as in $3 = \varphi^2 +
\varphi^{-2}$.

### 4.5 Coordinate uniqueness from irrationality

Coordinates are only meaningful if they are unique. Over the rationals they are —
and the proof rests squarely on the irrationality of $\varphi$.

> **Theorem 6 (Coordinate uniqueness over $\mathbb{Q}$).** If $a,b,c,d \in
> \mathbb{Q}$ and $a\varphi + b = c\varphi + d$, then $a=c$ and $b=d$.

*Proof.* Suppose $a \ne c$. Rearranging, $(a-c)\varphi = d-b$, so
$\varphi = (d-b)/(a-c) \in \mathbb{Q}$. But $\varphi = (1+\sqrt5)/2$ is
irrational, since $\sqrt 5$ is irrational ($5$ is prime and not a perfect
square). This contradiction forces $a=c$; substituting back gives $b=d$.
$\qquad\blacksquare$

**Remark.** Over $\mathbb{R}$ the statement is false: any real $x$ can be written
as $a\varphi + b$ in infinitely many ways (pick any $a$ and set $b = x -
a\varphi$). Rationality of the coordinates is therefore essential, not
cosmetic — it is exactly the hypothesis that lets irrationality do its work.

### 4.6 Why an irrational radix still yields discrete structure

It is worth pausing on the apparent paradox that an *irrational* radix produces
crisp integer values and a clean combinatorial law. The resolution is that
natural-exponent phinary values do not roam freely over $\mathbb{R}$; by Theorem
4 they are confined to the two-dimensional lattice $\mathbb{Z} + \mathbb{Z}\varphi$
inside $\mathbb{R}$. Within that lattice, the constraint "be a rational number"
(indeed "be an integer") is the single linear condition that the $\varphi$-coordinate
vanishes, by Theorem 6. Thus the arithmetic of base $\varphi$ is governed not by
the analytic size of $\varphi$ but by the algebra of the quadratic field
$\mathbb{Q}(\sqrt5)$, of which $\varphi$ is a fundamental unit. The carry rule
$\varphi^2 = \varphi + 1$ is exactly the minimal polynomial relation $x^2-x-1=0$
read positionally; the Fibonacci and Lucas sequences are the two natural integer
bases for the powers of the two conjugate units. Seen this way, phinary is a
positional shadow of the unit group of a real quadratic field, which is why it is
simultaneously analytic (an irrational radix), combinatorial (Zeckendorf), and
arithmetic (Fibonacci/Lucas coordinates).

---

## 5. Toward complex bases: the base $i-1$

The negabinary and phinary results share the pattern *"a residue fixes the next
digit, and a shrinking measure guarantees termination."* This template is not
specific to $\mathbb{Z}$ or $\mathbb{R}$; it applies to any base admitting a
Euclidean-style division. The smallest genuinely two-dimensional example is the
complex base $\beta = i - 1$ over the Gaussian integers $\mathbb{Z}[i]$.

The crucial numerical fact is that $|i-1|^2 = (-1)^2 + 1^2 = 2$, so $i-1$ has
norm $2$; reduction of any Gaussian integer modulo $i-1$ leaves exactly two
residue classes, which may be named $\{0,1\}$. This is precisely the
two-digit alphabet of negabinary, now realized over a two-dimensional lattice.
One checks small values directly:
$$(i-1)^0 = 1,\quad (i-1)^1 = i-1,\quad (i-1)^2 = -2i,\quad (i-1)^3 = 2+2i,\quad (i-1)^4 = -4.$$
Just as the powers of $-2$ alternate in sign to cover both half-lines of
$\mathbb{Z}$, the powers of $i-1$ spiral through all four quadrants of the
complex plane, covering every Gaussian integer. We record the expected statement
as a conjecture (Section 7), obtained from the negabinary proof by replacing the
interleaving measure $\mu$ on $\mathbb{Z}$ with the complex norm on
$\mathbb{Z}[i]$; the residue-fixes-the-digit half of the argument transports
verbatim.

---

## 6. Algorithms

We record the two fundamental conversion algorithms; both are constructive
extractions of the existence proofs above.

**Negabinary encoding (integer $\to$ bit string).** Repeatedly emit
$b = n \bmod 2$ and update $n \leftarrow (n-b)/(-2)$ until $n=0$. By Lemma 2 the
measure $\mu(n)$ strictly decreases, so the loop halts; the emitted bits, least
significant first, form the canonical negabinary string (Theorem 1). Complexity:
$O(\log|n|)$ iterations, each $O(1)$ arithmetic on the running value.

**Negabinary decoding (bit string $\to$ integer).** Horner evaluation with
multiplier $-2$: fold the bits from most significant to least via
$acc \leftarrow (-2)\cdot acc + b$. Linear in the number of digits.

**Zeckendorf / phinary integer expansion.** Greedily subtract the largest
Fibonacci number (equivalently the largest power-region of $\varphi$) not
exceeding the remaining value; the no-consecutive-$1$s property is guaranteed
because after subtracting $F_k$ the remainder is $< F_{k-1}$, forbidding an
adjacent term. This is the discrete shadow of the carry rule $011\to100$.

---

## 7. Applications and Context

**Sign-free integer arithmetic.** Negabinary is used in specialized hardware and
in the arithmetic of certain digital signal-processing pipelines precisely
because it eliminates the special-case handling of negative numbers: addition,
negation, and comparison become uniform bit operations with no sign channel.

**Fibonacci coding and Zeckendorf representation.** The no-consecutive-$1$s
property is the defining feature of Zeckendorf's theorem and underlies
Fibonacci-based prefix codes used in data compression, which are robust to
single-bit errors precisely because the pattern $11$ is forbidden and can serve
as a delimiter.

**A cultural thought experiment.** The results dramatize that base ten is a
contingent choice. A civilization prioritizing symmetry between positive and
negative quantities might adopt negabinary; one prizing aesthetic economy might
adopt base $\varphi$. More prosaically, an eight-limbed species might favor base
$8$ and a calendar-driven one base $12$. The mathematics is indifferent to the
choice; what these exotic bases reveal is which structural features (sign,
forbidden patterns, Fibonacci coordinates) each convention makes visible.

---

## 8. Discussion and Future Directions

The two systems share a common proof skeleton — *"a residue fixes the next
digit, and a shrinking measure guarantees termination"* — which suggests several
generalizations.

**A uniform bijection for all bases $b \le -2$.** The base-$(-2)$ argument used
only two base-agnostic facts: the least-significant digit is determined by the
value modulo $|b|$, and an interleaving measure on $\mathbb{Z}$ strictly
decreases under the base-$b$ successor. We conjecture that for every integer base
$b \le -2$, canonical digit strings over $\{0,1,\ldots,|b|-1\}$ biject with
$\mathbb{Z}$.

**Gaussian integers in base $i-1$.** Since $|i-1|^2 = 2$, reduction modulo $i-1$
leaves exactly the residues $\{0,1\}$. We conjecture that every Gaussian integer
has a unique $\{0,1\}$-representation in base $i-1$, obtained by replacing the
interleaving measure on $\mathbb{Z}$ with the complex norm in the very same
"residue + shrinking measure" recursion.

**$\varphi$ as the unique no-consecutive-digit base.** The collapse identity
$\beta^n + \beta^{n+1} = \beta^{n+2}$ is literally $\beta^2 = \beta + 1$, whose
only root exceeding $1$ is $\varphi$. We conjecture that among real bases
$\beta > 1$, the golden ratio is the *only* one whose greedy $\{0,1\}$-expansions
avoid the pattern $11$; the no-consecutive-$1$s phenomenon is thus $\varphi$'s
algebraic signature rather than a coincidence.

**A Fibonacci-coordinate integrality criterion.** By Theorem 4, a
non-negative-exponent phinary value $\sum_{i\in S}\varphi^{\,i}$ is an integer
iff its $\varphi$-coordinate $\sum_{i\in S}F_i$ vanishes; realizing a nonzero
integer with digits $\{0,1\}$ then forces negative exponents in a symmetric
(Lucas) pattern. Making the "only way" clause precise — classifying all
digit-$\{0,1\}$ integer representations in base $\varphi$ — is a natural next
target.

---

## 9. Conclusion

Detaching the notion of a base from the positive integers reveals that the
architecture of positional arithmetic is remarkably robust. Base $-2$ names all
of $\mathbb{Z}$ bijectively with two digits and no sign, its only real difficulty
being the correct termination measure. Base $\varphi$ names integers with a
forbidden adjacency that is nothing but the positional echo of
$\varphi^2=\varphi+1$, tying together the golden ratio, the Fibonacci and Lucas
sequences, and the irrationality of $\varphi$ in a single radix. The shared
proof template points toward a unified theory of exotic bases spanning the
negative, the complex, and the irrational.
