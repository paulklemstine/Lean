/-
# The spectral face of the factoring barrier: an exact zero-block theorem and the top-bit law

Companion to `Novelty.WalshSpectralFlatness`.  Where that file develops the Walsh calculus on the
Boolean cube, this file proves the two *arithmetic* facts that the spectral experiment
(Paper 53, Experiment 388) measured numerically:

1. **Zero block (flatness, exact).**  Let `t ≥ 2` and let the support be the full odd support
   modulo `2^t`: all ordered pairs `(p,q)` of odd residues, with public value `N = p q mod 2^t`.
   Then for every bit index `1 ≤ j < t` and **every** predictor `h` — arbitrary, not merely a
   low-degree GF(2) parity — the bit `p_j` of the secret factor is right exactly half the time.
   The correlation is *exactly* `0`, not `O(m^{-1/2})`.
   (`SpectralFlatnessFactoring.lowblock_corr_zero`,
    `SpectralFlatnessFactoring.lowblock_predictor_barrier`.)

2. **Top bit (the only non-flat structure).**  For a balanced semiprime `N = p q` with
   `2^{k-1} ≤ p ≤ q < 2^k`, the second-highest bit of the smaller factor is *transmitted* to the
   top bit of `N`: `p_{k-2} = 1 ⟹ N_{2k-1} = 1`, equivalently `N < 2^{2k-1} ⟹ p_{k-2} = 0`.
   This deterministic one-sided law is the source of the empirically observed
   `corr(p_{k-2}, N_{2k-1}) ≈ 0.285`, and it is a pure magnitude statement: the predicate
   `N ≥ 2^{2k-1}` is symmetric in `(p,q)` and is computable from `N` alone.
   (`SpectralFlatnessFactoring.second_bit_transmits_to_top`,
    `SpectralFlatnessFactoring.second_bit_zero_of_top_bit_zero`.)
   It is genuinely one-sided: `top_bit_does_not_determine_second_bit` exhibits two balanced
   semiprimes with the same top bit and different `p_{k-2}`, and
   `top_bit_does_not_determine_low_bit` does the same for a low bit.

3. **Perfect secrecy of the low block.**  Strengthening (1): conditioned on any public value,
   the secret factor is *equidistributed* over the whole unit group, so any two public values
   induce identical distributions on any property of the secret factor at all
   (`fiber_distribution_independent`), every fiber has exactly `2^{t-1}` points
   (`fiber_card`), and no guessing strategy hits more than one of them (`guess_card_le_one`).
   The mechanism is isolated abstractly in `group_zero_block`: it is the simple transitivity of
   the regular representation, not anything about primes.

4. **The top-bit bias is strictly positive at every size** (`covTop_pos`): over the full balanced
   integer support the covariance of `p_{k-2} = 1` with `N_{2k-1} = 1` is `> 0` for every `k`,
   so the contrast between the exactly-flat low block and the non-flat top-bit family is a
   theorem, not a numerical impression.

The results together are the formal content of the experiment's verdict: *all* the structure
that the Walsh spectrum sees is the symmetric magnitude/carry family of the top bits, and on the
low block the spectrum is exactly, provably flat.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the observed decay `corr(f_3,{1,2,3}) = 0.203 → 0.013` and
`corr(p_2, N_{2k-1}) = 0.254/0.166/0.013/0.006` at `k = 8/10/12/14` is not a slow asymptotic
approach to a nonzero limit but a finite-sample fluctuation around an *exactly zero* population
value.  If so, there must be an exact cancellation on the unrestricted (odd) support.

Experiment (Experimenter): a direct enumeration over the full odd support mod `2^t` for
`t = 4,5,6` (see `ComputationalEvidence.md`) gives, for every `1 ≤ j < t` and every parity of the
low block, correlation exactly `0` in exact rational arithmetic — not `10^{-3}`.  Per public value
the counts are exactly `(8,8)` for all 16 fibers at `t = 5` and `(16,16)` for all 32 fibers at
`t = 6`.  Restricting the support to `p < q` (the "smaller factor" convention) reintroduces
correlations at the `m^{-1/2}` scale (`2/15, 2/31, 1/21` at `t = 5,6,7`), and restricting further
to primes reproduces the reported `0.254 / 0.166` at `k = 8 / 10` for the `j = 2` anomaly, with
sign flips at `k = 7, 9` identifying it as a fluctuation.

Analysis (Analyst): the mechanism is the simply transitive action of the odd residues on
themselves.  For a *fixed* multiplier `p`, the map `q ↦ p q mod 2^t` permutes the odd residues, so
the public value `N` is independent of `p` in the exact, distributional sense; the sign
`(-1)^{p_j}` then factors out of the double sum and vanishes because `x ↦ x XOR 2^j` is a
sign-reversing involution of the odd residues.  Both ingredients are exact; neither survives the
restriction to `p < q`, which is precisely the reported source of the residual `m^{-1/2}` noise.

Critique (Critic): the theorem is about the odd support, not the prime support, and about ordered
pairs, not the `min`.  Both restrictions are recorded honestly here: the involution `x ↦ x XOR 2^j`
does not preserve `p < q`, so the exact statement provably does not transfer to the ordered
support — which is exactly why the experiment sees `O(m^{-1/2})` and not `0` there.  The top-bit
law, by contrast, is unconditional and holds for every balanced semiprime.
-/
import Novelty.WalshSpectralFlatness

namespace SpectralFlatnessFactoring

open Finset SpectralFlatness

/-! ### The full odd support modulo `2^t` -/

/-- The odd residues mod `2^t`: the "full odd support" of the experiment. -/
def OddRes (t : ℕ) : Finset ℕ := (Finset.range (2 ^ t)).filter fun x => x % 2 = 1

theorem mem_oddRes {t x : ℕ} : x ∈ OddRes t ↔ x < 2 ^ t ∧ x % 2 = 1 := by simp [OddRes]

/-- `±1` encoding of bit `j`. -/
noncomputable def bitSign (j x : ℕ) : ℝ := sgn (x.testBit j)

theorem bitSign_eq_one_or (j x : ℕ) : bitSign j x = 1 ∨ bitSign j x = -1 := by
  unfold bitSign sgn
  by_cases h : x.testBit j <;> simp [h]

/-- Flipping bit `j` flips the sign. -/
theorem bitSign_xor (j x : ℕ) : bitSign j (x ^^^ 2 ^ j) = -bitSign j x := by
  have h : (x ^^^ 2 ^ j).testBit j = !x.testBit j := by simp [Nat.testBit_xor]
  simp only [bitSign, sgn, h]
  cases x.testBit j <;> norm_num

/-- **Balancedness of the interior bits of the odd residues.**  For `1 ≤ j < t`, exactly half of
the odd residues mod `2^t` have bit `j` set: `x ↦ x XOR 2^j` is a sign-reversing involution. -/
theorem sum_bitSign_oddRes {j t : ℕ} (hj : 1 ≤ j) (hjt : j < t) :
    ∑ x ∈ OddRes t, bitSign j x = 0 := by
  have hj0 : j ≠ 0 := by omega
  refine Finset.sum_involution (fun x _ => x ^^^ 2 ^ j) ?_ ?_ ?_ ?_
  · intro a _; rw [bitSign_xor]; ring
  · intro a _ _ h
    have hb := congrArg (fun y => Nat.testBit y j) h
    simp [Nat.testBit_xor] at hb
  · intro a ha
    simp only [OddRes, mem_filter, mem_range] at ha ⊢
    refine ⟨Nat.xor_lt_two_pow ha.1 (Nat.pow_lt_pow_right one_lt_two hjt), ?_⟩
    have h0 : (a ^^^ 2 ^ j).testBit 0 = a.testBit 0 := by
      rw [Nat.testBit_xor]; simp [hj0]
    rw [Nat.testBit_zero, Nat.testBit_zero, decide_eq_decide] at h0
    omega
  · intro a _; simp

theorem oddRes_mul_mem {t p q : ℕ} (ht : 1 ≤ t) (hp : p ∈ OddRes t) (hq : q ∈ OddRes t) :
    p * q % 2 ^ t ∈ OddRes t := by
  rw [mem_oddRes] at hp hq ⊢
  refine ⟨Nat.mod_lt _ (Nat.two_pow_pos t), ?_⟩
  have hd : (2 : ℕ) ∣ 2 ^ t := dvd_pow_self 2 (by omega)
  rw [Nat.mod_mod_of_dvd _ hd]
  have h := Nat.mul_mod p q 2
  rw [hp.2, hq.2] at h
  simpa using h

/-- Multiplication by an odd residue is injective on the odd residues mod `2^t`. -/
theorem oddRes_mul_injOn {t p : ℕ} (hp : p ∈ OddRes t) :
    Set.InjOn (fun q => p * q % 2 ^ t) (OddRes t) := by
  intro a ha b hb hab
  simp only [Finset.mem_coe, mem_oddRes] at ha hb
  have hcop : Nat.gcd (2 ^ t) p = 1 :=
    Nat.Coprime.pow_left t
      ((Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr
        (by have := (mem_oddRes.mp hp).2; omega))
  have hmod : p * a ≡ p * b [MOD 2 ^ t] := hab
  have h3 := Nat.ModEq.cancel_left_of_coprime hcop hmod
  have h1 : a % 2 ^ t = a := Nat.mod_eq_of_lt ha.1
  have h2 : b % 2 ^ t = b := Nat.mod_eq_of_lt hb.1
  unfold Nat.ModEq at h3
  omega

/-- **Simple transitivity.**  Multiplication by a fixed odd residue permutes the odd residues:
the public value `N = p q mod 2^t` is a bijective reparametrisation of the cofactor `q`. -/
theorem oddRes_mul_image {t p : ℕ} (ht : 1 ≤ t) (hp : p ∈ OddRes t) :
    (OddRes t).image (fun q => p * q % 2 ^ t) = OddRes t := by
  have hinj : Set.InjOn (fun q => p * q % 2 ^ t) (OddRes t) := oddRes_mul_injOn hp
  refine Finset.eq_of_subset_of_card_le ?_ ?_
  · intro y hy
    simp only [mem_image] at hy
    obtain ⟨q, hq, rfl⟩ := hy
    exact oddRes_mul_mem ht hp hq
  · rw [Finset.card_image_of_injOn hinj]

/-! ### The zero-block theorem -/

/-- **Zero-block theorem (exact spectral flatness of the low block).**
For every real-valued statistic `g` of the public low block `N = p q mod 2^t` and every interior
bit `1 ≤ j < t`, the signed correlation of `p_j` with `g(N)` over the full odd support vanishes
identically.  Since `g` is arbitrary, this covers every GF(2) parity of any degree, every
polynomial in the bits of `N`, and every real statistic whatsoever. -/
theorem lowblock_corr_zero {t j : ℕ} (hj : 1 ≤ j) (hjt : j < t) (g : ℕ → ℝ) :
    ∑ p ∈ OddRes t, ∑ q ∈ OddRes t, bitSign j p * g (p * q % 2 ^ t) = 0 := by
  have ht : 1 ≤ t := by omega
  have hinner : ∀ p ∈ OddRes t,
      ∑ q ∈ OddRes t, bitSign j p * g (p * q % 2 ^ t)
        = bitSign j p * ∑ N ∈ OddRes t, g N := by
    intro p hp
    rw [← Finset.mul_sum]
    congr 1
    have hinj : Set.InjOn (fun q => p * q % 2 ^ t) (OddRes t) := oddRes_mul_injOn hp
    calc ∑ q ∈ OddRes t, g (p * q % 2 ^ t)
        = ∑ N ∈ (OddRes t).image (fun q => p * q % 2 ^ t), g N :=
          (Finset.sum_image hinj).symm
      _ = ∑ N ∈ OddRes t, g N := by rw [oddRes_mul_image ht hp]
  rw [Finset.sum_congr rfl hinner, ← Finset.sum_mul, sum_bitSign_oddRes hj hjt, zero_mul]

/-- The Walsh character (GF(2) parity) of a set `S` of bit positions of a natural number. -/
noncomputable def natParity (S : Finset ℕ) (N : ℕ) : ℝ := ∏ i ∈ S, sgn (N.testBit i)

/-- Reading a parity of low bit positions is the same before and after reduction mod `2^t`. -/
theorem natParity_mod {t : ℕ} {S : Finset ℕ} (hS : ∀ i ∈ S, i < t) (N : ℕ) :
    natParity S (N % 2 ^ t) = natParity S N := by
  refine Finset.prod_congr rfl fun i hi => ?_
  rw [Nat.testBit_mod_two_pow]
  simp [hS i hi]

/-- **The restricted Walsh spectrum of a factor bit vanishes on the low block.**  This is the
experiment's quantity `W(S) = ∑_x f_j(x) (-1)^{S·x}` itself, evaluated on the true integer product
`pq`: for every set `S` of bit positions below `t`, and every interior bit `1 ≤ j < t`, the
coefficient is exactly `0`. -/
theorem lowblock_walsh_spectrum_zero {t j : ℕ} (hj : 1 ≤ j) (hjt : j < t) {S : Finset ℕ}
    (hS : ∀ i ∈ S, i < t) :
    ∑ p ∈ OddRes t, ∑ q ∈ OddRes t, bitSign j p * natParity S (p * q) = 0 := by
  have h := lowblock_corr_zero hj hjt (natParity S)
  rw [← h]
  exact Finset.sum_congr rfl fun p _ => Finset.sum_congr rfl fun q _ => by
    rw [natParity_mod hS]

/-- Product form: the same statement summed over the support of ordered pairs. -/
theorem lowblock_corr_zero_prod {t j : ℕ} (hj : 1 ≤ j) (hjt : j < t) (g : ℕ → ℝ) :
    ∑ z ∈ OddRes t ×ˢ OddRes t, bitSign j z.1 * g (z.1 * z.2 % 2 ^ t) = 0 := by
  rw [Finset.sum_product]
  exact lowblock_corr_zero hj hjt g

/-- Auxiliary: a `±1`-valued sum vanishes iff the two signs are equinumerous. -/
theorem card_eq_of_sum_sign_zero {α : Type*} [DecidableEq α] {s : Finset α} {u : α → ℝ}
    (hu : ∀ a ∈ s, u a = 1 ∨ u a = -1) (h : ∑ a ∈ s, u a = 0) :
    (s.filter fun a => u a = 1).card = (s.filter fun a => ¬ u a = 1).card := by
  classical
  have hsplit : ∑ a ∈ s, u a
      = (∑ a ∈ s.filter fun a => u a = 1, u a) + ∑ a ∈ s.filter (fun a => ¬ u a = 1), u a :=
    (Finset.sum_filter_add_sum_filter_not _ _ _).symm
  have hp : ∀ a ∈ s.filter fun a => u a = 1, u a = 1 := by
    intro a ha; exact (Finset.mem_filter.mp ha).2
  have hn : ∀ a ∈ s.filter (fun a => ¬ u a = 1), u a = -1 := by
    intro a ha
    rw [Finset.mem_filter] at ha
    rcases hu a ha.1 with h1 | h1
    · exact absurd h1 ha.2
    · exact h1
  rw [Finset.sum_congr rfl hp, Finset.sum_congr rfl hn, Finset.sum_const, Finset.sum_const] at hsplit
  simp only [nsmul_eq_mul, mul_one, mul_neg_one] at hsplit
  rw [h] at hsplit
  have : ((s.filter fun a => u a = 1).card : ℝ) = ((s.filter fun a => ¬ u a = 1).card : ℝ) := by
    linarith
  exact_mod_cast this

/-- **The exact 1/2 barrier on the low block.**  Let `h` be *any* predictor that reads only the
public low block `N = p q mod 2^t`.  Over the full odd support, `h` predicts bit `j` of the secret
factor `p` correctly on exactly half of the pairs — never one pair more, for any `1 ≤ j < t`.  No
finite-sample slack, no low-degree hypothesis. -/
theorem lowblock_predictor_barrier {t j : ℕ} (hj : 1 ≤ j) (hjt : j < t) (h : ℕ → Bool) :
    ((OddRes t ×ˢ OddRes t).filter fun z => h (z.1 * z.2 % 2 ^ t) = z.1.testBit j).card
      = ((OddRes t ×ˢ OddRes t).filter fun z => ¬ h (z.1 * z.2 % 2 ^ t) = z.1.testBit j).card := by
  classical
  set u : ℕ × ℕ → ℝ := fun z => bitSign j z.1 * sgn (h (z.1 * z.2 % 2 ^ t)) with hu_def
  have hzero : ∑ z ∈ OddRes t ×ˢ OddRes t, u z = 0 := by
    rw [hu_def]
    exact lowblock_corr_zero_prod hj hjt (fun N => sgn (h N))
  have husign : ∀ z ∈ OddRes t ×ˢ OddRes t, u z = 1 ∨ u z = -1 := by
    intro z _
    rw [hu_def]
    simp only [bitSign, sgn]
    by_cases h1 : z.1.testBit j <;> by_cases h2 : h (z.1 * z.2 % 2 ^ t) <;> simp [h1, h2]
  have hiff : ∀ z : ℕ × ℕ, u z = 1 ↔ h (z.1 * z.2 % 2 ^ t) = z.1.testBit j := by
    intro z
    rw [hu_def]
    simp only [bitSign]
    rw [mul_comm, sgn_mul_eq_one_iff]
  have hkey := card_eq_of_sum_sign_zero husign hzero
  simpa only [hiff] using hkey

/-! ### The top-bit law: the one structure that is not flat -/

/-- If the second-highest bit of `p` is set then `p ≥ 3·2^e`. -/
theorem three_mul_le_of_testBit {e p : ℕ} (hp : 2 ^ (e + 1) ≤ p) (hbit : p.testBit e = true) :
    3 * 2 ^ e ≤ p := by
  have hpow : 0 < 2 ^ e := Nat.two_pow_pos e
  have hodd : p / 2 ^ e % 2 = 1 := by
    rw [Nat.testBit_eq_decide_div_mod_eq] at hbit
    simpa using hbit
  have hge : 2 ≤ p / 2 ^ e := by
    rw [Nat.le_div_iff_mul_le hpow]
    calc 2 * 2 ^ e = 2 ^ (e + 1) := by ring
      _ ≤ p := hp
  have h3 : 3 ≤ p / 2 ^ e := by omega
  calc 3 * 2 ^ e ≤ (p / 2 ^ e) * 2 ^ e := Nat.mul_le_mul_right _ h3
    _ ≤ p := Nat.div_mul_le_self p (2 ^ e)

/-- **The top-bit transmission law.**  For a balanced semiprime `N = p q` with
`2^{k-1} ≤ p ≤ q` (here `k = e + 2`), if the second-highest bit `p_{k-2}` of the smaller factor is
set then `N ≥ 2^{2k-1}`, i.e. the product carries out into its top bit.  This deterministic
implication is the entire source of the empirical `corr(p_{k-2}, N_{2k-1}) ≈ 0.285`. -/
theorem second_bit_transmits_to_top {e p q : ℕ} (hp : 2 ^ (e + 1) ≤ p) (hpq : p ≤ q)
    (hbit : p.testBit e = true) : 2 ^ (2 * e + 3) ≤ p * q := by
  have h3p : 3 * 2 ^ e ≤ p := three_mul_le_of_testBit hp hbit
  have h3q : 3 * 2 ^ e ≤ q := le_trans h3p hpq
  have hmul : (3 * 2 ^ e) * (3 * 2 ^ e) ≤ p * q := Nat.mul_le_mul h3p h3q
  have hpow : (3 * 2 ^ e) * (3 * 2 ^ e) = 9 * 2 ^ (2 * e) := by
    rw [two_mul, pow_add]; ring
  have h8 : 2 ^ (2 * e + 3) = 8 * 2 ^ (2 * e) := by rw [pow_add]; ring
  have : 8 * 2 ^ (2 * e) ≤ 9 * 2 ^ (2 * e) :=
    Nat.mul_le_mul_right _ (by norm_num)
  omega

/-- Contrapositive form: no carry out of the product forces the second-highest bit of the smaller
factor to be `0`.  (`N < 2^{2k-1} ⟹ p_{k-2} = 0`.) -/
theorem second_bit_zero_of_top_bit_zero {e p q : ℕ} (hp : 2 ^ (e + 1) ≤ p) (hpq : p ≤ q)
    (hN : p * q < 2 ^ (2 * e + 3)) : p.testBit e = false := by
  by_contra hcon
  have hb : p.testBit e = true := by
    cases hbit : p.testBit e with
    | false => exact absurd hbit hcon
    | true => rfl
  exact absurd (second_bit_transmits_to_top hp hpq hb) (not_le.mpr hN)

/-- For a number below `2^{m+1}`, the bit `m` is exactly the magnitude indicator `2^m ≤ N`. -/
theorem testBit_top_iff {N m : ℕ} (hN : N < 2 ^ (m + 1)) : N.testBit m = true ↔ 2 ^ m ≤ N := by
  rw [Nat.testBit_eq_decide_div_mod_eq]
  have hpow : 0 < 2 ^ m := Nat.two_pow_pos m
  constructor
  · intro h
    have h1 : N / 2 ^ m % 2 = 1 := by simpa using h
    have hne : N / 2 ^ m ≠ 0 := by
      intro h0
      rw [h0] at h1
      simp at h1
    have h2 : 1 ≤ N / 2 ^ m := Nat.one_le_iff_ne_zero.mpr hne
    rwa [Nat.le_div_iff_mul_le hpow, one_mul] at h2
  · intro h
    have h1 : 1 ≤ N / 2 ^ m := by rwa [Nat.le_div_iff_mul_le hpow, one_mul]
    have h2 : N / 2 ^ m < 2 := by
      rw [Nat.div_lt_iff_lt_mul hpow]
      calc N < 2 ^ (m + 1) := hN
        _ = 2 * 2 ^ m := by ring
    have : N / 2 ^ m = 1 := by omega
    simp [this]

/-- **Bit-level form of the transmission law.**  For a balanced semiprime with `k = e + 2` bit
factors, `p_{k-2} = 1` implies `N_{2k-1} = 1`: the second-highest bit of the hidden factor is
visible in the top bit of the public value. -/
theorem second_bit_transmits_to_top_bit {e p q : ℕ} (hp : 2 ^ (e + 1) ≤ p) (hpq : p ≤ q)
    (hq : q < 2 ^ (e + 2)) (hbit : p.testBit e = true) :
    (p * q).testBit (2 * e + 3) = true := by
  have hpq2 : p * q < 2 ^ (2 * e + 4) := by
    have hp2 : p < 2 ^ (e + 2) := lt_of_le_of_lt hpq hq
    calc p * q < 2 ^ (e + 2) * 2 ^ (e + 2) := by
          exact Nat.mul_lt_mul_of_lt_of_le hp2 (le_of_lt hq) (Nat.two_pow_pos (e + 2))
      _ = 2 ^ (2 * e + 4) := by rw [← pow_add]; ring_nf
  have := testBit_top_iff (N := p * q) (m := 2 * e + 3) (by simpa [Nat.add_assoc] using hpq2)
  exact this.mpr (second_bit_transmits_to_top hp hpq hbit)

/-- **Symmetry of the leaking statistic.**  The only structure the spectrum sees, the top bit of
`N`, is a symmetric function of the two factors: it cannot distinguish `p` from `q` and so is
"non-factor-revealing" in the sense of the barrier framework. -/
theorem top_bit_symmetric (p q m : ℕ) : (p * q).testBit m = (q * p).testBit m := by
  rw [Nat.mul_comm]

/-- **One-sidedness of the transmission law (sharpness).**  Two balanced `5`-bit semiprimes with
the *same* top bit of `N` but different second-highest bit of the smaller factor: the top bit of
`N` therefore does not determine `p_{k-2}`, and the correlation is strictly between `0` and `1`. -/
theorem top_bit_does_not_determine_second_bit :
    (17 * 31 : ℕ).testBit 9 = true ∧ (29 * 31 : ℕ).testBit 9 = true ∧
      (17 : ℕ).testBit 3 = false ∧ (29 : ℕ).testBit 3 = true ∧
      Nat.Prime 17 ∧ Nat.Prime 29 ∧ Nat.Prime 31 := by
  refine ⟨by decide, by decide, by decide, by decide, by norm_num, by norm_num, by norm_num⟩

/-- The same phenomenon for a *low* bit: the top bit of `N` carries no information about `p_1`. -/
theorem top_bit_does_not_determine_low_bit :
    (17 * 31 : ℕ).testBit 9 = true ∧ (19 * 29 : ℕ).testBit 9 = true ∧
      (17 : ℕ).testBit 1 = false ∧ (19 : ℕ).testBit 1 = true := by
  refine ⟨by decide, by decide, by decide, by decide⟩

/-! ### Cycle 2: the abstract mechanism, conditional balance, and a strictly positive top bias -/

/-- **The mechanism, abstractly.**  On any finite group, a mean-zero statistic of the first factor
is uncorrelated with *every* statistic of the product.  The zero-block theorem is the instance
`G = (ℤ/2^t)ˣ` with `u = (-1)^{p_j}`: what kills the correlation is not arithmetic but the
simple transitivity of the regular representation. -/
theorem group_zero_block {G : Type*} [Fintype G] [Group G] (u g : G → ℝ)
    (hu : ∑ x, u x = 0) : ∑ p : G, ∑ q : G, u p * g (p * q) = 0 := by
  have hinner : ∀ p : G, ∑ q : G, u p * g (p * q) = u p * ∑ w : G, g w := by
    intro p
    rw [← Finset.mul_sum]
    congr 1
    exact Fintype.sum_bijective (fun q => p * q) (Group.mulLeft_bijective p) _ _ fun _ => rfl
  simp_rw [hinner]
  rw [← Finset.sum_mul, hu, zero_mul]

/-- The fiber of the public value: all factorisations of `N` in the odd support mod `2^t`. -/
def fiber (t N : ℕ) : Finset (ℕ × ℕ) :=
  (OddRes t ×ˢ OddRes t).filter fun z => z.1 * z.2 % 2 ^ t = N

theorem sgn_eq_one_iff (b : Bool) : sgn b = 1 ↔ b = false := by
  cases b <;> norm_num [sgn]

/-- **Conditional balance (the strongest form of flatness).**  Not merely on average over the
support: conditioned on *every single* public value `N`, the signed bit `(-1)^{p_j}` sums to zero
over the fiber.  The public value carries literally no information about an interior bit of the
secret factor. -/
theorem fiber_sum_bitSign_zero {t j N : ℕ} (hj : 1 ≤ j) (hjt : j < t) (hN : N ∈ OddRes t) :
    ∑ z ∈ fiber t N, bitSign j z.1 = 0 := by
  have ht : 1 ≤ t := by omega
  have hbij : ∑ z ∈ fiber t N, bitSign j z.1 = ∑ p ∈ OddRes t, bitSign j p := by
    refine Finset.sum_bij (fun z _ => z.1) ?_ ?_ ?_ ?_
    · intro z hz
      simp only [fiber, Finset.mem_filter, Finset.mem_product] at hz
      exact hz.1.1
    · intro z hz w hw hzw
      simp only [fiber, Finset.mem_filter, Finset.mem_product] at hz hw
      have hzw' : z.1 = w.1 := hzw
      have h1 : z.1 * z.2 % 2 ^ t = w.1 * w.2 % 2 ^ t := by rw [hz.2, hw.2]
      rw [hzw'] at h1
      have h2 : z.2 = w.2 :=
        oddRes_mul_injOn hw.1.1 (by simpa using hz.1.2) (by simpa using hw.1.2) h1
      exact Prod.ext hzw' h2
    · intro p hp
      have himg : N ∈ (OddRes t).image (fun q => p * q % 2 ^ t) := by
        rw [oddRes_mul_image ht hp]; exact hN
      rw [Finset.mem_image] at himg
      obtain ⟨q, hq, hqe⟩ := himg
      refine ⟨(p, q), ?_, rfl⟩
      simp only [fiber, Finset.mem_filter, Finset.mem_product]
      exact ⟨⟨hp, hq⟩, hqe⟩
    · intro z _; rfl
  rw [hbij, sum_bitSign_oddRes hj hjt]

/-- Card form of conditional balance: within every fiber, bit `j` of the secret factor is `0` on
exactly as many factorisations as it is `1`. -/
theorem fiber_bit_balanced {t j N : ℕ} (hj : 1 ≤ j) (hjt : j < t) (hN : N ∈ OddRes t) :
    ((fiber t N).filter fun z => z.1.testBit j = false).card
      = ((fiber t N).filter fun z => ¬ z.1.testBit j = false).card := by
  classical
  have husign : ∀ z ∈ fiber t N, bitSign j z.1 = 1 ∨ bitSign j z.1 = -1 :=
    fun z _ => bitSign_eq_one_or j z.1
  have hiff : ∀ z : ℕ × ℕ, bitSign j z.1 = 1 ↔ z.1.testBit j = false := by
    intro z; rw [bitSign, sgn_eq_one_iff]
  have hkey := card_eq_of_sum_sign_zero husign (fiber_sum_bitSign_zero hj hjt hN)
  simpa only [hiff] using hkey

/-! #### The top-bit bias is strictly positive at every size -/

/-- The balanced support at half-size `k = e + 2`: all ordered pairs `2^{k-1} ≤ p ≤ q < 2^k`. -/
def BalSupp (e : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (2 ^ (e + 2))) ×ˢ (Finset.range (2 ^ (e + 2)))).filter
    fun z => 2 ^ (e + 1) ≤ z.1 ∧ z.1 ≤ z.2

/-- Pairs whose smaller factor has its second-highest bit set. -/
def hiSet (e : ℕ) : Finset (ℕ × ℕ) := (BalSupp e).filter fun z => z.1.testBit e = true

/-- Pairs whose product carries out into the top bit. -/
def topSet (e : ℕ) : Finset (ℕ × ℕ) :=
  (BalSupp e).filter fun z => (z.1 * z.2).testBit (2 * e + 3) = true

theorem mem_balSupp {e : ℕ} {z : ℕ × ℕ} :
    z ∈ BalSupp e ↔ (z.1 < 2 ^ (e + 2) ∧ z.2 < 2 ^ (e + 2)) ∧ 2 ^ (e + 1) ≤ z.1 ∧ z.1 ≤ z.2 := by
  simp [BalSupp, Finset.mem_filter, Finset.mem_product, and_assoc]

/-- The transmission law as an inclusion of events. -/
theorem hiSet_subset_topSet (e : ℕ) : hiSet e ⊆ topSet e := by
  intro z hz
  rw [hiSet, Finset.mem_filter] at hz
  obtain ⟨hmem, hbit⟩ := hz
  rw [mem_balSupp] at hmem
  rw [topSet, Finset.mem_filter]
  exact ⟨mem_balSupp.mpr hmem,
    second_bit_transmits_to_top_bit hmem.2.1 hmem.2.2 hmem.1.2 hbit⟩

/-- The event `p_{k-2} = 1` is nonempty at every size. -/
theorem hiSet_nonempty (e : ℕ) : (hiSet e).Nonempty := by
  refine ⟨(3 * 2 ^ e, 3 * 2 ^ e), ?_⟩
  have hpow : 0 < 2 ^ e := Nat.two_pow_pos e
  have hlt : 3 * 2 ^ e < 2 ^ (e + 2) := by
    have : 2 ^ (e + 2) = 4 * 2 ^ e := by ring
    omega
  have hge : 2 ^ (e + 1) ≤ 3 * 2 ^ e := by
    have : 2 ^ (e + 1) = 2 * 2 ^ e := by ring
    omega
  rw [hiSet, Finset.mem_filter, mem_balSupp]
  refine ⟨⟨⟨hlt, hlt⟩, hge, le_rfl⟩, ?_⟩
  rw [Nat.testBit_eq_decide_div_mod_eq, Nat.mul_div_cancel _ hpow]
  norm_num

/-- The event `N_{2k-1} = 1` is not everything: the smallest balanced pair has no carry-out. -/
theorem topSet_ssubset (e : ℕ) : topSet e ⊂ BalSupp e := by
  refine ⟨Finset.filter_subset _ _, ?_⟩
  intro hsub
  have hmem : ((2 : ℕ) ^ (e + 1), (2 : ℕ) ^ (e + 1)) ∈ BalSupp e := by
    have hlt : (2 : ℕ) ^ (e + 1) < 2 ^ (e + 2) := Nat.pow_lt_pow_right one_lt_two (by omega)
    rw [mem_balSupp]
    exact ⟨⟨hlt, hlt⟩, le_rfl, le_rfl⟩
  have hin := hsub hmem
  rw [topSet, Finset.mem_filter] at hin
  have hsmall : (2 : ℕ) ^ (e + 1) * 2 ^ (e + 1) < 2 ^ (2 * e + 3) := by
    have h1 : (2 : ℕ) ^ (e + 1) * 2 ^ (e + 1) = 2 ^ (2 * e + 2) := by
      rw [← pow_add]; ring_nf
    rw [h1]
    exact Nat.pow_lt_pow_right one_lt_two (by omega)
  have := Nat.testBit_lt_two_pow hsmall
  rw [this] at hin
  exact Bool.false_ne_true hin.2

/-- The covariance of the two indicator events `p_{k-2} = 1` and `N_{2k-1} = 1` over the balanced
support. -/
def covTop (e : ℕ) : ℚ :=
  (((hiSet e ∩ topSet e).card : ℚ) / ((BalSupp e).card : ℚ))
    - (((hiSet e).card : ℚ) / ((BalSupp e).card : ℚ))
      * (((topSet e).card : ℚ) / ((BalSupp e).card : ℚ))

/-- **The top-bit family is genuinely non-flat, at every size.**  The correlation between the
second-highest bit of the smaller factor and the top bit of `N` is strictly positive for every
`k = e + 2` — in contrast with the exactly vanishing low-block correlations.  This is the formal
counterpart of the empirical `corr(p_{k-2}, N_{2k-1}) ≈ 0.285`. -/
theorem covTop_pos (e : ℕ) : 0 < covTop e := by
  have hAB : hiSet e ∩ topSet e = hiSet e := Finset.inter_eq_left.mpr (hiSet_subset_topSet e)
  have hApos : 0 < (hiSet e).card := Finset.card_pos.mpr (hiSet_nonempty e)
  have hBlt : (topSet e).card < (BalSupp e).card := Finset.card_lt_card (topSet_ssubset e)
  have hSpos : 0 < (BalSupp e).card := lt_of_le_of_lt (Nat.zero_le _) hBlt
  have hS : (0 : ℚ) < ((BalSupp e).card : ℚ) := by exact_mod_cast hSpos
  have hA : (0 : ℚ) < ((hiSet e).card : ℚ) := by exact_mod_cast hApos
  have hB : ((topSet e).card : ℚ) < ((BalSupp e).card : ℚ) := by exact_mod_cast hBlt
  rw [covTop, hAB]
  have key : ((hiSet e).card : ℚ) / ((BalSupp e).card : ℚ)
      - ((hiSet e).card : ℚ) / ((BalSupp e).card : ℚ)
        * (((topSet e).card : ℚ) / ((BalSupp e).card : ℚ))
      = (((hiSet e).card : ℚ) / ((BalSupp e).card : ℚ))
        * ((((BalSupp e).card : ℚ) - ((topSet e).card : ℚ)) / ((BalSupp e).card : ℚ)) := by
    field_simp
  rw [key]
  apply mul_pos (div_pos hA hS)
  exact div_pos (by linarith) hS

/-! ### Cycle 3: perfect secrecy of the low block -/

theorem mem_fiber {t N : ℕ} {z : ℕ × ℕ} :
    z ∈ fiber t N ↔ (z.1 ∈ OddRes t ∧ z.2 ∈ OddRes t) ∧ z.1 * z.2 % 2 ^ t = N := by
  simp [fiber, Finset.mem_filter, Finset.mem_product]

/-- Inside a fiber the cofactor is determined by the factor. -/
theorem fiber_fst_inj {t N : ℕ} {z w : ℕ × ℕ} (hz : z ∈ fiber t N) (hw : w ∈ fiber t N)
    (h : z.1 = w.1) : z = w := by
  rw [mem_fiber] at hz hw
  have h1 : z.1 * z.2 % 2 ^ t = w.1 * w.2 % 2 ^ t := by rw [hz.2, hw.2]
  rw [h] at h1
  exact Prod.ext h (oddRes_mul_injOn hw.1.1 (by simpa using hz.1.2) (by simpa using hw.1.2) h1)

/-- Every odd residue occurs as the first factor in every fiber. -/
theorem exists_fiber_of_mem {t N a : ℕ} (ht : 1 ≤ t) (hN : N ∈ OddRes t) (ha : a ∈ OddRes t) :
    ∃ q, (a, q) ∈ fiber t N := by
  have himg : N ∈ (OddRes t).image (fun q => a * q % 2 ^ t) := by
    rw [oddRes_mul_image ht ha]; exact hN
  rw [Finset.mem_image] at himg
  obtain ⟨q, hq, hqe⟩ := himg
  exact ⟨q, mem_fiber.mpr ⟨⟨ha, hq⟩, hqe⟩⟩

/-- **The fiber is a faithful copy of the whole secret space.**  For any property `P` of the
secret factor, the number of factorisations of `N` whose factor satisfies `P` equals the number of
odd residues satisfying `P`, independently of `N`. -/
theorem fiber_filter_card {t N : ℕ} (ht : 1 ≤ t) (hN : N ∈ OddRes t)
    (P : ℕ → Prop) [DecidablePred P] :
    ((fiber t N).filter fun z => P z.1).card = ((OddRes t).filter P).card := by
  refine Finset.card_bij (fun z _ => z.1) ?_ ?_ ?_
  · intro z hz
    rw [Finset.mem_filter] at hz
    exact Finset.mem_filter.mpr ⟨(mem_fiber.mp hz.1).1.1, hz.2⟩
  · intro z hz w hw h
    exact fiber_fst_inj (Finset.mem_filter.mp hz).1 (Finset.mem_filter.mp hw).1 h
  · intro a ha
    rw [Finset.mem_filter] at ha
    obtain ⟨q, hq⟩ := exists_fiber_of_mem ht hN ha.1
    exact ⟨(a, q), Finset.mem_filter.mpr ⟨hq, ha.2⟩, rfl⟩

/-- **Perfect secrecy of the low block.**  Two different public values induce *identical*
distributions on any property of the secret factor: observing `N mod 2^t` is statistically
indistinguishable from observing nothing at all.  This subsumes every correlation statement:
there is nothing to correlate with. -/
theorem fiber_distribution_independent {t N N' : ℕ} (ht : 1 ≤ t) (hN : N ∈ OddRes t)
    (hN' : N' ∈ OddRes t) (P : ℕ → Prop) [DecidablePred P] :
    ((fiber t N).filter fun z => P z.1).card = ((fiber t N').filter fun z => P z.1).card := by
  rw [fiber_filter_card ht hN P, fiber_filter_card ht hN' P]

/-- The number of odd residues mod `2^t`. -/
theorem card_oddRes {t : ℕ} (ht : 1 ≤ t) : (OddRes t).card = 2 ^ (t - 1) := by
  have hpow : 2 ^ t = 2 * 2 ^ (t - 1) := by
    rw [← pow_succ']
    congr 1
    omega
  have himg : OddRes t = (Finset.range (2 ^ (t - 1))).image (fun m => 2 * m + 1) := by
    ext x
    simp only [mem_oddRes, Finset.mem_image, Finset.mem_range]
    constructor
    · intro hx
      exact ⟨x / 2, by omega, by omega⟩
    · rintro ⟨m, hm, rfl⟩
      omega
  rw [himg, Finset.card_image_of_injective _ (by intro a b hab; dsimp at hab; omega),
    Finset.card_range]

/-- Every fiber has exactly `2^{t-1}` points: the secret factor ranges over the whole unit
group. -/
theorem fiber_card {t N : ℕ} (ht : 1 ≤ t) (hN : N ∈ OddRes t) :
    (fiber t N).card = 2 ^ (t - 1) := by
  classical
  have h := fiber_filter_card ht hN (fun _ => True)
  simpa [Finset.filter_true, card_oddRes ht] using h

/-- **No guessing strategy beats chance.**  A predictor that outputs a candidate value for the
whole secret low block from the public value hits at most one of the `2^{t-1}` factorisations:
its success probability is exactly the `2^{-(t-1)}` of a blind guess. -/
theorem guess_card_le_one {t N : ℕ} (ht : 1 ≤ t) (hN : N ∈ OddRes t) (h : ℕ → ℕ) :
    ((fiber t N).filter fun z => z.1 = h N).card ≤ 1 := by
  classical
  rw [fiber_filter_card ht hN (fun a => a = h N)]
  rw [Finset.filter_eq' (OddRes t) (h N)]
  by_cases hmem : h N ∈ OddRes t <;> simp [hmem]

/-! ### Putting the two halves together -/

/-- **The verdict, formally.**  Fix the modulus `2^t`, an interior bit `1 ≤ j < t` and two public
values `N`, `N'`.  Then:

* the low block is *perfectly secret*: every property of the secret factor has exactly the same
  count under `N` as under `N'`;
* in particular bit `j` of the secret factor is exactly balanced in every fiber; and
* the one statistic that does correlate — the top bit of the product — is symmetric in the two
  factors, hence non-factor-revealing.

The conjunction is the "flat spectrum plus symmetric top-bit family" picture measured in the
experiment.  The global (support-averaged) predictor form is `lowblock_predictor_barrier`. -/
theorem spectral_flatness_verdict {t j N N' : ℕ} (hj : 1 ≤ j) (hjt : j < t)
    (hN : N ∈ OddRes t) (hN' : N' ∈ OddRes t) :
    (∀ P : ℕ → Bool,
        ((fiber t N).filter fun z => P z.1 = true).card
          = ((fiber t N').filter fun z => P z.1 = true).card)
      ∧ ((fiber t N).filter fun z => z.1.testBit j = false).card
          = ((fiber t N).filter fun z => ¬ z.1.testBit j = false).card
      ∧ (∀ p q m : ℕ, (p * q).testBit m = (q * p).testBit m) :=
  ⟨fun P => fiber_distribution_independent (by omega) hN hN' fun a => P a = true,
    fiber_bit_balanced hj hjt hN, top_bit_symmetric⟩

end SpectralFlatnessFactoring