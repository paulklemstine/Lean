# Formalized Class Group Actions and Isogeny-Based Cryptography

## Abstract

We present a formal verification of the algebraic foundations of isogeny-based cryptography, specifically the class group action framework underlying CSIDH and the CSI-FiSh signature scheme. Working in the Lean 4 proof assistant with the Mathlib library, we formalize:

1. Abstract group actions on finite sets, with proofs of injectivity, surjectivity, and inverse cancellation.
2. Free and transitive actions (torsors/principal homogeneous spaces), including the unique connector theorem, connector composition, connector inversion, and the cardinality theorem |G| = |X|.
3. The CSIDH key exchange protocol with a machine-verified proof of correctness (shared secret agreement).
4. The CSI-FiSh identification scheme with verified completeness and special soundness.
5. Collision resistance of the public key map derived from freeness of the group action.
6. Cayley graph properties of isogeny graphs with symmetry of adjacency.

All proofs are complete (no `sorry`), use only standard axioms (propext, Classical.choice, Quot.sound), and compile against Lean 4.28.0 with Mathlib.

## 1. Introduction

Isogeny-based cryptography has emerged as a promising candidate for post-quantum security, with CSIDH (Commutative Supersingular Isogeny Diffie-Hellman) [CLM+18] and CSI-FiSh [BKV19] as flagship protocols. These schemes derive their security from the hardness of the Group Action Inverse Problem (GAIP): given a base point $x_0$ and $y = g \cdot x_0$ under a class group action, recover $g$.

The mathematical foundation is the action of the ideal class group $\text{Cl}(\mathcal{O})$ on the set of $\mathbb{F}_p$-isomorphism classes of supersingular elliptic curves with endomorphism ring $\mathcal{O}$. This action is both free and transitive, making the set of curves a torsor (principal homogeneous space) for the class group.

Formal verification of cryptographic protocols has become increasingly important as subtle mathematical errors can lead to devastating attacks (cf. the SIKE break [CD22]). Our work provides machine-verified proofs of the core algebraic properties that underpin CSIDH and CSI-FiSh security.

### 1.1 Related Work

Prior formal verification work in cryptography includes:
- EasyCrypt for game-based security proofs
- CryptoVerif for computational soundness
- Mathlib's existing formalization of group theory and finite fields

Our contribution is the first formal verification, to our knowledge, of the complete algebraic framework specifically tailored to class group action-based cryptography, including the torsor structure, GAIP one-wayness, and CSI-FiSh soundness.

## 2. Mathematical Framework

### 2.1 Abstract Group Actions

**Definition 2.1** (CryptoGroupAction). A *crypto group action* consists of a finite group $(G, \cdot)$, a finite set $X$, and a map $\star : G \times X \to X$ satisfying:
- Identity: $1 \star x = x$ for all $x \in X$
- Compatibility: $(g \cdot h) \star x = g \star (h \star x)$ for all $g, h \in G, x \in X$

**Theorem 2.2** (Inverse Cancellation). For any group element $g$ and point $x$:
$$g^{-1} \star (g \star x) = x \quad \text{and} \quad g \star (g^{-1} \star x) = x$$

*Proof.* By compatibility, $g^{-1} \star (g \star x) = (g^{-1} \cdot g) \star x = 1 \star x = x$. The second equality is analogous.

**Corollary 2.3**. Each group element $g$ induces a bijection $\sigma_g : X \to X$ defined by $\sigma_g(x) = g \star x$, with inverse $\sigma_{g^{-1}}$.

### 2.2 Free and Transitive Actions (Torsors)

**Definition 2.4** (FreeTrans). A group action is *free and transitive* (a torsor) if:
- *Transitive*: For all $x, y \in X$, there exists $g \in G$ with $g \star x = y$.
- *Free*: If $g \star x = x$ for some $x \in X$, then $g = 1$.

This abstracts the CSIDH setting where the ideal class group acts regularly on supersingular curve isomorphism classes.

**Theorem 2.5** (Unique Connector). In a free transitive action, for any $x, y \in X$, there is a *unique* $g \in G$ with $g \star x = y$.

*Proof.* Existence from transitivity. For uniqueness, if $g \star x = y = h \star x$, then $(g \cdot h^{-1}) \star y = g \star (h^{-1} \star y) = g \star x = y$, so $g \cdot h^{-1} = 1$ by freeness, giving $g = h$.

**Definition 2.6** (Connector). The *connector* $\text{conn}(x, y)$ is the unique $g \in G$ with $g \star x = y$.

**Theorem 2.7** (Connector Algebra).
1. $\text{conn}(x, x) = 1$ (self-connector is identity)
2. $\text{conn}(x, z) = \text{conn}(y, z) \cdot \text{conn}(x, y)$ (composition)
3. $\text{conn}(y, x) = \text{conn}(x, y)^{-1}$ (inversion)

*Proof.* Each follows from uniqueness: verify that both sides map the source to the target, then invoke Theorem 2.5.

**Theorem 2.8** (Cardinality). If the action is free and transitive and $X$ is nonempty, then $|G| = |X|$.

*Proof.* Fix $x_0 \in X$. The map $g \mapsto g \star x_0$ is injective by Theorem 2.5 and surjective by transitivity, hence a bijection.

### 2.3 The Group Action Inverse Problem

**Definition 2.9** (GAIP). Given a base point $x_0 \in X$ and a target $y = g \star x_0$, the *Group Action Inverse Problem* is to recover $g$.

**Theorem 2.10** (Public Key Bijection). The map $\text{pk} : G \to X$ defined by $\text{pk}(g) = g \star x_0$ is a bijection.

**Theorem 2.11** (GAIP = Connector). Computing the GAIP is equivalent to computing $\text{conn}(x_0, y)$:
$$\text{conn}(x_0, g \star x_0) = g$$

## 3. CSIDH Protocol Verification

### 3.1 Protocol Description

**Setup**: Fix a base curve $E_0$ (base point in $X$).

**Key Generation**: Each party selects a random class group element as their secret key and publishes the corresponding public key (the image of $E_0$ under the action).

**Key Exchange**:
- Alice: secret $a \in G$, public $E_A = a \star E_0$
- Bob: secret $b \in G$, public $E_B = b \star E_0$
- Alice computes: $a \star E_B = a \star (b \star E_0)$
- Bob computes: $b \star E_A = b \star (a \star E_0)$

### 3.2 Correctness Theorem

**Theorem 3.1** (Shared Secret Agreement). When $G$ is abelian:
$$a \star (b \star E_0) = b \star (a \star E_0)$$

*Proof.* By compatibility, $a \star (b \star E_0) = (a \cdot b) \star E_0 = (b \cdot a) \star E_0 = b \star (a \star E_0)$, using commutativity of $G$.

This is the central correctness property of CSIDH. It relies essentially on the commutativity of the ideal class group.

## 4. CSI-FiSh Verification

### 4.1 Identification Protocol

The CSI-FiSh identification scheme is a sigma protocol:

1. **Commitment**: Prover picks random $r \in G$, sends $R = r \star x_0$.
2. **Challenge**: Verifier sends bit $b \in \{0, 1\}$.
3. **Response**: Prover sends $z = r$ if $b = 0$, or $z = r \cdot s^{-1}$ if $b = 1$.
4. **Verification**: Check $z \star x_0 = R$ if $b = 0$, or $z \star \text{pk} = R$ if $b = 1$.

### 4.2 Completeness

**Theorem 4.1** (Completeness, Challenge 0). For an honest prover with secret $s$ and randomness $r$:
$$r \star x_0 = r \star x_0 \quad \checkmark$$

**Theorem 4.2** (Completeness, Challenge 1). For an honest prover:
$$(r \cdot s^{-1}) \star (s \star x_0) = r \star x_0$$

*Proof.* $(r \cdot s^{-1}) \star (s \star x_0) = ((r \cdot s^{-1}) \cdot s) \star x_0 = r \star x_0$, using associativity and $s^{-1} \cdot s = 1$.

### 4.3 Special Soundness

**Theorem 4.3** (Special Soundness). Given two accepting transcripts with the same commitment $R$ but different challenges:
- $z_0 \star x_0 = R$ (challenge 0)
- $z_1 \star \text{pk} = R$ (challenge 1)

Then $z_0 \cdot z_1^{-1}$ is the secret mapping $x_0$ to $\text{pk}$:
$$(z_0 \cdot z_1^{-1}) \star x_0 = \text{pk}$$

*Proof.* From $z_1 \star \text{pk} = R$, we get $z_1^{-1} \star R = \text{pk}$. Using commutativity:
$$(z_0 \cdot z_1^{-1}) \star x_0 = (z_1^{-1} \cdot z_0) \star x_0 = z_1^{-1} \star (z_0 \star x_0) = z_1^{-1} \star R = \text{pk}$$

This theorem is crucial: it shows that breaking the identification scheme requires solving the GAIP.

## 5. Collision Resistance

### 5.1 From Collisions to Stabilizers

**Theorem 5.1**. If $g \star x_0 = h \star x_0$ with $g \neq h$, then $s = h^{-1} \cdot g$ satisfies $s \neq 1$ and $s \star x_0 = x_0$.

*Proof.* $s \star x_0 = h^{-1} \star (g \star x_0) = h^{-1} \star (h \star x_0) = x_0$. And $s = 1$ would imply $g = h$, contradicting the hypothesis.

### 5.2 No Collisions in Free Actions

**Theorem 5.2**. In a free action, $g \star x_0 = h \star x_0$ implies $g = h$.

*Proof.* Any collision would yield a non-trivial stabilizer (Theorem 5.1), contradicting freeness.

This establishes that the public key map is collision-resistant as a direct consequence of the torsor structure — no computational hardness assumption needed for information-theoretic collision resistance.

## 6. Cayley Graph Properties

### 6.1 Isogeny Graph as Cayley Graph

We model the isogeny graph as a Cayley graph of the group action:

**Definition 6.1** (IsogenyCayleyGraph). Given a group action and a set of generators $S \subseteq G$ with $1 \notin S$ and $S^{-1} = S$:
- Vertices: elements of $X$
- Edges: $(x, y)$ if $\exists g \in S, g \star x = y$

**Theorem 6.2** (Symmetry). Adjacency is symmetric: if $x$ is adjacent to $y$, then $y$ is adjacent to $x$.

*Proof.* If $g \star x = y$ with $g \in S$, then $g^{-1} \in S$ (by closure under inverses) and $g^{-1} \star y = x$.

**Theorem 6.3** (Degree Bound). Each vertex has at most $|S|$ neighbors.

### 6.2 Walks and Products

**Theorem 6.4**. A walk along group elements $[g_1, g_2, \ldots, g_k]$ from $x$ arrives at $(g_1 \cdot g_2 \cdots g_k) \star x$.

*Proof.* By induction on the length of the walk. Base case: empty walk gives $1 \star x = x$. Inductive step: $g_1 \star ((g_2 \cdots g_k) \star x) = (g_1 \cdot g_2 \cdots g_k) \star x$.

## 7. Discussion

### 7.1 Scope and Limitations

Our formalization captures the abstract algebraic structure of CSIDH and CSI-FiSh but does not include:
- Concrete instantiation with supersingular elliptic curves over $\mathbb{F}_p$
- Efficient algorithms for computing isogenies
- Computational complexity analysis of the GAIP
- Statistical properties (zero-knowledge) of the CSI-FiSh protocol

These would require extensive additional Mathlib infrastructure for elliptic curves, finite fields, and computational complexity theory.

### 7.2 Security Model

Our formalization works in the information-theoretic setting (perfect completeness, statistical soundness) rather than the computational setting. The one-wayness of the CSIDH function is captured abstractly: we show that inverting the public key map is equivalent to computing the connector (Theorem 2.11), which is the GAIP by definition.

### 7.3 Relationship to SIKE

The SIKE (Supersingular Isogeny Key Encapsulation) scheme, broken in 2022, used a fundamentally different mathematical structure: non-commutative endomorphism ring actions with auxiliary torsion point information. The CSIDH framework avoids this vulnerability by:
1. Using an abelian (commutative) group action
2. Not revealing torsion point data
3. Working over $\mathbb{F}_p$ rather than $\mathbb{F}_{p^2}$

## 8. Algorithms

### 8.1 CSIDH Key Generation
```
function CSIDH_KeyGen(E₀, ℓ₁, ..., ℓₙ):
    sample e₁, ..., eₙ from [-B, B]
    E = E₀
    for i = 1 to n:
        for j = 1 to |eᵢ|:
            E = ℓᵢ-isogeny from E (direction = sign(eᵢ))
    return (sk = (e₁,...,eₙ), pk = E)
```

### 8.2 CSI-FiSh Signing (Fiat-Shamir)
```
function CSIFiSh_Sign(sk, msg, E₀, pk):
    for i = 1 to t:
        rᵢ ← random class group element
        Eᵢ = rᵢ · E₀
    c = H(E₁, ..., Eₜ, msg)  // hash to {0,1}ᵗ
    for i = 1 to t:
        if cᵢ = 0: zᵢ = rᵢ
        else: zᵢ = rᵢ · sk⁻¹
    return σ = (c, z₁, ..., zₜ)
```

## 9. Future Work

1. **Concrete instantiation**: Formalize supersingular elliptic curves over $\mathbb{F}_p$ and the ideal class group action.
2. **Quantum security analysis**: Formalize Kuperberg's algorithm and its subexponential complexity.
3. **Advanced protocols**: Extend to threshold signatures, blind signatures, and verifiable random functions built on CSIDH.
4. **Mixing time bounds**: Prove that random walks on isogeny Cayley graphs have polylogarithmic mixing time.

## References

[BKV19] W. Beullens, T. Kleinjung, F. Vercauteren. "CSI-FiSh: Efficient Isogeny Based Signatures through Class Group Computations." ASIACRYPT 2019.

[CD22] W. Castryck, T. Decru. "An Efficient Key Recovery Attack on SIDH." EUROCRYPT 2023.

[CLM+18] W. Castryck, T. Lange, C. Martindale, L. Panny, J. Renes. "CSIDH: An Efficient Post-Quantum Commutative Group Action." ASIACRYPT 2018.

[Cou06] J.-M. Couveignes. "Hard Homogeneous Spaces." Preprint, 2006.

[RS06] A. Rostovtsev, A. Stolbunov. "Public-Key Cryptosystem Based on Isogenies." Preprint, 2006.

[Sho94] P. Shor. "Algorithms for Quantum Computation: Discrete Logarithms and Factoring." FOCS 1994.
