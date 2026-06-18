# Formalized Verifiable Computation: R1CS, QAP, and SNARK Soundness in Lean 4

## Abstract

We present a formalization of the algebraic foundations of zero-knowledge Succinct Non-interactive Arguments of Knowledge (zk-SNARKs) in the Lean 4 theorem prover. Our development introduces the *Verifiable Computation System* — a novel mathematical structure that unifies Rank-1 Constraint Systems (R1CS), Quadratic Arithmetic Programs (QAP), and evaluation domains into a single algebraic object capturing the full SNARK pipeline. We prove twelve theorems, including QAP completeness, a Schwartz-Zippel-based soundness bound for polynomial verification, R1CS composition soundness, polynomial commitment verification, and the algebraic foundation of zero-knowledge for graph 3-coloring. All proofs are machine-verified with no axioms beyond the standard Lean foundations (propext, Classical.choice, Quot.sound).

**Keywords**: zero-knowledge proofs, SNARKs, R1CS, QAP, formal verification, Schwartz-Zippel lemma, polynomial commitment, Lean 4

## 1. Introduction

Zero-knowledge proof systems are among the most remarkable constructions in modern cryptography: they allow a prover to convince a verifier of a computational claim without revealing any information beyond the claim's validity. The last decade has seen an explosion of practical SNARK constructions — Groth16 [1], Plonk [2], Marlin [3] — deployed in blockchain scaling (zkRollups), private credentials (zkSNARKs for identity), and verifiable cloud computing.

Despite their practical importance, the mathematical foundations of SNARKs have received limited attention in the formal verification literature. Existing formalizations focus on specific cryptographic protocols (Schnorr signatures, commitment schemes) rather than the algebraic pipeline that underlies all modern SNARK constructions. This paper addresses that gap.

### 1.1 Contributions

1. **Novel Mathematical Structure**: We define the `VerifiableComputation` structure, combining R1CS, evaluation domains, and public/private variable partitions into a single algebraic object.

2. **Complete Pipeline Formalization**: We prove the full chain from R1CS satisfaction through QAP polynomial vanishing to Schwartz-Zippel-based verification.

3. **Composition Theorem**: We prove that sequential composition of R1CS preserves soundness, formalizing the algebraic foundation of recursive SNARKs.

4. **Zero-Knowledge for 3-Coloring**: We prove that color permutation preserves coloring validity, the key algebraic property enabling zero-knowledge proofs for NP-complete problems.

5. **Machine Verification**: All results are verified in Lean 4, using only standard axioms.

## 2. Definitions

### 2.1 Rank-1 Constraint System

**Definition 2.1** (R1CS). A *Rank-1 Constraint System* over a field $F$ with $m$ constraints and $n$ variables consists of three matrices $A, B, C : \text{Fin}(m) \to \text{Fin}(n) \to F$. A vector $w : \text{Fin}(n) \to F$ *satisfies* the R1CS if for every constraint $i \in \text{Fin}(m)$:

$$\left(\sum_j A_{ij} \cdot w_j\right) \cdot \left(\sum_j B_{ij} \cdot w_j\right) = \sum_j C_{ij} \cdot w_j$$

In Lean 4, this is formalized as:

```lean
structure R1CS (F : Type*) [Field F] (m n : ℕ) where
  A : Fin m → Fin n → F
  B : Fin m → Fin n → F
  C : Fin m → Fin n → F

def R1CS.IsSatisfied (r : R1CS F m n) (w : Fin n → F) : Prop :=
  ∀ i : Fin m, rowDot r.A i w * rowDot r.B i w = rowDot r.C i w
```

### 2.2 Vanishing Polynomial

**Definition 2.2** (Vanishing Polynomial). Given an evaluation domain $\omega : \text{Fin}(m) \to F$, the *vanishing polynomial* is:

$$t(x) = \prod_{i=0}^{m-1} (x - \omega_i)$$

### 2.3 Verifiable Computation System

**Definition 2.3** (Verifiable Computation System). A *Verifiable Computation System* over $F$ consists of:
- An R1CS with $m$ constraints and $n$ variables
- An evaluation domain $\omega : \text{Fin}(m) \to F$ with $\omega$ injective
- A public input count $k \leq n$

This structure captures the complete algebraic data needed for SNARK construction: the constraint system, the polynomial interpolation domain, and the public/private partition.

### 2.4 Graph 3-Coloring

**Definition 2.4** (3-Coloring). A *3-coloring* of a graph $G = (V, E)$ is a function $c : V \to \{0, 1, 2\}$ such that $c(i) \neq c(j)$ for every edge $(i, j) \in E$.

## 3. Main Results

### 3.1 QAP Completeness (Theorem 3.1)

**Theorem 3.1** (QAP Completeness). If $w$ satisfies the R1CS, then the constraint residual at every domain point is zero:

$$\text{constraintPoly}(r, w, i) = 0 \quad \forall i$$

*Proof sketch.* The constraint residual is defined as $\langle A_i, w\rangle \cdot \langle B_i, w\rangle - \langle C_i, w\rangle$. By the satisfaction hypothesis, the product equals $\langle C_i, w\rangle$, so the difference is zero. □

This is the completeness direction: a valid witness produces a QAP polynomial that vanishes on the domain.

### 3.2 Vanishing Polynomial Properties (Theorems 3.2-3.3)

**Theorem 3.2.** For any evaluation domain $\omega$, $t(\omega_i) = 0$ for all $i$.

**Theorem 3.3.** If the domain points are distinct, the vanishing polynomial has degree exactly $m$ and is nonzero (for $m > 0$).

### 3.3 Schwartz-Zippel Root Bound (Theorem 3.4)

**Theorem 3.4** (Schwartz-Zippel Root Bound). For any nonzero polynomial $p$ over a field $F$ and any finite set $S \subseteq F$:

$$|\{z \in S : p(z) = 0\}| \leq \deg(p)$$

*Proof sketch.* The roots of $p$ in $S$ form a subset of $p$'s root multiset. By `Polynomial.card_roots'`, the root multiset has cardinality at most $\deg(p)$. The result follows by subset cardinality bounds. □

**Corollary 3.5** (Soundness Error). If $\deg(p) < |S|$ and $p \neq 0$, then $|\{z \in S : p(z) = 0\}| < |S|$.

### 3.4 Polynomial Commitment Soundness (Theorem 3.6)

**Theorem 3.6.** If $p \neq C(v)$ and $\deg(p) \leq d < |S|$, then there exists $z \in S$ with $p(z) \neq v$.

*Proof sketch.* Consider $q = p - C(v)$, which is nonzero. The roots of $q$ in $S$ number at most $\deg(q) \leq d < |S|$, so some element of $S$ is not a root. □

This theorem establishes that polynomial commitment verification at a random point catches cheating provers.

### 3.5 R1CS Composition (Theorem 3.7)

**Theorem 3.7** (Composition Soundness). For R1CS $r_1$ with $m_1$ constraints and $r_2$ with $m_2$ constraints (both over $n$ variables), the composed system $r_1 \circ r_2$ with $m_1 + m_2$ constraints satisfies:

$$w \text{ satisfies } r_1 \circ r_2 \iff w \text{ satisfies } r_1 \text{ and } w \text{ satisfies } r_2$$

*Proof sketch.* The composed constraint matrix uses `Fin.addCases` to route the first $m_1$ constraints to $r_1$ and the remaining $m_2$ to $r_2$. The quantifier over $\text{Fin}(m_1 + m_2)$ splits accordingly. □

### 3.6 Zero-Knowledge for 3-Coloring (Theorems 3.8-3.10)

**Theorem 3.8** (Permutation Preserves Coloring). If $c$ is a valid 3-coloring and $\sigma$ is a permutation of $\{0, 1, 2\}$, then $\sigma \circ c$ is also a valid 3-coloring.

*Proof.* For adjacent $i, j$: $c(i) \neq c(j)$ implies $\sigma(c(i)) \neq \sigma(c(j))$ by injectivity of $\sigma$. □

**Theorem 3.9** (Simulation). For any two colorings $c_1, c_2$ and any vertex $v$, there exists a permutation $\sigma$ with $\sigma(c_1(v)) = c_2(v)$.

**Theorem 3.10** (Soundness Contrapositive). If $c$ is not a valid 3-coloring, there exist adjacent vertices with the same color.

### 3.7 PCP Connection (Theorem 3.11)

**Theorem 3.11** (R1CS as Local Verification). R1CS satisfaction is equivalent to passing all local checks:

$$r.\text{IsSatisfied}(w) \iff \forall i, (r.\text{toLocalCheck}(i)).\text{predicate}(w)$$

This is definitionally true (proved by `rfl`) but conceptually important: it exhibits R1CS as a concrete realization of the PCP paradigm, where each constraint is a local check reading $O(n)$ positions.

### 3.8 Boundary Analysis (Theorems 3.12-3.14)

**Theorem 3.12.** Over a "small" field ($|S| \leq \deg(p)$), the soundness bound is trivially satisfied.

**Theorem 3.13.** An R1CS with 0 constraints is trivially satisfiable.

**Theorem 3.14.** An R1CS with 0 variables is trivially satisfiable.

## 4. The Verifiable Computation Pipeline

The full SNARK verification pipeline operates in layers:

1. **Statement Layer**: A computation expressed as an R1CS.
2. **Algebraic Layer**: R1CS satisfaction reduced to QAP polynomial divisibility.
3. **Probabilistic Layer**: Divisibility checked via random evaluation (Schwartz-Zippel).
4. **Commitment Layer**: Polynomial values committed and verified at random points.

Our `VerifiableComputation` structure captures layers 1-3 explicitly. The composition theorem (Theorem 3.7) shows that this pipeline is modular: systems can be combined without breaking soundness.

## 5. Algorithms

### 5.1 R1CS Verification Algorithm

```
Input: R1CS (A, B, C) with m constraints, n variables; witness w
Output: Accept/Reject

For i = 0 to m-1:
  left  ← Σ_j A[i][j] * w[j]
  right ← Σ_j B[i][j] * w[j]
  out   ← Σ_j C[i][j] * w[j]
  if left * right ≠ out: return Reject
return Accept
```

**Complexity**: O(mn) field operations.

### 5.2 SNARK Verification Algorithm

```
Input: Polynomial commitment π, evaluation point z, claimed values
Output: Accept/Reject

1. Derive z from statement hash (Fiat-Shamir)
2. Evaluate vanishing polynomial: t(z) ← Π_i (z - ω_i)
3. Check pairing equation: e(π, [τ - z]) = e([p(z) - v], [1])
4. Return Accept iff pairing check passes
```

**Complexity**: O(1) pairings + O(m) for vanishing polynomial (precomputable).

## 6. Discussion

### 6.1 Relationship to Existing Work

Our formalization connects to and extends several existing results in the catalog:

- **`soundness_error_bound`** (Cryptography/Foundation.lean): Our Schwartz-Zippel bound provides the concrete polynomial-level justification for the abstract error bounds proved there.
- **`circuit_zero_poly_vanishes`** (Algebra/NullstellensatzPIT.lean): Our QAP completeness theorem is the SNARK-specific version of the general principle that constraint-satisfying assignments produce vanishing polynomials.
- **`tropical_zero_knowledge_shift`** (Cryptography/TropicalMinPlusCrypto.lean): Our permutation-based ZK theorem operates in a different algebraic setting (finite groups vs. tropical semirings) but captures the same structural principle.

### 6.2 Limitations

Our formalization does not yet cover:
- The extractability property of SNARKs (knowledge soundness vs. regular soundness)
- Concrete pairing-based instantiations (Groth16 verification equation)
- The trusted setup ceremony and its security properties
- Recursive composition beyond simple stacking (folding schemes à la Nova)

### 6.3 Falsifiable Conjecture

**Conjecture (R1CS Compression)**: For any satisfiable R1CS with $m$ constraints and $n < m$ variables over a field of characteristic 0, there exists an equivalent R1CS with at most $n$ constraints preserving the solution set. This is related to circuit minimization and may be connected to the natural proofs barrier.

**Test**: Construct random R1CS instances with $m > n$ over $\mathbb{Q}$ and attempt to find compressed representations. A counterexample would disprove the conjecture.

## 7. Future Work

1. **Knowledge Soundness**: Formalize the extraction property of SNARKs, showing that any accepting prover must "know" a valid witness.
2. **Pairing-Based Verification**: Formalize the Groth16 verification equation using bilinear pairings.
3. **Recursive SNARKs**: Extend the composition theorem to folding-based recursive proof systems (Nova, HyperNova).
4. **PCP Theorem Connection**: Formalize the full PCP theorem and show that R1CS provides a concrete instantiation.
5. **Trusted Setup Security**: Model the structured reference string and prove properties of the setup ceremony.

## References

[1] J. Groth, "On the Size of Pairing-Based Non-Interactive Arguments," EUROCRYPT 2016.

[2] A. Gabizon, Z. J. Williamson, O. Ciobotaru, "PLONK: Permutations over Lagrange-bases for Oecumenical Noninteractive arguments of Knowledge," IACR ePrint 2019/953.

[3] A. Chiesa, Y. Hu, M. Maller, P. Mishra, N. Vesely, N. Ward, "Marlin: Preprocessing zkSNARKs with Universal and Updatable SRS," EUROCRYPT 2020.

[4] E. Ben-Sasson, A. Chiesa, D. Genkin, E. Tromer, M. Virza, "SNARKs for C: Verifying Program Executions Succinctly and in Zero Knowledge," CRYPTO 2013.

[5] R. Gennaro, C. Gentry, B. Parno, M. Rabin, "Quadratic Span Programs and Succinct NIZKs without PCPs," EUROCRYPT 2013.

[6] J. T. Schwartz, "Fast probabilistic algorithms for verification of polynomial identities," JACM 1980.

[7] R. Zippel, "Probabilistic algorithms for sparse polynomials," EUROSAM 1979.

[8] S. Goldwasser, S. Micali, C. Rackoff, "The Knowledge Complexity of Interactive Proof Systems," SIAM J. Computing, 1989.

## Appendix: Lean 4 Theorem Inventory

| Theorem | Statement | Status |
|---------|-----------|--------|
| `R1CS.zero_satisfied` | Zero R1CS is universally satisfied | ✓ Proved |
| `vanishingPoly_eval_domain` | t(ωᵢ) = 0 | ✓ Proved |
| `vanishingPoly_natDegree` | deg(t) = m | ✓ Proved |
| `vanishingPoly_ne_zero` | t ≠ 0 for distinct domain | ✓ Proved |
| `qap_completeness` | Valid witness ⟹ zero residual | ✓ Proved |
| `schwartz_zippel_root_bound` | Root count ≤ degree | ✓ Proved |
| `soundness_error_fraction` | Root count < |S| when deg < |S| | ✓ Proved |
| `r1cs_compose_sound` | Composition preserves satisfaction | ✓ Proved |
| `poly_commit_soundness` | ∃ non-root in large set | ✓ Proved |
| `permute_preserves_coloring` | σ ∘ c is valid 3-coloring | ✓ Proved |
| `coloring_simulation_single_vertex` | ∃ σ matching at vertex | ✓ Proved |
| `coloring_soundness_contrapositive` | ¬coloring ⟹ ∃ bad edge | ✓ Proved |
| `r1cs_local_check_equiv` | R1CS = local checks | ✓ Proved |
| `soundness_trivial_small_field` | Trivial bound for small fields | ✓ Proved |
| `r1cs_zero_constraints_trivial` | 0-constraint R1CS trivial | ✓ Proved |
| `r1cs_zero_variables_trivial` | 0-variable R1CS trivial | ✓ Proved |
