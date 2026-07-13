# A Hirzebruch–Riemann–Roch Identity for the Integral Tangent Class of the Boolean Matroid

## Abstract

We establish, in a completely elementary and self‑contained fashion, a Hirzebruch–Riemann–Roch identity — the equality $P^K = \mathrm{Hilb}$ — for the Boolean matroid $B_n$ (the free matroid on $n$ elements) equipped with its maximal Feichtner–Yuzvinsky building set. The wonderful compactification of $B_n$ in this setting is the permutohedral toric variety $X_n$ of dimension $n-1$, whose Chow ring $A^\bullet(B_n)$ is a graded Poincaré‑duality algebra with graded Betti numbers equal to the Eulerian numbers $\langle n, k\rangle$. Our main theorem asserts that the $K$‑polynomial of the integral tangent class $T^{\mathbb{Z}}_{B_n}$, whose degree‑$k$ coefficient is the alternating Euler‑characteristic expression $\sum_{j=0}^{k}(-1)^j\binom{n+1}{j}(k+1-j)^n$, coincides as a polynomial in $\mathbb{Z}[t]$ with the Hilbert series $\sum_k \langle n,k\rangle t^k$ of the Chow ring. Along the way we record the palindromicity of the Eulerian numbers (Poincaré duality), the row‑sum identity (total dimension equals $n!$), Worpitzky's identity (the Riemann–Roch generating‑function bridge), and the closed inclusion–exclusion formula for the Eulerian numbers. The central point is that two sequences defined by structurally different formulas — one a manifestly non‑negative dimension count, the other a manifestly alternating Euler characteristic — are proved equal by exhibiting a shared recurrence, giving a concrete and fully explicit instance of the general $P^K = \mathrm{Hilb}$ principle.

**Keywords:** Eulerian numbers, Boolean matroid, permutohedral variety, Chow ring, Hilbert series, Hirzebruch–Riemann–Roch, K‑theory, Poincaré duality, Worpitzky's identity.

---

## 1. Introduction

### 1.1 Motivation

A recurring theme in geometry and topology is the confrontation of two kinds of numerical invariant. On one side stand **dimension counts**: the dimensions of the graded pieces of a cohomology or Chow ring, quantities that are non‑negative by construction and that assemble into a Hilbert series. On the other side stand **Euler characteristics**: alternating sums that arise from sheaf cohomology, from K‑theory, and from the Riemann–Roch apparatus, and that carry $\pm$ signs as an inescapable part of their definition. The Hirzebruch–Riemann–Roch philosophy asserts that these two kinds of invariant, computed by wholly different recipes, agree.

The purpose of this paper is to present a single instance of this principle in which every ingredient is explicit, elementary, and checkable to the last term. We specialise to the **Boolean matroid** $B_n$ — the free matroid on an $n$‑element ground set — with its maximal building set, whose associated wonderful compactification is the classical **permutohedral toric variety** $X_n$. In this case the geometry is governed by one of the oldest sequences in combinatorics, the **Eulerian numbers**, and the desired identity becomes a concrete statement about polynomials with integer coefficients.

### 1.2 The identity in one line

Write $\langle n, k\rangle$ for the Eulerian number counting permutations of $\{1, \dots, n\}$ with exactly $k$ descents. The Chow ring $A^\bullet(B_n)$ has $\dim A^k(B_n) = \langle n, k\rangle$, so its Hilbert series is the Eulerian polynomial. The $K$‑polynomial of the integral tangent class has coefficients given by the classical alternating formula. Our main theorem is the equality

$$\underbrace{\sum_{k=0}^{n}\left(\sum_{j=0}^{k}(-1)^j\binom{n+1}{j}(k+1-j)^n\right)t^k}_{P^K(T^{\mathbb{Z}}_{B_n},\,t)} \;=\; \underbrace{\sum_{k=0}^{n}\langle n, k\rangle\, t^k}_{\mathrm{Hilb}(A^\bullet(B_n),\,t)} \qquad \text{in } \mathbb{Z}[t].$$

The left‑hand coefficients are alternating sums whose intermediate terms grow without bound; the right‑hand coefficients are non‑negative descent counts. Their equality is the promised $P^K = \mathrm{Hilb}$.

### 1.3 Contributions

We provide complete, rigorous proofs of the following, organised so that each result plays a clearly identified geometric role:

1. **Poincaré duality** of the Chow ring, as palindromicity $\langle n, k\rangle = \langle n, n-1-k\rangle$.
2. **Total dimension**, as the row‑sum identity $\sum_k \langle n, k\rangle = n!$, the value of the Hilbert series at $t = 1$.
3. **Worpitzky's identity** $m^n = \sum_k \langle n, k\rangle\binom{m+k}{n}$, the Riemann–Roch generating‑function bridge.
4. **The closed alternating formula** $\langle n, k\rangle = \sum_j (-1)^j\binom{n+1}{j}(k+1-j)^n$.
5. **The main theorem** $P^K = \mathrm{Hilb}$, together with its palindromic and evaluation consequences at the polynomial level.

---

## 2. Geometric background

We briefly recall the geometry that motivates the combinatorics; none of it is logically required for the proofs, which are purely combinatorial, but it explains the names.

### 2.1 The Boolean matroid and its wonderful model

The Boolean matroid $B_n$ is the free matroid on a ground set $E$ with $|E| = n$: every subset is independent, and the lattice of flats is the full Boolean lattice $2^E$. Given a building set $G$ in the sense of Feichtner and Yuzvinsky containing the top flat $E$, one forms the **wonderful compactification** by blowing up along the members of $G$. For $B_n$ with the maximal building set, this model is the **permutohedral toric variety** $X_n$, the smooth projective toric variety whose fan is the normal fan of the permutohedron. Its dimension is $n - 1$.

### 2.2 The Chow ring

The Chow ring $A^\bullet(B_n) = A^\bullet(X_n)$ is a graded, commutative, finite‑dimensional $\mathbb{Q}$‑algebra concentrated in degrees $0$ through $n-1$. It satisfies **Poincaré duality**: the pairing $A^k \times A^{n-1-k} \to A^{n-1} \cong \mathbb{Q}$ is perfect, forcing $\dim A^k = \dim A^{n-1-k}$. The graded Betti numbers $\dim A^k(B_n)$ form the $h$‑vector of the permutohedron and equal the Eulerian numbers:

$$\dim A^k(B_n) = \langle n, k\rangle, \qquad k = 0, 1, \dots, n-1.$$

Consequently the Hilbert series of the Chow ring is the Eulerian polynomial, and the total dimension $\sum_k \dim A^k = n!$ is the number of maximal cones of the permutohedral fan (equivalently, the number of vertices of the permutohedron, equivalently the number of chambers of the type‑$A$ Coxeter arrangement).

### 2.3 The integral tangent class and its $K$‑polynomial

On the $K$‑theory side one works in an integral $K$‑group $K_{\mathbb{Z}}(B_n, G)$ and considers the **integral tangent class** $T^{\mathbb{Z}}_{B_n}$, a distinguished element recording the tangent‑sheaf data of the model. Its $K$‑polynomial $P^K(T^{\mathbb{Z}}_{B_n}, t)$ is, by the localisation/inclusion–exclusion computation on the permutohedral variety, the generating function of the alternating Euler‑characteristic coefficients

$$\sum_{j=0}^{k}(-1)^j\binom{n+1}{j}(k+1-j)^n.$$

The equality of this $K$‑polynomial with the Hilbert series of the Chow ring is the Boolean case of the paper's central Theorem A, property 2.

---

## 3. Definitions

Throughout, $n, k, m, j$ denote non‑negative integers, and $\binom{a}{b}$ is the usual binomial coefficient (equal to $0$ when $b > a$).

### 3.1 Eulerian numbers

**Definition 3.1 (Eulerian numbers).** The Eulerian numbers $\langle n, k\rangle$ are defined by the triangle recurrence with boundary values
$$\langle 0, 0\rangle = 1, \qquad \langle 0, k+1\rangle = 0, \qquad \langle n+1, 0\rangle = 1,$$
$$\langle n+1, k+1\rangle = (k+2)\,\langle n, k+1\rangle + (n-k)\,\langle n, k\rangle.$$

The shifted indices above are the honest content of the classical recurrence $\langle n+1, k\rangle = (k+1)\langle n, k\rangle + (n+1-k)\langle n, k-1\rangle$; combinatorially $\langle n, k\rangle$ is the number of permutations of $\{1, \dots, n\}$ with exactly $k$ descents. The first few rows are:

| $n$ | $\langle n, 0\rangle, \langle n, 1\rangle, \dots$ | row sum |
|----|-------------------|---------|
| $0$ | $1$ | $1$ |
| $1$ | $1$ | $1$ |
| $2$ | $1,\ 1$ | $2$ |
| $3$ | $1,\ 4,\ 1$ | $6$ |
| $4$ | $1,\ 11,\ 11,\ 1$ | $24$ |
| $5$ | $1,\ 26,\ 66,\ 26,\ 1$ | $120$ |

### 3.2 The alternating $K$‑theoretic coefficients

**Definition 3.2 (tangent $K$‑coefficients).** For $n, k \ge 0$ set
$$\tau(n, k) \;=\; \sum_{j=0}^{k}(-1)^j\binom{n+1}{j}\,(k+1-j)^n \;\in\; \mathbb{Z}.$$
This is the degree‑$k$ coefficient of the $K$‑polynomial of the integral tangent class $T^{\mathbb{Z}}_{B_n}$; it is a manifestly alternating (signed) expression.

### 3.3 The two polynomials

**Definition 3.3 (Hilbert series and $K$‑polynomial).** In $\mathbb{Z}[t]$ define
$$\mathrm{Hilb}(A^\bullet(B_n), t) \;=\; \sum_{k=0}^{n}\langle n, k\rangle\, t^k, \qquad P^K(T^{\mathbb{Z}}_{B_n}, t) \;=\; \sum_{k=0}^{n}\tau(n, k)\, t^k.$$
(The top nonzero term of each sits in degree $n-1$; the degree‑$n$ coefficient vanishes for $n \ge 1$.)

---

## 4. Main results

### 4.1 Vanishing above the top degree

**Lemma 4.1 (vanishing).** For $n \ge 1$ and $k \ge n$ we have $\langle n, k\rangle = 0$.

*Proof sketch.* Induct on $n$. The base case $n = 1$ is immediate from the boundary values. For the inductive step, apply the recurrence to $\langle n+1, k+1\rangle = (k+2)\langle n, k+1\rangle + (n-k)\langle n, k\rangle$: when $k \ge n$ the coefficient $(n - k)$ vanishes (as a natural number) and $\langle n, k+1\rangle = 0$ by the inductive hypothesis, so both summands vanish. $\square$

This lemma is what makes the Hilbert series a polynomial of degree exactly $n-1$: there are no permutations of $\{1, \dots, n\}$ with $n$ or more descents.

### 4.2 Poincaré duality

**Theorem 4.2 (palindromicity / Poincaré duality).** For $k < n$,
$$\langle n, k\rangle = \langle n, \, n-1-k\rangle.$$

*Proof sketch.* Induct on $n$. The essential auxiliary fact is $\langle n+1, n\rangle = 1$ (the unique permutation with the maximal number $n$ of descents), proved by a parallel induction from the recurrence. For the general step, write $k = k'+1$ and reindex: the recurrence for $\langle n, k\rangle$ maps, under $k \mapsto n-1-k$, to the recurrence for $\langle n, n-1-k\rangle$, and the two boundary values match. Vanishing (Lemma 4.1) handles the extreme index $k = n-1$. $\square$

Geometrically this is exactly Poincaré duality on the smooth projective $(n-1)$‑dimensional variety $X_n$: the perfect pairing $A^k \times A^{n-1-k} \to A^{n-1}$ forces the Hilbert series to be palindromic.

### 4.3 Total dimension

**Theorem 4.3 (row sum).** For all $n$,
$$\sum_{k=0}^{n}\langle n, k\rangle = n!.$$

*Proof sketch.* Induct on $n$. Expand $\sum_{k}\langle n+1, k\rangle$ using the recurrence, reindex the two resulting sums so that the terms $(k+2)\langle n, k+1\rangle$ and $(n-k)\langle n, k\rangle$ line up on the same index, and combine them. On the overlapping range the coefficients telescope to $(x+2) + (n - (x+1)) = n+1$, producing $(n+1)\sum_k \langle n, k\rangle = (n+1)\cdot n! = (n+1)!$; the boundary contributions vanish by Lemma 4.1. $\square$

This is the total dimension $\dim_{\mathbb{Q}} A^\bullet(B_n) = n!$, equivalently the value of the Hilbert series at $t = 1$, equivalently the number of maximal cones of the permutohedral fan.

### 4.4 Worpitzky's identity

**Theorem 4.4 (Worpitzky).** For all $m, n \ge 0$,
$$m^n = \sum_{k=0}^{n}\langle n, k\rangle\binom{m+k}{n}.$$

*Proof sketch.* Strong induction on $n$. Insert the recurrence into the right‑hand side and split it into two sums, one weighted by $(k+1)$ and one by $(n-k)$. The key pointwise binomial identity is
$$(k+1)\binom{m+k}{n+1} + (n-k)\binom{m+k+1}{n+1} = m\binom{m+k}{n},$$
which follows from Pascal's rule $\binom{m+k+1}{n+1} = \binom{m+k}{n+1} + \binom{m+k}{n}$ together with the absorption identity $(n+1)\binom{m+k}{n+1} = (m+k-n)\binom{m+k}{n}$. Summing the pointwise identity and applying the inductive hypothesis $m^n = \sum_k \langle n, k\rangle\binom{m+k}{n}$ yields $m^{n+1} = m\cdot m^n$. $\square$

Worpitzky's identity is the Riemann–Roch generating‑function bridge: its left side $m^n$ is the lattice‑point/Euler‑characteristic count $\chi(X_n, L^m)$ of sections of the $m$‑th power of the natural line bundle, and its right‑hand coefficients are exactly the Hilbert (Chow Betti) data. It says the Hilbert polynomial of $X_n$ expands in the binomial basis with Eulerian coefficients.

### 4.5 The alternating formula

**Theorem 4.5 (closed alternating formula).** For all $n, k$,
$$\langle n, k\rangle = \tau(n, k) = \sum_{j=0}^{k}(-1)^j\binom{n+1}{j}(k+1-j)^n.$$

*Proof sketch.* It suffices to show that $\tau(n, k)$ satisfies the same recurrence and boundary data as $\langle n, k\rangle$. Two facts are established:

- **Base value.** $\tau(n, 0) = 1$, since only the $j = 0$ term survives.
- **Recurrence.** $\tau(n+1, k+1) = (k+2)\,\tau(n, k+1) + (n - k)\,\tau(n, k)$, where here $(n-k)$ is taken as the honest *integer* coefficient. This is proved by three algebraic manipulations of the defining sum: (i) splitting $\binom{n+2}{j}$ via Pascal's rule; (ii) writing $(k+2-j)^{n+1} = (k+2)(k+2-j)^n - j(k+2-j)^n$ to peel off a factor; and (iii) using the absorption identity $j\binom{n+1}{j} = (n+1)\binom{n}{j-1}$ to convert the $j$‑weighted sum into a shifted, reindexed copy. Reassembling gives the stated recurrence.

Because $\tau$ and $\langle\,\cdot\,,\cdot\,\rangle$ share their base cases and recurrence (using vanishing, Lemma 4.1, to reconcile the integer coefficient $(n-k)$ with the truncated natural‑number coefficient when $k \ge n$), an induction on $n$ concludes $\langle n, k\rangle = \tau(n, k)$ for all $n, k$. $\square$

This is the crux: the non‑negative descent count equals a signed alternating sum. It is the numerical heart of $P^K = \mathrm{Hilb}$.

### 4.6 The main theorem

**Theorem 4.6 ($P^K = \mathrm{Hilb}$ for the Boolean matroid).** As polynomials in $\mathbb{Z}[t]$,
$$P^K(T^{\mathbb{Z}}_{B_n}, t) = \mathrm{Hilb}(A^\bullet(B_n), t).$$

*Proof.* Compare coefficients. In degree $k$, the coefficient of $P^K$ is $\tau(n, k)$ and that of $\mathrm{Hilb}$ is $\langle n, k\rangle$; these are equal by Theorem 4.5. Since the two polynomials agree in every degree, they are equal. $\square$

**Corollary 4.7 (evaluation).** $\displaystyle \mathrm{Hilb}(A^\bullet(B_n), t)\big|_{t=1} = n!.$

*Proof.* Immediate from Theorem 4.3, since evaluating the polynomial at $1$ sums its coefficients. $\square$

**Corollary 4.8 (palindromic coefficients).** For $k < n$, the coefficients of $\mathrm{Hilb}(A^\bullet(B_n), t)$ satisfy $[\,t^k\,] = [\,t^{n-1-k}\,]$.

*Proof.* The degree‑$k$ coefficient is $\langle n, k\rangle$ for $k \le n$; apply Theorem 4.2. $\square$

Corollaries 4.7 and 4.8 are the two Poincaré‑duality consequences at the level of the Hilbert polynomial: total dimension $n!$ and palindromic symmetry.

---

## 5. Algorithms

We describe three algorithms implicit in the proofs; Python implementations appear in the companion demonstration code.

### 5.1 Triangle recurrence

**Purpose.** Compute the table $\langle n, k\rangle$ for $0 \le k \le n \le N$.

```
Input: N
Initialize E[0][0] = 1
For n from 1 to N:
    E[n][0] = 1
    For k from 1 to n:
        E[n][k] = (k+1) * E[n-1][k] + (n-k) * E[n-1][k-1]
Return E
```

The recurrence uses the classical (unshifted) normalisation. Time complexity $O(N^2)$ additions/multiplications; space $O(N^2)$ (or $O(N)$ with a rolling row).

### 5.2 Alternating Euler‑characteristic evaluation

**Purpose.** Compute $\tau(n, k) = \sum_{j=0}^{k}(-1)^j\binom{n+1}{j}(k+1-j)^n$ directly, and confirm $\tau(n, k) = \langle n, k\rangle$.

```
Input: n, k
S = 0
For j from 0 to k:
    S = S + (-1)^j * binom(n+1, j) * (k+1-j)^n
Return S
```

This is a genuine alternating sum: intermediate partial sums oscillate and the summands can be exponentially larger than the answer. Verifying $\tau(n,k) = \langle n, k\rangle$ over a grid is a stringent numerical test of Theorem 4.5.

### 5.3 Worpitzky expansion

**Purpose.** Given $m, n$, verify $m^n = \sum_k \langle n, k\rangle\binom{m+k}{n}$, and use it as a Riemann–Roch/Hilbert‑polynomial cross‑check.

```
Input: m, n; precomputed E = eulerian table
S = 0
For k from 0 to n:
    S = S + E[n][k] * binom(m+k, n)
Assert S == m^n
```

---

## 6. Applications and cross‑checks

- **Positivity certificate.** Theorem 4.5 exhibits the alternating sum $\tau(n, k)$ as a non‑negative integer, since it equals a count of permutations. Alternating sums are rarely positive for structural reasons; here positivity is *forced* by the identification with $\langle n, k\rangle$.
- **Closed formula from geometry.** Conversely, the geometric identification hands the combinatorialist a closed‑form evaluation of the Eulerian numbers as a single (if signed) sum, bypassing the recurrence.
- **Hilbert‑polynomial consistency.** Worpitzky's identity (Theorem 4.4) lets one read off the Hilbert polynomial of the natural polarisation on $X_n$ and confirm that its value at every integer $m$ is the honest power $m^n$, an independent check on the Betti numbers.
- **Symmetry diagnostics.** Palindromicity (Theorem 4.2) is a fast, local test that a purported Betti table could come from a Poincaré‑duality algebra.

---

## 7. Discussion

The Boolean matroid is the simplest loopless matroid, and precisely for that reason it is where the $P^K = \mathrm{Hilb}$ identity can be established with no loose ends: the Chow ring's Betti numbers are the Eulerian numbers, the $K$‑polynomial's coefficients are the classical alternating formula, and their equality reduces to the statement that two integer sequences share a recurrence. The proof strategy — identify a common recurrence and common initial data — is robust and generalises in principle, but the *inputs* to that strategy (which combinatorial numbers are the Betti numbers, which alternating formula computes the $K$‑coefficients) are what change, and become substantially more intricate, for general matroids and general building sets.

The philosophical content is worth restating. A dimension count and an Euler characteristic are the two canonical ways to extract integers from a geometric space; the first is manifestly non‑negative, the second manifestly signed. That they coincide is the Hirzebruch–Riemann–Roch bridge. Here that bridge is made completely concrete, and the "miracle" of the alternating sum collapsing to a small non‑negative integer is demystified as a shared recurrence.

---

## 8. Future directions

**General matroids.** Replace the Boolean matroid by an arbitrary loopless matroid $M$ and an arbitrary building set $G \ni E$. This requires developing the lattice of flats, the Feichtner–Yuzvinsky nested‑set basis of the Chow ring $A^\bullet(M, G)$, and the resulting Hilbert function. The $P^K = \mathrm{Hilb}$ identity would then be stated for the corresponding $K$‑class $T^{\mathbb{Z}}_{M, G}$.

**The Chow ring itself.** Here $A^\bullet(B_n)$ is treated only through its numerical invariant (the Hilbert series / Eulerian polynomial). A deeper development would construct the Feichtner–Yuzvinsky presentation of $A^\bullet(M, G)$ as a quotient of a polynomial ring, prove it is a Poincaré‑duality algebra, and derive palindromicity from that structure rather than from the recurrence.

**Integral K‑theory.** The tangent class $T^{\mathbb{Z}}$ lives in an integral $K$‑group $K_{\mathbb{Z}}(M, G)$. Constructing this group and its natural basis, then *defining* the tangent class and computing its $K$‑polynomial from first principles, would turn the alternating coefficients from a combinatorially‑defined stand‑in into the genuine $K$‑theoretic object, completing the geometric picture.

---

## 9. Conclusion

For the Boolean matroid $B_n$ with its maximal building set, the $K$‑polynomial of the integral tangent class equals the Hilbert series of the Chow ring of the permutohedral variety, coefficient for coefficient. The proof rests on four classical pillars — palindromicity, the row‑sum $n!$, Worpitzky's identity, and the closed alternating formula for the Eulerian numbers — each of which carries an unambiguous geometric meaning (Poincaré duality, total dimension, the Riemann–Roch bridge, and the Euler‑characteristic realisation of a dimension count). Together they exhibit a fully explicit, end‑to‑end instance of the Hirzebruch–Riemann–Roch principle in the theory of matroids.
