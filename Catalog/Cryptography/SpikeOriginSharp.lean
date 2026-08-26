/-
# Sharp constants and the deterministic band histogram

Continuation of `Cryptography.SpikeOriginDegeneracy`, `…Bands`, `…Counting`.

Two further steps of the programme:

* **Sharp discrete degeneracy constant.**  The degeneracy of the "`v ≥ 2⁹⁵`" clause was
  proved above for the first decile `u ≲ 0.1`.  Here it is pushed to `u ≤ 0.1123`
  (`sharp_degeneracy`), which is essentially the continuum optimum
  `(√6 − 2)/4 = 0.11237…`, and shown to be impossible beyond `u = 0.2072`
  (`sharp_constant_witness`) — the other continuum endpoint being
  `(√2 − 1)/2 = 0.20711…`.  So the exact discrete threshold is bracketed by the same two
  quadratic irrationalities that bound the crossing curve (`discrete_threshold_bracket`).

* **Deterministic band histogram.**  Because the residue is strictly increasing, the number
  of window positions with `bitlen v ≤ b` is an explicit difference of integer square roots
  (`card_sizeLe`), and the individual band populations telescope (`card_band_succ`,
  `card_band_formula`).  The band decomposition of a Fermat window carries no stochastic
  content at all: it is a function of `N` alone.
-/
import Mathlib
import Cryptography.SpikeOriginCounting

namespace SpikeOrigin

/-! ## Sharp constant for the degeneracy -/

/-- **Sharp degeneracy.**  For a `96`-bit modulus, every window point at normalised
position `u = (j − s)/(2s) ≤ 0.1123` has a sub-`2⁹⁵` residue.  The constant `0.1123` is
within `10⁻⁴` of the continuum optimum `(√6 − 2)/4`. -/
theorem sharp_degeneracy {N j : ℕ} (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96)
    (hj : Nat.sqrt N < j) (hu : 10000 * (j - Nat.sqrt N) ≤ 2246 * Nat.sqrt N) :
    resid N j < 2 ^ 95 := by
  set s := Nat.sqrt N with hs
  set d := j - s with hd
  have hjs : j = s + d := by omega
  have hsq : s * s ≤ N := Nat.sqrt_le N
  have hv : resid N j ≤ 2 * s * d + d * d := by
    have hj2 : j ^ 2 = s * s + (2 * s * d + d * d) := by rw [hjs]; ring
    have : resid N j = s * s + (2 * s * d + d * d) - N := by rw [resid, hj2]
    omega
  have hkey : 100000000 * (2 * s * d + d * d) ≤ 49964516 * (s * s) := by nlinarith
  have hNs : 49964516 * (s * s) ≤ 49964516 * N := Nat.mul_le_mul_left _ hsq
  have hbound : 100000000 * resid N j ≤ 49964516 * N :=
    le_trans (Nat.mul_le_mul_left _ hv) (le_trans hkey hNs)
  have h96 : (2 : ℕ) ^ 96 = 2 * 2 ^ 95 := by ring
  omega

/-- **The constant cannot be pushed past `0.2072`.**  There is a `96`-bit modulus with a
*full-size* residue already at normalised position `u ≤ 0.2072`, just below the continuum
endpoint `(√2 − 1)/2 = 0.20711…`. -/
theorem sharp_constant_witness :
    ∃ N j : ℕ, 2 ^ 95 ≤ N ∧ N < 2 ^ 96 ∧ Nat.sqrt N < j ∧ j ≤ 3 * Nat.sqrt N ∧
      10000 * (j - Nat.sqrt N) ≤ 2072 * (2 * Nat.sqrt N) ∧ 2 ^ 95 ≤ resid N j := by
  refine ⟨199032864766431 * 199032864766431, 281512083925640, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [resid]
    have e : (281512083925640 : ℕ) ^ 2 = 79249053396156578873049409600 := by norm_num
    have f : (2 : ℕ) ^ 95 = 39614081257132168796771975168 := by norm_num
    have g : (199032864766431 : ℕ) * 199032864766431 =
        39614081257132410564184477761 := by norm_num
    omega

/-- **Bracketing of the exact discrete threshold.**  Any positional cut-off `c` (in units of
`10⁻⁴`) that makes the `v ≥ 2⁹⁵` clause degenerate for *all* `96`-bit moduli satisfies
`c ≤ 2072`, and every `c ≤ 1123` does make it degenerate.  These are exactly the endpoints
`(√6 − 2)/4` and `(√2 − 1)/2` of the continuum crossing interval. -/
theorem discrete_threshold_bracket :
    (∀ N j : ℕ, 2 ^ 95 ≤ N → N < 2 ^ 96 → Nat.sqrt N < j →
        10000 * (j - Nat.sqrt N) ≤ 1123 * (2 * Nat.sqrt N) → resid N j < 2 ^ 95) ∧
    ¬ (∀ N j : ℕ, 2 ^ 95 ≤ N → N < 2 ^ 96 → Nat.sqrt N < j →
        10000 * (j - Nat.sqrt N) ≤ 2072 * (2 * Nat.sqrt N) → resid N j < 2 ^ 95) := by
  constructor
  · intro N j hlo hhi hj hu
    exact sharp_degeneracy hlo hhi hj (by omega)
  · intro hcon
    obtain ⟨N, j, h1, h2, h3, _, h5, h6⟩ := sharp_constant_witness
    have := hcon N j h1 h2 h3 h5
    omega

/-! ## Deterministic band histogram -/

/-- Cumulative band population: the number of window points with `bitlen v ≤ b`. -/
theorem card_sizeLe (N b : ℕ) :
    ((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => (resid N j).size ≤ b)).card
      = min (3 * Nat.sqrt N) (Nat.sqrt (N + 2 ^ b - 1)) - Nat.sqrt N := by
  rw [← card_lowBand N (2 ^ b) (by positivity)]
  congr 1
  apply Finset.filter_congr
  intro j _
  simp [Nat.size_le]

/-- The band populations telescope: `#{bitlen v ≤ b} + #{bitlen v = b+1} = #{bitlen v ≤ b+1}`. -/
theorem card_band_succ (N b : ℕ) :
    ((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => (resid N j).size ≤ b)).card
      + ((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => (resid N j).size = b + 1)).card
      = ((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => (resid N j).size ≤ b + 1)).card := by
  rw [← Finset.card_union_of_disjoint]
  · congr 1
    ext x
    simp only [Finset.mem_union, Finset.mem_filter]
    constructor
    · rintro (⟨hx, h⟩ | ⟨hx, h⟩) <;> exact ⟨hx, by omega⟩
    · rintro ⟨hx, h⟩
      rcases Nat.lt_or_ge (resid N x).size (b + 1) with h' | h'
      · exact Or.inl ⟨hx, by omega⟩
      · exact Or.inr ⟨hx, by omega⟩
  · rw [Finset.disjoint_left]
    rintro x hx hx'
    simp only [Finset.mem_filter] at hx hx'
    omega

/-- **Explicit band histogram.**  The number of window positions whose residue has bit
length exactly `b + 1` is a difference of two integer square roots — a deterministic
function of the modulus, with no stochastic content. -/
theorem card_band_formula (N b : ℕ) :
    ((Finset.Ioc (Nat.sqrt N) (3 * Nat.sqrt N)).filter
        (fun j => (resid N j).size = b + 1)).card
      = (min (3 * Nat.sqrt N) (Nat.sqrt (N + 2 ^ (b + 1) - 1)) - Nat.sqrt N)
        - (min (3 * Nat.sqrt N) (Nat.sqrt (N + 2 ^ b - 1)) - Nat.sqrt N) := by
  have h := card_band_succ N b
  rw [card_sizeLe, card_sizeLe] at h
  omega

end SpikeOrigin