import Physics.QuantumPythagoreanWalk.GeneralCollapse

/-!
# Quantum-Pythagorean-Walk — XII. Universal collapse: every non-prime-power resonator factors

`GeneralCollapse.lean` proves an exact collapse for a *given* coprime splitting `N = m·n`
whose two factors are each primitively represented as a sum of two squares
(`coprime_split_resonance_collapse`), and instantiates it for `ω(N) = 3`.  Two things were
still missing before the statement became unconditional:

* a supply of primitive representations for **prime powers** `p^k` (`primitive_rep_prime_pow`);
* the resulting statement for an arbitrary modulus, obtained by pushing
  `primitive_rep_mul` through a full factorisation
  (`primitive_rep_of_primes_one_mod_four`).

The engine of the first item is the Gaussian recursion `z ↦ (x ± i y)·z`: exactly one of the
two Brahmagupta compositions of a primitive representation of `p^k` with `p = x² + y²` is
again primitive (the other one is divisible by `p`), and which one it is can be decided by
the elementary "both would force `p ∣ 2xA`" argument in `dvd_of_not_isCoprime_brahmagupta`.

Putting the two together gives the headline of this file:

> **`universal_resonance_collapse`.**  Let `N` be odd with every prime factor `≡ 1 (mod 4)`,
> and suppose `N` is *not* a prime power (two distinct primes divide it).  Then the Berggren
> tree contains two distinct words of hypotenuse exactly `N` whose interference gcd is an
> **exact, nontrivial, proper divisor of `N`**.

This removes every remaining hypothesis of the `ω = 2` and `ω = 3` theorems: the resonance
mechanism factors *all* of the moduli on which it can resonate at all, and by
`resonance_exists_iff_isSquare_neg_one` the excluded moduli (prime powers) are exactly the
ones the mechanism must refuse, since a prime power has only one resonant word up to the
interference-free case.  The barrier of `Barrier.lean` is therefore the *only* obstruction:
the arithmetic always cooperates, the search space never does.
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### Two coprimality utilities -/

/-- If two integers are not coprime they have a common prime factor. -/
theorem exists_common_prime_of_not_isCoprime {a b : ℤ} (h : ¬ IsCoprime a b) :
    ∃ r : ℤ, Prime r ∧ r ∣ a ∧ r ∣ b := by
  by_contra hc
  push_neg at hc
  exact h (isCoprime_of_no_common_prime fun r hr h1 h2 => (hc r hr h1) h2)

/-- Absolute values of a primitive representation are again a primitive representation, with
both coordinates positive. -/
theorem pos_rep_of_ne_zero {A B M : ℤ} (hA : A ≠ 0) (hB : B ≠ 0) (hcop : IsCoprime A B)
    (hsum : A ^ 2 + B ^ 2 = M) :
    ∃ X Y : ℤ, 0 < X ∧ 0 < Y ∧ X ^ 2 + Y ^ 2 = M ∧ IsCoprime X Y := by
  refine ⟨|A|, |B|, abs_pos.mpr hA, abs_pos.mpr hB, by rw [sq_abs, sq_abs]; exact hsum, ?_⟩
  rcases abs_choice A with hA' | hA' <;> rcases abs_choice B with hB' | hB' <;> rw [hA', hB']
  · exact hcop
  · exact hcop.neg_right
  · exact hcop.neg_left
  · exact hcop.neg_left.neg_right

/-! ### One of the two Brahmagupta compositions with a prime stays primitive -/

/-- If the Brahmagupta composition of `(x, y)` with a primitive pair `(A, B)` fails to be
primitive, then the failure is caused by `p = x² + y²` itself: `p` divides the composed real
part. -/
theorem dvd_of_not_isCoprime_brahmagupta {p x y A B : ℤ} (hp : Prime p)
    (hxy : x ^ 2 + y ^ 2 = p) (hcop : IsCoprime A B)
    (hbad : ¬ IsCoprime (x * A - y * B) (x * B + y * A)) :
    p ∣ x * A - y * B := by
  obtain ⟨r, hr, hr₁, hr₂⟩ := exists_common_prime_of_not_isCoprime hbad
  have hrA : r ∣ p * A := by
    have e : p * A = x * (x * A - y * B) + y * (x * B + y * A) := by
      rw [← hxy]; ring
    rw [e]
    exact dvd_add (hr₁.mul_left _) (hr₂.mul_left _)
  have hrB : r ∣ p * B := by
    have e : p * B = x * (x * B + y * A) - y * (x * A - y * B) := by
      rw [← hxy]; ring
    rw [e]
    exact dvd_sub (hr₂.mul_left _) (hr₁.mul_left _)
  by_cases hrp : r ∣ p
  · have hassoc := hr.associated_of_dvd hp hrp
    exact dvd_trans hassoc.symm.dvd hr₁
  · exfalso
    have hA : r ∣ A := (hr.dvd_mul.mp hrA).resolve_left hrp
    have hB : r ∣ B := (hr.dvd_mul.mp hrB).resolve_left hrp
    exact hr.not_unit (hcop.isUnit_of_dvd' hA hB)

/-! ### Primitive representations of prime powers -/

/-- **Every power of a prime `p ≡ 1 (mod 4)` has a primitive representation.**  For all
`k ≥ 1` there are `A, B > 0` coprime with `A² + B² = p^k`. -/
theorem primitive_rep_prime_pow {p : ℕ} (hp : p.Prime) (hp4 : p % 4 = 1) :
    ∀ k : ℕ, 1 ≤ k → ∃ A B : ℤ, 0 < A ∧ 0 < B ∧ A ^ 2 + B ^ 2 = (p : ℤ) ^ k ∧ IsCoprime A B := by
  obtain ⟨x, y, hx, hy, hxy, hcxy⟩ := prime_sq_add_sq_pos hp hp4
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hp2 : p ≠ 2 := by omega
  have hpx : ¬ ((p : ℤ) ∣ x) := by
    intro hdx
    have hdy : (p : ℤ) ∣ y := by
      refine hpZ.dvd_of_dvd_pow (n := 2) ?_
      have e : y ^ 2 = (p : ℤ) - x ^ 2 := by linarith
      rw [e]
      exact dvd_sub dvd_rfl (Dvd.dvd.pow hdx two_ne_zero)
    exact hpZ.not_unit (hcxy.isUnit_of_dvd' hdx hdy)
  have hptwo : ¬ ((p : ℤ) ∣ 2) := by
    intro hd
    have : (p : ℤ) ≤ 2 := Int.le_of_dvd (by norm_num) hd
    have h2 : 2 ≤ p := hp.two_le
    have : (p : ℤ) = 2 := by
      have : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast h2
      omega
    exact hp2 (by exact_mod_cast this)
  intro k hk
  induction k, hk using Nat.le_induction with
  | base => exact ⟨x, y, hx, hy, by rw [pow_one]; exact hxy, hcxy⟩
  | succ k hk ih =>
    obtain ⟨A, B, hA, hB, hsum, hcop⟩ := ih
    -- `p` divides neither coordinate of a primitive representation of `p^k`, `k ≥ 1`
    have hpA : ¬ ((p : ℤ) ∣ A) := by
      intro hdA
      have hpk : (p : ℤ) ∣ (p : ℤ) ^ k := dvd_pow_self _ (by omega)
      have hdB : (p : ℤ) ∣ B := by
        refine hpZ.dvd_of_dvd_pow (n := 2) ?_
        have e : B ^ 2 = (p : ℤ) ^ k - A ^ 2 := by linarith
        rw [e]
        exact dvd_sub hpk (Dvd.dvd.pow hdA two_ne_zero)
      exact hpZ.not_unit (hcop.isUnit_of_dvd' hdA hdB)
    -- one of the two compositions is primitive
    have key : IsCoprime (x * A - y * B) (x * B + y * A) ∨
        IsCoprime (x * A - (-y) * B) (x * B + (-y) * A) := by
      by_contra hbad
      push_neg at hbad
      obtain ⟨hb₁, hb₂⟩ := hbad
      have hd₁ : (p : ℤ) ∣ x * A - y * B :=
        dvd_of_not_isCoprime_brahmagupta hpZ hxy hcop hb₁
      have hd₂ : (p : ℤ) ∣ x * A - (-y) * B :=
        dvd_of_not_isCoprime_brahmagupta hpZ (by rw [← hxy]; ring) hcop hb₂
      have hsum2 : (p : ℤ) ∣ 2 * (x * A) := by
        have e : 2 * (x * A) = (x * A - y * B) + (x * A - (-y) * B) := by ring
        rw [e]; exact dvd_add hd₁ hd₂
      rcases hpZ.dvd_mul.mp hsum2 with h | h
      · exact hptwo h
      · rcases hpZ.dvd_mul.mp h with h' | h'
        · exact hpx h'
        · exact hpA h'
    -- either way, its norm is `p^(k+1)`
    have hnorm : ∀ z : ℤ, z ^ 2 = y ^ 2 →
        (x * A - z * B) ^ 2 + (x * B + z * A) ^ 2 = (p : ℤ) ^ (k + 1) := by
      intro z hz
      have e : (x * A - z * B) ^ 2 + (x * B + z * A) ^ 2
          = (x ^ 2 + z ^ 2) * (A ^ 2 + B ^ 2) := by ring
      rw [e, hz, hxy, hsum, pow_succ]
      ring
    have hpone : (1 : ℤ) < (p : ℤ) := by
      have : 2 ≤ p := hp.two_le
      exact_mod_cast Nat.lt_of_lt_of_le one_lt_two this
    have hpowpos : (1 : ℤ) < (p : ℤ) ^ (k + 1) := by
      have := one_lt_pow₀ hpone (n := k + 1) (by omega)
      exact this
    -- turn a primitive pair into a positive primitive pair
    have final : ∀ z : ℤ, z ^ 2 = y ^ 2 → IsCoprime (x * A - z * B) (x * B + z * A) →
        ∃ X Y : ℤ, 0 < X ∧ 0 < Y ∧ X ^ 2 + Y ^ 2 = (p : ℤ) ^ (k + 1) ∧ IsCoprime X Y := by
      intro z hz hc
      have hs := hnorm z hz
      have hne₁ : x * A - z * B ≠ 0 := by
        intro h0
        rw [h0] at hc hs
        have hu : IsUnit (x * B + z * A) := isCoprime_zero_left.mp hc
        have : (x * B + z * A) ^ 2 = 1 := by
          rcases Int.isUnit_iff.mp hu with h | h <;> rw [h] <;> ring
        rw [this] at hs
        simp at hs
        omega
      have hne₂ : x * B + z * A ≠ 0 := by
        intro h0
        rw [h0] at hc hs
        have hu : IsUnit (x * A - z * B) := isCoprime_zero_right.mp hc
        have : (x * A - z * B) ^ 2 = 1 := by
          rcases Int.isUnit_iff.mp hu with h | h <;> rw [h] <;> ring
        rw [this] at hs
        simp at hs
        omega
      exact pos_rep_of_ne_zero hne₁ hne₂ hc hs
    rcases key with hc | hc
    · exact final y rfl hc
    · exact final (-y) (by ring) hc

/-! ### Primitive representations of an arbitrary admissible modulus -/

/-- **Primitivity for every admissible modulus.**  If `N > 1` and every prime factor of `N`
is `≡ 1 (mod 4)`, then `N = A² + B²` for some coprime `A, B > 0`. -/
theorem primitive_rep_of_primes_one_mod_four :
    ∀ N : ℕ, 1 < N → (∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 1) →
      ∃ A B : ℤ, 0 < A ∧ 0 < B ∧ A ^ 2 + B ^ 2 = (N : ℤ) ∧ IsCoprime A B := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro hN hall
    have hN0 : N ≠ 0 := by omega
    set p := N.minFac with hpdef
    have hp : p.Prime := Nat.minFac_prime (by omega)
    have hpN : p ∣ N := Nat.minFac_dvd N
    set k := N.factorization p with hkdef
    have hk1 : 1 ≤ k := hp.factorization_pos_of_dvd hN0 hpN
    set m := p ^ k with hmdef
    set n := N / p ^ k with hndef
    have hmn : m * n = N := Nat.ordProj_mul_ordCompl_eq_self N p
    have hcopmn : Nat.Coprime m n :=
      Nat.Coprime.pow_left _ (Nat.coprime_ordCompl hp hN0)
    have hm1 : 1 < m := by
      calc 1 < p := hp.one_lt
        _ = p ^ 1 := (pow_one p).symm
        _ ≤ p ^ k := Nat.pow_le_pow_right (le_of_lt hp.one_lt) hk1
    obtain ⟨A₁, B₁, hA₁, hB₁, hs₁, hc₁⟩ :=
      primitive_rep_prime_pow hp (hall p hp hpN) k hk1
    have hs₁' : A₁ ^ 2 + B₁ ^ 2 = (m : ℤ) := by rw [hs₁, hmdef]; push_cast; ring
    by_cases hn1 : n = 1
    · refine ⟨A₁, B₁, hA₁, hB₁, ?_, hc₁⟩
      rw [hs₁']
      have : m = N := by rw [← hmn, hn1, mul_one]
      rw [this]
    · have hn0 : n ≠ 0 := by
        intro h
        rw [h, mul_zero] at hmn
        omega
      have hnpos : 0 < n := Nat.pos_of_ne_zero hn0
      have hn1' : 1 < n := by omega
      have hlt : n < N := by
        calc n = 1 * n := (one_mul n).symm
          _ < m * n := (Nat.mul_lt_mul_right hnpos).mpr hm1
          _ = N := hmn
      have hdvdn : n ∣ N := ⟨m, by rw [← hmn]; ring⟩
      obtain ⟨A₂, B₂, hA₂, hB₂, hs₂, hc₂⟩ :=
        ih n hlt hn1' fun r hr hrn => hall r hr (hrn.trans hdvdn)
      have hne : (m : ℤ) ≠ (n : ℤ) := by
        intro h
        have hmn' : m = n := by exact_mod_cast h
        rw [hmn'] at hcopmn
        have : n = 1 := by simpa [Nat.Coprime] using hcopmn
        omega
      obtain ⟨X, Y, hX, hY, hXY, hcXY⟩ :=
        primitive_rep_mul hA₁ hB₁ hA₂ hB₂ hs₁' hs₂ hne hc₁ hc₂
          (Nat.isCoprime_iff_coprime.mpr hcopmn)
      refine ⟨X, Y, hX, hY, ?_, hcXY⟩
      rw [hXY]
      exact_mod_cast congrArg (fun t : ℕ => (t : ℤ)) hmn

/-! ### The universal collapse theorem -/

/-- **Universal exact collapse.**  Let `N` be odd, with every prime factor `≡ 1 (mod 4)`, and
suppose `N` is not a prime power — two distinct primes `p ≠ q` divide it.  Then the Berggren
tree contains two *distinct* words of hypotenuse exactly `N`, and the gcd of their
interference with `N` is an exact, nontrivial, proper divisor of `N`.

Together with `resonance_exists_iff_isSquare_neg_one` (which says these `N` are exactly the
odd moduli on which the walk resonates at all) this makes the factorisation half of the
mechanism unconditional: whenever resonance is arithmetically possible and `N` is not a prime
power, the resonance pair *does* factor `N`. -/
theorem universal_resonance_collapse {N : ℕ} (hodd : N % 2 = 1)
    (hall : ∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 1)
    {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (hpN : p ∣ N) (hqN : q ∣ N) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      (walk w₁).c = (N : ℤ) ∧ (walk w₂).c = (N : ℤ) ∧
      1 < (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) : ℤ) ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) : ℤ) < (N : ℤ) ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) : ℤ) ∣ (N : ℤ) := by
  have hN0 : N ≠ 0 := by
    intro h; rw [h] at hodd; omega
  have hpleN : p ≤ N := Nat.le_of_dvd (Nat.pos_of_ne_zero hN0) hpN
  have hN1 : 1 < N := lt_of_lt_of_le hp.one_lt hpleN
  set k := N.factorization p with hkdef
  have hk1 : 1 ≤ k := hp.factorization_pos_of_dvd hN0 hpN
  set m := p ^ k with hmdef
  set n := N / p ^ k with hndef
  have hmn : m * n = N := Nat.ordProj_mul_ordCompl_eq_self N p
  have hcopmn : Nat.Coprime m n := Nat.Coprime.pow_left _ (Nat.coprime_ordCompl hp hN0)
  have hm1 : 1 < m := by
    calc 1 < p := hp.one_lt
      _ = p ^ 1 := (pow_one p).symm
      _ ≤ p ^ k := Nat.pow_le_pow_right (le_of_lt hp.one_lt) hk1
  -- `q` avoids the `p`-part, hence divides the cofactor
  have hqm : Nat.Coprime q m := Nat.Coprime.pow_right _ ((Nat.coprime_primes hq hp).mpr (Ne.symm hpq))
  have hqn : q ∣ n := by
    have : q ∣ m * n := by rw [hmn]; exact hqN
    exact (Nat.Coprime.dvd_of_dvd_mul_left hqm this)
  have hn1 : 1 < n := lt_of_lt_of_le hq.one_lt (Nat.le_of_dvd (by
    rcases Nat.eq_zero_or_pos n with h | h
    · rw [h, mul_zero] at hmn; omega
    · exact h) hqn)
  have hdvdn : n ∣ N := ⟨m, by rw [← hmn]; ring⟩
  have hdvdm : m ∣ N := ⟨n, by rw [← hmn]⟩
  -- primitive representations of the two coprime parts
  obtain ⟨A₁, B₁, hA₁, hB₁, hs₁, hc₁⟩ := primitive_rep_prime_pow hp (hall p hp hpN) k hk1
  have hs₁' : A₁ ^ 2 + B₁ ^ 2 = (m : ℤ) := by rw [hs₁, hmdef]; push_cast; ring
  obtain ⟨A₂, B₂, hA₂, hB₂, hs₂, hc₂⟩ :=
    primitive_rep_of_primes_one_mod_four n hn1 fun r hr hrn => hall r hr (hrn.trans hdvdn)
  -- both parts are odd, coprime and `> 1`
  have hoddm : ((m : ℤ)) % 2 = 1 := by
    have hm2 : m % 2 = 1 := by
      have h2 : ¬ (2 ∣ m) := fun hd => by
        have : (2 : ℕ) ∣ N := hd.trans hdvdm
        omega
      omega
    omega
  have hoddn : ((n : ℤ)) % 2 = 1 := by
    have hn2 : n % 2 = 1 := by
      have h2 : ¬ (2 ∣ n) := fun hd => by
        have : (2 : ℕ) ∣ N := hd.trans hdvdn
        omega
      omega
    omega
  have hm1Z : (1 : ℤ) < (m : ℤ) := by exact_mod_cast hm1
  have hn1Z : (1 : ℤ) < (n : ℤ) := by exact_mod_cast hn1
  obtain ⟨w₁, w₂, hne, hcw₁, hcw₂, hgcd⟩ :=
    coprime_split_resonance_collapse hA₁ hB₁ hA₂ hB₂ hs₁' hs₂ hm1Z hn1Z hoddm hoddn hc₁ hc₂
      (Nat.isCoprime_iff_coprime.mpr hcopmn)
  have hNmn : (m : ℤ) * (n : ℤ) = (N : ℤ) := by exact_mod_cast congrArg (fun t : ℕ => (t : ℤ)) hmn
  rw [hNmn] at hcw₁ hcw₂ hgcd
  refine ⟨w₁, w₂, hne, hcw₁, hcw₂, ?_, ?_, ?_⟩
  · rcases hgcd with h | h
    · rw [h]; exact hm1Z
    · rw [h]; exact hn1Z
  · rcases hgcd with h | h
    · rw [h, ← hNmn]
      nlinarith [hm1Z, hn1Z]
    · rw [h, ← hNmn]
      nlinarith [hm1Z, hn1Z]
  · rcases hgcd with h | h
    · rw [h, ← hNmn]; exact ⟨(n : ℤ), rfl⟩
    · rw [h, ← hNmn]; exact ⟨(m : ℤ), by ring⟩

/-- **Corollary: the mechanism factors every admissible composite.**  If `N` is odd, has all
prime factors `≡ 1 (mod 4)` and is not a prime power, then the interference of the resonance
pair returns a factorisation `N = d · e` with `1 < d, e < N`. -/
theorem universal_resonance_factorisation {N : ℕ} (hodd : N % 2 = 1)
    (hall : ∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 1)
    {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (hpN : p ∣ N) (hqN : q ∣ N) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧ (walk w₁).c = (N : ℤ) ∧ (walk w₂).c = (N : ℤ) ∧
      ∃ d e : ℕ, 1 < d ∧ 1 < e ∧ d * e = N ∧
        (d : ℤ) = Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) := by
  obtain ⟨w₁, w₂, hne, hc₁, hc₂, hlow, hhigh, hdvd⟩ :=
    universal_resonance_collapse hodd hall hp hq hpq hpN hqN
  set g : ℤ := (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ) : ℤ)
    with hgdef
  have hgnat : ∃ d : ℕ, (d : ℤ) = g :=
    ⟨Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (N : ℤ), rfl⟩
  obtain ⟨d, hd⟩ := hgnat
  have hdN : d ∣ N := by
    have : (d : ℤ) ∣ (N : ℤ) := by rw [hd]; exact hdvd
    exact_mod_cast this
  obtain ⟨e, he⟩ := hdN
  have hd1 : 1 < d := by
    have : (1 : ℤ) < (d : ℤ) := by rw [hd]; exact hlow
    exact_mod_cast this
  have hdlt : d < N := by
    have : (d : ℤ) < (N : ℤ) := by rw [hd]; exact hhigh
    exact_mod_cast this
  have he1 : 1 < e := by
    rcases Nat.lt_or_ge e 2 with h | h
    · interval_cases e
      · omega
      · omega
    · omega
  exact ⟨w₁, w₂, hne, hc₁, hc₂, d, e, hd1, he1, he.symm, hd⟩

/-- **Depth window of the collapsing pair.**  The two words that factor `N` sit in the
window `log₇(N/5) ≤ |w| ≤ (N-5)/8`: the lower bound is the kinematic barrier of
`Barrier.lean` (the tree is too narrow to reach `N` sooner) and the upper bound says the
pair is nevertheless reached at finite, explicitly bounded depth. -/
theorem universal_resonance_collapse_depth {N : ℕ} (hodd : N % 2 = 1)
    (hall : ∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 1)
    {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (hpN : p ∣ N) (hqN : q ∣ N) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧ (walk w₁).c = (N : ℤ) ∧ (walk w₂).c = (N : ℤ) ∧
      (∀ w ∈ [w₁, w₂], (N : ℤ) ≤ 5 * 7 ^ w.length ∧ 8 * (w.length : ℤ) + 5 ≤ (N : ℤ)) := by
  obtain ⟨w₁, w₂, hne, hc₁, hc₂, -, -, -⟩ :=
    universal_resonance_collapse hodd hall hp hq hpq hpN hqN
  refine ⟨w₁, w₂, hne, hc₁, hc₂, ?_⟩
  intro w hw
  have hwc : (walk w).c = (N : ℤ) := by
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hw
    rcases hw with rfl | rfl
    · exact hc₁
    · exact hc₂
  refine ⟨?_, ?_⟩
  · rw [← hwc]; exact hyp_walk_le w
  · rw [← hwc]; exact_mod_cast hyp_walk_ge w

/-! ### Worked instances beyond the reach of the earlier theorems -/

/-- The *non-squarefree* modulus `325 = 5² · 13` collapses.  No earlier theorem applies: the
semiprime and three-prime results need squarefree moduli with distinct prime factors, while
here the `5`-part is a square. -/
theorem collapse_325 :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      (walk w₁).c = (325 : ℤ) ∧ (walk w₂).c = (325 : ℤ) ∧
      1 < (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (325 : ℤ) : ℤ) ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (325 : ℤ) : ℤ)
        < (325 : ℤ) ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (325 : ℤ) : ℤ)
        ∣ (325 : ℤ) := by
  have hall : ∀ r : ℕ, r.Prime → r ∣ 325 → r % 4 = 1 := by
    intro r hr hrd
    have hd : r ∣ 5 ^ 2 * 13 := by norm_num at hrd ⊢; exact hrd
    rcases (Nat.Prime.dvd_mul hr).mp hd with h | h
    · have h5 : r = 5 :=
        (Nat.prime_dvd_prime_iff_eq hr (by norm_num)).mp (hr.dvd_of_dvd_pow h)
      omega
    · have h13 : r = 13 := (Nat.prime_dvd_prime_iff_eq hr (by norm_num)).mp h
      omega
  have h := universal_resonance_collapse (N := 325) (by norm_num) hall
    (p := 5) (q := 13) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  simpa using h

/-- The `ω = 3` modulus `1105 = 5 · 13 · 17` collapses (the instance singled out in
`FUTURE_DIRECTIONS.md`). -/
theorem collapse_1105 :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      (walk w₁).c = (1105 : ℤ) ∧ (walk w₂).c = (1105 : ℤ) ∧
      1 < (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (1105 : ℤ) : ℤ) ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (1105 : ℤ) : ℤ)
        < (1105 : ℤ) ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (1105 : ℤ) : ℤ)
        ∣ (1105 : ℤ) := by
  have hall : ∀ r : ℕ, r.Prime → r ∣ 1105 → r % 4 = 1 := by
    intro r hr hrd
    have hd : r ∣ 5 * (13 * 17) := by norm_num at hrd ⊢; exact hrd
    rcases (Nat.Prime.dvd_mul hr).mp hd with h | h
    · have h5 : r = 5 := (Nat.prime_dvd_prime_iff_eq hr (by norm_num)).mp h
      omega
    · rcases (Nat.Prime.dvd_mul hr).mp h with h' | h'
      · have h13 : r = 13 := (Nat.prime_dvd_prime_iff_eq hr (by norm_num)).mp h'
        omega
      · have h17 : r = 17 := (Nat.prime_dvd_prime_iff_eq hr (by norm_num)).mp h'
        omega
  have h := universal_resonance_collapse (N := 1105) (by norm_num) hall
    (p := 5) (q := 13) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  simpa using h

end QuantumPythagoreanWalk