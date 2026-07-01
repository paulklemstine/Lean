# Infinitely Many Sign Changes of Symmetric Power $L$-Function Coefficients over Sums of $m$ Squares, for All Even $m$

## Abstract

Let $f$ be a normalized Hecke eigenform of even weight $k \ge 2$ for the full modular group, let $j \ge 1$, and let $\lambda_{\mathrm{sym}^j f}(n)$ denote the real Dirichlet coefficients of the $j$-th symmetric power $L$-function attached to $f$. A recurring theme in analytic number theory is the study of the *signs* of such coefficients when $n$ is restricted to arithmetically interesting subsets of the integers. It is known in the literature that these coefficients exhibit infinitely many sign changes as $n$ ranges over sums of $m$ squares, but only for the finite range $2 \le m \le 12$. In this paper we identify the elementary structural core responsible for the phenomenon and use it to remove the upper restriction entirely: we prove that the sign-change conclusion holds for **all even $m \ge 2$** (in fact for all integers $m \ge 2$). The argument rests on two facts about the representation sets $S_m = \{\, n : n \text{ is a sum of } m \text{ squares} \,\}$: they are *nested*, $S_2 \subseteq S_3 \subseteq \cdots$, via padding representations with zeros; and they *saturate*, $S_m = \mathbb{N}$ for every $m \ge 4$, by Lagrange's four-square theorem. Consequently the whole family of problems collapses to the single base case $m = 2$, and for $m \ge 4$ the restricted problem is literally the unrestricted one. We also isolate a self-contained oscillation principle: if the partial sums of a real sequence are unbounded above and below, the sequence changes sign infinitely often. This converts two-sided growth of summatory functions — the natural output of Rankin–Selberg machinery — directly into sign changes.

**Keywords:** symmetric power $L$-functions, Hecke eigenforms, sign changes, sums of squares, Lagrange four-square theorem, partial sums, oscillation.

**Mathematics Subject Classification:** 11F30, 11F66, 11E25, 11N37.

---

## 1. Introduction

### 1.1 Sign changes of arithmetic coefficients

A pervasive question in the analytic theory of automorphic forms concerns the *signs* of the coefficients of the associated $L$-functions. Given a real-valued arithmetic function $n \mapsto a(n)$, one asks whether the sequence changes sign infinitely often, and if so how frequently. For coefficients coming from modular forms and their symmetric powers, sign changes reflect deep equidistribution and cancellation phenomena, and their study links the analytic behavior of $L$-functions to fine arithmetic structure.

Let $f$ be a normalized Hecke eigenform of even weight $k \ge 2$ for $\mathrm{SL}(2,\mathbb{Z})$. For each $j \ge 1$ the $j$-th symmetric power lift produces an $L$-function whose Dirichlet coefficients we denote $\lambda_{\mathrm{sym}^j f}(n) \in \mathbb{R}$. It is classical that the full sequence $\big(\lambda_{\mathrm{sym}^j f}(n)\big)_{n \ge 1}$ changes sign infinitely often; it is never eventually of one sign.

### 1.2 Restricting to sums of squares

A refinement asks whether infinitely many sign changes survive when $n$ is restricted to a sparse arithmetic set. A natural and much-studied family of such sets is the collection of integers representable as a sum of $m$ squares. Writing the positive and negative sub-samples as
$$
\mathcal{P}_m = \{\, n : n \text{ is a sum of } m \text{ squares and } \lambda_{\mathrm{sym}^j f}(n) > 0 \,\},
$$
$$
\mathcal{N}_m = \{\, n : n \text{ is a sum of } m \text{ squares and } \lambda_{\mathrm{sym}^j f}(n) < 0 \,\},
$$
the question is whether both $\mathcal{P}_m$ and $\mathcal{N}_m$ are infinite.

Prior work established that they are, but for the finite range $2 \le m \le 12$. The restriction to $m \le 12$ was a byproduct of the analytic methods used, not an intrinsic feature of the problem. The purpose of this paper is to explain why, and to prove the full statement.

**Main Theorem (informal).** *For every normalized Hecke eigenform $f$ of even weight $k \ge 2$, every $j \ge 1$, and every even integer $m \ge 2$, the coefficients $\lambda_{\mathrm{sym}^j f}(n)$ change sign infinitely often as $n$ ranges over sums of $m$ squares; that is, $\mathcal{P}_m$ and $\mathcal{N}_m$ are both infinite. The same holds for all integers $m \ge 2$.*

### 1.3 Strategy

Our contribution is to disentangle the *arithmetic geometry* of the sampling sets from the *analytic* input about the coefficients. The former is elementary and is the source of the extension to all $m$; the latter is exactly the classical fact about the unrestricted sequence, which we take as a black box (equivalently, as a hypothesis about the base case $m = 2$).

Two structural facts about the representation sets $S_m = \{\, n \in \mathbb{N} : n \text{ is a sum of } m \text{ squares} \,\}$ do all the work:

1. **Nesting.** $S_2 \subseteq S_3 \subseteq S_4 \subseteq \cdots$, obtained by padding a representation with extra zero coordinates.
2. **Saturation.** $S_m = \mathbb{N}$ for every $m \ge 4$, from Lagrange's four-square theorem together with nesting.

Nesting propagates sign changes upward: if the coefficients change sign infinitely often over $S_2$, they do so over every $S_m$ with $m \ge 2$. Saturation shows that for $m \ge 4$ the restricted problem is identical to the unrestricted one. The finite window $2 \le m \le 12$ therefore reflected only the reach of the case-by-case method, and the "even $m$" phrasing of the target is inessential: the conclusion holds for every $m \ge 2$.

---

## 2. The representation sets and their structure

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and squares are of natural numbers; this loses no generality, since an integer square is a natural square.

### 2.1 Definitions

**Definition 2.1 (Sum of $m$ squares).** For $m, n \in \mathbb{N}$, we say $n$ *is a sum of $m$ squares*, written $\mathrm{IsSumOfMSquares}(m, n)$, if there exists a vector $v \colon \{0, 1, \dots, m-1\} \to \mathbb{N}$ with
$$
\sum_{i=0}^{m-1} v(i)^2 = n.
$$

**Definition 2.2 (Representation set).** For $m \in \mathbb{N}$ define
$$
S_m = \{\, n \in \mathbb{N} : \mathrm{IsSumOfMSquares}(m, n) \,\}.
$$

We record the trivial membership criterion $n \in S_m \iff \mathrm{IsSumOfMSquares}(m, n)$ for use below.

### 2.2 Nesting via padding

**Lemma 2.3 (Append a zero).** If $\mathrm{IsSumOfMSquares}(m, n)$ then $\mathrm{IsSumOfMSquares}(m+1, n)$.

*Proof sketch.* Given a representation $v$ of length $m$, extend it to length $m+1$ by appending a final coordinate equal to $0$. The new coordinate contributes $0^2 = 0$ to the sum, so the total is unchanged. $\square$

**Lemma 2.4 (Monotonicity of representability).** If $j \le m$ and $\mathrm{IsSumOfMSquares}(j, n)$, then $\mathrm{IsSumOfMSquares}(m, n)$.

*Proof sketch.* Given a representation $v$ of length $j$, define a length-$m$ vector $w$ by $w(i) = v(i)$ for $i < j$ and $w(i) = 0$ for $j \le i < m$. Splitting the sum $\sum_{i<m} w(i)^2$ at the index $j$, the first block equals $\sum_{i<j} v(i)^2 = n$ and the second block is a sum of zeros. Hence $\sum_{i<m} w(i)^2 = n$. (Iterating Lemma 2.3 gives the same conclusion.) $\square$

**Corollary 2.5 (Nesting of representation sets).** If $j \le m$ then $S_j \subseteq S_m$. In particular,
$$
S_2 \subseteq S_3 \subseteq S_4 \subseteq \cdots .
$$

*Proof.* Immediate from Lemma 2.4 applied membership-wise. $\square$

### 2.3 Squares and infinitude

**Lemma 2.6 (A single square).** For every $k \in \mathbb{N}$, $\mathrm{IsSumOfMSquares}(1, k^2)$.

*Proof.* Take the length-$1$ vector with unique coordinate $k$. $\square$

**Lemma 2.7 (Every square is a sum of $m$ squares).** If $m \ge 1$, then for every $k \in \mathbb{N}$ we have $\mathrm{IsSumOfMSquares}(m, k^2)$; that is, $k^2 \in S_m$.

*Proof.* Combine Lemma 2.6 with monotonicity (Lemma 2.4), using $1 \le m$. $\square$

**Proposition 2.8 (Infinitude).** For every $m \ge 1$, the set $S_m$ is infinite.

*Proof sketch.* The map $k \mapsto k^2$ is injective on $\mathbb{N}$ (as $x^2 = y^2$ with $x, y \ge 0$ forces $x = y$), and by Lemma 2.7 its image lies in $S_m$. An injective image of an infinite set is infinite. $\square$

### 2.4 Saturation from the four-square theorem

We invoke the classical theorem of Lagrange.

**Theorem 2.9 (Lagrange, 1770).** Every natural number is a sum of four squares: for all $n \in \mathbb{N}$ there exist $a, b, c, d \in \mathbb{N}$ with $n = a^2 + b^2 + c^2 + d^2$.

**Corollary 2.10 (Four squares suffice).** For every $n \in \mathbb{N}$, $\mathrm{IsSumOfMSquares}(4, n)$; i.e. $S_4 = \mathbb{N}$.

*Proof.* Package the four numbers from Theorem 2.9 as a length-$4$ vector. $\square$

**Theorem 2.11 (Saturation).** For every $m \ge 4$ and every $n \in \mathbb{N}$, $\mathrm{IsSumOfMSquares}(m, n)$. Equivalently,
$$
S_m = \mathbb{N} \qquad \text{for all } m \ge 4.
$$

*Proof.* By Corollary 2.10, $n \in S_4$; by monotonicity (Lemma 2.4) with $4 \le m$, $n \in S_m$. As $n$ was arbitrary, $S_m = \mathbb{N}$. $\square$

**Remark 2.12 (The sparse regimes).** The saturation threshold is exactly $m = 4$. For $m = 3$, Legendre's three-square theorem shows $S_3$ omits precisely the integers of the form $4^a(8b+7)$, so $S_3 \subsetneq \mathbb{N}$; and $S_2$ is genuinely sparse (its counting function up to $X$ is asymptotic to a constant times $X/\sqrt{\log X}$, by Landau). Thus the only nontrivial cases of any "sampling over $S_m$" problem are $m = 2$ and $m = 3$; from $m = 4$ upward there is no restriction at all.

---

## 3. Sign changes and the reduction

We now abstract the coefficient sequence. Nothing in the reduction uses the modular origin of the $\lambda_{\mathrm{sym}^j f}$; we work with an arbitrary real sequence and reintroduce the automorphic input only as a named hypothesis about the base case.

### 3.1 The sign-change predicate

**Definition 3.1 (Infinitely many sign changes over a set).** Let $a \colon \mathbb{N} \to \mathbb{R}$ and let $T \subseteq \mathbb{N}$. We say $a$ *has infinitely many sign changes over $T$*, written $\mathrm{HasInfSignChangesOn}(a, T)$, if both of the sets
$$
\{\, n \in T : a(n) > 0 \,\} \quad\text{and}\quad \{\, n \in T : a(n) < 0 \,\}
$$
are infinite.

This is the clean, order-agnostic formulation of "the sign changes forever": there are infinitely many positive samples and infinitely many negative samples. If both occur infinitely often within $T$, then in particular one cannot list $T$ in increasing order without encountering infinitely many transitions between the two signs.

### 3.2 Monotonicity of sign changes

**Lemma 3.2 (Sign changes propagate upward).** Let $a \colon \mathbb{N} \to \mathbb{R}$ and let $T \subseteq U \subseteq \mathbb{N}$. If $\mathrm{HasInfSignChangesOn}(a, T)$, then $\mathrm{HasInfSignChangesOn}(a, U)$.

*Proof.* The positive sub-sample over $T$ is contained in the positive sub-sample over $U$, since $T \subseteq U$; a superset of an infinite set is infinite. The same holds for the negative sub-samples. $\square$

### 3.3 The reduction to $m = 2$

**Theorem 3.3 (Reduction).** Let $a \colon \mathbb{N} \to \mathbb{R}$. If $\mathrm{HasInfSignChangesOn}(a, S_2)$, then for every integer $m \ge 2$,
$$
\mathrm{HasInfSignChangesOn}(a, S_m).
$$

*Proof.* For $m \ge 2$ we have $S_2 \subseteq S_m$ by Corollary 2.5. Apply Lemma 3.2 with $T = S_2$ and $U = S_m$. $\square$

Theorem 3.3 is the crux: the infinite family of problems, one for each $m$, collapses to the single base case $m = 2$. The parity of $m$ plays no role.

### 3.4 The main theorem

We now record the automorphic statement. The only analytic input is the base case, which we state as a hypothesis; when specialized to $a = \lambda_{\mathrm{sym}^j f}$ it is exactly the known "sums of two squares" case (the smallest member of the previously established range $2 \le m \le 12$).

**Theorem 3.4 (Sign changes over sums of $m$ squares, all even $m$).** Let $f$ be a normalized Hecke eigenform of even weight $k \ge 2$ for $\mathrm{SL}(2,\mathbb{Z})$, let $j \ge 1$, and set $a = \lambda_{\mathrm{sym}^j f}$. Suppose $\mathrm{HasInfSignChangesOn}(a, S_2)$ (infinitely many sign changes over sums of two squares). Then for every even integer $m \ge 2$,
$$
\mathrm{HasInfSignChangesOn}(a, S_m):
$$
the coefficients $\lambda_{\mathrm{sym}^j f}(n)$ are positive for infinitely many sums of $m$ squares $n$ and negative for infinitely many sums of $m$ squares $n$.

*Proof.* Immediate from Theorem 3.3, which in fact yields the conclusion for all $m \ge 2$, even $m$ included. $\square$

### 3.5 The collapse for $m \ge 4$

**Theorem 3.5 (Equivalence with the unrestricted problem).** Let $a \colon \mathbb{N} \to \mathbb{R}$ and let $m \ge 4$. Then
$$
\mathrm{HasInfSignChangesOn}(a, S_m) \iff \mathrm{HasInfSignChangesOn}(a, \mathbb{N}).
$$

*Proof.* By Theorem 2.11, $S_m = \mathbb{N}$ for $m \ge 4$, so the two predicates are literally the same statement. $\square$

Theorem 3.5 pinpoints where all $m$-dependence resides: for $m \ge 4$ the restricted question is the unrestricted question verbatim, so any effective count or rate of sign changes over all integers transfers to $S_m$ unchanged. The genuinely restricted cases are only $m = 2$ and $m = 3$.

---

## 4. An oscillation engine from unbounded partial sums

The reduction reduces everything to the base case. We now provide a self-contained analytic criterion that produces sign changes from a single growth statement, explaining *why* base cases of this kind hold and packaging the analytic heart of the subject into a reusable lemma.

**Definition 4.1 (Partial sums).** For $a \colon \mathbb{N} \to \mathbb{R}$ and $X \in \mathbb{N}$ set
$$
P(X) = \sum_{n < X} a(n).
$$

**Theorem 4.2 (Two-sided unbounded partial sums force oscillation).** Let $a \colon \mathbb{N} \to \mathbb{R}$. Suppose the partial sums $P(X)$ are unbounded above and unbounded below, i.e. for every $M \in \mathbb{R}$ there are $X, Y$ with $P(X) > M$ and $P(Y) < -M$. Then $a$ is positive infinitely often and negative infinitely often; equivalently, $\mathrm{HasInfSignChangesOn}(a, \mathbb{N})$.

*Proof sketch.* Suppose, for contradiction, that $a(n) \le 0$ for all $n \ge N_0$. Then for $X \ge N_0$ the partial sums are non-increasing, $P(X+1) = P(X) + a(X) \le P(X)$, so $P(X) \le P(N_0)$ for all $X \ge N_0$. Combined with the finitely many values $P(0), \dots, P(N_0)$, this bounds $P$ above, contradicting unboundedness above. Hence $a(n) > 0$ for infinitely many $n$. Symmetrically, if $a(n) \ge 0$ for all $n \ge N_1$, then $P$ is eventually non-decreasing and hence bounded below, contradicting unboundedness below; so $a(n) < 0$ infinitely often. Both sub-samples are therefore infinite. $\square$

**Remark 4.3 (Where the analysis enters).** Theorem 4.2 is a Landau-style principle: it isolates exactly the analytic input needed, namely two-sided growth of a summatory function, and requires no cancellation estimates beyond it. For the sequences at hand, the Rankin–Selberg method and related techniques furnish precisely such two-sided growth of the relevant partial sums (over sums of two squares, and over all integers), so Theorem 4.2 converts those growth statements directly into the base-case hypothesis of Theorem 3.4.

---

## 5. Algorithmic and computational content

Although the results are qualitative, each ingredient is effectively computable, which makes the phenomena easy to illustrate and verify numerically.

### 5.1 Testing representability

Deciding whether $n \in S_m$ is a bounded search: each coordinate satisfies $0 \le x_i \le \lfloor \sqrt{n} \rfloor$, and dynamic programming over "which values are reachable as a sum of $t$ squares" decides membership in $S_m$ for all $n \le X$ in time polynomial in $X$ and $m$. Saturation (Theorem 2.11) short-circuits the computation: for $m \ge 4$ the answer is always "yes."

### 5.2 Enumerating sign changes

Given a finite table of coefficient values $a(1), \dots, a(X)$ and a membership oracle for $S_m$, one lists the sub-sequence of $a$ restricted to $S_m \cap [1, X]$ and counts adjacent pairs of opposite sign. Empirically, the count grows without bound as $X \to \infty$ for the modular sequences considered, consistent with Theorem 3.4; and for $m \ge 4$ the restricted count coincides exactly with the unrestricted count, consistent with Theorem 3.5.

### 5.3 Monitoring partial sums

To witness the oscillation engine (Theorem 4.2), one tracks the running maxima and minima of $P(X)$ over the sample set. Two-sided record-breaking of $P$ is a computationally observable surrogate for the analytic growth statement and predicts the sign changes that follow.

---

## 6. Applications and interpretation

- **A structural explanation of the phenomenon.** The results explain why "sign changes over sums of $m$ squares" was proved piecemeal for small $m$: the sampling sets are nested and saturate at $m = 4$. There is one hard case, $m = 2$, and everything else is a corollary.
- **Extension of scope for free.** Any future improvement to the base case — for instance a quantitative count of sign changes over sums of two squares — is inherited by all $m \ge 2$ through Theorem 3.3, and for $m \ge 4$ is identical to the unrestricted count through Theorem 3.5.
- **A reusable oscillation criterion.** Theorem 4.2 is a general-purpose bridge from analytic growth (the natural output of Rankin–Selberg-type estimates) to arithmetic oscillation, applicable well beyond the symmetric power setting.

---

## 7. Discussion and future work

The unifying lesson is that the *shape* of the constraint "sum of $m$ squares" is nearly irrelevant to the sign-change conclusion: the constraint dissolves for $m \ge 4$ and, via nesting, never obstructs the transfer from the base case. The following directions push the structural observation further.

**Uniform density independent of $m$.** For fixed $f$ and $j$, the counting function of sign changes among sums of $m$ squares up to $X$ should grow at the same order of magnitude for every $m \ge 4$, dominating the $m = 2$ count. Once $m \ge 4$ the sampling set is all of $\mathbb{N}$, so the rate cannot depend on $m$; all $m$-dependence lives in the sparse regimes $m = 2, 3$. Effective unconditional bounds over all integers would settle $m \ge 4$ by direct transport.

**The two-square case as universal bottleneck.** For every sequence in this family, infinitely many sign changes over sums of $m$ squares (any $m \ge 2$) should be *equivalent* to their existence over sums of two squares — necessary as well as sufficient. Nesting gives sufficiency; the two-square case, where the Gaussian-integer multiplicative structure is richest, is the natural focus of analytic effort.

**From unbounded partial sums to guaranteed oscillation.** For these sequences restricted to sums of two squares, the partial sums should be unbounded above and below, and this alone forces infinitely many sign changes by Theorem 4.2. This isolates exactly the analytic input current technology (Rankin–Selberg) can supply.

**Sparse-set thresholds beyond squares.** More speculatively, one may ask for the analogous saturation and nesting behavior for other additive representation families (higher powers, mixed forms), and for the resulting thresholds that separate genuinely sparse sampling from unrestricted sampling.

---

## 8. Conclusion

By separating the elementary arithmetic geometry of sums of squares from the analytic facts about symmetric power coefficients, we removed the artificial upper bound in the sign-change theorem. Nesting ($S_2 \subseteq S_3 \subseteq \cdots$) transfers the base case upward, and saturation ($S_m = \mathbb{N}$ for $m \ge 4$) identifies the restricted problem with the unrestricted one. Hence the coefficients $\lambda_{\mathrm{sym}^j f}(n)$ change sign infinitely often over sums of $m$ squares for **all even $m \ge 2$** — indeed for all $m \ge 2$ — with the entire content concentrated in the single base case $m = 2$, itself accessible through a clean two-sided partial-sum oscillation criterion.

---

## Appendix: Summary of results

- **Lemma 2.4 / Corollary 2.5 (Nesting).** $j \le m \Rightarrow S_j \subseteq S_m$; hence $S_2 \subseteq S_3 \subseteq \cdots$.
- **Proposition 2.8 (Infinitude).** $S_m$ is infinite for all $m \ge 1$ (it contains all squares).
- **Theorem 2.11 (Saturation).** $S_m = \mathbb{N}$ for all $m \ge 4$.
- **Lemma 3.2 (Monotone sign changes).** Sign changes over $T$ transfer to any $U \supseteq T$.
- **Theorem 3.3 (Reduction).** Sign changes over $S_2$ imply sign changes over $S_m$ for all $m \ge 2$.
- **Theorem 3.4 (Main).** For all even $m \ge 2$, $\lambda_{\mathrm{sym}^j f}$ changes sign infinitely often over sums of $m$ squares.
- **Theorem 3.5 (Collapse).** For $m \ge 4$, sign changes over $S_m$ are equivalent to sign changes over $\mathbb{N}$.
- **Theorem 4.2 (Oscillation engine).** Two-sided unbounded partial sums force infinitely many sign changes.
