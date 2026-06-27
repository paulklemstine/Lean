# The Combinatorial Core of Bounded Prime Gaps: Admissibility, Pigeonhole Finiteness, and the Reduction to $\liminf(p_{n+1}-p_n)\le 246$

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty / Analytic Number Theory

## Abstract

The Zhang–Maynard–Tao theorem asserts that $\liminf_{n\to\infty}(p_{n+1}-p_n)$ is finite, with the current elementary bound from the Maynard–Tao method being $246$. The proof has two conceptually distinct components: a deep analytic *input* (the existence of bounded prime pairs arbitrarily far out, obtained from sieve theory and the distribution of primes in arithmetic progressions) and an elementary *combinatorial scaffold* surrounding it. This paper formalizes the scaffold completely and rigorously. We make two contributions. First, on the *input* side, we develop the theory of **admissible tuples**: we define admissibility via missing residue classes, prove a pigeonhole lemma showing every prime larger than the tuple size automatically has a missing residue, and deduce the structural **finiteness theorem** that admissibility is equivalent to a finite check over primes $p \le |H|$ — rendering it decidable. We verify the canonical witnesses: the twin tuple $\{0,2\}$ is admissible while the consecutive tuple $\{0,1\}$ is not. Second, on the *output* side, we prove the elementary **reduction theorem**: the existence of bounded prime pairs arbitrarily far out implies $\liminf(p_{n+1}-p_n)\le B$, via a clean counting lemma stating that the prime immediately following $p$ cannot exceed any prime $q>p$. Specializing $B=246$ yields the headline statement. All results are stated with full proof sketches; the entire scaffold is elementary, relying only on the pigeonhole principle and prime-counting bookkeeping.

## 1. Introduction

### 1.1 Background

A *prime gap* is the difference $p_{n+1}-p_n$ between consecutive primes, where $p_n$ denotes the $n$-th prime in increasing order ($p_0 = 2$). The prime number theorem gives the average gap near $x$ as $\sim \ln x$, which tends to infinity; nevertheless, the *small* gaps are of central interest. The Twin Prime Conjecture predicts $p_{n+1}-p_n = 2$ infinitely often, i.e. $\liminf_n (p_{n+1}-p_n) = 2$.

The breakthrough of Zhang (2013) established for the first time that this $\liminf$ is *finite*, with bound $7\times 10^7$. The Polymath8 project and, decisively, the independent method of Maynard and of Tao reduced the bound dramatically; the cleanest elementary value emerging from the Maynard–Tao construction is $246$.

### 1.2 The two-layer architecture

We separate the result into:

- **Analytic input.** For every $N$ there exist primes $p < q$ with $N \le p$ and $q \le p + B$. This is the hard sieve-theoretic statement; it is the *only* non-elementary ingredient.
- **Combinatorial scaffold.** (i) The local solvability condition (admissibility) governing which prime patterns can occur, and (ii) the reduction turning bounded *pairs* into bounded *consecutive* gaps.

This paper formalizes the scaffold with no gaps in reasoning. The deep input is quarantined behind a precise hypothesis, so that any future proof of that hypothesis (with any value of $B$) immediately yields the corresponding $\liminf$ bound.

### 1.3 Notation

Throughout, $H \subseteq \mathbb{Z}$ is a finite set (a *tuple* of offsets), $|H|$ its cardinality, and $\mathbb{Z}/p\mathbb{Z}$ the residues modulo a prime $p$. We write $h \bmod p$ for the image of $h$ in $\mathbb{Z}/p\mathbb{Z}$. We write $p_n = $ the $n$-th prime (zero-indexed), $\pi(x) = $ the number of primes $\le x$ (the prime-counting function), and $\liminf$ for the limit inferior of a sequence of naturals.

## 2. Admissible tuples: the local obstruction

### 2.1 Definition

The prime $k$-tuple heuristic asks when a finite offset set $H$ admits infinitely many translates $n + H = \{n + h : h \in H\}$ consisting entirely of primes. There is a clean local obstruction: if some prime $p$ "covers" $H$, every translate contains a multiple of $p$.

> **Definition 1 (Admissibility; Lean: `IsAdmissible`).**
> A finite set $H \subseteq \mathbb{Z}$ is *admissible* if
> $$\forall\, p \text{ prime}, \ \exists\, r \in \mathbb{Z}/p\mathbb{Z}, \ \forall\, h \in H,\ (h \bmod p) \ne r.$$
> Equivalently: for every prime $p$, the image of $H$ in $\mathbb{Z}/p\mathbb{Z}$ omits at least one residue class.

The omitted class is the obstruction's negation: if class $r$ is empty, one may choose the translation parameter so that no element of $n+H$ falls in the "$\equiv 0$" class modulo $p$, leaving the door open for all entries to be prime. If, conversely, $H$ covers all $p$ classes, then for *every* $n$ some $n+h$ is divisible by $p$, so $n+H$ cannot be all-prime beyond finitely many exceptions.

### 2.2 The pigeonhole lemma

> **Lemma 2 (Pigeonhole; Lean: `exists_missing_residue`).**
> Let $p$ be prime and $H \subseteq \mathbb{Z}$ finite with $|H| < p$. Then there exists $r \in \mathbb{Z}/p\mathbb{Z}$ with $(h \bmod p) \ne r$ for all $h \in H$.

*Proof sketch.* The reduction map $H \to \mathbb{Z}/p\mathbb{Z}$, $h \mapsto h \bmod p$, has image of size at most $|H| < p = |\mathbb{Z}/p\mathbb{Z}|$. A map from a set of size $< p$ cannot be surjective onto a $p$-element set; contrapositively, if every residue were hit, then $|\mathbb{Z}/p\mathbb{Z}| \le |H|$ by the surjection's cardinality bound, contradicting $|H| < p$. Hence some residue $r$ is omitted. $\square$

### 2.3 Finiteness and decidability

The definition quantifies over the infinitely many primes. Lemma 2 collapses this to a finite range.

> **Theorem 3 (Finiteness of the admissibility test; Lean: `isAdmissible_iff_small_primes`).**
> For any finite $H \subseteq \mathbb{Z}$,
> $$\text{IsAdmissible}(H) \iff \Big(\forall\, p \text{ prime},\ p \le |H| \ \Rightarrow\ \exists\, r \in \mathbb{Z}/p\mathbb{Z},\ \forall h \in H,\ (h \bmod p)\ne r\Big).$$

*Proof sketch.* ($\Rightarrow$) Immediate: admissibility provides the missing residue for *every* prime, in particular those $\le |H|$. ($\Leftarrow$) Let $p$ be an arbitrary prime. If $p \le |H|$, the hypothesis supplies the missing residue directly. If $p > |H|$, then $|H| < p$ and Lemma 2 supplies it. Either way the missing-residue condition holds for all primes, i.e. $H$ is admissible. $\square$

**Remark (Decidability).** Theorem 3 reduces admissibility to checking, for each of the finitely many primes $p \le |H|$, whether the finite set $\{h \bmod p : h \in H\} \subseteq \mathbb{Z}/p\mathbb{Z}$ is a proper subset. Each such test is a finite computation over $\mathbb{Z}/p\mathbb{Z}$, so admissibility is decidable. For a $50$-element tuple, one inspects only the $15$ primes $\le 50$.

### 2.4 Canonical witnesses

> **Proposition 4 (Twin tuple is admissible; Lean: `twinTuple_admissible`).** $\text{IsAdmissible}(\{0,2\})$.

*Proof sketch.* By Theorem 3 it suffices to check primes $p \le 2$, i.e. $p = 2$. Modulo $2$ the offsets reduce to $\{0,0\} = \{0\}$, so the class $1$ is omitted. (For completeness, modulo any $p \ge 3$ the two offsets occupy at most $2 < p$ classes, again omitting one — consistent with admissibility.) $\square$

> **Proposition 5 (Consecutive tuple is not admissible; Lean: `consecutive_not_admissible`).** $\neg\,\text{IsAdmissible}(\{0,1\})$.

*Proof sketch.* Take $p = 2$. The offsets reduce to $\{0,1\}$ modulo $2$, covering *both* residue classes. Hence no class is omitted modulo $2$, so the admissibility condition fails at $p=2$. This is the formal statement of "$n$ and $n+1$ cannot both be large primes." $\square$

These two propositions delineate the boundary: the smallest admissible nontrivial diameter is $2$ (twins), and the naive pattern of consecutive integers is locally forbidden.

## 3. The reduction: bounded pairs to bounded consecutive gaps

### 3.1 The gap sequence

> **Definition 6 (Prime gap; Lean: `primeGap`).**
> With $p_n$ the $n$-th prime, set
> $$\text{primeGap}(n) = p_{n+1} - p_n.$$

### 3.2 The counting lemma

The crux is that the successor of a prime $p$ in the prime enumeration cannot overshoot any prime exceeding $p$.

> **Lemma 7 (Next prime does not skip; Lean: `next_prime_le_of_prime_lt`).**
> Let $p, q$ be primes with $p < q$. Then
> $$p_{\,\pi(p)+1} \le q,$$
> where $\pi(p)$ is the number of primes $\le p$; equivalently, the prime immediately following $p$ is at most $q$.

*Proof sketch.* Let $c = \pi(p)$ be the count of primes $\le p$; since $p$ is itself prime, $p = p_{c-1}$ in zero-indexed enumeration is the largest prime $\le p$, and the immediately following prime is $p_{c}$ — written in the Lean development as $\text{nth Prime}(\text{count Prime } p + 1)$ using the off-by-one convention of `Nat.count`/`Nat.nth`. Because $p < q$ and $q$ is prime, the number of primes $\le q$ strictly exceeds the number of primes $\le p$: $\pi(q) > \pi(p)$. The fundamental relation between `nth` and `count` (the order isomorphism between primes and their indices, `Nat.lt_nth_iff_count_lt` / `Nat.nth_lt_of_lt_count`) then gives that the prime at index $\pi(p)+1$ is $\le q$, since $q$ is a prime whose count index is at least $\pi(p)+1$. $\square$

### 3.3 Infinitely many small consecutive gaps

> **Theorem 8 (Bounded pairs force bounded consecutive gaps; Lean: `exists_index_gap_le`).**
> Fix $B \in \mathbb{N}$ and suppose
> $$\forall N \in \mathbb{N},\ \exists\, p, q \text{ prime with } N \le p,\ p < q \le p + B. \tag{$\ast$}$$
> Then for every $M \in \mathbb{N}$ there exists an index $n \ge M$ with $\text{primeGap}(n) \le B$.

*Proof sketch.* Given $M$, apply $(\ast)$ with $N = p_M + 1$ to obtain primes $p < q \le p + B$ with $p \ge p_M + 1 > p_M$. Set $n = \pi(p)$ (the index with $p = p_n$). 

*Index lower bound $n \ge M$:* since $p > p_M$ and the prime enumeration is strictly monotone, $\pi(p) \ge M$; concretely, if $\pi(p) < M$ then $p = p_{\pi(p)} \le p_M$ by monotonicity, contradicting $p > p_M$.

*Gap upper bound:* by Lemma 7, $p_{n+1} = p_{\pi(p)+1} \le q$. Therefore
$$\text{primeGap}(n) = p_{n+1} - p_n = p_{n+1} - p \le q - p \le B.$$
Thus $n \ge M$ and $\text{primeGap}(n) \le B$, as required. $\square$

### 3.4 The $\liminf$ statement

Theorem 8 says the set $\{n : \text{primeGap}(n) \le B\}$ is unbounded ("frequently" along the filter at infinity). Translating to limit inferior:

> **Theorem 9 (Main reduction; Lean: `liminf_primeGap_le`).**
> If hypothesis $(\ast)$ holds for a bound $B$ — i.e. there are infinitely many prime pairs $p<q\le p+B$ — then
> $$\liminf_{n\to\infty}\big(p_{n+1}-p_n\big) = \liminf_{n\to\infty}\text{primeGap}(n) \le B.$$

*Proof sketch.* By Theorem 8, for every $M$ there is $n \ge M$ with $\text{primeGap}(n) \le B$; i.e. the property "$\text{primeGap}(n)\le B$" holds frequently along the at-infinity filter on $\mathbb{N}$. The standard characterization of $\liminf$ — that if a property bounding the sequence value by $B$ holds frequently then the $\liminf$ is $\le B$ (`Filter.liminf_le_of_frequently_le`, with the boundedness side-condition automatic in $\mathbb{N}$) — yields $\liminf \text{primeGap} \le B$. $\square$

### 3.5 The headline corollary

The Maynard–Tao sieve construction supplies hypothesis $(\ast)$ with $B = 246$: there are infinitely many pairs of primes within $246$ of each other. Feeding this into Theorem 9:

> **Corollary 10 (Maynard–Tao bound; Lean: `liminf_primeGap_le_246`).**
> $$\liminf_{n\to\infty}\big(p_{n+1}-p_n\big) \le 246.$$

In words: there are infinitely many pairs of *consecutive* primes differing by at most $246$.

## 4. The analytic engine (contextual overview)

The single hypothesis $(\ast)$ is where all the depth resides. We sketch its provenance for completeness; this section is expository and is *not* part of the formalized scaffold.

### 4.1 The GPY/Maynard variational problem

To produce bounded prime pairs one chooses an admissible tuple $H = \{h_1,\dots,h_k\}$ and a nonnegative weight $w(n) \ge 0$ supported on integers $n$ in a long interval, designed so that $w(n)$ is large exactly when $n + H$ contains many primes. The Goldston–Pintz–Yıldırım (GPY) weights take the form
$$w(n) = \Big(\sum_{\substack{d \mid P_H(n) \\ d \le R}} \lambda_d\Big)^2,\qquad P_H(n) = \prod_{i=1}^k (n + h_i),$$
where the $\lambda_d$ are tunable real coefficients supported on *squarefree* $d$ (the Selberg sieve structure; in the Lean future-work layer this squarefree support is captured by `selberg_weight_eq_squarefree_indicator`). One compares two weighted sums over $n$ in $[x, 2x]$:
$$S_1 = \sum_n w(n), \qquad S_2 = \sum_n \Big(\sum_{i=1}^k \mathbf{1}[n+h_i \text{ prime}]\Big) w(n).$$
If $S_2 > \rho\, S_1$ for some threshold $\rho \ge 1$, then some $n$ has more than $\rho$ primes among $n + H$, guaranteeing (for $\rho \ge 1$) at least two primes in a window of diameter $\text{diam}(H)$.

### 4.2 Maynard's multidimensional improvement

Maynard replaced the one-dimensional divisor sum by a multidimensional weight
$$w(n) = \Big(\sum_{\substack{d_1,\dots,d_k}} \lambda_{d_1,\dots,d_k}\Big)^2$$
indexed by $k$-tuples of divisors, turning the optimization of the ratio $S_2/S_1$ into a finite-dimensional Rayleigh quotient
$$\frac{S_2}{S_1} \approx \frac{\sum_i \int F^2}{\int F^2} \cdot (\text{level factor})$$
maximized over symmetric polynomials $F$ on the simplex $\{t_i \ge 0,\ \sum t_i \le 1\}$. The key threshold is whether this optimum exceeds a critical constant (morally $4$ in the GPY normalization, related to admitting $\ge 2$ primes). With enough test functions and a level of distribution from the Bombieri–Vinogradov theorem, the optimum is pushed past threshold for $k = 50$, and an admissible $50$-tuple of diameter $246$ then yields $(\ast)$ with $B = 246$.

### 4.3 Level of distribution

The level-of-distribution input — that primes are equidistributed in arithmetic progressions to modulus $x^{\theta}$ for $\theta$ up to (essentially) $1/2$, the Bombieri–Vinogradov theorem — controls the error terms in evaluating $S_1, S_2$. Zhang's innovation was a slight extension beyond $\theta = 1/2$ for smooth moduli; Maynard–Tao showed the unconditional $\theta = 1/2$ suffices with the multidimensional weights. This is the precise statement that, once formalized, would discharge $(\ast)$ unconditionally and turn Corollary 10 into a fully unconditional theorem.

## 5. Discussion

### 5.1 What is and is not formalized

The combinatorial scaffold — Definitions 1, 6, Lemmas 2, 7, Theorems 3, 8, 9, Propositions 4, 5 — is formalized completely and elementarily, with no analytic prerequisites. Corollary 10 is conditional on $(\ast)$ for $B=246$, which is exactly the Maynard–Tao analytic input summarized in §4 and isolated as a hypothesis. This is a faithful reflection of the mathematics: the elementary architecture is airtight, and the depth is precisely localized.

### 5.2 The value of clean interfaces

Quarantining the analytic difficulty behind hypothesis $(\ast)$ makes the result *modular*. Any improvement to the close-pair bound $B$ propagates instantly through Theorems 8–9 to the consecutive-gap statement. In particular, a future proof of the close-pair statement with $B = 12$ (the conjectural reach of current sieve methods under the Elliott–Halberstam conjecture) or $B = 2$ (the full Twin Prime Conjecture) requires *no* changes to the scaffold to yield the corresponding $\liminf$ bound.

### 5.3 Admissibility as a search primitive

Theorem 3 is not merely structural; it is the computational enabler. Finding the smallest-diameter admissible $k$-tuple — the optimization that fixes the constant $246$ — requires testing astronomically many candidate tuples for admissibility, feasible only because each test reduces to the finitely many primes $\le k$. The decidability remark of §2.3 is therefore the bridge between the abstract theory and the explicit constant.

## 6. Future work

1. **Decidability instance.** Promote Theorem 3 to an executable decision procedure for `IsAdmissible H` over explicit `H`, evaluating the missing-residue test over each `ZMod p` for $p \le |H|$.
2. **Minimal admissible diameters.** Define and compute $\text{admissibleDiameter}(k)$, the least diameter of an admissible $k$-tuple; verify monotonicity and the Maynard–Tao value $\text{admissibleDiameter}(50) = 246$ by certified search.
3. **Formalizing the analytic input.** State Bombieri–Vinogradov and the level-of-distribution machinery, and prove it implies $(\ast)$ for some $B \le 246$, discharging the hypothesis of Theorem 9 to obtain an unconditional result.
4. **The variational optimum.** Formalize the GPY/Maynard Rayleigh-quotient optimization with squarefree-supported weights and prove the optimum exceeds the critical threshold for sufficiently many test polynomials.

## 7. Conclusion

We have given a complete, elementary formalization of the combinatorial scaffold underlying the bounded-gaps theorem. Admissibility is defined via missing residues (Definition 1), shown to be a finite, decidable check by a pigeonhole argument (Lemma 2, Theorem 3), and illustrated on the twin and consecutive tuples (Propositions 4, 5). The reduction from bounded pairs to bounded consecutive gaps is proved through a single counting lemma (Lemma 7), yielding infinitely many small consecutive gaps (Theorem 8) and hence the limit-inferior bound (Theorem 9), specializing to the celebrated $\liminf(p_{n+1}-p_n) \le 246$ (Corollary 10). The lone deep ingredient — the existence of bounded prime pairs — is cleanly isolated as a hypothesis, leaving an architecture that is at once rigorous, modular, and ready to absorb future analytic advances.
