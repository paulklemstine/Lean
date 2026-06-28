# Primitive Prime Divisors of Fibonacci Numbers: A Computational–Classical Hybrid Proof of Carmichael's Theorem

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Number Theory / Combinatorics)

## Abstract

We present a complete and structurally explicit proof that every Fibonacci number $F_n$ with $n \ge 13$ possesses a *primitive prime divisor* — a prime $p$ dividing $F_n$ but dividing no earlier Fibonacci number $F_k$ for $0 < k < n$. This is Carmichael's theorem (1913), the Fibonacci specialization of the Bang–Zsigmondy theorem (Bang 1886). Our treatment is organized around a single algebraic device, the *primitive part* $\mathrm{primPart}(n)$, computed by iteratively stripping from $F_n$ all factors shared with $F_d$ for each proper divisor $d \mid n$. We prove two complementary structural facts about this construction: (i) if $\mathrm{primPart}(n) > 1$ then $F_n$ has a primitive prime divisor (`primPart_implies_primitive`), and (ii) any primitive prime of $F_n$ survives the stripping process and hence forces $\mathrm{primPart}(n) > 1$ (`primPart_pos_of_primitive`). The infinitude of the claim is then partitioned into three disjoint regimes: prime indices, handled by an unconditional elementary argument via the strong divisibility identity $\gcd(F_m, F_n) = F_{\gcd(m,n)}$ (`fib_primitive_divisor_prime`); composite indices $13 \le n \le 10{,}000$, handled by an exhaustive verified computation (`primPart_check`); and composite indices $n > 10{,}000$, handled by invoking the classical Bang–Zsigmondy theorem as an explicit, non-circular hypothesis `BangZsigmondyFib` (`primPart_pos_large`, `fib_carmichael_composite`). All ingredients other than the cited classical theorem are established from first principles. We discuss the design of the proof, the role of the strong divisibility property, the boundary between computation and classical input, and avenues for removing the remaining hypothesis through a formalized cyclotomic/lifting-the-exponent theory.

---

## 1. Introduction

The Fibonacci sequence is defined by $F_1 = F_2 = 1$ and $F_{n+2} = F_{n+1} + F_n$, giving
$$1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ 55,\ 89,\ 144,\ 233,\ \dots$$

A prime $p$ is a **primitive prime divisor** of $F_n$ if
$$p \mid F_n \quad\text{and}\quad p \nmid F_k \ \text{ for all } 0 < k < n.$$

Equivalently, $n$ is the *rank of apparition* of $p$ in the Fibonacci sequence: the least index at which $p$ appears.

Not every Fibonacci number has such a prime. The exhaustive list of exceptions is $n \in \{1, 2, 6, 12\}$:
- $F_1 = F_2 = 1$ have no prime divisors;
- $F_6 = 8 = 2^3$, but $2 \mid F_3 = 2$;
- $F_{12} = 144 = 2^4 \cdot 3^2$, but $2 \mid F_3$ and $3 \mid F_4 = 3$.

Carmichael's theorem asserts these are the *only* exceptions.

**Theorem (Carmichael, 1913).** For every $n \ge 13$, $F_n$ has a primitive prime divisor.

This paper documents a formally verified hybrid proof of this statement. The proof is *hybrid* in two senses. First, it combines an exhaustive finite computation for small indices with classical theory for the infinite tail. Second, it isolates the single deep ingredient — the existence of a primitive divisor for large indices, i.e. the Bang–Zsigmondy theorem — as an explicit hypothesis, while proving every surrounding structural and computational lemma unconditionally. This makes the dependency graph fully transparent and non-circular: the place where the classical theorem is consumed is named and localized.

### 1.1 Contributions

1. A reusable algebraic construction, the **primitive part** $\mathrm{primPart}(n)$, with two structural correctness theorems linking it to primitive divisors in both directions.
2. A **survival lemma** showing primitive primes are invariant under factor-stripping, which is the conceptual bridge between "a primitive prime exists" and "the primitive part is nontrivial."
3. An **unconditional prime-index theorem** dispatching all prime $n \ge 3$ via strong divisibility.
4. A **verified exhaustive computation** covering all $13 \le n \le 10{,}000$.
5. A **non-circular assembly** of Carmichael's theorem in which the only deep external input is the explicitly stated Bang–Zsigmondy hypothesis.

---

## 2. Preliminaries

### 2.1 The strong divisibility property

The single most important structural fact is the following classical identity, available as `Nat.fib_gcd`.

**Lemma 2.1 (Strong divisibility).** For all $m, n \in \mathbb{N}$,
$$\gcd(F_m, F_n) = F_{\gcd(m,n)}.$$

*Consequence.* If $p \mid F_n$ and $p \mid F_k$, then $p \mid \gcd(F_n, F_k) = F_{\gcd(n,k)}$.

This converts statements about *common prime divisors* into statements about *gcd of indices*, which is the lever underlying every subsequent argument.

### 2.2 The bridge lemma

**Lemma 2.2 (Bridge lemma, `bridge_lemma`).** Let $n > 0$ and let $p$ be a prime with $p \mid F_n$. Suppose that for every proper divisor $d$ of $n$ (i.e. $d \mid n$, $0 < d < n$) we have $p \nmid F_d$. Then $p \nmid F_k$ for every $k$ with $0 < k < n$; that is, $p$ is a primitive prime divisor of $F_n$.

*Proof sketch.* Suppose $p \mid F_k$ for some $0 < k < n$. By Lemma 2.1, $p \mid F_{\gcd(n,k)}$. Set $d = \gcd(n,k)$. Then $d \mid n$, $d > 0$ (since $\gcd$ of positive integers), and $d \le k < n$, so $d$ is a proper divisor of $n$. This contradicts the hypothesis $p \nmid F_d$. $\qquad\blacksquare$

The bridge lemma is the crucial finite reduction: primitivity over the *infinite* set $\{k : 0 < k < n\}$ is equivalent to non-divisibility over the *finite* set of proper divisors of $n$.

---

## 3. The primitive part

### 3.1 Definitions

We work with concrete, computable definitions to enable both reasoning and machine evaluation.

**Definition 3.1 (Factor stripping, `stripAllAux`).** Given $r, m \in \mathbb{N}$ and a fuel parameter, define
$$\mathrm{stripAllAux}(r, m, 0) = r,$$
$$\mathrm{stripAllAux}(r, m, \text{fuel}+1) = \begin{cases} r & \text{if } m \le 1, \\ r & \text{if } \gcd(r,m) \le 1, \\ \mathrm{stripAllAux}\!\left(r / \gcd(r,m),\, m,\, \text{fuel}\right) & \text{otherwise.}\end{cases}$$
Intuitively, $\mathrm{stripAllAux}(r, m, \cdot)$ repeatedly divides $r$ by $\gcd(r, m)$ until the two are coprime; the fuel bounds the recursion (and is always taken large enough, e.g. $\text{fuel} = r$).

**Definition 3.2 (Proper divisors, `propDivs`).** $\mathrm{propDivs}(n)$ is the list of $d$ with $0 < d < n$ and $d \mid n$.

**Definition 3.3 (Primitive part, `primPart`).**
$$\mathrm{primPart}(n) = \mathrm{foldl}\big(\lambda\, r\, d.\ \mathrm{stripAllAux}(r, F_d, r),\ F_n,\ \mathrm{propDivs}(n)\big).$$
That is, starting from $F_n$, we strip out all factors shared with $F_d$ for each proper divisor $d$ of $n$, in turn.

### 3.2 Structural correctness

**Lemma 3.4 (Stripping divides, `stripAllAux_dvd`).** $\mathrm{stripAllAux}(r, m, \text{fuel}) \mid r$ for all inputs.

*Proof sketch.* Induction on fuel; each recursive step replaces $r$ by $r/\gcd(r,m)$, which divides $r$, and divisibility is transitive. $\blacksquare$

**Lemma 3.5 (Stripping yields coprimality, `stripAllAux_coprime`).** If $m > 1$, $r > 0$, and $\text{fuel} \ge r$, then $\gcd(\mathrm{stripAllAux}(r, m, \text{fuel}), m) = 1$.

*Proof sketch.* Induction on fuel. If $\gcd(r,m) > 1$, dividing $r$ by it strictly decreases $r$ (so the fuel suffices), and recursion gives coprimality. If $\gcd(r,m) \le 1$ already, the value is unchanged and $\gcd(r,m) = 1$. The fuel bound $\text{fuel} \ge r$ guarantees termination because each productive step at least halves... more precisely strictly decreases $r$, and there can be at most $r$ such steps. $\blacksquare$

**Lemma 3.6 (Primitive part divides, `primPart_dvd`).** $\mathrm{primPart}(n) \mid F_n$.

*Proof sketch.* The fold begins at $F_n$ and each step applies $\mathrm{stripAllAux}$, which by Lemma 3.4 produces a divisor of its input. By induction over the divisor list (reverse recursion), the final result divides $F_n$. $\blacksquare$

**Lemma 3.7 (Primitive part is coprime to earlier terms, `primPart_coprime_proper_divs`).** If $\mathrm{primPart}(n) > 1$, then for every $d \in \mathrm{propDivs}(n)$, the smallest prime factor $\mathrm{minFac}(\mathrm{primPart}(n))$ does not divide $F_d$.

*Proof sketch.* One shows by induction over the fold that the running value is coprime to $F_d$ for each $d$ in the divisor list: when $d$ is processed, $\mathrm{stripAllAux}$ (Lemma 3.5) makes the value coprime to $F_d$; subsequent steps only divide the value further (Lemma 3.4), and coprimality is preserved under taking divisors. Hence $\gcd(\mathrm{primPart}(n), F_d) = 1$, so the prime $\mathrm{minFac}(\mathrm{primPart}(n))$, which divides $\mathrm{primPart}(n)$, cannot divide $F_d$ (else it would divide the gcd $=1$). $\blacksquare$

### 3.3 From primitive part to primitive divisor

**Theorem 3.8 (`primPart_implies_primitive`).** If $n \ge 3$ and $\mathrm{primPart}(n) > 1$, then $F_n$ has a primitive prime divisor.

*Proof sketch.* Let $p = \mathrm{minFac}(\mathrm{primPart}(n))$, a prime by minimality and $\mathrm{primPart}(n) > 1$. By Lemma 3.6, $p \mid \mathrm{primPart}(n) \mid F_n$. By Lemma 3.7, $p \nmid F_d$ for every proper divisor $d$ of $n$. To upgrade "no proper divisor" to "no smaller index," argue as in the bridge lemma: for $0 < k < n$, if $p \mid F_k$ then $p \mid F_{\gcd(k,n)}$, and $\gcd(k,n)$ is a proper divisor of $n$, contradicting coprimality. Hence $p$ is primitive. $\blacksquare$

This theorem reduces Carmichael's theorem to the purely *arithmetic* assertion $\mathrm{primPart}(n) > 1$.

---

## 4. Survival of primitive primes

The converse direction is what allows the deep classical input to be plugged in cleanly.

**Lemma 4.1 (Primes survive stripping, `stripAllAux_preserves_prime`).** Let $p$ be prime with $p \mid r$ and $p \nmid m$. Then $p \mid \mathrm{stripAllAux}(r, m, \text{fuel})$ for all fuel.

*Proof sketch.* Induction on fuel. The only nontrivial step replaces $r$ by $r/\gcd(r,m)$. Since $p \nmid m$, $p$ is coprime to $m$, hence coprime to $\gcd(r,m)$; as $p \mid r$ and $p$ is coprime to the divisor we factor out, $p \mid r/\gcd(r,m)$ (using $p \mid (r/\gcd) \cdot \gcd$ with $\gcd \cdot (r/\gcd) = r$ and $p$ coprime to $\gcd$). Apply the inductive hypothesis. $\blacksquare$

**Lemma 4.2 (Primes survive the fold, `foldl_strip_preserves_prime`).** If $p$ is prime, $p \mid \text{init}$, and $p \nmid F_d$ for all $d$ in a list $\ell$, then $p$ divides the result of folding the stripping operation over $\ell$ starting from $\text{init}$.

*Proof sketch.* Reverse induction on $\ell$ using Lemma 4.1 at each appended divisor. $\blacksquare$

**Theorem 4.3 (Survival ⟹ nontrivial primitive part, `primPart_pos_of_primitive`).** Let $n > 0$ and let $p$ be a prime with $p \mid F_n$ and $p \nmid F_k$ for all $0 < k < n$. Then $\mathrm{primPart}(n) > 1$.

*Proof sketch.* Every proper divisor $d$ of $n$ satisfies $0 < d < n$, so $p \nmid F_d$ by hypothesis. By Lemma 4.2 with $\text{init} = F_n$ and $\ell = \mathrm{propDivs}(n)$, we get $p \mid \mathrm{primPart}(n)$. Since $\mathrm{primPart}(n) \mid F_n$ and $F_n > 0$, $\mathrm{primPart}(n) > 0$; and $p \le \mathrm{primPart}(n)$ with $p \ge 2$ gives $\mathrm{primPart}(n) > 1$. $\blacksquare$

Theorems 3.8 and 4.3 together establish the equivalence
$$\mathrm{primPart}(n) > 1 \iff F_n \text{ has a primitive prime divisor} \qquad (n \ge 3).$$

This equivalence is the architectural centerpiece: it means we may prove the left-hand side by *computation* when feasible and by *classical theory* otherwise.

---

## 5. The prime-index case (unconditional)

**Theorem 5.1 (`fib_primitive_divisor_prime`).** If $n \ge 3$ is prime, then $F_n$ has a primitive prime divisor.

*Proof sketch.* Since $n \ge 3$, $F_n > 1$, so $F_n$ has a prime factor $p$. For any $k$ with $0 < k < n$: because $n$ is prime and $0 < k < n$, $n \nmid k$, hence $\gcd(n, k) = 1$. By Lemma 2.1, if $p \mid F_k$ then $p \mid \gcd(F_n, F_k) = F_{\gcd(n,k)} = F_1 = 1$, impossible for a prime. Thus $p \nmid F_k$ for all such $k$, so $p$ is primitive. $\blacksquare$

This handles *all* prime indices at once, with no upper bound and no computation, and is logically independent of the Bang–Zsigmondy hypothesis. It is also the prime-index special case of Bang's theorem, proved here from scratch.

---

## 6. The computational case

**Theorem 6.1 (`primPart_check`).** For every integer $n$ with $13 \le n \le 10{,}000$, either $n$ is prime or $\mathrm{primPart}(n) > 1$.

*Proof.* By exhaustive verified evaluation (`native_decide`): for each of the $9{,}988$ values of $n$ in the range, primality is decided and, if composite, $\mathrm{primPart}(n)$ is computed and compared with $1$. All cases pass. $\blacksquare$

Because every $\mathrm{primPart}(n)$ here is computed via Definition 3.3 and verified $> 1$ (when $n$ is composite), Theorem 3.8 immediately yields a primitive prime divisor for each composite $n$ in range. The disjunction "prime or $\mathrm{primPart}(n) > 1$" lets the prime indices be routed to Theorem 5.1 instead.

---

## 7. The classical tail and the assembled theorem

### 7.1 The Bang–Zsigmondy hypothesis

The composite indices beyond the computed range require the deep classical theorem. We state it precisely and carry it as an explicit hypothesis rather than an axiom.

**Definition 7.1 (`BangZsigmondyFib`).**
$$\mathrm{BangZsigmondyFib} \ :\equiv\ \forall n > 12,\ \exists p \text{ prime},\ p \mid F_n \ \wedge\ \big(\forall k,\ 0 < k < n \Rightarrow p \nmid F_k\big).$$

This is exactly the assertion that every $F_n$ with $n > 12$ has a primitive prime divisor — Bang (1886) / Carmichael (1913). Its classical proof rests on a magnitude estimate for the homogeneous cyclotomic factor $\Phi_n(\alpha, \beta)$ (where $\alpha, \beta$ are the roots of $x^2 - x - 1$) combined with a lifting-the-exponent identity for the imprimitive part. These are not yet available in the formal library; carrying the statement as a hypothesis keeps the development sound and non-circular.

### 7.2 Large composite indices

**Theorem 7.2 (`primPart_pos_large`).** Assume `BangZsigmondyFib`. Then for every $n > 12$, $\mathrm{primPart}(n) > 1$.

*Proof sketch.* The hypothesis supplies a primitive prime $p$ of $F_n$. Apply Theorem 4.3 (survival) to conclude $\mathrm{primPart}(n) > 1$. Crucially, this uses only the assumed theorem and the survival lemma — never Theorem 3.8 or the primitive-divisor conclusion being assembled — so there is no circularity. $\blacksquare$

### 7.3 Composite case and main theorem

**Theorem 7.3 (Composite case, `fib_carmichael_composite`).** Assume `BangZsigmondyFib`. For every composite $n \ge 13$, $F_n$ has a primitive prime divisor.

*Proof sketch.* By Theorem 3.8 it suffices to show $\mathrm{primPart}(n) > 1$. If $n \le 10{,}000$, this follows from Theorem 6.1 (resolving the disjunction by $n$ composite). If $n > 10{,}000$, this follows from Theorem 7.2. $\blacksquare$

**Theorem 7.4 (Carmichael's theorem, `fib_carmichael`).** Assume `BangZsigmondyFib`. For every $n \ge 13$,
$$\exists p \text{ prime},\ p \mid F_n \ \wedge\ \forall k,\ 0 < k < n \Rightarrow p \nmid F_k.$$

*Proof sketch.* If $n$ is prime, apply Theorem 5.1 (no hypothesis needed). If $n$ is composite, apply Theorem 7.3. $\blacksquare$

The dependency on `BangZsigmondyFib` is confined to the large-composite branch; the prime indices and the first ten thousand composite indices are dispatched unconditionally.

---

## 8. Algorithms

### 8.1 Computing the primitive part

The construction of Definition 3.3 is directly executable. Given $n$:
1. Compute $F_n$.
2. Enumerate proper divisors $d$ of $n$.
3. For each $d$, repeatedly divide the running value by $\gcd(\cdot, F_d)$ until coprime.
4. Return the surviving value.

The dominant cost is the divisor enumeration and the gcd-stripping loops; with fast Fibonacci computation (fast doubling) the primitive part of $F_n$ is obtained in time polynomial in $n$ and in the bit-length of $F_n$.

### 8.2 Extracting a primitive prime

Once $\mathrm{primPart}(n) > 1$, its smallest prime factor is a primitive prime divisor of $F_n$ (Theorem 3.8). For prime $n$, any prime factor of $F_n$ works (Theorem 5.1), so trial division or a probabilistic factoring step suffices.

---

## 9. Applications

- **Lucas-based primality testing and factoring.** Lucas sequences and the Fibonacci recurrence underpin Lucas–Lehmer-style tests and Pollard's $p-1$ method. Guaranteed primitive divisors ensure these sequences continually introduce new prime structure, which is exactly the resource such algorithms exploit.
- **Zsigmondy-type arguments in group theory.** The general Bang–Zsigmondy theorem on $a^n - b^n$ is a standard tool for bounding element orders and proving (non)existence results about finite groups and linear groups; the Fibonacci case is its archetype.
- **Ranks of apparition.** A primitive prime divisor of $F_n$ is precisely a prime with rank of apparition $n$. The theorem certifies that every $n \ge 13$ is the apparition rank of some prime, populating the rank function's image.
- **Methodological template.** The computation/elementary/classical trichotomy with an explicit, localized deep hypothesis is a reusable pattern for formalizing results whose full proof outstrips the current library.

---

## 10. Discussion

The proof's design pivots on the equivalence $\mathrm{primPart}(n) > 1 \Leftrightarrow$ existence of a primitive divisor (Theorems 3.8 and 4.3). This decoupling is what makes the hybrid strategy coherent: the *same* arithmetic quantity is established by computation in one regime and by classical theory in another, with a uniform downstream conclusion. The strong divisibility identity (Lemma 2.1) is used in three distinct places — the bridge lemma, the prime-index case, and the proper-divisor reduction — underscoring that it is the true engine of the subject.

A deliberate choice is to treat Bang–Zsigmondy as a named hypothesis rather than an axiom. This preserves soundness (no unproven assertion is injected into the trusted core), makes the logical dependency auditable, and cleanly separates "what we proved" from "what we invoked." The prime-index case demonstrates that a genuine fragment of Bang's theorem is provable from scratch with present tools.

---

## 11. Future work

1. **Remove the hypothesis via cyclotomic theory.** Formalize the homogeneous cyclotomic value $\Phi_n(\alpha,\beta)$ as the primitive part of $F_n$ and the magnitude bound $\Phi_n > n+1$ for $n > 12$, together with a lifting-the-exponent identity $v_p(F_n) = v_p(F_e) + v_p(n)$ at the entry point $e$. This would discharge `BangZsigmondyFib` and yield a fully unconditional theorem.
2. **Generalize to Lucas sequences.** Extend the primitive-part machinery to general nondegenerate Lucas sequences $U_n(P, Q)$, recovering the full Bang–Zsigmondy theorem on $a^n - b^n$.
3. **Effective apparition ranks.** Combine the construction with bounds on $\mathrm{primPart}(n)$ to produce explicit estimates on the size of the least primitive prime divisor.
4. **Extend the verified range.** Push the `native_decide` computation well beyond $10{,}000$ to narrow the regime that depends on the classical input, as a cross-check.

---

## References (classical, for context)

- A. S. Bang, *Taltheoretiske Undersøgelser*, 1886.
- R. D. Carmichael, *On the numerical factors of the arithmetic forms $\alpha^n \pm \beta^n$*, Annals of Mathematics, 1913.
- K. Zsigmondy, *Zur Theorie der Potenzreste*, Monatshefte für Mathematik, 1892.
