/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
theorem compactCapacity_set_nonempty (Λ : UCTropicalFunctional X) (K : Compacts X) :
    {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}.Nonempty :=
  ⟨Λ.toFun 0, 0, fun _ _ => le_refl _, rfl⟩

/-- The defining set for compactCapacity is bounded below. -/
theorem compactCapacity_bddBelow (_Λ : UCTropicalFunctional X) (_K : Compacts X) :
    BddBelow {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (_K : Set X), (0 : ℝ) ≤ f x) ∧ a = _Λ.toFun f} :=
  ⟨⊥, fun _ _ => bot_le⟩

/-- The capacity of `K` is at most `Λ(f)` for any `f` nonneg on `K`. -/
theorem compactCapacity_le_of_nonneg (Λ : UCTropicalFunctional X) (K : Compacts X)
    (f : C(X, ℝ)) (hf : ∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) :
    compactCapacity Λ K ≤ Λ.toFun f :=
  csInf_le (compactCapacity_bddBelow Λ K) ⟨f, hf, rfl⟩

/-
The capacity of the empty compact set is ⊥.
-/
theorem compactCapacity_empty (Λ : UCTropicalFunctional X) :
    compactCapacity Λ ⊥ = ⊥ := by
  have h_empty : ⨅ (n : ℕ), Λ.toFun (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
    convert Λ.map_const_neg_iInf;
  exact le_antisymm ( le_trans ( le_iInf fun n => csInf_le ⟨ ⊥, fun a ha => by rcases ha with ⟨ f, hf, rfl ⟩ ; exact bot_le ⟩ ⟨ _, by simp +decide, rfl ⟩ ) h_empty.le ) bot_le

/-- The capacity is monotone: if `K ⊆ L`, then `μ(K) ≤ μ(L)`. -/
theorem compactCapacity_mono (Λ : UCTropicalFunctional X) :
    Monotone (compactCapacity Λ) := by
  intro K L hKL
  apply sInf_le_sInf
  exact fun a ha => by obtain ⟨f, hf, rfl⟩ := ha; exact ⟨f, fun x hx => hf x (hKL hx), rfl⟩

/-
The capacity of any compact set is at most 0.
-/
theorem compactCapacity_le_zero (Λ : UCTropicalFunctional X) (K : Compacts X) :
    compactCapacity Λ K ≤ 0 := by
  -- By definition of compactCapacity, we know that compactCapacity Λ K ≤ Λ 0.
  apply compactCapacity_le_of_nonneg Λ K (0 : C(X, ℝ)) (by simp) |> le_trans <| by simp [Λ.normalized];

/-
The capacity of any compact set is not ⊤.
-/
theorem compactCapacity_ne_top (Λ : UCTropicalFunctional X) (K : Compacts X) :
    compactCapacity Λ K ≠ ⊤ := by
  exact ne_of_lt ( lt_of_le_of_lt ( compactCapacity_le_zero Λ K ) ( by simp +decide ) )

/-! ### Infimum on compact sets -/

/-- The infimum of `f` on a compact set `K` is a lower bound for `f` at any point of `K`. -/
theorem infOnCompact_le_eval (f : C(X, ℝ)) (K : Compacts X) {x : X}
    (hx : x ∈ (K : Set X)) :
    infOnCompact f K ≤ (f x : EReal) :=
  iInf₂_le x hx

/-! ### Union maxitivity -/

/-
Capacity is maxitive: `μ(K ⊔ L) = max(μ(K), μ(L))`.
-/
theorem compactCapacity_union (Λ : UCTropicalFunctional X) (K L : Compacts X) :
    compactCapacity Λ (K ⊔ L) = compactCapacity Λ K ⊔ compactCapacity Λ L := by
  refine' le_antisymm _ _;
  · refine' le_of_forall_gt_imp_ge_of_dense fun x hx => _;
    -- For any $x > \max(\mu(K), \mu(L))$, there exist functions $f$ and $g$ such that $f$ is nonneg on $K$, $g$ is nonneg on $L$, and $\Lambda(f) < x$ and $\Lambda(g) < x$.
    obtain ⟨f, hfK, hf⟩ : ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), 0 ≤ f x) ∧ Λ.toFun f < x := by
      have := exists_lt_of_csInf_lt ( compactCapacity_set_nonempty Λ K ) ( lt_of_le_of_lt ( le_max_left _ _ ) hx ) ; aesop;
    obtain ⟨g, hgL, hg⟩ : ∃ g : C(X, ℝ), (∀ x ∈ (L : Set X), 0 ≤ g x) ∧ Λ.toFun g < x := by
      contrapose! hx;
      exact le_max_of_le_right ( le_csInf ( compactCapacity_set_nonempty Λ L ) fun a ha => by aesop );
    -- Consider the function $h = f \⊔ g$. It is nonneg on $K \cup L$ and $\Lambda(h) = \Lambda(f \⊔ g) = \max(\Lambda(f), \Lambda(g)) < x$.
    set h : C(X, ℝ) := f ⊔ g
    have hhK : ∀ x ∈ (K ⊔ L : Set X), 0 ≤ h x := by
      aesop
    have hh : Λ.toFun h < x := by
      have hh : Λ.toFun h = max (Λ.toFun f) (Λ.toFun g) := by
        exact Λ.sup_preserving' f g;
      exact hh.symm ▸ max_lt hf hg;
    exact le_trans ( csInf_le ⟨ ⊥, by rintro a ⟨ f, hf, rfl ⟩ ; exact bot_le ⟩ ⟨ h, hhK, rfl ⟩ ) hh.le;
  · exact max_le ( compactCapacity_mono Λ ( le_sup_left ) ) ( compactCapacity_mono Λ ( le_sup_right ) )

/-! ### Representation inequality -/

/-
One direction of Choquet–Radon: for every compact `K`,
    `μ(K) + inf_K f ≤ Λ(f)`.
-/
theorem compactCapacity_add_infOnCompact_le
    (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) (K : Compacts X) :
    compactCapacity Λ K + infOnCompact f K ≤ Λ.toFun f := by
  by_cases h_empty : ( K : Set X ) = ∅;
  · simp +decide [ show K = ⊥ from SetLike.ext' h_empty, compactCapacity_empty ];
  · -- Since K is compact and nonempty, f attains minimum x₀ ∈ K with f(x₀) = min. Then infOnCompact f K = f(x₀).
    obtain ⟨x₀, hx₀K, hx₀min⟩ : ∃ x₀ ∈ (K : Set X), ∀ x ∈ (K : Set X), f x₀ ≤ f x := by
      exact ( IsCompact.exists_isMinOn ( K.2 ) ( Set.nonempty_iff_ne_empty.2 h_empty ) ( f.continuous.continuousOn ) )
    have h_inf : infOnCompact f K = (f x₀ : EReal) := by
      refine' le_antisymm _ _;
      · exact?;
      · exact le_iInf₂ fun x hx => mod_cast hx₀min x hx;
    have h_capacity : compactCapacity Λ K ≤ Λ.toFun (f - ContinuousMap.const X (f x₀)) := by
      exact compactCapacity_le_of_nonneg Λ K _ fun x hx => sub_nonneg.2 ( hx₀min x hx );
    have h_shift : Λ.toFun (f - ContinuousMap.const X (f x₀)) = Λ.toFun f - (f x₀ : EReal) := by
      convert Λ.shift_equivariant ( -f x₀ ) f using 1;
    cases h : Λ.toFun f <;> simp_all +decide [ sub_eq_add_neg ];
    exact?

/-- The tropical Choquet envelope is bounded above by `Λ(f)`. -/
theorem tropical_choquet_radon_le (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    (⨆ K : Compacts X, compactCapacity Λ K + infOnCompact f K) ≤ Λ.toFun f :=
  iSup_le (compactCapacity_add_infOnCompact_le Λ f)

/-
For singletons, the Choquet envelope gives a lower bound.
-/
theorem tropical_choquet_radon_singletons_le
    (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    (⨆ x : X, compactCapacity Λ ⟨{x}, isCompact_singleton⟩ + (f x : EReal))
      ≤ Λ.toFun f := by
  refine' iSup_le fun x => _;
  convert compactCapacity_add_infOnCompact_le Λ f ⟨ { x }, isCompact_singleton ⟩;
  simp +decide [ infOnCompact ]

/-! ### Support theory -/

/-- A tropical functional is supported on a set `S` if every compact set
    disjoint from `S` has capacity ⊥. -/
def supportedOn (Λ : UCTropicalFunctional X) (S : Set X) : Prop :=
  ∀ K : Compacts X, Disjoint (K : Set X) S → compactCapacity Λ K = ⊥

/-- The tropical support: the intersection of all closed carriers.
    This is automatically closed and is the smallest closed set on which Λ is supported. -/
def tropSupport (Λ : UCTropicalFunctional X) : Set X :=
  ⋂₀ {S : Set X | IsClosed S ∧ supportedOn Λ S}

/-- The tropical support is closed (intersection of closed sets). -/
theorem isClosed_tropSupport (Λ : UCTropicalFunctional X) :
    IsClosed (tropSupport Λ) := by
  exact isClosed_sInter (fun S hS => hS.1)

/-- The tropical support is contained in any closed carrier (by definition). -/
theorem tropSupport_minimal (Λ : UCTropicalFunctional X) {S : Set X}
    (hS : IsClosed S) (hsupp : supportedOn Λ S) :
    tropSupport Λ ⊆ S :=
  sInter_subset_of_mem ⟨hS, hsupp⟩

set_option maxHeartbeats 400000 in
/-
Key helper: if every singleton in `K` has capacity ⊥, then `K` has capacity ⊥.
    The proof uses compactness, continuity of test functions, and sup-preserving.
-/
theorem compactCapacity_eq_bot_of_singletons
    (Λ : UCTropicalFunctional X) (K : Compacts X)
    (h : ∀ x ∈ (K : Set X),
      compactCapacity Λ ⟨{x}, isCompact_singleton⟩ = ⊥) :
    compactCapacity Λ K = ⊥ := by
  by_contra h_contra;
  obtain ⟨n, hn⟩ : ∃ n : ℕ, ∀ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) → Λ.toFun f > -(n : EReal) := by
    have h_inf : ∃ m : EReal, m > ⊥ ∧ ∀ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) → Λ.toFun f ≥ m := by
      refine' ⟨ _, lt_of_le_of_ne ( bot_le ) ( Ne.symm h_contra ), fun f hf => _ ⟩
      generalize_proofs at *; simp_all +decide [ compactCapacity ] ;
      exact csInf_le ⟨ ⊥, by rintro a ⟨ g, hg, rfl ⟩ ; exact bot_le ⟩ ⟨ f, hf, rfl ⟩
    generalize_proofs at *; simp_all +decide [ compactCapacity ] ;
    obtain ⟨ m, hm₁, hm₂ ⟩ := h_inf; rcases m with ( _ | _ | m ) ;
    · exact False.elim ( hm₁.ne rfl );
    · exact ⟨ 0, fun f hf => lt_of_lt_of_le ( by simp +decide ) ( hm₂ f hf ) ⟩;
    · refine' ⟨ ⌊-m⌋₊ + 1, fun f hf => lt_of_lt_of_le _ ( hm₂ f hf ) ⟩ ; norm_num [ Nat.lt_floor_add_one ];
      exact EReal.coe_lt_coe_iff.mpr ( by linarith [ Nat.lt_floor_add_one ( -m ) ] );
  -- For each x in K, there exists a function f_x such that f_x(x) ≥ 0 and Λ(f_x) < -(n+1).
  have h_exists_fx : ∀ x ∈ (K : Set X), ∃ f : C(X, ℝ), f x ≥ 0 ∧ Λ.toFun f < -(n + 1 : EReal) := by
    intro x hx
    have h_exists_fx : compactCapacity Λ ⟨{x}, isCompact_singleton⟩ < -(n + 1 : EReal) := by
      rw [ h x hx ];
      exact EReal.bot_lt_coe _;
    contrapose! h_exists_fx;
    exact le_csInf ( compactCapacity_set_nonempty Λ ⟨ { x }, isCompact_singleton ⟩ ) fun a ha => by aesop;
  choose! f hf₁ hf₂ using h_exists_fx;
  -- Let $g_x = f_x + \text{const}(1)$. Then $g_x(x) \geq 1$, and $\Lambda(g_x) = \Lambda(f_x) + 1 < -n$.
  set g : X → C(X, ℝ) := fun x => f x + ContinuousMap.const X 1
  have hg₁ : ∀ x ∈ (K : Set X), (g x) x ≥ 1 := by
    aesop
  have hg₂ : ∀ x ∈ (K : Set X), Λ.toFun (g x) < -(n : EReal) := by
    intro x hx
    have h_shift : Λ.toFun (g x) = Λ.toFun (f x) + 1 := by
      convert Λ.shift_equivariant' 1 ( f x ) using 1
    rw [h_shift];
    specialize hf₂ x hx;
    cases h : Λ.toFun ( f x ) <;> simp_all +decide [ add_comm ];
    · exact EReal.bot_lt_coe _;
    · erw [ EReal.coe_lt_coe_iff ] at * ; norm_num at * ; linarith;
  -- The set $U_x = \{y \mid g_x(y) > 0\}$ is open (preimage of $(0, \infty)$ under continuous $g_x$) and $x \in U_x$ (since $g_x(x) \geq 1 > 0$).
  have hU_open : ∀ x ∈ (K : Set X), IsOpen {y | (g x) y > 0} := by
    exact fun x hx => isOpen_lt continuous_const ( g x |> ContinuousMap.continuous );
  -- By compactness, there exists a finite subcover: $x₁, ..., x_m ∈ K$ with $K ⊆ U_{x₁} ∪ ... ∪ U_{x_m}$.
  obtain ⟨x_fin, hx_fin⟩ : ∃ x_fin : Finset X, (K : Set X) ⊆ ⋃ x ∈ x_fin, {y | (g x) y > 0} ∧ ∀ x ∈ x_fin, x ∈ (K : Set X) := by
    have := K.2.elim_nhds_subcover ( fun x => { y | ( g x ) y > 0 } ) fun x hx => IsOpen.mem_nhds ( hU_open x hx ) ( show ( g x ) x > 0 from lt_of_lt_of_le zero_lt_one ( hg₁ x hx ) );
    exact ⟨ this.choose, this.choose_spec.2, this.choose_spec.1 ⟩;
  -- Set $h = g_{x₁} ⊔ ... ⊔ g_{x_m}$. Then $h$ is nonneg on $K$ and $\Lambda(h) < -n$.
  set h : C(X, ℝ) := Finset.sup' x_fin (by
  by_cases h_empty : K = ⊥;
  · simp_all +decide [ compactCapacity_empty ];
  · exact Finset.nonempty_of_ne_empty ( by rintro rfl; simp_all +decide [ Set.subset_empty_iff ] )) g
  generalize_proofs at *;
  -- Then $h$ is nonneg on $K$ and $\Lambda(h) < -n$.
  have hh_nonneg : ∀ x ∈ (K : Set X), 0 ≤ h x := by
    intro x hx
    obtain ⟨y, hy₁, hy₂⟩ : ∃ y ∈ x_fin, (g y) x > 0 := by
      simpa using hx_fin.1 hx;
    simp +zetaDelta at *;
    exact ⟨ y, hy₁, le_of_lt hy₂ ⟩
  have hh_lambda : Λ.toFun h < -(n : EReal) := by
    have hh_lambda : Λ.toFun h = Finset.sup' x_fin ‹_› (fun x => Λ.toFun (g x)) := by
      have hh_lambda : ∀ (s : Finset X) (hs : s.Nonempty), Λ.toFun (s.sup' hs g) = s.sup' hs (fun x => Λ.toFun (g x)) := by
        intro s hs; induction hs using Finset.Nonempty.cons_induction <;> simp_all +decide [ Finset.sup'_cons ] ;
        rw [ ← ‹Λ.toFun ( Finset.sup' _ _ g ) = Finset.sup' _ _ fun x => Λ.toFun ( g x ) ›, Λ.sup_preserving' ];
      exact hh_lambda x_fin ‹_›;
    simp_all +decide [ Finset.sup'_lt_iff ];
  grind +splitIndPred

/-
The functional is supported on its tropical support.
-/
theorem tropSupport_supported (Λ : UCTropicalFunctional X) :
    supportedOn Λ (tropSupport Λ) := by
  intro K;
  -- If $K$ is disjoint from the tropical support, then for every $x \in K$, there exists a closed carrier $S_x$ such that $x \notin S_x$.
  intro hK_disjoint
  have h_singleton : ∀ x ∈ (K : Set X), ∃ S : Set X, IsClosed S ∧ supportedOn Λ S ∧ x ∉ S := by
    simp_all +decide [ Set.disjoint_left, tropSupport ];
  apply compactCapacity_eq_bot_of_singletons;
  intro x hx;
  obtain ⟨ S, hS_closed, hS_support, hxS ⟩ := h_singleton x hx;
  exact hS_support ⟨ { x }, isCompact_singleton ⟩ ( Set.disjoint_singleton_left.mpr hxS )

/-- Combined: the tropical support is the unique smallest closed carrier. -/
theorem tropSupport_is_smallest_closed_support (Λ : UCTropicalFunctional X) :
    IsClosed (tropSupport Λ) ∧
    supportedOn Λ (tropSupport Λ) ∧
    ∀ S : Set X, IsClosed S → supportedOn Λ S → tropSupport Λ ⊆ S :=
  ⟨isClosed_tropSupport Λ, tropSupport_supported Λ,
   fun _S hS hsupp => tropSupport_minimal Λ hS hsupp⟩

/-- Characterization: `x ∉ tropSupport Λ` iff there exists a closed carrier not containing `x`. -/
theorem not_mem_tropSupport_iff (Λ : UCTropicalFunctional X) (x : X) :
    x ∉ tropSupport Λ ↔
    ∃ S : Set X, IsClosed S ∧ supportedOn Λ S ∧ x ∉ S := by
  simp [tropSupport]

/-! ### Functoriality under continuous maps -/

variable {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]

/-- Pushforward of a tropical functional along a continuous map `φ : X → Y`.
    Given `Λ` on `C(X, ℝ)`, `(φ_* Λ)` acts on `C(Y, ℝ)` by `(φ_* Λ)(g) = Λ(g ∘ φ)`. -/
def pushforwardFunctional (φ : C(X, Y)) (Λ : UCTropicalFunctional X) :
    UCTropicalFunctional Y where
  toFun g := Λ.toFun (g.comp φ)
  monotone' := fun _ _ hfg => Λ.monotone (fun x => hfg (φ x))
  sup_preserving' := by
    intro f g
    have h : (f ⊔ g).comp φ = f.comp φ ⊔ g.comp φ := by
      ext x; simp [ContinuousMap.comp_apply, ContinuousMap.sup_apply]
    rw [h]; exact Λ.sup_preserving (f.comp φ) (g.comp φ)
  shift_equivariant' := by
    intro c f
    have h : (f + ContinuousMap.const Y c).comp φ = f.comp φ + ContinuousMap.const X c := by
      ext x; simp [ContinuousMap.comp_apply]
    rw [h]; exact Λ.shift_equivariant c (f.comp φ)
  top_continuous' := by
    intro ι _ _ s f hf hs
    have hscomp : Monotone (fun i => (s i).comp φ) := fun i j hij x => hs hij (φ x)
    have hfcomp : ∀ x, (f.comp φ) x = ⨆ i, ((s i).comp φ x : EReal) := by
      intro x; simp [ContinuousMap.comp_apply]; exact hf (φ x)
    exact Λ.top_continuous' (fun i => (s i).comp φ) (f.comp φ) hfcomp hscomp
  normalized' := by
    show Λ.toFun ((0 : C(Y, ℝ)).comp φ) = 0
    have : (0 : C(Y, ℝ)).comp φ = 0 := by ext; simp
    rw [this]; exact Λ.normalized

/-
Capacity under pushforward is bounded by capacity of the image.
-/
theorem compactCapacity_pushforward_le (φ : C(X, Y))
    (Λ : UCTropicalFunctional X) (K : Compacts X) :
    compactCapacity Λ K
      ≤ compactCapacity (pushforwardFunctional φ Λ) (K.map φ φ.continuous) := by
  -- Let $g$ be a continuous function that is non-negative on $K$. Then $g \circ \phi$ is non-negative on $\phi(K)$.
  have h_nonneg : ∀ g : C(Y, ℝ), (∀ y ∈ (Compacts.map φ φ.continuous K : Set Y), (0 : ℝ) ≤ g y) → (∀ x ∈ (K : Set X), (0 : ℝ) ≤ g (φ x)) := by
    exact fun g hg x hx => hg _ ⟨ x, hx, rfl ⟩;
  refine' le_csInf _ _;
  · exact ⟨ _, ⟨ 0, fun _ _ => le_rfl, rfl ⟩ ⟩;
  · rintro _ ⟨ g, hg, rfl ⟩;
    exact compactCapacity_le_of_nonneg Λ K ( g.comp φ ) ( h_nonneg g hg )

/-- The tropical support of a pushforward maps into the image of the support.
    This requires showing that for y ∉ φ(tropSupport(Λ)), the singleton
    capacity cap_{φ_*Λ}({y}) = ⊥, which involves Urysohn-type extension arguments
    to construct admissible test functions g with g(y) ≥ 0 and Λ(g∘φ) arbitrarily negative. -/
theorem tropSupport_pushforward_subset (φ : C(X, Y))
    (Λ : UCTropicalFunctional X) :
    tropSupport (pushforwardFunctional φ Λ) ⊆ φ '' tropSupport Λ := by
  apply tropSupport_minimal
  · exact (isClosed_tropSupport Λ).isCompact.image φ.continuous |>.isClosed
  · intro K hK
    apply compactCapacity_eq_bot_of_singletons
    intro y hy
    -- y ∈ K and K is disjoint from φ '' tropSupport Λ
    -- So φ⁻¹({y}) is disjoint from tropSupport Λ
    sorry

end