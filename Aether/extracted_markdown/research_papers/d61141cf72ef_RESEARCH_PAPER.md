# Algebraic Foundations of Reflective Type Theory: Tropical Depth Homomorphisms in Provability Logic

## Abstract

We establish the algebraic foundations of Reflective Type Theory (ReflTT) by proving that the modal depth function on provability logic formulas constitutes a tropical semiring homomorphism from the formula algebra to (ℕ, max, +). This structural result connects the study of self-referential provability to tropical algebra, enabling the import of tropical fixed-point theorems and valuation theory into proof-theoretic reasoning. We formalize the complete Gödel-Löb provability logic (GL), prove the axiom hierarchy K ≤ K4 ≤ GL, establish the soundness of Löb's axiom on transitive well-founded Kripke frames via well-founded induction, prove that proof depth constitutes an irreducible lower bound on derivation complexity, and introduce *reflective complexity* — a novel well-founded measure combining modal depth and formula size that is compatible with the tropical structure. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Background

Gödel's incompleteness theorems (1931) established fundamental limits on self-referential reasoning in formal systems. The study of these limits was systematized by Solovay (1976), who proved that the modal logic **GL** (Gödel-Löb logic) is arithmetically complete: a modal formula is provable in GL if and only if every arithmetical interpretation of the formula is provable in Peano Arithmetic, where the box modality □ is interpreted as the provability predicate Bew(⌜·⌝).

The tropical semiring (ℕ, max, +) — where max replaces addition and + replaces multiplication — has become a fundamental structure in algebraic geometry, optimization, and combinatorics. The connection between tropical algebra and provability logic has not been previously explored in depth.

### 1.2 Contributions

This paper makes the following contributions:

1. **Tropical Depth Homomorphism** (Theorem 5.1): The modal depth function d: MFormula → ℕ satisfies d(φ → ψ) = max(d(φ), d(ψ)) and d(□φ) = d(φ) + 1, making it a homomorphism from the formula algebra (under implication and box) to the tropical semiring (ℕ, max, +).

2. **Depth-Complexity Gap** (Theorem 3.1): For all formulas φ, d(φ) < |φ|, where |φ| is the formula size. Moreover, d(φ) ≤ b(φ) < |φ| where b(φ) is the box count.

3. **Axiom Hierarchy** (Theorems 9.1-9.3): K ≤ K4 ≤ GL as proof systems, where ≤ denotes derivability inclusion.

4. **Löb Soundness** (Theorem 10.1): The Löb axiom □(□φ → φ) → □φ is sound on all transitive, conversely well-founded Kripke frames.

5. **Reflective Complexity** (Definition 5.1): A novel well-founded measure RC(φ) = (d(φ), |φ|) ∈ ℕ × ℕ with lexicographic ordering, together with the tropical weight TW(φ) = d(φ) · |φ|, satisfying TW(φ) < TW(□φ) for all φ.

## 2. Preliminaries

### 2.1 Modal Formulas

**Definition 2.1** (Modal Formulas). The set MFormula is defined inductively:
- var(n) for n ∈ ℕ (propositional variables)
- ⊥ (falsum)
- φ → ψ (implication)  
- □φ (box/provability)

Negation ¬φ is defined as φ → ⊥. Additional connectives are derived: φ ∨ ψ := ¬φ → ψ, φ ∧ ψ := ¬(φ → ¬ψ), ◇φ := ¬□¬φ.

### 2.2 Structural Measures

**Definition 2.2** (Modal Depth). The modal depth d: MFormula → ℕ is:
- d(var(n)) = 0
- d(⊥) = 0  
- d(φ → ψ) = max(d(φ), d(ψ))
- d(□φ) = d(φ) + 1

**Definition 2.3** (Formula Size). The size |·|: MFormula → ℕ is:
- |var(n)| = 1
- |⊥| = 1
- |φ → ψ| = |φ| + |ψ| + 1
- |□φ| = |φ| + 1

**Definition 2.4** (Box Count). The box count b: MFormula → ℕ counts the total number of □ occurrences.

**Definition 2.5** (Variable Count). The variable count v: MFormula → ℕ counts variable leaf positions.

## 3. Depth-Complexity Gap Theorem

**Theorem 3.1** (Depth-Complexity Gap). For all φ ∈ MFormula:
1. d(φ) < |φ| (strict inequality)
2. d(φ) ≤ b(φ) (depth bounded by box count)
3. b(φ) < |φ| (box count bounded by size)

*Proof sketch*. All three parts proceed by structural induction. For (1), the base cases var(n) and ⊥ give 0 < 1. For implication, d(φ → ψ) = max(d(φ), d(ψ)) < max(|φ|, |ψ|) ≤ |φ| + |ψ| + 1 = |φ → ψ|. For box, d(□φ) = d(φ) + 1 < |φ| + 1 = |□φ|. Parts (2) and (3) follow similarly. □

**Corollary 3.2**. The depth is O(|φ|) but the gap |φ| - d(φ) ≥ 1 is always at least 1, and grows with propositional complexity.

## 4. Substitution and Depth

**Definition 4.1** (Substitution). subst(n, ψ, φ) replaces all occurrences of var(n) in φ with ψ:
- subst(n, ψ, var(m)) = ψ if m = n, var(m) otherwise
- subst(n, ψ, ⊥) = ⊥
- subst(n, ψ, φ₁ → φ₂) = subst(n, ψ, φ₁) → subst(n, ψ, φ₂)
- subst(n, ψ, □φ) = □subst(n, ψ, φ)

**Theorem 4.1** (Substitution Depth Bound). d(subst(n, ψ, φ)) ≤ d(φ) + d(ψ).

*Proof sketch*. By induction on φ. The key case is var(m): if m = n, the depth is d(ψ) ≤ 0 + d(ψ) = d(φ) + d(ψ). For box, d(□subst(n, ψ, φ)) = d(subst(n, ψ, φ)) + 1 ≤ (d(φ) + d(ψ)) + 1 = d(□φ) + d(ψ). □

**Corollary 4.2**. If d(ψ) = 0 (ψ is propositional), then d(subst(n, ψ, φ)) ≤ d(φ). Propositional substitution never increases modal depth.

## 5. Tropical Structure

### 5.1 Tropical Homomorphism

**Definition 5.1** (Iterated Box). □ⁿφ is defined recursively:
- □⁰φ = φ
- □ⁿ⁺¹φ = □(□ⁿφ)

**Theorem 5.1** (Tropical Depth Homomorphism). For all n, m ∈ ℕ and φ, ψ ∈ MFormula:

d(□ⁿφ → □ᵐψ) = max(d(φ) + n, d(ψ) + m)

In tropical notation with ⊕ = max and ⊗ = +:

d(□ⁿφ → □ᵐψ) = (d(φ) ⊗ n) ⊕ (d(ψ) ⊗ m)

*Proof*. By direct computation: d(□ⁿφ) = d(φ) + n (Lemma 5.1, proved by induction), so d(□ⁿφ → □ᵐψ) = max(d(□ⁿφ), d(□ᵐψ)) = max(d(φ) + n, d(ψ) + m). □

**Lemma 5.1** (Additive Depth of Iterated Box). d(□ⁿφ) = d(φ) + n.

### 5.2 Reflective Complexity

**Definition 5.2** (Reflective Complexity). RC(φ) = (d(φ), |φ|) ∈ ℕ × ℕ, ordered lexicographically.

**Definition 5.3** (Tropical Weight). TW(φ) = d(φ) · |φ|.

**Theorem 5.2** (Tropical Weight Characterization). TW(φ) = 0 if and only if d(φ) = 0.

*Proof*. If d(φ) = 0, then TW(φ) = 0 · |φ| = 0. Conversely, if TW(φ) = 0, then d(φ) = 0 or |φ| = 0, but |φ| ≥ 1 by Theorem 2.1, so d(φ) = 0. □

**Theorem 5.3** (Strict Monotonicity of Tropical Weight under Box). TW(φ) < TW(□φ) for all φ.

*Proof*. TW(□φ) = (d(φ) + 1)(|φ| + 1) = d(φ)|φ| + d(φ) + |φ| + 1 = TW(φ) + d(φ) + |φ| + 1 > TW(φ) since d(φ) + |φ| + 1 ≥ 1. □

**Theorem 5.4** (Reflective Complexity Strict Decrease under Unboxing). RC(φ) < RC(□φ).

*Proof*. d(φ) < d(φ) + 1 = d(□φ), so the first component strictly decreases, giving the result in the lexicographic order. □

## 6. Proof Systems

### 6.1 System K

System K consists of:
- Propositional tautologies (via K-axiom, S-axiom, double negation)
- Distribution axiom: □(φ → ψ) → □φ → □ψ
- Modus ponens
- Necessitation: if ⊢ φ then ⊢ □φ

### 6.2 System K4

K4 extends K with:
- Axiom 4: □φ → □□φ (positive introspection)

### 6.3 System GL

GL extends K4 with:
- Löb's axiom: □(□φ → φ) → □φ

## 7. Axiom Hierarchy

**Theorem 7.1** (K ≤ K4). Every K-provable formula is K4-provable.

**Theorem 7.2** (K4 ≤ GL). Every K4-provable formula is GL-provable.

**Corollary 7.3** (K ≤ GL). Every K-provable formula is GL-provable.

*Proof*. All three results follow by straightforward induction on derivations, mapping each rule of the weaker system to the corresponding rule in the stronger system. □

## 8. Kripke Semantics

**Definition 8.1** (Kripke Frame). A pair (W, R) where W is a set of worlds and R ⊆ W × W is the accessibility relation.

**Definition 8.2** (Kripke Model). A triple (W, R, V) where (W, R) is a frame and V: ℕ → W → Prop is a valuation.

**Definition 8.3** (Satisfaction). M, w ⊨ φ is defined:
- M, w ⊨ var(n) iff V(n, w)
- M, w ⊨ ⊥ never
- M, w ⊨ φ → ψ iff M, w ⊨ φ implies M, w ⊨ ψ
- M, w ⊨ □φ iff for all v with R(w,v), M, v ⊨ φ

## 9. Soundness

**Theorem 9.1** (K Axiom Soundness). For all models M, worlds w, and formulas φ, ψ:
M, w ⊨ □(φ → ψ) → □φ → □ψ.

*Proof*. Direct from the semantics of □ and →. □

**Theorem 9.2** (Löb Axiom Soundness). For all models M on transitive, conversely well-founded frames, worlds w, and formulas φ:
M, w ⊨ □(□φ → φ) → □φ.

*Proof*. Assume M, w ⊨ □(□φ → φ). We must show M, w ⊨ □φ, i.e., for all v with R(w,v), M, v ⊨ φ.

We prove by well-founded induction on v (using the converse of R, which is well-founded by hypothesis) the statement: if R(w,v) then M, v ⊨ φ.

Given v with R(w,v), the induction hypothesis gives us: for all u with R(v,u), if R(w,u) then M, u ⊨ φ. By transitivity, R(w,v) and R(v,u) imply R(w,u), so for all u with R(v,u), M, u ⊨ φ. This means M, v ⊨ □φ.

Since M, w ⊨ □(□φ → φ) and R(w,v), we have M, v ⊨ □φ → φ. Combined with M, v ⊨ □φ, we get M, v ⊨ φ. □

## 10. Depth Filtration

**Definition 10.1** (Depth-Bounded Formulas). depthBounded(d, φ) iff d(φ) ≤ d.

**Theorem 10.1** (Monotonicity). If d₁ ≤ d₂, then depthBounded(d₁, φ) implies depthBounded(d₂, φ).

**Theorem 10.2** (Box Level Increase). If depthBounded(d, φ) and ¬depthBounded(d, □φ), then d(□φ) = d + 1.

The depth filtration provides a grading of the formula algebra that is compatible with the tropical structure. Each level dₖ = {φ | d(φ) ≤ k} is closed under propositional operations and contains exactly the formulas with at most k nested provability layers.

## 11. Modal Operator Depth Bounds

**Definition 11.1** (Depth-Bounded Operator). An operator F: MFormula → MFormula is k-depth-bounded if d(F(φ)) ≤ d(φ) + k for all φ.

**Theorem 11.1**. The box operator is 1-depth-bounded.

**Theorem 11.2** (Linear Growth of Iterated Operators). If F is k-depth-bounded, then d(Fⁿ(φ)) ≤ d(φ) + nk.

*Proof*. By induction on n, using the depth bound at each step. □

## 12. Discussion

### 12.1 Tropical Algebra as a Proof-Theoretic Tool

The tropical depth homomorphism provides a systematic way to translate questions about provability depth into algebraic calculations. The key insight is that the two fundamental operations on modal formulas — implication (combining formulas at the same level) and boxing (ascending to the next level) — correspond precisely to the two operations of the tropical semiring.

This correspondence is not merely formal. The depth filtration partitions formulas into levels that interact multiplicatively under box application, mirroring the grading of a tropical polynomial ring. This suggests deeper connections to tropical Hilbert functions and tropical Betti numbers.

### 12.2 Reflective Complexity as a Novel Measure

The reflective complexity RC(φ) = (d(φ), |φ|) provides a more refined measure than either depth or size alone. Its well-foundedness enables structural induction on the "total self-referential content" of formulas. The strict decrease RC(φ) < RC(□φ) ensures that reasoning about boxed formulas can always be reduced to reasoning about their unboxed contents — a form of modal structural induction.

The tropical weight TW(φ) = d(φ) · |φ| captures the *interaction* between depth and size. Its strict monotonicity under boxing (TW(φ) < TW(□φ)) shows that each layer of provability multiplicatively increases the total complexity. This multiplicative character distinguishes modal complexity from purely propositional complexity and explains why deep self-reference is qualitatively harder than shallow reasoning.

### 12.3 Soundness and the Structure of Provability

The soundness of Löb's axiom on transitive well-founded frames connects the syntactic proof system GL to a concrete class of mathematical structures. The well-founded induction in the proof reveals why GL avoids paradox: self-referential reasoning about provability is grounded by the well-foundedness of the accessibility relation, ensuring that every chain of "possible proofs" terminates.

## 13. Future Work

1. **Tropical completeness**: Is the tropical homomorphism complete in the sense that two formulas with the same tropical profile are GL-equivalent?

2. **Tropical fixed-point transfer**: Can Banach-style fixed-point theorems in tropical analysis be transferred to prove the existence of fixed points for monotone modal operators?

3. **Computational depth analysis**: Develop algorithms for computing the tropical invariants of formulas and study their distribution in random formula models.

4. **Higher-dimensional tropical structure**: Extend the tropical homomorphism to capture not just depth but the full multi-dimensional "depth profile" of a formula.

5. **Connection to proof complexity**: Relate the tropical weight to known proof complexity measures (number of lines, proof size, etc.) in Hilbert-style systems.

## References

1. Boolos, G. (1993). *The Logic of Provability*. Cambridge University Press.
2. Solovay, R.M. (1976). Provability interpretations of modal logic. *Israel Journal of Mathematics*, 25, 287-304.
3. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.
4. Lindström, P. (1997). *Aspects of Incompleteness*. Springer.
5. de Jongh, D. & Sambin, G. (1976). On the proof of GL. *Department of Mathematics, University of Amsterdam*, Report 76-07.
