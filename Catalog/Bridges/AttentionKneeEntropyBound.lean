/-
  # Cycle 2: the retention knee is bounded *below* by Rényi-2 (collision) entropy

  `Bridges.AttentionKneeGeometry` established the order-theoretic side of the
  retention knee (grids, majorization, geometric upper budgets).  That side is
  one-directional: it can only certify that `k` keys *suffice*.  This module
  supplies the converse — an **information-theoretic lower bound** on the knee,
  obtained from Cauchy–Schwarz (Chebyshev's sum inequality) rather than from any
  ordering assumption:

      `g ≤ mass w k  ⟹  g² ≤ k · E_k`   (`sq_gate_le_card_mul_energy`)

  where `E_k = ∑_{i<k} (w i)²` is the *attention energy* of those keys — the
  collision probability, i.e. `2^{-H₂}` for a probability profile.  Hence

      `k*(g) ≥ g² / E`   (`knee_ge_gate_sq_div_energy`).

  What is proved here:

  * `energy_ge_of_knee_le`: read backwards, a *measured* knee is a hard upper
    bound on the Rényi-2 entropy of the attention row.  Applied to the NET-63
    round-16 reading (`net63_energy_lower_bound`): any nonnegative profile whose
    knee at gate `0.98` is at most `24` must have energy `≥ 0.9604/24 > 0.04`,
    i.e. collision entropy `H₂ ≤ log₂(24/0.9604) < 4.65` bits.  This is a
    falsifiable prediction about the measured rows, not a restatement of the
    sweep.
  * `knee_ge_of_max_weight`: the cruder `ℓ^∞` bound `k*(g) ≥ g / M`.
  * `uniform_knee_lower_bound` / `uniform_energy`: on the uniform profile over
    `n` keys the `ℓ²` bound `g²n` is tight up to exactly one factor of the gate
    (the truth is `g n`), so the constant in the bound cannot be improved by
    more than `1/g`.
  * `knee_sandwich` and `budget_energy_consistency`: combining with the
    geometric-tail budget of cycle 1, any reported triple (knee, energy, tail
    constants) must satisfy `g²/E ≤ N` — a consistency test on the experiment.
-/

import Mathlib
import Bridges.AttentionKneeGeometry

namespace Bridges.AttentionKneeEntropyBound

open Finset Bridges.AttentionKneeGeometry

/-- The **attention energy** (collision probability) of the first `k` keys. -/
def energy (w : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ Finset.range k, (w i) ^ 2

lemma energy_mono {w : ℕ → ℝ} : Monotone (energy w) := by
  intro a b hab
  refine Finset.sum_le_sum_of_subset_of_nonneg ?_ (fun i _ _ => sq_nonneg _)
  intro i hi
  simp only [Finset.mem_range] at hi ⊢
  omega

/-! ## 1. Cauchy–Schwarz: mass cannot outrun energy -/

/-- **Cauchy–Schwarz for the retention curve.**  Retaining mass `g` with `k`
keys forces `g² ≤ k · E_k`. -/
theorem sq_gate_le_card_mul_energy {w : ℕ → ℝ} {g : ℝ} {k : ℕ} (hg : 0 ≤ g)
    (hk : g ≤ mass w k) : g ^ 2 ≤ (k : ℝ) * energy w k := by
  have hcs : (∑ i ∈ Finset.range k, w i) ^ 2
      ≤ (#(Finset.range k) : ℝ) * ∑ i ∈ Finset.range k, (w i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hmass : g ^ 2 ≤ (mass w k) ^ 2 := by nlinarith
  simpa [mass, energy] using le_trans hmass hcs

/-- **The knee is bounded below by the inverse energy.**  A profile of energy at
most `E` (Rényi-2 entropy at least `-log₂ E`) cannot meet the gate `g` with
fewer than `g²/E` keys. -/
theorem knee_ge_gate_sq_div_energy {w : ℕ → ℝ} {g E : ℝ} (hg : 0 ≤ g) (hE : 0 < E)
    (hEbound : ∀ k, energy w k ≤ E) (hex : ∃ k, g ≤ mass w k) :
    g ^ 2 / E ≤ (knee w g : ℝ) := by
  have hk := sq_gate_le_card_mul_energy hg (knee_pass hex)
  have h2 : (knee w g : ℝ) * energy w (knee w g) ≤ (knee w g : ℝ) * E :=
    mul_le_mul_of_nonneg_left (hEbound _) (Nat.cast_nonneg _)
  rw [div_le_iff₀ hE]
  nlinarith

/-- **Backwards reading: a measured knee caps the entropy.**  If a sweep
certifies `knee w g ≤ K`, the attention row must carry energy at least `g²/K`
in its first `K` keys. -/
theorem energy_ge_of_knee_le {w : ℕ → ℝ} {g : ℝ} {K : ℕ} (hw : ∀ i, 0 ≤ w i)
    (hg : 0 ≤ g) (hK : 0 < K) (hex : ∃ k, g ≤ mass w k) (hknee : knee w g ≤ K) :
    g ^ 2 / (K : ℝ) ≤ energy w K := by
  have hKR : (0:ℝ) < K := by exact_mod_cast hK
  have hpass : g ≤ mass w K := le_trans (knee_pass hex) (mass_mono hw hknee)
  have := sq_gate_le_card_mul_energy hg hpass
  rw [div_le_iff₀ hKR]
  linarith

/-! ## 2. The NET-63 prediction -/

/-- **A falsifiable prediction from the round-16 reading.**  Any nonnegative
attention profile whose knee at gate `0.98` is at most `24` keys must have
attention energy (collision probability) greater than `0.04` in those keys —
equivalently Rényi-2 entropy below `log₂ 25 < 4.65` bits.  A measured row that
is flatter than this cannot have a knee of 24. -/
theorem net63_energy_lower_bound {w : ℕ → ℝ} (hw : ∀ i, 0 ≤ w i)
    (hex : ∃ k, (0.98:ℝ) ≤ mass w k) (hknee : knee w 0.98 ≤ 24) :
    (0.04 : ℝ) < energy w 24 := by
  have h := energy_ge_of_knee_le hw (by norm_num) (show 0 < 24 by norm_num) hex hknee
  have h24 : ((24:ℕ):ℝ) = 24 := by norm_num
  rw [h24] at h
  nlinarith

/-! ## 3. The `ℓ^∞` bound, and tightness of the `ℓ²` bound -/

/-- The crude peak bound: with every key carrying at most `M`, the gate `g`
needs at least `g / M` keys. -/
theorem knee_ge_of_max_weight {w : ℕ → ℝ} {g M : ℝ} (hM : 0 < M)
    (hbound : ∀ i, w i ≤ M) (hex : ∃ k, g ≤ mass w k) :
    g / M ≤ (knee w g : ℝ) := by
  have hpass : g ≤ mass w (knee w g) := knee_pass hex
  have hle : mass w (knee w g) ≤ (knee w g : ℝ) * M := by
    have : mass w (knee w g) ≤ ∑ _i ∈ Finset.range (knee w g), M :=
      Finset.sum_le_sum fun i _ => hbound i
    simpa [mul_comm] using this
  rw [div_le_iff₀ hM]
  linarith

/-- Energy of a plateau profile. -/
lemma energy_stepProfile (n : ℕ) (c : ℝ) (k : ℕ) :
    energy (stepProfile n c) k = c ^ 2 * (min k n : ℕ) := by
  have hsq : ∀ i, (stepProfile n c i) ^ 2 = stepProfile n (c ^ 2) i := by
    intro i; unfold stepProfile; split <;> simp
  have : energy (stepProfile n c) k = mass (stepProfile n (c ^ 2)) k := by
    simp [energy, mass, hsq]
  rw [this, mass_stepProfile]

/-- **The prediction is sharp and non-vacuous.**  The plateau profile spreading
mass `0.98` over exactly `24` keys has knee `24` and energy exactly
`0.98²/24 = 0.0400166…`: the floor of `net63_energy_lower_bound` is attained, so
no larger constant is provable, and the hypotheses are satisfiable. -/
theorem net63_energy_bound_attained :
    ∃ w : ℕ → ℝ, (∀ i, 0 ≤ w i) ∧ Antitone w ∧ knee w 0.98 = 24 ∧
      energy w 24 = 0.98 ^ 2 / 24 := by
  refine ⟨stepProfile 24 (0.98 / 24), stepProfile_nonneg (by norm_num),
    stepProfile_antitone (by norm_num), knee_stepProfile (by norm_num) (by norm_num), ?_⟩
  rw [energy_stepProfile, show min 24 24 = 24 from by omega]
  norm_num

/-- The uniform profile over `n` keys has energy exactly `1/n`. -/
theorem uniform_energy {n : ℕ} (hn : 0 < n) :
    energy (stepProfile n (1 / n)) n = 1 / n := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  rw [energy_stepProfile, show min n n = n from by omega]
  field_simp

/-- On the uniform profile the true knee is `≥ g n`, while the `ℓ²` bound gives
`g² n`: the Cauchy–Schwarz estimate is tight up to exactly one factor of the
gate, so no bound of this shape can be improved by more than `1/g`. -/
theorem uniform_knee_lower_bound {n : ℕ} {g : ℝ} (hn : 0 < n)
    (hex : ∃ k, g ≤ mass (stepProfile n (1 / n)) k) :
    g * n ≤ (knee (stepProfile n (1 / n)) g : ℝ) := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  set K := knee (stepProfile n (1 / n)) g with hK
  have hpass : g ≤ mass (stepProfile n (1 / n)) K := knee_pass hex
  rw [mass_stepProfile] at hpass
  have hmin : ((min K n : ℕ) : ℝ) ≤ (K : ℝ) := by
    have : min K n ≤ K := min_le_left _ _
    exact_mod_cast this
  have : g ≤ (1 / n) * (K : ℝ) := le_trans hpass (by nlinarith [one_div_pos.mpr hnR])
  rw [one_div, inv_mul_eq_div, le_div_iff₀ hnR] at this
  linarith

/-- And the `ℓ²` bound really does apply to the uniform profile, giving
`g² n ≤ k*`, weaker than the truth `g n ≤ k*` by the factor `g`. -/
theorem uniform_l2_bound {n : ℕ} {g : ℝ} (hn : 0 < n) (hg : 0 ≤ g)
    (hex : ∃ k, g ≤ mass (stepProfile n (1 / n)) k) :
    g ^ 2 * n ≤ (knee (stepProfile n (1 / n)) g : ℝ) := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  have hEb : ∀ k, energy (stepProfile n (1 / n)) k ≤ 1 / n := by
    intro k
    rw [energy_stepProfile]
    have hmin : ((min k n : ℕ) : ℝ) ≤ (n : ℝ) := by
      have : min k n ≤ n := min_le_right _ _
      exact_mod_cast this
    have h0 : (0:ℝ) ≤ ((min k n : ℕ) : ℝ) := Nat.cast_nonneg _
    have hsq : (1 / (n:ℝ)) ^ 2 * ((min k n : ℕ) : ℝ) ≤ (1 / (n:ℝ)) ^ 2 * n :=
      mul_le_mul_of_nonneg_left hmin (by positivity)
    calc (1 / (n:ℝ)) ^ 2 * ((min k n : ℕ) : ℝ) ≤ (1 / (n:ℝ)) ^ 2 * n := hsq
      _ = 1 / n := by field_simp
  have h := knee_ge_gate_sq_div_energy (w := stepProfile n (1 / n)) (g := g)
    (E := 1 / n) hg (by positivity) hEb hex
  calc g ^ 2 * n = g ^ 2 / (1 / n) := by field_simp
    _ ≤ _ := h

/-! ## 4. Sandwiching the knee, and a consistency test for the experiment -/

/-- **Sandwich.**  An attention row with energy at most `E` and geometric tail
`(C, r)` has its knee pinned between an entropy floor and a tail ceiling. -/
theorem knee_sandwich {w : ℕ → ℝ} {g E C r : ℝ} {N : ℕ} (hg : 0 ≤ g) (hE : 0 < E)
    (hEbound : ∀ k, energy w k ≤ E) (htail : ∀ k, 1 - mass w k ≤ C * r ^ k)
    (hcert : C * r ^ N ≤ 1 - g) :
    g ^ 2 / E ≤ (knee w g : ℝ) ∧ knee w g ≤ N := by
  have hupper : knee w g ≤ N := knee_le_of_geometric_tail htail hcert
  refine ⟨knee_ge_gate_sq_div_energy hg hE hEbound ⟨N, ?_⟩, hupper⟩
  have := htail N
  linarith

/-- **Consistency test.**  Any experimentally reported triple (gate `g`, energy
bound `E`, tail certificate `C rᴺ ≤ 1 - g`) must satisfy `g²/E ≤ N`.  A report
violating this is internally inconsistent, whatever the sweep says. -/
theorem budget_energy_consistency {w : ℕ → ℝ} {g E C r : ℝ} {N : ℕ} (hg : 0 ≤ g)
    (hE : 0 < E) (hEbound : ∀ k, energy w k ≤ E)
    (htail : ∀ k, 1 - mass w k ≤ C * r ^ k) (hcert : C * r ^ N ≤ 1 - g) :
    g ^ 2 / E ≤ (N : ℝ) := by
  obtain ⟨hlo, hhi⟩ := knee_sandwich hg hE hEbound htail hcert
  have : ((knee w g : ℕ) : ℝ) ≤ (N : ℝ) := by exact_mod_cast hhi
  linarith

/-!
## Lab Notes (cycle 2)

* Numerical instance of the entropy floor: gate `g = 0.98`, measured knee
  `K = 24` gives `E ≥ 0.98²/24 = 0.0400166…`, hence `H₂ ≤ log₂(1/0.04) ≈ 4.64`
  bits.  Formalised (in the strict form `E > 0.04`) as
  `net63_energy_lower_bound`.
* Tightness check on the uniform profile over `n` keys: energy `1/n`
  (`uniform_energy`), true knee `≥ g n` (`uniform_knee_lower_bound`), `ℓ²`
  floor `g² n` (`uniform_l2_bound`).  Ratio of truth to bound: exactly `1/g`,
  i.e. `1.0204` at `g = 0.98` — the floor is essentially sharp at high gates.
* Consistency of the deployment table: with `N = 30` the test
  `g²/E ≤ N` requires `E ≥ 0.032`; the round-16 numbers satisfy it with room to
  spare.
-/

end Bridges.AttentionKneeEntropyBound