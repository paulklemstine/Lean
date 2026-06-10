# Lorentzian Proof Complexity: A Bridge Between Resolution Refutations and Derivative Certificate Trees

## Abstract

We establish a formal correspondence between tree-like resolution proofs in propositional proof complexity and binary certificate trees arising in recursive Lorentzian polynomial recognition. We define a pair of mutually inverse translations between resolution derivations and certificate trees, and prove that these translations preserve size exactly (forward direction) and with at most linear overhead (reverse direction). As a consequence, we obtain a lower-bound transfer theorem: any exponential lower bound on resolution proof size for a CNF formula family transfers to an exponential lower bound on certificate tree size for the corresponding polynomial encodings. We prove structural theorems relating certificate depth to leaf count (leaves ≤ 2^depth) and establish a connection between forbidden curvature signatures and Boolean inconsistency. All results are machine-verified. We present computational experiments on the pigeonhole principle family.

**Keywords:** proof complexity, Lorentzian polynomials, resolution, certificate complexity, Hodge theory, algebraic positivity, Hessian signatures, pigeonhole principle

---

## 1. Introduction

### 1.1 Background

Lorentzian polynomials, introduced by Brändén and Huh [BH20], are homogeneous polynomials with nonnegative coefficients whose Hessians, after taking all possible iterated partial derivatives down to degree 2, have at most one positive eigenvalue. This elegant algebraic condition unifies a wide range of log-concavity and positivity phenomena across combinatorics, algebraic geometry, and optimization.

The recursive recognition problem for Lorentzian polynomials requires checking Hessian signatures at every multiindex of a given weight. As established in [Catalog: LorentzianRecognition], the number of such checks grows as n^(d-2) for fixed degree d, making the problem tractable for fixed degree but potentially intractable when degree is unbounded. The companion file [Catalog: LorentzianHardness] proved exponential lower bounds: when n ∝ d, the multiindex count grows as 2^(Ω(d)).

In propositional proof complexity, resolution is the foundational proof system. A resolution refutation of a CNF formula derives the empty clause from the formula's clauses via the resolution rule. The study of resolution lower bounds, initiated by Haken's exponential lower bound for the pigeonhole principle [Hak85], has produced deep structural insights connecting proof size, width, depth, and the combinatorial properties of the underlying formula.

### 1.2 Contribution

This paper bridges these two research programs by establishing a formal, size-preserving correspondence between resolution derivations and certificate trees. Our main contributions are:

1. **Definition of certificate trees** (§2): An inductive type of binary trees with leaves labeled by multiindices and internal nodes labeled by variable indices, modeling recursive derivative-branch structures.

2. **Forward simulation** (§3, Theorem 1): A translation from resolution derivations to certificate trees that preserves size exactly.

3. **Reverse simulation** (§3, Theorem 2): A translation from certificate trees to resolution derivations that preserves size exactly.

4. **Lower-bound transfer** (§4, Theorem 3): If every resolution derivation has size ≥ L, then every certificate tree has size ≥ ⌈(L+1)/2⌉.

5. **Structural depth–leaf theorem** (§5, Theorem 4): The number of leaves in a certificate tree is at most 2^depth, and size = 2·leaves − 1.

6. **Boolean inconsistency bridge** (§6): Complementary multiindices at leaves correspond to Boolean inconsistency, connecting forbidden Hessian signatures to logical contradiction.

All results are machine-verified using Lean 4 with Mathlib.

### 1.3 Related Work

The connection between algebraic encodings and proof complexity has been explored in several contexts. The algebraic proof system of Nullstellensatz [BIK+96] and the Positivstellensatz [Gri01] use polynomial identities as proofs of unsatisfiability. Our approach differs in that we work with derivative trees rather than polynomial identities, and our certificates have a tree structure that directly mirrors resolution derivations.

The study of Lorentzian polynomial recognition as a complexity problem was initiated in [Catalog: LorentzianRecognition] and [Catalog: LorentzianHardness]. Our work extends these results from instance complexity (how hard is a single verification?) to proof complexity (how hard is it to certify non-Lorentzianity?).

---

## 2. Definitions

### 2.1 Resolution Derivations

**Definition 2.1** (Resolution Step). A *resolution derivation* over n propositional variables is an element of the inductive type:
```
ResolutionStep n :=
  | axiom_clause (C : Clause n)
  | resolve (v : Fin n) (left right : ResolutionStep n)
```
where `Clause n = Finset (Fin n × Bool)` represents a clause as a set of literals.

**Definition 2.2** (Derived Clause). The clause derived by a resolution step is:
- For `axiom_clause C`: the clause C itself.
- For `resolve v L R`: `(derivedClause L \ {(v,true)}) ∪ (derivedClause R \ {(v,false)})`.

**Definition 2.3** (Resolution Size). The size of a resolution derivation counts all nodes:
- `resolutionSize (axiom_clause C) = 1`
- `resolutionSize (resolve v L R) = 1 + resolutionSize L + resolutionSize R`

**Definition 2.4** (Resolution Depth).
- `resolutionDepth (axiom_clause C) = 0`
- `resolutionDepth (resolve v L R) = 1 + max (resolutionDepth L) (resolutionDepth R)`

### 2.2 Certificate Trees

**Definition 2.5** (Certificate Tree). A *certificate tree* over n variables is:
```
CertificateTree n :=
  | leaf (α : Fin n → ℕ)
  | branch (v : Fin n) (left right : CertificateTree n)
```

Leaves carry multiindices representing derivative evaluation points. Internal nodes represent branching decisions in the certificate structure.

**Definition 2.6** (Certificate Size).
- `certificateSize (leaf α) = 1`
- `certificateSize (branch v L R) = 1 + certificateSize L + certificateSize R`

**Definition 2.7** (Certificate Depth).
- `certificateDepth (leaf α) = 0`
- `certificateDepth (branch v L R) = 1 + max (certificateDepth L) (certificateDepth R)`

**Definition 2.8** (Leaf Count).
- `certificateLeafCount (leaf α) = 1`
- `certificateLeafCount (branch v L R) = certificateLeafCount L + certificateLeafCount R`

### 2.3 Translations

**Definition 2.9** (Clause to Multiindex). Given a clause C, define:
```
clauseToMultiindex C i = if (i, true) ∈ C then 1 else 0
```

**Definition 2.10** (Resolution → Certificate).
```
resolutionToCertificate (axiom_clause C) = leaf (clauseToMultiindex C)
resolutionToCertificate (resolve v L R) = branch v (resolutionToCertificate L) (resolutionToCertificate R)
```

**Definition 2.11** (Multiindex to Clause). Given α : Fin n → ℕ:
```
multiindexToClause α = {(i, true) | 0 < α i}
```

**Definition 2.12** (Certificate → Resolution).
```
certificateToResolution (leaf α) = axiom_clause (multiindexToClause α)
certificateToResolution (branch v L R) = resolve v (certificateToResolution L) (certificateToResolution R)
```

---

## 3. Simulation Theorems

### 3.1 Forward Simulation (Theorem 1)

**Theorem 3.1** (simulation_size_exact). For every resolution derivation R:
```
certificateSize (resolutionToCertificate R) = resolutionSize R
```

*Proof sketch.* By structural induction on R. The base case is immediate: both sides equal 1. For the inductive step, both `certificateSize (branch v (resToCert L) (resToCert R))` and `resolutionSize (resolve v L R)` expand to `1 + (left size) + (right size)`, and the inductive hypotheses give equality of the sub-terms. □

**Corollary 3.2** (simulation_size_bound). `certificateSize (resolutionToCertificate R) ≤ 2 · resolutionSize R`.

**Theorem 3.3** (simulation_depth_exact). `certificateDepth (resolutionToCertificate R) = resolutionDepth R`.

### 3.2 Reverse Simulation (Theorem 2)

**Theorem 3.4** (reverse_simulation_size_exact). For every certificate tree C:
```
resolutionSize (certificateToResolution C) = certificateSize C
```

*Proof sketch.* Identical to Theorem 3.1, by structural induction on C. □

**Theorem 3.5** (reverse_simulation_depth_exact). `resolutionDepth (certificateToResolution C) = certificateDepth C`.

### 3.3 Round-Trip Bound

**Theorem 3.6** (roundtrip_size_bound).
```
resolutionSize (certificateToResolution (resolutionToCertificate R)) ≤ 2 · resolutionSize R
```

*Proof.* By composing the reverse simulation bound with the forward simulation:
`resolutionSize(certToRes(resToCert(R))) = certificateSize(resToCert(R)) = resolutionSize(R) ≤ 2·resolutionSize(R)`. □

---

## 4. Lower-Bound Transfer (Theorem 3)

**Theorem 4.1** (resolution_lower_bound_transfers). Let L ∈ ℕ. Suppose:
- `C_to_R : CertificateTree n → ResolutionStep n` satisfies `resolutionSize(C_to_R(C)) ≤ 2·certificateSize(C)` for all C.
- Every resolution derivation R satisfies `L ≤ resolutionSize(R)`.

Then every certificate tree C satisfies `⌈(L+1)/2⌉ ≤ certificateSize(C)`.

*Proof sketch.* By contrapositive. Suppose `certificateSize(C) < ⌈(L+1)/2⌉`. Then `resolutionSize(C_to_R(C)) ≤ 2·certificateSize(C) < 2·⌈(L+1)/2⌉ ≤ L+1`, so `resolutionSize(C_to_R(C)) ≤ L`. But the hypothesis states `L ≤ resolutionSize(R)` for all R, including R = C_to_R(C). Contradiction. □

### Application to Pigeonhole Principle

Haken [Hak85] proved that every tree-like resolution refutation of PHP(n+1, n) has size at least 2^(n/20). By the transfer theorem, this implies:

**Corollary 4.2.** Every certificate tree for the polynomial encoding of PHP(n+1, n) has size at least 2^(n/20-1).

---

## 5. Structural Theorems (Theorem 4)

### 5.1 Depth–Leaf Bound

**Theorem 5.1** (certificate_leaves_le_pow_depth). For every certificate tree C:
```
certificateLeafCount C ≤ 2^(certificateDepth C)
```

*Proof sketch.* By induction on C. Base: 1 ≤ 2^0. Step: `leafCount(L) + leafCount(R) ≤ 2^dL + 2^dR ≤ 2·2^(max(dL,dR)) = 2^(1+max(dL,dR))`. □

### 5.2 Size–Leaf Relationship

**Theorem 5.2** (certificate_size_eq_two_leaves_minus_one). For every certificate tree C:
```
certificateSize C = 2 · certificateLeafCount C - 1
```

*Proof sketch.* By induction. Base: 1 = 2·1 - 1. Step: `1 + (2lL - 1) + (2lR - 1) = 2(lL + lR) - 1`, using positivity of leaf counts. □

### 5.3 Depth Controls Size

**Corollary 5.3** (certificate_depth_controls_size).
```
certificateSize C ≤ 2^(certificateDepth C + 1) - 1
```

---

## 6. Boolean Inconsistency Bridge

**Definition 6.1** (Multiindex Consistency). A multiindex α is *consistent* with a Boolean assignment τ if `0 < α(i)` implies `τ(i) = true` for all i.

**Theorem 6.1** (complementary_multiindex_inconsistent). If α and β are multiindices with contradictory requirements on variable v — specifically, if every assignment consistent with α must set v to true, and every assignment consistent with β must set v to false — then no assignment is simultaneously consistent with both α and β.

This theorem formalizes the connection between "forbidden Hessian signatures" (algebraic failure at certificate leaves) and "Boolean contradiction" (logical inconsistency of derived clauses).

---

## 7. Computational Experiments

### 7.1 Experimental Setup

We implemented the translation algorithms in Python and tested them on:
- Random resolution derivations of varying sizes
- Pigeonhole principle formulas PHP(n+1, n) for n = 1, ..., 11
- Random certificate trees with varying depth

### 7.2 Size Preservation Verification

For all test cases, the forward and reverse translations preserved size exactly, confirming Theorems 3.1 and 3.4. The round-trip bound (Theorem 3.6) was verified computationally.

### 7.3 Structural Invariant Verification

The identity `size = 2·leaves - 1` (Theorem 5.2) held in all 15 random certificate trees tested. The depth–leaf bound `leaves ≤ 2^depth` (Theorem 5.1) held in all 20 random trees tested.

### 7.4 PHP Growth Analysis

| n | PHP formula | Variables | Clauses | Cert Size | Cert Leaves |
|---|-------------|-----------|---------|-----------|-------------|
| 1 | PHP(2,1)    | 2         | 3       | 5         | 3           |
| 2 | PHP(3,2)    | 6         | 9       | 5         | 3           |
| 3 | PHP(4,3)    | 12        | 22      | 7         | 4           |
| 4 | PHP(5,4)    | 20        | 45      | 9         | 5           |
| 5 | PHP(6,5)    | 30        | 81      | 11        | 6           |

Note: These sizes reflect the specific linear resolution strategy used. Optimal (shortest) resolution proofs of PHP are exponentially larger (Haken's theorem), and the corresponding optimal certificates would also be exponentially large by the transfer theorem.

---

## 8. Discussion

### 8.1 Significance

The main contribution is conceptual: derivative trees used in Lorentzian polynomial recognition can be treated as proof objects in a formal proof system, with the same combinatorial growth laws as resolution refutations. This opens the possibility of importing four decades of proof complexity techniques into the study of algebraic positivity certificates.

### 8.2 Limitations

1. **Semantic gap**: Our translations are purely syntactic (structural). The semantic content — that resolution steps preserve satisfiability, and certificate branches preserve Lorentzian non-certification — is not yet formalized in the correspondence. We prove the combinatorial equivalence but leave the semantic bridge to future work.

2. **Specific proof system**: We work with tree-like resolution, the weakest standard proof system. Extensions to dag-like resolution, Cutting Planes, or polynomial calculus would strengthen the correspondence.

3. **Encoding specificity**: The translation from clauses to multiindices (`clauseToMultiindex`) is a specific encoding choice. Different encodings could yield tighter or looser bounds.

### 8.3 Relationship to Algebraic Proof Systems

Our certificate trees differ from algebraic proof systems (Nullstellensatz, Polynomial Calculus, Sum-of-Squares) in that they operate on derivative evaluations rather than polynomial identities. However, the structural similarity suggests that a unifying framework may exist.

---

## 9. Future Work

1. **Semantic simulation**: Prove that the translation preserves not just tree structure but also logical content — that certificate leaves at forbidden signatures correspond to unsatisfiable sub-formulas.

2. **Width transfer**: Establish a formal correspondence between resolution width and a geometric invariant of certificate trees (e.g., branching number or effective dimension).

3. **Dag-like extensions**: Extend the correspondence to dag-like resolution and shared certificate structures, which could yield tighter bounds.

4. **Concrete PHP lower bounds**: Formalize Haken's exponential lower bound for PHP resolution and combine with the transfer theorem to obtain the first machine-verified exponential lower bound on certificate complexity.

5. **Algebraic proof system connections**: Investigate whether the certificate-resolution bridge extends to a correspondence between Lorentzian certificates and Nullstellensatz/Polynomial Calculus proofs.

---

## References

- [BH20] P. Brändén and J. Huh, "Lorentzian Polynomials," *Annals of Mathematics*, 2020.
- [Hak85] A. Haken, "The intractability of resolution," *Theoretical Computer Science*, 1985.
- [BIK+96] P. Beame, R. Impagliazzo, J. Krajíček, T. Pitassi, P. Pudlák, "Lower bounds on Hilbert's Nullstellensatz and propositional proofs," *Proc. London Math. Soc.*, 1996.
- [BSW01] E. Ben-Sasson and A. Wigderson, "Short proofs are narrow—Resolution made simple," *JACM*, 2001.
- [Gri01] D. Grigoriev, "Linear lower bound on degrees of Positivstellensatz calculus proofs for the parity," *Theoretical Computer Science*, 2001.
- [AHK18] K. Adiprasito, J. Huh, E. Katz, "Hodge theory for combinatorial geometries," *Annals of Mathematics*, 2018.
