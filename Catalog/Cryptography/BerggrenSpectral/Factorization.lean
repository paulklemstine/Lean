import Cryptography.BerggrenSpectral.HyperbolicResonance

/-!
# Resonance ⇒ Factorization: extracting a prime factor of `N = p q`

Combining the exact spectral analysis of the previous files we obtain a **provably correct
factoring criterion** for RSA-type moduli `N = p q`, driven by the hyperbolic Berggren
generator `M₂`.

The mechanism ("modular energy resonance") is:

* `berg_two_resonance_qr` / `berg_two_resonance_nqr`: modulo the prime `p` the generator `M₂`
  has resonant frequency dividing `p - 1` or `p + 1` (hence `p² - 1`), decided by `p mod 8`;
* if an exponent `k` is *in resonance with `p` but out of resonance with `q`*, then `M₂ ^ k - 1`
  is divisible by `p` entrywise but has some entry not divisible by `q`;
* `berg_resonance_extracts_factor`: the gcd of that entry with `N` is then **exactly `p`**, a
  nontrivial factor of `N`.

`berg_resonance_factorization` packages this with the canonical resonant exponent
`k = p² - 1`, and `berg_resonance_sharp_frequency` with the sharp frequencies `p ∓ 1`.
Finally `berg_factor_fifteen` is a fully checked concrete instance: at the resonant
frequency `4 = 3 + 1` for `p = 3`, the criterion splits `N = 15`.

The contrast with `berg_one_gcd_barrier` (unipotent branch: no factoring information at all)
is the main structural finding of this development: **only the hyperbolic branch of the
Berggren tree carries prime-separating spectral information.**
-/

namespace BerggrenSpectral

open Matrix

/-! ## From matrix congruences to divisibility -/

/-- `A ≡ 1 (mod N)` as matrices iff `N` divides every entry of `A - 1`. -/
theorem redMat_eq_one_iff (N : ℕ) (A : Matrix (Fin 3) (Fin 3) ℤ) :
    redMat N A = 1 ↔ ∀ i j, (N : ℤ) ∣ (A - 1) i j := by
  have hmap : redMat N (A - 1) = redMat N A - 1 := by
    simp [redMat, map_sub]
  constructor
  · intro h i j
    have h0 : redMat N (A - 1) = 0 := by rw [hmap, h, sub_self]
    have h2 := congrFun (congrFun h0 i) j
    rw [redMat_apply] at h2
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ N).mp (by simpa using h2)
  · intro h
    have h0 : redMat N (A - 1) = 0 := by
      ext i j
      rw [redMat_apply]
      simpa using (ZMod.intCast_zmod_eq_zero_iff_dvd ((A - 1) i j) N).mpr (h i j)
    rw [hmap] at h0
    exact sub_eq_zero.mp h0

/-! ## The gcd extraction step -/

/-- **Factor extraction.**  If `p` divides `x` but `q` does not, then `gcd (x, p q) = p`. -/
theorem factor_extraction (p q : ℕ) (hq : q.Prime) (x : ℤ)
    (hpx : (p : ℤ) ∣ x) (hqx : ¬ (q : ℤ) ∣ x) (hp0 : p ≠ 0) :
    Int.gcd x ((p * q : ℕ) : ℤ) = p := by
  set g := Int.gcd x ((p * q : ℕ) : ℤ) with hg
  have hgx : (g : ℤ) ∣ x := Int.gcd_dvd_left _ _
  have hgN : g ∣ p * q := by exact_mod_cast Int.gcd_dvd_right x ((p * q : ℕ) : ℤ)
  have hpg : p ∣ g := by
    have h2 : (p : ℤ) ∣ ((p * q : ℕ) : ℤ) := by push_cast; exact Dvd.intro q rfl
    exact Int.dvd_gcd hpx h2
  obtain ⟨t, ht⟩ := hpg
  have htq : t ∣ q := (mul_dvd_mul_iff_left hp0).mp (ht ▸ hgN)
  rcases hq.eq_one_or_self_of_dvd t htq with h1 | h1
  · rw [ht, h1, mul_one]
  · exact absurd (((show (q : ℤ) ∣ (g : ℤ) by rw [ht, h1]; exact ⟨(p : ℤ), by push_cast; ring⟩)).trans
      hgx) hqx

/-! ## The main factoring theorem -/

/-- **Resonance extracts a prime factor.**  Let `N = p q` with `p, q` prime.  If the exponent
`k` is a resonance of `M₂` modulo `p` but not modulo `q`, then some entry of `M₂ ^ k - 1` has
gcd exactly `p` with `N`. -/
theorem berg_resonance_extracts_factor (p q k : ℕ) (hp : p.Prime) (hq : q.Prime)
    (hres : (redMat p M₂) ^ k = 1) (hnon : (redMat q M₂) ^ k ≠ 1) :
    ∃ i j, Int.gcd ((M₂ ^ k - 1) i j) ((p * q : ℕ) : ℤ) = p := by
  have hpdvd : ∀ i j, (p : ℤ) ∣ (M₂ ^ k - 1) i j := by
    refine (redMat_eq_one_iff p (M₂ ^ k)).mp ?_
    rw [redMat_pow]; exact hres
  have hqex : ∃ i j, ¬ (q : ℤ) ∣ (M₂ ^ k - 1) i j := by
    by_contra hcon
    push_neg at hcon
    exact hnon (by rw [← redMat_pow]; exact (redMat_eq_one_iff q (M₂ ^ k)).mpr hcon)
  obtain ⟨i, j, hij⟩ := hqex
  exact ⟨i, j, factor_extraction p q hq _ (hpdvd i j) hij hp.pos.ne'⟩

/-- The extracted divisor is a *nontrivial* factor of `N = p q`. -/
theorem berg_resonance_nontrivial (p q : ℕ) (hp : p.Prime) (hq : q.Prime) :
    1 < p ∧ p < p * q ∧ p ∣ p * q := by
  refine ⟨hp.one_lt, ?_, Dvd.intro q rfl⟩
  have : 1 < q := hq.one_lt
  have hppos : 0 < p := hp.pos
  nlinarith [hppos, this]

/-- **Berggren resonance factorization at the canonical frequency `2(p² - 1)`.**
If the canonical resonant exponent of `p` fails to be a resonance of `q`, the Berggren
generator `M₂` splits `N = p q`. -/
theorem berg_resonance_factorization (p q : ℕ) (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hnon : (redMat q M₂) ^ (p ^ 2 - 1) ≠ 1) :
    ∃ i j : Fin 3,
      Int.gcd ((M₂ ^ (p ^ 2 - 1) - 1 : Matrix (Fin 3) (Fin 3) ℤ) i j)
        ((p * q : ℕ) : ℤ) = p := by
  haveI : Fact p.Prime := ⟨hp⟩
  exact berg_resonance_extracts_factor p q _ hp hq (berg_two_resonance p hp2) hnon

/-- **Sharp resonant frequencies.**  For `p ≡ ±1 (mod 8)` the frequency `2(p-1)` already
splits `N`, and for `p ≡ ±3 (mod 8)` the frequency `2(p+1)` does. -/
theorem berg_resonance_sharp_frequency (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) :
    ((p % 8 = 1 ∨ p % 8 = 7) → (redMat q M₂) ^ (p - 1) ≠ 1 →
      ∃ i j, Int.gcd ((M₂ ^ (p - 1) - 1) i j) ((p * q : ℕ) : ℤ) = p) ∧
    ((p % 8 = 3 ∨ p % 8 = 5) → (redMat q M₂) ^ (p + 1) ≠ 1 →
      ∃ i j, Int.gcd ((M₂ ^ (p + 1) - 1) i j) ((p * q : ℕ) : ℤ) = p) := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨h1, h2⟩ := berg_two_resonance_mod_eight p hp2
  exact ⟨fun h8 hnon => berg_resonance_extracts_factor p q _ hp hq (h1 h8) hnon,
    fun h8 hnon => berg_resonance_extracts_factor p q _ hp hq (h2 h8) hnon⟩

/-- **Boundary of the method (adversarial check).**  If the exponent `k` is a resonance of
the *whole* modulus `N` — i.e. the two prime frequencies are aligned at `k` — then every gcd
the method can compute is the trivial divisor `N`.  So resonance *misalignment* is not merely
convenient, it is necessary. -/
theorem berg_aligned_resonance_no_factor (N k : ℕ) (h : (redMat N M₂) ^ k = 1) (i j : Fin 3) :
    Int.gcd ((M₂ ^ k - 1 : Matrix (Fin 3) (Fin 3) ℤ) i j) (N : ℤ) = N := by
  have hdvd : (N : ℤ) ∣ (M₂ ^ k - 1) i j := by
    refine (redMat_eq_one_iff N (M₂ ^ k)).mp ?_ i j
    rw [redMat_pow]; exact h
  refine Nat.dvd_antisymm ?_ ?_
  · exact_mod_cast Int.gcd_dvd_right ((M₂ ^ k - 1) i j) (N : ℤ)
  · exact Int.dvd_gcd hdvd dvd_rfl

/-! ## A concrete verified instance: `N = 15 = 3 · 5` -/

/-- `3 ≡ 3 (mod 8)`, so the resonant frequency of `p = 3` divides `3 + 1 = 4`. -/
theorem berg_resonance_three : (redMat 3 M₂) ^ 4 = 1 := by decide

/-- `5` is *not* in resonance at frequency `4` (its frequency is `5 + 1 = 6`). -/
theorem berg_no_resonance_five : (redMat 5 M₂) ^ 4 ≠ 1 := by decide

/-- **Worked instance.**  At the resonant frequency `4` of `p = 3`, the Berggren generator
splits `15 = 3 · 5`. -/
theorem berg_factor_fifteen :
    ∃ i j : Fin 3,
      Int.gcd ((M₂ ^ 4 - 1 : Matrix (Fin 3) (Fin 3) ℤ) i j) ((3 * 5 : ℕ) : ℤ) = 3 :=
  berg_resonance_extracts_factor 3 5 4 (by norm_num) (by norm_num)
    berg_resonance_three berg_no_resonance_five

/-! ## A textbook RSA modulus: `N = 3233 = 53 · 61` -/

set_option maxRecDepth 40000 in
/-- `53 ≡ 5 (mod 8)`, so the resonant frequency of `p = 53` divides `53 + 1 = 54`. -/
theorem berg_resonance_53 : (redMat 53 M₂) ^ 54 = 1 := by decide

set_option maxRecDepth 40000 in
/-- `61` is out of resonance at frequency `54` (its own frequency is `62`). -/
theorem berg_no_resonance_61 : (redMat 61 M₂) ^ 54 ≠ 1 := by decide

/-- **Worked RSA-style instance.**  At the resonant frequency `54` of `p = 53`, the Berggren
generator splits the classical toy RSA modulus `3233 = 53 · 61`. -/
theorem berg_factor_3233 :
    ∃ i j : Fin 3,
      Int.gcd ((M₂ ^ 54 - 1 : Matrix (Fin 3) (Fin 3) ℤ) i j) ((53 * 61 : ℕ) : ℤ) = 53 :=
  berg_resonance_extracts_factor 53 61 54 (by norm_num) (by norm_num)
    berg_resonance_53 berg_no_resonance_61

end BerggrenSpectral