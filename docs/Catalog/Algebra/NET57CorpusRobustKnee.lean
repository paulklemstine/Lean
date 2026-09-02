import Mathlib

/-!
# NET-57: the corpus algebra of the attention knee

This file gives an **algebraic** explanation of the NET-57 measurement
(`THE-KNEES-ARE-CORPUS-ROBUST`): an independent wikitext shard reproduces the
retention knees `k* = 16` at context `512` and `k* = 32` at context `1024`
*exactly*, with the control curves agreeing to four decimals.

The previous catalog treatments of the knee (`Catalog/Shared/AttentionBudgetKnee.lean`,
`Catalog/Combinatorics/KneeInvariance.lean`) work with the *retained-mass curve* and
its decay profile.  Here we change the ambient object: a corpus is a
**nonnegative attention profile** `w : ℕ → ℝ`, profiles form an ordered cone under
pointwise addition and positive scaling, and the gate condition

  `Clears w n k τ  :  τ * headMass w n ≤ headMass w k`

is a **linear** (half-space) condition on `w`.  Everything corpus-theoretic then
follows from linear algebra rather than from analysis of decay rates:

* `budgetCone` — the profiles clearing a fixed budget `K` form an `AddSubmonoid`
  of `ℕ → ℝ`, stable under nonnegative scalars (`budgetCone_smul_mem`): a convex
  cone.  The failing profiles form the *open* complementary half space, which is
  itself closed under addition (`not_clears_add`).  This two-sided linearity is
  the structural reason corpora can be pooled without moving the knee.
* `knee_add_le_max`, `min_le_knee_add` — the knee of a pooled corpus is squeezed
  between the constituent knees, and both bounds are attained
  (`sharp_knee_add_eq_min`, `sharp_knee_add_eq_max`), so the sandwich is sharp.
* `knee_add_eq` — **exact corpus robustness**: two corpora with a common knee
  generate an entire cone of corpora with that same knee.  Together with
  `knee_smul` (scale invariance) this says the knee is a *non-archimedean
  valuation-like* functional on the corpus cone (`knee_nonarchimedean`), and the
  budget cones give a `knee`-indexed filtration of the corpus cone
  (`budgetCone_filtration`).
* `knee_eq_of_uniform_close` — the **four-decimal theorem**: if two corpora agree
  to within `ε` on the whole retention grid and the reference corpus is at least
  `ε` away from the gate at every grid point, the two knees are *equal*, not
  merely close.  This is the exact logical content of "controls replicate to four
  decimals ⇒ the knee replicates exactly", and `net57_bracket_transfer` is its
  measurement-shaped corollary (a razor bracket measured on corpus A transfers
  verbatim to corpus B).
* `knee_mono_context` — knees are monotone in the context length, so the reported
  ladder `k*(512) = 16 ≤ k*(1024) = 32` is forced, and `knee_le_context`.

-- !-- Lab Notes -- !--
Hypothesizer (6 conjectures, ranked by expected impact):
 (H1) The knee is a *non-archimedean valuation* on the corpus cone:
      `k*(A + B) ≤ max (k* A) (k* B)` and `k*(cA) = k* A` for `c > 0`.   [BOLD]
 (H2) Corpus robustness is exact, not approximate: equal knees are preserved by
      pooling, so knee-level sets are subcones, not merely nearby.       [BOLD]
 (H3) A four-decimal agreement of control curves *forces* identical knees
      whenever the gate margin exceeds the agreement tolerance.
 (H4) The sandwich `min ≤ k*(A+B) ≤ max` is sharp: both endpoints occur.
 (H5) Knees are monotone in the context length for every profile, so the
      `{16, 32}` ladder cannot be inverted by any corpus.
 (H6) Mixing weights are irrelevant: any strictly positive convex combination of
      two equal-knee corpora has that knee.                              [BOLD]

Experimenter: H1–H6 are all formalised below, with zero sorries.  The measured
NET-57 grid (Qwen2.5-0.5B, gate 0.98, ctx 512) enters only as *hypotheses* of
`net57_bracket_transfer` / `net57_cross_corpus_512`, never as axioms:
  k         :   8        12       16
  corpus A  : 0.9318   0.9759   (pass)
  corpus B  : agrees with A to 1e-4 on the whole grid.

Analyst: the informative failure is that `k*(A + B) = k*(A)` is **false** when
the knees differ — `sharp_knee_add_eq_max` exhibits a pooled corpus whose knee
is the larger of the two.  So "corpus robustness" cannot be stated as additivity
of the knee; the correct statements are the sandwich plus its equality case on
the diagonal.  This is a "needs a different definition" outcome resolved in
favour of the filtration/valuation picture.

Critic: no theorem here is vacuous.  `sharp_knee_add_eq_min` and
`sharp_knee_add_eq_max` supply explicit witnesses on both sides, so no hypothesis
class is empty; `knee_eq_of_uniform_close` is stated with an explicit tolerance
and margin and would be false without the margin (a corpus sitting exactly on the
gate can be pushed either way by an arbitrarily small perturbation); and
`knee_lt_of_not_clears` shows the gate is a genuine constraint.
-/

namespace Catalog.Algebra.NET57

open Finset

/-! ## Corpora as nonnegative attention profiles -/

/-- Total unnormalised attention mass of the top `k` keys of a sorted profile. -/
noncomputable def headMass (w : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ range k, w i

/-- A profile is a *corpus* when all its sorted attention weights are nonnegative. -/
def IsCorpus (w : ℕ → ℝ) : Prop := ∀ i, 0 ≤ w i

/-- The gate condition in **linear** form: the top-`k` mass clears the fraction `τ`
of the total mass of a context of length `n`.  Written multiplicatively (rather than
as `τ ≤ headMass w k / headMass w n`) precisely so that it is a half space in `w`. -/
def Clears (w : ℕ → ℝ) (n k : ℕ) (τ : ℝ) : Prop := τ * headMass w n ≤ headMass w k

/-- The **knee** `k*`: the least key budget clearing the gate. -/
noncomputable def knee (w : ℕ → ℝ) (n : ℕ) (τ : ℝ) : ℕ := sInf {k | Clears w n k τ}

/-- Retained mass fraction, the quantity actually reported by the sweep. -/
noncomputable def retained (w : ℕ → ℝ) (n k : ℕ) : ℝ := headMass w k / headMass w n

/-! ## Elementary mass calculus -/

lemma headMass_zero (w : ℕ → ℝ) : headMass w 0 = 0 := by simp [headMass]

lemma headMass_succ (w : ℕ → ℝ) (k : ℕ) : headMass w (k + 1) = headMass w k + w k := by
  simp [headMass, Finset.sum_range_succ]

lemma headMass_nonneg {w : ℕ → ℝ} (hw : IsCorpus w) (k : ℕ) : 0 ≤ headMass w k :=
  Finset.sum_nonneg fun i _ => hw i

lemma headMass_mono {w : ℕ → ℝ} (hw : IsCorpus w) : Monotone (headMass w) := by
  intro a b hab
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_subset_range.mpr hab)
    fun i _ _ => hw i

lemma headMass_add (w v : ℕ → ℝ) (k : ℕ) :
    headMass (w + v) k = headMass w k + headMass v k := by
  simp [headMass, Finset.sum_add_distrib]

lemma headMass_smul (c : ℝ) (w : ℕ → ℝ) (k : ℕ) :
    headMass (fun i => c * w i) k = c * headMass w k := by
  simp [headMass, Finset.mul_sum]

/-! ## The knee as a left adjoint -/

section KneeBasic

variable {w : ℕ → ℝ} {n k : ℕ} {τ : ℝ}

/-- Monotonicity of the gate condition in the budget. -/
lemma Clears.mono (hw : IsCorpus w) (h : Clears w n k τ) {l : ℕ} (hkl : k ≤ l) :
    Clears w n l τ :=
  h.trans (headMass_mono hw hkl)

/-- Every corpus clears the gate at the full context length (for a gate `τ ≤ 1`). -/
lemma clears_full (hw : IsCorpus w) (hτ : τ ≤ 1) : Clears w n n τ := by
  simp only [Clears]
  nlinarith [headMass_nonneg hw n]

lemma knee_le_of_clears (h : Clears w n k τ) : knee w n τ ≤ k := Nat.sInf_le h

lemma clears_knee (hw : IsCorpus w) (hτ : τ ≤ 1) : Clears w n (knee w n τ) τ := by
  have h : sInf {k | Clears w n k τ} ∈ {k | Clears w n k τ} :=
    Nat.sInf_mem ⟨n, clears_full hw hτ⟩
  exact h

/-- The knee never exceeds the context length. -/
lemma knee_le_context (hw : IsCorpus w) (hτ : τ ≤ 1) : knee w n τ ≤ n :=
  knee_le_of_clears (clears_full hw hτ)

/-- **Galois connection**: `knee` is left adjoint to the gate predicate. -/
lemma knee_le_iff (hw : IsCorpus w) (hτ : τ ≤ 1) : knee w n τ ≤ k ↔ Clears w n k τ :=
  ⟨fun h => (clears_knee hw hτ).mono hw h, knee_le_of_clears⟩

/-- Below the knee the gate genuinely fails: the constraint is not vacuous. -/
lemma not_clears_of_lt_knee (h : k < knee w n τ) : ¬ Clears w n k τ :=
  fun hc => absurd (knee_le_of_clears hc) (not_le.2 h)

lemma knee_lt_of_not_clears (hw : IsCorpus w) (hτ : τ ≤ 1) (h : ¬ Clears w n k τ) :
    k < knee w n τ := by
  by_contra hcon
  exact h ((knee_le_iff hw hτ).1 (not_lt.1 hcon))

/-- The **razor bracket**: a failure at `a` and a pass at `b` pin the knee to `(a, b]`. -/
theorem knee_bracket (hw : IsCorpus w) (hτ : τ ≤ 1) {a b : ℕ}
    (hfail : ¬ Clears w n a τ) (hpass : Clears w n b τ) :
    a < knee w n τ ∧ knee w n τ ≤ b :=
  ⟨knee_lt_of_not_clears hw hτ hfail, knee_le_of_clears hpass⟩

/-- Pinning the knee exactly. -/
theorem knee_eq_of (hpass : Clears w n k τ) (hfail : ∀ j < k, ¬ Clears w n j τ) :
    knee w n τ = k := by
  refine le_antisymm (knee_le_of_clears hpass) ?_
  by_contra hcon
  push_neg at hcon
  have h : sInf {j | Clears w n j τ} ∈ {j | Clears w n j τ} := Nat.sInf_mem ⟨k, hpass⟩
  exact hfail _ hcon h

/-- Gate condition and retained mass agree whenever the context carries mass. -/
lemma clears_iff_retained (hpos : 0 < headMass w n) :
    Clears w n k τ ↔ τ ≤ retained w n k := by
  rw [Clears, retained, le_div_iff₀ hpos, mul_comm]

end KneeBasic

/-! ## Context monotonicity: the `{16, 32}` ladder cannot be inverted -/

/-- Clearing a gate at a longer context is harder. -/
lemma clears_of_clears_context {w : ℕ → ℝ} {τ : ℝ} (hw : IsCorpus w) (hτ : 0 ≤ τ)
    {n m k : ℕ} (hnm : n ≤ m) (h : Clears w m k τ) : Clears w n k τ :=
  le_trans (by
    have := headMass_mono hw hnm
    nlinarith [headMass_mono hw hnm]) h

/-- **Knees are monotone in the context length.**  No corpus can produce a knee that
decreases as the window grows, so a measured ladder `k*(512) ≤ k*(1024)` is a
structural fact rather than a fitted trend. -/
theorem knee_mono_context {w : ℕ → ℝ} {τ : ℝ} (hw : IsCorpus w) (hτ0 : 0 ≤ τ) (hτ : τ ≤ 1)
    {n m : ℕ} (hnm : n ≤ m) : knee w n τ ≤ knee w m τ :=
  knee_le_of_clears (clears_of_clears_context hw hτ0 hnm (clears_knee hw hτ))

/-! ## The budget cone: linearity of the gate -/

/-- Corpora clearing budget `K` at context `n` and gate `τ` form an additive submonoid
of the space of profiles — a convex cone by `budgetCone_smul_mem`. -/
def budgetCone (n K : ℕ) (τ : ℝ) : AddSubmonoid (ℕ → ℝ) where
  carrier := {w | Clears w n K τ}
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq, Clears, headMass_add] at *
    nlinarith [ha, hb]
  zero_mem' := by simp [Clears, headMass]

@[simp] lemma mem_budgetCone {n K : ℕ} {τ : ℝ} {w : ℕ → ℝ} :
    w ∈ budgetCone n K τ ↔ Clears w n K τ := Iff.rfl

/-- The budget cone is stable under nonnegative rescaling of a corpus. -/
lemma budgetCone_smul_mem {n K : ℕ} {τ : ℝ} {c : ℝ} (hc : 0 ≤ c) {w : ℕ → ℝ}
    (hwc : w ∈ budgetCone n K τ) : (fun i => c * w i) ∈ budgetCone n K τ := by
  simp only [mem_budgetCone, Clears, headMass_smul] at *
  nlinarith [hwc]

/-- Pooling two corpora that clear the same budget clears that budget. -/
lemma clears_add {w v : ℕ → ℝ} {n k : ℕ} {τ : ℝ} (hw : Clears w n k τ)
    (hv : Clears v n k τ) : Clears (w + v) n k τ :=
  (budgetCone n k τ).add_mem hw hv

/-- The *failing* side is a cone too: pooling two corpora that both miss the gate at
`k` still misses it.  This one-line linear fact is what makes the knee — and not just
an upper bound on it — corpus-robust. -/
lemma not_clears_add {w v : ℕ → ℝ} {n k : ℕ} {τ : ℝ} (hw : ¬ Clears w n k τ)
    (hv : ¬ Clears v n k τ) : ¬ Clears (w + v) n k τ := by
  simp only [Clears, not_le, headMass_add] at *
  nlinarith [hw, hv]

lemma clears_smul {w : ℕ → ℝ} {n k : ℕ} {τ c : ℝ} (hc : 0 ≤ c) (h : Clears w n k τ) :
    Clears (fun i => c * w i) n k τ := budgetCone_smul_mem hc h

lemma isCorpus_add {w v : ℕ → ℝ} (hw : IsCorpus w) (hv : IsCorpus v) : IsCorpus (w + v) :=
  fun i => add_nonneg (hw i) (hv i)

lemma isCorpus_smul {w : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c) (hw : IsCorpus w) :
    IsCorpus (fun i => c * w i) := fun i => mul_nonneg hc (hw i)

/-! ## Pooling: the knee sandwich and its equality case -/

variable {w v : ℕ → ℝ} {n : ℕ} {τ : ℝ}

/-- **Sub-max law.**  Pooling corpora never needs more keys than the greedier one. -/
theorem knee_add_le_max (hw : IsCorpus w) (hv : IsCorpus v) (hτ : τ ≤ 1) :
    knee (w + v) n τ ≤ max (knee w n τ) (knee v n τ) := by
  refine knee_le_of_clears (clears_add ?_ ?_)
  · exact (clears_knee hw hτ).mono hw (le_max_left _ _)
  · exact (clears_knee hv hτ).mono hv (le_max_right _ _)

/-- **Super-min law.**  Pooling corpora never needs fewer keys than the leaner one. -/
theorem min_le_knee_add (hw : IsCorpus w) (hv : IsCorpus v) (hτ : τ ≤ 1) :
    min (knee w n τ) (knee v n τ) ≤ knee (w + v) n τ := by
  by_contra hcon
  push_neg at hcon
  have hk := clears_knee (isCorpus_add hw hv) hτ (n := n) (τ := τ)
  exact not_clears_add (not_clears_of_lt_knee (lt_of_lt_of_le hcon (min_le_left _ _)))
    (not_clears_of_lt_knee (lt_of_lt_of_le hcon (min_le_right _ _))) hk

/-- **Exact corpus robustness.**  Two corpora with a common knee generate a whole cone
of corpora with that same knee: the knee is constant on the additive semigroup they
span.  This is the algebraic content of NET-57's "EXACT" verdicts. -/
theorem knee_add_eq (hw : IsCorpus w) (hv : IsCorpus v) (hτ : τ ≤ 1)
    (h : knee w n τ = knee v n τ) : knee (w + v) n τ = knee w n τ := by
  have hle := knee_add_le_max hw hv hτ (n := n)
  have hge := min_le_knee_add hw hv hτ (n := n)
  rw [h] at hle hge ⊢
  simp only [max_self, min_self] at hle hge
  exact le_antisymm hle hge

/-- Scale invariance: a corpus and any positive rescaling of it have the same knee. -/
theorem knee_smul {c : ℝ} (hc : 0 < c) : knee (fun i => c * w i) n τ = knee w n τ := by
  have hset : {k | Clears (fun i => c * w i) n k τ} = {k | Clears w n k τ} := by
    ext k
    simp only [Set.mem_setOf_eq, Clears, headMass_smul]
    constructor
    · intro h; nlinarith [h]
    · intro h; nlinarith [h]
  simp [knee, hset]

/-- **The knee is a non-archimedean valuation on the corpus cone**: scale invariant and
sub-maximal under pooling.  Consequently its sublevel sets `budgetCone` filter the
cone of corpora. -/
theorem knee_nonarchimedean (hw : IsCorpus w) (hv : IsCorpus v) (hτ : τ ≤ 1) {c : ℝ}
    (hc : 0 < c) :
    knee (w + v) n τ ≤ max (knee w n τ) (knee v n τ) ∧
      knee (fun i => c * w i) n τ = knee w n τ :=
  ⟨knee_add_le_max hw hv hτ, knee_smul hc⟩

/-- The budget cones are increasing in the budget along corpora: a `knee`-indexed
filtration of the corpus cone. -/
theorem budgetCone_filtration {K L : ℕ} (hw : IsCorpus w) (hKL : K ≤ L)
    (h : w ∈ budgetCone n K τ) : w ∈ budgetCone n L τ :=
  (mem_budgetCone.1 h).mono hw hKL

/-- Any strictly positive convex combination of two corpora with a common knee has that
knee: mixing weights are irrelevant (H6). -/
theorem knee_convex_mix (hw : IsCorpus w) (hv : IsCorpus v) (hτ : τ ≤ 1)
    (h : knee w n τ = knee v n τ) {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    knee (fun i => a * w i + b * v i) n τ = knee w n τ := by
  have h1 : knee (fun i => a * w i) n τ = knee w n τ := knee_smul ha
  have h2 : knee (fun i => b * v i) n τ = knee v n τ := knee_smul hb
  have hmix : (fun i => a * w i + b * v i) = (fun i => a * w i) + (fun i => b * v i) := rfl
  rw [hmix, knee_add_eq (isCorpus_smul ha.le hw) (isCorpus_smul hb.le hv) hτ (by
    rw [h1, h2, h]), h1]

/-! ## The four-decimal theorem: ε-agreement forces knee equality -/

/-- **Measurement-validity theorem.**  If two corpora's retention curves agree to
within `ε` at every grid point `k ≤ n`, and the reference corpus stays strictly more
than `ε` away from the gate at every such point, then the two knees are *equal*.

This is exactly the inference NET-57 makes: control curves matching to four decimals
(`ε = 10⁻⁴`) with gate margins far larger than `10⁻⁴` force the knees `16` and `32`
to replicate on the nose. -/
theorem knee_eq_of_uniform_close {A B : ℕ → ℝ} {n : ℕ} {τ ε : ℝ}
    (hA : IsCorpus A) (hB : IsCorpus B) (hτ : τ ≤ 1)
    (hApos : 0 < headMass A n) (hBpos : 0 < headMass B n)
    (hclose : ∀ k ≤ n, |retained A n k - retained B n k| ≤ ε)
    (hmargin : ∀ k ≤ n, ε < |retained A n k - τ|) :
    knee A n τ = knee B n τ := by
  -- On the grid `k ≤ n` the two gate predicates are literally equivalent.
  have key : ∀ k ≤ n, (Clears A n k τ ↔ Clears B n k τ) := by
    intro k hk
    rw [clears_iff_retained hApos, clears_iff_retained hBpos]
    have hc := hclose k hk
    have hm := hmargin k hk
    rw [abs_le] at hc
    rcases abs_cases (retained A n k - τ) with ⟨he, hs⟩ | ⟨he, hs⟩ <;> rw [he] at hm <;>
      constructor <;> intro h <;> linarith [hc.1, hc.2]
  have hkA : knee A n τ ≤ n := knee_le_context hA hτ
  have hkB : knee B n τ ≤ n := knee_le_context hB hτ
  refine le_antisymm ?_ ?_
  · exact knee_le_of_clears ((key _ hkB).2 (clears_knee hB hτ))
  · exact knee_le_of_clears ((key _ hkA).1 (clears_knee hA hτ))

/-- **Bracket transfer.**  A razor bracket measured on corpus A transfers verbatim to
corpus B under the same ε-agreement / margin hypotheses.  With the NET-57 grid this
reads: `12 < k*_B ≤ 16` at ctx 512, i.e. corpus B reproduces `k* = 16` on the grid. -/
theorem net57_bracket_transfer {A B : ℕ → ℝ} {n : ℕ} {τ ε : ℝ} {a b : ℕ}
    (hA : IsCorpus A) (hB : IsCorpus B) (hτ : τ ≤ 1)
    (hApos : 0 < headMass A n) (hBpos : 0 < headMass B n)
    (hclose : ∀ k ≤ n, |retained A n k - retained B n k| ≤ ε)
    (hmargin : ∀ k ≤ n, ε < |retained A n k - τ|)
    (hfail : ¬ Clears A n a τ) (hpass : Clears A n b τ) :
    a < knee B n τ ∧ knee B n τ ≤ b := by
  have h := knee_eq_of_uniform_close hA hB hτ hApos hBpos hclose hmargin
  rw [← h]
  exact knee_bracket hA hτ hfail hpass

/-- The measurement-shaped instance at context `512`, gate `0.98`, grid failure at
`k = 12` and pass at `k = 16`, with four-decimal control agreement: corpus B has the
same knee as corpus A, and that knee lies in `(12, 16]`. -/
theorem net57_cross_corpus_512 {A B : ℕ → ℝ}
    (hA : IsCorpus A) (hB : IsCorpus B)
    (hApos : 0 < headMass A 512) (hBpos : 0 < headMass B 512)
    (hclose : ∀ k ≤ 512, |retained A 512 k - retained B 512 k| ≤ (1 : ℝ) / 10000)
    (hmargin : ∀ k ≤ 512, (1 : ℝ) / 10000 < |retained A 512 k - 0.98|)
    (hfail : ¬ Clears A 512 12 0.98) (hpass : Clears A 512 16 0.98) :
    knee B 512 0.98 = knee A 512 0.98 ∧ 12 < knee B 512 0.98 ∧ knee B 512 0.98 ≤ 16 := by
  have heq := knee_eq_of_uniform_close hA hB (by norm_num) hApos hBpos hclose hmargin
  exact ⟨heq.symm, net57_bracket_transfer hA hB (by norm_num) hApos hBpos hclose hmargin
    hfail hpass⟩

/-! ## Sharpness of the sandwich

Both endpoints of `min ≤ knee (w + v) ≤ max` are attained, so neither bound can be
improved and `knee` is *not* additive.  The witnesses are two one-hot corpora on a
context of length `2`; only the gate changes between the two examples. -/

/-- First one-hot corpus: all mass on key `0`. -/
def eOne : ℕ → ℝ := fun i => if i = 0 then 1 else 0

/-- Second one-hot corpus: all mass on key `1`. -/
def eTwo : ℕ → ℝ := fun i => if i = 1 then 1 else 0

lemma isCorpus_eOne : IsCorpus eOne := by
  intro i; unfold eOne; split <;> norm_num

lemma isCorpus_eTwo : IsCorpus eTwo := by
  intro i; unfold eTwo; split <;> norm_num

lemma headMass_eOne_zero : headMass eOne 0 = 0 := by simp [headMass]
lemma headMass_eOne_one : headMass eOne 1 = 1 := by simp [headMass, eOne]
lemma headMass_eOne_two : headMass eOne 2 = 1 := by
  simp [headMass, eOne]
lemma headMass_eTwo_zero : headMass eTwo 0 = 0 := by simp [headMass]
lemma headMass_eTwo_one : headMass eTwo 1 = 0 := by simp [headMass, eTwo]
lemma headMass_eTwo_two : headMass eTwo 2 = 1 := by
  simp [headMass, eTwo]

lemma knee_eOne {τ : ℝ} (hτ0 : 0 < τ) (hτ : τ ≤ 1) : knee eOne 2 τ = 1 := by
  refine knee_eq_of ?_ ?_
  · simp only [Clears, headMass_eOne_one, headMass_eOne_two]; linarith
  · intro j hj
    interval_cases j
    simp only [Clears, headMass_eOne_zero, headMass_eOne_two, not_le]
    linarith

lemma knee_eTwo {τ : ℝ} (hτ0 : 0 < τ) (hτ : τ ≤ 1) : knee eTwo 2 τ = 2 := by
  refine knee_eq_of ?_ ?_
  · simp only [Clears, headMass_eTwo_two]; linarith
  · intro j hj
    interval_cases j
    · simp only [Clears, headMass_eTwo_two, headMass_eTwo_zero, not_le]
      linarith
    · simp only [Clears, headMass_eTwo_one, headMass_eTwo_two, not_le]
      linarith

/-- The **min** endpoint is attained: with gate `1/2` the pooled corpus keeps the
smaller knee `1 = min 1 2`. -/
theorem sharp_knee_add_eq_min :
    knee (eOne + eTwo) 2 (1/2) = min (knee eOne 2 (1/2)) (knee eTwo 2 (1/2)) := by
  have h1 : knee eOne 2 (1/2 : ℝ) = 1 := knee_eOne (by norm_num) (by norm_num)
  have h2 : knee eTwo 2 (1/2 : ℝ) = 2 := knee_eTwo (by norm_num) (by norm_num)
  have hsum : knee (eOne + eTwo) 2 (1/2 : ℝ) = 1 := by
    refine knee_eq_of ?_ ?_
    · simp only [Clears, headMass_add, headMass_eOne_one, headMass_eTwo_one,
        headMass_eOne_two, headMass_eTwo_two]
      norm_num
    · intro j hj
      interval_cases j
      simp only [Clears, headMass_add, headMass_eOne_two, headMass_eTwo_two,
        headMass_eOne_zero, headMass_eTwo_zero, not_le]
      norm_num
  rw [h1, h2, hsum]
  norm_num

/-- The **max** endpoint is attained: with gate `3/4` the same pooled corpus is pushed
to the larger knee `2 = max 1 2`.  Hence the knee is not additive, and equality in
`knee_add_eq` really does need the diagonal hypothesis. -/
theorem sharp_knee_add_eq_max :
    knee (eOne + eTwo) 2 (3/4) = max (knee eOne 2 (3/4)) (knee eTwo 2 (3/4)) := by
  have h1 : knee eOne 2 (3/4 : ℝ) = 1 := knee_eOne (by norm_num) (by norm_num)
  have h2 : knee eTwo 2 (3/4 : ℝ) = 2 := knee_eTwo (by norm_num) (by norm_num)
  have hsum : knee (eOne + eTwo) 2 (3/4 : ℝ) = 2 := by
    refine knee_eq_of ?_ ?_
    · simp only [Clears, headMass_add, headMass_eOne_two, headMass_eTwo_two]
      norm_num
    · intro j hj
      interval_cases j
      · simp only [Clears, headMass_add, headMass_eOne_two, headMass_eTwo_two,
          headMass_eOne_zero, headMass_eTwo_zero, not_le]
        norm_num
      · simp only [Clears, headMass_add, headMass_eOne_one, headMass_eTwo_one,
          headMass_eOne_two, headMass_eTwo_two, not_le]
        norm_num
  rw [h1, h2, hsum]
  norm_num

/-- Corollary of sharpness: the pooled knee is *not* a function of the individual
knees alone — the same pair of corpora yields `min` at one gate and `max` at another. -/
theorem knee_add_not_determined_by_summand_knees :
    ∃ (w v : ℕ → ℝ) (n : ℕ) (τ σ : ℝ), IsCorpus w ∧ IsCorpus v ∧
      knee w n τ = knee w n σ ∧ knee v n τ = knee v n σ ∧
      knee (w + v) n τ ≠ knee (w + v) n σ := by
  refine ⟨eOne, eTwo, 2, 1/2, 3/4, isCorpus_eOne, isCorpus_eTwo, ?_, ?_, ?_⟩
  · rw [knee_eOne (by norm_num) (by norm_num), knee_eOne (by norm_num) (by norm_num)]
  · rw [knee_eTwo (by norm_num) (by norm_num), knee_eTwo (by norm_num) (by norm_num)]
  · have ha := sharp_knee_add_eq_min
    have hb := sharp_knee_add_eq_max
    rw [knee_eOne (by norm_num) (by norm_num), knee_eTwo (by norm_num) (by norm_num)] at ha
    rw [knee_eOne (by norm_num) (by norm_num), knee_eTwo (by norm_num) (by norm_num)] at hb
    simp only [min_def, max_def] at ha hb
    norm_num at ha hb
    omega

end Catalog.Algebra.NET57