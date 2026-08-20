import Mathlib

/-!
# Good seeds and the fraction of a finite level set

The catalog already contains a great deal of machinery for randomised
cryptographic arguments: honest-verifier simulators, guarded execution traces,
bounded search for witnesses, and various counting arguments.  What was missing
is the elementary — but ubiquitous — *bookkeeping layer* that turns a cardinality
statement about a finite set of random seeds into a statement about a
**fraction** of the seed space, and, crucially, the decomposition of that
fraction along the **level sets of a cost function**.

This file supplies that layer.

## Main definitions

* `Cryptography.GoodSeeds.goodSeeds Ω acc` — the seeds in a finite seed space
  `Ω` on which the event `acc` occurs.
* `Cryptography.GoodSeeds.frac Ω acc` — the rational fraction
  `|goodSeeds Ω acc| / |Ω|`.
* `Cryptography.GoodSeeds.levelSet Ω cost i` — the seeds of cost exactly `i`.

## Main results

* `frac_nonneg`, `frac_le_one`, `frac_eq_one_iff`, `frac_eq_zero_iff` — the
  fraction is a genuine probability on a nonempty seed space.
* `frac_add_frac_not` — complementation.
* `frac_add_of_disjoint`, `frac_mono` — additivity and monotonicity.
* `sum_card_levelSet`, `sum_frac_levelSet` — **the fractions of the level sets of
  a bounded cost function sum to one**: the missing bookkeeping.
* `frac_sublevel_eq_sum_frac_levelSet` — a sublevel fraction is the partial sum
  of level-set fractions.
* `frac_le_of_markov` — Markov's inequality in level-set form.
* `expCost_eq_sum_level_frac`, `expCost_eq_sum_tail_frac` — the two layer-cake
  identities recovering the average cost from the level-set fractions.
* `frac_pow_of_independent_repetition` — the fraction of seed *vectors* all of
  whose coordinates are good is the `k`-th power of the fraction: soundness
  amplification, exactly.

-- !-- Lab Notes -- !--
Hypothesis (LS1): every "with probability ≥ ε over the seeds" statement in the
catalog can be reduced to a `Finset.card` computation plus a division, and the
resulting operator `frac` is a finitely additive probability measure on the
Boolean algebra of decidable events.
Experiment: define `frac` as a rational quotient of cardinalities and attempt to
derive the measure axioms without any `Nonempty` hypothesis.
Outcome: partially refuted.  Non-negativity, monotonicity in the numerator and
finite additivity hold unconditionally; `frac Ω acc ≤ 1`, `frac Ω (fun _ => True)
= 1` and complementation all *fail* for `Ω = ∅`, because `x / 0 = 0` in Lean's
rationals makes the empty seed space assign measure `0` to the sure event.  Every
normalisation statement below therefore carries an explicit `Ω.Nonempty` guard —
this is the "guarding" discipline the catalog already uses for bounded search,
transplanted to the counting layer.
Analysis: the level-set decomposition `sum_frac_levelSet` is the structural heart:
it is `Finset.card_eq_sum_card_fiberwise` divided by `|Ω|`, and it is what lets
Markov, the sublevel identity and the heavy-row argument of `Rewinding.lean` all
be proved by pure `Finset` manipulation with no measure theory.
Critique: `frac` is *not* a `Measure`; it is a rational-valued finitely additive
functional.  That is deliberate — it keeps every statement decidable and
`decide`-checkable on small cases, which is what a cryptographic soundness bound
needs.
-/

namespace Cryptography
namespace GoodSeeds

open Finset

variable {σ : Type*} {Ω : Finset σ}

/-- The **good seeds**: the elements of the finite seed space `Ω` on which the
event `acc` occurs. -/
def goodSeeds (Ω : Finset σ) (acc : σ → Prop) [DecidablePred acc] : Finset σ :=
  Ω.filter acc

/-- The **fraction** of the seed space `Ω` on which `acc` occurs. -/
def frac (Ω : Finset σ) (acc : σ → Prop) [DecidablePred acc] : ℚ :=
  ((goodSeeds Ω acc).card : ℚ) / (Ω.card : ℚ)

section Basic

variable {acc : σ → Prop} [DecidablePred acc]

@[simp] theorem mem_goodSeeds {s : σ} : s ∈ goodSeeds Ω acc ↔ s ∈ Ω ∧ acc s :=
  Finset.mem_filter

theorem goodSeeds_subset : goodSeeds Ω acc ⊆ Ω := Finset.filter_subset _ _

theorem card_goodSeeds_le : (goodSeeds Ω acc).card ≤ Ω.card :=
  Finset.card_le_card goodSeeds_subset

theorem frac_nonneg : 0 ≤ frac Ω acc := by
  unfold frac
  positivity

theorem frac_le_one : frac Ω acc ≤ 1 := by
  unfold frac
  rcases Ω.eq_empty_or_nonempty with h | h
  · simp [h, goodSeeds]
  · rw [div_le_one (by exact_mod_cast Finset.card_pos.2 h)]
    exact_mod_cast card_goodSeeds_le

/-- On a nonempty seed space the fraction is `1` exactly when every seed is
good. -/
theorem frac_eq_one_iff (hΩ : Ω.Nonempty) : frac Ω acc = 1 ↔ ∀ s ∈ Ω, acc s := by
  have hpos : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  unfold frac
  rw [div_eq_one_iff_eq hpos.ne']
  constructor
  · intro h
    have hcard : (goodSeeds Ω acc).card = Ω.card := by exact_mod_cast h
    have := Finset.eq_of_subset_of_card_le goodSeeds_subset (le_of_eq hcard.symm)
    intro s hs
    exact (mem_goodSeeds.1 (this ▸ hs)).2
  · intro h
    congr 1
    have : goodSeeds Ω acc = Ω := Finset.filter_true_of_mem h
    rw [this]

/-- On a nonempty seed space the fraction is `0` exactly when no seed is good. -/
theorem frac_eq_zero_iff (hΩ : Ω.Nonempty) : frac Ω acc = 0 ↔ ∀ s ∈ Ω, ¬ acc s := by
  have hpos : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  unfold frac
  rw [div_eq_zero_iff]
  simp only [hpos.ne', or_false]
  constructor
  · intro h s hs hacc
    have : (goodSeeds Ω acc).card = 0 := by exact_mod_cast h
    rw [Finset.card_eq_zero] at this
    exact absurd (mem_goodSeeds.2 ⟨hs, hacc⟩) (by rw [this]; simp)
  · intro h
    have : goodSeeds Ω acc = ∅ := Finset.filter_eq_empty_iff.2 h
    rw [this]
    simp

/-- Complementation: the good and the bad fractions add up to one. -/
theorem frac_add_frac_not (hΩ : Ω.Nonempty) :
    frac Ω acc + frac Ω (fun s => ¬ acc s) = 1 := by
  have hpos : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  unfold frac goodSeeds
  rw [← add_div, div_eq_one_iff_eq hpos.ne']
  exact_mod_cast Finset.card_filter_add_card_filter_not (s := Ω) (p := acc)

end Basic

section Combination

variable {p q : σ → Prop} [DecidablePred p] [DecidablePred q]

/-- Monotonicity of the fraction in the event. -/
theorem frac_mono (h : ∀ s ∈ Ω, p s → q s) : frac Ω p ≤ frac Ω q := by
  have hcard : (goodSeeds Ω p).card ≤ (goodSeeds Ω q).card :=
    Finset.card_le_card fun s hs =>
      mem_goodSeeds.2 ⟨(mem_goodSeeds.1 hs).1, h s (mem_goodSeeds.1 hs).1 (mem_goodSeeds.1 hs).2⟩
  unfold frac
  gcongr

/-- Finite additivity on mutually exclusive events. -/
theorem frac_add_of_disjoint (hdisj : ∀ s ∈ Ω, ¬ (p s ∧ q s)) :
    frac Ω (fun s => p s ∨ q s) = frac Ω p + frac Ω q := by
  classical
  unfold frac goodSeeds
  rw [← add_div]
  congr 1
  rw [Finset.filter_or]
  rw [Finset.card_union_of_disjoint]
  · norm_cast
  · rw [Finset.disjoint_filter]
    intro s hs hp hq
    exact hdisj s hs ⟨hp, hq⟩

/-- Congruence: events that agree on the seed space have the same fraction. -/
theorem frac_congr (h : ∀ s ∈ Ω, p s ↔ q s) : frac Ω p = frac Ω q := by
  have hfil : Ω.filter p = Ω.filter q := Finset.filter_congr h
  unfold frac goodSeeds
  rw [hfil]

end Combination

/-! ## Level sets of a cost function

The piece of bookkeeping that the catalog was missing: a finite seed space is
stratified by a cost function (number of oracle queries, search depth, running
time, Hamming weight of an error, …), and the fractions of the strata must add
up to one. -/

section LevelSets

variable (cost : σ → ℕ)

/-- The seeds of cost exactly `i`. -/
def levelSet (Ω : Finset σ) (cost : σ → ℕ) (i : ℕ) : Finset σ :=
  Ω.filter fun s => cost s = i

@[simp] theorem mem_levelSet {i : ℕ} {s : σ} :
    s ∈ levelSet Ω cost i ↔ s ∈ Ω ∧ cost s = i := Finset.mem_filter

theorem levelSet_eq_goodSeeds (i : ℕ) :
    levelSet Ω cost i = goodSeeds Ω (fun s => cost s = i) := rfl

/-- **The level sets of a bounded cost function partition the seed space.** -/
theorem sum_card_levelSet {B : ℕ} (h : ∀ s ∈ Ω, cost s ≤ B) :
    ∑ i ∈ Finset.range (B + 1), (levelSet Ω cost i).card = Ω.card :=
  (Finset.card_eq_sum_card_fiberwise
    (f := cost) (t := Finset.range (B + 1))
    fun s hs => Finset.mem_range.2 (Nat.lt_succ_of_le (h s hs))).symm

/-- **The fractions of the level sets of a bounded cost function sum to one.**
This is the "fraction of a finite level set" bookkeeping. -/
theorem sum_frac_levelSet (hΩ : Ω.Nonempty) {B : ℕ} (h : ∀ s ∈ Ω, cost s ≤ B) :
    ∑ i ∈ Finset.range (B + 1), frac Ω (fun s => cost s = i) = 1 := by
  have hpos : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  have hsum := sum_card_levelSet (Ω := Ω) cost h
  unfold frac
  rw [← Finset.sum_div, div_eq_one_iff_eq hpos.ne']
  have : ∑ i ∈ Finset.range (B + 1), ((goodSeeds Ω (fun s => cost s = i)).card : ℚ)
      = ((∑ i ∈ Finset.range (B + 1), (levelSet Ω cost i).card : ℕ) : ℚ) := by
    push_cast
    rfl
  rw [this, hsum]

/-- A sublevel fraction is the partial sum of the level fractions. -/
theorem frac_sublevel_eq_sum_frac_levelSet (t : ℕ) :
    frac Ω (fun s => cost s ≤ t) = ∑ i ∈ Finset.range (t + 1), frac Ω (fun s => cost s = i) := by
  have hcard :
      (goodSeeds Ω (fun s => cost s ≤ t)).card
        = ∑ i ∈ Finset.range (t + 1), (goodSeeds Ω (fun s => cost s = i)).card := by
    simp only [goodSeeds]
    have hfib := Finset.card_eq_sum_card_fiberwise
      (f := cost) (s := Ω.filter fun s => cost s ≤ t) (t := Finset.range (t + 1))
      (fun s hs => Finset.mem_range.2 (Nat.lt_succ_of_le (Finset.mem_filter.1 hs).2))
    rw [hfib]
    refine Finset.sum_congr rfl fun i hi => ?_
    have hit : i ≤ t := Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)
    congr 1
    ext s
    simp only [Finset.mem_filter]
    exact ⟨fun ⟨⟨hs, _⟩, he⟩ => ⟨hs, he⟩, fun ⟨hs, he⟩ => ⟨⟨hs, he ▸ hit⟩, he⟩⟩
  unfold frac
  rw [← Finset.sum_div]
  congr 1
  push_cast [hcard]
  rfl

/-- **Markov's inequality, level-set form.**  The fraction of seeds whose cost is
at least `t` is at most the average cost divided by `t`. -/
theorem frac_le_of_markov {t : ℕ} (ht : 0 < t) :
    frac Ω (fun s => t ≤ cost s) ≤ (∑ s ∈ Ω, (cost s : ℚ)) / (t * Ω.card) := by
  rcases Ω.eq_empty_or_nonempty with rfl | hΩ
  · simp [frac, goodSeeds]
  have hpos : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  have htq : (0 : ℚ) < (t : ℚ) := by exact_mod_cast ht
  set G := goodSeeds Ω (fun s => t ≤ cost s) with hG
  have hkey : (t : ℚ) * (G.card : ℚ) ≤ ∑ s ∈ Ω, (cost s : ℚ) := by
    have h1 : ∑ _s ∈ G, (t : ℚ) ≤ ∑ s ∈ G, (cost s : ℚ) := by
      refine Finset.sum_le_sum fun s hs => ?_
      exact_mod_cast (mem_goodSeeds.1 hs).2
    have h2 : ∑ s ∈ G, (cost s : ℚ) ≤ ∑ s ∈ Ω, (cost s : ℚ) :=
      Finset.sum_le_sum_of_subset_of_nonneg goodSeeds_subset (by intros; positivity)
    calc (t : ℚ) * (G.card : ℚ) = ∑ _s ∈ G, (t : ℚ) := by
          rw [Finset.sum_const, nsmul_eq_mul]; ring
      _ ≤ ∑ s ∈ G, (cost s : ℚ) := h1
      _ ≤ ∑ s ∈ Ω, (cost s : ℚ) := h2
  unfold frac
  rw [← hG, div_le_div_iff₀ (by positivity) (by positivity)]
  calc (G.card : ℚ) * ((t : ℚ) * (Ω.card : ℚ))
      = ((t : ℚ) * (G.card : ℚ)) * (Ω.card : ℚ) := by ring
    _ ≤ (∑ s ∈ Ω, (cost s : ℚ)) * (Ω.card : ℚ) := by
        exact mul_le_mul_of_nonneg_right hkey (le_of_lt hpos)

/-! ### The layer-cake identities

The average of a bounded cost function is recoverable from the level-set
fractions in two ways: as a weighted sum over the levels, and — the *layer cake*
— as an unweighted sum of the tail fractions.  These are the two identities that
make the level-set bookkeeping actually useful. -/

/-- The average cost over the seed space. -/
def expCost (Ω : Finset σ) (cost : σ → ℕ) : ℚ := (∑ s ∈ Ω, (cost s : ℚ)) / (Ω.card : ℚ)

/-- The total cost is the level-weighted sum of level-set cardinalities. -/
theorem sum_cost_eq_sum_level_card {B : ℕ} (h : ∀ s ∈ Ω, cost s ≤ B) :
    ∑ s ∈ Ω, cost s = ∑ i ∈ Finset.range (B + 1), i * (levelSet Ω cost i).card := by
  rw [← Finset.sum_fiberwise_of_maps_to
      (g := cost) (t := Finset.range (B + 1))
      (fun s hs => Finset.mem_range.2 (Nat.lt_succ_of_le (h s hs))) (fun s => cost s)]
  refine Finset.sum_congr rfl fun i _ => ?_
  have : ∀ s ∈ Ω.filter (fun s => cost s = i), cost s = i := fun s hs =>
    (Finset.mem_filter.1 hs).2
  rw [Finset.sum_congr rfl this, Finset.sum_const, smul_eq_mul, levelSet, mul_comm]

/-- **Layer cake, counting form.**  The total cost is the sum over thresholds of
the cardinalities of the tail sets. -/
theorem sum_cost_eq_sum_tail_card {B : ℕ} (h : ∀ s ∈ Ω, cost s ≤ B) :
    ∑ s ∈ Ω, cost s
      = ∑ t ∈ Finset.Icc 1 B, (goodSeeds Ω (fun s => t ≤ cost s)).card := by
  simp only [goodSeeds, Finset.card_filter]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun s hs => ?_
  have hfil : (Finset.Icc 1 B).filter (fun t => t ≤ cost s) = Finset.Icc 1 (cost s) := by
    ext t
    simp only [Finset.mem_filter, Finset.mem_Icc]
    have := h s hs
    omega
  symm
  calc ∑ t ∈ Finset.Icc 1 B, (if t ≤ cost s then 1 else 0)
      = ((Finset.Icc 1 B).filter (fun t => t ≤ cost s)).card := (Finset.card_filter _ _).symm
    _ = (Finset.Icc 1 (cost s)).card := by rw [hfil]
    _ = cost s := by rw [Nat.card_Icc]; omega

/-- **The average cost is the level-weighted sum of the level fractions.** -/
theorem expCost_eq_sum_level_frac (hΩ : Ω.Nonempty) {B : ℕ} (h : ∀ s ∈ Ω, cost s ≤ B) :
    expCost Ω cost = ∑ i ∈ Finset.range (B + 1), (i : ℚ) * frac Ω (fun s => cost s = i) := by
  have hpos : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  have hs := sum_cost_eq_sum_level_card (Ω := Ω) cost h
  unfold expCost frac
  rw [show ∑ i ∈ Finset.range (B + 1),
        (i : ℚ) * (((goodSeeds Ω (fun s => cost s = i)).card : ℚ) / (Ω.card : ℚ))
      = (∑ i ∈ Finset.range (B + 1),
          (i : ℚ) * ((goodSeeds Ω (fun s => cost s = i)).card : ℚ)) / (Ω.card : ℚ) by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun i _ => by ring]
  congr 1
  have : ((∑ s ∈ Ω, cost s : ℕ) : ℚ)
      = ((∑ i ∈ Finset.range (B + 1), i * (levelSet Ω cost i).card : ℕ) : ℚ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) hs
  push_cast at this
  exact this

/-- **Layer cake.**  The average cost is the sum of the tail fractions. -/
theorem expCost_eq_sum_tail_frac (hΩ : Ω.Nonempty) {B : ℕ} (h : ∀ s ∈ Ω, cost s ≤ B) :
    expCost Ω cost = ∑ t ∈ Finset.Icc 1 B, frac Ω (fun s => t ≤ cost s) := by
  have hpos : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  have hs := sum_cost_eq_sum_tail_card (Ω := Ω) cost h
  unfold expCost frac
  rw [← Finset.sum_div]
  congr 1
  have : ((∑ s ∈ Ω, cost s : ℕ) : ℚ)
      = ((∑ t ∈ Finset.Icc 1 B, (goodSeeds Ω (fun s => t ≤ cost s)).card : ℕ) : ℚ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) hs
  push_cast at this
  exact this

end LevelSets

/-! ## Independent repetition -/

/-- **Soundness amplification, exactly.**  Over the product seed space of `k`
independent seeds, the fraction of seed vectors *all* of whose coordinates are
good is the `k`-th power of the one-shot fraction.  No `Nonempty` guard is
needed: for `k = 0` both sides are `1`. -/
theorem frac_pow_of_independent_repetition (Ω : Finset σ) (acc : σ → Prop)
    [DecidablePred acc] (k : ℕ) :
    frac (Fintype.piFinset fun _ : Fin k => Ω) (fun f => ∀ i, acc (f i)) = (frac Ω acc) ^ k := by
  classical
  have hset : (Fintype.piFinset fun _ : Fin k => Ω).filter (fun f => ∀ i, acc (f i))
      = Fintype.piFinset fun _ : Fin k => goodSeeds Ω acc := by
    ext f
    simp only [Finset.mem_filter, Fintype.mem_piFinset, mem_goodSeeds]
    exact ⟨fun ⟨h1, h2⟩ i => ⟨h1 i, h2 i⟩, fun h => ⟨fun i => (h i).1, fun i => (h i).2⟩⟩
  unfold frac goodSeeds
  rw [hset, Fintype.card_piFinset, Fintype.card_piFinset]
  simp only [Finset.prod_const, Finset.card_univ, Fintype.card_fin]
  rw [div_pow]
  simp only [goodSeeds]
  push_cast
  ring

end GoodSeeds
end Cryptography