/-
  # Selberg Class Census: Combinatorial Framework

  This file formalizes the combinatorial structure underlying a census of
  the Selberg class of L-functions. We work with the *datum* associated
  to an L-function — its degree, conductor, and spectral parameters —
  rather than the analytic object itself.

  ## Main definitions
  - `SelbergDatum`: the finite invariant data (degree, conductor, spectral shifts)
  - `SpectralComplexity`: a rational-valued "energy" invariant
  - `SpectralEntropy`: arithmetic height of spectral parameters
  - `SelbergDatum.product`: Rankin-Selberg product of data

  ## Main results
  - Countability of the set of all Selberg data
  - Additivity of spectral complexity under products
  - Additivity of spectral entropy under products
  - Minimality of the Riemann zeta datum
  - Polynomial bound on conductor counting function
  - Well-foundedness of the factorization ordering
-/
import Mathlib

open Finset BigOperators

/-! ## Selberg Datum -/

/-- A `SelbergDatum` captures the finite invariant data associated to a
    Selberg class L-function: its degree `d`, conductor `q`, and a list
    of spectral shift parameters `μ` (rational approximations of the
    actual shifts, sufficient for the combinatorial census). -/
structure SelbergDatum where
  /-- The degree of the L-function (number of Gamma factors). -/
  d : ℕ
  /-- The conductor (a positive natural number). -/
  q : ℕ
  /-- Spectral shift parameters, one per Gamma factor. -/
  μ : List ℚ
  /-- The number of spectral parameters equals the degree. -/
  μ_length : μ.length = d
  /-- The conductor is positive. -/
  q_pos : 0 < q
  deriving DecidableEq

/-! ## Countability -/

/-- The type of Selberg data is countable, because it injects into
    ℕ × ℕ × List ℚ. -/
instance : Countable SelbergDatum := by
  apply Countable.of_equiv { p : ℕ × ℕ × List ℚ // p.2.2.length = p.1 ∧ 0 < p.2.1 }
  · exact {
      toFun := fun ⟨⟨n, q, μ⟩, hlen, hq⟩ => ⟨n, q, μ, hlen, hq⟩
      invFun := fun s => ⟨⟨s.d, s.q, s.μ⟩, s.μ_length, s.q_pos⟩
      left_inv := by intro ⟨⟨n, q, μ⟩, hlen, hq⟩; simp
      right_inv := by intro ⟨d, q, μ, hl, hq⟩; simp
    }

/-! ## Spectral Complexity -/

/-- The spectral complexity of a datum is the sum of absolute values of
    its spectral parameters plus its degree. This measures the "analytic
    cost" of the L-function. -/
noncomputable def spectralComplexity (s : SelbergDatum) : ℚ :=
  s.d + (s.μ.map (fun x => |x|)).sum

/-- The Riemann zeta function datum: degree 1, conductor 1, single
    spectral parameter 0. -/
def zetaDatum : SelbergDatum where
  d := 1
  q := 1
  μ := [0]
  μ_length := rfl
  q_pos := Nat.one_pos

/-- The spectral complexity of the zeta datum is exactly 1. -/
theorem spectralComplexity_zeta : spectralComplexity zetaDatum = 1 := by
  simp [spectralComplexity, zetaDatum, abs_of_nonneg]

/-! ## Spectral Entropy -/

/-- The spectral entropy of a datum measures the arithmetic height of its
    spectral parameters: sum of (|numerator| + denominator) for each
    parameter in lowest terms. This captures the arithmetic complexity
    of the spectral shifts, independent of conductor. -/
noncomputable def spectralEntropy (s : SelbergDatum) : ℚ :=
  (s.μ.map (fun x => (|x.num| : ℚ) + x.den)).sum

/-- The spectral entropy of the zeta datum equals 1 (the single
    parameter 0 has |0| + 1 = 1). -/
theorem spectralEntropy_zeta : spectralEntropy zetaDatum = 1 := by
  simp [spectralEntropy, zetaDatum]

/-! ## Product Structure -/

/-- The Rankin-Selberg product of two Selberg data concatenates their
    spectral parameters and multiplies their conductors.
    This models the tensor product of L-functions. -/
def SelbergDatum.product (s₁ s₂ : SelbergDatum) : SelbergDatum where
  d := s₁.d + s₂.d
  q := s₁.q * s₂.q
  μ := s₁.μ ++ s₂.μ
  μ_length := by simp [List.length_append, s₁.μ_length, s₂.μ_length]
  q_pos := Nat.mul_pos s₁.q_pos s₂.q_pos

/-
Spectral complexity is additive under products. This is the key
    structural property making it useful as an invariant.
-/
theorem spectralComplexity_product (s₁ s₂ : SelbergDatum) :
    spectralComplexity (s₁.product s₂) = spectralComplexity s₁ + spectralComplexity s₂ := by
  unfold spectralComplexity SelbergDatum.product;
  simp +decide [ add_comm, add_left_comm, add_assoc ]

/-
Spectral entropy is additive under products, because the spectral
    parameter lists concatenate.
-/
theorem spectralEntropy_product (s₁ s₂ : SelbergDatum) :
    spectralEntropy (s₁.product s₂) = spectralEntropy s₁ + spectralEntropy s₂ := by
  unfold spectralEntropy SelbergDatum.product; aesop;

/-! ## Minimality of the Zeta Datum -/

/-
For any Selberg datum with d ≥ 1, spectral complexity is at least 1.
-/
theorem spectralComplexity_ge_one (s : SelbergDatum) (hd : 1 ≤ s.d) :
    1 ≤ spectralComplexity s := by
  exact le_add_of_le_of_nonneg ( mod_cast hd ) ( List.sum_nonneg ( by aesop ) )

/-! ## Conductor Counting Function -/

/-- We define a finite approximation: data with degree d, conductor ≤ Q,
    and all spectral parameters having numerator and denominator bounded by B. -/
def countBoundedData (d Q B : ℕ) : ℕ :=
  (Finset.Icc 1 Q).card *
    ((Finset.Icc (-(B : ℤ)) B ×ˢ Finset.Icc 1 B).card ^ d)

/-
The counting function is monotone in Q.
-/
theorem countBoundedData_mono_Q (d B : ℕ) :
    Monotone (fun Q => countBoundedData d Q B) := by
  -- The cardinality of the set of integers from 1 to Q is non-decreasing in Q.
  have h_card_Icc : Monotone (fun Q : ℕ => (Finset.Icc 1 Q).card) := by
    exact fun a b hab => Finset.card_mono <| Finset.Icc_subset_Icc_right hab;
  exact fun Q Q' hQQ' => mul_le_mul_of_nonneg_right ( h_card_Icc hQQ' ) ( by positivity )

/-
The counting function is monotone in B.
-/
theorem countBoundedData_mono_B (d Q : ℕ) :
    Monotone (fun B => countBoundedData d Q B) := by
  refine' fun B B' h => mul_le_mul_of_nonneg_left _ ( by positivity );
  exact pow_le_pow_left₀ ( Nat.zero_le _ ) ( Finset.card_le_card <| Finset.product_subset_product ( Finset.Icc_subset_Icc ( by linarith ) ( by linarith ) ) ( Finset.Icc_subset_Icc ( by linarith ) ( by linarith ) ) ) _

/-
The counting function satisfies a polynomial bound in Q.
    Specifically, countBoundedData d Q B ≤ Q * ((2*B+1) * B)^d.
-/
theorem countBoundedData_poly_bound (d Q B : ℕ) :
    countBoundedData d Q B ≤ Q * ((2 * B + 1) * B) ^ d := by
  unfold countBoundedData;
  norm_num [ two_mul, add_assoc ];
  grind

/-! ## Well-Founded Factorization Ordering -/

/-- The factorization ordering on Selberg data: s₁ < s₂ if s₁ has
    strictly smaller degree or same degree with strictly smaller conductor. -/
def selbergLT (s₁ s₂ : SelbergDatum) : Prop :=
  s₁.d < s₂.d ∨ (s₁.d = s₂.d ∧ s₁.q < s₂.q)

/-
The factorization ordering is well-founded. This ensures that
    every L-function can be uniquely decomposed into primitive factors
    via a finite sequence of factorizations.
-/
theorem selbergLT_wf : WellFounded selbergLT := by
  -- The lexicographic order on pairs of natural numbers is well-founded.
  have h_lex_wf : WellFounded (fun (p q : ℕ × ℕ) => p.1 < q.1 ∨ (p.1 = q.1 ∧ p.2 < q.2)) := by
    convert ( WellFounded.prod_lex ( wellFounded_lt ) ( wellFounded_lt ) ) using 1;
    all_goals try infer_instance;
    grind +locals;
  rw [ WellFounded.wellFounded_iff_has_min ] at *;
  intro s hs; specialize h_lex_wf ( s.image fun x => ( x.d, x.q ) ) ; simp_all +decide [ selbergLT ] ;

/-! ## Degree-Conductor Energy -/

/-- The degree-conductor energy combines degree and conductor into a
    single natural number invariant. -/
def dcEnergy (s : SelbergDatum) : ℕ := s.d * s.q

/-
A nontrivial factor has strictly smaller degree-conductor energy.
-/
theorem dcEnergy_factor_lt (s₁ s₂ : SelbergDatum)
    (_hd₁ : 1 ≤ s₁.d) (hd₂ : 1 ≤ s₂.d) (hq₂ : 2 ≤ s₂.q) :
    dcEnergy s₁ < dcEnergy (s₁.product s₂) := by
  unfold dcEnergy SelbergDatum.product;
  nlinarith [ Nat.mul_le_mul_left s₁.d hq₂, Nat.mul_le_mul_left s₂.d s₁.q_pos ]

/-! ## Spectral Filtration -/

/-- The spectral filtration level of a datum is the maximum denominator
    appearing in its spectral parameters (or 1 if there are none). -/
def filtrationLevel (s : SelbergDatum) : ℕ :=
  (s.μ.map (fun x => x.den)).foldl max 1

/-! ## Primitive Datum Criterion -/

/-- A datum is primitive if it cannot be expressed as a nontrivial product.
    In the combinatorial model, this means degree 1. -/
def SelbergDatum.isPrimitive (s : SelbergDatum) : Prop :=
  s.d = 1

/-- The zeta datum is primitive. -/
theorem zetaDatum_isPrimitive : zetaDatum.isPrimitive := rfl

/-- The trivial (empty) datum used as identity for fold. -/
def trivialDatum : SelbergDatum where
  d := 0
  q := 1
  μ := []
  μ_length := rfl
  q_pos := Nat.one_pos

/-
Degree of a product of primitive data equals the number of factors.
-/
theorem degree_product_primitives (l : List SelbergDatum)
    (h : ∀ s ∈ l, SelbergDatum.isPrimitive s) :
    (l.foldl SelbergDatum.product trivialDatum).d = l.length := by
  induction' l using List.reverseRecOn with l ih;
  · rfl;
  · simp_all +decide [ SelbergDatum.product, SelbergDatum.isPrimitive ]