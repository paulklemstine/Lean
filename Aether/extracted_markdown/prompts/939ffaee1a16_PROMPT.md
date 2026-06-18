                # MATHEMATICAL RESEARCH MISSION: Fundamental theorem of identity systems from fiber equivalences

                ## Objective / Task Brief:
                Create a team to research this mathematical direction. Brainstorm new hypotheses, run experiments, analyze results, take notes, iterate. Combine all the researchers' findings into clean, verified Lean 4 files, and then brainstorm a list of the next research directions.

                ## Deliverables & Acceptance Criteria:
                1. **Lean 4 Proofs**: Fully verified, compiling Lean 4 files under the appropriate Catalog directory. Main theorems must be fully proved (0 sorries).
                2. **Lab Notes**: Include inline comment blocks (`-- !-- Lab Notes -- !--`) in the Lean files detailing your hypotheses, experimental outcomes, insights, and failure analysis.
                3. **FUTURE_DIRECTIONS.md**: Outlining 3-5 bold, testable mathematical conjectures for follow-up cycles based on your combined findings.

                ## Constraints (Strictly Enforced):
                - **NO prose or documentation articles**: Do NOT output ARTICLE.md, RESEARCH_PAPER.md, python algorithms, HTML widgets, or PACKAGE.json. Focus 100% of your compute on standard Lean 4 code and proofs.

                ## Context & Resources:
                - Domain: Logic
                - Existing Catalog References: Catalog/Logic/HoTT/Foundations.lean, Logic/HoTT/IdentitySystemsConverse.lean, Applications/HoTT/ConstructiveFoundations.lean

### Catalog Context
@Logic/HoTT/IdentitySystemsConverse.lean
```lean
/-
# Identity Systems II: Converse, Eliminator, Closure, and the Mathlib Bridge

This file is the *next research cycle* on the catalog's synthetic-HoTT layer. The
previous cycle (`Catalog/Logic/HoTT/IdentitySystems.lean`) proved the
**Fundamental Theorem of Identity Systems** (`fundamentalIdentitySystem`):
an `IdentitySystem A a₀ R` yields a fibrewise equivalence `(a₀ = a) ≃' R a`.

Here we close four of the research directions opened by that cycle, all
`sorry`-free and depending only on `propext`:

* **Direction 1 — the converse.** `idSys_of_fiber_equiv`: a family `R` that is
  fibrewise equivalent to the based path family `a₀ = ·` is itself an identity
  system. Together with `fundamentalIdentitySystem` this gives the genuine
  *characterisation*: `R` is an identity system **iff** it is fibrewise
  equivalent to the path family. The proof reuses the catalog's
  `Equiv'.contractible` to transport contractibility of the path total space
  across an assembled `Σ'`-equivalence `Equiv'.psigmaCongr`.

* **Direction 3 — closure under products.** `idSys_prod`: the product of two
  identity systems is an identity system on the product, via `Contractible.prod`
  and the regrouping equivalence `Equiv'.sigmaProd`.

* **Direction 4 — a `J`/path-induction eliminator.** `idSysElim` with its
  computation rule `idSysElim_beta`: every identity system induces its own
  dependent eliminator that reduces to the base case on the reflexivity witness,
  exactly like `Eq.rec` does for the based path family.

* **Direction 5 — the bridge to Mathlib.** `Equiv'.toEquiv` repackages the
  catalog's bespoke `Equiv'` as a Mathlib `Equiv`, and
  `fundamentalIdentitySystemEquiv` exports the fundamental theorem as an honest
  `(a₀ = a) ≃ R a`, importable into mainstream Mathlib developments.

## Relationship to catalog
- Reuses `HoTTFound.Contractible`, `Equiv'`, `Equiv'.symm`, `Equiv'.contractible`,
  `IdentitySystem`, `contractible_based_paths`, `fundamentalIdentitySystem` from
  `Foundations.lean` / `IdentitySystems.lean`; adds only new declarations.

-- !-- Lab Notebook -- !--
Hypothesis: The fundamental theorem of identity systems should be reversible
  (a fibrewise equivalence to the path family characterises identity systems),
  should generate its own eliminator, should be closed under products, and should
  embed into Mathlib's `Equiv` API — all derivable from the data already present
  in `Foundations.lean`/`IdentitySystems.lean` with no new axioms.
Result: All four confirmed and fully formalized (zero `sorry`). The converse
  (`idSys_of_fiber_equiv`) and product closure (`idSys_prod`) both reduce to a
  single move: build a `Σ'`-equivalence between total spaces and push
  contractibility across it with `Equiv'.contractible`. The eliminator
  (`idSysElim`) is transport of the base datum along the contractibility witness
  of the total space, and its `β`-rule (`idSysElim_beta`) holds because the
  relevant transport is along a *loop* in a `Prop`-valued `Eq`, hence `rfl` by
  proof irrelevance (`mpr_congr_loop`). The Mathlib bridge is a definitional
  repackaging since `Equiv'`'s two roundtrip laws are exactly Mathlib's
  `left_inv`/`right_inv`.
Insight: Contractibility transport along an `Equiv'` is the single reusable
  engine for the entire identity-system calculus: encode/decode (previous cycle),
  the converse, and closure properties all become one-line assemblies once the
  appropriate `Σ'`-equivalence is named. The eliminator's computation rule is
  "free" for the same reason the previous cycle's `left_inv` was free: `Eq` is a
  subsingleton, so every transport along a base loop is the identity.
-- ... (truncated, full file has 206 lines)
```

@Applications/HoTT/ConstructiveFoundations.lean
```lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Constructive Foundations from Homotopy Type Theory

A *self-contained* fragment of Homotopy Type Theory, developed inside Lean 4
**without** relying on Lean's `Eq` (which has definitional proof irrelevance and
therefore validates UIP, making genuine HoTT impossible).  Instead we introduce
a synthetic Martin-Löf identity type `Path`, valued in `Type`, eliminated only
by path induction (`Path.rec`).  Because `Path` is an *indexed inductive in
`Type`*, axiom K / UIP is **not** derivable for it, so it genuinely models the
homotopical identity type.

The load-bearing results of this file are:

* `equiv_iff_contr_fibers` — the coincidence of the two notions of equivalence:
  a map has a quasi-inverse iff all of its fibers are contractible.
* `fundamental_theorem_id` — the (full biconditional) Fundamental Theorem of
  Identity Types: a fibrewise family `f : ∀ x, Path a x → C x` is a fibrewise
  equivalence iff the total space `Σ x, C x` is contractible.
* `equivalence_induction` — the equivalence-induction principle unlocked by a
  `Univalence` hypothesis: to prove a property of every equivalence out of `A`
  it suffices to prove it of the identity equivalence.
* `PTrunc` / `PTrunc.rec` / `PTrunc.rec_unique` — propositional truncation, a
  genuine higher inductive type (the `(-1)`-truncation) realized as a quotient,
  with its recursion principle and uniqueness.

The development is deliberately library-free (no `import Mathlib`): every result
is proved from the synthetic path calculus.
-/

namespace ConstructiveFoundations

universe u v w v2 z vv

/-! ## The synthetic identity type and its groupoid structure -/

/-- Synthetic Martin-Löf identity type, valued in `Type` (not `Prop`), so that
Lean's definitional proof irrelevance does not collapse it.  Path induction is
the recursor `Path.rec`; UIP is **not** provable. -/
inductive Path {A : Type u} : A → A → Type u where
  | refl (a : A) : Path a a

/-- Path reversal (symmetry of the groupoid). -/
def Path.symm {A : Type u} {a b : A} : Path a b → Path b a
  | .refl _ => .refl _

/-- Path concatenation (composition in the groupoid). -/
def Path.trans {A : Type u} {a b c : A} : Path a b → Path b c → Path a c
  | .refl _, q => q

/-- Action on paths (functoriality): a function sends paths to paths. -/
def ap {A : Type u} {B : Type v} (f : A → B) {a b : A} : Path a b → Path (f a) (f b)
  | .refl _ => .refl _

/-- Transport along a path in a type family. -/
def transport {A : Type u} (P : A → Type v) {a b : A} : Path a b → P a → P b
  | .refl _, x => x

-- ... (truncated, full file has 493 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


                ## RESEARCH CORE METHODOLOGY:
1. **Catalog Leverage**: Examine existing catalog theorems carefully. Your theorems should extend, generalize, or connect catalog results.
2. **Pure Math Focus**: Focus 100% of your compute on standard Lean 4 definitions, lemmas, and theorems. Prove non-trivial math that represents genuine progress.
3. **Falsifiable Conjectures**: Formulate precise conjectures in FUTURE_DIRECTIONS.md to guide future research cycles.

