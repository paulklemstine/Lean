/-
  # The geometry of the retention knee: top-`k` attention mass, grids, and budgets

  ## Bridge: discrete convexity / majorization  ↔  limited-memory deployment tables

  This module gives a formal, assumption-explicit theory of the object that the
  NET-63 experiment series measures: the **retention knee**

      `k*(g) = least k such that the mass retained by the k largest keys is ≥ g`.

  The empirical thread (paper 148, round 16, "THE-2048-KNEE-IS-TWENTY-FOUR")
  reports, at context 2048 on corpus-A, gate `g = 0.98`, averaged over 12 windows:

      | k        | 20     | 24     | 28     | 32     |
      | retained | 0.9793 | 0.9835 | 0.9854 | 0.9885 |

  and the deployment chain `k* = 16, 20, 24` at contexts `512, 1024, 2048`,
  all inside a ~30-key budget.

  What we prove here (all statements are about an arbitrary nonnegative weight
  profile `w : ℕ → ℝ`, `mass w k = ∑_{i<k} w i`; when `w` is *antitone* this is
  exactly the top-`k` mass of a sorted attention row):

  * `knee` well-posedness: `knee_pass`, `knee_le_of_pass`, `mass_lt_of_lt_knee`,
    and the two-sided characterisation `pass_iff_knee_le`.
  * `knee_eq_of_fail_pass`: the "fail at `k-1`, pass at `k`" certificate that a
    sweep actually produces.
  * **Grid geometry.** A sweep only ever reports `gridKnee G`, the least *grid*
    point that passes.  We prove `knee_le_gridKnee` (a sweep never
    under-reports), `gridKnee_refine` (refining the grid can only *lower* the
    reported knee — the exact mechanism by which "28" became "24"), and
    `gridKnee_eq_knee_of_mem` (ON-grid landing).  `knee_bracket` turns the two
    numbers `0.9793 ✗ / 0.9835 ✓` into the sharp bracket `20 < k* ≤ 24`.
  * **Majorization ⇒ knee monotonicity.** If lengthening the context spreads the
    attention mass (`mass v k ≤ mass w k` for all `k`, i.e. `w` majorizes `v` in
    the partial-sum order) then `knee w g ≤ knee v g`, with a strict version
    `knee_lt_of_majorize_strict`.  This is the structural reason a chain like
    `16 < 20 < 24` is forced rather than coincidental (`deployment_chain`).
  * **Geometric tails ⇒ a finite key budget.** `knee_le_of_geometric_tail` and
    `exists_budget_of_geometric_tail`: an exponentially decaying attention tail
    always has a finite knee, with an explicit `C rᴺ ≤ 1 - g` certificate, and
    `knee_le_thirty_of_geometric_tail` is the "~30 keys" budget statement.
  * **An adversarial (Critic-stage) finding.** For antitone `w`, `mass` is
    *discretely concave*: equal-width block increments are antitone
    (`block_increment_antitone`), and averaging over windows preserves this
    (`avgMass_block_concave`).  The reported fine-grid row at 2048 **violates**
    this: `0.9854 - 0.9835 = 0.0019 < 0.0031 = 0.9885 - 0.9854`.  Hence
    `net63_fine2048_not_window_averaged_topk`: those four numbers cannot be the
    window-averaged top-`k` masses of any family of sorted attention rows.  The
    *knee* conclusion `k* = 24` survives (it only uses monotonicity), but the
    concavity-based extrapolation to `k = 28, 32` does not.

  * **Mixtures.**  `knee_mixture_le_max`: a convex blend of two heads never
    needs more keys than the harder of the two, so a multi-head budget is
    controlled by the worst head rather than by their sum.

  Everything is proved from scratch over `ℝ`; the concrete geometric example
  `geometricProfile` at the end exhibits a genuine coarse-grid overestimate
  (`geometric_coarse_grid_overestimates`: true knee 6, coarse grid reports 8).
-/

import Mathlib

namespace Bridges.AttentionKneeGeometry

open Finset

/-! ## 1. Retained mass -/

/-- `mass w k` is the attention mass retained by the first `k` keys of the
weight profile `w`.  When `w` is antitone this is the top-`k` mass. -/
def mass (w : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ Finset.range k, w i

@[simp] lemma mass_zero (w : ℕ → ℝ) : mass w 0 = 0 := by simp [mass]

lemma mass_succ (w : ℕ → ℝ) (k : ℕ) : mass w (k + 1) = mass w k + w k := by
  simp [mass, Finset.sum_range_succ]

lemma mass_mono {w : ℕ → ℝ} (hw : ∀ i, 0 ≤ w i) : Monotone (mass w) := by
  intro a b hab
  refine Finset.sum_le_sum_of_subset_of_nonneg ?_ ?_
  · intro i hi
    simp only [Finset.mem_range] at hi ⊢
    omega
  · intro i _ _; exact hw i

/-- Block increment: the mass added by keys `k, …, k+d-1`. -/
lemma mass_add_sub (w : ℕ → ℝ) (k d : ℕ) :
    mass w (k + d) - mass w k = ∑ i ∈ Finset.range d, w (k + i) := by
  simp [mass, Finset.sum_range_add]

/-- **Discrete concavity of the retention curve.**  For a sorted (antitone)
weight profile, equal-width blocks of keys contribute less and less mass. -/
lemma block_increment_antitone {w : ℕ → ℝ} (hanti : Antitone w) {k k' : ℕ}
    (hkk : k ≤ k') (d : ℕ) :
    mass w (k' + d) - mass w k' ≤ mass w (k + d) - mass w k := by
  rw [mass_add_sub, mass_add_sub]
  refine Finset.sum_le_sum ?_
  intro i _
  exact hanti (by omega)

/-! ## 2. The knee -/

/-- `knee w g` is the least number of keys whose retained mass meets the gate `g`
(and `0` if the gate is never met). -/
noncomputable def knee (w : ℕ → ℝ) (g : ℝ) : ℕ := sInf {k | g ≤ mass w k}

lemma knee_le_of_pass {w : ℕ → ℝ} {g : ℝ} {k : ℕ} (hk : g ≤ mass w k) :
    knee w g ≤ k := Nat.sInf_le hk

lemma knee_pass {w : ℕ → ℝ} {g : ℝ} (h : ∃ k, g ≤ mass w k) :
    g ≤ mass w (knee w g) := Nat.sInf_mem h

lemma mass_lt_of_lt_knee {w : ℕ → ℝ} {g : ℝ} {k : ℕ} (hk : k < knee w g) :
    mass w k < g := by
  by_contra hcon
  push_neg at hcon
  exact absurd (knee_le_of_pass hcon) (not_le.mpr hk)

/-- The gate is met by `k` keys **iff** `k` is at least the knee. -/
lemma pass_iff_knee_le {w : ℕ → ℝ} {g : ℝ} (hw : ∀ i, 0 ≤ w i)
    (h : ∃ k, g ≤ mass w k) (k : ℕ) : g ≤ mass w k ↔ knee w g ≤ k := by
  constructor
  · exact knee_le_of_pass
  · intro hk
    exact le_trans (knee_pass h) (mass_mono hw hk)

/-- The certificate a sweep actually produces: fail at `k - 1`, pass at `k`. -/
lemma knee_eq_of_fail_pass {w : ℕ → ℝ} {g : ℝ} (hw : ∀ i, 0 ≤ w i) {k : ℕ}
    (hfail : mass w (k - 1) < g) (hpass : g ≤ mass w k) (hk : 1 ≤ k) :
    knee w g = k := by
  refine le_antisymm (knee_le_of_pass hpass) ?_
  by_contra hlt
  push_neg at hlt
  have : g ≤ mass w (k - 1) :=
    le_trans (knee_pass ⟨k, hpass⟩) (mass_mono hw (by omega))
  linarith

/-- A higher gate needs at least as many keys. -/
lemma knee_mono_gate {w : ℕ → ℝ} {g₁ g₂ : ℝ} (hg : g₁ ≤ g₂)
    (h : ∃ k, g₂ ≤ mass w k) : knee w g₁ ≤ knee w g₂ :=
  knee_le_of_pass (le_trans hg (knee_pass h))

/-- **Bracketing.**  Two adjacent fine-grid readings `mass w a < g ≤ mass w b`
pin the knee into the half-open interval `(a, b]`.  With `a = 20, b = 24` this
is the NET-63 round-16 conclusion at context 2048. -/
lemma knee_bracket {w : ℕ → ℝ} {g : ℝ} (hw : ∀ i, 0 ≤ w i) {a b : ℕ}
    (hfail : mass w a < g) (hpass : g ≤ mass w b) :
    a < knee w g ∧ knee w g ≤ b := by
  refine ⟨?_, knee_le_of_pass hpass⟩
  by_contra hle
  push_neg at hle
  have : g ≤ mass w a := le_trans (knee_pass ⟨b, hpass⟩) (mass_mono hw hle)
  linarith

/-! ## 3. Majorization: why the deployment chain is monotone -/

/-- **Majorization ⇒ knee monotonicity.**  If every partial mass of `v` is at
most that of `w` (lengthening the context spreads attention), then `v` needs at
least as many keys as `w`. -/
theorem knee_le_of_majorize {v w : ℕ → ℝ} {g : ℝ}
    (hmaj : ∀ k, mass v k ≤ mass w k) (hv : ∃ k, g ≤ mass v k) :
    knee w g ≤ knee v g :=
  knee_le_of_pass (le_trans (knee_pass hv) (hmaj _))

/-- Strict version: if the profile `v` (typically: the same model at a longer
context, whose mass is majorized by `w`'s) *still fails* the gate at the knee of
`w`, then its knee is strictly larger.  Majorization is what makes the hypothesis
`hstrict` plausible, but the implication itself needs only nonnegativity. -/
theorem knee_lt_of_still_failing {v w : ℕ → ℝ} {g : ℝ} (hvnn : ∀ i, 0 ≤ v i)
    (hv : ∃ k, g ≤ mass v k) (hstrict : mass v (knee w g) < g) :
    knee w g < knee v g := by
  by_contra hle
  push_neg at hle
  have hnn : g ≤ mass v (knee v g) := knee_pass hv
  have : g ≤ mass v (knee w g) := le_trans hnn (mass_mono hvnn hle)
  linarith

/-! ## 4. Grid geometry: what a sweep can and cannot report -/

/-- The knee **as reported by a sweep over the finite grid `G`**: the least grid
point that passes the gate. -/
noncomputable def gridKnee (G : Set ℕ) (w : ℕ → ℝ) (g : ℝ) : ℕ :=
  sInf {k | k ∈ G ∧ g ≤ mass w k}

lemma gridKnee_mem {G : Set ℕ} {w : ℕ → ℝ} {g : ℝ}
    (h : ∃ k, k ∈ G ∧ g ≤ mass w k) :
    gridKnee G w g ∈ G ∧ g ≤ mass w (gridKnee G w g) := Nat.sInf_mem h

lemma gridKnee_le_of_mem {G : Set ℕ} {w : ℕ → ℝ} {g : ℝ} {k : ℕ}
    (hk : k ∈ G) (hpass : g ≤ mass w k) : gridKnee G w g ≤ k :=
  Nat.sInf_le ⟨hk, hpass⟩

/-- A sweep never under-reports the knee. -/
theorem knee_le_gridKnee {G : Set ℕ} {w : ℕ → ℝ} {g : ℝ}
    (h : ∃ k, k ∈ G ∧ g ≤ mass w k) : knee w g ≤ gridKnee G w g :=
  knee_le_of_pass (gridKnee_mem h).2

/-- **Grid refinement can only lower the reported knee.**  This is exactly the
mechanism by which the coarse reading `28` was replaced by the fine reading
`24`: no experiment was wrong, the grid was. -/
theorem gridKnee_refine {G G' : Set ℕ} {w : ℕ → ℝ} {g : ℝ} (hGG : G ⊆ G')
    (h : ∃ k, k ∈ G ∧ g ≤ mass w k) : gridKnee G' w g ≤ gridKnee G w g := by
  obtain ⟨hmem, hpass⟩ := gridKnee_mem h
  exact gridKnee_le_of_mem (hGG hmem) hpass

/-- **ON-grid landing.**  If the true knee happens to be a grid point, the sweep
reports it exactly. -/
theorem gridKnee_eq_knee_of_mem {G : Set ℕ} {w : ℕ → ℝ} {g : ℝ}
    (hmem : knee w g ∈ G) (h : ∃ k, g ≤ mass w k) :
    gridKnee G w g = knee w g :=
  le_antisymm (gridKnee_le_of_mem hmem (knee_pass h))
    (knee_le_gridKnee ⟨knee w g, hmem, knee_pass h⟩)

/-- Conversely, an off-grid knee is *strictly* over-reported as soon as the grid
contains no point in the bracket. -/
theorem knee_lt_gridKnee_of_not_mem {G : Set ℕ} {w : ℕ → ℝ} {g : ℝ}
    (hmem : knee w g ∉ G) (h : ∃ k, k ∈ G ∧ g ≤ mass w k) :
    knee w g < gridKnee G w g := by
  rcases lt_or_eq_of_le (knee_le_gridKnee h) with h' | h'
  · exact h'
  · exact absurd (h' ▸ (gridKnee_mem h).1) hmem

/-- Ceiling division, packaged as an existence statement. -/
lemma exists_mul_ceil (s : ℕ) (hs : 0 < s) (d : ℕ) : ∃ j, d ≤ s * j ∧ s * j < d + s := by
  induction d with
  | zero => exact ⟨0, by simp, by simpa using hs⟩
  | succ n ih =>
      obtain ⟨j, h1, h2⟩ := ih
      by_cases h : n + 1 ≤ s * j
      · exact ⟨j, h, by omega⟩
      · refine ⟨j + 1, ?_, ?_⟩ <;>
        · have he : s * (j + 1) = s * j + s := by ring
          omega

/-- **Quantitative grid bias.**  A sweep on an arithmetic grid of spacing `s`
(starting at or below the knee) over-reports the knee by strictly less than one
grid step:  `knee ≤ gridKnee < knee + s`.  For the round-16 fine grid `s = 4`
this says the reported `24` guarantees the true knee lies in `(20, 24]`; for a
coarse grid of spacing `16` a reported value only pins the knee to a window of
16 keys, which is precisely how a coarse sweep could read `28` or `32`. -/
theorem gridKnee_lt_knee_add_spacing {w : ℕ → ℝ} {g : ℝ} (hw : ∀ i, 0 ≤ w i)
    {G : Set ℕ} {a s : ℕ} (hs : 0 < s) (hG : ∀ j, a + s * j ∈ G)
    (ha : a ≤ knee w g) (hex : ∃ k, g ≤ mass w k) :
    knee w g ≤ gridKnee G w g ∧ gridKnee G w g < knee w g + s := by
  obtain ⟨j, hj1, hj2⟩ := exists_mul_ceil s hs (knee w g - a)
  have hge : knee w g ≤ a + s * j := by omega
  have hlt : a + s * j < knee w g + s := by omega
  have hpass : g ≤ mass w (a + s * j) := le_trans (knee_pass hex) (mass_mono hw hge)
  exact ⟨knee_le_gridKnee ⟨a + s * j, hG j, hpass⟩,
    lt_of_le_of_lt (gridKnee_le_of_mem (hG j) hpass) hlt⟩

/-! ## 5. Geometric tails and the key budget -/

/-- **Exponential tail ⇒ explicit knee certificate.**  If the un-retained tail
obeys `1 - mass w k ≤ C rᵏ`, then any `N` with `C rᴺ ≤ 1 - g` is a valid key
budget. -/
theorem knee_le_of_geometric_tail {w : ℕ → ℝ} {g C r : ℝ} {N : ℕ}
    (htail : ∀ k, 1 - mass w k ≤ C * r ^ k) (hcert : C * r ^ N ≤ 1 - g) :
    knee w g ≤ N := by
  refine knee_le_of_pass ?_
  have := htail N
  linarith

/-- **Existence of a finite budget.**  A genuinely exponential tail
(`r < 1`) and a gate below full mass always admit a finite knee. -/
theorem exists_budget_of_geometric_tail {w : ℕ → ℝ} {g C r : ℝ}
    (htail : ∀ k, 1 - mass w k ≤ C * r ^ k) (hC : 0 < C)
    (hr1 : r < 1) (hg : g < 1) : ∃ N, knee w g ≤ N := by
  obtain ⟨N, hN⟩ :=
    exists_pow_lt_of_lt_one (show 0 < (1 - g) / C from div_pos (by linarith) hC) hr1
  refine ⟨N, knee_le_of_geometric_tail htail ?_⟩
  have hrN : r ^ N ≤ (1 - g) / C := le_of_lt hN
  calc C * r ^ N ≤ C * ((1 - g) / C) := by nlinarith
    _ = 1 - g := by field_simp

/-- The "~30 keys" deployment budget, as a checkable certificate. -/
theorem knee_le_thirty_of_geometric_tail {w : ℕ → ℝ} {g C r : ℝ}
    (htail : ∀ k, 1 - mass w k ≤ C * r ^ k) (hcert : C * r ^ 30 ≤ 1 - g) :
    knee w g ≤ 30 := knee_le_of_geometric_tail htail hcert

/-! ## 6. Window averaging, and an obstruction -/

/-- The window-averaged retention curve of a family of `m` attention rows. -/
noncomputable def avgMass (m : ℕ) (W : Fin m → ℕ → ℝ) (k : ℕ) : ℝ :=
  (∑ j, mass (W j) k) / m

/-- Averaging over windows preserves discrete concavity of the retention
curve. -/
theorem avgMass_block_concave {m : ℕ} {W : Fin m → ℕ → ℝ}
    (hanti : ∀ j, Antitone (W j)) {k k' : ℕ} (hkk : k ≤ k') (d : ℕ) :
    avgMass m W (k' + d) - avgMass m W k' ≤ avgMass m W (k + d) - avgMass m W k := by
  have hsum : ∑ j, (mass (W j) (k' + d) - mass (W j) k')
      ≤ ∑ j, (mass (W j) (k + d) - mass (W j) k) :=
    Finset.sum_le_sum fun j _ => block_increment_antitone (hanti j) hkk d
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp [avgMass]
  · have hm' : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
    unfold avgMass
    rw [div_sub_div_same, div_sub_div_same, ← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
    gcongr

/-! ### The NET-63 round-16 fine grid at context 2048

Reported (12 windows, gate `g = 0.98`, corpus-A):
`R 20 = 0.9793`, `R 24 = 0.9835`, `R 28 = 0.9854`, `R 32 = 0.9885`.
-/

/-- The reported fine-grid row at context 2048. -/
def net63R : ℕ → ℝ
  | 20 => 0.9793
  | 24 => 0.9835
  | 28 => 0.9854
  | 32 => 0.9885
  | _  => 0

/-- **Positive reading of the data (P1/P3).**  With gate `0.98`, on the grid
`{20, 24, 28, 32}` the first pass is `k = 24`, with margin `+0.0035`, while
`k = 20` fails by `-0.0007`. -/
theorem net63_first_pass_is_24 :
    net63R 20 < 0.98 ∧ (0.98 : ℝ) ≤ net63R 24 ∧
      net63R 24 - 0.98 = 0.0035 ∧ 0.98 - net63R 20 = 0.0007 := by
  refine ⟨by norm_num [net63R], by norm_num [net63R], by norm_num [net63R],
    by norm_num [net63R]⟩

/-- The margin at `k = 24` is five times the (failing) deficit at `k = 20`. -/
theorem net63_margin_ratio :
    net63R 24 - 0.98 = 5 * (0.98 - net63R 20) := by
  norm_num [net63R]

/-- **Any** nonnegative profile whose 20- and 24-key masses match the reported
row has its knee in `(20, 24]` — the data determines the knee up to the grid
spacing, and no finer information is needed. -/
theorem net63_knee_bracket {w : ℕ → ℝ} (hw : ∀ i, 0 ≤ w i)
    (h20 : mass w 20 = net63R 20) (h24 : mass w 24 = net63R 24) :
    20 < knee w 0.98 ∧ knee w 0.98 ≤ 24 :=
  knee_bracket hw (by rw [h20]; norm_num [net63R]) (by rw [h24]; norm_num [net63R])

/-- **Critic-stage obstruction.**  The reported four numbers violate discrete
concavity: the block `24 → 28` adds `0.0019` while the *later* block `28 → 32`
adds `0.0031`.  Hence no family of sorted (antitone) attention rows, averaged
over any number of windows, can reproduce the row.  The knee conclusion
survives (it uses only monotonicity), but any concavity-based extrapolation
beyond `k = 24` does not. -/
theorem net63_fine2048_not_window_averaged_topk :
    ¬ ∃ (m : ℕ) (W : Fin m → ℕ → ℝ), (∀ j, Antitone (W j)) ∧
        (∀ k ∈ ({20, 24, 28, 32} : Set ℕ), avgMass m W k = net63R k) := by
  rintro ⟨m, W, hanti, hmatch⟩
  have h24 := hmatch 24 (by simp)
  have h28 := hmatch 28 (by simp)
  have h32 := hmatch 32 (by simp)
  have hconc := avgMass_block_concave hanti (show 24 ≤ 28 by norm_num) 4
  norm_num at hconc
  rw [h24, h28, h32] at hconc
  norm_num [net63R] at hconc

/-! ## 7. The deployment chain `16 < 20 < 24` -/

/-- **The deployment table, derived.**  Given the fail/pass certificates
measured at the three contexts, the chain of knees is exactly `16, 20, 24`;
it is strictly monotone and fits inside a 30-key budget. -/
theorem deployment_chain {w₅ w₁₀ w₂₀ : ℕ → ℝ} {g : ℝ}
    (h₅ : ∀ i, 0 ≤ w₅ i) (h₁₀ : ∀ i, 0 ≤ w₁₀ i) (h₂₀ : ∀ i, 0 ≤ w₂₀ i)
    (f₅ : mass w₅ 15 < g) (p₅ : g ≤ mass w₅ 16)
    (f₁₀ : mass w₁₀ 19 < g) (p₁₀ : g ≤ mass w₁₀ 20)
    (f₂₀ : mass w₂₀ 23 < g) (p₂₀ : g ≤ mass w₂₀ 24) :
    knee w₅ g = 16 ∧ knee w₁₀ g = 20 ∧ knee w₂₀ g = 24 ∧
      knee w₅ g < knee w₁₀ g ∧ knee w₁₀ g < knee w₂₀ g ∧ knee w₂₀ g ≤ 30 := by
  have e₅ : knee w₅ g = 16 := knee_eq_of_fail_pass h₅ (by simpa using f₅) p₅ (by norm_num)
  have e₁₀ : knee w₁₀ g = 20 := knee_eq_of_fail_pass h₁₀ (by simpa using f₁₀) p₁₀ (by norm_num)
  have e₂₀ : knee w₂₀ g = 24 := knee_eq_of_fail_pass h₂₀ (by simpa using f₂₀) p₂₀ (by norm_num)
  refine ⟨e₅, e₁₀, e₂₀, ?_, ?_, ?_⟩ <;> simp [e₅, e₁₀, e₂₀]

/-- **The chain is forced, not fitted.**  If each longer context spreads mass
(majorization) and still fails the gate at the previous knee, the knees are
strictly increasing — no numerology required. -/
theorem chain_strictly_monotone {w₅ w₁₀ w₂₀ : ℕ → ℝ} {g : ℝ}
    (n₁₀ : ∀ i, 0 ≤ w₁₀ i) (n₂₀ : ∀ i, 0 ≤ w₂₀ i)
    (e₁₀ : ∃ k, g ≤ mass w₁₀ k) (e₂₀ : ∃ k, g ≤ mass w₂₀ k)
    (s₁ : mass w₁₀ (knee w₅ g) < g) (s₂ : mass w₂₀ (knee w₁₀ g) < g) :
    knee w₅ g < knee w₁₀ g ∧ knee w₁₀ g < knee w₂₀ g :=
  ⟨knee_lt_of_still_failing n₁₀ e₁₀ s₁, knee_lt_of_still_failing n₂₀ e₂₀ s₂⟩

/-! ## 8. A concrete coarse-grid overestimate -/

/-- The dyadic attention profile `w i = 2^{-(i+1)}` (antitone, total mass 1). -/
noncomputable def geometricProfile : ℕ → ℝ := fun i => (1 / 2) ^ (i + 1)

lemma geometricProfile_nonneg (i : ℕ) : 0 ≤ geometricProfile i := by
  unfold geometricProfile; positivity

lemma geometricProfile_antitone : Antitone geometricProfile := by
  intro a b hab
  unfold geometricProfile
  exact pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)

lemma mass_geometricProfile (k : ℕ) :
    mass geometricProfile k = 1 - (1 / 2) ^ k := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [mass_succ, ih]
      unfold geometricProfile
      ring

/-- Its knee at gate `0.98` is exactly `6`. -/
theorem knee_geometricProfile : knee geometricProfile 0.98 = 6 := by
  refine knee_eq_of_fail_pass geometricProfile_nonneg ?_ ?_ (by norm_num)
  · norm_num [mass_geometricProfile]
  · norm_num [mass_geometricProfile]

/-- **A coarse grid genuinely overestimates.**  On the power-of-two grid
`{2, 4, 8, 16}` the same profile reports a knee of `8`, a `33%` over-provision;
adding the single point `6` recovers the truth.  (Compare NET-63's coarse `28`
versus fine `24`.) -/
theorem geometric_coarse_grid_overestimates :
    gridKnee {2, 4, 8, 16} geometricProfile 0.98 = 8 ∧
      gridKnee {2, 4, 6, 8, 16} geometricProfile 0.98 = 6 ∧
      knee geometricProfile 0.98 = 6 := by
  have hpass6 : (0.98 : ℝ) ≤ mass geometricProfile 6 := by
    norm_num [mass_geometricProfile]
  have hpass8 : (0.98 : ℝ) ≤ mass geometricProfile 8 := by
    norm_num [mass_geometricProfile]
  refine ⟨le_antisymm (gridKnee_le_of_mem (by simp) hpass8) ?_, ?_, knee_geometricProfile⟩
  · -- no grid point below 8 passes
    have h : ∃ k, k ∈ ({2, 4, 8, 16} : Set ℕ) ∧ (0.98:ℝ) ≤ mass geometricProfile k :=
      ⟨8, by simp, hpass8⟩
    obtain ⟨hmem, hp⟩ := gridKnee_mem h
    have hge : 6 ≤ gridKnee {2, 4, 8, 16} geometricProfile 0.98 := by
      have := knee_le_gridKnee h
      rwa [knee_geometricProfile] at this
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hmem
    rcases hmem with h2 | h4 | h8 | h16 <;> omega
  · refine le_antisymm (gridKnee_le_of_mem (by simp) hpass6) ?_
    have h : ∃ k, k ∈ ({2, 4, 6, 8, 16} : Set ℕ) ∧ (0.98:ℝ) ≤ mass geometricProfile k :=
      ⟨6, by simp, hpass6⟩
    have := knee_le_gridKnee h
    rwa [knee_geometricProfile] at this

/-! ## 9. Non-vacuity: the deployment hypotheses are realizable -/

/-- The step (plateau) profile: mass `c` on each of the first `K` keys. -/
def stepProfile (K : ℕ) (c : ℝ) : ℕ → ℝ := fun i => if i < K then c else 0

lemma stepProfile_nonneg {K : ℕ} {c : ℝ} (hc : 0 ≤ c) (i : ℕ) :
    0 ≤ stepProfile K c i := by
  unfold stepProfile; split <;> simp [hc]

lemma stepProfile_antitone {K : ℕ} {c : ℝ} (hc : 0 ≤ c) : Antitone (stepProfile K c) := by
  intro a b hab
  unfold stepProfile
  by_cases hb : b < K
  · simp [hb, show a < K by omega]
  · simp [hb]
    split <;> simp [hc]

lemma mass_stepProfile (K : ℕ) (c : ℝ) (k : ℕ) :
    mass (stepProfile K c) k = c * (min k K : ℕ) := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [mass_succ, ih]
      unfold stepProfile
      rcases lt_or_ge n K with h | h
      · have h1 : min n K = n := by omega
        simp [h, h1]
        ring
      · have h1 : min n K = K := by omega
        have h2 : min (n + 1) K = K := by omega
        simp [Nat.not_lt.mpr h, h1, h2]

/-- The plateau profile spreading mass `g` over `K` keys just misses the gate
with `K - 1` keys. -/
lemma mass_stepProfile_pred_lt {g : ℝ} (hg : 0 < g) {K : ℕ} (hK : 1 ≤ K) :
    mass (stepProfile K (g / K)) (K - 1) < g := by
  have hKR : (0:ℝ) < K := by exact_mod_cast hK
  rw [mass_stepProfile, show min (K - 1) K = K - 1 from by omega]
  have hcast : ((K - 1 : ℕ) : ℝ) = (K : ℝ) - 1 := by
    push_cast [Nat.cast_sub hK]; ring
  rw [hcast, div_mul_eq_mul_div, div_lt_iff₀ hKR]
  nlinarith

/-- … and meets it exactly with `K` keys. -/
lemma mass_stepProfile_self {g : ℝ} {K : ℕ} (hK : 1 ≤ K) :
    mass (stepProfile K (g / K)) K = g := by
  have hKR : (0:ℝ) < K := by exact_mod_cast hK
  rw [mass_stepProfile, show min K K = K from by omega,
    div_mul_cancel₀ _ (ne_of_gt hKR)]

/-- The plateau profile has knee exactly `K`. -/
lemma knee_stepProfile {g : ℝ} (hg : 0 < g) {K : ℕ} (hK : 1 ≤ K) :
    knee (stepProfile K (g / K)) g = K :=
  knee_eq_of_fail_pass (stepProfile_nonneg (by positivity))
    (mass_stepProfile_pred_lt hg hK) (le_of_eq (mass_stepProfile_self hK).symm) hK

/-- Every positive key count `K` is the knee of an honest sorted profile. -/
theorem exists_profile_with_knee {g : ℝ} (hg : 0 < g) {K : ℕ} (hK : 1 ≤ K) :
    ∃ w : ℕ → ℝ, (∀ i, 0 ≤ w i) ∧ Antitone w ∧ mass w (K - 1) < g ∧
      g ≤ mass w K ∧ knee w g = K :=
  ⟨stepProfile K (g / K), stepProfile_nonneg (by positivity),
    stepProfile_antitone (by positivity), mass_stepProfile_pred_lt hg hK,
    le_of_eq (mass_stepProfile_self hK).symm, knee_stepProfile hg hK⟩

/-- **The deployment chain is not vacuous.**  There really are sorted,
nonnegative attention profiles realizing the fail/pass certificates at
`16, 20, 24` for the gate `0.98`, hence realizing `deployment_chain`. -/
theorem deployment_chain_realizable :
    ∃ w₅ w₁₀ w₂₀ : ℕ → ℝ,
      (∀ i, 0 ≤ w₅ i) ∧ (∀ i, 0 ≤ w₁₀ i) ∧ (∀ i, 0 ≤ w₂₀ i) ∧
      mass w₅ 15 < 0.98 ∧ (0.98:ℝ) ≤ mass w₅ 16 ∧
      mass w₁₀ 19 < 0.98 ∧ (0.98:ℝ) ≤ mass w₁₀ 20 ∧
      mass w₂₀ 23 < 0.98 ∧ (0.98:ℝ) ≤ mass w₂₀ 24 ∧
      knee w₅ 0.98 = 16 ∧ knee w₁₀ 0.98 = 20 ∧ knee w₂₀ 0.98 = 24 := by
  obtain ⟨a, ha0, -, haf, hap, hak⟩ :=
    exists_profile_with_knee (g := (0.98:ℝ)) (by norm_num) (K := 16) (by norm_num)
  obtain ⟨b, hb0, -, hbf, hbp, hbk⟩ :=
    exists_profile_with_knee (g := (0.98:ℝ)) (by norm_num) (K := 20) (by norm_num)
  obtain ⟨c, hc0, -, hcf, hcp, hck⟩ :=
    exists_profile_with_knee (g := (0.98:ℝ)) (by norm_num) (K := 24) (by norm_num)
  exact ⟨a, b, c, ha0, hb0, hc0, by simpa using haf, hap, by simpa using hbf, hbp,
    by simpa using hcf, hcp, hak, hbk, hck⟩

/-! ## 10. Mixtures: multi-head budgets -/

/-- Retained mass is linear in the profile. -/
lemma mass_linear (a b : ℝ) (u v : ℕ → ℝ) (k : ℕ) :
    mass (fun i => a * u i + b * v i) k = a * mass u k + b * mass v k := by
  simp [mass, Finset.sum_add_distrib, Finset.mul_sum]

/-- **Averaging heads never costs keys.**  A convex mixture of two attention
profiles has a knee no larger than the worse of the two: budgeting for the
harder head suffices for any blend of them. -/
theorem knee_mixture_le_max {u v : ℕ → ℝ} {g lam : ℝ} (hu : ∀ i, 0 ≤ u i)
    (hv : ∀ i, 0 ≤ v i) (hlam0 : 0 ≤ lam) (hlam1 : lam ≤ 1)
    (hexu : ∃ k, g ≤ mass u k) (hexv : ∃ k, g ≤ mass v k) :
    knee (fun i => lam * u i + (1 - lam) * v i) g ≤ max (knee u g) (knee v g) := by
  set K := max (knee u g) (knee v g) with hK
  have hu' : g ≤ mass u K := le_trans (knee_pass hexu) (mass_mono hu (le_max_left _ _))
  have hv' : g ≤ mass v K := le_trans (knee_pass hexv) (mass_mono hv (le_max_right _ _))
  refine knee_le_of_pass ?_
  rw [mass_linear]
  nlinarith

/-!
## Lab Notes (experimental data used)

* NET-63 round 16, corpus-A, context 2048, gate `0.98` exact, 12 windows:
  `k = 20 → 0.9793 ✗`, `k = 24 → 0.9835 ✓`, `k = 28 → 0.9854 ✓`,
  `k = 32 → 0.9885 ✓`.  Formalised in `net63R`.
* Deployment chain: knees `16, 20, 24` at contexts `512, 1024, 2048`
  (`deployment_chain`).
* Derived facts: margin at 24 is `+0.0035` = five times the deficit at 20
  (`net63_margin_ratio`); the knee is bracketed by `20 < k* ≤ 24`
  (`net63_knee_bracket`).
* Negative finding: the four reported numbers are not window-averaged top-`k`
  masses of sorted rows (`net63_fine2048_not_window_averaged_topk`), because
  `0.9854 - 0.9835 = 0.0019 < 0.0031 = 0.9885 - 0.9854` breaks discrete
  concavity.
-/

end Bridges.AttentionKneeGeometry