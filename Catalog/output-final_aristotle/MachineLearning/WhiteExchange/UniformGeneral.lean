/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import MachineLearning.WhiteExchange.Basic
import MachineLearning.WhiteExchange.Uniform
import MachineLearning.WhiteExchange.Part3

/-!
# Uniform matroids realize *all* quadratic exchanges

`Uniform.lean` showed that in a uniform matroid every *symmetric exchange* (swap
one element between two bases) is a legal basis-preserving quadratic move.  This
file proves the much stronger statement that in a uniform matroid **every**
element-preserving reconfiguration of two bases is legal — i.e. uniform matroids
saturate the quadratic-exchange relation.

## Main results

* `uniform_redistribute` — *the realization theorem.*  Given two bases
  `B₁, B₂` of `U_{r,n}` and any `r`-subset `C₁` of their union that contains their
  intersection, there is a complementary `r`-subset `C₂` with
  `B₁.val + B₂.val = C₁.val + C₂.val`.  Thus every admissible first half of a
  redistribution extends to a full legal quadratic move.

* `uniform_redistribute_rreachable` — the corresponding reachability statement.

* `uniform_whitePart3_two` — **White's Part 3 for two-basis uniform
  configurations of arbitrary rank**: any two two-basis configurations of
  `U_{r,n}` with the same total multiset union are connected by a single
  basis-preserving quadratic move.

## Lab Notes

`-- !-- Lab Notes -- !--`

* **Hypothesis.**  Uniform matroids are so flexible that the symmetric-exchange
  restriction is unnecessary: *any* split of the combined `2r` elements of two
  bases into two `r`-subsets is realizable, provided repeated elements (the
  intersection) are split one to each side.

* **Experiment.**  The complementary set is
  `C₂ = (B₁ ∪ B₂) \ (C₁ \ (B₁ ∩ B₂))`.  Verified on small cases that the
  multiset equation `B₁.val + B₂.val = C₁.val + C₂.val` and `C₂.card = r` hold.

* **Analysis.**  The multiset equation is an inclusion–exclusion identity:
  `B₁.val + B₂.val = (B₁ ∪ B₂).val + (B₁ ∩ B₂).val`, then the two chosen halves
  redistribute these counts.

* **Critique.**  The intersection-splitting hypothesis `B₁ ∩ B₂ ⊆ C₁` is exactly
  the necessary condition: a repeated element must appear once on each side, so it
  must be present in `C₁`.

* **Synthesis.**  A complete description of the one-step uniform quadratic-exchange
  neighbourhood, from which the two-basis case of White's conjecture follows for
  every rank.
-/

open Finset

namespace WhiteExchange

variable {n : ℕ}

/-
**Realization theorem for uniform matroids.**  If `B₁, B₂` are `r`-subsets and
`C₁` is any `r`-subset with `B₁ ∩ B₂ ⊆ C₁ ⊆ B₁ ∪ B₂`, then the complementary set
`C₂ := (B₁ ∪ B₂) \ (C₁ \ (B₁ ∩ B₂))` is again an `r`-subset with the same combined
element-multiset, so `(B₁, B₂) ↦ (C₁, C₂)` is a legal quadratic move.
-/
theorem uniform_redistribute {r : ℕ} (B₁ B₂ C₁ : Finset (Fin n))
    (hB₁ : B₁.card = r) (hB₂ : B₂.card = r) (hC₁ : C₁.card = r)
    (hsub : C₁ ⊆ B₁ ∪ B₂) (hcap : B₁ ∩ B₂ ⊆ C₁) :
    ∃ C₂ : Finset (Fin n), C₂.card = r ∧ C₂ ⊆ B₁ ∪ B₂ ∧
      B₁.val + B₂.val = C₁.val + C₂.val := by
  refine' ⟨ ( B₁ ∪ B₂ ) \ ( C₁ \ ( B₁ ∩ B₂ ) ), _, _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff ];
  · rw [ Finset.card_sdiff ];
    rw [ show C₁ \ ( B₁ ∩ B₂ ) ∩ ( B₁ ∪ B₂ ) = C₁ \ ( B₁ ∩ B₂ ) from ?_ ];
    · rw [ Finset.card_sdiff ];
      rw [ show B₁ ∩ B₂ ∩ C₁ = B₁ ∩ B₂ from ?_, Finset.card_union ];
      · rw [ Nat.sub_sub, tsub_eq_of_eq_add ];
        rw [ Nat.add_sub_of_le ];
        · grind;
        · exact Finset.card_le_card fun x hx => hcap ( Finset.mem_of_mem_inter_left hx ) ( Finset.mem_of_mem_inter_right hx );
      · grind;
    · grind;
  · ext x
    by_cases hx₁ : x ∈ B₁ <;> by_cases hx₂ : x ∈ B₂ <;> by_cases hx₃ : x ∈ C₁ <;>
      simp_all +decide [ Multiset.count_add, B₁.nodup, B₂.nodup, C₁.nodup ]
    all_goals grind

/-- The realization theorem as a reachability statement: any admissible
redistribution of two uniform bases is a single basis-preserving move. -/
theorem uniform_redistribute_rreachable {r : ℕ} (B₁ B₂ C₁ : Finset (Fin n))
    (rest : Multiset (Finset (Fin n)))
    (hB₁ : B₁.card = r) (hB₂ : B₂.card = r) (hC₁ : C₁.card = r)
    (hsub : C₁ ⊆ B₁ ∪ B₂) (hcap : B₁ ∩ B₂ ⊆ C₁) :
    ∃ C₂ : Finset (Fin n), C₂.card = r ∧
      RReachable (IsUniformBasis r) (B₁ ::ₘ B₂ ::ₘ rest) (C₁ ::ₘ C₂ ::ₘ rest) := by
  obtain ⟨C₂, hcard, _, hval⟩ := uniform_redistribute B₁ B₂ C₁ hB₁ hB₂ hC₁ hsub hcap
  exact ⟨C₂, hcard, reconfig_two_bases_rreachable rest B₁ B₂ C₁ C₂ hval hC₁ hcard⟩

/-- **White's Part 3 for two-basis uniform configurations (any rank).**  Any two
two-basis configurations of `U_{r,n}` with the same total multiset union are
connected by a single basis-preserving quadratic move.

The hypothesis `hC` (that the source `C` is itself a configuration of bases) is
part of the faithful statement of White's conjecture — both operands are multisets
of bases — but it is not needed for the proof, since one quadratic move only
requires the *target* bases to lie in the family. -/
theorem uniform_whitePart3_two {r : ℕ} {C D : Multiset (Finset (Fin n))}
    (hCcard : C.card = 2) (hDcard : D.card = 2)
    (hC : SupportedOn (IsUniformBasis r) C) (hD : SupportedOn (IsUniformBasis r) D)
    (hCD : unionMS C = unionMS D) :
    RReachable (IsUniformBasis r) C D := by
  obtain ⟨B₁, B₂, hCeq⟩ := Multiset.card_eq_two.mp hCcard
  obtain ⟨C₁, C₂, hDeq⟩ := Multiset.card_eq_two.mp hDcard
  subst hCeq hDeq
  have hC₁ : IsUniformBasis r C₁ := hD C₁ (by simp)
  have hC₂ : IsUniformBasis r C₂ := hD C₂ (by simp)
  have hval : B₁.val + B₂.val = C₁.val + C₂.val := by
    simpa only [unionMS, Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton,
      Multiset.sum_cons, Multiset.sum_singleton] using hCD
  exact reconfig_two_bases_rreachable 0 B₁ B₂ C₁ C₂ hval hC₁ hC₂

end WhiteExchange