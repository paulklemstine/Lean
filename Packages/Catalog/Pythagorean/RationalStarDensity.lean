import Pythagorean.RationalStarRealization

/-!
# How densely a ray of a rational star is populated: a totient law

`Pythagorean.RationalStarRealization` shows that the ray of charge `k` at the rational
ideal point `p/q` is parametrised unimodularly by an integer `s`, through
`starSeed p q k a b s = (k b + s q, k a + s p)` with `p b - q a = 1`, and that the node
attached to `s` is a Euclid seed exactly when the arithmetic conditions on `(k, s)` hold.
Here we count.

## Main results

* `starSeed_isSeed_iff_coprime` : for both `p` and `q` odd (the case of the stars at
  `1/3`, `1/5`, `3/5`, … — the visible fans at `0.33` and `0.2`) and `k` odd, and for a
  parameter `s` past an explicit bound, the parametrised node is a Euclid seed **iff**
  `gcd(|k|, s) = 1`. The parity condition, which is what quantises the charges, is
  automatically satisfied.
* `window_coprime_card` : in any window of `2K` consecutive parameters there are exactly
  `2 φ(K)` integers coprime to `K`.
* `window_coprime_odd_card`, `window_coprime_even_card` : the split of that window count
  into the two parity classes, `φ(2K)` and `2φ(K) - φ(2K)`; for odd `K` both classes carry
  exactly `φ(K)` parameters.
* `spoke_window_card` : **the totient density law for a ray.** For `p, q` odd and `k` odd,
  the number of Berggren nodes on the ray of charge `k` at `p/q` whose parameter lies in a
  window of length `2|k|` beyond the bound is exactly `2 φ(|k|) = 2 φ(2|k|)`.
  A ray of large charge is therefore *thin* in the arithmetic-density sense
  (`2φ(K)` out of `2K` parameters) even though it is always infinite.

## Lab notes

Counting seeds with `m ≤ 20000` on the ray of charge `k` at `p/q`, normalised by the
number `M/q` of admissible `m`:

| `p/q` | `k` | count | count/(M/q) | `φ(K)/K` |
|---|---|---|---|---|
| `1/3` | `1` | 6666 | 0.9999 | 1.0 |
| `1/3` | `3` | 4444 | 0.6666 | 0.6667 |
| `1/5` | `5` | 3200 | 0.8000 | 0.8 |
| `1/2` | `3` | 3333 | 0.3333 | 0.6667 |
| `1/2` | `6` | 3333 | 0.3333 | 0.3333 |

The `p+q` even rows realise the density `φ(K)/K` of the theorem below; the `p+q` odd rows
lose a further factor `2` exactly when `K` is odd, which is the parity split
`window_coprime_odd_card`.
-/

namespace BerggrenRationalStar

open BerggrenHypercycleStars Finset

/-! ## Part 1. Coprimality is the only obstruction on a ray at an odd/odd rational -/

/-- `IsSeed` is a decidable predicate. -/
instance instDecidableIsSeed (m n : ℕ) : Decidable (IsSeed m n) :=
  decidable_of_iff (0 < n ∧ n < m ∧ Nat.Coprime m n ∧ (m + n) % 2 = 1)
    ⟨fun h => ⟨h.1, h.2.1, h.2.2.1, h.2.2.2⟩, fun h => ⟨h.pos, h.lt, h.cop, h.parity⟩⟩

/-- The inverse unimodular substitution: the charge `k` and the parameter `s` are integral
combinations of the two node coordinates, so a coprime node has coprime `(k, s)`. -/
theorem isCoprime_of_starSeed {p q a b : ℤ} {k s : ℤ}
    (h : IsCoprime (starSeed p q k a b s).1 (starSeed p q k a b s).2) : IsCoprime k s := by
  obtain ⟨u, v, huv⟩ := h
  refine ⟨u * b + v * a, u * q + v * p, ?_⟩
  simp only [starSeed] at huv
  linear_combination huv

/-- The explicit bound past which the parametrised node has `0 < n < m`. -/
def paramBound (k a b : ℤ) : ℕ :=
  (k * a).natAbs + (k * b).natAbs + (k * (b - a)).natAbs + 1

/-- Past the bound, the parametrised pair is a genuine ordered pair `0 < n < m`. -/
theorem starSeed_pos {p q : ℕ} (hp : 0 < p) (hpq : p < q) (k a b : ℤ) {s : ℕ}
    (hs : paramBound k a b ≤ s) :
    0 < (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).2 ∧
      (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).2
        < (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).1 := by
  have hp1 : (1 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp
  have hqp : (p : ℤ) + 1 ≤ (q : ℤ) := by exact_mod_cast hpq
  have hsZ : ((paramBound k a b : ℕ) : ℤ) ≤ (s : ℤ) := by exact_mod_cast hs
  rw [paramBound] at hsZ
  push_cast at hsZ
  have habs1 : -|k * a| ≤ k * a := neg_abs_le _
  have habs2 : (0 : ℤ) ≤ |k * b| := abs_nonneg _
  have habs3 : -|k * (b - a)| ≤ k * (b - a) := neg_abs_le _
  have habs0 : (0 : ℤ) ≤ |k * a| := abs_nonneg _
  have habs4 : (0 : ℤ) ≤ |k * (b - a)| := abs_nonneg _
  have hs0 : (0 : ℤ) ≤ (s : ℤ) := Int.natCast_nonneg s
  constructor
  · have hsp : (s : ℤ) ≤ (s : ℤ) * (p : ℤ) := by nlinarith
    simp only [starSeed]
    linarith
  · have hsq : (s : ℤ) ≤ (s : ℤ) * ((q : ℤ) - (p : ℤ)) := by nlinarith
    simp only [starSeed]
    linarith

/-- **The ray at an odd/odd rational is exactly the coprime set.** For `p, q` both odd and
`k` odd, and for a parameter `s` past the bound, the parametrised node is a Euclid seed if
and only if `s` is coprime to `|k|`: the parity condition holds automatically, so the ray is
populated as densely as the coprimality condition allows. -/
theorem starSeed_isSeed_iff_coprime {p q : ℕ} (hp : 0 < p) (hpq : p < q)
    (hpodd : p % 2 = 1) (hqodd : q % 2 = 1) {k a b : ℤ} (hab : (p : ℤ) * b - (q : ℤ) * a = 1)
    (hkodd : Odd k) {s : ℕ} (hs : paramBound k a b ≤ s) :
    IsSeed (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).1.toNat
        (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).2.toNat
      ↔ Nat.Coprime k.natAbs s := by
  obtain ⟨hnpos, hnm⟩ := starSeed_pos hp hpq k a b hs
  set m : ℤ := (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).1 with hm
  set n : ℤ := (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).2 with hn
  -- parity is automatic here
  have hsum : m + n = k * (a + b) + (s : ℤ) * ((p : ℤ) + q) := by
    simp only [hm, hn, starSeed]; ring
  have hparity : (m + n) % 2 = 1 := by
    obtain ⟨k', hk'⟩ := hkodd
    obtain ⟨p', hp'⟩ : ∃ p' : ℤ, (p : ℤ) = 2 * p' + 1 := ⟨(p : ℤ) / 2, by omega⟩
    obtain ⟨q', hq'⟩ : ∃ q' : ℤ, (q : ℤ) = 2 * q' + 1 := ⟨(q : ℤ) / 2, by omega⟩
    have habodd : (a + b) % 2 = 1 := by
      have hexp : (p : ℤ) * b - (q : ℤ) * a = 2 * (p' * b - q' * a) + (b - a) := by
        rw [hp', hq']; ring
      rw [hexp] at hab
      omega
    obtain ⟨w, hw⟩ : ∃ w : ℤ, a + b = 2 * w + 1 := ⟨(a + b) / 2, by omega⟩
    have hexp2 : m + n = 2 * ((2 * k' + 1) * w + k' + (p' + q' + 1) * (s : ℤ)) + 1 := by
      rw [hsum, hk', hw, hp', hq']; ring
    omega
  constructor
  · intro hseed
    -- from the seed to coprimality of `(k, s)`
    have hcopmn : IsCoprime m n := by
      have h1 : Int.gcd m n = 1 := by
        have := hseed.cop
        have e1 : m.toNat = m.natAbs := by omega
        have e2 : n.toNat = n.natAbs := by omega
        rw [e1, e2] at this
        exact this
      exact Int.isCoprime_iff_gcd_eq_one.mpr h1
    have hks : IsCoprime k (s : ℤ) := isCoprime_of_starSeed (by rw [← hm, ← hn] at *; exact hcopmn)
    have : Int.gcd k (s : ℤ) = 1 := Int.isCoprime_iff_gcd_eq_one.mp hks
    simpa [Int.gcd, Nat.Coprime] using this
  · intro hcop
    have hks : IsCoprime k (s : ℤ) := by
      refine Int.isCoprime_iff_gcd_eq_one.mpr ?_
      simpa [Int.gcd, Nat.Coprime] using hcop
    have hcopmn : IsCoprime m n := by
      have := isCoprime_starSeed (p := (p : ℤ)) (q := (q : ℤ)) hab hks
      rw [← hm, ← hn] at this
      exact this
    exact isSeed_toNat hnpos hnm hcopmn hparity

/-! ## Part 2. Counting parameters in a window -/

/-- A window of `2K` consecutive integers contains exactly `2 φ(K)` integers coprime
to `K`. -/
theorem window_coprime_card (K N : ℕ) :
    #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s} = 2 * Nat.totient K := by
  have hsplit : Ico N (N + 2 * K) = Ico N (N + K) ∪ Ico (N + K) (N + K + K) := by
    rw [Finset.Ico_union_Ico_eq_Ico (by omega) (by omega)]
    congr 1
    omega
  have hdisj : Disjoint (Ico N (N + K)) (Ico (N + K) (N + K + K)) :=
    Finset.Ico_disjoint_Ico_consecutive N (N + K) (N + K + K)
  rw [hsplit, Finset.filter_union, Finset.card_union_of_disjoint (by
    exact Finset.disjoint_filter_filter hdisj),
    Nat.filter_coprime_Ico_eq_totient K N, Nat.filter_coprime_Ico_eq_totient K (N + K)]
  ring

/-- Coprimality to `2K` splits as coprimality to `K` together with oddness. -/
theorem coprime_two_mul_iff (K s : ℕ) :
    Nat.Coprime (2 * K) s ↔ (Nat.Coprime K s ∧ s % 2 = 1) := by
  constructor
  · intro h
    refine ⟨Nat.Coprime.coprime_dvd_left ⟨2, by ring⟩ h, ?_⟩
    have h2 : Nat.Coprime 2 s := Nat.Coprime.coprime_dvd_left ⟨K, rfl⟩ h
    have := (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mp h2
    omega
  · rintro ⟨hK, hodd⟩
    have h2 : Nat.Coprime 2 s := (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (by omega)
    exact Nat.Coprime.mul_left h2 hK

/-- In a window of `2K` consecutive integers there are exactly `φ(2K)` odd integers coprime
to `K`. -/
theorem window_coprime_odd_card (K N : ℕ) :
    #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s ∧ s % 2 = 1} = Nat.totient (2 * K) := by
  have h : ∀ s, (Nat.Coprime K s ∧ s % 2 = 1) ↔ Nat.Coprime (2 * K) s :=
    fun s => (coprime_two_mul_iff K s).symm
  simp only [h]
  exact Nat.filter_coprime_Ico_eq_totient (2 * K) N

/-- The complementary parity class: in a window of `2K` consecutive integers there are
`2 φ(K) - φ(2K)` even integers coprime to `K`. For odd `K` this is again `φ(K)`, so the two
parity classes of a ray are equally populated; for even `K` it is `0`. -/
theorem window_coprime_even_card (K N : ℕ) :
    #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s ∧ s % 2 = 0}
      = 2 * Nat.totient K - Nat.totient (2 * K) := by
  have hsplit : #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s ∧ s % 2 = 1}
      + #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s ∧ s % 2 = 0}
      = #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s} := by
    rw [← Finset.card_union_of_disjoint]
    · congr 1
      ext s
      simp only [Finset.mem_union, Finset.mem_filter]
      constructor
      · rintro (⟨h1, h2, _⟩ | ⟨h1, h2, _⟩) <;> exact ⟨h1, h2⟩
      · rintro ⟨h1, h2⟩
        rcases Nat.even_or_odd s with h | h
        · exact Or.inr ⟨h1, h2, Nat.even_iff.mp h⟩
        · exact Or.inl ⟨h1, h2, Nat.odd_iff.mp h⟩
    · refine Finset.disjoint_left.mpr ?_
      rintro s hs1 hs2
      simp only [Finset.mem_filter] at hs1 hs2
      omega
  rw [window_coprime_card, window_coprime_odd_card] at hsplit
  omega

/-- For odd `K` the two parity classes are equally populated, with `φ(K)` parameters
each. -/
theorem window_coprime_parity_balanced {K : ℕ} (hK : K % 2 = 1) (N : ℕ) :
    #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s ∧ s % 2 = 1} = Nat.totient K ∧
      #{s ∈ Ico N (N + 2 * K) | Nat.Coprime K s ∧ s % 2 = 0} = Nat.totient K := by
  have htot : Nat.totient (2 * K) = Nat.totient K := by
    have h2K : Nat.Coprime 2 K :=
      (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (by omega : ¬ 2 ∣ K)
    rw [Nat.totient_mul h2K]
    simp
  refine ⟨by rw [window_coprime_odd_card, htot], ?_⟩
  rw [window_coprime_even_card, htot]
  omega

/-! ## Part 3. The totient density law for a ray -/

/-- **Totient density law.** Let `p/q` be an interior rational with `p` and `q` both odd
(the stars at `1/3`, `1/5`, `3/5`, …) and let `k` be an odd charge, `K = |k|`. Then in any
window of `2K` consecutive parameters past the bound, the ray of charge `k` at `p/q`
carries exactly `2 φ(K)` nodes of the Berggren tree. The ray is thus infinite but of
arithmetic density `φ(K)/K`: rays of highly composite charge are visibly sparser. -/
theorem spoke_window_card {p q : ℕ} (hp : 0 < p) (hpq : p < q)
    (hpodd : p % 2 = 1) (hqodd : q % 2 = 1) {k a b : ℤ}
    (hab : (p : ℤ) * b - (q : ℤ) * a = 1) (hkodd : Odd k) {N : ℕ}
    (hN : paramBound k a b ≤ N) :
    ((Ico N (N + 2 * k.natAbs)).filter (fun s : ℕ =>
        IsSeed (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).1.toNat
          (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).2.toNat)).card
      = 2 * Nat.totient k.natAbs := by
  have hcongr : (Ico N (N + 2 * k.natAbs)).filter (fun s : ℕ =>
        IsSeed (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).1.toNat
          (starSeed (p : ℤ) (q : ℤ) k a b (s : ℤ)).2.toNat)
      = (Ico N (N + 2 * k.natAbs)).filter (fun s : ℕ => Nat.Coprime k.natAbs s) := by
    refine Finset.filter_congr ?_
    intro s hs
    simp only [Finset.mem_Ico] at hs
    exact ⟨fun h => (starSeed_isSeed_iff_coprime hp hpq hpodd hqodd hab hkodd
        (by omega : paramBound k a b ≤ s)).mp h,
      fun h => (starSeed_isSeed_iff_coprime hp hpq hpodd hqodd hab hkodd
        (by omega : paramBound k a b ≤ s)).mpr h⟩
  rw [hcongr]
  exact window_coprime_card k.natAbs N

/-- Specialisation to the star at `1/3` — the fan visible at `0.33`. Its ray of charge `k`
carries `2 φ(|k|)` nodes per period of `2|k|` parameters. -/
theorem spoke_window_card_one_third {k a b : ℤ} (hab : (1 : ℤ) * b - (3 : ℤ) * a = 1)
    (hkodd : Odd k) {N : ℕ} (hN : paramBound k a b ≤ N) :
    ((Ico N (N + 2 * k.natAbs)).filter (fun s : ℕ =>
        IsSeed (starSeed (1 : ℤ) (3 : ℤ) k a b (s : ℤ)).1.toNat
          (starSeed (1 : ℤ) (3 : ℤ) k a b (s : ℤ)).2.toNat)).card
      = 2 * Nat.totient k.natAbs := by
  have h := spoke_window_card (p := 1) (q := 3) (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by simpa using hab) hkodd (N := N) hN
  simpa using h

end BerggrenRationalStar