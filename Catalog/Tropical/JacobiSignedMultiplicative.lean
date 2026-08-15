import Tropical.JacobiSignedWeilFloorBound

/-!
# Multiplicativity of the Jacobi-signed circle count and the semiprime Weil floor

The Jacobi-signed circle count is defined for an arbitrary modulus `n` by weighting the
circle `x² + y² = 1` over `ZMod n` with the *Jacobi symbol* `(x / n)`.  Summing the `y`'s
away, this is the character sum

`WZ n = ∑_{x : ZMod n} (x(1-x²) / n)`.

Main results.

* `JacSign.jchar_mul` : `x ↦ (x / n)` is multiplicative on `ZMod n`.
* `JacSign.WZ_mul` : `WZ (m n) = WZ m · WZ n` for coprime moduli — the Chinese remainder
  theorem turns the circle count into a **symmetric product over the factors**.
* `JacSign.WZ_prime` : for a prime modulus the Jacobi-signed count is the Legendre
  character sum `W p` of the core file.
* `JacSign.WZ_semiprime` : `WZ (p q) = W p · W q` for distinct primes.
* `JacSign.WZ_semiprime_sq_le` : `WZ (p q) ^ 2 ≤ 16 · p q`, i.e. `|WZ N| ≤ 4 √N`:
  **the semiprime Weil floor.**  The signal available to a factoring witness is
  `O(√N)` against a search space of size `N`.
* `JacSign.WZ_semiprime_eq_zero_of_three_mod_four` : if either prime is `≡ 3 (mod 4)`
  the whole statistic vanishes.
-/

open Finset

namespace JacSign

/-- The Jacobi symbol as a `ℤ`-valued function on `ZMod n`. -/
def jchar (n : ℕ) [NeZero n] (x : ZMod n) : ℤ := jacobiSym (x.val : ℤ) n

/-- The Jacobi-signed circle count for an arbitrary modulus. -/
noncomputable def WZ (n : ℕ) [NeZero n] : ℤ := ∑ x : ZMod n, jchar n (x * (1 - x ^ 2))

theorem jchar_mul (n : ℕ) [NeZero n] (x y : ZMod n) :
    jchar n (x * y) = jchar n x * jchar n y := by
  unfold jchar
  rw [← jacobiSym.mul_left]
  apply jacobiSym.mod_left'
  have h : ((((x * y).val : ℤ)) : ZMod n) = (((x.val * y.val : ℤ)) : ZMod n) := by
    push_cast
    simp
  exact (ZMod.intCast_eq_intCast_iff' _ _ _).mp h

/-- Reducing the modulus: the Jacobi symbol only sees the residue class. -/
theorem jchar_cast {N k : ℕ} [NeZero N] [NeZero k] (x : ZMod N) (hd : k ∣ N) :
    jacobiSym (x.val : ℤ) k = jchar k (ZMod.castHom hd (ZMod k) x) := by
  apply jacobiSym.mod_left'
  have h : (((x.val : ℤ)) : ZMod k) = ((((ZMod.castHom hd (ZMod k) x).val : ℤ)) : ZMod k) := by
    push_cast
    simp [ZMod.natCast_val, ZMod.castHom_apply]
  exact (ZMod.intCast_eq_intCast_iff' _ _ _).mp h

/-- The Jacobi symbol splits along a coprime factorisation of the modulus. -/
theorem jchar_split (m n : ℕ) [NeZero m] [NeZero n] (x : ZMod (m * n)) :
    haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
    jchar (m * n) x
      = jchar m (ZMod.castHom (dvd_mul_right m n) (ZMod m) x)
        * jchar n (ZMod.castHom (dvd_mul_left n m) (ZMod n) x) := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  show jacobiSym _ (m * n) = _
  rw [jacobiSym.mul_right, jchar_cast (k := m) x (dvd_mul_right m n),
    jchar_cast (k := n) x (dvd_mul_left n m)]

/-- **Multiplicativity.** For coprime moduli the Jacobi-signed circle count factors as a
symmetric product; this is exactly the "factors inseparable" phenomenon of the
experiment. -/
theorem WZ_mul (m n : ℕ) [NeZero m] [NeZero n] (h : m.Coprime n) :
    WZ (m * n) = WZ m * WZ n := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  set f : ZMod (m * n) →+* ZMod m := ZMod.castHom (dvd_mul_right m n) (ZMod m) with hf
  set g : ZMod (m * n) →+* ZMod n := ZMod.castHom (dvd_mul_left n m) (ZMod n) with hg
  have hsplit : ∀ x : ZMod (m * n), jchar (m * n) (x * (1 - x ^ 2))
      = jchar m (f x * (1 - (f x) ^ 2)) * jchar n (g x * (1 - (g x) ^ 2)) := by
    intro x
    show jacobiSym _ (m * n) = _
    rw [jacobiSym.mul_right]
    congr 1
    · rw [jchar_cast (k := m) (x * (1 - x ^ 2)) (dvd_mul_right m n)]
      congr 2
      simp [hf, map_mul, map_sub, map_pow]
    · rw [jchar_cast (k := n) (x * (1 - x ^ 2)) (dvd_mul_left n m)]
      congr 2
      simp [hg, map_mul, map_sub, map_pow]
  have hprod : WZ (m * n)
      = ∑ z : ZMod m × ZMod n, jchar m (z.1 * (1 - z.1 ^ 2)) * jchar n (z.2 * (1 - z.2 ^ 2)) := by
    rw [WZ, Finset.sum_congr rfl fun x _ => hsplit x]
    refine Fintype.sum_equiv (ZMod.chineseRemainder h).toEquiv _ _ fun x => ?_
    have h1 : ((ZMod.chineseRemainder h).toEquiv x).1 = f x := by
      simp [hf, ZMod.chineseRemainder]
    have h2 : ((ZMod.chineseRemainder h).toEquiv x).2 = g x := by
      simp [hg, ZMod.chineseRemainder]
    rw [h1, h2]
  rw [hprod, WZ, WZ, Finset.sum_mul_sum]
  exact Fintype.sum_prod_type _

theorem jchar_prime (p : ℕ) [Fact p.Prime] (x : ZMod p) :
    jchar p x = quadraticChar (ZMod p) x := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  unfold jchar
  rw [← jacobiSym.legendreSym.to_jacobiSym, legendreSym]
  congr 1
  push_cast
  simp [ZMod.natCast_val]

/-- For a prime modulus, the Jacobi-signed circle count is the Legendre character sum. -/
theorem WZ_prime (p : ℕ) [Fact p.Prime] : WZ p = W p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  rw [WZ, W]
  exact Finset.sum_congr rfl fun x _ => jchar_prime p _

/-- **The semiprime factorisation of the statistic**: `W(N) = W(p)·W(q)`. -/
theorem WZ_semiprime {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    WZ (p * q) = W p * W q := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  haveI : NeZero q := ⟨(Fact.out : q.Prime).ne_zero⟩
  have hcop : p.Coprime q := (Nat.coprime_primes (Fact.out) (Fact.out)).mpr hpq
  rw [WZ_mul p q hcop, WZ_prime, WZ_prime]

/-- **The semiprime Weil floor**: `|W(N)| ≤ 4 √N` for `N = p q`. -/
theorem WZ_semiprime_sq_le {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp : p ≠ 2) (hq : q ≠ 2) : (WZ (p * q)) ^ 2 ≤ 16 * ((p * q : ℕ) : ℤ) := by
  have hW := W_sq_le p hp
  have hV := W_sq_le q hq
  have hWnn : (0 : ℤ) ≤ (W p) ^ 2 := sq_nonneg _
  have hVnn : (0 : ℤ) ≤ (W q) ^ 2 := sq_nonneg _
  rw [WZ_semiprime hpq, mul_pow]
  push_cast
  nlinarith [hW, hV, hWnn, hVnn]

/-! ### The geometric statistic for a composite modulus -/

/-- The Jacobi-signed circle count of the paper, for an arbitrary modulus: the points of
`x² + y² = 1` over `ZMod n`, weighted by the Jacobi symbol `(x / n)`. -/
noncomputable def circleWeightZ (n : ℕ) [NeZero n] : ℤ :=
  ∑ x : ZMod n, ∑ y : ZMod n, if x ^ 2 + y ^ 2 = 1 then jchar n x else 0

/-- **The geometric circle weight is multiplicative in the modulus.** -/
theorem circleWeightZ_mul (m n : ℕ) [NeZero m] [NeZero n] (h : m.Coprime n) :
    circleWeightZ (m * n) = circleWeightZ m * circleWeightZ n := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  set e := ZMod.chineseRemainder h with he
  set f : ZMod (m * n) →+* ZMod m := ZMod.castHom (dvd_mul_right m n) (ZMod m) with hf
  set g : ZMod (m * n) →+* ZMod n := ZMod.castHom (dvd_mul_left n m) (ZMod n) with hg
  have hef : ∀ x, (e x).1 = f x := by intro x; simp [he, hf, ZMod.chineseRemainder]
  have heg : ∀ x, (e x).2 = g x := by intro x; simp [he, hg, ZMod.chineseRemainder]
  set G : ZMod m × ZMod m → ℤ := fun z => if z.1 ^ 2 + z.2 ^ 2 = 1 then jchar m z.1 else 0 with hG
  set H : ZMod n × ZMod n → ℤ := fun z => if z.1 ^ 2 + z.2 ^ 2 = 1 then jchar n z.1 else 0 with hH
  have hcond : ∀ x y : ZMod (m * n),
      (x ^ 2 + y ^ 2 = 1) ↔ ((f x) ^ 2 + (f y) ^ 2 = 1 ∧ (g x) ^ 2 + (g y) ^ 2 = 1) := by
    intro x y
    constructor
    · intro hxy
      refine ⟨?_, ?_⟩
      · have := congrArg f hxy; simpa [map_add, map_pow] using this
      · have := congrArg g hxy; simpa [map_add, map_pow] using this
    · rintro ⟨h1, h2⟩
      refine e.injective (Prod.ext ?_ ?_)
      · simpa [hef, map_add, map_pow] using h1
      · simpa [heg, map_add, map_pow] using h2
  have hterm : ∀ z : ZMod (m * n) × ZMod (m * n),
      (if z.1 ^ 2 + z.2 ^ 2 = 1 then jchar (m * n) z.1 else 0)
        = G (f z.1, f z.2) * H (g z.1, g z.2) := by
    rintro ⟨x, y⟩
    simp only [hG, hH]
    by_cases hxy : x ^ 2 + y ^ 2 = 1
    · obtain ⟨h1, h2⟩ := (hcond x y).mp hxy
      rw [if_pos hxy, if_pos h1, if_pos h2, jchar_split m n x]
    · rw [if_neg hxy]
      rcases not_and_or.mp ((hcond x y).not.mp hxy) with h1 | h1
      · rw [if_neg h1, zero_mul]
      · rw [if_neg h1, mul_zero]
  have hdouble : circleWeightZ (m * n)
      = ∑ z : ZMod (m * n) × ZMod (m * n),
          (if z.1 ^ 2 + z.2 ^ 2 = 1 then jchar (m * n) z.1 else 0) := by
    rw [circleWeightZ]
    exact (Fintype.sum_prod_type (fun z : ZMod (m * n) × ZMod (m * n) =>
      if z.1 ^ 2 + z.2 ^ 2 = 1 then jchar (m * n) z.1 else 0)).symm
  have hEq : ∑ z : ZMod (m * n) × ZMod (m * n), G (f z.1, f z.2) * H (g z.1, g z.2)
      = ∑ w : (ZMod m × ZMod m) × (ZMod n × ZMod n), G w.1 * H w.2 := by
    refine Fintype.sum_equiv ((e.toEquiv.prodCongr e.toEquiv).trans
      (Equiv.prodProdProdComm (ZMod m) (ZMod n) (ZMod m) (ZMod n))) _ _ fun z => ?_
    have hz : ((e.toEquiv.prodCongr e.toEquiv).trans
        (Equiv.prodProdProdComm (ZMod m) (ZMod n) (ZMod m) (ZMod n))) z
        = ((f z.1, f z.2), (g z.1, g z.2)) := by
      simp only [Equiv.prodProdProdComm, Equiv.trans_apply, Equiv.prodCongr_apply,
        Equiv.coe_fn_mk, Prod.mk.injEq]
      exact ⟨⟨hef _, hef _⟩, heg _, heg _⟩
    rw [hz]
  have hGm : circleWeightZ m = ∑ a : ZMod m × ZMod m, G a := by
    rw [circleWeightZ, hG]
    exact (Fintype.sum_prod_type (fun z : ZMod m × ZMod m =>
      if z.1 ^ 2 + z.2 ^ 2 = 1 then jchar m z.1 else 0)).symm
  have hHn : circleWeightZ n = ∑ b : ZMod n × ZMod n, H b := by
    rw [circleWeightZ, hH]
    exact (Fintype.sum_prod_type (fun z : ZMod n × ZMod n =>
      if z.1 ^ 2 + z.2 ^ 2 = 1 then jchar n z.1 else 0)).symm
  rw [hdouble, Finset.sum_congr rfl fun z _ => hterm z, hEq, hGm, hHn,
    Fintype.sum_prod_type, Finset.sum_mul_sum]

/-- For a prime modulus the geometric weight is the character sum `W p`
(this is `circleWeight_eq_W` transported along `jchar_prime`). -/
theorem circleWeightZ_prime (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : circleWeightZ p = W p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  rw [← circleWeight_eq_W p hp, circleWeightZ, circleWeight]
  exact Finset.sum_congr rfl fun x _ =>
    Finset.sum_congr rfl fun y _ => by rw [jchar_prime p x]

/-- **Claim 1 of the experiment, for the geometric statistic**:
`W(N) = W(p)·W(q)` for `N = p q`. -/
theorem circleWeightZ_semiprime {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp : p ≠ 2) (hq : q ≠ 2) : circleWeightZ (p * q) = W p * W q := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  haveI : NeZero q := ⟨(Fact.out : q.Prime).ne_zero⟩
  have hcop : p.Coprime q := (Nat.coprime_primes (Fact.out) (Fact.out)).mpr hpq
  rw [circleWeightZ_mul p q hcop, circleWeightZ_prime p hp, circleWeightZ_prime q hq]

/-- **The Weil floor for the geometric semiprime statistic**: `|W(N)| ≤ 4 √N`. -/
theorem circleWeightZ_semiprime_sq_le {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp : p ≠ 2) (hq : q ≠ 2) :
    (circleWeightZ (p * q)) ^ 2 ≤ 16 * ((p * q : ℕ) : ℤ) := by
  rw [circleWeightZ_semiprime hpq hp hq, ← WZ_semiprime hpq]
  exact WZ_semiprime_sq_le hpq hp hq

/-- If either prime factor is `≡ 3 (mod 4)`, the entire Jacobi-signed count vanishes:
the statistic is blind on a positive-density set of semiprimes. -/
theorem WZ_semiprime_eq_zero_of_three_mod_four {p q : ℕ} [Fact p.Prime] [Fact q.Prime]
    (hpq : p ≠ q) (h : p % 4 = 3 ∨ q % 4 = 3) : WZ (p * q) = 0 := by
  rw [WZ_semiprime hpq]
  rcases h with h | h
  · rw [W_eq_zero_of_three_mod_four p h, zero_mul]
  · rw [W_eq_zero_of_three_mod_four q h, mul_zero]

end JacSign