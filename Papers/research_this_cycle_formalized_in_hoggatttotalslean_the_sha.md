# A Möbius Discriminant Governing the Log-Behavior of First-Order Multiplicative Recurrences

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We isolate a single scalar invariant that completely determines the logarithmic growth character of any positive sequence satisfying a first-order multiplicative recurrence of the form $(\alpha n + \beta)\,a_{n+1} = (\gamma n + \delta)\,a_n$ with $\alpha n + \beta > 0$. We call
$$\Delta \;=\; \gamma\beta - \alpha\delta$$
the **Möbius discriminant** of the recurrence, and we prove the following **trichotomy**: the sequence is strictly log-convex when $\Delta > 0$, log-linear (geometric) when $\Delta = 0$, and strictly log-concave when $\Delta < 0$. The mechanism is that the consecutive ratio $a_{n+1}/a_n$ equals the Möbius (linear-fractional) function $(\gamma n + \delta)/(\alpha n + \beta)$, whose forward difference has the *index-independent* numerator $\Delta$; hence the ratio is strictly monotone, constant, or strictly antitone according to the sign of $\Delta$, uniformly in $n$. Instantiating the framework recovers, in one stroke, the strict log-convexity of the Catalan numbers ($\Delta = 6$), central binomial coefficients ($\Delta = 2$), and factorials ($\Delta = 1$); the log-linearity of the powers $2^n$ ($\Delta = 0$); and the strict log-concavity of the reciprocal factorials $1/n!$ ($\Delta = -1$). This refines a previously known dichotomy between two of these sequences into a genuine, sign-indexed trichotomy, and it explains the otherwise mysterious "constant coefficient gap" appearing in the direct Catalan discriminant identity as the shadow of the universal invariant $\Delta$.

**Keywords:** log-convexity, log-concavity, Möbius transformation, Catalan numbers, central binomial coefficients, factorials, P-recursive sequences, unimodality, combinatorial totals.

---

## 1. Introduction

Log-convexity and log-concavity are among the most useful structural properties a sequence of positive numbers can have. A positive sequence $(a_n)_{n\ge 0}$ is **log-concave** if $a_n a_{n+2} \le a_{n+1}^2$ for all $n$, and **log-convex** if the reverse inequality holds. Log-concavity implies unimodality and underlies a vast body of results in combinatorics, probability, and algebra; log-convexity is the natural counterpart for the fast-growing sequences of enumerative combinatorics, and is closely tied to positivity of moment sequences, Hankel determinants, and the Stieltjes moment problem.

Establishing one of these properties for a given sequence is typically done by an argument tailored to that sequence — often a delicate three-term identity or an asymptotic estimate. Our aim in this paper is to replace such case-by-case reasoning, for a large and classical family of sequences, by the evaluation of a single sign.

The family in question consists of sequences satisfying a **first-order multiplicative recurrence** with linear coefficients:
$$(\alpha n + \beta)\, a_{n+1} \;=\; (\gamma n + \delta)\, a_n, \qquad \alpha n + \beta > 0 \text{ for all } n. \tag{$\star$}$$
This is exactly the class of hypergeometric term sequences with linear-over-linear term ratio. It contains a remarkable number of the sequences one meets first: powers, factorials, binomial coefficients along the central column, and the Catalan numbers.

### 1.1 Motivating context: the $d$-Hoggatt totals

The investigation began with the *total* $d$-Hoggatt numbers $H_d(n) = \sum_k H_d(n,k)$, the row sums of a family of combinatorial triangles indexed by a parameter $d$. The first two members are classical:
$$H_1(n) = 2^n, \qquad H_2(n) = C_n \ \text{(the $n$-th Catalan number)}.$$
A prior result established a **sharp dichotomy**: $H_1(n) = 2^n$ is log-linear (geometric) and is *not* strictly log-convex, whereas $H_2(n) = C_n$ is strictly log-convex and is *not* log-concave. The proof of the Catalan side rested on an exact three-term identity
$$(2n+1)(n+3)\,C_n\,C_{n+2} = (n+2)(2n+3)\,C_{n+1}^2, \tag{1}$$
whose two polynomial coefficients differ by the positive constant $3$ — the source of strictness.

The present paper explains that dichotomy and completes it. We show that the "constant $3$" is not special to the Catalan numbers but is a normalized manifestation of a single invariant $\Delta$ attached to the recurrence $(\star)$, and that the sign of $\Delta$ governs a full **trichotomy**, with log-linearity ($\Delta = 0$) as the codimension-one boundary between the strictly log-convex ($\Delta > 0$) and strictly log-concave ($\Delta < 0$) regimes.

### 1.2 Main contribution

Our central definition is the following.

> **Definition (Möbius discriminant).** For a recurrence of the form $(\star)$ with coefficient vector $(\alpha,\beta,\gamma,\delta)$, the *Möbius discriminant* is
> $$\Delta = \gamma\beta - \alpha\delta.$$

Note that $\Delta$ is precisely the determinant $\det\begin{psmallmatrix}\gamma & \delta\\ \alpha & \beta\end{psmallmatrix}$ of the linear-fractional map governing the term ratio — hence the name. Our main result (Theorem 4.4) states that the sign of $\Delta$ determines the log-behavior of the sequence entirely and uniformly in $n$.

The rest of the paper is organized as follows. Section 2 fixes definitions and elementary exclusivity facts. Section 3 proves the ratio criterion that reduces log-behavior to monotonicity of consecutive ratios. Section 4 develops the Möbius engine — the ratio identity and the three regime theorems — culminating in the trichotomy. Section 5 works out the classical instances. Section 6 records the sharp trichotomy and its exclusivity. Sections 7–9 discuss applications, algorithms, and open problems.

---

## 2. Log-behavior predicates

Throughout, sequences are indexed by $\mathbb{N} = \{0,1,2,\dots\}$ and take values in $\mathbb{R}$.

> **Definition 2.1.** Let $a : \mathbb{N} \to \mathbb{R}$.
> - $a$ is **strictly log-convex** if $a_{n+1}^2 < a_n\,a_{n+2}$ for all $n$.
> - $a$ is **log-linear** if $a_{n+1}^2 = a_n\,a_{n+2}$ for all $n$.
> - $a$ is **strictly log-concave** if $a_n\,a_{n+2} < a_{n+1}^2$ for all $n$.

These three conditions are the trichotomy of the discrete second logarithmic difference. For positive sequences they are equivalent to the ratios $r_n = a_{n+1}/a_n$ being strictly increasing, constant, or strictly decreasing, respectively (Lemma 3.1). Log-linearity is exactly the statement that $a$ is a geometric progression.

The three predicates are pairwise incompatible in the following precise sense.

> **Proposition 2.2.** If $a$ is strictly log-convex then $a$ is neither log-linear nor strictly log-concave.

*Proof.* Evaluate at $n = 0$. Strict log-convexity gives $a_1^2 < a_0 a_2$. Log-linearity would give $a_1^2 = a_0 a_2$, contradicting the strict inequality; strict log-concavity would give $a_0 a_2 < a_1^2$, contradicting it by antisymmetry of $<$. $\qquad\blacksquare$

(Symmetric statements hold for strictly log-concave sequences. A single index of witness suffices because the definitions are universally quantified.)

---

## 3. The ratio criterion

The bridge from arithmetic (products of three terms) to the Möbius picture (monotonicity of ratios) is elementary but pivotal.

> **Lemma 3.1 (ratio criterion).** Let $a : \mathbb{N} \to \mathbb{R}$ be positive, i.e. $a_n > 0$ for all $n$. If the consecutive ratios are strictly increasing,
> $$\frac{a_{n+1}}{a_n} < \frac{a_{n+2}}{a_{n+1}} \quad \text{for all } n,$$
> then $a$ is strictly log-convex.

*Proof.* Fix $n$ and clear denominators in the hypothesis. Since $a_n > 0$ and $a_{n+1} > 0$, multiplying $a_{n+1}/a_n < a_{n+2}/a_{n+1}$ through by $a_n a_{n+1} > 0$ yields $a_{n+1}^2 < a_n a_{n+2}$, which is precisely strict log-convexity at $n$. $\qquad\blacksquare$

The corresponding statements for constant ratios (log-linearity) and strictly decreasing ratios (strict log-concavity) are proved identically by clearing denominators. This lemma isolates the "ratio amplification" mechanism: to control log-behavior, control the monotonicity of the ratio sequence $r_n = a_{n+1}/a_n$.

---

## 4. The Möbius engine

We now assume the recurrence $(\star)$ and compute the ratio sequence explicitly.

### 4.1 The ratio is a Möbius function of the index

> **Lemma 4.1 (ratio identity).** Suppose $a_n > 0$ for all $n$, that $\alpha n + \beta > 0$ for all $n$, and that $(\alpha n + \beta) a_{n+1} = (\gamma n + \delta) a_n$ for all $n$. Then
> $$\frac{a_{n+1}}{a_n} = \frac{\gamma n + \delta}{\alpha n + \beta} \quad \text{for all } n.$$

*Proof.* Both denominators $a_n$ and $\alpha n + \beta$ are nonzero (indeed positive), so the claimed equality of fractions is equivalent, after cross-multiplication, to $(\alpha n + \beta)\,a_{n+1} = (\gamma n + \delta)\,a_n$, which is the recurrence. $\qquad\blacksquare$

Thus the ratio sequence $r_n = a_{n+1}/a_n$ is the restriction to $\mathbb{N}$ of the **Möbius transformation** $t \mapsto (\gamma t + \delta)/(\alpha t + \beta)$.

### 4.2 The forward difference has constant numerator $\Delta$

The decisive computation is the forward difference of the Möbius function. For any real $n$ (with both denominators positive),
$$\frac{\gamma(n+1)+\delta}{\alpha(n+1)+\beta} - \frac{\gamma n + \delta}{\alpha n + \beta}
= \frac{(\gamma(n+1)+\delta)(\alpha n + \beta) - (\gamma n + \delta)(\alpha(n+1)+\beta)}{(\alpha(n+1)+\beta)(\alpha n + \beta)}.$$
Expanding the numerator, all $n$-dependent terms cancel, leaving exactly
$$\text{numerator} = \gamma\beta - \alpha\delta = \Delta.$$
The denominator $(\alpha(n+1)+\beta)(\alpha n + \beta)$ is a product of two positive quantities, hence positive. Therefore the sign of $r_{n+1} - r_n$ equals the sign of $\Delta$ **for every** $n$. This single, index-free computation is the engine behind all three regime theorems.

### 4.3 The three regime theorems

Combining Lemma 4.1, the difference computation of §4.2, and the ratio criterion (Lemma 3.1) yields:

> **Theorem 4.2 (log-convex regime).** Under $(\star)$ with $a_n > 0$ and $\alpha n + \beta > 0$, if $\Delta > 0$ (equivalently $\alpha\delta < \gamma\beta$) then $a$ is strictly log-convex.

*Proof.* By Lemma 4.1 the ratios are $r_n = (\gamma n + \delta)/(\alpha n + \beta)$. By §4.2, $r_{n+1} - r_n$ has the sign of $\Delta > 0$, so $r_n < r_{n+1}$ for all $n$; that is, the ratios are strictly increasing. Lemma 3.1 gives strict log-convexity. Concretely, the inequality $r_n < r_{n+1}$ is $\frac{\gamma n + \delta}{\alpha n + \beta} < \frac{\gamma(n+1)+\delta}{\alpha(n+1)+\beta}$, which cross-multiplies (both denominators positive) to a polynomial inequality whose net content is exactly $0 < \Delta$. $\qquad\blacksquare$

> **Theorem 4.3 (log-linear regime).** Under $(\star)$ with the same positivity, if $\Delta = 0$ (equivalently $\alpha\delta = \gamma\beta$) then $a$ is log-linear.

*Proof.* Now $r_{n+1} - r_n = 0$ for all $n$, so $r_n = r_{n+1}$; that is, $a_{n+1}/a_n = a_{n+2}/a_{n+1}$. Cross-multiplying by $a_n a_{n+1} > 0$ gives $a_{n+1}^2 = a_n a_{n+2}$. $\qquad\blacksquare$

> **Theorem 4.4 (log-concave regime).** Under $(\star)$ with the same positivity, if $\Delta < 0$ (equivalently $\gamma\beta < \alpha\delta$) then $a$ is strictly log-concave.

*Proof.* Symmetric to Theorem 4.2: $r_{n+1} - r_n$ has the sign of $\Delta < 0$, so the ratios are strictly decreasing, $a_{n+2}/a_{n+1} < a_{n+1}/a_n$; clearing denominators gives $a_n a_{n+2} < a_{n+1}^2$. $\qquad\blacksquare$

### 4.4 The trichotomy

The three regime theorems assemble into a single statement.

> **Theorem 4.5 (Möbius trichotomy).** Let $a : \mathbb{N} \to \mathbb{R}$ be positive and satisfy $(\star)$ with $\alpha n + \beta > 0$ for all $n$, and set $\Delta = \gamma\beta - \alpha\delta$. Then:
> $$\Delta > 0 \Rightarrow a \text{ strictly log-convex}, \quad \Delta = 0 \Rightarrow a \text{ log-linear}, \quad \Delta < 0 \Rightarrow a \text{ strictly log-concave}.$$
> These three conclusions are mutually exclusive (Proposition 2.2), so the sign of $\Delta$ determines the log-behavior of $a$ completely.

*Proof.* Immediate from Theorems 4.2–4.4, whose hypotheses are the three trichotomous cases of $\operatorname{sign}(\Delta)$. Exclusivity of the conclusions is Proposition 2.2. $\qquad\blacksquare$

**Remark (invariance and normalization).** The discriminant transforms predictably under rescaling of the recurrence. Multiplying both coefficient lines by a common positive factor, or the pair $(\gamma,\delta)$ and $(\alpha,\beta)$ by separate positive scalars $\lambda,\mu$, sends $\Delta \mapsto \lambda\mu\,\Delta$; the *sign* — and hence the log-behavior — is invariant. This is why the concrete "constant gap" one sees in a direct three-term identity such as (1) is only proportional to, not equal to, the intrinsic $\Delta$.

---

## 5. Classical instances

Each application of Theorem 4.5 requires only three ingredients: (i) positivity of $a$, (ii) the recurrence $(\star)$ cast over $\mathbb{R}$ with an explicit coefficient vector, and (iii) the numeric sign of $\Delta$.

### 5.1 Catalan numbers ($\Delta = 6$)

The Catalan numbers $C_n = \frac{1}{n+1}\binom{2n}{n}$ are positive and satisfy $(n+2)\,C_{n+1} = 2(2n+1)\,C_n = (4n+2)\,C_n$. Hence $(\alpha,\beta,\gamma,\delta) = (1,2,4,2)$ and
$$\Delta = \gamma\beta - \alpha\delta = 4\cdot 2 - 1\cdot 2 = 6 > 0.$$
By Theorem 4.5, $C_n$ is strictly log-convex: $C_{n+1}^2 < C_n C_{n+2}$ for all $n$. Comparing with the direct identity (1), the discriminant $\Delta = 6$ is exactly the origin of the "constant $3$" seen after normalization by the leading coefficient.

### 5.2 Central binomial coefficients ($\Delta = 2$)

The central binomial coefficients $\binom{2n}{n}$ are positive and satisfy $(n+1)\binom{2n+2}{n+1} = 2(2n+1)\binom{2n}{n}$, so $(\alpha,\beta,\gamma,\delta) = (1,1,4,2)$ and
$$\Delta = 4\cdot 1 - 1\cdot 2 = 2 > 0.$$
Hence $\binom{2n}{n}$ is strictly log-convex.

### 5.3 Factorials ($\Delta = 1$)

The factorials $n!$ are positive and satisfy $(n+1)! = (n+1)\,n!$, i.e. $1\cdot a_{n+1} = (n+1)\,a_n$, so $(\alpha,\beta,\gamma,\delta) = (0,1,1,1)$ and
$$\Delta = 1\cdot 1 - 0\cdot 1 = 1 > 0.$$
Hence $n!$ is strictly log-convex — a fact equivalent to strict convexity of $\log \Gamma$ restricted to the integers.

### 5.4 Powers of two ($\Delta = 0$)

The sequence $2^n$ is positive and satisfies $a_{n+1} = 2\,a_n$, so $(\alpha,\beta,\gamma,\delta) = (0,1,0,2)$ and
$$\Delta = 0\cdot 1 - 0\cdot 2 = 0.$$
Hence $2^n$ is log-linear: $\left(2^{n+1}\right)^2 = 2^n\cdot 2^{n+2}$. This is the boundary regime, and it recovers the $d = 1$ Hoggatt total.

### 5.5 Reciprocal factorials ($\Delta = -1$)

The sequence $1/n!$ is positive and satisfies $(n+1)\,a_{n+1} = a_n$, so $(\alpha,\beta,\gamma,\delta) = (1,1,0,1)$ and
$$\Delta = 0\cdot 1 - 1\cdot 1 = -1 < 0.$$
Hence $1/n!$ is strictly log-concave: $\tfrac{1}{n!}\cdot\tfrac{1}{(n+2)!} < \left(\tfrac{1}{(n+1)!}\right)^2$, equivalently $(n+1)^2 < (n+1)(n+2)$, which is transparently true and matches $\Delta < 0$.

---

## 6. The sharp trichotomy

Collecting the extreme representatives gives a single statement realizing all three regimes.

> **Theorem 6.1 (sharp trichotomy).** All three regimes are inhabited by classical sequences:
> - the Catalan numbers $C_n$ are strictly log-convex ($\Delta = 6$);
> - the powers $2^n$ are log-linear ($\Delta = 0$);
> - the reciprocal factorials $1/n!$ are strictly log-concave ($\Delta = -1$).

> **Corollary 6.2 (distinctness).** The three regimes are genuinely distinct: strict log-convexity of $C_n$ excludes both its log-linearity and its strict log-concavity.

Together, Theorem 6.1 and Corollary 6.2 upgrade the earlier $H_1$-vs-$H_2$ dichotomy (log-linear vs strictly log-convex) into a genuine sign-indexed trichotomy: log-linearity is not one of two alternatives but the exact codimension-one boundary $\{\Delta = 0\}$ separating the two open half-lines $\{\Delta > 0\}$ and $\{\Delta < 0\}$ in coefficient space.

---

## 7. Discussion and applications

**A uniform substitute for bespoke three-term identities.** The traditional route to log-convexity of a sequence like $C_n$ is to exhibit an exact identity such as (1) and read off a sign. Theorem 4.5 shows that any such identity, for a sequence in the class $(\star)$, is downstream of the single invariant $\Delta$. One no longer searches for a clever identity; one computes $\gamma\beta - \alpha\delta$.

**Strictness for free, from the first index.** Because the forward difference of the ratio has the *constant* numerator $\Delta$, the moment $\Delta \neq 0$ the monotonicity of ratios is strict and holds at every index with no exceptions — there is no "eventually," no threshold. This is stronger than an asymptotic statement and is exactly what is needed for consequences that are sensitive to the initial terms.

**Unimodality and moment-sequence structure.** Log-concavity implies unimodality, so Theorem 4.4 gives a one-line unimodality certificate for any $\Delta < 0$ sequence in the class. Dually, log-convexity of a positive sequence is a necessary condition for it to be a Stieltjes moment sequence (positive-definiteness of the associated Hankel forms begins with the $2\times 2$ minors $a_n a_{n+2} - a_{n+1}^2 \ge 0$); Theorem 4.2 supplies these leading minors' strict positivity uniformly.

**Explaining the Hoggatt dichotomy.** In the originating context, $H_1(n) = 2^n$ ($\Delta = 0$) and $H_2(n) = C_n$ ($\Delta = 6$) are two points on opposite sides of the boundary, which is why the earlier work found a sharp dichotomy rather than a coincidence.

---

## 8. Algorithms

The framework is constructive and yields simple, exact algorithms over the rationals.

**Algorithm A (classify by discriminant).** Given $(\alpha,\beta,\gamma,\delta)$ with $\alpha n + \beta > 0$ for the intended range, compute $\Delta = \gamma\beta - \alpha\delta$ and return `log-convex` / `log-linear` / `log-concave` according to $\operatorname{sign}(\Delta)$. Cost: $O(1)$ exact arithmetic operations.

**Algorithm B (certified ratio monotonicity).** Generate the exact rational ratios $r_n = (\gamma n + \delta)/(\alpha n + \beta)$ and the exact discrete curvatures $D_n = a_n a_{n+2} - a_{n+1}^2$ from the recurrence, verifying $\operatorname{sign}(D_n) = \operatorname{sign}(\Delta)$ for a prefix. This provides a finite, exact numerical witness to the theorem for any chosen sequence.

**Algorithm C (coefficient inference).** Given a candidate hypergeometric sequence, form the term ratio $a_{n+1}/a_n$ as a rational function of $n$, read off $(\alpha,\beta,\gamma,\delta)$ from its linear numerator and denominator, and apply Algorithm A. This recovers the coefficient vector for each classical example automatically.

---

## 9. Future work

The present results treat the first-order case exhaustively. Several natural extensions suggest themselves.

- **Quantitative discriminant law.** We conjecture that the discrete curvature $D_n = a_n a_{n+2} - a_{n+1}^2$ is not merely sign-constant but is an *exact positive multiple of $\Delta$* at every index, giving closed-form control of the second-order growth of every sequence in the class simultaneously.

- **Second-order (Turán) recurrences.** Many combinatorial totals (Motzkin, Baxter) satisfy a second-order recurrence $p(n)\,a_{n+2} = q(n)\,a_{n+1} + r(n)\,a_n$. We conjecture a discriminant *polynomial* $\Delta_2(n)$ built from $p,q,r$ whose eventual sign governs log-behavior and which reduces to $\gamma\beta - \alpha\delta$ when $r \equiv 0$.

- **Renormalization and infinite log-concavity.** Dividing a strictly log-convex total by its exact growth ratio $(\gamma n + \delta)/(\alpha n + \beta)$ yields a log-linear sequence; iterating a discriminant-based renormalization is a candidate route to infinite log-concavity of a residual sequence.

These directions are elaborated in the accompanying future-directions notes.

---

## Appendix: summary of the classical instances

| Sequence | Recurrence | $(\alpha,\beta,\gamma,\delta)$ | $\Delta$ | Regime |
|---|---|---|---|---|
| $2^n$ | $a_{n+1} = 2a_n$ | $(0,1,0,2)$ | $0$ | log-linear |
| $C_n$ (Catalan) | $(n+2)a_{n+1} = (4n+2)a_n$ | $(1,2,4,2)$ | $6$ | strictly log-convex |
| $\binom{2n}{n}$ | $(n+1)a_{n+1} = (4n+2)a_n$ | $(1,1,4,2)$ | $2$ | strictly log-convex |
| $n!$ | $a_{n+1} = (n+1)a_n$ | $(0,1,1,1)$ | $1$ | strictly log-convex |
| $1/n!$ | $(n+1)a_{n+1} = a_n$ | $(1,1,0,1)$ | $-1$ | strictly log-concave |
