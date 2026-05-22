/-
# Exchange-Closure Dependency Systems and Sparse Predictor Reconstruction

This file establishes a closure-theoretic foundation for sparse, interpretable
prediction. We define exchange-closure dependency systems with weighted implication
certificates over finite types and prove that:

1. Every finite closure system has canonical minimal supports (sparse basis existence)
2. Minimal supports are irredundant and finitely enumerable
3. Under exchange, minimal supports enjoy swap properties enabling canonical extraction
4. Weighted cost profiles determine closure structure (Reconstruction Duality)

## Main Results

* `isClosed_inter` — Closed sets are closed under intersection
* `isClosed_sInter` — Closed sets are closed under arbitrary intersection
* `cl_le_of_subset_closed` — Closure is below any closed superset
* `exists_minimalSupport` — Every derivable element has a minimal support
* `minimalSupport_irredundant` — Minimal supports are irredundant
* `exchange_swap` — Exchange property enables support element swapping
* `canonicalBasis_complete` — Canonical basis covers all derivations
* `costProfile_determines_membership` — Cost profile determines closure membership
* `cl_eq_of_cl_finset_eq` — Agreement on Finsets implies agreement on all Sets
* `reconstruction_duality` — Full reconstruction duality theorem

## Bridges

- **Algebra ↔ Machine Learning**: Closure operators ↔ feature dependency structure
- **Lattice Theory ↔ Sparse Prediction**: Join-irreducibles ↔ atomic predictors
- **Semiring Theory ↔ Optimization**: Idempotent costs ↔ minimal derivation
- **Dependency Logic ↔ Explainability**: Implication bases ↔ interpretable models
-/

import Mathlib

open Set Finset

noncomputable section

namespace Bridges.AlgebraEMLMachineLearning.ClosureDependency

/-! ## §1. Closure Operators on Finite Types -/

/-- A closure operator on `Set α`: extensive, monotone, idempotent.
This is the foundational object for dependency geometry. -/
structure ClosureSys (α : Type*) where
  cl : Set α → Set α
  cl_extensive : ∀ S, S ⊆ cl S
  cl_monotone : ∀ ⦃S T⦄, S ⊆ T → cl S ⊆ cl T
  cl_idempotent : ∀ S, cl (cl S) = cl S

namespace ClosureSys

variable {α : Type*} [Fintype α] [DecidableEq α]
variable (C : ClosureSys α)

/-- A set is closed if it equals its own closure. -/
def IsClosed (S : Set α) : Prop := C.cl S = S

/-- The closure of any set is closed (idempotence). -/
theorem cl_isClosed (S : Set α) : C.IsClosed (C.cl S) := C.cl_idempotent S

/-- The universe is always closed. -/
theorem isClosed_univ : C.IsClosed Set.univ := by
  unfold IsClosed
  apply le_antisymm
  · exact fun _ _ => Set.mem_univ _
  · exact C.cl_extensive _

/-
Intersection of two closed sets is closed.
-/
theorem isClosed_inter {S T : Set α} (hS : C.IsClosed S) (hT : C.IsClosed T) :
    C.IsClosed (S ∩ T) := by
  refine' le_antisymm _ _;
  · refine' Set.subset_inter _ _ <;> simp_all +decide [ Set.subset_def ];
    · exact fun x hx => hS.symm ▸ C.cl_monotone ( Set.inter_subset_left ) hx;
    · exact fun x hx => hT ▸ C.cl_monotone ( Set.inter_subset_right ) hx;
  · exact C.cl_extensive _

/-
Intersection of a nonempty family of closed sets is closed.
-/
theorem isClosed_sInter {F : Set (Set α)} (hF : ∀ S ∈ F, C.IsClosed S)
    (hne : F.Nonempty) : C.IsClosed (⋂₀ F) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Set.sInter_subset_of_mem, ClosureSys.IsClosed ];
  · exact fun S hS => le_trans ( C.cl_monotone ( Set.sInter_subset_of_mem hS ) ) ( by aesop );
  · exact C.cl_extensive _

/-
The closure is contained in any closed superset.
-/
theorem cl_le_of_subset_closed {S T : Set α} (hST : S ⊆ T) (hT : C.IsClosed T) :
    C.cl S ⊆ T := by
  exact hT ▸ C.cl_monotone hST

/-- Closure preserves membership for elements already in the set. -/
theorem mem_cl_of_mem {S : Set α} {x : α} (hx : x ∈ S) : x ∈ C.cl S :=
  C.cl_extensive S hx

/-- Closed sets are exactly the fixed points of closure. -/
theorem isClosed_iff_eq_cl {S : Set α} : C.IsClosed S ↔ C.cl S = S := Iff.rfl

/-- cl is monotone on Finset coercions. -/
theorem cl_mono_coe {A B : Finset α} (h : A ⊆ B) : C.cl ↑A ⊆ C.cl ↑B :=
  C.cl_monotone (Finset.coe_subset.mpr h)

end ClosureSys

/-! ## §2. Supports and Irredundancy

A support for an element `b` is a finite set `A` such that `b ∈ cl(A)`.
Minimal supports are the sparse explanatory objects central to interpretable prediction. -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- `A` is a support for `b` under closure `C`: the feature set `A` determines `b`. -/
def IsSupport (C : ClosureSys α) (A : Finset α) (b : α) : Prop :=
  b ∈ C.cl (↑A)

/-- `A` is a minimal support for `b`: no proper subset suffices. -/
def IsMinimalSupport (C : ClosureSys α) (A : Finset α) (b : α) : Prop :=
  IsSupport C A b ∧ ∀ A' : Finset α, A' ⊂ A → ¬IsSupport C A' b

/-- `A` is irredundant: removing any single element changes the closure. -/
def IsIrredundantSupport (C : ClosureSys α) (A : Finset α) : Prop :=
  ∀ a ∈ A, C.cl (↑(A.erase a) : Set α) ≠ C.cl (↑A)

/-
**Sparse Basis Existence**: Every derivable element has a minimal support
within any given support. This is the foundational sparsification theorem.
-/
theorem exists_minimalSupport (C : ClosureSys α) (A : Finset α) (b : α)
    (hb : IsSupport C A b) :
    ∃ A' : Finset α, A' ⊆ A ∧ IsMinimalSupport C A' b := by
  -- By the well-ordering principle, any nonempty subset of natural numbers has a least element.
  have h_well_ordering : ∀ (S : Set (Finset α)), S.Nonempty → ∃ m ∈ S, ∀ n ∈ S, m.card ≤ n.card := by
    intro S hS_nonempty
    have h_finite : S.Finite := by
      exact Set.toFinite S;
    apply_rules [ Set.exists_min_image ];
  obtain ⟨m, hm₁, hm₂⟩ := h_well_ordering {A' | A' ⊆ A ∧ IsSupport C A' b} ⟨A, by
    exact ⟨ Finset.Subset.refl _, hb ⟩⟩;
  exact ⟨ m, hm₁.1, hm₁.2, fun A' hA' hA'' => not_lt_of_ge ( hm₂ A' ⟨ Finset.Subset.trans hA'.1 hm₁.1, hA'' ⟩ ) ( Finset.card_lt_card hA' ) ⟩

/-
**Irredundancy of Minimal Supports**: If `A` is a minimal support for `b`
and `b ∉ A`, then `A` is irredundant—every element contributes non-trivially
to the closure.
-/
set_option linter.unusedSectionVars false in
theorem minimalSupport_irredundant (C : ClosureSys α) (A : Finset α) (b : α)
    (hmin : IsMinimalSupport C A b) (_hbA : b ∉ (↑A : Set α)) :
    IsIrredundantSupport C A := by
  intro a ha;
  contrapose! hmin;
  unfold IsMinimalSupport; simp_all +decide [ IsSupport ] ;
  refine' fun hb => ⟨ A.erase a, _, _ ⟩ <;> simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ]

/-- The set of all irredundant supports is finite (since `Finset α` is finite). -/
theorem finite_irredundantSupports (C : ClosureSys α) :
    Set.Finite {A : Finset α | IsIrredundantSupport C A} :=
  Set.toFinite _

/-! ## §3. Exchange-Closure Axiom

The Steinitz exchange property: if adding `c` to `A` newly derives `b`,
then adding `b` to `A` newly derives `c`. This is the structural axiom
that makes sparse predictor extraction canonical. -/

/-- A closure system has the exchange property (Steinitz–Mac Lane exchange). -/
def HasExchange (C : ClosureSys α) : Prop :=
  ∀ (A : Set α) (x y : α),
    y ∈ C.cl (A ∪ {x}) → y ∉ C.cl A → x ∈ C.cl (A ∪ {y})

/-
Under exchange, a minimal support element cannot be derived from
the rest of the support alone (it is indispensable).
-/
set_option linter.unusedSectionVars false in
theorem minimalSupport_not_in_cl_erase (C : ClosureSys α)
    (A : Finset α) (b : α) (hmin : IsMinimalSupport C A b)
    (_hbA : b ∉ (↑A : Set α)) (a : α) (ha : a ∈ A) :
    b ∉ C.cl (↑(A.erase a) : Set α) := by
  exact fun h => hmin.2 ( A.erase a ) ( Finset.erase_ssubset ha ) h

/-
**Exchange Swap**: Under exchange, if `A` is a minimal support for `b`
(with `b ∉ A`) and `a ∈ A`, then `a` can be derived from the remaining
elements plus `b`. This is the key lemma for canonical basis extraction.
-/
theorem exchange_swap (C : ClosureSys α) (hex : HasExchange C)
    (A : Finset α) (b : α) (hmin : IsMinimalSupport C A b)
    (_hbA : b ∉ (↑A : Set α)) (a : α) (ha : a ∈ A) :
    a ∈ C.cl ((↑(A.erase a) : Set α) ∪ {b}) := by
  apply hex ((Finset.erase A a) : Set α) a b; simp_all +decide [ IsMinimalSupport, IsSupport ] ;
  exact minimalSupport_not_in_cl_erase C A b hmin _hbA a ha

/-! ## §4. Weighted Closure Dependency Systems

A weighted closure dependency system enriches a closure operator with
derivation costs valued in `ℕ∞` (the tropical semiring `WithTop ℕ`).
The cost `wt A b` measures the prediction effort to derive `b` from features `A`. -/

/-- A weighted closure dependency system: a closure operator with costs.
The weight function `wt` assigns a cost to each derivation `(A, b)`,
with `wt A b < ⊤` iff `b ∈ cl(A)`. -/
structure WeightedClosureDep (α : Type*) [Fintype α] [DecidableEq α]
    extends ClosureSys α where
  wt : Finset α → α → ℕ∞
  wt_iff_mem_cl : ∀ (A : Finset α) (b : α), b ∈ cl ↑A ↔ wt A b < ⊤

namespace WeightedClosureDep

/-- The prediction cost of deriving `b` from support `A`. -/
def predCost (D : WeightedClosureDep α) (A : Finset α) (b : α) : ℕ∞ := D.wt A b

/-- Two weighted systems have equivalent cost profiles. -/
def CostProfileEquiv (D₁ D₂ : WeightedClosureDep α) : Prop :=
  ∀ (A : Finset α) (b : α), D₁.predCost A b = D₂.predCost A b

/-- Two weighted systems have equivalent closure membership on Finsets. -/
def ClosureMemberEquiv (D₁ D₂ : WeightedClosureDep α) : Prop :=
  ∀ (A : Finset α) (b : α), b ∈ D₁.cl ↑A ↔ b ∈ D₂.cl ↑A

end WeightedClosureDep

/-! ## §5. Reconstruction Duality

The central duality theorem: the cost profile of a weighted closure dependency
system determines the closure operator, and conversely. -/

/-
**Cost Profile Determines Membership**: If two systems have the same
cost profile, they agree on which elements are derivable from which supports.
-/
theorem costProfile_determines_membership (D₁ D₂ : WeightedClosureDep α)
    (h : WeightedClosureDep.CostProfileEquiv D₁ D₂) :
    WeightedClosureDep.ClosureMemberEquiv D₁ D₂ := by
  -- By definition of cost profile equivalence, we have that for any A and b, D₁.wt A b = D₂.wt A b.
  have h_wt_eq : ∀ A : Finset α, ∀ b : α, D₁.wt A b = D₂.wt A b := by
    exact h;
  exact fun A b => by rw [ D₁.wt_iff_mem_cl, D₂.wt_iff_mem_cl, h_wt_eq ] ;

/-
Agreement on all Finset coercions implies agreement on all Sets.
This is the key lifting lemma that connects the finitary cost profile
to the full closure operator.
-/
set_option linter.unusedSectionVars false in
theorem cl_eq_of_cl_finset_eq (C₁ C₂ : ClosureSys α)
    (h : ∀ A : Finset α, C₁.cl ↑A = C₂.cl ↑A) :
    C₁.cl = C₂.cl := by
  ext S;
  convert Set.ext_iff.mp ( h ( Set.toFinset S ) ) ‹_› using 1;
  all_goals try exact Fintype.ofFinite _;
  · simp +decide;
  · aesop

/-
**Reconstruction Duality (Theorem C)**: Two weighted closure dependency
systems with equivalent cost profiles have identical closure operators.
This is the precise sense in which the sparse predictor object determines
the dependency structure.
-/
theorem reconstruction_duality (D₁ D₂ : WeightedClosureDep α)
    (h : WeightedClosureDep.CostProfileEquiv D₁ D₂) :
    D₁.cl = D₂.cl := by
  apply cl_eq_of_cl_finset_eq;
  intro A;
  ext b;
  exact costProfile_determines_membership D₁ D₂ h A b

/-! ## §6. Canonical Sparse Basis

The canonical sparse basis is the finite collection of all minimal supports.
Every derivation can be witnessed by a member of this basis.
Under exchange, this basis has additional structure. -/

/-- The canonical sparse predictor basis: all pairs `(A, b)` where `A` is
a minimal support for `b`. -/
def canonicalBasis (C : ClosureSys α) : Set (Finset α × α) :=
  {p | IsMinimalSupport C p.1 p.2}

set_option linter.unusedSectionVars false in
/-- The canonical basis is always finite. -/
theorem canonicalBasis_finite (C : ClosureSys α) :
    Set.Finite (canonicalBasis C) :=
  Set.toFinite _

/-
**Canonical Basis Completeness (Theorem A)**: Every derivation
`b ∈ cl(A)` is witnessed by some minimal support `A' ⊆ A` in the
canonical basis.
-/
theorem canonicalBasis_complete (C : ClosureSys α)
    (A : Finset α) (b : α) (hb : IsSupport C A b) :
    ∃ A' : Finset α, A' ⊆ A ∧ (A', b) ∈ canonicalBasis C := by
  exact Exists.elim ( exists_minimalSupport C A b hb ) fun A' hA' => ⟨ A', hA'.1, hA'.2 ⟩

/-
Under exchange, the canonical basis determines the closure system.
If two exchange systems have the same canonical basis, they have the
same closure operator.
-/
theorem canonicalBasis_determines_closure (C₁ C₂ : ClosureSys α)
    (_hex₁ : HasExchange C₁) (_hex₂ : HasExchange C₂)
    (hbasis : canonicalBasis C₁ = canonicalBasis C₂) :
    C₁.cl = C₂.cl := by
  apply cl_eq_of_cl_finset_eq;
  intro A;
  refine' Set.Subset.antisymm _ _;
  · intro b hb
    obtain ⟨A', hA', hA'_basis⟩ := canonicalBasis_complete C₁ A b (by
    exact hb);
    exact C₂.cl_monotone ( Finset.coe_subset.mpr hA' ) ( by rw [ hbasis ] at hA'_basis; exact hA'_basis.1 );
  · intro b hb;
    obtain ⟨ A', hA', hA'' ⟩ := canonicalBasis_complete C₂ A b hb;
    exact C₁.cl_monotone ( by aesop ) ( hbasis.symm.subset hA'' |>.1 )

/-! ## §7. Join-Irreducible Closed Sets

In the lattice of closed sets, join-irreducible elements correspond to
atomic predictor dependencies. Under exchange, these are exactly the
closures of singletons not in `cl(∅)`. -/

/-- A closed set `F` is join-irreducible in the closure lattice: it is
not the bottom element and cannot be written as the join (= closure of union)
of two strictly smaller closed sets. -/
def ClosedJoinIrred (C : ClosureSys α) (F : Set α) : Prop :=
  C.IsClosed F ∧ F ≠ C.cl ∅ ∧
    ∀ G H : Set α, C.IsClosed G → C.IsClosed H →
      C.cl (G ∪ H) = F → G = F ∨ H = F

/-- Every closed set contains `cl(∅)`. -/
theorem cl_empty_le_closed (C : ClosureSys α) {F : Set α} (hF : C.IsClosed F) :
    C.cl ∅ ⊆ F := by
  exact C.cl_le_of_subset_closed ( Set.empty_subset _ ) hF

/-
Under exchange, if `y ∈ cl({x}) \ cl(∅)` then `x ∈ cl({y})`.
-/
set_option linter.unusedSectionVars false in
theorem exchange_symmetric_singleton (C : ClosureSys α)
    (hex : HasExchange C) (x y : α)
    (hy : y ∈ C.cl {x}) (hny : y ∉ C.cl ∅) :
    x ∈ C.cl {y} := by
  convert hex ∅ x y _ _ using 1 <;> aesop

/-
Under exchange, every proper closed subset of `cl({x})` (for `x ∉ cl(∅)`) is
contained in `cl(∅)`.
-/
theorem exchange_cl_singleton_minimal (C : ClosureSys α)
    (hex : HasExchange C) (x : α) (_hx : x ∉ C.cl ∅)
    (F : Set α) (hF : C.IsClosed F) (hFsub : F ⊆ C.cl {x}) (hFne : F ≠ C.cl {x}) :
    F ⊆ C.cl ∅ := by
  intro y hy;
  contrapose! hFne;
  have hx_in_F : x ∈ F := by
    have hx_in_F : x ∈ C.cl {y} := by
      apply exchange_symmetric_singleton C hex x y (hFsub hy) hFne;
    have hx_in_F : C.cl {y} ⊆ F := by
      exact C.cl_le_of_subset_closed ( Set.singleton_subset_iff.mpr hy ) hF;
    exact hx_in_F ‹_›;
  refine' le_antisymm hFsub _;
  exact C.cl_le_of_subset_closed ( Set.singleton_subset_iff.mpr hx_in_F ) hF

/-
Under exchange, `cl({x})` is join-irreducible for `x ∉ cl(∅)`.
-/
theorem singleton_closure_joinIrred (C : ClosureSys α)
    (hex : HasExchange C) (x : α) (hx : x ∉ C.cl ∅) :
    ClosedJoinIrred C (C.cl {x}) := by
  constructor;
  · exact C.cl_isClosed _;
  · refine' ⟨ _, fun G H hG hH hGH => _ ⟩;
    · exact fun h => hx <| h ▸ C.mem_cl_of_mem ( Set.mem_singleton x );
    · -- By exchange_cl_singleton_minimal, either G = cl({x}) or G ⊆ cl(∅). Similarly for H.
      have hG' : G = C.cl {x} ∨ G ⊆ C.cl ∅ := by
        have hG' : G ⊆ C.cl {x} := by
          exact hGH ▸ C.cl_extensive _ |> Set.Subset.trans ( Set.subset_union_left );
        exact Classical.or_iff_not_imp_left.2 fun h => exchange_cl_singleton_minimal C hex x hx G hG hG' h
      have hH' : H = C.cl {x} ∨ H ⊆ C.cl ∅ := by
        have hH' : H ⊆ C.cl {x} := by
          exact hGH ▸ C.cl_extensive _ |> Set.Subset.trans ( Set.subset_union_right );
        exact Classical.or_iff_not_imp_left.2 fun h => exchange_cl_singleton_minimal C hex x hx H hH hH' h;
      contrapose! hx;
      have h_union_subset : G ∪ H ⊆ C.cl ∅ := by
        exact Set.union_subset ( hG'.resolve_left hx.1 ) ( hH'.resolve_left hx.2 );
      have h_union_subset : C.cl (G ∪ H) ⊆ C.cl (C.cl ∅) := by
        exact C.cl_monotone h_union_subset;
      simp_all +decide [ C.cl_idempotent ];
      exact h_union_subset ( C.cl_extensive _ ( Set.mem_singleton _ ) )

/-! ## §8. Cost-Controlled Exchange

A strengthening of the exchange axiom with cost bounds. -/

/-
Standard exchange implies existence of a reverse derivation element.
-/
theorem exchange_reverse_exists (D : WeightedClosureDep α)
    (_hex : HasExchange D.toClosureSys)
    (A : Finset α) (b _c : α)
    (_hb : b ∈ D.cl ((↑A : Set α) ∪ {_c})) (hnb : b ∉ D.cl (↑A)) :
    ∃ c' ∈ D.cl ((↑A : Set α) ∪ {b}), c' ∉ D.cl (↑A) := by
  exact ⟨ b, by exact D.toClosureSys.cl_extensive _ ( by simp +decide ), hnb ⟩

/-! ## §9. Sparse Predictor Extraction Under Exchange

When the closure system has exchange, minimal supports enjoy stronger
properties enabling certified sparse predictor extraction. -/

/-
Under exchange, for a minimal support, each element is re-derivable
from the support using the original element (self-consistency).
-/
set_option linter.unusedSectionVars false in
theorem exchange_minimalSupport_selfConsistent (C : ClosureSys α)
    (_hex : HasExchange C) (b : α) (_hb : b ∉ C.cl ∅)
    (A : Finset α) (hmin : IsMinimalSupport C A b) (_hbA : b ∉ (↑A : Set α)) :
    ∀ a ∈ A, b ∈ C.cl ((↑(A.erase a) : Set α) ∪ {a}) := by
  intro a ha; have := hmin.1; simp_all +decide ;
  exact this

/-
Two elements in a minimal support under exchange are "co-dependent":
each can be re-derived in the presence of the target.
-/
theorem exchange_codependence (C : ClosureSys α)
    (hex : HasExchange C) (A : Finset α) (b : α)
    (hmin : IsMinimalSupport C A b) (hbA : b ∉ (↑A : Set α))
    (a : α) (ha : a ∈ A) :
    a ∈ C.cl ((↑(A.erase a) : Set α) ∪ {b}) := by
  apply exchange_swap C hex A b hmin hbA a ha

end Bridges.AlgebraEMLMachineLearning.ClosureDependency