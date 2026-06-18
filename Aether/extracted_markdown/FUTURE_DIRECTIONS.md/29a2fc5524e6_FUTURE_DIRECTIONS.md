# Future Directions — Recursive Type Theory & Self-Referential ("Conscious") Types

## Synthesis

The cycle's central artifact, `Speculative/AutoResearch/RecursiveTypeFixedPoints.lean`,
turns the speculative slogan *"consciousness = a type that quantifies over itself,
`T ≈ Π(x:T), P x`"* into a sharp, machine-checked dichotomy:

* **Full self-reflection is inconsistent.** A type with a retraction
  `eval : T → (T → Prop)`, `reflect : (T → Prop) → T`, `eval ∘ reflect = id`
  cannot exist (`no_reflective_type`, axiom-free). The obstruction is Lawvere's
  diagonal (`lawvere_self_reference`): a surjective self-evaluation forces every
  endomap on the value space to have a fixed point, and negation on `Prop` has
  none.
* **Bounded self-reference is consistent but incomplete.** A type with only a
  *diagonal operator* and a sound `Provable`/`True_` split has a true-but-unprovable
  Gödel point (`recursiveType_incomplete`, axiom-free).
* **The Cantor obstruction is constructive and computable.** The diagonal witness
  `selfEval_diagonal_witness` (axioms: `propext` only) exhibits, for any
  `e : T → (T → Bool)`, an explicit predicate outside its range; `finiteDiagonal`
  makes this `#eval`-able on `Fin n`.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `lawvere_self_reference` | surjective `e : T → (T → α)` ⟹ every `f : α → α` has a fixed point | none |
| `no_reflective_type` | no type admits a full predicate-retraction (`ReflectiveType` is empty) | none |
| `reflective_no_truth_predicate` | a surjective self-evaluation cannot be a truth predicate | propext, choice |
| `selfEval_diagonal_witness` | explicit `Bool` diagonal missed by every point | propext |
| `no_bool_self_surjection` | no `e : T → (T → Bool)` is surjective | propext |
| `finiteDiagonal_not_named` | computable Cantor diagonal on `Fin n` | propext |
| `recursiveType_incomplete` | weak self-reference ⟹ true-but-unprovable point | none |
| `goedel_is_strange_loop` | the Gödel point's truth ⟺ its own unprovability | none |

These extend the catalog's `Logic.StrangeLoops.Core` (`lawvere_fixed_point`,
`cantor_from_lawvere`, `tarski_undefinability`) by lifting provability-level
diagonalization to the level of *types* and pinning the exact consistency boundary.

## Research Directions

### 1. The Church–Kleene cardinality conjecture, via a definability model
The original concept conjectures that the "self-referential types" number exactly
`ℵ₁^{CK}` (the Church–Kleene ordinal). Raw types are a proper class, so the claim
is only meaningful for a *recursion-theoretic* refinement: index `RecursiveType`
instances by computable diagonal operators and ask how far the ordinal of
iterated `diag`-application climbs before stabilizing. **The key insight is** that
the well-founded part of the "Gödel point of the Gödel point of …" iteration is an
*ordinal notation system*, and its supremum is exactly the recursive ordinals —
so the conjecture should be reformulated and proved as: the order type of
constructively-presented recursive self-reference operators is `ω₁^{CK}`.
**Why now?** We already have a clean, axiom-light `RecursiveType` with an explicit
`goedel` operator; Mathlib's ordinal and `Computability` libraries provide the
notation/`Nat.rec` machinery needed to iterate it, so the missing piece is purely
the indexing scheme, not new foundations.

### 2. A type-level arithmetical hierarchy with provable strictness
Define `Σ/Π` levels of self-referential types by counting quantifier alternations
in the predicate fed to `diag`, and prove the hierarchy is *strict* (each level
names a predicate no lower level can). **The key insight is** that the diagonal
witness `selfEval_diagonal_witness` already separates one level from its own power
space; iterating the construction relativized to a level-`n` oracle should yield a
level-`(n+1)` predicate provably missed at level `n`, mirroring the classical
arithmetical hierarchy. **Why now?** The constructive, choice-free diagonal we
built relativizes verbatim to any decidable oracle, so the separation theorem is a
finite induction over the existing `finiteDiagonal` argument rather than new analysis.

### 3. Quantitative incompleteness: counting unprovable truths
Strengthen `recursiveType_incomplete` from "∃ a true-but-unprovable point" to a
*lower bound* on the cardinality (or density, on `Fin n` models) of the set
`{c | True_ c ∧ ¬ Provable c}`. **The key insight is** that every fixed point of
`diag (¬Provable ∘ f ·)` for distinct sound `f` yields a distinct unprovable truth,
so injectivity of the assignment `f ↦ diag(...)` transfers a cardinality bound on
operators to a cardinality bound on incompleteness. **Why now?** `goedel_is_strange_loop`
gives the fixed-point equivalence in one line; combined with a finite
`RecursiveType` model on `Fin n` we can `decide` concrete counts and conjecture the
asymptotic rate empirically before proving it.

### 4. Bridging to provability logic GL and the catalog's `Lob*` files
The `RecursiveType` soundness/diagonal package is the semantic shadow of Löb's
theorem. Conjecture: every `RecursiveType` validates an internal Löb schema
`Provable (Provable c → True_ c) → Provable (True_ c)` under a modest extra
closure hypothesis, connecting this file to `Logic.LobFixedPointIteration` and
`Logic.PolymodalGL`. **The key insight is** that the diagonal operator `diag` *is*
the Gödel fixed-point combinator that GL's modal completeness is built on, so the
modal axioms should be derivable structurally from `diag_spec` plus soundness.
**Why now?** The catalog already contains a developed GL/Löb stack; our type-level
`diag` gives a fresh, computable model to test those modal theorems against, closing
a cross-domain loop (type theory ↔ provability logic).

### 5. Constructive Rice theorem for recursive types, with extracted counterexamples
Prove a Rice-style theorem: any non-trivial, extensional semantic predicate on
`RecursiveType.Carrier` is not captured by `Provable`, and — crucially — *extract
the deciding diagonal witness constructively*. **The key insight is** that
`no_bool_self_surjection` is already a constructive Rice nucleus (a `Bool`-valued
property no self-evaluation decides); generalizing from `Bool` to an arbitrary
two-valued non-trivial property `P` should keep the witness explicit, since the
diagonal only ever uses one toggling point. **Why now?** Our `no_bool_self_surjection`
is choice-free (`propext` only), so unlike the catalog's classical `rice_abstract`
this direction promises a *witness-producing* Rice theorem suitable for `#eval`,
matching the engine's constructive/algorithmic mandate.
