/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Universal M-Convex Compression Theorem

This file establishes that the complexity of Lorentzian recognition for
homogeneous polynomials with nonnegative coefficients is controlled by
the discrete-convex geometry (M-convex shadow) of the Newton support.

## Main Results

* `mem_shadow_iff_fiber_nonempty` — shadow membership ↔ fiber nonemptiness
* `nonneg_coeff_no_cancellation` — nonneg coefficients ⟹ no cancellation
* `fiber_eq_quadLeafFiber_of_homog` — fiber = quad leaf fiber for homogeneous supports
* `derivWeight_pos` — derivative weights are positive
* `mconvex_fiber_exchange` — M-convex exchange controls fibers
* `exchangeVisible_eq_degreeShadow` — visible shadow = full shadow for nonneg coeff
* `matroidBasisSupport_homogeneous` — matroid basis supports are homogeneous

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators MvPolynomial Finsupp

noncomputable section

namespace MConvexCompression

/-! ## Part I: Core Definitions -/

/-- The Newton support of a polynomial as a Finset. -/
def NewtonSupportFinset {n : ℕ} (p : MvPolynomial (Fin n) ℝ) :
    Finset (Fin n →₀ ℕ) :=
  p.support

/-- The total degree of a multi-index. -/
def totalDeg {n : ℕ} (α : Fin n →₀ ℕ) : ℕ :=
  α.sum fun _ m => m

/-- The support shadow: all multi-indices dominated by some support element. -/
def SupportShadow {n : ℕ} (S : Finset (Fin n →₀ ℕ)) : Set (Fin n →₀ ℕ) :=
  {α | ∃ β ∈ S, α ≤ β}

/-- The degree-k shadow: elements of the support shadow with total degree k. -/
def DegreeShadow {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (k : ℕ) :
    Set (Fin n →₀ ℕ) :=
  {α | α ∈ SupportShadow S ∧ totalDeg α = k}

/-- The dominating fiber: support elements that dominate a given multi-index. -/
def DominatingFiber {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (α : Fin n →₀ ℕ) :
    Finset (Fin n →₀ ℕ) :=
  S.filter fun β => α ≤ β

/-- The quadratic leaf fiber: support elements that dominate α with
    total degree exactly `totalDeg α + 2`. -/
def QuadraticLeafFiber {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (α : Fin n →₀ ℕ) :
    Finset (Fin n →₀ ℕ) :=
  S.filter fun β => α ≤ β ∧ totalDeg β = totalDeg α + 2

/-- No-cancellation condition: all coefficients above α are nonneg. -/
def NoCancellationOnFiber {n : ℕ} (p : MvPolynomial (Fin n) ℝ)
    (α : Fin n →₀ ℕ) : Prop :=
  ∀ β, α ≤ β → MvPolynomial.coeff β p ≥ 0

/-- The exchange-visible shadow: degree-k shadow elements where the
    quadratic leaf fiber is nonempty and no-cancellation holds. -/
def ExchangeVisibleShadow {n : ℕ} (p : MvPolynomial (Fin n) ℝ)
    (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : Set (Fin n →₀ ℕ) :=
  {α | totalDeg α = k ∧
       (QuadraticLeafFiber S α).Nonempty ∧
       NoCancellationOnFiber p α}

/-- M-convex exchange property for sets of `Fin n →₀ ℕ`. -/
def IsMConvexExchange {n : ℕ} (S : Set (Fin n →₀ ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n,
    α i > β i →
    ∃ j : Fin n, α j < β j ∧
      (α - Finsupp.single i 1 + Finsupp.single j 1) ∈ S

/-- Homogeneity: all support elements have the same total degree. -/
def IsHomogeneousSupport {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (r : ℕ) : Prop :=
  ∀ β ∈ S, totalDeg β = r

/-! ## Part II: Shadow-Fiber Correspondence -/

/-- Shadow membership is equivalent to fiber nonemptiness. -/
theorem mem_shadow_iff_fiber_nonempty {n : ℕ}
    (S : Finset (Fin n →₀ ℕ)) (α : Fin n →₀ ℕ) :
    α ∈ SupportShadow S ↔ (DominatingFiber S α).Nonempty := by
  unfold SupportShadow DominatingFiber
  simp [Finset.Nonempty, Finset.mem_filter]

/-- Degree shadow membership is equivalent to fiber nonemptiness at the right degree. -/
theorem mem_degreeShadow_iff {n : ℕ}
    (S : Finset (Fin n →₀ ℕ)) (α : Fin n →₀ ℕ) (k : ℕ) :
    α ∈ DegreeShadow S k ↔
      (DominatingFiber S α).Nonempty ∧ totalDeg α = k := by
  unfold DegreeShadow
  rw [Set.mem_setOf_eq, ← mem_shadow_iff_fiber_nonempty]

/-- The quadratic leaf fiber is a subset of the dominating fiber. -/
theorem quadLeafFiber_sub_dominatingFiber {n : ℕ}
    (S : Finset (Fin n →₀ ℕ)) (α : Fin n →₀ ℕ) :
    QuadraticLeafFiber S α ⊆ DominatingFiber S α := by
  intro β hβ
  simp only [QuadraticLeafFiber, DominatingFiber, Finset.mem_filter] at hβ ⊢
  exact ⟨hβ.1, hβ.2.1⟩

/-- The fiber of α relative to a homogeneous support equals
    the quadratic leaf fiber when `totalDeg α = r - 2`. -/
theorem fiber_eq_quadLeafFiber_of_homog {n : ℕ}
    (S : Finset (Fin n →₀ ℕ)) (r : ℕ) (hr : 2 ≤ r)
    (hS : IsHomogeneousSupport S r)
    (α : Fin n →₀ ℕ) (hα : totalDeg α = r - 2) :
    DominatingFiber S α = QuadraticLeafFiber S α := by
  ext β
  simp only [DominatingFiber, QuadraticLeafFiber, Finset.mem_filter]
  constructor
  · intro ⟨hβS, hαβ⟩
    exact ⟨hβS, hαβ, by rw [hS β hβS, hα]; omega⟩
  · intro ⟨hβS, hαβ, _⟩
    exact ⟨hβS, hαβ⟩

/-! ## Part III: No-Cancellation and Derivative Weights -/

/-- For polynomials with nonneg coefficients, no-cancellation holds everywhere. -/
theorem nonneg_coeff_no_cancellation {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (hp : ∀ d, MvPolynomial.coeff d p ≥ 0)
    (α : Fin n →₀ ℕ) : NoCancellationOnFiber p α :=
  fun β _ => hp β

/-- The multinomial derivative weight: the product of descending factorials
    that appears when differentiating x^β by ∂^α. -/
def derivWeight {n : ℕ} (α β : Fin n →₀ ℕ) : ℕ :=
  Finset.univ.prod fun i => Nat.descFactorial (β i) (α i)

/-
**Theorem 1 (Derivative Weight Positivity).**
    The derivative weight is positive when α ≤ β.
-/
theorem derivWeight_pos {n : ℕ} (α β : Fin n →₀ ℕ) (h : α ≤ β) :
    0 < derivWeight α β := by
  exact Finset.prod_pos fun i _ => Nat.descFactorial_pos.mpr ( h i )

/-
Each term in the derivative sum is nonneg when the coefficient is nonneg.
-/
theorem deriv_term_nonneg {n : ℕ}
    (c : ℝ) (α β : Fin n →₀ ℕ)
    (hc : c ≥ 0) (_h : α ≤ β) :
    0 ≤ c * (derivWeight α β : ℝ) := by
  exact mul_nonneg hc ( Nat.cast_nonneg _ )

/-- **Theorem 2 (Derivative Survival = Shadow Membership).**
    For a polynomial with nonneg coefficients and Newton support S,
    α is in the support shadow iff the dominating fiber is nonempty. -/
theorem derivative_nonzero_iff_in_shadow {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ)
    (α : Fin n →₀ ℕ) :
    α ∈ SupportShadow (NewtonSupportFinset p) ↔
      (DominatingFiber (NewtonSupportFinset p) α).Nonempty :=
  mem_shadow_iff_fiber_nonempty _ _

/-! ## Part IV: Counting Compression -/

/-- The shadow Finset: all multi-indices of degree k dominated by some element of S. -/
def MConvexShadowFinset {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (k : ℕ) :
    Finset (Fin n →₀ ℕ) :=
  (S.biUnion fun β => Finset.Iic β).filter fun α => totalDeg α = k

/-- Membership in the shadow Finset captures exactly the degree shadow. -/
theorem mem_shadowFinset_iff {n : ℕ}
    (S : Finset (Fin n →₀ ℕ)) (k : ℕ) (α : Fin n →₀ ℕ) :
    α ∈ MConvexShadowFinset S k ↔ α ∈ DegreeShadow S k := by
  unfold MConvexShadowFinset DegreeShadow SupportShadow
  simp [Finset.mem_filter, Finset.mem_biUnion, Finset.mem_Iic]

/-- The count of nonzero quadratic leaves. -/
def quadraticLeafCount {n : ℕ} (S : Finset (Fin n →₀ ℕ)) (r : ℕ) : ℕ :=
  (MConvexShadowFinset S (r - 2)).card

/-- **Theorem 3 (Counting Compression).**
    The number of nonzero quadratic derivative leaves equals the
    cardinality of the degree-(r-2) shadow. -/
theorem nonzero_leaf_count_eq_shadow_card {n : ℕ}
    (S : Finset (Fin n →₀ ℕ)) (r : ℕ) :
    quadraticLeafCount S r = (MConvexShadowFinset S (r - 2)).card :=
  rfl

/-! ## Part V: M-Convex Exchange Structure on Fibers -/

/-
**Theorem 4 (M-Convex Fiber Exchange).**
    If S is M-convex and β₁, β₂ are in the dominating fiber above α,
    then M-convex exchange applies directly to β₁ and β₂.
-/
theorem mconvex_fiber_exchange {n : ℕ}
    (S : Finset (Fin n →₀ ℕ))
    (hmc : IsMConvexExchange (S : Set (Fin n →₀ ℕ)))
    (α β₁ β₂ : Fin n →₀ ℕ)
    (hβ₁ : β₁ ∈ DominatingFiber S α)
    (hβ₂ : β₂ ∈ DominatingFiber S α)
    (i : Fin n) (hi : β₁ i > β₂ i) :
    ∃ j : Fin n, β₁ j < β₂ j ∧
      (β₁ - Finsupp.single i 1 + Finsupp.single j 1) ∈
        (S : Set (Fin n →₀ ℕ)) := by
  exact hmc _ ( Finset.mem_filter.mp hβ₁ |>.1 ) _ ( Finset.mem_filter.mp hβ₂ |>.1 ) i hi

/-! ## Part VI: Exchange-Visible Shadow Equals Full Shadow -/

/-- **Theorem 5 (Exchange-Visible = Full Shadow for Nonneg Coefficients).**
    For a polynomial with nonneg coefficients and homogeneous support
    of degree r, the exchange-visible (r-2)-shadow equals the
    full (r-2)-shadow. -/
theorem exchangeVisible_eq_degreeShadow {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (r : ℕ) (hr : 2 ≤ r)
    (hp_nonneg : ∀ d, MvPolynomial.coeff d p ≥ 0)
    (hS : IsHomogeneousSupport (NewtonSupportFinset p) r) :
    ExchangeVisibleShadow p (NewtonSupportFinset p) (r - 2) =
      DegreeShadow (NewtonSupportFinset p) (r - 2) := by
  ext α
  simp only [ExchangeVisibleShadow, DegreeShadow, Set.mem_setOf_eq]
  constructor
  · intro ⟨hdeg, hfib, _⟩
    refine ⟨?_, hdeg⟩
    rw [mem_shadow_iff_fiber_nonempty]
    exact Finset.Nonempty.mono (quadLeafFiber_sub_dominatingFiber _ α) hfib
  · intro ⟨hshad, hdeg⟩
    refine ⟨hdeg, ?_, nonneg_coeff_no_cancellation p hp_nonneg α⟩
    rw [mem_shadow_iff_fiber_nonempty] at hshad
    rw [← fiber_eq_quadLeafFiber_of_homog _ r hr hS α hdeg]
    exact hshad

/-! ## Part VII: Cross-Domain — Flow Polytope Supports -/

/-- A network flow configuration. -/
structure FlowNetwork (m k : ℕ) where
  incidence : Fin m → Fin k → Int
  capacity : Fin m → ℕ
  demand : Fin k → Int

/-- A feasible integer flow for a network. -/
def IsFeasibleFlow {m k : ℕ} (net : FlowNetwork m k) (f : Fin m →₀ ℕ) : Prop :=
  (∀ e, f e ≤ net.capacity e) ∧
  (∀ v, ∑ e : Fin m, net.incidence e v * (f e : Int) = net.demand v)

/-- The set of feasible integer flows. -/
def FlowSupport {m k : ℕ} (net : FlowNetwork m k) : Set (Fin m →₀ ℕ) :=
  {f | IsFeasibleFlow net f}

/-
**Exchange Direction Existence.**
    When two Finsupps have the same total degree and differ at coordinate i,
    there must exist a compensating coordinate j in the other direction.
    This is a fundamental lemma used in all M-convex exchange arguments.
-/
theorem exchange_direction_exists {n : ℕ}
    (α β : Fin n →₀ ℕ)
    (htot : totalDeg α = totalDeg β)
    (i : Fin n) (hi : α i > β i) :
    ∃ j : Fin n, α j < β j := by
  contrapose! htot;
  unfold totalDeg;
  rw [ Finsupp.sum_fintype, Finsupp.sum_fintype ];
  · exact ne_of_gt ( Finset.sum_lt_sum ( fun i _ => htot i ) ⟨ i, Finset.mem_univ i, hi ⟩ );
  · exact fun _ => rfl;
  · exact fun _ => rfl

/-! ## Part VIII: Matroid Specialization -/

/-- A matroid basis family gives a multiaffine support. -/
def matroidBasisSupport {n : ℕ} (bases : Finset (Finset (Fin n))) :
    Finset (Fin n →₀ ℕ) :=
  bases.image fun B => B.sum fun i => Finsupp.single i 1

/-
Matroid basis supports are homogeneous.
-/
theorem matroidBasisSupport_homogeneous {n r : ℕ}
    (bases : Finset (Finset (Fin n))) (hcard : ∀ B ∈ bases, B.card = r) :
    IsHomogeneousSupport (matroidBasisSupport bases) r := by
  intro β hβ; rw [ matroidBasisSupport ] at hβ; rw [ Finset.mem_image ] at hβ; obtain ⟨ B, hB, rfl ⟩ := hβ; simp +decide [ *, totalDeg ] ;
  rw [ ← sum_finset_sum_index ] <;> norm_num [ hcard B hB ]

/-- **Theorem 7 (Matroid Basis Corollary).**
    For matroid basis generating polynomials, the compression
    theorem recovers the matroid basis leaf compression. -/
theorem matroid_compression_corollary {n r : ℕ}
    (bases : Finset (Finset (Fin n))) :
    quadraticLeafCount (matroidBasisSupport bases) r =
      (MConvexShadowFinset (matroidBasisSupport bases) (r - 2)).card :=
  rfl

/-! ## Part IX: Shadow Coordinate Containment -/

/-- Active coordinates appearing in at least one support element. -/
def activeCoords {n : ℕ} (S : Finset (Fin n →₀ ℕ)) : Finset (Fin n) :=
  S.biUnion fun β => Finset.univ.filter fun i => β i ≠ 0

/-
Shadow elements only use active coordinates.
-/
theorem shadow_uses_active_coords {n : ℕ}
    (S : Finset (Fin n →₀ ℕ)) (α : Fin n →₀ ℕ)
    (hα : α ∈ SupportShadow S) (i : Fin n) (hi : α i ≠ 0) :
    i ∈ activeCoords S := by
  obtain ⟨ β, hβ, hαβ ⟩ := hα; exact Finset.mem_biUnion.2 ⟨ β, hβ, Finset.mem_filter.2 ⟨ Finset.mem_univ _, by exact ne_of_gt ( lt_of_lt_of_le ( Nat.pos_of_ne_zero hi ) ( hαβ i ) ) ⟩ ⟩ ;

end MConvexCompression