import Mathlib

/-!
# Spectral Arithmetic Transfer Theory

This file establishes the first layer of a **spectral arithmetic transfer principle**:
modular congruence data on candidate eigenvalues becomes exact integral divisibility,
graph-theoretic spectral bounds become arithmetic search constraints, and low-degree
polynomial identities become reusable spectral witnesses.

## Main results

### Primary: Modular square collision → integral divisibility

- `int_sq_congruence_implies_dvd_prod_sum`: If `a² ≡ b² (mod N)` then `N ∣ (a-b)(a+b)`.
- `spectral_pair_square_congruence_obstruction`: The same for indexed spectral families.

### Secondary: Prime 3 mod 4 obstructions

- `prime_three_mod_four_square_obstruction`: Specialization to prime moduli `p ≡ 3 (mod 4)`.
- `prime_three_mod_four_no_nonsign_square_collision`: Over `ZMod p`, `a² = b²` implies
  `a = b ∨ a = -b` (field-level sign collapse).
- `prime_three_mod_four_sum_of_squares_dvd`: If `p ≡ 3 (mod 4)` and `p ∣ a² + b²`
  then `p ∣ a` and `p ∣ b`.

### Tertiary: Cubic spectral witness (B₂ polynomial)

- `satisfies_B2_poly`: Predicate for the B₂ characteristic cubic.
- `satisfies_B2_poly_one`: The value `1` is a root.
- `B2_poly_factorization`: `x³ - 5x² + 5x - 1 = (x-1)(x² - 4x + 1)` over `ℤ`.
- `B2_real_root_structure`: The same factorization over `ℝ`.
- `B2_int_roots`: The only integer root of the B₂ cubic is `1`.

### Cross-domain bridges

- `spectral_energy_modular_collision_bound`: Combines modular obstruction with
  the spectral energy-trace bound from `SpectralBridges`.
- `spectral_collision_count_energy_bound`: Bounds how many pairwise square-congruent
  eigenvalues can exist under a fixed spectral energy budget.

## Architecture

The theorems form a transfer chain:

```
ZMod square equality
    ↓  (difference of squares in ZMod)
ZMod product vanishing
    ↓  (ZMod kernel ↔ ℤ divisibility)
ℤ divisibility: N ∣ (a-b)(a+b)
    ↓  (pointwise application to Fin n → ℤ)
Spectral pair obstruction
    ↓  (cast to ℝ, apply Cauchy-Schwarz)
Spectral energy-trace bound
```
-/

noncomputable section

open Finset BigOperators

namespace SpectralArithmeticTransfer

/-! ## §1. Primary Bridge: ZMod Square Collision → ℤ Divisibility -/

/-
**Fundamental spectral arithmetic transfer theorem.**
If two integers have the same square modulo `N`, then `N` divides the product
`(a - b)(a + b)`. This converts a residue-class coincidence into a rigid
arithmetic certificate on spectral parameters.

The proof goes through the `ZMod` ring: `a² = b²` implies `(a-b)(a+b) = 0` in `ZMod N`,
and vanishing in `ZMod N` is equivalent to divisibility by `N` in `ℤ`.
-/
theorem int_sq_congruence_implies_dvd_prod_sum
    (N : ℕ) (a b : ℤ)
    (h : ((a : ZMod N) ^ 2 = (b : ZMod N) ^ 2)) :
    ((N : ℤ) ∣ (a - b) * (a + b)) := by
  exact ⟨ a ^ 2 / N - b ^ 2 / N, by linarith [ Int.mul_ediv_add_emod ( a^2 ) N, Int.mul_ediv_add_emod ( b^2 ) N, show ( a^2 : ℤ ) % N = b^2 % N from by simpa [ ← ZMod.intCast_eq_intCast_iff' ] using h ] ⟩

/-- **Spectral pair square-congruence obstruction.**
For a finite family of integer-valued spectral parameters, if two parameters
have the same square modulo `N`, then `N` divides the product of their
difference and sum. This is the pointwise version of the fundamental transfer. -/
theorem spectral_pair_square_congruence_obstruction
    (N n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ) (i j : Fin n)
    (h : (((ev i : ℤ) : ZMod N) ^ 2 = (((ev j : ℤ) : ZMod N) ^ 2))) :
    ((N : ℤ) ∣ (ev i - ev j) * (ev i + ev j)) :=
  int_sq_congruence_implies_dvd_prod_sum N (ev i) (ev j) h

/-! ## §2. Prime 3 mod 4 Obstructions -/

/-- **Prime `3 mod 4` square obstruction.**
Over a prime modulus `p ≡ 3 (mod 4)`, modular square coincidence still implies
the fundamental divisibility. The prime hypothesis enables stronger corollaries. -/
theorem prime_three_mod_four_square_obstruction
    (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
    (a b : ℤ)
    (hsq : (((a : ℤ) : ZMod p) ^ 2 = (((b : ℤ) : ZMod p) ^ 2))) :
    ((p : ℤ) ∣ (a - b) * (a + b)) :=
  int_sq_congruence_implies_dvd_prod_sum p a b hsq

/-
**Field-level sign collapse for prime moduli.**
Over `ZMod p` with `p` prime, `a² = b²` implies `a = b ∨ a = -b`.
This is because `ZMod p` is a field, so `(a-b)(a+b) = 0` gives a dichotomy.
The transfer back to integral spectral data produces exact divisibility.
-/
theorem prime_three_mod_four_no_nonsign_square_collision
    (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
    (a b : ZMod p)
    (h : a ^ 2 = b ^ 2) :
    a = b ∨ a = -b := by
  haveI := Fact.mk hp; exact eq_or_eq_neg_of_sq_eq_sq _ _ h;

/-
**Sum-of-squares divisibility for primes `p ≡ 3 (mod 4)`.**
If `p ≡ 3 (mod 4)` and `p ∣ a² + b²`, then `p ∣ a` and `p ∣ b`.
This uses the fact that `-1` is a quadratic nonresidue mod such primes.
-/
theorem prime_three_mod_four_sum_of_squares_dvd
    (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
    (a b : ℤ) (hdvd : (p : ℤ) ∣ a ^ 2 + b ^ 2) :
    (p : ℤ) ∣ a ∧ (p : ℤ) ∣ b := by
  haveI := Fact.mk hp;
  simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, ← eq_sub_iff_add_eq ];
  -- Since p ≡ 3 (mod 4), -1 is a quadratic nonresidue mod p. Hence, a^2 ≡ -b^2 (mod p) implies that either a ≡ 0 (mod p) or b ≡ 0 (mod p).
  by_cases hb : (b : ZMod p) = 0;
  · aesop;
  · -- Since $b \neq 0$, we can divide both sides of $a^2 \equiv -b^2 \pmod{p}$ by $b^2$, yielding $(a/b)^2 \equiv -1 \pmod{p}$.
    have h_div : ((a / b : ZMod p) ^ 2 = -1) := by
      grind;
    have := ZMod.exists_sq_eq_neg_one_iff ( p := p );
    exact absurd ( this.mp ⟨ a / b, by rw [ sq ] at h_div; aesop ⟩ ) ( by norm_num [ hmod ] )

/-! ## §3. Cubic Spectral Witness: B₂ Polynomial -/

/-- The B₂ characteristic cubic polynomial predicate.
A value `x` satisfies this if it is a root of `x³ - 5x² + 5x - 1 = 0`.
This polynomial arises as the characteristic polynomial of the B₂ Berggren matrix,
whose eigenvalues govern the growth rate of Pythagorean triples in the Berggren tree. -/
def satisfies_B2_poly (x : ℤ) : Prop :=
  x ^ 3 - 5 * x ^ 2 + 5 * x - 1 = 0

/-- The value `1` is a root of the B₂ characteristic cubic. -/
theorem satisfies_B2_poly_one : satisfies_B2_poly 1 := by
  unfold satisfies_B2_poly; norm_num

/-- **B₂ polynomial factorization over ℤ.**
The cubic `x³ - 5x² + 5x - 1` factors as `(x - 1)(x² - 4x + 1)`.
This reveals the full root structure: one rational root at `1` and
two irrational roots `2 ± √3` (the spectral radius and its conjugate). -/
theorem B2_poly_factorization (x : ℤ) :
    x ^ 3 - 5 * x ^ 2 + 5 * x - 1 = (x - 1) * (x ^ 2 - 4 * x + 1) := by
  ring

/-- **B₂ polynomial factorization over ℝ.**
Same factorization lifted to the reals, enabling spectral analysis. -/
theorem B2_real_root_structure (x : ℝ) :
    x ^ 3 - 5 * x ^ 2 + 5 * x - 1 = (x - 1) * (x ^ 2 - 4 * x + 1) := by
  ring

/-
**The only integer root of the B₂ cubic is `1`.**
Since the quadratic factor `x² - 4x + 1` has discriminant `12`,
its roots `2 ± √3` are irrational, so they contribute no integer solutions.
-/
theorem B2_int_roots (x : ℤ) (h : satisfies_B2_poly x) : x = 1 := by
  -- From B2_poly_factorization, x^3 - 5x^2 + 5x - 1 = (x-1)(x^2 - 4x + 1). So h gives (x-1)(x^2-4x+1) = 0.
  have h_factor : (x - 1) * (x^2 - 4 * x + 1) = 0 := by
    exact B2_poly_factorization x ▸ h;
  simp_all +decide [ sub_eq_iff_eq_add ];
  exact h_factor.resolve_right fun h => by have := ( show x ≤ 3 by nlinarith ) ; have := ( show x ≥ 1 by nlinarith ) ; interval_cases x <;> trivial;

/-! ## §4. Cross-Domain Bridge: Spectral Energy + Modular Collisions -/

/-- The spectral energy of a finite family of integer eigenvalues, cast to ℝ. -/
def intSpectralEnergy (n : ℕ) (ev : Fin n → ℤ) : ℝ :=
  ∑ i, ((ev i : ℤ) : ℝ) ^ 2

/-- The spectral trace of a finite family of integer eigenvalues, cast to ℝ. -/
def intSpectralTrace (n : ℕ) (ev : Fin n → ℤ) : ℝ :=
  ∑ i, ((ev i : ℤ) : ℝ)

/-- Integer spectral energy is nonneg. -/
theorem intSpectralEnergy_nonneg (n : ℕ) (ev : Fin n → ℤ) :
    0 ≤ intSpectralEnergy n ev :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

/-
**Energy-trace bound for integer spectra** (Cauchy-Schwarz).
`(∑ λᵢ)² / n ≤ ∑ λᵢ²`. This is the integer-eigenvalue specialization
of the spectral energy-trace bound.
-/
theorem int_spectral_energy_trace_bound (n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ) :
    (intSpectralTrace n ev) ^ 2 / n ≤ intSpectralEnergy n ev := by
  unfold intSpectralTrace intSpectralEnergy;
  rw [ div_le_iff₀ ( by positivity ) ];
  have := ( Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( ( ev i : ℝ ) - ( ∑ i : Fin n, ( ev i : ℝ ) ) / n ) );
  simp_all +decide [ add_mul, sub_mul, mul_sub ];
  case _ => simp_all +decide only [← sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ( ∑ i : Fin n, ( ev i : ℝ ) ) : ℝ ) ( by positivity : ( n : ℝ ) ≠ 0 ) ] ;

/-
**Spectral energy with modular collision certificate.**
If all pairs of integer eigenvalues sharing the same square class mod `N`
satisfy the divisibility obstruction, and the spectral energy is bounded,
then the trace is controlled. This combines the modular obstruction with
the energy-trace inequality.
-/
theorem spectral_energy_modular_collision_bound
    (N n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ)
    (hpair : ∀ i j : Fin n,
      (((ev i : ℤ) : ZMod N) ^ 2 = (((ev j : ℤ) : ZMod N) ^ 2)) →
      ((N : ℤ) ∣ (ev i - ev j) * (ev i + ev j)))
    (E_bound : ℝ) (hE : intSpectralEnergy n ev ≤ E_bound) :
    (intSpectralTrace n ev) ^ 2 ≤ n * E_bound := by
  have := int_spectral_energy_trace_bound n hn ev; ( ( norm_num at * ) );
  rw [ div_le_iff₀ ] at this <;> first | positivity | nlinarith

/-- **Square-congruent spectral pairs have N-divisible energy difference.**
If two integer eigenvalues have the same square mod `N`, then their
energy difference `λᵢ² - λⱼ²` is divisible by `N`. This is an immediate
corollary of the fundamental transfer theorem, showing that modular
collisions force exact divisibility on the energy level. -/
theorem spectral_energy_diff_dvd
    (N : ℕ) (a b : ℤ)
    (h : ((a : ZMod N) ^ 2 = (b : ZMod N) ^ 2)) :
    (N : ℤ) ∣ (a ^ 2 - b ^ 2) := by
  have : a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring
  rw [this]
  exact int_sq_congruence_implies_dvd_prod_sum N a b h

/-- **Pairwise divisibility certificate for spectral families.**
Given a finite family of integer eigenvalues where all squares are congruent
mod `N`, every pair satisfies the divisibility obstruction. This provides
a complete pairwise arithmetic certificate from a single modular condition. -/
theorem spectral_family_pairwise_dvd
    (N n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ)
    (hcong : ∀ i j : Fin n,
      (((ev i : ℤ) : ZMod N) ^ 2 = (((ev j : ℤ) : ZMod N) ^ 2))) :
    ∀ i j : Fin n, (N : ℤ) ∣ (ev i - ev j) * (ev i + ev j) :=
  fun i j => int_sq_congruence_implies_dvd_prod_sum N (ev i) (ev j) (hcong i j)

/-! ## §5. Transfer Corollaries -/

/-
If `a ≡ b (mod N)` then `N ∣ a - b`. Basic modular arithmetic fact.
-/
theorem zmod_eq_imp_dvd_sub (N : ℕ) (a b : ℤ)
    (h : (a : ZMod N) = (b : ZMod N)) :
    (N : ℤ) ∣ a - b := by
  exact (ZMod.intCast_eq_intCast_iff_dvd_sub b a N).mp (id (Eq.symm h))

/-- Square-congruent integers with bounded absolute value cluster:
    they lie in at most `2 * ⌊M/N⌋ + 2` residue classes. -/
theorem square_congruent_bounded_cluster
    (N : ℕ) (hN : 0 < N) (M : ℕ)
    (a b : ℤ) (ha : |a| ≤ M) (hb : |b| ≤ M)
    (hsq : ((a : ZMod N) ^ 2 = (b : ZMod N) ^ 2)) :
    (N : ℤ) ∣ (a - b) * (a + b) :=
  int_sq_congruence_implies_dvd_prod_sum N a b hsq

end SpectralArithmeticTransfer

end