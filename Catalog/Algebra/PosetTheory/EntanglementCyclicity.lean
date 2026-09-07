import Mathlib
import Shared.HilbertSpace.NoncommutativeFibonacci
import Shared.CarmichaelHelper
/-!
# Cyclicity forced by a finite noncommutative state space

Research theme: *Entanglement-Inspired Algorithmic Complexity in Noncommutative
Spaces*.  Here we make precise the slogan that *the finiteness of the state space
forces the dynamics to be cyclic* — the mathematical analogue of the
"cyclicity of Hilbert space dimensionality".

The Fibonacci correlations are propagated by the transfer matrix
`M = !![1,1; 1,0]` (see `Shared.NoncommutativeFibonacci`).  Reduced modulo `m`,
`M` becomes an element of the **finite noncommutative monoid**
`Matrix (Fin 2) (Fin 2) (ZMod m)`, and — crucially — a *unit*, because
`det M = -1` is invertible.  A unit in a finite monoid has finite multiplicative
order, so `M^p = 1` for some `p > 0`; feeding this back through the power formula
`transfer_pow_succ` yields the **Pisano periodicity** of the Fibonacci sequence
modulo `m`.

## Main result
* `fib_periodic_mod` — for every modulus `m ≥ 1` there is a period `p > 0` with
  `F(n + p) ≡ F(n) [MOD m]` for all `n`.  This is proved purely from the finite
  *noncommutative* group of the transfer matrix, not by direct residue chasing.

## Bridge to the catalog
* `primitive_divisor_recurs` combines the Pisano periodicity above with the
  catalog's Carmichael prime-case theorem `fib_primitive_divisor_prime`
  (`Shared.CarmichaelHelper`): for prime `n ≥ 13` there is a prime `p` whose
  *first* appearance in the Fibonacci sequence is exactly at index `n`, and whose
  appearances thereafter recur periodically.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  "Cyclicity of the Hilbert-space dimension":
  since the reduced correlation operator lives in a *finite* algebra, its powers
  must cycle.  Counter-intuitive angle: periodicity of an additive recurrence is
  really a statement about the *order of a unit in a noncommutative group*, and
  the period is the order of `M` in `GL₂(ZMod m)`.
* **Experiment (Experimenter).**  Computed Pisano periods `π(m)` for `m ≤ 10`
  (`ComputationalEvidence.md`); they match OEIS A001175 (1,3,8,6,20,24,16,12,24,60),
  confirming *existence* (our qualitative claim) and that the period equals the
  order of `M`.
* **Analysis (Analyst).**  "True and structural."  The delicate inputs are
  (i) `M` is a unit via `Matrix.isUnit_iff_isUnit_det` with `det M = -1`, and
  (ii) a unit of a finite monoid has positive order (`orderOf_pos` in the finite
  group of units).  The passage back to `Nat.fib` uses `transfer_pow_succ` and
  `ZMod.natCast_eq_natCast_iff`.
* **Critique (Critic).**  Not vacuous: `m ≥ 1` is needed precisely so `ZMod m` is
  finite (for `m = 0`, `ZMod 0 = ℤ` is infinite and `M` has infinite order).  No
  `decide`/`native_decide`; the period is produced abstractly, not searched.
* **Synthesis (PI).**  Finiteness of a noncommutative correlation algebra ⇒
  cyclicity of the dynamics; the classical Pisano period is the order of the
  transfer unit, and it governs the recurrence of primitive prime divisors.
-/

namespace Catalog.EntanglementCyclicity

open Matrix Catalog.NoncommutativeFibonacci

/-- **Pisano periodicity from a finite noncommutative group.**
For every modulus `m ≥ 1` there is a period `p > 0` with
`F(n + p) ≡ F(n) [MOD m]` for all `n`.  The period is the multiplicative order of
the transfer unit `M = !![1,1;1,0]` in the finite group `GL₂(ZMod m)`. -/
theorem fib_periodic_mod (m : ℕ) (hm : 1 ≤ m) :
    ∃ p, 0 < p ∧ ∀ n, Nat.fib (n + p) ≡ Nat.fib n [MOD m] := by
  haveI : NeZero m := ⟨by omega⟩
  set M : Matrix (Fin 2) (Fin 2) (ZMod m) := !![1, 1; 1, 0] with hM
  -- `M` is a unit because `det M = -1` is invertible.
  have hunit : IsUnit M := by
    rw [Matrix.isUnit_iff_isUnit_det]
    have hdet : M.det = -1 := by rw [hM, Matrix.det_fin_two]; simp
    rw [hdet]; exact (isUnit_one).neg
  obtain ⟨u, hu⟩ := hunit
  refine ⟨orderOf u, orderOf_pos u, ?_⟩
  -- A unit in the finite group of units has `M ^ (orderOf u) = 1`.
  have hMp : M ^ orderOf u = 1 := by
    have hone := pow_orderOf_eq_one u
    have h2 : (↑(u ^ orderOf u) : Matrix (Fin 2) (Fin 2) (ZMod m))
        = ↑(1 : (Matrix (Fin 2) (Fin 2) (ZMod m))ˣ) := by rw [hone]
    rw [Units.val_pow_eq_pow_val, hu] at h2
    simpa using h2
  intro n
  set p := orderOf u
  -- The `(1,1)` entry of `M^(k+1)` is `F(k)` modulo `m`.
  have key : ∀ k : ℕ, (Nat.fib k : ZMod m) = (M ^ (k + 1)) 1 1 := by
    intro k; rw [hM, transfer_pow_succ]; simp
  -- `M^((n+p)+1) = M^(n+1) · M^p = M^(n+1)`.
  have hpow : M ^ ((n + p) + 1) = M ^ (n + 1) := by
    have hidx : (n + p) + 1 = (n + 1) + p := by ring
    rw [hidx, pow_add, hMp, mul_one]
  have hcast : (Nat.fib (n + p) : ZMod m) = (Nat.fib n : ZMod m) := by
    rw [key (n + p), key n, hpow]
  exact (ZMod.natCast_eq_natCast_iff _ _ _).1 hcast

/-- **Recurrence of primitive prime divisors (bridge to the catalog).**
For a prime `n ≥ 13`, the catalog's Carmichael prime case provides a prime `p`
whose *first* appearance in the Fibonacci sequence is at index `n`
(`p ∣ F(n)` but `p ∤ F(k)` for `0 < k < n`).  Combined with `fib_periodic_mod`,
the pattern of appearances of `p` recurs with a positive period. -/
theorem primitive_divisor_recurs (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ (∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k)
      ∧ ∃ q, 0 < q ∧ ∀ j, Nat.fib (j + q) ≡ Nat.fib j [MOD p] := by
  obtain ⟨p, hp, hpn, hprim⟩ := fib_primitive_divisor_prime n hn hnp
  obtain ⟨q, hq, hper⟩ := fib_periodic_mod p hp.one_lt.le
  exact ⟨p, hp, hpn, hprim, q, hq, hper⟩

end Catalog.EntanglementCyclicity