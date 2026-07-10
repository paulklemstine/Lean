# Rearranging the Primes: Density and Rigidity of Displacement Ratios in the Prime Hotel

## Abstract

We study rearrangements of an infinite indexed family of guests, where room $n$ of an infinite hotel is occupied by the $n$-th prime $p_n$. A rearrangement is a permutation $\sigma$ of the natural numbers; after rearranging, room $n$ holds the prime $p_{\sigma(n)}$. We measure the disruption caused by $\sigma$ through the *displacement ratio* $R_\sigma(n) = p_{\sigma(n)}/p_n$, and we call $\sigma$ *well behaved* when $R_\sigma(n) \to 1$, i.e. when guests asymptotically retain their magnitude. We prove three results. First, every finitely supported permutation is well behaved, with displacement ratio eventually equal to $1$. Second — the central result — the well-behaved permutations are *dense* in the symmetric group $\operatorname{Sym}(\mathbb{N})$ under the topology of pointwise convergence: every permutation is matched on any finite initial segment by a well-behaved one. Third, the property is not universal: we construct an explicit involution, assembled from a sparse family of prime-doubling long-range swaps, whose displacement ratio is $\ge 2$ infinitely often and hence fails to converge. All three results depend only on the primes being a strictly increasing unbounded sequence, so they hold verbatim for any such sequence; the Prime Number Theorem is not required. We conclude with conjectures, in particular a proposed characterization of well-behaved permutations via $\sigma(n)/n \to 1$, and a discussion of how to quantify the "density" of well-behaved permutations in the sense of Baire category.

**Keywords:** prime numbers, symmetric group, permutations of $\mathbb{N}$, pointwise convergence, density, asymptotic invariants, displacement ratio, finite support.

---

## 1. Introduction

Hilbert's hotel is a classical illustration of the counterintuitive arithmetic of infinite sets: a fully occupied hotel with rooms indexed by $\mathbb{N}$ can still accommodate new guests by relabeling. We adopt the hotel as a staging ground for a question about the *stability of the prime numbers under rearrangement*.

Assign to room $n \in \mathbb{N}$ the $n$-th prime $p_n$. Because there are infinitely many primes, every room is occupied. A *rearrangement of the guests* is a bijection $\sigma : \mathbb{N} \to \mathbb{N}$; we interpret it as sending the guest originally in room $\sigma(n)$ into room $n$, so that after the rearrangement room $n$ holds the prime $p_{\sigma(n)}$.

The quantity of interest is how much the magnitude of a room's occupant changes. We define the **displacement ratio**
$$
R_\sigma(n) = \frac{p_{\sigma(n)}}{p_n},
$$
and declare $\sigma$ **well behaved** when $R_\sigma(n) \to 1$ as $n \to \infty$: asymptotically, the prime now in room $n$ is essentially the same size as the one that used to be there.

Two questions drive the paper:

1. **How plentiful are well-behaved rearrangements?** We show they are *dense* in the natural topology on $\operatorname{Sym}(\mathbb{N})$: no finite observation can rule out well-behavedness.
2. **Is well-behavedness automatic?** We show it is not, by an explicit construction.

A pleasant feature of the analysis is its economy. The only property of the sequence $n \mapsto p_n$ that we use is that it is strictly increasing and tends to infinity. Consequently, all main results hold for an arbitrary strictly increasing unbounded sequence $a : \mathbb{N} \to \mathbb{N}$; nothing about primality beyond monotone growth is needed, and in particular the Prime Number Theorem is *not* invoked.

---

## 2. Definitions and basic properties of the prime rooms

Let $p : \mathbb{N} \to \mathbb{N}$ enumerate the primes in increasing order, $p_0 = 2, p_1 = 3, p_2 = 5, \dots$ (we index from $0$ for convenience). We record the elementary facts we rely on.

**Proposition 2.1 (Basic properties).**
1. $p_n$ is prime for every $n$; in particular $p_n > 0$ and $(p_n : \mathbb{R}) \ne 0$.
2. $p$ is strictly monotone: $m < n \implies p_m < p_n$. Hence $p$ is injective.
3. $p_n \to \infty$ as $n \to \infty$.

*Proof.* Enumerating an infinite set of naturals in increasing order yields a strictly monotone function whose values are exactly that set; the set of primes is infinite (Euclid), giving (1)–(2). A strictly monotone function $\mathbb{N} \to \mathbb{N}$ tends to infinity, giving (3). $\square$

Everything below uses only Proposition 2.1(2)–(3).

**Definition 2.2 (Displacement ratio).** For $\sigma \in \operatorname{Sym}(\mathbb{N})$ and $n \in \mathbb{N}$, set
$$
R_\sigma(n) = \frac{p_{\sigma(n)}}{p_n} \in \mathbb{R}.
$$

**Definition 2.3 (Well behaved).** A permutation $\sigma \in \operatorname{Sym}(\mathbb{N})$ is *well behaved* if $R_\sigma(n) \to 1$ as $n \to \infty$.

We give $\operatorname{Sym}(\mathbb{N}) \subseteq \mathbb{N}^{\mathbb{N}}$ the topology of **pointwise convergence**: a basic neighborhood of $\sigma$ is
$$
U_{\sigma, N} = \{ \tau : \tau(i) = \sigma(i) \text{ for all } i < N \}, \qquad N \in \mathbb{N}.
$$
A set $S \subseteq \operatorname{Sym}(\mathbb{N})$ is dense iff every $U_{\sigma, N}$ meets $S$, i.e. iff for every $\sigma$ and $N$ there is a member of $S$ agreeing with $\sigma$ on $\{0, \dots, N-1\}$.

---

## 3. Finitely supported rearrangements are well behaved

The *support* of $\sigma$ is $\operatorname{supp}(\sigma) = \{ n : \sigma(n) \ne n \}$. We say $\sigma$ is *finitely supported* if $\operatorname{supp}(\sigma)$ is finite.

**Lemma 3.1 (Eventually identity).** If $\operatorname{supp}(\sigma)$ is finite, there is $N$ with $\sigma(n) = n$ for all $n \ge N$.

*Proof.* A finite set of naturals is bounded above by some $M$; take $N = M + 1$. Any $n \ge N$ lies outside $\operatorname{supp}(\sigma)$, so $\sigma(n) = n$. $\square$

**Lemma 3.2 (Eventual identity implies well behaved).** If there is $N$ with $\sigma(n) = n$ for all $n \ge N$, then $\sigma$ is well behaved; indeed $R_\sigma(n) = 1$ for all $n \ge N$.

*Proof.* For $n \ge N$, $\sigma(n) = n$, so $R_\sigma(n) = p_n / p_n = 1$ (using $p_n \ne 0$). A sequence eventually equal to the constant $1$ converges to $1$. $\square$

**Theorem 3.3 (Finite support ⇒ well behaved).** Every finitely supported permutation is well behaved.

*Proof.* Combine Lemmas 3.1 and 3.2. $\square$

In particular the identity permutation is well behaved (trivially, $R_{\mathrm{id}}(n) \equiv 1$).

---

## 4. Density of well-behaved rearrangements

The heart of the paper is that well-behavedness cannot be detected on any finite window.

**Lemma 4.1 (Finite-support approximation).** For every $\sigma \in \operatorname{Sym}(\mathbb{N})$ and every $N \in \mathbb{N}$, there is a finitely supported permutation $\tau$ with $\tau(i) = \sigma(i)$ for all $i < N$.

*Proof.* Induction on $N$.

*Base $N = 0$.* Take $\tau = \mathrm{id}$; the condition "$\tau(i) = \sigma(i)$ for all $i < 0$" is vacuous, and $\mathrm{id}$ has empty support.

*Step $N \to N+1$.* Suppose $\tau$ is finitely supported with $\tau(i) = \sigma(i)$ for all $i < N$. We adjust $\tau$ at index $N$ without breaking the earlier agreements. Consider the transposition $\operatorname{swap}(\tau(N), \sigma(N))$ (the identity if $\tau(N) = \sigma(N)$), and set
$$
\tau' = \operatorname{swap}(\tau(N), \sigma(N)) \circ \tau.
$$
Then $\tau'(N) = \operatorname{swap}(\tau(N), \sigma(N))(\tau(N)) = \sigma(N)$, so $\tau'$ agrees with $\sigma$ at $N$.

We check the earlier agreements survive. For $i < N$ we have $\tau(i) = \sigma(i)$. We must show the swap fixes $\tau(i)$, i.e. that $\tau(i) \notin \{\tau(N), \sigma(N)\}$. Since $\tau$ is injective and $i \ne N$, $\tau(i) \ne \tau(N)$. Also $\sigma(N) = \tau'(N)$ and, once we know $\tau'$ is a permutation agreeing with $\sigma$ (hence injective), $\sigma(i) = \sigma(N)$ would force $i = N$; more directly, $\sigma(N) = \tau(i)$ would give $\sigma(N) = \sigma(i)$ (using $\tau(i)=\sigma(i)$), contradicting injectivity of $\sigma$ for $i \ne N$. Hence the swap fixes $\tau(i)$ and $\tau'(i) = \tau(i) = \sigma(i)$.

Finally, $\operatorname{supp}(\tau') \subseteq \operatorname{supp}(\tau) \cup \{\tau(N), \sigma(N)\}$ is finite, since composing with a transposition enlarges the support by at most two points. This completes the induction. $\square$

**Theorem 4.2 (Density theorem).** For every $\sigma \in \operatorname{Sym}(\mathbb{N})$ and every $N \in \mathbb{N}$, there exists a well-behaved permutation $\tau$ with $\tau(i) = \sigma(i)$ for all $i < N$. Equivalently, the set $\{\sigma : \sigma \text{ well behaved}\}$ is dense in $\operatorname{Sym}(\mathbb{N})$ for the topology of pointwise convergence.

*Proof.* Given $\sigma$ and $N$, Lemma 4.1 supplies a finitely supported $\tau$ agreeing with $\sigma$ on $\{0, \dots, N-1\}$. By Theorem 3.3, $\tau$ is well behaved. The neighborhood $U_{\sigma, N}$ therefore meets the well-behaved set; as the $U_{\sigma, N}$ form a neighborhood basis, density follows. $\square$

Theorem 4.2 is the precise form of the informal claim that "you can shuffle the primes almost arbitrarily and the room magnitudes barely change": any prescribed finite reshuffling extends to a global reshuffle whose displacement ratios tend to $1$.

---

## 5. Well-behavedness is not universal

Density leaves open whether *every* permutation is well behaved. It is not. We build an explicit counterexample using only monotone unbounded growth of $p$.

**Lemma 5.1 (Prime doubling).** For every $m \in \mathbb{N}$ there is $b > m$ with $2 p_m \le p_b$.

*Proof.* Since $p_n \to \infty$, eventually $p_n > 2 p_m$; choosing such an $n$ that also exceeds $m$ gives $b = n$. $\square$

**Definition 5.2 (Jump sequence).** Define $j : \mathbb{N} \to \mathbb{N}$ recursively by $j_0 = 0$ and $j_{k+1} = $ a witness $b > j_k$ with $2 p_{j_k} \le p_b$ furnished by Lemma 5.1.

**Lemma 5.3 (Properties of the jump sequence).**
1. $j_k < j_{k+1}$ for all $k$; hence $j$ is strictly monotone and injective, and $k \le j_k$.
2. $2 p_{j_k} \le p_{j_{k+1}}$ for all $k$.

*Proof.* Immediate from Definition 5.2 and Lemma 5.1; strict monotonicity of a step-increasing sequence gives injectivity and $k \le j_k$. $\square$

We now pair up the landmarks $j_0 \leftrightarrow j_1$, $j_2 \leftrightarrow j_3$, $\dots$ To formalize the pairing, define the *toggle*
$$
t(k) = \begin{cases} k+1 & k \text{ even},\\ k-1 & k \text{ odd},\end{cases}
$$
which is an involution swapping each even number with its odd successor; note $t(2j) = 2j+1$.

**Definition 5.4 (Bad rearrangement).** Define $\beta : \mathbb{N} \to \mathbb{N}$ by
$$
\beta(n) = \begin{cases} j_{t(k)} & \text{if } n = j_k \text{ for some } k,\\ n & \text{if } n \text{ is not a landmark.}\end{cases}
$$
Since $j$ is injective, the case $n = j_k$ determines $k$ uniquely, so $\beta$ is well defined.

**Lemma 5.5 ($\beta$ is an involution).** $\beta(\beta(n)) = n$ for all $n$; in particular $\beta \in \operatorname{Sym}(\mathbb{N})$.

*Proof.* If $n$ is not a landmark then $\beta(n) = n$ and $\beta(\beta(n)) = n$. If $n = j_k$, then $\beta(n) = j_{t(k)}$, which is a landmark, so $\beta(j_{t(k)}) = j_{t(t(k))} = j_k = n$, using that $t$ is an involution. As $\beta$ is a self-inverse map $\mathbb{N} \to \mathbb{N}$, it is a bijection. $\square$

**Theorem 5.6 (Not universal).** The permutation $\beta$ is not well behaved. Precisely, $R_\beta(n) \ge 2$ for infinitely many $n$ — namely at every even landmark $n = j_{2i}$.

*Proof.* Fix $i$ and let $n = j_{2i}$. Then $t(2i) = 2i + 1$, so $\beta(n) = j_{2i+1}$ and
$$
R_\beta(n) = \frac{p_{\beta(n)}}{p_n} = \frac{p_{j_{2i+1}}}{p_{j_{2i}}} \ge \frac{2 p_{j_{2i}}}{p_{j_{2i}}} = 2,
$$
using Lemma 5.3(2). The indices $j_{2i}$ are distinct (Lemma 5.3(1)) and increase without bound, so $R_\beta(n) \ge 2$ for infinitely many $n$. A sequence that is $\ge 2$ infinitely often cannot converge to $1$. Hence $\beta$ is not well behaved. $\square$

Theorem 5.6 shows the phenomenon is genuine: the well-behaved permutations, though dense (Theorem 4.2), form a proper subset of $\operatorname{Sym}(\mathbb{N})$.

---

## 6. Generality: any strictly increasing unbounded sequence

Inspecting the proofs, the only inputs are:

- **Monotonicity** ($p$ strictly increasing, hence injective) — used in Lemma 4.1 and to make $j$ injective;
- **Unboundedness** ($p_n \to \infty$) — used in Lemma 5.1 (prime doubling).

Neither uses primality per se. Hence:

**Theorem 6.1 (Sequence-agnostic form).** Let $a : \mathbb{N} \to \mathbb{N}$ be any strictly increasing sequence with $a_n \to \infty$, and define $R^a_\sigma(n) = a_{\sigma(n)}/a_n$ and well-behavedness accordingly. Then: (i) every finitely supported $\sigma$ is well behaved; (ii) the well-behaved permutations are dense in $\operatorname{Sym}(\mathbb{N})$; (iii) there is a permutation that is not well behaved.

Thus the well-behaved/ill-behaved dichotomy is a structural feature of *infinite monotone growth*, not of arithmetic. The asymptotic magnitude of a room's occupant is an invariant robust to finite meddling, approximable to any finite precision, yet vulnerable to engineered long-range disorder.

---

## 7. Algorithms

We describe the computational counterparts used in the accompanying numerical study.

**Algorithm A (Displacement ratios of a rearrangement).** Given the first $M$ primes and a permutation $\sigma$ of $\{0, \dots, M-1\}$, compute $R_\sigma(n) = p_{\sigma(n)}/p_n$ for each $n$ and summarize the tail (mean, spread, and fraction within $\varepsilon$ of $1$). This empirically probes well-behavedness.

**Algorithm B (Finite-support approximant).** Given a target permutation $\sigma$ and horizon $N$, build the finite-support permutation $\tau$ agreeing with $\sigma$ on $\{0, \dots, N-1\}$ by the inductive transposition construction of Lemma 4.1, then verify $R_\tau(n) = 1$ for $n \ge \max(\operatorname{supp}\tau) + 1$.

**Algorithm C (Bad-permutation generator).** Build the jump sequence $j$ by greedily choosing, at each step, the least later index whose prime at least doubles the current one, pair up the landmarks, and confirm $R_\beta(j_{2i}) \ge 2$.

---

## 8. Applications and interpretation

- **A topological invariant of shuffling.** Density plus non-universality says the well-behaved set is a dense proper subset. Asymptotic magnitude is preserved under arbitrarily large but "asymptotically gentle" rearrangements, giving a clean example of an invariant that finite data cannot detect.
- **A template for rigidity results.** Theorem 6.1 packages a reusable pattern: monotone unbounded sequences admit dense families of magnitude-preserving rearrangements and explicit magnitude-distorting ones. This applies to squares, factorials, Fibonacci numbers, and beyond.
- **Pedagogy of infinity.** The prime hotel makes vivid the difference between *pointwise* control (finite windows) and *asymptotic* control (tails) — the same distinction underlying uniform vs. pointwise convergence.

---

## 9. Discussion and future work

The formalized results deliberately avoid the Prime Number Theorem, isolating the purely combinatorial core. The primes re-enter when we ask sharper, quantitative questions.

1. **Topologize the statement.** Replace the "agrees on $\{0,\dots,N-1\}$" formulation of density by the actual product topology on $\operatorname{Sym}(\mathbb{N})$ and prove that the well-behaved set is dense as a topological predicate. The neighborhood-basis form proved here is exactly this in disguise.

2. **The swap-even/odd example, honestly.** Prove that $\sigma : n \mapsto n \oplus 1$ (swap each even index with its odd successor) is well behaved. This requires $p_{n+1}/p_n \to 1$, i.e. that prime gaps are $o(p_n)$ — a consequence of the Prime Number Theorem. This is the canonical example of a permutation that is well behaved yet moves *every* guest.

3. **Characterize well-behaved permutations.** Conjecture: $\sigma$ is well behaved iff $p_{\sigma(n)}/p_n \to 1$, and, using $p_n \sim n \log n$, this is equivalent to $\sigma(n)/n \to 1$. Then the well-behaved permutations are exactly those of asymptotically unit index distortion — a clean asymptotic invariant.

4. **Quantify the "exact density."** Topologically the well-behaved set is dense but *meager* (a countable-to-one shadow of an $F_\sigma$-type condition). Making "density" precise via Baire category, or via a natural measure on $\operatorname{Sym}(\mathbb{N})$, and computing it, is open and enticing.

5. **Ratios with limits $\ne 1$.** Generalize to "the displacement ratio has *a* limit $L$"; study which $L$ are attainable and how the corresponding permutations sit inside $\operatorname{Sym}(\mathbb{N})$.

6. **Other room-filling sequences.** As in Theorem 6.1, replace primes by any strictly monotone unbounded $a : \mathbb{N} \to \mathbb{N}$; the finite-support density argument is unchanged and the negative result persists whenever $a$ is unbounded. Only the rate results (items 2–3) are arithmetic-specific.

---

## 10. Conclusion

The prime hotel exhibits a crisp trichotomy of rearrangements. Finite reshuffles are trivially well behaved. Well-behaved reshuffles are dense — indistinguishable from arbitrary ones on any finite window. Yet well-behavedness is not automatic: an explicit involution built from prime-doubling long-range swaps distorts magnitudes by a factor $\ge 2$ infinitely often. The primes are robust under rearrangement, but only almost; that qualification is the mathematics.
