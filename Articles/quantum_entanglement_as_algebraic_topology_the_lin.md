# When Entanglement Refuses to Be a Linking Number

## A beautiful topological picture meets a decisive arithmetic obstruction

Quantum entanglement invites visual metaphors. Two particles behave as one system even when separated; knots and links bind distant pieces of a curve without gluing them together. The analogy is so natural that one might hope for an exact statement: perhaps the entanglement of two qubits *is* the linking number of curves arising from a Hopf fibration. Product states would correspond to unlinked loops, Bell states to a Hopf link, and intermediate states to intermediate amounts of linking.

There is just one problem. Ordinary linking number counts in integers. Entanglement does not.

That mismatch is not a minor technicality. It gives a clean impossibility theorem, witnessed by one explicit quantum state whose entanglement is exactly $1/2$. No integer-valued linking invariant can equal the concurrence of every pure two-qubit state.

The failed identification nevertheless points toward a better geometric picture. Concurrence is controlled by a determinant—the simplest coordinate of exterior algebra—and that determinant has exactly the continuity, range, and vanishing behavior that entanglement requires. Topology may still illuminate the story, but it must do so through a real-valued geometric quantity rather than an ordinary linking number.

## Four amplitudes and one decisive determinant

A pure state of two qubits can be written

$$
|\psi\rangle=\alpha|00\rangle+\beta|01\rangle+\gamma|10\rangle+\delta|11\rangle,
$$

where $\alpha,\beta,\gamma,\delta$ are complex amplitudes. Physical normalization requires

$$
|\alpha|^2+|\beta|^2+|\gamma|^2+|\delta|^2=1.
$$

Arrange the four amplitudes as a $2\times2$ matrix,

$$
A_\psi=
\begin{pmatrix}
\alpha&\beta\\
\gamma&\delta
\end{pmatrix}.
$$

Its determinant is

$$
D(\psi)=\alpha\delta-\beta\gamma.
$$

For a pure two-qubit state, the concurrence is

$$
C(\psi)=2|D(\psi)|=2|\alpha\delta-\beta\gamma|.
$$

This compact expression captures the essential algebra of bipartite entanglement. If the state is a product,

$$
(u_0|0\rangle+u_1|1\rangle)\otimes(v_0|0\rangle+v_1|1\rangle),
$$

then its coefficient matrix is the outer product of two vectors and has rank one. Its determinant therefore vanishes. Conversely, a nonzero $2\times2$ matrix with zero determinant has rank one, so a normalized state satisfying $D(\psi)=0$ factors into a product. Thus the determinant criterion says:

> **Product-state criterion.** A normalized pure two-qubit state has zero concurrence if and only if $\alpha\delta=\beta\gamma$; equivalently, its coefficient matrix has rank one.

Entanglement begins precisely when the two rows—or the two columns—refuse to be scalar copies of one another.

This determinant also has an exterior-algebra meaning. If the rows are $r_1=(\alpha,\beta)$ and $r_2=(\gamma,\delta)$, then $D(\psi)$ is the coordinate of their wedge product $r_1\wedge r_2$. The wedge vanishes exactly when the rows are linearly dependent. Concurrence is therefore twice the norm of the simplest Plücker coordinate: it measures how much two coefficient directions span an area rather than collapse onto one line.

## Why concurrence always lies between zero and one

Nonnegativity is immediate because concurrence is a norm. The upper bound contains more content. Start with the triangle inequality:

$$
|\alpha\delta-\beta\gamma|
\le |\alpha||\delta|+|\beta||\gamma|.
$$

For nonnegative real numbers $x$ and $y$, the elementary inequality $2xy\le x^2+y^2$ follows from $(x-y)^2\ge0$. Applying it to the two products gives

$$
2|\alpha||\delta|\le |\alpha|^2+|\delta|^2
$$

and

$$
2|\beta||\gamma|\le |\beta|^2+|\gamma|^2.
$$

Adding these inequalities yields the general norm bound

$$
C(\psi)
\le |\alpha|^2+|\beta|^2+|\gamma|^2+|\delta|^2.
$$

For a normalized state, the right-hand side is $1$. Hence:

> **Sharp range theorem.** Every normalized pure two-qubit state satisfies $0\le C(\psi)\le1$.

Both endpoints occur. Product states have concurrence $0$. The Bell states have concurrence $1$, so the interval cannot be narrowed.

The proof also explains why concurrence varies smoothly. It is built from addition, multiplication, subtraction, and the complex norm. Small changes in amplitudes produce small changes in $C(\psi)$. This continuity is exactly what an integer-valued invariant cannot imitate across a connected family of states.

## Bell states at the summit

The four familiar Bell states are

$$
|\Phi^\pm\rangle=\frac{|00\rangle\pm|11\rangle}{\sqrt2},
\qquad
|\Psi^\pm\rangle=\frac{|01\rangle\pm|10\rangle}{\sqrt2}.
$$

Each is normalized. For $|\Phi^\pm\rangle$, the determinant is $\pm1/2$; for $|\Psi^\pm\rangle$, it is $\mp1/2$. In every case,

$$
C=2\left|\frac12\right|=1.
$$

Thus all four Bell states attain maximal concurrence. This agrees with the seductive Hopf-link picture: the most entangled states can be associated metaphorically with complete linking. But agreement at the endpoints does not establish an equality of invariants. Many very different functions share values $0$ and $1$.

Concurrence is also unchanged by a global phase. If every amplitude is multiplied by a complex number $u$ with $|u|=1$, then the determinant is multiplied by $u^2$. Since $|u^2|=1$,

$$
C(u\psi)=2|u^2D(\psi)|=2|D(\psi)|=C(\psi).
$$

That is physically necessary: multiplying an entire state vector by a common phase does not change the quantum state it represents.

## The half-entangled witness

Now consider the normalized state

$$
|\chi\rangle=rac12|00\rangle+rac1{\sqrt2}|01\rangle+rac12|11\rangle.
$$

Its squared norm is

$$
\left|\frac12\right|^2+
\left|\frac1{\sqrt2}\right|^2+
0^2+
\left|\frac12\right|^2
=rac14+rac12+rac14=1.
$$

Its determinant is especially simple:

$$
D(\chi)=\frac12\cdot\frac12-rac1{\sqrt2}\cdot0=rac14.
$$

Therefore

$$
C(\chi)=2\left|\frac14\right|=rac12.
$$

This single value overturns the proposed universal equality with ordinary linking number. Suppose an assignment associated an integer $L(\psi)$ to every normalized state and claimed

$$
C(\psi)=|L(\psi)|.
$$

Applying the claim to $|\chi\rangle$ would force

$$
\frac12=|L(\chi)|.
$$

But the absolute value of an integer is an integer. It cannot equal $1/2$. We obtain the central conclusion:

> **Integer-linking obstruction.** No integer-valued invariant can agree, in absolute value, with concurrence on every normalized pure two-qubit state. In particular, ordinary linking number cannot universally equal concurrence.

The argument is stronger than a failed numerical experiment. It excludes *every possible assignment* of ordinary integer linking numbers, regardless of how the curves are constructed, as long as the claimed equality is required for all normalized pure states.

## A dimensional warning from the Hopf fibration

There is a second reason to be cautious. Normalized two-qubit state vectors form the sphere $S^7$ inside $\mathbb C^4\cong\mathbb R^8$. The quaternionic Hopf fibration maps

$$
S^7\longrightarrow S^4.
$$

Its fibres are copies of $S^3$, not circles. The familiar linked-circle picture belongs to the classical Hopf fibration $S^3\to S^2$, whose fibres are $S^1$. Moving from complex to quaternionic Hopf geometry changes the dimensions of both total space and fibres. One cannot simply import the ordinary two-circle linking story unchanged.

This does not make Hopf geometry irrelevant. It means that the geometric object must be chosen with care. Higher-dimensional linking phenomena exist, as do differential forms, holonomy, calibrated volumes, and integral kernels that produce real numbers. What fails is the literal assertion that a continuously varying number in $[0,1]$ is always an ordinary integer linking number.

## Why endpoint tests can deceive

A proposed equation between two quantities should be tested where they are most likely to disagree, not only where intuition says they should agree. Product states and Bell states are poor discriminators for the linking hypothesis because both concurrence and the simplest linking story return the same endpoint values: $0$ for “separate” and $1$ for “fully linked.” A thousand repetitions of those endpoint tests would add no new information.

Intermediate states are different. Consider a continuous path of normalized states beginning at a product state and ending at a Bell state. Because concurrence is continuous, it cannot jump directly from $0$ to $1$; it must pass through every value between them. In particular, some states must have concurrence $1/3$, $1/2$, or $\sqrt2/2$. An ordinary linking number cannot follow this motion point by point. It remains an integer until a topological singularity changes the link type, and then it jumps by an integer amount.

This observation also clarifies the role of numerical sampling. Generating many random normalized states would reveal a cloud of real concurrence values throughout $[0,1]$. Such a plot is an excellent illustration, but it is not the logical foundation of the obstruction. The exact state $|\chi\rangle$ already supplies a conclusive proof. Sampling helps human intuition; the fraction $1/2$ settles the theorem.

## What survives: geometry through exterior algebra

The corrected bridge is both simpler and more robust. Concurrence is the norm of a determinant coordinate. Determinants belong naturally to exterior algebra, Grassmannian geometry, and the study of rank varieties. Product states form the rank-one locus cut out by

$$
\alpha\delta-\beta\gamma=0.
$$

After projectivizing to remove global phase and scale, this locus is the Segre variety obtained from pairs of one-qubit states. Entanglement measures departure from that variety.

This viewpoint suggests several research directions. One can seek a real-valued Hopf-geometric functional that equals $0$ on product states, equals $1$ on maximally entangled states, and varies continuously in between. One can classify all states attaining equality in the determinant bound. One can compare concurrence with metric distance to the product-state variety. For multipartite systems, one can replace the single $2\times2$ determinant by families of minors—Plücker coordinates of coefficient flattenings—to build richer entanglement measures.

The story is therefore not that topology has nothing to say about entanglement. Rather, topology imposes discipline on the analogy. Discrete invariants detect discrete classes; concurrence measures a continuum. A successful geometric interpretation must respect that continuum.

The most useful outcome of a beautiful conjecture is not always its confirmation. Sometimes one explicit state reveals the exact point where the metaphor breaks, while the proof of failure uncovers the structure that should replace it. Here the link is not an integer wound around another integer. It is an algebraic area: the magnitude of $\alpha\delta-\beta\gamma$, vanishing when two directions collapse and reaching its maximum when they stand in perfect quantum balance.
