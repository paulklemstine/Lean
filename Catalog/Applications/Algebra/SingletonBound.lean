/-
Copyright (c) 2025. All rights reserved.

# The Singleton Bound for Block Codes

## Overview

This file proves the **Singleton bound** of coding theory inside the same
combinatorial framework as `Catalog/Tropical/SpherePackingBound.lean` and
`Catalog/Applications/GilbertVarshamov.lean` (words `ι → G`, Hamming metric):

      |C| ≤ qⁿ⁻ᵈ⁺¹       for any `d`-separated code `C ⊆ (ι → G)`,

where `n = |ι|`, `q = |G|`. Unlike the sphere-packing and Gilbert–Varshamov
bounds, the Singleton bound needs **no group structure on the alphabet** and no
ball-volume formula: it is a pure *projection-injectivity* argument.

## Main Results

* `restriction_injOn` — erasing `d-1` coordinates is injective on a `d`-separated
  code (two codewords differing in `≥ d` places cannot agree on `n-d+1` places).
* `singleton_bound` — `|C| ≤ qⁿ⁻ᵈ⁺¹`.

## Catalog Synthesis

Complements `SpherePackingBound.sphere_packing_bound` (upper bound via packing)
and `GilbertVarshamov.gilbert_varshamov` (lower bound via covering) with the
*third* classical bound — Singleton — completing the trio of elementary code-size
estimates over q-ary alphabets. The key technical hinge, that `hammingDist` is the
cardinality of the disagreement `Finset`, is shared with both companion files.

-- !-- Lab Notebook -- !--
Hypothesis: a metric separation hypothesis (min distance `≥ d`) can be converted
  into a cardinality bound by *projecting away* `d-1` coordinates injectively.
Result: proved `singleton_bound` (`|C| ≤ qⁿ⁻ᵈ⁺¹`) via `restriction_injOn` and
  `Finset.card_le_card_of_injOn`.
Insight: injectivity is immediate because if two codewords agreed on a set `T`
  with `|Tᶜ| ≤ d-1`, their disagreement set would sit inside `Tᶜ`, forcing
  `hammingDist < d` — contradicting separation. No alphabet structure is used.
Failure analysis: a naive "project onto the first `n-d+1` coordinates" stumbles on
  the abstract index type `ι`; the fix is `Finset.exists_subset_card_eq` to *pick*
  a coordinate set of the right size rather than relying on an ordering.
-/
import Mathlib

open Finset BigOperators

noncomputable section

namespace SingletonBound

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
variable {G : Type*} [Fintype G] [DecidableEq G]

/-- A code is `d`-**separated** if any two distinct codewords are at Hamming
    distance at least `d`. -/
def Separated (C : Finset (ι → G)) (d : ℕ) : Prop :=
  ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hammingDist x y

/-
!-- If `x, y ∈ C` agree on a coordinate set `T` whose complement has size `≤ d-1`,
then their disagreement set is contained in `Tᶜ`, so `hammingDist x y ≤ |Tᶜ| < d`,
contradicting `d`-separation; hence `x = y`. -- !--

**Restriction is injective.** On a `d`-separated code, restricting words to a
coordinate set `T` with `|Tᶜ| ≤ d - 1` is injective.
-/
omit [Fintype G] in
theorem restriction_injOn {C : Finset (ι → G)} {d : ℕ}
    (hsep : Separated C d) {T : Finset ι} (hT : Tᶜ.card ≤ d - 1) :
    Set.InjOn (fun x : ι → G => fun i : T => x i.1) (C : Set (ι → G)) := by
  intro x hx y hy hxy;
  by_contra hxy_ne;
  have h_dist : hammingDist x y ≤ Tᶜ.card := by
    refine' Finset.card_le_card _;
    intro i hi; contrapose! hi; simp_all +decide [ funext_iff ] ;
  exact not_lt_of_ge h_dist ( lt_of_le_of_lt hT ( Nat.pred_lt ( by specialize hsep x hx y hy hxy_ne; aesop ) ) |> lt_of_lt_of_le <| hsep x hx y hy hxy_ne )

/-
!-- Pick (via `Finset.exists_subset_card_eq`) a coordinate set `T` of size
`n-(d-1)`; its complement has size `d-1`, so `restriction_injOn` makes the
restriction `C → (T → G)` injective, whence `|C| ≤ |T → G| = q^{n-d+1}`. -- !--

**Singleton bound.** A `d`-separated code with `d - 1 ≤ n` has `|C| ≤ qⁿ⁻ᵈ⁺¹`.
(The classical statement also assumes `1 ≤ d`; this hypothesis turns out to be
unnecessary — with `ℕ` truncated subtraction the bound is vacuously `|C| ≤ qⁿ`
when `d = 0` — so we omit it for a strictly more general result.)
-/
theorem singleton_bound {C : Finset (ι → G)} {d : ℕ}
    (hdn : d - 1 ≤ Fintype.card ι) (hsep : Separated C d) :
    C.card ≤ (Fintype.card G) ^ (Fintype.card ι - (d - 1)) := by
  obtain ⟨T, hT⟩ : ∃ T : Finset ι, T.card = Fintype.card ι - (d - 1) := by
    exact Exists.imp ( by aesop ) ( Finset.exists_subset_card_eq ( show Fintype.card ι - ( d - 1 ) ≤ Fintype.card ι from Nat.sub_le _ _ ) );
  -- By restriction_injOn, the restriction map from C to T → G is injective.
  have h_inj : Set.InjOn (fun x : ι → G => fun i : T => x i.1) (C : Set (ι → G)) := by
    apply restriction_injOn hsep;
    simp +decide [ Finset.card_compl, * ];
  convert Finset.card_le_card ( show C.image ( fun x : ι → G => fun i : T => x i ) ⊆ Finset.univ from Finset.subset_univ _ ) using 1;
  · rw [ Finset.card_image_of_injOn h_inj ];
  · simp +decide [ ← hT ]

end SingletonBound
end