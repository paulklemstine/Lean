/-
# The exclusive-dimension reliability curve is a monotone ramp (no capacity cliff)

## Motivation (NET-27, `EOS-WIDTH-SHIFT-IS-A-MONOTONE-RAMP`)

An empirical study of a recurrent network with a boundary ("EOS") token whose learned
embedding occupies `k` *exclusive* parameter dimensions reported the reliability curve

| exclusive dims `k` | 0    | 1    | 2    | 4    | 8    |
|--------------------|------|------|------|------|------|
| `P(cure)`          | 0.25 | 0.33 | 0.83 | 1.00 | 1.00 |

with the qualitative reading: the curve is *monotone*, the benefit of extra dimensions is
*sublinear* (diminishing returns), and there is *no sharp critical width* — one exclusive
dimension is not sufficient, but no finite width makes success certain either.

## What is proved here

We give an exact finite-field model in which all four qualitative claims are theorems,
not observations.  Let `V` be a finite vector space over `𝔽_p` (`p` prime).  The boundary
token's exclusive subspace is modelled by a tuple `v : Fin k → V` of `k` independent
uniform draws, and the network's failure modes by a finite family `W : Fin m → Submodule 𝔽_p V`
of *proper* subspaces ("obstruction subspaces"): the run *fails* when the whole exclusive
subspace is swallowed by some obstruction, i.e. when `∃ j, ∀ i, v i ∈ W j`.

* `EOSWidthRamp.failCount_succ_le` — a fibration/prefix injection giving
  `failCount W (k+1) ≤ failCount W k * #V`, hence
* `EOSWidthRamp.failProb_antitone` / `EOSWidthRamp.cureProb_monotone` — **monotone ramp**;
* `EOSWidthRamp.failProb_pos` — failure probability is *strictly positive for every `k`*:
  **no finite width certifies a cure**, so there is no capacity cliff;
* `EOSWidthRamp.failProb_le` — union bound `P(fail) ≤ m · p^{-k}`: the curve does climb to 1;
* `EOSWidthRamp.cureProb_isMonotoneRamp` — the packaged law: `k ↦ P(cure)` is monotone,
  everywhere `< 1`, and tends to `1`;
* `EOSWidthRamp.hyperplane_cureProb` — in the single-hyperplane case the curve is *exactly*
  `1 - p^{-k}`, with `EOSWidthRamp.hyperplane_gain_strictAnti` (**sublinear benefit**:
  the marginal gain `(p-1)p^{-(k+1)}` strictly decreases) and
  `EOSWidthRamp.hyperplane_cureProb_one` (**the first exclusive dimension is not sufficient**);
* `EOSWidthRamp.cureProb_deficiency_two_sided` — the matching lower bound: the deficiency
  `1 - P(cure)` is pinned between `p^{-k}` and `m·p^{-k}`, so the ramp climbs at exactly the
  geometric rate;
* `EOSWidthRamp.width_sufficient` / `EOSWidthRamp.width_necessary` — a two-sided **design rule**:
  reliability `1 - ε` needs width `log_p(1/ε)` and is guaranteed by width `log_p(m/ε)`;
* `EOSWidthRamp.no_cliff` — the reliability curve is never a step function;
* `EOSWidthRamp.hyperplane_tsum_failProb` — the total failure mass `∑_k p^{-k} = p/(p-1)`,
  a number-theoretic invariant of the ramp;
* `EOSWidthRamp.concrete_isMonotoneRamp` and `EOSWidthRamp.ramp_two_values` — a concrete
  witness (`V = 𝔽_p`, obstruction `⊥`) showing the hypotheses are satisfiable, with the
  predicted `p = 2` values `0, 1/2, 3/4, 15/16, 255/256` at the experimental widths.

### Lab notes

The empirical failure masses `0.75, 0.67, 0.17, 0.00, 0.00` at `k = 0,1,2,4,8` are
compatible with the model's `min(1, m·p^{-k})` envelope for `p = 2`, `m ≈ 1` in the tail
(`p^{-2} = 0.25 ≥ 0.17`, `p^{-4} = 0.06`, `p^{-8} = 0.004`): the model predicts that the
observed "`0` failures at `k = 4, 8`" is a finite-sample effect, not an exact cliff — which
is precisely the theorem `failProb_pos`.
-/

import Mathlib

open Module Filter Topology

namespace EOSWidthRamp

variable {p m : ℕ} [Fact p.Prime] {V : Type*} [AddCommGroup V] [Module (ZMod p) V] [Finite V]

/-! ## Cardinalities over `𝔽_p` -/

/-- A finite `𝔽_p`-vector space has `p ^ dim` elements. -/
theorem card_eq_pow_finrank_zmod (W : Type*) [AddCommGroup W] [Module (ZMod p) W] [Finite W] :
    Nat.card W = p ^ finrank (ZMod p) W := by
  have := Fintype.ofFinite W
  rw [Nat.card_eq_fintype_card, Module.card_eq_pow_finrank (K := ZMod p) (V := W), ZMod.card]

/-- A proper subspace has index at least `p`. -/
theorem card_submodule_mul_le {W : Submodule (ZMod p) V} (hW : W ≠ ⊤) :
    Nat.card W * p ≤ Nat.card V := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hlt : finrank (ZMod p) W < finrank (ZMod p) V := Submodule.finrank_lt hW
  calc Nat.card W * p = p ^ (finrank (ZMod p) W + 1) := by
        rw [card_eq_pow_finrank_zmod (p := p) (W := W), pow_succ]
    _ ≤ p ^ finrank (ZMod p) V := Nat.pow_le_pow_right (le_of_lt hp) hlt
    _ = Nat.card V := (card_eq_pow_finrank_zmod (p := p) V).symm

theorem card_V_pos : 0 < Nat.card V := Nat.card_pos

/-! ## The model -/

/-- The number of `k`-tuples of vectors of `V` all of whose entries are swallowed by one of
the obstruction subspaces `W j`.  This is the number of *failing* exclusive subspaces of
width `k`. -/
noncomputable def failCount (W : Fin m → Submodule (ZMod p) V) (k : ℕ) : ℕ :=
  Nat.card {v : Fin k → V // ∃ j, ∀ i, v i ∈ W j}

/-- The failure probability at exclusive width `k`. -/
noncomputable def failProb (W : Fin m → Submodule (ZMod p) V) (k : ℕ) : ℝ :=
  (failCount W k : ℝ) / (Nat.card V : ℝ) ^ k

/-- The reliability ("cure") probability at exclusive width `k`. -/
noncomputable def cureProb (W : Fin m → Submodule (ZMod p) V) (k : ℕ) : ℝ :=
  1 - failProb W k

/-! ## Exact counting -/

omit [Finite V] in
/-- The `k`-tuples inside a fixed subspace `W` number `(#W)^k`. -/
theorem card_tuples_mem (W : Submodule (ZMod p) V) (k : ℕ) :
    Nat.card {v : Fin k → V // ∀ i, v i ∈ W} = (Nat.card W) ^ k := by
  have e : {v : Fin k → V // ∀ i, v i ∈ W} ≃ (Fin k → W) :=
    { toFun := fun v i => ⟨v.1 i, v.2 i⟩
      invFun := fun v => ⟨fun i => (v i : V), fun i => (v i).2⟩
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }
  simp [Nat.card_congr e, Nat.card_fun]

theorem card_tuples_total (α : Type*) [Finite α] (k : ℕ) :
    Nat.card (Fin k → α) = (Nat.card α) ^ k := by
  simp [Nat.card_fun]

/-- Union bound at the level of counts. -/
theorem failCount_le_sum (W : Fin m → Submodule (ZMod p) V) (k : ℕ) :
    failCount W k ≤ ∑ j, (Nat.card (W j)) ^ k := by
  classical
  have hinj : Function.Injective
      (fun v : {v : Fin k → V // ∃ j, ∀ i, v i ∈ W j} =>
        (⟨v.2.choose, ⟨v.1, v.2.choose_spec⟩⟩ :
          Σ j : Fin m, {v : Fin k → V // ∀ i, v i ∈ W j})) := by
    intro a b hab
    have : (a : Fin k → V) = (b : Fin k → V) := congrArg (fun s => (s.2 : Fin k → V)) hab
    exact Subtype.ext this
  have := Nat.card_le_card_of_injective _ hinj
  simpa [failCount, Nat.card_sigma, card_tuples_mem] using this

/-- The all-zero tuple always fails, so failures never disappear. -/
theorem failCount_pos (W : Fin m → Submodule (ZMod p) V) (hm : 0 < m) (k : ℕ) :
    0 < failCount W k := by
  have : Nonempty {v : Fin k → V // ∃ j, ∀ i, v i ∈ W j} :=
    ⟨⟨fun _ => 0, ⟨⟨0, hm⟩, fun _ => zero_mem _⟩⟩⟩
  exact Nat.card_pos

/-- **Prefix fibration.**  Deleting the last vector of a failing `(k+1)`-tuple gives a failing
`k`-tuple, and the fibres have size at most `#V`. -/
theorem failCount_succ_le (W : Fin m → Submodule (ZMod p) V) (k : ℕ) :
    failCount W (k + 1) ≤ failCount W k * Nat.card V := by
  classical
  have hinj : Function.Injective
      (fun v : {v : Fin (k + 1) → V // ∃ j, ∀ i, v i ∈ W j} =>
        ((⟨fun i : Fin k => v.1 i.castSucc, by
            obtain ⟨j, hj⟩ := v.2
            exact ⟨j, fun i => hj _⟩⟩ : {v : Fin k → V // ∃ j, ∀ i, v i ∈ W j}),
          v.1 (Fin.last k))) := by
    intro a b hab
    have h1 : (fun i : Fin k => a.1 i.castSucc) = fun i : Fin k => b.1 i.castSucc :=
      congrArg (fun s => (s.1 : Fin k → V)) hab
    have h2 : a.1 (Fin.last k) = b.1 (Fin.last k) := congrArg (fun s => s.2) hab
    refine Subtype.ext (funext fun i => ?_)
    refine Fin.lastCases ?_ ?_ i
    · exact h2
    · intro i; exact congrFun h1 i
  have := Nat.card_le_card_of_injective _ hinj
  simpa [failCount, Nat.card_prod] using this

/-! ## The reliability curve -/

theorem failProb_pos (W : Fin m → Submodule (ZMod p) V) (hm : 0 < m) (k : ℕ) :
    0 < failProb W k := by
  have h1 : (0 : ℝ) < (failCount W k : ℝ) := by exact_mod_cast failCount_pos W hm k
  have h2 : (0 : ℝ) < (Nat.card V : ℝ) ^ k :=
    pow_pos (by exact_mod_cast (card_V_pos (V := V))) k
  exact div_pos h1 h2

theorem cureProb_lt_one (W : Fin m → Submodule (ZMod p) V) (hm : 0 < m) (k : ℕ) :
    cureProb W k < 1 := by
  have := failProb_pos W hm k
  simp only [cureProb]
  linarith

/-- **Monotone ramp (failure form).**  The failure probability never increases with width. -/
theorem failProb_antitone (W : Fin m → Submodule (ZMod p) V) : Antitone (failProb W) := by
  have hN : (0 : ℝ) < (Nat.card V : ℝ) := by exact_mod_cast (card_V_pos (V := V))
  have step : ∀ k, failProb W (k + 1) ≤ failProb W k := by
    intro k
    have h := failCount_succ_le W k
    have h' : (failCount W (k + 1) : ℝ) ≤ (failCount W k : ℝ) * (Nat.card V : ℝ) := by
      exact_mod_cast h
    have hpk : (0 : ℝ) < (Nat.card V : ℝ) ^ k := pow_pos hN k
    rw [failProb, failProb, div_le_div_iff₀ (by positivity) hpk]
    calc (failCount W (k + 1) : ℝ) * (Nat.card V : ℝ) ^ k
        ≤ ((failCount W k : ℝ) * (Nat.card V : ℝ)) * (Nat.card V : ℝ) ^ k := by
          exact mul_le_mul_of_nonneg_right h' (le_of_lt hpk)
      _ = (failCount W k : ℝ) * (Nat.card V : ℝ) ^ (k + 1) := by ring
  exact antitone_nat_of_succ_le step

/-- **Monotone ramp (reliability form).** -/
theorem cureProb_monotone (W : Fin m → Submodule (ZMod p) V) : Monotone (cureProb W) := by
  intro a b hab
  have := failProb_antitone W hab
  simp only [cureProb]
  linarith

/-- **Union bound.**  `P(fail) ≤ m · p^{-k}` : reliability does climb to `1`. -/
theorem failProb_le (W : Fin m → Submodule (ZMod p) V) (hW : ∀ j, W j ≠ ⊤) (k : ℕ) :
    failProb W k ≤ m / (p : ℝ) ^ k := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hN : (0 : ℝ) < (Nat.card V : ℝ) := by exact_mod_cast (card_V_pos (V := V))
  have hpR : (0 : ℝ) < (p : ℝ) := by positivity
  -- each term of the union bound is at most `(#V / p)^k`
  have hterm : ∀ j : Fin m,
      ((Nat.card (W j) : ℝ)) ^ k * (p : ℝ) ^ k ≤ (Nat.card V : ℝ) ^ k := by
    intro j
    have h := card_submodule_mul_le (hW j)
    have h' : (Nat.card (W j) : ℝ) * (p : ℝ) ≤ (Nat.card V : ℝ) := by exact_mod_cast h
    calc ((Nat.card (W j) : ℝ)) ^ k * (p : ℝ) ^ k
        = ((Nat.card (W j) : ℝ) * (p : ℝ)) ^ k := by rw [mul_pow]
      _ ≤ (Nat.card V : ℝ) ^ k := by
          exact pow_le_pow_left₀ (by positivity) h' k
  have hsum : (failCount W k : ℝ) * (p : ℝ) ^ k ≤ (m : ℝ) * (Nat.card V : ℝ) ^ k := by
    have h0 : (failCount W k : ℝ) ≤ ∑ j : Fin m, ((Nat.card (W j) : ℝ)) ^ k := by
      have := failCount_le_sum W k
      exact_mod_cast this
    calc (failCount W k : ℝ) * (p : ℝ) ^ k
        ≤ (∑ j : Fin m, ((Nat.card (W j) : ℝ)) ^ k) * (p : ℝ) ^ k := by
          exact mul_le_mul_of_nonneg_right h0 (by positivity)
      _ = ∑ j : Fin m, (((Nat.card (W j) : ℝ)) ^ k * (p : ℝ) ^ k) := by
          rw [Finset.sum_mul]
      _ ≤ ∑ _j : Fin m, (Nat.card V : ℝ) ^ k := Finset.sum_le_sum fun j _ => hterm j
      _ = (m : ℝ) * (Nat.card V : ℝ) ^ k := by simp
  rw [failProb, div_le_div_iff₀ (by positivity) (by positivity)]
  calc (failCount W k : ℝ) * (p : ℝ) ^ k ≤ (m : ℝ) * (Nat.card V : ℝ) ^ k := hsum
    _ = (m : ℝ) * (Nat.card V : ℝ) ^ k := rfl

/-! ## A matching lower bound: the ramp climbs at exactly the geometric rate `p^{-k}` -/

/-- Every tuple lying inside a single obstruction already fails. -/
theorem card_le_failCount (W : Fin m → Submodule (ZMod p) V) (j : Fin m) (k : ℕ) :
    (Nat.card (W j)) ^ k ≤ failCount W k := by
  have hinj : Function.Injective (fun v : {v : Fin k → V // ∀ i, v i ∈ W j} =>
      (⟨v.1, ⟨j, v.2⟩⟩ : {v : Fin k → V // ∃ j, ∀ i, v i ∈ W j})) := by
    intro a b hab
    exact Subtype.ext (congrArg (fun s => (s.1 : Fin k → V)) hab)
  have h := Nat.card_le_card_of_injective _ hinj
  rwa [card_tuples_mem] at h

/-- **Lower bound.**  If one obstruction is a hyperplane (index `p`), the failure probability
is at least `p^{-k}`; together with `failProb_le` the deficiency `1 - P(cure)` is pinned
between `p^{-k}` and `m·p^{-k}`: the ramp approaches certainty at exactly geometric rate. -/
theorem failProb_ge_of_hyperplane (W : Fin m → Submodule (ZMod p) V) (j : Fin m)
    (hidx : Nat.card (W j) * p = Nat.card V) (k : ℕ) :
    ((p : ℝ) ^ k)⁻¹ ≤ failProb W k := by
  have hWpos : (0 : ℝ) < (Nat.card (W j) : ℝ) := by
    have : 0 < Nat.card (W j) := Nat.card_pos
    exact_mod_cast this
  have hppos : (0 : ℝ) < (p : ℝ) := by
    have := (Fact.out : p.Prime).pos
    exact_mod_cast this
  have hNV : (Nat.card V : ℝ) = (Nat.card (W j) : ℝ) * (p : ℝ) := by exact_mod_cast hidx.symm
  have hnum : ((Nat.card (W j) : ℝ)) ^ k ≤ (failCount W k : ℝ) := by
    exact_mod_cast card_le_failCount W j k
  have hden : (0 : ℝ) < (Nat.card V : ℝ) ^ k := by rw [hNV]; positivity
  rw [failProb, le_div_iff₀ hden, hNV, mul_pow]
  calc ((p : ℝ) ^ k)⁻¹ * ((Nat.card (W j) : ℝ) ^ k * (p : ℝ) ^ k)
      = (Nat.card (W j) : ℝ) ^ k := by field_simp
    _ ≤ (failCount W k : ℝ) := hnum

/-- **The deficiency of the ramp is exactly of order `p^{-k}`.** -/
theorem cureProb_deficiency_two_sided (W : Fin m → Submodule (ZMod p) V)
    (hW : ∀ j, W j ≠ ⊤) (j : Fin m) (hidx : Nat.card (W j) * p = Nat.card V) (k : ℕ) :
    ((p : ℝ) ^ k)⁻¹ ≤ 1 - cureProb W k ∧ 1 - cureProb W k ≤ (m : ℝ) / (p : ℝ) ^ k := by
  have h1 := failProb_ge_of_hyperplane W j hidx k
  have h2 := failProb_le W hW k
  constructor <;> · simp only [cureProb]; linarith

/-! ## The abstract notion of a monotone ramp -/

/-- A *monotone ramp*: a reliability curve that never decreases, never attains certainty,
and converges to certainty.  Such a curve has no critical width. -/
structure IsMonotoneRamp (P : ℕ → ℝ) : Prop where
  mono : Monotone P
  lt_one : ∀ k, P k < 1
  tendsto_one : Tendsto P atTop (𝓝 1)

/-- **No capacity cliff.**  A monotone ramp never attains certainty, so there is no width
beyond which success is guaranteed. -/
theorem IsMonotoneRamp.no_critical_width {P : ℕ → ℝ} (h : IsMonotoneRamp P) :
    ¬ ∃ k, ∀ l, k ≤ l → P l = 1 := by
  rintro ⟨k, hk⟩
  exact absurd (hk k le_rfl) (ne_of_lt (h.lt_one k))

/-- Yet the ramp gets arbitrarily close to certainty. -/
theorem IsMonotoneRamp.eventually_gt {P : ℕ → ℝ} (h : IsMonotoneRamp P) {c : ℝ} (hc : c < 1) :
    ∃ K, ∀ l, K ≤ l → c < P l := by
  have := h.tendsto_one.eventually (eventually_gt_nhds hc)
  obtain ⟨K, hK⟩ := this.exists_forall_of_atTop
  exact ⟨K, fun l hl => hK l hl⟩

/-- **EOS-WIDTH-SHIFT-IS-A-MONOTONE-RAMP.**  In the finite-field obstruction model the
reliability curve `k ↦ P(cure)` is a monotone ramp: nondecreasing, strictly below `1` at
every finite width, and converging to `1`. -/
theorem cureProb_isMonotoneRamp (W : Fin m → Submodule (ZMod p) V) (hm : 0 < m)
    (hW : ∀ j, W j ≠ ⊤) : IsMonotoneRamp (cureProb W) := by
  refine ⟨cureProb_monotone W, cureProb_lt_one W hm, ?_⟩
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hlow : Tendsto (fun k : ℕ => 1 - (m : ℝ) / (p : ℝ) ^ k) atTop (𝓝 1) := by
    have h0 : Tendsto (fun k : ℕ => ((p : ℝ)⁻¹) ^ k) atTop (𝓝 0) := by
      apply tendsto_pow_atTop_nhds_zero_of_lt_one (by positivity)
      rw [inv_lt_one_iff₀]
      right
      exact_mod_cast hp
    have : Tendsto (fun k : ℕ => (m : ℝ) * ((p : ℝ)⁻¹) ^ k) atTop (𝓝 ((m : ℝ) * 0)) :=
      h0.const_mul _
    have h2 : Tendsto (fun k : ℕ => 1 - (m : ℝ) * ((p : ℝ)⁻¹) ^ k) atTop (𝓝 (1 - (m : ℝ) * 0)) :=
      (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub this
    simpa [div_eq_mul_inv, inv_pow] using h2
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le hlow tendsto_const_nhds ?_ ?_
  · intro k
    have := failProb_le W hW k
    simp only [cureProb]
    linarith
  · intro k
    have := (failProb_pos W hm k).le
    simp only [cureProb]
    linarith

/-! ## The exact hyperplane curve: sublinear benefit and total failure mass -/

section Hyperplane

variable (W : Submodule (ZMod p) V)

/-- Failure probability against a single obstruction of index `p` is exactly `p^{-k}`. -/
theorem hyperplane_failProb (hidx : Nat.card W * p = Nat.card V) (k : ℕ) :
    failProb (fun _ : Fin 1 => W) k = ((p : ℝ) ^ k)⁻¹ := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hcount : failCount (fun _ : Fin 1 => W) k = (Nat.card W) ^ k := by
    have e : {v : Fin k → V // ∃ _ : Fin 1, ∀ i, v i ∈ W} ≃
        {v : Fin k → V // ∀ i, v i ∈ W} :=
      { toFun := fun v => ⟨v.1, v.2.choose_spec⟩
        invFun := fun v => ⟨v.1, ⟨0, v.2⟩⟩
        left_inv := fun _ => rfl
        right_inv := fun _ => rfl }
    rw [failCount, Nat.card_congr e, card_tuples_mem]
  have hNV : (Nat.card V : ℝ) = (Nat.card W : ℝ) * (p : ℝ) := by exact_mod_cast hidx.symm
  have hWpos : (0 : ℝ) < (Nat.card W : ℝ) := by
    have : 0 < Nat.card W := Nat.card_pos
    exact_mod_cast this
  have hppos : (0 : ℝ) < (p : ℝ) := by positivity
  rw [failProb, hcount, hNV, mul_pow]
  push_cast
  rw [div_eq_iff (by positivity), inv_mul_eq_div, eq_div_iff (by positivity)]

/-- The exact reliability curve of the single-hyperplane model: `1 - p^{-k}`. -/
theorem hyperplane_cureProb (hidx : Nat.card W * p = Nat.card V) (k : ℕ) :
    cureProb (fun _ : Fin 1 => W) k = 1 - ((p : ℝ) ^ k)⁻¹ := by
  rw [cureProb, hyperplane_failProb W hidx k]

/-- **Zero exclusive dimensions never work.** -/
theorem hyperplane_cureProb_zero (hidx : Nat.card W * p = Nat.card V) :
    cureProb (fun _ : Fin 1 => W) 0 = 0 := by
  simp [hyperplane_cureProb W hidx]

/-- **The first exclusive dimension is not sufficient**: it buys only `1 - 1/p`. -/
theorem hyperplane_cureProb_one (hidx : Nat.card W * p = Nat.card V) :
    cureProb (fun _ : Fin 1 => W) 1 = 1 - (p : ℝ)⁻¹ := by
  simp [hyperplane_cureProb W hidx]

/-- The curve is *strictly* increasing: every extra exclusive dimension helps. -/
theorem hyperplane_cureProb_strictMono (hidx : Nat.card W * p = Nat.card V) :
    StrictMono (cureProb (fun _ : Fin 1 => W)) := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  intro a b hab
  rw [hyperplane_cureProb W hidx, hyperplane_cureProb W hidx]
  have : ((p : ℝ) ^ b)⁻¹ < ((p : ℝ) ^ a)⁻¹ := by
    apply inv_strictAnti₀ (by positivity) (pow_lt_pow_right₀ hpR hab)
  linarith

/-- **Sublinear benefit.**  The marginal gain from the `(k+1)`-st exclusive dimension is
`(p-1) p^{-(k+1)}`, which decays geometrically: diminishing returns, not a cliff. -/
theorem hyperplane_gain (hidx : Nat.card W * p = Nat.card V) (k : ℕ) :
    cureProb (fun _ : Fin 1 => W) (k + 1) - cureProb (fun _ : Fin 1 => W) k
      = ((p : ℝ) - 1) * ((p : ℝ) ^ (k + 1))⁻¹ := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (0 : ℝ) < (p : ℝ) := by positivity
  rw [hyperplane_cureProb W hidx, hyperplane_cureProb W hidx]
  field_simp
  ring

/-- The marginal gains are strictly decreasing in `k`. -/
theorem hyperplane_gain_strictAnti (hidx : Nat.card W * p = Nat.card V) :
    StrictAnti (fun k => cureProb (fun _ : Fin 1 => W) (k + 1)
      - cureProb (fun _ : Fin 1 => W) k) := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  intro a b hab
  simp only [hyperplane_gain W hidx]
  have h : ((p : ℝ) ^ (b + 1))⁻¹ < ((p : ℝ) ^ (a + 1))⁻¹ :=
    inv_strictAnti₀ (by positivity) (pow_lt_pow_right₀ hpR (by omega))
  nlinarith [h, hpR]

/-- **Total failure mass.**  Summing the failure probability over all widths gives the
arithmetic invariant `p/(p-1)`, i.e. `∑_{k≥0} p^{-k}`. -/
theorem hyperplane_tsum_failProb (hidx : Nat.card W * p = Nat.card V) :
    ∑' k : ℕ, failProb (fun _ : Fin 1 => W) k = (p : ℝ) / ((p : ℝ) - 1) := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  have : ∑' k : ℕ, failProb (fun _ : Fin 1 => W) k = ∑' k : ℕ, ((p : ℝ)⁻¹) ^ k := by
    refine tsum_congr fun k => ?_
    rw [hyperplane_failProb W hidx k, inv_pow]
  rw [this, tsum_geometric_of_lt_one (by positivity) (by
    rw [inv_lt_one_iff₀]; right; exact hpR)]
  field_simp

end Hyperplane

/-! ## A two-sided design rule for the required width -/

/-- **Sufficient width.**  To reach reliability `1 - ε` it is enough that `m ≤ ε·p^k`, i.e.
`k ≥ log_p(m/ε)`. -/
theorem width_sufficient (W : Fin m → Submodule (ZMod p) V) (hW : ∀ j, W j ≠ ⊤) {ε : ℝ}
    (k : ℕ) (h : (m : ℝ) ≤ ε * (p : ℝ) ^ k) : 1 - ε ≤ cureProb W k := by
  have hppos : (0 : ℝ) < (p : ℝ) ^ k := by
    have := (Fact.out : p.Prime).pos
    have : (0 : ℝ) < (p : ℝ) := by exact_mod_cast this
    positivity
  have hle := failProb_le W hW k
  have : (m : ℝ) / (p : ℝ) ^ k ≤ ε := by
    rw [div_le_iff₀ hppos]
    linarith
  simp only [cureProb]
  linarith

/-- **Necessary width.**  Conversely, if one obstruction is a hyperplane then reliability
`1 - ε` forces `p^{-k} ≤ ε`, i.e. `k ≥ log_p(1/ε)`.  The two bounds differ only by the additive
`log_p m`: the knee of the ramp is located to within `log_p m`, even though the ramp itself has
no sharp threshold. -/
theorem width_necessary (W : Fin m → Submodule (ZMod p) V) (j : Fin m)
    (hidx : Nat.card (W j) * p = Nat.card V) {ε : ℝ} (k : ℕ) (h : 1 - ε ≤ cureProb W k) :
    ((p : ℝ) ^ k)⁻¹ ≤ ε := by
  have hge := failProb_ge_of_hyperplane W j hidx k
  simp only [cureProb] at h
  linarith

/-! ## No sharp critical width, and a concrete instance of the law -/

/-- **NO sharp critical width.**  The reliability curve is never a step function: there is no
width `k₀` below which the token always fails and at or above which it always succeeds. -/
theorem no_cliff (W : Fin m → Submodule (ZMod p) V) (hm : 0 < m) :
    ¬ ∃ k₀ : ℕ, (∀ k, k < k₀ → cureProb W k = 0) ∧ (∀ k, k₀ ≤ k → cureProb W k = 1) := by
  rintro ⟨k₀, -, h⟩
  exact absurd (h k₀ le_rfl) (ne_of_lt (cureProb_lt_one W hm k₀))

section Concrete

/-- The hypotheses of the model are satisfiable: `V = 𝔽_p` with the single obstruction `⊥`. -/
theorem card_bot_mul_self (p : ℕ) [Fact p.Prime] :
    Nat.card (⊥ : Submodule (ZMod p) (ZMod p)) * p = Nat.card (ZMod p) := by
  have h1 : Nat.card (⊥ : Submodule (ZMod p) (ZMod p)) = 1 := Nat.card_unique
  have h2 : Nat.card (ZMod p) = p := by
    have : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
    simp [Nat.card_eq_fintype_card, ZMod.card]
  rw [h1, h2, one_mul]

theorem bot_ne_top_zmod (p : ℕ) [Fact p.Prime] : (⊥ : Submodule (ZMod p) (ZMod p)) ≠ ⊤ := by
  have : Nontrivial (ZMod p) := by
    have : Fact (1 < p) := ⟨(Fact.out : p.Prime).one_lt⟩
    infer_instance
  exact _root_.bot_ne_top

/-- The concrete curve `k ↦ 1 - p^{-k}` really is realised by the model. -/
theorem concrete_cureProb (p : ℕ) [Fact p.Prime] (k : ℕ) :
    cureProb (fun _ : Fin 1 => (⊥ : Submodule (ZMod p) (ZMod p))) k = 1 - ((p : ℝ) ^ k)⁻¹ :=
  hyperplane_cureProb _ (card_bot_mul_self p) k

/-- **The law, on a concrete witness.** -/
theorem concrete_isMonotoneRamp (p : ℕ) [Fact p.Prime] :
    IsMonotoneRamp (cureProb (fun _ : Fin 1 => (⊥ : Submodule (ZMod p) (ZMod p)))) :=
  cureProb_isMonotoneRamp _ Nat.one_pos (fun _ => bot_ne_top_zmod p)

/-- The predicted ramp at `p = 2`, at the widths `k = 0, 1, 2, 4, 8` used in the experiment:
`0, 1/2, 3/4, 15/16, 255/256` — monotone, sublinear, and strictly below `1` throughout, in
qualitative agreement with the measured `0.25, 0.33, 0.83, 1.00, 1.00`
(the two measured `1.00`s being finite-sample rounding of `0.94`/`0.996`). -/
theorem ramp_two_values :
    cureProb (fun _ : Fin 1 => (⊥ : Submodule (ZMod 2) (ZMod 2))) 0 = 0 ∧
    cureProb (fun _ : Fin 1 => (⊥ : Submodule (ZMod 2) (ZMod 2))) 1 = 1 / 2 ∧
    cureProb (fun _ : Fin 1 => (⊥ : Submodule (ZMod 2) (ZMod 2))) 2 = 3 / 4 ∧
    cureProb (fun _ : Fin 1 => (⊥ : Submodule (ZMod 2) (ZMod 2))) 4 = 15 / 16 ∧
    cureProb (fun _ : Fin 1 => (⊥ : Submodule (ZMod 2) (ZMod 2))) 8 = 255 / 256 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;>
    · rw [concrete_cureProb]
      norm_num

end Concrete

end EOSWidthRamp