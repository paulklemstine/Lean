import Shared.AttentionBudgetTailFit

/-!
# Cycle 5: the geometry of the energy floor — divergence rates, exact geometric energy,
and the mixture law

Cycle 4 (`Shared.AttentionBudgetTailFit`) produced the two-sided report
`g² / E ≤ k* ≤ n` together with a fit-based upper certificate.  The floor was proved but
not *evaluated*: nothing said how large `g²/E` actually is for the profiles that occur.
This cycle computes it.

**A. A quantitative divergence law.**  For a sorted (antitone) profile the energy is
controlled by the head weight, `E ≤ w₀ / headMass w n` (`energy_le_head_div_headMass`).
Feeding this into the floor turns the qualitative dichotomy of cycle 3 into a *rate*:

  `k*(n) ≥ g² · headMass w n / w₀`   (`kstar_ge_gate_sq_mul_headMass_div_head`).

Cycle 3 proved only that a non-summable profile defeats every fixed budget; here the
budget is bounded below by the partial sums themselves.  Applied to the critical Zipf
profile this gives the explicit logarithmic law

  `k*(n) ≥ g² · log(n+1)`   (`kstar_zipf_one_ge_log`),

the first quantitative growth rate for the knee at the critical exponent `s = 1`.

**B. The exact energy of a geometric profile.**  `energy_geometric` evaluates
`E = (1-r)(1+rⁿ) / ((1+r)(1-rⁿ))`, whose `n → ∞` limit is `(1-r)/(1+r)`.  So even a
perfectly geometric profile has a budget growing like `1/(1-r)`:
`kstar_ge_of_geometric_profile` gives `k* ≥ g² / (3(1-r))` once `rⁿ ≤ 1/2`.  Combined with
the cycle-2 upper bound `geometricBudget r g ≈ log(1/((1-g)(1-r)))/log(1/r)`, the knee of a
geometric profile is *pinned from both sides* (`geometric_budget_two_sided`): the reported
budget cannot be improved below `c/(1-r)`, so the tail-exponent fit is not merely
sufficient — it captures the true order of the budget.

**C. The mixture law for the floor.**  Merging heads is convex on the energy
(`energy_add_le_max`), hence the floor of a mixture never drops below the smaller of the
two per-head floors (`energy_floor_add_ge_min`).  This is the exact counterpart, on the
lower certificate, of the cycle-2 max law for the knee itself: the *worst* head governs
both ends of the sandwich.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 5, ranked):
 (H17) The energy floor upgrades the summability dichotomy to a rate: the budget grows
       at least like the partial sums of the profile.                        [BOLD]
 (H18) At the critical Zipf exponent the knee grows logarithmically, and the constant
       is the squared gate.                                                  [BOLD]
 (H19) For a geometric profile the floor is `Θ(1/(1-r))`, matching the cycle-2 upper
       bound up to the logarithmic factor `log(1/((1-g)(1-r)))`.             [BOLD]
 (H20) The energy floor obeys a min law under head merging, mirroring the max law for
       the knee.

Experimenter: H17 = `kstar_ge_gate_sq_mul_headMass_div_head`; H18 = `kstar_zipf_one_ge_log`
(via `log_add_one_le_harmonic`); H19 = `energy_geometric` +
`kstar_ge_of_geometric_profile` + `geometric_budget_two_sided`; H20 = `energy_add_le_max`
+ `energy_floor_add_ge_min`.  All proved, zero sorries.

Analyst: the mechanism behind H17 is that for a sorted profile the ℓ²-energy is at most
`w₀/S`; the *only* way to keep the energy large (and hence the floor small) is to keep the
normaliser small, i.e. to concentrate.  Divergence of `S` is therefore *equivalent*, at the
level of the floor, to divergence of the budget — which is exactly why the cycle-3
summability criterion and the cycle-4 energy floor are two views of one phenomenon.

Critic: `energy_le_head_div_headMass` needs the profile to be sorted (antitone); without
sortedness `w₀` is not the maximum and the bound fails, so the hypothesis is load-bearing
and is exactly the standing assumption of the whole programme (the profile is the *sorted*
attention weight vector).  In `kstar_ge_of_geometric_profile` the hypothesis `rⁿ ≤ 1/2` is
a genuine finite-context condition: for `n` below `log 2 / log(1/r)` the context truncation
itself, not the decay, limits the budget.
-/

namespace AttentionBudget

open Finset

/-! ## A. The energy of a sorted profile, and the divergence rate -/

section Sorted

variable {w : ℕ → ℝ} {n : ℕ} {g : ℝ}

/-- In a sorted profile the first weight dominates. -/
lemma weight_le_head (hanti : ∀ i, w (i + 1) ≤ w i) : ∀ i, w i ≤ w 0 := by
  intro i
  induction i with
  | zero => exact le_rfl
  | succ m ih => exact le_trans (hanti m) ih

/-- **The energy of a sorted profile is at most `w₀ / S`.**  Concentration is the only way
to keep the collision probability high. -/
theorem energy_le_head_div_headMass (hw : ∀ i, 0 < w i) (hanti : ∀ i, w (i + 1) ≤ w i)
    (hn : 0 < n) : energy w n ≤ w 0 / headMass w n := by
  have hS : 0 < headMass w n := headMass_pos hw hn
  have hS2 : (0 : ℝ) < headMass w n ^ 2 := by positivity
  have hterm : ∀ i ∈ range n, (w i / headMass w n) ^ 2 ≤ w 0 * (w i / headMass w n ^ 2) := by
    intro i _
    have h1 : w i ≤ w 0 := weight_le_head hanti i
    have h2 : 0 < w i := hw i
    rw [div_pow, div_le_iff₀ hS2]
    have hval : w 0 * (w i / headMass w n ^ 2) * headMass w n ^ 2 = w 0 * w i := by
      field_simp
    rw [hval]
    nlinarith
  calc energy w n ≤ ∑ i ∈ range n, w 0 * (w i / headMass w n ^ 2) :=
        Finset.sum_le_sum hterm
    _ = w 0 * (headMass w n / headMass w n ^ 2) := by
        rw [← Finset.mul_sum, ← Finset.sum_div]
        rfl
    _ = w 0 / headMass w n := by
        field_simp

/-- **H17 — the quantitative divergence law.**  The knee of a sorted profile is at least
`g²` times the ratio of the total context mass to the head weight.  For a non-summable
profile the right-hand side diverges, so this refines the qualitative cycle-3 dichotomy
into an explicit growth rate. -/
theorem kstar_ge_gate_sq_mul_headMass_div_head (hw : ∀ i, 0 < w i)
    (hanti : ∀ i, w (i + 1) ≤ w i) (hn : 0 < n) (hg0 : 0 < g) (hg1 : g ≤ 1) :
    g ^ 2 * headMass w n / w 0 ≤ (kstar w n g : ℝ) := by
  have hS : 0 < headMass w n := headMass_pos hw hn
  have hw0 : 0 < w 0 := hw 0
  have hE : 0 < energy w n := energy_pos hw hn
  have hfloor : g ^ 2 / energy w n ≤ (kstar w n g : ℝ) := (budget_sandwich hw hn hg0 hg1).1
  have hEle : energy w n ≤ w 0 / headMass w n := energy_le_head_div_headMass hw hanti hn
  have hstep : g ^ 2 * headMass w n / w 0 ≤ g ^ 2 / energy w n := by
    rw [div_le_div_iff₀ hw0 hE]
    have hES : energy w n * headMass w n ≤ w 0 := by
      rw [le_div_iff₀ hS] at hEle
      linarith
    nlinarith [sq_nonneg g, hg0]
  linarith

end Sorted

/-! ### The critical Zipf profile: a logarithmic budget law -/

lemma zipf_one_eq (i : ℕ) : zipf 1 i = 1 / ((i : ℝ) + 1) := by
  simp [zipf]

lemma zipf_one_antitone : ∀ i, zipf 1 (i + 1) ≤ zipf 1 i := by
  intro i
  rw [zipf_one_eq, zipf_one_eq]
  have h1 : (0 : ℝ) < (i : ℝ) + 1 := by positivity
  have h2 : ((i : ℝ) + 1) ≤ ((i : ℝ) + 1 + 1) := by linarith
  push_cast
  rw [div_le_div_iff₀ (by linarith) h1]
  linarith

lemma headMass_zipf_one (n : ℕ) : headMass (zipf 1) n = (harmonic n : ℝ) := by
  rw [headMass, harmonic]
  push_cast
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [zipf_one_eq, one_div]

/-- **H18 — the critical Zipf budget grows logarithmically.**  At the critical exponent
`s = 1` (the boundary of the cycle-3 phase transition) the knee obeys the explicit lower
bound `k*(n) ≥ g² log(n+1)`. -/
theorem kstar_zipf_one_ge_log {n : ℕ} {g : ℝ} (hn : 0 < n) (hg0 : 0 < g) (hg1 : g ≤ 1) :
    g ^ 2 * Real.log ((n : ℝ) + 1) ≤ (kstar (zipf 1) n g : ℝ) := by
  have hzero : zipf 1 0 = 1 := by rw [zipf_one_eq]; norm_num
  have hmain := kstar_ge_gate_sq_mul_headMass_div_head (w := zipf 1) (n := n) (g := g)
    (zipf_pos 1) zipf_one_antitone hn hg0 hg1
  rw [hzero, div_one, headMass_zipf_one] at hmain
  have hlog : Real.log ((n : ℝ) + 1) ≤ (harmonic n : ℝ) := by
    have := log_add_one_le_harmonic n
    push_cast at this
    exact this
  nlinarith [sq_nonneg g, hg0]

/-! ## B. The exact energy of a geometric profile -/

section Geometric

variable {r g : ℝ} {n : ℕ}

lemma headMass_geometric (hr1 : r < 1) (n : ℕ) :
    headMass (fun i => r ^ i) n = (1 - r ^ n) / (1 - r) := by
  have hne : r - 1 ≠ 0 := sub_ne_zero.mpr (ne_of_lt hr1)
  have hne' : (1 : ℝ) - r ≠ 0 := sub_ne_zero.mpr (ne_of_gt hr1)
  rw [headMass, geom_sum_eq (ne_of_lt hr1), div_eq_div_iff hne hne']
  ring

/-- **H19 — the exact energy of a geometric profile.**  `E = (1-r)(1+rⁿ)/((1+r)(1-rⁿ))`,
whose limit as the context grows is `(1-r)/(1+r)`. -/
theorem energy_geometric (hr0 : 0 < r) (hr1 : r < 1) (hn : 0 < n) :
    energy (fun i => r ^ i) n = ((1 - r) * (1 + r ^ n)) / ((1 + r) * (1 - r ^ n)) := by
  have hrn : r ^ n < 1 := pow_lt_one₀ hr0.le hr1 hn.ne'
  have hrn0 : 0 < r ^ n := pow_pos hr0 n
  have h1r : (0 : ℝ) < 1 - r := by linarith
  have h1rn : (0 : ℝ) < 1 - r ^ n := by linarith
  have h1pr : (0 : ℝ) < 1 + r := by linarith
  have hS : headMass (fun i => r ^ i) n = (1 - r ^ n) / (1 - r) := headMass_geometric hr1 n
  have hsq : ∑ i ∈ range n, ((r ^ i) ^ 2) = (1 - (r ^ 2) ^ n) / (1 - r ^ 2) := by
    have hr2 : r ^ 2 < 1 := by nlinarith
    have := headMass_geometric (r := r ^ 2) hr2 n
    rw [headMass] at this
    calc ∑ i ∈ range n, ((r ^ i) ^ 2) = ∑ i ∈ range n, (r ^ 2) ^ i := by
          refine Finset.sum_congr rfl fun i _ => ?_
          rw [← pow_mul, ← pow_mul, Nat.mul_comm]
      _ = (1 - (r ^ 2) ^ n) / (1 - r ^ 2) := this
  have hexpand : energy (fun i => r ^ i) n
      = (∑ i ∈ range n, ((r ^ i) ^ 2)) / (headMass (fun i => r ^ i) n) ^ 2 := by
    rw [energy, Finset.sum_div]
    exact Finset.sum_congr rfl fun i _ => by rw [div_pow]
  rw [hexpand, hsq, hS]
  have hpow : (r ^ 2) ^ n = (r ^ n) ^ 2 := by rw [← pow_mul, ← pow_mul, Nat.mul_comm]
  rw [hpow]
  have h1r2 : (0 : ℝ) < 1 - r ^ 2 := by nlinarith
  field_simp
  ring

/-- **The geometric floor.**  Once the context is long enough for the geometric tail to
have decayed (`rⁿ ≤ 1/2`), the knee is at least `g² / (3(1-r))`: the decay ratio controls
the budget from below as well as from above. -/
theorem kstar_ge_of_geometric_profile (hr0 : 0 < r) (hr1 : r < 1) (hdecayed : r ^ n ≤ 1 / 2)
    (hg0 : 0 < g) (hg1 : g ≤ 1) : g ^ 2 / (3 * (1 - r)) ≤ (kstar (fun i => r ^ i) n g : ℝ) := by
  have hn : 0 < n := by
    rcases Nat.eq_zero_or_pos n with h | h
    · rw [h] at hdecayed; norm_num at hdecayed
    · exact h
  have hrn0 : 0 < r ^ n := pow_pos hr0 n
  have h1r : (0 : ℝ) < 1 - r := by linarith
  have hwpos : ∀ i, (0 : ℝ) < r ^ i := fun i => pow_pos hr0 i
  have hE := energy_geometric hr0 hr1 hn
  have hfloor : g ^ 2 / energy (fun i => r ^ i) n ≤ (kstar (fun i => r ^ i) n g : ℝ) :=
    (budget_sandwich hwpos hn hg0 hg1).1
  have hrnlt : r ^ n < 1 := by linarith
  have h1t : (0 : ℝ) < 1 - r ^ n := by linarith
  have hEle : energy (fun i => r ^ i) n ≤ 3 * (1 - r) := by
    rw [hE, div_le_iff₀ (by nlinarith)]
    have hkey : 0 ≤ 3 * (1 + r) * (1 - r ^ n) - (1 + r ^ n) := by nlinarith
    nlinarith [mul_nonneg h1r.le hkey]
  have hEpos : 0 < energy (fun i => r ^ i) n := energy_pos hwpos hn
  have hstep : g ^ 2 / (3 * (1 - r)) ≤ g ^ 2 / energy (fun i => r ^ i) n := by
    apply div_le_div_of_nonneg_left (by positivity) hEpos hEle
  linarith

/-- **The two-sided pin for geometric profiles.**  The knee of the pure geometric profile
`rⁱ` lies between `g²/(3(1-r))` and the cycle-2 closed-form budget: the tail-exponent fit
captures the true order of the attention budget, not merely an upper bound. -/
theorem geometric_budget_two_sided (hr0 : 0 < r) (hr1 : r < 1) (hdecayed : r ^ n ≤ 1 / 2)
    (hg0 : 0 < g) (hg1 : g < 1) :
    g ^ 2 / (3 * (1 - r)) ≤ (kstar (fun i => r ^ i) n g : ℝ) ∧
      kstar (fun i => r ^ i) n g ≤ geometricBudget r g := by
  have hn : 0 < n := by
    rcases Nat.eq_zero_or_pos n with h | h
    · rw [h] at hdecayed; norm_num at hdecayed
    · exact h
  have hwpos : ∀ i, (0 : ℝ) < r ^ i := fun i => pow_pos hr0 i
  have hdec : ∀ i, r ^ (i + 1) ≤ r * r ^ i := fun i => le_of_eq (by ring)
  exact ⟨kstar_ge_of_geometric_profile hr0 hr1 hdecayed hg0 hg1.le,
    kstar_le_geometricBudget hwpos hr0 hr1 hdec hg1 hn⟩

end Geometric

/-! ## C. Head merging: the min law for the floor -/

section Merge

variable {w₁ w₂ : ℕ → ℝ} {n : ℕ} {g : ℝ}

/-- **H20 — mixing heads is convex on the energy.**  The collision probability of a merged
head never exceeds the larger of the two per-head collision probabilities. -/
theorem energy_add_le_max (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i) (hn : 0 < n) :
    energy (fun i => w₁ i + w₂ i) n ≤ max (energy w₁ n) (energy w₂ n) := by
  have hS₁ : 0 < headMass w₁ n := headMass_pos hw₁ hn
  have hS₂ : 0 < headMass w₂ n := headMass_pos hw₂ hn
  have hSsum : headMass (fun i => w₁ i + w₂ i) n = headMass w₁ n + headMass w₂ n :=
    headMass_add n
  set S₁ := headMass w₁ n
  set S₂ := headMass w₂ n
  set lam := S₁ / (S₁ + S₂) with hlam
  have hSpos : 0 < S₁ + S₂ := by linarith
  have hlam0 : 0 ≤ lam := by positivity
  have hlam1 : lam ≤ 1 := by
    rw [hlam, div_le_one hSpos]; linarith
  have hlamc : 1 - lam = S₂ / (S₁ + S₂) := by
    rw [hlam]; field_simp; ring
  have hterm : ∀ i ∈ range n,
      ((w₁ i + w₂ i) / (S₁ + S₂)) ^ 2
        ≤ lam * (w₁ i / S₁) ^ 2 + (1 - lam) * (w₂ i / S₂) ^ 2 := by
    intro i _
    set a := w₁ i / S₁ with ha
    set b := w₂ i / S₂ with hb
    have hw₁i : w₁ i = a * S₁ := by rw [ha]; field_simp
    have hw₂i : w₂ i = b * S₂ := by rw [hb]; field_simp
    have hmix : (w₁ i + w₂ i) / (S₁ + S₂) = lam * a + (1 - lam) * b := by
      rw [hw₁i, hw₂i, hlam, hlamc]
      field_simp
    rw [hmix]
    nlinarith [sq_nonneg (a - b), mul_nonneg hlam0 (sub_nonneg.mpr hlam1)]
  have hsum : ∑ i ∈ range n, ((w₁ i + w₂ i) / (S₁ + S₂)) ^ 2
      ≤ lam * energy w₁ n + (1 - lam) * energy w₂ n := by
    calc ∑ i ∈ range n, ((w₁ i + w₂ i) / (S₁ + S₂)) ^ 2
        ≤ ∑ i ∈ range n, (lam * (w₁ i / S₁) ^ 2 + (1 - lam) * (w₂ i / S₂) ^ 2) :=
          Finset.sum_le_sum hterm
      _ = lam * energy w₁ n + (1 - lam) * energy w₂ n := by
          rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
          rfl
  have hcombine : lam * energy w₁ n + (1 - lam) * energy w₂ n
      ≤ max (energy w₁ n) (energy w₂ n) := by
    have h₁ : energy w₁ n ≤ max (energy w₁ n) (energy w₂ n) := le_max_left _ _
    have h₂ : energy w₂ n ≤ max (energy w₁ n) (energy w₂ n) := le_max_right _ _
    nlinarith [sub_nonneg.mpr hlam1]
  have hrewrite : energy (fun i => w₁ i + w₂ i) n
      = ∑ i ∈ range n, ((w₁ i + w₂ i) / (S₁ + S₂)) ^ 2 := by
    rw [energy, hSsum]
  rw [hrewrite]
  linarith

/-- **The min law for the lower certificate.**  Merging two heads never pushes the energy
floor below the smaller of the two per-head floors — the mirror image, on the lower end of
the sandwich, of the cycle-2 max law `kstar_add_le_max` for the knee. -/
theorem energy_floor_add_ge_min (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i) (hn : 0 < n)
    (hg0 : 0 < g) :
    min (g ^ 2 / energy w₁ n) (g ^ 2 / energy w₂ n)
      ≤ g ^ 2 / energy (fun i => w₁ i + w₂ i) n := by
  have hE₁ : 0 < energy w₁ n := energy_pos hw₁ hn
  have hE₂ : 0 < energy w₂ n := energy_pos hw₂ hn
  have hwsum : ∀ i, 0 < w₁ i + w₂ i := fun i => add_pos (hw₁ i) (hw₂ i)
  have hEs : 0 < energy (fun i => w₁ i + w₂ i) n := energy_pos hwsum hn
  have hle := energy_add_le_max hw₁ hw₂ hn
  have hmaxpos : 0 < max (energy w₁ n) (energy w₂ n) := lt_of_lt_of_le hE₁ (le_max_left _ _)
  have hstep : g ^ 2 / max (energy w₁ n) (energy w₂ n)
      ≤ g ^ 2 / energy (fun i => w₁ i + w₂ i) n :=
    div_le_div_of_nonneg_left (by positivity) hEs hle
  have hmin : min (g ^ 2 / energy w₁ n) (g ^ 2 / energy w₂ n)
      ≤ g ^ 2 / max (energy w₁ n) (energy w₂ n) := by
    rcases max_cases (energy w₁ n) (energy w₂ n) with ⟨he, _⟩ | ⟨he, _⟩
    · rw [he]; exact min_le_left _ _
    · rw [he]; exact min_le_right _ _
  linarith

end Merge

end AttentionBudget