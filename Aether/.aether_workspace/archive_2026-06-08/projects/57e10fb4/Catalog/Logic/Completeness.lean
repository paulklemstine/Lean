/-
# Effective Completeness of Computable Reals

This module proves that the computable reals are effectively complete:
every effective Cauchy sequence of computable reals converges to a
computable real, with the limit constructed by a diagonal argument
on the approximation sequences.
-/
import ConstructiveAnalysis.Basic

open Set

/-! ## Effective Cauchy Sequences -/

/-- An effective Cauchy sequence of computable reals: a sequence `seq` of
computable reals together with a modulus `mod` such that for indices
beyond `mod n`, the canonical approximants agree to within `1/2^n`. -/
structure EffCauchySeq where
  seq : ℕ → ComputableReal
  mod : ℕ → ℕ
  mono_mod : Monotone mod
  cauchy' : ∀ n i j, mod n ≤ i → mod n ≤ j →
    |(seq i).approxAt (n + 2) - (seq j).approxAt (n + 2)| ≤ (1 : ℚ) / 2 ^ n

namespace EffCauchySeq

/-- The diagonal approximation scheme: at stage `n`, use the `mod(n+2)`-th sequence
element evaluated at precision `n+2`. This extracts a single rational Cauchy
sequence from a sequence of computable reals. -/
def diagApprox (s : EffCauchySeq) (n : ℕ) : ℚ :=
  (s.seq (s.mod (n + 2))).approxAt (n + 2)

/-
The diagonal approximation scheme is itself an effective Cauchy sequence
of rationals, with modulus `fun n => n`.
-/
theorem diagApprox_cauchy (s : EffCauchySeq) :
    ∀ n i j, n ≤ i → n ≤ j →
      |s.diagApprox i - s.diagApprox j| ≤ 3 * ((1 : ℚ) / 2 ^ n) := by
  intro n i j hi hj;
  -- Applying the triangle inequality and the coherence of approxAt, we get:
  have h_triangle : |(s.seq (s.mod (i + 2))).approxAt (i + 2) - (s.seq (s.mod (j + 2))).approxAt (j + 2)| ≤
    |(s.seq (s.mod (i + 2))).approxAt (n + 2) - (s.seq (s.mod (j + 2))).approxAt (n + 2)| +
    |(s.seq (s.mod (i + 2))).approxAt (i + 2) - (s.seq (s.mod (i + 2))).approxAt (n + 2)| +
    |(s.seq (s.mod (j + 2))).approxAt (j + 2) - (s.seq (s.mod (j + 2))).approxAt (n + 2)| := by
      cases abs_cases ( ( s.seq ( s.mod ( i + 2 ) ) |> ComputableReal.approxAt ) ( i + 2 ) - ( s.seq ( s.mod ( j + 2 ) ) |> ComputableReal.approxAt ) ( j + 2 ) ) <;> cases abs_cases ( ( s.seq ( s.mod ( i + 2 ) ) |> ComputableReal.approxAt ) ( n + 2 ) - ( s.seq ( s.mod ( j + 2 ) ) |> ComputableReal.approxAt ) ( n + 2 ) ) <;> cases abs_cases ( ( s.seq ( s.mod ( i + 2 ) ) |> ComputableReal.approxAt ) ( i + 2 ) - ( s.seq ( s.mod ( i + 2 ) ) |> ComputableReal.approxAt ) ( n + 2 ) ) <;> cases abs_cases ( ( s.seq ( s.mod ( j + 2 ) ) |> ComputableReal.approxAt ) ( j + 2 ) - ( s.seq ( s.mod ( j + 2 ) ) |> ComputableReal.approxAt ) ( n + 2 ) ) <;> linarith;
  -- Applying the Cauchy condition and the coherence of approxAt, we get:
  have h_cauchy : |(s.seq (s.mod (i + 2))).approxAt (n + 2) - (s.seq (s.mod (j + 2))).approxAt (n + 2)| ≤ 1 / 2 ^ n := by
    convert s.cauchy' n ( s.mod ( i + 2 ) ) ( s.mod ( j + 2 ) ) _ _ using 1;
    · exact s.mono_mod ( by linarith );
    · exact s.mono_mod ( by linarith )
  have h_coherent_i : |(s.seq (s.mod (i + 2))).approxAt (i + 2) - (s.seq (s.mod (i + 2))).approxAt (n + 2)| ≤ 1 / 2 ^ (n + 2) := by
    rw [ abs_sub_comm ] ; exact ComputableReal.approxAt_coherent _ _ _ ( by linarith ) ;
  have h_coherent_j : |(s.seq (s.mod (j + 2))).approxAt (j + 2) - (s.seq (s.mod (j + 2))).approxAt (n + 2)| ≤ 1 / 2 ^ (n + 2) := by
    grind +suggestions;
  norm_num [ pow_add ] at *;
  exact h_triangle.trans ( by linarith [ inv_pos.mpr ( pow_pos ( zero_lt_two' ℚ ) n ) ] )

/-
The effective limit: a computable real constructed from the diagonal
approximation scheme.
-/
noncomputable def effectiveLimit (s : EffCauchySeq) : ComputableReal where
  seq := fun n => s.diagApprox n
  mod := fun n => n + 2
  mono_mod := by intro a b h; show a + 2 ≤ b + 2; omega
  cauchy' := by
    intros n i j hi hj
    have := s.diagApprox_cauchy (n + 2) i j (by linarith) (by linarith)
    have h_final : |s.diagApprox i - s.diagApprox j| ≤ 3 * ((1 : ℚ) / 2 ^ (n + 2)) := by
      convert this using 1
    have h_final' : 3 * ((1 : ℚ) / 2 ^ (n + 2)) ≤ 1 / 2 ^ n := by
      ring_nf; norm_num;
    exact le_trans h_final h_final'

end EffCauchySeq

/-
**Effective Completeness Theorem.**
Every effective Cauchy sequence of computable reals has a computable real limit.
Moreover, the convergence rate is explicit: the limit agrees with the `k`-th
sequence element to within `O(1/2^n)` for `k ≥ mod(n)`.
-/
theorem computableReal_effective_completeness (s : EffCauchySeq) :
    ∃ x : ComputableReal,
      ∀ n, ∀ k, s.mod n ≤ k →
        |(s.seq k).approxAt (n + 2) - x.approxAt (n + 2)| ≤ 2 * ((1 : ℚ) / 2 ^ n) := by
  use ⟨ fun n => s.diagApprox n, fun n => n + 2, by
    exact fun n m h => Nat.add_le_add_right h 2, by
    intros n i j hi hj
    have := s.diagApprox_cauchy (n + 2) i j (by linarith) (by linarith)
    have h_final : |s.diagApprox i - s.diagApprox j| ≤ 3 * ((1 : ℚ) / 2 ^ (n + 2)) := by
      exact this;
    exact h_final.trans ( by ring_nf; norm_num )⟩;
  all_goals generalize_proofs at *;
  simp_all +decide [ ComputableReal.approxAt, EffCauchySeq.diagApprox ];
  intro n k hk;
  have := s.cauchy' n k ( s.mod ( n + 2 + 2 + 2 ) ) hk ( by linarith [ s.mono_mod ( by linarith : n ≤ n + 2 + 2 + 2 ) ] );
  have := ComputableReal.approxAt_coherent ( s.seq ( s.mod ( n + 2 + 2 + 2 ) ) ) ( n + 2 ) ( n + 2 + 2 + 2 ) ( by linarith );
  simp_all +decide [ ComputableReal.approxAt ];
  norm_num [ pow_add ] at *;
  grind