# Head Coefficients of Monstrous Products: Stable-Range Additivity, Frame-Shape Formulas, and a Finite Reduction

**Author:** Aristotle
**Date:** 2026-08-20

## Abstract

Let $T_g = q^{-1} + c_g(1)q + c_g(2)q^2 + \cdots$ be the McKay–Thompson series
attached to the $194$ conjugacy classes of the Monster, normalized so that the pole
is simple and the constant term vanishes. We study the Laurent expansion of the
product $P = \prod_g T_g$ near its pole of order $194$. Our central structural result
is a *stable-range additivity theorem*: if every factor of a finite product of formal
power series over a commutative ring is congruent to $1$ modulo $q^d$, then in the
entire range $1 \le k < 2d$ the coefficient of $q^k$ in the product equals the sum of
the coefficients of $q^k$ in the factors, with no elementary-symmetric corrections
whatsoever. The bound $k < 2d$ is sharp, and at the boundary degree $k = 2d$ the sole
correction is the second elementary symmetric function of the degree-$d$
coefficients. Since $qT_g \equiv 1 \pmod{q^2}$, the theorem yields the first three
Laurent coefficients of $P$ above the pole as $0$, $\sum_g c_g(1)$ and $\sum_g
c_g(2)$, and the fourth as $\sum_g c_g(3) + e_2\bigl(c_g(1)\bigr)$. Consequently the
analytic assertion $[q^{-192}]P = N$ over $\mathbb{C}$ is *equivalent* to the finite
integer assertion $\sum_g c_g(1) = N$, and hence is decidable once the head table is
given. We then show that for eta-quotient classes the table is not data but is
computable from frame shapes: the head coefficient is $a_1(a_1+3)/2 + a_2$, the
second is $\bigl(b_1(b_1+1)(b_1+2) + 6b_1b_2 + 6b_3\bigr)/6$ with $b_m = \sum_{k \mid
m} a_k$, and a logarithmic-derivative argument yields the complete Newton-type
recursion $r c_r = \sum_{k<r} c_k \sigma_a(r-k)$, $\sigma_a(r) = \sum_{d \mid r} d\,
b_d$, determining every coefficient. For the eight balanced frame shapes $1^{-e}
n^{e}$ with $e(n-1)=24$ this produces the derived columns $(276, 54, 20, 9, 2, 0, -1,
-1)$, $(-2048, -76, 0, 10, 8, 5, 2, 0)$ and $(11202, -243, -62, -30, -5, 0, 1, 0)$,
whose sums $359$, $-2099$, $10863$ are, together with the sum of squares $79579$, the
exact head Laurent coefficients $359$, $-2099$, $35514$ of the corresponding
eight-fold product. Finally we prove a uniform sharp lower bound $c_g(1) \ge -1$ over
the whole family of shapes $1^{-e}n^{e}$ with $n > 2$.

**Keywords:** Monstrous Moonshine, McKay–Thompson series, frame shapes, eta
quotients, formal power series, Newton recursion, elementary symmetric functions.

---

## 1. Introduction

### 1.1 Setting

Write $q = e^{2\pi i \tau}$ for $\tau$ in the upper half-plane. Monstrous Moonshine
attaches to each conjugacy class $[g]$ of the Monster group $\mathbb{M}$ a
*McKay–Thompson series*

$$T_g(\tau) = \frac{1}{q} + \sum_{n \ge 1} c_g(n)\, q^n,$$

a Hauptmodul for a genus-zero subgroup of $\mathrm{SL}_2(\mathbb{R})$, normalized so
that the pole at the cusp is simple with residue $1$ and the constant term vanishes.
For the identity class one recovers $j - 744$. There are $194$ conjugacy classes, and
the object of study here is the $194$-fold product

$$P \;=\; \prod_{[g]} T_g,$$

a Laurent series with a pole of order $194$.

Direct expansion of $P$ is combinatorially forbidding: the coefficient of $q^{-194+k}$
is *a priori* a sum over all ways of distributing the total degree $k$ among $194$
factors, i.e. a symmetric-function expression of unbounded complexity in the entries
of the head table $\bigl(c_g(n)\bigr)$. The content of this paper is that near the
pole this complexity is illusory, that the collapse has an exact range, and that the
head table itself is computable for a large family of classes.

### 1.2 Results

**Structural.** The *stable-range additivity theorem* (Theorem 3.4) states that a
finite product of power series each congruent to $1$ modulo $q^d$ is additive on
coefficients in every degree $1 \le k < 2d$. Sharpness is Proposition 3.6, and the
boundary correction is Theorem 3.8.

**Analytic-to-arithmetic.** Theorem 4.3 gives the first three Laurent coefficients of
$P$ above the pole; Theorem 4.5 is the resulting equivalence between the analytic
statement $[q^{-192}]P = N$ and the arithmetic statement $\sum_g c_g(1) = N$, and
Corollary 4.6 records that the analytic statement is therefore decidable.

**Computing the table.** Theorem 5.4 computes the head coefficient of an eta-quotient
class in closed form from its frame shape; Theorem 5.6 does the same one degree
higher; and Theorem 6.3 establishes the complete Newton recursion, from which
Theorem 6.6 deduces truncation stability of every coefficient.

**Worked family and a bound.** Section 7 tabulates the eight balanced shapes
$1^{-e}n^{e}$, computes the head Laurent coefficients $359$, $-2099$, $35514$ of the
corresponding eight-fold product (Theorem 7.3), and proves the uniform sharp lower
bound $c_g(1) \ge -1$ (Theorem 7.5).

---

## 2. Notation and conventions

Throughout, $R$ is a commutative ring and $R[[q]]$ the ring of formal power series.
For $f \in R[[q]]$ we write $[q^k]f$ for the coefficient of $q^k$, and $[q^0]f$ for
the constant term. For Laurent series (finitely many negative-degree terms) we use
the same notation with $k \in \mathbb{Z}$.

**Definition 2.1 (Normalized series).** A formal Laurent series $f$ over
$\mathbb{C}$ is *normalized* if $[q^{-1}]f = 1$ and $[q^{k}]f = 0$ for all $k < -1$;
that is, $f = q^{-1} + \sum_{n \ge 0} [q^n]f\, q^n$. For a normalized $f$ its
*normalized part* is the power series $qf \in \mathbb{C}[[q]]$, which has constant
term $1$.

**Definition 2.2 (Moonshine normalization).** A normalized $f$ is *moonshine-
normalized* if in addition $[q^0]f = 0$. Every McKay–Thompson series is
moonshine-normalized, and this is the only property of them used in Sections 3–4.

**Definition 2.3 (Integral head table).** An *integral head table* of size $m$ is a
family $c : \{1, \dots, m\} \times \mathbb{Z}_{\ge0} \to \mathbb{Z}$ with $c_i(0) = 0$
for all $i$. It determines $m$ moonshine-normalized series $T_i = q^{-1} + \sum_{n
\ge 0} c_i(n) q^n$.

---

## 3. Stable-range additivity

### 3.1 One-like series

**Definition 3.1.** Let $d \ge 0$. A power series $f \in R[[q]]$ is *one-like to
depth $d$*, written $f \equiv 1 \pmod{q^d}$, if $[q^0]f = 1$ and $[q^j]f = 0$ for all
$0 < j < d$.

**Lemma 3.2 (Closure under multiplication).** If $f \equiv 1$ and $g \equiv 1$
modulo $q^d$ then $fg \equiv 1 \pmod{q^d}$.

*Proof.* The constant term of $fg$ is the product of the constant terms, namely $1$.
For $0 < j < d$, expand $[q^j](fg) = \sum_{p+r=j} [q^p]f \cdot [q^r]g$. In each term
either $p = 0$, whence $r = j$ satisfies $0 < r < d$ and $[q^r]g = 0$; or $p > 0$,
and then $p \le j < d$, so $[q^p]f = 0$. Every term vanishes. $\square$

By induction, a finite product $\prod_{i \in S} f_i$ of series one-like to depth $d$
is one-like to depth $d$ (Lemma 3.3), the empty product being $1$.

### 3.2 The theorem

**Theorem 3.4 (Stable-range additivity, two factors).** Let $f, g \in R[[q]]$ both be
one-like to depth $d$, and let $k$ satisfy $1 \le k < 2d$. Then

$$[q^k](fg) \;=\; [q^k]f + [q^k]g .$$

*Proof sketch.* Write $[q^k](fg) = \sum_{p + r = k}[q^p]f\,[q^r]g$ over the
antidiagonal of $k$. Isolate the two extreme terms $(p,r) = (0,k)$ and $(k,0)$; they
contribute $1 \cdot [q^k]g$ and $[q^k]f \cdot 1$ respectively, and they are distinct
because $k \ge 1$. For any other term both $p$ and $r$ are strictly positive. If
$p < d$ then $[q^p]f = 0$; otherwise $p \ge d$, and since $p + r = k < 2d$ we get
$r < d$, so $[q^r]g = 0$. Hence all remaining terms vanish. $\square$

**Theorem 3.5 (Stable-range additivity, finite products).** Let $S$ be a finite index
set and let $f_i \in R[[q]]$ be one-like to depth $d$ for each $i \in S$. Then for
every $k$ with $1 \le k < 2d$,

$$[q^k]\Bigl(\prod_{i \in S} f_i\Bigr) \;=\; \sum_{i \in S} [q^k]f_i .$$

*Proof.* Induction on $S$. For $S = \varnothing$ the product is $1$ and both sides
vanish since $k \ge 1$. For $S = \{a\} \sqcup S'$, the tail $\prod_{i \in S'}f_i$ is
one-like to depth $d$ by Lemma 3.3, so Theorem 3.4 applies to the two-factor product
$f_a \cdot \prod_{S'} f_i$, and the inductive hypothesis handles the tail. $\square$

The theorem holds over an arbitrary commutative ring; no divisions, no characteristic
assumptions, and no bound on the number of factors are required.

### 3.3 Sharpness and the boundary correction

**Proposition 3.6 (Sharpness).** Additivity fails at $k = 2d$. Explicitly, over
$\mathbb{Z}$ take $d = 2$ and $f = g = 1 + q^2$. Both are one-like to depth $2$, and
$fg = 1 + 2q^2 + q^4$, so $[q^4](fg) = 1$ while $[q^4]f + [q^4]g = 0$.

**Lemma 3.7 (Boundary, two factors).** If $f, g \equiv 1 \pmod{q^2}$ then

$$[q^4](fg) = [q^4]f + [q^4]g + [q^2]f\cdot[q^2]g .$$

*Proof.* Expand over the antidiagonal $\{(0,4),(1,3),(2,2),(3,1),(4,0)\}$ and use
$[q^0]f = [q^0]g = 1$, $[q^1]f = [q^1]g = 0$. Only three terms survive. $\square$

**Theorem 3.8 (Boundary correction, finite products).** Let $f_i \equiv 1 \pmod{q^2}$
for $i \in S$ finite. Then

$$2\,[q^4]\Bigl(\prod_{i\in S} f_i\Bigr) \;=\; 2\sum_{i \in S}[q^4]f_i
\;+\; \Bigl(\sum_{i\in S}[q^2]f_i\Bigr)^{2} \;-\; \sum_{i\in S}\bigl([q^2]f_i\bigr)^2 .$$

Equivalently, when $2$ is invertible,
$[q^4]\prod f_i = \sum_i [q^4]f_i + e_2\bigl([q^2]f_i\bigr)$, where $e_2$ is the
second elementary symmetric function.

*Proof sketch.* Induction on $S$, inserting one factor $f_a$ at a time. Lemma 3.7
supplies the two-factor step; the degree-$2$ coefficient of the tail product is the
plain sum $\sum_{S'}[q^2]f_i$ by Theorem 3.5 (degree $2$ lies in the stable range for
$d = 2$), so the new cross term is $[q^2]f_a \cdot \sum_{S'}[q^2]f_i$, which is
precisely the increment of $e_2$. Writing $e_2$ in the division-free form
$\bigl((\sum x)^2 - \sum x^2\bigr)/2$ keeps the identity valid over any commutative
ring. $\square$

**Remark 3.9 (The expected pattern).** A factor can influence degree $k$ only through
its coefficients in degrees $\ge d$, so at most $\lfloor k/d \rfloor$ factors can be
simultaneously active. This suggests that in the range $jd \le k < (j+1)d$ the
coefficient of the product is a polynomial in the individual coefficients involving
exactly the elementary symmetric functions $e_1, \dots, e_j$ of the relevant
coefficient families, and no higher ones — the governing combinatorics being that of
partitions of $k$ into parts of size at least $d$. The cases $j = 1$ (Theorem 3.5)
and $j = 2$ at the boundary (Theorem 3.8) are established above.

---

## 4. The head of a Monstrous product

### 4.1 Depth of a moonshine-normalized series

**Lemma 4.1.** If $f$ is moonshine-normalized then its normalized part $qf$ is
one-like to depth $2$.

*Proof.* The constant term of $qf$ is $[q^{-1}]f = 1$; its degree-$1$ coefficient is
$[q^0]f = 0$. $\square$

**Lemma 4.2 (Pole factorization).** If $f_i$, $i \in S$, are normalized with $|S| =
m$, then $\prod_{i \in S} f_i = q^{-m}\prod_{i \in S}(q f_i)$; in particular the
product has a pole of order exactly $m$ (the leading coefficient being $1$), and for
every $k \ge 0$,
$$\Bigl[q^{\,k-m}\Bigr]\prod_{i\in S} f_i = [q^k]\prod_{i \in S}(qf_i).$$

### 4.2 The first three coefficients above the pole

**Theorem 4.3 (Head coefficients).** Let $f_i$, $i \in S$, be $m = |S|$
moonshine-normalized Laurent series. Then for $j = 0, 1, 2$,

$$\Bigl[q^{\,j+1-m}\Bigr]\prod_{i \in S} f_i \;=\; \sum_{i \in S} [q^{\,j}] f_i .$$

In particular the coefficient in degree $1-m$ (immediately below the leading
$q^{-m}$) is $0$, the coefficient in degree $2-m$ is $\sum_i [q^1]f_i$, and the
coefficient in degree $3-m$ is $\sum_i [q^2]f_i$.

*Proof.* By Lemma 4.2 the coefficient in degree $j + 1 - m$ of the product equals the
coefficient of $q^{j+1}$ in $\prod_i (qf_i)$. By Lemma 4.1 each $qf_i$ is one-like to
depth $2$, and $1 \le j + 1 < 4 = 2 \cdot 2$ exactly when $0 \le j \le 2$. Theorem 3.5
then gives $\sum_i [q^{j+1}](qf_i) = \sum_i [q^{j}]f_i$, the last equality being the
shift $[q^{n+1}](qf) = [q^n]f$. $\square$

Applied to the Monster with $m = 194$: the coefficients of $q^{-193}, q^{-192},
q^{-191}$ in $P$ are $0$, $\sum_g c_g(1)$, $\sum_g c_g(2)$.

**Theorem 4.4 (Fourth coefficient).** With $f_i$ as above,

$$2\Bigl[q^{\,4-m}\Bigr]\prod_{i\in S}f_i \;=\; 2\sum_{i\in S}[q^3]f_i
+\Bigl(\sum_{i\in S}[q^1]f_i\Bigr)^{2}-\sum_{i\in S}\bigl([q^1]f_i\bigr)^2 ,$$

i.e. the coefficient equals $\sum_i [q^3]f_i + e_2\bigl([q^1]f_i\bigr)$.

*Proof.* Combine Lemma 4.2 with Theorem 3.8, using $[q^4](qf) = [q^3]f$ and
$[q^2](qf) = [q^1]f$. $\square$

### 4.3 Reduction and decidability

**Theorem 4.5 (Finite reduction).** Let $c$ be an integral head table of size $m$
with associated series $T_i$, and let $N \in \mathbb{Z}$. Then

$$\Bigl[q^{\,2-m}\Bigr]\prod_{i=1}^{m} T_i \;=\; N \quad\text{in } \mathbb{C}
\qquad\Longleftrightarrow\qquad \sum_{i=1}^{m} c_i(1) \;=\; N \quad\text{in } \mathbb{Z}.$$

*Proof.* By Theorem 4.3 with $j = 1$, the left-hand coefficient equals $\sum_i c_i(1)$
regarded as a complex number. The canonical map $\mathbb{Z} \to \mathbb{C}$ is
injective, so equality of the images is equivalent to equality of the integers.
$\square$

**Corollary 4.6 (Decidability).** For $m = 194$ and any integral head table $c$, the
statement $[q^{-192}]\prod_g T_g = N$ — an assertion about a product of $194$ complex
Laurent series — is decidable: it holds if and only if the integer $\sum_g c_g(1)$
equals $N$, which is settled by adding $194$ integers.

**Remark 4.7.** The same argument gives decidability for $[q^{-191}]P = N$ (via
$\sum_g c_g(2)$) and, using Theorem 4.4, for $[q^{-190}]P = N$ (via $\sum_g c_g(3)$
together with $\sum_g c_g(1)$ and $\sum_g c_g(1)^2$). Beyond that, Remark 3.9
predicts that finitely many further symmetric data per degree suffice, so the
reduction is expected to persist degree by degree, with the number of required
columns growing like $k/2$.

---

## 5. Where the table comes from: frame shapes

### 5.1 Eta quotients

Let $\eta(\tau) = q^{1/24}\prod_{m \ge 1}(1 - q^m)$ be the Dedekind eta function. For
many Monster classes $g$ the McKay–Thompson series is $1/\eta_g$ up to an additive
constant, where

$$\eta_g(\tau) = \prod_{k \ge 1}\eta(k\tau)^{a_k}$$

for a finitely supported family $a = (a_k)_{k\ge1}$ of integers, the *frame shape* of
$g$ — classically the multiset of elementary divisors of $g$ acting on the Leech
lattice, written $\prod_k k^{a_k}$. The shape is *balanced* when $\sum_k k\,a_k = 24$,
which is exactly the condition making $\eta_g$ have weight $12$ and the $q$-powers
line up so that $q\cdot(1/\eta_g)$ is a power series with constant term $1$.

**Definition 5.1 (Divisor sums of a shape).** $b_m := \sum_{k \mid m} a_k$. Grouping
the factors of $\prod_k \prod_{n\ge1}(1-q^{kn})^{-a_k}$ by total degree $m = kn$
yields the fundamental identity

$$q \cdot \frac{1}{\eta_g} \;=\; \prod_{m\ge1}(1-q^m)^{-b_m} .$$

**Definition 5.2 (Truncated eta quotient).** For $M \ge 1$ put
$E_M(a) := \prod_{m=1}^{M} (1-q^m)^{-b_m}$, a unit of $R[[q]]$ with constant term
$1$. Since the $m$-th factor is $\equiv 1 \pmod{q^m}$, the coefficient of $q^r$ in
$E_M(a)$ is independent of $M$ as soon as $M \ge r$ (Theorem 6.6 below), and equals
the coefficient of $q^r$ in the infinite product. We write $c_r(a)$ for that stable
value. In terms of the moonshine normalization, $c_{r+1}(a)$ is the coefficient
$c_g(r)$ of the corresponding McKay–Thompson series.

### 5.2 Integer powers of a unit and the head formula

The computation rests on jets of integer powers.

**Lemma 5.3 (Two-jet of $u^z$).** Let $u \in R[[q]]$ be a unit with $[q^0]u = 1$ and
let $z \in \mathbb{Z}$. Then $[q^0](u^z) = 1$, $[q^1](u^z) = z\,[q^1]u$, and

$$2\,[q^2](u^z) = 2z\,[q^2]u + z(z-1)\bigl([q^1]u\bigr)^2 .$$

*Proof sketch.* First compute the low coefficients of $u^{-1}$ from $u \cdot u^{-1} =
1$: $[q^1](u^{-1}) = -[q^1]u$ and $[q^2](u^{-1}) = -[q^2]u + ([q^1]u)^2$. Then induct
on $z$ in both directions (multiplying by $u$ for $z \mapsto z+1$, by $u^{-1}$ for
$z \mapsto z-1$), using the elementary product formulas $[q^1](fg) = [q^0]f\,[q^1]g +
[q^1]f\,[q^0]g$ and $[q^2](fg) = [q^0]f\,[q^2]g + [q^1]f\,[q^1]g + [q^2]f\,[q^0]g$.
The stated formulas are the binomial expansions $\binom{z}{1}$, $\binom{z}{2}$ written
without division so as to remain valid over any commutative ring. $\square$

**Theorem 5.4 (Frame-shape head formula).** For every frame shape $a$ and every
$M \ge 2$,

$$[q^2]\,E_M(a) \;=\; \frac{a_1(a_1+3)}{2} + a_2 ,$$

and the division is exact. Equivalently, the head coefficient of the corresponding
McKay–Thompson series is $c_g(1) = a_1(a_1+3)/2 + a_2$.

*Proof sketch.* Write $E_M(a) = \prod_{m=1}^M u_m^{-b_m}$ with $u_m = 1 - q^m$. Each
factor has constant term $1$, so by the level-one and level-two Newton identities for
products of series with constant term $1$,
$$[q^1]\prod_m F_m = \sum_m [q^1]F_m,\qquad
2[q^2]\prod_m F_m = 2\sum_m [q^2]F_m + \Bigl(\sum_m [q^1]F_m\Bigr)^2 - \sum_m
\bigl([q^1]F_m\bigr)^2 .$$
By Lemma 5.3 applied to $u_m$ with $z = -b_m$, the factor $F_m = u_m^{-b_m}$ has
$[q^1]F_m = b_1$ if $m = 1$ and $0$ otherwise, and $2[q^2]F_m = b_1(b_1+1)$ if
$m = 1$, $= 2b_2$ if $m = 2$, and $0$ otherwise. Substituting,
$2[q^2]E_M(a) = b_1(b_1+1) + 2b_2 + b_1^2 - b_1^2 = b_1(b_1+1) + 2b_2$. Now
$b_1 = a_1$ and $b_2 = a_1 + a_2$, so the right-hand side is $a_1(a_1+1) + 2a_1 +
2a_2 = a_1(a_1+3) + 2a_2$. Finally $a_1(a_1+3)$ is even for every integer $a_1$
(consider $a_1$ even and odd separately), so the division is exact. $\square$

**Remark 5.5.** The formula involves only $a_1$ and $a_2$: the entire tail of the
frame shape is invisible to the head coefficient. This is a shadow of stable-range
additivity, applied inside the eta product rather than across McKay–Thompson series.

**Theorem 5.6 (Second head coefficient).** For every frame shape $a$ and $M \ge 3$,

$$6\,[q^3]E_M(a) \;=\; b_1(b_1+1)(b_1+2) + 6\,b_1b_2 + 6\,b_3 ,$$

and the right-hand side is divisible by $6$; equivalently $c_g(2) = \bigl(b_1(b_1+1)
(b_1+2) + 6b_1b_2 + 6b_3\bigr)/6$.

*Proof sketch.* The three-jet analogue of Lemma 5.3 gives, for a unit $u$ with
constant term $1$,
$$6[q^3](u^z) = 6z\,[q^3]u + 6z(z-1)\,[q^1]u\,[q^2]u + z(z-1)(z-2)\bigl([q^1]u\bigr)^3,$$
again proved by induction in both directions from the coefficients of $u^{-1}$. Now
split $E_M(a) = F_1 \cdot \prod_{m \ge 2} F_m$. Every factor with $m \ge 2$ is one-
like to depth $2$, so by Theorem 3.5 the tail product has $[q^1] = 0$, $[q^2] = b_2$
and $[q^3] = b_3$ — the only contributing factors being $m = 2$ and $m = 3$
respectively. For the head factor $F_1 = (1-q)^{-b_1}$ the three-jet formula gives
$[q^1]F_1 = b_1$, $2[q^2]F_1 = b_1(b_1+1)$, $6[q^3]F_1 = b_1(b_1+1)(b_1+2)$.
Multiplying out $[q^3](F_1 \cdot \text{tail})$ and clearing denominators gives the
statement. Divisibility by $6$ holds because $b_1(b_1+1)(b_1+2)$ is a product of
three consecutive integers. $\square$

---

## 6. The complete Newton recursion

The jet method above costs a longer computation for each new degree. A single
structural identity replaces it in all degrees.

**Definition 6.1 (Logarithmic derivative relation).** For a unit $u \in R[[q]]$ and
$\ell \in R[[q]]$ say that $\ell$ is *the logarithmic derivative* of $u$, written
$\mathrm{LD}(u, \ell)$, if
$$q\,u' \;=\; u\,\ell$$
in $R[[q]]$, where $'$ is the formal derivative. The multiplicative formulation
avoids ever dividing.

**Lemma 6.2 (Calculus of logarithmic derivatives).** If $\mathrm{LD}(u,\ell)$ and
$\mathrm{LD}(v, m)$ then $\mathrm{LD}(uv, \ell+m)$ and $\mathrm{LD}(u^{-1}, -\ell)$;
consequently $\mathrm{LD}(u^{z}, z\ell)$ for every $z \in \mathbb{Z}$, and
$\mathrm{LD}\bigl(\prod_i u_i, \sum_i \ell_i\bigr)$ for finite products.

*Proof sketch.* Products: apply the Leibniz rule to $q(uv)' = u\,(qv') + v\,(qu')$ and
substitute. Inverses: differentiate $uu^{-1} = 1$, giving $(u^{-1})' = -u^{-2}u'$, and
multiply by $q$. Integer powers: induct in both directions, the negative direction
using the inverse rule. $\square$

**The elementary factor.** With $\gamma_k := \sum_{j \ge 1} q^{jk}$, the identity
$(1-q^k)\gamma_k = q^k$ holds, and differentiating $u = 1 - q^k$ gives
$q u' = -k q^k = -k(1-q^k)\gamma_k = u\cdot(-k\gamma_k)$, i.e.
$\mathrm{LD}(1 - q^k, -k\gamma_k)$.

**Definition.** For a frame shape $a$ set $\sigma_a(r) := \sum_{d \mid r} d\, b_d$.

Combining Lemma 6.2 with the elementary factor, the truncated eta quotient satisfies
$\mathrm{LD}\bigl(E_M(a), L_M\bigr)$ with $L_M = \sum_{m=1}^{M} m\,b_m\,\gamma_m$, and
since $[q^r]\gamma_m = 1$ exactly when $m \mid r$ and $r > 0$,

$$[q^r]L_M = \sum_{\substack{d \mid r,\ d \le M}} d\,b_d = \sigma_a(r)
\qquad (1 \le r \le M), \qquad [q^0]L_M = 0.$$

**Theorem 6.3 (Newton recursion for eta quotients).** For all $1 \le r \le M$ and any
commutative ring $R$,

$$r\,[q^r]E_M(a) \;=\; \sum_{k=0}^{r-1} [q^k]E_M(a)\;\sigma_a(r-k) .$$

Together with $[q^0]E_M(a) = 1$ this determines every coefficient from the frame
shape.

*Proof.* Take the coefficient of $q^r$ in $q\,E' = E\,L$. On the left, $[q^r](qE') =
r\,[q^r]E$. On the right, $[q^r](EL) = \sum_{k=0}^{r}[q^k]E\;[q^{r-k}]L$, and the term
$k = r$ vanishes because $[q^0]L = 0$; the remaining terms have $1 \le r - k \le r \le
M$, so $[q^{r-k}]L = \sigma_a(r-k)$. $\square$

**Corollary 6.4 (First instances).** Writing $c_r = [q^r]E_M(a)$ for $M \ge r$:

- $c_1 = b_1$;
- $2c_2 = b_1^2 + b_1 + 2b_2$, which agrees with Theorem 5.4 after substituting
  $b_1 = a_1$, $b_2 = a_1+a_2$;
- $6c_3 = b_1(b_1+1)(b_1+2) + 6b_1b_2 + 6b_3$, which agrees with Theorem 5.6;
- $24c_4 = 6\sigma_a(4) + 6b_1\sigma_a(3) + 3\bigl(b_1^2+b_1+2b_2\bigr)\sigma_a(2)
  + b_1\bigl(b_1(b_1+1)(b_1+2) + 6b_1b_2 + 6b_3\bigr)$.

The agreement in degrees $2$ and $3$ is a genuine cross-check: the recursion route
and the jet route share no intermediate step.

**Remark 6.5 (Conjectural universal polynomials).** The recursion is a triangular
linear system whose only divisions are by $1, 2, \dots, r$, and each $\sigma_a(j)$ is
linear in the $b$'s with weight $j$. One therefore expects a universal polynomial
$P_r \in \mathbb{Q}[y_1,\dots,y_r]$, independent of the frame shape, with $c_r =
P_r(b_1,\dots,b_r)$, homogeneous of weighted degree $r$ when $y_m$ carries weight
$m$, with leading term $y_1^r/r!$, and with $r!\,P_r$ integral. The degree-$4$ formula
above has denominator exactly $24 = 4!$, as predicted.

**Theorem 6.6 (Truncation stability).** For every $r$ and all $M, N \ge r$,
$[q^r]E_M(a) = [q^r]E_N(a)$. Hence each $c_r(a)$ is an honest coefficient of the
infinite product $\prod_{m\ge1}(1-q^m)^{-b_m}$.

*Proof.* Strong induction on $r$. For $r = 0$ both sides are $1$. For $r \ge 1$ apply
Theorem 6.3 for $M$ and for $N$; the right-hand sides involve only coefficients of
index $k < r$, equal by induction, and the same numbers $\sigma_a(r-k)$. Hence
$r\,[q^r]E_M = r\,[q^r]E_N$, and one cancels $r \ne 0$ over $\mathbb{Z}$. $\square$

---

## 7. The eight balanced shapes $1^{-e}n^{e}$

**Definition 7.1.** For $n \ne 1$ and $e \in \mathbb{Z}$ let $\mathrm{pm}(n,e)$ be the
frame shape with $a_1 = -e$, $a_n = e$, all other $a_k = 0$; thus $\eta_g =
\eta(n\tau)^e/\eta(\tau)^e$. It is balanced, $\sum_k k a_k = 24$, exactly when
$e(n-1) = 24$.

Since $n - 1$ must divide $24$ and $n > 1$, there are exactly eight admissible pairs:

$$(n,e) \in \{(2,24),(3,12),(4,8),(5,6),(7,4),(9,3),(13,2),(25,1)\}.$$

**Proposition 7.2 (Closed form on the family).** For $n > 2$, Theorem 5.4 gives
$c_g(1) = e(e-3)/2$; for $n = 2$ one has additionally $a_2 = e$, so
$c_g(1) = e(e-3)/2 + e$.

Evaluating Theorem 5.4, Theorem 5.6 and Corollary 6.4 on the eight shapes yields the
head block of $q\cdot(1/\eta_g) = \prod_m (1-q^m)^{-b_m}$:

| $n$ | $e$ | $c_0$ | $c_1$ | $c_2 = c_g(1)$ | $c_3 = c_g(2)$ | $c_4 = c_g(3)$ |
|---:|---:|---:|---:|---:|---:|---:|
| $2$ | $24$ | $1$ | $-24$ | $276$ | $-2048$ | $11202$ |
| $3$ | $12$ | $1$ | $-12$ | $54$ | $-76$ | $-243$ |
| $4$ | $8$ | $1$ | $-8$ | $20$ | $0$ | $-62$ |
| $5$ | $6$ | $1$ | $-6$ | $9$ | $10$ | $-30$ |
| $7$ | $4$ | $1$ | $-4$ | $2$ | $8$ | $-5$ |
| $9$ | $3$ | $1$ | $-3$ | $0$ | $5$ | $0$ |
| $13$ | $2$ | $1$ | $-2$ | $-1$ | $2$ | $1$ |
| $25$ | $1$ | $1$ | $-1$ | $-1$ | $0$ | $0$ |

Column sums: $\sum c_g(1) = 359$, $\sum c_g(2) = -2099$, $\sum c_g(3) = 10863$, and
$\sum c_g(1)^2 = 79579$. (The coefficient $c_1 = -e$ is the constant term of
$1/\eta_g$; the moonshine normalization is $T_g = 1/\eta_g + e$, which is precisely
what makes the constant term vanish and puts these classes in the scope of Section 4.)

**Theorem 7.3 (Head of the eight-fold product).** Let $T_1,\dots,T_8$ be any
moonshine-normalized series whose coefficient tables agree with the columns above in
degrees $1$, $2$ and $3$. Then, irrespective of all their higher coefficients,

$$\prod_{i=1}^{8}T_i \;=\; q^{-8} + 0\cdot q^{-7} + 359\,q^{-6} - 2099\,q^{-5}
+ 35514\,q^{-4} + O\!\left(q^{-3}\right).$$

*Proof.* The first three displayed coefficients above the pole are Theorem 4.3 with
$m = 8$ and $j = 0, 1, 2$, giving $0$, $359$ and $-2099$. The fourth is Theorem 4.4:
$$\sum_i c_i(3) + e_2\bigl(c_i(1)\bigr) = 10863 + \tfrac12\bigl(359^2 - 79579\bigr)
= 10863 + 24651 = 35514 . \qquad\square$$

**Remark 7.4.** Note what is and is not used. Theorem 7.3 requires no information
about the eight series beyond three integers each; the entries of those columns are
themselves determined by the eight pairs $(n,e)$ through the closed formulas of
Sections 5 and 6. The chain from *eight pairs of small integers* to the analytic
expansion of an eight-fold product of transcendental functions is complete and finite.

**Theorem 7.5 (Uniform sharp lower bound).** For every integer $e$ and every $n > 2$,
the head coefficient of the shape $\mathrm{pm}(n,e)$ satisfies $c_g(1) = e(e-3)/2 \ge
-1$, with equality exactly at $e \in \{1,2\}$. For $n = 2$ one has $c_g(1) =
e(e-3)/2 + e \ge 0$.

*Proof.* $e(e-3)/2 + 1 = (e-1)(e-2)/2$, and $(e-1)(e-2) \ge 0$ for every integer $e$
since consecutive integers cannot have opposite signs; it vanishes exactly for
$e \in \{1,2\}$. For $n = 2$, $e(e-3)/2 + e = e(e-1)/2 \ge 0$ similarly. $\square$

Among the eight admissible shapes the bound is attained at $e = 1$ and $e = 2$, i.e.
at $n = 25$ and $n = 13$. This is a small, unconditional shadow of the positivity
phenomena that pervade Monstrous Moonshine: the head coefficients of this family are
never smaller than $-1$, and in fact the whole family's head column is antitone in
$n$.

---

## 8. Algorithms

Three algorithms extract every number in this paper. All are exact integer
arithmetic; no floating point occurs anywhere.

**A. Eta-quotient expansion by the Newton recursion.** *Input:* frame shape $a$
(finitely supported), degree bound $N$. *Output:* $c_0,\dots,c_N$ with
$\sum c_r q^r = \prod_{m\ge1}(1-q^m)^{-b_m}$.
Compute $b_d$ for $d \le N$ by divisor sums, then $\sigma_a(r) = \sum_{d\mid r}d\,b_d$,
then iterate $c_0 = 1$, $c_r = \frac1r\sum_{k<r}c_k\sigma_a(r-k)$. Cost: $O(N\log N)$
integer operations for the divisor sums and $O(N^2)$ for the convolution; integer
sizes grow like the coefficients themselves. Correctness is Theorem 6.3, and
integrality of each $c_r$ is automatic since the product has integer coefficients.

**B. Head-coefficient evaluation.** *Input:* frame shape $a$. *Output:* $c_g(1)$,
$c_g(2)$, $c_g(3)$ by the closed formulas of Theorem 5.4, Theorem 5.6 and Corollary
6.4. Cost: $O(1)$ divisor sums, hence essentially constant time. The value of the
closed formulas over Algorithm A is that they exhibit the coefficients as *polynomials
in the frame-shape data*, from which structural facts such as Theorem 7.5 follow.

**C. Head of a product from a table.** *Input:* an integral head table
$\bigl(c_i(n)\bigr)_{i \le m,\, n \le 3}$. *Output:* the Laurent coefficients of
$\prod_i T_i$ in degrees $-m, \dots, 4-m$. Return
$1$, $0$, $\sum_i c_i(1)$, $\sum_i c_i(2)$, $\sum_i c_i(3) + \frac12\bigl((\sum_i
c_i(1))^2 - \sum_i c_i(1)^2\bigr)$. Cost: $O(m)$ — *linear in the number of factors*,
versus the exponential-looking cross-term expansion a naive product would generate.
This is the algorithmic content of Theorems 4.3 and 4.4.

---

## 9. Discussion

### 9.1 What the collapse means

The additivity theorem is best read as a statement about the localization of
information in a product. Two power series that agree with $1$ to depth $d$ cannot
influence one another below degree $2d$: their interaction requires each to spend at
least $d$ units of degree. In the range where independence holds, the coefficient of
a product of arbitrarily many factors is simply the sum of individual contributions,
and this holds over any commutative ring with no constraint on the number of factors.
The failure at $k = 2d$ is not gradual; it is the sudden appearance of exactly one new
symmetric function.

For the Monster this places a hard limit on what the head of $\prod_g T_g$ can know:
three integer sums, then one sum of squares, and so on. Deep moonshine — the
representation-theoretic content of the individual $c_g(n)$ — is simply not visible
near the top of the product. Conversely, the arithmetic that *is* visible is visible
completely.

### 9.2 Analytic statements that are secretly finite

Corollary 4.6 is a template. A statement of the form "the $k$-th Laurent coefficient
of an explicitly-normalized product of modular functions equals $N$" looks analytic
and is, in the stable range, arithmetic. The reduction is exact rather than
approximate, so the resulting statement can be settled by inspection of a table, with
none of the truncation-error reasoning that accompanies numerical verification of
$q$-expansions.

### 9.3 Frame shapes as generators of tables

Section 5 removes the tabular character of the head data for eta-quotient classes: the
numbers $c_g(1)$, $c_g(2)$, $c_g(3)$ are polynomial functions of the frame-shape
exponents. Combined with the recursion of Section 6, *every* coefficient of such a
class is a polynomial in the divisor sums $b_1, \dots, b_r$. The eight-shape family
$1^{-e}n^{e}$ makes this concrete: eight pairs $(n,e)$ generate the entire head block
of the table used in Theorem 7.3.

### 9.4 Limitations

Three should be stated plainly. First, the reduction of Section 4 uses only the
normalization $T_g = q^{-1} + O(q)$; it applies to any family of such series and does
not, by itself, use or prove anything specific to the Monster. Second, the closed
formulas of Section 5 apply to those classes whose McKay–Thompson series is an eta
quotient up to an additive constant; other classes require their coefficients as
input. Third, the stable range genuinely ends at degree $2d$: coefficients deeper in
the expansion require the elementary symmetric corrections of Remark 3.9, and the
number of columns of the table needed grows linearly with the degree.

---

## 10. Future directions

**C1. Universal polynomials, weighted homogeneity, and integrality.** The recursion
$r c_r = \sum_{k<r}c_k\sigma_a(r-k)$ with $\sigma_a(r) = \sum_{d\mid r}d\,b_d$ holds
over an arbitrary commutative ring, and all coefficients are truncation-stable. The
remaining conjecture is that for each $r \ge 1$ the recursion's solution is a
*universal* polynomial $P_r \in \mathbb{Q}[y_1,\dots,y_r]$, independent of the frame
shape, with $c_r = P_r(b_1,\dots,b_r)$; that $P_r$ is homogeneous of weighted degree
$r$ when $y_m$ has weight $m$, with leading term $y_1^r/r!$; and that $r!\,P_r$ has
integer coefficients, so the denominators are exactly the factorials — no worse. The
key insight is that the recursion is a triangular linear system whose only divisions
are by $1,2,\dots,r$, and each $\sigma_a(j)$ is itself linear in the $b$'s of weight
$j$, so weighted homogeneity propagates upward and the denominator can grow only by a
factor $r$ per step. The degree-$4$ formula already exhibits denominator exactly
$24 = 4!$; what remains is to run the induction with $P_r$ as data rather than to
compute each degree by hand.

**C2. Exact determination of the stable range.** For power series congruent to $1$
modulo $q^d$, the coefficient of the product in degree $k$ should be a polynomial in
the individual coefficients involving *exactly* the elementary symmetric functions
$e_1,\dots,e_{\lfloor k/d\rfloor}$; in particular additivity holds if and only if
$k < 2d$, and for $jd \le k < (j+1)d$ the correction involves $e_j$ and no higher
symmetric function. The key insight is that a factor contributes to degree $k$ only
through its degrees $\ge d$, so the number of simultaneously active factors is bounded
by $k/d$: the combinatorics is that of partitions of $k$ into parts $\ge d$, not of
all partitions. The two extreme cases are already established here — additivity
($j=1$) and the boundary correction $e_2$ ($j=2$) — along with sharpness.

**C3. Completing the $194$-entry table.** The reduction makes the head identity a
finite arithmetic statement; entering all $194$ head coefficients discharges it
outright. For classes outside the eta-quotient family the coefficients must come from
elsewhere, and a uniform frame-shape-style generator for the remaining classes would
complete the programme.

**C4. Positivity beyond the sample family.** The uniform bound $c_g(1) \ge -1$ was
proved for the family $1^{-e}n^{e}$ directly from the closed formula. Whether an
analogous bound, or a monotonicity statement, holds for all balanced frame shapes —
and whether the bound $-1$ persists — is open and directly attackable with the closed
formula in hand.

**C5. Higher heads of the Monster product.** With the $e_2$ correction available, the
coefficient in degree $-190$ is determined by $\sum_g c_g(3)$, $\sum_g c_g(1)$ and
$\sum_g c_g(1)^2$. Establishing the $e_3$ correction at degree $6$ would give degree
$-189$ in terms of four columns, and iterating would produce a complete, finitely
generated description of the head of $\prod_g T_g$ to any fixed depth.

---

## Appendix: worked numerical checks

All numbers below are exact.

**A.1. Stable range in action.** Take $d = 3$ and the three series
$1 + 2q^3 - q^4 + 5q^5 + 3q^6 + q^8$, $1 - 4q^3 + 7q^4 + 2q^6 + q^7$, and
$1 + 11q^3 - 2q^5 + 4q^7 + 6q^8$. Their product has coefficients $9, 6, 3$ in degrees
$3, 4, 5$ — exactly the sums $2-4+11$, $-1+7+0$, $5+0-2$. In degree $6$ additivity
fails: the product has $-25$ while the sum is $5$; the difference $-30$ is precisely
$e_2(2,-4,11) = 2\cdot(-4) + 2\cdot 11 + (-4)\cdot 11 = -30$.

**A.2. Sharpness.** $(1+q^2)^2 = 1 + 2q^2 + q^4$: degree-$4$ coefficient $1$, sum of
individual degree-$4$ coefficients $0$.

**A.3. The eight-fold product.** With the columns of Section 7,
$$q^{-8} + 0\,q^{-7} + 359\,q^{-6} - 2099\,q^{-5} + 35514\,q^{-4} - 232252\,q^{-3}
+ \cdots,$$
the first five coefficients being exactly those predicted by Theorems 4.3 and 4.4;
the sixth lies beyond the reach of the corrections established here.

**A.4. A $194$-row check.** For any integral table with $c_g(0) = 0$, expanding the
$194$-fold product directly and reading off the coefficient in degree $-192$ returns
the integer $\sum_g c_g(1)$ — the reduction verified against brute-force
multiplication.
