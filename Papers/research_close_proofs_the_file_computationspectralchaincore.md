# Strong Divisibility Sequences: An Abstract Theory of Primitive Divisors and Apparition

## Abstract

We develop, from a single structural axiom, the elementary divisibility theory shared by the
Fibonacci numbers, the Mersenne-type sequences $a^n - 1$, and the broader family of *strong
divisibility sequences*. A sequence $u : \mathbb{N} \to \mathbb{N}$ is a **strong divisibility
sequence** if $u(\gcd(m,n)) = \gcd(u(m), u(n))$ for all $m, n$. We show that this one identity,
together with the elementary notion of a *primitive divisor*, suffices to derive: the weak
divisibility law $m \mid n \Rightarrow u(m) \mid u(n)$; a sharp meet law for arbitrary divisors;
the uniqueness of the index at which a value is primitive; the **law of apparition**
$p \mid u(m) \iff n \mid m$ for a primitive divisor $p$ of $u(n)$; the **join law**
$(p \mid u(n) \wedge q \mid u(n)) \iff \operatorname{lcm}(a,b) \mid n$ and its finite-family
generalization; and exact counting/density results $\#\{e < N : p \mid u(e+1)\} = \lfloor N/n \rfloor$
and $\lfloor N/\operatorname{lcm}(a,b)\rfloor$ for joint apparitions. A central observation is that
the classical law of apparition requires no primality hypothesis: only the meet law and minimality
of the first appearance are used. The Fibonacci sequence and the Mersenne-type sequences $a^n - 1$
are recorded as instances, so the entire theory specializes to both. All results have been
formally verified.

**Keywords.** strong divisibility sequence, primitive divisor, law of apparition, rank of
apparition, Fibonacci numbers, Mersenne numbers, Lucas sequences, gcd, lcm, divisibility lattice.

---

## 1. Introduction

The Fibonacci sequence $F_0 = 0,\ F_1 = 1,\ F_{n+2} = F_{n+1} + F_n$ enjoys a celebrated divisibility
property:
$$\gcd(F_m, F_n) = F_{\gcd(m,n)}. \tag{$\star$}$$
Identity $(\star)$ is the source of a large body of classical results: that $F_m \mid F_n$ whenever
$m \mid n$; that each prime $p$ has a *rank of apparition*, the least index at which $p$ divides a
Fibonacci number, with $p \mid F_n$ iff that rank divides $n$; and so on. The same identity, with
$F$ replaced by $a^n - 1$, reads
$$\gcd(a^m - 1, a^n - 1) = a^{\gcd(m,n)} - 1, \tag{$\star\star$}$$
a fact equally classical and equally fertile.

The purpose of this paper is to isolate the *minimal* hypothesis behind these phenomena and to
build the theory on it alone. We take as primitive the property displayed in $(\star)$ and
$(\star\star)$ — that the sequence is a **strong divisibility sequence** — and show that the entire
elementary apparition calculus follows. Crucially, the underlying recurrences (the Fibonacci
recurrence, the multiplicative structure of $a^n$) play *no role whatsoever* in the proofs; they
serve only to verify the single axiom for the two concrete instances.

A guiding methodological remark threads through the development: each theorem is proved from the
weakest hypotheses it actually needs. This discipline pays off immediately. The law of apparition is
classically stated for prime moduli; we find that primality is irrelevant, and the law holds for any
divisor possessing a first appearance. Likewise, the seductive but false statement
"$u(m) \mid u(n) \iff m \mid n$" (false at $F_1 = F_2 = 1$) is replaced by its correct refinement in
terms of primitive divisors.

### 1.1 Contributions

1. A definition of strong divisibility sequence (Definition 2.1) and of primitive divisor
   (Definition 2.2) phrased for an arbitrary sequence $u : \mathbb{N} \to \mathbb{N}$.
2. The weak divisibility law and the sharp meet law (Theorems 3.1, 3.2).
3. Rigidity of primitivity: uniqueness of the apparition index (Theorem 4.2), and the boundary
   behaviour at index $0$ (Theorem 4.1).
4. The law of apparition for arbitrary divisors (Theorem 5.1).
5. The join law for two divisors (Theorem 6.1) and for finite families (Theorem 6.2).
6. Exact counting and density results (Theorems 7.1, 7.2).
7. Verification that the Fibonacci sequence and the Mersenne-type sequences $a^n - 1$ are strong
   divisibility sequences (Theorems 8.1, 8.2), so all of the above specializes to both.

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, $\gcd$ and $\operatorname{lcm}$ denote the usual
greatest common divisor and least common multiple on $\mathbb{N}$ (with $\gcd(0,n) = n$ and
$\operatorname{lcm}(0,n) = 0$), and $a \mid b$ denotes divisibility.

**Definition 2.1 (Strong divisibility sequence).**
A function $u : \mathbb{N} \to \mathbb{N}$ is a *strong divisibility sequence* if
$$u(\gcd(m,n)) = \gcd(u(m), u(n)) \qquad \text{for all } m, n \in \mathbb{N}.$$
We abbreviate this hypothesis $\mathsf{SDS}(u)$.

**Definition 2.2 (Primitive divisor).**
Given $u : \mathbb{N} \to \mathbb{N}$ and $p, n \in \mathbb{N}$, we say $p$ is a *primitive divisor of
$u(n)$* if
$$p \mid u(n) \quad \text{and} \quad \forall k,\ (0 < k < n) \Rightarrow p \nmid u(k).$$
We write $\mathsf{Prim}(u; p, n)$. Informally, $p$ divides $u(n)$ but none of the earlier positive-index
terms; $n$ is the *first appearance* (or *apparition index*) of $p$.

These two definitions are the only primitives of the theory. Note that no recurrence, no positivity,
and no primality is assumed.

---

## 3. Elementary consequences of the strong divisibility law

**Theorem 3.1 (Weak divisibility law).**
If $\mathsf{SDS}(u)$ and $m \mid n$, then $u(m) \mid u(n)$.

*Proof.* From $m \mid n$ we get $\gcd(m,n) = m$. Applying $\mathsf{SDS}(u)$,
$$u(m) = u(\gcd(m,n)) = \gcd(u(m), u(n)),$$
and $\gcd(u(m), u(n)) \mid u(n)$. $\qquad\blacksquare$

This recovers the familiar weak divisibility law (for Fibonacci, the Mathlib fact `Nat.fib_dvd`) as a
*free corollary* of the strong law: no separate inductive argument is required.

**Theorem 3.2 (Meet law).**
If $\mathsf{SDS}(u)$, then for all $d, m, n$,
$$d \mid u(\gcd(m,n)) \iff \big(d \mid u(m) \ \wedge\ d \mid u(n)\big).$$

*Proof.* Rewrite the left side using $\mathsf{SDS}(u)$ to $d \mid \gcd(u(m), u(n))$, then apply the
characterization $d \mid \gcd(x,y) \iff d \mid x \wedge d \mid y$. $\qquad\blacksquare$

Theorem 3.2 is the lattice "meet" law at the level of raw divisors. It is sharp: it holds for *every*
$d$, with no coprimality or primality restriction, and is the workhorse behind the apparition results
of §5–§6.

---

## 4. Rigidity of primitivity

**Theorem 4.1 (Boundary at index $0$).**
If $u(0) = 0$, then $\mathsf{Prim}(u; p, 0)$ holds for every $p$.

*Proof.* $p \mid u(0) = 0$ trivially, and the minimality clause $\forall k,\ 0 < k < 0 \Rightarrow \cdots$
is vacuous. $\qquad\blacksquare$

The hypothesis $u(0) = 0$ is automatic for the Fibonacci sequence and for $a^n - 1$ at $n = 0$ when
$a^0 - 1 = 0$. The theorem records *why* index $0$ is excluded in the substantive results: every $p$ is
vacuously primitive there, so $0$ carries no information.

**Theorem 4.2 (Uniqueness of the apparition index).**
If $m, n > 0$ and $\mathsf{Prim}(u; p, m)$ and $\mathsf{Prim}(u; p, n)$, then $m = n$.

*Proof.* Suppose $m \ne n$, say $m < n$. Then $0 < m < n$, so the minimality clause of
$\mathsf{Prim}(u; p, n)$ gives $p \nmid u(m)$, contradicting $p \mid u(m)$ from $\mathsf{Prim}(u; p, m)$.
By symmetry the case $n < m$ is identical. $\qquad\blacksquare$

Strikingly, Theorem 4.2 uses *no* strong divisibility hypothesis: it is pure rigidity of the
"first appearance" definition. This is what makes the apparition index a well-defined labelling of
primitive divisors.

---

## 5. The law of apparition

**Theorem 5.1 (Law of apparition).**
Assume $\mathsf{SDS}(u)$. If $n > 0$ and $\mathsf{Prim}(u; p, n)$, then for all $m$,
$$p \mid u(m) \iff n \mid m.$$

*Proof.*
($\Leftarrow$) If $n \mid m$ then by Theorem 3.1, $u(n) \mid u(m)$; since $p \mid u(n)$, transitivity
gives $p \mid u(m)$.

($\Rightarrow$) Suppose $p \mid u(m)$. Together with $p \mid u(n)$, the meet law (Theorem 3.2) yields
$p \mid u(\gcd(n,m))$. Now $\gcd(n,m) \mid n$ and, since $n > 0$, we have $0 < \gcd(n,m) \le n$. If
$\gcd(n,m) < n$, the minimality clause of $\mathsf{Prim}(u; p, n)$ forces $p \nmid u(\gcd(n,m))$, a
contradiction. Hence $\gcd(n,m) = n$, i.e. $n \mid m$. $\qquad\blacksquare$

Theorem 5.1 is the conceptual centre of the paper. Two remarks:

- **No primality.** The classical statement assumes $p$ prime. The proof uses only the meet law and
  the minimality of the apparition index; primality is never invoked. The law of apparition therefore
  holds for *every* divisor possessing a first appearance.
- **Periodicity.** The set $\{m : p \mid u(m)\}$ is exactly $n\mathbb{N}$, the multiples of the
  apparition index. The "periodic comb" observed empirically for Fibonacci divisors is precisely this
  statement.

We define the *rank of apparition* of $p$ (when it exists) to be the unique $n > 0$ with
$\mathsf{Prim}(u; p, n)$; uniqueness is Theorem 4.2 and the divisibility characterization is
Theorem 5.1.

---

## 6. Simultaneous apparition: the join law

**Theorem 6.1 (Join law, two divisors).**
Assume $\mathsf{SDS}(u)$, $a, b > 0$, $\mathsf{Prim}(u; p, a)$ and $\mathsf{Prim}(u; q, b)$. Then for all
$n$,
$$\big(p \mid u(n) \ \wedge\ q \mid u(n)\big) \iff \operatorname{lcm}(a,b) \mid n.$$

*Proof.* By Theorem 5.1 applied to $p$ and to $q$, the left side is equivalent to
$(a \mid n) \wedge (b \mid n)$, which by the universal property of lcm is equivalent to
$\operatorname{lcm}(a,b) \mid n$. $\qquad\blacksquare$

Two periodic combs of spacings $a$ and $b$ overlap on a comb of spacing $\operatorname{lcm}(a,b)$.

**Theorem 6.2 (Join law, finite family).**
Assume $\mathsf{SDS}(u)$. Let $S$ be a finite index set, $f, g : S \to \mathbb{N}$ with $g(i) > 0$ and
$\mathsf{Prim}(u; f(i), g(i))$ for each $i \in S$. Then for all $n$,
$$\Big(\forall i \in S,\ f(i) \mid u(n)\Big) \iff \Big(\operatorname{lcm}_{i \in S} g(i)\Big) \mid n.$$

*Proof.* By Theorem 5.1, each conjunct $f(i) \mid u(n)$ is equivalent to $g(i) \mid n$. The claim is
then the universal property of the lcm over a finite family: $g(i) \mid n$ for all $i$ iff
$\operatorname{lcm}_i g(i) \mid n$. (Formally one inducts over $S$; the empty case uses
$\operatorname{lcm}_{\varnothing} = 1 \mid n$.) $\qquad\blacksquare$

---

## 7. Counting and density of apparition indices

The law of apparition turns analytic questions about how *often* a divisor appears into elementary
counting of multiples.

**Theorem 7.1 (Apparition count and density).**
Assume $\mathsf{SDS}(u)$, $n > 0$, $\mathsf{Prim}(u; p, n)$. For every $N$,
$$\#\big\{\,e \in \{0, \dots, N-1\} : p \mid u(e+1)\,\big\} = \left\lfloor \frac{N}{n} \right\rfloor.$$
Consequently the natural density of apparition indices of $p$ is $1/n$.

*Proof.* By Theorem 5.1, $p \mid u(e+1) \iff n \mid (e+1)$. The number of $e \in \{0, \dots, N-1\}$ with
$n \mid (e+1)$ is the number of multiples of $n$ in $\{1, \dots, N\}$, which is $\lfloor N/n \rfloor$.
The $+1$ shift excludes index $0$, where every divisor divides $u(0) = 0$. $\qquad\blacksquare$

**Theorem 7.2 (Joint apparition count).**
Assume $\mathsf{SDS}(u)$, $a, b > 0$, $\mathsf{Prim}(u; p, a)$, $\mathsf{Prim}(u; q, b)$. For every $N$,
$$\#\big\{\,e \in \{0, \dots, N-1\} : p \mid u(e+1)\ \wedge\ q \mid u(e+1)\,\big\}
   = \left\lfloor \frac{N}{\operatorname{lcm}(a,b)} \right\rfloor.$$
Hence the joint density is $1/\operatorname{lcm}(a,b)$.

*Proof.* By Theorem 6.1 the joint predicate is equivalent to $\operatorname{lcm}(a,b) \mid (e+1)$, and the
count of such $e$ is $\lfloor N/\operatorname{lcm}(a,b) \rfloor$ as in Theorem 7.1. $\qquad\blacksquare$

---

## 8. Instances

**Theorem 8.1 (Fibonacci).** The Fibonacci sequence $F : \mathbb{N} \to \mathbb{N}$ is a strong
divisibility sequence, $\mathsf{SDS}(F)$.

*Proof.* This is identity $(\star)$, $\gcd(F_m, F_n) = F_{\gcd(m,n)}$. $\qquad\blacksquare$

**Theorem 8.2 (Mersenne-type).** For every base $a \in \mathbb{N}$, the sequence
$u(n) = a^n - 1$ is a strong divisibility sequence, $\mathsf{SDS}(u)$.

*Proof.* This is identity $(\star\star)$, $\gcd(a^m - 1, a^n - 1) = a^{\gcd(m,n)} - 1$, valid for all
$a$ (the case $a = 0$ being handled separately). $\qquad\blacksquare$

By Theorems 8.1 and 8.2, every result of §3–§7 specializes verbatim to the Fibonacci numbers and to
the families $a^n - 1$ (in particular the Mersenne numbers $2^n - 1$). The specialization is literal:
the same theorems instantiate at a different sequence, with no adaptation of the proofs.

### 8.1 Worked example (Fibonacci)

The divisor $p = 2$ first appears in the Fibonacci sequence at $F_3 = 2$ and divides none of
$F_1 = 1, F_2 = 1$; thus $\mathsf{Prim}(F; 2, 3)$. Theorem 5.1 gives $2 \mid F_m \iff 3 \mid m$: the even
Fibonacci numbers are exactly $F_3, F_6, F_9, \dots$. Similarly $\mathsf{Prim}(F; 5, 5)$ since $5 = F_5$
divides no earlier term, so $5 \mid F_m \iff 5 \mid m$. By the join law (Theorem 6.1),
$2$ and $5$ jointly divide $F_n$ iff $\operatorname{lcm}(3,5) = 15 \mid n$; indeed $F_{15} = 610 = 2 \cdot 5
\cdot 61$. Theorem 7.1 gives exactly $\lfloor 30/3 \rfloor = 10$ even terms among $F_1, \dots, F_{30}$.

### 8.2 Worked example (Mersenne-type, $a = 2$)

For $u(n) = 2^n - 1 = 0, 1, 3, 7, 15, 31, 63, \dots$, the divisor $p = 7$ first appears at
$u(3) = 7$ and divides neither $u(1) = 1$ nor $u(2) = 3$; thus $\mathsf{Prim}(u; 7, 3)$. Theorem 5.1
gives $7 \mid 2^m - 1 \iff 3 \mid m$, the familiar statement that the multiplicative order of $2$ modulo
$7$ is $3$. The join law recovers, e.g., that $7$ and $5$ (with $\mathsf{Prim}(u;5,4)$, since
$2^4 - 1 = 15$ is the first term divisible by $5$) jointly divide $2^n - 1$ iff
$\operatorname{lcm}(3,4) = 12 \mid n$.

---

## 9. Algorithms

The theory is constructive and yields simple, efficient algorithms.

**Algorithm A (Rank of apparition / first appearance).** Given $u$ and $p$, scan $n = 1, 2, 3, \dots$
and return the first $n$ with $p \mid u(n)$. By Theorem 4.2 this $n$ is unique, and by Theorem 5.1 it
fully determines the divisibility set $\{m : p \mid u(m)\} = n\mathbb{N}$. Cost: $O(n)$ sequence
evaluations, where $n$ is the rank.

**Algorithm B (Membership test).** To test $p \mid u(m)$ for large $m$, compute the rank $n$ once via
Algorithm A, then return the boolean $n \mid m$. This replaces a potentially huge computation of
$u(m)$ by a single divisibility test, after an up-front $O(n)$ cost.

**Algorithm C (Joint membership and counting).** Given primitive data $(p, a)$ and $(q, b)$, compute
$\ell = \operatorname{lcm}(a,b)$ once; then $p, q$ jointly divide $u(m)$ iff $\ell \mid m$
(Theorem 6.1), and the count up to $N$ is $\lfloor N/\ell \rfloor$ (Theorem 7.2). This generalizes to
a finite family via $\operatorname{lcm}$ of all the ranks (Theorem 6.2).

---

## 10. Applications

- **Mersenne prime search.** Recognizing $2^n - 1$ as a strong divisibility sequence makes the
  factorization heuristics (a prime factor of $2^n - 1$ that is primitive appears only at multiples of
  $n$) instances of Theorems 5.1 and 6.1, unifying ad hoc divisibility lemmas used in practice.
- **Periodicity of residues.** Theorem 5.1 is exactly the statement that the appearance of a divisor is
  periodic with period equal to its rank; for $a^n - 1$ this is the order of $a$ modulo a divisor,
  recovering a basic fact of multiplicative order theory.
- **Density estimates.** Theorems 7.1–7.2 give exact, not asymptotic, counts of apparition indices,
  useful in sieve-style arguments and in estimating the frequency of terms divisible by prescribed
  sets of moduli.
- **Lucas sequence theory.** Many Lucas sequences $U_n(P,Q)$ are strong divisibility sequences; the
  abstract framework applies to them without reproof.

---

## 10.5. Related context

The study of divisibility in integer sequences has a long lineage. Lucas, in the nineteenth
century, systematized the arithmetic of the sequences $U_n(P,Q)$ now bearing his name, and
identified ranks of apparition for prime moduli. Carmichael's theorem on primitive divisors of
Fibonacci numbers, and Zsygmondy's theorem on primitive divisors of $a^n - b^n$, are deep refinements
concerning the *existence* of primitive divisors. The present paper occupies the elementary stratum
beneath those results: it does not address existence, but rather the *structure* that any primitive
divisor must obey once it exists. What is new here is not the individual facts --- most are classical
for Fibonacci and for $a^n - 1$ --- but the demonstration that they are all consequences of a single
axiom, shared across sequences, with the recurrences playing no role.

The abstraction "strong divisibility sequence" is itself classical terminology, but it is usually
introduced and then promptly specialized. Our emphasis is the opposite: we keep the sequence abstract
throughout and show how far one can travel on the axiom alone. The payoff is that the Fibonacci and
Mersenne-type theories are not analogues requiring parallel proofs but *literal instances* of one
theory.

## 11. Discussion

The development illustrates a recurring theme in mathematics: the right abstraction collapses a family
of special cases into a single argument. The four substantive results — meet law, uniqueness, law of
apparition, join law — never touch the defining recurrences of their motivating examples. They use only
$\mathsf{SDS}(u)$ and the minimality built into primitivity. This is why the Fibonacci and Mersenne-type
specializations are *literal instances* rather than analogues.

Two clarifications emerged from insisting on minimal hypotheses. First, the law of apparition needs no
primality. Second, the naive equivalence $u(m) \mid u(n) \iff m \mid n$ is false at the degenerate
indices ($F_1 = F_2 = 1$); the correct theory routes through primitive divisors and positivity, which
sidestep the degeneracy cleanly. The boundary lemma (Theorem 4.1) records exactly why index $0$ must be
excluded.

A further methodological point deserves emphasis. Theorem 4.2 (uniqueness of the apparition index) was
proved using *no* strong divisibility hypothesis at all; it is a property of the bare definition of
primitivity. Separating which results need the axiom (the meet law, apparition, the join law) from
those that do not (uniqueness, the index-$0$ boundary) sharpens one's understanding of where the
arithmetic content truly resides. The strong divisibility law is responsible for translating the
lattice of indices into the lattice of values; the rigidity of primitivity is responsible for making
the translation a labelling. Both ingredients are necessary, and the proofs make the division of
labour explicit.

Finally, we note that the constructive content of the theory (Algorithms A--C of \S9) is genuine: the
rank of apparition is computable, membership reduces to a single divisibility test, and joint counts
are closed-form. This is what makes the accompanying numerical demonstrations possible and what would
make an eventual extension to existence questions (\S12) computationally meaningful.

---

## 12. Future Directions

(See the companion "Future Directions" notes for the full program; in brief.)

1. **Typeclass abstraction across the catalog.** Factor $\mathsf{SDS}$ into a reusable interface so that
   every divisibility file inheriting it gets the apparition calculus for free; the proofs are already
   phrased structurally around the gcd identity, making this a mechanical refactor that multiplies
   theorem count across Lucas sequences $U_n(P,Q)$, Mersenne numbers, and $q$-integers $[n]_q$.
2. **Total existence of the rank of apparition.** Identify clean sufficient conditions (e.g.
   eventual strict monotonicity, or a growth bound) guaranteeing that every modulus admits a first
   appearance, upgrading the conditional law of apparition to an unconditional one.
3. **Sharper densities and error terms.** Move from exact counts of single/joint apparitions to
   asymptotic densities over families of moduli, connecting the apparition lattice to analytic number
   theory.
4. **Primitive divisor existence (Zsygmondy-type).** Combine the rigidity results here with growth
   estimates to study when $u(n)$ possesses a primitive divisor at all, the abstract shadow of
   Carmichael's and Zsygmondy's theorems.

---

## 13. Conclusion

From the single axiom $u(\gcd(m,n)) = \gcd(u(m), u(n))$ we have derived, with full rigor, the complete
elementary theory of primitive divisors and apparition: weak divisibility, the meet law, uniqueness of
apparition indices, the law of apparition (without any primality hypothesis), the join law for two and
for finitely many divisors, and exact counting/density results. The Fibonacci numbers and the
Mersenne-type sequences $a^n - 1$ are instances, so the theory specializes to both at once. The lesson
is that the order one observes in such sequences — periodic appearances, clockwork densities — is not a
fingerprint of any particular recurrence, but a property of the strong divisibility law itself.
