# Future Research Directions

## Synthesis

The de Bruijn Church-Rosser formalization establishes a reusable substitution algebra that opens multiple research frontiers. The σ-algebra (simultaneous substitutions with fusion lemmas) is not specific to the untyped lambda calculus — it is the correct infrastructure for *any* calculus with variable binding. The five directions below form a coherent program: Directions 1–2 extend the type-theoretic depth, Direction 3 explores the substitution algebra itself as a computational object, Direction 4 bridges to compiler verification, and Direction 5 connects to the foundations of proof theory. Each builds directly on the `substEnv_parBeta` theorem and the fusion lemmas as reusable infrastructure.

---

## Direction 1: Strong Normalization of Simply-Typed Lambda Calculus

**Conjecture**: Every well-typed term in the simply-typed lambda calculus (with de Bruijn indices and the substitution algebra from `DeBruijn/SubstAlgebra.lean`) is strongly normalizing: every reduction sequence terminates.

**Test**: Formalize simple types over `LamDB`, define a typing judgment `HasType`, and prove strong normalization via Tait's reducibility candidates method. The substitution algebra provides the infrastructure for the key substitution lemma in the reducibility argument: if `t` is reducible and `s` is reducible, then `subst0(s, t)` is reducible. Test computationally by enumerating all well-typed closed terms up to size 12 and verifying termination.

**Impact**: Strong normalization is the next major metatheoretic result after Church-Rosser. A proof reusing the same substitution algebra would validate the claim that the σ-algebra is genuinely reusable infrastructure, not a one-off construction.

**Catalog References**: `DeBruijn/SubstAlgebra.lean` (fusion lemmas), `DeBruijn/ChurchRosser.lean` (substEnv_parBeta).

**Proof Strategy**: Define reducibility candidates indexed by types. The key lemma is that reducibility is preserved under substitution, which requires `substEnv_comp` and the lift compatibility lemmas. The closure under beta-expansion uses `BetaDB.to_parBeta` and `ParBetaDB.refl`.

**Domain Bridges**: Type theory ↔ programming language semantics (type safety ↔ normalization). Termination proofs for dependently-typed languages.

**Lineage**: Extends Church-Rosser (confluence) to the orthogonal property (termination). Both are consequences of the same substitution algebra.

**Ambition**: ★★★★ (Grand challenge: the substitution lemma for reducibility is the hard part, but the algebra is already in place.)

---

## Direction 2: Confluence of System F (Polymorphic Lambda Calculus)

**Conjecture**: Beta-reduction in System F (second-order lambda calculus) is confluent, provable using parallel reduction with the same substitution algebra extended to handle type-level variables.

**Test**: Extend `LamDB` with type abstraction and type application. Define type substitution as a second instance of `substEnv`. Prove that parallel reduction at both term and type level satisfies the diamond property. Test by enumerating well-typed System F terms up to size 8.

**Impact**: System F is the theoretical foundation of ML, Haskell, and Rust's generics. Confluence of System F is well-known but rarely mechanized from scratch.

**Catalog References**: `DeBruijn/SubstAlgebra.lean` (template for type-level substitution).

**Proof Strategy**: Use two layers of de Bruijn indices (one for term variables, one for type variables). The substitution algebra instantiates twice. The interaction between term and type substitution requires a "commutation" lemma that follows from the general fusion framework.

**Domain Bridges**: Type theory ↔ programming language design (parametric polymorphism).

**Lineage**: Direct extension of Direction 1 to polymorphic types.

**Ambition**: ★★★★★ (Grand challenge: the two-sorted substitution interaction is the key difficulty.)

---

## Direction 3: Explicit Substitution Calculi and Their Confluence

**Conjecture**: The σ-algebra defined in `SubstAlgebra.lean`, when internalized as term constructors (creating an explicit substitution calculus), yields a calculus that is confluent on well-formed terms and simulates beta-reduction step-by-step.

**Test**: Define an explicit substitution calculus (à la Abadi-Cardelli-Curien-Lévy) where substitution environments are part of the term syntax. Prove confluence using the same parallel reduction method. Identify the "composition" reduction rule and show it is strongly normalizing on substitution chains. Test confluence computationally on terms up to size 10.

**Impact**: Explicit substitution calculi are used in implementations of proof assistants and compilers. A mechanized confluence proof would provide verified foundations for these implementations.

**Catalog References**: `DeBruijn/SubstAlgebra.lean` (fusion lemmas become reduction rules), `DeBruijn/ChurchRosser.lean` (proof template).

**Proof Strategy**: The fusion lemmas (`substEnv_comp`, etc.) become the equations of the explicit substitution calculus. Confluence follows from a diagram-chasing argument using the same Takahashi method.

**Domain Bridges**: Proof theory ↔ implementation (abstract machines, environment machines).

**Lineage**: The substitution algebra is "compiled" into a calculus.

**Ambition**: ★★★ (Well-understood but technically involved.)

---

## Direction 4: Verified Compiler Passes via Complete Development

**Conjecture**: The `develop` function, formalized as a verified algorithm, can serve as a certified optimization pass (simultaneous inlining) in a verified compiler pipeline. Composing `develop` with a CPS transformation and closure conversion yields a pipeline where each pass is individually verified.

**Test**: Implement a small functional language compiler targeting a stack machine. Define each pass as a function on `LamDB` (or an enriched variant). Prove semantic preservation for each pass, using `develop_triangle` for the inlining pass. Benchmark compilation of Church-numeral arithmetic.

**Impact**: Connects the pure metatheory to practical verified compilation. The complete development is a non-trivial optimization (simultaneous inlining) with a machine-checked correctness proof.

**Catalog References**: `DeBruijn/ChurchRosser.lean` (develop, develop_triangle, develop_reflects).

**Proof Strategy**: Define a denotational semantics for `LamDB` in a suitable domain. Show that `develop` preserves denotational equivalence. This follows from `develop_reflects` (develop is a parallel reduction) and the fact that parallel reduction preserves semantics.

**Domain Bridges**: Proof theory ↔ compiler construction ↔ software engineering.

**Lineage**: Applies the verified theory to engineering practice.

**Ambition**: ★★★★ (Significant engineering effort, high practical impact.)

---

## Direction 5: Normalization by Evaluation with Verified Correctness

**Conjecture**: Normalization by evaluation (NbE) for the simply-typed lambda calculus can be formalized using the de Bruijn substitution algebra, with a proof that the NbE algorithm produces the unique beta-normal form (when it exists) and that the algorithm terminates on all well-typed inputs.

**Test**: Implement NbE as a function from `LamDB` to `LamDB` (via a semantic domain). Prove `NbE(t) = normalize(t)` for all strongly normalizing terms. Test on Church-encoded data structures up to size 20.

**Impact**: NbE is the state-of-the-art normalization algorithm used in proof assistants (including the one used to verify this very development). Verifying NbE would close the loop: the tool is verified using its own verification engine.

**Catalog References**: `DeBruijn/SubstAlgebra.lean` (substitution algebra), `DeBruijn/ChurchRosser.lean` (confluence guarantees uniqueness of normal forms).

**Proof Strategy**: Define a "reify/reflect" pair between the semantic domain and `LamDB`. The key lemma is that reification commutes with substitution, which requires the fusion lemmas. Completeness follows from Church-Rosser (the normal form is unique).

**Domain Bridges**: Proof theory ↔ type theory ↔ implementation of proof assistants.

**Lineage**: The ultimate application of the substitution algebra.

**Ambition**: ★★★★★ (Grand challenge: NbE correctness is one of the hardest results in mechanized metatheory.)
