import Mathlib

/-!
# Hyperbolic Arithmetic on the Poincaré Disk

## Novel Mathematical Contributions

This module develops the algebraic and geometric foundations of arithmetic on the
Poincaré disk model of hyperbolic geometry. We formalize:

1. **Blaschke disk-preservation identity**: `‖b̄z+ā‖²(1 - ‖(az+b)/(b̄z+ā)‖²) = 1 - ‖z‖²`
2. **Einstein addition** as a group operation on (-1,1) with closure
3. **The rapidity isomorphism**: `artanh` linearizes Einstein addition
4. **Chebyshev-trace duality**: `T_n(cos θ) = cos(nθ)` and composition
5. **Orbit discreteness** for integer lattices

## Key Insight

The trace-distance duality `cosh(d(0, γ·0)) = |tr(γ)|/2` connects algebraic
and geometric data through Chebyshev polynomials. The Chebyshev composition
`T_m ∘ T_n = T_{mn}` on [-1,1] reflects the multiplicative structure of
orbit iteration in hyperbolic space.
-/

noncomputable section

open Real Complex Finset BigOperators

/-! ## Part 1: Blaschke Factor Identity — the Engine of Disk Geometry

A **Blaschke factor** (disk automorphism) has the form `z ↦ (az+b)/(b̄z+ā)`
where `|a|² - |b|² = 1`. The fundamental identity

  `‖b̄z + ā‖² · (1 - ‖(az+b)/(b̄z+ā)‖²) = (|a|² - |b|²) · (1 - ‖z‖²)`

shows that disk automorphisms uniformly scale the "distance to boundary"
factor `1 - ‖z‖²`. When `|a|²-|b|²=1`, this simplifies to `1 - ‖z‖²`,
proving the map preserves the disk. -/

/-- Predicate: z is in the open unit disk. -/
def InUnitDisk (z : ℂ) : Prop := Complex.normSq z < 1

/-
Key algebraic identity: `normSq(a + b*conj(z)) - normSq(a*z + b) = (|a|²-|b|²)(1-|z|²)`.
    This is the core computation underlying all disk automorphism results.
    Both cross terms `a·conj(b)·z + conj(a)·b·conj(z)` cancel in the difference.
-/
theorem blaschke_normSq_difference (a b z : ℂ) :
    Complex.normSq (a + b * starRingEnd ℂ z) - Complex.normSq (a * z + b) =
    (Complex.normSq a - Complex.normSq b) * (1 - Complex.normSq z) := by
  simpa [ Complex.normSq, Complex.ext_iff ] using by ring;

/-
The Blaschke disk-preservation identity:
    `‖b̄z+ā‖² · (1 - ‖(az+b)/(b̄z+ā)‖²) = (|a|²-|b|²)(1-|z|²)`.

    When `|a|²-|b|²=1`, this shows that the map `z ↦ (az+b)/(b̄z+ā)` preserves
    the disk: if `‖z‖² < 1` then `‖(az+b)/(b̄z+ā)‖² < 1`.
-/
theorem blaschke_disk_identity (a b z : ℂ)
    (h_denom : starRingEnd ℂ b * z + starRingEnd ℂ a ≠ 0) :
    Complex.normSq (starRingEnd ℂ b * z + starRingEnd ℂ a) *
      (1 - Complex.normSq ((a * z + b) / (starRingEnd ℂ b * z + starRingEnd ℂ a))) =
    (Complex.normSq a - Complex.normSq b) * (1 - Complex.normSq z) := by
  convert blaschke_normSq_difference a b z using 1;
  simp +decide [ mul_sub, mul_div_cancel₀, Complex.normSq_eq_norm_sq, h_denom ];
  rw [ ← Complex.norm_conj ] ; simp +decide [ add_comm, mul_comm ]

/-! ## Part 2: Einstein Addition — Hyperbolic Arithmetic on the Real Line -/

/-- Einstein addition (relativistic velocity addition). -/
def einsteinAdd (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

/-- Predicate for the open interval (-1, 1). -/
def InOpenInterval (x : ℝ) : Prop := |x| < 1

/-- The denominator `1 + ab` is positive when both `a, b ∈ (-1, 1)`. -/
theorem einstein_denom_pos {a b : ℝ} (ha : InOpenInterval a) (hb : InOpenInterval b) :
    0 < 1 + a * b := by
  nlinarith [abs_lt.mp ha, abs_lt.mp hb]

/-- The fundamental factorization: `(1+ab)² - (a+b)² = (1-a²)(1-b²)`. -/
theorem einstein_fundamental_identity (a b : ℝ) :
    (1 + a * b) ^ 2 - (a + b) ^ 2 = (1 - a ^ 2) * (1 - b ^ 2) := by ring

/-- Einstein addition is closed on (-1, 1). -/
theorem einstein_add_closure {a b : ℝ} (ha : InOpenInterval a) (hb : InOpenInterval b) :
    InOpenInterval (einsteinAdd a b) := by
  exact abs_lt.mpr ⟨by rw [einsteinAdd]; rw [lt_div_iff₀] <;>
    nlinarith [abs_lt.mp ha, abs_lt.mp hb],
    by rw [einsteinAdd]; rw [div_lt_iff₀] <;>
    nlinarith [abs_lt.mp ha, abs_lt.mp hb]⟩

/-- Einstein addition is associative. -/
theorem einstein_add_assoc (a b c : ℝ)
    (hab : 1 + a * b ≠ 0) (hbc : 1 + b * c ≠ 0)
    (h_left : 1 + einsteinAdd a b * c ≠ 0)
    (h_right : 1 + a * einsteinAdd b c ≠ 0) :
    einsteinAdd (einsteinAdd a b) c = einsteinAdd a (einsteinAdd b c) := by
  grind +locals

/-- Einstein addition is commutative. -/
theorem einstein_add_comm (a b : ℝ) : einsteinAdd a b = einsteinAdd b a := by
  unfold einsteinAdd; ring

/-- Zero is the identity for Einstein addition. -/
theorem einstein_add_zero (a : ℝ) : einsteinAdd a 0 = a := by
  unfold einsteinAdd; simp [div_one]

/-- The inverse for Einstein addition is negation: `a ⊕ (-a) = 0`. -/
theorem einstein_add_neg (a : ℝ) (h : 1 + a * (-a) ≠ 0) :
    einsteinAdd a (-a) = 0 := by
  unfold einsteinAdd; ring

/-! ## Part 3: The Rapidity Isomorphism -/

/-- The rapidity function (inverse hyperbolic tangent). -/
def rapidity (x : ℝ) : ℝ := (1 / 2) * Real.log ((1 + x) / (1 - x))

/-- **The Rapidity Homomorphism Theorem**: `rapidity(a ⊕ b) = rapidity(a) + rapidity(b)`.
    This shows that hyperbolic arithmetic IS ordinary arithmetic, viewed through the
    curved lens of the rapidity map. The proof uses logarithmic identities and the
    algebraic factorization `(1+ab+a+b)/(1+ab-a-b) = (1+a)(1+b)/((1-a)(1-b))`. -/
theorem rapidity_einstein_homomorphism {a b : ℝ} (ha : InOpenInterval a)
    (hb : InOpenInterval b) :
    rapidity (einsteinAdd a b) = rapidity a + rapidity b := by
  unfold rapidity einsteinAdd
  rw [← mul_add, ← Real.log_mul]
  · rw [div_mul_div_comm]
    rw [one_add_div, one_sub_div] <;>
      norm_num [show 1 + a * b ≠ 0 from by nlinarith [abs_lt.mp ha, abs_lt.mp hb]]
    rw [div_div_div_cancel_right₀] <;> ring
    nlinarith [abs_lt.mp ha, abs_lt.mp hb]
  · exact div_ne_zero (by linarith [abs_lt.mp ha]) (by linarith [abs_lt.mp ha])
  · exact div_ne_zero (by linarith [abs_lt.mp ha, abs_lt.mp hb])
      (by linarith [abs_lt.mp ha, abs_lt.mp hb])

/-! ## Part 4: Chebyshev Polynomials and the Trace-Distance Duality

For γ ∈ SL₂(ℤ) with trace t, the n-th power γⁿ has trace `2·T_n(t/2)` where
T_n is the Chebyshev polynomial. Since `cosh(d(0, γ·0)) = |tr(γ)|/2`, this
means distances along a hyperbolic geodesic follow the Chebyshev recurrence.

The composition formula `T_m(T_n(cos θ)) = T_{mn}(cos θ)` reflects the multiplicative
structure: iterating n times then m times equals iterating mn times. -/

/-- Chebyshev polynomials of the first kind, defined by recurrence. -/
def chebyshevT : ℕ → ℝ → ℝ
  | 0, _ => 1
  | 1, x => x
  | n + 2, x => 2 * x * chebyshevT (n + 1) x - chebyshevT n x

@[simp] theorem chebyshevT_zero (x : ℝ) : chebyshevT 0 x = 1 := rfl
@[simp] theorem chebyshevT_one (x : ℝ) : chebyshevT 1 x = x := rfl

theorem chebyshevT_succ_succ (n : ℕ) (x : ℝ) :
    chebyshevT (n + 2) x = 2 * x * chebyshevT (n + 1) x - chebyshevT n x := rfl

/-- `T₂(x) = 2x² - 1` — connects to the double angle formula `cos(2θ) = 2cos²θ - 1`. -/
theorem chebyshevT_two (x : ℝ) : chebyshevT 2 x = 2 * x ^ 2 - 1 := by
  simp [chebyshevT_succ_succ]; ring

/-- **Chebyshev-Cosine Duality**: `T_n(cos θ) = cos(nθ)`.
    The proof is by strong induction, using the product-to-sum formula
    `2cos(α)cos(β) = cos(α-β) + cos(α+β)` at the inductive step. -/
theorem chebyshevT_cos (n : ℕ) (θ : ℝ) :
    chebyshevT n (Real.cos θ) = Real.cos (n * θ) := by
  induction' n using Nat.strong_induction_on with n ih
  rcases n with (_ | _ | n) <;> simp_all +decide [chebyshevT]
  rw [(by ring : (n + 1 + 1 : ℝ) * θ = (n + 1) * θ + θ),
      (by ring : (n : ℝ) * θ = (n + 1) * θ - θ),
      Real.cos_add, Real.cos_sub]; ring

/-- **Chebyshev Composition**: `T_m(T_n(cos θ)) = T_{mn}(cos θ)`.
    This reflects the group-theoretic fact that iterating n times then m times
    equals iterating mn times along a geodesic. -/
theorem chebyshevT_comp (m n : ℕ) (θ : ℝ) :
    chebyshevT m (chebyshevT n (Real.cos θ)) = chebyshevT (m * n) (Real.cos θ) := by
  convert chebyshevT_cos m (n * θ) using 1
  · rw [← chebyshevT_cos]
  · convert chebyshevT_cos (m * n) θ using 1; push_cast; ring

/-! ## Part 5: Orbit Discreteness -/

/-- A subset of ℝ is discrete if every bounded region contains finitely many points. -/
def IsDiscreteSubset (S : Set ℝ) : Prop :=
  ∀ R : ℝ, R > 0 → Set.Finite {x ∈ S | |x| < R}

/-- The integers form a discrete subset of ℝ — the prototype for orbit discreteness. -/
theorem int_is_discrete : IsDiscreteSubset {x : ℝ | ∃ n : ℤ, x = ↑n} := by
  intro R hR
  rw [show {x : ℝ | ∃ n : ℤ, x = n} = Set.range (fun n : ℤ => (n : ℝ)) by ext; aesop]
  exact Set.Finite.subset (Set.toFinite (Finset.image (fun n : ℤ => (n : ℝ))
    (Finset.Icc ⌈-R⌉ ⌊R⌋))) fun x hx => by
    rcases hx with ⟨⟨n, rfl⟩, hn⟩
    exact Finset.mem_image.mpr ⟨n, Finset.mem_Icc.mpr
      ⟨Int.ceil_le.mpr (by linarith [abs_lt.mp hn]),
       Int.le_floor.mpr (by linarith [abs_lt.mp hn])⟩, rfl⟩

/-- Scaled integer lattices are discrete — applies to any orbit `{c·n : n ∈ ℤ}`. -/
theorem scaled_int_is_discrete (c : ℝ) (hc : c ≠ 0) :
    IsDiscreteSubset {x : ℝ | ∃ n : ℤ, x = c * ↑n} := by
  intro R hR
  exact Set.Finite.subset (Set.toFinite (Finset.image (fun n : ℤ => c * n)
    (Finset.Icc (-⌊R / |c|⌋) ⌊R / |c|⌋))) fun x hx => by
    rcases hx with ⟨⟨n, rfl⟩, hn⟩
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_Icc]
    exact ⟨n, ⟨neg_le_of_abs_le <| Int.le_floor.2 <| by
      push_cast; rw [le_div_iff₀ (abs_pos.2 hc)]; rw [abs_mul] at hn; linarith,
      le_of_abs_le <| Int.le_floor.2 <| by
      push_cast; rw [le_div_iff₀ (abs_pos.2 hc)]; rw [abs_mul] at hn; linarith⟩, rfl⟩

/-! ## Part 6: Conjectures and Future Directions -/

/-
**Conjecture (Chebyshev Polynomial Composition for All Reals)**:
    `T_m(T_n(x)) = T_{mn}(x)` holds for ALL `x ∈ ℝ`, not just `x = cos θ`.

    This is true because both sides are polynomial functions that agree on
    `[-1, 1]` (which has infinitely many points), hence they agree everywhere.
    A formal proof requires connecting our `chebyshevT` to Mathlib's polynomial
    framework and using the polynomial identity principle.
-/
theorem chebyshevT_comp_general (m n : ℕ) (x : ℝ) :
    chebyshevT m (chebyshevT n x) = chebyshevT (m * n) x := by
  -- By definition of Chebyshev polynomials, we know that $T_n(T_m(x)) = T_{mn}(x)$ for all $x$.
  have h_poly_eq : ∀ m n x, chebyshevT m (chebyshevT n x) = chebyshevT (m * n) x := by
    intros m n x
    have h_poly_eq : ∀ θ : ℝ, chebyshevT m (chebyshevT n (Real.cos θ)) = chebyshevT (m * n) (Real.cos θ) := by
      grind +suggestions;
    -- By definition of Chebyshev polynomials, we know that $T_n(x)$ is a polynomial of degree $n$.
    have h_poly_deg : ∀ n : ℕ, ∃ p : Polynomial ℝ, p.degree = n ∧ ∀ x : ℝ, chebyshevT n x = p.eval x := by
      intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ chebyshevT ] ;
      · exact ⟨ 1, Polynomial.degree_one, fun x => by norm_num ⟩;
      · exact ⟨ Polynomial.X, Polynomial.degree_X, fun x => by norm_num ⟩;
      · obtain ⟨ p, hp₁, hp₂ ⟩ := ih ( n + 1 ) ( by linarith ) ; obtain ⟨ q, hq₁, hq₂ ⟩ := ih n ( by linarith ) ; use 2 * Polynomial.X * p - q; simp_all +decide [ Polynomial.degree_sub_eq_left_of_degree_lt ] ;
        rw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num [ hp₁, hq₁ ];
        · erw [ Polynomial.degree_C ] <;> norm_num ; ring;
        · erw [ Polynomial.degree_C ] <;> norm_cast ; simp +arith +decide;
    obtain ⟨ p, hp_deg, hp_eval ⟩ := h_poly_deg m
    obtain ⟨ q, hq_deg, hq_eval ⟩ := h_poly_deg n
    obtain ⟨ r, hr_deg, hr_eval ⟩ := h_poly_deg ( m * n );
    -- Since $p$, $q$, and $r$ are polynomials, and $p(q(x)) = r(x)$ for all $x \in [-1, 1]$, it follows that $p(q(x)) = r(x)$ for all $x \in \mathbb{R}$.
    have h_poly_eq_all : p.comp q = r := by
      have h_poly_eq_all : Set.Infinite {x : ℝ | p.eval (q.eval x) = r.eval x} := by
        exact Set.Infinite.mono ( fun x hx => by have := h_poly_eq ( Real.arccos x ) ; rw [ Real.cos_arccos hx.1 hx.2 ] at this; aesop ) ( Set.Icc_infinite ( show -1 < 1 by norm_num ) );
      exact Classical.not_not.1 fun h => h_poly_eq_all <| Set.Finite.subset ( p.comp q - r |> Polynomial.roots |> Multiset.toFinset |> Finset.finite_toSet ) fun x hx => by simp_all +decide [ sub_eq_iff_eq_add ] ;
    aesop;
  exact h_poly_eq m n x

end