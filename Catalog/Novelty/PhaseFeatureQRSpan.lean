import Novelty.PhaseFeatureExactBlockSpectrum

/-!
# Full-frequency degeneracy: the QR feature is a phase combination (paper 150, fifth cycle)

## Research context

The ceilings of this thread are all *design-local*: they bound what the three features
`(cos_k, sin_k, QR)` of a single prime-`p` block, at a single frequency `k`, can explain, and the
sharp constant `1 - √(2/(p-1))` of `Novelty.PhaseFeatureExactBlockSpectrum` is attained precisely
because the quadratic-residue indicator is *partially* aligned with one trigonometric channel.

This file establishes the endpoint of that phenomenon.  Summing over *all* frequencies, the
alignment becomes total: the quadratic-residue indicator lies **exactly** in the span of the
phase features.  Consequently the QR feature adds no capacity whatsoever to a full-frequency
phase design; the whole discussion of QR/phase coupling is an artefact of using a restricted
frequency set (as exp 482 does: one root-position frequency per prime).

The proof is a Bessel equality.  At each nonzero frequency the two Gauss-sum channels together
explain exactly `2` units of the QR energy (`gain_qr_phase_pair`, from `|g_k|² = p` and
`‖cos_k‖² = ‖sin_k‖² = p/2`).  Over the `(p-1)/2` frequencies of a half period — a maximal
pairwise-orthogonal subfamily — the total is `p - 1 = ‖QR‖²`, leaving zero residual.

## Main results

* `halfFreq`, `card_halfFreq` — the frequency half-period `{1, …, (p-1)/2} ⊆ ZMod p`, of
  cardinality `(p-1)/2`, on which the phase family is pairwise orthogonal.
* `gain_qr_phase_pair` — at every nonzero frequency the cosine and sine channels jointly explain
  exactly `2` units of QR energy, whatever the residue class of `p` mod `4`.
* `phaseDesign_orthogonal`, `sum_gain_qr_phaseDesign` — the design is orthogonal and its total
  gain on the QR feature is exactly `‖QR‖² = p - 1`.
* `qr_eq_combo_phaseDesign` — **the degeneracy**: `QR` equals an explicit linear combination of
  the half-period phase features.
* `qr_adds_no_capacity` — the statistical consequence: appending `QR` to the full phase design
  cannot change the fitted residual, so the phase/QR coupling that drives the block ceiling is a
  feature-selection effect, not an information-theoretic one.

## Lab notes (fifth cycle)

```
p    ‖QR‖² = p-1   energy explained by the (p-1)/2 phase pairs   residual
5        4                        4.000000000                     0
7        6                        6.000000000                     0
11      10                       10.000000000                     0
13      12                       12.000000000                     0
17      16                       16.000000000                     0
19      18                       18.000000000                     0
29      28                       28.000000000                     0
```
(exploratory floating-point evaluation; the exact statement is `qr_eq_combo_phaseDesign` below)
-/

open Finset
open Catalog.Novelty.PhaseFeatureLiftCeiling
open Catalog.Novelty.PhaseFeatureCharacterGram

namespace Catalog.Novelty.PhaseFeatureQRSpan

/-! ## 1. Vanishing energy means vanishing feature -/

/-- A feature of zero sample energy is identically zero. -/
lemma sqnorm_eq_zero_iff {ι : Type*} [Fintype ι] (x : ι → ℝ) : sqnorm x = 0 ↔ x = 0 := by
  constructor
  · intro h
    funext i
    have hsum : ∑ j, (x j) ^ 2 = 0 := by rw [← sqnorm_eq_sum_sq]; exact h
    have hi := (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => sq_nonneg (x j))).mp hsum i
      (Finset.mem_univ i)
    simpa using pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hi
  · intro h; simp [h, sqnorm, dot]

/-! ## 2. The frequency half-period -/

section HalfFreq

variable {p : ℕ} [Fact p.Prime]

/-- The frequencies `1, 2, …, (p-1)/2` of a half period: a set of representatives for the
pairs `{k, -k}` of nonzero frequencies, on which the phase family is pairwise orthogonal. -/
def halfFreq (p : ℕ) : Finset (ZMod p) :=
  (Finset.Icc 1 ((p - 1) / 2)).image (fun n : ℕ => (n : ZMod p))

lemma mem_halfFreq_iff (k : ZMod p) :
    k ∈ halfFreq p ↔ ∃ n : ℕ, 1 ≤ n ∧ n ≤ (p - 1) / 2 ∧ (n : ZMod p) = k := by
  simp [halfFreq, Finset.mem_image, Finset.mem_Icc, and_assoc]

lemma card_halfFreq (hp : 3 ≤ p) : (halfFreq p).card = (p - 1) / 2 := by
  have hinj : Set.InjOn (fun n : ℕ => (n : ZMod p)) (Finset.Icc 1 ((p - 1) / 2)) := by
    intro a ha b hb hab
    simp only [Finset.coe_Icc, Set.mem_Icc] at ha hb
    have hap : a < p := by omega
    have hbp : b < p := by omega
    have hval := congrArg ZMod.val hab
    rwa [ZMod.val_natCast_of_lt hap, ZMod.val_natCast_of_lt hbp] at hval
  rw [halfFreq, Finset.card_image_of_injOn hinj, Nat.card_Icc]
  omega

lemma halfFreq_ne_zero (hp : 3 ≤ p) {k : ZMod p} (hk : k ∈ halfFreq p) : k ≠ 0 := by
  rw [mem_halfFreq_iff] at hk
  obtain ⟨n, h1, h2, rfl⟩ := hk
  intro h
  have hnp : n < p := by omega
  have hval := congrArg ZMod.val h
  rw [ZMod.val_natCast_of_lt hnp, ZMod.val_zero] at hval
  omega

/-- Two half-period frequencies never sum to zero: this is what makes the family orthogonal. -/
lemma halfFreq_add_ne_zero (hp : 3 ≤ p) {k l : ZMod p} (hk : k ∈ halfFreq p)
    (hl : l ∈ halfFreq p) : k + l ≠ 0 := by
  rw [mem_halfFreq_iff] at hk hl
  obtain ⟨n, hn1, hn2, rfl⟩ := hk
  obtain ⟨m, hm1, hm2, rfl⟩ := hl
  intro h
  have hcast : ((n + m : ℕ) : ZMod p) = 0 := by push_cast; exact h
  have hdvd : p ∣ (n + m) := (ZMod.natCast_eq_zero_iff _ _).mp hcast
  have hpos : 0 < n + m := by omega
  have hle := Nat.le_of_dvd hpos hdvd
  omega

end HalfFreq

/-! ## 3. Each frequency pair explains two units of QR energy -/

section Gains

variable {p : ℕ} [Fact p.Prime]

/-- **Two units per frequency.**  At any nonzero frequency the cosine and sine channels jointly
explain exactly `2` units of the quadratic-residue energy: the Gauss sum has modulus `√p` and the
phase features have energy `p/2` each, so the split between the channels is irrelevant to the
total.  (Which channel carries it is the Gauss-sign dichotomy.) -/
theorem gain_qr_phase_pair (hp : p ≠ 2) (hp3 : 3 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) :
    gain (qrFeat (p := p)) (phaseCos k) + gain (qrFeat (p := p)) (phaseSin k) = 2 := by
  have hp0 : (0 : ℝ) < (p : ℝ) := by
    have hpp : 0 < p := by omega
    exact_mod_cast hpp
  set g := gaussSum (chiC p) (ZMod.stdAddChar.mulShift k) with hg
  have hnorm : ‖g‖ ^ 2 = (p : ℝ) := norm_gaussSum_sq hp k hk
  have hsplit : g.re ^ 2 + g.im ^ 2 = (p : ℝ) := by
    rw [← hnorm, ← Complex.normSq_eq_norm_sq]
    simp [Complex.normSq_apply]
    ring
  rw [gain, gain, dot_qrFeat_phaseCos_eq, dot_qrFeat_phaseSin_eq,
    sqnorm_phaseCos k hk2, sqnorm_phaseSin k hk2, ← hg]
  field_simp
  linarith [hsplit]

/-- The half-period phase design: cosine and sine at every frequency of `halfFreq p`. -/
noncomputable def phaseDesign (p : ℕ) [Fact p.Prime] :
    {k : ZMod p // k ∈ halfFreq p} × Bool → (ZMod p → ℝ)
  | (k, false) => phaseCos k.1
  | (k, true) => phaseSin k.1

@[simp] lemma phaseDesign_false (k : {k : ZMod p // k ∈ halfFreq p}) :
    phaseDesign p (k, false) = phaseCos k.1 := rfl

@[simp] lemma phaseDesign_true (k : {k : ZMod p // k ∈ halfFreq p}) :
    phaseDesign p (k, true) = phaseSin k.1 := rfl

lemma phaseDesign_pos (hp3 : 3 ≤ p) (x : {k : ZMod p // k ∈ halfFreq p} × Bool) :
    0 < sqnorm (phaseDesign p x) := by
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast lt_of_lt_of_le (by norm_num) hp3
  obtain ⟨k, b⟩ := x
  have hk2 : k.1 + k.1 ≠ 0 := halfFreq_add_ne_zero hp3 k.2 k.2
  cases b
  · rw [phaseDesign_false, sqnorm_phaseCos k.1 hk2]; linarith
  · rw [phaseDesign_true, sqnorm_phaseSin k.1 hk2]; linarith

/-- **Orthogonality of the half-period design.**  Distinct features are exactly orthogonal:
cosines and sines never couple, and two distinct half-period frequencies satisfy both
`k - l ≠ 0` and `k + l ≠ 0`. -/
theorem phaseDesign_orthogonal (hp3 : 3 ≤ p)
    (x y : {k : ZMod p // k ∈ halfFreq p} × Bool) (hxy : x ≠ y) :
    dot (phaseDesign p x) (phaseDesign p y) = 0 := by
  obtain ⟨k, b⟩ := x
  obtain ⟨l, d⟩ := y
  have hfreq : b = d → (k : ZMod p) ≠ (l : ZMod p) := by
    intro hbd h
    exact hxy (by rw [Subtype.ext h, hbd])
  cases b <;> cases d
  · rw [phaseDesign_false, phaseDesign_false]
    exact dot_phaseCos_phaseCos_eq_zero _ _ (sub_ne_zero.mpr (hfreq rfl))
      (halfFreq_add_ne_zero hp3 k.2 l.2)
  · rw [phaseDesign_false, phaseDesign_true]
    exact dot_phaseCos_phaseSin _ _
  · rw [phaseDesign_true, phaseDesign_false, dot_comm]
    exact dot_phaseCos_phaseSin _ _
  · rw [phaseDesign_true, phaseDesign_true]
    exact dot_phaseSin_phaseSin_eq_zero _ _ (sub_ne_zero.mpr (hfreq rfl))
      (halfFreq_add_ne_zero hp3 k.2 l.2)

/-- **Bessel total.**  The half-period phase design explains exactly `p - 1 = ‖QR‖²` units of the
quadratic-residue energy: `2` per frequency, over `(p-1)/2` frequencies. -/
theorem sum_gain_qr_phaseDesign (hp : p ≠ 2) (hp3 : 3 ≤ p) :
    ∑ x, gain (qrFeat (p := p)) (phaseDesign p x) = (p : ℝ) - 1 := by
  have hodd : p % 2 = 1 := by
    rcases (Fact.out : p.Prime).eq_two_or_odd with h | h
    · omega
    · exact h
  have hstep : ∀ x : {k : ZMod p // k ∈ halfFreq p},
      gain (qrFeat (p := p)) (phaseDesign p (x, false))
        + gain (qrFeat (p := p)) (phaseDesign p (x, true)) = 2 := by
    intro x
    rw [phaseDesign_false, phaseDesign_true]
    exact gain_qr_phase_pair hp hp3 x.1 (halfFreq_ne_zero hp3 x.2)
      (halfFreq_add_ne_zero hp3 x.2 x.2)
  calc ∑ x, gain (qrFeat (p := p)) (phaseDesign p x)
      = ∑ x : {k : ZMod p // k ∈ halfFreq p}, (gain (qrFeat (p := p)) (phaseDesign p (x, false))
          + gain (qrFeat (p := p)) (phaseDesign p (x, true))) := by
        rw [Fintype.sum_prod_type]
        exact Finset.sum_congr rfl fun x _ => by
          rw [Fintype.sum_bool]; ring
    _ = ∑ _x : {k : ZMod p // k ∈ halfFreq p}, (2 : ℝ) :=
        Finset.sum_congr rfl fun x _ => hstep x
    _ = (p : ℝ) - 1 := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_coe, card_halfFreq hp3]
        have h2 : 2 * ((p - 1) / 2) = p - 1 := by omega
        have hcast : ((p - 1 : ℕ) : ℝ) = (p : ℝ) - 1 := by
          have : 1 ≤ p := by omega
          push_cast [Nat.cast_sub this]
          ring
        rw [nsmul_eq_mul]
        rw [show (((p - 1) / 2 : ℕ) : ℝ) * 2 = (((p - 1) / 2 * 2 : ℕ) : ℝ) by push_cast; ring]
        rw [show (p - 1) / 2 * 2 = p - 1 by omega, hcast]

/-- **The degeneracy theorem.**  The quadratic-residue indicator mod `p` is *exactly* a linear
combination of the half-period phase features: it carries no information beyond the phases.  The
coefficients are the ordinary projection coefficients `⟨QR, f⟩/‖f‖²`. -/
theorem qr_eq_combo_phaseDesign (hp : p ≠ 2) (hp3 : 3 ≤ p) :
    (qrFeat (p := p))
      = combo (fun x => dot (qrFeat (p := p)) (phaseDesign p x) / sqnorm (phaseDesign p x))
          (phaseDesign p) := by
  have hres := sqnorm_residual_orthogonal (qrFeat (p := p)) (phaseDesign p)
    (phaseDesign_pos hp3) (phaseDesign_orthogonal hp3)
  rw [sum_gain_qr_phaseDesign hp hp3, sqnorm_qrFeat] at hres
  have hzero : sqnorm (fun i => qrFeat (p := p) i
      - combo (fun x => dot (qrFeat (p := p)) (phaseDesign p x) / sqnorm (phaseDesign p x))
          (phaseDesign p) i) = 0 := by
    rw [hres]; ring
  have := (sqnorm_eq_zero_iff _).mp hzero
  funext r
  have hr := congrFun this r
  simp only [Pi.zero_apply, sub_eq_zero] at hr
  exact hr

/-- **No incremental capacity.**  Because `QR` is a phase combination, every model that fits
`QR` with coefficient `a` on top of the phase design is *identical* to a model using the phase
design alone: the QR feature cannot change any fitted residual, hence cannot change any `R²`.
The prime-block coupling that drives the sharp ceiling is therefore a consequence of restricting
to one frequency, not of any genuine arithmetic information in the QR indicator. -/
theorem qr_adds_no_capacity (hp : p ≠ 2) (hp3 : 3 ≤ p) (a : ℝ)
    (c : {k : ZMod p // k ∈ halfFreq p} × Bool → ℝ) :
    ∃ c' : {k : ZMod p // k ∈ halfFreq p} × Bool → ℝ,
      (fun i => a * qrFeat (p := p) i + combo c (phaseDesign p) i)
        = combo c' (phaseDesign p) := by
  refine ⟨fun x => a * (dot (qrFeat (p := p)) (phaseDesign p x) / sqnorm (phaseDesign p x))
      + c x, ?_⟩
  funext i
  have hq := congrFun (qr_eq_combo_phaseDesign hp hp3) i
  simp only [combo, hq, Finset.mul_sum, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun x _ => by ring

end Gains

end Catalog.Novelty.PhaseFeatureQRSpan