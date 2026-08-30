# Completeness, Compactness and Exact Fibonacci Covering Combinatorics of the First-Disagreement Truth Space

**Author:** Aristotle
**Date:** 2026-08-30

---

## Abstract

We study the space $\mathcal{C} = \{\texttt{0},\texttt{1}\}^{\mathbb{N}}$ of infinite binary *truth streams* — total assignments of yes/no answers to an enumerated sequence of queries — equipped with the **first-disagreement ultrametric** $d(x,y) = 2^{-\mathrm{fd}(x,y)}$, in which the closed ball of radius $2^{-n}$ about a stream is exactly its depth-$n$ prefix class. We prove that $(\mathcal{C},d)$ is **totally bounded**, with the explicit $2^{-n}$-net given by the $2^{n}$ depth-$n$ truncations; that it is **complete**, because Cauchy sequences stabilise coordinatewise and the coordinatewise limit is the metric limit; and hence that it is **compact**.

We then analyse the **golden-mean subshift** $\mathcal{G} \subseteq \mathcal{C}$, the set of streams containing no two consecutive $\texttt{1}$s. We show $\mathcal{G}$ is closed (hence compact), invariant under the $2$-Lipschitz shift map $\sigma$, and **perfect**, exhibiting for each admissible stream an explicit sequence of distinct admissible streams converging to it (a truncation and, when the truncation is degenerate, a truncation with a single isolated spike). Finally we determine the covering combinatorics of $\mathcal{G}$ *exactly at every dyadic scale*: the set of depth-$n$ prefixes of $\mathcal{G}$ coincides with the set of length-$n$ words avoiding $\texttt{11}$, whose cardinality is the Fibonacci number $F_{n+2}$; the $F_{n+2}$ closed balls of radius $2^{-n}$ centred at the zero-padded admissible words cover $\mathcal{G}$; and those same centres are pairwise at distance strictly greater than $2^{-n}$, so they form a matching $2^{-n}$-separated set. Covering number and packing number therefore coincide and equal $F_{n+2}$. Since $\varphi^{\,n} \le F_{n+2} \le \varphi^{\,n+1}$ with $\varphi = (1+\sqrt5)/2$, the box dimension of $\mathcal{G}$ is $\log\varphi/\log 2 = 0.69424\ldots$, versus $1$ for the ambient space.

We close by contrasting this metric deficit against a topological coincidence: $\mathcal{G}$ is nonempty, compact, perfect and totally disconnected, hence homeomorphic to $\mathcal{C}$ by Brouwer's characterisation of the Cantor set, so the dimension gap is invisible to the topology; while a fixed-point count ($2$ for $\sigma$ on $\mathcal{C}$, $1$ on $\mathcal{G}$) shows that the two shift dynamical systems are nevertheless non-conjugate. We discuss consequences for constrained hypothesis classes in learning theory, for run-length-limited coding, and for the thermodynamic formalism.

**Keywords.** Ultrametric space, Cantor space, compactness, total boundedness, subshift of finite type, golden-mean shift, Fibonacci numbers, box-counting dimension, topological entropy, covering and packing numbers.

---

## 1. Introduction

### 1.1 Motivation: hypothesis classes as metric spaces

A recurring pattern in learning theory, symbolic dynamics and constraint satisfaction is the following. One has an infinite family of *behaviours*, each behaviour being a total function from an enumerated set of queries to a finite answer alphabet; one has a notion of *finite observation*, namely the restriction of a behaviour to the first $n$ queries; and one wants to know how the number of distinguishable finite observations grows with $n$.

When the answer alphabet is $\{\texttt{0},\texttt{1}\}$ and the query set is $\mathbb{N}$, the family of all behaviours is the space $\mathcal{C} = \{\texttt{0},\texttt{1}\}^{\mathbb{N}}$, which we call the **truth space**. Its natural geometry is not Euclidean but *ultrametric*: two behaviours are close precisely when they cannot be distinguished by a short interrogation. Formalising "how short" as a distance gives the first-disagreement metric, whose balls are exactly the observation classes. Under this metric the truth space is compact, and this compactness is the abstract reason why the infinite family is controlled by a sequence of finite ones.

The purpose of this paper is twofold. First, to give a clean, self-contained development of the metric structure of $\mathcal{C}$ — completeness, total boundedness, compactness — with explicit, constructive witnesses at every step, rather than by appeal to Tychonoff's theorem or the general theory of inverse limits. Second, to carry out the same programme for a genuinely constrained subfamily, the golden-mean subshift, and to compute its covering combinatorics *exactly*, not merely up to constants.

### 1.2 What is proved

The main theorems, in order of appearance, are:

1. **Ball–prefix dictionary.** $d(x,y) \le 2^{-n}$ if and only if $x$ and $y$ agree on coordinates $0,\dots,n-1$. Consequently $\operatorname{diam}\mathcal{C} \le 1$.
2. **Total boundedness.** For each $n$, the $2^{n}$ depth-$n$ truncations form a $2^{-n}$-net for $\mathcal{C}$.
3. **Completeness.** Every Cauchy sequence in $\mathcal{C}$ stabilises coordinatewise; the coordinatewise stabilisation is its limit.
4. **Compactness.** $(\mathcal{C},d)$ is a compact metric space.
5. **Shift regularity.** The shift $\sigma$ satisfies $d(\sigma x, \sigma y) \le 2\,d(x,y)$ and is continuous.
6. **Closedness of the subshift.** $\mathcal{G}$ is closed, hence compact; and $\sigma(\mathcal{G}) \subseteq \mathcal{G}$.
7. **Perfectness.** $\mathcal{G}$ has no isolated points, with explicit approximants.
8. **Fibonacci word count.** The admissible words of length $n$ number $F_{n+2}$.
9. **Exact prefix realisation.** The depth-$n$ prefixes of points of $\mathcal{G}$ are precisely the admissible words of length $n$; hence $|\pi_n(\mathcal{G})| = F_{n+2}$.
10. **Matched covering and packing.** $\mathcal{G}$ is covered by $F_{n+2}$ closed $2^{-n}$-balls whose centres lie in $\mathcal{G}$ and are pairwise $>2^{-n}$ apart.

From (10) one reads off the box dimension $\log\varphi/\log 2$ and the topological entropy $\log\varphi$.

### 1.3 Relation to classical results

Every ingredient here has a classical ancestor. That $\{0,1\}^{\mathbb N}$ is compact is Tychonoff's theorem; that a subshift is closed and shift-invariant is the definition of a subshift; that the golden-mean shift has entropy $\log\varphi$ is a standard computation with the adjacency matrix $\begin{pmatrix}1&1\\1&0\end{pmatrix}$, whose Perron eigenvalue is $\varphi$; that a nonempty compact perfect totally disconnected metric space is a Cantor set is Brouwer's theorem.

The contribution of the present development is *constructive sharpness*. Each existential statement is replaced by an explicit witness: the net is a named finite set of streams; the limit of a Cauchy sequence is written down coordinate by coordinate as a diagonal read-off; the near neighbour witnessing perfectness is a truncation or a truncation-plus-spike; and, most importantly, the covering number is not bounded but *computed*, with a matching packing certificate. Bounds of the form $C_1\varphi^n \le N(2^{-n}) \le C_2\varphi^n$ suffice for dimension; the equality $N(2^{-n}) = F_{n+2}$ is a strictly finer statement, and it is what allows the metric entropy of the system to be read off at every finite scale rather than only in the limit.

---

## 2. The truth space and its ultrametric

### 2.1 Definitions

**Definition 2.1 (Truth space).** Let $\mathcal{C} = \{\texttt{0},\texttt{1}\}^{\mathbb{N}}$ denote the set of all functions $x : \mathbb{N} \to \{\texttt{0},\texttt{1}\}$. We write $x_k$ for $x(k)$ and call $x$ a *truth stream*; $x_k$ is the answer to query $k$. We freely identify $\texttt{1}$ with "yes"/`true` and $\texttt{0}$ with "no"/`false`.

**Definition 2.2 (Agreement to depth $n$).** For $n \in \mathbb{N}$ and $x,y \in \mathcal{C}$, say $x$ and $y$ *agree to depth $n$*, written $x \equiv_n y$, if $x_k = y_k$ for all $k < n$. Note $x \equiv_0 y$ always holds, vacuously.

**Definition 2.3 (First disagreement).** For $x \ne y$ let
$$\mathrm{fd}(x,y) = \min\{k \in \mathbb{N} : x_k \ne y_k\},$$
which exists because the set is a nonempty subset of $\mathbb{N}$.

**Definition 2.4 (First-disagreement metric).**
$$d(x,y) = \begin{cases} 0, & x = y,\\ 2^{-\mathrm{fd}(x,y)}, & x \ne y.\end{cases}$$

$d$ takes values in $\{0\} \cup \{2^{-n} : n \in \mathbb{N}\} \subseteq [0,1]$.

**Proposition 2.5 ($d$ is an ultrametric).** $d$ is a metric and satisfies the strong triangle inequality $d(x,z) \le \max(d(x,y), d(y,z))$.

*Proof sketch.* Symmetry and $d(x,y)=0 \Leftrightarrow x=y$ are immediate. For the strong triangle inequality, observe that $\equiv_n$ is an equivalence relation for every $n$; if $x \equiv_m y$ and $y \equiv_n z$ then $x \equiv_{\min(m,n)} z$. Taking $m = \mathrm{fd}(x,y)$ and $n = \mathrm{fd}(y,z)$ (with the convention $\mathrm{fd} = \infty$ when the arguments coincide) yields $\mathrm{fd}(x,z) \ge \min(\mathrm{fd}(x,y),\mathrm{fd}(y,z))$, which is the claim after applying the antitone map $t \mapsto 2^{-t}$. $\square$

### 2.2 The ball–prefix dictionary

The single most useful fact about $d$ is that its closed balls are prefix classes.

**Theorem 2.6 (Ball–prefix dictionary).** For all $x,y \in \mathcal{C}$ and $n \in \mathbb{N}$,
$$d(x,y) \le 2^{-n} \iff x \equiv_n y.$$

*Proof sketch.* If $x = y$ both sides hold. Otherwise $d(x,y) = 2^{-\mathrm{fd}(x,y)}$, and $2^{-\mathrm{fd}(x,y)} \le 2^{-n}$ is equivalent to $\mathrm{fd}(x,y) \ge n$, which by minimality of $\mathrm{fd}$ is equivalent to $x_k = y_k$ for every $k < n$. $\square$

**Corollary 2.7 (Strict bounds also force agreement).** If $d(x,y) < 2^{-n}$ then $x \equiv_n y$. (Immediate from Theorem 2.6, since $<$ implies $\le$.)

**Corollary 2.8 (Bounded diameter).** $d(x,y) \le 1$ for all $x,y$. Indeed $x \equiv_0 y$ always, so Theorem 2.6 with $n = 0$ gives $d(x,y) \le 2^{0} = 1$.

Because $d$ takes only the values $2^{-n}$ and $0$, the closed ball of radius $2^{-n}$ and the open ball of radius $2^{-n+1}$ coincide; every ball is **clopen**, and two balls of equal radius are either identical or disjoint. The depth-$n$ prefix classes thus partition $\mathcal{C}$ into $2^{n}$ clopen pieces.

**Lemma 2.9 (Dyadic cofinality).** For every $\varepsilon > 0$ there is $n \in \mathbb{N}$ with $2^{-n} < \varepsilon$.

*Proof sketch.* $(1/2)^n \to 0$; choose $n$ with $(1/2)^n < \varepsilon$ and rewrite $(1/2)^n = 2^{-n}$. $\square$

Lemma 2.9 lets us verify every metric statement on the dyadic scales alone, which is what makes all subsequent arguments purely combinatorial.

---

## 3. Total boundedness

**Definition 3.1 (Truncation).** For $n \in \mathbb{N}$ and $x \in \mathcal{C}$, define $T_n x \in \mathcal{C}$ by
$$(T_n x)_k = \begin{cases} x_k, & k < n,\\ \texttt{0}, & k \ge n.\end{cases}$$

**Definition 3.2 (The depth-$n$ net).** For a word $s \in \{\texttt{0},\texttt{1}\}^{n}$ let $\iota_n(s) \in \mathcal{C}$ be the stream with $\iota_n(s)_k = s_k$ for $k<n$ and $\texttt{0}$ otherwise. Set $N_n = \iota_n\big(\{\texttt{0},\texttt{1}\}^n\big) \subseteq \mathcal{C}$, a set of exactly $2^n$ streams.

**Lemma 3.3.** $T_n x \in N_n$ for every $x$, and $x \equiv_n T_n x$.

*Proof sketch.* Take $s = (x_0,\dots,x_{n-1})$; then $\iota_n(s) = T_n x$ by cases on $k<n$ or $k \ge n$. Agreement to depth $n$ is the definition of $T_n$ on $k < n$. $\square$

**Theorem 3.4 (Total boundedness).** $(\mathcal{C},d)$ is totally bounded: for every $\varepsilon>0$ there is a finite set $F \subseteq \mathcal{C}$ with $\mathcal{C} = \bigcup_{p \in F} B(p,\varepsilon)$. Explicitly, one may take $F = N_n$ for any $n$ with $2^{-n} < \varepsilon$.

*Proof sketch.* Given $\varepsilon>0$, pick $n$ by Lemma 2.9 with $2^{-n} < \varepsilon$. For arbitrary $x$, the point $T_n x$ lies in the finite set $N_n$ (Lemma 3.3) and satisfies $x \equiv_n T_n x$, hence $d(x, T_n x) \le 2^{-n} < \varepsilon$ by Theorem 2.6. $\square$

The net is optimal: by the disjointness of depth-$n$ prefix classes, any $2^{-n}$-net for $\mathcal{C}$ must have at least $2^n$ elements, since a single closed $2^{-n}$-ball is a single prefix class.

---

## 4. Completeness

Completeness in an ultrametric space of sequences is a statement about *stabilisation*: Cauchy-ness at scale $2^{-n}$ literally says the first $n$ coordinates have frozen.

**Lemma 4.1 (Cauchy $\Rightarrow$ eventual agreement).** Let $(u^{(i)})_{i\in\mathbb{N}}$ be a Cauchy sequence in $\mathcal{C}$. Then for every $n$ there exists $N(n)$ such that
$$i,j \ge N(n) \implies u^{(i)} \equiv_n u^{(j)}.$$

*Proof sketch.* Apply the Cauchy criterion with $\varepsilon = 2^{-n} > 0$ to obtain $N(n)$ with $d(u^{(i)},u^{(j)}) < 2^{-n}$ for $i,j\ge N(n)$, then apply Corollary 2.7. $\square$

**Theorem 4.2 (Completeness).** $(\mathcal{C},d)$ is a complete metric space. Explicitly, with $N(\cdot)$ as in Lemma 4.1, the limit of $(u^{(i)})$ is the *diagonal read-off*
$$u^{\star}_k \;=\; u^{(N(k+1))}_k .$$

*Proof sketch.* We claim the key stabilisation property: for all $n$ and all $i \ge N(n)$, $u^{(i)} \equiv_n u^{\star}$. Fix such $i$ and let $k < n$. Put $m = \max\big(i, N(k+1)\big)$. Then:

- Since $i, m \ge N(n)$, Lemma 4.1 at depth $n$ gives $u^{(i)}_k = u^{(m)}_k$ (using $k<n$).
- Since $m, N(k+1) \ge N(k+1)$, Lemma 4.1 at depth $k+1$ gives $u^{(m)}_k = u^{(N(k+1))}_k = u^{\star}_k$ (using $k < k+1$).

Chaining, $u^{(i)}_k = u^{\star}_k$ for all $k<n$, which is the claim.

Now let $\varepsilon>0$; choose $n$ with $2^{-n}<\varepsilon$. For $i \ge N(n)$ we get $u^{(i)} \equiv_n u^\star$, hence $d(u^{(i)}, u^\star) \le 2^{-n} < \varepsilon$ by Theorem 2.6. So $u^{(i)} \to u^\star$. $\square$

The double use of the maximum index $m$ is what makes the diagonal argument work: it reconciles the two different "freezing times", one coming from the depth we are trying to certify and one coming from the coordinate we are reading off.

**Theorem 4.3 (Compactness).** $(\mathcal{C},d)$ is a compact metric space.

*Proof sketch.* A metric space is compact iff it is complete and totally bounded. Theorem 3.4 gives total boundedness of the whole space, Theorem 4.2 gives completeness; a totally bounded subset of a complete space with closed closure is compact, and $\mathcal{C}$ is closed in itself. $\square$

**Remark 4.4.** This is Tychonoff's theorem for the countable product $\{\texttt{0},\texttt{1}\}^{\mathbb{N}}$, but obtained without the axiom of choice beyond countable dependent choice implicit in extracting $N(\cdot)$; the metric route makes the compactness *quantitative*: the $\varepsilon$-covering number of $\mathcal{C}$ is exactly $2^{\lceil \log_2(1/\varepsilon)\rceil}$.

---

## 5. The shift map

**Definition 5.1 (Shift).** $\sigma : \mathcal{C} \to \mathcal{C}$, $(\sigma x)_k = x_{k+1}$.

**Lemma 5.2 (Splitting agreement).** $x \equiv_{n+1} y$ if and only if $x_0 = y_0$ and $\sigma x \equiv_n \sigma y$.

*Proof sketch.* Forward: take $k=0$ for the first clause; for the second, $(\sigma x)_k = x_{k+1}$ and $k+1 < n+1$. Backward: for $k < n+1$, case on $k=0$ (first clause) or $k = j+1$ (second clause at $j<n$). $\square$

**Theorem 5.3 (The shift is $2$-Lipschitz).** $d(\sigma x, \sigma y) \le 2\,d(x,y)$ for all $x,y \in \mathcal{C}$; consequently $\sigma$ is continuous.

*Proof sketch.* If $x=y$ both sides vanish. Otherwise write $m = \mathrm{fd}(x,y)$, so $d(x,y) = 2^{-m}$.

- If $m = 0$ then $d(x,y) = 1$ and $d(\sigma x,\sigma y) \le 1 \le 2$ by Corollary 2.8.
- If $m = r+1$ then $x \equiv_{r+1} y$, so by Lemma 5.2 $\sigma x \equiv_r \sigma y$, whence $d(\sigma x, \sigma y) \le 2^{-r} = 2\cdot 2^{-(r+1)} = 2\,d(x,y)$. $\square$

The constant $2$ is sharp: take $x = \texttt{01}\overline{\texttt{0}}$ and $y=\texttt{00}\overline{\texttt{0}}$, for which $d(x,y)=1/2$ and $d(\sigma x,\sigma y)=1$.

---

## 6. The golden-mean subshift

### 6.1 Definition and closedness

**Definition 6.1 (Golden-mean subshift).**
$$\mathcal{G} = \{x \in \mathcal{C} \;:\; \neg\,(x_k = \texttt{1} \wedge x_{k+1} = \texttt{1}) \text{ for all } k \in \mathbb{N}\}.$$

Equivalently, $\mathcal{G}$ is the set of streams avoiding the forbidden word $\texttt{11}$. It is the archetypal *subshift of finite type* with a single forbidden block of length $2$; its transition matrix is $A = \begin{pmatrix}1&1\\1&0\end{pmatrix}$.

**Proposition 6.2 (Nonemptiness).** The constant stream $\overline{\texttt{0}}$ lies in $\mathcal{G}$, so $\mathcal{G} \neq \emptyset$.

**Theorem 6.3 (Closedness).** $\mathcal{G}$ is a closed subset of $\mathcal{C}$.

*Proof sketch.* We show the complement is open. Let $x \notin \mathcal{G}$; then there is $k$ with $x_k = x_{k+1} = \texttt{1}$. Set $r = 2^{-(k+2)} > 0$ and let $y \in B(x,r)$. By Corollary 2.7, $x \equiv_{k+2} y$; since $k < k+2$ and $k+1 < k+2$, we get $y_k = x_k = \texttt{1}$ and $y_{k+1} = x_{k+1} = \texttt{1}$. Hence $y \notin \mathcal{G}$, i.e. $B(x,r) \subseteq \mathcal{C}\setminus\mathcal{G}$. $\square$

The proof exhibits the general mechanism: a constraint expressible as a conjunction, over all positions, of predicates each depending on finitely many coordinates defines a closed set, because a *violation* is finitely witnessed and therefore stable under sufficiently small perturbation.

**Corollary 6.4 (Compactness of the subshift).** $\mathcal{G}$ is compact, being a closed subset of the compact space $\mathcal{C}$ (Theorem 4.3).

**Proposition 6.5 (Shift invariance).** $\sigma(\mathcal{G}) \subseteq \mathcal{G}$.

*Proof sketch.* If $x \in \mathcal{G}$ and $(\sigma x)_k = (\sigma x)_{k+1} = \texttt{1}$, then $x_{k+1} = x_{k+2} = \texttt{1}$, contradicting $x \in \mathcal{G}$ at index $k+1$. $\square$

Thus $(\mathcal{G},\sigma)$ is a compact topological dynamical system with a $2$-Lipschitz (hence continuous) map.

### 6.2 Perfectness

**Definition 6.6 (Spiked truncation).** For $n \in \mathbb{N}$, $x \in \mathcal{C}$, define $S_n x \in \mathcal{C}$ by
$$(S_n x)_k = \begin{cases} x_k, & k<n,\\ \texttt{1}, & k = n+1,\\ \texttt{0}, & \text{otherwise.}\end{cases}$$
So $S_n x$ is the depth-$n$ truncation followed by $\texttt{0}$, then a single isolated $\texttt{1}$, then $\texttt{0}$s.

**Lemma 6.7 (Truncation preserves admissibility).** If $x \in \mathcal{G}$ then $T_n x \in \mathcal{G}$ for every $n$.

*Proof sketch.* Suppose $(T_n x)_k = (T_n x)_{k+1} = \texttt{1}$. Both entries being $\texttt{1}$ forces $k<n$ and $k+1<n$, so both equal the corresponding entries of $x$, contradicting $x \in \mathcal{G}$. $\square$

**Lemma 6.8 (Spiked truncation preserves admissibility).** If $x \in \mathcal{G}$ then $S_n x \in \mathcal{G}$.

*Proof sketch.* Suppose $(S_n x)_k = (S_n x)_{k+1} = \texttt{1}$ for some $k$. If $k<n$ and $k+1<n$, both entries come from $x$: contradiction. If $k<n$ and $k+1 = n$, then $(S_n x)_{k+1} = (S_n x)_n = \texttt{0}$ (since $n \neq n+1$), contradiction. If $k \ge n$, then $(S_n x)_k = \texttt{1}$ forces $k = n+1$; but then $(S_n x)_{k+1} = (S_n x)_{n+2} = \texttt{0}$, contradiction. $\square$

**Lemma 6.9 (Truncation and spike are distinct, and both are close).** $T_n x \ne S_n x$ (they differ at coordinate $n+1$), and both satisfy $x \equiv_n T_n x$ and $x \equiv_n S_n x$.

**Theorem 6.10 (Perfectness).** For every $x \in \mathcal{G}$ and every $\varepsilon>0$ there exists $y \in \mathcal{G}$ with $y \ne x$ and $d(x,y) < \varepsilon$. Hence $\mathcal{G}$ has no isolated points.

*Proof sketch.* Pick $n$ with $2^{-n}<\varepsilon$ (Lemma 2.9). Two cases.

- If $T_n x \ne x$, take $y = T_n x$: admissible by Lemma 6.7, distinct by assumption, and $d(x,y) \le 2^{-n} < \varepsilon$ by Lemma 6.9 and Theorem 2.6.
- If $T_n x = x$, take $y = S_n x$: admissible by Lemma 6.8, and $y \ne x$ because $y = x = T_n x$ would give $T_n x = S_n x$, contradicting Lemma 6.9; and again $d(x,y) \le 2^{-n} < \varepsilon$. $\square$

**Corollary 6.11 (No isolated point in the subspace topology).** For no $x \in \mathcal{G}$ and $\varepsilon>0$ is $\mathcal{G}\cap B(x,\varepsilon) = \{x\}$.

**Corollary 6.12 (Brouwer package).** $\mathcal{G}$ is nonempty, compact, perfect and totally disconnected (the last because $d$ takes values in the discrete set $\{0\}\cup\{2^{-n}\}$, so every ball is clopen and the ambient space is totally separated). By Brouwer's characterisation, $\mathcal{G}$ is homeomorphic to the Cantor set — and in particular to $\mathcal{C}$ itself.

---

## 7. Exact covering combinatorics

### 7.1 Admissible words

**Definition 7.1 (Admissible word).** A finite word $w \in \{\texttt{0},\texttt{1}\}^{*}$ is *admissible* if it contains no factor $\texttt{11}$, i.e. no index $i$ with $w_i = w_{i+1} = \texttt{1}$. Let $\mathcal{A}_n$ denote the set of admissible words of length $n$ and $A_n = |\mathcal{A}_n|$.

Admissibility is a chain condition on consecutive letters, and it is closed under taking suffixes (in particular tails) and, as we shall see, has a clean prefix-recursive description.

**Lemma 7.2 (Closure rules).**
(i) The empty word and every one-letter word are admissible.
(ii) If $w$ is admissible, so is $\texttt{0}w$.
(iii) If $w$ is admissible, so is $\texttt{1}\texttt{0}w$.
(iv) If $c\,w$ is admissible and $\neg(b = \texttt{1} \wedge c=\texttt{1})$, then $b\,c\,w$ is admissible.
(v) If $w$ is admissible so is its tail.

**Definition 7.3 (Recursive family).** Define finite sets $W_n$ by
$$W_0 = \{\varepsilon\},\qquad W_1 = \{\texttt{0},\texttt{1}\},\qquad W_{n+2} = \texttt{0}\cdot W_{n+1} \;\sqcup\; \texttt{10}\cdot W_{n},$$
where $b\cdot W$ denotes $\{bw : w\in W\}$.

**Theorem 7.4 (The recursion computes $\mathcal{A}_n$).** $W_n = \mathcal{A}_n$ for all $n$.

*Proof sketch.* Induction on $n$ with base cases $n = 0,1$ immediate. For the inductive step: the inclusion $W_{n+2} \subseteq \mathcal{A}_{n+2}$ follows from Lemma 7.2(ii),(iii) and the length bookkeeping. Conversely, let $w = b\,r$ be admissible of length $n+2$. If $b = \texttt{0}$, then $r$ is admissible of length $n+1$ (Lemma 7.2(v)), so $w \in \texttt{0}\cdot W_{n+1}$ by induction. If $b = \texttt{1}$, write $r = c\,r'$; admissibility of $w$ forces $c = \texttt{0}$, and $r'$ is admissible of length $n$, so $w \in \texttt{10}\cdot W_n$. $\square$

**Theorem 7.5 (Fibonacci count).** $A_n = F_{n+2}$, where $F_0=0$, $F_1=1$, $F_{k+2}=F_{k+1}+F_k$.

*Proof sketch.* The two families in Definition 7.3 are disjoint (their elements differ in the first letter), and each of the maps $w \mapsto \texttt{0}w$ and $w\mapsto \texttt{10}w$ is injective. Hence $A_{n+2} = A_{n+1} + A_n$, with $A_0 = 1 = F_2$ and $A_1 = 2 = F_3$. Induction and the Fibonacci recursion $F_{n+4} = F_{n+3}+F_{n+2}$ finish the proof. $\square$

The first values are
$$A_0,A_1,A_2,\dots = 1,\,2,\,3,\,5,\,8,\,13,\,21,\,34,\,55,\,89,\dots$$

### 7.2 Prefixes of subshift points

**Definition 7.6 (Prefix map).** $\pi_n : \mathcal{C} \to \{\texttt{0},\texttt{1}\}^{n}$ is defined recursively by $\pi_0(x) = \varepsilon$ and $\pi_{n+1}(x) = x_0 \cdot \pi_n(\sigma x)$. Then $|\pi_n(x)| = n$.

**Lemma 7.7 (Prefixes separate at scale $2^{-n}$).** $\pi_n(x) = \pi_n(y) \iff x \equiv_n y$, hence
$$d(x,y) \le 2^{-n} \iff \pi_n(x) = \pi_n(y).$$

*Proof sketch.* Induction on $n$ using $\pi_{n+1}(x) = x_0\cdot\pi_n(\sigma x)$, the injectivity of list-cons, and the splitting Lemma 5.2. Then apply Theorem 2.6. $\square$

**Lemma 7.8 (Prefixes of admissible streams are admissible).** If $x \in \mathcal{G}$ then $\pi_n(x) \in \mathcal{A}_n$ for all $n$.

*Proof sketch.* Induction on $n$. The step uses $\sigma x \in \mathcal{G}$ (Proposition 6.5), the inductive hypothesis for $\pi_n(\sigma x)$, and Lemma 7.2(iv) with $b = x_0$, $c = x_1$, the hypothesis $\neg(x_0 = x_1 = \texttt{1})$ coming from $x \in \mathcal{G}$ at index $0$. $\square$

**Definition 7.9 (Zero-padding).** For a word $w$ let $\widehat{w} \in \mathcal{C}$ be the stream $\widehat{w}_k = w_k$ for $k < |w|$ and $\texttt{0}$ otherwise.

**Lemma 7.10 (Padding preserves admissibility).** If $w \in \mathcal{A}_n$ then $\widehat{w} \in \mathcal{G}$.

*Proof sketch.* Induction on $w$. For $w = \varepsilon$ or $w$ a single letter, $\widehat{w}$ has at most one $\texttt{1}$, at position $0$, with $\texttt{0}$ after it. For $w = b\,c\,w'$: at index $0$ the pair $(b,c)$ is admissible by hypothesis, and at index $k+1$ the pair equals the index-$k$ pair of $\widehat{c\,w'}$, handled by induction. $\square$

**Lemma 7.11 (Padding is a section).** $\pi_{|w|}(\widehat{w}) = w$ for every finite word $w$.

*Proof sketch.* Induction on $w$, using $\sigma(\widehat{b w}) = \widehat{w}$. $\square$

**Theorem 7.12 (Exact prefix realisation).** For every $n$,
$$\pi_n(\mathcal{G}) = \mathcal{A}_n, \qquad\text{hence}\qquad |\pi_n(\mathcal{G})| = F_{n+2}.$$

*Proof sketch.* $\subseteq$ is Lemma 7.8. For $\supseteq$, given $w \in \mathcal{A}_n$ put $x = \widehat{w}$; then $x \in \mathcal{G}$ by Lemma 7.10 and $\pi_n(x) = w$ by Lemma 7.11 (using $|w| = n$). Cardinality is Theorem 7.5. $\square$

This is the *finite-scale spectrum* of the subshift: at resolution $2^{-n}$, an observer distinguishes exactly $F_{n+2}$ admissible behaviours, no more and no fewer.

### 7.3 Covering and packing coincide

**Theorem 7.13 (Optimal covering).** For every $n$,
$$\mathcal{G} \;\subseteq\; \bigcup_{w \in \mathcal{A}_n} \overline{B}\big(\widehat{w},\,2^{-n}\big),$$
a union of exactly $F_{n+2}$ closed balls whose centres all lie in $\mathcal{G}$.

*Proof sketch.* Given $x \in \mathcal{G}$, set $w = \pi_n(x) \in \mathcal{A}_n$ (Lemma 7.8). By Lemma 7.11, $\pi_n(\widehat{w}) = w = \pi_n(x)$, so $d(x,\widehat{w}) \le 2^{-n}$ by Lemma 7.7. The centres lie in $\mathcal{G}$ by Lemma 7.10. $\square$

**Theorem 7.14 (Matching packing).** If $v,w \in \mathcal{A}_n$ and $v \ne w$, then
$$d(\widehat{v},\widehat{w}) > 2^{-n}.$$

*Proof sketch.* Suppose not, so $d(\widehat v,\widehat w) \le 2^{-n}$. By Lemma 7.7, $\pi_n(\widehat v) = \pi_n(\widehat w)$. But $\pi_n(\widehat v) = v$ and $\pi_n(\widehat w) = w$ by Lemma 7.11 (both words have length $n$), so $v = w$, a contradiction. $\square$

**Corollary 7.15 (Exact metric entropy at every scale).** Let $N(\mathcal{G},\varepsilon)$ be the minimal number of closed $\varepsilon$-balls needed to cover $\mathcal{G}$, and $P(\mathcal{G},\varepsilon)$ the maximal cardinality of an $\varepsilon$-separated subset of $\mathcal{G}$. Then for every $n$,
$$N(\mathcal{G},2^{-n}) = P(\mathcal{G},2^{-n}) = F_{n+2}.$$

*Proof sketch.* Theorem 7.13 gives $N \le F_{n+2}$; Theorem 7.14 gives a $2^{-n}$-separated set of size $F_{n+2}$ inside $\mathcal{G}$, so $P \ge F_{n+2}$. Conversely, a closed $2^{-n}$-ball is exactly a depth-$n$ prefix class (Theorem 2.6), so it can contain at most one point of any $2^{-n}$-separated set, giving $P \le N$; and by Theorem 7.12 a cover by $2^{-n}$-balls must meet all $F_{n+2}$ nonempty prefix classes of $\mathcal{G}$, giving $N \ge F_{n+2}$. $\square$

### 7.4 Dimension and entropy

**Theorem 7.16 (Box dimension).** With $\varphi = (1+\sqrt5)/2$,
$$\dim_{\mathrm B}\mathcal{G} \;=\; \lim_{n\to\infty}\frac{\log N(\mathcal{G},2^{-n})}{\log 2^{\,n}} \;=\; \frac{\log\varphi}{\log 2} \;=\; 0.6942419\ldots$$

*Proof sketch.* By Corollary 7.15 the numerator is $\log F_{n+2}$. The Fibonacci sandwich $\varphi^{\,n} \le F_{n+2} \le \varphi^{\,n+1}$ (an easy induction from $\varphi^2 = \varphi+1$) gives
$$\frac{n\log\varphi}{n\log 2} \;\le\; \frac{\log F_{n+2}}{n\log 2} \;\le\; \frac{(n+1)\log\varphi}{n\log 2},$$
and both bounds tend to $\log\varphi/\log2$. $\square$

**Corollary 7.17 (Topological entropy).** The topological entropy of the shift on $\mathcal{G}$ is
$$h_{\mathrm{top}}(\sigma|_{\mathcal{G}}) = \lim_{n\to\infty}\frac{\log A_n}{n} = \log\varphi = 0.4812\ldots,$$
strictly less than the full-shift entropy $\log 2 = 0.6931\ldots$. Equivalently, the per-symbol capacity of the constraint is $\log_2\varphi \approx 0.6942$ bits.

*Proof sketch.* For a subshift, $h_{\mathrm{top}}$ is the exponential growth rate of the language, which by Theorem 7.5 is that of $F_{n+2}$, namely $\varphi$. Strictness holds since $\varphi<2$; equivalently $A_n = F_{n+2} < 2^n$ for $n \ge 1$. $\square$

For the ambient space the same computation with $N(\mathcal{C},2^{-n}) = 2^{n}$ gives $\dim_{\mathrm B}\mathcal{C} = 1$ and $h_{\mathrm{top}}(\sigma) = \log 2$.

---

## 8. Topological coincidence versus metric and dynamical difference

Three statements about the pair $(\mathcal{C},\mathcal{G})$ must be held simultaneously, and they pull in different directions.

**(a) Metrically, $\mathcal{G}$ is strictly thinner.** $\dim_{\mathrm B}\mathcal{G} = \log_2\varphi < 1 = \dim_{\mathrm B}\mathcal{C}$ (Theorem 7.16). The subshift occupies a set of Hausdorff and box dimension $0.694$ in a space of dimension $1$; in particular it has measure zero for the natural $1$-dimensional (i.e. Bernoulli$(1/2)$) measure on $\mathcal{C}$.

**(b) Topologically, they are the same space.** By Corollary 6.12 both are nonempty compact perfect totally disconnected metric spaces, hence both are Cantor sets, hence homeomorphic. There is even an explicit homeomorphism $\mathcal{C} \to \mathcal{G}$, the *golden substitution*, which reads the source stream letter by letter and emits
$$\texttt{0} \longmapsto \texttt{0},\qquad \texttt{1}\longmapsto \texttt{10},$$
automatically interposing the spacer that makes $\texttt{11}$ impossible. The map is injective (the images are uniquely decodable, since a $\texttt{1}$ always begins a block), surjective onto $\mathcal{G}$ (parse an admissible stream greedily), and bi-continuous (a depth-$n$ prefix of the input determines a prefix of the output of length between $n$ and $2n$, and conversely).

Consequently the dimension deficit is *not* a topological invariant of the pair; it is an artefact of the ruler. This is a sharp and concrete instance of a general principle: box and Hausdorff dimension are quasi-isometry-type invariants of the metric, not of the topology, and a homeomorphism can compress or dilate scales without bound.

**(c) Dynamically, they are rigidly different.** A conjugacy of dynamical systems is a homeomorphism intertwining the maps. Fixed points are a conjugacy invariant. The full shift $\sigma$ on $\mathcal{C}$ has exactly two fixed points, $\overline{\texttt{0}}$ and $\overline{\texttt{1}}$; on $\mathcal{G}$ it has exactly one, $\overline{\texttt{0}}$, since $\overline{\texttt{1}}$ violates the constraint. Since $1 \ne 2$, no shift-equivariant homeomorphism $\mathcal{C}\to\mathcal{G}$ exists. Counting period-$2$ points gives the next obstruction: $4$ for the full shift versus $3$ for the golden-mean shift ($\overline{\texttt{0}}$, $\overline{\texttt{10}}$, $\overline{\texttt{01}}$); more generally the period-$p$ counts of the golden-mean shift are the Lucas numbers $L_p = \operatorname{tr} A^{p}$, versus $2^p$ for the full shift.

So: **same shape, different ruler, different motion.** All of the content of the constraint sits in the metric and the dynamics, and none of it in the topology.

---

## 9. Algorithms

The proofs above are constructive and translate directly into algorithms.

### 9.1 Admissible-word enumeration (prefix recursion)

The recursion $W_{n+2} = \texttt{0}\cdot W_{n+1} \sqcup \texttt{10}\cdot W_n$ enumerates $\mathcal{A}_n$ with no rejection and no duplicates: it is an *exact-cover* enumeration, emitting each of the $F_{n+2}$ words once. Time is $\Theta(n\,F_{n+2}) = \Theta(n\varphi^{\,n})$ (output-linear up to the word length), space $O(n)$ if streamed.

The count alone can be obtained in $O(n)$ additions by iterating the Fibonacci recursion, or in $O(\log n)$ big-integer multiplications by fast matrix powering of $A = \begin{pmatrix}1&1\\1&0\end{pmatrix}$, using $A^{n} = \begin{pmatrix}F_{n+1}&F_n\\F_n&F_{n-1}\end{pmatrix}$.

### 9.2 Metric evaluation and net construction

Evaluating $d(x,y)$ for streams given as oracles reduces to scanning for the first disagreement; for streams that are eventually periodic this terminates in time proportional to the pre-period plus period. Constructing the optimal $2^{-n}$-net of $\mathcal{G}$ means enumerating $\mathcal{A}_n$ and zero-padding, by §9.1.

### 9.3 Cauchy stabilisation / diagonal limit

Given a Cauchy sequence presented with a modulus $N(\cdot)$, the limit is computed coordinatewise: $u^\star_k = u^{(N(k+1))}_k$. Each coordinate of the limit costs one evaluation, so the depth-$n$ prefix of the limit costs $n$ evaluations. This is the algorithmic content of Theorem 4.2 and makes the completeness proof an actual *program* for extracting limits.

### 9.4 Membership testing and closedness certificates

Testing $x \in \mathcal{G}$ is semi-decidable by scanning: if $x \notin \mathcal{G}$ the scan finds a witness index $k$ in finite time, and the proof of Theorem 6.3 then outputs the *radius certificate* $r = 2^{-(k+2)}$ guaranteeing that the whole ball $B(x,r)$ misses $\mathcal{G}$. This certificate is the computational content of closedness.

### 9.5 Greedy decoding of the golden substitution

To invert the substitution $\texttt{0}\mapsto\texttt{0},\ \texttt{1}\mapsto\texttt{10}$ on an admissible stream: scan left to right; on reading $\texttt{0}$ emit $\texttt{0}$ and advance one; on reading $\texttt{1}$ emit $\texttt{1}$ and advance two (the next letter is necessarily $\texttt{0}$). Linear time, one-pass, no backtracking — the code is *uniquely decodable* precisely because $\texttt{11}$ is forbidden.

---

## 10. Applications

### 10.1 Constrained hypothesis classes

Read a truth stream as the behaviour of a total binary predictor on an enumerated query sequence. The full class $\mathcal{C}$ has $2^n$ distinguishable depth-$n$ behaviours — the maximum possible growth function, corresponding to shattering every prefix. Imposing the golden-mean constraint reduces this to $F_{n+2} \sim \varphi^{n+1}/\sqrt5$, so the *effective* number of hypotheses at resolution $n$ grows at rate $\varphi$ rather than $2$: the class loses $ (1-\log_2\varphi)n \approx 0.306\,n$ bits of expressive capacity by depth $n$. Because Corollary 7.15 gives the covering number *exactly*, the associated metric-entropy quantities carry no unspecified constants.

Compactness is what makes such a class analytically tractable at all: any infinite family of behaviours has a subsequence converging (coordinatewise, hence in the metric) to a limit behaviour, and any continuous risk functional attains its infimum on the class.

### 10.2 Online prediction and the minimax rate

Consider a forecaster predicting the next answer of an unknown golden-mean stream. The trivial predictor that always answers $\texttt{0}$ makes at most $\lceil n/2 \rceil$ mistakes in $n$ rounds against *every* admissible stream, because a $\texttt{1}$ must be followed by a $\texttt{0}$ and hence at most half the positions (rounded up) carry $\texttt{1}$s: precisely, $2\cdot\#\{k<n: x_k=\texttt{1}\} \le n+1$, with equality attained by the alternating stream $\overline{\texttt{10}}$. Conversely an adversary can force $\lfloor n/2\rfloor$ mistakes against any deterministic forecaster, by answering $\texttt{1}$ whenever the forecaster says $\texttt{0}$ and the constraint permits it, and $\texttt{0}$ otherwise. The minimax mistake rate is therefore exactly $1/2$ per round: the constraint halves the density of positive answers but does not, by itself, make them predictable.

### 10.3 Run-length-limited codes

The golden-mean constraint is the $(d,k) = (1,\infty)$ run-length-limited constraint of magnetic and optical recording: no two marks in adjacent cells. Corollary 7.17 says its Shannon capacity is $\log_2\varphi \approx 0.6942$ bits per cell — the highest achievable rate of any code respecting the constraint. Theorem 7.12 makes this exact at finite blocklength: there are precisely $F_{n+2}$ legal codewords of length $n$, so a rate-$R$ block code of length $n$ exists iff $2^{nR} \le F_{n+2}$.

### 10.4 Hard-square models and quasicrystals

In one-dimensional statistical mechanics, $\mathcal{G}$ is the configuration space of a hard-core lattice gas with nearest-neighbour exclusion; the partition function of length $n$ is $F_{n+2}$ at infinite temperature and, more generally, $\operatorname{tr}$-like sums over $A$ weighted by activity. In the theory of aperiodic order, the golden substitution $\texttt{0}\mapsto\texttt{0}$, $\texttt{1}\mapsto\texttt{10}$ that implements the homeomorphism of §8(b) is exactly the Fibonacci substitution whose fixed point generates the canonical one-dimensional quasicrystal.

---

## 11. Discussion

### 11.1 Why exactness is worth the trouble

Dimension computations customarily need only $N(\varepsilon) = \varepsilon^{-s+o(1)}$. The results here give more: at every dyadic scale, an exact integer with a matching lower bound certificate. Three benefits follow. First, finite-blocklength coding statements become exact rather than asymptotic. Second, the covering and packing numbers agree, which is unusual — generally they differ by a bounded factor — and here follows from the ultrametric fact that balls of a given radius partition the space. Third, exactness makes the whole hierarchy of counting invariants (words, cylinders, periodic points) computable and comparable, which is what allows the dynamical rigidity of §8(c) to be detected at all.

### 11.2 The role of the ultrametric

Nearly every proof above is shorter than its Euclidean analogue, and the reason is always the same: $\equiv_n$ is an equivalence relation and closed $2^{-n}$-balls are its classes. Total boundedness becomes "there are $2^n$ classes"; completeness becomes "Cauchy means the class eventually stops changing"; closedness of $\mathcal{G}$ becomes "a violation lives in one class"; covering = packing becomes "classes are disjoint". The ultrametric is not a technical convenience but the correct model of *finite interrogation*, in which the only thing an observer can ever learn is which class a point lies in.

### 11.3 Limitations

The results are specific to the binary alphabet and to a single forbidden word of length $2$. The word-count recursion generalises to any subshift of finite type — the count of length-$n$ words is $\mathbf{1}^{\mathsf T}A^{n-1}\mathbf{1}$ for the transition matrix $A$, growing at the Perron rate $\lambda(A)$ — but the *exact* covering-equals-packing statement uses only the ultrametric structure and so does generalise verbatim: for any subshift $X$ over a finite alphabet $\Sigma$ with the first-disagreement metric, $N(X, |\Sigma|^{-n}) = P(X,|\Sigma|^{-n}) = |\mathcal{L}_n(X)|$, the number of length-$n$ words in the language. What is special about the golden-mean case is that this number is a Fibonacci number, computable in closed form.

A second limitation: nothing here addresses measures. The Parry (measure of maximal entropy) measure on $\mathcal{G}$, its Hausdorff-measure normalisation, and the corresponding multifractal spectrum are outside the present scope.

---

## 12. Future directions

Twelve completed cycles of the broader research programme, all built on the first-disagreement ultrametric, suggest the following continuations.

* **Completeness, total boundedness, compactness** of the truth space; the golden-mean subshift is closed, compact and perfect; its length-$n$ prefix set is exactly the $F_{n+2}$ admissible words, realising both a covering and a matching packing at scale $2^{-n}$. *(The present paper.)*
* **Discrete distance spectrum and dimension.** The distance function takes values in a discrete set, so cylinders are clopen and the space is totally separated; the subshift is uncountable and nowhere dense; the sandwich $\varphi^{\,n} \le F_{n+2} \le \varphi^{\,n+1}$ yields box dimension $\log\varphi/\log 2$.
* **Explicit homeomorphism.** The golden substitution $\texttt{0}\mapsto\texttt{0}$, $\texttt{1}\mapsto\texttt{10}$ is a homeomorphism from the full truth space onto the subshift: the smaller box dimension is invisible to the topology.
* **Languages and closed sets.** Prefix conditions are clopen, so a prefix language always defines a closed set, and conversely a closed set is recovered from its prefix language; specialising recovers the subshift as $\{x : \pi_n(x)\text{ admissible for all }n\}$. A König-lemma argument realises every extendable language by infinite streams.
* **Devaney chaos.** Gluing two admissible words with a single spacer letter is the combinatorial engine of the system; it yields dense periodic points, topological transitivity, and sensitive dependence with the maximal sensitivity constant $1$.
* **Entropy and Fekete inequalities.** The same gluing map, together with closure under factors, gives the two Fekete inequalities by explicit injections, hence combinatorial proofs of $F_{n+2}F_{m+2}\le F_{n+m+3}$ and $F_{n+m+2}\le F_{n+2}F_{m+2}$; exponential sparseness $A_n < 2^n$; the entropy gap $\log\varphi<\log2$; and the sharp density bound $2\,\#\{\text{ones}\}\le n+1$, attained by the alternating word.
* **Minimax online mistake bound.** The predictor that always answers $\texttt{0}$ errs at most $(n+1)/2$ times against every admissible stream, and an explicit adversary forces at least $n/2$ mistakes against every deterministic predictor; the minimax rate is $1/2$ per round.
* **Dynamical rigidity.** The full shift has two fixed points and the golden-mean shift has one, so no shift-equivariant bijection exists: the spaces are homeomorphic but the dynamics are rigidly non-conjugate. The golden-mean shift is surjective but not injective.
* **Explicit transitive point.** The concatenation of all admissible words separated by buffer letters has dense forward orbit, upgrading transitivity to its strongest classical form; yet the subshift is not minimal.
* **Beyond:** period-$p$ counts as Lucas numbers and the full zeta function $\zeta(t) = 1/\det(I - tA)$; the Parry measure and multifractal analysis; general subshifts of finite type and sofic shifts, where the covering-equals-packing identity persists and the growth rate becomes the Perron eigenvalue; and quantitative learning-theoretic consequences of exact covering numbers for constrained hypothesis classes.

---

## 13. Conclusion

The space of infinite yes/no answer streams, metrised by first disagreement, is a compact ultrametric space whose closed balls are exactly the finite-interrogation classes. Completeness holds because Cauchy sequences freeze coordinatewise; total boundedness holds because there are only $2^n$ prefixes of length $n$. Imposing the local rule "never two consecutive yeses" carves out a closed, hence compact, shift-invariant, perfect subset — a Cantor set in its own right — whose finite-scale geometry is known exactly: $F_{n+2}$ balls of radius $2^{-n}$ cover it, $F_{n+2}$ points inside it are pairwise farther apart than $2^{-n}$, and these numbers match. The growth rate $\varphi$ of that count is simultaneously the box dimension exponent, the topological entropy, and the coding capacity of the constraint.

The final picture is a study in what different invariants can and cannot see. The topology sees nothing: constrained and unconstrained spaces are homeomorphic. The metric sees a $30.6\%$ dimension deficit. The dynamics sees an unbridgeable rigidity, detected by a count as simple as the number of fixed points. Same shape, different ruler, different motion.
