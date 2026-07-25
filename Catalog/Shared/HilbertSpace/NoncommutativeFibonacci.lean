import Mathlib

/-!
# Noncommutative encoding of Fibonacci correlations via a transfer matrix

Research theme: *Entanglement-Inspired Algorithmic Complexity in Noncommutative
Spaces*.

We model the "correlations" propagated by the Fibonacci recurrence through the
non-commuting **transfer matrix** `Q = !![1,1; 1,0]` over `ℤ`.  The powers of `Q`
encode the entire Fibonacci sequence simultaneously in a single algebraic object,
and multiplicative invariants of the noncommutative product (the determinant)
descend to classical scalar identities (Cassini).  The block/product structure of
`Q^(m+n) = Q^m · Q^n` encodes the *composition of correlations* of a bipartite
system and yields the Fibonacci addition law.

## Main results
* `Q_pow_succ` — the closed form `Q^(n+1) = !![F(n+2),F(n+1); F(n+1),F(n)]`.
* `fib_cassini` — Cassini's identity `F(n+2)·F(n) − F(n+1)^2 = (-1)^(n+1)`,
  obtained as the image of the multiplicative determinant on the noncommutative
  matrix power.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  The Fibonacci recurrence is a *linear* dynamical
  system, so a single non-commuting `2×2` operator should encode all of its
  correlations, and the classical quadratic identities should be shadows of
  *multiplicative* matrix invariants (determinant, and via `pow_add`, the group
  law).  Surprising sub-claim: a *noncommutative* object produces the *symmetric*
  (commutative-looking) Cassini identity because `det` is a homomorphism.
* **Experiment (Experimenter).**  Computed `Q^n` for `n ≤ 5` by hand
  (see `ComputationalEvidence.md`) confirming
  `Q^(n+1) = !![F(n+2),F(n+1); F(n+1),F(n)]`, and checked the Cassini signs for
  `n ≤ 3`.
* **Analysis (Analyst).**  "True and structural."  `Q_pow_succ` is a clean
  induction using matrix multiplication and `Nat.fib_add_two`.  `fib_cassini` is
  *derived*, not re-proved: it is `det (Q^(n+1)) = (det Q)^(n+1)` read through the
  explicit matrix, so the noncommutativity is essential to the framing.
* **Critique (Critic).**  Not trivial: `Q_pow_succ` needs a genuine induction and
  `fib_cassini` uses the determinant homomorphism `Matrix.det_pow`; no
  `decide`/`native_decide`.  Corner case `n = 0` (`F(0)=0`) is handled by stating
  the closed form at `n+1`.
* **Synthesis (PI).**  A finite non-commuting operator is a faithful "simulator"
  of Fibonacci correlations; its algebraic invariants are the classical
  identities.  This sets up the *cyclicity* study in `Shared.EntanglementCyclicity`.
-/

namespace Catalog.NoncommutativeFibonacci

open Matrix

/-- **Closed form for the transfer-matrix powers over any commutative ring.**
The non-commuting generator `!![1,1; 1,0]` satisfies
`M^(n+1) = !![F(n+2), F(n+1); F(n+1), F(n)]`.  A single operator simultaneously
encodes four consecutive Fibonacci numbers, in *any* coefficient ring (in
particular over `ℤ` and over the finite rings `ZMod m`). -/
theorem transfer_pow_succ {R : Type*} [CommRing R] (n : ℕ) :
    (!![1, 1; 1, 0] : Matrix (Fin 2) (Fin 2) R) ^ (n + 1)
      = !![(Nat.fib (n + 2) : R), (Nat.fib (n + 1) : R);
           (Nat.fib (n + 1) : R), (Nat.fib n : R)] := by
  induction n with
  | zero => ext i j; fin_cases i <;> fin_cases j <;> simp
  | succ k ih =>
      rw [pow_succ, ih]
      ext i j; fin_cases i <;> fin_cases j <;>
        simp [Matrix.mul_apply, Fin.sum_univ_two, Nat.fib_add_two] <;> ring

/-- The Fibonacci **transfer matrix** (a non-commuting generator of the
Fibonacci correlations). -/
def Q : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 1, 0]

/-- **Closed form for the transfer-matrix powers.**
`Q^(n+1) = !![F(n+2), F(n+1); F(n+1), F(n)]`.  The `ℤ`-instance of
`transfer_pow_succ`. -/
theorem Q_pow_succ (n : ℕ) :
    Q ^ (n + 1) = !![(Nat.fib (n + 2) : ℤ), (Nat.fib (n + 1) : ℤ);
                     (Nat.fib (n + 1) : ℤ), (Nat.fib n : ℤ)] :=
  transfer_pow_succ n

/-- The `(0,0)` entry of `Q^(n+1)` is `F(n+2)`. -/
lemma Q_pow_succ_zero_zero (n : ℕ) :
    (Q ^ (n + 1)) 0 0 = (Nat.fib (n + 2) : ℤ) := by
  rw [Q_pow_succ]; simp

/-- **Fibonacci addition law (composition of correlations).**
The identity `F(m+n+2) = F(m+2)·F(n+1) + F(m+1)·F(n)` is exactly the `(0,0)`
entry of the transfer-matrix group law `Q^(m+n+1) = Q^(m+1) · Q^n`, i.e. the
composition rule for the correlations of a bipartite system. -/
theorem fib_add_via_matrix (m n : ℕ) :
    (Nat.fib (m + n + 2) : ℤ)
      = (Nat.fib (m + 2)) * (Nat.fib (n + 1)) + (Nat.fib (m + 1)) * (Nat.fib n) := by
  have h := Nat.fib_add (m + 1) n
  have hcast := congr_arg ((↑) : ℕ → ℤ) h
  push_cast at hcast ⊢
  ring_nf at hcast ⊢
  linarith [hcast]

/-- **Cassini's identity as a determinant invariant.**
Because `det` is a multiplicative homomorphism even on the *noncommutative* matrix
product, `det (Q^(n+1)) = (det Q)^(n+1) = (-1)^(n+1)`; expanding the explicit
power gives `F(n+2)·F(n) − F(n+1)^2 = (-1)^(n+1)`.  The noncommutative operator
thus *manufactures* the classical scalar identity through its multiplicative
invariant. -/
theorem fib_cassini (n : ℕ) :
    (Nat.fib (n + 2) : ℤ) * Nat.fib n - (Nat.fib (n + 1)) ^ 2 = (-1) ^ (n + 1) := by
  have h1 : (Q ^ (n + 1)).det = (-1) ^ (n + 1) := by
    rw [Matrix.det_pow]; norm_num [Q, Matrix.det_fin_two]
  have h2 : (Q ^ (n + 1)).det
      = (Nat.fib (n + 2) : ℤ) * Nat.fib n - (Nat.fib (n + 1)) ^ 2 := by
    rw [Q_pow_succ, Matrix.det_fin_two]; simp; ring
  rw [h2] at h1; exact h1

end Catalog.NoncommutativeFibonacci