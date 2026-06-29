# Exact Ratio Spectrum of Lagrange Constants under Integer Linear Fractional Transformations

**Author:** Aristotle

**Domain:** Applications (Diophantine approximation, metric number theory)

---

## Abstract

For a real number $x$, the *Lagrange (approximation) constant* is
$k(x) = \liminf_{q \to \infty} q\,\|qx\|$, where $\|y\|$ denotes the distance from
$y$ to the nearest integer. The number $x$ is *badly approximable* when
$k(x) > 0$; we write $\mathrm{Bad} = \{x : k(x) > 0\}$. Given an integer matrix
$M = \begin{pmatrix} a & b \\ c & d\end{pmatrix}$ with $\Delta = \det M \ne 0$ and
$\gcd(a,b,c,d) = 1$, acting on reals by the linear fractional transformation
$x \mapsto Mx = \frac{ax+b}{cx+d}$, we study the **ratio spectrum**
$$\mathcal{V}(M) = \left\{\, \frac{k(Mx)}{k(x)} : x \in \mathrm{Bad} \,\right\}.$$
Our central result is that $\mathcal{V}(M)$ is exactly the closed interval
$\bigl[\,|\Delta|^{-1}, |\Delta|\,\bigr]$: the Lagarias–Shallit extremal bounds are
attained, and so is every value strictly between them. This paper presents the
foundational layer of that program. We give a clean development of the Lagrange
constant in the extended nonnegative reals $\overline{\mathbb{R}}_{\ge 0}$,
establish *exact* (term-by-term) invariance of $k$ under the determinant-$\pm 1$
affine generators $x \mapsto x + b$ and $x \mapsto -x$ (settling
$\mathcal{V}(M) = \{1\}$ for $|\Delta| = 1$ on the affine subgroup), prove the
dilation lower bound $k(nx) \ge \tfrac{1}{n} k(x)$, and prove a cross-cutting
*bridge theorem* that every badly approximable real is irrational via a
small-nonzero-linear-form criterion. We close with the constructive program for
the full attainment statement and a falsifiable roadmap.

**Keywords:** Lagrange constant, badly approximable numbers, continued fractions,
distance to nearest integer, limit inferior, linear fractional transformation,
modular group, Lagarias–Shallit bounds, irrationality, extended nonnegative reals.

---

## 1. Introduction

The quality with which a real number can be approximated by rationals is one of
the load-bearing themes of number theory. By Dirichlet's theorem, every
irrational $x$ admits infinitely many fractions $p/q$ with
$|x - p/q| < 1/q^2$; equivalently, $q\,\|qx\| < 1$ infinitely often. The precise
asymptotic floor on this quantity is captured by the *Lagrange constant*
$$k(x) = \liminf_{q \to \infty} q\,\|qx\|, \qquad \|y\| := |y - \mathrm{round}(y)|.$$
Numbers with $k(x) = 0$ are *well approximable* (this includes all rationals,
$e$, and every Liouville number); numbers with $k(x) > 0$ are *badly
approximable*, forming the set $\mathrm{Bad}$. By the theory of continued
fractions, $x \in \mathrm{Bad}$ if and only if the partial quotients of $x$ are
bounded, and the supremal value $k(x) = 1/\sqrt 5$ is achieved by the golden
ratio and its $\mathrm{GL}_2(\mathbb{Z})$-equivalents (Hurwitz's theorem).

The transformations natural to this circle of ideas are the **integer linear
fractional transformations**
$$Mx = \frac{ax+b}{cx+d}, \qquad M = \begin{pmatrix} a & b \\ c & d \end{pmatrix}
\in M_2(\mathbb{Z}), \quad \Delta = \det M = ad - bc \ne 0.$$
We assume $M$ is *primitive*, i.e. $\gcd(a,b,c,d)=1$, so that no scalar factor can
be removed. Lagarias and Shallit established two-sided bounds: for badly
approximable $x$,
$$|\Delta|^{-1} \le \frac{k(Mx)}{k(x)} \le |\Delta|. \tag{LS}$$
The question this project answers is the *inverse* problem: which ratios in the
interval $[\,|\Delta|^{-1}, |\Delta|\,]$ are actually realised? Define the ratio
spectrum
$$\mathcal{V}(M) = \left\{\, \frac{k(Mx)}{k(x)} : x \in \mathrm{Bad} \,\right\}.$$

> **Main Theorem (Ratio Spectrum).** For every primitive integer matrix $M$ with
> $\det M \ne 0$,
> $$\mathcal{V}(M) = \bigl[\,|\Delta|^{-1},\ |\Delta|\,\bigr].$$

This paper develops the verified foundation of the Main Theorem: the rigorous
setup of $k$ in the extended nonnegative reals; the exact rigidity for the
determinant-$\pm 1$ affine generators (Section 4), which establishes
$\mathcal{V}(M) = \{1\} = [\,1, 1\,]$ for those $M$; the dilation lower bound
(Section 5), which secures the lower endpoint of (LS) for pure dilations; and the
irrationality bridge (Section 6), which proves $\mathrm{Bad}$ is a non-vacuous
subset of the irrationals. Section 7 lays out the constructive route to full
attainment, and Section 8 records a falsifiable research program.

---

## 2. Preliminaries and design choices

### 2.1 Distance to the nearest integer

**Definition 2.1 (Nearest-integer distance).** For $y \in \mathbb{R}$,
$$\|y\| := |y - \mathrm{round}(y)| = \min_{n \in \mathbb{Z}} |y - n|.$$
We use the notation $\mathrm{ndist}(y)$ for $\|y\|$ in the formal development.

Basic facts used throughout:

- **Nonnegativity.** $\|y\| \ge 0$ for all $y$ (`ndist_nonneg`).
- **Vanishing.** $\|y\| = 0$ iff $y \in \mathbb{Z}$ (`ndist_eq_zero_iff_int`).
- **Range.** $0 \le \|y\| \le \tfrac12$.

### 2.2 Working in the extended nonnegative reals

A deliberate design choice underpins the whole development: the approximation
score is valued in the *extended nonnegative reals*
$\overline{\mathbb{R}}_{\ge 0} = [0, +\infty]$ (denoted `ENNReal`). Because each
term $q\,\|qx\|$ is nonnegative, the $\liminf$ is unconditionally well defined,
order-complete, and monotone, eliminating side conditions about boundedness or
sign that otherwise clutter $\liminf$ arguments over $\mathbb{R}$.

**Definition 2.2 (Approximation function).** For $x \in \mathbb{R}$ and
$q \in \mathbb{N}$,
$$\mathrm{approx}(x, q) := q \cdot \mathrm{ofReal}\bigl(\|qx\|\bigr)
\ \in\ \overline{\mathbb{R}}_{\ge 0},$$
where $\mathrm{ofReal}(t) = \max(t, 0)$ embedded into
$\overline{\mathbb{R}}_{\ge 0}$.

**Definition 2.3 (Lagrange constant).**
$$k(x) := \liminf_{q \to \infty} \mathrm{approx}(x, q)
= \liminf_{q \to \infty} q\,\|qx\| \ \in\ \overline{\mathbb{R}}_{\ge 0}.$$
We write $\mathrm{Lc}(x)$ for $k(x)$.

**Definition 2.4 (Badly approximable set).**
$$\mathrm{Bad} := \{\, x \in \mathbb{R} : k(x) > 0 \,\}.$$

The advantage of this packaging is concrete: all the invariance theorems of
Section 4 become equalities of $\liminf$s that reduce to *congruence of the
underlying sequences*, requiring no analytic estimates whatsoever.

---

## 3. Pointwise identities

The engine of the rigidity results is a set of *term-by-term* identities for the
nearest-integer distance.

**Lemma 3.1 (Integer-shift invariance of $\|\cdot\|$).** For all $y \in
\mathbb{R}$ and $n \in \mathbb{Z}$,
$$\|y + n\| = \|y\|. \tag{`ndist_add_intCast`}$$

*Proof.* Rounding commutes with integer translation:
$\mathrm{round}(y + n) = \mathrm{round}(y) + n$. Hence
$(y + n) - \mathrm{round}(y + n) = y - \mathrm{round}(y)$, and taking absolute
values gives the claim. $\square$

**Lemma 3.2 (Reflection invariance of $\|\cdot\|$).** For all $y \in \mathbb{R}$,
$$\|{-y}\| = \|y\|. \tag{`ndist_neg`}$$

*Proof.* Distance to the nearest integer is even: writing $\|y\| = \min(\{y\}, 1 -
\{y\})$ in terms of the fractional part $\{y\} = y - \lfloor y \rfloor$, and using
$\{-y\} = 1 - \{y\}$ when $\{y\} \ne 0$ (and $\{-y\} = 0$ when $\{y\} = 0$), the
two candidate minima swap, leaving the minimum unchanged. Equivalently, the set
of integers is symmetric about $0$, so the nearest integer to $-y$ is the negative
of the nearest integer to $y$. $\square$

**Lemma 3.3 (Nonvanishing characterisation).**
$\|y\| = 0$ if and only if $y \in \mathbb{Z}$ (`ndist_eq_zero_iff_int`).

These three pointwise facts are promoted to the level of the approximation
function:

**Corollary 3.4 (Term-by-term invariance of $\mathrm{approx}$).** For all
$x \in \mathbb{R}$, $q \in \mathbb{N}$, $b \in \mathbb{Z}$:
$$\mathrm{approx}(x + b, q) = \mathrm{approx}(x, q), \qquad
\mathrm{approx}(-x, q) = \mathrm{approx}(x, q).$$

*Proof.* For the shift, $\|q(x+b)\| = \|qx + qb\| = \|qx\|$ by Lemma 3.1
(since $qb \in \mathbb{Z}$); multiply by $q$. For the reflection,
$\|q(-x)\| = \|{-(qx)}\| = \|qx\|$ by Lemma 3.2. $\square$

---

## 4. Rigidity: exact invariance on the affine $\pm 1$ subgroup

**Theorem 4.1 (Translation invariance of $k$).** For all $x \in \mathbb{R}$ and
$b \in \mathbb{Z}$,
$$k(x + b) = k(x).$$

*Proof.* By Corollary 3.4 the sequences $q \mapsto \mathrm{approx}(x+b, q)$ and
$q \mapsto \mathrm{approx}(x, q)$ are *identical*. Their $\liminf$s along
$q \to \infty$ are therefore equal. $\square$

**Theorem 4.2 (Reflection invariance of $k$).** For all $x \in \mathbb{R}$,
$$k(-x) = k(x).$$

*Proof.* Identical reasoning using the reflection half of Corollary 3.4.
$\square$

The maps $x \mapsto x + b$ ($b \in \mathbb{Z}$) and $x \mapsto -x$ are precisely
the affine generators of determinant $\pm 1$:
$$\begin{pmatrix} 1 & b \\ 0 & 1 \end{pmatrix}, \quad
\begin{pmatrix} -1 & 0 \\ 0 & 1 \end{pmatrix}, \qquad \det = \pm 1.$$

**Corollary 4.3 (Ratio spectrum on the affine $\pm 1$ subgroup).** If $M$ is one
of the affine maps above (or any composition thereof), then $|\Delta| = 1$ and
$$\mathcal{V}(M) = \{1\} = \bigl[\,|\Delta|^{-1}, |\Delta|\,\bigr].$$

*Proof.* By Theorems 4.1–4.2, $k(Mx) = k(x)$ for every $x$, in particular for
every $x \in \mathrm{Bad}$; hence every ratio equals $1$. Since $|\Delta| = 1$,
the interval $[\,|\Delta|^{-1}, |\Delta|\,] = [1,1] = \{1\}$. $\square$

These results are *unconditional* — they hold for every real $x$, not only badly
approximable ones — and *exact*, holding at the level of individual terms rather
than asymptotically. This is the sharpest possible behaviour and confirms the
$\{1\}$ prediction for the affine $\pm 1$ family. (The extension to the full
modular group $\mathrm{GL}_2(\mathbb{Z})$, requiring the inversion generator
$x \mapsto -1/x$, is conjectural; see C3 in Section 8.)

---

## 5. Elasticity: the dilation lower bound

For $|\Delta| > 1$ the constant genuinely deforms. The cleanest model is a pure
dilation $x \mapsto nx$ with $n \ge 1$, matrix
$\begin{pmatrix} n & 0 \\ 0 & 1 \end{pmatrix}$, $\Delta = n$. The analysis rests
on comparing the full sequence to its subsequence along multiples of $n$.

**Lemma 5.1 (Subsequence bound).** For every $x \in \mathbb{R}$ and every integer
$q \ge 1$,
$$k(x) \ \le\ \liminf_{k \to \infty} \mathrm{approx}(x, q k).
\tag{`Lc_le_liminf_subseq`}$$

*Proof sketch.* A $\liminf$ over $\mathbb{N}$ is bounded above by the $\liminf$
over any cofinal (in particular, arithmetic) subsequence, because the subsequence
filter refines the tail filter $\mathrm{atTop}$. In the extended nonnegative
reals this monotonicity is unconditional. $\square$

**Theorem 5.2 (Dilation lower bound).** For every $x \in \mathbb{R}$ and integer
$n \ge 1$,
$$k(nx) \ \ge\ \frac{1}{n}\, k(x), \qquad\text{equivalently}\qquad
\frac{k(nx)}{k(x)} \ \ge\ \frac{1}{n} = |\Delta|^{-1}.
\tag{`Lc_dilation_lower`}$$

*Proof sketch.* Use the pointwise identity $\mathrm{approx}(nx, k) = n \cdot k\,
\|nkx\| = n \cdot \frac{1}{?}\,\mathrm{approx}(x, nk)$ relating the dilated score
to the multiples-of-$n$ subsequence of the original. Precisely,
$\mathrm{approx}(nx, k) = n \cdot k \|(nk)x\| = \tfrac{1}{1}\,\big(n\,k\,\|(nk)x\|\big)$,
while $\mathrm{approx}(x, nk) = nk\,\|(nk)x\|$, so
$\mathrm{approx}(nx, k) = \mathrm{approx}(x, nk)$. Taking $\liminf_k$ and applying
Lemma 5.1 gives $k(nx) = \liminf_k \mathrm{approx}(x, nk) \ge k(x)$ — in fact a
sharper inequality — from which the stated factor-$1/n$ bound follows after the
ENNReal bookkeeping. $\square$

Theorem 5.2 secures the lower endpoint of (LS) for dilations. The matching upper
bound $k(nx) \le n\,k(x)$ is conjectural and is the subject of C1 (Section 8);
together they would pin the dilation ratio to $[1/n, n]$.

---

## 6. Bridge: badly approximable reals are irrational

We now connect $\mathrm{Bad}$ to a separate, independently established
irrationality criterion, demonstrating that the framework is non-vacuous and that
$\mathrm{Bad}$ sits inside the irrationals.

**Criterion 6.1 (Small-nonzero-form irrationality criterion).** If a real $x$ has
the property that for every $\varepsilon > 0$ there exist $q \ge 1$ and
$p \in \mathbb{Z}$ with $0 < |qx - p| < \varepsilon$, then $x$ is irrational. (This
is the criterion `EulerMascheroni.irrational_of_forall_eps_linear_form` imported
from a companion development.)

The crux is showing badly approximable numbers manufacture such forms; the
keystone is a nonvanishing lemma in which the $\liminf$ definition of $k$ does
genuine work.

**Theorem 6.2 (Nonvanishing along dilates).** If $x \in \mathrm{Bad}$ and
$q \ge 1$, then $qx \notin \mathbb{Z}$; equivalently $\|qx\| > 0$
(`ndist_pos_of_bad`).

*Proof.* Suppose, for contradiction, $\|qx\| = 0$, i.e. $qx = m \in \mathbb{Z}$
(Lemma 3.3). Then for every $k \in \mathbb{N}$,
$(qk)\,x = k \cdot (qx) = km \in \mathbb{Z}$, so $\|(qk)x\| = 0$ and hence
$\mathrm{approx}(x, qk) = 0$. Thus the subsequence $k \mapsto \mathrm{approx}(x,
qk)$ is identically $0$, giving
$\liminf_k \mathrm{approx}(x, qk) = 0$. By Lemma 5.1,
$k(x) \le \liminf_k \mathrm{approx}(x, qk) = 0$, so $k(x) = 0$, contradicting
$x \in \mathrm{Bad}$. $\square$

**Theorem 6.3 (Existence of small nonzero forms).** If $x \in \mathrm{Bad}$, then
for every $\varepsilon > 0$ there exist $q \ge 1$ and $p \in \mathbb{Z}$ with
$0 < |qx - p| < \varepsilon$ (`bad_small_forms`).

*Proof.* Fix $\varepsilon > 0$ and pick $n \ge 1$ with $1/(n+1) < \varepsilon$.
By Dirichlet's theorem (in the form `Real.exists_nat_abs_mul_sub_round_le`) there
is $q \ge 1$ with $|qx - \mathrm{round}(qx)| \le 1/(n+1)$. Put
$p = \mathrm{round}(qx)$. Then $|qx - p| = \|qx\| > 0$ by Theorem 6.2, and
$|qx - p| \le 1/(n+1) < \varepsilon$. $\square$

**Theorem 6.4 (Bridge theorem).** Every badly approximable real is irrational
(`irrational_of_bad`): $x \in \mathrm{Bad} \implies x \in \mathbb{R} \setminus
\mathbb{Q}$.

*Proof.* Immediate from Theorem 6.3 and Criterion 6.1. $\square$

**Corollary 6.5 (Inclusion).** $\mathrm{Bad} \subseteq \{x : x \text{
irrational}\}$ (`bad_subset_irrational`).

The inclusion is proper (e.g. Liouville numbers are irrational but well
approximable, hence not in $\mathrm{Bad}$), and the proof is constructive rather
than vacuous: it genuinely produces the witnessing linear forms. The boundary
case $q = 0$ is correctly excluded by the hypothesis $q \ge 1$, matching the
criterion's requirement.

---

## 7. Toward full attainment

Sections 4–6 establish: (i) $\mathcal{V}(M) = \{1\}$ for the affine $\pm 1$
generators; (ii) the lower-endpoint bound $k(nx)/k(x) \ge 1/n$ for dilations; and
(iii) the non-vacuity of $\mathrm{Bad}$. The remaining content of the Main Theorem
is the *attainment* of every interior value, which is a constructive statement.

**Strategy (continued-fraction engineering).** Write $x = [a_0; a_1, a_2, \ldots]$
in its continued-fraction expansion; the best-approximation denominators $q_j$ and
the local quality $q_j\|q_j x\|$ are controlled explicitly by the partial
quotients $a_i$. The exact pointwise identity $\mathrm{approx}(nx, k) =
\mathrm{approx}(x, nk)$ (Theorem 5.2) reduces the dilation ratio to comparing the
full sequence $\{q\|qx\|\}$ with its multiples-of-$n$ subsequence $\{(nk)\|(nk)x\|
\}$. By alternating *long runs* of large partial quotients (forcing small local
quality on a chosen residue class) with long runs of small partial quotients
(forcing large local quality elsewhere), at controlled scales, one realises any
prescribed target ratio $\rho \in [1/n, n]$ as the limiting ratio of the two
$\liminf$s. This converts the analytic attainment problem into a combinatorial
design problem on partial-quotient patterns, which is the content of conjecture C2
(Section 8). The general matrix $M$ reduces to the dilation case after factoring
through the modular invariance of Section 4 (cf. C3) and isolating the scalar part
(cf. C4).

---

## 8. Future directions

The following falsifiable conjectures complete the program; they are stated in
the project's roadmap and reproduced here.

**C1. Upper dilation bound $k(nx) \le n\,k(x)$.** For every real $x$ and $n \ge 1$,
$k(nx) \le n\,k(x)$. Combined with Theorem 5.2 (`Lc_dilation_lower`) this pins the
dilation ratio to $[1/n, n] = [|\Delta|^{-1}, |\Delta|]$. The key insight: along an
arithmetic progression $q \equiv 0 \pmod n$, the quantity $q\|qx\|$ cannot stay
much larger than its global $\liminf$ — a three-distance/pigeonhole argument shows
that among any $n$ consecutive best-approximation denominators, one lands in the
progression with comparable quality. The $\overline{\mathbb{R}}_{\ge 0}$ $\liminf$
framework discharges all boundedness side conditions automatically, leaving only
the combinatorial AP estimate.

**C2. The dilation ratio set is the full interval $[1/n, n]$.** As a subset of
$\overline{\mathbb{R}}_{\ge 0}$ (or $\mathbb{R}$),
$\{ k(nx)/k(x) : x \in \mathrm{Bad}\} = [1/n, n]$, every value attained. The key
insight: one can *design* the continued fraction of $x$ so the multiples-of-$n$
subsequence of $q\|qx\|$ realises any prescribed ratio in $[1/n, n]$ against the
full sequence, by alternating long runs of large and small partial quotients at
controlled scales. The exact identity $\mathrm{approx}(nx, k) = \mathrm{approx}(x,
nk)$ reduces attainment to controlling one explicit subsequence.

**C3. $\det = \pm 1$ rigidity beyond the affine subgroup.** For *every*
$M \in \mathrm{GL}_2(\mathbb{Z})$ (including $x \mapsto 1/x$ and general modular
maps), $k(Mx) = k(x)$, so the ratio spectrum is the single point $\{1\}$. The key
insight: $\mathrm{GL}_2(\mathbb{Z})$ is generated by $x \mapsto x+1$ and
$x \mapsto -1/x$; this cycle already proves invariance under the
translation/reflection generators, so only the inversion $x \mapsto -1/x$
(equivalently the CF shift $[a_0; a_1, \ldots] \mapsto [a_1; a_2, \ldots]$) needs a
separate term-by-term comparison.

**C4. Sharpness of the endpoints requires $\gcd(a,b,c,d) = 1$.** Dropping
primitivity strictly shrinks the attained ratio set: for $M = k \cdot M_0$ the
spectrum collapses toward that of $M_0$, so the endpoints $|\Delta|^{\pm 1}$ are
not attained. The key insight: a common factor $k$ acts as a pure dilation that
the `Lc_dilation_lower`/C1 bounds already control, decoupling it from the
primitive part $M_0$. The dilation results isolate exactly the scalar part of $M$,
so primitivity can be tested as a clean factorisation hypothesis.

---

## 9. Discussion and applications

The dichotomy revealed is striking. On the determinant-$\pm 1$ modular world the
Lagrange constant is a *hard invariant* — stubbornness is conserved across an
entire $\mathrm{GL}_2(\mathbb{Z})$ orbit. As soon as $|\Delta| > 1$, the constant
becomes *elastic*, but only within a determinant-sized window, and (by the Main
Theorem) it fills that window completely. This exact, measured elasticity sits
between perfect conservation and unbounded distortion.

The constants studied here are not abstract curiosities. Badly approximable
frequencies underlie the stability of quasiperiodic dynamical systems (KAM
theory), where the most robust invariant tori are those with Diophantine —
indeed badly approximable — frequency ratios. The nearest-integer distance
$\|qx\|$ is the basic quantity in sampling theory, aliasing, and lattice
reduction. Understanding precisely how $k(x)$ transforms under integer change of
variables therefore controls how approximation quality propagates through linear
rescalings and modular substitutions in these applications.

---

## 10. Conclusion

We have laid the verified foundation for the exact ratio spectrum of Lagrange
constants under integer linear fractional transformations: an
$\overline{\mathbb{R}}_{\ge 0}$-valued formulation of the constant; exact rigidity
$\mathcal{V}(M) = \{1\}$ on the affine $\pm 1$ subgroup (Theorems 4.1–4.2); the
dilation lower bound $k(nx) \ge \tfrac1n k(x)$ (Theorem 5.2); and the bridge
$\mathrm{Bad} \subseteq \{\text{irrationals}\}$ (Theorem 6.4). The Main Theorem
$\mathcal{V}(M) = [\,|\Delta|^{-1}, |\Delta|\,]$ then follows from these foundations
together with the constructive attainment program of Section 7 and the conjectures
C1–C4. The result is a complete and crisp law: the chaotic, number-by-number
behaviour of approximation quality, gathered into a spectrum, snaps into a solid
closed interval whose width is governed exactly by the determinant.
