# The Collatz Map: Dynamics, a Min-Plus Stopping-Time Recurrence, and the Logic of Halting

## Abstract

The Collatz (or $3n+1$) map sends an even positive integer $n$ to $n/2$ and an odd $n$ to $3n+1$; the Collatz conjecture asserts that iterating this map from any positive integer eventually reaches $1$. We give a rigorous, self-contained development of the elementary dynamical theory of the map, isolate the precise logical shape of the conjecture and of any putative refutation, and exhibit a **min-plus (tropical) recurrence** governing the total stopping time. Our contributions are fourfold. First, we characterize the orbits of powers of two exactly: $2^m$ reaches $1$ in precisely $m$ steps. Second, we prove that the halting predicate is invariant along the orbit — reaching $1$ from $n \neq 1$ is equivalent to reaching $1$ from $T(n)$ — and we identify the negation of the conjecture with the existence of a single positive counterexample. Third, we show that the (a priori unbounded) halting predicate is the countable union of decidable bounded predicates, exposing the search structure underlying all numerical verification and the absence of any uniform certificate bound. Fourth, we prove that the total stopping time satisfies a Bellman-type shortest-path law, $\sigma(n) = 1 + \sigma(T(n))$ for $n \neq 1$ with $\sigma(1)=0$, which is precisely the fixed-point equation of a shortest-path operator in the tropical semiring $(\mathbb{N}\cup\{\infty\}, \min, +)$. We discuss how this reframing situates the conjecture within tropical dynamics and the logic of provability, and we record concrete verified orbits and open directions. All results stated as theorems are unconditional; the conjecture itself is never assumed.

**Keywords:** Collatz conjecture, $3n+1$ problem, tropical semiring, min-plus algebra, stopping time, shortest path, Bellman equation, decidability, arithmetic dynamics.

---

## 1. Introduction

The Collatz conjecture is among the most accessible unsolved problems in mathematics. Its statement requires nothing beyond parity and division, yet it has resisted proof since the 1930s and has been verified numerically for all starting values up to roughly $2^{68}$. The problem's resistance is often attributed to the competition between two forces: the contraction $n \mapsto n/2$ on even inputs and the expansion $n \mapsto 3n+1$ on odd inputs. Probabilistic heuristics suggest orbits contract on average by a factor near $3/4$ per odd step, so almost all orbits should descend to $1$; but such heuristics say nothing rigorous about *every* orbit, and a single divergent or non-trivially cyclic orbit would refute the conjecture.

This paper does not resolve the conjecture. Instead it does three things that we believe clarify *why* the problem is hard and *where* its difficulty is concentrated:

1. It develops the elementary dynamics rigorously, including the exact stopping time of powers of two and the orbit-invariance of the halting predicate.
2. It pins down the logical form of the conjecture and its negation, and it decomposes the halting predicate into a countable union of decidable bounded predicates — making explicit the "search with no a priori bound" that any verification confronts.
3. It exhibits a tropical (min-plus) recurrence for the total stopping time, connecting the Collatz dynamics to shortest-path theory and dynamic programming.

Throughout, we are careful to separate what is proved unconditionally from what is speculative. The much-discussed possibility that the conjecture is independent of strong base theories is *not* claimed as a theorem; it is recorded only as motivation and as a future direction. Every result labeled Theorem, Proposition, or Lemma below is established unconditionally, and the conjecture is never used as a hypothesis.

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and $T^{(k)}$ denotes the $k$-fold composition of $T$, with $T^{(0)}$ the identity.

**Definition 2.1 (Collatz map).** The *Collatz map* $T : \mathbb{N} \to \mathbb{N}$ is
$$
T(n) = \begin{cases} n/2, & n \equiv 0 \pmod 2,\\ 3n+1, & n \equiv 1 \pmod 2.\end{cases}
$$

**Definition 2.2 (Reaches).** A number $n$ *reaches* $1$, written $\mathrm{Reaches}(n)$, if there exists $k \in \mathbb{N}$ with $T^{(k)}(n) = 1$.

**Definition 2.3 (Collatz conjecture).** The *Collatz conjecture* is the proposition
$$
\mathrm{Collatz} :\equiv \forall n,\ (0 < n) \Rightarrow \mathrm{Reaches}(n).
$$

**Definition 2.4 (Bounded halting predicate).** For $b, n \in \mathbb{N}$, say $n$ *reaches $1$ within $b$ steps*, written $\mathrm{ReachesWithin}(b, n)$, if there exists $k \le b$ with $T^{(k)}(n) = 1$. For each fixed $b$ this predicate is decidable, since it is a finite disjunction over $k \in \{0, 1, \dots, b\}$.

**Definition 2.5 (Total stopping time).** If $\mathrm{Reaches}(n)$ holds, the *total stopping time* $\sigma(n)$ is the least $k$ with $T^{(k)}(n) = 1$; equivalently $\sigma(n) = \min\{k : T^{(k)}(n) = 1\}$, which is well defined by the least-number principle.

## 3. Elementary evaluation and the fixed cycle

We record the defining case split and the unique cycle through $1$.

**Lemma 3.1 (Evaluation).** For all $n$: if $n$ is even then $T(n) = n/2$; if $n$ is odd then $T(n) = 3n+1$. In particular $T(2n) = n$ for all $n$, and $T(1) = 4$.

*Proof.* Immediate from Definition 2.1 by case analysis on $n \bmod 2$; the identity $T(2n) = 2n/2 = n$ uses exactness of division by $2$ on even inputs. $\qquad\blacksquare$

**Lemma 3.2 (The cycle through $1$).** $T^{(3)}(1) = 1$; explicitly $1 \to 4 \to 2 \to 1$.

*Proof.* $T(1) = 4$, $T(4) = 2$, $T(2) = 1$ by direct computation. $\qquad\blacksquare$

Lemma 3.2 shows that "$\mathrm{Reaches}(n)$" captures the intended terminal behavior: once the orbit meets $1$ it enters the trivial $3$-cycle and never escapes.

## 4. Orbit invariance of the halting predicate

The halting predicate propagates both forward and backward along the orbit, away from the fixed point.

**Lemma 4.1 (Backward invariance).** If $\mathrm{Reaches}(T(n))$ then $\mathrm{Reaches}(n)$.

*Proof.* If $T^{(k)}(T(n)) = 1$ then $T^{(k+1)}(n) = 1$ by the composition law $T^{(k+1)}(n) = T^{(k)}(T(n))$. $\qquad\blacksquare$

**Lemma 4.2 (Forward invariance).** If $n \neq 1$ and $\mathrm{Reaches}(n)$, then $\mathrm{Reaches}(T(n))$.

*Proof.* Let $k$ be least with $T^{(k)}(n) = 1$. If $k = 0$ then $n = 1$, contradicting $n \neq 1$; hence $k = k'+1$ and $T^{(k')}(T(n)) = T^{(k'+1)}(n) = 1$, so $\mathrm{Reaches}(T(n))$. $\qquad\blacksquare$

**Theorem 4.3 (Orbit invariance).** For $n \neq 1$,
$$
\mathrm{Reaches}(n) \iff \mathrm{Reaches}(T(n)).
$$

*Proof.* Combine Lemmas 4.1 and 4.2. $\qquad\blacksquare$

Theorem 4.3 says the halting question is a property of the *orbit graph* rather than of any particular starting point: it is stable under single-step reparametrization. This is the structural fact that makes acceleration schemes (e.g. the odd-step map $n \mapsto (3n+1)/2$) natural to study, since they only reparametrize the same graph.

## 5. Powers of two: exact stopping time

**Theorem 5.1 (Powers of two).** For every $m \in \mathbb{N}$, $T^{(m)}(2^m) = 1$. Consequently $\mathrm{Reaches}(2^m)$ and $\sigma(2^m) = m$.

*Proof.* Induct on $m$. For $m = 0$, $T^{(0)}(1) = 1$. For the step, write $2^{m+1} = 2 \cdot 2^m$; then $T(2^{m+1}) = 2^m$ by Lemma 3.1, so
$$
T^{(m+1)}(2^{m+1}) = T^{(m)}\big(T(2^{m+1})\big) = T^{(m)}(2^m) = 1
$$
by the inductive hypothesis. Thus $\mathrm{Reaches}(2^m)$. Minimality of $m$ (so that $\sigma(2^m) = m$) follows because the orbit $2^m \to 2^{m-1} \to \cdots \to 1$ is strictly decreasing and does not meet $1$ before step $m$. $\qquad\blacksquare$

Powers of two are thus the *geodesics* of the orbit graph: their stopping time equals their $2$-adic exponent with no detour, providing an exact benchmark against which the erratic orbits of other integers can be measured.

## 6. Concrete orbits

Two nontrivial orbits illustrate the wide variation in stopping times.

**Proposition 6.1.** $\mathrm{Reaches}(7)$ with $\sigma(7) = 16$, and $\mathrm{Reaches}(27)$ with $\sigma(27) = 111$.

*Proof.* Direct finite computation of the orbits:
$$
7 \to 22 \to 11 \to 34 \to 17 \to 52 \to 26 \to 13 \to 40 \to 20 \to 10 \to 5 \to 16 \to 8 \to 4 \to 2 \to 1
$$
uses $16$ steps, and the orbit of $27$ (which peaks at $9232$) reaches $1$ in $111$ steps. $\qquad\blacksquare$

The contrast between $\sigma(7) = 16$ and $\sigma(27) = 111$ — despite the closeness of the starting values — is the empirical face of the problem's difficulty: stopping time is a wildly irregular function of the input.

## 7. The logical shape of the conjecture

**Theorem 7.1 (Refutation is a single counterexample).**
$$
\lnot\,\mathrm{Collatz} \iff \exists n,\ (0 < n) \land \lnot\,\mathrm{Reaches}(n).
$$

*Proof.* $\mathrm{Collatz}$ is the universally quantified implication $\forall n,\ 0 < n \Rightarrow \mathrm{Reaches}(n)$; its negation is, by the standard prenex laws, $\exists n,\ 0 < n \land \lnot\mathrm{Reaches}(n)$. $\qquad\blacksquare$

Theorem 7.1 makes the fundamental asymmetry explicit: the conjecture is $\Pi_2$ in form (a "for all $n$ there exists $k$" statement), whereas any refutation is witnessed by a single $n$. This is why a disproof could in principle be a finite object, while a proof must control all orbits simultaneously.

**Theorem 7.2 (Search decomposition).** For all $n$,
$$
\mathrm{Reaches}(n) \iff \exists b,\ \mathrm{ReachesWithin}(b, n).
$$

*Proof.* If $T^{(k)}(n) = 1$ then $\mathrm{ReachesWithin}(k, n)$ holds with witness $k \le k$. Conversely, if $\mathrm{ReachesWithin}(b, n)$ holds then some $k \le b$ satisfies $T^{(k)}(n) = 1$, so $\mathrm{Reaches}(n)$. $\qquad\blacksquare$

Because each $\mathrm{ReachesWithin}(b, \cdot)$ is decidable (Definition 2.4), Theorem 7.2 exhibits $\mathrm{Reaches}$ as a countable union of decidable bounded predicates — a $\Sigma_1$ predicate. Verification is therefore always possible for numbers that *do* halt (search until a witness $b$ appears), but there is **no uniform bound** on $b$ as a function of $n$. The growth rate of the least such $b$ — equivalently of $\sigma(n)$ — is precisely the quantity that any completeness or independence argument must control. Numerical verification up to $2^{68}$ is exactly the assertion that a finite (input-dependent) bound suffices for all $n$ in that range; the conjecture is the assertion that a finite bound always suffices.

## 8. The min-plus stopping-time recurrence

We now identify the stopping time as a shortest-path function.

**Theorem 8.1 (Bellman / min-plus recurrence).** $\sigma(1) = 0$, and for every $n \neq 1$ that reaches $1$,
$$
\sigma(n) = 1 + \sigma\big(T(n)\big).
$$

*Proof.* $\sigma(1) = 0$ because $T^{(0)}(1) = 1$ and no smaller index exists. For $n \neq 1$: by Lemma 4.2, $T(n)$ reaches $1$, so $\sigma(T(n))$ is defined. We show $\sigma(n) = \sigma(T(n)) + 1$ by verifying the two defining properties of the least witness. First, $T^{(\sigma(T(n))+1)}(n) = T^{(\sigma(T(n)))}(T(n)) = 1$, so $\sigma(T(n))+1$ is a witness. Second, minimality: suppose $j < \sigma(T(n))+1$ with $T^{(j)}(n) = 1$. If $j = 0$ then $n = 1$, contradiction; so $j = i+1$ with $i < \sigma(T(n))$ and $T^{(i)}(T(n)) = T^{(i+1)}(n) = 1$, contradicting minimality of $\sigma(T(n))$. Hence $\sigma(n) = \sigma(T(n)) + 1$. $\qquad\blacksquare$

**Tropical interpretation.** Work in the *min-plus semiring* $\mathbb{T} = (\mathbb{N} \cup \{\infty\}, \oplus, \otimes)$ where $a \oplus b = \min(a,b)$ and $a \otimes b = a + b$, with additive identity $\infty$ and multiplicative identity $0$. Model the positive integers as the vertex set of a directed graph $G$ with a single outgoing edge $n \to T(n)$ of weight $1$, and a distinguished terminal vertex $1$ with $\sigma(1) = 0$. The general shortest-path (Bellman) equation in $\mathbb{T}$ reads
$$
\sigma(n) = \bigoplus_{m : n \to m} \big(w(n,m) \otimes \sigma(m)\big),
$$
which, because $T$ is a function (a unique successor $m = T(n)$ of weight $1$), collapses to $\sigma(n) = 1 \otimes \sigma(T(n)) = 1 + \sigma(T(n))$ — exactly Theorem 8.1. Thus the Collatz total stopping time is the shortest-path (indeed unique-path) length to the sink $1$ in the tropical weighting of the orbit graph. Equivalently, $\sigma$ is a fixed point of the tropical Bellman operator $\Phi$ defined by $(\Phi f)(1) = 0$ and $(\Phi f)(n) = 1 + f(T(n))$; the Collatz conjecture is exactly the statement that this operator has a *total* (everywhere-finite) least fixed point on the positive integers.

This reframing places Collatz within the well-developed theory of shortest paths and min-plus linear algebra, and it converts the conjecture from a statement about integer arithmetic into a statement about **global reachability of a sink in an infinite min-plus dynamical system.**

## 9. Algorithms

We summarize the computational content extracted above.

**Algorithm A (Orbit / stopping time).** Given $n \ge 1$, iterate $T$, counting steps, until $1$ is reached. This computes $\sigma(n)$ and the full orbit. It terminates iff $\mathrm{Reaches}(n)$; by Theorem 7.2 there is no a priori step bound.

**Algorithm B (Bounded verifier).** Given $n$ and a budget $b$, iterate $T$ at most $b$ times and report whether $1$ was reached. This decides $\mathrm{ReachesWithin}(b, n)$ and always terminates. Range verification up to $N$ runs Algorithm B (with a generous $b$) for each $n \le N$.

**Algorithm C (Tropical fixed-point sweep).** On a finite window $\{1, \dots, N\}$ closed appropriately under $T$, initialize $\sigma(1) = 0$ and $\sigma(n) = \infty$ otherwise, then repeatedly apply the tropical Bellman update $\sigma(n) \leftarrow \min(\sigma(n),\, 1 + \sigma(T(n)))$ until stabilization. This is Bellman–Ford specialized to the single-successor Collatz graph and recovers $\sigma$ on the window.

## 10. Applications and connections

- **Arithmetic dynamics.** The orbit-invariance theorem shows halting is a graph property, clarifying why accelerated maps share the same undecidability profile.
- **Tropical geometry / optimization.** The stopping time is a genuine shortest-path function; techniques from min-plus linear algebra and dynamic programming apply directly to the finite-window problem (Algorithm C).
- **Logic of provability.** The search decomposition (Theorem 7.2) isolates the growth of the certificate bound as the sole obstacle to a finite proof, which is the precise quantity relevant to any independence phenomenon.

## 11. Discussion: the independence question

It is often speculated that the Collatz conjecture might be independent of strong base theories — true in the standard model of arithmetic yet unprovable. The intuition is that a proof would require bounding the stopping time $\sigma(n)$ by a provably total function, and the extreme irregularity of $\sigma$ (Proposition 6.1) suggests such a bound, if it exists, may outgrow the provably total functions of weak arithmetic. We emphasize that **this paper asserts no such independence result.** What we *do* establish is the exact structural setting in which such a question lives: $\mathrm{Collatz}$ is $\Pi_2$; its refutation is a single $\Sigma_1$ witness (Theorem 7.1); and its positive content is a countable union of decidable facts with no uniform bound (Theorem 7.2). Any future independence argument must engage precisely this structure.

## 12. Future work

- **Uniqueness of the tropical fixed point.** Upgrade Theorem 8.1 to show $\sigma$ is the *least* fixed point of the Bellman operator $\Phi$, and that $\Phi$ contracts in a natural graph metric on the halting set.
- **Certificate-bound growth.** Investigate whether the least verification budget $b(N)$ (equivalently $\max_{n \le N} \sigma(n)$) can be bounded by any primitive-recursive function admitting a low-complexity proof.
- **Accelerated map reduction.** Prove that the halting problems for $T$ and the odd-step map $n \mapsto (3n+1)/2$ are interreducible by stopping-time-preserving translations, transferring any structural phenomenon between them.
- **Cycle exclusion.** Develop tropical/min-plus obstructions to nontrivial cycles, i.e. finite closed walks in the orbit graph avoiding the sink $1$.

## 13. Conclusion

From a rule expressible in a single sentence we have extracted a rigorous elementary theory: the exact stopping time of powers of two, the orbit-invariance of halting, the single-witness form of any refutation, the decomposition of halting into decidable bounded searches, and a tropical Bellman recurrence identifying the stopping time as a shortest-path function. Together these results do not solve the Collatz conjecture, but they locate its difficulty with precision — in the uncontrolled growth of a certificate bound — and they connect the problem to tropical dynamics and the logic of provability. The conjecture remains open; its structure, at least, is now sharply drawn.
