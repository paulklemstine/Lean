# A Diophantine Sufficient Condition for Strong Aperiodicity of Wang Stripe Sets

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Aperiodic order; Diophantine approximation; symbolic dynamics)

---

## Abstract

We study a quantitative refinement of the classical fact that irrational densities force aperiodicity in stripe-based Wang tile families. Working with the Beatty-stripe skeleton $W(\alpha,\beta)$ of a two-dimensional Wang tile set — vertical stripes of density $\alpha$ overlaid on horizontal stripes of density $\beta$ — we replace the qualitative hypothesis "$\alpha,\beta$ irrational" by the sharp, falsifiable hypothesis "$\alpha,\beta$ Diophantine," meaning each density admits a uniform separation $|\alpha - a/b| \ge c/b^2$ from every rational $a/b$. We prove four results that together form a complete logical chain from elementary number theory to strong aperiodicity. First, every Diophantine real is irrational (a rational density would be hit exactly, contradicting the strict positive lower bound). Second, every irrational square root $\sqrt{d}$ is Diophantine with the explicit constant $c = 1/(2\sqrt{d}+1)$, via the surd identity $|\sqrt{d}-a/b|\cdot|\sqrt{d}+a/b| = |d b^2 - a^2|/b^2$ and the nonzero-integer bound $|d b^2 - a^2| \ge 1$. Third, for $\sqrt 2$ the constant improves to the clean value $1/4$, giving $|\sqrt 2 - a/b| \ge 1/(4b^2)$. Fourth, a Diophantine pair certifies strong aperiodicity of $W(\alpha,\beta)$, instantiated concretely at the quadratic pair $(\sqrt 2, \sqrt 3)$. The Diophantine exponent $2$ emerges as the structural invariant — the algebraic signature of degree-two irrationality — and the explicit constants quantify exactly how strongly the family refuses to repeat. We discuss algorithms for verifying the bounds numerically, applications to aperiodic order, and a program of conjectures (necessity, exponent-optimality, and complexity-rate control) for future work.

---

## 1. Introduction

### 1.1 Background

A **Wang tile** is a unit square with a color assigned to each of its four edges. Given a finite set of Wang tiles, a **tiling** of the plane is an assignment of one tile (without rotation or reflection) to each cell of the integer grid $\mathbb{Z}^2$ such that adjacent tiles share the color along their common edge. A tiling is **periodic** if some nonzero vector $v \in \mathbb{Z}^2$ leaves it invariant under translation, and **strongly aperiodic** if it admits *no* nonzero period vector at all. A tile set is *aperiodic* if it tiles the plane but only aperiodically.

Wang conjectured that any tile set able to tile the plane could do so periodically; Berger refuted this by constructing the first aperiodic set, launching the modern theory of aperiodic order — the mathematical backbone of physical quasicrystals. A recurring and conceptually clean source of aperiodicity is *irrationality of a density parameter*: when a tiling encodes a real density that is not a ratio of integers, no exact repetition is possible.

### 1.2 The stripe skeleton

The combinatorial core of many density-driven Wang families is captured by the **Beatty step word**. For $\alpha \in \mathbb{R}$, define

$$d_\alpha(n) = \lfloor (n+1)\alpha \rfloor - \lfloor n\alpha \rfloor, \qquad n \in \mathbb{N}.$$

For $\alpha \in (0,1)$ this is a binary sequence (the Sturmian / mechanical word of slope $\alpha$) recording where the running floor $\lfloor n\alpha\rfloor$ increments. Its key structural property is the **telescoping identity**

$$\sum_{n < N} d_\alpha(n) = \lfloor N\alpha\rfloor,$$

which makes the long-run frequency of $1$'s equal to $\alpha$ and pins eventual periodicity directly to the arithmetic of $\alpha$. The two-dimensional **Wang stripe set** $W(\alpha,\beta)$ overlays vertical stripes governed by $d_\alpha$ and horizontal stripes governed by $d_\beta$; it is the skeleton of a Wang tile set whose edge colors encode the positions dictated by the two Beatty words. The governing principle, established in the companion development of the stripe model, is:

> **(Aperiodicity criterion.)** $W(\alpha,\beta)$ admits a nonzero period vector iff at least one of the Beatty words $d_\alpha, d_\beta$ is (eventually) periodic; and $d_\gamma$ is periodic iff $\gamma \in \mathbb{Q}$. Consequently, if $\alpha$ and $\beta$ are both irrational, then $W(\alpha,\beta)$ is strongly aperiodic.

We take this criterion as the geometric input. The present paper supplies the *quantitative* number-theoretic input that strengthens "irrational" to a sharp, computable condition.

### 1.3 Contribution

"Irrational" is a binary predicate; it certifies that the pattern never *exactly* repeats but says nothing about how closely it approaches repetition. The natural quantitative sharpening is the **Diophantine** condition from the theory of metric number theory: $\alpha$ is badly approximable to exponent $2$. We prove:

1. **`Diophantine_irrational`** — Diophantine $\Rightarrow$ irrational.
2. **`sqrt_Diophantine`** — every irrational $\sqrt d$ is Diophantine with explicit $c = 1/(2\sqrt d + 1)$.
3. **`sqrt_two_Diophantine`, `sqrt_three_Diophantine`** — the two witnessing quadratic surds.
4. **`sqrt_two_diophantine_quarter`** — the sharpened constant $|\sqrt 2 - a/b| \ge 1/(4b^2)$.
5. **`diophantine_pair_aperiodic`** — the linking theorem: a Diophantine pair certifies strong aperiodicity.
6. **`sqrt2_sqrt3_wang_aperiodic`** — the concrete aperiodic instance $(\sqrt 2, \sqrt 3)$.

The logical chain is

$$\text{Diophantine } \alpha \wedge \text{Diophantine } \beta \;\Longrightarrow\; \text{Irrational } \alpha,\beta \;\Longrightarrow\; \text{no period of } d_\alpha, d_\beta \;\Longrightarrow\; \text{strong aperiodicity of } W(\alpha,\beta).$$

All constants are explicit, all hypotheses are non-vacuous (the surds $\sqrt 2, \sqrt 3$ witness them), and the result is a *sufficiency* statement; we are careful to claim neither necessity nor exponent-optimality, both of which we record as conjectures in §7.

---

## 2. Definitions

### 2.1 The Diophantine condition

**Definition 2.1 (Diophantine real).** A real number $\alpha$ is **Diophantine** (badly approximable to exponent $2$) if there exists a constant $c > 0$ such that for all integers $a \in \mathbb{Z}$ and all natural numbers $b \ge 1$,

$$\frac{c}{b^2} \;\le\; \left| \alpha - \frac{a}{b} \right|.$$

We call any such $c$ a **separation constant** for $\alpha$.

Intuitively, $\alpha$ keeps every rational $a/b$ at distance at least $c/b^2$; cheap (small-denominator) fractions stay far, and only expensive ones can approach, at a strictly controlled quadratic rate. This is the sharpest uniform rate possible for an irrational by Dirichlet's theorem, which guarantees infinitely many fractions with $|\alpha - a/b| < 1/b^2$; the Diophantine condition asserts a matching *lower* bound, so badly approximable numbers sit exactly at this threshold.

### 2.2 Irrationality and the Beatty skeleton

**Definition 2.2 (Irrational).** $\alpha$ is irrational if $\alpha \neq q$ for every $q \in \mathbb{Q}$.

**Definition 2.3 (Beatty step word).** For $\alpha \in \mathbb{R}$, the step word is $d_\alpha(n) = \lfloor (n+1)\alpha\rfloor - \lfloor n\alpha\rfloor$.

**Definition 2.4 (Wang stripe set).** $W(\alpha,\beta)$ is the two-dimensional configuration whose vertical-stripe positions are the support of $d_\alpha$ and whose horizontal-stripe positions are the support of $d_\beta$; equivalently, the Wang-tile skeleton in which a valid edge-matching tiling reproduces $d_\alpha$ along every row and $d_\beta$ along every column.

**Definition 2.5 (Strong aperiodicity).** $W(\alpha,\beta)$ is strongly aperiodic if there is no nonzero $v \in \mathbb{Z}^2$ with $W(\alpha,\beta) + v = W(\alpha,\beta)$.

---

## 3. Diophantine implies irrational

**Theorem 3.1 (`Diophantine_irrational`).** *If $\alpha$ is Diophantine, then $\alpha$ is irrational.*

**Proof sketch.** Let $c > 0$ be a separation constant and suppose toward contradiction that $\alpha = q$ for some rational $q$. Write $q = a/b$ in any representation with $b \ge 1$ (for instance $a = q.\mathrm{num}$, $b = q.\mathrm{den}$). Applying Definition 2.1 to this very $a/b$ gives

$$0 < \frac{c}{b^2} \;\le\; \left|\alpha - \frac{a}{b}\right| = |q - q| = 0,$$

a contradiction. Hence no rational equals $\alpha$. $\qquad\blacksquare$

The point is structural: a rational density is *hit exactly* by one of the competing fractions, so it can satisfy no positive lower bound on its distance to the rationals. The Diophantine condition is therefore a strict strengthening of irrationality — it forbids exact hits *and* quantifies the near-misses.

---

## 4. Quadratic irrationals are Diophantine

This section contains the technical heart: an elementary, constant-explicit proof that square roots are badly approximable.

### 4.1 The surd identity and the nonzero-integer bound

For $d \in \mathbb{N}$ with $\sqrt d$ irrational and any fraction $a/b$ ($b \ge 1$), the conjugate factorization gives

$$\left|\sqrt d - \frac{a}{b}\right| \cdot \left|\sqrt d + \frac{a}{b}\right| \;=\; \left| d - \frac{a^2}{b^2}\right| \;=\; \frac{|d\,b^2 - a^2|}{b^2}. \tag{4.1}$$

The numerator $d\,b^2 - a^2$ is an integer, and it is **nonzero**: if $d\,b^2 = a^2$ then $\sqrt d = |a|/b \in \mathbb{Q}$, contradicting irrationality of $\sqrt d$. A nonzero integer has absolute value at least $1$, so $|d\,b^2 - a^2| \ge 1$ and

$$\left|\sqrt d - \frac{a}{b}\right| \cdot \left|\sqrt d + \frac{a}{b}\right| \;\ge\; \frac{1}{b^2}. \tag{4.2}$$

This single integrality constraint — "a nonzero integer cannot be smaller than $1$" — is the entire engine of the result and is the algebraic signature of degree two.

### 4.2 The main theorem

**Theorem 4.1 (`sqrt_Diophantine`).** *If $d \in \mathbb{N}$ and $\sqrt d$ is irrational, then $\sqrt d$ is Diophantine with separation constant $c = \dfrac{1}{2\sqrt d + 1}$.*

**Proof sketch.** Fix $a \in \mathbb{Z}$, $b \ge 1$, and put $c = 1/(2\sqrt d + 1) > 0$. We must show $c/b^2 \le |\sqrt d - a/b|$. Split on the size of the error.

*Case 1: $|\sqrt d - a/b| < 1$.* Since $d$ is a non-square natural number, $\sqrt d \ge 1$, and the near-miss bound gives the upper estimate

$$\left|\sqrt d + \frac{a}{b}\right| \;<\; 2\sqrt d + 1,$$

because $|a/b| \le \sqrt d + 1$ when $a/b$ is within distance $1$ of $\sqrt d$. Combining this upper bound on the second factor with the lower bound (4.2) on the product,

$$\left|\sqrt d - \frac{a}{b}\right| \;\ge\; \frac{1/b^2}{\,|\sqrt d + a/b|\,} \;>\; \frac{1/b^2}{2\sqrt d + 1} \;=\; \frac{c}{b^2}.$$

*Case 2: $|\sqrt d - a/b| \ge 1$.* Since $b \ge 1$ and $\sqrt d \ge 1$ we have $c = 1/(2\sqrt d+1) \le 1$ and $c/b^2 \le 1 \le |\sqrt d - a/b|$ directly.

In both cases $c/b^2 \le |\sqrt d - a/b|$, so $\sqrt d$ is Diophantine. $\qquad\blacksquare$

### 4.3 The two witnesses

**Theorem 4.2 (`sqrt_two_Diophantine`).** *$\sqrt 2$ is Diophantine.*

**Proof sketch.** $\sqrt 2$ is irrational (classical), so Theorem 4.1 applies with $d = 2$, yielding the constant $1/(2\sqrt2+1) \approx 0.261$. $\qquad\blacksquare$

**Theorem 4.3 (`sqrt_three_Diophantine`).** *$\sqrt 3$ is Diophantine.*

**Proof sketch.** $3$ is prime, hence $\sqrt 3$ is irrational, and Theorem 4.1 applies with $d = 3$, giving constant $1/(2\sqrt3+1) \approx 0.225$. $\qquad\blacksquare$

These two theorems certify that Definition 2.1 is *non-vacuous*: concrete, named numbers satisfy it.

### 4.4 The sharpened constant for $\sqrt 2$

The generic constant $1/(2\sqrt d+1)$ is not optimal. For $\sqrt 2$ a slightly more careful estimate yields a clean rational floor.

**Theorem 4.4 (`sqrt_two_diophantine_quarter`).** *For all $a \in \mathbb{Z}$ and $b \ge 1$,*

$$\frac{1}{4 b^2} \;\le\; \left|\sqrt 2 - \frac{a}{b}\right|.$$

**Proof sketch.** As in (4.1)–(4.2) with $d = 2$, the nonzero integer is $a^2 - 2b^2$ (which cannot vanish, since $a^2 = 2b^2$ would make $a/b = \pm\sqrt2$ rational), so $|a^2 - 2b^2| \ge 1$ and

$$\left|\sqrt 2 - \frac{a}{b}\right|\cdot\left|\sqrt 2 + \frac{a}{b}\right| \ge \frac{1}{b^2}.$$

If $|\sqrt 2 - a/b| < 1$ then $\sqrt 2 + a/b < 2\sqrt 2 + 1 < 4$, whence $|\sqrt 2 - a/b| \ge 1/(4b^2)$. Otherwise $|\sqrt 2 - a/b| \ge 1 \ge 1/(4b^2)$. $\qquad\blacksquare$

This is the classical badly-approximable bound for $\sqrt 2$: no rational, however chosen, beats the $1/(4b^2)$ barrier. (The constant $1/4$ is not the absolute best possible — the metric theory of continued fractions gives an asymptotic floor governed by $1/(2\sqrt2\,b^2)$ — but $1/4$ is a clean, fully explicit, uniformly valid value.)

---

## 5. From Diophantine pairs to strong aperiodicity

**Theorem 5.1 (`diophantine_pair_aperiodic`).** *If $\alpha$ and $\beta$ are both Diophantine, then the Wang stripe set $W(\alpha,\beta)$ is strongly aperiodic.*

**Proof sketch.** By Theorem 3.1 each of $\alpha,\beta$ is irrational. By the aperiodicity criterion of §1.2, irrationality of $\gamma$ implies the Beatty word $d_\gamma$ is not eventually periodic, and a nonzero period vector of $W(\alpha,\beta)$ would force periodicity of $d_\alpha$ or $d_\beta$. With both words non-periodic, $W(\alpha,\beta)$ has no nonzero period vector. $\qquad\blacksquare$

**Theorem 5.2 (`sqrt2_sqrt3_wang_aperiodic`).** *The Wang stripe set $W(\sqrt 2, \sqrt 3)$ is strongly aperiodic.*

**Proof sketch.** Combine Theorems 4.2 and 4.3 (both densities Diophantine) with Theorem 5.1. $\qquad\blacksquare$

Thus the simplest non-trivial Diophantine data — a pair of distinct quadratic surds — already certifies strong aperiodicity, with an explicit joint separation constant $\min\{1/(2\sqrt2+1),\,1/(2\sqrt3+1)\} = 1/(2\sqrt3+1) \approx 0.225$.

---

## 6. Algorithms and numerical verification

While the theorems are exact, the bounds are eminently checkable, which makes the development a fertile ground for finite verification and for building intuition.

### 6.1 Beatty step word generator

Computing $d_\alpha(n) = \lfloor (n+1)\alpha\rfloor - \lfloor n\alpha\rfloor$ for $n = 0,\dots,N-1$ exhibits clockwork periodicity when $\alpha = a/b$ (period exactly $b$ in lowest terms) and non-repetition when $\alpha$ is irrational. Comparing the prefix of $d_{\sqrt2}$ against every short candidate period demonstrates aperiodicity empirically. Complexity: $O(N)$ floor evaluations; using a high-precision rational or arbitrary-precision float for $\alpha$ avoids round-off.

### 6.2 Diophantine bound certifier

Given $d$ and a denominator range $b = 1,\dots,B$, compute for each $b$ the best rational approximation $a = \mathrm{round}(b\sqrt d)$ and verify $|\sqrt d - a/b| \ge c/b^2$ with $c = 1/(2\sqrt d+1)$ (and $c = 1/4$ for $d = 2$). The minimizing $a$ is the only candidate that could violate the bound, so a single $a$ per $b$ suffices. Complexity: $O(B)$.

### 6.3 Convergent stress test

The continued-fraction convergents of $\sqrt d$ are the *worst* approximators — those that come closest. Generating the convergents $p_k/q_k$ and tabulating the *normalized error* $q_k^2 \cdot |\sqrt d - p_k/q_k|$ shows it staying bounded below by the separation constant and oscillating toward the metric limit, visually confirming that exponent $2$ is the correct scale. Complexity: $O(K)$ for $K$ convergents via the standard recurrence.

---

## 7. Discussion, applications, and future directions

### 7.1 Significance of the exponent

The Diophantine exponent $2$ is the structural invariant of the whole construction. It is not an arbitrary choice: it is the algebraic degree of a square root, surfacing through the quadratic numerator $d b^2 - a^2$ in the surd identity. Cubic irrationals and Liouville numbers break exactly the nonzero-integer step — Liouville numbers admit approximations far closer than any $c/b^2$ and are *not* Diophantine of exponent $2$, even though they remain irrational and hence still yield aperiodic stripe sets. The Diophantine condition therefore stratifies the irrational densities by *how strongly* they enforce aperiodicity, with the quadratic surds occupying the extremal, best-controlled stratum.

### 7.2 Applications

- **Aperiodic order and quasicrystals.** Density-driven Wang families model the diffraction-ordered but translation-disordered structure of physical quasicrystals; an explicit separation constant quantifies the minimum scale below which apparent periodicity is impossible.
- **Symbolic dynamics.** The Beatty/Sturmian words of badly approximable slope have linear factor complexity and bounded "repetition function"; the Diophantine constant controls the recurrence rate, tying word combinatorics to metric number theory.
- **Verification and constructive mathematics.** Because every constant is explicit and every hypothesis is witnessed by a concrete surd, the chain is fully constructive and finitely auditable, an attractive target for formal certification.

### 7.3 Future directions

These continue the research program of the cycle that produced the stripe model and the Diophantine condition (chain established: Diophantine $\alpha\wedge\beta \Rightarrow$ irrational $\Rightarrow$ no period of the Beatty step words $\Rightarrow$ strong aperiodicity of $W(\alpha,\beta)$; surds $\sqrt2,\sqrt3$ shown Diophantine with explicit constants, e.g. $|\sqrt2 - a/b| \ge 1/(4b^2)$).

**C1. Necessity (converse): periodic $\Leftrightarrow$ rational slope, sharply.** *Conjecture.* For every real $\alpha$, the Beatty step word $d_\alpha$ is eventually periodic *iff* $\alpha \in \mathbb{Q}$; moreover its minimal period equals the denominator of $\alpha$ in lowest terms. The telescoping identity $\sum_{n<N} d_\alpha(n) = \lfloor N\alpha\rfloor$ pins the period to the arithmetic of $\lfloor p\alpha\rfloor = p\alpha$, so the only freedom is the denominator — periodicity is a *purely Diophantine* (not combinatorial) phenomenon. One direction (irrational $\Rightarrow$ non-periodic) is already established constructively; the converse needs only an explicit periodic witness for rationals.

**C2. Optimal Diophantine exponent characterises quadratic irrationals.** *Conjecture.* Among the slopes $\alpha$ with $\alpha$ Diophantine (separation $c/b^2$), the ones whose exponent $2$ is *optimal* (badly approximable but no better) are exactly the quadratic irrationals; equivalently the constant can be taken $= 1/(2\sqrt d+1)$ only in the quadratic case, and $\alpha$ with unbounded continued fraction admits no uniform $c/b^2$ bound. The surd identity forces a $1/b^2$ lower bound from a *single* nonzero-integer constraint, the algebraic signature of degree $2$; higher degree or Liouville slopes break exactly this step. Turning "$\ge 1$ forces exponent $2$" into "exponent $2$ forces degree $\le 2$" is the natural dual.

**C3. Joint (pair) Diophantine strength controls the aperiodicity rate.** *Conjecture.* Define the joint constant $c(\alpha,\beta) = \min(c_\alpha, c_\beta)$. The number of distinct $R\times R$ patterns of $W(\alpha,\beta)$ (its pattern-complexity function $p(R)$) grows like $\Theta(R^2)$ with the implied constant monotone in $1/c(\alpha,\beta)$; for a pair of quadratic irrationals it is exactly $\Theta(R^2)$ (linear complexity in each direction $\times$ product). The strong aperiodicity proven here is the qualitative shadow of a quantitative complexity bound, and the Diophantine constant is the exact quantitative knob. With aperiodicity formalised, complexity counting becomes a finite combinatorial statement per $R$, checkable for small $R$ and then generalised.

**C4. Independence of slopes and genuine two-dimensionality.** A direction toward a genuinely two-dimensional theory: understanding when the pair $(\alpha,\beta)$ behaves independently in the two axes versus exhibiting coupled, lattice-like resonances, and how the joint Diophantine data governs the transition.

### 7.4 Honest scope

We prove *sufficiency*, not necessity: Diophantine pairs certify strong aperiodicity, but we do not claim they exhaust the aperiodic stripe sets (irrational-but-not-Diophantine pairs are still aperiodic). The model is the Beatty stripe skeleton of a Wang set rather than an arbitrary aperiodic protoset, and the constant $1/4$ for $\sqrt 2$, while clean and uniform, is not the asymptotically optimal one. These boundaries are deliberate; the conjectures of §7.3 chart the path toward the converse and the exponent-optimality characterization.

---

## 8. Conclusion

We have isolated a sharp, falsifiable, fully explicit condition — being Diophantine of exponent $2$ — that strengthens the qualitative "irrational density" hypothesis and certifies strong aperiodicity of Wang stripe sets. The condition is non-vacuous, witnessed by the quadratic surds $\sqrt 2$ and $\sqrt 3$ with explicit constants $1/(2\sqrt d + 1)$ (improving to $1/4$ for $\sqrt 2$), and it feeds a transparent logical chain ending in the concrete strongly aperiodic family $W(\sqrt 2, \sqrt 3)$. The exponent $2$ is revealed as the algebraic fingerprint of degree-two irrationality, and the explicit separation constants turn the binary notion of aperiodicity into a measurable, computable phenomenon.
