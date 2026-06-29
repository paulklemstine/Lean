# Structural Reduction of the Erdős–Straus Conjecture: Parametric Families, Divisor Inheritance, and a Prime-Core Theorem

**Author:** Aristotle
**Date:** 2026-06-25

## Abstract

The Erdős–Straus conjecture (1948) asserts that for every integer $n \ge 2$ the fraction $\frac{4}{n}$ admits a representation as a sum of three (not necessarily distinct) unit fractions: there exist positive integers $x, y, z$ with $\frac{4}{n} = \frac{1}{x} + \frac{1}{y} + \frac{1}{z}$. We present a complete, self-contained structural treatment built around a single arithmetic bridge that converts denominator-cleared integer identities into genuine unit-fraction representations. Using this bridge, we establish four explicit parametric solution families covering even denominators, multiples of three, denominators $n \equiv 3 \pmod 4$ (Sierpiński), and denominators $n \equiv 5 \pmod 8$ (Komornik). We prove a divisor-inheritance principle stating that solvability is closed under taking multiples, and we correct a common misstatement of this principle by exhibiting that the reverse (divisor) direction fails. Combining the families with divisor inheritance yields the main structural result: the Erdős–Straus conjecture for all $n \ge 2$ reduces to the single residue class of primes $p \equiv 1 \pmod 8$. We give a bounded version of this reduction suitable for finite certification and indicate how it confirms the conjecture for all $2 \le n < 1000$. We close with applications and a discussion of the open prime-core and its connection to quadratic reciprocity.

**Keywords:** Erdős–Straus conjecture, Egyptian fractions, unit fractions, parametric families, divisor inheritance, prime reduction, covering congruences, quadratic residues.

## 1. Introduction

In 1948 Paul Erdős and Ernst G. Straus conjectured that for every integer $n \ge 2$, the rational number $\frac{4}{n}$ can be written as a sum of three positive unit fractions. Despite its elementary statement, the conjecture remains open. It has been verified computationally for all $n$ up to bounds exceeding $10^{17}$, yet a general proof is unknown.

The problem belongs to the venerable tradition of *Egyptian fraction* problems, in which rationals are decomposed into sums of unit fractions $\frac{1}{x}$. This tradition is among the oldest in recorded mathematics: the scribes of ancient Egypt, more than three millennia ago, expressed essentially every fraction as a sum of distinct unit fractions, and the Rhind Mathematical Papyrus preserves an extensive table of decompositions of $\frac{2}{n}$. The Erdős–Straus problem fixes the numerator at $4$ and the number of summands at exactly $3$, and asks for universal solvability. Unlike the strict Egyptian convention, the three unit fractions here need not be distinct; this relaxation is exactly what makes the explicit families below possible, since several of them repeat a denominator.

The conjecture is one of a cluster of related problems. Sierpiński proposed the analogous statement for $\frac{5}{n}$, and Schinzel the general $\frac{a}{n}$ for fixed numerator $a$; all share the same fundamental obstruction structure, in which the bulk of cases yield to elementary identities while a thin set of residues resists. Understanding the Erdős–Straus case in clean structural terms therefore illuminates an entire family of questions.

This paper develops the standard structural theory of the conjecture in a unified, rigorous form. Our contributions are:

1. **An arithmetic bridge** (Theorem 3.1) reducing the rational existence statement to a single polynomial Diophantine identity over $\mathbb{N}$, so that all constructions become purely algebraic verifications.
2. **Four parametric families** (Theorems 4.1–4.4), each a standalone constructive existence proof with no circular dependence on the conjecture.
3. **Divisor inheritance** (Theorem 5.1) together with an explicit correction (Remark 5.2, Theorem 5.3) of a frequently misstated converse.
4. **A prime-core reduction** (Theorems 6.2–6.4): the conjecture for all $n \ge 2$ follows from its truth for primes $p \equiv 1 \pmod 8$, in both an unbounded and a finite-verification form.
5. **A finite certification** confirming the conjecture for all $2 \le n < 1000$.

Throughout, $\mathbb{N}$ denotes the nonnegative integers and $\mathbb{N}^{+}$ (written $\mathbb{Z}_{>0}$ where convenient) the positive integers. We write $a \equiv b \pmod m$ for congruence and $m \mid n$ for divisibility.

## 2. The central definition

**Definition 2.1 (Erdős–Straus solution).** For $n \in \mathbb{N}$, we say $n$ *has an Erdős–Straus solution*, written $\mathrm{ES}(n)$, if there exist positive integers $x, y, z$ such that
$$\frac{4}{n} = \frac{1}{x} + \frac{1}{y} + \frac{1}{z}.$$

The Erdős–Straus conjecture is the assertion that $\mathrm{ES}(n)$ holds for every integer $n \ge 2$. Note the summands need not be distinct; repetition is permitted, and several of the families below exploit this.

## 3. The arithmetic bridge

The first step is to eliminate denominators so that every construction reduces to verifying an integer polynomial identity.

**Theorem 3.1 (Arithmetic bridge, `es_of_nat`).** Let $n, x, y, z$ be positive integers satisfying the cleared identity
$$4 \, (xyz) = n \,(xy + yz + zx). \tag{$\ast$}$$
Then $\mathrm{ES}(n)$ holds, witnessed by $(x, y, z)$.

*Proof sketch.* Since $x, y, z, n > 0$, all of $x, y, z, n$ are nonzero in $\mathbb{Q}$. Casting $(\ast)$ into $\mathbb{Q}$ gives $4 (xyz) = n(xy+yz+zx)$ as a rational identity. Clearing denominators in the target equation $\frac{4}{n} = \frac{1}{x}+\frac{1}{y}+\frac{1}{z}$ via $\texttt{field\_simp}$ produces exactly $(\ast)$ up to reassociation; the polynomial normal forms agree, so the rational equation holds. $\square$

The power of Theorem 3.1 is that it converts the *analytic-looking* problem (an equality of rationals) into an *algebraic* one (a single multiplication identity). To prove $\mathrm{ES}(n)$ for a family of $n$, it now suffices to exhibit a parametric triple $(x, y, z)$ and check $(\ast)$ as a polynomial identity in the parameter — a mechanical task.

## 4. Parametric solution families

Each family is a self-contained constructive proof; none invokes $\mathrm{ES}$ of any other number, so there is no circular dependence on the conjecture.

**Theorem 4.1 (Even denominators, `es_even`).** If $n$ is even and $n \ge 2$, then $\mathrm{ES}(n)$ holds. Writing $n = 2m$ with $m \ge 1$,
$$\frac{4}{n} = \frac{1}{m} + \frac{1}{m+1} + \frac{1}{m(m+1)}.$$

*Proof sketch.* Take $(x, y, z) = (m, m+1, m(m+1))$. The cleared identity $(\ast)$ reads $4 \cdot m(m+1)\cdot m(m+1) = 2m\big(m(m+1) + (m+1)m(m+1) + m(m+1)m\big)$, which simplifies to a polynomial identity in $m$ verifiable by ring normalization. Conceptually, $\frac{1}{m}+\frac{1}{m+1} = \frac{2m+1}{m(m+1)}$, and adding the corrective sliver $\frac{1}{m(m+1)}$ yields $\frac{2m+2}{m(m+1)} = \frac{2}{m} = \frac{4}{2m}$. $\square$

**Theorem 4.2 (Multiples of three, `es_three_dvd`).** If $3 \mid n$ and $n \ge 1$, then $\mathrm{ES}(n)$ holds. Writing $n = 3m$ with $m \ge 1$,
$$\frac{4}{n} = \frac{1}{m+1} + \frac{1}{m(m+1)} + \frac{1}{3m}.$$

*Proof sketch.* Take $(x, y, z) = (m+1, m(m+1), 3m)$. Then $\frac{1}{m+1}+\frac{1}{m(m+1)} = \frac{m+1}{m(m+1)} = \frac{1}{m}$, and $\frac{1}{m}+\frac{1}{3m} = \frac{4}{3m}$. The cleared identity $(\ast)$ holds by ring normalization in $m$. $\square$

**Theorem 4.3 (Sierpiński's family, `es_three_mod_four`).** If $n \equiv 3 \pmod 4$, then $\mathrm{ES}(n)$ holds. Writing $n + 1 = 4k$ (so $k \ge 1$ and $n \ge 3$),
$$\frac{4}{n} = \frac{1}{k} + \frac{1}{2kn} + \frac{1}{2kn}.$$

*Proof sketch.* Take $(x, y, z) = (k, 2kn, 2kn)$. The cleared identity $(\ast)$ becomes
$$4 \cdot k \cdot (2kn)^2 = n\big(k\cdot 2kn + 2kn\cdot 2kn + 2kn\cdot k\big),$$
i.e. $16 k^3 n^2 = n(4k^2 n + 4k^2 n^2) = 4k^2 n^2(1 + n)$. Substituting $n + 1 = 4k$ gives $4k^2 n^2 \cdot 4k = 16 k^3 n^2$, an exact match. Over $\mathbb{Z}$ this is the linear combination of the hypothesis $n + 1 = 4k$ with coefficient $-4k^2 n^2$. $\square$

**Theorem 4.4 (Komornik's family, `es_five_mod_eight`).** If $n \equiv 5 \pmod 8$, then $\mathrm{ES}(n)$ holds. Writing $n + 3 = 8b$ (so $b \ge 1$ and $n \ge 5$),
$$\frac{4}{n} = \frac{1}{2b} + \frac{1}{2bn} + \frac{1}{bn}.$$

*Proof sketch.* Take $(x, y, z) = (2b, 2bn, bn)$. The cleared identity $(\ast)$ reduces, after substituting $n + 3 = 8b$, to a polynomial identity expressible as the linear combination of $n + 3 = 8b$ with coefficient $-2 b^2 n^2$ over $\mathbb{Z}$. Conceptually the three pieces sum to $\frac{n + 3}{2bn} = \frac{8b}{2bn} = \frac{4}{n}$. $\square$

**Remark 4.5 (Coverage of residues mod 8).** Among odd $n$, the residues $3$ and $7 \pmod 8$ both satisfy $n \equiv 3 \pmod 4$ and so are covered by Theorem 4.3; the residue $5 \pmod 8$ is covered by Theorem 4.4. Together with the even case (Theorem 4.1), the *only* uncovered residue among odd numbers is $1 \pmod 8$. This observation drives the reduction in Section 6.

## 4a. Worked examples

It is instructive to see the families produce concrete witnesses, each checkable by a single multiplication.

- **Even, $n = 10$:** here $m = 5$, giving $(x,y,z) = (5, 6, 30)$ and $\frac{4}{10} = \frac{1}{5} + \frac{1}{6} + \frac{1}{30}$. The cleared identity reads $4\cdot 5\cdot 6\cdot 30 = 3600 = 10\,(30 + 180 + 150) = 10\cdot 360$.
- **Multiple of three, $n = 21$:** here $m = 7$, giving $(8, 56, 21)$ and $\frac{4}{21} = \frac{1}{8} + \frac{1}{56} + \frac{1}{21}$.
- **Sierpiński, $n = 11$ ($11 \equiv 3 \bmod 4$):** here $n + 1 = 12 = 4\cdot 3$, so $k = 3$ and $(3, 66, 66)$, giving $\frac{4}{11} = \frac{1}{3} + \frac{1}{66} + \frac{1}{66}$.
- **Komornik, $n = 13$ ($13 \equiv 5 \bmod 8$):** here $n + 3 = 16 = 8\cdot 2$, so $b = 2$ and $(4, 52, 26)$, giving $\frac{4}{13} = \frac{1}{4} + \frac{1}{52} + \frac{1}{26}$.
- **Open core, $n = 17$ ($17 \equiv 1 \bmod 8$):** no family applies; a short search yields, for instance, $(5, 30, 510)$, since $\frac{4}{17} = \frac{1}{5} + \frac{1}{30} + \frac{1}{510}$. This is the smallest denominator at which the structural families fall silent and an explicit witness must be supplied.

The contrast between the first four (formulaic) examples and the last (searched) one is the entire story of the conjecture in miniature.

## 5. Divisor inheritance

Solvability of the Erdős–Straus equation propagates upward through divisibility.

**Theorem 5.1 (Divisor inheritance, `es_of_dvd`).** If $\mathrm{ES}(m)$ holds, $m \mid n$, and $n > 0$, then $\mathrm{ES}(n)$ holds.

*Proof sketch.* Write $n = km$ with $k > 0$ (and $m > 0$ since $n > 0$). Let $(x, y, z)$ witness $\mathrm{ES}(m)$, so $\frac{4}{m} = \frac{1}{x}+\frac{1}{y}+\frac{1}{z}$. Scaling every denominator by $k$ gives
$$\frac{1}{kx} + \frac{1}{ky} + \frac{1}{kz} = \frac{1}{k}\Big(\frac{1}{x}+\frac{1}{y}+\frac{1}{z}\Big) = \frac{1}{k}\cdot \frac{4}{m} = \frac{4}{km} = \frac{4}{n},$$
so $(kx, ky, kz)$ witnesses $\mathrm{ES}(n)$. Formally one clears denominators in both equations and matches polynomial normal forms. $\square$

**Remark 5.2 (The reverse direction is false).** A frequent misstatement asserts that $\mathrm{ES}(n)$ and $d \mid n$ imply $\mathrm{ES}(n/d)$. This is false. Take $n = 4$ and $d = 4$; then $n/d = 1$ and $\frac{4}{1} = 4$, which cannot be a sum of three unit fractions because the maximum such sum is $\frac{1}{1}+\frac{1}{1}+\frac{1}{1} = 3 < 4$. Solvability is monotone with respect to *multiples*, not divisors.

**Theorem 5.3 (Corrected converse, `es_of_div_dvd`).** If $d \mid n$, $n > 0$, and $\mathrm{ES}(n/d)$ holds, then $\mathrm{ES}(n)$ holds.

*Proof sketch.* Since $d \mid n$, the quotient $n/d$ divides $n$. Apply Theorem 5.1 with $m = n/d$. $\square$

## 6. Reduction to primes $\equiv 1 \pmod 8$

We now combine the families with divisor inheritance to localize the entire difficulty of the conjecture.

**Lemma 6.1 (Prime dichotomy, `es_prime`).** Let $p$ be prime, and suppose that $\mathrm{ES}(p)$ holds whenever $p \equiv 1 \pmod 8$. Then $\mathrm{ES}(p)$ holds for every prime $p$.

*Proof sketch.* If $2 \mid p$ then $p = 2$, handled by the even family (Theorem 4.1). Otherwise $p$ is odd, so $p \bmod 8 \in \{1, 3, 5, 7\}$. The case $p \equiv 1$ is the hypothesis; $p \equiv 3$ and $p \equiv 7$ both give $p \equiv 3 \pmod 4$, handled by Sierpiński (Theorem 4.3); $p \equiv 5$ is handled by Komornik (Theorem 4.4). $\square$

**Theorem 6.2 (Prime-core reduction, `erdosStraus_reduction`).** Suppose $\mathrm{ES}(p)$ holds for every prime $p \equiv 1 \pmod 8$. Then $\mathrm{ES}(n)$ holds for every integer $n \ge 2$.

*Proof sketch.* Let $n \ge 2$ and let $p = \mathrm{minFac}(n)$ be its smallest prime factor, which exists and is prime since $n \ge 2$. By Lemma 6.1, $\mathrm{ES}(p)$ holds. Since $p \mid n$ and $n > 0$, divisor inheritance (Theorem 5.1) yields $\mathrm{ES}(n)$. $\square$

Theorem 6.2 is the central structural result: **the full Erdős–Straus conjecture is equivalent to its restriction to primes $p \equiv 1 \pmod 8$.** Every other case is settled unconditionally by the explicit families.

**Theorem 6.3 (Bounded reduction, `erdosStraus_reduction_bounded`).** Fix $N \in \mathbb{N}$. Suppose $\mathrm{ES}(p)$ holds for every prime $p \equiv 1 \pmod 8$ with $p < N$. Then $\mathrm{ES}(n)$ holds for every integer $n$ with $2 \le n < N$.

*Proof sketch.* As in Theorem 6.2, take $p = \mathrm{minFac}(n)$. Then $p \le n < N$, so $p < N$, and $p \equiv 1 \pmod 8$ is covered by hypothesis (other residues by Lemma 6.1's families). Lift via divisor inheritance. $\square$

**Theorem 6.4 (Finite verification below 1000, `erdosStraus_lt_1000`).** $\mathrm{ES}(n)$ holds for every integer $n$ with $2 \le n < 1000$.

*Proof sketch.* Apply Theorem 6.3 with $N = 1000$. It remains to certify $\mathrm{ES}(p)$ for each prime $p \equiv 1 \pmod 8$ below $1000$ — namely $p \in \{17, 41, 73, 89, 97, 113, 137, 193, 233, 241, 257, \ldots\}$. For each such $p$ a witness triple $(x, y, z)$ is exhibited and the cleared identity $(\ast)$ is checked by direct computation via the bridge (Theorem 3.1). All non-$1 \pmod 8$ residues, and all composites, are handled by the families and divisor inheritance. $\square$

## 7. Algorithms

The structural theory yields two natural algorithms.

**Algorithm A (Structured solver).** Given $n \ge 2$, return a witness triple by case analysis:
1. If $n$ even, return $(m, m+1, m(m+1))$ with $m = n/2$.
2. Else if $3 \mid n$, return $(m+1, m(m+1), 3m)$ with $m = n/3$.
3. Else if $n \equiv 3 \pmod 4$, return $(k, 2kn, 2kn)$ with $k = (n+1)/4$.
4. Else if $n \equiv 5 \pmod 8$, return $(2b, 2bn, bn)$ with $b = (n+3)/8$.
5. Else ($n$ has all prime factors $\equiv 1 \pmod 8$ and itself $\equiv 1 \pmod 8$): reduce to $p = \mathrm{minFac}(n)$ and look up / search a witness for the prime, then scale by $n/p$.

This runs in $O(\sqrt{n})$ time dominated by trial factorization in the final case; the first four cases are $O(1)$.

**Algorithm B (Bounded certifier).** To certify $\mathrm{ES}(n)$ for all $2 \le n < N$: enumerate primes $p \equiv 1 \pmod 8$ below $N$, brute-force a witness for each by bounded search over $x$, verify $(\ast)$, and tabulate. All other $n$ are covered by the families and lifting. The witness search for a single prime $p$ is $O(p^{1+\epsilon})$ in the worst case but typically finds a small witness almost immediately.

## 8. Applications and significance

**Finite certification.** Theorem 6.3 reduces confirming the conjecture on $[2, N)$ from $N$ cases to roughly $\frac{N}{8\ln N}$ prime cases (by the prime number theorem applied to the arithmetic progression $1 \pmod 8$, which by Dirichlet's theorem and the prime number theorem for arithmetic progressions contains a positive proportion $\frac{1}{\varphi(8)} = \frac{1}{4}$ of all primes). Each surviving case is a one-line identity check. Concretely, of the roughly $168$ primes below $1000$, only about a quarter lie in the class $1 \pmod 8$ — explicitly $17, 41, 73, 89, 97, 113, 137, 193, 233, 241, 257, 281, 313, 337, 353, 401, 409, 433, 449, 457, \ldots$ — and these are the *only* values for which a witness must be supplied by hand; everything else follows from the families and divisor inheritance. This is the engine behind all large-scale empirical verifications.

**Localization of difficulty.** The reduction provides a precise diagnosis: the conjecture's entire unresolved content lives in a single arithmetic progression. Any constructive scheme covering primes $\equiv 1 \pmod 8$ closes the problem unconditionally.

**A reusable algebraic toolkit.** The bridge (Theorem 3.1) plus the "two natural pieces and a corrective sliver" template recur across Egyptian-fraction problems (e.g. the analogous $\frac{5}{n}$ conjecture of Sierpiński). The same scaffolding transfers directly.

## 9. Discussion: why $1 \pmod 8$ is hard

The four families exploit cheap algebraic identities tied to small moduli. The residue $1 \pmod 8$ is precisely the class where $2$ is a quadratic residue modulo $p$ (by the supplement to quadratic reciprocity, $2$ is a QR mod an odd prime $p$ iff $p \equiv \pm 1 \pmod 8$). This changes the solvability of the auxiliary congruences governing whether a clean parametric construction exists. Classical work of Mordell handles all primes outside a sparse set of residues modulo products of small primes via covering congruences, but no covering system is known to capture every prime $\equiv 1 \pmod 8$. The obstruction is genuinely arithmetic: it concerns representability conditions controlled by quadratic characters, not a mere failure of search.

To see the mechanism more concretely, consider seeking a solution of a fixed structural shape, say with one denominator divisible by $n$ and the rest controlled by a parameter. Substituting such an ansatz into the cleared identity $(\ast)$ and reducing modulo $n$ produces a congruence condition whose solvability is governed by whether certain small integers are quadratic residues modulo the prime $p$. For $p \equiv 3 \pmod 4$ the relevant condition involves $-1$, which is a non-residue, and the Sierpiński shape always closes; for $p \equiv 5 \pmod 8$ the relevant condition involves $2$, and the Komornik shape closes. For $p \equiv 1 \pmod 8$ both $-1$ and $2$ become residues, simultaneously *removing* the arithmetic leverage that the other two families relied upon. The conjecture's difficulty is thus not an accident of presentation but a reflection of which quadratic characters are trivial in this class.

It is worth emphasizing what is *not* in doubt. For any individual $n$, the conjecture is a decidable, indeed easily verifiable, statement: a witness, once found, certifies $\mathrm{ES}(n)$ by a single multiplication. The conjecture's open status is entirely about *uniformity* — the absence of a single construction, or finite family of constructions, provably covering every prime $\equiv 1 \pmod 8$. The structural results of this paper sharpen exactly this gap: they show that uniformity over all $n \ge 2$ is logically equivalent to uniformity over this one arithmetic progression.

## 10. Future work

Four directions stand out, each building directly on the present scaffolding.

1. **Covering congruences for $1 \pmod 8$.** Formalize Mordell's covering-congruence constructions, which solve $\frac{4}{p}$ for all $p$ outside a sparse residue set modulo small moduli. The predicate, witness-verification idioms, and divisor inheritance developed here are exactly the reusable infrastructure such a formalization needs.
2. **Computational certification at scale.** Since $\mathrm{ES}(n)$ is witnessed by a finite triple whose correctness is a single rational identity, a verified search procedure can emit witnesses for enormous ranges and check them mechanically, turning empirical tables (confirmed beyond $10^{17}$) into certified theorems for explicit bounds. Theorem 6.4 demonstrates the pattern end to end; scaling it is an engineering task.
3. **A parametrized solver.** The four families are instances of a few algebraic identities — the $\frac{1}{a} + \frac{1}{an}$ split and its halving, and the $\frac{n+3}{2na}$ collapse. A single lemma taking residue data and returning a witness would yield all four families as corollaries and expose precisely which algebraic degrees of freedom remain unused for $1 \pmod 8$.
4. **Connection to quadratic reciprocity.** The obstruction at $p \equiv 1 \pmod 8$ is governed by congruences that quadratic reciprocity controls. Phrasing the open core via Legendre symbols and character theory could recast it as a clean representability statement rather than a raw existential over triples.

## 11. Conclusion

We have given a complete structural treatment of the Erdős–Straus conjecture: an arithmetic bridge converting it to integer identities, four explicit solution families, a divisor-inheritance principle (with its converse correctly stated), and a prime-core reduction showing that the conjecture for all $n \ge 2$ follows from its truth for primes $p \equiv 1 \pmod 8$. A bounded version certifies all $2 \le n < 1000$. The work isolates the conjecture's entire difficulty in one arithmetic progression and assembles the precise toolkit needed to attack it.

## References

The conjecture originates with P. Erdős and E. G. Straus (1948). The residue families are due to W. Sierpiński and V. Komornik; the covering-congruence approach is due to L. J. Mordell. The supplement to the law of quadratic reciprocity governs the quadratic character of $2$. (Full bibliographic details are standard and omitted here in keeping with the self-contained format.)
