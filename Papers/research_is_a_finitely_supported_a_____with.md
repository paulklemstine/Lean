# The Head Coefficient of a Normalised Eta Quotient: Jet Calculus, a Heisenberg Cocycle, and a Divisor-Sum Recursion

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

Let $a=(a_k)_{k\ge1}$ be a finitely supported sequence of integers and let
$\eta_a(\tau)=\prod_{k\ge1}\eta(k\tau)^{a_k}$ be the associated eta quotient,
where $\eta$ is the Dedekind eta function. When the exponent vector is
*admissible*, i.e. $\sum_k k\,a_k=24$, the quotient has the normal form
$\eta_a = q\prod_{m\ge1}(1-q^m)^{b_m}$ with $b_m=\sum_{k\mid m}a_k$, so that
$1/\eta_a = q^{-1}+c(0)+c(1)q+\cdots$ is a Hauptmodul-shaped expansion. We prove
a closed formula for the *head coefficient*:
$$c(1)=\frac{a_1(a_1+3)}{2}+a_2,$$
valid for every truncation of the defining product of length at least $2$, hence
for the infinite product. We prove the companion formulas $c(-1)=1$, $c(0)=a_1$
and, one degree further,
$c(2)=\tfrac{1}{6}a_1(a_1+1)(a_1+2)+a_1(a_1+a_2)+a_1+a_3$.

Three structural theorems accompany the computation. First, a **stability
theorem**: the coefficient of $q^n$ is independent of the truncation length once
that length is at least $n$, so the infinite product is coefficientwise
well defined. Second, a **Heisenberg cocycle**: the head coefficient is not
additive in $a$, but satisfies $c(1)(a+a')=c(1)(a)+c(1)(a')+a_1a_1'$, and the
matrix $M(a)=\begin{pmatrix}1&a_1&c(1)\\0&1&a_1\\0&0&1\end{pmatrix}$ defines a
group homomorphism from exponent vectors to the discrete Heisenberg group.
Third, a **logarithmic-derivative recursion** valid in *every* degree:
writing $F_a=q/\eta_a=\sum_{n\ge0}A_nq^n$ and $\sigma_b(j)=\sum_{m\mid j}m\,b_m$,
$$n\,A_n=\sum_{i<n}A_i\,\sigma_b(n-i),\qquad A_0=1 .$$

From the recursion we deduce two infinite-degree results inaccessible to
finite jet computation: **positivity** ($b\ge0$ and $b_1\ge1$ imply $A_n\ge1$
for all $n$, in particular for $q/\Delta$, recovering positivity of
$1,24,324,3200,25650,\dots$), and a **congruence** ($d\mid b_m$ for all $m$ and
$\gcd(d,n)=1$ imply $d\mid A_n$; for $q/\Delta$, $24\mid A_n$ whenever
$\gcd(n,24)=1$, with $A_2=324$ showing the coprimality hypothesis is
irremovable). We characterise the achievable head coefficients arithmetically:
for pure powers ($a_2=0$) the attainable values are exactly the $c$ with $8c+9$
a perfect square, they are bounded below by $-1$, and they are subject to the
reflection symmetry $a_1\mapsto -3-a_1$; allowing $a_2\ne0$ the head coefficient
map is surjective onto $\mathbb{Z}$ even when restricted to admissible vectors.
Finally we place the whole picture inside a two-layer invariant tower whose base
is a tropical valuation layer, and show the base layer is strictly coarser:
the tropicalised $q$-adic order of $F_a$ is the tropical unit for every $a$, so
it cannot distinguish exponent vectors whose head coefficients differ by $324$.

**Keywords:** Dedekind eta function, eta quotient, Hauptmodul, jet calculus,
Heisenberg group, twisted divisor sums, logarithmic derivative, congruences,
tropical valuation.

---

## 1. Introduction

### 1.1 The objects

Dedekind's eta function is the infinite product

$$\eta(\tau)\;=\;q^{1/24}\prod_{n\ge1}(1-q^n),\qquad q=e^{2\pi i\tau},\ \ \Im\tau>0 .$$

An **eta quotient** is a finite product of rescaled eta functions with integer
exponents,

$$\eta_a(\tau)\;=\;\prod_{k\ge1}\eta(k\tau)^{a_k},$$

where $a:\mathbb{N}\to\mathbb{Z}$ is finitely supported. Eta quotients are the
most explicitly computable family of modular forms: they include the modular
discriminant $\Delta=\eta^{24}$, the generating function of partitions
$\eta^{-1}$ up to a $q$-power, and weight-two newforms of small level.

Collecting the fractional $q$-powers, the leading behaviour of $\eta_a$ is
$q^{w(a)/24}$ where $w(a)=\sum_k k\,a_k$. We call $a$ **admissible** when
$w(a)=24$; the leading term is then exactly $q$, all fractional exponents cancel,
and

$$\eta_a(\tau)\;=\;q\prod_{m\ge1}(1-q^m)^{b_m},\qquad
\boxed{\,b_m=\sum_{k\mid m}a_k\,}\tag{1.1}$$

The exponent regrouping (1.1) — each factor $\eta(k\tau)$ contributing
$(1-q^{kn})$ for all $n\ge1$, so that the total exponent of $(1-q^m)$ is the sum
of $a_k$ over divisors $k$ of $m$ — converts the arithmetic of eta quotients into
the arithmetic of divisor sums, and is used throughout.

Inverting, and multiplying by $q$ to clear the pole, we obtain the central object
of this paper:

$$F_a(q)\;:=\;\frac{q}{\eta_a}\;=\;\prod_{m\ge1}(1-q^m)^{-b_m}\;=\;\sum_{n\ge0}A_n\,q^n
\;\in\;\mathbb{Z}[\![q]\!]^\times. \tag{1.2}$$

The two indexings are related by $A_n=c(n-1)$, where the $c(\cdot)$ are the
coefficients in the *Hauptmodul normal form*

$$\frac{1}{\eta_a}\;=\;q^{-1}+c(0)+c(1)\,q+c(2)\,q^2+\cdots \tag{1.3}$$

This is the shape in which McKay–Thompson series and genus-zero Hauptmoduln are
customarily written, and $c(1)=A_2$ — the coefficient of $q^2$ in $F_a$ — is the
first coefficient not fixed by the normalisation. We call it the **head
coefficient** of $a$ and write $\mathrm{hc}(a)$.

### 1.2 Statement of the main results

Throughout, $F_a^{(N)}=\prod_{m=1}^{N}(1-q^m)^{-b_m}$ denotes the truncated
product, a unit of $\mathbb{Z}[\![q]\!]$.

**Theorem A (Head coefficient).** For every finitely supported
$a:\mathbb{N}\to\mathbb{Z}$ and every $N\ge2$, the coefficient of $q^2$ in
$F_a^{(N)}$ equals
$$\mathrm{hc}(a)\;=\;\frac{a_1(a_1+3)}{2}+a_2 ,$$
independently of $N$. Moreover the coefficient of $q$ is $a_1$ and the constant
coefficient is $1$; in the normal form (1.3), $c(-1)=1$, $c(0)=a_1$,
$c(1)=\mathrm{hc}(a)$.

**Theorem B (Second coefficient).** For every $N\ge3$, the coefficient of $q^3$
in $F_a^{(N)}$ is
$$c(2)\;=\;\frac{a_1(a_1+1)(a_1+2)}{6}+a_1(a_1+a_2)+a_1+a_3 .$$

**Theorem C (Stability).** For $n\le N$ and $n\le M$, the coefficient of $q^n$ in
$F_a^{(N)}$ equals that in $F_a^{(M)}$. Consequently $A_n$ is well defined by any
truncation of length $\ge n$, and Theorems A and B are statements about the
infinite product (1.2).

**Theorem D (Heisenberg cocycle and matrix bridge).**
$F_{a+a'}=F_a\,F_{a'}$, and
$$\mathrm{hc}(a+a')=\mathrm{hc}(a)+\mathrm{hc}(a')+a_1a_1' .$$
The assignment
$M(a)=\begin{pmatrix}1&a_1&\mathrm{hc}(a)\\0&1&a_1\\0&0&1\end{pmatrix}$
satisfies $M(a+a')=M(a)M(a')$ and $\det M(a)=1$; it is a homomorphism from the
additive group of exponent vectors to the discrete Heisenberg group
$H_3(\mathbb{Z})\le \mathrm{SL}_3(\mathbb{Z})$.

**Theorem E (Recursion in all degrees).** Let
$\sigma_b(j)=\sum_{m\mid j,\ m\le N}m\,b_m$. Then $A_0=1$ and, for all $n\ge1$,
$$n\,A_n=\sum_{i=0}^{n-1}A_i\,\sigma_b(n-i).$$
The structure constants are additive in the exponent vector:
$\sigma_{b(a+a')}(j)=\sigma_{b(a)}(j)+\sigma_{b(a')}(j)$. For $j\le N$,
$\sigma_b(j)$ is the full divisor sum $\sum_{m\mid j}m\,b_m$ and hence
independent of the truncation.

**Theorem F (Positivity).** If $b_m\ge0$ for all $1\le m\le N$ then $A_n\ge0$ for
all $n$. If moreover $b_1\ge1$ then $A_n\ge1$ for all $n$. In particular all
coefficients of $q/\Delta=\prod_m(1-q^m)^{-24}$, namely
$1,24,324,3200,25650,176256,\dots$, are $\ge1$.

**Theorem G (Congruence).** If $d\mid b_m$ for all $1\le m\le N$ then
$d\mid n\,A_n$ for all $n\ge1$; if moreover $\gcd(d,n)=1$ then $d\mid A_n$. For
$q/\Delta$: $24\mid A_n$ whenever $\gcd(n,24)=1$, and combining with Theorem F,
$A_n\ge24$ for such $n$. The coprimality hypothesis cannot be removed:
$A_2=324$ and $24\nmid324$.

**Theorem H (Arithmetic of the head coefficient).** For pure exponent vectors
($a_2=0$), an integer $c$ is a head coefficient if and only if $8c+9$ is a
perfect square; the value $c=1$ is not attained; $c\ge-1$ always, with equality
exactly at $a_1\in\{-1,-2\}$; and $\mathrm{hc}$ takes the same value at $a_1$
and $a_1'$ precisely when $a_1'=a_1$ or $a_1'=-3-a_1$. Allowing $a_2\ne0$, every
integer $c$ is the head coefficient of an **admissible** exponent vector, e.g.
$a_2=c,\ a_3=2c-24,\ a_4=24-2c$.

**Theorem I (Tropical layer and its incompleteness).** The tropicalised $q$-adic
order $T(f)=\mathrm{trop}(\mathrm{ord}\,f)$ satisfies $T(fg)=T(f)\otimes T(g)$
and $T(f)\oplus T(g)\le T(f+g)$ in the tropical semiring. For every $a$ and
every $N\ge2$, $T(F_a^{(N)})$ is the tropical unit. Consequently $T$ is blind to
the head coefficient: there exist $a,a'$ with $T(F_a)=T(F_{a'})$ but
$\mathrm{hc}(a)-\mathrm{hc}(a')=324$.

### 1.3 Organisation

Section 2 sets up the jet calculus and proves Theorems A and B. Section 3 proves
stability (Theorem C) and the divisor regrouping in low degree. Section 4 proves
the cocycle and the Heisenberg bridge (Theorem D). Section 5 develops the
logarithmic derivative and proves Theorem E, together with an independent
re-derivation of Theorem A. Section 6 derives positivity and congruences
(Theorems F and G). Section 7 treats the Diophantine questions (Theorem H).
Section 8 treats the tropical layer (Theorem I). Section 9 gives algorithms.
Section 10 discusses applications and future directions.

---

## 2. Jet calculus and the head coefficient

### 2.1 Two-jets

Work in $\mathbb{Z}[\![X]\!]$ and write $[X^n]f$ for the coefficient of $X^n$.

**Definition 2.1.** For $f\in\mathbb{Z}[\![X]\!]$ and $c_1,c_2\in\mathbb{Z}$, say
$f$ has **jet** $(c_1,c_2)$, written $J(f)=(c_1,c_2)$, if
$$[X^0]f=1,\qquad [X^1]f=c_1,\qquad [X^2]f=c_2 ,$$
i.e. $f=1+c_1X+c_2X^2+O(X^3)$.

The set of series with a jet is exactly the set of units of
$\mathbb{Z}[\![X]\!]$ with constant term $1$, and the jet is a homomorphism onto
a two-step nilpotent group, as the next lemma records.

**Lemma 2.2 (Jet group law).** If $J(f)=(c_1,c_2)$ and $J(g)=(d_1,d_2)$, then
$$J(fg)=(c_1+d_1,\ c_2+c_1d_1+d_2).$$

*Proof.* Convolution: $[X^1](fg)=[X^0]f\,[X^1]g+[X^1]f\,[X^0]g$ and
$[X^2](fg)=[X^0]f\,[X^2]g+[X^1]f\,[X^1]g+[X^2]f\,[X^0]g$; substitute the jets. $\square$

**Lemma 2.3 (Inversion).** If $u$ is a unit with $J(u)=(c_1,c_2)$, then
$J(u^{-1})=(-c_1,\ c_1^2-c_2)$.

*Proof.* Apply Lemma 2.2 to $u\,u^{-1}=1$, whose jet is $(0,0)$, and solve for the
jet of $u^{-1}$ degree by degree. $\square$

**Lemma 2.4 (Integer powers).** If $J(u)=(c_1,c_2)$ then for every $n\in\mathbb{Z}$,
$$J(u^{n})=\Bigl(n\,c_1,\ \ n\,c_2+\binom{n}{2}c_1^{2}\Bigr),$$
where $\binom{n}{2}=\tfrac{n(n-1)}{2}$ is the triangular number extended to all
integers.

*Proof.* Induct in both directions from $n=0$. The step $n\to n+1$ uses Lemma 2.2
and $\binom{n+1}{2}=\binom{n}{2}+n$; the step $n\to n-1$ uses Lemma 2.3 and
$\binom{n-1}{2}=\binom{n}{2}-(n-1)$. $\square$

Lemma 2.4 is the engine. The appearance of $\binom{n}{2}$ is the degree-two
truncation of $\exp(n\log u)$, and it is the ultimate source of the quadratic
term in Theorem A.

Two auxiliary facts are needed: a product of series each with jet $(0,0)$ has jet
$(0,0)$, and multiplying by a series with jet $(0,0)$ does not change a jet.
Both follow immediately from Lemma 2.2.

### 2.2 The basic factors

For $m\ge1$ the series $1-X^m$ is a unit (its constant term is $1$). Its jets are
$$J(1-X)=(-1,0),\qquad J(1-X^2)=(0,-1),\qquad J(1-X^m)=(0,0)\ \ (m\ge3),$$
since $1-X^m$ differs from $1$ only in degree $m$.

### 2.3 Proof of Theorem A

Set $b_m=\sum_{k\mid m}a_k$; in particular $b_1=a_1$ and $b_2=a_1+a_2$.
Let $F^{(N)}=\prod_{m=1}^{N}(1-X^m)^{-b_m}$.

Induct on $N\ge2$.

*Base $N=2$.* By Lemma 2.4,
$J\bigl((1-X)^{-b_1}\bigr)=\bigl(b_1,\ \binom{-b_1}{2}\bigr)=\bigl(a_1,\ \tfrac{a_1(a_1+1)}{2}\bigr)$
(using $\binom{-b}{2}=\tfrac{b(b+1)}{2}$), and
$J\bigl((1-X^2)^{-b_2}\bigr)=(0,\ b_2)=(0,\ a_1+a_2)$. Multiplying by Lemma 2.2:
$$J(F^{(2)})=\Bigl(a_1,\ \tfrac{a_1(a_1+1)}{2}+a_1\cdot0+a_1+a_2\Bigr)
=\Bigl(a_1,\ \tfrac{a_1(a_1+3)}{2}+a_2\Bigr),$$
since $\tfrac{a_1(a_1+1)}{2}+a_1=\tfrac{a_1(a_1+3)}{2}$.

*Step.* For $N\ge2$, the new factor $(1-X^{N+1})^{-b_{N+1}}$ has jet $(0,0)$ by
Lemma 2.4 applied to $J(1-X^{N+1})=(0,0)$ (as $N+1\ge3$), so multiplying by it
leaves the jet unchanged. $\square$

Note the mechanism: the head coefficient is a sum of two contributions of
different natures — a *quadratic* contribution $\binom{-b_1}{2}+b_1$ from the
single factor $(1-X)^{-b_1}$, and a *linear* contribution $b_2$ from
$(1-X^2)^{-b_2}$. The divisor regrouping turns these into the stated polynomial
in $a_1, a_2$.

An immediate check: $a=24\delta_1$ (i.e. $\Delta=\eta^{24}$) gives
$\mathrm{hc}=24\cdot27/2=324$, and $\Delta$'s exponent vector is admissible
($1\cdot24=24$). Similarly $a=12\delta_2$ ($\eta(2\tau)^{12}$, weight
$2\cdot12=24$, admissible) gives $\mathrm{hc}=0+12=12$.

### 2.4 Three-jets and Theorem B

Extend Definition 2.1 by also recording $[X^3]f=c_3$. The corresponding power law
is
$$J_3(u^n)=\Bigl(n c_1,\ nc_2+\binom{n}{2}c_1^2,\ \ nc_3+n(n-1)c_1c_2+\binom{n}{3}c_1^3\Bigr),$$
with $\binom{n}{3}=\tfrac{n(n-1)(n-2)}{6}$ the tetrahedral number extended to
$\mathbb{Z}$. Running the same induction with the four relevant jets
$J_3(1-X)=(-1,0,0)$, $J_3(1-X^2)=(0,-1,0)$, $J_3(1-X^3)=(0,0,-1)$,
$J_3(1-X^m)=(0,0,0)$ for $m\ge4$, and $b_3=a_1+a_3$, yields Theorem B:
$$c(2)=-\binom{-a_1}{3}+\text{(cross terms)}
=\frac{a_1(a_1+1)(a_1+2)}{6}+a_1(a_1+a_2)+a_1+a_3 .$$
The identity $-\binom{-b}{3}=\tfrac{b(b+1)(b+2)}{6}$ is the degree-three analogue
of $\binom{-b}{2}=\tfrac{b(b+1)}{2}$. For $a=24\delta_1$ the formula returns
$2600+576+24=3200$, in agreement with
$1/\Delta=q^{-1}+24+324q+3200q^2+\cdots$.

The shape of the two formulas already suggests the general pattern: in degree
$n$, $c(n-1)$ is a polynomial of weighted degree $n$ in $a_1,\dots,a_n$ for the
weighting $\mathrm{wt}(a_k)=k$, whose top part is the binomial
$\binom{-a_1}{n}$ up to sign and whose bottom part is the linear term $a_n$.

---

## 3. Stability of the truncation

The jet arguments are stated for finite products; Theorem C is what makes them
theorems about the infinite product (1.2).

**Definition 3.1.** For $k\ge0$ say $f\equiv1 \pmod{X^k}$ if $X^k\mid f-1$.

**Lemma 3.2.** The relation of Definition 3.1 is stable under products, under
inversion of units, under integer powers of units, and it weakens under
decreasing $k$.

*Proof.* For products, $fg-1=(f-1)g+(g-1)$. For inverses,
$u^{-1}-1=u^{-1}(1-u)$. Integer powers follow by induction from these two.
Weakening is $X^{k}\mid X^{l}$ for $k\le l$. $\square$

**Lemma 3.3.** $1-X^m\equiv 1\pmod{X^m}$; and if $g\equiv1\pmod{X^{k}}$ then
$[X^n](fg)=[X^n]f$ for all $n<k$.

*Proof.* The first is immediate. For the second, $fg-f=f(g-1)$ is divisible by
$X^{k}$, so its coefficients vanish below degree $k$. $\square$

*Proof of Theorem C.* For $N\le M$ write
$F^{(M)}=F^{(N)}\cdot\prod_{m=N+1}^{M}(1-X^m)^{-b_m}$. By Lemmas 3.2 and 3.3,
each factor of the tail is $\equiv1\pmod{X^{N+1}}$, hence so is the tail, hence
the coefficients of $F^{(M)}$ and $F^{(N)}$ agree in all degrees $\le N$. For
general $N,M\ge n$ compare both to $F^{(\max(N,M))}$. $\square$

Consequently the definition $A_n:=[X^n]F^{(n)}$ is legitimate and computed by any
truncation of length $\ge n$; one recovers $A_0=1$, $A_1=a_1$,
$A_2=\mathrm{hc}(a)$ for the infinite product.

### 3.1 Divisor regrouping in low degree

Identity (1.1) is a rearrangement of a doubly infinite product and is used to
identify $\prod_m(1-q^m)^{-b_m}$ with $q/\eta_a$. In the degrees relevant to the
head coefficient it can be verified directly, and we record this as a
consistency check on the whole normalisation. Set
$P_a^{(N)}=\prod_{k=1}^{N}\bigl(\prod_{n=1}^{N}(1-X^{kn})\bigr)^{a_k}$ (the
truncated eta product without the $q$-normalisation) and
$D_a^{(N)}=\prod_{m=1}^{N}(1-X^m)^{b_m}$ (its divisor-sum form).

**Proposition 3.4.** For $N\ge2$,
$$J\bigl(P_a^{(N)}\bigr)=J\bigl(D_a^{(N)}\bigr)=\Bigl(-a_1,\ \tfrac{a_1(a_1-1)}{2}-a_1-a_2\Bigr),$$
and consequently $J\bigl(P_a^{(N)}\cdot F_a^{(N)}\bigr)=(0,0)$: the product
$(\eta_a/q)\cdot(q/\eta_a)$ is $1$ to the accuracy at which the head coefficient
is computed.

*Proof.* Both sides are computed by the same jet calculus. For $P$: the factor
with $k=1$ is $\prod_n(1-X^n)$ with jet $(-1,-1)$, raised to $a_1$; the factor
with $k=2$ is $\prod_n(1-X^{2n})$ with jet $(0,-1)$, raised to $a_2$; factors
with $k\ge3$ have jet $(0,0)$. For $D$: use $b_1=a_1$, $b_2=a_1+a_2$ and the jets
of §2.2. Both computations give the displayed pair. The final claim follows from
Lemma 2.2 and Theorem A. $\square$

---

## 4. The Heisenberg cocycle

**Proposition 4.1 (Multiplicativity).** $b_\bullet$ is additive in $a$, hence
$F_{a+a'}^{(N)}=F_a^{(N)}F_{a'}^{(N)}$ for all $N$.

*Proof.* $b_m(a+a')=\sum_{k\mid m}(a_k+a_k')=b_m(a)+b_m(a')$; then
$(1-X^m)^{-(b+b')}=(1-X^m)^{-b}(1-X^m)^{-b'}$ factorwise. $\square$

*Proof of Theorem D.* Multiplicativity is Proposition 4.1. For the cocycle,
apply Theorem A three times and expand:
$$\frac{(a_1+a_1')(a_1+a_1'+3)}{2}+(a_2+a_2')
=\frac{a_1(a_1+3)}{2}+a_2+\frac{a_1'(a_1'+3)}{2}+a_2'+a_1a_1'.$$
(All divisions by $2$ are exact because $n(n+3)$ is always even.) Equivalently,
this is Lemma 2.2 read off in degree $2$: with $c_1=a_1$, $d_1=a_1'$, the
cross-term $c_1d_1$ *is* the cocycle. For the matrix statement, multiply
$$\begin{pmatrix}1&a_1&h\\0&1&a_1\\0&0&1\end{pmatrix}
\begin{pmatrix}1&a_1'&h'\\0&1&a_1'\\0&0&1\end{pmatrix}
=\begin{pmatrix}1&a_1+a_1'&h+h'+a_1a_1'\\0&1&a_1+a_1'\\0&0&1\end{pmatrix},$$
which is $M(a+a')$ precisely because of the cocycle identity. The determinant of
a unipotent upper-triangular matrix is $1$. $\square$

**Remark 4.2.** The two invariants $c(0)=a_1$ and $c(1)=\mathrm{hc}(a)$ therefore
sit in a two-step tower: the first is a homomorphism to $(\mathbb{Z},+)$, the
second is a homomorphism only modulo the commutator, and the obstruction is the
symmetric form $(a,a')\mapsto a_1a_1'$. The centre of $H_3(\mathbb{Z})$ — the
upper right corner — is exactly where the head coefficient lives, and the image
of $a\mapsto M(a)$ is a subgroup of $H_3(\mathbb{Z})$ whose commutator subgroup
is generated by the values of that form. This is the smallest non-abelian
phenomenon that a $q$-expansion can exhibit, and Theorem A says the eta quotients
realise it explicitly.

---

## 5. The logarithmic-derivative recursion

Jet calculus is degree-by-degree: computing $c(3)$ requires a fresh four-jet
formalism, $c(4)$ a five-jet formalism, and so on. This section replaces it by a
single uniform statement.

### 5.1 The Euler operator

Write $D=\frac{d}{dX}$ for the formal derivative and, for a unit $u$,
$$L(u)\;:=\;X\,\frac{D u}{u}\;=\;X\,(Du)\,u^{-1}.$$
This is the Euler operator $q\,\frac{d}{dq}$ applied to $\log u$; the factor $X$
is what converts products of $(1-X^m)$ into divisor sums.

**Lemma 5.1.** $L(1)=0$, $L(uv)=L(u)+L(v)$, $L(u^{-1})=-L(u)$,
$L(u^{n})=n\,L(u)$ for $n\in\mathbb{Z}$, and $L(\prod_i u_i)=\sum_i L(u_i)$.

*Proof.* The product rule $D(uv)=u\,Dv+v\,Du$ divided by $uv$; the rest follows
formally. $\square$

**Lemma 5.2.** For $m\ge1$, $L(1-X^m)=-m\,\dfrac{X^m}{1-X^m}$, and
$\dfrac{X^m}{1-X^m}=\sum_{j\ge1}[m\mid j]\,X^j$.

*Proof.* $D(1-X^m)=-mX^{m-1}$, so $L(1-X^m)=-mX^{m}(1-X^m)^{-1}$. The
geometric expansion of $(1-X^m)^{-1}=\sum_{k\ge0}X^{mk}$ is verified by
multiplying out. $\square$

**Proposition 5.3.** With $F=F_a^{(N)}$,
$$L(F)\;=\;\sum_{m=1}^{N}m\,b_m\,\frac{X^m}{1-X^m},
\qquad [X^j]L(F)=\sigma_b(j):=\sum_{\substack{m\mid j\\ m\le N}}m\,b_m\quad (j\ge1),$$
and $[X^0]L(F)=0$.

*Proof.* Lemma 5.1 turns the product into a sum of $-b_m\,L(1-X^m)$, and Lemma
5.2 evaluates each term; the $j$-th coefficient picks out the divisors of $j$. $\square$

The quantity $\sigma_b(j)$ is a **twisted divisor sum**: for $b\equiv1$ it is the
classical $\sigma_1(j)$, and for $q/\Delta$ (where $b_m=24$ for all $m$) it is
$24\,\sigma_1(j)$.

### 5.2 Proof of Theorem E

Multiply the definition of $L$ by $F$:
$$F\cdot L(F)=X\,DF .$$
Take the coefficient of $X^{n}$ with $n\ge1$. On the right,
$[X^n](X\,DF)=[X^{n-1}]DF=n\,A_n$. On the left, convolution gives
$\sum_{i=0}^{n}A_i\,[X^{n-i}]L(F)$; the term $i=n$ vanishes because
$[X^0]L(F)=0$, and the remaining terms are $A_i\,\sigma_b(n-i)$ by
Proposition 5.3. Hence $nA_n=\sum_{i<n}A_i\sigma_b(n-i)$, with $A_0=1$ because
the constant-term map is a ring homomorphism and each factor
$(1-X^m)^{-b_m}$ has constant term $1$. Additivity of $\sigma_b$ in $a$ is
immediate from additivity of $b$. Independence of $N$ for $j\le N$ holds because
every divisor $m$ of $j$ satisfies $m\le j\le N$, so the truncation removes
nothing. $\square$

### 5.3 An independent derivation of Theorem A

The recursion re-proves the head coefficient formula by a route sharing no lemma
with §2. One computes $\sigma_b(1)=b_1=a_1$ and
$\sigma_b(2)=b_1+2b_2=a_1+2(a_1+a_2)=3a_1+2a_2$. Then:

- $n=1$: $1\cdot A_1=A_0\sigma_b(1)=a_1$, so $A_1=a_1$, i.e. $c(0)=a_1$.
- $n=2$: $2A_2=A_0\sigma_b(2)+A_1\sigma_b(1)=(3a_1+2a_2)+a_1^2$, so
  $A_2=\tfrac{a_1^2+3a_1}{2}+a_2=\tfrac{a_1(a_1+3)}{2}+a_2$.

The agreement of two structurally unrelated derivations is a strong consistency
check on both the formula and the normalisation. Specialising $a=24\delta_1$ once
more recovers $c(1)=324$.

---

## 6. Positivity and congruences: two infinite-degree theorems

The value of Theorem E is that it says something in *every* degree at once. Both
theorems in this section are of that kind and neither can be obtained from any
finite jet computation.

### 6.1 Positivity

**Lemma 6.1.** If $b_m\ge0$ for $1\le m\le N$, then $\sigma_b(j)\ge0$ for all
$j$; and since $m=1$ always divides $j$, $\sigma_b(j)\ge b_1$.

*Proof.* Each summand $m\,b_m$ is a product of nonnegatives; isolating the
$m=1$ term leaves a nonnegative remainder. $\square$

*Proof of Theorem F.* Strong induction on $n$. $A_0=1\ge0$. For $n\ge1$,
$nA_n=\sum_{i<n}A_i\sigma_b(n-i)$ is a sum of products of nonnegative numbers by
the inductive hypothesis and Lemma 6.1; dividing by $n>0$ gives $A_n\ge0$.

For the strict statement, assume additionally $b_1\ge1$. Then each of the $n$
summands satisfies $A_i\sigma_b(n-i)\ge1\cdot b_1\ge1$ by induction and Lemma
6.1, so $nA_n\ge n$, whence $A_n\ge1$.

For $q/\Delta$: $a=24\delta_1$ gives $b_m=\sum_{k\mid m}24\,[k=1]=24$ for every
$m\ge1$, so both hypotheses hold and every coefficient is $\ge1$. $\square$

Note the essential role of the divisor regrouping: the exponent vector of
$\Delta$ is supported at a single index, but the *divisor data* $b$ is the
constant sequence $24$. Positivity is a statement about $b$, not about $a$.

### 6.2 Congruences

**Lemma 6.2.** If $d\mid b_m$ for all $1\le m\le N$, then $d\mid\sigma_b(j)$ for
all $j$.

*Proof.* Each summand $m\,b_m$ is divisible by $d$. $\square$

*Proof of Theorem G.* By Theorem E, $nA_n=\sum_{i<n}A_i\sigma_b(n-i)$; every
summand is divisible by $d$ by Lemma 6.2, so $d\mid nA_n$. If $\gcd(d,n)=1$, then
$d$ and $n$ are coprime in $\mathbb{Z}$, so $d\mid A_n$.

For $q/\Delta$, $b_m=24$ for all $m$, so $d=24$ is admissible and $24\mid A_n$
whenever $\gcd(n,24)=1$. The sequence begins
$$A_0,\dots,A_7=1,\ 24,\ 324,\ 3200,\ 25650,\ 176256,\ 1073720,\ 5930496 .$$
Indeed $24\mid24$, $24\mid176256=24\cdot7344$, $24\mid5930496=24\cdot247104$
(the indices $1,5,7$ are coprime to $24$), whereas $324,3200,25650$ (indices
$2,3,4$) are not divisible by $24$. Hence the hypothesis $\gcd(n,24)=1$ is not
removable. $\square$

**Corollary 6.3 (Two-sided bound).** For $q/\Delta$ and every $n\ge1$ with
$\gcd(n,24)=1$: $A_n$ is a positive multiple of $24$, hence $A_n\ge24$.

*Proof.* Combine Theorems F and G: $A_n=24t$ with $A_n\ge1$ forces $t\ge1$. $\square$

Two remarks. First, the modulus $24$ here is the same $24$ as in the
admissibility condition $\sum_k ka_k=24$ and in the exponent of
$\Delta=\eta^{24}$ — but it enters through a completely different route, namely
as the constant value of the divisor data $b$. Second, the mechanism is entirely
general: any eta quotient whose divisor data share a common factor $d$ inherits
the congruence $d\mid A_n$ for $n$ coprime to $d$. This is a divisibility
phenomenon of moonshine flavour obtained with no modular input at all — only the
recursion.

---

## 7. Which integers are head coefficients?

Restrict first to *pure* vectors, $a_2=0$, so $\mathrm{hc}(a)=\tfrac{n(n+3)}{2}$
with $n=a_1$. This is the sequence
$\dots,\ 2,\ 0,\ -1,\ -1,\ 0,\ 2,\ 5,\ 9,\ 14,\dots$ for
$n=-4,-3,-2,-1,0,1,2,3,4$.

**Proposition 7.1 (Diophantine characterisation).** An integer $c$ satisfies
$c=\tfrac{n(n+3)}{2}$ for some $n\in\mathbb{Z}$ if and only if $8c+9$ is a
perfect square.

*Proof.* If $2c=n(n+3)$ then $8c+9=4n^2+12n+9=(2n+3)^2$. Conversely if
$s^2=8c+9$ then $s$ is odd (an even $s$ would force $8c+9$ even), say $s=2u+1$;
then $(u-1)(u+2)=2c$, and $n=u-1$ works. $\square$

**Corollary 7.2.** $c=1$ is not a pure head coefficient, since $8+9=17$ is not a
square.

**Proposition 7.3 (Reflection symmetry).** $\tfrac{n(n+3)}{2}=\tfrac{n'(n'+3)}{2}$
if and only if $n'=n$ or $n'=-3-n$.

*Proof.* Clearing denominators, $(n-n')(n+n'+3)=0$. $\square$

**Proposition 7.4 (Integrality rigidity).** $\tfrac{n(n+3)}{2}\ge-1$ for all
$n\in\mathbb{Z}$, with equality exactly at $n=-1$ and $n=-2$.

*Proof.* $(n+1)(n+2)\ge0$ for every integer $n$ (the two factors are consecutive
integers), so $n(n+3)=(n+1)(n+2)-2\ge-2$. Equality holds iff $(n+1)(n+2)=0$. $\square$

The real quadratic $x(x+3)/2$ attains $-9/8$ at $x=-3/2$; the integer minimum
$-1$ is strictly larger, and the gap $1/8$ is a small but genuine instance of
integrality rigidity.

**Theorem 7.5 (Surjectivity on admissible vectors).** For every $c\in\mathbb{Z}$
there is a finitely supported $a$ with $\sum_k k\,a_k=24$ and
$\mathrm{hc}(a)=c$.

*Proof.* Take $a_2=c$, $a_3=2c-24$, $a_4=24-2c$, all other $a_k=0$. Then
$\sum_k ka_k=2c+3(2c-24)+4(24-2c)=2c+6c-72+96-8c=24$, and since $a_1=0$,
$\mathrm{hc}(a)=0+a_2=c$. $\square$

So the arithmetic obstruction of Proposition 7.1 is a phenomenon of the
one-parameter slice $a_2=0$: the second exponent is a free additive dial and its
presence makes the head coefficient surjective, even under the admissibility
constraint. Concretely, $c=1$ is unattainable by pure powers but is attained by
$a=(0,1,-22,22,0,\dots)$.

---

## 8. The tropical layer

The **tropical semiring** on $\mathbb{N}\cup\{\infty\}$ has
$x\otimes y=x+y$ and $x\oplus y=\min(x,y)$, with multiplicative unit $0$ and
additive unit $\infty$. The $X$-adic order $\mathrm{ord}(f)$ (the index of the
first non-zero coefficient, $\infty$ for $f=0$) is a valuation and therefore
becomes a semiring-compatible map after tropicalisation. Write
$T(f)=\mathrm{trop}(\mathrm{ord} f)$.

**Proposition 8.1.** $T(fg)=T(f)\otimes T(g)$; $T(f)\oplus T(g)\le T(f+g)$;
$T(1)$ is the tropical unit; $T(0)$ is the tropical zero; $T(X^n)=\mathrm{trop}(n)$;
and $T(f^n)=T(f)^{\otimes n}$.

*Proof.* These are the standard valuation axioms
$\mathrm{ord}(fg)=\mathrm{ord}f+\mathrm{ord}g$ (valid because
$\mathbb{Z}[\![X]\!]$ is a domain) and
$\mathrm{ord}(f+g)\ge\min(\mathrm{ord}f,\mathrm{ord}g)$, restated in tropical
notation. $\square$

**Proposition 8.2.** For every $a$ and $N\ge2$, $\mathrm{ord}(F_a^{(N)})=0$ and
$T(F_a^{(N)})$ is the tropical unit. Consequently
$a\mapsto T(F_a^{(N)})$ is a (constant) monoid homomorphism from
$(\mathbb{Z}^{(\mathbb{N})},+)$ to the tropical units.

*Proof.* $F_a^{(N)}$ is a unit of $\mathbb{Z}[\![X]\!]$ with constant term $1$
(Theorem A), so its order is $0$. Multiplicativity is Propositions 4.1 and
8.1. $\square$

*Proof of Theorem I.* Take $a=24\delta_1$ and $a'=0$. Both have tropically
trivial shadow by Proposition 8.2, while $\mathrm{hc}(a)=324$ and
$\mathrm{hc}(a')=0$. $\square$

The content is the *strictness*. The normalisation $F_a=q/\eta_a$ pushes all of
the $q$-adic valuation into the explicit factor $q$; the tropical layer of the
theory is therefore the trivial, abelianised bottom of an invariant tower whose
next floor — the head coefficient — is Heisenberg and genuinely non-abelian. Any
attempt to classify eta quotients by valuation-theoretic data alone must fail by
at least $324$.

---

## 9. Algorithms

Three algorithms follow from the results, all with explicit complexity.

**Algorithm 1 (Head coefficient in $O(1)$).** Given $a_1,a_2$, return
$a_1(a_1+3)/2+a_2$. Two multiplications, one shift, one addition; exact in
integer arithmetic since $n(n+3)$ is always even. Contrast with the naive
approach of expanding the product, which needs $\Theta(N)$ series
multiplications.

**Algorithm 2 (All coefficients by the recursion, $O(n^2+n\log n)$).**
Precompute $b_m=\sum_{k\mid m}a_k$ for $m\le n$ by sieving over multiples
($O(n\log n)$ operations), then $\sigma_b(j)=\sum_{m\mid j}m\,b_m$ by a second
sieve, then apply $A_0=1$, $nA_n=\sum_{i<n}A_i\sigma_b(n-i)$. The convolution
dominates at $O(n^2)$ integer multiplications. Every division is exact, so the
algorithm stays in $\mathbb{Z}$.

**Algorithm 3 (Direct product expansion, $O(n^2\log)$-ish, used as a check).**
Multiply the truncated factors $(1-q^m)^{-b_m}$ one at a time, using
$(1-q^m)^{-b}=\sum_{j\ge0}\binom{b+j-1}{j}q^{mj}$ for $b\ge0$ and the
corresponding finite binomial expansion for $b<0$. Stability (Theorem C)
guarantees termination at $m=n$ with the correct answer.

Running Algorithms 2 and 3 against each other, and both against the closed forms
of Theorems A and B, is the natural validation loop; a numerical demonstration
carrying this out is included with this work.

---

## 10. Discussion, applications, and future directions

### 10.1 Why the head coefficient is the right invariant

In the normal form $1/\eta_a=q^{-1}+c(0)+c(1)q+\cdots$, the leading $q^{-1}$ is
forced by admissibility and $c(0)=a_1$ is a linear functional. The head
coefficient $c(1)$ is therefore the first invariant carrying non-linear
information about $a$, and Theorem D explains exactly what kind: it is the
central coordinate of a Heisenberg-valued homomorphism. Any classification of
eta quotients by the first two free coefficients is a classification by a
subgroup of $H_3(\mathbb{Z})$.

This is the natural home for the numerology surrounding genus-zero Hauptmoduln.
Monstrous-moonshine McKay–Thompson series have precisely the normal form (1.3),
their $c(1)$ are decomposable into dimensions of Monster representations, and
several of them are eta quotients. Theorem A gives their head coefficients
without any expansion at all.

### 10.2 The role of the recursion

Theorem E deserves emphasis as the structural centre. It says: pass to the
logarithmic derivative, where the map $a\mapsto\log F_a$ is *exactly linear*
(the structure constants $\sigma_b$ are additive in $a$), and all of the
non-linearity of the coefficients is the non-linearity of the exponential.
Unipotent groups are the truncations of $\exp$, which is why they govern the
coefficient tower; the Heisenberg cocycle of Theorem D is the $n=2$ shadow of a
Baker–Campbell–Hausdorff expansion. This viewpoint also explains why positivity
and congruences (Theorems F, G) are so cheap once one has the recursion: both are
inherited from the structure constants and propagated by an induction that never
leaves $\mathbb{Z}$.

### 10.3 Applications

- **Fast evaluation.** $c(1)$ and $c(2)$ in constant time from $a_1,a_2,a_3$,
  bypassing power-series arithmetic entirely. Useful in searches over exponent
  vectors, where the admissibility constraint $\sum_k ka_k=24$ already leaves a
  large space to scan.
- **Search filters.** Proposition 7.1 gives an $O(1)$ necessary condition for a
  target head coefficient to be realisable by a pure power, and Proposition 7.4
  gives a hard lower bound $-1$; both prune searches immediately.
- **Certified positivity and lower bounds.** Theorem F certifies positivity of
  the whole coefficient sequence of $q/\Delta$ (the sequence
  $1,24,324,3200,25650,176256,\dots$) without any asymptotic analysis, and
  Corollary 6.3 upgrades this to $A_n\ge24$ on indices coprime to $24$.
- **Congruence certificates.** Theorem G converts a divisibility statement about
  the divisor data — verifiable in $O(N\log N)$ — into infinitely many
  divisibility statements about coefficients.

### 10.4 Future directions

Five falsifiable conjectures suggested by the results above. Throughout, $a$ is a
finitely supported exponent vector, $b_m=\sum_{k\mid m}a_k$,
$F_a=\prod_{m\ge1}(1-q^m)^{-b_m}=\sum_{n\ge0}c(n-1)q^n=q/\eta_a$, and
$\sigma_b(j)=\sum_{m\mid j}m\,b_m$.

**Conjecture 1 (Unipotent tower).** *The $n$-th coefficient realises a faithful
representation of a free nilpotent group.* For each $n\ge1$ let
$\Phi_n(a)=(c(0),c(1),\dots,c(n-1))\in\mathbb{Z}^n$. Then $\Phi_n$ is a group
homomorphism from the additive group of exponent vectors into a unipotent group
$U_n\le\mathrm{GL}_{n+1}(\mathbb{Z})$ of upper-triangular matrices with $1$s on
the diagonal, extending $M(a)$, and the $k$-th layer of the lower central series
of the image is generated by the degree-$k$ part of $c(k-1)$ as a polynomial in
$a_1,\dots,a_k$. Concretely: $c(n-1)$ minus its term linear in $a_n$ is a
polynomial in $a_1,\dots,a_{n-1}$ of weighted degree exactly $n$ for
$\mathrm{wt}(a_k)=k$.

*Key insight:* the Heisenberg cocycle $c(1)(a+a')=c(1)(a)+c(1)(a')+a_1a_1'$ is
not an accident of degree $2$ but the $n=2$ shadow of a Baker–Campbell–Hausdorff
expansion: $\log F_a$ is linear in $a$ (this is exactly the additivity of
$\sigma_b$), so the non-linearity of the coefficients is entirely the
non-linearity of $\exp$, whose truncations are unipotent. Because both the
linearity of the log side and the exact passage from the log side to the
coefficient side are established, the conjecture reduces to a purely
combinatorial statement about the recursion — no new analytic input is required.
It is falsifiable at $n=4$ by a finite computation.

**Conjecture 2 (Sharp congruence).** *The exact modulus is the gcd of the divisor
data.* Let $d=\gcd\{b_m:m\ge1\}$. Then for every $n\ge1$,
$c(n-1)\equiv0 \pmod{d/\gcd(d,n)}$, and this is sharp: for each $n$ there is an
admissible $a$ for which $d/\gcd(d,n)$ is exactly the largest modulus dividing
$c(n-1)$.

*Key insight:* the divisibility $d\mid n\,c(n-1)$ is already available; what
remains is to control the exact power of each prime that survives the division by
$n$, and to exhibit extremal examples. The $\Delta$ data ($d=24$, coefficients
$1,24,324,3200,25650,176256$) already exhibit the predicted drop at
$n=2,3,4$ and its absence at $n=1,5$.

**Conjecture 3 (Positivity is exactly nonnegativity of the divisor data).** For
an exponent vector $a$, all coefficients $c(n-1)$ are positive if and only if
$b_m\ge0$ for all $m$ and $b_1\ge1$. The forward implication is proved; the
converse asserts that a single negative $b_m$ eventually forces a negative
coefficient.

**Conjecture 4 (Weighted-degree growth of the coefficient polynomials).** For
each $n$, the polynomial expressing $c(n-1)$ in $a_1,\dots,a_n$ has leading term
$\tfrac{a_1^n}{n!}$ up to lower-order corrections, so that the coefficient
sequence of a pure power $\eta^{a_1}$ grows like the coefficients of
$\exp$ in the exponent — quantitatively, $c(n-1)=\tfrac{a_1^n}{n!}(1+O(1/a_1))$
for fixed $n$ and large $a_1$.

**Conjecture 5 (Independence of the invariant layers).** The tropical layer
(valuation), the abelian layer ($c(0)=a_1$), and the Heisenberg layer ($c(1)$)
are pairwise independent as invariants on admissible exponent vectors: for any
prescribed values of the second and third that are consistent with the
Diophantine constraints of §7, there is an admissible $a$ realising them. The
surjectivity theorem is the case where only the third is prescribed.

---

## 11. Summary

Starting from an eta quotient $\eta_a=\prod_k\eta(k\tau)^{a_k}$ with
$\sum_k ka_k=24$, we normalised to $F_a=q/\eta_a=\prod_m(1-q^m)^{-b_m}$ with
$b_m=\sum_{k\mid m}a_k$, and computed the head coefficient of the resulting
Hauptmodul-shaped expansion:
$$c(1)=\frac{a_1(a_1+3)}{2}+a_2,$$
together with $c(0)=a_1$ and
$c(2)=\tfrac16 a_1(a_1+1)(a_1+2)+a_1(a_1+a_2)+a_1+a_3$. We proved that these
values are independent of any truncation of the defining product, that the head
coefficient obeys the Heisenberg cocycle
$c(1)(a+a')=c(1)(a)+c(1)(a')+a_1a_1'$ and hence defines a homomorphism into the
discrete Heisenberg group, and that all coefficients are governed uniformly by
the recursion $nA_n=\sum_{i<n}A_i\sigma_b(n-i)$ with twisted divisor-sum
structure constants. From the recursion came positivity of the coefficient
sequence of $q/\Delta$ and the congruence $24\mid A_n$ for $\gcd(n,24)=1$, the
coprimality being necessary. We characterised the attainable head coefficients —
$8c+9$ a square in the pure case, all of $\mathbb{Z}$ in general — and showed
that the valuation-theoretic (tropical) layer of the theory is strictly coarser
than the head coefficient, failing to distinguish exponent vectors whose head
coefficients differ by $324$.
