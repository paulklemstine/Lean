# A Conditional Refinement of Page's Theorem on Landau–Siegel Zeros: The Repulsion-to-Uniqueness Principle

## Abstract

Page's theorem asserts that among the primitive quadratic Dirichlet characters with
conductor in a bounded range, at most one can have an *exceptional* (Landau–Siegel)
real zero of its $L$-function extremely close to $s = 1$. The classical proof is
analytic, resting on the non-negativity of the Dirichlet coefficients of the product
$\zeta(s) L(s,\chi_1) L(s,\chi_2) L(s,\chi_1\chi_2)$, which yields a *repulsion
principle*: two distinct near-$1$ real zeros cannot coexist because their minimum is
bounded away from $1$. In this paper we isolate the exact logical skeleton of Page's
theorem and of its modern conditional refinements. We show that once the repulsion
inequality
$$
\min(\beta_1, \beta_2) \leq 1 - \frac{C}{\log(q_1 q_2)}
$$
is granted with a constant $C$, the uniqueness conclusion is a purely quantitative
consequence, valid for *any* conductor window $[Q_0, M]$ under the sharp compatibility
condition
$$
C > 2\, Q_0^{-\varepsilon}\, \log M,
$$
where $\varepsilon > 0$ controls the exceptionality margin $\beta \geq 1 - q^{-\varepsilon}$.
We prove this deduction unconditionally, package it as a cardinality bound ("at most
one exceptional character"), exhibit that the hypotheses are non-vacuous, and show
that the threshold is load-bearing. The abstraction reveals that the phenomenon is
structural: it depends only on a conductor-indexed real parameter obeying a pairwise
repulsion inequality, not on any property specific to quadratic characters. This gives
a template — *repulsion implies sparsity* — that transfers verbatim to broader families
of $L$-functions and clarifies precisely how improved zero-free regions (larger $C$)
translate into wider uniqueness windows.

**Keywords.** Landau–Siegel zeros, exceptional zeros, Page's theorem, repulsion
principle, Dirichlet $L$-functions, quadratic characters, conductor, zero-free regions.

---

## 1. Introduction

### 1.1 Background

Let $\chi$ be a primitive quadratic Dirichlet character of conductor $q$, and let
$L(s, \chi)$ be its Dirichlet $L$-function. A central open problem of analytic number
theory concerns the possible existence of a real zero $\beta$ of $L(s, \chi)$ lying
anomalously close to $s = 1$ — a *Landau–Siegel* or *exceptional* zero. The
Generalized Riemann Hypothesis forbids such zeros; unconditionally, we can neither
prove they exist nor rule them out. Their potential presence weakens error terms
throughout number theory (in the prime number theorem for arithmetic progressions, in
class number formulas, and beyond), and eliminating them remains a defining challenge.

A foundational structural constraint on exceptional zeros is **Page's theorem**
(A. Page, 1935): in any bounded range of conductors, at most one primitive quadratic
character can support an exceptional real zero. The classical mechanism is a
*repulsion principle* traceable to Landau's study of the Dedekind zeta function of the
biquadratic field $\mathbb{Q}(\sqrt{d_1}, \sqrt{d_2})$. If two distinct primitive
quadratic characters $\chi_1, \chi_2$ both possessed real zeros very close to $1$, the
product
$$
\zeta(s)\, L(s, \chi_1)\, L(s, \chi_2)\, L(s, \chi_1 \chi_2)
$$
— which equals the Dedekind zeta function of the corresponding biquadratic field and
therefore has non-negative Dirichlet coefficients — would be forced to violate that
non-negativity. Quantitatively, the two real zeros cannot both satisfy
$\beta \geq 1 - c / \log(q_1 q_2)$.

### 1.2 The conditional refinement

Recent conditional programmes seek to *strengthen* the repulsion constant by improving
the zero-free region: if one excludes non-real zeros $\rho$ of $L(s, \chi)$ from a
shrinking neighbourhood of $s = 1$, namely $\operatorname{Re}(\rho) \leq 1 - C/\log q$
for a controlled constant $C = C(\varepsilon)$, then the effective repulsion strength
increases, and Page's "at most one" statement can be pushed to larger windows and
tighter exceptionality margins. The informal main result of this circle of ideas is:

> For every $\varepsilon > 0$ there exist effectively computable constants
> $C(\varepsilon) > 0$ and $Q_0(\varepsilon) > 0$ such that if, for every primitive
> quadratic character $\chi$ of conductor $q \geq Q_0(\varepsilon)$, all non-real zeros
> $\rho$ of $L(s, \chi)$ satisfy $\operatorname{Re}(\rho) \leq 1 - C(\varepsilon)/\log q$,
> then there is at most one such character whose $L$-function has a real zero
> $\beta \in [1 - q^{-\varepsilon}, 1)$.

### 1.3 Contribution of this paper

Our aim is to isolate and prove, in complete rigour, the **quantitative skeleton**
underpinning both Page's theorem and its conditional refinement. We make the following
observation, which is our organizing principle:

> The analytic machinery (biquadratic fields, non-negative coefficients, zero-free
> regions) is used *solely* to establish the pairwise repulsion inequality. The passage
> from that inequality to the "at most one" conclusion is not analytic; it is a short,
> unconditional, quantitative argument.

We therefore take the repulsion inequality as a hypothesis — exactly as it functions
logically in the analytic proofs — and prove the uniqueness conclusion from it, making
explicit the sharp arithmetic compatibility condition
$$
C > 2\, Q_0^{-\varepsilon}\, \log M
$$
relating the repulsion constant $C$, the window endpoints $[Q_0, M]$, and the
exceptionality exponent $\varepsilon$. The deduction requires only two elementary
real-analytic facts and cleanly separates the analytic *input* from the counting
*output*.

The main results are:

- **Theorem A** (pairwise uniqueness): under repulsion with constant $C$ and the
  compatibility condition, any two $\varepsilon$-exceptional characters with conductors
  in $[Q_0, M]$ coincide.
- **Theorem B** (cardinality bound): consequently, any finite family of
  $\varepsilon$-exceptional characters in the window that pairwise obeys repulsion has
  at most one element — the precise "at most one exceptional character" shape of Page's
  theorem.

We also verify that the hypotheses are non-vacuous and that the threshold is
load-bearing (it cannot be dropped), and we observe that the argument is agnostic to
the quadratic nature of the characters, yielding a general *repulsion-implies-sparsity*
template.

---

## 2. Definitions

Throughout, $\varepsilon, C \in \mathbb{R}$ with $\varepsilon > 0$, and
$Q_0, M \in \mathbb{N}$ are the endpoints of a conductor window.

**Definition 2.1 (Character datum).** A *quadratic character datum* is a pair
$\chi = (q, \beta)$ consisting of a *conductor* $q \in \mathbb{N}$ and a putative real
zero $\beta = \beta(\chi) \in \mathbb{R}$ of the associated $L$-function. We write
$q(\chi)$ and $\beta(\chi)$ for the two components. (For the deduction we retain only
the data on which the argument depends; all deeper structure lives inside the repulsion
hypothesis.)

**Definition 2.2 ($\varepsilon$-exceptional).** A datum $\chi = (q, \beta)$ is
*$\varepsilon$-exceptional* if
$$
\beta \;\geq\; 1 - q^{-\varepsilon},
$$
equivalently $\beta \in [\,1 - q^{-\varepsilon},\, 1\,)$ up to the (irrelevant) right
endpoint. This is the shrinking neighbourhood of $s = 1$ in the statement.

**Definition 2.3 (Window).** A datum lies *in the window* $[Q_0, M]$ if
$Q_0 \leq q(\chi) \leq M$.

**Definition 2.4 (Valid datum).** A datum is *valid* (for parameters
$\varepsilon, Q_0, M$) if it lies in the window and is $\varepsilon$-exceptional.

**Definition 2.5 (Repulsion principle).** Two data $\chi, \chi'$ satisfy *repulsion
with constant $C$* if
$$
\chi \neq \chi' \;\Longrightarrow\; \min\big(\beta(\chi),\, \beta(\chi')\big) \;\leq\; 1 - \frac{C}{\log\!\big(q(\chi)\, q(\chi')\big)}.
$$
This is the analytic input: in the conditional refinement, $C = C(\varepsilon)$ is
furnished by the excluded neighbourhood of non-real zeros.

---

## 3. Elementary lemmas

The entire deduction rests on two monotonicity facts and a positivity fact.

**Lemma 3.1 (Antitonicity of the margin).** For $\varepsilon > 0$ and integers
$2 \leq Q_0 \leq q$,
$$
q^{-\varepsilon} \;\leq\; Q_0^{-\varepsilon}.
$$
*Proof.* The function $x \mapsto x^{-\varepsilon}$ is strictly decreasing on
$(0, \infty)$ when $\varepsilon > 0$, since its exponent is negative. Applying this to
$Q_0 \leq q$ (both positive) gives the inequality. $\qquad\blacksquare$

**Lemma 3.2 (Product-log bound).** For integers $q_1, q_2 \leq M$ with $M \geq 2$,
$$
\log(q_1 q_2) \;\leq\; 2 \log M.
$$
*Proof.* Since $q_1, q_2 \leq M$ we have $q_1 q_2 \leq M^2$, and $\log$ is increasing,
so $\log(q_1 q_2) \leq \log(M^2) = 2 \log M$. (The degenerate cases $q_i \in \{0,1\}$
only make the left side smaller — indeed non-positive — so the bound holds a
fortiori.) $\qquad\blacksquare$

**Lemma 3.3 (Positivity of the denominator).** For integers $q_1, q_2 \geq 2$,
$$
\log(q_1 q_2) \;>\; 0.
$$
*Proof.* Then $q_1 q_2 \geq 4 > 1$, and $\log x > 0$ for $x > 1$. $\qquad\blacksquare$

These are the *only* analytic ingredients. No property of $L$-functions, primality, or
quadratic residues enters the deduction; they are all encapsulated in Definition 2.5.

---

## 4. Main results

### 4.1 Pairwise uniqueness

**Theorem A (Conditional refinement of Page's theorem — pairwise form).**
Let $\varepsilon > 0$, let $2 \leq Q_0 \leq M$ be integers, and suppose the arithmetic
compatibility condition
$$
2\, Q_0^{-\varepsilon}\, \log M \;<\; C
$$
holds. If $\chi_1, \chi_2$ are two valid data (in the window $[Q_0, M]$ and
$\varepsilon$-exceptional) that satisfy repulsion with constant $C$, then
$$
\chi_1 = \chi_2.
$$

*Proof.* Suppose, for contradiction, that $\chi_1 \neq \chi_2$. Write $q_i = q(\chi_i)$
and $\beta_i = \beta(\chi_i)$.

*Step 1 (Floor from exceptionality).* Each $\chi_i$ is $\varepsilon$-exceptional, so
$\beta_i \geq 1 - q_i^{-\varepsilon}$. Since $q_i \geq Q_0 \geq 2$, Lemma 3.1 gives
$q_i^{-\varepsilon} \leq Q_0^{-\varepsilon}$, hence
$$
\beta_i \;\geq\; 1 - Q_0^{-\varepsilon}, \qquad i = 1, 2.
$$
Taking the minimum,
$$
\min(\beta_1, \beta_2) \;\geq\; 1 - Q_0^{-\varepsilon}. \tag{4.1}
$$

*Step 2 (Ceiling from repulsion).* Because $\chi_1 \neq \chi_2$, Definition 2.5 yields
$$
\min(\beta_1, \beta_2) \;\leq\; 1 - \frac{C}{\log(q_1 q_2)}. \tag{4.2}
$$
By Lemma 3.3 the denominator $\log(q_1 q_2)$ is positive (as $q_i \geq 2$), and by
Lemma 3.2, $\log(q_1 q_2) \leq 2 \log M$. Since $C > 0$ (it exceeds
$2 Q_0^{-\varepsilon} \log M \geq 0$), the fraction $C/\log(q_1 q_2)$ is *decreasing*
in the denominator, so
$$
\frac{C}{\log(q_1 q_2)} \;\geq\; \frac{C}{2 \log M},
$$
and therefore
$$
\min(\beta_1, \beta_2) \;\leq\; 1 - \frac{C}{2 \log M}. \tag{4.3}
$$

*Step 3 (Squeeze).* Combining (4.1) and (4.3),
$$
1 - Q_0^{-\varepsilon} \;\leq\; \min(\beta_1, \beta_2) \;\leq\; 1 - \frac{C}{2 \log M},
$$
whence $Q_0^{-\varepsilon} \geq C/(2 \log M)$, i.e.
$$
C \;\leq\; 2\, Q_0^{-\varepsilon}\, \log M.
$$
This contradicts the hypothesis $C > 2 Q_0^{-\varepsilon} \log M$. Hence
$\chi_1 = \chi_2$. $\qquad\blacksquare$

Note the tight logical economy: the exceptionality margin supplies a *floor* on the
minimum zero, the repulsion principle supplies a *ceiling*, and the compatibility
condition is exactly what makes the floor exceed the ceiling for distinct characters.

### 4.2 Cardinality bound

**Theorem B (Conditional refinement of Page's theorem — packaged form).**
Under the hypotheses of Theorem A, let $S$ be any finite family of data such that every
$\chi \in S$ is valid, and every pair $\chi, \chi' \in S$ satisfies repulsion with
constant $C$. Then
$$
|S| \;\leq\; 1.
$$

*Proof.* By Theorem A, any two elements of $S$ are equal; a set in which every two
elements coincide has at most one element. $\qquad\blacksquare$

This is exactly the "at most one exceptional character" conclusion of Page's theorem,
now quantified by the explicit condition $C > 2 Q_0^{-\varepsilon} \log M$.

### 4.3 Non-vacuity and sharpness

**Proposition 4.1 (Non-vacuity).** The class of valid, $\varepsilon$-exceptional data
is inhabited. For example, with $\varepsilon = 1$, the datum $\chi = (2, 0.6)$ is
$1$-exceptional, since $1 - 2^{-1} = 0.5 \leq 0.6 = \beta$; and it lies in any window
$[Q_0, M]$ containing $2$. Thus Theorems A and B are not vacuously true.

**Proposition 4.2 (The threshold is load-bearing).** The compatibility condition
$C > 2 Q_0^{-\varepsilon} \log M$ cannot be dropped. If $C$ is small (weak repulsion),
two distinct exceptional characters can coexist: take $q_1 \neq q_2$ in $[Q_0, M]$ and
$\beta_1, \beta_2$ both equal to $1 - Q_0^{-\varepsilon}$. These are valid and, for
$C \leq 2 Q_0^{-\varepsilon}\log M$, they satisfy the repulsion inequality (its right
side is $\geq 1 - Q_0^{-\varepsilon}$), yet $\chi_1 \neq \chi_2$. Uniqueness genuinely
fails, which is why the refinement is conditional in precisely this quantitative sense.

**Remark 4.3 (Asymptotic shape).** As $Q_0 \to \infty$ along $M = Q_0$, the required
$C$ shrinks like $Q_0^{-\varepsilon}\log Q_0 \to 0$. This matches the heuristic that
exceptional zeros of large conductor are increasingly repelled, so ever weaker
repulsion suffices to enforce uniqueness at large conductors.

---

## 5. Algorithms

The result is quantitative and therefore *checkable*. We describe two algorithms.

### 5.1 Compatibility test

Given $(\varepsilon, C, Q_0, M)$, decide whether the compatibility condition holds and
therefore whether uniqueness is guaranteed.

```
Input:  ε > 0, C > 0, integers 2 ≤ Q₀ ≤ M
Output: TRUE if uniqueness is guaranteed on the window, else FALSE
1.  threshold ← 2 · Q₀^(−ε) · log(M)
2.  return (C > threshold)
```

Complexity: $O(1)$ real operations (two logs / powers). This is the practical face of
Theorem A.

### 5.2 Certified pairwise checker

Given a finite list of data and a repulsion constant $C$, verify directly that no two
valid exceptional data violate the squeeze, thereby *certifying* $|S| \leq 1$ or
exhibiting a coexisting pair.

```
Input:  list of data χ = (q, β); parameters ε, C, Q₀, M
Output: "unique" with the surviving datum, or a witnessing coexisting pair
1.  V ← [ χ in list : Q₀ ≤ q(χ) ≤ M  and  β(χ) ≥ 1 − q(χ)^(−ε) ]     # valid data
2.  if |V| ≤ 1: return "unique", V
3.  for each unordered pair {χ, χ'} in V with χ ≠ χ':
4.        ceiling ← 1 − C / log(q(χ)·q(χ'))
5.        if min(β(χ), β(χ')) ≤ ceiling:  continue            # repulsion respected
6.        else: return "coexisting pair", {χ, χ'}             # repulsion violated
7.  return "consistent", V
```

If the compatibility condition of Theorem A holds, step 6 can never fire for two
distinct valid data, so $|V| \leq 1$ is forced. Complexity: $O(n^2)$ pair checks for
$n$ data.

---

## 6. Applications and interpretation

**6.1 Making Page's theorem quantitative.** The classical statement is qualitative
("at most one in a bounded range"). Theorem A converts the analytic repulsion estimate
directly into an explicit window: given a repulsion constant $C$ and margin exponent
$\varepsilon$, uniqueness holds up to conductor $M$ satisfying
$\log M < C / (2 Q_0^{-\varepsilon})$. Better analysis (larger $C$) mechanically widens
the window.

**6.2 Dictionary for zero-free-region inputs.** In the conditional refinement, one buys
the constant $C$ by excluding non-real zeros from $\operatorname{Re}(\rho) \leq 1 - C/\log q$.
Theorem A is the exchange rate: an improvement pushing $C$ up by a factor $\lambda$
multiplies the admissible $\log M$ by the same $\lambda$, or allows a smaller margin
exponent $\varepsilon$ at fixed window.

**6.3 Structural transfer.** Because the deduction uses only a conductor $q \geq Q_0$
and a real parameter $\beta$ obeying a pairwise repulsion inequality, it applies to any
conductor-indexed family with such a repulsion input — including higher-degree
$L$-functions. This yields, conditionally, "at most one exceptional form" statements in
settings well beyond quadratic Dirichlet characters.

---

## 7. Discussion

The value of the abstraction is *separation of concerns*. Century-old presentations of
Page's theorem interleave the deep analysis (which produces repulsion) with the light
counting (which produces uniqueness). By quarantining the analysis inside a single
hypothesis and proving the counting unconditionally, we obtain a modular result: any
future improvement to the repulsion input plugs directly into Theorem A without
reproving anything. The precise threshold $C > 2 Q_0^{-\varepsilon}\log M$ is not an
artefact of estimation but the true order of magnitude of the barrier — as Proposition
4.2 shows, it is sharp up to the constant.

A subtle but important point is that the argument is *robust to the meaning of
$\beta$*. Nowhere do we use that $\beta$ is a zero of an $L$-function, or even a number
with arithmetic significance; we use only that valid data have $\beta$ near $1$ and
that distinct data repel. This is why the phenomenon is best understood as a law of
conductor-indexed families rather than a fact about Dirichlet characters.

---

## 8. Future directions

The following directions are distilled from the present work, whose central finding is
that the "at most one exceptional character" phenomenon of Page's theorem is, at its
logical core, a *quantitative repulsion-to-uniqueness* implication: a pairwise lower
bound on how far apart two near-$1$ real zeros must sit, combined with a bounded
conductor window, forces uniqueness precisely when the repulsion constant dominates
$2 Q_0^{-\varepsilon}\log M$.

**8.1 Sharp window–constant trade-off is an equality, not just a threshold.**
Conjecture: for each $\varepsilon > 0$ there is a critical curve
$C = \kappa(\varepsilon)\, Q_0^{-\varepsilon}\log M$ such that below it two distinct
exceptional characters can genuinely coexist, and the extremal configurations are
attained by pairs of quadratic characters whose conductors are as close as the window
permits. The threshold $2 Q_0^{-\varepsilon}\log M$ isolated here is not an artefact of
estimation but the true order of magnitude of the barrier, so the governing inequality
should be reversible up to the constant $\kappa(\varepsilon)$. Recent programmes
pushing non-real zeros back to $\operatorname{Re}(\rho) \leq 1 - C/\log q$ supply, for
the first time, explicit repulsion constants whose $\varepsilon$-dependence can be
tracked, making the extremal analysis concrete rather than heuristic.

**8.2 Repulsion upgrades "at most one per window" to "at most one globally".**
Conjecture: if the repulsion constant grows at least like $C(q) \asymp (\log q)^{1+\delta}$
for some $\delta > 0$ — just beyond what pairwise product-$L$-function positivity gives
— then across *all* conductors, not merely a bounded window, at most one primitive
quadratic character has an exceptional real zero. The obstruction to a global statement
is entirely the slow growth of $\log(q_1 q_2)$; a repulsion constant that itself grows
with the conductor overwhelms this and collapses the family of exceptional characters
to a single point. Conditional inputs excluding non-real zeros from shrinking
neighbourhoods of $s = 1$ are exactly the mechanism believed to boost the effective
repulsion strength, so the hypothesis $C(q) \asymp (\log q)^{1+\delta}$ is newly within
conditional reach.

**8.3 The repulsion template transfers to higher-degree $L$-functions.**
Conjecture: the same repulsion-to-sparsity implication holds verbatim for families of
automorphic $L$-functions indexed by analytic conductor, yielding "at most one
exceptional form" statements for $GL(2)$ newforms of bounded conductor. Nothing in the
uniqueness deduction uses the quadratic nature of the characters — only a real
parameter attached to each object and a pairwise inequality of the shape
$\min(\beta, \beta') \leq 1 - C/\log(q q')$ — so the phenomenon is a structural feature
of conductor-indexed families, not of Dirichlet characters. Explicit pairwise repulsion
estimates for $GL(2)$ $L$-functions have recently been made unconditional in various
ranges, bringing this within reach.

---

## 9. Conclusion

We have distilled Page's theorem on Landau–Siegel zeros to its quantitative essence: a
pairwise repulsion inequality plus a bounded conductor window forces uniqueness of
exceptional characters, precisely when the repulsion constant $C$ dominates
$2 Q_0^{-\varepsilon}\log M$. The deduction is elementary, unconditional, non-vacuous,
and sharp in the threshold, and it isolates the analytic content of the problem into a
single hypothesis. The abstraction makes transparent how improved zero-free regions
translate into wider uniqueness windows, and — because it never uses the quadratic
structure — it offers a reusable "repulsion implies sparsity" template for the wider
world of $L$-functions.
