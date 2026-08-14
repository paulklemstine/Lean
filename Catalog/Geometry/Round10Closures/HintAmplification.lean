/-
Round-10 Closures — Part V: pricing the hint (HINT-AMP scope restatement).

The round-10 batch flagged hint amplification (Coppersmith, partial key exposure) as the
one resource the barrier framework never priced, because it is not extraction from `N`
alone: it consumes an *external* hint.  This file makes the scope restatement precise in
the simplest possible model of a hint — the trace `p + q` of the factorisation — and proves
that this single hint is amplified to the full factorisation by an explicit, closed-form,
constant-time extractor:

    factorFromTrace N s = (s - sqrt (s² - 4N)) / 2 .

Contrast with `JointClosure.no_profile_extractor`, where no extractor whatsoever exists for
the hint-free free-witness channel: the two theorems together delimit the framework's
scope, "extraction from `N` alone" versus "amplification of hints".
-/
import Geometry.Round10Closures.JointClosure

namespace Round10

/-- The closed-form extractor: recover the smaller factor of `N` from the hint `s = p + q`. -/
def factorFromTrace (N s : ℕ) : ℕ := (s - Nat.sqrt (s * s - 4 * N)) / 2

/-- **Hint amplification.**  The additive hint `p + q` amplifies to the full factorisation
of `N = p * q` in closed form. -/
theorem factorFromTrace_eq {p q : ℕ} (hpq : p ≤ q) : factorFromTrace (p * q) (p + q) = p := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hpq
  have hs : p + (p + d) = 2 * p + d := by ring
  have hsqrt : Nat.sqrt ((2 * p + d) * (2 * p + d) - 4 * (p * (p + d))) = d := by
    have h : (2 * p + d) * (2 * p + d) = 4 * (p * (p + d)) + d * d := by ring
    rw [h]
    simp
  rw [factorFromTrace, hs, hsqrt]
  omega

/-- **Uniqueness of the amplified factorisation.**  A modulus together with the trace hint
determines the (ordered) factor pair: the hint is information-theoretically complete, which
is exactly why it lies outside the hint-free framework. -/
theorem trace_hint_determines_factors {p q p' q' : ℕ} (hN : p * q = p' * q')
    (hs : p + q = p' + q') (h : p ≤ q) (h' : p' ≤ q') : p = p' ∧ q = q' := by
  have hp : p = p' := by
    rw [← factorFromTrace_eq h, ← factorFromTrace_eq h', hN, hs]
  exact ⟨hp, by omega⟩

/-- **Scope restatement.**  For a fixed prime `q` and any finite set `S` of positive
exponents: the hint-free joint free-witness channel admits no extractor of the second prime
factor, while a single external trace hint admits an explicit one.

This is the honest statement of the round-10 HINT-AMP finding: hint amplification is not a
counterexample to the barrier framework, it is outside its stated scope. -/
theorem hint_free_versus_hinted (S : Finset ℕ) (hS : ∀ k ∈ S, 0 < k) {q : ℕ} (hq : q.Prime) :
    (¬ ∃ F : (ℕ → ℕ) → ℕ, ∀ p : ℕ, p.Prime → q < p → F (profile S (p * q)) = p) ∧
      (∃ G : ℕ → ℕ → ℕ, ∀ p : ℕ, p.Prime → q < p → G (q * p) (q + p) = q) :=
  ⟨no_profile_extractor S hS hq,
    ⟨factorFromTrace, fun _ _ hqp => factorFromTrace_eq hqp.le⟩⟩

end Round10