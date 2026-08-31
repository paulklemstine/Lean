# The Multiplicative Law of the Tokenizer Tax

### Dilation budgets, characters of the fragmentation group, and the non-separability of multilingual key-cache budget tables

**Author:** Aristotle
**Date:** 2026-08-31

---

## Abstract

Bounded key-value caches force a deployment question: how many attention keys must be
retained so that a fixed fraction $\tau$ of the attention mass survives? We show that for
multilingual workloads the answer is governed by a rigid algebraic law, and that the
additive "tokenizer tax" — the extra keys a more finely-tokenized language demands — is
not an additive quantity at all.

We begin from a two-parameter power-law recall model, $\mathrm{deficit}(k) = A k^{-a}$,
whose gate we solve exactly: the retention bar $\tau$ is met if and only if
$k \ge (A/(1-\tau))^{1/a}$, an equivalence and not a bound. Writing the deficit amplitude
as $A = A_0(\lambda C)^b$, where $C$ is the context length and $\lambda$ the fragmentation
ratio of the language relative to a reference, we prove that the budget functional is
homogeneous of degree $1/a$ in the amplitude, so that the language knob acts by
multiplication with an *amplification factor* $\chi(\lambda) = \lambda^{b/a}$ that is
independent of the bar $\tau$, of the intrinsic difficulty $A_0$, and of the context
length, and is a character of the multiplicative group of fragmentation ratios.

The consequence is the **multiplicative law**: the additive tax
$T(\lambda,C) = (\chi(\lambda)-1)\mathcal{B}(1,C)$ is a fixed multiple of the baseline
requirement, so between any two context lengths the tax is amplified by exactly the factor
by which the baseline accelerates. The observed transition from a $+4$-key tax at short
context to a $\ge +16$-key tax at context $4096$ is therefore the already-measured
$4\times$ baseline acceleration, and not an independent parameter. Two competing
hypotheses — that the tax dissolves at long context, and that it persists as a constant
additive offset — are refuted: the tax is unbounded in $C$, and it is constant across two
contexts if and only if the language is free or the baseline does not move.

We then prove a rigidity theorem with direct engineering content: no separable budget table
exists. If $\mathcal{B}(\lambda,C) = f(C) + g(\lambda)$ for all positive $\lambda, C$, then
$\chi(\lambda)=1$; for any genuinely fragmenting language no such decomposition exists. A
fine-step layer shows that grid quantization cannot absorb the growth. Finally we abstract
the entire development into the notion of a **dilation budget** — a positive budget
function with a multiplicative response to context dilation — and prove that the response
factor is *forced* to be a character, that the multiplicative law holds in every such
model, and that a continuum Zipf attention profile, whose retention curve
$(k/C)^{1-s}$ is computed from exact mass integrals rather than postulated, is a second,
parameter-disjoint model of the same structure. The law is structural; the exponent $b/a$
is the measurable content. Two parameter-free falsifiable predictions follow.

**Keywords:** tokenizer tax, key-value cache, recall deficit, power law, character,
dilation budget, Zipf profile, budget separability, multilingual inference.

---

## 1. Introduction

### 1.1 The deployment setting

A transformer language model attends over its full context, but a deployed system rarely
stores the full attention state. Bounded key-value caches, sparse-attention schedulers, and
retrieval-augmented pipelines all implement the same primitive: retain the $k$ most
important key positions and drop the rest. The engineering question is how large $k$ must
be so that quality is preserved, and the standard operationalization is a **retention
gate**: the retained fraction of attention mass must reach a bar $\tau$, typically
$\tau = 0.98$.

Two knobs move the answer. The first is the **context length** $C$: as the context grows,
attention mass spreads over more positions and a fixed top-$k$ slice recovers relatively
less. The second is the **language**. A tokenizer trained predominantly on English assigns
single tokens to common English words and fragments other languages more finely. Fixing a
reference language, a target language has a **fragmentation ratio** $\lambda > 1$: it
spends $\lambda$ tokens per unit of reference content. From the point of view of the
attention mechanism, a document in the target language at context $C$ presents the same
workload as reference-language material at context $\lambda C$. This is the *exchange
principle* that drives everything below.

### 1.2 The measurement

A fixed retrieval harness was applied to German prose at $C = 4096$, with an exact gate and
three held-out windows, sweeping the key budget:

| $k$ | 24 | 32 | 40 | 48 | 56 |
|---|---|---|---|---|---|
| retained | $0.953$ | $0.966$ | $0.973$ | $0.975$ | $0.976$ |

All five points fail the $0.98$ bar; even $k = 56$ retains only $0.976$. At short contexts
the same harness had established a modest tokenizer penalty of about **four extra keys**
relative to the reference language. At $4096$ that penalty is at least $+16$ — a $4\times$
amplification which coincides exactly with the measured acceleration of the baseline
requirement over the same range of contexts.

Three hypotheses were pre-registered.

- **P1 (compounding).** The tokenizer tax compounds with the context-length acceleration.
- **P2 (dissolution).** At long context everything is expensive and language differences
  wash out.
- **P3 (persistence).** The tax stays at a fixed additive offset, so budget tables need
  only a constant per-language column.

P1 is confirmed; P2 and P3 are refuted. The purpose of this paper is to replace the table
of measurements by an algebraic account in which the confirmation and the two refutations
are theorems, the observed $4\times$ coincidence is an identity, and the residual empirical
content is isolated in a single exponent.

### 1.3 Contributions

1. An **exact gate theorem** for the power-law recall model: the budget functional
   $\mathcal{B}(A,a,\tau) = (A/(1-\tau))^{1/a}$ is the precise threshold of the retention
   gate, an equivalence rather than an inequality (Theorem 3.1).
2. **Homogeneity and the character property**: the budget is homogeneous of degree $1/a$
   in the amplitude, whence the language amplification $\chi(\lambda) = \lambda^{b/a}$ is a
   monoid homomorphism, independent of $\tau$ and of the intrinsic difficulty
   (Theorems 4.1–4.4).
3. **The multiplicative law** $T(\lambda,C_2)\mathcal{B}(1,C_1) = T(\lambda,C_1)\mathcal{B}(1,C_2)$,
   with the $+4 \mapsto +16$ instance as a corollary, and the refutations of P2 and P3
   (Theorems 5.2–5.6).
4. **Super-linear response** from the measured sub-linear recall exponent: the two anchor
   points of the German table alone force $a < 1$, and $a<1$ forces the budget to respond
   super-linearly to any hardening of the workload (Theorems 6.1–6.3).
5. **Rigidity of budget tables**: the exchange symmetry, the affine log-law with a single
   shared slope, the non-existence of an additive $f(C)+g(\lambda)$ table, and the failure
   of grid quantization to absorb the growth (Section 7).
6. **Model independence**: the abstract notion of a dilation budget, the derivation (not
   assumption) of multiplicativity of its response factor, the transfer of every result to
   that setting, and a second, parameter-disjoint model built from continuum Zipf mass
   integrals (Section 8).
7. **Two parameter-free predictions** for the next experimental cells (Section 9).

---

## 2. The recall model

Throughout, $k > 0$ denotes a real key budget, $C > 0$ a context length, $\tau < 1$ a
retention bar, and all parameters are real.

**Definition 2.1 (recall deficit and retained fraction).** For an amplitude $A$ and an
exponent $a$, the *recall deficit* at key budget $k$ is
$$\mathrm{deficit}(A,a,k) = A\,k^{-a},$$
and the *retained fraction* is $\mathrm{retained}(A,a,k) = 1 - \mathrm{deficit}(A,a,k)$.

This is the two-parameter family whose log–log fit to the German table gives
$a \approx 0.810$, $A \approx 0.582$, with residuals below $0.004$ at all five measured
points.

**Definition 2.2 (budget functional).** For $A > 0$, $a>0$, $\tau<1$,
$$\mathcal{B}(A,a,\tau) = \Big(\frac{A}{1-\tau}\Big)^{1/a}.$$

**Definition 2.3 (amplitude, fragmentation ratio).** For a base difficulty $A_0$, a
context exponent $b$, a fragmentation ratio $\lambda$ and a context length $C$,
$$\mathcal{A}(A_0,b,\lambda,C) = A_0\,(\lambda C)^{b}.$$
We abbreviate $\mathcal{B}(\lambda,C) := \mathcal{B}(\mathcal{A}(A_0,b,\lambda,C),a,\tau)$
when $A_0,b,a,\tau$ are fixed, and call $\mathcal{B}(1,C)$ the **baseline**.

**Definition 2.4 (amplification factor).** $\chi(\lambda) = \lambda^{\,b/a}$.

**Definition 2.5 (tokenizer tax).**
$$T(\lambda,C) = \mathcal{B}(\lambda,C) - \mathcal{B}(1,C),$$
the number of extra keys the target language demands over the reference at context $C$.

**Elementary facts.** For $A>0$ and $k>0$ the deficit is positive; for $A>0, a>0$ it is
strictly decreasing in $k$, hence the retained fraction is strictly increasing in $k$
(spending keys always helps). For $A>0$ and $\tau<1$ the budget is positive.

---

## 3. The gate is exact

**Theorem 3.1 (exact gate).** *Let $A>0$, $a>0$, $\tau<1$, $k>0$. Then*
$$\tau \le \mathrm{retained}(A,a,k) \iff \mathcal{B}(A,a,\tau) \le k .$$

*Proof sketch.* Since $\tau<1$ we have $1-\tau>0$, and $k^{a}>0$. The gate
$\tau \le 1 - Ak^{-a}$ is equivalent to $A k^{-a} \le 1-\tau$, i.e. to
$A/(1-\tau) \le k^{a}$ after clearing the positive denominators. The map $x \mapsto x^{1/a}$
is a strictly increasing bijection of the positive reals with inverse $x \mapsto x^{a}$
(here $a>0$ is used), so this is equivalent to $(A/(1-\tau))^{1/a} \le k$. $\square$

The equivalence is what makes the budget functional a legitimate object of study: it is the
threshold, so every statement about budgets is a statement about the gate, with no slack.

Two immediate consequences organize the experimental table.

**Corollary 3.2 (one failure certifies all).** *If $A>0$, $a>0$ and
$\mathrm{retained}(A,a,56) < 0.98$, then $\mathrm{retained}(A,a,k)<0.98$ for every
$0 < k \le 56$.*

*Proof sketch.* Strict monotonicity of the retained fraction in $k$: for $k<56$,
$\mathrm{retained}(k) < \mathrm{retained}(56) < 0.98$; for $k=56$ it is the hypothesis.
$\square$

Thus the five failing measurements are not five independent facts. The German sweep
contains exactly one datum — failure at the largest budget tried — and monotonicity does
the rest.

**Corollary 3.3 (the budget was never reached).** *Under the same hypotheses,
$56 < \mathcal{B}(A,a,0.98)$.*

*Proof sketch.* If $\mathcal{B}(A,a,0.98) \le 56$, Theorem 3.1 with $k=56$ gives
$0.98 \le \mathrm{retained}(A,a,56)$, contradicting the hypothesis. $\square$

With the fitted constants $A \approx 0.582$, $a \approx 0.810$ the budget at $\tau=0.98$ is
approximately $64$ keys; the sweep stopped at $56$ and could not have succeeded.

---

## 4. Homogeneity and the character property

The structural heart of the matter is that the two experimental knobs enter only through
the amplitude, and the budget responds to the amplitude by a power.

**Theorem 4.1 (homogeneity).** *For $A \ge 0$, $c \ge 0$, $\tau<1$,*
$$\mathcal{B}(cA,a,\tau) = c^{1/a}\,\mathcal{B}(A,a,\tau).$$

*Proof sketch.* $(cA/(1-\tau))^{1/a} = (c \cdot A/(1-\tau))^{1/a} = c^{1/a}(A/(1-\tau))^{1/a}$,
using that the power function is multiplicative on non-negative arguments. $\square$

**Theorem 4.2 (baseline form).** *For $A_0 \ge 0$, $\tau<1$, $C \ge 0$,*
$$\mathcal{B}(1,C) = \Big(\frac{A_0}{1-\tau}\Big)^{1/a} C^{\,b/a}.$$

*Proof sketch.* The amplitude at $\lambda = 1$ is $A_0 C^{b}$; apply homogeneity with
$c = C^{b}$ and use $(C^{b})^{1/a} = C^{b/a}$. $\square$

**Theorem 4.3 (the language knob multiplies).** *For $A_0 \ge 0$, $\tau<1$, $\lambda \ge 0$,
$C\ge 0$,*
$$\mathcal{B}(\lambda,C) = \chi(\lambda)\,\mathcal{B}(1,C), \qquad \chi(\lambda)=\lambda^{b/a}.$$

*Proof sketch.* $\mathcal{A}(A_0,b,\lambda,C) = \lambda^{b}\,\mathcal{A}(A_0,b,1,C)$; apply
homogeneity with $c=\lambda^{b}$ and simplify $(\lambda^{b})^{1/a} = \lambda^{b/a}$.
$\square$

**Theorem 4.4 (the tax is a character).** *The map $x \mapsto x^{\,b/a}$ is a monoid
homomorphism of the non-negative reals under multiplication: $\chi(1)=1$ and
$\chi(\lambda_1\lambda_2) = \chi(\lambda_1)\chi(\lambda_2)$ for $\lambda_1,\lambda_2\ge0$.
Moreover, if $a>0$, $b>0$ and $\lambda>1$ then $\chi(\lambda)>1$.*

*Proof sketch.* Multiplicativity and normalization are the corresponding properties of real
powers; strict inequality for $\lambda>1$ follows because $b/a>0$ and $x\mapsto \lambda^{x}$
is strictly increasing for base $\lambda>1$. $\square$

Composing tokenizer shifts therefore multiplies their costs — the tax lives in a
multiplicative, not an additive, world.

**Theorem 4.5 (universality of the amplification).** *For $A,B \ge 0$, $\lambda \ge 0$ and
bars $\tau_1,\tau_2 < 1$,*
$$\mathcal{B}(\lambda^{b}A,a,\tau_1)\,\mathcal{B}(B,a,\tau_2) = \mathcal{B}(A,a,\tau_1)\,\mathcal{B}(\lambda^{b}B,a,\tau_2).$$

*Proof sketch.* Apply homogeneity to both sides; each side equals
$\lambda^{b/a}\mathcal{B}(A,a,\tau_1)\mathcal{B}(B,a,\tau_2)$. $\square$

The interpretation is important for experimental design: the amplification factor does not
depend on which bar you gate at, nor on the intrinsic difficulty of the workload. Two labs
using different retention bars, different corpora, and different base difficulties will
measure the *same* $\chi(\lambda)$.

---

## 5. The multiplicative law

**Theorem 5.1 (tax as a multiple of the baseline).** *For $A_0 \ge 0$, $\tau<1$,
$\lambda \ge 0$, $C \ge 0$,*
$$T(\lambda,C) = \big(\chi(\lambda) - 1\big)\,\mathcal{B}(1,C).$$

*Proof sketch.* Substitute Theorem 4.3 into Definition 2.5 and factor. $\square$

This one line contains all the phenomenology.

**Theorem 5.2 (the multiplicative law).** *For $A_0\ge0$, $\tau<1$, $\lambda\ge0$,
$C_1,C_2\ge0$,*
$$T(\lambda,C_2)\cdot\mathcal{B}(1,C_1) \;=\; T(\lambda,C_1)\cdot\mathcal{B}(1,C_2).$$

*Proof sketch.* By Theorem 5.1 both sides equal
$(\chi(\lambda)-1)\mathcal{B}(1,C_1)\mathcal{B}(1,C_2)$. $\square$

**Theorem 5.3 (acceleration form).** *If the baseline accelerates by a factor $\rho$, i.e.
$\mathcal{B}(1,C_2) = \rho\,\mathcal{B}(1,C_1)$, then $T(\lambda,C_2) = \rho\,T(\lambda,C_1)$.*

*Proof sketch.* Immediate from Theorem 5.1. $\square$

**Corollary 5.4 ($+4 \mapsto +16$).** *If the baseline quadruples between $C_1$ and $C_2$
and the short-context tax is $4$ keys, then the long-context tax is exactly $16$ keys.*

This is the headline transition as a derived statement. Nothing about German, about $4096$, or
about the particular tokenizer enters; only the measured baseline acceleration does.

The hypotheses of Corollary 5.4 are satisfiable, which rules out a vacuous reading. Taking
$A_0 = b = a = 1$, $\tau = 1/2$, $\lambda = 3$, $C_1 = 1$, $C_2 = 4$, one computes directly
that the baseline quadruples, $T(3,1) = 4$, and $T(3,4) = 16$.

**Theorem 5.5 (P2 refuted: the tax is unbounded).** *If $A_0>0$, $a>0$, $b>0$, $\tau<1$ and
$\lambda>1$, then for every $M \in \mathbb{R}$ there is a context length $C>0$ with
$T(\lambda,C) > M$.*

*Proof sketch.* By Theorems 4.4 and 5.1, $T(\lambda,C) = \kappa\,\mathcal{B}(1,C)$ with
$\kappa = \chi(\lambda)-1 > 0$, and by Theorem 4.2, $\mathcal{B}(1,C) = \beta\,C^{b/a}$ with
$\beta>0$. Since $b/a>0$, $C^{b/a} \to \infty$ as $C \to \infty$; choose $C$ large enough
that $\kappa\beta C^{b/a} > M$. $\square$

**Theorem 5.6 (P3 refuted: the tax is not constant).** *Under the same hypotheses there is
no $t \in \mathbb{R}$ with $T(\lambda,C) = t$ for all $C>0$.*

*Proof sketch.* Such a $t$ would bound the tax, contradicting Theorem 5.5 applied with
$M = t$. $\square$

The abstract version of Theorem 5.6, proved in Section 8, is an exact dichotomy: a
context-independent tax requires either a free language or a frozen baseline.

---

## 6. Sub-linearity and the explosion

Growth alone would justify the verdict "the tax grows". The stronger verdict — that it
*explodes* — comes from the measured exponent.

**Theorem 6.1 (the data force a sub-linear exponent).** *If $\mathrm{deficit}(A,a,24) = 0.047$
and $\mathrm{deficit}(A,a,56) = 0.024$, then $a<1$.*

*Proof sketch.* Dividing the two relations gives $(56/24)^{a} = 0.047/0.024$. Numerically
$56/24 \approx 2.333$ and $0.047/0.024 \approx 1.958$. If $a \ge 1$ then, since the base
exceeds $1$, $(56/24)^{a} \ge 56/24 > 0.047/0.024$, a contradiction. Hence $a<1$. $\square$

Note the structure: no fitting is required, only the two anchor points of the German sweep.
Keys buy strictly less than proportional recall.

**Theorem 6.2 (super-linear response).** *If $A>0$, $0<a<1$, $\tau<1$ and $c>1$, then*
$$\mathcal{B}(cA,a,\tau) > c\,\mathcal{B}(A,a,\tau).$$

*Proof sketch.* By homogeneity the left side is $c^{1/a}\mathcal{B}(A,a,\tau)$, and
$1/a>1$ with $c>1$ gives $c^{1/a} > c$; multiply by the positive budget. $\square$

So any multiplicative hardening of the workload — longer context, finer tokenization, a
stricter bar — is repaid at a strictly worse than linear rate. Specialized to the language
knob:

**Theorem 6.3 (the amplification exceeds the token-count penalty).** *If $0<a<1$, $b>0$ and
$\lambda>1$, then $\lambda^{b} < \chi(\lambda) = \lambda^{b/a}$.*

*Proof sketch.* Since $\lambda>1$ the map $x \mapsto \lambda^{x}$ is strictly increasing,
and $b < b/a$ because $0<a<1$ and $b>0$. $\square$

A naive accounting would charge a language exactly for the extra tokens it spends, i.e.
$\lambda^{b}$. The true charge is strictly larger. The tax compounds with itself, and the
compounding rate is $1/a$.

---

## 7. Rigidity: no budget table is separable

We now extract the deployment conclusion as theorems about the shape of any correct budget
table.

**Theorem 7.1 (language–context exchange symmetry).** *For all parameters,*
$$\mathcal{B}(\lambda, C) = \mathcal{B}(1, \lambda C).$$

*Proof sketch.* The amplitude depends on $\lambda$ and $C$ only through the product
$\lambda C$: $A_0(\lambda C)^{b} = A_0 (1 \cdot (\lambda C))^{b}$. $\square$

This is the formal content of the phrase "German at context $C$ is the reference language
at context $\lambda C$": the two knobs are not merely analogous, they are the *same* knob.

**Theorem 7.2 (affine log-law with a single slope).** *For $A_0>0$, $\tau<1$, $\lambda>0$,
$C>0$,*
$$\log \mathcal{B}(\lambda,C) = \frac1a\log\frac{A_0}{1-\tau} + \frac{b}{a}\log\lambda + \frac{b}{a}\log C .$$

*Proof sketch.* Take logarithms in Theorem 4.2 combined with Theorem 4.3, using
$\log(x^{p}) = p\log x$ for positive $x$ and $\log(xy)=\log x+\log y$ for positive $x,y$;
all factors are positive under the hypotheses. $\square$

Budgets are additive in log-space, with the *same* coefficient $b/a$ on the language and
context axes — the exchange symmetry made quantitative. This is the correct shape for a
budget table, and it is the only one:

**Theorem 7.3 (no additive budget table).** *Let $A_0>0$, $a>0$, $b>0$, $\tau<1$,
$\lambda>0$. Suppose there are functions $f,g$ with*
$$\mathcal{B}(l,C) = f(C) + g(l) \quad \text{for all } l>0,\ C>0 .$$
*Then $\chi(\lambda) = 1$.*

*Proof sketch.* Under separability the difference
$\mathcal{B}(\lambda,C)-\mathcal{B}(1,C) = g(\lambda)-g(1)$ is independent of $C$. But by
Theorem 5.1 that difference equals $(\chi(\lambda)-1)\mathcal{B}(1,C)$, and by Theorem 4.2
the baseline $\mathcal{B}(1,C) = \beta C^{b/a}$ takes at least two distinct positive values
as $C$ ranges over the positive reals (since $b/a > 0$ and $\beta>0$). Evaluating at two
such contexts $C_1 \ne C_2$ gives
$(\chi(\lambda)-1)\mathcal{B}(1,C_1) = (\chi(\lambda)-1)\mathcal{B}(1,C_2)$ with
$\mathcal{B}(1,C_1) \ne \mathcal{B}(1,C_2)$, forcing $\chi(\lambda)-1 = 0$. $\square$

**Corollary 7.4 (a genuine language has no table).** *If $A_0>0$, $a>0$, $b>0$, $\tau<1$
and $\lambda>1$, then there exist no functions $f,g$ with $\mathcal{B}(l,C)=f(C)+g(l)$ for
all positive $l,C$.*

*Proof sketch.* Such $f,g$ would give $\chi(\lambda)=1$ by Theorem 7.3, contradicting
$\chi(\lambda)>1$ from Theorem 4.4. $\square$

This is the sharpest possible statement of the engineering conclusion. The universal
practice of sizing caches from a table with a context row and a language column is not
merely inaccurate at the margins; the functional form it presupposes is *impossible*. Any
correct table must carry a language $\times$ context interaction term — or, equivalently,
be written in log-space where Theorem 7.2 makes it genuinely additive.

### 7.1 Quantization does not save you

Real allocators hand out cache in blocks. Could the coarseness of the grid absorb the
amplification? It cannot.

**Definition 7.5 (grid steps).** For a grid $g$ and a real demand $x$, the number of blocks
is $\mathrm{steps}(g,x) = \lceil x/g \rceil$. It is monotone in $x$ for $g>0$.

**Theorem 7.6 (quadrupling costs blocks).** *For all $g$ and $x$,*
$$4\,\mathrm{steps}(g,x) - 3 \;\le\; \mathrm{steps}(g,4x).$$

*Proof sketch.* Write $y = x/g$. Since $\lceil y\rceil < y+1$ we get
$4\lceil y\rceil < 4y+4 \le \lceil 4y \rceil + 4$, and both sides are integers, so
$4\lceil y \rceil \le \lceil 4y\rceil + 3$. Finally $4x/g = 4y$. $\square$

**Example 7.7.** On a grid of $4$: a real tax of $4$ costs one block, and a real tax of
$16$ costs four. The $4\times$ amplification passes through the quantizer intact.

**Theorem 7.8 (no finite block surcharge is safe).** *If $A_0>0$, $a>0$, $b>0$, $\tau<1$,
$\lambda>1$ and the grid $g>0$, then for every integer $N$ there is a context $C>0$ with
$N \le \mathrm{steps}(g, T(\lambda,C))$.*

*Proof sketch.* By Theorem 5.5 choose $C$ with $T(\lambda,C) > Ng$. Then
$T(\lambda,C)/g > N$, so its ceiling is at least $N$. $\square$

---

## 8. Model independence: dilation budgets

Everything above lives inside one two-parameter family. A critic may reasonably ask whether
the multiplicative law is an artifact of the power-law shape. It is not, and this section
isolates the single structural property responsible.

**Definition 8.1 (dilation budget).** A *dilation budget* consists of a budget function
$\mathcal{B}:\mathbb{R}\to\mathbb{R}$ of the context length and a response factor
$\chi:\mathbb{R}\to\mathbb{R}$ such that

- (positivity) $\mathcal{B}(C) > 0$ for all $C>0$;
- (dilation law) $\mathcal{B}(uC) = \chi(u)\,\mathcal{B}(C)$ for all $u>0$, $C>0$.

The *language tax* of a fragmentation ratio $\lambda$ is
$T(\lambda,C) = \mathcal{B}(\lambda C) - \mathcal{B}(C)$.

The definition assumes *nothing* about $\chi$ beyond its existence — in particular not
multiplicativity. Multiplicativity is a theorem.

**Theorem 8.2 (the response factor is normalized).** *In any dilation budget, $\chi(1)=1$.*

*Proof sketch.* The dilation law with $u=C=1$ gives $\mathcal{B}(1) = \chi(1)\mathcal{B}(1)$,
and $\mathcal{B}(1)>0$ may be cancelled. $\square$

**Theorem 8.3 (the response factor is forced to be a character).** *In any dilation budget,
for $u,v>0$,*
$$\chi(uv) = \chi(u)\,\chi(v).$$

*Proof sketch.* Compute $\mathcal{B}(u(v\cdot 1))$ in two ways. Applying the dilation law
twice gives $\chi(u)\chi(v)\mathcal{B}(1)$; applying it once to the dilation $uv$ gives
$\chi(uv)\mathcal{B}(1)$. Cancel the positive $\mathcal{B}(1)$. $\square$

The moral is that multiplicativity of the tokenizer tax is not a modelling choice; it is
associativity of dilation in disguise. Composing two fragmenting effects must multiply
their costs, because dilating by $u$ and then by $v$ is dilating by $uv$.

**Theorem 8.4 (tax as a multiple of the baseline, abstractly).** *For $\lambda>0$, $C>0$,*
$$T(\lambda,C) = \big(\chi(\lambda)-1\big)\,\mathcal{B}(C).$$

**Theorem 8.5 (the multiplicative law, structurally).** *In any dilation budget, for
$\lambda>0$ and $C_1,C_2>0$,*
$$T(\lambda,C_2)\,\mathcal{B}(C_1) = T(\lambda,C_1)\,\mathcal{B}(C_2),$$
*and if $\mathcal{B}(C_2) = \rho\,\mathcal{B}(C_1)$ then $T(\lambda,C_2)=\rho\,T(\lambda,C_1)$.*

*Proof sketch.* Both are immediate from Theorem 8.4; each side of the first identity equals
$(\chi(\lambda)-1)\mathcal{B}(C_1)\mathcal{B}(C_2)$. $\square$

**Theorem 8.6 (exact dichotomy for a constant tax; P3 has no room).** *In any dilation
budget, for $\lambda>0$ and $C_1,C_2>0$,*
$$T(\lambda,C_1) = T(\lambda,C_2) \iff \big(\chi(\lambda) = 1 \ \text{ or } \ \mathcal{B}(C_1)=\mathcal{B}(C_2)\big).$$

*Proof sketch.* By Theorem 8.4 the equation is
$(\chi(\lambda)-1)(\mathcal{B}(C_1)-\mathcal{B}(C_2)) = 0$, and a product of reals vanishes
iff a factor does. The converse direction is a substitution. $\square$

This is strictly stronger than Theorem 5.6: it says exactly when the "constant additive
offset" picture is available, namely only in the two degenerate cases of a free language or
a frozen baseline.

### 8.1 Model 1: the power-law recall model

**Proposition 8.7.** *For $A_0>0$ and $\tau<1$, the pair*
$$\mathcal{B}(C) = \Big(\frac{A_0}{1-\tau}\Big)^{1/a} C^{\,b/a}, \qquad \chi(u) = u^{\,b/a}$$
*is a dilation budget, and on non-negative contexts its budget function agrees with the
power-law budget at fragmentation ratio $1$; its response factor is exactly the
amplification factor $\chi$ of Definition 2.4.*

*Proof sketch.* Positivity is a product of positive powers. The dilation law is
$(uC)^{b/a} = u^{b/a}C^{b/a}$ for $u,C>0$. Agreement with $\mathcal{B}(1,C)$ is Theorem 4.2.
$\square$

### 8.2 Model 2: a continuum Zipf attention profile

We now exhibit a model built from different primitives, sharing no parameter with the
first, whose retention curve is *computed* rather than postulated.

Suppose attention mass over a context of length $C$ is described by the continuum density
$x \mapsto x^{-s}$ on $(0,C]$, with $s<1$ (needed for integrability at the origin).

**Theorem 8.8 (total mass).** *For $s<1$ and any $C$,*
$$\int_0^{C} x^{-s}\,dx = \frac{C^{\,1-s}}{1-s}.$$

*Proof sketch.* Antidifferentiate $x^{-s}$ to $x^{-s+1}/(-s+1)$, valid because
$-s > -1$; the boundary term at $0$ vanishes since $1-s>0$. $\square$

**Theorem 8.9 (the Zipf retention curve, derived).** *For $s<1$, $0<k$, $0<C$, the fraction
of attention mass recovered by the top $k$ positions is*
$$\frac{\int_0^{k} x^{-s}\,dx}{\int_0^{C} x^{-s}\,dx} = \Big(\frac{k}{C}\Big)^{1-s}.$$

*Proof sketch.* Substitute Theorem 8.8 in numerator and denominator; the factors $1/(1-s)$
cancel and $k^{1-s}/C^{1-s} = (k/C)^{1-s}$ by multiplicativity of powers on positives.
$\square$

**Definition 8.10 (Zipf budget).** $\mathcal{B}_{\mathrm{Z}}(C) = \tau^{1/(1-s)}\,C$.

**Theorem 8.11 (the Zipf gate is exact).** *For $s<1$, $\tau>0$, $k>0$, $C>0$,*
$$\tau \le \Big(\frac{k}{C}\Big)^{1-s} \iff \mathcal{B}_{\mathrm{Z}}(C) \le k .$$

*Proof sketch.* Raise both sides of the left inequality to the power $1/(1-s)>0$, a
strictly increasing operation on positives, to obtain $\tau^{1/(1-s)} \le k/C$, and clear
the positive $C$. The converse reverses the steps, raising to the power $1-s>0$. $\square$

**Theorem 8.12 (the Zipf model is a dilation budget).** *For $\tau>0$, the pair
$\mathcal{B}_{\mathrm{Z}}$, $\chi_{\mathrm{Z}}(u)=u$ is a dilation budget. Consequently, for
$\lambda>0$ and $C>0$,*
$$T_{\mathrm{Z}}(\lambda,C) = (\lambda-1)\,\mathcal{B}_{\mathrm{Z}}(C),$$
*and the multiplicative law of Theorem 8.5 holds: in particular a $4\times$ longer context
carries a $4\times$ larger tokenizer tax.*

*Proof sketch.* Positivity: $\tau^{1/(1-s)}>0$ and $C>0$. Dilation:
$\mathcal{B}_{\mathrm{Z}}(uC) = \tau^{1/(1-s)}uC = u\,\mathcal{B}_{\mathrm{Z}}(C)$. The
remaining claims are Theorems 8.4 and 8.5 specialized. $\square$

### 8.3 What is structural and what is measurable

The two models obey the same law but not with the same character. This separates the
untestable from the testable.

**Theorem 8.13 (the characters agree iff $b=a$).** *For $a>0$ and $\lambda>1$,*
$$\lambda^{\,b/a} = \lambda \iff b = a .$$

*Proof sketch.* Since $\lambda>1$, the map $x\mapsto\lambda^{x}$ is strictly increasing,
hence injective; $\lambda^{b/a} = \lambda^{1}$ forces $b/a = 1$, and with $a\ne0$ this is
$b=a$. The converse is immediate. $\square$

So the multiplicative law — the fact that the tax amplifies by exactly the baseline
acceleration — is common to every dilation budget and cannot distinguish models. The
*exponent* is where the empirical content sits. The observed datum, a $4\times$ amplification
at $C = 4096$, is a measurement of $b/a$ and of nothing else.

**Theorem 8.14 (monotonicity of the character).** *If $a>0$, $b>0$ and $0<\lambda_1<\lambda_2$
then $\chi(\lambda_1) < \chi(\lambda_2)$.*

*Proof sketch.* The map $x\mapsto x^{b/a}$ is strictly increasing on the non-negative reals
because $b/a>0$. $\square$

---

## 9. Two parameter-free predictions

Both of the following hold in *every* dilation budget, hence in both models, and neither
contains a fitted quantity. They are therefore clean falsification targets for the next
experimental cells (French at $4096$; more languages at $4096$; larger models).

**Prediction 1 (the language ratio is a context invariant).** *For fragmentation ratios
$\lambda_1,\lambda_2>0$ and contexts $C_1,C_2>0$,*
$$T(\lambda_1,C_1)\,T(\lambda_2,C_2) \;=\; T(\lambda_1,C_2)\,T(\lambda_2,C_1).$$

*Proof sketch.* By Theorem 8.4 both sides equal
$(\chi(\lambda_1)-1)(\chi(\lambda_2)-1)\mathcal{B}(C_1)\mathcal{B}(C_2)$. $\square$

Operationally: each language's tax diverges with context, but the *ratio* of two languages'
taxes is the same at every context length. Measuring French and German at two context
lengths tests this identity with no free parameter.

**Prediction 2 (rankings never cross).** *If $\chi(\lambda_1) \le \chi(\lambda_2)$ then
$T(\lambda_1,C) \le T(\lambda_2,C)$ for every $C>0$.*

*Proof sketch.* By Theorem 8.4 the difference of the taxes is
$(\chi(\lambda_2)-\chi(\lambda_1))\mathcal{B}(C) \ge 0$ since $\mathcal{B}(C)>0$. $\square$

In the power-law model Theorem 8.14 decides the hypothesis from the fragmentation ratios
alone: if $1 < \lambda_{\mathrm{fr}} < \lambda_{\mathrm{de}}$ then French must sit strictly
between the reference baseline and the German curve at *every* context, including $4096$.
An observed crossing would refute the dilation structure itself, not merely the exponent.

---

## 10. Algorithms

The theory yields three small, exact procedures which together replace the practice of
interpolating budget tables.

**Algorithm A (exact budget from a measured sweep).** Given measurements
$(k_i, r_i)_{i=1}^{n}$ of the retained fraction, fit the power-law recall model by ordinary
least squares in log–log space on the deficits $d_i = 1-r_i$: regressing $\log d_i$ on
$\log k_i$ returns a slope $-a$ and an intercept $\log A$. Then return
$\mathcal{B} = (A/(1-\tau))^{1/a}$. By Theorem 3.1 this is the exact gate threshold for the
fitted model, so the return value is a *requirement*, not an estimate of one. Cost
$O(n)$.

**Algorithm B (tax projection across contexts).** Given a tax $T_1$ measured at context
$C_1$ and the baseline requirements at $C_1$ and $C_2$, return
$T_2 = T_1\,\mathcal{B}(1,C_2)/\mathcal{B}(1,C_1)$. By Theorem 5.2 this is exact in any
dilation budget; the input is the baseline acceleration, which is a *reference-language*
measurement and hence already available. Cost $O(1)$. With $\rho=4$ and $T_1=4$ it returns
$16$.

**Algorithm C (interaction-aware budget table).** Rather than storing $f(C)+g(\lambda)$ —
which by Corollary 7.4 cannot exist — store the three log-space coefficients of Theorem 7.2
and evaluate
$\mathcal{B}(\lambda,C) = \exp\big(c_0 + \tfrac{b}{a}\log\lambda + \tfrac{b}{a}\log C\big)$,
then quantize with $\lceil \cdot / g\rceil$. Theorems 7.6 and 7.8 guarantee that the
quantized table inherits the amplification. Cost $O(1)$ per lookup and $O(1)$ storage per
language.

---

## 11. Discussion

### 11.1 What the experiment actually measured

The strongest reading of the measured cell is negative: the sweep never reached the budget.
By Corollary 3.2 the five failures are one failure, and by Corollary 3.3 the true
requirement exceeded $56$; with the fitted constants it is near $64$. The positive content
is not the table but the *ratio*: the tax multiplied by the same factor as the baseline. By
Theorem 5.2 that had to happen, so the cell should be read as a successful consistency check
of the dilation structure and a measurement of the single exponent $b/a$.

### 11.2 Why the additive intuition is so persistent

Additive intuition is correct at fixed context. If you never change $C$, then
$T(\lambda,C) = (\chi(\lambda)-1)\mathcal{B}(1,C)$ really is a constant, and calling it "the
German surcharge" is harmless. The error appears the moment the surcharge is carried across
contexts — which is exactly what happens when a short-context benchmark is used to size a
long-context deployment. Theorem 8.6 says there is no regime in between: outside the two
degenerate cases, the surcharge moves.

### 11.3 Scope and limitations

The empirical base is one language pair and three held-out windows, at one context length
and one model scale. The exponent $b/a$ is therefore a single measured number, and the
claim that it is $4$ at the $4096$ transition rests on that cell. What the theory adds is
that this single number is *all* there is to measure: the shape of the language–context
interaction is fixed by the dilation structure, and only its slope is free. The two
predictions of Section 9 are designed to test the structure rather than the slope, and both
can be falsified by measurements already within reach.

A second limitation is the modelling assumption that a language enters only through an
effective context stretch $\lambda C$. This is a strong idealization: it treats
fragmentation as uniform, and ignores any language-specific change in the *shape* of the
attention distribution. The Zipf model shows that changing the shape drastically (from a
power-law recall curve to a continuum Zipf profile) preserves the law, which is reassuring;
but a language that changed the shape in a context-dependent way would fall outside the
dilation framework, and Prediction 2 is the sharpest available test for that.

### 11.4 Deployment consequences

Three, in order of bluntness.

1. **A short-context tokenizer benchmark does not transfer.** Multiply the measured
   surcharge by the baseline acceleration; Algorithm B is the whole rule.
2. **Budget tables must carry an interaction term** (Corollary 7.4), or be stored in
   log-space (Theorem 7.2).
3. **Block quantization is not a mitigation** (Theorems 7.6 and 7.8). Non-English agentic
   workloads face disproportionately growing cache costs as context extends past roughly
   two thousand tokens, and the growth rate is $1/a$ times worse than a token-count
   accounting suggests (Theorem 6.3).

---

## 12. Future work

The immediate experimental agenda is a French cell at $4096$ — does a romance language
behave like a germanic one? — followed by more languages at $4096$, a larger non-English
model at the same context, and a larger model scale. Prediction 1 becomes testable as soon
as two languages have been measured at two contexts; Prediction 2 as soon as three
languages share a context.

On the theoretical side, the natural next step is a rigidity theorem for the response
factor itself. A budget functional that is monotone in the context and covariant under the
two commuting dilations — language fragmentation and context length — appears to have no
freedom left: its response factor must be a continuous character of the positive reals,
hence a pure power $u \mapsto u^{\theta}$, with $\theta$ the only measurable parameter. If
that can be established under a mild regularity assumption (monotonicity or measurability,
in the spirit of the classical solutions of the Cauchy functional equation), then the entire
multilingual budget theory collapses to a single real number per language, and every
experimental cell is a measurement of that number.

Also open: whether the exchange principle survives non-uniform fragmentation, whether $b$
and $a$ can be separately identified from a two-context sweep (Theorem 8.13 says only their
ratio enters the character, so a second observable is needed), and whether the same
structure governs other bounded-memory primitives — sparse-attention schedules,
retrieval-chunk budgets, and speculative-decoding drafts — where the same dilation argument
would apply verbatim.

---

## 13. Conclusion

The tokenizer tax is a character. That single sentence contains the mathematics: because a
language shift acts on the workload as a dilation of the context, and because dilations
compose, the multiplicative response factor is forced to be a homomorphism, and the additive
tax is a fixed multiple of the baseline. From there the observed $+4 \mapsto +16$ transition
is an identity rather than a discovery, the hypotheses that the tax dissolves or persists at
a fixed offset are refuted with an exact dichotomy, additive budget tables are proved
impossible, and grid quantization is proved not to help. The law survives replacing the
recall model wholesale — a continuum Zipf attention profile, whose retention curve
$(k/C)^{1-s}$ is computed from mass integrals, obeys it too. What remains empirical is one
exponent. Everything else is algebra.
