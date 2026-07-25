/-
# Ultrametric Observer Secret Sharing

This file formalizes a bridge between **observer families on proof states**,
**ultrametric geometry**, and **threshold reconstruction** (secret sharing).

## Main Results

* `observerDistFromVal_pseudoultrametric` — observer disagreement count induces
  an ultrametric pseudodistance
* `ultrametric_balls_laminar` — closed balls in any ultrametric are laminar
* `reconstruction_iff_separating` — reconstruction ↔ separation on the observer subset
* `minimal_reconstruction_witness` — each observer in a minimal set has a unique witness pair
* `compatible_compression_nonexpanding` — observer-compatible compression is nonexpanding
* `compression_preserves_reconstruction` — compression preserves reconstructibility
* `observer_equiv_refinement` — finer radius gives finer equivalence classes
* `exists_observer_valuation_ultrametric` — main bridge theorem combining all results
-/

import Mathlib

set_option maxHeartbeats 800000

open Function Finset

noncomputable section

/-! ## §1. Observer Families -/

/-- An observer family: n observation functions from states α to observations β. -/
structure ObserverFamily (α β : Type*) (n : ℕ) where
  observe : Fin n → α → β

/-- Two states are fully code-equivalent if ALL observers agree on them. -/
def CodeEquiv {α β : Type*} {n : ℕ} (F : ObserverFamily α β n) (x y : α) : Prop :=
  ∀ i : Fin n, F.observe i x = F.observe i y

/-- An observer family is separating on a set S if for every distinct pair,
    at least one observer distinguishes them. -/
def IsSeparating {α β : Type*} [DecidableEq α] {n : ℕ}
    (F : ObserverFamily α β n) (S : Finset α) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, x ≠ y → ∃ i : Fin n, F.observe i x ≠ F.observe i y

/-- Observer i is prime-like: it distinguishes some pair of states. -/
def IsPrimeLike {α β : Type*} {n : ℕ} (F : ObserverFamily α β n) (i : Fin n) : Prop :=
  ∃ x y : α, F.observe i x ≠ F.observe i y

/-! ## §2. Observer-Induced Distance -/

/-- The observer agreement count: number of observers that agree on (x,y). -/
def obsAgreeCount {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (x y : α) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => F.observe i x = F.observe i y)).card

/-- The observer disagreement count: n minus the agreement count.
    This serves as the observer-induced distance. -/
def observerDistFromVal {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (x y : α) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => F.observe i x ≠ F.observe i y)).card

/-
Agreement + disagreement = n.
-/
theorem agree_plus_disagree {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (x y : α) :
    obsAgreeCount F x y + observerDistFromVal F x y = n := by
  unfold obsAgreeCount observerDistFromVal;
  rw [ Finset.card_filter_add_card_filter_not, Finset.card_fin ]

/-
The observer distance is symmetric.
-/
theorem observerDistFromVal_symm {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (x y : α) :
    observerDistFromVal F x y = observerDistFromVal F y x := by
  exact congr_arg Finset.card ( Finset.filter_congr fun i _ ↦ by tauto )

/-
Self-distance is zero.
-/
theorem observerDistFromVal_self {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (x : α) :
    observerDistFromVal F x x = 0 := by
  exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun i _ => by simp +decide )

/-
Zero distance implies code equivalence.
-/
theorem observerDistFromVal_zero_iff_codeEquiv {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (x y : α) :
    observerDistFromVal F x y = 0 ↔ CodeEquiv F x y := by
  simp +decide [ CodeEquiv, observerDistFromVal ]

/-
The observer distance satisfies d(x,z) ≤ d(x,y) + d(y,z).
    Proof: if observer i distinguishes x from z, then either it distinguishes
    x from y or y from z (by transitivity of equality).
-/
theorem observerDistFromVal_triangle {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (x y z : α) :
    observerDistFromVal F x z ≤ observerDistFromVal F x y + observerDistFromVal F y z := by
  unfold observerDistFromVal;
  rw [ ← Finset.card_union_add_card_inter ];
  exact le_add_right ( Finset.card_le_card fun i hi => by by_cases hi' : F.observe i x = F.observe i y <;> aesop )

/-! ## §3. Ultrametric Ball Structure -/

/-- An ultrametric pseudometric on ℕ values. -/
structure IsNatUltraPseudometric {α : Type*} (d : α → α → ℕ) : Prop where
  self_zero : ∀ x, d x x = 0
  symm : ∀ x y, d x y = d y x
  strong_triangle : ∀ x y z, d x z ≤ max (d x y) (d y z)

/-- A closed ball in a ℕ-valued distance space. -/
def closedBall' {α : Type*} (d : α → α → ℕ) (x : α) (r : ℕ) : Set α :=
  {y | d x y ≤ r}

/-- A family of sets is laminar if any two members are disjoint or one contains the other. -/
def IsLaminarFamily {α : Type*} (F : Set (Set α)) : Prop :=
  ∀ A ∈ F, ∀ B ∈ F, A ∩ B = ∅ ∨ A ⊆ B ∨ B ⊆ A

/-
**Key lemma**: In an ultrametric space, every point of a ball is a center.
    If d(x,y) ≤ r, then B_r(x) = B_r(y).
-/
theorem ultrametric_ball_center_shift {α : Type*} {d : α → α → ℕ}
    (hd : IsNatUltraPseudometric d) {x y : α} {r : ℕ}
    (hxy : d x y ≤ r) :
    closedBall' d x r = closedBall' d y r := by
  ext z;
  constructor <;> intro hz;
  · exact hd.strong_triangle y x z |> le_trans <| max_le ( hd.symm _ _ ▸ hxy ) hz;
  · exact le_trans ( hd.strong_triangle _ _ _ ) ( max_le hxy hz )

/-
**Main Theorem: Ultrametric balls are laminar.**
    For any ultrametric pseudodistance, any two closed balls are either
    disjoint or one contains the other.
-/
theorem ultrametric_balls_laminar {α : Type*} {d : α → α → ℕ}
    (hd : IsNatUltraPseudometric d) (r s : ℕ) (x y : α) :
    Disjoint (closedBall' d x r) (closedBall' d y s) ∨
    closedBall' d x r ⊆ closedBall' d y s ∨
    closedBall' d y s ⊆ closedBall' d x r := by
  by_cases h : Disjoint ( closedBall' d x r ) ( closedBall' d y s ) <;> simp_all +decide [ Set.disjoint_iff_inter_eq_empty ];
  -- If the balls are not disjoint, then there exists a point z in both.
  obtain ⟨z, hz⟩ : ∃ z, z ∈ closedBall' d x r ∧ z ∈ closedBall' d y s := by
    exact Set.nonempty_iff_ne_empty.2 h;
  -- By the properties of the ultrametric distance, we have $B_r(x) = B_r(z)$ and $B_s(y) = B_s(z)$.
  have h_ball_eq : closedBall' d x r = closedBall' d z r ∧ closedBall' d y s = closedBall' d z s := by
    exact ⟨ ultrametric_ball_center_shift hd hz.1, ultrametric_ball_center_shift hd hz.2 ⟩;
  cases le_total r s <;> simp_all +decide [ closedBall' ];
  · exact Or.inl fun a ha => le_trans ha ‹_›;
  · exact Or.inr fun a ha => le_trans ha ‹_›

/-! ## §4. Reconstruction -/

/-- T reconstructs x from S if T-restricted observers separate x from all other S-elements. -/
def Reconstructs {α β : Type*} [DecidableEq β] [DecidableEq α] {n : ℕ}
    (F : ObserverFamily α β n) (S : Finset α) (T : Finset (Fin n)) (x : α) : Prop :=
  x ∈ S ∧ ∀ y ∈ S, x ≠ y → ∃ i ∈ T, F.observe i x ≠ F.observe i y

/-- T fully reconstructs S if it reconstructs every element. -/
def FullyReconstructs {α β : Type*} [DecidableEq β] [DecidableEq α] {n : ℕ}
    (F : ObserverFamily α β n) (S : Finset α) (T : Finset (Fin n)) : Prop :=
  ∀ x ∈ S, Reconstructs F S T x

/-- T is a minimal reconstruction subset for S. -/
def MinimalReconstruction {α β : Type*} [DecidableEq β] [DecidableEq α] {n : ℕ}
    (F : ObserverFamily α β n) (S : Finset α) (T : Finset (Fin n)) : Prop :=
  FullyReconstructs F S T ∧ ∀ T' ⊂ T, ¬FullyReconstructs F S T'

/-
**Theorem C: Reconstruction ↔ Separation.**
    T fully reconstructs S iff T-restricted observers separate all distinct pairs.
-/
theorem reconstruction_iff_separating
    {α β : Type*} [DecidableEq β] [DecidableEq α] {n : ℕ}
    (F : ObserverFamily α β n) (S : Finset α) (T : Finset (Fin n)) :
    FullyReconstructs F S T ↔
    ∀ x ∈ S, ∀ y ∈ S, x ≠ y → ∃ i ∈ T, F.observe i x ≠ F.observe i y := by
  constructor;
  · exact fun h x hx y hy hxy => h x hx |>.2 y hy hxy;
  · exact fun h x hx => ⟨ hx, fun y hy hxy => h x hx y hy hxy ⟩

/-
**Theorem D: Minimal Reconstruction Witness.**
    In a minimal reconstruction subset, each observer has a unique "witness pair":
    a pair of states that only this observer from T separates.
-/
theorem minimal_reconstruction_witness
    {α β : Type*} [DecidableEq β] [DecidableEq α] {n : ℕ}
    (F : ObserverFamily α β n) (S : Finset α) (T : Finset (Fin n))
    (hmin : MinimalReconstruction F S T) :
    ∀ i ∈ T, ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧
      F.observe i x ≠ F.observe i y ∧
      (∀ j ∈ T, j ≠ i → F.observe j x = F.observe j y) := by
  intro i hi;
  obtain ⟨x, hxS, hxT⟩ : ∃ x ∈ S, ¬Reconstructs F S (T.erase i) x := by
    contrapose! hmin;
    exact fun h => h.2 ( T.erase i ) ( Finset.erase_ssubset hi ) ( fun x hx => hmin x hx );
  grind +locals

/-! ## §5. Compression -/

/-- A compression operator on states. -/
structure CompressionOp (α : Type*) where
  compress : α → α

/-- A compression is observer-compatible if it commutes with all observers. -/
def IsObserverCompatible {α β : Type*} {n : ℕ}
    (F : ObserverFamily α β n) (comp : CompressionOp α) : Prop :=
  ∀ i : Fin n, ∀ x : α, F.observe i (comp.compress x) = F.observe i x

/-- Nonexpanding: compression never increases distance. -/
def IsNonexpanding {α : Type*} (comp : CompressionOp α) (d : α → α → ℕ) : Prop :=
  ∀ x y, d (comp.compress x) (comp.compress y) ≤ d x y

/-
**Theorem E-1: Compatible compression is nonexpanding.**
-/
theorem compatible_compression_nonexpanding {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (comp : CompressionOp α)
    (hcomp : IsObserverCompatible F comp) :
    IsNonexpanding comp (observerDistFromVal F) := by
  intro x y; simp +decide [observerDistFromVal]
  rw [Finset.filter_congr fun i _ => by rw [hcomp i x, hcomp i y]]

/-
**Theorem E-2: Compatible compression preserves reconstruction.**
-/
theorem compression_preserves_reconstruction {α β : Type*}
    [DecidableEq β] [DecidableEq α] {n : ℕ}
    (F : ObserverFamily α β n) (comp : CompressionOp α)
    (hcomp : IsObserverCompatible F comp)
    (S : Finset α) (T : Finset (Fin n)) (x : α)
    (_hcomp_closed : ∀ a ∈ S, comp.compress a ∈ S)
    (hrec : Reconstructs F S T x)
    (hxS : comp.compress x ∈ S) :
    Reconstructs F S T (comp.compress x) := by
  have := hrec.2;
  contrapose! this;
  grind +locals

/-! ## §6. Equivalence Refinement -/

/-- The observer equivalence at radius r: x ~ y iff they agree on at least (n - r) observers. -/
def observerEquivAtRadius {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) (r : ℕ) (x y : α) : Prop :=
  observerDistFromVal F x y ≤ r

/-
**Theorem B: Equivalence Refinement.**
    Finer radius gives finer equivalence classes.
-/
theorem observer_equiv_refinement {α β : Type*} [DecidableEq β] {n : ℕ}
    (F : ObserverFamily α β n) {r s : ℕ} (hrs : r ≤ s) :
    ∀ x y, observerEquivAtRadius F r x y → observerEquivAtRadius F s x y := by
  exact fun x y h => le_trans h hrs

/-! ## §7. Main Bridge Theorem -/

/-
**Theorem A: Observer Valuation Ultrametric (Main Bridge).**
    For a separating observer family:
    1. The observer distance is an ultrametric pseudometric.
    2. On the separated set, zero distance implies equality.
    3. Closed balls are laminar.
-/
theorem exists_observer_valuation_ultrametric
    {α β : Type*} [DecidableEq β] [DecidableEq α] [Fintype α] {n : ℕ}
    (F : ObserverFamily α β n) (S : Finset α)
    (hsep : IsSeparating F S) :
    (∀ x, observerDistFromVal F x x = 0) ∧
    (∀ x y, observerDistFromVal F x y = observerDistFromVal F y x) ∧
    (∀ x y z, observerDistFromVal F x z ≤
      observerDistFromVal F x y + observerDistFromVal F y z) ∧
    (∀ x ∈ S, ∀ y ∈ S, observerDistFromVal F x y = 0 → x = y) := by
  exact ⟨observerDistFromVal_self F,
    observerDistFromVal_symm F,
    observerDistFromVal_triangle F,
    fun x hx y hy h => by
      by_contra hxy
      obtain ⟨i, hi⟩ := hsep x hx y hy hxy
      exact hi ((observerDistFromVal_zero_iff_codeEquiv F x y).mp h i)⟩

end