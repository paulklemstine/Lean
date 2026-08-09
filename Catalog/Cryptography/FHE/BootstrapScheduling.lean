import Cryptography.FHE.Bootstrapping

/-!
# Optimal bootstrap scheduling

`Cryptography.FHE.Bootstrapping` shows that refreshing every `L` levels succeeds
whenever `L` levels of noise growth stay under the decoding radius `T`.  This
file proves the matching *lower* bound: no schedule of bootstraps can do better.

A **schedule** is the list of block lengths between consecutive refreshes.  Its
total multiplicative depth is the sum of the list and its bootstrap count is the
length of the list.  Writing `L` for the largest safe block length, we prove:

* `Schedule.block_le_of_safe` — a correct schedule has every block of length
  `≤ L`, because the noise iteration is monotone in depth;
* `Schedule.depth_le_smul` — hence total depth `≤ L · (number of bootstraps)`;
* `Schedule.ceilDiv_le_bootstraps` — the number of bootstraps is at least
  `⌈d/L⌉`, matching the `⌈d/L⌉` refreshes used by `bootIter`;
* `Schedule.uniform_is_optimal` — the uniform schedule `replicate ⌈d/L⌉ L` is
  therefore an optimal bootstrap placement.

The monotonicity input (`iterD_mono_depth_of_one_le`) is where the mathematics
happens: for `γ ≥ 1`, `D ≥ 0` and a starting level `≥ 1` the quadratic noise map
is expanding, so longer blocks are strictly worse and greedy scheduling is
optimal.  Note the hypothesis `1 ≤ Bmin`: in normalized units this says that a
refreshed ciphertext still carries at least one unit of noise, which is exactly
what makes the refresh count nontrivial.
-/

namespace FHENoise

noncomputable section

/-! ## 1. Monotonicity of the noise iteration in the depth -/

lemma one_le_iterD {gamma D x : ℝ} (hg : 1 ≤ gamma) (hD : 0 ≤ D) (hx : 1 ≤ x) :
    ∀ d, 1 ≤ iterD gamma D d x
  | 0 => hx
  | (d + 1) => by
      have ih := one_le_iterD hg hD hx d
      simp only [iterD_succ, noiseStep]
      nlinarith

/-- Above noise level `1` the quadratic map is expanding: each extra level can
only increase the noise. -/
lemma iterD_le_succ {gamma D x : ℝ} (hg : 1 ≤ gamma) (hD : 0 ≤ D) (hx : 1 ≤ x) (d : ℕ) :
    iterD gamma D d x ≤ iterD gamma D (d + 1) x := by
  have h1 := one_le_iterD hg hD hx d
  simp only [iterD_succ, noiseStep]
  nlinarith

/-- Monotonicity of the noise level in the multiplicative depth. -/
lemma iterD_mono_depth_of_one_le {gamma D x : ℝ} (hg : 1 ≤ gamma) (hD : 0 ≤ D) (hx : 1 ≤ x)
    {d e : ℕ} (hde : d ≤ e) : iterD gamma D d x ≤ iterD gamma D e x := by
  induction e with
  | zero =>
      have : d = 0 := Nat.le_zero.mp hde
      simp [this]
  | succ k ih =>
      rcases Nat.lt_or_ge d (k + 1) with h | h
      · exact le_trans (ih (Nat.lt_succ_iff.mp h)) (iterD_le_succ hg hD hx k)
      · have : d = k + 1 := le_antisymm hde h
        simp [this]

/-! ## 2. Schedules -/

namespace Schedule

/-- The multiplicative depth realized by a schedule of block lengths. -/
def depth (sch : List ℕ) : ℕ := sch.sum

/-- The number of bootstraps performed by a schedule. -/
def bootstraps (sch : List ℕ) : ℕ := sch.length

/-- A schedule is *safe* for the parameters if every block, started from the
refreshed noise level `Bmin`, stays inside the decoding radius `T`. -/
def Safe (gamma D Bmin T : ℝ) (sch : List ℕ) : Prop :=
  ∀ n ∈ sch, iterD gamma D n Bmin ≤ T

/-- **Every block of a safe schedule is short.**  If `L + 1` levels already
overshoot the decoding radius, no safe schedule contains a block longer than
`L`. -/
theorem block_le_of_safe {gamma D Bmin T : ℝ} (hg : 1 ≤ gamma) (hD : 0 ≤ D)
    (hB : 1 ≤ Bmin) {L : ℕ} (hL : T < iterD gamma D (L + 1) Bmin)
    {sch : List ℕ} (hsafe : Safe gamma D Bmin T sch) : ∀ n ∈ sch, n ≤ L := by
  intro n hn
  by_contra hlt
  have hge : L + 1 ≤ n := by omega
  have := iterD_mono_depth_of_one_le (x := Bmin) hg hD hB hge
  exact absurd (hsafe n hn) (not_le.mpr (lt_of_lt_of_le hL this))

/-- **Depth is bounded by blocks × bootstraps.** -/
theorem depth_le_smul {gamma D Bmin T : ℝ} (hg : 1 ≤ gamma) (hD : 0 ≤ D)
    (hB : 1 ≤ Bmin) {L : ℕ} (hL : T < iterD gamma D (L + 1) Bmin)
    {sch : List ℕ} (hsafe : Safe gamma D Bmin T sch) :
    depth sch ≤ L * bootstraps sch := by
  have h := List.sum_le_card_nsmul sch L (block_le_of_safe hg hD hB hL hsafe)
  simpa [depth, bootstraps, smul_eq_mul, Nat.mul_comm] using h

/-- **Lower bound on the number of bootstraps.**  Reaching multiplicative depth
`d` requires at least `⌈d/L⌉` bootstraps, exactly the number performed by the
uniform schedule of `Bootstrapping.bootIter`. -/
theorem ceilDiv_le_bootstraps {gamma D Bmin T : ℝ} (hg : 1 ≤ gamma) (hD : 0 ≤ D)
    (hB : 1 ≤ Bmin) {L : ℕ} (hLpos : 0 < L) (hL : T < iterD gamma D (L + 1) Bmin)
    {sch : List ℕ} (hsafe : Safe gamma D Bmin T sch) :
    depth sch ⌈/⌉ L ≤ bootstraps sch :=
  (ceilDiv_le_iff_le_smul hLpos).mpr (depth_le_smul hg hD hB hL hsafe)

/-- **Optimality of the uniform schedule.**  For any target depth `d`, the
schedule consisting of `⌈d/L⌉` blocks of `L` levels is safe, reaches depth at
least `d`, and uses exactly the minimum possible number of bootstraps. -/
theorem uniform_is_optimal {gamma D Bmin T : ℝ} (hg : 1 ≤ gamma) (hD : 0 ≤ D)
    (hB : 1 ≤ Bmin) {L : ℕ} (hLpos : 0 < L) (hL : T < iterD gamma D (L + 1) Bmin)
    (hsafeL : iterD gamma D L Bmin ≤ T) (d : ℕ) :
    Safe gamma D Bmin T (List.replicate (d ⌈/⌉ L) L) ∧
      d ≤ depth (List.replicate (d ⌈/⌉ L) L) ∧
      bootstraps (List.replicate (d ⌈/⌉ L) L) = d ⌈/⌉ L ∧
      (∀ sch : List ℕ, Safe gamma D Bmin T sch → d ≤ depth sch →
        bootstraps (List.replicate (d ⌈/⌉ L) L) ≤ bootstraps sch) := by
  refine ⟨?_, ?_, by simp [bootstraps], ?_⟩
  · intro n hn
    rw [List.eq_of_mem_replicate hn]
    exact hsafeL
  · have hsum : depth (List.replicate (d ⌈/⌉ L) L) = (d ⌈/⌉ L) * L := by
      simp [depth, List.sum_replicate, smul_eq_mul]
    rw [hsum]
    have := (ceilDiv_le_iff_le_smul (a := L) (b := d) (c := d ⌈/⌉ L) hLpos).mp (le_refl _)
    simpa [Nat.mul_comm] using this
  · intro sch hsch hd
    have hlow := ceilDiv_le_bootstraps hg hD hB hLpos hL hsch
    have : d ⌈/⌉ L ≤ depth sch ⌈/⌉ L := by
      simp only [Nat.ceilDiv_eq_add_pred_div]
      exact Nat.div_le_div_right (by omega)
    simp only [bootstraps, List.length_replicate]
    exact le_trans this hlow

end Schedule

end

end FHENoise