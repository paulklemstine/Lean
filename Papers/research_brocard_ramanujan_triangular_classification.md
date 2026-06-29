# A Bertrand-Postulate Obstruction to Square and Square–Triangular Factorials

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Number Theory (Novelty)

## Abstract

We give a complete and elementary classification of the natural numbers $n$ for which the factorial $n!$ is a perfect square, and for which $n!$ is simultaneously a perfect square and a triangular number. In both cases the answer is the same and maximally restrictive: it happens if and only if $n \le 1$. The proof rests on a single structural fact extracted from **Bertrand's postulate**: for every $n \ge 2$ there is a prime $p$ with $n/2 < p \le n$, and such a prime divides $n!$ to *exact multiplicity one*. Since a perfect square requires every prime to occur to even multiplicity, this lone prime obstructs squareness for all $n \ge 2$. We isolate the obstruction as reusable lemmas, formalize the entire chain in the Lean 4 proof assistant on top of Mathlib, and situate the result against its famous open cousin, the **Brocard–Ramanujan problem** ($n! + 1 = m^2$), whose triangular reformulation we make precise. All results in this paper are fully proved; the Brocard–Ramanujan classification is discussed only as motivation and future work, and is *not* claimed as a theorem here.

## 1. Introduction

Factorials, $n! = \prod_{k=1}^{n} k$, are among the most basic objects in combinatorics, counting the permutations of an $n$-element set. A recurring meta-question in number theory is whether members of a fast-growing integer sequence can also be *figurate* — perfect squares, triangular numbers, perfect powers, and so on. Such coincidences are rare and rigid, and their classification often reveals a sharp arithmetic obstruction.

This paper answers the question for squares and for the square–triangular intersection. The data is suggestive: the perfect squares begin $1, 4, 9, 16, 25, \dots$, while the factorials are $1, 1, 2, 6, 24, 120, 720, \dots$. The only overlaps are the two trivial $1$'s at $n = 0$ and $n = 1$. We prove this is no accident and admits no large exception.

**Main Theorem (Square classification).** For every $n \in \mathbb{N}$, $n!$ is a perfect square if and only if $n \le 1$.

**Corollary (Square–triangular classification).** For every $n \in \mathbb{N}$, $n!$ is simultaneously a perfect square and a triangular number if and only if $n \le 1$.

The engine is a clean valuation statement: the $p$-adic valuation of $n!$ at a Bertrand prime $p \in (n/2, n]$ is exactly $1$. Because squareness demands even valuations everywhere, a single odd valuation suffices to rule it out. The argument is short, fully constructive in its prime input, and was formally verified in Lean 4.

We deliberately separate what is proved from what is conjectured. The closely related **Brocard–Ramanujan problem** asks for which $n$ is $n! + 1$ a perfect square; only $n \in \{4, 5, 7\}$ are known and the finiteness of this set is a longstanding open problem. We give its exact triangular reformulation (Section 6) and explain precisely why the "$+1$" defeats the valuation method, but we make no claim to resolve it.

## 2. Definitions and Preliminaries

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and $n! = \prod_{k=1}^n k$ with $0! = 1$.

**Definition 2.1 (Perfect square).** A natural number $m$ is a *perfect square*, written $\mathrm{IsSquare}(m)$, if there exists $k \in \mathbb{N}$ with $m = k^2$.

**Definition 2.2 (Triangular number).** A natural number $m$ is *triangular*, written $\mathrm{IsTriangular}(m)$, if there exists $t \in \mathbb{N}$ with
$$m = \frac{t(t+1)}{2} = T_t.$$
The triangular numbers are $0, 1, 3, 6, 10, 15, 21, 28, 36, \dots$.

**Definition 2.3 ($p$-adic valuation).** For a prime $p$ and a positive integer $m$, the *$p$-adic valuation* $v_p(m)$ is the exponent of $p$ in the prime factorization of $m$; equivalently $v_p(m) = \max\{e : p^e \mid m\}$. In Lean/Mathlib this is `Nat.factorization m p`.

**Lemma 2.4 (Legendre's formula).** For a prime $p$ and $n \ge 1$,
$$v_p(n!) = \sum_{i \ge 1} \left\lfloor \frac{n}{p^i} \right\rfloor,$$
a finite sum since $\lfloor n/p^i \rfloor = 0$ once $p^i > n$.

**Theorem 2.5 (Bertrand's postulate, half-interval form).** For every integer $n \ge 2$ there exists a prime $p$ with
$$\frac{n}{2} < p \le n, \qquad\text{equivalently}\qquad p \le n < 2p.$$
In Mathlib this is available as `Nat.exists_prime_lt_and_le_two_mul`, applied at $\lfloor n/2 \rfloor$.

A perfect square has an even valuation at every prime: if $m = k^2$ then $v_p(m) = 2\,v_p(k)$ for all $p$. The contrapositive of this observation drives the entire paper.

### 2.1 Two worked examples

It is worth seeing the mechanism concretely before the general proof.

**Example A ($n = 10$).** We have $10! = 3{,}628{,}800$. Bertrand's postulate (applied at $\lfloor 10/2 \rfloor = 5$) supplies a prime in $(5, 10]$; take $p = 7$. The only multiple of $7$ among $1, \dots, 10$ is $7$ itself, and the next one, $14$, exceeds $10$. So $v_7(10!) = \lfloor 10/7 \rfloor + \lfloor 10/49 \rfloor + \cdots = 1 + 0 + \cdots = 1$. Since the exponent of $7$ is odd, $10!$ cannot be a perfect square — and indeed $\sqrt{3{,}628{,}800} \approx 1904.94$ is not an integer. (One may also take $p = 5$: $v_5(10!) = \lfloor 10/5 \rfloor + \lfloor 10/25\rfloor = 2 + 0 = 2$, which is even — so not *every* prime witnesses the obstruction; the point is that the *Bertrand* prime always does.)

**Example B ($n = 15$).** Here $\lfloor 15/2 \rfloor = 7$, and Bertrand gives a prime in $(7, 15]$; take $p = 13$. The multiples of $13$ up to $15$ are just $\{13\}$, and $26 > 15$, so $v_{13}(15!) = 1$. Again the single odd exponent forecloses squareness. The largest prime $\le n$ is always such a witness, because for $n \ge 2$ the largest prime $p \le n$ already satisfies $p > n/2$ (otherwise $2p \le n$ would force a larger prime in $(p, n]$ by Bertrand, a contradiction).

## 3. The Square Obstruction

We first record the abstract obstruction, independent of factorials.

**Lemma 3.1 (Odd-once primes block squares).** Let $p$ be prime and $m \in \mathbb{N}$. If $p \mid m$ but $p^2 \nmid m$, then $m$ is not a perfect square.

*Proof sketch.* Suppose for contradiction $m = k^2$. Since $p$ is prime and $p \mid k^2$, Euclid's lemma gives $p \mid k$, hence $p^2 = p \cdot p \mid k \cdot k = k^2 = m$, contradicting $p^2 \nmid m$. $\qquad\blacksquare$

In Lean this is `not_square_of_prime_dvd_not_sq_dvd`, proved by introducing the witness $k$, deriving $p \mid k$ from `Nat.Prime.dvd_of_dvd_pow`, and concluding $p^2 \mid k^2$ via `pow_dvd_pow_of_dvd`.

## 4. Exact Multiplicity at a Bertrand Prime

The crux is that a Bertrand prime occurs in $n!$ exactly once.

**Lemma 4.1 (Exact multiplicity one).** Let $p$ be prime with $p \le n < 2p$. Then
$$v_p(n!) = 1, \qquad\text{and in particular}\qquad p^2 \nmid n!.$$

*Proof sketch.* By Legendre's formula (Lemma 2.4),
$$v_p(n!) = \sum_{i \ge 1} \left\lfloor \frac{n}{p^i} \right\rfloor.$$
We show only the $i = 1$ term survives.

- **The $i = 1$ term equals $1$.** Since $p \le n$ we have $\lfloor n/p \rfloor \ge 1$. Since $n < 2p$ we have $n/p < 2$, so $\lfloor n/p \rfloor \le 1$. Hence $\lfloor n/p \rfloor = 1$: among $1, 2, \dots, n$ there is exactly one multiple of $p$, namely $p$ itself.
- **All terms $i \ge 2$ vanish.** From $n < 2p \le p \cdot p = p^2$ (using $p \ge 2$), we get $n < p^2 \le p^i$ for $i \ge 2$, so $\lfloor n/p^i \rfloor = 0$.

Therefore $v_p(n!) = 1$. Since $p^2 \mid n!$ would require $v_p(n!) \ge 2$, we conclude $p^2 \nmid n!$. $\qquad\blacksquare$

In Lean (`not_sq_dvd_factorial`) the valuation is computed via `Nat.factorization_def` and `padicValNat_factorial`, the upper cutoff for the log range comes from `Nat.log_lt_of_lt_pow`, and the final non-divisibility is obtained from `Nat.Prime.pow_dvd_iff_le_factorization` together with the bound $\lfloor n/p \rfloor < 2$ (from `Nat.div_mul_le_self`). The combinatorial content is precisely the "first multiple in, second multiple out" observation: the next multiple of $p$ after $p$ is $2p > n$.

## 5. Main Results

**Theorem 5.1 (Factorials are not squares for $n \ge 2$).** For every $n \ge 2$, $n!$ is not a perfect square.

*Proof sketch.* By Bertrand's postulate (Theorem 2.5) applied at $\lfloor n/2 \rfloor$, there is a prime $p$ with $\lfloor n/2 \rfloor < p \le 2\lfloor n/2 \rfloor \le n$, hence $p \le n < 2p$. Then $p \mid n!$ because $p \le n$ (so $p$ is one of the factors; `Nat.dvd_factorial`), while $p^2 \nmid n!$ by Lemma 4.1. By Lemma 3.1, $n!$ is not a perfect square. $\qquad\blacksquare$

This is `factorial_not_square_of_two_le` in Lean. The bound $\lfloor n/2 \rfloor < p \le n$ rearranges to exactly the hypotheses $p \le n$ and $n < 2p$ of Lemma 4.1, discharged by `omega`.

**Theorem 5.2 (Square classification).** For every $n \in \mathbb{N}$,
$$\mathrm{IsSquare}(n!) \iff n \le 1.$$

*Proof sketch.*
($\Rightarrow$) Contrapositive of Theorem 5.1: if $n \ge 2$ then $n!$ is not a square; equivalently, a square factorial forces $n \le 1$.
($\Leftarrow$) For $n \in \{0, 1\}$ we have $n! = 1 = 1^2$, so the witness $k = 1$ works.
$\qquad\blacksquare$

This is `factorial_square_iff_le_one`.

**Theorem 5.3 (Square–triangular classification).** For every $n \in \mathbb{N}$,
$$\big(\mathrm{IsSquare}(n!) \wedge \mathrm{IsTriangular}(n!)\big) \iff n \le 1.$$

*Proof sketch.*
($\Rightarrow$) The conjunction implies $\mathrm{IsSquare}(n!)$, and Theorem 5.2 then yields $n \le 1$. (The triangular hypothesis is not even needed for this direction — squareness alone already forces $n \le 1$.)
($\Leftarrow$) For $n \in \{0, 1\}$, $n! = 1$, and $1 = 1^2$ is a square while $1 = \frac{1 \cdot 2}{2} = T_1$ is triangular; so both witnesses ($k = 1$ and $t = 1$) work.
$\qquad\blacksquare$

This is `factorial_square_triangular_iff_le_one`. The corollary is striking precisely because it shows the *square* constraint is the binding one: the additional triangular requirement is logically redundant on the forward direction.

## 6. The Brocard–Ramanujan Connection

The titular motivation is the **Brocard–Ramanujan problem**: determine all $n$ for which
$$n! + 1 = m^2 \tag{$\star$}$$
for some integer $m$. Solutions $(n, m)$ are called *Brown numbers*; the only known ones are
$$(4, 5): 4! + 1 = 25, \qquad (5, 11): 5! + 1 = 121, \qquad (7, 71): 7! + 1 = 5041.$$
It is conjectured these are the only solutions, verified computationally for $n$ up to roughly $10^{12}$, but the finiteness of the solution set remains **open**.

**Proposition 6.1 (Triangular reformulation).** For $n \ge 1$, the following are equivalent:
1. $n! + 1$ is a perfect square;
2. $n!/8$ is a triangular number (in particular $8 \mid n!$, which holds for all $n \ge 4$).

*Proof sketch.* If $n!/8 = T_y = y(y+1)/2$ then $n! = 4y(y+1) = (2y+1)^2 - 1$, so $n! + 1 = (2y+1)^2$ is an (odd) square. Conversely, if $n! + 1 = m^2$, then since $n!$ is even for $n \ge 2$, $m$ is odd, say $m = 2y + 1$; expanding, $n! = (2y+1)^2 - 1 = 4y^2 + 4y = 8 \cdot \frac{y(y+1)}{2}$, so $n!/8 = T_y$. $\qquad\blacksquare$

Thus the three Brown numbers correspond to three triangular values:
$$\frac{4!}{8} = 3 = T_2, \qquad \frac{5!}{8} = 15 = T_5, \qquad \frac{7!}{8} = 630 = T_{35}.$$
The Brocard–Ramanujan conjecture is exactly the statement that $n \in \{4, 5, 7\}$ are the only $n$ with $n!/8$ triangular.

**Why the valuation method does not transfer.** Our proof of Theorem 5.2 exploits that we know the prime anatomy of $n!$ exactly; the Bertrand prime $p$ has $v_p(n!) = 1$, an odd exponent forbidden in a square. But $\gcd(n!, n! + 1) = 1$: adding $1$ destroys all shared prime structure, so $v_p(n! + 1) = 0$ for that same $p$, and the obstruction evaporates. This is the precise reason the innocuous "$+1$" separates a one-paragraph theorem from a 150-year-old open problem. Equation $(\star)$ is, after the substitution $m = 2y+1$, a question about how often the smooth-but-rigid number $n!$ lands one below a perfect square — a Diophantine question with no known elementary handle.

## 6.5 Historical Context

The study of when factorials meet figurate numbers is old and recurring. Bertrand conjectured his postulate in 1845 after verifying it up to $n = 3{,}000{,}000$; Chebyshev gave the first proof in 1852, and Erdős later popularized a short elementary proof using binomial coefficients. Legendre's formula for $v_p(n!)$ dates to the early nineteenth century and is the standard tool for analyzing the multiplicative structure of factorials. The specific observation that a prime in the top half of $\{1, \dots, n\}$ appears exactly once in $n!$ is folklore, frequently used to prove that the central binomial coefficient $\binom{2n}{n}$ is never a perfect power and that $n!$ is squarefree-obstructed.

Brocard posed the equation $n! + 1 = m^2$ in 1876 and again in 1885; Ramanujan independently raised it in 1913. The three Brown numbers were known to both, and despite extensive computation (most recently to $n$ well beyond $10^{12}$) no fourth solution has appeared. Heuristics based on the density of squares near $n!$ strongly suggest the list is complete, but a proof remains elusive — the problem is a textbook example of a Diophantine equation that is trivial to state, easy to test, and apparently very hard to close. Our contribution is to give the *adjacent* and *fully resolved* statement (about $n!$ rather than $n! + 1$) a clean, machine-checked treatment, and to delineate exactly the structural reason the two problems differ in difficulty.

## 6.6 Computational Verification

The accompanying `demo.py` independently checks the theorems on an initial range. For each $n$ it (i) computes $n!$ exactly, (ii) tests squareness via an integer square root, (iii) tests triangularity via the identity "$m$ triangular $\iff 8m + 1$ is a square," and (iv) exhibits the Bertrand prime $p$ and its valuation $v_p(n!) = 1$. Across $0 \le n \le 15$ the only square (and only square-and-triangular) factorials are $n \in \{0, 1\}$, in agreement with Theorems 5.2–5.3. The script also enumerates Brown numbers, recovering exactly $(4, 5), (5, 11), (7, 71)$ and asserting, for every tested $n$, the equivalence of Proposition 6.1 ($n! + 1$ square $\iff n!/8$ triangular). A companion algorithm, `factorial_is_square`, decides squareness of $n!$ in $O(n)$ primality work *without ever forming the astronomically large integer $n!$* — a direct computational distillation of the proof, since it merely locates the Bertrand prime and reads off the parity of its (always odd) valuation.

## 7. Formalization Notes

All results of Sections 3–5 are formalized in Lean 4 over Mathlib in the file `Catalog/NumberTheory/FactorialNotSquare.lean`, namespace `FactorialNotSquare`. The dependency graph is:

```
not_square_of_prime_dvd_not_sq_dvd   (Lemma 3.1)
not_sq_dvd_factorial                 (Lemma 4.1)
        │  └── Bertrand: Nat.exists_prime_lt_and_le_two_mul (Thm 2.5)
        ▼
factorial_not_square_of_two_le       (Theorem 5.1)
        ▼
factorial_square_iff_le_one          (Theorem 5.2)
        ▼
factorial_square_triangular_iff_le_one (Theorem 5.3)
```

The Lean predicates `IsSquareNat m := ∃ k, m = k^2` and `IsTriangularNat m := ∃ t, m = t*(t+1)/2` match Definitions 2.1–2.2 (natural-number division, exact for triangular numbers). The valuation computation uses `padicValNat_factorial`, `Nat.factorization_def`, `Nat.log_lt_of_lt_pow`, and `Nat.Prime.pow_dvd_iff_le_factorization`; the index arithmetic for the Bertrand prime is discharged by `omega`. Proposition 6.1 is not formalized in this file (it concerns the open problem and is presented as context).

## 8. Applications and Generalizations

The "exact multiplicity one" lemma is a reusable obstruction generator.

- **Higher powers.** Since $v_p(n!) = 1$ for the Bertrand prime, and a perfect $k$-th power requires $k \mid v_q(m)$ for all primes $q$, the same single prime shows $n!$ is never a perfect $k$-th power for any $k \ge 2$ once $n \ge 2$. Squares are the $k = 2$ case.
- **Figurate numbers.** Many figurate shapes (pentagonal, hexagonal) impose congruence or factorization constraints that a lone odd-multiplicity prime can violate; the method extends to ruling these out for large $n$.
- **Structure vs. disguise.** Conceptually, the result is a parable: $n!$ exposes its factorization by construction and is therefore "obstructable," whereas $n! + 1$ hides its factorization. The same tension underlies the hardness assumptions of factorization-based cryptography.

The unifying principle deserves emphasis. Every "rigid shape" a number can take — square, cube, $k$-th power, and many figurate forms — imposes a constraint on the *exponent vector* $(v_2(m), v_3(m), v_5(m), \dots)$ in the prime factorization of $m$. Squares demand all entries even; cubes, all divisible by three; perfect $k$-th powers, all divisible by $k$. Bertrand's postulate hands us a coordinate of this vector that we can pin down exactly for $m = n!$: the Bertrand prime's entry is precisely $1$. A single coordinate equal to $1$ violates *every* divisibility-by-$k$ constraint with $k \ge 2$ simultaneously. Thus one lemma — "exact multiplicity one" — refutes squareness, cubeness, and all higher-power-ness of $n!$ in one stroke, and with light additional congruence bookkeeping it attacks figurate shapes too. This is why we regard Lemma 4.1, rather than any single classification theorem, as the reusable core of the development.

## 9. Discussion and Future Work

The proven theorems are tight and unconditional. The natural frontier is the Brocard–Ramanujan problem and its relatives, which the valuation method alone cannot reach. Four concrete directions:

1. **Bounded computational certificates for Brown numbers.** Replace the open full classification with checked, *bounded* statements ("no Brown numbers for $8 \le n \le N$") packaged as reusable, parameterized certificates, with valuation-based pruning that tests prime-interval residues rather than brute-forcing square roots.
2. **Pell recurrences for square–triangular numbers.** Formalize the classical theory of numbers that are simultaneously square and triangular ($0, 1, 36, 1225, 41616, \dots$) via the Pell equation $x^2 - 2y^2 = 1$ and the recurrence $a_{k+1} = 34a_k - a_{k-1} + 2$, connecting it to the factorial classification proved here.
3. **Cataloging factorial figurate obstructions via prime intervals.** Generalize the exact-multiplicity lemma into a library showing $n!$ is never a perfect $k$-th power and never various nontrivial figurate numbers for large $n$.
4. **Reusable Mathlib lemmas about exact prime occurrence in factorials.** Contribute a polished general lemma `factorization_factorial_eq_one_of_lt_two_mul` (a prime $p$ with $p \le n < 2p$ has $v_p(n!) = 1$) plus corollaries.

## 10. Conclusion

We classified, completely and elementarily, the square and square–triangular factorials: both occur exactly when $n \le 1$. The proof distills to one idea — a Bertrand prime in $(n/2, n]$ divides $n!$ precisely once, and one odd exponent forecloses squareness. The same idea fails by a hair's breadth for $n! + 1$, the Brocard–Ramanujan problem, illuminating exactly where elementary methods end and a famous mystery begins.

## References

- J. Bertrand (1845); P. L. Chebyshev (1852), Bertrand's postulate.
- A. M. Legendre, Legendre's formula for the prime factorization of factorials.
- H. Brocard (1876, 1885); S. Ramanujan (1913), the problem $n! + 1 = m^2$.
