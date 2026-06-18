# Future Directions: Intrinsically Typed Higher-Order Rewriting with βη-Completion

## Synthesis

The development of intrinsically typed higher-order rewriting modulo βη establishes three foundational results: substitution functoriality, η-stability under substitution, and quotient descent of equational generation. These create a platform from which several research programs naturally emerge. The substitution category structure connects to categorical semantics (Direction 1), the η-stability theorem enables certified completion algorithms (Direction 2), the quotient descent result opens normalization-by-evaluation (Direction 3), the intrinsic typing methodology generalizes to dependent types (Direction 4), and the entire framework bridges to denotational semantics via cartesian closed categories (Direction 5). These directions share a common theme: the intrinsic typing discipline that eliminated side conditions in our η-stability proof should similarly eliminate side conditions in related areas, producing cleaner and more powerful theories.

---

## Direction 1: Certified Higher-Order Knuth-Bendix Completion Modulo βη

**Conjecture:** There exists a terminating Knuth-Bendix completion procedure for finite, left-linear, simply typed rewrite systems modulo βη-equivalence that produces a convergent system whenever one exists, with all intermediate steps verified against the βη-quotient descent theorem.

**Test:** Implement the procedure for rewrite systems of order ≤ 2 with at most 5 rules and left-hand sides of size ≤ 10. Run on the standard test suite of higher-order rewrite systems (Nipkow 1991, Mayr-Nipkow 1998). The procedure should terminate on all 25+ known convergent systems and produce correct normal forms matching those of established implementations.

**Impact:** This would be the first certified higher-order completion procedure that handles extensionality. Current implementations (HOPS, Wanda) either ignore η or handle it informally. A certified version would enable trustworthy optimization of functional programs and automated equational reasoning in proof assistants.

**Catalog References:**
- `Pythagorean/HigherOrderCompletion.lean`: `master_pipeline` provides the untyped completion architecture
- `Pythagorean/ConcreteTermAlgebra.lean`: `concrete_completion_correct` provides the first-order correctness template
- `Pythagorean/IntrinsicBetaEta.lean`: `hoEqGen_respects_betaEta` provides the quotient descent foundation

**Proof Strategy:** Use the βη-stable theory structure (`BetaEtaStableTheory`) as the invariant. At each completion step, verify that new rules maintain the βη-stability property. The quotient descent theorem (`betaEtaStable_quotient_descent`) ensures that critical pairs computed modulo βη are well-defined. For termination, adapt the decreasing interpretation approach of Jouannaud-Rubio to the intrinsically typed setting.

**Domain Bridges:** Automated theorem proving (certified ATP), compiler verification (verified optimizer), algebraic specification (modular equational reasoning).

**Lineage:** This directly extends `HigherOrderCompletion.lean`'s pipeline with the extensional closure from `IntrinsicBetaEta.lean`.

**Ambition:** *Grand challenge.* A working certified completion procedure modulo βη would be a breakthrough in automated deduction.

The key insight is that the quotient descent theorem transforms the completion problem from "find rewrite rules on syntax" to "find rewrite rules on βη-equivalence classes," which is the mathematically correct formulation but was previously inaccessible to formal verification.

Why now? The combination of intrinsic typing (which eliminates side conditions) and the substitution category structure (which provides the algebraic backbone) makes a certified implementation feasible for the first time. Prior attempts failed because the βη-quotient was not formally established as a well-defined domain for equational reasoning.

---

## Direction 2: Normalization-by-Evaluation for Intrinsically Typed Terms

**Conjecture:** There exists an NbE algorithm for simply typed λ-calculus that is formally provably correct (normalization ∘ reflect = id on normal forms, and reify ∘ eval = normalize) using only the substitution category structure and βη-stability, without requiring a separate logical relation argument.

**Test:** Implement NbE in Lean 4 for simply typed λ-calculus with base types and function types. Verify that it computes the βη-normal form for all terms of size ≤ 15 and types of order ≤ 3. Compare performance (reduction steps to normal form) against leftmost-outermost normalization.

**Impact:** A formally verified NbE algorithm would be directly usable as the normalization engine for proof assistants, replacing the current unverified implementations.

**Catalog References:**
- `Pythagorean/IntrinsicBetaEta.lean`: `subst_comp`, `compSub_assoc` provide the categorical infrastructure
- `Pythagorean/IntrinsicBetaEta.lean`: `betaEtaEq_closed_under_subst` provides stability

**Proof Strategy:** Model the semantic domain as a presheaf over the renaming category (following Altenkirch-Hofmann-Streicher). Define `eval : Tm Γ A → Sem Γ A` and `reify : Sem Γ A → Nf Γ A` where `Sem` is the presheaf model and `Nf` is the type of normal forms. The key lemma is that `eval` respects βη-equivalence, which follows from `betaEtaEq_closed_under_subst`.

**Domain Bridges:** Type theory (kernel normalization), programming languages (partial evaluation), category theory (presheaf semantics).

**Lineage:** Extends the substitution category from `IntrinsicBetaEta.lean` to its presheaf completion.

**Ambition:** *Solid extension.* NbE for simply typed λ-calculus is well-understood informally; the challenge is the formal verification.

The key insight is that the substitution category laws (`compSub_assoc`, identity laws) provide exactly the algebraic structure needed for the presheaf semantics that underlies NbE, so no additional infrastructure is needed.

Why now? The formally verified substitution category eliminates the most tedious part of NbE correctness proofs: the renaming/substitution interaction lemmas. With these in hand, the remaining proof obligations become manageable.

---

## Direction 3: Parallel βη-Reduction and Confluence

**Conjecture:** There exists a parallel βη-reduction relation on intrinsically typed terms that satisfies the diamond property: if t ⇒ u₁ and t ⇒ u₂, then there exists v with u₁ ⇒ v and u₂ ⇒ v. Moreover, this parallel reduction is substitution-stable.

**Test:** Define parallel βη-reduction, formalize the complete development lemma, and verify the diamond property on all pairs (t, u₁, u₂) with t of size ≤ 10. Check that the proof method (Takahashi's "complete development" technique) extends to the typed setting without new difficulties.

**Impact:** A typed confluence proof would be the foundation for a certified type-checker where definitional equality is decidable by normalization.

**Catalog References:**
- `Pythagorean/IntrinsicBetaEta.lean`: `beta_closed_under_subst`, `eta_closed_under_subst` are the one-step stability results that the parallel version must generalize

**Proof Strategy:** Define parallel reduction `ParRed : Tm Γ A → Tm Γ A → Prop` that allows simultaneous reduction of all redexes. Prove substitution stability by combining `beta_closed_under_subst` and `eta_closed_under_subst` in a parallel fashion. The diamond property follows from showing that the "complete development" (reducing all redexes simultaneously) is the maximum of the reduction partial order.

**Domain Bridges:** Rewriting theory (abstract confluence), type theory (decidable definitional equality), concurrency (Church-Rosser as a consistency property).

**Lineage:** Directly generalizes the one-step stability results from `IntrinsicBetaEta.lean`.

**Ambition:** *Solid extension.* The technique is well-known, but the intrinsic typing should simplify the proof.

The key insight is that intrinsic typing should make the "complete development" construction simpler because the types prevent ill-formed intermediate terms, eliminating several case splits that plague the untyped proof.

Why now? With the one-step stability theorems in hand, the parallel version requires "only" the simultaneous case, which is technically demanding but conceptually clear.

---

## Direction 4: Dependent Types and Substitution Calculi

**Conjecture:** The substitution category structure and βη-quotient descent theorem extend to a dependently typed calculus (at minimum, a predicative Martin-Löf type theory with Π, Σ, and a universe), with the key innovation being that type-level substitution uses the same composition law as term-level substitution.

**Test:** Formalize the syntax of a minimal dependently typed calculus with intrinsic typing. Prove `subst_comp` at both the type and term level. Verify on 50+ terms that the composition law holds for both term-level and type-level substitutions.

**Impact:** This would be a major step toward a fully verified core for proof assistants like Lean, Coq, and Agda, where the substitution calculus is the most error-prone component.

**Catalog References:**
- `Pythagorean/IntrinsicBetaEta.lean`: The entire development serves as the simply typed prototype

**Proof Strategy:** Define a mutual inductive family `Ty : Ctx → Type` and `Tm : (Γ : Ctx) → Ty Γ → Type` where contexts are telescopes. The substitution must act simultaneously on types and terms. The key challenge is that `liftSub` for dependent types requires a proof that the lifted substitution preserves the type of the variable, which involves a transport along the substitution's action on types.

**Domain Bridges:** Type theory (kernel implementation), homotopy type theory (substitution in HoTT), algebraic topology (fibered categories).

**Lineage:** Extends all results of `IntrinsicBetaEta.lean` to the dependent setting.

**Ambition:** *Grand challenge.* Dependent type theory substitution is one of the hardest problems in formal metatheory.

The key insight is that our substitution category laws should serve as the "simply typed template" that reveals the essential algebraic structure, making the dependent generalization more systematic than starting from scratch.

Why now? The simply typed development demonstrates that the intrinsic approach produces clean, provable substitution laws. The dependent extension is the natural next step, and the community has been converging on the right formulations (categories with families, natural models, comprehension categories).

---

## Direction 5: Cartesian Closed Structure and Denotational Semantics

**Conjecture:** The syntactic substitution category enriched with the term presheaf and βη-quotient forms an initial cartesian closed category (CCC), and the initiality proof can be given using only the algebraic laws established in `IntrinsicBetaEta.lean` plus the universal property of the βη-quotient.

**Test:** Define the CCC structure (products, exponentials, evaluation, currying) on the syntactic category. Verify the universal property computationally by checking that for every CCC with an interpretation of the base types, there is a unique structure-preserving functor from the syntactic CCC.

**Impact:** This would provide the definitive connection between syntax and semantics for the simply typed λ-calculus, showing that our formal development captures exactly the "free CCC" construction. It would also provide a template for denotational semantics of programming languages based on categorical models.

**Catalog References:**
- `Pythagorean/IntrinsicBetaEta.lean`: `compSub_assoc`, `compSub_idSub_left/right` provide the category
- `Pythagorean/IntrinsicBetaEta.lean`: `minBetaEta_hoEqGen_iff_betaEtaEq` characterizes the quotient

**Proof Strategy:** Define context extension `Γ.A` as `A :: Γ`, weakening projection `p : Sub (A :: Γ) Γ`, and the generic variable `q : Tm (A :: Γ) A`. Show these satisfy the CCC axioms using `subst_comp` and the lifting lemmas. For the exponential, use `lam` and `app` with `beta_closed_under_subst` and `eta_closed_under_subst` to verify the β and η equations.

**Domain Bridges:** Category theory (CCC theory), programming language semantics (denotational semantics), logic (categorical logic, Lambek-Scott).

**Lineage:** The categorical interpretation of the substitution laws from `IntrinsicBetaEta.lean`.

**Ambition:** *Solid extension with paradigm-shifting implications.* While the CCC construction for STLC is classical, a fully formal version using intrinsic typing would be new and would serve as a foundation for certified denotational semantics.

The key insight is that our substitution category is not just *a* category — it should be the *initial* CCC generated by the base types, which is the precise sense in which "syntax is the free algebra of meaning."

Why now? The formal substitution laws and βη-quotient characterization provide exactly the raw material needed. The only missing pieces are the CCC axiom verifications, which should follow from the existing infrastructure with moderate effort.
