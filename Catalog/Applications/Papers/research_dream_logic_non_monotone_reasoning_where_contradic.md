# Dream Spaces and Paraconsistent Logic: A Formal Framework for Non-Monotone Reasoning with Coexisting Contradictions

## Abstract

We formalize a mathematical framework connecting paraconsistent logic, non-monotonic reasoning, and pre-topological structures. We introduce *dream spaces* — pre-topological spaces satisfying finite intersection closure but not arbitrary union closure — and prove they strictly generalize topological spaces via a concrete separation theorem. In the logical dimension, we formalize Belnap's four-valued logic, proving the Non-Explosion Theorem (contradictions do not entail arbitrary conclusions) and characterizing the unique self-contradictory truth value. We establish non-monotonicity of closed-world reasoning over Belnap valuations: expanding knowledge provably retracts previously held beliefs. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: Paraconsistent logic, Belnap bilattice, non-monotonic reasoning, pre-topological spaces, dream spaces, formal verification

## 1. Introduction

Classical logic rests on the principle of explosion (*ex falso quodlibet*): from a contradiction P ∧ ¬P, any proposition Q follows. While mathematically clean, this principle renders classical logic inadequate for modeling reasoning systems where contradictions arise naturally — databases with conflicting entries, legal codes with incompatible rules, or the fluid, contradiction-tolerant logic of dream states.

**Paraconsistent logics** weaken the explosion principle, allowing contradictions to coexist without global collapse. The most prominent approach is Belnap's four-valued logic [1], which adds truth values "Both" (simultaneously true and false) and "Neither" (no information) to the classical True and False.

**Non-monotonic reasoning** captures a complementary phenomenon: adding information can retract previously derivable conclusions. Classical logic is monotone (Γ ⊢ φ implies Γ ∪ {ψ} ⊢ φ), but real-world reasoning frequently requires belief revision.

**Pre-topological spaces** are geometric structures satisfying weaker axioms than topological spaces. We call these *dream spaces* when they arise from the semantics of paraconsistent logic.

This paper makes three main contributions:

1. **Formal bilattice theory**: We formalize BelnapVal as a four-element bilattice with knowledge ordering, truth operations (conjunction, disjunction, negation), and prove structural properties including De Morgan laws and distributivity.

2. **Non-explosion and non-monotonicity**: We prove the Non-Explosion Theorem, characterize the unique self-contradictory element, and establish non-monotonicity of closed-world reasoning.

3. **Dream space separation**: We define dream spaces, prove every topological space is a dream space, and construct a concrete dream space (the singleton dream space on ℕ) that is provably not topological.

## 2. Belnap's Four-Valued Logic

### 2.1 The Bilattice Structure

**Definition 2.1** (BelnapVal). The set of Belnap truth values is:

```
BelnapVal = {neither, tt, ff, both}
```

equipped with the *knowledge ordering* ≤_k defined by:
- neither ≤_k v for all v (bottom: no information)
- v ≤_k both for all v (top: maximal, possibly contradictory information)
- tt ≤_k tt, ff ≤_k ff (reflexivity for intermediate elements)

This ordering forms a bounded lattice with:
- **Knowledge join** (kjoin): the least upper bound, combining information from two sources
- **Knowledge meet** (kmeet): the greatest lower bound, extracting common information

**Theorem 2.1** (Lattice Properties). (BelnapVal, ≤_k) is a bounded lattice with bottom `neither` and top `both`. kjoin computes the least upper bound and kmeet the greatest lower bound.

### 2.2 Truth Operations

**Definition 2.2** (Paraconsistent Negation). The negation operation neg : BelnapVal → BelnapVal is defined by:
- neg(neither) = neither
- neg(tt) = ff
- neg(ff) = tt
- neg(both) = both

**Theorem 2.2** (Negation Properties).
1. Negation is an involution: neg(neg(v)) = v for all v.
2. Negation is monotone with respect to ≤_k.
3. De Morgan laws hold: neg(kjoin(a,b)) = kjoin(neg(a), neg(b)) and similarly for kmeet.

**Definition 2.3** (Truth Conjunction and Disjunction). We define tconj (conjunction) and tdisj (disjunction) as generalizations of classical AND and OR to four values. Key properties:
- Both operations are commutative.
- tconj distributes over tdisj: tconj(a, tdisj(b,c)) = tdisj(tconj(a,b), tconj(a,c)).

### 2.3 Designation and the Non-Explosion Theorem

**Definition 2.4** (Designation). A truth value v is *designated* if it contains truth:
- designated(tt) = True
- designated(both) = True
- designated(neither) = False
- designated(ff) = False

**Theorem 2.3** (Non-Explosion). There exists a value v ∈ BelnapVal such that tconj(v, neg(v)) is designated, yet there exists q ∈ BelnapVal with ¬designated(q).

*Proof sketch*. The witness is v = both. We have neg(both) = both, so tconj(both, both) = both, which is designated. Meanwhile, ff is not designated. □

**Theorem 2.4** (Self-Contradiction Characterization). For v ∈ BelnapVal:
designated(tconj(v, neg(v))) ↔ v = both

This is a deeper result: `both` is the *unique* truth value sustaining self-contradiction. In the classical fragment {tt, ff}, no contradiction can be designated. The paraconsistent element is precisely isolated.

## 3. Non-Monotonic Reasoning

### 3.1 The Closed-World Assumption

**Definition 3.1** (CWA Valuation). Given a finite set S of known-true propositions, the closed-world valuation assigns:
- cwaValuation(S, p) = tt if p ∈ S
- cwaValuation(S, p) = ff if p ∉ S

**Theorem 3.1** (Non-Monotonicity of CWA). There exist finite sets S₁ ⊂ S₂ and a proposition p such that:
- neg(cwaValuation(S₁, p)) is designated (¬p holds under CWA with knowledge S₁)
- neg(cwaValuation(S₂, p)) is NOT designated (¬p fails under CWA with knowledge S₂)

*Proof*. Let S₁ = {true}, S₂ = {true, false}, p = false. Under S₁, p ∉ S₁ so cwaValuation(S₁, p) = ff, hence neg(ff) = tt, which is designated. Under S₂, p ∈ S₂ so cwaValuation(S₂, p) = tt, hence neg(tt) = ff, which is not designated. □

This theorem formalizes the intuition that learning new facts can retract old beliefs — a hallmark of non-monotonic reasoning.

## 4. Dream Spaces

### 4.1 Definition and Basic Properties

**Definition 4.1** (Dream Space). A *dream space* on a type α is a structure (α, τ) where τ ⊆ P(α) satisfies:
1. ∅ ∈ τ
2. α ∈ τ (i.e., Set.univ ∈ τ)
3. If s, t ∈ τ then s ∩ t ∈ τ

A dream space is a *Čech pre-topological space* — it satisfies the axioms of a topological space except closure under arbitrary union.

**Definition 4.2** (Topological Dream Space). A dream space is *topological* if additionally:
4. For any S ⊆ τ, ⋃S ∈ τ

**Theorem 4.1** (Embedding). Every topological space (α, T) induces a dream space, and this dream space is topological.

### 4.2 The Singleton Dream Space

**Definition 4.3** (Singleton Dream Space). The *singleton dream space* on ℕ has open sets:
```
τ = {∅, ℕ} ∪ {{n} | n ∈ ℕ}
```

**Theorem 4.2** (Well-formedness). The singleton dream space is indeed a dream space: τ is closed under finite intersection.

*Proof*. The intersection of two distinct singletons {n} ∩ {m} = ∅ ∈ τ. The intersection of a singleton with itself is the singleton. Intersections involving ∅ or ℕ are straightforward. □

### 4.3 The Separation Theorem

**Theorem 4.3** (Separation). The singleton dream space is NOT topological.

*Proof*. Define the family of even singletons: S = {{2k} | k ∈ ℕ}. Each {2k} ∈ τ. Their union is the set of even numbers E = {n | ∃k, n = 2k}. We show E ∉ τ:
- E ≠ ∅ (since 0 ∈ E)
- E ≠ ℕ (since 1 ∉ E)
- E ≠ {n} for any n (since 0 ∈ E and 2 ∈ E, but 0 ≠ 2)

Thus ⋃S ∉ τ, violating the union axiom. □

**Corollary 4.4** (Dream Disjunction Failure). There exists a family S of open sets in the singleton dream space such that each member is open, but ⋃S is not open, not empty, and not the whole space.

This models dream-like reasoning: each individual scenario is locally coherent, but their combination produces something outside the logic's expressive power.

### 4.4 Dream Consequence

**Definition 4.4** (Dream Consequence). Given a dream space (α, τ), we say φ is a *dream consequence* of Γ ⊆ α if every open set containing Γ also contains φ:
```
dreamConsequence(D, Γ, φ) ≡ ∀ s ∈ τ, Γ ⊆ s → φ ∈ s
```

**Theorem 4.5** (Monotonicity of Dream Consequence). Dream consequence is monotone in the premise set: if Γ₁ ⊆ Γ₂ and φ is a dream consequence of Γ₁, then φ is a dream consequence of Γ₂.

**Theorem 4.6** (Dream Consequence Separation). In the singleton dream space, for distinct a ≠ b, b is NOT a dream consequence of {a}. The singleton {a} is an open separator.

This result shows that the singleton dream space has maximal separation power at the point level — each point has its own open neighborhood that excludes all others. The non-topological behavior emerges only at the level of infinite unions.

### 4.5 Dream Morphisms

**Definition 4.5** (Dream Morphism). A *dream morphism* f : (α, τ₁) → (β, τ₂) is a function f : α → β such that f⁻¹(s) ∈ τ₁ for all s ∈ τ₂.

**Theorem 4.7** (Category Structure). Dream spaces and dream morphisms form a category:
- The identity function is a dream morphism.
- The composition of dream morphisms is a dream morphism.

## 5. The Correspondence

The connection between Belnap logic and dream spaces operates through the following conceptual bridge:

1. **Local consistency ↔ finite intersection**: In Belnap's logic, combining a finite number of consistent observations preserves consistency. This corresponds to the finite intersection axiom of dream spaces.

2. **Global inconsistency ↔ union failure**: Infinitely many individually consistent beliefs can produce a globally inconsistent belief state. This corresponds to the failure of arbitrary union in dream spaces.

3. **Paraconsistency ↔ non-topological structure**: The existence of the "Both" truth value, which sustains contradiction without explosion, corresponds to dream spaces that are strictly more general than topological spaces.

4. **Non-monotonicity ↔ closed-world default**: The CWA non-monotonicity theorem shows that belief retraction is a consequence of how default reasoning interacts with expanding knowledge, formalized through Belnap valuations.

## 6. Algorithms

### 6.1 Belnap Evaluation

Given a formula over BelnapVal, evaluation proceeds by structural recursion:
```
eval(atom p, v) = v(p)
eval(¬φ, v) = neg(eval(φ, v))
eval(φ ∧ ψ, v) = tconj(eval(φ, v), eval(ψ, v))
eval(φ ∨ ψ, v) = tdisj(eval(φ, v), eval(ψ, v))
```

Time complexity: O(|φ|) per evaluation.

### 6.2 Dream Space Membership Testing

For the singleton dream space, membership testing is decidable:
```
isOpen(s) ↔ s = ∅ ∨ s = ℕ ∨ ∃n, s = {n}
```

For finite sets, this reduces to checking |s| ∈ {0, 1} or s = universe.

## 7. Discussion and Future Work

### 7.1 Connections to Existing Work

Our dream space construction is related to Čech's pre-topological spaces [2] and Sambin's formal topology [3]. The novelty lies in the explicit connection to paraconsistent logic semantics and the formal machine verification of all results.

The Non-Explosion Theorem and the Separation Theorem together formalize a claim that, to our knowledge, has not been previously machine-verified: that paraconsistent logics correspond to strictly pre-topological geometric structures.

### 7.2 Conjectures

**Conjecture 7.1** (Dream Space Completeness). Every countable dream space arises as the "consistent neighborhood" structure of some Belnap valuation over a countable proposition set.

**Test**: Enumerate all dream spaces on {0, 1, 2, 3} (finite, so computable) and verify each arises from a Belnap valuation.

### 7.3 Future Directions

1. **Metric dream spaces**: Can we define a natural distance function on dream spaces that measures "degree of contradiction"? The knowledge ordering on BelnapVal suggests a metric where `both` and `neither` are equidistant from `tt` and `ff`.

2. **Sheaf theory on dream spaces**: Do dream spaces support a meaningful notion of sheaves? The failure of the union axiom means the gluing lemma fails, but a weakened gluing condition might yield a novel notion of "dream sheaf."

3. **Categorical properties**: Is the category of dream spaces cartesian closed? Does it have a natural internal logic?

## 8. References

[1] N.D. Belnap, "A useful four-valued logic," in *Modern Uses of Multiple-Valued Logic*, 1977.

[2] E. Čech, *Topological Spaces*, revised ed., Wiley, 1966.

[3] G. Sambin, "Some points in formal topology," *Theoretical Computer Science*, vol. 305, 2003.

[4] A. Arieli and A. Avron, "Reasoning with logical bilattices," *Journal of Logic, Language and Information*, vol. 5, 1996.

[5] R. Reiter, "A logic for default reasoning," *Artificial Intelligence*, vol. 13, 1980.
