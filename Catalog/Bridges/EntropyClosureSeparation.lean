import Mathlib

/-!
# Entropy-Rate Separation via Closure Growth Dynamics

This file formalizes the mathematical core of **closure-growth separation**: the principle
that two monotone set transformers (modeling proof-search policies) can be distinguished
by a finite witness whenever their iterated closures diverge at any stage.

## Main results

### Abstract closure iteration theory
- `closureIter`: iteration of a set transformer via `Nat.iterate`
- `closureIter_zero`, `closureIter_succ_apply`: standard recursion lemmas
- `closureIter_mono`: monotonicity propagates through iteration
- `closureIter_stabilizes`: idempotent closure operators stabilize in one step

### Witness extraction
- `finite_witness_of_stage_separation`: any stage where `F^[n] S ⊈ G^[n] S` yields
  a concrete element witnessing the separation
- `finite_witness_of_eventual_growth_gap`: eventual strict inclusion implies a
  finite separating witness

### Fixed-point invariance
- `closure_fixed_points_are_iterative_invariants`: fixed points of a closure operator
  are invariant under all iterates

### EML instantiation
- `fullEMLClosure'_extensive`: seed sets embed into their full EML closure
- `fullEMLClosure'_setMono`: full EML closure is monotone in the seed set
- `fullEMLClosure'_isClosureOp`: full EML closure is a closure operator
- `fullEMLClosure'_iter_stabilizes`: iterates of full EML closure stabilize

## Motivation

In neural proof mining, a **proof policy** induces a set transformer on the space of
proof states: given a set of reachable states, the policy expands it by one step of
search. The **closure filtration** `F^[0] S ⊆ F^[1] S ⊆ ⋯` captures the cumulative
reach of the policy from seed set `S`.

Two policies `F` and `G` are **separable** if their filtrations diverge: some state is
reachable by `F` but not by `G` (or vice versa) within finitely many steps. The
**finite witness theorem** (`finite_witness_of_stage_separation`) extracts a concrete
certificate of this divergence — the exact mathematical object needed for
counterexample-guided training and benchmark generation.

The split between **preclosure** dynamics (monotone + extensive, where growth happens)
and **closure** saturation (idempotent, where growth halts) is the formal kernel of
"thermodynamic proof complexity": entropy lives in the transient filtration, while
semantic invariants live in the idempotent hull.
-/

open Set Function

noncomputable section

namespace ClosureGrowth

/-! ## Definitions: Set Monotonicity, Closure, and Preclosure -/

/-- A set transformer is **monotone** if it preserves subset inclusion. -/
def SetMono {α : Type*} (C : Set α → Set α) : Prop :=
  ∀ ⦃S T : Set α⦄, S ⊆ T → C S ⊆ C T

/-- A **preclosure operator** is monotone and extensive (inflationary).
    This models a single-step expansion of a proof-search policy. -/
structure IsPreclosureOp {α : Type*} (F : Set α → Set α) : Prop where
  extensive : ∀ S, S ⊆ F S
  monotone : SetMono F

/-- A **closure operator** is a preclosure operator that is additionally idempotent.
    Fixed points of a closure operator are the "learnable invariant strategies." -/
structure IsClosureOp {α : Type*} (C : Set α → Set α) : Prop where
  extensive : ∀ S, S ⊆ C S
  monotone : SetMono C
  idempotent : ∀ S, C (C S) = C S

/-- Every closure operator is a preclosure operator. -/
theorem IsClosureOp.toPreclosureOp {α : Type*} {C : Set α → Set α}
    (hC : IsClosureOp C) : IsPreclosureOp C :=
  ⟨hC.extensive, hC.monotone⟩

/-! ## Iterated Closure -/

/-- Iterate a set transformer `C` by `n`-fold self-composition. -/
def closureIter {α : Type*} (C : Set α → Set α) (n : ℕ) : Set α → Set α :=
  C^[n]

@[simp]
theorem closureIter_zero {α : Type*} (C : Set α → Set α) (S : Set α) :
    closureIter C 0 S = S := rfl

theorem closureIter_succ_apply {α : Type*} (C : Set α → Set α) (n : ℕ) (S : Set α) :
    closureIter C (n + 1) S = C (closureIter C n S) := by
  show C^[n + 1] S = C (C^[n] S)
  rw [iterate_succ']
  rfl

/-! ## Monotonicity of Iterates -/

/-- If `C` is monotone, then `C^[n]` is monotone for all `n`. -/
theorem closureIter_mono {α : Type*} {C : Set α → Set α}
    (hC : SetMono C) : ∀ n, SetMono (closureIter C n) := by
  intro n
  induction n with
  | zero => exact fun _ _ h => h
  | succ n ih =>
    intro S T h
    rw [closureIter_succ_apply, closureIter_succ_apply]
    exact hC (ih h)

/-! ## Extensivity of Iterates -/

/-- For a preclosure operator, `F^[n] S ⊆ F^[n+1] S`: the filtration is increasing. -/
theorem subset_closureIter_succ {α : Type*} {F : Set α → Set α}
    (hF : IsPreclosureOp F) (S : Set α) (n : ℕ) :
    closureIter F n S ⊆ closureIter F (n + 1) S := by
  induction n with
  | zero => exact hF.extensive S
  | succ n ih =>
    rw [closureIter_succ_apply, closureIter_succ_apply]
    exact hF.monotone ih

/-- For a preclosure operator, the seed set is contained in all iterates. -/
theorem subset_closureIter {α : Type*} {F : Set α → Set α}
    (hF : IsPreclosureOp F) (S : Set α) (n : ℕ) :
    S ⊆ closureIter F n S := by
  induction n with
  | zero => exact fun _ h => h
  | succ n ih => exact ih.trans (subset_closureIter_succ hF S n)

/-- For a preclosure operator, earlier stages are contained in later stages. -/
theorem closureIter_le_of_le {α : Type*} {F : Set α → Set α}
    (hF : IsPreclosureOp F) (S : Set α) {m n : ℕ} (hmn : m ≤ n) :
    closureIter F m S ⊆ closureIter F n S := by
  induction hmn with
  | refl => exact Subset.rfl
  | step _ ih => exact ih.trans (subset_closureIter_succ hF S _)

/-! ## Stabilization for Closure Operators -/

/-- An idempotent closure operator stabilizes after one step:
    `C^[n+1] S = C S` for all `n`. This is the formal expression that
    "entropy rate is zero" for a genuine closure operator — all growth
    happens in the first application. -/
theorem closureIter_stabilizes {α : Type*} {C : Set α → Set α}
    (hC : IsClosureOp C) (S : Set α) :
    ∀ n, closureIter C (n + 1) S = C S := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih => rw [closureIter_succ_apply, ih, hC.idempotent]

/-! ## Stagewise Reachability and Witness Extraction -/

/-- `x` is **reachable by stage `n`** from seed `S` under transformer `F`. -/
def reachesBy {α : Type*} (F : Set α → Set α) (S : Set α) (n : ℕ) (x : α) : Prop :=
  x ∈ closureIter F n S

/-- **Finite witness extraction**: if the `F`-filtration is not contained in the
    `G`-filtration at some stage, there exists a concrete witness element and stage. -/
theorem finite_witness_of_stage_separation {α : Type*}
    {F G : Set α → Set α}
    (_hF : IsPreclosureOp F) (_hG : IsPreclosureOp G)
    {S : Set α} :
    (∃ n, ¬(closureIter F n S ⊆ closureIter G n S)) →
    ∃ n x, x ∈ closureIter F n S ∧ x ∉ closureIter G n S := by
  rintro ⟨n, hn⟩
  rw [not_subset] at hn
  exact ⟨n, hn⟩

/-! ## Eventual Growth Gap and Separation -/

/-- Two transformers exhibit an **eventual growth gap** from seed `S` if,
    past some threshold, `G` is strictly contained in `F` at every stage. -/
def EventuallyStrictlyLarger {α : Type*}
    (F G : Set α → Set α) (S : Set α) : Prop :=
  ∃ N, ∀ n ≥ N, closureIter G n S ⊂ closureIter F n S

/-- **Entropy-rate separation theorem**: an eventual growth gap yields a
    finite distinguishing witness. -/
theorem finite_witness_of_eventual_growth_gap {α : Type*}
    {F G : Set α → Set α}
    (_hF : IsPreclosureOp F) (_hG : IsPreclosureOp G)
    {S : Set α} :
    EventuallyStrictlyLarger F G S →
    ∃ n x, x ∈ closureIter F n S ∧ x ∉ closureIter G n S := by
  rintro ⟨N, hN⟩
  obtain ⟨x, hxF, hxG⟩ := Set.exists_of_ssubset (hN N le_rfl)
  exact ⟨N, x, hxF, hxG⟩

/-! ## Fixed-Point Invariance -/

/-- A set `S` is **invariant** under `C` if `C S = S`. -/
def IsInvariant {α : Type*} (C : Set α → Set α) (S : Set α) : Prop :=
  C S = S

/-- Invariance is equivalent to `C S = S` (definitional unfolding). -/
theorem invariant_iff_eq {α : Type*} {C : Set α → Set α}
    (_hC : IsClosureOp C) (S : Set α) :
    IsInvariant C S ↔ C S = S :=
  Iff.rfl

/-- **Fixed points are iteratively invariant**: if `C S = S` for a closure operator `C`,
    then `C^[n] S = S` for all `n`. -/
theorem closure_fixed_points_are_iterative_invariants {α : Type*}
    {C : Set α → Set α} (_hC : IsClosureOp C) {S : Set α}
    (hS : C S = S) : ∀ n, closureIter C n S = S := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih => rw [closureIter_succ_apply, ih, hS]

/-! ## EML Closure Infrastructure

We reproduce the core EML definitions here for self-containedness, then
connect them to the abstract closure theory. The EML (Exponential-Minus-Log)
operation generates a closure on `Set ℝ` modeling compositional proof-state
transformations.
-/

/-- The EML operation: `EMLd'(a, b) = exp(a) - log(b)`. -/
def EMLd' (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- EML closure at depth `n`: start from seed set `S` and iteratively adjoin
    all values obtainable by applying `EMLd'` to pairs of existing elements. -/
def EMLClosure' : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S => EMLClosure' n S ∪
      {z | ∃ a ∈ EMLClosure' n S, ∃ b ∈ EMLClosure' n S, z = EMLd' a b}

/-- The full EML closure: union over all depths. -/
def fullEMLClosure' (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure' n S

/-- `EMLClosure'` at any fixed depth is monotone in the seed set. -/
theorem EMLClosure'_depth_mono_set (n : ℕ) :
    SetMono (EMLClosure' n) := by
  intro S T hST
  induction n with
  | zero => exact hST
  | succ n ih =>
    intro x hx
    simp only [EMLClosure'] at hx ⊢
    cases hx with
    | inl h => exact Or.inl (ih h)
    | inr h =>
      obtain ⟨a, ha, b, hb, rfl⟩ := h
      exact Or.inr ⟨a, ih ha, b, ih hb, rfl⟩

/-- The seed set is contained in `EMLClosure'` at every depth. -/
theorem EMLClosure'_extensive (S : Set ℝ) : ∀ n, S ⊆ EMLClosure' n S := by
  intro n
  induction n with
  | zero => exact Subset.rfl
  | succ n ih => exact ih.trans fun _ hx => Or.inl hx

/-- `EMLClosure'` is monotone in depth. -/
theorem EMLClosure'_depth_mono (S : Set ℝ) (n : ℕ) :
    EMLClosure' n S ⊆ EMLClosure' (n + 1) S :=
  fun _ hx => Or.inl hx

/-- Depth monotonicity: if `m ≤ n` then `EMLClosure' m S ⊆ EMLClosure' n S`. -/
theorem EMLClosure'_depth_le {S : Set ℝ} {m n : ℕ} (h : m ≤ n) :
    EMLClosure' m S ⊆ EMLClosure' n S := by
  induction h with
  | refl => exact Subset.rfl
  | step _ ih => exact ih.trans (EMLClosure'_depth_mono S _)

/-- `fullEMLClosure'` is **extensive**: `S ⊆ fullEMLClosure' S`. -/
theorem fullEMLClosure'_extensive (S : Set ℝ) :
    S ⊆ fullEMLClosure' S :=
  fun _ hx => mem_iUnion.mpr ⟨0, hx⟩

/-- `fullEMLClosure'` is **monotone** in the seed set. -/
theorem fullEMLClosure'_setMono : SetMono fullEMLClosure' := by
  intro S T hST x hx
  obtain ⟨n, hn⟩ := mem_iUnion.mp hx
  exact mem_iUnion.mpr ⟨n, EMLClosure'_depth_mono_set n hST hn⟩

/-- `fullEMLClosure'` is a preclosure operator. -/
theorem fullEMLClosure'_isPreclosureOp : IsPreclosureOp fullEMLClosure' :=
  ⟨fullEMLClosure'_extensive, fullEMLClosure'_setMono⟩

/-
Key lemma: elements of `EMLClosure' n (fullEMLClosure' S)` are in `fullEMLClosure' S`.
    This is the core of the idempotence proof.
-/
theorem EMLClosure'_of_fullEMLClosure' (S : Set ℝ) (n : ℕ) :
    EMLClosure' n (fullEMLClosure' S) ⊆ fullEMLClosure' S := by
  induction' n with n ih;
  · exact fun ⦃a⦄ a_1 => a_1;
  · simp_all +decide [ EMLClosure', Set.subset_def ];
    rintro x ( hx | ⟨ a, ha, b, hb, rfl ⟩ ) <;> [ exact ih x hx; exact Set.mem_iUnion.mpr ?_ ];
    obtain ⟨ m₁, hm₁ ⟩ := Set.mem_iUnion.mp ( ih a ha );
    obtain ⟨ m₂, hm₂ ⟩ := Set.mem_iUnion.mp ( ih b hb );
    -- Let $M = \max(m₁, m₂)$. Then $a$ and $b$ are in $EMLClosure' M S$.
    set M := max m₁ m₂ with hM
    have hM₁ : a ∈ EMLClosure' M S := by
      exact EMLClosure'_depth_le ( le_max_left _ _ ) hm₁
    have hM₂ : b ∈ EMLClosure' M S := by
      exact EMLClosure'_depth_le ( le_max_right m₁ m₂ ) hm₂;
    exact Set.mem_iUnion.mpr ⟨ M + 1, by exact Set.mem_union_right _ ⟨ a, hM₁, b, hM₂, rfl ⟩ ⟩

/-- **Idempotence** of `fullEMLClosure'`: applying the full closure twice gives
    the same result as applying it once. -/
theorem fullEMLClosure'_idempotent (S : Set ℝ) :
    fullEMLClosure' (fullEMLClosure' S) = fullEMLClosure' S := by
  apply subset_antisymm
  · intro x hx
    obtain ⟨n, hn⟩ := mem_iUnion.mp hx
    exact EMLClosure'_of_fullEMLClosure' S n hn
  · exact fullEMLClosure'_extensive (fullEMLClosure' S)

/-- `fullEMLClosure'` is a closure operator. -/
theorem fullEMLClosure'_isClosureOp : IsClosureOp fullEMLClosure' where
  extensive := fullEMLClosure'_extensive
  monotone := fullEMLClosure'_setMono
  idempotent := fullEMLClosure'_idempotent

/-- Fixed points of `fullEMLClosure'` are invariant under all iterates. -/
theorem fullEMLClosure'_fixed_iterative_invariant {S : Set ℝ}
    (hS : fullEMLClosure' S = S) :
    ∀ n, closureIter fullEMLClosure' n S = S :=
  closure_fixed_points_are_iterative_invariants fullEMLClosure'_isClosureOp hS

/-- One-step stabilization for `fullEMLClosure'`: iterates beyond the first
    all equal `fullEMLClosure' S`. -/
theorem fullEMLClosure'_iter_stabilizes (S : Set ℝ) :
    ∀ n, closureIter fullEMLClosure' (n + 1) S = fullEMLClosure' S :=
  closureIter_stabilizes fullEMLClosure'_isClosureOp S

end ClosureGrowth

end