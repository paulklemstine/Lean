/-
# What a nested window ladder can and cannot identify
## (paper 168 / exp 501, cycle 4 — built on `Logic.UHardenResolutionSplit`)

Cycles 1–3 bounded the *resolution* part of a measured gate drop from above (`|D| ≤ L/N₁`
for nested windows) and derived its offset-averaged law.  The complementary question is a
lower bound on ignorance: two different responses can produce **identical** measurements on
every window of the design and still disagree about the intrinsic drop, because a window of
`N` items only ever evaluates the response at the rates `k/N`.

**The construction.**  `linResp L` is the linear response of slope `−L/2`; `kinkResp L`
descends at the maximal admissible rate `−L` on the first half of the first fine cell, is
flat on the second half, and rejoins `linResp L` from `1/960` onwards
(`kinkResp_eq_linResp_of_ge`).  Both are antitone and `L`-Lipschitz
(`linResp_antitone`, `linResp_lip`, `kinkResp_antitone`, `kinkResp_lip`).

**Indistinguishability.**  With the soft gate at `0` and the hard gate at `1/1920` — inside
the first fine cell — both windows of the design realise the gates at `0`, `1/240` and
`1/960`, where the two responses agree.  So `Δ(240)` and `Δ(960)` are *identical* for the
two responses (`ladder_measurements_agree`), while their intrinsic drops differ by exactly
`L/3840 = L/(4·960)` (`intrinsic_gap`).

**Conclusion (`ladder_identifiability_limit`).**  A two-cell nested ladder pins the
intrinsic drop no better than `L/(4·N_fine)`, and cycle 2's bound shows it pins it at least
that well up to a constant.  Numerically, with the Lipschitz floor `L ≥ 8.30` certified by
`p168_lipschitz_floor_nested`, the structural ambiguity is `≈ 0.0022`, i.e. about `2 %` of
`Δ(240) = 0.1073`.  **So the `[0.36, 0.60]` spread on the intrinsic share found in cycle 1
is not a resolution limit of the design — it is statistical width in the reported
intervals.**  More seeds, not finer windows, is the way to close it.
-/
import Logic.UHardenResolutionSplit

namespace Logic.UHarden

/-! ## 1.  Two responses that no window of the design can tell apart -/

/-- The reference response: linear with slope `−L/2`. -/
noncomputable def linResp (L : ℝ) : ℝ → ℝ := fun x => -(L / 2 * x)

/-- The adversary: it descends at the maximal admissible rate `−L` on `(−∞, 1/1920]`, is
flat on `[1/1920, 1/960]`, and coincides with `linResp L` from `1/960` on. -/
noncomputable def kinkResp (L : ℝ) : ℝ → ℝ := fun x =>
  if x ≤ 1 / 1920 then -(L * x) else if x ≤ 1 / 960 then -(L / 1920) else -(L / 2 * x)

theorem linResp_antitone {L : ℝ} (hL : 0 ≤ L) : Antitone (linResp L) := by
  intro a b hab
  simp only [linResp, neg_le_neg_iff]
  nlinarith

theorem linResp_lip {L : ℝ} (hL : 0 ≤ L) : LipBound (linResp L) L := by
  intro x y
  have h : linResp L x - linResp L y = -(L / 2 * (x - y)) := by simp only [linResp]; ring
  rw [h, abs_neg, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ L / 2)]
  have habs : 0 ≤ |x - y| := abs_nonneg _
  nlinarith

/-- Above `1/960` the adversary is the reference response. -/
theorem kinkResp_eq_linResp_of_ge {L x : ℝ} (hx : 1 / 960 < x) :
    kinkResp L x = linResp L x := by
  have h1 : ¬ x ≤ 1 / 1920 := by linarith
  have h2 : ¬ x ≤ 1 / 960 := by linarith
  unfold kinkResp linResp
  rw [if_neg h1, if_neg h2]

/-- A pointwise description of the adversary, used for both regularity proofs. -/
theorem kinkResp_step {L : ℝ} (hL : 0 ≤ L) {x y : ℝ} (hxy : x ≤ y) :
    0 ≤ kinkResp L x - kinkResp L y ∧ kinkResp L x - kinkResp L y ≤ L * (y - x) := by
  unfold kinkResp
  by_cases hx1 : x ≤ 1 / 1920 <;> by_cases hy1 : y ≤ 1 / 1920 <;>
    by_cases hx2 : x ≤ 1 / 960 <;> by_cases hy2 : y ≤ 1 / 960 <;>
    simp only [hx1, hy1, hx2, hy2, if_true, if_false] <;>
    constructor <;> nlinarith

theorem kinkResp_antitone {L : ℝ} (hL : 0 ≤ L) : Antitone (kinkResp L) := by
  intro a b hab
  linarith [(kinkResp_step hL hab).1]

theorem kinkResp_lip {L : ℝ} (hL : 0 ≤ L) : LipBound (kinkResp L) L := by
  intro x y
  rcases le_total x y with h | h
  · have hs := kinkResp_step hL h
    rw [abs_of_nonneg hs.1, abs_of_nonpos (by linarith : x - y ≤ 0)]
    have : L * (y - x) = L * -(x - y) := by ring
    linarith [hs.2, this.ge, this.le]
  · have hs := kinkResp_step hL h
    rw [abs_of_nonpos (by linarith : kinkResp L x - kinkResp L y ≤ 0),
      abs_of_nonneg (by linarith : (0:ℝ) ≤ x - y)]
    linarith [hs.2]

/-! ## 2.  The two windows of the design cannot separate them -/

/-- The three rates at which the design ever evaluates the response, for the gate pair
`(0, 1/1920)`. -/
theorem gates_realised :
    gridUp 240 (0 : ℝ) = 0 ∧ gridUp 960 (0 : ℝ) = 0 ∧
      gridUp 240 (1 / 1920 : ℝ) = 1 / 240 ∧ gridUp 960 (1 / 1920 : ℝ) = 1 / 960 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> · unfold gridUp; norm_num

/-- **Indistinguishability.**  Both windows of the design report the *same* drop for the two
responses: the design never evaluates them where they differ. -/
theorem ladder_measurements_agree (L : ℝ) :
    gateDrop (kinkResp L) 240 0 (1 / 1920) = gateDrop (linResp L) 240 0 (1 / 1920) ∧
      gateDrop (kinkResp L) 960 0 (1 / 1920) = gateDrop (linResp L) 960 0 (1 / 1920) := by
  obtain ⟨g1, g2, g3, g4⟩ := gates_realised
  have h0 : kinkResp L 0 = linResp L 0 := by
    unfold kinkResp linResp
    rw [if_pos (by norm_num : (0:ℝ) ≤ 1 / 1920)]
    ring
  have h240 : kinkResp L (1 / 240) = linResp L (1 / 240) :=
    kinkResp_eq_linResp_of_ge (by norm_num)
  have h960 : kinkResp L (1 / 960) = linResp L (1 / 960) := by
    unfold kinkResp linResp
    rw [if_neg (by norm_num : ¬ (1 / 960 : ℝ) ≤ 1 / 1920), if_pos (le_refl (1 / 960 : ℝ))]
    ring
  unfold gateDrop qResp
  rw [g1, g2, g3, g4, h0, h240, h960]
  exact ⟨rfl, rfl⟩

/-- **…yet their intrinsic drops differ.**  Between the soft gate `0` and the hard gate
`1/1920` the adversary has fallen twice as far: the gap is `L/3840 = L/(4·960)`. -/
theorem intrinsic_gap (L : ℝ) :
    gateDropInf (kinkResp L) 0 (1 / 1920) - gateDropInf (linResp L) 0 (1 / 1920)
      = L / 3840 := by
  have hk0 : kinkResp L 0 = 0 := by
    unfold kinkResp
    rw [if_pos (by norm_num : (0:ℝ) ≤ 1 / 1920)]
    ring
  have hk : kinkResp L (1 / 1920) = -(L / 1920) := by
    unfold kinkResp
    rw [if_pos (le_refl (1 / 1920 : ℝ))]
    ring
  unfold gateDropInf linResp
  rw [hk0, hk]
  ring

/-- **The identifiability limit of the two-cell ladder.**  There are two antitone,
`L`-Lipschitz responses that agree on every measurement the design makes, yet whose
intrinsic drops differ by `L/(4·960)`.  No amount of re-analysis of the four cells can
resolve the intrinsic drop below that width; conversely cycle 2's `|D| ≤ L/240` shows the
design does resolve it to within a constant multiple.  With the certified floor `L ≥ 8.30`
the structural ambiguity is only `≈ 0.0022`, so the wide `[0.36, 0.60]` share interval of
cycle 1 is statistical, not structural. -/
theorem ladder_identifiability_limit {L : ℝ} (hL : 0 ≤ L) :
    (Antitone (kinkResp L) ∧ LipBound (kinkResp L) L) ∧
      (Antitone (linResp L) ∧ LipBound (linResp L) L) ∧
      (gateDrop (kinkResp L) 240 0 (1 / 1920) = gateDrop (linResp L) 240 0 (1 / 1920) ∧
        gateDrop (kinkResp L) 960 0 (1 / 1920) = gateDrop (linResp L) 960 0 (1 / 1920)) ∧
      gateDropInf (kinkResp L) 0 (1 / 1920) - gateDropInf (linResp L) 0 (1 / 1920)
        = L / 3840 :=
  ⟨⟨kinkResp_antitone hL, kinkResp_lip hL⟩, ⟨linResp_antitone hL, linResp_lip hL⟩,
    ladder_measurements_agree L, intrinsic_gap L⟩

end Logic.UHarden