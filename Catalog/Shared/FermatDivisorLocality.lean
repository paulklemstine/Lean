import Shared.FermatGapLocality

/-!
# From gap-locality to divisor-locality

`Shared.FermatGapLocality` computes the cost of Fermat's method on a semiprime
`N = p*q` and finds it to be `(p+q)/2 - ⌊√N⌋ - 1`, a function of the AM–GM gap
of the factor pair.  This file identifies *why*, by computing the cost of the
method on an **arbitrary odd non-square `N`**:

> Fermat's scan stops at the half-sum `(d + N/d)/2` of the ordered factorisation
> of `N` whose small factor `d` is **closest to `√N` from below**.

So the true locality class of Fermat is *divisor-locality at the square root*:
the method is blind to every divisor of `N` except the one nearest `√N`, and its
cost is the AM–GM gap of that single pair.  Gap-locality on semiprimes is the
special case where the nearest divisor below `√N` is the prime factor `p`
itself.

## Main results

* `factor_sum_antitone` : `d ↦ d + N/d` is antitone in the small factor `d`.
* `fermat_cost_eq_sInf_sums` : for odd non-square `N`, the stopping point of the
  scan is the least half-sum of an ordered factorisation of `N`.
* `fermat_cost_largest_divisor` : that least half-sum is realised by the largest
  small factor, i.e. by the divisor nearest `√N`.
* `fermat_cost_prime` / `fermat_cost_prime_exact` : the worst case.  On an odd
  **prime** `N` the only factorisation is the trivial one, so the scan runs to
  `(N+1)/2` and the cost is `(N - 2⌊√N⌋ - 1)/2`: Fermat's method is a `Θ(N)`
  primality test — the opposite end of the taxonomy from
  `fermatSteps_eq_zero_of_small_gap`.
-/

namespace FermatGapLocality

/-- Half-sums of the ordered factorisations of `N`: exactly the points at which
the difference-of-squares scan can stop. -/
def fermatSums (N : ℕ) : Set ℕ := {a | ∃ d e, d * e = N ∧ d ≤ e ∧ d + e = 2 * a}

/-- **The factor sum is antitone in the small factor.**  Of two ordered
factorisations of the same `N`, the one whose small factor is larger (hence
closer to `√N`) has the smaller sum. -/
lemma factor_sum_antitone {N d e d' e' : ℕ} (hN : 0 < N)
    (h : d * e = N) (h' : d' * e' = N) (hdd : d' ≤ d) (hde : d ≤ e) :
    d + e ≤ d' + e' := by
  have hd'0 : 0 < d' := by
    rcases Nat.eq_zero_or_pos d' with h0 | h0
    · exfalso; rw [h0, zero_mul] at h'; omega
    · exact h0
  obtain ⟨c, rfl⟩ : ∃ c, d = d' + c := ⟨d - d', by omega⟩
  have hkey : d' * (e + c) ≤ d' * e' := by
    have hce : c * d' ≤ c * e := Nat.mul_le_mul_left c (by omega)
    calc d' * (e + c) = d' * e + c * d' := by ring
      _ ≤ d' * e + c * e := by omega
      _ = (d' + c) * e := by ring
      _ = d' * e' := by rw [h, h']
  have := Nat.le_of_mul_le_mul_left hkey hd'0
  omega

/-- A stop of the scan gives a factorisation half-sum. -/
lemma hit_mem_sums {N k : ℕ} (h : k ∈ fermatHits N) :
    fermatStart N + k ∈ fermatSums N := by
  obtain ⟨d, e, h1, h2, h3⟩ := hit_factorization h
  exact ⟨d, e, h1, h2, h3⟩

/-- Conversely, a factorisation half-sum at or beyond the starting point is a
stop of the scan. -/
lemma sums_mem_hits {N a : ℕ} (h : a ∈ fermatSums N) (hstart : fermatStart N ≤ a) :
    a - fermatStart N ∈ fermatHits N := by
  obtain ⟨d, e, hde, hle, hsum⟩ := h
  have hd : d ≤ a := by omega
  obtain ⟨c, hc⟩ : ∃ c, a = d + c := ⟨a - d, by omega⟩
  have he : e = d + 2 * c := by omega
  refine ⟨c, ?_⟩
  have hrw : fermatStart N + (a - fermatStart N) = a := by omega
  rw [hrw, hc, ← hde, he]
  ring

/-- Every factorisation half-sum of a non-square lies at or beyond the start of
the scan: this is AM > GM for a pair of distinct factors. -/
lemma start_le_of_mem_sums {N a : ℕ} (hns : ∀ m, m * m ≠ N) (h : a ∈ fermatSums N) :
    fermatStart N ≤ a := by
  obtain ⟨d, e, hde, hle, hsum⟩ := h
  have hlt : d < e := by
    rcases lt_or_eq_of_le hle with h1 | h1
    · exact h1
    · exact absurd (h1 ▸ hde) (hns d)
  obtain ⟨g, hg⟩ : ∃ g, e = d + 2 * g := ⟨(e - d) / 2, by omega⟩
  have hg1 : 1 ≤ g := by omega
  have hadg : a = d + g := by omega
  have hNa : N < a * a := by
    rw [← hde, hg, hadg]; nlinarith [hg1]
  have hsqrt : Nat.sqrt N < a := by
    by_contra hcon
    push_neg at hcon
    have h1 : a * a ≤ Nat.sqrt N * Nat.sqrt N := Nat.mul_le_mul hcon hcon
    have h2 : Nat.sqrt N * Nat.sqrt N ≤ N := Nat.sqrt_le N
    omega
  simpa [fermatStart] using hsqrt

/-- **Fermat's stopping point on an arbitrary odd non-square.**  The scan halts
exactly at the least half-sum of an ordered factorisation of `N`. -/
theorem fermat_cost_eq_sInf_sums {N : ℕ} (hodd : Odd N) (hns : ∀ m, m * m ≠ N) :
    fermatStart N + fermatSteps N = sInf (fermatSums N) := by
  obtain ⟨k, hk⟩ := hodd
  have hmem : (N + 1) / 2 ∈ fermatSums N := ⟨1, N, by ring, by omega, by omega⟩
  have hne : (fermatSums N).Nonempty := ⟨_, hmem⟩
  have hA : sInf (fermatSums N) ∈ fermatSums N := Nat.sInf_mem hne
  have hstartA : fermatStart N ≤ sInf (fermatSums N) := start_le_of_mem_sums hns hA
  have hhit : sInf (fermatSums N) - fermatStart N ∈ fermatHits N := sums_mem_hits hA hstartA
  have h1 : fermatSteps N ≤ sInf (fermatSums N) - fermatStart N := Nat.sInf_le hhit
  have hhne : (fermatHits N).Nonempty := ⟨_, hhit⟩
  have h2 : fermatStart N + fermatSteps N ∈ fermatSums N := hit_mem_sums (Nat.sInf_mem hhne)
  have h3 : sInf (fermatSums N) ≤ fermatStart N + fermatSteps N := Nat.sInf_le h2
  omega

/-- **Divisor-locality.**  For odd non-square `N`, the scan stops at the half-sum
of the factorisation whose small factor `d` is maximal — the divisor nearest
`√N` from below.  Every other divisor of `N` is invisible to the method. -/
theorem fermat_cost_largest_divisor {N d e : ℕ} (hodd : Odd N) (hns : ∀ m, m * m ≠ N)
    (hde : d * e = N) (hle : d ≤ e)
    (hmax : ∀ d' e', d' * e' = N → d' ≤ e' → d' ≤ d) :
    2 * (fermatStart N + fermatSteps N) = d + e := by
  have hN0 : 0 < N := by obtain ⟨k, hk⟩ := hodd; omega
  have hdodd : Odd d ∧ Odd e := Nat.odd_mul.mp (hde ▸ hodd)
  obtain ⟨j, hj⟩ := hdodd.1
  obtain ⟨l, hl⟩ := hdodd.2
  obtain ⟨a0, ha0⟩ : ∃ a0, d + e = 2 * a0 := ⟨j + l + 1, by omega⟩
  have hmem : a0 ∈ fermatSums N := ⟨d, e, hde, hle, ha0⟩
  have hmin : ∀ x ∈ fermatSums N, a0 ≤ x := by
    rintro x ⟨d', e', hde', hle', hsum'⟩
    have hdd : d' ≤ d := hmax d' e' hde' hle'
    have := factor_sum_antitone hN0 hde hde' hdd hle
    omega
  have hInf : sInf (fermatSums N) = a0 :=
    le_antisymm (Nat.sInf_le hmem) (hmin _ (Nat.sInf_mem ⟨_, hmem⟩))
  have := fermat_cost_eq_sInf_sums hodd hns
  omega

/-- **Worst case of the taxonomy.**  On an odd prime `N` Fermat's scan runs all
the way to `(N+1)/2`. -/
theorem fermat_cost_prime {N : ℕ} (hN : N.Prime) (hN2 : N ≠ 2) :
    2 * (fermatStart N + fermatSteps N) = N + 1 := by
  have hN2le := hN.two_le
  have hodd : Odd N := hN.odd_of_ne_two hN2
  have hns : ∀ m, m * m ≠ N := by
    intro m hm
    rcases (Nat.Prime.eq_one_or_self_of_dvd hN m ⟨m, hm.symm⟩) with h1 | h1
    · rw [h1] at hm; omega
    · rw [h1] at hm; nlinarith
  have hmax : ∀ d' e', d' * e' = N → d' ≤ e' → d' ≤ 1 := by
    intro d' e' hd' hle'
    rcases (Nat.Prime.eq_one_or_self_of_dvd hN d' ⟨e', hd'.symm⟩) with h1 | h1
    · omega
    · exfalso
      rw [h1] at hd' hle'
      have he1 : e' = 1 := by nlinarith
      omega
  have := fermat_cost_largest_divisor (d := 1) (e := N) hodd hns (by ring) (by omega) hmax
  omega

/-- The exact iteration count on an odd prime: `N = 2⌊√N⌋ + 2·steps + 1`, i.e.
the cost is `(N - 2⌊√N⌋ - 1)/2 = Θ(N)`.  Compare `minFac`-style trial division,
which certifies primality in `⌊√N⌋` steps: Fermat's method is quadratically
*worse* than trial division on primes, while being unboundedly *better* on
balanced semiprimes (`fermatSteps_eq_zero_of_small_gap`). -/
theorem fermat_cost_prime_exact {N : ℕ} (hN : N.Prime) (hN2 : N ≠ 2) :
    N = 2 * Nat.sqrt N + 2 * fermatSteps N + 1 := by
  have h := fermat_cost_prime hN hN2
  simp only [fermatStart] at h
  omega

/-- Consistency of the two descriptions: on a semiprime `p*q` with odd primes
`p < q`, the divisor-local stopping point of `fermat_cost_largest_divisor` is
the gap-local value `(p+q)/2` of `fermatSteps_add_start`. -/
theorem divisor_local_eq_gap_local {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hpq : p < q) :
    2 * (fermatStart (p * q) + fermatSteps (p * q)) = p + q := by
  have h := fermatSteps_add_start hp hq hp2 hpq
  have hpodd : Odd p := hp.odd_of_ne_two hp2
  have hqodd : Odd q := hq.odd_of_ne_two (by rintro rfl; have := hp.two_le; omega)
  obtain ⟨k, hk⟩ := hpodd
  obtain ⟨l, hl⟩ := hqodd
  omega

end FermatGapLocality