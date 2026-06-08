/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Shadow Complexity as an Arithmetic Circuit Lower Bound

This file establishes a novel connection between combinatorial shadow growth
and arithmetic circuit lower bounds for second-derivative (Hessian) computation.

## Mathematical overview

Given a finite support set `S ⊆ ℕⁿ` of exponent vectors, the **second shadow**
`Sh₂(S)` consists of all exponent vectors obtainable by subtracting two basis
vectors from some element of `S`. This is exactly the set of exponents that can
appear in second partial derivatives of a polynomial with support `S`.

The main theorem shows that any "support circuit" computing all Hessian channels
must have size at least `|Sh₂(S)| / n²`, establishing a support-geometric
lower bound on differentiation complexity.

## Main definitions

* `ShadowComplexity.secondShadow` — The second shadow `Sh₂(S)` of a support set
* `ShadowComplexity.hessianSupportFamily` — Tagged second shadow with channel indices
* `ShadowComplexity.hessianChannelSupport` — Per-channel shadow
* `ShadowComplexity.SupportCircuit` — Model of circuits computing exponent vectors
* `ShadowComplexity.ComputesHessianSupport` — Correctness predicate for circuits
* `ShadowComplexity.polytopeErosion2` — Discrete polytope erosion by degree-2 simplex

## Main results

* `ShadowComplexity.mem_secondShadow_iff_exists_hessian_channel` —
  Equivalence: β ∈ Sh₂(S) ↔ ∃ channel (i,j) with ((i,j),β) in the Hessian family
* `ShadowComplexity.supportCircuit_hessian_lower_bound` —
  Lower bound: |Sh₂(S)| ≤ n² · circuit size
* `ShadowComplexity.secondShadow_mono` — Monotonicity of second shadow
* `ShadowComplexity.secondShadow_eq_discreteErosion` —
  Second shadow equals discrete polytope erosion
-/

open Finset BigOperators

namespace ShadowComplexity

variable {n : ℕ}

/-! ## Second Shadow -/

/-- Predicate: exponent vector `β` is in the second shadow of `α`, meaning
there exist indices `i, j` such that `α = β + eᵢ + eⱼ` (coordinatewise). -/
def InSecondShadowOf (α β : Fin n → ℕ) : Prop :=
  ∃ i j : Fin n, ∀ k : Fin n,
    α k = β k + (if k = i then 1 else 0) + (if k = j then 1 else 0)

instance (α β : Fin n → ℕ) : Decidable (InSecondShadowOf α β) :=
  inferInstanceAs (Decidable (∃ i j : Fin n, ∀ k : Fin n,
    α k = β k + (if k = i then 1 else 0) + (if k = j then 1 else 0)))

/-- The **second shadow** of a support set `S ⊆ ℕⁿ`: all exponent vectors `β`
such that `β + eᵢ + eⱼ ∈ S` for some indices `i, j`.

This captures all exponents that can appear in the Hessian of a polynomial
with exponent support `S`. -/
def secondShadow (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.biUnion fun α =>
    (Fintype.piFinset fun k => Finset.range (α k + 1)).filter fun β =>
      InSecondShadowOf α β

theorem mem_secondShadow_iff {S : Finset (Fin n → ℕ)} {β : Fin n → ℕ} :
    β ∈ secondShadow S ↔ ∃ α ∈ S, InSecondShadowOf α β := by
  simp only [secondShadow, mem_biUnion, mem_filter, Fintype.mem_piFinset, mem_range]
  constructor
  · rintro ⟨α, hα, hrange, hshadow⟩
    exact ⟨α, hα, hshadow⟩
  · rintro ⟨α, hα, hshadow⟩
    refine ⟨α, hα, ?_, hshadow⟩
    intro k
    obtain ⟨i, j, hijk⟩ := hshadow
    have := hijk k
    omega

/-! ## Hessian Support Family -/

/-- The **Hessian support family**: all triples `((i,j), β)` encoding that
exponent vector `β` occurs in the `(i,j)`-entry of the Hessian of any
polynomial with exponent support `S`. -/
def hessianSupportFamily (S : Finset (Fin n → ℕ)) :
    Finset ((Fin n × Fin n) × (Fin n → ℕ)) :=
  S.biUnion fun α =>
    Finset.univ.biUnion fun (ij : Fin n × Fin n) =>
      let i := ij.1; let j := ij.2
      (Fintype.piFinset fun k => Finset.range (α k + 1)).filter
        (fun β => ∀ k, α k = β k + (if k = i then 1 else 0) + (if k = j then 1 else 0))
      |>.image fun β => (ij, β)

/-- Per-channel Hessian support: the set of exponent vectors appearing in
the `(i,j)`-entry of the Hessian. -/
def hessianChannelSupport (S : Finset (Fin n → ℕ)) (i j : Fin n) :
    Finset (Fin n → ℕ) :=
  S.biUnion fun α =>
    (Fintype.piFinset fun k => Finset.range (α k + 1)).filter fun β =>
      ∀ k, α k = β k + (if k = i then 1 else 0) + (if k = j then 1 else 0)

theorem mem_hessianChannelSupport_iff {S : Finset (Fin n → ℕ)}
    {i j : Fin n} {β : Fin n → ℕ} :
    β ∈ hessianChannelSupport S i j ↔
    ∃ α ∈ S, ∀ k, α k = β k + (if k = i then 1 else 0) + (if k = j then 1 else 0) := by
  simp only [hessianChannelSupport, mem_biUnion, mem_filter, Fintype.mem_piFinset, mem_range]
  constructor
  · rintro ⟨α, hα, hrange, hspec⟩; exact ⟨α, hα, hspec⟩
  · rintro ⟨α, hα, hspec⟩
    exact ⟨α, hα, fun k => by have := hspec k; omega, hspec⟩

/-! ## Shadow-Channel Equivalence (Theorem 1) -/

/-
**Shadow Coverage Theorem.**
An exponent vector `β` lies in the second shadow of `S` if and only if
there exist derivative indices `i, j` such that `β` appears in the
`(i,j)`-channel of the Hessian support. This bridges combinatorial
shadow structure to differentiation semantics.
-/
theorem mem_secondShadow_iff_exists_hessian_channel
    {β : Fin n → ℕ} {S : Finset (Fin n → ℕ)} :
    β ∈ secondShadow S ↔
    ∃ i j : Fin n, β ∈ hessianChannelSupport S i j := by
  simp +decide [ mem_secondShadow_iff, mem_hessianChannelSupport_iff ];
  exact ⟨ fun ⟨ α, hα, i, j, h ⟩ => ⟨ i, j, α, hα, h ⟩, fun ⟨ i, j, α, hα, h ⟩ => ⟨ α, hα, i, j, h ⟩ ⟩

/-! ## Monotonicity -/

/-
The second shadow is monotone: if `S ⊆ T`, then `Sh₂(S) ⊆ Sh₂(T)`.
-/
theorem secondShadow_mono {S T : Finset (Fin n → ℕ)} (h : S ⊆ T) :
    secondShadow S ⊆ secondShadow T := by
  intro β hβ;
  exact mem_secondShadow_iff.mpr ( by obtain ⟨ α, hα₁, hα₂ ⟩ := mem_secondShadow_iff.mp hβ; exact ⟨ α, h hα₁, hα₂ ⟩ )

/-! ## Support Circuit Model -/

/-- A **support circuit** is an abstract model of a circuit that computes
exponent vectors for Hessian entries. It has a `size` (number of gates)
and produces output exponents for each derivative channel `(i,j)`.

The key constraint is that each channel's output set has cardinality
bounded by the circuit size — each gate can produce at most one
exponent per channel. -/
structure SupportCircuit (n : ℕ) where
  /-- Number of gates in the circuit -/
  size : ℕ
  /-- Output exponents for each derivative channel (i,j) -/
  channelOutputs : Fin n → Fin n → Finset (Fin n → ℕ)
  /-- Each channel's output is bounded by the circuit size -/
  channel_size_bound : ∀ i j, (channelOutputs i j).card ≤ size

/-- A support circuit **computes the Hessian support** of `S` if for each
derivative channel `(i,j)`, the channel-specific shadow is contained in
the circuit's output for that channel. -/
def ComputesHessianSupport (S : Finset (Fin n → ℕ)) (C : SupportCircuit n) : Prop :=
  ∀ i j, hessianChannelSupport S i j ⊆ C.channelOutputs i j

/-! ## Second Shadow as Channel Union -/

/-
The second shadow equals the union of all per-channel supports.
This is the structural lemma connecting the global shadow to channel-specific views.
-/
theorem secondShadow_eq_biUnion_channels (S : Finset (Fin n → ℕ)) :
    secondShadow S =
    Finset.univ.biUnion fun ij : Fin n × Fin n =>
      hessianChannelSupport S ij.1 ij.2 := by
  ext β; simp [secondShadow, hessianChannelSupport];
  constructor <;> intro h;
  · rcases h with ⟨ a, ha, h₁, h₂ ⟩ ; rcases h₂ with ⟨ i, j, h₃ ⟩ ; exact ⟨ i, j, a, ha, h₁, h₃ ⟩ ;
  · rcases h with ⟨ i, j, α, hα, hβ, hαβ ⟩ ; exact ⟨ α, hα, hβ, i, j, hαβ ⟩ ;

/-! ## Circuit Lower Bound (Theorem 2) -/

/-
**Shadow-to-Complexity Lower Bound.**
Any support circuit computing all Hessian channels must have size at least
`|Sh₂(S)| / n²`. Equivalently, `|Sh₂(S)| ≤ n² · circuit_size`.

This is the first rigorous "shadow-to-complexity" theorem: a combinatorial
invariant of the exponent support directly yields a lower bound on
symbolic differentiation complexity.

The proof proceeds by:
1. Expressing the second shadow as a union of `n²` channel-specific sets
2. Bounding each channel set by the circuit's output for that channel
3. Using the circuit's size bound to conclude
-/
theorem supportCircuit_hessian_lower_bound
    (S : Finset (Fin n → ℕ)) (C : SupportCircuit n)
    (hC : ComputesHessianSupport S C) :
    (secondShadow S).card ≤ n ^ 2 * C.size := by
  -- By definition of `secondShadow`, it can be written as a union of per-channel supports.
  have h_union : (secondShadow S).card ≤ ∑ ij : Fin n × Fin n, (hessianChannelSupport S ij.1 ij.2).card := by
    rw [ secondShadow_eq_biUnion_channels ];
    convert Finset.card_biUnion_le;
  refine le_trans h_union ?_;
  refine' le_trans ( Finset.sum_le_sum fun _ _ => Finset.card_le_card <| hC _ _ ) _;
  exact le_trans ( Finset.sum_le_sum fun _ _ => C.channel_size_bound _ _ ) ( by norm_num [ sq, Finset.card_univ ] )

/-- Rearranged form: circuit size is at least the shadow cardinality
divided by `n²`. -/
theorem supportCircuit_size_ge_div
    (S : Finset (Fin n → ℕ)) (C : SupportCircuit n)
    (hC : ComputesHessianSupport S C) :
    (secondShadow S).card / n ^ 2 ≤ C.size := by
  have h := supportCircuit_hessian_lower_bound S C hC
  exact Nat.div_le_of_le_mul h

/-! ## Discrete Polytope Erosion (Theorem 4) -/

/-- **Discrete polytope erosion** by the degree-2 simplex: all exponent
vectors `β` such that `β + eᵢ + eⱼ ∈ S` for some `i, j`.  -/
def polytopeErosion2 (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.biUnion fun α =>
    (Fintype.piFinset fun k => Finset.range (α k + 1)).filter fun β =>
      ∃ i j : Fin n, ∀ k,
        α k = β k + (if k = i then 1 else 0) + (if k = j then 1 else 0)

/-- **Cross-Domain Theorem.** The second shadow equals the discrete polytope
erosion by the degree-2 simplex. This connects arithmetic circuit complexity
to discrete convex geometry: the shadow lower bound is a Newton-polytope
erosion invariant. -/
theorem secondShadow_eq_discreteErosion (S : Finset (Fin n → ℕ)) :
    secondShadow S = polytopeErosion2 S := by
  ext β
  simp only [secondShadow, polytopeErosion2, mem_biUnion, mem_filter,
    Fintype.mem_piFinset, mem_range, InSecondShadowOf]

/-! ## Explicit Family: Simplex Support -/

/-- The simplex support: all exponent vectors in `ℕᵈ` summing to exactly `m`.
These are the monomials of a generic homogeneous polynomial of degree `m`. -/
noncomputable def simplexSupport (d m : ℕ) : Finset (Fin d → ℕ) :=
  (Fintype.piFinset fun _ => Finset.range (m + 1)).filter fun α => ∑ i, α i = m

theorem mem_simplexSupport_iff {d m : ℕ} {α : Fin d → ℕ} :
    α ∈ simplexSupport d m ↔ (∀ i, α i ≤ m) ∧ ∑ i, α i = m := by
  simp +decide [ simplexSupport ]

/-
For `m ≥ 2`, the second shadow of the degree-`m` simplex support equals
the degree-`(m-2)` simplex support. This gives a clean structural recursion
on the homogeneous degree.
-/
theorem secondShadow_simplexSupport {d : ℕ} {m : ℕ} (hd : 1 ≤ d) (hm : 2 ≤ m) :
    secondShadow (simplexSupport d m) = simplexSupport d (m - 2) := by
  ext β; simp [secondShadow, simplexSupport];
  constructor <;> intro h;
  · obtain ⟨ α, hα₁, hα₂, hα₃ ⟩ := h; rcases hα₃ with ⟨ i, j, hα₃ ⟩ ; simp_all +decide [ Finset.sum_add_distrib ] ;
    exact ⟨ fun k => Nat.le_sub_of_add_le ( by linarith [ hα₁.1 k, Finset.single_le_sum ( fun a _ => Nat.zero_le ( β a ) ) ( Finset.mem_univ k ) ] ), eq_tsub_of_add_eq ( by linarith ) ⟩;
  · use fun i => β i + (if i = ⟨0, by omega⟩ then 1 else 0) + (if i = ⟨0, by omega⟩ then 1 else 0);
    simp_all +decide [ Finset.sum_add_distrib, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
    exact ⟨ ⟨ fun i => by split_ifs <;> linarith [ h.1 i, Nat.sub_add_cancel hm ], by omega ⟩, fun i => by split_ifs <;> linarith, ⟨ ⟨ 0, hd ⟩, ⟨ 0, hd ⟩, fun i => by aesop ⟩ ⟩

end ShadowComplexity