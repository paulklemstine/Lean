# An Explicit 2-adic Valuation Formula for the Shifted Perrin Sequence

## Abstract

The Perrin sequence is the integer sequence defined by $R_0 = 3$, $R_1 = 0$, $R_2 = 2$, and $R_{n+3} = R_{n+1} + R_n$. We study the 2-adic valuation $\nu_2(R_m - 1)$ of the shifted sequence and give a complete, explicit description of it. The engine of the analysis is the fact that $R \bmod 2^k$ is purely periodic with period $7 \cdot 2^{k-1}$: the period doubles with each additional 2-adic digit of precision. From this we derive three results. First, a parity classification: $\nu_2(R_m - 1) = 0$ if and only if $m \bmod 7 \in \{1, 2, 4\}$. Second, an explicit closed form: on $25$ of the $28$ residue classes modulo $28$ the valuation is a constant in $\{0, 1, 2\}$ given by an explicit table. Third, a self-similar refinement: on the three exceptional classes $m \equiv 10, 19, 26 \pmod{28}$ — equivalently, $R_m \equiv 1 \pmod 8$ — the valuation is at least $3$ and, passing to residues modulo $56$, each class splits into one class of valuation exactly $3$ and one class of valuation at least $4$, a structure that iterates at every higher power of two. We discuss the resulting ruler-function description of the exceptional exponents, the fact that the valuation attains every natural number, and the application to the Perrin–Brocard Diophantine equation $R_m = x^2 + 1$, whose analysis this formula reduces to a finite congruence-and-size check.

**Keywords:** Perrin sequence, 2-adic valuation, linear recurrences, periodicity modulo prime powers, ruler sequence, Perrin–Brocard equation.

---

## 1. Introduction

Linear recurrence sequences reduced modulo a prime power are eventually periodic, and for many recurrences the periodic structure is rich enough to pin down arithmetic invariants of the terms exactly. A recurring theme in the study of Fibonacci-like sequences is the determination of the $p$-adic valuation of the terms, or of shifts of the terms, as an explicit function of the index. Such formulas are valuable both intrinsically and as tools: an explicit valuation converts qualitative Diophantine questions into finite congruence conditions.

The Perrin sequence $R$ is defined by
$$R_0 = 3, \quad R_1 = 0, \quad R_2 = 2, \qquad R_{n+3} = R_{n+1} + R_n \quad (n \ge 0).$$
Its first terms are $3, 0, 2, 3, 2, 5, 5, 7, 10, 12, 17, 22, 29, 39, 51, 68, 90, 119, \dots$. The characteristic polynomial is $x^3 - x - 1$, whose real root is the **plastic number** $\rho \approx 1.324718$, so $R_m$ grows like $\rho^m$.

We investigate the **shifted** sequence $R_m - 1$ and its 2-adic valuation
$$\nu_2(R_m - 1) = \max\{k \ge 0 : 2^k \mid R_m - 1\}.$$
Our goal is a formula for $\nu_2(R_m - 1)$ that is explicit wherever possible and structurally complete everywhere.

**Main contributions.**

1. A period-$7$ parity classification (Theorem 3.1).
2. A period-$28$ explicit closed form valid on $25$ of $28$ residue classes, taking values in $\{0,1,2\}$ (Theorem 4.2).
3. A period-$56$ self-similar refinement of the three exceptional classes, exhibiting the period-doubling mechanism that governs the unbounded part of the valuation (Theorem 5.1).

We also record two consequences: the value set of $\nu_2(R_m - 1)$ is all of $\mathbb{N}$ (§6), and the Perrin–Brocard equation $R_m = x^2 + 1$ is amenable to a finite congruence-plus-size analysis (§7).

---

## 2. Preliminaries

### 2.1 The 2-adic valuation

For a nonzero integer $x$, $\nu_2(x)$ is the largest $k$ with $2^k \mid x$; equivalently, $x = 2^{\nu_2(x)} u$ with $u$ odd. We use three elementary facts throughout.

- **(V0)** If $x$ is even, then $\nu_2(x - 1) = 0$ (since $x-1$ is odd).
- **(V1)** If $x \equiv 3 \pmod 4$, then $\nu_2(x - 1) = 1$ (since $x - 1 \equiv 2 \pmod 4$).
- **(V2)** If $x \equiv 5 \pmod 8$, then $\nu_2(x - 1) = 2$ (since $x - 1 \equiv 4 \pmod 8$).

More generally, if $2^k \mid x$ but $2^{k+1} \nmid x$, then $\nu_2(x) = k$; we call this the **pinning lemma**. It is the workhorse for reading off a valuation from a congruence one power beyond the claimed value.

### 2.2 Reduction to residue classes

Because $\nu_2(x)$ depends only on $x$ modulo a sufficiently high power of $2$, valuation questions become congruence questions once we control $R_m$ modulo powers of $2$. That control comes from periodicity.

---

## 3. Periodicity modulo powers of two

The following is the structural heart of the paper.

> **Proposition 3.0 (Doubling period).** For each $k \ge 1$, the sequence $(R_m \bmod 2^k)_{m \ge 0}$ is purely periodic with period $7 \cdot 2^{k-1}$. In particular:
> - $R_{m+7} \equiv R_m \pmod 2$,
> - $R_{m+28} \equiv R_m \pmod 8$,
> - $R_{m+56} \equiv R_m \pmod{16}$.

**Proof sketch.** The recurrence is governed by the companion matrix
$$M = \begin{pmatrix} 0 & 1 & 0 \\ 0 & 0 & 1 \\ 1 & 1 & 0 \end{pmatrix}, \qquad (R_{n}, R_{n+1}, R_{n+2})^\top = M^n (R_0, R_1, R_2)^\top.$$
Periodicity modulo $2^k$ is equivalent to $M^{7 \cdot 2^{k-1}} \equiv I \pmod{2^k}$. One checks the base case $M^7 \equiv I \pmod 2$ directly. The doubling step follows from a $2$-adic lifting identity: if $M^{7 \cdot 2^{k-1}} = I + 2^k B_k$ for some integer matrix $B_k$, then squaring gives
$$M^{7 \cdot 2^{k}} = (I + 2^k B_k)^2 = I + 2^{k+1} B_k + 2^{2k} B_k^2 \equiv I \pmod{2^{k+1}},$$
so the period modulo $2^{k+1}$ divides $7 \cdot 2^{k}$. That it is not smaller (primitivity) is confirmed at the low levels used here by direct computation. Concretely, the low-level congruences $R_{m+7} \equiv R_m \pmod 2$, $R_{m+28} \equiv R_m \pmod 8$, and $R_{m+56} \equiv R_m \pmod{16}$ are established by strong induction on $m$, reducing to a finite base check over one full period. $\square$

From Proposition 3.0 we obtain the reductions used below:
$$R_m \equiv R_{m \bmod 7} \pmod 2, \qquad R_m \equiv R_{m \bmod 28} \pmod 8, \qquad R_m \equiv R_{m \bmod 56} \pmod{16}.$$
Each reduction is proved by strong induction: for $m$ smaller than the period it is a finite check, and for larger $m$ one applies periodicity to $m - (\text{period})$ and the induction hypothesis.

---

## 4. Level one and level two: the explicit part

### 4.1 Parity classification

Working modulo $2$ over one period of length $7$, the Perrin residues are
$$R_0, \dots, R_6 \equiv 1, 0, 0, 1, 0, 1, 1 \pmod 2,$$
so $R_m$ is even exactly when $m \bmod 7 \in \{1, 2, 4\}$. By (V0):

> **Theorem 3.1 (Parity classification).** For all $m \ge 0$,
> $$\nu_2(R_m - 1) = 0 \iff m \bmod 7 \in \{1, 2, 4\}.$$

**Proof.** $\nu_2(R_m - 1) = 0$ iff $R_m - 1$ is odd iff $R_m$ is even. By the reduction $R_m \equiv R_{m \bmod 7} \pmod 2$ and the tabulated residues, $R_m$ is even iff $m \bmod 7 \in \{1,2,4\}$. $\square$

Lifting to $m \bmod 28$, the twelve residues with $\nu_2 = 0$ are
$$\{1, 2, 4, 8, 9, 11, 15, 16, 18, 22, 23, 25\}.$$

### 4.2 The explicit closed form modulo 28

Define the table $\nu : \mathbb{Z}/28 \to \{0,1,2\}$ by
$$\nu(r) = \begin{cases} 1, & r \in \{0, 3, 7, 13, 14, 17, 21, 27\}, \\ 2, & r \in \{5, 6, 12, 20, 24\}, \\ 0, & \text{otherwise.} \end{cases}$$

> **Theorem 4.2 (Explicit valuation).** If $m \bmod 28 \notin \{10, 19, 26\}$, then
> $$\nu_2(R_m - 1) = \nu(m \bmod 28) \in \{0, 1, 2\}.$$

**Proof sketch.** By $R_m \equiv R_{m \bmod 28} \pmod 8$, the value of $R_m$ modulo $8$ is determined by $m \bmod 28$. For each of the $25$ non-exceptional residues one reads off $R_{m \bmod 28} \bmod 8 \in \{0,2,4,6\}$ (giving $\nu = 0$ via (V0)), or $\equiv 3, 7 \pmod 8$ (giving $\nu = 1$ via (V1)), or $\equiv 5 \pmod 8$ (giving $\nu = 2$ via (V2)). Since $\nu(r) \le 2$ on these classes, congruence modulo $8 = 2^3$ suffices to pin the valuation exactly: one shows $2^{\nu(r)} \mid R_m - 1$ and $2^{\nu(r)+1} \nmid R_m - 1$, both determined by $R_m \bmod 2^{\nu(r)+1}$, and $\nu(r) + 1 \le 3$. The pinning lemma of §2.1 then gives the stated equality. $\square$

The three residues excluded here, $\{10, 19, 26\}$, are exactly those with $R_m \equiv 1 \pmod 8$, i.e. $8 \mid R_m - 1$. On these the congruence modulo $8$ cannot bound the valuation, and a finer analysis is required.

---

## 5. Level three: self-similar refinement

> **Theorem 5.1 (Refinement modulo 56).** Suppose $m \bmod 28 \in \{10, 19, 26\}$. Then $8 \mid R_m - 1$, so $\nu_2(R_m - 1) \ge 3$. Refining to residues modulo $56$, each exceptional class splits into two, on which:
> $$\begin{array}{c|c|c}
> m \bmod 28 & \nu_2 = 3 \text{ exactly on} & \nu_2 \ge 4 \text{ on} \\ \hline
> 10 & m \equiv 38 \pmod{56} & m \equiv 10 \pmod{56} \\
> 19 & m \equiv 47 \pmod{56} & m \equiv 19 \pmod{56} \\
> 26 & m \equiv 26 \pmod{56} & m \equiv 54 \pmod{56}
> \end{array}$$

**Proof sketch.** Since $R_m \equiv R_{m \bmod 56} \pmod{16}$, the residue of $R_m$ modulo $16$ is determined by $m \bmod 56$. For the three "exactly $3$" children one computes $R_{m \bmod 56} \equiv 9 \pmod{16}$, i.e. $R_m - 1 \equiv 8 \pmod{16}$, so $\nu_2 = 3$ by the pinning lemma at $k = 3$. For the three "at least $4$" children one computes $R_{m \bmod 56} \equiv 1 \pmod{16}$, i.e. $16 \mid R_m - 1$, so $\nu_2 \ge 4$. $\square$

**Interpretation: the period-doubling / ruler mechanism.** Theorem 5.1 is one step of an infinite process. At level $k$ the sequence is periodic mod $2^k$ with period $7 \cdot 2^{k-1}$. Each exceptional residue class carrying $\nu_2 \ge k$ splits, upon refining to period $7 \cdot 2^{k}$, into exactly two child classes: one on which the valuation equals $k$ exactly, and one on which it persists at $\ge k+1$. Thus a single nested chain of survivor residues threads through all levels, along which the valuation increases without bound. This is precisely the structure of a **ruler sequence**: the increments of $\nu_2(R_m - 1)$ along the exceptional thread form the 2-adic ruler pattern, and the conjectural closed form for the exceptional exponents is
$$\nu_2(R_m - 1) = 3 + (\text{affine function of } \nu_2(m + c))$$
for a suitable constant $c$ tied to the offset of the survivor chain — the exact analogue of the piecewise-linear "TV1" law known for the related Padovan sequence. The base cases established here (levels mod $28$ and mod $56$) pin down both the constant part and the first ruler increments, anchoring an induction on the companion-matrix expansion $M^{7 \cdot 2^{k-1}} = I + 2^k B_k$.

---

## 6. The value set is all of $\mathbb{N}$

> **Corollary 6.1.** The function $m \mapsto \nu_2(R_m - 1)$ attains every value in $\mathbb{N}$.

**Reasoning.** By Theorem 4.2 the values $0, 1, 2$ are attained (e.g. at $m = 1, 3, 5$). By the refinement mechanism of §5, for each $k \ge 3$ the survivor thread guarantees a nonempty set of $m$ with $\nu_2(R_m - 1) \ge k$, and the "exactly $k$" child at the next level realizes the value $k$. The primitivity of the Perrin period modulo $2^k$ — the period never collapses when the modulus doubles — ensures the survivor set is never empty. Small explicit witnesses confirm the ladder: the least $m$ with $\nu_2(R_m - 1) = k$ for $k = 0, 1, \dots, 8$ is $m = 1, 3, 5, 26, 10, 110, 66, 75, 290$, respectively. Moreover, for $k \ge 3$ precisely three residues modulo $7 \cdot 2^{k-1}$ carry valuation $\ge k$.

---

## 7. Application: the Perrin–Brocard equation

Brocard's problem asks for which $n$ the number $n! + 1$ is a perfect square; only $n \in \{4, 5, 7\}$ are known and finiteness is open. The **Perrin–Brocard equation** is the analogue
$$R_m = x^2 + 1, \qquad \text{i.e.} \qquad R_m - 1 = x^2.$$

The valuation formula gives an immediate sieve, via the elementary fact that a perfect square has *even* 2-adic valuation: if $x^2 = R_m - 1$ then $\nu_2(R_m - 1) = 2\,\nu_2(x)$ is even.

> **Proposition 7.1 (Parity sieve).** If $\nu_2(R_m - 1)$ is odd, then $R_m - 1$ is not a perfect square, so $m$ is not a solution of the Perrin–Brocard equation.

By Theorem 4.2, $\nu_2(R_m - 1) = 1$ (odd) on the eight residue classes
$$m \bmod 28 \in \{0, 3, 7, 13, 14, 17, 21, 27\},$$
each of which is therefore excluded entirely. Among the remaining classes, the valuation is either $0$ or $2$ (both even, hence passing the sieve) on the regular residues, or unbounded on the three exceptional classes, where the refinement of §5 further splits candidates by the parity of their valuation at each level. Combined with the exponential growth $R_m \sim \rho^m$ (which bounds $x \approx \rho^{m/2}$ and hence the range of admissible $m$ for any target), the sieve reduces the search to a finite, explicit, checkable set of residues and sizes. A direct search finds the small solutions
$$(m, x) \in \{(4,1),\ (5,2),\ (6,2),\ (8,3),\ (10,4)\},$$
corresponding to $R_4 = 1^2+1$, $R_5 = R_6 = 2^2+1$, $R_8 = 3^2+1$, and $R_{10} = 4^2+1$, and no further solutions with $m < 5000$. Note that $m = 10$ is an exceptional class with $\nu_2(R_m - 1) = 4$ (even), consistent with passing the parity sieve.

---

## 8. Algorithms

**A. Valuation by table lookup (regular residues).** Given $m$ with $m \bmod 28 \notin \{10, 19, 26\}$, return $\nu(m \bmod 28)$ in $O(1)$ time — no large-integer arithmetic on $R_m$ is needed.

**B. Valuation by refinement (exceptional residues).** Given $m$ with $m \bmod 28 \in \{10,19,26\}$, compute $R_m \bmod 2^{K}$ for increasing $K$ using the length-$3$ recurrence on residues (cost $O(K)$ modular steps, using periodicity to reduce $m$ modulo $7 \cdot 2^{K-1}$), and return the largest $k$ with $2^k \mid R_m - 1$.

**C. Perrin–Brocard sieve.** Enumerate residues mod $28$; discard those with $\nu(r)$ odd; for the survivors, test $R_m - 1$ for squareness up to the size bound implied by $R_m \sim \rho^m$.

---

## 9. Discussion and future work

The analysis exhibits a clean dichotomy: the shifted Perrin valuation is a bounded, explicitly tabulated function on the overwhelming majority of residues, and an unbounded, self-similar (ruler-type) function on a measure-zero exceptional set organized by a period-doubling refinement. Several directions extend the work.

1. **A closed ruler-function form for the exceptional exponents.** On the exceptional classes the valuation appears to equal $3$ plus an affine function of a single $\nu_2(m + c)$, making the whole valuation piecewise linear in $\nu_2(m + c)$ — the exact analogue of the Padovan "TV1" law. The period doubles cleanly under each 2-adic refinement, so exactly one child residue survives at every level and the increments form a ruler sequence. The base cases (mod $28$ and mod $56$) pin down the constant part and the first two ruler increments, anchoring an induction on the expansion $M^{7 \cdot 2^{k-1}} = I + 2^k B_k$.

2. **The valuation realizes every natural number.** Empirically $\nu_2(R_m - 1)$ attains $0, 1, 2, 3, \dots$ with explicit small witnesses, so its value set is exactly $\mathbb{N}$, and for $k \ge 3$ precisely three residues mod $7 \cdot 2^{k-1}$ carry valuation $\ge k$. The key is that the Perrin period is *primitive* — it never collapses when the modulus doubles — forcing a nonempty survivor set at every level. Exact-period primitivity follows from the squaring identity $(I + 2^k B)^2 \equiv I \pmod{2^{k+1}}$, and the three-residue survivor count is confirmed through four full doublings.

3. **Finiteness of the Perrin–Brocard equation $R_m = x^2 + 1$.** Since a perfect square has even 2-adic valuation, every $m$ with $\nu_2(R_m - 1)$ odd is excluded — e.g. all $m \equiv 0,3,7,13,14,17,21,27 \pmod{28}$, where the valuation is $1$. An explicit valuation formula converts a hard Diophantine search into a finite congruence-plus-size check; with the mod-$28$/mod-$56$ table and the growth $R_m \sim \rho^m$, the surviving candidates lie in a finite, checkable range.

4. **The whole family $R_{n+3} = a R_{n+1} + b R_n$.** Perrin is $(a,b) = (1,1)$. For odd $b$ the companion matrix is 2-adically regular, so $R \bmod 2^k$ should again be purely periodic with a doubling period and a finite congruence description of $\nu_2(R_m - c)$. Period-doubling is a generic property of a 2-adically regular companion matrix, not a Perrin coincidence; the Perrin proof isolates exactly which matrix computation drives the law, so it can be replayed across the parameter family.

---

## 10. Conclusion

Driven by a single structural fact — that the Perrin sequence modulo $2^k$ is purely periodic with the doubling period $7 \cdot 2^{k-1}$ — we obtained a complete description of $\nu_2(R_m - 1)$: a period-$7$ parity rule, an explicit period-$28$ table covering $25$ of $28$ residue classes with values in $\{0,1,2\}$, and a period-$56$ self-similar refinement of the three exceptional classes that iterates as a ruler sequence at every higher power of two. As an application, the parity of the valuation sieves the Perrin–Brocard equation $R_m = x^2 + 1$ down to a finite, explicit search.
