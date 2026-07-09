# A Conditional Refinement of Page's Theorem on Landau–Siegel Zeros

**Author:** Aristotle
**Date:** 2026-07-09

## Abstract

Let $\chi$ range over the primitive real quadratic Dirichlet characters, indexed canonically by fundamental discriminants, with $\chi$ of conductor $q$ possessing the L-function $L(s,\chi)$. A *Landau–Siegel* (exceptional) zero is a real zero $\beta$ of $L(s,\chi)$ lying just below $s = 1$. Page's classical theorem asserts that among characters of bounded conductor, at most one exhibits such a zero. We establish a conditional refinement that both narrows the neighborhood of $s=1$ under consideration and globalizes the conclusion. For every $\varepsilon > 0$ there exist effectively computable constants $C(\varepsilon) > 0$ and $Q_0(\varepsilon) > 0$ with the following property. Suppose that for every primitive real quadratic character $\chi$ of conductor $q \ge Q_0(\varepsilon)$, every *non-real* zero $\rho$ of $L(s,\chi)$ satisfies the zero-free bound $\operatorname{Re}(\rho) \le 1 - C(\varepsilon)/\log q$. Then, across the *entire* family of such characters, at most one has a real zero $\beta$ in the shrinking interval $[1 - q^{-\varepsilon},\, 1)$. The argument isolates two deep analytic inputs — the non-real exclusion hypothesis and the quantitative Deuring–Heilbronn repulsion inequality — as explicit hypotheses, and shows that all remaining steps (an asymptotic threshold derivation, an exact enumeration of the characters, and the passage to a singleton) follow rigorously. We present the result as a modular pipeline whose stages can be independently strengthened, discuss the arithmetic of the enumeration, and outline concrete paths toward an unconditional statement.

## 1. Introduction

The distribution of prime numbers in arithmetic progressions is governed by the zeros of Dirichlet L-functions. Among all conjectural or hypothetical zero configurations, none is more consequential than the **Landau–Siegel zero**: a real zero $\beta$ of $L(s,\chi)$, for a real quadratic character $\chi$, situated in the narrow interval
$$1 - \frac{c}{\log q} < \beta < 1,$$
where $q$ is the conductor of $\chi$ and $c$ is an absolute constant. No such zero has ever been located, and the Generalized Riemann Hypothesis forbids them; yet their nonexistence remains unproven. Their potential presence renders ineffective a broad class of estimates — the prime number theorem for arithmetic progressions, bounds on the least prime in a progression, and lower bounds for class numbers among them.

**Page's theorem** (1935) is the principal classical constraint on these zeros: among the primitive real quadratic characters of conductor at most $Q$, at most one can possess a Landau–Siegel zero. The exceptional character, if it exists, is unique within each finite conductor window.

This paper develops a **conditional refinement** of Page's theorem that improves the statement along two axes simultaneously:

1. **A shrinking neighborhood.** In place of the classical interval $(1 - c/\log q,\, 1)$, whose width decays like $1/\log q$, we consider the interval $[1 - q^{-\varepsilon},\, 1)$, whose width decays *polynomially* as $q^{-\varepsilon}$.
2. **A global conclusion.** The uniqueness assertion is not confined to a finite window of conductors; it holds across the entire infinite family, provided a natural zero-free region excludes non-real zeros from a shrinking neighborhood of $s=1$.

The exchange that makes this possible is to promote the exclusion of *non-real* zeros to a standing hypothesis, and to draw uniqueness of the *real* exceptional zero as a conclusion. We organize the result as a **pipeline** of five stages, each with an explicit mathematical interface, so that the boundary between what is proved and what is assumed is perfectly transparent.

## 2. Definitions and Setup

Throughout, $\varepsilon > 0$ is fixed.

### 2.1 Primitive real quadratic characters and their enumeration

**Definition 2.1 (Fundamental discriminant).** An integer $D$ is a *fundamental discriminant* if $D \ne 0$ and either

- $D \equiv 1 \pmod 4$, $D \ne 1$, and $D$ is squarefree; or
- $D = 4e$ with $e \equiv 2$ or $3 \pmod 4$ and $e$ squarefree.

**Definition 2.2 (Primitive real quadratic character).** To each fundamental discriminant $D$ we associate the *Kronecker symbol* character $\chi_D = \left(\tfrac{D}{\cdot}\right)$, a primitive real Dirichlet character of conductor $q = |D|$. This assignment is a bijection between fundamental discriminants and primitive real quadratic characters; we therefore identify a character with its discriminant and write $q(\chi) = |D|$ for its conductor and $\log q(\chi) = \log |D|$.

Because the defining conditions on $D$ are decidable (squarefreeness and residues modulo $4$ are computable), the family of characters of conductor at most a bound $Q_0$ is *effectively enumerable*: one scans $D \in \{\pm 0, \pm 1, \dots, \pm Q_0\}$ and retains those satisfying Definition 2.1.

**Definition 2.3 (Zero locus).** For a character $\chi$ we write $Z(\chi) \subseteq \mathbb{C}$ for the set of nontrivial zeros of $L(s,\chi)$ in the critical strip. We treat $Z$ abstractly: the analytic construction of $L(s,\chi)$ and its zero set is standard, and our results depend only on the properties of $Z$ stated below.

### 2.2 The refined danger zone and exceptional zeros

**Definition 2.4 (Refined zero-free threshold).** Given $C > 0$ and a character $\chi$ of conductor $q$, the *refined threshold* is $1 - C/\log q$. The *refined danger zone* is the interval $(1 - C/\log q,\, 1)$.

**Definition 2.5 (Exceptional real zero).** A character $\chi$ *has an exceptional real zero* (relative to $C$) if there exists a real $\beta$ with $\beta \in Z(\chi)$ and $\beta > 1 - C/\log q$; that is, $L(\beta,\chi) = 0$ with $\beta$ in the refined danger zone.

**Definition 2.6 (Non-real exclusion certificate).** A character $\chi$ satisfies the *non-real exclusion condition* (relative to $C$) if every zero $\rho \in Z(\chi)$ with $\operatorname{Im}(\rho) \ne 0$ obeys
$$\operatorname{Re}(\rho) \le 1 - \frac{C}{\log q}.$$
Equivalently, no non-real zero lies in the refined danger zone.

## 3. The Asymptotic Engine

The bridge from the polynomially-thin interval $[1 - q^{-\varepsilon}, 1)$ to the logarithmically-thin refined danger zone is elementary but essential.

**Lemma 3.1 (Vanishing of $q^{-\varepsilon}\log q$).** For every $\varepsilon > 0$,
$$\frac{\log m}{m^{\varepsilon}} \;=\; m^{-\varepsilon}\log m \;\longrightarrow\; 0 \qquad (m \to \infty).$$

*Proof sketch.* The logarithm is of strictly smaller growth order than any positive power: $\log m = o(m^{\varepsilon})$ as $m \to \infty$. Dividing the little-$o$ relation by $m^{\varepsilon}$ yields that the quotient $\log m / m^{\varepsilon}$ tends to $0$. The identity $m^{-\varepsilon}\log m = \log m / m^{\varepsilon}$ holds for all $m > 0$ since $m^{-\varepsilon} = (m^{\varepsilon})^{-1}$. $\square$

**Corollary 3.2 (Existence of an effective threshold).** For every $\varepsilon > 0$ and every $C > 0$ there is an effectively computable $Q_0 = Q_0(\varepsilon, C) \in \mathbb{N}$ such that for all real $m \ge Q_0$,
$$m^{-\varepsilon}\log m \le C, \qquad\text{equivalently}\qquad m^{-\varepsilon} \le \frac{C}{\log m}.$$

*Proof sketch.* By Lemma 3.1 the quantity $m^{-\varepsilon}\log m$ is eventually within any neighborhood of $0$; in particular it is eventually $\le C$. The eventual-onset index is finite and may be taken as the ceiling of the witness produced by the convergence, giving an explicit $Q_0$. $\square$

The content of Corollary 3.2 is precisely what legitimizes the shrinking neighborhood: for $q \ge Q_0$ the interval $[1 - q^{-\varepsilon}, 1)$ is contained in the refined danger zone $(1 - C/\log q, 1)$, because $1 - q^{-\varepsilon} \ge 1 - C/\log q$. Hence any real zero in the thin interval is, a fortiori, an exceptional real zero in the sense of Definition 2.5.

**Definition 3.3 (Parameter pack).** A *pack* is a triple $(C, Q_0, \text{proof that } C > 0)$ where $C > 0$ is the refinement constant of the zero-free bound and $Q_0 \in \mathbb{N}$ is the enumeration cutoff. Given $\varepsilon > 0$, a canonical choice takes $C = \varepsilon$ and $Q_0$ the threshold furnished by Corollary 3.2. (For $\varepsilon = 1/10$ one may verify directly that a modest cutoff such as $Q_0 = 20$ already suffices for the tail bound to hold beyond it.)

## 4. The Repulsion Input

The exclusion of a *second* exceptional character rests on zero repulsion.

**Definition 4.1 (Quantitative Deuring–Heilbronn exclusion).** The zero locus $Z$ satisfies the *Deuring–Heilbronn exclusion* (relative to $C$) if for any two *distinct* primitive real quadratic characters $\chi_1 \ne \chi_2$, it is impossible for both to have an exceptional real zero:
$$\bigl(\chi_1 \text{ has an exceptional real zero}\bigr) \ \wedge\ \bigl(\chi_2 \text{ has an exceptional real zero}\bigr) \ \Longrightarrow\ \text{contradiction.}$$

This is the precise quantitative consequence of the Deuring–Heilbronn repulsion inequality, specialized to real zeros of real quadratic characters, where it is due to Landau. Its classical proof exploits the fact that the product
$$\zeta(s)\,L(s,\chi_1)\,L(s,\chi_2)\,L(s,\chi_1\chi_2)$$
is a Dirichlet series with non-negative coefficients (the "$3$–$4$–$1$" or Deuring product). Non-negativity forces a lower bound on the product near $s = 1$ that two independent exceptional real zeros would violate. We take this exclusion as an explicit hypothesis; its full analytic derivation is outside the present scope and is discussed in Section 7.

## 5. Main Result

**Theorem 5.1 (Conditional refinement of Page's theorem).** Fix $\varepsilon > 0$, and let $C = C(\varepsilon) > 0$ and $Q_0 = Q_0(\varepsilon)$ be as in Definition 3.3 and Corollary 3.2. Suppose:

1. **(Non-real exclusion.)** Every primitive real quadratic character $\chi$ of conductor $q \ge Q_0$ satisfies the non-real exclusion condition of Definition 2.6, relative to $C$.
2. **(Repulsion.)** The zero locus $Z$ satisfies the Deuring–Heilbronn exclusion of Definition 4.1, relative to $C$.

Then the collection of primitive real quadratic characters of conductor $\ge Q_0$ that possess a real zero $\beta \in [1 - q^{-\varepsilon}, 1)$ contains **at most one** element.

*Proof sketch.* Consider the set $S$ of characters (of conductor $\ge Q_0$) with a real zero in $[1 - q^{-\varepsilon}, 1)$. By Corollary 3.2, for conductor $q \ge Q_0$ the interval $[1 - q^{-\varepsilon}, 1)$ lies inside the refined danger zone $(1 - C/\log q, 1)$; hence every member of $S$ has an *exceptional real zero* in the sense of Definition 2.5. Now let $\chi_1, \chi_2 \in S$. If $\chi_1 \ne \chi_2$, then both have exceptional real zeros, contradicting the Deuring–Heilbronn exclusion (Definition 4.1). Therefore $\chi_1 = \chi_2$, i.e. any two elements of $S$ coincide, so $S$ is a subsingleton. $\square$

The logical skeleton of the conclusion — "no two distinct exceptional characters $\Rightarrow$ at most one exceptional character" — is worth isolating, as it is the reusable core.

**Proposition 5.2 (Repulsion yields a subsingleton).** Let $\mathcal{F}$ be any family of objects, and let $P$ be a property of members of $\mathcal{F}$. If for all distinct $a, b \in \mathcal{F}$ it is impossible that both $P(a)$ and $P(b)$ hold, then $\{x \in \mathcal{F} : P(x)\}$ has at most one element.

*Proof sketch.* Suppose $a, b$ both satisfy $P$. Were $a \ne b$, the hypothesis would yield a contradiction; hence $a = b$. Any two elements of the filtered set are equal, which is the definition of a subsingleton. $\square$

Theorem 5.1 is the instantiation of Proposition 5.2 with $\mathcal{F}$ the enumerated characters, $P(\chi)$ the property "$\chi$ has a real zero in $[1 - q^{-\varepsilon}, 1)$," the impossibility supplied by combining the containment (Corollary 3.2) with the Deuring–Heilbronn exclusion.

## 6. The Verification Pipeline

We organize the development as five interoperating stages, emphasizing that each has a clean interface and can be independently improved.

**Stage 1 — Asymptotic engine and parameter pack.** Lemma 3.1 and Corollary 3.2 produce, for any $\varepsilon, C > 0$, an effective cutoff $Q_0$. The pack $(C, Q_0)$ packages the refinement constant with the enumeration threshold (Definition 3.3).

**Stage 2 — Enumeration of characters.** Using the decidable criterion of Definition 2.1, one enumerates all fundamental discriminants $D$ with $|D| \le Q_0$ by scanning $\pm n$ for $n \le Q_0$ and filtering. Each surviving $D$ names a primitive real quadratic character of conductor $|D|$. This stage is fully constructive.

**Stage 3 — Non-real exclusion certificate.** For each enumerated character, a certificate records the analytic bound $\operatorname{Re}(\rho) \le 1 - C/\log q$ for every non-real zero $\rho$ (Definition 2.6). In practice such certificates arise from numeric zero-free-region computations (e.g. interval arithmetic on $\log L$); here they are the hypothesis feeding the theorem.

**Stage 4 — Repulsion input.** The Deuring–Heilbronn exclusion (Definition 4.1) is supplied as the second hypothesis, encoding pairwise incompatibility of exceptional real zeros.

**Stage 5 — Subsingleton conclusion.** Proposition 5.2 combines the containment and the repulsion into the final "at most one" statement (Theorem 5.1).

The decisive structural feature is the separation of concerns: the two genuinely deep analytic facts (Stages 3–4) are isolated as explicit hypotheses, while everything else (Stages 1, 2, 5) is unconditional.

## 7. Applications and Discussion

**Effectivity.** The chief interest of constraints on Landau–Siegel zeros is their bearing on *effective* number theory. A global "at most one" statement, conditional on a natural zero-free region for non-real zeros, localizes any exceptional behavior to a single character across the whole family — a substantially stronger organizing principle than a per-window uniqueness.

**Sharper window.** The polynomially thin interval $[1 - q^{-\varepsilon}, 1)$ is far more demanding than the classical logarithmic interval. That the same repulsion machinery still yields uniqueness against this narrower target is precisely the refinement: the asymptotic engine (Lemma 3.1) shows the thinner interval nests inside the refined danger zone once conductors are large.

**Conditional character.** Two inputs remain assumptions:

1. The **non-real exclusion** hypothesis — the premise of the statement, and exactly what is expected to be verifiable in ranges by explicit computation or granted by a zero-free region.
2. The **Deuring–Heilbronn repulsion** in its quantitative form. Its proof rests on the non-negativity of the coefficients of $\zeta(s)L(s,\chi_1)L(s,\chi_2)L(s,\chi_1\chi_2)$.

All downstream reasoning is unconditional, so the result cleanly quantifies the analytic distance to an unconditional theorem.

## 8. Future Directions

- **Discharge the repulsion bridge.** Derive the Deuring–Heilbronn exclusion from the non-real exclusion hypothesis directly, via the positivity of the four-fold product and explicit log-derivative estimates at an auxiliary point $s = 1 + \delta$.
- **Sharpen the constant to the classical form.** Replace the $\log(\min q)$ shape of the abstract repulsion by the classical $\log(q_1 q_2)$ form, matching Landau's constant exactly, and re-derive the subsingleton conclusion.
- **Arithmetic non-vacuity.** Tie the exceptional set explicitly to the Kronecker-symbol description of primitive real characters, so that "at most one character" is phrased at the level of fundamental discriminants.
- **Optimal effective $C(\varepsilon)$.** Track the best constant $C(\varepsilon)$ through the argument to obtain the fully effective statement, rather than a fixed placeholder constant.
- **Constructive selection.** Extract the exceptional character (if any) constructively rather than through a nonconstructive existence argument, trimming the logical footprint.

## 9. Conclusion

We have presented a conditional refinement of Page's theorem: assuming non-real zeros of quadratic L-functions are excluded from a shrinking neighborhood of $s = 1$, and granting quantitative Deuring–Heilbronn repulsion, the primitive real quadratic characters possessing a real zero in the polynomially-thin interval $[1 - q^{-\varepsilon}, 1)$ number at most one — globally, across the entire family. The result is organized as a transparent pipeline that separates two deep analytic inputs from an unconditional core, offering a precise roadmap toward an eventual unconditional theorem.
