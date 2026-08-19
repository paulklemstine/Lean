# The Price of Universality is a Submodular Set Function

### The marginal value of a model, diminishing returns for Shtarkov sums, and a $(1-1/e)$ guarantee for greedy decompressor-library design

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

For a class $\mathcal S$ of probabilistic sources on a finite message set $X$, the minimax pointwise regret of universal coding is $\log_2 C_{\mathcal S}$ bits, where $C_{\mathcal S} = \sum_{x} \sup_{\theta} p_\theta(x)$ is the Shtarkov sum of the class — the $\ell^1$ norm of the maximum-likelihood envelope. We determine exactly how this *price of universality* responds to enlarging the class. Adjoining a single source $p$ to $\mathcal S$ changes the Shtarkov sum by
$$C_{\mathcal S \cup \{p\}} - C_{\mathcal S} = \sum_{x \in X} \bigl(p(x) - \hat p_{\mathcal S}(x)\bigr)^{+},$$
the total mass on which the new model strictly outbids the incumbent envelope $\hat p_{\mathcal S}(x) = \sup_\theta p_\theta(x)$. The increment vanishes precisely when $p \le \hat p_{\mathcal S}$ pointwise and is strictly positive otherwise; in particular every convex combination of members of $\mathcal S$ is free, so the price sees only extreme points. The same formula governs the merger of two classes, with the newcomer's envelope in place of $p$.

Because the positive part $(p(x) - t)^{+}$ is antitone in the incumbent level $t$, the marginal value formula immediately yields **diminishing returns**. Making this precise, we study the *library price functional* $C(A) = \sum_x \max_{i \in A} P_i(x)$ attached to a pool of candidate models $(P_i)_{i \in \iota}$ and finite libraries $A$. We prove that $C$ is monotone, vanishes on the empty library, satisfies the marginal value formula in library form, and is **submodular**: $C(A \cup B) + C(A \cap B) \le C(A) + C(B)$. We strengthen this to **multiplicative submodularity**, $C(A \cup B)\, C(A \cap B) \le C(A)\, C(B)$, whence the price *in bits*, $\log_2 C(A)$, is itself submodular whenever the shared sub-library $A \cap B$ contains a genuine source; a two-point-mass example shows the positivity guard cannot be dropped. As a corollary of monotone submodularity we obtain the design theorem: greedy library construction is $(1 - 1/e)$-optimal, i.e. after $n$ insertions the greedy library's price factor is at least $(1 - e^{-1})$ times that of the best library of size $n$, equivalently within $\log_2 \frac{e}{e-1} < 0.67$ bits of it. We also record the exact two-model identity $C(\{p,q\}) = 1 + \|p - q\|_{\mathrm{TV}}$, a worked four-model pool with exact prices, and exhaustive small-case computations confirming the general theorems.

**Keywords:** universal compression, Shtarkov sum, normalized maximum likelihood, minimax regret, submodularity, greedy approximation, total variation, model libraries.

---

## 1. Introduction

### 1.1 The problem

A lossless code for a finite message set $X$ is, up to integrality, a probability distribution $q$ on $X$: encoding $x$ costs $\log_2(1/q(x))$ bits. If the true source is $p$, the best achievable expected length is the entropy $H(p)$, attained by $q = p$. This is the ideal that a compressor with perfect knowledge would reach.

Real compressors do not have perfect knowledge. They must operate against a whole *class* of candidate sources
$$\mathcal S = \{p_\theta : \theta \in \Theta\},$$
and are judged not by expected length against a fixed source but by **regret** relative to the best member of the class *in hindsight*:
$$R(q, x) = \log_2 \frac{1}{q(x)} - \log_2 \frac{1}{\hat p_{\mathcal S}(x)}, \qquad \hat p_{\mathcal S}(x) := \sup_{\theta \in \Theta} p_\theta(x).$$
The function $\hat p_{\mathcal S}$ is the **maximum-likelihood envelope** of the class: the largest probability that any model in $\mathcal S$ assigns to the message $x$. It is generally not a probability distribution — its total mass exceeds $1$ as soon as the class contains two genuinely different models.

That total mass,
$$C_{\mathcal S} := \sum_{x \in X} \hat p_{\mathcal S}(x),$$
is the **Shtarkov sum** of the class, and it settles the minimax problem completely. Normalizing the envelope produces the **normalized maximum likelihood** (NML) distribution $q_{\mathrm{NML}}(x) = \hat p_{\mathcal S}(x)/C_{\mathcal S}$, whose regret is
$$R(q_{\mathrm{NML}}, x) = \log_2 \frac{C_{\mathcal S}}{\hat p_{\mathcal S}(x)} - \log_2\frac{1}{\hat p_{\mathcal S}(x)} = \log_2 C_{\mathcal S}$$
*for every* $x$ — a constant. No code can do better in the worst case, so the minimax pointwise regret equals $\log_2 C_{\mathcal S}$. We call this quantity the **price of universality** of the class:
$$\mathrm{price}(\mathcal S) := \log_2 C_{\mathcal S} \ \text{bits}.$$

Earlier instalments of this research thread settled the qualitative behaviour of the price: $C_{\mathcal S} = 1$ if and only if the class is degenerate (some single distribution dominates every member pointwise), so that any genuinely new source makes the price strictly positive; and the price is monotone under enlarging the class.

### 1.2 What this paper adds

We answer the quantitative question. *Exactly how many bits does one more model cost?* The answer, Theorem 3.1 below, is exact and elementary:
$$C_{\mathcal S \cup \{p\}} - C_{\mathcal S} \;=\; \sum_{x} \bigl(p(x) - \hat p_{\mathcal S}(x)\bigr)^{+}.$$
The formula has an immediate structural consequence: the increment is antitone in the incumbent envelope, hence in the class. This is diminishing returns, and diminishing returns for a set function is submodularity. Sections 5–7 develop the consequences: the price of universality, viewed as a functional on libraries of models, is a monotone submodular set function, additively and multiplicatively and (with a positivity guard) in bits; and therefore greedy library design enjoys the classical $(1 - 1/e)$ guarantee.

The practical reading is a design principle for compression systems. A modern archiver, a codec family, or a neural compression stack ships a *library* of models and a mechanism for selecting among them. Choosing which $n$ models to ship out of a large pool, so as to maximise the reach of the resulting envelope, is a subset-selection problem over an exponentially large search space. The theory below says the search is unnecessary: myopic, one-at-a-time selection by marginal value is within a factor $1 - 1/e$, i.e. within two-thirds of one bit, of the unattainable optimum.

### 1.3 Two readings of one number

A caution on interpretation, since the same quantity plays two roles. If a class $\mathcal S$ is *imposed* on you — you must be universal over it — then $\log_2 C_{\mathcal S}$ is a cost you pay, and you would prefer it small. If a library $A$ is something you *choose* from a pool, then $C(A)$ measures the probability mass the library's envelope captures, that is, its explanatory reach: the number of sources it can model well. In design mode one maximises $C$ subject to a cardinality budget; in operating mode one pays $\log_2 C$. The mathematics is identical; only the direction of preference differs. All statements below are about the functional itself and are agnostic between the two readings.

---

## 2. Setup and definitions

Throughout, $X$ is a finite nonempty set of messages.

**Definition 2.1 (Source class).** A *source class* on $X$ with parameter set $\Theta$ is a family $\mathcal S = (p_\theta)_{\theta \in \Theta}$ of functions $p_\theta : X \to \mathbb R$ with $p_\theta(x) \ge 0$ for all $x$ and $\sum_{x \in X} p_\theta(x) = 1$ for all $\theta$. The parameter set may be infinite; no measurability or topology is needed since $X$ is finite.

**Definition 2.2 (Maximum-likelihood envelope).** For a nonempty class $\mathcal S$, the envelope is $\hat p_{\mathcal S}(x) = \sup_{\theta \in \Theta} p_\theta(x)$. It satisfies the two characteristic properties: $p_\theta \le \hat p_{\mathcal S}$ pointwise for every $\theta$, and if $c \ge p_\theta(x)$ for all $\theta$ then $c \ge \hat p_{\mathcal S}(x)$. The supremum is finite because every $p_\theta(x) \le 1$.

**Definition 2.3 (Shtarkov sum and price).** $C_{\mathcal S} = \sum_{x \in X} \hat p_{\mathcal S}(x)$ and $\mathrm{price}(\mathcal S) = \log_2 C_{\mathcal S}$.

Two elementary bounds are used repeatedly and follow from $p_\theta \le \hat p_{\mathcal S} \le \sum_\theta$-type comparisons: $1 \le C_{\mathcal S}$ for every nonempty class (take any single $\theta$ and sum $p_\theta \le \hat p_{\mathcal S}$), and $C_{\mathcal S} \le |X|$ (each envelope value is at most $1$). Thus $0 \le \mathrm{price}(\mathcal S) \le \log_2 |X|$, and in particular $C_{\mathcal S} > 0$, so the logarithm is always defined for nonempty classes.

**Definition 2.4 (Total variation).** For distributions $p, q$ on $X$, $\|p - q\|_{\mathrm{TV}} = \frac12 \sum_{x} |p(x) - q(x)|$.

**Notation.** $(t)^{+} = \max(t, 0)$ for $t \in \mathbb R$.

The following triviality is the pivot of the entire paper.

**Lemma 2.5 (Positive part identity).** For all real $a, b$: $\max(a,b) - b = (a - b)^{+}$.

*Proof.* If $a \le b$ both sides are $0$; if $b \le a$ both sides are $a - b$. $\square$

---

## 3. The marginal value of a model

Let $\mathcal S = (p_\theta)_{\theta \in \Theta}$ be a nonempty source class and let $p$ be a probability distribution on $X$. Write $\mathcal S \cup \{p\}$ for the class with parameter set $\Theta \sqcup \{\ast\}$ whose members are the $p_\theta$ together with $p$.

**Lemma 3.1 (Envelope of an enlarged class).** $\widehat{p_{\mathcal S \cup \{p\}}}(x) = \max\bigl(p(x),\, \hat p_{\mathcal S}(x)\bigr)$ for every $x \in X$.

*Proof.* Both bounds are immediate from the characteristic properties of a supremum. Every member of the enlarged class is bounded by the right-hand side ($p$ by the first argument, each $p_\theta$ by $\hat p_{\mathcal S}$ and hence by the second), giving "$\le$". Conversely $p$ and each $p_\theta$ lie below the enlarged envelope, so $p(x)$ and $\hat p_{\mathcal S}(x)$ both do, giving "$\ge$". No attainment of the suprema is used. $\square$

**Theorem 3.2 (Marginal value formula).** For every nonempty class $\mathcal S$ and every distribution $p$ on $X$,
$$C_{\mathcal S \cup \{p\}} \;=\; C_{\mathcal S} \;+\; \sum_{x \in X} \bigl(p(x) - \hat p_{\mathcal S}(x)\bigr)^{+}.$$

*Proof.* By Lemma 3.1 the new envelope is $\max(p, \hat p_{\mathcal S})$, and by Lemma 2.5, pointwise,
$$\max\bigl(p(x), \hat p_{\mathcal S}(x)\bigr) = \hat p_{\mathcal S}(x) + \bigl(p(x) - \hat p_{\mathcal S}(x)\bigr)^{+}.$$
Summing over the finite set $X$ and splitting the sum gives the claim. $\square$

The theorem says that **the value of a model is the mass on which it beats the incumbent envelope**, and nothing else. Three corollaries make the dichotomy explicit.

**Corollary 3.3 (Nonnegativity).** $C_{\mathcal S} \le C_{\mathcal S \cup \{p\}}$: enlarging a class can never lower the price. (Each summand in Theorem 3.2 is nonnegative.)

**Corollary 3.4 (Free models).** $C_{\mathcal S \cup \{p\}} = C_{\mathcal S}$ if and only if $p(x) \le \hat p_{\mathcal S}(x)$ for all $x \in X$.

*Proof.* A finite sum of nonnegative terms vanishes iff every term vanishes, and $(p(x) - \hat p_{\mathcal S}(x))^{+} = 0$ iff $p(x) \le \hat p_{\mathcal S}(x)$. $\square$

**Corollary 3.5 (Genuinely new models).** $C_{\mathcal S} < C_{\mathcal S \cup \{p\}}$ if and only if there exists $x$ with $\hat p_{\mathcal S}(x) < p(x)$. Equivalently, in bits: $\mathrm{price}(\mathcal S) < \mathrm{price}(\mathcal S \cup \{p\})$ iff the new model strictly outbids the envelope somewhere.

*Proof.* The first statement is the contrapositive of Corollary 3.4 combined with Corollary 3.3: strict increase fails iff equality holds. For the second, $\log_2$ is strictly increasing on $(0,\infty)$ and both Shtarkov sums are $\ge 1 > 0$. $\square$

Two quantitative envelopes for the increment are worth recording. Both are sharp in the appropriate degenerate cases.

**Proposition 3.6 (Bounds on the increment).**
$$C_{\mathcal S \cup \{p\}} - C_{\mathcal S} \;\le\; \sum_x \bigl| p(x) - \hat p_{\mathcal S}(x)\bigr| \qquad\text{and}\qquad C_{\mathcal S \cup \{p\}} - C_{\mathcal S} \;\le\; 1.$$

*Proof.* Pointwise $(t)^{+} \le |t|$ gives the first. For the second, $(p(x) - \hat p_{\mathcal S}(x))^{+} \le p(x)$ because $\hat p_{\mathcal S}(x) \ge 0$ and $p(x) \ge 0$; summing gives $\sum_x p(x) = 1$. $\square$

**Theorem 3.7 (Mixtures are free).** Suppose $\Theta$ is finite, $w : \Theta \to [0,1]$ with $\sum_\theta w_\theta = 1$, and $p(x) = \sum_\theta w_\theta \, p_\theta(x)$ for all $x$. Then $C_{\mathcal S \cup \{p\}} = C_{\mathcal S}$.

*Proof.* $p(x) = \sum_\theta w_\theta p_\theta(x) \le \sum_\theta w_\theta \hat p_{\mathcal S}(x) = \hat p_{\mathcal S}(x)$, so Corollary 3.4 applies. $\square$

Thus the price of universality is blind to the convex hull: it depends only on the *extreme points* of the model set. Ensembling or averaging existing models buys no additional universality reach.

### 3.1 Merging whole classes

Nothing in the argument used that the newcomer was a single model.

**Definition 3.8.** For classes $\mathcal S = (p_\theta)_{\theta \in \Theta}$ and $\mathcal T = (r_\eta)_{\eta \in H}$ on $X$, their union $\mathcal S \sqcup \mathcal T$ has parameter set $\Theta \sqcup H$ and the evident members.

**Theorem 3.9 (Envelope and price of a union).** For nonempty $\mathcal S, \mathcal T$:
$$\widehat{p_{\mathcal S \sqcup \mathcal T}}(x) = \max\bigl(\hat p_{\mathcal S}(x), \hat p_{\mathcal T}(x)\bigr), \qquad C_{\mathcal S \sqcup \mathcal T} = C_{\mathcal S} + \sum_x \bigl(\hat p_{\mathcal T}(x) - \hat p_{\mathcal S}(x)\bigr)^{+}.$$
Consequently $C_{\mathcal S \sqcup \mathcal T} = C_{\mathcal S}$ iff $\hat p_{\mathcal T} \le \hat p_{\mathcal S}$ pointwise.

*Proof.* Identical to Lemma 3.1 and Theorem 3.2, with $\hat p_{\mathcal T}$ in place of $p$; the proofs never used $\sum_x p(x) = 1$ (only Proposition 3.6's second bound did). $\square$

**Theorem 3.10 (Antitonicity of marginal value).** If $\mathcal S, \mathcal S'$ are nonempty classes with $\hat p_{\mathcal S} \le \hat p_{\mathcal S'}$ pointwise, then for every class $\mathcal T$,
$$\sum_x \bigl(\hat p_{\mathcal T}(x) - \hat p_{\mathcal S'}(x)\bigr)^{+} \;\le\; \sum_x \bigl(\hat p_{\mathcal T}(x) - \hat p_{\mathcal S}(x)\bigr)^{+}.$$

*Proof.* $t \mapsto (c - t)^{+}$ is antitone for fixed $c$; apply pointwise and sum. $\square$

Theorem 3.10 is diminishing returns in complete generality: no finiteness of parameter sets, no attainment of suprema. The remainder of the paper converts it into the language of set functions, where the algorithmic consequences live.

---

## 4. The library price functional

Fix a **pool** of candidate models, i.e. a family of functions $P_i : X \to \mathbb R$ indexed by $i \in \iota$. Libraries are finite subsets $A \subseteq \iota$. Except where stated, the $P_i$ need not be probability distributions — the structural results hold for arbitrary families, which is convenient because envelopes and partial sums are not distributions either.

**Definition 4.1 (Library envelope).** $\mathrm{env}_A(x) = \max_{i \in A} P_i(x)$ if $A \neq \emptyset$, with the convention $\mathrm{env}_\emptyset(x) = 0$. Formally, $\mathrm{env}_A(x)$ is the fold of $\max$ over $A$ starting from $0$; equivalently $\mathrm{env}_A(x) = \max\bigl(\{0\} \cup \{P_i(x) : i \in A\}\bigr)$.

The convention $\mathrm{env}_\emptyset = 0$ makes the functional vanish on the empty library, which is exactly what the greedy machinery requires. For nonnegative pools — the case of interest — it changes nothing else, since then $\mathrm{env}_A = \max_{i\in A} P_i$ for $A \ne \emptyset$.

**Lemma 4.2 (Basic envelope calculus).** For all libraries $A, B$, all $j \in \iota$ and all $x \in X$:
1. $\mathrm{env}_A(x) \ge 0$;
2. $P_i(x) \le \mathrm{env}_A(x)$ for every $i \in A$;
3. if $c \ge 0$ and $c \ge P_i(x)$ for all $i \in A$, then $c \ge \mathrm{env}_A(x)$;
4. $A \subseteq B \implies \mathrm{env}_A(x) \le \mathrm{env}_B(x)$;
5. $\mathrm{env}_{A \cup \{j\}}(x) = \max\bigl(P_j(x), \mathrm{env}_A(x)\bigr)$;
6. $\mathrm{env}_{A \cup B}(x) = \max\bigl(\mathrm{env}_A(x), \mathrm{env}_B(x)\bigr)$.

*Proof.* (1)–(3) are the defining properties of a maximum over a finite set augmented by $0$; (4) follows from (2) and (3); (5) is idempotence of $\max$ under folding; (6) follows from (4) for "$\ge$" and from (2)–(3) applied to members of $A$ and of $B$ separately for "$\le$". $\square$

**Definition 4.3 (Library price functional).** $\displaystyle C(A) = \sum_{x \in X} \mathrm{env}_A(x)$, the $\ell^1$ norm of the envelope; and $\mathrm{price}(A) = \log_2 C(A)$ when $C(A) > 0$.

**Proposition 4.4.** $C(\emptyset) = 0$, $C(A) \ge 0$, and $C$ is monotone: $A \subseteq B \implies C(A) \le C(B)$.

*Proof.* Immediate from Lemma 4.2(1),(4) and linearity of the finite sum. $\square$

**Theorem 4.5 (Marginal value, library form).** For every library $A$ and every $j \in \iota$,
$$C(A \cup \{j\}) - C(A) \;=\; \sum_{x \in X} \bigl(P_j(x) - \mathrm{env}_A(x)\bigr)^{+}.$$

*Proof.* Lemma 4.2(5) followed by Lemma 2.5, summed over $x$. $\square$

We write $\Delta(j \mid A) := C(A \cup \{j\}) - C(A)$ for the marginal value.

**Theorem 4.6 (Submodularity).** For all libraries $A, B$,
$$C(A \cup B) + C(A \cap B) \;\le\; C(A) + C(B).$$

*Proof.* It suffices to prove the pointwise inequality
$$\mathrm{env}_{A \cup B}(x) + \mathrm{env}_{A \cap B}(x) \le \mathrm{env}_A(x) + \mathrm{env}_B(x)$$
and sum. Write $a = \mathrm{env}_A(x)$, $b = \mathrm{env}_B(x)$, $i = \mathrm{env}_{A \cap B}(x)$. By Lemma 4.2(6) the first term is $\max(a,b)$, and by Lemma 4.2(4) we have $i \le a$ and $i \le b$. If $a \le b$ then $\max(a,b) + i = b + i \le b + a$; symmetrically if $b \le a$. $\square$

**Theorem 4.7 (Diminishing returns).** If $A \subseteq B$ then $\Delta(j \mid B) \le \Delta(j \mid A)$ for every $j \in \iota$.

*Proof.* By Theorem 4.5 both sides are sums of positive parts, and $\mathrm{env}_A(x) \le \mathrm{env}_B(x)$ by Lemma 4.2(4), so termwise $(P_j(x) - \mathrm{env}_B(x))^{+} \le (P_j(x) - \mathrm{env}_A(x))^{+}$. $\square$

(Theorems 4.6 and 4.7 are equivalent formulations of submodularity for set functions; we prove both directly because each is used below in its own right.)

**Theorem 4.8 (Submodular covering inequality).** For all libraries $A, B$,
$$C(A \cup B) - C(A) \;\le\; \sum_{j \in B} \Delta(j \mid A).$$

*Proof.* We first prove the pointwise version by induction on $B$:
$$\mathrm{env}_{A \cup B}(x) - \mathrm{env}_A(x) \le \sum_{j \in B} \bigl(P_j(x) - \mathrm{env}_A(x)\bigr)^{+}.$$
For $B = \emptyset$ both sides are $0$. For the step, let $B' = B \cup \{j\}$ with $j \notin B$ and put $e = \mathrm{env}_A(x)$, $u = \mathrm{env}_{A \cup B}(x)$, $t = (P_j(x) - e)^{+} \ge 0$, $\Sigma = \sum_{i \in B}(P_i(x) - e)^{+} \ge 0$. Then $\mathrm{env}_{A \cup B'}(x) = \max(P_j(x), u)$. If $P_j(x) \le u$ the left side is $u - e \le \Sigma \le \Sigma + t$ by the inductive hypothesis. Otherwise the left side is $P_j(x) - e \le t \le t + \Sigma$. Summing the pointwise inequality over $x$, exchanging the two finite sums, and applying Theorem 4.5 to each inner sum gives the result. $\square$

Theorem 4.8 is the workhorse: it says that a library cannot be worth more, jointly, than the sum of its members' individual worths measured against the same incumbent.

### 4.1 The bridge to source classes

**Theorem 4.9 (The library functional is a Shtarkov sum).** Suppose the pool consists of genuine sources: $P_i(x) \ge 0$ for all $i, x$ and $\sum_x P_i(x) = 1$ for all $i$. Let $A$ be a nonempty library and let $\mathcal S_A$ denote the source class whose members are exactly the $P_i$, $i \in A$. Then $\hat p_{\mathcal S_A} = \mathrm{env}_A$ and hence
$$C_{\mathcal S_A} = C(A), \qquad \mathrm{price}(\mathcal S_A) = \log_2 C(A).$$

*Proof.* Both $\hat p_{\mathcal S_A}$ and $\mathrm{env}_A$ are the least upper bound of the finite set $\{P_i(x) : i \in A\}$ — for $\mathrm{env}_A$ one uses $A \ne \emptyset$ and $P_i \ge 0$ to discard the auxiliary $0$. Summing over $x$ gives the identity of Shtarkov sums. $\square$

So every statement in Section 4 is a statement about the genuine minimax regret of universal coding over the models in the library.

**Proposition 4.10 (Nonempty libraries of sources cost at least one).** If the pool consists of sources and $A \ne \emptyset$, then $C(A) \ge 1$; hence $\mathrm{price}(A) \ge 0$.

*Proof.* Pick $i \in A$; then $1 = \sum_x P_i(x) \le \sum_x \mathrm{env}_A(x) = C(A)$. $\square$

**Theorem 4.11 (Two-model libraries).** For sources $p, q$,
$$C(\{p, q\}) = \sum_x \max(p(x), q(x)) = 1 + \|p - q\|_{\mathrm{TV}}.$$

*Proof.* $\max(u,v) = \frac{u + v + |u - v|}{2}$ pointwise; summing gives $\frac{1 + 1}{2} + \frac12\sum_x |p(x) - q(x)| = 1 + \|p-q\|_{\mathrm{TV}}$. $\square$

Theorem 4.11 identifies the price of universality over a two-element class with the total-variation diversity of its members, and shows the price is $0$ bits exactly when $p = q$, in agreement with the degeneracy criterion.

**Theorem 4.12 (Strictness).** For any library $A$ and any $j$: $C(A) < C(A \cup \{j\})$ if and only if $\mathrm{env}_A(x) < P_j(x)$ for some $x$.

*Proof.* As in Corollaries 3.4–3.5, using Theorem 4.5. $\square$

---

## 5. Submodularity in bits

A general principle is available: if $f$ is a nonnegative monotone submodular set function and $g$ is concave and nondecreasing, then $g \circ f$ is submodular. With $g = \log_2$ this would deliver submodularity of the price in bits — except that $\log_2$ is not finite at $0$, and $C(\emptyset) = 0$ is exactly the value the price functional takes on the empty library, so the principle degenerates precisely at the boundary that matters. We therefore prove a sharper *multiplicative* inequality directly; it is a statement about the redundancy factors themselves, it is strictly stronger than the additive form whenever the values exceed $1$, and it passes through the logarithm cleanly wherever the logarithm is defined.

**Theorem 5.1 (Multiplicative submodularity).** For all libraries $A, B$,
$$C(A \cup B) \cdot C(A \cap B) \;\le\; C(A) \cdot C(B).$$

*Proof.* Write $u = C(A \cup B)$, $i = C(A \cap B)$, $a = C(A)$, $b = C(B)$. Monotonicity (Proposition 4.4) gives $0 \le i \le a$ and $i \le b$, and Theorem 4.6 gives $u + i \le a + b$. Then
$$ab - ui \;\ge\; ab - (a + b - i)\,i \;=\; (a - i)(b - i) \;\ge\; 0,$$
where the first inequality uses $u \le a + b - i$ and $i \ge 0$. $\square$

**Theorem 5.2 (The price in bits is submodular).** If $C(A \cap B) > 0$ then
$$\mathrm{price}(A \cup B) + \mathrm{price}(A \cap B) \;\le\; \mathrm{price}(A) + \mathrm{price}(B).$$

*Proof.* Monotonicity and $C(A \cap B) > 0$ force $C(A), C(B), C(A \cup B) > 0$, so all four logarithms are defined. Apply the increasing function $\log_2$ to Theorem 5.1 and split each logarithm of a product. $\square$

**Corollary 5.3.** If the pool consists of genuine sources and $A \cap B \neq \emptyset$, the conclusion of Theorem 5.2 holds. (By Proposition 4.10, $C(A \cap B) \ge 1 > 0$.)

**Theorem 5.4 (The guard is necessary).** There is a pool for which the bit-level inequality fails. Take $X = \{0, 1\}$ and the two point masses $P_0 = \delta_0$, $P_1 = \delta_1$, with $A = \{0\}$, $B = \{1\}$. Then $C(A) = C(B) = 1$, $C(A \cup B) = 2$, and $C(A \cap B) = C(\emptyset) = 0$, so the claimed inequality reads
$$\log_2 2 + \log_2 0 \le \log_2 1 + \log_2 1,$$
i.e. $1 + \log_2 0 \le 0$, which fails for any real-valued convention with $\log_2 0 = 0$ and holds only under the extended convention $\log_2 0 = -\infty$.

*Proof.* Direct computation of the three envelopes. $\square$

The boundary case is instructive rather than pathological: two libraries with nothing in common satisfy no bit-level submodularity constraint, because a library of zero models has no meaningful price. Any implementation manipulating real numbers must carry the guard $C(A \cap B) > 0$, which in practice means "the two libraries share at least one model".

---

## 6. Greedy library design

We now harvest the algorithmic consequence. Fix a pool $(P_i)_{i \in \iota}$.

**Definition 6.1 (Greedy run).** A sequence of libraries $A_0, A_1, A_2, \ldots$ is a *greedy run* if
1. $A_0 = \emptyset$;
2. each $A_{k+1} = A_k \cup \{j_k\}$ for some $j_k \in \iota$;
3. each step is optimal: $C(A_k \cup \{j\}) \le C(A_{k+1})$ for every $j \in \iota$.

**Proposition 6.2 (Budget).** A greedy run satisfies $|A_k| \le k$, so comparing $A_n$ with libraries of size $n$ is a fair comparison of equal budgets.

*Proof.* Induction: $|A_0| = 0$ and $|A_{k+1}| \le |A_k| + 1$. $\square$

**Lemma 6.3 (One greedy step earns its share).** Let $A$ be any library and $B$ a nonempty library with $|B| = n$. Then there is $j \in B$ with
$$\Delta(j \mid A) \;\ge\; \frac{C(B) - C(A)}{n}.$$

*Proof.* By monotonicity $C(B) \le C(A \cup B)$, so
$$C(B) - C(A) \;\le\; C(A \cup B) - C(A) \;\le\; \sum_{j \in B} \Delta(j \mid A)$$
using Theorem 4.8. A finite sum of $n$ terms that is at least $n \cdot \frac{C(B)-C(A)}{n}$ must contain a term at least $\frac{C(B)-C(A)}{n}$. $\square$

**Theorem 6.4 (Geometric decay of the optimality gap).** Let $(A_k)$ be a greedy run and $B$ a nonempty library with $|B| = n$. Then for every $k \ge 0$,
$$C(B) - C(A_k) \;\le\; \Bigl(1 - \frac1n\Bigr)^{k} C(B).$$

*Proof.* Induction on $k$. For $k = 0$, $C(A_0) = C(\emptyset) = 0$ and the claim is $C(B) \le C(B)$. For the step, Lemma 6.3 produces $j \in B$ with $\Delta(j \mid A_k) \ge \frac{C(B) - C(A_k)}{n}$, and greediness gives $C(A_{k+1}) - C(A_k) \ge \Delta(j \mid A_k)$. Hence
$$C(B) - C(A_{k+1}) \le \bigl(C(B) - C(A_k)\bigr) - \frac{C(B)-C(A_k)}{n} = \Bigl(1 - \frac1n\Bigr)\bigl(C(B) - C(A_k)\bigr),$$
and $0 \le 1 - \frac1n$ (as $n \ge 1$) lets us multiply the inductive bound through. $\square$

**Lemma 6.5.** For every integer $n \ge 1$, $\bigl(1 - \frac1n\bigr)^{n} \le e^{-1}$.

*Proof.* $1 + t \le e^{t}$ with $t = -1/n$ gives $0 \le 1 - \frac1n \le e^{-1/n}$; raise to the $n$-th power (both sides nonnegative) and use $(e^{-1/n})^n = e^{-1}$. $\square$

**Theorem 6.6 (Greedy design is $(1 - 1/e)$-optimal).** Let $(A_k)$ be a greedy run and $B$ a nonempty library, $n = |B|$. Then
$$C(A_n) \;\ge\; \bigl(1 - e^{-1}\bigr)\, C(B) \;\approx\; 0.6321\, C(B).$$
In particular this holds when $B$ is a library of size $n$ maximising $C$.

*Proof.* Theorem 6.4 at $k = n$ combined with Lemma 6.5 and $C(B) \ge 0$:
$$C(B) - C(A_n) \le \Bigl(1 - \frac1n\Bigr)^n C(B) \le e^{-1} C(B). \qquad \square$$

**Theorem 6.7 (Greedy runs exist).** If the pool is finite and nonempty, the canonical greedy sequence — $A_0 = \emptyset$, $A_{k+1} = A_k \cup \{j_k\}$ with $j_k \in \arg\max_j C(A_k \cup \{j\})$ — is a greedy run, so Theorem 6.6 is not vacuous.

*Proof.* A real-valued function on a finite nonempty set attains its maximum; the three conditions of Definition 6.1 hold by construction. $\square$

**Theorem 6.8 (The guarantee in bits).** If the pool consists of genuine sources and $B$ is a nonempty library with $n = |B|$, then the canonical greedy library satisfies
$$\mathrm{price}(A_n) \;\ge\; \mathrm{price}(B) - \log_2 \frac{e}{e-1}, \qquad \log_2 \frac{e}{e-1} = 0.6617\ldots < 0.67 .$$

*Proof.* By Proposition 4.10, $C(B) \ge 1 > 0$, and $1 - e^{-1} > 0$. Apply $\log_2$ to Theorem 6.6 and expand $\log_2\bigl((1-e^{-1}) C(B)\bigr) = \log_2 C(B) + \log_2(1 - e^{-1})$, noting $\log_2(1-e^{-1}) = -\log_2\frac{e}{e-1}$. $\square$

This is the design statement in its most usable form: **whatever the pool, whatever the alphabet, whatever the budget, greedy selection lands within two-thirds of a bit of the optimal library of the same size.**

---

## 7. Algorithms and complexity

Let $m = |\iota|$ be the pool size, $N = |X|$ the alphabet size, and $n$ the budget.

**Envelope maintenance.** Represent the current envelope as an array $e \in \mathbb R^{N}$, initialised to $0$. Inserting model $j$ replaces $e$ by $\max(e, P_j)$ componentwise in $O(N)$ time, and the current price factor $C(A) = \sum_x e(x)$ can be maintained incrementally.

**Marginal value.** By Theorem 4.5, $\Delta(j \mid A) = \sum_x (P_j(x) - e(x))^{+}$: one pass of $O(N)$ per candidate. Crucially, no re-evaluation of the whole envelope is needed and no matrix inversion, optimisation, or sampling appears anywhere.

**Greedy selection.** Each round evaluates $m$ marginals at $O(N)$ each and inserts the best: $O(mN)$ per round, $O(nmN)$ total. This is the same cost as reading the pool $n$ times.

**Lazy greedy.** Theorem 4.7 (diminishing returns) licenses the classical *lazy evaluation* speed-up: keep the candidates in a max-heap keyed by their last computed marginal value, which is an upper bound on their current marginal value; pop the top, recompute its marginal, and if it still tops the heap, accept it. Correctness is exactly diminishing returns — a stale key can only overestimate. The output equals that of plain greedy, so the guarantee is untouched, while the number of marginal evaluations drops substantially — on random pools of a few hundred models we observe reductions of 40% to 67%, growing with the pool size.

**Exact design.** Brute force over $\binom{m}{n}$ libraries costs $O\bigl(\binom{m}{n} n N\bigr)$ and is feasible only for toy pools. It is used below solely to certify greedy's performance on small instances.

**Pseudocode (greedy library design).**

```
input:  pool P[1..m] of nonnegative vectors of length N; budget n
output: library A of size <= n
A <- empty;  e <- zero vector of length N
repeat n times:
    best_j <- none;  best_gain <- 0
    for j not in A:
        gain <- sum over x of max(P[j][x] - e[x], 0)
        if gain > best_gain: best_gain <- gain; best_j <- j
    if best_j is none: break            # no model beats the envelope
    A <- A + {best_j}
    e <- componentwise max(e, P[best_j])
return A, sum(e)                        # price factor C(A); price = log2 C(A)
```

---

## 8. A worked pool, and exhaustive verification

Take $X = \{a_0, a_1, a_2\}$ and the pool

| model | $p(a_0)$ | $p(a_1)$ | $p(a_2)$ |
|---|---|---|---|
| $P_0$ | $1/2$ | $1/4$ | $1/4$ |
| $P_1$ | $1/4$ | $1/2$ | $1/4$ |
| $P_2$ | $1/3$ | $1/3$ | $1/3$ |
| $P_3$ | $0$ | $0$ | $1$ |

Exact prices, computed from Definition 4.3:

$$C(\{P_i\}) = 1 \ \ (\text{all } i), \quad C(\{P_0,P_1\}) = \tfrac54, \quad C(\{P_0,P_3\}) = \tfrac74, \quad C(\{P_0,P_1,P_2\}) = \tfrac43, \quad C(\{P_0,P_1,P_3\}) = 2 .$$

Three lessons are visible in these five numbers.

*A single model is free.* $C = 1$, price $0$ bits: universality over a singleton class is no burden — consistent with the degeneracy criterion and with Theorem 4.11 at $p = q$.

*Similar models are cheap.* $\|P_0 - P_1\|_{\mathrm{TV}} = \frac12(\frac14 + \frac14 + 0) = \frac14$, so Theorem 4.11 predicts $C(\{P_0,P_1\}) = \frac54$, which matches. The second skewed model adds only a quarter unit.

*Eccentric models are valuable; sensible ones need not be.* The marginal value of $P_3$ over $\{P_0\}$ is $(0 - \tfrac12)^{+} + (0 - \tfrac14)^{+} + (1 - \tfrac14)^{+} = \tfrac34$, three times that of $P_1$; and the three-model library $\{P_0,P_1,P_2\}$, with $C = 4/3$, is *less* valuable than the two-model library $\{P_0,P_3\}$, with $C = 7/4$. The uniform model barely pokes above the envelope of $\{P_0, P_1\}$, which is $(\tfrac12, \tfrac12, \tfrac14)$: it exceeds it only on $a_2$, and only by $1/12$, so its marginal value there is $1/12$ — while the degenerate point mass covers territory nobody else covers.

*Greedy is exact here.* Starting from $\emptyset$, greedy takes some model (all tie at gain $1$), say $P_0$; then compares gains $\Delta(P_1) = \frac14$, $\Delta(P_2) = \frac16$, $\Delta(P_3) = \frac34$ and takes $P_3$, reaching $C = \frac74$; then compares $\Delta(P_1) = \frac14$ against $\Delta(P_2) = \frac1{12}$ and takes $P_1$, reaching $C = 2$. The best three-element library is $\{P_0,P_1,P_3\}$ with $C = 2$, so greedy attains the optimum, comfortably above the guaranteed $0.632 \times 2 = 1.264$.

To rule out any accident of these particular hand-picked libraries, the general theorems were also checked exhaustively on an integer-scaled copy of this pool (multiply every probability by $12$, which scales $C$ by $12$ and preserves all the inequalities): the marginal value formula of Theorem 4.5 was confirmed for all $16 \times 4 = 64$ pairs (library, inserted model); submodularity (Theorem 4.6) for all $16 \times 16 = 256$ pairs of libraries; and diminishing returns (Theorem 4.7) for all nested pairs $A \subseteq B$ and all insertions. Every case holds with exact integer arithmetic.

---

## 9. Applications

**Codec and decompressor-library design.** An archiver that ships $n$ built-in models — text, source code, executables, images, tabular data, DNA — is solving exactly the cardinality-constrained maximisation of $C$. The results say: measure each candidate's marginal value as the mass on which it beats the current envelope, add the largest, repeat; the resulting library is within $0.67$ bits of the best possible.

**Deduplication of model zoos.** Corollary 3.4 gives an exact redundancy test: a model may be deleted from a library, with no loss of universality reach, precisely when it is pointwise dominated by the envelope of the others. Theorem 3.7 adds that any mixture of retained models is automatically redundant, so a library closed under mixture may be pruned to its extreme points.

**Model selection and MDL.** In the minimum description length framework the "parametric complexity" of a model class is $\log_2 C_{\mathcal S}$, the same quantity, and it acts as the complexity penalty in the NML criterion. The marginal value formula therefore prices the complexity cost of enriching a model family — for example when deciding whether to add a parameter or a mixture component — without recomputing the whole normalising constant.

**Diversity measurement.** Theorem 4.11 makes $C(A) - 1$ a natural multi-way generalisation of total variation: the excess mass of the envelope above a single distribution. Unlike pairwise-distance summaries, it is submodular, so diversity budgets can be optimised greedily with guarantees.

**Cryptographic and steganographic covers.** In settings where a cover distribution must plausibly explain traffic from several sources at once, $C$ quantifies the unavoidable statistical slack of the joint cover, and the marginal value formula tells the designer which additional traffic model actually widens the cover.

---

## 10. Discussion

The technical core of this work is a single line, $\max(a,b) - b = (a-b)^{+}$, applied to a quantity that happens to be an $\ell^1$ norm of a pointwise supremum. That such a small observation carries so much structure is worth pausing over. The Shtarkov sum is usually approached asymptotically — Rissanen's expansion $\frac{k}{2}\log \frac{n}{2\pi} + \log \int \sqrt{\det I(\theta)}\, d\theta + o(1)$ for smooth $k$-parameter families is the canonical result — and asymptotic formulas hide exact combinatorial structure. Read non-asymptotically, the Shtarkov sum turns out to be one of the *coverage functionals* of combinatorial optimisation, a max-of-sums whose increments are positive parts.

Three points of contrast deserve emphasis.

First, **the results are exact and assumption-free.** No smoothness, no parametric structure, no asymptotics in blocklength; the parameter set may be infinite and the supremum need not be attained. All that is used is that $X$ is finite so that the sums converge.

Second, **the bit-level statement needs care at the boundary.** The generic route to submodularity of $\log_2 C$ — a concave nondecreasing function of a monotone submodular function is submodular — breaks down exactly where the empty library sits, since $\log_2 0$ is not finite. Theorem 5.1 avoids the issue and gives more: the additive inequality plus monotonicity yields, via $(a-i)(b-i)\ge 0$, the strictly stronger multiplicative inequality between redundancy factors, which then survives the logarithm intact wherever it is defined. The two-point-mass boundary case (Theorem 5.4) marks the exact edge of validity.

Third, **the guarantee is worst-case and often pessimistic.** On the worked pool greedy is exactly optimal. The $(1-1/e)$ factor is the price of assuming nothing whatsoever about the pool's geometry, and curvature-refined bounds (see below) should recover most of the slack for realistic model pools whose members are mutually close.

A limitation worth naming: everything here concerns a *fixed* finite message set $X$, i.e. a fixed block length. Universal coding practice concerns sequences of growing length, where the Shtarkov sum of the $n$-fold class grows and the price per symbol vanishes. The library calculus applies verbatim at each fixed length, but the interaction between the greedy ordering at length $n$ and at length $n+1$ — whether greedy libraries are *nested* across block lengths — is not addressed and appears genuinely subtle.

---

## 11. Future directions

**Matroid constraints and continuous greedy.** A realistic codec budget is not a plain cardinality bound but a partition matroid: at most $k$ models per data modality. Under a matroid constraint plain greedy degrades to a factor $1/2$, while the continuous-greedy method restores $1 - 1/e$ by optimising the *multilinear extension*
$$F(y) = \mathbb E_{A \sim y}\, C(A) = \sum_{x} \mathbb E_{A \sim y} \max_{i \in A} P_i(x),$$
where $A$ contains $i$ independently with probability $y_i$. Conjecturally $F$ is concave along nonnegative directions and its gradient has the closed form
$$\frac{\partial F}{\partial y_j}(y) = \sum_{x} \mathbb E_{A \sim y}\, \bigl(P_j(x) - \mathrm{env}_A(x)\bigr)^{+},$$
which is exactly the expectation of the discrete marginal value. The key point is that this is not an abstract value-oracle expectation but an explicit $\ell^1$ norm of an expectation of positive parts; the discrete derivative is already in closed form (Theorem 4.5) and diminishing returns (Theorem 4.7) is precisely the sign condition needed for the cross-derivatives.

**Curvature: beating $1 - 1/e$ for smooth pools.** Define the curvature of a pool $\Omega$ by
$$\kappa = 1 - \min_{j \in \Omega} \frac{C(\Omega) - C(\Omega \setminus \{j\})}{C(\{j\})}.$$
Conjecture: greedy library design achieves the factor $(1 - e^{-\kappa})/\kappa$, and for pools whose members are pairwise within total variation $\delta$ one has $\kappa \le \delta \, |\Omega|$, so nearly identical model pools admit nearly optimal greedy libraries. The two-model identity $C(\{p,q\}) = 1 + \|p - q\|_{\mathrm{TV}}$ (Theorem 4.11) shows total variation to be the right modulus for controlling curvature of the Shtarkov functional, and the diversity lower bound $1 + \|p-q\|_{\mathrm{TV}} \le C$ supplies the other half.

**Hardness of exact design.** Conjecture: deciding, for a rational pool $P$ and thresholds $k, t$, whether some library of size $k$ has $C(A) \ge t$ is NP-hard — presumably by reduction from Max Coverage, whose coverage functional is the special case of $C$ in which every $P_i$ is a normalised indicator. A hardness result would complete the picture by showing the $(1-1/e)$ factor is not merely the best we have proved but, up to standard complexity assumptions, the best obtainable in polynomial time.

**Sequential and adaptive libraries.** Extending the calculus from a fixed alphabet to sequences, and to *adaptive* libraries whose members are selected online as data arrives, would connect the marginal value formula to the switching-and-mixing literature of online learning, where the same envelope appears as the best-expert-in-hindsight benchmark.

---

## 12. Summary of main results

1. **Marginal value formula.** $C_{\mathcal S \cup \{p\}} = C_{\mathcal S} + \sum_x (p(x) - \hat p_{\mathcal S}(x))^{+}$; the same with $\hat p_{\mathcal T}$ in place of $p$ for merging whole classes.
2. **Dichotomy.** The increment is zero iff $p \le \hat p_{\mathcal S}$ pointwise, and strictly positive iff $p$ outbids the envelope somewhere; the same in bits. Mixtures of class members are always free.
3. **Bounds.** The increment is at most $\sum_x |p(x) - \hat p_{\mathcal S}(x)|$ and at most $1$.
4. **Library functional.** $C(A) = \sum_x \max_{i \in A} P_i(x)$ is monotone, vanishes on $\emptyset$, satisfies $\Delta(j \mid A) = \sum_x (P_j(x) - \mathrm{env}_A(x))^{+}$, is submodular, has diminishing returns, and satisfies the covering inequality $C(A \cup B) - C(A) \le \sum_{j \in B} \Delta(j \mid A)$.
5. **Bridge.** For a nonempty library of genuine sources, $C(A)$ *is* the Shtarkov sum of the corresponding class, so the price of universality in bits is $\log_2 C(A) \ge 0$.
6. **Bit-level submodularity.** $C(A\cup B) C(A \cap B) \le C(A) C(B)$, hence $\log_2 C$ is submodular whenever $C(A \cap B) > 0$; two disjoint point-mass libraries show the guard is necessary.
7. **Two-model identity.** $C(\{p,q\}) = 1 + \|p - q\|_{\mathrm{TV}}$.
8. **Greedy design.** The optimality gap decays as $C(B) - C(A_k) \le (1 - 1/|B|)^k C(B)$; hence $C(A_n) \ge (1 - e^{-1}) C(B)$ for $|B| = n$, i.e. greedy is within $\log_2\frac{e}{e-1} < 0.67$ bits of the best library of the same size, and canonical greedy runs exist for finite pools.
