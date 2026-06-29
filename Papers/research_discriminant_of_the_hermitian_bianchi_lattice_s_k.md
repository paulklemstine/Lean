# The Discriminant of the Hermitian Bianchi Lattice $S_K = \mathrm{Herm}_2(\mathcal{O}_K)$

**Author:** Aristotle

**Domain:** Applications (arithmetic geometry of lattices)

## Abstract

Let $d < 0$ be a squarefree integer, let $K = \mathbb{Q}(\sqrt{d})$ be the associated imaginary quadratic field, and let $\mathcal{O}_K = \mathbb{Z}[\omega]$ be its ring of integers, where $\omega = \frac{1+\sqrt{d}}{2}$ if $d \equiv 1 \pmod 4$ and $\omega = \sqrt{d}$ otherwise. The rank-four lattice $S_K = \mathrm{Herm}_2(\mathcal{O}_K)$ of Hermitian $2 \times 2$ matrices over $\mathcal{O}_K$, equipped with the quadratic form $q(A) = 2\det A$, is a fundamental object in the arithmetic of Bianchi groups and in the lattice theory underlying K3 surfaces. We prove that the determinant of the Gram matrix of the polarising symmetric bilinear form of $q$, computed in the natural basis consisting of the two diagonal Hermitian matrix units together with the off-diagonal generators $1$ and $\omega$, equals the **fundamental discriminant** $D_K$ of $K$: namely $\det \mathrm{Gram}(S_K) = d$ when $d \equiv 1 \pmod 4$ and $4d$ otherwise. The proof factors into a purely algebraic identity, $\det \mathrm{Gram}(S_K) = T^2 - 4M$ where $T = \mathrm{Tr}(\omega)$ and $M = N(\omega)$, valid for all integers $T, M$; and a number-theoretic evaluation, $T^2 - 4M = D_K$, which is the discriminant of the minimal polynomial of $\omega$. The Gram matrix splits as the orthogonal direct sum of a hyperbolic plane $U$ and a negative binary block carrying the norm form of $K$, exposing the entire result through a block-determinant computation. All results have been formally verified in Lean 4 with Mathlib.

## 1. Introduction

The interplay between the arithmetic of number fields and the geometry of integral lattices is one of the recurring themes of modern mathematics. A single integer — the discriminant of a quadratic field — controls the splitting of primes, ramification, the class group, and a host of other arithmetic phenomena. Independently, integral lattices equipped with quadratic forms organise the classification of algebraic surfaces (notably K3 surfaces via the Torelli theorem), the theory of modular forms, and string-theoretic compactifications. When an arithmetically defined lattice has a determinant equal to a field discriminant, the two theories become directly comparable.

This paper concerns the lattice of Hermitian matrices over the ring of integers of an imaginary quadratic field. Such lattices arise naturally in the study of Bianchi groups $\mathrm{SL}_2(\mathcal{O}_K)$, which act on hyperbolic 3-space, and the space of Hermitian forms is the symmetric space on which they act. The quadratic form $q(A) = 2\det A$ is the natural $\mathrm{SL}_2$-invariant on this space, and twice the determinant is taken so that the form is integral and even on the lattice $\mathrm{Herm}_2(\mathcal{O}_K)$.

The choice of the quadratic form $q = 2\det$ deserves comment. On Hermitian $2\times 2$ matrices the determinant is an integer-valued quadratic form, but its polarisation is not integral on the diagonal generators unless one rescales; doubling the determinant produces an *even* integral form whose associated bilinear form has integer Gram entries in the chosen basis. This is the standard normalisation under which $\mathrm{Herm}_2(\mathcal{O}_K)$ becomes an even lattice of signature $(1,3)$, the natural arithmetic model for the action of the Bianchi group on hyperbolic $3$-space. The determinant of its Gram matrix is then a basis-independent invariant — the lattice discriminant — and it is this invariant we identify with $D_K$.

Our main result is a clean, exact identity:
$$\det \mathrm{Gram}(S_K) = D_K,$$
where $D_K$ is the fundamental discriminant of $K$ and the Gram matrix is computed in a specific natural basis. The result is stated in the introduction as a conjecture and is established here in full, with a proof that cleanly separates an algebraic core from a number-theoretic evaluation.

### Conventions

Throughout, $d < 0$ is squarefree and $K = \mathbb{Q}(\sqrt{d})$. Complex conjugation on $K$ is denoted $z \mapsto \overline{z}$. For $z \in K$ we write $\mathrm{Tr}(z) = z + \overline{z}$ and $N(z) = z\overline{z}$ for the trace and norm. We abbreviate $T = \mathrm{Tr}(\omega)$ and $M = N(\omega)$.

## 2. Definitions

### 2.1 The field, its ring of integers, and its discriminant

**Definition 2.1 (Ring of integers).** The ring of integers of $K = \mathbb{Q}(\sqrt{d})$ is $\mathcal{O}_K = \mathbb{Z}[\omega]$ with $\mathbb{Z}$-basis $\{1, \omega\}$, where
$$\omega = \begin{cases} \dfrac{1+\sqrt{d}}{2} & d \equiv 1 \pmod 4, \\[1mm] \sqrt{d} & \text{otherwise.}\end{cases}$$

**Definition 2.2 (Trace and norm of $\omega$).** With $\omega$ as above,
$$T = \mathrm{Tr}(\omega) = \begin{cases} 1 & d \equiv 1 \pmod 4, \\ 0 & \text{otherwise,}\end{cases} \qquad M = N(\omega) = \begin{cases} \dfrac{1-d}{4} & d \equiv 1 \pmod 4, \\ -d & \text{otherwise.}\end{cases}$$
These are encoded in Lean as `omegaTrace d` and `omegaNorm d`. The minimal polynomial of $\omega$ is $x^2 - Tx + M$.

**Definition 2.3 (Fundamental discriminant).** The fundamental discriminant of $K$ is
$$D_K = \begin{cases} d & d \equiv 1 \pmod 4, \\ 4d & \text{otherwise,}\end{cases}$$
encoded in Lean as `fundamentalDisc d`.

### 2.2 The Hermitian Bianchi lattice and its quadratic form

**Definition 2.4 (The lattice $S_K$).** Let
$$S_K = \mathrm{Herm}_2(\mathcal{O}_K) = \left\{ \begin{pmatrix} a & b \\ \overline{b} & c\end{pmatrix} : a, c \in \mathbb{Z},\ b \in \mathcal{O}_K \right\}.$$
Writing $b = x + y\omega$ with $x, y \in \mathbb{Z}$, the lattice is coordinatised by $(a, c, x, y) \in \mathbb{Z}^4$. It is a free $\mathbb{Z}$-module of rank $4$. The chosen ordered basis is: the diagonal matrix unit $E_{11}$ (i.e. $a=1$), the diagonal matrix unit $E_{22}$ (i.e. $c=1$), the off-diagonal generator with $b = 1$, and the off-diagonal generator with $b = \omega$.

**Definition 2.5 (Hermitian determinant).** For coordinates $(a, c, x, y)$, the determinant of the underlying Hermitian matrix is
$$\det A = ac - N(b) = ac - (x^2 + Txy + My^2),$$
encoded in Lean as `hermDet T M a c x y`.

**Definition 2.6 (Quadratic form $q$).** The quadratic form on $S_K$ is $q(A) = 2\det A$. In coordinates,
$$q(a, c, x, y) = 2ac - 2x^2 - 2T\,xy - 2M\,y^2,$$
encoded in Lean as `qform T M v` where $v = (v_0, v_1, v_2, v_3) = (a, c, x, y)$.

**Definition 2.7 (Polarising bilinear form $B$).** The symmetric bilinear form associated to $q$ is
$$B(u, v) = (u_0 v_1 + u_1 v_0) - 2\,u_2 v_2 - T(u_2 v_3 + u_3 v_2) - 2M\,u_3 v_3,$$
encoded in Lean as `bil T M u v`.

**Definition 2.8 (Gram matrix).** The Gram matrix of $B$ in the basis of Definition 2.4 is
$$\mathrm{Gram}(S_K)_{ij} = B(e_i, e_j), \qquad e_i = \text{$i$-th standard basis vector of } \mathbb{Z}^4,$$
encoded in Lean as `gramMatrix T M`.

## 3. Main Results

### 3.1 The bilinear form polarises the quadratic form

**Lemma 3.1 (`bil_symm`).** $B$ is symmetric: $B(u, v) = B(v, u)$ for all $u, v$.

*Proof sketch.* Immediate from the symmetric shape of Definition 2.7; each term is invariant under swapping $u \leftrightarrow v$. Formally discharged by `ring`. $\square$

**Lemma 3.2 (`bil_self`).** $B(v, v) = q(v)$ for all $v$.

*Proof sketch.* Substituting $u = v$ in Definition 2.7 collapses $u_0 v_1 + u_1 v_0$ to $2 v_0 v_1$, $u_2 v_2$ to $v_2^2$, the cross term to $2 v_2 v_3$, and $u_3 v_3$ to $v_3^2$, reproducing Definition 2.6 term by term. Formally by `ring`. $\square$

**Lemma 3.3 (`bil_polar`).** $B$ is the polarisation of $q$:
$$\mathrm{polar}(q)(u, v) := q(u+v) - q(u) - q(v) = 2\,B(u, v).$$

*Proof sketch.* Expand $q(u+v)$ using Definition 2.6 with $(u+v)_i = u_i + v_i$. Every pure term in $u$ or $v$ cancels against $-q(u)$ and $-q(v)$, leaving exactly the cross terms, which assemble into $2B(u,v)$. Formally by `ring` after unfolding `QuadraticMap.polar`. $\square$

Lemmas 3.1–3.3 certify that $B$ is the correct integral symmetric bilinear form attached to $q$, so that the Gram matrix faithfully encodes the geometry of $(S_K, q)$.

### 3.2 The quadratic form is twice the determinant

**Lemma 3.4 (`qform_eq_two_hermDet`).** For all $a, c, x, y$,
$$q(a, c, x, y) = 2\det A = 2\,\big(ac - (x^2 + Txy + My^2)\big).$$

*Proof sketch.* Direct expansion: $2(ac - x^2 - Txy - My^2) = 2ac - 2x^2 - 2Txy - 2My^2$, matching Definition 2.6. Formally by `ring` after evaluating the vector entries. $\square$

This lemma certifies that $q$ really is the defining quadratic form $2\det$ of the Hermitian Bianchi lattice, not merely a convenient polynomial.

### 3.3 Explicit shape and determinant of the Gram matrix

**Lemma 3.5 (`gramMatrix_eq`).** The Gram matrix has the explicit block-diagonal shape
$$\mathrm{Gram}(S_K) = \begin{pmatrix} 0 & 1 & 0 & 0 \\ 1 & 0 & 0 & 0 \\ 0 & 0 & -2 & -T \\ 0 & 0 & -T & -2M \end{pmatrix}.$$

*Proof sketch.* Evaluate $B(e_i, e_j)$ for each of the sixteen pairs $(i,j)$ using Definition 2.7. The diagonal-unit basis vectors $e_0, e_1$ interact only through the $u_0 v_1 + u_1 v_0$ term, producing the hyperbolic block $\left(\begin{smallmatrix}0&1\\1&0\end{smallmatrix}\right)$; the off-diagonal generators $e_2, e_3$ interact only through the remaining terms, producing $\left(\begin{smallmatrix}-2&-T\\-T&-2M\end{smallmatrix}\right)$; all cross terms between the two pairs vanish. Formally by `fin_cases` on $i, j$ and `simp`. $\square$

The two diagonal blocks have clear meaning. The top-left block $\left(\begin{smallmatrix}0&1\\1&0\end{smallmatrix}\right)$ is the **hyperbolic plane** $U$, the unimodular even indefinite rank-two lattice. The bottom-right block $\left(\begin{smallmatrix}-2&-T\\-T&-2M\end{smallmatrix}\right)$ is $(-1)$ times the Gram matrix of the **binary norm form** $N(x + y\omega) = x^2 + Txy + My^2$ of $\mathcal{O}_K$.

**Theorem 3.6 (`det_gramMatrix`; algebraic core).** For all integers $T, M$,
$$\det \mathrm{Gram}(S_K) = T^2 - 4M.$$

*Proof sketch.* By Lemma 3.5 the matrix is block-diagonal. Reindexing through `finSumFinEquiv` exhibits it as $\mathrm{fromBlocks}\,U\,0\,0\,B_2$ with $U = \left(\begin{smallmatrix}0&1\\1&0\end{smallmatrix}\right)$ and $B_2 = \left(\begin{smallmatrix}-2&-T\\-T&-2M\end{smallmatrix}\right)$. The block-triangular determinant lemma `Matrix.det_fromBlocks_zero₂₁` gives $\det = \det U \cdot \det B_2$. Each $2\times 2$ determinant is computed by `Matrix.det_fin_two_of`: $\det U = -1$ and $\det B_2 = (-2)(-2M) - (-T)(-T) = 4M - T^2$. Their product is $(-1)(4M - T^2) = T^2 - 4M$, closed by `ring`. $\square$

The expression $T^2 - 4M$ is precisely the discriminant of the monic quadratic $x^2 - Tx + M$, the minimal polynomial of $\omega$. This is the entire algebraic content: the lattice determinant is the polynomial discriminant of the generator $\omega$, independent of any number-theoretic interpretation.

### 3.4 Number-theoretic evaluation

**Lemma 3.7 (`discriminantInvariant`).** For all integers $d$,
$$T^2 - 4M = D_K, \quad\text{i.e.}\quad (\texttt{omegaTrace}\,d)^2 - 4\,(\texttt{omegaNorm}\,d) = \texttt{fundamentalDisc}\,d.$$

*Proof sketch.* Split on the congruence $d \equiv 1 \pmod 4$.
- If $d \equiv 1 \pmod 4$: $T = 1$, $M = \frac{1-d}{4}$. The integrality of $\frac{1-d}{4}$ (a side condition handled by `omega`, since $1 - d \equiv 0 \pmod 4$) gives $4M = 1 - d$, so $T^2 - 4M = 1 - (1 - d) = d = D_K$.
- Otherwise: $T = 0$, $M = -d$, so $T^2 - 4M = 0 - 4(-d) = 4d = D_K$; closed by `ring`. $\square$

The case split here is exactly the case split defining $\omega$ and $D_K$: feeding the algebraic core the correct trace and norm — including the subtle half-integer generator when $d \equiv 1 \pmod 4$ — makes the field discriminant appear automatically.

### 3.5 The main theorems

**Theorem 3.8 (`detGram_eq_fundamentalDisc`; general form).** For every integer $d$,
$$\det \mathrm{Gram}\big(\texttt{omegaTrace}\,d,\ \texttt{omegaNorm}\,d\big) = \texttt{fundamentalDisc}\,d.$$

*Proof sketch.* Chain Theorem 3.6 and Lemma 3.7: $\det \mathrm{Gram} = T^2 - 4M = D_K$. $\square$

**Theorem 3.9 (`discriminant_S_K`; the conjecture).** Let $d < 0$ be squarefree and $K = \mathbb{Q}(\sqrt{d})$. Then
$$\det \mathrm{Gram}(S_K) = \begin{cases} d & d \equiv 1 \pmod 4, \\ 4d & \text{otherwise.}\end{cases}$$

*Proof sketch.* This is Theorem 3.8 with `fundamentalDisc` unfolded into its two branches. The hypotheses $d < 0$ and $\mathrm{Squarefree}\,d$ pin down the imaginary quadratic field $K$ and its ring of integers $\mathcal{O}_K$; they are part of the stated conjecture but are not needed for the determinant identity, which holds for every integer $d$. $\square$

### 3.6 Worked examples

We record explicit evaluations to make the identity concrete. In each row $\det \mathrm{Gram}$ is the product of the two block determinants $(-1)\cdot(4M-T^2)$.

| $d$ | $d \bmod 4$ | $\omega$ | $T$ | $M$ | $T^2-4M$ | $D_K$ | $\det \mathrm{Gram}(S_K)$ |
|---:|:---:|:---:|---:|---:|---:|---:|---:|
| $-1$ | $3$ | $\sqrt{-1}$ | $0$ | $1$ | $-4$ | $-4$ | $-4$ |
| $-2$ | $2$ | $\sqrt{-2}$ | $0$ | $2$ | $-8$ | $-8$ | $-8$ |
| $-3$ | $1$ | $\tfrac{1+\sqrt{-3}}{2}$ | $1$ | $1$ | $-3$ | $-3$ | $-3$ |
| $-7$ | $1$ | $\tfrac{1+\sqrt{-7}}{2}$ | $1$ | $2$ | $-7$ | $-7$ | $-7$ |
| $-11$ | $1$ | $\tfrac{1+\sqrt{-11}}{2}$ | $1$ | $3$ | $-11$ | $-11$ | $-11$ |
| $-15$ | $1$ | $\tfrac{1+\sqrt{-15}}{2}$ | $1$ | $4$ | $-15$ | $-15$ | $-15$ |

Take $d = -3$, the Eisenstein case. Here $\omega = \tfrac{1+\sqrt{-3}}{2}$ is a primitive sixth root of unity, $T = 1$, $M = 1$, and the off-diagonal block is $\left(\begin{smallmatrix}-2&-1\\-1&-2\end{smallmatrix}\right)$, which is $(-1)$ times the Gram matrix of the $A_2$ root lattice. Its determinant is $4-1 = 3$, and with the hyperbolic factor $-1$ we obtain $\det \mathrm{Gram}(S_K) = -3 = D_K$. The lattice $S_K$ for $d=-3$ is thus $U \oplus A_2(-1)$, an even lattice of signature $(1,3)$.

Take $d = -1$, the Gaussian case. Here $\omega = \sqrt{-1} = i$, $T = 0$, $M = 1$, and the off-diagonal block is $\left(\begin{smallmatrix}-2&0\\0&-2\end{smallmatrix}\right) = -2I_2$, determinant $4$. With the hyperbolic factor $-1$ we get $\det \mathrm{Gram}(S_K) = -4 = 4d = D_K$, reflecting the ramification of $2$ in $\mathbb{Z}[i]$. These two cases exhibit the two branches of the theorem in their cleanest form.

## 4. Discussion

### 4.1 Two layers, cleanly separated

The proof's architecture is its main conceptual contribution. The determinant computation (Theorem 3.6) is a pure linear-algebra identity in the two parameters $T$ and $M$, valid over $\mathbb{Z}$ with no arithmetic input. The number-theoretic content (Lemma 3.7) is the single evaluation $T^2 - 4M = D_K$. The negativity and squarefreeness of $d$ — the hypotheses that make $K$ an honest imaginary quadratic field — never enter the determinant calculation; they serve only to license the *interpretation* of $T^2 - 4M$ as the field discriminant. This separation is what makes the result robust: it would persist verbatim for real quadratic fields ($d > 0$), where the signature of $S_K$ flips from $(1,3)$ to $(2,2)$ but the determinant remains $D_K$.

### 4.2 The block decomposition and the hyperbolic plane

The block-diagonal shape of the Gram matrix (Lemma 3.5) is not an accident of computation but a consequence of the chosen basis: the diagonal matrix units and the off-diagonal generators are mutually orthogonal under $B$. The diagonal block is literally the hyperbolic plane $U$, and the off-diagonal block is $(-1)$ times the binary norm form of $K$. This suggests the lattice-level isometry $S_K \cong U \oplus A$, where $A$ is the negative-definite binary norm form of $K$ — a strengthening of the determinant identity from an equation of integers to an isomorphism of lattices, with $\mathrm{disc}\,S_K = -\mathrm{disc}\,A = D_K$.

### 4.3 Connection to binary quadratic forms

The off-diagonal block carries the form $x^2 + Txy + My^2$, the principal binary quadratic form of discriminant $D_K$ in the sense of Gauss. The $\mathrm{SL}_2(\mathbb{Z})$-class of this block is therefore expected to be a complete invariant of the genus of $S_K$, linking the four-dimensional Hermitian lattice to the classical theory of the form class group.

### 4.4 K3 surfaces and Néron–Severi lattices

Lattices built from $U$ and the $E_8$ root lattice are the backbone of the classification of K3 surfaces, whose total cohomology lattice is $\Lambda_{K3} = U^3 \oplus E_8(-1)^2$. Embedding a rank-four arithmetic lattice such as $S_K$ (or a scaling $S_K(N)$) as a Néron–Severi lattice makes the determinant we computed control the discriminant of the orthogonal (transcendental) complement; a clean determinant $D_K$, free of parasitic factors, is exactly what permits an undistorted transfer of the field's arithmetic into the geometry of the surface.

## 5. Algorithms

The results are fully constructive and computable. We highlight three algorithms, given in pseudocode here and implemented in the accompanying `demo.py`.

**Algorithm A (Field invariants from $d$).** Given squarefree $d < 0$, compute $(\omega\text{-data}, T, M, D_K)$ by branching on $d \bmod 4$. Constant time.

**Algorithm B (Gram matrix assembly).** Given $(T, M)$, output the $4\times 4$ block-diagonal Gram matrix of Definition 2.8. Constant time.

**Algorithm C (Determinant verification).** Compute the integer determinant of the assembled Gram matrix (by block factorisation or by exact integer Gaussian elimination) and check equality with $D_K$. The block factorisation runs in constant time; verifying via full $4\times 4$ exact determinant is also constant time.

## 6. Applications

1. **Bianchi groups.** $S_K$ is the lattice of integral Hermitian forms on which $\mathrm{SL}_2(\mathcal{O}_K)$ acts; the determinant identity gives a closed-form covolume-type invariant of the lattice in terms of $D_K$.
2. **Class field theory bridges.** The appearance of the principal binary form of discriminant $D_K$ inside the Gram matrix links the lattice to the form class group $\mathrm{Cl}(D_K)$.
3. **K3 geometry.** Scalings $S_K(N)$ embed into the K3 lattice; the determinant controls the transcendental complement, relevant to Picard-rank-four K3 surfaces.
4. **Computational number theory.** The identity provides an instant, branch-free check that a computed Hermitian lattice has the correct discriminant.

## 7. Future Work

- **Genus invariance of the off-diagonal block.** Prove that the $\mathrm{SL}_2(\mathbb{Z})$-class of the binary block $\left(\begin{smallmatrix}-2&-T\\-T&-2M\end{smallmatrix}\right)$ is a complete invariant of the genus of $S_K$, and that two fields give isometric off-diagonal blocks iff their discriminants agree.
- **Lattice isometry $S_K \cong U \oplus A$.** Upgrade the block-determinant decomposition to a genuine isometry of integral lattices, yielding signature $(1,3)$ and $\mathrm{disc}\,S_K = D_K$ directly.
- **Even, 2-elementary structure and K3 transcendental lattices.** Determine the full discriminant *group* of $S_K(2)$ (not merely its order) and the discriminant $16 N^4 |D_K|$ of the complement of $S_K(2N)$ in $\Lambda_{K3}$.
- **Real quadratic and Bianchi analogues.** Confirm that the identity $\det \mathrm{Gram} = T^2 - 4M = D_K$ survives for $d > 0$ with signature $(2,2)$, exhibiting $\det \mathrm{Gram}$ as a sign-insensitive field invariant while the signature detects the sign of $d$.

## 8. Conclusion

We have established, with full formal verification, that the Gram determinant of the Hermitian Bianchi lattice $S_K = \mathrm{Herm}_2(\mathcal{O}_K)$ under the quadratic form $q = 2\det$ equals the fundamental discriminant $D_K$ of the imaginary quadratic field $K = \mathbb{Q}(\sqrt{d})$. The proof isolates a robust algebraic core, $\det \mathrm{Gram} = T^2 - 4M$, valid for all parameters, from a single number-theoretic evaluation $T^2 - 4M = D_K$. The block-diagonal structure of the Gram matrix — a hyperbolic plane orthogonal to the binary norm form of $K$ — both drives the computation and points toward the lattice-isometry, class-group, and K3-geometric refinements catalogued above.
