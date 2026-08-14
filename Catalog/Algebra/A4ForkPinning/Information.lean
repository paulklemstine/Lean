/-
# Fork information: the pinned / flat / leaking trichotomy

Formal core of the *A4-FORK-PINNING* experiment (paper 75, experiment 410).

A **fork** attached to a number field is a binary observable `F` of the Frobenius
class of a prime `p`; a **dial** is a residue datum `y = p mod m`.  The
experiment measures the mutual information `I(y ; F)` and observes exactly three
regimes:

* **pinned**   — `F` is a function of `y`, and `I = H(F)` is maximal;
* **flat**     — `F` is independent of `y`, and `I = 0`;
* **leaking**  — `F` is a *thinning* of a pinned event, and `0 < I < H(F)`,
  with the exact closed form `I = H(pq) - p·H(q)`.

This file builds the (bit-valued) information calculus needed to state and prove
those three laws for an arbitrary finite dial:

* `A4ForkPinning.info_of_pinned`   — pinned forks realise `I = H(F)`;
* `A4ForkPinning.info_of_flat`     — flat forks realise `I = 0`;
* `A4ForkPinning.info_leak`        — the **exact leakage law** `I = H(pq) - p·H(q)`;
* `A4ForkPinning.info_leak_strict` — leakage is strictly between the two regimes;
* `A4ForkPinning.info_trichotomy`  — `0 ≤ I ≤ H(F)`, with `I = 0` iff the fork is
  flat and `I = H(F)` iff the fork is pinned (strict Jensen in both directions).

All entropies are measured in **bits** (`negMulLog` divided by `log 2`).
-/
import Mathlib

namespace A4ForkPinning

open Real Finset Set

/-! ## Bit-valued entropy -/

/-- `nml x = -x log₂ x`, the entropy contribution of a single outcome, in bits. -/
noncomputable def nml (x : ℝ) : ℝ := Real.negMulLog x / Real.log 2

/-- Binary entropy in bits, `H(x) = -x log₂ x - (1-x) log₂ (1-x)`. -/
noncomputable def hb (x : ℝ) : ℝ := nml x + nml (1 - x)

/-- Shannon entropy (in bits) of a finitely supported distribution. -/
noncomputable def entropy {ι : Type*} [Fintype ι] (p : ι → ℝ) : ℝ := ∑ i, nml (p i)

lemma log_two_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)

@[simp] lemma nml_zero : nml 0 = 0 := by simp [nml]

@[simp] lemma nml_one : nml 1 = 0 := by simp [nml]

lemma nml_nonneg {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) : 0 ≤ nml x :=
  div_nonneg (Real.negMulLog_nonneg h0 h1) log_two_pos.le

lemma nml_pos {x : ℝ} (h0 : 0 < x) (h1 : x < 1) : 0 < nml x := by
  have h : 0 < Real.negMulLog x := by
    rw [Real.negMulLog]
    have := Real.log_neg h0 h1
    nlinarith
  exact div_pos h log_two_pos

@[simp] lemma hb_zero : hb 0 = 0 := by simp [hb]

@[simp] lemma hb_one : hb 1 = 0 := by simp [hb]

lemma hb_symm (x : ℝ) : hb (1 - x) = hb x := by simp [hb, add_comm]

/-- One fair bit carries exactly one bit of entropy. -/
@[simp] lemma hb_half : hb (1 / 2) = 1 := by
  have h2 : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  have h : (1 : ℝ) - 1 / 2 = 1 / 2 := by norm_num
  rw [hb, h, nml, Real.negMulLog, show ((1 : ℝ) / 2) = (2 : ℝ)⁻¹ by norm_num, Real.log_inv]
  field_simp
  ring

lemma hb_nonneg {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) : 0 ≤ hb x :=
  add_nonneg (nml_nonneg h0 h1) (nml_nonneg (by linarith) (by linarith))

lemma hb_pos {x : ℝ} (h0 : 0 < x) (h1 : x < 1) : 0 < hb x :=
  add_pos_of_pos_of_nonneg (nml_pos h0 h1) (nml_nonneg (by linarith) (by linarith))

/-- On `[0,1]` the binary entropy vanishes exactly at the two deterministic points. -/
lemma hb_eq_zero_iff {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) : hb x = 0 ↔ x = 0 ∨ x = 1 := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    exact absurd h (ne_of_gt (hb_pos (lt_of_le_of_ne h0 (Ne.symm hc.1))
      (lt_of_le_of_ne h1 hc.2)))
  · rintro (rfl | rfl) <;> simp

/-! ## Concavity -/

lemma strictConcaveOn_nml : StrictConcaveOn ℝ (Set.Ici (0 : ℝ)) nml := by
  refine ⟨convex_Ici _, ?_⟩
  intro x hx y hy hxy a b ha hb' hab
  have h := Real.strictConcaveOn_negMulLog.2 hx hy hxy ha hb' hab
  simp only [nml, smul_eq_mul] at *
  rw [show a * (Real.negMulLog x / Real.log 2) + b * (Real.negMulLog y / Real.log 2)
      = (a * Real.negMulLog x + b * Real.negMulLog y) / Real.log 2 by ring]
  exact (div_lt_div_iff_of_pos_right log_two_pos).2 h

lemma strictConcaveOn_hb : StrictConcaveOn ℝ (Set.Icc (0 : ℝ) 1) hb := by
  refine ⟨convex_Icc _ _, ?_⟩
  intro x hx y hy hxy a b ha hb' hab
  have h1 := strictConcaveOn_nml.2 (Set.mem_Ici.2 hx.1) (Set.mem_Ici.2 hy.1) hxy ha hb' hab
  have h2 := strictConcaveOn_nml.2 (x := 1 - x) (y := 1 - y)
      (Set.mem_Ici.2 (by linarith [hx.2])) (Set.mem_Ici.2 (by linarith [hy.2]))
      (by intro h; apply hxy; linarith) ha hb' hab
  simp only [smul_eq_mul] at *
  rw [show a * (1 - x) + b * (1 - y) = 1 - (a * x + b * y) by nlinarith [hab]] at h2
  simp only [hb]
  linarith

/-- **Strict entropy gain of a thinning.**  For `0 < p < 1` and `0 < q ≤ 1`,
`p·H(q) < H(pq)`: diluting a `q`-biased coin by an independent `p`-coin strictly
increases the entropy.  This is the engine of the leakage law. -/
lemma hb_thinning_lt {p q : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (hq0 : 0 < q) (hq1 : q ≤ 1) :
    p * hb q < hb (p * q) := by
  have h := strictConcaveOn_hb.2
    (show (0 : ℝ) ∈ Set.Icc (0 : ℝ) 1 by constructor <;> norm_num)
    (show q ∈ Set.Icc (0 : ℝ) 1 from ⟨hq0.le, hq1⟩) (ne_of_lt hq0)
    (show (0 : ℝ) < 1 - p by linarith) hp0 (by ring)
  simp only [smul_eq_mul, hb_zero, mul_zero, zero_add] at h
  linarith

/-! ## The dial → fork channel -/

variable {Y : Type*} [Fintype Y]

/-- The unconditional rate `P(F = 1) = ∑_y w y · f y` of a fork with conditional
rates `f` on a dial with weights `w`. -/
noncomputable def avg (w f : Y → ℝ) : ℝ := ∑ y, w y * f y

/-- Conditional entropy `H(F | dial)` in bits. -/
noncomputable def condEntropy (w f : Y → ℝ) : ℝ := ∑ y, w y * hb (f y)

/-- Mutual information `I(dial ; F) = H(F) - H(F | dial)` in bits. -/
noncomputable def info (w f : Y → ℝ) : ℝ := hb (avg w f) - condEntropy w f

/-- Mutual information between a dial and an arbitrary finite-valued observable
given by conditional distributions `P y`. -/
noncomputable def infoGen {Z : Type*} [Fintype Z] (w : Y → ℝ) (P : Y → Z → ℝ) : ℝ :=
  entropy (fun z => ∑ y, w y * P y z) - ∑ y, w y * entropy (P y)

/-- A binary observable, read through `infoGen`, computes the binary `info`:
the two notions of mutual information agree. -/
lemma infoGen_binary (w f : Y → ℝ) (hw : ∑ y, w y = 1) :
    infoGen w (fun y => ![f y, 1 - f y]) = info w f := by
  have hcompl : ∑ y, w y * (1 - f y) = 1 - ∑ y, w y * f y := by
    simp only [mul_sub, mul_one]
    rw [Finset.sum_sub_distrib, hw]
  simp only [infoGen, info, entropy, condEntropy, avg, Fin.sum_univ_two,
    Matrix.cons_val_zero, Matrix.cons_val_one, hb, hcompl]
  -- `simp only` above already closes the goal

/-! ### Pinned forks -/

/-- **Pinned fork law.**  If the fork is a deterministic function of the dial then
the mutual information saturates: `I = H(F)`. -/
theorem info_of_pinned (w f : Y → ℝ) (hf : ∀ y, f y = 0 ∨ f y = 1) :
    info w f = hb (avg w f) := by
  have h : condEntropy w f = 0 := by
    refine Finset.sum_eq_zero fun y _ => ?_
    rcases hf y with h | h <;> simp [h]
  simp [info, h]

/-! ### Flat forks -/

/-- **Flat fork law.**  A fork whose conditional rate does not depend on the dial
carries zero information about the dial. -/
theorem info_of_flat (w f : Y → ℝ) (c : ℝ) (hw : ∑ y, w y = 1) (hf : ∀ y, f y = c) :
    info w f = 0 := by
  have h1 : avg w f = c := by
    simp only [avg, hf]
    rw [← Finset.sum_mul, hw, one_mul]
  have h2 : condEntropy w f = hb c := by
    simp only [condEntropy, hf]
    rw [← Finset.sum_mul, hw, one_mul]
  simp [info, h1, h2]

/-! ### Leaking forks -/

/-- **Exact leakage law.**  Let `g` be a pinned fork of rate `p` and let `F` be the
`q`-thinning of `g` (i.e. `P(F = 1 | dial = y) = q · g y`).  Then

`I(dial ; F) = H(pq) - p · H(q)`.

For `q = 1` this degenerates to the pinned law `I = H(p)`; for `p = 1` to flatness. -/
theorem info_leak (w g : Y → ℝ) (q : ℝ) (hg : ∀ y, g y = 0 ∨ g y = 1) :
    info w (fun y => q * g y) = hb (q * avg w g) - avg w g * hb q := by
  have hav : avg w (fun y => q * g y) = q * avg w g := by
    simp only [avg, Finset.mul_sum]
    exact Finset.sum_congr rfl fun y _ => by ring
  have hcond : condEntropy w (fun y => q * g y) = avg w g * hb q := by
    simp only [condEntropy, avg, Finset.sum_mul]
    refine Finset.sum_congr rfl fun y _ => ?_
    rcases hg y with h | h <;> simp [h]
  simp [info, hav, hcond]

/-- The leaking regime is strictly between the flat and the pinned regime:
`0 < I < H(F)` whenever `0 < p < 1` and `0 < q < 1`. -/
theorem info_leak_strict (w g : Y → ℝ) (q : ℝ) (hg : ∀ y, g y = 0 ∨ g y = 1)
    (hq0 : 0 < q) (hq1 : q < 1) (hp0 : 0 < avg w g) (hp1 : avg w g < 1) :
    0 < info w (fun y => q * g y) ∧
      info w (fun y => q * g y) < hb (avg w (fun y => q * g y)) := by
  have hav : avg w (fun y => q * g y) = q * avg w g := by
    simp only [avg, Finset.mul_sum]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [info_leak w g q hg, hav]
  refine ⟨?_, ?_⟩
  · have := hb_thinning_lt hp0 hp1 hq0 hq1.le
    rw [mul_comm q (avg w g)]
    linarith
  · have : 0 < avg w g * hb q := mul_pos hp0 (hb_pos hq0 hq1)
    linarith

/-! ### The trichotomy -/

/-- Mutual information is bounded above by the entropy of the fork. -/
theorem info_le (w f : Y → ℝ) (hw : ∀ y, 0 ≤ w y) (hf0 : ∀ y, 0 ≤ f y) (hf1 : ∀ y, f y ≤ 1) :
    info w f ≤ hb (avg w f) := by
  have h : 0 ≤ condEntropy w f :=
    Finset.sum_nonneg fun y _ => mul_nonneg (hw y) (hb_nonneg (hf0 y) (hf1 y))
  simp only [info]
  linarith

/-- Saturation `I = H(F)` characterises the pinned forks. -/
theorem info_eq_top_iff (w f : Y → ℝ) (hw : ∀ y, 0 < w y) (hf0 : ∀ y, 0 ≤ f y)
    (hf1 : ∀ y, f y ≤ 1) : info w f = hb (avg w f) ↔ ∀ y, f y = 0 ∨ f y = 1 := by
  constructor
  · intro h y
    have hzero : condEntropy w f = 0 := by simp only [info] at h; linarith
    have hy := (Finset.sum_eq_zero_iff_of_nonneg
      (fun y _ => mul_nonneg (hw y).le (hb_nonneg (hf0 y) (hf1 y)))).1 hzero y (Finset.mem_univ y)
    have hb0 : hb (f y) = 0 := by
      rcases mul_eq_zero.1 hy with h' | h'
      · exact absurd h' (ne_of_gt (hw y))
      · exact h'
    exact (hb_eq_zero_iff (hf0 y) (hf1 y)).1 hb0
  · exact fun h => info_of_pinned w f h

/-- **Fork trichotomy.**  For a strictly positive dial distribution:
`I ≥ 0`, with `I = 0` exactly for flat forks, and `I ≤ H(F)`, with equality exactly
for pinned forks.  Everything else leaks: `0 < I < H(F)`. -/
theorem info_trichotomy (w f : Y → ℝ) [Nonempty Y] (hw : ∀ y, 0 < w y) (hsum : ∑ y, w y = 1)
    (hf0 : ∀ y, 0 ≤ f y) (hf1 : ∀ y, f y ≤ 1) :
    0 ≤ info w f ∧ info w f ≤ hb (avg w f) ∧
      (info w f = 0 ↔ ∀ y y', f y = f y') ∧
      (info w f = hb (avg w f) ↔ ∀ y, f y = 0 ∨ f y = 1) := by
  have hmem : ∀ y ∈ (Finset.univ : Finset Y), f y ∈ Set.Icc (0 : ℝ) 1 :=
    fun y _ => ⟨hf0 y, hf1 y⟩
  have hJ : condEntropy w f ≤ hb (avg w f) := by
    have h := strictConcaveOn_hb.concaveOn.le_map_sum (t := (Finset.univ : Finset Y))
      (w := w) (p := f) (fun y _ => (hw y).le) hsum hmem
    simpa only [smul_eq_mul, condEntropy, avg] using h
  refine ⟨by simp only [info]; linarith, info_le w f (fun y => (hw y).le) hf0 hf1, ?_,
    info_eq_top_iff w f hw hf0 hf1⟩
  constructor
  · intro h
    have heq : hb (∑ y, w y • f y) = ∑ y, w y • hb (f y) := by
      simp only [smul_eq_mul]
      simp only [info, condEntropy, avg] at h
      linarith
    have hall := (strictConcaveOn_hb.map_sum_eq_iff (t := (Finset.univ : Finset Y))
      (fun y _ => hw y) hsum hmem).1 heq
    intro y y'
    rw [hall y (Finset.mem_univ y), hall y' (Finset.mem_univ y')]
  · intro h
    obtain ⟨y₀⟩ := ‹Nonempty Y›
    exact info_of_flat w f (f y₀) hsum (fun y => h y y₀)

end A4ForkPinning