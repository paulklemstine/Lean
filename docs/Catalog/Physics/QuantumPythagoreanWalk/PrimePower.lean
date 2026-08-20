import Physics.QuantumPythagoreanWalk.UniversalCollapse

/-!
# Quantum-Pythagorean-Walk — XIV. Prime powers carry exactly one resonance

`Multiplicity.lean` proves `r(p) = 1` and `ExactMultiplicity.lean` proves `r(pq) = 2`.
This file settles the remaining "diagonal" case, the second next-cycle sub-conjecture of
`FUTURE_DIRECTIONS.md`:

> **`exists_unique_resonant_word_of_prime_pow`.**  For a prime `p ≡ 1 (mod 4)` and any
> `k ≥ 1` there is *exactly one* walk word whose node has hypotenuse `p^k`.

So the multiplicity formula `r(N) = 2^{ω(N) - 1}` (with `ω` counting *distinct* primes)
extends verbatim to non-squarefree moduli, and — since interference needs two distinct
resonant nodes — the mechanism *provably refuses* to "factor" a prime power.  Combined with
`universal_resonance_collapse` this yields a complete dichotomy for every modulus on which
the walk can resonate at all (`prime_power_dichotomy`).

The engine is a *direct* (non-inductive) uniqueness proof for primitive representations of a
prime power, replacing the descent used for semiprimes.  If `A² + B² = A'² + B'² = p^k` with
both pairs primitive, then

`(AB' - A'B)(AB' + A'B) = p^k (B'² - B²)`,

and `p` cannot divide both factors (it divides none of `A, B, A', B'`).  Hence the whole
`p^k` divides one factor, which the Brahmagupta identity
`(AA' ∓ BB')² + (AB' ± A'B)² = p^{2k}` then forces to be `0` or `±p^k`; each alternative
pins `{A², B²} = {A'², B'²}` (`prime_pow_rep_unique`).
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### Two divisibility utilities -/

/-- Mutual divisibility in `ℤ` equalises squares. -/
theorem sq_eq_of_dvd_dvd {a b : ℤ} (h₁ : a ∣ b) (h₂ : b ∣ a) : a ^ 2 = b ^ 2 := by
  have habs : a.natAbs = b.natAbs :=
    Nat.dvd_antisymm (Int.natAbs_dvd_natAbs.mpr h₁) (Int.natAbs_dvd_natAbs.mpr h₂)
  rcases Int.natAbs_eq_natAbs_iff.mp habs with h | h
  · rw [h]
  · rw [h]; ring

/-- Positive integers with equal squares are equal. -/
theorem eq_of_sq_eq_of_pos {a b : ℤ} (ha : 0 < a) (hb : 0 < b) (h : a ^ 2 = b ^ 2) :
    a = b := by
  have h0 : (a - b) * (a + b) = 0 := by linear_combination h
  rcases mul_eq_zero.mp h0 with h' | h' <;> omega

/-- A prime does not divide either coordinate of a primitive representation of `p^k`,
`k ≥ 1`. -/
theorem not_dvd_of_primitive_rep_prime_pow {p : ℕ} (hp : p.Prime) {A B : ℤ} {k : ℕ}
    (hk : 1 ≤ k) (hsum : A ^ 2 + B ^ 2 = (p : ℤ) ^ k) (hcop : IsCoprime A B) :
    ¬ ((p : ℤ) ∣ A) ∧ ¬ ((p : ℤ) ∣ B) := by
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hpk : (p : ℤ) ∣ (p : ℤ) ^ k := dvd_pow_self _ (by omega)
  constructor
  · intro hdA
    have hdB : (p : ℤ) ∣ B := by
      refine hpZ.dvd_of_dvd_pow (n := 2) ?_
      have e : B ^ 2 = (p : ℤ) ^ k - A ^ 2 := by linarith
      rw [e]
      exact dvd_sub hpk (Dvd.dvd.pow hdA two_ne_zero)
    exact hpZ.not_unit (hcop.isUnit_of_dvd' hdA hdB)
  · intro hdB
    have hdA : (p : ℤ) ∣ A := by
      refine hpZ.dvd_of_dvd_pow (n := 2) ?_
      have e : A ^ 2 = (p : ℤ) ^ k - B ^ 2 := by linarith
      rw [e]
      exact dvd_sub hpk (Dvd.dvd.pow hdB two_ne_zero)
    exact hpZ.not_unit (hcop.isUnit_of_dvd' hdA hdB)

/-! ### Uniqueness of the primitive representation of a prime power -/

/-- The key step: if the whole modulus divides one Euler cross term, the two representations
agree up to order and sign. -/
theorem rep_eq_of_dvd_cross {M A B A' B' : ℤ} (hM : 0 < M)
    (hsum : A ^ 2 + B ^ 2 = M) (hsum' : A' ^ 2 + B' ^ 2 = M)
    (hcop : IsCoprime A B) (hcop' : IsCoprime A' B')
    (hdvd : M ∣ A * B' - A' * B) :
    (A ^ 2 = A' ^ 2 ∧ B ^ 2 = B' ^ 2) ∨ (A ^ 2 = B' ^ 2 ∧ B ^ 2 = A' ^ 2) := by
  obtain ⟨t, ht⟩ := hdvd
  have hid : (A * A' + B * B') ^ 2 + (A * B' - A' * B) ^ 2 = M ^ 2 := by
    have e : (A * A' + B * B') ^ 2 + (A * B' - A' * B) ^ 2
        = (A ^ 2 + B ^ 2) * (A' ^ 2 + B' ^ 2) := by ring
    rw [e, hsum, hsum']; ring
  have hle : (M * t) ^ 2 ≤ M ^ 2 := by
    rw [← ht]
    nlinarith [sq_nonneg (A * A' + B * B')]
  have ht2 : t ^ 2 ≤ 1 := by nlinarith [sq_nonneg t]
  have hcase : t = 0 ∨ t ^ 2 = 1 := by
    rcases lt_trichotomy t 0 with h | h | h
    · right; nlinarith
    · left; exact h
    · right; nlinarith
  rcases hcase with h0 | h1
  · -- the cross term vanishes: the two pairs are proportional
    have hcross : A * B' = A' * B := by rw [h0, mul_zero] at ht; linarith
    left
    have hA : A ∣ A' := hcop.dvd_of_dvd_mul_right ⟨B', hcross.symm⟩
    have hA' : A' ∣ A := hcop'.dvd_of_dvd_mul_right ⟨B, hcross⟩
    have hAsq : A ^ 2 = A' ^ 2 := sq_eq_of_dvd_dvd hA hA'
    exact ⟨hAsq, by linarith⟩
  · -- the cross term is maximal: the diagonal term vanishes
    have hmax : (A * B' - A' * B) ^ 2 = M ^ 2 := by
      rw [ht, mul_pow, h1, mul_one]
    have hzero : A * A' + B * B' = 0 := by
      have hz : (A * A' + B * B') ^ 2 = 0 := by linarith
      exact pow_eq_zero_iff (n := 2) two_ne_zero |>.mp hz
    right
    have hA : A ∣ B' := hcop.dvd_of_dvd_mul_left ⟨-A', by linear_combination hzero⟩
    have hB' : B' ∣ A := hcop'.symm.dvd_of_dvd_mul_left ⟨-B, by linear_combination hzero⟩
    have hAsq : A ^ 2 = B' ^ 2 := sq_eq_of_dvd_dvd hA hB'
    exact ⟨hAsq, by linarith⟩

/-- **Uniqueness of the primitive representation of a prime power.**  Two primitive
representations of `p^k` (`p` an odd prime, `k ≥ 1`) coincide up to order and sign. -/
theorem prime_pow_rep_unique {p : ℕ} (hp : p.Prime) (hodd : p % 2 = 1) {k : ℕ} (hk : 1 ≤ k)
    {A B A' B' : ℤ} (hsum : A ^ 2 + B ^ 2 = (p : ℤ) ^ k)
    (hsum' : A' ^ 2 + B' ^ 2 = (p : ℤ) ^ k)
    (hcop : IsCoprime A B) (hcop' : IsCoprime A' B') :
    (A ^ 2 = A' ^ 2 ∧ B ^ 2 = B' ^ 2) ∨ (A ^ 2 = B' ^ 2 ∧ B ^ 2 = A' ^ 2) := by
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hppos : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  have hMpos : (0 : ℤ) < (p : ℤ) ^ k := pow_pos hppos k
  obtain ⟨hpA, hpB⟩ := not_dvd_of_primitive_rep_prime_pow hp hk hsum hcop
  obtain ⟨hpA', hpB'⟩ := not_dvd_of_primitive_rep_prime_pow hp hk hsum' hcop'
  have hp2 : ¬ ((p : ℤ) ∣ 2) := by
    intro hd
    have hle : (p : ℤ) ≤ 2 := Int.le_of_dvd (by norm_num) hd
    have h2 : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
    have : (p : ℤ) = 2 := by omega
    have : p = 2 := by exact_mod_cast this
    omega
  -- the modulus divides the product of the two cross terms
  have hprod : (p : ℤ) ^ k ∣ (A * B' - A' * B) * (A * B' + A' * B) :=
    ⟨B' ^ 2 - B ^ 2, by linear_combination (B' ^ 2) * hsum - (B ^ 2) * hsum'⟩
  -- but not both of them, since it divides none of the four coordinates
  have hnotboth : ¬ ((p : ℤ) ∣ A * B' - A' * B ∧ (p : ℤ) ∣ A * B' + A' * B) := by
    rintro ⟨h₁, h₂⟩
    have hsum2 : (p : ℤ) ∣ 2 * (A * B') := by
      have e : 2 * (A * B') = (A * B' - A' * B) + (A * B' + A' * B) := by ring
      rw [e]; exact dvd_add h₁ h₂
    rcases hpZ.dvd_mul.mp hsum2 with h | h
    · exact hp2 h
    · rcases hpZ.dvd_mul.mp h with h' | h'
      · exact hpA h'
      · exact hpB' h'
  -- hence the whole prime power divides one of the two cross terms
  have hone : (p : ℤ) ^ k ∣ A * B' - A' * B ∨ (p : ℤ) ^ k ∣ A * B' + A' * B := by
    by_cases h₁ : (p : ℤ) ∣ A * B' - A' * B
    · have h₂ : ¬ ((p : ℤ) ∣ A * B' + A' * B) := fun h => hnotboth ⟨h₁, h⟩
      have hcp : IsCoprime ((p : ℤ) ^ k) (A * B' + A' * B) :=
        IsCoprime.pow_left ((hpZ.coprime_iff_not_dvd).mpr h₂)
      exact Or.inl (hcp.dvd_of_dvd_mul_right hprod)
    · have hcp : IsCoprime ((p : ℤ) ^ k) (A * B' - A' * B) :=
        IsCoprime.pow_left ((hpZ.coprime_iff_not_dvd).mpr h₁)
      exact Or.inr (hcp.dvd_of_dvd_mul_left hprod)
  rcases hone with h | h
  · exact rep_eq_of_dvd_cross hMpos hsum hsum' hcop hcop' h
  · -- the second case is the first one for the conjugate representation `(A', -B')`
    have h' : (p : ℤ) ^ k ∣ A * (-B') - A' * B := by
      have e : A * (-B') - A' * B = -(A * B' + A' * B) := by ring
      rw [e]
      exact dvd_neg.mpr h
    have hsum'' : A' ^ 2 + (-B') ^ 2 = (p : ℤ) ^ k := by rw [neg_pow]; simpa using hsum'
    have hcop'' : IsCoprime A' (-B') := hcop'.neg_right
    rcases rep_eq_of_dvd_cross hMpos hsum hsum'' hcop hcop'' h' with ⟨e₁, e₂⟩ | ⟨e₁, e₂⟩
    · left
      constructor
      · exact e₁
      · rw [e₂]; ring
    · right
      constructor
      · rw [e₁]; ring
      · exact e₂

/-! ### Exactly one resonant word for a prime power -/

/-- Two nodes with the same prime-power hypotenuse coincide. -/
theorem node_unique_of_prime_pow_hyp {p : ℕ} (hp : p.Prime) (hoddp : p % 2 = 1) {k : ℕ}
    (hk : 1 ≤ k) {t₁ t₂ : Node}
    (h₁ : t₁.IsPPT) (o₁ : t₁.a % 2 = 1) (c₁ : t₁.c = (p : ℤ) ^ k)
    (h₂ : t₂.IsPPT) (o₂ : t₂.a % 2 = 1) (c₂ : t₂.c = (p : ℤ) ^ k) : t₁ = t₂ := by
  obtain ⟨m₁, n₁, hn₁, hnm₁, hc₁, he₁⟩ := exists_repNode_of_isPPT h₁ o₁
  obtain ⟨m₂, n₂, hn₂, hnm₂, hc₂, he₂⟩ := exists_repNode_of_isPPT h₂ o₂
  have hr₁ : m₁ ^ 2 + n₁ ^ 2 = (p : ℤ) ^ k := by rw [← c₁, he₁]; simp [repNode]
  have hr₂ : m₂ ^ 2 + n₂ ^ 2 = (p : ℤ) ^ k := by rw [← c₂, he₂]; simp [repNode]
  rcases prime_pow_rep_unique hp hoddp hk hr₁ hr₂ hc₁ hc₂ with ⟨e₁, e₂⟩ | ⟨e₁, e₂⟩
  · have hm : m₁ = m₂ := eq_of_sq_eq_of_pos (by omega) (by omega) e₁
    have hn : n₁ = n₂ := eq_of_sq_eq_of_pos hn₁ hn₂ e₂
    rw [he₁, he₂, hm, hn]
  · -- `m₁ = n₂ < m₂ = n₁ < m₁` is impossible
    exfalso
    have hm : m₁ = n₂ := eq_of_sq_eq_of_pos (by omega) hn₂ e₁
    have hn : n₁ = m₂ := eq_of_sq_eq_of_pos hn₁ (by omega) e₂
    omega

/-- **A prime power carries exactly one resonance.**  For `p ≡ 1 (mod 4)` prime and `k ≥ 1`
there is a unique walk word with hypotenuse `p^k`; in particular no interference pair
exists, and the mechanism cannot split a prime power. -/
theorem exists_unique_resonant_word_of_prime_pow {p : ℕ} (hp : p.Prime) (hp4 : p % 4 = 1)
    {k : ℕ} (hk : 1 ≤ k) :
    ∃! w : List (Fin 3), (walk w).c = (p : ℤ) ^ k := by
  have hoddp : p % 2 = 1 := by omega
  obtain ⟨A, B, hA, hB, hsum, hcop⟩ := primitive_rep_prime_pow hp hp4 k hk
  have hoddsum : (A ^ 2 + B ^ 2) % 2 = 1 := by
    rw [hsum]
    have hodd : Odd ((p : ℤ) ^ k) := by
      refine Odd.pow ?_
      have : Odd p := Nat.odd_iff.mpr hoddp
      exact_mod_cast Int.odd_coe_nat p |>.mpr this
    obtain ⟨c, hc⟩ := hodd
    omega
  obtain ⟨t, ht, htodd, htc, -, -⟩ := node_of_primitive_rep' hA (ne_of_gt hB) hcop hoddsum
  obtain ⟨w, hw⟩ := exists_word_of_isPPT t ht htodd
  refine ⟨w, ?_, ?_⟩
  · show (walk w).c = (p : ℤ) ^ k
    rw [hw, htc, hsum]
  · intro w' hw'
    refine walk_injective ?_
    rw [hw]
    exact node_unique_of_prime_pow_hyp hp hoddp hk (walk_isPPT w') (walk_odd_a w') hw'
      ht htodd (by rw [htc, hsum])

/-- No interference pair exists for a prime power: any two resonant words coincide. -/
theorem no_resonant_pair_of_prime_pow {p : ℕ} (hp : p.Prime) (hp4 : p % 4 = 1) {k : ℕ}
    (hk : 1 ≤ k) {w₁ w₂ : List (Fin 3)} (h₁ : (walk w₁).c = (p : ℤ) ^ k)
    (h₂ : (walk w₂).c = (p : ℤ) ^ k) : w₁ = w₂ := by
  obtain ⟨w, -, huniq⟩ := exists_unique_resonant_word_of_prime_pow hp hp4 hk
  rw [huniq w₁ h₁, huniq w₂ h₂]

/-! ### The complete dichotomy -/

/-- Every `N > 1` either has two distinct prime factors or is a prime power. -/
theorem two_prime_factors_or_prime_pow {N : ℕ} (hN : 1 < N) :
    (∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ p ∣ N ∧ q ∣ N) ∨
      (∃ p k : ℕ, p.Prime ∧ 1 ≤ k ∧ N = p ^ k) := by
  have hN0 : N ≠ 0 := by omega
  set p := N.minFac with hpdef
  have hp : p.Prime := Nat.minFac_prime (by omega)
  have hpN : p ∣ N := Nat.minFac_dvd N
  by_cases hsplit : ∃ q : ℕ, q.Prime ∧ q ∣ N ∧ q ≠ p
  · obtain ⟨q, hq, hqN, hqp⟩ := hsplit
    exact Or.inl ⟨p, q, hp, hq, Ne.symm hqp, hpN, hqN⟩
  · -- no second prime factor: `N` is a power of `p`
    push_neg at hsplit
    right
    set k := N.factorization p with hkdef
    have hk1 : 1 ≤ k := hp.factorization_pos_of_dvd hN0 hpN
    have hcompl : N / p ^ k = 1 := by
      by_contra hne
      have hpos : 0 < N / p ^ k := Nat.ordCompl_pos p hN0
      obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd (n := N / p ^ k) (by omega)
      have hrN : r ∣ N := hrd.trans ⟨p ^ k, by
        rw [mul_comm]; exact (Nat.ordProj_mul_ordCompl_eq_self N p).symm⟩
      have hrp : r = p := hsplit r hr hrN
      have hcopr : Nat.Coprime p (N / p ^ k) := Nat.coprime_ordCompl hp hN0
      rw [hrp] at hrd
      have hdvd1 : p ∣ 1 := by
        have hg := Nat.dvd_gcd (dvd_refl p) hrd
        rwa [hcopr] at hg
      exact hp.one_lt.ne' (Nat.dvd_one.mp hdvd1)
    refine ⟨p, k, hp, hk1, ?_⟩
    have := Nat.ordProj_mul_ordCompl_eq_self N p
    rw [hcompl, mul_one] at this
    exact this.symm

/-- **Dichotomy for every resonant modulus.**  Let `N > 1` be odd with all prime factors
`≡ 1 (mod 4)` — by `resonance_exists_iff_isSquare_neg_one` exactly the odd moduli on which
the walk resonates.  Then either

* `N = p^k` is a prime power, and the resonance is *unique*, so no interference pair exists
  (and indeed there is nothing to factor); or
* `N` has two distinct prime factors, and some resonant pair collapses onto an exact
  nontrivial proper divisor of `N`.

The arithmetic therefore never fails; only the search space (`hilbert_dimension_lower_bound`)
stands in the way. -/
theorem prime_power_dichotomy {N : ℕ} (hN : 1 < N) (hodd : N % 2 = 1)
    (hall : ∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 1) :
    (∃! w : List (Fin 3), (walk w).c = (N : ℤ)) ∨
      (∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
        (walk w₁).c = (N : ℤ) ∧ (walk w₂).c = (N : ℤ) ∧
        1 < (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) : ℤ) ∧
        (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) : ℤ)
          < (N : ℤ) ∧
        (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) : ℤ)
          ∣ (N : ℤ)) := by
  rcases two_prime_factors_or_prime_pow hN with ⟨p, q, hp, hq, hpq, hpN, hqN⟩ | ⟨p, k, hp, hk, hNe⟩
  · exact Or.inr (universal_resonance_collapse hodd hall hp hq hpq hpN hqN)
  · left
    have hpN : p ∣ N := ⟨p ^ (k - 1), by rw [hNe]; rw [← pow_succ']; congr 1; omega⟩
    have hNpk : (N : ℤ) = (p : ℤ) ^ k := by
      rw [hNe]; push_cast; ring
    rw [hNpk]
    exact exists_unique_resonant_word_of_prime_pow hp (hall p hp hpN) hk

/-- **Unique resonance characterises prime powers.**  Among the moduli on which the walk
resonates, the resonant word is unique exactly for the prime powers; every other modulus
carries an interference pair (and hence, by `universal_resonance_collapse`, a factor). -/
theorem unique_resonance_iff_prime_pow {N : ℕ} (hN : 1 < N) (hodd : N % 2 = 1)
    (hall : ∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 1) :
    (∃! w : List (Fin 3), (walk w).c = (N : ℤ)) ↔ ∃ p k : ℕ, p.Prime ∧ 1 ≤ k ∧ N = p ^ k := by
  constructor
  · intro huniq
    rcases two_prime_factors_or_prime_pow hN with
      ⟨p, q, hp, hq, hpq, hpN, hqN⟩ | hpow
    · exfalso
      obtain ⟨w₁, w₂, hne, hc₁, hc₂, -, -, -⟩ :=
        universal_resonance_collapse hodd hall hp hq hpq hpN hqN
      obtain ⟨w, -, hw⟩ := huniq
      exact hne ((hw w₁ hc₁).trans (hw w₂ hc₂).symm)
    · exact hpow
  · rintro ⟨p, k, hp, hk, rfl⟩
    have hpN : p ∣ p ^ k := ⟨p ^ (k - 1), by rw [← pow_succ']; congr 1; omega⟩
    have hNpk : ((p ^ k : ℕ) : ℤ) = (p : ℤ) ^ k := by push_cast; ring
    rw [hNpk]
    exact exists_unique_resonant_word_of_prime_pow hp (hall p hp hpN) hk

end QuantumPythagoreanWalk