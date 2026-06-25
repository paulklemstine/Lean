# Primitive Prime Divisors of Fibonacci Numbers: A Verified Account of the Prime-Index Case and a Computational Frontier for the Composite Case

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Computation / Number Theory

## Abstract

A primitive prime divisor of the $n^{\text{th}}$ Fibonacci number $F(n)$ is a
prime $p$ dividing $F(n)$ but dividing no earlier Fibonacci number $F(k)$ with
$0 < k < n$. Carmichael's theorem (1913) asserts that $F(n)$ has a primitive
prime divisor for every $n$ outside a small exceptional set. We give a complete,
elementary, and fully machine-checked proof of the **prime-index case**: if $n$
is prime and $n \ge 13$ (indeed $n \ge 3$ suffices), then $F(n)$ has a primitive
prime divisor. The proof rests on a single structural identity, the strong
divisibility property $\gcd(F(m), F(n)) = F(\gcd(m,n))$, together with the
observation that the primality of the index collapses any nontrivial common index
to $1$. We then develop the composite-index case via an explicit *primitive-part*
construction — an algorithm that strips from $F(n)$ all prime factors shared with
$F(d)$ for proper divisors $d \mid n$ — and prove that whenever the primitive part
exceeds $1$, its least prime factor is a primitive prime divisor. A verified
finite computation establishes the survival inequality (primitive part $> 1$) for
every composite index in the range $13 \le n \le 10000$, yielding Carmichael's
conclusion throughout that range. The unbounded tail $n > 10000$, which requires
replacing computation with an exponential growth estimate, is identified as the
remaining open problem. We situate these results within the broader theory of
ranks of apparition for strong divisibility sequences and outline several
concrete generalizations.

## 1. Introduction

The Fibonacci sequence $F : \mathbb{N} \to \mathbb{N}$ is defined by $F(0) = 0$,
$F(1) = 1$, and $F(n+2) = F(n+1) + F(n)$. Its arithmetic is unusually rigid: the
sequence is a *strong divisibility sequence*, meaning

$$\gcd\bigl(F(m), F(n)\bigr) = F\bigl(\gcd(m,n)\bigr) \qquad (m, n \ge 0). \tag{$\star$}$$

This single identity organizes essentially everything about Fibonacci
divisibility, including the location of first appearances of prime factors.

**Definition 1 (Primitive prime divisor).** A prime $p$ is a *primitive prime
divisor* of $F(n)$ if $p \mid F(n)$ and, for every $k$ with $0 < k < n$, we have
$p \nmid F(k)$.

Carmichael's theorem states that $F(n)$ has a primitive prime divisor for all $n
\notin \{1, 2, 6, 12\}$ (with the convention $F(1)=F(2)=1$). The exceptional
indices are genuine: $F(1) = F(2) = 1$ have no prime factors at all, $F(6) = 8 =
2^3$ repeats the prime $2$ that already divides $F(3) = 2$, and $F(12) = 144 = 2^4
\cdot 3^2$ repeats primes that appear earlier.

This paper has two complementary contributions.

1. **A complete, elementary, machine-checked proof of the prime-index case**
   (Section 3, Theorem 1). The proof is short and conceptually transparent: it
   uses only $(\star)$ and the fact that a prime index has no nontrivial proper
   divisor.

2. **An algorithmic and computational treatment of the composite-index case**
   (Sections 4–5). We construct the *primitive part* of $F(n)$ as an explicit
   procedure, prove its correctness (it divides $F(n)$ and, when it exceeds $1$,
   certifies a primitive prime divisor), and verify by exact computation that the
   primitive part exceeds $1$ for every composite $n$ in $[13, 10000]$.

We are scrupulous about status. Theorem 1 (prime case) is unconditionally proved.
The composite case is established for $13 \le n \le 10000$; the infinite tail is
an explicitly flagged open problem (Section 7).

## 2. Preliminaries

We work over the natural numbers $\mathbb{N}$. We use three standard facts.

- **(P1) Existence of a prime divisor.** Every natural number $m \ne 1$ has a
  prime divisor. (Formally: `Nat.exists_prime_and_dvd`.)
- **(P2) The strong divisibility identity $(\star)$.** For all $m, n$,
  $\gcd(F(m), F(n)) = F(\gcd(m,n))$. (Formally: `Nat.fib_gcd`.) An immediate
  corollary, used repeatedly, is the **divisibility form**: if $p \mid F(m)$ and
  $p \mid F(n)$, then $p \mid F(\gcd(m,n))$, since $p \mid \gcd(F(m),F(n)) =
  F(\gcd(m,n))$.
- **(P3) Coprimality below a prime.** If $0 < k < n$ then $n \nmid k$; and if $n$
  is prime, $\gcd(n,k) \in \{1, n\}$, so $\gcd(n,k) = 1$. (Formally:
  `Nat.not_dvd_of_pos_of_lt` together with `Nat.Prime.coprime_iff_not_dvd`.)

We also record growth facts: $F(n) > 1$ for $n \ge 3$ (so (P1) applies to $F(n)$),
and $F(n) \ge \varphi^{n-2}$ for $n \ge 1$, where $\varphi = (1+\sqrt5)/2$.

## 3. The Prime-Index Case

**Theorem 1 (Carmichael, prime case).** *Let $n$ be prime with $n \ge 13$. Then
$F(n)$ has a primitive prime divisor: there exists a prime $p$ with $p \mid F(n)$
and $p \nmid F(k)$ for every $k$ with $0 < k < n$.*

(In the formalization this is `fib_primitive_divisor_prime`. The hypothesis $n \ge
13$ is convenient for downstream uniformity but is stronger than necessary; the
proof works verbatim for any prime $n \ge 3$.)

**Proof sketch.** Since $n \ge 13 \ge 3$, we have $F(n) > 1$, so by (P1) there is
a prime $p$ with $p \mid F(n)$. We claim *every* such $p$ is primitive; no special
choice is needed.

Fix $k$ with $0 < k < n$ and suppose for contradiction that $p \mid F(k)$. Then
$p \mid F(n)$ and $p \mid F(k)$, so by the divisibility form of (P2),

$$p \mid F\bigl(\gcd(n,k)\bigr).$$

By (P3), since $n$ is prime and $0 < k < n$, we have $\gcd(n,k) = 1$. Hence $p
\mid F(1) = 1$, contradicting that $p$ is prime. Therefore $p \nmid F(k)$ for all
$0 < k < n$, i.e. $p$ is a primitive prime divisor of $F(n)$. $\qquad\blacksquare$

**Remark.** The role of primality is razor-sharp: it is used *only* to force
$\gcd(n,k) = 1$. Replacing "prime" by "$1$ and $n$ are the only divisors of $n$"
changes nothing, which is exactly why the argument transfers to any strong
divisibility sequence with $F(1)$ a unit.

A reusable abstraction of the contradiction step is the following bridge from
*proper divisors* to *all smaller indices*.

**Lemma 2 (Divisor-to-all bridge).** *Let $n > 0$ and let $p$ be a prime with $p
\mid F(n)$. Suppose $p \nmid F(d)$ for every divisor $d$ of $n$ with $0 < d < n$.
Then $p \nmid F(k)$ for every $k$ with $0 < k < n$.*

(Formally: `bridge_lemma`.)

**Proof sketch.** Suppose $0 < k < n$ and $p \mid F(k)$. With $p \mid F(n)$, the
divisibility form of (P2) gives $p \mid F(\gcd(n,k))$. Set $d = \gcd(n,k)$. Then
$d \mid n$, $d > 0$ (as $n, k > 0$), and $d \le \gcd(n,k) \le k < n$, so $d$ is a
proper divisor of $n$ with $p \mid F(d)$ — contradicting the hypothesis.
$\qquad\blacksquare$

Lemma 2 is what makes the composite case tractable: it suffices to defeat $p$ on
the *finitely many proper divisors* of $n$, not on all of $0 < k < n$. For a prime
$n$, the only proper divisor is $1$, and $F(1) = 1$ is divisible by no prime, so
Lemma 2 instantly recovers Theorem 1.

## 4. The Composite-Index Case: the Primitive-Part Construction

To handle composite $n$ we isolate the genuinely new portion of $F(n)$.

**Definition 2 (Proper divisors).** For $n \in \mathbb{N}$, let
$$\mathrm{propDivs}(n) = \{\, d : 0 < d < n \text{ and } d \mid n \,\},$$
realized as a finite list. (Formally: `propDivs`.)

**Definition 3 (Factor-stripping routine).** Given $r, m$ and a fuel budget,
`stripAllAux` repeatedly replaces $r$ by $r / \gcd(r, m)$ until $\gcd(r,m) = 1$ (or
the fuel runs out, or $m \le 1$). Each step removes one layer of the primes common
to $r$ and $m$. (Formally: `stripAllAux`.)

**Definition 4 (Primitive part).** The *primitive part* of $F(n)$ is
$$\mathrm{primPart}(n) = \Bigl(\textstyle\prod\text{-fold strip}\Bigr): \quad
\text{start from } F(n), \text{ and for each } d \in \mathrm{propDivs}(n) \text{
strip all factors shared with } F(d).$$
Concretely, `primPart n` folds `stripAllAux` over `propDivs n`, beginning at
$F(n)$. (Formally: `primPart`.)

The construction is engineered so that the surviving number is coprime to every
$F(d)$ with $d$ a proper divisor of $n$, while still dividing $F(n)$.

**Lemma (Stripping divides).** `stripAllAux r m fuel ∣ r`. (Formally:
`stripAllAux_dvd`.) Each step divides $r$ by a divisor of $r$, so the result
divides $r$ throughout.

**Lemma (Stripping achieves coprimality).** With sufficient fuel ($\text{fuel}
\ge r$, $m > 1$, $r > 0$), $\gcd(\mathrm{stripAllAux}(r,m,\text{fuel}), m) = 1$.
(Formally: `stripAllAux_coprime`.) Each step with $\gcd > 1$ strictly decreases
$r$, so $r$ steps suffice to reach $\gcd = 1$.

**Lemma 3 (Primitive part divides).** $\mathrm{primPart}(n) \mid F(n)$.
(Formally: `primPart_dvd`.) Immediate by induction over the fold using the
stripping-divides lemma.

**Lemma (Coprime to proper divisors).** If $\mathrm{primPart}(n) > 1$, then its
least prime factor divides no $F(d)$ for $d \in \mathrm{propDivs}(n)$. (Formally:
`primPart_coprime_proper_divs`.) The stripping-coprimality lemma guarantees the
fold output is coprime to each $F(d)$, hence so is any divisor of it.

Combining these yields the key reduction.

**Lemma 4 (Primitive part certifies a primitive divisor).** *Let $n \ge 3$ and
suppose $\mathrm{primPart}(n) > 1$. Then $F(n)$ has a primitive prime divisor;
explicitly, the least prime factor of $\mathrm{primPart}(n)$ is one.* (Formally:
`primPart_implies_primitive`.)

**Proof sketch.** Let $p$ be the least prime factor of $\mathrm{primPart}(n)$
(well-defined since $\mathrm{primPart}(n) > 1$). By Lemma 3, $p \mid
\mathrm{primPart}(n) \mid F(n)$. For primitivity, take any $0 < k < n$ with $p
\mid F(k)$. With $p \mid F(n)$, (P2) gives $p \mid F(\gcd(k,n))$. Now $\gcd(k,n)$
is a proper divisor of $n$ (positive, dividing $n$, and $\le k < n$), so by the
"coprime to proper divisors" lemma $p \nmid F(\gcd(k,n))$ — a contradiction.
Hence $p$ is primitive. $\qquad\blacksquare$

Lemma 4 reduces Carmichael's composite case to a *single inequality* for each
$n$: $\mathrm{primPart}(n) > 1$.

## 5. Verified Computation over a Finite Range

**Proposition 5 (Verified survival sweep).** *For every $n$ with $13 \le n \le
10000$, either $n$ is prime or $\mathrm{primPart}(n) > 1$.* (Formally:
`primPart_check`, established by a checked computation.)

The statement is a finite conjunction of decidable facts, discharged by direct
evaluation of $\mathrm{primPart}(n)$ for each $n$ in the range and a primality
test. No exceptions occur: every composite index in $[13, 10000]$ has a strictly
nontrivial primitive part.

**Theorem 6 (Composite case on the verified range).** *For composite $n$ with
$13 \le n \le 10000$, $F(n)$ has a primitive prime divisor.* (Formally:
`fib_carmichael_composite`, for the bounded range.)

**Proof sketch.** By Proposition 5, $n$ composite forces $\mathrm{primPart}(n) >
1$. Apply Lemma 4. $\qquad\blacksquare$

Combining Theorem 1 (prime indices, all $n \ge 13$) with Theorem 6 (composite
indices, $13 \le n \le 10000$) gives Carmichael's full conclusion for every $13
\le n \le 10000$, and Theorem 1 alone gives it for *all* prime indices without
upper bound.

**Status of the tail.** For composite $n > 10000$ the computation is replaced by
the growth principle: $F(n)$ grows like $\varphi^n$, while the product of the
$F(d)$ over proper divisors $d \mid n$ grows much more slowly, so $F(n)$ cannot be
exhausted by old factors. Turning this heuristic into a verified bound is the
remaining work; in the current development the tail is an explicit open case
(`sorry`) and is not claimed as proved.

## 6. Worked Numerical Illustrations

The following first appearances illustrate the theorems (all are first-appearance
facts that the proofs guarantee).

| $n$ | $F(n)$ | Factorization | Primitive prime divisor(s) |
|---|---|---|---|
| 13 (prime) | 233 | $233$ | $233$ |
| 17 (prime) | 1597 | $1597$ | $1597$ |
| 19 (prime) | 4181 | $37 \times 113$ | $37, 113$ |
| 23 (prime) | 28657 | $28657$ | $28657$ |
| 25 (composite) | 75025 | $5^2 \times 3001$ | $3001$ |
| 29 (prime) | 514229 | $514229$ | $514229$ |
| 31 (prime) | 1346269 | $557 \times 2417$ | $557, 2417$ |

For $n = 25$ the prime $5$ is *not* primitive — it already divides $F(5) = 5$ — but
$3001$ is new, exactly as the primitive-part construction predicts: stripping the
factors shared with $F(5)=5$ removes $5^2$ and leaves $3001 = \mathrm{primPart}(25)
> 1$.

## 7. Discussion, Ranks of Apparition, and Future Work

**Rank of apparition.** For a prime $p$, its *rank of apparition* $\alpha(p)$ is
the least $n > 0$ with $p \mid F(n)$. The strong divisibility identity $(\star)$
implies the fundamental law $p \mid F(n) \iff \alpha(p) \mid n$. Carmichael's
theorem, dually, asserts that the map $p \mapsto \alpha(p)$ is "almost surjective":
every index $n \ge 13$ is the rank of apparition of some prime — precisely the
primitive prime divisor of $F(n)$.

The same machinery generalizes to arbitrary **strong divisibility sequences**
(SDS) $a : \mathbb{N} \to \mathbb{N}$ satisfying $\gcd(a_m, a_n) = a_{\gcd(m,n)}$
with $a_1 = 1$. For any such sequence, the prime-case argument of Theorem 1
applies verbatim, and the primitive-part construction of Section 4 is
sequence-agnostic. We close with concrete follow-up problems.

**Conjecture 1 — Rank is multiplicative-coprime-additive.** For an SDS $a$ and
coprime targets $d, e$ (each appearing), the joint appearance set $\{n : de \mid
a_n\}$ is governed by the lcm of ranks: $(d \mid a_n \wedge e \mid a_n) \iff
\mathrm{lcm}(\mathrm{rank}_a d, \mathrm{rank}_a e) \mid n$. This should follow from
the divisibility law $d \mid a_n \iff \mathrm{rank}_a d \mid n$ applied twice,
combined with $\mathrm{lcm}\text{-}\mathrm{dvd}$.

**Conjecture 2 — Rank of a prime power.** For Fibonacci (and any SDS with a law of
apparition), if $p$ is prime with $\mathrm{rank}_{F} p = r$, then for $e \ge 1$,
$\mathrm{rank}_{F}(p^e) = p^{e-1} r$ unless a Wall–Sun–Sun-type exception holds.
Testable computationally for $p \le 50$, $e \le 4$; the abstract skeleton needs
only a $p$-adic valuation bound.

**Conjecture 3 — Pisano period divides a multiple of the rank.** The Pisano
period $\pi(m)$ (period of $F \bmod m$) satisfies $\mathrm{rank}_F m \mid \pi(m)$
with quotient $\pi(m)/\mathrm{rank}_F m \in \{1, 2, 4\}$. Testable for $m \le 200$;
the divisibility $\mathrm{rank} \mid \pi$ is a clean next target.

**Conjecture 4 — Carmichael via abstract SDS primitivity.** Generalize the
Fibonacci result to any SDS $a$ with strict growth $a_n \ge 2^n$ and a uniform
bound on $\prod_{d \mid n,\, d < n} a_d$: such a sequence has a primitive prime
divisor for all $n$ beyond an explicit threshold. The primitive-part machinery is
already sequence-agnostic; the work is reproving the large-$n$ growth bound.

**Conjecture 5 — Appearance-set semigroup characterization.** For an SDS $a$, the
family of appearance sets $\{\,\{n : d \mid a_n\} : d \in \mathrm{image}\,a\,\}$,
ordered by reverse inclusion, is isomorphic to the divisor lattice of indices via
$d \mapsto \mathrm{rank}_a d$. Each set is a rank-multiple set; the conjecture is
that $d \mid e$ corresponds to $\mathrm{rank}_a d \mid \mathrm{rank}_a e$.

**Resolving the tail.** The single most concrete open problem here is the
composite tail of Section 5: prove $\mathrm{primPart}(n) > 1$ for all composite $n
> 10000$ via the $\varphi^n$ growth estimate, completing Carmichael's theorem for
Fibonacci numbers within this framework.

## 8. Conclusion

The prime-index case of Carmichael's primitive divisor theorem admits a proof of
remarkable economy: one structural identity, $(\star)$, plus the observation that
a prime index forces $\gcd(n,k)=1$. This case is unconditionally established. The
composite case reduces, via an explicit and verifiably correct primitive-part
construction, to a single survival inequality, which we confirm by exact
computation for all $13 \le n \le 10000$. The combination yields Carmichael's
conclusion throughout that range and for all prime indices, while cleanly
delineating the infinite composite tail as the open frontier. The underlying
mechanism — first appearances controlled by indices through a gcd identity —
extends to the full theory of ranks of apparition for strong divisibility
sequences, where the conjectures of Section 7 await.
