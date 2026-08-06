# Bishop's Constructive Analysis with Explicit Moduli: Completeness, the Intermediate Value Theorem, and Sharp Constants

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

We present a self-contained quantitative development of Errett Bishop's constructive real analysis, organised around the principle that every existence claim must be accompanied by an explicit modulus. Real numbers are taken to be *regular sequences of rationals*, sequences $x : \mathbb{N} \to \mathbb{Q}$ satisfying $|x_m - x_n| \le \frac{1}{m+1} + \frac{1}{n+1}$, so that the modulus of Cauchyness is part of the datum rather than an object produced by a non-effective search. We establish: (i) the explicit approximation bound $|\hat x - x_n| \le \frac{1}{n+1}$ relating a regular sequence to the classical real it denotes; (ii) the equivalence of Bishop equality $|x_n - y_n| \le \frac{2}{n+1}$ with equality of denoted reals, whence the quotient of regular sequences by Bishop equality is in canonical bijection with $\mathbb{R}$; (iii) constructive completeness by the shifted diagonal $n \mapsto x^{(2n+1)}_{2n+1}$, together with the error estimate $|L - \hat x^{(k)}| \le \frac{1}{k+1}$, and an explicit family showing that the shift cannot be removed; (iv) the witnessed order relation, its extensional agreement with the classical order, an explicit cotransitivity algorithm requiring one rational comparison at any index $m$ with $\frac{1}{m+1} \le \frac{g}{8}$ where $g$ is the certified rational gap, and the impossibility of any uniform bound on the witness index; (v) the approximate intermediate value theorem by an explicit finite grid search, and the exact intermediate value theorem under a positive slope bound $c$, with root modulus $\delta \mapsto \omega(c\delta)$ and the sharp displacement estimate $|x - r| \le \varepsilon / c$; (vi) a Brouwerian counterexample — Bishop's shelf family — showing that no continuous, hence no constructive, root selector exists, strengthened to the statement that *every* root selector has oscillation at least $1$ in every neighbourhood of the critical parameter; (vii) a bracketing refinement showing that the sign-change grid search locates a genuine root to within one mesh *without any non-degeneracy hypothesis*, together with an explicit function proving that Bishop's local non-constancy hypothesis is by itself insufficient for any "small value implies near a root" principle; and (viii) the constructive least upper bound principle for located sets via a trisection search with exact geometric rate $(2/3)^n$, together with a complete analysis of the general one-query search: the contraction factor of the scheme with query fractions $\alpha < \beta$ is exactly $\max(\beta, 1-\alpha)$, trisection is therefore not optimal, and the optimal contraction factor of a one-query located search is the infimum $\tfrac12$, which is never attained.

**Keywords:** constructive analysis, Bishop reals, regular sequences, explicit modulus, intermediate value theorem, Brouwerian counterexample, located sets, cotransitivity, computable reals.

---

## 1. Introduction

### 1.1 The problem of effective content

Classical analysis proves existence statements. It proves that a Cauchy sequence converges, that a continuous function changing sign has a root, that a bounded set has a supremum. What it typically does not do is say *how* — at what rate, from what index, with what precision. For most mathematical purposes this is harmless. For any purpose in which the objects must be produced rather than merely contemplated, it is fatal.

The gap is easy to locate precisely. The classical definition of a Cauchy sequence reads
$$\forall \varepsilon > 0 \; \exists N \; \forall m, n \ge N : |x_m - x_n| < \varepsilon,$$
and the object $N$ — the *modulus of convergence* — is bound by an unrestricted existential quantifier. A classical proof may produce that $N$ by any means whatsoever, including by an appeal to excluded middle over an undecidable predicate. There is then no function $\varepsilon \mapsto N(\varepsilon)$ available, and no way to compute the limit to a prescribed accuracy.

Bishop's response, developed in *Foundations of Constructive Analysis* (1967) and its revision with Bridges (*Constructive Analysis*, 1985), was to relocate the modulus from the conclusion into the datum. This paper carries that programme out for the core of elementary real analysis, and pushes it one step further: once every constant is explicit, one can ask whether the constants are *optimal*, and in several cases we answer.

### 1.2 What is new here

Much of the content below is Bishop's, restated with full quantitative detail. The following results are, to our knowledge, either new or not standard in the literature, and they are the ones we regard as the contribution of this paper:

1. **Necessity of the diagonal shift.** An explicit family of regular sequences of reals for which the unshifted diagonal $n \mapsto x^{(n)}_n$ fails regularity, at the concrete indices $m=0$, $n=1$ (Theorem 4.4).
2. **Sharpness of the root modulus.** The displacement bound $|x - r| \le \varepsilon/c$ is attained, and no constant $\kappa < 1$ may replace the implicit $1$ (Theorems 7.6, 7.7).
3. **Quantitative failure of the exact intermediate value theorem.** Every root selector for the shelf family, continuous or not, has oscillation at least $1$ on every neighbourhood of the critical parameter (Theorem 8.4).
4. **Bracketing beats bounding.** The sign-change grid search locates a genuine root to within one mesh with no non-degeneracy hypothesis (Theorem 9.1); and local non-constancy, even with an explicit modulus, supports no "small value implies near a root" principle (Theorem 9.3).
5. **The optimal one-query contraction ratio.** The contraction factor of the general one-query located search is exactly $\max(\beta, 1-\alpha)$; trisection's $2/3$ is not optimal; the infimum over all one-query schemes is $\tfrac12$, and it is not attained (Theorems 11.2, 11.3, 11.4).
6. **No uniform witness bound for the order.** For every $N$ there are Bishop reals $x < y$ with no witness index $\le N$ (Theorem 6.6).

### 1.3 Conventions

Throughout, $\mathbb{Q}$ and $\mathbb{R}$ denote the rationals and the classical reals. We work in a classical metatheory: our theorems are classical statements *about* constructive data, and we make the comparison with classical analysis explicit rather than tacit. This is the standard way to make sharpness claims precise — one wants to prove, for instance, that no constant below $1$ works, and such a statement is naturally a classical one about the space of all functions.

We write $\hat x$ for the classical real denoted by a regular sequence $x$, and $x_n$ for its $n$-th rational approximation.

---

## 2. Regular sequences of rationals

### 2.1 The definition

**Definition 2.1 (regular sequence).** A **regular sequence of rationals**, or **Bishop real**, is a sequence $x : \mathbb{N} \to \mathbb{Q}$ satisfying
$$|x_m - x_n| \;\le\; \frac{1}{m+1} + \frac{1}{n+1} \qquad \text{for all } m, n \in \mathbb{N}.$$

The intended reading: $x_n$ is an approximation, accurate to within $1/(n+1)$, of the number the sequence denotes; the inequality expresses that these accuracy claims are mutually consistent. The essential point is that the modulus is *fixed by the definition*, not obtained by a search. No choice principle and no non-effective extraction is involved. If the function $n \mapsto x_n$ is computable, the real number is a computable object in the most concrete sense: a program that on input $n$ outputs a rational within $1/(n+1)$ of the intended value.

(Bishop indexes from $1$ with bound $\frac1m + \frac1n$; the shift to $\frac{1}{m+1} + \frac{1}{n+1}$ is a matter of avoiding division by zero and changes nothing.)

**Lemma 2.2.** The real sequence $n \mapsto x_n$ (regarded in $\mathbb{R}$) is Cauchy, with $|x_n - x_m| \le \frac{2}{N+1}$ whenever $n, m \ge N$.

*Proof.* Immediate from Definition 2.1 and the monotonicity of $t \mapsto 1/(t+1)$. $\square$

**Definition 2.3.** $\hat x := \lim_{n} x_n \in \mathbb{R}$, the classical real **denoted** by $x$.

### 2.2 The explicit approximation bound

**Theorem 2.4 (explicit modulus).** For every regular sequence $x$ and every $n$,
$$|\hat x - x_n| \;\le\; \frac{1}{n+1}.$$

*Proof sketch.* Fix $n$ and let $j \to \infty$ in the regularity inequality $|x_j - x_n| \le \frac{1}{j+1} + \frac{1}{n+1}$. The left side converges to $|\hat x - x_n|$ by continuity of $t \mapsto |t - x_n|$; the right side converges to $\frac{1}{n+1}$. Weak inequalities are preserved in the limit. $\square$

This is the theorem that makes the whole development usable: to compute $\hat x$ to accuracy $\varepsilon$ it suffices to evaluate $x_n$ for any $n \ge \lceil 1/\varepsilon \rceil$. There is no search and no waiting phase.

The following converse is the standard tool for identifying the real denoted by a constructed sequence.

**Theorem 2.5 (identification criterion).** Let $x$ be a regular sequence, $r \in \mathbb{R}$ and $C \ge 0$. If $|x_n - r| \le \frac{C}{n+1}$ for all $n$, then $\hat x = r$.

*Proof sketch.* By Theorem 2.4 and the triangle inequality, $|\hat x - r| \le \frac{1+C}{n+1}$ for every $n$; letting $n \to \infty$ gives $|\hat x - r| = 0$. $\square$

### 2.3 Equality

Constructively one cannot define $x = y$ as $\hat x = \hat y$: the limits are not antecedently available, only the sequences are. Bishop therefore defines equality on the data.

**Definition 2.6 (Bishop equality).** Regular sequences $x, y$ are **equal**, written $x \approx y$, if
$$|x_n - y_n| \;\le\; \frac{2}{n+1} \qquad \text{for all } n.$$

The tolerance $2/(n+1)$ is forced: it is the sum of the two error bars, so it is the largest tolerance under which two sequences denoting the same number are guaranteed to satisfy the condition, and the smallest under which they always do.

**Theorem 2.7.** $x \approx y$ if and only if $\hat x = \hat y$.

*Proof sketch.* ($\Rightarrow$) By two applications of Theorem 2.4 and one of the hypothesis,
$$|\hat x - \hat y| \le |\hat x - x_n| + |x_n - y_n| + |y_n - \hat y| \le \frac{1}{n+1} + \frac{2}{n+1} + \frac{1}{n+1} = \frac{4}{n+1}$$
for every $n$; let $n \to \infty$. ($\Leftarrow$) Conversely $|x_n - y_n| \le |x_n - \hat x| + |\hat y - y_n| \le \frac{2}{n+1}$ using $\hat x = \hat y$. $\square$

**Corollary 2.8.** $\approx$ is an equivalence relation.

Transitivity is not a triviality in this setting — it is the classical "$3\varepsilon$" argument, and it is exactly what Theorem 2.7 packages. We write $\mathbf{R}_{\mathrm{B}}$ for the quotient of regular sequences by $\approx$.

### 2.4 Nothing is lost

**Theorem 2.9 (surjectivity).** Every $r \in \mathbb{R}$ is denoted by some regular sequence.

*Proof sketch.* For each $n$ choose $q_n \in \mathbb{Q}$ with $|r - q_n| < \frac{1}{2(n+1)}$ (density of $\mathbb{Q}$). Then
$$|q_m - q_n| \le |q_m - r| + |r - q_n| < \frac{1}{2(m+1)} + \frac{1}{2(n+1)} \le \frac{1}{m+1} + \frac{1}{n+1},$$
so $q$ is regular, and by Theorem 2.5 (with $C = 1$) it denotes $r$. $\square$

**Theorem 2.10 (comparison with classical analysis).** The map $[x] \mapsto \hat x$ is a bijection $\mathbf{R}_{\mathrm{B}} \to \mathbb{R}$.

*Proof.* Well-definedness and injectivity are Theorem 2.7; surjectivity is Theorem 2.9. $\square$

Theorem 2.10 is the precise sense in which constructive analysis is not a theory of *fewer* numbers. It is the same numbers, presented with more information; what differs is the admissible operations on that presentation.

---

## 3. Computable arithmetic

Each arithmetic operation must be defined so that the result is again regular, and the index shifts required are the quantitative heart of the matter.

**Definition 3.1 (rational constants and negation).** For $q \in \mathbb{Q}$, the constant sequence $(q)_n = q$ is regular and denotes $q$. For a regular $x$, $(-x)_n = -x_n$ is regular and denotes $-\hat x$.

**Definition 3.2 (addition).** $(x + y)_n := x_{2n+1} + y_{2n+1}$.

**Proposition 3.3.** $x + y$ is regular and denotes $\hat x + \hat y$.

*Proof sketch.* $|(x+y)_m - (x+y)_n| \le |x_{2m+1} - x_{2n+1}| + |y_{2m+1} - y_{2n+1}| \le 2\left(\frac{1}{2(m+1)} + \frac{1}{2(n+1)}\right) = \frac{1}{m+1} + \frac{1}{n+1}$, using $(2k+1)+1 = 2(k+1)$. The identification of the limit is Theorem 2.5. $\square$

The shift $n \mapsto 2n+1$ is exactly the halving of the error budget needed to accommodate two summands.

Multiplication requires a bound on the factors, since errors are amplified multiplicatively.

**Definition 3.4 (canonical bound).** $B(x) := \lceil |x_0| \rceil + 2$, where $\lceil \cdot \rceil$ is the ceiling into $\mathbb{N}$.

**Lemma 3.5.** $|x_n| \le B(x)$ for all $n$.

*Proof.* $|x_n| \le |x_0| + |x_n - x_0| \le |x_0| + \frac{1}{n+1} + 1 \le \lceil|x_0|\rceil + 2$. $\square$

**Definition 3.6 (multiplication).** With $M := B(x) + B(y)$ and the index map $\mu(n) := M(n+1)$,
$$(x \cdot y)_n := x_{\mu(n)} \cdot y_{\mu(n)}.$$

**Proposition 3.7.** $x \cdot y$ is regular and denotes $\hat x \, \hat y$.

*Proof sketch.* Write $ab - a'b' = a(b - b') + b'(a - a')$ with $a = x_{\mu(m)}$ etc.; bound $|a|, |b'|$ by $B(x), B(y)$ and each difference by the regularity of $x$, $y$. The resulting bound is $M\left(\frac{1}{\mu(m)+1} + \frac{1}{\mu(n)+1}\right)$, and the arithmetic inequality $M \cdot \frac{1}{M(n+1)+1} \le \frac{1}{n+1}$ closes the estimate. $\square$

The shift is proportional to the magnitude of the factors — larger numbers require more precision before their product is trustworthy — which is the correct behaviour of a floating-point-free exact arithmetic.

**Example 3.8 (a computable irrational).** Define
$$\sqrt2_n \;:=\; \frac{\lfloor \sqrt{2(n+1)^2} \rfloor}{n+1} \in \mathbb{Q},$$
the numerator being the integer square root. Then $\sqrt2$ is a regular sequence, $\widehat{\sqrt 2}^{\,2} = 2$, and its terms are literally computable: $\sqrt2_4 = 7/5$ and $\sqrt2_{99} = 141/100$.

*Proof sketch.* The integer square root satisfies $s \le \sqrt{2m^2} < s+1$ with $s = \lfloor\sqrt{2m^2}\rfloor$, hence $|s/m - \sqrt2| \le 1/m$; with $m = n+1$ this gives $|\sqrt2_n - \sqrt2| \le \frac{1}{n+1}$, from which regularity follows by the triangle inequality through $\sqrt 2$, and the identification by Theorem 2.5. $\square$

---

## 4. Constructive completeness

**Definition 4.1.** A sequence $x^{(0)}, x^{(1)}, \ldots$ of Bishop reals is a **regular sequence of reals** if
$$\bigl|\hat x^{(k)} - \hat x^{(l)}\bigr| \le \frac{1}{k+1} + \frac{1}{l+1} \qquad \text{for all } k, l.$$

Any Cauchy sequence with a known modulus can be reindexed into this normal form, so the definition costs no generality.

**Theorem 4.2 (constructive completeness).** Let $x^{(\bullet)}$ be a regular sequence of reals. Then
$$L_n \;:=\; x^{(2n+1)}_{\,2n+1}$$
defines a regular sequence of rationals, and its denoted real $\hat L$ satisfies the explicit estimate
$$\bigl|\hat L - \hat x^{(k)}\bigr| \;\le\; \frac{1}{k+1} \qquad \text{for every } k.$$

*Proof sketch.* Regularity: by Theorem 2.4, $|x^{(2j+1)}_{2j+1} - \hat x^{(2j+1)}| \le \frac{1}{2j+2} = \frac{1}{2}\cdot\frac{1}{j+1}$. Hence
$$|L_m - L_n| \le \tfrac12\tfrac{1}{m+1} + \bigl|\hat x^{(2m+1)} - \hat x^{(2n+1)}\bigr| + \tfrac12\tfrac{1}{n+1} \le \tfrac12\tfrac{1}{m+1} + \left(\tfrac12\tfrac{1}{m+1} + \tfrac12\tfrac{1}{n+1}\right) + \tfrac12\tfrac{1}{n+1},$$
which is exactly $\frac{1}{m+1} + \frac{1}{n+1}$. The rate: for any $n$,
$$|\hat L - \hat x^{(k)}| \le |\hat L - L_n| + |L_n - \hat x^{(2n+1)}| + |\hat x^{(2n+1)} - \hat x^{(k)}| \le \frac{1}{n+1} + \frac{1}{2(n+1)} + \frac{1}{2(n+1)} + \frac{1}{k+1},$$
and letting $n \to \infty$ leaves $\frac{1}{k+1}$. $\square$

Note that the *shifted diagonal* is not an artefact of the proof; the following family shows it is forced.

**Definition 4.3 (the witness family).** For $k \in \mathbb{N}$ let
$$w^{(k)}_n \;:=\; \frac{1}{k+1} + (-1)^k \cdot \frac{1}{n+1}.$$

Each $w^{(k)}$ is regular (the difference of two of its terms is $\pm\left(\frac{1}{m+1} - \frac{1}{n+1}\right)$, of absolute value at most $\max$ of the two, hence at most their sum), and $\hat w^{(k)} = \frac{1}{k+1}$. Since $\left|\frac{1}{k+1} - \frac{1}{l+1}\right| \le \frac{1}{k+1} + \frac{1}{l+1}$, the family is a regular sequence of reals.

**Theorem 4.4 (the diagonal shift is necessary).** For the family $w^{(\bullet)}$, the *unshifted* diagonal $n \mapsto w^{(n)}_n$ is **not** a regular sequence: at $m = 0, n = 1$ its terms differ by $2$, whereas regularity permits at most $\frac{1}{1} + \frac{1}{2} = \frac32$.

*Proof.* $w^{(0)}_0 = 1 + 1 = 2$ and $w^{(1)}_1 = \frac12 - \frac12 = 0$. $\square$

**Theorem 4.5.** For the same family, the shifted diagonal converges to the correct limit: $\hat L = 0 = \lim_k \hat w^{(k)}$.

*Proof sketch.* By Theorem 4.2, $|\hat L - \frac{1}{k+1}| \le \frac{1}{k+1}$ for every $k$, so $|\hat L| \le \frac{2}{k+1} \to 0$. $\square$

The lesson is general: a constructive completeness theorem is a *formula*, and the formula must budget the two independent sources of error — the error of the $k$-th member as an approximation to the limit, and the error of its own $n$-th approximation — against a single allowance $1/(n+1)$. The factor $2$ is exactly the cost of two sources.

---

## 5. Continuity with an explicit modulus

**Definition 5.1.** A function $\omega : (0,\infty) \to (0,\infty)$ is a **modulus of uniform continuity** for $f$ on a set $S$ if for every $\varepsilon > 0$ we have $\omega(\varepsilon) > 0$ and
$$x, y \in S, \; |x - y| \le \omega(\varepsilon) \;\Longrightarrow\; |f(x) - f(y)| \le \varepsilon.$$

This is Bishop's definition of a continuous function on a compact interval: not the assertion that a tolerance exists, but a function producing it. Classically it is strictly stronger than continuity pointwise but coincides with uniform continuity on compacta; the point is the *presentation*.

**Proposition 5.2.** A function with a modulus of uniform continuity on $S$ is continuous on $S$.

Every $1$-Lipschitz function has the modulus $\omega = \mathrm{id}$; the linear function $x \mapsto cx$ ($c > 0$) has the modulus $\omega(\varepsilon) = \varepsilon/c$ and, as we shall use repeatedly, the slope bound $c$ of Definition 7.3.

---

## 6. The constructive order

### 6.1 Witnessed positivity

**Definition 6.1.** For a regular sequence $x$:
$$x > 0 \;:\iff\; \exists\, n : \; x_n > \frac{1}{n+1}; \qquad\qquad x < y \;:\iff\; \exists\, n : \; x_n + \frac{2}{n+1} < y_n .$$

A proof of $x < y$ is thus a pair (index, rational inequality) — a certificate that can be checked by a finite computation. The margin $2/(n+1)$ is again the sum of the two error bars, and it is what makes the definition robust.

**Theorem 6.2 (extensional agreement).** $x > 0 \iff \hat x > 0$, and $x < y \iff \hat x < \hat y$.

*Proof sketch.* ($\Rightarrow$) If $x_n > \frac{1}{n+1}$ then $\hat x \ge x_n - \frac{1}{n+1} > 0$ by Theorem 2.4. ($\Leftarrow$) If $\hat x > 0$, pick $n$ with $\frac{2}{n+1} < \hat x$; then $x_n \ge \hat x - \frac{1}{n+1} > \frac{1}{n+1}$. The relation $<$ reduces to positivity of the difference by the same two-sided estimate. $\square$

Consequently $<$ is irreflexive, transitive and asymmetric — but these are now *theorems about certificates*, and the certificates must be recomputed at each step.

### 6.2 Cotransitivity

Trichotomy is unavailable. Its constructive substitute is cotransitivity, and we give it in fully explicit form.

**Definition 6.3 (certified gap).** If the index $n$ witnesses $x < y$, set
$$g \;:=\; y_n - x_n - \frac{2}{n+1} \;\in\; \mathbb{Q}_{>0}.$$

**Lemma 6.4 (gap propagation).** If $\frac{1}{m+1} \le \frac{g}{8}$ then $y_m - x_m \ge \frac{3g}{4}$.

*Proof sketch.* By Theorem 2.4, $\hat y - \hat x \ge g$ (the certified gap is a genuine lower bound on the real gap), while $x_m \le \hat x + \frac{1}{m+1}$ and $y_m \ge \hat y - \frac{1}{m+1}$. Hence $y_m - x_m \ge g - \frac{2}{m+1} \ge g - \frac{g}{4} = \frac{3g}{4}$. $\square$

**Theorem 6.5 (cotransitivity, explicit form).** Let $n$ witness $x < y$ with certified gap $g$, and let $m$ be any index with $\frac{1}{m+1} \le \frac{g}{8}$. Then for every regular sequence $z$, the single decidable rational comparison
$$z_m \;\ge\; \frac{x_m + y_m}{2} \quad ?$$
decides between the two certificates
$$x_m + \frac{2}{m+1} < z_m \qquad\text{and}\qquad z_m + \frac{2}{m+1} < y_m,$$
so that $x < z$ or $z < y$.

*Proof sketch.* By Lemma 6.4, $y_m - x_m \ge \frac{3g}{4}$, and by hypothesis $\frac{2}{m+1} \le \frac{g}{4}$. If $z_m \ge \frac{x_m + y_m}{2}$ then $z_m - x_m \ge \frac{y_m - x_m}{2} \ge \frac{3g}{8} > \frac{g}{4} \ge \frac{2}{m+1}$; symmetrically in the other case. $\square$

The disjunction is *overlapping*: both branches may hold, and this is exactly why the test is decidable. Insisting on the exclusive disjunction $x < z$ or $z \ge y$ reinstates the undecidable comparison.

The same technique yields **constructive location**: for rationals $a < b$ and any $x$, choose $n$ with $\frac{4}{n+1} \le b - a$ and compare $x_n$ with the midpoint $\frac{a+b}{2}$; one obtains $a < \hat x$ or $\hat x < b$. The classically trivial exclusive alternative "$a < \hat x$ or $\hat x \le a$" is not constructively available; the overlapping version is its replacement, and it is an algorithm.

### 6.3 The witness cannot be bounded

**Theorem 6.6 (no uniform witness bound).** For every $N \in \mathbb{N}$ there are Bishop reals $x < y$ such that **no** index $n \le N$ witnesses the inequality.

*Proof.* Take $x$ the constant sequence $0$ and $y$ the constant sequence $\frac{1}{N+1}$; then $\hat x < \hat y$, so $x < y$ by Theorem 6.2. But for $n \le N$ we have $\frac{1}{N+1} \le \frac{1}{n+1} \le \frac{2}{n+1}$, so $x_n + \frac{2}{n+1} \ge \frac{2}{n+1} \ge y_n$, and $n$ is not a witness. $\square$

This is the exact sense in which the constructive order, though extensionally the classical one (Theorem 6.2), is not decidable at any bounded precision. No algorithm inspecting a fixed finite number of approximations of $x$ and $y$ can decide the order.

---

## 7. The intermediate value theorem

### 7.1 The grid search

**Definition 7.1.** For $a \le b$ and $N \ge 1$, the **grid points** are $\mathrm{gr}_k := a + k\frac{b-a}{N}$, $0 \le k \le N$; the **mesh** is $\frac{b-a}{N}$.

**Theorem 7.2 (approximate intermediate value theorem).** Let $f$ have modulus of uniform continuity $\omega$ on $[a,b]$, with $f(a) \le 0 \le f(b)$. Let $\varepsilon > 0$ and let $N \ge 1$ satisfy $\frac{b-a}{N} \le \omega(\varepsilon)$. Then the **largest** index $k \le N$ with $f(\mathrm{gr}_k) \le 0$ satisfies
$$|f(\mathrm{gr}_k)| \le \varepsilon .$$
In particular, for every $\varepsilon > 0$ one can compute a point of $[a,b]$ at which $|f| \le \varepsilon$.

*Proof sketch.* The set $S = \{k \le N : f(\mathrm{gr}_k) \le 0\}$ contains $0$ and is finite, so it has a maximum $k$. If $k = N$ then $f(b) \le 0 \le f(b)$ gives $f(b) = 0$ and the claim is trivial. Otherwise $k+1 \le N$ and $f(\mathrm{gr}_{k+1}) > 0$ by maximality. The two grid points are one mesh apart, hence within $\omega(\varepsilon)$, so $f(\mathrm{gr}_{k+1}) - f(\mathrm{gr}_k) \le \varepsilon$. Since $f(\mathrm{gr}_k) \le 0 < f(\mathrm{gr}_{k+1})$, we get $|f(\mathrm{gr}_k)| = -f(\mathrm{gr}_k) \le \varepsilon$. $\square$

The search is finite, explicit, and free of any non-degeneracy hypothesis. It is the constructive content of the intermediate value theorem that always survives.

### 7.2 From small values to small distances

**Definition 7.3 (slope bound).** $f$ has **slope bound** $c$ on $S$ if
$$x, y \in S,\; x \le y \;\Longrightarrow\; c\,(y - x) \le f(y) - f(x).$$

For $c > 0$ this is an explicit quantitative form of "$f$ is nowhere locally constant and increasing".

**Theorem 7.4 (root modulus).** Let $f$ have slope bound $c > 0$ on $[a,b]$, let $r \in [a,b]$ with $f(r) = 0$, and let $x \in [a,b]$ with $|f(x)| \le \varepsilon$. Then
$$|x - r| \le \frac{\varepsilon}{c}.$$

*Proof sketch.* If $r \le x$ then $c(x - r) \le f(x) - f(r) = f(x) \le \varepsilon$; if $x \le r$ then $c(r - x) \le f(r) - f(x) = -f(x) \le \varepsilon$. $\square$

**Corollary 7.5 (uniqueness).** Under a positive slope bound the root is unique (take $\varepsilon = 0$).

**Theorem 7.6 (constructive intermediate value theorem with explicit modulus).** Let $f$ have modulus $\omega$ and slope bound $c > 0$ on $[a,b]$, with $f(a) \le 0 \le f(b)$. Then $f$ has a unique root $r \in [a,b]$, and for every $\delta > 0$ and every $N \ge 1$ with $\frac{b-a}{N} \le \omega(c\delta)$, the grid search of Theorem 7.2 (run at accuracy $c\delta$) returns an index $k \le N$ with
$$|\mathrm{gr}_k - r| \le \delta .$$
The **modulus of the root** is therefore $\delta \mapsto \omega(c\,\delta)$.

*Proof.* Existence of $r$ follows from continuity (Proposition 5.2) and the classical intermediate value theorem; uniqueness is Corollary 7.5. Apply Theorem 7.2 with $\varepsilon := c\delta$ to obtain a grid point with $|f| \le c\delta$, then Theorem 7.4 to convert this into $|\mathrm{gr}_k - r| \le c\delta/c = \delta$. $\square$

Running this construction over $\delta = \frac{1}{2(n+1)}$ presents the root itself as a Bishop real: there is a regular sequence of rationals denoting $r$, each of whose terms is an explicitly computed *rational* grid point $a + k\frac{b-a}{N}$ with $a, b \in \mathbb{Q}$.

### 7.3 Sharpness of the constant

**Theorem 7.7 (the root modulus is attained).** For every $c > 0$ and every $\varepsilon > 0$ with $\varepsilon/c \le 1$ there is a function $f$ on $[-1,1]$ with an explicit modulus of uniform continuity and slope bound $c$, a root $r$, and a point $x$ with $|f(x)| \le \varepsilon$ and
$$|x - r| = \frac{\varepsilon}{c} \quad \text{exactly}.$$

*Proof.* Take $f(x) = cx$, with modulus $\omega(\varepsilon) = \varepsilon/c$ and slope bound $c$ (both with equality). Then $r = 0$, and $x = \varepsilon/c$ has $|f(x)| = \varepsilon$ and $|x - r| = \varepsilon/c$. $\square$

**Theorem 7.8 (no smaller constant).** There is no $\kappa < 1$ such that for all $f, a, b, c > 0, \varepsilon > 0, r, x$: a slope bound $c$, a root $r$, and $|f(x)| \le \varepsilon$ imply $|x - r| \le \kappa \frac{\varepsilon}{c}$.

*Proof.* Instantiate with $f(x) = x$ on $[-1,1]$, $c = \varepsilon = 1$, $r = 0$, $x = 1$: the hypothesis gives $1 \le \kappa$, contradicting $\kappa < 1$. $\square$

So $\varepsilon/c$ is exactly the right exchange rate between a value bound and a distance bound.

---

## 8. The Brouwerian counterexample

### 8.1 The shelf family

**Definition 8.1.** For $t \in [-1,1]$ define $\mathrm{shelf}_t : [0,3] \to \mathbb{R}$ by
$$\mathrm{shelf}_t(x) \;=\; \min\bigl(x - 1,\; \max(t,\; x - 2)\bigr).$$

**Proposition 8.2.** Each $\mathrm{shelf}_t$ is $1$-Lipschitz (hence has the explicit modulus $\omega = \mathrm{id}$), and satisfies $\mathrm{shelf}_t(0) \le 0 \le \mathrm{shelf}_t(3)$. Consequently Theorem 7.2 applies **uniformly in $t$**: for every $\varepsilon > 0$ and every $N$ with $3/N \le \varepsilon$, some grid point of $[0,3]$ satisfies $|\mathrm{shelf}_t| \le \varepsilon$, and the required $N$ does not depend on $t$.

*Proof sketch.* Lipschitzness follows from $|\min(a,b) - \min(a',b')| \le \max(|a-a'|,|b-b'|)$ and the corresponding inequality for $\max$, applied to the two translates of the identity. The sign conditions are direct: $\mathrm{shelf}_t(0) \le 0 - 1 < 0$ and $\mathrm{shelf}_t(3) = \min(2, \max(t,1)) \ge 0$. $\square$

The root structure is completely explicit:

**Lemma 8.3.**
- If $t > 0$ then the unique root of $\mathrm{shelf}_t$ is $x = 1$; in particular $\mathrm{shelf}_1(x) = 0 \Rightarrow x = 1$.
- If $t < 0$ then the unique root is $x = 2$; in particular $\mathrm{shelf}_{-1}(x) = 0 \Rightarrow x = 2$.
- If $1 < x < 2$ and $\mathrm{shelf}_t(x) = 0$ then $t = 0$.
- Every root of every $\mathrm{shelf}_t$ lies in $[1,2]$.
- $\mathrm{shelf}_0$ vanishes identically on $[1,2]$; consequently it admits **no** positive slope bound on $[0,3]$.

*Proof sketch.* All five are finite case analyses on which of the two branches of $\min$ and of $\max$ is active. For the last: $\mathrm{shelf}_0(1) = \mathrm{shelf}_0(2) = 0$, so a slope bound $c$ would force $c \cdot 1 \le 0$. $\square$

### 8.2 No continuous root selector

**Theorem 8.4 (Brouwerian counterexample).** There is no continuous $r : [-1,1] \to \mathbb{R}$ with $\mathrm{shelf}_t(r(t)) = 0$ for all $t \in [-1,1]$.

*Proof.* Suppose such an $r$ exists. By Lemma 8.3, $r(1) = 1$ and $r(-1) = 2$. By the classical intermediate value theorem applied to the continuous function $r$ on $[-1,1]$, the interval $[1,2]$ is contained in the image of $r$; in particular there are $t_0, t_1$ with $r(t_0) = 3/2$ and $r(t_1) = 7/4$. Both values lie strictly between $1$ and $2$, so by Lemma 8.3 $t_0 = t_1 = 0$. But then $3/2 = r(0) = 7/4$, a contradiction. $\square$

Since every constructively definable function $\mathbb{R} \to \mathbb{R}$ is continuous, no constructive proof of the exact intermediate value theorem can exist: the root is not a continuous — let alone computable — function of the data $(f, a, b)$. What rescues Theorem 7.6 is precisely the hypothesis that Lemma 8.3 shows this family to violate: a positive slope bound.

### 8.3 The failure is maximal

Theorem 8.4 excludes *continuous* selectors. In fact no selector whatsoever is even approximately continuous at the critical parameter.

**Theorem 8.5 (quantitative failure).** Let $r : [-1,1] \to \mathbb{R}$ be **any** function with $\mathrm{shelf}_t(r(t)) = 0$ for all $t$. Then for every $\eta > 0$,
$$\sup\, r\bigl([-1,1] \cap [-\eta,\eta]\bigr) \;-\; \inf\, r\bigl([-1,1] \cap [-\eta,\eta]\bigr) \;\ge\; 1 .$$

*Proof sketch.* Set $s = \min(\eta, 1) > 0$. Both $s$ and $-s$ lie in $[-1,1] \cap [-\eta,\eta]$. By Lemma 8.3, $r(s) = 1$ and $r(-s) = 2$. All values of $r$ lie in $[1,2]$, so the image is bounded and the supremum is at least $2$ while the infimum is at most $1$. $\square$

The hypothesis is not vacuous: the discontinuous selector $r(t) = 2$ for $t < 0$ and $r(t) = 1$ otherwise satisfies it. The point is that *every* selector jumps by at least $1$ arbitrarily close to $t = 0$.

---

## 9. Bracketing versus bounding

Theorem 7.6 converts a value bound into a distance bound using the slope bound, at the price of the factor $1/c$. We now show that the grid search actually delivers something stronger *for free*, and that the value bound alone is genuinely too weak.

**Theorem 9.1 (bracketing form of the grid search).** Let $f$ have a modulus of uniform continuity on $[a,b]$ with $f(a) \le 0 \le f(b)$, and let $N \ge 1$. Then the largest grid index $k$ with $f(\mathrm{gr}_k) \le 0$ satisfies: there exists a genuine root $r \in [a,b]$ of $f$ with
$$|\mathrm{gr}_k - r| \le \frac{b-a}{N}.$$
**No** non-degeneracy hypothesis is required.

*Proof sketch.* If $k = N$ then $f(b) = 0$ and $r = b = \mathrm{gr}_k$. Otherwise $f(\mathrm{gr}_k) \le 0 < f(\mathrm{gr}_{k+1})$, and continuity on $[\mathrm{gr}_k, \mathrm{gr}_{k+1}]$ supplies a root $r$ in that interval, which has length exactly one mesh. $\square$

The accuracy of the *location* is the mesh itself, with no $1/c$ factor. The information used is the **sign change**, not the smallness of $|f|$ — the two are different, and the difference is real:

**Definition 9.2 (local non-constancy).** $f$ satisfies **local non-constancy with modulus $\nu$** if $\nu(h) > 0$ for $h > 0$ and, for every $h > 0$ and every interval $[p,q]$ with $q - p \ge h$, there is $z \in [p,q]$ with $|f(z)| \ge \nu(h)$.

This is Bishop's weakest standard non-degeneracy hypothesis. It does not suffice.

**Theorem 9.3 (local non-constancy is insufficient).** For every $\delta \in (0,2)$ there is a $1$-Lipschitz function $f$ on $[0,4]$ with $f(0) \le 0 \le f(4)$, satisfying local non-constancy with the explicit modulus $\nu(h) = h/8$, and a point $x \in [0,4]$ with
$$|f(x)| \le \frac{\nu(\delta)}{2} \qquad\text{yet}\qquad |x - r| > \delta \ \text{ for every root } r \text{ of } f.$$

*Proof sketch.* Take $\eta := \delta/32$ and
$$f(x) \;=\; \mathrm{dip}_\eta(x) \;:=\; \min\bigl(x - 1,\; |x - 3| + \eta\bigr), \qquad x \in [0,4].$$
This is $1$-Lipschitz as a minimum of two $1$-Lipschitz functions; $f(0) = -1 \le 0$ and $f(4) = \min(3, 1+\eta) > 0$. Its unique root is $x = 1$: on $[0,2]$ the first branch is active and vanishes only at $1$, while the second branch is bounded below by $\eta > 0$. Local non-constancy with $\nu(h) = h/8$ holds because on any interval of length $\ge h$ one can find a point at distance $\ge h/8$ from both critical points $1$ and $3$, and at such a point $|f| \ge h/8$. Finally $f(3) = \min(2, \eta) = \eta = \delta/32 \le \nu(\delta)/2 = \delta/16$, while $|3 - 1| = 2 > \delta$. $\square$

The moral for algorithm design: report the bracket, not the residual. A small residual is weak evidence of proximity to a root; a certified sign change is strong evidence, and the grid search produces it at no extra cost.

---

## 10. The constructive least upper bound principle

### 10.1 Located sets

The classical construction of $\sup S$ decides, for rational $q$, whether $q$ is an upper bound of $S$. That decision is in general undecidable. Bishop's replacement makes the decision procedure part of the data, in a form weakened just enough to be attainable.

**Definition 10.1 (located data).** A **located datum** for $S \subseteq \mathbb{R}$ is a function $L : \mathbb{Q} \times \mathbb{Q} \to \{\texttt{true}, \texttt{false}\}$ such that for all rationals $p < q$:
- if $L(p,q) = \texttt{true}$ then $s \le q$ for every $s \in S$;
- if $L(p,q) = \texttt{false}$ then there exists $s \in S$ with $s > p$.

The two conclusions are compatible — when $\sup S$ lies in $(p, q)$ both are true — and it is exactly this slack that makes $L$ implementable. The datum asserts only the disjunction, not an exclusive decision.

**Definition 10.2 (enclosure invariant).** A pair $(p,q) \in \mathbb{Q}^2$ **encloses** $S$ if $q$ is an upper bound of $S$ and some $s \in S$ satisfies $s > p$.

### 10.2 The trisection search

**Algorithm 10.3 (trisection step).** Given $(p, q)$ with $p < q$, set $m_1 = p + \frac{q-p}{3}$, $m_2 = p + \frac{2(q-p)}{3}$ and return
$$T(p,q) \;=\; \begin{cases} (p,\, m_2) & \text{if } L(m_1, m_2) = \texttt{true},\\[2pt] (m_1,\, q) & \text{if } L(m_1, m_2) = \texttt{false}.\end{cases}$$
Let $(p_n, q_n) := T^n(a_0, b_0)$.

**Theorem 10.4 (exact geometric rate).** $q_n - p_n = \left(\frac{2}{3}\right)^n (b_0 - a_0)$ for every $n$ — with equality, not merely an inequality.

*Proof sketch.* Both branches produce an interval of length exactly $\frac23 (q - p)$: $m_2 - p = \frac23(q-p)$ and $q - m_1 = \frac23(q-p)$. Induct. $\square$

**Theorem 10.5 (invariance).** If $(a_0, b_0)$ encloses $S$ and $a_0 < b_0$, then $(p_n, q_n)$ encloses $S$ for every $n$.

*Proof sketch.* Induction on $n$. In the `true` branch, $L(m_1,m_2) = \texttt{true}$ certifies $m_2$ as an upper bound while the old lower witness above $p$ is retained. In the `false` branch, $L(m_1,m_2) = \texttt{false}$ produces a member of $S$ above $m_1$ while the old upper bound $q$ is retained. Note that the query points are chosen *inside* the current interval, so $m_1 < m_2$ and the located datum applies. $\square$

**Theorem 10.6 (constructive least upper bound principle).** Let $S$ be nonempty and bounded above, with a located datum $L$ and an initial enclosure $(a_0, b_0)$, $a_0 < b_0$. Then $S$ has a least upper bound $u$, and for every $n$,
$$p_n \le u \le q_n, \qquad q_n - p_n = \left(\tfrac23\right)^n (b_0 - a_0).$$

*Proof sketch.* Nonemptiness and boundedness give a classical supremum $u$. Theorem 10.5 gives, at stage $n$, an element of $S$ above $p_n$ (so $p_n \le u$) and an upper bound $q_n$ (so $u \le q_n$). The width is Theorem 10.4. $\square$

**Theorem 10.7 (the supremum is a Bishop real).** Under the hypotheses of Theorem 10.6, the sequence whose $k$-th term is $p_{n(k)}$, where $n(k)$ is the least stage with $\left(\frac23\right)^{n} (b_0 - a_0) \le \frac{1}{k+1}$, is a regular sequence of rationals denoting $u$.

*Proof sketch.* $|p_{n(k)} - u| \le q_{n(k)} - p_{n(k)} \le \frac{1}{k+1}$, whence regularity via the triangle inequality through $u$, and identification via Theorem 2.5. $\square$

The whole construction stays inside $\mathbb{Q}$: the approximations are rational endpoints of the search.

### 10.3 A worked instance, and the cost of the hypothesis

**Example 10.8.** For $c \in \mathbb{Q}$ the half-line $S = (-\infty, c]$ has the located datum $L(p, q) := [\,c \le q\,]$, a decidable rational comparison. Indeed $c \le q$ makes $q$ an upper bound, and $q < c$ makes $c \in S$ a member above $p$ (since $p < q < c$). Running the trisection on $[0,1]$ with $c = 1/2$ produces
$$(0,1),\quad \left(0, \tfrac23\right),\quad \left(\tfrac29, \tfrac23\right),\quad \left(\tfrac29, \tfrac{14}{27}\right),\ \ldots$$
and after ten steps the width is exactly $(2/3)^{10}$, with $\frac12$ inside the enclosure.

**Theorem 10.9 (classical equivalence).** Assuming the classically valid decision "is $q$ an upper bound of $S$?", every $S$ has a located datum.

*Proof.* Take $L(p,q) := [\,\forall s \in S,\; s \le q\,]$. A `true` answer is literally the upper bound condition; a `false` answer yields $s \in S$ with $s > q > p$. $\square$

So the constructive principle is classically equivalent to ordinary completeness, and its entire content is the extra datum. Constructive mathematics does not weaken the theorem; it makes visible a hypothesis that the classical proof consumes silently.

---

## 11. Optimising the located search

Because Algorithm 10.3 is completely explicit, one may ask whether $2/3$ is the best contraction per oracle call. It is not, and the exact answer is available.

**Algorithm 11.1 (general one-query step).** Fix $0 < \alpha < \beta < 1$. Given $(p,q)$, query the oracle at $p + \alpha(q-p)$ and $p + \beta(q-p)$ and return
$$T_{\alpha,\beta}(p,q) \;=\; \begin{cases} \bigl(p,\; p + \beta(q-p)\bigr) & \text{on \texttt{true}},\\[2pt] \bigl(p + \alpha(q-p),\; q\bigr) & \text{on \texttt{false}}.\end{cases}$$

**Theorem 11.2 (exact contraction factor).** For $0 < \alpha < \beta < 1$ the scheme $T_{\alpha,\beta}$ preserves the enclosure invariant of Definition 10.2, never degenerates ($p_n < q_n$ for all $n$), and after $n$ oracle calls
$$q_n - p_n \;\le\; \bigl(\max(\beta,\, 1-\alpha)\bigr)^n (b_0 - a_0),$$
with the factor $\max(\beta, 1-\alpha)$ attained in the worst case (the `true` branch contracts by $\beta$, the `false` branch by $1 - \alpha$).

*Proof sketch.* The two branch widths are $\beta(q-p)$ and $(1-\alpha)(q-p)$; both are positive by $0 < \alpha < \beta < 1$, and both are at most $\max(\beta,1-\alpha)(q-p)$. Invariance is as in Theorem 10.5, using $\alpha < \beta$ to ensure the two query points are distinct and ordered. Induct for the $n$-fold bound. $\square$

Trisection is $(\alpha,\beta) = (\frac13, \frac23)$, giving $\max(\frac23,\frac23) = \frac23$.

**Theorem 11.3 (trisection is not optimal).** The scheme with $(\alpha, \beta) = \left(\frac25, \frac12\right)$ preserves the same enclosure invariant and contracts by
$$\max\left(\tfrac12,\; \tfrac35\right) = \tfrac35 \;<\; \tfrac23$$
per oracle call.

**Theorem 11.4 (the optimal ratio is the infimum $\tfrac12$, never attained).**
1. For all $\alpha < \beta$, $\max(\beta, 1-\alpha) > \frac12$.
2. For every $\eta > 0$ there are $0 < \alpha < \beta < 1$ with $\max(\beta, 1-\alpha) < \frac12 + \eta$.

*Proof.* (1) If $\beta > \frac12$ we are done. If $\beta \le \frac12$ then $\alpha < \beta \le \frac12$, so $1 - \alpha > \frac12$. (2) Put $t := \min(\eta, \frac14) > 0$ and $\alpha := \frac12 - \frac t2$, $\beta := \frac12 + \frac t2$. Then $0 < \alpha < \beta < 1$ and $\max(\beta, 1-\alpha) = \frac12 + \frac t2 < \frac12 + \eta$. $\square$

The interpretation is information-theoretic. One oracle call returns one bit, and one bit can at best halve the search space; hence the barrier at $\frac12$. It is not attained because the two query points must be *distinct*: the located datum is only defined for $p < q$, and it is precisely the gap between the query points that gives the oracle the freedom to answer either way when the supremum lies between them. The constructive algorithm pays a strictly positive, arbitrarily small tax for the very ambiguity that makes locatedness implementable.

---

## 12. Algorithmic summary

The development yields five algorithms, all finite and all with proved bounds:

| Algorithm | Input | Output | Guarantee |
|---|---|---|---|
| Approximation | Bishop real $x$, target $\varepsilon$ | rational $x_n$, $n = \lceil 1/\varepsilon\rceil$ | $|\hat x - x_n| \le \varepsilon$ |
| Shifted diagonal | regular sequence of reals | Bishop real $L$ | $|\hat L - \hat x^{(k)}| \le \frac{1}{k+1}$ |
| Cotransitivity test | certificate for $x<y$, third real $z$ | branch $x<z$ or $z<y$ | one rational comparison at any $m$ with $\frac{1}{m+1}\le\frac g8$ |
| Sign-change grid search | $f$ with modulus $\omega$, $N$ | grid index $k$ | $|f(\mathrm{gr}_k)| \le \varepsilon$ if mesh $\le\omega(\varepsilon)$; and $\mathrm{gr}_k$ within one mesh of a root |
| One-query located search | located datum, $(\alpha,\beta)$ | enclosure of $\sup S$ | width $\le \max(\beta,1-\alpha)^n(b_0-a_0)$ |

Complexity, in oracle/evaluation calls: the approximation algorithm is $O(1)$ calls to the sequence; the grid search at accuracy $\varepsilon$ costs $N + 1$ function evaluations with $N = \lceil (b-a)/\omega(\varepsilon)\rceil$, which for a $c$-Lipschitz $f$ is $O((b-a)c/\varepsilon)$; the located search costs $\lceil \log(1/\varepsilon)/\log(1/\rho)\rceil$ oracle calls with $\rho = \max(\beta, 1-\alpha)$, so the improvement from $\rho = 2/3$ to $\rho = 3/5$ is a constant-factor speedup of $\log(3/2)/\log(5/3) \approx 0.794$, and pushing $\rho \to 1/2$ gives at best $\log(3/2)/\log 2 \approx 0.585$.

Note that the grid search is *not* a bisection: bisection on $[a,b]$ would require deciding the sign of $f$ at the midpoint, and that decision is exactly the undecidable comparison. The linear scan over $N+1$ grid points avoids the issue because it never needs to know the sign at any *particular* point in advance — it only needs the finite set $\{k : f(\mathrm{gr}_k) \le 0\}$ to have a maximum, which is a decidable fact about a finite list once the finitely many comparisons are made.

---

## 13. Discussion

### 13.1 A pattern: overlapping disjunctions

Three of the central results share a shape. Cotransitivity (Theorem 6.5) concludes "$x < z$ **or** $z < y$", and both may hold. Constructive location concludes "$a < x$ **or** $x < b$" for $a < b$, and both may hold. The located datum (Definition 10.1) concludes "$q$ is an upper bound **or** some member exceeds $p$", and both may hold.

In each case the classical statement is an exclusive dichotomy that is undecidable, and the constructive replacement is an *overlapping* disjunction that is decidable. The overlap is not a defect; it is the mechanism. A decision procedure needs slack in order to be implementable, and the size of the slack is the quantitative content: $\frac{g}{8}$ in cotransitivity, $\frac{b-a}{4}$ in location, $q - p$ in locatedness. Theorem 11.4 says something remarkable about this: the slack in the located datum forces a strictly positive information loss, but the loss can be made arbitrarily small.

### 13.2 Where the classical proofs hide their hypotheses

Each constructive theorem here has a classical counterpart with strictly fewer hypotheses, and in each case the missing hypothesis is one the classical proof consumes invisibly:

- **Completeness.** Classically, no modulus is required; constructively, the modulus is the datum and the diagonal shift is forced (Theorem 4.4).
- **Intermediate value theorem.** Classically, continuity suffices; constructively, one needs a modulus *and* either to weaken the conclusion to $\varepsilon$-approximation (Theorem 7.2) or to add a slope bound (Theorem 7.6). The shelf family (Theorem 8.4) shows this is not an artefact of proof technique.
- **Least upper bound.** Classically, boundedness suffices; constructively, locatedness is needed, and Theorem 10.9 shows that classically it is free.

The uniform diagnosis: the classical proof performs an undecidable decision, and the constructive theorem either supplies that decision as data or weakens the conclusion until the decision is unnecessary.

### 13.3 Sharpness as a dividend

The results of Sections 4.4, 7.3, 9 and 11 are of a kind that cannot even be *stated* in a purely existential development. "The constant $\varepsilon/c$ is attained" presupposes that a constant has been named. "The shift $2n+1$ cannot be removed" presupposes that the limit is given by a formula. "$2/3$ is not optimal" presupposes an algorithm with a rate. Making the constructions explicit does not merely make them implementable; it makes them *criticisable*, and the criticism yields new mathematics.

### 13.4 Limitations

Our metatheory is classical: we prove classical statements about constructive data, and we use the classical intermediate value theorem to produce the exact root whose *location* is then computed constructively (Theorem 7.6, Theorem 9.1). A fully intuitionistic treatment would construct the root by the search itself. This is a difference of packaging rather than of content — the algorithms and their bounds are unchanged, and the sharpness statements (which quantify over all functions or all constants) are most naturally classical anyway.

---

## 14. Future directions

The following are concrete, falsifiable conjectures suggested by the development. Each is stated so that a single proof or a single counterexample settles it.

### C6. $k$ oracle calls per step cannot beat the ratio $1/(k+1)$

Theorem 11.4 shows that the optimal contraction ratio of a *one-query* located search is the infimum $1/2$, never attained. The natural generalisation queries the locatedness oracle $k$ times per step, at the pairs $\bigl(p + \alpha_i (q-p),\, p + \beta_i (q-p)\bigr)$ with $\alpha_1 < \beta_1 \le \alpha_2 < \beta_2 \le \cdots < \beta_k$, keeping the smallest enclosure the answers certify.

> **Conjecture.** The worst-case contraction factor of any such $k$-query scheme is $> \frac{1}{k+1}$, and for every $\eta > 0$ some $k$-query scheme achieves a factor $< \frac{1}{k+1} + \eta$. In particular the per-oracle-call efficiency $(\text{contraction})^{1/k}$ tends to $0$ as $k \to \infty$: batching queries strictly pays.

Falsifiable: a $k$-query scheme (for a concrete $k$, e.g. $k = 2$) that provably preserves the enclosure invariant and contracts by a factor $\le \frac{1}{k+1}$ refutes the first half; a proof that no $2$-query scheme beats, say, $2/5$ refutes the second.

### C7. The cotransitivity threshold is exactly $6$

Theorem 6.5 decides $x < z$ or $z < y$ at any index $m$ with $\frac{1}{m+1} \le \frac{g}{8}$, where $g$ is the certified gap; the arithmetic of the proof only needs $\frac{1}{m+1} < \frac{g}{6}$.

> **Conjecture.** $6$ is optimal: the hypothesis $\frac{1}{m+1} \le \frac{g}{\kappa}$ with $\kappa < 6$ is insufficient — there are $x, y, z$ and indices $n, m$ satisfying it for which the midpoint test at $m$ decides neither $x < z$ nor $z < y$ — while the conclusion of cotransitivity does hold under $\frac{1}{m+1} < \frac{g}{6}$.

Falsifiable: a proof of cotransitivity with a constant $\kappa < 6$ refutes the first half; an explicit triple defeating the constant $6$ refutes the second.

### C8. The canonical multiplication bound can be lowered to $\lceil |x_0| \rceil + 1$

The bound $B(x) = \lceil |x_0| \rceil + 2$ of Definition 3.4 is used to choose the index shift in the definition of multiplication. Since $|x_n - x_0| \le \frac{1}{n+1} + 1 \le 2$, with strict inequality for $n \ge 1$, only $n = 0$ is at issue.

> **Conjecture.** Replacing $B$ by $\lceil |x_0| \rceil + 1$ still yields a regular sequence for the product, and the identification of the product with $\hat x \hat y$ continues to hold; the constant $1$ is then optimal, i.e. $\lceil |x_0| \rceil$ alone fails for some pair of Bishop reals.

Falsifiable: a pair $x, y$ for which the sequence defined with $\lceil |x_0| \rceil + 1$ violates the regularity inequality refutes the first half; a proof that $\lceil |x_0| \rceil$ always suffices refutes the second.

### Further questions

- **Sharpness of the addition shift.** Is $n \mapsto 2n+1$ the least shift for which the pointwise sum of two regular sequences is regular? The analogue of Theorem 4.4 for addition is open.
- **Uniformity in the shelf oscillation.** Theorem 8.5 gives oscillation $\ge 1$ for every root selector. Is $1$ the exact value of the oscillation infimum over all selectors, and is it attained by the discontinuous selector of Section 8.3?
- **Bracket-based moduli.** Theorem 9.1 gives location to within one mesh with no non-degeneracy hypothesis. Can the whole of Theorem 7.6 be rederived from bracketing alone, with the slope bound entering only in the uniqueness statement?

---

## 15. Conclusion

We have carried out a quantitative development of Bishop's constructive analysis in which every existence statement is accompanied by an explicit modulus: real numbers as regular sequences with the canonical rate $1/(n+1)$; completeness by the shifted diagonal $n \mapsto x^{(2n+1)}_{2n+1}$, with the shift shown necessary; an order carrying certificates, with an explicit cotransitivity algorithm and a proof that the certificate cannot be bounded in advance; the intermediate value theorem in its approximate form (always available, by finite grid search) and its exact form (available under a slope bound, with root modulus $\delta \mapsto \omega(c\delta)$ and the sharp displacement bound $\varepsilon/c$); a Brouwerian counterexample whose failure is quantified to oscillation $\ge 1$; a bracketing refinement showing that sign changes locate roots better than residuals do, with an explicit function proving local non-constancy insufficient; and the least upper bound principle for located sets, with the exact rate $(2/3)^n$ improved to $\max(\beta, 1-\alpha)^n$ and the optimal ratio identified as the unattained infimum $1/2$.

The recurring theme is that explicitness is not merely a philosophical constraint but a mathematical instrument. Once a rate is written down, one can ask whether it is optimal; once an algorithm is written down, one can ask whether it is efficient. The classical theorems, which assert only that something exists, do not admit these questions. Bishop's discipline turns analysis into a subject with constants — and constants can be improved.

---

## References

- E. Bishop, *Foundations of Constructive Analysis*, McGraw-Hill, 1967.
- E. Bishop and D. Bridges, *Constructive Analysis*, Grundlehren der mathematischen Wissenschaften 279, Springer, 1985.
- D. Bridges and F. Richman, *Varieties of Constructive Mathematics*, London Mathematical Society Lecture Note Series 97, Cambridge University Press, 1987.
- A. S. Troelstra and D. van Dalen, *Constructivism in Mathematics: An Introduction*, North-Holland, 1988.
