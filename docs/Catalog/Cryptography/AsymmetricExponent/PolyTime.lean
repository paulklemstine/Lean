import Cryptography.AsymmetricExponent.Core

/-!
# `Q(a) = a^(N-1) mod N` is cheap: a verified logarithmic-cost algorithm

The FETQ quantity is interesting only because it costs nothing to compute.
This file makes that precise inside Lean: a binary (square-and-multiply)
modular exponentiation routine is defined, proved **correct**, and its
recursion depth is proved to be at most the binary length `Nat.size` of the
exponent.  Computing `Q(a)` therefore costs `O(log N)` modular multiplications
— no factorisation, no aggregation over many `a`.

Main results.

* `AsymmetricExponent.powMod_eq` — `powMod m a n = a^n % m` (strong induction on
  the exponent).
* `AsymmetricExponent.powModSteps_le_size` — the number of recursive halvings
  is at most `Nat.size n`.
* `AsymmetricExponent.fetq_eq_powMod` and
  `AsymmetricExponent.fetq_cost_logarithmic` — the FETQ quantity is computed by
  this routine at logarithmic cost.
-/

namespace AsymmetricExponent

/-- Square-and-multiply modular exponentiation. -/
def powMod (m a : ℕ) : ℕ → ℕ
  | 0 => 1 % m
  | (n + 1) =>
      let h := powMod m a ((n + 1) / 2)
      if (n + 1) % 2 = 0 then h * h % m else h * h % m * (a % m) % m
  decreasing_by omega

/-- The number of recursive calls made by `powMod` on exponent `n`. -/
def powModSteps : ℕ → ℕ
  | 0 => 0
  | (n + 1) => powModSteps ((n + 1) / 2) + 1
  decreasing_by omega

/-- **Correctness of square-and-multiply.** -/
theorem powMod_eq (m a : ℕ) : ∀ n : ℕ, powMod m a n = a ^ n % m := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp [powMod]
    | (k + 1) =>
      have hlt : (k + 1) / 2 < k + 1 := by omega
      have ihk := ih ((k + 1) / 2) hlt
      rw [powMod]
      simp only [ihk]
      rcases Nat.even_or_odd (k + 1) with hev | hodd
      · have hmod : (k + 1) % 2 = 0 := Nat.even_iff.mp hev
        have hsplit : a ^ (k + 1) = a ^ ((k + 1) / 2) * a ^ ((k + 1) / 2) := by
          rw [← pow_add]; congr 1; omega
        rw [if_pos hmod, hsplit, Nat.mul_mod]
        simp
      · have hmod : (k + 1) % 2 = 1 := Nat.odd_iff.mp hodd
        have hsplit : a ^ (k + 1) = a ^ ((k + 1) / 2) * a ^ ((k + 1) / 2) * a := by
          rw [← pow_add, ← pow_succ]; congr 1; omega
        rw [if_neg (by omega), hsplit, Nat.mul_mod (a ^ ((k + 1) / 2) * a ^ ((k + 1) / 2)) a,
          Nat.mul_mod (a ^ ((k + 1) / 2))]

/-- **Logarithmic recursion depth.** -/
theorem powModSteps_le_size : ∀ n : ℕ, powModSteps n ≤ Nat.size n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp [powModSteps]
    | (k + 1) =>
      have hlt : (k + 1) / 2 < k + 1 := by omega
      have ihk := ih ((k + 1) / 2) hlt
      have hs : 0 < Nat.size (k + 1) := Nat.size_pos.mpr (Nat.succ_pos k)
      have hup : (k + 1) < 2 ^ Nat.size (k + 1) := Nat.lt_size_self _
      have hhalf : (k + 1) / 2 < 2 ^ (Nat.size (k + 1) - 1) := by
        rw [Nat.div_lt_iff_lt_mul (by norm_num)]
        calc (k + 1) < 2 ^ Nat.size (k + 1) := hup
          _ = 2 ^ (Nat.size (k + 1) - 1) * 2 := by
              rw [← pow_succ]
              congr 1
              omega
      have hsize : Nat.size ((k + 1) / 2) ≤ Nat.size (k + 1) - 1 :=
        Nat.size_le.mpr hhalf
      rw [powModSteps]
      omega

theorem fetq_eq_powMod (N a : ℕ) : fetq N a = powMod N a (N - 1) := by
  rw [powMod_eq, fetq]

/-- The FETQ quantity is computed with at most `Nat.size (N-1)` halving steps:
`O(log N)` modular multiplications, with no reference to the factorisation. -/
theorem fetq_cost_logarithmic (N a : ℕ) :
    fetq N a = powMod N a (N - 1) ∧ powModSteps (N - 1) ≤ Nat.size (N - 1) :=
  ⟨fetq_eq_powMod N a, powModSteps_le_size _⟩

end AsymmetricExponent