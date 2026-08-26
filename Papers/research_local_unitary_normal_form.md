# A Local-Unitary Normal Form for Maximally Entangled Two-Qubit States

**Author:** Aristotle
**Date:** 2026-08-26

## Abstract

A pure state of two qubits is encoded by a complex $2\times2$ amplitude matrix $M$, whose squared Frobenius norm $\|M\|_F^2$ is the total probability and whose *concurrence* is $C(M) = 2|\det M|$. We give a complete, self-contained analysis of the extremal problem "maximize $|\det M|$ subject to $\|M\|_F^2 = 1$".

We prove the sharp Hadamard-type inequality $2|\det M| \le \|M\|_F^2$ for all complex $2\times2$ matrices, hence $C \le 1$ on normalized states, from a single application of the two-dimensional Lagrange (Cauchy–Binet) identity together with the arithmetic–geometric mean inequality. Analyzing the equality case yields the **row classification**: the rows of a normalized maximizer are orthogonal and each of squared length $\tfrac12$; equivalently the reduced density matrix $\rho = MM^{\dagger}$ equals $\tfrac12 I$, and this condition is also sufficient. Consequently $\sqrt2\,M$ is unitary, which upgrades the classification to a **normal form**: the maximizers are exactly the local-unitary orbit $\{U\Phi V^{\mathsf T} : U,V \in U(2)\}$ of the Bell state $\Phi = \operatorname{diag}(1/\sqrt2, 1/\sqrt2)$. Because $\Phi$ is scalar, either one-sided action is already transitive, and the stabilizer of $\Phi$ in $U(2)\times U(2)$ is $\{(U,\overline{U})\}$.

We then develop the structure of this orbit. The *flat* maximizers (all amplitudes of modulus $\tfrac12$) form a single orbit of the diagonal torus through $\tfrac12 F_2$, the order-two case of the classification of complex Hadamard matrices; exactly $8$ of the $16$ real sign patterns are maximizers. The Pauli orbit of $\Phi$ is an orthonormal basis of the state space consisting entirely of maximizers, with an explicit expansion formula. Finally we give three quantitative refinements: the linear-entropy identity $C^2 = 2(1-\operatorname{tr}\rho^2)$ with the resulting bound $\operatorname{tr}\rho^2 \ge \tfrac12$; the Schmidt spectrum $\bigl(1\pm\sqrt{1-C^2}\bigr)/2$, degenerate exactly at maximizers and containing $0$ exactly at product states; and the exact stability identity $\|\rho - \tfrac12 I\|_F^2 = (1-C^2)/2 \le 1 - C$, which turns the classification into a quantitative inverse theorem.

**Keywords:** concurrence, local unitary orbit, Bell state, Cauchy–Binet identity, complex Hadamard matrix, Schmidt decomposition, reduced density matrix, extremal rigidity.

---

## 1. Introduction

### 1.1 The extremal problem

Let $M \in \mathbb{C}^{2\times2}$ with entries $m_{ij}$, $i,j \in \{0,1\}$. We regard $M$ as the amplitude matrix of the pure two-qubit state
$$|\psi_M\rangle \;=\; \sum_{i,j\in\{0,1\}} m_{ij}\,|ij\rangle,$$
so that $|m_{ij}|^2$ is the probability of observing the outcome $(i,j)$ and
$$\|M\|_F^2 \;=\; \sum_{i,j} |m_{ij}|^2$$
is the total probability. The state is *normalized* when $\|M\|_F^2 = 1$.

The question we answer completely is:

> Among normalized amplitude matrices, which maximize $|\det M|$, and what is the geometry of the maximizing set?

This is not an idle question. As we recall in §2.3, $\det M$ vanishes exactly on the unentangled (product) states, so its modulus is a canonical measure of entanglement; twice it is Wootters' *concurrence*
$$C(M) \;=\; 2\,|\det M|.$$

The answers are: the maximum is $C = 1$; the maximizing set is a single orbit of the group of local unitaries; and every finer question one can ask about that orbit (its stabilizer, its flat locus, its relationship to orthonormal bases, its stability under perturbation) has an explicit answer obtained from the same two-line computation.

### 1.2 Method

The whole development rests on one classical identity. For $u = (a,b)$ and $v = (c,d)$ in $\mathbb{C}^2$, Lagrange's identity (the $2\times2$ case of Cauchy–Binet) states
$$\bigl|\langle u,v\rangle\bigr|^2 + \bigl|ad-bc\bigr|^2 \;=\; \|u\|^2\,\|v\|^2 ,$$
where $\langle u,v\rangle = a\overline{c} + b\overline{d}$.
Applied to the two rows of $M$ this is the Gram relation
$$\bigl|\langle r_0, r_1\rangle\bigr|^2 + |\det M|^2 = \|r_0\|^2\|r_1\|^2 ,$$
from which the sharp bound follows by AM–GM. Every classification statement in the paper is the *equality case* of this single relation, and every quantitative statement is the identity read with the error terms retained rather than discarded. That is the structural moral of the work: the analytic content of "maximal entanglement" is one equality case of one classical identity.

### 1.3 Organization

§2 fixes definitions and records the two group actions. §3 proves the Gram relation and the sharp bound. §4 proves the row classification and its converse, and derives the unitary rescaling. §5 proves the normal form theorem, one-sided transitivity, and the stabilizer computation. §6 treats product states, the opposite extreme. §7 treats flat maximizers, complex Hadamard matrices, and the count of real sign patterns. §8 treats the Bell basis. §9 gives the purity and Schmidt-spectrum characterizations. §10 gives the stability theorem. §11 discusses applications, and §12 future directions.

---

## 2. Definitions and the local group action

### 2.1 States and invariants

**Definition 2.1 (Amplitude matrix, norm, normalization).** An *amplitude matrix* is a matrix $M \in \mathbb{C}^{2\times2}$. Its *squared Frobenius norm* is $\|M\|_F^2 = \sum_{i,j}|m_{ij}|^2$. The matrix is *normalized* when $\|M\|_F^2 = 1$.

**Definition 2.2 (Concurrence).** The *concurrence* of $M$ is $C(M) = 2\,|\det M|$.

**Definition 2.3 (Sharp maximizer).** $M$ is a *sharp maximizer* if it is normalized and $C(M) = 1$.

The terminology anticipates Theorem 3.4, which shows $C \le 1$ on normalized states; a sharp maximizer is thus exactly a normalized state realizing the maximum.

**Definition 2.4 (Bell state).** $\Phi = \operatorname{diag}\bigl(1/\sqrt2,\,1/\sqrt2\bigr) = \tfrac{1}{\sqrt2}I$. As a state vector this is $\tfrac1{\sqrt2}\bigl(|00\rangle + |11\rangle\bigr)$.

**Definition 2.5 (Rows and their Gram data).** Write $r_0 = (m_{00}, m_{01})$ and $r_1 = (m_{10}, m_{11})$ for the rows of $M$. Set
$$\|r_0\|^2 = |m_{00}|^2 + |m_{01}|^2, \qquad \|r_1\|^2 = |m_{10}|^2 + |m_{11}|^2,$$
$$\langle r_0, r_1\rangle = m_{00}\overline{m_{10}} + m_{01}\overline{m_{11}} .$$

**Lemma 2.6.** $\|M\|_F^2 = \|r_0\|^2 + \|r_1\|^2$, and both summands are non-negative.

*Proof.* Expand the double sum by rows. $\square$

**Definition 2.7 (Reduced density matrix, purity).** The *marginal*, or reduced density matrix of the first qubit, is $\rho = MM^{\dagger}$. Its *purity* is $\operatorname{tr}\rho^2$, which we also write $P(M) = \operatorname{Re}\operatorname{tr}\bigl((MM^\dagger)^2\bigr)$.

Two elementary identities are used repeatedly:
$$\operatorname{tr}(MM^{\dagger}) = \|M\|_F^2, \qquad \det(MM^{\dagger}) = |\det M|^2 . \tag{2.1}$$
The first is the row expansion again; the second is multiplicativity of $\det$ together with $\det(M^\dagger) = \overline{\det M}$.

### 2.2 The local unitary action

Local operations act on the two qubits independently. On amplitude matrices, an operator $U\otimes V$ acts by left multiplication by $U$ and right multiplication by the *transpose* of $V$ (the transpose arises because the second index of $M$ is a ket index contracted against $V$).

**Definition 2.8 (Local action).** For $U, V \in U(2)$ set
$$L_U(M) = UM, \qquad R_V(M) = MV^{\mathsf T}, \qquad \Lambda_{U,V}(M) = U\,M\,V^{\mathsf T}.$$

**Proposition 2.9 (Action laws).** $\Lambda_{U,V} = L_U \circ R_V$; $\Lambda_{I,I} = \mathrm{id}$; $L_{U_1U_2} = L_{U_1}\circ L_{U_2}$; $R_{V_1V_2} = R_{V_1}\circ R_{V_2}$; and $\Lambda_{U_1U_2,\,V_1V_2} = \Lambda_{U_1,V_1}\circ\Lambda_{U_2,V_2}$.

*Proof.* Associativity of matrix multiplication, and $(V_1V_2)^{\mathsf T} = V_2^{\mathsf T}V_1^{\mathsf T}$ combined with the right-hand placement of the transposed factor. $\square$

Thus $\Lambda$ is a genuine left action of the group $U(2)\times U(2)$.

**Lemma 2.10 (Closure properties of $U(2)$).** If $V$ is unitary then so are $V^{\mathsf T}$ and $V^{\dagger}$, and $|\det U| = 1$ for unitary $U$.

*Proof.* From $V^{\dagger}V = I$ we get $V^{\mathsf T}(V^{\mathsf T})^{\dagger} = V^{\mathsf T}\overline{V} = (V^{\dagger}V)^{\mathsf T} = I$. Unitarity of $V^\dagger$ is the definition read symmetrically. Finally $\det U \cdot \overline{\det U} = \det(UU^\dagger) = 1$, so $|\det U|^2 = 1$. $\square$

**Theorem 2.11 (Invariance).** For $U,V \in U(2)$ and any $M$:
$$\|\Lambda_{U,V}(M)\|_F^2 = \|M\|_F^2, \qquad |\det \Lambda_{U,V}(M)| = |\det M|, \qquad C(\Lambda_{U,V}M) = C(M).$$
In particular the local action preserves normalization and sharpness.

*Proof.* For the norm, using $\operatorname{tr}(MM^\dagger)$ and $(UMV^{\mathsf T})(UMV^{\mathsf T})^{\dagger} = U M V^{\mathsf T}\overline V M^{\dagger}U^{\dagger} = U(MM^{\dagger})U^{\dagger}$ by Lemma 2.10, cyclicity of the trace gives $\operatorname{tr}\bigl(U(MM^\dagger)U^\dagger\bigr) = \operatorname{tr}(MM^\dagger)$. For the determinant, $\det(UMV^{\mathsf T}) = \det U\,\det M\,\det V$ and both unitary determinants are unimodular. $\square$

### 2.3 Product states

**Definition 2.12.** $M$ is a *product state* if there exist $u, w \in \mathbb{C}^2$ with $m_{ij} = u_i w_j$ for all $i,j$.

**Theorem 2.13.** $C(M) = 0$ if and only if $M$ is a product state.

*Proof.* If $m_{ij} = u_iw_j$ then $\det M = u_0w_0u_1w_1 - u_0w_1u_1w_0 = 0$. Conversely suppose $\det M = m_{00}m_{11} - m_{01}m_{10} = 0$. If $m_{00} \ne 0$, take $u = (1, m_{10}/m_{00})$ and $w = (m_{00}, m_{01})$; the three obvious entries match and the fourth, $m_{10}m_{01}/m_{00} = m_{11}$, is exactly the vanishing of the determinant. If $m_{00} = 0$ and $m_{01} \ne 0$, the determinant condition forces $m_{01}m_{10} = 0$, so $m_{10} = 0$, and $u = (1, m_{11}/m_{01})$, $w = (m_{00}, m_{01})$ works. If $m_{00} = m_{01} = 0$, take $u = (0,1)$, $w = (m_{10}, m_{11})$. $\square$

So the concurrence measures the failure of factorization; the extremal problem of §1.1 is the search for the states that are *maximally* non-factorizable.

---

## 3. The Gram relation and the sharp bound

**Lemma 3.1 (Lagrange's identity in dimension two).** For all $a,b,c,d\in\mathbb{C}$,
$$\bigl|a\overline c + b\overline d\bigr|^2 + \bigl|ad - bc\bigr|^2 = \bigl(|a|^2+|b|^2\bigr)\bigl(|c|^2+|d|^2\bigr).$$

*Proof.* Write $a = a_1 + ia_2$, $b = b_1 + ib_2$, $c = c_1+ic_2$, $d = d_1+id_2$, and expand both sides as real polynomials in the eight real variables $a_1,\dots,d_2$. Every monomial appearing on the left with a mixed sign cancels, and what survives on the left is precisely the expansion of the right-hand side
$$(a_1^2+a_2^2+b_1^2+b_2^2)(c_1^2+c_2^2+d_1^2+d_2^2).$$
Equivalently, the identity is the Cauchy–Binet formula applied to the Gram determinant of the pair $\{(a,b),(c,d)\}$. $\square$

**Corollary 3.2 (Gram relation).** For every $M\in\mathbb{C}^{2\times2}$,
$$\bigl|\langle r_0,r_1\rangle\bigr|^2 + |\det M|^2 = \|r_0\|^2\,\|r_1\|^2. \tag{3.1}$$

*Proof.* Apply Lemma 3.1 with $(a,b) = (m_{00},m_{01})$ and $(c,d) = (m_{10},m_{11})$, noting $\det M = m_{00}m_{11} - m_{01}m_{10}$. $\square$

**Corollary 3.3 (Hadamard's inequality in dimension two).** $|\det M|^2 \le \|r_0\|^2\|r_1\|^2$.

**Theorem 3.4 (Sharp bound).** For every $M \in \mathbb{C}^{2\times2}$,
$$2\,|\det M| \;\le\; \|M\|_F^2 .$$
Consequently every normalized state satisfies $C(M)\le 1$.

*Proof.* By Corollary 3.3, $|\det M| \le \|r_0\|\,\|r_1\|$. By AM–GM, $2\|r_0\|\|r_1\| \le \|r_0\|^2 + \|r_1\|^2 = \|M\|_F^2$ (Lemma 2.6). Chain the two. $\square$

The bound is attained, as Theorem 4.4 below shows for $\Phi$; the whole point of the paper is that the attaining set is as small as it can possibly be.

---

## 4. The row classification

**Theorem 4.1 (Row classification).** Let $M$ be a sharp maximizer. Then
$$\|r_0\|^2 = \|r_1\|^2 = \tfrac12, \qquad \langle r_0, r_1\rangle = 0 .$$

*Proof.* Normalization gives $\|r_0\|^2 + \|r_1\|^2 = 1$, and $C(M) = 1$ gives $|\det M| = \tfrac12$, hence $|\det M|^2 = \tfrac14$. Substituting into the Gram relation (3.1),
$$\bigl|\langle r_0,r_1\rangle\bigr|^2 + \tfrac14 = \|r_0\|^2\|r_1\|^2 .$$
Writing $x = \|r_0\|^2$ and $y = \|r_1\|^2$ with $x+y = 1$, we have $xy \le \tfrac14$ with equality iff $x = y = \tfrac12$, because $4xy = (x+y)^2 - (x-y)^2 = 1 - (x-y)^2$. Hence $|\langle r_0,r_1\rangle|^2 = xy - \tfrac14 \le 0$, forcing simultaneously $\langle r_0,r_1\rangle = 0$ and $(x-y)^2 = 0$, i.e. $x = y = \tfrac12$. $\square$

The three conclusions of Theorem 4.1 are, verbatim, the four matrix entries of a single statement.

**Theorem 4.2 (Maximally mixed marginal).** If $M$ is a sharp maximizer then $MM^{\dagger} = \tfrac12 I$.

*Proof.* The $(0,0)$ entry of $MM^\dagger$ is $|m_{00}|^2 + |m_{01}|^2 = \|r_0\|^2 = \tfrac12$; the $(1,1)$ entry is $\|r_1\|^2 = \tfrac12$; the $(0,1)$ entry is $\langle r_0,r_1\rangle = 0$; and the $(1,0)$ entry is its conjugate. $\square$

**Theorem 4.3 (Converse).** If $MM^{\dagger} = \tfrac12 I$ then $M$ is a sharp maximizer. Hence
$$M \text{ is a sharp maximizer} \iff MM^{\dagger} = \tfrac12 I .$$

*Proof.* Taking traces in $MM^\dagger = \tfrac12 I$ and using (2.1) gives $\|M\|_F^2 = \operatorname{tr}(\tfrac12 I) = 1$, so $M$ is normalized. Taking determinants and using (2.1) gives $|\det M|^2 = \det(\tfrac12 I) = \tfrac14$, so $|\det M| = \tfrac12$ and $C(M) = 1$. $\square$

Theorem 4.3 is the physically striking form of the classification: *a two-qubit pure state is maximally entangled exactly when its one-qubit marginal is maximally mixed.* Maximal global correlation is maximal local ignorance.

**Theorem 4.4 (Unitary rescaling).** If $MM^{\dagger} = \tfrac12 I$ then $\sqrt2\,M \in U(2)$. In particular $\Phi = \tfrac1{\sqrt2}I$ is a sharp maximizer.

*Proof.* $(\sqrt2 M)(\sqrt2 M)^{\dagger} = 2\,MM^{\dagger} = I$. For $\Phi$: $\Phi\Phi^\dagger = \tfrac12 I$, so Theorem 4.3 applies. $\square$

Theorem 4.4 is the promised step "construct a unitary matrix from an orthonormal basis": Theorem 4.1 says the rows of $\sqrt2 M$ are an orthonormal basis of $\mathbb{C}^2$, and a matrix with orthonormal rows *is* a unitary matrix.

---

## 5. The normal form theorem

**Theorem 5.1 (Left transitivity).** $M$ is a sharp maximizer if and only if $M = U\Phi$ for some $U\in U(2)$.

*Proof.* ($\Rightarrow$) Put $U = \sqrt2 M$, unitary by Theorems 4.2 and 4.4. Then $U\Phi = \sqrt2 M\cdot\tfrac1{\sqrt2}I = M$. ($\Leftarrow$) $\Phi$ is a sharp maximizer (Theorem 4.4) and $M\mapsto UM = \Lambda_{U,I}(M)$ preserves sharpness (Theorem 2.11). $\square$

**Theorem 5.2 (Local-unitary normal form).** $M$ is a sharp maximizer if and only if there exist $U, V \in U(2)$ with
$$M \;=\; U\,\Phi\,V^{\mathsf T}.$$
Equivalently, the set of sharp maximizers is exactly the orbit of $\Phi$ under $U(2)\times U(2)$.

*Proof.* ($\Rightarrow$) Theorem 5.1 with $V = I$. ($\Leftarrow$) Theorem 2.11 applied to the sharp maximizer $\Phi$. $\square$

**Theorem 5.3 (Right transitivity).** $M$ is a sharp maximizer if and only if $M = \Phi V^{\mathsf T}$ for some $V \in U(2)$.

*Proof.* Since $\Phi$ is a scalar matrix it commutes with every matrix. Given a sharp maximizer, Theorem 5.1 provides $U$ with $M = U\Phi = \Phi U$; take $V = U^{\mathsf T}$, unitary by Lemma 2.10, so that $V^{\mathsf T} = U$. The converse is Theorem 2.11 again. $\square$

**Corollary 5.4 (Transitivity on the orbit).** If $M$ and $N$ are sharp maximizers then $N = WM$ for some $W\in U(2)$.

*Proof.* Write $M = A\Phi$ and $N = B\Phi$ with $A,B$ unitary (Theorem 5.1) and set $W = BA^{\dagger}$, which is unitary. Then $WM = BA^{\dagger}A\Phi = B\Phi = N$. $\square$

Corollary 5.4 says that a *single-sided* local rotation suffices to convert any maximally entangled state into any other — an operationally meaningful statement, since it means one party acting alone can perform the conversion.

**Theorem 5.5 (Stabilizer of the Bell state).** Let $U \in U(2)$ and let $V$ be any matrix. Then
$$U\,\Phi\,V^{\mathsf T} = \Phi \iff V = \overline{U},$$
where $\overline U = (U^{\dagger})^{\mathsf T}$ is the entrywise complex conjugate of $U$. Thus the stabilizer of $\Phi$ in $U(2)\times U(2)$ is $\{(U,\overline U) : U \in U(2)\}$, a copy of $U(2)$.

*Proof.* Since $\Phi = \tfrac1{\sqrt2}I$ is scalar, $U\Phi V^{\mathsf T} = \tfrac1{\sqrt2}\,UV^{\mathsf T}$, so the equation is equivalent to $UV^{\mathsf T} = I$ after cancelling the nonzero scalar. Multiplying on the left by $U^{\dagger}$ and using $U^{\dagger}U = I$ gives $V^{\mathsf T} = U^{\dagger}$, i.e. $V = (U^{\dagger})^{\mathsf T} = \overline U$. Conversely if $V = \overline U$ then $V^{\mathsf T} = U^{\dagger}$ and $UV^{\mathsf T} = UU^{\dagger} = I$. $\square$

Theorem 5.5 quantifies the freedom in the normal form: the orbit is $\bigl(U(2)\times U(2)\bigr)/U(2)$, of real dimension $4 + 4 - 4 = 4$; taking into account the global phase, which acts trivially on physical states, the maximizers form a $4$-real-dimensional family of matrices inside the $7$-sphere of normalized states.

**Corollary 5.6 (Extremes are disjoint).** A sharp maximizer is never a product state.

*Proof.* A product state has $C = 0$ by Theorem 2.13, while a sharp maximizer has $C = 1$. $\square$

---

## 6. Flat maximizers and complex Hadamard matrices of order two

**Definition 6.1.** $M$ is *flat* if $|m_{ij}| = \tfrac12$ for all $i,j$. Write
$$F_2 = \begin{pmatrix} 1 & 1 \\ 1 & -1\end{pmatrix}$$
for the order-two Fourier (Hadamard) matrix.

A flat sharp maximizer, rescaled by $2$, is exactly a *complex Hadamard matrix* of order two: a matrix with unimodular entries and pairwise orthogonal rows.

**Lemma 6.2.** If $d = (d_0,d_1)$ with $|d_i| = 1$, then $\operatorname{diag}(d)$ is unitary. Moreover $\tfrac12 F_2$ is a flat sharp maximizer.

*Proof.* $\operatorname{diag}(d)\operatorname{diag}(d)^{\dagger} = \operatorname{diag}(|d_0|^2, |d_1|^2) = I$. For $F_2$: $(\tfrac12F_2)(\tfrac12F_2)^{\dagger} = \tfrac14 F_2F_2^{\mathsf T} = \tfrac14\cdot 2I = \tfrac12 I$, so Theorem 4.3 applies; flatness is immediate. $\square$

**Theorem 6.3 (Dephasing).** Let $M$ be a flat sharp maximizer. Then there exist unimodular vectors $d, e \in \mathbb{C}^2$ with
$$M \;=\; \operatorname{diag}(d)\,\bigl(\tfrac12 F_2\bigr)\,\operatorname{diag}(e).$$

*Proof.* Flatness gives $m_{ij}\overline{m_{ij}} = \tfrac14$ for all $i,j$, and in particular every entry is nonzero. The orthogonality relation of Theorem 4.1 reads $m_{00}\overline{m_{10}} + m_{01}\overline{m_{11}} = 0$. Multiply it by $4 m_{10}m_{11}$ and substitute $4m_{10}\overline{m_{10}} = 1$, $4m_{11}\overline{m_{11}} = 1$, obtaining the *unconjugated* relation
$$m_{00}m_{11} + m_{01}m_{10} = 0. \tag{6.1}$$
Now take $d = \bigl(1,\; m_{10}/m_{00}\bigr)$ and $e = \bigl(2m_{00},\,2m_{01}\bigr)$; both are unimodular by flatness. The product $\operatorname{diag}(d)(\tfrac12 F_2)\operatorname{diag}(e)$ has entries
$$\begin{pmatrix} m_{00} & m_{01} \\ m_{10} & -m_{01}m_{10}/m_{00}\end{pmatrix},$$
and the bottom-right entry equals $m_{11}$ precisely by (6.1). $\square$

**Theorem 6.4 (Flat classification).** $M$ is a flat sharp maximizer if and only if $M = \operatorname{diag}(d)\,(\tfrac12 F_2)\,\operatorname{diag}(e)$ for unimodular $d, e$.

*Proof.* ($\Rightarrow$) Theorem 6.3. ($\Leftarrow$) Sharpness follows from Lemma 6.2 and Theorem 2.11 (note $\operatorname{diag}(e) = \operatorname{diag}(e)^{\mathsf T}$, so this is a legitimate local action); flatness is a direct computation on the four entries, each of which is $\pm\tfrac12 d_i e_j$. $\square$

This is the order-two case of the classification of complex Hadamard matrices, and it is a *rigidity* statement: whereas the full maximizer set requires the six-parameter group $U(2)\times U(2)$ (modulo stabilizer) to sweep out, the flat locus requires only the three-parameter torus of diagonal phases (four phases modulo one global phase). There is no continuous family of order-two complex Hadamard matrices beyond dephasing — the *defect* is zero. (Contrast order four, where a genuine one-parameter family exists.)

### 6.1 The real count

**Definition 6.5.** For $a,b,c,d \in \{\pm\}$ let $S(a,b,c,d)$ be the matrix with entries $\pm\tfrac12$ according to the four signs.

**Theorem 6.6 (Sign criterion).** $S(a,b,c,d)$ is a sharp maximizer if and only if the propositions "$a = d$" and "$b = c$" have opposite truth values.

*Proof.* Every such matrix is automatically normalized, since $4\cdot\tfrac14 = 1$. Its determinant is $\tfrac14(ad - bc)$ with $ad, bc \in \{\pm1\}$, so $|\det| = \tfrac12$ iff $ad = -bc$, i.e. iff exactly one of $ad = 1$, $bc = 1$ holds. $\square$

**Corollary 6.7 (The count).** Exactly $8$ of the $16$ real sign patterns are sharp maximizers.

*Proof.* Condition on $ad$: for each of the $8$ pairs $(a,d)$ there are exactly $2$ pairs $(b,c)$ with $bc = -ad$ out of $4$; more simply, the map $(a,b,c,d)\mapsto(a,b,c,-d)$ is a fixed-point-free involution exchanging the maximizers with the non-maximizers, so the two classes have equal size $8$. $\square$

Equivalently, the $8$ real maximizers form a single orbit of the sign group $\{\pm1\}^3$ (row signs and column signs modulo the global sign) through $\tfrac12 F_2$ — the real shadow of Theorem 6.4.

---

## 7. The Bell basis

Define the Hilbert–Schmidt inner product on amplitude matrices,
$$\langle M, N\rangle_{HS} = \sum_{i,j}\overline{m_{ij}}\,n_{ij},$$
which is the standard inner product of the corresponding state vectors. Let $\sigma_0 = I$ and
$$\sigma_x = \begin{pmatrix}0&1\\1&0\end{pmatrix},\qquad \sigma_y = \begin{pmatrix}0&-i\\i&0\end{pmatrix},\qquad \sigma_z = \begin{pmatrix}1&0\\0&-1\end{pmatrix}$$
be the Pauli matrices, and set $\Phi_k = \sigma_k\Phi = \tfrac1{\sqrt2}\sigma_k$ for $k \in \{0,x,y,z\}$.

**Lemma 7.1.** Each $\sigma_k$ is unitary, and $\langle \sigma_j,\sigma_k\rangle_{HS} = 2\,\delta_{jk}$.

*Proof.* Direct computation on $2\times2$ matrices; each $\sigma_k$ squares to $I$ and is Hermitian, and the four are pairwise Hilbert–Schmidt orthogonal with squared norm $\operatorname{tr}(\sigma_k^2) = 2$. $\square$

**Theorem 7.2 (Bell basis).** The four states $\Phi_0, \Phi_x, \Phi_y, \Phi_z$ are sharp maximizers, are orthonormal for $\langle\cdot,\cdot\rangle_{HS}$, and form a basis: every amplitude matrix satisfies
$$M \;=\; \sum_{k} \langle \Phi_k, M\rangle_{HS}\;\Phi_k .$$

*Proof.* Sharpness: $\Phi_k = \Lambda_{\sigma_k, I}(\Phi)$ and $\sigma_k$ is unitary, so Theorem 2.11 applies. Orthonormality: $\langle \Phi_j, \Phi_k\rangle_{HS} = \tfrac12\langle\sigma_j,\sigma_k\rangle_{HS} = \delta_{jk}$ by Lemma 7.1. Completeness: the Pauli matrices span $\mathbb{C}^{2\times2}$ with the expansion $M = \tfrac12\sum_k\langle\sigma_k,M\rangle_{HS}\,\sigma_k$ (verify entrywise, or note that orthogonality plus a dimension count forces it), and substituting $\sigma_k = \sqrt2\,\Phi_k$ and $\langle\sigma_k,M\rangle_{HS} = \sqrt2\langle\Phi_k,M\rangle_{HS}$ yields the stated formula. $\square$

Theorem 7.2 is the structural fact behind superdense coding and teleportation: there exists an orthonormal basis of the four-dimensional two-qubit state space consisting *entirely* of maximally entangled states, and its members differ by a unitary acting on one side only.

---

## 8. Purity, linear entropy, and the Schmidt spectrum

Cayley–Hamilton in dimension two, $A^2 - (\operatorname{tr}A)A + (\det A)I = 0$, gives in trace form $\operatorname{tr}(A^2) = (\operatorname{tr}A)^2 - 2\det A$. Applying this to $\rho = MM^{\dagger}$ and using (2.1):

**Proposition 8.1.** $P(M) = \operatorname{tr}\rho^2 = \|M\|_F^4 - 2|\det M|^2$.

**Theorem 8.2 (Linear-entropy identity).** For every normalized $M$,
$$C(M)^2 \;=\; 2\bigl(1 - \operatorname{tr}\rho^2\bigr).$$

*Proof.* Put $\|M\|_F^2 = 1$ into Proposition 8.1: $\operatorname{tr}\rho^2 = 1 - 2|\det M|^2 = 1 - \tfrac12 C^2$. Rearrange. $\square$

The quantity $1 - \operatorname{tr}\rho^2$ is the *linear entropy* of the marginal; Theorem 8.2 says the squared concurrence is exactly twice it, so the two standard measures of entanglement for a two-qubit pure state — non-factorizability of the amplitude matrix, and mixedness of the marginal — are literally the same function up to a change of variable.

**Corollary 8.3 (Minimal purity).** Every normalized state has $\operatorname{tr}\rho^2 \ge \tfrac12$, and equality holds exactly at the sharp maximizers.

*Proof.* $\operatorname{tr}\rho^2 = 1 - \tfrac12C^2 \ge 1 - \tfrac12 = \tfrac12$ using $C \le 1$ (Theorem 3.4), with equality iff $C = 1$ (using $C \ge 0$). $\square$

### 8.1 The Schmidt spectrum

**Definition 8.4.** For a normalized state set
$$s_{\pm}(M) = \frac{1 \pm \sqrt{1 - C(M)^2}}{2}.$$

**Lemma 8.5.** $s_+ + s_- = 1$, $s_+s_- = |\det M|^2$, and $0 \le s_- \le s_+ \le 1$.

*Proof.* The sum is immediate. For the product, $s_+s_- = \tfrac14\bigl(1 - (1-C^2)\bigr) = \tfrac14 C^2 = |\det M|^2$, using $\bigl(\sqrt{1-C^2}\bigr)^2 = 1 - C^2$, legitimate since $C \le 1$. The bounds follow from $0 \le \sqrt{1-C^2} \le 1$. $\square$

**Theorem 8.6 (Schmidt spectrum).** For a normalized state,
$$\bigl(\rho - s_+ I\bigr)\bigl(\rho - s_- I\bigr) = 0 .$$
Thus the eigenvalues of the marginal — the squared Schmidt coefficients of the state — are exactly $s_{\pm}(M)$.

*Proof.* Expand the left side as $\rho^2 - (s_++s_-)\rho + s_+s_-I = \rho^2 - (\operatorname{tr}\rho)\rho + (\det\rho)I$, using Lemma 8.5 with $\operatorname{tr}\rho = \|M\|_F^2 = 1$ and $\det\rho = |\det M|^2$. This vanishes by Cayley–Hamilton. $\square$

**Corollary 8.7 (Both extremes as spectral degeneracies).** For a normalized state:
1. $M$ is a sharp maximizer $\iff s_+ = s_-$ (spectrum $\{\tfrac12,\tfrac12\}$);
2. $M$ is a product state $\iff s_- = 0$ (spectrum $\{1,0\}$).

*Proof.* $s_+ - s_- = \sqrt{1-C^2}$, which vanishes iff $C^2 = 1$ iff $C = 1$ (as $C \ge 0$). And $2s_- = 1 - \sqrt{1-C^2}$ vanishes iff $\sqrt{1-C^2} = 1$ iff $C = 0$, which by Theorem 2.13 is the product condition. $\square$

The concurrence therefore interpolates monotonically between the two degeneracies of a one-parameter spectral family, and the classification of §4–5 is the statement that the *flat-spectrum* end of this family is a single group orbit.

---

## 9. Stability: a quantitative inverse theorem

The proof of Theorem 4.1 discarded a non-negative term; retaining it turns the classification into an exact identity, and hence into a robust statement.

**Lemma 9.1.** For every $M$,
$$\bigl\|\rho - \tfrac12 I\bigr\|_F^2 = \bigl(\|r_0\|^2 - \tfrac12\bigr)^2 + \bigl(\|r_1\|^2 - \tfrac12\bigr)^2 + 2\,\bigl|\langle r_0,r_1\rangle\bigr|^2 ,$$
where $\rho = MM^{\dagger}$.

*Proof.* The entries of $\rho$ are $\rho_{00} = \|r_0\|^2$, $\rho_{11} = \|r_1\|^2$, $\rho_{01} = \langle r_0,r_1\rangle$, $\rho_{10} = \overline{\rho_{01}}$. Subtract $\tfrac12 I$ and sum the four squared moduli. $\square$

**Theorem 9.2 (Exact stability identity).** For every normalized $M$,
$$\bigl\|\,MM^{\dagger} - \tfrac12 I\,\bigr\|_F^2 \;=\; \frac{1 - C(M)^2}{2}.$$

*Proof.* Write $x = \|r_0\|^2$, $y = \|r_1\|^2$, $t = |\langle r_0,r_1\rangle|^2$, $D = |\det M|^2 = C^2/4$. Normalization gives $x + y = 1$ and the Gram relation (3.1) gives $t + D = xy$. Then
$$\bigl(x-\tfrac12\bigr)^2 + \bigl(y-\tfrac12\bigr)^2 = \tfrac12 (x-y)^2 = \tfrac12\bigl((x+y)^2 - 4xy\bigr) = \tfrac12\bigl(1 - 4t - 4D\bigr),$$
so by Lemma 9.1 the left-hand side of the theorem equals $\tfrac12 - 2t - 2D + 2t = \tfrac12 - 2D = \tfrac12 - \tfrac{C^2}{2}$. $\square$

Note that the cross terms cancel exactly: the off-diagonal contribution $2t$ is precisely compensated by the $t$-dependence of the diagonal deficit. This is why the identity is clean.

**Corollary 9.3 (Deficit bound).** For every normalized $M$,
$$\bigl\|\,MM^{\dagger} - \tfrac12 I\,\bigr\|_F^2 \;\le\; 1 - C(M).$$

*Proof.* $\tfrac12(1-C^2) = \tfrac12(1-C)(1+C) \le (1-C)$ since $0 \le C \le 1$. $\square$

**Corollary 9.4.** For a normalized $M$, $\;\|MM^{\dagger} - \tfrac12 I\|_F = 0$ if and only if $M$ is a sharp maximizer.

Thus if a state's concurrence falls short of the maximum by $\varepsilon$, its marginal lies within Frobenius distance $\sqrt{\varepsilon}$ of the maximally mixed state, and the exponent $\tfrac12$ is optimal: the exact identity of Theorem 9.2 shows the distance is $\Theta(\sqrt{\varepsilon})$ as $\varepsilon\to0$ along a curve with $C = 1-\varepsilon$. The classification is therefore not a knife-edge phenomenon; it degrades continuously and with an explicit modulus.

---

## 10. Algorithmic content

The theory above is entirely constructive and yields short algorithms.

**Algorithm A (Certify maximality).** Given $M$, compute $\|M\|_F^2$ and $\det M$ in $O(1)$ arithmetic operations; report *sharp maximizer* iff $\|M\|_F^2 = 1$ and $2|\det M| = 1$. By Theorem 4.3 this is equivalent to the four-entry test $MM^{\dagger} = \tfrac12 I$, which is a useful cross-check and is what one measures experimentally (state tomography of one qubit).

**Algorithm B (Normal-form extraction).** Given a sharp maximizer $M$, return $U = \sqrt2\,M$ and $V = I$; then $M = U\Phi V^{\mathsf T}$ and $U$ is unitary (Theorem 4.4). Cost $O(1)$; the certificate can be verified by checking $UU^{\dagger} = I$.

**Algorithm C (Interconversion).** Given sharp maximizers $M, N$, return $W = 2\,N M^{\dagger}$. Indeed $W = (\sqrt2 N)(\sqrt2 M)^{\dagger}$ is a product of unitaries, hence unitary, and $WM = 2NM^{\dagger}M = 2N\cdot\tfrac12 I= N$ using $M^\dagger M = \tfrac12 I$ (which holds because $\sqrt2 M$ is unitary and unitaries satisfy $A^\dagger A = I$). This realizes Corollary 5.4 with an explicit $O(1)$ formula.

**Algorithm D (Dephasing a flat maximizer).** Given a flat sharp maximizer $M$, return $d = (1, m_{10}/m_{00})$ and $e = (2m_{00}, 2m_{01})$; then $M = \operatorname{diag}(d)(\tfrac12 F_2)\operatorname{diag}(e)$ by Theorem 6.3.

**Algorithm E (Bell-basis transform).** Given any $M$, return the four coefficients $c_k = \langle\Phi_k, M\rangle_{HS} = \tfrac1{\sqrt2}\operatorname{tr}(\sigma_k^{\dagger}M)$; by Theorem 7.2, $M = \sum_k c_k\Phi_k$ and $\sum_k|c_k|^2 = \|M\|_F^2$. This is the $4$-point transform underlying Bell-basis measurement.

**Algorithm F (Schmidt spectrum).** Given a normalized $M$, return $s_{\pm} = \bigl(1\pm\sqrt{1-C^2}\bigr)/2$ with $C = 2|\det M|$; by Theorem 8.6 these are the eigenvalues of $MM^{\dagger}$, obtained without diagonalizing anything.

Every algorithm is $O(1)$ because the underlying dimension is fixed; the point is not complexity but that each theorem supplies an explicit witness, so the classification can be *used*, not merely quoted.

---

## 11. Discussion and applications

**Entanglement as an extremal problem.** The narrative of §3–5 is a template. A sharp inequality is proved by dropping one non-negative term and applying AM–GM; the equality case reinstates both, forcing two equations; those equations assemble into a matrix identity ($\rho = \tfrac12 I$); the matrix identity says the object is unitary after rescaling; and unitarity is precisely membership in a group orbit. Wherever this template applies — Hadamard matrices, tight frames, extremal graphs, isoperimetric problems — one expects the maximizer set to be a single orbit and the proof of the inequality, read backwards, to be the classification.

**Operational content.** Theorem 4.3 is the statement that maximal entanglement is *exactly* maximal local ignorance, which is why the halves of a Bell pair are individually useless: each is a uniformly random bit. Corollary 5.4 says either party can convert their shared maximally entangled state into any other by acting alone, which is why "maximally entangled state" is a resource without further qualification: there is only one, up to local relabelling. Theorem 5.5 explains the isotropy of Bell correlations: rotating one particle by $U$ can always be undone by rotating the other by $\overline U$. Theorem 7.2 is the mathematical substrate of superdense coding (four distinguishable messages encoded by one-sided Pauli operations) and teleportation (measurement in a maximally entangled basis).

**Combinatorial content.** Theorem 6.4 and Corollary 6.7 place the analysis in contact with the combinatorics of Hadamard matrices. Order two is the base case of a hierarchy that becomes hard fast: the classification of complex Hadamard matrices is complete only up to order five. What the base case exhibits cleanly is the phenomenon of *defect zero* — the only deformations of $F_2$ through complex Hadamard matrices are the trivial ones by row and column phases. The real count $8 = |\{\pm1\}^3|$ is a single orbit of the sign group, the exact discrete shadow of the torus statement.

**Stability.** Theorem 9.2 upgrades a rigidity theorem to a robustness theorem. In an experimental setting one never certifies $C = 1$; one certifies $C \ge 1 - \varepsilon$. Corollary 9.3 converts that certificate directly into a bound on how far the observed one-qubit marginal can be from maximally mixed — an inequality between two quantities that are separately measurable, with no free constants.

---

## 12. Future directions

**Direction 1 — A complete local-unitary invariant via the Schmidt normal form.** The row classification is the equality case of a Gram inequality whose *general* case is the singular value decomposition. The same Lagrange identity that produced $MM^{\dagger} = \tfrac12 I$ should produce the general normal form $M = U\operatorname{diag}(s,t)V^{\mathsf T}$, exhibiting the Schmidt coefficients of §8 as a complete invariant of the local action on *all* states, not just maximizers. The ingredients are in place: $MM^{\dagger}$ is Hermitian positive semidefinite with the spectrum computed in Theorem 8.6, the degenerate cases in dimension two are a finite check, and the orbit machinery of §2.2 already applies. The expected conclusion — that $|\det M|$ together with $\|M\|_F^2$ is a *complete* invariant of the two-sided action, so two states are locally equivalent iff they have the same concurrence — would place all of §4–9 inside a single classification.

**Direction 2 — The Hadamard defect and the rigidity of $F_2$.** Theorem 6.3 shows the order-two complex Hadamard matrices admit exactly a three-parameter dephasing group and no continuous family beyond it, i.e. defect zero; order four, by contrast, carries a genuine one-parameter family. A formal notion of *defect* — the dimension of the space of infinitesimal deformations preserving both unimodularity and orthogonality, modulo dephasing — would explain both facts uniformly, and the order-two case now provides a fully proved base case against which to calibrate the definition rather than folklore.

**Direction 3 — Sharpness stability: from marginal to state.** The equality-case argument only ever used the bound $|\langle r_0,r_1\rangle|^2 \le \varepsilon$, so it is already quantitative: one expects $\|M\|_F^2 - 2|\det M| \le \varepsilon$ to force $M$ to lie within Frobenius distance $O(\sqrt{\varepsilon})$ of the maximizer orbit. Theorem 9.2 supplies the marginal-level half of this exactly, in the form $\|\rho - \tfrac12 I\|_F^2 = (1-C^2)/2$. What remains is the passage from "marginal close to $\tfrac12 I$" to "state close to the orbit", i.e. a perturbative version of Theorem 4.4: if $MM^{\dagger}$ is within $\delta$ of $\tfrac12 I$, then $\sqrt2 M$ is within $O(\delta)$ of a unitary — a two-dimensional instance of the Lin-type problem of approximating almost-unitary matrices by unitary ones, where the polar decomposition should give the optimal constant.

---

## 13. Summary of results

| Statement | Content |
|---|---|
| Sharp bound | $2|\det M| \le \|M\|_F^2$ for all $M \in \mathbb{C}^{2\times2}$; hence $C \le 1$ on normalized states. |
| Row classification | A sharp maximizer has orthogonal rows of squared length $\tfrac12$ each. |
| Marginal criterion | $M$ is a sharp maximizer $\iff MM^{\dagger} = \tfrac12 I$. |
| Unitary rescaling | For a sharp maximizer, $\sqrt2\,M$ is unitary. |
| Normal form | Sharp maximizers $=$ the orbit $\{U\Phi V^{\mathsf T}\}$ of $\Phi = \operatorname{diag}(1/\sqrt2,1/\sqrt2)$. |
| One-sided transitivity | $M = U\Phi$ suffices; also $M = \Phi V^{\mathsf T}$; any two maximizers differ by a one-sided unitary. |
| Stabilizer | $U\Phi V^{\mathsf T} = \Phi \iff V = \overline U$. |
| Product states | $C(M) = 0 \iff M$ factors; maximizers never factor. |
| Flat classification | Flat maximizers $=\operatorname{diag}(d)(\tfrac12 F_2)\operatorname{diag}(e)$, phases $d,e$. |
| Real count | Exactly $8$ of the $16$ real sign patterns are maximizers. |
| Bell basis | $\{\tfrac1{\sqrt2}\sigma_k\}$ is an orthonormal basis of maximizers with explicit expansion. |
| Linear entropy | $C^2 = 2(1 - \operatorname{tr}\rho^2)$; $\operatorname{tr}\rho^2 \ge \tfrac12$ with equality at maximizers. |
| Schmidt spectrum | $\rho$ has eigenvalues $\bigl(1\pm\sqrt{1-C^2}\bigr)/2$; degenerate at maximizers, singular at products. |
| Stability | $\|\rho - \tfrac12 I\|_F^2 = (1-C^2)/2 \le 1 - C$, vanishing exactly at maximizers. |
