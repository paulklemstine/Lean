# Generalization Bounds via Rademacher Complexity: Exact Values, Margin Bounds, and the Failure of Counting

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

We develop, from first principles and in complete detail, the theory of *empirical Rademacher complexity* as a measure of the capacity of a hypothesis class, and use it to establish generalization bounds for supervised learning. Working with the exact finite average over the $2^n$ sign patterns of a sample of size $n$, we establish: (i) the basic calculus of the complexity functional — vanishing on singletons, monotonicity, nonnegativity, and boundedness by any uniform bound on the outputs; (ii) the *margin bound* $\widehat{\mathcal{R}} \le WB/\sqrt n$ for linear predictors of weight-norm at most $W$ on sample points of norm at most $B$ in an **arbitrary** real inner product space, together with its kernel form, which depends on the kernel only through $\sup_x K(x,x)$; (iii) *Massart's finite class lemma* $\widehat{\mathcal{R}} \le r\sqrt{2\log N}/n$ together with the exact evaluation $\widehat{\mathcal{R}}(\{-1,1\}^n) = 1$, which shows the lemma is tight up to the single absolute constant $\sqrt{2\log 2} \in [1, 6/5)$; (iv) the exact evaluation $\widehat{\mathcal{R}}(\mathrm{Ball}_n(r)) = r/\sqrt n$ for the Euclidean ball, together with the fact that this class is infinite — so every counting-based (VC/growth-function/Massart) bound is vacuous for it — and the quantitative statement that any dimension-dependent bound of the form $c\sqrt{d/n}$ is strictly worse than the margin bound once $d > (WB/c)^2$; and (v) the *symmetrization inequality* $\mathbb{E}_S[\sup_f(\mathbb{E}f - \widehat{\mathbb{E}}_S f)] \le 2\,\mathbb{E}_S[\widehat{\mathcal{R}}_S(\mathcal{F})]$ over a finite domain with an arbitrary product measure, from which we deduce the generalization bound $2B\sqrt{2\log N/n}$ for finite classes. Taken together these results give a sharp two-regime picture: on unstructured finite classes counting is essentially optimal, while on geometrically constrained continuous classes — balls, linear predictors, kernel machines — counting is infinitely loose and the Rademacher measurement is exact.

**Keywords:** Rademacher complexity, generalization bound, margin bound, kernel methods, symmetrization, Massart's lemma, VC dimension, statistical learning theory.

---

## 1. Introduction

### 1.1 The problem

A learning algorithm sees a finite sample and returns a hypothesis that performs well on it. The central question of statistical learning theory is: *when does good performance on the sample imply good performance on the underlying distribution?* Since the algorithm selects the hypothesis after seeing the data, the guarantee must be **uniform** over the hypothesis class $\mathcal{F}$; the quantity to control is

$$\mathrm{gap}(S) \;=\; \sup_{f \in \mathcal{F}}\big( \mathbb{E}f - \widehat{\mathbb{E}}_S f\big),$$

where $\widehat{\mathbb{E}}_S f = \frac1n\sum_{i=1}^n f(x_i)$ is the empirical mean on the sample $S = (x_1,\dots,x_n)$ and $\mathbb{E}f$ the true mean.

The classical answer measures $\mathcal{F}$ combinatorially, via the **VC dimension** — the largest $n$ for which $\mathcal{F}$ realizes all $2^n$ labelings of some $n$ points — and yields bounds of the shape $c\sqrt{d/n}$. This answer has two well-known defects. First, it is *distribution-free* to a fault: it does not see that the actual data may occupy a small, well-behaved region. Second, and more seriously, it is a **counting** bound: it degenerates when the class realizes infinitely many behaviours on the sample, which is the generic situation for real-valued predictors and for every kernel method.

### 1.2 Our contribution

We build the alternative — Rademacher complexity — from the ground up, with all statements made precise and all constants explicit. Three things distinguish the development here.

1. **Exact values, not just bounds.** We compute $\widehat{\mathcal{R}}$ *exactly* for two fundamental classes: the full sign cube (value $1$) and the Euclidean ball of radius $r$ (value $r/\sqrt n$). Exact values are what make the comparison with counting bounds decisive rather than suggestive.

2. **Complete dimension-freedom.** The margin bound is proved in an arbitrary real inner product space, with no finiteness or separability hypothesis; the dimension of the ambient space does not appear in the statement or in the proof. This is what licenses the kernel form.

3. **A quantitative separation.** We prove a precise threshold beyond which any dimension-dependent bound is strictly weaker than the dimension-free margin bound, and we exhibit a class on which counting bounds are not merely weak but vacuous.

### 1.3 Organization

Section 2 gives the definitions and the elementary calculus. Section 3 proves symmetrization and the resulting generalization bound. Section 4 proves Massart's lemma and establishes its tightness. Section 5 computes the complexity of the Euclidean ball and proves the failure of counting. Section 6 proves the margin bound and its kernel form and gives the quantitative comparison with dimension-dependent bounds. Section 7 gives algorithms for estimating and computing these quantities. Section 8 discusses applications, Section 9 limitations and future work.

---

## 2. Definitions and the Basic Calculus

Throughout, $n \ge 1$ is the sample size.

### 2.1 Sign patterns and the complexity functional

**Definition 2.1 (Sign patterns).** A *sign pattern* is a vector $\sigma \in \{-1,+1\}^n$. We index them by $\varepsilon \in \{\texttt{true},\texttt{false}\}^n$ via $\sigma_i = +1$ if $\varepsilon_i = \texttt{true}$ and $\sigma_i = -1$ otherwise. There are $2^n$ of them, and the *Rademacher distribution* is the uniform distribution on this set. Two identities are used constantly: $|\sigma_i| = 1$ and $\sigma_i^2 = 1$.

**Definition 2.2 (Sign average).** For a sign pattern $\sigma$ and a vector $v \in \mathbb{R}^n$, the *sign average* is
$$A_\sigma(v) \;=\; \frac1n \sum_{i=1}^n \sigma_i v_i.$$

**Definition 2.3 (Empirical Rademacher complexity).** For a set $F \subseteq \mathbb{R}^n$ of behaviour vectors,
$$\widehat{\mathcal{R}}(F) \;=\; \frac{1}{2^n}\sum_{\sigma \in \{-1,1\}^n} \; \sup_{v\in F} A_\sigma(v).$$

If $\mathcal{F}$ is a class of functions $X \to \mathbb{R}$ and $S = (x_1,\dots,x_n)$ a sample, we write $\widehat{\mathcal{R}}_S(\mathcal{F}) = \widehat{\mathcal{R}}(F_S)$ where $F_S = \{(f(x_1),\dots,f(x_n)) : f \in \mathcal{F}\}$ is the restriction of $\mathcal{F}$ to $S$. Note that only $F_S$ matters: two classes that agree on the sample have the same empirical complexity.

**Interpretation.** $A_\sigma(v)$ is the empirical correlation of the outputs $v$ with the random $\pm1$ labels $\sigma$. So $\widehat{\mathcal{R}}(F)$ measures, on average over label noise, how well the *best* member of the class fits pure noise. A class that can fit any noise has complexity near its output scale; a class that cannot has complexity near zero.

### 2.2 A symmetry lemma

Almost every elementary fact below rests on one observation.

**Lemma 2.4 (Sign-flip symmetry).** The map $\sigma \mapsto -\sigma$ is an involution of the set of sign patterns. Consequently, for any $g : \{-1,1\}^n \to \mathbb{R}$,
$$\sum_\sigma g(-\sigma) = \sum_\sigma g(\sigma).$$
In particular, taking $g(\sigma)=\sigma_i$: $\sum_\sigma \sigma_i = 0$ for every coordinate $i$.

*Proof.* Negation is a bijection of the index set onto itself and is its own inverse, so it merely reindexes the sum. For the consequence, $\sum_\sigma \sigma_i = \sum_\sigma(-\sigma_i) = -\sum_\sigma \sigma_i$, whence the sum is zero. $\square$

A refinement of the same idea, flipping only one coordinate, gives the decorrelation identity used in Section 6.

**Lemma 2.5 (Decorrelation).** For $i \ne j$, $\;\sum_\sigma \sigma_i \sigma_j = 0$; and $\sum_\sigma \sigma_i^2 = 2^n$.

*Proof.* The map that flips the $i$-th coordinate and leaves the rest alone is an involution of the sign patterns which negates $\sigma_i$ and fixes $\sigma_j$, hence negates the summand $\sigma_i\sigma_j$; reindexing shows the sum equals its own negative. The second claim is immediate from $\sigma_i^2 = 1$. $\square$

### 2.3 The calculus

**Theorem 2.6 (Singletons have zero complexity).** For any $v \in \mathbb{R}^n$, $\widehat{\mathcal{R}}(\{v\}) = 0$.

*Proof.* The supremum over a singleton is $A_\sigma(v)$, so $\widehat{\mathcal{R}}(\{v\}) = 2^{-n}\sum_\sigma \frac1n\sum_i \sigma_i v_i$. Exchanging the order of summation and applying Lemma 2.4 coordinatewise, each inner sum $\sum_\sigma \sigma_i v_i = v_i \sum_\sigma \sigma_i = 0$. $\square$

This is the base case of the theory: a class with no freedom of choice cannot correlate with noise, and cannot overfit.

**Theorem 2.7 (Monotonicity).** If $F \subseteq G$, $F \neq \emptyset$, and each $\sup_{v \in G} A_\sigma(v)$ is finite, then $\widehat{\mathcal{R}}(F) \le \widehat{\mathcal{R}}(G)$.

*Proof.* For each $\sigma$, $A_\sigma(F) \subseteq A_\sigma(G)$, so the suprema are ordered; sum and divide by $2^n > 0$. $\square$

**Theorem 2.8 (Nonnegativity).** If $F \neq \emptyset$ and all suprema are finite, then $\widehat{\mathcal{R}}(F) \ge 0$.

*Proof.* Fix any $v \in F$. For each $\sigma$, $\sup_{u\in F} A_\sigma(u) \ge A_\sigma(v)$ and $\sup_{u\in F} A_{-\sigma}(u) \ge A_{-\sigma}(v) = -A_\sigma(v)$. Adding, the pair $(\sigma, -\sigma)$ contributes a nonnegative total. Summing over all $\sigma$ and using Lemma 2.4 to identify $\sum_\sigma \sup_u A_{-\sigma}(u)$ with $\sum_\sigma \sup_u A_\sigma(u)$, we get $2\sum_\sigma \sup_u A_\sigma(u) \ge 0$. $\square$

The mechanism is worth naming: **the supremum over a symmetric average of $\pm$ correlations cannot be negative**, because no matter how badly the class correlates with $\sigma$, it correlates equally well with $-\sigma$.

**Theorem 2.9 (Uniform output bound).** Let $B \ge 0$. If $|v_i| \le B$ for all $v \in F$ and all $i$, then $\widehat{\mathcal{R}}(F) \le B$.

*Proof.* For each $\sigma$ and $v$, $A_\sigma(v) \le \frac1n \sum_i |\sigma_i||v_i| \le \frac1n \cdot nB = B$; hence each supremum is $\le B$ and the average is $\le B$. $\square$

**Lemma 2.10 (Sandwich principle).** If $\sup_{v \in F} A_\sigma(v) \le c$ for every $\sigma$ then $\widehat{\mathcal{R}}(F) \le c$; if $\sup_{v\in F} A_\sigma(v) \ge c$ for every $\sigma$ then $\widehat{\mathcal{R}}(F) \ge c$.

*Proof.* Average the pointwise inequality over the $2^n$ patterns. $\square$

Lemma 2.10 is the workhorse for exact computations: if one can show that the supremum takes the *same* value $c$ for every sign pattern — which happens for both the cube and the ball, by symmetry — then $\widehat{\mathcal{R}}(F) = c$ exactly.

---

## 3. Symmetrization: Why Rademacher Complexity Controls Generalization

We now justify the definition. We work over a finite domain $X$ with a probability vector $p : X \to [0,\infty)$, $\sum_{x} p(x)=1$, and the product measure on samples: $w(S) = \prod_{i=1}^n p(S_i)$ for $S \in X^n$. All expectations are explicit finite sums; no measurability issues arise, and the supremum over a finite class is a maximum.

**Definition 3.1.** For a finite nonempty class $\mathcal{F}$ of functions $X \to \mathbb{R}$:
- the empirical mean $\widehat{\mathbb{E}}_S f = \frac1n\sum_i f(S_i)$ and the true mean $\mathbb{E}f = \sum_x p(x) f(x)$;
- the signed empirical average $C_\sigma(S,f) = \frac1n\sum_i \sigma_i f(S_i)$;
- the empirical Rademacher complexity on the sample, $\widehat{\mathcal{R}}_S(\mathcal{F}) = 2^{-n}\sum_\sigma \max_{f\in\mathcal{F}} C_\sigma(S,f)$;
- the uniform deviation $\mathrm{gap}(S) = \max_{f\in\mathcal{F}}(\mathbb{E}f - \widehat{\mathbb{E}}_S f)$.

**Lemma 3.2 (Product measure basics).** $w(S) \ge 0$ for all $S$; $\sum_S w(S) = 1$; the $i$-th marginal is $p$, i.e. $\sum_S w(S)\, g(S_i) = \sum_x p(x)g(x)$ for every $g$ and every $i$. Consequently the empirical mean is unbiased: $\sum_S w(S)\, \widehat{\mathbb{E}}_S f = \mathbb{E}f$.

*Proof.* Nonnegativity is clear. The total mass factorizes as $\prod_i \big(\sum_x p(x)\big) = 1$. For the marginal, sum out the $n-1$ coordinates $j\ne i$, each contributing a factor $1$. Unbiasedness follows by linearity: $\sum_S w(S)\frac1n\sum_i f(S_i) = \frac1n\sum_i \mathbb{E}f = \mathbb{E}f$. $\square$

**Theorem 3.3 (Symmetrization).** For a finite nonempty class $\mathcal{F}$ and $n \ge 1$,
$$\sum_S w(S)\, \mathrm{gap}(S) \;\le\; 2 \sum_S w(S)\, \widehat{\mathcal{R}}_S(\mathcal{F}).$$
In probabilistic notation: $\mathbb{E}_S[\mathrm{gap}(S)] \le 2\,\mathbb{E}_S[\widehat{\mathcal{R}}_S(\mathcal{F})]$.

*Proof.* **Step 1 (ghost sample).** Introduce an independent copy $S'$ with the same product law and define
$$G(S,S') \;=\; \max_{f\in\mathcal{F}} \frac1n\sum_i\big(f(S'_i) - f(S_i)\big).$$
By unbiasedness (Lemma 3.2), for each fixed $f$ we have $\mathbb{E}f = \sum_{S'} w(S')\,\widehat{\mathbb{E}}_{S'}f$, so
$$\mathrm{gap}(S) = \max_f \sum_{S'} w(S')\big(\widehat{\mathbb{E}}_{S'}f - \widehat{\mathbb{E}}_S f\big) \le \sum_{S'} w(S') \max_f \big(\widehat{\mathbb{E}}_{S'}f - \widehat{\mathbb{E}}_S f\big) = \sum_{S'} w(S')\, G(S,S'),$$
because the maximum of a weighted average is at most the weighted average of the maxima (Jensen for the convex function $\max$). Weighting by $w(S)$ and summing,
$$\sum_S w(S)\,\mathrm{gap}(S) \;\le\; \sum_{S,S'} w(S)w(S')\, G(S,S').$$

**Step 2 (swap invariance).** For a sign pattern $\sigma$, let $T_\sigma$ act on pairs $(S,S')$ by exchanging $S_i \leftrightarrow S'_i$ for every $i$ with $\sigma_i = -1$. Then $T_\sigma$ is an involution of $X^n \times X^n$ and preserves the product weight, $w(S)w(S') = w(T_\sigma(S,S')_1)\,w(T_\sigma(S,S')_2)$, since it merely permutes the factors. Moreover
$$G\big(T_\sigma(S,S')\big) \;=\; \max_f \frac1n\sum_i \sigma_i\big(f(S'_i) - f(S_i)\big),$$
because exchanging the $i$-th pair negates the $i$-th difference. Reindexing the double sum by $T_\sigma$ therefore yields, for **every** $\sigma$,
$$\sum_{S,S'} w(S)w(S')\,G(S,S') \;=\; \sum_{S,S'} w(S)w(S')\max_f \frac1n\sum_i \sigma_i\big(f(S'_i)-f(S_i)\big).$$

**Step 3 (split).** Average the previous display over the $2^n$ sign patterns and split each maximum using $\max_f (a_f + b_f) \le \max_f a_f + \max_f b_f$:
$$\max_f \frac1n\sum_i \sigma_i\big(f(S'_i)-f(S_i)\big) \le \max_f C_\sigma(S',f) + \max_f \big(-C_\sigma(S,f)\big).$$
Averaging the second term over $\sigma$ and using Lemma 2.4 ($\sigma \mapsto -\sigma$) turns $\max_f(-C_\sigma(S,f))$ into $\max_f C_\sigma(S,f)$. Hence the double sum is at most $\sum_{S'} w(S')\widehat{\mathcal{R}}_{S'}(\mathcal{F}) + \sum_S w(S)\widehat{\mathcal{R}}_S(\mathcal{F}) = 2\sum_S w(S)\widehat{\mathcal{R}}_S(\mathcal{F})$, since $S$ and $S'$ have the same law. $\square$

**Remark 3.4.** The factor $2$ is an artifact of splitting the difference; it is not known to be improvable by this argument, but it is a constant and does not affect rates. The theorem holds verbatim with $\mathrm{gap}$ replaced by $\sup_f(\widehat{\mathbb{E}}_S f - \mathbb{E}f)$ by symmetry of the argument.

Theorem 3.3 is the reason the coin-flip experiment is meaningful: *the expected uniform overfitting of a class is at most twice its expected ability to fit random labels.*

---

## 4. Counting: Massart's Finite Class Lemma and Its Exact Tightness

### 4.1 The lemma

**Theorem 4.1 (Massart's finite class lemma).** Let $F \subseteq \mathbb{R}^n$ be a finite nonempty set of $N = |F|$ vectors with $\sum_i v_i^2 \le r^2$ for every $v\in F$, where $r \ge 0$. Then
$$\widehat{\mathcal{R}}(F) \;\le\; \frac{r\sqrt{2\log N}}{n}.$$

*Proof.* If $N=1$ both sides are $0$ by Theorem 2.6 and $\log 1 = 0$; assume $N \ge 2$, so $L := \log N > 0$. If $r = 0$ then $F=\{0\}$ and both sides vanish; assume $r>0$. Write $M(\sigma) = \max_{v\in F}\sum_i \sigma_i v_i$ for the unnormalized maximal correlation, so $\widehat{\mathcal{R}}(F) = \frac{1}{n}\cdot 2^{-n}\sum_\sigma M(\sigma)$.

Fix $\lambda>0$. By Jensen's inequality applied to the convex map $t \mapsto e^{t}$ and the uniform measure on sign patterns,
$$\exp\Big(\lambda\, 2^{-n}\textstyle\sum_\sigma M(\sigma)\Big) \;\le\; 2^{-n}\sum_\sigma \exp\big(\lambda M(\sigma)\big).$$
Since $\exp(\lambda \max_v \cdot) = \max_v \exp(\lambda\, \cdot\,) \le \sum_{v\in F}\exp(\lambda\,\cdot\,)$,
$$2^{-n}\sum_\sigma e^{\lambda M(\sigma)} \;\le\; \sum_{v\in F}\; 2^{-n}\sum_\sigma \exp\Big(\lambda\sum_i \sigma_i v_i\Big).$$
The inner average is the Rademacher moment generating function, which **factorizes exactly**: since the coordinates are independent and $\sigma_i$ is uniform on $\{\pm1\}$,
$$2^{-n}\sum_\sigma \exp\Big(\lambda\sum_i \sigma_i v_i\Big) \;=\; \prod_{i=1}^n \frac{e^{\lambda v_i} + e^{-\lambda v_i}}{2} \;=\; \prod_{i=1}^n \cosh(\lambda v_i).$$
The elementary inequality $\cosh t \le e^{t^2/2}$ (compare Taylor coefficients: $\frac{1}{(2k)!} \le \frac{1}{2^k k!}$) gives
$$\prod_i \cosh(\lambda v_i) \le \exp\Big(\tfrac{\lambda^2}{2}\sum_i v_i^2\Big) \le \exp\big(\tfrac{\lambda^2 r^2}{2}\big).$$
Combining and taking logarithms, $\lambda\,2^{-n}\sum_\sigma M(\sigma) \le \log N + \frac{\lambda^2 r^2}{2}$, i.e.
$$2^{-n}\sum_\sigma M(\sigma) \;\le\; \frac{L}{\lambda} + \frac{\lambda r^2}{2}.$$
Choose $\lambda = \sqrt{2L}/r$, which balances the two terms; the right-hand side becomes $r\sqrt{2L}$. Dividing by $n$ gives the claim. $\square$

### 4.2 The bound is tight up to an absolute constant

**Definition 4.2 (Sign cube).** $Q_n = \{-1,+1\}^n \subseteq \mathbb{R}^n$, the class of all $2^n$ sign patterns viewed as behaviour vectors. This is the restriction to the sample of a class that shatters it: the maximally expressive class.

**Theorem 4.3 (Exact complexity of the cube).** For $n \ge 1$, $\;\widehat{\mathcal{R}}(Q_n) = 1$.

*Proof.* Fix $\sigma$. For any $v \in Q_n$, $\sum_i \sigma_i v_i \le \sum_i 1 = n$ since each product of signs is at most $1$; and the choice $v = \sigma \in Q_n$ attains $\sum_i \sigma_i^2 = n$. Hence $\max_{v \in Q_n} A_\sigma(v) = 1$ for every $\sigma$, and Lemma 2.10 gives $\widehat{\mathcal{R}}(Q_n) = 1$. $\square$

**Theorem 4.4 (Tightness of Massart's lemma).** For $n \ge 1$: the exact complexity of $Q_n$ is $1$; Massart's bound applied to $Q_n$ — where $N = 2^n$ and $r = \sqrt n$ — evaluates to
$$\frac{\sqrt n \cdot \sqrt{2\log 2^n}}{n} \;=\; \sqrt{2\log 2},$$
independently of $n$; and
$$1 \;\le\; \sqrt{2\log 2} \;<\; \tfrac{6}{5}.$$

*Proof.* The evaluation uses $\log 2^n = n\log 2$ and $\sqrt{n \cdot 2\log 2} = \sqrt n\sqrt{2\log 2}$, so the expression is $\sqrt n \sqrt n \sqrt{2\log 2}/n = \sqrt{2\log 2}$. The numerical bracket follows from $\log 2 > 1/2$ (so $2\log 2 > 1$) and $\log 2 < 0.6931472 < 18/25$ (so $2\log 2 < 36/25 = (6/5)^2$). $\square$

**Interpretation.** On the *hardest possible* class, Massart's counting bound overestimates the truth by the fixed factor $\sqrt{2\log 2} \approx 1.1774$ — under $18\%$ — for every sample size. The $\sqrt{\log N}$ shape is therefore not an artifact of a lossy proof; it is the correct behaviour for unstructured finite classes.

**Corollary 4.5 (Generalization for finite classes).** Let $\mathcal{F}$ be a finite nonempty class of $N$ functions on a finite domain with $|f(x)| \le B$ for all $f\in\mathcal{F}$, $x\in X$. Then for every sample of size $n \ge 1$,
$$\widehat{\mathcal{R}}_S(\mathcal{F}) \;\le\; \frac{B\sqrt{2\log N}}{\sqrt n},$$
and consequently, for i.i.d. samples from any product measure,
$$\mathbb{E}_S\Big[\sup_{f\in\mathcal{F}}\big(\mathbb{E}f - \widehat{\mathbb{E}}_S f\big)\Big] \;\le\; 2B\sqrt{\frac{2\log N}{n}}.$$

*Proof.* The behaviour vectors satisfy $\sum_i f(S_i)^2 \le nB^2$, i.e. length $\le B\sqrt n$; Theorem 4.1 with $r = B\sqrt n$ gives $B\sqrt n \sqrt{2\log N}/n = B\sqrt{2\log N}/\sqrt n$. (Equivalently, run the Chernoff argument directly with the per-sample scale $c = B^2/n$ and the optimal parameter $\lambda = \sqrt{2L/c}$.) Averaging this uniform-in-$S$ bound against the product weights and inserting it into Theorem 3.3 gives the second display, since $\sum_S w(S) = 1$. $\square$

This is a complete, quantitative, constant-explicit generalization theorem — obtained with no combinatorics beyond counting the class.

---

## 5. Geometry: The Euclidean Ball and the Collapse of Counting

### 5.1 An exact value

**Definition 5.1.** For $r \ge 0$, $\;\mathrm{Ball}_n(r) = \{ v \in \mathbb{R}^n : \sum_{i=1}^n v_i^2 \le r^2 \}$.

**Lemma 5.2 (Upper bound by Cauchy–Schwarz).** For $r \ge 0$, $n \ge 1$, $v \in \mathrm{Ball}_n(r)$ and any sign pattern $\sigma$: $A_\sigma(v) \le r/\sqrt n$.

*Proof.* $\sum_i \sigma_i v_i \le \big(\sum_i \sigma_i^2\big)^{1/2}\big(\sum_i v_i^2\big)^{1/2} \le \sqrt n\, r$; divide by $n$ and use $\sqrt n/n = 1/\sqrt n$. $\square$

**Lemma 5.3 (Attainment).** For $n\ge1$ and any $\sigma$, the vector $v^\sigma := \frac{r}{\sqrt n}\,\sigma$ lies in $\mathrm{Ball}_n(r)$ and satisfies $A_\sigma(v^\sigma) = r/\sqrt n$.

*Proof.* $\sum_i (v^\sigma_i)^2 = \frac{r^2}{n}\sum_i \sigma_i^2 = r^2$, so $v^\sigma$ is in the ball (on its boundary). And $A_\sigma(v^\sigma) = \frac1n \sum_i \sigma_i \cdot \frac{r}{\sqrt n}\sigma_i = \frac{1}{n}\cdot n\cdot\frac{r}{\sqrt n} = \frac{r}{\sqrt n}$. $\square$

**Theorem 5.4 (Exact complexity of the ball).** For $r \ge 0$ and $n \ge 1$,
$$\widehat{\mathcal{R}}\big(\mathrm{Ball}_n(r)\big) \;=\; \frac{r}{\sqrt n}.$$

*Proof.* By Lemmas 5.2 and 5.3, for every $\sigma$ the supremum is *attained* and equals $r/\sqrt n$; apply Lemma 2.10 in both directions. $\square$

**Theorem 5.5 (Dimension-free bound for subclasses).** If $F \subseteq \mathrm{Ball}_n(r)$ then $\widehat{\mathcal{R}}(F) \le r/\sqrt n$.

*Proof.* Immediate from Lemma 5.2 and the upper half of Lemma 2.10. $\square$

### 5.2 Counting bounds are vacuous here

**Theorem 5.6 (The ball is infinite).** For $r > 0$ and $n \ge 1$, $\mathrm{Ball}_n(r)$ is an infinite set.

*Proof.* The map $t \mapsto (t,0,\dots,0)$ is injective on $[0,r]$ and lands in $\mathrm{Ball}_n(r)$, since $t^2 \le r^2$ there. An injective image of an infinite set is infinite. $\square$

**Corollary 5.7 (Failure of counting).** Every bound on $\widehat{\mathcal{R}}$ obtained by counting the number $N$ of behaviours of the class on the sample — Massart's lemma, growth-function bounds, Sauer–Shelah bounds, and hence the standard VC route — is vacuous for $\mathrm{Ball}_n(r)$ with $r>0$: it asserts only $\widehat{\mathcal{R}} \le \infty$. Yet the true value is the finite, exactly known number $r/\sqrt n$.

This is the sharpest possible statement of the gap between the two methodologies. Counting is not "loose" for the ball; it is *silent*. The Rademacher functional, by contrast, sees the correct geometric fact: the ball is small in the Euclidean metric even though it is uncountable as a set, and Euclidean smallness is what noise-fitting responds to.

---

## 6. The Margin Bound for Linear and Kernel Classes

### 6.1 Statement and proof

Let $E$ be a real inner product space — **no assumption on its dimension**.

**Definition 6.1 (Linear class on a sample).** For $W \ge 0$ and a sample $x_1,\dots,x_n \in E$,
$$\mathcal{L}_W(x) \;=\; \big\{\, v\in\mathbb{R}^n : \exists\, w\in E,\ \|w\|\le W,\ v_i = \langle w, x_i\rangle \ \forall i \,\big\}.$$
This class is nonempty (take $w=0$).

**Lemma 6.2 (Cauchy–Schwarz in feature space).** For every sign pattern $\sigma$,
$$\sup_{v \in \mathcal{L}_W(x)} A_\sigma(v) \;\le\; \frac{W}{n}\Big\|\sum_{i=1}^n \sigma_i x_i\Big\|.$$

*Proof.* For $v$ generated by $w$ with $\|w\|\le W$, linearity of the inner product gives $\sum_i \sigma_i \langle w, x_i\rangle = \langle w, \sum_i \sigma_i x_i\rangle \le \|w\|\,\|\sum_i \sigma_i x_i\| \le W \|\sum_i \sigma_i x_i\|$. Divide by $n$ and take the supremum. $\square$

**Lemma 6.3 (Second moment of the signed sum).** For any $x_1,\dots,x_n \in E$,
$$\sum_{\sigma} \Big\|\sum_i \sigma_i x_i\Big\|^2 \;=\; 2^n \sum_{i=1}^n \|x_i\|^2, \qquad\text{i.e.}\qquad \mathbb{E}_\sigma \Big\|\sum_i \sigma_i x_i\Big\|^2 = \sum_i \|x_i\|^2 .$$

*Proof.* Expanding the squared norm bilinearly, $\|\sum_i \sigma_i x_i\|^2 = \sum_{i}\sum_{j} \sigma_i\sigma_j \langle x_i, x_j\rangle$. Sum over $\sigma$ and exchange the order of summation. By Lemma 2.5, $\sum_\sigma \sigma_i\sigma_j = 0$ for $i\ne j$ and $= 2^n$ for $i=j$. Only the diagonal survives, contributing $2^n\sum_i \langle x_i,x_i\rangle = 2^n\sum_i\|x_i\|^2$. $\square$

**Theorem 6.4 (Margin bound for linear predictors).** Let $W, B \ge 0$, $n \ge 1$, and let $x_1,\dots,x_n \in E$ satisfy $\|x_i\|\le B$ for all $i$. Then
$$\widehat{\mathcal{R}}\big(\mathcal{L}_W(x)\big) \;\le\; \frac{WB}{\sqrt n}.$$
No hypothesis is made on $\dim E$.

*Proof.* Write $u(\sigma) = \|\sum_i \sigma_i x_i\|$. By Lemma 6.2,
$$\sum_\sigma \sup_{v} A_\sigma(v) \;\le\; \frac{W}{n}\sum_\sigma u(\sigma).$$
By Cauchy–Schwarz over the $2^n$ sign patterns, $\big(\sum_\sigma u(\sigma)\big)^2 \le 2^n \sum_\sigma u(\sigma)^2$. By Lemma 6.3 and $\|x_i\| \le B$,
$$\sum_\sigma u(\sigma)^2 = 2^n\sum_i \|x_i\|^2 \le 2^n\, n B^2 .$$
Hence $\big(\sum_\sigma u(\sigma)\big)^2 \le \big(2^n \sqrt n B\big)^2$, and since $u \ge 0$, $\sum_\sigma u(\sigma) \le 2^n \sqrt n B$. Therefore
$$\widehat{\mathcal{R}}(\mathcal{L}_W(x)) \le \frac{1}{2^n}\cdot \frac{W}{n}\cdot 2^n\sqrt n B = \frac{W\sqrt n B}{n} = \frac{WB}{\sqrt n}. \qquad\square$$

**Remark 6.5 (Where the $\sqrt n$ comes from).** Passing through Theorem 5.5 instead would give a weaker result: the behaviour vectors of $\mathcal{L}_W(x)$ have Euclidean length at most $WB\sqrt n$, so Theorem 5.5 yields only $\widehat{\mathcal{R}} \le WB$. The extra factor $1/\sqrt n$ in Theorem 6.4 is purchased entirely by *cancellation*: the identity $\mathbb{E}_\sigma[\sigma_i\sigma_j]=0$ of Lemma 2.5 replaces a worst-case bound $\|\sum_i\sigma_i x_i\| \le nB$ by the root-mean-square bound $\sqrt n B$. Linear classes are learnable not just because they are bounded, but because signed sums of data vectors cancel.

### 6.2 The kernel form

**Theorem 6.6 (Kernel margin bound).** Let $X$ be any set, $\varphi : X \to E$ a feature map into a real inner product space, and $K(y,z) = \langle \varphi(y), \varphi(z)\rangle$ the associated kernel. Let $W, B \ge 0$ and let $s_1,\dots,s_n \in X$ satisfy $K(s_i,s_i)\le B^2$ for all $i$. Then the class of kernel predictors $y \mapsto \langle w, \varphi(y)\rangle$ with $\|w\|\le W$, restricted to the sample, has
$$\widehat{\mathcal{R}} \;\le\; \frac{WB}{\sqrt n}.$$

*Proof.* $\|\varphi(s_i)\|^2 = \langle \varphi(s_i), \varphi(s_i)\rangle = K(s_i,s_i) \le B^2$, so $\|\varphi(s_i)\| \le B$; apply Theorem 6.4 to the sample $\varphi(s_1),\dots,\varphi(s_n)$ in $E$. $\square$

**Remark 6.7 (Only the diagonal matters).** The bound depends on the kernel **solely** through $\sup_i K(s_i,s_i)$ — the diagonal. Off-diagonal structure, the dimension of the reproducing kernel Hilbert space, and even whether that space is separable are irrelevant. Concretely:

| Kernel | $K(x,x)$ | Feature dimension | Complexity bound |
|---|---|---|---|
| Linear, $\|x\|\le B$ | $\le B^2$ | $d$ | $WB/\sqrt n$ |
| Polynomial degree $q$, $\|x\|\le 1$ | $\le 2^q$ (for $(1+\langle x,y\rangle)^q$) | $\binom{d+q}{q}$ | $W2^{q/2}/\sqrt n$ |
| Gaussian RBF | $= 1$ | infinite | $W/\sqrt n$ |

The Gaussian row is the point of the theory: an infinite-dimensional hypothesis class with a finite, small, explicitly computed complexity bound.

### 6.3 Quantitative comparison with dimension-dependent bounds

Linear predictors (through the origin) in $\mathbb{R}^d$ have VC dimension $d$; with a bias term, $d+1$. Any bound derived from that combinatorial parameter therefore has the shape $c\sqrt{d/n}$ for some absolute constant $c>0$.

**Theorem 6.8 (Dimension dependence is eventually fatal).** Let $W,B,c > 0$ and $n \ge 1$. If the dimension satisfies
$$d > \left(\frac{WB}{c}\right)^{2},$$
then
$$\frac{WB}{\sqrt n} \;<\; c\sqrt{\frac{d}{n}}.$$

*Proof.* Since $\sqrt{d/n} = \sqrt d/\sqrt n$ and $\sqrt{\cdot}$ is strictly increasing, the hypothesis $d > (WB/c)^2$ gives $\sqrt d > WB/c$, i.e. $c\sqrt d > WB$. Dividing by $\sqrt n > 0$ gives the claim. $\square$

**Interpretation.** Whatever constant $c$ a dimension-based analysis achieves, there is a finite threshold $d_0 = (WB/c)^2$ beyond which the dimension-free margin bound is *strictly* better, and the ratio of the two bounds is $c\sqrt d/(WB) \to \infty$ as $d\to\infty$. Since the margin bound holds in infinite dimension (Theorem 6.6) while the dimension-dependent bound diverges, the separation is not asymptotic hair-splitting: it is the difference between a meaningful guarantee and none.

Combining with Corollary 5.7, the comparison has two independent teeth:

1. **Qualitative:** for continuous classes such as $\mathrm{Ball}_n(r)$, counting bounds are *vacuous* while the Rademacher value is exact.
2. **Quantitative:** even where a dimension-dependent bound is finite, it is strictly worse than the margin bound once $d > (WB/c)^2$, by a factor growing like $\sqrt d$.

---

## 7. Algorithms

Three computational tasks arise. We describe them at the level of pseudocode; complexities are in terms of the sample size $n$, the class size $N$ (when finite), the ambient dimension $d$, and the number $m$ of Monte Carlo sign draws.

### 7.1 Exact complexity of a finite class

For $F = \{v^{(1)},\dots,v^{(N)}\}\subseteq\mathbb{R}^n$, the definition is a finite average, so it can be evaluated exactly by enumerating all $2^n$ sign patterns:
$$\widehat{\mathcal{R}}(F) = \frac{1}{2^n}\sum_{\sigma} \max_{k\le N} \frac1n\langle \sigma, v^{(k)}\rangle .$$
Cost: $\Theta(2^n N n)$ time, $\Theta(Nn)$ space. This is feasible for $n \lesssim 20$ and is exactly what one needs to *verify* the theoretical bounds on small examples.

### 7.2 Monte Carlo estimation

For larger $n$ one samples $m$ sign patterns uniformly and averages. The estimator is unbiased with variance $O(1/m)$; since each term lies in $[-B, B]$ under a uniform output bound $B$, Hoeffding's inequality gives an additive error $O(B\sqrt{\log(1/\delta)/m})$ with probability $1-\delta$. Cost: $\Theta(mNn)$, or $\Theta(m \cdot \mathrm{fit}(n))$ where $\mathrm{fit}$ is the cost of one training run when the "maximum over the class" is realized by running the learning algorithm on the random labels. This last variant is the practically important one: **the complexity of a class as implemented by an actual optimizer can be estimated by training on random labels.**

### 7.3 Closed-form evaluation for structured classes

For the ball and the linear/kernel classes no sampling is needed — the supremum is available in closed form for each $\sigma$:
- Ball of radius $r$: the supremum equals $r/\sqrt n$ for every $\sigma$ (Lemmas 5.2, 5.3), so the answer is $r/\sqrt n$ in $O(1)$ time.
- Linear class with weight ball radius $W$ on sample $x_1,\dots,x_n$: the supremum for a given $\sigma$ equals $\frac{W}{n}\|\sum_i\sigma_i x_i\|$ *exactly* (the maximizing $w$ is $W$ times the unit vector in the direction of $\sum_i \sigma_i x_i$, when that sum is nonzero). Hence $\widehat{\mathcal{R}} = \frac{W}{n}\,\mathbb{E}_\sigma\big\|\sum_i \sigma_i x_i\big\|$ exactly, which can be Monte-Carlo estimated at cost $\Theta(mnd)$. Bounding $\mathbb{E}_\sigma\|\cdot\|$ above by $\big(\mathbb{E}_\sigma\|\cdot\|^2\big)^{1/2} = \big(\sum_i\|x_i\|^2\big)^{1/2} \le \sqrt n B$ recovers Theorem 6.4, so the Monte Carlo value is always at least as informative as the closed-form bound.
- Kernel version: the same quantity is computable from the Gram matrix alone, since $\|\sum_i \sigma_i \varphi(s_i)\|^2 = \sum_{i,j}\sigma_i\sigma_j K(s_i,s_j) = \sigma^\top G \sigma$. Cost: $\Theta(mn^2)$ after an $\Theta(n^2)$ Gram computation. Note the feature map is never needed.

### 7.4 Bound selection

Given a class one may hold several bounds at once and should report the minimum:
$$\widehat{\mathcal{R}} \;\le\; \min\Big\{\, B,\;\; \tfrac{r\sqrt{2\log N}}{n}\ (\text{if } N<\infty),\;\; \tfrac{r}{\sqrt n}\ (\text{if } F\subseteq \mathrm{Ball}_n(r)),\;\; \tfrac{WB}{\sqrt n}\ (\text{if linear/kernel}) \,\Big\}.$$
The whole content of Sections 4–6 is a description of which term wins where: the Massart term for unstructured finite classes, the margin term for norm-constrained linear and kernel classes, and — when the class is infinite — the Massart term is simply unavailable.

---

## 8. Applications

**Support vector machines and kernel methods.** A soft-margin SVM with regularization constrains $\|w\|\le W$; the data enter only through $\sup_x K(x,x)$. Theorem 6.6 gives $\widehat{\mathcal{R}} \le WB/\sqrt n$, and Theorem 3.3 converts this into a generalization guarantee. For a normalized kernel ($K(x,x)=1$) the guarantee is $W/\sqrt n$ — independent of everything else about the kernel. This is the precise sense in which "the kernel trick is free": moving to a richer feature space costs nothing in capacity as long as the diagonal of the kernel and the norm budget are controlled.

**Regularization as capacity control.** Theorem 6.4 says the capacity is $WB/\sqrt n$: linear in the weight-norm budget. Weight decay, $\ell_2$ regularization, margin maximization, and constrained optimization all reduce $W$. The theory therefore does not merely permit regularization; it identifies $W$ as the exact quantity being paid for.

**The overparameterization paradox.** Modern models have far more parameters than training examples, so $d \gg n$ and every dimension-dependent bound is vacuous or worse than trivial. Theorem 6.8 explains why this is not evidence against learning theory but against the *parameter count* as a capacity measure: the margin bound is uniformly better for $d > (WB/c)^2$ and remains finite as $d \to \infty$. Capacity is a matter of scale, not of parameter count.

**Random-label diagnostics.** The definition of $\widehat{\mathcal{R}}$ is, operationally, "train on random labels and measure the fit". A model that achieves near-perfect accuracy on random labels has $\widehat{\mathcal{R}}$ near its output scale $B$, and Theorem 3.3 then offers no nontrivial guarantee — correctly, since such a class *can* be fooled by a finite sample. A model whose random-label fit degrades to near chance has small $\widehat{\mathcal{R}}$ and a corresponding guarantee. The diagnostic is not a heuristic proxy for the theory; it is the theory.

**Model selection.** Since $\widehat{\mathcal{R}}$ is estimable (Section 7.2) whereas VC dimension typically is not, one can compare candidate architectures or hyperparameter settings by their measured complexity together with their training error, and pick the minimizer of the sum — a structural-risk-minimization procedure with a computable penalty.

---

## 9. Discussion, Limitations, and Future Work

### 9.1 What has been established

We have a complete, self-contained chain: *definition* $\to$ *elementary calculus* $\to$ *symmetrization* (Rademacher complexity controls uniform deviation) $\to$ *counting route* (Massart, tight up to $\sqrt{2\log 2} < 6/5$) $\to$ *geometric route* (exact value on the ball; margin bound for linear and kernel classes) $\to$ *separation* (counting is vacuous on infinite classes; dimension-dependent bounds lose beyond $d = (WB/c)^2$).

Two exact evaluations anchor the theory: $\widehat{\mathcal{R}}(\{\pm1\}^n)=1$ and $\widehat{\mathcal{R}}(\mathrm{Ball}_n(r)) = r/\sqrt n$. These are what turn qualitative slogans ("Rademacher is sharper than VC") into theorems.

### 9.2 Limitations

- **In expectation, not in probability.** Theorem 3.3 and Corollary 4.5 bound expectations over the sample. The familiar high-probability statements require a concentration step (Section 9.3, item 1).
- **Finite domain in the symmetrization argument.** Section 3 works with a finite domain and explicit product weights, so that all expectations are finite sums and the supremum over a finite class is a maximum. Extending to general probability spaces is routine mathematically but requires measurability side conditions on the supremum.
- **Real-valued classes, not losses.** The margin bound (Theorem 6.4) applies to the *scores* $\langle w,x\rangle$. Transferring it to a classification loss requires a contraction step (Section 9.3, item 2).
- **The constant $2$.** The factor $2$ in symmetrization comes from splitting a difference; whether it is optimal is not addressed here.

### 9.3 Future directions

1. **High-probability bounds.** The present bounds are in expectation. Adding McDiarmid's bounded differences inequality would give the usual $\sup_f(\mathbb{E}f - \widehat{\mathbb{E}}_S f) \le 2\widehat{\mathcal{R}} + 3B\sqrt{\log(2/\delta)/(2n)}$ with probability $1-\delta$.
2. **Contraction (Talagrand's lemma).** $\widehat{\mathcal{R}}(\phi\circ\mathcal{F}) \le L\,\widehat{\mathcal{R}}(\mathcal{F})$ for $L$-Lipschitz $\phi$ would let the margin bound for linear classes be transferred to the margin loss and yield the standard margin bound for classification error.
3. **Sauer–Shelah and the growth function.** Establishing $\Pi_\mathcal{F}(n) \le (en/d)^d$ for a class of VC dimension $d$ and combining it with Massart's lemma would give the VC bound $\widehat{\mathcal{R}} \le \sqrt{2d\log(en/d)/n}$, making the comparison with the dimension-free margin bound quantitative for a *fixed* structured class rather than through the shape of the bound.
4. **Lower bounds.** A matching lower bound for the Rademacher complexity of the ball and of the cube (both computed exactly here) could be extended to a general Sudakov-type minoration.
5. **From finite to general probability spaces.** The symmetrization argument here is carried out over a finite domain with explicit product weights. Recasting it in terms of general product measures would remove the finiteness assumption, at the cost of measurability side conditions for the supremum.

### 9.4 A closing remark

The recurring theme is that **capacity is a metric, not a combinatorial, notion**. Counting how many behaviours a class exhibits is a legitimate and — as the cube shows — nearly optimal strategy when the class has no geometry to exploit. But when it does have geometry, as every norm-constrained predictor class does, counting throws away exactly the information that matters and returns an infinite answer to a question with a small finite one. Rademacher complexity is the measurement that respects the geometry, and its operational meaning — how well can this class fit noise? — is the same in both regimes.

---

## Notation Index

| Symbol | Meaning |
|---|---|
| $n$ | sample size |
| $\sigma \in \{-1,1\}^n$ | sign (Rademacher) pattern; uniform over $2^n$ values |
| $A_\sigma(v)$ | sign average $\frac1n\sum_i \sigma_i v_i$ |
| $\widehat{\mathcal{R}}(F)$ | empirical Rademacher complexity, $2^{-n}\sum_\sigma \sup_{v\in F} A_\sigma(v)$ |
| $\widehat{\mathcal{R}}_S(\mathcal{F})$ | complexity of the function class $\mathcal{F}$ restricted to sample $S$ |
| $\widehat{\mathbb{E}}_S f$, $\mathbb{E}f$ | empirical and true mean of $f$ |
| $\mathrm{gap}(S)$ | $\sup_{f}(\mathbb{E}f - \widehat{\mathbb{E}}_S f)$ |
| $N$ | number of distinct behaviours of the class on the sample |
| $r$ | Euclidean radius bound on behaviour vectors |
| $B$ | uniform bound on outputs, or on $\|x_i\|$ |
| $W$ | bound on the weight norm $\|w\|$ |
| $Q_n$ | sign cube $\{-1,1\}^n$ |
| $\mathrm{Ball}_n(r)$ | $\{v : \sum_i v_i^2 \le r^2\}$ |
| $K(y,z)$ | kernel $\langle \varphi(y),\varphi(z)\rangle$ |
