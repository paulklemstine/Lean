/-
# From counting to density: the `log n / log (1/δ)` lower bound

Building on `Bridges.DenseSumsetLower.Core`, this file converts the exact counting
criterion into statements about the density parameter `δ`:

* `DenseSumsetLower.exists_sumset_of_real_bounds` — the real-analytic repackaging of the
  counting criterion, with a slack parameter `ε` and an upper bound `M` for the size of
  the shift window;
* `DenseSumsetLower.eventually_floor_log_pow_le` — the analytic engine: if
  `c log b < 1` then `⌊c log N⌋ · b^{⌊c log N⌋} ≤ α N` for all large `N`;
* `DenseSumsetLower.exists_sumset_of_density` — the integer-interval instance: if
  `|S| ≥ δ n`, `k ≤ ε δ n` and `k (2/((1-ε)δ))^k ≤ δ n`, then `S ⊆ [n]` contains a sumset
  `A + B` with `|A| = |B| = k`;
* `DenseSumsetLower.eventually_exists_sumset_of_density` — consequently, for every
  `c < 1 / log (2/δ)`, *every* `δ`-dense subset of `[n]` contains a sumset `A + B` with
  `|A| = |B| = ⌊c log n⌋` once `n` is large.

Together with the sharpness constructions of `Bridges.DeltaDenseSumsetAvoidance`
(which produce `δ`-dense sets avoiding progression sumsets of length
`3 log n / log (1/δ)`), these results pin the extremal threshold to the window
`[(1-o(1)) log n / log (2/δ), 3 log n / log (1/δ)]`; in particular the constant `3` of the
mission statement cannot be replaced by any constant below `1` in the regime `δ → 0`.
-/
import Bridges.DenseSumsetLower.Core

namespace DenseSumsetLower

open Finset Pointwise Filter Asymptotics

/-! ## The real-parameter form of the counting criterion -/

variable {G : Type*} [AddCommGroup G] [DecidableEq G]

/-- **Real-parameter criterion.**  Suppose the shift window `D` absorbs all differences of
`S`, has at most `M` elements and at least `k` elements, and `|S| ≥ σ`.  If `k ≤ ε σ` and
`k (M / ((1-ε) σ))^k ≤ σ`, then `S` contains a sumset `A + B` with `|A| = |B| = k`.

The two instances used below are `D = G` (with `M = |G|`, `σ = δ|G|`) and
`D = (-n, n) ⊆ ℤ` (with `M = 2n`, `σ = δ n`). -/
theorem exists_sumset_of_real_bounds {S D : Finset G} (hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D)
    {k : ℕ} {σ M ε : ℝ} (hε0 : 0 < ε) (hε1 : ε < 1) (hσ : 0 < σ)
    (hScard : σ ≤ S.card) (hDM : (D.card : ℝ) ≤ M) (hkD : k ≤ D.card)
    (hk : (k : ℝ) ≤ ε * σ) (hcond : (k : ℝ) * (M / ((1 - ε) * σ)) ^ k ≤ σ) :
    ∃ A B : Finset G, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hkS : k ≤ S.card := by
    have h1 : (k : ℝ) ≤ σ := by nlinarith
    exact_mod_cast le_trans h1 hScard
  have hbase : (0 : ℝ) < (1 - ε) * σ := mul_pos (by linarith) hσ
  have hsub : (1 - ε) * σ ≤ ((S.card - k : ℕ) : ℝ) := by
    rw [Nat.cast_sub hkS]
    nlinarith
  -- rearrange the hypothesis into `k ≤ σ ((1-ε)σ / M)^k`
  have hstep : (k : ℝ) * M ^ k ≤ σ * ((1 - ε) * σ) ^ k := by
    have h := mul_le_mul_of_nonneg_right hcond (le_of_lt (pow_pos hbase k))
    have hid : (M / ((1 - ε) * σ)) ^ k * ((1 - ε) * σ) ^ k = M ^ k := by
      rw [← mul_pow, div_mul_cancel₀ _ (ne_of_gt hbase)]
    calc (k : ℝ) * M ^ k = (k : ℝ) * (M / ((1 - ε) * σ)) ^ k * ((1 - ε) * σ) ^ k := by
          rw [mul_assoc, hid]
      _ ≤ σ * ((1 - ε) * σ) ^ k := h
  have hkey : ((k * D.card ^ k : ℕ) : ℝ) ≤ ((S.card * (S.card - k) ^ k : ℕ) : ℝ) := by
    push_cast
    calc (k : ℝ) * (D.card : ℝ) ^ k
        ≤ (k : ℝ) * M ^ k :=
          mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity) hDM k) hknn
      _ ≤ σ * ((1 - ε) * σ) ^ k := hstep
      _ ≤ (S.card : ℝ) * ((S.card - k : ℕ) : ℝ) ^ k := by
          have h1 : ((1 - ε) * σ) ^ k ≤ ((S.card - k : ℕ) : ℝ) ^ k :=
            pow_le_pow_left₀ (le_of_lt hbase) hsub k
          have h2 : (0 : ℝ) ≤ ((1 - ε) * σ) ^ k := pow_nonneg (le_of_lt hbase) k
          nlinarith
  obtain ⟨A, B, _, hA, hB, hAB⟩ :=
    exists_sumset_of_counting hD hkS hkD (by exact_mod_cast hkey)
  exact ⟨A, B, hA, hB, hAB⟩

/-! ## The analytic engine -/

/-- **The `k b^k ≤ α N` estimate.**  If `b > 1` and `c log b < 1`, then for every `α > 0`
and all large `N`, the choice `k = ⌊c log N⌋` satisfies `k b^k ≤ α N`.

This is the exact point where the constant `1 / log b` enters all lower bounds below:
`b^k ≤ N^{c log b}` is a power of `N` of exponent `< 1`, while `k ≤ c log N` is negligible. -/
theorem eventually_floor_log_pow_le {b c α : ℝ} (hb : 1 < b) (hc0 : 0 < c)
    (hcb : c * Real.log b < 1) (hα : 0 < α) :
    ∀ᶠ N : ℕ in atTop, (1 : ℝ) ≤ (N : ℝ) ∧
      (⌊c * Real.log N⌋₊ : ℝ) * b ^ (⌊c * Real.log N⌋₊) ≤ α * N := by
  set L : ℝ := Real.log b with hL
  have hLpos : 0 < L := Real.log_pos hb
  set θ : ℝ := c * L with hθ
  have hθpos : 0 < θ := mul_pos hc0 hLpos
  set η : ℝ := 1 - θ with hη
  have hηpos : 0 < η := by simp only [hη]; linarith
  have hlittle : (Real.log) =o[atTop] (fun x : ℝ => x ^ η) := isLittleO_log_rpow_atTop hηpos
  have hev1 : ∀ᶠ x : ℝ in atTop, ‖Real.log x‖ ≤ (α / c) * ‖x ^ η‖ := hlittle.def (by positivity)
  have hevR : ∀ᶠ x : ℝ in atTop, (1 : ℝ) ≤ x ∧ (c * Real.log x) * x ^ θ ≤ α * x := by
    filter_upwards [hev1, eventually_ge_atTop (1 : ℝ)] with x hx hx1
    have hxpos : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx1
    have hlogpos : 0 ≤ Real.log x := Real.log_nonneg hx1
    have hrpos : (0 : ℝ) < x ^ η := Real.rpow_pos_of_pos hxpos η
    have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hxpos θ
    have hxη : c * Real.log x ≤ α * x ^ η := by
      rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg hlogpos,
        abs_of_nonneg (le_of_lt hrpos)] at hx
      have h := mul_le_mul_of_nonneg_left hx (le_of_lt hc0)
      calc c * Real.log x ≤ c * ((α / c) * x ^ η) := h
        _ = α * x ^ η := by field_simp
    have hsplit : x ^ η * x ^ θ = x := by
      rw [← Real.rpow_add hxpos]; simp [hη]
    refine ⟨hx1, ?_⟩
    calc (c * Real.log x) * x ^ θ ≤ (α * x ^ η) * x ^ θ :=
          mul_le_mul_of_nonneg_right hxη (le_of_lt hxθ)
      _ = α * x := by rw [mul_assoc, hsplit]
  have hevN : ∀ᶠ N : ℕ in atTop, (1 : ℝ) ≤ (N : ℝ) ∧
      (c * Real.log N) * (N : ℝ) ^ θ ≤ α * N := tendsto_natCast_atTop_atTop.eventually hevR
  filter_upwards [hevN] with N hN
  obtain ⟨hN1, hN2⟩ := hN
  refine ⟨hN1, ?_⟩
  set k : ℕ := ⌊c * Real.log N⌋₊ with hk
  have hlognonneg : 0 ≤ Real.log N := Real.log_nonneg hN1
  have hkle : (k : ℝ) ≤ c * Real.log N := Nat.floor_le (by positivity)
  have hbpos : (0 : ℝ) < b := lt_trans zero_lt_one hb
  have hexp : (b : ℝ) ^ k = Real.exp (L * k) := by
    rw [hL, Real.exp_mul, Real.exp_log hbpos, Real.rpow_natCast]
  have hpow : (b : ℝ) ^ k ≤ (N : ℝ) ^ θ := by
    rw [hexp, Real.rpow_def_of_pos (lt_of_lt_of_le zero_lt_one hN1)]
    apply Real.exp_le_exp.mpr
    calc L * (k : ℝ) ≤ L * (c * Real.log N) := mul_le_mul_of_nonneg_left hkle (le_of_lt hLpos)
      _ = Real.log N * θ := by rw [hθ]; ring
  have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  calc (k : ℝ) * b ^ k ≤ (c * Real.log N) * (N : ℝ) ^ θ := by
        have h2 : (0 : ℝ) ≤ (b : ℝ) ^ k := by positivity
        nlinarith [Real.rpow_pos_of_pos (lt_of_lt_of_le zero_lt_one hN1) θ]
    _ ≤ α * N := hN2

/-! ## The integer interval -/

/-- **Density form, integer intervals.**  Let `S ⊆ [0,n)` have `|S| ≥ δ n`, and let
`0 < ε < 1`.  If `k ≤ ε δ n` and `k (2/((1-ε)δ))^k ≤ δ n`, then `S` contains a sumset
`A + B` with `|A| = |B| = k`. -/
theorem exists_sumset_of_density {n k : ℕ} {S : Finset ℕ} (hS : S ⊆ Finset.range n)
    {δ ε : ℝ} (hδ0 : 0 < δ) (hε0 : 0 < ε) (hε1 : ε < 1) (hn : 0 < n)
    (hdense : δ * n ≤ S.card)
    (hk : (k : ℝ) ≤ ε * (δ * n)) (hcond : (k : ℝ) * (2 / ((1 - ε) * δ)) ^ k ≤ δ * n) :
    ∃ A B : Finset ℕ, A.card = k ∧ B.card = k ∧ A + B ⊆ S := by
  classical
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hσ : 0 < δ * n := mul_pos hδ0 hnpos
  have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  -- transport `S` to `ℤ` and use the window `(-n, n)`
  have hcast : Function.Injective (fun s : ℕ => (s : ℤ)) := fun a b h => by simpa using h
  set S' : Finset ℤ := S.image (fun s : ℕ => (s : ℤ)) with hS'def
  have hS'card : S'.card = S.card := Finset.card_image_of_injective _ hcast
  have hS'sub : S' ⊆ Finset.Ico (0 : ℤ) n := by
    intro x hx
    obtain ⟨s, hs, rfl⟩ := Finset.mem_image.mp hx
    have := Finset.mem_range.mp (hS hs)
    exact Finset.mem_Ico.mpr ⟨by positivity, by exact_mod_cast this⟩
  set D : Finset ℤ := Finset.Ioo (-(n : ℤ)) n with hDdef
  have hDcard : D.card = 2 * n - 1 := by rw [hDdef, Int.card_Ioo]; omega
  have hD : ∀ u ∈ S', ∀ s ∈ S', s - u ∈ D := by
    intro u hu s hs
    have hu' := Finset.mem_Ico.mp (hS'sub hu)
    have hs' := Finset.mem_Ico.mp (hS'sub hs)
    exact Finset.mem_Ioo.mpr ⟨by omega, by omega⟩
  have hSn : S.card ≤ n := by
    have := Finset.card_le_card hS
    simpa using this
  have hkn : k ≤ n := by
    have h1 : (k : ℝ) ≤ δ * n := by nlinarith
    have hcastSn : ((S.card : ℕ) : ℝ) ≤ (n : ℝ) := by exact_mod_cast hSn
    have h2 : (k : ℝ) ≤ (n : ℝ) := le_trans h1 (le_trans hdense hcastSn)
    exact_mod_cast h2
  have hkD : k ≤ D.card := by omega
  have hDM : (D.card : ℝ) ≤ 2 * n := by
    have h : D.card ≤ 2 * n := by omega
    calc (D.card : ℝ) ≤ ((2 * n : ℕ) : ℝ) := by exact_mod_cast h
      _ = 2 * n := by push_cast; ring
  have hcond' : (k : ℝ) * ((2 * n) / ((1 - ε) * (δ * n))) ^ k ≤ δ * n := by
    have : (2 * (n : ℝ)) / ((1 - ε) * (δ * n)) = 2 / ((1 - ε) * δ) := by
      field_simp
    rw [this]
    exact hcond
  obtain ⟨A, B, hAcard, hBcard, hAB⟩ :=
    exists_sumset_of_real_bounds hD hε0 hε1 hσ
      (by rw [hS'card]; exact hdense) hDM hkD hk hcond'
  -- translate back to `ℕ`
  rcases Nat.eq_zero_or_pos k with rfl | hkpos
  · exact ⟨∅, ∅, by simp, by simp, by simp⟩
  have hAne : A.Nonempty := Finset.card_pos.mp (by omega)
  set t : ℤ := A.min' hAne with ht
  have htA : t ∈ A := A.min'_mem hAne
  have hAt : ∀ a ∈ A, t ≤ a := fun a ha => A.min'_le a ha
  have hmemS' : ∀ a ∈ A, ∀ b ∈ B, a + b ∈ S.image (fun s : ℕ => (s : ℤ)) := by
    intro a ha b hb
    exact hAB (Finset.add_mem_add ha hb)
  have hBt : ∀ b ∈ B, 0 ≤ b + t := by
    intro b hb
    obtain ⟨m, _, hm⟩ := Finset.mem_image.mp
      (show t + b ∈ S.image (fun s : ℕ => (s : ℤ)) from hmemS' t htA b hb)
    omega
  refine ⟨A.image (fun a => (a - t).toNat), B.image (fun b => (b + t).toNat), ?_, ?_, ?_⟩
  · refine (Finset.card_image_of_injOn ?_).trans hAcard
    intro a ha b hb hab
    have h1 := hAt a ha; have h2 := hAt b hb
    simp only at hab
    omega
  · refine (Finset.card_image_of_injOn ?_).trans hBcard
    intro a ha b hb hab
    have h1 := hBt a ha; have h2 := hBt b hb
    simp only at hab
    omega
  · intro x hx
    obtain ⟨p, hp, q, hq, rfl⟩ := Finset.mem_add.mp hx
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hp
    obtain ⟨b, hb, rfl⟩ := Finset.mem_image.mp hq
    obtain ⟨m, hmS, hm⟩ := Finset.mem_image.mp
      (show a + b ∈ S.image (fun s : ℕ => (s : ℤ)) from hmemS' a ha b hb)
    have h1 : t ≤ a := hAt a ha
    have h2 : 0 ≤ b + t := hBt b hb
    have hsum : (a - t).toNat + (b + t).toNat = m := by omega
    rwa [hsum]

/-! ## The asymptotic form -/

/-- **Asymptotic lower bound in `[n]`.**  Fix `0 < δ < 1` and any `c` with
`c log (2/δ) < 1`.  Then for all large `n`, *every* subset `S ⊆ [n]` with `|S| ≥ δ n`
contains a sumset `A + B` with `|A| = |B| = ⌊c log n⌋`.

Since `log (2/δ) = (1 + o(1)) log (1/δ)` as `δ → 0`, no `δ`-dense set can avoid all
sumsets of size `(1 - o(1)) log n / log (1/δ)`. -/
theorem eventually_exists_sumset_of_density {δ c : ℝ} (hδ0 : 0 < δ) (hδ1 : δ < 1)
    (hc0 : 0 < c) (hc : c * Real.log (2 / δ) < 1) :
    ∀ᶠ n : ℕ in atTop, ∀ S : Finset ℕ, S ⊆ Finset.range n → δ * (n : ℝ) ≤ S.card →
      ∃ A B : Finset ℕ, A.card = ⌊c * Real.log n⌋₊ ∧ B.card = ⌊c * Real.log n⌋₊ ∧
        A + B ⊆ S := by
  -- slack `ε = 1 - exp (-t/(2c))` with `t = 1 - c log (2/δ) > 0`
  set t : ℝ := 1 - c * Real.log (2 / δ) with ht
  have htpos : 0 < t := by simp only [ht]; linarith
  set ε : ℝ := 1 - Real.exp (-(t / (2 * c))) with hε
  have hexp1 : Real.exp (-(t / (2 * c))) < 1 := by
    apply Real.exp_lt_one_iff.mpr
    have : 0 < t / (2 * c) := by positivity
    linarith
  have hexp0 : 0 < Real.exp (-(t / (2 * c))) := Real.exp_pos _
  have hε0 : 0 < ε := by simp only [hε]; linarith
  have hε1 : ε < 1 := by simp only [hε]; linarith
  have h1ε : 1 - ε = Real.exp (-(t / (2 * c))) := by simp [hε]
  set b : ℝ := 2 / ((1 - ε) * δ) with hb
  have hbase : (0 : ℝ) < (1 - ε) * δ := mul_pos (by linarith) hδ0
  have hb1 : 1 < b := by
    rw [hb, lt_div_iff₀ hbase, one_mul]
    nlinarith [hexp1, h1ε]
  have hexpne : Real.exp (t / (2 * c)) ≠ 0 := Real.exp_ne_zero _
  have hb_eq : b = (2 / δ) * Real.exp (t / (2 * c)) := by
    rw [hb, h1ε, Real.exp_neg]
    field_simp
  have hlogb : Real.log b = Real.log (2 / δ) + t / (2 * c) := by
    rw [hb_eq, Real.log_mul (by positivity) hexpne, Real.log_exp]
  have hcb : c * Real.log b < 1 := by
    rw [hlogb]
    have hct : c * (t / (2 * c)) = t / 2 := by field_simp
    rw [mul_add, hct, ht]
    linarith
  filter_upwards [eventually_floor_log_pow_le hb1 hc0 hcb (α := ε * δ) (by positivity),
    eventually_gt_atTop 0] with n hn hnpos S hS hdense
  obtain ⟨hn1, hn2⟩ := hn
  set k : ℕ := ⌊c * Real.log n⌋₊ with hk
  have hone : (1 : ℝ) ≤ b ^ k := one_le_pow₀ (le_of_lt hb1)
  have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hkbound : (k : ℝ) ≤ ε * (δ * n) := by nlinarith
  refine exists_sumset_of_density hS hδ0 hε0 hε1 hnpos hdense hkbound ?_
  have hεδ : ε * δ ≤ δ := by nlinarith
  calc (k : ℝ) * b ^ k ≤ ε * δ * n := hn2
    _ ≤ δ * n := by nlinarith [(by exact_mod_cast hnpos : (0:ℝ) < (n:ℝ))]

end DenseSumsetLower