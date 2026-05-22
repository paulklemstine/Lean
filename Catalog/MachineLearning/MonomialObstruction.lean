import Mathlib

/-!
# Monomial Obstruction Theorem

This file proves that for monomial/powering maps `T(x) = x^d`, the logarithmic
evolution of iterates is exactly affine — there is no smoothing error term.
This makes the digit distribution of orbits depend entirely on the distribution
of `d^n * log_b(p) mod 1`, which is a rigid phase problem.

This is the "exceptional family" result: for such maps, Benford's law does not
follow automatically from growth estimates, but requires additional Diophantine
assumptions about the irrationality of `log_b(p)`.

## Main Results

- `monomial_iterate_log_eq`: For the monomial map, `log |T^[n](p)| = d^n * log p` exactly.
- `monomial_iterate_eq`: `(x^d)^[n] = x^(d^n)` for natural number iterates.
- `monomial_digit_reduces_to_torus`: Digit distribution reduces to torus dynamics.
- `monomial_rational_log_eventually_periodic`: Rational log_b gives eventually periodic phases.
-/

open Real Nat Function

/-- The monomial map `x ↦ x^d` iterated `n` times gives `x^(d^n)`.
    This is the key algebraic identity for the exceptional family. -/
theorem monomial_iterate_eq (d : ℕ) (x : ℤ) (n : ℕ) :
    (fun z : ℤ => z ^ d)^[n] x = x ^ (d ^ n) := by
  induction n <;> simp +decide [ *, pow_succ, pow_mul, Function.iterate_succ_apply' ]

/-- For the monomial map, `log |x^(d^n)| = d^n * log |x|` exactly
    (when `x ≠ 0`). This shows there is no smoothing error in the
    logarithmic evolution, making Benford behavior a pure equidistribution
    problem for `d^n * log_b |p| mod 1`. -/
theorem monomial_iterate_log_eq (d : ℕ) (hd : 2 ≤ d)
    (p : ℕ) (hp : Nat.Prime p) (n : ℕ) :
    Real.log ((p : ℝ) ^ (d ^ n)) = (d ^ n : ℕ) * Real.log (p : ℝ) := by
  simp +zetaDelta at *

/-- The fractional part of `log_b |T^[n](p)|` for a monomial map reduces
    exactly to `fract(d^n * log_b p)`. This means digit distributions
    are determined entirely by the orbit of `log_b p` under multiplication
    by `d` on the torus `ℝ/ℤ`. -/
theorem monomial_digit_reduces_to_torus (d b : ℕ) (hd : 2 ≤ d) (hb : 2 ≤ b)
    (p : ℕ) (hp : Nat.Prime p) (n : ℕ) :
    Int.fract (Real.log ((p : ℝ) ^ (d ^ n)) / Real.log (b : ℝ)) =
    Int.fract ((d ^ n : ℕ) * Real.log (p : ℝ) / Real.log (b : ℝ)) := by
  grind +suggestions

/-
For the monomial map `x ↦ x^d`, the sequence of fractional parts
    `{d^n * (a/q) mod 1}_{n ≥ 0}` is eventually periodic. This means
    that when `log_b(p) = a/q` is rational, the torus orbit is eventually
    periodic, and equidistribution can fail. This is the core obstruction
    mechanism for exceptional families.
-/
theorem monomial_rational_log_eventually_periodic (d q : ℕ) (hd : 2 ≤ d)
    (a : ℤ) (hq : 0 < q) :
    ∃ N₀ T : ℕ, 0 < T ∧ ∀ n : ℕ, N₀ ≤ n →
      Int.fract ((d ^ (n + T) : ℕ) * ((a : ℝ) / (q : ℝ))) =
      Int.fract ((d ^ n : ℕ) * ((a : ℝ) / (q : ℝ))) := by
  -- By the pigeonhole principle, there exist integers $i < j$ such that $d^i * a \equiv d^j * a \pmod{q}$.
  obtain ⟨i, j, h_lt, h_mod⟩ : ∃ i j : ℕ, i < j ∧ d ^ i * a ≡ d ^ j * a [ZMOD q] := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.mpr <| Set.Finite.subset ( Set.finite_Ico 0 ( q : ℤ ) ) <| Set.range_subset_iff.mpr fun n => ⟨ Int.emod_nonneg _ <| by positivity, Int.emod_lt_of_pos _ <| by positivity ⟩ );
  refine' ⟨ i, j - i, tsub_pos_of_lt h_lt, fun n hn => Int.fract_eq_fract.mpr _ ⟩;
  -- Since $d^i * a \equiv d^j * a \pmod{q}$, we have $d^{n + (j - i)} * a \equiv d^n * a \pmod{q}$ for all $n \geq i$.
  have h_cong : d ^ (n + (j - i)) * a ≡ d ^ n * a [ZMOD q] := by
    induction hn <;> simp_all +decide [ ← ZMod.intCast_eq_intCast_iff, pow_add ];
    · rw [ ← pow_add, add_tsub_cancel_of_le h_lt.le ];
    · linear_combination' ‹ ( d : ZMod q ) ^ _ * d ^ ( j - i ) * a = d ^ _ * a › * d;
  obtain ⟨ z, hz ⟩ := h_cong.symm.dvd;
  field_simp;
  exact ⟨ z, by push_cast; exact mod_cast ( by linarith : ( a : ℤ ) * ( d ^ ( n + ( j - i ) ) - d ^ n ) = q * z ) ⟩

/-
When `gcd(d, q) = 1`, the sequence is purely periodic (not just eventually).
-/
theorem monomial_rational_log_periodic_coprime (d q : ℕ) (hd : 2 ≤ d)
    (a : ℤ) (hq : 0 < q) (hcop : Nat.Coprime d q) :
    ∃ T : ℕ, 0 < T ∧ ∀ n : ℕ,
      Int.fract ((d ^ (n + T) : ℕ) * ((a : ℝ) / (q : ℝ))) =
      Int.fract ((d ^ n : ℕ) * ((a : ℝ) / (q : ℝ))) := by
  -- By Euler's totient theorem, since gcd(d, q) = 1, we have d^(φ(q)) ≡ 1 (mod q).
  have h_euler : d^(Nat.totient q) ≡ 1 [MOD q] := by
    exact Nat.ModEq.pow_totient hcop;
  refine' ⟨ φ q, _, _ ⟩;
  · exact?;
  · intro n; rw [ Int.fract_eq_fract ] ; simp_all +decide [ pow_add, mul_assoc, mul_div_assoc ] ;
    obtain ⟨ z, hz ⟩ := h_euler.symm.dvd;
    field_simp;
    exact ⟨ z * a * d ^ n, by push_cast [ ← @Int.cast_inj ℝ ] at *; linear_combination' hz * a * d ^ n ⟩

/-
The number of distinct values in the sequence `{fract(d^n * a/q)}_{n ≥ 0}`
    is at most `q`. This gives a uniform bound on the complexity of the
    torus orbit for rational phases.
-/
theorem monomial_rational_orbit_finite (d q : ℕ) (hd : 2 ≤ d)
    (a : ℤ) (hq : 0 < q) :
    Set.Finite {x : ℝ | ∃ n : ℕ, x = Int.fract ((d ^ n : ℕ) * ((a : ℝ) / (q : ℝ)))} := by
  -- Each value fract(d^n * a/q) = fract(k/q) for some integer k, and fract(k/q) only depends on k mod q.
  have h_fract_mod : ∀ n : ℕ, ∃ k : ℤ, Int.fract ((d ^ n : ℕ) * ((a : ℝ) / (q : ℝ))) = Int.fract ((k : ℝ) / (q : ℝ)) := by
    exact fun n => ⟨ d ^ n * a, by push_cast; ring ⟩;
  choose f hf using h_fract_mod;
  -- Since `fract(k/q)` only depends on `k mod q`, the set of values `fract(k/q)` is contained in the finite set `{fract(k/q) : k ∈ {0, ..., q-1}}`.
  have h_fract_finite : Set.Finite {x : ℝ | ∃ k : ℤ, x = Int.fract ((k : ℝ) / (q : ℝ))} := by
    refine Set.Finite.subset ( Set.toFinite ( Finset.image ( fun k : ℤ => Int.fract ( k / q : ℝ ) ) ( Finset.Ico 0 q ) ) ) ?_;
    intro x hx
    obtain ⟨k, hk⟩ := hx
    use Finset.mem_image.mpr ⟨k % q, Finset.mem_Ico.mpr ⟨Int.emod_nonneg k (by positivity), Int.emod_lt_of_pos k (by positivity)⟩, by
      rw [ hk, Int.emod_def ];
      convert Int.fract_add_intCast _ ( - ( k / q ) ) using 2 ; push_cast ; ring;
      · norm_num [ mul_comm, hq.ne' ];
      · infer_instance⟩;
  exact Set.Finite.subset h_fract_finite fun x hx => by obtain ⟨ n, rfl ⟩ := hx; exact ⟨ f n, hf n ▸ rfl ⟩ ;