import MachineLearning.CayleyCensusInvariance

/-!
# Moments, adjacency powers and return dominance for the Cayley census

This file is the analytic/linear-algebraic half of the census project begun in
`Catalog.MachineLearning.CayleyCensusInvariance`.  Three layers are built on top
of the invariance results proved there.

1. **Concatenation (Chapman–Kolmogorov).**  `walkCount_add` expresses
   `walkCount S (m + n) g` as a convolution of two shorter censuses.  This is
   the semigroup law of the census, and it is what makes the census a *moment
   sequence* rather than a mere counting function.

2. **Return dominance.**  `walkCount_two_mul_le_walkCount_two_mul_one`:
   for an inversion-closed connection set the even-length census is maximised at
   the identity, `walkCount S (2n) g ≤ walkCount S (2n) 1`.  The proof genuinely
   *uses* the inversion symmetry (`walkCount_inv`) — without it the statement is
   false for directed connection sets — combined with the discrete
   Cauchy–Schwarz inequality `2ab ≤ a² + b²` over `ℕ`.
   The identity `walkCount_two_mul_one_eq_sum_sq`,
   `walkCount S (2n) 1 = ∑ h, walkCount S n h ^ 2`, is the second-moment form.

3. **Adjacency bridge.**  `walkCount_eq_adj_pow` identifies the census with
   entries of powers of the Cayley adjacency matrix, `adj_isSymm` shows that
   inversion-closedness is exactly symmetry of that matrix, and `trace_adj_pow`
   gives the trace formula `tr(Aⁿ) = |G| · walkCount S n 1`, the discrete
   analogue of a heat-kernel trace.

## Main results

* `walkCount_add`
* `walkCount_two_mul_one_eq_sum_sq`
* `walkCount_two_mul_le_walkCount_two_mul_one`
* `walkCount_eq_adj_pow`, `adj_isSymm`, `trace_adj_pow`
-/

namespace CayleyCensus

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- Discrete Cauchy–Schwarz in one variable, over `ℕ` (where `(a - b)^2 ≥ 0` is
unavailable, so we pass through `ℤ`). -/
theorem two_mul_mul_le_sq_add_sq (a b : ℕ) : 2 * (a * b) ≤ a ^ 2 + b ^ 2 := by
  have hz : (0 : ℤ) ≤ ((a : ℤ) - (b : ℤ)) ^ 2 := sq_nonneg _
  have hint : (2 * (a * b) : ℤ) ≤ (a : ℤ) ^ 2 + (b : ℤ) ^ 2 := by nlinarith
  exact_mod_cast hint

/-! ### The concatenation (semigroup) law -/

/-- **Chapman–Kolmogorov for the Cayley census.**  A word of length `m + n`
factors uniquely as a word of length `m` reaching some `h`, followed by a word
of length `n` from `h` to `g`. -/
theorem walkCount_add (S : Finset G) (m n : ℕ) (g : G) :
    walkCount S (m + n) g = ∑ h : G, walkCount S m h * walkCount S n (h⁻¹ * g) := by
  induction m generalizing g with
  | zero =>
      simp only [Nat.zero_add, walkCount_zero, ite_mul, one_mul, zero_mul]
      rw [Finset.sum_ite_eq' Finset.univ (1 : G)]
      simp
  | succ m ih =>
      have hsucc : m + 1 + n = (m + n) + 1 := by omega
      rw [hsucc, walkCount_succ]
      have hstep : ∀ s : G, walkCount S (m + n) (s⁻¹ * g)
          = ∑ h : G, walkCount S m h * walkCount S n (h⁻¹ * (s⁻¹ * g)) :=
        fun s => ih _
      rw [Finset.sum_congr rfl (fun s _ => hstep s)]
      -- expand the right-hand side and exchange the two summations
      have hRHS : ∑ h : G, walkCount S (m + 1) h * walkCount S n (h⁻¹ * g)
          = ∑ s ∈ S, ∑ h : G, walkCount S m (s⁻¹ * h) * walkCount S n (h⁻¹ * g) := by
        simp only [walkCount_succ, Finset.sum_mul]
        rw [Finset.sum_comm]
      rw [hRHS]
      refine Finset.sum_congr rfl fun s _ => ?_
      refine (Fintype.sum_equiv (Equiv.mulLeft s⁻¹) _ _ fun h => ?_).symm
      have h2 : (s⁻¹ * h)⁻¹ * (s⁻¹ * g) = h⁻¹ * g := by group
      simp only [Equiv.coe_mulLeft]
      rw [h2]

/-- Second-moment form of the return count: for an inversion-closed connection
set, the number of closed walks of length `2n` at the identity is the squared
`ℓ²`-norm of the length-`n` census row. -/
theorem walkCount_two_mul_one_eq_sum_sq {S : Finset G} (hS : InvClosed S) (n : ℕ) :
    walkCount S (2 * n) (1 : G) = ∑ h : G, walkCount S n h ^ 2 := by
  have h2 : 2 * n = n + n := by ring
  rw [h2, walkCount_add]
  refine Finset.sum_congr rfl fun h _ => ?_
  rw [mul_one, walkCount_inv hS, sq]

/-- **Return dominance.**  For an inversion-closed connection set the even-length
census is maximised at the identity.  The two ingredients are the inversion
symmetry of the census and the elementary inequality `2ab ≤ a² + b²`. -/
theorem walkCount_two_mul_le_walkCount_two_mul_one {S : Finset G} (hS : InvClosed S)
    (n : ℕ) (g : G) : walkCount S (2 * n) g ≤ walkCount S (2 * n) (1 : G) := by
  set a : G → ℕ := fun h => walkCount S n h with ha
  set b : G → ℕ := fun h => walkCount S n (g⁻¹ * h) with hb
  have hsplit : 2 * n = n + n := by ring
  have hg : walkCount S (2 * n) g = ∑ h : G, a h * b h := by
    rw [hsplit, walkCount_add]
    refine Finset.sum_congr rfl fun h _ => ?_
    have hinv : h⁻¹ * g = (g⁻¹ * h)⁻¹ := by group
    rw [ha, hb, hinv, walkCount_inv hS]
  have h1 : walkCount S (2 * n) (1 : G) = ∑ h : G, a h ^ 2 :=
    walkCount_two_mul_one_eq_sum_sq hS n
  -- the two `ℓ²`-masses agree, because `b` is a translate of `a`
  have hshift : ∑ h : G, b h ^ 2 = ∑ h : G, a h ^ 2 :=
    Fintype.sum_equiv (Equiv.mulLeft g⁻¹) _ _ fun h => by simp [ha, hb]
  have hCS : 2 * ∑ h : G, a h * b h ≤ 2 * ∑ h : G, a h ^ 2 := by
    have hterm : ∀ h : G, 2 * (a h * b h) ≤ a h ^ 2 + b h ^ 2 :=
      fun h => two_mul_mul_le_sq_add_sq (a h) (b h)
    calc 2 * ∑ h : G, a h * b h = ∑ h : G, 2 * (a h * b h) := by
            rw [Finset.mul_sum]
      _ ≤ ∑ h : G, (a h ^ 2 + b h ^ 2) := Finset.sum_le_sum fun h _ => hterm h
      _ = (∑ h : G, a h ^ 2) + ∑ h : G, b h ^ 2 := by rw [Finset.sum_add_distrib]
      _ = 2 * ∑ h : G, a h ^ 2 := by rw [hshift]; ring
  rw [hg, h1]
  omega

/-! ### The adjacency-matrix bridge -/

/-- The adjacency matrix of the Cayley graph `Cay(G, S)`: there is an edge from
`x` to `y` exactly when `x⁻¹ y ∈ S`. -/
def adj (S : Finset G) : Matrix G G ℕ := fun x y => if x⁻¹ * y ∈ S then 1 else 0

omit [Group G] in
/-- Collapsing a `0/1`-weighted sum over the whole group to a sum over `S`. -/
theorem sum_indicator_mul (S : Finset G) (f : G → ℕ) :
    ∑ s : G, (if s ∈ S then 1 else 0) * f s = ∑ s ∈ S, f s := by
  simp [ite_mul, Finset.sum_ite_mem]

omit [Fintype G] in
/-- Inversion-closedness of the connection set is precisely symmetry of the
adjacency matrix; this is the linear-algebraic shadow of `walkCount_inv`. -/
theorem adj_isSymm {S : Finset G} (hS : InvClosed S) : (adj S).IsSymm := by
  ext x y
  show adj S y x = adj S x y
  unfold adj
  by_cases h : x⁻¹ * y ∈ S
  · have : y⁻¹ * x ∈ S := by
      have hrw : y⁻¹ * x = (x⁻¹ * y)⁻¹ := by group
      rw [hrw]; exact hS h
    simp [h, this]
  · have : y⁻¹ * x ∉ S := by
      intro hc
      apply h
      have hrw : x⁻¹ * y = (y⁻¹ * x)⁻¹ := by group
      rw [hrw]; exact hS hc
    simp [h, this]

/-- **The census is the entry sequence of the adjacency powers.** -/
theorem walkCount_eq_adj_pow (S : Finset G) (n : ℕ) (x y : G) :
    (adj S ^ n) x y = walkCount S n (x⁻¹ * y) := by
  induction n generalizing x y with
  | zero =>
      simp only [pow_zero, Matrix.one_apply, walkCount_zero, inv_mul_eq_one]
  | succ n ih =>
      rw [pow_succ']
      rw [Matrix.mul_apply]
      have hstep : ∀ z : G, adj S x z * (adj S ^ n) z y
          = (if x⁻¹ * z ∈ S then 1 else 0) * walkCount S n (z⁻¹ * y) := by
        intro z; rw [ih]; rfl
      rw [Finset.sum_congr rfl (fun z _ => hstep z)]
      have hre : ∑ z : G, (if x⁻¹ * z ∈ S then 1 else 0) * walkCount S n (z⁻¹ * y)
          = ∑ s : G, (if s ∈ S then 1 else 0) * walkCount S n (s⁻¹ * (x⁻¹ * y)) := by
        refine (Fintype.sum_equiv (Equiv.mulLeft x) _ _ fun s => ?_).symm
        have h1 : x⁻¹ * (x * s) = s := by group
        have h2 : (x * s)⁻¹ * y = s⁻¹ * (x⁻¹ * y) := by group
        simp only [Equiv.coe_mulLeft, h1, h2]
      rw [hre, walkCount_succ]
      exact sum_indicator_mul S (fun s => walkCount S n (s⁻¹ * (x⁻¹ * y)))

/-- **Trace formula.**  Because the Cayley graph is vertex-transitive, the number
of closed walks of length `n` is `|G|` times the return count at the identity.
This is the discrete analogue of a heat-kernel trace, and it shows that the
single census entry `walkCount S n 1` already determines all spectral moments of
the adjacency matrix. -/
theorem trace_adj_pow (S : Finset G) (n : ℕ) :
    Matrix.trace (adj S ^ n) = Fintype.card G * walkCount S n (1 : G) := by
  rw [Matrix.trace]
  simp only [Matrix.diag_apply]
  have hdiag : ∀ x : G, (adj S ^ n) x x = walkCount S n (1 : G) := by
    intro x
    rw [walkCount_eq_adj_pow, inv_mul_cancel]
  rw [Finset.sum_congr rfl (fun x _ => hdiag x)]
  rw [Finset.sum_const, smul_eq_mul, Finset.card_univ]

end CayleyCensus