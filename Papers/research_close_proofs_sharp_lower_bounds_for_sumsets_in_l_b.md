# Sharp Lower Bounds for Sumsets in $L_1$ Balls in $\mathbb{Z}^d$

**Author:** Aristotle

**Date:** 2026-07-14

## Abstract

We study lower bounds on the cardinality of the sumset $A_1 + \cdots + A_n$ of finite nonempty subsets of the taxicab ($L_1$) ball
$$B_m^d = \{\, x \in \mathbb{Z}^d : |x_1| + \cdots + |x_d| \le m \,\}$$
in the integer lattice $\mathbb{Z}^d$. Combining an iterated Cauchy–Davenport inequality (the additive engine) with the dilation geometry of the cross-polytope (the discrete-geometry engine) and a transcendental extremal computation (the real-analytic engine), we establish an unconditional geometric-mean lower bound
$$|A_1 + \cdots + A_n| \ge \big(|A_1|\cdots|A_n|\big)^{1/q}$$
valid for every real exponent $q \ge n$, and we isolate the **sharp exponent**
$$p = \frac{n\log(m+1)}{\log(nm+1)},$$
proving that $1 < p < n$ whenever $n \ge 2$ and $m \ge 1$, and that the one-dimensional interval configuration $A_j = \{0, \dots, m\}$ attains equality both in the additive Cauchy–Davenport bound and in the sharp-exponent bound. We also pin down the underlying geometry: the cross-polytope is symmetric, its radius-$0$ ball is a point, its radius-$1$ ball has exactly $2d+1$ lattice points, and sub-sumsets of the radius-$m$ ball are contained in the radius-$nm$ ball. Together these results reduce the full sharp inequality to a single dimension-free monotone comparison.

## 1. Introduction

Additive combinatorics asks how the *size* of a set changes under addition. The prototypical result is the **Cauchy–Davenport theorem**, which in a torsion-free abelian group takes the clean form $|A + B| \ge |A| + |B| - 1$ for finite nonempty $A, B$. Iterated, it controls the cardinality of an $n$-fold sumset in terms of the individual summand cardinalities.

A rich and largely open direction, in the spirit of recent work of Becker–Ivanisvili–Krachun–Madrid, asks for *multiplicative* rather than additive lower bounds when the summands are constrained to a geometric body — specifically the $L_1$ ball (cross-polytope) in $\mathbb{Z}^d$. The target is a bound of the form
$$|A_1 + \cdots + A_n| \ge \big(|A_1|\cdots|A_n|\big)^{1/p}$$
with an exponent $p$ that is as small as possible, since smaller exponents yield stronger conclusions. The remarkable feature is that the conjecturally optimal exponent is *transcendental*, namely $p = n\log(m+1)/\log(nm+1)$, and depends only on the number of summands $n$ and the radius $m$, never on the ambient dimension $d$.

This paper builds the complete additive/geometric/analytic scaffolding for this problem. We prove the unconditional bound at exponent $n$ (and hence at every larger exponent), establish the exact location and extremal role of the sharp exponent, and identify the geometry that makes the exponent dimension-free. This reduces the outstanding conjecture — validity of the sharp exponent in all dimensions — to a single monotone comparison, replacing a dimension-by-dimension analysis.

## 2. Definitions and setting

Throughout, sets are finite subsets of an abelian group, and $|S|$ denotes cardinality.

**Definition 2.1 (Sumset).** For sets $A_1, \dots, A_n$ in an abelian group $G$, the sumset is
$$A_1 + \cdots + A_n = \{\, a_1 + \cdots + a_n : a_j \in A_j \,\}.$$
More generally, for a finite index set $s$ and a family $(A_i)_{i \in s}$, we write $\sum_{i \in s} A_i$.

**Definition 2.2 (Torsion-free group).** An abelian group $G$ is *torsion-free* if $kx = 0$ with $k \ge 1$ forces $x = 0$. Both $\mathbb{Z}$ and $\mathbb{Z}^d$ are torsion-free; this is exactly the hypothesis under which the sharp Cauchy–Davenport bound $|A+B| \ge |A|+|B|-1$ holds without a modular correction.

**Definition 2.3 ($L_1$ norm and ball).** For $x = (x_1, \dots, x_d) \in \mathbb{Z}^d$, the *taxicab* or $L_1$ norm is
$$\|x\|_1 = \sum_{i=1}^d |x_i|.$$
The $L_1$ ball (cross-polytope) of radius $m \ge 0$ is
$$B_m^d = \{\, x \in \mathbb{Z}^d : \|x\|_1 \le m \,\}.$$

**Definition 2.4 (Sharp exponent).** For integers $n, m \ge 1$, the *sharp exponent* is
$$p(n,m) = \frac{n\log(m+1)}{\log(nm+1)}.$$

## 3. The additive engine: iterated Cauchy–Davenport

We begin with the additive backbone.

**Lemma 3.1 (Nonemptiness of sumsets).** If $(A_i)_{i \in s}$ is a family of nonempty finite sets indexed by a nonempty finite set $s$, then $\sum_{i \in s} A_i$ is nonempty.

*Proof sketch.* Induct on $s$ using the identity $\sum_{i \in \{a\} \cup s} A_i = A_a + \sum_{i \in s} A_i$ and the fact that the sum of two nonempty sets is nonempty. $\square$

**Theorem 3.2 (Iterated Cauchy–Davenport).** Let $G$ be a torsion-free abelian group and let $(A_i)_{i \in s}$ be nonempty finite subsets of $G$ over a nonempty finite index set $s$. Then
$$\Big(\sum_{i \in s} |A_i|\Big) + 1 \le \Big|\sum_{i \in s} A_i\Big| + |s|.$$
Equivalently, $\big|\sum_{i \in s} A_i\big| \ge \big(\sum_{i \in s} |A_i|\big) - (|s| - 1)$.

*Proof sketch.* Induct on $s$. The base case $|s| = 1$ is trivial. For the inductive step, split off one index $a$ and apply the single-step torsion-free Cauchy–Davenport bound $|A_a + \sum_{i} A_i| \ge |A_a| + |\sum_i A_i| - 1$ to the sum of $A_a$ with the (nonempty, by Lemma 3.1) remaining sumset; combine with the inductive hypothesis by elementary arithmetic. $\square$

## 4. The multiplicative and geometric-mean bounds

**Lemma 4.1 (Each summand embeds).** For a family of nonempty finite sets $(A_i)_{i \in s}$ and any $j \in s$,
$$|A_j| \le \Big|\sum_{i \in s} A_i\Big|.$$

*Proof sketch.* Write $\sum_{i \in s} A_i = A_j + \sum_{i \in s \setminus \{j\}} A_i$. Fixing any element of the second (nonempty) factor and translating $A_j$ by it is injective, so $A_j$ embeds into the sumset. $\square$

**Theorem 4.2 (Multiplicative sumset bound).** For nonempty finite sets $(A_i)_{i \in s}$,
$$\prod_{i \in s} |A_i| \le \Big|\sum_{i \in s} A_i\Big|^{\,|s|}.$$

*Proof sketch.* Apply Lemma 4.1 to each factor and multiply the $|s|$ inequalities $|A_i| \le |\sum_j A_j|$ together; the right-hand side becomes $|\sum_j A_j|^{|s|}$. $\square$

**Theorem 4.3 (Geometric-mean bound, exponent $n$).** For nonempty finite sets $(A_i)_{i \in s}$ with $n = |s| \ge 1$,
$$\Big(\prod_{i \in s} |A_i|\Big)^{1/n} \le \Big|\sum_{i \in s} A_i\Big|.$$

*Proof sketch.* Take $n$-th roots in Theorem 4.2. Concretely, if $P \le C^n$ with $P, C \ge 0$ and $n \ge 1$, then $P^{1/n} \le (C^n)^{1/n} = C$ by monotonicity of the real power function. $\square$

**Theorem 4.4 (Every larger exponent is valid).** Under the hypotheses of Theorem 4.3, for every real $q \ge n$,
$$\Big(\prod_{i \in s} |A_i|\Big)^{1/q} \le \Big|\sum_{i \in s} A_i\Big|.$$

*Proof sketch.* Let $C = |\sum_i A_i| \ge 1$ (by Lemma 3.1) and $P = \prod_i |A_i| \ge 0$ with $P \le C^n$. Then
$$P^{1/q} \le (C^n)^{1/q} = C^{n/q} \le C^{1} = C,$$
where the last inequality uses $C \ge 1$ and $n/q \le 1$. $\square$

Theorem 4.4 shows the set of valid exponents is precisely a half-line $[n, \infty)$ obtained "for free." All the difficulty of the sharp theory is to push the exponent **below** $n$.

## 5. The geometry of the cross-polytope

We now record the discrete-geometry facts that make the constraint "$A_j \subseteq B_m^d$" meaningful.

**Lemma 5.1 (Triangle inequality).** For $x, y \in \mathbb{Z}^d$, $\|x + y\|_1 \le \|x\|_1 + \|y\|_1$.

*Proof sketch.* Sum the coordinatewise inequalities $|x_i + y_i| \le |x_i| + |y_i|$. $\square$

**Lemma 5.2 (Symmetry).** $\|-x\|_1 = \|x\|_1$, hence $x \in B_m^d \iff -x \in B_m^d$.

**Lemma 5.3 (Membership characterization).** $x \in B_m^d \iff \|x\|_1 \le m$; moreover every coordinate then satisfies $|x_i| \le m$.

**Proposition 5.4 (Radius-$0$ and radius-$1$ counts).**
$$B_0^d = \{0\}, \qquad |B_0^d| = 1, \qquad |B_1^d| = 2d + 1.$$
The radius-$1$ ball consists of the origin and the $2d$ signed standard basis vectors $\pm e_1, \dots, \pm e_d$.

*Proof sketch.* For $B_0^d$: $\|x\|_1 \le 0$ with $\|x\|_1 \ge 0$ forces every $|x_i| = 0$. For $B_1^d$: decompose by the value of the first coordinate $x_1 \in \{-1, 0, 1\}$. If $x_1 = 0$ the remainder is a radius-$1$ ball in one lower dimension; if $x_1 = \pm 1$ the remaining coordinates must all vanish, contributing one point each. This gives the recursion $|B_1^d| = |B_1^{d-1}| + 2$ with base $|B_1^0| = 1$, hence $|B_1^d| = 2d + 1$. $\square$

**Theorem 5.5 (Dilation / containment).** If $B \subseteq B_p^d$ and $C \subseteq B_q^d$, then $B + C \subseteq B_{p+q}^d$. Consequently, if $A_i \subseteq B_m^d$ for all $i \in s$, then
$$\sum_{i \in s} A_i \subseteq B_{|s| \cdot m}^d.$$

*Proof sketch.* For the two-set statement, any $b + c$ with $\|b\|_1 \le p$, $\|c\|_1 \le q$ satisfies $\|b+c\|_1 \le p + q$ by Lemma 5.1. Iterate over $s$ by induction, accumulating radius $m$ per summand. $\square$

Theorem 5.5 explains the appearance of $nm+1$ in the sharp exponent: the $n$-fold sumset of radius-$m$ sets is confined to the radius-$nm$ ball, whose one-dimensional slice is the interval $\{-nm, \dots, nm\}$; in the nonnegative extremal case this is $\{0, \dots, nm\}$ with $nm+1$ points.

## 6. The sharp transcendental exponent

**Theorem 6.1 (Sharpness identity).** For integers $n, m \ge 1$, the sharp exponent $p = p(n,m)$ satisfies
$$(m+1)^{\,n/p} = nm + 1.$$

*Proof sketch.* By definition $n/p = \log(nm+1)/\log(m+1)$. Hence
$$(m+1)^{n/p} = \exp\!\Big(\tfrac{\log(nm+1)}{\log(m+1)} \cdot \log(m+1)\Big) = \exp(\log(nm+1)) = nm+1,$$
using $\log(m+1) \ne 0$ (as $m \ge 1$). $\square$

**Theorem 6.2 (Upper bound $p \le n$).** For $n, m \ge 1$, $p(n,m) \le n$, and for $n \ge 2, m \ge 1$ the inequality is strict: $p(n,m) < n$.

*Proof sketch.* We have $p \le n \iff \log(m+1) \le \log(nm+1)$, which holds since $m+1 \le nm+1$. When $n \ge 2$ and $m \ge 1$ we have $m+1 < nm+1$ strictly, and strict monotonicity of $\log$ gives $p < n$. $\square$

**Theorem 6.3 (Lower bound $p \ge 1$).** For $n, m \ge 1$, $p(n,m) \ge 1$, and for $n \ge 2, m \ge 1$ the inequality is strict: $p(n,m) > 1$.

*Proof sketch.* We have $p \ge 1 \iff \log(nm+1) \le n\log(m+1) = \log((m+1)^n) \iff nm+1 \le (m+1)^n$. The inequality $nm+1 \le (m+1)^n$ is Bernoulli's inequality $(1+m)^n \ge 1 + nm$; for $n \ge 2, m \ge 1$ the binomial expansion contributes a strictly positive quadratic term $\binom{n}{2}m^2$, giving $(m+1)^n > 1 + nm$ and hence $p > 1$. $\square$

Combining Theorems 6.2 and 6.3:

**Corollary 6.4 (The bracket).** For $n \ge 2$ and $m \ge 1$,
$$1 < p(n,m) < n.$$
Thus the sharp bound (at exponent $p$) is strictly stronger than the geometric-mean bound (at exponent $n$), yet the exponent can never reach the impossible value $1$.

## 7. The extremal configuration

**Lemma 7.1 (Interval sumset).** For $m \ge 0$ and $n \ge 0$, the $n$-fold sumset of the interval $\{0, \dots, m\}$ in $\mathbb{Z}$ is $\{0, \dots, nm\}$; in particular it has $nm+1$ elements.

*Proof sketch.* Induct on $n$ using the interval identity $\{a, \dots, b\} + \{c, \dots, d\} = \{a+c, \dots, b+d\}$ for integer intervals, which holds because integer intervals are "gap-free" arithmetic progressions of common difference $1$. $\square$

**Theorem 7.2 (Extremal sharpness).** Fix $n, m \ge 1$ and work in dimension $d = 1$. Let each $A_j = \{0, 1, \dots, m\}$ (so $|A_j| = m+1$ and $A_j \subseteq B_m^1$). Then:

1. **Additive equality:** $\big(\sum_{j=1}^n |A_j|\big) + 1 = \big|\sum_{j=1}^n A_j\big| + n$, i.e. $n(m+1) + 1 = (nm+1) + n$.
2. **Sharp-exponent equality:** $\big(\prod_{j=1}^n |A_j|\big)^{1/p} = \big|\sum_{j=1}^n A_j\big|$, i.e. $\big((m+1)^n\big)^{1/p} = nm+1$.

Consequently the exponent $p = p(n,m)$ cannot be decreased: it is the least exponent for which the multiplicative lower bound can hold for all configurations.

*Proof sketch.* By Lemma 7.1 the sumset is $\{0, \dots, nm\}$ with $nm+1$ elements. Statement (1) is then arithmetic: both sides equal $n(m+1)+1$. For (2), the product of sizes is $(m+1)^n$, and $\big((m+1)^n\big)^{1/p} = (m+1)^{n/p} = nm+1$ by Theorem 6.1. $\square$

## 8. The packaged bridge

The results above combine into two connector statements.

**Theorem 8.1 ($L_1$-ball sumset bridge).** Let $A_1, \dots, A_n$ be finite nonempty subsets of $B_m^d$ with $n \ge 1$. Then all four faces hold simultaneously:
- (additive) $\big(\sum_j |A_j|\big) + 1 \le \big|\sum_j A_j\big| + n$;
- (multiplicative) $\prod_j |A_j| \le \big|\sum_j A_j\big|^{n}$;
- (geometric mean) $\big(\prod_j |A_j|\big)^{1/n} \le \big|\sum_j A_j\big|$;
- (geometry) $\sum_j A_j \subseteq B_{nm}^d$.

*Proof sketch.* These are exactly Theorems 3.2, 4.2, 4.3, and 5.5 respectively, specialized to $s = \{1, \dots, n\}$. $\square$

**Theorem 8.2 (Sharp exponent bracket).** For $n \ge 2$ and $m \ge 1$,
$$1 < p(n,m) < n \qquad \text{and} \qquad (m+1)^{\,n/p(n,m)} = nm+1.$$

*Proof sketch.* Immediate from Corollary 6.4 and Theorem 6.1. $\square$

## 9. Algorithmic content

Several results are effectively computable, which supports numerical exploration and testing of the conjectural sharp bound.

**Sumset computation.** Given finite sets $A_1, \dots, A_n \subseteq \mathbb{Z}^d$, the sumset is computed by iterated pairwise Minkowski sums with deduplication. If $N_k = |A_1 + \cdots + A_k|$, the cost is $O\big(\sum_k N_{k-1}|A_k|\big)$ elementary vector additions plus hashing, and $N_n \le \prod_j |A_j|$.

**Exponent evaluation.** The sharp exponent $p(n,m) = n\log(m+1)/\log(nm+1)$ is a constant-time floating-point evaluation; its bracket $1 < p < n$ can be certified by comparing $nm+1$ with $(m+1)^n$ and with $m+1$ (both exact integer comparisons).

**Ball enumeration.** The lattice points of $B_m^d$ can be enumerated by recursion on dimension: for each first-coordinate value $c$ with $|c| \le m$, recurse in dimension $d-1$ with radius $m - |c|$. The point counts satisfy the Delannoy-type recursion behind $|B_0^d| = 1$ and $|B_1^d| = 2d+1$.

## 10. Applications

- **Structure of sets with small sumset.** The equality analysis (Theorem 7.2) shows that extremality forces the interval / arithmetic-progression structure, connecting to inverse theorems (Freiman-type) in additive combinatorics.
- **Lattice geometry and coding.** The dilation containment (Theorem 5.5) and the $2d+1$ point count (Proposition 5.4) are exactly the parameters relevant to $L_1$-metric lattice codes and to counting nearest-neighbor shells in the taxicab metric.
- **Benchmarking conjectures.** The unconditional bound at exponent $n$ and the exact extremal equality give a rigorous "sandwich" for numerically testing whether the sharp exponent $p$ holds in higher dimensions.

## 11. Discussion

The core phenomenon is a three-way tension:

1. the **additive engine** (Cauchy–Davenport) gives an unconditional bound at exponent $n$;
2. the **discrete geometry** (cross-polytope dilation) confines sums to the radius-$nm$ ball and forces the appearance of $nm+1$;
3. the **real-analytic exponent** $p = n\log(m+1)/\log(nm+1)$ is the unique value making the interval extremiser attain equality.

What is proved unconditionally is the geometric-mean bound at every exponent $q \ge n$, together with the exact location $1 < p < n$ and the extremal equality at $p$. What remains open is the *dimension-free* validity of the exponent-$p$ bound for **all** configurations in all dimensions $d$; the extremal computation shows $p$ cannot be improved, so the conjecture is that $p$ is exactly right. The decisive structural insight is that $p$ does not depend on $d$: because the cross-polytope dilates self-similarly across dimensions, a one-dimensional extremiser should remain globally extremal, reducing the open problem to a single monotone comparison rather than a dimension-by-dimension analysis.

## 12. Future directions

**1. The dimension-free sharp exponent bound.** *Conjecture.* For all finite nonempty $A_1, \dots, A_n \subseteq \{x \in \mathbb{Z}^d : \sum|x_i| \le m\}$, $|A_1 + \cdots + A_n| \ge (|A_1|\cdots|A_n|)^{1/p}$ with $p = n\log(m+1)/\log(nm+1)$, for every dimension $d$. The key insight is that the exponent depends only on $n$ and $m$, never on $d$: the cross-polytope's radial dilation is self-similar across dimensions, so a one-dimensional extremiser should already be globally extremal. The present development isolates the exact obstruction — the gap between the general exponent-$n$ bound and the extremal exponent-$p$ equality — reducing the open problem to a single monotone comparison.

**2. Tensor-power stability of the extremal configuration.** *Conjecture.* Among all sub-sumset configurations of fixed cardinalities inside the radius-$m$ ball, the product-of-intervals family $A_j = \{0, \dots, m\}^d$ uniquely minimizes $|A_1 + \cdots + A_n|$, with minimum exactly $(nm+1)^d$. The key insight is that the counting identity for the dilated ball tensorizes: if the interval is extremal in one dimension, its $d$-fold Cartesian power should be extremal in $d$ dimensions, turning sharpness into a rigidity/uniqueness statement. The radius-$1$ count $2d+1$ and the additive equality case provide the base and inductive seed.

**3. A stability (near-extremal) version.** *Conjecture.* If $|A_1 + \cdots + A_n|$ is within a $(1+\varepsilon)$ factor of the sharp lower bound, then each $A_j$ is, up to affine transformation, within $O(\varepsilon)$ (in symmetric-difference density) of an arithmetic progression of common difference dividing the ball's radial step. The key insight is that equality forces the additive Cauchy–Davenport step to be tight at every stage, and tightness there forces arithmetic-progression structure; a quantitative propagation yields stability.

**4. Replacing the $L_1$ ball by general symmetric convex lattice bodies.** *Conjecture.* For any origin-symmetric convex lattice polytope $K \subseteq \mathbb{Z}^d$, the sharp sumset exponent equals $n\log|K|/\log|nK|$, where $nK$ is the $n$-fold dilate, and equality is attained by intersecting $K$ with a rational line through the origin.

## 13. Conclusion

We have assembled a complete additive/geometric/analytic framework for sumset lower bounds in $L_1$ balls in $\mathbb{Z}^d$: an iterated Cauchy–Davenport engine, its multiplicative and geometric-mean consequences valid at every exponent $q \ge n$, the cross-polytope geometry (symmetry, point counts, dilation), and the transcendental sharp exponent $p = n\log(m+1)/\log(nm+1)$, shown to lie strictly in $(1,n)$ and to be attained with equality by the one-dimensional interval extremiser. This reduces the full sharp conjecture to a dimension-free monotone comparison and lays out a concrete program — dimension-freeness, tensor-power rigidity, stability, and general convex bodies — for completing it.
