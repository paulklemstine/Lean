# Future Directions: Higher-Order Completion and Lambda-Calculus Integration

## Synthesis

The formalization of substitution functoriality, β-commutation, and rewrite closure for the simply-typed λ-calculus opens a systematic research program at the intersection of rewriting theory, type theory, categorical semantics, and compiler optimization. The five directions below form a coherent progression: Direction 1 strengthens the syntactic foundation, Direction 2 attacks the central algorithmic problem (completion modulo β), Directions 3 and 4 connect to applications in compilers and proof automation, and Direction 5 pursues the deepest mathematical connection — to operadic and homotopical structures. Each direction builds on the verified infrastructure of substitution composition (`subst_comp`), β-commutation (`beta_closed_under_subst`), and rewrite closure (`hoRewrites_closed_under_subst`, `hoRewrites_closed_under_context`), extending their reach into new territory.

---

## Direction 1: Intrinsically Typed Higher-Order Rewriting with βη-Completion

**Conjecture:** For the simply-typed λ-calculus with βη-reduction, substitution functoriality and rewrite closure extend to the βη setting, and the generated equational theory descends cleanly to βη-equivalence classes. Concretely: if `HOEqGen(E, t, u)` and `t ~βη t'`, `u ~βη u'`, then `HOEqGen(E, t', u')` in a theory with βη-rules included.

**Test:** Formalize intrinsically typed terms (indexed by context and type) using de Bruijn indices. Prove `subst_comp` and `hoRewrites_closed_under_subst` for typed terms. Then add η-contraction (`lam(app(rename(·+1, f), var 0)) → f`) and verify the η-commutation lemma: `eta_closed_under_subst`. Check computationally on typed terms up to size 12 that βη-normalization commutes with rewriting for orthogonal rule sets.

**Impact:** Intrinsically typed terms would eliminate ill-scoped terms by construction, making the formalization stronger and aligning with the Fiore-Plotkin-Turi framework for abstract syntax. βη-completion is strictly more powerful than β-completion and is required for extensional reasoning about functional programs.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (subst_comp, beta_closed_under_subst, liftSubst_compSubst); `Pythagorean/ConcreteTermAlgebra.lean` (FOTerm.subst_comp as the first-order prototype).

**Proof Strategy:** Start with the Autosubst-style approach: define a universe of types, index terms by `(Ctx, Ty)`, and derive the substitution lemmas mechanically. The η case requires proving `subst(lam(app(rename(·+1, f), var 0)), σ) = subst(f, σ)` when f has appropriate type, which reduces to showing `liftSubst(σ)(1) = rename(·+1)(σ(0))` — a definitional equality.

**Domain Bridges:** Type theory (intrinsic typing), categorical semantics (presheaves over contexts), proof automation (extensional simplification).

**Lineage:** Direct extension of the current work's substitution calculus.

**Ambition:** Solid extension — builds directly on verified infrastructure with clear proof path.

**"The key insight is..."** that η-contraction is the *semantic* counterpart of β-reduction — where β says "functions compute," η says "things that compute like functions *are* functions" — and the substitution calculus we have already verified handles both uniformly once the commutation lemma is established.

**"Why now?"** The substitution infrastructure (11 lemmas from `liftRen_id` through `subst_comp`) is now verified and battle-tested. Extending to η requires exactly one new commutation lemma and one new lifting property, both following the established pattern.

---

## Direction 2: Higher-Order Critical Pairs and Knuth-Bendix Completion Modulo β

**Conjecture:** For finite, left-linear, simply-typed higher-order rewrite systems with no critical pairs up to β-normalized matching on terms of size ≤ N, the generated β-aware one-step relation is locally confluent on all closed terms of size ≤ N. Moreover, a decidable criterion for the absence of critical pairs exists for the class of higher-order pattern rewrite systems (in the sense of Miller).

**Test:** Implement higher-order unification for Miller patterns. Enumerate all overlaps between pairs of rules in a given system. For each overlap, compute the critical pair and attempt to join it. Test on benchmark systems: map fusion, fold/build fusion, CPS transformation rules. Report the first system size at which a non-joinable critical pair appears (if any).

**Impact:** A working higher-order Knuth-Bendix procedure would be a major advance in automated reasoning, enabling certified completion for equational theories of functional programs. Even a bounded version with correctness guarantees would be immediately useful.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (HoRewrite, hoRewrites_closed_under_subst — the closure property is essential for the completion step); `Pythagorean/ConcreteTermAlgebra.lean` (concrete_completion_correct — the first-order completion correctness theorem that we aim to lift).

**Proof Strategy:** Define `CriticalPair(E)` as the set of pairs `(s, t)` arising from non-trivial overlaps of rules in E. Prove: if `CriticalPair(E)` is empty (up to β), then `HoRewrite(E)` is locally confluent. The proof uses `hoRewrites_closed_under_subst` to show that overlapping reductions can be completed. For the algorithmic part, implement Miller's higher-order pattern unification and verify it against the matching function.

**Domain Bridges:** Automated theorem proving (completion procedures), unification theory (higher-order unification), compiler optimization (certified rule derivation).

**Lineage:** Lifts the first-order completion correctness theorem to higher order.

**Ambition:** Grand challenge — higher-order completion modulo β is a known open problem in its full generality.

**"The key insight is..."** that the closure theorems we have verified (`hoRewrites_closed_under_subst`, `hoRewrites_closed_under_context`) are exactly the properties needed to make the Knuth-Bendix completion step valid at higher order — the rest is "just" unification and critical pair analysis.

**"Why now?"** The formal infrastructure for higher-order rewrite closure is now in place. The bottleneck has shifted from *closure properties* (solved) to *unification and overlap detection* (tractable with Miller patterns).

---

## Direction 3: Certified Stream Fusion via Higher-Order Completion

**Conjecture:** The stream fusion transformation (converting recursive list operations to stream operations and then to tight loops) can be expressed as a finite set of higher-order rewrite rules, and the resulting system is confluent modulo β on well-typed terms. The β-normal form of any term in the generated theory corresponds to the fused program.

**Test:** Encode the GHC stream fusion rules (stream/unstream, map/stream, filter/stream, foldr/build) as higher-order equations. Apply bounded completion. Check that all critical pairs join. Benchmark the resulting rewriting system against GHC's actual fusion behavior on 20 benchmark programs from the nofib suite.

**Impact:** Stream fusion is one of the most important optimizations in Haskell, but its correctness has never been formally established at the equational level. A certified higher-order rewriting approach would provide the first machine-checked correctness proof for a production compiler optimization.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (mapFusionEq, map_fusion_in_theory — the map fusion example demonstrates the approach); `Pythagorean/ConcreteTermAlgebra.lean` (rewrites_closed_under_subst_and_context — the closure property that makes rule application correct).

**Proof Strategy:** Define stream type as `Stream a = ∃s. (s → Step a s, s)` in the STLC (using existential encoding). Express stream fusion as rewrite rules. Use `hoRewrites_closed_under_subst` to verify that rule application is sound. Apply `subst_comp` to verify that composed transformations equal single-pass transformations.

**Domain Bridges:** Compiler optimization (GHC), functional programming (deforestation), performance engineering.

**Lineage:** Extends the map fusion example to a full optimization framework.

**Ambition:** Solid extension with high practical impact.

**"The key insight is..."** that stream fusion is not just a *specific* optimization but an *equational theory* — a set of higher-order equations whose closure under substitution and contexts (exactly what we've verified) generates all valid fusion transformations.

**"Why now?"** Map fusion is already formalized as a higher-order equation in our framework. Stream fusion is a systematic generalization requiring the same infrastructure at larger scale.

---

## Direction 4: Normalization-Guided Proof Automation via Higher-Order Rewriting

**Conjecture:** A simplification procedure based on higher-order completion modulo β can decide equality in the equational theory of simply-typed combinatory algebra (S, K, I combinators with their defining equations) by normalizing both sides and comparing normal forms. This procedure, when integrated as a tactic, can automate proofs that currently require manual `simp` lemma engineering.

**Test:** Implement a `ho_simp` tactic that: (1) takes a set of higher-order equations, (2) computes their completion (bounded), (3) normalizes both sides of the goal using the completed system, (4) checks syntactic equality of normal forms. Test on 50 equational goals involving function composition, map/filter laws, and monad laws. Compare proof length against `simp` with manually curated lemma sets.

**Impact:** Current proof automation in type-theoretic proof assistants relies heavily on manually curated `simp` sets. A completion-based approach would automatically derive the needed simplification rules from equational axioms, reducing the human effort in proof engineering.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (HOEqGen_closed_under_subst — the generated theory respects substitution, which is essential for tactic soundness; leftmostReduce_sound — verified reduction is the computational backbone).

**Proof Strategy:** The soundness theorem for the tactic follows from `HOEqGen_closed_under_subst`: if both sides normalize to the same term under a completed system derived from the equational axioms, they are in the generated equational theory. The main challenge is ensuring that the completion process terminates and produces a confluent system for the given axioms.

**Domain Bridges:** Proof automation (tactic development), type theory (equational reasoning), software verification.

**Lineage:** Applies the verified rewriting infrastructure as a proof automation tool.

**Ambition:** Solid extension with immediate applicability.

**"The key insight is..."** that completion doesn't just *simplify* expressions — it *decides* equational theories. A completed higher-order rewriting system is a decision procedure for its equational theory, and the closure theorems we've verified guarantee that this decision procedure is sound.

**"Why now?"** The formal connection between rewriting and equational theory (HOEqGen and its closure under substitution) is now verified, providing the soundness foundation for a tactic.

---

## Direction 5: Operadic Rewriting and Homotopical Completion

**Conjecture:** The substitution category formalized in our work (with `compSubst_assoc`, identity laws, and the presheaf-like action of terms) is the underlying category of a *colored operad* whose algebras are exactly the models of the STLC. Higher-order completion modulo β can be interpreted as a homotopical completion in the sense of operadic Koszul duality: the completed rewriting system computes a cofibrant replacement of the operad.

**Test:** Formalize the operad structure: define the composition operation on substitutions, verify the interchange law, and construct the corresponding operad. Then show that the critical pair computation of Direction 2 corresponds to computing the operadic Koszulity condition. Test on the associativity operad (whose Koszul dual is well-known) as a sanity check.

**Impact:** This would connect higher-order rewriting to the rapidly growing field of homotopical algebra and operadic methods. It would provide a new perspective on completion as a *homological* computation, potentially yielding new termination criteria and complexity bounds for higher-order completion.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (compSubst_assoc, compSubst_idSubst_left, compSubst_idSubst_right — the categorical structure of substitutions is the starting point for the operadic construction).

**Proof Strategy:** Define an operad `O` with colors `ℕ` (arities), operations `O(n₁,...,nₖ; m) = Subst(n₁+...+nₖ, m)`, and composition given by `compSubst`. Verify the operad axioms from the categorical properties already proved. Then define rewriting rules as generators of an operadic ideal, and show that completion computes the operadic Gröbner basis.

**Domain Bridges:** Homotopical algebra (operads, Koszul duality), algebraic topology (cofibrant replacements), homological algebra (resolutions).

**Lineage:** Reinterprets the substitution category as operadic structure.

**Ambition:** Grand challenge / paradigm-shifting — connects rewriting theory to homotopical algebra.

**"The key insight is..."** that substitution composition is not just a *convenience* but an *operadic structure* — the multi-sorted composition operation of an operad whose algebras are exactly the models of the type theory. Completion, viewed through this lens, is computing a resolution of the operad.

**"Why now?"** The categorical properties of substitution (associativity, identity, functoriality) are now formally verified, providing the raw material for an operadic construction. Recent advances in homotopical algebra (Loday-Vallette, Dotsenko-Khoroshkin) provide the theoretical tools for operadic completion.
