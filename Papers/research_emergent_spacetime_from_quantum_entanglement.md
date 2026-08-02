# Emergent Spacetime from Quantum Entanglement: A Finite ER=EPR Toy Model

**Aristotle**  
**August 2, 2026**

## Abstract

We present a self-contained finite model in which the entanglement structure of a real pure two-qubit state determines a two-boundary geometry with one possible weighted throat. A state is represented by a real $2\times2$ coefficient matrix. Product states are outer products and therefore have zero determinant. The associated pure-state concurrence is twice the absolute determinant. For the Bell state $|\Phi^+\rangle=(|00\rangle+|11\rangle)/\sqrt2$, direct contraction gives both one-qubit reduced density matrices as $I/2$, its determinant is $1/2$, its concurrence is $1$, and it admits no product factorization. On the geometric side, boundary entropies $(S(L),S(R),S(LR))$ reconstruct a nonnegative throat weight by

$$
w=\frac{S(L)+S(R)-S(LR)}{2}.
$$

This formula is an exact inverse to the cut data of every one-throat geometry. Assigning the Bell pair its entropy data $(1,1,0)$ in bits therefore reconstructs a unit-weight microscopic Einstein–Rosen bridge. The resulting finite ER=EPR correspondence simultaneously identifies nonfactorization, maximally mixed local states, unit concurrence, and unit geometric connectivity. The construction is an algebraic toy model, not a claim about continuum gravity, but it isolates a precise mechanism by which mutual information can parameterize geometry.

## 1. Introduction

The possibility that spacetime geometry may emerge from quantum entanglement motivates a basic mathematical question: what is the smallest setting in which boundary correlation data can determine a bulk connection? A finite model cannot reproduce quantum field theory, gravity, or a dynamical Einstein–Rosen bridge. It can, however, make the proposed dictionary exact. Such a model separates three tasks that are often blended together: detecting entanglement in a state, extracting local information from that state, and reconstructing a geometric parameter from boundary data.

We study two real qubits and a two-boundary graph with one possible edge, called a throat. This is the minimal nontrivial setting. The quantum side has enough structure to distinguish product and entangled states. The geometric side has one unknown nonnegative weight. The bridge between them is the entropy triple of the left subsystem, right subsystem, and their union.

The central example is the Bell state

$$
|\Phi^+\rangle=\frac{|00\rangle+|11\rangle}{\sqrt2}.
$$

Its local density matrices are both maximally mixed even though the complete state is pure. Consequently, its subsystem entropies are $1$ bit each while its total entropy is $0$. The combination

$$
I(L:R)=S(L)+S(R)-S(LR)
$$

is the mutual information. In a one-edge cut geometry, the edge contributes once to each proper boundary cut and zero times to the full boundary. It therefore contributes twice to mutual information, leading to the reconstruction rule $w=I(L:R)/2$.

Our main result is a conjunction of quantum and geometric facts. The Bell state cannot be factorized; both marginals equal $I/2$; its concurrence is one; and its entropy data reconstruct a unit throat. Each fact is elementary, but their exact compatibility supplies a rigorous finite interpretation of ER=EPR.

The scope is deliberately restricted. Amplitudes are real, entropy values are attached to the Bell state as boundary data rather than derived from a general spectral entropy construction, and geometry is a weighted cut graph rather than a manifold. These restrictions ensure that every definition and proof can be given explicitly.

## 2. Quantum model

### 2.1 Two-qubit coefficient matrices

Let each qubit have computational basis indexed by $\{0,1\}$. A real pure two-qubit state is written

$$
|\psi\rangle=\sum_{i,j\in\{0,1\}}\psi_{ij}|ij\rangle
$$

and represented by the coefficient matrix

$$
\Psi=(\psi_{ij})=
\begin{pmatrix}
\psi_{00}&\psi_{01}\\
\psi_{10}&\psi_{11}
\end{pmatrix}.
$$

For physical normalization one imposes $\sum_{i,j}\psi_{ij}^2=1$. The algebraic product-state theorem below does not require normalization.

**Definition 2.1 (Product state).** A coefficient matrix $\Psi$ is a product state if there exist real vectors $u=(u_0,u_1)$ and $v=(v_0,v_1)$ such that

$$
\psi_{ij}=u_i v_j
$$

for all $i,j\in\{0,1\}$. Equivalently, $\Psi=uv^{\mathsf T}$.

**Definition 2.2 (Entanglement determinant and concurrence).** The entanglement determinant is

$$
\Delta(\psi)=\det\Psi.
$$

For a real pure two-qubit state, define concurrence by

$$
C(\psi)=2|\Delta(\psi)|.
$$

For normalized states this agrees with the usual pure-state two-qubit concurrence in the real-amplitude case.

**Lemma 2.3 (Product states have zero determinant).** If $\Psi$ is a product state, then $\Delta(\psi)=0$.

**Proof sketch.** Write

$$
\Psi=
\begin{pmatrix}
u_0v_0&u_0v_1\\
u_1v_0&u_1v_1
\end{pmatrix}.
$$

Then

$$
\det\Psi=(u_0v_0)(u_1v_1)-(u_0v_1)(u_1v_0)=0.
$$

Equivalently, an outer product has rank at most one. $\square$

The converse also holds for $2\times2$ matrices, subject to the harmless zero-matrix case, but only the stated direction is required: nonzero determinant certifies nonfactorization.

### 2.2 Reduced density matrices

For real amplitudes, the density matrix of the full pure state is $|\psi\rangle\langle\psi|$. Taking the partial trace over one factor gives the reduced density matrix of the other.

**Definition 2.4 (Reduced density matrices).** The left and right reduced density matrices are

$$
(\rho_L)_{ik}=\sum_{j=0}^1\psi_{ij}\psi_{kj},
\qquad
(\rho_R)_{j\ell}=\sum_{i=0}^1\psi_{ij}\psi_{i\ell}.
$$

In matrix form,

$$
\rho_L=\Psi\Psi^{\mathsf T},
\qquad
\rho_R=\Psi^{\mathsf T}\Psi.
$$

**Definition 2.5 (Maximally mixed qubit).** The maximally mixed one-qubit density matrix is

$$
\rho_*=\frac{I}{2}=
\begin{pmatrix}
1/2&0\\0&1/2
\end{pmatrix}.
$$

It assigns equal probability to either outcome in every orthonormal basis and has no preferred pure-state direction.

### 2.3 Bell-state calculations

The Bell state has coefficient matrix

$$
B=\begin{pmatrix}
1/\sqrt2&0\\0&1/\sqrt2
\end{pmatrix}=\frac{I}{\sqrt2}.
$$

**Theorem 2.6 (Bell marginals).** Both reduced density matrices of $|\Phi^+\rangle$ are maximally mixed:

$$
\rho_L=\rho_R=\rho_*.
$$

**Proof sketch.** Since $B$ is real and diagonal,

$$
BB^{\mathsf T}=B^{\mathsf T}B=
\frac{I}{\sqrt2}\frac{I}{\sqrt2}=rac{I}{2}.
$$

The identity $(\sqrt2)^{-2}=1/2$ establishes each diagonal entry, and every off-diagonal entry vanishes. $\square$

**Theorem 2.7 (Unit Bell concurrence).** The concurrence of $|\Phi^+\rangle$ is one.

**Proof sketch.** The determinant of $B$ is

$$
\det B=\frac{1}{\sqrt2}\frac{1}{\sqrt2}=rac12.
$$

Therefore $C(\Phi^+)=2|1/2|=1$. $\square$

**Corollary 2.8 (Bell nonfactorization).** The Bell state is not a product state.

**Proof sketch.** If it were a product state, Lemma 2.3 would give $\det B=0$ and hence $C(\Phi^+)=0$. This contradicts Theorem 2.7. $\square$

These results articulate two complementary signatures of entanglement. The determinant detects the impossibility of factorization, while the marginal calculation shows that globally available information is absent from each component separately.

## 3. One-throat geometric model

### 3.1 Geometry and boundary data

We now define an intentionally minimal bulk geometry.

**Definition 3.1 (Two-boundary one-throat geometry).** A geometry consists of two labeled boundary components $L$ and $R$ together with a throat of weight $w\in\mathbb R$ satisfying $w\ge0$.

The weight is an abstract cut capacity. Calling it a throat is a geometric interpretation internal to this model; it is not presumed to be a continuum area, geodesic length, or solution of gravitational field equations.

**Definition 3.2 (Boundary entanglement data).** Boundary data are a triple of real numbers

$$
E=(S(L),S(R),S(LR)),
$$

interpreted respectively as the entropy of the left boundary, the right boundary, and their union.

**Definition 3.3 (Cut data generated by a throat).** A one-throat geometry of weight $w$ generates

$$
S(L)=w,
\qquad
S(R)=w,
\qquad
S(LR)=0.
$$

The reason is combinatorial: the cut isolating either one of the two boundary components crosses the unique throat, while the complete boundary has no complementary boundary vertex and crosses no throat.

### 3.2 Reconstruction

For arbitrary boundary data, suppose

$$
S(L)+S(R)-S(LR)\ge0.
$$

This condition ensures that the reconstructed weight below is nonnegative.

**Definition 3.4 (Two-boundary reconstruction).** Define

$$
\mathcal R(E)=\frac{S(L)+S(R)-S(LR)}{2}.
$$

The numerator is the mutual information $I(L:R)$. Thus the model identifies throat weight with half the mutual information.

**Theorem 3.5 (Exact one-throat reconstruction).** Let a two-boundary one-throat geometry have any nonnegative weight $w$. Generate its boundary data according to Definition 3.3 and reconstruct according to Definition 3.4. The reconstructed weight is exactly $w$.

**Proof sketch.** Substitution gives

$$
\mathcal R(E)=\frac{w+w-0}{2}=w.
$$

Nonnegativity of $w$ guarantees admissibility. $\square$

This is an injectivity and left-inverse statement for the one-parameter model: the boundary cut data retain the complete geometric degree of freedom. The data contain redundancy, since both one-sided entropies equal the same weight, but the symmetric formula makes the mutual-information interpretation explicit.

**Definition 3.6 (Microscopic bridge).** A geometry is a microscopic Einstein–Rosen bridge in this model if its throat weight is exactly $1$.

The unit is fixed by measuring Bell-pair entropies in bits. A different entropy convention would rescale the geometric unit.

## 4. Finite ER=EPR correspondence

### 4.1 Bell entropy data

For the Bell pair, each reduced density matrix is $I/2$. The binary spectrum $(1/2,1/2)$ has entropy $1$ bit, while the complete Bell state is pure and has entropy $0$. In the present finite model, we record these values as the boundary data

$$
E_{\mathrm{Bell}}=(1,1,0).
$$

A general definition and spectral derivation of von Neumann entropy are outside the minimal setup; only this explicit triple is used in reconstruction.

**Theorem 4.1 (Bell-pair bridge reconstruction).** The Bell boundary data reconstruct a microscopic bridge of unit weight.

**Proof sketch.** The admissibility expression is $1+1-0=2\ge0$. Applying the reconstruction rule yields

$$
\mathcal R(E_{\mathrm{Bell}})=\frac{1+1-0}{2}=1.
$$

This is precisely the defining condition for a microscopic bridge. $\square$

**Theorem 4.2 (Finite ER=EPR correspondence).** For the Bell state $|\Phi^+\rangle$, the following statements hold simultaneously:

1. $|\Phi^+\rangle$ admits no product factorization;
2. its left reduced density matrix equals $I/2$;
3. its right reduced density matrix equals $I/2$;
4. its concurrence equals $1$; and
5. its boundary entropy data $(1,1,0)$ reconstruct a unit-weight microscopic throat.

**Proof sketch.** The marginal statements are Theorem 2.6. The concurrence statement is Theorem 2.7, and nonfactorization follows from Corollary 2.8. The geometric conclusion is Theorem 4.1. Since all statements concern the same Bell state and its assigned boundary data, they form the claimed conjunction. $\square$

This theorem is the complete content of ER=EPR in the finite model. “EPR” is represented by nonfactorization, unit concurrence, and maximally mixed marginals. “ER” is represented by the reconstructed unit-weight throat. The correspondence is not an identification of Hilbert spaces with manifolds; it is an exact agreement between quantum entanglement data and a cut-geometric reconstruction rule.

### 4.2 A control example

Consider the normalized product state $|00\rangle$, represented by

$$
P=\begin{pmatrix}1&0\\0&0\end{pmatrix}.
$$

Its determinant and concurrence vanish. Both reduced density matrices are

$$
\begin{pmatrix}1&0\\0&0\end{pmatrix},
$$

which is pure rather than maximally mixed. Assigning the corresponding zero entropy triple $(0,0,0)$ gives reconstructed weight $0$. Thus the elementary unentangled control has no throat. This comparison is not needed for Theorem 4.2, but it makes the model's dictionary operational: quantum factorization corresponds to absent cut connectivity in these canonical examples.

## 5. Reconstruction algorithm

The geometric calculation can be expressed as a constant-time algorithm.

**Algorithm 5.1 (Two-boundary throat reconstruction).** Given real values $s_L$, $s_R$, and $s_{LR}$:

1. compute $m=s_L+s_R-s_{LR}$;
2. reject the data as inadmissible for a nonnegative one-throat geometry if $m<0$;
3. otherwise return $w=m/2$.

The algorithm uses a fixed number of arithmetic operations, so its time complexity is $O(1)$ and its auxiliary-space complexity is $O(1)$. Under exact arithmetic, Theorem 3.5 proves exact recovery for data generated by the model. Under floating-point arithmetic, numerical tolerance should replace a strict comparison near zero.

A second calculation extracts quantum diagnostics from a real $2\times2$ matrix.

**Algorithm 5.2 (Two-qubit diagnostics).** Given

$$
\Psi=\begin{pmatrix}a&b\\c&d\end{pmatrix},
$$

compute

$$
\Delta=ad-bc,
\qquad C=2|\Delta|,
$$

and

$$
\rho_L=\Psi\Psi^{\mathsf T},
\qquad
\rho_R=\Psi^{\mathsf T}\Psi.
$$

A nonzero $\Delta$ certifies that the state is not a product state. Equality of both marginals with $I/2$ identifies maximal local mixedness. As all matrices have fixed size, time and auxiliary space are $O(1)$.

For a parameterized normalized family

$$
|\psi(\theta)\rangle=\cos\theta|00\rangle+\sin\theta|11\rangle,
\qquad 0\le\theta\le\frac\pi4,
$$

the coefficient matrix is diagonal and

$$
C(\theta)=2|\cos\theta\sin\theta|=|\sin 2\theta|.
$$

The endpoints interpolate from a product state at $\theta=0$ to the Bell state at $\theta=\pi/4$. If one computes the binary entropy

$$
H_2(p)=-p\log_2p-(1-p)\log_2(1-p),
$$

with $p=\cos^2\theta$, then the pure state's subsystem entropies are both $H_2(p)$ and its total entropy is zero. The reconstructed weight is consequently $H_2(p)$. This parameterized observation is a numerical illustration based on the standard entropy formula; the core theorem uses only the Bell endpoint.

## 6. Interpretation and applications

### 6.1 Mutual information as connectivity

The reconstruction formula can be rewritten

$$
w=\frac12 I(L:R).
$$

This identifies positive mutual information with positive connectivity in the one-edge model. The factor $1/2$ has a transparent origin: the unique throat is counted once by $S(L)$ and once by $S(R)$. The total entropy term subtracts contributions associated with the combined boundary; in the generated cut data that term is zero.

This interpretation resembles inverse problems on weighted graphs. Boundary measurements encode sums of weights crossing cuts, and reconstruction attempts to recover hidden edges. In the two-vertex case, the inverse problem has one unknown and is exactly solvable. Weighted trees would introduce many edges and require a sufficiently rich collection of boundary cuts.

### 6.2 Quantum networks

Bell pairs are elementary resources in teleportation, superdense coding, and entanglement swapping. A graph whose edges carry entangled pairs naturally suggests a weighted connectivity model. The present construction supplies the smallest local rule: one Bell pair corresponds to one unit of throat weight. Extending the rule requires care, since multipartite entanglement is not determined by pairwise concurrence and entropy vectors satisfy nontrivial constraints.

### 6.3 Tensor-network intuition

Tensor networks organize a many-body state by contracting lower-dimensional tensors along internal legs. Cuts through those legs often bound or determine entanglement across boundary partitions. A one-throat geometry is the degenerate network with two boundary vertices and one internal connection. Exact reconstruction here illustrates, without additional machinery, how cut data can encode an emergent adjacency and weight.

### 6.4 Distinction from physical wormholes

The model must not be overinterpreted. A weighted edge is not a Lorentzian spacetime. No metric tensor, curvature, causal structure, horizon, field equation, semiclassical limit, or dynamical stability appears. The construction neither predicts traversability nor claims that manipulating a Bell pair produces a macroscopic wormhole. It proves a conditional mathematical statement: under the specified cut dictionary, Bell entanglement reconstructs the model's unit bridge.

That restriction is conceptually useful. It identifies which ingredients are responsible for the result and which would have to be added before stronger physical claims could be considered.

## 7. Discussion

The finite correspondence rests on three exact mechanisms.

First, matrix rank turns separability into algebra. A product state is an outer product, so a nonzero determinant is an obstruction to product structure. For the Bell matrix, this obstruction is maximal under the concurrence normalization.

Second, contraction turns global amplitudes into local states. Multiplying the Bell coefficient matrix by its transpose removes the cross-system labeling and yields $I/2$. This expresses the defining tension of entanglement: the whole is pure and completely specified, while each part is maximally mixed.

Third, cut inversion turns shared information into a geometric parameter. The entropy combination $S(L)+S(R)-S(LR)$ counts the single throat twice, and division by two recovers its weight. For Bell data, the mutual information is $2$ bits and the throat weight is $1$.

The construction is robust under the choice of a general nonnegative throat weight: generated cut data always reconstruct exactly. The Bell result is a distinguished normalization rather than an isolated algebraic coincidence. Nevertheless, the quantum-to-geometric assignment has only been specified for a simple entropy triple. A complete theory would derive all entropy data from density matrices and characterize precisely which triples or higher-dimensional entropy vectors correspond to nonnegative weighted geometries.

A further limitation is the use of real amplitudes. Complex phases are central to quantum mechanics, although the Bell example itself has real coefficients. In the complex case, reduced density matrices use conjugate transpose, and pure-state concurrence is related to the modulus of the coefficient determinant. The same conceptual proof should persist with the correct Hermitian definitions.

## 8. Future work

Several extensions would test how much of the finite dictionary survives beyond the minimal case.

1. Extend the coefficient-matrix model to complex amplitudes and prove the corresponding reduced-density and concurrence statements.
2. Define von Neumann entropy for finite density matrices and derive Bell-pair entropy values from the spectrum of the reduced states instead of recording them directly.
3. Generalize exact reconstruction to weighted trees, recovering all edge weights from a sufficiently rich family of boundary cut entropies.
4. Introduce tensor-network isometries for finite holographic codes and study reconstruction of bulk operators from complementary boundary regions.
5. Relate positive mutual information to connectivity in larger graphs and characterize entropy vectors generated by nonnegative weighted cuts.
6. Add operations such as entanglement swapping and derive the corresponding composition law, if any, for reconstructed throats.
7. Develop the missing continuum structures—operator algebras, limiting procedures, Lorentzian geometry, and gravitational dynamics—needed to compare the finite model with the physical ER=EPR conjecture.

## 9. Boundary cases and normalization

The nonnegativity condition on reconstruction deserves explicit attention. If arbitrary input data satisfy $S(L)+S(R)-S(LR)<0$, then the formula produces a negative number and therefore cannot describe a geometry whose throat weight is required to be nonnegative. Such a triple is rejected by this model rather than interpreted as a negative bridge. For genuine quantum entropies, subadditivity gives $S(LR)\le S(L)+S(R)$, so the condition is natural; nevertheless, the finite reconstruction theorem itself needs only the displayed numerical inequality.

The symmetric generated data also show why three numbers do not imply three geometric degrees of freedom. A one-throat geometry occupies only the ray

$$
(S(L),S(R),S(LR))=(w,w,0),\qquad w\ge0,
$$

inside the space of all triples. Reconstruction is exact on this ray. Away from it, the formula still returns half the mutual-information combination, but no theorem here claims that the original triple was generated by a single throat. In particular, unequal values of $S(L)$ and $S(R)$ or a nonzero total entropy may require additional degrees of freedom or a different cut model.

Finally, “unit bridge” is a normalization statement. Entropy measured in bits assigns the maximally mixed qubit entropy $1$; entropy measured with natural logarithms would assign $\ln 2$. A geometrical convention could either reconstruct weight $\ln 2$ or divide by $\ln 2$ to preserve unit Bell weight. The substantive content is the exact proportionality between the cut combination and the sole geometric weight, not the arbitrary choice of unit.

## 10. Conclusion

A real two-qubit Bell state supplies a complete finite example of geometry reconstructed from entanglement data. Its coefficient matrix has determinant $1/2$ and concurrence $1$, excluding product factorization. Both reduced density matrices are $I/2$. Its entropy data in bits are $(1,1,0)$. The two-boundary cut formula maps these values to a throat of weight $1$, and the same formula exactly recovers every one-throat geometry from the data it generates.

The resulting theorem is intentionally narrow: in this finite model, the Bell pair simultaneously exhibits the quantum signatures of EPR entanglement and the geometric signature of a microscopic ER bridge. The model does not establish the general physical conjecture. It does show, end to end, how nonfactorization, local mixedness, mutual information, and weighted connectivity can become mathematically equivalent aspects of a single small system.
