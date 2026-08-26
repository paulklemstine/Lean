# Restricted Sumsets Along Many Lines in $\mathbb{F}_p^2$: A Sharp Triple Criterion and the Failure of the $(k-2)(p-1)$ Threshold

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

Let $p$ be a prime, let $v_1,\dots,v_k$ be pairwise linearly independent directions in the plane $\mathbb{F}_p^2$, and let $S_1,\dots,S_k \subseteq \mathbb{F}_p$ be step-sets each containing $0$. The *reach* of the configuration is the restricted sumset
$$\mathcal{R}(v,S) \;=\; \Bigl\{\, \textstyle\sum_{i=1}^k s_i v_i \;:\; s_i \in S_i \,\Bigr\} \subseteq \mathbb{F}_p^2 ,$$
and the *total deficiency* is $D(S) = \sum_{i=1}^k (p - |S_i|)$. A natural conjecture, arising from the degree count in Alon's Combinatorial Nullstellensatz and from the exchange rate suggested by iterated Cauchy–Davenport, asserts that
$$D(S) \le (k-2)(p-1) \;\Longrightarrow\; \mathcal{R}(v,S) = \mathbb{F}_p^2 .$$

We settle this conjecture. It is **true for $k = 3$**, in the sharp form $D(S) < p$, and we give a short covering proof. It is **false for every $k \ge 4$ and every prime $p \ge 3$**: we exhibit a uniform family — the *harmonic quadruple* $(1,0),(0,1),(1,1),(-1,1)$ with step-sets $\mathbb{F}_p\setminus\{1\}, \mathbb{F}_p\setminus\{1\}, \{0,1\}, \{0,1\}$, padded by trivial sets $\{0\}$ — that attains total deficiency exactly $(k-2)(p-1)$ and misses the point $(1,2)$, for every $k$ in the entire feasible range $4 \le k \le p+1$.

In place of the false conjecture we prove a criterion that is valid for all $k$ and optimal: **if some three distinct indices $i,j,l$ satisfy $d_i + d_j + d_l < p$, where $d_i = p - |S_i|$, then $\mathcal{R}(v,S) = \mathbb{F}_p^2$.** The counterexample family shows that the strict inequality cannot be relaxed to $\le p$, since there every triple has deficiency sum at least $p$, with the value $p$ attained.

We also delimit exactly what the conjectured threshold does buy. First, under $D(S) \le (k-2)(p-1)$ the reach surjects onto every quotient line $\mathbb{F}_p^2/\langle v_{i_0}\rangle$, so its complement contains no full line in any of the $k$ directions; the counterexamples consequently miss only isolated points, and in fact exactly one. Second, if some $S_{i_0} = \mathbb{F}_p$, the conjectured bound *is* valid, by iterated Cauchy–Davenport in the quotient line followed by a sweep along $v_{i_0}$. Finally, we give the polynomial-method reformulation: $(k-2)(p-1)$ is precisely the degree budget making an admissible monomial of $L_1^{p-1}L_2^{p-1}$ available, so the conjecture can only fail through simultaneous vanishing of all admissible coefficients — which is exactly what happens in the harmonic family.

**Keywords:** restricted sumsets, Cauchy–Davenport, Combinatorial Nullstellensatz, finite plane, harmonic quadruple, polynomial method, spanning criteria.

---

## 1. Introduction

### 1.1 The problem

Additive combinatorics over $\mathbb{F}_p$ is dominated by one estimate: the Cauchy–Davenport inequality, which says that for nonempty $A, B \subseteq \mathbb{F}_p$,
$$|A + B| \ \ge\ \min\bigl(p,\ |A| + |B| - 1\bigr).$$
Iterating, a sum $A_1 + \cdots + A_m$ of nonempty sets has size at least $\min\bigl(p, \sum_i |A_i| - m + 1\bigr)$. In particular the sumset is all of $\mathbb{F}_p$ as soon as $\sum_i |A_i| \ge p + m - 1$, which is exactly the statement that the total deficiency obeys $\sum_i (p - |A_i|) \le (m-1)(p-1)$. The permitted deficiency thus grows by $p-1$ with each extra summand; the two-dimensional problem below is governed by an analogous-looking budget, and the whole point of this paper is that the analogy breaks.

The two-dimensional analogue studied here replaces "sets summed in $\mathbb{F}_p$" by "sets of scalars applied along fixed directions in $\mathbb{F}_p^2$". Given directions $v_1,\dots,v_k \in \mathbb{F}_p^2$ and step-sets $S_1,\dots,S_k \subseteq \mathbb{F}_p$, the object of interest is
$$\mathcal{R}(v,S) \;=\; S_1 v_1 + S_2 v_2 + \cdots + S_k v_k \;=\; \Bigl\{\textstyle\sum_i s_i v_i : s_i \in S_i\Bigr\}.$$
This is a *restricted sumset along lines*: each summand is confined to a one-dimensional subspace, and the only freedom is how far along that subspace one may travel.

Such configurations arise wherever a two-dimensional target must be hit by combining rank-one contributions with limited alphabets: in the design of covering codes over $\mathbb{F}_p$, in spread and blocking-set constructions in finite geometry, in exclusion arguments for auxiliary-class profiles in group-theoretic classification problems, and in the analysis of restricted-alphabet linear-combination reachability. The natural question is a *threshold* question: how much may the step-sets be depleted before the reach fails to be everything?

### 1.2 The conjectured threshold and the answer

Two independent heuristics point to the same bound.

*Heuristic 1 (dimension count).* Two directions with unrestricted sets already span the plane; each further direction should buy an extra line's worth of slack, $p-1$. This suggests the budget $(k-2)(p-1)$.

*Heuristic 2 (polynomial method).* Alon's Combinatorial Nullstellensatz reduces spanning to the nonvanishing of a coefficient of $L_1^{p-1}L_2^{p-1}$ at an exponent vector $e$ with $e_i \le |S_i| - 1$ and $\sum_i e_i = 2(p-1)$. Such an $e$ exists if and only if $\sum_i (|S_i| - 1) \ge 2(p-1)$, i.e. if and only if $D(S) \le (k-2)(p-1)$.

So the conjecture
$$D(S) \le (k-2)(p-1) \;\Longrightarrow\; \mathcal{R}(v,S) = \mathbb{F}_p^2 \tag{$\ast$}$$
is well motivated. Our results are:

1. **($\ast$) holds for $k=3$**, sharply (Theorem 3.1 and Remark 3.3).
2. **($\ast$) fails for all $k \ge 4$ and all $p \ge 3$** (Theorem 5.3).
3. The correct general criterion is a **triple criterion** (Theorem 4.1), and it is **optimal** (Theorem 5.5).
4. ($\ast$) is valid under the extra hypothesis that some $S_{i_0} = \mathbb{F}_p$ (Theorem 6.3).
5. ($\ast$) always yields **surjectivity onto every quotient line** (Theorem 7.1) and hence "no missing line" (Corollary 7.2).
6. The polynomial-method criterion and the exact degree-budget equivalence (Theorems 8.2, 8.4, 8.5).

---

## 2. Definitions and conventions

Throughout, $p$ is a prime and $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$.

**Definition 2.1 (The plane).** $\mathbb{F}_p^2$ is the set of ordered pairs $(x,y)$ with $x,y \in \mathbb{F}_p$, an $\mathbb{F}_p$-vector space of dimension $2$ and cardinality $p^2$.

**Definition 2.2 (Determinant).** For $a = (a_1,a_2)$ and $b = (b_1,b_2)$ in $\mathbb{F}_p^2$ set
$$\det(a,b) = a_1b_2 - a_2b_1 \in \mathbb{F}_p .$$
It is bilinear and alternating: $\det(a,b) = -\det(b,a)$, $\det(a+b,z) = \det(a,z)+\det(b,z)$, and $\det(ca,z) = c\det(a,z)$. Moreover $\det(a,b) = 0$ with $b \ne 0$ forces $a = \lambda b$ for a unique $\lambda \in \mathbb{F}_p$.

**Definition 2.3 (Pairwise independence).** A family $v = (v_1,\dots,v_k)$ in $\mathbb{F}_p^2$ is *pairwise independent* if $\det(v_i,v_j) \ne 0$ whenever $i \ne j$. Equivalently, the $v_i$ are nonzero and determine $k$ pairwise distinct points of the projective line $\mathbb{P}^1(\mathbb{F}_p)$. Since $|\mathbb{P}^1(\mathbb{F}_p)| = p+1$, a pairwise independent family has at most $p+1$ members; this is the *feasible range* $k \le p+1$.

**Definition 2.4 (Reach).** For a family of directions $v$ and step-sets $S_1,\dots,S_k \subseteq \mathbb{F}_p$,
$$\mathcal{R}(v,S) = \Bigl\{\, t \in \mathbb{F}_p^2 \;:\; \exists\, s \in \textstyle\prod_i S_i,\ \sum_i s_i v_i = t \,\Bigr\}.$$
We say the configuration *spans* if $\mathcal{R}(v,S) = \mathbb{F}_p^2$.

**Definition 2.5 (Deficiency).** $d_i = p - |S_i|$ and $D(S) = \sum_{i=1}^k d_i$. We always assume $0 \in S_i$ for every $i$; then $0 \le d_i \le p-1$, and $d_i = p-1$ exactly when $S_i = \{0\}$.

The hypothesis $0 \in S_i$ is a normalisation, not a restriction: translating each $S_i$ translates the reach by a fixed vector. Its combinatorial role is that a direction may always be *ignored*, which is what makes sub-configurations usable.

**Remark 2.6 (Monotonicity).** If $S_i \subseteq S_i'$ for all $i$ then $\mathcal{R}(v,S) \subseteq \mathcal{R}(v,S')$; and if $0 \in S_i$ for all $i$, then for any subset $I$ of indices, $\mathcal{R}(v|_I, S|_I) \subseteq \mathcal{R}(v,S)$, by setting $s_i = 0$ off $I$. Both facts are used repeatedly.

---

## 3. The three-line theorem

**Theorem 3.1 (Three pairwise independent lines).** Let $p$ be prime, let $v_1,v_2,v_3 \in \mathbb{F}_p^2$ be pairwise independent, and let $S_1,S_2,S_3 \subseteq \mathbb{F}_p$ satisfy
$$d_1 + d_2 + d_3 < p .$$
Then $\mathcal{R}(v,S) = \mathbb{F}_p^2$.

*Proof sketch.* Fix a target $t \in \mathbb{F}_p^2$ and suppose it is unreachable. Since $\det(v_1,v_2) \ne 0$, the pair $(v_1,v_2)$ is a basis; write
$$t = \alpha v_1 + \beta v_2, \qquad v_3 = \gamma v_1 + \delta v_2$$
with $\alpha,\beta,\gamma,\delta \in \mathbb{F}_p$ uniquely determined by Cramer's rule:
$$\alpha = \frac{\det(t,v_2)}{\det(v_1,v_2)}, \quad \beta = \frac{\det(v_1,t)}{\det(v_1,v_2)}, \quad \gamma = \frac{\det(v_3,v_2)}{\det(v_1,v_2)}, \quad \delta = \frac{\det(v_1,v_3)}{\det(v_1,v_2)} .$$
Pairwise independence gives $\gamma \ne 0$ (else $v_3 \parallel v_2$) and $\delta \ne 0$ (else $v_3 \parallel v_1$).

Every representation of $t$ is determined by its third coefficient: if $s_3 = c$, then necessarily
$$s_1 = \alpha - \gamma c, \qquad s_2 = \beta - \delta c ,$$
because $(v_1,v_2)$ is a basis. Unreachability therefore says: for every $c \in \mathbb{F}_p$,
$$c \notin S_3 \quad\text{or}\quad \alpha - \gamma c \notin S_1 \quad\text{or}\quad \beta - \delta c \notin S_2 .$$
Consequently $\mathbb{F}_p$ is covered by the three sets
$$\Bigl\{\tfrac{\alpha - u}{\gamma} : u \notin S_1\Bigr\} \ \cup\ \Bigl\{\tfrac{\beta - u}{\delta} : u \notin S_2\Bigr\} \ \cup\ \bigl(\mathbb{F}_p \setminus S_3\bigr).$$
The maps $u \mapsto (\alpha-u)/\gamma$ and $u \mapsto (\beta-u)/\delta$ are affine bijections (here $\gamma,\delta \ne 0$ is used a second time), so the three sets have sizes at most $d_1$, $d_2$, $d_3$. Counting,
$$p = |\mathbb{F}_p| \le d_1 + d_2 + d_3 ,$$
contradicting the hypothesis. $\square$

**Remark 3.2 (Structure of the argument).** The proof is a *pencil* argument: the set of representations of a fixed target by three pairwise independent directions is a one-parameter affine family, and a missed target requires the parameter line to be covered by three "forbidden" images. Pairwise independence is used exactly twice, and only to ensure the two coefficient maps do not degenerate.

**Remark 3.3 (Sharpness).** For $k=3$ the conjectured bound $(k-2)(p-1) = p-1$ coincides with $D(S) < p$, so Theorem 3.1 proves ($\ast$) for $k=3$, and the bound cannot be improved: configurations with $D(S) = p$ that miss a point are plentiful. For instance $v = ((1,0),(0,1),(1,1))$ with $S_1 = S_2 = \mathbb{F}_p\setminus\{1\}$, $S_3 = \{0,1\}$ has $D = 1 + 1 + (p-2) = p$ and misses $(1,2)$ by the same computation as in §5. Exhaustive enumeration at $p = 5$ over all $15{,}880$ hypothesis-satisfying triples confirms spanning in every case, and finds $14{,}400$ non-spanning configurations at $D = p$.

---

## 4. The triple criterion for many lines

**Theorem 4.1 (Triple criterion).** Let $p$ be prime, $k \ge 3$, let $v_1,\dots,v_k$ be pairwise independent, and let $S_1,\dots,S_k \subseteq \mathbb{F}_p$ each contain $0$. Suppose there exist three distinct indices $i,j,l$ with
$$d_i + d_j + d_l < p .$$
Then $\mathcal{R}(v,S) = \mathbb{F}_p^2$.

*Proof sketch.* The subfamily $(v_i,v_j,v_l)$ is pairwise independent, and $(S_i,S_j,S_l)$ has total deficiency $< p$, so by Theorem 3.1 every $t \in \mathbb{F}_p^2$ is $s_iv_i + s_jv_j + s_lv_l$ with $s_i \in S_i$ etc. Extend by $s_m = 0$ for $m \notin \{i,j,l\}$; this is legitimate because $0 \in S_m$, and it does not change the sum. Hence $t \in \mathcal{R}(v,S)$. $\square$

**Corollary 4.2 (Total-deficiency criterion).** If $k \ge 3$, the directions are pairwise independent, every $S_i$ contains $0$, and $D(S) < p$, then $\mathcal{R}(v,S) = \mathbb{F}_p^2$.

*Proof sketch.* Any three indices have deficiency sum at most $D(S) < p$; apply Theorem 4.1. $\square$

**Remark 4.3.** Restated: the reach is everything as soon as the **three smallest deficiencies** sum to less than $p$. Neither $k$ nor $D(S)$ enters. A single rich triple carries an arbitrarily deficient remainder — a strong statement that will turn out to be best possible in a precise sense (Theorem 5.5).

---

## 5. Refutation of the $(k-2)(p-1)$ conjecture

### 5.1 The harmonic quadruple

**Definition 5.1.** For $p \ge 3$ the *harmonic quadruple* is
$$w_1 = (1,0), \quad w_2 = (0,1), \quad w_3 = (1,1), \quad w_4 = (-1,1).$$
Its determinants are $\det(w_1,w_2) = 1$, $\det(w_1,w_3) = 1$, $\det(w_1,w_4) = 1$, $\det(w_2,w_3) = -1$, $\det(w_2,w_4) = 1$, $\det(w_3,w_4) = 2$. All are nonzero precisely because $p$ is odd, so the quadruple is pairwise independent for every odd prime; the four slopes $\infty, 0, 1, -1$ form a harmonic range in $\mathbb{P}^1(\mathbb{F}_p)$.

**Lemma 5.2 (The blocking identity).** Let $s_3, s_4 \in \{0,1\}$ and suppose
$$s_1 + s_3 - s_4 = 1, \qquad s_2 + s_3 + s_4 = 2 .$$
Then $s_1 = 1$ or $s_2 = 1$.

*Proof sketch.* Four cases. If $(s_3,s_4) = (0,0)$, the first equation gives $s_1 = 1$. If $(1,0)$, the second gives $s_2 = 1$. If $(0,1)$, the second gives $s_2 = 1$. If $(1,1)$, the first gives $s_1 = 1$. $\square$

The two equations are exactly the coordinates of $s_1w_1 + s_2w_2 + s_3w_3 + s_4w_4 = (1,2)$. Thus with $S_1 = S_2 = \mathbb{F}_p \setminus \{1\}$ and $S_3 = S_4 = \{0,1\}$, the point $(1,2)$ is unreachable, while
$$D(S) = 1 + 1 + (p-2) + (p-2) = 2(p-1) = (4-2)(p-1).$$

### 5.2 The uniform family

To reach arbitrary $k$, pad with directions carrying only the trivial step-set. Concretely, index the directions by $0,\dots,k-1$ and set
$$v_i = \begin{cases} (0,1) & i = 1,\\ (-1,1) & i = 3,\\ (1, \lambda_i) & \text{otherwise},\end{cases} \qquad \lambda_0 = 0,\ \lambda_2 = 1,\ \lambda_j = j-2 \ (j \ge 4),$$
so that the slopes $\lambda_i$ are pairwise distinct and avoid $-1$; this is possible exactly when $k \le p+1$, the full feasible range. Set
$$S_i = \begin{cases} \mathbb{F}_p \setminus \{1\} & i \in \{0,1\},\\ \{0,1\} & i \in \{2,3\},\\ \{0\} & i \ge 4 .\end{cases}$$

**Theorem 5.3 (Counterexample family).** Let $p \ge 3$ be prime and $4 \le k \le p+1$. The configuration above is pairwise independent, every $S_i$ contains $0$,
$$D(S) = 1 + 1 + (p-2) + (p-2) + (k-4)(p-1) = (k-2)(p-1),$$
and $(1,2) \notin \mathcal{R}(v,S)$. In particular the conjecture ($\ast$) fails for every $k \ge 4$ and every odd prime.

*Proof sketch.* Pairwise independence: the determinant of $(1,\lambda)$ and $(1,\mu)$ is $\mu - \lambda \ne 0$; of $(1,\lambda)$ and $(0,1)$ is $1$; of $(1,\lambda)$ and $(-1,1)$ is $1 + \lambda \ne 0$ since $\lambda \ne -1$; of $(0,1)$ and $(-1,1)$ is $1$. Deficiency: the four distinguished indices contribute $1,1,p-2,p-2$ and each padded index contributes $p-1$; the identity $1+1+2(p-2)+(k-4)(p-1) = (k-2)(p-1)$ is elementary. Unreachability: in any representation of $(1,2)$ the padded coefficients are forced to $0$ and contribute nothing, so the two coordinate equations reduce to those of Lemma 5.2, which force $s_0 = 1$ or $s_1 = 1$ — both forbidden. $\square$

**Remark 5.4 (Exactly one missing point).** Computation over the harmonic family for $p \in \{3,5,7,11\}$ and all admissible $k$ shows the reach misses *precisely* the single point $(1,2)$. This is consistent with, and sharpened by, the quotient-line surjectivity of §7, which forbids a whole line from being missed.

### 5.3 Optimality of the triple criterion

**Theorem 5.5 (Sharpness of the triple criterion).** For every prime $p \ge 3$ and every $k$ with $4 \le k \le p+1$ there is a pairwise independent family of $k$ directions and step-sets containing $0$ such that:

1. every triple of distinct indices $i,j,l$ satisfies $d_i + d_j + d_l \ge p$;
2. some triple attains $d_i + d_j + d_l = p$;
3. $\mathcal{R}(v,S) \ne \mathbb{F}_p^2$.

Hence the strict inequality in Theorem 4.1 cannot be weakened to $\le p$.

*Proof sketch.* Take the family of Theorem 5.3. Its deficiency profile is $(1,1,p-2,p-2,p-1,\dots,p-1)$. Any triple either contains at most two indices from $\{0,1\}$ — hence at least one deficiency $\ge p-2$ and two more each $\ge 1$, giving a sum $\ge p$ — or, if it contains both indices $0$ and $1$, contributes $1 + 1 + d_l \ge 1 + 1 + (p-2) = p$. The triple $(0,1,2)$ attains exactly $p$. Non-spanning is Theorem 5.3. $\square$

**Remark 5.6 (Corrected threshold).** Combining Theorem 5.3 with Corollary 4.2: the largest $D$-threshold valid for all pairwise independent configurations with $0 \in S_i$ is between $p-1$ and $(k-2)(p-1) - 1$. But this is the wrong question — Theorem 5.5 shows the honest invariant is not $D$ but $\min_{i<j<l}(d_i + d_j + d_l)$, for which the exact threshold $< p$ is now known.

---

## 6. When one step-set is everything

Although ($\ast$) is false in general, it is true under a natural extra hypothesis. The mechanism is a quotient argument coupled with the iterated Cauchy–Davenport inequality.

**Lemma 6.1 (Cauchy–Davenport).** For nonempty $A,B \subseteq \mathbb{F}_p$, $|A+B| \ge \min(p, |A|+|B|-1)$.

**Lemma 6.2 (Iterated representation form).** Let $I$ be a finite index set, $c_i \in \mathbb{F}_p^\times$ and $T_i \subseteq \mathbb{F}_p$ nonempty for $i \in I$. Then the set
$$A = \Bigl\{\textstyle\sum_{i\in I} c_i s_i : s_i \in T_i\Bigr\}$$
satisfies $|A| \ge \min\bigl(p,\ \sum_{i \in I}|T_i| + 1 - |I|\bigr)$.

*Proof sketch.* Induct on $|I|$. The empty case gives $A = \{0\}$ and the bound $\min(p,1) = 1$. For the inductive step, $A_{I \cup \{a\}} = c_a T_a + A_I$; multiplication by $c_a \ne 0$ is a bijection so $|c_aT_a| = |T_a|$, and Cauchy–Davenport gives $|A_{I\cup\{a\}}| \ge \min(p, |T_a| + |A_I| - 1)$, which combines with the inductive bound. $\square$

**Theorem 6.3 (The conjectured bound holds when one set is full).** Let $p$ be prime, $k \ge 2$, let $v$ be pairwise independent, let each $S_i \ni 0$, and suppose $S_{i_0} = \mathbb{F}_p$ for some index $i_0$. If
$$D(S) \le (k-2)(p-1),$$
then $\mathcal{R}(v,S) = \mathbb{F}_p^2$.

*Proof sketch.* Let $I = \{1,\dots,k\}\setminus\{i_0\}$, so $|I| = k-1$, and put $c_i = \det(v_i, v_{i_0})$, nonzero by pairwise independence. Because $S_{i_0}$ is full it contributes $0$ to $D(S)$, so $\sum_{i \in I}(p - |S_i|) = D(S) \le (k-2)(p-1)$, which rearranges to
$$\sum_{i \in I}|S_i| + 1 - |I| \;=\; (k-1)p - D(S) + 1 - (k-1) \;\ge\; p .$$
By Lemma 6.2 the set $A = \{\sum_{i \in I} c_i s_i : s_i \in S_i\}$ is all of $\mathbb{F}_p$. Now fix a target $t$. Choose $s_i \in S_i$ ($i \in I$) with $\sum_{i\in I} c_i s_i = \det(t, v_{i_0})$ and put $w = \sum_{i \in I} s_i v_i$. By bilinearity $\det(w, v_{i_0}) = \sum_{i\in I} c_i s_i = \det(t,v_{i_0})$, so $\det(t - w, v_{i_0}) = 0$ and hence $t - w = a\,v_{i_0}$ for some $a \in \mathbb{F}_p$ (using $v_{i_0} \ne 0$, which follows from pairwise independence and $k \ge 2$). Since $S_{i_0} = \mathbb{F}_p$, the coefficient $a$ is admissible, and $t = w + a v_{i_0} \in \mathcal{R}(v,S)$. $\square$

**Remark 6.4.** The computation in the proof shows the numerics are tight: $(k-2)(p-1)$ is *precisely* the largest deficiency for which the Cauchy–Davenport estimate over the $k-1$ non-distinguished directions still reaches $p$. This is a second, independent derivation of the conjectured threshold — and an explanation of why it looked inevitable.

---

## 7. What the conjectured bound really buys

Theorem 6.3 used the full set only in the last step, to slide along $v_{i_0}$. Dropping that hypothesis, the first part of the argument still delivers a genuine theorem for arbitrary configurations.

**Theorem 7.1 (Surjectivity onto every quotient line).** Let $p$ be prime, $k \ge 2$, let $v$ be pairwise independent and each $S_i \ni 0$, and suppose $D(S) \le (k-2)(p-1)$. Then for every index $i_0$ and every $c \in \mathbb{F}_p$ there is $r \in \mathcal{R}(v,S)$ with $\det(r, v_{i_0}) = c$. Equivalently, the image of $\mathcal{R}(v,S)$ in the quotient $\mathbb{F}_p^2 / \langle v_{i_0}\rangle \cong \mathbb{F}_p$ is everything.

*Proof sketch.* As in Theorem 6.3, put $I = \{1,\dots,k\}\setminus\{i_0\}$ and $c_i = \det(v_i,v_{i_0}) \ne 0$. Since $\sum_{i \in I}(p-|S_i|) \le D(S) \le (k-2)(p-1)$, Lemma 6.2 gives $\{\sum_{i\in I}c_is_i : s_i \in S_i\} = \mathbb{F}_p$. Choose $s_i \in S_i$ ($i \in I$) realising $c$ and set $s_{i_0} = 0 \in S_{i_0}$. The point $r = \sum_i s_i v_i$ lies in the reach and, because $\det(v_{i_0},v_{i_0}) = 0$, satisfies $\det(r, v_{i_0}) = \sum_{i \in I} c_i s_i = c$. $\square$

**Corollary 7.2 (No missing line).** Under the hypotheses of Theorem 7.1, for every $i_0$ and every $b \in \mathbb{F}_p^2$ there is $t \in \mathbb{F}_p$ with $b + t\,v_{i_0} \in \mathcal{R}(v,S)$. That is, the complement of the reach contains no full line in any of the $k$ directions.

*Proof sketch.* Apply Theorem 7.1 with $c = \det(b, v_{i_0})$ to get $r \in \mathcal{R}(v,S)$ with $\det(r - b, v_{i_0}) = 0$; then $r - b$ is a multiple of $v_{i_0}$. $\square$

**Remark 7.3.** Corollary 7.2 confines any counterexample to a sparse missed set: at most $p-1$ points on each line in each of the $k$ directions could conceivably be missed, but no line entirely. The harmonic family sits at the extreme opposite end of this range, missing a single point out of $p^2$ — a failure that is real but minimal.

---

## 8. The polynomial-method reformulation

We now explain analytically why $(k-2)(p-1)$ is the "right-looking" bound, and locate exactly the step that fails.

**Definition 8.1 (Coordinate linear forms).** For a direction family $v = (v_1,\dots,v_k)$ define, in the polynomial ring $\mathbb{F}_p[X_1,\dots,X_k]$,
$$L_1 = \sum_{i=1}^k (v_i)_1 X_i, \qquad L_2 = \sum_{i=1}^k (v_i)_2 X_i .$$
For $x \in \mathbb{F}_p^k$ one has $\bigl(L_1(x), L_2(x)\bigr) = \sum_i x_i v_i$, so hitting the target $t$ means solving $L_1 = t_1$, $L_2 = t_2$ with $x_i \in S_i$.

**Theorem 8.2 (Nonvanishing-coefficient criterion).** Let $p$ be prime and let $e = (e_1,\dots,e_k)$ be exponents with
$$e_i < |S_i| \ \ \text{for all } i, \qquad \sum_i e_i = 2(p-1) .$$
If the coefficient of $\prod_i X_i^{e_i}$ in $L_1^{\,p-1}L_2^{\,p-1}$ is nonzero, then $\mathcal{R}(v,S) = \mathbb{F}_p^2$.

*Proof sketch.* Fix a target $t$ and set
$$F = \bigl(1 - (L_1 - t_1)^{p-1}\bigr)\bigl(1 - (L_2 - t_2)^{p-1}\bigr) .$$
Expanding $F = 1 - A - B + AB$ with $A = (L_1-t_1)^{p-1}$, $B = (L_2-t_2)^{p-1}$: the terms $1$, $A$, $B$ have total degree $< 2(p-1)$ and so contribute nothing to the coefficient at $e$; and $AB$ differs from $L_1^{p-1}L_2^{p-1}$ only in degrees $< 2(p-1)$, because replacing a linear form $f$ by $f - c$ changes $f^n$ only below degree $n$. Hence the coefficient of $X^e$ in $F$ equals that in $L_1^{p-1}L_2^{p-1}$, which is nonzero by hypothesis; and $\deg F = 2(p-1) = \sum_i e_i$. The Combinatorial Nullstellensatz then supplies $x$ with $x_i \in S_i$ and $F(x) \ne 0$. Both factors of $F$ are then nonzero, and by Fermat's little theorem $1 - y^{p-1} \ne 0$ forces $y = 0$; thus $L_1(x) = t_1$ and $L_2(x) = t_2$, i.e. $\sum_i x_i v_i = t$. $\square$

**Definition 8.3 (Admissible exponent vector).** An exponent vector $e$ is *admissible* for $S$ if $e_i < |S_i|$ for all $i$ and $\sum_i e_i = 2(p-1)$.

**Theorem 8.4 (The degree budget equals the conjectured bound).** Let $p$ be prime, $k \ge 2$, and let each $S_i$ be nonempty. An admissible exponent vector exists **if and only if**
$$D(S) \le (k-2)(p-1).$$

*Proof sketch.* The maximum available total exponent is $\sum_i (|S_i| - 1)$, and
$$\sum_i (|S_i| - 1) = \sum_i \bigl((p-1) - d_i\bigr) = k(p-1) - D(S).$$
So a vector with $e_i \le |S_i|-1$ and $\sum_i e_i = 2(p-1)$ exists iff $k(p-1) - D(S) \ge 2(p-1)$, i.e. iff $D(S) \le (k-2)(p-1)$; the "if" direction is realised by greedily filling the caps $|S_i|-1$ until the total $2(p-1)$ is reached. $\square$

**Theorem 8.5 (Structure of the conjecture).** Under $D(S) \le (k-2)(p-1)$ with all $S_i$ nonempty, an admissible exponent vector $e$ always exists, and any admissible $e$ whose coefficient in $L_1^{p-1}L_2^{p-1}$ is nonzero proves $\mathcal{R}(v,S) = \mathbb{F}_p^2$. Consequently the conjecture ($\ast$) can fail **only** through the simultaneous vanishing of *all* admissible coefficients.

*Proof sketch.* Combine Theorems 8.4 and 8.2. $\square$

**Remark 8.6 (What happens in the counterexamples).** In the harmonic family the caps are $|S_i| - 1 = (p-2, p-2, 1, 1, 0, \dots, 0)$, summing to exactly $2(p-1)$: there is precisely *one* admissible exponent vector, namely $e = (p-2, p-2, 1, 1, 0,\dots,0)$, and its coefficient in $L_1^{p-1}L_2^{p-1}$ vanishes. The counterexample is thus not a violation of the polynomial method but a *witness that the method's hypothesis is strictly stronger than the degree count* — the conjecture ($\ast$) was the degree count mistaken for the hypothesis.

---

## 9. Algorithms

The results above are effective, and the following procedures make them so.

**Algorithm A (Reach computation by iterated sumset).** Given $p$, directions $v_1,\dots,v_k$ and step-sets $S_i$, compute $\mathcal{R}$ by starting from $\{(0,0)\}$ and repeatedly forming $\{r + s v_i : r \in \mathcal{R}_{\text{partial}}, s \in S_i\}$. Each stage costs $O(p^2 \cdot |S_i|)$ set operations and the accumulator never exceeds $p^2$ elements, so the total cost is $O\bigl(p^2 \sum_i |S_i|\bigr) = O(kp^3)$, versus $O\bigl(\prod_i |S_i|\bigr)$ for naive enumeration.

**Algorithm B (Spanning certificate).** Given a configuration, sort the deficiencies and test $d_{(1)} + d_{(2)} + d_{(3)} < p$. If it holds, output "spans" together with the explicit witness triple; by Theorem 4.1 this is a proof. Cost: $O(k\log k)$ after computing set sizes. This is the fastest available certificate and requires no computation in the plane at all.

**Algorithm C (Explicit representation along a triple).** Given a target $t$ and a certified triple $(i,j,l)$, compute $\alpha,\beta,\gamma,\delta$ by Cramer's rule and scan $c \in \mathbb{F}_p$ until $c \in S_l$, $\alpha - \gamma c \in S_i$ and $\beta - \delta c \in S_j$. Theorem 3.1 guarantees success within $d_i + d_j + d_l + 1 \le p$ trials, so the cost is $O(p)$ field operations — an effective, worst-case-linear inversion of the three-line theorem.

**Algorithm D (Admissible-coefficient search).** Expand $L_1^{p-1}L_2^{p-1}$ as a sparse polynomial over $\mathbb{F}_p$ and inspect the coefficients at all admissible exponent vectors. A nonzero one is a spanning certificate valid even when no triple criterion applies. The expansion has at most $\binom{k + 2p - 3}{2p-2}$ monomials, so this is exponential in $p$ in general but entirely practical for the small parameters where the phenomenon lives.

---

## 10. Computational evidence

Exhaustive and targeted computations support and sharpen the theory.

* **Three-line theorem, exhaustively.** Over all pairwise independent triples of directions and all step-sets containing $0$: at $p=3$, all $88$ configurations with $D < p$ span; at $p=5$, all $15{,}880$ do. At $D = p$ exactly, non-spanning configurations appear ($80$ at $p=3$, $14{,}400$ at $p=5$), so $D < p$ is exactly the right hypothesis.
* **The counterexample family.** For $(p,k) \in \{(3,4),(5,4),(5,6),(7,5),(7,8),(11,6)\}$ the harmonic family is pairwise independent, has $D = (k-2)(p-1)$ exactly, and misses precisely the single point $(1,2)$.
* **Triple sharpness.** In the same family the minimum triple deficiency is exactly $p$ for every tested $(p,k)$, confirming Theorem 5.5 numerically.
* **Quotient-line surjectivity.** For the counterexamples the image of the reach in each of the $k$ quotient lines has size exactly $p$ — the reach meets every line in every direction, as Theorem 7.1 requires.
* **One full set.** At $p=5$, $k=4$, all $3{,}797$ configurations with $S_1 = \mathbb{F}_5$ and $D \le 8$ span, in accordance with Theorem 6.3.
* **Coefficient vanishing.** For the harmonic counterexamples the unique admissible exponent vector has coefficient $0$ in $L_1^{p-1}L_2^{p-1}$; for a nearby spanning configuration at $p=5$, $k=4$ (with $D = 7 < 8$) there are three nonzero admissible coefficients.

---

## 11. Applications

**Covering and reachability with restricted alphabets.** A transmitter that can add rank-one contributions along $k$ fixed directions, each with a restricted alphabet, reaches every state of a two-dimensional register precisely when the reach is everything. Algorithm B gives an $O(k \log k)$ admissibility test, and Algorithm C an $O(p)$ decoder.

**Blocking configurations in finite planes.** The harmonic family produces, for every odd prime and every admissible $k$, a set of $p^2 - 1$ points that is a restricted sumset along $k$ directions and yet blocks a single point — an extremal object whose missed set contains no whole line in any of the given directions.

**Auxiliary-class exclusion arguments.** In classification problems where one wishes to exclude a *profile* of class sizes by showing that a corresponding spread must cover the plane, the conjecture ($\ast$) would have provided a uniform exclusion tool. Theorem 5.3 shows it cannot: in particular, the $p = 5$ profile $(8,2,2,2,2,2)$ cannot be excluded by ($\ast$), since the numerics of ($\ast$) are satisfied by non-spanning configurations. Theorem 4.1 gives the correct replacement tool, but with a genuinely stronger hypothesis.

**Design of step-set allocations.** Given a fixed deficiency budget, Theorems 4.1 and 5.5 say how to spend it: keep three of the deficiencies small, with sum below $p$. Concentrating the budget in the pattern $(1,1,p-2,p-2)$ on a harmonic quadruple is the uniquely wasteful allocation.

---

## 12. Discussion

The failure of ($\ast$) is a failure of *aggregation*. Total deficiency is a single scalar, while spanning is a projective-geometric property, and the harmonic quadruple is precisely a configuration in which a large budget is spent so as to create a genuine obstruction rather than diffuse slack. Two facts make this vivid.

First, the correct criterion is *local*: three directions with a joint deficiency budget below $p$ suffice, regardless of how impoverished the remaining $k-3$ directions are. Locality is the reason the criterion is robust; aggregation is the reason ($\ast$) is not.

Second, both natural derivations of $(k-2)(p-1)$ — the polynomial-method degree budget and the iterated Cauchy–Davenport count in a quotient line — are *correct as far as they go*. The degree count is exactly right (Theorem 8.4) and the quotient count is exactly right (Theorem 7.1); each simply proves a weaker conclusion than ($\ast$) claims. It is a good example of a conjecture that is not a wild guess but the conflation of a necessary condition with a sufficient one.

The overall picture is now complete in the following sense. For all $k$ and all $p$:

| Hypothesis | Conclusion | Status |
|---|---|---|
| $d_i + d_j + d_l < p$ for some triple | reach is $\mathbb{F}_p^2$ | true, and sharp |
| $D \le p-1$ | reach is $\mathbb{F}_p^2$ | true (special case of the above) |
| $D \le (k-2)(p-1)$ and some $S_{i_0} = \mathbb{F}_p$ | reach is $\mathbb{F}_p^2$ | true, and the numerics are tight |
| $D \le (k-2)(p-1)$ | reach meets every line in every direction $v_i$ | true |
| $D \le (k-2)(p-1)$ | reach is $\mathbb{F}_p^2$ | **false** for all $k \ge 4$, $p \ge 3$ |

---

## 13. Future directions

**Profile dichotomy for spanning.** Fix $p$ and $k \ge 3$. Conjecturally, a deficiency profile $d_1 \le \cdots \le d_k$ (with $0 \le d_i \le p-1$) admits *some* pairwise independent non-spanning configuration if and only if $d_1 + d_2 + d_3 \ge p$ **and** the profile avoids an explicitly describable list of exceptions. The condition "the three smallest sum to at least $p$" is exactly the failure of Theorem 4.1, hence necessary; enumeration shows it is not sufficient. Every exception observed so far — $(0,2,3,3)$, $(1,2,2,2)$ and $(2,2,2,2)$ at $p=5$; $(1,3,3,4)$ at $p=7$ — is a profile in which no four indices can be arranged into a harmonic cross-ratio pattern with the available set sizes. The obstruction is projective, not merely numerical, and identifying it exactly is the central open problem.

**Cross-ratio invariants.** The harmonic quadruple is characterised by cross-ratio $-1$. Is a non-spanning configuration at the extremal deficiency necessarily supported on a quadruple in harmonic position, up to projective equivalence? If so, the exception list of the profile dichotomy would be computable from the geometry of $\mathbb{P}^1(\mathbb{F}_p)$ alone.

**Higher dimensions.** The three-line pencil argument generalises to $\mathbb{F}_p^n$ with $n+1$ directions in general position: is the correct criterion "some $(n+1)$-subset has deficiency sum $< p$"? The counting is suggestive, but the covering argument uses the one-dimensionality of the fibre in an essential way.

**Non-prime moduli and general abelian groups.** Cauchy–Davenport fails over $\mathbb{Z}/m\mathbb{Z}$ for composite $m$; the Kneser and Davenport–Erdős–Kneser theory replaces it with a stabiliser-corrected bound. The natural analogue of Theorem 4.1 would read: the reach is everything unless a coset of a proper subgroup obstructs. Formulating and proving the correct statement, with the subgroup correction, is open.

**Quantitative refinement of "no missing line".** Corollary 7.2 shows a counterexample cannot miss a whole line. The harmonic family misses exactly one point. Is *one* the maximum? That is: under $D \le (k-2)(p-1)$, is $|\mathbb{F}_p^2 \setminus \mathcal{R}(v,S)| \le 1$ always? Computation supports this for small $p$ and $k$, and a proof would show the conjecture ($\ast$) is false only in the mildest conceivable way.

**Effective inverse theory.** Given a non-spanning configuration, can one read off the missed point from the direction family and the set sizes in $O(k)$ time? For the harmonic family, the answer is $(1,2)$ up to the obvious projective normalisation; a general answer would turn the counterexample construction into a classification.

---

## 14. Summary of results

Let $p$ be prime, $v_1,\dots,v_k$ pairwise independent directions in $\mathbb{F}_p^2$, $S_i \ni 0$ step-sets, $d_i = p - |S_i|$ and $D = \sum_i d_i$.

1. **(Three-line theorem.)** For $k=3$: $d_1+d_2+d_3 < p$ implies $\mathcal{R} = \mathbb{F}_p^2$. Sharp.
2. **(Triple criterion.)** For any $k \ge 3$: if some three distinct indices have $d_i+d_j+d_l < p$ then $\mathcal{R} = \mathbb{F}_p^2$. In particular $D \le p-1$ suffices.
3. **(Refutation.)** For every prime $p \ge 3$ and every $k$ with $4 \le k \le p+1$ there is a configuration with $D = (k-2)(p-1)$ and $\mathcal{R} \ne \mathbb{F}_p^2$; the conjectured threshold is therefore invalid throughout the feasible range.
4. **(Optimality.)** In that same family every triple has $d_i+d_j+d_l \ge p$ with equality attained, so the criterion of (2) cannot be relaxed.
5. **(One full set.)** If some $S_{i_0} = \mathbb{F}_p$, then $D \le (k-2)(p-1)$ does imply $\mathcal{R} = \mathbb{F}_p^2$.
6. **(Quotient surjectivity.)** $D \le (k-2)(p-1)$ implies the reach meets every line parallel to every $v_i$; equivalently the missed set contains no line.
7. **(Polynomial method.)** $(k-2)(p-1)$ is exactly the degree budget making an admissible monomial of $L_1^{p-1}L_2^{p-1}$ available; a nonzero admissible coefficient certifies spanning, and the conjecture can fail only by simultaneous vanishing of all such coefficients — as it does in the harmonic family, where a unique admissible monomial has coefficient zero.
