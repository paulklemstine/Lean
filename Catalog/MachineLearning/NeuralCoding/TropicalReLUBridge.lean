/-
Copyright (c) 2026 Tropical Neural Geometry Research Team. All rights reserved.
Released under Apache 2.0 license.

# Close Proofs: a formalized bridge between ReLU networks and tropical geometry

This file gives a self-contained, rigorous account of the classical
Zhang–Naitzat–Lim correspondence between feed-forward ReLU networks and
**tropical (max-plus) rational functions**.  We work over the input space
`ℝ^d = (Fin d → ℝ)`.

A *tropical polynomial* is a finite max of affine functions
`x ↦ ⟨a, x⟩ + b` — exactly the value of a tropical (max-plus) polynomial map.
The headline facts are:

* tropical polynomials are closed under pointwise `max` (tropical addition),
  pointwise `+` (tropical multiplication), and nonnegative scaling;
* `ReLU ∘ (tropical polynomial)` is again a tropical polynomial;
* every tropical polynomial is a **convex** piecewise-linear function;
* every one-hidden-layer ReLU network output is a **tropical rational
  function**: a difference `p - q` of two tropical polynomials;
* the **decision boundary** of a tropical-rational classifier `f = p - q`
  is the locus `{x | p x = q x}`, on which the combined tropical polynomial
  `max(p, q)` is attained simultaneously by a piece of `p` and a piece of `q`
  — i.e. the boundary lies on the tropical hypersurface of `max(p, q)`.

The core engine is the max-plus distributive law
`(sup' p) + (sup' q) = sup' over the product of (p + q)`, which is the formal
content of "tropical multiplication = ordinary addition of exponents".

This extends the catalog's tropical ML line (`MachineLearning.TropicalGating`,
which fixes a route to get a *single* affine map) by instead tracking the full
piecewise-affine / tropical structure across a ReLU layer.
-/

import Mathlib

open scoped BigOperators
open Finset

namespace TropicalReLUBridge

variable {d : ℕ}

/-- An affine functional `(a, b)` evaluated at `x`: `⟨a, x⟩ + b`. -/
def affEval (ab : (Fin d → ℝ) × ℝ) (x : Fin d → ℝ) : ℝ :=
  (∑ j, ab.1 j * x j) + ab.2

/-- `f` is a **tropical polynomial**: a finite (nonempty) max of affine functions.
This is precisely the value function of a tropical (max-plus) polynomial. -/
def IsTropPoly (f : (Fin d → ℝ) → ℝ) : Prop :=
  ∃ (S : Finset ((Fin d → ℝ) × ℝ)) (h : S.Nonempty),
    ∀ x, f x = S.sup' h (fun ab => affEval ab x)

/-- `f` is a **tropical rational function**: a difference of two tropical
polynomials.  This is the class computed by ReLU networks. -/
def IsTropRational (f : (Fin d → ℝ) → ℝ) : Prop :=
  ∃ p q : (Fin d → ℝ) → ℝ, IsTropPoly p ∧ IsTropPoly q ∧ ∀ x, f x = p x - q x

/-- The rectifier `ReLU t = max t 0`. -/
def relu (t : ℝ) : ℝ := max t 0

-- !-- A single affine function is a (one-term) tropical polynomial. -- !--
-- !-- Witness: the singleton family {(a,b)}; sup' over a singleton is the value. -- !--
theorem affine_isTropPoly (a : Fin d → ℝ) (b : ℝ) :
    IsTropPoly (fun x => affEval (a, b) x) := by
  refine ⟨{(a, b)}, Finset.singleton_nonempty _, ?_⟩
  intro x
  rw [Finset.sup'_singleton]

-- !-- Tropical addition: max of two tropical polynomials is a tropical polynomial. -- !--
-- !-- Take the union of the two affine families; `Finset.sup'_union` splits the sup. -- !--
theorem IsTropPoly.sup {f g : (Fin d → ℝ) → ℝ}
    (hf : IsTropPoly f) (hg : IsTropPoly g) :
    IsTropPoly (fun x => max (f x) (g x)) := by
  obtain ⟨S, hS, hfS⟩ := hf
  obtain ⟨T, hT, hgT⟩ := hg
  refine ⟨S ∪ T, hS.mono Finset.subset_union_left, ?_⟩
  intro x
  show max (f x) (g x) = _
  rw [hfS x, hgT x, Finset.sup'_union hS hT]

/-
!-- Key max-plus distributive law: (sup' over S) + (sup' over T) ranges over S×T. -- !--
!-- This is "tropical multiplication = addition": apply `sup'_add` then `add_sup'` -- !--
!-- and collapse the nested sup via `Finset.sup'_product_left`. -- !--
-/
theorem sup'_add_sup' {α : Type*} (S T : Finset α) (hS : S.Nonempty) (hT : T.Nonempty)
    (u v : α → ℝ) :
    S.sup' hS u + T.sup' hT v
      = (S ×ˢ T).sup' (hS.product hT) (fun p => u p.1 + v p.2) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
  · rcases Finset.exists_mem_eq_sup' hS u with ⟨ a, ha, ha' ⟩ ; rcases Finset.exists_mem_eq_sup' hT v with ⟨ b, hb, hb' ⟩ ; use a, b ; aesop;
  · exact fun a b ha hb => add_le_add ( Finset.le_sup' u ha ) ( Finset.le_sup' v hb )

/-
!-- Tropical multiplication: the sum of two tropical polynomials is a tropical -- !--
!-- polynomial, indexed by the Minkowski/product family with added coefficients. -- !--
-/
theorem IsTropPoly.add {f g : (Fin d → ℝ) → ℝ}
    (hf : IsTropPoly f) (hg : IsTropPoly g) :
    IsTropPoly (fun x => f x + g x) := by
  obtain ⟨S, hS, hfS⟩ := hf
  obtain ⟨T, hT, hgT⟩ := hg
  refine ⟨(S ×ˢ T).image (fun p => (p.1.1 + p.2.1, p.1.2 + p.2.2)),
    (hS.product hT).image _, ?_⟩
  intro x; simp +decide [ hfS, hgT, sup'_add_sup' _ _ hS hT ] ;
  unfold affEval; norm_num [ Finset.sum_add_distrib ] ;
  simp +decide only [add_assoc, add_left_comm, add_mul, sum_add_distrib]

/-
!-- Nonnegative scaling preserves tropical polynomials (scale every affine piece). -- !--
!-- For `c ≥ 0`, `c * ·` is monotone, so it commutes with `sup'`. -- !--
-/
theorem IsTropPoly.smul_nonneg {f : (Fin d → ℝ) → ℝ} (hf : IsTropPoly f)
    {c : ℝ} (hc : 0 ≤ c) :
    IsTropPoly (fun x => c * f x) := by
  obtain ⟨S, hS, hfS⟩ := hf
  refine ⟨S.image (fun ab => (fun j => c * ab.1 j, c * ab.2)), hS.image _, ?_⟩
  simp_all +decide [ Finset.sup'_eq_csSup_image, affEval ];
  intro x; rw [ ← smul_eq_mul, ← Real.sSup_smul_of_nonneg hc ] ; congr; ext; simp +decide [ mul_add, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
  simp +decide [ Set.mem_smul_set, mul_assoc, Finset.mul_sum _ _ _, mul_add, add_comm, add_left_comm, add_assoc ]

-- !-- ReLU of a tropical polynomial is a tropical polynomial: ReLU t = max t 0, -- !--
-- !-- and the zero function is affine, so this is `IsTropPoly.sup` with the constant 0. -- !--
theorem IsTropPoly.relu {f : (Fin d → ℝ) → ℝ} (hf : IsTropPoly f) :
    IsTropPoly (fun x => relu (f x)) := by
  have hzero : IsTropPoly (fun _ : Fin d → ℝ => (0 : ℝ)) := by
    have := affine_isTropPoly (d := d) (fun _ => 0) 0
    simpa [affEval] using this
  simpa [relu] using hf.sup hzero

/-
!-- Every affine functional is convex (it is a linear map plus a constant). -- !--
-/
theorem affEval_convexOn (ab : (Fin d → ℝ) × ℝ) :
    ConvexOn ℝ Set.univ (fun x => affEval ab x) := by
  refine' ⟨ convex_univ, _ ⟩;
  simp +decide [ affEval, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, ← eq_sub_iff_add_eq' ];
  intros; subst_vars; linarith;

/-
!-- A tropical polynomial is convex: a finite max of convex (affine) functions, -- !--
!-- proved by `Finset.sup'_induction` with closure under `ConvexOn.sup`. -- !--
-/
theorem IsTropPoly.convexOn {f : (Fin d → ℝ) → ℝ} (hf : IsTropPoly f) :
    ConvexOn ℝ Set.univ f := by
  obtain ⟨S, hS, hfS⟩ := hf
  have hcongr : f = fun x => S.sup' hS (fun ab => affEval ab x) := funext hfS
  rw [hcongr]
  have h_ind : ∀ (s : Finset ((Fin d → ℝ) × ℝ)) (hs : s.Nonempty), ConvexOn ℝ Set.univ (fun x => s.sup' hs (fun ab => affEval ab x)) := by
    intro s hs;
    induction' hs using Finset.Nonempty.cons_induction with a s ha ih;
    · simpa using affEval_convexOn a;
    · simp_all +decide;
      exact ConvexOn.sup ( affEval_convexOn s ) ‹_›;
  exact h_ind S hS

/-! ### One-hidden-layer ReLU networks are tropical rational -/

/-- A one-hidden-layer ReLU network with `n` hidden units: hidden pre-activations
are affine maps `(A i, βh i)`, the output combines `ReLU` of each via weights
`c i` plus an output bias `b₀`:
`x ↦ b₀ + ∑ i, c i · ReLU(⟨A i, x⟩ + βh i)`. -/
def reluNet {n : ℕ} (A : Fin n → (Fin d → ℝ)) (bh : Fin n → ℝ)
    (c : Fin n → ℝ) (b0 : ℝ) (x : Fin d → ℝ) : ℝ :=
  b0 + ∑ i, c i * relu (affEval (A i, bh i) x)

-- !-- A constant function is a tropical polynomial (affine with zero linear part). -- !--
theorem const_isTropPoly (b : ℝ) : IsTropPoly (fun _ : Fin d → ℝ => b) := by
  have := affine_isTropPoly (d := d) (fun _ => 0) b
  simpa [affEval] using this

/-
!-- A finite sum of tropical polynomials is a tropical polynomial -- !--
!-- (induction on the finset; empty sum is the constant 0, step uses `IsTropPoly.add`). -- !--
-/
theorem isTropPoly_sum {ι : Type*} (s : Finset ι) (g : ι → (Fin d → ℝ) → ℝ)
    (hg : ∀ i ∈ s, IsTropPoly (g i)) :
    IsTropPoly (fun x => ∑ i ∈ s, g i x) := by
  induction' s using Finset.induction with i s hi ih;
  convert const_isTropPoly 0;
  convert IsTropPoly.add ( hg i ( Finset.mem_insert_self i s ) ) ( ih fun j hj => hg j ( Finset.mem_insert_of_mem hj ) ) using 1;
  grind +locals;
  exact Classical.decEq ι

/-
!-- MAIN BRIDGE THEOREM: every one-hidden-layer ReLU network output is a -- !--
!-- tropical rational function (a difference of two tropical polynomials). -- !--
!-- Each c i · ReLU(affine) splits by sign of c i into a positively-scaled -- !--
!-- tropical polynomial; collect positives into p, negatives into q. -- !--
-/
theorem reluNet_isTropRational {n : ℕ} (A : Fin n → (Fin d → ℝ)) (bh : Fin n → ℝ)
    (c : Fin n → ℝ) (b0 : ℝ) :
    IsTropRational (reluNet A bh c b0) := by
  refine' ⟨ fun x => b0 + ∑ i, ( Max.max ( c i ) 0 ) * relu ( affEval ( A i, bh i ) x ), fun x => ∑ i, ( Max.max ( -c i ) 0 ) * relu ( affEval ( A i, bh i ) x ), _, _, _ ⟩;
  · convert IsTropPoly.add ( const_isTropPoly b0 ) ( isTropPoly_sum Finset.univ ( fun i x => max ( c i ) 0 * relu ( affEval ( A i, bh i ) x ) ) ?_ ) using 1;
    exact fun i _ => IsTropPoly.smul_nonneg ( IsTropPoly.relu ( affine_isTropPoly ( A i ) ( bh i ) ) ) ( le_max_right _ _ );
  · convert isTropPoly_sum Finset.univ ( fun i x => Max.max ( -c i ) 0 * relu ( affEval ( A i, bh i ) x ) ) _ using 1;
    exact fun i _ => IsTropPoly.smul_nonneg ( IsTropPoly.relu ( affine_isTropPoly _ _ ) ) ( le_max_right _ _ );
  · intro x; simp only [reluNet] ; ring;
    rw [ ← Finset.sum_sub_distrib ] ; congr ; ext i ; cases max_cases ( c i ) 0 <;> cases max_cases ( -c i ) 0 <;> simp +decide [ * ] ; ring;
    · exact Or.inl ( by linarith );
    · linarith

/-! ### Decision boundaries are tropical hypersurfaces -/

/-- The **decision boundary** of a real-valued classifier `f` (sign of `f`):
the locus where `f` vanishes. -/
def decisionBoundary (f : (Fin d → ℝ) → ℝ) : Set (Fin d → ℝ) := {x | f x = 0}

-- !-- For a tropical-rational classifier f = p - q, the decision boundary is -- !--
-- !-- exactly {x | p x = q x}. -- !--
theorem decisionBoundary_eq_locus {f p q : (Fin d → ℝ) → ℝ}
    (hf : ∀ x, f x = p x - q x) :
    decisionBoundary f = {x | p x = q x} := by
  ext x
  simp only [decisionBoundary, Set.mem_setOf_eq, hf]
  constructor
  · intro h; linarith [sub_eq_zero.mp h]
  · intro h; rw [h]; ring

/-
!-- BRIDGE TO TROPICAL HYPERSURFACES: on the decision boundary {p = q} of a -- !--
!-- tropical-rational classifier, the combined tropical polynomial max(p,q) is -- !--
!-- attained simultaneously by a maximizing affine piece of p AND of q. Thus the -- !--
!-- boundary lies on the tropical hypersurface (non-smooth locus) of max(p,q). -- !--
-/
theorem decisionBoundary_on_tropHypersurface
    {p q : (Fin d → ℝ) → ℝ}
    {Sp : Finset ((Fin d → ℝ) × ℝ)} {hSp : Sp.Nonempty}
    {Sq : Finset ((Fin d → ℝ) × ℝ)} {hSq : Sq.Nonempty}
    (hp : ∀ x, p x = Sp.sup' hSp (fun ab => affEval ab x))
    (hq : ∀ x, q x = Sq.sup' hSq (fun ab => affEval ab x))
    {x : Fin d → ℝ} (hx : p x = q x) :
    ∃ abp ∈ Sp, ∃ abq ∈ Sq,
      affEval abp x = max (p x) (q x) ∧ affEval abq x = max (p x) (q x) := by
  have := Finset.exists_mem_eq_sup' hSp ( fun ab => affEval ab x ) ; have := Finset.exists_mem_eq_sup' hSq ( fun ab => affEval ab x ) ; aesop;

/-! ### Worked examples -/

-- ReLU of an affine pre-activation is a convex piecewise-linear function
-- (tropical polynomial ⇒ convex), the geometric reason ReLU layers are tame.
example (a : Fin d → ℝ) (b : ℝ) :
    ConvexOn ℝ Set.univ (fun x => relu (affEval (a, b) x)) :=
  ((affine_isTropPoly a b).relu).convexOn

-- A one-hidden-unit ReLU network is a tropical rational function.
example (a : Fin d → ℝ) (b w c0 : ℝ) :
    IsTropRational (reluNet (fun _ : Fin 1 => a) (fun _ : Fin 1 => b) (fun _ : Fin 1 => w) c0) :=
  reluNet_isTropRational _ _ _ _

-- The decision boundary of a tropical-rational classifier is the equality locus of
-- its two tropical polynomial parts.
example (p q : (Fin d → ℝ) → ℝ) :
    decisionBoundary (fun x => p x - q x) = {x | p x = q x} :=
  decisionBoundary_eq_locus (fun _ => rfl)

end TropicalReLUBridge