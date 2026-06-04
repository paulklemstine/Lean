# Non-Well-Founded Proof Systems: Self-Referential Proofs as Fixed Points of Monotone Operators

## Abstract

We introduce **Guarded Recursive Proof Systems (GRPS)**, a novel mathematical framework that treats self-referential proofs as legitimate mathematical objects. A proof system is modeled as a monotone operator F on the complete lattice of sets of propositions. The least fixed point (lfp) of F captures well-founded, grounded proofs; the greatest fixed point (gfp) captures non-well-founded proofs that may involve circular reasoning. We define the **circularity gap** C(F) = gfp(F) \ lfp(F) and prove it is non-empty for natural proof systems. We introduce the notion of **safe** propositions (derivable only when assumed) and **self-referential** propositions (safe but derivable from their own singleton), proving that self-referential propositions are exactly the canonical inhabitants of the circularity gap. We establish structural properties of post-fixed points (closure under arbitrary unions), give approximation sequences converging to lfp and gfp, prove that constant systems have empty gap, and show that the liar paradox is excluded because negation violates monotonicity. All results are machine-verified in Lean 4 with Mathlib.

**Keywords:** Fixed-point theory, self-reference, coinduction, circularity gap, monotone operators, non-well-founded proofs, Knaster-Tarski theorem

## 1. Introduction

### 1.1 Motivation

Self-reference is ubiquitous in mathematics and logic. Gödel's incompleteness theorems, Tarski's undefinability theorem, and Lawvere's fixed-point theorem all exploit self-referential constructions to establish fundamental limits. Yet the treatment of self-reference in proof theory is predominantly negative: self-referential arguments are either paradoxical (the liar) or used instrumentally to prove impossibility results.

We propose a complementary perspective: self-referential proofs as *positive mathematical objects* with their own structure and properties. Our framework places self-referential proofs precisely in the lattice-theoretic gap between the least and greatest fixed points of a derivation operator, allowing us to study them using the well-developed machinery of order theory.

### 1.2 Related Work

Our work builds on several traditions:

- **Non-well-founded sets** (Aczel, 1988): The Anti-Foundation Axiom replaces the Axiom of Foundation, allowing circular membership. Our framework can be seen as a proof-theoretic analog.
- **Coinduction** (Sangiorgi, 2012): The greatest fixed point characterization of non-well-founded proofs is precisely a coinductive definition. Our "self-consistent theory" is a coinductive proof.
- **Knaster-Tarski theorem**: The existence of lfp and gfp for monotone operators on complete lattices is the mathematical foundation of our framework.
- **Paraconsistent logic** (Priest, 2006): Our observation that non-well-founded proofs can "prove" absurdity connects to dialetheia and paraconsistency.

### 1.3 Contributions

1. **A novel mathematical structure** — the circularity gap C(F) = gfp(F) \ lfp(F) — that precisely captures self-referential proofs.
2. **Classification theorems** showing safe, self-referential propositions are the canonical inhabitants of C(F).
3. **Structural results** on post-fixed points (closure under unions, minimality of singletons).
4. **Boundary analysis** distinguishing productive self-reference (monotone) from paradoxical self-reference (anti-monotone).
5. **Complete machine verification** of all results in Lean 4.

## 2. Definitions

### 2.1 Proof Systems

**Definition 2.1** (Proof System). A *proof system* over a type α is a pair P = (derive, mono) where:
- derive : Set α → Set α is the derivation operator
- mono : Monotone(derive) certifies that more assumptions yield more conclusions

The monotonicity condition is the key structural requirement. It ensures that the derivation operator has well-defined fixed points.

**Definition 2.2** (Order Homomorphism). The order homomorphism associated to P is the monotone map F_P : (Set α, ⊆) → (Set α, ⊆) defined by F_P(S) = derive(S).

### 2.2 Well-Founded and Non-Well-Founded Derivability

**Definition 2.3** (Well-Founded Derivability). The set of well-foundedly derivable propositions is:

    wfDeriv(P) = lfp(F_P) = ⋂ { S | derive(S) ⊆ S }

This is the smallest pre-fixed point of F_P — equivalently, the set of propositions reachable by iterating derive from ∅.

**Definition 2.4** (Non-Well-Founded Derivability). The set of non-well-foundedly derivable propositions is:

    nwfDeriv(P) = gfp(F_P) = ⋃ { S | S ⊆ derive(S) }

This is the largest post-fixed point — the set of propositions belonging to some self-consistent theory.

**Definition 2.5** (Circularity Gap). The circularity gap is:

    circGap(P) = nwfDeriv(P) \ wfDeriv(P)

### 2.3 Safety and Self-Reference

**Definition 2.6** (Safe Proposition). A proposition a is *safe* if:

    ∀ S, a ∈ derive(S) → a ∈ S

Safe propositions appear in derivations only when already assumed. They cannot be "created from nothing."

**Definition 2.7** (Self-Referential Proposition). A proposition a is *self-referential* if it is safe and a ∈ derive({a}). It can be derived from its own singleton but not from the empty set.

### 2.4 Post-Fixed and Pre-Fixed Points

**Definition 2.8**. A set S is a *post-fixed point* (self-consistent theory) if S ⊆ derive(S). It is a *pre-fixed point* (closed theory) if derive(S) ⊆ S.

## 3. Main Results

### 3.1 The Gap Existence Theorem

**Theorem 3.1** (wf_sub_nwf). For any proof system P:

    wfDeriv(P) ⊆ nwfDeriv(P)

*Proof.* Direct application of the Knaster-Tarski lfp ≤ gfp inequality. □

**Theorem 3.2** (circGap_nonempty). For the identity system on any inhabited type, circGap is non-empty.

*Proof.* In the identity system (derive(S) = S), every element is self-referential. By Theorem 3.5 below, every self-referential element is in circGap. □

### 3.2 The Safe Classification Theorems

**Theorem 3.3** (safe_not_wfDerivable). If a is safe, then a ∉ wfDeriv(P).

*Proof.* Let W = wfDeriv(P) and consider T = W \ {a}. We show T is a pre-fixed point:
- Take x ∈ derive(T). By monotonicity (T ⊆ W), derive(T) ⊆ derive(W) = W, so x ∈ W.
- If x = a, then a ∈ derive(T), and by safety a ∈ T, but a ∉ T by construction — contradiction.
- So x ≠ a and x ∈ W, hence x ∈ W \ {a} = T.

Since T is a pre-fixed point, lfp ⊆ T = W \ {a}. Hence a ∉ W. □

**Theorem 3.4** (selfRef_in_nwfDeriv). If a is self-referential, then a ∈ nwfDeriv(P).

*Proof.* Since a ∈ derive({a}), the set {a} satisfies {a} ⊆ derive({a}), making it a post-fixed point. By the gfp characterization, {a} ⊆ gfp(F_P). □

**Theorem 3.5** (selfRef_in_circGap). If a is self-referential, then a ∈ circGap(P).

*Proof.* Combine Theorems 3.3 (a ∉ wfDeriv) and 3.4 (a ∈ nwfDeriv). □

### 3.3 Structural Properties

**Theorem 3.6** (postFixedPoints_iUnion_closed). Post-fixed points are closed under arbitrary unions: if S_i ⊆ derive(S_i) for all i, then (⋃_i S_i) ⊆ derive(⋃_i S_i).

*Proof.* Take x ∈ ⋃_i S_i, so x ∈ S_j for some j. Then x ∈ derive(S_j) by hypothesis. Since S_j ⊆ ⋃_i S_i, monotonicity gives derive(S_j) ⊆ derive(⋃_i S_i). Hence x ∈ derive(⋃_i S_i). □

**Corollary 3.7.** The collection of self-consistent theories forms a complete lattice (with unions as joins and the infimum taken as the largest post-fixed point below).

**Theorem 3.8** (selfRef_minimal_witness). If a ∈ derive({a}), then {a} is the smallest post-fixed point containing a.

*Proof.* {a} ⊆ derive({a}) since a ∈ derive({a}). For minimality: any T with a ∈ T satisfies {a} ⊆ T. □

### 3.4 Boundary Analysis

**Theorem 3.9** (liar_no_fixedPoint). There is no proposition P with P ↔ ¬P.

*Proof.* If P holds, then ¬P by the forward direction, contradicting P. If ¬P, then P by the backward direction, contradicting ¬P. □

This theorem explains why the liar paradox is excluded from the GRPS framework: the negation operator ¬ is anti-monotone (P → Q implies ¬Q → ¬P), violating the monotonicity requirement for the existence of fixed points.

### 3.5 System Comparison

**Theorem 3.10** (wfDeriv_mono / nwfDeriv_mono). If derive_P(S) ⊆ derive_Q(S) for all S, then wfDeriv(P) ⊆ wfDeriv(Q) and nwfDeriv(P) ⊆ nwfDeriv(Q).

*Proof.* For lfp: any pre-fixed point of Q is a pre-fixed point of P, so lfp(P) ⊆ lfp(Q). For gfp: any post-fixed point of P is a post-fixed point of Q, so gfp(P) ⊆ gfp(Q). □

### 3.6 Zero-Gap Systems

**Theorem 3.11** (constant_lfp_eq_gfp). For a constant system (derive(S) = T for all S), lfp = gfp = T.

**Theorem 3.12** (constant_circGap_empty). The constant system has empty circularity gap.

### 3.7 Approximation Theory

**Theorem 3.13.** The sequences:
- lfpApprox(0) = ∅, lfpApprox(n+1) = derive(lfpApprox(n))
- gfpApprox(0) = univ, gfpApprox(n+1) = derive(gfpApprox(n))

satisfy:
- lfpApprox is monotone (increasing)
- gfpApprox is antitone (decreasing)
- lfpApprox(n) ⊆ gfpApprox(n) for all n

### 3.8 All-Safe Systems

**Theorem 3.14** (wfDeriv_empty_of_allSafe). If every element is safe, wfDeriv = ∅.

**Theorem 3.15** (circGap_eq_nwf_of_allSafe). If every element is safe, circGap = nwfDeriv.

## 4. Examples and PEGB Analysis

### 4.1 The Identity System (Primary Example)

**P**roof: Every element is self-referential (Theorem identitySystem_allSelfRef), hence in the circularity gap (Theorem selfRef_in_circGap). The gap equals the entire type.

**E**xample: On Bool, the identity system has wfDeriv = ∅, nwfDeriv = {true, false}, circGap = {true, false}. Both `true` and `false` are self-referential: each is "provable" only by assuming itself.

**G**eneralization: The identity system generalizes to any "subidentity" system where derive(S) ⊆ S. Such systems have wfDeriv = ∅ and nwfDeriv = gfp, which is the largest set S with S ⊆ derive(S).

**B**oundary: The identity system is extremal — it has the largest possible circularity gap (the entire type). The constant system is the opposite extremal case — it has zero gap. All proof systems lie between these extremes.

### 4.2 The Union-Axiom System

**P**roof: For unionAxiomSystem(A), derive(S) = S ∪ A. Then lfp = A (the axioms) and gfp = univ (everything is self-consistent with the axioms). The circularity gap is univ \ A — everything that's not an axiom.

**E**xample: With α = ℕ and A = {0, 1}, wfDeriv = {0, 1}, circGap = ℕ \ {0, 1} = {2, 3, 4, ...}.

**G**eneralization: Replace the union with any monotone "enrichment" operator.

**B**oundary: When A = univ, the gap is empty. When A = ∅, we recover the identity system.

### 4.3 The Safe Classification (Primary Theorem)

**P**roof: Theorem selfRef_in_circGap — the culmination of Theorems 3.3-3.5.

**E**xample: In the identity system, the proposition "true" is safe (it appears in derive(S) = S only when in S) and self-referential (true ∈ derive({true}) = {true}). It lives in the gap.

**G**eneralization: The notion of "safe" generalizes to any complete lattice, not just Set α. An element a of a complete lattice L is F-safe if F(x) ≥ a implies x ≥ a for all x. The same classification theorem holds.

**B**oundary: Non-safe elements (axioms) live in wfDeriv, not in the gap. The axiom "1 + 1 = 2" in standard arithmetic is not safe — it can be derived from nothing — and it belongs to wfDeriv, not circGap.

### 4.4 Consistency Asymmetry (Key Insight)

**P**roof: Theorem nwf_bot_of_bot_selfRef + Theorem wf_consistent — the fundamental asymmetry between WF and NWF.

**E**xample: In the identity system, the proposition ⊥ (absurdity) is safe and self-referential. It lives in the circularity gap: ⊥ has a "non-well-founded proof" (the circular proof "⊥ because ⊥") but no well-founded proof. This shows that NWF proofs, unlike WF proofs, can "prove" absurdity.

**G**eneralization: In any proof system where ⊥ is safe, NWF proofs are unsound for ⊥. Guardedness conditions (ordinal-bounded self-reference) are needed to restore consistency.

**B**oundary: If ⊥ is NOT safe (i.e., ⊥ ∈ derive(S) for some S not containing ⊥), then the system is already WF-inconsistent. The safety condition is the boundary between WF-consistency and WF-inconsistency.

## 5. Algorithms

### 5.1 Computing the Circularity Gap

For finite types, the circularity gap is computable:

```
Algorithm ComputeCircularityGap(derive, α):
  Input: monotone derive : P(α) → P(α), finite type α
  
  # Compute lfp by ascending iteration
  S_wf = ∅
  repeat:
    S_wf' = derive(S_wf)
    if S_wf' == S_wf: break
    S_wf = S_wf'
  
  # Compute gfp by descending iteration  
  S_nwf = α
  repeat:
    S_nwf' = derive(S_nwf)
    if S_nwf' == S_nwf: break
    S_nwf = S_nwf'
  
  return S_nwf \ S_wf
```

Complexity: O(|α|²) iterations, each costing O(|α| · T_derive) where T_derive is the cost of one derivation step.

### 5.2 Detecting Self-Referential Elements

```
Algorithm DetectSelfReferential(derive, α):
  for each a in α:
    if a ∈ derive({a}) and a ∉ derive(∅):
      output a as self-referential
```

## 6. Conjectures

### 6.1 Circularity Rank Conjecture

**Conjecture 6.1.** For any finite proof system on Fin(n), the circularity gap is non-empty if and only if there exists a cycle a₁, ..., aₖ such that aᵢ ∈ derive({aᵢ₊₁ mod k}) for all i, and no element of the cycle is in derive(∅).

**Computational test:** Enumerate all monotone operators on P(Fin(3)) and verify the conjecture for n = 3. There are finitely many such operators (bounded by 2^(2^3 · 2^3) but symmetry reduces this dramatically).

### 6.2 Gap Dimension Conjecture

**Conjecture 6.2.** For "generic" monotone operators on Set(Fin n), the circularity gap has cardinality at least n/2.

**Test:** Sample random monotone operators on Fin(n) for n = 4, 6, 8, 10 and measure gap sizes.

## 7. Discussion

### 7.1 Connection to Existing Work

Our framework connects to the catalog result `classical_not_self_sound_with_paradox`, which proves that classical theories cannot be self-sound. Our Theorem 3.9 (liar_no_fixedPoint) provides a complementary perspective: the liar paradox fails because negation is anti-monotone. In paraconsistent settings (as studied in that catalog entry), self-soundness becomes possible precisely because the truth-value algebra admits fixed points for its operations.

### 7.2 Limitations

1. **Finitary iteration:** Our approximation sequences use ℕ-indexing. For operators that are not ω-continuous, transfinite iteration (indexed by ordinals) is needed to reach the actual lfp/gfp. This extension is left for future work.

2. **Guardedness:** We identify the consistency problem with NWF proofs but do not fully develop the guardedness conditions needed to restore consistency. The ordinal-stratified approach (requiring self-references to decrease an ordinal measure) is sketched but not formalized.

3. **Computational content:** Our current framework is classical (uses excluded middle). A constructive version would be valuable for extracting computational content from NWF proofs.

### 7.3 Impact

The circularity gap provides a new mathematical tool for understanding self-reference across domains:
- **Logic:** Classifies which self-referential arguments are valid vs. paradoxical
- **Computer science:** The gap corresponds to recursively-defined values that exist by coinduction
- **Economics:** Self-fulfilling prophecies live in the circularity gap of economic models
- **Biology:** Autocatalytic cycles are self-consistent but not constructively derivable

## 8. References

1. Aczel, P. (1988). *Non-Well-Founded Sets*. CSLI Lecture Notes 14.
2. Barwise, J. & Moss, L. (1996). *Vicious Circles*. CSLI Publications.
3. Davey, B.A. & Priestley, H.A. (2002). *Introduction to Lattices and Order*. Cambridge University Press.
4. Knaster, B. (1928). Un théorème sur les fonctions d'ensembles. *Ann. Soc. Polon. Math.* 6, 133-134.
5. Priest, G. (2006). *In Contradiction*. Oxford University Press.
6. Sangiorgi, D. (2012). *Introduction to Bisimulation and Coinduction*. Cambridge University Press.
7. Tarski, A. (1955). A lattice-theoretical fixpoint theorem and its applications. *Pacific J. Math.* 5(2), 285-309.
