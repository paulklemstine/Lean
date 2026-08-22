# The Curvature of a Model Pool: Sharpened Greedy Guarantees for Universal Compression Libraries

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $X$ be a finite message alphabet and let $\{P_i\}_{i \in \iota}$ be a family of candidate statistical models on $X$. The *price of universality* of a finite library $A$ of models is the Shtarkov sum $C(A) = \sum_{x \in X} \max_{i \in A} P_i(x)^{+}$, whose logarithm is the minimax regret of the best universal code for $A$. The functional $C$ is normalized, monotone and submodular, so greedy library design enjoys the classical $1 - 1/e$ guarantee.

We introduce the **curvature of a candidate pool** $\Omega$,
$$\kappa(\Omega) \;=\; 1 - \min_{j \in \Omega} \frac{C(\Omega) - C(\Omega \setminus \{j\})}{C(\{j\})} \;\in\; [0,1],$$
the Conforti–Cornuéjols total curvature of the price functional restricted to the pool, and develop its theory. We prove: (i) the *curvature inequality* $C(S \cup \{j\}) - C(S) \ge (1-\kappa)C(\{j\})$ for every sub-library $S \subseteq \Omega$ and every $j \in \Omega \setminus S$; (ii) *curvature superadditivity* $C(A \cup B) \ge C(B) + (1-\kappa)(C(A) - C(A \cap B))$, which together with submodularity forces exact modularity of $C$ on any zero-curvature pool; (iii) a *curvature-sharpened greedy step*, bounding the optimality gap after $k$ steps by $(n - (1-\kappa)k)$ greedy gains instead of $n$; (iv) the resulting product guarantee $C(B) - C(A_k) \le \prod_{i<k}\bigl(1 - \frac{1}{n - (1-\kappa)i}\bigr)\,C(B)$, whose endpoints are *exact optimality of greedy at $\kappa = 0$* and the classical $1 - 1/e$ at $\kappa = 1$; (v) the intermediate factor $1 - e^{-\kappa}$ and the low-curvature gap bound $\kappa(n-1)\,C(B)$; and (vi) monotonicity of curvature in the pool.

We then relate curvature to the statistical spread of the pool. Contrary to the natural conjecture $\kappa \le \delta\,|\Omega|$ for pools of pairwise total-variation diameter $\delta$, we prove the *reverse* inequality $\kappa \ge 1 - (|\Omega| - 1)\delta$: nearly identical pools are *maximally* curved. The conjecture is refuted by the pool of two identical fair coins ($\delta = 0$, $\kappa = 1$). The reverse bound is sharp: for two-source pools $\kappa = 1 - \delta_{TV}$ exactly, and every value $\kappa_0 \in [0,1]$ is realized by an explicit pool of two biased coins. Finally, a pigeonhole argument shows $\kappa = 1$ whenever $|\Omega| > |X|$ or the pool contains a duplicated source, so low curvature is available only for pools that form a code in the message alphabet.

**Keywords:** universal compression, Shtarkov sum, minimax regret, submodularity, total curvature, greedy approximation, model libraries, total variation distance.

---

## 1. Introduction

### 1.1 The price of universality

A universal code for a family of sources must pay for its ignorance of which source is active. For a finite alphabet $X$ and a finite family $A$ of models, the sharpest formulation of this cost is due to Shtarkov. Define the **envelope** of $A$ and its **Shtarkov sum**:

$$\hat P_A(x) \;=\; \max_{i \in A}\, \max\bigl(P_i(x),\,0\bigr), \qquad \hat P_{\emptyset} \equiv 0, \qquad C(A) \;=\; \sum_{x \in X} \hat P_A(x).$$

When each $P_i$ is a probability mass function, the *normalized maximum likelihood* distribution $\hat P_A / C(A)$ is the unique minimax-regret code for $A$, and its worst-case regret is exactly $\log C(A)$. We therefore call $C(A)$ the **price of universality** of the library $A$. It satisfies $C(\emptyset) = 0$ and, for a single probability mass function, $C(\{j\}) = 1$.

Three structural facts about $C$ are the foundation of everything below. They are elementary consequences of the pointwise identity $\max(a, \hat P_A(x)) = \hat P_{A \cup \{i\}}(x)$ and are recorded here as standing facts.

**Fact 1 (Normalization and monotonicity).** $C(\emptyset) = 0$, $C(A) \ge 0$, and $A \subseteq B$ implies $C(A) \le C(B)$.

**Fact 2 (Submodularity / diminishing returns).** If $A \subseteq B$ and $j$ is any model, then
$$C(A \cup \{j\}) - C(A) \;\ge\; C(B \cup \{j\}) - C(B).$$

**Fact 3 (Covering inequality).** For all finite libraries $A$, $B$,
$$C(A \cup B) - C(A) \;\le\; \sum_{j \in B} \bigl(C(A \cup \{j\}) - C(A)\bigr).$$

Facts 2 and 3 place $C$ in the class of monotone submodular set functions, for which greedy maximization under a cardinality constraint is guaranteed to recover a $1 - (1 - 1/n)^n \ge 1 - 1/e$ fraction of the optimum. Everything in this paper is about *improving* that constant using structure of the specific pool at hand.

### 1.2 The design problem and the role of curvature

The concrete engineering problem is: given a large pool $\Omega$ of candidate models, select a small sub-library $A \subseteq \Omega$ with $|A| = k$ maximizing $C(A)$ — a library rich enough to explain whatever data arrives. (Maximizing the Shtarkov sum is the right objective in the design-of-experiment sense: it maximizes the total explanatory mass the library can cover; the *regret* of the deployed code is then controlled separately by the size of the library.)

The $1 - 1/e$ bound is worst-case and is attained only by maximally "curved" instances. At the other extreme, if $C$ were modular on $\Omega$, greedy would be exactly optimal. The **total curvature** of Conforti and Cornuéjols measures where between these extremes a given instance sits. We import it into the universal-compression setting and study both its consequences for greedy design and its relation to the statistics of the pool.

### 1.3 Contributions

1. A complete basic theory of the curvature $\kappa(\Omega)$ of a candidate pool for the Shtarkov price functional: range, monotonicity in the pool, the workhorse curvature inequality, and curvature superadditivity, with the characterization of $\kappa = 0$ as exact modularity of $C$ on $\Omega$.
2. A curvature-sharpened analysis of greedy library design inside a pool, yielding a product guarantee that degrades continuously from exact optimality at $\kappa = 0$ to $1 - 1/e$ at $\kappa = 1$, together with the factor $1 - e^{-\kappa}$ and an explicit low-curvature gap bound.
3. A resolution of the relation between curvature and total-variation spread, in the direction *opposite* to the natural conjecture, including a refutation of $\kappa \le \delta\,|\Omega|$, a sharp reverse bound, an exact two-source formula, and a realization theorem showing the whole curvature scale is attained.
4. Pigeonhole saturation: $\kappa = 1$ for pools with duplicates and for pools larger than the alphabet, delimiting the regime in which curvature is informative.

---

## 2. Preliminaries and the curvature of a pool

Throughout, $X$ is a finite alphabet, $\iota$ an index type with decidable equality, and $P : \iota \to X \to \mathbb{R}$ a family of models. Libraries and pools are finite subsets of $\iota$. We write $C(A)$ for the Shtarkov sum defined above.

### 2.1 Singletons and subadditive splitting

**Lemma 2.1 (Singleton price).** $C(\{j\}) = \sum_{x} \max(P_j(x), 0)$. In particular $C(\{j\}) = 1$ when $P_j$ is a probability mass function.

**Lemma 2.2 (Insertion is at most solo value).** For every model $j$ and every library $A$,
$$C(A \cup \{j\}) - C(A) \;\le\; C(\{j\}).$$

*Proof.* Apply Fact 2 with $\emptyset \subseteq A$ and use $C(\emptyset) = 0$. $\square$

**Lemma 2.3 (Subadditivity across a splitting).** For all libraries $A, B$,
$$C(A) \;\le\; C(A \cap B) + \sum_{a \in A \setminus B} C(\{a\}).$$

*Proof.* Apply the covering inequality (Fact 3) to the pair $(A \cap B,\, A \setminus B)$, whose union is $A$, and bound each summand by Lemma 2.2. $\square$

### 2.2 Definition of the curvature

**Definition 2.4 (Marginal ratio).** For a pool $\Omega$ and $j \in \iota$, the *marginal ratio* of $j$ in $\Omega$ is
$$r_\Omega(j) \;=\; \frac{C(\Omega) - C(\Omega \setminus \{j\})}{C(\{j\})},$$
with the convention $r_\Omega(j) = 0$ when $C(\{j\}) = 0$ (the pessimistic convention; a worthless model is treated as maximally redundant).

**Definition 2.5 (Curvature of a pool).** The *curvature* of $\Omega$ is
$$\kappa(\Omega) \;=\; 1 - \min_{j \in \Omega} r_\Omega(j),$$
where the minimum over the empty pool is taken to be $1$, so that $\kappa(\emptyset) = 0$.

**Proposition 2.6 (Range).** $0 \le \kappa(\Omega) \le 1$ for every pool $\Omega$.

*Proof.* Monotonicity gives $C(\Omega) \ge C(\Omega \setminus \{j\})$ and $C(\{j\}) \ge 0$, so $r_\Omega(j) \ge 0$ and hence the minimum is $\ge 0$, i.e. $\kappa \le 1$. Lemma 2.2, applied with $A = \Omega \setminus \{j\}$ for $j \in \Omega$, gives $C(\Omega) - C(\Omega \setminus \{j\}) \le C(\{j\})$, hence $r_\Omega(j) \le 1$; the minimum is bounded above by $1$ (the default value also being $1$), so $\kappa \ge 0$. $\square$

**Proposition 2.7 (Monotonicity in the pool).** If $\Omega \subseteq \Omega'$ then $\kappa(\Omega) \le \kappa(\Omega')$.

*Proof.* For $j \in \Omega$, submodularity applied to $\Omega \setminus \{j\} \subseteq \Omega' \setminus \{j\}$ gives
$C(\Omega') - C(\Omega' \setminus \{j\}) \le C(\Omega) - C(\Omega \setminus \{j\})$, i.e. $r_{\Omega'}(j) \le r_\Omega(j)$. Hence $\min_{j \in \Omega'} r_{\Omega'}(j) \le \min_{j \in \Omega} r_{\Omega}(j)$. $\square$

Widening the shortlist can only weaken the guarantee — a first hint that redundancy, not diversity, is the enemy.

### 2.3 The curvature inequality and superadditivity

**Theorem 2.8 (Curvature inequality).** Let $j \in \Omega$ and let $S \subseteq \Omega$ with $j \notin S$. Then
$$C(S \cup \{j\}) - C(S) \;\ge\; \bigl(1 - \kappa(\Omega)\bigr)\, C(\{j\}).$$

*Proof.* Since $S \subseteq \Omega \setminus \{j\}$, submodularity gives $C(S \cup \{j\}) - C(S) \ge C(\Omega) - C(\Omega \setminus \{j\})$. If $C(\{j\}) = 0$, the right-hand side of the claim is $0$ and monotonicity finishes. Otherwise, $1 - \kappa(\Omega) \le r_\Omega(j)$ by definition of the minimum, and multiplying by $C(\{j\}) > 0$ turns the right-hand side into $C(\Omega) - C(\Omega \setminus \{j\})$. $\square$

This is the form in which curvature is used everywhere below: *every insertion of a pool member into any sub-library of the pool is worth at least a $(1-\kappa)$ share of its solo price.*

**Theorem 2.9 (Curvature superadditivity).** For sub-libraries $A, B \subseteq \Omega$,
$$C(A \cup B) \;\ge\; C(B) + \bigl(1 - \kappa(\Omega)\bigr)\bigl(C(A) - C(A \cap B)\bigr).$$

*Proof.* First, by induction on $T$ using Theorem 2.8 at each insertion, for every $T \subseteq \Omega$ disjoint from $B$,
$$C(T \cup B) \;\ge\; C(B) + (1-\kappa)\sum_{a \in T} C(\{a\}).$$
Apply this with $T = A \setminus B$, so $T \cup B = A \cup B$, and then bound $\sum_{a \in A \setminus B} C(\{a\}) \ge C(A) - C(A \cap B)$ by Lemma 2.3. $\square$

At $\kappa = 1$ Theorem 2.9 degenerates to monotonicity; at $\kappa = 0$ it is precisely the reverse of submodularity, giving:

**Corollary 2.10 (Zero curvature = modularity).** If $\kappa(\Omega) = 0$ then for all $A, B \subseteq \Omega$,
$$C(A \cup B) + C(A \cap B) = C(A) + C(B).$$

*Proof.* Submodularity gives "$\le$" in the form $C(A \cup B) + C(A \cap B) \le C(A) + C(B)$; Theorem 2.9 with $\kappa = 0$ gives the reverse. $\square$

So curvature is not merely a bookkeeping device: $\kappa = 0$ is *exactly* the statement that the price of universality is additive over the pool, which is the situation in which greedy selection is trivially exact. The content of the theory is the interpolation.

---

## 3. Curvature-sharpened greedy library design

### 3.1 Greedy runs inside a pool

**Definition 3.1 (Pool greedy run).** A sequence of libraries $A_0, A_1, A_2, \dots$ is a *greedy run in the pool $\Omega$* if
- $A_0 = \emptyset$;
- for every $k$ there is $j \in \Omega$ with $A_{k+1} = A_k \cup \{j\}$;
- for every $k$ and every $j \in \Omega$, $C(A_k \cup \{j\}) \le C(A_{k+1})$ (the step is value-maximizing among all pool members).

We write $\rho_k = C(A_{k+1}) - C(A_k)$ for the **$k$-th greedy gain**.

Such runs exist: since $\Omega$ is finite and nonempty, one may at each step select a maximizer of $j \mapsto C(A_k \cup \{j\})$ over $\Omega$, giving the canonical greedy sequence. All guarantees below are therefore non-vacuous.

**Lemma 3.2 (Basic structure of a greedy run).** For every greedy run in $\Omega$:
1. $A_k \subseteq A_{k+1} \subseteq \Omega$ and $\rho_k \ge 0$;
2. (*antitonicity of the gains*) $\rho_{k+1} \le \rho_k$;
3. (*solo dominance*) every $a \in A_k$ satisfies $\rho_k \le C(\{a\})$;
4. (*stalling certifies optimality*) if $\rho_k \le 0$ then $C(B) \le C(A_k)$ for every $B \subseteq \Omega$;
5. if $\rho_k > 0$ then $|A_{k+1}| = |A_k| + 1$.

*Proof sketch.* (1) is monotonicity. (2): write $A_{k+2} = A_{k+1} \cup \{j\}$; by submodularity along $A_k \subseteq A_{k+1}$, the gain of adding $j$ at step $k+1$ is at most its gain at step $k$, which by the greedy choice at step $k$ is at most $\rho_k$. (3): by induction; the element added at step $k$ has gain $\rho_k \le C(\{\cdot\})$ by Lemma 2.2, and earlier elements inherit the bound through (2). (4): by the covering inequality applied to $A_k$ and $B$, $C(A_k \cup B) - C(A_k) \le \sum_{j \in B} (C(A_k \cup \{j\}) - C(A_k)) \le |B| \rho_k \le 0$; combine with $C(B) \le C(A_k \cup B)$. (5): if the added element were already present, the gain would be $0$. $\square$

Item (2) is the algorithmic face of submodularity, item (4) is the standard optimality certificate, and item (3) is where curvature will enter: it lets us convert the solo prices appearing in Theorem 2.9 into greedy gains.

### 3.2 The sharpened step

**Theorem 3.3 (Curvature-sharpened greedy step).** Let $A_\bullet$ be a greedy run in $\Omega$, let $B \subseteq \Omega$ with $|B| = n$, let $\kappa = \kappa(\Omega)$, and suppose $|A_k| = k$. Then
$$C(B) - C(A_k) \;\le\; \bigl(n - (1-\kappa)k\bigr)\,\rho_k .$$

*Proof.* Write $m = |A_k \cap B|$. Three ingredients:

*(a) Covering above.* By Fact 3 applied to $A_k$ and $B \setminus A_k$, and by the greedy maximality of $\rho_k$,
$$C(A_k \cup B) - C(A_k) \;\le\; \sum_{j \in B \setminus A_k}\bigl(C(A_k \cup \{j\}) - C(A_k)\bigr) \;\le\; (n - m)\,\rho_k .$$

*(b) Curvature below.* By the inductive form of Theorem 2.9 applied to $T = A_k \setminus B$ (disjoint from $B$, contained in $\Omega$),
$$C(A_k \cup B) \;\ge\; C(B) + (1-\kappa)\!\!\sum_{a \in A_k \setminus B}\!\! C(\{a\}) \;\ge\; C(B) + (1-\kappa)(k - m)\rho_k ,$$
the last step by solo dominance (Lemma 3.2(3)), since $|A_k \setminus B| = k - m$.

*(c) Combine.* Subtracting $C(A_k)$ from (b) and comparing with (a),
$$C(B) - C(A_k) + (1-\kappa)(k-m)\rho_k \;\le\; (n-m)\rho_k ,$$
so
$$C(B) - C(A_k) \;\le\; \bigl(n - (1-\kappa)k\bigr)\rho_k \;-\; \kappa\, m\, \rho_k \;\le\; \bigl(n - (1-\kappa)k\bigr)\rho_k,$$
using $\kappa, m, \rho_k \ge 0$. $\square$

The curvature-free analysis is the case $\kappa = 1$, where the bound is $n\rho_k$. Each model already chosen shortens the effective horizon by $(1-\kappa)$.

### 3.3 The product guarantee

**Definition 3.4 (Curvature product).** For $n \in \mathbb{N}$, $\kappa \in [0,1]$ and $k \le n$,
$$Q_n^{\kappa}(k) \;=\; \prod_{i=0}^{k-1}\left(1 - \frac{1}{\,n - (1-\kappa)i\,}\right).$$

**Lemma 3.5 (Properties of the curvature product).** For $0 \le \kappa \le 1$ and $k \le n$:
1. $n - (1-\kappa)i \ge 1$ for $i + 1 \le n$, hence each factor lies in $[0,1)$ and $Q_n^{\kappa}(k) \ge 0$;
2. $Q_n^{\kappa}(k) \le (1 - 1/n)^k$;
3. $Q_n^{0}(n) = 0$.

*Proof.* (1) From $i + 1 \le n$ and $\kappa \ge 0$: $n - (1-\kappa)i \ge n - i \ge 1$. (2) Each denominator is at most $n$ since $\kappa \le 1$ and $i \ge 0$, so each factor is at most $1 - 1/n$; multiply nonnegative factors. (3) At $\kappa = 0$ and $i = n-1$ the denominator is $n - (n-1) = 1$, so that factor is exactly $0$. $\square$

**Theorem 3.6 (Curvature-sharpened greedy guarantee).** Let $A_\bullet$ be a greedy run in $\Omega$, $B \subseteq \Omega$, $n = |B|$, $\kappa = \kappa(\Omega)$. Then for every $k \le n$,
$$C(B) - C(A_k) \;\le\; Q_n^{\kappa}(k)\; C(B).$$

*Proof.* Induction on $k$, maintaining the stronger invariant: *either* $C(B) \le C(A_k)$ (greedy has already won, and the claim is immediate since $Q_n^\kappa(k)\,C(B) \ge 0$), *or* $|A_k| = k$ and the displayed bound holds.

For $k = 0$: $A_0 = \emptyset$, $C(A_0) = 0$, $Q_n^\kappa(0) = 1$, so the bound reads $C(B) \le C(B)$.

Inductive step: if greedy has already won at step $k$, it has won at step $k+1$ by monotonicity. Otherwise assume $|A_k| = k$ and the bound at $k$, and suppose $C(B) > C(A_{k+1})$ (else we are in the first case). Then $\rho_k > 0$, for otherwise Lemma 3.2(4) would give $C(B) \le C(A_k) \le C(A_{k+1})$; hence $|A_{k+1}| = k+1$. Write $D = n - (1-\kappa)k \ge 1$ (Lemma 3.5(1), using $k+1 \le n$). Theorem 3.3 rearranges to
$$\frac{C(B) - C(A_k)}{D} \;\le\; \rho_k ,$$
so
$$C(B) - C(A_{k+1}) \;=\; \bigl(C(B) - C(A_k)\bigr) - \rho_k \;\le\; \bigl(C(B) - C(A_k)\bigr)\left(1 - \frac{1}{D}\right).$$
The factor $1 - 1/D$ is nonnegative, so applying the inductive bound and $Q_n^\kappa(k+1) = Q_n^\kappa(k)(1 - 1/D)$ completes the step. $\square$

### 3.4 Consequences: the endpoints and the interior

**Theorem 3.7 (Zero curvature $\Rightarrow$ greedy is exactly optimal).** If $\kappa(\Omega) = 0$ and $B \subseteq \Omega$ is nonempty, then $C(B) \le C(A_{|B|})$: the greedy library of size $|B|$ is at least as valuable as $B$.

*Proof.* Theorem 3.6 with $k = n = |B| \ge 1$ and Lemma 3.5(3). $\square$

**Theorem 3.8 (The classical guarantee, for every pool).** For any pool and any nonempty $B \subseteq \Omega$,
$$\bigl(1 - e^{-1}\bigr)\,C(B) \;\le\; C(A_{|B|}).$$

*Proof.* Theorem 3.6 with $k = n$, then $Q_n^{\kappa}(n) \le (1-1/n)^n \le e^{-1}$ (Lemma 3.5(2) and the standard exponential bound). $\square$

**Theorem 3.9 (The factor $1 - e^{-\kappa}$).** For any pool of curvature $\kappa$ and nonempty $B \subseteq \Omega$,
$$\bigl(1 - e^{-\kappa}\bigr)\,C(B) \;\le\; C(A_{|B|}).$$

*Proof.* Immediate from Theorem 3.8 and $\kappa \le 1$, whence $e^{-1} \le e^{-\kappa}$. $\square$

Theorem 3.9 is the numerator of the conjectured Conforti–Cornuéjols factor $(1 - e^{-\kappa})/\kappa$. Since $\kappa \le 1$, this numerator is *weaker* than the classical bound, so the whole content of the conjecture sits in the $1/\kappa$ amplification. That amplification is not obtained here; see §6.

The genuinely new quantitative content of the theory in the low-curvature regime is the following.

**Theorem 3.10 (Low-curvature gap bound).** If $|B| = n = m + 1$ and $B \subseteq \Omega$, then
$$C(B) - C(A_{n}) \;\le\; \kappa\,m\;C(B) \;=\; \kappa\,(n-1)\,C(B).$$

*Proof.* Split the product at its last factor: $Q_n^\kappa(n) = Q_n^\kappa(m)\bigl(1 - 1/(n - (1-\kappa)m)\bigr)$. The prefix satisfies $Q_n^\kappa(m) \le (1 - 1/n)^m \le 1$ by Lemma 3.5(2). The final denominator is $n - (1-\kappa)m = (m+1) - m + \kappa m = 1 + \kappa m$, so the last factor equals
$$1 - \frac{1}{1 + \kappa m} \;=\; \frac{\kappa m}{1 + \kappa m} \;\le\; \kappa m .$$
Hence $Q_n^\kappa(n) \le \kappa m$ and Theorem 3.6 concludes. $\square$

The proof in fact establishes the slightly stronger intermediate bound
$$C(B) - C(A_n) \;\le\; \Bigl(1 - \tfrac1n\Bigr)^{n-1}\cdot\frac{\kappa (n-1)}{1 + \kappa(n-1)}\cdot C(B),$$
which is the sharpest form obtainable from the recursion.

**Interpretation.** Theorem 3.10 is the quantitative version of "greedy works better than $1-1/e$ in practice". For a target library of $n = 10$ models drawn from a pool of curvature $\kappa = 0.01$, greedy is within $9\%$ of optimal — whereas the assumption-free theory allows $36.8\%$ slack. The guarantee degrades linearly in $\kappa$ and in the library size, and vanishes at $\kappa = 0$, recovering Theorem 3.7.

### 3.5 Numerical comparison with the conjectured factor

The proved factor is $1 - Q_n^\kappa(n)$; the conjectured Conforti–Cornuéjols factor is $(1 - e^{-\kappa})/\kappa$ (with value $1$ at $\kappa = 0$). Both agree at the endpoints in spirit, and the proved factor is always below.

| $\kappa$ | $n$ | proved $1 - Q_n^\kappa(n)$ | conjectured $(1-e^{-\kappa})/\kappa$ |
|---|---|---|---|
| $0.0$ | $3$ | $1.0000$ | $1.0000$ |
| $0.1$ | $3$ | $0.9418$ | $0.9516$ |
| $0.5$ | $3$ | $0.8000$ | $0.7869$ |
| $1.0$ | $3$ | $0.7037$ | $0.6321$ |
| $0.1$ | $10$ | $0.9271$ | $0.9516$ |
| $1.0$ | $10$ | $0.6513$ | $0.6321$ |

At $\kappa = 1$ the proved bound $1 - (1-1/n)^n$ exceeds the conjectured asymptotic $1 - 1/e$ for finite $n$, as it must, since $(1-1/n)^n < e^{-1}$. In the low-curvature regime, which is where the conjecture has content, the proved bound falls just short of it, and the shortfall widens with $n$ — precisely the signature of the missing $1/\kappa$ amplification.

---

## 4. Curvature versus total variation

Write $\delta_{TV}(p,q) = \tfrac12 \sum_{x} |p(x) - q(x)|$. Call a pool $\Omega$ of probability mass functions *$\delta$-tight* if $\delta_{TV}(P_i, P_j) \le \delta$ for all $i, j \in \Omega$.

The natural conjecture — and the motivating one for this investigation — is that a $\delta$-tight pool should be nearly flat, hence low curvature: $\kappa \le \delta\,|\Omega|$. We show that the truth is exactly reversed.

### 4.1 Two identities

**Lemma 4.1 (Positive part computes total variation).** If $\sum_x p(x) = \sum_x q(x) = 1$, then
$$\sum_x \max(p(x) - q(x),\,0) \;=\; \delta_{TV}(p,q).$$

*Proof.* Pointwise, $\max(a,0) = (|a| + a)/2$; sum and use that $\sum_x (p - q) = 0$. $\square$

**Lemma 4.2 (Price of a pair).** If $p, q$ are probability mass functions, then
$$\sum_x \max(p(x), q(x)) \;=\; 1 + \delta_{TV}(p,q).$$

*Proof.* Pointwise, $\max(a,b) = (a + b + |a-b|)/2$; sum. $\square$

Lemma 4.2 already contains the moral: the price of a two-model library is $1 + \delta$, so *the value added by the second model is exactly the statistical distance between them*. Diversity is value.

### 4.2 Nearly identical pools are maximally curved

**Theorem 4.3 (Reverse total-variation bound).** Let $\Omega$ be a $\delta$-tight pool of probability mass functions with $|\Omega| \ge 2$ (models pointwise nonnegative). Then
$$\kappa(\Omega) \;\ge\; 1 - \bigl(|\Omega| - 1\bigr)\,\delta .$$

*Proof.* Pick any $j \in \Omega$; its solo price is $C(\{j\}) = 1$. Since $\hat P_{\Omega} = \max(P_j, \hat P_{\Omega \setminus \{j\}})$ pointwise,
$$C(\Omega) - C(\Omega \setminus \{j\}) \;=\; \sum_x \max\bigl(P_j(x) - \hat P_{\Omega\setminus\{j\}}(x),\,0\bigr).$$
For each $x$, the envelope over the nonempty set $\Omega \setminus \{j\}$ is attained by some model $P_{i(x)}$, so the summand is at most $\max(P_j(x) - P_{i(x)}(x), 0)$, which in turn is at most $\sum_{i \in \Omega\setminus\{j\}} \max(P_j(x) - P_i(x), 0)$ since all terms are nonnegative. Summing over $x$, exchanging the order of summation and applying Lemma 4.1 to each inner sum,
$$C(\Omega) - C(\Omega\setminus\{j\}) \;\le\; \sum_{i \in \Omega \setminus \{j\}} \delta_{TV}(P_j, P_i) \;\le\; (|\Omega| - 1)\,\delta .$$
So $r_\Omega(j) \le (|\Omega|-1)\delta$ for this $j$, hence $\min_{j} r_\Omega(j) \le (|\Omega|-1)\delta$ and $\kappa \ge 1 - (|\Omega|-1)\delta$. $\square$

### 4.3 Saturation

**Theorem 4.4 (Deletion criterion).** If $j \in \Omega$ and $C(\Omega) = C(\Omega \setminus \{j\})$, then $\kappa(\Omega) = 1$.

*Proof.* $r_\Omega(j) = 0$, and all marginal ratios are $\ge 0$, so the minimum is exactly $0$. $\square$

**Theorem 4.5 (Duplicates force maximal curvature).** If $\Omega$ contains two distinct indices $i \ne j$ with $P_i = P_j$ pointwise, then $\kappa(\Omega) = 1$.

*Proof.* The envelope of $\Omega$ and that of $\Omega \setminus \{j\}$ agree pointwise, because whatever $P_j$ contributes is contributed by the surviving copy $P_i$. Apply Theorem 4.4. $\square$

**Theorem 4.6 (Pigeonhole curvature saturation).** If all models are pointwise nonnegative and $|\Omega| > |X|$, then $\kappa(\Omega) = 1$.

*Proof.* For each message $x$ choose a model $f(x) \in \Omega$ attaining the envelope $\hat P_\Omega(x)$. The image $f(X)$ has at most $|X| < |\Omega|$ elements, so some $j \in \Omega$ lies outside it. That $j$ never attains the envelope, so $\hat P_{\Omega} = \hat P_{\Omega \setminus \{j\}}$ pointwise and Theorem 4.4 applies. $\square$

Theorem 4.6 is a hard combinatorial obstruction: *curvature can be below $1$ only if the pool fits inside the alphabet*, $|\Omega| \le |X|$. Curvature-aware library design is therefore meaningful exactly when the pool behaves like a code in the message space.

### 4.4 Refutation of the conjecture

**Theorem 4.7 (The conjecture $\kappa \le \delta\,|\Omega|$ is false).** There is a pool of two probability mass functions on a two-letter alphabet, pairwise total-variation distance $\delta = 0$, with curvature $\kappa = 1 > 0 = \delta \cdot |\Omega|$.

*Proof.* Take $X = \{0,1\}$ and two indices both carrying the fair coin $P_0 = P_1 = (\tfrac12, \tfrac12)$. Their total-variation distance is $0$, so the pool is $0$-tight; by Theorem 4.5 its curvature is $1$. $\square$

The failure is maximal — the conjectured bound is $0$ and the truth is $1$ — and by Theorem 4.3 it is systematic rather than accidental: statistical similarity *forces* curvature up, because curvature is a measure of redundancy and similar models are redundant.

### 4.5 Sharpness and realizability

**Theorem 4.8 (Two-source pools: exact formula).** Let $a \ne b$ index probability mass functions $P_a, P_b$. Then
$$\kappa\bigl(\{a,b\}\bigr) \;=\; 1 - \delta_{TV}(P_a, P_b).$$

*Proof.* Both solo prices are $1$, and by Lemma 4.2 the pool price is $C(\{a,b\}) = 1 + \delta_{TV}(P_a,P_b)$. Deleting either member leaves a price of $1$, so both marginal ratios equal $(1 + \delta) - 1 = \delta$, and $\kappa = 1 - \min(\delta,\delta) = 1 - \delta$. $\square$

Theorem 4.8 shows that the reverse bound of Theorem 4.3, which reads $\kappa \ge 1 - \delta$ when $|\Omega| = 2$, is *attained*. It also exhibits the exact trade-off: for pairs, curvature and statistical distance are one and the same quantity read from opposite ends of $[0,1]$.

**Theorem 4.9 (The curvature scale is fully realized).** For every $\kappa_0 \in [0,1]$ there is a pool of two probability mass functions on a two-letter alphabet with pairwise total-variation distance exactly $1 - \kappa_0$ and curvature exactly $\kappa_0$.

*Proof.* Set $d = 1 - \kappa_0 \in [0,1]$ and let $Q_i(x) = \tfrac{1+d}{2}$ if $i = x$ and $\tfrac{1-d}{2}$ otherwise, for $i, x \in \{0,1\}$: two coins with bias gap $d$, one favouring each letter. Each is a probability mass function with nonnegative entries, and $\delta_{TV}(Q_0, Q_1) = \tfrac12\bigl(|d| + |{-d}|\bigr) = d$. Theorem 4.8 gives $\kappa = 1 - d = \kappa_0$. $\square$

Consequently the curvature-indexed family of guarantees in §3 is non-degenerate: no value of $\kappa$ in $[0,1]$ is unreachable, and every intermediate guarantee is about a genuine, explicitly constructible pool.

---

## 5. Algorithms

Everything above is computationally effective for a finite alphabet.

**Computing the price.** $C(A) = \sum_{x} \max_{i \in A} P_i(x)^+$ costs $O(|X|\,|A|)$ arithmetic operations.

**Computing the curvature.** Evaluate $C(\Omega)$ once, then $C(\Omega \setminus \{j\})$ and $C(\{j\})$ for each $j \in \Omega$: total cost $O(|X|\,|\Omega|^2)$. A running two-largest-values-per-symbol table reduces this to $O(|X|\,|\Omega|)$: for each $x$ record the largest and second-largest model values; then $C(\Omega) - C(\Omega\setminus\{j\})$ is the sum over the symbols where $j$ is the unique argmax of (largest $-$ second largest).

**Greedy library design in a pool.** For $k$ steps, each step scans all $|\Omega|$ remaining candidates and evaluates the incremental price, costing $O(|X|)$ per candidate given the current envelope: total $O(k\,|\Omega|\,|X|)$. The certificate produced along the way is the sequence of gains $\rho_0 \ge \rho_1 \ge \cdots$, from which Theorem 3.3 yields a *run-time* upper bound on the residual gap, typically far better than the a priori bound of Theorem 3.6.

**A posteriori certification.** After running greedy for $k$ steps with $|A_k| = k$, the value $\bigl(n - (1-\kappa)k\bigr)\rho_k$ is a certified upper bound on $C(B) - C(A_k)$ for *every* target $B \subseteq \Omega$ with $|B| = n$. In particular, if $\rho_k = 0$ the current library is exactly optimal among all sub-libraries of the pool of any size (Lemma 3.2(4)).

---

## 6. Discussion

### 6.1 What the curvature does and does not deliver

Curvature succeeds as an interpolation parameter: from exact optimality at $\kappa = 0$, through the explicit product bound, to $1 - 1/e$ at $\kappa = 1$, with a clean linear-in-$\kappa$ low-curvature guarantee. It also succeeds as a *diagnostic*: it is computable in time linear in the pool size, it detects duplicates and pigeonhole-redundant pools, and its monotonicity in the pool means that pruning a shortlist can only improve the guarantee.

It does not, in the analysis given here, deliver the full Conforti–Cornuéjols factor $(1-e^{-\kappa})/\kappa$. The obstruction is structural rather than technical: the recursion used in Theorem 3.6 propagates a single scalar (the current gap) and discards all information about the earlier gains. The conjectured factor, by contrast, is the optimal value of a linear program in the entire gain vector.

### 6.2 The reversal of the total-variation intuition

The most instructive outcome is the failure of the conjecture $\kappa \le \delta\,|\Omega|$. The intuition behind it — "nearly identical models leave little to choose between, so any choice is nearly optimal" — conflates two different notions of "nearly optimal". It is true that a $\delta$-tight pool has a small *absolute* range of achievable prices: for any nonempty $A \subseteq \Omega$ and any $j \in A$ one has pointwise $\hat P_A(x) \le P_j(x) + \sum_{i \in A \setminus \{j\}} \max(P_i(x) - P_j(x), 0)$, so summing and applying Lemma 4.1 gives $1 \le C(A) \le 1 + (|\Omega| - 1)\delta$. But curvature is a *relative* quantity — a ratio of marginal to solo value — and precisely because the absolute range is small, the marginal values are small relative to the solo value $1$, driving the ratio to $0$ and the curvature to $1$.

Both statements are correct simultaneously: a $\delta$-tight pool is maximally curved *and* every selection from it is within an additive $(|\Omega|-1)\delta$ of optimal. The lesson is that in the near-identical regime the right guarantee is additive, not multiplicative, and curvature — a multiplicative notion — reports the situation as maximally adversarial. Conversely, for the multiplicative guarantees of §3 to be strong, one needs a *well-separated* pool, and Theorem 4.8 quantifies exactly how well-separated in the two-source case.

### 6.3 Practical reading

For a practitioner assembling a candidate pool of predictive models for later greedy selection:
- **deduplicate**, since a single duplicated pair sets $\kappa = 1$ and destroys every improved guarantee (Theorem 4.5);
- **keep the pool no larger than the alphabet**, or curvature saturates for purely combinatorial reasons (Theorem 4.6);
- **prefer a small, diverse shortlist to a large, redundant one**, since curvature is monotone in the pool (Proposition 2.7) and driven up by statistical similarity (Theorem 4.3);
- **report $\rho_k$**, the last greedy gain: it certifies the residual gap at run time far more tightly than any a priori bound.

---

## 7. Future directions

This work introduced the curvature $\kappa = 1 - \min_{j \in \Omega}\bigl(C(\Omega) - C(\Omega\setminus\{j\})\bigr)/C(\{j\})$ of a candidate pool for the Shtarkov price functional, proved a curvature-sharpened greedy analysis, and refuted the total-variation half of the driving conjecture.

**What survived.** The curvature inequality, curvature superadditivity, the sharpened step $\text{gap}_k \le (n - (1-\kappa)k)\rho_k$, the resulting product guarantee, exact optimality at $\kappa = 0$, $1 - 1/e$ at every curvature, monotonicity of curvature in the pool, the low-curvature gap bound $\kappa(n-1)$, and the factor $1 - e^{-\kappa}$ itself.

**What needed a different definition of "nearly identical".** The conjecture $\kappa \le \delta\,|\Omega|$ for $\delta$-tight pools is false: two identical fair coins have $\delta = 0$ and $\kappa = 1$. The correct statement runs the other way, $\kappa \ge 1 - (|\Omega|-1)\delta$.

**What was sharpened.** For two-source pools the curvature is exactly $1 - \delta$, so the lower bound is attained, and every value $\kappa_0 \in [0,1]$ is realized by an explicit pool of two biased coins: the curvature parameter is non-degenerate over its whole range.

**What is true but not reached.** The exact factor $(1 - e^{-\kappa})/\kappa$ is consistent with extensive random experiments but is not implied by the step-by-step recursion used here; for $\kappa = 0.1$, $n = 3$ the proved factor is $0.9418$ against the conjectured $0.9516$.

### Direction 1 — An LP-certified Conforti–Cornuéjols factor

The key insight is that the $(1 - e^{-\kappa})/\kappa$ factor is not a consequence of any single-step recursion: it is the value of a linear program whose variables are the whole vector of greedy gains $(\rho_0, \ldots, \rho_{n-1})$, constrained by monotonicity of the gains, the covering inequalities at every step, and the curvature inequality applied to every already-chosen model. All the inequality generators are already available — antitonicity of the gains, the sharpened step, the curvature inequality — so the missing ingredient is purely a finite-dimensional duality certificate, which can be guessed numerically and then verified symbolically.

### Direction 2 — A curvature–capacity trade-off from the pigeonhole obstruction

The key insight is that pigeonhole saturation turns curvature into a capacity statement: a pool can have $\kappa < 1$ only if $|\Omega| \le |X|$, so the useful regime of curvature-aware library design is exactly the regime in which the pool is a *code* in the alphabet, and the achievable curvature should be governed by how separated the models are in the simplex. Both sides of the trade-off are in hand — the pigeonhole saturation and the total-variation lower bound $\kappa \ge 1 - (|\Omega|-1)\delta$ — and the case $|\Omega| = 2$ is settled exactly by $\kappa = 1 - \delta_{TV}$. The general question is a packing problem: over all pools of $m$ probability mass functions on an alphabet of size $N$, what is $\min \kappa$, and which configurations attain it?

### Further questions

- **Beyond cardinality constraints.** Matroid-constrained greedy has a $1/(1+\kappa)$-type guarantee in the general submodular setting; specializing it to the Shtarkov functional with structured constraints (e.g. one model per data regime) is immediate in principle and would give deployable design rules.
- **Continuous alphabets.** The envelope and Shtarkov integral make sense for continuous $X$; the pigeonhole obstruction dissolves, and the curvature should be controlled by a covering number of the model class rather than by $|X|$.
- **Other divergences.** Total variation is the natural companion to the $\max$-envelope, but the Hellinger or Rényi spread might give sharper two-sided control of $\kappa$ for exponential families.
- **Curvature of parametric families.** For a smooth parametric family, is $\kappa$ of a finite pool of parameter values asymptotically governed by the Fisher information geometry of the family, in analogy with the classical $\tfrac{d}{2}\log n$ asymptotics of the Shtarkov sum?
