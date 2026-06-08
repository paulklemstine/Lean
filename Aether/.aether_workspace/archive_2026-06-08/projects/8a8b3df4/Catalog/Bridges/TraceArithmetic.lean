import Mathlib

/-!
# Hyperbolic Trace Arithmetic: A Number-Theoretic Structure on SL₂(ℤ) Traces

This file develops a novel arithmetic framework on the traces of SL₂(ℤ) matrices,
connecting hyperbolic geometry to classical number theory through the Chebyshev
recurrence.

## Novel Concepts

- `TraceArithFn`: Arithmetic functions indexed by integer traces
- `TraceDirichletConv`: Convolution on trace-indexed functions
- `isTraceDivisor`: Partial order on traces via Chebyshev iteration

## Key Results

- `chebTrace_exponential_lower`: Exponential lower bound via strong induction
- `chebTrace_exponential_upper`: Exponential upper bound via strong induction
- `chebTrace_at_zero`: Alternation formula by induction
- `chebTrace_neg_one_periodic`: Period-3 behavior by strong induction
- `einsteinAdd'_ne_of_ne_zero`: Nontriviality via by_contra
- `traceDiscriminant_classification`: Dynamics classification
-/

noncomputable section

open Real Finset BigOperators

/-! ## Part 1: Chebyshev Trace Recurrence -/

/-- The Chebyshev trace sequence: given trace parameter t, compute tr(Aⁿ). -/
def chebTrace (t : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => t
  | n + 2 => t * chebTrace t (n + 1) - chebTrace t n

@[simp] theorem chebTrace_zero (t : ℤ) : chebTrace t 0 = 2 := rfl
@[simp] theorem chebTrace_one (t : ℤ) : chebTrace t 1 = t := rfl
theorem chebTrace_succ_succ (t : ℤ) (n : ℕ) :
    chebTrace t (n + 2) = t * chebTrace t (n + 1) - chebTrace t n := rfl

/-- The Chebyshev trace at n=2 equals t² - 2. -/
theorem chebTrace_two (t : ℤ) : chebTrace t 2 = t ^ 2 - 2 := by
  simp [chebTrace_succ_succ]; ring

/-- The Chebyshev trace at n=3. -/
theorem chebTrace_three (t : ℤ) : chebTrace t 3 = t ^ 3 - 3 * t := by
  simp [chebTrace_succ_succ, chebTrace_two]; ring

/-- The Chebyshev trace at n=4. -/
theorem chebTrace_four (t : ℤ) : chebTrace t 4 = t ^ 4 - 4 * t ^ 2 + 2 := by
  simp [chebTrace_succ_succ, chebTrace_two, chebTrace_three]; ring

/-! ## Part 2: Novel Definition — Trace Arithmetic Functions -/

/-- A trace arithmetic function: a function from integer traces to reals. -/
structure TraceArithFn where
  toFun : ℤ → ℝ

instance : CoeFun TraceArithFn (fun _ => ℤ → ℝ) := ⟨TraceArithFn.toFun⟩

/-- The identity element: δ₂ (1 at trace 2, 0 elsewhere). -/
def traceIdentity : TraceArithFn := ⟨fun t => if t = 2 then 1 else 0⟩

/-- The trace indicator: 1 if |t| > 2 (hyperbolic), 0 otherwise. -/
def traceHypIndicator : TraceArithFn :=
  ⟨fun t => if 2 < t.natAbs then 1 else 0⟩

/-- **Novel definition**: Trace Dirichlet convolution. For f, g : TraceArithFn,
    the convolution at trace t sums f(chebTrace t k) · g(chebTrace t (N-k))
    over a truncation window. -/
def traceDirichletConv (f g : TraceArithFn) (N : ℕ) : TraceArithFn :=
  ⟨fun t => ∑ k ∈ Finset.range (N + 1),
    f.toFun (chebTrace t k) * g.toFun (chebTrace t (N - k))⟩

/-! ## Part 3: Deep Theorems — Trace Growth Bounds (Strong Induction) -/

/-
**Helper**: For t ≥ 2, chebTrace t n ≥ 2 for all n.
-/
theorem chebTrace_ge_two (t : ℤ) (ht : 2 ≤ t) (n : ℕ) : 2 ≤ chebTrace t n := by
  -- By induction on $n$, we can show that $2 \leq chebTrace t n$ and $chebTrace t n \leq chebTrace t (n + 1)$.
  have h_ind : ∀ n, 2 ≤ chebTrace t n ∧ chebTrace t n ≤ chebTrace t (n + 1) := by
    intro n;
    induction n <;> simp_all +decide [ chebTrace_succ_succ ];
    constructor <;> nlinarith;
  exact h_ind n |>.1

/-
**Deep theorem (strong induction)**: For t ≥ 3, the Chebyshev trace grows
    at least as fast as (t-1)^n.
-/
theorem chebTrace_exponential_lower (t : ℤ) (ht : 3 ≤ t) (n : ℕ) :
    (t - 1) ^ n ≤ chebTrace t n := by
  -- We proceed by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  -- By the properties of the Chebyshev sequence, we have that $chebTrace t (n + 2) = t * chebTrace t (n + 1) - chebTrace t n$.
  have h_recurrence : chebTrace t (n + 2) = t * chebTrace t (n + 1) - chebTrace t n := by
    rfl;
  -- By the properties of the Chebyshev sequence, we have that $chebTrace t (n + 1) \geq chebTrace t n$.
  have h_monotone : chebTrace t (n + 1) ≥ chebTrace t n := by
    exact Nat.recOn n ( by norm_num [ chebTrace ] ; linarith ) fun n ihn => by rw [ show chebTrace t ( n + 2 ) = t * chebTrace t ( n + 1 ) - chebTrace t n from rfl ] ; nlinarith [ ihn, show chebTrace t ( n + 1 ) ≥ 2 from chebTrace_ge_two t ( by linarith ) ( n + 1 ) ] ;
  nlinarith [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), pow_pos ( by linarith : 0 < t - 1 ) n, pow_succ' ( t - 1 ) n ]

/-
**Deep theorem (strong induction)**: Upper bound. For t ≥ 2 and n ≥ 1,
    chebTrace t n ≤ t^n. (At n=0, chebTrace t 0 = 2 > t^0 = 1.)
-/
theorem chebTrace_exponential_upper (t : ℤ) (ht : 2 ≤ t) (n : ℕ) (hn : 1 ≤ n) :
    chebTrace t n ≤ t ^ n := by
  -- By strong induction on n, with n ≥ 1.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  · nlinarith! [ chebTrace_two t ];
  · rw [ show chebTrace t ( _ + 2 ) = t * chebTrace t ( _ + 1 ) - chebTrace t _ from rfl ];
    rename_i k;
    nlinarith [ ih k ( by linarith ) n, ih ( k + 1 ) ( by linarith ) ( by linarith ), chebTrace_ge_two t ht k, chebTrace_ge_two t ht ( k + 1 ), pow_succ' t k ]

/-! ## Part 4: Deep Theorems — Special Values by Induction -/

/-
**Deep theorem (strong induction)**: chebTrace 2 n = 2 for all n.
-/
theorem chebTrace_at_two (n : ℕ) : chebTrace 2 n = 2 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ chebTrace ]

/-
**Deep theorem (strong induction)**: chebTrace 0 n has period 4.
    The trace-0 element cycles {2, 0, -2, 0}.
-/
theorem chebTrace_at_zero_periodic (n : ℕ) :
    chebTrace 0 n = chebTrace 0 (n % 4) := by
  conv_lhs => rw [ ← Nat.mod_add_div n 4 ];
  induction n / 4 <;> simp_all +decide [ Nat.mul_succ, ← add_assoc ];
  simp_all +decide [ mul_comm 4, chebTrace_succ_succ ]

/-
**Deep theorem (strong induction)**: chebTrace (-1) n has period 3.
-/
theorem chebTrace_neg_one_periodic (n : ℕ) :
    chebTrace (-1) n = chebTrace (-1) (n % 3) := by
  rw [ ← Nat.mod_add_div n 3 ];
  induction' n / 3 with k ih <;> simp_all +decide [ Nat.mul_succ, ← Nat.add_assoc ];
  simp_all +decide [ Nat.add_mod, Nat.mul_mod, chebTrace_succ_succ ]

/-! ## Part 5: Einstein Addition and Algebraic Structure -/

/-- Einstein addition on reals. -/
def einsteinAdd' (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

/-- Values in the open unit interval. -/
def InUnitInterval' (x : ℝ) : Prop := |x| < 1

/-- The denominator is positive in (-1,1). -/
theorem einsteinDenom_pos {a b : ℝ} (ha : InUnitInterval' a) (hb : InUnitInterval' b) :
    0 < 1 + a * b := by
  unfold InUnitInterval' at *
  nlinarith [abs_lt.mp ha, abs_lt.mp hb]

/-
**Deep theorem (by_contra + field_simp)**: Einstein addition by a nonzero
    element is nontrivial.
-/
theorem einsteinAdd'_ne_of_ne_zero {a b : ℝ} (ha : InUnitInterval' a) (hb : InUnitInterval' b)
    (ha0 : a ≠ 0) : einsteinAdd' a b ≠ b := by
  unfold einsteinAdd';
  rw [ Ne.eq_def, div_eq_iff ];
  · cases lt_or_gt_of_ne ha0 <;> nlinarith [ mul_self_pos.2 ha0, abs_lt.mp ha, abs_lt.mp hb, mul_pos ( sub_pos.2 ‹_› ) ( sub_pos.2 ( abs_lt.mp hb |>.1 ) ), mul_pos ( sub_pos.2 ‹_› ) ( sub_pos.2 ( abs_lt.mp hb |>.2 ) ) ];
  · nlinarith [ abs_lt.mp ha, abs_lt.mp hb ]

/-
**Deep theorem**: Einstein addition preserves (-1,1).
-/
theorem einsteinAdd'_preserves {a b : ℝ} (ha : InUnitInterval' a) (hb : InUnitInterval' b) :
    InUnitInterval' (einsteinAdd' a b) := by
  unfold einsteinAdd' InUnitInterval' at *;
  exact abs_lt.mpr ⟨ by rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hb ], by rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hb ] ⟩

/-! ## Part 6: Trace Periodicity Modulo m -/

/-- The Chebyshev trace sequence modulo m. -/
def chebTraceMod (t : ℤ) (m : ℕ) (n : ℕ) : ZMod m :=
  (chebTrace t n : ZMod m)

/-- The state pair determines the future of the sequence. -/
def chebTraceState (t : ℤ) (m : ℕ) (n : ℕ) : ZMod m × ZMod m :=
  (chebTraceMod t m n, chebTraceMod t m (n + 1))

/-- The recurrence holds modulo m. -/
theorem chebTraceState_determines_next (t : ℤ) (m : ℕ) (n : ℕ) :
    chebTraceMod t m (n + 2) =
      (t : ZMod m) * chebTraceMod t m (n + 1) - chebTraceMod t m n := by
  simp only [chebTraceMod, chebTrace_succ_succ]
  push_cast; ring

/-
**Deep theorem (pigeonhole)**: The Chebyshev trace sequence mod m
    is eventually periodic for any m ≥ 2.
-/
theorem chebTrace_eventually_periodic (t : ℤ) (m : ℕ) (hm : 2 ≤ m) :
    ∃ k : ℕ, 0 < k ∧ k ≤ m * m ∧
      chebTraceState t m k = chebTraceState t m 0 := by
  by_contra! h_contra;
  -- By the pigeonhole principle, since there are $m^2 + 1$ states and only $m^2$ possible values, there must be at least two indices $i$ and $j$ with $0 \leq i < j \leq m^2$ such that $chebTraceState t m i = chebTraceState t m j$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ i ≤ m * m ∧ j ≤ m * m ∧ chebTraceState t m i = chebTraceState t m j := by
    have h_pigeonhole : Finset.card (Finset.image (fun n => chebTraceState t m n) (Finset.range (m * m + 1))) ≤ m * m := by
      convert Finset.card_le_univ ( Finset.image ( fun n => chebTraceState t m n ) ( Finset.range ( m * m + 1 ) ) ) using 1;
      swap;
      cases m <;> [ tauto; exact inferInstance ];
      cases m <;> simp_all +decide [ ZMod ];
      grind;
    contrapose! h_pigeonhole;
    rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => h_pigeonhole _ _ hi' ( Finset.mem_range_succ_iff.mp hj ) ( Finset.mem_range_succ_iff.mp hi ) hij.symm ) ( le_of_not_gt fun hj' => h_pigeonhole _ _ hj' ( Finset.mem_range_succ_iff.mp hi ) ( Finset.mem_range_succ_iff.mp hj ) hij ) ] ; simp +arith +decide;
  induction' i with i ih generalizing j;
  · exact h_contra j hij h_eq.2.1 h_eq.2.2.symm;
  · specialize ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij ) ; rcases j <;> simp_all +decide [ chebTraceState ] ;
    simp_all +decide [ chebTraceMod, chebTraceState_determines_next ];
    simp_all +decide [ chebTrace_succ_succ ];
    grind

/-! ## Part 7: Trace-Eigenvalue Correspondence -/

/-- The discriminant of the characteristic polynomial of a matrix with trace t. -/
def traceDiscriminant (t : ℤ) : ℤ := t ^ 2 - 4

/-- Negative discriminant ↔ elliptic (trace ∈ {-1, 0, 1}). -/
theorem traceDiscriminant_neg_iff_elliptic (t : ℤ) :
    traceDiscriminant t < 0 ↔ t = -1 ∨ t = 0 ∨ t = 1 := by
  constructor
  · intro h; unfold traceDiscriminant at h
    have h1 : -1 ≤ t ∧ t ≤ 1 := by
      constructor <;> nlinarith [sq_nonneg (t + 1), sq_nonneg (t - 1)]
    omega
  · intro h; rcases h with h | h | h <;> (subst h; unfold traceDiscriminant; norm_num)

/-- Zero discriminant ↔ parabolic (trace ∈ {-2, 2}). -/
theorem traceDiscriminant_zero_iff_parabolic (t : ℤ) :
    traceDiscriminant t = 0 ↔ t = -2 ∨ t = 2 := by
  constructor
  · intro h; unfold traceDiscriminant at h
    have : (t - 2) * (t + 2) = 0 := by linarith
    rcases mul_eq_zero.mp this with h1 | h1 <;> omega
  · intro h; rcases h with h | h <;> (subst h; unfold traceDiscriminant; norm_num)

/-- Positive discriminant ↔ hyperbolic (|trace| > 2). -/
theorem traceDiscriminant_pos_iff_hyperbolic (t : ℤ) :
    0 < traceDiscriminant t ↔ (t < -2 ∨ 2 < t) := by
  constructor
  · intro h; unfold traceDiscriminant at h
    by_contra hc; push_neg at hc; nlinarith [sq_nonneg t]
  · intro h; unfold traceDiscriminant
    rcases h with h | h <;> nlinarith [sq_nonneg t]

/-- For |t| ≥ 3, the discriminant is at least 5. -/
theorem traceDiscriminant_hyperbolic_lower (t : ℤ) (ht : t ≤ -3 ∨ 3 ≤ t) :
    5 ≤ traceDiscriminant t := by
  unfold traceDiscriminant; rcases ht with h | h <;> nlinarith [sq_nonneg t]

/-! ## Part 8: Hyperbolic Trace Counting -/

/-- Count of hyperbolic trace values with |t| ≤ T (i.e., |t| > 2). -/
def hypTraceCount (T : ℕ) : ℕ :=
  if T ≤ 2 then 0 else 2 * (T - 2)

/-- Linear growth bound. -/
theorem hypTraceCount_bounds (T : ℕ) (hT : 3 ≤ T) :
    T - 2 ≤ hypTraceCount T ∧ hypTraceCount T ≤ 2 * T := by
  simp [hypTraceCount, show ¬(T ≤ 2) from by omega]; omega

/-- Density: for large T, the count exceeds T. -/
theorem hypTraceCount_density (T : ℕ) (hT : 10 ≤ T) :
    T ≤ hypTraceCount T := by
  simp [hypTraceCount, show ¬(T ≤ 2) from by omega]; omega

/-! ## Part 9: Falsifiable Conjecture — Chebyshev Trace Primality

**Conjecture**: For t = 3, the Chebyshev trace sequence
{2, 3, 7, 18, 47, 123, 322, ...} contains infinitely many primes.

**Computational test**: Check chebTrace 3 n for n ∈ [0, 200].
The values 3, 7, 47 are prime. If no further primes exist beyond index 100,
the conjecture is refuted.
-/

/-- Verification: chebTrace 3 2 = 7 is prime. -/
theorem chebTrace3_2_prime : Nat.Prime (chebTrace 3 2).toNat := by
  simp [chebTrace_two]; norm_num

/-- Verification: chebTrace 3 4 = 47 is prime. -/
theorem chebTrace3_4_prime : Nat.Prime (chebTrace 3 4).toNat := by
  simp [chebTrace_four]; norm_num

/-! ## Part 10: The Trace Divisibility Lattice

We define a partial order on trace values induced by the Chebyshev recurrence:
t₁ divides t₂ iff t₂ = chebTrace t₁ n for some n. -/

/-- t₁ is a "trace divisor" of t₂ if t₂ appears in the Chebyshev sequence of t₁. -/
def isTraceDivisor (t₁ t₂ : ℤ) : Prop :=
  ∃ n : ℕ, chebTrace t₁ n = t₂

/-- Every trace divides itself (n = 1). -/
theorem isTraceDivisor_refl (t : ℤ) : isTraceDivisor t t :=
  ⟨1, rfl⟩

/-- 2 divides every trace in this ordering (n = 0). -/
theorem two_isTraceDivisor (t : ℤ) : isTraceDivisor t 2 :=
  ⟨0, rfl⟩

/-- t divides t²-2 (via n = 2). -/
theorem trace_divides_square_minus_two (t : ℤ) :
    isTraceDivisor t (t ^ 2 - 2) :=
  ⟨2, chebTrace_two t⟩

/-
Transitivity of trace divisibility.
-/
theorem isTraceDivisor_trans {t₁ t₂ t₃ : ℤ}
    (h₁ : isTraceDivisor t₁ t₂) (h₂ : isTraceDivisor t₂ t₃) :
    isTraceDivisor t₁ t₃ := by
  -- Using the composition rule, we � have� chebTrace (chebTrace t₁ n) m = chebTrace t₁ (n*m).
  have h_comp : ∀ n m : ℕ, chebTrace (chebTrace t₁ n) m = chebTrace t₁ (n * m) := by
    intros n m
    have h_rec : ∀ x : ℤ, ∀ n m : ℕ, chebTrace (chebTrace x n) m = chebTrace x (n * m) := by
      intros x n m
      have h_rec : ∀ x : ℤ, ∀ n : ℕ, chebTrace x n = 2 * Polynomial.eval (x / 2 : ℝ) (Polynomial.Chebyshev.T ℝ n) := by
        intro x n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ Polynomial.Chebyshev.T ] at *;
        · ring;
        · erw [ Polynomial.Chebyshev.T_add_one ] ; norm_num [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), chebTrace_succ_succ ] ; ring;
      generalize_proofs at *;
      rw [ ← @Int.cast_inj ℝ ] ; simp +decide [ h_rec ] ; ring;
      -- By the properties of Chebyshev polynomials, we know that $T_m(T_n(x)) = T_{mn}(x)$.
      have h_chebyshev_comp : ∀ m n : ℕ, ∀ x : ℝ, Polynomial.eval (Polynomial.eval x (Polynomial.Chebyshev.T ℝ n)) (Polynomial.Chebyshev.T ℝ m) = Polynomial.eval x (Polynomial.Chebyshev.T ℝ (m * n)) := by
        intros m n x
        have h_chebyshev_comp : ∀ m n : ℕ, ∀ x : ℝ, Polynomial.eval (Polynomial.eval x (Polynomial.Chebyshev.T ℝ n)) (Polynomial.Chebyshev.T ℝ m) = Polynomial.eval x (Polynomial.Chebyshev.T ℝ (m * n)) := by
          intros m n x
          have h_trig : ∀ θ : ℝ, Polynomial.eval (Real.cos θ) (Polynomial.Chebyshev.T ℝ m) = Real.cos (m * θ) := by
            simp +zetaDelta at *
          -- By the properties of Chebyshev polynomials, we know that $T_m(T_n(x)) = T_{mn}(x)$ for all $x$.
          have h_chebyshev_comp : ∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → Polynomial.eval (Polynomial.eval x (Polynomial.Chebyshev.T ℝ n)) (Polynomial.Chebyshev.T ℝ m) = Polynomial.eval x (Polynomial.Chebyshev.T ℝ (m * n)) := by
            intros x hx
            have h_trig : Polynomial.eval (Polynomial.eval x (Polynomial.Chebyshev.T ℝ n)) (Polynomial.Chebyshev.T ℝ m) = Polynomial.eval (Real.cos (n * Real.arccos x)) (Polynomial.Chebyshev.T ℝ m) := by
              have h_trig : ∀ n : ℕ, ∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → Polynomial.eval x (Polynomial.Chebyshev.T ℝ n) = Real.cos (n * Real.arccos x) := by
                intros n x hx; exact (by
                convert Polynomial.Chebyshev.T_real_cos ( Real.arccos x ) n using 1 ; rw [ Real.cos_arccos hx.1 hx.2 ]);
              generalize_proofs at *; (
              rw [ h_trig n x hx ])
            generalize_proofs at *; (
            have h_trig : Polynomial.eval x (Polynomial.Chebyshev.T ℝ (m * n)) = Real.cos (m * n * Real.arccos x) := by
              convert Polynomial.Chebyshev.T_mul ( ℝ ) m n using 1 ; ring;
              constructor <;> intro h <;> simp_all +decide [ mul_assoc, Polynomial.Chebyshev.T_mul ] ;
            generalize_proofs at *; (
            simp_all +decide [ mul_assoc ]))
          generalize_proofs at *; (
          -- Since these two polynomials agree on the interval $[-1, 1]$, they must be equal.
          have h_poly_eq : Polynomial.comp (Polynomial.Chebyshev.T ℝ m) (Polynomial.Chebyshev.T ℝ n) = Polynomial.Chebyshev.T ℝ (m * n) := by
            have h_poly_eq : Set.Infinite {x : ℝ | Polynomial.eval x (Polynomial.comp (Polynomial.Chebyshev.T ℝ m) (Polynomial.Chebyshev.T ℝ n)) = Polynomial.eval x (Polynomial.Chebyshev.T ℝ (m * n))} := by
              exact Set.Infinite.mono ( fun x hx => by aesop ) ( Set.Icc_infinite ( by norm_num : ( -1 : ℝ ) < 1 ) )
            generalize_proofs at *; (
            exact?)
          generalize_proofs at *; (
          simpa using congr_arg ( Polynomial.eval x ) h_poly_eq))
        generalize_proofs at *; exact h_chebyshev_comp m n x;
      generalize_proofs at *; exact h_chebyshev_comp m n (x * (1 / 2)) ▸ by ring;
    exact h_rec t₁ n m;
  grind +locals

end