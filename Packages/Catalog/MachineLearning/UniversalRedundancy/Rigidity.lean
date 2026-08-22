/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VIII: rigidity — the equality cases

Eighth instalment of the thread *Compression Beyond the Pigeonhole Bound*.
Parts I–VII established the two *sharp bounds* for the Shtarkov sum of a finite
source class,

`1 ≤ Cₛ ≤ #Θ`,

together with the closure laws that keep a class inside the `1`-sum (simplex)
world: products, tied products, reindexings.  Both endpoints were known to be
*attained* (`shtarkovSum_of_subsingleton`, `shtarkovSum_eq_card_of_disjoint_supports`).
What was missing is the **equality analysis**: which classes sit exactly at an
endpoint, and how far a class is from an endpoint when it misses it.

## Central Idea

The whole rigidity picture follows from a single *exact identity* that upgrades
the inequality `Cₛ ≤ #Θ` to a conservation law:

`Cₛ + Ω = #Θ`,   where   `Ω = ∑ₓ (∑_θ p_θ x − sup_θ p_θ x) ≥ 0`

is the **overlap** of the class — the probability mass that the sources share.
Every equality statement below is read off from `Ω`:

* `Ω = 0` ⟺ the sources are mutually singular ⟺ `Cₛ = #Θ` (maximal price);
* at the other end, `Cₛ = 1` forces `p_θ = sup_θ p_θ` pointwise, i.e. *all*
  sources coincide — no non-trivial class is free;
* for a two-source class the identity becomes the exact formula
  `Cₛ = 1 + d_TV(p, q)`, so the price of universality of a pair is *literally*
  the total variation distance, interpolating between the two rigid endpoints;
* consequently `1 + max_{θ≠θ'} d_TV(p_θ, p_θ') ≤ Cₛ` for every class: pairwise
  statistical separation is a lower bound on the universality price.

The same "sum of a pointwise inequality" analysis, applied to the *induction*
behind the tied-product law of Part VII, produces the equality criterion for
subadditivity: sharing a parameter across two blocks costs the full additive
price iff every pair of block outcomes admits a **common maximiser**.

## Main Results

* `SourceClass.overlap`, `shtarkovSum_add_overlap_eq_card` — the conservation law
* `SourceClass.MutuallySingular`, `shtarkovSum_eq_card_iff_mutuallySingular` —
  the upper endpoint is rigid
* `shtarkovSum_lt_card_of_overlap` — any shared message strictly lowers the price
* `shtarkovSum_eq_card_iff_exists_supports` — iff-form of Part I's partition
  criterion (`shtarkovSum_eq_card_of_disjoint_supports` is the easy direction)
* `shtarkovSum_eq_one_iff_forall_eq` — the lower endpoint is rigid: converse of
  the calibration law `shtarkovSum_of_subsingleton`
* `logb_shtarkovSum_eq_zero_iff`, `logb_shtarkovSum_eq_logb_card_iff` — the two
  rigidity theorems in bits
* `tvDist`, `shtarkovSum_pair_eq_one_add_tvDist` — exact two-source formula
* `one_add_tvDist_le_shtarkovSum`, `shtarkovSum_le_one_add_sum_tvDist` —
  a total-variation sandwich for the price of any class
* `shtarkovSum_le_card_sub_one_add_tvDist` — quantitative stability: one close
  pair already pulls the price away from the maximum
* `sum_pairs_affinity_le_overlap`, `shtarkovSum_le_card_sub_avg_affinity` —
  all-pairs stability: the average pairwise affinity is a deficit from the
  maximal price
* `reindexClass`, `shtarkovSum_reindexClass_eq_iff` — equality case of the
  monotonicity law
* `shtarkovSum_tiedProdClass_eq_iff` — equality analysis of the tied-product
  induction of Part VII, and `shtarkovSum_tiedProdClass_lt` for the strict case
* `pointMassClass`, `shtarkovSum_pointMassClass`,
  `shtarkovSum_tiedProdClass_pointMass` — a worked extremal family witnessing
  both endpoints and strict subadditivity
* `sum_maxLik_fiber_le_one`, `shtarkovSum_eq_card_statistic_iff` — equality
  analysis of the sufficient-statistic bound of Part II

## Application Keywords

universal coding, Shtarkov sum, rigidity, equality case, total variation,
mutual singularity, subadditivity, method of types
-/

import MachineLearning.UniversalRedundancy.Core
import MachineLearning.UniversalRedundancy.Types
import MachineLearning.UniversalRedundancy.Products

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} (S : SourceClass X Θ)

/-! ## The conservation law -/

/-- The **overlap** of a finite source class: the total probability mass that
the sources share, `Ω = ∑ₓ (∑_θ p_θ x − sup_θ p_θ x)`. -/
noncomputable def overlap [Fintype Θ] : ℝ := ∑ x, ((∑ θ, S.prob θ x) - S.maxLik x)

lemma maxLik_le_sum_prob [Fintype Θ] (x : X) : S.maxLik x ≤ ∑ θ, S.prob θ x := by
  classical
  cases isEmpty_or_nonempty Θ with
  | inl h => simp [maxLik, Real.iSup_of_isEmpty]
  | inr h =>
      refine S.maxLik_le fun θ => ?_
      exact Finset.single_le_sum (f := fun θ => S.prob θ x)
        (fun i _ => S.nonneg i x) (Finset.mem_univ θ)

lemma overlap_nonneg [Fintype Θ] : 0 ≤ S.overlap :=
  Finset.sum_nonneg fun x _ => sub_nonneg.mpr (S.maxLik_le_sum_prob x)

/-- **Conservation law.**  The sharp bound `Cₛ ≤ #Θ` is the shadow of an exact
identity: the price of universality and the overlap of the class add up to the
cost of naming the source. -/
theorem shtarkovSum_add_overlap_eq_card [Fintype Θ] :
    S.shtarkovSum + S.overlap = (Fintype.card Θ : ℝ) := by
  unfold shtarkovSum overlap
  rw [← Finset.sum_add_distrib]
  have : ∀ x : X, S.maxLik x + ((∑ θ, S.prob θ x) - S.maxLik x) = ∑ θ, S.prob θ x := by
    intro x; ring
  rw [Finset.sum_congr rfl fun x _ => this x, Finset.sum_comm]
  simp [S.sum_one]

/-! ## Rigidity at the upper endpoint -/

/-- The sources of the class are **mutually singular**: no message has positive
probability under two different sources. -/
def MutuallySingular : Prop :=
  ∀ (x : X) (θ θ' : Θ), θ ≠ θ' → S.prob θ x = 0 ∨ S.prob θ' x = 0

/-- Pointwise form of the rigidity: at a fixed message, the maximum likelihood
equals the total likelihood iff at most one source charges that message. -/
lemma maxLik_eq_sum_prob_iff [Fintype Θ] [Nonempty Θ] (x : X) :
    S.maxLik x = (∑ θ, S.prob θ x) ↔ ∀ θ θ' : Θ, θ ≠ θ' → S.prob θ x = 0 ∨ S.prob θ' x = 0 := by
  classical
  constructor
  · intro hEq θ θ' hne
    obtain ⟨θ₀, hθ₀⟩ := Finite.exists_max fun θ : Θ => S.prob θ x
    have hmax : S.maxLik x = S.prob θ₀ x :=
      le_antisymm (S.maxLik_le fun θ => hθ₀ θ) (S.le_maxLik θ₀ x)
    have hsplit : ∑ θ ∈ univ.erase θ₀, S.prob θ x = 0 := by
      have := Finset.add_sum_erase (univ : Finset Θ) (fun θ => S.prob θ x) (Finset.mem_univ θ₀)
      rw [hmax] at hEq
      linarith [hEq, this]
    have hzero : ∀ θ ∈ univ.erase θ₀, S.prob θ x = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg fun θ _ => S.nonneg θ x).mp hsplit
    by_cases h : θ = θ₀
    · subst h
      right
      exact hzero θ' (Finset.mem_erase.mpr ⟨Ne.symm hne, Finset.mem_univ θ'⟩)
    · left
      exact hzero θ (Finset.mem_erase.mpr ⟨h, Finset.mem_univ θ⟩)
  · intro hsing
    by_cases hall : ∀ θ : Θ, S.prob θ x = 0
    · have h1 : S.maxLik x = 0 :=
        le_antisymm (S.maxLik_le fun θ => le_of_eq (hall θ)) (S.maxLik_nonneg x)
      simp [h1, hall]
    · push_neg at hall
      obtain ⟨θ₀, hθ₀⟩ := hall
      have hzero : ∀ θ ∈ univ.erase θ₀, S.prob θ x = 0 := by
        intro θ hθ
        rcases hsing θ θ₀ (Finset.mem_erase.mp hθ).1 with h | h
        · exact h
        · exact absurd h hθ₀
      have hsum : ∑ θ, S.prob θ x = S.prob θ₀ x := by
        rw [← Finset.add_sum_erase (univ : Finset Θ) (fun θ => S.prob θ x) (Finset.mem_univ θ₀),
          Finset.sum_eq_zero hzero, add_zero]
      have hmax : S.maxLik x = S.prob θ₀ x := by
        refine le_antisymm (S.maxLik_le fun θ => ?_) (S.le_maxLik θ₀ x)
        by_cases h : θ = θ₀
        · exact le_of_eq (by rw [h])
        · rw [hzero θ (Finset.mem_erase.mpr ⟨h, Finset.mem_univ θ⟩)]
          exact S.nonneg θ₀ x
      rw [hmax, hsum]

/-- **Rigidity of the maximal price.**  A finite class pays the full
`log₂ #Θ` bits — the cost of naming the source — *exactly* when its sources are
mutually singular.  Part I proved the easy direction under an explicit support
partition; this is the characterisation. -/
theorem shtarkovSum_eq_card_iff_mutuallySingular [Fintype Θ] [Nonempty Θ] :
    S.shtarkovSum = (Fintype.card Θ : ℝ) ↔ S.MutuallySingular := by
  classical
  have hcons := S.shtarkovSum_add_overlap_eq_card
  constructor
  · intro hEq x θ θ' hne
    have hΩ : S.overlap = 0 := by linarith
    have hpt : ∀ x ∈ (univ : Finset X), (∑ θ, S.prob θ x) - S.maxLik x = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg
        fun x _ => sub_nonneg.mpr (S.maxLik_le_sum_prob x)).mp hΩ
    have := (S.maxLik_eq_sum_prob_iff x).mp (by linarith [hpt x (Finset.mem_univ x)])
    exact this θ θ' hne
  · intro hsing
    have hΩ : S.overlap = 0 :=
      Finset.sum_eq_zero fun x _ => by
        have := (S.maxLik_eq_sum_prob_iff x).mpr (fun θ θ' hne => hsing x θ θ' hne)
        linarith
    linarith

/-- **Strictness.**  A single message shared by two distinct sources already
makes the price of universality strictly cheaper than naming the source. -/
theorem shtarkovSum_lt_card_of_overlap [Fintype Θ] [Nonempty Θ] {x : X} {θ θ' : Θ}
    (hne : θ ≠ θ') (h1 : 0 < S.prob θ x) (h2 : 0 < S.prob θ' x) :
    S.shtarkovSum < (Fintype.card Θ : ℝ) := by
  have hle : S.shtarkovSum ≤ (Fintype.card Θ : ℝ) := S.shtarkovSum_le_card
  refine lt_of_le_of_ne hle fun hEq => ?_
  rcases (S.shtarkovSum_eq_card_iff_mutuallySingular).mp hEq x θ θ' hne with h | h
  · exact absurd h h1.ne'
  · exact absurd h h2.ne'

/-- **Support form of the rigidity.**  Maximal price is equivalent to the
existence of a family of pairwise disjoint supports carrying all the mass — the
hypothesis of Part I's `shtarkovSum_eq_card_of_disjoint_supports`, which is
therefore not merely sufficient but necessary. -/
theorem shtarkovSum_eq_card_iff_exists_supports [Fintype Θ] [Nonempty Θ] [DecidableEq X] :
    S.shtarkovSum = (Fintype.card Θ : ℝ) ↔
      ∃ supp : Θ → Finset X, (∀ θ θ', θ ≠ θ' → Disjoint (supp θ) (supp θ')) ∧
        ∀ θ, ∑ x ∈ supp θ, S.prob θ x = 1 := by
  classical
  constructor
  · intro hEq
    have hsing := (S.shtarkovSum_eq_card_iff_mutuallySingular).mp hEq
    refine ⟨fun θ => univ.filter (fun x => S.prob θ x ≠ 0), ?_, ?_⟩
    · intro θ θ' hne
      refine Finset.disjoint_left.mpr fun x hx hx' => ?_
      have h1 : S.prob θ x ≠ 0 := (Finset.mem_filter.mp hx).2
      have h2 : S.prob θ' x ≠ 0 := (Finset.mem_filter.mp hx').2
      rcases hsing x θ θ' hne with h | h
      · exact h1 h
      · exact h2 h
    · intro θ
      rw [Finset.sum_filter_ne_zero]
      exact S.sum_one θ
  · rintro ⟨supp, hdisj, hmass⟩
    exact S.shtarkovSum_eq_card_of_disjoint_supports supp hdisj hmass

/-! ## Rigidity at the lower endpoint -/

/-- **Rigidity of the free class.**  Universality is free (`Cₛ = 1`, zero bits)
only for a class all of whose sources have the *same* law: the converse of the
calibration law `shtarkovSum_of_subsingleton` of Part VII. -/
theorem shtarkovSum_eq_one_iff_forall_eq [Nonempty Θ] :
    S.shtarkovSum = 1 ↔ ∀ θ θ' x, S.prob θ x = S.prob θ' x := by
  constructor
  · intro hEq θ θ' x
    have key : ∀ ϑ : Θ, ∀ y : X, S.prob ϑ y = S.maxLik y := by
      intro ϑ
      have hle : ∀ y ∈ (univ : Finset X), S.prob ϑ y ≤ S.maxLik y := fun y _ => S.le_maxLik ϑ y
      have hsum : ∑ y, S.prob ϑ y = ∑ y, S.maxLik y := by
        rw [S.sum_one ϑ]; exact hEq.symm
      intro y
      exact (Finset.sum_eq_sum_iff_of_le hle).mp hsum y (Finset.mem_univ y)
    rw [key θ x, key θ' x]
  · intro h
    exact S.shtarkovSum_of_subsingleton h

/-- Contrapositive form: a class containing two genuinely different sources
pays a strictly positive number of bits. -/
theorem one_lt_shtarkovSum_of_ne [Nonempty Θ] {θ θ' : Θ} {x : X}
    (h : S.prob θ x ≠ S.prob θ' x) : 1 < S.shtarkovSum := by
  refine lt_of_le_of_ne S.one_le_shtarkovSum fun hEq => ?_
  exact h ((S.shtarkovSum_eq_one_iff_forall_eq).mp hEq.symm θ θ' x)

end SourceClass

/-! ## The exact two-source formula -/

variable {X : Type*} [Fintype X]

/-- Total variation distance between two laws on a finite message space. -/
noncomputable def tvDist (p q : X → ℝ) : ℝ := (∑ x, |p x - q x|) / 2

lemma tvDist_nonneg (p q : X → ℝ) : 0 ≤ tvDist p q := by
  unfold tvDist
  positivity

namespace SourceClass

/-- For a two-source class the maximum-likelihood envelope is the pointwise
maximum of the two laws. -/
lemma maxLik_bool (S : SourceClass X Bool) (x : X) :
    S.maxLik x = max (S.prob true x) (S.prob false x) := by
  refine le_antisymm (S.maxLik_le fun b => ?_) ?_
  · cases b
    · exact le_max_right _ _
    · exact le_max_left _ _
  · rcases max_cases (S.prob true x) (S.prob false x) with ⟨h, _⟩ | ⟨h, _⟩
    · rw [h]; exact S.le_maxLik true x
    · rw [h]; exact S.le_maxLik false x

/-- **The price of a pair is its total variation distance.**  For a class with
two sources the Shtarkov sum is exactly `1 + d_TV(p, q)`; the two rigidity
theorems above are the endpoints `d_TV = 0` and `d_TV = 1` of this formula. -/
theorem shtarkovSum_pair_eq_one_add_tvDist (S : SourceClass X Bool) :
    S.shtarkovSum = 1 + tvDist (S.prob true) (S.prob false) := by
  have hmax : ∀ a b : ℝ, max a b = (a + b + |a - b|) / 2 := by
    intro a b
    rcases le_total a b with h | h
    · rw [max_eq_right h, abs_of_nonpos (by linarith)]; ring
    · rw [max_eq_left h, abs_of_nonneg (by linarith)]; ring
  unfold shtarkovSum tvDist
  have hcongr : ∀ x : X, S.maxLik x
      = (S.prob true x + S.prob false x + |S.prob true x - S.prob false x|) / 2 := by
    intro x; rw [S.maxLik_bool x, hmax]
  rw [Finset.sum_congr rfl fun x _ => hcongr x]
  have hsplit : ∑ x, (S.prob true x + S.prob false x + |S.prob true x - S.prob false x|) / 2
      = ((∑ x, S.prob true x) + (∑ x, S.prob false x)
          + ∑ x, |S.prob true x - S.prob false x|) / 2 := by
    rw [← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_add_distrib]
  rw [hsplit, S.sum_one true, S.sum_one false]
  ring

/-- **Pairwise separation is a lower bound on the price.**  For any two members
of a class, the price of universality is at least `1 + d_TV`: statistically
distinguishable sources are expensive to serve with one code. -/
theorem one_add_tvDist_le_shtarkovSum {Θ : Type*} [Nonempty Θ] (S : SourceClass X Θ)
    (θ θ' : Θ) : 1 + tvDist (S.prob θ) (S.prob θ') ≤ S.shtarkovSum := by
  classical
  set ι : Bool → Θ := fun b => if b then θ else θ' with hι
  set P : SourceClass X Bool :=
    SourceClass.mk (fun b x => S.prob (ι b) x) (fun b x => S.nonneg (ι b) x)
      (fun b => S.sum_one (ι b)) with hP
  have hpair : P.shtarkovSum = 1 + tvDist (S.prob θ) (S.prob θ') := by
    have := P.shtarkovSum_pair_eq_one_add_tvDist
    simpa [hP, hι] using this
  have hmono : P.shtarkovSum ≤ S.shtarkovSum := S.shtarkovSum_reindex_le ι
  linarith [hpair ▸ hmono]

/-- The positive part of the difference of two laws integrates to the total
variation distance. -/
lemma sum_posPart_eq_tvDist {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∑ x, max (p x - q x) 0 = tvDist p q := by
  have hmax : ∀ t : ℝ, max t 0 = (t + |t|) / 2 := by
    intro t
    rcases le_total 0 t with h | h
    · rw [max_eq_left h, abs_of_nonneg h]; ring
    · rw [max_eq_right h, abs_of_nonpos h]; ring
  unfold tvDist
  rw [Finset.sum_congr rfl fun x _ => hmax (p x - q x), ← Finset.sum_div,
    Finset.sum_add_distrib, Finset.sum_sub_distrib, hp, hq]
  ring

/-- **Upper TV bound.**  Measured from any reference member `θ₀` of the class,
the price of universality is at most `1 + ∑_θ d_TV(p_θ, p_θ₀)`.  Together with
`one_add_tvDist_le_shtarkovSum` this sandwiches `Cₛ` between the largest and the
total statistical separation inside the class. -/
theorem shtarkovSum_le_one_add_sum_tvDist {Θ : Type*} [Fintype Θ] [Nonempty Θ]
    (S : SourceClass X Θ) (θ₀ : Θ) :
    S.shtarkovSum ≤ 1 + ∑ θ, tvDist (S.prob θ) (S.prob θ₀) := by
  classical
  have hpt : ∀ x : X, S.maxLik x ≤ S.prob θ₀ x + ∑ θ, max (S.prob θ x - S.prob θ₀ x) 0 := by
    intro x
    refine S.maxLik_le fun θ => ?_
    have h1 : S.prob θ x ≤ S.prob θ₀ x + max (S.prob θ x - S.prob θ₀ x) 0 := by
      rcases le_total (S.prob θ x) (S.prob θ₀ x) with h | h
      · have : max (S.prob θ x - S.prob θ₀ x) 0 = 0 := max_eq_right (by linarith)
        rw [this]; linarith
      · have : max (S.prob θ x - S.prob θ₀ x) 0 = S.prob θ x - S.prob θ₀ x :=
          max_eq_left (by linarith)
        rw [this]; linarith
    have h2 : max (S.prob θ x - S.prob θ₀ x) 0
        ≤ ∑ ϑ, max (S.prob ϑ x - S.prob θ₀ x) 0 :=
      Finset.single_le_sum (f := fun ϑ => max (S.prob ϑ x - S.prob θ₀ x) 0)
        (fun ϑ _ => le_max_right _ _) (Finset.mem_univ θ)
    linarith
  calc S.shtarkovSum ≤ ∑ x, (S.prob θ₀ x + ∑ θ, max (S.prob θ x - S.prob θ₀ x) 0) :=
        Finset.sum_le_sum fun x _ => hpt x
    _ = 1 + ∑ θ, ∑ x, max (S.prob θ x - S.prob θ₀ x) 0 := by
        rw [Finset.sum_add_distrib, S.sum_one θ₀, Finset.sum_comm]
    _ = 1 + ∑ θ, tvDist (S.prob θ) (S.prob θ₀) := by
        refine congrArg (fun t => 1 + t) (Finset.sum_congr rfl fun θ _ => ?_)
        exact sum_posPart_eq_tvDist (S.sum_one θ) (S.sum_one θ₀)

/-- The pointwise minimum of two laws integrates to `1 - d_TV`: the *affinity*
of the pair. -/
lemma sum_min_eq_one_sub_tvDist {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∑ x, min (p x) (q x) = 1 - tvDist p q := by
  have hmin : ∀ a b : ℝ, min a b = (a + b - |a - b|) / 2 := by
    intro a b
    rcases le_total a b with h | h
    · rw [min_eq_left h, abs_of_nonpos (by linarith)]; ring
    · rw [min_eq_right h, abs_of_nonneg (by linarith)]; ring
  unfold tvDist
  rw [Finset.sum_congr rfl fun x _ => hmin (p x) (q x), ← Finset.sum_div,
    Finset.sum_sub_distrib, Finset.sum_add_distrib, hp, hq]
  ring

/-- **Stability of the upper endpoint.**  Any *single* pair of statistically
close sources pulls the price of universality away from the maximum:
`Cₛ ≤ #Θ - 1 + d_TV(p_θ, p_θ')`.  At `d_TV = 0` this recovers the rigidity
theorem quantitatively, and at `d_TV = 1` it degenerates to the sharp bound. -/
theorem shtarkovSum_le_card_sub_one_add_tvDist {Θ : Type*} [Fintype Θ] [Nonempty Θ]
    (S : SourceClass X Θ) {θ θ' : Θ} (hne : θ ≠ θ') :
    S.shtarkovSum ≤ (Fintype.card Θ : ℝ) - 1 + tvDist (S.prob θ) (S.prob θ') := by
  classical
  have hpt : ∀ x : X, min (S.prob θ x) (S.prob θ' x)
      ≤ (∑ ϑ, S.prob ϑ x) - S.maxLik x := by
    intro x
    obtain ⟨ϑ₀, hϑ₀⟩ := Finite.exists_max fun ϑ : Θ => S.prob ϑ x
    have hmax : S.maxLik x = S.prob ϑ₀ x :=
      le_antisymm (S.maxLik_le fun ϑ => hϑ₀ ϑ) (S.le_maxLik ϑ₀ x)
    have herase : (∑ ϑ, S.prob ϑ x) - S.prob ϑ₀ x = ∑ ϑ ∈ univ.erase ϑ₀, S.prob ϑ x := by
      have := Finset.add_sum_erase (univ : Finset Θ) (fun ϑ => S.prob ϑ x)
        (Finset.mem_univ ϑ₀)
      linarith
    -- one of `θ`, `θ'` differs from the maximiser, and its mass survives the erasure
    have hpick : ∃ ϑ ∈ univ.erase ϑ₀, min (S.prob θ x) (S.prob θ' x) ≤ S.prob ϑ x := by
      by_cases h : θ = ϑ₀
      · exact ⟨θ', Finset.mem_erase.mpr ⟨fun hc => hne (h.trans hc.symm), Finset.mem_univ θ'⟩,
          min_le_right _ _⟩
      · exact ⟨θ, Finset.mem_erase.mpr ⟨h, Finset.mem_univ θ⟩, min_le_left _ _⟩
    obtain ⟨ϑ, hϑmem, hϑle⟩ := hpick
    have hsingle : S.prob ϑ x ≤ ∑ ϑ' ∈ univ.erase ϑ₀, S.prob ϑ' x :=
      Finset.single_le_sum (f := fun ϑ' => S.prob ϑ' x) (fun ϑ' _ => S.nonneg ϑ' x) hϑmem
    rw [hmax, herase]
    linarith
  have hsum : 1 - tvDist (S.prob θ) (S.prob θ') ≤ S.overlap := by
    rw [← sum_min_eq_one_sub_tvDist (S.sum_one θ) (S.sum_one θ')]
    exact Finset.sum_le_sum fun x _ => hpt x
  have hcons := S.shtarkovSum_add_overlap_eq_card
  linarith

/-- **All-pairs stability.**  Not just the closest pair: the *total* affinity
`∑_{θ ≠ θ'} (1 - d_TV(p_θ, p_θ'))` over all ordered pairs of distinct sources is
controlled by the overlap, hence by the deficiency `#Θ - Cₛ` from the maximal
price. -/
theorem sum_pairs_affinity_le_overlap {Θ : Type*} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
    (S : SourceClass X Θ) :
    ∑ θ : Θ, ∑ θ' ∈ univ.erase θ, (1 - tvDist (S.prob θ) (S.prob θ'))
      ≤ (Fintype.card Θ : ℝ) * ((Fintype.card Θ : ℝ) - 1) * S.overlap := by
  classical
  have hcard : ∀ θ : Θ, (((univ : Finset Θ).erase θ).card : ℝ) = (Fintype.card Θ : ℝ) - 1 := by
    intro θ
    rw [Finset.card_erase_of_mem (Finset.mem_univ θ), Finset.card_univ,
      Nat.cast_sub (Nat.one_le_iff_ne_zero.mpr Fintype.card_ne_zero), Nat.cast_one]
  -- pointwise: the mass shared by two distinct sources fits in the non-maximal part
  have hpt : ∀ (x : X) (θ θ' : Θ), θ ≠ θ' →
      min (S.prob θ x) (S.prob θ' x) ≤ (∑ ϑ, S.prob ϑ x) - S.maxLik x := by
    intro x θ θ' hne
    obtain ⟨ϑ₀, hϑ₀⟩ := Finite.exists_max fun ϑ : Θ => S.prob ϑ x
    have hmax : S.maxLik x = S.prob ϑ₀ x :=
      le_antisymm (S.maxLik_le fun ϑ => hϑ₀ ϑ) (S.le_maxLik ϑ₀ x)
    have herase : (∑ ϑ, S.prob ϑ x) - S.prob ϑ₀ x = ∑ ϑ ∈ univ.erase ϑ₀, S.prob ϑ x := by
      have := Finset.add_sum_erase (univ : Finset Θ) (fun ϑ => S.prob ϑ x)
        (Finset.mem_univ ϑ₀)
      linarith
    have hpick : ∃ ϑ ∈ univ.erase ϑ₀, min (S.prob θ x) (S.prob θ' x) ≤ S.prob ϑ x := by
      by_cases h : θ = ϑ₀
      · exact ⟨θ', Finset.mem_erase.mpr ⟨fun hc => hne (h.trans hc.symm), Finset.mem_univ θ'⟩,
          min_le_right _ _⟩
      · exact ⟨θ, Finset.mem_erase.mpr ⟨h, Finset.mem_univ θ⟩, min_le_left _ _⟩
    obtain ⟨ϑ, hϑmem, hϑle⟩ := hpick
    have hsingle : S.prob ϑ x ≤ ∑ ϑ' ∈ univ.erase ϑ₀, S.prob ϑ' x :=
      Finset.single_le_sum (f := fun ϑ' => S.prob ϑ' x) (fun ϑ' _ => S.nonneg ϑ' x) hϑmem
    rw [hmax, herase]
    linarith
  -- one message at a time, summed over the `#Θ (#Θ - 1)` ordered pairs
  have hx : ∀ x : X, ∑ θ : Θ, ∑ θ' ∈ univ.erase θ, min (S.prob θ x) (S.prob θ' x)
      ≤ (Fintype.card Θ : ℝ) * ((Fintype.card Θ : ℝ) - 1)
          * ((∑ ϑ, S.prob ϑ x) - S.maxLik x) := by
    intro x
    have hrow : ∀ θ : Θ, ∑ θ' ∈ univ.erase θ, min (S.prob θ x) (S.prob θ' x)
        ≤ ((Fintype.card Θ : ℝ) - 1) * ((∑ ϑ, S.prob ϑ x) - S.maxLik x) := by
      intro θ
      have hle : ∑ θ' ∈ univ.erase θ, min (S.prob θ x) (S.prob θ' x)
          ≤ ∑ _θ' ∈ univ.erase θ, ((∑ ϑ, S.prob ϑ x) - S.maxLik x) :=
        Finset.sum_le_sum fun θ' hθ' => hpt x θ θ' (Ne.symm (Finset.mem_erase.mp hθ').1)
      rwa [Finset.sum_const, nsmul_eq_mul, hcard θ] at hle
    have hsum := Finset.sum_le_sum fun (θ : Θ) (_ : θ ∈ (univ : Finset Θ)) => hrow θ
    rwa [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, ← mul_assoc] at hsum
  calc ∑ θ : Θ, ∑ θ' ∈ univ.erase θ, (1 - tvDist (S.prob θ) (S.prob θ'))
      = ∑ θ : Θ, ∑ θ' ∈ univ.erase θ, ∑ x : X, min (S.prob θ x) (S.prob θ' x) :=
        Finset.sum_congr rfl fun θ _ => Finset.sum_congr rfl fun θ' _ =>
          (sum_min_eq_one_sub_tvDist (S.sum_one θ) (S.sum_one θ')).symm
    _ = ∑ x : X, ∑ θ : Θ, ∑ θ' ∈ univ.erase θ, min (S.prob θ x) (S.prob θ' x) := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun θ _ => Finset.sum_comm
    _ ≤ ∑ x : X, (Fintype.card Θ : ℝ) * ((Fintype.card Θ : ℝ) - 1)
          * ((∑ ϑ, S.prob ϑ x) - S.maxLik x) := Finset.sum_le_sum fun x _ => hx x
    _ = (Fintype.card Θ : ℝ) * ((Fintype.card Θ : ℝ) - 1) * S.overlap := by
        unfold SourceClass.overlap
        rw [Finset.mul_sum]

/-- The price of universality drops below the maximum by the *average* pairwise
affinity of the class. -/
theorem shtarkovSum_le_card_sub_avg_affinity {Θ : Type*} [Fintype Θ] [DecidableEq Θ]
    [Nonempty Θ] (S : SourceClass X Θ) (hcard : 2 ≤ Fintype.card Θ) :
    S.shtarkovSum ≤ (Fintype.card Θ : ℝ)
      - (∑ θ : Θ, ∑ θ' ∈ univ.erase θ, (1 - tvDist (S.prob θ) (S.prob θ')))
          / ((Fintype.card Θ : ℝ) * ((Fintype.card Θ : ℝ) - 1)) := by
  have h2 : (2 : ℝ) ≤ (Fintype.card Θ : ℝ) := by exact_mod_cast hcard
  have hden : 0 < (Fintype.card Θ : ℝ) * ((Fintype.card Θ : ℝ) - 1) := by nlinarith
  have hmain := S.sum_pairs_affinity_le_overlap
  have hcons := S.shtarkovSum_add_overlap_eq_card
  have hdiv : (∑ θ : Θ, ∑ θ' ∈ univ.erase θ, (1 - tvDist (S.prob θ) (S.prob θ')))
      / ((Fintype.card Θ : ℝ) * ((Fintype.card Θ : ℝ) - 1)) ≤ S.overlap := by
    rw [div_le_iff₀ hden]
    linarith [hmain]
  linarith

/-! ## Bit-level form of the two rigidity theorems -/

/-- The price of universality is *zero bits* exactly for a class of identical
sources. -/
theorem logb_shtarkovSum_eq_zero_iff {Θ : Type*} [Nonempty Θ] (S : SourceClass X Θ) :
    logb 2 S.shtarkovSum = 0 ↔ ∀ θ θ' x, S.prob θ x = S.prob θ' x := by
  rw [← S.shtarkovSum_eq_one_iff_forall_eq]
  constructor
  · intro h
    rcases lt_or_eq_of_le S.one_le_shtarkovSum with hlt | heq
    · exact absurd h (ne_of_gt (Real.logb_pos (by norm_num) hlt))
    · exact heq.symm
  · intro h
    rw [h, Real.logb_one]

/-- The price of universality is the full `log₂ #Θ` bits exactly for a mutually
singular class. -/
theorem logb_shtarkovSum_eq_logb_card_iff {Θ : Type*} [Fintype Θ] [Nonempty Θ]
    (S : SourceClass X Θ) :
    logb 2 S.shtarkovSum = logb 2 (Fintype.card Θ : ℝ) ↔ S.MutuallySingular := by
  rw [← S.shtarkovSum_eq_card_iff_mutuallySingular]
  constructor
  · intro h
    have hcard : (0 : ℝ) < (Fintype.card Θ : ℝ) := by
      have : 0 < Fintype.card Θ := Fintype.card_pos
      exact_mod_cast this
    exact Real.logb_injOn_pos (by norm_num) (Set.mem_Ioi.mpr S.shtarkovSum_pos)
      (Set.mem_Ioi.mpr hcard) h
  · intro h
    rw [h]

end SourceClass

/-! ## Equality analysis of the tied-product induction (Part VII) -/

variable {X₁ X₂ : Type*} [Fintype X₁] [Fintype X₂]

/-- Pointwise form of the tied-product bound: the tied envelope never exceeds
the product of the block envelopes. -/
lemma maxLik_tiedProdClass_le {Θ : Type*} [Nonempty Θ]
    (S₁ : SourceClass X₁ Θ) (S₂ : SourceClass X₂ Θ) (x : X₁ × X₂) :
    (tiedProdClass S₁ S₂).maxLik x ≤ S₁.maxLik x.1 * S₂.maxLik x.2 :=
  SourceClass.maxLik_le _ fun θ =>
    mul_le_mul (S₁.le_maxLik θ x.1) (S₂.le_maxLik θ x.2) (S₂.nonneg _ _)
      (S₁.maxLik_nonneg x.1)

/-- The product of the block envelopes integrates to the product of the block
Shtarkov sums. -/
lemma sum_maxLik_mul_eq {Θ : Type*} [Nonempty Θ]
    (S₁ : SourceClass X₁ Θ) (S₂ : SourceClass X₂ Θ) :
    ∑ x : X₁ × X₂, S₁.maxLik x.1 * S₂.maxLik x.2
      = S₁.shtarkovSum * S₂.shtarkovSum := by
  rw [Fintype.sum_prod_type]
  calc ∑ x₁ : X₁, ∑ x₂ : X₂, S₁.maxLik x₁ * S₂.maxLik x₂
      = ∑ x₁ : X₁, S₁.maxLik x₁ * ∑ x₂ : X₂, S₂.maxLik x₂ :=
        Finset.sum_congr rfl fun x₁ _ => by rw [Finset.mul_sum]
    _ = S₁.shtarkovSum * S₂.shtarkovSum := by rw [← Finset.sum_mul]; rfl

/-- **Strictness from a single deficient outcome.**  If at one pair of block
outcomes the tied envelope falls strictly below the product of the block
envelopes, then tying the parameter strictly saves bits.  No finiteness of the
parameter space is needed, so this applies to continuous families such as the
memoryless simplex. -/
theorem shtarkovSum_tiedProdClass_lt_of_maxLik_lt {Θ : Type*} [Nonempty Θ]
    (S₁ : SourceClass X₁ Θ) (S₂ : SourceClass X₂ Θ) {x₁ : X₁} {x₂ : X₂}
    (h : (tiedProdClass S₁ S₂).maxLik (x₁, x₂) < S₁.maxLik x₁ * S₂.maxLik x₂) :
    (tiedProdClass S₁ S₂).shtarkovSum < S₁.shtarkovSum * S₂.shtarkovSum := by
  classical
  rw [← sum_maxLik_mul_eq S₁ S₂]
  refine Finset.sum_lt_sum (fun x _ => maxLik_tiedProdClass_le S₁ S₂ x)
    ⟨(x₁, x₂), Finset.mem_univ _, h⟩

/-- **Equality case of subadditivity.**  Two blocks driven by a *shared*
parameter pay the full additive price iff every pair of block outcomes admits a
single parameter maximising the likelihood of *both* blocks simultaneously.
This is the exact equality analysis of the induction behind
`shtarkovSum_tiedProdClass_le`. -/
theorem shtarkovSum_tiedProdClass_eq_iff {Θ : Type*} [Fintype Θ] [Nonempty Θ]
    (S₁ : SourceClass X₁ Θ) (S₂ : SourceClass X₂ Θ) :
    (tiedProdClass S₁ S₂).shtarkovSum = S₁.shtarkovSum * S₂.shtarkovSum ↔
      ∀ x₁ x₂, ∃ θ : Θ, S₁.prob θ x₁ = S₁.maxLik x₁ ∧ S₂.prob θ x₂ = S₂.maxLik x₂ := by
  classical
  have hpt : ∀ x : X₁ × X₂,
      (tiedProdClass S₁ S₂).maxLik x ≤ S₁.maxLik x.1 * S₂.maxLik x.2 :=
    maxLik_tiedProdClass_le S₁ S₂
  have hprod : ∑ x : X₁ × X₂, S₁.maxLik x.1 * S₂.maxLik x.2
      = S₁.shtarkovSum * S₂.shtarkovSum := sum_maxLik_mul_eq S₁ S₂
  constructor
  · intro hEq x₁ x₂
    have hsum : ∑ x : X₁ × X₂, (tiedProdClass S₁ S₂).maxLik x
        = ∑ x : X₁ × X₂, S₁.maxLik x.1 * S₂.maxLik x.2 := by
      rw [hprod]; exact hEq
    have hptEq : (tiedProdClass S₁ S₂).maxLik (x₁, x₂) = S₁.maxLik x₁ * S₂.maxLik x₂ :=
      (Finset.sum_eq_sum_iff_of_le (fun x _ => hpt x)).mp hsum (x₁, x₂) (Finset.mem_univ _)
    obtain ⟨θ₀, hθ₀⟩ := Finite.exists_max fun θ : Θ => S₁.prob θ x₁ * S₂.prob θ x₂
    have hattain : (tiedProdClass S₁ S₂).maxLik (x₁, x₂) = S₁.prob θ₀ x₁ * S₂.prob θ₀ x₂ :=
      le_antisymm (SourceClass.maxLik_le _ fun θ => hθ₀ θ)
        ((tiedProdClass S₁ S₂).le_maxLik θ₀ (x₁, x₂))
    have hkey : S₁.prob θ₀ x₁ * S₂.prob θ₀ x₂ = S₁.maxLik x₁ * S₂.maxLik x₂ := by
      rw [← hattain, hptEq]
    -- degenerate branches: a block whose envelope vanishes puts no constraint
    by_cases h1 : S₁.maxLik x₁ = 0
    · have hz : ∀ θ : Θ, S₁.prob θ x₁ = 0 := fun θ =>
        le_antisymm (h1 ▸ S₁.le_maxLik θ x₁) (S₁.nonneg θ x₁)
      obtain ⟨θ₂, hθ₂⟩ := Finite.exists_max fun θ : Θ => S₂.prob θ x₂
      exact ⟨θ₂, by rw [hz θ₂, h1],
        le_antisymm (S₂.maxLik_le fun θ => hθ₂ θ) (S₂.le_maxLik θ₂ x₂) ▸ rfl⟩
    by_cases h2 : S₂.maxLik x₂ = 0
    · have hz : ∀ θ : Θ, S₂.prob θ x₂ = 0 := fun θ =>
        le_antisymm (h2 ▸ S₂.le_maxLik θ x₂) (S₂.nonneg θ x₂)
      obtain ⟨θ₁, hθ₁⟩ := Finite.exists_max fun θ : Θ => S₁.prob θ x₁
      exact ⟨θ₁, le_antisymm (S₁.maxLik_le fun θ => hθ₁ θ) (S₁.le_maxLik θ₁ x₁) ▸ rfl,
        by rw [hz θ₁, h2]⟩
    · refine ⟨θ₀, ?_, ?_⟩
      · have hm1 : 0 < S₁.maxLik x₁ := lt_of_le_of_ne (S₁.maxLik_nonneg x₁) (Ne.symm h1)
        have hm2 : 0 < S₂.maxLik x₂ := lt_of_le_of_ne (S₂.maxLik_nonneg x₂) (Ne.symm h2)
        nlinarith [S₁.le_maxLik θ₀ x₁, S₂.le_maxLik θ₀ x₂, S₁.nonneg θ₀ x₁, S₂.nonneg θ₀ x₂]
      · have hm1 : 0 < S₁.maxLik x₁ := lt_of_le_of_ne (S₁.maxLik_nonneg x₁) (Ne.symm h1)
        have hm2 : 0 < S₂.maxLik x₂ := lt_of_le_of_ne (S₂.maxLik_nonneg x₂) (Ne.symm h2)
        nlinarith [S₁.le_maxLik θ₀ x₁, S₂.le_maxLik θ₀ x₂, S₁.nonneg θ₀ x₁, S₂.nonneg θ₀ x₂]
  · intro hcommon
    refine le_antisymm (shtarkovSum_tiedProdClass_le S₁ S₂) ?_
    rw [← hprod]
    refine Finset.sum_le_sum fun x _ => ?_
    obtain ⟨θ, hθ₁, hθ₂⟩ := hcommon x.1 x.2
    have := (tiedProdClass S₁ S₂).le_maxLik θ x
    rw [show (tiedProdClass S₁ S₂).prob θ x = S₁.prob θ x.1 * S₂.prob θ x.2 from rfl,
      hθ₁, hθ₂] at this
    exact this

/-- **Strict subadditivity.**  If some pair of block outcomes has no common
maximiser, tying the parameter *strictly* saves bits. -/
theorem shtarkovSum_tiedProdClass_lt {Θ : Type*} [Fintype Θ] [Nonempty Θ]
    (S₁ : SourceClass X₁ Θ) (S₂ : SourceClass X₂ Θ)
    (h : ∃ x₁ x₂, ∀ θ : Θ, S₁.prob θ x₁ ≠ S₁.maxLik x₁ ∨ S₂.prob θ x₂ ≠ S₂.maxLik x₂) :
    (tiedProdClass S₁ S₂).shtarkovSum < S₁.shtarkovSum * S₂.shtarkovSum := by
  refine lt_of_le_of_ne (shtarkovSum_tiedProdClass_le S₁ S₂) fun hEq => ?_
  obtain ⟨x₁, x₂, hx⟩ := h
  obtain ⟨θ, h1, h2⟩ := (shtarkovSum_tiedProdClass_eq_iff S₁ S₂).mp hEq x₁ x₂
  rcases hx θ with h | h
  · exact h h1
  · exact h h2

/-! ## Equality analysis of monotonicity (Part VII) -/

/-- The subclass of `S` obtained by reindexing the parameter along `ι`. -/
def reindexClass {Θ Θ' : Type*} {Y : Type*} [Fintype Y] (S : SourceClass Y Θ) (ι : Θ' → Θ) :
    SourceClass Y Θ' where
  prob θ' x := S.prob (ι θ') x
  nonneg θ' x := S.nonneg (ι θ') x
  sum_one θ' := S.sum_one (ι θ')

/-- **Equality case of monotonicity.**  A subclass is exactly as expensive to
serve universally as the full class iff it reproduces the maximum-likelihood
envelope at *every* message: pruning parameters is free precisely when the
pruned ones were never the maximisers. -/
theorem shtarkovSum_reindexClass_eq_iff {Θ Θ' : Type*} [Nonempty Θ] [Nonempty Θ']
    (S : SourceClass X Θ) (ι : Θ' → Θ) :
    (reindexClass S ι).shtarkovSum = S.shtarkovSum ↔
      ∀ x, (reindexClass S ι).maxLik x = S.maxLik x := by
  classical
  have hpt : ∀ x ∈ (univ : Finset X), (reindexClass S ι).maxLik x ≤ S.maxLik x :=
    fun x _ => SourceClass.maxLik_le _ fun θ' => S.le_maxLik (ι θ') x
  constructor
  · intro hEq x
    exact (Finset.sum_eq_sum_iff_of_le hpt).mp hEq x (Finset.mem_univ x)
  · intro h
    exact Finset.sum_congr rfl fun x _ => h x

/-! ## A worked extremal family -/

/-- The class of point masses on a finite alphabet: source `a` puts all its mass
on the message `a`.  It is the canonical mutually singular class. -/
noncomputable def pointMassClass (A : Type*) [Fintype A] [DecidableEq A] :
    SourceClass A A where
  prob a x := if x = a then 1 else 0
  nonneg a x := by by_cases h : x = a <;> simp [h]
  sum_one a := by simp

variable {A : Type*} [Fintype A] [DecidableEq A] [Nonempty A]

lemma maxLik_pointMassClass (x : A) : (pointMassClass A).maxLik x = 1 := by
  refine le_antisymm (SourceClass.maxLik_le _ fun a => ?_) ?_
  · show (if x = a then (1 : ℝ) else 0) ≤ 1
    split <;> norm_num
  · have := (pointMassClass A).le_maxLik x x
    simpa [pointMassClass] using this

/-- The point-mass class sits exactly at the upper endpoint: `Cₛ = #A`, i.e. a
universal code must spend the full `log₂ #A` bits naming the source. -/
theorem shtarkovSum_pointMassClass : (pointMassClass A).shtarkovSum = (Fintype.card A : ℝ) := by
  refine ((pointMassClass A).shtarkovSum_eq_card_iff_mutuallySingular).mpr ?_
  intro x a a' hne
  by_cases h : x = a
  · right
    show (if x = a' then (1 : ℝ) else 0) = 0
    rw [if_neg (show ¬ (x = a') from fun hc => hne (by rw [← h]; exact hc))]
  · left
    show (if x = a then (1 : ℝ) else 0) = 0
    rw [if_neg h]

/-- Tying the parameter of two point-mass blocks collapses the price from
`2 log₂ #A` bits to `log₂ #A` bits: `Cₛ(tied) = #A`, not `#A²`. -/
theorem shtarkovSum_tiedProdClass_pointMass :
    (tiedProdClass (pointMassClass A) (pointMassClass A)).shtarkovSum
      = (Fintype.card A : ℝ) := by
  classical
  have hmax : ∀ x : A × A, (tiedProdClass (pointMassClass A) (pointMassClass A)).maxLik x
      = if x.1 = x.2 then (1 : ℝ) else 0 := by
    intro x
    by_cases h : x.1 = x.2
    · rw [if_pos h]
      refine le_antisymm (SourceClass.maxLik_le _ fun a => ?_) ?_
      · show (if x.1 = a then (1 : ℝ) else 0) * (if x.2 = a then (1 : ℝ) else 0) ≤ 1
        split <;> split <;> norm_num
      · have := (tiedProdClass (pointMassClass A) (pointMassClass A)).le_maxLik x.1 x
        simpa [tiedProdClass, pointMassClass, h.symm] using this
    · rw [if_neg h]
      refine le_antisymm (SourceClass.maxLik_le _ fun a => ?_)
        (SourceClass.maxLik_nonneg _ x)
      show (if x.1 = a then (1 : ℝ) else 0) * (if x.2 = a then (1 : ℝ) else 0) ≤ 0
      by_cases h1 : x.1 = a
      · have h2 : ¬ (x.2 = a) := fun hc => h (h1.trans hc.symm)
        rw [if_neg h2]; norm_num
      · rw [if_neg h1]; norm_num
  unfold SourceClass.shtarkovSum
  rw [Finset.sum_congr rfl fun x _ => hmax x, Fintype.sum_prod_type]
  simp

/-- **Strict subadditivity, witnessed.**  On an alphabet with at least two
letters, sharing a parameter across two point-mass blocks is strictly cheaper
than choosing two parameters: `#A < #A · #A`. -/
theorem shtarkovSum_tiedProdClass_pointMass_lt (h : 2 ≤ Fintype.card A) :
    (tiedProdClass (pointMassClass A) (pointMassClass A)).shtarkovSum
      < (pointMassClass A).shtarkovSum * (pointMassClass A).shtarkovSum := by
  rw [shtarkovSum_tiedProdClass_pointMass, shtarkovSum_pointMassClass]
  have h2 : (2 : ℝ) ≤ (Fintype.card A : ℝ) := by exact_mod_cast h
  nlinarith

/-! ## Equality analysis of the sufficient-statistic bound (Part II) -/

namespace SourceClass

variable {Θ : Type*} (S : SourceClass X Θ)

/-- Each fibre of a sufficient statistic carries at most unit maximum-likelihood
mass: the pointwise inequality summed in Part II's `shtarkovSum_le_card_statistic`. -/
lemma sum_maxLik_fiber_le_one [Nonempty Θ] {σ : Type*} [DecidableEq σ] (T : X → σ)
    (hT : ∀ θ x y, T x = T y → S.prob θ x = S.prob θ y) (s : σ) :
    ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x ≤ 1 := by
  classical
  rcases Finset.eq_empty_or_nonempty (univ.filter (fun x => T x = s)) with he | hne
  · simp [he]
  obtain ⟨x0, hx0⟩ := hne
  have hx0' : T x0 = s := (Finset.mem_filter.mp hx0).2
  have hconstprob : ∀ θ, ∀ x ∈ univ.filter (fun x => T x = s), S.prob θ x = S.prob θ x0 :=
    fun θ x hx => hT θ x x0 (by rw [(Finset.mem_filter.mp hx).2, hx0'])
  have hconst : ∀ x ∈ univ.filter (fun x => T x = s), S.maxLik x = S.maxLik x0 := by
    intro x hx
    unfold SourceClass.maxLik
    exact congrArg _ (funext fun θ => hconstprob θ x hx)
  set k : ℕ := (univ.filter (fun x => T x = s)).card with hk
  have hkpos : 0 < k := Finset.card_pos.mpr ⟨x0, hx0⟩
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hkpos
  have hmass : ∀ θ, (k : ℝ) * S.prob θ x0 ≤ 1 := by
    intro θ
    have h1 : ∑ x ∈ univ.filter (fun x => T x = s), S.prob θ x = (k : ℝ) * S.prob θ x0 := by
      rw [Finset.sum_congr rfl (hconstprob θ), Finset.sum_const, nsmul_eq_mul, hk]
    have h2 : ∑ x ∈ univ.filter (fun x => T x = s), S.prob θ x ≤ ∑ x, S.prob θ x :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun x _ _ => S.nonneg θ x
    rw [S.sum_one θ] at h2
    linarith [h1 ▸ h2]
  have hmaxle : S.maxLik x0 ≤ 1 / (k : ℝ) := by
    refine S.maxLik_le fun θ => ?_
    rw [le_div_iff₀ hkR]
    calc S.prob θ x0 * (k : ℝ) = (k : ℝ) * S.prob θ x0 := by ring
      _ ≤ 1 := hmass θ
  calc ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x
      = (k : ℝ) * S.maxLik x0 := by
        rw [Finset.sum_congr rfl hconst, Finset.sum_const, nsmul_eq_mul, hk]
    _ ≤ (k : ℝ) * (1 / (k : ℝ)) := mul_le_mul_of_nonneg_left hmaxle hkR.le
    _ = 1 := by field_simp

/-- **Equality case of the sufficient-statistic bound.**  A class saturates
`Cₛ ≤ #σ` exactly when *every* fibre of the statistic is saturated, i.e. when
each type class carries a full unit of maximum-likelihood mass. -/
theorem shtarkovSum_eq_card_statistic_iff [Nonempty Θ] {σ : Type*} [Fintype σ] [DecidableEq σ]
    (T : X → σ) (hT : ∀ θ x y, T x = T y → S.prob θ x = S.prob θ y) :
    S.shtarkovSum = (Fintype.card σ : ℝ) ↔
      ∀ s : σ, ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x = 1 := by
  classical
  have hdecomp : S.shtarkovSum
      = ∑ s : σ, ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x :=
    (Finset.sum_fiberwise univ T S.maxLik).symm
  have hle : ∀ s ∈ (univ : Finset σ),
      ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x ≤ 1 :=
    fun s _ => S.sum_maxLik_fiber_le_one T hT s
  constructor
  · intro hEq s
    have hsum : ∑ s : σ, ∑ x ∈ univ.filter (fun x => T x = s), S.maxLik x
        = ∑ _s : σ, (1 : ℝ) := by
      rw [← hdecomp, hEq]; simp
    exact (Finset.sum_eq_sum_iff_of_le hle).mp hsum s (Finset.mem_univ s)
  · intro hfull
    rw [hdecomp, Finset.sum_congr rfl fun s _ => hfull s]
    simp

end SourceClass

end UniversalRedundancy

/-! ## Lab notes (exact rational experiments that guided this file)

Computed with `ℚ` arithmetic on explicit classes, `Cₛ = ∑ₓ max_θ p_θ x`:

* `p = (1/2, 1/3, 1/6)`, `q = (1/4, 1/4, 1/2)`:  `Cₛ = 4/3 = 1 + d_TV`.
* `p = (1, 0, 0)`,       `q = (0, 1/2, 1/2)`:    `Cₛ = 2   = 1 + d_TV` (singular).
* three copies of the uniform law on three letters: `Cₛ = 1`, overlap `Ω = 2`,
  so `Cₛ + Ω = 3 = #Θ`.
* all `8³ = 512` classes of three sources on three letters drawn from the
  palette `(1,0,0), (0,1,0), (0,0,1), (½,½,0), (½,0,½), (0,½,½), (⅓,⅓,⅓),
  (¼,¼,½)`: the predicate `Cₛ = 3` agreed with mutual singularity in every
  single case (0 disagreements) — the experiment behind
  `shtarkovSum_eq_card_iff_mutuallySingular`.
* tied product of two point-mass blocks on two letters: `Cₛ(tied) = 2` versus
  `Cₛ · Cₛ = 4` — the experiment behind `shtarkovSum_tiedProdClass_pointMass_lt`.
-/