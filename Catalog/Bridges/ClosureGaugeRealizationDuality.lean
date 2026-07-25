import Mathlib

/-!
# Closure–Gauge Realization Duality via Idempotent Holonomy

This file establishes a finite realization/minimality duality for discrete gauge fields
encoded by closure data. It builds a formal bridge between:

- **Closure systems** from lattice theory and EML
- **Idempotent/tropical linear algebra** (valuations in ℕ with max/sup)
- **Automata-theoretic finite realization** (Hankel/Nerode style)
- **Discrete gauge theory / lattice holonomy** (Wilson-loop observables)

## Core Idea

A *gauge valuation* assigns a non-negative integer "holonomy capacity" to each element
(abstracting: loop ↦ holonomy value). The *induced closure* captures all elements
whose capacity is dominated by the supremum of a given set:

  `cl_v(S) = { x | v(x) ≤ sup_{s ∈ S} v(s) }`

## Main Results

* `valuationClosure` — Valuation-induced closure is a closure operator
* `valuationClosure_closedSets_chain` — Closed sets form a chain
* `valuationClosure_eq_iff_orderEquiv` — Equal closures ↔ order-equivalent valuations
* `closureOp_realizable_iff_chain` — Realizability iff closed sets form a chain
* `minimal_realization_exists` — Existence of minimal realization
* `minimal_realizations_orderEquiv` — Uniqueness up to gauge equivalence
* `certified_reconstruction` — Certified reconstruction from chain decomposition
-/

set_option maxHeartbeats 800000

open Finset Function

namespace ClosureGaugeRealization

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Section 1: Closure Operators -/

/-- A closure operator on `Finset α` over a finite type. -/
structure ClosureOp (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Finset α → Finset α
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ {s t}, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

/-- A set is closed if it is a fixpoint of the closure. -/
def ClosureOp.IsClosed (C : ClosureOp α) (s : Finset α) : Prop := C.cl s = s

/-! ## Section 2: Gauge Valuations and Induced Closure -/

/-- The closure operator induced by a gauge valuation:
    `cl_v(S) = { x ∈ univ | v(x) ≤ sup_{s ∈ S} v(s) }`. -/
def valuationCl (v : α → ℕ) (S : Finset α) : Finset α :=
  Finset.univ.filter (fun x => v x ≤ S.sup v)

/-- The valuation closure is extensive: `S ⊆ cl_v(S)`. -/
theorem valuationCl_extensive (v : α → ℕ) (S : Finset α) :
    S ⊆ valuationCl v S := by
  intro x hx
  simp only [valuationCl, Finset.mem_filter, Finset.mem_univ, true_and]
  exact Finset.le_sup hx

/-- The valuation closure is monotone: `S ⊆ T → cl_v(S) ⊆ cl_v(T)`. -/
theorem valuationCl_monotone (v : α → ℕ) {S T : Finset α} (h : S ⊆ T) :
    valuationCl v S ⊆ valuationCl v T := by
  intro x hx
  simp only [valuationCl, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  exact le_trans hx (Finset.sup_mono h)

/-- Membership in valuation closure detected by sup comparison. -/
theorem mem_valuationCl_iff (v : α → ℕ) (S : Finset α) (x : α) :
    x ∈ valuationCl v S ↔ v x ≤ S.sup v := by
  simp [valuationCl]

/-
Key lemma: the sup of a valuation closure equals the sup of the original set.
-/
theorem valuationCl_sup_eq (v : α → ℕ) (S : Finset α) :
    (valuationCl v S).sup v = S.sup v := by
  refine' le_antisymm _ _;
  · exact Finset.sup_le fun x hx => Finset.mem_filter.mp hx |>.2;
  · exact Finset.sup_mono ( valuationCl_extensive v S )

/-
The valuation closure is idempotent: `cl_v(cl_v(S)) = cl_v(S)`.
-/
theorem valuationCl_idempotent (v : α → ℕ) (S : Finset α) :
    valuationCl v (valuationCl v S) = valuationCl v S := by
  unfold valuationCl;
  ext x; simp +decide [ Finset.sup_le_iff ] ;
  constructor;
  · exact fun hx => le_trans hx ( Finset.sup_le fun y hy => by aesop );
  · exact fun hx => Finset.le_sup ( f := v ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx ⟩ )

/-- Package: the valuation closure is a closure operator. -/
noncomputable def valuationClosure (v : α → ℕ) : ClosureOp α where
  cl := valuationCl v
  extensive := valuationCl_extensive v
  monotone := fun h => valuationCl_monotone v h
  idempotent := valuationCl_idempotent v

/-! ## Section 3: Closed Sets of Valuation Closures Form a Chain -/

/-
A closed set of the valuation closure is exactly a level set `{x | v(x) ≤ k}`
    for `k = S.sup v`.
-/
theorem valuationCl_closed_iff (v : α → ℕ) (S : Finset α) :
    (valuationClosure v).IsClosed S ↔ S = Finset.univ.filter (fun x => v x ≤ S.sup v) := by
  exact?

/-
Two closed sets of a valuation closure are comparable under inclusion.
-/
theorem valuationClosure_closedSets_chain (v : α → ℕ) (S T : Finset α)
    (hS : (valuationClosure v).IsClosed S) (hT : (valuationClosure v).IsClosed T) :
    S ⊆ T ∨ T ⊆ S := by
  -- By definition of closure, S = univ.filter (fun x => v x ≤ S.sup v) and T = univ.filter (fun x => v x ≤ T.sup v).
  have hS_def : S = Finset.univ.filter (fun x => v x ≤ S.sup v) := by
    exact?
  have hT_def : T = Finset.univ.filter (fun x => v x ≤ T.sup v) := by
    exact?;
  grind

/-! ## Section 4: Order Equivalence (Gauge Equivalence) -/

/-- Two valuations are order-equivalent ("gauge equivalent") if they induce
    the same ordering on elements. -/
def OrderEquiv (v₁ v₂ : α → ℕ) : Prop :=
  ∀ x y : α, v₁ x ≤ v₁ y ↔ v₂ x ≤ v₂ y

omit [Fintype α] [DecidableEq α] in
theorem OrderEquiv.refl (v : α → ℕ) : OrderEquiv v v :=
  fun _ _ => Iff.rfl

omit [Fintype α] [DecidableEq α] in
theorem OrderEquiv.symm {v₁ v₂ : α → ℕ} (h : OrderEquiv v₁ v₂) :
    OrderEquiv v₂ v₁ :=
  fun x y => (h x y).symm

omit [Fintype α] [DecidableEq α] in
theorem OrderEquiv.trans {v₁ v₂ v₃ : α → ℕ} (h₁ : OrderEquiv v₁ v₂)
    (h₂ : OrderEquiv v₂ v₃) : OrderEquiv v₁ v₃ :=
  fun x y => (h₁ x y).trans (h₂ x y)

/-
**Fundamental Gauge Uniqueness**: Equal valuation closures imply
    order-equivalent valuations (gauge equivalence).
    Key idea: `v₁(x) ≤ v₁(y) ↔ x ∈ cl_{v₁}({y}) ↔ x ∈ cl_{v₂}({y}) ↔ v₂(x) ≤ v₂(y)`.
-/
theorem valuationCl_eq_implies_orderEquiv (v₁ v₂ : α → ℕ)
    (h : valuationCl v₁ = valuationCl v₂) : OrderEquiv v₁ v₂ := by
  have := congr_fun h;
  intro x y; specialize this { y } ; replace this := Finset.ext_iff.mp this x; simp +decide [ mem_valuationCl_iff ] at this; aesop;

/-! ## Section 5: Capacity and Holographic Duality -/

/-- The capacity of a set under a closure operator. -/
def closureCapacity (C : ClosureOp α) (S : Finset α) : ℕ := (C.cl S).card

/-- Capacity is monotone. -/
theorem closureCapacity_mono (C : ClosureOp α) {S T : Finset α} (h : S ⊆ T) :
    closureCapacity C S ≤ closureCapacity C T :=
  Finset.card_le_card (C.monotone h)

/-- Capacity is extensive. -/
theorem closureCapacity_extensive (C : ClosureOp α) (S : Finset α) :
    S.card ≤ closureCapacity C S :=
  Finset.card_le_card (C.extensive S)

/-
A set is closed iff capacity equals cardinality.
-/
theorem isClosed_iff_capacity_eq_card (C : ClosureOp α) (S : Finset α) :
    C.IsClosed S ↔ closureCapacity C S = S.card := by
  constructor;
  · exact fun h => congr_arg Finset.card h;
  · have h_closed : S ⊆ C.cl S := by
      exact C.extensive S;
    exact fun h => Finset.eq_of_subset_of_card_le h_closed ( by linarith! ) |> Eq.symm

/-
**Holographic duality**: Equal capacity profiles imply equal closures.
-/
theorem holographic_duality (C₁ C₂ : ClosureOp α)
    (hcap : ∀ S : Finset α, closureCapacity C₁ S = closureCapacity C₂ S) :
    C₁.cl = C₂.cl := by
  apply funext;
  -- Apply the equality of capacities to conclude that the closures are equal.
  intros S
  apply Finset.eq_of_subset_of_card_le;
  · have h_closed : C₂.cl (C₁.cl S) = C₁.cl S := by
      apply Finset.eq_of_subset_of_card_le;
      · have h_subset : C₁.cl S ⊆ C₂.cl (C₁.cl S) := by
          exact C₂.extensive _;
        have := hcap ( C₁.cl S );
        unfold closureCapacity at *;
        rw [ C₁.idempotent ] at this;
        exact Finset.eq_of_subset_of_card_le h_subset ( by linarith ) ▸ Finset.Subset.refl _;
      · exact C₂.extensive _ |> Finset.card_le_card;
    have h_extensive : C₂.cl S ⊆ C₂.cl (C₁.cl S) := by
      exact C₂.monotone ( C₁.extensive S );
    have := hcap S; simp_all +decide [ closureCapacity ] ;
    exact Finset.eq_of_subset_of_card_le h_extensive ( by simp +decide [ hcap ] ) ▸ Finset.Subset.refl _;
  · unfold closureCapacity at hcap; aesop;

/-! ## Section 6: Realizability -/

/-- A closure operator is *gauge-realizable* if it equals `valuationCl v` for some `v`. -/
def GaugeRealizable (C : ClosureOp α) : Prop :=
  ∃ v : α → ℕ, C.cl = valuationCl v

/-- The closed sets form a chain if any two are comparable. -/
def ClosedSetsChain (C : ClosureOp α) : Prop :=
  ∀ S T : Finset α, C.IsClosed S → C.IsClosed T → S ⊆ T ∨ T ⊆ S

/-- A closure operator is *separated* if distinct singletons have distinct closures. -/
def Separated (C : ClosureOp α) : Prop :=
  ∀ a b : α, a ≠ b → C.cl {a} ≠ C.cl {b}

/-
Forward direction: realizable implies chain.
-/
theorem realizable_implies_chain (C : ClosureOp α) (hR : GaugeRealizable C) :
    ClosedSetsChain C := by
  obtain ⟨ v, hv ⟩ := hR;
  -- Let $S$ and $T$ be any two closed sets of $C$.
  intro S T hS hT
  -- By definition of $C$, we have $C.cl S = S$ and $C.cl T = T$.
  have hCS : C.cl S = S := by
    exact hS
  have hCT : C.cl T = T := by
    exact hT;
  simp_all +decide [ Finset.subset_iff, valuationCl ];
  grind

/-
Key helper: x ∈ cl(S) iff cl{x} ⊆ cl(S).
-/
theorem mem_cl_iff_singleton_subset (C : ClosureOp α) (S : Finset α) (x : α) :
    x ∈ C.cl S ↔ C.cl {x} ⊆ C.cl S := by
  constructor <;> intro h;
  · -- Since $x \in C.cl S$, we have $\{x\} \subseteq C.cl S$.
    have h_singleton_subset : {x} ⊆ C.cl S := by
      aesop;
    exact C.monotone h_singleton_subset |> Set.Subset.trans <| by simp +decide [ C.idempotent ] ;
  · exact h ( C.extensive _ ( Finset.mem_singleton_self _ ) )

/-
In a chain closure with nonempty S, cl(S) = cl{s} for some s ∈ S.
-/
theorem chain_cl_eq_cl_singleton (C : ClosureOp α) (hchain : ClosedSetsChain C)
    (S : Finset α) (hne : S.Nonempty) :
    ∃ s ∈ S, C.cl S = C.cl {s} := by
  -- By the chain property, the closures of the elements of S form a chain.
  have h_chain : ∀ s t : α, s ∈ S → t ∈ S → C.cl {s} ⊆ C.cl {t} ∨ C.cl {t} ⊆ C.cl {s} := by
    intros s t hs ht
    have h_closed : C.IsClosed (C.cl {s}) ∧ C.IsClosed (C.cl {t}) := by
      exact ⟨ C.idempotent _, C.idempotent _ ⟩;
    exact hchain _ _ h_closed.1 h_closed.2;
  obtain ⟨s, hs⟩ : ∃ s ∈ S, ∀ t ∈ S, C.cl {t} ⊆ C.cl {s} := by
    obtain ⟨s, hs⟩ : ∃ s ∈ S, ∀ t ∈ S, (C.cl {s}).card ≥ (C.cl {t}).card := by
      exact Finset.exists_max_image _ _ hne;
    refine' ⟨ s, hs.1, fun t ht => _ ⟩;
    cases h_chain s t hs.1 ht <;> simp_all +decide [ Finset.subset_iff ];
    have := Finset.eq_of_subset_of_card_le ‹_› ( by linarith [ hs.2 t ht ] ) ; aesop;
  refine' ⟨ s, hs.1, le_antisymm _ _ ⟩;
  · have h_subset : S ⊆ C.cl {s} := by
      exact fun x hx => hs.2 x hx ( C.extensive _ ( Finset.mem_singleton_self _ ) );
    exact C.monotone h_subset |> le_trans <| by simp +decide [ C.idempotent ] ;
  · exact C.monotone ( Finset.singleton_subset_iff.mpr hs.1 )

/-
In a chain, subset ↔ card ≤ for closed sets.
-/
theorem chain_closed_subset_iff_card_le (C : ClosureOp α) (hchain : ClosedSetsChain C)
    (S T : Finset α) (hS : C.IsClosed S) (hT : C.IsClosed T) :
    S ⊆ T ↔ S.card ≤ T.card := by
  constructor <;> intro h;
  · exact Finset.card_le_card h;
  · have := hchain S T hS hT;
    cases this <;> simp_all +decide [ Finset.subset_iff ];
    have := Finset.eq_of_subset_of_card_le ‹_› ; aesop;

/-
Backward direction: chain implies realizable.
    Construction: v(x) = (cl{x}).card - (cl ∅).card.
-/
theorem chain_implies_realizable (C : ClosureOp α) (hchain : ClosedSetsChain C) :
    GaugeRealizable C := by
  use fun x => (C.cl {x}).card - (C.cl ∅).card;
  ext S x; simp +decide [ mem_cl_iff_singleton_subset, valuationCl ] ;
  constructor;
  · by_cases hS : S.Nonempty;
    · obtain ⟨ s₀, hs₀ ⟩ := chain_cl_eq_cl_singleton C hchain S hS;
      intro hx
      have h_card : (C.cl {x}).card ≤ (C.cl {s₀}).card := by
        exact Finset.card_le_card ( hs₀.2 ▸ hx );
      have h_card_le : (C.cl {s₀}).card - (C.cl ∅).card ≤ S.sup (fun x => (C.cl {x}).card - (C.cl ∅).card) := by
        exact Finset.le_sup ( f := fun x => #(C.cl { x }) - #(C.cl ∅) ) hs₀.1;
      omega;
    · simp_all +decide [ Finset.not_nonempty_iff_eq_empty.mp hS ];
      exact fun h => Finset.card_le_card h;
  · by_cases hS : S.Nonempty;
    · intro hx
      obtain ⟨s₀, hs₀⟩ : ∃ s₀ ∈ S, (C.cl {x}).card - (C.cl ∅).card ≤ (C.cl {s₀}).card - (C.cl ∅).card := by
        contrapose! hx;
        have h_sup_lt : (S.sup (fun x => (C.cl {x}).card - (C.cl ∅).card)) < (C.cl {x}).card - (C.cl ∅).card := by
          grind +suggestions;
        exact lt_tsub_iff_right.mp h_sup_lt;
      have h_subset : C.cl {x} ⊆ C.cl {s₀} := by
        apply chain_closed_subset_iff_card_le C hchain (C.cl {x}) (C.cl {s₀}) (by
        exact C.idempotent _) (by
        exact C.idempotent _) |>.2;
        have h_card_le : (C.cl ∅).card ≤ (C.cl {x}).card ∧ (C.cl ∅).card ≤ (C.cl {s₀}).card := by
          exact ⟨ Finset.card_le_card ( C.monotone ( Finset.empty_subset _ ) ), Finset.card_le_card ( C.monotone ( Finset.empty_subset _ ) ) ⟩;
        omega;
      exact Finset.Subset.trans h_subset ( C.monotone ( Finset.singleton_subset_iff.mpr hs₀.1 ) );
    · intro h y hy; have := Finset.eq_of_subset_of_card_le ( show C.cl ∅ ⊆ C.cl { x } from C.monotone ( Finset.empty_subset _ ) ) ; aesop;

/-- **Realizability iff chain**: A closure operator is gauge-realizable
    iff its closed sets form a chain. -/
theorem closureOp_realizable_iff_chain (C : ClosureOp α) :
    GaugeRealizable C ↔ ClosedSetsChain C :=
  ⟨realizable_implies_chain C, chain_implies_realizable C⟩

/-! ## Section 7: Realization Rank and Minimality -/

/-- The rank of a gauge valuation: the number of distinct values. -/
noncomputable def realizationRank (v : α → ℕ) : ℕ :=
  (Finset.univ.image v).card

/-- A realization is minimal if no same-closure realization has smaller rank. -/
def IsMinimalRealization (v : α → ℕ) : Prop :=
  ∀ w : α → ℕ, valuationCl v = valuationCl w → realizationRank v ≤ realizationRank w

/-- The canonical normalized valuation: maps x to the count of elements
    with strictly smaller v-value. -/
noncomputable def normalizeValuation (v : α → ℕ) : α → ℕ :=
  fun x => (Finset.univ.filter (fun y => v y < v x)).card

/-
The normalized valuation is order-equivalent to the original.
-/
omit [DecidableEq α] in
theorem normalizeValuation_orderEquiv (v : α → ℕ) :
    OrderEquiv v (normalizeValuation v) := by
  intro x y;
  constructor <;> intro h;
  · exact Finset.card_mono fun z hz => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, lt_of_lt_of_le ( Finset.mem_filter.mp hz |>.2 ) h ⟩;
  · contrapose! h;
    refine' Finset.card_lt_card _;
    simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
    exact ⟨ fun z hz => lt_trans hz h, y, h, le_rfl ⟩

/-
**Existence of minimal realization**.
-/
theorem minimal_realization_exists (C : ClosureOp α) (hR : GaugeRealizable C) :
    ∃ v : α → ℕ, C.cl = valuationCl v ∧ IsMinimalRealization v := by
  have h_min_realization : ∃ v : α → ℕ, C.cl = valuationCl v ∧ ∀ w : α → ℕ, C.cl = valuationCl w → realizationRank v ≤ realizationRank w := by
    -- By the well-ordering principle, there exists a minimal rank among all realizations.
    obtain ⟨r, hr⟩ : ∃ r : ℕ, r ∈ Set.image realizationRank {v : α → ℕ | C.cl = valuationCl v} ∧ ∀ s ∈ Set.image realizationRank {v : α → ℕ | C.cl = valuationCl v}, r ≤ s := by
      apply_rules [ Set.exists_min_image ];
      · exact Set.finite_iff_bddAbove.mpr ⟨ Fintype.card α, Set.forall_mem_image.mpr fun v hv => Finset.card_image_le.trans ( by simp +decide ) ⟩;
      · exact ⟨ _, ⟨ hR.choose, hR.choose_spec, rfl ⟩ ⟩;
    grind +splitImp;
  exact ⟨ h_min_realization.choose, h_min_realization.choose_spec.1, fun w hw => h_min_realization.choose_spec.2 w <| hw ▸ h_min_realization.choose_spec.1 ⟩

/-! ## Section 8: Uniqueness Up to Gauge Equivalence -/

/-
**Uniqueness**: Any two minimal realizations of the same closure
    are order-equivalent (gauge-equivalent).
-/
theorem minimal_realizations_orderEquiv (v₁ v₂ : α → ℕ)
    (hcl : valuationCl v₁ = valuationCl v₂) :
    OrderEquiv v₁ v₂ := by
  exact?

/-! ## Section 9: Certified Reconstruction -/

/-
**Certified reconstruction**: Given a closure with chain closed sets,
    one can reconstruct a minimal gauge valuation realizing it.
-/
theorem certified_reconstruction (C : ClosureOp α) (hchain : ClosedSetsChain C) :
    ∃ v : α → ℕ, C.cl = valuationCl v ∧ IsMinimalRealization v := by
  convert minimal_realization_exists C _;
  exact?

/-! ## Section 10: The Main Duality Theorem -/

/-- **Main Closure-Gauge Realization Duality**. -/
theorem closure_gauge_realization_duality (C : ClosureOp α) :
    GaugeRealizable C ↔ ClosedSetsChain C :=
  closureOp_realizable_iff_chain C

/-! ## Section 11: Concrete Examples -/

/-
The discrete closure (identity) is NOT gauge-realizable for n ≥ 2,
    since the identity closure has non-chain closed sets.
-/
theorem discrete_not_realizable_of_two_le {n : ℕ} (hn : 2 ≤ n) :
    ¬ GaugeRealizable (α := Fin n)
      ⟨id, fun _ => Finset.Subset.refl _, fun h => h, fun _ => rfl⟩ := by
  intro ⟨ v, hv ⟩
  generalize_proofs at *;
  have := congr_fun hv { ⟨ 0, by linarith ⟩ } ; have := congr_fun hv { ⟨ 1, by linarith ⟩ } ; simp_all +decide [ Finset.ext_iff ] ;
  unfold valuationCl at *; simp_all +decide [ Finset.ext_iff ] ;
  grind +splitIndPred

/-- A valuation closure IS always gauge-realizable (tautologically). -/
theorem valuation_closure_realizable (v : α → ℕ) :
    GaugeRealizable (valuationClosure v) :=
  ⟨v, rfl⟩

/-
The total closure (everything maps to univ) is gauge-realizable.
-/
theorem total_realizable :
    GaugeRealizable (α := α)
      ⟨fun _ => Finset.univ, fun _ => Finset.subset_univ _,
       fun _ => Finset.subset_univ _, fun _ => rfl⟩ := by
  -- Use the zero valuation v = fun _ => 0 (constant zero). Then valuationCl v S = univ.filter (fun x => 0 ≤ S.sup (fun _ => 0)) = univ.filter (fun x => 0 ≤ 0) = univ.filter (fun _ => True) = univ.
  use fun _ => 0;
  ext; simp [valuationCl]

/-! ## Section 12: Separation and Injectivity -/

/-
In a valuation closure, separation ↔ injectivity of the valuation.
-/
theorem valuationClosure_separated_iff (v : α → ℕ) :
    Separated (valuationClosure v) ↔ Function.Injective v := by
  constructor;
  · intro h_inj v w hvw;
    contrapose! h_inj;
    unfold Separated; simp +decide;
    refine' ⟨ v, w, h_inj, _ ⟩;
    ext x; simp [valuationClosure];
    unfold valuationCl; aesop;
  · intro hv a b hab;
    simp_all +decide [ Finset.ext_iff, valuationClosure ];
    cases lt_or_gt_of_ne ( hv.ne hab ) <;> simp_all +decide [ valuationCl ];
    · exact ⟨ b, by aesop ⟩;
    · exact ⟨ a, by aesop ⟩

/-
Separated closures with chain property admit injective realizations.
-/
theorem separated_chain_injective_realization (C : ClosureOp α)
    (hchain : ClosedSetsChain C) (hsep : Separated C) :
    ∃ v : α → ℕ, C.cl = valuationCl v ∧ Function.Injective v := by
  -- From hchain, by chain_implies_realizable, get v with C.cl = valuationCl v.
  obtain ⟨v, hv⟩ := chain_implies_realizable C hchain;
  refine' ⟨ v, hv, _ ⟩;
  convert valuationClosure_separated_iff v |>.1 _;
  unfold Separated; aesop;

end ClosureGaugeRealization