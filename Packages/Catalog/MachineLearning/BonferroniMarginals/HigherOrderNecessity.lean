import MachineLearning.BonferroniMarginals.MarginalIndeterminacy

/-!
# Every marginal order below `k` is insufficient for `k` sets

`MarginalIndeterminacy.lean` exhibits three sets whose first- and second-order
marginals coincide but whose unions differ, showing that the Bonferroni
machinery can never be upgraded to an identity.  That example leaves open the
obvious escape route: *maybe order `3`, or order `17`, always suffices.*

This file closes the escape route completely.  For **every** `k ≥ 1` we build
two families of `k` sets, `plainFam k` and `parityFam k`, on a common ground set
of `2^(k+1)` points such that

* all joint marginals of order `< k` agree —
  `jointFail_card_eq_of_ne_univ`: `|⋂_{i ∈ T} Aᵢ| = |⋂_{i ∈ T} Bᵢ|` for every
  `T ≠ univ`;
* the top-order marginal differs (`jointFail_card_univ_ne`), and
* the unions differ (`card_cover_ne`), one being odd and the other even.

Hence `marginal_order_lt_insufficient`: no functional of the marginals of order
`< k` can compute the union of `k` sets, for any `k ≥ 1`.  Together with
`card_cover_eq_of_all_inf_card_eq` (inclusion–exclusion), the marginal order
threshold for a family of `k` sets is **exactly `k`**.

## The construction

Ground set `Ω = Finset (Fin k) × Bool`: two labelled copies of every subset of
`Fin k`.

* `plainFam k i = {(S, false) | i ∈ S}` — one copy of each subset containing `i`.
* `parityFam k i = {(S, b) | i ∈ S, |S| ≡ k (mod 2)}` — *two* copies of the
  subsets of the correct size parity.

Writing `w(S)` for the number of ground points sitting over `S`, the two
families have weight functions `1` and `1 + (−1)^{k−|S|}`; the perturbation
`δ(S) = (−1)^{k−|S|}` has vanishing "upper sums" `∑_{S ⊇ T} δ(S) = 0` for all
`T ≠ univ`, by the alternating binomial identity — and this is exactly the
statement that all marginals of order `< k` are unchanged.  The perturbation is
invisible below order `k` and flips the parity of the union.
-/

namespace BonferroniMarginals

open Finset

/-! ## Joint marginals of arbitrary order -/

/-- The joint event `⋂_{i ∈ T} A i`, computed inside a finite ambient type.
For `T = ∅` this is the whole space.  `(jointFail A T).card` is the marginal of
order `|T|` of the family `A`. -/
def jointFail {Ω ι : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq ι]
    (A : ι → Finset Ω) (T : Finset ι) : Finset Ω :=
  univ.filter (fun x => ∀ i ∈ T, x ∈ A i)

/-! ## Counting subsets with a prescribed size parity -/

/-- Half of the subsets of a nonempty finite set have any prescribed size parity. -/
lemma card_powerset_filter_parity {α : Type*} [DecidableEq α] (C : Finset α)
    (hC : C.Nonempty) (c : ℕ) :
    (C.powerset.filter (fun U => (U.card + c) % 2 = 0)).card = 2 ^ (C.card - 1) := by
  classical
  have hsplit := Finset.card_filter_add_card_filter_not (s := C.powerset)
    (p := fun U : Finset α => (U.card + c) % 2 = 0)
  rw [Finset.card_powerset] at hsplit
  -- the alternating sum vanishes, so the two halves have equal size
  have halt : ∑ U ∈ C.powerset, ((-1 : ℤ)) ^ U.card = 0 :=
    Finset.sum_powerset_neg_one_pow_card_of_nonempty hC
  have hsum : ∑ U ∈ C.powerset, ((-1 : ℤ)) ^ U.card
      = (-1 : ℤ) ^ c * (((C.powerset.filter (fun U : Finset α => (U.card + c) % 2 = 0)).card : ℤ)
          - ((C.powerset.filter (fun U : Finset α => ¬ ((U.card + c) % 2 = 0))).card : ℤ)) := by
    rw [← Finset.sum_filter_add_sum_filter_not C.powerset
      (fun U : Finset α => (U.card + c) % 2 = 0)]
    have h1 : ∀ U ∈ C.powerset.filter (fun U : Finset α => (U.card + c) % 2 = 0),
        ((-1 : ℤ)) ^ U.card = (-1 : ℤ) ^ c := by
      intro U hU
      have hUP : (U.card + c) % 2 = 0 := (Finset.mem_filter.mp hU).2
      have hmod : U.card % 2 = c % 2 := by omega
      rw [neg_one_pow_eq_pow_mod_two, hmod, ← neg_one_pow_eq_pow_mod_two]
    have h2 : ∀ U ∈ C.powerset.filter (fun U : Finset α => ¬ ((U.card + c) % 2 = 0)),
        ((-1 : ℤ)) ^ U.card = -((-1 : ℤ) ^ c) := by
      intro U hU
      have hUP : ¬ ((U.card + c) % 2 = 0) := (Finset.mem_filter.mp hU).2
      have hmod : U.card % 2 = (c + 1) % 2 := by omega
      rw [neg_one_pow_eq_pow_mod_two, hmod, ← neg_one_pow_eq_pow_mod_two, pow_succ]
      ring
    rw [Finset.sum_congr rfl h1, Finset.sum_congr rfl h2]
    simp only [Finset.sum_const, nsmul_eq_mul]
    ring
  rw [halt] at hsum
  have hne : ((-1 : ℤ)) ^ c ≠ 0 := by positivity
  have hdiff : ((C.powerset.filter (fun U : Finset α => (U.card + c) % 2 = 0)).card : ℤ)
      = ((C.powerset.filter (fun U : Finset α => ¬ ((U.card + c) % 2 = 0))).card : ℤ) := by
    rcases mul_eq_zero.mp hsum.symm with h | h
    · exact absurd h hne
    · linarith
  have heq : (C.powerset.filter (fun U : Finset α => (U.card + c) % 2 = 0)).card
      = (C.powerset.filter (fun U : Finset α => ¬ ((U.card + c) % 2 = 0))).card := by
    exact_mod_cast hdiff
  have hC1 : 1 ≤ C.card := Finset.card_pos.mpr hC
  have hpow : 2 ^ C.card = 2 * 2 ^ (C.card - 1) := by
    conv_lhs => rw [show C.card = (C.card - 1) + 1 by omega]
    ring
  omega

/-! ## Supersets of a fixed set -/

variable {k : ℕ}

/-- Reindexing supersets of `T` by subsets of the complement. -/
lemma card_filter_superset (T : Finset (Fin k)) (P : ℕ → Prop) [DecidablePred P] :
    ((univ : Finset (Finset (Fin k))).filter (fun S => T ⊆ S ∧ P S.card)).card
      = ((Tᶜ).powerset.filter (fun U => P (U.card + T.card))).card := by
  classical
  refine Finset.card_nbij' (fun S => S \ T) (fun U => U ∪ T) ?_ ?_ ?_ ?_
  · intro S hS
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hS
    obtain ⟨hTS, hPS⟩ := hS
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_powerset]
    refine ⟨?_, ?_⟩
    · intro x hx
      simp only [Finset.mem_sdiff] at hx
      simpa [Finset.mem_compl] using hx.2
    · rwa [Finset.card_sdiff_add_card_eq_card hTS]
  · intro U hU
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_powerset] at hU
    obtain ⟨hUT, hPU⟩ := hU
    have hdisj : Disjoint U T := by
      rw [Finset.disjoint_right]
      intro x hxT hxU
      have := hUT hxU
      simp only [Finset.mem_compl] at this
      exact this hxT
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
    exact ⟨Finset.subset_union_right, by rwa [Finset.card_union_of_disjoint hdisj]⟩
  · intro S hS
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hS
    exact Finset.sdiff_union_of_subset hS.1
  · intro U hU
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_powerset] at hU
    have hdisj : Disjoint U T := by
      rw [Finset.disjoint_right]
      intro x hxT hxU
      have := hU.1 hxU
      simp only [Finset.mem_compl] at this
      exact this hxT
    show (U ∪ T) \ T = U
    rw [Finset.union_sdiff_cancel_right hdisj]

/-- The number of subsets of `Fin k` containing `T` is `2^(k - |T|)`. -/
lemma card_supersets (T : Finset (Fin k)) :
    ((univ : Finset (Finset (Fin k))).filter (fun S => T ⊆ S)).card = 2 ^ (k - T.card) := by
  classical
  have h := card_filter_superset T (fun _ => True)
  simp only [and_true] at h
  rw [h]
  simp [Finset.card_powerset, Finset.card_compl]

/-- Among the subsets of `Fin k` containing a *proper* subset `T`, exactly half
have any prescribed size parity. -/
lemma card_supersets_parity (T : Finset (Fin k)) (hT : T.card < k) (c : ℕ) :
    ((univ : Finset (Finset (Fin k))).filter
        (fun S => T ⊆ S ∧ (S.card + c) % 2 = 0)).card = 2 ^ (k - T.card - 1) := by
  classical
  have hcompl : (Tᶜ : Finset (Fin k)).card = k - T.card := by
    simp [Finset.card_compl]
  have hne : (Tᶜ : Finset (Fin k)).Nonempty := by
    rw [← Finset.card_pos, hcompl]
    omega
  have h := card_filter_superset T (fun n => (n + c) % 2 = 0)
  rw [h]
  simp only [add_assoc]
  rw [card_powerset_filter_parity _ hne (T.card + c), hcompl]

/-! ## The two families -/

/-- One copy of every subset containing `i`. -/
def plainFam (k : ℕ) (i : Fin k) : Finset (Finset (Fin k) × Bool) :=
  univ.filter (fun p => i ∈ p.1 ∧ p.2 = false)

/-- Two copies of every subset containing `i` whose size has the same parity as `k`. -/
def parityFam (k : ℕ) (i : Fin k) : Finset (Finset (Fin k) × Bool) :=
  univ.filter (fun p => i ∈ p.1 ∧ (p.1.card + k) % 2 = 0)

lemma jointFail_plain (T : Finset (Fin k)) (hT : T.Nonempty) :
    jointFail (plainFam k) T
      = ((univ : Finset (Finset (Fin k))).filter (fun S => T ⊆ S)) ×ˢ ({false} : Finset Bool) := by
  ext p
  simp only [jointFail, plainFam, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_product, Finset.mem_singleton]
  obtain ⟨i0, hi0⟩ := hT
  constructor
  · intro h
    exact ⟨fun x hx => (h x hx).1, (h i0 hi0).2⟩
  · intro h
    exact fun i hi => ⟨h.1 hi, h.2⟩

lemma jointFail_parity (T : Finset (Fin k)) (hT : T.Nonempty) :
    jointFail (parityFam k) T
      = ((univ : Finset (Finset (Fin k))).filter (fun S => T ⊆ S ∧ (S.card + k) % 2 = 0))
          ×ˢ (univ : Finset Bool) := by
  ext p
  simp only [jointFail, parityFam, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_product, and_true]
  obtain ⟨i0, hi0⟩ := hT
  constructor
  · intro h
    exact ⟨fun x hx => (h x hx).1, (h i0 hi0).2⟩
  · intro h
    exact fun i hi => ⟨h.1 hi, h.2⟩

/-- **All marginals of order `< k` agree.** -/
theorem jointFail_card_eq_of_ne_univ (T : Finset (Fin k)) (hT : T ≠ univ) :
    (jointFail (plainFam k) T).card = (jointFail (parityFam k) T).card := by
  classical
  have hlt : T.card < k := by
    have h1 : T ⊂ univ := ⟨Finset.subset_univ T, fun h => hT (Finset.Subset.antisymm (Finset.subset_univ T) h)⟩
    have := Finset.card_lt_card h1
    simpa using this
  rcases T.eq_empty_or_nonempty with rfl | hne
  · simp [jointFail]
  rw [jointFail_plain T hne, jointFail_parity T hne, Finset.card_product, Finset.card_product,
    card_supersets, card_supersets_parity T hlt k]
  simp only [Finset.card_singleton, Finset.card_univ, Fintype.card_bool, mul_one]
  have hpow : 2 ^ (k - T.card) = 2 ^ (k - T.card - 1) * 2 := by
    conv_lhs => rw [show k - T.card = (k - T.card - 1) + 1 by omega]
    ring
  rw [hpow]

/-- **The top-order marginal differs**: the full intersection has one point in
the first family and two in the second. -/
theorem jointFail_card_univ_ne (hk : 0 < k) :
    (jointFail (plainFam k) univ).card ≠ (jointFail (parityFam k) univ).card := by
  classical
  have hne : (univ : Finset (Fin k)).Nonempty := by
    rw [← Finset.card_pos]
    simpa using hk
  rw [jointFail_plain _ hne, jointFail_parity _ hne, Finset.card_product, Finset.card_product]
  have h1 : ((univ : Finset (Finset (Fin k))).filter (fun S => (univ : Finset (Fin k)) ⊆ S)).card
      = 1 := by
    rw [card_supersets]
    simp
  have h2 : ((univ : Finset (Finset (Fin k))).filter
      (fun S => (univ : Finset (Fin k)) ⊆ S ∧ (S.card + k) % 2 = 0)).card = 1 := by
    have : ((univ : Finset (Finset (Fin k))).filter
        (fun S => (univ : Finset (Fin k)) ⊆ S ∧ (S.card + k) % 2 = 0))
        = (univ : Finset (Finset (Fin k))).filter (fun S => (univ : Finset (Fin k)) ⊆ S) := by
      apply Finset.filter_congr
      intro S _
      constructor
      · exact fun h => h.1
      · intro h
        refine ⟨h, ?_⟩
        have : S = univ := Finset.Subset.antisymm (Finset.subset_univ S) h
        rw [this]
        simp [Finset.card_univ]
        omega
    rw [this, card_supersets]
    simp
  rw [h1, h2]
  simp

/-! ## The unions differ -/

lemma cover_plain :
    cover (univ : Finset (Fin k)) (plainFam k)
      = ((univ : Finset (Finset (Fin k))).filter (fun S => S.Nonempty))
          ×ˢ ({false} : Finset Bool) := by
  ext p
  simp only [mem_cover, plainFam, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_product, Finset.mem_singleton]
  aesop

lemma cover_parity :
    cover (univ : Finset (Fin k)) (parityFam k)
      = ((univ : Finset (Finset (Fin k))).filter
          (fun S => S.Nonempty ∧ (S.card + k) % 2 = 0)) ×ˢ (univ : Finset Bool) := by
  ext p
  simp only [mem_cover, parityFam, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_product, and_true]
  aesop

/-- **The unions differ**: `|⋃ plainFam| = 2^k − 1` is odd while `|⋃ parityFam|`
is even, for every `k ≥ 1`. -/
theorem card_cover_ne (hk : 0 < k) :
    (cover (univ : Finset (Fin k)) (plainFam k)).card
      ≠ (cover (univ : Finset (Fin k)) (parityFam k)).card := by
  classical
  rw [cover_plain, cover_parity, Finset.card_product, Finset.card_product]
  have hplain : ((univ : Finset (Finset (Fin k))).filter (fun S => S.Nonempty)).card
      = 2 ^ k - 1 := by
    have hcompl : ((univ : Finset (Finset (Fin k))).filter (fun S => ¬ S.Nonempty)).card = 1 := by
      have : ((univ : Finset (Finset (Fin k))).filter (fun S => ¬ S.Nonempty))
          = {(∅ : Finset (Fin k))} := by
        ext S
        simp [Finset.not_nonempty_iff_eq_empty]
      rw [this, Finset.card_singleton]
    have htot := Finset.card_filter_add_card_filter_not
      (s := (univ : Finset (Finset (Fin k)))) (p := fun S => S.Nonempty)
    rw [hcompl] at htot
    have hcard : (univ : Finset (Finset (Fin k))).card = 2 ^ k := by
      simp [Finset.card_univ, Fintype.card_finset]
    rw [hcard] at htot
    omega
  rw [hplain]
  simp only [Finset.card_singleton, Finset.card_univ, Fintype.card_bool, mul_one]
  intro hcon
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  have hpow : 2 ^ (j + 1) = 2 * 2 ^ j := by ring
  have hj : 1 ≤ 2 ^ j := Nat.one_le_two_pow
  omega

/-! ## The main theorem -/

/-- **Marginals of order `< k` never determine the union of `k` sets.**
For every `k ≥ 1` there are two families of `k` subsets of a common finite
ground set whose joint marginals agree on every proper subfamily, whose
top-order marginals differ, and whose unions differ.

Combined with `card_cover_eq_of_all_inf_card_eq` (inclusion–exclusion, which
shows that the full marginal data *does* determine the union), the marginal
order threshold for `k` sets is exactly `k`: the Bonferroni machinery, which
sees orders `1` and `2` only, is intrinsically an inequality for all `k ≥ 3`. -/
theorem marginal_order_lt_insufficient (k : ℕ) (hk : 0 < k) :
    ∃ A B : Fin k → Finset (Finset (Fin k) × Bool),
      (∀ T : Finset (Fin k), T ≠ univ → (jointFail A T).card = (jointFail B T).card) ∧
      (jointFail A univ).card ≠ (jointFail B univ).card ∧
      (cover (univ : Finset (Fin k)) A).card ≠ (cover (univ : Finset (Fin k)) B).card :=
  ⟨plainFam k, parityFam k, fun T hT => jointFail_card_eq_of_ne_univ T hT,
    jointFail_card_univ_ne hk, card_cover_ne hk⟩

/-- **No functional of the sub-top-order marginals computes the union.** -/
theorem no_lower_order_formula (k : ℕ) (hk : 0 < k) :
    ¬ ∃ F : (Finset (Fin k) → ℕ) → ℕ,
        ∀ A : Fin k → Finset (Finset (Fin k) × Bool),
          (cover (univ : Finset (Fin k)) A).card
            = F (fun T => if T = univ then 0 else (jointFail A T).card) := by
  rintro ⟨F, hF⟩
  obtain ⟨A, B, hagree, -, hne⟩ := marginal_order_lt_insufficient k hk
  apply hne
  rw [hF A, hF B]
  congr 1
  funext T
  by_cases hT : T = univ
  · simp [hT]
  · simp [hT, hagree T hT]

end BonferroniMarginals