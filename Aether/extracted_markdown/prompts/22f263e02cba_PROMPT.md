## YOUR ASSIGNMENT: algebra_breakthrough_discovery

**TARGET DOMAIN**: Algebra

**PRECISE ASSIGNMENT**: Do not merely “survey” Algebra; extract a structural organizing principle from the existing infrastructure around `Advanced`, `GaloisTheory`, `InvertedTreeAdvanced`, and the additive-combinatorial file on Montgomery pair correlation. The most promising breakthrough target is to formalize a **Galois connection / order-isomorphism architecture** behind intermediate objects, closures, and inversion/reindexing constructions, and then prove that the resulting posets are functorial and transport algebraic structure.

A concrete high-value target is to build a reusable lattice-theoretic interface for “subobjects determined by stabilizers/fixed points/closures” and prove one genuinely structural theorem: that the closure operators arising in the algebra files induce order isomorphisms or antitone equivalences between naturally associated subobject posets.

You should aim to define and prove a theorem schema of the following flavor, specialized to whatever objects actually exist in the referenced files:

```lean
/-- A generic closure operator on a preorder. -/
structure ClosureOperator (α : Type*) [Preorder α] where
  toFun : α → α
  monotone' : Monotone toFun
  le_closure' : ∀ a, a ≤ toFun a
  idempotent' : ∀ a, toFun (toFun a) = toFun a

/-- Closed elements for a closure operator. -/
def IsClosed {α : Type*} [Preorder α] (c : ClosureOperator α) (a : α) : Prop :=
  c.toFun a = a
```

and then establish a theorem of the form

```lean
theorem closedElements_completeLattice
    (α : Type*) [CompleteLattice α] (c : ClosureOperator α) :
    CompleteLattice {a : α // IsClosed c a}
```

or, if that is too infrastructure-heavy for the current catalog, at minimum:

```lean
theorem closureOperator_induces_galois_insertion
    (α : Type*) [PartialOrder α] (c : ClosureOperator α)
    (h_inf : ∀ a b, c.toFun (a ⊓ b) = c.toFun (c.toFun a ⊓ c.toFun b)) :
    ∃ gi : GaloisInsertion (fun a : {a : α // IsClosed c a} => (a : α)) c.toFun, True
```

This is not an arbitrary abstraction: it is the right infrastructure for organizing intermediate fields, fixed substructures, invariant subobjects, and “inverted tree” closure constructions under one formal umbrella.

A second concrete theorem target, if the Galois-theory file exposes the usual correspondence infrastructure, is an order-theoretic packaging of the fundamental theorem of Galois theory as an order isomorphism:

```lean
theorem intermediateField_orderIso_op_subgroup
    {K L : Type*} [Field K] [Field L] [Algebra K L]
    [FiniteDimensional K L] [Normal K L] [Separable K L] :
    Nonempty ((IntermediateField K L) ≃o OrderDual (Subgroup (L ≃ₐ[K] L)))
```

If the exact hypotheses or target types differ from Mathlib’s available statements, adapt to the existing theorem names in `GaloisTheory.lean`, but preserve the ambition: package the correspondence as an explicit `OrderIso`, and then prove transport lemmas showing how lattice operations correspond.

A third target, designed to connect the additive-combinatorial file to the structural algebra files, is to define a notion of “invariant statistic under algebraic symmetry” and prove transport along equivalences:

```lean
def InvariantStatistic
    (G : Type*) [Group G] (α : Type*) [MulAction G α] (β : Type*) :=
  {f : α → β // ∀ g x, f (g • x) = f x}

theorem invariantStatistic_comp_equiv
    {G : Type*} [Group G]
    {α β γ : Type*} [MulAction G α] [MulAction G β]
    (e : α ≃ β)
    (he : ∀ g x, e (g • x) = g • e x)
    (f : InvariantStatistic G β γ) :
    InvariantStatistic G α γ
```

This gives a formal mechanism to move “pair correlation”-type statistics across algebraic models when the underlying objects are equivariantly equivalent.

---

## PRECISE THEOREM STATEMENTS

Prioritize proving **one major structural theorem** and **2–4 transport/corollary theorems** around it. Suitable exact Lean targets include:

```lean
structure ClosureOperator (α : Type*) [Preorder α] where
  toFun : α → α
  monotone' : Monotone toFun
  le_closure' : ∀ a, a ≤ toFun a
  idempotent' : ∀ a, toFun (toFun a) = toFun a

def IsClosed {α : Type*} [Preorder α] (c : ClosureOperator α) (a : α) : Prop :=
  c.toFun a = a

theorem closure_eq_iff_isClosed
    {α : Type*} [Preorder α] (c : ClosureOperator α) (a : α) :
    c.toFun a = a ↔ IsClosed c a := Iff.rfl

theorem closure_monotone
    {α : Type*} [Preorder α] (c : ClosureOperator α) :
    Monotone c.toFun := c.monotone'

theorem closure_fixpoint_closed_under_closure
    {α : Type*} [Preorder α] (c : ClosureOperator α) (a : α) :
    IsClosed c (c.toFun a) := c.idempotent' a
```

If complete-lattice infrastructure is tractable:

```lean
def ClosedElements (α : Type*) [Preorder α] (c : ClosureOperator α) :=
  {a : α // IsClosed c a}

theorem closedElements_orderEmbedding
    {α : Type*} [PartialOrder α] (c : ClosureOperator α) :
    OrderEmbedding (fun a : ClosedElements α c => (a : α))
```

If the Galois correspondence is already partially present, prove explicit order-level transport:

```lean
theorem top_intermediateField_corresponds_bot_subgroup
    {K L : Type*} [Field K] [Field L] [Algebra K L]
    [FiniteDimensional K L] [Normal K L] [Separable K L]
    (e : (IntermediateField K L) ≃o OrderDual (Subgroup (L ≃ₐ[K] L))) :
    e ⊤ = ⊥

theorem inf_intermediateField_corresponds_sup_subgroup
    {K L : Type*} [Field K] [Field L] [Algebra K L]
    [FiniteDimensional K L] [Normal K L] [Separable K L]
    (e : (IntermediateField K L) ≃o OrderDual (Subgroup (L ≃ₐ[K] L)))
    (E₁ E₂ : IntermediateField K L) :
    e (E₁ ⊓ E₂) = e E₁ ⊔ e E₂
```

If the exact `OrderIso` is unavailable but a pair of monotone inverse maps exists in the catalog, construct the `OrderIso` yourself from those data.

A bolder target, if `InvertedTreeAdvanced.lean` really contains a recursive/tree inversion object with a partial order, is:

```lean
theorem inversion_operator_is_closure
    {α : Type*} [Preorder α]
    (inv : α → α)
    (hmon : Monotone inv)
    (hle : ∀ a, a ≤ inv a)
    (hidem : ∀ a, inv (inv a) = inv a) :
    ClosureOperator α
```

followed by instantiations showing that the inversion construction in that file is not ad hoc but an example of a universal closure phenomenon.

---

## PROOF STRATEGY

### Strategy A: Build a reusable closure/Galois-insertion layer, then instantiate it
This is the most promising route because it converts disparate algebraic constructions into one reusable theorem engine.

1. **Extract the algebraic pattern from the existing files.**
   Search for operators with the three hallmark properties:
   - monotone,
   - extensive (`x ≤ c x`),
   - idempotent (`c (c x) = c x`).
   Candidates include closure-like constructions on intermediate objects, stabilizers/fixed fields, or inversion/tree hulls.

2. **Package the pattern as a structure.**
   Define `ClosureOperator` and `IsClosed`.
   Prove immediate lemmas:
   ```lean
   theorem le_closure {α} [Preorder α] (c : ClosureOperator α) (a : α) : a ≤ c.toFun a
   theorem closure_closed {α} [Preorder α] (c : ClosureOperator α) (a : α) : IsClosed c (c.toFun a)
   theorem closed_iff_closure_eq {α} [Preorder α] (c : ClosureOperator α) (a : α) :
     IsClosed c a ↔ c.toFun a = a
   ```

3. **Construct the subposet of closed elements.**
   Give it the inherited order via subtype instances.
   Then prove that the inclusion map and closure map form a Galois insertion whenever the ambient order structure is sufficient.
   Key proof pattern:
   - show `x ≤ closed_inclusion y ↔ c x ≤ y`,
   - use `y` closed to rewrite `c y = y`,
   - use monotonicity and extensivity.

4. **Instantiate in the strongest algebraic setting available.**
   If `GaloisTheory.lean` contains maps such as subgroup ↔ fixed field or intermediate field ↔ automorphism subgroup, prove these maps are examples of the abstract machine.
   The deepest outcome is not merely one correspondence theorem, but a theorem saying:
   “this correspondence is the manifestation of a closure operator / Galois insertion.”

5. **Derive lattice transport theorems.**
   Once you have an `OrderIso` or `GaloisInsertion`, prove preservation/reversal formulas for `⊓`, `⊔`, `⊤`, `⊥`.
   These are often one-line consequences from `OrderIso` API but are conceptually powerful.

### Strategy B: Reconstruct the Galois correspondence as an explicit `OrderIso`
This is ideal if the needed maps already exist in Mathlib or in `GaloisTheory.lean`.

1. Identify the forward and backward maps, likely:
   - `IntermediateField K L → Subgroup (L ≃ₐ[K] L)` via automorphisms fixing the field,
   - `Subgroup (L ≃ₐ[K] L) → IntermediateField K L` via fixed field.
2. Prove monotonicity/antitonicity carefully.
3. Prove the triangular identities under finite Galois hypotheses:
   - fixed field of fixing subgroup is the original field,
   - fixing subgroup of fixed field is the original subgroup.
4. Package the correspondence as an `OrderIso` into an `OrderDual`.
5. Derive transport theorems for inf/sup and top/bot.

This route is breakthrough-worthy because it converts isolated theorems into a composable categorical/algebraic interface.

### Strategy C: Symmetry transport for additive-combinatorial statistics
Use this if the pair-correlation file exposes functions/statistics on algebraic objects with natural symmetries.

1. Define `InvariantStatistic` for a group action.
2. Prove pullback/pushforward along equivariant equivalences.
3. Show that any algebraically defined statistic in the Montgomery file that is invariant under a natural action can be transported across equivalent models.
4. If possible, prove a theorem that pair-correlation data depends only on orbit structure:
   ```lean
   theorem invariantStatistic_eq_on_orbit
       {G α β} [Group G] [MulAction G α]
       (f : InvariantStatistic G α β) {x y : α}
       (h : ∃ g, g • x = y) :
       f.1 x = f.1 y
   ```
This opens a bridge between additive combinatorics and algebraic symmetry methods.

---

## CONCRETE PROOF STEPS AND KEY LEMMAS

1. **Mine the existing files for maps already satisfying adjunction-like properties.**
   Search for:
   - `gc`, `gi`, `OrderIso`, `fixingSubgroup`, `fixedField`,
   - monotonicity lemmas,
   - closure/idempotence lemmas,
   - “inversion” operators on trees/substructures.
   If a theorem is present only as two inequalities, assemble it into a stronger packaged theorem.

2. **Use subtype/order inheritance aggressively.**
   For closed elements:
   ```lean
   def ClosedElements (α : Type*) [Preorder α] (c : ClosureOperator α) :=
     {a : α // c.toFun a = a}
   ```
   The key technical trick is rewriting through subtype equalities with `Subtype.ext` and using `simp [IsClosed, ClosedElements]`.

3. **Exploit `OrderIso`, `GaloisConnection`, and `GaloisInsertion` APIs.**
   Mathlib has strong order-theoretic infrastructure. Once you can prove the defining biconditional
   ```lean
   l a ≤ b ↔ a ≤ u b
   ```
   many lattice consequences follow abstractly. This is much better than proving each transport theorem ad hoc.

4. **When proving correspondence theorems, isolate the hard algebra in triangular identities.**
   The order isomorphism proof should be decomposed into:
   - map definitions,
   - monotonicity/antitonicity,
   - left inverse,
   - right inverse.
   Once these are in place, the `OrderIso` construction is routine.

5. **Turn every major theorem into an algorithmic shadow.**
   If you prove an order isomorphism, also define the actual computable map and prove simplification lemmas:
   ```lean
   @[simp] theorem orderIso_apply_symm_apply ...
   @[simp] theorem orderIso_symm_apply_apply ...
   theorem mem_fixedField_iff ...
   theorem mem_fixingSubgroup_iff ...
   ```
   These lemmas make the result usable for later automation.

---

## WHAT COUNTS AS A BREAKTHROUGH HERE

The breakthrough is not one isolated theorem but the discovery that several apparently separate algebraic constructions in the catalog are manifestations of the same order-theoretic machine:

- closure operators,
- Galois insertions/connections,
- anti-equivalences of subobject lattices,
- symmetry-invariant statistics transported along equivariant equivalence.

If you succeed, Algebra stops being a bag of 8610 declarations and becomes a navigable architecture. That matters because:

1. **It opens a bridge to Category/Order theory immediately.**
   Once correspondences are packaged as `OrderIso`/`GaloisInsertion`, they can be reused across fields, groups, modules, lattices, and topology.

2. **It creates a reusable formalization pattern.**
   Future files can instantiate the closure/Galois framework instead of reproving bespoke monotonicity and fixed-point lemmas.

3. **It gives additive combinatorics an algebraic symmetry interface.**
   Transporting invariant statistics across algebraic equivalences is the first step toward genuine bridges between combinatorial observables and algebraic automorphism groups.

4. **It has algorithmic consequences.**
   Explicit order isomorphisms and closure operators can be computed, normalized, and used to canonicalize algebraic data.

5. **It opens three next doors immediately.**
   - categorical reformulation of Galois correspondences,
   - closure systems on module/submodule/subalgebra lattices,
   - symmetry transport of analytic/combinatorial statistics.

---

## IF A FULL THEOREM IS OUT OF REACH

State precise conjectures with Lean-style signatures, for example:

```lean
conjecture fixedField_fixingSubgroup_orderIso
    {K L : Type*} [Field K] [Field L] [Algebra K L]
    [FiniteDimensional K L] [Normal K L] [Separable K L] :
    Nonempty ((IntermediateField K L) ≃o OrderDual (Subgroup (L ≃ₐ[K] L)))
```

```lean
conjecture inversion_closedElements_distributive
    {α : Type*} [DistribLattice α] (c : ClosureOperator α) :
    DistribLattice (ClosedElements α c)
```

```lean
conjecture pairCorrelation_invariant_under_equivariant_equiv
    {G : Type*} [Group G]
    {α β : Type*} [MulAction G α] [MulAction G β]
    (e : α ≃ β)
    (he : ∀ g x, e (g • x) = g • e x)
    (pcα : InvariantStatistic G α ℝ)
    (pcβ : InvariantStatistic G β ℝ) :
    True
```

These are worthwhile only if accompanied by a clear explanation of which existing lemmas almost prove them and what obstruction remains.

---

## REQUIRED OUTPUT ARTIFACTS

1. A Lean file containing:
   - new organizing definitions,
   - at least one substantial structural theorem,
   - 2–4 corollaries/transport lemmas.

2. Definitions should be designed for reusability, not one-off local hacks.

3. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - extending closure/Galois infrastructure from intermediate fields to submodules/subalgebras,
   - categorifying the order isomorphism into a contravariant equivalence,
   - transporting pair-correlation or spectral statistics along algebraic symmetries,
   - extracting canonical algorithms from closure normal forms,
   - building a unified “algebraic fixed-point correspondence” library.

### Catalog Reference Files
            @Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34
-/


noncomputable section

/-- The difference set of a finite set S: all values s - t for s, t ∈ S. -/
def differenceSet (S : Finset ℤ) : Finset ℤ :=
  (S ×ˢ S).image (fun p => p.1 - p.2)




/-- The nonzero difference set — excludes the trivial zero difference. -/
def nonzeroDifferenceSet (S : Finset ℤ) : Finset ℤ :=
  (differenceSet S).filter (· ≠ 0)




/-- Zero is always in the difference set of a nonempty set. -/
theorem zero_mem_differenceSet {S : Finset ℤ} (hS : S.Nonempty) :
    (0 : ℤ) ∈ differenceSet S := by
  obtain ⟨x, hx⟩ := hS
  simp only [differenceSet, Finset.mem_image, Finset.mem_product]
  exact ⟨⟨x, x⟩, ⟨hx, hx⟩, sub_self x⟩




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem nonzero_diff_card_le (S : Finset ℤ) :
    (nonzeroDifferenceSet S).card ≤ S.card ^ 2 - S.card := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun p : ℤ × ℤ => p.1 - p.2 ) ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) );
  · unfold nonzeroDifferenceSet differenceSet;
    intro x hx; aesop;
  · refine' le_trans ( Finset.card_image_le ) _;
    rw [ show ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext ⟨ x, y ⟩ ; aesop ] ; simp +decide [ sq, Finset.offDiag_card ]




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem sidon_diff_card (S : Finset ℤ) (hS : IsSidonSet S) :
    (nonzeroDifferenceSet S).card = S.card * (S.card - 1) := by
  -- For a Sidon set, every nonzero difference d = s - t with s ≠ t appears exactly once. The total number of ordered pairs (s,t) with s ≠ t is |S|*(|S|-1). Each such pair contributes a unique nonzero difference (this is the Sidon condition). So the number of distinct nonzero differences equals |S|*(|S|-1).
  have h_diff_set_card : ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)).card = S.card * (S.card - 1) := by
    simp +contextual [ Finset.filter_ne, Finset.card_product ];
    rw [ show ( Finset.filter ( fun p => ¬p.1 = p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext; aesop ] ; simp +decide [ Finset.offDiag_card ];
    rw [ Nat.mul_sub_left_distrib, Nat.mul_one ];
  -- Since these pairs contribute distinct nonzero differences, the cardinality of the nonzero difference set is equal to the cardinality of the set of pairs.
  have h_distinct_diffs : Finset.image (fun p : ℤ × ℤ => p.1 - p.2) ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)) = nonzeroDifferenceSet S := by
    ext; simp [differenceSet, nonzeroDifferenceSet];
    grind +ring;
  rw [ ← h_diff_set_card, ← h_distinct_diffs, Finset.card_image_of_injOn ];
  intro p hp q hq; have := hS ( p.1 - p.2 ) ; simp_all +decide [ Set.InjOn ] ;
  intro h; have := this ( sub_ne_zero_of_ne hp.2 ) ; simp_all +decide [ autocorrelation ] ;
  contrapose! this;
  refine' Finset.one_lt_card.mpr ⟨ p, _, q, _, _ ⟩ <;> aesop




/-- The autocorrelation energy: sum of squared autocorrelation values over
the difference set. This measures departure from randomness. -/
def autocorrelationEnergy (S : Finset ℤ) : ℕ :=
  ∑ d ∈ differenceSet S, (autocorrelation S d) ^ 2




theorem autocorrelation_total_sum (S : Finset ℤ) :
    ∑ d ∈ differenceSet S, autocorrelation S d = S.card ^ 2 := by
  unfold differenceSet autocorrelation;
  rw [ Finset.sum_image' ];
  rotate_left;
  use fun _ => 1;
  · aesop;
  · norm_num [ sq ]




/-- The number of "additive quadruples" (a,b,c,d) with a-b = c-d. -/
def additiveQuadruples (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).filter (fun p => p.1 - p.2 = 0)).card  -- simplified placeholder




/-- The Sidon defect: number of nonzero differences with multiplicity ≥ 2. -/
def sidonDefect (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).image (fun p => p.1 - p.2) |>.filter
    (fun d => d ≠ 0 ∧ 1 < autocorrelation S d)).card




theorem sidon_iff_defect_zero (S : Finset ℤ) :
    IsSidonSet S ↔ sidonDefect S = 0 := by
  rw [ sidonDefect ];
  constructor;
  · aesop;
  · intro h;
    intro d hd; contrapose! h; simp_all +decide [ Finset.ext_iff ] ;
    obtain ⟨ p, hp ⟩ := Finset.card_pos.mp ( pos_of_gt h ) ; use p.1, by aesop, p.2; aesop;




/-- Compute the Sidon defect of a list-represented set. -/
def sidonDefectCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.countP (fun d =>
    1 < (S.product S).countP (fun p => p.1 - p.2 = d))




/-- Compute maximum autocorrelation value for d ≠ 0. -/
def maxAutocorrCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.foldl (fun acc d =>
    max acc ((S.product S).countP (fun p => p.1 - p.2 = d))) 0




/-- Compute autocorrelation energy. -/
def autocorrEnergyCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let allDiffs := diffs.eraseDups
  allDiffs.foldl (fun acc d =>
    acc + ((S.product S).countP (fun p => p.1 - p.2 = d))^2) 0

-- ... (truncated, full file has 409 lines)
```

@Algebra/Advanced/Advanced.lean
```lean
import Mathlib

/-! # CatalogBuild.Computation.Oracles.Advanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16
-/


noncomputable section

/-- O₁ refines O₂ if every fixed point of O₁ is a fixed point of O₂. -/
def OracleRefines {X : Type*} (O₁ O₂ : X → X) : Prop :=
  ∀ x, O₁ x = x → O₂ x = x




/-- [Section: # CatalogBuild.Computation.Oracles.Advanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem oracleRefines_refl {X : Type*} (O : X → X) : OracleRefines O O :=
  fun _ h => h




/-- [Section: # CatalogBuild.Computation.Oracles.Advanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem oracleRefines_trans {X : Type*} (O₁ O₂ O₃ : X → X)
    (h₁₂ : OracleRefines O₁ O₂) (h₂₃ : OracleRefines O₂ O₃) :
    OracleRefines O₁ O₃ :=
  fun x hx => h₂₃ x (h₁₂ x hx)




theorem idem_compose_self {X : Type*} (f : X → X) (hf : ∀ x, f (f x) = f x) :
    f ∘ f = f := funext hf




theorem binaryEntropy_nonneg (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ binaryEntropy p := by
  unfold binaryEntropy;
  split_ifs <;> nlinarith [ Real.logb_neg ( show 1 < 2 by norm_num ) hp0 hp1, Real.logb_neg ( show 1 < 2 by norm_num ) ( show 0 < 1 - p by linarith ) ( show 1 - p < 1 by linarith ) ]




theorem binaryEntropy_half : binaryEntropy (1/2 : ℝ) = 1 := by
  unfold binaryEntropy; norm_num;
  norm_num [ Real.logb_div ]




/-- A constant oracle has a unique fixed point. -/
theorem constant_unique_fixed_point (c : ℝ) :
    ∃! x : ℝ, (fun _ => c) x = x :=
  ⟨c, rfl, fun y hy => hy.symm⟩




/-- Idempotent maps converge in one step. -/
theorem idem_one_step (f : ℝ → ℝ) (hf : ∀ x, f (f x) = f x) (x : ℝ) :
    f x = f (f x) := (hf x).symm




theorem mobius_compose (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ x : ℝ)
    (h : c₂ * x + d₂ ≠ 0)
    (h' : c₁ * mobiusTransform a₂ b₂ c₂ d₂ x + d₁ ≠ 0) :
    mobiusTransform a₁ b₁ c₁ d₁ (mobiusTransform a₂ b₂ c₂ d₂ x) =
    (a₁ * (a₂ * x + b₂) + b₁ * (c₂ * x + d₂)) /
    (c₁ * (a₂ * x + b₂) + d₁ * (c₂ * x + d₂)) := by
  unfold mobiusTransform; simp_all +decide [ mul_comm, mul_assoc, mul_left_comm ] ; ring;
  grind




/-- Meta-oracle: selects the best oracle from a family. -/
structure MetaGeodesicOracle (α : Type*) where
  family : α → (ℝ → ℝ)
  idem : ∀ i, ∀ x, family i (family i x) = family i x
  selectIdx : ℝ → α




/-- Meta-oracle consultation. -/
def MetaGeodesicOracle.consult {α : Type*} (M : MetaGeodesicOracle α) (x : ℝ) : ℝ :=
  M.family (M.selectIdx x) x




/-- With constant selector, meta-oracle is a standard oracle. -/
theorem MetaGeodesicOracle.constant_selector_is_oracle {α : Type*}
    (M : MetaGeodesicOracle α) (i : α) (hsel : ∀ x, M.selectIdx x = i) :
    ∀ x, M.consult (M.consult x) = M.consult x := by
  intro x
  simp only [MetaGeodesicOracle.consult, hsel]
  exact M.idem i _




/-- N-dimensional inverse stereographic projection ℝⁿ → Sⁿ ⊂ ℝⁿ⁺¹. -/
def invStereoN (n : ℕ) (x : Fin n → ℝ) : Fin (n + 1) → ℝ :=
  let s := ∑ i, x i ^ 2
  fun i =>
    if h : i.val < n then
      2 * x ⟨i.val, h⟩ / (1 + s)
    else
      (s - 1) / (1 + s)




theorem invStereoN_on_sphere (n : ℕ) (x : Fin n → ℝ) :
    ∑ i : Fin (n + 1), (invStereoN n x i) ^ 2 = 1 := by
  unfold invStereoN;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_pow, Finset.sum_mul _ _ _, div_pow ];
  norm_num [ Finset.sum_ite, Fin.sum_univ_castSucc ];
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_div ];
  rw [ ← add_div, div_eq_iff ] <;> nlinarith [ show 0 ≤ ∑ i, x i ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]




theorem hypothesis_crystallization (f : ℝ → ℝ) (hf : ∀ x, f (f x) = f x) (x : ℝ) :
    f (f x) = f x := hf x

-- H4: Idempotent partition into fixed/non-fixed



theorem idem_partition {α : Type*} [DecidableEq α] (f : α → α)
    (hf : ∀ x, f (f x) = f x) (x : α) :
    f x = x ∨ (f x ≠ x ∧ f (f x) = f x) := by
  by_cases h : f x = x
-- ... (truncated, full file has 157 lines)
```

@Algebra/Advanced/GaloisTheory.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Advanced.GaloisTheory

Auto-generated from theorem catalog database.
Domain: Algebra/Advanced
Declarations: 8
-/


/-- [Section: # CatalogBuild.Algebra.Advanced.GaloisTheory
Auto-generated from theorem catalog database.
Domain: Algebra/Advanced
Declarations: 8] -/
theorem gf2_card : Fintype.card (ZMod 2) = 2 := by decide



/-- [Section: # CatalogBuild.Algebra.Advanced.GaloisTheory
Auto-generated from theorem catalog database.
Domain: Algebra/Advanced
Declarations: 8] -/
theorem gf3_card : Fintype.card (ZMod 3) = 3 := by decide




theorem frobenius_endomorphism' (p : ℕ) [Fact (Nat.Prime p)] (x : ZMod p) :
    x ^ p = x := ZMod.pow_card x




theorem cyclotomic_degree' (n : ℕ) :
    (cyclotomic n ℤ).natDegree = Nat.totient n :=
  Polynomial.natDegree_cyclotomic n ℤ




theorem cyclotomic_monic' (n : ℕ) : (cyclotomic n ℤ).Monic :=
  Polynomial.cyclotomic.monic n ℤ




theorem prod_cyclotomic' (n : ℕ) (hn : 0 < n) :
    ∏ d ∈ Nat.divisors n, cyclotomic d ℤ = X ^ n - 1 :=
  Polynomial.prod_cyclotomic_eq_X_pow_sub_one hn ℤ




theorem tower_degree' (F K L : Type*) [Field F] [Field K] [Field L]
    [Algebra F K] [Algebra K L] [Algebra F L] [IsScalarTower F K L]
    [FiniteDimensional F K] [FiniteDimensional K L] :
    Module.finrank F K * Module.finrank K L = Module.finrank F L :=
  Module.finrank_mul_finrank F K L




theorem complex_over_real_degree' : Module.finrank ℝ ℂ = 2 :=
  Complex.finrank_real_complex
```

@Algebra/Advanced/InvertedTreeAdvanced.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.InvertedTreeAdvanced

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 90
-/

/-- Forward Berggren transform B₁. -/
def fwdB₁ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Forward Berggren transform B₂. -/
def fwdB₂ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Forward Berggren transform B₃. -/
def fwdB₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The p-parameter: shared first component of B₁⁻¹ and B₂⁻¹. -/
def berggren_p (a b c : ℤ) : ℤ := a + 2*b - 2*c

/-- The q-parameter: shared second component of B₂⁻¹ and B₃⁻¹. -/
def berggren_q (a b c : ℤ) : ℤ := 2*a + b - 2*c

/-- The h-parameter: universal parent hypotenuse. -/
def berggren_h (a b c : ℤ) : ℤ := -2*a - 2*b + 3*c

/-- **Component Sharing (1,2)**: B₁⁻¹ and B₂⁻¹ share the same first component. -/
theorem invB₁_fst_eq_invB₂_fst (a b c : ℤ) :
    (invB₁ a b c).1 = (invB₂ a b c).1 := by
  simp [invB₁, invB₂]

/-- **Component Sharing (2,3)**: B₂⁻¹ and B₃⁻¹ share the same second component. -/
theorem invB₂_snd_eq_invB₃_snd (a b c : ℤ) :
    (invB₂ a b c).2.1 = (invB₃ a b c).2.1 := by
  simp [invB₂, invB₃]

/-- **Universal Hypotenuse**: All three produce the same third component. -/
theorem all_hyp_eq₁₂ (a b c : ℤ) :
    (invB₁ a b c).2.2 = (invB₂ a b c).2.2 := by
  simp [invB₁, invB₂]

/-- [Section: # Inverted Berggren Tree — Advanced Theorems
New discoveries about the inverted Berggren tree structure.
## Main Results
1. **Ghost Triple Structure**: All three inverse images are (p, -q, h), (p, q, h), (-p, q, h)
— related by sign flips of two canonical parameters p and q.
2. **Branch Determination**: The valid parent branch is determined by signs of
p = a + 2b - 2c and q = 2a + b - 2c.
3. **Euclid Parameterization**: Branch determination in terms of Euclid (m,n) parameters.
4. **Parent Hypotenuse = Sum of Squares**: h = (m-2n)² + n² for Euclid triples.
5. **Ghost Pythagorean**: If (a,b,c) is Pythagorean, then (p,q,h) is also Pythagorean.
6. **Parity Conservation**: p ≡ a, q ≡ b, h ≡ c (mod 2).] -/
theorem all_hyp_eq₂₃ (a b c : ℤ) :
    (invB₂ a b c).2.2 = (invB₃ a b c).2.2 := by
  simp [invB₂, invB₃]

/-- **Ghost Structure**: B₁⁻¹ first component = p. -/
theorem invB₁_fst_eq_p (a b c : ℤ) :
    (invB₁ a b c).1 = berggren_p a b c := by
  simp [invB₁, berggren_p]

/-- B₁⁻¹ second component = -q. -/
theorem invB₁_snd_eq_neg_q (a b c : ℤ) :
    (invB₁ a b c).2.1 = -berggren_q a b c := by
  simp [invB₁, berggren_q]; ring

/-- B₂⁻¹ second component = q. -/
theorem invB₂_snd_eq_q (a b c : ℤ) :
    (invB₂ a b c).2.1 = berggren_q a b c := by
  simp [invB₂, berggren_q]

/-- B₃⁻¹ first component = -p. -/
theorem invB₃_fst_eq_neg_p (a b c : ℤ) :
    (invB₃ a b c).1 = -berggren_p a b c := by
  simp [invB₃, berggren_p]; ring

/-- All three share hypotenuse = h. -/
theorem inv_hyp_eq_h (a b c : ℤ) :
    (invB₁ a b c).2.2 = berggren_h a b c := by
  simp [invB₁, berggren_h]

/-- **Sign Opposition (1↔3)**: First components of B₁⁻¹ and B₃⁻¹ sum to zero. -/
theorem invB₁_fst_neg_invB₃_fst (a b c : ℤ) :
    (invB₁ a b c).1 = -(invB₃ a b c).1 := by
  simp [invB₁, invB₃]; ring

/-- **Sign Opposition (1↔2)**: Second components of B₁⁻¹ and B₂⁻¹ sum to zero. -/
theorem invB₁_snd_neg_invB₂_snd (a b c : ℤ) :
    (invB₁ a b c).2.1 = -(invB₂ a b c).2.1 := by
  simp [invB₁, invB₂]; ring

/-- **Sign Opposition (2↔3)**: First components of B₂⁻¹ and B₃⁻¹ sum to zero. -/
theorem invB₂_fst_neg_invB₃_fst (a b c : ℤ) :
    (invB₂ a b c).1 = -(invB₃ a b c).1 := by
  simp [invB₂, invB₃]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Branch Determination
-- ═══════════════════════════════════════════════════════════════

/-- B₁⁻¹ = (p, -q, h) is all-positive iff p > 0, q < 0, h > 0. -/
theorem branch1_positive_iff (a b c : ℤ) :
    (0 < (invB₁ a b c).1 ∧ 0 < (invB₁ a b c).2.1 ∧ 0 < (invB₁ a b c).2.2) ↔
    (0 < berggren_p a b c ∧ berggren_q a b c < 0 ∧ 0 < berggren_h a b c) := by
  rw [invB₁_fst_eq_p, invB₁_snd_eq_neg_q, inv_hyp_eq_h]
  constructor
  · intro ⟨ha, hb, hc⟩; exact ⟨ha, by linarith, hc⟩
  · intro ⟨ha, hb, hc⟩; exact ⟨ha, by linarith, hc⟩

/-- B₂⁻¹ = (p, q, h) is all-positive iff p > 0, q > 0, h > 0. -/
theorem branch2_positive_iff (a b c : ℤ) :
    (0 < (invB₂ a b c).1 ∧ 0 < (invB₂ a b c).2.1 ∧ 0 < (invB₂ a b c).2.2) ↔
    (0 < berggren_p a b c ∧ 0 < berggren_q a b c ∧ 0 < berggren_h a b c) := by
  simp only [invB₂, berggren_p, berggren_q, berggren_h]

/-- B₃⁻¹ = (-p, q, h) is all-positive iff p < 0, q > 0, h > 0. -/
theorem branch3_positive_iff (a b c : ℤ) :
    (0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2) ↔
    (berggren_p a b c < 0 ∧ 0 < berggren_q a b c ∧ 0 < berggren_h a b c) := by
  simp only [invB₃, berggren_p, berggren_q, berggren_h]; constructor
  · intro ⟨ha, hb, hc⟩; exact ⟨by linarith, hb, hc⟩
  · intro ⟨ha, hb, hc⟩; exact ⟨by linarith, hb, hc⟩

theorem branch_exclusive_13 (a b c : ℤ)
    (h1 : 0 < (invB₁ a b c).1 ∧ 0 < (invB₁ a b c).2.1 ∧ 0 < (invB₁ a b c).2.2)
    (h3 : 0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2) :
    False := by
  rw [branch1_positive_iff] at h1; rw [branch3_positive_iff] at h3; linarith [h1.1, h3.1]

theorem branch_exclusive_23 (a b c : ℤ)
    (h2 : 0 < (invB₂ a b c).1 ∧ 0 < (invB₂ a b c).2.1 ∧ 0 < (invB₂ a b c).2.2)
    (h3 : 0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2) :
    False := by
  rw [branch2_positive_iff] at h2; rw [branch3_positive_iff] at h3; linarith [h2.1, h3.1]

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Round-Trip Identities
-- ═══════════════════════════════════════════════════════════════

theorem fwdB₁_comp_invB₁ (a b c : ℤ) :
    fwdB₁ (invB₁ a b c).1 (invB₁ a b c).2.1 (invB₁ a b c).2.2 = (a, b, c) := by
  simp [fwdB₁, invB₁, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

theorem fwdB₂_comp_invB₂ (a b c : ℤ) :
    fwdB₂ (invB₂ a b c).1 (invB₂ a b c).2.1 (invB₂ a b c).2.2 = (a, b, c) := by
  simp [fwdB₂, invB₂, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]
-- ... (truncated, full file has 435 lines)
```


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Algebra
Research mode: discover
