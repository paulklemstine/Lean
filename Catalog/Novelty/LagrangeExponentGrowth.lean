/-
# Consequences of concavity: cube–root growth, subadditivity, and the AM–GM equality case

Second research cycle on the Lagrange exponent `σ t = (1 + ∛(27 t - 1)) / 3`
(`Novelty.LagrangeExponentCore`, `Novelty.LagrangeExponentConcavity`).

Having established that `σ` is (strictly) concave exactly on `[1/27, ∞)`, we now extract
the structural consequences that concavity is *for*.

## Main results

* `lagrangeExponent_le_cbrt_add_third` / `cbrt_le_lagrangeExponent` — the **cube–root
  sandwich** `∛t ≤ σ t ≤ ∛t + 1/3` on the physical range (the upper bound holds on all of
  `ℝ`).  So the growth rate is a cube root up to an additive constant `≤ 1/3`, and the
  constant is optimal: the gap is `0` at `t = 1/27` and tends to `1/3`.
* `lagrangeExponent_subadditive_shift` — concavity anchored at the critical point yields
  `σ (s + t - 1/27) + 1/3 ≤ σ s + σ t`: merging two mass distributions is *cheaper* than
  running them separately, once the critical mass is accounted for exactly once.
* `lagrangeExponent_merge_finset` — the `n`-fold merging law, by induction over a finite
  family of admissible masses: `σ (∑ mᵢ - (n-1)/27) + (n-1)/3 ≤ ∑ σ (mᵢ)`.
* `lagrangeExponentOrderIso` — `σ` is an order isomorphism of `ℝ` with inverse the critical
  cubic, hence continuous and cofinal.
* `lagrangeExponent_mass_eq_third_iff` — the **equality case** of the mass bridge: a
  three–point distribution attains the critical exponent `1/3` iff it is uniform.  This
  shows the boundary `1/27` of the concavity region is attained by exactly one
  distribution, so the guard in `lagrangeExponent_concaveOn` is tight, not slack.
-/
import Novelty.LagrangeExponentConcavity

namespace LagrangeExponent

open Set Filter

/-! ## Cube–root growth -/

lemma cbrt_27_mul (t : ℝ) : cbrt (27 * t) = 3 * cbrt t :=
  cbrt_eq_iff.2 (by rw [mul_pow, cbrt_cube]; ring)

/-- Upper bound, valid for **all** real masses: the exponent never exceeds the cube root by
more than `1/3`. -/
theorem lagrangeExponent_le_cbrt_add_third (t : ℝ) : lagrangeExponent t ≤ cbrt t + 1 / 3 := by
  have hmono : cbrt (27 * t - 1) ≤ cbrt (27 * t) := cbrt_strictMono.monotone (by linarith)
  rw [cbrt_27_mul] at hmono
  unfold lagrangeExponent
  linarith

/-- Lower bound on the physical range: the exponent is at least the cube root. -/
theorem cbrt_le_lagrangeExponent {t : ℝ} (ht : 1 / 27 ≤ t) : cbrt t ≤ lagrangeExponent t := by
  set A := cbrt (27 * t - 1) with hA
  have hA0 : 0 ≤ A := by
    have : cbrt 0 ≤ cbrt (27 * t - 1) := cbrt_strictMono.monotone (by linarith)
    simpa [hA] using this
  have hcube : (A + 1) ^ 3 = 27 * t + (3 * A ^ 2 + 3 * A) := by
    have h3 : A ^ 3 = 27 * t - 1 := by rw [hA, cbrt_cube]
    nlinarith [h3]
  have hge : (3 * cbrt t) ^ 3 ≤ (A + 1) ^ 3 := by
    have hct : (cbrt t) ^ 3 = t := cbrt_cube t
    nlinarith [hcube, sq_nonneg A, hA0, hct]
  have : 3 * cbrt t ≤ A + 1 := by
    by_contra hcon
    push_neg at hcon
    have := cube_strictMono hcon
    simp only at this
    linarith
  unfold lagrangeExponent
  linarith

/-- The **cube–root sandwich** on the physical range. -/
theorem lagrangeExponent_sandwich {t : ℝ} (ht : 1 / 27 ≤ t) :
    cbrt t ≤ lagrangeExponent t ∧ lagrangeExponent t ≤ cbrt t + 1 / 3 :=
  ⟨cbrt_le_lagrangeExponent ht, lagrangeExponent_le_cbrt_add_third t⟩

/-- The sandwich is tight at the left endpoint: there the gap `σ t - ∛t` vanishes. -/
theorem lagrangeExponent_sandwich_sharp_at_critical :
    lagrangeExponent (1 / 27 : ℝ) = cbrt (1 / 27 : ℝ) := by
  have h : cbrt (1 / 27 : ℝ) = 1 / 3 := cbrt_eq_iff.2 (by norm_num)
  rw [h, lagrangeExponent_critical]

/-! ## Subadditivity from concavity anchored at the critical mass -/

/-- **Merging masses.** Concavity anchored at the critical point `(1/27, 1/3)` gives
`σ (s + t - 1/27) + 1/3 ≤ σ s + σ t` for admissible masses `s, t`. -/
theorem lagrangeExponent_subadditive_shift {s t : ℝ} (hs : 1 / 27 ≤ s) (ht : 1 / 27 ≤ t) :
    lagrangeExponent (s + t - 1 / 27) + 1 / 3 ≤ lagrangeExponent s + lagrangeExponent t := by
  rcases eq_or_lt_of_le (by linarith : (0:ℝ) ≤ s + t - 2 / 27) with hzero | hD
  · -- degenerate case: both masses are exactly critical
    have hs' : s = 1 / 27 := by linarith
    have ht' : t = 1 / 27 := by linarith
    subst hs'; subst ht'
    norm_num [lagrangeExponent_critical]
  · have hDne : s + t - 2 / 27 ≠ 0 := ne_of_gt hD
    obtain ⟨a, ha⟩ : ∃ a : ℝ, a = (s - 1 / 27) / (s + t - 2 / 27) := ⟨_, rfl⟩
    obtain ⟨b, hb⟩ : ∃ b : ℝ, b = (t - 1 / 27) / (s + t - 2 / 27) := ⟨_, rfl⟩
    have ha0 : 0 ≤ a := ha ▸ div_nonneg (by linarith) hD.le
    have hb0 : 0 ≤ b := hb ▸ div_nonneg (by linarith) hD.le
    have hab : a + b = 1 := by
      rw [ha, hb, ← add_div, div_eq_one_iff_eq hDne]; ring
    have hmemX : s + t - 1 / 27 ∈ Ici (1 / 27 : ℝ) := mem_Ici.2 (by linarith)
    have hmemC : (1 / 27 : ℝ) ∈ Ici (1 / 27 : ℝ) := mem_Ici.2 le_rfl
    have h1 := lagrangeExponent_concaveOn.2 hmemX hmemC ha0 hb0 hab
    have h2 := lagrangeExponent_concaveOn.2 hmemX hmemC hb0 ha0 (by linarith)
    simp only [smul_eq_mul] at h1 h2
    have e1 : a * (s + t - 1 / 27) + b * (1 / 27) = s := by
      rw [ha, hb, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hDne]; ring
    have e2 : b * (s + t - 1 / 27) + a * (1 / 27) = t := by
      rw [ha, hb, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hDne]; ring
    rw [e1] at h1
    rw [e2] at h2
    rw [lagrangeExponent_critical] at h1 h2
    have hb1 : b = 1 - a := by linarith
    rw [hb1] at h1 h2
    have hcancel : a * lagrangeExponent (s + t - 1 / 27)
        + (1 - a) * lagrangeExponent (s + t - 1 / 27) = lagrangeExponent (s + t - 1 / 27) := by
      ring
    linarith [h1, h2, hcancel]

/-- Admissible masses have total mass at least `card / 27`. -/
lemma sum_ge_card_div_27 {ι : Type*} (T : Finset ι) (m : ι → ℝ)
    (hm : ∀ i ∈ T, (1 : ℝ) / 27 ≤ m i) : (T.card : ℝ) / 27 ≤ ∑ i ∈ T, m i := by
  have := Finset.card_nsmul_le_sum T m (1 / 27) hm
  simpa [nsmul_eq_mul, div_eq_mul_inv, mul_comm] using this

/-- **`n`-fold merging law.** Iterating the merging inequality over a finite family of
admissible masses: the critical mass is paid exactly once. -/
theorem lagrangeExponent_merge_finset {ι : Type*} {T : Finset ι} (hT : T.Nonempty) (m : ι → ℝ)
    (hm : ∀ i ∈ T, (1 : ℝ) / 27 ≤ m i) :
    lagrangeExponent ((∑ i ∈ T, m i) - ((T.card : ℝ) - 1) / 27) + ((T.card : ℝ) - 1) / 3
      ≤ ∑ i ∈ T, lagrangeExponent (m i) := by
  revert hm
  induction hT using Finset.Nonempty.cons_induction with
  | singleton a =>
    intro _
    simp only [Finset.sum_singleton, Finset.card_singleton, Nat.cast_one]
    norm_num
  | cons a s hnotmem hs ih =>
    intro hm
    have hma : (1 : ℝ) / 27 ≤ m a := hm a (by simp)
    have hms : ∀ i ∈ s, (1 : ℝ) / 27 ≤ m i := fun i hi => hm i (by simp [hi])
    have ihs := ih hms
    have hcard : (0 : ℝ) < (s.card : ℝ) := by
      exact_mod_cast Finset.card_pos.2 hs
    have hsum : ((s.card : ℝ)) / 27 ≤ ∑ i ∈ s, m i := sum_ge_card_div_27 s m hms
    have hrest : (1 : ℝ) / 27 ≤ (∑ i ∈ s, m i) - ((s.card : ℝ) - 1) / 27 := by
      linarith
    have hmerge := lagrangeExponent_subadditive_shift hma hrest
    have harg : m a + ((∑ i ∈ s, m i) - ((s.card : ℝ) - 1) / 27) - 1 / 27
        = (m a + ∑ i ∈ s, m i) - ((s.card : ℝ) + 1 - 1) / 27 := by ring
    rw [harg] at hmerge
    rw [Finset.sum_cons, Finset.sum_cons, Finset.card_cons]
    push_cast
    linarith [hmerge, ihs]

/-! ## `σ` as an order isomorphism of the mass line -/

/-- The Lagrange exponent is an order isomorphism of `ℝ`, with inverse the critical cubic. -/
noncomputable def lagrangeExponentOrderIso : ℝ ≃o ℝ where
  toFun := lagrangeExponent
  invFun := lagrangeCubic
  left_inv := lagrangeCubic_lagrangeExponent
  right_inv := lagrangeExponent_lagrangeCubic
  map_rel_iff' := lagrangeExponent_strictMono.le_iff_le

@[simp] lemma lagrangeExponentOrderIso_apply (t : ℝ) : lagrangeExponentOrderIso t =
    lagrangeExponent t := rfl

/-- `σ` is continuous (an order isomorphism of a linear order with the order topology). -/
theorem lagrangeExponent_continuous : Continuous lagrangeExponent :=
  lagrangeExponentOrderIso.continuous

/-- `σ` is surjective: every growth rate is realised by some mass. -/
theorem lagrangeExponent_surjective : Function.Surjective lagrangeExponent :=
  lagrangeExponentOrderIso.surjective

/-! ## Equality case of the mass bridge -/

/-- Equality in AM–GM for three masses forces the uniform distribution. -/
theorem three_mass_prod_eq_inv27_iff {p q r : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) (hr : 0 ≤ r)
    (h : p + q + r = 1) : p * q * r = 1 / 27 ↔ p = 1 / 3 ∧ q = 1 / 3 ∧ r = 1 / 3 := by
  constructor
  · intro he
    have hp' : p = 1 / 3 := by
      nlinarith [sq_nonneg (p - q), sq_nonneg (q - r), sq_nonneg (p - r), sq_nonneg (3 * p - 1),
        mul_nonneg hq hr, mul_nonneg hp hq, mul_nonneg hp hr, sq_nonneg (q + r - 2 / 3)]
    have hq' : q = 1 / 3 := by
      nlinarith [sq_nonneg (p - q), sq_nonneg (q - r), sq_nonneg (p - r), sq_nonneg (3 * q - 1),
        mul_nonneg hq hr, mul_nonneg hp hq, mul_nonneg hp hr, sq_nonneg (p + r - 2 / 3)]
    exact ⟨hp', hq', by linarith⟩
  · rintro ⟨hp', hq', hr'⟩
    subst hp'; subst hq'; subst hr'; norm_num

/-- **Tightness of the guard `1/27`.** A three–point mass distribution reaches the critical
exponent `1/3` if and only if it is uniform; every other distribution sits strictly inside
the convex (sub–critical) regime. -/
theorem lagrangeExponent_mass_eq_third_iff {p q r : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) (hr : 0 ≤ r)
    (h : p + q + r = 1) :
    lagrangeExponent (p * q * r) = 1 / 3 ↔ p = 1 / 3 ∧ q = 1 / 3 ∧ r = 1 / 3 := by
  rw [← three_mass_prod_eq_inv27_iff hp hq hr h]
  constructor
  · intro he
    have : lagrangeExponent (p * q * r) = lagrangeExponent (1 / 27) := by
      rw [he, lagrangeExponent_critical]
    exact lagrangeExponent_injective this
  · intro he; rw [he, lagrangeExponent_critical]

/-- Any non-uniform three–point distribution has a *strictly* sub-critical exponent. -/
theorem lagrangeExponent_mass_lt_third {p q r : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) (hr : 0 ≤ r)
    (h : p + q + r = 1) (hne : ¬ (p = 1 / 3 ∧ q = 1 / 3 ∧ r = 1 / 3)) :
    lagrangeExponent (p * q * r) < 1 / 3 := by
  have hle := lagrangeExponent_mass_prod_le_third hp hq hr h
  rcases lt_or_eq_of_le hle with h1 | h1
  · exact h1
  · exact absurd ((lagrangeExponent_mass_eq_third_iff hp hq hr h).1 h1) hne

end LagrangeExponent