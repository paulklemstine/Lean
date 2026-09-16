/-
# The semiprime layer of the quintic type channel, and the coset-bookkeeping test

Companion to `Bridges.QuinticTypeChannelF20`.  There the *single-prime* channel of the
Frobenius field `F₂₀ = AGL(1,5)` of `x⁵ - 2` was evaluated: `I(p mod 5 ; T) = 3/2`.
Here we do the semiprime layer, where an adversary sees the **pair of splitting types**
`{T(p), T(q)}` of the two prime factors of `N = p q` together with the residue class of
`N mod 5` — the `C₄` dial of the product.

## Results

* `quintic_pair_law` — **the pair law**: `I({T(p),T(q)} ; N mod 5) = 5/4` exactly.  The
  semiprime reads `1.25` of the two available bits of the quartic dial; the `log₂ 5` of the
  quintic entropy cancels completely, as at the prime level.
* `quintic_pair_eq_C4_pair` — the bridge: that number is *verbatim* the catalog's cyclotomic
  `C₄` pair channel `Ipair 4 = 5/4` of `ℚ(ζ₅)` (`CyclicTypeChannel.Ipair_val_4`).  The
  non-abelian degree-five object reads its abelianization's pair channel exactly.
* `which_factor_wall_zero` — knowing *which* factor carries which type is worth nothing:
  the unordered pair channel has the same value `5/4`.
* `quintic_fork_eq_Isplit_four` — the `[1,2,2]`-fork (the type occurring exactly for
  `p ≡ 4 mod 5`) is an **order-4 pinned fork on a non-abelian field**, and its split-count
  channel equals the catalog's `Isplit 4 = 19/8 - (21/16) log₂ 3` on the nose.
* `coset_swap_invisible_at_prime_level`, `swap_pair_law`,
  `coset_swap_detected_only_by_the_pair_law` — **the instructive failure, formalized.**
  Relabelling the two order-4 cosets against the `C₄` valuation (putting `[1,2,2]` on
  `e = 3` instead of `e = 2`) leaves *every* prime-level quantity unchanged — same type
  entropy, same dial, same `3/2` — yet moves the pair law from `5/4` to `9/8`.  The pair
  channel is therefore the discriminating test of coset bookkeeping exactly where
  type-merging hides the error.
-/
import Bridges.QuinticTypeChannelF20
import Bridges.QuinticTypeChannelF20Converse
import Shared.CyclicTypeChannelValues
import Shared.CyclicTypeChannelCap

namespace QuinticF20Pair

open Finset CyclicTypeChannel QuinticF20

set_option maxRecDepth 1000000

/-! ## 0. Logarithm bookkeeping -/

lemma lbq_40 : Real.logb 2 (40 : ℝ) = 3 + Real.logb 2 5 := by
  rw [show (40 : ℝ) = 8 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_8]

lemma lbq_50 : Real.logb 2 (50 : ℝ) = 1 + 2 * Real.logb 2 5 := by
  rw [show (50 : ℝ) = 2 * 25 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_25,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]

lemma lbq_80 : Real.logb 2 (80 : ℝ) = 4 + Real.logb 2 5 := by
  rw [show (80 : ℝ) = 16 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_16]

lemma lbq_400 : Real.logb 2 (400 : ℝ) = 4 + 2 * Real.logb 2 5 := by
  rw [show (400 : ℝ) = 16 * 25 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_16,
    lb_25]

lemma lbq_75 : Real.logb 2 (75 : ℝ) = Real.logb 2 3 + 2 * Real.logb 2 5 := by
  rw [show (75 : ℝ) = 3 * 25 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_25]

lemma lbq_150 : Real.logb 2 (150 : ℝ) = 1 + Real.logb 2 3 + 2 * Real.logb 2 5 := by
  rw [show (150 : ℝ) = 2 * 75 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lbq_75,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
  ring

/-! ## 1. The semiprime box -/

/-- The Chebotarev box of a semiprime `N = p q`: the two Frobenius classes vary
independently over `F₂₀`. -/
def qBox : Finset (ℕ × ℕ) := qFrob ×ˢ qFrob

/-- The ordered pair of quintic splitting types seen by the adversary. -/
def qPairType (p : ℕ × ℕ) : ℕ × ℕ := (qType p.1, qType p.2)

/-- The unordered pair of types: the adversary is not told which factor is which. -/
def qPairUnord (p : ℕ × ℕ) : ℕ × ℕ := (min (qType p.1) (qType p.2), max (qType p.1) (qType p.2))

/-- The dial of the semiprime: the `C₄` class of `N mod 5`, i.e. the sum of the two
valuations mod 4. -/
def qProdDial (p : ℕ × ℕ) : ℕ := (qDial p.1 + qDial p.2) % 4

/-- The split-count read-out of the `[1,2,2]`-fork: how many of the two prime factors are
`≡ 4 mod 5`. -/
def qFork (p : ℕ × ℕ) : ℕ :=
  (if qType p.1 = 122 then 1 else 0) + (if qType p.2 = 122 then 1 else 0)

lemma qBox_card : qBox.card = 400 := by decide

lemma qProdDial_image : qBox.image qProdDial = range 4 := by decide

lemma qClass_card_0 : #{x ∈ qBox | qProdDial x = 0} = 100 := by decide
lemma qClass_card_1 : #{x ∈ qBox | qProdDial x = 1} = 100 := by decide
lemma qClass_card_2 : #{x ∈ qBox | qProdDial x = 2} = 100 := by decide
lemma qClass_card_3 : #{x ∈ qBox | qProdDial x = 3} = 100 := by decide

/-! ## 2. The ordered pair channel -/

/-- The joint entropy of the two splitting types: `H(Π) = 11/5 + (log₂ 5)/2 = 3.3610…`,
exactly twice the single-prime entropy (the two Frobenii are independent). -/
theorem qPairEntropy_val : uEnt qBox qPairType = 11 / 5 + (1 / 2) * Real.logb 2 5 := by
  have h : (qBox.image qPairType).val.map (fun v => (#{x ∈ qBox | qPairType x = v} : ℕ))
      = (↑[1, 4, 5, 10, 4, 16, 20, 40, 5, 20, 25, 50, 10, 40, 50, 100] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, qBox_card]
  norm_num [lbq_400, lbq_50, lbq_40, lb_25, lb_16, lb_10, lb_4, lbq_20, lb_100]
  ring

/-- The conditional entropy of the type pair given `N mod 5`. -/
theorem qCondPairEntropy_val :
    condEnt qBox qPairType qProdDial = 19 / 20 + (1 / 2) * Real.logb 2 5 := by
  have e0 : uEnt {x ∈ qBox | qProdDial x = 0} qPairType = 7 / 10 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 0}).image qPairType).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 0} | qPairType q = v} : ℕ))
        = (↑[1, 4, 4, 16, 25, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_0]
    norm_num [lbq_50, lb_25, lb_16, lb_4, lb_100]
    ring
  have e1 : uEnt {x ∈ qBox | qProdDial x = 1} qPairType = 6 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 1}).image qPairType).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 1} | qPairType q = v} : ℕ))
        = (↑[5, 20, 5, 20, 25, 25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_1]
    norm_num [lb_25, lbq_20, lb_100]
    ring
  have e2 : uEnt {x ∈ qBox | qProdDial x = 2} qPairType = 7 / 10 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 2}).image qPairType).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 2} | qPairType q = v} : ℕ))
        = (↑[5, 20, 5, 20, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_2]
    norm_num [lbq_50, lbq_20, lb_100]
    ring
  have e3 : uEnt {x ∈ qBox | qProdDial x = 3} qPairType = 6 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 3}).image qPairType).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 3} | qPairType q = v} : ℕ))
        = (↑[5, 20, 25, 25, 5, 20] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_3]
    norm_num [lb_25, lbq_20, lb_100]
    ring
  rw [condEnt, qProdDial_image, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_one, e0, e1, e2, e3, qBox_card,
    qClass_card_0, qClass_card_1, qClass_card_2, qClass_card_3]
  norm_num
  ring

/-- **THE QUINTIC PAIR LAW.**  The type pair of a semiprime transmits exactly `5/4` bits
about `N mod 5`: the largest fraction of a merged-type dial in the program, and again a
rational number — the `log₂ 5` cancels. -/
theorem quintic_pair_law : mutInfo qBox qPairType qProdDial = 5 / 4 := by
  rw [mutInfo, qPairEntropy_val, qCondPairEntropy_val]; ring

/-- **The bridge to the abelianization.**  The `F₂₀` semiprime pair law is *verbatim* the
cyclotomic `C₄` pair channel of `ℚ(ζ₅)`: the non-abelian quintic field reads exactly the
pair channel of its abelianization. -/
theorem quintic_pair_eq_C4_pair : mutInfo qBox qPairType qProdDial = Ipair 4 := by
  rw [quintic_pair_law, Ipair_val_4]

/-! ## 3. The which-factor wall -/

/-- Entropy of the unordered type pair. -/
theorem qPairUnordEntropy_val :
    uEnt qBox qPairUnord = 311 / 200 + (1 / 2) * Real.logb 2 5 := by
  have h : (qBox.image qPairUnord).val.map (fun v => (#{x ∈ qBox | qPairUnord x = v} : ℕ))
      = (↑[1, 8, 16, 10, 40, 25, 20, 80, 100, 100] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, qBox_card]
  norm_num [lbq_400, lbq_80, lbq_40, lb_25, lb_16, lb_10, lb_8, lbq_20, lb_100]
  ring

/-- Conditional entropy of the unordered type pair given `N mod 5`. -/
theorem qCondPairUnordEntropy_val :
    condEnt qBox qPairUnord qProdDial = 61 / 200 + (1 / 2) * Real.logb 2 5 := by
  have e0 : uEnt {x ∈ qBox | qProdDial x = 0} qPairUnord
      = 31 / 50 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 0}).image qPairUnord).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 0} | qPairUnord q = v} : ℕ))
        = (↑[1, 8, 16, 25, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_0]
    norm_num [lbq_50, lb_25, lb_16, lb_8, lb_100]
    ring
  have e1 : uEnt {x ∈ qBox | qProdDial x = 1} qPairUnord
      = 1 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 1}).image qPairUnord).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 1} | qPairUnord q = v} : ℕ))
        = (↑[10, 40, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_1]
    norm_num [lbq_50, lbq_40, lb_10, lb_100]
    ring
  have e2 : uEnt {x ∈ qBox | qProdDial x = 2} qPairUnord
      = 1 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 2}).image qPairUnord).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 2} | qPairUnord q = v} : ℕ))
        = (↑[10, 40, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_2]
    norm_num [lbq_50, lbq_40, lb_10, lb_100]
    ring
  have e3 : uEnt {x ∈ qBox | qProdDial x = 3} qPairUnord
      = 1 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 3}).image qPairUnord).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 3} | qPairUnord q = v} : ℕ))
        = (↑[50, 10, 40] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_3]
    norm_num [lbq_50, lbq_40, lb_10, lb_100]
    ring
  rw [condEnt, qProdDial_image, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_one, e0, e1, e2, e3, qBox_card,
    qClass_card_0, qClass_card_1, qClass_card_2, qClass_card_3]
  norm_num
  ring

/-- **The which-factor wall is zero.**  Telling the adversary which of the two prime factors
carries which splitting type adds no information about `N mod 5` whatsoever: the ordered and
unordered pair channels agree. -/
theorem which_factor_wall_zero :
    mutInfo qBox qPairUnord qProdDial = mutInfo qBox qPairType qProdDial := by
  rw [mutInfo, qPairUnordEntropy_val, qCondPairUnordEntropy_val, quintic_pair_law]; ring

/-! ## 4. The `[1,2,2]`-fork: an order-4 pinned fork on a non-abelian field -/

/-- The entropy of the fork's split count. -/
theorem qForkEntropy_val : uEnt qBox qFork = 29 / 8 - (3 / 2) * Real.logb 2 3 := by
  have h : (qBox.image qFork).val.map (fun v => (#{x ∈ qBox | qFork x = v} : ℕ))
      = (↑[25, 150, 225] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, qBox_card]
  norm_num [lbq_400, lbq_150, lb_25, lb_225]
  ring

/-- The conditional entropy of the fork's split count given `N mod 5`. -/
theorem qCondForkEntropy_val :
    condEnt qBox qFork qProdDial = 5 / 4 - (3 / 16) * Real.logb 2 3 := by
  have e0 : uEnt {x ∈ qBox | qProdDial x = 0} qFork = 2 - (3 / 4) * Real.logb 2 3 := by
    have h : (({x ∈ qBox | qProdDial x = 0}).image qFork).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 0} | qFork q = v} : ℕ))
        = (↑[25, 75] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_0]
    norm_num [lbq_75, lb_25, lb_100]
    ring
  have e1 : uEnt {x ∈ qBox | qProdDial x = 1} qFork = 1 := by
    have h : (({x ∈ qBox | qProdDial x = 1}).image qFork).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 1} | qFork q = v} : ℕ))
        = (↑[50, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_1]
    norm_num [lbq_50, lb_100]
    ring
  have e2 : uEnt {x ∈ qBox | qProdDial x = 2} qFork = 1 := by
    have h : (({x ∈ qBox | qProdDial x = 2}).image qFork).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 2} | qFork q = v} : ℕ))
        = (↑[50, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_2]
    norm_num [lbq_50, lb_100]
    ring
  have e3 : uEnt {x ∈ qBox | qProdDial x = 3} qFork = 1 := by
    have h : (({x ∈ qBox | qProdDial x = 3}).image qFork).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 3} | qFork q = v} : ℕ))
        = (↑[50, 50] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_3]
    norm_num [lbq_50, lb_100]
    ring
  rw [condEnt, qProdDial_image, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_one, e0, e1, e2, e3, qBox_card,
    qClass_card_0, qClass_card_1, qClass_card_2, qClass_card_3]
  norm_num
  ring

/-- **The `[1,2,2]`-fork is an order-4 pinned fork on a non-abelian field**, and it realizes
the catalog's `Is(4)` exactly: `I(fork ; N mod 5) = Isplit 4 = 19/8 - (21/16) log₂ 3`.
Before this, order-4 split-count forks existed in the catalog only over abelian `V₄` and the
joint-`AND` `D₄` fork. -/
theorem quintic_fork_eq_Isplit_four : mutInfo qBox qFork qProdDial = Isplit 4 := by
  rw [mutInfo, qForkEntropy_val, qCondForkEntropy_val, Isplit_val_4]
  ring

/-! ## 5. The instructive failure: swapping the two order-4 coset labels

`qTypeSwap` is the same splitting-type dictionary, but with the order-2 multiplier placed on
the valuation `e = 3` instead of `e = 2` — i.e. the labels `V(3)` and `V(4)` interchanged
relative to the `C₄` valuation.  Every prime-level statistic is unchanged, because the two
order-4 cosets are merged by the type `[1,4]` anyway; the pair channel is not. -/

/-- The mislabelled splitting-type dictionary. -/
def qTypeSwap (x : ℕ) : ℕ :=
  if x / 5 = 0 then (if x % 5 = 0 then 1 else 5) else if x / 5 = 3 then 122 else 14

/-- The pair read-out of the mislabelled dictionary. -/
def qPairTypeSwap (p : ℕ × ℕ) : ℕ × ℕ := (qTypeSwap p.1, qTypeSwap p.2)

lemma qTypeSwap_image : qFrob.image qTypeSwap = ({1, 5, 14, 122} : Finset ℕ) := by decide

lemma qTypeSwap_fiber_1 : #{x ∈ qFrob | qTypeSwap x = 1} = 1 := by decide
lemma qTypeSwap_fiber_5 : #{x ∈ qFrob | qTypeSwap x = 5} = 4 := by decide
lemma qTypeSwap_fiber_14 : #{x ∈ qFrob | qTypeSwap x = 14} = 10 := by decide
lemma qTypeSwap_fiber_122 : #{x ∈ qFrob | qTypeSwap x = 122} = 5 := by decide

lemma qDial_uniform_in_swap_fibers :
    ∀ t ∈ qFrob.image qTypeSwap, ∀ a ∈ ({x ∈ qFrob | qTypeSwap x = t} : Finset ℕ),
      #{x ∈ ({y ∈ qFrob | qTypeSwap y = t} : Finset ℕ) | qDial x = qDial a}
        = qMergeSize t := by
  decide

/-- The mislabelled dictionary has the *same* splitting entropy. -/
theorem qTypeSwap_entropy : uEnt qFrob qTypeSwap = uEnt qFrob qType := by
  have h : (qFrob.image qTypeSwap).val.map (fun v => (#{x ∈ qFrob | qTypeSwap x = v} : ℕ))
      = (↑[1, 4, 5, 10] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, qFrob_card, quinticTypeEntropy_val]
  norm_num [lbq_20, lb_10, lb_4]
  ring

/-- **The coset swap is invisible at the prime level.**  Since the type `[1,4]` merges the
two order-4 cosets in either labelling, the merged-coset sum — and hence the transmitted
information — is unchanged: still exactly `3/2`. -/
theorem coset_swap_invisible_at_prime_level : mutInfo qFrob qTypeSwap qDial = 3 / 2 := by
  have hgap := dial_gap_eq_merge_entropy qFrob_nonempty qTypeSwap qDial qMergeSize
    qDial_uniform_in_swap_fibers
  have hsum : ∑ t ∈ qFrob.image qTypeSwap,
      ((#{x ∈ qFrob | qTypeSwap x = t} : ℝ) / qFrob.card) *
        (Real.logb 2 (#{x ∈ qFrob | qTypeSwap x = t} : ℝ) - Real.logb 2 (qMergeSize t : ℝ))
      = 1 / 2 := by
    rw [qTypeSwap_image]
    rw [show ({1, 5, 14, 122} : Finset ℕ) = insert 1 (insert 5 (insert 14 {122})) from rfl]
    rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
      Finset.sum_insert (by decide), Finset.sum_singleton]
    rw [qTypeSwap_fiber_1, qTypeSwap_fiber_5, qTypeSwap_fiber_14, qTypeSwap_fiber_122,
      qFrob_card]
    norm_num [qMergeSize, lb_10, lb_4]
  rw [quinticDialEntropy_val, hsum] at hgap
  linarith

/-- **The invisibility is structural, not numerical.**  The two labellings have the same
merge pattern — same densities, same number of merged cosets — so merge-pattern invariance
(`QuinticF20.mutInfo_eq_of_merge_pattern_bij`) forces the two prime-level channels to agree
without computing either of them. -/
theorem coset_swap_invisible_by_merge_invariance :
    mutInfo qFrob qTypeSwap qDial = mutInfo qFrob qType qDial := by
  have hfib : ∀ t ∈ qFrob.image qTypeSwap,
      #{x ∈ qFrob | qTypeSwap x = t} = #{x ∈ qFrob | qType x = t} := by decide
  refine mutInfo_eq_of_merge_pattern_bij (c := qMergeSize) (c' := qMergeSize)
    qFrob_nonempty qFrob_nonempty qDial_uniform_in_swap_fibers qDial_uniform_in_type_fibers
    rfl id (by decide) (fun _ _ _ _ hst => hst) (by decide) ?_ ?_
  · intro t ht
    simp only [id_eq, hfib t ht]
  · intro t ht
    simp only [id_eq, hfib t ht]

/-- The prime-level information transmitted by the non-abelian quintic channel is exactly
the *entire* type entropy of the `C₄` cyclotomic channel of `ℚ(ζ₅)`, which is itself fully
pinned there: `3/2 = typeEntropy 4`. -/
theorem quintic_prime_eq_C4_typeEntropy : mutInfo qFrob qType qDial = typeEntropy 4 := by
  rw [abelianization_law_degree_five, typeEntropy_val_4]

/-- The mislabelled pair channel: the joint entropy is again `11/5 + (log₂ 5)/2`. -/
theorem qPairSwapEntropy_val : uEnt qBox qPairTypeSwap = 11 / 5 + (1 / 2) * Real.logb 2 5 := by
  have h : (qBox.image qPairTypeSwap).val.map (fun v => (#{x ∈ qBox | qPairTypeSwap x = v} : ℕ))
      = (↑[1, 4, 10, 5, 4, 16, 40, 20, 10, 40, 100, 50, 5, 20, 50, 25] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, qBox_card]
  norm_num [lbq_400, lbq_50, lbq_40, lb_25, lb_16, lb_10, lb_4, lbq_20, lb_100]
  ring

/-- ... but the conditional entropy is different: `43/40 + (log₂ 5)/2` instead of
`19/20 + (log₂ 5)/2`. -/
theorem qCondPairSwapEntropy_val :
    condEnt qBox qPairTypeSwap qProdDial = 43 / 40 + (1 / 2) * Real.logb 2 5 := by
  have e0 : uEnt {x ∈ qBox | qProdDial x = 0} qPairTypeSwap
      = 6 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 0}).image qPairTypeSwap).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 0} | qPairTypeSwap q = v} : ℕ))
        = (↑[1, 4, 4, 16, 25, 25, 25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_0]
    norm_num [lb_25, lb_16, lb_4, lb_100]
    ring
  have e1 : uEnt {x ∈ qBox | qProdDial x = 1} qPairTypeSwap
      = 6 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 1}).image qPairTypeSwap).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 1} | qPairTypeSwap q = v} : ℕ))
        = (↑[5, 20, 5, 20, 25, 25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_1]
    norm_num [lb_25, lbq_20, lb_100]
    ring
  have e2 : uEnt {x ∈ qBox | qProdDial x = 2} qPairTypeSwap
      = 6 / 5 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 2}).image qPairTypeSwap).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 2} | qPairTypeSwap q = v} : ℕ))
        = (↑[5, 20, 25, 5, 20, 25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_2]
    norm_num [lb_25, lbq_20, lb_100]
    ring
  have e3 : uEnt {x ∈ qBox | qProdDial x = 3} qPairTypeSwap
      = 7 / 10 + (1 / 2) * Real.logb 2 5 := by
    have h : (({x ∈ qBox | qProdDial x = 3}).image qPairTypeSwap).val.map
        (fun v => (#{q ∈ {x ∈ qBox | qProdDial x = 3} | qPairTypeSwap q = v} : ℕ))
        = (↑[5, 20, 50, 5, 20] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, qClass_card_3]
    norm_num [lbq_50, lbq_20, lb_100]
    ring
  rw [condEnt, qProdDial_image, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_one, e0, e1, e2, e3, qBox_card,
    qClass_card_0, qClass_card_1, qClass_card_2, qClass_card_3]
  norm_num
  ring

/-- **The mislabelled pair law** is `9/8`, not `5/4`. -/
theorem swap_pair_law : mutInfo qBox qPairTypeSwap qProdDial = 9 / 8 := by
  rw [mutInfo, qPairSwapEntropy_val, qCondPairSwapEntropy_val]; ring

/-- **THE DISCRIMINATING TEST.**  Swapping the two order-4 coset labels against the `C₄`
valuation is undetectable by *any* prime-level statistic of the channel — the type entropy,
the dial entropy and the transmitted information `3/2` are all identical — and yet it moves
the semiprime pair law by exactly `1/8` of a bit, from `5/4` to `9/8`.  The pair channel is
the discriminating test of coset bookkeeping precisely where type-merging hides the error. -/
theorem coset_swap_detected_only_by_the_pair_law :
    uEnt qFrob qTypeSwap = uEnt qFrob qType ∧
    mutInfo qFrob qTypeSwap qDial = mutInfo qFrob qType qDial ∧
    mutInfo qBox qPairTypeSwap qProdDial ≠ mutInfo qBox qPairType qProdDial ∧
    mutInfo qBox qPairType qProdDial - mutInfo qBox qPairTypeSwap qProdDial = 1 / 8 := by
  refine ⟨qTypeSwap_entropy, ?_, ?_, ?_⟩
  · rw [coset_swap_invisible_at_prime_level, abelianization_law_degree_five]
  · rw [swap_pair_law, quintic_pair_law]; norm_num
  · rw [swap_pair_law, quintic_pair_law]; norm_num

/-- The full `F₂₀` semiprime row: pair law, which-factor wall, fork, and the coset-swap
margin, in one statement. -/
theorem quintic_semiprime_table :
    mutInfo qBox qPairType qProdDial = 5 / 4 ∧
    mutInfo qBox qPairType qProdDial = Ipair 4 ∧
    mutInfo qBox qPairUnord qProdDial = mutInfo qBox qPairType qProdDial ∧
    mutInfo qBox qFork qProdDial = Isplit 4 ∧
    mutInfo qBox qPairTypeSwap qProdDial = 9 / 8 :=
  ⟨quintic_pair_law, quintic_pair_eq_C4_pair, which_factor_wall_zero,
    quintic_fork_eq_Isplit_four, swap_pair_law⟩

end QuinticF20Pair