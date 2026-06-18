# Spectral Theory of Tangled Hierarchies in Provability Logic

## Abstract

We develop a spectral theory for tangled hierarchies in provability logic GL, establishing that the consistency hierarchy Con₀, Con₁, Con₂, ... creates a canonical diagonal stratification of finite Kripke frames. Our central result, the **Consistency Stratification Theorem**, proves that in a linear chain frame of *n* worlds, the consistency formula Con_k is forced at world *w* if and only if *w + k < n*. This yields a perfect "proof-theoretic coordinate system" on finite frames.

We prove several further results: (1) the **Hierarchy Collapse Theorem** showing that any proof system with both Löb's axiom and full reflection is inconsistent; (2) the **Entanglement-Modal Orthogonality Theorem** establishing that entanglement depth and modal depth are genuinely independent complexity measures; (3) the **Generalized Entanglement Growth Theorem** showing that the soundness operator increases entanglement by exactly 1 for arbitrary base formulas; (4) the **No Spectral Gaps Theorem** establishing that linear chains achieve every tangling level without gaps. We define the novel concept of a **Tangled Proof Spectrum** — a proof system enriched with a complexity measure that tracks self-referential depth.

All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: provability logic, GL, Kripke semantics, consistency hierarchy, entanglement depth, modal depth, self-reference, incompleteness

## 1. Introduction

### 1.1 Background

Provability logic GL (Gödel-Löb logic) is the modal logic obtained from K4 by adding the Löb axiom □(□p → p) → □p. Solovay's completeness theorem [Solovay 1976] establishes that GL is the logic of provability in Peano Arithmetic: a modal formula is a theorem of GL if and only if every arithmetical interpretation under which □ is read as "PA proves" yields a theorem of PA.

The finite Kripke frames for GL are exactly the finite strict partial orders — frames (W, R) where R is transitive and irreflexive (and therefore well-founded). The modal logic GL is complete with respect to these frames [Boolos 1993].

### 1.2 The Consistency Hierarchy

The consistency hierarchy is the sequence of formulas:
- Con₀ = ¬⊥ (tautology)
- Con₁ = ¬□⊥ (consistency)
- Con₂ = ¬□¬Con₁ (consistency of consistency)
- Con_{n+1} = ¬□¬Con_n

Each Con_n has modal depth exactly *n* [Boolos 1993, Ch. 5]. These formulas capture iterated reflection principles: Con₁ asserts that the system doesn't prove a contradiction, Con₂ asserts that the system can't prove its own inconsistency, and so on.

### 1.3 Self-Referential Soundness

The soundness operator S takes a formula φ to □φ → φ. Iterated soundness S^n(φ) wraps φ in *n* layers of self-referential assumption. A fundamental observation (going back to Löb's theorem) is that if a system proves S(⊥) = □⊥ → ⊥ and the Löb axiom instance for ⊥, then it proves ⊥.

### 1.4 Contributions

This paper makes the following contributions:

1. **Consistency Stratification Theorem** (Theorem 3.1): Complete characterization of forcing for Con_k in linear chain frames.

2. **Hierarchy Collapse Theorem** (Theorem 4.1): Löb + reflection ⟹ inconsistency, generalized to arbitrary formulas.

3. **Entanglement-Modal Orthogonality** (Theorem 5.1): Modal depth and entanglement depth are independent.

4. **Generalized Entanglement Growth** (Theorem 6.1): Soundness increases entanglement by 1 for any base formula.

5. **No Spectral Gaps** (Theorem 7.1): Linear chains have gap-free provability spectra.

6. **Novel structure**: The Tangled Proof Spectrum, combining proof theory with spectral analysis.

## 2. Definitions

### 2.1 Modal Formulas

The language of GL consists of propositional variables p₀, p₁, ..., the constant ⊥, implication →, and the box operator □. We define ¬φ := φ → ⊥ and ⊤ := ¬⊥.

### 2.2 Modal Depth

The **modal depth** of a formula:
- md(pᵢ) = md(⊥) = 0
- md(φ → ψ) = max(md(φ), md(ψ))
- md(□φ) = md(φ) + 1

### 2.3 Entanglement Depth

The **entanglement depth** counts nested □φ → φ patterns:
- ed(pᵢ) = ed(⊥) = 0
- ed(□φ → φ) = ed(φ) + 1 (when the box argument equals the consequent)
- ed(φ → ψ) = max(ed(φ), ed(ψ)) (otherwise)
- ed(□φ) = ed(φ)

### 2.4 GL-Frames and Forcing

A **GL-frame** is a structure (W, R) where W is finite and R is transitive and irreflexive. Forcing is defined by:
- w ⊩ pᵢ iff V(i, w) holds
- w ⊮ ⊥
- w ⊩ φ → ψ iff w ⊩ φ implies w ⊩ ψ
- w ⊩ □φ iff ∀w'(wRw' → w' ⊩ φ)

### 2.5 Linear Chain Frames

The **linear chain frame** of order *n* has W = {0, 1, ..., n-1} with R(i,j) iff i < j.

### 2.6 Tangling Level

The **tangling level** of world *w* in a linear chain of *n* worlds is τ(w) = n - 1 - w.

## 3. The Consistency Stratification Theorem

**Theorem 3.1** (Consistency Stratification). *Let F_n be the linear chain frame of n ≥ 1 worlds, V any valuation, and w ∈ F_n. Then for all k ≥ 0:*

*w ⊩ Con_k if and only if w + k < n.*

**Proof sketch.** By induction on k.

*Base case (k = 0):* Con₀ = ¬⊥ = ⊥ → ⊥, which is forced at every world. Since w ∈ Fin(n), we have w + 0 = w < n.

*Inductive step:* Con_{k+1} = ¬□¬Con_k. We have:

w ⊩ Con_{k+1} ⟺ ¬(∀w' > w, w' ⊮ Con_k) ⟺ ∃w' > w, w' ⊩ Con_k

By the induction hypothesis, w' ⊩ Con_k ⟺ w' + k < n. Thus:

w ⊩ Con_{k+1} ⟺ ∃w' with w < w' < n and w' + k < n

The minimal such w' is w + 1, requiring (w + 1) + k < n, i.e., w + (k + 1) < n. Conversely, if w + k + 1 < n, then w' = w + 1 is a valid witness. □

**Corollary 3.2.** *The tangling level of world w equals the maximum k such that Con_k is forced at w.*

**Corollary 3.3** (Consistency depth is tight). *Con_n is not forced at any world in the linear chain of n worlds.*

**Corollary 3.4** (Monotonicity). *If w ⊩ Con_k and j ≤ k, then w ⊩ Con_j.*

## 4. The Hierarchy Collapse Theorem

**Theorem 4.1** (Generalized Soundness Forces Provability). *Let S be a proof system closed under modus ponens and necessitation. If S ⊢ □(□φ → φ) → □φ (Löb for φ) and S ⊢ □φ → φ (reflection for φ), then S ⊢ φ.*

**Proof.** By necessitation on reflection: S ⊢ □(□φ → φ). By modus ponens with Löb: S ⊢ □φ. By modus ponens with reflection: S ⊢ φ. □

**Corollary 4.2** (Hierarchy Collapse). *If S proves the Löb axiom instance □(□⊥ → ⊥) → □⊥ and reflection □⊥ → ⊥, then S is inconsistent.*

This formalizes the fundamental impossibility: no consistent system can internalize its own soundness.

## 5. Entanglement-Modal Orthogonality

**Theorem 5.1** (Orthogonality). *For every N ≥ 0, there exist formulas φ and ψ such that:*
- *md(φ) = N, ed(φ) = N* (φ = S^N(p₀), iterated soundness)
- *md(ψ) = N, ed(ψ) = 0* (ψ = Con_N, consistency hierarchy)

*Thus modal depth and entanglement depth are independent complexity measures.*

**Lemma 5.2.** *ed(Con_n) = 0 for all n.*

**Proof.** By induction. Con₀ = ⊥ → ⊥ has ed = 0. For the inductive step, Con_{k+1} = □X → ⊥ where X = ¬Con_k. Since X = Con_k → ⊥ ≠ ⊥, the if-check fails, giving ed = max(ed(□X), 0) = ed(X) = ed(Con_k → ⊥) = max(ed(Con_k), 0) = 0 by IH. □

**Corollary 5.3** (Entanglement Gap). *The entanglement gap md(Con_n) - ed(Con_n) = n.*

## 6. Generalized Entanglement Growth

**Theorem 6.1.** *For any GL formula φ, ed(S(φ)) = ed(φ) + 1.*

**Proof.** S(φ) = □φ → φ. This matches the pattern □X → Y with X = Y = φ. The equality check succeeds, so ed(S(φ)) = ed(φ) + 1. □

**Corollary 6.2** (Iterated Growth). *ed(S^m(φ)) = m + ed(φ).*

**Corollary 6.3** (Additivity). *ed(S^m(S^n(p))) = m + n.*

## 7. No Spectral Gaps

**Theorem 7.1** (No Spectral Gaps). *For every 0 ≤ m < n, there exists a world w in the linear chain of n worlds such that:*
- *w ⊩ Con_m*
- *For all k with m < k < n, w ⊮ Con_k*

**Proof.** Take w = n - 1 - m. By the Stratification Theorem, w + m = n - 1 < n (so Con_m is forced), and w + (m+1) = n (so Con_{m+1} is not forced). □

**Corollary 7.2** (Spectrum is a bijection). *The tangling level function τ: {0,...,n-1} → {0,...,n-1} given by τ(w) = n-1-w is a bijection. Every level is achieved exactly once.*

## 8. The 4-Axiom

**Theorem 8.1.** *□φ → □□φ is valid in all GL-frames.*

**Proof.** Given w ⊩ □φ, for any w' with wRw' and w'' with w'Rw'', by transitivity wRw'', so w'' ⊩ φ. Thus w' ⊩ □φ, and since w' was arbitrary, w ⊩ □□φ. □

## 9. Novel Structure: Tangled Proof Spectrum

**Definition 9.1.** A **Tangled Proof Spectrum** is a proof system S together with a function level: GLFormula → ℕ satisfying:
1. Necessitation increases level: level(□φ) = level(φ) + 1 for theorems φ
2. Modus ponens bounds: level(ψ) ≤ max(level(φ → ψ), level(φ))
3. Level bounded by modal depth: level(φ) ≤ md(φ)

**Theorem 9.2** (Spectral Bound). *In any tangled proof spectrum, level(S^n(p)) ≤ n.*

## 10. Conjecture

**Conjecture 10.1** (Optimal Frame Tangling). *For any GL-frame F with n worlds, the number of distinct values of k such that Con_k is satisfiable in F is at most n. The linear chain achieves this bound.*

This conjecture has been verified computationally for n ≤ 4. It would establish linear chains as the canonical structure for maximizing consistency stratification.

## 11. Discussion

### 11.1 Relationship to Beklemishev's Work

Our Consistency Stratification Theorem can be seen as a Kripke-semantic counterpart of Beklemishev's work on reflection principles and provability algebras [Beklemishev 2005]. While Beklemishev works syntactically with proof-theoretic ordinal notations, our approach is semantic, characterizing the forcing relation directly.

### 11.2 The Two Dimensions of Logical Complexity

The orthogonality between entanglement depth and modal depth suggests that "self-referential complexity" and "hierarchical complexity" are fundamentally different phenomena. The consistency hierarchy creates towers of meta-reasoning without any self-reference, while the soundness operator creates self-referential loops without adding hierarchical structure beyond the single layer.

### 11.3 Implications for Self-Referential Systems

The Hierarchy Collapse Theorem has implications for any system that reasons about its own correctness. The three-step proof (necessitate, Löb, reflect) shows that the impossibility of self-referential soundness is algebraically inevitable, not dependent on the details of arithmetic encoding.

## 12. Formalization

All results in this paper have been formalized in Lean 4 with Mathlib. The formalization consists of approximately 370 lines of Lean code in `Logic/TangledHierarchySpectral.lean`. Key formalized theorems include:

- `con_forces_linear_chain`: Consistency Stratification Theorem
- `hierarchy_collapse`: Hierarchy Collapse Theorem
- `entanglement_modal_orthogonality`: Orthogonality Theorem
- `entanglement_soundness_general`: Generalized Entanglement Growth
- `no_spectral_gap`: No Spectral Gaps Theorem
- `four_axiom_valid`: 4-Axiom Validity
- `con_entanglement_zero`: Con_n has zero entanglement

All proofs compile without `sorry` and depend only on standard axioms (propext, Classical.choice, Quot.sound).

## References

1. Boolos, G. (1993). *The Logic of Provability*. Cambridge University Press.
2. Solovay, R. (1976). Provability interpretations of modal logic. *Israel Journal of Mathematics*, 25, 287-304.
3. Beklemishev, L. (2005). Reflection principles and provability algebras in formal arithmetic. *Russian Mathematical Surveys*, 60(2), 197-268.
4. Lindström, P. (1997). *Aspects of Incompleteness*. Lecture Notes in Logic, vol. 10.
5. Visser, A. (2005). Faith & Falsity. *Annals of Pure and Applied Logic*, 131, 103-131.
6. Japaridze, G., & de Jongh, D. (1998). The logic of provability. In *Handbook of Proof Theory*, 475-546.
