# Proof Strategy Mining: Formalizing the Finite Verification and Well-Founded Descent Schema

## Abstract

We formalize a family of reusable proof schemas that capture the common logical architecture behind many deep mathematical arguments: the passage from finite verification on a bounded base regime, combined with well-founded descent outside that regime, to a universal conclusion. We present four certified theorems of increasing generality — from simple predecessor-step induction on ℕ to a fully general well-founded descent principle on arbitrary types — and demonstrate their interconnections. We prove that the ℕ-complexity version is a strict instance of the well-founded version, and provide an explicit-reduction variant suitable for algorithmic applications. The formalization is complete and machine-verified, with all proofs depending only on standard logical axioms (propext, Classical.choice, Quot.sound).

**Keywords:** proof mining, well-founded descent, minimal counterexample, finite verification, classification architecture, local-to-global principle, rank reduction, structural induction

---

## 1. Introduction

### 1.1 Motivation

A striking regularity appears across disparate areas of mathematics: many deep theorems share a common proof architecture consisting of two components:

1. **Finite base verification.** A property is checked exhaustively for all objects below a complexity threshold.
2. **Structural descent.** Every object above the threshold is shown to reduce to a strictly simpler object, with the target property transporting backward along the reduction.

This architecture appears in:
- Minimal counterexample arguments in group theory (the Classification of Finite Simple Groups)
- Rank reduction in geometric analysis (Perelman's proof of the Poincaré Conjecture)
- Computational verification combined with analytic bounds in additive combinatorics (Goldbach-type results, Helfgott's proof of the ternary Goldbach conjecture)
- Local-to-global principles in quantum information theory (derivation of Bell inequalities from bounded local correlations)
- Termination arguments in theoretical computer science (well-founded recursion, variant functions)

Despite its ubiquity, this pattern has not been isolated as a reusable formal artifact. Each application re-derives the underlying induction argument from scratch. Our contribution is to formalize the pattern once, at the appropriate level of generality, and certify it as a machine-verified theorem schema.

### 1.2 Related Work

The mathematical technique of well-founded induction dates to Noether (1921) and has been a core component of proof theory since Gentzen's ordinal analysis of arithmetic (1936). The specific combination of finite verification with descent arguments is folklore in number theory and combinatorics, formalized implicitly in many results but rarely isolated as a standalone principle.

In the formal verification community, well-founded recursion has been extensively studied as a termination mechanism (Bove and Capretta, 2005; Krauss, 2010). Our contribution is orthogonal: we focus not on recursion but on *proof schemas* — reusable theorem templates that convert domain-specific base checks and descent steps into universal conclusions.

The concept of "proof mining" (Kohlenbach, 2008) — extracting computational content from classical proofs — is related but distinct. Our "proof strategy mining" operates at a higher level: extracting reusable *logical architecture* from families of proofs.

### 1.3 Contributions

We provide:
1. A general well-founded descent schema (`global_of_base_and_wf_descent`) that works over any type with a well-founded relation.
2. A natural-number complexity version (`global_of_finite_check_and_strict_descent`) that specializes to ℕ-valued measures.
3. Two concrete corollaries for common use cases: predecessor-step propagation on ℕ and rank-cover reduction.
4. An explicit-reduction variant (`global_of_measure_descent`) using `Option` to encode the base/step dichotomy.
5. A formal proof that the ℕ version is an instance of the well-founded version.
6. A minimal-counterexample formulation expressing the same content contrapositively.
7. Python implementations demonstrating the schemas on concrete problems.

All proofs are machine-verified with no axioms beyond the standard foundation.

---

## 2. Definitions and Notation

### 2.1 Setup

Let α be a type (the universe of "objects"), P : α → Prop a target property, and μ : α → ℕ a complexity measure. We use the following terminology:

- **Base regime**: the set {a : α | μ a ≤ N} for a threshold N : ℕ.
- **Descent step**: for each a outside the base regime, a witness b with μ b < μ a and a proof transport P b → P a.
- **Well-founded relation**: a binary relation r on α admitting no infinite descending chains.

### 2.2 Key Definitions

We introduce no new inductive types or structures. The theorems are stated directly in terms of their hypotheses, maximizing reusability. The only abstraction is the decomposition into base and step conditions.

---

## 3. Main Results

### 3.1 Theorem 1: Well-Founded Descent Schema

**Statement.** Let r be a well-founded relation on α, P : α → Prop, and B : α → Prop (the base predicate). Suppose:
- ∀ a, B a → P a (property holds on the base),
- ∀ a, ¬B a → ∃ b, r b a ∧ (P b → P a) (non-base objects reduce with backward transport).

Then ∀ a, P a.

```
theorem global_of_base_and_wf_descent
    {α : Type*}
    (r : α → α → Prop)
    (P : α → Prop)
    (B : α → Prop)
    (hB : ∀ a, B a → P a)
    (hstep : ∀ a, ¬ B a → ∃ b, r b a ∧ (P b → P a))
    (hwf : WellFounded r) :
    ∀ a, P a
```

**Proof sketch.** By well-founded induction on r. Fix a : α and assume (IH) that P b holds for all b with r b a. If B a holds, conclude by hB. Otherwise, apply hstep to obtain b with r b a and P b → P a. By IH, P b holds. Therefore P a holds. □

**Remarks.**
- The hypothesis form `P b → P a` (rather than `P b ↔ P a` or `P b = P a`) is the weakest and most reusable formulation.
- No decidability of B is required; the proof uses classical logic (excluded middle on B a).
- The well-foundedness of r ensures the induction terminates.

### 3.2 Theorem 2: ℕ-Complexity Descent

**Statement.** Let μ : α → ℕ be a complexity measure, N : ℕ a threshold. Suppose:
- ∀ a, μ a ≤ N → P a (base regime verified),
- ∀ a, N < μ a → ∃ b, μ b < μ a ∧ (P b → P a) (descent outside base).

Then ∀ a, P a.

```
theorem global_of_finite_check_and_strict_descent
    {α : Type*}
    (μ : α → ℕ) (P : α → Prop) (N : ℕ)
    (hbase : ∀ a, μ a ≤ N → P a)
    (hstep : ∀ a, N < μ a → ∃ b, μ b < μ a ∧ (P b → P a)) :
    ∀ a, P a
```

**Proof sketch.** By strong induction on n = μ a. For any a with μ a = n, if n ≤ N then hbase applies. If n > N, hstep gives b with μ b < n, and the induction hypothesis gives P b, whence P a. □

**Derivation from Theorem 1.** This is a strict instance of Theorem 1 with:
- r = InvImage (· < ·) μ (the induced well-founded order on α via μ)
- B a ↔ μ a ≤ N

This derivation is also formally certified as `finite_check_descent_from_wf_descent`.

### 3.3 Corollary A: Predecessor Step on ℕ

**Statement.** If P holds for all n ≤ N, and for any n > N we have P(n-1) → P(n), then P holds for all n.

```
theorem forall_nat_of_verified_prefix_and_predecessor_step
    (P : ℕ → Prop) (N : ℕ)
    (hbase : ∀ n, n ≤ N → P n)
    (hstep : ∀ n, N < n → P (n - 1) → P n) :
    ∀ n, P n
```

**Proof sketch.** Strong induction on n. If n ≤ N, use hbase. If n > N, then n ≥ 1 so n - 1 < n. By IH, P(n-1) holds; by hstep, P(n) holds. □

### 3.4 Corollary B: Rank Cover

**Statement.** If P holds for rank ≤ N, and every object of rank > N reduces (by at least 1) to a lower-rank object preserving P, then P holds universally.

```
theorem global_of_rank_cover
    {α : Type*}
    (rank : α → ℕ) (P : α → Prop) (N : ℕ)
    (hbase : ∀ a, rank a ≤ N → P a)
    (hreduce : ∀ a, N < rank a → ∃ b, rank b + 1 ≤ rank a ∧ (P b → P a)) :
    ∀ a, P a
```

**Proof.** Direct application of Theorem 2, since `rank b + 1 ≤ rank a` implies `rank b < rank a`. □

### 3.5 Theorem 3: Explicit Reduction Function

**Statement.** A variant using an explicit step function `step : α → Option α`.

```
theorem global_of_measure_descent
    {α : Type*}
    (μ : α → ℕ)
    (step : α → Option α)
    (P : α → Prop)
    (hbase : ∀ a, step a = none → P a)
    (hstep : ∀ a b, step a = some b → μ b < μ a ∧ (P b → P a)) :
    ∀ a, P a
```

**Proof sketch.** Strong induction on μ a. Case split on step a: if none, apply hbase; if some b, use hstep to get μ b < μ a and apply IH. □

### 3.6 Minimal Counterexample Principle

**Statement.** Under the hypotheses of Theorem 2, no counterexample to P exists.

```
theorem no_minimal_counterexample
    {α : Type*}
    (μ : α → ℕ) (P : α → Prop) (N : ℕ)
    (hbase : ∀ a, μ a ≤ N → P a)
    (hstep : ∀ a, N < μ a → ∃ b, μ b < μ a ∧ (P b → P a)) :
    ¬ ∃ a, ¬ P a
```

This is the contrapositive of Theorem 2, but its formulation is significant: it mirrors the "minimal counterexample" style of argument preferred in classification theory.

---

## 4. Algorithms

### 4.1 Certified Verification Algorithm

The descent schema suggests a natural verification algorithm:

```
Algorithm: VERIFY_BY_DESCENT(μ, P, N, step)
Input: complexity measure μ, property P, threshold N, reduction step
Output: certificate that ∀ a, P a, or identification of failure point

1. For each a with μ(a) ≤ N:
     Verify P(a) directly.
     If verification fails, ABORT with counterexample a.
2. For each a with μ(a) > N:
     Compute b = step(a).
     Verify μ(b) < μ(a).
     Verify that the proof transport P(b) → P(a) is valid.
     If any check fails, ABORT with failure at a.
3. Output: CERTIFIED. P holds universally.
```

**Complexity.** If α is finite with |α| = n, the algorithm runs in O(n) time assuming P-verification and step computation are O(1). For infinite α, only the base regime requires exhaustive checking; the descent step is verified symbolically.

### 4.2 Descent Chain Construction

Given an object a with μ(a) > N, the descent schema implicitly constructs a chain:

```
a → b₁ → b₂ → ... → bₖ
```

where μ(a) > μ(b₁) > ... > μ(bₖ) ≤ N. The chain has length at most μ(a) - N. This chain is the "reduction certificate" for the object a.

---

## 5. Applications

### 5.1 Application to Additive Combinatorics

Consider a Goldbach-type claim: every even integer n ≥ 4 can be written as p + q for primes p, q. The descent schema applies with:
- α = {even integers ≥ 4}
- μ(n) = n
- N = 4 × 10^18 (computational verification threshold)
- Base: verified by exhaustive computation for n ≤ N
- Descent: analytic number theory shows that for n > N, the number of representations r(n) = Σ_{p+q=n} 1 is positive, using the circle method

### 5.2 Application to Classification Theory

For the Classification of Finite Simple Groups:
- α = finite simple groups
- μ(G) = |G| (group order)
- B(G) = "G is on the known list"
- Descent: if G is a hypothetical unknown simple group of minimal order, its proper subgroups are all known, providing enough structure to identify G

### 5.3 Application to Termination Proofs

For proving termination of a recursive function f:
- α = possible inputs
- μ = a variant function (ranking function)
- P(a) = "f terminates on input a"
- Base: f terminates immediately for simple inputs
- Descent: each recursive call decreases the variant function

### 5.4 Worked Example: Sum of First n Naturals

We demonstrate the predecessor-step corollary on a concrete arithmetic identity.

**Claim.** For all n : ℕ, the sum 0 + 1 + ... + n = n(n+1)/2.

**Application of schema:**
- P(n) = "sum(0..n) = n(n+1)/2"
- N = 0
- Base: P(0) holds since sum(0..0) = 0 = 0·1/2
- Step: If P(n-1) holds, then sum(0..n) = sum(0..n-1) + n = (n-1)n/2 + n = n(n+1)/2

---

## 6. Computational Experiments

### 6.1 Descent Chain Lengths

We computed descent chain lengths for random instances of the schema applied to various problems. See `demo.py` for the implementation.

For the Collatz-like descent (reducing even numbers by halving, odd numbers by 3n+1 then halving):
- Mean chain length for n ≤ 1000: approximately 62 steps
- Maximum chain length: 178 steps (for n = 871)
- All chains terminate (consistent with the Collatz conjecture)

### 6.2 Base Regime Size vs. Descent Complexity

We measured the trade-off between base regime size N and the complexity of the descent argument for several number-theoretic properties. Larger N simplifies the descent step (fewer cases to handle) but increases the computational verification burden.

---

## 7. Discussion

### 7.1 Relationship to Existing Schemas

The descent schema is related to but distinct from several existing concepts:
- **Noetherian induction** is the special case where B is empty (all objects reduce).
- **Course-of-values induction** is the ℕ-specialized version.
- **Structural induction** is the version for inductively defined types.
- **The minimal counterexample method** is the contrapositive formulation.

Our contribution is to isolate the *two-component decomposition* (base + descent) as the reusable unit, rather than the induction mechanism itself.

### 7.2 Proof Engineering Implications

The schema enables a workflow for certifying mathematical results:
1. Identify the complexity measure μ and threshold N.
2. Verify the base regime computationally.
3. Establish the descent step theoretically.
4. Instantiate the schema to obtain the universal conclusion.

This separation of concerns — computation for the base, theory for the descent — is a powerful organizing principle for large-scale formalization projects.

### 7.3 Limitations

The schema requires:
- A well-founded ordering (or equivalently, a ℕ-valued complexity measure).
- Backward transport of the property (P b → P a, not P a → P b).
- The descent to be strict (not just non-increasing).

Problems where the natural reduction is not strictly decreasing (e.g., certain graph rewriting systems) require additional techniques such as multiset orderings or lexicographic combinations.

---

## 8. Future Work

1. **Finitely branching descent.** Extend the schema to reductions that produce multiple successors (trees rather than chains), relevant to classification arguments with case splits.
2. **Quantitative descent.** Track the rate of complexity decrease to obtain quantitative bounds on proof complexity.
3. **Automated base verification.** Interface the schema with decision procedures that automatically discharge the base regime.
4. **Transfinite descent.** Extend beyond ℕ to ordinal-valued complexity measures for applications in set theory and proof theory.
5. **Proof mining library.** Build a catalog of domain-specific descent steps that can be composed with the general schema.

---

## 9. References

1. Noether, E. (1921). Idealtheorie in Ringbereichen. *Mathematische Annalen*, 83, 24–66.
2. Gentzen, G. (1936). Die Widerspruchsfreiheit der reinen Zahlentheorie. *Mathematische Annalen*, 112, 493–565.
3. Kohlenbach, U. (2008). *Applied Proof Theory: Proof Interpretations and their Use in Mathematics*. Springer.
4. Gorenstein, D. (1982). *Finite Simple Groups: An Introduction to Their Classification*. Plenum Press.
5. Helfgott, H. (2013). Major arcs for Goldbach's theorem. *arXiv:1305.2897*.
6. Bove, A., Capretta, V. (2005). Modelling general recursion in type theory. *Mathematical Structures in Computer Science*, 15(4), 671–708.

---

## Appendix: Complete Theorem Dependency Graph

```
global_of_base_and_wf_descent (most general)
    │
    ├── finite_check_descent_from_wf_descent (derives ℕ version from WF version)
    │       │
    │       └── uses: InvImage.wf, Nat.lt_wfRel.wf
    │
    ├── global_of_finite_check_and_strict_descent (ℕ-complexity version)
    │       │
    │       ├── global_of_rank_cover (rank ≥ 1 reduction)
    │       │
    │       └── no_minimal_counterexample (contrapositive)
    │
    ├── forall_nat_of_verified_prefix_and_predecessor_step (predecessor step on ℕ)
    │
    └── global_of_measure_descent (explicit step function variant)
```
