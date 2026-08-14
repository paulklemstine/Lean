# The Parity of the Elliptic Order as a Residue Dial

### Frobenius cycle types, quadratic reciprocity, and a symmetric — hence factoring-useless — shadow on semiprimes

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $E : y^2 = x^3 + Ax + B$ be an elliptic curve over a prime field $\mathbb{F}_p$, $p$ odd, with separable cubic ($\Delta = -4A^3 - 27B^2 \neq 0$). We give a complete, elementary account of the $2$-part of the order $\#E(\mathbb{F}_p)$ in terms of the action of the Frobenius automorphism on the three geometric roots of the cubic, and we determine exactly how much of that structure survives when only a semiprime $N = pq$ is observable.

The results are of four kinds. First, a **parity dichotomy**: $\#E(\mathbb{F}_p)$ is even if and only if the cubic has a root in $\mathbb{F}_p$; the proof is a fibrewise count requiring no group law. Second, a **cubic parity law** (Stickelberger's theorem in the cubic case): $\Delta$ is a quadratic non-square modulo $p$ precisely when the Frobenius is a transposition; consequently $(\Delta \mid p) = -1$ forces $2 \mid \#E(\mathbb{F}_p)$ with conditional probability exactly $1$, while the complementary half of the primes has conditional probability $1/3$, the global density being $2/3$. Third, a **symmetric residue shadow**: for the standard curve $E_0 : y^2 = x^3 + x + 1$ one has $\Delta = -31$, and quadratic reciprocity converts the Legendre symbol into a congruence condition modulo $31$; for a semiprime $N = pq$ the Jacobi symbol $(N \mid 31) = -1$ forces the order of $E_0$ to be even at $p$ or at $q$. This holds for every depressed integral cubic of discriminant $-\ell$ with $\ell \equiv 3 \pmod 4$ prime; the case $\ell = 23$, $y^2 = x^3 - x + 1$, is a second instance. Fourth, the **order modulo $4$**: three rational roots force $4 \mid \#E$, while with a unique rational root $a$ one has $\#E \equiv 2 \pmod 4$ if and only if $k = 3a^2 + A$ is a non-square — a criterion that refutes the natural guess that a transposition Frobenius always yields $\#E \equiv 2 \pmod 4$ ($p = 23$, $\#E_0(\mathbb{F}_{23}) = 28$). Via class field theory the split face is the classical principal-form condition $4p = A^2 + 31B^2$, whence: if $4p = A^2 + 31B^2$ then $\#E_0(\mathbb{F}_p) \not\equiv 2 \pmod 4$.

We quantify the semiprime channel exactly: it carries $H(8/9) - \tfrac12 H(7/9) = 0.1212$ bits, against $H(2/3) - \tfrac12 H(1/3) = 0.4591$ bits for the single-prime channel. All of it is symmetric in $p$ and $q$; none of it identifies a factor. An exact **Jensen deficit identity** shows how any non-uniformity of the conditional split rates compresses a union probability below its flat value by exactly the variance of the fork. The conclusion is a sharp negative result for factorization together with several positive structural theorems.

---

## 1. Introduction

The elliptic curve method of factorization, introduced by Lenstra, succeeds on a semiprime $N = pq$ when the order $\#E(\mathbb{F}_p)$ of a randomly chosen curve is smooth. Everything about the method's performance is therefore a question about the distribution of the two integers $\#E(\mathbb{F}_p)$ and $\#E(\mathbb{F}_q)$, of which the coarsest feature is their parity.

Parity is not random. For a fixed curve with integral coefficients, the parity of $\#E(\mathbb{F}_p)$ is a Frobenius condition in the splitting field of the cubic $x^3 + Ax + B$, and half of that condition — the sign of the Frobenius permutation — is a quadratic character of the discriminant, hence, by reciprocity, a congruence on $p$. The natural question is whether this residue-level visibility can ever be turned against the factorization problem, since one can compute Jacobi symbols of $N$ without knowing $p$ and $q$.

This paper answers that question completely, in the negative, and in the process assembles the exact structure of the $2$-part of the order.

Two framing remarks. First, everything here is unconditional and elementary except where explicitly attributed to Chebotarev's density theorem (used only for densities, never in a theorem statement) and to class field theory (used only to interpret the split face; the implication actually established below runs from the quadratic form to the curve and is proved from scratch). Second, the object of study is deliberately the "generic" curve: the cubic $x^3+x+1$ has Galois group $S_3$ over $\mathbb{Q}$, which is the situation of a curve with no rational two-torsion and no extra structure — the generic ECM situation. Curves engineered to have rational torsion are the opposite extreme and are not our subject.

### 1.1 Notation

Throughout, $p$ is an odd prime and $A, B \in \mathbb{F}_p$. We write
$$f(x) = x^3 + Ax + B, \qquad \Delta = \Delta(A,B) = -4A^3 - 27B^2 .$$
Separability is the condition $\Delta \neq 0$. We define the **order**
$$\#E(\mathbb{F}_p) \;=\; 1 + \#\{(x,y) \in \mathbb{F}_p^2 : y^2 = f(x)\},$$
the added $1$ accounting for the point at infinity of the projective Weierstrass model. We write $R = \{x \in \mathbb{F}_p : f(x) = 0\}$ for the rational root set and $r = |R|$. $(a \mid p)$ denotes the Legendre symbol and $(a \mid n)$ the Jacobi symbol for odd $n > 0$. $H(t) = -t\log_2 t - (1-t)\log_2(1-t)$ is the binary entropy.

Two curves recur:
$$E_0 : y^2 = x^3 + x + 1 \quad (\Delta = -31), \qquad E_1 : y^2 = x^3 - x + 1 \quad (\Delta = -23).$$

---

## 2. Depressed cubics: the algebraic preliminaries

All the structure below rests on the following elementary facts about a depressed cubic over an arbitrary field $F$ (characteristic $\neq 2$ where relevant). They are stated for a cubic with two known distinct roots $a \neq b$.

**Lemma 2.1 (Vieta).** If $f(a) = f(b) = 0$ with $a \ne b$, then
$$A = -(a^2 + ab + b^2), \qquad B = ab(a+b).$$

*Proof sketch.* Subtracting $f(a) = f(b) = 0$ gives $(a-b)(a^2+ab+b^2+A) = 0$; cancel $a - b$. Substituting back into $f(a) = 0$ yields the expression for $B$. $\square$

**Lemma 2.2 (Third root and factorization).** With $a \ne b$ as above, $c := -(a+b)$ is also a root, and every root of $f$ equals $a$, $b$ or $c$; indeed $f(x) = (x-a)(x-b)(x-c)$.

*Proof sketch.* Substitute the Vieta expressions into $f(-(a+b))$ and expand; then expand $(x-a)(x-b)(x-c)$ and compare with $f$ after the same substitution. $\square$

**Lemma 2.3 (Discriminant as a square of the difference product).** With $a,b,c$ as above,
$$\Delta = \bigl[(a-b)(b-c)(c-a)\bigr]^2 .$$

*Proof sketch.* Substitute the Vieta expressions for $A$ and $B$ into $-4A^3 - 27B^2$ and into the right-hand side; both reduce to the same polynomial in $a, b$. $\square$

**Corollary 2.4 (No cubic has exactly two rational roots).** If $\Delta \ne 0$ then $r \in \{0,1,3\}$.

*Proof sketch.* If $r \geq 2$, pick distinct roots $a \ne b$; then $c = -(a+b)$ is a third root, and $\Delta \ne 0$ forces $c \notin \{a, b\}$ — if, say, $c = a$ then $b = -2a$, and substituting into Lemma 2.3 gives $\Delta = 0$. So $r = 3$. $\square$

---

## 3. The parity dichotomy

**Lemma 3.1 (Fibre count).** For odd $p$ and $c \in \mathbb{F}_p$, the number of $y$ with $y^2 = c$ is $1$ if $c = 0$, $2$ if $c$ is a nonzero square, $0$ otherwise. In particular this number is odd exactly when $c = 0$.

*Proof sketch.* If $c = 0$ the only solution is $y = 0$ (a field has no nilpotents). If $c = y_0^2 \ne 0$ then $y^2 = c$ factors as $(y - y_0)(y + y_0) = 0$, and $y_0 \ne -y_0$ because $p$ is odd. $\square$

**Theorem 3.2 (Parity dichotomy).** *Let $p$ be an odd prime and let $x^3 + Ax + B$ be separable over $\mathbb{F}_p$. Then*
$$2 \mid \#E(\mathbb{F}_p) \iff \exists\, x \in \mathbb{F}_p,\ x^3 + Ax + B = 0 .$$

*Proof sketch.* Summing Lemma 3.1 over $x \in \mathbb{F}_p$ shows that the number of affine points is congruent modulo $2$ to $r$, the number of roots. Hence $\#E = 1 + \#\text{affine} \equiv 1 + r \pmod 2$, so $\#E$ is even iff $r$ is odd. By Corollary 2.4, $r \in \{0,1,3\}$, and $r$ is odd iff $r \ne 0$. $\square$

Equivalently, $\#E(\mathbb{F}_p)$ is odd exactly when the cubic is irreducible over $\mathbb{F}_p$, i.e. exactly when the Frobenius acts as a $3$-cycle on the geometric roots.

Note that no group law is used. The result recovers, by pure counting, the classical fact that the two-torsion of a Weierstrass curve consists of the points $(a, 0)$ with $f(a) = 0$.

---

## 4. The cubic parity law and the pinned face

The three cycle types of the Frobenius on the roots — identity ($r = 3$), transposition ($r = 1$), $3$-cycle ($r = 0$) — are distinguished by two pieces of data: the sign of the permutation, and, on the even side, whether it is trivial. The sign is exactly the quadratic character of the discriminant.

**Theorem 4.1 (Cubic parity law; Stickelberger for cubics).** *Let $p$ be odd and let the cubic be separable over $\mathbb{F}_p$. Then*
$$\Delta \text{ is a non-square in } \mathbb{F}_p \iff r = 1 .$$

The proof has three parts.

**(a) $r = 3 \Rightarrow \Delta$ is a square.** Immediate from Lemma 2.3, since $a, b, c \in \mathbb{F}_p$.

**(b) $r = 0 \Rightarrow \Delta$ is a square.** This is the substantive direction. Since $f$ has no rational root and $\deg f = 3$, $f$ is irreducible, so $K = \mathbb{F}_p[x]/(f)$ is a field with $p^3$ elements. Let $a \in K$ be the image of $x$; then $a$ is a root of $f$, and applying the Frobenius $\varphi(z) = z^p$ — which fixes $A$ and $B$, as they lie in the prime field — shows that $b = a^p$ and $a^{p^2}$ are roots too. Because $a \notin \mathbb{F}_p$ we have $a \ne b$, and Lemma 2.2 identifies the third root as $c = -(a+b)$; a short argument using $a^{p^3} = a$ shows $a^{p^2} = c$. Thus $\varphi$ cycles $a \to b \to c \to a$. The difference product $\delta = (a-b)(b-c)(c-a)$ is invariant under this cyclic rotation, so $\delta^p = \delta$, i.e. $\delta \in \mathbb{F}_p$. By Lemma 2.3, $\Delta = \delta^2$ is a square in $\mathbb{F}_p$. $\square$

**(c) $r = 1 \Rightarrow \Delta$ is a non-square.** Let $a$ be the unique root; then $B = -a^3 - Aa$ and
$$f(x) = (x - a)\bigl(x^2 + ax + (a^2 + A)\bigr).$$
Uniqueness of $a$ means the quadratic factor has no root in $\mathbb{F}_p$ (a root $x_0$ of it would be a root of $f$, hence $x_0 = a$, which would make $a$ a double root and force $\Delta = 0$). Over a field of odd characteristic a quadratic $x^2 + ax + c$ has a root iff its discriminant $a^2 - 4c$ is a square; hence $a^2 - 4(a^2+A) = -3a^2 - 4A$ is a non-square. The algebraic identity
$$\Delta = (3a^2 + A)^2 \cdot (-3a^2 - 4A)$$
(verified by substituting $B = -a^3 - Aa$) then exhibits $\Delta$ as a nonzero square times a non-square, hence a non-square. Note $3a^2 + A \ne 0$, else $\Delta = 0$. $\square$

Combining Theorems 3.2 and 4.1:

**Corollary 4.2 (The pinned face).** *If $\Delta$ is a quadratic non-square modulo $p$ (equivalently, if the Legendre symbol $(\Delta \mid p) = -1$), then $2 \mid \#E(\mathbb{F}_p)$.*

This is a statement with conditional probability exactly $1$: on the non-residue half of the primes, the parity coin is not a coin at all.

### 4.1 Densities

For a cubic with Galois group $S_3$ over $\mathbb{Q}$ (as for $E_0$ and $E_1$), Chebotarev's density theorem gives natural densities $1/6$, $1/2$, $1/3$ for the cycle types $[1,1,1]$, $[1]$, $[3]$. Hence:

$$\Pr[\,2 \mid \#E\,] = \tfrac16 + \tfrac12 = \tfrac23, \qquad
\Pr[\,2 \mid \#E \mid (\Delta\mid p) = -1\,] = 1, \qquad
\Pr[\,2 \mid \#E \mid (\Delta\mid p) = +1\,] = \tfrac13 .$$

The last figure is the probability that a Frobenius in $A_3$ is the identity. Counting for $E_0$ over the $2{,}260$ primes $p < 20{,}000$ with $p \notin \{2,31\}$ gives observed frequencies $0.1602$, $0.5066$, $0.3332$ for the three cycle types, an even-order density of $0.6668$, and $0.3247$ conditional on $(\Delta \mid p) = +1$.

---

## 5. From Legendre symbol to congruence: the residue dial

The pinned face is a condition on $p$ that a factoring algorithm cannot evaluate — unless the discriminant is chosen so that reciprocity converts it into a congruence.

**Lemma 5.1 (Reciprocity in the form needed).** *Let $\ell \equiv 3 \pmod 4$ be prime and $p \ne 2, \ell$ prime. Then*
$$\left(\frac{-\ell}{p}\right) = \left(\frac{p}{\ell}\right).$$

*Proof sketch.* Multiplicativity gives $(-\ell \mid p) = (-1 \mid p)(\ell \mid p)$. If $p \equiv 1 \pmod 4$ then $(-1\mid p) = 1$ and reciprocity gives $(\ell \mid p) = (p \mid \ell)$. If $p \equiv 3 \pmod 4$ then $(-1 \mid p) = -1$, and since also $\ell \equiv 3 \pmod 4$, reciprocity gives $(\ell \mid p) = -(p \mid \ell)$; the two signs cancel. $\square$

For $E_0$ we have $\Delta = -4 - 27 = -31$ and $31 \equiv 3 \pmod 4$, so $(\Delta \mid p) = (p \mid 31)$: **the parity of $\#E_0(\mathbb{F}_p)$ is pinned by $p \bmod 31$ on half of all primes.** For $E_1$, $\Delta = -4(-1)^3 - 27 = 4 - 27 = -23$, and $23 \equiv 3 \pmod 4$; the same applies with modulus $23$.

**Corollary 5.2.** *If $(p \mid 31) = -1$, then $2 \mid \#E_0(\mathbb{F}_p)$. If $(p \mid 23) = -1$, then $2 \mid \#E_1(\mathbb{F}_p)$.*

---

## 6. The symmetric shadow on a semiprime

We now pass to the setting in which only $N = pq$ is known.

**Theorem 6.1 (Symmetric residue shadow, general form).** *Let $\ell \equiv 3 \pmod 4$ be prime and let $a, b \in \mathbb{Z}$ satisfy $-4a^3 - 27b^2 = -\ell$. Let $p, q$ be odd primes different from $\ell$ and put $N = pq$. If the Jacobi symbol $(N \mid \ell) = -1$, then the order of $y^2 = x^3 + ax + b$ is even over $\mathbb{F}_p$ or over $\mathbb{F}_q$.*

*Proof sketch.* Since $-\ell$ is squarefree and prime, the reduced cubic is separable modulo every $p \ne \ell$. The Jacobi symbol factors, $(N \mid \ell) = (p \mid \ell)(q \mid \ell)$, and both factors are $\pm 1$ (neither $p$ nor $q$ is divisible by $\ell$). A product equal to $-1$ forces at least one factor to be $-1$; for that prime, Lemma 5.1 gives $(\Delta \mid \cdot) = -1$ and Corollary 4.2 applies. $\square$

**Corollary 6.2 (The $\Delta = -31$ dial).** *For $N = pq$ with $p, q \notin \{2, 31\}$: if $(N \mid 31) = -1$ then $2 \mid \#E_0(\mathbb{F}_p)$ or $2 \mid \#E_0(\mathbb{F}_q)$. The hypothesis depends only on $N \bmod 31$.*

**Corollary 6.3 (Robustness face $\Delta = -23$).** *The same statement holds for $E_1 : y^2 = x^3 - x + 1$ with modulus $23$.*

The dial is thus not an accident of the number $31$: it exists for every integral depressed cubic whose discriminant is minus a prime congruent to $3$ modulo $4$. What is special about $-31$ is only that $x^3 + x + 1$ is the smallest such cubic and is a standard default curve.

---

## 7. Exactly how much information the dial carries

Model $(p \mid \ell)$ and $(q \mid \ell)$ as independent fair signs, and — conditionally on each sign — let the parity of the corresponding order follow the Chebotarev distribution of §4.1. Let $Y$ be the indicator of the event
$$Y : \quad 2 \mid \#E(\mathbb{F}_p) \ \text{ or } \ 2 \mid \#E(\mathbb{F}_q),$$
and let $X = (N \mid \ell) \in \{\pm 1\}$ be the observable.

**Conditional probabilities.** If $X = -1$ then exactly one of the two signs is $-1$, and $\Pr[Y] = 1$ by Theorem 6.1. If $X = +1$ then either both signs are $-1$ (probability $1/2$, whence $\Pr[Y] = 1$) or both are $+1$ (probability $1/2$, whence each factor independently contributes an even order with probability $1/3$ and $\Pr[Y] = 1 - (2/3)^2 = 5/9$). Therefore
$$\Pr[Y \mid X = -1] = 1, \qquad \Pr[Y \mid X = +1] = \tfrac12 + \tfrac12\cdot\tfrac59 = \tfrac79, \qquad \Pr[Y] = \tfrac89 .$$

**Channel capacity.** The mutual information is
$$I(X; Y) = H\!\left(\tfrac89\right) - \tfrac12 H(1) - \tfrac12 H\!\left(\tfrac79\right) = 0.50326 - 0.38210 = 0.12116 \text{ bits}.$$
By contrast, if the individual prime $p$ were observable, the analogous channel $X' = (p \mid \ell)$, $Y' = [\,2 \mid \#E(\mathbb{F}_p)\,]$ carries
$$I(X'; Y') = H\!\left(\tfrac23\right) - \tfrac12 H(1) - \tfrac12 H\!\left(\tfrac13\right) = 0.91830 - 0.45915 = 0.45915 \text{ bits}.$$

A simulation over $40{,}000$ random semiprimes built from primes below $60{,}000$ measures $I(N \bmod 31; Y) = 0.1253$ bits and $I\bigl((N\mid 31); Y\bigr) = 0.1249$ bits, so that the residual information in the full residue $N \bmod 31$ beyond the Jacobi symbol is $0.0003$ bits — statistically indistinguishable from zero. The dial is *exactly* the quadratic character; nothing finer about $N \bmod 31$ matters. This is as it must be: the parity condition is a Frobenius condition in a degree-$6$ field whose only abelian subextension is $\mathbb{Q}(\sqrt{-\ell})$, and abelian subextensions are precisely what congruences can see.

**Why this cannot factor.** The observable is a Jacobi symbol, and a Jacobi symbol is a *product* over the hidden primes; therefore every function of it is a symmetric function of the pair $(p, q)$. A factoring algorithm needs an asymmetric fact — "the even-order factor is *this* one" — and no symmetric statistic can supply it. Formally, the asymmetric channel
$$X = (N \mid \ell) \ \longrightarrow\ Y_{\mathrm{asym}} = \bigl[\,2 \mid \#E(\mathbb{F}_p)\,\bigr]$$
(with $p$ the smaller factor, say) has zero mutual information under the model, because the model is invariant under swapping $p$ and $q$ while $X$ is not affected by the swap. The measured asymmetric information in experiments is at the noise floor. This is the negative verdict: **the parity dial is real, exact, and useless for factorization.**

### 7.1 The Jensen deficit of a non-flat fork

The value $7/9$ above assumed that, conditionally on $(\Delta\mid p) = +1$, each factor has an even order with the *same* probability $1/3$. Suppose instead the conditional even-order rate varies across observable classes: in class $i$ (of $n$ equally likely classes) the rate is $\theta_i$. If both factors are drawn from the same class, the union probability is $1 - \frac1n\sum_i (1-\theta_i)^2$. The following exact identity governs the comparison with the "flat" value obtained by replacing every $\theta_i$ with the mean $\bar\theta$.

**Theorem 7.1 (Jensen deficit identity).** *For any $\theta_1, \dots, \theta_n \in \mathbb{R}$ with mean $\bar\theta = \frac1n\sum_i \theta_i$,*
$$1 - \frac1n\sum_{i=1}^{n} (1 - \theta_i)^2 \;=\; \Bigl(1 - (1-\bar\theta)^2\Bigr) \;-\; \frac1n\sum_{i=1}^{n}\bigl(\theta_i - \bar\theta\bigr)^2 .$$

*Proof sketch.* Expand both sides as polynomials in $\sum\theta_i$ and $\sum\theta_i^2$: the left side is $1 - \frac1n\sum\theta_i^2 + \frac2n\sum\theta_i - 1$, and the variance term supplies exactly the discrepancy $\frac1n\sum\theta_i^2 - \bar\theta^2$. $\square$

**Corollary 7.2.** *The union probability never exceeds its flat value; the deficit equals the variance of the fork, and is zero exactly for a flat fork.*

This is the precise mechanism by which a residue-dependent fork would compress the observed $\Pr[Y \mid X = +1]$ below $7/9$: the union of two events drawn from a *correlated* class is a concave functional of the class rate. Empirically, the extent of any such compression is a measurement of the non-flatness of the split rate.

We record what the computation shows. Over the $15$ quadratic-residue classes modulo $31$, restricted to primes $p < 200{,}000$ with $(\Delta \mid p) = +1$, the observed rates of the fully-split face lie in the narrow band $[0.319, 0.342]$ with mean $0.3312$; the resulting variance is $1.0 \times 10^{-4}$ and the union deficit is of the same order: the same-class union probability is $0.5526$ against its flat value $0.5527$, and in the independent-draw model of §7 the measured $\Pr[Y \mid X = +1] = 0.7715$ sits at $7/9 = 0.7778$ to within sampling error. This is the flat behaviour predicted by Chebotarev: the split condition is a Frobenius condition in the degree-$6$ splitting field, whose Frobenius classes are equidistributed *within* each quadratic-residue class of the modulus. Any substantially larger spread measured on a small sample of primes is a finite-sample artefact — with $\sim 10^2$ primes per class the binomial standard deviation is already $\approx 0.05$, and estimated mutual informations at moduli as large as $31^2 = 961$ are dominated by estimator bias. Theorem 7.1 is unconditional; what it multiplies, in this instance, is a variance that vanishes in the limit.

---

## 8. The order modulo $4$

Parity is settled by counting roots. The next bit requires refining the fibre count with an involution.

Write $S = \{x \in \mathbb{F}_p : f(x) \ne 0 \text{ and } f(x) \text{ is a square}\}$, the set of $x$ whose fibre has two points. By Lemma 3.1,
$$\#E(\mathbb{F}_p) = 1 + r + 2|S| ,$$
so the class of $\#E$ modulo $4$ is determined by $r$ together with the parity of $|S|$.

**The translation involution.** Let $a$ be a rational root and set $k = 3a^2 + A$ (which is $f'(a)$, and is nonzero when $\Delta \ne 0$, by the identity $\Delta = k^2(-3a^2 - 4A)$). Define
$$\tau_a(x) = a + \frac{k}{x - a} \qquad (x \ne a).$$
This is the $x$-coordinate of translation by the two-torsion point $(a, 0)$.

**Lemma 8.1.** *$\tau_a$ maps $S$ to $S$ and satisfies $\tau_a \circ \tau_a = \mathrm{id}$ on $S$. Its fixed points in $S$ are the solutions of $(x - a)^2 = k$.*

*Proof sketch.* The key algebraic identity, obtained by writing $f(a + u) = u(u^2 + 3au + k)$ and substituting $u = k/(x-a)$, is
$$f(\tau_a(x))\,(x-a)^4 = k^2 f(x).$$
Thus $f(\tau_a(x))$ differs from $f(x)$ by the square factor $k^2/(x-a)^4$, so it is a nonzero square exactly when $f(x)$ is; membership in $S$ is preserved. Involutivity is a direct computation, and $\tau_a(x) = x$ rearranges to $(x-a)^2 = k$. $\square$

**Lemma 8.2 (Parity via fixed points).** *For any involution of a finite set, the cardinality is congruent modulo $2$ to the number of fixed points.* Hence $|S| \equiv \#\{x \in S : (x-a)^2 = k\} \pmod 2$.

The candidate fixed points are $a \pm w$ when $k = w^2$ is a square, and there are none when $k$ is a non-square. The decisive computation is the product identity
$$f(a+w)\,f(a-w) = \Delta \qquad \text{whenever } w^2 = k,$$
which pins the *joint* quadratic character of the two candidates to that of the discriminant.

**Theorem 8.3 (Split face).** *If the cubic has three roots in $\mathbb{F}_p$, then $4 \mid \#E(\mathbb{F}_p)$.*

*Proof sketch.* Here $r = 3$ and $\Delta$ is a square. If $k$ is a non-square there are no fixed points and $|S|$ is even. If $k = w^2$, then $f(a+w)f(a-w) = \Delta$ is a nonzero square, so $f(a+w)$ and $f(a-w)$ have the *same* quadratic character: either both $a \pm w$ lie in $S$ or neither does. Either way the fixed-point count is even, so $|S|$ is even and $\#E = 1 + 3 + 2|S| \equiv 0 \pmod 4$. $\square$

Group-theoretically: three rational roots means full rational two-torsion, $E(\mathbb{F}_p) \supseteq (\mathbb{Z}/2)^2$.

**Theorem 8.4 (One-root face, exact law).** *If the cubic has the unique root $a$, then*
$$\#E(\mathbb{F}_p) \equiv \begin{cases} 0 \pmod 4, & \text{if } 3a^2 + A \text{ is a square mod } p,\\[2pt] 2 \pmod 4, & \text{if } 3a^2 + A \text{ is a non-square mod } p.\end{cases}$$

*Proof sketch.* Now $r = 1$ and $\Delta$ is a *non-square* (Theorem 4.1). If $k$ is a non-square there are no fixed points, $|S|$ is even, and $\#E = 2 + 2|S| \equiv 2 \pmod 4$. If $k = w^2$, then $f(a+w)f(a-w) = \Delta$ is a non-square, so exactly one of $f(a\pm w)$ is a square: exactly one fixed point, $|S|$ odd, and $\#E = 2 + 2|S| \equiv 0 \pmod 4$. $\square$

**Remark 8.5 (A natural guess, refuted).** One might expect that a transposition Frobenius always gives $\#E \equiv 2 \pmod 4$ — one rational two-torsion point and no more $2$-power. Theorem 8.4 shows the correct criterion involves the tangent slope $k = f'(a)$, and the guess fails. The smallest witness for $E_0$ is $p = 23$: the cubic $x^3+x+1$ has the unique root $a = 4$ modulo $23$, yet
$$\#E_0(\mathbb{F}_{23}) = 28 \equiv 0 \pmod 4 .$$
Indeed $k = 3\cdot 4^2 + 1 = 49 \equiv 3 \pmod{23}$ and $3 = 7^2$ is a square modulo $23$, so Theorem 8.4 predicts $4 \mid \#E$. The invariant meaning: $k$ being a square is the classical criterion for the two-torsion point $(a,0)$ to be divisible by $2$ in $E(\mathbb{F}_p)$, i.e. for a point of order $4$ to exist above it. A verification of Theorems 8.3 and 8.4 across all $2{,}260$ good primes below $20{,}000$ finds no violations.

**Remark 8.6 (Not a congruence).** Unlike parity, the mod-$4$ law is *not* a residue dial. The criterion $(3a^2 + A \mid p) = 1$ refers to the root $a$, an algebraic function of $p$ of degree $3$; the condition is a Frobenius condition in the compositum of the splitting field of the cubic with a quadratic extension defined over the cubic field, a non-abelian extension of $\mathbb{Q}$ of degree $12$. No congruence on $p$ can detect it.

---

## 9. The class field face: $4p = A^2 + 31B^2$

The split face $r = 3$ admits a classical description. The splitting field $L$ of $x^3+x+1$ over $\mathbb{Q}$ is an $S_3$-extension containing $K = \mathbb{Q}(\sqrt{-31})$; the field $K$ has class number $3$, and $L$ is its Hilbert class field. By class field theory, a prime $p$ splits completely in $L$ if and only if $p$ splits in $K$ into principal prime ideals, which for an imaginary quadratic field of discriminant $-31$ is equivalent to representability of $p$ by the principal binary quadratic form. In the $4p$-normalisation:

> $x^3 + x + 1$ has three roots modulo $p$ $\iff$ $4p = A^2 + 31B^2$ for some $A, B \in \mathbb{Z}$ with $A \equiv B \pmod 2$.

The same holds with $31$ replaced by $23$ and the cubic by $x^3 - x + 1$, since $\mathbb{Q}(\sqrt{-23})$ also has class number $3$. A direct test over all good primes below $20{,}000$ confirms the dictionary with zero mismatches; the smallest split prime is $p = 47$, where $4 \cdot 47 = 188 = 8^2 + 31\cdot 2^2$ and $\#E_0(\mathbb{F}_{47}) = 60$.

We prove from first principles the elementary half of the dictionary, and combine it with §8.

**Theorem 9.1.** *Let $p \ne 2$ be prime and suppose $4p = A^2 + 31B^2$ for integers $A, B$. Then $-31$ is a square modulo $p$.*

*Proof sketch.* First, $p \nmid B$: if $p \mid B$ then reducing $4p = A^2 + 31B^2$ modulo $p$ gives $p \mid A^2$, hence $p \mid A$, hence $p^2 \mid 4p$, i.e. $p \mid 4$, contradicting $p$ odd. So $B$ is invertible modulo $p$, and reducing the equation modulo $p$ gives $A^2 + 31B^2 \equiv 0$, i.e. $-31 \equiv (A/B)^2$. $\square$

**Theorem 9.2 (Class-field shadow on the order modulo $4$).** *Let $p \notin \{2, 31\}$ be prime with $4p = A^2 + 31B^2$ for some integers $A, B$. Then*
$$\#E_0(\mathbb{F}_p) \not\equiv 2 \pmod 4 :$$
*the order is either odd or divisible by $4$.*

*Proof sketch.* By Theorem 9.1 the discriminant $\Delta = -31$ is a square modulo $p$, so by Theorem 4.1 the root count $r$ is not $1$; by Corollary 2.4, $r \in \{0, 3\}$. If $r = 0$, Theorem 3.2 makes $\#E_0$ odd. If $r = 3$, Theorem 8.3 gives $4 \mid \#E_0$. $\square$

The representability of $4p$ by the principal form of discriminant $-31$ — a question of binary quadratic forms, older than elliptic curves — is thereby *visible in the two-part of the group of points*.

---

## 10. Algorithms

Four routines suffice to reproduce everything above; all are elementary and run in time polynomial in $\log p$ except the naive point count, which is included for verification.

**(A1) Point count by character sums.** $\#E(\mathbb{F}_p) = 1 + \sum_{x} \bigl(1 + (f(x)\mid p)\bigr) = 1 + p + \sum_x (f(x)\mid p)$. Cost $O(p \log p)$; used only as ground truth. (For large $p$, Schoof-type algorithms are the practical alternative, but nothing in this paper needs them: all our statements about $\#E$ modulo $4$ are computed from root sets and Legendre symbols.)

**(A2) Frobenius cycle-type classification.** Compute $\gcd(x^p - x, f)$ in $\mathbb{F}_p[x]$ to get the number of rational roots without enumeration; equivalently, for small $p$, enumerate. Then the cycle type is $[1,1,1]$, $[1]$, $[3]$ according as $r = 3, 1, 0$. Predicted parity: even iff $r > 0$. Predicted class modulo $4$: $0$ if $r = 3$; if $r = 1$ with root $a$, $0$ or $2$ according as $(3a^2+A \mid p) = +1$ or $-1$; and odd if $r = 0$. Cost: one modular exponentiation of a polynomial, $O(\log p)$ multiplications.

**(A3) Semiprime dial.** Given $N$ and $\ell \equiv 3 \pmod 4$ with $-\ell$ the discriminant of the chosen cubic, compute the Jacobi symbol $(N \mid \ell)$ by the binary algorithm in $O(\log^2 N)$ bit operations; if it is $-1$, output the certificate "the order is even at at least one factor of $N$". No knowledge of the factors is required.

**(A4) Principal-form representation.** To test $4p = A^2 + 31B^2$, loop $B$ over $0 \le B \le \sqrt{4p/31}$ and test whether $4p - 31B^2$ is a perfect square of the right parity; cost $O(\sqrt{p})$. The classical $O(\log^2 p)$ alternative is Cornacchia's algorithm: find a square root of $-31$ modulo $4p$ and run a truncated Euclidean algorithm.

---

## 11. Numerical summary

All figures below are computed directly from the definitions.

| Quantity | Measured | Predicted |
|---|---|---|
| $\Pr[\text{Frobenius} = [1,1,1]]$, $p < 20000$ | $0.1602$ | $1/6 = 0.1667$ |
| $\Pr[\text{Frobenius} = [1]]$ | $0.5066$ | $1/2$ |
| $\Pr[\text{Frobenius} = [3]]$ | $0.3332$ | $1/3$ |
| $\Pr[2 \mid \#E_0]$ | $0.6668$ | $2/3$ |
| $\Pr[2 \mid \#E_0 \mid (\Delta\mid p) = -1]$ | $1.0000$ | $1$ (Corollary 4.2) |
| $\Pr[2 \mid \#E_0 \mid (\Delta\mid p) = +1]$ | $0.3247$ | $1/3$ |
| Violations of the parity dichotomy, $p<2000$ | $0$ | $0$ |
| Violations of the cubic parity law, $p<2000$ | $0$ | $0$ |
| Violations of $4\mid\#E$ on the split face, $p<20000$ | $0$ | $0$ |
| Violations of the one-root mod-$4$ law, $p<20000$ | $0$ | $0$ |
| Mismatches of $[1,1,1] \leftrightarrow 4p = A^2+31B^2$ | $0/2260$ | $0$ |
| $I(N \bmod 31; \text{even at } p \text{ or } q)$ | $0.1253$ bits | $0.1212$ bits |
| $I((N\mid 31); \text{same event})$ | $0.1249$ bits | $0.1212$ bits |
| $\Pr[\text{OR} \mid (N\mid31) = -1]$ | $1.0000$ | $1$ (Theorem 6.1) |
| $\Pr[\text{OR} \mid (N\mid31) = +1]$ | $0.7715$ | $7/9 = 0.7778$ |
| Single-prime channel $I((p\mid31); 2\mid\#E_0)$ | — | $0.4591$ bits |

A representative table of small primes for $E_0$, illustrating all three faces and both mod-$4$ behaviours:

| $p$ | roots of $x^3+x+1$ | type | $\#E_0(\mathbb{F}_p)$ | $\#E_0 \bmod 4$ |
|---|---|---|---|---|
| $5$ | none | $[3]$ | $9$ | odd |
| $7$ | none | $[3]$ | $5$ | odd |
| $11$ | $\{2\}$ | $[1]$ | $14$ | $2$ |
| $13$ | $\{7\}$ | $[1]$ | $18$ | $2$ |
| $23$ | $\{4\}$ | $[1]$ | $28$ | $0$ |
| $29$ | $\{26\}$ | $[1]$ | $36$ | $0$ |
| $41$ | none | $[3]$ | $35$ | odd |
| $47$ | $\{25,34,35\}$ | $[1,1,1]$ | $60$ | $0$ |

The rows $p = 23$ and $p = 29$ are the refutation of Remark 8.5; $p = 47$ is the smallest prime with $4p = A^2 + 31B^2$.

**The size of the effect.** The dial is not merely a curiosity about parity: it moves the quantity that the elliptic curve method actually cares about. Over the $2{,}260$ primes $p < 20{,}000$ with $p \notin \{2,31\}$, split by the Legendre symbol $(p\mid 31)$:

| face | primes | $\Pr[\,2 \mid \#E_0\,]$ | mean $v_2(\#E_0)$ | $\Pr[\#E_0 \text{ is } 60\text{-smooth}]$ |
|---|---|---|---|---|
| $(p\mid31) = -1$ (pinned) | $1145$ | $1.0000$ | $2.0035$ | $0.3100$ |
| $(p\mid31) = +1$ (free) | $1115$ | $0.3247$ | $1.0789$ | $0.2933$ |
| both | $2260$ | $0.6668$ | $1.5473$ | $0.3018$ |

The pinned face carries a full extra factor of $2$ on average (indeed $2.0035$ versus $1.0789$, the excess above $1$ coming from the mod-$4$ law of §8), and a measurably higher smoothness probability. The gain is genuine; what is missing is any way to attach it to a named factor of $N$.

---

## 12. Discussion

**What is proved, and what it means.** The $2$-part of the order of a Weierstrass curve over $\mathbb{F}_p$ is entirely encoded by the Frobenius action on the roots of the defining cubic, together with one further Legendre symbol on the transposition face. Half of the encoding — the sign of the permutation — is abelian and therefore visible in congruences; the other half is not. For a curve of discriminant $-\ell$ with $\ell \equiv 3 \pmod 4$, the abelian half becomes a genuinely usable dial: a single Jacobi symbol of a semiprime produces a *certain* statement about the hidden factorization.

**Why it does not help factor.** The dial is symmetric. Jacobi symbols multiply over factors, so any statistic derived from $(N \mid \ell)$ is a symmetric function of the pair $(p,q)$, while factoring requires breaking that symmetry. Quantitatively, the symmetric channel carries $0.1212$ bits and the asymmetric channel carries none. This is a clean, structural barrier, not a limitation of the analysis: it survives every strengthening of the residue modulus, because the exact order is separated from the residue data by the Chinese Remainder splitting of the semiprime, and because the finer, non-abelian information (the mod-$4$ law of §8) is invisible to congruences by Remark 8.6.

**Positive by-products.** Three items are of independent interest. (i) The involution proof of the mod-$4$ law computes a group-theoretic invariant — the presence of a point of order $4$ — without invoking the group law, replacing it by a fixed-point count for $x \mapsto a + f'(a)/(x-a)$. (ii) The corrected one-root law, with its counterexample at $p = 23$, is a reminder that the cycle type of the Frobenius determines the order modulo $2$ but not modulo $4$. (iii) The class-field statement transfers a $19$th-century representability question, $4p = A^2 + 31B^2$, into a statement about $\#E \bmod 4$.

**Limitations.** The density statements of §4.1 rest on Chebotarev and hold in the natural-density sense; the empirical figures are finite-sample. The class-field equivalence of §9 is quoted from class field theory; only the implication used in Theorem 9.2 is proved here from first principles. The information-theoretic model of §7 treats the two Legendre symbols as independent fair coins, which is the correct heuristic for primes drawn uniformly from a large range but is not a theorem about any particular family of semiprimes.

---

## 13. Future directions

**Conjecture 1 — the $2$-adic valuation as a two-symbol dial.** For a separable depressed cubic over $\mathbb{F}_p$ with root set of size $r$: $r = 0$ gives $v_2(\#E) = 0$; $r = 1$ gives $v_2(\#E) = 1$ exactly when $k = 3a^2 + A$ is a non-square (proved above), and conjecturally $v_2(\#E) = 2 + v_2(m)$, where $m$ counts the $x$ with $f(x)$ a nonzero square in a single orbit class of the translation involution; $r = 3$ gives $v_2(\#E) \ge 2$, with equality exactly when none of $(b-a)(c-a)$, $(a-b)(c-b)$, $(a-c)(b-c)$ is a square modulo $p$. The organising insight is that the mod-$4$ (and, conjecturally, the mod-$2^k$) information is carried by the quadratic characters of the tangent slopes $f'(a)$ at the rational two-torsion points, because the translation involution has a fixed point exactly when that slope is a square — the classical halving criterion in involution form. The involution machinery makes such statements finite fixed-point computations rather than group-law arguments.

**Conjecture 2 — the $4 \mid \#E$ face is not a residue dial.** Whereas $2 \mid \#E_0(\mathbb{F}_p)$ is pinned by $p \bmod 31$ on half of all primes, we conjecture that $4 \mid \#E_0(\mathbb{F}_p)$ is not determined by $p \bmod M$ for any fixed modulus $M$: the criterion $(3a^2+1\mid p) = 1$ involves the root $a$, an algebraic function of $p$ of degree $3$, so the condition cuts out a non-abelian Chebotarev class in a degree-$12$ field of type $S_3 \times C_2$. The corrected mod-$4$ law is a *conditional* Legendre symbol of a quantity living in the cubic field, hence a Frobenius condition in a non-abelian extension, invisible to any congruence. The statement is now clean enough to be tested by counting and, plausibly, proved by identifying the degree-$12$ field explicitly.

**Further directions.** (a) Extend the analysis to the odd part: the analogous $\ell$-parity questions for $\ell = 3$ involve the $3$-division polynomial and a quartic resolvent, and it would be interesting to see whether any of them admits a reciprocity-driven residue dial. (b) Quantify the ray-class refinement: conditioning on $N \bmod \ell^2$ rather than $N \bmod \ell$ can only add information through ramified characters, and one should be able to prove that the added mutual information is exactly zero in the limit, making the observed excess at finite samples a pure estimator-bias effect. (c) Systematically catalogue the depressed cubics $x^3+ax+b$ with $-4a^3-27b^2 = -\ell$, $\ell \equiv 3 \pmod 4$ prime and $h(\mathbb{Q}(\sqrt{-\ell})) = 3$, to obtain a family of curves each carrying its own exact residue dial. (d) Investigate whether the certainty on the pinned face can be exploited in the *design* of ECM curve families — choosing curves whose discriminant guarantees an even order at the unknown factor, thereby raising the smoothness probability by a controllable factor, even though it cannot identify the factor.

---

## Appendix: statements collected

For reference, the results proved above.

1. **Parity dichotomy.** For odd $p$ and separable $x^3+Ax+B$ over $\mathbb{F}_p$: $2 \mid \#E(\mathbb{F}_p)$ iff the cubic has a root in $\mathbb{F}_p$.
2. **Root count trichotomy.** A separable depressed cubic has $0$, $1$ or $3$ roots in a field.
3. **Cubic parity law.** $\Delta$ is a non-square modulo $p$ iff the cubic has exactly one root.
4. **Pinned face.** $(\Delta\mid p) = -1 \Rightarrow 2 \mid \#E(\mathbb{F}_p)$.
5. **Reciprocity form.** For prime $\ell\equiv 3 \pmod 4$: $(-\ell\mid p) = (p \mid \ell)$.
6. **Symmetric shadow.** For $-4a^3-27b^2 = -\ell$ and $N = pq$: $(N\mid \ell) = -1 \Rightarrow$ the order of $y^2=x^3+ax+b$ is even at $p$ or at $q$. Instances: $x^3+x+1$ with $\ell = 31$; $x^3-x+1$ with $\ell = 23$.
7. **Split face mod $4$.** Three rational roots $\Rightarrow 4 \mid \#E(\mathbb{F}_p)$.
8. **One-root face mod $4$.** Unique root $a$: $\#E \equiv 2 \pmod 4$ iff $3a^2+A$ is a non-square; otherwise $4 \mid \#E$. Counterexample to the blanket claim: $\#E_0(\mathbb{F}_{23}) = 28$.
9. **Class-field shadow.** $4p = A^2+31B^2 \Rightarrow -31$ is a square modulo $p$ $\Rightarrow \#E_0(\mathbb{F}_p) \not\equiv 2 \pmod 4$.
10. **Jensen deficit identity.** $1 - \frac1n\sum(1-\theta_i)^2 = \bigl(1-(1-\bar\theta)^2\bigr) - \frac1n\sum(\theta_i-\bar\theta)^2$, and hence the union probability never exceeds its flat value.
