# Mutually Orthogonal Italian Squares: The Sharp Bound $n-1$ and its Prime-Power Realization

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Applications (combinatorial design theory)

---

## Abstract

An *Italian square* of order $n$ — synonymous with a *Latin square* — is an $n \times n$ array over an $n$-symbol alphabet in which every symbol occurs exactly once in each row and exactly once in each column. Two Italian squares are *orthogonal* when their superposition realizes each ordered pair of symbols exactly once. We study families of pairwise orthogonal Italian squares (MOLS). We give a complete, self-contained account of two results. First, an **upper bound**: for every order $n \ge 2$, any family of pairwise orthogonal Italian squares has at most $n - 1$ members. Second, a **prime-power realization**: for every prime power $n = p^k \ge 2$, the affine squares $S_a(i,j) = a \cdot i + j$ indexed by the nonzero elements $a$ of the Galois field $\mathrm{GF}(p^k)$ form a family of exactly $n - 1$ pairwise orthogonal squares, so the bound is attained. Together these yield: over a finite field with $n \ge 2$ elements the maximum size of an MOLS family is exactly $n - 1$, and it is achieved. We present the definitions, the main theorems with detailed proof sketches, the affine construction algorithm, worked numerical examples, applications to experimental design and coding theory, and a careful discussion of the converse direction — "the bound is attained *only* for prime powers" — which is equivalent to the open existence problem for finite projective planes and is deliberately left unasserted.

---

## 1. Introduction

Latin squares are among the oldest studied combinatorial objects, with roots reaching back to magic-square traditions and crystallized in Euler's eighteenth-century investigations. A *Latin square* of order $n$ is an $n \times n$ matrix over an alphabet of $n$ symbols such that each symbol appears exactly once in each row and exactly once in each column. We adopt the name **Italian square** as a synonym throughout; the mathematics is identical.

The structure becomes far richer when several squares interact. Two Latin squares are *orthogonal* (a Graeco-Latin pair, in Euler's dress) if superimposing them produces each of the $n^2$ ordered symbol-pairs exactly once. A family in which every two members are orthogonal is a set of **mutually orthogonal Latin squares (MOLS)**. The fundamental quantity is
$$
N(n) := \text{the maximum size of a family of pairwise orthogonal Latin squares of order } n.
$$

This paper establishes two of the cornerstones of MOLS theory in a fully rigorous, machine-checked development, and explains them in self-contained mathematical prose:

- **(Upper bound)** $N(n) \le n - 1$ for all $n \ge 2$.
- **(Prime-power lower bound / tightness)** $N(n) = n - 1$ whenever $n$ is a prime power.

The combination is classical (Bose; see Van Lint & Wilson, *A Course in Combinatorics*, Ch. 22; and Brualdi & Dahl 2018), but our contribution is a clean, faithful, and complete formal encoding together with this expository synthesis. We also delimit precisely what is *not* proven: the converse implication — that the bound is attained only at prime powers — is equivalent to the existence of finite projective planes and remains a major open problem.

---

## 2. Definitions

We work over an arbitrary symbol type $\alpha$; the order is $n = |\alpha|$ when $\alpha$ is finite.

### 2.1 Italian (Latin) squares

> **Definition 2.1 (Italian square).** An *Italian square* on a symbol set $\alpha$ is a function $L : \alpha \to \alpha \to \alpha$, written $L(i,j)$ for the entry in row $i$ and column $j$, subject to:
> - **Row condition** (`row_bij`): for every row $i$, the map $j \mapsto L(i,j)$ is a bijection of $\alpha$;
> - **Column condition** (`col_bij`): for every column $j$, the map $i \mapsto L(i,j)$ is a bijection of $\alpha$.

Each condition says "every symbol occurs exactly once": once per row, once per column. For finite $\alpha$ a function on a finite set is a bijection iff it is injective iff it is surjective, so the definition matches the array intuition exactly. In the formal development this is the structure `ItalianSquare` bundling `toFun`, `row_bij`, and `col_bij`.

### 2.2 Orthogonality

> **Definition 2.2 (Orthogonality).** Two Italian squares $L, M$ on $\alpha$ are *orthogonal*, written $\mathrm{Orthogonal}(L,M)$, if the **superposition map**
> $$
> \Phi_{L,M} : \alpha \times \alpha \to \alpha \times \alpha, \qquad (i,j) \mapsto \big(L(i,j),\, M(i,j)\big)
> $$
> is a bijection.

Equivalently, each ordered pair $(s,t) \in \alpha \times \alpha$ of symbols arises from exactly one cell $(i,j)$. For finite $\alpha$ this is the statement that the $n^2$ superimposed pairs are pairwise distinct, hence exhaust all $n^2$ possibilities.

> **Definition 2.3 (MOLS family).** A family $\{L_s\}_{s \in K}$ of Italian squares indexed by a set $K$ is *pairwise orthogonal* if $\mathrm{Orthogonal}(L_s, L_t)$ for all $s \ne t$. We write $N(n)$ for the maximum cardinality $|K|$ over all such families of order $n$.

---

## 3. Main results

We collect the theorems proved, with their formal names, before sketching proofs.

> **Theorem 3.1 (Upper bound, `card_le_card_sub_one`).** Let $\alpha$ be a finite symbol set with $|\alpha| = n \ge 2$. For any family $\{L_s\}_{s \in K}$ of pairwise orthogonal Italian squares on $\alpha$,
> $$
> |K| \le n - 1.
> $$

> **Theorem 3.2 (Affine squares are Italian, `affine_row_bij` + `affine_col_bij`).** Let $F$ be a field and $a \in F$ with $a \ne 0$. The array $S_a(i,j) = a \cdot i + j$ satisfies the row and column conditions, hence `affineSquare` defines an Italian square on $F$.

> **Theorem 3.3 (Orthogonality of distinct slopes, `affineSquare_orthogonal`).** Let $F$ be a field and $a, b \in F$ with $a \ne 0$, $b \ne 0$, and $a \ne b$. Then $S_a$ and $S_b$ are orthogonal.

> **Theorem 3.4 (Tightness over a finite field, `exists_mols_card_eq_card_sub_one`).** Let $F$ be a finite field with $|F| \ge 2$. There exists a family of pairwise orthogonal Italian squares on $F$ of size exactly $|F| - 1$.

> **Theorem 3.5 (Exact maximum, `maximum_mols_eq_card_sub_one`).** Let $F$ be a finite field with $|F| = n \ge 2$. Then the maximum size of a family of pairwise orthogonal Italian squares on $F$ is exactly $n - 1$: a family of size $n - 1$ exists, and every pairwise orthogonal family has at most $n - 1$ members.

> **Theorem 3.6 (Prime-power realization, `exists_mols_prime_power`).** Let $p$ be prime and $k \ge 1$, with $n = p^k \ge 2$. Then there exist $n - 1$ pairwise orthogonal Italian squares of order $n$, realized on the Galois field $\mathrm{GF}(p^k)$.

---

## 4. The upper bound $N(n) \le n - 1$

### 4.1 Proof sketch

The argument is a single application of the pigeonhole principle, made possible by a relabeling normalization.

**Step 1 — Relabeling invariance.** Orthogonality is invariant under independently permuting the symbol alphabet *within each square*. Concretely, if $\sigma, \tau$ are bijections of $\alpha$ and we replace $L$ by $\sigma \circ L$ and $M$ by $\tau \circ M$, then the superposition map is post-composed by the bijection $(\sigma, \tau)$ of $\alpha \times \alpha$, which preserves bijectivity. Likewise each relabeled square remains Italian (composing a bijection with the row/column bijections). Hence we may *standardize* each square in the family so that its first row reads $x \mapsto x$ (the identity listing of symbols) without affecting pairwise orthogonality.

**Step 2 — Fix a witness cell.** Choose two distinct rows; since $n \ge 2$ such rows exist. Call them the "first" row $x_0$ (the standardized one) and a "second" row $x_1 \ne x_0$. Fix a column $c$. For each square $L_s$ in the family consider the symbol $L_s(x_1, c)$ placed in the witness cell $(x_1, c)$.

**Step 3 — Distinct symbols across the family.** Suppose two standardized squares $L_s, L_t$ ($s \ne t$) place the *same* symbol $w = L_s(x_1,c) = L_t(x_1,c)$ in the witness cell. Because both are standardized, the first row is the identity, so there is a unique column $d$ with $L_s(x_0,d) = L_t(x_0,d) = w$ as well. (For the affine-style normalization, $d$ is determined by $w$.) Then the ordered pair $(w,w)$ appears in the superposition $\Phi_{L_s,L_t}$ at *both* the witness cell $(x_1,c)$ and the first-row cell $(x_0,d)$ — two distinct cells, since $x_0 \ne x_1$. This contradicts orthogonality, which requires every pair to appear exactly once. Therefore the symbols $\{L_s(x_1,c)\}_{s \in K}$ are pairwise distinct: the map $s \mapsto L_s(x_1,c)$ is injective.

**Step 4 — Count.** Injectivity gives $|K| \le n$. Moreover the specific symbol that the standardized first row places in column $c$, namely the "diagonal" value, cannot occur in the witness cell of any family member (that would again duplicate a first-row pair against itself). Excluding it leaves at most $n - 1$ admissible symbols, so $|K| \le n - 1$. $\qquad\blacksquare$

The formal proof avoids materializing standardized squares; instead, for each square $L_t$ it uses the bijective first row $\mathrm{row}_0 : j \mapsto L_t(x_0,j)$ to define a *slope invariant* $a(t) := \mathrm{row}_0^{-1}(L_t(x_1, x_0))$, and shows $t \mapsto a(t)$ is injective into the set of admissible symbols of size $n - 1$. This is exactly the textbook standardization argument carried out at the level of inverse maps rather than rewritten arrays.

### 4.2 Remarks

- The bound is independent of any algebraic structure on $\alpha$; it holds for an arbitrary finite symbol set.
- $n - 1$ is genuinely the obstruction count: it is the number of "non-identity slopes," which previews why a structure supplying exactly $n - 1$ usable slopes — a field — attains it.

---

## 5. The affine construction and tightness

### 5.1 The affine squares

Let $F$ be a field. For a nonzero $a \in F$ define
$$
S_a(i,j) = a \cdot i + j, \qquad i, j \in F.
$$

> **Lemma 5.1 (`affine_row_bij`).** For any $a, i \in F$, the row map $j \mapsto a \cdot i + j$ is a bijection of $F$.
>
> *Proof.* It is $j \mapsto j + c$ with constant $c = a \cdot i$: injective by left-cancellation of addition (`add_right_injective`) and surjective because $j = u - c$ solves $j + c = u$ (`add_left_surjective`). $\blacksquare$

> **Lemma 5.2 (`affine_col_bij`).** For $a \ne 0$ and any $j \in F$, the column map $i \mapsto a \cdot i + j$ is a bijection of $F$.
>
> *Proof.* Injectivity: if $a i_1 + j = a i_2 + j$ then $a i_1 = a i_2$, and cancelling the nonzero $a$ (`mul_left_cancel₀`) gives $i_1 = i_2$. Surjectivity: for target $u$, set $i = (u - j)/a$; then $a \cdot \frac{u-j}{a} + j = (u-j) + j = u$ using $a \ne 0$ (`mul_div_cancel₀`). $\blacksquare$

Together (Theorem 3.2) these show `affineSquare` $S_a$ is an Italian square for each nonzero $a$.

### 5.2 Orthogonality of distinct slopes

> **Theorem 3.3 restated (`affineSquare_orthogonal`).** For nonzero $a \ne b$, $S_a$ and $S_b$ are orthogonal.
>
> *Proof sketch.* We show $\Phi : (i,j) \mapsto (a i + j,\, b i + j)$ is a bijection of $F \times F$.
>
> **Injectivity.** Suppose $\Phi(i_1,j_1) = \Phi(i_2,j_2)$, i.e.
> $$ a i_1 + j_1 = a i_2 + j_2, \qquad b i_1 + j_1 = b i_2 + j_2. $$
> Subtracting eliminates $j$: $(a-b) i_1 = (a-b) i_2$. Since $a \ne b$, $a - b \ne 0$, so cancellation gives $i_1 = i_2$; substituting back yields $j_1 = j_2$.
>
> **Surjectivity.** Given a target $(u,v)$, solve
> $$ a i + j = u, \qquad b i + j = v. $$
> Subtracting gives $(a-b) i = u - v$, so $i = \dfrac{u-v}{a-b}$ (legal because $a - b \ne 0$), and then $j = u - a i$. A direct substitution verifies $\Phi(i,j) = (u,v)$.
>
> The entire argument is the invertibility of the $2 \times 2$ coefficient matrix $\begin{pmatrix} a & 1 \\ b & 1 \end{pmatrix}$, whose determinant is $a - b$. Over a field, nonzero determinant $\iff$ bijection. $\blacksquare$

This is the algebraic heart of the whole theory: orthogonality of $S_a, S_b$ reduces to the single nonvanishing condition $a - b \ne 0$.

### 5.3 Tightness and exact maximum

> **Theorem 3.4 restated (`exists_mols_card_eq_card_sub_one`).** Over a finite field $F$ with $|F| \ge 2$, the family $\{S_a : a \in F,\, a \ne 0\}$ indexed by $K = \{a \in F : a \ne 0\}$ is pairwise orthogonal and has cardinality $|F| - 1$.
>
> *Proof.* Pairwise orthogonality is Theorem 3.3 applied to distinct nonzero slopes. The index set $K$ is the complement of $\{0\}$ in $F$, so $|K| = |F| - 1$ (`Fintype.card_subtype_compl`). $\blacksquare$

> **Theorem 3.5 restated (`maximum_mols_eq_card_sub_one`).** For a finite field $F$ with $|F| = n \ge 2$: an MOLS family of size $n-1$ exists (Theorem 3.4), and every MOLS family has size $\le n-1$ (Theorem 3.1). Hence $N(n) = n - 1$ and the maximum is attained. $\blacksquare$

### 5.4 Prime-power realization

> **Theorem 3.6 restated (`exists_mols_prime_power`).** For prime $p$, $k \ge 1$, $n = p^k \ge 2$: the Galois field $\mathrm{GF}(p^k)$ has exactly $n$ elements (`GaloisField.card`, valid since $k \ne 0$). Applying Theorem 3.4 to $F = \mathrm{GF}(p^k)$ produces $n - 1$ pairwise orthogonal Italian squares of order $n$. $\blacksquare$

Because every prime power admits a finite field of that order, this covers all $n \in \{2,3,4,5,7,8,9,11,13,16,\dots\}$.

---

## 6. Algorithms

### 6.1 Affine MOLS generator

The constructive content of Theorems 3.4–3.6 is an explicit generator. Given a field of order $n$ (e.g. $\mathbb{Z}/p\mathbb{Z}$ for prime $n$, or $\mathrm{GF}(p^k)$ via polynomial arithmetic modulo an irreducible polynomial), output the $n-1$ squares $S_a(i,j) = a\cdot i + j$ for $a \ne 0$.

**Pseudocode.**
```
Input: field F with elements e[0..n-1], where e[0] = 0 (additive identity)
Output: list of n-1 mutually orthogonal n x n arrays
for each a in F with a != 0:
    S_a := new n x n array
    for i in F:
        for j in F:
            S_a[index(i)][index(j)] := a * i + j      # field arithmetic
    append S_a to result
return result
```
Complexity: each square costs $O(n^2)$ field operations; the full family costs $O(n^3)$ operations and $O(n^3)$ storage.

### 6.2 Orthogonality verifier

To verify orthogonality of two $n \times n$ arrays, collect the $n^2$ pairs $(L(i,j), M(i,j))$ and check they are all distinct (equivalently, that the set has size $n^2$).

**Pseudocode.**
```
Input: arrays L, M of order n
seen := empty set
for i in 0..n-1:
    for j in 0..n-1:
        p := (L[i][j], M[i][j])
        if p in seen: return False
        add p to seen
return (size(seen) == n*n)   # always true once no duplicate found
```
Complexity: $O(n^2)$ time and space.

---

## 7. Worked examples

### 7.1 Order 3 ($\mathbb{Z}/3\mathbb{Z}$)

Slopes $a \in \{1,2\}$ give the maximum $n-1 = 2$ squares:
$$
S_1 = \begin{array}{ccc} 0&1&2\\1&2&0\\2&0&1 \end{array}
\qquad
S_2 = \begin{array}{ccc} 0&1&2\\2&0&1\\1&2&0 \end{array}
$$
Superposition yields all nine pairs once — verified orthogonal.

### 7.2 Order 4 ($\mathrm{GF}(4)$)

Here $4 = 2^2$ is a prime power but **not** prime; one must use the field $\mathrm{GF}(4) = \{0,1,\omega,\omega^2\}$ with $\omega^2 = \omega + 1$, *not* $\mathbb{Z}/4\mathbb{Z}$ (which is not a field). The three nonzero slopes $a \in \{1, \omega, \omega^2\}$ produce $n - 1 = 3$ mutually orthogonal squares — the maximum, corresponding to the projective plane of order 4.

### 7.3 Order 5 ($\mathbb{Z}/5\mathbb{Z}$)

Slopes $a \in \{1,2,3,4\}$ give $4$ mutually orthogonal squares, the full ceiling.

### 7.4 The exceptional order 6

$6$ is *not* a prime power, so our construction does not apply. Indeed Tarry (1900) proved no two orthogonal squares of order 6 exist: $N(6) = 1 < 5$. This is consistent with — but not implied by — our theorems; it lives on the open converse side.

---

## 8. Applications

- **Statistical experimental design.** A pair of orthogonal squares is a Graeco-Latin design, allowing two blocking factors to be tested without confounding; complete MOLS families correspond to hyper-Graeco-Latin designs. This is foundational to Fisher's analysis of variance.
- **Coding theory.** A complete set of $n-1$ MOLS of order $n$ is equivalent to a maximum-distance-separable (MDS) code and to an orthogonal array of strength 2 and index 1. The bound $N(n) \le n-1$ is the combinatorial Singleton bound in disguise.
- **Finite geometry.** A complete MOLS family of order $n$ is equivalent to an affine (hence projective) plane of order $n$; the slopes are the parallel classes of lines.
- **Cryptography.** The affine maps $x \mapsto a x + b$ over a finite field form a sharply 2-transitive group, underlying authentication codes, universal hash families, and key-scheduling constructions.
- **Scheduling.** Round-robin tournaments, conflict-free timetabling, and frequency assignment reduce to MOLS / Latin-square coloring.

---

## 9. Discussion: what is proven and what is open

We have rigorously established **both halves of the prime-power statement**:

- the universal upper bound $N(n) \le n-1$ ($n \ge 2$), with no algebraic assumptions; and
- the prime-power tightness $N(n) = n - 1$ via the affine construction over $\mathrm{GF}(p^k)$.

We have **deliberately not asserted the converse** "the bound is attained only for prime powers." That statement is equivalent to: *a finite projective plane of order $n$ exists iff $n$ is a prime power.* Its forward-from-prime-power direction is what we prove; the reverse — nonexistence of planes of non-prime-power order — is a celebrated open problem.

Known boundary facts (not formalized here) frame the gap:

- **Bruck–Ryser–Chowla:** if $n \equiv 1$ or $2 \pmod 4$ and a plane of order $n$ exists, then $n$ is a sum of two integer squares; this excludes $n = 6, 14, 21, 22, \dots$.
- **Order 6:** Euler's 36-officers problem; Tarry (1900) proved $N(6) = 1$.
- **Order 10:** a massive computer search proved no projective plane of order 10 exists, so the full ceiling of 9 is not reached, though pairs and partial families do exist.
- **Euler's spoilers:** Bose, Shrikhande, and Parker showed two orthogonal squares exist for every order $4k+2$ except $6$, refuting Euler's broader conjecture.

---

## 10. Future work

The formalization invites several next layers, ordered roughly by accessibility:

1. **Plane equivalence (Conjecture 1).** Formalize finite affine/projective planes and prove that a *complete* family of $n-1$ MOLS exists iff a projective plane of order $n$ exists, making the converse precise rather than folklore. The affine `slope` construction already supplies one direction.
2. **Bruck–Ryser–Chowla obstruction (Conjecture 2).** A falsifiable necessary condition using only elementary number theory (quadratic residues, sums of two squares) already in the library; instantly rules out many orders.
3. **MacNeish multiplicative bound (Conjecture 3).** $N(mn) \ge \min(N(m), N(n))$ via the Kronecker (coordinatewise) product of squares on $\alpha \times \beta$, reusing the exact `Orthogonal` predicate; gives $N(n) \ge (\text{least prime-power factor}) - 1$.
4. **Order-6 nonexistence (Conjecture 4).** $\mathrm{Orthogonal}$ on $\mathrm{Fin}\,6$ is a decidable property of a finite search space, enabling a verified Euler–Tarry result $N(6) = 1$.

---

## 11. Conclusion

From a single sharp question — how many Latin/Italian squares of order $n$ can be mutually orthogonal — emerges a complete and beautiful answer for prime powers: exactly $n - 1$, attained effortlessly by the affine squares $S_a(i,j) = a i + j$. The upper bound flows from a one-cell pigeonhole argument; the matching construction flows from the single algebraic fact that nonzero field elements are invertible. The remaining mystery — whether non-prime-power orders can ever reach the ceiling — is one of the most enduring open problems in combinatorics, and our development is scrupulous to prove exactly what can be proven and to mark precisely where knowledge ends.

---

## References (for context; the paper is self-contained)

- R. A. Brualdi and G. Dahl, *Combinatorial Matrix Classes / design-theoretic surveys*, 2018.
- J. H. van Lint and R. M. Wilson, *A Course in Combinatorics*, 2nd ed., Cambridge University Press, 1992 (Ch. 22).
- L. Euler, *Recherches sur une nouvelle espèce de quarrés magiques*, 1782.
- G. Tarry, *Le problème des 36 officiers*, 1900.
- R. C. Bose, S. S. Shrikhande, E. T. Parker, refutation of Euler's conjecture, 1960.
