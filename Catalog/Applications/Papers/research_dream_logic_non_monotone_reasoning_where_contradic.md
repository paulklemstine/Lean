# Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist

## Abstract

We present a machine-verified formalization of paraconsistent reasoning through Belnap's four-valued logic (FOUR) and its connection to non-topological pre-topological spaces we call *dream spaces*. We establish that FOUR forms a bounded distributive lattice under the truth ordering (Theorem 1), prove that explosion — the classical principle that a contradiction entails every statement — fails in FOUR (Theorem 2), characterize paraconsistency as equivalent to the existence of designated gluts (Theorem 3), and construct a concrete non-topological dream space on the natural numbers (Theorem 4). The Belnap negation is shown to be a De Morgan involution, yielding a full De Morgan algebra. These results formalize the precise algebraic conditions under which contradiction-tolerant reasoning is possible and connect them to topological deficiencies that model incomplete or dream-like spatial reasoning. All results are verified by exhaustive case analysis over finitely many truth values.

---

## 1. Introduction

Classical propositional logic rests on two pillars: *bivalence* (every proposition is true or false) and *explosion* (from a contradiction, everything follows). While these principles produce a mathematically elegant system, they are ill-suited to domains where information is incomplete, contradictory, or both — including database systems with conflicting records, multi-sensor fusion in autonomous agents, and the cognitive phenomenon of dreaming.

Belnap (1977) proposed a four-valued logic, sometimes called FOUR or FDE (First-Degree Entailment), that relaxes bivalence by introducing two additional truth values: **B** (both true and false) and **N** (neither true nor false). The resulting system preserves most algebraic properties of classical logic — distributivity, De Morgan duality, involutive negation — while allowing contradictions to be localized rather than explosive.

In parallel, the notion of a topological space provides the standard mathematical framework for reasoning about "nearness" and continuity. A topology on a set X is a collection of subsets (called open) satisfying: (i) ∅ and X are open, (ii) arbitrary unions of open sets are open, and (iii) finite intersections of open sets are open. Weakening axiom (ii) to closure under finite unions only produces what we call a *dream space* — a pre-topological structure that can model reasoning systems with local but not global coherence.

This paper presents formal proofs of four main results connecting these ideas:

1. **Theorem 1** (`instDistribLattice`): Belnap's FOUR is a bounded distributive lattice under the truth ordering.
2. **Theorem 2** (`explosion_fails`): Explosion fails in FOUR — there exist p, q such that p ∧ ¬p is designated but q is not.
3. **Theorem 3** (`paraconsistency_iff_glut`): Explosion failure is equivalent to the existence of a designated glut.
4. **Theorem 4** (`nat_finite_is_nonTopological`): The finite-or-universal dream space on ℕ is not a topology.

All proofs are verified by exhaustive computation over the four truth values, with the dream space result following from an explicit counterexample (the even numbers).

---

## 2. Definitions

### 2.1 Belnap's Four-Valued Logic

**Definition 2.1** (Truth Values). The set FOUR = {F, N, B, T} consists of four truth values:
- **F** (false only): the proposition is rejected and not supported.
- **N** (neither): no information is available.
- **B** (both): the proposition is both supported and rejected.
- **T** (true only): the proposition is supported and not rejected.

**Definition 2.2** (Truth Ordering). The truth ordering ≤_t on FOUR is defined by the Hasse diagram:

```
        T
       / \
      N   B
       \ /
        F
```

where F ≤_t N, F ≤_t B, N ≤_t T, B ≤_t T, and N, B are incomparable. Formally, a ≤_t b if and only if tmeet(a, b) = a, where tmeet is the lattice meet operation.

**Definition 2.3** (Lattice Operations). The meet (conjunction) and join (disjunction) under the truth ordering are:

| tmeet | F | N | B | T |      | tjoin | F | N | B | T |
|-------|---|---|---|---|      |-------|---|---|---|---|
| **F** | F | F | F | F |      | **F** | F | N | B | T |
| **N** | F | N | F | N |      | **N** | N | N | T | T |
| **B** | F | F | B | B |      | **B** | B | T | B | T |
| **T** | F | N | B | T |      | **T** | T | T | T | T |

**Definition 2.4** (Negation). Belnap negation bneg : FOUR → FOUR is defined by:
- bneg(T) = F, bneg(F) = T, bneg(B) = B, bneg(N) = N.

**Definition 2.5** (Designation). A truth value a ∈ FOUR is *designated* if a = T or a = B. The set of designated values D = {T, B} represents the values accepted as "at least partially true."

**Definition 2.6** (Glut and Gap). A value a is a *glut* if both a and bneg(a) are designated. A value a is a *gap* if neither a nor bneg(a) is designated.

### 2.2 Dream Spaces

**Definition 2.7** (Dream Space). A *dream space* on a set X is a collection τ ⊆ 𝒫(X) satisfying:
1. ∅ ∈ τ and X ∈ τ.
2. If U, V ∈ τ then U ∩ V ∈ τ (closure under finite intersection).
3. If U, V ∈ τ then U ∪ V ∈ τ (closure under *finite* union).

A dream space is a topology if and only if it is additionally closed under *arbitrary* unions.

**Definition 2.8** (Finite-or-Universal Dream Space). On the set ℕ, define:
- dreamOpen(S) iff S is finite or S = ℕ.

---

## 3. Main Results

### 3.1 Theorem 1: FOUR Is a Bounded Distributive Lattice

**Theorem 3.1** (`Belnap.instDistribLattice`, `BoundedOrder Belnap`).
*Under the truth ordering, FOUR is a bounded distributive lattice with bottom element F and top element T.*

*Proof sketch.* Each lattice axiom — reflexivity, transitivity, and antisymmetry of ≤_t; the meet and join properties; and the distributive law — is verified by exhaustive case analysis over all 4 (or 4² or 4³) combinations of truth values. For example, distributivity requires checking that for all a, b, c ∈ FOUR:

a ∨ (b ∧ c) = (a ∨ b) ∧ (a ∨ c)

This amounts to 64 cases, each verified by direct computation. The bounds F ≤_t a ≤_t T hold for all a ∈ FOUR by four direct checks each. ∎

*Significance.* This establishes that Belnap's logic has the same core algebraic structure as classical propositional logic (which is also a bounded distributive lattice over {F, T}). The additional values N and B enrich the lattice without compromising its algebraic properties.

### 3.2 De Morgan Algebra Structure

**Theorem 3.2** (`bneg_bneg`, `bneg_tmeet`, `bneg_tjoin`, `bneg_antitone`).
*Belnap negation is a De Morgan involution: it is involutive (bneg ∘ bneg = id), satisfies both De Morgan laws, and reverses the truth ordering.*

*Proof sketch.* Each property is verified by exhaustive case analysis:
- Involution: bneg(bneg(a)) = a for all a ∈ FOUR (4 cases).
- De Morgan I: bneg(tmeet(a,b)) = tjoin(bneg(a), bneg(b)) for all a, b (16 cases).
- De Morgan II: bneg(tjoin(a,b)) = tmeet(bneg(a), bneg(b)) for all a, b (16 cases).
- Antitone: if a ≤_t b then bneg(b) ≤_t bneg(a) (16 cases with hypothesis filtering). ∎

*Significance.* Together with Theorem 3.1, this shows that (FOUR, tmeet, tjoin, bneg) is a De Morgan algebra — the canonical algebraic structure underlying relevance logic and related paraconsistent systems.

### 3.3 Theorem 2: Explosion Fails

**Theorem 3.3** (`Belnap.explosion_fails`).
*There exist p, q ∈ FOUR such that designated(tmeet(p, bneg(p))) holds but designated(q) does not.*

*Proof sketch.* Take p = B and q = F. Then:
- bneg(B) = B, so tmeet(B, bneg(B)) = tmeet(B, B) = B.
- B is designated (B ∈ {T, B}), so designated(tmeet(p, bneg(p))) holds.
- F is not designated (F ∉ {T, B}), so ¬designated(q) holds. ∎

**Theorem 3.4** (`Belnap.classical_no_contradiction`).
*In the classical fragment {T, F}, contradictions are never designated: for p ∈ {T, F}, ¬designated(tmeet(p, bneg(p))).*

*Proof sketch.* If p = T then tmeet(T, F) = F, which is not designated. If p = F then tmeet(F, T) = F, which is not designated. ∎

*Significance.* Theorem 3.3 demonstrates that FOUR is *paraconsistent*: it tolerates contradiction without explosion. Theorem 3.4 shows that this tolerance arises specifically from the non-classical values — the classical fragment remains explosion-proof because contradictions are impossible in it.

### 3.4 Designation Closure Properties

**Theorem 3.5** (`designated_closed_tmeet`, `designated_closed_tjoin`).
*The designated set D = {T, B} is closed under both tmeet and tjoin.*

*Proof sketch.* By case analysis on the four combinations (T,T), (T,B), (B,T), (B,B):
- tmeet: T∧T=T, T∧B=B, B∧T=B, B∧B=B — all in D.
- tjoin: T∨T=T, T∨B=T, B∨T=T, B∨B=B — all in D. ∎

*Significance.* D forms a sub-semilattice under both operations. This means that designated reasoning is compositionally closed: combining designated premises through conjunction or disjunction always yields a designated conclusion. The logical system does not "leak" non-designated values through valid inferences from designated premises.

### 3.5 Glut and Gap Characterization

**Theorem 3.6** (`glut_iff_B`, `gap_iff_N`).
*B is the unique glut in FOUR and N is the unique gap.*

*Proof sketch.* A value a is a glut iff a ∈ D and bneg(a) ∈ D. Checking all four values: only B satisfies bneg(B) = B ∈ D. Similarly, a is a gap iff a ∉ D and bneg(a) ∉ D; only N satisfies bneg(N) = N ∉ D. ∎

### 3.6 Theorem 3: Paraconsistency Characterization

**Theorem 3.7** (`Belnap.paraconsistency_iff_glut`).
*Explosion failure in FOUR is equivalent to the existence of a designated glut:*

(∃ p q, designated(p ∧ ¬p) ∧ ¬designated(q)) ↔ (∃ a, isGlut(a))

*Proof sketch.*
(⇒) If designated(tmeet(p, bneg(p))) holds, then by case analysis on p, we must have p = B (since for T and F the meet with the negation yields F, which is not designated). Then both p = B and bneg(p) = B are designated, so p is a glut.

(⇐) If a is a glut, then designated(a) and designated(bneg(a)) both hold. Since tmeet(a, bneg(a)) can be computed by cases and a glut must be B (by Theorem 3.6), we get tmeet(B, B) = B which is designated. Taking q = F gives ¬designated(F), completing the witness. ∎

*Significance.* This is the central characterization theorem. It reduces the metalogical property of paraconsistency — a statement about what *cannot be derived* in the logic — to a purely algebraic condition about the existence of a specific kind of element in the truth-value algebra. This provides a clean criterion for designing paraconsistent logics: introduce a designated glut, and explosion fails; remove all designated gluts, and classical behavior is restored.

### 3.7 Theorem 4: A Non-Topological Dream Space

**Theorem 3.8** (`DreamSpace.nat_finite_is_nonTopological`).
*The finite-or-universal dream space on ℕ is not a topology.*

*Proof sketch.* The collection {S ⊆ ℕ : S is finite or S = ℕ} satisfies the dream space axioms:
- ∅ is finite, hence open. ℕ = ℕ, hence open.
- If S, T are open: if either is ℕ then S ∩ T equals the other (open); if both are finite, S ∩ T is finite (open). Similarly for S ∪ T.

However, consider the family of singletons {{2n} : n ∈ ℕ}. Each {2n} is finite, hence open. But their union is the set of even numbers, which is infinite and not equal to ℕ, hence not open. The collection is not closed under arbitrary unions and therefore is not a topology. ∎

*Significance.* This provides a concrete mathematical model for "dream-like" spatial reasoning: a system that correctly processes finite collections of observations but cannot assemble them into certain global conclusions. The even numbers are "locally visible" (each even number is in an open set) but "globally invisible" (the set of all even numbers is not open).

---

## 4. The Bridge: Algebraic Paraconsistency and Topological Deficiency

The two main constructions — Belnap's FOUR and dream spaces — share a common structural pattern. Both are obtained by weakening a single axiom of a classical system:

| Classical System | Weakened Axiom | Result |
|---|---|---|
| Boolean algebra (classical logic) | Bivalence (a ∨ ¬a = ⊤) | De Morgan algebra (Belnap logic) |
| Topological space | Closure under arbitrary unions | Dream space |

In both cases, the weakening introduces the possibility of *local coherence without global coherence*:

- In FOUR, each individual inference step respects the lattice structure, but the global reasoning system tolerates states (gluts) that classical logic would reject.
- In a dream space, each finite collection of open sets behaves topologically, but the global structure permits configurations (infinite unions that are not open) that topology would forbid.

This parallel suggests a deeper categorical connection: functors from the category of De Morgan algebras to the category of dream spaces that preserve the relevant "defect" structures. We leave the formal development of this bridge to future work.

---

## 5. Applications

### 5.1 Inconsistency-Tolerant Databases

In database systems, merging records from multiple sources frequently produces contradictions. A patient may be listed as both "alive" and "deceased" in different subsystems. Under classical logic, any query on such a database would return every possible answer. Under Belnap valuations, the patient's status is assigned the value B, queries about *other* patients proceed normally, and the contradiction is quarantined.

### 5.2 Multi-Agent Belief Fusion

When autonomous agents with different sensors report conflicting observations — one camera detects an obstacle, another does not — a paraconsistent reasoning engine can assign B to the obstacle proposition and continue planning, rather than entering an inconsistent state that blocks all inference.

### 5.3 Dream Cognition Modeling

The dream space construction provides a formal model for the spatial reasoning characteristic of dreams: locally coherent (individual scenes make sense) but globally incoherent (the overall geography is impossible). This connects to theories of dream cognition that emphasize the role of weakened prefrontal control in allowing contradictory spatial representations to coexist.

---

## 6. Related Work

Belnap's original formulation appears in *A Useful Four-Valued Logic* (1977), where the logic is motivated by "computer told" reasoning — how a computer should handle contradictory inputs from different sources. The algebraic treatment as a bilattice was developed by Ginsberg (1988) and Fitting (1991), who showed that FOUR carries two lattice orderings (truth and knowledge) and that the interaction between them governs non-monotonic reasoning.

The connection between paraconsistent logics and topology has been explored by several authors. Mortensen (1995) studied topological models of paraconsistent mathematics. More recently, the framework of neighborhood semantics (Pacuit, 2017) provides a general topological perspective on non-normal modal logics that overlaps with our dream space construction.

The specific construction of pre-topological spaces that fail closure under arbitrary unions appears in the general topology literature (Čech, 1966) under the name "closure spaces" or "pretopological spaces." Our dream space terminology emphasizes the cognitive interpretation.

---

## 7. Discussion

### 7.1 Why "Dream" Logic?

The term is not merely metaphorical. The formal properties of our constructions align with empirical observations about dream cognition:

1. **Local consistency**: Individual dream scenes are internally coherent, just as finite subcollections of a dream space behave topologically.
2. **Global inconsistency**: The overall dream narrative violates physical and logical constraints, just as infinite unions in a dream space may fail to be open.
3. **Contradiction tolerance**: Dreamers accept impossible objects without distress, just as Belnap logic designates contradictory values without explosion.
4. **Non-monotonicity**: Dream beliefs can be retracted (a character changes identity mid-scene), paralleling the non-monotone consequence relation of paraconsistent logics.

### 7.2 The Diamond vs. the Chain

A notable structural feature of FOUR is that it is a *non-chain* lattice: the elements N and B are incomparable under ≤_t. This incomparability is essential. Any bounded distributive lattice on four elements where all elements are comparable (i.e., a total order) would be the chain F < N < B < T (or some relabeling), in which negation could not simultaneously be involutive, order-reversing, and identity on both middle elements. The diamond shape — with its two incomparable middle elements — is the *minimal* lattice structure that supports both gluts and gaps.

This observation connects to the broader theory of De Morgan algebras. Every De Morgan algebra has a "center" consisting of elements fixed by negation; in FOUR, this center is {B, N}. The paraconsistency of FOUR depends on the center intersecting the designated set, while the "gappy" behavior depends on the center intersecting the non-designated set.

### 7.3 Relationship to Other Paraconsistent Systems

Belnap's FOUR is not the only paraconsistent logic. Priest's LP (Logic of Paradox) uses three values {T, B, F} with designated set {T, B} — it has a glut but no gap. Kleene's K3 uses three values {T, N, F} with designated set {T} — it has a gap but no glut, and is therefore *not* paraconsistent (it is paracomplete instead). Our Theorem 3.7 (`paraconsistency_iff_glut`) makes this taxonomy precise: LP is paraconsistent because B is a designated glut; K3 is not paraconsistent because it has no designated glut.

The general pattern suggests a classification theorem: a finite De Morgan algebra is paraconsistent if and only if its center intersects the designated filter. This is a natural generalization of our result that merits further investigation.

### 7.4 Computational Aspects

All proofs in our formalization proceed by exhaustive case analysis over finitely many truth values. While this proof strategy is complete for the specific four-element algebra, it does not scale to parameterized families of many-valued logics. A more algebraic proof strategy — using universal properties of De Morgan algebras and filter theory — would be more informative and would generalize to infinite-valued settings.

The decision procedure implicit in our approach has complexity O(4^k) for checking a property quantified over k variables, which is feasible for the small number of variables in our theorems (at most 3). For verification of logical consequence in FOUR with n propositional variables, the complexity is O(4^n), which is exponential but still finite — a marked contrast with the undecidability of first-order paraconsistent logics.

### 7.5 Dream Spaces and Convergence

The dream space construction raises interesting questions about convergence. In a topology, a sequence converges to a point x if every open neighborhood of x contains a tail of the sequence. In a dream space, the same definition applies, but the weaker open-set structure can produce different convergence behavior. In the finite-or-universal dream space on ℕ, the sequence 0, 2, 4, 6, ... has no convergent subsequence (since the set of even numbers is not open), yet each term is contained in an open set. This "phantom convergence" — where individual terms are locally visible but the limit is globally invisible — provides a precise mathematical model for the dream experience of following a narrative that never quite arrives at its destination.

### 7.6 Limitations

Our formalization treats FOUR as a propositional logic. Extension to first-order or modal paraconsistent logics would require significantly more infrastructure, including careful treatment of quantifier rules in the presence of truth-value gaps and gluts. The dream space construction is similarly limited to a single concrete example; a general theory of dream spaces (including morphisms, products, and compactness analogues) remains to be developed.

The bridge between paraconsistent logic and dream spaces in this paper is primarily conceptual. A more formal categorical correspondence — perhaps through Stone-type duality theorems adapted to De Morgan algebras and dream spaces — would strengthen the connection from analogy to theorem.

---

## 8. Future Work

Several natural extensions present themselves:

1. **Bilattice homomorphisms**: Formalizing the knowledge ordering on FOUR and characterizing which bilattice morphisms preserve paraconsistency.
2. **Dream space completion**: Computing the topological completion of dream spaces and measuring the "topological defect" — the cardinality gap between a dream space and its completion.
3. **Paraconsistent valuations as dream points**: Establishing a formal correspondence where Belnap valuations on a propositional language form a dream space, with non-topological points corresponding to valuations assigning B to infinitely many variables.
4. **Graded paraconsistency**: Defining quantitative measures of how paraconsistent a logic is, based on the proportion or structure of its designated gluts.

---

## 9. References

1. Belnap, N.D. (1977). A useful four-valued logic. In *Modern Uses of Multiple-Valued Logic* (pp. 5–37). Reidel.
2. Fitting, M. (1991). Bilattices and the semantics of logic programming. *Journal of Logic Programming*, 11(2), 91–116.
3. Ginsberg, M.L. (1988). Multivalued logics: A uniform approach to reasoning in artificial intelligence. *Computational Intelligence*, 4(3), 265–316.
4. Mortensen, C. (1995). *Inconsistent Mathematics*. Kluwer Academic Publishers.
5. Pacuit, E. (2017). *Neighborhood Semantics for Modal Logic*. Springer.
6. Čech, E. (1966). *Topological Spaces*. Wiley.

---

## Appendix: File References

All formal proofs are contained in `Bridges/DreamLogic.lean`. Key declarations:

- **Theorem 1**: `Belnap.instDistribLattice` — bounded distributive lattice structure
- **Theorem 2**: `Belnap.explosion_fails` — paraconsistency witness
- **Theorem 3**: `Belnap.paraconsistency_iff_glut` — characterization of explosion failure
- **Theorem 4**: `DreamSpace.nat_finite_is_nonTopological` — non-topological dream space
- **De Morgan laws**: `Belnap.bneg_tmeet`, `Belnap.bneg_tjoin`
- **Glut/gap characterization**: `Belnap.glut_iff_B`, `Belnap.gap_iff_N`
- **Designation closure**: `Belnap.designated_closed_tmeet`, `Belnap.designated_closed_tjoin`
