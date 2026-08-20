import Physics.QuantumPythagoreanWalk.ExactMultiplicity

/-!
# Quantum-Pythagorean-Walk — XI. Exact collapse for an arbitrary coprime splitting

`Semiprime.lean` proves that a semiprime `N = pq` (distinct primes `≡ 1 mod 4`) carries a
resonant pair whose interference gcd is a *nontrivial proper* divisor of `N`.  That proof
is prime-specific: it needs an anti-cancellation lemma for the quartic
`Q(x,y) = x⁴ - 6x²y² + y⁴` at a *prime* modulus.

This file removes the primality hypothesis entirely and, at the same time, sharpens the
conclusion from "nontrivial proper divisor" to an **exact value**.

The new ingredients are:

* `quartic_isCoprime` : for *any* odd `m = x² + y²` with `x, y` coprime, `Q(x,y)` is coprime
  to `m`.  The proof is the identity `Q = m² - 8x²y²` plus the observation that a common
  prime factor would have to divide both `x` and `y`.
* `brahmagupta_isCoprime` : both Brahmagupta compositions of a primitive representation of
  `m` with a primitive representation of a *coprime* `n` are again primitive.  (The version
  in `Semiprime.lean` assumes `m`, `n` are primes.)
* `interference_of_signs` : the interference `a₁a₂ - b₁b₂` of the two nodes is, up to sign,
  one of the two Euler quartic forms — this is what lets us discard the sign ambiguity in
  `node_of_primitive_rep'`.
* `gcd_sq_mul_eq` : the exact gcd computation `gcd(n²k, mn) = n` whenever `k` is coprime to
  `m` and `m` is coprime to `n`.  This is what upgrades "proper nontrivial divisor" to an
  *exact* factor.

Putting them together, `coprime_split_resonance_collapse` says:

> If `N = m·n` with `m, n > 1` odd and coprime and each carrying a primitive representation
> as a sum of two squares, then the Berggren tree contains two **distinct** resonant words
> for `N`, and their interference gcd is **exactly `m` or exactly `n`** — a genuine factor,
> read off with no further search.

Because primitivity is preserved by the composition, the hypothesis propagates along any
coprime factorisation.  We record the concrete consequence for three distinct primes
(`three_prime_resonance_collapse`), which settles the `ω(N) = 3` case of the next-cycle
conjecture.
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### A criterion for coprimality in `ℤ` -/

/-- Two integers with no common prime factor are coprime. -/
theorem isCoprime_of_no_common_prime {a b : ℤ}
    (h : ∀ r : ℤ, Prime r → r ∣ a → r ∣ b → False) : IsCoprime a b := by
  rw [Int.isCoprime_iff_gcd_eq_one]
  by_contra hg
  obtain ⟨r, hr, hrdvd⟩ := Nat.exists_prime_and_dvd hg
  have hrZ : Prime (r : ℤ) := Nat.prime_iff_prime_int.mp hr
  have h1 : (r : ℤ) ∣ a :=
    dvd_trans (Int.natCast_dvd_natCast.mpr hrdvd) (Int.gcd_dvd_left _ _)
  have h2 : (r : ℤ) ∣ b :=
    dvd_trans (Int.natCast_dvd_natCast.mpr hrdvd) (Int.gcd_dvd_right _ _)
  exact h _ hrZ h1 h2

/-- A prime cannot divide both entries of a coprime pair. -/
theorem not_prime_dvd_both {a b r : ℤ} (hcop : IsCoprime a b) (hr : Prime r)
    (h1 : r ∣ a) (h2 : r ∣ b) : False :=
  hr.not_unit (hcop.isUnit_of_dvd' h1 h2)

/-! ### The Euler quartic is coprime to its own modulus -/

/-- **Anti-cancellation, general form.**  For any odd `m = x² + y²` with `x`, `y` coprime,
the Euler quartic `x⁴ - 6x²y² + y⁴` is coprime to `m`.  No primality is needed: the
identity `x⁴ - 6x²y² + y⁴ = m² - 8x²y²` shows a common prime factor would divide `8x²y²`,
hence (oddness) both `x` and `y`. -/
theorem quartic_isCoprime {m x y : ℤ} (hm : x ^ 2 + y ^ 2 = m) (hodd : m % 2 = 1)
    (hcop : IsCoprime x y) : IsCoprime (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4) m := by
  refine isCoprime_of_no_common_prime ?_
  intro r hr hrQ hrm
  -- `r` divides `8x²y² = m² - Q`
  have hr8 : r ∣ 8 * (x ^ 2 * y ^ 2) := by
    have hid : 8 * (x ^ 2 * y ^ 2) = m * m - (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4) := by
      rw [← hm]; ring
    rw [hid]
    exact dvd_sub (hrm.mul_left m) hrQ
  -- `r` is odd, since `r ∣ m` and `m` is odd
  have hrodd : ¬ (r ∣ 8) := by
    intro h8
    have h2 : r ∣ 2 := by
      rcases hr.dvd_mul.mp (show r ∣ 2 * 4 by simpa using h8) with h | h
      · exact h
      · rcases hr.dvd_mul.mp (show r ∣ 2 * 2 by simpa using h) with h' | h' <;> exact h'
    have hnat : r.natAbs ∣ 2 := by simpa using Int.natAbs_dvd_natAbs.mpr h2
    have hrp : r.natAbs.Prime := Int.prime_iff_natAbs_prime.mp hr
    have h2eq : r.natAbs = 2 :=
      ((Nat.prime_two.eq_one_or_self_of_dvd _ hnat).resolve_left hrp.ne_one)
    have hdvd : ((r.natAbs : ℤ)) ∣ m := Int.natAbs_dvd.mpr hrm
    rw [h2eq] at hdvd
    have : (2 : ℤ) ∣ m := by exact_mod_cast hdvd
    omega
  -- hence `r ∣ x²y²`, so `r ∣ x` and `r ∣ y`
  have hrxy : r ∣ x ^ 2 * y ^ 2 := (hr.dvd_mul.mp hr8).resolve_left hrodd
  have hrx : r ∣ x ∨ r ∣ y := by
    rcases hr.dvd_mul.mp hrxy with h | h
    · exact Or.inl (hr.dvd_of_dvd_pow h)
    · exact Or.inr (hr.dvd_of_dvd_pow h)
  rcases hrx with h | h
  · have hy2 : r ∣ y ^ 2 := by
      have : y ^ 2 = m - x ^ 2 := by rw [← hm]; ring
      rw [this]
      exact dvd_sub hrm (dvd_pow h two_ne_zero)
    exact not_prime_dvd_both hcop hr h (hr.dvd_of_dvd_pow hy2)
  · have hx2 : r ∣ x ^ 2 := by
      have : x ^ 2 = m - y ^ 2 := by rw [← hm]; ring
      rw [this]
      exact dvd_sub hrm (dvd_pow h two_ne_zero)
    exact not_prime_dvd_both hcop hr (hr.dvd_of_dvd_pow hx2) h

/-! ### Brahmagupta composition preserves primitivity -/

/-- **Brahmagupta primitivity, general form.**  If `m = x² + y²` and `n = u² + v²` are
primitive representations of coprime integers, both compositions are primitive. -/
theorem brahmagupta_isCoprime {m n x y u v : ℤ} (hm : x ^ 2 + y ^ 2 = m)
    (hn : u ^ 2 + v ^ 2 = n) (hcxy : IsCoprime x y) (hcuv : IsCoprime u v)
    (hmn : IsCoprime m n) :
    IsCoprime (x * u + y * v) (y * u - x * v) := by
  refine isCoprime_of_no_common_prime ?_
  intro r hr hrA hrB
  -- the four linear combinations isolating `xn`, `yn`, `um`, `vm`
  have hxn : r ∣ x * n := by
    have hid : x * n = u * (x * u + y * v) - v * (y * u - x * v) := by rw [← hn]; ring
    rw [hid]
    exact dvd_sub (hrA.mul_left u) (hrB.mul_left v)
  have hyn : r ∣ y * n := by
    have hid : y * n = v * (x * u + y * v) + u * (y * u - x * v) := by rw [← hn]; ring
    rw [hid]
    exact dvd_add (hrA.mul_left v) (hrB.mul_left u)
  have hum : r ∣ u * m := by
    have hid : u * m = x * (x * u + y * v) + y * (y * u - x * v) := by rw [← hm]; ring
    rw [hid]
    exact dvd_add (hrA.mul_left x) (hrB.mul_left y)
  have hvm : r ∣ v * m := by
    have hid : v * m = y * (x * u + y * v) - x * (y * u - x * v) := by rw [← hm]; ring
    rw [hid]
    exact dvd_sub (hrA.mul_left y) (hrB.mul_left x)
  -- `r` divides `mn`
  have hrmn : r ∣ m * n := by
    have hid : m * n = (x * u + y * v) ^ 2 + (y * u - x * v) ^ 2 := by rw [← hm, ← hn]; ring
    rw [hid]
    exact dvd_add (dvd_pow hrA two_ne_zero) (dvd_pow hrB two_ne_zero)
  rcases hr.dvd_mul.mp hrmn with hrm | hrn
  · -- `r ∣ m`, so `r ∤ n`, so `r` divides both `x` and `y`
    have hrn : ¬ (r ∣ n) := fun h => not_prime_dvd_both hmn hr hrm h
    exact not_prime_dvd_both hcxy hr ((hr.dvd_mul.mp hxn).resolve_right hrn)
      ((hr.dvd_mul.mp hyn).resolve_right hrn)
  · -- `r ∣ n`, so `r ∤ m`, so `r` divides both `u` and `v`
    have hrm : ¬ (r ∣ m) := fun h => not_prime_dvd_both hmn hr h hrn
    exact not_prime_dvd_both hcuv hr ((hr.dvd_mul.mp hum).resolve_right hrm)
      ((hr.dvd_mul.mp hvm).resolve_right hrm)

/-! ### Sign bookkeeping -/

/-- The interference `a₁a₂ - b₁b₂` of two nodes whose legs are known only up to sign is,
up to a global sign, one of the two Euler forms. -/
theorem interference_of_signs {P₁ P₂ R₁ R₂ a₁ b₁ a₂ b₂ : ℤ}
    (ha₁ : a₁ = P₁ ∨ a₁ = -P₁) (hb₁ : b₁ = R₁ ∨ b₁ = -R₁)
    (ha₂ : a₂ = P₂ ∨ a₂ = -P₂) (hb₂ : b₂ = R₂ ∨ b₂ = -R₂) :
    a₁ * a₂ - b₁ * b₂ = P₁ * P₂ - R₁ * R₂ ∨ a₁ * a₂ - b₁ * b₂ = -(P₁ * P₂ - R₁ * R₂) ∨
      a₁ * a₂ - b₁ * b₂ = P₁ * P₂ + R₁ * R₂ ∨
      a₁ * a₂ - b₁ * b₂ = -(P₁ * P₂ + R₁ * R₂) := by
  rcases ha₁ with h1 | h1 <;> rcases hb₁ with h2 | h2 <;>
    rcases ha₂ with h3 | h3 <;> rcases hb₂ with h4 | h4 <;>
    subst h1 <;> subst h2 <;> subst h3 <;> subst h4 <;>
    first
      | (left; ring1)
      | (right; left; ring1)
      | (right; right; left; ring1)
      | (right; right; right; ring1)

/-! ### An exact gcd computation -/

/-- If `k` is coprime to `m` and `m` is coprime to `n > 0`, then `gcd(n²k, mn) = n`
*exactly*.  This is the arithmetic heart of the "exact factor" statement. -/
theorem gcd_sq_mul_eq {m n k : ℤ} (hn : 0 < n) (hmn : IsCoprime m n) (hkm : IsCoprime k m) :
    (Int.gcd (n ^ 2 * k) (m * n) : ℤ) = n := by
  have hco : IsCoprime (n * k) m := IsCoprime.mul_left hmn.symm hkm
  obtain ⟨a, b, hab⟩ := hco
  refine Int.dvd_antisymm (Int.natCast_nonneg _) hn.le ?_ ?_
  · -- `n` is an integer combination of `n²k` and `mn`
    have hcomb : a * (n ^ 2 * k) + b * (m * n) = n := by linear_combination n * hab
    calc ((Int.gcd (n ^ 2 * k) (m * n) : ℕ) : ℤ)
        ∣ a * (n ^ 2 * k) + b * (m * n) :=
          dvd_add ((Int.gcd_dvd_left _ _).mul_left a) ((Int.gcd_dvd_right _ _).mul_left b)
      _ = n := hcomb
  · have htoNat : ((n.toNat : ℤ)) = n := Int.toNat_of_nonneg hn.le
    have hdvd : n.toNat ∣ Int.gcd (n ^ 2 * k) (m * n) :=
      Int.dvd_gcd (by rw [htoNat]; exact ⟨n * k, by ring⟩) (by rw [htoNat]; exact ⟨m, by ring⟩)
    have := Int.natCast_dvd_natCast.mpr hdvd
    rwa [htoNat] at this

/-- The same computation with the roles of the two factors exchanged. -/
theorem gcd_sq_mul_eq' {m n k : ℤ} (hm : 0 < m) (hmn : IsCoprime m n) (hkn : IsCoprime k n) :
    (Int.gcd (m ^ 2 * k) (m * n) : ℤ) = m := by
  have h := gcd_sq_mul_eq (m := n) (n := m) (k := k) hm hmn.symm hkn
  rwa [mul_comm n m] at h

/-! ### The exact collapse -/

set_option maxHeartbeats 1000000 in
/-- **Exact resonance collapse for a coprime splitting.**  If `N = m·n` with `m, n > 1` odd,
coprime, and each given by a primitive representation as a sum of two positive squares, then
the Berggren tree contains two distinct words whose nodes both have hypotenuse exactly `N`,
and the gcd of their interference with `N` is *exactly* `m` or *exactly* `n`. -/
theorem coprime_split_resonance_collapse {m n x y u v : ℤ}
    (hx : 0 < x) (hy : 0 < y) (hu : 0 < u) (hv : 0 < v)
    (hm : x ^ 2 + y ^ 2 = m) (hn : u ^ 2 + v ^ 2 = n)
    (hm1 : 1 < m) (hn1 : 1 < n) (hmodd : m % 2 = 1) (hnodd : n % 2 = 1)
    (hcxy : IsCoprime x y) (hcuv : IsCoprime u v) (hmn : IsCoprime m n) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      (walk w₁).c = m * n ∧ (walk w₂).c = m * n ∧
      ((Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (m * n) : ℤ) = m ∨
       (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b) (m * n) : ℤ) = n) := by
  have hmpos : 0 < m := by linarith
  have hnpos : 0 < n := by linarith
  -- `m = n` is impossible: they are coprime and both exceed `1`
  have hmnne : m ≠ n := by
    intro h
    have : IsUnit m := hmn.isUnit_of_dvd' dvd_rfl (by rw [h])
    rcases Int.isUnit_iff.mp this with h1 | h1 <;> omega
  -- the two Brahmagupta compositions
  obtain ⟨A, hAdef⟩ : ∃ A : ℤ, A = x * u + y * v := ⟨_, rfl⟩
  obtain ⟨B, hBdef⟩ : ∃ B : ℤ, B = x * v - y * u := ⟨_, rfl⟩
  obtain ⟨C, hCdef⟩ : ∃ C : ℤ, C = x * u - y * v := ⟨_, rfl⟩
  obtain ⟨D, hDdef⟩ : ∃ D : ℤ, D = x * v + y * u := ⟨_, rfl⟩
  have hApos : 0 < A := by rw [hAdef]; positivity
  have hDpos : 0 < D := by rw [hDdef]; positivity
  have hcop₁ : IsCoprime A B := by
    have h := brahmagupta_isCoprime hm hn hcxy hcuv hmn
    have hBneg : x * v - y * u = -(y * u - x * v) := by ring
    rw [hAdef, hBdef, hBneg]
    exact h.neg_right
  have hcop₂ : IsCoprime D C := by
    have h := brahmagupta_isCoprime (n := n) (u := v) (v := u) hm (by rw [← hn]; ring)
      hcxy hcuv.symm hmn
    have hCneg : x * u - y * v = -(y * v - x * u) := by ring
    rw [hDdef, hCdef, hCneg]
    exact h.neg_right
  have hsum₁ : A ^ 2 + B ^ 2 = m * n := by rw [hAdef, hBdef, ← hm, ← hn]; ring
  have hsum₂ : D ^ 2 + C ^ 2 = m * n := by rw [hDdef, hCdef, ← hm, ← hn]; ring
  have hoddN : (m * n) % 2 = 1 := by
    rw [Int.mul_emod, hmodd, hnodd]
    norm_num
  -- both "imaginary parts" are nonzero, else `m = n`
  have hBne : B ≠ 0 := by
    rw [hBdef]
    intro h
    obtain ⟨h1, h2⟩ := eq_of_cross_mul hx hu hcxy hcuv (by linarith)
    exact hmnne (by rw [← hm, ← hn, h1, h2])
  have hCne : C ≠ 0 := by
    rw [hCdef]
    intro h
    obtain ⟨h1, h2⟩ := eq_of_cross_mul hx hv hcxy hcuv.symm (by linarith)
    exact hmnne (by rw [← hm, ← hn, h1, h2]; ring)
  obtain ⟨t₁, ht₁, ht₁odd, ht₁c, ht₁b, ht₁a⟩ :=
    node_of_primitive_rep' hApos hBne hcop₁ (by rw [hsum₁]; exact hoddN)
  obtain ⟨t₂, ht₂, ht₂odd, ht₂c, ht₂b, ht₂a⟩ :=
    node_of_primitive_rep' hDpos hCne hcop₂ (by rw [hsum₂]; exact hoddN)
  -- the two odd legs differ, so the two nodes differ
  have hxne : x ≠ y := by
    intro h
    have h2 : m = 2 * y ^ 2 := by rw [← hm, h]; ring
    omega
  have hune : u ≠ v := by
    intro h
    have h2 : n = 2 * v ^ 2 := by rw [← hn, h]; ring
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
  -- the two possible interference values, with their exact gcds
  have hQx : IsCoprime (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4) m := quartic_isCoprime hm hmodd hcxy
  have hQu : IsCoprime (u ^ 4 - 6 * u ^ 2 * v ^ 2 + v ^ 4) n := quartic_isCoprime hn hnodd hcuv
  have hid₁ : (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) - (2 * A * B) * (2 * D * C)
      = -(n ^ 2 * (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4)) := by
    rw [hAdef, hBdef, hCdef, hDdef, ← hn]; ring
  have hid₂ : (A ^ 2 - B ^ 2) * (D ^ 2 - C ^ 2) + (2 * A * B) * (2 * D * C)
      = -(m ^ 2 * (u ^ 4 - 6 * u ^ 2 * v ^ 2 + v ^ 4)) := by
    rw [hAdef, hBdef, hCdef, hDdef, ← hm]; ring
  have hgcdn : (Int.gcd (n ^ 2 * (x ^ 4 - 6 * x ^ 2 * y ^ 2 + y ^ 4)) (m * n) : ℤ) = n :=
    gcd_sq_mul_eq hnpos hmn hQx
  have hgcdm : (Int.gcd (m ^ 2 * (u ^ 4 - 6 * u ^ 2 * v ^ 2 + v ^ 4)) (m * n) : ℤ) = m :=
    gcd_sq_mul_eq' hmpos hmn hQu
  -- read off the gcd of the actual interference
  have hkey : ((Int.gcd (t₁.a * t₂.a - t₁.b * t₂.b) (m * n) : ℤ) = m ∨
      (Int.gcd (t₁.a * t₂.a - t₁.b * t₂.b) (m * n) : ℤ) = n) := by
    have hsign := interference_of_signs (P₁ := A ^ 2 - B ^ 2) (R₁ := 2 * A * B)
      (P₂ := D ^ 2 - C ^ 2) (R₂ := 2 * D * C)
      (a₁ := t₁.a) (b₁ := t₁.b) (a₂ := t₂.a) (b₂ := t₂.b)
      (ht₁a.imp id (fun h => by rw [h]; ring))
      (ht₁b.imp id (fun h => by rw [h]))
      (ht₂a.imp id (fun h => by rw [h]; ring))
      (ht₂b.imp id (fun h => by rw [h]))
    rcases hsign with h | h | h | h
    · right; rw [h, hid₁, Int.neg_gcd]; exact hgcdn
    · right; rw [h, hid₁, neg_neg]; exact hgcdn
    · left; rw [h, hid₂, Int.neg_gcd]; exact hgcdm
    · left
      rw [h, hid₂, neg_neg]
      exact hgcdm
  -- transport to words
  obtain ⟨w₁, hw₁⟩ := exists_word_of_isPPT t₁ ht₁ ht₁odd
  obtain ⟨w₂, hw₂⟩ := exists_word_of_isPPT t₂ ht₂ ht₂odd
  refine ⟨w₁, w₂, ?_, ?_, ?_, ?_⟩
  · intro h; exact htne (by rw [← hw₁, ← hw₂, h])
  · rw [hw₁, ht₁c, hsum₁]
  · rw [hw₂, ht₂c]; exact hsum₂
  · rw [hw₁, hw₂]; exact hkey

/-! ### Primitivity propagates along coprime products -/

/-- **The hypothesis of `coprime_split_resonance_collapse` is multiplicative.**  A product of
two coprime integers, each a sum of two positive coprime squares, is again a sum of two
positive coprime squares.  (The positivity of the second coordinate is recovered by taking
the absolute value of the Brahmagupta "imaginary part", which is nonzero because `m ≠ n`.) -/
theorem primitive_rep_mul {m n x y u v : ℤ} (hx : 0 < x) (hy : 0 < y) (hu : 0 < u) (hv : 0 < v)
    (hm : x ^ 2 + y ^ 2 = m) (hn : u ^ 2 + v ^ 2 = n) (hmne : m ≠ n)
    (hcxy : IsCoprime x y) (hcuv : IsCoprime u v) (hmn : IsCoprime m n) :
    ∃ X Y : ℤ, 0 < X ∧ 0 < Y ∧ X ^ 2 + Y ^ 2 = m * n ∧ IsCoprime X Y := by
  have hcop : IsCoprime (x * u + y * v) (x * v - y * u) := by
    have h := brahmagupta_isCoprime hm hn hcxy hcuv hmn
    have hBneg : x * v - y * u = -(y * u - x * v) := by ring
    rw [hBneg]
    exact h.neg_right
  have hYne : x * v - y * u ≠ 0 := by
    intro h
    obtain ⟨h1, h2⟩ := eq_of_cross_mul hx hu hcxy hcuv (by linarith)
    exact hmne (by rw [← hm, ← hn, h1, h2])
  have hXpos : 0 < x * u + y * v := by positivity
  refine ⟨x * u + y * v, |x * v - y * u|, hXpos, abs_pos.mpr hYne, ?_, ?_⟩
  · rw [sq_abs, ← hm, ← hn]; ring
  · rcases abs_choice (x * v - y * u) with h2 | h2 <;> rw [h2]
    · exact hcop
    · exact hcop.neg_right

/-! ### The three-prime case -/

/-- Distinct primes are coprime in `ℤ`. -/
theorem isCoprime_of_ne_primes {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    IsCoprime (p : ℤ) (q : ℤ) :=
  Nat.isCoprime_iff_coprime.mpr ((Nat.coprime_primes hp hq).mpr hpq)

/-- **Exact collapse for a product of three primes `≡ 1 (mod 4)`.**  The tree contains two
distinct words of hypotenuse exactly `pqr`, and their interference gcd is exactly `pq` or
exactly `r`; in particular it is a proper nontrivial divisor, so the resonance pair factors
an `ω = 3` modulus with no further search. -/
theorem three_prime_resonance_collapse {p q r : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hr : r.Prime) (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hr4 : r % 4 = 1)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      (walk w₁).c = (p : ℤ) * q * r ∧ (walk w₂).c = (p : ℤ) * q * r ∧
      ((Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b)
          ((p : ℤ) * q * r) : ℤ) = (p : ℤ) * q ∨
       (Int.gcd ((walk w₁).a * (walk w₂).a - (walk w₁).b * (walk w₂).b)
          ((p : ℤ) * q * r) : ℤ) = (r : ℤ)) := by
  obtain ⟨x, y, hx, hy, hxy, hcxy⟩ := prime_sq_add_sq_pos hp hp4
  obtain ⟨u, v, hu, hv, huv, hcuv⟩ := prime_sq_add_sq_pos hq hq4
  obtain ⟨s, t, hs, ht, hst, hcst⟩ := prime_sq_add_sq_pos hr hr4
  have hpqZ : ((p : ℤ)) ≠ (q : ℤ) := by exact_mod_cast hpq
  -- a primitive positive representation of `pq`
  obtain ⟨X, Y, hX, hY, hXY, hcXY⟩ :=
    primitive_rep_mul hx hy hu hv hxy huv hpqZ hcxy hcuv (isCoprime_of_ne_primes hp hq hpq)
  have hp5 : 5 ≤ p := by
    rcases Nat.lt_or_ge p 5 with hlt | hge
    · have := hp.two_le; interval_cases p <;> omega
    · exact hge
  have hq5 : 5 ≤ q := by
    rcases Nat.lt_or_ge q 5 with hlt | hge
    · have := hq.two_le; interval_cases q <;> omega
    · exact hge
  have hr5 : 5 ≤ r := by
    rcases Nat.lt_or_ge r 5 with hlt | hge
    · have := hr.two_le; interval_cases r <;> omega
    · exact hge
  have hpZ : (5 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp5
  have hqZ : (5 : ℤ) ≤ (q : ℤ) := by exact_mod_cast hq5
  have hrZ : (5 : ℤ) ≤ (r : ℤ) := by exact_mod_cast hr5
  have hm1 : (1 : ℤ) < (p : ℤ) * q := by nlinarith
  have hn1 : (1 : ℤ) < (r : ℤ) := by linarith
  have hmodd : ((p : ℤ) * q) % 2 = 1 := by
    have hpn : ((p : ℤ)) % 2 = 1 := by
      have : (p : ℤ) % 2 = ((p % 2 : ℕ) : ℤ) := by omega
      rw [this]; norm_num; omega
    have hqn : ((q : ℤ)) % 2 = 1 := by
      have : (q : ℤ) % 2 = ((q % 2 : ℕ) : ℤ) := by omega
      rw [this]; norm_num; omega
    rw [Int.mul_emod, hpn, hqn]; norm_num
  have hnodd : ((r : ℤ)) % 2 = 1 := by
    have : (r : ℤ) % 2 = ((r % 2 : ℕ) : ℤ) := by omega
    rw [this]; norm_num; omega
  have hmn : IsCoprime ((p : ℤ) * q) (r : ℤ) :=
    IsCoprime.mul_left (isCoprime_of_ne_primes hp hr hpr) (isCoprime_of_ne_primes hq hr hqr)
  obtain ⟨w₁, w₂, hne, hc₁, hc₂, hgcd⟩ :=
    coprime_split_resonance_collapse hX hY hs ht hXY hst hm1 hn1 hmodd hnodd hcXY hcst hmn
  exact ⟨w₁, w₂, hne, hc₁, hc₂, hgcd⟩

end QuantumPythagoreanWalk