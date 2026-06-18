# Formally Verified Paraconsistent Logic: Bilattice Structure, Naive Set Theory, and the Diagonal Paradox Engine

## Abstract

We present a formally verified framework for paraconsistent logic based on Belnap's four-valued semantics (FDE), encompassing three interlocking developments. First, we formalize Dunn's representation theorem, proving that the Belnap bilattice is isomorphic to Bool × Bool and that all logical operations decompose into componentwise Boolean operations on evidence pairs. Second, we construct a model of naive set theory with unrestricted comprehension over Belnap-valued membership, proving that Russell's set exists with B-valued self-membership while the system remains non-trivial. Third, we introduce the Diagonal Paradox Engine — a unified algebraic structure from which all self-referential paradoxes (Liar, Russell, Curry) arise as instances — and prove that any negation-based diagonal engine necessarily produces paradoxical values. All results are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords**: Paraconsistent logic, Belnap four-valued logic, FDE, bilattice, naive set theory, Russell's paradox, Curry's paradox, formal verification, Lean 4

## 1. Introduction

Paraconsistent logics are non-classical logics that tolerate contradictions without collapsing into triviality — that is, they reject the principle of explosion (*ex falso quodlibet*). Among these, Belnap's four-valued logic FDE (First-Degree Entailment) has emerged as a canonical framework, originally motivated by reasoning in databases that may contain conflicting information.

The four truth values of FDE — True (T), False (F), Both (B), Neither (N) — arise naturally from considering two independent dimensions: positive evidence and negative evidence. A proposition may have evidence for it (T), against it (F), both (B), or neither (N). This evidence-based interpretation, formalized by Dunn, reveals that FDE is isomorphic to the product of two classical Boolean algebras.

Despite decades of philosophical and mathematical study, the formal verification of paraconsistent logic has remained largely unexplored. In this paper, we provide:

1. A complete formalization of the Belnap bilattice with both truth and information orderings, including Dunn's representation theorem (Section 3).
2. A model of naive set theory with unrestricted comprehension, where Russell's paradox becomes a theorem rather than a contradiction (Section 4).
3. The Diagonal Paradox Engine: a novel algebraic structure that unifies all negation-based self-referential paradoxes (Section 5).
4. A proof that Curry's paradox is blocked in FDE through the "B-absorption" phenomenon (Section 6).
5. Quantitative results on paradox density in finite models (Section 7).

## 2. Preliminaries

### 2.1 Belnap's Four-Valued Logic

**Definition 2.1** (Belnap Values). The set of truth values is BVal = {T, F, B, N}, equipped with:
- Negation: ¬T = F, ¬F = T, ¬B = B, ¬N = N
- Conjunction: componentwise AND on positive evidence, OR on negative evidence
- Disjunction: componentwise OR on positive evidence, AND on negative evidence
- Material conditional: a → b ≡ ¬a ∨ b

### 2.2 The Two Orderings

The Belnap values carry two natural partial orderings:

**Truth ordering (≤_t)**: F ≤_t N ≤_t T, F ≤_t B ≤_t T, with N and B incomparable.

**Information ordering (≤_i)**: N ≤_i T ≤_i B, N ≤_i F ≤_i B.

Under ≤_t, conjunction is meet and disjunction is join. Under ≤_i, the information join combines evidence and the information meet intersects evidence.

## 3. Dunn's Representation Theorem

### 3.1 The Evidence Pair Decomposition

**Definition 3.1** (Evidence Functions).
- pos : BVal → Bool, where pos(T) = pos(B) = true, pos(F) = pos(N) = false
- neg_ev : BVal → Bool, where neg_ev(F) = neg_ev(B) = true, neg_ev(T) = neg_ev(N) = false

**Definition 3.2** (Dunn Encoding). toPair : BVal → Bool × Bool maps T ↦ (true, false), F ↦ (false, true), B ↦ (true, true), N ↦ (false, false).

**Theorem 3.1** (Dunn's Representation Theorem). The map `dunn_iso : BVal ≃ Bool × Bool` is a bijection, with inverse ofPair.

*Proof*: Direct verification that toPair ∘ ofPair = id and ofPair ∘ toPair = id by case analysis on all four values. □

### 3.2 Operations as Componentwise Boolean Operations

**Theorem 3.2** (Componentwise Conjunction). For all a, b : BVal,
toPair(a ∧ b) = (pos(a) && pos(b), neg_ev(a) || neg_ev(b)).

**Theorem 3.3** (Componentwise Disjunction). For all a, b : BVal,
toPair(a ∨ b) = (pos(a) || pos(b), neg_ev(a) && neg_ev(b)).

These theorems reveal that FDE conjunction/disjunction are simply the product of two classical operations — AND on positive evidence, OR on negative evidence (and vice versa for disjunction). This decomposition immediately implies:

**Theorem 3.4** (De Morgan Laws). For all a, b : BVal,
- ¬(a ∧ b) = ¬a ∨ ¬b
- ¬(a ∨ b) = ¬a ∧ ¬b

### 3.3 Negation as Component Swap

**Theorem 3.5** (Negation Swap). toPair(¬v) = (neg_ev(v), pos(v)).

This shows negation swaps the evidence components without destroying information — it is an information-preserving automorphism.

**Corollary 3.6** (Negation Commutes with Information Operations).
- ¬(a ⊔_i b) = ¬a ⊔_i ¬b
- ¬(a ⊓_i b) = ¬a ⊓_i ¬b

## 4. Naive Set Theory with Unrestricted Comprehension

### 4.1 Paraconsistent Sets

**Definition 4.1** (BSet). A paraconsistent set over universe α is a function S : α → BVal. The membership relation is bmem(x, S) = S(x).

**Definition 4.2** (Comprehension). For any φ : α → BVal, define bComprehension(φ) = φ.

**Theorem 4.1** (Unrestricted Comprehension). For all φ and x, bmem(x, bComprehension(φ)) = φ(x).

This is the key departure from ZF set theory: *every* property defines a set, with no restrictions.

### 4.2 Russell's Set

**Definition 4.3** (Russell Set). Given a universe embedding U : α → BSet α, the Russell set is R = bComprehension(λ x. ¬bmem(x, U(x))).

**Theorem 4.2** (Russell's Fixed Point). If U(r) = R for some r, then ¬bmem(r, U(r)) = bmem(r, U(r)).

*Proof Sketch*: By definition, bmem(r, U(r)) = bmem(r, R) = ¬bmem(r, U(r)). Taking negation of both sides and using double negation gives the result. □

**Corollary 4.3** (Russell B or N). Under the hypotheses of Theorem 4.2, bmem(r, U(r)) ∈ {B, N}.

**Theorem 4.4** (Russell Dialetheia). If additionally pos(bmem(r, U(r))) = true, then bmem(r, U(r)) = B.

### 4.3 Non-Triviality

**Theorem 4.5** (Non-Triviality). There exists a universe U : Fin 3 → BSet(Fin 3) containing a Russell set (with B-valued self-membership) that is non-trivial — it contains sets with purely T-valued and purely F-valued memberships.

*Proof*: Construct U(0) as the Russell set (self-membership B, other memberships T and F), U(1) as the full set (all T), U(2) as the empty set (all F). The Russell set has ¬B = B = bmem(0, U(0)), while U(1) provides T values and U(2) provides F values. □

## 5. The Diagonal Paradox Engine

### 5.1 Definition

**Definition 5.1** (Diagonal Paradox Engine). A diagonal paradox engine over α consists of:
- app : α → α → BVal (self-application operator)
- twist : BVal → BVal (transformation generating the paradox)
- diag : α (the diagonal element)
- fixed_point : app(diag, diag) = twist(app(diag, diag))

**Definition 5.2** (Paradoxical Engine). An engine E is paradoxical if app(diag, diag) ∈ {B, N}.

### 5.2 The Universality Theorem

**Theorem 5.1** (Negation Engines are Paradoxical). If E.twist = bneg, then E is paradoxical.

*Proof*: The fixed-point equation gives v = ¬v where v = app(diag, diag). The only solutions in BVal are B and N. □

### 5.3 Instantiations

**Liar Engine**: Set app(s, _) = truth(s), twist = bneg, diag = L (the Liar sentence). The fixed-point equation becomes truth(L) = ¬truth(L).

**Russell Engine**: Set app = mem (set membership), twist = bneg, diag = R (the Russell set). The fixed-point equation becomes mem(R, R) = ¬mem(R, R).

Both engines are paradoxical by Theorem 5.1.

## 6. Curry's Paradox and B-Absorption

### 6.1 The Absorption Phenomenon

**Theorem 6.1** (B-Absorption). For all q : BVal, B ∧ (B → q) = B.

*Proof*: By the Dunn decomposition, bimpl(B, q) = bor(bneg(B), q) = bor(B, q). Then band(B, bor(B, q)) = B for all q, verified by case analysis. □

This is the mechanism that blocks Curry's paradox. A Curry sentence C asserting "if C then Q" would require truth(C) = bimpl(truth(C), Q). When truth(C) = B, the conditional is self-consistent (bimpl(B, F) = B for Q = F), but applying modus ponens via conjunction only yields B — the explosive conclusion Q never emerges independently.

### 6.2 Failure of Modus Ponens for B

**Theorem 6.2** (Modus Ponens Failure). There exist a, b with pos(a) = true, pos(a → b) = true, but pos(b) = false. Specifically, a = B, b = F.

**Theorem 6.3** (Classical Modus Ponens). If a ∈ {T, F}, pos(a) = true, and pos(a → b) = true, then pos(b) = true.

Together, these show that modus ponens is *surgically* invalidated: it fails precisely and only for B-valued premises, exactly where it would cause explosion.

## 7. Paradox Counting

### 7.1 Quantitative Results

**Definition 7.1** (Paradox Count). For app : Fin n → Fin n → BVal, paradoxCount(app) = |{i | app(i,i) ∈ {B, N}}|.

**Theorem 7.1** (Lower Bound). If S ⊆ Fin n with |S| = k and app(i,i) = ¬app(i,i) for all i ∈ S, then paradoxCount(app) ≥ k.

**Theorem 7.2** (Full Paradox). If app(i,i) = ¬app(i,i) for all i, then paradoxCount(app) = n.

### 7.2 The Paradox Subalgebra

**Theorem 7.3** (Information Subalgebra). The set {B, N} is closed under:
- Negation: ¬B = B, ¬N = N
- Information join: B ⊔_i N = B, N ⊔_i B = B, B ⊔_i B = B, N ⊔_i N = N
- Information meet: similarly closed

However, {B, N} is NOT closed under truth operations: B ∧ N = F, B ∨ N = T. This asymmetry — closure under information operations but escape under truth operations — is the structural reason that paraconsistency is a controlled phenomenon.

**Theorem 7.4** (B-N Interaction). B ∧ N = F and B ∨ N = T. Contradictions and gaps interact to produce classical values.

### 7.3 The Paradox-Bool Isomorphism

**Theorem 7.5**. The paradoxical subsystem {B, N} is isomorphic to Bool, with B ↔ true and N ↔ false. Under information operations, this isomorphism respects the Boolean algebra structure.

## 8. The Fixed-Point Spectrum

**Theorem 8.1** (Negation-Commuting Maps Preserve Paradox). If f : BVal → BVal commutes with negation (f(¬v) = ¬f(v) for all v), then f(B) ∈ {B, N} and f(N) ∈ {B, N}.

*Proof*: Since ¬B = B, we have ¬f(B) = f(¬B) = f(B), so f(B) is a fixed point of negation, hence in {B, N}. Similarly for N. □

This theorem reveals that the paradoxical values are *invariant* under all symmetry-respecting operations — they form an inescapable attractor in the space of negation-equivariant transformations.

## 9. Conjecture

**Conjecture 9.1** (Minimal Paraconsistency). For any n ≥ 2, there exists app : Fin n → Fin n → BVal with paradoxCount(app) = 1, containing exactly one paradoxical element and n-1 classical elements, where the paradoxical element satisfies the negation fixed-point equation.

*Computational Test*: Verified for n = 2 by constructing a concrete model.

## 10. Discussion and Future Work

### 10.1 Connections to Existing Work

Our framework connects to several threads in the Catalog:

- **Fixed-Point Theory**: The diagonal paradox engine is an instance of the general fixed-point constructions in `TropicalGodelSentence.lean`, where idempotent closure operators on Fin n → ℕ have Knaster-Tarski fixed points. Our engine operates on BVal instead of ℕ but shares the diagonal construction.

- **Russell's Set**: The `ParaconsistentParadox.lean` file established the russell_set_fixed_point theorem. Our `russell_exists_B` strengthens this with the positive-evidence criterion and embeds it in the full naive set theory framework.

- **Tropical Incompleteness**: The tropical incompleteness theorem shows that non-identity extensive operators cannot be complete. Our B-absorption theorem is an analogous result: the material conditional cannot be "complete" (valid modus ponens) when paradoxical values are present.

### 10.2 Future Directions

1. **Paraconsistent Arithmetic**: Define natural numbers within the BVal-membership framework and investigate which arithmetic truths remain provable.

2. **Categorical Semantics**: The Dunn isomorphism BVal ≃ Bool × Bool suggests a functorial interpretation where FDE is the product of two copies of classical propositional logic. Formalizing this as a categorical equivalence would connect to the Catalog's categorical work.

3. **Tropical-Paraconsistent Bridge**: The information ordering on BVal (N ≤ T,F ≤ B) mirrors min-plus semiring structures. Investigating whether tropical proof systems can be equipped with Belnap-valued truth would unify the `TropicalGodelSentence.lean` and paraconsistent frameworks.

4. **Quantified FDE**: Extending from propositional to first-order paraconsistent logic, with quantifiers interpreted over BVal-valued domains.

## References

1. Belnap, N.D. (1977). "A useful four-valued logic." In *Modern Uses of Multiple-Valued Logic*, pp. 5–37. Reidel.
2. Dunn, J.M. (1976). "Intuitive semantics for first-degree entailments and 'coupled trees'." *Philosophical Studies*, 29, 149–168.
3. Priest, G. (2006). *In Contradiction: A Study of the Transconsistent*. 2nd ed. Oxford University Press.
4. Arieli, O. and Avron, A. (1996). "Reasoning with logical bilattices." *Journal of Logic, Language and Information*, 5, 25–63.
5. Brady, R.T. (2006). *Universal Logic: An Exposition of a General Theory of Logics*. CSLI Publications.
