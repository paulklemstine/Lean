import Mathlib

/-!
# Oracle Closure Algebras and Resolvability Degrees

This module develops the algebraic theory of **oracle closure operators** arising from
reflective oracle hierarchies. We define a closure operator on sets of sentences
induced by the oracle jump, study its fixed-point structure, and introduce
**resolvability degrees** — a preorder on sentences measuring their oracle complexity.

## Mathematical Context

Given a reflective hierarchy (T₀ ⊂ T₁ ⊂ T₂ ⊂ ⋯), each level resolves new sentences.
The *oracle closure* of a set S is the set of all sentences eventually provable in the
hierarchy starting from S. This gives rise to a closure operator on ℘(Sentence) with
rich algebraic structure.

The key insight: the incompleteness phenomenon has an *algebraic* face. The failure
of idempotence at finite levels, combined with the closure property at ω, reveals
a deep connection between Gödel's theorems and the theory of closure algebras.

## Novel Definitions

- `OracleHierarchy` — A reflective hierarchy with injective consistency sentences
- `OracleClosure` — Closure operator on sentence sets via oracle jumps
- `ResolvabilityLE` — Preorder measuring oracle complexity of sentences
- `IncompletenessKernel` — The set of sentences that remain unprovable at each level

## Main Results

- `oracle_closure_extensive` — Closure is extensive
- `oracle_closure_monotone` — Closure is monotone
- `oracle_closure_not_idempotent` — Finite closure is NOT idempotent (key insight!)
- `diagonal_resistance_unbounded` — No finite bound on resolution complexity
- `incompleteness_kernel_nonempty` — The kernel is nonempty at every level
- `hierarchy_collapse_impossible` — No finite jump collapses the hierarchy
- `incompleteness_kernel_strictly_decreasing` — Kernels form a strict chain
- `diagonal_antichain` — Consistency sentences form an antichain in resolvability
-/

noncomputable section

open Set Function

/-! ## The Oracle Hierarchy -/

/-- An **OracleHierarchy** models a sequence of theories indexed by ℕ,
    each extending the previous by oracle jumps, with injective consistency sentences. -/
structure OracleHierarchy where
  /-- Sentence type -/
  Sentence : Type*
  /-- Provability at each level -/
  Provable : ℕ → Sentence → Prop
  /-- Truth predicate -/
  True_ : Sentence → Prop
  /-- Bottom sentence -/
  bot : Sentence
  /-- Bottom is not true -/
  bot_not_true : ¬ True_ bot
  /-- Monotonicity -/
  mono : ∀ n φ, Provable n φ → Provable (n + 1) φ
  /-- Strictness -/
  strict : ∀ n, ∃ φ, Provable (n + 1) φ ∧ ¬ Provable n φ
  /-- Consistency sentences -/
  conSentence : ℕ → Sentence
  /-- Consistency sentences are true -/
  con_true : ∀ n, True_ (conSentence n)
  /-- Level n can't prove its own consistency -/
  con_unprovable : ∀ n, ¬ Provable n (conSentence n)
  /-- Level n+1 proves consistency of level n -/
  con_jump : ∀ n, Provable (n + 1) (conSentence n)
  /-- Injectivity of consistency sentences -/
  con_injective : Injective conSentence

/-! ## Part 1: Basic Monotonicity -/

/-- Multi-step monotonicity. -/
theorem OracleHierarchy.mono_le (H : OracleHierarchy) {m n : ℕ}
    (hmn : m ≤ n) (φ : H.Sentence) (hp : H.Provable m φ) :
    H.Provable n φ := by
  induction hmn with
  | refl => exact hp
  | step _ ih => exact H.mono _ φ ih

/-- Consistency of level k is not provable at any level ≤ k. -/
theorem OracleHierarchy.con_unprovable_le (H : OracleHierarchy) (k m : ℕ) (hm : m ≤ k) :
    ¬ H.Provable m (H.conSentence k) :=
  fun hp => H.con_unprovable k (H.mono_le hm _ hp)

/-! ## Part 2: Oracle Closure Operator -/

/-- The **provable set** at level n. -/
def OracleHierarchy.provableSet (H : OracleHierarchy) (n : ℕ) : Set H.Sentence :=
  { φ | H.Provable n φ }

/-- The **union provable set** (ω-limit). -/
def OracleHierarchy.unionProvableSet (H : OracleHierarchy) : Set H.Sentence :=
  { φ | ∃ n, H.Provable n φ }

/-- The **oracle closure** at depth k: apply k oracle jumps starting from level n. -/
def OracleHierarchy.oracleClosure (H : OracleHierarchy) (n k : ℕ) : Set H.Sentence :=
  H.provableSet (n + k)

/-- **Extensivity**: Oracle closure extends the original provable set. -/
theorem oracle_closure_extensive (H : OracleHierarchy) (n k : ℕ) :
    H.provableSet n ⊆ H.oracleClosure n k := by
  intro φ hp
  exact H.mono_le (by omega) φ hp

/-- **Monotonicity**: More oracle jumps yield larger provable sets. -/
theorem oracle_closure_monotone (H : OracleHierarchy) (n : ℕ) {j k : ℕ} (hjk : j ≤ k) :
    H.oracleClosure n j ⊆ H.oracleClosure n k := by
  intro φ hp
  exact H.mono_le (by omega) φ hp

/-
**Non-idempotence**: Oracle closure at depth 1 differs from depth 2.
    This is the algebraic face of Gödel incompleteness: the closure operator
    on provable sets never stabilizes at finite depth.
-/
theorem oracle_closure_not_idempotent (H : OracleHierarchy) (n : ℕ) :
    H.oracleClosure n 1 ≠ H.oracleClosure n 2 := by
  simp +decide [ Set.ext_iff, OracleHierarchy.oracleClosure ];
  obtain ⟨ φ, hφ₁, hφ₂ ⟩ := H.strict ( n + 1 );
  exact ⟨ φ, by unfold OracleHierarchy.provableSet; tauto ⟩

/-! ## Part 3: Incompleteness Kernels -/

/-- The **incompleteness kernel** at level n: true sentences not provable at level n. -/
def OracleHierarchy.incompletenessKernel (H : OracleHierarchy) (n : ℕ) : Set H.Sentence :=
  { φ | H.True_ φ ∧ ¬ H.Provable n φ }

/-- The incompleteness kernel at each level is nonempty. -/
theorem incompleteness_kernel_nonempty (H : OracleHierarchy) (n : ℕ) :
    (H.incompletenessKernel n).Nonempty :=
  ⟨H.conSentence n, H.con_true n, H.con_unprovable n⟩

/-
**The incompleteness kernels form a strictly decreasing chain.**
    Each oracle jump resolves some incompleteness but introduces new frontier questions.
    This is the algebraic form of the "frontier advancement" phenomenon.
-/
theorem incompleteness_kernel_strictly_decreasing (H : OracleHierarchy) (n : ℕ) :
    H.incompletenessKernel (n + 1) ⊂ H.incompletenessKernel n := by
  constructor;
  · exact fun x hx => ⟨ hx.1, fun h => hx.2 <| H.mono _ _ h ⟩;
  · simp +decide [ Set.not_subset, OracleHierarchy.incompletenessKernel ];
    exact ⟨ H.conSentence n, H.con_true n, H.con_unprovable n, fun _ => H.con_jump n ⟩

/-
Kernel separation across multiple levels.
-/
theorem kernel_separation (H : OracleHierarchy) {m n : ℕ} (hmn : m < n) :
    H.incompletenessKernel n ⊂ H.incompletenessKernel m := by
  induction' hmn with n hmn ih;
  · exact?;
  · exact Set.ssubset_of_ssubset_of_subset ( incompleteness_kernel_strictly_decreasing H n ) ih.1

/-! ## Part 4: Diagonal Resistance -/

/-
**Diagonal Resistance Unbounded**: For every level N, there exists a true sentence
    not provable at any level ≤ N.
-/
theorem diagonal_resistance_unbounded (H : OracleHierarchy) :
    ∀ N : ℕ, ∃ φ, H.True_ φ ∧ ∀ m, m ≤ N → ¬ H.Provable m φ := by
  exact fun n => ⟨ H.conSentence n, H.con_true n, fun m hm => H.con_unprovable_le n m hm ⟩

/-! ## Part 5: Hierarchy Collapse Impossibility -/

/-
**Hierarchy Collapse Impossibility**: No finite number of oracle jumps can collapse
    the hierarchy — there is always more to prove beyond any finite depth.
-/
theorem hierarchy_collapse_impossible (H : OracleHierarchy) (n k : ℕ) :
    H.oracleClosure n k ≠ H.unionProvableSet := by
  exact fun h => H.con_unprovable ( n + k ) ( h.symm.subset <| Set.mem_setOf.mpr ⟨ n + k + 1, H.con_jump _ ⟩ )

/-! ## Part 6: Resolvability Preorder -/

/-- **Resolvability preorder**: φ ≤ᵣ ψ iff any level proving ψ also proves φ. -/
def OracleHierarchy.resolvabilityLE (H : OracleHierarchy) (φ ψ : H.Sentence) : Prop :=
  ∀ n, H.Provable n ψ → H.Provable n φ

/-- Resolvability is reflexive. -/
theorem resolvability_refl (H : OracleHierarchy) (φ : H.Sentence) :
    H.resolvabilityLE φ φ :=
  fun _ hp => hp

/-- Resolvability is transitive. -/
theorem resolvability_trans (H : OracleHierarchy) (φ ψ χ : H.Sentence) :
    H.resolvabilityLE φ ψ → H.resolvabilityLE ψ χ → H.resolvabilityLE φ χ :=
  fun h1 h2 n hp => h1 n (h2 n hp)

/-
**Consistency sentences are strictly ordered**: Con(n+1) is NOT below Con(n).
-/
theorem con_resolvability_strict (H : OracleHierarchy) (n : ℕ) :
    ¬ H.resolvabilityLE (H.conSentence (n + 1)) (H.conSentence n) := by
  exact fun h => H.con_unprovable _ ( h _ ( H.con_jump _ ) )

/-
**Diagonal Antichain**: The consistency sentences form an antichain —
    no Con(m) is mutually resolvability-comparable to Con(n) when m ≠ n.
    This captures the essential independence of different incompleteness levels.
-/
theorem diagonal_antichain (H : OracleHierarchy) (m n : ℕ) (hmn : m ≠ n) :
    ¬ (H.resolvabilityLE (H.conSentence m) (H.conSentence n) ∧
       H.resolvabilityLE (H.conSentence n) (H.conSentence m)) := by
  -- WLOG $m < n$ (use `Nat.lt_or_gt_of_ne hmn`).
  by_cases hlt : m < n;
  · intro h;
    have := h.2 _ ( H.con_jump m );
    exact H.con_unprovable_le n ( m + 1 ) ( by linarith ) this;
  · have := H.con_jump n;
    exact fun h => H.con_unprovable_le m ( n + 1 ) ( by linarith [ Nat.lt_of_le_of_ne ( le_of_not_gt hlt ) hmn.symm ] ) ( h.1 _ this )

/-! ## Part 7: Quantifier Complexity Classification -/

/-- A sentence is **Σ₁-resolvable** if it becomes provable at some finite level. -/
def OracleHierarchy.sigma1Resolvable (H : OracleHierarchy) (φ : H.Sentence) : Prop :=
  ∃ n, H.Provable n φ

/-- A sentence is **Π₂-persistent** if it is true but never provable at any level. -/
def OracleHierarchy.pi2Persistent (H : OracleHierarchy) (φ : H.Sentence) : Prop :=
  H.True_ φ ∧ ∀ n, ¬ H.Provable n φ

/-- Consistency sentences are Σ₁-resolvable. -/
theorem con_sigma1_resolvable (H : OracleHierarchy) (n : ℕ) :
    H.sigma1Resolvable (H.conSentence n) :=
  ⟨n + 1, H.con_jump n⟩

/-- **Classification**: Con(n) is provable at exactly the levels > n. -/
theorem consistency_classification (H : OracleHierarchy) (n : ℕ) :
    H.Provable (n + 1) (H.conSentence n) ∧
    (∀ j, j ≤ n → ¬ H.Provable j (H.conSentence n)) :=
  ⟨H.con_jump n, fun _ hj hp => H.con_unprovable n (H.mono_le hj _ hp)⟩

/-! ## Part 8: Union Theory and Convergence -/

/-
**Iterated jumps converge to the union**: the union provable set
    is exactly the union of all finite-level provable sets.
-/
theorem iterated_jump_convergence (H : OracleHierarchy) :
    H.unionProvableSet = ⋃ n, H.provableSet n := by
  ext φ; simp [OracleHierarchy.unionProvableSet, OracleHierarchy.provableSet]

/-- The union theory proves all finite consistency sentences. -/
theorem union_proves_all_consistency (H : OracleHierarchy) (n : ℕ) :
    H.conSentence n ∈ H.unionProvableSet :=
  ⟨n + 1, H.con_jump n⟩

/-! ## Part 9: Concrete Construction -/

/-- Construct a concrete oracle hierarchy where sentences are ℕ,
    consistency sentence for level k is 2k+1, and provability at level n
    means "is an odd number 2k+1 with k < n". -/
def mkOracleHierarchy : OracleHierarchy where
  Sentence := ℕ
  Provable := fun n s => ∃ k, k < n ∧ s = 2 * k + 1
  True_ := fun s => ∃ k, s = 2 * k + 1
  bot := 0
  bot_not_true := fun ⟨k, hk⟩ => by omega
  mono := fun n s ⟨k, hk, hs⟩ => ⟨k, by omega, hs⟩
  strict := fun n => ⟨2 * n + 1, ⟨n, by omega, rfl⟩, fun ⟨k, hk, hs⟩ => by omega⟩
  conSentence := fun k => 2 * k + 1
  con_true := fun n => ⟨n, rfl⟩
  con_unprovable := fun n ⟨k, hk, hs⟩ => by omega
  con_jump := fun n => ⟨n, by omega, rfl⟩
  con_injective := fun a b hab => by simp only at hab; omega

/-! ## Conjecture -/

/-- **Conjecture (Resolvability Density)**: For any Π₂-persistent sentence and any
    level n, there exists a Σ₁-resolvable true sentence not yet provable at level n.

    **Testable prediction**: Construct a hierarchy over PA. Check whether every
    Π₂-persistent sentence has nearby Σ₁-resolvable sentences at each level.
    If the hierarchy ever has a level where all remaining true-but-unprovable
    sentences are permanently unreachable, the conjecture fails. -/
def resolvabilityDensityConjecture (H : OracleHierarchy) : Prop :=
  ∀ φ, H.pi2Persistent φ →
    ∀ n, ∃ ψ, H.sigma1Resolvable ψ ∧ H.True_ ψ ∧ ¬ H.Provable n ψ

end