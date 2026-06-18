# Future Directions

## Synthesis

The finite model property for STLC opens a rich landscape connecting type theory, temporal logic, graph theory, and complexity theory. Our verified theorems establish that typed computation is inherently finite-state, but the precise *quantitative* bounds — and extensions to richer type systems — remain open. The directions below form a coherent program: the tight bound hypothesis (Direction 1) calibrates the theory, treewidth bounds (Direction 2) enable efficient algorithms, System F extension (Direction 3) tests universality, and the categorical perspective (Direction 5) provides unifying abstractions. Each direction builds on the formalized foundation and is designed to be testable, falsifiable, and impactful.

---

### Direction 1: Tight Bound Hypothesis for Normalization Length

**Conjecture**: For the simply typed lambda calculus with a single base type, the maximum reduction length of a term `t : τ` of size `n` is exactly `(2^depth(τ) - 1) · n`, and this bound is achieved by Church numeral–successor compositions.

**Test**: Generate all well-typed terms of types with depth ≤ 5 and sizes ≤ 15. Exhaustively enumerate all reduction sequences. Check whether the maximum observed length matches `(2^d - 1) · n`. A single counterexample (observed length > predicted) falsifies the conjecture.

**Impact**: If confirmed, provides an *exact* formula for the size of the FTS, enabling precise resource prediction for typed programs. If falsified, reveals unexpected computational patterns in typed λ-calculus.

**Catalog References**: `Pythagorean/STLCDefs.lean` (Ty.depth, Ty.complexity), `Pythagorean/STLCTheorems.lean` (finite_model_property)

**Proof Strategy**: Prove lower bound by constructing maximally-long terms at each type depth. Prove upper bound by refining the reducibility argument to track step counts. Key lemma: reduction length of `app t u` ≤ reduction length of `t` + reduction length of `u` + interaction term.

**Domain Bridges**: Proof theory (ordinal analysis of STLC), combinatorics (counting reduction paths)

**Lineage**: Extends Schwichtenberg's bounds on simply typed normalization (1991)

**Ambition**: ★★★★ (requires novel combinatorial analysis)

---

### Direction 2: Bounded Treewidth and Linear-Time CTL* Model Checking

**Conjecture**: The treewidth of the reduction graph of a well-typed term `t : τ` is bounded by `depth(τ)`, and this enables linear-time CTL* model checking (in the size of the graph).

**Test**: (1) Compute treewidth of reduction graphs for terms with types of depth 1-5 and sizes 1-20 using exact treewidth algorithms. Verify `tw ≤ depth(τ)`. (2) Implement both PSPACE CTL* model checking and bounded-treewidth CTL* model checking; compare running times on typed term FTS.

**Impact**: Transforms temporal verification of typed programs from PSPACE to linear time. Practical impact on certified compilation and functional program verification.

**Catalog References**: `Pythagorean/STLCTheorems.lean` (sn_reduction_graph_dag, typed_finite_model_property), `Pythagorean/BoundedBetaTheorems.lean` (finite_states_of_bounded_beta)

**Proof Strategy**: Construct tree decomposition by induction on type structure. For base type, the graph is a path (tw=1). For arrow type σ → τ, use the reducibility structure to bound bag sizes. Key insight: the type derivation tree provides a natural tree decomposition skeleton.

**Domain Bridges**: Graph theory (treewidth), parameterized complexity, model checking (Courcelle's theorem)

**Lineage**: Builds on Courcelle (1990), extends to λ-calculus reduction graphs

**Ambition**: ★★★★★ (grand challenge: connects three major fields)

---

### Direction 3: Finite Model Property for System F

**Conjecture**: The finite model property does NOT extend to System F (second-order typed lambda calculus) in its full generality — specifically, there exist System F terms whose reduction graphs, while finite (by strong normalization), have sizes that cannot be bounded by any primitive recursive function of the type and term size.

**Test**: Construct the System F encoding of `2^{2^n}` using iterated Church numerals and type abstraction. Compute the reduction graph size. If it exceeds `complexity(τ)^n` for the assigned type, the primitive recursive bound fails.

**Impact**: Establishes a fundamental boundary between STLC and System F for temporal verification. Shows that polymorphism radically changes the model-checking landscape.

**Catalog References**: `Pythagorean/STLCTheorems.lean` (red_properties, finite_model_property)

**Proof Strategy**: Use Girard's representation of fast-growing functions in System F. The reduction graph of `T₃` (tower function) has super-exponential size. Show no primitive recursive bound suffices by diagonalization.

**Domain Bridges**: Proof theory (proof-theoretic ordinals of System F = Γ₀), computability theory

**Lineage**: Girard (1972), Statman (1979) on the complexity of normalization

**Ambition**: ★★★★★ (grand challenge: would resolve a long-standing question)

---

### Direction 4: Optimal Complexity of Reducibility Bounds

**Conjecture**: The reducibility-based normalization bound `complexity(τ)^n` is optimal up to a polynomial factor — there exist families of terms achieving reduction lengths `Ω(complexity(τ)^{n/c})` for a constant `c`.

**Test**: For each type τ with complexity ≤ 100, construct the term achieving the longest reduction sequence. Plot max-reduction-length vs `complexity(τ)^n`. If the ratio is bounded away from 0, the conjecture is supported. If the ratio converges to 0, the conjecture is falsified.

**Impact**: Validates or refines the theoretical bound, with implications for resource prediction in certified compilers.

**Catalog References**: `Pythagorean/STLCDefs.lean` (Ty.complexity), `Pythagorean/STLCTheorems.lean` (red_implies_sn)

**Proof Strategy**: Construct long-reducing terms using iterated application of identity functions. The key is the interaction between function application depth and type complexity.

**Domain Bridges**: Complexity theory, rewriting theory

**Lineage**: Beckmann (2001) on bounds for simply typed normalization

**Ambition**: ★★★ (solid extension)

---

### Direction 5: Categorical Semantics of Temporal Verification

**Conjecture**: The reduction graph of a well-typed term, viewed as a finite category (objects = terms, morphisms = reduction paths), supports a sheaf-theoretic interpretation of CTL* formulas, where model checking becomes section computation.

**Test**: Implement the presheaf construction for CTL* formulas on reduction graphs of typed terms with types of depth ≤ 3. Verify that global sections correspond exactly to satisfied CTL* formulas.

**Impact**: Provides a categorical unification of type theory and temporal logic. Opens the door to sheaf-theoretic program analysis methods.

**Catalog References**: `Pythagorean/BoundedBetaDefs.lean` (FTS, SatisfiesFTS), `Pythagorean/BoundedBetaTheorems.lean` (bisimilar_preserves_modal_theory)

**Proof Strategy**: Define the category Red(t) from the reduction graph. Define a functor F_φ : Red(t)^op → Set for each CTL* formula φ. Show F_φ is a sheaf iff φ has the finite model property. Global sections = models.

**Domain Bridges**: Category theory (presheaves, sheaves), topos theory, domain theory

**Lineage**: Abramsky (1987) on domain theory in logical form, Joyal-Moerdijk sheaf semantics

**Ambition**: ★★★★ (paradigm-bridging)
