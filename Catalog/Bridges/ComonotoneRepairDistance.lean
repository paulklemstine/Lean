/-
# The comonotone repair distance and the discordance mass

Third cycle of the `UniformDial` thread (see `Combinatorics.UniformDialDrawInvariance` for
the pairwise identity and `Combinatorics.UniformDialRegimeHomotopy` for the concordance
budget and the QS triage rule).

A population `(x, y)` on a finite key set `ι` is *comonotone* when no pair of keys is
discordant.  The regime-free quantity governing the triage rule of the previous cycle is
the **discordance mass** `Δ = discordanceMass x y`.  Here we introduce a genuinely
different, *geometric* measure of non-comonotonicity:

> `repairDist x y = inf { ‖d‖₁ : (x, y + d) is comonotone }`,

the least ℓ¹ perturbation of the rates that removes every discordant pair.  This is exactly
the ℓ¹ distance from `y` to the isotonic cone of the preorder induced by `x`, so the object
is an ℓ¹ isotonic-regression problem attached to the population.

## What is proved

* `repairDist_nonneg`, `repairDist_le_of_mem`, `le_repairDist` — the infimum is well posed
  (the repair set is never empty: `d = x - y` always works).
* `violation_le_repairDist` — every discordant pair is a certificate: the size of its
  rate inversion is a lower bound for the repair distance.
* `repairDist_eq_zero_iff_comonotone` — the repair distance is a faithful defect measure.
* `discordanceMass_le_repairDist` — **upper bound**: `Δ ≤ 2 · |ι| · range(x) · δ`.
* `repairDist_le_discordanceMass` — **lower bound**: `g · δ ≤ Δ` whenever the distinct
  footprint values are `g`-separated.  The proof is constructive and dimension-free: the
  upper envelope `isoUp` of `y` along `x` is an explicit admissible repair whose cost at
  each key is charged to a *distinct column* of the discordance matrix.
* `repair_discordance_two_sided` — the two bounds packaged as a two-sided comparison.
* `dial_pos_of_repair_distance` — **QS triage with a single population parameter**: the
  dial is strictly positive in *every* regime with mass ratio `κ = M/ε` as soon as
  `κ² · 2 |ι| · range(x) · δ < C`.

## What is refuted

The naive dimension-free forms of the two inequalities are *false*, and we prove it with
explicit finite populations:

* `no_quadratic_lower_bound` — `δ² ≤ Δ` fails (`x = (0,1)`, `y = (3,0)`: `δ = 3`, `Δ = 6`).
  The two sides have different scaling degrees in `y`, so no such bound can hold.
* `no_dimension_free_upper_bound` — `Δ ≤ 2 δ range(x)` fails (`x = (0,1,2)`, `y = (1,0,0)`:
  `δ = 1`, `range = 2`, `Δ = 6 > 4`).  The factor `|ι|` in `discordanceMass_le_repairDist`
  is therefore not an artifact of the proof.
* `no_lower_bound_constant_above_two` — the constant in `g · δ ≤ Δ` is optimal up to `2`.
* `discordance_not_determined_by_repairDist` — two populations with the *same* footprint
  and the *same* repair distance but different discordance mass.  Hence `Δ` is not a
  function of `δ`: the pairwise data is irreducible, and no ℓ¹ repair statistic can
  replace it in the triage rule.
-/
import Combinatorics.UniformDialRegimeHomotopy

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-! ### The repair distance -/

/-- ℓ¹ size of a perturbation of the rates. -/
noncomputable def l1norm (d : ι → ℝ) : ℝ := ∑ i, |d i|

lemma l1norm_nonneg (d : ι → ℝ) : 0 ≤ l1norm d :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-- The admissible repairs of a population: the perturbations of the rate vector that
make the population comonotone. -/
def RepairSet (x y : ι → ℝ) : Set (ι → ℝ) := {d | Comonotone x (fun i => y i + d i)}

omit [Fintype ι] in
/-- `d = x - y` is always an admissible repair, so the repair set is never empty. -/
lemma sub_mem_RepairSet (x y : ι → ℝ) : (fun i => x i - y i) ∈ RepairSet x y := by
  intro i j
  have h : (x i - x j) * ((y i + (x i - y i)) - (y j + (x j - y j))) = (x i - x j) ^ 2 := by
    ring
  rw [h]
  exact sq_nonneg _

/-- **The comonotone repair distance**: the least ℓ¹ perturbation of the rates that
removes every discordant pair. -/
noncomputable def repairDist (x y : ι → ℝ) : ℝ := sInf (l1norm '' RepairSet x y)

lemma repairImage_nonempty (x y : ι → ℝ) : (l1norm '' RepairSet x y).Nonempty :=
  ⟨_, ⟨_, sub_mem_RepairSet x y, rfl⟩⟩

lemma repairImage_bddBelow (x y : ι → ℝ) : BddBelow (l1norm '' RepairSet x y) := by
  refine ⟨0, ?_⟩
  rintro _ ⟨d, -, rfl⟩
  exact l1norm_nonneg d

lemma repairDist_nonneg (x y : ι → ℝ) : 0 ≤ repairDist x y := by
  refine le_csInf (repairImage_nonempty x y) ?_
  rintro _ ⟨d, -, rfl⟩
  exact l1norm_nonneg d

/-- Every admissible repair bounds the repair distance from above. -/
lemma repairDist_le_of_mem {x y d : ι → ℝ} (hd : d ∈ RepairSet x y) :
    repairDist x y ≤ l1norm d :=
  csInf_le (repairImage_bddBelow x y) ⟨d, hd, rfl⟩

/-- A quantity dominated by the cost of every admissible repair bounds the repair
distance from below. -/
lemma le_repairDist {x y : ι → ℝ} {c : ℝ} (h : ∀ d ∈ RepairSet x y, c ≤ l1norm d) :
    c ≤ repairDist x y := by
  refine le_csInf (repairImage_nonempty x y) ?_
  rintro _ ⟨d, hd, rfl⟩
  exact h d hd

/-- Two coordinates of a perturbation never cost more than its ℓ¹ size. -/
lemma two_abs_le_l1norm (d : ι → ℝ) {i j : ι} (hij : i ≠ j) :
    |d i| + |d j| ≤ l1norm d := by
  classical
  have hsub : ({i, j} : Finset ι) ⊆ univ := subset_univ _
  have hpair : ∑ k ∈ ({i, j} : Finset ι), |d k| = |d i| + |d j| := by
    rw [Finset.sum_pair hij]
  calc |d i| + |d j| = ∑ k ∈ ({i, j} : Finset ι), |d k| := hpair.symm
    _ ≤ ∑ k, |d k| :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub (fun k _ _ => abs_nonneg _)
    _ = l1norm d := rfl

/-- **Every discordant pair is a certificate.**  If key `i` has the strictly smaller
footprint, then any repair must pay at least the size of the rate inversion `y i - y j`
(the statement is vacuous when that quantity is nonpositive). -/
theorem violation_le_repairDist {x y : ι → ℝ} {i j : ι} (hx : x i < x j) :
    y i - y j ≤ repairDist x y := by
  refine le_repairDist ?_
  intro d hd
  have hcom := hd i j
  have hne : i ≠ j := fun h => absurd (h ▸ hx) (lt_irrefl _)
  have hxneg : x i - x j < 0 := by linarith
  have hz : y i + d i ≤ y j + d j := by nlinarith [hcom]
  have h1 : y i - y j ≤ d j - d i := by linarith
  have h2 : d j - d i ≤ |d i| + |d j| := by
    have := neg_abs_le (d i)
    have := le_abs_self (d j)
    linarith
  exact h1.trans (h2.trans (two_abs_le_l1norm d hne))

/-- The repair distance vanishes exactly on comonotone populations: it is a faithful
measure of the population's defect, just like the discordance mass. -/
theorem repairDist_eq_zero_iff_comonotone (x y : ι → ℝ) :
    repairDist x y = 0 ↔ Comonotone x y := by
  constructor
  · intro h i j
    by_contra hij
    push_neg at hij
    -- a discordant pair produces a strictly positive certificate
    rcases lt_trichotomy (x i) (x j) with hx | hx | hx
    · have hy : y j < y i := by nlinarith
      have := violation_le_repairDist (y := y) hx
      rw [h] at this
      linarith
    · rw [hx] at hij; simp at hij
    · have hy : y i < y j := by nlinarith
      have := violation_le_repairDist (y := y) hx
      rw [h] at this
      linarith
  · intro h
    refine le_antisymm ?_ (repairDist_nonneg x y)
    have hmem : (fun _ : ι => (0 : ℝ)) ∈ RepairSet x y := by
      intro i j
      simpa using h i j
    have := repairDist_le_of_mem hmem
    simpa [l1norm] using this

/-! ### Upper bound: the discordance mass is controlled by the repair distance -/

lemma sum_pair_abs (d : ι → ℝ) :
    ∑ i, ∑ j, (|d i| + |d j|) = 2 * (Fintype.card ι : ℝ) * l1norm d := by
  have h1 : ∀ i : ι, ∑ _j : ι, |d i| = (Fintype.card ι : ℝ) * |d i| := by
    intro i
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have : ∑ i, ∑ j, (|d i| + |d j|)
      = ∑ i : ι, ((Fintype.card ι : ℝ) * |d i| + l1norm d) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_add_distrib, h1 i]
    rfl
  rw [this, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul]
  simp only [l1norm]
  ring

omit [Fintype ι] in
/-- Pointwise bound: the discordant part of a pair product is at most `range(x)` times the
ℓ¹ cost the repair spends on the two keys. -/
lemma discordant_term_le {x y d : ι → ℝ} (hd : d ∈ RepairSet x y) {R : ℝ} (hR : 0 ≤ R)
    (hx : ∀ i j, |x i - x j| ≤ R) (i j : ι) :
    max (-((x i - x j) * (y i - y j))) 0 ≤ R * (|d i| + |d j|) := by
  have hcom := hd i j
  have key : -((x i - x j) * (y i - y j)) ≤ (x i - x j) * (d i - d j) := by nlinarith [hcom]
  have habs : (x i - x j) * (d i - d j) ≤ R * (|d i| + |d j|) := by
    have h1 : (x i - x j) * (d i - d j) ≤ |x i - x j| * |d i - d j| := by
      have := le_abs_self ((x i - x j) * (d i - d j))
      rwa [abs_mul] at this
    have h2 : |d i - d j| ≤ |d i| + |d j| := abs_sub _ _
    have h3 : |x i - x j| * |d i - d j| ≤ R * (|d i| + |d j|) :=
      mul_le_mul (hx i j) h2 (abs_nonneg _) hR
    linarith
  have hnn : 0 ≤ R * (|d i| + |d j|) :=
    mul_nonneg hR (by positivity)
  exact max_le (le_trans key habs) hnn

/-- Every admissible repair bounds the discordance mass. -/
lemma discordanceMass_le_of_mem {x y d : ι → ℝ} (hd : d ∈ RepairSet x y) {R : ℝ}
    (hR : 0 ≤ R) (hx : ∀ i j, |x i - x j| ≤ R) :
    discordanceMass x y ≤ 2 * (Fintype.card ι : ℝ) * R * l1norm d := by
  have hstep : discordanceMass x y ≤ ∑ i, ∑ j, R * (|d i| + |d j|) := by
    refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
    exact discordant_term_le hd hR hx i j
  have hsum : ∑ i, ∑ j, R * (|d i| + |d j|) = R * ∑ i, ∑ j, (|d i| + |d j|) := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by rw [Finset.mul_sum]
  rw [hsum, sum_pair_abs d] at hstep
  linarith [hstep]

/-- **Upper bound (corrected form).**  The discordance mass is at most
`2 · |ι| · range(x)` times the comonotone repair distance.  The population-size factor is
genuinely needed — see `no_dimension_free_upper_bound`. -/
theorem discordanceMass_le_repairDist (x y : ι → ℝ) {R : ℝ} (hx : ∀ i j, |x i - x j| ≤ R) :
    discordanceMass x y ≤ 2 * (Fintype.card ι : ℝ) * R * repairDist x y := by
  rcases isEmpty_or_nonempty ι with hι | hι
  · have hcard : (Fintype.card ι : ℝ) = 0 := by
      simp [Fintype.card_eq_zero]
    simp [discordanceMass, Finset.univ_eq_empty]
  · obtain ⟨i0⟩ := hι
    have hR : 0 ≤ R := by simpa using hx i0 i0
    have hkey : ∀ d ∈ RepairSet x y,
        discordanceMass x y ≤ 2 * (Fintype.card ι : ℝ) * R * l1norm d :=
      fun d hd => discordanceMass_le_of_mem hd hR hx
    set c : ℝ := 2 * (Fintype.card ι : ℝ) * R with hc
    have hc0 : 0 ≤ c := by
      have : (0 : ℝ) ≤ (Fintype.card ι : ℝ) := Nat.cast_nonneg _
      positivity
    rcases eq_or_lt_of_le hc0 with hzero | hpos
    · have hd0 := hkey _ (sub_mem_RepairSet x y)
      rw [← hzero] at hd0 ⊢
      have : discordanceMass x y ≤ 0 := by simpa using hd0
      have h2 := discordanceMass_nonneg x y
      linarith [this, h2]
    · have hbound : discordanceMass x y / c ≤ repairDist x y := by
        refine le_repairDist ?_
        intro d hd
        rw [div_le_iff₀ hpos]
        have := hkey d hd
        linarith [this]
      rw [div_le_iff₀ hpos] at hbound
      linarith [hbound]

/-! ### Lower bound: an explicit repair built from the upper envelope of the rates -/

open Classical in
/-- The keys whose footprint is strictly below that of `i`, together with `i` itself. -/
noncomputable def predSet (x : ι → ℝ) (i : ι) : Finset ι :=
  insert i (univ.filter (fun j => x j < x i))

lemma mem_predSet_self (x : ι → ℝ) (i : ι) : i ∈ predSet x i := by
  classical
  simp [predSet]

lemma predSet_nonempty (x : ι → ℝ) (i : ι) : (predSet x i).Nonempty :=
  ⟨i, mem_predSet_self x i⟩

lemma mem_predSet_iff {x : ι → ℝ} {i j : ι} : j ∈ predSet x i ↔ j = i ∨ x j < x i := by
  classical
  simp [predSet]

lemma predSet_subset {x : ι → ℝ} {i k : ι} (h : x i < x k) : predSet x i ⊆ predSet x k := by
  intro j hj
  rcases mem_predSet_iff.mp hj with rfl | hj
  · exact mem_predSet_iff.mpr (Or.inr h)
  · exact mem_predSet_iff.mpr (Or.inr (hj.trans h))

/-- The **upper envelope** of the rates along the footprint: the largest rate seen at or
strictly below the footprint of `i`.  It is the canonical isotonic majorant of `y`. -/
noncomputable def isoUp (x y : ι → ℝ) (i : ι) : ℝ :=
  (predSet x i).sup' (predSet_nonempty x i) y

lemma le_isoUp (x y : ι → ℝ) (i : ι) : y i ≤ isoUp x y i :=
  Finset.le_sup' y (mem_predSet_self x i)

lemma isoUp_mono {x y : ι → ℝ} {i k : ι} (h : x i < x k) : isoUp x y i ≤ isoUp x y k :=
  Finset.sup'_mono y (predSet_subset h) (predSet_nonempty x i)

/-- The upper envelope is comonotone with the footprint. -/
lemma comonotone_isoUp (x y : ι → ℝ) : Comonotone x (isoUp x y) := by
  intro i j
  rcases lt_trichotomy (x i) (x j) with h | h | h
  · have := isoUp_mono (y := y) h
    nlinarith
  · rw [h]; simp
  · have := isoUp_mono (y := y) h
    nlinarith

/-- A single discordant pair term never exceeds the total discordance mass. -/
lemma term_le_discordanceMass (x y : ι → ℝ) (a b : ι) :
    max (-((x a - x b) * (y a - y b))) 0 ≤ discordanceMass x y := by
  have hinner : max (-((x a - x b) * (y a - y b))) 0
      ≤ ∑ j, max (-((x a - x j) * (y a - y j))) 0 :=
    Finset.single_le_sum (f := fun j => max (-((x a - x j) * (y a - y j))) 0)
      (fun j _ => le_max_right _ _) (mem_univ b)
  have houter : (∑ j, max (-((x a - x j) * (y a - y j))) 0) ≤ discordanceMass x y :=
    Finset.single_le_sum (f := fun i => ∑ j, max (-((x i - x j) * (y i - y j))) 0)
      (fun i _ => Finset.sum_nonneg fun j _ => le_max_right _ _) (mem_univ a)
  exact hinner.trans houter

/-- Each coordinate of the envelope repair is paid for by the *column* of the discordance
matrix indexed by that key.  The witness pairs of distinct keys therefore live in distinct
columns, which is what makes the resulting bound dimension-free. -/
lemma gap_isoUp_le_column {x y : ι → ℝ} {g : ℝ} (hg : 0 < g)
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) (b : ι) :
    g * (isoUp x y b - y b) ≤ ∑ a, max (-((x a - x b) * (y a - y b))) 0 := by
  have hcol : 0 ≤ ∑ a, max (-((x a - x b) * (y a - y b))) 0 :=
    Finset.sum_nonneg fun a _ => le_max_right _ _
  obtain ⟨j, hj, hje⟩ := Finset.exists_mem_eq_sup' (predSet_nonempty x b) y
  have hval : isoUp x y b = y j := hje
  rcases mem_predSet_iff.mp hj with rfl | hlt
  · rw [hval]
    simpa using hcol
  · rcases le_or_gt (y j) (y b) with hy | hy
    · have hnp : isoUp x y b - y b ≤ 0 := by rw [hval]; linarith
      nlinarith
    · have hgg : g ≤ x b - x j := hgap j b hlt
      have hterm : max (-((x j - x b) * (y j - y b))) 0
          ≤ ∑ a, max (-((x a - x b) * (y a - y b))) 0 :=
        Finset.single_le_sum (f := fun a => max (-((x a - x b) * (y a - y b))) 0)
          (fun a _ => le_max_right _ _) (mem_univ j)
      have hpos : g * (y j - y b) ≤ -((x j - x b) * (y j - y b)) := by nlinarith
      have hmax : -((x j - x b) * (y j - y b)) ≤ max (-((x j - x b) * (y j - y b))) 0 :=
        le_max_left _ _
      rw [hval]
      linarith

/-- **Lower bound (dimension-free).**  If the distinct footprint values are `g`-separated,
then `g · δ ≤ Δ`: a population that is expensive to repair must carry proportionally much
discordance mass, with *no* dependence on the population size.

The proof is constructive.  The isotonic upper envelope `isoUp` of `y` along `x` is an
explicit admissible repair; the cost it spends at key `b` is witnessed by a discordant
pair whose *second* coordinate is `b`, so distinct keys are charged to distinct columns of
the discordance matrix and the charges may be summed without loss.

The constant is sharp up to a factor `2`: for `x = (0,1)`, `y = (3,0)` one has `g = 1`,
`δ = 3` and `Δ = 6 = 2 · g · δ` (see `no_lower_bound_constant_above_two`). -/
theorem repairDist_le_discordanceMass {x y : ι → ℝ} {g : ℝ} (hg : 0 < g)
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) :
    g * repairDist x y ≤ discordanceMass x y := by
  set d : ι → ℝ := fun i => isoUp x y i - y i with hd
  have hmem : d ∈ RepairSet x y := by
    intro i j
    have hi : y i + d i = isoUp x y i := by simp [hd]
    have hj : y j + d j = isoUp x y j := by simp [hd]
    show (0 : ℝ) ≤ (x i - x j) * ((y i + d i) - (y j + d j))
    rw [hi, hj]
    exact comonotone_isoUp x y i j
  have hl1 : l1norm d = ∑ i, (isoUp x y i - y i) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    exact abs_of_nonneg (by simpa [hd] using sub_nonneg.mpr (le_isoUp x y i))
  have hle : repairDist x y ≤ ∑ i, (isoUp x y i - y i) := by
    rw [← hl1]; exact repairDist_le_of_mem hmem
  have hsum : g * ∑ i, (isoUp x y i - y i) ≤ discordanceMass x y := by
    rw [Finset.mul_sum]
    calc ∑ b, g * (isoUp x y b - y b)
        ≤ ∑ b, ∑ a, max (-((x a - x b) * (y a - y b))) 0 :=
          Finset.sum_le_sum fun b _ => gap_isoUp_le_column hg hgap b
      _ = discordanceMass x y := by
          rw [discordanceMass]
          exact Finset.sum_comm
  have := mul_le_mul_of_nonneg_left hle hg.le
  linarith

/-- **Two-sided comparison.**  For a `g`-separated footprint of range at most `R`, the
discordance mass and the comonotone repair distance control each other:
`g · δ ≤ Δ ≤ (2 |ι| R) · δ`.  The left constant is sharp up to a factor `2`; the
population-size factor on the right is unavoidable (`no_dimension_free_upper_bound`). -/
theorem repair_discordance_two_sided {x y : ι → ℝ} {g R : ℝ} (hg : 0 < g)
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) (hx : ∀ i j, |x i - x j| ≤ R) :
    g * repairDist x y ≤ discordanceMass x y ∧
      discordanceMass x y ≤ 2 * (Fintype.card ι : ℝ) * R * repairDist x y :=
  ⟨repairDist_le_discordanceMass hg hgap, discordanceMass_le_repairDist x y hx⟩

/-! ### QS triage from a single population parameter -/

/-- **QS triage rule, repair-distance form.**  The dial is strictly positive in *every*
draw regime whose per-key mass lies in `[ε, M]`, as soon as the single interpretable
population parameter `δ = repairDist x y` satisfies
`(M/ε)² · 2 |ι| · range(x) · δ < concordanceMass x y`.  In particular a population that
is cheap to repair cannot be triaged away by any conditioning number. -/
theorem dial_pos_of_repair_distance {p x y : ι → ℝ} {ε M R : ℝ} (hp : ∑ i, p i = 1)
    (hε : 0 < ε) (hlo : ∀ i, ε ≤ p i) (hhi : ∀ i, p i ≤ M) (hx : ∀ i j, |x i - x j| ≤ R)
    (htriage : M ^ 2 * (2 * (Fintype.card ι : ℝ) * R * repairDist x y)
      < ε ^ 2 * concordanceMass x y) :
    0 < wcov p x y := by
  refine dial_pos_of_concordance_ratio hp hε hlo hhi ?_
  have hΔ := discordanceMass_le_repairDist x y hx
  have hM : (0 : ℝ) ≤ M ^ 2 := sq_nonneg M
  nlinarith [hΔ, hM, htriage]

/-! ### Refutations: the naive dimension-free forms fail -/

section Counterexamples

/-- Footprints of the three-key witness population. -/
def wx : Fin 3 → ℝ := ![0, 1, 2]

/-- Rates of the first three-key witness population (one high outlier at the bottom). -/
def wy : Fin 3 → ℝ := ![1, 0, 0]

/-- Rates of the second three-key witness population (one inversion at the top). -/
def wy' : Fin 3 → ℝ := ![0, 1, 0]

lemma discordanceMass_wx_wy : discordanceMass wx wy = 6 := by
  simp [discordanceMass, Fin.sum_univ_three, wx, wy]
  norm_num

lemma discordanceMass_wx_wy' : discordanceMass wx wy' = 2 := by
  simp [discordanceMass, Fin.sum_univ_three, wx, wy']
  norm_num

lemma repairDist_wx_wy : repairDist wx wy = 1 := by
  refine le_antisymm ?_ ?_
  · have hmem : (![-1, 0, 0] : Fin 3 → ℝ) ∈ RepairSet wx wy := by
      intro i j
      fin_cases i <;> fin_cases j <;> norm_num [wx, wy]
    have := repairDist_le_of_mem hmem
    simpa [l1norm, Fin.sum_univ_three] using this
  · have h := violation_le_repairDist (x := wx) (y := wy) (i := 0) (j := 1)
      (by norm_num [wx])
    simpa [wy] using h

lemma repairDist_wx_wy' : repairDist wx wy' = 1 := by
  refine le_antisymm ?_ ?_
  · have hmem : (![0, -1, 0] : Fin 3 → ℝ) ∈ RepairSet wx wy' := by
      intro i j
      fin_cases i <;> fin_cases j <;> norm_num [wx, wy']
    have := repairDist_le_of_mem hmem
    simpa [l1norm, Fin.sum_univ_three] using this
  · have h := violation_le_repairDist (x := wx) (y := wy') (i := 1) (j := 2)
      (by simp [wx])
    simpa [wy'] using h

/-- Footprints of the two-key witness population. -/
def vx : Fin 2 → ℝ := ![0, 1]

/-- Rates of the two-key witness population, with a large inversion. -/
def vy : Fin 2 → ℝ := ![3, 0]

lemma discordanceMass_vx_vy : discordanceMass vx vy = 6 := by
  simp [discordanceMass, Fin.sum_univ_two, vx, vy]
  norm_num

lemma repairDist_vx_vy : repairDist vx vy = 3 := by
  refine le_antisymm ?_ ?_
  · have hmem : (![-3, 0] : Fin 2 → ℝ) ∈ RepairSet vx vy := by
      intro i j
      fin_cases i <;> fin_cases j <;> norm_num [vx, vy]
    have := repairDist_le_of_mem hmem
    simpa [l1norm, Fin.sum_univ_two] using this
  · have h := violation_le_repairDist (x := vx) (y := vy) (i := 0) (j := 1)
      (by norm_num [vx])
    simpa [vy] using h

lemma vx_gap : ∀ i j : Fin 2, vx i < vx j → (1 : ℝ) ≤ vx j - vx i := by
  intro i j h
  fin_cases i <;> fin_cases j <;> norm_num [vx] <;> norm_num [vx] at h

/-- **The constant `1` in `g · δ ≤ Δ` cannot be raised above `2`.**  For the `1`-separated
population `x = (0,1)`, `y = (3,0)` one has `g · δ = 3` and `Δ = 6`, so every constant
`C > 2` fails.  The dimension-free lower bound is therefore optimal up to a factor `2`. -/
theorem no_lower_bound_constant_above_two {C : ℝ} (hC : 2 < C) :
    ¬ (C * (1 : ℝ) * repairDist vx vy ≤ discordanceMass vx vy) := by
  rw [repairDist_vx_vy, discordanceMass_vx_vy]
  intro h
  linarith

/-- **Refutation of `δ² ≤ Δ`.**  The two sides scale differently in `y` (quadratically
versus linearly), so a large single inversion breaks the bound: for `x = (0,1)`,
`y = (3,0)` one has `δ = 3` but `Δ = 6 < 9`. -/
theorem no_quadratic_lower_bound :
    ¬ ∀ (n : ℕ) (x y : Fin n → ℝ), (repairDist x y) ^ 2 ≤ discordanceMass x y := by
  intro h
  have := h 2 vx vy
  rw [repairDist_vx_vy, discordanceMass_vx_vy] at this
  norm_num at this

/-- **Refutation of the dimension-free upper bound `Δ ≤ 2 δ range(x)`.**  Discordance mass
aggregates over all pairs while an ℓ¹ repair may fix all of them at one key: for
`x = (0,1,2)`, `y = (1,0,0)` one has `δ = 1`, `range(x) = 2`, but `Δ = 6 > 4`.  The factor
`|ι|` in `discordanceMass_le_repairDist` is therefore necessary. -/
theorem no_dimension_free_upper_bound :
    ¬ ∀ (n : ℕ) (x y : Fin n → ℝ) (R : ℝ), (∀ i j, |x i - x j| ≤ R) →
        discordanceMass x y ≤ 2 * repairDist x y * R := by
  intro h
  have hrange : ∀ i j : Fin 3, |wx i - wx j| ≤ 2 := by
    intro i j
    fin_cases i <;> fin_cases j <;> norm_num [wx]
  have := h 3 wx wy 2 hrange
  rw [repairDist_wx_wy, discordanceMass_wx_wy] at this
  norm_num at this

/-- **The discordance mass is not a function of the repair distance.**  Two populations
with the same footprints and the same comonotone repair distance `δ = 1` have discordance
masses `6` and `2`.  Hence the pairwise data is irreducible: no ℓ¹ repair statistic can
replace `Δ` in the triage rule, and the two-sided bounds above cannot be improved to an
identity. -/
theorem discordance_not_determined_by_repairDist :
    repairDist wx wy = repairDist wx wy' ∧ discordanceMass wx wy ≠ discordanceMass wx wy' := by
  refine ⟨by rw [repairDist_wx_wy, repairDist_wx_wy'], ?_⟩
  rw [discordanceMass_wx_wy, discordanceMass_wx_wy']
  norm_num

end Counterexamples

end Catalog.UniformDial