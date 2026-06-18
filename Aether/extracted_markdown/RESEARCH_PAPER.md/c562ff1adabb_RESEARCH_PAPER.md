# Formalized Security of Isogeny-Based Cryptography: CSIDH and CSI-FiSh

## Abstract

We present a machine-verified formalization of the cryptographic security foundations of CSIDH and CSI-FiSh, two prominent isogeny-based post-quantum cryptographic schemes. Working in the framework of abstract group actions on finite sets, we formalize free transitive group actions (torsors), prove that the CSIDH key exchange yields a bijective one-way function under the Group Action Inverse Problem (GAIP) assumption, establish the special soundness property of the CSI-FiSh identification protocol, and verify the correctness of multi-party key agreement. We introduce novel formalizations of group action morphisms, the stabilizer structure theorem, walk-based key space analysis, and the Decisional CSIDH problem. All theorems are proven without axioms beyond the standard foundational ones, with zero uses of `sorry`.

## 1. Introduction

### 1.1 Background

The advent of quantum computing threatens classical public-key cryptography based on integer factorization (RSA) and discrete logarithms (Diffie-Hellman, ECDSA). Shor's algorithm [Shor 1994] solves both problems in polynomial time on a quantum computer, motivating the development of post-quantum alternatives.

Isogeny-based cryptography, initiated by Couveignes [2006] and Rostovtsev-Stolbunov [2006], uses the computational difficulty of finding isogenies between elliptic curves as its security foundation. CSIDH (Commutative Supersingular Isogeny Diffie-Hellman) [Castryck et al. 2018] refines this approach by exploiting the commutative structure of the ideal class group of imaginary quadratic orders.

CSI-FiSh [Beullens, Kleinjung, Vercauteren 2019] builds on CSIDH to construct a signature scheme via the Fiat-Shamir transform applied to an identification protocol based on the GAIP.

### 1.2 Contributions

Our formalization contributes:

1. **Abstract group action framework**: We formalize `CryptoGroupAction` and `FreeTrans` structures that capture the essential properties of class group actions on supersingular curve sets.

2. **One-way function theorem**: We prove that the CSIDH map g ↦ g · x₀ is a bijection, establishing it as a one-way permutation under the GAIP hardness assumption.

3. **CSI-FiSh protocol verification**: We prove special soundness (secret extraction from two transcripts) and completeness of the identification protocol.

4. **Group action morphism category**: We introduce `GroupActionMorphism` as a novel formalization and prove that equivariant maps between torsors are injective.

5. **Multi-party key agreement**: We verify the correctness and permutation-invariance of the multi-party CSIDH protocol.

6. **Key space analysis**: We prove monotonicity results for the CSIDH key space size as a function of the number of primes and exponent bound.

7. **Decisional CSIDH**: We formalize the D-CSIDH problem and prove structural properties of real vs. random instances.

## 2. Mathematical Framework

### 2.1 Crypto Group Actions

**Definition 2.1** (CryptoGroupAction). A *crypto group action* consists of a finite group (G, ·) acting on a finite set X via a map act : G × X → X satisfying:
- act(1, x) = x for all x ∈ X (identity)
- act(g · h, x) = act(g, act(h, x)) for all g, h ∈ G, x ∈ X (compatibility)

**Definition 2.2** (FreeTrans). A *free transitive action* (torsor) additionally satisfies:
- ∀ x, y ∈ X, ∃ g ∈ G : act(g, x) = y (transitivity)
- ∀ g ∈ G, x ∈ X : act(g, x) = x → g = 1 (freeness)

### 2.2 The CSIDH Setting

In CSIDH, G = Cl(O) is the ideal class group of the order O = ℤ[π] where π is the Frobenius endomorphism of a supersingular curve over F_p, and X is the set of F_p-isomorphism classes of supersingular curves with endomorphism ring O.

The class group is abelian (commutative), which enables the key exchange protocol. The class number h = |Cl(O)| equals |X| by the cardinality theorem for torsors.

### 2.3 Group Action Morphisms

**Definition 2.3** (GroupActionMorphism). Given two crypto group actions (G, X, act_X) and (G, Y, act_Y) with the same group G, a *group action morphism* is a map f : X → Y satisfying equivariance:
    f(act_X(g, x)) = act_Y(g, f(x))

**Theorem 2.4** (Injectivity). If both actions are free and transitive, then every group action morphism f : X → Y is injective.

*Proof sketch*: Suppose f(x₁) = f(x₂). By transitivity, there exists g with act(g, x₁) = x₂. Then act_Y(g, f(x₁)) = f(act_X(g, x₁)) = f(x₂) = f(x₁), so g fixes f(x₁). By freeness of the Y-action, g = 1, hence x₁ = x₂. □

### 2.4 Stabilizer Structure

**Theorem 2.5** (Trivial Stabilizer). In a free action, the stabilizer Stab(x) = {g ∈ G : act(g, x) = x} equals {1} for every x ∈ X.

## 3. One-Way Function from GAIP

### 3.1 The CSIDH One-Way Function

Fix a base point x₀ ∈ X. The CSIDH one-way function is:

    f_{x₀} : G → X,  g ↦ act(g, x₀)

**Theorem 3.1** (Bijectivity). The function f_{x₀} is a bijection.

*Proof*: Injectivity follows from freeness (if act(g, x₀) = act(h, x₀), then act(g·h⁻¹, act(h, x₀)) = act(h, x₀), so g·h⁻¹ = 1). Surjectivity follows from transitivity. □

**Theorem 3.2** (Collision Resistance). Any collision f_{x₀}(g) = f_{x₀}(h) with g ≠ h contradicts freeness.

### 3.2 Hardness Assumption

The **Group Action Inverse Problem (GAIP)**: Given x₀ and y = act(g, x₀) for random g, compute g.

Under the GAIP hardness assumption, f_{x₀} is a one-way function. Our formalization makes this reduction explicit by showing that the connector map (the inverse of f_{x₀}) is exactly the GAIP.

## 4. CSI-FiSh Protocol

### 4.1 Identification Scheme

The CSI-FiSh identification protocol proceeds as follows:

1. **Setup**: Public key pk = act(s, x₀) for secret s.
2. **Commit**: Prover chooses random r, sends R = act(r, x₀).
3. **Challenge**: Verifier sends bit b ∈ {0, 1}.
4. **Response**: If b = 0, prover sends z = r. If b = 1, prover sends z = r · s⁻¹.
5. **Verify**: If b = 0, check act(z, x₀) = R. If b = 1, check act(z, pk) = R.

### 4.2 Completeness

**Theorem 4.1** (Completeness). An honest prover always passes verification.

*Proof*: For b = 0: act(r, x₀) = R by construction. For b = 1: act(r · s⁻¹, act(s, x₀)) = act(r · s⁻¹ · s, x₀) = act(r, x₀) = R, using the abelian property. □

### 4.3 Special Soundness

**Theorem 4.2** (Special Soundness). Given two accepting transcripts (R, 0, z₀) and (R, 1, z₁) for the same commitment R, we can extract the secret key: act(z₀ · z₁⁻¹, x₀) = pk.

*Proof*: From the two transcripts: act(z₀, x₀) = R and act(z₁, pk) = R. Hence act(z₁⁻¹, R) = pk, and act(z₀ · z₁⁻¹, x₀) = act(z₁⁻¹, act(z₀, x₀)) = act(z₁⁻¹, R) = pk. (Uses commutativity for the reordering.) □

### 4.4 Signature Scheme

CSI-FiSh applies the Fiat-Shamir transform: replace the verifier's challenge with a hash of the commitment and message. The signature consists of (commitments, challenges, responses) for t parallel rounds.

**Theorem 4.3** (Honest Sign Verification). Honestly generated signatures always pass verification.

## 5. Multi-Party Key Agreement

### 5.1 Protocol

For n parties with secrets g₁, ..., gₙ, the shared key is act(∏gᵢ, x₀).

**Theorem 5.1** (Permutation Invariance). The shared key is invariant under permutations of the secret list, by commutativity of G.

*Proof*: By induction on the permutation relation. The key step is that for any transposition of adjacent elements gᵢ and gᵢ₊₁, we have gᵢ · gᵢ₊₁ = gᵢ₊₁ · gᵢ by commutativity. □

**Theorem 5.2** (Partial Key). Any party can compute the shared key by applying their secret to the partial key (product of all other secrets applied to x₀).

## 6. Walk-Based Analysis

### 6.1 Cayley Graph Walks

A walk of length k in the Cayley graph corresponds to a list [g₁, ..., gₖ] of generators, with the resulting action being act(g₁ · g₂ · ... · gₖ, x₀).

**Theorem 6.1** (Walk-Product Correspondence). The walk evaluation equals the action by the product of generators, proved by induction on the walk length.

**Theorem 6.2** (Walk Concatenation). Concatenating two walks corresponds to composing their actions, equivalent to multiplying the products.

### 6.2 Key Space Size

With n small primes and exponent bound B, the key space has size (2B+1)ⁿ.

**Theorem 6.3** (Monotonicity in B). For fixed n > 0: (2B+1)ⁿ < (2(B+1)+1)ⁿ.

**Theorem 6.4** (Monotonicity in n). For fixed B > 0: (2B+1)ⁿ < (2B+1)ⁿ⁺¹.

### 6.3 Security Parameter Selection

For CSIDH-512: n = 74 primes, B = 5, giving (11)⁷⁴ ≈ 2²⁵⁶ — matching 128-bit post-quantum security.

## 7. Decisional CSIDH

### 7.1 Problem Statement

The Decisional CSIDH (D-CSIDH) problem: Given (x₀, g·x₀, h·x₀), distinguish (g·h)·x₀ from a uniformly random element of X.

**Theorem 7.1** (Real Instance Characterization). In a real D-CSIDH instance, the target equals act(connector(x₀, gx) · connector(x₀, hx), x₀).

This provides a clean algebraic characterization of the "real" distribution in terms of the connector map.

## 8. Connector Algebra

The connector map c(x, y) — the unique group element mapping x to y — satisfies a rich algebraic structure:

**Theorem 8.1** (Cocycle Property). c(x, z) = c(y, z) · c(x, y).

**Theorem 8.2** (Inversion). c(y, x) = c(x, y)⁻¹.

**Theorem 8.3** (Identity). c(x, x) = 1.

**Theorem 8.4** (Action Recovery). c(x, act(g, x)) = g.

These properties make the connector a group-valued 1-cocycle on the torsor, connecting the algebraic structure to cohomological ideas.

## 9. Repeated Squaring

**Theorem 9.1** (Additive Law). act(g^(m+n), x) = act(g^m, act(g^n, x)).

This enables efficient evaluation of large powers via the square-and-multiply algorithm, critical for practical CSIDH implementations.

## 10. Conjecture and Future Work

### 10.1 Cayley Diameter Conjecture

**Conjecture 10.1**: For Z/nZ with generators {±1}, the Cayley graph diameter is ⌊n/2⌋. That is, every element a can be written as a = ±k for some k ≤ ⌊n/2⌋.

*Computational evidence*: Verified for all n ≤ 101 in the test suite.

### 10.2 Class Number Heuristic

**Conjecture 10.2**: For CSIDH primes p, the class number h of ℤ[√(-p)] satisfies h ≤ √p and √p ≤ 4π·h.

### 10.3 Future Directions

1. Formalize the expander graph properties of isogeny Cayley graphs.
2. Prove tight bounds on the mixing time of random walks.
3. Formalize the security reduction from the D-CSIDH problem to the computational CSIDH problem.
4. Connect to the SIDH/SIKE attacks [Castryck-Decru 2022] and the structural differences between commutative and non-commutative isogeny-based schemes.

## 11. Discussion

Our formalization demonstrates that the core security arguments for CSIDH and CSI-FiSh can be made completely rigorous at the level of abstract group actions. The key insight is that the free transitive action structure alone — without any details about elliptic curves, isogenies, or class groups — suffices to establish:

- The one-way function property (bijectivity of the public key map)
- The key exchange correctness (from commutativity)
- The identification protocol security (special soundness)
- The signature scheme correctness (via Fiat-Shamir)

This level of abstraction has both advantages and limitations. It cleanly separates the *structural* security (what follows from the torsor axioms) from the *computational* security (what follows from GAIP hardness). But it doesn't capture the algebraic geometry that makes specific instantiations secure or insecure.

The novel formalization of group action morphisms provides a framework for reasoning about relationships between different instantiations of CSIDH, potentially enabling formal security proofs for parameter changes or optimizations.

## References

1. Castryck, W., Lange, T., Martindale, C., Panny, L., Renes, J. (2018). CSIDH: An Efficient Post-Quantum Commutative Group Action. ASIACRYPT 2018.

2. Beullens, W., Kleinjung, T., Vercauteren, F. (2019). CSI-FiSh: Efficient Isogeny based Signatures through Class Group Computations. ASIACRYPT 2019.

3. Couveignes, J.-M. (2006). Hard Homogeneous Spaces. Cryptology ePrint Archive.

4. Castryck, W., Decru, T. (2022). An efficient key recovery attack on SIDH. Cryptology ePrint Archive.

5. Alamati, N., De Feo, L., Montgomery, H., Patranabis, S. (2020). Cryptographic Group Actions and Applications. ASIACRYPT 2020.

6. Shor, P. (1994). Algorithms for Quantum Computation: Discrete Logarithms and Factoring. FOCS 1994.
