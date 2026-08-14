# The Discriminant-Gated $p+1$ Weakness and Its Invisibility from the Modulus

**Author:** Aristotle

**Date:** 2026-08-14

---

## Abstract

The Williams $p+1$ factoring method exploits primes $p$ for which $p+1$ is smooth, in the same way that Pollard's $p-1$ method exploits primes for which $p-1$ is smooth. We give a complete structural account of when the method succeeds and prove that its success condition is invisible from the composite modulus $N$.

Two groups of results are established. On the *positive* side, we prove that the method's success at a prime $p$, for base $P$ with discriminant $D = P^2 - 4$, is governed by a quadratic character: if $D$ is a non-residue modulo $p$ and $(p+1) \mid M$, then the Lucas value $V_M(P) \equiv 2 \pmod p$ and the gcd step returns $p$ exactly; if $D$ is a nonzero square, then $V_{p+1} \equiv P^2 - 2 \not\equiv 2$, and the method has silently degenerated into Pollard's $p-1$ method. Sharpening this, $V_{p+1} \equiv 2 \pmod p$ holds *if and only if* $D$ is a non-residue or $D = 0$. We classify the universally degenerate bases — precisely those with $|P| \le 2$ — and count the good ones: exactly $(p-1)/2$ of the $p$ residues $P \in \mathbb{F}_p$ open the gate, via a trace parametrization $P = a + a^{-1}$ that is two-to-one away from $a = \pm 1$. We also show that bases whose discriminants differ by a nonzero square factor are gated by the same character, so that $P = 3$ ($D = 5$) and $P = 7$ ($D = 45 = 5 \cdot 3^2$) succeed on exactly the same primes.

On the *negative* side, we prove that no predicate of the statistic $N \mapsto (N \bmod 60060,\ \lceil \log_2 N \rceil)$ decides either the $+1$-divisibility of the smaller prime factor or the discriminant gate at that factor; the witness is the matched collision $359 \cdot 5849 = 2{,}099{,}791$ against $397 \cdot 5743 = 2{,}279{,}971$, two $22$-bit semiprimes congruent modulo $60060 = 2^2\cdot 3\cdot 5\cdot 7\cdot 11\cdot 13$ with opposite labels for both predicates simultaneously. The mechanism is a dichotomy: $N \bmod 3$ *does* determine the symmetric predicate "exactly one of $p, q$ is $\equiv -1 \bmod 3$", and $(D\mid N) = (D \mid p)(D \mid q)$ is the product of the two local characters, so every abelian statistic of $N$ is blind to the $S_2$-orbit of the factor pair. An empirical study of $40$ matched semiprime pairs confirms all of this quantitatively, including the exact coincidence between per-base success counts and $(D \mid p) = -1$ rates.

The conclusion is that the $p+1$ weakness is real but strictly more hidden than the $p-1$ weakness: it is exploitable only by running the classical algorithm, never by inspecting $N$.

**Keywords:** Williams $p+1$ method, Lucas sequences, quadratic residues, Legendre and Jacobi symbols, integer factorization, smoothness, tropical/max-plus conditions, information-theoretic barriers.

---

## 1. Introduction

### 1.1 Fragile primes

Let $N = pq$ be a semiprime with $p < q$. Two classical special-purpose factoring methods target *fragile* primes.

- **Pollard's $p-1$ method (1974)** computes $\gcd(a^M - 1, N)$ for $M = \operatorname{lcm}(1,\dots,B)$. It succeeds when the order of $a$ in $\mathbb{F}_p^\times$ divides $M$, which happens in particular when $p - 1$ is $B$-powersmooth.
- **Williams' $p+1$ method (1982)** replaces the multiplicative group $\mathbb{F}_p^\times$ (order $p-1$) with the norm-one torus of $\mathbb{F}_{p^2}$ (order $p+1$), realized concretely through Lucas sequences. It succeeds when $p + 1$ is $B$-powersmooth — *and*, as we shall make precise, when an additional character condition holds.

For key generation the relevant question is not whether such primes are dangerous — they are — but whether their presence can be *detected from $N$*. If it can, the modulus leaks a hint about its own factorization, and one obtains a cheap screening test that identifies which composites are worth attacking. This paper answers the question for the $p+1$ family, in the negative, and in three independent senses.

### 1.2 Contributions

1. **A complete discriminant gate (Section 3).** We prove that the decisive congruence $V_{p+1} \equiv 2 \pmod p$ of the base-$P$ method holds if and only if the quadratic character condition $(P^2 - 4 \mid p) = -1$ is met (or the degenerate case $P^2 - 4 \equiv 0$ occurs), and identify exactly what happens in the complementary case.
2. **Classification of degenerate bases (Section 4).** The bases for which the method can never work are precisely $P \in \{-2,-1,0,1,2\}$.
3. **Gate density (Section 5).** Exactly $(p-1)/2$ of the $p$ bases in $\mathbb{F}_p$ open the gate; consequently a random base works with probability $(p-1)/(2p)$, and the classical triple $\{3,5,7\}$ is effectively a pair because $D_3 = 5$ and $D_7 = 45$ share a square class.
4. **A general invisibility barrier and its instances (Section 6).** A single statistic-collision on two admissible instances with opposite labels destroys an entire family of would-be detectors. We exhibit such a collision for a very rich statistic and deduce invisibility of both the divisibility predicate and the gate predicate.
5. **The symmetry mechanism (Section 7).** $N$ is a symmetric function of $\{p, q\}$; the exploitable predicate is asymmetric. We make this quantitative in the residue channel (XOR visibility mod 3) and in the character channel (Jacobi splitting).
6. **Experimental confirmation (Section 8).** Forty matched pairs, three channels of attack, and an exact identity between per-base success sets and gate-open sets.

---

## 2. Setup and definitions

Throughout, $p$ and $q$ denote primes, $N = pq$ with $p < q$, and $\ell$ denotes a small auxiliary prime.

**Definition 2.1 (Lucas $V$-sequence).** For a base $P$ in a commutative ring $R$, define $V_n(P) \in R$ by
$$V_0 = 2, \qquad V_1 = P, \qquad V_{n+2} = P\,V_{n+1} - V_n \quad (n \ge 0).$$
These are the Lucas sequences with parameters $(P, Q) = (P, 1)$.

Because the recurrence has coefficients in the prime ring, it commutes with ring homomorphisms: for any $f : R \to S$ we have $f(V_n(P)) = V_n(f(P))$. In particular, reduction modulo $p$ may be performed at any stage, which is what makes the algorithm practical.

**Definition 2.2 (Discriminant).** The discriminant of the base $P$ is $D = P^2 - 4$, the discriminant of the companion polynomial $x^2 - Px + 1$.

**Definition 2.3 (Powersmoothness and the classical exponent).** For $B \ge 1$ put $\operatorname{lcm}_{\le B} := \operatorname{lcm}(1, 2, \dots, B)$. An integer $n \ge 1$ is *$B$-powersmooth* if $\ell^{v_\ell(n)} \le B$ for every prime $\ell$, where $v_\ell$ is the $\ell$-adic valuation.

**Definition 2.4 (Admissible instance).** A pair $(p,q)$ is *admissible* if $p$ and $q$ are prime and $p < q$; then "the smaller factor" of $N = pq$ is well defined.

**Definition 2.5 (Locator).** Let $\mathrm{stat} : \mathbb{N} \to \alpha$ be any function of the modulus and let $S$ be a predicate on primes. A *locator for $S$ from $\mathrm{stat}$* is a predicate $f$ on $\alpha$ such that for every admissible $(p,q)$,
$$f\big(\mathrm{stat}(pq)\big) \iff S(p).$$
"$S$ is invisible from $\mathrm{stat}$" means no locator exists.

Definition 2.5 is deliberately generous to the attacker: $f$ may be arbitrary, non-computable, and tailored to the class of instances. Impossibility at this level of generality is therefore very strong.

---

## 3. The discriminant gate

### 3.1 Binet form and the success criterion

**Lemma 3.1 (Binet form).** *If $a, b$ lie in a commutative ring with $ab = 1$ and $a + b = P$, then $V_n(P) = a^n + b^n$ for all $n$.*

*Proof sketch.* Two-step induction. The base cases are $a^0 + b^0 = 2$ and $a + b = P$. For the step, use the identity
$$a^{n+2} + b^{n+2} = (a+b)(a^{n+1} + b^{n+1}) - (ab)(a^n + b^n)$$
and substitute $ab = 1$, $a + b = P$. $\square$

**Theorem 3.2 (Exact success criterion).** *Let $K$ be an integral domain and $a, b \in K$ with $ab = 1$, $a + b = P$. Then for every $M \ge 0$,*
$$V_M(P) = 2 \iff a^M = 1 .$$

*Proof sketch.* From $ab = 1$ we get $a^M b^M = 1$, whence the algebraic identity
$$a^M\big(V_M(P) - 2\big) = a^M\big(a^M + b^M - 2\big) = (a^M - 1)^2 .$$
If $V_M = 2$ the right-hand side vanishes; since $K$ is a domain, $a^M = 1$. Conversely $a^M = 1$ forces $b^M = 1$ and hence $V_M = 2$. $\square$

Theorem 3.2 is the conceptual heart: the Williams criterion is an *order condition on a norm-one element*, and the divisibility $(p+1) \mid M$ is merely the arithmetic hypothesis the algorithm can arrange in advance.

### 3.2 The $p+1$ half of the gate

**Theorem 3.3 ($p+1$ gate, non-residue case).** *Let $p$ be an odd prime and $P \in \mathbb{F}_p$ a base whose discriminant $D = P^2 - 4$ is a quadratic non-residue modulo $p$. Then for every $M$ with $(p+1) \mid M$,*
$$V_M(P) \equiv 2 \pmod p .$$

*Proof sketch.* Since $D$ is a non-residue, $x^2 - D$ is irreducible over $\mathbb{F}_p$, so $K = \mathbb{F}_p[x]/(x^2 - D) \cong \mathbb{F}_{p^2}$ is a field of characteristic $p$ containing a square root $s$ of $D$. Euler's criterion gives $D^{(p-1)/2} = -1$, hence
$$s^p = (s^2)^{(p-1)/2} \cdot s = D^{(p-1)/2} s = -s ,$$
so Frobenius negates $s$. Set $a = (P+s)/2$ and $b = (P-s)/2$ (legitimate since $p$ is odd). Then $a + b = P$ and
$$ab = \frac{P^2 - s^2}{4} = \frac{P^2 - (P^2-4)}{4} = 1 .$$
Because $K$ has characteristic $p$, the Frobenius map is additive, so $a^p = (P^p + s^p)/2^p = (P - s)/2 = b$ and likewise $b^p = a$. Therefore
$$a^{p+1} = a^p \cdot a = ba = 1, \qquad b^{p+1} = 1 ,$$
and for $M = (p+1)k$ we get $a^M = b^M = 1$. Lemma 3.1 gives $V_M(P) = a^M + b^M = 2$ in $K$; since $\mathbb{F}_p \hookrightarrow K$ is injective and $V_M(P)$ already lies in $\mathbb{F}_p$, the congruence holds there. $\square$

**Corollary 3.4 (Integer form).** *If $p$ is an odd prime, $P \in \mathbb{Z}$, the Legendre symbol satisfies $\big(\tfrac{P^2-4}{p}\big) = -1$, and $(p+1) \mid M$, then $p \mid V_M(P) - 2$ in $\mathbb{Z}$.*

### 3.3 The $p-1$ half of the gate

**Lemma 3.5 (Split roots).** *If $t^2 \equiv P^2 - 4 \pmod p$ for an odd prime $p$, then $a = (P+t)/2$ and $b = (P-t)/2$ lie in $\mathbb{F}_p$ and satisfy $ab = 1$, $a + b = P$.*

**Theorem 3.6 (Degeneration to Pollard).** *If $D = P^2 - 4$ is a square modulo the odd prime $p$, then $V_M(P) \equiv 2 \pmod p$ whenever $(p-1) \mid M$. Moreover the exact value at the $p+1$ step is*
$$V_{p+1}(P) \equiv P^2 - 2 \pmod p .$$

*Proof sketch.* For the first claim, Lemma 3.5 puts $a, b$ in $\mathbb{F}_p^\times$, and Fermat gives $a^{p-1} = b^{p-1} = 1$; apply Theorem 3.2. For the second, $a^p = a$ and $b^p = b$ in $\mathbb{F}_p$, so
$$V_{p+1} = a^{p+1} + b^{p+1} = a^2 + b^2 = (a+b)^2 - 2ab = P^2 - 2 . \square$$

Thus when the gate is closed the method is not merely inefficient; it is *a different algorithm*. The relevant group is $\mathbb{F}_p^\times$ of order $p-1$, and all the smoothness of $p+1$ in the world is irrelevant.

**Theorem 3.7 (Sharp gate).** *For an odd prime $p$ and any base $P \in \mathbb{F}_p$,*
$$V_{p+1}(P) = 2 \iff \big(P^2 - 4 \text{ is a non-residue}\big) \ \text{or}\ \big(P^2 - 4 = 0\big).$$

*Proof sketch.* ($\Leftarrow$) The non-residue case is Theorem 3.3 with $M = p+1$; the case $D = 0$ follows from Theorem 3.6 with $t = 0$, since then $P^2 - 2 = 2$. ($\Rightarrow$) If $D$ is a nonzero square, Theorem 3.6 gives $V_{p+1} = P^2 - 2$, and $P^2 - 2 = 2$ would force $D = P^2 - 4 = 0$, a contradiction. $\square$

Theorem 3.7 is the formal content of the experimental identity reported in Section 8: for a nondegenerate base, per-instance success of the $p+1$ congruence coincides exactly with the event $(D \mid p) = -1$.

### 3.4 The gcd step returns the factor

**Theorem 3.8 (Exactness of the gcd step).** *Let $p, q$ be primes and $V \in \mathbb{Z}$ with $p \mid V$ and $q \nmid V$. Then $\gcd(V, pq) = p$.*

*Proof sketch.* $p$ divides the gcd, and the gcd divides $pq$, so the gcd is $p$ or $pq$; the latter would force $q \mid V$. $\square$

**Theorem 3.9 (Positive control, capstone).** *Let $p$ be an odd prime, $q$ a prime, $P \in \mathbb{Z}$ a base with $\big(\tfrac{P^2-4}{p}\big) = -1$, and suppose $p+1$ is $B$-powersmooth. If $q \nmid V_{M}(P) - 2$ for $M = \operatorname{lcm}_{\le B}$, then*
$$\gcd\big(V_M(P) - 2,\ pq\big) = p .$$

*Proof sketch.* Powersmoothness gives $(p+1) \mid \operatorname{lcm}_{\le B}$: indeed, comparing factorizations, $v_\ell(p+1) \le v_\ell(\operatorname{lcm}_{\le B})$ for every prime $\ell$ because $\ell^{v_\ell(p+1)} \in \{1, \dots, B\}$. Then Corollary 3.4 gives $p \mid V_M - 2$, and Theorem 3.8 finishes. $\square$

**Remark 3.10 (Tropical shape of smoothness).** The hypothesis "$\ell^{v_\ell(n)} \le B$ for all $\ell$" is a bound on the **maximum** of the quantities $v_\ell(n)\log \ell$, i.e. a sup-norm constraint on the valuation vector of $n$. This is a max-plus (tropical) condition, in contrast to the ordinary multiplicative conditions of number theory; the divisibility $n \mid \operatorname{lcm}_{\le B}$ is precisely the statement that the valuation vector lies in the tropical box cut out by that condition. The same tropical flavour recurs in Section 7.3, where the returned factor is characterized as the divisor on the lower side of the corner of a piecewise-linear function.

**Worked instance.** Take $N = 91 = 7 \cdot 13$, $P = 3$ (so $D = 5$), $M = 8$. Since $5$ is a non-residue mod $7$ and $7 + 1 = 8 \mid M$, Theorem 3.3 predicts $7 \mid V_8 - 2$. Indeed $V_8(3) = 2207$ and $\gcd(2205, 91) = 7$. Conversely at $p = 11$ the discriminant $5$ *is* a square ($4^2 = 16 \equiv 5$), and $V_{12}(3) \equiv 3^2 - 2 = 7 \not\equiv 2 \pmod{11}$, exactly as Theorem 3.6 requires: the gate is genuinely necessary.

---

## 4. Which bases are usable?

**Definition 4.1.** A base $P \in \mathbb{Z}$ is *universally degenerate* if $V_k(P) = 2$ for some $k \ge 1$ as an identity over $\mathbb{Z}$.

For such a base the gcd step returns $\gcd(V_M - 2, N) = \gcd(0, N) = N$ for every $N$ and every $M$ divisible by $k$: no factor is ever produced, regardless of the arithmetic of $p$ and $q$.

**Lemma 4.2 (Periodicity).** *If $V_k(P) = 2$ and $V_{k+1}(P) = P$, then $V_{n+k}(P) = V_n(P)$ for all $n$; consequently $V_M(P) = 2$ for every multiple $M$ of $k$.*

*Proof sketch.* The pair $(V_k, V_{k+1})$ equals the initial state $(V_0, V_1)$, and the recurrence is a deterministic map on states. $\square$

**Proposition 4.3 (The five bad bases).** *The bases $2, -2, -1, 0, 1$ are universally degenerate with periods $1, 2, 3, 4, 6$ respectively.* For $P = 2$ the sequence is constantly $2$; the others return to the initial state after the stated number of steps. These are exactly the values $P = 2\cos\theta$ for which the root $a = e^{i\theta}$ is a root of unity of order $1, 2, 3, 4$ or $6$ — the crystallographic orders.

**Lemma 4.4 (Growth).** *For integer $P \ge 3$ one has $V_{n+1}(P) \ge 3$ and $V_{n+1}(P) < V_{n+2}(P)$ for all $n \ge 0$.*

*Proof sketch.* Induction: from $3 \le V_{n} < V_{n+1}$ one gets $V_{n+2} = P V_{n+1} - V_n \ge 3V_{n+1} - V_n > V_{n+1}$. $\square$

**Theorem 4.5 (Classification of degenerate bases).** *For $P \in \mathbb{Z}$,*
$$\exists\, k \ge 1 : V_k(P) = 2 \iff |P| \le 2 .$$

*Proof sketch.* ($\Leftarrow$) Proposition 4.3. ($\Rightarrow$) For $P \ge 3$, Lemma 4.4 gives $V_k \ge 3$ for all $k \ge 1$. For $P \le -3$, use the sign symmetry $V_n(-P) = (-1)^n V_n(P)$ to transfer the statement from $|P| \ge 3$ positive. $\square$

This is the theoretical justification for the standard implementation choice of starting the base search at $P = 3$: below that threshold, the algorithm is provably vacuous.

---

## 5. How many bases open the gate?

**Theorem 5.1 (Gate density).** *Let $p$ be an odd prime. Then*
$$\#\{P \in \mathbb{F}_p : P^2 - 4 \text{ is a square}\} = \frac{p+1}{2}, \qquad \#\{P \in \mathbb{F}_p : P^2 - 4 \text{ is a non-residue}\} = \frac{p-1}{2}.$$

*Proof sketch.* Consider the *trace map* $g : \mathbb{F}_p^\times \to \mathbb{F}_p$, $g(a) = a + a^{-1}$. If $P = g(a)$ then $P^2 - 4 = (a - a^{-1})^2$ is a square. Conversely, if $P^2 - 4 = t^2$ then by Lemma 3.5 the roots $a = (P+t)/2$, $b = (P - t)/2$ lie in $\mathbb{F}_p^\times$ with $ab = 1$, so $P = a + a^{-1}$ is in the image of $g$. Thus the set of "bad" bases is exactly $g(\mathbb{F}_p^\times)$. Now $g(a) = g(a')$ iff $a' \in \{a, a^{-1}\}$, so $g$ is two-to-one except at the two fixed points $a = \pm 1$ of inversion. Counting fibres over the $p-1$ elements of the domain,
$$\#g(\mathbb{F}_p^\times) = \frac{(p-1) - 2}{2} + 2 = \frac{p+1}{2}.$$
The complementary count is $p - (p+1)/2 = (p-1)/2$. $\square$

**Corollary 5.2.** A base chosen uniformly at random from $\mathbb{F}_p$ opens the gate with probability $(p-1)/(2p)$, which tends to $1/2$. Sanity check at $p = 11$: six bad bases, five good ones.

**Theorem 5.3 (Square-class invariance).** *If $c \not\equiv 0 \pmod p$, then $\big(\tfrac{Dc^2}{p}\big) = \big(\tfrac{D}{p}\big)$. In particular $\big(\tfrac{45}{p}\big) = \big(\tfrac{5}{p}\big)$ for all $p \ne 3$, so the bases $P = 3$ ($D = 5$) and $P = 7$ ($D = 45 = 5 \cdot 3^2$) are gated by the same character and succeed at exactly the same primes.*

Theorem 5.3 has a practical consequence: a base list should be chosen with pairwise distinct discriminant square classes. Trying $\{3, 5, 7\}$ costs three Lucas exponentiations but delivers only two independent gate trials, so the heuristic success probability against a random prime is about $1 - (1/2)^2 = 3/4$, not $7/8$. This is confirmed exactly in Section 8.

---

## 6. Invisibility from the modulus

### 6.1 The abstract barrier

**Theorem 6.1 (No locator from a collision).** *Let $\mathrm{stat}$ be any function of the modulus, $S$ any predicate on primes. Suppose there exist admissible pairs $(p,q)$ and $(p', q')$ with*
$$\mathrm{stat}(pq) = \mathrm{stat}(p'q'), \qquad S(p) \text{ true}, \qquad S(p') \text{ false}.$$
*Then $S$ is invisible from $\mathrm{stat}$: no locator exists.*

*Proof.* If $f$ were a locator, then $f(\mathrm{stat}(pq))$ holds because $S(p)$ holds; rewriting along the collision, $f(\mathrm{stat}(p'q'))$ holds, whence $S(p')$ holds — contradiction. $\square$

Trivial as it is, Theorem 6.1 is the right tool, because it is quantified over *all* predicates $f$: no cleverness, no machine learning, no unbounded computation can extract the label. A single collision kills an entire attack surface.

### 6.2 The rich statistic and the matched collision

Let
$$\mathrm{stat}(N) = \big(N \bmod 60060,\ \operatorname{bitlength}(N)\big), \qquad 60060 = 2^2 \cdot 3 \cdot 5 \cdot 7 \cdot 11 \cdot 13 .$$
This statistic determines $N \bmod \ell$ for every prime $\ell \le 13$ (hence all five residue channels measured experimentally), every Jacobi symbol $(d \mid N)$ with $d$ supported on $\{-1, 2, 3, 5, 7, 11, 13\}$ up to squares, and the size information used to match instances.

**Lemma 6.2 (The matched collision).** *With $N = 359 \cdot 5849 = 2{,}099{,}791$ and $N' = 397 \cdot 5743 = 2{,}279{,}971$:*
$$N \equiv N' \equiv 57{,}751 \pmod{60060}, \qquad \operatorname{bitlength}(N) = \operatorname{bitlength}(N') = 22 ,$$
*and the two small factors have the same bit length (9), as do the two large factors (13).*

**Lemma 6.3 (Opposite labels).** $3 \mid 359 + 1$ but $3 \nmid 397 + 1$; and $\big(\tfrac{5}{397}\big) = -1$ but $\big(\tfrac{5}{359}\big) = +1$.

*Proof.* $360 = 3 \cdot 120$ and $398 = 3 \cdot 132 + 2$. For the characters, $5 \equiv 1 \pmod 4$ so quadratic reciprocity gives $\big(\tfrac{5}{p}\big) = \big(\tfrac{p}{5}\big)$; since $359 \equiv 4$ and $397 \equiv 2 \pmod 5$, and the squares mod $5$ are $\{1,4\}$, we get $+1$ and $-1$ respectively. $\square$

Notice that the *same* collision serves both channels, with the labels swapped: the pair is a simultaneous counterexample for divisibility-detection and for gate-detection.

**Theorem 6.4 (Invisibility of $+1$-divisibility).** *There is no predicate $f$ such that for all admissible $(p,q)$,*
$$f\big(pq \bmod 60060,\ \operatorname{bitlength}(pq)\big) \iff 3 \mid p+1 .$$

**Theorem 6.5 (Invisibility of the discriminant gate).** *There is no predicate $f$ such that for all admissible $(p,q)$,*
$$f\big(pq \bmod 60060,\ \operatorname{bitlength}(pq)\big) \iff \Big(\tfrac{5}{p}\Big) = -1 .$$

*Proof of both.* Apply Theorem 6.1 with the collision of Lemma 6.2 and the labels of Lemma 6.3 (in the respective orders). $\square$

Because $\big(\tfrac{5}{p}\big) = -1$ says exactly that $D = 3^2 - 4 = 5$ is a non-residue mod $p$, Theorem 6.5 asserts the invisibility of *the very condition* that Theorem 3.7 identifies as equivalent to success of the base-$3$ method.

**Corollary 6.6 (Per-modulus corollaries).** *For every $\ell \mid 60060$ — in particular $\ell = 3, 5, 7, 11, 13$ — neither $3 \mid p+1$ nor $\big(\tfrac{5}{p}\big) = -1$ is decidable from $N \bmod \ell$.* Indeed a locator from $N \bmod \ell$ would compose with reduction $N \bmod 60060 \mapsto N \bmod \ell$ to give a locator from the richer statistic. These corollaries are exactly the vanishing mutual informations measured in Section 8.

---

## 7. Why: the symmetry mechanism

Theorems 6.4 and 6.5 rest on explicit witnesses, which can feel accidental. They are not. Every statistic of $N = pq$ is a function of the *unordered* pair $\{p, q\}$, while the exploitable weakness is a predicate of the distinguished element $\min(p,q)$. This section makes the collapse visible in two channels and explains why the collisions must exist in abundance.

### 7.1 The residue channel: XOR is visible, the label is not

**Theorem 7.1 ($+1$-divisibility dichotomy).** *Let $p, q$ be primes different from $3$ and $N = pq$. Then*
$$N \equiv 2 \pmod 3 \iff \text{exactly one of } 3 \mid p+1,\ 3 \mid q+1 \text{ holds.}$$

*Proof sketch.* Neither $p$ nor $q$ is divisible by $3$, so each residue is $1$ or $2$ mod $3$, and $3 \mid p + 1$ is equivalent to $p \equiv 2$. Multiplication mod $3$ on $\{1,2\}$ is the group $\mathbb{Z}/2$: the product is $2$ iff exactly one factor is $2$. $\square$

**Corollary 7.2.** The symmetric predicate "exactly one of $p,q$ is $\equiv -1 \bmod 3$" *is* computable from $N$ by a single residue test, and if $N \equiv 2 \pmod 3$ then at least one of $p, q$ has $3 \mid \cdot + 1$.

The contrast with Corollary 6.6 is the crux of the paper. $N \bmod 3$ carries a full bit of information about the pair — the XOR of the two local bits — and zero information about which factor carries which bit. XOR is invariant under swapping $p$ and $q$; the "which" question is not. The experiment measures exactly this: mutual information $0.2996$ bits for the symmetric predicate, $0.0005$ bits for the asymmetric one.

### 7.2 The character channel: products destroy the split

**Theorem 7.3 (Jacobi splitting).** *For distinct primes $p, q$ and any $D \in \mathbb{Z}$,*
$$\Big(\frac{D}{pq}\Big) = \Big(\frac{D}{p}\Big)\Big(\frac{D}{q}\Big),$$
*where the left side is the Jacobi symbol and the right-hand factors are Legendre symbols.*

The attacker can compute the left-hand side in polynomial time without factoring. But the map $\{\pm 1\}^2 \to \{\pm 1\}$, $(u,v) \mapsto uv$, has fibres of size two, and both fibres confound a gate-open instance with a gate-closed one:

**Proposition 7.4 (Product uninformativeness).** $\big(\tfrac{5}{21}\big) = +1$ with $\big(\tfrac{5}{3}\big) = -1$ (gate open at the smaller factor), while $\big(\tfrac{5}{209}\big) = +1$ with $\big(\tfrac{5}{11}\big) = +1$ (gate closed). Hence no predicate of $\big(\tfrac{5}{N}\big)$ decides the gate at the smaller factor.

This is the sense in which the $p+1$ weakness is *strictly more hidden* than the $p-1$ weakness. On the $p-1$ side, the exploitable condition is an order condition with no associated character, and the residue channel already exhibits a symmetric leak. On the $p+1$ side, the exploitable condition *is* a quadratic character of the hidden factor, and the only corresponding character of $N$ is the product of the two hidden ones — a quantity from which the individual values cannot be recovered even in principle. Every abelian invariant of $N$ (residues, Jacobi symbols, Dirichlet characters, Artin symbols in abelian extensions) is a product of the corresponding invariants of $p$ and $q$, hence invariant under the swap.

### 7.3 The tropical corner

A final structural remark ties the successful output to piecewise-linear geometry. The divisor pairs of $N$ lie on the hyperbola $xy = N$, whose logarithmic picture $\log x + \log y = \log N$ has a distinguished corner at $x = y = \sqrt N$. For any divisor $d \mid N$, the pair $\{d, N/d\}$ straddles the corner: $\min(d, N/d) \le \sqrt N \le \max(d, N/d)$.

**Proposition 7.5 (Output localization).** *When the Williams method succeeds at the smaller factor of $N = pq$, the value it returns is $p$ itself, and $p \le \lfloor \sqrt N \rfloor$.*

So the algorithm locates a lattice point in the window $[1, \sqrt N]$ — the lower branch of the corner locus — which, by Theorems 6.4 and 6.5, no statistic of $N$ can point to. The weakness lives on one side of a tropical corner and the modulus knows only the corner.

---

## 8. Experimental protocol and measurements

The theory above was developed to explain a controlled experiment; we report it here because the exact numerical coincidences are part of the evidence.

### 8.1 Design

Forty **matched pairs** of semiprimes were generated. Within each pair, the smaller factor had a fixed bit length ($18$) and the larger a fixed bit length ($21$); the two instances of a pair differed *only* in whether the smaller factor's $p+1$ was smooth:

- **PLUSONE class:** $p + 1$ divides $M = \operatorname{lcm}(1,\dots,100)$;
- **GENERAL class:** no smoothness engineered on $p \pm 1$ or $q \pm 1$.

Matching bit lengths within pairs removes size as a confounder, so any measured signal must come from the arithmetic, not from magnitude.

### 8.2 Positive control

Running the classical method with $M = \operatorname{lcm}(1,\dots,100)$ and bases $P \in \{3,5,7\}$:

| class | factored |
|---|---|
| PLUSONE ($p+1 \mid M$) | **24 / 40** |
| GENERAL | **0 / 40** |

The classes are genuinely different; there is a real weakness to detect. The base $P = 2$ was confirmed degenerate ($D = 0$), returning $\gcd = N$ on every instance, in agreement with Theorem 4.5.

### 8.3 The gate identity

Per-base success counts, and the counts of instances with $(D \mid p) = -1$:

| base $P$ | $D = P^2-4$ | successes | instances with $(D\mid p) = -1$ |
|---|---|---|---|
| $3$ | $5$ | 11 / 40 | 11 / 40 |
| $5$ | $21$ | 17 / 40 | 17 / 40 |
| $7$ | $45 = 5\cdot 3^2$ | 11 / 40 | 11 / 40 |

The agreement is exact, not approximate: all $24$ successes had $(D \mid p) = -1$, and no gate-closed instance ever succeeded. (A gate-closed instance is not *forbidden* to succeed: by Theorem 3.6 the roots then lie in $\mathbb{F}_p^\times$ and the run wins if the order of the root happens to divide $M$ — a $p-1$-type accident. None occurred in this sample, which is why the counts coincide exactly; what the theory guarantees unconditionally is the implication gate-open $\Rightarrow$ success.) Moreover bases $3$ and $7$ succeeded on *the same eleven instances*, as Theorem 5.3 requires. Theorem 3.7 explains the identity: for a nondegenerate base, the $p+1$ congruence holds precisely when the discriminant is a non-residue.

### 8.4 Residue invisibility

Mutual information (in bits) between $N \bmod \ell$ and two labels:

| $\ell$ | asymmetric: $\ell \mid p+1$ | symmetric: $\ell \mid p+1$ or $\ell \mid q+1$ |
|---|---|---|
| $3$ | 0.0005 | **0.2996** |
| $5$ | 0.0002 | 0.0327 |
| $7$ | 0.0014 | 0.0158 |
| $11$ | 0.0017 | 0.0070 |
| $13$ | 0.0022 | 0.0052 |

The asymmetric column sits at or below the null floor; the symmetric column is visible, dramatically so at $\ell = 3$. This is Theorem 7.1 versus Corollary 6.6, measured. (The decay along the symmetric column is expected: the probability that a random prime is $\equiv -1 \bmod \ell$ is $1/(\ell-1)$, so the symmetric event becomes rare and its information content shrinks.)

### 8.5 Trajectory invisibility

A third channel was tested: instead of reducing $N$, run the Lucas recurrence modulo $N$ and inspect the trajectory. Twenty-one features were extracted from windowed $V$-sequences (window length $256$, bases $3, 5, 7$) — moments, autocorrelations, residue histograms and gcd statistics. Maximum standardized difference between classes: $0.241$, *below* the null-model mean of $0.381$; permutation $p$-value $0.898$. The intermediate state of the attack itself carries no advance warning of whether the attack will succeed.

### 8.6 Character invisibility, measured

Among the $24$ successful instances, the publicly computable Jacobi symbol $(D \mid N)$ equalled $-1$ in $11$ of them, i.e. in about half — exactly the behaviour predicted by Theorem 7.3 and Proposition 7.4 when the two local symbols are otherwise unconstrained. Knowing $(D \mid N)$ tells the attacker nothing about whether the base-$P$ run will succeed.

---

## 9. Algorithms

For completeness we state the two procedures at the centre of the analysis.

### 9.1 Lucas ladder for $V_M \bmod N$

The recurrence must not be iterated $M$ times ($M \approx e^{B}$ digits of work). Instead one uses the doubling identities, valid for $Q = 1$:
$$V_{2k} = V_k^2 - 2, \qquad V_{2k+1} = V_k V_{k+1} - P .$$
Processing the bits of $M$ from the most significant down and maintaining the pair $(V_k, V_{k+1})$ costs $O(\log M)$ modular multiplications, i.e. $\tilde O(\log M \cdot \log^2 N)$ bit operations.

### 9.2 The Williams $p+1$ method

Given $N$, a smoothness bound $B$ and a base list, set $M = \operatorname{lcm}(1,\dots,B)$, compute $V_M \bmod N$ by the ladder, and return $\gcd(V_M - 2, N)$ if it is a nontrivial divisor. Complexity is $\tilde O(B \log N)$ multiplications for the ladder (since $\log M = \Theta(B)$ by the prime number theorem) plus one gcd. By Theorem 3.9 it provably succeeds when $p+1$ is $B$-powersmooth *and* $(P^2 - 4 \mid p) = -1$; by Theorem 5.1 a random base satisfies the second condition with probability about $1/2$, so $k$ bases with pairwise distinct discriminant square classes push the failure probability to about $2^{-k}$.

---

## 10. Discussion

### 10.1 What the null result does and does not say

It says: no function of the tested statistics — residues modulo any divisor of $60060$, Jacobi symbols supported there, bit length, and $21$ trajectory features — can decide either the smoothness label or the gate label of the smaller factor. Because Theorem 6.1 quantifies over arbitrary predicates, this is an information-theoretic statement, not a computational one; increasing the attacker's computing power does not help.

It does not say that $N$ is featureless. Theorem 7.1 exhibits a genuine, cheap, one-bit leak: the XOR of the two local $+1$-divisibility bits. The leak is real and symmetric, and symmetric leaks are useless for locating a weak factor. Nor does it say that the Williams method is weak: it is provably strong on gated smooth instances (Theorem 3.9). The claim is exactly that its applicability cannot be predicted more cheaply than by attempting it.

### 10.2 Consequences for key generation

Two practical corollaries follow. First, *screening is worthless*: there is no test on $N$ that flags $p+1$-smooth moduli, so a defender cannot audit a public key without the private factors. Second, and consequently, *the defence must be at generation time*: primes should be chosen so that $p \pm 1$ both have a large prime factor, a condition the generator can check because it knows $p$. Standards that already mandate "strong primes" for this reason are vindicated by the positive control, and the null result explains why the mandate cannot be replaced by a post-hoc check.

### 10.3 The general shape of the barrier

The unifying statement is that every statistic tested factors through the multiset $\{p, q\}$ — indeed through the elementary symmetric functions $p+q$ and $pq$ when only residues are used — while the target predicate distinguishes the two elements. Formally, the symmetric group $S_2$ acts on ordered factor pairs; $N$ is $S_2$-invariant; the label is not. Any $S_2$-invariant statistic that admits both orbit representatives in a common fibre (a "collision") is blind, and Dirichlet's theorem on primes in arithmetic progressions guarantees that colliding pairs with matched sizes and opposite labels are plentiful, not exceptional.

This suggests where an attack would have to live: in a statistic of $N$ that is neither multiplicative nor abelian, so that its value does not factor as a product of the corresponding local invariants of $p$ and $q$. No such statistic is known.

---

## 11. Future directions

The results above isolate one mechanism behind the whole $p \pm 1$ self-hint null: **every statistic computable from $N$ that has been tested is a symmetric function of the factor pair $\{p,q\}$, while the exploitable weakness is an asymmetric predicate of the smaller factor.** The residue channel realizes this as the XOR-only visibility of Theorem 7.1; the character channel realizes it as the product formula of Theorem 7.3. Two conjectures try to turn that observation from an explanation into a theorem, and to probe where it must break.

**Conjecture 1 (Symmetric-statistic barrier, quantitative form).** *Let $S$ be any predicate on primes that is not almost-everywhere constant on residue classes, and let $\mathrm{stat}$ be any function of $N$ that factors through the multiset $\{p \bmod m, q \bmod m\}$ for a fixed modulus $m$ together with $\lfloor \log_2 N\rfloor$. Then for every bound there exist admissible pairs $p<q$ and $p'<q'$ with all four primes of the same bit lengths, $pq \equiv p'q' \pmod m$, equal bit lengths of the products, $S(p)$ true and $S(p')$ false — and the number of such colliding bucket pairs grows like $\pi(2^b)^2/m$ as the bit length $b \to \infty$.*

The key insight is that $N \bmod m$ sees only the elementary symmetric functions $p+q$ and $pq$ of the residue pair, so a "which factor" predicate survives a full $S_2$-orbit inside every bucket, and Dirichlet density supplies both orbit representatives in equal proportion. The single collision witness $359 \cdot 5849 \equiv 397 \cdot 5743 \pmod{60060}$ is already in hand; what is missing is only the counting step, for which Dirichlet's theorem on primes in arithmetic progressions is exactly the right input — it would replace "one witness" by "positive density of witnesses".

**Conjecture 2 (Galois-theoretic upgrade: the invisible datum is a Frobenius conjugacy class).** *Fix a base $P$ with discriminant $D = P^2 - 4$. The base-$P$ Williams weakness at the smaller factor of $N$ is a function of the Frobenius class of $p$ in $\mathrm{Gal}(\mathbb{Q}(\sqrt D, \zeta_m)/\mathbb{Q})$, whereas everything computable from $N$ alone is a function of the **product** of the two Frobenius classes. Consequently no Chebotarev-type invariant of $N$ — not just $N \bmod m$ and Jacobi symbols, but any Artin symbol of $N$ in an abelian extension — can locate the weak factor.*

The key insight is that $(D \mid N) = (D\mid p)(D \mid q)$ and $N \bmod m$ are both instances of "the image of $N$ in an abelian character group is the product of the images of $p$ and $q$", so the entire abelian world is $S_2$-blind by construction; escaping it requires a genuinely non-abelian or non-multiplicative statistic. The abelian case is already established here (Theorem 7.3), and the abstract barrier of Theorem 6.1 is stated for an *arbitrary* statistic, so the upgrade is a matter of supplying Chebotarev-density inputs in place of the single witness.

Further directions worth pursuing:

- **Higher-degree analogues.** The $p+1$ method is the norm-one torus of a quadratic extension; cyclotomic-polynomial methods target $\Phi_k(p)$ for $k \ge 3$. Each has its own gate — a condition on the splitting of $p$ in a degree-$k$ field — and each gate should be invisible from $N$ for the same product-of-local-invariants reason. Making this uniform in $k$ would close the entire cyclotomic family at once.
- **Elliptic-curve analogue.** In ECM the group order is $p + 1 - a_p$ and varies with the curve, so the "gate" is replaced by a distribution over curves. Quantifying the corresponding invisibility statement — that no statistic of $N$ predicts which curves will work — would extend the programme to the general-purpose special method.
- **Optimal base lists.** Theorem 5.3 shows that discriminant square classes, not bases, are the resource being spent. Choosing base lists whose discriminants are multiplicatively independent modulo squares maximizes the number of independent gate trials per unit of arithmetic; a systematic study of such lists is elementary but appears not to have been done.
- **Sharpening the trajectory null.** The $21$-feature study rules out a specific family of statistics of the intermediate Lucas state. A theorem — say, that the distribution of the windowed trajectory modulo $N$ is statistically close between the two classes — would upgrade the measurement to a proof.

---

## 12. Conclusion

The Williams $p+1$ weakness is real, and it is sharper than folklore suggests: success is not implied by smoothness alone, but is driven by a quadratic character condition, $(P^2 - 4 \mid p) = -1$, at the hidden factor — a condition equivalent to the decisive congruence at the critical exponent — with exactly $(p-1)/2$ of the $p$ possible bases opening that gate, with $|P| \le 2$ unusable outright, and with discriminants in a common square class delivering literally the same trials.

And it is invisible. No predicate of $N \bmod 60060$ and the bit length decides either the smoothness label or the gate label of the smaller factor; no per-modulus residue does; the relevant character of $N$ is the product of the two hidden characters and therefore uninformative about their split; and the trajectory of the attack itself separates the classes at chance. Behind all four statements lies a single fact: the modulus is a symmetric function of its factors, and the weakness is not.

The lock has a flaw, and the lock does not tell you it has one.
