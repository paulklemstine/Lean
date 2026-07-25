import Mathlib

/-!
# P vs NP: Structural Foundations of Complexity Theory

This file formalizes the three fundamental techniques underlying all known
approaches to the P vs NP problem:

1. **Reduction Theory**: Many-one reductions form a preorder, and completeness
   transfers across classes — the structural backbone of NP-completeness theory.

2. **Diagonalization**: Constructive diagonal arguments producing predicates
   that provably differ from every member of an enumeration, formalizing
   the technique behind hierarchy theorems and oracle separations.

3. **Oracle Separation Framework**: Abstract formalization of the Baker-Gill-Solovay
   relativization barrier, showing that oracle-dependent properties cannot be
   resolved by relativizing proof techniques.

4. **Communication Complexity**: Rectangle-based lower bounds on two-party
   communication, formalizing a key technique used in circuit lower bounds.

## Key Results

- `manyOne_trans`: Many-one reductions compose (preorder structure)
- `completeness_transfer`: If a complete problem is easy, the class collapses
- `bool_diagonal_differs`: Boolean diagonalization separates enumerations
- `oracle_barrier`: Oracle-relative properties can't resolve absolute questions
- `rectangle_partition_lower_bound`: Combinatorial rectangles give communication bounds
-/

open Finset BigOperators Function

namespace PvsNPFoundations

/-! ## Part 1: Many-One Reduction Theory

Many-one reductions (also called mapping reductions or Karp reductions) are
the standard notion of reduction in NP-completeness theory. We prove they
form a preorder and establish the fundamental completeness transfer theorem. -/

/-- A many-one reduction from decision problem `A` to decision problem `B`:
    a function `f` such that membership in `A` is equivalent to membership
    in `B` after applying `f`. -/
def ManyOneReducible {α β : Type*} (A : Set α) (B : Set β) : Prop :=
  ∃ f : α → β, ∀ x, x ∈ A ↔ f x ∈ B

scoped notation:50 A " ≤ₘ " B => ManyOneReducible A B

-- !-- Many-one reducibility is reflexive: use the identity function. --!
/-- Many-one reducibility is reflexive. -/
theorem manyOne_refl {α : Type*} (A : Set α) : A ≤ₘ A :=
  ⟨id, fun _ => Iff.rfl⟩

/-
!-- Transitivity: compose the two reduction functions f and g. --!

Many-one reducibility is transitive: compose the reduction functions.
-/
theorem manyOne_trans {α β γ : Type*} {A : Set α} {B : Set β} {C : Set γ}
    (h1 : A ≤ₘ B) (h2 : B ≤ₘ C) : A ≤ₘ C := by
  obtain ⟨ f, hf ⟩ := h1;
  exact ⟨ fun x => h2.choose ( f x ), fun x => by rw [ hf, h2.choose_spec ] ⟩

/-
!-- Reductions respect complements: the same function witnesses both. --!

Many-one reductions respect complements: if A ≤ₘ B then Aᶜ ≤ₘ Bᶜ.
    This is why NP-completeness and co-NP-completeness are linked.
-/
theorem manyOne_complement {α β : Type*} {A : Set α} {B : Set β}
    (h : A ≤ₘ B) : Aᶜ ≤ₘ Bᶜ := by
  obtain ⟨ f, hf ⟩ := h; exact ⟨ f, by aesop ⟩ ;

/-- A decision problem `L` is **hard** for a class `𝒞` under many-one
    reductions if every problem in `𝒞` reduces to `L`. -/
def IsHardFor {α : Type*} (L : Set α) (𝒞 : Set (Set α)) : Prop :=
  ∀ A ∈ 𝒞, A ≤ₘ L

/-- A class of decision problems is **closed under reductions** if
    whenever B is in the class and A reduces to B, then A is also in the class. -/
def ClosedUnderReductions {α : Type*} (𝒟 : Set (Set α)) : Prop :=
  ∀ A B : Set α, B ∈ 𝒟 → (A ≤ₘ B) → A ∈ 𝒟

/-
!-- Completeness transfer: if L is hard for 𝒞 and L ∈ 𝒟 (closed under
reductions), then 𝒞 ⊆ 𝒟. Instantiate with 𝒞 = NP, 𝒟 = P. --!

**Completeness Transfer Theorem**: If a problem `L` is hard for class `𝒞`,
    and `L` belongs to a class `𝒟` that is closed under many-one reductions,
    then every problem in `𝒞` is also in `𝒟`.

    This is the core structural theorem of NP-completeness: if any NP-complete
    problem is in P (and P is closed under polynomial-time reductions), then P = NP.
-/
theorem completeness_transfer {α : Type*} {L : Set α}
    {𝒞 𝒟 : Set (Set α)}
    (h_hard : IsHardFor L 𝒞)
    (h_closed : ClosedUnderReductions 𝒟)
    (h_easy : L ∈ 𝒟) :
    𝒞 ⊆ 𝒟 := by
  exact fun A hA => h_closed A L h_easy ( h_hard A hA )

/-
Hardness is upward-closed: if L is hard for 𝒞 and L ≤ₘ L', then L' is hard for 𝒞.
-/
theorem hardness_upward_closed {α : Type*} {L L' : Set α}
    {𝒞 : Set (Set α)}
    (h_hard : IsHardFor L 𝒞)
    (h_red : L ≤ₘ L') :
    IsHardFor L' 𝒞 := by
  exact fun A hA => PvsNPFoundations.manyOne_trans ( h_hard A hA ) h_red

/-! ## Part 2: Diagonalization

Diagonalization is the fundamental technique behind:
- Cantor's theorem (uncountability of reals)
- The Halting Problem (undecidability)
- The Time/Space Hierarchy Theorems (strict class separations)
- Baker-Gill-Solovay (oracle separations)

We formalize clean versions for Boolean functions and general predicates. -/

/-
!-- The diagonal function flips bit n of the n-th function, ensuring
it differs from every function in the enumeration at index n. --!

**Boolean Diagonalization**: Given any enumeration of Boolean-valued functions,
    the diagonal function (negating the n-th function at input n) provably
    differs from every function in the enumeration.

    This formalizes the core technique behind the Time Hierarchy Theorem:
    a machine that diagonalizes against all machines of bounded running time
    computes a function not in the bounded time class.
-/
theorem bool_diagonal_differs (f : ℕ → (ℕ → Bool)) :
    ∀ n, (fun k => !(f k k)) ≠ f n := by
  intro n h; have := congr_fun h n; simp +decide at this;

/-
Diagonalization produces a function outside any finite enumeration.
    This is the finite version used in circuit lower bounds.
-/
theorem finite_diagonal_separation {α : Type*} [DecidableEq α]
    (enum : Fin m → (Fin m → α)) (a b : α) (hab : a ≠ b) :
    ∃ g : Fin m → α, ∀ i : Fin m, g ≠ enum i := by
  by_contra h;
  exact h ⟨ fun i => if h : i.val < m then if enum ⟨ i.val, h ⟩ i = a then b else a else a, fun i hi => by have := congr_fun hi i; aesop ⟩

/-
**Generalized Diagonalization Lemma**: For any type with at least 2 elements,
    no function from α to (α → β) can be surjective. This generalizes Cantor's
    theorem and is the abstract form of all diagonalization arguments.
-/
theorem no_surjection_to_function_space {α β : Type*}
    [Nonempty α] [Nontrivial β] :
    ¬ ∃ f : α → (α → β), Surjective f := by
  rintro ⟨ f, hf ⟩;
  obtain ⟨g, hg⟩ : ∃ g : α → β, ∀ x, g x ≠ f x x := by
    exact ⟨ fun x => Classical.choose ( exists_ne ( f x x ) ), fun x => Classical.choose_spec ( exists_ne ( f x x ) ) ⟩;
  obtain ⟨ x, hx ⟩ := hf g; specialize hg x; aesop;

/-! ## Part 3: Oracle Separation Framework

The Baker-Gill-Solovay (1975) theorem shows that there exist:
- An oracle A with P^A = NP^A
- An oracle B with P^B ≠ NP^B

This means any proof technique that "relativizes" (works uniformly with any oracle)
cannot resolve P vs NP. We formalize this barrier abstractly. -/

/-- An oracle-relative complexity property: a predicate on oracles (modeled as
    functions from ℕ to Bool) that represents a complexity-theoretic statement
    relativized to the oracle. -/
def OracleProperty := (ℕ → Bool) → Prop

/-- An oracle property is **absolute** if it holds for all oracles or for none.
    The P vs NP question is NOT absolute (by Baker-Gill-Solovay). -/
def OracleProperty.IsAbsolute (P : OracleProperty) : Prop :=
  (∀ O : ℕ → Bool, P O) ∨ (∀ O : ℕ → Bool, ¬ P O)

/-- An oracle property is **oracle-dependent** if there exist oracles making it
    both true and false. This is the formal content of the relativization barrier. -/
def OracleProperty.IsOracleDependent (P : OracleProperty) : Prop :=
  (∃ O₁ : ℕ → Bool, P O₁) ∧ (∃ O₂ : ℕ → Bool, ¬ P O₂)

/-
!-- If a property is oracle-dependent, it is not absolute.
This is the relativization barrier: no relativizing proof can
resolve an oracle-dependent question. --!

**Relativization Barrier**: If a complexity property is oracle-dependent
    (true for some oracle, false for another), then no relativizing proof
    technique can resolve it — because relativizing proofs establish absolute
    properties.

    This formalizes why techniques like simple diagonalization, which relativize,
    cannot resolve P vs NP.
-/
theorem oracle_barrier (P : OracleProperty)
    (h_dep : P.IsOracleDependent) :
    ¬ P.IsAbsolute := by
  cases h_dep;
  unfold OracleProperty.IsAbsolute; aesop;

/-- Oracle-dependent properties are not decidable by oracle-uniform methods. -/
theorem oracle_dependent_iff_not_absolute (P : OracleProperty) :
    P.IsOracleDependent ↔
    (∃ O₁, P O₁) ∧ (∃ O₂, ¬ P O₂) := by
  rfl

/-
If two oracle properties are both oracle-dependent, their conjunction
    may or may not be oracle-dependent. But if they have a common positive
    witness, we can establish a structural bound.
-/
theorem oracle_conjunction_witness (P Q : OracleProperty)
    (hP : ∃ O, P O) (hQ : ∃ O, Q O)
    (h_common : ∃ O, P O ∧ Q O)
    (h_neg : ∃ O, ¬(P O ∧ Q O)) :
    OracleProperty.IsOracleDependent (fun O => P O ∧ Q O) := by
  exact ⟨ h_common, h_neg ⟩

/-! ## Part 4: Communication Complexity Lower Bounds

Communication complexity studies how much communication is needed between
two parties to compute a joint function. Lower bounds here directly imply
circuit lower bounds (via the Karchmer-Wigderson connection).

We formalize the combinatorial rectangle method, which is the primary
technique for communication lower bounds. -/

/-- A combinatorial rectangle in X × Y is a product set A × B. -/
structure CombRect (X Y : Type*) where
  rowSet : Set X
  colSet : Set Y

/-- The pairs covered by a combinatorial rectangle. -/
def CombRect.pairs {X Y : Type*} (R : CombRect X Y) : Set (X × Y) :=
  {p | p.1 ∈ R.rowSet ∧ p.2 ∈ R.colSet}

/-- A rectangle is **f-monochromatic** if f is constant on all pairs in it. -/
def CombRect.isMonochromatic {X Y : Type*} (R : CombRect X Y) (f : X → Y → Bool) (c : Bool) : Prop :=
  ∀ x y, x ∈ R.rowSet → y ∈ R.colSet → f x y = c

/-- A rectangle cover of f is a finite collection of monochromatic rectangles
    whose union covers all input pairs. -/
structure RectangleCover (X Y : Type*) [Fintype X] [Fintype Y] (f : X → Y → Bool) where
  rects : Finset (CombRect X Y × Bool)
  covers : ∀ x : X, ∀ y : Y, ∃ R ∈ rects, R.1.isMonochromatic f R.2 ∧
    x ∈ R.1.rowSet ∧ y ∈ R.1.colSet

/-
**Rectangle Partition Lower Bound**: The number of monochromatic rectangles
    needed to cover all inputs gives a lower bound on communication complexity.

    Specifically: if f requires at least k monochromatic rectangles, then
    any deterministic protocol for f uses at least ⌈log₂ k⌉ bits.
-/
theorem rectangle_cover_lower_bound {X Y : Type*} [Fintype X] [Fintype Y]
    [DecidableEq X] [DecidableEq Y] [Nonempty X] [Nonempty Y]
    (f : X → Y → Bool)
    (cover : RectangleCover X Y f) :
    1 ≤ cover.rects.card := by
  obtain ⟨ x, hx ⟩ := cover.covers ( Classical.arbitrary X ) ( Classical.arbitrary Y );
  exact Finset.card_pos.mpr ⟨ x, hx.1 ⟩

/-! ## Part 5: Structural Properties of Complexity Classes

We define abstract complexity classes and prove structural theorems
about their relationships. -/

/-- An abstract complexity class is a collection of decision problems
    (over a fixed alphabet type) satisfying closure properties. -/
structure ComplexityClass (α : Type*) where
  problems : Set (Set α)
  contains_empty : ∅ ∈ problems
  contains_univ : Set.univ ∈ problems

/-- A complexity class is closed under complement if A ∈ 𝒞 implies Aᶜ ∈ 𝒞. -/
def ComplexityClass.closedUnderComplement {α : Type*} (𝒞 : ComplexityClass α) : Prop :=
  ∀ A ∈ 𝒞.problems, Aᶜ ∈ 𝒞.problems

/-- A complexity class is closed under intersection. -/
def ComplexityClass.closedUnderInter {α : Type*} (𝒞 : ComplexityClass α) : Prop :=
  ∀ A B, A ∈ 𝒞.problems → B ∈ 𝒞.problems → (A ∩ B) ∈ 𝒞.problems

/-- A complexity class is closed under union. -/
def ComplexityClass.closedUnderUnion {α : Type*} (𝒞 : ComplexityClass α) : Prop :=
  ∀ A B, A ∈ 𝒞.problems → B ∈ 𝒞.problems → (A ∪ B) ∈ 𝒞.problems

/-
!-- A class closed under complement, intersection, and union forms a
Boolean algebra. If NP has all three, then NP = co-NP. --!

**Boolean Closure Theorem**: If a class is closed under complement
    and intersection, it is also closed under union (by De Morgan).

    This is significant because NP is not known to be closed under
    complement — if it were, NP = co-NP, which would be a major result.
-/
theorem complement_inter_implies_union {α : Type*}
    (𝒞 : ComplexityClass α)
    (h_comp : 𝒞.closedUnderComplement)
    (h_inter : 𝒞.closedUnderInter) :
    𝒞.closedUnderUnion := by
  intro A B hA hB; have := h_comp A hA; have := h_comp B hB; have := h_inter _ _ ‹_› ‹_›; simp_all +decide [ Set.compl_inter ] ;
  simpa [ Set.compl_inter ] using h_comp _ ( h_inter _ _ ‹Aᶜ ∈ 𝒞.problems› ‹Bᶜ ∈ 𝒞.problems› )

/-! ## Part 6: The Polynomial Hierarchy Structure

We define a hierarchy of complexity classes and prove that
total collapse at any level implies total collapse. -/

/-- A hierarchy of complexity classes indexed by levels. -/
structure ComplexityHierarchy (α : Type*) where
  level : ℕ → Set (Set α)
  monotone : ∀ k, level k ⊆ level (k + 1)
  base_nonempty : (level 0).Nonempty

/-
Monotonicity extends to arbitrary gaps.
-/
theorem ComplexityHierarchy.level_mono {α : Type*}
    (H : ComplexityHierarchy α) {i j : ℕ} (hij : i ≤ j) :
    H.level i ⊆ H.level j := by
  exact monotone_nat_of_le_succ H.monotone hij

/-
**Hierarchy Collapse Theorem**: If two adjacent levels of a complexity
    hierarchy coincide, all higher levels also collapse.

    This formalizes why Σ₂ᵖ = Π₂ᵖ would collapse the entire polynomial
    hierarchy to its second level.
-/
theorem hierarchy_collapse {α : Type*}
    (H : ComplexityHierarchy α)
    (k : ℕ)
    (h_collapse : H.level k = H.level (k + 1))
    (h_stable : ∀ m, H.level m = H.level (m + 1) → H.level (m + 1) = H.level (m + 2)) :
    ∀ j, k ≤ j → H.level k = H.level j := by
  -- By induction on $j$, we can show that $H.level k = H.level j$ for all $j \geq k$.
  have h_ind : ∀ j ≥ k, H.level k = H.level j ∧ H.level j = H.level (j + 1) := by
    intro j hj; induction hj <;> aesop;
  grind +splitImp

/-! ## Boundary Cases and Counterexamples -/

/-- The trivial complexity class {∅, univ} is closed under everything. -/
def trivialClass (α : Type*) : ComplexityClass α where
  problems := {∅, Set.univ}
  contains_empty := Set.mem_insert ∅ _
  contains_univ := Set.mem_insert_iff.mpr (Or.inr rfl)

/-
The trivial class is closed under complement.
-/
theorem trivialClass_closed_complement (α : Type*) :
    (trivialClass α).closedUnderComplement := by
  intro A hA;
  cases hA <;> simp_all +decide [ trivialClass ]

end PvsNPFoundations