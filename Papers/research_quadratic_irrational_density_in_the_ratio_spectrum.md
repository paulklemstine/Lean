# Density of the Quadratic-Irrational Restriction Class in the Ratio Spectrum: The Topological Floor

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty (Metric number theory / Diophantine approximation)

---

## Abstract

For an integer $2\times 2$ matrix $M=\begin{pmatrix}p&q\\r&s\end{pmatrix}$ with nonzero determinant $D=ps-qr$, the linear-fractional (Möbius) action $M\cdot x=(px+q)/(rx+s)$ distorts the Lagrange constant $k(x)=\liminf_{q\to\infty} q\,\lVert qx\rVert$ of a real number $x$. The Lagarias–Shallit bounds confine the resulting **ratio spectrum** to the interval $\bigl[\tfrac{1}{|D|},|D|\bigr]$, and a density conjecture asserts that the ratios $k(Mx)/k(x)$ are *dense* in this interval as $x$ ranges over real quadratic irrational badly approximable numbers. This paper isolates and rigorously establishes the **topological and algebraic floor** of that program — the part independent of the analytic theory of $k$. We prove: (i) **domain density**, that real quadratic irrationals are dense in $\mathbb{R}$, witnessed by the explicit one-parameter family $q+\sqrt 2$ ($q\in\mathbb{Q}$); (ii) **adjugate non-degeneracy and inversion**, that the inverse Möbius map given by the adjugate matrix is well-defined on irrationals and is a genuine left inverse; and (iii) **image density**, that the Möbius image of the quadratic-irrational locus is dense in $\mathbb{R}$. We also record the determinant structure of the target interval — its endpoints are reciprocal and its midpoint contains $1$ — and the action-theoretic identities (scaling invariance, determinant multiplicativity, composition) that reduce the problem to the primitive class of $M$, and via Smith normal form to the single family $x\mapsto x/|D|$. All results are fully formalized. The remaining gap — the analytic Lagrange-constant estimate — is isolated as future work.

---

## 1. Introduction

### 1.1 Diophantine approximation and the Lagrange constant

Given a real number $x$, classical Diophantine approximation studies how closely $x$ can be approximated by rationals $p/q$ relative to the size of the denominator $q$. The sharpest single invariant capturing this is the **Lagrange constant** (also called the Markov constant, up to reciprocal conventions):

$$k(x) \;=\; \liminf_{q\to\infty} \; q\,\lVert qx\rVert, \qquad \lVert t\rVert = \operatorname{dist}(t,\mathbb{Z}).$$

A real number is **badly approximable** iff $k(x)>0$, equivalently iff its continued-fraction partial quotients are bounded. The supremum of $k$ over all irrationals is the Hurwitz constant $1/\sqrt5$, attained at the golden ratio and its $\mathrm{GL}_2(\mathbb{Z})$-translates.

### 1.2 The Möbius action and the ratio spectrum

The group $\mathrm{GL}_2(\mathbb{Z})$, and more generally the monoid of integer $2\times2$ matrices of nonzero determinant, acts on $\mathbb{R}$ by linear-fractional transformations:

$$M\cdot x \;=\; \frac{px+q}{rx+s}, \qquad M=\begin{pmatrix}p&q\\r&s\end{pmatrix}.$$

When $\det M=\pm1$ the action only edits a finite head of the continued fraction of $x$, so $k(Mx)=k(x)$. For general determinant $D=\det M$, the Lagarias–Shallit theory yields the two-sided bound

$$\frac{1}{|D|} \;\le\; \frac{k(Mx)}{k(x)} \;\le\; |D|. \tag{1.1}$$

The **ratio spectrum** of $M$ is the set
$$\Sigma(M) \;=\; \Bigl\{\, k(Mx)/k(x) \;:\; x \text{ a real quadratic irrational badly approximable number}\,\Bigr\} \;\subseteq\; \Bigl[\tfrac{1}{|D|},|D|\Bigr].$$

### 1.3 The density conjecture

> **Conjecture (Density of the ratio spectrum).** For every *primitive* integer matrix $M$ with $\det M=D\ne0$, the set $\Sigma(M)$ is dense in $\bigl[\tfrac1{|D|},|D|\bigr]$. Equivalently, for all reals $u<v$ with $\tfrac1{|D|}\le u<v\le|D|$ there exists a real quadratic irrational $x$ with $u < k(Mx)/k(x) < v$.

Here *primitive* means $\gcd(p,q,r,s)=1$, the natural normalization since the Möbius map is invariant under scaling all entries (Theorem 5.1).

### 1.4 Contribution of this paper

The conjecture decomposes into two strata:

- an **analytic stratum** controlling $k$ along periodic continued fractions (Section 8), and
- a **topological/algebraic stratum** guaranteeing that the underlying sets are rich and the action is non-degenerate.

We rigorously establish the entire topological/algebraic stratum. The principal results are:

1. **Domain density** (Theorem 3.2): real quadratic irrationals are dense in $\mathbb{R}$.
2. **Adjugate inversion** (Theorems 4.1–4.2): the adjugate Möbius map is well-defined on irrationals and is a left inverse of $M$.
3. **Image density** (Theorem 4.3): the Möbius image of the quadratic-irrational locus is dense in $\mathbb{R}$.
4. **Closure** (Theorem 2.3): the quadratic-irrational locus is invariant under the integer Möbius action.
5. **Determinant structure** (Section 5): interval geometry, scaling invariance, and the composition law that reduce the problem to the primitive class and to $\operatorname{diag}(1,|D|)$.

All statements have been formally verified.

---

## 2. Preliminaries: the Möbius action and quadratic irrationals

### 2.1 Definitions

**Definition 2.1 (Möbius action).** For integers $p,q,r,s$ and $x\in\mathbb{R}$,
$$\operatorname{mobius}(p,q,r,s)(x) \;=\; \frac{p\,x+q}{r\,x+s}.$$

**Definition 2.2 (Quadratic irrational locus).** A real number $x$ is a **quadratic irrational**, written $\operatorname{QuadIrr}(x)$, iff $x$ is irrational and there exist integers $a,b,c$ with $a\ne0$ and
$$a\,x^2 + b\,x + c = 0.$$

By Lagrange's theorem, $\operatorname{QuadIrr}(x)$ holds iff the continued fraction of $x$ is eventually periodic; every quadratic irrational is automatically badly approximable.

### 2.2 Closure of the quadratic-irrational locus

The structural prerequisite for a well-posed ratio spectrum is invariance of the restriction class under the action.

**Lemma 2.2a (Anisotropy of the transformed form).** *Let $x$ be an irrational root of $a x^2+bx+c=0$ with $a\ne0$. Then the binary quadratic form $a m^2 - b mn + c n^2$ has no nontrivial integer zero: for all $(m,n)\ne(0,0)$,*
$$a\,m^2 - b\,m\,n + c\,n^2 \;\ne\; 0.$$

*Proof sketch.* If $n=0$ the value is $a m^2\ne0$. If $n\ne0$ and the form vanished, then completing the square via the identity
$$4a\,(am^2-bmn+cn^2) = (2am-bn)^2 - (b^2-4ac)\,n^2$$
together with the root relation $4a(ax^2+bx+c)=(2ax+b)^2-(b^2-4ac)=0$ would force
$$(2ax+b)^2 = \Bigl(\tfrac{2am-bn}{n}\Bigr)^2,$$
hence $2ax+b=\pm\tfrac{2am-bn}{n}\in\mathbb{Q}$. But $2ax+b$ is irrational whenever $x$ is and $a\ne0$ (a nonzero rational multiple of an irrational plus a rational). Contradiction. $\square$

**Theorem 2.3 (Closure, `quadIrr_mobius`).** *Let $x$ be a real quadratic irrational, and let $p,q,r,s\in\mathbb{Z}$ with $D=ps-qr\ne0$ and denominator $rx+s\ne0$. Then $\operatorname{mobius}(p,q,r,s)(x)$ is again a real quadratic irrational.*

*Proof sketch.* Irrationality of the image is `irrational_mobius` (Lemma 2.4). For the quadratic relation, write $y=Mx$ and substitute the inverse relation into $ax^2+bx+c=0$; clearing the denominator $(p-ry)^2$ produces an integer quadratic in $y$ with coefficients
$$
A = a s^2 - bsr + cr^2,\quad
B = -2asq + b(sp+qr) - 2cpr,\quad
C = a q^2 - bqp + cp^2,
$$
and leading coefficient $A = a s^2 - b s r + c r^2$. By Lemma 2.2a applied to $(m,n)=(s,r)$ (which is nonzero since $D\ne0$ forces $(r,s)\ne(0,0)$), $A\ne0$, so $y$ satisfies a genuine integer quadratic. $\square$

**Lemma 2.4 (Irrationality of the image, `irrational_mobius`).** *If $x$ is irrational, $D=ps-qr\ne0$, and $rx+s\ne0$, then $\operatorname{mobius}(p,q,r,s)(x)$ is irrational.*

*Proof sketch.* If $Mx=t\in\mathbb{Q}$, then $px+q=t(rx+s)$, i.e. $(p-tr)x=ts-q$. If $p-tr\ne0$ then $x=(ts-q)/(p-tr)\in\mathbb{Q}$, contradiction. If $p-tr=0$ then $ts=q$ and one checks $D=ps-qr=0$, contradicting $D\ne0$. $\square$

---

## 3. Domain density

### 3.1 An explicit family of quadratic irrationals

**Theorem 3.1 (`quadIrr_rat_add_sqrt_two`).** *For every $q\in\mathbb{Q}$, the number $q+\sqrt2$ is a real quadratic irrational.*

*Proof sketch.* Irrationality: $\sqrt2$ is irrational, and adding a rational preserves irrationality (`Irrational.rat_add` on `irrational_sqrt_two`). The integer quadratic: write $q=e/f$ with $e=q.\mathrm{num}$, $f=q.\mathrm{den}>0$, so $(q:\mathbb{R})=e/f$. Then $x=e/f+\sqrt2$ satisfies
$$f^2\,x^2 - 2ef\,x + (e^2 - 2f^2) = 0,$$
verified by clearing denominators and using $(\sqrt2)^2=2$; the leading coefficient is $f^2\ne0$. $\square$

### 3.2 Density in $\mathbb{R}$

**Theorem 3.2 (Domain density, `quadIrr_dense`).** *For all reals $u<v$ there exists $x$ with $\operatorname{QuadIrr}(x)$ and $u<x<v$.*

*Proof sketch.* Apply density of $\mathbb{Q}$ (`exists_rat_btwn`) to the shifted interval $(u-\sqrt2,\,v-\sqrt2)$ to obtain $q\in\mathbb{Q}$ with $u-\sqrt2<q<v-\sqrt2$. Then $x=q+\sqrt2$ is a quadratic irrational (Theorem 3.1) and $u<x<v$. $\square$

The single family $q+\sqrt2$ therefore witnesses density: the *domain* of the ratio spectrum is dense in $\mathbb{R}$, eliminating the worry that the quadratic-irrational restriction is too thin.

---

## 4. The adjugate inverse and image density

### 4.1 The adjugate and its denominator

For $M=\begin{pmatrix}p&q\\r&s\end{pmatrix}$ the **adjugate** is $\operatorname{adj}M=\begin{pmatrix}s&-q\\-r&p\end{pmatrix}$, with $\det(\operatorname{adj}M)=ps-qr=\det M$. The adjugate Möbius map is $w\mapsto \operatorname{mobius}(s,-q,-r,p)(w)=\dfrac{sw-q}{-rw+p}$.

**Theorem 4.1 (Adjugate denominator, `mobius_adjugate_den_ne_zero`).** *If $w$ is irrational and $ps-qr\ne0$, then $-r\,w+p\ne0$.*

*Proof sketch.* Suppose $-rw+p=0$. If $r\ne0$ then $w=p/r\in\mathbb{Q}$, contradicting irrationality. If $r=0$ then $p=0$, but then $ps-qr=0$, contradicting $\det\ne0$. $\square$

### 4.2 Inversion

**Theorem 4.2 (Adjugate left inverse, `mobius_adjugate_left_inverse`).** *If $ps-qr\ne0$ and $-r\,w+p\ne0$, then*
$$\operatorname{mobius}(p,q,r,s)\bigl(\operatorname{mobius}(s,-q,-r,p)(w)\bigr) = w.$$

*Proof sketch.* Write $x=\dfrac{sw-q}{-rw+p}$. Then
$$Mx = \frac{p\,x+q}{r\,x+s} = \frac{p(sw-q)+q(-rw+p)}{r(sw-q)+s(-rw+p)} = \frac{(ps-qr)\,w}{ps-qr} = w,$$
where the cross terms cancel and the common factor $\det M=ps-qr\ne0$ divides out. (Formally one clears the denominator $-rw+p$ and verifies the resulting polynomial identity.) $\square$

This identity is the algebraic source of the **reciprocal-endpoint symmetry** of the target interval: $M$ and $\operatorname{adj}M$ swap the roles of $|D|$ and $1/|D|$.

### 4.3 Image density

**Theorem 4.3 (Image density, `mobius_image_dense`).** *Let $p,q,r,s\in\mathbb{Z}$ with $ps-qr\ne0$, and let $u<v$ be reals. Then there exists $x$ with $\operatorname{QuadIrr}(x)$, $r\,x+s\ne0$, and*
$$u < \operatorname{mobius}(p,q,r,s)(x) < v.$$

*Proof sketch.* By domain density (Theorem 3.2) choose a quadratic irrational $w$ with $u<w<v$. Set $x=\operatorname{mobius}(s,-q,-r,p)(w)=\dfrac{sw-q}{-rw+p}$; the denominator is nonzero by Theorem 4.1. Then:

- $x$ is a quadratic irrational by closure (Theorem 2.3) applied to $\operatorname{adj}M$, whose determinant is also $ps-qr\ne0$, with denominator nonzero by Theorem 4.1;
- $rx+s\ne0$: a direct computation expresses $rx+s$ as $\det M/(-rw+p)$ up to sign, nonzero because both factors are;
- $\operatorname{mobius}(p,q,r,s)(x)=w$ by adjugate inversion (Theorem 4.2), and $u<w<v$. $\square$

Thus the *image* of the quadratic-irrational locus under any integer matrix of nonzero determinant is dense in $\mathbb{R}$. Domain density and image density are the two halves of the topological floor; both are witnessed constructively by the family $q+\sqrt2$ transported by $M$ and $\operatorname{adj}M$.

---

## 5. Determinant structure of the target interval

The endpoints of $\Sigma(M)$'s ambient interval are governed entirely by $|D|$ and the primitive class of $M$.

**Theorem 5.0 (Interval geometry).** *Let $D=ps-qr\ne0$. Then:*

- *(`one_le_absDet`)* $1\le|D|$ (a nonzero integer has absolute value $\ge1$);
- *(`one_mem_spectrum_interval`)* $\tfrac1{|D|}\le1\le|D|$, so the midpoint value $1$ lies in the interval;
- *(`spectrum_lower_le_upper`)* $\tfrac1{|D|}\le|D|$, so the interval is nonempty;
- *(`spectrum_endpoints_mul`)* $\tfrac1{|D|}\cdot|D|=1$, the reciprocal-endpoint identity.

*Proof sketch.* All four follow from $|D|\ge1$ over $\mathbb{R}$ by elementary inequalities. $\square$

**Theorem 5.1 (Scaling invariance, `mobius_smul_invariant`).** *For $k\ne0$ and all $x$,*
$$\operatorname{mobius}(kp,kq,kr,ks)(x) = \operatorname{mobius}(p,q,r,s)(x).$$

*Proof sketch.* The common factor $k$ cancels in numerator and denominator. $\square$

Consequently the Möbius action — and hence the ratio spectrum — depends only on the **primitive class** of $M$ (divide out $\gcd(p,q,r,s)$). This justifies stating the density conjecture for primitive $M$.

**Theorem 5.2 (Determinant multiplicativity, `det_mul`).** *For the product of $\begin{pmatrix}p&q\\r&s\end{pmatrix}$ and $\begin{pmatrix}p'&q'\\r'&s'\end{pmatrix}$,*
$$(pp'+qr')(rq'+ss') - (pq'+qs')(rp'+sr') = (ps-qr)(p's'-q'r').$$

**Theorem 5.3 (Composition law, `mobius_comp`).** *With nonvanishing inner and composed denominators,*
$$\operatorname{mobius}(p,q,r,s)\bigl(\operatorname{mobius}(p',q',r',s')(x)\bigr) = \operatorname{mobius}(pp'+qr',\,pq'+qs',\,rp'+sr',\,rq'+ss')(x).$$

Theorems 5.2–5.3 say the integer matrix monoid acts on $\mathbb{R}$ by (partial) Möbius transformations with determinants multiplying. The reachable interval of a product $MN$ thus sits inside the product of the intervals of $M$ and $N$, and the spectrum can be transported along $\mathrm{GL}_2(\mathbb{Z})$ multiplications.

---

## 6. The Smith-normal-form reduction (program)

Combining scaling invariance (Theorem 5.1) and the composition law (Theorem 5.3) with the Smith normal form yields the conceptual simplification underlying the conjecture's phrasing:

> **Reduction.** Every primitive integer $2\times2$ matrix $M$ with $\det M=D$ admits $U,V\in\mathrm{GL}_2(\mathbb{Z})$ with $UMV=\operatorname{diag}(1,|D|)$. Since $\mathrm{GL}_2(\mathbb{Z})$ acts by $k$-invariant Möbius maps, $\Sigma(M)=\Sigma(\operatorname{diag}(1,|D|))$.

Primitivity (gcd of entries $=1$) forces the first elementary divisor to be $1$, so the entire spectrum problem collapses to the single one-parameter family
$$x \mapsto \operatorname{mobius}(1,0,0,D)(x) = x/D.$$
The matrix disappears, and the density conjecture becomes: *the values $k(x/D)/k(x)$ for quadratic irrational $x$ are dense in $[1/D,D]$.* The Lean development already provides the closure and action identities that make this reduction rigorous; the remaining step is the explicit Euclidean reduction to diagonal form, a finite decidable computation.

---

## 7. Algorithms

### 7.1 Numerical Lagrange constant

The Lagrange constant is computed by a finite-window approximation of the liminf:
$$\hat k_N(x) = \min_{N_0\le q\le N} q\,\lVert qx\rVert,$$
with a tail-window refinement to approximate the liminf rather than the global minimum. For quadratic irrationals with bounded partial quotients this converges to $k(x)$.

### 7.2 Quadratic-irrational witness search (constructive image density)

To realize a target $w\in(u,v)$ as $Mx$ for a quadratic irrational $x$:
1. choose rational $q$ with $u-\sqrt2<q<v-\sqrt2$, set $w=q+\sqrt2$;
2. compute $x=\operatorname{adj}M\cdot w=(sw-q_0)/(-rw+p)$ (here $q_0$ is the matrix entry);
3. return $x$; then $Mx=w\in(u,v)$ by Theorem 4.2.

This is the algorithmic content of Theorem 4.3.

---

## 8. Discussion and the remaining gap

The results above constitute a complete, verified **topological floor**: the domain is dense (Theorem 3.2), the action is invertible and non-degenerate on irrationals (Theorems 4.1–4.2), the image is dense (Theorem 4.3), and the restriction class is closed under the action (Theorem 2.3). The determinant structure (Section 5) pins the ambient interval and reduces the problem to the primitive class and to $x\mapsto x/D$.

The honest remaining gap is purely analytic: image density controls $Mx$, not yet $k(Mx)/k(x)$. Closing it requires:

- a formal definition of $k(x)$ via continued-fraction convergents and $\liminf$ over $q\to\infty$;
- the Lagarias–Shallit bound (1.1) and its $\mathrm{GL}_2(\mathbb{Z})$-invariance;
- a continuity argument: periodic continued fractions with a single large partial quotient $a$ satisfy $k(x)\approx1/a$, and inserting/deleting that quotient under division by $D$ moves the ratio continuously across $[1/D,D]$ as $a\to\infty$.

---

## 9. Future work

1. **Define $k$ and prove $\mathrm{GL}_2(\mathbb{Z})$-invariance.** Establish that $k(x)=\liminf_{q\to\infty} q\lVert qx\rVert$ is $\mathrm{GL}_2(\mathbb{Z})$-invariant and obeys $1/|D|\le k(Mx)/k(x)\le|D|$ via Smith normal form, using Mathlib's continued-fraction and `liminf` APIs.
2. **Smith normal form for $2\times2$.** Prove $UMV=\operatorname{diag}(1,|D|)$ for primitive $M$ and that $\Sigma(M)=\Sigma(\operatorname{diag}(1,|D|))$.
3. **Density for $\operatorname{diag}(1,D)$.** Show $\{k(x/D)/k(x)\}$ is dense in $[1/D,D]$ with endpoints approached but not attained, via single-large-partial-quotient periodic continued fractions.

---

## 10. Summary of formalized results

| Result | Name | Statement |
|---|---|---|
| Anisotropy | `quadForm_ne_zero` | irrational root $\Rightarrow$ $am^2-bmn+cn^2\ne0$ for $(m,n)\ne0$ |
| Image irrational | `irrational_mobius` | $Mx$ irrational for irrational $x$, $\det\ne0$ |
| Closure | `quadIrr_mobius` | $Mx$ quadratic irrational for quadratic irrational $x$ |
| Explicit family | `quadIrr_rat_add_sqrt_two` | $q+\sqrt2$ is quadratic irrational |
| Domain density | `quadIrr_dense` | quadratic irrationals dense in $\mathbb{R}$ |
| Adjugate denominator | `mobius_adjugate_den_ne_zero` | $-rw+p\ne0$ on irrationals |
| Adjugate inverse | `mobius_adjugate_left_inverse` | $M(\operatorname{adj}M\cdot w)=w$ |
| Image density | `mobius_image_dense` | $M$-image of quadratic irrationals dense in $\mathbb{R}$ |
| Interval geometry | `one_le_absDet`, `one_mem_spectrum_interval`, `spectrum_lower_le_upper`, `spectrum_endpoints_mul` | $|D|\ge1$; $1$ in interval; nonempty; reciprocal endpoints |
| Scaling invariance | `mobius_smul_invariant` | $\operatorname{mobius}(kM)=\operatorname{mobius}(M)$ |
| Multiplicativity | `det_mul` | $\det(MN)=\det M\det N$ |
| Composition | `mobius_comp` | $M\cdot(N\cdot x)=(MN)\cdot x$ |

All entries are fully formalized and verified.
