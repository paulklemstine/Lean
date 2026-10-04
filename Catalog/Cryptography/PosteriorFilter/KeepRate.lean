import Mathlib

/-!
# Paper 131 — the posterior filter equals the sham: the keep-rate law

Experiment 461 built a Bayesian candidate filter from the exact type-channel posterior and
compared it with a coin-flip keep-set of the same size.  The two were indistinguishable at
every dial.  This file proves the exact combinatorial statements behind that finding, in
the residue model of trial division.

## The model

The two prime factors of `N = p q` are recorded by their residues `a, b` in a finite group
`G` (for instance `(ZMod m)ˣ`), drawn uniformly from `G × G`.  The public number fixes
the residue `c = a * b`.  A *filter* is a keep-policy `K : G → Finset G`: after reading the
public residue `c`, the filter keeps the candidate residue classes in `K c` and trial
divides only those.  The filter succeeds when the target residue `a` lies in `K (a * b)`.
An *ordering policy* `r c : G ≃ Fin |G|` decides in which order the candidate classes
are examined.

## Main results

* `flat_transport` — the change of variables `(a, b) ↦ (a, a b)`: every statistic of the
  pair (target residue, public residue) is the uniform average over *independent* pairs.
* `posterior_flat` — **barrier 2**: whatever a public dial `φ` shows, every residue class
  of the target has exactly the same posterior weight.
* `hitCount_eq_sum_card` — **the keep-rate law**: the number of successes of a filter is
  `∑_c |K c|`; it depends only on the keep sizes, never on which classes are kept.
* `real_filter_eq_sham` — two filters with the same keep sizes have exactly the same
  success count, and `hitRate_eq_keepRate` — the success rate equals the keep rate.
* `noFallback_failure_eq` — a filter dropping one class per public residue fails with
  probability exactly `1/|G|`.
* `ordering_invariance` — no ordering policy changes the expected number of candidates
  examined: it is always `(|G| + 1)/2`.
* `filter_cost_eq`, `filter_cost_ge_baseline`, `fullKeep_cost_eq_two_baseline` — honest
  accounting: pricing every membership test at one division, every filter costs at least
  the plain scan (cap `1x`), and a filter that keeps every class costs exactly twice the
  scan (`0.5x`).
* `sham_coinflation` — the test-free (buggy) cost over successful runs also depends only on
  the keep sizes, so a cost-accounting bug inflates the real filter and the sham equally.
-/

namespace PosteriorFilter

open Finset

section Transport

variable {G : Type*} [Group G] [Fintype G]

/-- **Flat transport.**  For the uniform pair of factor residues, the map
`(a, b) ↦ (a, a * b)` is a bijection, so every statistic of the target residue together
with the public residue is the uniform double sum over independent pairs. -/
theorem flat_transport {M : Type*} [AddCommMonoid M] (f : G → G → M) :
    ∑ w : G × G, f w.1 (w.1 * w.2) = ∑ c : G, ∑ a : G, f a c := by
  rw [Fintype.sum_prod_type]
  conv_rhs => rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  exact Fintype.sum_equiv (Equiv.mulLeft a) _ _ (fun b => rfl)

end Transport

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

section Posterior

/-- **Barrier 2 (flat posterior).**  Let `φ` be any public dial, i.e. any function of the
public residue `c = a b`.  For a dial reading `d` and any candidate class `r`, the number of
factor pairs with that reading whose target lies in `r` is `|φ⁻¹(d)|`, independent of `r`.
Hence the posterior over the target's residue is flat. -/
theorem posterior_flat {β : Type*} [DecidableEq β] (φ : G → β) (d : β) (r : G) :
    (univ.filter (fun w : G × G => φ (w.1 * w.2) = d ∧ w.1 = r)).card =
      (univ.filter (fun c : G => φ c = d)).card := by
  rw [Finset.card_filter, Finset.card_filter]
  rw [flat_transport (fun a c => if φ c = d ∧ a = r then 1 else 0)]
  refine Finset.sum_congr rfl (fun c _ => ?_)
  by_cases h : φ c = d
  · simp [h]
  · simp [h]

/-- The flat posterior makes every class equally likely: two candidate classes always have
the same posterior weight, whatever the dial shows. -/
theorem posterior_indifferent {β : Type*} [DecidableEq β] (φ : G → β) (d : β) (r s : G) :
    (univ.filter (fun w : G × G => φ (w.1 * w.2) = d ∧ w.1 = r)).card =
      (univ.filter (fun w : G × G => φ (w.1 * w.2) = d ∧ w.1 = s)).card := by
  rw [posterior_flat, posterior_flat]

end Posterior

section KeepRate

/-- The number of factor pairs on which the keep-policy `K` keeps the target class. -/
def hitCount (K : G → Finset G) : ℕ :=
  (univ.filter (fun w : G × G => w.1 ∈ K (w.1 * w.2))).card

/-- **The keep-rate law.**  The number of successes of a filter is the total keep size. -/
theorem hitCount_eq_sum_card (K : G → Finset G) : hitCount K = ∑ c : G, (K c).card := by
  unfold hitCount
  rw [Finset.card_filter, flat_transport (fun a c => if a ∈ K c then 1 else 0)]
  refine Finset.sum_congr rfl (fun c _ => ?_)
  rw [← Finset.card_filter]
  congr 1
  ext a; simp

/-- **Real filter equals sham.**  Two filters keeping the same number of classes for each
public residue have exactly the same number of successes, whatever classes they keep: the
posterior-ranked filter and an arbitrary (e.g. coin-flip) keep-set of the same size are
indistinguishable. -/
theorem real_filter_eq_sham (Kreal Ksham : G → Finset G)
    (hsize : ∀ c, (Kreal c).card = (Ksham c).card) : hitCount Kreal = hitCount Ksham := by
  rw [hitCount_eq_sum_card, hitCount_eq_sum_card]
  exact Finset.sum_congr rfl (fun c _ => hsize c)

/-- **Success rate equals keep rate.**  With a constant keep size `k`, the success
probability of any filter is exactly `k / |G|`. -/
theorem hitRate_eq_keepRate (K : G → Finset G) (k : ℕ) (hk : ∀ c, (K c).card = k) :
    (hitCount K : ℝ) / (Fintype.card (G × G)) = k / Fintype.card G := by
  rw [hitCount_eq_sum_card, Finset.sum_congr rfl (fun c _ => hk c), Finset.sum_const,
    Finset.card_univ, Fintype.card_prod, smul_eq_mul]
  have hpos : (Fintype.card G : ℝ) ≠ 0 := by
    have : 0 < Fintype.card G := Fintype.card_pos
    exact_mod_cast this.ne'
  push_cast
  field_simp

/-- **No-fallback failure rate.**  A filter that discards exactly one candidate class for
every public residue misses the target on exactly `|G|` of the `|G|²` factor pairs, i.e.
with probability exactly `1/|G|`. -/
theorem noFallback_failure_eq (K : G → Finset G) (hk : ∀ c, (K c).card + 1 = Fintype.card G) :
    (univ.filter (fun w : G × G => w.1 ∉ K (w.1 * w.2))).card = Fintype.card G := by
  have htot := Finset.card_filter_add_card_filter_not (s := (univ : Finset (G × G)))
    (fun w : G × G => w.1 ∈ K (w.1 * w.2))
  obtain ⟨k, hkdef⟩ : ∃ k, Fintype.card G = k + 1 := ⟨(K 1).card, (hk 1).symm⟩
  have hhit : hitCount K = (k + 1) * k := by
    rw [hitCount_eq_sum_card, Finset.sum_congr rfl (fun c _ =>
      (show (K c).card = k by have := hk c; omega)), Finset.sum_const, Finset.card_univ,
      smul_eq_mul, hkdef]
  unfold hitCount at hhit
  rw [Finset.card_univ, Fintype.card_prod, hkdef, hhit] at htot
  rw [hkdef]
  nlinarith

end KeepRate

section Ordering

/-- The candidate classes ranked no later than `a` by the ranking `e`. -/
def upTo {n : ℕ} (e : G ≃ Fin n) (a : G) : Finset G := univ.filter (fun x => e x ≤ e a)

omit [Group G] [DecidableEq G] in
/-- Under a ranking, exactly `rank + 1` candidates are examined up to and including `a`. -/
theorem card_upTo {n : ℕ} (e : G ≃ Fin n) (a : G) : (upTo e a).card = (e a : ℕ) + 1 := by
  unfold upTo
  have h : (univ.filter (fun x => e x ≤ e a)).map e.toEmbedding = Finset.Iic (e a) := by
    ext i
    simp only [mem_map, mem_filter, mem_univ, true_and, Equiv.coe_toEmbedding, mem_Iic]
    constructor
    · rintro ⟨x, hx, rfl⟩; exact hx
    · intro hi; exact ⟨e.symm i, by simpa using hi, by simp⟩
  rw [← Finset.card_map e.toEmbedding, h, Fin.card_Iic]

omit [Group G] [DecidableEq G] in
/-- The sum of all ranks is `n (n - 1) / 2`, in multiplication-free form. -/
theorem two_mul_sum_rank {n : ℕ} (e : G ≃ Fin n) :
    2 * ∑ a : G, (e a : ℕ) = n * (n - 1) := by
  rw [e.sum_comp (fun i : Fin n => (i : ℕ)), Fin.sum_univ_eq_sum_range (fun i => i), mul_comm,
    Finset.sum_range_id_mul_two]

omit [DecidableEq G] in
/-- **Ordering invariance (no reweighting).**  However the ordering of candidate classes
is chosen from the public residue, the total number of candidates examined before reaching
the target, summed over all `|G|²` factor pairs, is `|G|² (|G| - 1) / 2`: the expected
rank is `(|G| - 1)/2` for every ordering policy, exactly as for the plain scan. -/
theorem ordering_invariance (r : G → (G ≃ Fin (Fintype.card G))) :
    2 * ∑ w : G × G, (r (w.1 * w.2) w.1 : ℕ) =
      Fintype.card G * (Fintype.card G * (Fintype.card G - 1)) := by
  rw [flat_transport (fun a c => (r c a : ℕ)), Finset.mul_sum,
    Finset.sum_congr rfl (fun c _ => two_mul_sum_rank (r c)), Finset.sum_const,
    Finset.card_univ, smul_eq_mul]

omit [DecidableEq G] in
/-- Any two ordering policies have the same total search cost. -/
theorem ordering_real_eq_sham (r s : G → (G ≃ Fin (Fintype.card G))) :
    ∑ w : G × G, (r (w.1 * w.2) w.1 : ℕ) = ∑ w : G × G, (s (w.1 * w.2) w.1 : ℕ) := by
  have h1 := ordering_invariance r
  have h2 := ordering_invariance s
  omega

end Ordering

section Cost

variable (r : G → (G ≃ Fin (Fintype.card G)))

/-- Baseline cost: the plain scan divides by every candidate up to and including the
target. -/
def baselineCost (c a : G) : ℕ := (upTo (r c) a).card

/-- Honest filter cost: every examined candidate is first tested for membership in the
keep-set (one division-equivalent) and the kept ones are then divided (one more). -/
def filterCost (K : G → Finset G) (c a : G) : ℕ :=
  ∑ x ∈ upTo (r c) a, (1 + if x ∈ K c then 1 else 0)

omit [Group G] in
/-- Decomposition of the honest filter cost into the scan cost plus the kept divisions. -/
theorem filterCost_eq (K : G → Finset G) (c a : G) :
    filterCost r K c a = baselineCost r c a + ((upTo (r c) a).filter (· ∈ K c)).card := by
  unfold filterCost baselineCost
  rw [Finset.sum_add_distrib, Finset.card_filter]
  simp

/-- Total honest filter cost over all factor pairs. -/
theorem filter_cost_eq (K : G → Finset G) :
    ∑ w : G × G, filterCost r K (w.1 * w.2) w.1 =
      ∑ w : G × G, baselineCost r (w.1 * w.2) w.1 +
        ∑ w : G × G, ((upTo (r (w.1 * w.2)) w.1).filter (· ∈ K (w.1 * w.2))).card := by
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl (fun w _ => filterCost_eq r K _ _)

/-- **The `1x` cap.**  With every membership test priced at one division, no filter —
posterior-built or sham — beats the plain scan on total cost. -/
theorem filter_cost_ge_baseline (K : G → Finset G) :
    ∑ w : G × G, baselineCost r (w.1 * w.2) w.1 ≤
      ∑ w : G × G, filterCost r K (w.1 * w.2) w.1 := by
  rw [filter_cost_eq]; exact Nat.le_add_right _ _

omit [DecidableEq G] in
/-- The plain-scan total: `2 · total = |G|² (|G| + 1)`, i.e. expected cost `(|G| + 1)/2`,
for every ordering policy. -/
theorem baseline_total :
    2 * ∑ w : G × G, baselineCost r (w.1 * w.2) w.1 =
      Fintype.card G * (Fintype.card G * (Fintype.card G + 1)) := by
  unfold baselineCost
  simp only [card_upTo]
  rw [Finset.sum_add_distrib, mul_add, ordering_invariance r]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_prod, smul_eq_mul, mul_one]
  have : 0 < Fintype.card G := Fintype.card_pos
  obtain ⟨k, hk⟩ : ∃ k, Fintype.card G = k + 1 := ⟨_, (Nat.succ_pred_eq_of_pos this).symm⟩
  rw [hk]; simp only [Nat.add_sub_cancel]; ring

/-- **The `0.5x` law.**  A filter that keeps every class (equivalently: one whose fallback
eventually divides every tested candidate) pays the test *and* the division on every
candidate: exactly twice the plain scan. -/
theorem fullKeep_cost_eq_two_baseline :
    ∑ w : G × G, filterCost r (fun _ => univ) (w.1 * w.2) w.1 =
      2 * ∑ w : G × G, baselineCost r (w.1 * w.2) w.1 := by
  rw [filter_cost_eq, two_mul]
  congr 1
  refine Finset.sum_congr rfl (fun w _ => ?_)
  unfold baselineCost
  congr 1
  ext x; simp

omit [Group G] in
/-- The rank-sum identity behind sham co-inflation: inside any keep-set, the number of
ordered pairs `(x, a)` with `x` ranked no later than `a` is `|K| (|K| + 1) / 2`. -/
theorem two_mul_sum_card_upTo_inter {n : ℕ} (e : G ≃ Fin n) (K : Finset G) :
    2 * ∑ a ∈ K, ((upTo e a).filter (· ∈ K)).card = K.card * (K.card + 1) := by
  have hcard : ∀ a ∈ K, ((upTo e a).filter (· ∈ K)).card =
      ∑ x ∈ K, if e x ≤ e a then 1 else 0 := by
    intro a _
    rw [← Finset.card_filter]
    congr 1
    ext x; simp [upTo, and_comm]
  rw [Finset.sum_congr rfl hcard, two_mul]
  conv_lhs => arg 2; rw [Finset.sum_comm]
  rw [← Finset.sum_add_distrib]
  have hpt : ∀ a ∈ K, (∑ x ∈ K, if e x ≤ e a then 1 else 0) +
      (∑ x ∈ K, if e a ≤ e x then 1 else 0) = K.card + 1 := by
    intro a ha
    rw [← Finset.sum_add_distrib]
    have hx : ∀ x ∈ K, ((if e x ≤ e a then 1 else 0) + (if e a ≤ e x then 1 else 0) : ℕ) =
        1 + if x = a then 1 else 0 := by
      intro x _
      by_cases hxa : x = a
      · subst hxa; simp
      · have hne : e x ≠ e a := fun h => hxa (e.injective h)
        rcases lt_or_gt_of_ne hne with h | h
        · simp [hxa, h.le, not_le.mpr h]
        · simp [hxa, h.le, not_le.mpr h]
    rw [Finset.sum_congr rfl hx, Finset.sum_add_distrib]
    simp [ha]
  rw [Finset.sum_congr rfl hpt, Finset.sum_const, smul_eq_mul]

/-- **Sham co-inflation.**  If the membership test is (wrongly) left unpriced, the cost of a
successful run is the number of kept classes divided before the target.  Summed over the
successful runs this buggy cost is `∑_c |K c| (|K c| + 1) / 2`: it depends only on the
keep sizes.  So the spurious speedup produced by the bug is *identical* for the posterior
filter and for the same-size sham — the diagnostic that caught the two accounting bugs. -/
theorem sham_coinflation (K : G → Finset G) :
    2 * ∑ w : G × G, (if w.1 ∈ K (w.1 * w.2) then
        ((upTo (r (w.1 * w.2)) w.1).filter (· ∈ K (w.1 * w.2))).card else 0) =
      ∑ c : G, (K c).card * ((K c).card + 1) := by
  rw [flat_transport (fun a c => if a ∈ K c then ((upTo (r c) a).filter (· ∈ K c)).card
    else 0), Finset.mul_sum]
  refine Finset.sum_congr rfl (fun c _ => ?_)
  rw [← Finset.sum_filter, ← two_mul_sum_card_upTo_inter (r c) (K c)]
  congr 2
  ext a; simp

/-- Consequently the buggy cost of the real filter equals that of any sham with the same
keep sizes. -/
theorem buggy_cost_real_eq_sham (r' : G → (G ≃ Fin (Fintype.card G))) (Kreal Ksham : G → Finset G)
    (hsize : ∀ c, (Kreal c).card = (Ksham c).card) :
    ∑ w : G × G, (if w.1 ∈ Kreal (w.1 * w.2) then
        ((upTo (r (w.1 * w.2)) w.1).filter (· ∈ Kreal (w.1 * w.2))).card else 0) =
      ∑ w : G × G, (if w.1 ∈ Ksham (w.1 * w.2) then
        ((upTo (r' (w.1 * w.2)) w.1).filter (· ∈ Ksham (w.1 * w.2))).card else 0) := by
  have h1 := sham_coinflation r Kreal
  have h2 := sham_coinflation r' Ksham
  have h3 : ∑ c : G, (Kreal c).card * ((Kreal c).card + 1) =
      ∑ c : G, (Ksham c).card * ((Ksham c).card + 1) :=
    Finset.sum_congr rfl (fun c _ => by rw [hsize c])
  rw [h3] at h1
  omega

end Cost

end PosteriorFilter