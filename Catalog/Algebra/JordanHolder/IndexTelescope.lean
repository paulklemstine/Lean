/-
# Subgroup-index telescope for finite monotone chains

This file proves an elementary "telescope" identity for the relative indices of a
finite monotone chain of subgroups

  `H 0 ≤ H 1 ≤ … ≤ H n`

inside a group `G`.  For each adjacent inclusion `H i ≤ H (i+1)` one forms the
*relative subgroup* `(H i.castSucc).subgroupOf (H i.succ)` living inside
`H (i+1)`; its index is the relative index `[H_{i+1} : H_i]`, which in Mathlib is
`Subgroup.relIndex (H i.castSucc) (H i.succ)` and is *definitionally equal* to
`((H i.castSucc).subgroupOf (H i.succ)).index`.

The main results are:

* `relIndex_prod_telescope`     : `∏ i, [H_{i+1} : H_i] = [H_n : H_0]`;
* `index_prod_telescope`        : `(∏ i, [H_{i+1} : H_i]) * [G : H_n] = [G : H_0]`;
* `card_telescope`              : `Nat.card H_n = Nat.card H_0 * ∏ i, [H_{i+1} : H_i]`;
* `prod_relIndex_eq_index_of_top` : if `H_n = ⊤` then `∏ i, [H_{i+1} : H_i] = [G : H_0]`;
* `prod_relIndex_eq_card_of_bot_top` : if moreover `H_0 = ⊥` then the product is `Nat.card G`.

**Deliberately non-circular.**  This is a *foundational* component intended to be
reused by a future Jordan–Hölder formalization.  It is **not** a proof of the
Jordan–Hölder theorem and uses *no* Jordan–Hölder machinery whatsoever: no
`CompositionSeries.jordan_holder`, no theorem named `jordan_holder`, and no
`JordanHolderLattice` instance for subgroups.  The proofs rely only on the
elementary multiplicativity of the subgroup index already in Mathlib
(`Subgroup.relIndex_mul_relIndex`, `Subgroup.relIndex_mul_index`,
`Subgroup.card_mul_index`).  No theorem in this file is recursive: the only
induction is the structural induction on the chain length `n` inside
`relIndex_prod_telescope`, which calls only its own inductive hypothesis on a
*strictly shorter* chain, and every other result is a non-recursive consequence.
-/

import Mathlib

open scoped BigOperators

namespace JordanHolder.IndexTelescope

variable {G : Type*} [Group G]

/-
**Core telescope lemma.**  For a monotone chain `H : Fin (n+1) → Subgroup G`,
the product of the adjacent relative indices `[H_{i+1} : H_i]` collapses to the
single relative index `[H_n : H_0]`.

The proof is by structural induction on `n`, splitting the product with
`Fin.prod_univ_castSucc`, applying the inductive hypothesis to the truncated
chain `H ∘ Fin.castSucc`, and gluing the final step with
`Subgroup.relIndex_mul_relIndex`.
-/
theorem relIndex_prod_telescope (n : ℕ) (H : Fin (n + 1) → Subgroup G)
    (hmono : Monotone H) :
    (∏ i : Fin n, (H i.castSucc).relIndex (H i.succ)) = (H 0).relIndex (H (Fin.last n)) := by
  induction' n with n ih;
  · simp +decide [ Fin.eq_zero ];
  · specialize ih ( fun i ↦ H i.castSucc ) ( fun i j hij ↦ hmono hij ) ; simp_all +decide [ Fin.prod_univ_castSucc ] ;
    convert Subgroup.relIndex_mul_relIndex ( H 0 ) ( H ( Fin.last n |> Fin.castSucc ) ) ( H ( Fin.last ( n + 1 ) ) ) ( hmono ( Nat.zero_le _ ) ) ( hmono ( Fin.le_last _ ) ) using 1

/-
The index telescope: the product of relative indices times the terminal global
index equals the initial global index:
`(∏ i, [H_{i+1} : H_i]) * [G : H_n] = [G : H_0]`.
-/
theorem index_prod_telescope (n : ℕ) (H : Fin (n + 1) → Subgroup G)
    (hstep : ∀ i : Fin n, H i.castSucc ≤ H i.succ) :
    (∏ i : Fin n, (H i.castSucc).relIndex (H i.succ)) * (H (Fin.last n)).index
      = (H 0).index := by
  have hmono : Monotone H := Fin.monotone_iff_le_succ.mpr hstep;
  have := @relIndex_prod_telescope G _ n H hmono;
  rw [ this, Subgroup.relIndex_mul_index ( hmono ( Fin.zero_le _ ) ) ]

/-
The cardinality form of the telescope (no finiteness needed; both sides may be
`0` when infinite):
`Nat.card H_n = Nat.card H_0 * ∏ i, [H_{i+1} : H_i]`.
-/
theorem card_telescope (n : ℕ) (H : Fin (n + 1) → Subgroup G)
    (hstep : ∀ i : Fin n, H i.castSucc ≤ H i.succ) :
    Nat.card (H (Fin.last n)) =
      Nat.card (H 0) * ∏ i : Fin n, (H i.castSucc).relIndex (H i.succ) := by
  have hmono : Monotone H := Fin.monotone_iff_le_succ.mpr hstep
  have hle : H 0 ≤ H (Fin.last n) := hmono (Fin.zero_le _)
  rw [ relIndex_prod_telescope n H hmono, ← Nat.card_congr ( Subgroup.subgroupOfEquivOfLe hle ).toEquiv ];
  rw [ ← Subgroup.card_mul_index ];
  congr! 1

/-
If the chain reaches the whole group (`H_n = ⊤`), the product of relative
indices equals the global index `[G : H_0]`.
-/
theorem prod_relIndex_eq_index_of_top (n : ℕ) (H : Fin (n + 1) → Subgroup G)
    (hstep : ∀ i : Fin n, H i.castSucc ≤ H i.succ) (htop : H (Fin.last n) = ⊤) :
    (∏ i : Fin n, (H i.castSucc).relIndex (H i.succ)) = (H 0).index := by
  rw [ ← index_prod_telescope n H hstep ] ; simp +decide [ htop ]

/-
If the chain starts at the trivial subgroup and reaches the whole group
(`H_0 = ⊥`, `H_n = ⊤`), the product of relative indices equals `Nat.card G`.
-/
theorem prod_relIndex_eq_card_of_bot_top (n : ℕ) (H : Fin (n + 1) → Subgroup G)
    (hstep : ∀ i : Fin n, H i.castSucc ≤ H i.succ)
    (hbot : H 0 = ⊥) (htop : H (Fin.last n) = ⊤) :
    (∏ i : Fin n, (H i.castSucc).relIndex (H i.succ)) = Nat.card G := by
  convert prod_relIndex_eq_index_of_top n H hstep htop using 1;
  rw [ hbot, Subgroup.index_bot ]

end JordanHolder.IndexTelescope