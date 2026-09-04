import MachineLearning.ForkChannelCorrelation

/-!
# Table closure for fork channels: ordering, decay, and the (non-)crossover

`MachineLearning.ForkChannelCorrelation` proved that the four fork channels of an
`(n+1)`-bit Bernoulli(`p`) fork are all values of one rational profile

`Φ(t, n) = tⁿ / (1 + t + ⋯ + tⁿ)`,

namely `A = Φ(p, ·)`, `g = Φ(1-p, ·)`, `X = Φ((1-2p)², ·)`, `Is = Φ(1, ·)`.

This file develops `Φ` and closes the tables:

* **Monotonicity** (`Phi_le_iff`): `Φ(s, n) ≤ Φ(t, n) ↔ s ≤ t` for `n ≥ 1`.
  Hence the whole comparison problem between fork channels collapses to comparing
  the four *channel parameters* `p`, `1-p`, `(1-2p)²`, `1`.

* **H1 (confirmed, and sharpened)**: `Is ≥ max(g, A, X)` for every `p` and every
  size (`isChan_ge_max`); `A ≥ g ↔ p ≥ 1/2` (`aChan_ge_gChan_iff`); and
  `A ≥ X ↔ p ≥ 1/4` (`aChan_ge_xChan_iff`).

* **The crossover is an artifact (H1's `n = 8` claim refuted)**: the sign of
  `A - X` (and of `A - g`) does not depend on the number of bits at all
  (`aChan_xChan_crossover_free`, `no_AX_crossover`).  No fork of this kind can
  exhibit a finite crossover size.

* **H2 (confirmed)**: every channel tends to `0`, uniformly dominated by the
  split-count channel `1/(n+1)` (`Phi_le_one_div`, `*_tendsto_zero`).

* **H3 (refuted, in a strong form)**: the ratio `X / g` never tends to `2`
  (`xChan_div_gChan_not_tendsto_two`).  Its behaviour is a trichotomy governed by
  the single point `p = 3/4`, where the XOR and OR channels coincide *identically
  in n* (`xChan_eq_gChan_iff`).

* **Exact table entries** at `25` bits are recorded in closed rational form
  (`table25_*`), together with the exact ordering at that size.
-/

open Filter Topology

namespace ForkChannel

/-! ## The profile `Φ` -/

theorem geomSeries_pos {t : ℝ} (ht : 0 ≤ t) (n : ℕ) :
    0 < ∑ k ∈ Finset.range (n+1), t ^ k :=
  Finset.sum_pos' (fun k _ => pow_nonneg ht k)
    ⟨0, Finset.mem_range.mpr (Nat.succ_pos n), by simp⟩

theorem Phi_nonneg {t : ℝ} (ht : 0 ≤ t) (n : ℕ) : 0 ≤ Phi t n :=
  div_nonneg (pow_nonneg ht n) (geomSeries_pos ht n).le

theorem Phi_pos {t : ℝ} (ht : 0 < t) (n : ℕ) : 0 < Phi t n :=
  div_pos (pow_pos ht n) (geomSeries_pos ht.le n)

/-- The termwise comparison behind every ordering statement in this file. -/
theorem pow_cross_le {s t : ℝ} (hs : 0 ≤ s) (hst : s ≤ t) {n k : ℕ} (hkn : k ≤ n) :
    s ^ n * t ^ k ≤ t ^ n * s ^ k := by
  have ht : 0 ≤ t := le_trans hs hst
  have h1 : s ^ n = s ^ k * s ^ (n - k) := by rw [← pow_add]; congr 1; omega
  have h2 : t ^ n = t ^ k * t ^ (n - k) := by rw [← pow_add]; congr 1; omega
  have h3 : s ^ (n - k) ≤ t ^ (n - k) := pow_le_pow_left₀ hs hst (n - k)
  have h5 : (0:ℝ) ≤ s ^ k * t ^ k := mul_nonneg (pow_nonneg hs k) (pow_nonneg ht k)
  rw [h1, h2]
  nlinarith [mul_le_mul_of_nonneg_left h3 h5]

theorem Phi_mono {s t : ℝ} (hs : 0 ≤ s) (hst : s ≤ t) (n : ℕ) : Phi s n ≤ Phi t n := by
  have ht : 0 ≤ t := le_trans hs hst
  rw [Phi, Phi, div_le_div_iff₀ (geomSeries_pos hs n) (geomSeries_pos ht n),
    Finset.mul_sum, Finset.mul_sum]
  exact Finset.sum_le_sum
    (fun k hk => pow_cross_le hs hst (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)))

theorem Phi_strictMono {s t : ℝ} (hs : 0 ≤ s) (hst : s < t) {n : ℕ} (hn : 1 ≤ n) :
    Phi s n < Phi t n := by
  have ht : 0 ≤ t := le_trans hs hst.le
  rw [Phi, Phi, div_lt_div_iff₀ (geomSeries_pos hs n) (geomSeries_pos ht n),
    Finset.mul_sum, Finset.mul_sum]
  refine Finset.sum_lt_sum
    (fun k hk => pow_cross_le hs hst.le (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)))
    ⟨0, Finset.mem_range.mpr (Nat.succ_pos n), ?_⟩
  simpa using pow_lt_pow_left₀ hst hs (by omega : n ≠ 0)

/-- **Order rigidity of the profile.**  For a fork with at least two bits the
comparison of two channels is *exactly* the comparison of their parameters. -/
theorem Phi_le_iff {s t : ℝ} (hs : 0 ≤ s) (ht : 0 ≤ t) {n : ℕ} (hn : 1 ≤ n) :
    Phi s n ≤ Phi t n ↔ s ≤ t := by
  refine ⟨fun h => ?_, fun h => Phi_mono hs h n⟩
  by_contra hc
  push_neg at hc
  exact absurd h (not_le.mpr (Phi_strictMono ht hc hn))

theorem Phi_lt_iff {s t : ℝ} (hs : 0 ≤ s) (ht : 0 ≤ t) {n : ℕ} (hn : 1 ≤ n) :
    Phi s n < Phi t n ↔ s < t := by
  rw [← not_le, ← not_le, Phi_le_iff ht hs hn]

theorem Phi_eq_iff {s t : ℝ} (hs : 0 ≤ s) (ht : 0 ≤ t) {n : ℕ} (hn : 1 ≤ n) :
    Phi s n = Phi t n ↔ s = t := by
  rw [le_antisymm_iff, le_antisymm_iff, Phi_le_iff hs ht hn, Phi_le_iff ht hs hn]

theorem Phi_one (n : ℕ) : Phi 1 n = 1 / (n + 1) := by
  simp [Phi]

/-- Every channel of a fork is dominated by the split-count channel `1/(n+1)`. -/
theorem Phi_le_one_div {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (n : ℕ) : Phi t n ≤ 1 / (n + 1) := by
  rw [← Phi_one n]
  exact Phi_mono ht ht1 n

/-- Closed (complement) form of the profile below `1`. -/
theorem Phi_closed_form {t : ℝ} (ht : 0 ≤ t) (ht1 : t < 1) (n : ℕ) :
    Phi t n = t ^ n * (1 - t) / (1 - t ^ (n+1)) := by
  have hS : 0 < ∑ k ∈ Finset.range (n+1), t ^ k := geomSeries_pos ht n
  have hgeom : 1 - t ^ (n+1) = (1 - t) * ∑ k ∈ Finset.range (n+1), t ^ k := geom_identity t n
  have h1t : (0:ℝ) < 1 - t := by linarith
  rw [Phi, hgeom]
  field_simp

/-- Exact rational form of the profile: `Φ(a/b, n) = aⁿ (b - a) / (b^{n+1} - a^{n+1})`. -/
theorem Phi_rat {a b : ℝ} (ha : 0 ≤ a) (hab : a < b) (n : ℕ) :
    Phi (a / b) n = a ^ n * (b - a) / (b ^ (n+1) - a ^ (n+1)) := by
  have hb : 0 < b := lt_of_le_of_lt ha hab
  have ht : 0 ≤ a / b := div_nonneg ha hb.le
  have ht1 : a / b < 1 := (div_lt_one hb).mpr hab
  have hkey : (0:ℝ) < b ^ (n+1) - a ^ (n+1) := by
    have : a ^ (n+1) < b ^ (n+1) := pow_lt_pow_left₀ hab ha (Nat.succ_ne_zero n)
    linarith
  have hb0 : b ≠ 0 := hb.ne'
  have hbn : (b:ℝ) ^ n ≠ 0 := (pow_pos hb n).ne'
  have hbn1 : (b:ℝ) ^ (n+1) ≠ 0 := (pow_pos hb (n+1)).ne'
  have e1 : (1 : ℝ) - a / b = (b - a) / b := by field_simp
  have e2 : (1 : ℝ) - (a / b) ^ (n+1) = (b ^ (n+1) - a ^ (n+1)) / b ^ (n+1) := by
    rw [div_pow]; field_simp
  rw [Phi_closed_form ht ht1 n, div_pow, e1, e2, div_div_eq_mul_div,
    div_eq_div_iff hkey.ne' hkey.ne']
  field_simp
  ring

/-! ## Decay -/

theorem Phi_tendsto_zero {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) :
    Tendsto (fun n : ℕ => Phi t n) atTop (𝓝 0) := by
  refine squeeze_zero (fun n => Phi_nonneg ht n) (fun n => Phi_le_one_div ht ht1 n) ?_
  exact tendsto_one_div_add_atTop_nhds_zero_nat

theorem Phi_le_pow {t : ℝ} (ht : 0 ≤ t) (n : ℕ) : Phi t n ≤ t ^ n := by
  have h1 : (1:ℝ) ≤ ∑ k ∈ Finset.range (n+1), t ^ k := by
    have := Finset.single_le_sum (f := fun k => t ^ k)
      (fun k _ => pow_nonneg ht k) (Finset.mem_range.mpr (Nat.succ_pos n))
    simpa using this
  rw [Phi, div_le_iff₀ (geomSeries_pos ht n)]
  nlinarith [pow_nonneg ht n]

theorem pow_div_le_Phi {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (n : ℕ) :
    t ^ n / (n + 1) ≤ Phi t n := by
  have h1 : (∑ k ∈ Finset.range (n+1), t ^ k) ≤ (n : ℝ) + 1 := by
    have : (∑ k ∈ Finset.range (n+1), t ^ k) ≤ ∑ _k ∈ Finset.range (n+1), (1:ℝ) :=
      Finset.sum_le_sum (fun k _ => pow_le_one₀ ht ht1)
    simpa using this
  have hn : (0:ℝ) < (n : ℝ) + 1 := by positivity
  rw [Phi, div_le_div_iff₀ hn (geomSeries_pos ht n)]
  nlinarith [pow_nonneg ht n]

/-- A slower-decaying channel dwarfs a faster-decaying one: the ratio of profiles
with different parameters tends to `0`, geometrically. -/
theorem Phi_ratio_tendsto_zero {s t : ℝ} (hs : 0 ≤ s) (hst : s < t) (ht1 : t ≤ 1) :
    Tendsto (fun n : ℕ => Phi s n / Phi t n) atTop (𝓝 0) := by
  have ht : 0 < t := lt_of_le_of_lt hs hst
  have hr0 : 0 ≤ s / t := div_nonneg hs ht.le
  have hr1 : s / t < 1 := (div_lt_one ht).mpr hst
  refine squeeze_zero (fun n => div_nonneg (Phi_nonneg hs n) (Phi_nonneg ht.le n))
    (g := fun n : ℕ => ((n : ℝ) + 1) * (s / t) ^ n) (fun n => ?_) ?_
  · have hden : 0 < t ^ n / ((n : ℝ) + 1) := by positivity
    have hle : Phi s n / Phi t n ≤ s ^ n / (t ^ n / ((n : ℝ) + 1)) := by
      have hb : 0 < Phi t n := lt_of_lt_of_le hden (pow_div_le_Phi ht.le ht1 n)
      rw [div_le_div_iff₀ hb hden]
      nlinarith [Phi_le_pow hs n, pow_div_le_Phi ht.le ht1 n, Phi_nonneg hs n, pow_nonneg hs n]
    refine le_trans hle (le_of_eq ?_)
    have h1 : (t:ℝ) ^ n ≠ 0 := (pow_pos ht n).ne'
    show s ^ n / (t ^ n / ((n:ℝ) + 1)) = ((n:ℝ) + 1) * (s / t) ^ n
    rw [div_pow]
    field_simp
  · have h1 : Tendsto (fun n : ℕ => (n : ℝ) * (s / t) ^ n) atTop (𝓝 0) :=
      tendsto_self_mul_const_pow_of_lt_one hr0 hr1
    have h2 : Tendsto (fun n : ℕ => ((s / t) : ℝ) ^ n) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one hr0 hr1
    have := h1.add h2
    simpa [add_mul, one_mul] using this

/-! ## The four channel parameters -/

section Channels

variable {p : ℝ}

theorem param_nonneg_p (hp : 0 < p) : (0:ℝ) ≤ p := hp.le

theorem param_le_one_q (hp : 0 < p) : (1:ℝ) - p ≤ 1 := by linarith

theorem param_xor_nonneg (p : ℝ) : (0:ℝ) ≤ (1 - 2*p) ^ 2 := sq_nonneg _

theorem param_xor_le_one (hp : 0 < p) (hp1 : p < 1) : (1 - 2*p) ^ 2 ≤ 1 := by nlinarith

/-! ### H1: the split-count channel dominates -/

theorem isChan_ge_aChan (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : aChan p n ≤ isChan p n := by
  rw [aChan_eq hp hp1, isChan_eq hp hp1]
  exact Phi_mono hp.le (by linarith) n

theorem isChan_ge_gChan (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : gChan p n ≤ isChan p n := by
  rw [gChan_eq hp hp1, isChan_eq hp hp1]
  exact Phi_mono (by linarith) (by linarith) n

theorem isChan_ge_xChan (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : xChan p n ≤ isChan p n := by
  rw [xChan_eq hp hp1, isChan_eq hp hp1]
  exact Phi_mono (param_xor_nonneg p) (param_xor_le_one hp hp1) n

/-- **H1, confirmed**: the split-count channel dominates all three Boolean channels,
at every fork size and for every bias. -/
theorem isChan_ge_max (hp : 0 < p) (hp1 : p < 1) (n : ℕ) :
    max (max (gChan p n) (aChan p n)) (xChan p n) ≤ isChan p n :=
  max_le (max_le (isChan_ge_gChan hp hp1 n) (isChan_ge_aChan hp hp1 n)) (isChan_ge_xChan hp hp1 n)

/-- The split-count channel is exactly `1/(n+1)`: it is the profile at parameter `1`. -/
theorem isChan_value (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : isChan p n = 1 / (n + 1) := by
  rw [isChan_eq hp hp1, Phi_one]

/-! ### H1: AND versus OR, AND versus XOR -/

/-- `A ≥ g` exactly when the fork is majority-`true`; the fork size is irrelevant. -/
theorem aChan_ge_gChan_iff (hp : 0 < p) (hp1 : p < 1) {n : ℕ} (hn : 1 ≤ n) :
    gChan p n ≤ aChan p n ↔ 1/2 ≤ p := by
  rw [gChan_eq hp hp1, aChan_eq hp hp1, Phi_le_iff (by linarith) hp.le hn]
  constructor <;> intro h <;> linarith

/-- `A ≥ X` exactly when `p ≥ 1/4`; again, the fork size is irrelevant. -/
theorem aChan_ge_xChan_iff (hp : 0 < p) (hp1 : p < 1) {n : ℕ} (hn : 1 ≤ n) :
    xChan p n ≤ aChan p n ↔ 1/4 ≤ p := by
  rw [xChan_eq hp hp1, aChan_eq hp hp1, Phi_le_iff (param_xor_nonneg p) hp.le hn]
  constructor
  · intro h; nlinarith
  · intro h; nlinarith

/-- **The crossover is an artifact.**  Whether the AND channel beats the XOR channel
is decided by the bias alone: it cannot switch as the fork grows.  In particular no
"`A` overtakes `X` at `n = 8`" phenomenon is possible in this model. -/
theorem aChan_xChan_crossover_free (hp : 0 < p) (hp1 : p < 1) {m n : ℕ}
    (hm : 1 ≤ m) (hn : 1 ≤ n) :
    (xChan p m ≤ aChan p m ↔ xChan p n ≤ aChan p n) := by
  rw [aChan_ge_xChan_iff hp hp1 hm, aChan_ge_xChan_iff hp hp1 hn]

theorem no_AX_crossover (hp : 0 < p) (hp1 : p < 1) {m n : ℕ} (hm : 1 ≤ m) (hn : 1 ≤ n)
    (h : aChan p m < xChan p m) : aChan p n < xChan p n := by
  by_contra hc
  push_neg at hc
  exact absurd ((aChan_xChan_crossover_free hp hp1 hn hm).mp hc) (not_le.mpr h)

/-- The same rigidity for the AND/OR pair. -/
theorem aChan_gChan_crossover_free (hp : 0 < p) (hp1 : p < 1) {m n : ℕ}
    (hm : 1 ≤ m) (hn : 1 ≤ n) :
    (gChan p m ≤ aChan p m ↔ gChan p n ≤ aChan p n) := by
  rw [aChan_ge_gChan_iff hp hp1 hm, aChan_ge_gChan_iff hp hp1 hn]

/-! ### H2: every channel decays to zero -/

theorem aChan_tendsto_zero (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => aChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => (aChan_eq hp hp1 n).symm) ?_
  exact Phi_tendsto_zero hp.le hp1.le

theorem gChan_tendsto_zero (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => gChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => (gChan_eq hp hp1 n).symm) ?_
  exact Phi_tendsto_zero (by linarith) (by linarith)

theorem xChan_tendsto_zero (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => xChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => (xChan_eq hp hp1 n).symm) ?_
  exact Phi_tendsto_zero (param_xor_nonneg p) (param_xor_le_one hp hp1)

theorem isChan_tendsto_zero (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => isChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => (isChan_eq hp hp1 n).symm) ?_
  exact Phi_tendsto_zero zero_le_one le_rfl

/-! ### H3: the `X / g` ratio -/

/-- The XOR and OR channels coincide, *identically in the fork size*, exactly at
`p = 3/4`.  This is the unique degeneracy of the pair. -/
theorem xChan_eq_gChan_iff (hp : 0 < p) (hp1 : p < 1) {n : ℕ} (hn : 1 ≤ n) :
    xChan p n = gChan p n ↔ p = 3/4 := by
  rw [xChan_eq hp hp1, gChan_eq hp hp1,
    Phi_eq_iff (param_xor_nonneg p) (by linarith) hn]
  constructor
  · intro h; nlinarith
  · intro h; rw [h]; norm_num

/-- Below the degeneracy the XOR channel is exponentially weaker than the OR channel. -/
theorem xChan_div_gChan_tendsto_zero (hp : 0 < p) (hp1 : p < 3/4) :
    Tendsto (fun n : ℕ => xChan p n / gChan p n) atTop (𝓝 0) := by
  have hp1' : p < 1 := by linarith
  refine Tendsto.congr (fun n => by rw [xChan_eq hp hp1' n, gChan_eq hp hp1' n]) ?_
  refine Phi_ratio_tendsto_zero (param_xor_nonneg p) ?_ (by linarith)
  nlinarith

/-- Above the degeneracy the OR channel is exponentially weaker than the XOR channel. -/
theorem gChan_div_xChan_tendsto_zero (hp : 3/4 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => gChan p n / xChan p n) atTop (𝓝 0) := by
  have hp0 : 0 < p := by linarith
  refine Tendsto.congr (fun n => by rw [xChan_eq hp0 hp1 n, gChan_eq hp0 hp1 n]) ?_
  refine Phi_ratio_tendsto_zero (by linarith) ?_ (param_xor_le_one hp0 hp1)
  nlinarith

/-- **H3, refuted.**  For no bias does the XOR/OR ratio converge to `2`: it converges
to `0` below `p = 3/4`, equals `1` identically at `p = 3/4`, and diverges above it. -/
theorem xChan_div_gChan_not_tendsto_two (hp : 0 < p) (hp1 : p < 1) :
    ¬ Tendsto (fun n : ℕ => xChan p n / gChan p n) atTop (𝓝 2) := by
  intro hcon
  rcases lt_trichotomy p (3/4) with h | h | h
  · have h0 := xChan_div_gChan_tendsto_zero hp h
    have : (0:ℝ) = 2 := tendsto_nhds_unique h0 hcon
    norm_num at this
  · have hconst : ∀ n : ℕ, xChan p n / gChan p n = 1 := by
      intro n
      have hg : 0 < gChan p n := by
        rw [gChan_eq hp hp1 n]; exact Phi_pos (by linarith) n
      have hx : xChan p n = gChan p n := by
        rw [xChan_eq hp hp1 n, gChan_eq hp hp1 n, h]; norm_num
      rw [hx, div_self hg.ne']
    have h1 : Tendsto (fun n : ℕ => xChan p n / gChan p n) atTop (𝓝 1) := by
      simp [hconst]
    have : (1:ℝ) = 2 := tendsto_nhds_unique h1 hcon
    norm_num at this
  · have hp0 : 0 < p := by linarith
    have hinv : Tendsto (fun n : ℕ => (xChan p n / gChan p n)⁻¹) atTop (𝓝 (2:ℝ)⁻¹) :=
      hcon.inv₀ (by norm_num)
    have hswap : ∀ n : ℕ, (xChan p n / gChan p n)⁻¹ = gChan p n / xChan p n :=
      fun n => inv_div _ _
    have h0 : Tendsto (fun n : ℕ => gChan p n / xChan p n) atTop (𝓝 (2:ℝ)⁻¹) := by
      simpa [hswap] using hinv
    have hzero := gChan_div_xChan_tendsto_zero h hp1
    have : (2:ℝ)⁻¹ = 0 := tendsto_nhds_unique h0 hzero
    norm_num at this

end Channels

/-! ## The closed tables at 25 bits (`n = 24`)

With bias `p = 1/3`, all four channels have exact rational values.  Together with
`Phi_le_iff` these entries close the table: the ordering `X < A < g < Is` at 25 bits
is the ordering `(1-2p)² < p < 1-p < 1` of the channel parameters, and it is the same
at every fork size. -/

theorem table25_isChan : isChan (1/3 : ℝ) 24 = 1 / 25 := by
  rw [isChan_value (by norm_num) (by norm_num)]
  norm_num

theorem table25_aChan : aChan (1/3 : ℝ) 24 = 1 / 423644304721 := by
  rw [aChan_eq (by norm_num) (by norm_num),
    show (1/3 : ℝ) = 1 / 3 by norm_num, Phi_rat (by norm_num) (by norm_num)]
  norm_num

theorem table25_gChan : gChan (1/3 : ℝ) 24 = 16777216 / 847255055011 := by
  rw [gChan_eq (by norm_num) (by norm_num),
    show (1 : ℝ) - 1/3 = 2 / 3 by norm_num, Phi_rat (by norm_num) (by norm_num)]
  norm_num

theorem table25_xChan : xChan (1/3 : ℝ) 24 = 1 / 89737248461481573596281 := by
  rw [xChan_eq (by norm_num) (by norm_num),
    show ((1 : ℝ) - 2 * (1/3)) ^ 2 = 1 / 9 by norm_num, Phi_rat (by norm_num) (by norm_num)]
  norm_num

/-- The exact ordering of the closed 25-bit table. -/
theorem table25_ordering :
    xChan (1/3 : ℝ) 24 < aChan (1/3 : ℝ) 24 ∧
    aChan (1/3 : ℝ) 24 < gChan (1/3 : ℝ) 24 ∧
    gChan (1/3 : ℝ) 24 < isChan (1/3 : ℝ) 24 := by
  rw [table25_xChan, table25_aChan, table25_gChan, table25_isChan]
  norm_num

end ForkChannel