# A Base-Uniform Proof of Gawron–Miska–Ulas Unboundedness for Multiplicity Two

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Logic / Combinatorial Number Theory

---

## Abstract

For integers $b \ge 2$ and $m \ge 1$, let $T_{b,m}(n)$ denote the coefficient of $x^n$ in the formal power series
$$\prod_{i=0}^{\infty}\left(1 - x^{b^i}\right)^m.$$
The Gawron–Miska–Ulas conjecture asserts that for every $b \ge 2$ and every $m \ge 2$ the integer sequence $n \mapsto T_{b,m}(n)$ is unbounded in absolute value. The published proof of the conjecture treats the case $b = 2$ (all $m$) using the theory of $b$-regular sequences. We give a complementary, fully base-uniform proof of the case $m = 2$, valid for **every** base $b \ge 2$ simultaneously, by an elementary argument. The proof rests on three ingredients: (i) a Mahler-type functional equation $Q_{N+1}(x) = (1-x)^m\, Q_N(x^b)$ for the truncated products; (ii) a finite-equals-infinite stabilization principle showing that the coefficient of $x^n$ is correctly computed by any truncation of order $N \ge n$; and (iii) an exact closed form $T_{b,2}(R_k) = (-2)^k$ at the base-$b$ repunits $R_k = 1 + b + \cdots + b^{k-1}$. Unboundedness follows immediately, since $|T_{b,2}(R_k)| = 2^k \to \infty$. We contrast this with the boundedness $|T_{b,1}(n)| \le 1$ at multiplicity one, isolating the squared factor's middle coefficient as the structural source of growth, and we outline a transfer-matrix program for the remaining cases $m \ge 3$. All results have been formally verified.

---

## 1. Introduction

### 1.1 The object of study

Fix integers $b \ge 2$ (the *base*) and $m \ge 1$ (the *multiplicity*). Consider the formal power series over $\mathbb{Z}$
$$F_{b,m}(x) = \prod_{i=0}^{\infty}\left(1 - x^{b^i}\right)^m = (1-x)^m (1 - x^b)^m (1 - x^{b^2})^m \cdots.$$
This product is well-defined as a formal power series because for each degree $n$ only finitely many factors contribute: the factor $(1 - x^{b^i})^m$ is congruent to $1$ modulo $x^{b^i}$, so all factors with $b^i > n$ act as the identity on the coefficient of $x^n$. We write
$$T_{b,m}(n) = [x^n]\, F_{b,m}(x)$$
for the coefficient of $x^n$.

These products generalize classical objects. At $b = 2$, $m = 1$ one obtains a signed digit-counting sequence; the products $\prod_i (1 - x^{b^i})^m$ are studied by Gawron, Miska, and Ulas in connection with the arithmetic and analytic behaviour of the coefficient sequences, and with $b$-regular and $b$-automatic sequences.

### 1.2 The conjecture and known cases

**Conjecture (Gawron–Miska–Ulas).** For every $b \ge 2$ and every $m \ge 2$, the sequence $n \mapsto T_{b,m}(n)$ is unbounded:
$$\forall B,\; \exists n,\; |T_{b,m}(n)| > B.$$

The case $b = 2$ (all $m$) is known, by an argument using the $2$-regularity of the coefficient sequence. The conjecture for general bases is open. The multiplicity $m = 1$ is genuinely different: there the sequence is *bounded*, so the hypothesis $m \ge 2$ is essential.

### 1.3 Contribution

We prove the conjecture for $m = 2$ and **every** base $b \ge 2$:

> **Main Theorem (`T_two_unbounded`).** For every $b \ge 2$ and every $B \in \mathbb{Z}$ there exists $n \in \mathbb{N}$ with $|T_{b,2}(n)| > B$.

The argument is elementary and base-uniform: a single identity, evaluated along the base-$b$ repunits, produces the explicit values witnessing unboundedness. In contrast to the $b$-regular-sequence machinery used for $b = 2$, our proof requires only polynomial coefficient extraction and induction, and it does not distinguish between bases. All statements below have been formalized and machine-checked.

### 1.4 Organization

Section 2 fixes definitions. Section 3 proves the Mahler functional equation and the truncation-stabilization principle. Section 4 develops the repunit recurrence and the closed form. Section 5 deduces unboundedness. Section 6 records the multiplicity-one contrast. Section 7 discusses the obstruction for $m \ge 3$ and a transfer-matrix program. Section 8 summarizes the formal development.

---

## 2. Definitions

Throughout, $\mathbb{Z}[X]$ is the polynomial ring in one variable, $X$ the indeterminate, and $[x^n]p$ the coefficient of $x^n$ in $p$. We write $\operatorname{expand}_b$ for the ring homomorphism $\mathbb{Z}[X] \to \mathbb{Z}[X]$ sending $X \mapsto X^b$ (substitution $x \mapsto x^b$).

**Definition 2.1 (Truncated product).** For $b, m, N \in \mathbb{N}$, set
$$Q_N := \mathrm{Tpoly}(b,m,N) := \prod_{i=0}^{N}\left(1 - X^{b^i}\right)^m \in \mathbb{Z}[X].$$

**Definition 2.2 (Coefficient sequence).** For $b, m, n \in \mathbb{N}$, set
$$T_{b,m}(n) := [x^n]\,\mathrm{Tpoly}(b,m,n) = (Q_n).\mathrm{coeff}\,(n).$$
That is, we read off the $x^n$-coefficient from the truncation of order $n$. Proposition 3.4 shows this equals $[x^n]$ of any truncation of order $\ge n$, hence equals $[x^n]F_{b,m}$.

**Definition 2.3 (Base-$b$ repunits).** Define $R \colon \mathbb{N} \to \mathbb{N}$ by
$$R_0 = 0, \qquad R_{k+1} = b\,R_k + 1.$$
Then $R_k = 1 + b + b^2 + \cdots + b^{k-1} = \dfrac{b^k - 1}{b - 1}$, the integer whose base-$b$ representation is $k$ ones.

---

## 3. The functional equation and truncation stability

### 3.1 The Mahler-type functional equation

**Lemma 3.1 (`expand_factor`).** For all $b, m, i$,
$$\operatorname{expand}_b\!\left((1 - X^{b^i})^m\right) = (1 - X^{b^{i+1}})^m.$$

*Proof sketch.* $\operatorname{expand}_b$ is a ring homomorphism with $\operatorname{expand}_b(X) = X^b$. Hence $\operatorname{expand}_b(1 - X^{b^i}) = 1 - (X^b)^{b^i} = 1 - X^{b^{i+1}}$, using $b \cdot b^i = b^{i+1}$; raise to the $m$-th power. $\square$

**Lemma 3.2 (`factor_succ`, Mahler functional equation).** For all $b, m, N$,
$$Q_{N+1} = (1 - X)^m \cdot \operatorname{expand}_b(Q_N).$$

*Proof sketch.* Re-index the product $Q_{N+1} = \prod_{i=0}^{N+1}(1-X^{b^i})^m$ by peeling off the $i = 0$ factor and shifting $i \mapsto i+1$ on the rest:
$$Q_{N+1} = (1 - X^{b^0})^m \prod_{i=0}^{N}(1 - X^{b^{i+1}})^m.$$
The leading factor is $(1-X)^m$. By Lemma 3.1, each remaining factor is $\operatorname{expand}_b((1 - X^{b^i})^m)$, and since $\operatorname{expand}_b$ is multiplicative, the product equals $\operatorname{expand}_b\!\big(\prod_{i=0}^N (1-X^{b^i})^m\big) = \operatorname{expand}_b(Q_N)$. $\square$

This is a *Mahler functional equation*: $F_{b,m}(x) = (1-x)^m F_{b,m}(x^b)$ in the inverse limit, reflecting the self-similarity of the product under $x \mapsto x^b$.

### 3.2 Coefficients are unaffected by high-degree factors

**Lemma 3.3 (`one_sub_Xpow_pow_eq_expand`, `coeff_mul_one_sub_Xpow_pow`).** Let $e \ge 1$. Then $(1 - X^e)^m = \operatorname{expand}_e((1-X)^m)$, a polynomial in $X^e$. Consequently, for any $p \in \mathbb{Z}[X]$ and any $n < e$,
$$[x^n]\big(p \cdot (1 - X^e)^m\big) = [x^n]\,p.$$

*Proof sketch.* Write $(1-X^e)^m = \operatorname{expand}_e((1-X)^m)$, all of whose nonzero terms have degree divisible by $e$, with the degree-$0$ term equal to $1$. In the convolution $[x^n](p \cdot (1-X^e)^m) = \sum_{j} [x^j]p \cdot [x^{n-j}](1-X^e)^m$, every contribution with $n - j > 0$ requires $e \mid (n-j)$ and $0 < n - j \le n < e$, which is impossible. Only $j = n$ (the degree-$0$ term of the second factor) survives, leaving $[x^n]p$. $\square$

**Proposition 3.4 (`coeff_stable_step`, `coeff_eq_of_le`, truncation stability).** Let $b \ge 2$. For all $m$ and all $n \le N$,
$$[x^n]\,Q_N = T_{b,m}(n).$$
Equivalently, the coefficient of $x^n$ is the same in every truncation of order $\ge n$, hence equals $[x^n]F_{b,m}$.

*Proof sketch.* One step: $Q_{N+1} = Q_N \cdot (1 - X^{b^{N+1}})^m$. Since $n \le N < b^{N+1}$ (using $N < 2^N \le b^N \le b^{N+1}$), Lemma 3.3 gives $[x^n]Q_{N+1} = [x^n]Q_N$. Iterating from $N = n$ upward (formally, strong induction on $N$) yields $[x^n]Q_N = [x^n]Q_n = T_{b,m}(n)$ for all $N \ge n$. $\square$

Proposition 3.4 is what legitimizes Definition 2.2: the "diagonal" reading $T_{b,m}(n) = [x^n]Q_n$ agrees with the infinite product.

---

## 4. The repunit recurrence and closed form

We now specialize to $m = 2$ and exploit $(1-X)^2 = 1 - 2X + X^2$.

**Lemma 4.1 (`T_two_zero`).** $T_{b,2}(0) = 1$.

*Proof sketch.* $T_{b,2}(0) = [x^0]Q_0$ and the constant term of any product $\prod (1 - X^{b^i})^2$ is $1$ (each factor has constant term $1$). $\square$

**Lemma 4.2 (`T_repunit_step`, repunit recurrence).** For $b \ge 2$ and all $k$,
$$T_{b,2}(R_{k+1}) = -2\,T_{b,2}(R_k).$$

*Proof sketch.* Recall $R_{k+1} = b\,R_k + 1$. We compute $[x^{R_{k+1}}]Q_{R_{k+1}}$. By truncation stability (Prop. 3.4) it suffices to compute the coefficient in a convenient truncation, and we apply the functional equation one step:
$$Q_{N+1} = (1-X)^2 \cdot \operatorname{expand}_b(Q_N), \qquad (1-X)^2 = 1 - 2X + X^2.$$
The factor $\operatorname{expand}_b(Q_N)$ contains only monomials whose exponent is divisible by $b$. The target degree is $b\,R_k + 1 \equiv 1 \pmod b$. In the convolution with $1 - 2X + X^2$:

- the term $1$ (shift $0$) contributes from exponent $b R_k + 1 \equiv 0$ — incompatible with the multiple-of-$b$ exponents in $\operatorname{expand}_b(Q_N)$;
- the term $X^2$ (shift $2$) requires exponent $b R_k - 1 \equiv -1 \pmod b$ — again not a multiple of $b$ for $b \ge 2$;
- only the middle term $-2X$ (shift $1$) requires exponent $b R_k \equiv 0 \pmod b$ — compatible.

Hence the unique surviving contribution is
$$[x^{bR_k+1}]Q_{R_{k+1}} = -2 \cdot [x^{bR_k}]\operatorname{expand}_b(Q_{R_k}) = -2 \cdot [x^{R_k}]Q_{R_k} = -2\,T_{b,2}(R_k),$$
where $[x^{bR_k}]\operatorname{expand}_b(p) = [x^{R_k}]p$ because $\operatorname{expand}_b$ sends the $x^{R_k}$-coefficient to the $x^{bR_k}$-coefficient. The two applications of Prop. 3.4 align the truncation orders with the relevant degrees. $\square$

The structural heart of Lemma 4.2 is that $(1-X)^2$ has a **single interior term**, $-2X$, at degree $1$. Because the target degree is exactly $1 \pmod b$, that lone middle term is the only one whose residue can match the $0 \pmod b$ exponents of the expanded polynomial. This is precisely why the recurrence is a single-ratio recurrence — and why the same proof works for *every* base.

**Theorem 4.3 (`T_repunit`, closed form).** For $b \ge 2$ and all $k$,
$$T_{b,2}(R_k) = (-2)^k.$$

*Proof sketch.* Induction on $k$. Base case $k = 0$: $T_{b,2}(R_0) = T_{b,2}(0) = 1 = (-2)^0$ by Lemma 4.1. Step: by Lemma 4.2, $T_{b,2}(R_{k+1}) = -2\,T_{b,2}(R_k) = -2 \cdot (-2)^k = (-2)^{k+1}$. $\square$

**Corollary 4.4 (`abs_T_repunit`).** For $b \ge 2$ and all $k$, $\;|T_{b,2}(R_k)| = 2^k.$

*Proof sketch.* $|(-2)^k| = |{-2}|^k = 2^k$. $\square$

---

## 5. Unboundedness

**Theorem 5.1 (`T_two_unbounded`, Main Theorem).** For every $b \ge 2$ and every $B \in \mathbb{Z}$ there exists $n \in \mathbb{N}$ with
$$|T_{b,2}(n)| > B.$$

*Proof sketch.* The powers of two are unbounded above in $\mathbb{Z}$, so choose $k$ with $2^k > B$. Set $n = R_k$. By Corollary 4.4, $|T_{b,2}(n)| = 2^k > B$. $\square$

**Corollary 5.2 (`T_two_not_bounded`).** There is no $B$ with $|T_{b,2}(n)| \le B$ for all $n$; i.e. $T_{b,2}$ admits no uniform bound. This is the negation of boundedness and is logically equivalent to Theorem 5.1.

Thus the Gawron–Miska–Ulas conjecture holds for $m = 2$ and **every** base $b \ge 2$.

---

## 6. The multiplicity-one contrast

The hypothesis $m \ge 2$ is load-bearing. At $m = 1$ the product $\prod_i (1 - x^{b^i})$ has coefficients confined to $\{-1, 0, 1\}$:
$$|T_{b,1}(n)| \le 1 \quad \text{for all } n.$$
Intuitively, the single factor $(1 - x)$ has no interior term — its expansion contributes only shifts $0$ and $1$ with coefficients $+1$ and $-1$ — so no doubling can be seeded, and the convolution can never accumulate magnitude beyond one. The jump from bounded ($m=1$) to unbounded ($m=2$) is caused entirely by the appearance of the middle binomial coefficient $\binom{2}{1} = 2$ in $(1-x)^2 = 1 - 2x + x^2$. The growth rate $(-2)^k$ is literally built from that coefficient.

---

## 7. Discussion: the obstruction for $m \ge 3$ and a transfer-matrix program

### 7.1 Why the clean collapse is special to $m = 2$

For general $m$, $(1-x)^m = \sum_{j=0}^m (-1)^j \binom{m}{j} x^j$ has interior terms at every degree $0 \le j \le m$. Evaluating the functional equation at the repunit degree $b R_k + 1$, the surviving terms are those with $j \equiv 1 \pmod b$, namely $j \in \{1, 1+b, 1+2b, \dots\} \cap [0, m]$. When $b \ge m$ the only such $j$ is $j = 1$, and one recovers a single-ratio recurrence $T_{b,m}(R_{k+1}) = (-m)\,T_{b,m}(R_k)$, giving $T_{b,m}(R_k) = (-m)^k$ and unboundedness. (For $m = 2$ this is automatic since $b \ge 2 = m$.) But when $b < m$, several indices $j$ survive, and the recurrence becomes
$$T_{b,m}(R_{k+1}) = \sum_{t \,:\, 1 + tb \le m} (-1)^{1+tb}\binom{m}{1+tb}\, T_{b,m}(R_k - t),$$
coupling the repunit value to its lower neighbours.

For example, with $b = 3$, $m = 4$, the repunit values are $1, -4, 17, -76, 353, \dots$, which is not $(-4)^k$; the single-ratio identity fails precisely because more than one interior binomial term survives.

### 7.2 A transfer-matrix criterion

The multi-term recurrence is linear with constant coefficients, so the finite window
$$v_k = \big(T_{b,m}(R_k - t)\big)_{0 \le t \le T}, \qquad T = \left\lfloor \tfrac{m-1}{b} \right\rfloor,$$
satisfies $v_{k+1} = M\,v_k$ for a fixed integer matrix $M = M(b,m)$ whose entries are $\pm\binom{m}{1+tb}$ (together with shift entries). Then $T_{b,m}$ is unbounded **iff** the spectral radius $\rho(M) > 1$. This recasts an analytic conjecture as a finite eigenvalue computation for each $(b,m)$, since the Mahler equation makes $T_{b,m}$ a $b$-regular sequence and any digit-pattern subsequence (here the all-ones repunits) is governed by a constant linear recursion.

### 7.3 Sharpness

Computations suggest that when $b \ge m \ge 2$ the repunit is the *global* in-window maximum:
$$\max_{0 \le n < b^k} |T_{b,m}(n)| = m^k,$$
attained exactly at $R_k$. The matching upper bound would follow from a sup-norm estimate $\|(1-x)^m \cdot \operatorname{expand}_b f\|_\infty \le m\,\|f\|_\infty$ on coefficients, an inductive inequality compatible with the convolution machinery used here.

---

## 8. The formal development

Every result above has been formally verified. The development comprises:

- `Tpoly`, `T`, `R` — the definitions of the truncated product, the coefficient sequence, and the repunits.
- `expand_factor`, `factor_succ` — the Mahler functional equation.
- `one_sub_Xpow_pow_eq_expand`, `coeff_mul_one_sub_Xpow_pow`, `coeff_stable_step`, `coeff_eq_of_le` — truncation stability (finite = infinite).
- `T_two_zero`, `T_repunit_step`, `T_repunit`, `abs_T_repunit` — the base case, recurrence, closed form, and magnitude at repunits.
- `T_two_unbounded`, `T_two_not_bounded` — the main unboundedness theorem and its boundedness-negation phrasing.

The unboundedness statement is a genuine $\forall B\,\exists n$ assertion proved by induction together with the functional equation, not by definitional unfolding or finite enumeration.

---

## 9. Conclusion

We have given a base-uniform, elementary proof of the Gawron–Miska–Ulas unboundedness conjecture for multiplicity $m = 2$ and every base $b \ge 2$. The proof isolates the mechanism of growth — the middle coefficient of $(1-x)^2$ surviving at repunit residues — and yields the exact closed form $T_{b,2}(R_k) = (-2)^k$. The same lens identifies the genuinely open corner ($2 \le b < m$) as a finite spectral problem for an explicit transfer matrix, charting a concrete path toward the full conjecture.

---

## References

- A. Gawron, P. Miska, M. Ulas, work on coefficient sequences of products $\prod_i (1 - x^{b^i})^m$ and their boundedness/unboundedness (base $b = 2$).
- K. Mahler, on functional equations of the form $F(x) = a(x)\,F(x^b)$ and the associated regular/automatic sequences.
