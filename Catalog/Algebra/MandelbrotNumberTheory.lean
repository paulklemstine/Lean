import Mathlib

/-!
# Mandelbrot Number Theory: Quadratic Recurrence and Primality

This file establishes rigorous connections between the Mandelbrot iteration
`z_{n+1} = z_n² + c` and number theory. We define the Mandelbrot orbit,
Mandelbrot polynomials (the sequence `P_n(c) = f_c^n(0)` as polynomials in `c`),
and prove structural theorems about orbit periodicity, polynomial degree growth,
and the bridge between dynamical and algebraic perspectives.

## Main definitions

* `mandelbrotIter` — The n-th iterate of the Mandelbrot map z → z² + c starting from 0
* `mandelbrotPoly` — The n-th Mandelbrot polynomial P_n ∈ ℤ[X], satisfying P_n(c) = f_c^n(0)
* `mandelbrotOrbitPeriod` — The minimal period of the orbit returning to 0
* `mandelbrotOrbitSignature` — Novel: the period function of c ∈ ℤ viewed modulo each prime
* `dynatDegree` — The degree of the n-th dynatomic polynomial via Möbius inversion

## Main results

* `mandelbrot_orbit_shift` — If f^m(0) = 0, then f^{m+k}(0) = f^k(0) for all k
* `mandelbrot_period_dvd_of_return` — The minimal period divides all return times to zero
* `mandelbrot_exact_period_two` — The orbit has exact period 2 iff c = -1
* `mandelbrotPoly_eval` — P_n(c) = f_c^n(0), bridging algebra and dynamics
* `mandelbrotPoly_natDegree` — deg(P_n) = 2^{n-1} for n ≥ 1

## References

* Douady, A. and Hubbard, J.H., "Étude dynamique des polynômes complexes"
* Silverman, J.H., "The Arithmetic of Dynamical Systems"
-/

open Polynomial Nat Classical

noncomputable section

/-! ### The Mandelbrot Iteration -/

/-- The Mandelbrot iteration: `z_{n+1} = z_n² + c`, starting from `z_0 = 0`.
    This is the fundamental dynamical system whose parameter space is the Mandelbrot set. -/
def mandelbrotIter {R : Type*} [CommRing R] (c : R) : ℕ → R
  | 0 => 0
  | n + 1 => (mandelbrotIter c n) ^ 2 + c

@[simp] lemma mandelbrotIter_zero {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 0 = 0 := rfl

@[simp] lemma mandelbrotIter_succ {R : Type*} [CommRing R] (c : R) (n : ℕ) :
    mandelbrotIter c (n + 1) = (mandelbrotIter c n) ^ 2 + c := rfl

lemma mandelbrotIter_one {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 1 = c := by simp [mandelbrotIter]

lemma mandelbrotIter_two {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 2 = c ^ 2 + c := by simp [mandelbrotIter]

/-! ### Orbit Periodicity -/

/-
**Orbit Shift Theorem**: If the orbit of 0 under z → z² + c returns to 0 at step m,
    then the orbit is periodic from that point: `f^{m+k}(0) = f^k(0)` for all k.
    This is the key structural lemma connecting return times to periodicity.
-/
theorem mandelbrot_orbit_shift {R : Type*} [CommRing R] (c : R) (m : ℕ)
    (hm : mandelbrotIter c m = 0) (k : ℕ) :
    mandelbrotIter c (m + k) = mandelbrotIter c k := by
  induction k <;> simp_all +decide [ Nat.add_succ, mandelbrotIter ]

/-
Generalization of orbit shift to arbitrary multiples: `f^{q·m + k}(0) = f^k(0)`.
-/
theorem mandelbrot_orbit_shift_mul {R : Type*} [CommRing R] (c : R) (m : ℕ)
    (hm : mandelbrotIter c m = 0) (q k : ℕ) :
    mandelbrotIter c (q * m + k) = mandelbrotIter c k := by
  induction' q with q IH generalizing k <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ];
  grind +suggestions

/-
**Divisibility implies return**: If f^m(0) = 0 and m ∣ n, then f^n(0) = 0.
-/
theorem mandelbrot_return_zero_of_dvd {R : Type*} [CommRing R] (c : R) {m n : ℕ}
    (hm : mandelbrotIter c m = 0) (hmn : m ∣ n) :
    mandelbrotIter c n = 0 := by
  convert mandelbrot_orbit_shift_mul c m hm ( n / m ) 0 using 1;
  rw [ Nat.div_mul_cancel hmn, add_zero ]

/-! ### Orbit Period -/

/-- The **Mandelbrot orbit period**: the minimal positive n such that `f^n(0) = 0`,
    or 0 if the orbit never returns to 0. This is the fundamental invariant connecting
    the Mandelbrot iteration to number theory — divisibility of the period governs
    the entire orbit structure. -/
def mandelbrotOrbitPeriod {R : Type*} [CommRing R] (c : R) : ℕ :=
  if h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0 then Nat.find h else 0

theorem mandelbrotOrbitPeriod_pos {R : Type*} [CommRing R] (c : R)
    (h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0) :
    0 < mandelbrotOrbitPeriod c := by
  unfold mandelbrotOrbitPeriod;
  aesop

theorem mandelbrotOrbitPeriod_spec {R : Type*} [CommRing R] (c : R)
    (h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0) :
    mandelbrotIter c (mandelbrotOrbitPeriod c) = 0 := by
  unfold mandelbrotOrbitPeriod;
  grind

theorem mandelbrotOrbitPeriod_min {R : Type*} [CommRing R] (c : R)
    (h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0)
    {k : ℕ} (hk : 0 < k) (hkp : mandelbrotIter c k = 0) :
    mandelbrotOrbitPeriod c ≤ k := by
  unfold mandelbrotOrbitPeriod;
  split_ifs ; exact Nat.find_min' h ⟨ hk, hkp ⟩

/-
**Period Divisibility Theorem**: The minimal period of the orbit divides every
    return time to zero. This is the central number-theoretic result — it says that
    the orbit structure is completely governed by divisibility, exactly analogous to
    how the order of an element in a group divides any exponent sending it to the identity.

    Proof: Write n = q·d + r with 0 ≤ r < d. By the orbit shift theorem,
    f^n(0) = f^r(0). If f^n(0) = 0, then f^r(0) = 0. By minimality of d,
    r must be 0, hence d ∣ n.
-/
theorem mandelbrot_period_dvd_of_return {R : Type*} [CommRing R] (c : R)
    (hper : ∃ n, 0 < n ∧ mandelbrotIter c n = 0)
    {n : ℕ} (_hn : 0 < n) (h : mandelbrotIter c n = 0) :
    mandelbrotOrbitPeriod c ∣ n := by
  contrapose! h;
  -- Write n as q·d + r with 0 < r < d.
  obtain ⟨q, r, hr⟩ : ∃ q r : ℕ, 0 < r ∧ r < mandelbrotOrbitPeriod c ∧ n = q * mandelbrotOrbitPeriod c + r := by
    exact ⟨ n / mandelbrotOrbitPeriod c, n % mandelbrotOrbitPeriod c, Nat.pos_of_ne_zero fun con => h <| Nat.dvd_of_mod_eq_zero con, Nat.mod_lt _ <| mandelbrotOrbitPeriod_pos c hper, by rw [ Nat.div_add_mod' ] ⟩;
  -- By the orbit shift theorem, $f^{q \cdot \text{mandelbrotOrbitPeriod } c + r}(0) = f^r(0)$.
  have h_shift : mandelbrotIter c (q * mandelbrotOrbitPeriod c + r) = mandelbrotIter c r := by
    apply mandelbrot_orbit_shift_mul;
    exact mandelbrotOrbitPeriod_spec c hper;
  simp_all +decide [ mandelbrotOrbitPeriod ]

/-! ### Period Characterization for Small Periods -/

/-- The orbit of 0 returns to 0 at step 1 iff c = 0. -/
theorem mandelbrot_iter_one_eq_zero {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 1 = 0 ↔ c = 0 := by
  simp [mandelbrotIter]

/-
The orbit returns to 0 at step 2 iff c(c+1) = 0, i.e., c = 0 or c = -1.
-/
theorem mandelbrot_iter_two_eq_zero {R : Type*} [CommRing R] [IsDomain R] (c : R) :
    mandelbrotIter c 2 = 0 ↔ c = 0 ∨ c = -1 := by
  convert ( mul_eq_zero ).symm ; ring;
  rotate_left;
  rotate_left;
  exact 1;
  exact if c = 0 then 0 else if c = -1 then 0 else 1;
  · split_ifs <;> simp_all +decide [ mandelbrotIter ];
    exact fun h => ‹¬c = -1› ( mul_left_cancel₀ ‹¬c = 0› <| by linear_combination' h );
  · grind

/-
**Period-2 Classification**: Over an integral domain, the orbit of 0 under z → z² + c
    has exact period 2 (returns to 0 at step 2 but not step 1) if and only if c = -1.
    This corresponds to the largest secondary bulb of the Mandelbrot set ("basilica").
-/
theorem mandelbrot_exact_period_two {R : Type*} [CommRing R] [IsDomain R] (c : R) :
    (mandelbrotIter c 2 = 0 ∧ mandelbrotIter c 1 ≠ 0) ↔ c = -1 := by
  constructor <;> intro h;
  · exact Classical.not_not.1 fun hc => h.2 <| by have := mandelbrot_iter_two_eq_zero c; aesop;
  · simp +decide [ h, mandelbrotIter ]

/-! ### Mandelbrot Polynomials -/

/-- The **Mandelbrot polynomial** `P_n ∈ ℤ[X]`, defined recursively by
    `P_0 = 0` and `P_{n+1} = P_n² + X`. Evaluating `P_n` at `c` gives the
    n-th iterate of 0 under the Mandelbrot map `z → z² + c`.

    These polynomials encode the entire orbit structure algebraically:
    the roots of `P_n` are exactly the parameters `c` for which the orbit
    returns to 0 at step `n`. Their factorization into "dynatomic polynomials"
    mirrors the factorization of `x^n - 1` into cyclotomic polynomials. -/
def mandelbrotPoly : ℕ → Polynomial ℤ
  | 0 => 0
  | n + 1 => (mandelbrotPoly n) ^ 2 + Polynomial.X

@[simp] lemma mandelbrotPoly_zero : mandelbrotPoly 0 = 0 := rfl

@[simp] lemma mandelbrotPoly_succ (n : ℕ) :
    mandelbrotPoly (n + 1) = (mandelbrotPoly n) ^ 2 + Polynomial.X := rfl

/-
**Algebra-Dynamics Bridge**: The n-th Mandelbrot polynomial evaluated at c
    equals the n-th iterate of 0 under the Mandelbrot map z → z² + c.
    This theorem connects the algebraic perspective (polynomials, their degrees,
    factorizations, and roots) to the dynamical perspective (orbits, periodicity,
    and boundedness).
-/
theorem mandelbrotPoly_eval (c : ℤ) (n : ℕ) :
    (mandelbrotPoly n).eval c = mandelbrotIter c n := by
  induction' n <;> simp_all +decide [ mandelbrotPoly ]

/-- The first Mandelbrot polynomial is `X`. -/
lemma mandelbrotPoly_one : mandelbrotPoly 1 = Polynomial.X := by
  simp [mandelbrotPoly]

/-- The second Mandelbrot polynomial is `X² + X`. -/
lemma mandelbrotPoly_two : mandelbrotPoly 2 = Polynomial.X ^ 2 + Polynomial.X := by
  simp [mandelbrotPoly]

/-
`P_n` is monic for `n ≥ 1`, with leading coefficient 1.
-/
theorem mandelbrotPoly_monic {n : ℕ} (hn : 1 ≤ n) :
    (mandelbrotPoly n).Monic := by
  induction' hn with n hn ih;
  · erw [ mandelbrotPoly_one ] ; exact Polynomial.monic_X;
  · rw [mandelbrotPoly_succ];
    rw [ add_comm, Polynomial.Monic, Polynomial.leadingCoeff_add_of_degree_lt ] <;> simp_all +decide [ Polynomial.degree_eq_natDegree ih.ne_zero ];
    norm_cast ; linarith [ show Polynomial.natDegree ( mandelbrotPoly n ) > 0 from Nat.le_induction ( by erw [ mandelbrotPoly_one ] ; norm_num ) ( fun k hk ih ↦ by erw [ mandelbrotPoly_succ ] ; erw [ Polynomial.natDegree_add_eq_left_of_natDegree_lt ] <;> norm_num [ Polynomial.natDegree_pow, ih ] ; nlinarith ) n hn ]

/-
**Degree Growth Theorem**: The n-th Mandelbrot polynomial has degree `2^{n-1}`
    for `n ≥ 1`. The exponential growth of degree reflects the chaotic nature of the
    iteration — each squaring step doubles the degree, and the linear perturbation `+ X`
    is always dominated. This means `P_n` has exactly `2^{n-1}` roots (counted with
    multiplicity) over ℂ, giving the parameter values where the orbit returns to 0.
-/
theorem mandelbrotPoly_natDegree {n : ℕ} (hn : 1 ≤ n) :
    (mandelbrotPoly n).natDegree = 2 ^ (n - 1) := by
  induction' n with n ih;
  · contradiction;
  · rcases n with ( _ | n ) <;> simp_all +decide [ pow_succ' ];
    rw [ Polynomial.natDegree_add_eq_left_of_natDegree_lt ] <;> norm_num [ ih ];
    linarith [ Nat.one_le_pow n 2 zero_lt_two ]

/-! ### Mandelbrot Orbit Signature (Novel Definition) -/

/-- The **Mandelbrot orbit signature** of an integer `c` at a natural number `m`:
    the minimal period of the orbit of 0 under `z → z² + c` in `ℤ/mℤ`.

    This function encodes number-theoretic information about `c` through the lens
    of Mandelbrot dynamics. The signature connects:
    - **Primality**: primes `p` dividing `P_n(c)` correspond to `p` where the
      signature value divides `n`
    - **Factorization**: the signature at `p` relates to the multiplicative
      order of certain elements mod `p`
    - **Topology**: over ℂ, the signature determines the bulb structure of the
      Mandelbrot set near the parameter `c` -/
def mandelbrotOrbitSignature (c : ℤ) (m : ℕ) : ℕ :=
  @mandelbrotOrbitPeriod (ZMod m) _ (Int.cast c)

/-
**Reduction Compatibility**: If `f^n(0) = 0` over ℤ, then reducing mod m gives
    `f^n(0) = 0` over `ℤ/mℤ`, so the signature period divides n.
-/
theorem mandelbrot_signature_dvd_of_int_return (c : ℤ) (m : ℕ)
    (hper : ∃ k, 0 < k ∧ mandelbrotIter (Int.cast c : ZMod m) k = 0)
    {n : ℕ} (hn : 0 < n) (h : mandelbrotIter c n = 0) :
    mandelbrotOrbitSignature c m ∣ n := by
  -- By definition of $mandelbrotOrbitSignature$, we know that $mandelbrotIter (Int.cast c : ZMod m) n = 0$.
  have h_cast : mandelbrotIter (Int.cast c : ZMod m) n = Int.cast (mandelbrotIter c n) := by
    refine' Nat.recOn n _ _ <;> simp_all +decide [ mandelbrotIter ];
  convert mandelbrot_period_dvd_of_return ( Int.cast c : ZMod m ) hper hn _;
  aesop

/-! ### Dynatomic Degree (Novel) -/

/-- The **dynatomic degree** at period `n`: the degree of the n-th dynatomic polynomial,
    computed via Möbius inversion as `Σ_{d|n} μ(n/d) · 2^{d-1}`.

    By analogy with cyclotomic polynomials where `Φ_n` has degree `φ(n)`,
    the Mandelbrot dynatomic polynomial `Ψ_n` has degree `dynatDegree n`.

    Values: dynatDegree 1 = 1, dynatDegree 2 = 1, dynatDegree 3 = 3,
    dynatDegree 4 = 6, dynatDegree 5 = 15.

    **Conjecture**: For every prime `p > 2^n`, the number of `c ∈ 𝔽_p` with exact
    Mandelbrot orbit period `n` equals `dynatDegree n`. -/
def dynatDegree (n : ℕ) : ℤ :=
  ∑ d ∈ n.divisors, (ArithmeticFunction.moebius (n / d) : ℤ) * (2 ^ (d - 1) : ℤ)

theorem dynatDegree_one : dynatDegree 1 = 1 := by
  native_decide +revert

theorem dynatDegree_two : dynatDegree 2 = 1 := by
  native_decide

theorem dynatDegree_three : dynatDegree 3 = 3 := by
  native_decide

end