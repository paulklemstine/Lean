import Novelty.OracleRealizationGap

/-!
# Crediting a sensor to a statistic: the exact realization bound

The round-74 experiment credited a policy with *realizing* an oracle sensor by comparing its
predictions to the sensor on a labelled population, first pooled ("lenient") and then inside
`log N` strata ("strict").  The strict verdict was `0 %` for every `N`-only policy.

This file supplies the exact combinatorial law behind such crediting.  Fix a finite population
`P`, a **statistic** `T : ι → κ` (everything a policy is allowed to read: residues, magnitude
stratum, a menu of probe answers, …) and a Boolean **target** `s : ι → Bool` (the sensor).  A
`T`-measurable policy is a map `f : κ → Bool`, and its error count is `err P T s f`.

## Main results

* `err_ge_irredError` : every `T`-measurable policy makes at least
  `irredError P T s = ∑_classes min(#true, #false)` mistakes;
* `exists_majority_optimal` : the class-wise majority vote attains that value exactly;
* `isLeast_err` : hence `irredError P T s` **is** the minimum error — a measurement, not a bound;
* `two_mul_irredError_of_balanced` : if every `T`-class is balanced (`#true = #false`), the
  minimum error is exactly half the population: the statistic realizes *nothing*, which is the
  exact form of the "strict within-strata crediting `0 %`" verdict;
* `residue_err_pos` : instantiated at the navigation sensor of
  `Novelty.OracleRealizationGap`, every residue-only policy has strictly positive error on an
  explicit two-point semiprime population, for every modulus and every threshold.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "percentage of the oracle peak realized" is not an information-theoretic
primitive; it is a minimum-error functional of the statistic the policy is allowed to read, and
it should have a closed form.

Experiment (Experimenter): `ComputationalEvidence.md` enumerates small populations (`|P| ≤ 8`)
and all `2^|κ|` policies by brute force, checking `min_f err = ∑ minorities` in every case.

Analysis (Analyst): the closed form is the sum of class minorities.  Two extremes explain the
two crediting regimes measured in the lab: statistics whose classes are pure give minimum error
`0` (full realization), and statistics whose classes are balanced give minimum error `|P| / 2`
(zero realization, no matter how the policy is fitted).  The lenient pooled credit sits between
because pooling merges strata whose base rates differ.

Critique (Critic): the bound must be attained, else "0 %" would be an artefact of a weak
argument; `exists_majority_optimal` exhibits the optimal policy explicitly.  The theorem is
stated for arbitrary `κ`, so it applies verbatim to menu-answer vectors, not just residues.
-/

namespace StatisticRealization

open Finset

variable {ι κ : Type*} [DecidableEq κ]

/-- The number of population members on which the `T`-measurable policy `f` disagrees with the
target `s`. -/
def err (P : Finset ι) (T : ι → κ) (s : ι → Bool) (f : κ → Bool) : ℕ :=
  (P.filter fun i => f (T i) ≠ s i).card

/-- The minority count of a Boolean target on a finset. -/
def minority (Q : Finset ι) (s : ι → Bool) : ℕ :=
  min (Q.filter fun i => s i = true).card (Q.filter fun i => s i = false).card

/-- The irreducible error of a statistic: the sum of the class minorities. -/
def irredError (P : Finset ι) (T : ι → κ) (s : ι → Bool) : ℕ :=
  ∑ c ∈ P.image T, minority (P.filter fun i => T i = c) s

/-- Restricting the mismatch set to a `T`-class replaces `f (T i)` by the constant `f c`. -/
lemma class_restrict (P : Finset ι) (T : ι → κ) (s : ι → Bool) (f : κ → Bool) (c : κ) :
    ((P.filter fun i => f (T i) ≠ s i).filter fun i => T i = c)
      = (P.filter fun i => T i = c).filter fun i => f c ≠ s i := by
  rw [Finset.filter_filter, Finset.filter_filter]
  apply Finset.filter_congr
  intro i _
  constructor
  · rintro ⟨h1, h2⟩; exact ⟨h2, by rw [← h2]; exact h1⟩
  · rintro ⟨h2, h1⟩; exact ⟨by rw [h2]; exact h1, h2⟩

/-- On a class where the policy answers `true`, its errors are the `false`-labelled members. -/
lemma err_class_true (P : Finset ι) (T : ι → κ) (s : ι → Bool) (f : κ → Bool) {c : κ}
    (hfc : f c = true) :
    ((P.filter fun i => f (T i) ≠ s i).filter fun i => T i = c).card =
      ((P.filter fun i => T i = c).filter fun i => s i = false).card := by
  rw [class_restrict]
  congr 1
  apply Finset.filter_congr
  intro i _
  rw [hfc]
  cases s i <;> simp

/-- On a class where the policy answers `false`, its errors are the `true`-labelled members. -/
lemma err_class_false (P : Finset ι) (T : ι → κ) (s : ι → Bool) (f : κ → Bool) {c : κ}
    (hfc : f c = false) :
    ((P.filter fun i => f (T i) ≠ s i).filter fun i => T i = c).card =
      ((P.filter fun i => T i = c).filter fun i => s i = true).card := by
  rw [class_restrict]
  congr 1
  apply Finset.filter_congr
  intro i _
  rw [hfc]
  cases s i <;> simp

/-- The class-wise decomposition of the error count. -/
lemma err_eq_sum (P : Finset ι) (T : ι → κ) (s : ι → Bool) (f : κ → Bool) :
    err P T s f = ∑ c ∈ P.image T,
      ((P.filter fun i => f (T i) ≠ s i).filter fun i => T i = c).card := by
  refine Finset.card_eq_sum_card_fiberwise ?_
  intro i hi
  exact Finset.mem_image_of_mem T (Finset.mem_of_mem_filter i hi)

/-- **Lower bound.**  No `T`-measurable policy beats the sum of the class minorities. -/
theorem err_ge_irredError (P : Finset ι) (T : ι → κ) (s : ι → Bool) (f : κ → Bool) :
    irredError P T s ≤ err P T s f := by
  rw [err_eq_sum]
  refine Finset.sum_le_sum ?_
  intro c _
  unfold minority
  cases hfc : f c with
  | true => rw [err_class_true P T s f hfc]; exact min_le_right _ _
  | false => rw [err_class_false P T s f hfc]; exact min_le_left _ _

/-- The class-wise majority vote. -/
def majority (P : Finset ι) (T : ι → κ) (s : ι → Bool) (c : κ) : Bool :=
  decide (((P.filter fun i => T i = c).filter fun i => s i = false).card ≤
    ((P.filter fun i => T i = c).filter fun i => s i = true).card)

/-- **Attainment.**  The majority vote realizes the irreducible error exactly. -/
theorem exists_majority_optimal (P : Finset ι) (T : ι → κ) (s : ι → Bool) :
    err P T s (majority P T s) = irredError P T s := by
  rw [err_eq_sum]
  refine Finset.sum_congr rfl ?_
  intro c _
  unfold minority
  by_cases h : ((P.filter fun i => T i = c).filter fun i => s i = false).card ≤
      ((P.filter fun i => T i = c).filter fun i => s i = true).card
  · have hmaj : majority P T s c = true := by unfold majority; simpa using h
    rw [err_class_true P T s _ hmaj]
    exact (min_eq_right h).symm
  · have hmaj : majority P T s c = false := by unfold majority; simpa using h
    rw [err_class_false P T s _ hmaj]
    exact (min_eq_left (le_of_lt (lt_of_not_ge h))).symm

/-- **The measurement.**  `irredError` is the least achievable error of a `T`-measurable
policy: the exact amount of the target that the statistic `T` fails to realize. -/
theorem isLeast_err (P : Finset ι) (T : ι → κ) (s : ι → Bool) :
    IsLeast {n | ∃ f : κ → Bool, err P T s f = n} (irredError P T s) :=
  ⟨⟨majority P T s, exists_majority_optimal P T s⟩,
   by rintro n ⟨f, rfl⟩; exact err_ge_irredError P T s f⟩

/-- A class in which the target is balanced contributes exactly half its size. -/
lemma two_mul_minority_of_balanced (Q : Finset ι) (s : ι → Bool)
    (hbal : (Q.filter fun i => s i = true).card = (Q.filter fun i => s i = false).card) :
    2 * minority Q s = Q.card := by
  have hsplit : (Q.filter fun i => s i = true).card + (Q.filter fun i => s i = false).card
      = Q.card := by
    have h := Finset.card_filter_add_card_filter_not (s := Q) (p := fun i => s i = true)
    simp only [Bool.not_eq_true] at h
    simpa using h
  unfold minority
  omega

/-- **Strict crediting is zero on balanced strata.**  If every `T`-class carries the two target
values equally often, then the least error of any `T`-measurable policy is exactly half the
population: the statistic realizes none of the target. -/
theorem two_mul_irredError_of_balanced (P : Finset ι) (T : ι → κ) (s : ι → Bool)
    (hbal : ∀ c ∈ P.image T,
      ((P.filter fun i => T i = c).filter fun i => s i = true).card =
        ((P.filter fun i => T i = c).filter fun i => s i = false).card) :
    2 * irredError P T s = P.card := by
  have hfib : P.card = ∑ c ∈ P.image T, (P.filter fun i => T i = c).card :=
    Finset.card_eq_sum_card_fiberwise fun i hi => Finset.mem_image_of_mem T hi
  unfold irredError
  rw [Finset.mul_sum, hfib]
  exact Finset.sum_congr rfl fun c hc =>
    two_mul_minority_of_balanced _ s (hbal c hc)

/-! ## The navigation sensor against residue statistics -/

open OracleRealizationGap

/-- **Zero realization, concretely.**  For every modulus `L ≠ 0` and every sensor threshold `B`
there is a two-point population of semiprimes on which every residue-only policy errs: the
residue statistic realizes none of the navigation sensor. -/
theorem residue_err_pos (L B : ℕ) (hL : L ≠ 0) :
    ∃ p q₁ q₂ : ℕ, p.Prime ∧ q₁.Prime ∧ q₂.Prime ∧ (p, q₁) ≠ (p, q₂) ∧
      ∀ f : ℕ → Bool,
        0 < err ({(p, q₁), (p, q₂)} : Finset (ℕ × ℕ))
          (fun x => (x.1 * x.2) % L) (fun x => sensor B x.1 x.2) f := by
  obtain ⟨p, q₁, q₂, hp, hq₁, hq₂, _, _, _, hpq₁, hpq₂, hmod, hlo, hhi⟩ :=
    residue_menu_blind L B hL
  have hne : q₁ ≠ q₂ := by
    intro h
    rw [h] at hlo
    omega
  refine ⟨p, q₁, q₂, hp, hq₁, hq₂, by simp [hne], ?_⟩
  intro f
  have hs₁ : sensor B p q₁ = true := by simp [sensor, hlo]
  have hs₂ : sensor B p q₂ = false := by
    simp only [sensor, decide_eq_false_iff_not, not_le]; omega
  have hres : (p * q₁) % L = (p * q₂) % L := hmod
  rw [err, Finset.card_pos]
  by_cases hf : f ((p * q₁) % L) = true
  · refine ⟨(p, q₂), Finset.mem_filter.mpr ⟨by simp, ?_⟩⟩
    simp only
    rw [hs₂, ← hres, hf]
    simp
  · refine ⟨(p, q₁), Finset.mem_filter.mpr ⟨by simp, ?_⟩⟩
    simp only
    rw [hs₁]
    simpa using hf

end StatisticRealization