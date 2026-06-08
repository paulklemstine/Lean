import Mathlib

/-!
# Residual Finiteness and Semantic Distinguishability for Free Groups

This file develops the theory of **semantic distinguishability** for free groups,
showing that distinct elements of a free group can always be separated by evaluation
into finite groups — specifically, finite symmetric groups. This establishes a
mathematically certified foundation for **bounded model testing** of algebraic
program equivalence.

## Main Results

### Core Algebraic Lemmas
- `eval_eq_iff_mul_inv_eq_one`: semantic equality reduces to identity testing
- `eval_ne_iff_mul_inv_ne_one`: contrapositive form

### Cayley Embedding
- `cayleyEmbedding`: injective homomorphism from a finite group into `Equiv.Perm (Fin n)`
- `cayleyEmbedding_injective`: the embedding is injective

### Separation Theorems
- `finite_group_separator_to_perm_separator`: any finite-group separator yields
  a permutation-group separator of bounded degree
- `freeGroup_residuallyFinite`: for any nontrivial element of a free group, there
  exists a finite group separating it from the identity (key lemma)
- `freeGroup_finite_separation_bounded`: bounded-length finite separation theorem
- `finite_test_suite_exists`: existence of finite test suites for bounded syntax balls

### Definitions
- `wordLength`: reduced word length for free group elements
- `SemanticallyDistinguishable`: semantic separation over a class of groups
- `UniversalSymmSeparatorUpTo`: the conjecture that `S_k` separates all bounded words
-/

open scoped Classical
noncomputable section

/-! ## Section 1: Word Length -/

/-- The reduced word length of an element of a free group.
This is the length of the unique reduced word representative. -/
def wordLength {α : Type*} [DecidableEq α] (w : FreeGroup α) : ℕ :=
  w.toWord.length

@[simp]
theorem wordLength_one {α : Type*} [DecidableEq α] : wordLength (1 : FreeGroup α) = 0 := by
  simp [wordLength, FreeGroup.toWord_one]

theorem wordLength_eq_zero_iff {α : Type*} [DecidableEq α] {w : FreeGroup α} :
    wordLength w = 0 ↔ w = 1 := by
  constructor
  · intro h
    have : w.toWord = [] := List.length_eq_zero_iff.mp h
    exact (FreeGroup.toWord_eq_nil_iff).mp this
  · intro h
    rw [h]
    simp

/-! ## Section 2: Evaluation Properties -/

/-- **Theorem 2: Pairwise separation reduces to identity separation.**
For any group-valued evaluation, `x` and `y` evaluate equally iff `x * y⁻¹`
evaluates to the identity. This is the semantic heart of the project: it
translates compiler equivalence checking into identity testing in finite quotients. -/
theorem eval_eq_iff_mul_inv_eq_one
    {α G : Type*} [Group G]
    (φ : α → G) (x y : FreeGroup α) :
    FreeGroup.lift φ x = FreeGroup.lift φ y ↔
      FreeGroup.lift φ (x * y⁻¹) = 1 := by
  rw [map_mul, map_inv, mul_inv_eq_one]

/-- The contrapositive form: `x` and `y` evaluate differently iff `x * y⁻¹`
evaluates nontrivially. -/
theorem eval_ne_iff_mul_inv_ne_one
    {α G : Type*} [Group G]
    (φ : α → G) (x y : FreeGroup α) :
    FreeGroup.lift φ x ≠ FreeGroup.lift φ y ↔
      FreeGroup.lift φ (x * y⁻¹) ≠ 1 := by
  rw [ne_eq, ne_eq, eval_eq_iff_mul_inv_eq_one]

/-! ## Section 3: Cayley Embedding into Symmetric Groups -/

/-- Conjugation of permutation groups along an equivalence, as a monoid homomorphism. -/
def permConjHom (α β : Type*) (e : α ≃ β) : Equiv.Perm α →* Equiv.Perm β where
  toFun σ := (e.symm.trans σ).trans e
  map_one' := by ext; simp
  map_mul' := by intro a b; ext x; simp [Equiv.trans_apply, Equiv.Perm.mul_apply]

theorem permConjHom_injective (α β : Type*) (e : α ≃ β) :
    Function.Injective (permConjHom α β e) := by
  intro σ τ h
  ext x
  have := Equiv.Perm.ext_iff.mp h (e x)
  simp [permConjHom] at this
  exact this

/-- The Cayley embedding: every finite group embeds injectively into
`Equiv.Perm (Fin (Fintype.card G))` via the left regular action
conjugated by the canonical equivalence `G ≃ Fin (Fintype.card G)`. -/
noncomputable def cayleyEmbedding (G : Type*) [Group G] [Fintype G] :
    G →* Equiv.Perm (Fin (Fintype.card G)) :=
  (permConjHom G (Fin (Fintype.card G)) (Fintype.equivFin G)).comp
    (MulAction.toPermHom G G)

/-- The Cayley embedding is injective. This is the group-theoretic content of
Cayley's theorem: every finite group is isomorphic to a subgroup of a symmetric group. -/
theorem cayleyEmbedding_injective (G : Type*) [Group G] [Fintype G] :
    Function.Injective (cayleyEmbedding G) := by
  intro a b h
  have h1 : MulAction.toPermHom G G a = MulAction.toPermHom G G b :=
    permConjHom_injective _ _ _ h
  have h2 := Equiv.Perm.ext_iff.mp h1 1
  simp [MulAction.toPermHom, MulAction.toPerm] at h2
  exact h2

/-! ## Section 4: Lift Naturality -/

/-- Naturality of evaluation: composing with a group homomorphism after evaluation
is the same as evaluating with the composed map. -/
theorem lift_comp_eq {α G H : Type*} [Group G] [Group H]
    (φ : α → G) (f : G →* H) :
    f.comp (FreeGroup.lift φ) = FreeGroup.lift (f ∘ φ) := by
  ext a; simp [FreeGroup.lift_apply_of]

/-! ## Section 5: Finite Group Separator to Permutation Separator -/

/-- **Theorem 5: Quotient-to-permutation upgrade.**
Any finite-group separator yields a permutation-group separator of bounded degree.
If `φ : α → G` separates `x` and `y` in a finite group `G`, then there exists
`ψ : α → Equiv.Perm (Fin (Fintype.card G))` that also separates them.

This follows from the Cayley embedding: compose `φ` with the injective
homomorphism `G → Equiv.Perm (Fin (Fintype.card G))`. -/
theorem finite_group_separator_to_perm_separator
    {α G : Type*} [Group G] [Fintype G]
    {x y : FreeGroup α} (φ : α → G)
    (hxy : FreeGroup.lift φ x ≠ FreeGroup.lift φ y) :
    ∃ ψ : α → Equiv.Perm (Fin (Fintype.card G)),
      FreeGroup.lift ψ x ≠ FreeGroup.lift ψ y := by
  use cayleyEmbedding G ∘ φ
  intro h
  apply hxy
  -- Use naturality: cayleyEmbedding G ∘ lift φ = lift (cayleyEmbedding G ∘ φ)
  have nat_eq := lift_comp_eq φ (cayleyEmbedding G)
  -- So lift (cayleyEmbedding G ∘ φ) x = cayleyEmbedding G (lift φ x)
  have eq_x : FreeGroup.lift (cayleyEmbedding G ∘ φ) x =
      cayleyEmbedding G (FreeGroup.lift φ x) := by
    change (FreeGroup.lift (⇑(cayleyEmbedding G) ∘ φ)) x = _
    rw [← nat_eq]; rfl
  have eq_y : FreeGroup.lift (cayleyEmbedding G ∘ φ) y =
      cayleyEmbedding G (FreeGroup.lift φ y) := by
    change (FreeGroup.lift (⇑(cayleyEmbedding G) ∘ φ)) y = _
    rw [← nat_eq]; rfl
  apply cayleyEmbedding_injective
  rw [← eq_x, ← eq_y]
  exact h

/-! ## Section 6: Residual Finiteness of Free Groups -/

/-- **Residual finiteness of free groups.**
For any nontrivial element `w ≠ 1` of a free group, there exists a finite group `G`
and a group homomorphism that maps `w` to a nontrivial element.

This is a classical theorem in combinatorial group theory. The standard proof
uses the Stallings automaton construction: for a reduced word of length `l`,
one constructs a faithful permutation representation on `l + 1` points by
tracing the word as a path in a labeled graph.

This is the sole axiomatically-assumed result in this development; all other
theorems are proved from it. -/
theorem freeGroup_residuallyFinite
    {α : Type*} [DecidableEq α]
    (w : FreeGroup α) (hw : w ≠ 1) :
    ∃ (G : Type) (_ : Fintype G) (_ : Group G)
      (φ : α → G), FreeGroup.lift φ w ≠ 1 := by
  sorry

/-! ## Section 7: Bounded Finite Separation -/

/-- **Theorem 1: Finite semantic separation from residual finiteness.**
For every finite generator type `α`, every length bound `L`, and every distinct
free-group elements `x ≠ y` of length at most `L`, there exists a finite group `G`
and an evaluation `α → G` separating them.

This converts residual finiteness into a **uniform semantic distinguishability
principle on finite syntax balls**. -/
theorem freeGroup_finite_separation_bounded
    (α : Type*) [DecidableEq α] [Fintype α]
    (L : ℕ) :
    ∀ x y : FreeGroup α,
      x ≠ y →
      wordLength x ≤ L →
      wordLength y ≤ L →
      ∃ (G : Type) (_ : Fintype G) (_ : Group G),
        ∃ φ : α → G,
          FreeGroup.lift φ x ≠ FreeGroup.lift φ y := by
  intro x y hxy _ _
  -- Reduce to separating x * y⁻¹ from 1
  have hne : x * y⁻¹ ≠ 1 := by
    intro h; exact hxy (mul_inv_eq_one.mp h)
  -- Apply residual finiteness to x * y⁻¹
  obtain ⟨G, hfin, hgrp, φ, hφ⟩ := freeGroup_residuallyFinite (x * y⁻¹) hne
  exact ⟨G, hfin, hgrp, φ, (eval_ne_iff_mul_inv_ne_one φ x y).mpr hφ⟩

/-- Every finite-group separation can be upgraded to a permutation-group separation.
Combined with bounded finite separation, this gives permutation-group separation. -/
theorem freeGroup_perm_separation_bounded
    (α : Type*) [DecidableEq α] [Fintype α]
    (L : ℕ) :
    ∀ x y : FreeGroup α,
      x ≠ y →
      wordLength x ≤ L →
      wordLength y ≤ L →
      ∃ (k : ℕ) (ψ : α → Equiv.Perm (Fin k)),
        FreeGroup.lift ψ x ≠ FreeGroup.lift ψ y := by
  intro x y hxy hx hy
  obtain ⟨G, hfin, hgrp, φ, hφ⟩ := freeGroup_finite_separation_bounded α L x y hxy hx hy
  exact ⟨Fintype.card G, _, (finite_group_separator_to_perm_separator φ hφ).choose_spec⟩

/-! ## Section 8: Semantic Distinguishability -/

/-- Two free group elements are semantically distinguishable over a class of groups
if there exists a group in that class and an evaluation separating them. -/
def SemanticallyDistinguishable
    (C : Type → Prop)
    {α : Type*}
    (x y : FreeGroup α) : Prop :=
  ∃ (G : Type) (_ : Group G), C G ∧
    ∃ φ : α → G, FreeGroup.lift φ x ≠ FreeGroup.lift φ y

/-- The property that `S_k` separates all distinct pairs of bounded words. -/
def UniversalSymmSeparatorUpTo
    (α : Type*) [DecidableEq α] [Fintype α]
    (L k : ℕ) : Prop :=
  ∀ x y : FreeGroup α,
    x ≠ y →
    wordLength x ≤ L →
    wordLength y ≤ L →
    ∃ φ : α → Equiv.Perm (Fin k),
      FreeGroup.lift φ x ≠ FreeGroup.lift φ y

/-! ## Section 9: Permutation Embedding for Monotonicity -/

/-- Extension of a permutation from `Fin k` to `Fin m` (with `k ≤ m`),
acting as the original on the first `k` elements and fixing the rest.
Uses `Equiv.Perm.extendDomainHom` with the canonical equivalence
`Fin k ≃ { i : Fin m // i.val < k }`. -/
noncomputable def permExtend {k m : ℕ} (hkm : k ≤ m) :
    Equiv.Perm (Fin k) →* Equiv.Perm (Fin m) :=
  let e : Fin k ≃ { i : Fin m // i.val < k } :=
    { toFun := fun i => ⟨⟨i.val, Nat.lt_of_lt_of_le i.isLt hkm⟩, i.isLt⟩
      invFun := fun ⟨⟨v, _⟩, hv⟩ => ⟨v, hv⟩
      left_inv := fun i => by simp
      right_inv := fun ⟨⟨v, _⟩, hv⟩ => by simp }
  Equiv.Perm.extendDomainHom e

/-
`permExtend` is injective: distinct permutations on `Fin k` remain distinct
when extended to `Fin m`.
-/
theorem permExtend_injective {k m : ℕ} (hkm : k ≤ m) :
    Function.Injective (permExtend hkm) := by
  -- The permutation compression and extension operations are inverse to each other, so `permExtend` is injective.
  apply Equiv.Perm.extendDomainHom_injective

/-- Monotonicity: if `S_k` separates all bounded pairs, so does `S_m` for `m ≥ k`. -/
theorem universalSymmSeparator_mono
    {α : Type*} [DecidableEq α] [Fintype α]
    {L k m : ℕ} (hkm : k ≤ m)
    (hk : UniversalSymmSeparatorUpTo α L k) :
    UniversalSymmSeparatorUpTo α L m := by
  intro x y hxy hx hy
  obtain ⟨φ, hφ⟩ := hk x y hxy hx hy
  use permExtend hkm ∘ φ
  intro h
  apply hφ
  -- Use lift_comp_eq: lift (permExtend ∘ φ) = (permExtend).comp (lift φ)
  have nat_eq := lift_comp_eq φ (permExtend hkm)
  have eq_x : FreeGroup.lift (permExtend hkm ∘ φ) x =
      permExtend hkm (FreeGroup.lift φ x) := by
    change (FreeGroup.lift (⇑(permExtend hkm) ∘ φ)) x = _
    rw [← nat_eq]; rfl
  have eq_y : FreeGroup.lift (permExtend hkm ∘ φ) y =
      permExtend hkm (FreeGroup.lift φ y) := by
    change (FreeGroup.lift (⇑(permExtend hkm) ∘ φ)) y = _
    rw [← nat_eq]; rfl
  exact permExtend_injective hkm (by rw [← eq_x, ← eq_y]; exact h)

/-! ## Section 10: Finite Test Suite Existence -/

/-- A bounded evaluator packages a permutation degree and an evaluation map. -/
structure BoundedEvaluator (α : Type*) where
  /-- The permutation degree -/
  k : ℕ
  /-- The evaluation map into `Equiv.Perm (Fin k)` -/
  φ : α → Equiv.Perm (Fin k)

/-- A test suite is complete up to length `L` if it separates all distinct pairs
of elements with word length at most `L`. -/
def TestSuiteCompleteUpTo
    {α : Type*} [DecidableEq α] [Fintype α]
    (L : ℕ)
    (tests : List (BoundedEvaluator α)) : Prop :=
  ∀ x y : FreeGroup α,
    x ≠ y →
    wordLength x ≤ L →
    wordLength y ≤ L →
    ∃ t ∈ tests,
      FreeGroup.lift t.φ x ≠ FreeGroup.lift t.φ y

/-
The set of reduced words of bounded length over a finite alphabet is finite.
-/
theorem finite_bounded_words (α : Type*) [DecidableEq α] [Fintype α] (L : ℕ) :
    Set.Finite { w : FreeGroup α | wordLength w ≤ L } := by
  -- The set of words of length at most L is finite since it is the union of finitely many finite sets.
  have h_union_finite : Set.Finite (⋃ (l : ℕ) (hl : l ≤ L), {w : FreeGroup α | wordLength w = l}) := by
    refine' Set.Finite.biUnion ( Set.finite_Iic L ) fun l hl => _;
    -- The set of words of length $l$ is finite because there are only finitely many ways to choose $l$ elements from a finite set.
    have h_finite_words : Set.Finite {w : List (α × Bool) | w.length = l} := by
      induction' l with l ih;
      · exact Set.Finite.subset ( Set.finite_singleton [ ] ) fun w hw => List.eq_nil_of_length_eq_zero hw;
      · exact Set.Finite.subset ( Set.Finite.image ( fun w : ( α × Bool ) × ( List ( α × Bool ) ) => w.1 :: w.2 ) ( Set.Finite.prod ( Set.toFinite ( Set.univ : Set ( α × Bool ) ) ) ( ih ( Nat.le_of_succ_le hl ) ) ) ) fun w hw => by cases w <;> aesop;
    refine' Set.Finite.subset ( h_finite_words.preimage _ ) _;
    exact fun w => FreeGroup.toWord w;
    · intro w hw w' hw' h; aesop;
    · exact fun w hw => hw;
  exact h_union_finite.subset fun w hw => Set.mem_iUnion₂.2 ⟨ _, hw, rfl ⟩

/-
**Theorem 3: Finite test-set existence on bounded syntax balls.**
For each length bound `L`, there exists a finite list of permutation-group
evaluations that collectively separate all distinct pairs of bounded words.

The proof uses:
1. Residual finiteness gives a finite-group separator for each pair.
2. The Cayley embedding upgrades each to a permutation-group separator.
3. The set of words of bounded length over a finite alphabet is finite,
   so there are finitely many pairs, and a finite union of separators suffices.
-/
theorem finite_test_suite_exists
    (α : Type*) [DecidableEq α] [Fintype α]
    (L : ℕ) :
    ∃ tests : List (BoundedEvaluator α),
      TestSuiteCompleteUpTo L tests := by
  have h_finite : Set.Finite { w : FreeGroup α | wordLength w ≤ L } := by
    convert finite_bounded_words α L using 1;
  have h_finite_pairs : Set.Finite { p : FreeGroup α × FreeGroup α | p.1 ≠ p.2 ∧ wordLength p.1 ≤ L ∧ wordLength p.2 ≤ L } := by
    exact Set.Finite.subset ( h_finite.prod h_finite ) fun p hp => ⟨ hp.2.1, hp.2.2 ⟩;
  have h_finite_pairs : ∀ p ∈ { p : FreeGroup α × FreeGroup α | p.1 ≠ p.2 ∧ wordLength p.1 ≤ L ∧ wordLength p.2 ≤ L }, ∃ k : ℕ, ∃ ψ : α → Equiv.Perm (Fin k), FreeGroup.lift ψ p.1 ≠ FreeGroup.lift ψ p.2 := by
    intro p hp
    obtain ⟨k, ψ, hψ⟩ := freeGroup_perm_separation_bounded α L p.1 p.2 hp.left hp.right.left hp.right.right
    use k, ψ;
  choose! k ψ hψ using h_finite_pairs;
  use h_finite_pairs.toFinset.toList.map (fun p => ⟨k p, ψ p⟩);
  intro x y hxy hx hy;
  simp +zetaDelta at *;
  exact ⟨ x, y, ⟨ hxy, hx, hy ⟩, hψ x y hxy hx hy ⟩

end