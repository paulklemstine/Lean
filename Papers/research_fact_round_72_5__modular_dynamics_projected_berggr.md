# Trial-Division Equivalence, Guidance Nullity, and Congruence Blindness of the Modular Berggren Descent

**Author:** Aristotle
**Date:** 2026-08-29

---

## Abstract

The Berggren tree enumerates every primitive Pythagorean triple exactly once from the root $(3,4,5)$ under three fixed integer matrices whose entries all lie in $\{-2,-1,1,2,3\}$. Reducing that tree modulo an integer $N$ produces a multiplication-free, deterministic, non-repeating stream of residues, and thereby a superficially attractive integer-factorisation heuristic: walk the tree and test $\gcd(\text{hypotenuse}, N)$ at each node. We give a complete, unconditional analysis of this "hypotenuse dive" and show that it fails for three independent and individually decisive reasons.

First, **trial-division equivalence**. Modulo a semiprime $N = pq$, the set of residues with nontrivial gcd has cardinality exactly $N - 1 - \varphi(N) = p + q - 2$, so the per-node hit density is $(p+q-2)/pq \asymp 1/p_{\min}$. In a finite sampling model we obtain an exact closed form for the number of $t$-node streams on which an inspection schedule $S$ succeeds, and deduce that any schedule with $4|S| < p$ succeeds on fewer than half of all streams. Constant success therefore requires $\Omega(p_{\min})$ inspected nodes: the scaling exponent is $\alpha = 1$, matching the measured $\alpha = 1.007 \pm 0.088$, and no $O(\sqrt{p_{\min}})$ behaviour is possible.

Second, the **guidance null**. The exact count shows that the number of successful streams depends on the inspection schedule *only through its cardinality*. Two schedules of equal size succeed on precisely the same number of streams. No ordering rule, priority queue, traversal shape, or residue-class preference can alter the success probability at matched node budget; every reported improvement at matched compute is an artefact of an unmatched comparison.

Third, **congruence blindness**. We prove from first principles that every prime divisor of the hypotenuse of a primitive Pythagorean triple is $\equiv 1 \pmod 4$. Consequently the hypotenuse dive returns $\gcd = 1$ at every node and every depth on Blum integers $N = pq$ with $p \equiv q \equiv 3 \pmod 4$ — the Rabin and Blum–Blum–Shub moduli — and, when only $p \equiv 3 \pmod 4$, can reach only $p - 1$ of the $p + q - 2$ revealing residue classes.

Finally we prove an unconditional separation from the collision paradigm: a distinct congruent pair yields the factor $p$ exactly, and a birthday estimate gives at least $30\%$ success at $t = 2\lceil\sqrt{p}\,\rceil$ nodes, so at matched budget the pair test dominates every value-testing schedule. Together these results close every face of the modular-descent proposal and suggest a general quadratic-form obstruction to orbit-tree factoring.

**Keywords:** Berggren tree, primitive Pythagorean triples, integer factorisation, trial division, Blum integers, quadratic reciprocity, birthday bound, null result.

---

## 1. Introduction

### 1.1 The Berggren tree

A *Pythagorean triple* is a triple $(a,b,c)$ of positive integers with $a^2 + b^2 = c^2$; it is *primitive* if the only common divisors of $a$, $b$, $c$ are units. Define the three matrices

$$
B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},\qquad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},\qquad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix},
$$

each of which preserves the ternary quadratic form

$$
Q(x,y,z) = x^2 + y^2 - z^2 .
$$

Berggren's theorem (1934) states that the orbit map sending a finite word $u$ in $B_1, B_2, B_3$ to $B_u\,(3,4,5)^{\mathsf T}$ is a bijection onto the set of primitive Pythagorean triples under the customary normalisation. We write $\mathrm{node}(u) = (a_u, b_u, c_u)$ for the triple at address $u$, and call $c_u$ its *hypotenuse*. Applying $B_1, B_2, B_3$ to the root gives $(5,12,13)$, $(21,20,29)$, $(15,8,17)$ respectively.

Two properties of this enumeration are of computational interest.

* **Multiplication-freeness.** Every matrix entry lies in $\{-2,-1,1,2,3\}$, so a child is computed from its parent by additions, subtractions and doublings only. Reducing modulo $N$ costs at most a conditional subtraction per coordinate.
* **Collision-freeness.** Distinct addresses give distinct triples. Empirically the *reduced* stream inherits this: no state repetition was observed within $200\,000$ nodes on any tested modulus.

Both properties are precisely what one wants from a pseudorandom generator intended to drive a gcd-based factoring search.

### 1.2 The hypotenuse dive

**Definition 1.1 (Dive).** Given a modulus $N$, a *hypotenuse dive of budget $t$* traverses $t$ nodes of the mod-$N$ Berggren tree, obtaining residues $c_1, \dots, c_t \bmod N$, and computes $\gcd(c_i, N)$ for $i$ in an inspection schedule $S \subseteq \{1,\dots,t\}$ chosen in advance by any rule whatsoever. The dive *succeeds* if some inspected gcd is a nontrivial divisor of $N$.

The proposal under test is that the tree's structure — its confinement to a few residue classes, its collision-freeness, its determinism — might make this dive behave like a structured random walk with $O(\sqrt{p_{\min}})$ cost, as Pollard's rho does, rather than like trial division with $O(p_{\min})$ cost.

Empirical measurement over $200$ independent order-free dives returned a first-success node count $v^* \approx 0.89\,p_{\min}$ and a fitted scaling exponent

$$
\alpha = 1.007 \pm 0.088 ,
$$

with constants roughly $11\times$ worse than plain trial division at matched compute, and with the ambient orbit under-sampling factor-revealing residues by about a factor of $5$ relative to uniformly random Pythagorean points. This paper proves the theorems behind all three of those numbers.

### 1.3 Organisation

Section 2 establishes the congruence law for primitive hypotenuses and its consequences for Blum integers. Section 3 develops the exact combinatorics of gcd dives in a finite sampling model, giving the trial-division scaling theorem and the guidance null. Section 4 couples the two, quantifying the structural under-sampling. Section 5 proves the unconditional separation from the pair (rho) paradigm. Section 6 discusses the experimental picture, the artefact that produced spurious significance scores, and the algorithmic content. Section 7 states the conjectural generalisation.

---

## 2. The congruence law: primitive hypotenuses are $1 \bmod 4$-smooth

Throughout this section $(a,b,c)$ is a triple of integers with $a^2 + b^2 = c^2$, and *primitive* means that every $d \in \mathbb{Z}$ dividing all of $a$, $b$, $c$ is a unit.

### 2.1 Parity

**Lemma 2.1 (Odd hypotenuse).** *If $(a,b,c)$ is a primitive Pythagorean triple then $c$ is odd.*

*Proof sketch.* Suppose $c = 2k$ and split on the parities of $a$ and $b$.

- If $a = 2s$ and $b = 2t$, then $2$ divides $a$, $b$ and $c$, contradicting primitivity.
- If $a = 2s$ and $b = 2t+1$, then $a^2 + b^2 \equiv 1 \pmod 4$ while $c^2 = 4k^2 \equiv 0 \pmod 4$; rearranging the identity exhibits $4 \mid 1$, absurd.
- The case $a$ odd, $b$ even is symmetric.
- If both are odd, $a^2 + b^2 \equiv 2 \pmod 4$ while $c^2 \equiv 0 \pmod 4$; rearranging exhibits $4 \mid 2$, absurd. $\square$

### 2.2 Primes on the hypotenuse miss both legs

**Lemma 2.2.** *Let $(a,b,c)$ be primitive and $p$ a prime with $p \mid c$. Then $p \nmid a$ and $p \nmid b$.*

*Proof sketch.* Suppose $p \mid a$. From $b^2 = c^2 - a^2$ and $p \mid c$, $p \mid a$ we get $p \mid b^2$, hence $p \mid b$ since $p$ is prime. Then $p$ is a common divisor of $a$, $b$, $c$, so primitivity forces $p$ to be a unit, contradicting $p \ge 2$. The statement for $b$ follows by swapping the legs, which preserves both the identity and primitivity. $\square$

### 2.3 The main congruence

**Theorem 2.3 (Hypotenuse congruence law).** *Let $(a,b,c)$ be a primitive Pythagorean triple and $p$ a prime dividing $c$. Then $p \equiv 1 \pmod 4$.*

*Proof sketch.* By Lemma 2.1, $c$ is odd, so $p \ne 2$. By Lemma 2.2, $p \nmid b$, so $b$ is invertible in $\mathbb{F}_p$. Reducing $a^2 + b^2 = c^2$ modulo $p$ and using $c \equiv 0$ gives $a^2 + b^2 \equiv 0 \pmod p$, hence

$$
\left(a\,b^{-1}\right)^2 \equiv -1 \pmod p .
$$

So $-1$ is a quadratic residue modulo the odd prime $p$, which by Euler's criterion happens if and only if $p \equiv 1 \pmod 4$. As $p$ is odd, $p \bmod 4 \in \{1,3\}$, and the criterion excludes $3$. $\square$

**Remark 2.4 (What the theorem really says).** The content is that the binary form $x^2 + y^2$ is *anisotropic* modulo any prime $p \equiv 3 \pmod 4$: its only zero over $\mathbb{F}_p$ is $(0,0)$. The Pythagorean cone $Q = 0$ intersected with the hyperplane $z \equiv 0$ therefore has no nonzero $\mathbb{F}_p$-points at such primes. Nothing about triangles is used, only the definiteness of the restricted form. This observation drives the conjecture of Section 7.

### 2.4 Transport to the tree

Every node of the Berggren tree is a primitive Pythagorean triple with positive entries: the matrices preserve $Q$ and preserve primitivity, and the root $(3,4,5)$ is primitive. Writing $c_u \in \mathbb{N}$ for the hypotenuse at address $u$:

**Corollary 2.5.** *For every address $u$ and every prime $p \mid c_u$ we have $p \equiv 1 \pmod 4$.*

**Corollary 2.6 (Coprimality to $3 \bmod 4$ moduli).** *If every prime factor of $N$ is $\equiv 3 \pmod 4$ then $\gcd(c_u, N) = 1$ for every $u$.*

*Proof sketch.* If the gcd exceeded $1$ it would have a prime factor $r$; then $r \mid c_u$ gives $r \equiv 1 \pmod 4$ by Corollary 2.5, while $r \mid N$ gives $r \equiv 3 \pmod 4$ by hypothesis. Contradiction. $\square$

### 2.5 Blum-integer immunity

**Definition 2.7.** $N$ is a *Blum integer* if $N = pq$ with $p, q$ prime and $p \equiv q \equiv 3 \pmod 4$. These are the moduli of Rabin encryption and of the Blum–Blum–Shub generator.

**Theorem 2.8 (Blum immunity).** *If $N$ is a Blum integer then $\gcd(c_u, N) = 1$ for every address $u$, at every depth.*

*Proof sketch.* Any prime factor of $N = pq$ equals $p$ or $q$, both $\equiv 3 \pmod 4$; apply Corollary 2.6. $\square$

Thus on a positive-density family of cryptographically standard moduli the hypotenuse dive is not merely slow: it transmits *zero* information, at any budget, for all time. Traversing the entire infinite tree yields the constant sequence $1, 1, 1, \dots$ (For instance $21 = 3 \cdot 7$ is a Blum integer, and the gcd is $1$ at every node.)

**Theorem 2.9 (One bad prime suffices).** *Let $N = pq$ with $p, q$ prime and $p \equiv 3 \pmod 4$. Then $p \nmid c_u$ for every $u$, and consequently $\gcd(c_u, N) \in \{1, q\}$ for all $u$.*

*Proof sketch.* $p \nmid c_u$ is immediate from Corollary 2.5. Hence $g = \gcd(c_u, N)$ is coprime to $p$ and divides $pq$, so $g \mid q$; primality of $q$ gives $g \in \{1,q\}$. $\square$

### 2.6 Sharpness

Two examples delimit the phenomenon exactly.

* **The obstruction is congruence, not search depth.** For $N = 65 = 5 \cdot 13$ (both primes $1 \bmod 4$) the dive splits $N$ at depth two: the node with address $B_3 B_2$ has hypotenuse $85$, and $\gcd(85,65) = 5$. The dive is perfectly capable of succeeding when the arithmetic permits.
* **The law concerns the hypotenuse only.** The legs carry no congruence restriction: the child $B_1(3,4,5) = (5,12,13)$ has a leg divisible by $3$. A leg-based dive is therefore not structurally blind on Blum moduli — but it remains trial-division-class by Section 3, which applies to any value stream.

---

## 3. Exact combinatorics of gcd dives

We now analyse dives in a clean finite model that is *generous* to the heuristic: values are drawn uniformly and independently from $\mathbb{Z}/N$, i.e. the tree is granted perfect pseudorandomness. Every negative result proved here therefore holds a fortiori for the actual, structurally constrained stream.

### 3.1 Revealing residues

**Definition 3.1.** A residue $x$ *reveals* a factor of $N$ if $1 < \gcd(x,N) < N$. Write
$$\mathcal{R}(N) = \{x < N : x \text{ reveals}\}, \qquad \mathcal{A}(N) = \{x < N : x \text{ does not reveal}\}.$$

**Lemma 3.2 (Structure of the non-revealing set).** *For $N \ge 2$,*
$$\mathcal{A}(N) = \{0\} \cup \{x < N : \gcd(x,N) = 1\}.$$

*Proof sketch.* If $x$ does not reveal then $\gcd(x,N) \le 1$ or $\gcd(x,N) \ge N$. In the first case the gcd is nonzero (as $N \ge 2$), hence $1$, so $x$ is a unit. In the second case $\gcd(x,N) = N$ forces $N \mid x$ with $x < N$, i.e. $x = 0$. The converse is immediate. $\square$

**Theorem 3.3 (Hit count).** *For $N \ge 2$, $\;|\mathcal{R}(N)| = N - 1 - \varphi(N)$.*

*Proof sketch.* $|\mathcal{R}(N)| + |\mathcal{A}(N)| = N$, and Lemma 3.2 gives $|\mathcal{A}(N)| = 1 + \varphi(N)$ since $0$ is not coprime to $N$. $\square$

**Corollary 3.4 (Semiprime hit count).** *If $N = pq$ with $p \ne q$ prime then $|\mathcal{R}(pq)| = p + q - 2$.*

*Proof sketch.* $\varphi(pq) = (p-1)(q-1)$, and $pq - 1 - (p-1)(q-1) = p + q - 2$. $\square$

*Example.* $\mathcal{R}(15) = \{3,5,6,9,10,12\}$, of size $6 = 3 + 5 - 2$.

The **per-node hit density** is therefore
$$
\delta(p,q) = \frac{p+q-2}{pq} = \frac 1p + \frac 1q - \frac{2}{pq} \;\asymp\; \frac{1}{p_{\min}} .
$$
Everything in this section is a rigorous consequence of that single number.

### 3.2 Streams and schedules

**Definition 3.5.** The *stream space* of budget $t$ is $\Omega_{N,t} = (\mathbb{Z}/N)^{\{1,\dots,t\}}$, of cardinality $N^t$. For $S \subseteq \{1,\dots,t\}$ the *success set* is
$$
H(N,t,S) = \{ f \in \Omega_{N,t} : \exists\, i \in S,\; f(i) \in \mathcal{R}(N) \}.
$$

A schedule models an arbitrary guidance heuristic: any rule deciding in advance which of the $t$ visited nodes to gcd-test, in any order.

**Theorem 3.6 (Exact success count).** *For all $N, t$ and every $S$,*
$$
|H(N,t,S)| \;=\; \bigl(N^{|S|} - |\mathcal{A}(N)|^{|S|}\bigr)\cdot N^{\,t-|S|}
\;=\; \bigl(N^{|S|} - (N-r)^{|S|}\bigr)\cdot N^{\,t-|S|},
$$
*where $r = |\mathcal{R}(N)|$.*

*Proof sketch.* The complement consists of the streams avoiding $\mathcal{R}(N)$ on $S$ and unconstrained elsewhere; it is the product set $\prod_j A_j$ with $A_j = \mathcal{A}(N)$ for $j \in S$ and $A_j = \mathbb{Z}/N$ otherwise, of cardinality $|\mathcal{A}(N)|^{|S|} N^{t-|S|}$. Subtract from $N^t$. $\square$

### 3.3 The guidance null

**Theorem 3.7 (Guidance null, sharp form).** *If $|S| = |T|$ then $|H(N,t,S)| = |H(N,t,T)|$.*

*Proof sketch.* Immediate from Theorem 3.6: the right-hand side depends on $S$ only through $|S|$. $\square$

**Theorem 3.8 (Order invariance).** *For any permutation $\sigma$ of $\{1,\dots,t\}$ and any stream $f$, the stream $f \circ \sigma$ contains a revealing value if and only if $f$ does.*

Theorems 3.7–3.8 are the formal content of the guidance null. Three consequences deserve emphasis.

1. *Selection rules are powerless.* Choosing which nodes to test by any criterion — residue class, nonzero-digit histogram, learned score — leaves the success count unchanged at fixed $|S|$.
2. *Traversal shape is powerless.* Depth-first, breadth-first, best-first, random order: all identical.
3. *Scaling is exact.* $|H(N,t,S)| = \bigl(N^{s} - (N-r)^{s}\bigr) N^{t-s}$ with $s = |S|$, so examining $s$ of $t$ nodes has exactly the success *rate* of examining the first $s$. There is no hidden benefit to spreading inspections out.

An immediate corollary is methodological: any experiment reporting an improvement at matched node budget is reporting an artefact. Section 6 identifies the specific artefact.

### 3.4 Union bound and trial-division scaling

**Lemma 3.9 (Convexity estimate).** *For all naturals $b, d, s$: $\;(b+d)^{s+1} \le b^{s+1} + (s+1)\,d\,(b+d)^{s}$.*

*Proof sketch.* Induction on $s$. The step multiplies the hypothesis by $(b+d)$ and absorbs the cross term using $b^{s+1} \le (b+d)^{s+1}$. $\square$

**Theorem 3.10 (Union bound).** *If $|S| \ge 1$ then $\;|H(N,t,S)| \le |S| \cdot r \cdot N^{\,t-1}$, where $r = |\mathcal{R}(N)|$.*

*Proof sketch.* Write $a = N - r$. Lemma 3.9 with $b = a$, $d = r$ and $s+1 = |S|$ gives $N^{|S|} \le a^{|S|} + |S|\,r\,N^{|S|-1}$; multiply by $N^{t-|S|}$ and combine with Theorem 3.6. $\square$

**Theorem 3.11 (Trial-division scaling; $\alpha = 1$).** *Let $N = pq$ with $p \le q$ distinct primes and let $S$ be any schedule with $4|S| < p$. Then*
$$
2\,|H(N,t,S)| \;<\; N^t ,
$$
*i.e. the dive succeeds on strictly fewer than half of all value streams.*

*Proof sketch.* If $S = \emptyset$ the success set is empty and the claim is trivial. Otherwise Theorem 3.10 and Corollary 3.4 give $|H| \le s\,(p+q-2)\,N^{t-1}$ with $s = |S|$, so it suffices to establish the arithmetic inequality
$$
2s\,(p+q-2) < pq \qquad \text{whenever } 4s < p \le q .
$$
Since $p - 2 < q$ we have $p + q - 2 < 2q$, so $2s(p+q-2) < 4sq < pq$. Multiplying the strict inequality by the positive quantity $N^{t-1}$ and using $N \cdot N^{t-1} = N^{t}$ completes the argument. $\square$

**Corollary 3.12 (Linear lower bound).** *Under the hypotheses of Theorem 3.11, if the dive succeeds on at least half of all streams then $p \le 4|S|$.*

This is the precise sense in which the dive is trial-division-class: the number of inspected nodes needed for constant success probability is $\Theta(p_{\min})$. Writing the cost as $p_{\min}^{\alpha}$ gives $\alpha = 1$, in agreement with the measured $\alpha = 1.007 \pm 0.088$ and $v^* \approx 0.89\,p_{\min}$. A $\sqrt{p_{\min}}$ law is *impossible* in this model, for any stream, guided or not.

---

## 4. Coupling: quantified under-sampling of the tree

Section 3 grants the tree perfect randomness. Section 2 shows the real tree is worse. We now measure how much worse.

**Lemma 4.1 (Multiples of $q$).** *For $q \ge 1$, the number of $x < pq$ with $q \mid x$ is exactly $p$.*

**Theorem 4.2 (Reachable revealing residues).** *Let $N = pq$ with $p \ne q$ prime. The revealing residues not divisible by $p$ are exactly the nonzero multiples of $q$ below $N$, and there are $p - 1$ of them.*

*Proof sketch.* If $x$ reveals and $p \nmid x$, then $\gcd(x,pq) > 1$ has a prime factor dividing both $x$ and $pq$; it cannot be $p$, so it is $q$, giving $q \mid x$. Also $x \ne 0$, since $\gcd(0,N) = N$ does not reveal. Conversely, if $0 < x < pq$ and $q \mid x$ then $q \mid \gcd(x,pq)$, so the gcd exceeds $1$; it is smaller than $N$, else $N \mid x$ with $0 < x < N$; and $p \nmid x$, for otherwise $pq \mid x$ by coprimality of $p$ and $q$. Count with Lemma 4.1 and remove $x = 0$. $\square$

**Theorem 4.3 (Structural under-sampling).** *Let $N = pq$ with $p, q$ distinct primes and $p \equiv 3 \pmod 4$. Then (i) $p \nmid c_u$ for every address $u$; and (ii) the number of revealing classes the hypotenuse stream can reach is $p - 1$, strictly less than the total $p + q - 2$.*

*Proof sketch.* (i) is Theorem 2.9. For (ii) combine Theorem 4.2 with Corollary 3.4 and note $p - 1 < p + q - 2$ because $q \ge 2$. $\square$

Interpretation: projecting the tree modulo $N$ *loses* hit density. The effective density seen by the hypotenuse dive is at most
$$
\frac{p-1}{pq} \;<\; \frac{p+q-2}{pq},
$$
and in the balanced case $p \approx q$ this is a loss of roughly a factor of $2$ from congruence alone, on top of any further deficit caused by the orbit's confinement to a small number of nonzero-digit histogram classes (about $99.75\%$ of the observed orbit occupies two such classes). The measured $\approx 5\times$ under-sampling of factor-revealing residues relative to uniform Pythagorean points is thus partly explained by an exact theorem and partly by orbit concentration. In the Blum case the loss is total: zero reachable classes.

---

## 5. Unconditional separation: why the pair test dominates

The rho paradigm does not test values; it tests *differences*.

**Theorem 5.1 (A collision yields the factor exactly).** *Let $p, q$ be primes, $0 \le x < y < pq$, and suppose $x \equiv y \pmod p$. Then $\gcd(y-x,\;pq) = p$.*

*Proof sketch.* From $x \equiv y \pmod p$ and $x < y$ we get $p \mid y-x$, hence $p \mid g := \gcd(y-x,pq)$; write $g = pk$. Since $g \mid pq$ we get $k \mid q$, so $k = 1$ or $k = q$. If $k = q$ then $g = pq$ divides $y - x$, which is positive and less than $pq$ — impossible. Hence $g = p$. $\square$

Note the strength: the gcd is not merely nontrivial, it is the prime itself.

**Definition 5.2.** A stream $f$ of budget $t$ is a *pair hit* modulo $p$ if there are indices $i,j$ with $f(i) \ne f(j)$ and $f(i) \equiv f(j) \pmod p$. Write $H_\rho(p,q,t)$ for the set of pair hits in $\Omega_{pq,t}$. By Theorem 5.1, membership in $H_\rho$ is genuinely a factorisation event.

**Lemma 5.3 (Injection bound).** *The streams whose values are pairwise distinct modulo $p$ number at most $p^{\underline{t}}\,q^{t}$, where $p^{\underline t} = p(p-1)\cdots(p-t+1)$.*

*Proof sketch.* Map $f \mapsto (\,i \mapsto f(i) \bmod p,\; i \mapsto \lfloor f(i)/p\rfloor\,)$. The first component is an injection $\{1,\dots,t\} \hookrightarrow \mathbb{Z}/p$ by hypothesis, the second lands in $\{0,\dots,q-1\}$ since $f(i) < pq$, and division with remainder makes the pair determine $f$, so the map is injective. Count the target: $p^{\underline t}$ injections times $q^t$ free choices. $\square$

**Lemma 5.4 (Repeat bound).** *The streams that repeat a value number at most $(t^2-t)\,N^{t-1}$.*

*Proof sketch.* For fixed $i \ne j$, the streams with $f(i) = f(j)$ number at most $N^{t-1}$: choose the common value and the other $t-2$ coordinates freely. Union over the $t^2 - t$ ordered pairs. $\square$

**Lemma 5.5 (Complement bound).** *The streams that are not pair hits number at most $p^{\underline{t}} q^{t} + (t^2-t)N^{t-1}$.*

*Proof sketch.* A non-hit either has all values distinct — in which case distinct values must also be distinct modulo $p$, so Lemma 5.3 applies — or repeats a value, and Lemma 5.4 applies. $\square$

**Lemma 5.6 (Falling-factorial estimates).** *For all $p,a,b$: $\;p^{\underline{a+b}} \le p^{a}(p-a)^{b}$. For all $p,d,k$: $\;p^{k+1} + (k+1)dp^{k} \le (p+d)^{k+1}$.*

**Theorem 5.7 (Birthday inequality).** *If $1 \le p \le m^2$ then $\;2\,p^{\underline{2m}} \le p^{2m}$.*

*Proof sketch.* By Lemma 5.6, $p^{\underline{2m}} \le p^m (p-m)^m$. Also $(p-m)(p+m) \le p^2$, whence $(p-m)^m(p+m)^m \le p^{2m}$. Finally the two-term binomial bound with $d = m$, together with $p \le m^2$, gives $2p^m \le (p+m)^m$. Chaining, $2p^{\underline{2m}} \le 2p^m(p-m)^m \le (p+m)^m(p-m)^m \le p^{2m}$. $\square$

This is the birthday paradox in exact integer form: once $t = 2m$ with $p \le m^2$ — that is, $t \ge 2\sqrt p$ — fewer than half of all $t$-tuples of residues mod $p$ are pairwise distinct.

**Theorem 5.8 (Birthday success bound).** *Let $N = pq$ with $p, q$ prime, $p \ge 5$, and let $t = 2m$ with $p \le m^2$ and $t^2 \le q$. Then*
$$
3\,N^{t} \;\le\; 10\,|H_\rho(p,q,t)| ,
$$
*i.e. the pair test succeeds on at least $30\%$ of all value streams.*

*Proof sketch.* By Lemma 5.5 the complement splits in two. Theorem 5.7 bounds the first piece by half of $N^t$: indeed $2p^{\underline t} q^t \le p^t q^t = N^t$. The second obeys $5(t^2-t)N^{t-1} \le N^t$, using $t^2 - t \le q$ and $5 \le p$, since then $5(t^2-t) \le pq = N$. Hence the complement is at most $\tfrac12 N^t + \tfrac15 N^t = \tfrac{7}{10}N^t$, leaving at least $\tfrac{3}{10}N^t$ successes. $\square$

**Theorem 5.9 (Rho dominates the dive at matched compute).** *Let $N = pq$ with $p \ne q$ prime, $5 \le p \le q$, budget $t = 2m$ with $p \le m^2$, $t^2 \le q$ and $4t < p$. Then simultaneously: every value-testing schedule $S \subseteq \{1,\dots,t\}$ satisfies $2|H(N,t,S)| < N^t$, while the pair test satisfies $3N^t \le 10\,|H_\rho(p,q,t)|$.*

*Proof sketch.* The first is Theorem 3.11 with $|S| \le t$ and $4t < p$; the second is Theorem 5.8. $\square$

**Corollary 5.10 (Concrete instance).** *Take $N = 101 \cdot 487 = 49\,187$ and $t = 22$, so $m = 11$, $p = 101 \le 121$, $t^2 = 484 \le 487$ and $4t = 88 < 101$. Every gcd-dive schedule succeeds on under half of all streams, while the pair test succeeds on at least $30\%$.*

The hypotheses of Theorem 5.9 are simultaneously satisfiable for arbitrarily large $p$: choose $m \approx \sqrt p$ and $q \gtrsim 4p$. In that regime $t \asymp \sqrt p$, whereas by Corollary 3.12 a value dive needs $\Omega(p)$ inspections. The separation is quadratic and unconditional within the model.

---

## 6. Discussion

### 6.1 What survives of the proposal

Every attractive feature of the modular Berggren descent is real: multiplication-free expansion with coefficients in $\{-2,-1,1,2,3\}$; no state repetition within $200\,000$ nodes on any tested modulus; and confinement of about $99.75\%$ of the observed orbit to two nonzero-digit histogram classes. None of it converts into factoring power. The failure is *structural*, not a matter of tuning: a better traversal, a better data structure, a better scoring function, or a hundredfold larger budget all leave the theorems untouched.

### 6.2 The artefact behind the spurious significance

Guided variants of the dive initially reported improvements at significance scores of $z = 12$–$24$. Theorem 3.7 says such improvements cannot exist at matched node budget. The resolution is that the comparison, not the heuristic, carried the signal: a control that merely *randomises the visitation order* — introducing no guidance at all — reproduced $z = 21.8$ against the same baseline. The effect was therefore a pure traversal-shape artefact of an unpaired comparison. Under a correctly paired protocol every honest $|z|$ falls below $2$, and the pre-registered null is confirmed.

The methodological lesson generalises. When an exact combinatorial identity says a quantity depends on the budget alone, any measured dependence on anything else localises a defect in the measurement. Theorem 3.7 is, in that sense, a debugging tool.

### 6.3 The constant factor

Even ignoring congruence blindness, the dive at density $\delta = (p+q-2)/pq$ requires about $p_{\min}$ node expansions, each costing several modular additions across three coordinates plus a gcd. Trial division requires about $p_{\min}/\ln p_{\min}$ divisions if restricted to primes, or $p_{\min}$ cheap remainders if not, at a lower cost per step. The measured penalty was roughly $11\times$ at matched compute. Both are exponential in the bit length of $p_{\min}$; the interesting comparison is with rho at $O(\sqrt{p_{\min}})$, and Theorem 5.9 shows that comparison is lost unconditionally.

### 6.4 Algorithmic summary

Three algorithms are implicit in the analysis.

1. **Multiplication-free modular tree expansion.** Maintain a frontier of triples mod $N$; expand a node by three matrix applications, each a fixed pattern of additions, doublings and conditional reductions. Cost: $O(1)$ modular additions per child, i.e. $O(\log N)$ bit operations.
2. **Hypotenuse gcd dive.** Traverse the expansion, computing $\gcd(c,N)$ at inspected nodes; cost $O(\log^2 N)$ per inspection. Expected inspections to success: $\Theta(p_{\min})$ when both primes are $1 \bmod 4$; never, when both are $3 \bmod 4$.
3. **Pair (difference) test on the same stream.** Store residues, or use cycle detection on differences, and test $\gcd(c_j - c_i, N)$; expected budget $O(\sqrt{p_{\min}})$ for an unconstrained stream.

A subtlety in item 3 deserves emphasis. A stream that is *known* to be collision-free defeats a naive pair test on values; the collision-freeness advertised as a virtue of the tree is, in the rho paradigm, a liability. Theorem 5.8 is a statement about unconstrained streams; for the Berggren stream one needs collisions of the *reduced* orbit modulo the unknown prime, which is a genuinely different question (see Section 7).

### 6.5 Scope and limitations

The counting theorems are proved in a finite uniform sampling model. This is a *hypothesis-free upper bound* on the real dive: the actual stream is deterministic and, by Section 2, provably worse than uniform on a positive-density set of moduli. Conversely, Theorem 5.8's lower bound for the pair test assumes uniformity, so it is a statement about the paradigm rather than about the particular tree stream. The unconditional statements — the congruence law, Blum immunity, the exact hit counts, the guidance null — depend on no randomness assumption at all.

---

## 7. Future directions

The congruence law of Theorem 2.3 is, as Remark 2.4 observes, not about Pythagorean triples. It is the statement that a certain binary form is anisotropic at half the primes. This suggests the following.

**Conjecture 7.1 (Quadratic-form obstruction to tree-based factoring).** *Let $\Gamma \le \mathrm{SO}(Q,\mathbb{Z})$ be a finitely generated group preserving an integral ternary quadratic form $Q$ of signature $(2,1)$, acting on a $\Gamma$-orbit $\mathcal{O}$ of primitive points, and let $\lambda$ be a nonzero linear functional. Then the set of primes dividing $\lambda(v)$ for some $v \in \mathcal{O}$ is contained in a union of finitely many Chebotarev classes determined by the splitting field of $Q$ restricted to $\ker \lambda$; in particular it has density at most $1/2$ among all primes whenever $Q|_{\ker\lambda}$ is definite.*

The Pythagorean case is $Q = x^2 + y^2 - z^2$ with $\lambda = z$, so $Q|_{\ker\lambda} = x^2+y^2$ is definite and the admissible primes are exactly those $\equiv 1 \pmod 4$ — density $1/2$, with the bound attained.

**A first test.** Prove the binary case: for $\lambda$ with $Q|_{\ker\lambda} \cong ax^2 + by^2$, show that $p \mid \lambda(v)$ for $v \in \mathcal{O}$ forces the Legendre-symbol condition $\left(\tfrac{-ab}{p}\right) = 1$. This is a direct generalisation of Section 2: reduce the vanishing form modulo $p$ and invert one coordinate.

**If true.** Every "factor by walking a hyperbolic orbit tree" proposal inherits an unconditional blind spot of density at least $1/2$, and the class of such proposals is dismissed by one structural theorem rather than case by case.

**If false.** A functional whose divisor primes are unrestricted would be the first genuine candidate for a non-null tree dive — though it would still face the trial-division scaling and guidance nullity of Section 3, which are insensitive to the arithmetic of the stream.

Three further questions seem tractable.

* **Legs instead of hypotenuses.** The legs carry no congruence obstruction. Does the leg stream reach the full $p+q-2$ revealing classes with the correct density, and is its measured $\alpha$ also $1$? The theory of Section 3 predicts yes; the experiment is cheap.
* **Density of the orbit in residue classes.** Quantify the observed $\approx 99.75\%$ concentration in two nonzero-digit histogram classes as an equidistribution statement for the reduced orbit, and derive the residual under-sampling factor rigorously.
* **Composing with a hidden reduction.** Since the tree stream is collision-free by construction, the pair test needs the reduction modulo the unknown prime to induce collisions. Whether the reduced Berggren orbit mod $p$ behaves like a random map — with the associated $\sqrt p$ cycle structure — is the one remaining question not settled by the theorems above.

---

## 8. Conclusion

The modular Berggren descent is a clean and genuinely elegant construction: a multiplication-free, deterministic, collision-free enumeration of the primitive Pythagorean cone modulo $N$. As a factoring device it is null, and the nullity is now fully accounted for by three independent theorems.

1. **Trial-division equivalence.** The revealing residues modulo $pq$ number exactly $p+q-2$; any inspection schedule with $4|S| < p$ succeeds on fewer than half of all streams; constant success costs $\Omega(p_{\min})$ nodes; $\alpha = 1$, matching the measured $1.007 \pm 0.088$.
2. **Guidance nullity.** The success count depends on the inspection schedule only through its cardinality. Guidance at matched budget is provably impossible, and every reported improvement is an artefact of comparison — as confirmed by a random-order control reproducing the entire apparent effect.
3. **Congruence blindness.** Every prime divisor of a primitive hypotenuse is $\equiv 1 \pmod 4$; the dive is identically blind on Blum integers and reaches at most $p-1$ of the $p+q-2$ revealing classes when $p \equiv 3 \pmod 4$.

Against these, a pair test on the same budget succeeds at least $30\%$ of the time at $t \approx 2\sqrt p$, an unconditional quadratic separation in favour of the collision paradigm.

A negative result of this shape is worth more than a tuned heuristic: it converts an open-ended engineering question — "could a smarter traversal of the Pythagorean tree factor integers?" — into a closed one, with the exact obstruction identified and, in the third case, a conjecturally general form that would settle an entire family of similar proposals at once.
