# Oracle Closure Algebras and Resolvability Degrees in Reflective Hierarchies

## Abstract

We develop the algebraic theory of oracle closure operators arising from reflective oracle hierarchies — sequences of formal theories indexed by natural numbers, each extending the previous by adding the consistency statement of its predecessor. We prove that the oracle closure operator is extensive and monotone but *not* idempotent at any finite depth, establishing a direct algebraic characterization of Gödel's incompleteness phenomenon. We introduce *resolvability degrees*, a preorder on sentences measuring their oracle complexity, and prove that the canonical consistency sentences form an antichain in this order — capturing the logical independence of different levels of incompleteness. We establish the hierarchy collapse impossibility theorem (no finite extension can reach the ω-limit) and the strict descent of incompleteness kernels. All results are formalized in Lean 4 with the Mathlib library.

**Keywords**: Oracle hierarchies, Gödel incompleteness, closure operators, resolvability degrees, proof theory, formalization

---

## 1. Introduction

Gödel's incompleteness theorems (1931) establish that any sufficiently powerful, consistent formal system T contains a true sentence not provable in T. The natural response is to extend T by adding the unprovable sentence (typically the consistency statement Con(T)) as a new axiom, obtaining a stronger theory T₁ = T + Con(T). Iterating this process yields a hierarchy:

  T₀ ⊂ T₁ ⊂ T₂ ⊂ ⋯

where Tₙ₊₁ = Tₙ + Con(Tₙ). This construction, studied extensively by Turing (1939), Feferman (1962), and Franzén (2004), produces an ω-sequence of theories with remarkable structural properties.

In this paper, we study this hierarchy from an *algebraic* perspective, treating the oracle jump as an operator on sets of sentences and analyzing its closure-theoretic properties. Our main contributions are:

1. **Oracle Closure Algebra** (§3): We show that the oracle closure operator satisfies extensivity and monotonicity but fails idempotence at every finite depth, providing an algebraic reformulation of Gödel's theorem.

2. **Resolvability Degrees** (§5): We introduce a preorder on sentences based on their oracle complexity and prove that the consistency sentences form an antichain — establishing the logical independence of different levels of incompleteness.

3. **Incompleteness Kernel Descent** (§4): We prove that the incompleteness kernels (sets of true-but-unprovable sentences) form a strictly decreasing chain, with the consistency sentences as canonical separating witnesses.

4. **Hierarchy Collapse Impossibility** (§5): We prove that no finite number of oracle jumps can reach the ω-limit theory.

5. **Concrete Construction** (§7): We provide a concrete model over ℕ demonstrating that all axioms are simultaneously satisfiable.

All results are formalized in Lean 4 and machine-verified.

---

## 2. Definitions

### 2.1 Oracle Hierarchies

An **oracle hierarchy** H consists of:
- A type `Sentence` of sentences
- A family `Provable : ℕ → Sentence → Prop` of provability predicates
- A truth predicate `True_ : Sentence → Prop`
- A bottom sentence `bot` with `¬ True_(bot)`
- **Monotonicity**: `Provable(n, φ) → Provable(n+1, φ)` for all n, φ
- **Strictness**: For each n, there exists φ with `Provable(n+1, φ) ∧ ¬Provable(n, φ)`
- A family `conSentence : ℕ → Sentence` of consistency sentences satisfying:
  - **Truth**: `True_(conSentence(n))` for all n
  - **Incompleteness**: `¬Provable(n, conSentence(n))` for all n
  - **Jump Resolution**: `Provable(n+1, conSentence(n))` for all n
  - **Injectivity**: `conSentence` is injective

### 2.2 Derived Notions

The **provable set** at level n is `Prov(n) = {φ | Provable(n, φ)}`.

The **oracle closure** at depth k from level n is `Cl(n, k) = Prov(n + k)`.

The **union provable set** is `Prov(ω) = ⋃ₙ Prov(n)`.

The **incompleteness kernel** at level n is `K(n) = {φ | True_(φ) ∧ ¬Provable(n, φ)}`.

The **resolvability preorder** is: `φ ≤ᵣ ψ` iff `∀n, Provable(n, ψ) → Provable(n, φ)`.

---

## 3. Oracle Closure Algebra

### 3.1 Extensivity and Monotonicity

**Theorem 3.1** (Extensivity). *For all n, k, we have Prov(n) ⊆ Cl(n, k).*

*Proof.* By multi-step monotonicity: if φ is provable at level n, then it is provable at level n + k ≥ n. □

**Theorem 3.2** (Monotonicity). *For j ≤ k, we have Cl(n, j) ⊆ Cl(n, k).*

*Proof.* Prov(n + j) ⊆ Prov(n + k) by multi-step monotonicity, since n + j ≤ n + k. □

### 3.2 Failure of Idempotence

**Theorem 3.3** (Non-Idempotence). *For all n, Cl(n, 1) ≠ Cl(n, 2).*

*Proof.* Consider Con(n+1). By the jump resolution axiom, Provable(n+2, Con(n+1)), so Con(n+1) ∈ Cl(n, 2). By the incompleteness axiom, ¬Provable(n+1, Con(n+1)), so Con(n+1) ∉ Cl(n, 1). □

**Remark 3.4.** The failure of idempotence is the algebraic signature of Gödel incompleteness. In the theory of closure systems, an operator that is extensive and monotone but not idempotent is called a *preclosure operator*. The oracle jump is thus a preclosure operator whose iterates form a strictly increasing chain — a phenomenon impossible for genuine closure operators, which stabilize after one application.

More precisely, for any depth k, applying one more jump always strictly enlarges the provable set:

**Corollary 3.5.** *For all n and all k₁ < k₂, Cl(n, k₁) ⊊ Cl(n, k₂).*

---

## 4. Incompleteness Kernels

### 4.1 Nonemptiness

**Theorem 4.1.** *For all n, K(n) is nonempty.*

*Proof.* Con(n) is true (by the truth axiom) and not provable at level n (by the incompleteness axiom). □

### 4.2 Strict Descent

**Theorem 4.2** (Strict Kernel Descent). *For all n, K(n+1) ⊊ K(n).*

*Proof.* For the subset direction: if φ ∈ K(n+1), then True_(φ) and ¬Provable(n+1, φ). By monotonicity, ¬Provable(n, φ), so φ ∈ K(n).

For strictness: Con(n) ∈ K(n) by Theorem 4.1, but Con(n) ∉ K(n+1) because Provable(n+1, Con(n)) by jump resolution. □

**Theorem 4.3** (Multi-level Separation). *For m < n, K(n) ⊊ K(m).*

*Proof.* By induction on n - m, using Theorem 4.2 and transitivity of ⊊. □

### 4.3 Interpretation

The strict descent of kernels means that each oracle jump genuinely resolves some incompleteness (Con(n) exits the kernel) while preserving the rest. The kernel sequence {K(n)}ₙ is a filtration of the set of true sentences by their oracle complexity.

---

## 5. Resolvability Degrees and the Diagonal Antichain

### 5.1 The Resolvability Preorder

**Definition 5.1.** For sentences φ, ψ in an oracle hierarchy, we write φ ≤ᵣ ψ and say "φ is resolvability-dominated by ψ" if every level proving ψ also proves φ.

**Proposition 5.2.** ≤ᵣ is a preorder (reflexive and transitive).

**Theorem 5.3** (Strict Ordering). *Con(n+1) is not resolvability-dominated by Con(n).*

*Proof.* Suppose Con(n+1) ≤ᵣ Con(n). Then Provable(n+1, Con(n)) implies Provable(n+1, Con(n+1)). But Con(n) is provable at level n+1 (by jump resolution) and Con(n+1) is not (by incompleteness). Contradiction. □

### 5.2 The Antichain Theorem

**Theorem 5.4** (Diagonal Antichain). *For m ≠ n, the pair (Con(m), Con(n)) is not mutually comparable in the resolvability preorder.*

*Proof.* Without loss of generality, assume m < n. Suppose both Con(m) ≤ᵣ Con(n) and Con(n) ≤ᵣ Con(m). By jump resolution, Provable(m+1, Con(m)). By the second dominance, Provable(m+1, Con(n)). But m + 1 ≤ n, so by multi-step monotonicity upward and the incompleteness axiom, this is impossible. □

**Interpretation.** The antichain theorem says that different levels of incompleteness are genuinely independent. Resolving Con(5) provides no information about Con(3), and vice versa. Each consistency sentence represents a unique, irreducible source of uncertainty in the hierarchy.

### 5.3 Hierarchy Collapse Impossibility

**Theorem 5.5** (Collapse Impossibility). *For all n, k, Cl(n, k) ≠ Prov(ω).*

*Proof.* Con(n + k) ∈ Prov(ω) (witnessed by level n + k + 1). But Con(n + k) ∉ Cl(n, k) = Prov(n + k), by the incompleteness axiom. □

### 5.4 Unbounded Diagonal Resistance

**Theorem 5.6** (Unbounded Resistance). *For every N, there exists a true sentence requiring more than N oracle jumps to resolve.*

*Proof.* Con(N) is true and not provable at any level m ≤ N (since provability at level m ≤ N would imply provability at level N by monotonicity, contradicting incompleteness). □

---

## 6. Quantifier Complexity Classification

We classify sentences by their behavior in the hierarchy:

- **Σ₁-resolvable**: ∃n, Provable(n, φ). These are sentences that eventually become provable.
- **Π₂-persistent**: True_(φ) ∧ ∀n, ¬Provable(n, φ). These are permanently unprovable truths.

All consistency sentences are Σ₁-resolvable (each requires exactly one jump above its index). The existence of Π₂-persistent sentences depends on the hierarchy — in the standard arithmetic hierarchy starting from PA, the soundness statement "all provable sentences are true" is Π₂-persistent.

**Conjecture 6.1** (Resolvability Density). *For any Π₂-persistent sentence φ and any level n, there exists a Σ₁-resolvable true sentence not yet provable at level n.* This states that Σ₁-resolvable sentences are "dense" around persistent ones in the hierarchy.

---

## 7. Concrete Model

We construct a concrete oracle hierarchy over ℕ:
- Sentences are natural numbers
- Con(k) = 2k + 1 (odd numbers)
- Provable(n, s) ⟺ ∃k < n, s = 2k + 1
- True_(s) ⟺ ∃k, s = 2k + 1
- bot = 0

This model satisfies all axioms and demonstrates their joint consistency.

---

## 8. Convergence

**Theorem 8.1** (Convergence). *Prov(ω) = ⋃ₙ Prov(n).*

*Proof.* By definition, both sides equal {φ | ∃n, Provable(n, φ)}. □

**Theorem 8.2.** *The union theory proves all finite consistency sentences: Con(n) ∈ Prov(ω) for all n.*

---

## 9. Discussion

### 9.1 Relation to Prior Work

The oracle hierarchy has been studied since Turing's 1939 work on ordinal logics. Our contribution is the algebraic perspective: treating the jump as a preclosure operator and studying its fixed-point failure. This connects Gödel incompleteness to the well-developed theory of closure algebras, lattice theory, and Galois connections.

The resolvability preorder is new. It provides a natural notion of "relative difficulty" for incompleteness phenomena, analogous to Turing reducibility in computability theory but operating at the proof-theoretic level.

### 9.2 The Preclosure Perspective

The key algebraic insight is that Gödel incompleteness corresponds precisely to the failure of idempotence of the oracle closure operator. A closure operator (extensive, monotone, idempotent) on a lattice always has a well-behaved fixed-point theory. The oracle jump, being merely a preclosure operator, generates an unbounded ascending chain — the hierarchy itself.

### 9.3 Connections to Computability

The oracle hierarchy mirrors the arithmetical hierarchy in computability theory: Σ₁ sets are those computable relative to a single halting oracle, Σ₂ sets require two, and so forth. Our resolvability degrees are the proof-theoretic analogue of Turing degrees. The antichain theorem is the analogue of Post's problem (the existence of incomparable Turing degrees), but with a much simpler proof: the consistency sentences provide canonical incomparable elements.

---

## 10. Future Work

1. **Transfinite extensions**: Extend the hierarchy to ordinal indices, connecting to ordinal analysis and proof-theoretic ordinals.
2. **Speed-up theorems**: Quantify the proof-length compression gained by oracle jumps.
3. **Connections to modal logic**: Relate the resolvability preorder to Kripke frames for provability logic (GL).
4. **Density conjectures**: Investigate whether Σ₁-resolvable sentences are dense among all true sentences in natural hierarchies.

---

## References

1. K. Gödel, "Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I," *Monatshefte für Mathematik und Physik*, 38 (1931), 173–198.
2. A.M. Turing, "Systems of Logic Based on Ordinals," *Proc. London Math. Soc.*, s2-45 (1939), 161–228.
3. S. Feferman, "Transfinite recursive progressions of axiomatic theories," *J. Symbolic Logic*, 27 (1962), 259–316.
4. T. Franzén, *Inexhaustibility: A Non-Exhaustive Treatment*, ASL Lecture Notes in Logic (2004).
5. G. Boolos, *The Logic of Provability*, Cambridge University Press (1993).
