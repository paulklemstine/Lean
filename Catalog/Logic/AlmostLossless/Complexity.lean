import Logic.AlmostLossless.Instances

/-!
# Decoder complexity: an exact expected cost and a universal lower bound

The rate side of almost-lossless compression is settled by `Core`; this file is
about the *time* side, which the research thread identifies as the real
obstacle.

* `AlmostLossless.avg_decodeCost_bucketed_eq` — for a **pairwise independent**
  hash family the expected number of candidate tests performed by the bucketed
  decoder on a typical word is *exactly* `1 + (|T|-1)/m₁`, matching the
  numerical measurements (Section 4 of `ComputationalEvidence.md`) to the digit.
  So the upper bound `avg_decodeCost_bucketed_le` cannot be improved for this
  class of families.

* `AlmostLossless.card_typical_sq_le_card_mul_sum_decodeCost` — a *universal*
  lower bound: for **every** scan scheme and every seed, the total decoding work
  over the typical set is at least `|T|²/|M|` (Cauchy–Schwarz over the buckets),
  and each individual decoding costs at least one test.  Hence no scheme with
  `m` codewords can decode a typical set of size `t` in less than `t/m` expected
  tests: rate and decoding time obey a hyperbolic trade-off.

Together these pin the bucketed decoder to within an additive `1` of optimal.
-/

namespace AlmostLossless

open Finset

variable {S A M : Type*} [DecidableEq S] [DecidableEq M]

/-! ## Exact expected work for pairwise independent families -/

theorem avg_collisionCount_eq [Fintype A] [DecidableEq A] [Nonempty A] [Fintype M] [Nonempty M]
    {h : A → S → M} (hpi : PairwiseIndependent h) (T : Finset S) (x : S) :
    (∑ a : A, (collisionCount h T a x : ℚ)) / (Fintype.card A : ℚ)
      = ((T.erase x).card : ℚ) / (Fintype.card M : ℚ) := by
  classical
  have hA : (0 : ℚ) < (Fintype.card A : ℚ) := by exact_mod_cast Fintype.card_pos (α := A)
  have hM : (0 : ℚ) < (Fintype.card M : ℚ) := by exact_mod_cast Fintype.card_pos (α := M)
  have key : (∑ a : A, collisionCount h T a x) * Fintype.card M
      = (T.erase x).card * Fintype.card A := by
    have hswap : ∑ a : A, collisionCount h T a x
        = ∑ y ∈ T.erase x, #{a | h a y = h a x} := by
      unfold collisionCount
      simp_rw [Finset.card_filter]
      rw [Finset.sum_comm]
    rw [hswap, Finset.sum_mul]
    calc ∑ y ∈ T.erase x, #{a | h a y = h a x} * Fintype.card M
        = ∑ _y ∈ T.erase x, Fintype.card A :=
          Finset.sum_congr rfl fun y hy => hpi y x (Finset.ne_of_mem_erase hy)
      _ = (T.erase x).card * Fintype.card A := by rw [Finset.sum_const, smul_eq_mul]
  rw [div_eq_div_iff (ne_of_gt hA) (ne_of_gt hM)]
  have hcast : ((∑ a : A, collisionCount h T a x : ℕ) : ℚ) * (Fintype.card M : ℚ)
      = ((T.erase x).card : ℚ) * (Fintype.card A : ℚ) := by exact_mod_cast key
  calc (∑ a : A, (collisionCount h T a x : ℚ)) * (Fintype.card M : ℚ)
      = ((∑ a : A, collisionCount h T a x : ℕ) : ℚ) * (Fintype.card M : ℚ) := by
        push_cast; ring
    _ = ((T.erase x).card : ℚ) * (Fintype.card A : ℚ) := hcast

section Bucketed

variable {A₁ A₂ M₁ M₂ : Type*} [DecidableEq M₁] [DecidableEq M₂]

omit [DecidableEq M₂] in
/-- **Exact expected decoder complexity.**  For a pairwise independent bucket
hash the bucketed decoder tests exactly `1 + (|T|-1)/m₁` candidates on average
over the seed — an identity, so the bound of `avg_decodeCost_bucketed_le` is
attained. -/
theorem avg_decodeCost_bucketed_eq [Fintype A₁] [DecidableEq A₁] [Nonempty A₁]
    [Fintype M₁] [Nonempty M₁] (T : Finset S) {h₁ : A₁ → S → M₁} (h₂ : A₂ → S → M₂)
    (hpi : PairwiseIndependent h₁) (a₂ : A₂) {x : S} (hx : x ∈ T) :
    (∑ a₁ : A₁, (((bucketed T h₁ h₂).decodeCost (a₁, a₂)
        ((bucketed T h₁ h₂).hash (a₁, a₂) x) : ℕ) : ℚ)) / (Fintype.card A₁ : ℚ)
      = 1 + ((T.erase x).card : ℚ) / (Fintype.card M₁ : ℚ) := by
  have hA : (0 : ℚ) < (Fintype.card A₁ : ℚ) := by exact_mod_cast Fintype.card_pos (α := A₁)
  have hterm : ∀ a₁ : A₁, (((bucketed T h₁ h₂).decodeCost (a₁, a₂)
      ((bucketed T h₁ h₂).hash (a₁, a₂) x) : ℕ) : ℚ)
      = 1 + (collisionCount h₁ T a₁ x : ℚ) := by
    intro a₁
    rw [decodeCost_bucketed_self T h₁ h₂ a₁ a₂ hx]
    push_cast
    ring
  rw [Finset.sum_congr rfl (fun a₁ _ => hterm a₁), Finset.sum_add_distrib]
  have hone : ∑ _a₁ : A₁, (1 : ℚ) = (Fintype.card A₁ : ℚ) := by simp
  rw [hone, add_div, div_self (ne_of_gt hA), avg_collisionCount_eq hpi T x]

end Bucketed

/-! ## A universal lower bound on decoder work -/

variable [Fintype M]

omit [DecidableEq S] [Fintype M] in
/-- Every typical word that shares a codeword with `x` is a candidate when `x`'s
codeword is received: the decoder cannot avoid its whole bucket. -/
theorem bucket_subset_cand (P : ScanScheme S A M) (a : A) (x : S) :
    {y ∈ P.typical | P.hash a y = P.hash a x} ⊆ P.cand a (P.hash a x) := by
  intro y hy
  rw [Finset.mem_filter] at hy
  have := P.self_mem_cand a y hy.1
  rwa [hy.2] at this

omit [DecidableEq S] [DecidableEq M] [Fintype M] in
/-- Decoding always costs at least one candidate test. -/
theorem one_le_decodeCost (P : ScanScheme S A M) (a : A) {x : S} (hx : x ∈ P.typical) :
    1 ≤ P.decodeCost a (P.hash a x) :=
  Finset.card_pos.2 ⟨x, P.self_mem_cand a x hx⟩

omit [DecidableEq S] in
/-- **Universal lower bound on decoding work (Cauchy–Schwarz over buckets).**
For any scan scheme and any seed, the total number of candidate tests spent
decoding the whole typical set is at least `|T|²/|M|`.  Averaged over a typical
word this says: `m` codewords force `t/m` expected tests, whatever the scheme. -/
theorem card_typical_sq_le_card_mul_sum_decodeCost (P : ScanScheme S A M) (a : A) :
    (P.typical.card : ℚ) ^ 2
      ≤ (Fintype.card M : ℚ) * ∑ x ∈ P.typical, (P.decodeCost a (P.hash a x) : ℚ) := by
  classical
  set T := P.typical with hT
  set F : M → Finset S := fun m => {y ∈ T | P.hash a y = m} with hF
  have hmaps : ∀ x ∈ T, P.hash a x ∈ (Finset.univ : Finset M) := fun _ _ => Finset.mem_univ _
  -- the bucket of `x` is contained in the candidate set, so bucket sizes lower bound the work
  have hb : ∀ x ∈ T, ((F (P.hash a x)).card : ℚ) ≤ (P.decodeCost a (P.hash a x) : ℚ) := by
    intro x hx
    have := Finset.card_le_card (bucket_subset_cand P a x)
    exact_mod_cast this
  have hsum_b : ∑ x ∈ T, ((F (P.hash a x)).card : ℚ) = ∑ m : M, ((F m).card : ℚ) ^ 2 := by
    rw [← Finset.sum_fiberwise_of_maps_to hmaps (fun x => ((F (P.hash a x)).card : ℚ))]
    refine Finset.sum_congr rfl ?_
    intro m _
    have hcongr : ∀ x ∈ {x ∈ T | P.hash a x = m}, ((F (P.hash a x)).card : ℚ)
        = ((F m).card : ℚ) := by
      intro x hx
      rw [Finset.mem_filter] at hx
      rw [hx.2]
    rw [Finset.sum_congr rfl hcongr, Finset.sum_const, nsmul_eq_mul]
    have : ({x ∈ T | P.hash a x = m} : Finset S) = F m := rfl
    rw [this, sq]
  have hcard : ∑ m : M, ((F m).card : ℚ) = (T.card : ℚ) := by
    have := Finset.card_eq_sum_card_fiberwise (f := fun x => P.hash a x) (s := T)
      (t := (Finset.univ : Finset M)) hmaps
    have hq : (T.card : ℚ) = ∑ m : M, (({x ∈ T | P.hash a x = m} : Finset S).card : ℚ) := by
      exact_mod_cast this
    rw [hq]
  have hcheb : (∑ m : M, ((F m).card : ℚ)) ^ 2
      ≤ (Fintype.card M : ℚ) * ∑ m : M, ((F m).card : ℚ) ^ 2 := by
    have := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset M))
      (f := fun m => ((F m).card : ℚ))
    simpa [Finset.card_univ] using this
  calc (T.card : ℚ) ^ 2 = (∑ m : M, ((F m).card : ℚ)) ^ 2 := by rw [hcard]
    _ ≤ (Fintype.card M : ℚ) * ∑ m : M, ((F m).card : ℚ) ^ 2 := hcheb
    _ = (Fintype.card M : ℚ) * ∑ x ∈ T, ((F (P.hash a x)).card : ℚ) := by rw [hsum_b]
    _ ≤ (Fintype.card M : ℚ) * ∑ x ∈ T, (P.decodeCost a (P.hash a x) : ℚ) := by
        have hMnn : (0 : ℚ) ≤ (Fintype.card M : ℚ) := by positivity
        exact mul_le_mul_of_nonneg_left (Finset.sum_le_sum hb) hMnn

omit [DecidableEq S] in
/-- Average form: with `m` codewords, decoding a typical set of size `t` costs
at least `t/m` candidate tests per word — the rate/time hyperbola. -/
theorem avg_decodeCost_ge (P : ScanScheme S A M) (a : A) (hT : P.typical.Nonempty) :
    (P.typical.card : ℚ) / (Fintype.card M : ℚ)
      ≤ (∑ x ∈ P.typical, (P.decodeCost a (P.hash a x) : ℚ)) / (P.typical.card : ℚ) := by
  have htpos : (0 : ℚ) < (P.typical.card : ℚ) := by
    exact_mod_cast Finset.card_pos.2 hT
  have hMpos : (0 : ℚ) < (Fintype.card M : ℚ) := by
    have : 0 < Fintype.card M := by
      have := P.self_mem_cand a _ hT.choose_spec
      exact Fintype.card_pos_iff.2 ⟨P.hash a hT.choose⟩
    exact_mod_cast this
  rw [div_le_div_iff₀ hMpos htpos]
  have h := card_typical_sq_le_card_mul_sum_decodeCost P a
  nlinarith [h, sq_nonneg ((P.typical.card : ℚ))]

end AlmostLossless