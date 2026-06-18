# Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist

## Abstract

We formalize Belnap's four-valued logic and establish its key properties as a paraconsistent reasoning system. We prove that the principle of explosion fails (the Non-Explosion Theorem), that De Morgan's laws survive the four-valued generalization, and that Belnap's truth values form a bilattice with two antisymmetric orderings connected by an involutive negation. We introduce *pre-topological spaces* — structures satisfying the finite intersection axiom but not the arbitrary union axiom — and construct a concrete example (dream opens) demonstrating that such structures are strictly weaker than topologies. We define *dream spaces* as Belnap-valued Kripke frames with paradoxical worlds and prove the Dream Coexistence Theorem: contradictory beliefs can coexist without trivializing the logic. Finally, we introduce a *credulous consequence operator* and prove its non-monotonicity: adding contradictory premises can retract previously derivable conclusions.

**Keywords**: paraconsistent logic, Belnap logic, bilattice, pre-topological space, non-monotone reasoning, dream space, four-valued logic

## 1. Introduction

Classical propositional logic is built on the principle of bivalence: every proposition is either true or false. From this principle follows *ex contradictione quodlibet* (ECQ) — from a contradiction, anything can be derived. While ECQ is mathematically convenient, it creates fragile reasoning systems: a single inconsistency in a knowledge base renders it trivial.

Paraconsistent logics address this fragility by denying ECQ while preserving as much classical reasoning as possible. The most prominent system is Belnap's four-valued logic [1], which extends the classical truth values {T, F} with two additional values: B (both true and false) and N (neither true nor false). The value B models genuine contradictions — information that supports both a proposition and its negation — while N models complete ignorance.

In this paper, we:
1. Formalize Belnap's four-valued logic with full semantic definitions (§2)
2. Prove De Morgan's laws hold in the four-valued setting (§3)
3. Prove the Non-Explosion Theorem (§4)
4. Introduce pre-topological spaces and construct dream opens (§5)
5. Define dream spaces and prove the Coexistence Theorem (§6)
6. Prove non-monotonicity of credulous consequence (§7)
7. Establish the bilattice structure of Belnap values (§8)

All results have been formally verified in Lean 4 with Mathlib.

## 2. Belnap's Four-Valued Logic

### 2.1 Truth Values

**Definition 2.1** (BVal). The set of Belnap truth values is BVal = {t, f, both, neither}.

### 2.2 Logical Operations

**Definition 2.2** (Negation). The negation function neg : BVal → BVal is defined by:
- neg(t) = f, neg(f) = t, neg(both) = both, neg(neither) = neither

The key property is that neg(both) = both: a paradoxical value remains paradoxical under negation.

**Definition 2.3** (Conjunction). The conjunction conj : BVal × BVal → BVal acts as the meet in the truth ordering. Notable cases:
- conj(both, both) = both (paradox persists under conjunction)
- conj(both, neither) = f (combining contradiction with ignorance yields falsehood)
- conj(t, x) = x for all x (truth is the identity)

**Definition 2.4** (Disjunction). The disjunction disj : BVal × BVal → BVal acts as the join in the truth ordering. Notable case:
- disj(both, neither) = t (a paradox OR ignorance yields truth, since the paradox contributes a truth component)

### 2.3 Designation

**Definition 2.5** (Designated values). A value v ∈ BVal is *designated* if v = t or v = both. The designated values are those carrying a truth component.

This choice is the semantic foundation of paraconsistency: the value `both` is designated (it carries truth) even though it also carries falsehood. A proposition valued `both` and its negation (also valued `both`) are both accepted.

## 3. De Morgan's Laws

**Theorem 3.1** (De Morgan I). For all a, c ∈ BVal:
```
neg(conj(a, c)) = disj(neg(a), neg(c))
```

**Theorem 3.2** (De Morgan II). For all a, c ∈ BVal:
```
neg(disj(a, c)) = conj(neg(a), neg(c))
```

*Proof.* Both theorems are verified by exhaustive case analysis over BVal × BVal (16 cases each), with each case reducing to definitional equality. □

**Remark.** De Morgan's laws are far from trivial in the four-valued setting. The values `both` and `neither` interact with negation, conjunction, and disjunction in non-obvious ways (e.g., disj(both, neither) = t), yet the De Morgan identities survive exactly. This reflects the deep symmetry of Belnap's design.

### 3.1 Designation Characterizations

**Theorem 3.3** (Conjunction-Designation). conj(a, c) is designated iff both a and c are designated.

**Theorem 3.4** (Disjunction-Designation). disj(a, c) is designated iff at least one of a, c is designated.

These theorems establish that conjunction corresponds to set intersection and disjunction to set union at the level of designated truth sets — the semantic foundation for connecting Belnap logic to topology.

## 4. The Non-Explosion Theorem

### 4.1 Formulas and Entailment

**Definition 4.1** (BForm). Propositional formulas over a variable type V are generated by:
- var(x) for x ∈ V
- neg(φ), conj(φ, ψ), disj(φ, ψ)

**Definition 4.2** (Evaluation). Given a valuation ν : V → BVal, eval(ν, φ) computes the Belnap value of formula φ recursively.

**Definition 4.3** (Entailment). Γ ⊨ φ (semantic consequence) holds iff every valuation that designates all formulas in Γ also designates φ.

### 4.2 Main Result

**Theorem 4.4** (Non-Explosion). There exist formulas p, q such that {p, ¬p} ⊭ q.

*Proof.* Let p = var(0) and q = var(1) over V = Fin 2. Define ν(0) = both, ν(1) = neither. Then:
- eval(ν, p) = both, which is designated ✓
- eval(ν, neg(p)) = neg(both) = both, which is designated ✓  
- eval(ν, q) = neither, which is NOT designated ✗

The valuation ν witnesses that the entailment {p, ¬p} ⊨ q fails. □

**Corollary.** Belnap's four-valued logic is paraconsistent: it denies ECQ.

## 5. Pre-Topological Spaces and Dream Opens

### 5.1 Pre-Topological Spaces

**Definition 5.1** (PreTopology). A pre-topological space (α, isOpen) consists of:
- isOpen : P(α) → Prop
- isOpen(∅) and isOpen(α) (trivial opens)
- isOpen(s) ∧ isOpen(t) → isOpen(s ∩ t) (finite intersection)

Note: we do NOT require closure under arbitrary unions.

**Definition 5.2** (Full topology). A pre-topology is a full topology if for every family S of open sets, ⋃S is also open.

### 5.2 Dream Opens

**Definition 5.3** (Dream opens on Fin 4). A set s ⊆ Fin 4 is a *dream open* if s = ∅, s = Fin 4, or s = {x} for some x.

**Theorem 5.4** (Intersection closure). The dream opens are closed under pairwise intersection.

*Proof sketch.* Case analysis on the two dream opens:
- If either is ∅, the intersection is ∅ (a dream open).
- If either is Fin 4, the intersection is the other (a dream open).
- If both are singletons {x} and {y}: if x = y, the intersection is {x}; if x ≠ y, it's ∅. Both are dream opens. □

**Corollary.** (dreamPreTopology). The dream opens form a pre-topological space.

**Theorem 5.5** (Not a topology). The dream pre-topology is NOT a full topology.

*Proof.* Consider S = {{0}, {1}}. Both are dream opens (singletons). But ⋃S = {0, 1}, which:
- Is not ∅ (contains 0)
- Is not Fin 4 (does not contain 2)  
- Is not a singleton (contains both 0 and 1)

Hence {0, 1} is not a dream open, and the arbitrary union axiom fails. □

### 5.3 Interpretation

Dream opens model *atomic, indivisible beliefs*. Each singleton {x} represents a pure dream-state — a coherent but isolated experience. The failure of union closure captures the phenomenon that combining two individually coherent dream-states may not yield a coherent compound dream-state. "I was flying" and "I was swimming" are each coherent dreams, but "I was flying-or-swimming" is a logical construction without dream-reality.

## 6. Dream Spaces and Coexistence

### 6.1 Dream Spaces

**Definition 6.1** (DreamSpace). A dream space (W, V, val, hasDream) consists of:
- A type W of worlds and V of propositional variables
- A valuation val : W → V → BVal
- A witness hasDream : ∃ w v, val(w, v) = both

### 6.2 The Coexistence Theorem

**Theorem 6.2** (Dream Coexistence). There exists a dream space where:
1. Some proposition is simultaneously true and false (both it and its negation are designated)
2. Some proposition is not designated (the space is non-trivial)

*Proof.* Construct D with W = Fin 1, V = Fin 2, and val(0, v) = both if v = 0, neither if v = 1. Then:
1. At world 0, proposition 0 has value both. Both both and neg(both) = both are designated.
2. At world 0, proposition 1 has value neither, which is not designated. □

**Interpretation.** A dreamer can hold contradictory beliefs about one aspect of their experience (proposition 0 is paradoxically both true and false) while remaining in a state of genuine uncertainty about another aspect (proposition 1 is unknown). The contradiction does not propagate.

## 7. Non-Monotone Consequence

### 7.1 Credulous Consequence

**Definition 7.1** (Credulous beliefs). For a premise set Γ:
```
credulousBeliefs(Γ) = {φ | ∃ν classically clean, ν ⊨ Γ and ν ⊨ φ}
```
where "classically clean" means ν(i) ≠ both for all i.

### 7.2 Non-Monotonicity

**Theorem 7.2** (Non-monotonicity). There exist Γ ⊂ Δ and φ such that φ ∈ credulousBeliefs(Γ) but φ ∉ credulousBeliefs(Δ).

*Proof.* Let p = var(0). Take Γ = {p}, Δ = {p, ¬p}, φ = p.

For φ ∈ credulousBeliefs(Γ): the valuation ν(0) = t, ν(1) = t is classically clean, designates p, and designates φ.

For φ ∉ credulousBeliefs(Δ): suppose ν is classically clean and designates both p and ¬p. Since ν(0) ≠ both and ν(0) is designated, we must have ν(0) = t. But then neg(ν(0)) = neg(t) = f, which is not designated. Contradiction. □

**Interpretation.** Adding a contradiction to a belief set doesn't just fail to add conclusions — it *removes* them. The credulous reasoner, faced with inconsistency, loses confidence in everything. This models the dream dissolution phenomenon: the moment of recognizing an impossibility doesn't make the dreamer omniscient; it makes the dream fall apart.

## 8. Bilattice Structure

### 8.1 Two Orderings

**Definition 8.1** (Truth ordering). a ≤_t c iff a = f, or c = t, or a = c ∈ {both, neither}.

**Definition 8.2** (Information ordering). a ≤_k c iff a = neither, or c = both, or a = c ∈ {t, f}.

**Theorem 8.3** (Truth antisymmetry). The truth ordering is antisymmetric.

**Theorem 8.4** (Information antisymmetry). The information ordering is antisymmetric.

**Theorem 8.5** (Negation reverses truth). If a ≤_t c then neg(c) ≤_t neg(a).

**Theorem 8.6** (Negation preserves information). If a ≤_k c then neg(a) ≤_k neg(c).

These theorems establish that (BVal, ≤_t, ≤_k, neg) forms a bilattice structure where negation acts as an anti-homomorphism on the truth ordering and a homomorphism on the information ordering.

## 9. Combinatorial Conjecture

**Conjecture 9.1**. The number of Belnap valuations on an n × m grid that use the value `both` at least once equals 4^(nm) - 3^(nm).

*Verification.* For n=1, m=2: 4² - 3² = 16 - 9 = 7. This has been computationally verified by exhaustive enumeration in Lean (the `dream_count_bound` theorem).

This conjecture has a natural interpretation: the "dream density" of a reasoning space — the fraction of valuations that contain at least one paradox — approaches 1 as the space grows, since 1 - (3/4)^(nm) → 1.

## 10. Discussion

### 10.1 Significance

Our results formalize three key aspects of dream-like reasoning:

1. **Containment** (Non-Explosion): Contradictions are locally contained and do not propagate globally. This is the foundation of paraconsistent logic.

2. **Geometry** (Pre-Topology): The space of dream-beliefs has a geometric structure that is strictly weaker than classical topology. Beliefs can be consistently intersected but not freely combined by union.

3. **Fragility** (Non-Monotonicity): Dream reasoning is fragile under new information. Adding a contradiction doesn't strengthen beliefs — it weakens them, potentially collapsing the entire belief system.

### 10.2 Related Work

Belnap's four-valued logic [1] was originally designed for computer information systems. Priest's logic of paradox (LP) [2] uses only three values {T, F, B}, sacrificing the "neither" value. Our formalization follows Belnap's original four-valued design.

Pre-topological spaces were studied by Čech [3] under the name "closure spaces." Our contribution is connecting them to paraconsistent logic through the dream opens construction.

Non-monotone reasoning has been extensively studied in AI [4], but typically using default logic or circumscription. Our credulous consequence operator provides a paraconsistent alternative.

### 10.3 Limitations

The dream_count_bound theorem is verified only for specific small cases. A general proof for arbitrary n, m would require more sophisticated combinatorial reasoning about subtypes of function spaces.

The pre-topology construction (dream opens) is artificial. A more natural construction, deriving pre-topological structure from the semantic structure of Belnap logic itself, remains an open problem.

## 11. Future Work

1. **Full bilattice formalization**: Complete the lattice structure with meet/join operations and prove distributivity properties.

2. **Infinite dream spaces**: Extend to infinitary logics and study the resulting pre-topological spaces.

3. **Category of dream spaces**: Define morphisms between dream spaces and study the resulting category.

4. **Applications to AI**: Implement paraconsistent belief revision systems based on credulous consequence.

5. **Modal dream logic**: Add a modal operator □ for "stably believed" and study the resulting S4-like system.

## References

[1] N. Belnap. "A useful four-valued logic." In: Modern Uses of Multiple-Valued Logic. D. Reidel, 1977.

[2] G. Priest. In Contradiction: A Study of the Transconsistent. Oxford University Press, 2006.

[3] E. Čech. Topological Spaces. Wiley, 1966.

[4] G. Brewka, J. Dix, K. Konolige. Nonmonotonic Reasoning: An Overview. CSLI Publications, 1997.

## Appendix: Formal Verification

All theorems in this paper have been formally verified in Lean 4 with Mathlib. The formalization consists of approximately 360 lines of Lean code in `Shared/DreamLogic.lean`. Key formal artifacts:

- `BVal` — inductive type with constructors t, f, both, neither
- `BForm` — inductive type for propositional formulas
- `PreTopology` — structure with open-set axioms (without union closure)
- `DreamSpace` — structure for Belnap-valued Kripke frames
- 10 formally verified theorems with no sorry or non-standard axioms
