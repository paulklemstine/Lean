# The Complete Crossing Spectrum of the Fork Channel

**Author:** Aristotle
**Date:** 2026-09-08

---

## Abstract

We study a two-architecture read-out model attached to a branching node of arity $n$. An *address channel* $A(n) = \log_2 n - 1 - \delta(n)$ pays an additive penalty equal to an entropy deficit $\delta(n) = 1/n^{2}$, while an *exchange channel* $X(n) = 2\bigl(1 - \delta(n)\bigr)$ suffers the same deficit multiplicatively. For integral arity, $\delta(n)$ is exactly the collision probability of two independent uniform probes of the ordered branch-pair set $[n] \times [n]$, so the two architectures are degraded by one and the same physical quantity in two different grammars.

Our central structural observation is that the comparison collapses onto a single scalar functional, the *resonance* $R(n) = \log_2 n + 1/n^{2}$, via the exact identity $A(n) - X(n) = R(n) - 3$. We prove that $R$ is strictly increasing on $[2,\infty)$ and strictly decreasing on $(0,1]$, and that at integral arity $m \ge 2$ the comparison is *exactly* one integer inequality per side: $X(m) < A(m)$ if and only if $2^{3m^{2}-1} < m^{m^{2}}$. The two decisive certificates are $7^{49} < 2^{146}$ and $2^{191} < 8^{64}$.

From these we obtain: $A(n) < X(n)$ for all real $2 < n \le 7$; $A(n) > X(n)$ for all real $n \ge 8$; a *unique* crossing $r$ with $7 < r < 8$ on the physical range $n > 2$, settling the uniqueness conjecture; strict monotonicity of the ratio $A/X$ on $[2,\infty)$, which closes the monotonicity gap; and divergence $A/X \to \infty$. Extending to the full positive axis, we determine the crossing spectrum completely: $\{n > 0 : A(n) = X(n)\} = \{1/2, r\}$, where the sub-critical crossing at $n = 1/2$ is *exact* — there $\log_2 n + \delta(n) = -1 + 4 = 3$ and both channels equal $-6$. Finally, two integer power certificates, $253^{64009} < 2^{511048}$ and $2^{2309345} < 507^{257049}$, sharpen the transcendental crossing to the dyadic bracket $253/32 < r < 507/64$, i.e. $7.90625 < r < 7.921875$.

**Keywords:** fork channel, entropy deficit, collision probability, resonance functional, crossing uniqueness, integer certificates, dyadic bracketing, unimodality.

---

## 1. Introduction

### 1.1 The problem

A branching node with $n$ outgoing branches — a *fork of arity $n$* — must be read out. Two elementary architectures suggest themselves, and they respond to the node's imperfection in structurally different ways.

The **address channel** names branches. Naming one of $n$ branches costs $\log_2 n$ bits, of which one bit is consumed by the fork decision itself. The imperfection of the node, quantified by an *entropy deficit* $\delta(n)$, is charged as a straight subtraction from the payload:

$$A(n) \;=\; \log_2 n \;-\; 1 \;-\; \delta(n).$$

The **exchange channel** does not name. It always transmits a fixed two-bit packet, but the node's imperfection degrades its *rate*, multiplicatively:

$$X(n) \;=\; 2\bigl(1 - \delta(n)\bigr).$$

The same physical quantity $\delta(n)$ enters both expressions; only the grammar of degradation differs. The question is which channel is better, and — much harder — how many times the answer changes as $n$ ranges over the arities.

Numerically, the exchange channel dominates for small forks and the address channel eventually dominates, since $\log_2 n \to \infty$ while $X(n) < 2$ for all $n > 0$. A sign change is therefore forced somewhere. Sampling shows it occurs between $n = 7$ and $n = 8$. What sampling cannot establish is that this is the *only* sign change: a table of values is compatible with any number of further crossings at arities not sampled.

### 1.2 Results

We settle the question completely, and in fact more than completely: we determine the crossing spectrum on the whole positive axis, not merely on the physical range.

1. **Collapse.** $A(n) - X(n) = R(n) - 3$ where $R(n) = \log_2 n + \delta(n)$. All comparison questions become level-set questions for the single functional $R$.
2. **Monotonicity.** $R$ is strictly increasing on $[2,\infty)$ and strictly decreasing on $(0,1]$; on $[1,2]$ it satisfies $R \le 2$.
3. **Integer criterion.** For integral $m \ge 2$: $X(m) < A(m) \iff 2^{3m^{2}-1} < m^{m^{2}}$, and $A(m) < X(m) \iff m^{m^{2}} < 2^{3m^{2}-1}$. Decisive certificates: $7^{49} < 2^{146}$ and $2^{191} < 8^{64}$.
4. **Sign dichotomy.** $A(n) < X(n)$ for real $2 < n \le 7$; $X(n) < A(n)$ for real $n \ge 8$.
5. **Uniqueness.** There is exactly one $r > 2$ with $A(r) = X(r)$, and $7 < r < 8$.
6. **Ratio.** $A/X$ is strictly increasing on $[2,\infty)$ and $A(n)/X(n) \to \infty$.
7. **Complete spectrum.** $\{n > 0 : A(n) = X(n)\} = \{1/2, r\}$, with $A(1/2) = X(1/2) = -6$ exactly.
8. **Sharpened bracket.** $253/32 < r < 507/64$, certified by two integer power inequalities.

### 1.3 Method

Three ideas carry the paper. First, the *collapse*: an algebraic identity that reduces a two-function comparison to a one-function level set. Second, *unimodality*: the resonance functional has exactly one interior minimum, which caps the number of crossings at two before any numerics are done. Third, *integer certification*: every decisive numerical comparison is reduced to an inequality between two integer powers, so that no approximation error can enter anywhere.

---

## 2. The model

### 2.1 Definitions

Throughout, $\log_2$ denotes the base-$2$ logarithm and $\ln$ the natural logarithm.

**Definition 2.1 (Entropy deficit).** The *entropy deficit* of a fork of arity $n \ne 0$ is
$$\delta(n) \;=\; \frac{1}{n^{2}}.$$

**Definition 2.2 (Address channel).** $\;A(n) = \log_2 n - 1 - \delta(n)$.

**Definition 2.3 (Exchange channel).** $\;X(n) = 2\bigl(1 - \delta(n)\bigr)$.

**Definition 2.4 (Resonance).** $\;R(n) = \log_2 n + \delta(n)$.

**Definition 2.5 (Channel ratio).** $\;\rho(n) = A(n) / X(n)$, defined wherever $X(n) \ne 0$.

### 2.2 Combinatorial grounding of the deficit

The deficit is not an arbitrary correction term; at integral arity it is a probability attached to the fork itself.

**Proposition 2.6 (Deficit as fork collision probability).** Let $n \ge 1$ be an integer and let $S = [n] \times [n]$ be the set of ordered pairs of branches, $|S| = n^{2}$. Draw two elements of $S$ independently and uniformly. The probability that they coincide equals $\delta(n)$.

*Proof.* The favourable outcomes are the diagonal of $S \times S$, which has $|S| = n^{2}$ elements; the total is $|S|^{2} = (n^{2})^{2}$. Hence the collision probability is $n^{2}/(n^{2})^{2} = 1/n^{2} = \delta(n)$. $\square$

Thus both channels are degraded by the same, combinatorially meaningful quantity: the chance that two independent probes of the fork's ordered branch-pair structure return the same answer.

### 2.3 Elementary properties of the exchange channel

**Lemma 2.7 (Sharpened finite-$n$ identity).** For $n \ne 0$, $\;X(n)\,n^{2} = 2n^{2} - 2$.

*Proof.* $X(n)n^{2} = 2(1 - n^{-2})n^{2} = 2n^{2} - 2$. $\square$

This identity is what makes the integer criterion of Section 4 possible: it clears the only denominator in the model.

**Lemma 2.8 (Positivity and ceiling).** For $n > 1$, $\;0 < X(n)$; for $n > 0$, $\;X(n) < 2$.

*Proof.* If $n > 1$ then $n^{2} > 1$, so $\delta(n) = 1/n^{2} < 1$ and $X(n) = 2(1 - \delta(n)) > 0$. If $n > 0$ then $\delta(n) > 0$, so $X(n) < 2$. $\square$

The ceiling $X < 2$ is the structural reason the address channel must eventually win: the exchange channel has a hard cap that the unbounded $\log_2 n$ overtakes.

---

## 3. The collapse

**Theorem 3.1 (Collapse identity).** For every $n \ne 0$,
$$A(n) - X(n) \;=\; R(n) - 3 .$$

*Proof.* Expand both sides in terms of $\delta = \delta(n)$:
$$A(n) - X(n) = (\log_2 n - 1 - \delta) - (2 - 2\delta) = \log_2 n + \delta - 3 = R(n) - 3 . \qquad \square$$

The identity is deceptively simple but it is the pivot of the whole development. The additive deficit contributes $-\delta$ and the multiplicative deficit contributes $+2\delta$; they do not cancel, they *reinforce*, leaving exactly $+\delta$ in the difference. That is why the difference is not a logarithm minus a constant (which would be trivially monotone) but a genuine competition between two terms of opposite monotonicity.

**Corollary 3.2 (Comparison trichotomy).** For every $n \ne 0$:
$$A(n) < X(n) \iff R(n) < 3, \qquad X(n) < A(n) \iff R(n) > 3, \qquad A(n) = X(n) \iff R(n) = 3 .$$

*Proof.* Immediate from Theorem 3.1. $\square$

From here on, the two-channel problem is the level-set problem $R^{-1}(3)$.

---

## 4. Derivatives and the shape of the resonance

### 4.1 Derivatives

**Lemma 4.1.** For $n \ne 0$: $\;\delta'(n) = -2/n^{3}$, $\;\bigl(\log_2 n\bigr)' = 1/(n \ln 2)$, and consequently
$$R'(n) = \frac{1}{n \ln 2} - \frac{2}{n^{3}}, \qquad A'(n) = \frac{1}{n \ln 2} + \frac{2}{n^{3}}, \qquad X'(n) = \frac{4}{n^{3}} .$$

*Proof.* Quotient rule for $\delta = 1/n^{2}$; the chain rule and $\log_2 n = \ln n / \ln 2$ for the logarithm; the rest is linearity. $\square$

Note the qualitative content: $A' > 0$ and $X' > 0$ on $n > 0$ — both channels improve with arity — so the competition is between two increasing functions, and no naive sign argument can settle it.

### 4.2 Unimodality

**Lemma 4.2 (Sign of $R'$).** $R'(n) > 0$ if and only if $n^{2} > 2 \ln 2$, i.e. $n > \sqrt{2\ln 2} = 1.1774\ldots$ (for $n > 0$).

*Proof.* For $n > 0$, $R'(n) > 0 \iff 1/(n\ln 2) > 2/n^{3} \iff n^{3} > 2 n \ln 2 \iff n^{2} > 2\ln 2$. $\square$

**Theorem 4.3 (Strict monotonicity on the physical range).** $R$ is strictly increasing on $[2,\infty)$.

*Proof.* $R$ is continuous on $[2,\infty)$ and differentiable on $(2,\infty)$. For $n \ge 2$ we have $n^{3} \ge 4n$, while $2n\ln 2 < 2n \cdot 0.6931471808 < 1.3863\,n < 4n$; hence $n^{3} > 2n\ln 2$, i.e. $n^{2} > 2\ln 2$, and Lemma 4.2 gives $R' > 0$ on $(2,\infty)$. A function continuous on an interval with positive derivative on its interior is strictly increasing there. $\square$

**Theorem 4.4 (Strict antitonicity on sub-critical arity).** $R$ is strictly decreasing on $(0,1]$.

*Proof.* By Lemma 4.2, $R'(n) < 0$ for $0 < n < \sqrt{2\ln 2}$. For $0 < n \le 1$ we have $n^{2} \le 1 < 1.3862\ldots = 2\ln 2$, so $R' < 0$ on $(0,1)$. Continuity on $(0,1]$ together with a negative derivative on the interior yields strict decrease. $\square$

**Lemma 4.5 (The separating interval is inert).** For $1 \le n \le 2$, $\;R(n) \le 2$.

*Proof.* Monotonicity of $\log_2$ gives $\log_2 n \le \log_2 2 = 1$; and $n \ge 1$ gives $\delta(n) = 1/n^{2} \le 1$. Add. $\square$

Together, Theorems 4.3, 4.4 and Lemma 4.5 say that $R$ is *unimodal* on $(0,\infty)$ with a single interior minimum at $n_\star = \sqrt{2\ln 2} \approx 1.1774$ (where $R(n_\star) \approx 0.9570$), and that the transition band $[1,2]$ sits strictly below the critical level $3$. This is the structural fact from which the crossing count follows: **a unimodal function meets a horizontal line strictly above its minimum in at most two points.**

---

## 5. The integer criterion

The next result is the arithmetic heart of the paper: at integral arity the comparison of two transcendental expressions is *equivalent* to a single inequality between integers.

**Lemma 5.1 (Clearing the logarithm).** For $n > 0$,
$$R(n) < 3 \iff (\ln n)\, n^{2} < \bigl(3n^{2} - 1\bigr)\ln 2, \qquad R(n) > 3 \iff \bigl(3n^{2} - 1\bigr)\ln 2 < (\ln n)\, n^{2}.$$

*Proof.* Write $R(n) = \frac{\ln n}{\ln 2} + \frac{1}{n^{2}} = \frac{n^{2}\ln n + \ln 2}{n^{2}\ln 2}$. Since $n^{2}\ln 2 > 0$, the inequality $R(n) < 3$ is equivalent to $n^{2}\ln n + \ln 2 < 3n^{2}\ln 2$, i.e. to $n^{2}\ln n < (3n^{2}-1)\ln 2$. Likewise for the reverse. $\square$

**Lemma 5.2 (Exponentiation).** For an integer $m \ge 2$,
$$(\ln m)\, m^{2} < \bigl(3m^{2}-1\bigr)\ln 2 \iff m^{\,m^{2}} < 2^{\,3m^{2}-1}.$$

*Proof.* $\ln\bigl(m^{m^{2}}\bigr) = m^{2}\ln m$ and $\ln\bigl(2^{3m^{2}-1}\bigr) = (3m^{2}-1)\ln 2$, and $\ln$ is strictly increasing on positive reals; both sides are positive. $\square$

**Theorem 5.3 (Integer criterion — one inequality per side).** Let $m \ge 2$ be an integer. Then
$$A(m) < X(m) \iff m^{\,m^{2}} < 2^{\,3m^{2}-1}, \qquad\qquad X(m) < A(m) \iff 2^{\,3m^{2}-1} < m^{\,m^{2}} .$$

*Proof.* Combine Corollary 3.2, Lemma 5.1 and Lemma 5.2. $\square$

Thus the entire comparison table of the two channels, over all integer arities, is determined by one integer inequality per row. Two rows decide the crossing.

**Proposition 5.4 (Decisive certificates).**
$$7^{49} < 2^{146} \qquad\text{and}\qquad 2^{191} < 8^{64}.$$

*Proof.* Both are finite integer computations. For the second there is a one-line argument: $8^{64} = (2^{3})^{64} = 2^{192} > 2^{191}$. For the first, $7^{49}$ has $42$ decimal digits and $2^{146}$ has $44$; explicitly $7^{49} \approx 2.567 \times 10^{41}$ while $2^{146} \approx 8.923 \times 10^{43}$. $\square$

**Corollary 5.5.** $A(7) < X(7)$ and $X(8) < A(8)$; equivalently $R(7) < 3 < R(8)$.

*Proof.* Apply Theorem 5.3 with $m = 7$ ($m^{2} = 49$, $3m^{2}-1 = 146$) and $m = 8$ ($m^{2} = 64$, $3m^{2}-1 = 191$), then Corollary 3.2. $\square$

Numerically, $R(7) = 2.82776\ldots$ and $R(8) = 3.015625$ exactly (since $\log_2 8 = 3$ and $1/64 = 0.015625$). The margin at $n = 8$ is thin — one part in sixty-four — which is precisely why an exact certificate rather than a numerical estimate is desirable.

---

## 6. The sign dichotomy and uniqueness

**Theorem 6.1 (Negative side).** For every real $n$ with $2 < n \le 7$, $\;A(n) < X(n)$.

*Proof.* By Theorem 4.3, $R$ is strictly increasing on $[2,\infty)$, so $R(n) \le R(7)$ for $2 < n \le 7$. By Corollary 5.5, $R(7) < 3$. Hence $R(n) < 3$, and Corollary 3.2 gives $A(n) < X(n)$. $\square$

**Theorem 6.2 (Positive side).** For every real $n \ge 8$, $\;X(n) < A(n)$.

*Proof.* By Theorem 4.3, $R(n) \ge R(8)$ for $n \ge 8$, and $R(8) > 3$ by Corollary 5.5. Apply Corollary 3.2. $\square$

**Theorem 6.3 (Uniqueness of the crossing).** There exists exactly one real $r > 2$ with $A(r) = X(r)$, and it satisfies $7 < r < 8$.

*Proof.* *Existence.* $R$ is continuous on $[7,8]$ and $R(7) < 3 < R(8)$, so by the intermediate value theorem there is $r \in [7,8]$ with $R(r) = 3$; by Corollary 3.2, $A(r) = X(r)$, and $r \ge 7 > 2$.

*Uniqueness.* If $y > 2$ also satisfies $A(y) = X(y)$, then $R(y) = 3 = R(r)$ with $y, r \in [2,\infty)$. A strictly increasing function is injective, so $y = r$ by Theorem 4.3.

*Location.* If $r \le 7$ then Theorem 6.1 gives $A(r) < X(r)$, a contradiction; if $r \ge 8$ then Theorem 6.2 gives $X(r) < A(r)$, again a contradiction. Hence $7 < r < 8$. $\square$

This settles the conjecture: the crossing observed between $n = 7$ and $n = 8$ is the only crossing on the physical range. Numerically $r = 7.9119050\ldots$

---

## 7. The ratio $A/X$

Beyond the sign, one wants the *magnitude* of the advantage, and whether it can ever recede.

**Theorem 7.1 (Strict monotonicity of the ratio).** The ratio $\rho = A/X$ is strictly increasing on $[2,\infty)$; in particular on $[8,\infty)$, which is exactly the monotonicity statement needed to see that the advantage of the address channel never regresses once acquired.

*Proof.* On $n \ge 2$ we have $X(n) > 0$ (Lemma 2.8), so $\rho$ is differentiable with
$$\rho'(n) = \frac{A'(n)X(n) - A(n)X'(n)}{X(n)^{2}} .$$
Substituting Lemma 4.1 and simplifying (multiply out by $n^{3}\ln 2$ and use $X(n)n^{2} = 2n^{2}-2$) gives the closed form for the numerator:
$$A'(n)X(n) - A(n)X'(n) \;=\; \frac{2\bigl[(n^{2} - 1) + 4\ln 2 - 2\ln n\bigr]}{n^{3}\ln 2}.$$
The bracket is positive for all $n > 0$: from $\ln n \le n - 1$ we get $2\ln n \le 2n - 2 \le n^{2} - 1$ (the latter because $n^{2} - 2n + 1 = (n-1)^{2} \ge 0$), so $(n^{2}-1) - 2\ln n \ge 0$, and $4\ln 2 > 0$ strictly. Hence $\rho' > 0$ on $(2,\infty)$, and $\rho$ is continuous on $[2,\infty)$, so it is strictly increasing there. $\square$

The bracket $(n^{2}-1) + 4\ln 2 - 2\ln n$ has minimum value $4\ln 2 \approx 2.77$ at $n = 1$, so the positivity is comfortable, not marginal — the monotonicity is robust to a wide class of perturbations of the model.

**Lemma 7.2 (Lower bound on the ratio).** For $n \ge 8$, $\;\rho(n) \ge \dfrac{\log_2 n - 2}{2}$.

*Proof.* For $n \ge 8$ we have $\delta(n) \le 1$, hence $A(n) \ge \log_2 n - 2$; also $\log_2 n \ge 3$, so $A(n) \ge 1 > 0$. Since $0 < X(n) < 2$ (Lemma 2.8), $\rho(n) = A(n)/X(n) \ge A(n)/2 \ge (\log_2 n - 2)/2$. $\square$

**Theorem 7.3 (Divergence).** $\;\rho(n) \to \infty$ as $n \to \infty$.

*Proof.* $\log_2 n \to \infty$, so $(\log_2 n - 2)/2 \to \infty$, and Lemma 7.2 dominates $\rho$ from below eventually. $\square$

So the address channel does not merely overtake the exchange channel; it outperforms it by an unbounded factor, gaining one unit of ratio per two doublings of the arity.

---

## 8. The complete crossing spectrum

The physical model lives on $n > 2$, but the resonance functional is defined on all of $(0,\infty)$, and its unimodality (Section 4.2) says the level $3$ — which lies well above the minimum value $R(n_\star) \approx 0.9570$ — must be met *twice*. Where is the second point?

**Theorem 8.1 (The exact sub-critical crossing).** At $n = 1/2$,
$$\log_2 \tfrac12 + \delta(\tfrac12) = -1 + 4 = 3, \qquad A(\tfrac12) = X(\tfrac12) = -6 .$$

*Proof.* $\log_2(1/2) = -1$ and $\delta(1/2) = 1/(1/2)^{2} = 4$, so $R(1/2) = 3$. Then $A(1/2) = -1 - 1 - 4 = -6$ and $X(1/2) = 2(1 - 4) = -6$. $\square$

This is the *hidden resonance* between the logarithm and the entropy deficit: an exact integer coincidence between a dyadic logarithm and a dyadic deficit, not an approximate numerical one. It is a closed-form solution of a transcendental equation, available only because $1/2$ is a power of $2$.

**Theorem 8.2 (Complete crossing spectrum).** There is a real $r$ with $7 < r < 8$ such that
$$\{\, n > 0 \;:\; A(n) = X(n) \,\} \;=\; \{\, \tfrac12,\; r \,\}.$$

*Proof.* By Corollary 3.2 the set equals $\{n > 0 : R(n) = 3\}$. Let $n > 0$ with $R(n) = 3$.

- If $n \le 1$: $R$ is strictly decreasing, hence injective, on $(0,1]$ (Theorem 4.4), and $R(1/2) = 3$ with $1/2 \in (0,1]$. Therefore $n = 1/2$.
- If $1 < n < 2$: Lemma 4.5 gives $R(n) \le 2 < 3$, a contradiction; no crossing here.
- If $n \ge 2$: $R$ is strictly increasing, hence injective, on $[2,\infty)$ (Theorem 4.3), and $R(r) = 3$ with $r \ge 2$ by Theorem 6.3. Therefore $n = r$.

Conversely both $1/2$ (Theorem 8.1) and $r$ (Theorem 6.3) lie in the set. $\square$

Two crossings, not one and not three: the count is forced by the shape of $R$, not by any numerical accident. Note that the mission statement's expectation of "a second crossing at small $n$" is *false* on the physical range $n > 2$ (Theorem 6.3) but *true and exactly solvable* on the analytic continuation to $n > 0$.

---

## 9. Bracketing the transcendental crossing by integer certificates

The dyadic crossing is exact; the other is transcendental and can only be bracketed. The point of this section is that bracketing, too, reduces to pure integer arithmetic — no floating point at any stage.

**Lemma 9.1 (Logarithm bounds from integer powers).** Let $x > 0$ and let $p, q$ be positive integers.
- If $x^{q} < 2^{p}$ then $\log_2 x < p/q$.
- If $2^{p} < x^{q}$ then $p/q < \log_2 x$.

*Proof.* Taking $\ln$ of $x^{q} < 2^{p}$ gives $q\ln x < p\ln 2$, hence $\ln x/\ln 2 < p/q$ since $q, \ln 2 > 0$. Symmetrically for the other. $\square$

**Proposition 9.2 (The two bracketing certificates).**
$$253^{64009} < 2^{511048} \qquad\text{and}\qquad 2^{2309345} < 507^{257049}.$$

These are exact integer comparisons (the numbers have roughly $1.5\times 10^{5}$ and $7\times 10^{5}$ decimal digits respectively). The exponents are chosen as $q = 253^{2} = 64009$ and $q = 507^{2} = 257049$, matching the denominators produced by the deficit at the dyadic points below.

**Theorem 9.3 (Dyadic bracket).** The transcendental crossing satisfies
$$\frac{253}{32} \;<\; r \;<\; \frac{507}{64}, \qquad\text{i.e.}\qquad 7.90625 < r < 7.921875 .$$

*Proof.* At $n_- = 253/32$: since $32 = 2^{5}$, $\log_2 n_- = \log_2 253 - 5$, and $\delta(n_-) = 32^{2}/253^{2} = 1024/64009$. Lemma 9.1 with the first certificate ($q = 64009 = 253^{2}$, $p = 511048$) gives $\log_2 253 < 511048/64009$. Hence
$$R(n_-) \;<\; \frac{511048}{64009} - 5 + \frac{1024}{64009} \;=\; \frac{512072}{64009} - 5 \;=\; 8 - 5 \;=\; 3,$$
using $8 \cdot 64009 = 512072$. Thus $R(253/32) < 3$.

At $n_+ = 507/64$: since $64 = 2^{6}$, $\log_2 n_+ = \log_2 507 - 6$, and $\delta(n_+) = 4096/257049$. Lemma 9.1 with the second certificate ($q = 257049 = 507^{2}$, $p = 2309345$) gives $\log_2 507 > 2309345/257049$. Hence
$$R(n_+) > \frac{2309345}{257049} - 6 + \frac{4096}{257049} = \frac{2313441}{257049} - 6 = 9 - 6 = 3,$$
using $9 \cdot 257049 = 2313441$. Thus $R(507/64) > 3$.

Since $R$ is strictly increasing on $[2,\infty)$ and $R(r) = 3$, we conclude $253/32 < r < 507/64$. $\square$

The design of the certificates is worth isolating, because it generalises. To test $R(a/2^{k})$ against $3$ for an integer $a$ and $k \ge 0$, write $R(a/2^{k}) = \log_2 a - k + 4^{k}/a^{2}$. The target inequality $R < 3$ becomes $\log_2 a < (3 + k) - 4^{k}/a^{2}$, i.e. $a^{2}\log_2 a < (3+k)a^{2} - 4^{k}$, i.e.
$$a^{\,a^{2}} \;<\; 2^{\,(3+k)a^{2} - 4^{k}} ,$$
an inequality between two integers with no logarithms at all. With $a = 253$, $k = 5$: $a^{2} = 64009$ and $(3+5)\cdot 64009 - 1024 = 512072 - 1024 = 511048$. With $a = 507$, $k = 6$: $a^{2} = 257049$ and $(3+6)\cdot 257049 - 4096 = 2313441 - 4096 = 2309345$. Every dyadic bracket, at any precision, is certified this way by exactly one integer power comparison per endpoint. The true value is $r = 7.91190503766\ldots$

---

## 10. Algorithms

Three computational procedures encapsulate the constructive content.

### 10.1 Exact integer arity test

**Input:** integer $m \ge 2$. **Output:** which channel wins at arity $m$.

Compute $L = m^{m^{2}}$ and $Rt = 2^{3m^{2}-1}$ as exact integers and compare. By Theorem 5.3 this is a *complete* decision procedure with no numerical error. Both numbers have $\Theta(m^{2}\log m)$ bits, so the cost is dominated by the exponentiation, $O(m^{2}\log m)$ multiplications by repeated squaring on numbers of that size — quite feasible for $m$ up to a few hundred. A cheaper equivalent test compares $m^{2}\log_2 m + 1$ with $3m^{2}$ in high-precision rational arithmetic, but the integer version is the one that carries a certificate.

### 10.2 Certified dyadic bracketing of the crossing

**Input:** a target dyadic precision $2^{-k}$. **Output:** integers $a$ with $R(a/2^{k}) < 3 < R((a+1)/2^{k})$, each verified by an integer power comparison.

Bisect on the dyadic grid $\{a/2^{k}\}$. At each candidate, decide the sign of $R(a/2^{k}) - 3$ using
$$R\!\left(\frac{a}{2^{k}}\right) < 3 \iff a^{\,a^{2}} < 2^{\,(3+k)a^{2} - 4^{k}} ,$$
an exact integer test. The bisection needs $O(k)$ tests, and each test is an exponentiation of numbers with $\Theta(a^{2}\log a)$ bits. This produces the bracket $253/32 < r < 507/64$ at $k = 5,6$ and can be pushed further at rapidly growing cost.

### 10.3 Fast high-precision root refinement

For pure numerics (no certificate), Newton's method on $F(n) = R(n) - 3$ with
$$F'(n) = \frac{1}{n\ln 2} - \frac{2}{n^{3}}$$
converges quadratically from any start in $[7,8]$, since $F' > 0$ and $F$ is smooth and convex-free of pathology on that interval. Starting from $n_0 = 7.9$, three iterations give $r$ to more than $12$ digits. The certified bracketing of §10.2 is then used to confirm the digits rigorously.

---

## 11. Discussion

### 11.1 What made uniqueness hard

Existence of a crossing is a two-point computation. Uniqueness is a global statement, and no finite amount of sampling implies it. What supplies the global control here is not a sharper numeric but a structural fact: the difference $A - X$ is, up to an additive constant, a *single* functional $R$ whose derivative changes sign exactly once on $(0,\infty)$. Once unimodality is in hand, the crossing count is at most two before any numbers are examined; the numbers only locate the crossings.

The pattern is general. Whenever two architectures are degraded by the same quantity — one additively, one multiplicatively — the difference of their performances is a linear combination of the degradation and whatever else distinguishes them, so the comparison becomes a level-set problem for one functional. Counting solutions is then a question about the *shape* of that functional, which is often accessible even when the functional's roots are not.

### 11.2 Why integer certificates

The critical margin at $n = 8$ is $R(8) - 3 = 1/64$, and at $n = 7$ it is $3 - R(7) \approx 0.172$. Neither is tight enough to worry a double-precision computation, but the dyadic bracketing of §9 operates on margins of order $10^{-5}$ and below, where naive floating point would be untrustworthy. Reducing every decisive comparison to an inequality between two integers eliminates the issue entirely: the statement $2^{191} < 8^{64}$ is either true or false, with no error term. It is also, in this case, humanly checkable: $8^{64} = 2^{192}$.

### 11.3 Robustness of the model

Nothing in the collapse identity used the exponent $2$ in $\delta(n) = 1/n^{2}$. For any $s > 0$ the same computation with $\delta_s(n) = n^{-s}$ gives
$$A_s(n) - X_s(n) = R_s(n) - 3, \qquad R_s(n) = \log_2 n + n^{-s} ,$$
and $R_s'(n) = \frac{1}{n\ln 2} - s n^{-s-1}$ vanishes exactly once, at $n^{s} = s\ln 2$. So the whole family is unimodal, and its minimum value simplifies remarkably. Writing $u = s\ln 2$, the minimiser is $n_\star = u^{1/s}$ and
$$R_s^{\min} = \frac{\log_2 u}{s} + \frac{1}{u} = \frac{\ln u}{u} + \frac{1}{u} = \frac{1 + \ln u}{u}.$$
The function $u \mapsto (1 + \ln u)/u$ has derivative $-(\ln u)/u^{2}$, so it is maximised at $u = 1$ with value exactly $1$. Hence

> **Universal valley bound.** For every $s > 0$, $\;R_s^{\min} \le 1$, with equality precisely when $s = 1/\ln 2 = \log_2 e = 1.4427\ldots$

Since the critical level $3$ exceeds $1$, it clears the valley floor for *every* deficit exponent: the two-crossing structure found here is not an artefact of $s = 2$ but a universal feature of the family. Indeed any level $c > 1$ is met exactly twice, for every $s > 0$. For $s = 2$ one has $u = 2\ln 2 \approx 1.386$ and $R_2^{\min} = (1 + \ln u)/u \approx 0.957$, and the two crossings are $1/2$ and $r$.

### 11.4 The dyadic coincidence

The exact crossing at $n = 1/2$ arises because $\log_2$ and $\delta$ are *simultaneously* rational at powers of two: $R(2^{-k}) = 4^{k} - k$. The critical level $3$ is hit at $k = 1$ because $4 - 1 = 3$. Since $k \mapsto 4^{k} - k$ is strictly increasing for $k \ge 1$ and takes the values $1, 3, 14, 61, 252, \ldots$ at $k = 0, 1, 2, 3, 4$, no other dyadic arity of the form $2^{-k}$ resonates at level $3$ — the coincidence at $k = 1$ is isolated. The same table shows which integer levels *are* dyadically attainable: exactly the numbers $4^{k} - k$.

---

## 12. Future work

**Dyadic rigidity of resonance levels.** The relation $R(2^{-k}) = 4^{k} - k$ turns the question "for which integer levels $c$ does $R(n) = c$ admit a dyadic solution?" into a purely Diophantine one. The sequence $\rho_k = 4^{k} - k$ is strictly increasing for $k \ge 1$ with $\rho_1 = 3$; we conjecture that for every integer level $c$ the equation $R(n) = c$ has at most one solution of the form $n = 2^{-k}$, $k \ge 0$. More generally one may ask for solutions at arbitrary dyadic rationals $a/2^{k}$, which by §9 is equivalent to the integer equation $a^{a^{2}} = 2^{(c+k)a^{2} - 4^{k}}$ — solvable only when $a$ is itself a power of two, suggesting a rigidity statement.

**Deficit exponent families.** As shown in §11.3, the family $R_s(n) = \log_2 n + n^{-s}$ has valley floor $(1 + \ln(s\ln 2))/(s\ln 2) \le 1$ for all $s > 0$, so the level $3$ is always met exactly twice. Two questions follow. First: for which $s$ is the sub-critical crossing *exactly solvable*, as it is at $s = 2$ where it equals $1/2$? Second: how does the super-critical crossing $r(s)$ behave as a function of $s$ — it is the unique large solution of $\log_2 n = 3 - n^{-s}$, hence $r(s) \uparrow 8$ as $s \to \infty$, and one would like the asymptotic expansion of $8 - r(s)$.

**Higher-arity read-out models.** Replacing the two-bit exchange packet by a $b$-bit packet changes the critical level from $3$ to $b + 1$, and the same analysis applies verbatim; the crossing arity then grows roughly like $2^{b+1}$, and the integer criterion becomes $m^{m^{2}} \lessgtr 2^{(b+1)m^{2}-1}$. Charting the crossing arity as a function of $b$, and identifying for which $b$ the crossing falls exactly on an integer arity, is a well-posed and probably delicate question.

**Non-uniform forks.** The collision probability grounding of the deficit suggests replacing the uniform branch distribution by an arbitrary one, in which case $\delta$ becomes the Rényi-$2$ collision probability $\sum_i p_i^{2}$ and $\log_2 n$ becomes the Shannon entropy. The collapse identity survives — $A - X = H(p) + \delta(p) - 3$ — and the comparison becomes a question about the interaction of Shannon and Rényi-$2$ entropies on the simplex, which is a genuinely richer geometry than the one-dimensional problem solved here.

---

## 13. Summary of results

| Statement | Content |
|---|---|
| Collapse identity | $A(n) - X(n) = R(n) - 3$, $\;R(n) = \log_2 n + 1/n^{2}$ |
| Deficit grounding | $\delta(n) = 1/n^{2}$ is the collision probability of $[n]\times[n]$ |
| Monotonicity | $R$ strictly increasing on $[2,\infty)$, strictly decreasing on $(0,1]$, $\le 2$ on $[1,2]$ |
| Integer criterion | For integers $m\ge 2$: $X(m)<A(m) \iff 2^{3m^{2}-1} < m^{m^{2}}$ |
| Certificates | $7^{49} < 2^{146}$; $\;2^{191} < 8^{64}$ |
| Sign dichotomy | $A<X$ on $(2,7]$; $\;A>X$ on $[8,\infty)$ |
| Uniqueness | Exactly one $r>2$ with $A(r)=X(r)$; $\;7<r<8$ |
| Ratio | $A/X$ strictly increasing on $[2,\infty)$; $\;A/X \to \infty$ |
| Full spectrum | $\{n>0 : A(n)=X(n)\} = \{1/2, r\}$, with $A(1/2)=X(1/2)=-6$ |
| Sharp bracket | $253/32 < r < 507/64$ via $253^{64009}<2^{511048}$ and $2^{2309345}<507^{257049}$ |
