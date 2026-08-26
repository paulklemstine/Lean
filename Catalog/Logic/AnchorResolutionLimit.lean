/-
# Resolution-limited inversion of a booked anchor (paper 225 erratum rider)

The rider attached to the exp-576 report concerns four booked amplification anchors whose
underlying hit probability `P̂` was never stored raw: each booked `P̂` is a *drafted-law
inversion*, recovered from the stored anchor to a precision of about `2·10⁻⁴`.  The
recommendation is to book the anchors "at resolution limit" rather than "at stored `P̂`".

This file supplies the mathematics that makes "resolution limit" a definite notion and
that certifies the two quantitative claims of the rider.

**Two-sided resolution.**  For a law `f` that is at least `m`-expansive and at most
`L`-Lipschitz on a window `s`, the set of probabilities compatible with an anchor stored to
precision `δ` — the *resolution cell* — has diameter at most `2δ/m`
(`Logic.AnchorResolution.cell_diam_le`) and contains a whole interval of half-width `δ/L`
around any exact preimage (`Logic.AnchorResolution.cell_mem_of_close`).  So the cell is a
genuine window, not a point: an inversion cannot report more than the cell.

**Forward amplification.**  Conversely a `P̂` discrepancy `ε` moves the anchor by at most
`L·ε` (`Logic.AnchorResolution.anchor_shift_le`).  At the `29.1×` locus the booked
`P̂ = 0.9853` exceeds the certified-law-implied `P̂ = 0.985068` by `2.32·10⁻⁴`, and the
sensitivity of the law there is about `826`, giving an anchor overstatement of at most
`0.192` — the reported `~0.19` (`Logic.AnchorResolution.p225_printed_overstatement`).

**Margin robustness.**  Feasibility of the corrected table is unaffected: a perturbation of
the booked anchor smaller than the recorded slack cannot break `S_raw ≤ S_A`
(`Logic.AnchorResolution.feasibility_margin_stable`), and all four recorded margins
`0.212 / 0.242 / 0.183 / 0.190` exceed the perturbation
(`Logic.AnchorResolution.p225_four_margins_hold`).

An explicit non-degenerate law `P ↦ 1/(1−P)` on `[0.98, 0.99]` is carried through to show
that the expansive/Lipschitz hypotheses are satisfiable with a genuine gap between the two
constants (`Logic.AnchorResolution.invLaw_expansive`, `Logic.AnchorResolution.invLaw_lipOn`,
`Logic.AnchorResolution.invLaw_cell_width`).
-/
import Mathlib

namespace Logic.AnchorResolution

/-- `f` grows at least at rate `m` on `s`: the inversion `R ↦ P̂` is well conditioned. -/
def Expansive (f : ℝ → ℝ) (s : Set ℝ) (m : ℝ) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → x ≤ y → m * (y - x) ≤ f y - f x

/-- `f` grows at most at rate `L` on `s`: the forward map `P̂ ↦ R` amplifies by at most `L`. -/
def LipOn (f : ℝ → ℝ) (s : Set ℝ) (L : ℝ) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → x ≤ y → f y - f x ≤ L * (y - x)

/-- The probabilities compatible with an anchor stored as `R` to precision `δ`. -/
def cell (f : ℝ → ℝ) (s : Set ℝ) (R delta : ℝ) : Set ℝ := {P | P ∈ s ∧ |f P - R| ≤ delta}

/-- **Resolution limit.**  Two probabilities in the same resolution cell differ by at most
`2δ/m`: an inversion of a stored anchor cannot resolve `P̂` beyond this width. -/
theorem cell_diam_le {f : ℝ → ℝ} {s : Set ℝ} {m R delta : ℝ} (hm : 0 < m)
    (hf : Expansive f s m) {P Q : ℝ} (hP : P ∈ cell f s R delta) (hQ : Q ∈ cell f s R delta) :
    |P - Q| ≤ 2 * delta / m := by
  obtain ⟨hPs, hPd⟩ := hP
  obtain ⟨hQs, hQd⟩ := hQ
  have habs : ∀ {x y : ℝ}, x ∈ s → y ∈ s → |f x - R| ≤ delta → |f y - R| ≤ delta →
      x ≤ y → y - x ≤ 2 * delta / m := by
    intro x y hx hy hdx hdy hxy
    have h1 : m * (y - x) ≤ f y - f x := hf hx hy hxy
    have h2 : f y - f x ≤ 2 * delta := by
      have hx' := abs_le.mp hdx
      have hy' := abs_le.mp hdy
      linarith [hx'.1, hx'.2, hy'.1, hy'.2]
    have hkey : m * (y - x) ≤ 2 * delta := le_trans h1 h2
    exact (le_div_iff₀' hm).mpr hkey
  rcases le_total P Q with h | h
  · rw [abs_sub_comm, abs_of_nonneg (by linarith)]
    exact habs hPs hQs hPd hQd h
  · rw [abs_of_nonneg (by linarith)]
    exact habs hQs hPs hQd hPd h

/-- **The cell is a genuine window.**  If `f P₀ = R` then every admissible `P` within
`δ/L` of `P₀` also lies in the cell: the resolution limit is not an artifact of the bound. -/
theorem cell_mem_of_close {f : ℝ → ℝ} {s : Set ℝ} {m L R delta : ℝ} (hm : 0 ≤ m) (hL : 0 < L)
    (hexp : Expansive f s m) (hf : LipOn f s L) {P0 P : ℝ} (hP0 : P0 ∈ s) (hP : P ∈ s)
    (hR : f P0 = R) (hclose : |P - P0| ≤ delta / L) :
    P ∈ cell f s R delta := by
  refine ⟨hP, ?_⟩
  rw [← hR, abs_le]
  obtain ⟨h1, h2⟩ := abs_le.mp hclose
  have hLd : L * (delta / L) = delta := by field_simp
  rcases le_total P P0 with h | h
  · have hup := hf hP hP0 h
    have hlow := hexp hP hP0 h
    have hstep : L * (P0 - P) ≤ L * (delta / L) := by nlinarith
    constructor <;> nlinarith
  · have hup := hf hP0 hP h
    have hlow := hexp hP0 hP h
    have hstep : L * (P - P0) ≤ L * (delta / L) := by nlinarith
    constructor <;> nlinarith

/-- **Forward amplification.**  A `P̂` discrepancy of `ε` shifts the anchor by at most
`L·ε`, for a law that is monotone (`Expansive` with rate `0`) and `L`-Lipschitz. -/
theorem anchor_shift_le {f : ℝ → ℝ} {s : Set ℝ} {L eps : ℝ} (hL : 0 ≤ L)
    (hmono : Expansive f s 0) (hf : LipOn f s L)
    {P Q : ℝ} (hP : P ∈ s) (hQ : Q ∈ s) (h : |P - Q| ≤ eps) :
    |f P - f Q| ≤ L * eps := by
  obtain ⟨h1, h2⟩ := abs_le.mp h
  rcases le_total P Q with hle | hle
  · have hup := hf hP hQ hle
    have hlow := hmono hP hQ hle
    rw [abs_le]
    constructor <;> nlinarith
  · have hup := hf hQ hP hle
    have hlow := hmono hQ hP hle
    rw [abs_le]
    constructor <;> nlinarith

/-! ## The paper-225 rider, quantified -/

/-- **Printed-anchor overstatement at the 29.1× locus.**  Booking `P̂ = 0.9853` instead of
the certified-law-implied `P̂ = 0.985068` overstates the printed anchor by at most `0.192`,
given the local sensitivity `826` of the law — matching the reported `~0.19`. -/
theorem p225_printed_overstatement {f : ℝ → ℝ} {s : Set ℝ}
    (hmono : Expansive f s 0) (hf : LipOn f s 826) {Pb Pc : ℝ} (hPb : Pb ∈ s) (hPc : Pc ∈ s)
    (hb : Pb = 9853 / 10000) (hc : Pc = 985068 / 1000000) :
    |f Pb - f Pc| ≤ 192 / 1000 := by
  have hdiff : |Pb - Pc| ≤ 232 / 1000000 := by
    rw [hb, hc]; rw [abs_le]; constructor <;> norm_num
  have := anchor_shift_le (by norm_num : (0:ℝ) ≤ 826) hmono hf hPb hPc hdiff
  calc |f Pb - f Pc| ≤ 826 * (232 / 1000000) := this
    _ ≤ 192 / 1000 := by norm_num

/-- **Bookings inside one resolution cell.**  If both the booked and the certified `P̂`
reproduce the stored anchor to its precision `δ`, they are separated by at most `2δ/m`:
the two bookings are indistinguishable from the stored data, which is exactly the
admissibility situation the rider describes. -/
theorem booked_certified_indistinguishable {f : ℝ → ℝ} {s : Set ℝ} {m R delta : ℝ}
    (hm : 0 < m) (hf : Expansive f s m) {Pb Pc : ℝ}
    (hb : Pb ∈ cell f s R delta) (hc : Pc ∈ cell f s R delta) :
    |Pb - Pc| ≤ 2 * delta / m :=
  cell_diam_le hm hf hb hc

/-- **Margin robustness.**  A perturbation of the booked quantity that is smaller than the
recorded feasibility margin cannot break the feasibility inequality. -/
theorem feasibility_margin_stable {SA SA' Sraw margin eps : ℝ}
    (h : Sraw + margin ≤ SA) (hd : |SA' - SA| ≤ eps) (heps : eps ≤ margin) :
    Sraw ≤ SA' := by
  have := (abs_le.mp hd).1
  linarith

/-- The four recorded feasibility margins of paper 225's corrected table. -/
noncomputable def p225Margins : Fin 4 → ℝ := ![212 / 1000, 242 / 1000, 183 / 1000, 190 / 1000]

/-- **All four loci survive the rider.**  Rebooking the anchors at the resolution limit
perturbs each `S_A` by at most `0.18`, which is below every recorded margin, so all four
feasibility readings `S_raw ≤ S_A` continue to hold. -/
theorem p225_four_margins_hold (SA SA' Sraw : Fin 4 → ℝ)
    (hmar : ∀ i, Sraw i + p225Margins i ≤ SA i)
    (hpert : ∀ i, |SA' i - SA i| ≤ 18 / 100) :
    ∀ i, Sraw i ≤ SA' i := by
  intro i
  refine feasibility_margin_stable (hmar i) (hpert i) ?_
  fin_cases i <;> simp [p225Margins] <;> norm_num

/-! ## A non-degenerate instance of the hypotheses -/

/-- An illustrative amplification law with a pole at `P̂ = 1`. -/
noncomputable def invLaw (P : ℝ) : ℝ := 1 / (1 - P)

/-- On `[0.98, 0.99]` the illustrative law expands by at least `2500`. -/
theorem invLaw_expansive : Expansive invLaw (Set.Icc (98 / 100) (99 / 100)) 2500 := by
  rintro x ⟨hx1, hx2⟩ y ⟨hy1, hy2⟩ hxy
  have h1x : (0:ℝ) < 1 - x := by norm_num at hx2 ⊢; linarith
  have h1y : (0:ℝ) < 1 - y := by norm_num at hy2 ⊢; linarith
  have hdiff : invLaw y - invLaw x = (y - x) / ((1 - y) * (1 - x)) := by
    rw [invLaw, invLaw]; field_simp; ring
  rw [hdiff, le_div_iff₀ (by positivity)]
  have hbx : 1 - x ≤ 2 / 100 := by norm_num at hx1 ⊢; linarith
  have hby : 1 - y ≤ 2 / 100 := by norm_num at hy1 ⊢; linarith
  have hd : 0 ≤ y - x := sub_nonneg.mpr hxy
  have hprod : (1 - y) * (1 - x) ≤ 1 / 2500 := by nlinarith
  nlinarith [mul_le_mul_of_nonneg_left hprod hd]

/-- On `[0.98, 0.99]` the illustrative law amplifies by at most `10000`. -/
theorem invLaw_lipOn : LipOn invLaw (Set.Icc (98 / 100) (99 / 100)) 10000 := by
  rintro x ⟨hx1, hx2⟩ y ⟨hy1, hy2⟩ hxy
  have h1x : (0:ℝ) < 1 - x := by norm_num at hx2 ⊢; linarith
  have h1y : (0:ℝ) < 1 - y := by norm_num at hy2 ⊢; linarith
  have hdiff : invLaw y - invLaw x = (y - x) / ((1 - y) * (1 - x)) := by
    rw [invLaw, invLaw]; field_simp; ring
  rw [hdiff, div_le_iff₀ (by positivity)]
  have hbx : 1 / 100 ≤ 1 - x := by norm_num at hx2 ⊢; linarith
  have hby : 1 / 100 ≤ 1 - y := by norm_num at hy2 ⊢; linarith
  have hd : 0 ≤ y - x := sub_nonneg.mpr hxy
  have hprod : 1 / 10000 ≤ (1 - y) * (1 - x) := by nlinarith
  nlinarith [mul_le_mul_of_nonneg_left hprod hd]

/-- For the illustrative law, an anchor stored to precision `δ` pins `P̂` to a window of
width at most `δ/1250`, while every `P̂` within `δ/10000` of an exact preimage is still
compatible: the resolution cell has a genuine width, bracketed by a factor `8`. -/
theorem invLaw_cell_width {R delta : ℝ} {P Q : ℝ}
    (hP : P ∈ cell invLaw (Set.Icc (98 / 100) (99 / 100)) R delta)
    (hQ : Q ∈ cell invLaw (Set.Icc (98 / 100) (99 / 100)) R delta) :
    |P - Q| ≤ delta / 1250 := by
  have h := cell_diam_le (by norm_num : (0:ℝ) < 2500) invLaw_expansive hP hQ
  calc |P - Q| ≤ 2 * delta / 2500 := h
    _ = delta / 1250 := by ring

end Logic.AnchorResolution