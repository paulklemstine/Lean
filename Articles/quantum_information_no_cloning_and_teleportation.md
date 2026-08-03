# The Quantum Rules That Forbid Copying, Enable Teleportation, and Ration Entanglement

Quantum information is governed by a striking combination of prohibition and possibility. An unknown quantum state cannot be copied perfectly. Yet that same state can be transferred to a distant system without sending the physical carrier that originally held it. Meanwhile, the entanglement that powers this transfer cannot be shared arbitrarily: in a three-qubit system, strong correlations with one partner constrain correlations with another.

These are not three unrelated curiosities. They are different faces of one central fact: quantum amplitudes evolve linearly, while many tempting operations on information are nonlinear. Linearity forbids universal copying, but it also makes interference predictable enough to support teleportation. The algebra of amplitudes then imposes exact accounting laws on entanglement.

This article develops all three ideas from first principles. We prove a general no-cloning theorem for observables, calculate every branch of the teleportation protocol, and derive an exact monogamy identity for the important family of three-qubit W states.

## Qubits and amplitudes

A qubit has two computational basis states, written $|0\rangle$ and $|1\rangle$. A pure qubit state is an amplitude pair

$$
|\psi\rangle=\alpha|0\rangle+\beta|1\rangle,
$$

where $\alpha,\beta\in\mathbb C$. For a normalized state, $|\alpha|^2+|\beta|^2=1$. The squared moduli are measurement probabilities. Global scaling will sometimes be retained in intermediate calculations because a post-measurement branch is naturally unnormalized.

Two standard gates will be central. The Pauli $X$ gate exchanges the amplitudes of $|0\rangle$ and $|1\rangle$. The Pauli $Z$ gate leaves the $|0\rangle$ amplitude fixed and negates the $|1\rangle$ amplitude. The Hadamard gate acts by

$$
H|0\rangle=\frac{|0\rangle+|1\rangle}{\sqrt2},\qquad
H|1\rangle=\frac{|0\rangle-|1\rangle}{\sqrt2}.
$$

A controlled-NOT, or CNOT, flips its target bit exactly when its control bit is $1$.

## Why a universal copying machine cannot exist

The familiar no-cloning theorem is often presented through inner products or unitary evolution. A shorter and more general obstruction is already visible at the level of linearity.

Let $A$ be any nontrivial complex $C^*$-algebra with identity $1$. Think of $A$ as an algebra of observables. A universal algebraic cloner would be a complex-linear map

$$
C:A\longrightarrow A\otimes A
$$

satisfying $C(a)=a\otimes a$ for every $a\in A$.

**Universal No-Cloning Theorem.** No such complex-linear map exists on any nontrivial complex $C^*$-algebra.

The reason is a mismatch of scaling laws. Linearity demands

$$
C(2\cdot1)=2C(1)=2(1\otimes1).
$$

Universal cloning demands instead

$$
C(2\cdot1)=(2\cdot1)\otimes(2\cdot1)=4(1\otimes1).
$$

To make the contradiction completely internal to the algebra, multiply the two tensor factors using the linear map $m:A\otimes A\to A$ determined by $m(a\otimes b)=ab$. The two equations would imply $2\cdot1=4\cdot1$, impossible in a nontrivial complex algebra. Thus the desired copying rule is quadratic in its input, whereas physical evolution must at least be linear.

This result immediately applies to a qubit's diagonal observable algebra, the complex-valued functions on a two-element set. Requiring the cloner to be unitary or completely positive cannot help: those conditions are stronger than the linearity that has already produced the contradiction.

The theorem does not say that known classical data cannot be copied, or that a chosen family of mutually distinguishable states cannot be duplicated. It rules out one device that correctly clones every possible input. Quantum cryptography turns precisely this limitation into a security resource: an eavesdropper cannot quietly make a perfect spare copy of an arbitrary transmitted state.

## Teleportation: transfer without duplication

No-cloning does not prevent moving a state. Quantum teleportation transfers an unknown qubit from Alice to Bob by consuming shared entanglement and sending two classical bits. The original state is destroyed in Alice's measurement, so no second copy survives.

Alice begins with

$$
|\psi\rangle=\alpha|0\rangle+\beta|1\rangle.
$$

Alice and Bob also share a Bell pair

$$
|\Phi^+\rangle=\frac{|00\rangle+|11\rangle}{\sqrt2}.
$$

Alice holds the input qubit and the first Bell qubit; Bob holds the second Bell qubit. The combined initial state is $|\psi\rangle\otimes|\Phi^+\rangle$. Alice applies a CNOT from the input wire to her Bell wire, then applies a Hadamard to the input wire. She measures her two wires, obtaining bits $a,b\in\{0,1\}$, and sends them to Bob. Bob applies $X$ if $b=1$, followed by $Z$ if $a=1$.

The protocol's entire logic is contained in the following four-branch table. Before Bob's correction, his unnormalized state is

| Alice's outcome $(a,b)$ | Bob's branch before correction | Bob's correction |
|---|---|---|
| $(0,0)$ | $\frac12(\alpha|0\rangle+\beta|1\rangle)$ | $I$ |
| $(0,1)$ | $\frac12(\beta|0\rangle+\alpha|1\rangle)$ | $X$ |
| $(1,0)$ | $\frac12(\alpha|0\rangle-\beta|1\rangle)$ | $Z$ |
| $(1,1)$ | $\frac12(-\beta|0\rangle+\alpha|1\rangle)$ | $ZX$ |

In every row the correction produces

$$
\frac12(\alpha|0\rangle+\beta|1\rangle)=\frac12|\psi\rangle.
$$

This gives the exact result.

**Teleportation Correctness Theorem.** For every complex amplitude pair $|\psi\rangle$, every measurement outcome $(a,b)$, and each output basis value $c\in\{0,1\}$, Bob's corrected branch has amplitude $\frac12\psi(c)$. Consequently, after normalizing the selected branch, Bob's state is exactly $|\psi\rangle$.

The common factor $1/2$ is a branch amplitude, not an error. If the input is normalized, each branch has squared norm $1/4$, so the four outcomes are equally likely and their probabilities sum to $1$. Dividing the selected branch by its norm restores the original amplitudes.

The proof is a direct amplitude calculation. The Bell pair contributes $1/\sqrt2$ whenever its two bits agree. The Hadamard contributes another $1/\sqrt2$ and introduces the outcome-dependent sign. Since $(1/\sqrt2)^2=1/2$, the table follows. The conditional Pauli operations remove the swap and sign in each branch.

Teleportation therefore transmits quantum information without transmitting the input particle. But it is not faster-than-light communication. Bob cannot know which correction to perform until Alice's two classical bits arrive. Nor does the protocol violate no-cloning: Alice's measurement irreversibly consumes the input, while the Bell pair is consumed as a resource.

## Entanglement has a budget

For three qubits, entanglement cannot generally be distributed like ordinary shared randomness. A useful test family is the W sector,

$$
|W(a,b,c)\rangle=a|100\rangle+b|010\rangle+c|001\rangle,
$$

with complex amplitudes $a,b,c$. A normalized W state satisfies

$$
|a|^2+|b|^2+|c|^2=1.
$$

Define the squared modulus of $z\in\mathbb C$ by $q(z)=|z|^2$. Three quantities measure how qubit A shares entanglement. The one-tangle between A and the pair BC is

$$
\tau_{A|BC}=4|a|^2\bigl(|b|^2+|c|^2\bigr).
$$

The squared pairwise concurrences are

$$
C_{AB}^2=4|a|^2|b|^2,
\qquad
C_{AC}^2=4|a|^2|c|^2.
$$

**W-State Monogamy Equality.** For every choice of complex amplitudes $a,b,c$,

$$
C_{AB}^2+C_{AC}^2=\tau_{A|BC}.
$$

The proof is distributivity:

$$
4|a|^2|b|^2+4|a|^2|c|^2
=4|a|^2\bigl(|b|^2+|c|^2\bigr).
$$

Thus the usual monogamy inequality $C_{AB}^2+C_{AC}^2\leq\tau_{A|BC}$ is saturated throughout the W sector. All of A's one-tangle is accounted for by pairwise entanglement with B and C; there is no residual three-party tangle in this measure.

**Normalized One-Tangle Bound.** If $|a|^2+|b|^2+|c|^2=1$, then

$$
\tau_{A|BC}\leq1.
$$

Indeed, set $x=|a|^2$. Normalization gives $|b|^2+|c|^2=1-x$, so

$$
\tau_{A|BC}=4x(1-x)=1-(2x-1)^2\leq1.
$$

Equality occurs when $|a|^2=1/2$, with the remaining probability $1/2$ shared arbitrarily between the other two one-excitation basis states.

## What the three results do—and do not—say

The no-cloning theorem is strongest when read precisely. It excludes a single linear machine that copies every possible input. It does not make copying impossible whenever the input comes from a known classical list. Two orthogonal states can be distinguished and re-prepared, and a known state can be prepared repeatedly. The forbidden ingredient is universality over unknown quantum data. This distinction is exactly why ordinary documents can be copied freely while a cryptographic qubit cannot be intercepted, duplicated perfectly, and forwarded without risk.

Teleportation has an equally important boundary. The word can suggest that matter disappears in one place and instantly appears in another, but the protocol claims something narrower and more useful: the amplitude state is reconstructed on Bob's already-existing qubit. Alice must perform a measurement, the shared Bell pair is spent, and two ordinary bits must travel to Bob. Before those bits arrive, he does not know which Pauli correction is needed. Relativity remains intact because the classical message cannot outrun light.

The W-state identity is also a result about a clearly specified family and clearly specified measures. It says that, for one-excitation states, the entire one-tangle of the first qubit is visible as pairwise squared concurrence. Other three-qubit states can carry a residual genuinely tripartite contribution. Thus saturation is not the absence of quantum correlation; it is a signature of how W-type correlation is organized.

These boundaries make the results more, not less, informative. Each theorem identifies an exact resource tradeoff: universality conflicts with linearity, state transfer consumes entanglement and classical communication, and pairwise W-state correlations consume a fixed tangle budget.

## A concrete journey through the protocols

Imagine that Alice's input lies halfway between the two computational basis states, with amplitudes of equal magnitude. In teleportation, none of Alice's four outcomes is preferred. Each appears with probability $1/4$. If she reads $(0,1)$, Bob's amplitudes are exchanged; if she reads $(1,0)$, one relative sign is reversed. The two-bit message is therefore not a compressed description of the unknown amplitudes. It is an instruction describing which distortion occurred. Bob can undo that distortion without ever learning the state itself.

Now consider the symmetric W state, in which all three one-excitation amplitudes have magnitude $1/\sqrt3$. The pairwise squared concurrences are both $4/9$, while the one-tangle is $8/9$. The arithmetic balance is exact: $4/9+4/9=8/9$. If the weight shifts toward the first and second qubits while the third amplitude shrinks, the A-B share rises and the A-C share falls. At the extreme where $|a|^2=|b|^2=1/2$ and $c=0$, the one-tangle reaches its maximum value $1$ and is entirely concentrated in the A-B pair.

## One linear theory, three quantum lessons

The arc is now complete. A cloning rule would scale quadratically and therefore cannot be a universal linear operation. Teleportation succeeds because linear gates reorganize amplitudes so that two classical bits identify one of four simple Pauli distortions. Entanglement monogamy emerges as an exact algebraic budget: in a W state, the total A-versus-BC tangle splits into its A-B and A-C contributions.

These facts shape real quantum technologies. No-cloning protects quantum key distribution and complicates error correction. Teleportation is a primitive for quantum networks, distributed computation, and fault-tolerant circuits. Monogamy constrains which links in a quantum network can be simultaneously strong and helps diagnose genuinely multipartite correlations.

Quantum information is not ethereal information unconstrained by physics. It is information with an exact geometry: impossible to duplicate universally, possible to relocate through entanglement and classical communication, and subject to strict sharing laws. The prohibitions and the protocols belong to the same mathematical world—and understanding one makes the others less mysterious.
