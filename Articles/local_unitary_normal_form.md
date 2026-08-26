# The Only Shape of Perfect Entanglement

## A $2\times 2$ matrix, a determinant, and the rigidity of the quantum world

Take a sheet of paper and write down four complex numbers in a square:

$$M \;=\; \begin{pmatrix} m_{00} & m_{01} \\ m_{10} & m_{11}\end{pmatrix}.$$

That is all the data in a pair of quantum bits. The number $m_{ij}$ is the amplitude with which the first bit reads $i$ and the second reads $j$; the probability of seeing the outcome $(i,j)$ is $|m_{ij}|^2$, and because *something* must happen, the four probabilities sum to one:

$$\|M\|_F^2 \;=\; \sum_{i,j} |m_{ij}|^2 \;=\; 1 .$$

Now ask a question that sounds like it belongs to linear algebra and turns out to belong to physics: **how large can $|\det M|$ be?**

The answer is $\tfrac12$, and the matrices that achieve it are — up to a change of basis on each bit separately — *one single matrix*. That rigidity is the subject of this article.

---

## The determinant is entanglement

Why should anyone care about the determinant of an amplitude matrix? Because of a small miracle of dictionary.

Two quantum bits are *unentangled* — a "product state" — precisely when each bit has a state of its own and the joint amplitudes factor:

$$m_{ij} \;=\; u_i\, w_j .$$

But a matrix whose entries factor like that is a rank-one matrix, and a rank-one $2\times2$ matrix has determinant zero. Conversely, any $2\times2$ matrix of vanishing determinant has rank at most one and so does factor. So:

> **Theorem (Product states are the zeros of the determinant).** A two-qubit state factors as a product of one-qubit states if and only if $\det M = 0$.

The determinant is therefore not merely *a* measure of entanglement, it is *the* obstruction to factoring. Wootters' **concurrence**

$$C(M) \;=\; 2\,|\det M|$$

simply rescales it so that the interesting range is $[0,1]$: zero for product states, and — as we are about to see — never more than one.

---

## The sharp bound, from a two-hundred-year-old identity

Write $r_0 = (m_{00}, m_{01})$ and $r_1 = (m_{10}, m_{11})$ for the two rows of $M$, regarded as vectors in $\mathbb{C}^2$. Lagrange's identity in dimension two — the two-dimensional case of the Cauchy–Binet formula, and a one-line calculation once you expand real and imaginary parts — says

$$|\langle r_0, r_1\rangle|^2 \;+\; |\det M|^2 \;=\; \|r_0\|^2\,\|r_1\|^2 ,$$

where $\langle r_0, r_1\rangle = m_{00}\overline{m_{10}} + m_{01}\overline{m_{11}}$ is the Hermitian inner product of the rows. It is the Pythagorean theorem of $2\times2$ determinants: the *area* squared plus the *overlap* squared equals the product of the squared lengths.

Two consequences fall out immediately. First, dropping the (non-negative) overlap term,

$$|\det M|^2 \;\le\; \|r_0\|^2\,\|r_1\|^2 .$$

Second, by the arithmetic–geometric mean inequality $2\sqrt{xy} \le x+y$,

$$2\,|\det M| \;\le\; 2\,\|r_0\|\,\|r_1\| \;\le\; \|r_0\|^2 + \|r_1\|^2 \;=\; \|M\|_F^2 .$$

> **Theorem (Sharp Hadamard-type bound).** For every complex $2\times2$ matrix, $2|\det M| \le \|M\|_F^2$. In particular, every normalized two-qubit state satisfies $C(M) \le 1$.

We call a normalized state with $C(M)=1$ a **sharp maximizer**. Everything that follows is the analysis of *when the two inequalities above are simultaneously tight* — and that is where the rigidity comes from. Equality in AM–GM forces $\|r_0\| = \|r_1\|$; since the two squared lengths add to $1$, each must be $\tfrac12$. Equality in the first step forces $\langle r_0, r_1\rangle = 0$. So:

> **Theorem (Row classification).** The rows of a normalized sharp maximizer are orthogonal and each has squared length $\tfrac12$.

---

## What the classification means physically

Say it in matrix language. "Rows of squared length $\tfrac12$, mutually orthogonal" is exactly the statement

$$M M^{\dagger} \;=\; \tfrac12 I .$$

The matrix $MM^{\dagger}$ is the **reduced density matrix** of the first qubit: the state you see if you take the pair, throw the second bit away, and look only at the first. So the row classification says something startling in plain language:

> **A pair of qubits is maximally entangled exactly when either half of it, looked at alone, is maximally *random*.**

The converse holds too, and is even easier: if $MM^\dagger = \tfrac12 I$, then taking traces gives $\|M\|_F^2 = 1$ and taking determinants gives $|\det M|^2 = \tfrac14$, so $C(M) = 1$. Maximal entanglement and maximal local ignorance are the *same* condition.

> **Theorem (Maximal entanglement $=$ maximally mixed marginal).** A two-qubit state is a sharp maximizer if and only if $MM^{\dagger} = \tfrac12 I$.

This is the reason a maximally entangled pair is useless on its own and priceless as a pair. Each half is a perfect coin flip and carries no information whatsoever; all the information lives in the correlation.

---

## One state, wearing many costumes

Here is the punchline. A matrix $A$ is *unitary* when $AA^{\dagger} = I$, i.e. when its rows form an orthonormal basis. Our sharp maximizer has rows of length $1/\sqrt2$ that are orthogonal — so $\sqrt2\,M$ is unitary.

> **Theorem (Unitary rescaling).** If $M$ is a sharp maximizer, then $\sqrt2\,M$ is a unitary matrix.

Now let $\Phi = \tfrac{1}{\sqrt2}I = \operatorname{diag}(1/\sqrt2, 1/\sqrt2)$ — the celebrated **Bell state** $\tfrac{1}{\sqrt2}(|00\rangle + |11\rangle)$. Setting $U = \sqrt2\,M$ we obtain $M = U\,\Phi$ instantly. And the operations $M \mapsto UMV^{\mathsf T}$, for unitaries $U$ and $V$, are precisely the *local* operations: rotate the first qubit by $U$, rotate the second by $V$, never letting them interact. They preserve $\|M\|_F^2$ (unitaries preserve length) and they preserve $|\det M|$ (unitary determinants have modulus one). So they preserve sharpness.

> **Theorem (Local-unitary normal form).** A two-qubit state is a maximally entangled normalized state if and only if it can be written $M = U\,\Phi\,V^{\mathsf T}$ with $U$ and $V$ unitary, where $\Phi = \operatorname{diag}(1/\sqrt2,1/\sqrt2)$.

The set of maximally entangled two-qubit states — a curved, six-real-dimensional surface inside the seven-sphere of normalized states — is *one orbit*. There is, in a precise sense, only one maximally entangled state; everything else is that state seen from a rotated coordinate frame.

Two refinements sharpen the picture, and both come from the fact that $\Phi$ is a *scalar* matrix and therefore commutes with everything.

- **One-sided transitivity.** You never need both factors: $M$ is a sharp maximizer iff $M = U\Phi$ for some unitary $U$, and equally iff $M = \Phi V^{\mathsf T}$ for some unitary $V$. Rotating just the first qubit already reaches every maximally entangled state. Consequently, given *any* two maximally entangled states $M$ and $N$, there is a unitary $W$ with $N = WM$: acting on one side of one qubit suffices to convert either into the other.
- **The stabilizer.** Which local rotations leave the Bell state exactly where it is? Precisely the pairs $(U, \overline{U})$: the local rotation $U \otimes V$ fixes $\Phi$ if and only if $V$ is the entrywise complex conjugate of $U$. This is the mathematical fingerprint of the Bell state's famous *rotational invariance* — turn one particle and you can always undo it by turning the other the conjugate way, which is why the correlations of an entangled pair look the same in every direction.

---

## Flat states, Hadamard matrices, and a count of eight

Among the maximally entangled states there is a distinguished family: the **flat** ones, where all four amplitudes have the same modulus $\tfrac12$, so all four measurement outcomes are equally likely. Multiply such a matrix by $2$ and you get a matrix with unimodular entries and orthogonal rows — a **complex Hadamard matrix** of order two.

The classical fact that all order-two complex Hadamard matrices are equivalent to the Fourier matrix

$$F_2 \;=\; \begin{pmatrix} 1 & 1 \\ 1 & -1\end{pmatrix}$$

becomes here a statement about a much smaller symmetry group. You do not need all of the unitaries — you only need to multiply rows and columns by phases.

> **Theorem (Dephasing of flat maximizers).** A state is a flat sharp maximizer if and only if it has the form $D\cdot(\tfrac12 F_2)\cdot E$ with $D$ and $E$ diagonal unitary matrices (that is, diagonal matrices whose entries are phases).

The maximizer set is one orbit of a six-dimensional group; the *flat* maximizers are already one orbit of a three-dimensional torus of phases. That is a rigidity phenomenon: the flat locus has no room to wiggle beyond the obvious phase freedom.

Restrict further, to real amplitudes: each entry is $\pm\tfrac12$, giving $2^4 = 16$ sign patterns. Which of them are maximally entangled? Exactly those where the two "diagonal agreements" disagree — writing the pattern as $\begin{pmatrix} a & b \\ c & d\end{pmatrix}$, the condition is that "$a=d$" and "$b=c$" have opposite truth values.

> **Theorem (The count).** Exactly $8$ of the $16$ real sign patterns are maximally entangled: the real Hadamard matrices of order two, forming one orbit of the sign group $\{\pm1\}^3$ through $F_2$.

Half of the sign patterns work, half do not, and the eight that work are a single orbit. Combinatorics and quantum mechanics shaking hands.

---

## The Bell basis: four maximizers that span everything

The orbit of $\Phi$ is not just large — it is large enough to contain a *whole coordinate system*. Apply the three Pauli matrices

$$\sigma_x = \begin{pmatrix}0&1\\1&0\end{pmatrix},\quad \sigma_y = \begin{pmatrix}0&-i\\ i&0\end{pmatrix},\quad \sigma_z = \begin{pmatrix}1&0\\0&-1\end{pmatrix}$$

to the first qubit of the Bell state, together with the identity, and you get four states $\Phi_k = \tfrac1{\sqrt2}\sigma_k$.

> **Theorem (Bell basis).** The four states $\tfrac1{\sqrt2}I$, $\tfrac1{\sqrt2}\sigma_x$, $\tfrac1{\sqrt2}\sigma_y$, $\tfrac1{\sqrt2}\sigma_z$ are all maximally entangled, are orthonormal for the Hilbert–Schmidt inner product $\langle M,N\rangle = \sum_{ij}\overline{m_{ij}}n_{ij}$, and every two-qubit state expands uniquely as $M = \sum_k \langle \Phi_k, M\rangle\, \Phi_k$.

This one fact is the engine of two of the most famous protocols in quantum information. In **superdense coding**, Alice holds half of a Bell pair and applies one of the four Pauli operations to *her* qubit alone; because the four results are orthogonal, Bob can tell which she chose — two classical bits transmitted by touching one qubit. In **teleportation**, a measurement in this basis is what collapses an unknown state into a form Bob can reconstruct. The mathematics is exactly the statement above: an orthonormal basis made entirely of maximally entangled states, reachable from one another by acting on a single side.

---

## Two more ways to say "maximal"

The same $2\times2$ Cayley–Hamilton computation yields two further characterizations, both worth stating because they are the ones physicists reach for.

**Purity.** The purity of the marginal is $\operatorname{tr}\rho^2$ where $\rho = MM^{\dagger}$. For a normalized state,

$$C(M)^2 \;=\; 2\bigl(1 - \operatorname{tr}\rho^2\bigr),$$

so the squared concurrence is exactly twice the *linear entropy* of the marginal. Since $C \le 1$, the purity satisfies $\operatorname{tr}\rho^2 \ge \tfrac12$, and equality holds precisely at the sharp maximizers. Maximal entanglement is minimal purity.

**Schmidt spectrum.** The eigenvalues of $\rho$ — the Schmidt coefficients — are pinned down by its trace ($=1$) and determinant ($=|\det M|^2$). Cayley–Hamilton gives

$$\Bigl(\rho - \tfrac{1+\sqrt{1-C^2}}{2}I\Bigr)\Bigl(\rho - \tfrac{1-\sqrt{1-C^2}}{2}I\Bigr) = 0,$$

so the spectrum is $\bigl(1 \pm \sqrt{1-C^2}\bigr)/2$. The two extremes of the entanglement scale are the two degeneracies of this spectrum: the coefficients *coincide* exactly at the maximizers ($C=1$, spectrum $\{\tfrac12,\tfrac12\}$), and one of them *vanishes* exactly at the product states ($C=0$, spectrum $\{1,0\}$). The whole scale of entanglement is the interpolation between "flat spectrum" and "concentrated spectrum".

---

## The classification is stable, not just exact

A classification theorem that only speaks about exact maximizers is fragile: real experiments never hit $C=1$ on the nose. Happily, the computation above is an *identity*, not merely an inequality, and identities survive perturbation. Measuring the failure of the marginal to be maximally mixed in Frobenius norm, one finds exactly

$$\bigl\|\,MM^{\dagger} - \tfrac12 I\,\bigr\|_F^2 \;=\; \frac{1 - C(M)^2}{2} ,$$

for every normalized state. In particular, since $1-C^2 = (1-C)(1+C) \le 2(1-C)$,

$$\bigl\|\,MM^{\dagger} - \tfrac12 I\,\bigr\|_F^2 \;\le\; 1 - C(M).$$

So a state whose concurrence falls short of $1$ by $\varepsilon$ has a marginal within $\sqrt{\varepsilon}$ of maximally mixed — and the distance vanishes if and only if the state is exactly a sharp maximizer. The classification degrades gracefully: nearly maximal entanglement really does mean nearly maximal local randomness, with an explicit constant.

---

## Why this is a story about rigidity

Step back and the shape of the argument is startlingly simple. One identity — Lagrange's, the two-dimensional Cauchy–Binet — plus AM–GM produces the sharp bound. The *equality case* of that same identity produces the entire classification: orthogonal rows, a maximally mixed marginal, a unitary after rescaling, a single orbit, an explicit stabilizer, a finite count in the real case, an orthonormal basis of maximizers, and a stability estimate. The analytic content of "maximal entanglement" is one equality case of one classical identity.

There is a broader lesson in that. Maximal objects tend to be rigid: the extremizers of a sharp inequality are usually a single symmetry orbit, and the inequality's proof, read backwards, is the classification. Hadamard matrices, extremal graphs, isoperimetric sets, and — as here — maximally entangled states all fit the pattern. The Bell state is not one of many equally good maximally entangled states. Up to the freedom of choosing coordinates on each particle separately, it is the *only* one.

And the flat case shows the rigidity is layered: within the six-dimensional orbit of maximizers sits the flat locus, itself a single orbit of a three-dimensional torus of phases, with exactly eight real representatives. Zoom in and the symmetry group shrinks but the "single orbit" conclusion survives. That layering — global rigidity, then finer rigidity inside — is the signature of an extremal problem whose answer is truly unique.
