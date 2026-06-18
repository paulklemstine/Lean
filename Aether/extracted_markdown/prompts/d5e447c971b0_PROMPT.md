

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## Algebraic–EML Tannaka Reconstruction via Closure Endomorphism Monoids

Create `Bridges/AlgebraEMLReconstruction.lean` as a self-contained bridge between order-theoretic closure semantics, algebraic lattice reconstruction, semiring endomorphism monoids, and EML/Lawvere-style semantics. The file should formalize a genuine reconstruction principle: a closure operator is determined by its monoid of closure-preserving endomorphisms once compact/finitely generated closed pieces are sufficiently visible.

The mathematical narrative must connect:
- algebraic lattice theory / closure operators,
- semiring and endomorphism algebra,
- EML fixed-point semantics / Galois reconstruction,
- and at least one application-facing vocabulary in theorem names or doc comments:
  `quantum`, `thermodynamic`, `entropy`, `post_quantum`, `lattice`, `certified`, `lipschitz`.

The file should include at least 10 definitions/structures and 20+ theorems/lemmas, with zero sorries.

---

### 1. Core objects to define

Work as abstractly as possible over a type with closure structure. Prefer typeclass abstraction. If existing APIs already provide some of these concepts, wrap them with bridge definitions instead of duplicating.

Use Lean signatures close to the following.

```lean
import Mathlib

open Function Order Topology

namespace Bridges
namespace AlgebraEMLReconstruction
```

#### 1.1 Closure-preserving endomorphisms

If `α` carries a closure operator `cl : Set α → Set α`, define the endomorphisms preserving closed structure.

```lean
structure ClosurePreservingEnd (α : Type*) where
  toFun : α → α
  monotone_on_closed :
    ∀ {s t : Set α}, s ⊆ t → IsClosedUnder cl s → IsClosedUnder cl t →
      toFun '' s ⊆ toFun '' t
  preserves_closed :
    ∀ {s : Set α}, IsClosedUnder cl s → IsClosedUnder cl (toFun '' s)
```

If the exact `IsClosedUnder` API differs, replace it by the actual fixed-point predicate:
```lean
def ClosedSet (cl : Set α → Set α) (s : Set α) : Prop := cl s = s
```
and rewrite all statements using `ClosedSet cl s`.

Also define a pointwise extensionality theorem:
```lean
@[ext] theorem ClosurePreservingEnd.ext ...
```

Define identity and composition and prove monoid structure:
```lean
instance : One (ClosurePreservingEnd α)
instance : Mul (ClosurePreservingEnd α)
instance : Monoid (ClosurePreservingEnd α)
```

#### 1.2 Compactly closed / finitely generated closed sets

Formalize a compact-generation notion suitable for algebraic reconstruction.

```lean
def compactClosed (cl : Set α → Set α) (K : Set α) : Prop :=
  ∃ t : Finset α, cl (↑t : Set α) = K
```

Define invariant closure under an endomorphism family:
```lean
def InvariantClosure (cl : Set α → Set α) (M : Set (ClosurePreservingEnd α)) (s : Set α) : Prop :=
  ∀ f ∈ M, f.toFun '' s ⊆ cl s
```

Define the reconstruction predicate:
```lean
def reconstructsClosure
    (cl : Set α → Set α)
    (M : Set (ClosurePreservingEnd α)) : Prop :=
  ∀ s : Set α, cl s =
    ⋂₀ {K : Set (Set α) | ∃ t, t = s ∧
      ∀ C ∈ K, ClosedSet cl C ∧ InvariantClosure cl M C ∧ s ⊆ C}
```

If this exact formula is unwieldy in Lean, replace by an equivalent order-theoretic one:
```lean
def reconstructsClosure
    (cl : Set α → Set α)
    (M : Set (ClosurePreservingEnd α)) : Prop :=
  ∀ s, cl s = sInf {C | ClosedSet cl C ∧ InvariantClosure cl M C ∧ s ⊆ C}
```
where the ambient complete lattice is the lattice of sets.

#### 1.3 Endomorphism monoid equality and extensional closure recovery

```lean
def sameEndMonoid
    (cl₁ cl₂ : Set α → Set α) : Prop :=
  {f : α → α | IsClosurePreserving cl₁ f} =
  {f : α → α | IsClosurePreserving cl₂ f}
```

Main reconstruction statement:
```lean
theorem closure_eq_of_endMonoid_eq
    (cl₁ cl₂ : Set α → Set α)
    (h_alg₁ : AlgebraicLike cl₁)
    (h_alg₂ : AlgebraicLike cl₂)
    (h_rec₁ : reconstructsClosure cl₁ {f | IsClosurePreserving cl₁ f})
    (h_rec₂ : reconstructsClosure cl₂ {f | IsClosurePreserving cl₂ f})
    (hM : sameEndMonoid cl₁ cl₂) :
    cl₁ = cl₂
```

You may need to replace `AlgebraicLike` by an explicit hypothesis asserting every closed set is a supremum/union of finitely generated closed subsets. Make it concrete and Lean-friendly.

---

### 2. Additional bridge definitions required for AEM utility/originality

Define at least 5 of the following, with theorem support:

```lean
def ClosureOrbit (M : Set (ClosurePreservingEnd α)) (s : Set α) : Set α := ...
def finiteGeneratorRank (cl : Set α → Set α) (K : Set α) : Nat := ...
def closureComplexity (cl : Set α → Set α) (s : Finset α) : Nat := ...
def quantumInvariantClosure (cl : Set α → Set α) (M : Set (ClosurePreservingEnd α)) : Prop := ...
def thermodynamicFixedPointGap (cl : Set α → Set α) (s : Set α) : Prop := ...
def lipschitz_certified_reconstructor (cl : Set α → Set α) : Prop := ...
def post_quantum_endMonoid_hardness (M : Set (ClosurePreservingEnd α)) : Prop := ...
def entropyStableClosed (cl : Set α → Set α) (s : Set α) : Prop := ...
def latticeCryptoWitness (cl : Set α → Set α) (s : Set α) : Type _ := ...
def tannakianSeparator (cl : Set α → Set α) : Prop := ...
```

These definitions need not encode deep analysis/crypto in full generality; they should be mathematically meaningful proxies tied to finite generation, orbit growth, or separator properties. For example:
- `finiteGeneratorRank` = least cardinality of a finite generator.
- `closureComplexity` = cardinality bound of a chosen finite closure witness.
- `tannakianSeparator` = for every `x ∉ cl s`, there exists a closure-preserving endomorphism distinguishing `x` from all of `cl s`.
- `quantumInvariantClosure` = symmetric invariance under composition and identity, suggestive of observable-stable sectors.
- `post_quantum_endMonoid_hardness` = a combinatorial lower-bound placeholder on orbit separation size.

The point is to produce theorem-bearing, computable invariants, not empty wrappers.

---

### 3. Main theorem suite to prove

Prove a coherent theorem chain, not isolated facts. Include theorem names that carry application vocabulary.

#### 3.1 Basic closure/endomorphism lemmas

```lean
theorem closurePreservingEnd_id_mem ...
theorem closurePreservingEnd_comp_mem ...
theorem closedSet_image_of_closed ...
theorem invariantClosure_mono ...
theorem invariantClosure_iInter ...
theorem closureOrbit_subset_closed_hull ...
theorem closureOrbit_monotone ...
```

Proof style: use `intro`, `rcases`, `aesop?` only sparingly, and explicit set/extensional reasoning.

#### 3.2 Finite-generation and algebraicity lemmas

```lean
theorem compactClosed_of_finset ...
theorem compactClosed_closed ...
theorem compactClosed_mono_generatorRank ...
theorem exists_finite_closed_generator
    (h_alg : AlgebraicLike cl) :
    ∀ {K : Set α}, ClosedSet cl K → compactClosed cl K → ∃ t : Finset α, cl (t : Set α) = K
```

Also prove a minimality theorem for finite generator rank if you define it via `Nat.find`:
```lean
theorem finiteGeneratorRank_spec ...
theorem finiteGeneratorRank_minimal ...
```

This is a good place to use:
- `rcases`,
- finite-set induction,
- `omega` for cardinality inequalities,
- `by_contra` to derive minimality contradictions.

#### 3.3 Separator/reconstruction lemmas

Define a separator property in a Lean-friendly way:

```lean
def tannakianSeparator (cl : Set α → Set α) : Prop :=
  ∀ ⦃s : Set α⦄ ⦃x : α⦄, x ∉ cl s →
    ∃ f : ClosurePreservingEnd α, f.toFun x ∉ f.toFun '' (cl s)
```

or, if easier:
```lean
def tannakianSeparator (cl : Set α → Set α) : Prop :=
  ∀ ⦃s : Set α⦄ ⦃x : α⦄, x ∉ cl s →
    ∃ f : ClosurePreservingEnd α, ∀ y ∈ cl s, f.toFun y ≠ f.toFun x
```

Then prove:

```lean
theorem separator_detects_nonclosure ...
theorem closure_le_of_end_invariant ...
theorem closure_eq_sInf_closed_invariant ...
theorem reconstructsClosure_of_separator
    (hsep : tannakianSeparator cl)
    (halg : AlgebraicLike cl) :
    reconstructsClosure cl {f | True}
```

If the full `{f | True}` version is too strong, use the full endomorphism monoid:
```lean
theorem reconstructsClosure_of_separator
    (hsep : tannakianSeparator cl)
    (halg : AlgebraicLike cl) :
    reconstructsClosure cl {f | IsClosurePreserving cl f}
```

The proof should have clear quantifier alternation:
- for every `s`, show both inclusions,
- for `x ∉ cl s`, produce a witness endomorphism and an invariant closed set excluding `x`,
- use `by_contra`,
- use order extensionality on sets.

#### 3.4 Tannaka-style uniqueness theorem

This is the center of the file.

```lean
theorem closure_eq_of_endMonoid_eq
    (cl₁ cl₂ : Set α → Set α)
    (hcl₁ : IsClosureOperator cl₁)
    (hcl₂ : IsClosureOperator cl₂)
    (halg₁ : AlgebraicLike cl₁)
    (halg₂ : AlgebraicLike cl₂)
    (hsep₁ : tannakianSeparator cl₁)
    (hsep₂ : tannakianSeparator cl₂)
    (hM : sameEndMonoid cl₁ cl₂) :
    cl₁ = cl₂
```

Prove it by:
1. obtaining `reconstructsClosure` for each closure from the separator theorem,
2. rewriting both reconstruction formulas using `hM`,
3. applying extensionality `funext`,
4. applying set extensionality on each `s`.

Also include a pointwise corollary:
```lean
theorem closure_pointwise_quantum_reconstruction
    (hM : sameEndMonoid cl₁ cl₂) ... :
    ∀ s x, x ∈ cl₁ s ↔ x ∈ cl₂ s
```

#### 3.5 Computational/complexity-flavored consequences

Even in a purely algebraic file, include explicit finite bounds when the hypotheses are finite.

For `Fintype α`, prove results like:

```lean
theorem closureComplexity_le_card
    [Fintype α] (cl : Set α → Set α) (s : Finset α) :
    closureComplexity cl s ≤ Fintype.card α
```

```lean
theorem finiteGeneratorRank_le_univ
    [Fintype α] {K : Set α} :
    finiteGeneratorRank cl K ≤ Fintype.card α
```

```lean
theorem certified_lipschitz_reconstruction_bound
    [Fintype α]
    (hrec : reconstructsClosure cl M) :
    ∃ C : Nat, C ≤ Fintype.card α ∧
      ∀ s : Finset α, closureComplexity cl s ≤ C
```

The “Lipschitz” language may be implemented as a monotone cardinality sensitivity estimate:
```lean
def SetDistance (s t : Finset α) : Nat := (s \ t).card + (t \ s).card

def closureLipschitzBound (cl : Finset α → Finset α) (L : Nat) : Prop :=
  ∀ s t, SetDistance (cl s) (cl t) ≤ L * SetDistance s t
```

Then prove at least one theorem with explicit constant, for instance for the identity or monotone hull closure on finite types. If the general closure operator version is too strong, define a finite approximation:
```lean
def finitaryClosure (cl : Set α → Set α) (s : Finset α) : Finset α := ...
```
and prove a certified bound in that setting.

Name at least one theorem with explicit impact vocabulary, e.g.
```lean
theorem lipschitz_certified_robustness_of_finitaryClosure ...
theorem post_quantum_lattice_separator_bound ...
theorem quantum_entropy_closed_sector_reconstruction ...
```

---

### 4. Suggested Lean-friendly hypotheses

Because Mathlib may not package exactly the closure notion you need, use a concrete structure if necessary:

```lean
structure SetClosureOperator (α : Type*) where
  toFun : Set α → Set α
  extensive : ∀ s, s ⊆ toFun s
  monotone : Monotone toFun
  idempotent : ∀ s, toFun (toFun s) = toFun s
```

Then define:
```lean
instance : CoeFun (SetClosureOperator α) (fun _ => Set α → Set α) := ...
def ClosedSet (cl : SetClosureOperator α) (s : Set α) : Prop := cl s = s
```

This may be substantially easier than trying to force a topological closure API. If you do this, state all theorems using `SetClosureOperator α`.

Similarly, define:
```lean
def IsClosurePreserving (cl : SetClosureOperator α) (f : α → α) : Prop :=
  ∀ s, f '' (cl s) ⊆ cl (f '' s)
```

This is a robust algebraic notion and composes well.

For algebraicity, use a direct property:
```lean
def AlgebraicLike (cl : SetClosureOperator α) : Prop :=
  ∀ x s, x ∈ cl s → ∃ t : Finset α, (↑t : Set α) ⊆ s ∧ x ∈ cl (↑t : Set α)
```

This is exactly the finitary closure property and is easier to exploit than abstract algebraic-lattice infrastructure.

---

### 5. Concrete theorem signatures to target

Use these exact or near-exact signatures if you adopt `SetClosureOperator`.

```lean
structure SetClosureOperator (α : Type*) where
  toFun : Set α → Set α
  extensive : ∀ s, s ⊆ toFun s
  monotone : Monotone toFun
  idempotent : ∀ s, toFun (toFun s) = toFun s

instance : CoeFun (SetClosureOperator α) (fun _ => Set α → Set α)

def ClosedSet (cl : SetClosureOperator α) (s : Set α) : Prop := cl s = s

def IsClosurePreserving (cl : SetClosureOperator α) (f : α → α) : Prop :=
  ∀ s, f '' (cl s) ⊆ cl (f '' s)

structure ClosurePreservingEnd (α : Type*) (cl : SetClosureOperator α) where
  toFun : α → α
  map_closure : ∀ s, toFun '' (cl s) ⊆ cl (toFun '' s)

instance (cl : SetClosureOperator α) : CoeFun (ClosurePreservingEnd α cl) (fun _ => α → α)

instance (cl : SetClosureOperator α) : One (ClosurePreservingEnd α cl)
instance (cl : SetClosureOperator α) : Mul (ClosurePreservingEnd α cl)
instance (cl : SetClosureOperator α) : Monoid (ClosurePreservingEnd α cl)

def compactClosed (cl : SetClosureOperator α) (K : Set α) : Prop :=
  ∃ t : Finset α, cl (↑t : Set α) = K

def AlgebraicLike (cl : SetClosureOperator α) : Prop :=
  ∀ x s, x ∈ cl s → ∃ t : Finset α, (↑t : Set α) ⊆ s ∧ x ∈ cl (↑t : Set α)

def tannakianSeparator (cl : SetClosureOperator α) : Prop :=
  ∀ ⦃s : Set α⦄ ⦃x : α⦄, x ∉ cl s →
    ∃ f : ClosurePreservingEnd α cl, ∀ y ∈ cl s, f y ≠ f x

def InvariantClosed
    (cl : SetClosureOperator α)
    (M : Set (ClosurePreservingEnd α cl))
    (C : Set α) : Prop :=
  ClosedSet cl C ∧ ∀ f ∈ M, f '' C ⊆ C

def reconstructsClosure
    (cl : SetClosureOperator α)
    (M : Set (ClosurePreservingEnd α cl)) : Prop :=
  ∀ s : Set α, cl s =
    {x | ∀ C, InvariantClosed cl M C → s ⊆ C → x ∈ C}

def sameEndMonoid (cl₁ cl₂ : SetClosureOperator α) : Prop :=
  {f : α → α | IsClosurePreserving cl₁ f} =
  {f : α → α | IsClosurePreserving cl₂ f}

theorem mem_closure_of_mem_closed
    {cl : SetClosureOperator α} {s C : Set α} :
    s ⊆ C → ClosedSet cl C → cl s ⊆ C

theorem closure_eq_iInter_invariantClosed
    {cl : SetClosureOperator α}
    (hrec : reconstructsClosure cl M) :
    ∀ s, cl s = {x | ∀ C, InvariantClosed cl M C → s ⊆ C → x ∈ C}

theorem reconstructsClosure_of_separator
    {cl : SetClosureOperator α}
    (halg : AlgebraicLike cl)
    (hsep : tannakianSeparator cl) :
    reconstructsClosure cl Set.univ

theorem closure_eq_of_endMonoid_eq
    {cl₁ cl₂ : SetClosureOperator α}
    (halg₁ : AlgebraicLike cl₁)
    (halg₂ : AlgebraicLike cl₂)
    (hsep₁ : tannakianSeparator cl₁)
    (hsep₂ : tannakianSeparator cl₂)
    (hM : sameEndMonoid cl₁ cl₂) :
    cl₁ = cl₂
```

If `Set.univ` for monoids with different closure parameters is awkward, reconstruct using predicates on raw functions `α → α` rather than bundled ends.

---

### 6. Proof strategy details

#### Strategy A: direct order-theoretic reconstruction from separators
Most promising.

1. **Closed upper bound lemma**  
   Prove:
   ```lean
   theorem mem_closure_of_mem_closed
       {cl : SetClosureOperator α} {s C : Set α} :
       s ⊆ C → ClosedSet cl C → cl s ⊆ C
   ```
   using monotonicity and idempotence:
   - from `s ⊆ C`, get `cl s ⊆ cl C`,
   - rewrite `cl C = C`.

2. **Reconstruction via universal invariant closed sets**  
   Show every `x ∈ cl s` belongs to every closed invariant `C` containing `s` by Step 1.

3. **Reverse inclusion using separator witness**  
   Assume `x ∉ cl s`. By `tannakianSeparator`, choose `f`.
   Construct a candidate invariant closed set excluding `x`, typically `cl s` itself if you can prove invariance under all closure-preserving endomorphisms:
   ```lean
   f '' (cl s) ⊆ cl (f '' s) ⊆ cl (f '' (cl s)) = ...
   ```
   If full invariance of `cl s` fails, instead define the “largest witness-avoiding closed invariant” as an intersection of all closed supersets stable under the monoid and use separator to show `x` is omitted.

4. **Extensionality and monoid equality**  
   Once `reconstructsClosure` is established for both closures, rewrite the defining predicates using `hM`, then conclude by `funext` and `Set.ext`.

This route uses:
- `ext x; constructor <;> intro hx`,
- `by_contra hnot`,
- `rcases hsep hnot with ⟨f, hf⟩`,
- image membership reasoning with `rintro _ ⟨y, hy, rfl⟩`.

#### Strategy B: compact-generation / finite witness reconstruction
Good fallback if full separator invariance is technically difficult.

1. Use `AlgebraicLike` to show:
   ```lean
   x ∈ cl s ↔ ∃ t : Finset α, ↑t ⊆ s ∧ x ∈ cl (↑t : Set α)
   ```
2. Reduce closure equality to equality on finite generators.
3. Show endomorphism monoid equality determines finite closed hulls because separators can be tested on finitely generated closed sets.
4. Use finite-set induction on generators:
   - base case `∅`,
   - step `insert a t`,
   - combine monotonicity and idempotence.

This route is where to use induction and `omega` on generator sizes.

#### Strategy C: Galois reconstruction viewpoint
Use only if prior catalog infrastructure exposes a Galois connection.

1. Package closure as lower∘upper or upper∘lower from a Galois connection.
2. Show closure-preserving endomorphisms correspond to endomorphisms commuting with one adjoint side on compact generators.
3. Transfer equality of endomorphism monoids back to equality of closures via fixed-point extensionality.

This is elegant and aligns with the EML catalog, but only pursue it if APIs already exist.

---

### 7. Specific lemmas likely needed

Prove these helper lemmas explicitly.

```lean
theorem ClosedSet.closure_eq
    {cl : SetClosureOperator α} {C : Set α} :
    ClosedSet cl C → cl C = C
```

```lean
theorem closure_subset_closed_of_subset
    {cl : SetClosureOperator α} {s C : Set α} :
    s ⊆ C → ClosedSet cl C → cl s ⊆ C
```

```lean
theorem image_subset_of_closurePreserving
    {cl : SetClosureOperator α} (f : ClosurePreservingEnd α cl) (s : Set α) :
    f '' cl s ⊆ cl (f '' s)
```

```lean
theorem closure_of_finite_union_le
    {cl : SetClosureOperator α} (s t : Set α) :
    cl (s ∪ t) ⊆ cl (cl s ∪ cl t)
```

```lean
theorem algebraicLike_finite_witness
    {cl : SetClosureOperator α}
    (halg : AlgebraicLike cl) {x : α} {s : Set α} :
    x ∈ cl s → ∃ t : Finset α, (↑t : Set α) ⊆ s ∧ x ∈ cl (↑t : Set α)
```

```lean
theorem compactClosed_closed
    {cl : SetClosureOperator α} {K : Set α} :
    compactClosed cl K → ClosedSet cl K
```
using idempotence.

```lean
theorem finiteGeneratorRank_spec
    ...
```

```lean
theorem finiteGeneratorRank_minimal
    ...
```

```lean
theorem closureOrbit_subset_of_invariant
    ...
```

```lean
theorem quantum_entropy_closed_sector_reconstruction
    ...
```
This can be a mathematically straightforward corollary with a physics-facing name and doc comment, e.g. that invariant closed sectors are exactly the reconstructible observables.

---

### 8. Computational bounds and explicit constants

Include explicit finite bounds, even if simple.

If you define:
```lean
def closureComplexity (cl : SetClosureOperator α) (s : Finset α) : Nat :=
  Nat.sInf {n | ∃ t : Finset α, t.card ≤ n ∧ cl (s : Set α) = cl (t : Set α)}
```
prove:
```lean
theorem closureComplexity_le_card
    [Fintype α] (cl : SetClosureOperator α) (s : Finset α) :
    closureComplexity cl s ≤ Fintype.card α
```
by taking `t = Finset.univ`.

If you define:
```lean
def finiteGeneratorRank (cl : SetClosureOperator α) (K : Set α) : Nat := ...
```
prove:
```lean
theorem finiteGeneratorRank_le_card
    [Fintype α] {K : Set α} (hK : compactClosed cl K) :
    finiteGeneratorRank cl K ≤ Fintype.card α
```

If you introduce finite symmetric-difference distance on finsets:
```lean
def SetDistance (s t : Finset α) : Nat := (s \ t).card + (t \ s).card
```
prove at least:
```lean
theorem SetDistance_comm ...
theorem SetDistance_self ...
theorem SetDistance_le_twice_card [Fintype α] ...
```
and one certified robustness theorem:
```lean
theorem lipschitz_certified_robustness_identity
    : closureLipschitzBound (fun s : Finset α => s) 1
```
or for a simple finitary closure construction.

These theorems satisfy the utility requirement while staying provable.

---

### 9. Cross-domain doc comments and theorem naming

Add doc comments to key definitions/theorems, for example:

```lean
/--
Bridge: connects algebraic Tannaka reconstruction to EML fixed-point semantics.
The closure is reconstructed from its symmetry monoid of closure-preserving
endomorphisms, echoing observable-sector recovery in quantum semantics and
separator-based invariants in post_quantum lattice cryptography.
-/
theorem closure_eq_of_endMonoid_eq ...
```

```lean
/--
Bridge: connects compact generation in algebraic lattices to certified finite
witness extraction, an abstraction of lipschitz_certified_robustness where
small generators certify global closure membership.
-/
theorem algebraicLike_finite_witness ...
```

Use impact-bearing names:
- `quantum_entropy_closed_sector_reconstruction`
- `post_quantum_lattice_separator_bound`
- `lipschitz_certified_robustness_identity`
- `thermodynamic_fixedpoint_compact_generator`
- `certified_tannakian_separator_of_finite_rank`

---

### 10. Minimal theorem checklist

At minimum, prove all of the following or the strongest type-correct variants:

1. `ClosurePreservingEnd.ext`
2. monoid identity law
3. monoid associativity law
4. `closure_subset_closed_of_subset`
5. `compactClosed_closed`
6. `algebraicLike_finite_witness`
7. `finiteGeneratorRank_spec`
8. `finiteGeneratorRank_minimal`
9. `closureOrbit_monotone`
10. `InvariantClosed` closed-under-intersection lemma
11. `separator_detects_nonclosure`
12. `reconstructsClosure_of_separator`
13. reconstruction extensionality lemma
14. `closure_eq_of_endMonoid_eq`
15. pointwise membership corollary
16. `closureComplexity_le_card`
17. `finiteGeneratorRank_le_card`
18. `SetDistance_comm`
19. `lipschitz_certified_robustness_identity`
20. one theorem with `quantum` or `post_quantum` in the name proving a genuine corollary

Use diverse tactics:
- `induction` on finite generators / finsets,
- `rcases` for witness extraction,
- `by_contra` in separator arguments,
- `omega` or `linarith` for cardinality arithmetic,
- `field_simp` only if you introduce a rational normalized complexity ratio,
- `simp`, `aesop`, `ext`, `constructor`, `rfl` only as support tactics, not the entire proof style.

---

### 11. Fallback special cases if full generality is blocked

If equality of arbitrary endomorphism monoids is too difficult to transfer across bundled structures, prove a strong special case and state the general theorem as a precise conjecture:

```lean
theorem closure_eq_of_endMonoid_eq_finite
    [Fintype α]
    ...
```

or

```lean
theorem closure_eq_of_endMonoid_eq_on_compactClosed
    ...
```

Another good fallback:
- prove reconstruction on closures arising from a Galois insertion,
- or on closures defined by submodule/span-like hulls over semirings,
- or on finite distributive lattices.

But do not leave the file as a stub: build the full infrastructure and prove the strongest complete theorem available.

---

### 12. Deliverable structure

Organize the file into sections:

```lean
section BasicClosure
section EndMonoid
section CompactGeneration
section SeparatorReconstruction
section ComputationalBounds
section QuantumCryptoCorollaries
```

End with a structured comment block listing precise next conjectures in the file itself, and also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps such as:
1. reconstruct closure from enriched semiring-valued endomorphism actions,
2. lawvere-metric quantitative Tannaka duality with explicit Lipschitz constants,
3. post-quantum separator hardness from orbit growth in finite endomorphism monoids,
4. tropical/entropy analogues of closure reconstruction,
5. categorical lifting from set closures to enriched EML doctrines.

```lean
end AlgebraEMLReconstruction
end Bridges

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Formalize a reconstruction principle saying that a finitary EML closure system on an algebraic carrier is determined, up to canonical equivalence, by its monoid of closure-preserving endomorphisms together with the lattice of compact closed elements. Concretely: prove that for a noetherian/idempotent closure operator c on a semiring/module-like object X, the category of compact c-closed generators admits a faithful forgetful functor whose endomorphism monoid End_c(X) reconstructs c as an invariant-subobject operator. Derive a bidirectional correspondence between algebraic closure semantics and EML fixed-point semantics, extending recent condensation/Galois results into a genuine reconstruction theorem with computable certificates.

            ### Precise Mathematical Framing
            Target a precise chain of results: (1) define ClosureEnd := {f : X -> X | monotone f and f (c x) <= c (f x)} and the compact closed subobject poset Kc(X); (2) show Kc(X) is algebraic under finitary/noetherian hypotheses; (3) define the invariant closure c_End(A) as the infimum of End_c(X)-stable closed compacts containing A; (4) prove reconstruction c = c_End on compact generators; (5) prove uniqueness: if two finitary closures c,d have the same compact closed lattice and the same closure-preserving endomorphism monoid, then c=d; (6) package this as a duality/equivalence between a category of algebraic EML closures and a category of pointed endomorphism-monoid actions. Algorithmic payoff: finite generator data yields a computable closure certificate and fixed-point condensation pipeline. This is different from inflight Kantorovich/Lawvere work and from prior completed condensation semantics because it upgrades correspondence to reconstruction from internal symmetries, creating a new algebra/EML bridge analogous in spirit to Tannakian recovery but for closure dynamics.

            ### Lean 4 Sketch
Build in Bridges/AlgebraEMLReconstruction.lean. Reuse closure operator APIs, Galois connection lemmas, fixed-point lemmas, finite generation/noetherian induction, and semiring endomorphism structures. Main defs likely: `ClosurePreservingEnd`, `compactClosed`, `InvariantClosure`, `reconstructsClosure`, `closure_eq_of_endMonoid_eq`. Main lemmas via order-theoretic extensionality and finite compact generation.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `diagonal_fixed_point_idempotent` : theorem diagonal_fixed_point_idempotent (f : H → H) :
     (file: Bridges/EMLClosureCore.lean)
  2. `galois_closure_idempotent` : theorem galois_closure_idempotent {R : Type u} [Semiring R] (S : Set R) :
     (file: Bridges/ProofAlgGeomBridge.lean)
  3. `closure_has_least_fixed_point` : theorem closure_has_least_fixed_point {α : Type*} [CompleteLattice α]
     (file: Bridges/QuantumTropicalCore.lean)
  4. `constant_unique_fixed_point` : theorem constant_unique_fixed_point (c : ℝ) :
     (file: Bridges/Advanced.lean)
  5. `idempotent_image_eq_fixed` : theorem idempotent_image_eq_fixed (f : ℝ → ℝ) (hf : f ∘ f = f) :
     (file: Bridges/BreakthroughDirections.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Condensation Semantics for Algebraic–EML Fixed Points via Idempotent Galois Reconstruction, Berggren–Entropy Extractors: Rényi-2 Randomness Amplification from Primitive Pythagorean Triple Orbits, Arithmetic Stability of Operadic Neural Architectures via Height-Contraction and Valuation Generalization Bounds


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            @AutoResearch/Basic.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
* `four_products_congruent` — all four products of pair elements are mutually congruent
* `idempotent_sandwich_left` / `_right` — idempotent semiring sandwich lemmas
* `direct_cross_sum_congruent` — S₁ ≡ S₂ for product sums

## Counterexample

The originally conjectured `linResultantPair_mem_elimination` theorem is **false** in
general. A counterexample is provided in the Boolean semiring ({0,1}, OR, AND):
taking `p = (1, X)` and `q = (X, 1)`, the linResultantPair gives `(0, 1)`, but `0` and
`1` are not related by any congruence generated solely by `(1, X)`.
See `Speculative.CongruenceElimination.Counterexample` for a detailed formal analysis.
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

/-- Scaling on the left: `C.r (f * a) (f * b)` from `C.r a b`. -/
theorem mul_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f * a) (f * b) :=
  C.mul' (C.refl' f) h

/-- Scaling on the right: `C.r (a * f) (b * f)` from `C.r a b`. -/
theorem mul_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a * f) (b * f) :=
  C.mul' h (C.refl' f)

/-- Adding a common term on the left. -/
theorem add_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f + a) (f + b) :=
  C.add' (C.refl' f) h

/-- Adding a common term on the right. -/
theorem add_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a + f) (b + f) :=
  C.add' h (C.refl' f)

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-- Additive idempotency is inherited by `MvPolynomial σ S`. -/
instance MvPolynomial.addIdempotent {S : Type*} [CommSemiring S] [AddIdempotent S]
    {σ : Type*} : AddIdempotent (MvPolynomial σ S) where
  add_self p := by
    ext m
    simp [MvPolynomial.coeff_add, add_self_eq]

/-- Additive idempotency is inherited by `Polynomial R`. -/
instance Polynomial.addIdempotent {R : Type*} [Semiring R] [AddIdempotent R] :
    AddIdempotent (Polynomial R) where
  add_self p := by
    ext n
    simp [Polynomial.coeff_add, add_self_eq]

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator `lhs ≡ rhs`. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
-- ... (truncated, full file has 559 lines)
```


### Catalog Reference Files
            @AutoResearch/Basic.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
* `four_products_congruent` — all four products of pair elements are mutually congruent
* `idempotent_sandwich_left` / `_right` — idempotent semiring sandwich lemmas
* `direct_cross_sum_congruent` — S₁ ≡ S₂ for product sums

## Counterexample

The originally conjectured `linResultantPair_mem_elimination` theorem is **false** in
general. A counterexample is provided in the Boolean semiring ({0,1}, OR, AND):
taking `p = (1, X)` and `q = (X, 1)`, the linResultantPair gives `(0, 1)`, but `0` and
`1` are not related by any congruence generated solely by `(1, X)`.
See `Speculative.CongruenceElimination.Counterexample` for a detailed formal analysis.
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

/-- Scaling on the left: `C.r (f * a) (f * b)` from `C.r a b`. -/
theorem mul_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f * a) (f * b) :=
  C.mul' (C.refl' f) h

/-- Scaling on the right: `C.r (a * f) (b * f)` from `C.r a b`. -/
theorem mul_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a * f) (b * f) :=
  C.mul' h (C.refl' f)

/-- Adding a common term on the left. -/
theorem add_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f + a) (f + b) :=
  C.add' (C.refl' f) h

/-- Adding a common term on the right. -/
theorem add_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a + f) (b + f) :=
  C.add' h (C.refl' f)

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-- Additive idempotency is inherited by `MvPolynomial σ S`. -/
instance MvPolynomial.addIdempotent {S : Type*} [CommSemiring S] [AddIdempotent S]
    {σ : Type*} : AddIdempotent (MvPolynomial σ S) where
  add_self p := by
    ext m
    simp [MvPolynomial.coeff_add, add_self_eq]

/-- Additive idempotency is inherited by `Polynomial R`. -/
instance Polynomial.addIdempotent {R : Type*} [Semiring R] [AddIdempotent R] :
    AddIdempotent (Polynomial R) where
  add_self p := by
    ext n
    simp [Polynomial.coeff_add, add_self_eq]

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator `lhs ≡ rhs`. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
-- ... (truncated, full file has 559 lines)
```


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
