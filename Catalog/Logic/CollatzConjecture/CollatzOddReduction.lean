import Mathlib

/-!
# Collatz Odd Reduction: Reachability Closure and the Odd-Restriction Barrier

This file extends the structural study of the Collatz (3n+1) dynamical system
begun in `Logic.CollatzModularDynamics`.  There we characterized the behaviour of
the map on powers of two, fixed points, and short cycles.  Here we develop the
*reachability* relation `Reaches n := ∃ k, C^[k] n = 1` and prove a collection of
closure properties that culminate in a genuine **proof-theoretic reduction** of
the Collatz conjecture:

> The Collatz conjecture holds for *all* positive integers iff it holds for all
> *odd* positive integers.

This is the formal counterpart of the well-known folklore reduction: even inputs
can always be halved down to an odd "seed", so the entire convergence question is
controlled by the odd skeleton of ℕ.  The proof is by strong induction on `n`,
using the doubling-invariance lemma `reaches_double`.

We also prove:
* `reaches_pow2` — every power of two reaches one (the 2-adic descent corollary);
* `syracuse_no_fixed_point` — the accelerated Syracuse map has no positive fixed
  point, sharpening the "no fixed point" result of the companion file.

Catalog synthesis: this file builds directly on `CollatzModular.C`, `C_even`,
`C_odd`, and `C_pow2` from `Logic.CollatzModularDynamics`, lifting their pointwise
content to the global reachability relation.
-/

namespace CollatzOddReduction

-- !-- Lab Notebook: CollatzOddReduction -- !--
-- !-- Hypothesis: Reachability of 1 under the Collatz map is closed under doubling, so the conjecture reduces to its odd skeleton -- !--
-- !-- Result: reaches_double gives the doubling invariance; strong induction collapses every even input to an odd seed, yielding collatz_iff_odd -- !--
-- !-- Insight: The reduction is purely structural and needs NO information about the actual Collatz conjecture — only that C(2n)=n -- !--
-- !-- End Lab Notebook -- !--

/-- The standard Collatz step: `n/2` if even, `3n+1` if odd. -/
def C (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

theorem C_even {n : ℕ} (h : n % 2 = 0) : C n = n / 2 := by simp [C, h]

theorem C_odd {n : ℕ} (h : n % 2 = 1) : C n = 3 * n + 1 := by simp [C, h]

/-- `C` sends a doubled input straight back: `C (2 * n) = n`. -/
theorem C_two_mul (n : ℕ) : C (2 * n) = n := by
  have h : (2 * n) % 2 = 0 := by omega
  rw [C_even h]; omega

/-- A natural number *reaches one* if some finite number of Collatz steps lands on `1`. -/
def Reaches (n : ℕ) : Prop := ∃ k, (C^[k]) n = 1

-- !-- comment: `1` reaches itself in zero steps. -- !--
theorem reaches_one : Reaches 1 := ⟨0, rfl⟩

/-- Reachability propagates backwards along a Collatz step: if the *image* `C n`
    reaches one, then so does `n` (prepend the step). -/
theorem reaches_of_reaches_C {n : ℕ} (h : Reaches (C n)) : Reaches n := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k + 1, by rw [Function.iterate_succ_apply]; exact hk⟩

/-- **Doubling invariance.** For a positive `n`, the doubled value `2 * n` reaches
    one iff `n` does.  This is the engine of the odd reduction.

    Forward: `2*n` is even, so the first step is `C (2*n) = n`, and the
    remaining trajectory is that of `n`.  Backward: prepend the step `C (2*n) = n`. -/
theorem reaches_double {n : ℕ} : Reaches (2 * n) ↔ Reaches n := by
  constructor
  · rintro ⟨k, hk⟩
    cases k with
    | zero =>
        rw [Function.iterate_zero_apply] at hk; omega
    | succ j =>
        refine ⟨j, ?_⟩
        rw [Function.iterate_succ_apply, C_two_mul] at hk
        exact hk
  · intro h
    exact reaches_of_reaches_C (by rw [C_two_mul]; exact h)

-- !-- comment: Induction on `k` using `reaches_double`: `2^(k+1) = 2 * 2^k`. -- !--
/-- Every power of two reaches one — the global form of the 2-adic descent property. -/
theorem reaches_pow2 (k : ℕ) : Reaches (2 ^ k) := by
  induction k with
  | zero => simpa using reaches_one
  | succ j ih =>
      have : (2 : ℕ) ^ (j + 1) = 2 * 2 ^ j := by ring
      rw [this]
      exact reaches_double.mpr ih

/-- **The odd-restriction reduction (main theorem).**
    The Collatz conjecture (every positive integer reaches one) is *equivalent* to
    its restriction to odd positive integers.

    Forward is immediate.  Backward is strong induction on `n`: an odd `n` is handled
    by hypothesis, while an even `n = 2*m` with `0 < m < n` is reduced via
    `reaches_double` to the strictly smaller `m`. -/
theorem collatz_iff_odd :
    (∀ n, 0 < n → Reaches n) ↔ (∀ n, 0 < n → Odd n → Reaches n) := by
  constructor
  · intro h n hn _; exact h n hn
  · intro hodd n
    induction n using Nat.strong_induction_on with
    | _ n ih =>
        intro hn
        rcases Nat.even_or_odd n with he | ho
        · obtain ⟨m, rfl⟩ := he
          have hm : 0 < m := by omega
          have : (m + m) = 2 * m := by ring
          rw [this]
          exact reaches_double.mpr (ih m (by omega) hm)
        · exact hodd n hn ho

/-! ## The accelerated Syracuse map -/

/-- The "shortcut" / Syracuse map: `n/2` for even `n`, `(3n+1)/2` for odd `n`. -/
def syracuse (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

-- !-- comment: Even case forces `n = 0`; odd case forces `3n+1 = 2n`, impossible in ℕ. -- !--
/-- The Syracuse map has no positive fixed point, sharpening the no-fixed-point
    result of the companion file from `C` to the accelerated map. -/
theorem syracuse_no_fixed_point (n : ℕ) (hn : 0 < n) : syracuse n ≠ n := by
  unfold syracuse
  split_ifs with h <;> omega

end CollatzOddReduction