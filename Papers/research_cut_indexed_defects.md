# Cut-Indexed Defects: A Finite Cut-Data Theory of the Singleton Bound, its Entropic Refinement, and its Quantum Avatar

**Author:** Aristotle

**Date:** 2026-08-23

---

## Abstract

We isolate the purely finite, order-theoretic content of the notion of *bond dimension across a cut* in a tensor network, and show that it suffices to prove a family of Singleton-type inequalities indexed by cuts. A **cut datum** on $n$ sites with local dimension $q$ is a function $r$ from subsets of $\{1,\dots,n\}$ to the natural numbers, together with a total dimension $\mathrm{tot}$, subject to three axioms: $r(\varnothing)\le 1$, monotonicity, and one-site growth $r(S\cup\{a\})\le q\,r(S)$. Calling a cut datum *$d$-resolving* when $n-|S|<d$ forces $r(S)=\mathrm{tot}$, we prove the **cut-wise Singleton inequality**
$$\mathrm{tot}\;\le\;q^{\,k-|S|}\,r(S), \qquad k:=n+1-d,\quad |S|\le k,$$
whose specialisation at $S=\varnothing$ is the classical Singleton bound, and a **rigidity theorem**: saturation $\mathrm{tot}=q^{k}$ forces $r(S)=q^{|S|}$ at every cut below the plateau.

Instantiating at the cut rank of a finite codebook recovers, as corollaries, the Singleton bound, the theorem that every $k$ coordinates of an MDS code form an information set, and an exact balanced-fibre count. We then build the **entropic mirror** of the axiom system for the Shannon entropy $H(S)$ of the marginal that the uniform distribution on a code induces on a cut: $H(\varnothing)=0$, monotonicity $S\subseteq T\Rightarrow H(S)\le H(T)$, and a chain-rule bound $H(T)\le H(S)+(|T|-|S|)\log q$. From the mirror we deduce the **entropic cut-wise Singleton inequality**
$$\log|C|\;\le\;H(S)+(k-|S|)\log q,$$
which implies the counting version and is strictly sharper whenever the cut marginal is non-uniform; the key analytic input is a relativised grouping (log-sum) inequality proved here. We show the entropy profile of an MDS code is exactly the plateau $H(S)=\min(|S|,k)\log q$, and that the vanishing of the entropic defect at a *single* cut of size $k$ characterises the MDS property.

Finally, promoting a codebook to the uniform superposition state $|C\rangle$, we prove a **quantum cut-wise Singleton inequality** $E(S)\le\min(|S|,k)\log q$ for the entanglement entropy, and show that MDS code states saturate it exactly in the regime $|S|\le\min(k,d-1)$, where the reduced density matrix is maximally mixed. A three-bit example demonstrates that the guard $|S|<d$ is sharp: the quantum profile is a *tent*, forced down by global purity, whereas the classical profile is a monotone *staircase*. We also exhibit a five-word code showing that the cut rank is not submodular, in contrast with the cut entropy.

**Keywords:** cut data, bond dimension, Singleton bound, MDS codes, cut entropy, grouping inequality, entanglement entropy, tensor networks, information sets, polymatroid.

---

## 1. Introduction

### 1.1 Bond dimension as a combinatorial invariant

A tensor network on $n$ sites with local dimension $q$ associates to each bipartition of the sites a *bond dimension*: the number of internal degrees of freedom that must cross the cut for the two halves to reconstruct the global object. In the theory of matrix product states this is the size of the virtual index; in the theory of error-correcting codes the same quantity, applied to the set of restrictions of codewords, controls generalised Hamming weights; in matroid theory it is the exponential of a rank function.

The three properties of bond dimension that everybody uses are almost embarrassingly weak:

* looking at no sites gives you at most one bond;
* looking at more sites cannot decrease the bond dimension;
* looking at one extra site multiplies it by at most $q$.

The question motivating this work is: *how much of the theory of error-correcting codes survives on these three axioms alone?* The answer developed here is: the entire Singleton package, in a cut-indexed form strictly stronger than the classical statement, plus a rigidity theorem for the codes that saturate it.

### 1.2 What is new

1. **A cut-indexed family of Singleton inequalities**, one for each cut, of which the classical Singleton bound is the empty-cut member (Theorem 3.4).
2. **A rigidity theorem** identifying saturated cut data with maximally entangled cut data at every scale (Theorem 3.7).
3. **An entropic mirror** of the axiom system, with all three mirror axioms proved (Proposition 6.4, Theorems 6.5 and 6.7), yielding an entropic cut-wise Singleton inequality (Theorem 6.9) that dominates the counting one.
4. **A relativised grouping inequality** (Theorem 6.1) which is the analytic engine of the entropic theory and appears to be the right generalisation of the standard "entropy $\le$ log support" estimate for use inside a sum over cuts.
5. **A one-cut criterion for the MDS property** (Theorem 5.7, Theorem 6.13).
6. **A quantum cut-wise Singleton inequality** with an exact saturation regime (Theorems 7.4, 7.6) and a worked counterexample showing the regime cannot be enlarged (Section 8).
7. **A five-word counterexample to submodularity of the cut rank** (Proposition 8.5), explaining structurally why entropy is the better invariant.

### 1.3 Notation

Throughout, $n,q$ are natural numbers, $[n] := \{1,\dots,n\}$ is identified with the index set of sites, and a **word** is a function $c : [n] \to [q]$. Cuts are subsets $S \subseteq [n]$; $|S|$ is cardinality and $S^c$ the complement. For a word $c$, $c|_S$ denotes its restriction to $S$, an element of $[q]^S$. A **codebook** is a finite set $C$ of words. All logarithms are natural, and entropies are in nats. We write $\eta(x) := -x\log x$ for $x>0$ and $\eta(0):=0$; thus Shannon entropy is $\sum_y \eta(p_y)$.

---

## 2. Finite cut data

**Definition 2.1 (Cut datum).** A *cut datum* on $n$ sites with local dimension $q$ consists of a function $r : \mathcal{P}([n]) \to \mathbb{N}$ (the **bond dimension**) and a number $\mathrm{tot} \in \mathbb{N}$ (the **total dimension**) subject to:

* **(A1) Unit empty cut.** $r(\varnothing) \le 1$.
* **(A2) Monotonicity.** $S \subseteq T \implies r(S) \le r(T)$.
* **(A3) One-site growth.** $r(S \cup \{a\}) \le q\, r(S)$ for every $S$ and every site $a$.

We deliberately write $r(\varnothing)\le 1$ rather than $=1$; this keeps the empty codebook inside the theory at no cost to any theorem below.

**Definition 2.2 ($d$-resolving).** A cut datum is *$d$-resolving* if
$$n - |S| < d \implies r(S) = \mathrm{tot}.$$
This is the abstract shadow of minimum distance $d$: the object is determined by any $n-d+1$ of its sites.

**Definition 2.3 (Singleton dimension).** $k := n + 1 - d$ (truncated subtraction in $\mathbb{N}$).

---

## 3. The cut-wise Singleton inequality and rigidity

**Lemma 3.1 (Local dimension bound).** *For every cut, $r(S) \le q^{|S|}$.*

*Proof sketch.* Induct on $S$. The base case is (A1). For the inductive step, (A3) gives $r(S\cup\{a\}) \le q\, r(S) \le q \cdot q^{|S|} = q^{|S|+1}$. $\square$

**Lemma 3.2 (Block growth).** *For all cuts $S, E$: $r(S \cup E) \le q^{|E|}\, r(S)$.*

*Proof sketch.* Induct on $E$, applying (A3) once per element removed. $\square$

**Theorem 3.3 (Cut monotonicity with a rate).** *If $S \subseteq T$ then*
$$r(T) \;\le\; q^{\,|T|-|S|}\, r(S).$$

*Proof sketch.* Write $T = S \cup (T \setminus S)$ and apply Lemma 3.2 with $E = T\setminus S$, using $|T\setminus S| = |T|-|S|$. $\square$

This single statement is the engine of everything that follows: it says the bond dimension is *Lipschitz* with rate $\log q$ per site along the lattice of cuts.

**Theorem 3.4 (Cut-wise Singleton inequality).** *Let a cut datum be $d$-resolving with $d \ge 1$ and $k = n+1-d$. Then for every cut $S$ with $|S| \le k$,*
$$\mathrm{tot} \;\le\; q^{\,k-|S|}\, r(S).$$

*Proof sketch.* Since $|S|\le k \le n$, choose $T \supseteq S$ with $|T| = k$ exactly. Then $n - |T| = n - k = d-1 < d$, so the resolving property gives $r(T) = \mathrm{tot}$. Theorem 3.3 gives $r(T) \le q^{k-|S|} r(S)$. Combine. $\square$

Note the shape of the argument: no distance hypothesis enters until the very last step, where an *information set* $T \supseteq S$ of size exactly $k$ is produced.

**Corollary 3.5 (Singleton bound).** *Under the hypotheses of Theorem 3.4, $\mathrm{tot} \le q^{k}$.*

*Proof.* Take $S=\varnothing$ and use (A1). $\square$

**Definition 3.6 (Cut-indexed defect).** For a $d$-resolving cut datum and $|S|\le k$, the *cut-indexed defect* is
$$\delta(S) \;:=\; q^{\,k - |S|}\, r(S) \;-\; \mathrm{tot} \;\in\;\mathbb{N}.$$
By Theorem 3.4 this truncated subtraction is honest, and $\delta(S) = 0$ if and only if the cut-wise inequality is tight at $S$.

**Theorem 3.7 (Rigidity of saturated cut data).** *Let a cut datum be $d$-resolving with $d\ge 1$, $q \ge 1$, and suppose the global Singleton bound is saturated: $\mathrm{tot} = q^{k}$. Then for every cut with $|S| \le k$,*
$$r(S) = q^{|S|}, \qquad \delta(S) = 0.$$

*Proof sketch.* Substituting $\mathrm{tot} = q^k$ into Theorem 3.4 and splitting $q^k = q^{k-|S|}q^{|S|}$ gives $q^{k-|S|}q^{|S|} \le q^{k-|S|} r(S)$; cancelling the positive factor $q^{k-|S|}$ yields $q^{|S|} \le r(S)$. The reverse inequality is Lemma 3.1. Then $q^{k-|S|}r(S) = q^{k} = \mathrm{tot}$, so $\delta(S)=0$. $\square$

Informally: *a saturated cut datum is maximally entangled across every cut below the plateau.* The defect $\delta$ is not monotone in any variable, but its vanishing at $S=\varnothing$ is exactly saturation, and for $q\ge 2$ its vanishing everywhere is equivalent to saturation.

---

## 4. Codes as cut data

**Definition 4.1 (Cut rank).** For a codebook $C$ of words of length $n$ over $[q]$ and a cut $S$,
$$r_C(S) \;:=\; \big|\{\, c|_S \;:\; c \in C \,\}\big|,$$
the number of distinct patterns realised on $S$.

**Definition 4.2 (Minimum distance).** $C$ has *minimum distance at least $d$* if any two distinct codewords differ in at least $d$ positions.

**Proposition 4.3.** *$(r_C, |C|)$ is a cut datum.*

*Proof sketch.* (A1): all words restrict to the same (empty) pattern on $\varnothing$, so $r_C(\varnothing)\le 1$. (A2): restriction to $S$ factors through restriction to $T$ for $S\subseteq T$, and images do not grow under further maps. (A3): the map $y \mapsto (y|_S,\, y(a))$ is injective on patterns over $S\cup\{a\}$ and lands in a set of size $r_C(S)\cdot q$. $\square$

**Lemma 4.4 (Distance resolves cuts).** *If $C$ has minimum distance at least $d$ and $n - |S| < d$, then restriction to $S$ is injective on $C$, so $r_C(S) = |C|$.*

*Proof sketch.* Two words agreeing on $S$ differ only inside $S^c$, hence at distance at most $n-|S| < d$; minimum distance forces them equal. $\square$

Combining Proposition 4.3, Lemma 4.4 and the results of Section 3:

**Theorem 4.5 (Cut-wise Singleton for codes).** *If $C$ has minimum distance at least $d\ge 1$ and $|S| \le k = n+1-d$, then*
$$|C| \;\le\; q^{\,k-|S|}\, r_C(S).$$

**Corollary 4.6 (Singleton bound).** *$|C| \le q^{\,n+1-d}$.*

**Definition 4.7 (MDS).** $C$ is *MDS* (with respect to $d$) if it has minimum distance at least $d$ and $|C| = q^{k}$.

**Theorem 4.8 (Every $k$ coordinates form an information set).** *If $C$ is MDS with $d\ge1$, $q\ge1$, and $|S| \le k$, then $r_C(S) = q^{|S|}$: the restriction map $C \to [q]^S$ is surjective.*

*Proof.* Theorem 3.7 applied to $(r_C, |C|)$. $\square$

**Definition 4.9 (Fibre).** For a pattern $y \in [q]^S$, $\;F_C(S,y) := \{c \in C : c|_S = y\}$.

**Lemma 4.10 (Fibres are small).** *If $C$ has minimum distance at least $d\ge1$ and $|S|\le k$, then $|F_C(S,y)| \le q^{\,k-|S|}$ for every $y$.*

*Proof sketch.* A fibre is itself a codebook of minimum distance at least $d$, and its cut rank at $S$ is at most $1$ (all its members agree on $S$). Apply Theorem 4.5 to the fibre. This is a genuinely recursive use of the main theorem. $\square$

**Theorem 4.11 (Balanced fibres of an MDS code).** *If $C$ is MDS with $d\ge1$ and $|S|\le k$, then every $y \in [q]^S$ satisfies*
$$|F_C(S,y)| \;=\; q^{\,k-|S|}$$
*exactly: the restriction of an MDS code to any small cut is a uniform covering map.*

*Proof sketch.* The fibres partition $C$, so $\sum_{y \in [q]^S} |F_C(S,y)| = |C| = q^k = q^{|S|} \cdot q^{k-|S|}$. Since there are $q^{|S|}$ patterns and each fibre has size at most $q^{k-|S|}$ by Lemma 4.10, a single strict inequality would make the total sum strictly less than $q^k$. Hence all inequalities are equalities. $\square$

Theorem 4.11 is the combinatorial input to the entropy plateau of the next section.

---

## 5. The entropy profile of a cut

### 5.1 Cut marginals

**Definition 5.1 (Cut probability and cut entropy).** Let $C$ be a nonempty codebook. Put the uniform distribution on $C$ and push it to the cut $S$:
$$p_{C,S}(y) \;:=\; \frac{|F_C(S,y)|}{|C|}, \qquad y \in [q]^S.$$
The **cut entropy** is
$$H_C(S) \;:=\; \sum_{y \in [q]^S} \eta\big(p_{C,S}(y)\big) \;=\; -\sum_y p_{C,S}(y)\log p_{C,S}(y).$$
We drop the subscript $C$ when it is clear.

Since the fibres partition $C$, $\sum_y p_{C,S}(y) = 1$, and $p_{C,S}(y) \ne 0$ exactly when $y$ is a realised pattern; hence the support of the cut marginal has size exactly $r_C(S)$.

**Theorem 5.2 (Entropy is bounded by log bond dimension).** *For nonempty $C$,*
$$H(S) \;\le\; \log r_C(S).$$

*Proof sketch.* This is the standard "entropy at most log support size" estimate: by $\log x \le x-1$ applied to $x = 1/(m\,p_y)$ where $m = r_C(S)$, summed over the support. $\square$

Combining with Lemma 3.1:

**Corollary 5.3.** *$H(S) \le |S| \log q$; equivalently, the **entropic cut defect** $|S|\log q - H(S)$ is nonnegative.*

(The degenerate case $q=0$ is handled separately: a nonempty codebook over an empty alphabet forces $n=0$, hence $S = \varnothing$, and both sides vanish.)

**Theorem 5.4 (Entropic cut-wise Singleton bound, plateau form).** *If $C$ is nonempty with minimum distance at least $d\ge 1$ and $q\ge 1$, then for every cut*
$$H(S) \;\le\; \min\big(|S|,\,k\big)\,\log q .$$

*Proof sketch.* For $|S|\le k$ this is Corollary 5.3. For $|S| > k$ use $H(S) \le \log r_C(S) \le \log |C| \le k\log q$, the last step by the Singleton bound. $\square$

The right-hand side is a piecewise-linear "Ryu–Takayanagi"-shaped curve: unit slope $\log q$ up to $|S| = k$, then flat.

### 5.2 The plateau is attained

**Lemma 5.5 (Flat marginals).** *If the cut marginal is uniform on its $m \ge 1$ realised patterns, then $H(S) = \log m$.*

*Proof.* Immediate: $H(S) = m \cdot \eta(1/m) = \log m$. $\square$

**Theorem 5.6 (The entropy plateau of an MDS code).** *Let $C$ be MDS with $1 \le d \le n+1$ and $q \ge 1$. Then for every cut,*
$$H(S) \;=\; \min\big(|S|,\,k\big)\,\log q.$$

*Proof sketch.* Two regimes, both instances of Lemma 5.5.

*Below the plateau* ($|S|\le k$): Theorem 4.8 says the $q^{|S|}$ patterns are all realised, and Theorem 4.11 says each fibre has exactly $q^{k-|S|}$ elements, so $p(y) = q^{k-|S|}/q^{k} = q^{-|S|}$ for every $y$. The marginal is uniform on $q^{|S|}$ patterns and $H(S) = |S|\log q$.

*Above the plateau* ($|S| \ge k$): then $n - |S| \le n-k = d-1 < d$, so by Lemma 4.4 restriction is injective on $C$; each realised pattern has a single preimage and the marginal is uniform on all $|C| = q^{k}$ patterns. Hence $H(S) = \log|C| = k \log q$. $\square$

So the entropy profile of an MDS code is a *staircase*: it climbs with the maximum permitted slope and then is exactly flat, with a sharp corner at the Singleton dimension.

### 5.3 One cut suffices

**Theorem 5.7 (Entropy detects the MDS property at a single cut).** *Let $C$ be nonempty with minimum distance at least $d$, $1 \le d \le n+1$, and $q \ge 2$. Let $S$ be any single cut with $|S| = k$ exactly. Then*
$$C \text{ is MDS} \iff H(S) = k \log q.$$

*Proof sketch.* ($\Rightarrow$) Theorem 5.6 at $|S|=k$.

($\Leftarrow$) Always $H(S) \le \log r_C(S) \le \log |C|$. So $k \log q \le \log|C|$, i.e. $q^{k} \le |C|$. The reverse is the Singleton bound (Corollary 4.6). Hence $|C| = q^k$. $\square$

The hypotheses $q\ge2$ and $C$ nonempty are both necessary: for $q=1$ every logarithm vanishes and the criterion is vacuous; for $C=\varnothing$ there is no marginal. The content of the theorem is that *no averaging over cuts is required*: the whole Singleton defect is visible at a single well-chosen cut. This is precisely what the counting defect cannot do, and Section 8 explains why.

---

## 6. The entropic mirror of the axioms

Section 5 bounds the entropy profile from above. This section establishes its *structural* properties, showing that $H$ satisfies exact entropic analogues of (A1)–(A3) and hence supports a rerun of the Singleton argument in the entropic category — with a strictly stronger conclusion.

### 6.1 Two analytic inputs

**Theorem 6.1 (Grouping / log-sum inequality).** *Let $F$ be a finite index set with $|F| \le N$ for some $N \ge 1$, and let $p : F \to [0,\infty)$. Put $A := \sum_{i \in F} p_i$. Then*
$$\sum_{i \in F} \eta(p_i) \;\le\; \eta(A) \;+\; A \log N.$$

*Proof sketch.* If $A = 0$ all $p_i$ vanish and both sides are $0$. Otherwise fix $i$ with $p_i > 0$ and apply $\log x \le x-1$ to $x = A/(N p_i) > 0$:
$$\log A - \log N - \log p_i \;\le\; \frac{A}{N p_i} - 1.$$
Multiplying by $p_i > 0$ and rearranging gives
$$\eta(p_i) \;\le\; \frac{A}{N} - p_i - p_i \log A + p_i \log N,$$
an inequality that also holds trivially when $p_i = 0$. Summing over $F$ and using $\sum_i p_i = A$ yields
$$\sum_{i\in F}\eta(p_i) \;\le\; |F|\frac{A}{N} - A - A\log A + A\log N.$$
Finally $|F| \le N$ gives $|F| A/N \le A$, and $-A\log A = \eta(A)$. $\square$

This is the standard entropy-versus-log-support estimate *relativised to a sub-block*: it compares the entropy of a lump of mass $A$ split into at most $N$ parts against a single atom of that mass, and it is exactly this relativisation that makes it usable inside a sum over cuts. Equality holds iff $|F| = N$ and all $p_i = A/N$.

**Theorem 6.2 (Superadditivity of $\eta$).** *For nonnegative $a_1,\dots,a_m$,*
$$\eta\Big(\sum_i a_i\Big) \;\le\; \sum_i \eta(a_i).$$

*Proof sketch.* Let $A = \sum_j a_j$. If $A = 0$ both sides vanish. Otherwise, for each $i$ with $a_i>0$ we have $a_i \le A$, hence $\log a_i \le \log A$, hence $-a_i \log A \le -a_i \log a_i = \eta(a_i)$; the same holds trivially when $a_i = 0$. Summing gives $-A\log A \le \sum_i \eta(a_i)$. $\square$

### 6.2 Coarse-graining and the mirror axioms

**Lemma 6.3 (Coarse-graining).** *If $S \subseteq T$ and $y \in [q]^S$, then*
$$p_{C,S}(y) \;=\; \sum_{\substack{z \in [q]^T \\ z|_S = y}} p_{C,T}(z),$$
*because the fibre over $y$ is the disjoint union of the fibres over the extensions of $y$.*

**Proposition 6.4 (Mirror (A1)).** $H(\varnothing) = 0$: there is exactly one pattern on the empty cut, of probability $1$, and $\eta(1)=0$.

**Theorem 6.5 (Mirror (A2): monotonicity of the entropy profile).** *For any codebook and any $S \subseteq T$,*
$$H(S) \;\le\; H(T).$$

*Proof sketch.* By Lemma 6.3 and Theorem 6.2,
$$H(S) = \sum_{y}\eta\Big(\sum_{z|_S=y} p_T(z)\Big) \le \sum_{y}\sum_{z|_S=y}\eta\big(p_T(z)\big) = H(T),$$
the last step because the sets $\{z : z|_S=y\}$ partition $[q]^T$. $\square$

This is *not* a formal consequence of monotonicity of the cut rank; coarse-graining can raise entropy in general. What saves the argument is that the coarse-graining here is deterministic (a sum over fibres) and $\eta$ is superadditive.

**Lemma 6.6 (Counting extensions).** *If $S \subseteq T$, each pattern $y \in [q]^S$ has at most $q^{|T|-|S|}$ extensions to $T$.*

*Proof.* An extension is determined by $y$ together with its values on $T\setminus S$, and $|T\setminus S| = |T|-|S|$. $\square$

**Theorem 6.7 (Mirror (A3): entropic one-block growth).** *Let $C$ be nonempty, $q \ge 1$, and $S \subseteq T$. Then*
$$H(T) \;\le\; H(S) \;+\; \big(|T| - |S|\big)\log q.$$

*Proof sketch.* Fix $y \in [q]^S$ and let $F_y := \{z \in [q]^T : z|_S = y\}$, so $|F_y| \le N := q^{|T|-|S|}$ by Lemma 6.6 and $\sum_{z\in F_y} p_T(z) = p_S(y)$ by Lemma 6.3. Theorem 6.1 applied to the weights $(p_T(z))_{z \in F_y}$ gives
$$\sum_{z \in F_y} \eta\big(p_T(z)\big) \;\le\; \eta\big(p_S(y)\big) \;+\; p_S(y)\,\big(|T|-|S|\big)\log q .$$
Summing over $y$ and using that the $F_y$ partition $[q]^T$ together with $\sum_y p_S(y) = 1$ gives the claim. $\square$

This is the Shannon chain rule in the form needed here: enlarging a cut by $m$ sites adds at most $m \log q$ nats of entropy. Note that it is exactly the entropic mirror of (A3), with $\log q$ per site replacing a factor of $q$ per site.

### 6.3 The entropic cut-wise Singleton inequality

**Lemma 6.8 (Entropy above the Singleton dimension).** *If $C$ is nonempty with minimum distance at least $d$ and $n - |T| < d$, then $H(T) = \log|C|$.*

*Proof.* Lemma 4.4 makes restriction injective, so every fibre is a singleton and the marginal is uniform on $|C|$ patterns; apply Lemma 5.5. $\square$

**Theorem 6.9 (Entropic cut-wise Singleton inequality).** *Let $C$ be a nonempty codebook of length $n$ over an alphabet of size $q \ge 1$ with minimum distance at least $d \ge 1$, and $k = n+1-d$. Then for every cut $S$ with $|S| \le k$,*
$$\boxed{\;\log|C| \;\le\; H(S) \;+\; (k - |S|)\log q. \;}$$

*Proof sketch.* Enlarge $S$ to $T$ with $|T| = k$ exactly. Then $n-|T| = d-1 < d$, so $H(T) = \log|C|$ by Lemma 6.8. Theorem 6.7 gives $H(T) \le H(S) + (k-|S|)\log q$. Combine. $\square$

The proof is structurally identical to that of Theorem 3.4 — enlarge to an information set, then apply Lipschitz growth — but with $\log$ of the counting invariant replaced by the entropy.

**Theorem 6.10 (Entropic implies counting).** *Under the same hypotheses,*
$$\log|C| \;\le\; \log r_C(S) \;+\; (k-|S|)\log q,$$
*which is the logarithm of Theorem 4.5.*

*Proof.* Chain Theorem 6.9 with $H(S) \le \log r_C(S)$ (Theorem 5.2). $\square$

**Corollary 6.11 (Strictness).** *The entropic inequality is strictly stronger than the counting inequality whenever the cut marginal is non-uniform on its support*, since then $H(S) < \log r_C(S)$ strictly. Section 8 exhibits an explicit five-word code where this occurs.

**Definition 6.12 (Entropic cut defect).** For $|S| \le k$,
$$\Delta_C(d,S) \;:=\; H(S) + (k - |S|)\log q - \log|C| \;\ge\; 0,$$
nonnegativity being Theorem 6.9.

**Theorem 6.13 (The entropic defect at the empty cut detects MDS).** *Let $C$ be nonempty with minimum distance at least $d$ and $q \ge 2$. Then*
$$\Delta_C(d,\varnothing) = 0 \iff C \text{ is MDS}.$$

*Proof sketch.* $H(\varnothing) = 0$, so $\Delta_C(d,\varnothing) = k\log q - \log|C|$. Since $q\ge2$, $\log$ is injective on positives, so this vanishes iff $|C| = q^{k}$. $\square$

Together, Theorems 5.7 and 6.13 say that the Singleton defect of a code is a *single scalar attached to a single cut*, obtainable either at the empty cut (entropic defect) or at a full information set (entropy versus $k\log q$).

---

## 7. The quantum avatar

### 7.1 The uniform code state

**Definition 7.1.** For a nonempty codebook $C$ and a cut $S$, the **uniform code state** is
$$|C\rangle \;=\; \frac{1}{\sqrt{|C|}} \sum_{c \in C} |c\rangle,$$
which across the cut $S$ is the bipartite state with coefficient matrix
$$M_S(a,b) \;=\; \begin{cases} |C|^{-1/2}, & \text{if } a \sqcup b \in C,\\ 0, & \text{otherwise,}\end{cases}\qquad a \in [q]^S,\; b\in[q]^{S^c},$$
where $a \sqcup b$ denotes the word obtained by gluing the two half-patterns.

**Proposition 7.2 (Normalisation).** *$\sum_{a,b} |M_S(a,b)|^2 = 1$ for every cut.*

*Proof.* The pairs $(a,b)$ with $a\sqcup b \in C$ biject with $C$ (glue and split are mutually inverse), and each contributes $1/|C|$. $\square$

The **Schmidt rank** of $|C\rangle$ across $S$ is the matrix rank of $M_S$; the **entanglement entropy** $E(S)$ is the von Neumann entropy of the reduced density matrix $\rho_S = M_S M_S^{\dagger}$.

**Theorem 7.3 (Bond-dimension factorisation).** *$M_S$ factors through a space of dimension $r_C(S)$; hence*
$$\operatorname{rank} M_S \;\le\; r_C(S).$$

*Proof sketch.* $M_S(a,\cdot)$ is identically zero unless $a$ is a realised pattern on $S$. Writing $M_S = P R$, where $P$ is the $[q]^S \times \{\text{realised patterns}\}$ indicator matrix and $R$ the restriction of $M_S$ to realised rows, exhibits a factorisation through a space of dimension $r_C(S)$. $\square$

Also, trivially, $\operatorname{rank} M_S \le q^{|S^c|}$ — the **purity bound**, coming from the width of the matrix. This is the seed of the difference between the classical and quantum profiles.

**Theorem 7.4 (Quantum cut-wise Singleton inequality).** *Let $C$ be nonempty with minimum distance at least $d\ge 1$ and $k = n+1-d$. Then for every cut,*
$$E(S) \;\le\; \min\big(|S|,\,k\big)\,\log q,$$
*the same plateau curve that bounds the classical cut entropy.*

*Proof sketch.* For a normalised bipartite state, $E(S) \le \log \operatorname{rank} M_S$. By Theorem 7.3, $\operatorname{rank} M_S \le r_C(S)$, and $r_C(S) \le \min(q^{|S|}, |C|) \le q^{\min(|S|,k)}$ using Lemma 3.1 and the Singleton bound. Take logarithms. $\square$

### 7.2 Exact saturation for MDS codes

**Theorem 7.5 (Maximally mixed reduced state).** *Let $C$ be MDS with $d \ge 1$, $q \ge 1$, and let $S$ satisfy $|S| \le k$ and $|S| < d$. Then*
$$\rho_S \;=\; q^{-|S|}\, I_{q^{|S|}},$$
*the maximally mixed state on $q^{|S|}$ levels.*

*Proof sketch.* Compute $\rho_S(a,a') = \sum_b M_S(a,b)\overline{M_S(a',b)}$.

*Off-diagonal* ($a \ne a'$): a nonzero term requires both $a\sqcup b$ and $a'\sqcup b$ to be codewords. They are distinct (they differ on $S$) and agree on all of $S^c$, so their Hamming distance is at most $|S| < d$ — contradicting minimum distance. Every off-diagonal entry vanishes.

*Diagonal:* $\rho_S(a,a) = |F_C(S,a)| / |C|$, which by Theorem 4.11 equals $q^{k-|S|}/q^{k} = q^{-|S|}$. $\square$

**Theorem 7.6 (MDS code states saturate the quantum bound).** *Under the hypotheses of Theorem 7.5,*
$$E(S) \;=\; |S| \log q, \qquad \operatorname{rank} M_S \;=\; q^{|S|}, \qquad E(S) = \log \operatorname{rank} M_S.$$

*Proof.* The von Neumann entropy of $q^{-m} I_{q^{m}}$ is $m\log q$; the rank of a nonzero multiple of the identity is the full dimension $q^{|S|}$; the third equality follows from the first two. $\square$

The last equality says the state is *maximally entangled at that bond*: the entropy–Schmidt-rank inequality is tight.

**Theorem 7.7 (Mutual information sandwich).** *Under the hypotheses of Theorem 7.5, the quantum mutual information $I(S{:}S^c) = E(S) + E(S^c)$ satisfies*
$$|S|\log q \;\le\; I(S{:}S^c) \;\le\; 2\,|S|\log q .$$

*Proof.* The lower bound is $E(S) = |S|\log q$ plus nonnegativity of $E(S^c)$. The upper bound is the general estimate $I \le 2\log \operatorname{rank} M_S$ together with Theorem 7.6. $\square$

Purity of $|C\rangle$ suggests that $E(S^c) = E(S)$ and hence that the upper end is achieved; establishing this requires knowing that the nonzero spectra of $MM^\dagger$ and $M^\dagger M$ coincide with multiplicity for *rectangular* $M$, which is stated as an open direction in Section 10.

---

## 8. Worked examples and negative results

### 8.1 The even-weight code: staircase versus tent

Let $E = \{000, 011, 101, 110\} \subseteq \{0,1\}^3$, the even-weight code. Here $n = 3$, $q = 2$, minimum distance $d = 2$, $k = n+1-d = 2$, and $|E| = 4 = 2^{k}$, so $E$ is MDS.

**Proposition 8.1 (Cut ranks).** $r_E(\varnothing)=1$, $r_E(\{i\}) = 2$, $r_E(\{i,j\}) = 4$, $r_E(\{1,2,3\}) = 4$.

*Proof.* For $|S| \le k = 2$ this is Theorem 4.8: $r_E(S) = 2^{|S|}$. For $|S| = 3$, restriction is the identity. $\square$

**Proposition 8.2 (Entropy profile).** $H_E(S) = \min(|S|, 2)\log 2$, i.e. the profile in nats is
$$0,\quad \log 2,\quad 2\log 2,\quad 2\log 2$$
for $|S| = 0,1,2,3$.

*Proof.* Theorem 5.6. $\square$

**Proposition 8.3 (A nonzero defect).** *At the full cut, the entropic cut defect of Corollary 5.3 is exactly*
$$3\log 2 - H_E(\{1,2,3\}) = 3\log 2 - 2\log 2 = \log 2 > 0.$$

So the defect is a genuinely nonzero invariant and the theory is not vacuous: the third bit of an even-weight word carries no new information, and the defect records exactly that.

**Proposition 8.4 (Sharpness of the guard $|S| < d$).** *For the one-site cut, $E(\{1\}) = \log 2$, saturating Theorem 7.4. For the two-site cut,*
$$E\big(\{1,2\}\big) \;<\; H_E\big(\{1,2\}\big) = 2\log 2 .$$

*Proof sketch.* The one-site statement is Theorem 7.6 with $|S| = 1 \le \min(k, d-1) = 1$. For the two-site cut, the purity bound gives $\operatorname{rank} M_S \le q^{|S^c|} = 2$, whence $E(\{1,2\}) \le \log 2 < 2\log 2$. $\square$

This is the promised counterexample: at $|S| = 2 = k$ but $|S| > d-1 = 1$, the *quantum* cut entropy is strictly below the *classical* one even though the code is MDS. The classical profile is a monotone **staircase** $0,1,2,2$ (in units of $\log 2$); the quantum profile is a **tent** $0,1,\le 1,0$, forced back down by purity — a pure state cannot carry more entanglement than either side can hold, so $E(S) = E(S^c) \le \min(|S|,|S^c|)\log q$. The two saturation regimes of Sections 5 and 7 differ, and this is structural, not an artefact of the proofs.

### 8.2 A five-word code: strictness and non-submodularity

Let $P = \{000, 100, 010, 110, 001\} \subseteq \{0,1\}^3$, so $|P| = 5$ and the minimum distance is $1$ (hence $k = 3$).

**Strictness of the entropic inequality.** At $S = \{1\}$ the two fibres have sizes $3$ (words with first bit $0$) and $2$, so the marginal is $(3/5, 2/5)$ and
$$H_P(\{1\}) = -\tfrac35\log\tfrac35 - \tfrac25\log\tfrac25 \approx 0.6730 \;<\; \log 2 \approx 0.6931 = \log r_P(\{1\}).$$
Theorem 6.9 therefore gives a strictly better bound than Theorem 6.10 at this cut: entropy sees the *shape* of the fibre distribution while rank sees only its support.

**Proposition 8.5 (The cut rank is not submodular).** *For $S = \{1,3\}$ and $T = \{2,3\}$,*
$$r_P(S)\, r_P(T) \;=\; 3\cdot 3 \;=\; 9 \;<\; 10 \;=\; 5 \cdot 2 \;=\; r_P(S\cup T)\, r_P(S\cap T).$$

*Proof.* Direct enumeration: the patterns of $P$ on $\{1,3\}$ are $\{00,10,01\}$, likewise on $\{2,3\}$; $r_P(\{1,2,3\}) = |P| = 5$ and $r_P(\{3\}) = 2$. $\square$

Hence $\log r_P$ violates submodularity, an inequality Shannon entropy always satisfies. This is the structural reason the entropic defect is a finer invariant than the counting defect, and it also shows that no submodularity axiom may be added to Definition 2.1 without excluding the code instance.

---

## 9. Algorithms

All quantities in this paper are computable by direct enumeration; the following procedures make the complexity explicit for a codebook $C$ of $m$ words of length $n$ over an alphabet of size $q$.

**Algorithm A (Cut-rank profile).** For each of the $2^n$ cuts, hash the $m$ restrictions and count distinct values. Complexity $O(2^n m n)$ time, $O(m)$ space per cut. Output: the map $S \mapsto r_C(S)$.

**Algorithm B (Cut-entropy profile).** For each cut, build the fibre-size histogram $(|F_C(S,y)|)_y$ in one pass over $C$ (cost $O(mn)$), then evaluate $H(S) = \log m - \frac1m\sum_y |F_C(S,y)|\log |F_C(S,y)|$. This *counting form* of the entropy avoids division and is numerically stable. Complexity $O(2^n m n)$.

**Algorithm C (Defect certification).** Given $d$, compute $k = n+1-d$, then for each cut with $|S|\le k$ evaluate both defects,
$$\delta(S) = q^{k-|S|} r_C(S) - |C|, \qquad \Delta(S) = H(S) + (k-|S|)\log q - \log|C|,$$
and assert $\delta(S)\ge 0$, $\Delta(S)\ge 0$, and $\Delta(S) \le \delta$-implied bound. Complexity dominated by Algorithms A and B.

**Algorithm D (Minimum distance).** Pairwise Hamming distances: $O(m^2 n)$. Used to determine $d$, hence $k$, hence the MDS test $|C| \stackrel{?}{=} q^{k}$.

**Algorithm E (Quantum profile).** For each cut, assemble the $q^{|S|} \times q^{n-|S|}$ coefficient matrix, compute its singular values, and evaluate $E(S) = -\sum_i \sigma_i^2 \log \sigma_i^2$. Complexity $O(q^{n} \min(q^{|S|}, q^{n-|S|})^2)$ per cut by dense SVD; feasible for the small $n$ used in examples.

---

## 10. Discussion and future directions

### 10.1 Three inequalities, one family

The results assemble into a single family of cut-indexed inequalities of the shape
$$\log(\text{total}) \;\le\; \Phi(S) \;+\; (k - |S|)\log q,$$
with three successively finer choices of $\Phi$:

| $\Phi(S)$ | Inequality | Saturated by MDS? |
|---|---|---|
| $\log r_C(S)$ (cut rank) | counting cut-wise Singleton | yes, for all $|S|\le k$ |
| $H(S)$ (cut entropy) | entropic cut-wise Singleton | yes, for all $|S|\le k$ |
| $\log \operatorname{rank} M_S$ / $E(S)$ (quantum) | quantum cut-wise Singleton | only for $|S| \le \min(k, d-1)$ |

Since $E(S) \le \log\operatorname{rank}M_S \le \log r_C(S)$ and $H(S) \le \log r_C(S)$, the entropic form dominates the counting form. The quantum member is the only one that can *fail* to saturate for MDS codes, and the reason is purity on the complement (Section 8.1).

### 10.2 The profile as a polymatroid

Monotonicity (Theorem 6.5) and the chain-rule bound (Theorem 6.7) are exactly the two axioms defining a *polymatroid* rank function, save for submodularity. If submodularity of $H$ holds — as it does for Shannon entropy in the usual setting — the entropy profile of a code is a polymatroid whose rank function is the matroid rank of the code rescaled by $\log q$, and the entropic defect becomes a matroid invariant. Proposition 8.5 shows this cannot be established by transporting the corresponding statement for the cut rank, which is false.

### 10.3 Open directions

**1. Chain-rule rigidity: the entropy profile determines the code up to information sets.**
*Conjecture.* Let $C$ be a code of minimum distance $d$ with $q \ge 2$. If the entropy profile satisfies $H(S) = \min(|S|, k)\log q$ for *every* cut $S$, then $C$ is MDS, and conversely; moreover any two codes with the same profile have the same family of information sets.
*The key insight is* that the empty-cut criterion (Theorem 6.13) already reduces the MDS property to the vanishing of a single scalar at one cut, so the whole profile must be a *matroid* invariant: $H$ is the rank function of the code's matroid rescaled by $\log q$, and the conjecture asserts that the entropic defect is the matroid's Singleton defect.
*Why now?* The monotone-plus-chain-rule package (Theorems 6.5 and 6.7) is exactly the pair of axioms defining a polymatroid; the remaining step is to prove submodularity of the cut entropy, which is a finite Jensen argument on the fibre decomposition of Lemma 6.3.

**2. Submodularity of the cut entropy versus non-submodularity of the cut rank.**
*Conjecture.* The cut entropy is submodular: $H(S) + H(T) \ge H(S\cup T) + H(S\cap T)$ for all cuts, even though the five-word code of Proposition 8.5 shows the rank is not.
*The key insight is* that the failure witnessed by the five-word code is a *support* phenomenon: the rank only sees which patterns occur, while the entropy weights them, and the weighting is exactly what restores submodularity.
*Why now?* The grouping inequality (Theorem 6.1) is the one-sided half of the standard proof; the missing half is the conditional form of the same estimate on a common refinement of two cuts.

**3. Rectangular purity: equal marginal entropies for a bipartite pure state.**
*Conjecture.* For any rectangular matrix $M$ the nonzero spectra of $MM^{\dagger}$ and $M^{\dagger}M$ coincide with multiplicity; consequently the two marginal von Neumann entropies of a bipartite pure state agree, and the mutual information of an MDS code state across a small cut is exactly $2|S|\log q$.
*The key insight is* that the standard characteristic-polynomial commutation identity fails to apply only for the bookkeeping reason that the two products live on different index types; padding $M$ to a square matrix over the disjoint union of the two index sets should transport the identity.
*Why now?* Theorem 7.7 proves the two-sided sandwich $|S|\log q \le I \le 2|S|\log q$ and identifies this as the only missing step; everything else in the computation (Theorem 7.5) is already available.

**4. Holographic plateau: the quantum profile of an MDS code is the tent.**
*Conjecture.* For an MDS code, the quantum profile is exactly $E(S) = \min(|S|, |S^c|, k)\log q$ — the tent observed in Section 8.1 — for every cut, not merely in the regime $|S| \le \min(k, d-1)$ where saturation is proved. This is the discrete analogue of the Ryu–Takayanagi formula with the "minimal surface" being the smaller of the two sides, capped by the Singleton dimension.

### 10.4 Applications

*Coding theory.* Theorem 4.5 gives a cut-localised certificate against MDS-ness: to prove a code is *not* MDS it suffices to exhibit a single cut $S$ with $|S|\le k$ where $q^{k-|S|} r_C(S) > |C|$ — one need not compute the full weight enumerator. Theorem 4.11 is the exact balanced-fibre statement that underlies uniform sampling and list-decoding heuristics for MDS codes.

*Tensor networks.* Theorem 3.4 gives a lower bound on the bond dimension required at any cut in order for a matrix product state to represent an object of a given total dimension whose local reconstruction radius is $d$: $r(S) \ge \mathrm{tot}\, q^{|S|-k}$. Theorem 3.7 says that saturating the bound forces maximal bond dimension at every scale — a rigidity statement about optimal network architectures.

*Quantum information.* Theorem 7.6 constructs, from any MDS code, a family of states that are exactly maximally entangled across every cut of size below $\min(k, d-1)$; Reed–Solomon codes therefore yield explicit multipartite states with prescribed entanglement plateaus.

*Complexity of certification.* All the invariants are computable by the enumeration algorithms of Section 9; the one-cut criteria (Theorems 5.7, 6.13) reduce a global optimality test to a single local computation.

---

## 11. Conclusion

Three axioms — trivial empty cut, monotonicity, one-site growth — plus a saturation hypothesis suffice to prove a cut-indexed family of Singleton inequalities, of which the classical Singleton bound is the empty-cut member, and to force the rigidity $r(S) = q^{|S|}$ for saturated data. Replacing the counting bond dimension by the Shannon entropy of the cut marginal reproduces all three axioms in entropic form and yields a strictly stronger inequality, $\log|C| \le H(S) + (k-|S|)\log q$, whose defect vanishes at a single cut exactly when the code is MDS. Promoting the code to a uniform superposition yields a third member of the family, which is saturated by MDS codes only below the reconstruction radius $d$, the deficit being a direct consequence of global purity. The resulting picture — counting profile, entropic staircase, quantum tent — is the small-scale, fully discrete shadow of the entanglement-versus-minimal-surface story of holography, and the open questions it leaves are all concrete statements about a single scalar attached to a single cut.
