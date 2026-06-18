# Coherent Paradox Systems: Rank Theory and the Paradox-Soundness Duality

## Abstract

We introduce the **Coherent Paradox System (CPS)**, a novel mathematical structure that extends Belnap's four-valued paraconsistent logic with a rank function measuring self-referential depth and a generator function producing higher-rank paradoxes. We prove the **Paradox-Soundness Duality** — that dialectheias (Both-valued sentences) contribute positively to the soundness of a theory rather than undermining it — and establish a complete characterization of the sound provable set as the union of the true set and the dialectheia set. We develop a rank filtration theory showing that paradox orbits consist entirely of dialectheias, prove orbit distinctness via rank separation, establish the duality involution's preservation of paradoxical structure, and provide precise arithmetic relating paradox count to soundness count. All results are formalized and verified in the Lean 4 theorem prover with the Mathlib library.

**Keywords**: Paraconsistent logic, Belnap four-valued logic, dialetheism, self-reference, paradox, fixed points, soundness

---

## 1. Introduction

### 1.1 Background

Since Russell's discovery of his eponymous paradox in 1901, mainstream mathematical logic has treated contradictions as catastrophic. In classical logic, the principle of explosion (*ex falso quodlibet*) ensures that a single contradiction renders a theory trivial — every sentence becomes provable. This has led to elaborate avoidance strategies: type theories, Zermelo-Fraenkel set theory, and various restriction principles designed to prevent paradoxes from arising.

An alternative tradition, beginning with Jaśkowski (1948) and da Costa (1974), and developed extensively by Priest (2006), proposes that contradictions can be *tolerated* within a logical system without catastrophic consequences. In **paraconsistent logic**, the inference rule from `A ∧ ¬A` to arbitrary `B` is rejected, allowing contradictions to be localized.

Belnap (1977) introduced a particularly elegant four-valued semantics with truth values T (true only), F (false only), B (both true and false), and N (neither true nor false). The B value is the key to handling paradoxes: the Liar sentence and Russell's set both receive the value B, and the logic remains non-trivial.

### 1.2 Contributions

We introduce the **Coherent Paradox System (CPS)**, which extends Belnap's framework with:

1. A **rank function** ρ : S → ℕ measuring the self-referential depth of each sentence
2. A **generator function** g : S → S that produces new paradoxes from existing ones
3. Coherence conditions ensuring g preserves dialectheia status and strictly increases rank
4. An injectivity condition on g ensuring distinct paradoxes produce distinct offspring

Our main results include:

- **Paradox-Soundness Duality** (Theorem 4.1): The sound set equals the true set union the dialectheia set
- **Dialectheias Expand Soundness** (Theorem 5.1): Converting a gap to a dialectheia strictly grows the sound set
- **Orbit Totality** (Theorem 7.1): Generator orbits from a dialectheia consist entirely of dialectheias
- **Orbit Distinctness** (Theorem 7.4): Different orbit positions yield distinct sentences
- **Duality Preservation** (Theorem 9.1): The T↔F involution preserves the dialectheia set
- **Paradox-Soundness Arithmetic** (Theorem 10.2): soundCount = trueCount + paradoxCount
- **Four-Value Necessity** (Theorem 13.1): B is the unique at-least-true negation fixed point
- **Spectrum Decomposition** (Theorem 14.1): The four truth-value counts sum to the total

---

## 2. Preliminaries: Belnap's Four-Valued Logic

### 2.1 Truth Values and Operations

**Definition 2.1** (BelnapVal). The set of Belnap truth values is BelnapVal = {T, F, B, N} with:
- **Negation**: neg(T) = F, neg(F) = T, neg(B) = B, neg(N) = N
- **Conjunction**: truth-order meet
- **Disjunction**: truth-order join
- **isTrue**: T ↦ true, B ↦ true, F ↦ false, N ↦ false
- **isFalse**: F ↦ true, B ↦ true, T ↦ false, N ↦ false

Key properties: neg is an involution (neg(neg(v)) = v for all v), and B and N are the fixed points of negation.

### 2.2 The Duality Involution

**Definition 2.2** (Duality). The duality involution dual : BelnapVal → BelnapVal is defined by:
dual(T) = F, dual(F) = T, dual(B) = B, dual(N) = N.

**Proposition 2.3**. The duality satisfies:
1. dual(dual(v)) = v (involution)
2. dual(neg(v)) = neg(dual(v)) (commutes with negation)
3. dual(v).isTrue = v.isFalse (swaps truth and falsity)
4. dual(v) = B ↔ v = B (preserves B)
5. dual(v) = N ↔ v = N (preserves N)

### 2.3 Paraconsistent Theories

**Definition 2.4** (ParaconsistentTheory). A paraconsistent theory over a type S consists of:
- A truth function truth : S → BelnapVal
- Sentence operations sentNeg, sentConj, sentDisj
- Compatibility: truth(sentNeg s) = neg(truth s), etc.

---

## 3. The Coherent Paradox System

**Definition 3.1** (CoherentParadoxSystem). A CPS over a type S extends a paraconsistent theory with:
- rank : S → ℕ (paradox depth)
- generator : S → S (paradox propagation)
- gen_preserves_B: truth(s) = B → truth(generator(s)) = B
- gen_rank_succ: truth(s) = B → rank(generator(s)) = rank(s) + 1
- gen_inj: generator is injective

**Remark 3.2**. The rank function measures self-referential depth. Rank-0 dialectheias are "primitive" paradoxes (e.g., the Liar sentence itself). Higher ranks arise from applying the generator, which can be understood as creating meta-paradoxes: "the sentence that says X is paradoxical" is itself paradoxical at a higher rank.

**Remark 3.3**. The injectivity of the generator ensures that distinct paradoxes produce distinct offspring, preventing the rank hierarchy from collapsing.

---

## 4. The Paradox-Soundness Duality

### 4.1 Fundamental Sets

**Definition 4.1**. For a CPS C, define:
- soundSet(C) = {s | isTrue(truth(s)) = true}
- dialectheiaSet(C) = {s | truth(s) = B}
- gapSet(C) = {s | truth(s) = N}
- trueSet(C) = {s | truth(s) = T}
- falseSet(C) = {s | truth(s) = F}

### 4.2 Main Duality Theorem

**Theorem 4.1** (Paradox-Soundness Duality).
soundSet(C) = trueSet(C) ∪ dialectheiaSet(C).

*Proof sketch*. By extensionality and case analysis on truth(s). A sentence s is in soundSet(C) iff isTrue(truth(s)) = true, which holds iff truth(s) ∈ {T, B} iff s ∈ trueSet(C) ∪ dialectheiaSet(C). □

**Corollary 4.2**. dialectheiaSet(C) ⊆ soundSet(C). Every dialetheia is soundly provable.

**Theorem 4.3** (Four-Way Partition).
trueSet(C) ∪ falseSet(C) ∪ dialectheiaSet(C) ∪ gapSet(C) = univ.

**Theorem 4.4** (Sound Complement Partition).
soundSet(C) ∪ (gapSet(C) ∪ falseSet(C)) = univ, and these two sets are disjoint.

**Interpretation**: The "deficit" of a theory — sentences that cannot be soundly proved — consists entirely of gaps and pure falsehoods. Dialectheias contribute zero deficit. This is the quantitative expression of the Paradox-Soundness Duality.

---

## 5. Dialectheias Expand Soundness

**Theorem 5.1** (Soundness Expansion). Let truth₁, truth₂ : S → BelnapVal agree on all sentences except s₀, where truth₁(s₀) = N and truth₂(s₀) = B. Then:

{s | isTrue(truth₁(s)) = true} ⊂ {s | isTrue(truth₂(s)) = true}

(strict inclusion).

*Proof sketch*. For the subset direction: if truth₁(s) has isTrue = true, then s ≠ s₀ (since isTrue(N) = false), so truth₂(s) = truth₁(s). For strictness: s₀ is in the second set (isTrue(B) = true) but not the first (isTrue(N) = false). □

**Interpretation**: "Upgrading" a truth-value gap to a dialetheia strictly grows the sound set. In classical logic, adding a contradiction is catastrophic. In four-valued logic, it's beneficial — you get more soundly provable sentences, not fewer.

---

## 6. Rank Filtration

**Definition 6.1**. The rank filtration at level n:
F_n = {s | truth(s) = B ∧ rank(s) ≤ n}.

**Theorem 6.1** (Ascending Chain). F_n ⊆ F_{n+1} for all n.

**Theorem 6.2** (Completeness). ⋃_n F_n = dialectheiaSet(C).

**Theorem 6.3** (Soundness). Every F_n is sound: for all s ∈ F_n, isTrue(truth(s)) = true.

**Theorem 6.4** (Generator Maps Levels). If truth(s) = B and rank(s) ≤ n, then generator(s) ∈ F_{n+1}.

---

## 7. Generator Orbits

**Definition 7.1**. The n-th iterate of the generator:
genIterate(C, 0, s) = s; genIterate(C, n+1, s) = generator(genIterate(C, n, s)).

**Theorem 7.1** (Orbit Totality). If truth(s) = B, then truth(genIterate(C, n, s)) = B for all n.

*Proof*. By induction on n, using gen_preserves_B. □

**Theorem 7.2** (Orbit Rank). If truth(s) = B, then rank(genIterate(C, n, s)) = rank(s) + n.

**Theorem 7.3** (Orbit Injectivity). genIterate(C, n, ·) is injective for all n.

**Theorem 7.4** (Orbit Distinctness). If truth(s) = B and m ≠ n, then genIterate(C, m, s) ≠ genIterate(C, n, s).

*Proof*. If genIterate(C, m, s) = genIterate(C, n, s), then by Theorem 7.2, rank(s) + m = rank(s) + n, giving m = n, contradiction. □

**Interpretation**: A single dialectheia seed generates an infinite sequence of distinct dialectheias at strictly increasing ranks. This shows that paradoxes are inherently generative — one paradox implies infinitely many.

---

## 8. The Paradox Core

**Definition 8.1**. The paradox core:
core(C) = {s | truth(s) = B ∧ s ∉ range(generator)}.

Core elements are "primitive" paradoxes not derivable from other paradoxes by the generator.

**Theorem 8.1**. core(C) ⊆ dialectheiaSet(C) ⊆ soundSet(C).

---

## 9. The Duality Involution

**Definition 9.1**. The dual truth assignment: dualTruth(C)(s) = dual(truth(s)).

**Theorem 9.1** (Dialectheia Preservation). dualTruth(C)(s) = B ↔ truth(s) = B.

**Theorem 9.2** (Gap Preservation). dualTruth(C)(s) = N ↔ truth(s) = N.

**Theorem 9.3** (Soundness-Refutability Swap). {s | isTrue(dualTruth(C)(s)) = true} = {s | isFalse(truth(s)) = true}.

**Theorem 9.4** (Involution). dual(dualTruth(C)(s)) = truth(s).

**Theorem 9.5** (Dialectheia = Sound ∩ Refutable).
dialectheiaSet(C) = soundSet(C) ∩ {s | isFalse(truth(s)) = true}.

**Interpretation**: Dialectheias occupy a unique position — they are the sentences that are simultaneously sound-provable AND refutable. The duality involution reveals this as a manifestation of the B value's dual nature.

---

## 10. Paradox Counting

**Definition 10.1**. For finite CPS:
- paradoxCount(C) = |{s | truth(s) = B}|
- soundCount(C) = |{s | isTrue(truth(s)) = true}|
- trueCount(C) = |{s | truth(s) = T}|

**Theorem 10.1** (Soundness Dominates). paradoxCount(C) ≤ soundCount(C).

**Theorem 10.2** (Paradox-Soundness Arithmetic). soundCount(C) = trueCount(C) + paradoxCount(C).

**Theorem 10.3** (Spectrum Decomposition). trueCount + falseCount + paradoxCount + gapCount = |S|.

---

## 11. CPS-Oracle Bridge

**Definition 11.1** (Oracle Hierarchy). A structure (level, oracle) where oracle at level(s) decides s.

**Theorem 11.1**. Every CPS induces an oracle hierarchy via rank.

**Theorem 11.2** (Monotonicity). The induced oracle is monotone: if oracle(m, s) = true and m ≤ n, then oracle(n, s) = true.

---

## 12. Fixed-Point Theorems

**Theorem 12.1** (Paradox Fixed Point). For any B-preserving endomorphism f on truth assignments, the constant-B assignment is a fixed point.

**Theorem 12.2** (Four-Value Necessity). B is the unique BelnapVal satisfying v = neg(v) ∧ isTrue(v) = true.

---

## 13. Conjectures and Future Work

**Conjecture 13.1** (Paradox Density Bound). For a CPS on Fin(n) with n ≥ 4 having all four truth values present: paradoxCount ≤ n - 3.

**Computational Evidence**: For n = 4, the three "non-paradox" slots must accommodate at least one T, one F, and one N, leaving at most 1 for B. For n = 5, at most 2. The conjecture generalizes this pattern.

---

## 14. Discussion

### 14.1 Philosophical Implications

The Paradox-Soundness Duality challenges the received view that contradictions are inherently destructive to formal reasoning. In four-valued logic, the destructive element is not the contradiction (B) but the truth-value gap (N). Gaps and pure falsehoods are the sole contributors to the soundness deficit.

This has implications for the philosophy of mathematics: perhaps the correct response to paradoxes is not avoidance but accommodation. A theory that embraces its paradoxes can be stronger — in a precise, measurable sense — than one that excludes them.

### 14.2 Computational Interpretation

The CPS-Oracle Bridge connects self-reference in logic to the oracle hierarchy in computability theory. This suggests a deep structural parallel: the rank of a paradox plays the same role as the Turing degree of an undecidable problem. Both measure "how far above the decidable/classical one must go."

### 14.3 The Generative Nature of Paradox

Theorem 7.4 (Orbit Distinctness) reveals that paradoxes are inherently generative. A single dialectheia seed produces an infinite chain of distinct dialectheias at increasing ranks. This mirrors the situation in computability theory where the halting problem generates an infinite hierarchy of undecidable problems.

---

## 15. References

1. Belnap, N. (1977). "A useful four-valued logic." In *Modern Uses of Multiple-Valued Logic*, pp. 5-37.
2. Priest, G. (2006). *In Contradiction: A Study of the Transconsistent*. Oxford University Press.
3. da Costa, N. (1974). "On the theory of inconsistent formal systems." *Notre Dame Journal of Formal Logic*, 15(4), 497-510.
4. Jaśkowski, S. (1948). "Propositional calculus for contradictory deductive systems." *Studia Logica*, 24, 143-157.

---

## Appendix: Formalization

All definitions and theorems in this paper have been formalized and verified in Lean 4 with the Mathlib library. The formalization comprises approximately 400 lines of Lean code with complete proofs (no `sorry` statements remain). The key files are:

- `Logic/ParaconsistentParadox.lean` — Foundation: BelnapVal, ParaconsistentTheory
- `Logic/CoherentParadoxSystem.lean` — Novel CPS structure and all main theorems

The proofs use only standard axioms (propext, Classical.choice, Quot.sound).
