import Bridges.MoonshineMomentLaurentBridge

/-!
# Moonshine beyond the j-function V: renormalized products and symmetric aggregates

This file closes **Conjecture C** and the main half of **Conjecture D** of the previous cycles of
this research thread (see `Catalog/Bridges/MoonshineMomentLaurentBridge.lean` and
`FUTURE_DIRECTIONS.md`).

Cycle 1 showed that a product of `m` McKay–Thompson-normalized `q`-series (order exactly `-1` at
the cusp) has order exactly `-m`, so the "product over all Monster classes" cannot be
holomorphic; and that multiplying by `q^m` restores order `0`
(`MoonshineMoments.orderTop_renormalized_prod`).  Conjecture C asked whether the pole is the
*only* obstruction, i.e. whether every order-`0` series arises this way.

* `exists_normalized_family_renormalized_prod_eq` : **yes**, for every `m ≥ 1` and every series
  `F` of order `0` there is a family of `m` normalized series whose renormalized product is
  exactly `F`.
* `renormalized_prod_iff_orderTop_zero` : hence the image of the renormalized-product map is
  *precisely* the set of order-`0` series — the pole order is the only obstruction.
* `factorization_not_unique` : the factorization is never unique, so the renormalized product
  cannot be inverted.

Conjecture D asked whether the failure of the unlabeled product to remember the labels is a
defect of one example or a structural fact.  It is structural:

* `symmetric_aggregate_not_injective` : **no** permutation-invariant aggregate of a family of
  `m ≥ 2` series is injective.  Since multiplication is commutative this contains the cycle-1
  counterexample as a special case (`prod_aggregate_not_injective_of_two_le`), and it identifies
  commutativity — not any accident of the example — as the obstruction.
* The interleaving aggregate of cycle 1 is injective, so by the same theorem it cannot be
  permutation-invariant (`interleave_not_symmetric`), completing the dichotomy.

Everything is proved; there are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset

namespace MoonshineFactorization

open MoonshineMoments

/-! ## Part 1: powers of the basic monomial `q⁻¹` -/

/-- `(q⁻¹)^k = q^(-k)` as Hahn series. -/
theorem single_neg_one_pow (k : ℕ) :
    (HahnSeries.single (-1 : ℤ) (1 : ℤ)) ^ k = HahnSeries.single (-(k : ℤ)) (1 : ℤ) := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, ih, HahnSeries.single_mul_single]
      push_cast
      ring_nf

/-- A nonzero series has order `≠ ⊤`; in particular a normalized series is nonzero. -/
theorem ne_zero_of_isMTNormalized {T : QLaurent} (hT : IsMTNormalized T) : T ≠ 0 := by
  intro h
  rw [IsMTNormalized, h, HahnSeries.orderTop_zero] at hT
  exact WithTop.top_ne_coe hT

/-! ## Part 2: Conjecture C — the pole order is the only obstruction -/

/-- **Conjecture C.**  For every `m ≥ 1` and every Laurent `q`-series `F` of order exactly `0` at
the cusp, there is a family of `m` McKay–Thompson-normalized series (each of order `-1`) whose
renormalized product `q^m · ∏ f i` equals `F`.  Together with
`MoonshineMoments.orderTop_renormalized_prod` this says: the renormalized-product map is onto the
order-`0` series, so the pole order is the *only* obstruction to holomorphy. -/
theorem exists_normalized_family_renormalized_prod_eq (m : ℕ) (hm : 0 < m) (F : QLaurent)
    (hF : F.orderTop = ((0 : ℤ) : WithTop ℤ)) :
    ∃ f : Fin m → QLaurent, (∀ i, IsMTNormalized (f i)) ∧
      HahnSeries.single ((Finset.univ : Finset (Fin m)).card : ℤ) (1 : ℤ) * ∏ i, f i = F := by
  classical
  obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, (Nat.succ_pred_eq_of_pos hm).symm⟩
  set q : QLaurent := HahnSeries.single (-1 : ℤ) (1 : ℤ) with hq
  refine ⟨Function.update (fun _ => q) 0 (q * F), ?_, ?_⟩
  · intro i
    by_cases hi : i = 0
    · subst hi
      simp only [Function.update_self]
      unfold IsMTNormalized
      rw [HahnSeries.orderTop_mul, hq,
        HahnSeries.orderTop_single (by norm_num : (1 : ℤ) ≠ 0), hF]
      norm_cast
    · simp only [Function.update_of_ne hi]
      exact isMTNormalized_single 1 one_ne_zero
  · have hcard : ((Finset.univ : Finset (Fin (n + 1))) \ {(0 : Fin (n + 1))}).card = n := by
      simp [Finset.card_sdiff]
    rw [Finset.prod_update_of_mem (Finset.mem_univ _), Finset.prod_const, hcard,
      single_neg_one_pow, hq]
    rw [show (HahnSeries.single (-1 : ℤ) (1 : ℤ) * F) * HahnSeries.single (-(n : ℤ)) (1 : ℤ)
        = (HahnSeries.single (-1 : ℤ) (1 : ℤ) * HahnSeries.single (-(n : ℤ)) (1 : ℤ)) * F by
      ring]
    rw [HahnSeries.single_mul_single, ← mul_assoc, HahnSeries.single_mul_single]
    have hsum : ((Finset.univ : Finset (Fin (n + 1))).card : ℤ) + (-1 + -(n : ℤ)) = 0 := by
      simp
      ring
    rw [hsum]
    simp

/-- **Characterization of renormalized products.**  For `m ≥ 1`, a series is the renormalized
product `q^m · ∏ f i` of `m` normalized series if and only if it has order exactly `0`. -/
theorem renormalized_prod_iff_orderTop_zero (m : ℕ) (hm : 0 < m) (F : QLaurent) :
    (∃ f : Fin m → QLaurent, (∀ i, IsMTNormalized (f i)) ∧
        HahnSeries.single ((Finset.univ : Finset (Fin m)).card : ℤ) (1 : ℤ) * ∏ i, f i = F)
      ↔ F.orderTop = ((0 : ℤ) : WithTop ℤ) := by
  constructor
  · rintro ⟨f, hf, rfl⟩
    exact orderTop_renormalized_prod Finset.univ f (fun i _ => hf i)
  · exact exists_normalized_family_renormalized_prod_eq m hm F

/-- Negating a series does not change its order, so normalization is preserved. -/
theorem isMTNormalized_neg {T : QLaurent} (hT : IsMTNormalized T) : IsMTNormalized (-T) := by
  unfold IsMTNormalized at hT ⊢
  rwa [HahnSeries.orderTop_neg]

/-- **The factorization is never unique.**  Every order-`0` series is the renormalized product of
two *distinct* pairs of normalized series (flip the sign of both factors), so the renormalized
product carries strictly less information than the family it comes from. -/
theorem factorization_not_unique (F : QLaurent) (hF : F.orderTop = ((0 : ℤ) : WithTop ℤ)) :
    ∃ f g : Fin 2 → QLaurent, f ≠ g ∧ (∀ i, IsMTNormalized (f i)) ∧ (∀ i, IsMTNormalized (g i)) ∧
      HahnSeries.single ((Finset.univ : Finset (Fin 2)).card : ℤ) (1 : ℤ) * ∏ i, f i = F ∧
      HahnSeries.single ((Finset.univ : Finset (Fin 2)).card : ℤ) (1 : ℤ) * ∏ i, g i = F := by
  obtain ⟨f, hf, hfF⟩ := exists_normalized_family_renormalized_prod_eq 2 (by norm_num) F hF
  refine ⟨f, fun i => -f i, ?_, hf, fun i => isMTNormalized_neg (hf i), hfF, ?_⟩
  · intro hcontra
    have h0 : f 0 = -f 0 := congrFun hcontra 0
    have hsum : f 0 + f 0 = 0 := by
      nth_rewrite 2 [h0]
      simp
    have hz : f 0 = 0 := by
      ext n
      have hc := congrArg (fun t : QLaurent => t.coeff n) hsum
      simp only [HahnSeries.coeff_add, HahnSeries.coeff_zero] at hc
      simpa using (by omega : (f 0).coeff n = 0)
    exact ne_zero_of_isMTNormalized (hf 0) hz
  · rw [← hfF]
    congr 1
    rw [Fin.prod_univ_two, Fin.prod_univ_two, neg_mul_neg]

/-! ## Part 3: Conjecture D — symmetry is the obstruction to injective aggregates -/

/-- Two normalized series that are genuinely different. -/
theorem single_ne_single_two : HahnSeries.single (-1 : ℤ) (1 : ℤ)
    ≠ HahnSeries.single (-1 : ℤ) (2 : ℤ) := by
  intro h
  have := congrArg (fun t : QLaurent => t.coeff (-1)) h
  simp at this

/-- **Conjecture D, main half.**  No permutation-invariant ("unlabeled") aggregate of a family of
`m ≥ 2` series can be injective.  The obstruction is symmetry itself, not any accident of the
two-factor counterexample of cycle 1: a symmetric aggregate cannot distinguish a family from its
transposition. -/
theorem symmetric_aggregate_not_injective (m : ℕ) (hm : 2 ≤ m)
    (A : (Fin m → QLaurent) → QLaurent)
    (hA : ∀ (f : Fin m → QLaurent) (σ : Equiv.Perm (Fin m)), A (f ∘ σ) = A f) :
    ¬ Function.Injective A := by
  intro hinj
  set i₀ : Fin m := ⟨0, lt_of_lt_of_le (by norm_num) hm⟩ with hi₀
  set i₁ : Fin m := ⟨1, lt_of_lt_of_le (by norm_num) hm⟩ with hi₁
  have hne01 : i₀ ≠ i₁ := by
    rw [hi₀, hi₁]
    intro h
    have := congrArg Fin.val h
    simp at this
  set f : Fin m → QLaurent := fun i =>
    if i = i₀ then HahnSeries.single (-1 : ℤ) (1 : ℤ) else HahnSeries.single (-1 : ℤ) (2 : ℤ)
    with hf
  have hswap : A (f ∘ (Equiv.swap i₀ i₁)) = A f := hA f _
  have hne : f ∘ (Equiv.swap i₀ i₁) ≠ f := by
    intro hcontra
    have hval := congrFun hcontra i₀
    simp only [Function.comp_apply, Equiv.swap_apply_left, hf, if_neg (Ne.symm hne01),
      if_pos rfl] at hval
    exact single_ne_single_two hval.symm
  exact hne (hinj hswap)

/-- In particular the *product* aggregate — the literal "product over all Monster classes" — is
non-injective for every `m ≥ 2`, generalizing the two-factor counterexample of cycle 1. -/
theorem prod_aggregate_not_injective_of_two_le (m : ℕ) (hm : 2 ≤ m) :
    ¬ Function.Injective (fun f : Fin m → QLaurent => ∏ i, f i) := by
  refine symmetric_aggregate_not_injective m hm _ ?_
  intro f σ
  exact Fintype.prod_equiv σ _ _ (fun i => rfl)

/-- Completing the dichotomy: the interleaving aggregate of cycle 1 *is* injective, hence it
cannot be permutation-invariant. -/
theorem interleave_not_symmetric (m : ℕ) (hm : 2 ≤ m) :
    ¬ ∀ (f : Fin m → QLaurent) (σ : Equiv.Perm (Fin m)),
        interleave m (lt_of_lt_of_le (by norm_num) hm) (f ∘ σ)
          = interleave m (lt_of_lt_of_le (by norm_num) hm) f := by
  intro hsym
  exact symmetric_aggregate_not_injective m hm _ hsym
    (interleave_injective m (lt_of_lt_of_le (by norm_num) hm))

end MoonshineFactorization