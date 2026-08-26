/-
# Exact counting of the tiny-residue channel in a Fermat window

Companion to `Cryptography.SpikeOriginDegeneracy` and `Cryptography.SpikeOriginBands`.

The residue `v(j) = j² − N` is strictly increasing along the window `j ∈ (s, 3s]`,
`s = ⌊√N⌋`.  Consequently *every* bit-length band is an interval of positions, and the
"exclude `v < T`" clause is, for a **fixed** modulus, literally a positional cut at
`j ≤ ⌊√(N + T − 1)⌋`.  We compute the excluded population exactly
(`card_lowBand`) and show for `96`-bit moduli that the excluded left-edge interval has
width at least `0.22 · s`, i.e. it strictly contains the whole first decile (width `0.2 s`)
with a margin of at least `0.02 · s` positions.

Combined with `SpikeOriginBands.midRegime_not_universal` — where the cut position moves with
`N` — this is the precise form of "the spike is not one object": *within* a modulus the
`bitlen v` band and the position are the same stratification, *across* moduli they are not.

The tiny channel reaches all the way down to `v ≤ 2√N + 1` (`resid_left_end_le`), i.e.
about half the bit-length of `N`, which is the arithmetic mechanism behind the inclusion
artifact.
-/
import Mathlib
import Cryptography.SpikeOriginDegeneracy

namespace SpikeOrigin

/-! ## Monotonicity: bands are positional intervals -/

lemma lt_sq_of_sqrt_lt {N j : ℕ} (hj : Nat.sqrt N < j) : N < j ^ 2 :=
  lt_of_lt_of_le (Nat.lt_succ_sqrt' N) (Nat.pow_le_pow_left hj 2)

/-- The residue is strictly increasing along the window. -/
theorem resid_strictMono {N j₁ j₂ : ℕ} (h₁ : Nat.sqrt N < j₁) (h : j₁ < j₂) :
    resid N j₁ < resid N j₂ := by
  have hN : N < j₁ ^ 2 := lt_sq_of_sqrt_lt h₁
  have hsq : j₁ ^ 2 < j₂ ^ 2 := Nat.pow_lt_pow_left h (by norm_num)
  simp only [resid]
  omega

/-- Membership in the low band `v < T` is exactly the positional condition
`j ≤ ⌊√(N + T − 1)⌋`. -/
theorem resid_lt_iff {N T j : ℕ} (hT : 0 < T) (hj : Nat.sqrt N < j) :
    resid N j < T ↔ j ≤ Nat.sqrt (N + T - 1) := by
  have hN : N < j ^ 2 := lt_sq_of_sqrt_lt hj
  have hstep : resid N j < T ↔ j * j ≤ N + T - 1 := by
    simp only [resid, pow_two] at *
    omega
  rw [hstep, Nat.le_sqrt]

/-- **The excluded (tiny-residue) set is a left-edge interval.** -/
theorem lowBand_eq_Ioc (N T : ℕ) (hT : 0 < T) :
    ((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter (fun j => resid N j < T))
      = Finset.Ioc (Nat.sqrt N) (min (3 * Nat.sqrt N) (Nat.sqrt (N + T - 1))) := by
  ext j
  simp only [Finset.mem_filter, Finset.mem_Ioc, le_min_iff]
  constructor
  · rintro ⟨⟨hj1, hj2⟩, hv⟩
    exact ⟨hj1, hj2, (resid_lt_iff hT hj1).1 hv⟩
  · rintro ⟨hj1, hj2, hj3⟩
    exact ⟨⟨hj1, hj2⟩, (resid_lt_iff hT hj1).2 hj3⟩

/-- **Exact population of the low band.** -/
theorem card_lowBand (N T : ℕ) (hT : 0 < T) :
    ((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter (fun j => resid N j < T)).card
      = min (3 * Nat.sqrt N) (Nat.sqrt (N + T - 1)) - Nat.sqrt N := by
  rw [lowBand_eq_Ioc N T hT, Nat.card_Ioc]

/-! ## How small the tiny channel gets -/

/-- The extreme left end of the window already realises a residue of size `O(√N)`:
`v(s+1) ≤ 2√N + 1`, i.e. roughly half the bit-length of `N`.  This is the arithmetic
mechanism that lets the window contain residues vastly smaller than a random draw. -/
theorem resid_left_end_le (N : ℕ) : resid N (Nat.sqrt N + 1) ≤ 2 * Nat.sqrt N + 1 := by
  have h : Nat.sqrt N * Nat.sqrt N ≤ N := Nat.sqrt_le N
  have hexp : (Nat.sqrt N + 1) ^ 2 = Nat.sqrt N * Nat.sqrt N + 2 * Nat.sqrt N + 1 := by ring
  simp only [resid]
  omega

/-! ## The excluded interval strictly contains the first decile (96-bit case) -/

section NinetySix

variable {N : ℕ}

private lemma sqrt_sq_le (N : ℕ) : Nat.sqrt N * Nat.sqrt N ≤ N := Nat.sqrt_le N

/-- For a `96`-bit modulus the low-band cut point `m = ⌊√(N + 2⁹⁵ − 1)⌋` stays inside the
window. -/
theorem cut_le_window (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96) :
    Nat.sqrt (N + 2 ^ 95 - 1) ≤ 3 * Nat.sqrt N := by
  set s := Nat.sqrt N with hs
  have h1 : s * s ≤ N := sqrt_sq_le N
  have hup : N < (s + 1) * (s + 1) := by
    have := Nat.lt_succ_sqrt' N
    simpa [hs, pow_two] using this
  have hs1 : 1 ≤ s := by
    rw [hs]
    exact Nat.le_sqrt.2 (by omega)
  have hss : s ≤ s * s := Nat.le_mul_of_pos_left s hs1
  have hlt : Nat.sqrt (N + 2 ^ 95 - 1) < 3 * s + 1 := by
    rw [Nat.sqrt_lt']
    have hexp : (3 * s + 1) ^ 2 = 9 * (s * s) + 6 * s + 1 := by ring
    have hexp2 : (s + 1) * (s + 1) = s * s + 2 * s + 1 := by ring
    omega
  omega

/-- **Quantitative degeneracy.**  For a `96`-bit modulus the excluded low band
`{j ∈ (s, 3s] : v(j) < 2⁹⁵}` is a left-edge interval of width at least `0.22 · s`, whereas
the first decile has width at most `0.2 s + 1`.  So the exclusion clause wipes out the whole
first decile and at least a further `0.02 · s` positions: it is a geometric operation, not a
data-driven one. -/
theorem card_lowBand_ge (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96) :
    11 * Nat.sqrt N ≤
      50 * (((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => resid N j < 2 ^ 95)).card) := by
  set s := Nat.sqrt N with hs
  have hcard := card_lowBand N (2 ^ 95) (by positivity)
  rw [min_eq_right (cut_le_window hlo hhi), ← hs] at hcard
  set m := Nat.sqrt (N + 2 ^ 95 - 1) with hm
  have h1 : s * s ≤ N := sqrt_sq_le N
  have hup : N < (s + 1) * (s + 1) := by
    have := Nat.lt_succ_sqrt' N
    simpa [hs, pow_two] using this
  -- `s` is large: `s ≥ 2⁴⁷`
  have hslarge : 2 ^ 47 ≤ s := by
    rw [hs, Nat.le_sqrt]
    calc (2:ℕ) ^ 47 * 2 ^ 47 = 2 ^ 94 := by ring
      _ ≤ 2 ^ 95 := by norm_num
      _ ≤ N := hlo
  -- the ceiling `k = ⌈1.22 s⌉` still lies below the cut point
  set k := (61 * s + 49) / 50 with hk
  have hk1 : 50 * k ≥ 61 * s := by omega
  have hk2 : 50 * k ≤ 61 * s + 49 := by omega
  have hhalf : 2 * (2 ^ 95 : ℕ) ≥ N := by omega
  have hkm : k ≤ m := by
    rw [hm, Nat.le_sqrt]
    -- `2500 k² ≤ (61 s + 49)² ≤ 3721 s² + 5978 s + 2401 ≤ 2500 (N + 2⁹⁵ − 1)`
    have hkk : 2500 * (k * k) ≤ (61 * s + 49) * (61 * s + 49) := by nlinarith
    have hgoal : (61 * s + 49) * (61 * s + 49) ≤ 2500 * (N + 2 ^ 95 - 1) := by
      have hN2 : 2 ^ 95 ≤ N := hlo
      have hsub : N + 2 ^ 95 - 1 ≥ N + (N / 2) - 1 := by omega
      have hexp : (61 * s + 49) * (61 * s + 49) = 3721 * (s * s) + 5978 * s + 2401 := by ring
      have hNs : 3721 * (s * s) ≤ 3721 * N := Nat.mul_le_mul_left _ h1
      have hbig : 5978 * s + 2401 + 3721 * N ≤ 2500 * (N + 2 ^ 95 - 1) := by
        have h2 : 2500 * (N + 2 ^ 95 - 1) ≥ 2500 * N + 1250 * N - 2500 := by omega
        have h3 : 5978 * s + 10000 ≤ 29 * N := by
          have : s ≤ N := Nat.sqrt_le_self N
          nlinarith [hslarge, hlo]
        omega
      omega
    have hfin := le_trans hkk hgoal
    omega
  omega

/-- Complementary upper bound on the cut point: `m ≤ 1.42 · s`. -/
theorem cut_upper (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96) :
    100 * Nat.sqrt (N + 2 ^ 95 - 1) ≤ 142 * Nat.sqrt N := by
  set s := Nat.sqrt N with hs
  have h1 : s * s ≤ N := sqrt_sq_le N
  have hup : N < (s + 1) * (s + 1) := by
    have := Nat.lt_succ_sqrt' N
    simpa [hs, pow_two] using this
  have hslarge : 2 ^ 47 ≤ s := by
    rw [hs, Nat.le_sqrt]
    calc (2:ℕ) ^ 47 * 2 ^ 47 = 2 ^ 94 := by ring
      _ ≤ 2 ^ 95 := by norm_num
      _ ≤ N := hlo
  set k := (142 * s) / 100 with hk
  have hk1 : 142 * s < 100 * (k + 1) := by omega
  have hsq : 2 * (s * s) + 4 * s + 2 < (k + 1) * (k + 1) := by nlinarith
  have hexp : (s + 1) * (s + 1) = s * s + 2 * s + 1 := by ring
  have hm : Nat.sqrt (N + 2 ^ 95 - 1) < k + 1 := by
    rw [Nat.sqrt_lt']
    have : (k + 1) ^ 2 = (k + 1) * (k + 1) := by ring
    omega
  omega

/-- **Two-sided window fraction of the tiny-residue channel.**  For every `96`-bit modulus
the excluded low band occupies between `11 %` and `21 %` of the `2s` window positions —
a discrete counterpart of the continuum crossing interval
`((√6 − 2)/4, (√2 − 1)/2] ⊂ (0.1123, 0.2072]`, and in particular always strictly more than
the first decile. -/
theorem lowBand_fraction_bounds (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96) :
    11 * (2 * Nat.sqrt N) ≤
      100 * (((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => resid N j < 2 ^ 95)).card) ∧
    100 * (((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => resid N j < 2 ^ 95)).card) ≤ 21 * (2 * Nat.sqrt N) := by
  have hcard := card_lowBand N (2 ^ 95) (by positivity)
  rw [min_eq_right (cut_le_window hlo hhi)] at hcard
  have hlow := card_lowBand_ge hlo hhi
  have hupper := cut_upper hlo hhi
  omega

end NinetySix

/-! ## Monotone law for the continuum crossing position -/

/-- The crossing position `u₀(N)` is strictly decreasing in `N`: larger moduli expose their
full-size residues earlier in the window.  Together with
`SpikeOriginDegeneracy.crossingPos_le` / `crossingPos_gt` this pins the crossing curve to
`((√6 − 2)/4, (√2 − 1)/2]` and makes it a strictly monotone reparametrisation of `N`. -/
theorem crossingPos_strictAntiOn {N₁ N₂ : ℝ} (h₁ : 0 < N₁) (h : N₁ < N₂) :
    crossingPos N₂ < crossingPos N₁ := by
  have h₂ : (0:ℝ) < N₂ := lt_trans h₁ h
  have hdiv : (2:ℝ) ^ 95 / N₂ < 2 ^ 95 / N₁ := by
    apply div_lt_div_of_pos_left (by positivity) h₁ h
  have := Real.sqrt_lt_sqrt (by positivity) (show 1 + 2 ^ 95 / N₂ < 1 + 2 ^ 95 / N₁ by linarith)
  unfold crossingPos
  linarith

end SpikeOrigin