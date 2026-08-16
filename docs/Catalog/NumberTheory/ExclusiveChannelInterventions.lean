/-
# NET-30 / Catalog·NumberTheory — Exclusive boundary channels: interventions, the
k = 1 collapse, and the affine no-go

Formal counterpart of the *intervention algebra* underlying the round-net-30 law
**INTERNALIZATION-SATURATES-AT-K=2**.

In the experiment a trained recurrent cell owns `k` *exclusive* coordinates
(the coordinates of the hidden state that only the end-of-sequence/boundary
pathway writes into).  At inference time one manipulates the stored coefficient
vector `c ∈ ℝ^k` on those coordinates and re-evaluates:

| intervention | action on `c`                       |
|--------------|--------------------------------------|
| `ctl`        | `c`                                  |
| `zeroAll`    | `0` (whole exclusive block frozen)   |
| `zeroAt i`   | `c` with the `i`-th entry set to `0` |
| `flipAt i`   | `c` with the `i`-th entry negated    |
| `scaleAll l` | `l • c`                              |

The measured s = 13, k = 2 arm has the signature

```
ctl 0.9980 | zeroAt 0 : 0.9961 | zeroAt 1 : 0.9990 | zeroAll : 0.7544
           | flipAt 0 : 0.7505 | scaleAll 0.1 : 0.9067
```

i.e. **every single-coordinate ablation is a no-op while the whole-block
ablation costs 0.24**, and the sign flip costs just as much.  This file proves
what that signature can and cannot mean.

* `zeroAt_eq_zeroAll_of_one`, `two_le_of_redundant_and_block_dependent`:
  a *model-free* theorem.  For `k = 1` the interventions `zeroAt 0` and
  `zeroAll` are literally the same map, so **no statistic whatsoever** can
  separate them; for `k = 0` `zeroAll` is the identity.  Hence the
  "1-redundant but block-dependent" signature *forces* `k ≥ 2`.  This is the
  formal content of "the missing middle": the phenomenon is invisible at
  `k = 1` for structural, not empirical, reasons.
* `dropZeroAll_eq_sum_dropZeroAt`, `dropFlipAt_eq_two_mul_dropZeroAt`,
  `dropScaleAll_eq`: in an **affine** read-out the whole intervention algebra
  collapses to one number per coordinate: whole-block drop = sum of the
  single-coordinate drops, flip drop = twice the zero drop, scale-`l` drop =
  `(1 - l)` times the block drop.
* `abs_dropZeroAll_le`, `card_lower_bound_of_block_drop`: the resulting
  quantitative bound — with single-coordinate no-op tolerance `ε` an affine
  read-out can lose at most `k · ε` from the whole block, so an observed block
  drop `D` certifies `k ≥ D / ε` exclusive dimensions.
* `s13_k2_no_affine_readout`, `s13_k2_flip_no_affine_readout`: applied to the
  published s = 13 numbers this is a **no-go**: no affine boundary read-out
  reproduces the measured k = 2 arm (it would need ≥ 128 exclusive dimensions).
  The saturation law is therefore a statement about a *nonlinear* read-out;
  a matching nonlinear realisation is built in
  `NumberTheory.ExclusiveChannelPopulation`, and the exact convexity boundary
  is located in `NumberTheory.ExclusiveChannelConvexity`.
* `zeroAll_margin_ge_of_redundant`: the positive half — if the block's net
  affine contribution is nonpositive ("removal helps", the measured s = 10
  arm), single-coordinate redundancy *does* upgrade to whole-block
  self-sufficiency.
-/

import Mathlib

namespace NumberTheory.ExclusiveChannel

open Finset

variable {k : ℕ}

/-! ## The intervention maps -/

/-- `zeroAt i` freezes the `i`-th exclusive coordinate to `0`. -/
def zeroAt (i : Fin k) (c : Fin k → ℝ) : Fin k → ℝ := Function.update c i 0

/-- `zeroAll` freezes the whole exclusive block. -/
def zeroAll (_c : Fin k → ℝ) : Fin k → ℝ := fun _ => 0

/-- `flipAt i` negates the `i`-th exclusive coordinate. -/
def flipAt (i : Fin k) (c : Fin k → ℝ) : Fin k → ℝ := Function.update c i (-c i)

/-- `scaleAll l` rescales the whole exclusive block by `l`. -/
def scaleAll (l : ℝ) (c : Fin k → ℝ) : Fin k → ℝ := fun i => l * c i

@[simp] lemma zeroAll_apply (c : Fin k → ℝ) (i : Fin k) : zeroAll c i = 0 := rfl

@[simp] lemma zeroAt_self (i : Fin k) (c : Fin k → ℝ) : zeroAt i c i = 0 := by
  simp [zeroAt]

lemma zeroAt_of_ne {i j : Fin k} (c : Fin k → ℝ) (h : j ≠ i) : zeroAt i c j = c j := by
  simp [zeroAt, h]

@[simp] lemma scaleAll_one (c : Fin k → ℝ) : scaleAll 1 c = c := by
  funext i; simp [scaleAll]

@[simp] lemma scaleAll_zero (c : Fin k → ℝ) : scaleAll 0 c = zeroAll c := by
  funext i; simp [scaleAll, zeroAll]

/-! ## The k = 1 collapse (model-free) -/

/-- **The k = 1 collapse.**  With a single exclusive coordinate the
single-coordinate ablation *is* the whole-block ablation, as maps. -/
theorem zeroAt_eq_zeroAll_of_one (c : Fin 1 → ℝ) (i : Fin 1) : zeroAt i c = zeroAll c := by
  funext j
  have hj : j = i := Subsingleton.elim _ _
  subst hj
  simp [zeroAt, zeroAll]

/-- With no exclusive coordinates at all, the block ablation is the identity. -/
theorem zeroAll_eq_self_of_zero (c : Fin 0 → ℝ) : zeroAll c = c := by
  funext i; exact i.elim0

/-- **The missing middle, model-free form.**  If some statistic `F` (accuracy at
a fixed evaluation draw, say — no structure on `F` is assumed) is *unchanged* by
every single-coordinate ablation yet *changed* by the whole-block ablation, then
the exclusive block has at least two coordinates.

This is exactly the s = 13 signature, and the reason it cannot be observed in
the `k = 1` (E = 21) arms of Part B: there, `zeroAt 0 = zeroAll`. -/
theorem two_le_of_redundant_and_block_dependent {α : Type*} (F : (Fin k → ℝ) → α)
    (c : Fin k → ℝ) (hred : ∀ i, F (zeroAt i c) = F c) (hdep : F (zeroAll c) ≠ F c) :
    2 ≤ k := by
  match k with
  | 0 => exact absurd (congrArg F (zeroAll_eq_self_of_zero c)) hdep
  | 1 =>
      exact absurd (((zeroAt_eq_zeroAll_of_one c 0) ▸ hred 0 : F (zeroAll c) = F c)) hdep
  | (_ + 2) => omega

/-- Contrapositive packaging: at `k ≤ 1` single-coordinate redundancy already
implies whole-block self-sufficiency, for *any* statistic.  (The `k = 1`
seed-heterogeneity of Part B is therefore not a statement about redundancy: at
`k = 1` there is nothing to be redundant with.) -/
theorem block_self_sufficient_of_redundant_of_le_one {α : Type*} (hk : k ≤ 1)
    (F : (Fin k → ℝ) → α) (c : Fin k → ℝ) (hred : ∀ i, F (zeroAt i c) = F c) :
    F (zeroAll c) = F c := by
  by_contra hdep
  have := two_le_of_redundant_and_block_dependent F c hred hdep
  omega

/-! ## The affine read-out -/

/-- The affine boundary margin: baseline `b` plus the exclusive block's
contribution `∑ i, g i * c i`, where `g` collects the read-out weights of the
exclusive coordinates. -/
def margin (b : ℝ) (g c : Fin k → ℝ) : ℝ := b + ∑ i, g i * c i

@[simp] lemma margin_zeroAll (b : ℝ) (g c : Fin k → ℝ) :
    margin b g (zeroAll c) = b := by
  simp [margin]

lemma margin_zeroAt (b : ℝ) (g c : Fin k → ℝ) (i : Fin k) :
    margin b g (zeroAt i c) = margin b g c - g i * c i := by
  have hfun : (fun j => g j * zeroAt i c j)
      = fun j => (g j * c j) - (if j = i then g i * c i else 0) := by
    funext j
    by_cases hj : j = i
    · subst hj; simp
    · simp [zeroAt_of_ne c hj, hj]
  simp only [margin, hfun]
  rw [Finset.sum_sub_distrib, Finset.sum_ite_eq' univ i (fun _ => g i * c i)]
  simp
  ring

lemma margin_flipAt (b : ℝ) (g c : Fin k → ℝ) (i : Fin k) :
    margin b g (flipAt i c) = margin b g c - 2 * (g i * c i) := by
  have hfun : (fun j => g j * flipAt i c j)
      = fun j => (g j * c j) - (if j = i then 2 * (g i * c i) else 0) := by
    funext j
    by_cases hj : j = i
    · subst hj; simp [flipAt]; ring
    · simp [flipAt, hj]
  simp only [margin, hfun]
  rw [Finset.sum_sub_distrib, Finset.sum_ite_eq' univ i (fun _ => 2 * (g i * c i))]
  simp
  ring

lemma margin_scaleAll (b l : ℝ) (g c : Fin k → ℝ) :
    margin b g (scaleAll l c) = b + l * ∑ i, g i * c i := by
  simp only [margin, scaleAll, Finset.mul_sum]
  exact congrArg (b + ·) (Finset.sum_congr rfl fun i _ => by ring)

/-! ## Intervention drops in the affine model -/

/-- Accuracy/margin loss caused by freezing the whole exclusive block. -/
def dropZeroAll (b : ℝ) (g c : Fin k → ℝ) : ℝ := margin b g c - margin b g (zeroAll c)

/-- Margin loss caused by freezing the single coordinate `i`. -/
def dropZeroAt (b : ℝ) (g c : Fin k → ℝ) (i : Fin k) : ℝ :=
  margin b g c - margin b g (zeroAt i c)

/-- Margin loss caused by flipping the sign of the single coordinate `i`. -/
def dropFlipAt (b : ℝ) (g c : Fin k → ℝ) (i : Fin k) : ℝ :=
  margin b g c - margin b g (flipAt i c)

/-- Margin loss caused by rescaling the whole block by `l`. -/
def dropScaleAll (b : ℝ) (g c : Fin k → ℝ) (l : ℝ) : ℝ :=
  margin b g c - margin b g (scaleAll l c)

@[simp] lemma dropZeroAt_eq (b : ℝ) (g c : Fin k → ℝ) (i : Fin k) :
    dropZeroAt b g c i = g i * c i := by
  simp [dropZeroAt, margin_zeroAt]

@[simp] lemma dropZeroAll_eq (b : ℝ) (g c : Fin k → ℝ) :
    dropZeroAll b g c = ∑ i, g i * c i := by
  simp [dropZeroAll, margin]

/-- **Additivity of ablations in an affine read-out.**  The whole-block drop is
the *sum* of the single-coordinate drops. -/
theorem dropZeroAll_eq_sum_dropZeroAt (b : ℝ) (g c : Fin k → ℝ) :
    dropZeroAll b g c = ∑ i, dropZeroAt b g c i := by
  simp

/-- **The affine flip law.**  A sign flip costs exactly twice an ablation. -/
theorem dropFlipAt_eq_two_mul_dropZeroAt (b : ℝ) (g c : Fin k → ℝ) (i : Fin k) :
    dropFlipAt b g c i = 2 * dropZeroAt b g c i := by
  simp [dropFlipAt, margin_flipAt]

/-- **The affine scale law.**  Rescaling by `l` costs `(1 - l)` block drops; in
particular the scale curve is a straight line between `zeroAll` and `ctl`. -/
theorem dropScaleAll_eq (b l : ℝ) (g c : Fin k → ℝ) :
    dropScaleAll b g c l = (1 - l) * dropZeroAll b g c := by
  have h1 : dropScaleAll b g c l = (∑ i, g i * c i) - l * ∑ i, g i * c i := by
    rw [dropScaleAll, margin_scaleAll, margin]; ring
  rw [h1, dropZeroAll_eq]
  ring

/-- **The affine saturation bound.**  If every single-coordinate ablation moves
the margin by at most `ε`, the whole block is worth at most `k · ε`. -/
theorem abs_dropZeroAll_le {b : ℝ} {g c : Fin k → ℝ} {ε : ℝ}
    (h : ∀ i, |dropZeroAt b g c i| ≤ ε) : |dropZeroAll b g c| ≤ k * ε := by
  calc |dropZeroAll b g c| = |∑ i, dropZeroAt b g c i| := by
        rw [dropZeroAll_eq_sum_dropZeroAt]
    _ ≤ ∑ _i : Fin k, ε := (Finset.abs_sum_le_sum_abs _ _).trans
          (Finset.sum_le_sum fun i _ => h i)
    _ = k * ε := by simp [mul_comm]

/-- **Dimension certificate.**  An observed block drop `D` together with a
single-coordinate no-op tolerance `ε > 0` forces `D / ε ≤ k` exclusive
dimensions in any affine read-out. -/
theorem card_lower_bound_of_block_drop {b : ℝ} {g c : Fin k → ℝ} {ε D : ℝ}
    (hε : 0 < ε) (h : ∀ i, |dropZeroAt b g c i| ≤ ε) (hD : D ≤ |dropZeroAll b g c|) :
    D / ε ≤ k :=
  (div_le_iff₀ hε).2 (by simpa [mul_comm] using hD.trans (abs_dropZeroAll_le h))

/-! ## The no-go for the measured k = 2, s = 13 arm

The published numbers are `ctl 0.9980`, `zeroAt 0 : 0.9961`, `zeroAt 1 : 0.9990`
(both inside the reported no-op band `|Δ| ≤ 0.002`), `zeroAll : 0.7544`
(a drop of `0.2436`) and `flipAt 0 : 0.7505` (a drop of `0.2475`).  Reading the
measured accuracies as an affine margin statistic, both signatures are
impossible at `k = 2`. -/

/-- **No-go, ablation form.**  No affine read-out on two exclusive coordinates
has single-coordinate drops bounded by `0.002` and a whole-block drop of
`0.2436`: additivity would cap the block drop at `0.004`.  (Equivalently: the
measured arm would need at least `122` exclusive dimensions to be affine.) -/
theorem s13_k2_no_affine_readout :
    ¬ ∃ (b : ℝ) (g c : Fin 2 → ℝ),
        (∀ i, |dropZeroAt b g c i| ≤ 2 / 1000) ∧
          dropZeroAll b g c = 2436 / 10000 := by
  rintro ⟨b, g, c, hsmall, hblock⟩
  have hbound := abs_dropZeroAll_le hsmall
  rw [hblock] at hbound
  rw [abs_of_nonneg (by norm_num)] at hbound
  norm_num at hbound

/-- **No-go, sign form.**  Sign-sensitivity without ablation-sensitivity is
affinely impossible *at any width*: the flip drop is exactly twice the ablation
drop.  With the measured `s = 13` numbers (`|Δzero| ≤ 0.002`, flip drop
`0.2475`) there is no affine read-out on any number of coordinates. -/
theorem s13_k2_flip_no_affine_readout (i : Fin 2) :
    ¬ ∃ (b : ℝ) (g c : Fin 2 → ℝ),
        |dropZeroAt b g c i| ≤ 2 / 1000 ∧ dropFlipAt b g c i = 2475 / 10000 := by
  rintro ⟨b, g, c, hsmall, hflip⟩
  rw [dropFlipAt_eq_two_mul_dropZeroAt] at hflip
  have : |dropZeroAt b g c i| = 2475 / 20000 := by
    rw [show dropZeroAt b g c i = 2475 / 20000 by linarith]
    rw [abs_of_nonneg (by norm_num)]
  rw [this] at hsmall
  norm_num at hsmall

/-! ## The positive half: when redundancy does upgrade

The five self-sufficient k = 2 arms (seeds 8–12) show whole-block drops of at
most `0.010`, and at the imperfect s = 10 arm the block drop is *negative*
(removal helps: `0.9399 → 0.9453`).  Affinely, a nonpositive net block
contribution is exactly the condition under which single-coordinate redundancy
upgrades to whole-block self-sufficiency. -/

/-- **Redundancy upgrade.**  If each single-coordinate ablation keeps the margin
above threshold `θ` and the block's net contribution is nonpositive, then the
whole-block ablation keeps the margin above `θ` as well. -/
theorem zeroAll_margin_ge_of_redundant {b θ : ℝ} {g c : Fin k → ℝ} (hk : 0 < k)
    (hred : ∀ i, θ ≤ margin b g (zeroAt i c)) (hblock : ∑ i, g i * c i ≤ 0) :
    θ ≤ margin b g (zeroAll c) := by
  have key : ∀ i : Fin k, θ ≤ b + (∑ j, g j * c j) - g i * c i := by
    intro i
    have h := hred i
    rw [margin_zeroAt, margin] at h
    linarith
  have h1 : ∑ _i : Fin k, θ ≤ ∑ i : Fin k, (b + (∑ j, g j * c j) - g i * c i) :=
    Finset.sum_le_sum fun i _ => key i
  have h2 : ∑ _i : Fin k, θ = (k : ℝ) * θ := by simp [mul_comm]
  have h3 : ∑ i : Fin k, (b + (∑ j, g j * c j) - g i * c i)
      = (k : ℝ) * (b + ∑ j, g j * c j) - ∑ j, g j * c j := by
    rw [Finset.sum_sub_distrib]
    simp
    ring
  rw [h2, h3] at h1
  have hkpos : (0 : ℝ) < k := by exact_mod_cast hk
  have hk1 : (1 : ℝ) ≤ k := by exact_mod_cast hk
  have hSk : ((k : ℝ) - 1) * (∑ j, g j * c j) ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos (by linarith) hblock
  have hb : θ ≤ b := by nlinarith
  simpa using hb

end NumberTheory.ExclusiveChannel