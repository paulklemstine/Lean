# Future Directions: Formal Hodge Theory Beyond Rank One

## Hypothesis 1: Primitive Embedding via Discriminant Forms

**Conjecture.** Let $(L, Q)$ be a nondegenerate even lattice of signature $(1, r-1)$ with $r \leq 20$. Then $L$ admits a primitive embedding into the K3 lattice $\Lambda_{K3} = U^3 \oplus E_8(-1)^2$ if and only if the discriminant form $q_L: A_L \to \mathbb{Q}/2\mathbb{Z}$ satisfies the Nikulin embedding conditions:
1. $\text{rank}(\Lambda_{K3}) - \text{rank}(L) \geq \ell(A_L)$ (length condition),
2. The signature modulo 8 is compatible.

**Test.** Formalize the discriminant form as a finite bilinear form on $L^\vee / L$ and state the embedding criterion as a decidable predicate. Implement a verified algorithm that checks the Nikulin conditions for explicit lattices. For refutation, construct an explicit lattice satisfying the numerical conditions but failing to embed (which would reveal a missing condition in the Nikulin theory beyond what we've formalized).

**Impact.** A verified primitive embedding algorithm would give the first machine-certified lattice-theoretic classification results for K3 surfaces, connecting formal Hodge theory to formal arithmetic geometry.

---

## Hypothesis 2: Semisimplicity of Polarizable Rational Hodge Structures

**Conjecture.** Every polarized rational Hodge structure $(V, Q, H^{p,q})$ is semisimple: for any Hodge substructure $W \subseteq V$, the Q-orthogonal complement $W^\perp$ is also a Hodge substructure, giving a Hodge-theoretic complement $V = W \oplus W^\perp$.

**Test.** The proof requires showing that the polarization form restricts nondegenerately to every Hodge substructure. Formalize the positive-definiteness of the Hodge-Riemann bilinear relations $(−1)^p Q(v, \bar{v}) > 0$ for $v \in H^{p,q}$, and derive nondegeneracy of $Q|_W$ from this. The key bridge lemma is: the Hodge-Riemann relations imply the Hodge index theorem, which implies nondegeneracy.

**Refutation.** If the formalization fails, it will identify the exact point where the positivity argument breaks down — likely a missing compatibility between the Weil operator $C$ and the rational structure. This would clarify the boundary between "polarizable implies semisimple" and the more general (and false in non-polarizable cases) claim.

**Impact.** Semisimplicity is the foundation of the Tannakian formalism for Hodge structures. Once formalized, it gives automatic decompositions of all Hodge structures into simple factors, enabling systematic endomorphism algebra computation.

---

## Hypothesis 3: Mumford–Tate Group via Tensor Invariants

**Conjecture.** For a weight-1 rational Hodge structure $W$ of dimension $2g$, the Mumford–Tate group $\text{MT}(W) \subseteq \text{GL}(W)$ can be recovered as the stabilizer of all tensor Hodge classes:
$$\text{MT}(W) = \bigcap_{p,q \geq 0} \text{Stab}(\text{Hdg}(W^{\otimes p} \otimes (W^\vee)^{\otimes q}))$$

For $g \leq 2$ and generic $W$, $\text{MT}(W) = \text{GSp}_{2g}$.

**Test.** Formalize the tensor construction $W^{\otimes p} \otimes (W^\vee)^{\otimes q}$ with its induced Hodge structure. Compute the Hodge classes explicitly for $p + q \leq 4$ in the case $g = 1$ (elliptic curves). Verify that the stabilizer of these classes is $\text{GL}_2$ for non-CM curves and a proper subgroup for CM curves.

**Refutation.** Failure would manifest as either (a) the tensor Hodge class computation not terminating in finitely many steps (suggesting the invariant ring is not finitely generated in our framework), or (b) the stabilizer being strictly larger than the expected Mumford–Tate group (revealing missing tensor powers in the computation).

**Impact.** This would give the first formal connection between Hodge classes and algebraic groups, opening the door to motivic Galois group computations and formal proofs of the Hodge conjecture in special cases.

---

## Hypothesis 4: Kuga–Satake Construction for Weight-2 Structures

**Conjecture.** For a polarized weight-2 rational Hodge structure $(V, Q)$ of K3 type (i.e., $\dim H^{2,0} = 1$), the even Clifford algebra $\text{Cl}^+(V, Q)$ carries a canonically induced weight-1 Hodge structure. The resulting abelian variety (the Kuga–Satake variety) has dimension $2^{(\dim V - 2)/2}$.

**Test.** Formalize the Clifford algebra $\text{Cl}(V, Q)$ using Mathlib's `CliffordAlgebra` API. Define the even subalgebra and construct the Hodge decomposition on it by extending the weight-2 decomposition multiplicatively. Verify that the construction produces a valid weight-1 Hodge structure (i.e., $H^{1,0} \oplus H^{0,1} = \text{Cl}^+_\mathbb{C}$ with $H^{1,0} \cap H^{0,1} = 0$).

**Refutation.** The construction could fail if the multiplicative extension of the Hodge decomposition does not produce complementary subspaces in the even Clifford algebra. This would happen precisely when the signature of $(V, Q)$ is not of K3 type, identifying the exact signature constraint needed.

**Impact.** The Kuga–Satake construction is one of the deepest connections between K3 surfaces and abelian varieties. A formal version would provide machine-certified proofs of K3 rationality results and Hodge-theoretic consequences of the Kuga–Satake correspondence.

---

## Hypothesis 5: Derived Torelli via Lattice Isometries

**Conjecture.** Let $(V_1, Q_1, A_1, T_1)$ and $(V_2, Q_2, A_2, T_2)$ be two polarized weight-2 rational Hodge structures with their algebraic/transcendental decompositions. An isometry $\phi: (V_1, Q_1) \to (V_2, Q_2)$ that preserves the decomposition ($\phi(A_1) = A_2$ and $\phi(T_1) = T_2$) and induces Hodge isometries on both summands determines a unique Hodge isometry of the full structures.

**Test.** Formalize the gluing condition: given Hodge isometries $\phi_A: A_1 \to A_2$ and $\phi_T: T_1 \to T_2$ that are compatible with the ambient bilinear forms (i.e., $Q_2(\phi_A(a), \phi_T(t)) = Q_1(a, t) = 0$), prove that $\phi_A \oplus \phi_T$ is a Hodge isometry of $(V_1, Q_1) \to (V_2, Q_2)$.

**Refutation.** The conjecture could fail if there exist "exotic" isometries that permute the algebraic and transcendental summands in a way that is globally consistent but not decomposable. Construct such an example formally: a Hodge isometry that maps some algebraic classes to transcendental ones while preserving the overall Hodge structure.

**Impact.** This would formalize the key structural insight behind the Global Torelli Theorem for K3 surfaces: the full Hodge structure is determined by its behavior on the algebraic and transcendental parts separately. A formal version would provide a certified factorization of the Torelli problem into two independent sub-problems.
