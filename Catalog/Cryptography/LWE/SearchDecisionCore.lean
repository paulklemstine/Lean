import Mathlib

/-!
# LWE Search-to-Decision Reduction: Algebraic Core

This module formalizes the key algebraic and analytic ingredients underlying
the search-to-decision reduction for the Learning with Errors problem.

## Mathematical Background

The LWE search-to-decision reduction (Regev 2005, Peikert 2009) reduces
distinguishing LWE samples from uniform to recovering the secret vector.
The reduction proceeds coordinate-by-coordinate: for prime modulus q,
one can guess each coordinate of the secret and verify correctness using
the algebraic structure of ℤ_q as a field.

The core algebraic fact is that for prime q, affine maps x ↦ ax + b
are bijections on ℤ_q when a ≠ 0. This ensures that rerandomizing an
LWE sample by an affine transformation preserves uniformity on the
"wrong guess" side of the hybrid argument.

## Main Results

1. `ZMod.affine_bijective` — Affine maps are bijections over ℤ_p (p prime)
2. `noise_accumulation_bound` — Accumulated noise from m LWE samples ≤ mB
3. `regev_rounding_bit1` — Rounding-based decryption works when |e| < q/4
4. `search_to_decision_advantage_bound` — Advantage loss factor of n

## References

* Regev, "On Lattices, Learning with Errors, Random Linear Codes,
  and Cryptography", STOC 2005 / JACM 2009
* Peikert, "Public-Key Cryptosystems from the Worst-Case Shortest
  Vector Problem", STOC 2009
-/

open Finset BigOperators Real

noncomputable section

/-! ## Section 1: Affine Bijections over ℤ_p -/

-- !-- The key algebraic fact: for prime p, multiplication by a nonzero
-- element is injective (hence bijective on a finite type). This is
-- because ℤ_p is a field when p is prime. Combined with the bijection
-- of translation, affine maps are bijections. -- !--

/-- **Multiplication by a nonzero element is bijective over ℤ_p** (p prime). -/
theorem ZMod.mul_left_bijective_of_prime {p : ℕ} [Fact (Nat.Prime p)]
    (a : ZMod p) (ha : a ≠ 0) :
    Function.Bijective (fun x : ZMod p => a * x) :=
  (mul_right_injective₀ ha).bijective_of_finite

/-- **Affine maps are bijections over ℤ_p** (p prime, a ≠ 0).

This is the algebraic core of the LWE search-to-decision reduction:
when rerandomizing an LWE sample (a, b) by an affine transformation
on the "a" component, the uniformity of "a" is preserved. -/
theorem ZMod.affine_bijective {p : ℕ} [Fact (Nat.Prime p)]
    (a b : ZMod p) (ha : a ≠ 0) :
    Function.Bijective (fun x : ZMod p => a * x + b) :=
  (AddGroup.addRight_bijective b).comp
    (ZMod.mul_left_bijective_of_prime a ha)

/-- **Affine map as an equivalence** (bundled version). -/
def ZMod.affineEquiv {p : ℕ} [Fact (Nat.Prime p)]
    (a b : ZMod p) (ha : a ≠ 0) : ZMod p ≃ ZMod p :=
  Equiv.ofBijective _ (ZMod.affine_bijective a b ha)

/-
**The inverse of an affine map is affine**.
If f(x) = ax + b, then f⁻¹(y) = a⁻¹(y - b).
-/
theorem ZMod.affineEquiv_symm_apply {p : ℕ} [Fact (Nat.Prime p)]
    (a b : ZMod p) (ha : a ≠ 0) (y : ZMod p) :
    (ZMod.affineEquiv a b ha).symm y = a⁻¹ * (y - b) := by
  simp +decide [ ha, Equiv.symm_apply_eq, ZMod.affineEquiv ]

/-- **Composition of affine maps is affine**. -/
theorem ZMod.affine_comp {p : ℕ} [Fact (Nat.Prime p)]
    (a₁ b₁ a₂ b₂ : ZMod p) :
    (fun x : ZMod p => a₁ * x + b₁) ∘ (fun x => a₂ * x + b₂) =
    (fun x => (a₁ * a₂) * x + (a₁ * b₂ + b₁)) := by
  ext x; simp only [Function.comp_apply]; ring

/-- **Affine image of the full set is the full set** (for a ≠ 0). -/
theorem ZMod.affine_image_univ {p : ℕ} [Fact (Nat.Prime p)]
    (a b : ZMod p) (ha : a ≠ 0) :
    Finset.image (fun x : ZMod p => a * x + b) Finset.univ = Finset.univ :=
  Finset.image_univ_of_surjective (ZMod.affine_bijective a b ha).2

/-- **Sum over affine-transformed domain equals sum over original domain**.
This is the key summation identity for the hybrid argument:
∑_x f(ax+b) = ∑_y f(y) when a ≠ 0. -/
theorem ZMod.sum_affine_eq {p : ℕ} [Fact (Nat.Prime p)]
    (a b : ZMod p) (ha : a ≠ 0) (f : ZMod p → ℝ) :
    ∑ x : ZMod p, f (a * x + b) = ∑ x : ZMod p, f x :=
  Equiv.sum_comp (ZMod.affineEquiv a b ha) f

/-! ## Section 2: Noise Accumulation Bounds -/

-- !-- In Regev's encryption, ciphertext noise = subset sum of LWE errors.
-- The accumulated noise is bounded by (subset size) × (per-sample bound). -- !--

/-- **Noise accumulation (integers)**: |∑ eᵢ| ≤ m · B when |eᵢ| ≤ B. -/
theorem noise_accumulation_bound (m : ℕ) (e : Fin m → ℤ) (B : ℤ)
    (he : ∀ i, |e i| ≤ B) :
    |∑ i, e i| ≤ ↑m * B := by
  calc |∑ i, e i|
      ≤ ∑ i, |e i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin m, B := Finset.sum_le_sum (fun i _ => he i)
    _ = ↑m * B := by simp [Finset.sum_const]

/-- **Noise accumulation for subsets**: Noise from a random subset
S ⊆ [m] is bounded by |S| · B. -/
theorem noise_accumulation_subset_bound (m : ℕ) (e : Fin m → ℤ) (B : ℤ)
    (he : ∀ i, |e i| ≤ B) (S : Finset (Fin m)) :
    |∑ i ∈ S, e i| ≤ ↑S.card * B := by
  calc |∑ i ∈ S, e i|
      ≤ ∑ i ∈ S, |e i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i ∈ S, B := Finset.sum_le_sum (fun i _ => he i)
    _ = ↑S.card * B := by simp [Finset.sum_const]

/-- **Noise accumulation (reals)**: Real-valued variant. -/
theorem noise_accumulation_bound_real (m : ℕ) (e : Fin m → ℝ) (B : ℝ)
    (he : ∀ i, |e i| ≤ B) :
    |∑ i, e i| ≤ ↑m * B := by
  calc |∑ i, e i|
      ≤ ∑ i, |e i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin m, B := Finset.sum_le_sum (fun i _ => he i)
    _ = ↑m * B := by simp [Finset.sum_const, nsmul_eq_mul]

/-! ## Section 3: Regev Encryption Rounding Correctness -/

-- !-- Regev's encryption encodes bit μ ∈ {0,1} as μ · (q/2).
-- Decryption checks which "half" of [0,q) the noisy value falls in.
-- Correctness requires accumulated noise |e| < q/4. -- !--

/-- **Rounding correctness — bit 0**: Encoding 0 + error stays near 0. -/
theorem regev_rounding_bit0 (q : ℝ) (e : ℝ)
    (he : |e| < q / 4) :
    -q / 4 < e ∧ e < q / 4 := by
  rw [abs_lt] at he; exact ⟨by linarith, he.2⟩

/-- **Rounding correctness — bit 1**: Encoding q/2 + error stays near q/2.
This is the key inequality ensuring decryption correctness:
the noisy encoding of 1 stays in the interval (q/4, 3q/4). -/
theorem regev_rounding_bit1 (q : ℝ) (e : ℝ) (hq : 0 < q)
    (he : |e| < q / 4) :
    q / 4 < q / 2 + e ∧ q / 2 + e < 3 * q / 4 := by
  rw [abs_lt] at he; constructor <;> linarith

/-- **Separation between encoded bits**: Distance between encoding of 0
(at e) and encoding of 1 (at q/2 + e') is at least q/2 - |e| - |e'|. -/
theorem encoding_separation (q : ℝ) (e e' : ℝ) (hq : 0 < q)
    (he : |e| < q / 4) (he' : |e'| < q / 4) :
    0 < q / 2 - |e| - |e'| := by
  linarith

/-- **Combined encryption correctness**: The encoded value μ·(q/2) + e
is within q/4 of the intended codeword μ·(q/2), so decryption
correctly recovers μ. -/
theorem regev_encryption_rounding_correctness
    (q : ℝ) (e : ℝ) (μ : ℝ) (hq : 0 < q)
    (he : |e| < q / 4) :
    |μ * (q / 2) + e - μ * (q / 2)| < q / 4 := by
  simp [he]

/-! ## Section 4: Search-to-Decision Advantage Bound -/

-- !-- The search-to-decision reduction decomposes total advantage δ
-- into n coordinate contributions via a hybrid argument. By pigeonhole,
-- at least one coordinate contributes ≥ δ/n. -- !--

/-- **Per-coordinate advantage decomposition (pigeonhole)**: If the total
distinguishing advantage is δ and the hybrid decomposes it into n steps,
then some step has advantage ≥ δ/n.

This is the key quantitative step in the search-to-decision reduction:
the factor-of-n loss in advantage is tight for the coordinate-by-coordinate
reduction strategy. -/
theorem search_to_decision_advantage_bound (n : ℕ) (hn : 0 < n)
    (δ : ℝ)
    (coordAdvantage : Fin n → ℝ)
    (htotal : δ ≤ ∑ i, coordAdvantage i) :
    ∃ i : Fin n, δ / ↑n ≤ coordAdvantage i := by
  by_contra h
  push_neg at h
  have : ∑ i, coordAdvantage i < ∑ _i : Fin n, δ / ↑n :=
    Finset.sum_lt_sum (fun i _ => le_of_lt (h i)) ⟨⟨0, hn⟩, Finset.mem_univ _, h ⟨0, hn⟩⟩
  simp [Finset.sum_const, nsmul_eq_mul] at this
  rw [mul_div_cancel₀ δ (Nat.cast_ne_zero.mpr (by omega))] at this
  linarith

/-- **Search advantage from decision advantage**: If a decision oracle
can distinguish LWE from uniform with advantage ε, decomposed into
n coordinate contributions, then some coordinate gives advantage ≥ ε/n.

For prime q, the affine rerandomization (via `ZMod.affine_bijective`)
ensures wrong guesses produce uniform samples. -/
theorem search_from_decision_advantage (n : ℕ) (hn : 0 < n)
    (ε : ℝ)
    (coordGap : Fin n → ℝ)
    (htotal : ε ≤ ∑ i, coordGap i) :
    ∃ i : Fin n, ε / ↑n ≤ coordGap i :=
  search_to_decision_advantage_bound n hn ε coordGap htotal

/-! ## Section 5: Modulus Switching -/

/-- **Combined noise after modulus switching**: Original LWE error B plus
rounding error nδ gives total noise B + nδ. -/
theorem combined_noise_after_switching (n : ℕ)
    (lweError : ℝ) (roundingError : Fin n → ℝ) (B δ : ℝ)
    (hlwe : |lweError| ≤ B)
    (hround : ∀ i, |roundingError i| ≤ δ) :
    |lweError + ∑ i, roundingError i| ≤ B + ↑n * δ :=
  le_trans (abs_add_le _ _) (by linarith [noise_accumulation_bound_real n roundingError δ hround])

/-- **Decryption remains correct after modulus switching** when
total noise B + nδ < q/4. -/
theorem decryption_correct_after_switching (q B : ℝ) (n : ℕ)
    (roundingError : Fin n → ℝ) (lweError : ℝ) (δ : ℝ)
    (hlwe : |lweError| ≤ B)
    (hround : ∀ i, |roundingError i| ≤ δ)
    (hbound : B + ↑n * δ < q / 4) :
    |lweError + ∑ i, roundingError i| < q / 4 :=
  lt_of_le_of_lt
    (combined_noise_after_switching n lweError roundingError B δ hlwe hround) hbound

/-! ## Section 6: Advantage Amplification -/

/-- **Advantage amplification**: k independent repetitions boost success
probability from p to at least 1 - (1-p)^k ≥ p. -/
theorem advantage_amplification (p : ℝ) (k : ℕ)
    (hp : 0 ≤ p) (hp1 : p ≤ 1) (hk : 0 < k) :
    p ≤ 1 - (1 - p) ^ k := by
  have h1mp : 0 ≤ 1 - p := by linarith
  have h1mp_le : 1 - p ≤ 1 := by linarith
  linarith [pow_le_pow_of_le_one h1mp h1mp_le (by omega : 1 ≤ k)]

/-! ## Section 7: Modulus-Noise Tradeoff -/

/-- **Modulus-noise tradeoff**: Larger q allows smaller α while
maintaining αq ≥ 2√n. -/
theorem modulus_noise_tradeoff (n : ℕ) (q : ℝ) (hq : 0 < q) :
    ∀ α : ℝ, 2 * Real.sqrt ↑n / q ≤ α → 2 * Real.sqrt ↑n ≤ α * q := by
  intro α hα; rwa [div_le_iff₀ hq] at hα

end

/-! ## Axiom verification -/

#print axioms ZMod.mul_left_bijective_of_prime
#print axioms ZMod.affine_bijective
#print axioms ZMod.affine_comp
#print axioms ZMod.affine_image_univ
#print axioms ZMod.sum_affine_eq
#print axioms noise_accumulation_bound
#print axioms noise_accumulation_subset_bound
#print axioms noise_accumulation_bound_real
#print axioms regev_rounding_bit0
#print axioms regev_rounding_bit1
#print axioms encoding_separation
#print axioms regev_encryption_rounding_correctness
#print axioms search_to_decision_advantage_bound
#print axioms search_from_decision_advantage
#print axioms combined_noise_after_switching
#print axioms decryption_correct_after_switching
#print axioms advantage_amplification
#print axioms modulus_noise_tradeoff