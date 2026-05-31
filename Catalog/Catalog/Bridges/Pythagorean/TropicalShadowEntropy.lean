/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.IteratedShadowGeometry

/-!
# Tropical Differential Entropy via Newton Shadows

This file develops a theory of **discrete tropical entropy flow** for finite lattice
supports under iterated shadow operators. The central result is that for downward-closed
supports, Newton support erosion obeys an **entropy dissipation law**: the shadow entropy
is antitone, has finite lifetime, and the shadow operation preserves downward-closedness.

## Main Definitions

* `DownwardClosed` — A finite support is downward-closed (order-ideal) if whenever `a ∈ S`
  and `b ≤ a` coordinatewise, then `b ∈ S`.
* `shadowCard` — The cardinality of the `k`-th shadow: `|Sh_k(S)|`.
* `shadowEntropyPos` — The tropical shadow entropy: `log(|Sh_k(S)| + 1)`.
* `shadowEntropyDrop` — The entropy drop: `H(k+1) - H(k)`.
* `supportMaxDeg` — The maximum total mass in a support set.
* `degreeLayerCard` — The number of elements of a given total mass.

## Main Results

* `kthShadow_antitone_of_downwardClosed` — For downward-closed `S`, the shadow is
  antitone: `k₁ ≤ k₂ → kthShadow S k₂ ⊆ kthShadow S k₁`.
* `shadowCard_antitone_of_downwardClosed` — Shadow cardinality is antitone.
* `shadowEntropyPos_antitone_of_downwardClosed` — Shadow entropy is antitone.
* `downwardClosed_kthShadow` — The shadow of a downward-closed set is downward-closed.
* `kthShadow_eq_empty_of_supportMaxDeg_lt` — After exceeding the max degree, the shadow
  vanishes (finite extinction).
* `shadowEntropyPos_eventually_zero` — Shadow entropy eventually reaches zero.

## References

Builds on `IteratedShadowGeometry.lean`, especially `kthShadow_add`, `kthShadow_mono`,
and `kthShadow_eq_empty_of_large`.
-/

open IteratedShadowGeometry Finset BigOperators

noncomputable section

namespace TropicalShadowEntropy

variable {n : ℕ}

/-! ## Core Definitions -/

/-- A finite support `S` is **downward-closed** (an order ideal) if whenever `a ∈ S`
and `b ≤ a` coordinatewise, then `b ∈ S`. This is the discrete analogue of a
monomial ideal complement, and is the natural setting for shadow entropy theory. -/
def DownwardClosed (S : Finset (Fin n →₀ ℕ)) : Prop :=
  ∀ ⦃a b : Fin n →₀ ℕ⦄, a ∈ S → b ≤ a → b ∈ S

/-- The **shadow cardinality** at step `k`: the number of lattice points in the `k`-th shadow. -/
def shadowCard (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : ℕ :=
  (kthShadow S k).card

/-- The **tropical shadow entropy** with the `+1` convention for unconditional theorems:
`H_S(k) = log(|Sh_k(S)| + 1)`. This ensures `H_S(k) ≥ 0` always, and `H_S(k) = 0`
iff the shadow is empty. -/
def shadowEntropyPos (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : ℝ :=
  Real.log ((shadowCard S k : ℝ) + 1)

/-- The **entropy drop** at step `k`: the change in entropy from step `k` to `k+1`. -/
def shadowEntropyDrop (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : ℝ :=
  shadowEntropyPos S (k + 1) - shadowEntropyPos S k

/-- The **maximum total mass** in a support set. Returns 0 for the empty set. -/
def supportMaxDeg (S : Finset (Fin n →₀ ℕ)) : ℕ :=
  S.sup (fun α => totalMass α)

/-- The **degree layer cardinality**: number of elements with a given total mass. -/
def degreeLayerCard (S : Finset (Fin n →₀ ℕ)) (t : ℕ) : ℕ :=
  (S.filter (fun u => totalMass u = t)).card

/-! ## Downward-Closed Support Properties -/

/-- The empty set is trivially downward-closed. -/
theorem downwardClosed_empty : DownwardClosed (∅ : Finset (Fin n →₀ ℕ)) := by
  intro a b ha; simp at ha

/-- A singleton containing 0 is downward-closed. -/
theorem downwardClosed_singleton_zero :
    DownwardClosed ({0} : Finset (Fin n →₀ ℕ)) := by
  intro a b ha hba
  rw [Finset.mem_singleton] at ha ⊢
  subst ha
  exact le_antisymm hba (zero_le b)

/-! ## Antitone Shadow Inclusion for Downward-Closed Sets -/

/-
**Key structural theorem**: For downward-closed sets, the shadow is antitone
in the step parameter. If `k₁ ≤ k₂`, then `kthShadow S k₂ ⊆ kthShadow S k₁`.

The proof uses the splitting lemma from the catalog: if `totalMass(α - β) = k₂ ≥ k₁`,
we can split `α - β` into two parts, one of mass `k₁`, giving a witness `α'` with
`β ≤ α' ≤ α` and `totalMass(α' - β) = k₁`. Since `S` is downward-closed and `α ∈ S`,
we have `α' ∈ S`, proving `β ∈ kthShadow S k₁`.
-/
theorem kthShadow_antitone_of_downwardClosed
    (S : Finset (Fin n →₀ ℕ)) (hS : DownwardClosed S)
    {k₁ k₂ : ℕ} (hk : k₁ ≤ k₂) :
    kthShadow S k₂ ⊆ kthShadow S k₁ := by
  intro β hβ; simp_all +decide [ kthShadow ] ;
  -- By the splitting lemma, we can split `a - β` into two parts, one of mass `k₁` and the other of mass `k₂ - k₁`.
  obtain ⟨τ₁, τ₂, hτ₁, hτ₂, hτ⟩ : ∃ τ₁ τ₂ : Fin n →₀ ℕ, τ₁ + τ₂ = (hβ.choose - β) ∧ totalMass τ₁ = k₁ ∧ totalMass τ₂ = k₂ - k₁ := by
    convert finsupp_totalMass_split ( hβ.choose - β ) k₁ ( k₂ - k₁ ) _ using 1 ; linarith [ hβ.choose_spec.2.2, Nat.sub_add_cancel hk ];
  refine' ⟨ β + τ₁, hS _ _, _, _ ⟩;
  exact hβ.choose;
  · exact hβ.choose_spec.1;
  · convert add_le_add_left ( show τ₁ ≤ hβ.choose - β from hτ₁ ▸ le_add_right le_rfl ) β using 1;
    · exact add_comm _ _;
    · rw [ tsub_add_cancel_of_le hβ.choose_spec.2.1 ];
  · exact le_add_right le_rfl;
  · rw [ add_tsub_cancel_left, hτ₂ ]

/-
Shadow cardinality is antitone for downward-closed sets.
-/
theorem shadowCard_antitone_of_downwardClosed
    (S : Finset (Fin n →₀ ℕ)) (hS : DownwardClosed S) :
    Antitone (shadowCard S) := by
  exact fun k₁ k₂ hk => Finset.card_le_card <| kthShadow_antitone_of_downwardClosed S hS hk

/-
Shadow entropy is antitone for downward-closed sets: the thermodynamic arrow of time.
-/
theorem shadowEntropyPos_antitone_of_downwardClosed
    (S : Finset (Fin n →₀ ℕ)) (hS : DownwardClosed S) :
    Antitone (shadowEntropyPos S) := by
  exact fun k₁ k₂ hk => Real.log_le_log ( by positivity ) ( by exact_mod_cast Nat.succ_le_succ <| shadowCard_antitone_of_downwardClosed S hS hk )

/-! ## Downward-Closedness is Preserved by Shadows -/

/-
The shadow of a downward-closed set is downward-closed. This is a structural
preservation theorem: the "order ideal" property is an invariant of the shadow flow.

Proof sketch: if `β ∈ kthShadow S k` and `γ ≤ β`, we need `γ ∈ kthShadow S k`.
From `β ∈ kthShadow S k`, there exists `α ∈ S` with `β ≤ α` and `totalMass(α - β) = k`.
Since `γ ≤ β ≤ α`, we have `totalMass(α - γ) = totalMass(α - β) + totalMass(β - γ) ≥ k`.
By the splitting lemma, we find `α'` with `γ ≤ α' ≤ α` and `totalMass(α' - γ) = k`.
Since `S` is downward-closed, `α' ∈ S`, so `γ ∈ kthShadow S k`.
-/
theorem downwardClosed_kthShadow
    (S : Finset (Fin n →₀ ℕ)) (hS : DownwardClosed S) (k : ℕ) :
    DownwardClosed (kthShadow S k) := by
  intro β γ hβ hγβ;
  obtain ⟨ α, hαS, hβα, hαβ ⟩ := mem_kthShadow_iff.mp hβ;
  -- By the splitting lemma, we find `α'` with `γ ≤ α' ≤ α` and `totalMass(α' - γ) = k`.
  obtain ⟨ α', hα'γ, hα'α, hα'γk ⟩ : ∃ α' : Fin n →₀ ℕ, γ ≤ α' ∧ α' ≤ α ∧ totalMass (α' - γ) = k := by
    have h_split : ∃ τ₁ τ₂ : Fin n →₀ ℕ, τ₁ + τ₂ = α - γ ∧ totalMass τ₁ = k ∧ totalMass τ₂ = totalMass (α - γ) - k := by
      have h_split : totalMass (α - γ) = totalMass (α - β) + totalMass (β - γ) := by
        convert totalMass_tsub_add hγβ hβα using 1;
      exact ⟨ α - β, β - γ, by rw [ tsub_add_tsub_cancel hβα hγβ ], hαβ, by aesop ⟩;
    obtain ⟨ τ₁, τ₂, h₁, h₂, h₃ ⟩ := h_split; use γ + τ₁; simp_all +decide [ Finsupp.le_def ] ;
    intro i; replace h₁ := congr_arg ( fun x => x i ) h₁; simp_all +decide ;
    linarith [ Nat.sub_add_cancel ( show γ i ≤ α i from le_trans ( hγβ i ) ( hβα i ) ) ];
  exact mem_kthShadow_iff.mpr ⟨ α', hS hαS hα'α, hα'γ, hα'γk ⟩

/-! ## Finite Extinction -/

/-
The shadow vanishes when `k` exceeds the maximum total mass.
This identifies tropical entropy dissipation as a finite-time extinction phenomenon.
-/
theorem kthShadow_eq_empty_of_supportMaxDeg_lt
    (S : Finset (Fin n →₀ ℕ)) {k : ℕ}
    (hk : supportMaxDeg S < k) :
    kthShadow S k = ∅ := by
  apply kthShadow_eq_empty_of_large;
  exact fun α hα => lt_of_le_of_lt ( Finset.le_sup ( f := fun α => totalMass α ) hα ) hk

/-
Shadow entropy eventually reaches zero: the entropy flow has finite lifetime.
-/
theorem shadowEntropyPos_eventually_zero
    (S : Finset (Fin n →₀ ℕ)) :
    ∃ D, ∀ k, D ≤ k → shadowEntropyPos S k = 0 := by
  use S.sup ( fun α => α.sum fun _ m => m ) + 1;
  intro k hk;
  convert kthShadow_eq_empty_of_supportMaxDeg_lt S hk;
  constructor <;> intro h <;> simp_all +decide [ shadowEntropyPos, shadowCard ];
  exact h.resolve_left ( by linarith ) |> Or.resolve_right <| by linarith;

/-! ## Shadow Profile Algorithm -/

/-- Compute the full shadow cardinality profile up to extinction. -/
def shadowProfile (S : Finset (Fin n →₀ ℕ)) : List ℕ :=
  (List.range (supportMaxDeg S + 1)).map (shadowCard S)

/-
The shadow profile correctly computes shadow cardinalities.
-/
theorem shadowProfile_get (S : Finset (Fin n →₀ ℕ))
    (k : ℕ) (hk : k < supportMaxDeg S + 1) :
    (shadowProfile S).get ⟨k, by simp [shadowProfile]; omega⟩ = shadowCard S k := by
  unfold shadowProfile; aesop;

/-! ## Cross-Domain: kthShadow Subset for Downward-Closed Sets -/

/-
For downward-closed sets, the shadow is always a subset of the original set.
This connects to monomial ideal theory: the shadow of an order ideal is an order ideal
contained in the original.
-/
theorem kthShadow_subset_of_downwardClosed
    (S : Finset (Fin n →₀ ℕ)) (hS : DownwardClosed S) (k : ℕ) :
    kthShadow S k ⊆ S := by
  intro β hβ;
  obtain ⟨ α, hα, hβα, hαβ ⟩ := mem_kthShadow_iff.mp hβ; exact hS hα hβα;

/-- The shadow at step 0 equals the original set (from catalog, re-exported). -/
theorem shadowCard_zero (S : Finset (Fin n →₀ ℕ)) :
    shadowCard S 0 = S.card := by
  simp [shadowCard, kthShadow_zero]

/-- Shadow card of empty set is zero. -/
@[simp]
theorem shadowCard_empty (k : ℕ) :
    shadowCard (∅ : Finset (Fin n →₀ ℕ)) k = 0 := by
  simp [shadowCard]

/-! ## Entropy Drop Nonpositivity -/

/-
For downward-closed sets, the entropy drop is always nonpositive:
entropy can only decrease under the shadow flow.
-/
theorem shadowEntropyDrop_nonpos_of_downwardClosed
    (S : Finset (Fin n →₀ ℕ)) (hS : DownwardClosed S) (k : ℕ) :
    shadowEntropyDrop S k ≤ 0 := by
  exact sub_nonpos_of_le ( shadowEntropyPos_antitone_of_downwardClosed S hS k.le_succ )

end TropicalShadowEntropy