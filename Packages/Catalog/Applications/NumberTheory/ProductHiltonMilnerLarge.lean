/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Towards the product Hilton–Milner theorem

The **product Hilton–Milner problem** asks, for `n > 100·ℓ·k²` and `3 ≤ ℓ < k`:
if `F ⊆ ([n] choose k)` and `G ⊆ ([n] choose ℓ)` are *non-trivial*
(`⋂_{A∈F} A = ∅` and `⋂_{B∈G} B = ∅`) and *cross-intersecting*
(`A ∩ B ≠ ∅` for all `A∈F`, `B∈G`), must

    |F| · |G| ≤ h(n,k) · C(n-1, ℓ-1),

where `h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1` is the Hilton–Milner value?

The two deep ingredients of the sharp bound are the Hilton–Milner theorem
(the sharp upper bound `h(n,k)` on a non-trivial intersecting `k`-uniform family)
and the Erdős–Ko–Rado theorem (`C(n-1,ℓ-1)` for an intersecting `ℓ`-uniform
family).  The Hilton–Milner theorem is **not** in Mathlib.  This file develops,
fully and unconditionally, the surrounding structure:

* `crossIntersecting_prod_le` — the elementary *mixed-uniformity* cross-intersecting
  product bound `|F|·|G| ≤ (C(n,k)-C(n-ℓ,k)) · (C(n,ℓ)-C(n-k,ℓ))`.  Unlike the
  companion files (which handle a single uniformity `k`), this treats `k ≠ ℓ`.
* `intersecting_prod_le` — the Erdős–Ko–Rado product bound
  `|F|·|G| ≤ C(n-1,k-1)·C(n-1,ℓ-1)` for genuinely intersecting families, built on
  Mathlib's `Finset.erdos_ko_rado`.  This is the sharp product bound in the
  *trivial* (star) regime and isolates exactly the `C(n-1,ℓ-1)` factor of the
  target.
* `card_hiltonMilnerFamily` — the exact size of the canonical Hilton–Milner family
  (a fixed point `x`, a `k`-set `Y` avoiding `x`, all `k`-sets through `x` that meet
  `Y`, together with `Y` itself) is **exactly** `h(n,k)`.  This is the extremal
  configuration realising the `h(n,k)` factor of the product bound, and the identity
  `C(n-1,k-1) - C(n-k-1,k-1) + 1` is verified as a genuine cardinality computation.

Sharpening `crossIntersecting_prod_le` from the elementary counts down to the
Hilton–Milner product `h(n,k)·C(n-1,ℓ-1)` is precisely the content of the
Hilton–Milner theorem and is recorded as a future direction.
-/
import Mathlib

open Finset

namespace ProductHiltonMilner

variable {n : ℕ}

/-- `F` is `k`-uniform: every member has exactly `k` elements. -/
def IsUniform (k : ℕ) (F : Finset (Finset (Fin n))) : Prop := ∀ A ∈ F, A.card = k

/-- Two families are *cross-intersecting* if every member of one meets every
member of the other. -/
def CrossIntersecting (F G : Finset (Finset (Fin n))) : Prop :=
  ∀ A ∈ F, ∀ B ∈ G, (A ∩ B).Nonempty

/-- `F` is contained in a *star*: some fixed point lies in every member. -/
def IsStar (F : Finset (Finset (Fin n))) : Prop := ∃ x, ∀ A ∈ F, x ∈ A

/-- `F` is *non-trivial* if it is not contained in any star, equivalently
`⋂_{A∈F} A = ∅` (see `nonTrivial_iff_no_common_point`). -/
def NonTrivial (F : Finset (Finset (Fin n))) : Prop := ¬ IsStar F

/-- The Hilton–Milner value `h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1`. -/
def hm (n k : ℕ) : ℕ := Nat.choose (n - 1) (k - 1) - Nat.choose (n - k - 1) (k - 1) + 1

/-- Non-triviality is exactly the absence of a common point of the whole family,
i.e. `⋂_{A∈F} A = ∅`. -/
lemma nonTrivial_iff_no_common_point {F : Finset (Finset (Fin n))} :
    NonTrivial F ↔ ∀ x : Fin n, ∃ A ∈ F, x ∉ A := by
  simp only [NonTrivial, IsStar, not_exists, not_forall, exists_prop]

/-! ## The mixed-uniformity elementary product bound -/

/--
**Per-family meeting bound.** If `G` is `k`-uniform and every member meets a
fixed set `A₀` with `A₀.card = m`, then `|G| ≤ C(n,k) - C(n-m,k)` (the number of
`k`-subsets of `[n]` meeting a fixed `m`-set).
-/
lemma card_le_of_meets {k m : ℕ} {G : Finset (Finset (Fin n))}
    (hG : IsUniform k G) {A₀ : Finset (Fin n)} (hA₀ : A₀.card = m)
    (hmeet : ∀ B ∈ G, (A₀ ∩ B).Nonempty) :
    G.card ≤ Nat.choose n k - Nat.choose (n - m) k := by
  convert Finset.card_le_card _ using 1;
  case convert_3 => exact Finset.powersetCard k Finset.univ \ Finset.powersetCard k A₀ᶜ;
  · rw [ Finset.card_sdiff ] ; norm_num [ Finset.subset_iff, hA₀ ];
    rw [ Finset.inter_eq_left.mpr ( Finset.powersetCard_mono <| Finset.subset_univ _ ), Finset.card_powersetCard, Finset.card_compl, hA₀ ];
    rw [ Fintype.card_fin ];
  · intro B hB; specialize hmeet B hB; simp_all +decide [ Finset.subset_iff, Finset.mem_sdiff, Finset.mem_powersetCard ] ;
    exact ⟨ hG B hB, fun h => False.elim <| hmeet.elim fun x hx => h ( Finset.mem_of_mem_inter_right hx ) ( Finset.mem_of_mem_inter_left hx ) ⟩

/--
**Mixed-uniformity cross-intersecting product bound.** For a non-empty
`k`-uniform family `F` and a non-empty `ℓ`-uniform family `G` that are
cross-intersecting, `|F|·|G| ≤ (C(n,k)-C(n-ℓ,k))·(C(n,ℓ)-C(n-k,ℓ))`.
-/
theorem crossIntersecting_prod_le {k l : ℕ} {F G : Finset (Finset (Fin n))}
    (hF : IsUniform k F) (hG : IsUniform l G)
    (hFne : F.Nonempty) (hGne : G.Nonempty)
    (hcross : CrossIntersecting F G) :
    F.card * G.card ≤
      (Nat.choose n k - Nat.choose (n - l) k) * (Nat.choose n l - Nat.choose (n - k) l) := by
  gcongr;
  · convert card_le_of_meets hF _ _;
    exact Classical.choose hGne;
    · exact hG _ ( Classical.choose_spec hGne );
    · exact fun B hB => by simpa only [ Finset.inter_comm ] using hcross _ hB _ ( Classical.choose_spec hGne ) ;
  · obtain ⟨ A₀, hA₀ ⟩ := hFne;
    convert card_le_of_meets hG ( hF A₀ hA₀ ) _ using 1;
    exact fun B hB => hcross A₀ hA₀ B hB

/-! ## The Erdős–Ko–Rado product bound (sharp in the trivial regime) -/

/-- A `Finset`-level intersecting family gives a `Set.Intersecting` coercion,
so that Mathlib's `Finset.erdos_ko_rado` applies. -/
lemma coe_intersecting {F : Finset (Finset (Fin n))}
    (h : ∀ A ∈ F, ∀ B ∈ F, (A ∩ B).Nonempty) :
    (↑F : Set (Finset (Fin n))).Intersecting := by
  intro A hA B hB
  simp only [Finset.mem_coe] at hA hB
  rw [Finset.not_disjoint_iff_nonempty_inter]
  exact h A hA B hB

/--
**Erdős–Ko–Rado product bound.** For an intersecting `k`-uniform family `F`
and an intersecting `ℓ`-uniform family `G` with `k ≤ n/2` and `ℓ ≤ n/2`,
`|F|·|G| ≤ C(n-1,k-1)·C(n-1,ℓ-1)`.  This is the product bound in the star
(trivial) regime and exhibits the `C(n-1,ℓ-1)` factor of the target.
-/
theorem intersecting_prod_le {k l : ℕ} {F G : Finset (Finset (Fin n))}
    (hF : IsUniform k F) (hG : IsUniform l G)
    (hFi : ∀ A ∈ F, ∀ B ∈ F, (A ∩ B).Nonempty)
    (hGi : ∀ A ∈ G, ∀ B ∈ G, (A ∩ B).Nonempty)
    (hk : k ≤ n / 2) (hl : l ≤ n / 2) :
    F.card * G.card ≤ Nat.choose (n - 1) (k - 1) * Nat.choose (n - 1) (l - 1) := by
  apply_rules [ Nat.mul_le_mul ];
  · convert Finset.erdos_ko_rado ( coe_intersecting hFi ) _ hk using 1;
    exact fun x hx => hF x hx;
  · convert Finset.erdos_ko_rado ( coe_intersecting hGi ) _ hl using 1;
    exact fun x hx => hG x hx

/-! ## The extremal Hilton–Milner family and its exact size -/

/-- The canonical Hilton–Milner family for a point `x` and a `k`-set `Y` with
`x ∉ Y`: all `k`-sets that either contain `x` and meet `Y`, or equal `Y`. -/
def hiltonMilnerFamily (x : Fin n) (Y : Finset (Fin n)) : Finset (Finset (Fin n)) :=
  ((univ : Finset (Fin n)).powersetCard Y.card).filter
    (fun A => (x ∈ A ∧ (A ∩ Y).Nonempty) ∨ A = Y)

/--
**Counting `k`-subsets of a finset through a fixed element.** For `1 ≤ k` and
`a ∈ s`, the number of `k`-element subsets of `s` containing `a` is
`C(|s|-1, k-1)`.
-/
lemma card_powersetCard_filter_mem {s : Finset (Fin n)} {a : Fin n} (ha : a ∈ s)
    {k : ℕ} (hk : 1 ≤ k) :
    ((s.powersetCard k).filter (fun A => a ∈ A)).card = (s.card - 1).choose (k - 1) := by
  -- The sets `(s.powersetCard k).filter (a ∈ A)` and `(s.powersetCard k).filter (a ∉ A)` partition `s.powersetCard k`, so by `Finset.filter_card_add_filter_neg_card_eq_card` their cardinalities sum to `(s.powersetCard k).card = s.card.choose k` (using `Finset.card_powersetCard`).
  have h_partition : Finset.card ({A ∈ powersetCard k s | a ∈ A}) + Finset.card ({A ∈ powersetCard k s | a ∉ A}) = Nat.choose (s.card) k := by
    rw [ Finset.card_filter_add_card_filter_not, Finset.card_powersetCard ];
  -- The negative part equals `(s.erase a).powersetCard k`: indeed `A ∈ s.powersetCard k ∧ a ∉ A ↔ A ⊆ s ∧ A.card = k ∧ a ∉ A ↔ A ⊆ s.erase a ∧ A.card = k ↔ A ∈ (s.erase a).powersetCard k` (use `Finset.mem_powersetCard`, `Finset.subset_erase`).
  have h_negative : {A ∈ powersetCard k s | a ∉ A} = (s.erase a).powersetCard k := by
    grind;
  rcases k with ( _ | k ) <;> simp_all +decide [ add_comm ];
  rcases x : #s with ( _ | _ | s ) <;> simp_all +arith +decide [ Nat.choose ]

/--
**Exact size of the Hilton–Milner family.** For `1 ≤ k ≤ n`, a `k`-set `Y`
with `x ∉ Y`, the canonical Hilton–Milner family has cardinality exactly
`h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1`.
-/
theorem card_hiltonMilnerFamily {k : ℕ} (x : Fin n) {Y : Finset (Fin n)}
    (hY : Y.card = k) (hx : x ∉ Y) (hk : 1 ≤ k) (hkn : k ≤ n) :
    (hiltonMilnerFamily x Y).card = hm n k := by
  -- Let's split the set into two parts: those subsets that contain x and those that do not.
  have h_split : hiltonMilnerFamily x Y = ((univ : Finset (Fin n)).powersetCard k).filter (fun A => x ∈ A ∧ (A ∩ Y).Nonempty) ∪ {Y} := by
    grind +locals;
  -- Let's count the number of subsets that contain x and those that do not.
  have h_count : ((univ : Finset (Fin n)).powersetCard k).filter (fun A => x ∈ A ∧ (A ∩ Y).Nonempty) = ((univ : Finset (Fin n)).powersetCard k).filter (fun A => x ∈ A) \ ((Yᶜ : Finset (Fin n)).powersetCard k).filter (fun A => x ∈ A) := by
    ext; simp;
    simp +contextual [ Finset.subset_iff, Finset.Nonempty ];
    grind
  generalize_proofs at *; (
  rw [ h_split, h_count, Finset.card_union_of_disjoint ] <;> simp +decide [ Finset.disjoint_singleton_right ];
  · rw [ Finset.card_sdiff ] ; ring_nf;
    rw [ show ( Finset.filter ( fun A => x ∈ A ) ( Finset.powersetCard k Yᶜ ) ∩ Finset.filter ( fun A => x ∈ A ) ( Finset.powersetCard k Finset.univ ) ) = Finset.filter ( fun A => x ∈ A ) ( Finset.powersetCard k Yᶜ ) from ?_, show ( Finset.filter ( fun A => x ∈ A ) ( Finset.powersetCard k Finset.univ ) ) = Finset.filter ( fun A => x ∈ A ) ( Finset.powersetCard k Finset.univ ) from rfl ] ; rw [ card_powersetCard_filter_mem, card_powersetCard_filter_mem ] <;> norm_num [ Finset.card_compl, hY, hx, hk, hkn ] ; ring_nf;
    · unfold hm; ring;
    · grind;
  · aesop)

/--
The Hilton–Milner family is `k`-uniform.
-/
lemma hiltonMilnerFamily_uniform {k : ℕ} (x : Fin n) {Y : Finset (Fin n)}
    (hY : Y.card = k) : IsUniform k (hiltonMilnerFamily x Y) := by
  intro A hA; unfold hiltonMilnerFamily at hA; aesop;

/--
The Hilton–Milner family is intersecting.
-/
lemma hiltonMilnerFamily_intersecting (x : Fin n) {Y : Finset (Fin n)}
    (hYne : Y.Nonempty) :
    ∀ A ∈ hiltonMilnerFamily x Y, ∀ B ∈ hiltonMilnerFamily x Y, (A ∩ B).Nonempty := by
  unfold hiltonMilnerFamily; simp +decide [ Finset.Nonempty ] ;
  grind

/--
The Hilton–Milner family is non-trivial (`⋂ = ∅`): no single point lies in all
members.  `Y` (a member) excludes the star point `x`, and for any `p ∈ Y` the
member `insert x (Y.erase p)` (through `x`, meeting `Y`) excludes `p`.
-/
lemma hiltonMilnerFamily_nonTrivial {k : ℕ} (x : Fin n) {Y : Finset (Fin n)}
    (hY : Y.card = k) (hx : x ∉ Y) (hk : 2 ≤ k) :
    NonTrivial (hiltonMilnerFamily x Y) := by
  contrapose! hx;
  obtain ⟨ p, hp ⟩ := not_not.mp hx;
  unfold hiltonMilnerFamily at hp;
  contrapose! hp;
  by_cases hpY : p ∈ Y;
  · refine' ⟨ Insert.insert x ( Y.erase p ), _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff ];
    · exact ⟨ Nat.succ_pred_eq_of_pos ( pos_of_gt hk ), Or.inl <| Finset.one_lt_card.1 <| by linarith ⟩;
    · aesop;
  · grind

/--
**The Hilton–Milner value is attained.** For `2 ≤ k` and `k + 1 ≤ n`, there is
a `k`-uniform, intersecting, non-trivial family of subsets of `[n]` with exactly
`h(n,k)` members.  This is the extremal family that supplies the `h(n,k)` factor
in the product Hilton–Milner bound.
-/
theorem exists_nonTrivial_intersecting_uniform_card_eq_hm {k : ℕ}
    (hk : 2 ≤ k) (hn : k + 1 ≤ n) :
    ∃ F : Finset (Finset (Fin n)),
      IsUniform k F ∧ NonTrivial F ∧
      (∀ A ∈ F, ∀ B ∈ F, (A ∩ B).Nonempty) ∧ F.card = hm n k := by
  obtain ⟨x, hx⟩ : ∃ x : Fin n, ∃ Y : Finset (Fin n), Y.card = k ∧ x ∉ Y := by
    obtain ⟨Y, hY⟩ : ∃ Y : Finset (Fin n), Y.card = k := by
      exact Exists.imp ( by aesop ) ( Finset.exists_subset_card_eq ( show k ≤ Finset.card ( Finset.univ : Finset ( Fin n ) ) from by simpa using by linarith ) );
    exact Exists.elim ( Finset.exists_of_ssubset ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.subset_univ Y, by aesop_cat ⟩ ) ) fun x hx => ⟨ x, Y, hY, by aesop_cat ⟩;
  cases' hx with Y hY;
  refine' ⟨ hiltonMilnerFamily x Y, hiltonMilnerFamily_uniform x hY.1, hiltonMilnerFamily_nonTrivial x hY.1 hY.2 hk, hiltonMilnerFamily_intersecting x _, _ ⟩;
  · exact Finset.card_pos.mp ( by linarith );
  · exact card_hiltonMilnerFamily x hY.1 hY.2 ( by linarith ) ( by linarith )

end ProductHiltonMilner