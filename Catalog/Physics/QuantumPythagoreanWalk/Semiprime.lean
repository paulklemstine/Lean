import Physics.QuantumPythagoreanWalk.Resonance

/-!
# Quantum-Pythagorean-Walk — VII. Semiprime targets carry a resonant *pair*

`Collapse.lean` collapses a *pair* of resonant nodes onto a factor.  `Resonance.lean` shows
when a single resonance exists.  The missing existence statement — the one the factoring
story actually needs — is that a semiprime target carries **two distinct** resonant nodes.
That is proved here:

> If `p ≠ q` are primes `≡ 1 (mod 4)`, then the Berggren tree contains two distinct nodes
> whose hypotenuse is exactly `pq`, reached by two distinct walk words
> (`exists_two_resonant_words_of_semiprime`).

The construction is Brahmagupta composition of the two Gaussian representations
`p = x²+y²`, `q = u²+v²`:

`pq = (xu+yv)² + (xv-yu)² = (xu-yv)² + (xv+yu)²`,

both of which are *primitive* (`brahmagupta_coprime`), of opposite parity, and give
different unordered pairs — hence different nodes.  Together with `resonance_collapse`
this says: for a semiprime, the resonant pair whose interference reveals a factor always
exists; only its non-degeneracy has to be checked.
-/

namespace QuantumPythagoreanWalk

open Node

/-- Squares preserve parity. -/
private theorem sq_emod_two (a : ℤ) : a ^ 2 % 2 = a % 2 := by
  obtain ⟨k, hk⟩ : ∃ k, a = 2 * k + a % 2 := ⟨a / 2, by omega⟩
  have h := Int.emod_two_eq_zero_or_one a
  rcases h with h | h <;> rw [hk, h] <;> ring_nf <;> omega

/-- Every prime `p ≡ 1 (mod 4)` is a sum of two positive coprime squares. -/
theorem prime_sq_add_sq_pos {p : ℕ} (hp : p.Prime) (hp4 : p % 4 = 1) :
    ∃ x y : ℤ, 0 < x ∧ 0 < y ∧ x ^ 2 + y ^ 2 = (p : ℤ) ∧ IsCoprime x y := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq (p := p) (by omega)
  have hane : a ≠ 0 := by
    rintro rfl
    simp at hab
    rcases (hp.eq_one_or_self_of_dvd b ⟨b, by rw [← hab]; ring⟩) with h | h
    · rw [h] at hab; simp at hab; have := hp.two_le; omega
    · rw [h] at hab
      have := hp.two_le
      nlinarith
  have hbne : b ≠ 0 := by
    rintro rfl
    simp at hab
    rcases (hp.eq_one_or_self_of_dvd a ⟨a, by rw [← hab]; ring⟩) with h | h
    · rw [h] at hab; simp at hab; have := hp.two_le; omega
    · rw [h] at hab
      have := hp.two_le
      nlinarith
  refine ⟨(a : ℤ), (b : ℤ), by positivity, by positivity, by exact_mod_cast hab, ?_⟩
  rw [Int.isCoprime_iff_gcd_eq_one]
  by_contra hne
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd hne
  have hrg : (r : ℤ) ∣ ((Int.gcd (a : ℤ) (b : ℤ) : ℕ) : ℤ) := Int.natCast_dvd_natCast.mpr hrd
  have hra : (r : ℤ) ∣ (a : ℤ) := hrg.trans (Int.gcd_dvd_left _ _)
  have hrb : (r : ℤ) ∣ (b : ℤ) := hrg.trans (Int.gcd_dvd_right _ _)
  have hrp : (r : ℤ) ∣ (p : ℤ) := by
    have : ((a : ℤ)) ^ 2 + ((b : ℤ)) ^ 2 = (p : ℤ) := by exact_mod_cast hab
    rw [← this]
    exact dvd_add (Dvd.dvd.pow hra (by norm_num)) (Dvd.dvd.pow hrb (by norm_num))
  have hrpn : r ∣ p := by exact_mod_cast hrp
  have hrp' : r = p := ((Nat.Prime.eq_one_or_self_of_dvd hp r hrpn).resolve_left hr.ne_one)
  subst hrp'
  -- then `r² ∣ r`, impossible
  have hr2 : ((r : ℤ)) ^ 2 ∣ (r : ℤ) := by
    have hcast : ((a : ℤ)) ^ 2 + ((b : ℤ)) ^ 2 = (r : ℤ) := by exact_mod_cast hab
    have hdd : ((r : ℤ)) ^ 2 ∣ ((a : ℤ)) ^ 2 + ((b : ℤ)) ^ 2 :=
      dvd_add (pow_dvd_pow_of_dvd hra 2) (pow_dvd_pow_of_dvd hrb 2)
    rwa [hcast] at hdd
  have hrpos : (0 : ℤ) < (r : ℤ) := by exact_mod_cast hr.pos
  have := Int.le_of_dvd hrpos hr2
  have h2 : (2 : ℤ) ≤ (r : ℤ) := by exact_mod_cast hr.two_le
  nlinarith

/-- **Brahmagupta primitivity.**  The two compositions of representations of distinct primes
`p = x²+y²` and `q = u²+v²` are primitive representations of `pq`. -/
theorem brahmagupta_coprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    {x y u v : ℤ} (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (huv : u ^ 2 + v ^ 2 = (q : ℤ)) :
    IsCoprime (x * u + y * v) (x * v - y * u) := by
  rw [Int.isCoprime_iff_gcd_eq_one]
  by_contra hne
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd hne
  have hrg : (r : ℤ) ∣ ((Int.gcd (x * u + y * v) (x * v - y * u) : ℕ) : ℤ) :=
    Int.natCast_dvd_natCast.mpr hrd
  have hrA : (r : ℤ) ∣ x * u + y * v := hrg.trans (Int.gcd_dvd_left _ _)
  have hrB : (r : ℤ) ∣ x * v - y * u := hrg.trans (Int.gcd_dvd_right _ _)
  -- `r` divides `pq`
  have hrpq : (r : ℤ) ∣ (p : ℤ) * (q : ℤ) := by
    have hid : (x * u + y * v) ^ 2 + (x * v - y * u) ^ 2 = (x ^ 2 + y ^ 2) * (u ^ 2 + v ^ 2) := by
      ring
    have : (r : ℤ) ∣ (x * u + y * v) ^ 2 + (x * v - y * u) ^ 2 :=
      dvd_add (Dvd.dvd.pow hrA (by norm_num)) (Dvd.dvd.pow hrB (by norm_num))
    rwa [hid, hxy, huv] at this
  have hrprime : Prime (r : ℤ) := Nat.prime_iff_prime_int.mp hr
  -- combinations isolating `x`, `y` (or `u`, `v`)
  have hcx : (r : ℤ) ∣ x * (q : ℤ) := by
    have hid : u * (x * u + y * v) + v * (x * v - y * u) = x * (u ^ 2 + v ^ 2) := by ring
    have : (r : ℤ) ∣ u * (x * u + y * v) + v * (x * v - y * u) :=
      dvd_add (Dvd.dvd.mul_left hrA _) (Dvd.dvd.mul_left hrB _)
    rwa [hid, huv] at this
  have hcy : (r : ℤ) ∣ y * (q : ℤ) := by
    have hid : v * (x * u + y * v) - u * (x * v - y * u) = y * (u ^ 2 + v ^ 2) := by ring
    have : (r : ℤ) ∣ v * (x * u + y * v) - u * (x * v - y * u) :=
      dvd_sub (Dvd.dvd.mul_left hrA _) (Dvd.dvd.mul_left hrB _)
    rwa [hid, huv] at this
  have hcu : (r : ℤ) ∣ u * (p : ℤ) := by
    have hid : x * (x * u + y * v) - y * (x * v - y * u) = u * (x ^ 2 + y ^ 2) := by ring
    have : (r : ℤ) ∣ x * (x * u + y * v) - y * (x * v - y * u) :=
      dvd_sub (Dvd.dvd.mul_left hrA _) (Dvd.dvd.mul_left hrB _)
    rwa [hid, hxy] at this
  have hcv : (r : ℤ) ∣ v * (p : ℤ) := by
    have hid : y * (x * u + y * v) + x * (x * v - y * u) = v * (x ^ 2 + y ^ 2) := by ring
    have : (r : ℤ) ∣ y * (x * u + y * v) + x * (x * v - y * u) :=
      dvd_add (Dvd.dvd.mul_left hrA _) (Dvd.dvd.mul_left hrB _)
    rwa [hid, hxy] at this
  -- `r` is `p` or `q`
  have hrpn : r = p ∨ r = q := by
    rcases hrprime.dvd_mul.mp hrpq with h | h
    · left
      have : r ∣ p := by exact_mod_cast h
      exact (Nat.Prime.eq_one_or_self_of_dvd hp r this).resolve_left hr.ne_one
    · right
      have : r ∣ q := by exact_mod_cast h
      exact (Nat.Prime.eq_one_or_self_of_dvd hq r this).resolve_left hr.ne_one
  rcases hrpn with rfl | rfl
  · -- `r = p`: then `r ∣ x` and `r ∣ y`, so `r² ∣ p = r`
    have hrq : ¬ ((r : ℤ) ∣ (q : ℤ)) := by
      intro h
      have : r ∣ q := by exact_mod_cast h
      exact hpq ((Nat.Prime.eq_one_or_self_of_dvd hq r this).resolve_left hr.ne_one)
    have hrx : (r : ℤ) ∣ x := (hrprime.dvd_mul.mp hcx).resolve_right hrq
    have hry : (r : ℤ) ∣ y := (hrprime.dvd_mul.mp hcy).resolve_right hrq
    have hr2 : ((r : ℤ)) ^ 2 ∣ (r : ℤ) := by
      have hdd : ((r : ℤ)) ^ 2 ∣ x ^ 2 + y ^ 2 :=
        dvd_add (pow_dvd_pow_of_dvd hrx 2) (pow_dvd_pow_of_dvd hry 2)
      rwa [hxy] at hdd
    have hrpos : (0 : ℤ) < (r : ℤ) := by exact_mod_cast hr.pos
    have hle := Int.le_of_dvd hrpos hr2
    have h2 : (2 : ℤ) ≤ (r : ℤ) := by exact_mod_cast hr.two_le
    nlinarith
  · -- `r = q`: symmetric
    have hrp : ¬ ((r : ℤ) ∣ (p : ℤ)) := by
      intro h
      have : r ∣ p := by exact_mod_cast h
      exact hpq ((Nat.Prime.eq_one_or_self_of_dvd hp r this).resolve_left hr.ne_one).symm
    have hru : (r : ℤ) ∣ u := (hrprime.dvd_mul.mp hcu).resolve_right hrp
    have hrv : (r : ℤ) ∣ v := (hrprime.dvd_mul.mp hcv).resolve_right hrp
    have hr2 : ((r : ℤ)) ^ 2 ∣ (r : ℤ) := by
      have hdd : ((r : ℤ)) ^ 2 ∣ u ^ 2 + v ^ 2 :=
        dvd_add (pow_dvd_pow_of_dvd hru 2) (pow_dvd_pow_of_dvd hrv 2)
      rwa [huv] at hdd
    have hrpos : (0 : ℤ) < (r : ℤ) := by exact_mod_cast hr.pos
    have hle := Int.le_of_dvd hrpos hr2
    have h2 : (2 : ℤ) ≤ (r : ℤ) := by exact_mod_cast hr.two_le
    nlinarith

/-- A primitive representation `N = A² + B²` of an odd `N` with `A ≠ B` gives a node of the
walk with hypotenuse `N`. -/
theorem node_of_primitive_rep {A B : ℤ} (hA : 0 < A) (hB : 0 < B) (hcop : IsCoprime A B)
    (hodd : (A ^ 2 + B ^ 2) % 2 = 1) :
    ∃ t : Node, t.IsPPT ∧ t.a % 2 = 1 ∧ t.c = A ^ 2 + B ^ 2 ∧ t.b = 2 * A * B ∧
      (t.a = A ^ 2 - B ^ 2 ∨ t.a = B ^ 2 - A ^ 2) := by
  have hpar : (A + B) % 2 = 1 := by
    have h1 := sq_emod_two A
    have h2 := sq_emod_two B
    omega
  have hne : A ≠ B := by
    intro h
    rw [h] at hpar
    omega
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · refine ⟨repNode B A, ?_, ?_, ?_, ?_, Or.inr rfl⟩
    · exact (repNode_isPPT hA hlt hcop.symm (by omega)).1
    · exact (repNode_isPPT hA hlt hcop.symm (by omega)).2
    · simp only [repNode_c]; ring
    · simp only [repNode_b]; ring
  · refine ⟨repNode A B, ?_, ?_, ?_, ?_, Or.inl rfl⟩
    · exact (repNode_isPPT hB hgt hcop (by omega)).1
    · exact (repNode_isPPT hB hgt hcop (by omega)).2
    · simp only [repNode_c]
    · simp only [repNode_b]

/-- Sign-free version of `node_of_primitive_rep`: the second leg only has to be nonzero. -/
theorem node_of_primitive_rep' {A B : ℤ} (hA : 0 < A) (hB : B ≠ 0) (hcop : IsCoprime A B)
    (hodd : (A ^ 2 + B ^ 2) % 2 = 1) :
    ∃ t : Node, t.IsPPT ∧ t.a % 2 = 1 ∧ t.c = A ^ 2 + B ^ 2 ∧
      (t.b = 2 * A * B ∨ t.b = -(2 * A * B)) ∧
      (t.a = A ^ 2 - B ^ 2 ∨ t.a = B ^ 2 - A ^ 2) := by
  obtain ⟨B', hB'pos, hB'sq, hB'cop, hB'sign⟩ :
      ∃ B' : ℤ, 0 < B' ∧ B' ^ 2 = B ^ 2 ∧ IsCoprime A B' ∧ (B' = B ∨ B' = -B) := by
    rcases lt_or_gt_of_ne hB with h | h
    · exact ⟨-B, by omega, by ring, hcop.neg_right, Or.inr rfl⟩
    · exact ⟨B, h, rfl, hcop, Or.inl rfl⟩
  obtain ⟨t, h1, h2, h3, hb, h4⟩ :=
    node_of_primitive_rep hA hB'pos hB'cop (by rw [hB'sq]; exact hodd)
  refine ⟨t, h1, h2, by rw [h3, hB'sq], ?_, ?_⟩
  · rcases hB'sign with hs | hs
    · exact Or.inl (by rw [hb, hs])
    · exact Or.inr (by rw [hb, hs]; ring)
  · rw [hB'sq] at h4
    exact h4

/-- Two coprime positive pairs with equal cross products coincide. -/
theorem eq_of_cross_mul {x y u v : ℤ} (hx : 0 < x) (hu : 0 < u)
    (hcxy : IsCoprime x y) (hcuv : IsCoprime u v) (h : x * v = y * u) :
    x = u ∧ y = v := by
  have hxu : x ∣ u := hcxy.dvd_of_dvd_mul_left ⟨v, h.symm⟩
  have hux : u ∣ x := hcuv.dvd_of_dvd_mul_right ⟨y, by linarith⟩
  have hxeq : x = u := Int.dvd_antisymm hx.le hu.le hxu hux
  refine ⟨hxeq, ?_⟩
  subst hxeq
  have hvy : x * v = x * y := by linarith
  have := mul_left_cancel₀ (ne_of_gt hx) hvy
  omega

/-! ### Non-degeneracy: the interference of the two Brahmagupta branches never cancels -/

/-- A prime `p = x² + y²` divides neither of its own Gaussian coordinates. -/
theorem prime_not_dvd_coord {p : ℕ} (hp : p.Prime) {x y : ℤ} (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) :
    ¬ ((p : ℤ) ∣ x) := by
  intro hx
  have hprime : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hy2 : (p : ℤ) ∣ y ^ 2 := by
    have h1 : (p : ℤ) ∣ x ^ 2 := Dvd.dvd.pow hx (by norm_num)
    have h2 : y ^ 2 = (p : ℤ) - x ^ 2 := by linarith
    rw [h2]
    exact dvd_sub dvd_rfl h1
  have hy : (p : ℤ) ∣ y := hprime.dvd_of_dvd_pow hy2
  have hsq : ((p : ℤ)) ^ 2 ∣ (p : ℤ) := by
    have hdd : ((p : ℤ)) ^ 2 ∣ x ^ 2 + y ^ 2 :=
      dvd_add (pow_dvd_pow_of_dvd hx 2) (pow_dvd_pow_of_dvd hy 2)
    rwa [hxy] at hdd
  have hpos : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  have hle := Int.le_of_dvd hpos hsq
  have h2 : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
  nlinarith

/-- **Anti-cancellation lemma.**  For a prime `p = x² + y²` with `p ≡ 1 (mod 4)` the quartic
`x⁴ - 6x²y² + y⁴` — the real part of `(x + iy)⁴` — is never divisible by `p`; modulo `p` it
is `8x⁴`. -/
theorem prime_not_dvd_quartic {p : ℕ} (hp : p.Prime) (hp4 : p % 4 = 1) {x y : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) :
    ¬ ((p : ℤ) ∣ (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4)) := by
  intro h
  have hprime : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hWid : x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4
      = 8 * x ^ 4 - (p : ℤ) * (7 * x ^ 2 - y ^ 2) := by
    rw [← hxy]; ring
  rw [hWid] at h
  have h8 : (p : ℤ) ∣ 8 * x ^ 4 := by
    have := dvd_add h (dvd_mul_right (p : ℤ) (7 * x ^ 2 - y ^ 2))
    simpa using this
  rcases hprime.dvd_mul.mp h8 with h1 | h1
  · -- `p ∣ 8` forces `p = 2`, incompatible with `p ≡ 1 (mod 4)`
    have hn : p ∣ 8 := by exact_mod_cast h1
    have hle := Nat.le_of_dvd (by norm_num) hn
    have h2 := hp.two_le
    interval_cases p <;> omega
  · exact prime_not_dvd_coord hp hxy (hprime.dvd_of_dvd_pow h1)

set_option maxHeartbeats 800000 in
/-- **Full resonance collapse for a semiprime.**  For distinct primes `p, q ≡ 1 (mod 4)` the
Berggren walk contains two distinct words whose nodes both have hypotenuse exactly `N = pq`,
and the interference of that pair is *automatically* non-degenerate: the gcd read off by
`resonance_collapse` is a proper nontrivial divisor of `N`.

The two branches are the two Brahmagupta compositions `π̄ρ` and `πρ` of the Gaussian primes
above `p` and `q`.  Their interference term is `±(u²+v²)²(x⁴-6x²y²+y⁴)` or
`±(x²+y²)²(u⁴-6u²v²+v⁴)`, and `prime_not_dvd_quartic` says neither is killed by `N`. -/
theorem semiprime_resonance_collapse {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hpq : p ≠ q) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      (walk w₁).c = (p : ℤ) * q ∧ (walk w₂).c = (p : ℤ) * q ∧
      1 < Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) ((p : ℤ) * q) ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) ((p : ℤ) * q) : ℤ)
        < (p : ℤ) * q ∧
      (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) ((p : ℤ) * q) : ℤ)
        ∣ (p : ℤ) * q := by
  obtain ⟨x, y, hx, hy, hxy, hcxy⟩ := prime_sq_add_sq_pos hp hp4
  obtain ⟨u, v, hu, hv, huv, hcuv⟩ := prime_sq_add_sq_pos hq hq4
  have hprimeP : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hprimeQ : Prime (q : ℤ) := Nat.prime_iff_prime_int.mp hq
  have hpqZ : (p : ℤ) ≠ (q : ℤ) := by exact_mod_cast hpq
  have hpnq : ¬ ((p : ℤ) ∣ (q : ℤ)) := by
    intro h
    have hn : p ∣ q := by exact_mod_cast h
    exact hpq ((hq.eq_one_or_self_of_dvd p hn).resolve_left hp.ne_one)
  have hqnp : ¬ ((q : ℤ) ∣ (p : ℤ)) := by
    intro h
    have hn : q ∣ p := by exact_mod_cast h
    exact hpq ((hp.eq_one_or_self_of_dvd q hn).resolve_left hq.ne_one).symm
  -- the two Brahmagupta compositions
  obtain ⟨A, hAdef⟩ : ∃ A : ℤ, A = x * u + y * v := ⟨_, rfl⟩
  obtain ⟨B, hBdef⟩ : ∃ B : ℤ, B = x * v - y * u := ⟨_, rfl⟩
  obtain ⟨C, hCdef⟩ : ∃ C : ℤ, C = x * u - y * v := ⟨_, rfl⟩
  obtain ⟨D, hDdef⟩ : ∃ D : ℤ, D = x * v + y * u := ⟨_, rfl⟩
  have hApos : 0 < A := by rw [hAdef]; positivity
  have hDpos : 0 < D := by rw [hDdef]; positivity
  have hcop₁ : IsCoprime A B := by
    rw [hAdef, hBdef]; exact brahmagupta_coprime hp hq hpq hxy huv
  have hcop₂ : IsCoprime D C := by
    rw [hDdef, hCdef]
    exact brahmagupta_coprime hp hq hpq hxy (by linarith)
  have hsum₁ : A ^ 2 + B ^ 2 = (p : ℤ) * q := by
    rw [hAdef, hBdef, ← hxy, ← huv]; ring
  have hsum₂ : D ^ 2 + C ^ 2 = (p : ℤ) * q := by
    rw [hDdef, hCdef, ← hxy, ← huv]; ring
  have hoddN : ((p : ℤ) * q) % 2 = 1 := by
    have hn : (p * q) % 2 = 1 :=
      Nat.odd_iff.mp ((Nat.odd_iff.mpr (by omega)).mul (Nat.odd_iff.mpr (by omega)))
    exact_mod_cast hn
  -- `B ≠ 0` and `C ≠ 0`, else `p = q`
  have hBne : B ≠ 0 := by
    rw [hBdef]
    intro h
    obtain ⟨h1, h2⟩ := eq_of_cross_mul hx hu hcxy hcuv (by linarith)
    exact hpqZ (by rw [← hxy, ← huv, h1, h2])
  have hCne : C ≠ 0 := by
    rw [hCdef]
    intro h
    obtain ⟨h1, h2⟩ := eq_of_cross_mul hx hv hcxy hcuv.symm (by linarith)
    exact hpqZ (by rw [← hxy, ← huv, h1, h2]; ring)
  obtain ⟨t₁, ht₁, ht₁odd, ht₁c, ht₁b, ht₁a⟩ :=
    node_of_primitive_rep' hApos hBne hcop₁ (by rw [hsum₁]; exact hoddN)
  obtain ⟨t₂, ht₂, ht₂odd, ht₂c, ht₂b, ht₂a⟩ :=
    node_of_primitive_rep' hDpos hCne hcop₂ (by rw [hsum₂]; exact hoddN)
  -- the two odd legs differ, so the two nodes differ
  have hxne : x ≠ y := by
    intro h
    have h2 : (2 : ℤ) ∣ (p : ℤ) := ⟨x ^ 2, by rw [← hxy, h]; ring⟩
    have : (2 : ℕ) ∣ p := by exact_mod_cast h2
    omega
  have hune : u ≠ v := by
    intro h
    have h2 : (2 : ℤ) ∣ (q : ℤ) := ⟨u ^ 2, by rw [← huv, h]; ring⟩
    have : (2 : ℕ) ∣ q := by exact_mod_cast h2
    omega
  have hxysq : x ^ 2 - y ^ 2 ≠ 0 := by
    intro h
    rcases lt_trichotomy x y with h1 | h1 | h1
    · nlinarith
    · exact hxne h1
    · nlinarith
  have huvsq : u ^ 2 - v ^ 2 ≠ 0 := by
    intro h
    rcases lt_trichotomy u v with h1 | h1 | h1
    · nlinarith
    · exact hune h1
    · nlinarith
  have hdiff : (A ^ 2 - B ^ 2) - (C ^ 2 - D ^ 2) = 8 * (x * y * u * v) := by
    rw [hAdef, hBdef, hCdef, hDdef]; ring
  have hsumST : (A ^ 2 - B ^ 2) + (C ^ 2 - D ^ 2)
      = 2 * ((x ^ 2 - y ^ 2) * (u ^ 2 - v ^ 2)) := by
    rw [hAdef, hBdef, hCdef, hDdef]; ring
  have hprodpos : 0 < 8 * (x * y * u * v) := by positivity
  have hsumne : (A ^ 2 - B ^ 2) + (C ^ 2 - D ^ 2) ≠ 0 := by
    rw [hsumST]
    exact mul_ne_zero two_ne_zero (mul_ne_zero hxysq huvsq)
  have hane : t₁.a ≠ t₂.a := by
    rcases ht₁a with h1 | h1 <;> rcases ht₂a with h2 | h2 <;> rw [h1, h2] <;> intro hc
    · exact hsumne (by linarith)
    · linarith
    · linarith
    · exact hsumne (by linarith)
  have htne : t₁ ≠ t₂ := fun h => hane (by rw [h])
  -- non-degeneracy of the interference
  have hid₁ : (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) - 4 * A * B * C * D
      = -((q : ℤ) ^ 2 * (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4)) := by
    rw [hAdef, hBdef, hCdef, hDdef, ← huv]; ring
  have hid₂ : (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) + 4 * A * B * C * D
      = -((p : ℤ) ^ 2 * (u ^ 4 - 6 * u ^ 2 * v ^ 2 + v ^ 4)) := by
    rw [hAdef, hBdef, hCdef, hDdef, ← hxy]; ring
  have hN₁ : ¬ ((p : ℤ) * q ∣ (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) - 4 * A * B * C * D) := by
    intro h
    rw [hid₁] at h
    have hpd : (p : ℤ) ∣ (q : ℤ) ^ 2 * (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4) := by
      have := (dvd_mul_right (p : ℤ) (q : ℤ)).trans h
      rwa [dvd_neg] at this
    rcases hprimeP.dvd_mul.mp hpd with h1 | h1
    · exact hpnq (hprimeP.dvd_of_dvd_pow h1)
    · exact prime_not_dvd_quartic hp hp4 hxy h1
  have hN₂ : ¬ ((p : ℤ) * q ∣ (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) + 4 * A * B * C * D) := by
    intro h
    rw [hid₂] at h
    have hqd : (q : ℤ) ∣ (p : ℤ) ^ 2 * (u ^ 4 - 6 * u ^ 2 * v ^ 2 + v ^ 4) := by
      have := (dvd_mul_left (q : ℤ) (p : ℤ)).trans h
      rwa [dvd_neg] at this
    rcases hprimeQ.dvd_mul.mp hqd with h1 | h1
    · exact hqnp (hprimeQ.dvd_of_dvd_pow h1)
    · exact prime_not_dvd_quartic hq hq4 huv h1
  have hM₁ : ¬ ((p : ℤ) * q ∣ -((A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) - 4 * A * B * C * D)) :=
    fun h => hN₁ (dvd_neg.mp h)
  have hM₂ : ¬ ((p : ℤ) * q ∣ -((A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) + 4 * A * B * C * D)) :=
    fun h => hN₂ (dvd_neg.mp h)
  have hgen : ∀ z : ℤ,
      (z = (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) - 4 * A * B * C * D ∨
        z = -((A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) - 4 * A * B * C * D) ∨
        z = (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) + 4 * A * B * C * D ∨
        z = -((A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) + 4 * A * B * C * D)) →
      ¬ ((p : ℤ) * q ∣ z) := by
    rintro z (rfl | rfl | rfl | rfl)
    · exact hN₁
    · exact hM₁
    · exact hN₂
    · exact hM₂
  have hne : ¬ ((p : ℤ) * q ∣ t₁.a * t₂.a - t₁.b * t₂.b) := by
    rcases ht₁a with h1 | h1 <;> rcases ht₁b with h2 | h2 <;>
      rcases ht₂a with h3 | h3 <;> rcases ht₂b with h4 | h4 <;>
      rw [h1, h2, h3, h4] <;> apply hgen <;>
      first
        | (left; ring1)
        | (right; left; ring1)
        | (right; right; left; ring1)
        | (right; right; right; ring1)
  have hne' : ¬ ((p : ℤ) * q ∣ t₁.a * t₂.a + t₁.b * t₂.b) := by
    rcases ht₁a with h1 | h1 <;> rcases ht₁b with h2 | h2 <;>
      rcases ht₂a with h3 | h3 <;> rcases ht₂b with h4 | h4 <;>
      rw [h1, h2, h3, h4] <;> apply hgen <;>
      first
        | (left; ring1)
        | (right; left; ring1)
        | (right; right; left; ring1)
        | (right; right; right; ring1)
  -- assemble
  have hNgt : (1 : ℤ) < (p : ℤ) * q := by
    have h1 : (5 : ℤ) ≤ (p : ℤ) := by
      have := hp.two_le
      have : 5 ≤ p := by
        rcases Nat.lt_or_ge p 5 with hlt | hge
        · interval_cases p <;> omega
        · exact hge
      exact_mod_cast this
    have h2 : (5 : ℤ) ≤ (q : ℤ) := by
      have := hq.two_le
      have : 5 ≤ q := by
        rcases Nat.lt_or_ge q 5 with hlt | hge
        · interval_cases q <;> omega
        · exact hge
      exact_mod_cast this
    nlinarith
  obtain ⟨w₁, hw₁⟩ := exists_word_of_isPPT t₁ ht₁ ht₁odd
  obtain ⟨w₂, hw₂⟩ := exists_word_of_isPPT t₂ ht₂ ht₂odd
  have hc₁ : (walk w₁).c = (p : ℤ) * q := by rw [hw₁, ht₁c, hsum₁]
  have hc₂ : (walk w₂).c = (p : ℤ) * q := by rw [hw₂, ht₂c]; exact hsum₂
  have hr₁ : (p : ℤ) * q ∣ t₁.c := ⟨1, by rw [ht₁c, hsum₁]; ring⟩
  have hr₂ : (p : ℤ) * q ∣ t₂.c := ⟨1, by rw [ht₂c, hsum₂]; ring⟩
  obtain ⟨g1, g2, g3⟩ := resonance_collapse hNgt ht₁ ht₂ hr₁ hr₂ hne hne'
  refine ⟨w₁, w₂, ?_, hc₁, hc₂, ?_, ?_, ?_⟩
  · intro h; exact htne (by rw [← hw₁, ← hw₂, h])
  · rw [hw₁, hw₂]; exact g1
  · rw [hw₁, hw₂]; exact g2
  · rw [hw₁, hw₂]; exact g3

/-- **Two resonances for a semiprime.**  For distinct primes `p, q ≡ 1 (mod 4)` the walk
contains two distinct nodes of hypotenuse exactly `pq`, reached by two distinct words. -/
theorem exists_two_resonant_words_of_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hpq : p ≠ q) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      (walk w₁).c = (p : ℤ) * q ∧ (walk w₂).c = (p : ℤ) * q := by
  obtain ⟨w₁, w₂, h, h₁, h₂, _⟩ := semiprime_resonance_collapse hp hq hp4 hq4 hpq
  exact ⟨w₁, w₂, h, h₁, h₂⟩

/-- **Tree resonance factors every product of two distinct primes `≡ 1 (mod 4)`.**  The
composite `N = pq` is never prime — witnessed constructively by the interference gcd. -/
theorem not_prime_semiprime_of_resonance {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hpq : p ≠ q) :
    ¬ Prime ((p : ℤ) * q) := by
  obtain ⟨w₁, w₂, _, _, _, g1, g2, g3⟩ := semiprime_resonance_collapse hp hq hp4 hq4 hpq
  intro hprime
  set d := Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) ((p : ℤ) * q) with hd
  have hNnat : (((p : ℤ) * q).natAbs).Prime := Int.prime_iff_natAbs_prime.mp hprime
  have hdd : d ∣ ((p : ℤ) * q).natAbs := by simpa using Int.natAbs_dvd_natAbs.mpr g3
  rcases hNnat.eq_one_or_self_of_dvd d hdd with h | h
  · omega
  · have hNabs : ((((p : ℤ) * q).natAbs : ℤ)) = (p : ℤ) * q := by
      refine Int.natAbs_of_nonneg ?_
      positivity
    omega

end QuantumPythagoreanWalk