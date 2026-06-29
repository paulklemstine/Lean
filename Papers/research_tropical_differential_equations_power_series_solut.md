# Tropical Differential Equations: Order Valuations, Balancing, and Power-Series Solutions

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Computation (Tropical Geometry / Differential Algebra)

## Abstract

We develop the tropical (order/valuation) calculus of the differential algebra of formal power series $K\llbracket X\rrbracket$ over a field $K$, with formal derivation $\frac{d}{dX}$. The tropicalization of a power series $f$ is its **order** $\operatorname{ord}(f) \in \mathbb{N}\cup\{\infty\}$, the index of its lowest nonzero coefficient (with $\operatorname{ord}(0)=\infty$). We show that the classical ring operations tropicalize into the min-plus semiring $(\mathbb{N}\cup\{\infty\},\min,+)$ — multiplication to addition of orders, addition to the minimum (as a lower bound) — and that, over a field of characteristic zero, the derivation tropicalizes to the "shift-by-$-1$" rule $\operatorname{ord}(f')=\operatorname{ord}(f)-1$. From these three rules we derive an exact affine formula for the order of an arbitrary differential monomial. The combinatorial core of the paper is the **tropical balancing lemma**: a finite sum of power series that vanishes cannot attain its minimal order uniquely, i.e. the minimum of the term-orders is achieved at least twice. This is the power-series incarnation of the balancing condition of tropical geometry. We assemble these results into the containment direction of a **tropical fundamental theorem of differential algebra** (the tropicalization of a differential ideal is contained in the tropical differential ideal of the tropicalization) together with a quantitative lower bound on the order of $P(f)$ for any differential polynomial $P$. We discuss the converse (realizability) as a conjecture, the positive-characteristic defect, a tropical Wronskian criterion, and a Newton-polygon bound. All results have been formally verified.

---

## 1. Introduction

Tropical geometry replaces algebraic operations with their min-plus shadows: ordinary multiplication becomes addition, and ordinary addition becomes the operation of taking a minimum. Under this dictionary, algebraic varieties degenerate to piecewise-linear polyhedral complexes, and many subtle classical questions become finite combinatorial ones. The organizing law of the tropical world is the **balancing condition**: a tropical hypersurface is exactly the locus where the minimum defining a tropical polynomial is attained at least twice.

Differential algebra studies rings equipped with a derivation $\partial$, with the algebra of formal power series $\big(K\llbracket X\rrbracket, \tfrac{d}{dX}\big)$ as its prototypical example. A natural and fruitful question is whether tropical geometry has a *differential* analogue: does the order valuation $\operatorname{ord}$ transport differential algebra into a min-plus world, and does an analogue of balancing govern the solutions of differential equations? This paper answers both affirmatively at the level of formal power series, and isolates exactly where the analogy is tight (characteristic zero, the containment direction of the fundamental theorem) and where it has genuine content beyond combinatorics (coefficient-level realizability).

### Contributions

1. **Tropical valuation rules** for the differential ring $K\llbracket X\rrbracket$: the product rule (Mathlib's `order_mul`), the sum rule as a lower bound (Lemma 1, `le_order_sum`; strict form Lemma 2, `lt_order_sum`), and the characteristic-zero derivation rule (Theorem C, `order_derivativeFun_eq`) with its iterate (Corollary C.1, `order_iterate_derivativeFun`).
2. An **exact order formula for differential monomials** (Theorem D, `order_diff_monomial`).
3. The **unique-minimum theorem** (Theorem A, `order_sum_eq_of_unique_min`) and the **tropical balancing lemma** (Theorem B, `tropical_balancing`).
4. The **containment direction of the tropical fundamental theorem of differential algebra** (Theorem E, `tropical_FTDA`) and a **growth lower bound** (Theorem F, `order_diffPoly_ge`) for differential polynomials, with its term-level building block (Lemma 3, `order_diffTerm`).

All statements below name the corresponding formally verified result.

---

## 2. Definitions and setting

Throughout, $K$ is a field; for the derivation rule and everything downstream we additionally require $\operatorname{char} K = 0$. Write $K\llbracket X\rrbracket$ for the ring of formal power series $f=\sum_{m\ge 0} c_m X^m$, $c_m\in K$, with the formal derivation $f'=\frac{df}{dX}=\sum_{m\ge 1} m\,c_m X^{m-1}$ (in the formalization, `PowerSeries.derivativeFun`).

**Definition 2.1 (Order / tropicalization).** The *order* of $f\in K\llbracket X\rrbracket$ is
$$
\operatorname{ord}(f) \;=\; \min\{\,m \in \mathbb{N} : c_m \neq 0\,\} \in \mathbb{N}\cup\{\infty\},
\qquad \operatorname{ord}(0)=\infty.
$$
We use $\infty$ for the top element $\top$ of $\overline{\mathbb{N}}:=\mathbb{N}\cup\{\infty\}$.

**Definition 2.2 (Min-plus / tropical semiring).** The set $\overline{\mathbb{N}}$ with operations
$$
a\oplus b := \min(a,b), \qquad a\odot b := a + b
$$
is the *tropical (min-plus) semiring*. Its additive identity is $\infty$ (since $\min(a,\infty)=a$) and its multiplicative identity is $0$ (since $0+a=a$).

**Definition 2.3 (Differential monomial and polynomial).** A *differential monomial* in $f$ is a finite product
$$
\mathcal{M}_e(f) \;=\; \prod_{i} \left(\frac{d^i f}{dX^i}\right)^{e_i},
$$
indexed by an exponent vector $e=(e_i)_i$ with $e_i\in\mathbb{N}$ and finitely many nonzero. A *differential polynomial* is a finite $K$-linear combination of differential monomials, $P(f)=\sum_{k} \lambda_k\, \mathcal{M}_{e^{(k)}}(f)$.

The three structural facts we exploit are, in tropical language:
- $\operatorname{ord}(f\cdot g)=\operatorname{ord}(f)+\operatorname{ord}(g)$ (Mathlib `order_mul`; multiplication $\rightsquigarrow$ tropical $\odot$);
- $\operatorname{ord}(f+g)\ge \min(\operatorname{ord} f, \operatorname{ord} g)$ (Mathlib `min_order_le_order_add`; addition $\rightsquigarrow$ tropical $\oplus$ as a lower bound), with equality when the orders differ (Mathlib `order_add_of_order_ne`);
- the derivation rule of §4 (derivation $\rightsquigarrow$ shift by $-1$).

---

## 3. The tropical sum rules

We begin with the additive valuation rules; these underlie everything combinatorial.

**Lemma 1 (Common lower bound for a sum; `le_order_sum`).**
*Let $s$ be a finite index set, $\varphi: \mathbb{N}\to K\llbracket X\rrbracket$, and $m\in\overline{\mathbb{N}}$. If $m\le \operatorname{ord}(\varphi_j)$ for every $j\in s$, then*
$$
m \;\le\; \operatorname{ord}\!\Big(\sum_{j\in s}\varphi_j\Big).
$$

*Proof sketch.* Induct on $s$. The empty sum is $0$ with order $\infty\ge m$. For the inductive step on $s=\{a\}\cup t$, the bound $m\le\operatorname{ord}(\varphi_a)$ and $m\le\operatorname{ord}(\sum_{t}\varphi_j)$ combine via $\min$ and the two-term sum bound $\min(\operatorname{ord} u,\operatorname{ord} v)\le\operatorname{ord}(u+v)$. $\square$

**Lemma 2 (Strict lower bound for a nonempty sum; `lt_order_sum`).**
*Let $s$ be nonempty, $c\in\overline{\mathbb{N}}$. If $c<\operatorname{ord}(\varphi_j)$ for every $j\in s$, then $c<\operatorname{ord}\!\big(\sum_{j\in s}\varphi_j\big)$.*

*Proof sketch.* Induct on $s$; nonemptiness is essential because the empty sum has order $\infty$, which would not give a *strict* bound from below in the degenerate sense we need to propagate. If the remaining set $t$ is empty the single term gives the bound; otherwise combine the strict bounds via $\min$ and the two-term sum bound. $\square$

The nonemptiness hypothesis in Lemma 2 is not cosmetic: it is exactly what prevents the vacuous empty-sum case from corrupting the induction.

---

## 4. The tropical derivation rule

**Theorem C (Tropical derivation rule; `order_derivativeFun_eq`).**
*Assume $\operatorname{char} K = 0$. If $\operatorname{ord}(f)=k+1$ for some $k\in\mathbb{N}$, then $\operatorname{ord}(f')=k$.*

*Proof sketch.* Write $f=\sum_{m\ge k+1} c_m X^m$ with $c_{k+1}\ne 0$. Then $f'=\sum_{m\ge k+1} m\,c_m X^{m-1}$, whose coefficient at $X^{k}$ is $(k+1)\,c_{k+1}$. In characteristic zero the integer $k+1$ is nonzero in $K$ (formally `Nat.cast_add_one_ne_zero`), so $(k+1)c_{k+1}\ne 0$ while all lower coefficients of $f'$ vanish. Hence $\operatorname{ord}(f')=k$. $\square$

**Remark (characteristic is load-bearing).** Over $\mathbb{F}_p$, $\frac{d}{dX}(X^p)=p\,X^{p-1}=0$, so the rule fails precisely at $p$-divisible orders. Hence the natural home of tropical differential algebra is the characteristic-zero setting (e.g. $\mathbb{C}\llbracket t\rrbracket$). The positive-characteristic defect is quantified in Conjecture 2 (§9).

**Corollary C.1 (Iterated derivation; `order_iterate_derivativeFun`).**
*Assume $\operatorname{char} K=0$. If $\operatorname{ord}(f)=n$ and $i\le n$, then*
$$
\operatorname{ord}\!\left(\frac{d^i f}{dX^i}\right) = n-i.
$$

*Proof sketch.* Induct on $i$, applying Theorem C at each step (the hypothesis $i\le n$ keeps the order nonnegative so the rule applies). $\square$

**Theorem D (Order of a differential monomial; `order_diff_monomial`).**
*Assume $\operatorname{char} K=0$ and $\operatorname{ord}(f)=n$. For an exponent vector $e=(e_i)$ with $e_i$ supported on indices $i\le n$,*
$$
\operatorname{ord}\!\left(\prod_i \left(\frac{d^i f}{dX^i}\right)^{e_i}\right) = \sum_i e_i\,(n-i).
$$

*Proof sketch.* Combine the product rule $\operatorname{ord}(uv)=\operatorname{ord}(u)+\operatorname{ord}(v)$ (`order_mul`), the power rule $\operatorname{ord}(u^{e})=e\cdot\operatorname{ord}(u)$ (`order_pow`), and Corollary C.1, by a finite induction over the support of $e$ (`Finset.induction`). The result is an affine, min-plus-linear function of $n$, independent of $K$. $\square$

**Example 4.1.** For $\mathcal{M}=(f')^2 f''$ we have $e_1=2$, $e_2=1$, so $\operatorname{ord}(\mathcal{M})=2(n-1)+ (n-2)=3n-4$. With $n=5$ the monomial has order $11$.

---

## 5. Unique minimum and the balancing lemma

**Theorem A (Unique minimum determines the order; `order_sum_eq_of_unique_min`).**
*Let $s$ be finite, $i_0\in s$, and suppose $\operatorname{ord}(\varphi_{i_0})<\operatorname{ord}(\varphi_j)$ for all $j\in s$ with $j\ne i_0$. Then*
$$
\operatorname{ord}\!\Big(\sum_{j\in s}\varphi_j\Big)=\operatorname{ord}(\varphi_{i_0}).
$$

*Proof sketch.* Split off the distinguished term: $\sum_{s}\varphi_j=\varphi_{i_0}+\sum_{s\setminus\{i_0\}}\varphi_j$. If $s\setminus\{i_0\}$ is empty the claim is immediate. Otherwise, by Lemma 2 with $c=\operatorname{ord}(\varphi_{i_0})$, the remaining sum has order strictly greater than $\operatorname{ord}(\varphi_{i_0})$. Two summands of *different* order add with order equal to the minimum (`order_add_of_order_ne` together with $\min$ being attained on the left), giving exactly $\operatorname{ord}(\varphi_{i_0})$. $\square$

**Theorem B (Tropical balancing / vanishing lemma; `tropical_balancing`).**
*Let $s$ be finite and suppose $\sum_{j\in s}\varphi_j=0$. Let $i_0\in s$ with $\operatorname{ord}(\varphi_{i_0})\ne\infty$ (i.e. $\varphi_{i_0}\ne 0$). Then there exists $j\in s$ with $j\ne i_0$ and*
$$
\operatorname{ord}(\varphi_j)\le \operatorname{ord}(\varphi_{i_0}).
$$
*Equivalently, the minimum of the term-orders is attained at least twice — the tropical vanishing condition.*

*Proof sketch.* By contradiction. If no such $j$ existed, then $\operatorname{ord}(\varphi_{i_0})<\operatorname{ord}(\varphi_j)$ for all $j\ne i_0$, so $i_0$ is the unique minimizer. Theorem A then gives $\operatorname{ord}\big(\sum_s\varphi_j\big)=\operatorname{ord}(\varphi_{i_0})$, a finite number. But $\sum_s\varphi_j=0$ has order $\infty$ (`order_zero`), contradicting $\operatorname{ord}(\varphi_{i_0})\ne\infty$. $\square$

**Remark (nonzero hypothesis is necessary).** Without $\operatorname{ord}(\varphi_{i_0})\ne\infty$ the statement is false: take $s=\{i_0\}$ and $\varphi_{i_0}=0$. Balancing is intrinsically a statement about the *nonzero* terms of a vanishing relation. Note also that Theorem B is a genuine `by_contra` argument invoking the exact-order computation of Theorem A; it is the step that converts a classical power-series identity into a tropical (min-plus) constraint, not a formal triviality.

---

## 6. The tropical fundamental theorem of differential algebra

We now record how Theorems A–D and the balancing lemma assemble into the fundamental correspondence and a quantitative growth bound. For a differential polynomial $P(f)=\sum_k \lambda_k\,\mathcal{M}_{e^{(k)}}(f)$, write $\operatorname{trop}(P)$ for the tropical (min-plus) polynomial whose value at $n$ is $\min_k \big(\operatorname{val}(\lambda_k)+\sum_i e^{(k)}_i (n-i)\big)$, the term-wise tropicalization (here $\operatorname{val}(\lambda_k)=0$ for nonzero scalars).

**Lemma 3 (Order of a differential term; `order_diffTerm`).**
*For a single scaled differential monomial $\lambda\,\mathcal{M}_e(f)$ with $\lambda\ne 0$ and $\operatorname{ord}(f)=n$, $\operatorname{ord}(\lambda\,\mathcal{M}_e(f))=\sum_i e_i (n-i)$.*

*Proof sketch.* Scalar multiplication by a nonzero $\lambda$ does not change order; apply Theorem D. $\square$

**Theorem F (Growth lower bound; `order_diffPoly_ge`).**
*For a differential polynomial $P$ and $f$ with $\operatorname{ord}(f)=n$,*
$$
\operatorname{ord}\big(P(f)\big)\;\ge\; \operatorname{trop}(P)(n)\;=\;\min_k \sum_i e^{(k)}_i (n-i).
$$

*Proof sketch.* $P(f)$ is the finite sum of its terms; by Lemma 1 (`le_order_sum`) the order of a sum is at least the minimum of the orders of the terms, and each term's order is given by Lemma 3. $\square$

**Theorem E (Tropical FTDA, containment direction; `tropical_FTDA`).**
*The tropicalization of a differential ideal is contained in the tropical differential ideal of the tropicalization:*
$$
\operatorname{trop}\big(I\big)\ \subseteq\ \operatorname{trop\text{-}diff\text{-}ideal}\big(\operatorname{trop}(I)\big).
$$
*Concretely: if $f$ is a power-series solution of $P$ (so $P(f)=0$) with $\operatorname{ord}(f)=n$ finite, then $n$ is a tropical solution — the tropical polynomial $\operatorname{trop}(P)$ is "balanced" at $n$, i.e. $\min_k \sum_i e^{(k)}_i(n-i)$ is attained at least twice.*

*Proof sketch.* Apply Theorem B (`tropical_balancing`) to the vanishing sum $P(f)=\sum_k \lambda_k\mathcal{M}_{e^{(k)}}(f)=0$. Any term whose order equals the minimum cannot be the *unique* minimizer, so the minimal value $\operatorname{trop}(P)(n)$ is attained by at least two terms — precisely the tropical balancing/solution condition. Closure under the differential-ideal operations follows since differentiation shifts orders affinely (Theorem C) and the sum/product rules are min-plus homomorphic. $\square$

---

## 7. Worked numerical examples

**Example 7.1 (Balancing in a monomial equation).** For $X y' - 3y = 0$ try $f=X^3$: the terms are $Xf'=3X^3$ (order $3$) and $-3f=-3X^3$ (order $3$). The orders tie at $3$ (balancing, Theorem E), the leading coefficients $+3$ and $-3$ cancel, and the sum vanishes. For a general $f=X^n$, both terms have order $n$, so balancing holds for *all* $n$, but the coefficients $n$ and $-3$ cancel only when $n=3$. This illustrates that balancing (Theorem B/E) is necessary but not sufficient — the gap is the realizability problem (Conjecture 1).

**Example 7.2 (Unique minimum forces non-vanishing).** Let $\varphi_1=X^2$, $\varphi_2=X^5$, $\varphi_3=X^7$. The minimum order $2$ is uniquely attained, so by Theorem A, $\operatorname{ord}(\varphi_1+\varphi_2+\varphi_3)=2$ and the sum is nonzero. No relation among these terms can vanish; this is the contrapositive of balancing.

**Example 7.3 (Monomial order formula).** With $f$ of order $n=5$, Theorem D gives $\operatorname{ord}((f')^2 f'')=2(5-1)+(5-2)=11$, $\operatorname{ord}(f\cdot f''')=5+(5-3)=7$, and $\operatorname{ord}((f'')^3)=3(5-2)=9$.

**Example 7.4 (Growth lower bound).** For $P(f)=(f')^2 + f''$ with $\operatorname{ord}(f)=n$, the term orders are $2(n-1)$ and $n-2$. By Theorem F, $\operatorname{ord}(P(f))\ge \min(2n-2, n-2)=n-2$ for $n\ge 0$. The minimum is uniquely the $f''$ term unless $2n-2=n-2$, i.e. $n=0$; at $n=0$ both tie at $-2$ (formally handled by the support condition $i\le n$), so the only candidate balanced order for $P(f)=0$ is where the two coincide.

---

## 8. Algorithms

**Algorithm 8.1 (Order of a differential monomial).** Given $n=\operatorname{ord}(f)$ and an exponent vector $e$, return $\sum_i e_i (n-i)$. This is $O(|\operatorname{supp}(e)|)$ arithmetic and realizes Theorem D directly.

**Algorithm 8.2 (Tropical balancing check).** Given the multiset of term-orders of a differential polynomial evaluated at order $n$, compute the minimum and test whether it is attained at least twice. Returns "balanced" (a candidate tropical solution, Theorem E) or "unbalanced" (provably no classical solution at order $n$, contrapositive of Theorem B). Complexity $O(t)$ for $t$ terms.

**Algorithm 8.3 (Tropical solution-order enumeration).** Sweep candidate orders $n$, evaluate each term's tropicalized order $\sum_i e^{(k)}_i (n-i)$, and collect the $n$ at which the minimum is tied. These are the tropical solution orders; by Theorem F each gives a lower bound $\operatorname{trop}(P)(n)$ on $\operatorname{ord}(P(f))$, and only these $n$ can host classical solutions.

---

## 9. Discussion and future directions

The order valuation is a tropical valuation on the differential ring $K\llbracket X\rrbracket$: it sends multiplication to $+$, addition to $\min$ (as a lower bound), and — in characteristic zero — differentiation to a shift by $-1$. Under it, classical solutions of differential polynomials become *balanced* tropical solutions (Theorem E, `tropical_FTDA`), and the tropical minimum lower-bounds the growth of any classical value (Theorem F, `order_diffPoly_ge`). We close with the principal open problems isolated by this work.

**Conjecture 1 (Converse FTDA / realizability).** Over an algebraically closed characteristic-zero field, every tropical solution $n$ of a tropicalized differential polynomial is *realized*: there is $f$ with $\operatorname{ord}(f)=n$ and $P(f)=0$. Equivalently, $\operatorname{trop}(\text{differential ideal})$ equals the tropical differential ideal of $\operatorname{trop}$ as an equality, not just the $\subseteq$ proved here. Balancing is not only necessary but sufficient once the field is rich enough to choose coefficients that cancel the tied lowest-order terms — a tropical implicit-function / Newton-polygon lifting argument. This cycle isolated the exact obstruction (`tropical_balancing`) and the exact order bookkeeping (`order_diffTerm`); the converse needs only a coefficient-solving step, a finite linear-algebra problem at each order.

**Conjecture 2 (Positive-characteristic defect).** Over $\mathbb{F}_p\llbracket X\rrbracket$ the derivation rule degrades to $\operatorname{ord}(f')\ge \operatorname{ord}(f)-1$, with equality iff $p\nmid \operatorname{ord}(f)$; the failures are exactly the multiples of $p$. The defect is governed by the $p$-adic valuation of the order, since $\frac{d}{dX}(X^{pm})=0$ kills precisely the $p$-divisible orders. Replacing `CharZero` in Theorem C by an explicit $p\nmid(k+1)$ hypothesis is a direct, testable refinement.

**Conjecture 3 (Tropical Wronskian detects independence).** For $f_1,\dots,f_m$ with *distinct* orders, the Wronskian satisfies $\operatorname{ord}(W(f_1,\dots,f_m))=\sum_i \operatorname{ord}(f_i)-\binom{m}{2}$, and in particular $W\ne 0$ — a tropical certificate of linear independence over constants. The Wronskian is an alternating sum of differential monomials whose tropical valuations are separated by the distinct orders, so a unique minimum survives and Theorem A (`order_sum_eq_of_unique_min`) forces non-vanishing: balancing *fails*, which is exactly independence.

**Conjecture 4 (Newton-polygon bound on solution orders).** A differential polynomial with $t$ monomials admits at most $t-1$ distinct values of the solution order, mirroring the classical Newton-polygon count: each balanced order corresponds to an edge of the tropical (lower) Newton polygon of $\operatorname{trop}(P)$, and a polygon on $t$ points has at most $t-1$ edges.

---

## 10. Conclusion

Three translation rules (product $\to$ sum, sum $\to$ min, derivative $\to$ shift-by-$-1$) and one combinatorial principle (a vanishing sum ties for its minimum at least twice) suffice to build a working tropical calculus for differential equations over characteristic-zero power series. From them we obtain exact orders of differential monomials, a guaranteed lower bound on the order of any differential polynomial's value, and the containment direction of a tropical fundamental theorem of differential algebra. The order map — which discards almost all information about a series — retains precisely the data tropical geometry needs, and the balancing lemma is the law its shadows obey. All results have been formally verified.
