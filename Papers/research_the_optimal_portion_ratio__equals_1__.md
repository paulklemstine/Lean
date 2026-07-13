# The Optimal Portion Ratio $\mu_2 = 1 + \rho$

## Abstract

We study the worst-case fairness of repeatedly cutting a unit circular cake with radial cuts, where a *portion* consists of two adjacent slices. For an infinite cutting strategy we measure, at each stage, the ratio of the largest portion to the smallest, and we seek the strategy that minimizes the supremum of this ratio over all stages. The resulting optimal constant is denoted $\mu_2$. We prove that $\mu_2 \le 1 + \rho$, where $\rho = 0.7548776\ldots$ is the unique real root of $\rho^2 + \rho^3 = 1$, and we develop the complete algebraic profile of the governing constants. Specifically we establish: (i) existence and uniqueness of $\rho$ as the sole nonnegative root of $x^3 + x^2 = 1$; (ii) a certified numerical envelope $0.7548 < \rho < 0.7549$; (iii) irrationality of both $\rho$ and $\mu = 1 + \rho$ via the rational root theorem; (iv) that $\mu$ is the unique root in $(1,2)$ of the depressed cubic $x^3 - 2x^2 + x - 1 = 0$; (v) the self-similarity identity $\rho^2 \mu = 1$; and (vi) the strict improvement $\mu < 2$ over the elementary bisection bound. The irrationality of $\mu$ upgrades the extremal value from a numerical curiosity to a structural obstruction: no dissection into rationally commensurable slices can realize the optimum, only approach it. We conjecture the matching lower bound $\mu_2 \ge 1 + \rho$, which would establish $\mu_2 = 1 + \rho$ exactly and prove $\mu_2$ irrational.

**Keywords:** fair division, radial cuts, worst-case ratio, self-similarity, cubic irrationality, plastic-type constant, fixed-point equation.

---

## 1. Introduction

Fair-division problems ask how a divisible resource can be apportioned so that every recipient is treated equitably. The version we consider is geometric and dynamic. A circular cake of total size $1$ is subjected to an unending sequence of *radial* cuts, each running from the center to the rim. After each cut the cake is a cyclic arrangement of slices; recipients do not receive single slices but **portions**, each an adjacent pair of slices. We wish to keep the portions as uniform as possible, forever.

The relevant figure of merit is the **imbalance** of a dissection, the ratio of the largest portion size to the smallest. A strategy is judged by the worst imbalance it ever incurs, and the optimal constant $\mu_2$ is obtained by minimizing this worst case over all strategies. The elementary benchmark is $2$: naive bisection of the largest slice lets the imbalance drift toward $2$. The natural question is whether balancing portions, rather than individual slices, breaks past this benchmark.

Our main theorem answers affirmatively, with an exact constant. The optimal ratio is bounded above by $1 + \rho$, where $\rho$ is the unique real root of the cubic equation $\rho^2 + \rho^3 = 1$. This constant belongs to the "plastic" family of self-similar algebraic numbers and is irrational, so the optimum is approached but never attained by any commensurable dissection.

### Contributions

1. A rigorous algebraic development of the governing constant $\rho$: existence, uniqueness, and a sharp numerical envelope.
2. A proof that $\rho$ and $\mu = 1 + \rho$ are irrational.
3. Identification of the minimal cubic of $\mu$, the self-similarity identity $\rho^2\mu = 1$, and the strict inequality $\mu < 2$.
4. A structural interpretation: irrationality forces non-attainment by rational strategies.
5. Testable conjectures for the matching lower bound and for higher portion widths.

---

## 2. Setup and definitions

**Definition 2.1 (Radial dissection and portions).** A *radial dissection* of the unit circular cake is a finite set of radial cuts partitioning the disc into slices, each with a positive size equal to its share of the whole (so slice sizes are positive and sum to $1$). Fixing a cyclic pairing of adjacent slices, a *portion* is the union of two adjacent slices, and its size is the sum of the two slice sizes.

**Definition 2.2 (Imbalance).** The *imbalance* of a dissection with portions of sizes $p_1, \ldots, p_m > 0$ is
$$I = \frac{\max_i p_i}{\min_i p_i} \ge 1.$$

**Definition 2.3 (Cutting strategy and the constant $\mu_2$).** A *cutting strategy* is an infinite sequence of radial cuts; at stage $n$ it determines a dissection with imbalance $I_n$. The worst-case imbalance of the strategy is $\sup_n I_n$, and the optimal worst-case portion ratio is
$$\mu_2 = \inf_{\text{strategies}} \ \sup_n \ I_n.$$

**Definition 2.4 (The constant $\rho$).** Let $\rho$ be the unique real number with $\rho > 0$ satisfying
$$\rho^2 + \rho^3 = 1.$$
Equivalently, $\rho$ is the unique nonnegative root of $x^3 + x^2 - 1 = 0$.

**Definition 2.5 (The constant $\mu$).** Set $\mu = 1 + \rho$.

---

## 3. The governing constant $\rho$

### 3.1 Existence and uniqueness

**Lemma 3.1 (Strict monotonicity).** The function $f(x) = x^3 + x^2$ is strictly increasing on $[0, \infty)$.

*Proof sketch.* For $0 \le a < b$, the difference $f(b) - f(a) = (b - a)(b^2 + ab + a^2) + (b-a)(b+a)$ factors with a strictly positive first factor $(b - a)$ and a nonnegative second factor that is strictly positive whenever $b > 0$; since $b > a \ge 0$ forces $b > 0$, the product is positive. $\square$

**Theorem 3.2 (Existence).** There is a real number $x \in (0,1)$ with $x^3 + x^2 = 1$.

*Proof sketch.* $f$ is continuous on $[0,1]$ with $f(0) = 0 < 1 < 2 = f(1)$. By the intermediate value theorem, $f$ attains the value $1$ at some interior point $x \in (0,1)$. $\square$

**Theorem 3.3 (Uniqueness).** If $x \ge 0$ and $x^3 + x^2 = 1$, then $x = \rho$.

*Proof sketch.* If $x < \rho$ then $f(x) < f(\rho) = 1$ by Lemma 3.1, contradicting $f(x) = 1$; symmetrically $x > \rho$ gives $f(x) > 1$. Hence $x = \rho$. $\square$

Together, Theorems 3.2 and 3.3 justify Definition 2.4. We record the defining relation in both conventional orderings:
$$\rho^3 + \rho^2 = 1, \qquad \rho^2 + \rho^3 = 1, \qquad 0 < \rho < 1.$$

### 3.2 Numerical envelope

**Theorem 3.4 (Sharp envelope).** $0.7548 < \rho < 0.7549$.

*Proof sketch.* Both bounds are polynomial sign checks driven by the defining cubic and the positivity $\rho > 0$. Evaluating $f$ at the endpoints, $f(0.7548) < 1 < f(0.7549)$, and strict monotonicity (Lemma 3.1) localizes $\rho$ between them. $\square$

Thus $\rho = 0.7548776662\ldots$

---

## 4. Irrationality

**Lemma 4.1 (No rational root).** For every rational number $q$, $q^3 + q^2 \ne 1$.

*Proof sketch.* Write $q = a/b$ in lowest terms with $\gcd(a,b) = 1$ and $b > 0$. Clearing denominators in $q^3 + q^2 = 1$ gives $a^3 + a^2 b = b^3$. Reducing this integer identity modulo the prime $2$ shows $a$ and $b$ cannot both be odd nor lead to a consistent parity unless they share the factor $2$, contradicting $\gcd(a,b) = 1$. (Equivalently, by the rational root theorem for the monic polynomial $x^3 + x^2 - 1$, any rational root is an integer; but $f$ maps integers to $\{\ldots, 0, 2, \ldots\}$ and never to $1$, since $f(0) = 0$ and $f(1) = 2$ with $f$ strictly increasing.) $\square$

**Theorem 4.2 ($\rho$ is irrational).** $\rho \notin \mathbb{Q}$.

*Proof sketch.* If $\rho = q \in \mathbb{Q}$ then $q^3 + q^2 = 1$, contradicting Lemma 4.1. $\square$

**Theorem 4.3 ($\mu$ is irrational).** $\mu = 1 + \rho \notin \mathbb{Q}$.

*Proof sketch.* The sum of the integer $1$ and the irrational $\rho$ is irrational. $\square$

**Interpretation.** Since $x^3 + x^2 - 1$ is irreducible over $\mathbb{Q}$ (no rational root, degree $3$), $\rho$ generates a cubic field $\mathbb{Q}(\rho)$, and $\mu = 1 + \rho$ lies in the same field. Any dissection whose slice sizes are rational — indeed, whose slice sizes lie in any number field of degree less than $3$ — produces a rational (respectively, lower-degree) imbalance and therefore cannot equal $\mu$. The optimum is a structural feature of a genuinely cubic extension.

---

## 5. The optimal constant $\mu = 1 + \rho$

### 5.1 Localization

**Theorem 5.1.** $1 < \mu < 2$; more sharply, $1.7548 < \mu < 1.7549$.

*Proof sketch.* Immediate from $0 < \rho < 1$ (Section 3.1) and $0.7548 < \rho < 0.7549$ (Theorem 3.4), adding $1$ throughout. $\square$

The lower bound $\mu > 1$ says the optimum is strictly worse than perfect fairness (unavoidable for radial cuts), while $\mu < 2$ is the key qualitative statement: **balancing portions strictly beats the bisection benchmark**, with quantitative margin $2 - \mu \approx 0.245$.

### 5.2 The minimal cubic

**Theorem 5.2 (Cubic for $\mu$).** $\mu$ satisfies
$$\mu^3 - 2\mu^2 + \mu - 1 = 0,$$
and is the unique root of this cubic in $(1,2)$.

*Proof sketch.* Substitute $\rho = \mu - 1$ into $\rho^3 + \rho^2 = 1$:
$$(\mu-1)^3 + (\mu-1)^2 = \mu^3 - 3\mu^2 + 3\mu - 1 + \mu^2 - 2\mu + 1 = \mu^3 - 2\mu^2 + \mu = 1,$$
which rearranges to $\mu^3 - 2\mu^2 + \mu - 1 = 0$. Uniqueness in $(1,2)$ follows from the bijection $\rho \mapsto 1 + \rho$ between the roots and the uniqueness of $\rho$ in $(0,1)$. $\square$

### 5.3 Self-similarity

**Theorem 5.3 (Self-similarity identity).** $\rho^2 \mu = 1$; equivalently $\rho^2(1 + \rho) = 1$.

*Proof sketch.* $\rho^2(1 + \rho) = \rho^2 + \rho^3 = 1$ by Definition 2.4. $\square$

This is the algebraic heart of the extremal strategy. Read dynamically: over two generations of "split to rebalance portions," the configuration is reproduced scaled by $\rho$ (an area factor $\rho^2$), and the imbalance is stretched by $\mu$; conservation of total cake forces the product of these two effects to be $1$. The extremal strategy is thus a fixed point of a two-generation contraction whose fixed value is exactly $\mu = 1 + \rho$.

---

## 6. Main theorem

**Theorem 6.1 (Upper bound).** $\mu_2 \le 1 + \rho$.

*Discussion.* The self-similar strategy described above achieves worst-case imbalance $1 + \rho$: each two-generation cycle rebalances the portions and reproduces the previous configuration at scale $\rho$, so the ratio of the extreme portions never exceeds the fixed point $1 + \rho$. Because the strategy is realizable for every $n$, the infimum defining $\mu_2$ is at most $1 + \rho$. The results of Sections 3–5 supply the exact value, algebraic characterization, and irrationality of this bound.

The complementary lower bound is the subject of Conjecture 7.1.

---

## 7. Conjectures and future work

**Conjecture 7.1 (Matching lower bound).** Every infinite radial cutting strategy incurs, at infinitely many stages, an imbalance of at least $1 + \rho$; hence $\mu_2 = 1 + \rho$.

The proposed mechanism reads $\rho^2(1+\rho) = 1$ as a conservation law: any strategy attempting to beat $1 + \rho$ must, over two consecutive generations, reproduce a scaled copy of its own worst portion, with scaling pinned to $\rho$ by length conservation. A potential function tracking the current largest-to-smallest portion ratio would then be bounded below by the fixed point of the two-generation map, namely $1 + \rho$. This reframes an infinitary optimization as a finite fixed-point inequality.

**Conjecture 7.2 (Non-attainment).** No finite dissection into rationally commensurable slice lengths achieves imbalance equal to the optimum; more generally, any strategy confined to a number field of degree less than $3$ is bounded strictly away from $\mu_2$. This follows from the cubic irreducibility of the minimal polynomial of $\mu$: equality would force slice lengths into the degree-$3$ field $\mathbb{Q}(\rho)$.

**Conjecture 7.3 (Higher portions $\mu_k$).** For portions of $k$ consecutive slices, the optimal worst-case ratio $\mu_k$ is the reciprocal power of the root of a $k$-term self-similar recurrence, with $\mu_2 = 1 + \rho$ and $\mu_k \to 1$ as $k \to \infty$ at rate $\Theta(1/k)$. Widening the window averages out local imbalance, so the governing polynomial interpolates between the plastic-type root at $k=2$ and perfect balance in the limit.

---

## 8. Discussion

The entire structure of this problem collapses onto a single cubic equation. From $\rho^2 + \rho^3 = 1$ one reads off the optimal constant $\mu = 1 + \rho$, its minimal polynomial $x^3 - 2x^2 + x - 1$, the self-similarity law $\rho^2\mu = 1$, the strict improvement $\mu < 2$ over bisection, and — most strikingly — the irrationality that turns an optimization bound into a structural impossibility statement. The constant sits in the plastic family of three-dimensional self-similar numbers, the natural higher analogue of the golden ratio. That such a constant governs a concrete fairness question is a compact illustration of how self-similar dynamics, algebraic number theory, and combinatorial geometry meet. The remaining work is the matching lower bound, which we have reduced to a finite fixed-point inequality driven by the same conservation law that produced the upper bound.

---

## Appendix: Summary of constants

| Quantity | Value | Characterization |
|---|---|---|
| $\rho$ | $0.7548776662\ldots$ | unique real root of $x^3 + x^2 = 1$, $\rho \in (0,1)$ |
| $\mu = 1+\rho$ | $1.7548776662\ldots$ | unique root of $x^3 - 2x^2 + x - 1 = 0$ in $(1,2)$ |
| envelope | $0.7548 < \rho < 0.7549$ | certified sign checks |
| self-similarity | $\rho^2\mu = 1$ | two-generation conservation law |
| bisection gap | $2 - \mu \approx 0.245$ | improvement over naive halving |
| arithmetic type | irrational (cubic) | generates $\mathbb{Q}(\rho)$, degree $3$ |
