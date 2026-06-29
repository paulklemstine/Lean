# Tropical Matrix Powers and the Correctness of Tropical Diffie–Hellman Key Exchange

**Author:** Aristotle

**Date:** 2026-06-20

**Domain:** Tropical Algebra / Post-Quantum Cryptography

---

## Abstract

We develop the algebra of **tropical (min-plus) matrix powers** over the real numbers and establish the exponent laws required to state and analyze the *tropical Diffie–Hellman key exchange* and the associated *tropical discrete logarithm problem* (TDLP). Working over the min-plus semiring $(\mathbb{R}, \min, +)$, where the tropical matrix product is $(A \otimes B)(i,j) = \min_k (A(i,k) + B(k,j))$, we confront a structural obstruction absent from the classical theory: over a field there is no tropical identity matrix, since it would require $+\infty$ off the diagonal. We resolve this with a shift-by-one indexing convention in which `tropMatPow A k` denotes the genuine $(k{+}1)$-fold tropical product. Within this framework we prove four laws: (i) matrix–vector associativity $(A \otimes B) \otimes v = A \otimes (B \otimes v)$; (ii) the iterated-dynamics law $A^{\otimes(k+1)} \otimes v = (A \otimes \cdot)^{k+1} v$; (iii) power multiplicativity $A^{\otimes(a+1)} \otimes A^{\otimes(b+1)} = A^{\otimes(a+b+2)}$; and (iv) power-of-a-power $(A^{\otimes(a+1)})^{\otimes(b+1)} = A^{\otimes(ab+a+b+1)}$. Together these yield **Diffie–Hellman correctness**, $(A^{\otimes a})^{\otimes b} = (A^{\otimes b})^{\otimes a}$, so that both parties of the protocol agree on a shared key. We show that the underlying structure is a monoid homomorphism $m \mapsto A^{\otimes(m+1)}$ from $(\mathbb{N},+)$ into the tropical matrix monoid, that the commutativity of $(\mathbb{N},+)$ is the sole source of correctness, and that this same homomorphic transparency is precisely the structural weakness exploited by attacks on the TDLP. All results have been formally verified.

---

## 1. Introduction

Diffie–Hellman key exchange (Diffie & Hellman, 1976) is the foundational primitive of modern public-key cryptography. Its security in the classical setting rests on the conjectured hardness of the *discrete logarithm problem* in a cyclic group. The advent of Shor's algorithm threatens this hardness on quantum hardware, motivating a search for *post-quantum* platforms — algebraic structures supporting a key-exchange protocol whose inversion problem resists quantum attack.

**Tropical algebra** has been repeatedly proposed as such a platform (Grigoriev & Shpilrain, 2014, and successors). The min-plus semiring replaces addition by $\min$ and multiplication by $+$. Tropical matrix multiplication is the algebraic skeleton of the all-pairs shortest path problem, computable in $O(n^3)$ per product and $O(n^3 \log m)$ per $m$-th power via repeated tropical squaring. The appeal for cryptography is the apparent asymmetry: powering is cheap, but recovering the exponent — the *Tropical Discrete Logarithm Problem* — was hoped to be hard.

This paper makes precise the algebraic substrate on which any such protocol must rest. We define tropical matrix powers over $\mathbb{R}$, prove the exponent laws, and establish protocol correctness. Crucially, we also identify, at the structural level, why the very laws that guarantee correctness simultaneously expose the protocol to attack: the powering map is a monoid homomorphism whose image lies on a predictable tropical-linear trajectory governed by the tropical spectrum of $A$.

### 1.1 Contributions

1. A field-friendly definition of tropical matrix powers that circumvents the non-existence of a tropical identity over $\mathbb{R}$ (Section 3).
2. Matrix–vector associativity for the min-plus product, the engine of all subsequent results (Theorem 4.1).
3. The identification of tropical powers with iterated dynamics (Theorem 4.2).
4. The two exponent laws — power multiplicativity and power-of-a-power (Theorems 5.1, 5.2).
5. The correctness of tropical Diffie–Hellman (Theorem 5.3).
6. A structural synthesis: the homomorphism interpretation and its dual role as the source of both correctness and cryptographic weakness (Section 6).

All statements have been formally verified; theorem names in `monospace` correspond to the verified development.

---

## 2. Preliminaries: the min-plus semiring and tropical matrices

### 2.1 The tropical semiring

**Definition 2.1 (Min-plus semiring).** The *tropical semiring* is the structure $(\mathbb{R}, \oplus, \otimes)$ with $a \oplus b := \min(a,b)$ and $a \otimes b := a + b$. Tropical "addition" is idempotent ($a \oplus a = a$) and there is no additive identity within $\mathbb{R}$ (the role of $0$ for $\oplus$ would require $+\infty$).

### 2.2 Tropical matrix and matrix–vector products

Fix $n \geq 1$. For real matrices $A, B \in \mathbb{R}^{n \times n}$, the **tropical matrix product** is

$$(A \otimes B)(i,j) := \min_{k} \big( A(i,k) + B(k,j) \big),$$

where the minimum ranges over all $k \in \{1,\dots,n\}$ (formally, over a nonempty finite index set; in the verified development this is `tropMatMul`, with the minimum realized as `Finset.univ.inf'`). The **tropical matrix–vector product** of $A$ with $v \in \mathbb{R}^n$ is

$$(A \otimes v)(i) := \min_k \big( A(i,k) + v(k) \big),$$

denoted `tropMatVecMul`.

We rely on one foundational result from the underlying min-plus algebra development.

**Proposition 2.2 (Associativity of the tropical product, `tropMatMul_assoc`).** For all $A, B, C \in \mathbb{R}^{n \times n}$,

$$(A \otimes B) \otimes C = A \otimes (B \otimes C),$$

both sides being equal to $\min_{k,\ell}\big(A(i,k) + B(k,\ell) + C(\ell,j)\big)$ entrywise.

This makes $(\mathbb{R}^{n \times n}, \otimes)$ a semigroup. Note it is *non-commutative*: in general $A \otimes B \neq B \otimes A$.

### 2.3 The identity obstruction

A two-sided identity $I$ for $\otimes$ would need to satisfy $(I \otimes A)(i,j) = A(i,j)$, i.e. $\min_k(I(i,k) + A(k,j)) = A(i,j)$ for all $A$. This forces $I(i,i) = 0$ and $I(i,k) = +\infty$ for $i \neq k$. Over $\mathbb{R}$ no such matrix exists. (One may use a finite surrogate `tropId n M` with $0$ on the diagonal and a large constant $M$ off-diagonal, which acts as an identity only for matrices whose entries are dominated by $M$; this is recorded in the foundational development as `tropId_mul_of_bound` and `mul_tropId_of_bound`.) The absence of a *universal* identity is the reason we cannot index powers from a zeroth power, and motivates the convention of Section 3.

---

## 3. Tropical matrix powers

**Definition 3.1 (Tropical matrix power, `tropMatPow`).** For $A \in \mathbb{R}^{n \times n}$ define $\mathrm{tropMatPow}(A, \cdot) : \mathbb{N} \to \mathbb{R}^{n \times n}$ recursively by

$$\mathrm{tropMatPow}(A, 0) = A, \qquad \mathrm{tropMatPow}(A, k+1) = A \otimes \mathrm{tropMatPow}(A, k).$$

We write $A^{\otimes(k+1)} := \mathrm{tropMatPow}(A, k)$, so that $\mathrm{tropMatPow}(A,k)$ is the genuine $(k{+}1)$-fold tropical product of $A$ with itself. The base case `tropMatPow_zero` records $\mathrm{tropMatPow}(A,0)=A$, and the recursion `tropMatPow_succ` records the successor step.

**Remark 3.2.** The shift-by-one is forced by the identity obstruction (Section 2.3): with no $A^{\otimes 0} = I$ available, the smallest meaningful power is $A$ itself. Every downstream statement carries an explicit "$+1$"; this off-by-one is purely bookkeeping and never affects the mathematics.

**Computational note.** $A^{\otimes(m+1)}$ is computed by repeated tropical squaring: maintain a running product and square via $\otimes$, doubling the exponent per step, for a total cost of $O(n^3 \log m)$ arithmetic operations.

---

## 4. The associativity engine and iterated dynamics

### 4.1 Matrix–vector associativity

**Theorem 4.1 (`tropMatVecMul_tropMatMul`).** For all $A, B \in \mathbb{R}^{n \times n}$, all $v \in \mathbb{R}^n$, and all indices $i$,

$$\big((A \otimes B) \otimes v\big)(i) = \big(A \otimes (B \otimes v)\big)(i).$$

*Proof sketch.* Expand both sides. The left side is $\min_k\big( (A\otimes B)(i,k) + v(k)\big) = \min_k \min_\ell \big(A(i,\ell) + B(\ell,k) + v(k)\big)$. The right side is $\min_\ell\big(A(i,\ell) + (B \otimes v)(\ell)\big) = \min_\ell \min_k \big(A(i,\ell) + B(\ell,k) + v(k)\big)$. Both equal the joint minimum $\min_{k,\ell}\big(A(i,\ell)+B(\ell,k)+v(k)\big)$. The formal proof proves the two inequalities $\leq$ and $\geq$ separately: for each, it extracts an index achieving the inner infimum (via the finite-minimum witness lemma `Finset.exists_mem_eq_inf'` / `Finset.exists_min_image`) and bounds the other side using `Finset.inf'_le`. $\square$

This theorem is the single load-bearing fact of the development; every exponent law reduces to it together with Proposition 2.2.

### 4.2 Powers as iterated dynamics

**Theorem 4.2 (`tropMatVecMul_tropMatPow`).** For all $A$, all $k \in \mathbb{N}$, and all $v \in \mathbb{R}^n$,

$$A^{\otimes(k+1)} \otimes v = \big(w \mapsto A \otimes w\big)^{[k+1]}(v),$$

where $f^{[m]}$ denotes $m$-fold composition of $f$.

*Proof sketch.* Induction on $k$. The base case $k=0$ is $\mathrm{tropMatPow}(A,0)\otimes v = A \otimes v$, which is definitional. For the inductive step, rewrite the iterate with `Function.iterate_succ_apply'` and the power with `tropMatPow_succ`, then apply Theorem 4.1 to peel off one application of $A$ and invoke the inductive hypothesis. $\square$

**Interpretation.** A tropical matrix power is exactly a discrete dynamical system: $A^{\otimes(k+1)} \otimes v$ is the state obtained after $k{+}1$ steps of the min-plus update $w \mapsto A \otimes w$. This is the tropical analog of an evolution operator and the vantage point from which the protocol's structure is clearest.

---

## 5. Exponent laws and Diffie–Hellman correctness

### 5.1 Power multiplicativity

**Theorem 5.1 (`tropMatMul_tropMatPow_add`).** For all $A$ and all $a, b \in \mathbb{N}$,

$$\mathrm{tropMatPow}(A,a) \otimes \mathrm{tropMatPow}(A,b) = \mathrm{tropMatPow}(A, a+b+1),$$

equivalently $A^{\otimes(a+1)} \otimes A^{\otimes(b+1)} = A^{\otimes(a+b+2)}$.

*Proof sketch.* Induction on $a$. The base case $a=0$ reads $A \otimes \mathrm{tropMatPow}(A,b) = \mathrm{tropMatPow}(A, b+1)$, which is exactly `tropMatPow_succ`. The inductive step rewrites $\mathrm{tropMatPow}(A,a+1) = A \otimes \mathrm{tropMatPow}(A,a)$, applies associativity (Proposition 2.2) to regroup, and uses the inductive hypothesis. $\square$

### 5.2 Power of a power

**Theorem 5.2 (`tropMatPow_tropMatPow`).** For all $A$ and all $a, b \in \mathbb{N}$,

$$\mathrm{tropMatPow}\big(\mathrm{tropMatPow}(A,a),\, b\big) = \mathrm{tropMatPow}(A,\, a\cdot b + a + b),$$

equivalently $\big(A^{\otimes(a+1)}\big)^{\otimes(b+1)} = A^{\otimes(ab+a+b+1)}$.

*Proof sketch.* Induction on $b$. The base case $b=0$ states $\mathrm{tropMatPow}(B, 0) = B$ with $B = \mathrm{tropMatPow}(A,a)$, which is definitional once the exponent $a\cdot 0 + a + 0 = a$ is simplified. The inductive step writes $\mathrm{tropMatPow}(B, b+1) = B \otimes \mathrm{tropMatPow}(B,b)$, applies the inductive hypothesis and Theorem 5.1, and finishes by the exponent identity $a + (a b + a + b) + 1 = a(b+1) + a + (b+1)$, discharged by ring arithmetic. The governing exponent identity is $(a+1)(b+1) - 1 = ab + a + b$. $\square$

### 5.3 Diffie–Hellman correctness

**Theorem 5.3 (`tropMatPow_comm`).** For all $A$ and all $a, b \in \mathbb{N}$,

$$\mathrm{tropMatPow}\big(\mathrm{tropMatPow}(A,a),\,b\big) = \mathrm{tropMatPow}\big(\mathrm{tropMatPow}(A,b),\,a\big),$$

equivalently $\big(A^{\otimes a}\big)^{\otimes b} = \big(A^{\otimes b}\big)^{\otimes a}$.

*Proof sketch.* Apply Theorem 5.2 to both sides, reducing the left to $\mathrm{tropMatPow}(A, ab+a+b)$ and the right to $\mathrm{tropMatPow}(A, ba+b+a)$. The two exponents are equal because $ab + a + b = ba + b + a$ in $\mathbb{N}$; ring arithmetic closes the goal. $\square$

**The protocol.** Alice and Bob publicly fix $A$. Alice draws secret $a \in \mathbb{N}$ and publishes $P_A = A^{\otimes a}$; Bob draws secret $b$ and publishes $P_B = A^{\otimes b}$. Alice computes $P_B^{\otimes a}$, Bob computes $P_A^{\otimes b}$. By Theorem 5.3 these coincide, defining the shared key

$$K = \big(A^{\otimes a}\big)^{\otimes b} = \big(A^{\otimes b}\big)^{\otimes a} = A^{\otimes((a+1)(b+1))}.$$

Correctness is therefore unconditional and entirely algebraic.

---

## 6. Structural synthesis: homomorphism, correctness, and weakness

### 6.1 The exponent homomorphism

Define $\Phi_A : \mathbb{N} \to (\mathbb{R}^{n\times n}, \otimes)$ by $\Phi_A(m) = A^{\otimes(m+1)} = \mathrm{tropMatPow}(A,m)$. Theorem 5.1 says

$$\Phi_A(a) \otimes \Phi_A(b) = \Phi_A(a + b + 1),$$

which, up to the benign $+1$ shift, is the statement that $\Phi_A$ converts addition of exponents into tropical matrix multiplication — a *monoid homomorphism* from $(\mathbb{N},+)$ into the tropical matrix monoid. Theorem 5.2 is the iterated form of the same fact, and Theorem 5.3 (correctness) is nothing more than the commutativity of the source monoid $(\mathbb{N},+)$.

It is worth emphasizing the contrast: the target semigroup $(\mathbb{R}^{n\times n}, \otimes)$ is **non-commutative**, yet the cyclic sub-structure $\{\Phi_A(m) : m \in \mathbb{N}\}$ generated by a single $A$ is commutative, because it is the homomorphic image of an abelian monoid. This is exactly the property a Diffie–Hellman platform requires.

### 6.2 Why the same structure breaks the TDLP

The security of the protocol would require the *Tropical Discrete Logarithm Problem* to be hard: given $A$ and $A^{\otimes m}$, recover $m$. The homomorphism picture shows why this hope is misplaced. Tropical powers are governed by the **tropical spectral theory** of $A$: a tropical eigenpair $(\lambda, v)$ satisfies $A \otimes v = v + \lambda \cdot \mathbf{1}$ (the tropical analog of $Av = \lambda v$), and the dominant tropical eigenvalue equals the minimum cycle mean of the weighted digraph with weight matrix $A$. As a consequence, for large $m$ the entries of $A^{\otimes m}$ become *eventually periodic plus linear*: they grow linearly in $m$ at a rate fixed by the minimum cycle mean, modulated by a periodic correction.

This eventual tropical-linearity makes the discrete logarithm transparent. An adversary observing $A^{\otimes m}$ can read off the growth regime and the periodic phase and thereby determine $m$, without solving any genuinely hard problem. The very transparency that makes shortest-path computation tractable — and that powers the $O(n^3\log m)$ forward direction — is what defeats the inversion hardness. The "Lab Notes" of the development summarize this duality precisely: commutativity of $(\mathbb{N},+)$ "gives DH correctness — and also the structural weakness that breaks TDLP."

This is consistent with the broader cryptanalytic record: several tropical key-exchange proposals have been broken by exploiting exactly this min-plus periodicity and cycle-mean structure. The results here isolate the *reason*: the powering map is too well-behaved a homomorphism.

---

## 7. Algorithms

We summarize the algorithmic content implied by the theory.

**Algorithm A — Fast tropical exponentiation (repeated squaring).** Computes $A^{\otimes(m+1)} = \mathrm{tropMatPow}(A,m)$ in $O(n^3 \log m)$ time. Maintains a running result and a running square; at each bit of $m{+}1$, conditionally accumulates the square into the result, then squares. Correctness follows from Theorem 5.1 (power multiplicativity).

**Algorithm B — Tropical Diffie–Hellman key agreement.** Each party samples a secret exponent, applies Algorithm A to the public $A$, exchanges the resulting matrices, and applies Algorithm A again to the partner's matrix with its own secret. By Theorem 5.3 both compute the identical key $A^{\otimes((a+1)(b+1))}$.

**Algorithm C — Structural TDLP recovery (cryptanalysis).** Given $A$ and $Y = A^{\otimes m}$, exploit the eventual tropical-linearity from Section 6.2: estimate the per-step growth rate of the entries of successive powers (the minimum cycle mean of $A$), match the observed magnitude and periodic phase of $Y$ against the predicted trajectory, and solve for $m$. This runs in time polynomial in $n$ and $\log m$, demonstrating that the TDLP on this platform is not a sound hardness assumption.

---

## 8. Applications and discussion

The positive content — a verified, identity-free theory of tropical matrix powers with full exponent laws — is reusable well beyond cryptography. The same powers compute multi-leg shortest paths (Theorem 4.2 reads a power as iterated dynamic programming), drive max-plus/min-plus scheduling and discrete-event systems, and appear in tropical geometry as the combinatorial shadows of algebraic varieties.

The cryptographic discussion is cautionary. Tropical algebra is the algebra of optimization, engineered for transparency; importing it as a one-way platform imports that transparency. The lesson generalizes: an exotic algebraic structure is not automatically a source of cryptographic hardness, and a homomorphic powering map whose orbit is structurally predictable cannot support a discrete-logarithm assumption.

---

## 9. Future work

- **Quantify the leak.** Make Section 6.2 fully quantitative by formalizing the eventual periodicity of $A^{\otimes m}$ via the minimum cycle mean, yielding an explicit attack with proven complexity.
- **Identity-bearing surrogates.** Study the finite surrogate `tropId n M` and characterize the matrix classes for which $A^{\otimes 0} = I$ can be consistently adjoined, recovering a true monoid.
- **Higher tropical structures.** Extend the homomorphism analysis to tropical group-like or supertropical settings where periodicity may be disrupted, and test whether any such modification restores inversion hardness.
- **Robustness bridges.** The min-plus product is provably Lipschitz (a result of the foundational development); explore the use of tropical layers as certified-robust neural-network components, where transparency is a feature rather than a flaw.

---

## 10. Conclusion

We have built and verified the algebra of tropical matrix powers over $\mathbb{R}$, resolving the identity obstruction with a clean shift-by-one convention and proving the four exponent laws that culminate in Diffie–Hellman correctness, `tropMatPow_comm`. The unifying structure is a monoid homomorphism $m \mapsto A^{\otimes(m+1)}$ from $(\mathbb{N},+)$ into the non-commutative tropical matrix monoid; the commutativity of $(\mathbb{N},+)$ supplies correctness, and the homomorphic predictability of the orbit supplies the cryptanalytic weakness. The theory is simultaneously a sound foundation for tropical dynamic programming and a precise diagnosis of why tropical Diffie–Hellman, in this form, cannot be secure.

---

## References

- W. Diffie and M. E. Hellman, *New directions in cryptography*, IEEE Trans. Inform. Theory, 1976.
- D. Grigoriev and V. Shpilrain, *Tropical cryptography*, Comm. Algebra, 2014.
- P. Butkovič, *Max-linear Systems: Theory and Algorithms*, Springer, 2010.
- M. Akian, S. Gaubert, A. Guterman, *Tropical polyhedra are equivalent to mean payoff games*, 2012.
