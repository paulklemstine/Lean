# Provability Logic GL: A Formal Framework Connecting Algebraic Semantics, Relational Semantics, and the Consistency Hierarchy

## Abstract

We present a rigorous formal framework for provability logic GL (Gödel-Löb logic) that connects three perspectives: *Löb algebras* (algebraic semantics), *GL frames* (relational semantics), and the *consistency hierarchy* (proof-theoretic ordinal structure). Our main results are:

1. **Löb ↔ Well-Foundedness Equivalence**: The semantic Löb property on transitive frames—□((□S)ᶜ ∪ S) ⊆ □S for all S—is equivalent to converse well-foundedness of the accessibility relation. This reveals Löb's axiom as well-founded induction in disguise.

2. **Strict Consistency Hierarchy**: Under Σ₁-soundness, the sequence ⊥ < □⊥ < □²⊥ < □³⊥ < ⋯ is strictly increasing, providing an embedding of ℕ into any nontrivial Σ₁-sound Löb algebra.

3. **Fixed-Point Rigidity**: The only solution to □a = a in a Löb algebra is a = ⊤. This shows that provability is inherently inflationary.

4. **Rosser Separation**: Under Σ₁-soundness, any element g satisfying g ⊓ □g = ⊥ has □g ≠ ⊤.

All results are fully formalized in Lean 4 with Mathlib, with no sorry or non-standard axioms.

## 1. Introduction

Provability logic GL, introduced by Solovay (1976), is the modal logic of the provability predicate in Peano Arithmetic and its extensions. The fundamental axiom of GL is Löb's axiom:

□(□p → p) → □p

which captures the behavior of the Hilbert-Bernays-Löb derivability conditions. Solovay proved that GL is arithmetically complete: a modal formula is a theorem of GL if and only if it is valid under all arithmetical interpretations of □ as the provability predicate of PA.

In this paper, we develop three perspectives on GL and prove their connections:

- **Algebraic**: Löb algebras, where the axiom takes the form "□a ≤ a implies a = ⊤"
- **Relational**: Transitive frames with the semantic Löb property
- **Proof-theoretic**: The consistency hierarchy and its strict monotonicity

### 1.1 Related Work

The algebraic study of provability logic originates with Magari (1975), who introduced *diagonalizable algebras*. Simmons (1988) developed the lattice-theoretic perspective. The Kripke semantics for GL was established by Segerberg (1971), who showed GL is characterized by the class of finite transitive irreflexive frames. The well-foundedness characterization is classical (see Boolos, *The Logic of Provability*, 1993) but to our knowledge has not been previously formalized with full machine-checked proofs.

## 2. Löb Algebras

### 2.1 Definition

**Definition 2.1** (Löb Algebra). A *Löb algebra* is a bounded distributive lattice (L, ⊓, ⊔, ⊥, ⊤) equipped with a unary operator □ : L → L satisfying:
1. □ is monotone: a ≤ b ⟹ □a ≤ □b
2. □⊤ = ⊤
3. □(a ⊓ b) = □a ⊓ □b
4. (Löb) □a ≤ a ⟹ a = ⊤

The Löb axiom (4) encodes Löb's theorem: if provability implies truth, then the statement is a tautology. This is stronger than it appears—it prevents any non-trivial element from being a fixed point of □.

**Remark.** Our axiomatization uses Löb's *theorem* (□a ≤ a ⟹ a = ⊤) rather than Löb's *axiom* (□(□a → a) → □a) as the primitive. In the presence of a Boolean complement, these are equivalent. In the distributive lattice setting, Löb's theorem is the natural choice since it avoids the need for complements.

### 2.2 Fundamental Theorems

**Theorem 2.2** (Gödel's Second Incompleteness, algebraic form). In any nontrivial Löb algebra (⊥ ≠ ⊤), we have □⊥ ≠ ⊥.

*Proof.* If □⊥ = ⊥ then □⊥ ≤ ⊥, so by the Löb axiom, ⊥ = ⊤, contradicting nontriviality. □

**Theorem 2.3** (Fixed-Point Rigidity). In a Löb algebra, if □a = a then a = ⊤.

*Proof.* □a = a implies □a ≤ a, so a = ⊤ by the Löb axiom. □

**Remark.** Fixed-point rigidity means the operator □ has no nontrivial orbits of period 1. This is the algebraic reflection of the fact that there are no non-trivial "self-provable" sentences in PA.

### 2.3 The Σ₁-Soundness Condition

**Definition 2.4** (Σ₁-Soundness). A Löb algebra is *Σ₁-sound* if □a = ⊤ implies a = ⊤ for all a.

This condition is not derivable from the Löb axioms alone. It holds in the Lindenbaum algebra of any Σ₁-sound theory (one that doesn't prove false Σ₁ sentences). Without it, □⊥ = ⊤ is consistent with ⊥ ≠ ⊤, corresponding to inconsistent but "self-aware" theories.

### 2.4 The Strict Consistency Hierarchy

**Definition 2.5.** Define □⁰a = a and □ⁿ⁺¹a = □(□ⁿa).

**Theorem 2.6** (Strict Hierarchy). In a nontrivial Σ₁-sound Löb algebra, □ⁿ⊥ < □ⁿ⁺¹⊥ for all n ∈ ℕ.

*Proof.* The ≤ direction follows by induction: □⁰⊥ = ⊥ ≤ □⊥ = □¹⊥ (by bot_le), and □ⁿ⊥ ≤ □ⁿ⁺¹⊥ implies □ⁿ⁺¹⊥ = □(□ⁿ⊥) ≤ □(□ⁿ⁺¹⊥) = □ⁿ⁺²⊥ by monotonicity.

For strictness, suppose □ⁿ⁺¹⊥ ≤ □ⁿ⊥, i.e., □(□ⁿ⊥) ≤ □ⁿ⊥. By Löb, □ⁿ⊥ = ⊤. But Σ₁-soundness gives □ⁿ⁻¹⊥ = ⊤ (since □(□ⁿ⁻¹⊥) = □ⁿ⊥ = ⊤), and by induction, ⊥ = ⊤, contradicting nontriviality. □

**Corollary 2.7.** The map n ↦ □ⁿ⊥ is a strict order embedding ℕ ↪ L. In particular, any nontrivial Σ₁-sound Löb algebra is infinite.

### 2.5 Rosser Separation

**Definition 2.8** (Rosser Pair). A *Rosser pair* in a Löb algebra is an element g with g ⊓ □g = ⊥.

**Theorem 2.9** (Rosser Separation). In a nontrivial Σ₁-sound Löb algebra, if g ⊓ □g = ⊥ then □g ≠ ⊤.

*Proof.* If □g = ⊤ then g ⊓ ⊤ = ⊥ gives g = ⊥. Then □⊥ = ⊤, and Σ₁-soundness gives ⊥ = ⊤. □

## 3. Transitive Frames and the Löb–WF Equivalence

### 3.1 Definitions

**Definition 3.1** (Transitive Frame). A *transitive frame* is a pair (W, R) where W is a type and R : W → W → Prop is transitive.

**Definition 3.2** (Box on Frames). □S = {w | ∀v, R(w,v) → v ∈ S}.

**Definition 3.3** (Semantic Löb Property). A transitive frame has the *Löb property* if □((□S)ᶜ ∪ S) ⊆ □S for all S ⊆ W.

**Definition 3.4** (Converse Well-Foundedness). A frame is *conversely well-founded* if the relation (fun a b ↦ R b a) is well-founded, i.e., there is no infinite ascending R-chain.

### 3.2 Main Equivalence

**Theorem 3.5** (Löb ↔ Converse Well-Foundedness). A transitive frame has the Löb property if and only if it is conversely well-founded.

This is the central result of the paper. It reveals that Löb's axiom is well-founded induction in disguise.

*Proof (⇐).* Assume converse WF. Fix S, w ∈ □((□S)ᶜ ∪ S), and R(w,v). We show v ∈ S by well-founded induction (on the converse relation) on v. By the inductive hypothesis, all R-successors u of v satisfy u ∈ S (since R(w,u) holds by transitivity). So v ∈ □S. Since w ∈ □((□S)ᶜ ∪ S), we have v ∈ (□S)ᶜ ∪ S. Since v ∈ □S, v ∉ (□S)ᶜ, hence v ∈ S.

*Proof (⇒).* Assume the Löb property. We show converse WF using the equivalent characterization: every nonempty set has a minimal element (w.r.t. the converse relation, i.e., an element with no R-successor in the set).

Suppose A is nonempty with no such minimal element: for every a ∈ A, there exists b ∈ A with R(a,b). Set S = Aᶜ.

For any a ∈ A, we show a ∈ □((□S)ᶜ ∪ S): for any v with R(a,v), either v ∈ A (then v ∉ □S since v has a successor in A ⊆ Sᶜ, so v ∈ (□S)ᶜ) or v ∉ A (so v ∈ S).

By the Löb property, a ∈ □S. But a has an R-successor b ∈ A ⊆ Sᶜ, contradicting a ∈ □S. □

### 3.3 GL Frames

**Definition 3.6** (GL Frame). A *GL frame* is a transitive frame with converse well-foundedness.

**Theorem 3.7.** In a GL frame, the accessibility relation is irreflexive (no world sees itself).

*Proof.* Immediate from well-foundedness. □

## 4. Diagonal Systems

**Definition 4.1** (Diagonal System). A *diagonal system* consists of a type of sentences, a provability predicate, and a diagonal function diag satisfying: Prov(diag f) ↔ Prov(f(diag f)) for all f.

**Theorem 4.2** (Gödel Undecidability). In a diagonal system with a "negation" map neg satisfying Prov(neg s) ↔ ¬Prov(s), the Gödel sentence diag(neg) is undecidable: neither it nor its negation is provable.

*Proof.* If Prov(diag neg), then Prov(neg(diag neg)) by the diagonal property, so ¬Prov(diag neg), contradiction. If Prov(neg(diag neg)), then ¬Prov(diag neg) by the negation property, but also Prov(diag neg) by the diagonal property (applied in reverse), contradiction. □

## 5. The Incompleteness Spectrum

**Definition 5.1.** The *incompleteness spectrum* of a Löb algebra is {a ∈ L | a ≠ ⊥ ∧ a ≠ ⊤}.

**Theorem 5.2.** In a nontrivial Σ₁-sound Löb algebra, □ⁿ⊥ is in the incompleteness spectrum for all n ≥ 1.

*Proof.* □ⁿ⊥ ≠ ⊤ by Σ₁-soundness (Theorem 2.6). □ⁿ⊥ ≠ ⊥: if □ⁿ⊥ = ⊥ then □ⁿ⁻¹⊥ < □ⁿ⊥ = ⊥ by the strict hierarchy, contradicting that ⊥ is the minimum. □

## 6. Algorithms and Computational Aspects

### 6.1 Algorithm: Computing the Consistency Hierarchy

```
INPUT: A finite Löb algebra (L, □) and element a ∈ L
OUTPUT: The orbit (a, □a, □²a, ...) until stabilization

1. Set orbit = [a], current = a
2. Repeat:
   a. next = □(current)
   b. If next ∈ orbit, return orbit (cycle detected)
   c. If next = current, return orbit (fixed point)
   d. Append next to orbit, set current = next
3. Return orbit
```

By fixed-point rigidity, the only fixed point is ⊤. In a finite algebra, the orbit must eventually reach ⊤ or cycle—but by monotonicity and the Löb axiom, cycles are impossible (except at ⊤). So the orbit always terminates at ⊤.

### 6.2 Algorithm: Löb Property Verification

```
INPUT: A finite transitive frame (W, R)
OUTPUT: Whether the frame has the Löb property

1. Compute the converse relation R⁻¹
2. Check if R⁻¹ is well-founded (no cycles, since W is finite)
3. Return True iff R is acyclic
```

For finite frames, converse well-foundedness is equivalent to acyclicity (which implies irreflexivity and the absence of longer cycles). This can be checked in O(|W| + |R|) time using topological sort.

## 7. Discussion

### 7.1 The Role of Σ₁-Soundness

A key finding is that the strict consistency hierarchy requires Σ₁-soundness as an additional axiom beyond the Löb conditions. Without it, □⊥ = ⊤ is consistent with ⊥ ≠ ⊤—corresponding to theories that are inconsistent but "know" they are inconsistent (like PA + ¬Con(PA)). The Löb axiom alone cannot distinguish consistent from inconsistent theories; it only describes the *structure* of provability.

### 7.2 Connections to Ordinal Analysis

The strict embedding ℕ ↪ L via the consistency hierarchy is the beginning of ordinal analysis. In the full picture, the proof-theoretic ordinal of a theory T is the supremum of ordinals α such that T proves the well-ordering of α. The consistency hierarchy ⊥ < □⊥ < □²⊥ < ⋯ corresponds to the first ω levels of this ordinal analysis. Extending to transfinite levels requires Japaridze's polymodal logic GLP, where multiple provability operators □₀, □₁, □₂, ... capture increasingly strong notions of provability.

### 7.3 Fixed-Point Rigidity and Self-Reference

The theorem that □a = a implies a = ⊤ has a philosophical interpretation: in any sufficiently strong formal system, there are no non-trivial "self-provable" sentences. A sentence cannot bootstraps its own provability unless it is already a tautology. This is closely related to the de Jongh-Sambin fixed-point theorem, which states that every modalized formula in GL has a unique fixed point (up to GL-equivalence).

## 8. Future Work

1. **Japaridze's GLP**: Extend the framework to polymodal provability logic with operators □₀, □₁, □₂, ... satisfying □ₙp → □ₙ₊₁p and each □ₙ satisfying the Löb axiom.

2. **Solovay's Completeness**: Prove the arithmetic completeness theorem: GL is complete with respect to the class of finite transitive irreflexive frames.

3. **Ordinal Analysis**: Connect the consistency hierarchy to proof-theoretic ordinals, showing that □^α⊥ for transfinite α captures the ordinal analysis of theories.

4. **Tropical Connection**: Investigate the connection between Löb algebras and tropical semirings, where the idempotent addition a ⊕ a = a plays the role of lattice join.

## References

1. Boolos, G. (1993). *The Logic of Provability*. Cambridge University Press.
2. Solovay, R. (1976). Provability interpretations of modal logic. *Israel Journal of Mathematics*, 25(3-4), 287-304.
3. Magari, R. (1975). The diagonalizable algebras. *Bollettino dell'Unione Matematica Italiana*, 12(3), 117-125.
4. Segerberg, K. (1971). *An Essay in Classical Modal Logic*. Uppsala.
5. Japaridze, G. (1988). The polymodal logic of provability. *Intensional Logics and Logical Structure of Theories*, 16-48.
6. de Jongh, D. & Sambin, G. (1976). On completeness of the Gödel-Löb provability logic. Preprint.
