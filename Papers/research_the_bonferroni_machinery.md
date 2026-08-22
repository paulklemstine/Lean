# Which Marginals Feed the Machine? Second-Moment Union Bounds, Exact Collision Marginals, and an Unconditional Converse for Random Hashing

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Lower bounds on the probability of a union of events are commonly obtained by feeding two *marginals* — the probability of a single event and the probability of a pair of events — into the second Bonferroni inequality. Applied to the failure event of a uniformly random hashing codebook, this route yields the bound $\Pr[\text{failure}] \ge k/(2M)$ on $k$ competing messages and $M$ labels, but only in the regime $2(k-1) \le M$. We ask whether that regime restriction is a property of the marginals or of the inequality, and prove that it is a property of the inequality.

We first establish, in exact counting form and for an arbitrary finite family of finite sets, the Chung–Erdős (second-moment) inequality $(\sum_i |A_i|)^2 \le |\bigcup_i A_i| \cdot \sum_{i,j} |A_i \cap A_j|$, by double counting the multiplicity function and applying Cauchy–Schwarz. From it we derive an abstract **marginal-profile theorem**: a family whose members each have measure exactly $1/m$ and whose distinct pairs each have measure at most $1/c$ satisfies $c\,k\,N \le m\,|\bigcup_i A_i|\,(c + m(k-1))$, with no restriction on the number $k$ of sets. We show the bound is attained by a constant family, hence unimprovable as a function of the profile $(m,c,k,N)$, and that the Bonferroni-shaped conclusion $|\bigcup_i A_i| \ge kN/(2m)$ *fails* for that same family, so the pairwise hypothesis is load-bearing.

Instantiating with the two hashing marginals gives $\Pr[\text{failure}] \ge k/(M+k-1)$ unconditionally; this dominates $k/(2M)$ throughout the Bonferroni regime $k \le M+1$, and yields a genuine converse to Shannon's random-coding bound: for $k \ge M$ a uniformly random codebook fails with probability strictly greater than $1/2$.

We then compute all the relevant marginals exactly. A **component law** states that the number of codebooks realising an arbitrary prescribed collision pattern equals $M$ raised to the number of connected components of the pattern graph; consequently a prescribed star of $t$ collisions has probability exactly $M^{-t}$, the pairwise input above is an equality rather than an inequality, and vertex-sharing and vertex-disjoint pairs of collisions have the same marginal. A **conditional marginal principle** — a collision has conditional probability exactly $1/M$ given any event that does not constrain the relevant coordinate — yields the exact failure law $\Pr[\text{failure}] = 1 - (1-1/M)^k$, from which we recover the Shannon bound $k/M$ and the matching lower bound $k/(M+k)$, and establish the hierarchy
$$\frac{k}{2M} \le \frac{k}{M+k-1} \le \Pr[\text{failure}] = 1-\Bigl(1-\tfrac1M\Bigr)^k \le \frac{k}{M}.$$
Finally, averaging the exact law rather than the union bound produces a **derandomisation** that is never vacuous: some fixed codebook loses at most a $1-(1-1/M)^{|S|-1}$ fraction of the typical set, a bound that always implies the classical $|S|(|S|-1)/M$ estimate.

**Keywords:** Chung–Erdős inequality, Bonferroni inequalities, second moment method, random hashing, almost-lossless source coding, collision patterns, derandomisation, converse bounds.

---

## 1. Introduction

### 1.1 The problem

Let $\alpha$ be a finite alphabet of messages and let $M \ge 1$ be a number of labels. A **codebook** is a function $H : \alpha \to \{0,1,\dots,M-1\}$; the set of codebooks has cardinality $M^{|\alpha|}$, and "a uniformly random codebook" means the uniform measure on this finite set, equivalently independent uniform labels for distinct messages.

Fix a **typical set** $S \subseteq \alpha$ and a transmitted message $x \in S$. The codebook fails at $x$ if some other typical message shares its label:
$$\mathrm{fail}(S,x,M) \;=\; \bigl\{\, H : \exists\, y \in S \setminus \{x\},\; H(y) = H(x) \,\bigr\}.$$
Writing $k = |S \setminus \{x\}|$ for the number of competitors, Shannon's random-coding (union) bound gives $\Pr[\mathrm{fail}] \le k/M$: compression at $M \gg k$ labels succeeds with high probability.

The converse direction — lower bounds on $\Pr[\mathrm{fail}]$ — is standardly obtained from the **second Bonferroni inequality**, which in exact counting form reads
$$\sum_{i \in I} |A_i| \;\le\; \Bigl|\bigcup_{i\in I} A_i\Bigr| \;+\; \sum_{(i,j) \in I^{\mathrm{offdiag}}} |A_i \cap A_j| \tag{B}$$
for an arbitrary finite family $(A_i)_{i \in I}$ of finite sets. Feeding (B) the two hashing marginals

* **first marginal:** $M \cdot |\{H : H(y) = H(x)\}| = M^{|\alpha|}$, i.e. probability $1/M$;
* **second marginal:** $M^2 \cdot |\{H : H(p) = H(r) = H(q)\}| \le M^{|\alpha|}$, i.e. probability at most $1/M^2$;

produces
$$\Pr[\mathrm{fail}] \;\ge\; \frac{k}{2M}, \qquad \text{valid only when } 2(k-1) \le M. \tag{1.1}$$

The side condition is unsatisfying. It restricts the conclusion to precisely the regime in which the conclusion is weak, and it disappears exactly where a converse would be interesting, namely as $k$ approaches and exceeds $M$.

### 1.2 The question, and the answer

Inequality (B) is stated for an *arbitrary* finite family. The hypothesis $2(k-1) \le M$ therefore cannot come from (B)'s generality; it must come either from the two marginals fed in or from the algebraic shape of (B) itself. This paper answers the question:

> **Is the regime restriction a property of the marginals, or of the machinery?**

**Answer: of the machinery.** The identical two marginals, fed into the second-moment (Chung–Erdős) inequality instead of into (B), yield
$$\Pr[\mathrm{fail}] \;\ge\; \frac{k}{M+k-1} \qquad \text{for all } k \text{ and all } M \ge 1, \tag{1.2}$$
which dominates (1.1) throughout the regime where (1.1) is valid and remains informative — indeed remains greater than $1/2$ — when $k \ge M$.

We complement this with a complete determination of the marginals themselves (Section 4), showing that no sharpening of the inputs was available: the second marginal is an equality, not an inequality. And we compute the failure probability exactly (Section 5), locating all bounds in a single hierarchy (Section 6), before applying the exact law to derandomisation (Section 7).

### 1.3 Organisation

Section 2 fixes notation. Section 3 develops the second-moment machinery and the abstract marginal-profile theorem, together with its sharpness and the necessity of the pairwise hypothesis. Section 4 computes exact marginals of arbitrary collision patterns via collapse maps and via the component law. Section 5 proves the conditional marginal principle and the exact failure law. Section 6 assembles the hierarchy of bounds. Section 7 treats exact derandomisation. Section 8 discusses algorithms and applications; Section 9 collects open directions.

---

## 2. Setting and notation

Throughout, $\iota$ and $\alpha$ denote finite index sets (of messages), $M \ge 1$ is the number of labels, and codebooks are functions into a fixed $M$-element label set, which we identify with $\mathbb{Z}/M$. The ambient probability space is the set of all $M^{|\alpha|}$ codebooks with the uniform measure; all "probabilities" below are ratios of cardinalities with denominator $M^{|\alpha|}$, and all statements are proved as exact statements about integers before being divided.

**Definition 2.1 (Collision event).** For $p, q \in \iota$, the *collision event* is
$$C(p,q) \;=\; \{\, H : \iota \to \mathbb{Z}/M \;\mid\; H(p) = H(q) \,\}.$$

**Definition 2.2 (Star event).** For $T \subseteq \iota$ and $x \in \iota$, the *star event* is
$$\mathrm{Star}(T,x) \;=\; \{\, H \mid H(y) = H(x) \text{ for all } y \in T \,\}.$$

**Definition 2.3 (Collision pattern and pattern event).** A *collision pattern* is a finite set $P \subseteq \iota \times \iota$ of ordered pairs, i.e. a directed graph on $\iota$; we always treat it as an undirected graph, since the event it defines is symmetric. Its *pattern event* is
$$E(P) \;=\; \{\, H \mid H(a) = H(b) \text{ for all } (a,b) \in P \,\}.$$

**Definition 2.4 (Failure event and bad strings).** For $S \subseteq \alpha$ and $x \in S$,
$$\mathrm{fail}(S,x) \;=\; \bigl\{ H \mid \exists\, y \in S\setminus\{x\},\; H(y)=H(x) \bigr\}, \qquad
\mathrm{bad}(S,H) \;=\; \bigl\{ x \in S \mid \exists\, y \in S\setminus\{x\},\; H(y)=H(x) \bigr\}.$$
Note the basic decomposition
$$\mathrm{fail}(S,x) \;=\; \bigcup_{y \in S \setminus \{x\}} C(y,x), \tag{2.1}$$
which is what makes union bounds the natural tool.

**Definition 2.5 (No-collision event).** For $D \subseteq \iota$ and $x \in \iota$,
$$\mathrm{NC}(D,x) \;=\; \{\, H \mid H(y) \ne H(x) \text{ for all } y \in D \,\},$$
the complement of $\mathrm{fail}$ when $D = S \setminus \{x\}$.

**Definition 2.6 (Off-diagonal).** For a finite index set $I$, $I^{\mathrm{offdiag}} = \{(i,j) \in I \times I : i \ne j\}$, of cardinality $|I|^2 - |I|$.

---

## 3. The second-moment machinery

### 3.1 The Chung–Erdős inequality in counting form

**Theorem 3.1 (Chung–Erdős, exact counting form).**
*Let $\Omega$ be a finite set, $I$ a finite index set and $A : I \to \mathcal{P}(\Omega)$ a family of finite subsets. Then*
$$\Bigl(\sum_{i \in I} |A_i|\Bigr)^{2} \;\le\; \Bigl|\bigcup_{i \in I} A_i\Bigr| \cdot \sum_{(i,j) \in I \times I} |A_i \cap A_j|.$$

*Proof.* Write $U = \bigcup_{i \in I} A_i$ and define the **multiplicity function**
$$f : \Omega \to \mathbb{N}, \qquad f(w) = \#\{ i \in I : w \in A_i \}.$$
Since $A_i \subseteq U$ for every $i$, we may write $|A_i| = \sum_{w \in U} \mathbf{1}[w \in A_i]$, and exchanging the order of summation gives the **first-moment identity**
$$\sum_{i \in I} |A_i| \;=\; \sum_{w \in U} f(w).$$
Similarly, $|A_i \cap A_j| = \sum_{w\in U} \mathbf{1}[w \in A_i]\,\mathbf{1}[w \in A_j]$, and exchanging summation over the product index set gives the **second-moment identity**
$$\sum_{(i,j) \in I\times I} |A_i \cap A_j| \;=\; \sum_{w \in U} \Bigl(\sum_{i\in I} \mathbf{1}[w \in A_i]\Bigr)^{2} \;=\; \sum_{w \in U} f(w)^2 .$$
The claim is now precisely Cauchy–Schwarz applied to $f$ and the constant function $1$ on the finite set $U$:
$\bigl(\sum_{w \in U} f(w)\bigr)^2 \le |U| \sum_{w \in U} f(w)^2$. $\square$

Two remarks. First, the statement is an inequality between natural numbers; no measure theory, no normalisation, and no positivity hypotheses beyond finiteness are needed. Second, Theorem 3.1 is the *second-moment counterpart* of the Bonferroni inequality (B): both take as input the same data, $\sum_i |A_i|$ and $\sum_{i \ne j} |A_i \cap A_j|$, and both output a lower bound on $|U|$. Bonferroni bounds the overcount linearly; Chung–Erdős bounds it quadratically. The difference in behaviour is exactly the difference between the two shapes.

### 3.2 The marginal-profile theorem

We now isolate the abstract content: what a union bound can say knowing only the *marginal profile* of a family.

**Definition 3.2 (Marginal profile).** Let $N \ge 1$ be the size of an ambient space, $I$ a finite index set of size $k$, and $A : I \to \mathcal{P}(\Omega)$ a family. We say $A$ has **first marginal exactly $1/m$** if $m\,|A_i| = N$ for all $i \in I$, and **second marginal at most $1/c$** if $c\,|A_i \cap A_j| \le N$ for all $(i,j) \in I^{\mathrm{offdiag}}$.

**Theorem 3.3 (Marginal-profile lower bound).**
*Let $A : I \to \mathcal{P}(\Omega)$ have first marginal exactly $1/m$ and second marginal at most $1/c$ relative to $N \ge 1$, and set $k = |I|$, $U = \bigcup_{i\in I} A_i$. Then*
$$c\,k\,N \;\le\; m\,|U|\,\bigl(c + m(k-1)\bigr).$$
*Equivalently, if $m, c \ge 1$,*
$$\frac{|U|}{N} \;\ge\; \frac{c\,k}{m\,\bigl(c + m(k-1)\bigr)} \;=\; \frac{k}{m + \dfrac{m^{2}(k-1)}{c}}.$$
***There is no restriction relating $k$, $m$ and $c$.***

*Proof.* The case $k = 0$ is trivial, so assume $k \ge 1$. Put $T = \sum_{(i,j) \in I \times I} |A_i \cap A_j|$.

*First moment.* From $m|A_i| = N$ for each $i$,
$$m \sum_{i \in I} |A_i| = kN. \tag{3.1}$$

*Second moment.* Splitting $I \times I$ into its diagonal and off-diagonal parts and using $A_i \cap A_i = A_i$,
$$T = \sum_{i \in I} |A_i| + \sum_{(i,j)\in I^{\mathrm{offdiag}}} |A_i \cap A_j|.$$
The off-diagonal part has $k^2 - k$ terms, each of size at most $N/c$; multiplying through by $c$,
$$c \sum_{(i,j)\in I^{\mathrm{offdiag}}} |A_i \cap A_j| \;\le\; (k^2-k)\,N.$$
Multiplying the split identity by $mc$ and substituting (3.1) into the diagonal term gives
$$mc\,T \;\le\; c\,(kN) + m\,(k^2-k)N. \tag{3.2}$$

*Combination.* Apply Theorem 3.1 and scale by $m^2 c$:
$$c(kN)^2 \;\overset{(3.1)}{=}\; m^2 c\Bigl(\sum_i |A_i|\Bigr)^2 \;\le\; m^2 c\,|U|\,T \;=\; m|U| \cdot \bigl(mc\,T\bigr) \;\overset{(3.2)}{\le}\; m|U|\bigl(c\,kN + m(k^2-k)N\bigr).$$
Since $k^2 - k = k(k-1)$, the right-hand side equals $(kN)\cdot m|U|(c + m(k-1))$, while the left-hand side equals $(kN)\cdot ckN$. Cancelling the positive factor $kN$ gives the claim. The probability form follows by dividing by $mN(c+m(k-1)) > 0$. $\square$

The absence of a side condition is the crux. As $k \to \infty$ the bound degrades smoothly to $\approx c/(m^2)\cdot 1$ rather than becoming unavailable; there is no threshold at which it ceases to be a theorem.

### 3.3 Sharpness

**Theorem 3.4 (The marginal bound is attained).**
*There exist $\Omega$, $A$, $I$ and $(m,c,N)$ realising a marginal profile for which the inequality of Theorem 3.3 is an equality. Explicitly, take $\Omega$ of size $N = 2$, $m = c = 2$, and let $A_1 = A_2 = A_3$ all equal a fixed singleton (so $k = 3$). Then both sides equal $12$.*

*Proof.* Each $|A_i| = 1$, so $m|A_i| = 2 = N$: first marginal exactly $1/2$. Each pairwise intersection is the same singleton, so $c|A_i \cap A_j| = 2 \le N$: second marginal at most $1/2$. The union is the singleton, $|U| = 1$. Left side: $ckN = 2\cdot3\cdot2 = 12$. Right side: $m|U|(c+m(k-1)) = 2 \cdot 1 \cdot (2 + 2\cdot 2) = 12$. $\square$

Consequently **Theorem 3.3 cannot be improved as a function of $(m,c,k,N)$ alone**: any strengthening must use information about the family beyond its marginal profile. (Sanity check of the probability form on this example: $ck/(m(c+m(k-1))) = 6/(2\cdot 6) = 1/2 = |U|/N$.)

### 3.4 Necessity of the pairwise input

**Theorem 3.5 (The second marginal is load-bearing).**
*The Bonferroni-shaped conclusion $|U| \ge kN/(2m)$ — the shape of (1.1) — is false for a family with a perfect first marginal but no pairwise control. Explicitly, with the constant family of Theorem 3.4 ($N = m = 2$, $k = 3$, $|U| = 1$) one has $2m|U| = 4 < 6 = kN$.*

*Proof.* Direct computation, as displayed. $\square$

Theorems 3.4 and 3.5 bracket the situation neatly. The first says no better conclusion can be drawn from the two marginals; the second says that dropping the pairwise marginal invalidates conclusions of this strength altogether. The two hypotheses of Theorem 3.3 are thus exactly the right ones.

### 3.5 The unconditional hashing bound

**Theorem 3.6 (Unconditional lower bound for random hashing).**
*Let $S \subseteq \alpha$, $x \in S$, $M \ge 1$, and $k = |S \setminus \{x\}|$. Then*
$$k \cdot M^{|\alpha|} \;\le\; |\mathrm{fail}(S,x)| \cdot (M + k - 1),$$
*equivalently*
$$\Pr[\mathrm{fail}] \;=\; \frac{|\mathrm{fail}(S,x)|}{M^{|\alpha|}} \;\ge\; \frac{k}{M+k-1},$$
*with no restriction relating $k$ and $M$.*

*Proof.* Apply Theorem 3.3 to the family $A_y = C(y,x)$ indexed by $y \in S\setminus\{x\}$, whose union is $\mathrm{fail}(S,x)$ by (2.1), with ambient size $N = M^{|\alpha|}$, first-marginal parameter $m = M$ (the first marginal is exact: $M\,|C(y,x)| = M^{|\alpha|}$ for $y \ne x$) and second-marginal parameter $c = M^2$ (from $M^2|C(p,x)\cap C(q,x)| \le M^{|\alpha|}$ for distinct $p,q \ne x$). Theorem 3.3 gives
$$M^{2}\,k\,N \;\le\; M\,|\mathrm{fail}|\,\bigl(M^{2} + M(k-1)\bigr) \;=\; M^{2}\,\bigl(|\mathrm{fail}|\,(M+k-1)\bigr),$$
and cancelling $M^2 > 0$ finishes. $\square$

**Theorem 3.7 (Domination of the Bonferroni bound).**
*For $M \ge 1$ and $k \le M+1$ — i.e. throughout the Bonferroni regime $2(k-1)\le M$ and slightly beyond — one has*
$$\frac{k}{2M} \;\le\; \frac{k}{M+k-1}.$$

*Proof.* $k \le M+1$ gives $M + k - 1 \le 2M$, and both denominators are positive. $\square$

**Theorem 3.8 (A converse for random hashing above the pigeonhole rate).**
*If $M \le k$ then*
$$\Pr[\mathrm{fail}] \;>\; \frac{1}{2}.$$

*Proof.* By Theorem 3.6 it suffices that $k/(M+k-1) > 1/2$, i.e. $2k > M+k-1$, i.e. $k > M-1$, which holds. $\square$

Theorem 3.8 is the qualitative payoff. The Bonferroni route can say nothing here: its hypothesis $2(k-1) \le M$ fails and its nominal value $k/(2M)$ can exceed $1$. The second-moment route, using *the same two marginals*, shows that a uniformly random codebook is more likely to fail than to succeed once the typical set has at least $M$ competitors — the random-coding analogue of the pigeonhole converse, and a genuine complement to Shannon's achievability result.

---

## 4. Which marginals? Exact marginals of arbitrary collision patterns

Sections 3.5–3.8 used only two marginals. It is natural to ask how much slack those two contained, and what all the higher marginals are. This section answers both: there is no slack, and all marginals are given by a single geometric law.

### 4.1 Collapse maps

**Definition 4.1 (Collapse event).** For $f : \iota \to \iota$, let
$$\mathrm{Col}(f) \;=\; \{\, H \mid H(f(a)) = H(a) \text{ for all } a \in \iota \,\},$$
the codebooks that are constant on the fibres of $f$, i.e. factor through $f$.

**Theorem 4.2 (Exact marginal of a collapse map).**
*If $f$ is idempotent ($f\circ f = f$) then $|\mathrm{Col}(f)| = M^{\,|f(\iota)|}$.*

*Proof.* Idempotence makes every element of the image a fixed point of $f$. The map $H \mapsto H|_{f(\iota)}$ is a bijection from $\mathrm{Col}(f)$ onto the set of all functions $f(\iota) \to \mathbb{Z}/M$: it is injective because $H(a) = H(f(a))$ recovers $H$ from its restriction, and surjective because for any $g : f(\iota) \to \mathbb{Z}/M$ the codebook $H(a) = g(f(a))$ lies in $\mathrm{Col}(f)$ (using $f(f(a)) = f(a)$) and restricts to $g$ (using $f(s) = s$ on the image). Hence $|\mathrm{Col}(f)| = M^{|f(\iota)|}$. $\square$

**Theorem 4.3 (Pattern marginal via a collapse presentation).**
*Let $P$ be a collision pattern and $f : \iota \to \iota$ idempotent with (i) $f(a) = f(b)$ for every $(a,b) \in P$, and (ii) every $H \in E(P)$ constant on the fibres of $f$. Then $|E(P)| = M^{|f(\iota)|}$.*

*Proof.* Condition (ii) gives $E(P) \subseteq \mathrm{Col}(f)$; condition (i) gives the reverse inclusion, since $H \in \mathrm{Col}(f)$ and $(a,b) \in P$ imply $H(a) = H(f(a)) = H(f(b)) = H(b)$. Apply Theorem 4.2. $\square$

### 4.2 The star marginal

**Theorem 4.4 (Exact star marginal).**
*If $T \subseteq \iota$ and $x \notin T$, then*
$$|\mathrm{Star}(T,x)| \;=\; M^{\,|\iota| - |T|}, \qquad\text{i.e.}\qquad \Pr[\mathrm{Star}(T,x)] = M^{-|T|}.$$

*Proof.* Let $f(a) = x$ for $a \in T$ and $f(a) = a$ otherwise. Since $x \notin T$, $f$ is idempotent, and its image is $\iota \setminus T$, of size $|\iota| - |T|$. A codebook lies in $\mathrm{Star}(T,x)$ exactly when it is constant on the fibres of $f$. Theorem 4.2 gives $M^{|\iota|-|T|}$; dividing by $M^{|\iota|}$ gives the probability. $\square$

Every marginal appearing in any Bonferroni-type or moment-type expansion of the failure event (2.1) is an instance of Theorem 4.4, since intersections of collision events all sharing the vertex $x$ are exactly star events.

**Corollary 4.5 (First marginal, exactly).** For $p \ne q$, $|C(p,q)| = M^{|\iota|-1}$: a prescribed collision has probability exactly $1/M$.

**Corollary 4.6 (The second marginal is an equality).** For distinct $p,q,r$,
$$M^{2}\,\bigl|C(p,r) \cap C(q,r)\bigr| \;=\; M^{|\iota|}.$$
*Proof.* $C(p,r)\cap C(q,r) = \mathrm{Star}(\{p,q\},r)$ with $r \notin \{p,q\}$ and $|\{p,q\}| = 2$; apply Theorem 4.4. $\square$

So the inequality fed into both the Bonferroni route and Theorem 3.6 loses nothing: there was no sharper second marginal to be found, and no refinement of the inputs could have removed the regime restriction. Only replacing the machine could.

**Theorem 4.7 (Two disjoint collisions are exactly independent).**
*Let $p,q,r,s \in \iota$ with $p \ne q$, $r \ne s$, $p \ne r$, $p \ne s$, $q \ne r$. Then*
$$M^{2}\,\bigl|C(p,q) \cap C(r,s)\bigr| \;=\; M^{|\iota|}.$$
*(Note $q = s$ is permitted: only the two collapsed vertices $p, r$ need be distinct from each other and from their targets.)*

*Proof.* Let $f(a) = q$ if $a = p$, $f(a) = s$ if $a = r$, and $f(a) = a$ otherwise. The hypotheses make $f$ idempotent and identify its image as $\iota \setminus \{p,r\}$, of size $|\iota|-2$; and $C(p,q) \cap C(r,s) = \mathrm{Col}(f)$. Apply Theorem 4.2. $\square$

Corollary 4.6 and Theorem 4.7 concern geometrically very different configurations — a path of length two versus two disjoint edges — yet produce the same marginal $1/M^2$. This is the first hint of the general law.

### 4.3 The component law

**Definition 4.8 (Pattern connectivity).** Let $\sim_P$ denote the equivalence relation on $\iota$ generated by the adjacency relation of $P$; its classes are the connected components of the pattern graph, isolated vertices included. Write $c(P)$ for the number of classes.

**Lemma 4.9.** $H \in E(P)$ if and only if $H$ is constant on each $\sim_P$-class.

*Proof.* If $H$ is constant on classes then in particular $H(a) = H(b)$ for every edge. Conversely, if $H$ respects every edge then the relation $\{(a,b) : H(a) = H(b)\}$ is an equivalence relation containing the adjacency relation of $P$, hence contains $\sim_P$; formally, induct over the generation of $\sim_P$ through its reflexive, symmetric and transitive steps. $\square$

**Theorem 4.10 (The component law).**
*For an arbitrary collision pattern $P$ on a finite $\iota$,*
$$|E(P)| \;=\; M^{\,c(P)} .$$
*Equivalently, a uniformly random codebook realises all collisions prescribed by $P$ with probability $M^{-(|\iota| - c(P))}$.*

*Proof.* By Lemma 4.9, $E(P)$ is in bijection with the set of functions from the quotient $\iota/\!\sim_P$ to the label set: the forward map sends $H$ to the induced function on classes (well defined by Lemma 4.9), the inverse composes a function on classes with the quotient projection. The set of such functions has cardinality $M^{c(P)}$. $\square$

Theorem 4.10 makes the collapse maps of Section 4.1 unnecessary in principle; they remain a convenient computational device for evaluating $c(P)$ in concrete families. Comparing the two computations even yields purely graph-theoretic corollaries.

**Corollary 4.11 (Component count of a star, deduced from two enumerations).**
*Let $T \subseteq \iota$, $x \notin T$, and let $P$ be the star pattern joining every $y \in T$ to $x$. If $M \ge 2$ then $c(P) = |\iota| - |T|$.*

*Proof.* Theorem 4.10 gives $|E(P)| = M^{c(P)}$; Theorem 4.4 gives $|E(P)| = M^{|\iota|-|T|}$. For $M \ge 2$ the function $n \mapsto M^n$ is injective, so the exponents agree. $\square$

**Structural conclusion.** The marginals available to *any* inclusion–exclusion-type machinery here are $M^{-(|\iota|-c(P))}$: they depend on the pattern only through its component count and are blind to its shape. Two collisions always cost a factor $M^{-2}$, whether or not they share a vertex. It follows that the regime restriction in (1.1) can be attributed neither to the coarseness of the inputs nor to hidden dependence structure among the events. It belongs to the inequality.

---

## 5. The exact failure law

Having determined all the marginals, one can go further and compute the failure probability outright. The mechanism is a conditional refinement of Corollary 4.5.

**Definition 5.1 (Unconstrained at a coordinate).** An event $G$ of codebooks is *unconstrained at $y$* if it is stable under arbitrary overwriting of the $y$-th label: for every $H \in G$ and every label $v$, the codebook agreeing with $H$ off $y$ and taking value $v$ at $y$ also lies in $G$.

**Theorem 5.2 (Conditional collision marginal).**
*Let $G$ be unconstrained at $y$, and let $y \ne x$. Then*
$$M \cdot |G \cap C(y,x)| \;=\; |G|, \qquad\text{i.e.}\qquad \Pr[\,C(y,x) \mid G\,] = \frac 1M .$$

*Proof.* Exhibit a bijection $(G \cap C(y,x)) \times (\mathbb{Z}/M) \to G$, $(K, v) \mapsto K^{y \mapsto v}$ (overwrite the $y$-th label by $v$). It lands in $G$ because $G$ is unconstrained at $y$. It is injective: from the image one reads off $v$ at coordinate $y$ and all other coordinates of $K$ directly, and $K(y)$ is recovered as $K(x)$, which is an off-$y$ coordinate, using $K \in C(y,x)$ and $y \ne x$. It is surjective: given $H \in G$, take $K = H^{y \mapsto H(x)}$ — which lies in $G$, and in $C(y,x)$ because $K(y) = H(x) = K(x)$ — and $v = H(y)$; then $K^{y \mapsto v} = H$. Counting gives $|G|\cdot 1 = |G \cap C(y,x)| \cdot M$. $\square$

Taking $G$ to be the whole space recovers Corollary 4.5; the point is that the conditional statement survives arbitrary conditioning that leaves the coordinate $y$ free.

**Lemma 5.3.** *If $y \notin D$ and $y \ne x$ then $\mathrm{NC}(D,x)$ is unconstrained at $y$.*

*Proof.* The constraints defining $\mathrm{NC}(D,x)$ involve only the coordinates in $D \cup \{x\}$, none of which is $y$. $\square$

**Lemma 5.4 (One competitor at a time).** *If $y \notin D$ and $y \ne x$ then*
$$M\,\bigl|\mathrm{NC}(D \cup \{y\},x)\bigr| \;=\; (M-1)\,\bigl|\mathrm{NC}(D,x)\bigr|.$$

*Proof.* Write $G = \mathrm{NC}(D,x)$. Then $\mathrm{NC}(D\cup\{y\},x) = G \setminus (G \cap C(y,x))$, so its size is $|G| - |G\cap C(y,x)|$. By Lemma 5.3 and Theorem 5.2, $|G \cap C(y,x)| = |G|/M$; multiplying by $M$ gives $M|\mathrm{NC}(D\cup\{y\},x)| = M|G| - |G| = (M-1)|G|$. $\square$

**Theorem 5.5 (Exact survival count).** *For $x \notin D$ and $k = |D|$,*
$$M^{k}\,\bigl|\mathrm{NC}(D,x)\bigr| \;=\; (M-1)^{k}\,M^{|\iota|}.$$

*Proof.* Induction on $D$. For $D = \varnothing$ the event is everything and both sides are $M^{|\iota|}$. The inductive step is Lemma 5.4 multiplied by $M^{|D|}$. $\square$

**Theorem 5.6 (Exact failure law).** *For $S \subseteq \alpha$, $x \in S$, $k = |S\setminus\{x\}|$ and $M \ge 1$,*
$$M^{k}\,|\mathrm{fail}(S,x)| \;+\; (M-1)^{k}\,M^{|\alpha|} \;=\; M^{k}\,M^{|\alpha|},$$
*equivalently*
$$\Pr[\mathrm{fail}] \;=\; 1 - \Bigl(1 - \frac{1}{M}\Bigr)^{k}.$$

*Proof.* The failure event is the complement of $\mathrm{NC}(S\setminus\{x\},x)$, so the two cardinalities sum to $M^{|\alpha|}$. Multiply by $M^k$ and substitute Theorem 5.5. Dividing by $M^{k+|\alpha|}$ gives the probability form. $\square$

Brute-force enumeration of the full codebook space confirms the law in small cases: for $|\alpha| = 3$, $M = 2$, with every other message a competitor, the count is $2^3 - 1^2\cdot 2 = 6$ out of $8$; for $|\alpha| = 4$, $M = 3$, it is $3^4 - 2^3\cdot 3 = 57$ out of $81$.

**Corollary 5.7 (Shannon bound from the exact law).** $\Pr[\mathrm{fail}] \le k/M$.

*Proof.* Bernoulli's inequality $1 + k t \le (1+t)^k$ with $t = -1/M \ge -1$ gives $1 - k/M \le (1-1/M)^k$; substitute into Theorem 5.6. $\square$

**Corollary 5.8 (Matching lower bound).** $\Pr[\mathrm{fail}] \ge \dfrac{k}{M+k}$.

*Proof.* Bernoulli with $t = 1/M$ gives $1 + k/M \le (1+1/M)^k$. Multiplying by $(1-1/M)^k \ge 0$ and using $\bigl((1+1/M)(1-1/M)\bigr)^k = (1 - 1/M^2)^k \le 1$ yields
$$\Bigl(1+\frac kM\Bigr)\Bigl(1-\frac1M\Bigr)^{k} \le 1, \qquad\text{i.e.}\qquad \Bigl(1-\frac1M\Bigr)^{k} \le \frac{M}{M+k},$$
and Theorem 5.6 converts this into $\Pr[\mathrm{fail}] \ge 1 - M/(M+k) = k/(M+k)$. $\square$

Together, $k/(M+k) \le \Pr[\mathrm{fail}] \le k/M$: random hashing fails with probability $\Theta(\min(1, k/M))$ for **all** $k$ and all $M \ge 1$, with no regime hypotheses.

---

## 6. The hierarchy of marginal-driven bounds

We now locate the second-moment bound (1.2) relative to the exact law. The arithmetic content is an integer Bernoulli inequality.

**Lemma 6.1 (Integer Bernoulli).** *For $M \ge 1$ and $j \ge 0$,*
$$(M-1)^{j}\,(M+j) \;\le\; M^{\,j+1}.$$

*Proof.* Induction on $j$. For $j = 0$ both sides are $M$. For the step, it suffices to know $(M-1)(M+j+1) \le M(M+j)$, i.e. $M^2 + Mj - j - 1 \le M^2 + Mj$, which is clear; multiplying the inductive hypothesis $(M-1)^j(M+j) \le M^{j+1}$ by this and cancelling the positive factor $M+j$ gives $(M-1)^{j+1}(M+j+1) \le M^{j+2}$. $\square$

**Theorem 6.2 (The exact law implies the second-moment bound).** *For $M \ge 1$ and $k \ge 0$,*
$$\frac{k}{M+k-1} \;\le\; 1 - \Bigl(1-\frac1M\Bigr)^{k}.$$

*Proof.* For $k = 0$ both sides are $0$; otherwise write $k = j+1$. Lemma 6.1 gives $(M-1)^j(M+j) \le M^{j+1}$; multiplying by $M-1 \ge 0$ yields $(M-1)^{j+1}(M+j) \le (M-1)M^{j+1}$, i.e.
$$\Bigl(1-\frac1M\Bigr)^{j+1} = \frac{(M-1)^{j+1}}{M^{j+1}} \;\le\; \frac{M-1}{M+j} \;=\; 1 - \frac{j+1}{M+j}.$$
Since $M + k - 1 = M + j$, this is the claim. $\square$

**Theorem 6.3 (Full hierarchy).** *For every $S$, every $x \in S$, every $M \ge 1$ and every $k = |S\setminus\{x\}| \le M+1$,*
$$\frac{k}{2M} \;\le\; \frac{k}{M+k-1} \;\le\; \Pr[\mathrm{fail}] \;=\; 1-\Bigl(1-\frac1M\Bigr)^{k} \;\le\; \frac{k}{M}.$$

*Proof.* The first inequality is Theorem 3.7; the second is Theorem 6.2 combined with the exact law (Theorem 5.6); the equality is Theorem 5.6; the last is Corollary 5.7. $\square$

The classical Bonferroni output is thus the weakest member of a four-term chain, and the middle terms use only the first two marginals. Only the leftmost inequality requires the hypothesis $k \le M+1$; the remaining terms hold unconditionally.

---

## 7. Exact derandomisation

Random coding is a device; the object of interest is a fixed codebook. Classically one averages the union bound over all codebooks: since the expected number of typical messages lost is at most $|S|\cdot(|S|-1)/M$, some codebook loses at most that many. This is vacuous as soon as $|S| - 1 \ge M$ — again the interesting regime. Averaging the exact law instead never is.

**Lemma 7.1 (Incidence double count).**
$$\sum_{H} |\mathrm{bad}(S,H)| \;=\; \sum_{x \in S} |\mathrm{fail}(S,x)|,$$
*the sum on the left over all $M^{|\alpha|}$ codebooks.*

*Proof.* Both sides count incidences $(H,x)$ with $x \in S$ lost by $H$; exchange the order of summation. $\square$

**Theorem 7.2 (Exact derandomisation).** *Let $S \subseteq \alpha$, $M \ge 1$ and $k = |S|-1$. There exists a codebook $H$ with*
$$M^{k}\,|\mathrm{bad}(S,H)| \;\le\; |S|\,\bigl(M^{k} - (M-1)^{k}\bigr).$$

*Proof.* For each $x \in S$, $|S \setminus \{x\}| = k$, so Theorem 5.6 gives $M^k|\mathrm{fail}(S,x)| = M^{|\alpha|}(M^k - (M-1)^k)$. Summing over $x \in S$ and applying Lemma 7.1,
$$M^{k}\sum_{H} |\mathrm{bad}(S,H)| \;=\; |S|\,M^{|\alpha|}\bigl(M^k - (M-1)^k\bigr).$$
Choose $H_0$ minimising $|\mathrm{bad}(S,H)|$; then $M^{|\alpha|}\,|\mathrm{bad}(S,H_0)| \le \sum_H |\mathrm{bad}(S,H)|$, and substituting and cancelling the positive factor $M^{|\alpha|}$ gives the claim. $\square$

**Corollary 7.3 (Fractional form).** *If $S \ne \varnothing$ and $M \ge 1$, some codebook $H$ satisfies*
$$\frac{|\mathrm{bad}(S,H)|}{|S|} \;\le\; 1 - \Bigl(1-\frac1M\Bigr)^{|S|-1}.$$

For $M \ge 2$ the right-hand side is strictly less than $1$ for every $S$: the statement is **never vacuous**, however large the typical set. And it always implies the classical estimate:

**Theorem 7.4 (The exact bound dominates the union bound).** *For all $M, k \ge 0$,*
$$M^{k} \;\le\; (M-1)^{k} + k\,M^{k-1}, \qquad\text{i.e.}\qquad M^k - (M-1)^k \le k M^{k-1},$$
*equivalently $1 - (1-1/M)^k \le k/M$.*

*Proof.* Induction on $k$. The case $k=0$ is trivial. Assuming $M^n \le (M-1)^n + nM^{n-1}$, multiply by $M$:
$$M^{n+1} \le M(M-1)^n + M\cdot nM^{n-1} \le M(M-1)^n + nM^n \le (M-1)^{n+1} + (n+1)M^n,$$
where the last step uses $M(M-1)^n \le (M-1)^{n+1} + M^n$, which follows from $(M-1)^n \le M^n$. $\square$

Thus the exact derandomisation is never worse than the classical one and is strictly better precisely where the classical one degenerates.

---

## 8. Algorithms and applications

### 8.1 Algorithmic content

Three computational procedures are implicit in the development.

1. **Marginal-profile evaluation.** Given a family $A_1,\dots,A_k$ over a universe of size $N$ as bit-vectors, compute $m = N/|A_1|$, $c = \min_{i\ne j} \lfloor N/|A_i\cap A_j|\rfloor$, and output the certified lower bound $ck/(m(c+m(k-1)))$ on $|\bigcup A_i|/N$. The cost is $O(k^2 N/w)$ word operations for word size $w$, dominated by the pairwise intersections; the resulting bound is guaranteed by Theorem 3.3 and, by Theorem 3.4, cannot be improved without further information.

2. **Component-law marginal computation.** Given a collision pattern $P$ on $n$ vertices with $|P|$ edges, compute $c(P)$ by union–find in $O((n+|P|)\,\alpha(n))$ time and output $\Pr[E(P)] = M^{-(n - c(P))}$ exactly, by Theorem 4.10. This replaces any enumeration over $M^n$ codebooks.

3. **Greedy exact derandomisation.** Theorem 7.2 asserts existence; the standard method of conditional expectations turns it into an algorithm. Label the messages of $S$ one at a time; at each step choose the label minimising the conditional expectation of $|\mathrm{bad}(S,H)|$, which by the conditional marginal principle (Theorem 5.2) is computable in closed form from the current bin occupancies. The result is a fixed codebook achieving the bound of Corollary 7.3 in $O(|S|\,M)$ arithmetic operations.

### 8.2 Applications

**Converse bounds in source coding.** Theorem 3.8 supplies the statement that random binning is not merely unproven but actually *bad* above the pigeonhole rate: with $k \ge M$, failure has probability exceeding $1/2$. Together with the achievability bound $k/M$ this pins the operational threshold at $k \asymp M$ from both sides.

**Load balancing and hash tables.** Theorem 5.6 is the exact probability that a designated key collides with at least one of $k$ others in a table with $M$ slots; Corollaries 5.7 and 5.8 sandwich it between $k/(M+k)$ and $k/M$ with no assumptions, and Corollary 7.3 gives an existence statement for a fixed hash function with a bounded fraction of colliding keys.

**Union bounds in probabilistic combinatorics generally.** Theorem 3.3 is stated for arbitrary families and can be applied wherever a first and second marginal are available and the Bonferroni route stalls — for example to threshold phenomena where the number of events grows past the inverse first marginal, precisely the regime Bonferroni forbids.

---

## 9. Discussion and future work

### 9.1 What was established

The regime restriction $2(k-1) \le M$ in the classical converse is an artefact of the second Bonferroni inequality, not of the collision marginals. Three independent lines of evidence support this. (i) The same two marginals, fed to the Chung–Erdős inequality, give an unconditional bound (Theorem 3.6) that dominates the Bonferroni bound wherever the latter applies (Theorem 3.7) and remains informative above the pigeonhole rate (Theorem 3.8). (ii) The marginals themselves contain no slack: the second marginal is an equality (Corollary 4.6), and indeed *all* pattern marginals are computed exactly by the component law (Theorem 4.10). (iii) The abstract theorem extracted from the profile is attained (Theorem 3.4), while the pairwise hypothesis cannot be dropped (Theorem 3.5) — so the second-moment route uses exactly the available information, and uses all of it.

Beyond the structural point, the exact failure law $1-(1-1/M)^k$ (Theorem 5.6) resolves the quantitative question completely, sandwiches the failure probability between $k/(M+k)$ and $k/M$ for all parameters, situates the classical bound at the bottom of a four-term hierarchy (Theorem 6.3), and yields a derandomisation that is never vacuous (Theorem 7.2, Corollary 7.3).

### 9.2 Limitations

The exact law relies on full independence of labels across messages: the survival recursion (Lemma 5.4) needs the no-collision event to be unconstrained at each fresh coordinate. Under $t$-wise independent hash families only the first $t$ marginals are guaranteed, and one is thrown back on inequalities of the type in Section 3 — which is precisely why Theorem 3.3, using only two marginals, matters beyond the fully independent case. Note that Theorem 3.6 needs *pairwise* independence only, so it applies verbatim to pairwise independent (e.g. universal) hash families, whereas the exact law does not.

### 9.3 Future directions

Several concrete directions follow.

* **Higher-order profiles.** Theorem 3.3 uses the first two marginals. What is the optimal union lower bound from the first $t$ marginals, as a function of the profile alone? For $t = 2$ the answer is Theorem 3.3, by the sharpness example. The general question is a moment problem over multiplicity distributions on $\{0,1,\dots,k\}$ with prescribed first $t$ moments, and its answer would give the exact strength of $t$-wise independence in this setting.
* **Non-uniform profiles.** Allowing $m_i$ and $c_{ij}$ to vary with the index yields a weighted Cauchy–Schwarz problem; identifying the extremal configurations there would extend the analysis to non-uniform source distributions.
* **Beyond stars.** The component law makes all marginals available; using more than two of them in a Bonferroni-type expansion, or in a Lovász-local-lemma style argument on the pattern graph, may capture regimes where the second-moment bound is still lossy.
* **Algorithmic derandomisation guarantees.** Making the conditional-expectation derandomisation of Section 8.1 rigorous end to end, with an exact accounting of the loss, would give a deterministic construction matching Corollary 7.3 exactly.

### 9.4 Programme-level directions carried forward

The wider research programme in which this work sits identified the following continuations.

The immediate cycle established: the second-moment (Chung–Erdős) inequality in exact counting form for arbitrary finite families, and an abstract marginal-profile theorem — first marginal $1/m$ plus pairwise marginal at most $1/c$ giving $c\,k\,N \le m|\bigcup A|(c+m(k-1))$ with no restriction on $k$. Fed with the two collision marginals this yields $\Pr[\text{failure}] \ge k/(M+k-1)$, removing the hypothesis $2(k-1)\le M$, and gives a converse to Shannon: $\Pr[\text{failure}] > 1/2$ once $k \ge M$. The abstract bound is proved attained, and the pairwise marginal proved load-bearing. Exact marginals for arbitrary collision patterns follow via idempotent collapse maps: the star marginal $M^{|\iota|-|T|}$, the upgrade of the pairwise bound from $\le$ to $=$, and exact independence of two disjoint collisions. The conditional collision marginal ($1/M$ conditionally on any event not constraining the coordinate) gives the exact failure law $\Pr[\text{failure}] = 1-(1-1/M)^k$, and from it both the Shannon bound $k/M$ and a matching lower bound $k/(M+k)$.

A second loop produced the component law — the marginal of an arbitrary pattern is $M$ to the number of connected components of the pattern graph, with no collapse map needed — a graph-theoretic corollary deducing the component count of a star from two independent enumerations, and the hierarchy theorem $k/(2M) \le k/(M+k-1) \le \Pr[\text{failure}] \le k/M$, which locates the classical Bonferroni output precisely.

A third loop produced exact derandomisation: averaging the exact law instead of the union bound over all codebooks gives $M^k|\mathrm{bad}(H)| \le |S|(M^k-(M-1)^k)$ for some fixed $H$, i.e. a deterministic codebook losing at most a $1-(1-1/M)^{|S|-1}$ fraction of the typical set. The classical bound $|S|(|S|-1)/M$ is vacuous once $|S|-1 \ge M$; the new one never is, and the integer inequality $M^k - (M-1)^k \le kM^{k-1}$ proves it always implies the old one.

Nothing in the plan turned out false, but two formulations had to change. In particular, a first draft of the abstract theorem attempted to *falsify* the second-moment conclusion using a constant family; that family in fact turns the abstract inequality into an equality, and what it falsifies is the stronger Bonferroni-shaped conclusion — which is how Theorems 3.4 and 3.5 came to be stated as a matched pair.

---

## 10. Summary of principal results

| Result | Statement |
|---|---|
| Chung–Erdős counting form (Thm 3.1) | $(\sum_i \lvert A_i\rvert)^2 \le \lvert\bigcup_i A_i\rvert \cdot \sum_{i,j}\lvert A_i\cap A_j\rvert$ |
| Marginal-profile bound (Thm 3.3) | first marginal $1/m$, pairwise $\le 1/c$ $\Rightarrow$ $ckN \le m\lvert U\rvert(c+m(k-1))$, all $k$ |
| Sharpness (Thm 3.4) | attained with equality by a constant family ($m=c=N=2$, $k=3$) |
| Necessity of pairwise input (Thm 3.5) | $\lvert U\rvert \ge kN/(2m)$ fails for that family |
| Unconditional hashing converse (Thm 3.6) | $\Pr[\mathrm{fail}] \ge k/(M+k-1)$ for all $k, M$ |
| Domination (Thm 3.7) | $k/(2M) \le k/(M+k-1)$ whenever $k \le M+1$ |
| Converse above the rate (Thm 3.8) | $k \ge M \Rightarrow \Pr[\mathrm{fail}] > 1/2$ |
| Star marginal (Thm 4.4) | $\lvert\mathrm{Star}(T,x)\rvert = M^{\lvert\iota\rvert - \lvert T\rvert}$, probability exactly $M^{-\lvert T\rvert}$ |
| Component law (Thm 4.10) | $\lvert E(P)\rvert = M^{c(P)}$ for an arbitrary pattern $P$ |
| Conditional marginal (Thm 5.2) | $\Pr[C(y,x)\mid G] = 1/M$ for $G$ unconstrained at $y$ |
| Exact failure law (Thm 5.6) | $\Pr[\mathrm{fail}] = 1-(1-1/M)^k$ |
| Sandwich (Cor 5.7, 5.8) | $k/(M+k) \le \Pr[\mathrm{fail}] \le k/M$, all $k, M$ |
| Hierarchy (Thm 6.3) | $k/(2M) \le k/(M+k-1) \le \Pr[\mathrm{fail}] \le k/M$ for $k \le M+1$ |
| Exact derandomisation (Thm 7.2, Cor 7.3) | some $H$ with $\lvert\mathrm{bad}(S,H)\rvert/\lvert S\rvert \le 1-(1-1/M)^{\lvert S\rvert-1}$ |
| Domination of the union bound (Thm 7.4) | $M^k-(M-1)^k \le kM^{k-1}$ |
