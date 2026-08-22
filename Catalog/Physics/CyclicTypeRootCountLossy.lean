import Physics.CyclicTypeChannelPrime

/-!
# Root-count lossiness, in general: the binary readout loses information exactly at composites

The catalog file `Catalog.Computation.CyclicTypeChannel` introduces two readouts of the
Frobenius class `x` of a cyclic Galois group `C_n`:

* the **splitting type** `T(x) = n / gcd (n, x)`, a multi-state observable whose law is the
  Euler-φ law `P(T = d) = φ(d)/n` over the divisor lattice of `n`;
* the **root count** `nr`, the binary coarsening "splits completely (`T = 1`) or not".

`Catalog.Computation.CyclicTypeDeterminism` proves `H(nr) = H(T)` for prime cyclic orders and
`Catalog.Computation.CyclicTypeChannelLaws` exhibits two composite orders (`n = 4, 6`) where the
inequality is strict.  Here we settle the general statement.

## Main results

* `CyclicType.Hnr_le_HT` : `H(nr) ≤ H(T)` for every cyclic order `n ≥ 1` — coarsening never
  gains information.
* `CyclicType.Hnr_lt_HT_of_not_prime` : the inequality is **strict** for every composite order.
* `CyclicType.Hnr_lt_HT_iff` : for `n ≥ 2`, `H(nr) < H(T) ↔ ¬ n.Prime`.  The root-count readout
  is lossy *exactly* at the composite cyclic orders, i.e. exactly when the divisor lattice of
  the Galois group has more than one nontrivial level.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

open Finset

variable {n : ℕ}

/-- The weighted log-sum of the Euler-φ type law, restricted to the nontrivial types. -/
private noncomputable def phiLogSum (n : ℕ) : ℝ :=
  ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)

private lemma phiLogSum_erase (n : ℕ) :
    phiLogSum n = ∑ d ∈ n.divisors.erase 1, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d) := by
  rw [phiLogSum, ← Finset.sum_erase (f := fun d => (Nat.totient d : ℝ)
    * Real.logb 2 (Nat.totient d)) (s := n.divisors) (a := 1) (by simp)]

private lemma sum_totient_erase (hn : 0 < n) :
    ∑ d ∈ n.divisors.erase 1, ((Nat.totient d : ℝ)) = (n : ℝ) - 1 := by
  have hmem : (1 : ℕ) ∈ n.divisors := Nat.one_mem_divisors.2 hn.ne'
  have hall : ∑ d ∈ n.divisors, ((Nat.totient d : ℝ)) = (n : ℝ) := by
    rw [← Nat.cast_sum, Nat.sum_totient]
  have := Finset.sum_erase_add (n.divisors) (fun d => ((Nat.totient d : ℝ))) hmem
  rw [hall] at this
  simp only [Nat.totient_one, Nat.cast_one] at this
  linarith

private lemma totient_le_sub_one {d : ℕ} (hd : d ∣ n) (hd1 : d ≠ 1) (hn : 0 < n) :
    Nat.totient d ≤ n - 1 := by
  have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hd hn
  have hdle : d ≤ n := Nat.le_of_dvd hn hd
  have h2 : 2 ≤ d := by omega
  have := Nat.totient_lt d h2
  omega

/-- **Coarsening never gains information.**  The binary root-count readout has entropy at most
that of the full splitting type, for every cyclic order. -/
theorem Hnr_le_HT (hn : 0 < n) : Hnr n ≤ HT n := by
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.2 hn.ne') with h1 | h2
  · -- `n = 1`: both entropies vanish
    rw [Hnr_eq_binary_entropy hn, HT_divisor_formula hn, ← h1]
    norm_num
  have hn2 : 2 ≤ n := h2
  have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
  have hpos : (0 : ℝ) < (n : ℝ) := by linarith
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have : 1 ≤ n := by omega
    push_cast [this]; ring
  -- every nontrivial type contributes at most `φ(d) log₂ (n-1)`
  have hterm : ∀ d ∈ n.divisors.erase 1,
      (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
        ≤ (Nat.totient d : ℝ) * Real.logb 2 ((n : ℝ) - 1) := by
    intro d hd
    obtain ⟨hd1, hdmem⟩ := Finset.mem_erase.1 hd
    obtain ⟨hdvd, -⟩ := Nat.mem_divisors.1 hdmem
    have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hn
    have htpos : 0 < Nat.totient d := Nat.totient_pos.2 hdpos
    have hle : (Nat.totient d : ℝ) ≤ (n : ℝ) - 1 := by
      have := totient_le_sub_one hdvd hd1 hn
      have : ((Nat.totient d : ℕ) : ℝ) ≤ ((n - 1 : ℕ) : ℝ) := by exact_mod_cast this
      rwa [hcast] at this
    have htR : (0 : ℝ) < (Nat.totient d : ℝ) := by exact_mod_cast htpos
    exact mul_le_mul_of_nonneg_left
      (Real.logb_le_logb_of_le (by norm_num) htR hle) (le_of_lt htR)
  have hsum : phiLogSum n ≤ ((n : ℝ) - 1) * Real.logb 2 ((n : ℝ) - 1) := by
    rw [phiLogSum_erase n]
    refine le_trans (Finset.sum_le_sum hterm) ?_
    rw [← Finset.sum_mul, sum_totient_erase hn]
  rw [Hnr_eq_binary_entropy hn, HT_divisor_formula hn, hcast]
  have hphi : ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
      = phiLogSum n := rfl
  rw [hphi, sub_le_sub_iff_left]
  have hinv : (0 : ℝ) < 1 / (n : ℝ) := by positivity
  have h := mul_le_mul_of_nonneg_left hsum hinv.le
  have hrw : ((n : ℝ) - 1) / (n : ℝ) * Real.logb 2 ((n : ℝ) - 1)
      = 1 / (n : ℝ) * (((n : ℝ) - 1) * Real.logb 2 ((n : ℝ) - 1)) := by ring
  rw [hrw]
  exact h

/-- **Strict lossiness at composite orders.**  If the cyclic order is composite, the binary
root-count readout carries strictly less information than the full splitting type. -/
theorem Hnr_lt_HT_of_not_prime (hn : 2 ≤ n) (hcomp : ¬ n.Prime) : Hnr n < HT n := by
  have hnpos : 0 < n := by omega
  have hnR : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hpos : (0 : ℝ) < (n : ℝ) := by linarith
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have : 1 ≤ n := by omega
    push_cast [this]; ring
  -- the minimal prime factor is a nontrivial divisor strictly below `n`
  have hmf : n.minFac ∣ n := Nat.minFac_dvd n
  have hmfp : (n.minFac).Prime := Nat.minFac_prime (by omega)
  have hmfne : n.minFac ≠ n := by
    intro h
    exact hcomp (Nat.prime_def_minFac.2 ⟨hn, h⟩)
  have hmflt : n.minFac < n := lt_of_le_of_ne (Nat.le_of_dvd hnpos hmf) hmfne
  have hmfmem : n.minFac ∈ n.divisors.erase 1 := by
    refine Finset.mem_erase.2 ⟨hmfp.ne_one, Nat.mem_divisors.2 ⟨hmf, by omega⟩⟩
  -- and its totient is strictly below `n - 1`
  have hstrict : (Nat.totient n.minFac : ℝ) * Real.logb 2 (Nat.totient n.minFac)
      < (Nat.totient n.minFac : ℝ) * Real.logb 2 ((n : ℝ) - 1) := by
    have htpos : 0 < Nat.totient n.minFac := Nat.totient_pos.2 hmfp.pos
    have hlt : Nat.totient n.minFac < n - 1 := by
      have := Nat.totient_lt n.minFac hmfp.one_lt
      omega
    have hltR : (Nat.totient n.minFac : ℝ) < (n : ℝ) - 1 := by
      have : ((Nat.totient n.minFac : ℕ) : ℝ) < ((n - 1 : ℕ) : ℝ) := by exact_mod_cast hlt
      rwa [hcast] at this
    have htR : (0 : ℝ) < (Nat.totient n.minFac : ℝ) := by exact_mod_cast htpos
    exact mul_lt_mul_of_pos_left (Real.logb_lt_logb (by norm_num) htR hltR) htR
  have hterm : ∀ d ∈ n.divisors.erase 1,
      (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
        ≤ (Nat.totient d : ℝ) * Real.logb 2 ((n : ℝ) - 1) := by
    intro d hd
    obtain ⟨hd1, hdmem⟩ := Finset.mem_erase.1 hd
    obtain ⟨hdvd, -⟩ := Nat.mem_divisors.1 hdmem
    have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hnpos
    have htpos : 0 < Nat.totient d := Nat.totient_pos.2 hdpos
    have hle : (Nat.totient d : ℝ) ≤ (n : ℝ) - 1 := by
      have h := totient_le_sub_one hdvd hd1 hnpos
      have h' : ((Nat.totient d : ℕ) : ℝ) ≤ ((n - 1 : ℕ) : ℝ) := by exact_mod_cast h
      rwa [hcast] at h'
    have htR : (0 : ℝ) < (Nat.totient d : ℝ) := by exact_mod_cast htpos
    exact mul_le_mul_of_nonneg_left
      (Real.logb_le_logb_of_le (by norm_num) htR hle) (le_of_lt htR)
  have hsum : phiLogSum n < ((n : ℝ) - 1) * Real.logb 2 ((n : ℝ) - 1) := by
    rw [phiLogSum_erase n]
    refine lt_of_lt_of_le
      (Finset.sum_lt_sum hterm ⟨n.minFac, hmfmem, hstrict⟩) ?_
    rw [← Finset.sum_mul, sum_totient_erase hnpos]
  rw [Hnr_eq_binary_entropy hnpos, HT_divisor_formula hnpos, hcast]
  have hphi : ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
      = phiLogSum n := rfl
  rw [hphi, sub_lt_sub_iff_left]
  have hinv : (0 : ℝ) < 1 / (n : ℝ) := by positivity
  have h := mul_lt_mul_of_pos_left hsum hinv
  have hrw : ((n : ℝ) - 1) / (n : ℝ) * Real.logb 2 ((n : ℝ) - 1)
      = 1 / (n : ℝ) * (((n : ℝ) - 1) * Real.logb 2 ((n : ℝ) - 1)) := by ring
  rw [hrw]
  exact h

/-- **The exact lossiness criterion.**  For a cyclic order `n ≥ 2`, the binary root-count
readout is strictly lossy precisely when `n` is composite; for prime orders the type channel is
itself binary and nothing is lost. -/
theorem Hnr_lt_HT_iff (hn : 2 ≤ n) : Hnr n < HT n ↔ ¬ n.Prime := by
  constructor
  · intro hlt hprime
    exact absurd (Hnr_eq_HT_of_prime hprime) (ne_of_lt hlt)
  · exact Hnr_lt_HT_of_not_prime hn

end CyclicType