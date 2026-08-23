import Probability.MultiFineTuneSharingPhase

/-!
# Rigidity of extremal shared-serving families (hub rigidity)

This file attacks Conjecture 2 of the previous cycle (`FUTURE_DIRECTIONS.md`,
"Hub Rigidity of Extremal Shared-Serving Families").

`MultiFineTuneSharingPhase.sum_agree_sq_bound` proves the multiplicity bound
`s² ≤ s + k(k−1)β` for `s = ∑ᵢ agr(H, Aᵢ)`, and `hub_saturates_multiplicity_bound`
exhibits a family attaining it.  The question left open was whether the hub is the
*only* extremal shape.  The answer proved here is yes, in a precise sense, and it
comes with an unexpected corollary: **saturating configurations are quantised**.

The engine is an exact *defect identity* (`saturation_defect_identity`): with
`N = |Ω|`, `n(x)` the number of fine-tunes the shared model matches at position `x`,
and `pairOverlap` the number of ordered pairs of distinct fine-tunes matched at a
common position,

`N² (s² − s − k(k−1)β) = − spread − N (k(k−1)βN − pairOverlap)`,

where `spread = ½ ∑ₓ ∑_y (n(x) − n(y))²` is the Cauchy–Schwarz defect.  Both
subtracted terms are nonnegative (the second by the pairwise budget), so the bound
is an equality **iff** both vanish.  That gives the two rigidity conditions
conjectured last cycle:

* `saturation_matchCount_constant` — the matched count `n(x)` is the *same at every
  position*: the shared model matches equally many fine-tunes everywhere.
* `saturation_pairwise_tight` — every pair of distinct fine-tunes agrees exactly `β`
  of the time, and *every* position at which two fine-tunes agree is matched by the
  shared model: `agreeSet H (A i) ∩ agreeSet H (A j) = agreeSet (A i) (A j)`.  This
  is exactly the hub geometry: the shared model is the consensus, and the fine-tunes
  deviate from it on sets that overlap as little as the budget allows.
* `saturation_quantised` — the corollary: an extremal family has
  `M = c/k` and `β = c(c−1)/(k(k−1))` for an integer `c ≤ k`.  Extremal serving
  values are therefore *quantised*; the hub family of the previous cycle is the case
  `c = k − 1`, and no family can saturate the bound at a budget `β` outside this
  countable set (`no_saturation_of_irrational_budget`).
-/

namespace Catalog.Probability.SharingRigidity

open Finset
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.MultiFineTuneSharingPhase

variable {Ω Y : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq Y]
variable {k : ℕ}

/-! ### 0. Two elementary tools -/

/-- If `f ≤ g` pointwise on `s` and the sums agree, then `f = g` pointwise on `s`. -/
lemma eq_of_sum_eq_of_le {ι : Type*} (s : Finset ι) (f g : ι → ℝ)
    (hle : ∀ i ∈ s, f i ≤ g i) (heq : ∑ i ∈ s, f i = ∑ i ∈ s, g i) :
    ∀ i ∈ s, f i = g i := by
  intro i hi
  by_contra hne
  have hlt : f i < g i := lt_of_le_of_ne (hle i hi) hne
  have := Finset.sum_lt_sum hle ⟨i, hi, hlt⟩
  linarith

omit [DecidableEq Ω] in
/-- The Cauchy–Schwarz defect as a sum of squares:
`N ∑ f² − (∑ f)² = ½ ∑ₓ ∑_y (f x − f y)²`. -/
lemma card_mul_sum_sq_sub_sq_sum (f : Ω → ℝ) :
    (Fintype.card Ω : ℝ) * (∑ x, (f x) ^ 2) - (∑ x, f x) ^ 2
      = (1 / 2) * ∑ x, ∑ y, (f x - f y) ^ 2 := by
  have expand : ∀ x y : Ω, (f x - f y) ^ 2 = (f x) ^ 2 - 2 * (f x * f y) + (f y) ^ 2 :=
    fun x y => by ring
  simp_rw [expand, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul, ← Finset.mul_sum, ← Finset.sum_mul]
  ring

/-! ### 1. The matched-count profile -/

/-- The number of fine-tunes whose prediction the shared model reproduces at `x`. -/
def matchCount (H : Ω → Y) (A : Fin k → (Ω → Y)) (x : Ω) : ℕ :=
  (univ.filter (fun i => x ∈ agreeSet H (A i))).card

/-- The Cauchy–Schwarz defect of the matched-count profile: it vanishes exactly when
the shared model matches the same number of fine-tunes at every position. -/
noncomputable def spread (H : Ω → Y) (A : Fin k → (Ω → Y)) : ℝ :=
  (1 / 2) * ∑ x : Ω, ∑ y : Ω, ((matchCount H A x : ℝ) - (matchCount H A y : ℝ)) ^ 2

/-- The number of ordered pairs of *distinct* fine-tunes matched at a common
position. -/
noncomputable def pairOverlap (H : Ω → Y) (A : Fin k → (Ω → Y)) : ℝ :=
  ∑ i : Fin k, ∑ j ∈ univ.erase i,
    (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)

lemma spread_nonneg (H : Ω → Y) (A : Fin k → (Ω → Y)) : 0 ≤ spread H A := by
  unfold spread
  have : (0 : ℝ) ≤ ∑ x : Ω, ∑ y : Ω, ((matchCount H A x : ℝ) - (matchCount H A y : ℝ)) ^ 2 :=
    Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _
  linarith

/-- The incidence count: `∑ₓ n(x) = N ∑ᵢ agr(H, Aᵢ)`. -/
lemma sum_matchCount (hN : 0 < Fintype.card Ω) (H : Ω → Y) (A : Fin k → (Ω → Y)) :
    (∑ x : Ω, (matchCount H A x : ℝ))
      = (Fintype.card Ω : ℝ) * ∑ i, agreeFrac H (A i) := by
  classical
  have h0 : ∑ x : Ω, matchCount H A x = ∑ i, ((agreeSet H (A i)).card) :=
    sum_match_count (fun i => agreeSet H (A i))
  have hcast : (∑ x : Ω, (matchCount H A x : ℝ)) = ∑ i, (((agreeSet H (A i)).card : ℝ)) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) h0
  rw [hcast, Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [card_agreeSet_eq hN]
  ring

/-- The second moment of the matched-count profile splits into the diagonal (the
total agreement) plus the off-diagonal overlaps. -/
lemma sum_sq_matchCount (hN : 0 < Fintype.card Ω) (H : Ω → Y) (A : Fin k → (Ω → Y)) :
    (∑ x : Ω, ((matchCount H A x : ℝ)) ^ 2)
      = (Fintype.card Ω : ℝ) * (∑ i, agreeFrac H (A i)) + pairOverlap H A := by
  classical
  have hEq : ∑ x : Ω, (matchCount H A x) ^ 2
      = ∑ i, ∑ j, (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card) :=
    sum_sq_match_count (fun i => agreeSet H (A i))
  have hcast : (∑ x : Ω, ((matchCount H A x : ℝ)) ^ 2)
      = ∑ i : Fin k, ∑ j : Fin k, (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ) := by
    have h1 := congrArg (fun m : ℕ => (m : ℝ)) hEq
    push_cast at h1
    exact h1
  rw [hcast, pairOverlap, Finset.mul_sum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i), Finset.inter_self,
    card_agreeSet_eq hN]
  ring

/-! ### 2. The defect identity -/

/-- **The defect identity.**  The slack in the multiplicity bound is exactly the sum
of the Cauchy–Schwarz defect and the unused pairwise budget.  This is an identity: no
hypothesis on `β` is needed. -/
theorem saturation_defect_identity (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ) :
    (Fintype.card Ω : ℝ) ^ 2 *
        ((∑ i, agreeFrac H (A i)) ^ 2 - (∑ i, agreeFrac H (A i))
          - (k : ℝ) * ((k : ℝ) - 1) * beta)
      = -spread H A
        - (Fintype.card Ω : ℝ) *
            ((k : ℝ) * ((k : ℝ) - 1) * beta * (Fintype.card Ω : ℝ) - pairOverlap H A) := by
  set N : ℝ := (Fintype.card Ω : ℝ) with hNdef
  have hT := sum_matchCount hN H A
  have hQ := sum_sq_matchCount hN H A
  have hvar := card_mul_sum_sq_sub_sq_sum (f := fun x : Ω => (matchCount H A x : ℝ))
  have hspread : spread H A
      = N * (∑ x : Ω, ((matchCount H A x : ℝ)) ^ 2) - (∑ x : Ω, (matchCount H A x : ℝ)) ^ 2 := by
    rw [hvar]
    rfl
  rw [hQ, hT] at hspread
  nlinarith [hspread]

/-- Each pair of distinct fine-tunes contributes at most `βN` to `pairOverlap`. -/
lemma overlap_term_le (hN : 0 < Fintype.card Ω) (H : Ω → Y) (A : Fin k → (Ω → Y))
    (beta : ℝ) (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    {i j : Fin k} (hij : i ≠ j) :
    (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ) ≤ beta * (Fintype.card Ω : ℝ) := by
  have hNpos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have h1 : (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
      ≤ ((agreeSet (A i) (A j)).card : ℝ) := by
    have := Finset.card_le_card (inter_agreeSet_subset H (A i) (A j))
    exact_mod_cast this
  have h2 : ((agreeSet (A i) (A j)).card : ℝ) = agreeFrac (A i) (A j) * (Fintype.card Ω : ℝ) :=
    card_agreeSet_eq hN _ _
  have h3 : agreeFrac (A i) (A j) * (Fintype.card Ω : ℝ) ≤ beta * (Fintype.card Ω : ℝ) :=
    mul_le_mul_of_nonneg_right (hpair i j hij) hNpos.le
  linarith [h2 ▸ h1]

/-- The pairwise budget bounds the total overlap. -/
lemma pairOverlap_le (hN : 0 < Fintype.card Ω) (H : Ω → Y) (A : Fin k → (Ω → Y))
    (beta : ℝ) (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta) :
    pairOverlap H A ≤ (k : ℝ) * ((k : ℝ) - 1) * beta * (Fintype.card Ω : ℝ) := by
  classical
  have hrow : ∀ i : Fin k,
      ∑ j ∈ univ.erase i, (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
        ≤ ((k : ℝ) - 1) * (beta * (Fintype.card Ω : ℝ)) := by
    intro i
    have hle : ∀ j ∈ univ.erase i,
        (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
          ≤ beta * (Fintype.card Ω : ℝ) := by
      intro j hj
      exact overlap_term_le hN H A beta hpair (fun h => (Finset.ne_of_mem_erase hj) h.symm)
    have hsum := Finset.sum_le_sum hle
    rw [Finset.sum_const, nsmul_eq_mul] at hsum
    have hcard : (((univ : Finset (Fin k)).erase i).card : ℝ) = (k : ℝ) - 1 := by
      have h1 : ((univ : Finset (Fin k)).erase i).card = k - 1 := by
        rw [Finset.card_erase_of_mem (Finset.mem_univ i)]; simp
      have hk1 : 1 ≤ k := Fin.pos i
      rw [h1]; push_cast [Nat.cast_sub hk1]; ring
    rw [hcard] at hsum
    exact hsum
  have hall := Finset.sum_le_sum (fun i (_ : i ∈ (univ : Finset (Fin k))) => hrow i)
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at hall
  calc pairOverlap H A ≤ (k : ℝ) * (((k : ℝ) - 1) * (beta * (Fintype.card Ω : ℝ))) := hall
    _ = (k : ℝ) * ((k : ℝ) - 1) * beta * (Fintype.card Ω : ℝ) := by ring

/-! ### 3. The two rigidity conditions -/

/-- The saturation hypothesis: the multiplicity bound of `sum_agree_sq_bound` holds
with equality. -/
def Saturates (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ) : Prop :=
  (∑ i, agreeFrac H (A i)) ^ 2
    = (∑ i, agreeFrac H (A i)) + (k : ℝ) * ((k : ℝ) - 1) * beta

/-- Under saturation both defects vanish. -/
lemma defects_vanish (hN : 0 < Fintype.card Ω) (H : Ω → Y) (A : Fin k → (Ω → Y))
    (beta : ℝ) (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    (hsat : Saturates H A beta) :
    spread H A = 0 ∧
      pairOverlap H A = (k : ℝ) * ((k : ℝ) - 1) * beta * (Fintype.card Ω : ℝ) := by
  have hNpos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have hid := saturation_defect_identity hN H A beta
  have hzero : (Fintype.card Ω : ℝ) ^ 2 *
      ((∑ i, agreeFrac H (A i)) ^ 2 - (∑ i, agreeFrac H (A i))
        - (k : ℝ) * ((k : ℝ) - 1) * beta) = 0 := by
    unfold Saturates at hsat
    rw [hsat]; ring
  rw [hzero] at hid
  have hs := spread_nonneg H A
  have hb := pairOverlap_le hN H A beta hpair
  constructor
  · nlinarith [hid, hs, hb, hNpos]
  · nlinarith [hid, hs, hb, hNpos]

/-- **First rigidity condition: constant multiplicity.**  If the multiplicity bound is
attained, the shared model matches exactly the same number of fine-tunes at every
position.  (Equality in the Cauchy–Schwarz step of the bound.) -/
theorem saturation_matchCount_constant (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    (hsat : Saturates H A beta) :
    ∀ x y : Ω, matchCount H A x = matchCount H A y := by
  obtain ⟨hs, -⟩ := defects_vanish hN H A beta hpair hsat
  intro x y
  have hsum : ∑ x : Ω, ∑ y : Ω, ((matchCount H A x : ℝ) - (matchCount H A y : ℝ)) ^ 2 = 0 := by
    unfold spread at hs; linarith
  have hrow : ∀ x ∈ (univ : Finset Ω),
      ∑ y : Ω, ((matchCount H A x : ℝ) - (matchCount H A y : ℝ)) ^ 2 = 0 := by
    refine (Finset.sum_eq_zero_iff_of_nonneg ?_).1 hsum
    intro x _
    exact Finset.sum_nonneg fun _ _ => sq_nonneg _
  have hxy : ((matchCount H A x : ℝ) - (matchCount H A y : ℝ)) ^ 2 = 0 := by
    refine (Finset.sum_eq_zero_iff_of_nonneg ?_).1 (hrow x (Finset.mem_univ x)) y
      (Finset.mem_univ y)
    intro _ _
    exact sq_nonneg _
  have : (matchCount H A x : ℝ) = (matchCount H A y : ℝ) := by
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hxy
    linarith
  exact_mod_cast this

/-- **Second rigidity condition: the pairwise budget is exhausted, and the shared
model is the consensus.**  If the multiplicity bound is attained then every pair of
distinct fine-tunes agrees exactly `β` of the time, *and* every position at which two
fine-tunes agree is a position at which the shared model matches both.  This is the
hub geometry conjectured last cycle. -/
theorem saturation_pairwise_tight (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    (hsat : Saturates H A beta) :
    ∀ i j, i ≠ j →
      agreeFrac (A i) (A j) = beta ∧
      (agreeSet H (A i)) ∩ (agreeSet H (A j)) = agreeSet (A i) (A j) := by
  classical
  obtain ⟨-, hP⟩ := defects_vanish hN H A beta hpair hsat
  have hNpos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  -- each row attains its bound
  have hrowle : ∀ i ∈ (univ : Finset (Fin k)),
      ∑ j ∈ univ.erase i, (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
        ≤ ((k : ℝ) - 1) * (beta * (Fintype.card Ω : ℝ)) := by
    intro i _
    have hle : ∀ j ∈ univ.erase i,
        (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
          ≤ beta * (Fintype.card Ω : ℝ) := by
      intro j hj
      exact overlap_term_le hN H A beta hpair (fun h => (Finset.ne_of_mem_erase hj) h.symm)
    have hsum := Finset.sum_le_sum hle
    rw [Finset.sum_const, nsmul_eq_mul] at hsum
    have hcard : (((univ : Finset (Fin k)).erase i).card : ℝ) = (k : ℝ) - 1 := by
      have h1 : ((univ : Finset (Fin k)).erase i).card = k - 1 := by
        rw [Finset.card_erase_of_mem (Finset.mem_univ i)]; simp
      have hk1 : 1 ≤ k := Fin.pos i
      rw [h1]; push_cast [Nat.cast_sub hk1]; ring
    rw [hcard] at hsum
    exact hsum
  have htot : ∑ i : Fin k, ∑ j ∈ univ.erase i,
      (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
        = ∑ _i : Fin k, ((k : ℝ) - 1) * (beta * (Fintype.card Ω : ℝ)) := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    rw [← pairOverlap, hP]; ring
  have hrow := eq_of_sum_eq_of_le (univ : Finset (Fin k))
    (fun i => ∑ j ∈ univ.erase i, (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ))
    (fun _ => ((k : ℝ) - 1) * (beta * (Fintype.card Ω : ℝ))) hrowle htot
  intro i j hij
  have hjmem : j ∈ (univ : Finset (Fin k)).erase i :=
    Finset.mem_erase.2 ⟨Ne.symm hij, Finset.mem_univ j⟩
  -- inside the row, every term attains its bound
  have hle : ∀ j' ∈ (univ : Finset (Fin k)).erase i,
      (((agreeSet H (A i)) ∩ (agreeSet H (A j'))).card : ℝ)
        ≤ beta * (Fintype.card Ω : ℝ) := by
    intro j' hj'
    exact overlap_term_le hN H A beta hpair (fun h => (Finset.ne_of_mem_erase hj') h.symm)
  have hrowsum : ∑ j' ∈ (univ : Finset (Fin k)).erase i,
      (((agreeSet H (A i)) ∩ (agreeSet H (A j'))).card : ℝ)
      = ∑ _j' ∈ (univ : Finset (Fin k)).erase i, beta * (Fintype.card Ω : ℝ) := by
    rw [Finset.sum_const, nsmul_eq_mul]
    have hcard : (((univ : Finset (Fin k)).erase i).card : ℝ) = (k : ℝ) - 1 := by
      have h1 : ((univ : Finset (Fin k)).erase i).card = k - 1 := by
        rw [Finset.card_erase_of_mem (Finset.mem_univ i)]; simp
      have hk1 : 1 ≤ k := Fin.pos i
      rw [h1]; push_cast [Nat.cast_sub hk1]; ring
    rw [hcard]
    exact hrow i (Finset.mem_univ i)
  have hterm : (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
      = beta * (Fintype.card Ω : ℝ) :=
    eq_of_sum_eq_of_le ((univ : Finset (Fin k)).erase i)
      (fun j' => (((agreeSet H (A i)) ∩ (agreeSet H (A j'))).card : ℝ))
      (fun _ => beta * (Fintype.card Ω : ℝ)) hle hrowsum j hjmem
  -- now translate the numerical equality into set equality
  have hsub : (agreeSet H (A i)) ∩ (agreeSet H (A j)) ⊆ agreeSet (A i) (A j) :=
    inter_agreeSet_subset H (A i) (A j)
  have hcards : (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ)
      ≤ ((agreeSet (A i) (A j)).card : ℝ) := by
    exact_mod_cast Finset.card_le_card hsub
  have hcardA : ((agreeSet (A i) (A j)).card : ℝ)
      = agreeFrac (A i) (A j) * (Fintype.card Ω : ℝ) := card_agreeSet_eq hN _ _
  have hAle : agreeFrac (A i) (A j) * (Fintype.card Ω : ℝ) ≤ beta * (Fintype.card Ω : ℝ) :=
    mul_le_mul_of_nonneg_right (hpair i j hij) hNpos.le
  have hbetaEq : agreeFrac (A i) (A j) = beta := by
    have h1 : beta * (Fintype.card Ω : ℝ) ≤ agreeFrac (A i) (A j) * (Fintype.card Ω : ℝ) := by
      rw [← hcardA]; linarith [hterm, hcards]
    have := le_antisymm hAle h1
    exact mul_right_cancel₀ (ne_of_gt hNpos) this
  refine ⟨hbetaEq, ?_⟩
  have hcardeq : ((agreeSet (A i) (A j)).card : ℝ)
      = (((agreeSet H (A i)) ∩ (agreeSet H (A j))).card : ℝ) := by
    rw [hcardA, hbetaEq, hterm]
  have hcardeqN : (agreeSet (A i) (A j)).card
      = ((agreeSet H (A i)) ∩ (agreeSet H (A j))).card := by exact_mod_cast hcardeq
  exact Finset.eq_of_subset_of_card_le hsub (le_of_eq hcardeqN)

/-! ### 4. Quantisation of extremal serving values -/

/-- **Extremal serving values are quantised.**  If a family of `k ≥ 2` fine-tunes and a
shared model attain the multiplicity bound, then there is an integer `c ≤ k` — the
common number of fine-tunes matched at each position — with

`meanAgree H A = c / k` and `β = c(c−1) / (k(k−1))`.

So the extremal pairs `(β, M)` form a *finite* set for each `k`: the hub family of the
previous cycle is the case `c = k − 1`, giving `β = 1 − 2/k` and `M = 1 − 1/k`. -/
theorem saturation_quantised (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    (hsat : Saturates H A beta) :
    ∃ c : ℕ, c ≤ k ∧
      meanAgree H A = (c : ℝ) / (k : ℝ) ∧
      beta = ((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1)) := by
  classical
  have hNpos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hne : Nonempty Ω := Fintype.card_pos_iff.1 hN
  obtain ⟨x0⟩ := hne
  set c : ℕ := matchCount H A x0 with hc
  have hconst := saturation_matchCount_constant hN H A beta hpair hsat
  have hcle : c ≤ k := by
    have h1 : ((univ : Finset (Fin k)).filter (fun i => x0 ∈ agreeSet H (A i))).card
        ≤ (univ : Finset (Fin k)).card := Finset.card_filter_le _ _
    simpa [matchCount, hc, Finset.card_univ] using h1
  -- the total incidence count
  have hsumc : (∑ x : Ω, (matchCount H A x : ℝ)) = (c : ℝ) * (Fintype.card Ω : ℝ) := by
    have : ∀ x : Ω, (matchCount H A x : ℝ) = (c : ℝ) := by
      intro x
      rw [hc, hconst x x0]
    rw [Finset.sum_congr rfl (fun x _ => this x), Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul]
    ring
  have hT := sum_matchCount hN H A
  have hsum_agree : (∑ i, agreeFrac H (A i)) = (c : ℝ) := by
    have hmul : (Fintype.card Ω : ℝ) * (∑ i, agreeFrac H (A i))
        = (Fintype.card Ω : ℝ) * (c : ℝ) := by
      rw [← hT, hsumc]; ring
    exact mul_left_cancel₀ (ne_of_gt hNpos) hmul
  refine ⟨c, hcle, ?_, ?_⟩
  · unfold meanAgree
    rw [hsum_agree]
  · unfold Saturates at hsat
    rw [hsum_agree] at hsat
    have hkne : ((k : ℝ) * ((k : ℝ) - 1)) ≠ 0 := by
      have : (0 : ℝ) < (k : ℝ) * ((k : ℝ) - 1) := by nlinarith
      exact ne_of_gt this
    rw [eq_div_iff hkne]
    linear_combination -hsat

/-- The hub family of the previous cycle is the quantised case `c = k − 1`. -/
theorem hub_is_quantised_case (hk : 2 ≤ k) :
    ((((k : ℝ) - 1) * (((k : ℝ) - 1) - 1)) / ((k : ℝ) * ((k : ℝ) - 1)) = 1 - 2 / (k : ℝ))
      ∧ (((k : ℝ) - 1) / (k : ℝ) = 1 - 1 / (k : ℝ)) := by
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have hk1 : (k : ℝ) - 1 ≠ 0 := by intro h; linarith [h]
  constructor
  · field_simp
    ring
  · field_simp

/-- **No extremal family at a generic budget.**  Since the saturating budgets form the
finite set `{c(c−1)/(k(k−1)) : c ≤ k}` of rationals, a family whose pairwise budget is
irrational can never attain the multiplicity bound — the bound is then automatically
strict. -/
theorem no_saturation_of_irrational_budget (hN : 0 < Fintype.card Ω) (hk : 2 ≤ k)
    (H : Ω → Y) (A : Fin k → (Ω → Y)) (beta : ℝ)
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ beta)
    (hirr : Irrational beta) :
    ¬ Saturates H A beta := by
  intro hsat
  obtain ⟨c, -, -, hbeta⟩ := saturation_quantised hN hk H A beta hpair hsat
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hrat : ¬ Irrational beta := by
    rw [hbeta]
    intro hcon
    have : ((((c : ℚ) * ((c : ℚ) - 1)) / ((k : ℚ) * ((k : ℚ) - 1)) : ℚ) : ℝ)
        = ((c : ℝ) * ((c : ℝ) - 1)) / ((k : ℝ) * ((k : ℝ) - 1)) := by
      push_cast
      ring
    exact (Rat.not_irrational _) (this ▸ hcon)
  exact hrat hirr

/-! ### 5. The rigidity theorems are not vacuous, and a NET-54 corollary -/

/-- The hub family of the previous cycle really does saturate the multiplicity bound,
so the rigidity theorems above have content: their hypothesis is satisfiable for every
`k ≥ 2`. -/
theorem hub_saturates (hk : 2 ≤ k) :
    ∃ (A : Fin k → (Fin k → Fin 2)) (H : Fin k → Fin 2) (beta : ℝ),
      beta = 1 - 2 / (k : ℝ) ∧
      (∀ i j, i ≠ j → agreeFrac (A i) (A j) = beta) ∧
      Saturates H A beta := by
  obtain ⟨A, H, beta, hbeta, hp, hmean, -⟩ := hub_saturates_multiplicity_bound (k := k) hk
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hk0 : (k : ℝ) ≠ 0 := by intro h; rw [h] at hkR; linarith
  refine ⟨A, H, beta, hbeta, hp, ?_⟩
  have hsum : (∑ i, agreeFrac H (A i)) = (k : ℝ) - 1 := by
    have h1 : (∑ i, agreeFrac H (A i)) / (k : ℝ) = (1 + beta) / 2 := hmean
    rw [div_eq_iff hk0, hbeta] at h1
    rw [h1]
    field_simp
    ring
  unfold Saturates
  rw [hsum, hbeta]
  field_simp
  ring

/-- **No extremal family at the measured NET-54 budget.**  The cross-parent agreement
`β = 0.8327` is not of the quantised form `c(c−1)/(k(k−1))` for `k = 12`, so a family of
twelve fine-tunes at that budget can never saturate the multiplicity bound: for such a
family the serving bound is *strict*, and the shortfall is not an artefact of the proof
but a consequence of the arithmetic of the budget. -/
theorem net54_no_saturating_family_of_twelve (hN : 0 < Fintype.card Ω)
    (H : Ω → Y) (A : Fin 12 → (Ω → Y))
    (hpair : ∀ i j, i ≠ j → agreeFrac (A i) (A j) ≤ 0.8327) :
    ¬ Saturates H A 0.8327 := by
  intro hsat
  obtain ⟨c, hcle, -, hbeta⟩ := saturation_quantised hN (by norm_num) H A 0.8327 hpair hsat
  have hkey : (c : ℝ) * ((c : ℝ) - 1) = 109.9164 := by
    have h12 : (((12 : ℕ) : ℝ) * (((12 : ℕ) : ℝ) - 1)) = 132 := by norm_num
    rw [h12] at hbeta
    field_simp at hbeta
    linarith
  interval_cases c <;> norm_num at hkey

end Catalog.Probability.SharingRigidity