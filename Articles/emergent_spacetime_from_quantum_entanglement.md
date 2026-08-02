# When Entanglement Draws a Bridge

## A finite window onto emergent spacetime

Two of modern physics' strangest ideas may be different descriptions of the same pattern. Quantum entanglement says that a composite system can possess definite correlations even when neither part has a definite state of its own. General relativity says that geometry can connect regions through an Einstein–Rosen bridge, a “throat” in spacetime more commonly called a wormhole. The slogan ER=EPR proposes a relationship between these phenomena: entanglement may be the microscopic thread from which spatial connection is woven.

That slogan is sweeping, and the full physical conjecture remains far beyond a two-qubit calculation. Yet a small model can expose its mathematical skeleton with unusual clarity. In the model developed here, a quantum state lives on two qubits, while the corresponding geometry has two boundaries and at most one weighted throat between them. The bridge is not assumed by hand after the calculation. Its weight is reconstructed from boundary entanglement data. For the maximally entangled Bell pair, the answer is exactly one unit.

The result is modest but precise: the same Bell pair has a nonzero algebraic signature of entanglement, maximally mixed local states, and boundary data that reconstruct a unit microscopic bridge. To see why those statements fit together, we begin with a tiny matrix.

## A quantum state as a square of amplitudes

Restrict attention to real amplitudes. Any pure state of two qubits can be written

$$
|\psi\rangle=a|00\rangle+b|01\rangle+c|10\rangle+d|11\rangle,
$$

and represented by its coefficient matrix

$$
\Psi=\begin{pmatrix}a&b\\c&d\end{pmatrix}.
$$

Rows label the left qubit and columns label the right qubit. This simple arrangement turns a physical distinction into elementary linear algebra. A product state is one that factors as

$$
|\psi\rangle=|u\rangle\otimes|v\rangle.
$$

If $u=(u_0,u_1)$ and $v=(v_0,v_1)$, then its matrix is the outer product

$$
\Psi=uv^{\mathsf T},
$$

so every row is proportional to every other row. Such a matrix has rank at most one and therefore

$$
\det\Psi=ad-bc=0.
$$

This gives the first basic result.

**Product-State Determinant Theorem.** Every real pure two-qubit product state has zero coefficient-matrix determinant.

The proof is immediate from the outer-product form: substituting $a=u_0v_0$, $b=u_0v_1$, $c=u_1v_0$, and $d=u_1v_1$ makes $ad-bc$ cancel exactly. Its contrapositive is a useful entanglement test: a nonzero determinant rules out product structure.

For normalized real two-qubit states, define the concurrence by

$$
C(\psi)=2|\det\Psi|.
$$

It vanishes for every product state and reaches one for the Bell state considered below. Concurrence is therefore a scalar gauge of how decisively the two-qubit amplitudes resist factorization.

## The Bell pair: globally pure, locally featureless

The protagonist is the Bell state

$$
|\Phi^+\rangle=\frac{|00\rangle+|11\rangle}{\sqrt2},
$$

whose coefficient matrix is

$$
B=\frac{1}{\sqrt2}\begin{pmatrix}1&0\\0&1\end{pmatrix}.
$$

Its determinant is $1/2$, so its concurrence is

$$
C(\Phi^+)=2\left|\frac12\right|=1.
$$

This proves two linked statements.

**Bell Concurrence Theorem.** The Bell state $|\Phi^+\rangle$ has unit concurrence.

**Bell Nonfactorization Theorem.** The Bell state cannot be expressed as a product of one-qubit states.

For the second theorem, suppose it did factor. The Product-State Determinant Theorem would force its determinant, and hence its concurrence, to vanish. That contradicts unit concurrence.

Entanglement has another face. Although the joint Bell state is perfectly specified, either qubit viewed alone looks maximally random. For a real coefficient matrix $\Psi$, define the left and right reduced density matrices by contraction:

$$
\rho_L=\Psi\Psi^{\mathsf T},\qquad
\rho_R=\Psi^{\mathsf T}\Psi.
$$

In components these are

$$
(\rho_L)_{ik}=\sum_j\Psi_{ij}\Psi_{kj},\qquad
(\rho_R)_{j\ell}=\sum_i\Psi_{ij}\Psi_{i\ell}.
$$

For $B=I/\sqrt2$, both products are $I/2$.

**Bell Marginal Theorem.** Both one-qubit reduced density matrices of $|\Phi^+\rangle$ equal the maximally mixed state:

$$
\rho_L=\rho_R=\frac12\begin{pmatrix}1&0\\0&1\end{pmatrix}.
$$

The proof is a direct multiplication using $(1/\sqrt2)^2=1/2$. This is the heart of the quantum paradox. All information about the Bell state is global. Each part alone contains no preferred computational-basis outcome, yet the pair is perfectly correlated.

Measured in bits, a maximally mixed qubit has entropy $1$, while the complete pure pair has entropy $0$. Thus the Bell data are

$$
S(L)=1,\qquad S(R)=1,\qquad S(LR)=0.
$$

Here these entropy values are supplied as boundary data, rather than derived through a general spectral definition of entropy. That distinction keeps the model finite and transparent.

## Turning correlations into a throat

Now exchange the quantum picture for a geometric toy universe. It has two boundary components, called $L$ and $R$, and a single possible throat joining them. The throat carries a nonnegative real weight $w$. One may imagine this weight as a normalized cross-sectional capacity. It is not a literal length or area in a dynamical spacetime; it is the sole geometric parameter in a cut model.

The cut rule is simple. Separating either boundary from the other crosses the throat once, while taking both boundaries together crosses nothing. Therefore a geometry of weight $w$ generates boundary data

$$
S(L)=w,\qquad S(R)=w,\qquad S(LR)=0.
$$

Conversely, given three boundary entropy values satisfying

$$
S(L)+S(R)-S(LR)\ge 0,
$$

define the reconstructed throat weight by

$$
w_{\mathrm{rec}}=rac{S(L)+S(R)-S(LR)}{2}.
$$

The numerator is the mutual information between the two boundaries. In this two-vertex setting, half the mutual information is exactly the bridge weight.

**One-Throat Reconstruction Theorem.** If a nonnegative one-throat geometry has weight $w$ and produces cut data $S(L)=w$, $S(R)=w$, and $S(LR)=0$, then the reconstruction formula returns the original weight:

$$
w_{\mathrm{rec}}=w.
$$

Indeed,

$$
\frac{w+w-0}{2}=w.
$$

This theorem says that no geometric information is lost when the one-parameter geometry is encoded by its boundary cuts. In larger networks, reconstruction can be subtle or underdetermined. Here it is exact because there is only one unknown edge.

Call a unit-weight throat a microscopic Einstein–Rosen bridge in this finite model. Feeding the Bell entropy data into the reconstruction gives

$$
w_{\mathrm{rec}}=\frac{1+1-0}{2}=1.
$$

Hence we obtain the geometric half of the correspondence.

**Bell-Bridge Reconstruction Theorem.** The boundary entropy data of a Bell pair reconstruct a unit-weight microscopic Einstein–Rosen bridge in the two-boundary cut model.

## The finite ER=EPR correspondence

The separate calculations now lock together.

**Finite ER=EPR Correspondence Theorem.** For the Bell state $|\Phi^+\rangle$, all of the following hold simultaneously:

1. the state is not a product state;
2. its left reduced density matrix is $I/2$;
3. its right reduced density matrix is $I/2$; and
4. its boundary entropy triple $(1,1,0)$ reconstructs a unit-weight throat.

The proof combines the determinant test, the direct calculation of both reduced matrices, and the one-throat reconstruction formula. No single step is mysterious. The conceptual force comes from their alignment: algebraic nonfactorization, local mixedness, and geometric connectivity are three views of one finite pattern.

A concrete comparison sharpens the point. Consider the product state $|00\rangle$. Its coefficient matrix has determinant zero and concurrence zero. Each reduced state is the pure projector onto $|0\rangle$, not $I/2$. Its natural entropy data are $(0,0,0)$, and the same cut formula returns a throat weight of zero. In the model, removing entanglement removes the bridge.

## What this model says—and what it does not

The reconstruction formula resembles a principle that appears throughout holographic thinking: geometry can be inferred from entropic information attached to boundaries. The model distills that principle to its smallest nontrivial case. Mutual information is not merely a report about correlation; after division by two, it becomes the weight of a connecting edge.

That conversion has practical echoes beyond quantum gravity. Weighted cut models appear in network science, where observations at terminals can reveal hidden links. Tensor networks use entanglement structure to organize effective geometry. Quantum communication protocols treat Bell pairs as resources, and network capacities can be described by how many entangled links cross a partition. In each setting, a global pattern can be inferred from what cuts disclose.

But precision requires restraint. This finite algebraic model does not prove that physical wormholes are literally created by laboratory Bell pairs. It contains no continuum spacetime, no Lorentzian metric, no gravitational field equations, no dynamics, and no quantum field theory. The word “bridge” has a stipulated meaning here: one nonnegative edge whose weight obeys a cut-entropy rule. The entropy triple for the Bell state is recorded from its familiar one-qubit behavior rather than developed from a full entropy theory.

Those limitations are also a research map. Complex amplitudes would cover general two-qubit states. A spectral definition of von Neumann entropy would derive the values $1$, $1$, and $0$ internally. Weighted trees would replace the single throat and ask whether many hidden edges can be reconstructed from many boundary cuts. Entanglement swapping could test whether joining quantum correlations corresponds to composing geometric throats. Finite holographic codes could add bulk operators and complementary boundary reconstruction.

The deepest lesson of the toy model is methodological. It also suggests a striking experimental style of thought: do not search first for coordinates or distances; ask which partitions share information, then infer the simplest network compatible with those answers. In this view, geometry is an economical summary of correlation. “Spacetime from entanglement” need not begin as an impenetrable claim about the universe. It can begin with a matrix, a determinant, two contractions, and a cut. The Bell pair refuses to split; each half forgets everything locally; the shared information survives; and a geometric rule turns that shared information into a bridge. In this smallest world, entanglement does not merely live across space. It specifies the connection that space is allowed to have.
