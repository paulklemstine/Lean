/-
# Dependency Extraction: A Formal Theory of Proof-File Causality

This file formalizes a lightweight dependency model for proof files and proves
structural theorems about:
1. Theorem-level dependency acyclicity under declaration order
2. Import closure as a monotone, idempotent operator on finite sets

## Key results
- `no_self_dependency_of_respects_order`: no theorem depends on itself
- `dependency_edge_decreases_index`: dependency edges strictly decrease index
- `stepClosure_monotone`: one-step import closure is monotone
- `importClosure_monotone`: iterated import closure is monotone in step count
- `stepClosure_idempotent_of_closed`: closure is idempotent on closed sets
- `exists_rank_function`: well-ordered declarations admit a topological ranking
-/

import Mathlib

/-! ## Core Definitions -/

/-- A theorem declaration: a named entity with a finite set of dependencies. -/
structure ThmDecl where
  name : String
  deps : Finset String
  deriving DecidableEq

/-- A proof file abstraction: a list of imports and a list of theorem declarations. -/
structure ProofFile where
  imports : List String
  theorems : List ThmDecl

/-- The set of theorem names from a list of declarations. -/
def theoremNames (xs : List ThmDecl) : Finset String :=
  xs.foldl (fun acc t => insert t.name acc) ∅

/-- The set of theorem names from declarations strictly before position `i`. -/
def priorNames (xs : List ThmDecl) (i : Nat) : Finset String :=
  (xs.take i).foldl (fun acc t => insert t.name acc) ∅

/-- A list of declarations respects order if every theorem only depends on
    theorems declared earlier (before it in the list). -/
def DeclsRespectOrder (xs : List ThmDecl) : Prop :=
  ∀ i (hi : i < xs.length),
    (xs.get ⟨i, hi⟩).deps ⊆ priorNames xs i

/-- The edge relation on theorem names induced by a list of declarations:
    `Edge xs a b` means theorem `a` directly depends on theorem `b`. -/
def Edge (xs : List ThmDecl) (a b : String) : Prop :=
  ∃ t ∈ xs, t.name = a ∧ b ∈ t.deps

/-- Unique names property: all theorem names in the list are distinct. -/
def UniqueNames (xs : List ThmDecl) : Prop :=
  xs.Pairwise fun a b => a.name ≠ b.name

/-! ## Helper Lemmas -/

/-
Key helper: a name in `priorNames` comes from an earlier index.
-/
lemma mem_priorNames_of_get (xs : List ThmDecl) {j i : Nat}
    (hj : j < xs.length) (hji : j < i) :
    (xs.get ⟨j, hj⟩).name ∈ priorNames xs i := by
  -- By definition of `priorNames`, we know that if `j < i`, then `(xs.get ⟨j, hj⟩).name` is in `priorNames xs i`.
  have h_pname : (xs.get ⟨j, hj⟩).name ∈ List.foldl (fun (acc : Finset String) (t : ThmDecl) => acc ∪ {t.name}) ∅ (xs.take i) := by
    have h_pname : ∀ {l : List ThmDecl} {x : ThmDecl}, x ∈ l → x.name ∈ List.foldl (fun (acc : Finset String) (t : ThmDecl) => acc ∪ {t.name}) ∅ l := by
      intros l x hx; induction' l using List.reverseRecOn with l IH <;> aesop;
    convert h_pname _;
    rw [ List.mem_iff_get ];
    use ⟨ j, by
      rw [ List.length_take ] ; omega ⟩
    generalize_proofs at *;
    grind;
  convert h_pname using 1;
  unfold priorNames; induction ( xs.take i ) using List.reverseRecOn <;> aesop;

/-
Key helper: if a name is in `priorNames xs i`, it equals some `xs[j].name` for `j < i`.
-/
lemma exists_index_of_mem_priorNames (xs : List ThmDecl) {i : Nat} {s : String}
    (hs : s ∈ priorNames xs i) :
    ∃ j, ∃ hj : j < xs.length, j < i ∧ (xs.get ⟨j, hj⟩).name = s := by
  unfold priorNames at hs;
  induction' i with i ih generalizing xs s <;> simp_all +decide [ List.take_add_one ];
  grind

/-
If names are unique and `xs[j].name ∈ priorNames xs i`, then `j < i`.
-/
lemma index_lt_of_name_in_priorNames
    (xs : List ThmDecl)
    (hu : UniqueNames xs)
    {i j : Nat} (_hi : i < xs.length) (hj : j < xs.length)
    (hmem : (xs.get ⟨j, hj⟩).name ∈ priorNames xs i) :
    j < i := by
  have h_exists_index : ∃ k, ∃ hk : k < xs.length, k < i ∧ (xs.get ⟨k, hk⟩).name = (xs.get ⟨j, hj⟩).name := by
    exact exists_index_of_mem_priorNames xs hmem;
  have := List.pairwise_iff_get.mp hu;
  grind

/-! ## Main Theorems: Declaration Order -/

/-
**Theorem 1**: No theorem depends on itself in a well-ordered declaration list
    with unique names. This is the first anti-circularity theorem for proof architecture.
-/
theorem no_self_dependency_of_respects_order
    (xs : List ThmDecl)
    (hu : UniqueNames xs)
    (h : DeclsRespectOrder xs)
    {i : Nat} (hi : i < xs.length) :
    (xs.get ⟨i, hi⟩).name ∉ (xs.get ⟨i, hi⟩).deps := by
  -- Apply the hypothesis `h` to get that the deps of the i-th element are a subset of the priorNames of i.
  have h_subset : (xs.get ⟨i, hi⟩).deps ⊆ priorNames xs i := by
    exact h i hi;
  exact fun h => by have := index_lt_of_name_in_priorNames xs hu hi hi ( h_subset h ) ; linarith;

/-
**Theorem 2**: If theorem `i` depends on theorem `j` (by name), then `j < i`.
    Dependency edges strictly decrease the declaration index.
-/
theorem dependency_edge_decreases_index
    (xs : List ThmDecl)
    (hu : UniqueNames xs)
    (h : DeclsRespectOrder xs)
    {i j : Nat}
    (hi : i < xs.length)
    (hj : j < xs.length)
    (hname : (xs.get ⟨j, hj⟩).name ∈ (xs.get ⟨i, hi⟩).deps) :
    j < i := by
  exact index_lt_of_name_in_priorNames _ hu hi hj ( h i hi hname )

/-
**Theorem 3**: There exists a rank function on theorem names such that
    every dependency edge strictly decreases rank. This is a certified
    topological ranking theorem.
-/
theorem exists_rank_function
    (xs : List ThmDecl)
    (hu : UniqueNames xs)
    (h : DeclsRespectOrder xs) :
    ∃ r : String → Nat,
      ∀ {i j : Nat} (hi : i < xs.length) (hj : j < xs.length),
        (xs.get ⟨j, hj⟩).name ∈ (xs.get ⟨i, hi⟩).deps →
        r (xs.get ⟨j, hj⟩).name < r (xs.get ⟨i, hi⟩).name := by
  by_contra! h_contra;
  -- By definition of `UniqueNames`, every theorem name in `xs` is unique.
  have h_unique_names : List.Nodup (List.map ThmDecl.name xs) := by
    rw [ List.nodup_iff_injective_get ];
    intro i j hij;
    have := List.pairwise_iff_get.mp hu;
    exact le_antisymm ( le_of_not_gt fun hi => this ⟨ j, by simpa using j.2 ⟩ ⟨ i, by simpa using i.2 ⟩ hi <| by simpa using hij.symm ) ( le_of_not_gt fun hj => this ⟨ i, by simpa using i.2 ⟩ ⟨ j, by simpa using j.2 ⟩ hj <| by simpa using hij );
  -- By definition of `UniqueNames`, every theorem name in `xs` is unique, so we can define `r` as the index of each theorem name in `xs`.
  obtain ⟨r, hr⟩ : ∃ r : String → ℕ, ∀ i (hi : i < xs.length), r (xs.get ⟨i, hi⟩).name = i := by
    use fun s => List.findIdx (fun t => t.name = s) xs;
    intro i hi;
    have h_findIdx : ∀ {l : List ThmDecl} {p : ThmDecl → Bool} {i : ℕ} (hi : i < l.length), p (l.get ⟨i, hi⟩) → (∀ j (hj : j < l.length), j ≠ i → ¬p (l.get ⟨j, hj⟩)) → List.findIdx p l = i := by
      grind +revert;
    apply h_findIdx hi;
    · simp +decide;
    · intro j hj hij; have := List.nodup_iff_injective_get.mp h_unique_names; simp_all +decide [ Function.Injective ] ;
      exact fun h => hij <| by simpa [ Fin.ext_iff ] using @this ⟨ j, by simpa using hj ⟩ ⟨ i, by simpa using hi ⟩ h;
  obtain ⟨ i, j, hi, hj, h₁, h₂ ⟩ := h_contra r ; linarith [ hr i hi, hr j hj, dependency_edge_decreases_index xs hu h hi hj h₁ ]

/-! ## Import Closure -/

/-- One step of import closure: add all direct imports of current set members. -/
def stepClosure (G : String → Finset String) (S : Finset String) : Finset String :=
  S ∪ S.biUnion G

/-- Iterated import closure. -/
def importClosure (G : String → Finset String) : Nat → Finset String → Finset String
  | 0, S => S
  | n + 1, S => importClosure G n (stepClosure G S)

/-- A set is import-closed if all imports of its members are already in the set. -/
def ImportClosed (G : String → Finset String) (S : Finset String) : Prop :=
  ∀ x ∈ S, G x ⊆ S

/-
**Theorem 4**: `stepClosure` is monotone.
-/
theorem stepClosure_monotone'
    (G : String → Finset String) :
    Monotone (stepClosure G) := by
  exact fun x y hxy => Finset.union_subset_union hxy ( Finset.biUnion_subset_biUnion_of_subset_left _ hxy )

/-
The base set is always contained in its step closure.
-/
theorem subset_stepClosure (G : String → Finset String) (S : Finset String) :
    S ⊆ stepClosure G S := by
  exact Finset.subset_union_left

/-
Helper: importClosure is monotone in its input set argument.
-/
lemma importClosure_mono_set (G : String → Finset String) (n : Nat)
    {S T : Finset String} (hST : S ⊆ T) :
    importClosure G n S ⊆ importClosure G n T := by
  induction' n with n ih generalizing S T;
  · exact hST;
  · convert ih ( stepClosure_monotone' G hST ) using 1

/-
**Theorem 5**: Import closure is monotone in the number of steps.
-/
theorem importClosure_monotone
    (G : String → Finset String) {m n : Nat} (hmn : m ≤ n) (S : Finset String) :
    importClosure G m S ⊆ importClosure G n S := by
  induction' hmn with n hmn ih;
  · grind;
  · exact Set.Subset.trans ih ( importClosure_mono_set G n ( subset_stepClosure G _ ) )

/-
**Theorem 6**: Step closure is idempotent on import-closed sets.
-/
theorem stepClosure_idempotent_of_closed
    (G : String → Finset String) {S : Finset String}
    (hS : ImportClosed G S) :
    stepClosure G S = S := by
  exact Finset.union_eq_left.mpr ( Finset.biUnion_subset.mpr fun x hx => hS x hx )

/-! ## Concrete Example -/

/-- An example proof file with three theorems forming a chain: C depends on B, B on A. -/
def exampleFile : ProofFile where
  imports := ["Mathlib.Data.Nat.Basic", "Mathlib.Tactic"]
  theorems := [
    ⟨"A", ∅⟩,
    ⟨"B", {"A"}⟩,
    ⟨"C", {"A", "B"}⟩
  ]

#eval exampleFile.imports

/-! ## Future Connections

This framework can be extended to:
- **Metaprogramming**: Extract actual dependencies from Lean's `Environment` using
  `Lean.Environment.find?` and `Lean.ConstantInfo.getUsedConstants`.
- **Proof complexity**: Measure dependency depth as a complexity invariant.
- **Holographic compression**: Boundary-to-bulk reconstruction via import closures.
- **Semantic stratification**: Layer theorems by dependency depth.
-/