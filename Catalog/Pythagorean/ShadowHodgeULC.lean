/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Shadow Hodge Theory and Ultra-Log-Concavity

This file develops the theory of **shadow profiles** for finite subsets of ℕⁿ,
their ultra-log-concavity properties, and connections to M-convex exchange geometry.

## Main Definitions

* `ShadowHodge.UltraLogConcave` — Ultra-log-concavity of a sequence with respect to degree D
* `ShadowHodge.MConvex` — M-convex exchange axiom for finite subsets of ℕⁿ
* `ShadowHodge.ShadowSet` — Shadow set of a finite set at degree k
* `ShadowHodge.LogConcaveSeq` — Standard log-concavity of a sequence

## Main Results

* `ShadowHodge.choose_sq_mul_factors_eq` — Key algebraic identity relating adjacent
  binomial coefficients
* `ShadowHodge.binomial_log_concave` — Log-concavity of binomial coefficients:
  C(n,k)² ≥ C(n,k-1) · C(n,k+1)
* `ShadowHodge.shadow_set_mono` — Shadow sets are monotone in the base set
* `ShadowHodge.conjecture_counterexample` — The naive ULC conjecture with D = max degree
  is FALSE: explicit counterexample with U(3,4)
* `ShadowHodge.log_concave_ratio_antitone` — Cross-domain: log-concavity implies
  ratio monotonicity (bridge to information theory)
* `ShadowHodge.binomial_ulc_self` — C(n,k) is ULC with D = n

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators Nat

noncomputable section

namespace ShadowHodge

/-! ## Core Definitions -/

/-- **Ultra-log-concavity** of a sequence `a : ℕ → ℝ` with respect to degree `D`.
    The normalized sequence `a k / C(D, k)` is log-concave:
    `(a k / C(D,k))² ≥ (a(k-1)/C(D,k-1)) · (a(k+1)/C(D,k+1))`
    Rearranging: `a k² · C(D,k-1) · C(D,k+1) ≥ a(k-1) · a(k+1) · C(D,k)²`. -/
def UltraLogConcave (D : ℕ) (a : ℕ → ℝ) : Prop :=
  ∀ k : ℕ, 1 ≤ k → k + 1 ≤ D →
    (a k) ^ 2 * (D.choose (k - 1) : ℝ) * (D.choose (k + 1) : ℝ) ≥
    (a (k - 1)) * (a (k + 1)) * ((D.choose k : ℝ)) ^ 2

/-- **Standard log-concavity** of a sequence on an interval. -/
def LogConcaveSeq (a : ℕ → ℝ) (lo hi : ℕ) : Prop :=
  ∀ k : ℕ, lo + 1 ≤ k → k + 1 ≤ hi →
    (a k) ^ 2 ≥ (a (k - 1)) * (a (k + 1))

/-- **M-convex exchange axiom** for a finite subset of `Fin n → ℕ`.
    For any α, β in S with α(i) > β(i), there exists j with α(j) < β(j)
    such that the exchange vector α - eᵢ + eⱼ is in S. -/
def MConvex {n : ℕ} (S : Finset (Fin n → ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n,
    α i > β i →
    ∃ j : Fin n, α j < β j ∧
      (fun k => if k = i then α i - 1
                else if k = j then α j + 1
                else α k) ∈ S

/-- The **shadow set** of `S ⊆ (Fin n → ℕ)` at degree `k`:
    all vectors of total degree `k` dominated coordinatewise by some element of `S`. -/
def ShadowSet {n : ℕ} (S : Finset (Fin n → ℕ)) (k : ℕ) : Set (Fin n → ℕ) :=
  {β | (∑ i : Fin n, β i) = k ∧ ∃ α ∈ S, ∀ i : Fin n, β i ≤ α i}

/-- A sequence is **unimodal** on `[lo, hi]`. -/
def Unimodal (a : ℕ → ℝ) (lo hi : ℕ) : Prop :=
  ∃ m : ℕ, lo ≤ m ∧ m ≤ hi ∧
    (∀ i j, lo ≤ i → i ≤ j → j ≤ m → a i ≤ a j) ∧
    (∀ i j, m ≤ i → i ≤ j → j ≤ hi → a j ≤ a i)

/-! ## Key Algebraic Identity for Binomial Coefficients -/

/-
The fundamental identity linking adjacent binomial coefficients (shifted form):
    `C(n+2, k+1)² · (k+1) · (n+1-k) = C(n+2, k) · C(n+2, k+2) · (k+2) · (n+2-k)`

    This is the algebraic engine behind log-concavity of binomial coefficients.
    We use shifted indices to avoid natural number subtraction pitfalls.
-/
theorem choose_sq_mul_factors_eq (n k : ℕ) (hk : k + 1 ≤ n + 1) :
    (Nat.choose (n + 2) (k + 1)) ^ 2 * (k + 1) * (n + 1 - k) =
    Nat.choose (n + 2) k * Nat.choose (n + 2) (k + 2) * (k + 2) * (n + 2 - k) := by
  have h1 := Nat.succ_mul_choose_eq ( n + 2 ) k;
  have h2 := Nat.succ_mul_choose_eq ( n + 2 ) ( k + 1 );
  simp_all +decide [ Nat.choose_succ_succ, mul_comm, mul_assoc, mul_left_comm ];
  zify [ Nat.succ_sub ( by linarith : k ≤ n + 1 ), Nat.succ_sub ( by linarith : k ≤ n + 2 ) ] at *;
  grind

/-
**Log-concavity of binomial coefficients** (shifted form):
    `C(n+2, k+1)² ≥ C(n+2, k) · C(n+2, k+2)` for `k+1 ≤ n+1`.

    Follows from `choose_sq_mul_factors_eq` and `(k+2)(n+2-k) ≥ (k+1)(n+1-k)`,
    which holds because `(k+2)(n+2-k) - (k+1)(n+1-k) = n + 3 > 0`.
-/
theorem binomial_log_concave (n k : ℕ) (hk : k + 1 ≤ n + 1) :
    (Nat.choose (n + 2) (k + 1)) ^ 2 ≥
    Nat.choose (n + 2) k * Nat.choose (n + 2) (k + 2) := by
  -- By multiplying both sides of the equation from choose_sq_mul_factors_eq by $(k + 2) * (n + 2 - k)$, we obtain the desired inequality.
  have h_mul : (Nat.choose (n + 2) (k + 1)) ^ 2 * (k + 1) * (n + 1 - k) ≥ (Nat.choose (n + 2) k) * (Nat.choose (n + 2) (k + 2)) * (k + 1) * (n + 1 - k) := by
    rw [ choose_sq_mul_factors_eq ];
    · gcongr <;> omega;
    · linarith;
  nlinarith [ mul_pos ( Nat.succ_pos k ) ( Nat.sub_pos_of_lt hk ) ]

/-! ## Shadow Set Properties -/

/-- Shadow sets are monotone: if `S ⊆ T`, then `ShadowSet S k ⊆ ShadowSet T k`. -/
theorem shadow_set_mono {n : ℕ} {S T : Finset (Fin n → ℕ)} (h : S ⊆ T) (k : ℕ) :
    ShadowSet S k ⊆ ShadowSet T k := by
  intro β ⟨hsum, α, hαS, hdom⟩
  exact ⟨hsum, α, h hαS, hdom⟩

/-- The zero vector is always in the degree-0 shadow of a nonempty set. -/
theorem zero_mem_shadow_zero {n : ℕ} (S : Finset (Fin n → ℕ)) (hS : S.Nonempty) :
    (0 : Fin n → ℕ) ∈ ShadowSet S 0 := by
  obtain ⟨α, hα⟩ := hS
  exact ⟨by simp, α, hα, fun i => Nat.zero_le _⟩

/-! ## Counterexample: The Naive ULC Conjecture Fails -/

/-- **Counterexample**: For U(3,4), the shadow profile `a_k = C(4,k)` with `D = 3`
    fails ULC at `k = 1`:
      `C(4,1)² · C(3,0) · C(3,2) = 48 < 54 = C(4,0) · C(4,2) · C(3,1)²`
    This refutes the naive Shadow-Hodge ULC conjecture with `D = max |α|`. -/
theorem conjecture_counterexample :
    ¬ ((Nat.choose 4 1) ^ 2 * Nat.choose 3 0 * Nat.choose 3 2 ≥
       Nat.choose 4 0 * Nat.choose 4 2 * (Nat.choose 3 1) ^ 2) := by
  decide

/-! ## Log-Concave Sequences: Structural Results -/

/-
If a nonneg log-concave sequence has a zero with a positive predecessor,
    then the successor is also zero. Zeros propagate forward in
    log-concave nonneg sequences.
-/
theorem log_concave_zero_propagates {a : ℕ → ℝ} {lo hi : ℕ}
    (hlc : LogConcaveSeq a lo hi) (hnn : ∀ i, lo ≤ i → i ≤ hi → 0 ≤ a i)
    (j : ℕ) (hjlo : lo + 1 ≤ j) (hjhi : j + 1 ≤ hi)
    (hj : a j = 0) (hjm1 : 0 < a (j - 1)) :
    a (j + 1) = 0 := by
  nlinarith [ hlc j ( by linarith ) ( by linarith ), hnn ( j - 1 ) ( by omega ) ( by omega ), hnn ( j + 1 ) ( by omega ) ( by omega ) ]

/-! ## Cross-Domain: Log-Concavity to Ratio Monotonicity -/

/-
**Cross-domain bridge (Combinatorics ↔ Information Theory)**:
    Log-concavity of a positive sequence implies that the ratio `a(k+1)/a(k)`
    is nonincreasing. In information-theoretic terms, this means the discrete
    log-partition function `log a(k)` is concave, connecting combinatorial
    log-concavity to maximum entropy principles.

    Proof: Log-concavity gives `a(k)² ≥ a(k-1)·a(k+1)`, i.e.,
    `a(k)/a(k-1) ≥ a(k+1)/a(k)` after dividing by positive terms.
-/
theorem log_concave_ratio_antitone {a : ℕ → ℝ} {lo hi : ℕ}
    (hlc : LogConcaveSeq a lo hi)
    (hpos : ∀ i, lo ≤ i → i ≤ hi → 0 < a i)
    (k : ℕ) (hk1 : lo + 1 ≤ k) (hk2 : k + 1 ≤ hi) :
    a (k + 1) / a k ≤ a k / a (k - 1) := by
  rw [ div_le_div_iff₀ ] <;> nlinarith! [ hlc k hk1 hk2, hpos k ( by linarith ) ( by linarith ), hpos ( k - 1 ) ( Nat.le_sub_one_of_lt hk1 ) ( Nat.sub_le_of_le_add <| by linarith ) ]

/-! ## ULC Structural Results -/

/-
**Binomial coefficients are ULC with respect to their own index** (D = n).
    Since `a k = C(n,k)` and D = n, both sides of the ULC inequality are
    `C(n,k)² · C(n,k-1) · C(n,k+1)`, giving equality.
-/
theorem binomial_ulc_self (n : ℕ) :
    UltraLogConcave n (fun k => (n.choose k : ℝ)) := by
  intro k hk₁ hk₂; have := choose_sq_mul_factors_eq ( n - 2 ) ( k - 1 ) ; rcases n with ( _ | _ | n ) <;> rcases k with ( _ | _ | k ) <;> norm_num at *;
  · linarith;
  · linarith

/-
**Log-concavity of binomial coefficients (natural form)**:
    `C(m, k)² ≥ C(m, k-1) · C(m, k+1)` for `1 ≤ k` and `k+1 ≤ m`.
    This is the unshifted version derived from `binomial_log_concave`.
-/
theorem binomial_log_concave' (m k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (Nat.choose m k) ^ 2 ≥ Nat.choose m (k - 1) * Nat.choose m (k + 1) := by
  rcases k with ( _ | k ) <;> rcases m with ( _ | m ) <;> norm_num [ Nat.add_one_mul_choose_eq ] at *;
  have := binomial_log_concave ( m - 1 ) k ?_ <;> cases m <;> cases k <;> simp_all +arith +decide [ Nat.choose ]

/-
**The binomial coefficient sequence is log-concave.**
    This packages `binomial_log_concave` in the `LogConcaveSeq` format,
    connecting the pointwise inequality to the sequence-level property.
-/
theorem binomial_is_log_concave_seq (n : ℕ) :
    LogConcaveSeq (fun k => (n.choose k : ℝ)) 0 n := by
  intro k hk1 hk2; by_cases hk : 1 ≤ k <;> simp_all +decide [ Nat.choose_eq_zero_of_lt ] ;
  exact_mod_cast binomial_log_concave' n k hk ( by linarith )

/-
**Binomial ratio monotonicity**: `C(n,k+1)/C(n,k)` is nonincreasing.
    Specialization of `log_concave_ratio_antitone` to binomial coefficients.
    This is equivalent to saying (n-k)/(k+1) is decreasing in k.
-/
theorem binomial_ratio_antitone (n k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ n)
    (hk3 : 0 < Nat.choose n (k - 1)) :
    (n.choose (k + 1) : ℝ) / (n.choose k) ≤ (n.choose k : ℝ) / (n.choose (k - 1)) := by
  rw [ div_le_div_iff₀ ] <;> norm_cast;
  · nlinarith [ binomial_log_concave' n k hk1 hk2 ];
  · exact Nat.choose_pos ( by linarith )

/-! ## Testable Conjecture -/

/-- **Testable Conjecture (Corrected Shadow Log-Concavity)**:
    For any M-convex set S ⊆ ℕⁿ, the shadow profile `a_k = |Sh_k(S)|`
    is log-concave (without normalization): `a_k² ≥ a_{k-1} · a_{k+1}`.

    This avoids the false D = max-degree normalization shown in
    `conjecture_counterexample`. For uniform matroids, this reduces to
    `binomial_log_concave`.

    **Computational test**: Enumerate all graphic matroids on ≤ 8 edges
    and all uniform matroids U(r,n) with n ≤ 12. Compute shadow profiles
    and verify log-concavity. A single counterexample falsifies. -/
def corrected_shadow_conjecture : Prop :=
  ∀ (n : ℕ) (S : Finset (Fin n → ℕ)),
    MConvex S →
    ∀ k : ℕ, 1 ≤ k →
      (ShadowSet S k).ncard ^ 2 ≥
      (ShadowSet S (k - 1)).ncard * (ShadowSet S (k + 1)).ncard

end ShadowHodge