/-
# Non-regular coverings of prime degree

`FundamentalGroupCoveringPrimeIndex` proved the positive half of sub-conjecture **C1b** of
the thread: a connected covering of a `K(G,1)` whose degree is the *smallest* prime factor
of `|G|` is automatically regular and character-theoretic
(`normal_and_exists_char_of_index_eq_minFac`).  This file closes the converse half, which
was left open:

* `minFac_lt_index_of_not_normal` — the general obstruction.  If a subgroup of finite
  index has prime index and is **not** normal, then its index is strictly larger than the
  smallest prime factor of the order of the group.  Equivalently: a non-regular connected
  covering of prime degree `p` forces a prime divisor of `|G|` smaller than `p`.
* `stabZero_not_normal`, `s3_triple_covering_not_regular` — the predicted example.  The
  point stabiliser of `0` in `S₃ ⟳ Fin 3` has index three but is not normal, so the
  associated connected three-sheeted covering of the `K(S₃,1)` is **not** regular: its
  deck transformation group does not act transitively on a fibre.
* `stabZero_self_normalizing`, `s3_triple_covering_deck_trivial` — the covering is in fact
  maximally non-regular: the stabiliser is self-normalising, so the deck group of the
  three-sheeted covering is trivial, even though the covering has three sheets.
* `nonRegular_prime_degree_forces_smaller_prime` packages the two directions: `3` is a
  prime index at which regularity fails for `S₃`, and correspondingly `2 = |S₃|.minFac < 3`.

Together with the earlier file this determines exactly when the prime-degree character
theory applies: at the minimal prime it always does, and at every larger prime it can
fail, as the three-sheeted covering of the `K(S₃,1)` shows.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringDeck
import Bridges.FundamentalGroupCoveringPrimeIndex
import Bridges.FundamentalGroupCoveringConjugacy

open CategoryTheory MulAction

namespace FundamentalGroupCovering

universe u

/-! ## The general obstruction -/

section General

variable {K : Type u} [Group K]

/-- **A non-normal subgroup of prime index has index larger than the smallest prime factor
of the order of the group.**  Covering-theoretically: if a connected covering of a
`K(G,1)` of prime degree `p` is *not* regular, then `|G|` has a prime factor smaller
than `p`. -/
theorem minFac_lt_index_of_not_normal {H : Subgroup K} (hp : H.index.Prime)
    (hnn : ¬ H.Normal) : (Nat.card K).minFac < H.index := by
  have hdvd : H.index ∣ Nat.card K := H.index_dvd_card
  have hle : (Nat.card K).minFac ≤ H.index := Nat.minFac_le_of_dvd hp.two_le hdvd
  rcases lt_or_eq_of_le hle with h | h
  · exact h
  · exact absurd (Subgroup.normal_of_index_eq_minFac_card h.symm) hnn

/-- The contrapositive form, matching the falsifiable statement of the conjecture: if the
order of the group has no prime factor below `p`, then every subgroup of index `p` is
normal, i.e. every connected degree-`p` covering is regular. -/
theorem normal_of_index_prime_of_le_minFac {H : Subgroup K} (hp : H.index.Prime)
    (hle : H.index ≤ (Nat.card K).minFac) : H.Normal := by
  by_contra hnn
  exact absurd (minFac_lt_index_of_not_normal hp hnn) (not_lt.mpr hle)

end General

/-! ## The three-sheeted covering of the `K(S₃,1)` -/

section Symmetric

/-- The point stabiliser of `0` in `S₃` is **not** normal: conjugating the transposition
`(1 2)` by `(0 1)` produces `(0 2)`, which does not fix `0`. -/
theorem stabZero_not_normal : ¬ StabZero.Normal := by
  intro h
  have hmem : Equiv.swap (1 : Fin 3) 2 ∈ StabZero := by
    show Equiv.swap (1 : Fin 3) 2 • (0 : Fin 3) = 0
    decide
  have hconj := h.conj_mem _ hmem (Equiv.swap (0 : Fin 3) 1)
  have hno : ¬ ((Equiv.swap (0 : Fin 3) 1 * Equiv.swap (1 : Fin 3) 2 *
      (Equiv.swap (0 : Fin 3) 1)⁻¹) • (0 : Fin 3) = 0) := by decide
  exact hno hconj

/-- **The three-sheeted covering of the `K(S₃,1)` classified by a point stabiliser is not
regular**: its deck transformations do not act transitively on the fibre. -/
theorem s3_triple_covering_not_regular :
    ¬ (∀ p q : S3 ⧸ StabZero, ∃ f ∈ DeckSubgroup S3 (S3 ⧸ StabZero), f p = q) :=
  fun h => stabZero_not_normal ((deck_transitive_iff_normal StabZero).mp h)

theorem card_S3 : Nat.card S3 = 6 := by
  rw [Nat.card_eq_fintype_card, Fintype.card_perm]
  decide

/-- The order of a point stabiliser in `S₃` is two. -/
theorem card_StabZero : Nat.card StabZero = 2 := by
  have h := Subgroup.card_mul_index StabZero
  rw [index_StabZero, card_S3] at h
  omega

/-- The point stabiliser is **self-normalising**. -/
theorem stabZero_self_normalizing : StabZero.normalizer = StabZero := by
  -- the order of the normaliser is a multiple of two dividing six, so it is two or six;
  -- six would make the stabiliser normal, which it is not
  obtain ⟨n, hn⟩ : ∃ n, Nat.card StabZero.normalizer = n := ⟨_, rfl⟩
  have hdvd : n ∣ 6 := by
    rw [← hn, ← card_S3]; exact Subgroup.card_subgroup_dvd_card _
  have hdvd2 : 2 ∣ n := by
    rw [← hn, ← card_StabZero]; exact Subgroup.card_dvd_of_le Subgroup.le_normalizer
  have hub : n ≤ 6 := Nat.le_of_dvd (by norm_num) hdvd
  have hcase : n = 2 ∨ n = 6 := by
    interval_cases n <;> revert hdvd hdvd2 <;> decide
  rcases hcase with h2 | h6
  · exact (Subgroup.eq_of_le_of_card_ge Subgroup.le_normalizer
      (by rw [hn, h2, card_StabZero])).symm
  · exact absurd (Subgroup.normalizer_eq_top_iff.mp
      (Subgroup.eq_top_of_card_eq _ (by rw [hn, h6, card_S3]))) stabZero_not_normal

/-- **The deck group of the non-regular three-sheeted covering is trivial.**  A covering of
degree three whose deck group has order one: the failure of regularity here is total. -/
theorem s3_triple_covering_deck_trivial :
    Subsingleton (DeckSubgroup S3 (S3 ⧸ StabZero)) := by
  have hsub : Subsingleton (StabZero.normalizer ⧸ StabZero.subgroupOf StabZero.normalizer) := by
    have htop : StabZero.subgroupOf StabZero.normalizer = ⊤ := by
      rw [Subgroup.subgroupOf_eq_top]
      exact le_of_eq stabZero_self_normalizing
    rw [htop]
    exact QuotientGroup.subsingleton_quotient_top
  exact (deckMulEquivNormalizerQuotient StabZero).toEquiv.symm.subsingleton

/-- **Synthesis of sub-conjecture C1b.**  Regularity of prime-degree coverings holds
exactly at the minimal prime: at `p = 3` over the base `K(S₃,1)` there is a connected
degree-three covering that is not regular, and correspondingly the order of `S₃` has the
smaller prime factor `2 = |S₃|.minFac < 3`. -/
theorem nonRegular_prime_degree_forces_smaller_prime :
    StabZero.index = 3 ∧ ¬ StabZero.Normal ∧ (Nat.card S3).minFac = 2 ∧
      (Nat.card S3).minFac < StabZero.index := by
  have hmf : (Nat.card S3).minFac = 2 := by rw [card_S3]; decide
  refine ⟨index_StabZero, stabZero_not_normal, hmf, ?_⟩
  rw [hmf, index_StabZero]
  norm_num

end Symmetric

end FundamentalGroupCovering