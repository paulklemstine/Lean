# An Exact Sign Law for the Coefficients of Ramanujan's Third Order Mock Theta Function $\rho(q)$

## Abstract

Let $\rho(q)=\sum_{m\ge 0} q^{2m(m+1)}\big/\prod_{k=0}^{m}(1+q^{2k+1}+q^{4k+2})=\sum_{n\ge 0} r(n)q^{n}$ be Ramanujan's third order mock theta function. We study the arithmetic of the integer coefficient sequence $r(n)$. Our central object is a *sign law* organized by residues modulo $3$: numerical and structural evidence indicates that $r(3n)>0$, $r(3n+1)\le 0$, and $r(3n+2)\le 0$ for all $n\ge 0$, and that the only vanishing coefficients in the two non-positive residue classes are $r(2)=r(4)=r(8)=r(11)=r(20)=0$. We identify the exact algebraic source of the modulus $3$: each denominator factor $1+q^{2k+1}+q^{4k+2}$ is the third cyclotomic-type trinomial $1+Y+Y^2$ with $Y=q^{2k+1}$, so that $(1-q^{2k+1})(1+q^{2k+1}+q^{4k+2})=1-q^{6k+3}$. This single-factor cube identity lifts to a *telescoping denominator factorization*, an exact identity valid for every partial product, and yields a closed form for the reciprocal of each factor. Using this closed form we build an exact finite model of the coefficient sequence and confirm the sign law together with the exact zero set for all $n\le 150$. We prove the telescoping factorization in full generality, discuss why it explains the modulus $3$, and formulate precise conjectures on the exact finite sign law, the unbounded linear growth of the positive class, and a representation-theoretic characterization of the sporadic zero set. The asymptotic form of the sign law is known; the exact finite statement remains open.

**Keywords:** mock theta function, $\rho(q)$, sign law, cyclotomic trinomial, telescoping product, difference of cubes, $q$-series, coefficient positivity.

---

## 1. Introduction

Among the seventeen mock theta functions Ramanujan communicated to Hardy in his last letter of 1920 are seven of "third order." One of these is
$$
\rho(q) \;=\; \sum_{m\ge 0} \frac{q^{2m(m+1)}}{\prod_{k=0}^{m}\bigl(1+q^{2k+1}+q^{4k+2}\bigr)}.
$$
Expanding each reciprocal factor as a power series and collecting terms, $\rho$ is an ordinary formal power series over the integers,
$$
\rho(q)=\sum_{n\ge 0} r(n)\,q^{n},\qquad r(n)\in\mathbb{Z}.
$$
The first coefficients are
$$
(r(n))_{n\ge 0}=1,-1,0,1,0,-1,1,-1,0,1,-1,0,2,-1,-1,1,-1,-1,2,-1,0,2,-1,-1,2,-2,-1,3,\dots
$$

The signs of these coefficients exhibit a striking regularity when read modulo $3$. This paper isolates and formalizes that regularity, exhibits the exact algebraic mechanism responsible for the modulus $3$, and organizes the resulting phenomena into a small family of precise conjectures, one of which (the asymptotic sign law) is already known while its exact finite refinement remains open.

Our contributions are:

1. **A precise statement of the exact sign law** (Section 3), including the complete determination of the sporadic zero set within the two non-positive residue classes.
2. **The telescoping denominator factorization** (Section 4, Theorems 4.1–4.2), a fully general exact identity in the polynomial ring $\mathbb{Z}[X]$ that reduces the reciprocal of each denominator factor to a two-term polynomial times a geometric series and identifies $1+Y+Y^2$ as the third cyclotomic building block.
3. **An exact finite computational model** (Section 5) of the sequence $r(n)$, based on the closed-form reciprocal, together with verification of the sign law and the exact zero set for all $n\le 150$.
4. **A structural explanation** (Section 6) of why the modulus is $3$ and why the exceptional zeros are confined to a small initial segment, and **three conjectures** (Section 7) charting the path to a complete theory.

Throughout, $\mathbb{Z}[X]$ denotes the polynomial ring in one variable $X$ over the integers, with $X$ playing the role of the formal variable $q$. We use $[q^n]F$ for the coefficient of $q^n$ in a formal power series $F$.

### 1.1 Historical and mathematical background

Mock theta functions were introduced by Ramanujan in his final 1920 letter to Hardy. He listed seventeen examples, grouped informally by "order," and asserted that each is an Eulerian $q$-series that behaves near the unit circle almost like an ordinary theta function, yet fails to be modular in the classical sense. For most of the twentieth century these functions were studied as isolated identities, with no unifying framework; a satisfactory conceptual home emerged only in the twenty-first century, when mock theta functions were recognized as the holomorphic parts of harmonic (weight $1/2$) modular forms, so that each mock theta function is completed to a genuine modular object by adding a non-holomorphic "shadow." The third order family, of which $\rho(q)$ is a member, is the most classical and the most studied.

Despite this modern structural understanding, the *arithmetic* of the coefficients of individual mock theta functions remains a rich source of concrete, elementary-looking problems. Questions about the signs, positivity, vanishing, and growth of these coefficients are frequently far harder than their statements suggest, because the coefficients are typically differences of two rapidly growing quantities and their signs reflect delicate cancellation. Sign and positivity phenomena for $q$-series coefficients — for partition-type generating functions, for theta quotients, and for mock theta functions — form a recurring theme in the subject, and results of "eventual" (asymptotic) type are common while their exact finite refinements often lie deeper. The present work fits squarely into this tradition: it isolates an exact-arithmetic strengthening of a known asymptotic phenomenon for $\rho(q)$ and exposes the elementary algebra that governs it.

What makes $\rho(q)$ especially tractable is the particular shape of its denominators. Unlike a generic Eulerian series, the denominator of the $m$-th term of $\rho$ is a product of *trinomials* $1+q^{2k+1}+q^{4k+2}$, each of which is a cyclotomic-type factor. This special structure is precisely what we exploit: it lets us replace the analytic machinery usually needed to control such coefficients by a transparent algebraic identity, at least for the purpose of exact finite computation and for explaining the governing modulus.

---

## 2. Preliminaries and notation

### 2.1 The function and its coefficients

**Definition 2.1 (Denominator factor).** For $k\ge 0$ define the *$k$-th trinomial factor*
$$
D_k(q) \;=\; 1 + q^{2k+1} + q^{4k+2}.
$$

**Definition 2.2 (Partial denominator).** For $m\ge 0$ set
$$
P_m(q) \;=\; \prod_{k=0}^{m} D_k(q) \;=\;\prod_{k=0}^{m}\bigl(1+q^{2k+1}+q^{4k+2}\bigr).
$$
Each $D_k$ has constant term $1$, so $P_m$ is invertible in the ring $\mathbb{Z}[[q]]$ of formal power series, and $\rho(q)=\sum_{m\ge 0} q^{2m(m+1)}\,P_m(q)^{-1}$ is a well-defined element of $\mathbb{Z}[[q]]$.

**Definition 2.3 (Coefficient sequence).** The integers $r(n)$ are defined by $\rho(q)=\sum_{n\ge 0}r(n)q^n$.

A crucial finiteness observation makes exact computation possible.

**Lemma 2.4 (Finite support per coefficient).** Fix $n\ge 0$. Only the terms with $2m(m+1)\le n$ contribute to $[q^n]\rho$; that is,
$$
r(n)=\sum_{m:\,2m(m+1)\le n}[q^{\,n-2m(m+1)}]\,P_m(q)^{-1}.
$$

*Proof.* The $m$-th summand is $q^{2m(m+1)}P_m(q)^{-1}$, and $P_m(q)^{-1}\in\mathbb{Z}[[q]]$ has no negative-degree terms; hence the summand contributes to $q^n$ only if $2m(m+1)\le n$. The number of such $m$ is finite because $2m(m+1)\to\infty$. $\qquad\blacksquare$

Lemma 2.4 shows that truncating every series at degree $N$ computes $r(0),\dots,r(N)$ *exactly*, not approximately: each low-degree coefficient receives all of its finitely many contributions.

### 2.2 Residue classes

We repeatedly partition the index set $\mathbb{N}$ into the three residue classes $n\equiv 0,1,2 \pmod 3$. We call $n\equiv 0$ the **positive class** and $n\equiv 1,2$ the **non-positive classes**, terminology justified by the sign law below.

---

## 3. The exact sign law

We first record the empirical/structural law in full, then explain in later sections both its algebraic origin and the current state of knowledge.

**Conjecture 3.1 (Exact sign law).** For all $n\ge 0$,
$$
r(3n) > 0,\qquad r(3n+1)\le 0,\qquad r(3n+2)\le 0.
$$
Moreover, a coefficient in a non-positive class vanishes if and only if its index lies in a finite exceptional set:
$$
r(3n+1)=0 \ \text{or}\ r(3n+2)=0 \iff n\in\{2,4,8,11,20\}.
$$
Equivalently, the complete zero set of $\rho$ is $\{2,4,8,11,20\}$, all zeros occur in the non-positive classes, and $r(m)>0$ strictly for every $m\equiv 0\pmod 3$.

**Remark 3.2 (Known vs. open).** The *asymptotic* form of the sign law — that the three inequalities of Conjecture 3.1 hold for all sufficiently large $n$ — is established through the analytic theory of the coefficients of $\rho$. What remains open is the *exact finite* statement: that the inequalities hold for **all** $n$ (no small counterexample), and that the exceptional zero set is exactly $\{2,4,8,11,20\}$. The finiteness of the zero set and its exact membership are, for each fixed range, decidable; the outstanding problem is to bridge the verified finite range to the asymptotic regime with a single positivity argument.

The rest of the paper develops the algebraic engine that (a) explains the modulus $3$, (b) enables exact verification over any finite range, and (c) points to the shape of a complete proof.

---

## 4. The telescoping denominator factorization

The key algebraic input is elementary but decisive: each trinomial factor is a difference-of-cubes cofactor.

### 4.1 The single-factor cube identity

**Theorem 4.1 (Single-factor cube identity).** In $\mathbb{Z}[X]$, for every $k\ge 0$,
$$
\bigl(1 - X^{2k+1}\bigr)\bigl(1 + X^{2k+1} + X^{4k+2}\bigr) \;=\; 1 - X^{6k+3}.
$$

*Proof.* Write $Y = X^{2k+1}$. Then $X^{4k+2}=Y^2$ and $X^{6k+3}=Y^3$, and the identity becomes the classical factorization of a difference of cubes,
$$
(1-Y)(1+Y+Y^2)=1-Y^3,
$$
which holds in any commutative ring. $\qquad\blacksquare$

**Corollary 4.2 (Closed-form reciprocal of a factor).** In $\mathbb{Z}[[q]]$,
$$
\frac{1}{1+q^{2k+1}+q^{4k+2}} \;=\; \frac{1-q^{2k+1}}{1-q^{6k+3}} \;=\; \bigl(1-q^{2k+1}\bigr)\sum_{j\ge 0} q^{(6k+3)j}.
$$

*Proof.* Divide the identity of Theorem 4.1 by $D_k(q)(1-q^{6k+3})$ and expand $1/(1-q^{6k+3})$ as a geometric series. $\qquad\blacksquare$

Corollary 4.2 is the computational heart of the paper: it replaces general power-series inversion (needed to expand $1/D_k$) by the multiplication of two *sparse* series — a two-term polynomial $1-q^{2k+1}$ and a lacunary geometric series supported on multiples of $6k+3$.

### 4.2 Lifting to the full product

**Theorem 4.3 (Telescoping denominator factorization).** In $\mathbb{Z}[X]$, for every $m\ge 0$,
$$
\Bigl(\prod_{k=0}^{m}\bigl(1 - X^{2k+1}\bigr)\Bigr)\cdot\Bigl(\prod_{k=0}^{m}\bigl(1 + X^{2k+1} + X^{4k+2}\bigr)\Bigr)
\;=\; \prod_{k=0}^{m}\bigl(1 - X^{6k+3}\bigr).
$$
Equivalently, in $\mathbb{Z}[[q]]$,
$$
P_m(q)=\prod_{k=0}^{m}\bigl(1+q^{2k+1}+q^{4k+2}\bigr)=\frac{\displaystyle\prod_{k=0}^{m}\bigl(1-q^{6k+3}\bigr)}{\displaystyle\prod_{k=0}^{m}\bigl(1-q^{2k+1}\bigr)}.
$$

*Proof.* Combine the two products on the left into a single product over $k=0,\dots,m$ of the paired terms, then apply Theorem 4.1 factor-by-factor:
$$
\prod_{k=0}^{m}\bigl(1-X^{2k+1}\bigr)\bigl(1+X^{2k+1}+X^{4k+2}\bigr)=\prod_{k=0}^{m}\bigl(1-X^{6k+3}\bigr).
$$
The series form follows by dividing by $\prod_{k=0}^{m}(1-q^{2k+1})$, which is a unit in $\mathbb{Z}[[q]]$. $\qquad\blacksquare$

**Remark 4.4 (Why the identity is robust).** Theorem 4.3 is a *ring identity*: it uses no positivity, no bound on $m$, and no analytic input. This robustness is exactly what distinguishes it from the sign law, which is only known asymptotically. The factorization survives to all $m$ because it is purely formal; the sign law does not, because it is a statement about the *signs* of the assembled coefficients, a far more delicate quantity than the algebraic shape of the denominator.

**Remark 4.5 (Where the modulus $3$ is born).** Each trinomial factor $1+q^{2k+1}+q^{4k+2}$ has exponents $0,\ 2k+1,\ 4k+2$. Reducing modulo $3$ with $a:=2k+1$ gives $\{0,\,a,\,2a\}\pmod 3$. Whenever $3\nmid a$ this is a complete residue system modulo $3$. In other words $1+Y+Y^2=(Y^3-1)/(Y-1)$ is the third cyclotomic-type building block, the algebraic shadow of the primitive cube roots of unity. The modulus $3$ in the sign law is precisely the fingerprint of these hidden cube roots.

---

## 5. An exact finite model and its verification

Corollary 4.2 turns the abstract series $\rho$ into a fully explicit finite computation. We describe the model over truncated integer power series (coefficient lists indexed by degree, truncated at degree $N$).

### 5.1 The model

Represent a truncated series by its coefficient list $[c_0,c_1,\dots,c_N]$.

- **Truncated product.** For lists $a,b$ define $(a\ast b)_n=\sum_{i=0}^{n}a_i\,b_{n-i}$ for $0\le n\le N$.
- **Two-term polynomial.** $\mathrm{OneMinus}(s)$ is the list of $1-q^{s}$: coefficient $1$ at degree $0$, $-1$ at degree $s$, else $0$.
- **Geometric series.** $\mathrm{Geom}(s)$ is the list of $\sum_{j\ge 0}q^{sj}$: coefficient $1$ at each degree divisible by $s$, else $0$ (requires $s\ge 1$).
- **Factor reciprocal.** By Corollary 4.2, $D_k^{-1}$ is modeled by $\mathrm{OneMinus}(2k+1)\ast \mathrm{Geom}(6k+3)$.
- **Partial-denominator reciprocal.** $P_m^{-1}$ is the product $\ast_{k=0}^{m} D_k^{-1}$ (nested reciprocals).
- **Assembly.** $\rho$ is modeled by $\sum_{m:\,2m(m+1)\le N} q^{2m(m+1)}\cdot P_m^{-1}$, i.e. the reciprocal $P_m^{-1}$ shifted up by $2m(m+1)$ and summed.

By Lemma 2.4 and the exactness of Corollary 4.2, the resulting list equals $[r(0),\dots,r(N)]$ *exactly*.

### 5.2 Verification

Computing the model at $N=150$ reproduces the sequence
$$
1,-1,0,1,0,-1,1,-1,0,1,-1,0,2,-1,-1,1,-1,-1,2,-1,0,2,-1,-1,2,-2,-1,3,\dots
$$
and confirms, for all $0\le n\le 150$:

- $r(3n)>0$ (positive class strictly positive, no exceptions);
- $r(3n+1)\le 0$ and $r(3n+2)\le 0$ (non-positive classes);
- the exact set of vanishing coefficients is $\{2,4,8,11,20\}$, all in non-positive classes.

The first sixty coefficients were cross-checked against a fully independent direct expansion of $\rho$ (expanding each $1/D_k$ by ordinary series inversion), with perfect agreement. This gives high confidence both in the correctness of the closed-form reciprocal (Corollary 4.2) and in the exact zero set.

**Remark 5.1 (Scope of the verification).** These are exact finite facts, not a proof of the infinite conjecture. Their role is twofold: (a) to pin the *exact* zero set, a finite decidable statement; and (b) to extend the verified range well beyond the last sporadic zero at $n=20$, sharpening confidence in the transition to strict signs.

---

## 6. Structural discussion: signs as signed counts

Why is the sign law true, and why is it hard?

Substituting the telescoping factorization (Theorem 4.3) and Corollary 4.2 into the definition of $\rho$ expresses each coefficient $r(n)$ as a **signed representation count**. Concretely, $P_m^{-1}=\prod_{k=0}^m (1-q^{2k+1})\sum_{j\ge0}q^{(6k+3)j}$, so a contribution to $q^{n}$ from the $m$-th term of $\rho$ corresponds to a choice of the numerator shift $2m(m+1)$, a subset of the "$-q^{2k+1}$" terms (each carrying a sign $-1$), and a tuple of geometric exponents $(6k+3)j_k$, summing to $n$. Each such representation contributes $\pm 1$; $r(n)$ is the net signed total.

Two features follow.

1. **Residue control.** Every exponent that can appear — $2m(m+1)$, the $2k+1$ from the polynomial factors, and the $6k+3=3(2k+1)$ from the geometric factors — has a controlled residue modulo $3$. The geometric exponents are always multiples of $3$; the numerator and polynomial exponents distribute according to the cyclotomic pattern of Remark 4.5. This is what forces the coarse mod-$3$ structure of the signs.

2. **Eventual one-signedness with a small unstable head.** The signed count is *eventually* one-signed on each class (the asymptotic sign law), but for small $n$ the $+1$ and $-1$ contributions are comparable in number and can balance exactly. A perfect balance produces a zero; a near-balance that tips the wrong way would produce a sign-law violation. Empirically, exact balances occur only at $n\in\{2,4,8,11,20\}$ — precisely where few factors participate — and no wrong-way tip ever occurs. Proving that the head is *exactly* this stable is the crux of the open problem.

This picture also explains the qualitative difference between the two kinds of statements we prove and conjecture: the telescoping factorization is a *formal* identity (Section 4), hence unconditional and general; the sign law is a *metric* statement about signed cancellation (this section), hence only asymptotically settled with a finite unverified-in-closed-form head.

**Remark 6.1 (Why finite verification is not enough).** It is tempting to regard the exact sign law as "almost proved" because it holds throughout a large computed range. But a finite computation, however extensive, can never certify an inequality that must hold for infinitely many $n$: a single late counterexample or a sixth zero far out would falsify Conjecture 3.1 without contradicting any finite check. The value of the finite verification is therefore precise and limited — it fixes the *exact* exceptional set (a decidable, finite datum) and it rules out counterexamples below the verified bound, thereby telling any prospective asymptotic argument exactly how large a threshold it is allowed to leave uncovered. In this sense the finite and asymptotic halves are complementary: the finite half handles the unstable head, the asymptotic half must handle the stable tail, and a complete proof requires the two to meet at an explicit, verified threshold.

**Remark 6.2 (On the choice of model).** The closed-form reciprocal of Corollary 4.2 is not merely a computational convenience; it is what makes the coefficient a *manifestly integer* signed count with fully explicit exponents. Any general series-inversion approach would compute the same integers but would obscure the residue structure, because the inverse of $1+q^{2k+1}+q^{4k+2}$, expanded naively, is an alternating series $1-q^{2k+1}+q^{6k+3}-q^{8k+4}+\cdots$ whose sign pattern is exactly the content of the difference-of-cubes identity. Making that identity explicit is what turns a black-box computation into an explanation.

---

## 7. Conjectures and future directions

We close with three precise conjectures, in increasing order of ambition.

**Conjecture 7.1 (Exact finite sign law).** For every $n\ge 0$, $r(3n)>0$, $r(3n+1)\le 0$, and $r(3n+2)\le 0$; the only vanishing coefficients in the two non-positive classes are $r(2)=r(4)=r(8)=r(11)=r(20)=0$, and $r(m)>0$ for every $m\equiv 0\pmod3$. This is the exact-arithmetic strengthening of the known asymptotic law; the remaining gap is a finite-range positivity argument closing the tail between the verified range and the asymptotic regime.

**Conjecture 7.2 (Unbounded linear growth of the positive class).** The subsequence $(r(3n))_{n\ge 0}$ is strictly positive for all $n$ and satisfies $r(3n)\to\infty$; more precisely $r(3n)\sim c\,n$ for an explicit constant $c>0$. The growth is *not* monotone (e.g. $r(12)=2$ while $r(15)=1$): the data show a linear main term perturbed by a bounded oscillation. As $n$ grows, the number of denominator depths $m$ with $2m(m+1)\le n$ contributing to residue class $0$ grows like $\sqrt{n}$, and the net positive mass they deposit accumulates faster than the oscillation, which suggests both the linear rate and the failure of monotonicity.

**Conjecture 7.3 (Representation-obstruction characterization of zeros).** An index $n$ with $n\not\equiv 0\pmod 3$ satisfies $r(n)=0$ if and only if the signed representation count of $n$ (by the shifted pentagonal-type data $2m(m+1)$ against the alternating factors $1-q^{2k+1}$ and geometric factors) cancels exactly; equivalently, if and only if $n\in\{2,4,8,11,20\}$. The vanishing is not accidental but reflects a perfect $+1/-1$ cancellation, possible only for small $n$ where few factors participate.

A proof of Conjecture 7.1 would likely proceed by (i) an effective asymptotic lower bound for $r(3n)$ and effective upper bounds for $r(3n+1),r(3n+2)$ valid for $n$ beyond an explicit threshold, combined with (ii) the exact finite verification past that threshold. The telescoping factorization of Section 4 is the natural starting point, since it renders each coefficient a tractable signed count and exposes the mod-$3$ structure that any such asymptotic analysis must exploit.

---

## 8. Conclusion

Ramanujan's third order mock theta function $\rho(q)$ hides a clean traffic-light pattern in the signs of its coefficients: strictly positive on indices divisible by $3$, non-positive elsewhere, with only five sporadic zeros at $n=2,4,8,11,20$. We have exhibited the exact algebraic mechanism behind the governing modulus $3$ — the difference-of-cubes identity $(1-Y)(1+Y+Y^2)=1-Y^3$ specialized to $Y=q^{2k+1}$, which telescopes the denominator into a ratio of theta-like products and gives a sparse closed form for each factor's reciprocal. This closed form yields an exact finite model confirming the sign law and the precise zero set well beyond the last exception. The asymptotic sign law is known; its exact finite refinement, the linear growth of the positive class, and the closed characterization of the zero set remain as sharp, testable conjectures.

---

## Appendix A. Data table

| $n$ | $r(n)$ | $n$ | $r(n)$ | $n$ | $r(n)$ |
|---:|---:|---:|---:|---:|---:|
| 0 | 1 | 10 | -1 | 20 | 0 |
| 1 | -1 | 11 | 0 | 21 | 2 |
| 2 | 0 | 12 | 2 | 22 | -1 |
| 3 | 1 | 13 | -1 | 23 | -1 |
| 4 | 0 | 14 | -1 | 24 | 2 |
| 5 | -1 | 15 | 1 | 25 | -2 |
| 6 | 1 | 16 | -1 | 26 | -1 |
| 7 | -1 | 17 | -1 | 27 | 3 |
| 8 | 0 | 18 | 2 | 28 | -2 |
| 9 | 1 | 19 | -1 | 29 | -1 |

The positive class ($n\equiv 0$): $1,1,1,1,2,1,2,2,2,3,\dots$ — strictly positive throughout. The zeros $2,4,8,11,20$ all lie in the non-positive classes.
