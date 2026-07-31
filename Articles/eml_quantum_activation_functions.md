# When a Quantum Neuron Falls Off the Unitary Sphere

## A promising formula meets a decisive boundary case

Quantum computing and neural networks share a taste for composition. A neural network builds complicated behavior by chaining simple transformations; a quantum circuit does the same with unitary gates. It is therefore tempting to take a successful classical activation pattern, replace scalar exponentials and logarithms by their matrix counterparts, and hope that the resulting “quantum neuron” becomes a flexible quantum gate.

Consider two Hermitian matrices $H_1$ and $H_2$. Hermitian matrices represent observables and Hamiltonians: their eigenvalues are real, and the exponential

$$
E(H_1)=\exp(iH_1)
$$

is unitary. That is exactly the kind of transformation quantum mechanics permits for a closed system. Inspired by exponential–logarithmic activations, one may then propose

$$
N(H_1,H_2)=\exp(iH_1)\,\Log(I+iH_2),
$$

where $I$ is the identity matrix and $\Log$ denotes the principal matrix logarithm. The enticing conjecture is that, for a single qubit, varying the two Hermitian inputs might produce every element of $SU(2)$, the group of determinant-one $2\times2$ unitary matrices.

The formula contains plenty of parameters. Each Hermitian $2\times2$ matrix has four real degrees of freedom, while $SU(2)$ has only three. Yet parameter counting is not geometry, and it is not a proof. Before asking whether a formula covers an entire group, one must ask a more basic question: does it even land in that group?

Here the answer is no.

## The zero-input obstruction

Set the second Hamiltonian to zero. Then

$$
I+iH_2=I
$$

and the principal logarithm of the identity is zero:

$$
\Log(I)=0.
$$

Consequently, for every Hermitian $H_1$,

$$
N(H_1,0)=\exp(iH_1)\,0=0.
$$

This is the **Zero-Input Theorem**: *for every Hermitian first Hamiltonian, the raw quantum exponential–logarithm activation vanishes when its second Hamiltonian is zero.*

The zero matrix is not unitary in any nontrivial unital matrix algebra. A unitary matrix $U$ must satisfy

$$
U^*U=UU^*=I,
$$

where $U^*$ is the conjugate transpose. For $U=0$, the left-hand side is zero rather than $I$. It follows immediately that the proposed expression is not always unitary-valued. In particular, it cannot define an unrestricted map from pairs of Hermitian matrices into $SU(2)$.

This is not a rare numerical accident, a branch-cut subtlety, or a failure at some exotic parameter. It occurs at the most natural input imaginable. Moreover, no adjustment of $H_1$ can repair it: multiplying zero by a unitary matrix still gives zero. Thus the **Unitary-Target Exclusion Theorem** says: *if $U$ is any unitary matrix and $H_1$ is Hermitian, then $N(H_1,0)\ne U$.*

The distinction matters. A family of expressions might still contain every desired target somewhere among its outputs, even though some other parameter choices produce nonunitary matrices. What has been ruled out is the stronger and often implicit claim that the raw formula itself is an $SU(2)$-valued activation on its full domain. Coverage, if it holds after suitable parameter choices, is a separate problem.

## A unitary factor cannot hide a bad logarithm

The first exponential factor is always unitary, so perhaps it could somehow “correct” the logarithmic factor. It cannot. Unitary multiplication rotates geometry; it does not repair lengths or singular values.

Write

$$
E=\exp(iH_1),\qquad L=\Log(I+iH_2),
$$

so that $N=EL$. Suppose $EL$ is unitary. Because $E$ is unitary, $E^*E=I$. Multiplying $EL$ on the left by $E^*$ gives

$$
E^*(EL)=(E^*E)L=L.
$$

Both $E^*$ and $EL$ are unitary, and a product of unitary matrices is unitary. Therefore $L$ itself must be unitary.

This yields the **Log-Factor Necessity Theorem**: *if $N(H_1,H_2)$ is unitary, then $\Log(I+iH_2)$ is unitary.* Its contrapositive is an especially useful diagnostic: *if the logarithmic factor is not unitary, then no choice of the first Hamiltonian can make the output unitary.*

There is also a direct geometric calculation. Since $E^*E=I$,

$$
(EL)^*(EL)=L^*E^*EL=L^*L.
$$

Thus $EL$ is unitary exactly when $L$ is unitary. Left multiplication by $E$ preserves every singular value of $L$. The logarithmic factor is not merely one contributor among two; it is the complete gatekeeper for unitarity.

## What the logarithm is doing

For Hermitian $H_2$, the matrix $I+iH_2$ is normal. Diagonalize $H_2$ as

$$
H_2=Q\,\operatorname{diag}(\lambda_1,\ldots,\lambda_n)Q^*,
$$

with real eigenvalues $\lambda_j$ and unitary $Q$. Functional calculus gives

$$
\Log(I+iH_2)
=Q\,\operatorname{diag}\bigl(\Log(1+i\lambda_1),\ldots,
\Log(1+i\lambda_n)\bigr)Q^*.
$$

Therefore the logarithmic factor is unitary precisely when every scalar eigenvalue $\Log(1+i\lambda_j)$ lies on the complex unit circle. For a real scalar $t$,

$$
\Log(1+it)=\tfrac12\log(1+t^2)+i\arctan(t),
$$

so its squared modulus is

$$
f(t)=\tfrac14\log^2(1+t^2)+\arctan^2(t).
$$

At $t=0$, this is $0$, recovering the obstruction. Numerical exploration shows that $f(t)$ eventually exceeds $1$, suggesting nonzero values of $t$ where $f(t)=1$. Such a value would make a scalar logarithmic factor unitary. This observation does not undo the zero-input theorem; instead, it points toward a restricted domain on which the architecture could be meaningful.

## A better design principle

The lesson is constructive. If a neural layer is intended to represent quantum gates, group membership should be built into its architecture rather than inferred from suggestive notation.

One option is **domain restriction**. Permit only those $H_2$ for which

$$
\Log(I+iH_2)^*\Log(I+iH_2)=I.
$$

On that subset, both factors are unitary and their product is unitary. The spectral formula above turns this matrix condition into scalar conditions on the eigenvalues of $H_2$.

A second option is **polar normalization**. Given

$$
L=\Log(I+iH_2),
$$

and assuming $L$ is invertible, define its unitary polar factor by

$$
P(L)=L(L^*L)^{-1/2}.
$$

Then replace the raw activation by

$$
\widetilde N(H_1,H_2)=\exp(iH_1)P(L).
$$

The normalization removes radial distortion while retaining the angular part of $L$. A determinant correction can then be used to target $SU(2)$ rather than the larger group $U(2)$. The singular case $L=0$ explains why invertibility or a regularized variant is essential.

A third approach is to use a parameterization that is unitary from the outset, such as an exponential of a Hermitian matrix, and let the logarithmic construction influence the Hamiltonian rather than appear as an unconstrained multiplicative factor.

## Seeing the geometry on a qubit

A single-qubit unitary can be pictured as a carefully constrained motion. Up to an overall phase, it corresponds to a rotation of the Bloch sphere, the familiar globe on which pure qubit states live. The group $SU(2)$ is not a flat vector space inside the set of all complex matrices; it is a curved three-dimensional manifold. Adding or multiplying arbitrary matrix-valued features generally leaves that manifold.

The raw logarithmic factor exposes this geometry through singular values. If $L=\Log(I+iH_2)$ stretches one direction by a factor $s$, then $\exp(iH_1)L$ still stretches some direction by the same factor $s$. The exponential may rotate which direction is stretched, but it cannot turn $s$ into $1$. A true unitary has every singular value equal to $1$. At $H_2=0$, every singular value of $L$ is $0$, so the entire state space collapses to the origin rather than rotating.

This gives a practical visualization. Imagine a sphere of vectors. Applying $L$ may turn it into an ellipsoid, flatten it, or expand it. Applying $\exp(iH_1)$ afterward merely rotates that resulting shape. If the intermediate shape was not already a sphere of the same radius, the final one will not be either. In symbols,

$$
N(H_1,H_2)^*N(H_1,H_2)=L(H_2)^*L(H_2).
$$

The equation says that the metric distortion is entirely independent of $H_1$. It also guides optimization: a training penalty based on $\|N^*N-I\|$ cannot be reduced by changing the first Hamiltonian. Only the second Hamiltonian, or a change to the architecture, can reduce it.

## Why this small theorem matters

In hybrid quantum–classical learning, violations of unitarity are not cosmetic. A nonunitary matrix does not describe a deterministic closed-system quantum gate. Implementing it requires dilation, measurement, postselection, noise modeling, or some other enlarged physical mechanism. Those can be useful, but they are different computational objects and should be named honestly.

The obstruction also illustrates a broad rule in mathematical design: check identity and zero cases before attempting a global universality theorem. Sophisticated coverage arguments can be irrelevant if the codomain claim already fails at a boundary point. Here one substitution, $H_2=0$, separates two questions that had been entangled:

1. Does the raw formula always produce a unitary matrix? No.
2. Can carefully chosen parameters nevertheless represent every single-qubit unitary? That remains a meaningful restricted-coverage question.

The factor theorem sharpens the research program. Any successful parameter pair must make the logarithmic factor unitary. That condition can be tested spectrally, optimized numerically, and perhaps solved analytically. A particularly clean route is to take $H_2=tI$. Then

$$
\Log(I+iH_2)=\Log(1+it)I.
$$

If $|\Log(1+it)|=1$, the logarithmic factor is a scalar phase. The remaining question becomes whether the Hermitian exponential can supply every required unitary after accounting for that phase, and how the determinant-one condition constrains the trace of $H_1$.

The failed unrestricted activation is therefore not the end of the idea. It is a map of where the idea must change. The exponential factor already lives on the unitary group. The logarithmic factor does not, and no unitary prefactor can pull it there. Restrict it, normalize it, or redesign its role—and a mathematically coherent quantum activation may yet emerge.

That pattern reaches beyond this particular proposal. Whenever a model is meant to live on a curved space—rotations, probability simplices, positive matrices, or quantum channels—its formulas should respect the defining equations of that space. Counting parameters and composing fashionable functions are not substitutes for checking invariants. Often the fastest route to a better architecture is not a larger experiment but a smaller calculation: evaluate the identity, evaluate zero, cancel the factors that can be cancelled, and ask which component truly controls the geometry. Here those steps transform a vague universality hope into a precise spectral research program.
