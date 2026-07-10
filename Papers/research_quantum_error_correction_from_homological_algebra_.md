# Quantum Error Correction from Homological Algebra: CSS Codes as Cohomology

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

We develop the exact dictionary between Calderbank–Shor–Steane (CSS) quantum error-correcting codes and the homology of chain complexes. A CSS code is, algebraically, a length-two segment of a chain complex $A \xrightarrow{d_2} B \xrightarrow{d_1} C$ with $d_1 \circ d_2 = 0$; the physical qubits are a basis of the middle space $B$, and the *logical qubits* are precisely the middle homology $H = \ker d_1 / \operatorname{im} d_2$. We prove two structural dimension identities that drive every CSS/HQECC computation: the **dimension formula** $k + \operatorname{rank} d_1 + \operatorname{rank} d_2 = \dim B$ (the CSS count $k = n - \operatorname{rank}(H_X) - \operatorname{rank}(H_Z)$), and the **Euler identity** $\beta_0 + \dim B = \dim(\ker d_1) + \dim C$, which for a graph complex reads $V - E = \beta_0 - \beta_1$. Both are established additively over an arbitrary field, avoiding truncated subtraction and making them field-agnostic. Specializing to the graph (one-dimensional) case yields the homological quantum error-correcting code $\mathrm{HQECC}(G)$, whose logical dimension equals the circuit rank $k = \beta_1(G) = E - V + \beta_0$. Applying this to the $n$-dimensional hypercube graph $Q_n$, we obtain the exact closed form $\beta_1(Q_n) = 2^{n-1}(n-2) + 1$, and we prove that the folklore "one logical qubit" law holds *only* at $n = 2$ (the $4$-cycle): for all $n \ge 3$ the code encodes at least five logical qubits, with $Q_4, Q_6, Q_8$ encoding $17, 129, 769$ qubits respectively. This corrects a common conflation of the hypercube *graph* with the hypercube *cell complex*.

## 1. Introduction

Quantum error correction is the foundation on which scalable quantum computation rests. Among the most influential families of quantum codes are the CSS codes of Calderbank, Shor, and Steane, built from a pair of classical binary linear codes whose parity-check structures are mutually compatible. A recurring observation — sometimes stated as a slogan, "quantum error correction is cohomology" — is that the CSS construction has the exact shape of a homological computation. The purpose of this paper is to make that slogan precise, to prove the structural identities it entails, and to test it on a concrete and instructive family: the hypercube graphs.

The central conceptual claim is simple. A CSS code is specified by two parity-check matrices $H_X$ and $H_Z$ over $\mathbb{F}_2$ satisfying $H_X H_Z^{\mathsf{T}} = 0$. Reading $H_Z^{\mathsf{T}}$ as a map $d_2$ into the space of physical qubits and $H_X$ as a map $d_1$ out of it, the compatibility condition becomes $d_1 \circ d_2 = 0$: a two-term chain complex. The number of encoded logical qubits, classically computed as $k = n - \operatorname{rank} H_X - \operatorname{rank} H_Z$, is then nothing other than the dimension of the middle homology group. We prove this equivalence in full generality and extract from it two accounting identities that underlie all downstream computations.

We then instantiate the theory for graphs, where the construction becomes the homological quantum error-correcting code $\mathrm{HQECC}(G)$. Because a graph is a one-dimensional complex with no $2$-cells, the boundary map $d_2$ vanishes and the logical dimension equals the first Betti number (circuit rank) of the graph. The hypercube family provides a sharp illustration — and a corrective one, since we show that the widely repeated claim that the hypercube code encodes a single qubit is false for every $n \ge 3$.

## 2. Definitions

Throughout, $K$ is a field. All vector spaces are $K$-vector spaces; for a linear map $f$ we write $\ker f$, $\operatorname{im} f$, $\operatorname{rank} f = \dim \operatorname{im} f$. We write $\dim$ for $\dim_K$ and assume the relevant spaces are finite-dimensional where dimensions are taken.

**Definition 2.1 (CSS chain complex).** A *CSS complex* is a triple of $K$-vector spaces together with two linear maps
$$A \xrightarrow{\ d_2\ } B \xrightarrow{\ d_1\ } C$$
satisfying the *chain condition* $d_1 \circ d_2 = 0$. The middle space $B$ is the *physical space*; a basis of $B$ indexes the physical qubits. The map $d_1$ plays the role of the $X$-type parity check $H_X$, and $d_2$ the transpose of the $Z$-type parity check $H_Z^{\mathsf{T}}$.

**Definition 2.2 (Cycles and boundaries).** The *cycle space* is $Z = \ker d_1 \subseteq B$, and the *boundary space* is $B_{\partial} = \operatorname{im} d_2 \subseteq B$.

**Lemma 2.3 (Boundaries are cycles).** $B_{\partial} \subseteq Z$.

*Proof.* If $b = d_2(a) \in \operatorname{im} d_2$, then $d_1(b) = (d_1 \circ d_2)(a) = 0$, so $b \in \ker d_1 = Z$. $\qquad\blacksquare$

**Definition 2.4 (Logical space / middle homology).** The *logical space* is the quotient
$$H = Z / B_{\partial} = \frac{\ker d_1}{\operatorname{im} d_2}.$$
The *number of logical qubits* is $k = \dim H$. (The quotient is well-defined precisely because of Lemma 2.3.)

**Definition 2.5 (Zeroth homology).** The *zeroth homology* is $H^0 = C / \operatorname{im} d_1$, and $\beta_0 = \dim H^0$. For a graph complex $B = \mathbb{F}_2^E$, $C = \mathbb{F}_2^V$ with $d_1$ the incidence map, $\beta_0$ is the number of connected components.

**Definition 2.6 (Graph complex / HQECC).** Given a finite graph $G = (V, E)$, its *graph complex* over $K$ takes $B = K^E$, $C = K^V$, $A = 0$ (so $d_2 = 0$), and $d_1 = \partial$ the boundary/incidence map sending each edge to the (signed, or over $\mathbb{F}_2$ unsigned) sum of its endpoints. The resulting CSS code is the *homological quantum error-correcting code* $\mathrm{HQECC}(G)$.

## 3. Main results

### 3.1 The structural dimension identities

Everything rests on two applications of rank–nullity, packaged additively so that no natural-number subtraction ever appears.

**Proposition 3.1 (Splitting off the boundaries).** For a CSS complex with $\dim B < \infty$,
$$k + \operatorname{rank} d_2 = \dim Z.$$

*Proof.* By the first isomorphism theorem for quotients, $\dim(Z/B_{\partial}') + \dim B_{\partial}' = \dim Z$ for any subspace $B_{\partial}' \subseteq Z$. Here $H = Z / B_{\partial}$, where $B_{\partial}$ is regarded inside $Z$ via Lemma 2.3; the inclusion induces an isomorphism between $\operatorname{im} d_2$ as a subspace of $B$ and as a subspace of $Z$, so $\dim B_{\partial} = \operatorname{rank} d_2$. Hence $k + \operatorname{rank} d_2 = \dim Z$. $\qquad\blacksquare$

**Proposition 3.2 (Rank–nullity on $d_1$).** For a CSS complex with $\dim B < \infty$,
$$\dim Z + \operatorname{rank} d_1 = \dim B.$$

*Proof.* This is the rank–nullity theorem applied to $d_1 : B \to C$, since $Z = \ker d_1$. $\qquad\blacksquare$

**Theorem 3.3 (CSS dimension formula).** For a CSS complex with $\dim B < \infty$,
$$k + \operatorname{rank} d_1 + \operatorname{rank} d_2 = \dim B.$$
Equivalently, $k = \dim B - \operatorname{rank} d_1 - \operatorname{rank} d_2$, the CSS count $k = n - \operatorname{rank}(H_X) - \operatorname{rank}(H_Z)$.

*Proof.* Add the identities of Propositions 3.1 and 3.2 and cancel $\dim Z$:
$$k + \operatorname{rank} d_2 + \operatorname{rank} d_1 = \dim Z + \operatorname{rank} d_1 = \dim B. \qquad\blacksquare$$

**Theorem 3.4 (Euler identity).** For a CSS complex with $\dim B, \dim C < \infty$,
$$\beta_0 + \dim B = \dim Z + \dim C.$$
For a graph complex ($\dim B = E$, $\dim C = V$) this reads $\beta_0 + E = \beta_1 + V$, i.e.
$$V - E = \beta_0 - \beta_1.$$

*Proof.* Rank–nullity for the quotient $H^0 = C / \operatorname{im} d_1$ gives $\beta_0 + \operatorname{rank} d_1 = \dim C$. Substituting $\operatorname{rank} d_1 = \dim B - \dim Z$ from Proposition 3.2 yields $\beta_0 + \dim B - \dim Z = \dim C$, which rearranges to the claim. $\qquad\blacksquare$

### 3.2 The graph specialization

**Theorem 3.5 (Logical dimension of a graph code).** For the graph complex of $G$ (so $d_2 = 0$),
$$k = \dim Z, \qquad\text{and}\qquad k + V = E + \beta_0, \quad\text{i.e.}\quad k = E - V + \beta_0 = \beta_1(G).$$
In particular, if $G$ is connected then $\beta_0 = 1$ and $k = E - V + 1$, the circuit rank.

*Proof.* When $d_2 = 0$ we have $\operatorname{im} d_2 = 0$, so $H = Z / 0 \cong Z$ and $k = \dim Z$ (Proposition 3.1 with $\operatorname{rank} d_2 = 0$). The additive count $k + V = E + \beta_0$ is Theorem 3.4 with $\dim Z = k$, $\dim B = E$, $\dim C = V$. Rearranging gives $k = E - V + \beta_0$; connectivity gives $\beta_0 = 1$. $\qquad\blacksquare$

### 3.3 The hypercube homological code

The $n$-dimensional hypercube graph $Q_n$ has vertex set $\{0,1\}^n$ with edges between strings differing in one coordinate. It is connected and satisfies
$$V(Q_n) = 2^n, \qquad E(Q_n) = n \cdot 2^{n-1}.$$

**Theorem 3.6 (Closed form for the hypercube code).** For $n \ge 1$, the homological code $\mathrm{HQECC}(Q_n)$ encodes
$$k = \beta_1(Q_n) = E - V + 1 = n \cdot 2^{n-1} - 2^n + 1 = 2^{n-1}(n - 2) + 1$$
logical qubits.

*Proof.* By Theorem 3.5, $k = \beta_1(Q_n) = E - V + 1$ because $Q_n$ is connected. Substituting $E = n \cdot 2^{n-1}$ and $V = 2^n = 2 \cdot 2^{n-1}$ gives $k = n\cdot 2^{n-1} - 2\cdot 2^{n-1} + 1 = 2^{n-1}(n-2) + 1$. $\qquad\blacksquare$

**Theorem 3.7 (The "one qubit" law holds only at $n = 2$).** For $n \ge 1$, $\beta_1(Q_n) = 1$ if and only if $n = 2$.

*Proof.* By Theorem 3.6, $\beta_1(Q_n) = 1$ iff $2^{n-1}(n-2) = 0$. Since $2^{n-1} > 0$, this holds iff $n - 2 = 0$, i.e. $n = 2$. $\qquad\blacksquare$

**Theorem 3.8 (Failure of the conjecture for $n \ge 3$).** For $n \ge 3$, $\beta_1(Q_n) \ge 5$; in particular the hypercube code encodes strictly more than one logical qubit.

*Proof.* For $n \ge 3$ we have $2^{n-1} \ge 2^2 = 4$ and $n - 2 \ge 1$, so $\beta_1(Q_n) = 2^{n-1}(n-2) + 1 \ge 4 \cdot 1 + 1 = 5$. $\qquad\blacksquare$

**Corollary 3.9 (Test cases).** The mission's three test instances evaluate to
$$\beta_1(Q_4) = 17, \qquad \beta_1(Q_6) = 129, \qquad \beta_1(Q_8) = 769.$$

*Proof.* Direct substitution: $2^{3}(2) + 1 = 17$; $2^{5}(4) + 1 = 129$; $2^{7}(6) + 1 = 769$. $\qquad\blacksquare$

**Remark 3.10 (Graph versus cell complex).** The folklore "one qubit" claim conflates two distinct spaces. The hypercube *graph* is a one-dimensional complex whose first homology is the full cycle space of dimension $2^{n-1}(n-2)+1$. The hypercube *cell complex* (the filled solid, a torus-like object) is a different space with additional $2$-cells; its middle homology can be small. The homological code is defined from a specified complex, and the encoded dimension is a topological invariant of *that* complex. The single-qubit law is correct only for $Q_2$, the $4$-cycle.

## 4. Algorithms

We summarize the computational content as three algorithms.

**Algorithm A (Logical dimension from rank data).** Given the two parity-check maps $d_1, d_2$ of a CSS complex over a field, compute $r_1 = \operatorname{rank} d_1$ and $r_2 = \operatorname{rank} d_2$ by Gaussian elimination and return $k = \dim B - r_1 - r_2$ (Theorem 3.3). Complexity $O(n^3)$ in the physical dimension $n = \dim B$.

**Algorithm B (Graph code parameters).** Given a graph $G$, compute $V$, $E$, and the number of connected components $\beta_0$ (by union–find in near-linear time), then return $k = E - V + \beta_0$ (Theorem 3.5). Complexity $O((V + E)\,\alpha(V))$.

**Algorithm C (Hypercube closed form).** Given $n$, return $2^{n-1}(n-2) + 1$ directly (Theorem 3.6). Complexity $O(1)$ arithmetic operations (or $O(n)$ bit operations for the power).

## 5. Applications

- **Code design as space design.** Every simplicial (or cell) complex yields a CSS code whose logical dimension, rate, and distance are topological invariants: the Betti number, the Euler-characteristic-controlled rate, and the systole respectively. Designing a good quantum memory becomes the geometric problem of designing a good shape.
- **Surface and toric codes.** The most successful practical quantum codes are graph/surface homological codes; the identities here compute their logical dimension uniformly.
- **Rate estimation.** Theorem 3.4 turns the code rate $k/n$ into a purely combinatorial ratio $1 - (V - \beta_0)/E$ for graph codes, giving instant rate estimates from vertex/edge counts.
- **Sanity checking published parameters.** The hypercube analysis shows how the framework detects and corrects errors in claimed code parameters.

## 6. Discussion

The value of the homological viewpoint is twofold. First, it *unifies*: the classical CSS count, the Euler characteristic, and the circuit rank all become instances of a single additive accounting over dimensions of quotient spaces. Second, it *protects against error* in the human sense: by insisting on an exact chain complex and an exact quotient, it forces one to specify which space is meant, which is precisely where the hypercube folklore went astray.

A methodological point deserves emphasis. Stating rank–nullity additively — "$\dim(\ker) + \operatorname{rank} = \dim$" rather than "$\dim(\ker) = \dim - \operatorname{rank}$" — makes every identity valid without side conditions on which quantity is larger, and makes the results field-agnostic. Over $\mathbb{F}_2$ this is the relevant regime for quantum codes, but nothing in the arguments uses the characteristic, so the same theorems describe qudit CSS codes over any prime field.

## 7. Future work

The dictionary "logical qubits = middle homology" invites several sharp questions.

1. **Distance of the hypercube code.** We conjecture that $\mathrm{HQECC}(Q_n)$ has minimum distance equal to the girth of $Q_n$, namely $4$ for all $n \ge 2$, so that the code does *not* achieve the quantum Singleton bound $d = 2^{n/2}$ for $n \ge 5$. In a one-dimensional complex the shortest nontrivial cycle is a shortest graph cycle; every hypercube contains a $4$-cycle and no triangle, so distance is a girth invariant decoupled from the exponentially large encoded dimension.

2. **Euler characteristic as a rate obstruction.** For any connected graph complex, the rate is $k/n = 1 - (V-1)/E$. Extremizing this over graphs with a fixed number of edges is a discrete isoperimetric problem: the rate is maximized by bouquets (one vertex, many loops) and minimized by trees (rate $0$).

3. **Realizability of all dimension pairs.** For every field $K$ and every pair $k \le n$, there is a length-two chain complex over $K$ with $\dim B = n$ and $\dim H = k$. The exact dimension formula reduces this to prescribing two ranks summing to $n - k$.

4. **Cohomological duality of the two check families.** The $X$-logical space $\ker d_1 / \operatorname{im} d_2$ and the $Z$-logical space $\ker d_2^{\mathsf{T}} / \operatorname{im} d_1^{\mathsf{T}}$ have equal dimension, a self-dual topological invariant of the complex.

## 8. Conclusion

Quantum error correction, in its CSS incarnation, is homology made concrete: physical qubits are the middle of a chain complex, logical qubits are its middle homology, and the code's parameters are topological invariants. Two additive identities — the CSS dimension formula and the Euler identity — furnish a complete and robust accounting of the logical dimension, and their specialization to graphs identifies the logical count with the circuit rank. The hypercube case study demonstrates both the power and the discipline of the viewpoint: computed exactly, $\mathrm{HQECC}(Q_n)$ encodes $2^{n-1}(n-2)+1$ logical qubits, refuting the single-qubit folklore for all $n \ge 3$ while confirming it uniquely at $n = 2$.
