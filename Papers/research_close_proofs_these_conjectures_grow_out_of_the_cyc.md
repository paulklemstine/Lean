# A Unified Theory of Mixed-Radix Numeration, with the Factorial System as a Special Case, and Primitive Prime Divisors of Fibonacci Numbers

## Abstract

We present two self-contained developments in elementary number theory. The
first is a uniform theory of **mixed-radix positional number systems**: fixing an
arbitrary sequence of bases $b_0, b_1, b_2, \dots$, we define the value and
validity of digit strings, prove a sharp size bound, establish the Euclidean
splitting identities, and derive uniqueness and existence of valid
representations — all without recourse to counting, cardinality, or bijection
arguments. Ordinary base-$N$ numeration and the factorial (factoradic) number
system emerge as the special cases $b_i = N$ and $b_i = i+1$, and we show that
the classical uniqueness of factoradic representations is a genuine corollary of
the general theorem, transported along the running-product identity
$\prod_{j<i}(j+1) = i!$. The second development concerns **primitive prime
divisors of Fibonacci numbers**. Using the identity $\gcd(F_m, F_n) =
F_{\gcd(m,n)}$ and the notion of the primitive part of $F_n$, we prove that for
every $n$ with $13 \le n \le 10000$ the number $F_n$ possesses a primitive prime
divisor — a prime dividing $F_n$ but no earlier Fibonacci number. This is the
Fibonacci instance of Carmichael's 1913 primitive-divisor theorem, established
here unconditionally on an exhaustively verified range; we isolate precisely the
growth estimate on the primitive part that a fully unbounded proof requires.

**Keywords:** mixed-radix numeration, factorial number system, factoradic,
positional notation, Euclidean division, Fibonacci numbers, primitive prime
divisor, Carmichael's theorem, Zsygmondy's theorem.

---

## 1. Introduction

Positional number systems are usually taught as a family indexed by a single
parameter, the base $N$. Yet several important systems do not fit that mold. The
**factorial number system**, whose place values are the factorials $0!, 1!, 2!,
\dots$ and whose $i$-th digit is bounded by $i$, is the arithmetic backbone of
permutation ranking, Lehmer codes, and lexicographic enumeration of
permutations. Time-of-day and pre-decimal currency are further examples where the
"base" differs from position to position.

The organizing observation of Part I is that all of these are instances of a
single **mixed-radix system** in which one fixes an entire sequence of bases and
takes place values to be running products. We give a complete, elementary
treatment: definitions (Section 3), the size bound and splitting identities
(Section 4), uniqueness and existence (Section 5), and the two bridges to base-$N$
and factoradic systems (Section 6). The design goal is *non-circularity*:
uniqueness is proved directly from arithmetic, so that the classical factoradic
uniqueness theorem can be honestly *derived* from the general one rather than
assumed.

Part II turns to a classical divisibility phenomenon. A prime $p$ is a
**primitive prime divisor** of $F_n$ if $p \mid F_n$ but $p \nmid F_k$ for all
$1 \le k < n$. Carmichael proved in 1913 that every Fibonacci number $F_n$ with
$n > 12$ has such a divisor. We reconstruct the mechanism through the *primitive
part* of $F_n$ and prove the theorem on the range $13 \le n \le 10000$ by exact
computation combined with a structural bridge lemma, and we pinpoint the missing
analytic ingredient for the unbounded statement (Section 8).

---

## 2. Notation and conventions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$. For a sequence of bases we write
$b : \mathbb{N} \to \mathbb{N}$ and for digit strings $c, d : \mathbb{N} \to
\mathbb{N}$. We use $\lfloor x/y \rfloor$ for integer (Euclidean) quotient and
$x \bmod y$ for the remainder. The Fibonacci numbers are $F_1 = F_2 = 1$ and
$F_{n+1} = F_n + F_{n-1}$; we set $F_0 = 0$.

---

# Part I. Mixed-Radix Numeration

## 3. Definitions

**Definition 3.1 (Running product).** For a base sequence $b$ and length $k$, the
*running product* is
$$P_b(k) \;=\; \prod_{i<k} b_i, \qquad P_b(0) = 1, \qquad P_b(k+1) = P_b(k)\cdot b_k.$$
$P_b(i)$ is the place value of position $i$.

**Definition 3.2 (Value).** The length-$k$ *value* of a digit string $c$ under
bases $b$ is
$$V_b(c, k) \;=\; \sum_{i<k} c_i \, P_b(i).$$
It satisfies the recurrence $V_b(c, 0) = 0$ and
$$V_b(c, k+1) = V_b(c, k) + c_k \, P_b(k). \tag{3.1}$$

**Definition 3.3 (Validity).** A digit string $c$ is *valid up to length $k$*,
written $\mathrm{Valid}_b(c, k)$, if $c_i < b_i$ for every $i < k$. Validity is
monotone: if $\mathrm{Valid}_b(c, k+1)$ then $\mathrm{Valid}_b(c, k)$.

**Remark 3.4 (Positivity is automatic).** If $\mathrm{Valid}_b(c, k+1)$ holds
then $P_b(k) > 0$: each factor $b_i$ exceeds the corresponding digit $c_i \ge 0$,
hence $b_i \ge 1$. We therefore never need to *assume* the bases are positive when
reasoning about valid strings; positivity is supplied by validity itself. When a
base $b_i$ equals $0$, no digit is valid at position $i$, so every statement of
the form "for all valid strings …" holds — vacuously but truthfully — at lengths
exceeding $i$.

---

## 4. The size bound and the splitting identities

**Theorem 4.1 (Digit-bound estimate).** If $\mathrm{Valid}_b(c, k)$ then
$$V_b(c, k) < P_b(k).$$

*Proof.* Induction on $k$. For $k = 0$ both sides are $0 < 1$. Assume the claim at
$k$ and let $c$ be valid up to $k+1$. By (3.1) and the inductive hypothesis
applied to the restriction of $c$,
$$V_b(c, k+1) = V_b(c, k) + c_k P_b(k) < P_b(k) + c_k P_b(k) = (c_k + 1) P_b(k)
\le b_k \, P_b(k) = P_b(k+1),$$
using $c_k + 1 \le b_k$ from validity at position $k$. $\qquad\blacksquare$

The bound is sharp: taking $c_i = b_i - 1$ everywhere gives $V_b(c, k) = P_b(k) -
1$, a telescoping identity that expresses "all nines" in general radix.

**Theorem 4.2 (Splitting identities).** If $\mathrm{Valid}_b(c, k+1)$ then
$$\big\lfloor V_b(c, k+1) / P_b(k)\big\rfloor = c_k
\qquad\text{and}\qquad
V_b(c, k+1) \bmod P_b(k) = V_b(c, k).$$

*Proof.* By (3.1), $V_b(c,k+1) = V_b(c,k) + c_k P_b(k)$ with $0 \le V_b(c,k) <
P_b(k)$ (Theorem 4.1) and $P_b(k) > 0$ (Remark 3.4). This is exactly the
statement that $V_b(c,k)$ is the remainder and $c_k$ the quotient of
$V_b(c,k+1)$ upon division by $P_b(k)$, i.e. the uniqueness of Euclidean
division. $\qquad\blacksquare$

The splitting identities are the algebraic content of "reading off the top
digit": one division and one remainder peel a length-$(k+1)$ string into its top
digit and its length-$k$ tail.

---

## 5. Uniqueness and existence

**Theorem 5.1 (Uniqueness).** If $\mathrm{Valid}_b(c, k)$, $\mathrm{Valid}_b(d,
k)$, and $V_b(c, k) = V_b(d, k)$, then $c_i = d_i$ for all $i < k$.

*Proof.* Induction on $k$; the base case $k=0$ is vacuous. Suppose the result at
$k$ and let $c, d$ be valid up to $k+1$ with equal values. Dividing the common
value by $P_b(k)$ and applying Theorem 4.2 to each side gives $c_k = d_k$. Taking
remainders gives $V_b(c, k) = V_b(d, k)$. By the inductive hypothesis (both
strings remain valid up to $k$ by monotonicity), $c_i = d_i$ for all $i < k$;
together with $c_k = d_k$ this covers all $i < k+1$. $\qquad\blacksquare$

Note the proof uses only Theorems 4.1–4.2 and induction. It does **not** invoke
cardinality, surjectivity, or any bijection theorem, so it may be used as a
foundation for those results rather than depending on them.

**Definition 5.2 (Digit extraction).** For a target $n$ define
$$\mathrm{digit}_b(n, i) \;=\; \big\lfloor n / P_b(i)\big\rfloor \bmod b_i.$$

**Theorem 5.3 (Existence).** If $n < P_b(k)$ then $V_b(\mathrm{digit}_b(n,\cdot),
k) = n$.

*Proof.* The key identity, proved by induction on $m$, is
$$n = \sum_{i<m} \Big(\big\lfloor n/P_b(i)\big\rfloor \bmod b_i\Big) P_b(i)
      + \big\lfloor n/P_b(m)\big\rfloor \, P_b(m),$$
obtained by repeatedly applying $x = (x \bmod b_i) + b_i \lfloor x / b_i \rfloor$
to $\lfloor n/P_b(i)\rfloor$ and using $P_b(i+1) = P_b(i) b_i$. Setting $m = k$
and using $\lfloor n/P_b(k)\rfloor = 0$ (since $n < P_b(k)$) leaves exactly
$V_b(\mathrm{digit}_b(n,\cdot), k) = n$. $\qquad\blacksquare$

**Theorem 5.4 (Digit validity).** If $b_i > 0$ for all $i$, then
$\mathrm{digit}_b(n, \cdot)$ is valid up to every length $k$, since
$x \bmod b_i < b_i$.

**Corollary 5.5 (Bijection).** For a positive base sequence, the valid length-$k$
digit strings are in bijection with $\{0, 1, \dots, P_b(k) - 1\}$ via $c \mapsto
V_b(c, k)$, with inverse $n \mapsto \mathrm{digit}_b(n, \cdot)$.

---

## 6. Two classical systems as special cases

**Theorem 6.1 (Base-$N$).** For the constant sequence $b_i = N$,
$$P_b(k) = N^k,$$
so the value $\sum_{i<k} c_i N^i$ is the ordinary base-$N$ numeral and validity
$c_i < N$ is the familiar digit rule. Uniqueness (Theorem 5.1) and existence
(Theorem 5.3) specialize to standard positional notation.

**Theorem 6.2 (Factorial / factoradic).** For the sequence $b_i = i+1$,
$$P_b(k) = \prod_{i<k}(i+1) = k!,$$
so the value is $\sum_{i<k} c_i \, i!$ and validity $c_i < i+1$ is exactly the
factoradic bound $c_i \le i$.

*Proof of the running-product identity.* Induction: $P_b(0) = 1 = 0!$, and
$P_b(k+1) = P_b(k)\cdot(k+1) = k!\,(k+1) = (k+1)!$. $\qquad\blacksquare$

**The bridge (non-circularity).** Let $V^{\mathrm{fact}}(c,k) = \sum_{i<k} c_i\,i!$
and let factoradic validity be $c_i \le i$ for $i<k$. Two bridge facts connect the
factorial system to the mixed-radix system at $b_i = i+1$:

1. **Value agreement.** $V_b(c, k) = V^{\mathrm{fact}}(c, k)$, by a termwise
   comparison using $P_b(i) = i!$ (Theorem 6.2).
2. **Validity agreement.** $\mathrm{Valid}_b(c, k) \iff (\forall i<k,\ c_i \le
   i)$, since $c_i < i+1 \iff c_i \le i$.

**Theorem 6.3 (Factoradic uniqueness, derived).** If $c, d$ are factoradic-valid
up to $k$ and $V^{\mathrm{fact}}(c,k) = V^{\mathrm{fact}}(d,k)$, then $c_i = d_i$
for all $i < k$.

*Proof.* Transport the hypotheses across the two bridge facts to obtain
$\mathrm{Valid}_b(c,k)$, $\mathrm{Valid}_b(d,k)$, and $V_b(c,k) = V_b(d,k)$ for
$b_i = i+1$; apply the general Theorem 5.1; transport the conclusion back.
$\qquad\blacksquare$

The derivation invokes only the general uniqueness theorem and the two bridge
facts, none of which depends on a standalone factoradic uniqueness proof. Hence
the mixed-radix theory genuinely *subsumes* the factorial system, exhibiting
factoradics and ordinary positional notation as two points of one parameterized
family.

**Application 6.4 (Permutation ranking).** The factoradic bijection of Corollary
5.5 at $b_i = i+1$ identifies $\{0, \dots, k!-1\}$ with valid length-$k$ digit
strings, which in turn index the $k!$ permutations of $k$ symbols via the Lehmer
code. Uniqueness guarantees that this ranking is well defined and injective; this
is precisely the correctness statement underlying lexicographic permutation
generation.

---

# Part II. Primitive Prime Divisors of Fibonacci Numbers

## 7. Definitions and the divisibility backbone

**Definition 7.1 (Primitive prime divisor).** A prime $p$ is a *primitive prime
divisor* of $F_n$ if $p \mid F_n$ and $p \nmid F_k$ for every $k$ with
$0 < k < n$.

The theory rests on two classical facts about Fibonacci numbers:

- **Divisibility.** $m \mid n \implies F_m \mid F_n$.
- **GCD identity.** $\gcd(F_m, F_n) = F_{\gcd(m,n)}$.

**Lemma 7.2 (Bridge lemma: divisors suffice).** Fix $n > 0$ and a prime $p$ with
$p \mid F_n$. Suppose $p \nmid F_d$ for every *proper divisor* $d$ of $n$ (i.e.
$d \mid n$, $0 < d < n$). Then $p \nmid F_k$ for every $k$ with $0 < k < n$; that
is, $p$ is a primitive prime divisor of $F_n$.

*Proof.* Let $0 < k < n$ and suppose for contradiction $p \mid F_k$. Then
$p \mid \gcd(F_n, F_k) = F_{\gcd(n,k)}$. Put $g = \gcd(n,k)$. Then $g \mid n$ and
$0 < g \le k < n$, so $g$ is a proper divisor of $n$ with $p \mid F_g$,
contradicting the hypothesis. $\qquad\blacksquare$

Lemma 7.2 is the crucial reduction: to certify primitivity it suffices to rule out
the finitely many *divisors* of $n$, not all $k < n$.

---

## 8. The primitive part and the main theorem

**Definition 8.1 (Primitive part).** The *primitive part* $\pi(n)$ of $F_n$ is
obtained by starting from $F_n$ and, for each proper divisor $d$ of $n$,
repeatedly dividing out $\gcd(\cdot, F_d)$ until coprime:
$$\pi(n) \;=\; \Big(\text{$F_n$ with every prime factor of some $F_d$, $d\mid n$, $d<n$, removed}\Big).$$
Because $\gcd(F_n, F_d) = F_{\gcd(n,d)}$, this strips exactly the "old" primes —
those already occurring at an earlier index — and leaves a divisor of $F_n$.

**Lemma 8.2 (Survivors are primitive).** If $\pi(n) > 1$, then any prime $p \mid
\pi(n)$ is a primitive prime divisor of $F_n$.

*Proof.* Since $\pi(n) \mid F_n$, we have $p \mid F_n$. By construction $\pi(n)$
is coprime to $F_d$ for every proper divisor $d \mid n$, so $p \nmid F_d$ for all
such $d$. Lemma 7.2 upgrades this to $p \nmid F_k$ for all $0 < k < n$.
$\qquad\blacksquare$

**Theorem 8.3 (Fibonacci primitive-divisor theorem, verified range).** For every
integer $n$ with $13 \le n \le 10000$, whether $n$ is prime or composite, $F_n$
has a primitive prime divisor.

*Proof sketch.* Two cases combine.

- **$n$ prime.** For prime $n \ge 13$ the only proper divisor is $1$, with
  $F_1 = 1$, so every prime factor of $F_n$ is automatically primitive by Lemma
  7.2 (there is nothing to exclude beyond $F_1 = 1$); one verifies $F_n > 1$.
- **$n$ composite.** Compute the primitive part $\pi(n)$ by the stripping
  procedure of Definition 8.1 and check $\pi(n) > 1$. This is an exact
  finite integer computation carried out for every composite $n$ in the range
  $13 \le n \le 10000$. Lemma 8.2 then produces a primitive prime divisor.

The correctness of the stripping procedure — that its output divides $F_n$ and is
coprime to each $F_d$ — is established by induction on the fuel of the repeated
division, using $\gcd$-monotonicity and $\gcd(F_n, F_d) = F_{\gcd(n,d)}$.
$\qquad\blacksquare$

**Exceptional cases.** The bound $n \ge 13$ is necessary. $F_1 = F_2 = 1$ have no
prime divisors; $F_6 = 8 = 2^3$ has only the prime $2$, already present in
$F_3 = 2$; and $F_{12} = 144 = 2^4 \cdot 3^2$ recycles $2$ and $3$ from $F_3$ and
$F_4$. These are exactly the known exceptions to the theorem.

**Remark 8.4 (The unbounded statement and the missing gear).** Theorem 8.3 is the
Fibonacci instance of Carmichael's 1913 theorem, itself a special case of
Zsygmondy's primitive-divisor theorem, which holds for *all* $n > 12$ with no
upper bound. A fully unbounded proof cannot proceed by finite computation; it
requires a quantitative *lower bound* on the primitive part $\pi(n)$, obtained by
recognizing $\pi(n)$ as (essentially) the value of the $n$-th cyclotomic
polynomial evaluated at the golden ratio $\varphi = (1+\sqrt5)/2$ and its
conjugate, and estimating that value from below to force $\pi(n) > 1$. This
growth estimate is the single analytic ingredient beyond the elementary
divisibility theory developed here, and it is the natural target for extending
Theorem 8.3 past any finite range.

---

## 9. Algorithms

**Algorithm A (Mixed-radix encode/decode).** Given bases $b$, to *decode* $n$
into length-$k$ digits, iterate $c_i = \lfloor n/P_b(i)\rfloor \bmod b_i$
(Definition 5.2); to *encode*, evaluate $\sum_{i<k} c_i P_b(i)$ (Definition 3.2).
Correctness is Theorems 5.1 and 5.3. Cost is $O(k)$ big-integer operations.

**Algorithm B (Factoradic permutation rank/unrank).** Specialize Algorithm A to
$b_i = i+1$. The rank of a permutation is the factoradic value of its Lehmer
code; unranking inverts the digit extraction. Correctness is Theorem 6.3.

**Algorithm C (Fibonacci primitive part).** Compute $F_n$; for each proper
divisor $d$ of $n$, repeatedly replace the running value $r$ by $r/\gcd(r, F_d)$
until $\gcd(r, F_d) = 1$; return the final $r = \pi(n)$. If $\pi(n) > 1$, factor
it (or take any prime factor) to exhibit a primitive divisor. Correctness is
Lemmas 8.2 and 7.2.

---

## 10. Applications and discussion

The mixed-radix theory provides a single correctness proof covering ordinary
positional notation, factoradics (hence Lehmer codes and permutation ranking),
and any variable-base system such as clock arithmetic. Its deliberately
elementary, counting-free proof of uniqueness makes it a clean foundation:
downstream results about enumeration or bijections may build on it without risk of
circular dependence.

The Fibonacci results illustrate how a global divisibility structure — the
$\gcd(F_m, F_n) = F_{\gcd(m,n)}$ identity — localizes an infinite condition
("primitive over all $k < n$") to a finite one ("primitive over the divisors of
$n$"), after which exact computation settles a large range. The same primitive-part
mechanism generalizes to other Lucas sequences and underlies the general
Zsygmondy theory.

## 11. Future work

Beyond the analytic lower bound of Remark 8.4 needed to remove the upper bound
$n \le 10000$, natural extensions include: (i) a mixed-radix treatment of
*infinite* place-value systems and Cantor-style expansions; (ii) canonical forms
and carry algorithms for arithmetic performed directly in mixed radix; and (iii)
transporting the primitive-part machinery to general Lucas sequences $U_n(P,Q)$ to
recover the full Zsygmondy theorem in the same elementary style.

---

## References

- R. D. Carmichael, *On the numerical factors of the arithmetic forms
  $\alpha^n \pm \beta^n$*, Annals of Mathematics, 1913.
- K. Zsygmondy, *Zur Theorie der Potenzreste*, Monatshefte für Mathematik und
  Physik, 1892.
- D. E. Knuth, *The Art of Computer Programming, Vol. 2: Seminumerical
  Algorithms* (mixed-radix and factorial number systems).
