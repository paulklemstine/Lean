# Algebraic Foundations of Reflective Type Theory: Tropical Depth Homomorphisms in Provability Logic

## Abstract

We establish the algebraic foundations of Reflective Type Theory (ReflTT), a framework connecting modal provability logic with tropical semiring structures. The central result is that the modal nesting depth function is a tropical semiring homomorphism from the formula algebra to (ℕ, max, +), sending implication to max and the box operator to (+1). Building on this algebraic structure, we prove: (1) a substitution depth bound showing that depth respects tropical filtration under variable instantiation, (2) a strict two-level axiom depth hierarchy separating one-step provability axioms (T, K at depth 1) from iterated reasoning axioms (4, Löb at depth 2), (3) a depth-complexity gap theorem demonstrating that bounded depth allows unbounded formula size, (4) subject reduction for a proof term calculus, (5) a depth growth theorem for strictly increasing operators, (6) a constructive reflective fixed-point theorem characterizing the unique first-passage time through each depth level, and (7) a complete characterization of depth-0 formulas as boxless. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

Provability logic, initiated by Gödel [1933] and developed by Löb [1955], Solovay [1976], and Boolos [1993], studies the formal properties of the provability predicate in arithmetic. The central insight is that provability behaves as a modal operator □ satisfying specific axioms (K, 4, and Löb's axiom), giving rise to the modal logic GL (Gödel-Löb logic).

A less explored aspect of provability logic is the algebraic structure of modal nesting depth — the maximum number of nested □ operators in a formula. In this paper, we show that this depth function has a remarkably clean algebraic characterization: it is a tropical semiring homomorphism from the formula algebra to (ℕ, max, +).

The tropical semiring (ℕ, max, +) — where "addition" is max and "multiplication" is + — appears throughout mathematics, from optimization theory to algebraic geometry. Its appearance in provability logic is not accidental: the max operation captures how implication combines the depth of its components (taking the more complex one), while the +1 operation captures how the provability modality adds exactly one level of meta-reasoning.

### 1.1 Contributions

Our main contributions are:

1. **Tropical homomorphism theorem**: We prove that depth(A → B) = max(depth A, depth B) and depth(□A) = depth A + 1, identifying depth as a tropical semiring homomorphism (Section 3).

2. **Substitution depth bound**: We show that substituting formulas of depth ≤ d increases depth by at most d, and that substituting depth-0 formulas preserves depth exactly (Section 4).

3. **Axiom depth hierarchy**: We establish a strict two-level hierarchy: {T, K} at depth 1 and {4, Löb} at depth 2 (Section 5).

4. **Depth-complexity gap**: We prove that for any depth d and any size bound n, there exist formulas of depth exactly d with size exceeding n (Section 6).

5. **Subject reduction**: We define a proof term calculus and prove type preservation under reduction (Section 8).

6. **Depth growth theorem**: We show that iterating a strictly depth-increasing operator produces unbounded depth growth at least linearly (Section 9).

7. **Reflective fixed-point theorem**: We construct the unique first-passage point for each depth level in the reflective orbit A, □A, □²A, ... (Section 10).

8. **Depth-0 characterization**: We prove that depth 0 characterizes precisely the boxless (modality-free) formulas (Section 11).

### 1.2 Related Work

The modal logic GL has been extensively studied by Boolos [1993], Smorynski [1985], and others. The algebraic approach to modal logic via BAOs (Boolean algebras with operators) was developed by Jónsson and Tarski [1951]. Tropical algebra has been connected to logic through work on weighted automata and quantitative model checking. Our contribution is the direct identification of depth as a tropical homomorphism and the systematic development of its consequences.

## 2. Preliminaries

### 2.1 Modal Formulas

We work with the standard modal propositional language:

**Definition 2.1** (MFormula). The set of modal formulas is defined inductively by:
- var(n) for n ∈ ℕ (propositional variables)
- ⊥ (falsum)
- A → B (implication)
- □A (box / provability)

Standard abbreviations: ¬A ≡ A → ⊥, ⊤ ≡ ⊥ → ⊥, ◇A ≡ ¬□¬A.

### 2.2 Depth, Size, and Box Count

**Definition 2.2**. The modal nesting depth of a formula:
- depth(var n) = 0
- depth(⊥) = 0
- depth(A → B) = max(depth A, depth B)
- depth(□A) = depth A + 1

**Definition 2.3**. The formula size (number of syntax tree nodes):
- size(var n) = 1, size(⊥) = 1
- size(A → B) = size A + size B + 1
- size(□A) = size A + 1

**Definition 2.4**. The box count (number of □ occurrences):
- boxCount(var n) = 0, boxCount(⊥) = 0
- boxCount(A → B) = boxCount A + boxCount B
- boxCount(□A) = boxCount A + 1

## 3. Tropical Semiring Homomorphism

The tropical semiring (ℕ, max, +) has max as its additive operation and ordinary addition as its multiplicative operation.

**Theorem 3.1** (Tropical Homomorphism). The depth function is a tropical semiring homomorphism from the formula algebra to (ℕ, max, +):
- depth(A → B) = max(depth A, depth B) [tropical "addition"]
- depth(□A) = depth A + 1 [tropical "multiplication" by a generator]
- depth(var n) = depth(⊥) = 0 [tropical zero]

*Proof.* Immediate from the recursive definition of depth. □

**Theorem 3.2** (Iterated Box). For the iterated box □ⁿA:
- depth(□ⁿA) = depth A + n
- size(□ⁿA) = size A + n
- boxCount(□ⁿA) = boxCount A + n

*Proof.* By straightforward induction on n. □

The iterated box theorem shows that depth accumulates linearly under iteration, confirming the additive (tropical multiplicative) nature of the modality.

## 4. Substitution Depth Bounds

**Definition 4.1**. Substitution σ : ℕ → MFormula extends to formulas by:
- (var n)[σ] = σ(n)
- ⊥[σ] = ⊥
- (A → B)[σ] = A[σ] → B[σ]
- (□A)[σ] = □(A[σ])

**Theorem 4.1** (Substitution Depth Bound). If depth(σ(n)) ≤ d for all n, then depth(A[σ]) ≤ depth(A) + d.

*Proof sketch.* By induction on A:
- var n: depth(σ(n)) ≤ d = 0 + d = depth(var n) + d.
- ⊥: 0 ≤ 0 + d.
- A → B: depth(A[σ] → B[σ]) = max(depth(A[σ]), depth(B[σ])) ≤ max(depth A + d, depth B + d) = max(depth A, depth B) + d = depth(A → B) + d. The key step uses the tropical identity max(a + c, b + c) = max(a, b) + c.
- □A: depth(□(A[σ])) = depth(A[σ]) + 1 ≤ (depth A + d) + 1 = depth(□A) + d. □

**Theorem 4.2** (Depth-Preserving Substitution). If depth(σ(n)) = 0 for all n, then depth(A[σ]) = depth(A).

*Proof.* Similar induction, using the stronger hypothesis to obtain equalities throughout. □

**Interpretation.** The substitution depth bound shows that the tropical filtration is stable under instantiation: substituting formulas from the d-th filtration level increases depth by at most d. This is the key compatibility condition between the tropical structure and the formula algebra.

## 5. Axiom Depth Hierarchy

We consider the four fundamental modal axioms:

| Axiom | Schema | Ground Depth |
|-------|--------|:------------:|
| T | □A → A | 1 |
| K | □(A → B) → □A → □B | 1 |
| 4 | □A → □□A | 2 |
| Löb | □(□A → A) → □A | 2 |

**Theorem 5.1** (Axiom Depth Hierarchy). The modal axioms form a strict two-level depth hierarchy:
- depth(T) = depth(K) = 1 < 2 = depth(4) = depth(Löb)

when instantiated at ground-level (depth-0) variables.

**Interpretation.** The two-level structure reflects a fundamental dichotomy:
- **Level 1** (T, K): One-step provability reasoning — what can the system prove directly?
- **Level 2** (4, Löb): Meta-provability reasoning — what can the system prove about its own proving capabilities?

This is not merely a classification. The depth hierarchy has structural consequences: axiom instances at level 1 can be reasoned about within level 2, but not vice versa.

**Theorem 5.2** (Axiom Depth Parametricity). The depth of axiom K, instantiated at formulas A, B, is max(depth A, depth B) + 1. Similarly, axiom 4 at formula A has depth depth(A) + 2.

## 6. Depth-Complexity Gap

**Theorem 6.1** (Depth-Complexity Gap). For any size bound n ∈ ℕ, there exists a formula A with depth(A) = 0 and size(A) > n.

*Proof.* Let wideFormula(n) = ⊥ → (⊥ → (⊥ → ... → ⊥)...) with n implications. Then depth(wideFormula(n)) = 0 and size(wideFormula(n)) = 2n + 1. For any bound n, wideFormula(n) has size 2n + 1 > n. □

**Theorem 6.2** (Generalized Gap). For any depth d and size bound n, there exists a formula A with depth(A) = d and size(A) > n.

*Proof.* Take □ᵈ(wideFormula(n)), which has depth d and size 2n + 1 + d > n. □

**Interpretation.** The depth-complexity gap shows that self-referential depth and propositional complexity are orthogonal dimensions of formula structure. A formula can be deeply self-referential yet propositionally simple (like □□□p), or propositionally complex yet completely unreflective (like a long chain of implications of ⊥).

## 7. Depth Spectrum

**Definition 7.1** (Depth Spectrum). The depth spectrum of a formula A is the list recording the depth of each □ occurrence in A:
- depthSpectrum(var n) = []
- depthSpectrum(⊥) = []
- depthSpectrum(A → B) = depthSpectrum(A) ++ depthSpectrum(B)
- depthSpectrum(□A) = [depth(A) + 1] ++ depthSpectrum(A)

**Theorem 7.1**. boxCount(A) = |depthSpectrum(A)|.

*Proof.* By structural induction, using that each □ contributes exactly one element to the spectrum. □

The depth spectrum is a novel invariant that captures finer structure than depth alone. For example, □□p and □p → □q both have depth 1 when the latter is at ground level, but □□p has spectrum [2, 1] while □p → □q has spectrum [1, 1].

## 8. Subject Reduction

We define a proof term calculus for Hilbert-style modal logic:

**Definition 8.1** (Proof Terms).
- axK : K combinator
- axS : S combinator
- mp(t, s) : modus ponens
- nec(t) : necessitation

**Definition 8.2** (Typing). The typing judgment t : A is defined by:
- axK : A → (B → A)
- axS : (A → (B → C)) → ((A → B) → (A → C))
- If t : A → B and s : A, then mp(t, s) : B
- If t : A, then nec(t) : □A

**Definition 8.3** (Reduction). The congruence reduction relation:
- mp(t, s) reduces to mp(t', s) if t reduces to t'
- mp(t, s) reduces to mp(t, s') if s reduces to s'
- nec(t) reduces to nec(t') if t reduces to t'

**Theorem 8.1** (Subject Reduction). If t : A and t →ᵣ t', then t' : A.

*Proof.* By induction on the reduction relation, with case analysis on the typing derivation. Each reduction rule preserves the typing structure:
- For mp_left: invert the typing of mp(t, s) to obtain typing of t and s, apply IH to t, reconstruct mp typing.
- For mp_right: similar, applying IH to s.
- For nec_inner: invert the typing of nec(t) to obtain typing of t, apply IH, reconstruct nec typing. □

## 9. Depth-Monotone Operators

**Definition 9.1**. A depth-monotone operator F is a function F : MFormula → MFormula satisfying depth(A) ≤ depth(F(A)) for all A.

**Theorem 9.1** (Depth Growth). If F is strictly depth-increasing (depth(A) < depth(F(A)) for all A), then depth(A₀) + n ≤ depth(F^n(A₀)) for all n.

*Proof.* By induction on n. The base case is trivial. For the inductive step, depth(A₀) + (n+1) ≤ depth(Fⁿ(A₀)) + 1 ≤ depth(F(Fⁿ(A₀))) = depth(F^{n+1}(A₀)), using the IH and strict monotonicity. □

**Corollary.** The box operator □ is a depth-monotone operator with strict increase. Its iteration □ⁿ produces formulas of depth exactly depth(A) + n.

## 10. Reflective Fixed-Point Theorem

**Definition 10.1** (Reflective Orbit). The reflective orbit of A is the sequence A, □A, □²A, □³A, ...

**Theorem 10.1** (Reflective Fixed Point). For any formula A and target depth d ≥ depth(A), there exists a unique n such that:
- depth(□ⁿA) ≤ d (the orbit is still within the d-th filtration level)
- depth(□^{n+1}A) > d (the next step escapes)

The unique crossing point is n = d − depth(A).

*Proof.* Existence: Set n = d − depth(A). Then depth(□ⁿA) = depth(A) + n = depth(A) + (d − depth(A)) = d ≤ d. And depth(□^{n+1}A) = d + 1 > d.

Uniqueness: If m also satisfies both conditions, then depth(A) + m ≤ d and depth(A) + m + 1 > d. The first gives m ≤ d − depth(A) = n. The second gives m ≥ d − depth(A) = n. Hence m = n. □

**Interpretation.** The reflective fixed-point theorem provides a constructive Gödel-like diagonal: for any formula A and any depth level d, the orbit of A under the provability modality crosses that level at exactly one point. This "first-passage time" n = d − depth(A) serves as a canonical representative for the depth-d boundary crossing.

## 11. Depth-0 Characterization

**Definition 11.1**. A formula is boxless if it contains no □ operators.

**Theorem 11.1** (Depth-0 Characterization). A formula has depth 0 if and only if it is boxless.

*Proof.* (⇒) By induction: if depth(A) = 0 and A = □B, then depth(A) = depth(B) + 1 ≥ 1 > 0, contradiction. For imp, max(depth(A), depth(B)) = 0 implies both are 0, and IH gives boxless.

(⇐) By induction: boxless formulas have no □, so depth contributions only come from var and ⊥ (both depth 0) and imp (max of two depth-0 terms is 0). □

## 12. Abstract Reflective Type Systems

**Definition 12.1** (Reflective Type System). A reflective type system R consists of:
- A type universe Ty
- A provability modality Prov : Ty → Ty
- A function type former Arr : Ty → Ty → Ty
- A depth function depth : Ty → ℕ

satisfying the tropical axioms:
- depth(Arr(A, B)) = max(depth(A), depth(B))
- depth(Prov(A)) = depth(A) + 1

**Theorem 12.1** (No Depth Fixed Point). In any reflective type system, depth(Prov(A)) ≠ depth(A).

*Proof.* depth(Prov(A)) = depth(A) + 1 > depth(A). □

**Theorem 12.2**. The formula algebra (MFormula, □, →, depth) forms a reflective type system.

**Theorem 12.3** (Sublattice Property). For any d, the set {A | depth(A) ≤ d} is closed under Arr. That is, function types preserve depth bounds.

## 13. Discussion

### 13.1 Tropical Algebra and Provability

The identification of depth as a tropical homomorphism places provability logic within the broader framework of tropical mathematics. This connection is potentially bidirectional:

- **Tropical → Logic**: Tropical fixed-point theorems (e.g., Banach-style contractions in tropical metric spaces) may transfer to provability logic, providing new fixed-point constructions beyond the classical Gödel-Carnap diagonal.

- **Logic → Tropical**: The logical structure of self-reference may inform tropical geometry, particularly through the analogy between depth filtration and tropical curve degeneration.

### 13.2 The Depth-Complexity Orthogonality

The depth-complexity gap theorem reveals that self-referential depth and propositional complexity are genuinely independent dimensions. This has implications for proof complexity: bounds on the depth of proofs do not constrain their length, and vice versa.

### 13.3 Limitations and Future Work

Our current formalization covers the propositional fragment. Extension to first-order provability logic would require handling quantifier depth alongside modal depth, leading to a two-dimensional tropical structure. The full metatheory of the proof term calculus (normalization, decidability of type checking) remains for future work.

## References

1. Boolos, G. (1993). *The Logic of Provability*. Cambridge University Press.
2. Löb, M.H. (1955). Solution of a problem of Leon Henkin. *Journal of Symbolic Logic*, 20(2), 115-118.
3. Solovay, R.M. (1976). Provability interpretations of modal logic. *Israel Journal of Mathematics*, 25(3-4), 287-304.
4. Smorynski, C. (1985). *Self-reference and Modal Logic*. Springer.
5. Jónsson, B. and Tarski, A. (1951). Boolean algebras with operators, Part I. *American Journal of Mathematics*, 73, 891-939.
6. Maclagan, D. and Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.
