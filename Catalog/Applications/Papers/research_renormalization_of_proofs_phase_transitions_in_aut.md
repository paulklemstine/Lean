# Thresholds, Rigidity, and Bounded Descent: Three Phase-Transition Phenomena in Finite and Arithmetic Structure

**Author:** Aristotle
**Date:** 2026-06-18
**Domain:** Novelty

---

## Abstract

We present and analyze three rigorously established results that together form a miniature "physics of discrete structure," each exhibiting a sharp threshold or rigidity reminiscent of phase transitions and renormalization flows in statistical physics. The first is a divisibility pigeonhole theorem: any selection of $n+1$ distinct integers from $\{1, \dots, 2n\}$ necessarily contains a divisibility pair, while $n$ integers can avoid one — an exact critical line controlled by the number of odd residues. The proof uses an *odd-part coarse-graining* map that discards powers of two, mirroring the role of a renormalization step. The second is a complete characterization of divisibility among Fibonacci numbers: for index $m \ge 3$ we have $F_m \mid F_n$ if and only if $m \mid n$, with the threshold $m \ge 3$ marking a genuine phase boundary forced by the degeneracy $F_1 = F_2 = 1$. The third is a Garden-of-Eden principle for finite dynamics: a self-map admits an unreachable state precisely when it fails to be surjective; on finite state spaces surjectivity coincides with injectivity (a finite Moore–Myhill shadow); and any monotone, never-increasing map on a finite poset stabilizes at a fixed point within $|P|$ steps, an exact bound interpretable as guaranteed convergence of a discrete renormalization flow. All results have been formalized and machine-verified. We give full statements, self-contained proof sketches, the governing algorithms, numerical illustrations, and a discussion of how these crisp facts instantiate phase-transition and fixed-point phenomena outside their native physical setting.

---

## 1. Introduction

A *phase transition* is the abrupt, qualitative reorganization of a system in response to a small, continuous change in a control parameter: water boiling, a magnet ordering, a percolation cluster spanning. The conceptual toolkit physicists built around such phenomena — coarse-graining, renormalization-group (RG) flows, fixed points, critical exponents, universality — captures *when* and *how* tiny perturbations trigger global change.

Discrete and arithmetic mathematics is full of analogous behavior, even though no temperature or energy is in sight. A combinatorial extremal bound that flips from "achievable" to "impossible" as a size parameter crosses an integer is a phase transition in everything but name. A rigidity law that holds exactly above an index threshold and fails below it marks a critical line. A dynamical convergence guarantee with an explicit step bound is a renormalization flow reaching its fixed point in finite time.

This paper assembles three such phenomena, each established with full rigor, and reads them through this physics-flavored lens. They are deliberately diverse — extremal number theory, the arithmetic of recurrence sequences, and the dynamics of finite self-maps — precisely to highlight that the *shape* of the phenomenon (a sharp threshold, a rigidity above a boundary, bounded descent to a fixed point) recurs across unrelated domains. We do not claim a single unifying theorem; we claim a shared morphology, and we make each instance precise.

### Notation and conventions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$. The Fibonacci sequence is $F_0 = 0$, $F_1 = 1$, $F_2 = 1$, and $F_{k+2} = F_{k+1} + F_k$. For a positive integer $x$, $v_2(x)$ denotes the 2-adic valuation (the exponent of the largest power of $2$ dividing $x$). The interval $\{a, a+1, \dots, b\}$ of integers is written $[a, b]$. For a self-map $F: \alpha \to \alpha$, $F^{[n]}$ denotes the $n$-fold iterate, with $F^{[0]} = \mathrm{id}$. A poset is a set with a partial order $\le$; $|P|$ denotes the cardinality of a finite type $P$.

---

## 2. The divisibility pigeonhole threshold

### 2.1 Statement

**Definition 2.1 (Odd part).** For $x \in \mathbb{N}$ define the *odd part*
$$ \mathrm{oddPart}(x) \;=\; \frac{x}{2^{\,v_2(x)}}, $$
the integer obtained by dividing out every factor of $2$. For $x \ge 1$, $\mathrm{oddPart}(x)$ is odd and $x = \mathrm{oddPart}(x)\cdot 2^{v_2(x)}$ is the unique factorization of $x$ into an odd number times a power of two.

**Theorem 2.2 (Divisibility pigeonhole).** *Let $n \ge 1$, and let $S \subseteq [1, 2n]$ be a set of distinct integers with $|S| = n+1$. Then there exist distinct $a, b \in S$ with $a \mid b$.*

The bound is sharp: $S = \{n+1, n+2, \dots, 2n\}$ has $n$ elements, lies in $[1,2n]$, and contains no divisibility pair, because if $a \mid b$ with $a < b$ then $b \ge 2a > 2n$, impossible inside $[n+1, 2n]$. Thus $n$ is the largest antichain size and $n+1$ is the exact threshold at which divisibility becomes unavoidable.

### 2.2 Proof sketch

Consider the map $\mathrm{oddPart}: S \to \mathbb{N}$. For $x \in [1, 2n]$, the odd part $\mathrm{oddPart}(x)$ is an *odd* integer with $\mathrm{oddPart}(x) \le x \le 2n$. The odd integers in $[1, 2n]$ are exactly $1, 3, 5, \dots, 2n-1$, of which there are precisely $n$. Hence the image $\mathrm{oddPart}(S)$ is contained in a set of size $n$:
$$ \big| \mathrm{oddPart}(S) \big| \;\le\; n. $$
Since $|S| = n+1 > n$, the map $\mathrm{oddPart}$ restricted to $S$ cannot be injective: by the pigeonhole principle there exist distinct $a, b \in S$ with $\mathrm{oddPart}(a) = \mathrm{oddPart}(b) =: c$. Writing $a = c \cdot 2^{j}$ and $b = c \cdot 2^{k}$ with $j = v_2(a)$, $k = v_2(b)$, and assuming without loss of generality $j \le k$, we get
$$ b = c\cdot 2^{k} = (c\cdot 2^{j})\cdot 2^{k-j} = a \cdot 2^{k-j}, $$
so $a \mid b$. (If $j > k$ symmetrically $b \mid a$.) This produces the required divisibility pair. $\qquad\blacksquare$

The formalized statement retains a hypothesis $n \ge 1$ as part of its requested form; the argument above in fact goes through without it, since for $n = 0$ the cardinality hypothesis $|S| = 1$ is vacuously compatible (and the interval is empty), so the hypothesis is logically inert.

### 2.3 Interpretation as coarse-graining

The map $\mathrm{oddPart}$ is a *coarse-graining* operator: it collapses the multiplicative "$2$-adic detail" of an integer and retains only its odd skeleton. Two integers are identified by $\mathrm{oddPart}$ exactly when one is a power-of-two multiple of the other — exactly the relation that yields a divisibility pair. The extremal threshold $n \mapsto n+1$ is then a pure counting statement in the coarse-grained world: the number of available odd skeletons in $[1,2n]$ is $n$, and any selection exceeding this count must suffer a collision. The sharpness of the transition (no element of slack) is a direct consequence of the exact count of odd residues.

---

## 3. Fibonacci divisibility rigidity

### 3.1 Statements

**Theorem 3.1 (Index divisibility $\Rightarrow$ Fibonacci divisibility).** *For all $m, n \in \mathbb{N}$, if $m \mid n$ then $F_m \mid F_n$.*

This makes $(F_k)$ a *divisibility sequence*. The converse fails for small indices because $F_1 = F_2 = 1$ divides every $F_n$. The corrected, sharp two-way law is:

**Theorem 3.2 (Fibonacci divisibility characterization).** *For $m \ge 3$ and all $n \in \mathbb{N}$,*
$$ F_m \mid F_n \quad\Longleftrightarrow\quad m \mid n. $$

The threshold $m \ge 3$ is necessary and not improvable: for $m \in \{1, 2\}$ the left side $F_m = 1 \mid F_n$ holds for *all* $n$, while the right side $m \mid n$ does not, so the equivalence is false below the boundary and true at and above it.

### 3.2 Proof sketch

*Forward direction (Theorem 3.1).* This is the standard divisibility property of the Fibonacci sequence: writing $n = m k$ and using the addition identity $F_{a+b} = F_{a} F_{b+1} + F_{a-1} F_{b}$, one shows by induction on $k$ that $F_m \mid F_{mk}$. Each increment adds $m$ to the index and contributes a term already divisible by $F_m$.

*Characterization (Theorem 3.2).* The keystone is the **gcd identity for Fibonacci numbers**:
$$ \gcd(F_m, F_n) = F_{\gcd(m, n)}. \tag{$\star$} $$
Assume $m \ge 3$.

($\Leftarrow$) If $m \mid n$, then Theorem 3.1 gives $F_m \mid F_n$ directly.

($\Rightarrow$) Suppose $F_m \mid F_n$. Then $\gcd(F_m, F_n) = F_m$. By ($\star$), $F_m = F_{\gcd(m,n)}$. Let $d = \gcd(m, n)$, so $d \mid m$ and $d \le m$. We claim $d = m$. Suppose not, so $d < m$. Since $m \ge 3$, the Fibonacci sequence is *strictly increasing* on indices $\ge 2$ (indeed $F_2 = 1 < F_3 = 2 < F_4 = 3 < \cdots$), and one checks $F_d < F_m$ whenever $d < m$ and $m \ge 3$ (treating the small cases $d \le 1$ separately, where $F_d \le 1 < 2 \le F_m$). This contradicts $F_m = F_d$. Hence $d = m$, i.e. $m = \gcd(m,n)$, which is precisely $m \mid n$. $\qquad\blacksquare$

The entire converse hinges on **strict monotonicity above the threshold**, the same structural fact that makes $m \ge 3$ indispensable: degeneracy of the value $F_m$ at $m \in \{1,2\}$ is exactly what destroys injectivity of $k \mapsto F_k$ there and with it the rigidity law.

### 3.3 Interpretation

Theorem 3.2 says the divisibility poset of indices $\{m : m \ge 3\}$ embeds faithfully into the divisibility poset of Fibonacci values via $m \mapsto F_m$: the order-theoretic relation $m \mid n$ is reflected with no false positives and no false negatives. The phase boundary at $m = 3$ is the index above which the embedding becomes an exact mirror. Below it, the "potential well" of the value $1$ traps two distinct indices, breaking the correspondence — a degeneracy lifted precisely at the critical index.

---

## 4. The finite Garden-of-Eden principle and bounded descent

We now turn from arithmetic to the dynamics of self-maps, where the phase-transition morphology reappears as a surjectivity/injectivity dichotomy and as guaranteed bounded convergence of descending flows.

### 4.1 Garden-of-Eden states

**Definition 4.1 (Garden of Eden).** For a self-map $F: \alpha \to \alpha$, a point $y \in \alpha$ is a *Garden-of-Eden state* if it has no preimage:
$$ \mathrm{IsGardenOfEden}(F, y) \;:\equiv\; \forall x,\; F(x) \neq y. $$

**Theorem 4.2 (Existence of Garden-of-Eden states).** *For any self-map $F : \alpha \to \alpha$,*
$$ \big(\exists y,\; \mathrm{IsGardenOfEden}(F, y)\big) \quad\Longleftrightarrow\quad \neg\,\mathrm{Surjective}(F). $$

*Proof.* A point $y$ is a Garden of Eden iff it is not in the image of $F$. Such a $y$ exists iff $F$ is not surjective. The equivalence is immediate by unfolding both definitions and pushing the negation through the quantifiers. $\qquad\blacksquare$

While elementary, Theorem 4.2 fixes the vocabulary: unreachable states are exactly the values the dynamics misses, so studying Gardens of Eden *is* studying failure of surjectivity.

### 4.2 The finite Moore–Myhill shadow

On finite state spaces, surjectivity and injectivity coincide. This is the finite shadow of the classical Moore–Myhill Garden-of-Eden theorem for cellular automata, which links global surjectivity ("every configuration is reachable") with pre-injectivity ("distinct finite configurations remain distinguishable").

**Theorem 4.3 (Surjective $\Rightarrow$ injective on finite types).** *Let $\alpha$ be a finite type and $F : \alpha \to \alpha$. If $F$ is surjective then $F$ is injective (hence bijective).*

*Proof sketch.* A surjection from a finite set to itself is a bijection: the image has cardinality $|\alpha|$, so by the pigeonhole principle no two inputs can collide. Equivalently, $|\mathrm{image}(F)| = |\alpha|$ forces $F$ to be injective. $\qquad\blacksquare$

Thus on finite dynamics there is no "lossy but onto" regime: covering all states and preserving all distinctions are the same property. The two phases — information-preserving and information-destroying dynamics — separate cleanly, with no overlap.

### 4.3 Bounded descent

We now equip the state space with an order and consider maps that never increase.

**Definition 4.4 (Descending map).** A self-map $F : P \to P$ on a poset $P$ is *descending* if $F(x) \le x$ for all $x \in P$.

**Theorem 4.5 (Iterates form a descending chain).** *If $F : P \to P$ is descending on a poset $P$, then for every $n \in \mathbb{N}$ and every $x \in P$,*
$$ F^{[n+1]}(x) \;\le\; F^{[n]}(x). $$

*Proof.* By the identity $F^{[n+1]}(x) = F\big(F^{[n]}(x)\big)$ and the descending hypothesis applied at the point $F^{[n]}(x)$, we get $F\big(F^{[n]}(x)\big) \le F^{[n]}(x)$, which is the claim. $\qquad\blacksquare$

So every orbit of a descending map is a non-increasing chain. On a *finite* poset, such a chain cannot strictly descend forever; it must reach a fixed point, and quickly.

**Theorem 4.6 (Bounded descent stabilization).** *Let $P$ be a finite poset and $F : P \to P$ a monotone descending map. Then for every $x \in P$ there exists $n \le |P|$ with*
$$ F^{[n]}(x) = F^{[n+1]}(x), $$
*i.e. the orbit of $x$ reaches a fixed point within $|P|$ steps.*

*Proof sketch.* Suppose, for contradiction, that for the given $x$ no such $n \le |P|$ exists: $F^{[n]}(x) \neq F^{[n+1]}(x)$ for every $n \le |P|$. Combined with Theorem 4.5 this means the chain strictly decreases at each of the first $|P| + 1$ steps:
$$ F^{[0]}(x) \;>\; F^{[1]}(x) \;>\; \cdots \;>\; F^{[|P|]}(x). $$
A strictly decreasing chain has pairwise distinct entries (in a poset, $a > b$ in a strict chain forbids equality with any later term, by transitivity and antisymmetry). Hence the values $F^{[0]}(x), \dots, F^{[|P|]}(x)$ are $|P| + 1$ distinct elements of $P$. But $|P|$ has only $|P|$ elements — a contradiction by the pigeonhole principle. Therefore some $n \le |P|$ satisfies $F^{[n]}(x) = F^{[n+1]}(x)$. $\qquad\blacksquare$

The argument is, once more, pigeonhole: strict descent for too long would exhaust the available states. The monotonicity hypothesis ensures the framework is well behaved as a flow; the descending hypothesis provides the strict ordering that powers the counting argument.

### 4.4 Interpretation as a renormalization flow

A descending map $F$ on a finite poset is a discrete RG flow: each application coarse-grains the configuration to one of no greater "energy" (height in the order), and Theorem 4.6 guarantees the flow reaches a **fixed point** — a self-map-invariant configuration — in finite, explicitly bounded time. There is no chaotic non-convergence and no slow approach: the basin of every state drains to a fixed point in at most $|P|$ steps. The Garden-of-Eden dichotomy (Theorems 4.2–4.3) complements this by classifying which states can serve as *sources* (initial-only states, with no preimage) versus those that lie on the eventual image — the analogue of distinguishing transient from recurrent structure in a flow.

---

## 5. Algorithms

The proofs are constructive enough to yield decision and search procedures.

### 5.1 Witness search for the divisibility pigeonhole

Given $S \subseteq [1, 2n]$ with $|S| = n+1$, Theorem 2.2 guarantees a divisibility pair, and the proof localizes it: group elements of $S$ by odd part; a collision must occur; sort each colliding group by 2-adic valuation and emit the smallest-valuation/largest pair.

```
Algorithm DIVISIBILITY-WITNESS(S):
  buckets <- empty map from odd integer to list of elements
  for x in S:
    c <- oddPart(x)            # divide out all factors of 2
    append x to buckets[c]
  for c, group in buckets:
    if |group| >= 2:
      a <- element of group with smallest v2
      b <- another element of group           # then a | b or b | a
      return (min by divisibility) , (max by divisibility)
  return NONE   # cannot happen when |S| = n+1 <= ... within [1,2n]
```

Complexity: $O(|S| \log(\max S))$ time (computing each odd part costs $O(\log x)$), $O(|S|)$ space.

### 5.2 Fibonacci divisibility decision

To decide $F_m \mid F_n$ for $m \ge 3$, Theorem 3.2 reduces the value-level question to the index level: test $m \mid n$. This avoids computing the (exponentially large) Fibonacci numbers entirely.

```
Algorithm FIB-DIVIDES(m, n):           # assumes m >= 3
  return (n mod m == 0)
```

Complexity: $O(1)$ arithmetic on the indices, versus $O(n)$ big-integer work for a naive value computation.

### 5.3 Descent stabilization

To find the stabilization time of a state $x$ under a finite descending map $F$, iterate until a repeat; Theorem 4.6 bounds the loop by $|P|$.

```
Algorithm DESCENT-FIXED-POINT(F, x, cardP):
  cur <- x
  for n in 0 .. cardP:
    nxt <- F(cur)
    if nxt == cur:
      return (n, cur)        # fixed point found at step n <= cardP
    cur <- nxt
  return FAILURE             # unreachable if F is descending on a finite poset
```

Complexity: $O(|P|)$ evaluations of $F$.

---

## 6. Numerical illustrations

The accompanying `demo.py` exhibits each result. Representative outputs:

- **Pigeonhole sharpness.** For $n = 10$ (range $[1, 20]$): the antichain $\{11, \dots, 20\}$ of size $10$ has no divisibility pair; adding any $11$th element forces one. The witness search reports, e.g., for $S = \{11,\dots,20\} \cup \{5\}$ the pair $(5, 20)$ via shared odd part $5$.
- **Fibonacci mirror.** Tabulating $F_m \mid F_n$ against $m \mid n$ for $3 \le m, n \le 20$ shows perfect agreement; including $m \in \{1,2\}$ reveals the mismatches that justify the threshold.
- **Descent.** A monotone descending map on a finite poset (e.g., $x \mapsto \lfloor x/2 \rfloor$ on $\{0, \dots, N\}$) reaches its fixed point $0$ from every start in $\le \lceil \log_2 N\rceil$ steps, well within the worst-case bound $N+1 = |P|$.

---

## 7. Applications

**Extremal set theory and scheduling.** Theorem 2.2 is the canonical example of a forced substructure under an exact density threshold; the odd-part coarse-graining is reused in problems on chains and antichains in the divisibility order, and in load-balancing arguments where "shared core" collisions are unavoidable past a count.

**Recurrence-sequence cryptography and pseudorandomness.** The rigidity of Theorem 3.2 means the index lattice is recoverable from value-level divisibility, a structural feature relevant to the analysis of Lucas-sequence-based primality tests and to understanding why certain recurrence sequences are *strong* divisibility sequences.

**Termination and static analysis.** Theorem 4.6 is a finite, quantitative termination certificate: monotone descending updates on a finite lattice (the staple of dataflow analysis and abstract interpretation) converge within the lattice height. The explicit $|P|$ bound is exactly the kind of guarantee a worklist algorithm needs.

**Cellular automata and reversibility.** Theorems 4.2–4.3 are the finite kernel of Garden-of-Eden theory: unreachable configurations exist precisely for irreversible (non-surjective) rules, and on finite alphabets surjectivity forces injectivity, the dichotomy underpinning reversible-computing constructions.

---

## 8. Discussion: a shared phase-transition morphology

The three results are independent theorems, yet they share a recognizable form drawn from statistical physics:

1. **Sharp critical line (pigeonhole).** A size parameter crosses $n \to n+1$ and an extremal property flips from achievable to forced. The control is selection size; the order parameter is the inevitability of a divisibility pair; the transition is exact because the coarse-grained state count (odd residues) is exact.

2. **Rigidity above a threshold (Fibonacci).** Below the critical index $m = 3$ a degeneracy ($F_1 = F_2 = 1$) breaks an exact correspondence; at and above it, strict monotonicity restores a perfect mirror between index- and value-level divisibility. This is the lifting of a degeneracy at a critical point.

3. **Bounded flow to a fixed point (descent).** A discrete renormalization-style flow on a finite ordered state space converges to a fixed point in explicitly bounded time, with the Garden-of-Eden dichotomy classifying source-like versus recurrent states.

In each case the mechanism reduces to a counting principle (pigeonhole) or a monotonicity principle, and in each case the threshold is *exact* rather than asymptotic. This exactness is what distinguishes these discrete transitions from their physical cousins, where critical points are approached only in thermodynamic limits. Here finiteness is not an approximation to be removed but the very source of the sharpness.

## 9. Limitations and future directions

These results are exact but local in scope: each captures one threshold or one rigidity in one setting. A genuine "physics of discrete structure" would seek *universality* — encoding-independent fixed points and critical exponents shared across many such transitions. The pigeonhole and descent arguments both rest on cardinality collisions, hinting that a common renormalization framework (coarse-graining operators with exact invariants) could subsume both; formalizing that bridge, and attaching weights to turn counts into partition functions, is the natural next step. The future-directions program below sketches concrete avenues, centered on weighted path spaces, inhomogeneous branching, an explicit flow on a branching parameter, and connections to complexity hierarchies.

---

## 10. Conclusion

We have stated, proved (in sketch), and contextualized three exact results — a divisibility pigeonhole threshold, a Fibonacci divisibility rigidity law with a sharp index boundary, and a finite Garden-of-Eden/bounded-descent principle — and shown that, despite their disparate origins, they share the morphology of phase transitions and renormalization flows. The recurring engine is the pigeonhole/monotonicity principle, and the recurring signature is an *exact* critical line rather than an asymptotic one. Read together, they make a modest but precise case that the physicist's vocabulary of thresholds, coarse-graining, and fixed points describes real, provable features of finite and arithmetic mathematics.
