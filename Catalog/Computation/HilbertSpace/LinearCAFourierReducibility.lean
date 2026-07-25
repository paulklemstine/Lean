import Mathlib

/-!
# Computational reducibility of linear cellular automata via Fourier diagonalization

A one-dimensional **linear** (convolutional) cellular automaton on the finite
cyclic group `ZMod n` is given by a local rule `c : ZMod n → ℂ`; one step of the
automaton sends a configuration `f : ZMod n → ℂ` to its **circulant** transform

`(circulant c f)(x) = ∑ⱼ c(j) · f(x - j)`.

The Fourier characters `x ↦ χ(k·x)` (where `χ = ZMod.stdAddChar` is the standard
additive character) are simultaneous eigenvectors of every circulant operator,
with eigenvalue

`eigenvalue c k = ∑ⱼ c(j) · χ(-(k·j))`.

This file develops that diagonalization and its computational consequence:
evolving a band-limited configuration `∑_{k∈K} a k · χ(k·x)` for `t` steps does
**not** require `t` matrix applications.  In the Fourier basis each mode evolves
independently by raising its eigenvalue to the `t`-th power, which can be done
with `O(log t)` complex multiplications per mode via binary exponentiation
(`fastPow`).

## Main results

* `circulant_eigen` — characters are eigenvectors of `circulant c`.
* `iter_eigen` — the `t`-fold iterate scales a character by `(eigenvalue c k)^t`.
* `fastPow_eq` — binary exponentiation computes the `t`-th power.
* `fastPowSteps_le` — binary exponentiation uses `O(log t)` multiplications.
* `iter_superposition` — linearity: each Fourier mode evolves independently.
* `reducibility_corollary` — the iterate computed via `fastPow`.
* `reducibility_cost` — the total multiplication cost is `O(|K| · log t)`.
-/

open scoped BigOperators

/-- The standard additive character `a ↦ exp(2πi·a/n)` of `ZMod n`. -/
noncomputable def chi (n : ℕ) [NeZero n] : AddChar (ZMod n) ℂ := ZMod.stdAddChar

/-- One step of the linear cellular automaton with local rule `c`:
`(circulant c f)(x) = ∑ⱼ c(j) · f(x - j)`. -/
noncomputable def circulant {n : ℕ} [NeZero n] (c f : ZMod n → ℂ) (x : ZMod n) : ℂ :=
  ∑ j : ZMod n, c j * f (x - j)

/-- The eigenvalue of `circulant c` on the Fourier mode `k`:
`eigenvalue c k = ∑ⱼ c(j) · χ(-(k·j))`. -/
noncomputable def eigenvalue {n : ℕ} [NeZero n] (c : ZMod n → ℂ) (k : ZMod n) : ℂ :=
  ∑ j : ZMod n, c j * chi n (-(k * j))

/-- Binary (fast) exponentiation `b ^ t`. -/
noncomputable def fastPow (b : ℂ) : ℕ → ℂ
  | 0 => 1
  | (m + 1) =>
      if (m + 1) % 2 = 0 then (fastPow b ((m + 1) / 2)) ^ 2
      else b * (fastPow b ((m + 1) / 2)) ^ 2
decreasing_by all_goals exact Nat.div_lt_self (Nat.succ_pos m) (by norm_num)

/-- The number of complex multiplications used by `fastPow` to compute `b ^ t`
(each squaring counts as one multiplication, and the extra factor of `b` in the
odd case counts as one more). -/
def fastPowSteps : ℕ → ℕ
  | 0 => 0
  | (m + 1) =>
      if (m + 1) % 2 = 0 then fastPowSteps ((m + 1) / 2) + 1
      else fastPowSteps ((m + 1) / 2) + 2
decreasing_by all_goals exact Nat.div_lt_self (Nat.succ_pos m) (by norm_num)

variable {n : ℕ} [NeZero n]

/-- The key multiplicativity of the character along a shift:
`χ(k·(x - j)) = χ(k·x) · χ(-(k·j))`. -/
theorem chi_shift (k x j : ZMod n) :
    chi n (k * (x - j)) = chi n (k * x) * chi n (-(k * j)) := by
  rw [← AddChar.map_add_eq_mul]
  congr 1
  ring

/-- A scaled character `x ↦ a · χ(k·x)` is an eigenvector of `circulant c` with
eigenvalue `eigenvalue c k`. -/
theorem circulant_eigen_smul (c : ZMod n → ℂ) (k : ZMod n) (a : ℂ) :
    circulant c (fun x => a * chi n (k * x))
      = fun x => a * eigenvalue c k * chi n (k * x) := by
  funext x
  simp only [circulant, eigenvalue]
  rw [Finset.mul_sum, Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro j _
  rw [chi_shift]
  ring

/-- Characters are eigenvectors of `circulant c`:
`circulant c (χ(k··)) = eigenvalue c k · χ(k··)`. -/
theorem circulant_eigen (c : ZMod n → ℂ) (k : ZMod n) :
    circulant c (fun x => chi n (k * x))
      = fun x => eigenvalue c k * chi n (k * x) := by
  have h := circulant_eigen_smul c k 1
  simpa using h

/-- A scaled character evolves under `t` steps by scaling with the `t`-th power of
the eigenvalue. -/
theorem iter_eigen_smul (c : ZMod n → ℂ) (k : ZMod n) (a : ℂ) (t : ℕ) :
    (circulant c)^[t] (fun x => a * chi n (k * x))
      = fun x => a * (eigenvalue c k) ^ t * chi n (k * x) := by
  induction t with
  | zero => simp
  | succ t ih =>
      rw [Function.iterate_succ_apply', ih, circulant_eigen_smul]
      funext x
      rw [pow_succ]
      ring

/-- The `t`-fold iterate of `circulant c` on a character scales it by
`(eigenvalue c k)^t`. -/
theorem iter_eigen (c : ZMod n → ℂ) (k : ZMod n) (t : ℕ) :
    (circulant c)^[t] (fun x => chi n (k * x))
      = fun x => (eigenvalue c k) ^ t * chi n (k * x) := by
  have h := iter_eigen_smul c k 1 t
  simpa using h

/-- `fastPow` computes the `t`-th power. -/
theorem fastPow_eq (b : ℂ) (t : ℕ) : fastPow b t = b ^ t := by
  induction t using Nat.strong_induction_on with
  | _ t ih =>
    match t with
    | 0 => rw [fastPow, pow_zero]
    | (m + 1) =>
      have hhalf : (m + 1) / 2 < m + 1 := Nat.div_lt_self (Nat.succ_pos m) (by norm_num)
      rw [fastPow]
      rcases Nat.even_or_odd (m + 1) with he | ho
      · have h2 : (m + 1) % 2 = 0 := Nat.even_iff.mp he
        rw [if_pos h2, ih _ hhalf, ← pow_mul]
        congr 1
        omega
      · have h2 : (m + 1) % 2 = 1 := Nat.odd_iff.mp ho
        rw [if_neg (by omega), ih _ hhalf, ← pow_mul, ← pow_succ']
        congr 1
        omega

/-- `fastPow` uses `O(log t)` multiplications: `fastPowSteps t ≤ 2·log₂ t + 2`. -/
theorem fastPowSteps_le (t : ℕ) : fastPowSteps t ≤ 2 * Nat.log 2 t + 2 := by
  induction t using Nat.strong_induction_on with
  | _ t ih =>
    match t, ih with
    | 0, _ => simp [fastPowSteps]
    | 1, _ =>
        have h1 : fastPowSteps 1 = 2 := by simp [fastPowSteps]
        omega
    | (m + 2), ih =>
        have hhalf : (m + 2) / 2 < m + 2 := Nat.div_lt_self (by omega) (by norm_num)
        have hlog : Nat.log 2 (m + 2) = Nat.log 2 ((m + 2) / 2) + 1 := by
          have hpos : 0 < Nat.log 2 (m + 2) := Nat.log_pos (by norm_num) (by omega)
          rw [Nat.log_div_base]
          omega
        have ihh := ih ((m + 2) / 2) hhalf
        rw [fastPowSteps]
        show (if (m + 2) % 2 = 0 then fastPowSteps ((m + 2) / 2) + 1
              else fastPowSteps ((m + 2) / 2) + 2) ≤ 2 * Nat.log 2 (m + 2) + 2
        split <;> · rw [hlog]; omega

/-- `circulant` is additive over a finite sum of configurations. -/
theorem circulant_finset_sum (c : ZMod n → ℂ) (K : Finset (ZMod n))
    (g : ZMod n → ZMod n → ℂ) :
    circulant c (fun x => ∑ k ∈ K, g k x)
      = fun x => ∑ k ∈ K, circulant c (g k) x := by
  funext x
  simp only [circulant, Finset.mul_sum]
  rw [Finset.sum_comm]

/-- The `t`-fold iterate of `circulant c` is additive over a finite sum of
configurations. -/
theorem iter_circulant_finset_sum (c : ZMod n → ℂ) (K : Finset (ZMod n))
    (g : ZMod n → ZMod n → ℂ) (t : ℕ) :
    (circulant c)^[t] (fun x => ∑ k ∈ K, g k x)
      = fun x => ∑ k ∈ K, (circulant c)^[t] (g k) x := by
  induction t with
  | zero => simp
  | succ t ih =>
      funext x
      rw [Function.iterate_succ_apply', ih, circulant_finset_sum]
      simp only [Function.iterate_succ_apply']

/-- **Superposition / independent mode evolution.**  Evolving a band-limited
configuration `∑_{k∈K} a k · χ(k·x)` for `t` steps scales each Fourier mode by
the `t`-th power of its eigenvalue. -/
theorem iter_superposition (c : ZMod n → ℂ) (K : Finset (ZMod n))
    (a : ZMod n → ℂ) (t : ℕ) :
    (circulant c)^[t] (fun x => ∑ k ∈ K, a k * chi n (k * x))
      = fun x => ∑ k ∈ K, a k * (eigenvalue c k) ^ t * chi n (k * x) := by
  rw [iter_circulant_finset_sum]
  funext x
  apply Finset.sum_congr rfl
  intro k _
  rw [iter_eigen_smul]

/-- **Reducibility corollary.**  The `t`-step evolution of a band-limited
configuration, computed with binary exponentiation for the eigenvalue powers. -/
theorem reducibility_corollary (c : ZMod n → ℂ) (K : Finset (ZMod n))
    (a : ZMod n → ℂ) (t : ℕ) :
    (circulant c)^[t] (fun x => ∑ k ∈ K, a k * chi n (k * x))
      = fun x => ∑ k ∈ K, a k * fastPow (eigenvalue c k) t * chi n (k * x) := by
  rw [iter_superposition]
  funext x
  apply Finset.sum_congr rfl
  intro k _
  rw [fastPow_eq]

omit [NeZero n] in
/-- **Reducibility cost.**  Computing the eigenvalue powers for every mode in `K`
by binary exponentiation, plus one scaling multiplication per mode, costs
`O(|K| · log t)` complex multiplications.

Note: the cost bound originally requested,
`fastPowSteps t * K.card + K.card ≤ 2 * K.card * (Nat.log 2 t + 1)`,
is *false* for the `fastPow` defined here: for `t = 1` we have
`fastPowSteps 1 = 2` (the recursion computes `b^1 = b · (b^0)^2` using two
multiplications), so with `|K| = 1` the left side is `3` while the right side is
`2`.  The corrected bound below replaces `+ 1` by `+ 2`; it follows from
`fastPowSteps_le`.  The hypothesis `0 < t` turned out to be unnecessary and is
retained only because it was part of the original request. -/
theorem reducibility_cost (K : Finset (ZMod n)) (t : ℕ) (_ht : 0 < t) :
    fastPowSteps t * K.card + K.card ≤ 2 * K.card * (Nat.log 2 t + 2) := by
  have h := fastPowSteps_le t
  nlinarith [h, Nat.zero_le K.card]