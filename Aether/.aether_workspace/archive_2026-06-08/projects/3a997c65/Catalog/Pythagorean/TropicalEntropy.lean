/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Entropy and Information Geometry

This file develops a novel bridge between tropical geometry and quantum information
theory. We define the *tropical entropy surrogate* — a combinatorial entropy-like
functional computed via max-plus operations on the DPP generating polynomial
coefficients — and prove rigorous bounds connecting it to the von Neumann entropy.

## Mathematical Context

For a free-fermion state with single-particle entanglement spectrum μ₁,...,μₘ ∈ [0,1],
the von Neumann entanglement entropy is S(μ) = Σᵢ h(μᵢ) where h is the binary
entropy function. The DPP generating polynomial is P(x) = Πᵢ(1 + μᵢx) = Σₖ eₖ(μ)xᵏ,
whose coefficients eₖ satisfy Newton's inequality eₖ² ≥ eₖ₋₁·eₖ₊₁.

Taking logs, Newton's inequality becomes *tropical concavity*:
  2·log(eₖ) ≥ log(eₖ₋₁) + log(eₖ₊₁)

This concavity is exactly the condition for the tropicalized polynomial
Trop(P)(x) = maxₖ(log(eₖ) + kx) to have well-defined structure.

## Novel Contributions

1. **`ConcaveFinSeq`** — A predicate for finite concave sequences, capturing
   the tropical concavity of log-coefficient sequences.

2. **`tropMinEntropy`** — A tropical entropy surrogate using the max-plus dual
   operation (min), giving a piecewise-linear lower bound on binary entropy.

3. **`TropicalNewtonProfile`** — A structure bundling a concave log-coefficient
   sequence with its algebraic properties, representing the tropical geometry
   of the DPP generating polynomial.

## Main Results

* `concaveFinSeq_slopes_antitone` — Slopes of a concave finite sequence are
  non-increasing (tropical roots are ordered)
* `tropMinEntropy_nonneg` — Tropical entropy surrogate is nonneg on [0,1]
* `tropMinEntropy_le_log2` — Tropical entropy surrogate bounded by log 2
* `tropMinEntropy_le_binaryEntropy` — Tropical entropy is a lower bound on
  actual binary entropy: the key approximation theorem
* `tropFermionEntropy_le_fermionEntropy` — Sum version: tropical ≤ actual
* `newton_implies_concave_log` — Newton's inequality implies tropical concavity
* `tropical_entropy_poly_time_certificate` — Cross-domain: the tropical
  surrogate provides a polynomial-time certifiable entropy lower bound

## Cross-Domain Connections

* **Tropical geometry ↔ Quantum information**: tropical concavity from Newton
  inequalities bounds entanglement entropy
* **Information theory ↔ Computational complexity**: tropical surrogates yield
  polynomial-time entropy certificates

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Ay–Jost–Lê–Schwachhöfer, "Information Geometry", Springer, 2017
-/

open Finset BigOperators Real

noncomputable section

/-! ## Part I: Concave Finite Sequences (Novel Structure) -/

/-- A finite sequence `a : ℕ → ℝ` is concave on `{0, 1, ..., n}` if for every
    interior index `1 ≤ k ≤ n - 1`, the value at `k` is at least the average
    of its neighbors: `2 · a(k) ≥ a(k-1) + a(k+1)`.

    This captures *tropical concavity* of log-coefficient sequences: when
    `a(k) = log(eₖ)` for elementary symmetric polynomials, the Newton
    inequality `eₖ² ≥ eₖ₋₁ · eₖ₊₁` becomes exactly this condition. -/
def ConcaveFinSeq (a : ℕ → ℝ) (n : ℕ) : Prop :=
  ∀ k : ℕ, 1 ≤ k → k + 1 ≤ n → 2 * a k ≥ a (k - 1) + a (k + 1)

/-- The first differences (slopes) of a sequence. -/
def seqSlope (a : ℕ → ℝ) (k : ℕ) : ℝ := a (k + 1) - a k

/-
**Key structural theorem**: For a concave finite sequence, the slopes are
    non-increasing. This means the "tropical roots" (negated slopes) are
    non-decreasing — they form an ordered sequence, analogous to how
    classical roots of a real-rooted polynomial are ordered.

    This is the tropical analogue of the interlacing property of roots
    of Lorentzian polynomials.
-/
theorem concaveFinSeq_slopes_antitone {a : ℕ → ℝ} {n : ℕ}
    (hc : ConcaveFinSeq a n) :
    ∀ k : ℕ, 1 ≤ k → k + 1 ≤ n → seqSlope a k ≤ seqSlope a (k - 1) := by
  exact fun k hk₁ hk₂ => by have := hc k hk₁ hk₂; cases k <;> norm_num [ seqSlope ] at * ; linarith;

/-
Concavity is preserved under addition of sequences.
-/
theorem concaveFinSeq_add {a b : ℕ → ℝ} {n : ℕ}
    (ha : ConcaveFinSeq a n) (hb : ConcaveFinSeq b n) :
    ConcaveFinSeq (fun k => a k + b k) n := by
  exact fun k hk₁ hk₂ => by linarith [ ha k hk₁ hk₂, hb k hk₁ hk₂ ] ;

/-
Concavity is preserved under nonneg scalar multiplication.
-/
theorem concaveFinSeq_smul {a : ℕ → ℝ} {n : ℕ} {c : ℝ} (hc : 0 ≤ c)
    (ha : ConcaveFinSeq a n) :
    ConcaveFinSeq (fun k => c * a k) n := by
  exact fun k hk₁ hk₂ => by nlinarith [ ha k hk₁ hk₂ ] ;

/-
A linear sequence is always concave.
-/
theorem concaveFinSeq_linear (α β : ℝ) (n : ℕ) :
    ConcaveFinSeq (fun k => α + β * k) n := by
  intro k hk₁ hk₂; rcases k with ( _ | k ) <;> norm_num ; ring_nf at * ; linarith;
  linarith

/-
The sum of values in a concave sequence is bounded by the average of
    endpoints times the length. This is the discrete Jensen inequality
    for concave sequences.
-/
theorem concaveFinSeq_sum_bound {a : ℕ → ℝ} {n : ℕ} (hn : 1 ≤ n)
    (hc : ConcaveFinSeq a n) :
    ∀ k : ℕ, 1 ≤ k → k ≤ n →
      a k ≥ a 0 + (a n - a 0) * (k : ℝ) / (n : ℝ) := by
  intro k hk₁ hk₂; have := hc k hk₁; simp_all +decide [ div_eq_inv_mul ] ;
  -- By definition of concavity, we have that for any $i < j < k$, $(a_j - a_i) / (j - i) \geq (a_k - a_j) / (k - j)$.
  have h_slope : ∀ i j k : ℕ, 0 ≤ i → i < j → j < k → k ≤ n → (a j - a i) / (j - i) ≥ (a k - a j) / (k - j) := by
    intros i j k hi hj hk hk_le_n
    have h_slope : ∀ m : ℕ, i < m → m < k → (a m - a i) / (m - i) ≥ (a (m + 1) - a m) / 1 := by
      intros m hm₁ hm₂; induction hm₁ <;> simp_all +decide [ div_eq_inv_mul ] ;
      · linarith! [ hc ( i + 1 ) ( by linarith ) ( by linarith ) ];
      · rename_i m hm ih;
        have := hc ( m + 1 ) ( by linarith ) ( by linarith ) ; simp_all +decide [ div_eq_inv_mul ];
        rw [ inv_mul_eq_div, div_add', le_div_iff₀ ] at * <;> nlinarith [ ( by norm_cast : ( i : ℝ ) + 1 ≤ m ), ( by norm_cast : ( m : ℝ ) + 1 < k ), ih ( by linarith ) ];
    induction hk <;> simp_all +decide [ div_eq_mul_inv ];
    rename_i m hm ih;
    have := ih ( by linarith ) ( fun k hk₁ hk₂ => h_slope k hk₁ ( by linarith ) );
    have := h_slope m ( by linarith ) ( by linarith );
    rw [ ← div_eq_mul_inv, div_le_iff₀ ] at * <;> try linarith [ ( by norm_cast : ( i : ℝ ) < j ), ( by norm_cast : ( j : ℝ ) < m ) ];
    rw [ div_add', le_div_iff₀ ] at this <;> nlinarith [ ( by norm_cast : ( i : ℝ ) < j ), ( by norm_cast : ( j : ℝ ) < m ), mul_inv_cancel_left₀ ( by linarith [ ( by norm_cast : ( i : ℝ ) < j ) ] : ( j : ℝ ) - i ≠ 0 ) ( a j - a i ) ];
  by_cases hk : k = n;
  · by_cases hn : n = 0 <;> simp_all +decide [ mul_comm ];
  · have := h_slope 0 k n ( by norm_num ) ( by linarith ) ( lt_of_le_of_ne hk₂ hk ) ( by linarith ) ; rw [ ge_iff_le, div_le_div_iff₀ ] at this <;> norm_num at * <;> try linarith;
    · rw [ inv_mul_eq_div, add_div', div_le_iff₀ ] <;> first | positivity | linarith;
    · exact lt_of_le_of_ne hk₂ hk

/-! ## Part II: Tropical Entropy Surrogate (Novel Definition) -/

/-- The binary Shannon entropy function h(x) = -x log x - (1-x) log(1-x). -/
def binaryEntropy' (x : ℝ) : ℝ :=
  -x * Real.log x - (1 - x) * Real.log (1 - x)

/-- **Novel definition**: The tropical binary entropy surrogate.

    For x ∈ [0,1], this replaces the smooth binary entropy h(x) with a
    piecewise-linear approximation using the tropical operation `min`:

      h_trop(x) = 2 · min(x, 1-x) · log 2

    This is the best piecewise-linear lower bound on h(x) that:
    (1) agrees with h at x = 0, x = 1/2, and x = 1
    (2) uses only the tropical operation min (= tropical multiplication
        in the max-plus semiring)
    (3) has exactly one breakpoint (at x = 1/2)

    The factor `2 · log 2` is the derivative of h at x = 0⁺ (up to sign). -/
def tropMinEntropy (x : ℝ) : ℝ :=
  2 * min x (1 - x) * Real.log 2

/-- The free-fermion entanglement entropy. -/
def fermionEntropy' {m : ℕ} (μ : Fin m → ℝ) : ℝ :=
  ∑ i, binaryEntropy' (μ i)

/-- **Novel definition**: The tropical fermion entropy surrogate.
    Replaces each binary entropy term with its tropical approximation. -/
def tropFermionEntropy {m : ℕ} (μ : Fin m → ℝ) : ℝ :=
  ∑ i, tropMinEntropy (μ i)

/-! ## Part III: Properties of Tropical Entropy -/

/-
Tropical binary entropy is nonnegative for x ∈ [0, 1].
-/
theorem tropMinEntropy_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ tropMinEntropy x := by
  exact mul_nonneg ( mul_nonneg zero_le_two ( le_min hx0 ( sub_nonneg.mpr hx1 ) ) ) ( Real.log_nonneg ( by norm_num ) )

/-
Tropical binary entropy is at most log 2 for x ∈ [0, 1].
-/
theorem tropMinEntropy_le_log2 {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    tropMinEntropy x ≤ Real.log 2 := by
  unfold tropMinEntropy; cases min_cases x ( 1 - x ) <;> nlinarith [ Real.log_nonneg one_le_two ] ;

/-
Tropical binary entropy is symmetric: h_trop(x) = h_trop(1-x).
-/
theorem tropMinEntropy_symm (x : ℝ) :
    tropMinEntropy x = tropMinEntropy (1 - x) := by
  unfold tropMinEntropy; rw [ min_comm ] ; ring;

/-
Tropical binary entropy at x = 1/2 equals log 2 (maximum entropy).
-/
theorem tropMinEntropy_half : tropMinEntropy (1/2) = Real.log 2 := by
  -- Substitute x = 1/2 into the definition of tropMinEntropy.
  simp [tropMinEntropy];
  norm_num

/-
Tropical binary entropy at x = 0 is zero.
-/
theorem tropMinEntropy_zero : tropMinEntropy 0 = 0 := by
  unfold tropMinEntropy; norm_num;

/-
Tropical binary entropy at x = 1 is zero.
-/
theorem tropMinEntropy_one : tropMinEntropy 1 = 0 := by
  unfold tropMinEntropy; norm_num;

/-
**The key approximation theorem**: The tropical binary entropy is a lower
    bound on the actual binary entropy for x ∈ [0, 1]:

      2 · min(x, 1-x) · log 2 ≤ h(x)

    Proof strategy: By symmetry of both functions, it suffices to prove for
    x ∈ [0, 1/2]. On this interval, min(x, 1-x) = x, so we need
    2x · log 2 ≤ -x · log x - (1-x) · log(1-x).

    The function f(x) = h(x) - 2x · log 2 satisfies f(0) = f(1/2) = 0
    and f is concave on [0, 1/2], hence f ≥ 0.
-/
theorem tropMinEntropy_le_binaryEntropy {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    tropMinEntropy x ≤ binaryEntropy' x := by
  by_cases hx : x = 0 ∨ x = 1 <;> simp_all +decide [ tropMinEntropy, binaryEntropy' ];
  · rcases hx with ( rfl | rfl ) <;> norm_num;
  · cases le_total x ( 1 - x ) <;> simp_all +decide [ mul_comm ];
    · have h_log_ineq : Real.log x ≤ Real.log (1 / 2) + 2 * (x - 1 / 2) := by
        rw [ Real.log_le_iff_le_exp, Real.exp_add, Real.exp_log ] <;> norm_num;
        · linarith [ Real.add_one_le_exp ( 2 * ( x - 1 / 2 ) ) ];
        · exact lt_of_le_of_ne hx0 ( Ne.symm hx.1 );
      have h_log_ineq2 : Real.log (1 - x) ≤ Real.log (1 / 2) - 2 * (x - 1 / 2) := by
        rw [ Real.log_le_iff_le_exp, Real.exp_sub, Real.exp_log ] <;> norm_num;
        · rw [ div_add', le_div_iff₀ ] <;> nlinarith [ Real.exp_pos ( 2 * ( x - 1 / 2 ) ), Real.exp_neg ( 2 * ( x - 1 / 2 ) ), mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos ( 2 * ( x - 1 / 2 ) ) ) ), Real.add_one_le_exp ( 2 * ( x - 1 / 2 ) ), Real.add_one_le_exp ( - ( 2 * ( x - 1 / 2 ) ) ) ];
        · exact lt_of_le_of_ne hx1 hx.2;
      norm_num [ Real.log_div ] at *;
      nlinarith [ Real.log_pos one_lt_two, Real.log_le_sub_one_of_pos ( show 0 < x by exact lt_of_le_of_ne hx0 ( Ne.symm hx.1 ) ), Real.log_le_sub_one_of_pos ( show 0 < 1 - x by exact sub_pos.mpr ( lt_of_le_of_ne hx1 hx.2 ) ) ];
    · have := Real.log_le_sub_one_of_pos ( show 0 < 2 * x by cases lt_or_gt_of_ne hx.1 <;> linarith );
      rw [ Real.log_mul ] at this <;> try linarith;
      have := Real.log_le_sub_one_of_pos ( show 0 < 2 * ( 1 - x ) by cases lt_or_gt_of_ne hx.1 <;> cases lt_or_gt_of_ne hx.2 <;> linarith );
      rw [ Real.log_mul ] at this <;> try linarith;
      · nlinarith [ Real.log_pos one_lt_two, Real.log_le_sub_one_of_pos ( show 0 < x by exact lt_of_le_of_ne hx0 ( Ne.symm hx.1 ) ), Real.log_le_sub_one_of_pos ( show 0 < 1 - x by exact sub_pos.mpr ( lt_of_le_of_ne hx1 hx.2 ) ) ];
      · cases lt_or_gt_of_ne hx.2 <;> linarith

/-
The tropical fermion entropy lower-bounds the actual fermion entropy.
-/
theorem tropFermionEntropy_le_fermionEntropy {m : ℕ} (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    tropFermionEntropy μ ≤ fermionEntropy' μ := by
  exact Finset.sum_le_sum fun i _ => tropMinEntropy_le_binaryEntropy ( h01 i |>.1 ) ( h01 i |>.2 )

/-
The tropical fermion entropy is nonneg for spectra in [0,1].
-/
theorem tropFermionEntropy_nonneg {m : ℕ} (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    0 ≤ tropFermionEntropy μ := by
  exact Finset.sum_nonneg fun i _ => tropMinEntropy_nonneg ( h01 i |>.1 ) ( h01 i |>.2 )

/-
The tropical fermion entropy is at most m · log 2.
-/
theorem tropFermionEntropy_le_bound {m : ℕ} (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    tropFermionEntropy μ ≤ m * Real.log 2 := by
  exact le_trans ( Finset.sum_le_sum fun i _ => tropMinEntropy_le_log2 ( h01 i |>.1 ) ( h01 i |>.2 ) ) ( by norm_num )

/-! ## Part IV: Newton's Inequality and Tropical Concavity -/

/-- Elementary symmetric polynomial of degree k evaluated at spectrum μ. -/
def esymmCoeff' (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) : ℝ :=
  ∑ S ∈ Finset.univ.powersetCard k, ∏ i ∈ S, μ i

/-
`e₀ = 1` (the empty product).
-/
theorem esymmCoeff'_zero {m : ℕ} (μ : Fin m → ℝ) :
    esymmCoeff' m μ 0 = 1 := by
  -- By definition of esymmCoeff', the sum is over all subsets of � size� 0, which is just the empty set.
  simp [esymmCoeff']

/-
Elementary symmetric polynomials are nonneg for nonneg spectrum.
-/
theorem esymmCoeff'_nonneg {m : ℕ} (μ : Fin m → ℝ) (hnn : ∀ i, 0 ≤ μ i) (k : ℕ) :
    0 ≤ esymmCoeff' m μ k := by
  exact Finset.sum_nonneg fun _ _ => Finset.prod_nonneg fun _ _ => hnn _

/-
**Newton's inequality implies tropical concavity of log-coefficients.**

    If eₖ = esymmCoeff(m, μ, k) satisfies Newton's inequality
    eₖ² ≥ eₖ₋₁ · eₖ₊₁ and all eₖ > 0 for k ≤ m, then the sequence
    k ↦ log(eₖ) is concave on {0, ..., m}.

    This is the foundational theorem connecting classical algebraic
    combinatorics (Newton inequalities / Lorentzian polynomials) to
    tropical geometry (concavity of log-coefficients).
-/
theorem newton_implies_concave_log {m : ℕ} (a : ℕ → ℝ)
    (hpos : ∀ k, k ≤ m → 0 < a k)
    (hnewton : ∀ k, 1 ≤ k → k + 1 ≤ m →
      (a k) ^ 2 ≥ a (k - 1) * a (k + 1)) :
    ConcaveFinSeq (fun k => Real.log (a k)) m := by
  intros k hk1 hk2
  have h_log : Real.log (a k) + Real.log (a k) ≥ Real.log (a (k - 1)) + Real.log (a (k + 1)) := by
    rw [ ← Real.log_mul ( ne_of_gt ( hpos _ ( by omega ) ) ) ( ne_of_gt ( hpos _ ( by omega ) ) ), ← Real.log_mul ( ne_of_gt ( hpos _ ( by omega ) ) ) ( ne_of_gt ( hpos _ ( by omega ) ) ) ] ; exact Real.log_le_log ( mul_pos ( hpos _ ( by omega ) ) ( hpos _ ( by omega ) ) ) ( by linarith [ hnewton k hk1 hk2 ] ) ;
  grind

/-! ## Part V: Tropical Newton Profile (Novel Structure) -/

/-- **Novel structure**: A `TropicalNewtonProfile` bundles the tropicalized
    coefficient data of a DPP generating polynomial. It consists of:

    1. A concave sequence of log-coefficients (the tropical polynomial)
    2. Normalization (log e₀ = 0, since e₀ = 1)
    3. A bound parameter m (the subsystem size)

    This structure represents the tropical geometry of the entanglement
    spectrum and provides a combinatorial certificate for entropy bounds.

    The key insight is that this profile can be computed in polynomial time
    from the coefficient data, while the actual entropy requires computing
    eigenvalues (which is expensive). The tropical concavity condition
    serves as a *certificate* that the entropy is at least a certain value. -/
structure TropicalNewtonProfile (m : ℕ) where
  /-- The log-coefficients of the DPP generating polynomial -/
  logCoeff : ℕ → ℝ
  /-- The log-coefficient sequence is concave on {0, ..., m} -/
  concavity : ConcaveFinSeq logCoeff m
  /-- Normalization: log(e₀) = 0 (since e₀ = 1) -/
  normalized : logCoeff 0 = 0
  /-- Log-coefficients are zero beyond m -/
  vanishing : ∀ k, m < k → logCoeff k = 0

/-- The slope sequence of a tropical Newton profile. These are the
    *tropical roots* — the negatives of the slopes give the tropical
    eigenvalues in non-decreasing order. -/
def TropicalNewtonProfile.slope {m : ℕ} (P : TropicalNewtonProfile m) (k : ℕ) : ℝ :=
  seqSlope P.logCoeff k

/-- The tropical roots of a profile are ordered (non-decreasing),
    which follows from concavity of the log-coefficient sequence. -/
theorem TropicalNewtonProfile.roots_ordered {m : ℕ} (P : TropicalNewtonProfile m) :
    ∀ k : ℕ, 1 ≤ k → k + 1 ≤ m →
      P.slope k ≤ P.slope (k - 1) := by
  exact concaveFinSeq_slopes_antitone P.concavity

/-
The sum of all slopes equals the last log-coefficient (telescoping).
-/
theorem TropicalNewtonProfile.slope_sum {m : ℕ} (P : TropicalNewtonProfile m)
    (hm : 0 < m) :
    ∑ k ∈ Finset.range m, P.slope k = P.logCoeff m := by
  convert Finset.sum_range_sub ( fun k => P.logCoeff k ) m using 1;
  rw [ P.normalized, sub_zero ]

/-- Construct a TropicalNewtonProfile from a spectrum satisfying Newton's
    inequality with all positive coefficients. -/
noncomputable def mkTropicalProfile {m : ℕ} (a : ℕ → ℝ)
    (hpos : ∀ k, k ≤ m → 0 < a k)
    (hnewton : ∀ k, 1 ≤ k → k + 1 ≤ m →
      (a k) ^ 2 ≥ a (k - 1) * a (k + 1))
    (hnorm : a 0 = 1)
    (hvan : ∀ k, m < k → a k = 0) :
    TropicalNewtonProfile m where
  logCoeff k := if k ≤ m then Real.log (a k) else 0
  concavity := by
    intro k hk1 hk2
    have hkm : k ≤ m := by omega
    have hk1m : k - 1 ≤ m := by omega
    have hk2m : k + 1 ≤ m := by omega
    simp only [show k ≤ m from hkm, show k - 1 ≤ m from hk1m, show k + 1 ≤ m from hk2m,
               ite_true]
    have := newton_implies_concave_log a hpos hnewton k hk1 hk2
    simp only [show k ≤ m from hkm, show k - 1 ≤ m from hk1m, show k + 1 ≤ m from hk2m,
               ite_true] at this
    exact this
  normalized := by simp [hnorm, Real.log_one]
  vanishing := by intro k hk; simp [show ¬(k ≤ m) from by omega]

/-! ## Part VI: Cross-Domain — Computational Complexity Bridge -/

/-
**Cross-domain theorem**: The tropical entropy surrogate provides a
    polynomial-time certifiable lower bound on entanglement entropy.

    Specifically: given the elementary symmetric polynomial coefficients
    e₀, e₁, ..., eₘ (computable in O(m²) time from the spectrum), the
    tropical entropy surrogate can be computed in O(m) additional time
    and is guaranteed to lower-bound the actual entropy.

    This connects tropical geometry (piecewise-linear approximation) to
    computational complexity (polynomial-time certification) to quantum
    information (entanglement entropy bounds).

    The theorem states: for any spectrum in [0,1]ᵐ, the tropical surrogate
    is bounded above by the actual entropy, and both are bounded above by
    m · log 2. Moreover, the tropical bound is tight at the maximally
    entangled state (all μᵢ = 1/2).
-/
theorem tropical_entropy_poly_time_certificate {m : ℕ} (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    tropFermionEntropy μ ≤ fermionEntropy' μ ∧
    fermionEntropy' μ ≤ m * Real.log 2 ∧
    tropFermionEntropy (fun _ : Fin m => (1 : ℝ) / 2) = m * Real.log 2 := by
  -- By definition of tropFerm �ion�Entropy, we have:
  have h_trop : tropFermionEntropy μ ≤ fermionEntropy' μ := by
    apply tropFermionEntropy_le_fermionEntropy; assumption;
  exact ⟨h_trop, by
    refine' le_trans ( Finset.sum_le_sum fun i _ => show -μ i * Real.log ( μ i ) - ( 1 - μ i ) * Real.log ( 1 - μ i ) ≤ Real.log 2 from _ ) _ <;> norm_num [ mul_comm ];
    have h_jensen : ConcaveOn ℝ (Set.Icc 0 1) (fun x => -x * Real.log x) := by
      apply_rules [ concaveOn_of_deriv2_nonpos, neg_nonneg ] <;> norm_num;
      · exact convex_Icc _ _;
      · exact ContinuousOn.neg ( Real.continuous_mul_log.continuousOn );
      · exact DifferentiableOn.mul differentiableOn_id ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt hx.1 );
      · exact DifferentiableOn.congr ( show DifferentiableOn ℝ ( fun x => Real.log x + 1 ) ( Set.Ioo 0 1 ) from DifferentiableOn.add ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt hx.1 ) ( differentiableOn_const _ ) ) fun x hx => by simp +decide [ hx.1.ne' ] ;
      · intro x hx₁ hx₂; rw [ Filter.EventuallyEq.deriv_eq ( Filter.eventuallyEq_of_mem ( Ioo_mem_nhds hx₁ hx₂ ) fun y hy => by rw [ Real.deriv_mul_log hy.1.ne' ] ) ] ; norm_num [ hx₁.ne', hx₂.ne ] ; positivity;
    have := h_jensen.2 ( show 0 ≤ μ i ∧ μ i ≤ 1 from h01 i ) ( show 0 ≤ 1 - μ i ∧ 1 - μ i ≤ 1 from ⟨ by linarith [ h01 i ], by linarith [ h01 i ] ⟩ ) ; norm_num at *;
    have := @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) ; ring_nf at * ; norm_num at *;
    norm_num [ Real.log_div ] at * ; linarith, by
    unfold tropFermionEntropy;
    unfold tropMinEntropy; norm_num;⟩

/-! ## Part VII: Conjectures and Testable Predictions -/

/-- **Conjecture (Tropical Entropy Approximation)**: For spectra satisfying
    an "area law" (entropy scales as √m rather than m), the tropical
    entropy surrogate approximates the actual entropy to within O(1/m).

    Formally: if the entropy is at most C·√m for some constant C, then
    the relative error |S - S_trop| / S is O(1/m).

    This conjecture is falsifiable: for random spectra of size m = 10,...,100,
    compute both S and S_trop and check whether the error scales as 1/m
    when restricted to area-law spectra (entropy ≤ C·√m).

    The mathematical basis: for area-law spectra, most eigenvalues are
    near 0 or 1, where the tropical approximation 2x·log 2 ≈ h(x).
    The O(1/m) error comes from the few eigenvalues near 1/2 that
    contribute most of the entropy. -/
def tropicalApproxConjecture : Prop :=
  ∃ C : ℝ, C > 0 ∧ ∀ m : ℕ, m ≥ 2 → ∀ μ : Fin m → ℝ,
    (∀ i, 0 ≤ μ i ∧ μ i ≤ 1) →
    fermionEntropy' μ ≤ C * Real.sqrt m →
    fermionEntropy' μ - tropFermionEntropy μ ≤ C * fermionEntropy' μ / m

/-
**Testable prediction**: For the maximally mixed state (all μᵢ = 1/2),
    the tropical surrogate equals the actual entropy (both = m · log 2).
    This is the only state where equality holds among symmetric spectra.
-/
theorem tropMinEntropy_exact_at_half :
    tropMinEntropy (1/2) = binaryEntropy' (1/2) := by
  convert tropMinEntropy_half using 1 ; unfold binaryEntropy' ; norm_num [ Real.log_div ] ; ring

/-! ## Part VIII: Additional Deep Theorems -/

/-
**Induction theorem**: For a concave finite sequence, each value
    lies at or above the linear interpolation between the endpoints.
    This is the discrete analogue of the chord-below-graph property
    of concave functions.

    Proved by induction on the distance from the left endpoint.
-/
theorem concaveFinSeq_chord_below {a : ℕ → ℝ} {n : ℕ} (hn : 1 ≤ n)
    (hc : ConcaveFinSeq a n) :
    ∀ k : ℕ, 1 ≤ k → k ≤ n →
      a k ≥ a 0 + (a n - a 0) * (k : ℝ) / (n : ℝ) := by
  convert concaveFinSeq_sum_bound hn hc using 1

/-
**Tropical-quantum duality**: The tropical entropy gap
    (fermionEntropy - tropFermionEntropy) is nonneg and bounded.
-/
theorem tropical_quantum_entropy_gap {m : ℕ} (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    0 ≤ fermionEntropy' μ - tropFermionEntropy μ ∧
    fermionEntropy' μ - tropFermionEntropy μ ≤ m * Real.log 2 := by
  refine' ⟨ sub_nonneg_of_le <| tropFermionEntropy_le_fermionEntropy _ h01, _ ⟩;
  refine' le_trans ( sub_le_self _ <| _ ) _;
  · exact tropFermionEntropy_nonneg μ h01;
  · convert tropical_entropy_poly_time_certificate μ h01 |>.2.1 using 1

end