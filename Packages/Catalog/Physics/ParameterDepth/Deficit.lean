import Physics.ParameterDepth.Composition

/-!
# Parameter-derived depth, VI: how often does the coarse-level overhead cost a level?

`TreeDepth.foamDepth_deficit` says that charging for *all* levels of the cascade rather
than only for its leaves costs either `0` or `1` level of depth:

`deficit B T = Nat.log B T - foamDepth B T ∈ {0, 1}`.

This file determines *exactly* which budgets pay the extra level, and with what
frequency.  Fix a scale `L` and look at the block of budgets `B^L ≤ T < B^(L+1)` (those
with `Nat.log B T = L`).  Then:

* `lossless_filter_eq` — the lossless budgets form the interval `[foamCells B L, B^(L+1))`;
* `lossy_filter_eq` — the lossy ones form `[B^L, foamCells B L)`;
* `lossy_card` — **self-similarity**: the number of lossy budgets at scale `L` is exactly
  `foamCells B (L-1)`, the total cell count of a cascade one level shallower;
* `lossy_card_geom` — equivalently `(B-1) · #lossy + 1 = B^L`;
* `lossy_density_tendsto` — the fraction of lossy budgets in the block converges to
  `1 / (B-1)²`.  For binary foam (`B = 2`) that limit is `1`: *almost every* information
  budget pays the extra level; for large branching numbers the penalty becomes rare.

The last statement is a genuine analytic limit extracted from a purely arithmetic
counting identity, and it quantifies the physical statement "the coarse-grained levels of
a Wheeler foam are (or are not) a negligible part of its information budget".
-/

namespace Physics.ParameterDepth

open Filter Topology

/-- How many levels of depth are lost by charging for the whole cascade instead of only
its finest level. -/
def deficit (B T : ℕ) : ℕ := Nat.log B T - foamDepth B T

theorem deficit_le_one {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) : deficit B T ≤ 1 := by
  have h := foamDepth_deficit hB hT
  simp only [deficit]
  omega

theorem deficit_eq_zero_iff {B T : ℕ} (hB : 2 ≤ B) (hT : 1 ≤ T) :
    deficit B T = 0 ↔ foamCells B (Nat.log B T) ≤ T := by
  rw [← foamDepth_eq_log_iff hB hT]
  have h := foamDepth_deficit hB hT
  simp only [deficit]
  omega

/-- The budgets at scale `L`: exactly those with `Nat.log B T = L`. -/
def scaleBlock (B L : ℕ) : Finset ℕ := Finset.Ico (B ^ L) (B ^ (L + 1))

theorem log_eq_of_mem_scaleBlock {B L T : ℕ} (h : T ∈ scaleBlock B L) :
    Nat.log B T = L := by
  rw [scaleBlock, Finset.mem_Ico] at h
  exact Nat.log_eq_of_pow_le_of_lt_pow h.1 h.2

theorem one_le_of_mem_scaleBlock {B L T : ℕ} (hB : 2 ≤ B) (h : T ∈ scaleBlock B L) : 1 ≤ T := by
  rw [scaleBlock, Finset.mem_Ico] at h
  exact le_trans (Nat.one_le_pow _ _ (by omega)) h.1

/-- **Lossless budgets at scale `L`.** -/
theorem lossless_filter_eq {B L : ℕ} (hB : 2 ≤ B) :
    (scaleBlock B L).filter (fun T => deficit B T = 0)
      = Finset.Ico (foamCells B L) (B ^ (L + 1)) := by
  ext T
  simp only [Finset.mem_filter, Finset.mem_Ico, scaleBlock] at *
  constructor
  · rintro ⟨⟨h1, h2⟩, hd⟩
    have hT : 1 ≤ T := le_trans (Nat.one_le_pow _ _ (by omega)) h1
    have hlog : Nat.log B T = L := Nat.log_eq_of_pow_le_of_lt_pow h1 h2
    have := (deficit_eq_zero_iff hB hT).1 hd
    rw [hlog] at this
    exact ⟨this, h2⟩
  · rintro ⟨h1, h2⟩
    have hpow : B ^ L ≤ T := le_trans (pow_le_foamCells B L) h1
    have hT : 1 ≤ T := le_trans (Nat.one_le_pow _ _ (by omega)) hpow
    have hlog : Nat.log B T = L := Nat.log_eq_of_pow_le_of_lt_pow hpow h2
    refine ⟨⟨hpow, h2⟩, ?_⟩
    rw [deficit_eq_zero_iff hB hT, hlog]
    exact h1

/-- **Lossy budgets at scale `L`.** -/
theorem lossy_filter_eq {B L : ℕ} (hB : 2 ≤ B) :
    (scaleBlock B L).filter (fun T => deficit B T = 1)
      = Finset.Ico (B ^ L) (foamCells B L) := by
  ext T
  simp only [Finset.mem_filter, Finset.mem_Ico, scaleBlock] at *
  constructor
  · rintro ⟨⟨h1, h2⟩, hd⟩
    have hT : 1 ≤ T := le_trans (Nat.one_le_pow _ _ (by omega)) h1
    have hlog : Nat.log B T = L := Nat.log_eq_of_pow_le_of_lt_pow h1 h2
    have hne : deficit B T ≠ 0 := by omega
    have : ¬ foamCells B (Nat.log B T) ≤ T := fun h => hne ((deficit_eq_zero_iff hB hT).2 h)
    rw [hlog] at this
    exact ⟨h1, by omega⟩
  · rintro ⟨h1, h2⟩
    have hT : 1 ≤ T := le_trans (Nat.one_le_pow _ _ (by omega)) h1
    have hup : T < B ^ (L + 1) :=
      lt_of_lt_of_le h2 (foamCells_le_pow_succ hB L)
    have hlog : Nat.log B T = L := Nat.log_eq_of_pow_le_of_lt_pow h1 hup
    refine ⟨⟨h1, hup⟩, ?_⟩
    have hd1 : deficit B T ≤ 1 := deficit_le_one hB hT
    have hd0 : deficit B T ≠ 0 := by
      intro h
      have := (deficit_eq_zero_iff hB hT).1 h
      rw [hlog] at this
      omega
    omega

/-- **Self-similarity of the deficit.**  At scale `L ≥ 1` the number of budgets paying the
extra level equals the total cell count of a cascade of depth `L - 1`. -/
theorem lossy_card {B L : ℕ} (hB : 2 ≤ B) (hL : 1 ≤ L) :
    ((scaleBlock B L).filter (fun T => deficit B T = 1)).card = foamCells B (L - 1) := by
  rw [lossy_filter_eq hB, Nat.card_Ico]
  have hsucc : foamCells B L = foamCells B (L - 1) + B ^ (L - 1 + 1) := by
    conv_lhs => rw [show L = (L - 1) + 1 by omega]
    rw [foamCells_succ]
  have hidx : L - 1 + 1 = L := by omega
  rw [hidx] at hsucc
  omega

/-- Equivalent geometric form of the count. -/
theorem lossy_card_geom {B L : ℕ} (hB : 2 ≤ B) (hL : 1 ≤ L) :
    (B - 1) * ((scaleBlock B L).filter (fun T => deficit B T = 1)).card + 1 = B ^ L := by
  rw [lossy_card hB hL]
  have h := foamCells_geom (by omega : 1 ≤ B) (L - 1)
  rw [show L - 1 + 1 = L by omega] at h
  exact h

/-- The scale-`L` block has `B^(L+1) - B^L` budgets in it. -/
theorem scaleBlock_card {B L : ℕ} : (scaleBlock B L).card = B ^ (L + 1) - B ^ L := by
  rw [scaleBlock, Nat.card_Ico]

/-- **Density of the depth penalty.**  The fraction of scale-`L` budgets that lose a level
tends to `1 / (B-1)²`.  For `B = 2` this is `1`: binary foam almost always pays the
overhead; for `B ≥ 3` the penalty has density `< 1`. -/
theorem lossy_density_tendsto {B : ℕ} (hB : 2 ≤ B) :
    Tendsto
      (fun L : ℕ =>
        (((scaleBlock B L).filter (fun T => deficit B T = 1)).card : ℝ) /
          ((B : ℝ) ^ (L + 1) - (B : ℝ) ^ L))
      atTop (𝓝 (1 / ((B : ℝ) - 1) ^ 2)) := by
  have hB1 : (1 : ℝ) < B := by exact_mod_cast hB
  have hBpos : (0 : ℝ) < B := by linarith
  have hBm : (0 : ℝ) < (B : ℝ) - 1 := by linarith
  -- the counting identity, transported to `ℝ`
  have hcount : ∀ L : ℕ, 1 ≤ L →
      (((scaleBlock B L).filter (fun T => deficit B T = 1)).card : ℝ)
        = ((B : ℝ) ^ L - 1) / ((B : ℝ) - 1) := by
    intro L hL
    have h := lossy_card_geom hB hL
    have hcast : ((B : ℝ) - 1) *
        (((scaleBlock B L).filter (fun T => deficit B T = 1)).card : ℝ) + 1 = (B : ℝ) ^ L := by
      have := congrArg (fun n : ℕ => (n : ℝ)) h
      push_cast [Nat.cast_sub (by omega : 1 ≤ B)] at this
      linarith [this]
    field_simp
    linarith [hcast]
  -- the target function eventually equals `(1 - (1/B)^L) / (B-1)^2`
  have heq : ∀ᶠ L : ℕ in atTop,
      (((scaleBlock B L).filter (fun T => deficit B T = 1)).card : ℝ) /
          ((B : ℝ) ^ (L + 1) - (B : ℝ) ^ L)
        = (1 - (1 / (B : ℝ)) ^ L) / ((B : ℝ) - 1) ^ 2 := by
    filter_upwards [eventually_ge_atTop 1] with L hL
    rw [hcount L hL]
    have hpow : (0 : ℝ) < (B : ℝ) ^ L := by positivity
    have hden : (B : ℝ) ^ (L + 1) - (B : ℝ) ^ L = ((B : ℝ) - 1) * (B : ℝ) ^ L := by
      rw [pow_succ]; ring
    rw [hden, div_pow, one_pow]
    field_simp
  refine Tendsto.congr' (Filter.EventuallyEq.symm heq) ?_
  have hzero : Tendsto (fun L : ℕ => (1 / (B : ℝ)) ^ L) atTop (𝓝 0) := by
    refine tendsto_pow_atTop_nhds_zero_of_lt_one (by positivity) ?_
    rw [div_lt_one hBpos]
    exact hB1
  have := ((tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub hzero).div_const
    (((B : ℝ) - 1) ^ 2)
  simpa using this

end Physics.ParameterDepth