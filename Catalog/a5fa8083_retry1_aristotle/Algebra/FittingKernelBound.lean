/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Fitting kernel bound for endomorphism powers

For a finite-dimensional vector space `V` over a field `K` and an endomorphism
`g : V →ₗ[K] V`, the kernels of the powers of `g` form an *ascending* chain.  Once
two consecutive kernels coincide the chain stabilizes forever, and by counting
dimensions this plateau must occur no later than step `finrank K V`.  Hence the
kernels are constant from `finrank K V` onwards.

This is the kernel-side (dual) counterpart of the range stabilization result; the
two are proved independently here so as not to create a circular dependency.

## Main results

* `ker_pow_mono` — the chain `n ↦ ker (g ^ n)` is monotone.
* `ker_pow_succ_eq_comap` — `ker (g ^ (k+1)) = Submodule.comap g (ker (g ^ k))`.
* `ker_pow_stable` — once the kernel stabilizes at step `k` it stays constant.
* `exists_ker_pow_plateau_le_finrank` — a plateau occurs at some `k ≤ finrank K V`.
* `ker_pow_eq_of_ge_finrank` — `ker (g ^ m) = ker (g ^ finrank K V)` for `m ≥ finrank K V`.
-/
import Mathlib

namespace Catalog.Algebra.FittingKernelBound

open LinearMap Module Submodule

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- The kernel of `g ^ n` is contained in the kernel of `g ^ (n + 1)`: an ascending
chain. -/
theorem ker_pow_le_succ (g : V →ₗ[K] V) (n : ℕ) :
    ker (g ^ n) ≤ ker (g ^ (n + 1)) := by
  rw [pow_succ' g n]
  exact LinearMap.ker_le_ker_comp (g ^ n) g

/-- The ascending kernel chain `n ↦ ker (g ^ n)` is monotone. -/
theorem ker_pow_mono (g : V →ₗ[K] V) :
    Monotone (fun n => ker (g ^ n)) :=
  monotone_nat_of_le_succ (ker_pow_le_succ g)

/-- The successor kernel is obtained as a comap along `g`:
`ker (g ^ (k+1)) = Submodule.comap g (ker (g ^ k))`. -/
theorem ker_pow_succ_eq_comap (g : V →ₗ[K] V) (k : ℕ) :
    ker (g ^ (k + 1)) = Submodule.comap g (ker (g ^ k)) := by
  rw [pow_succ g k]
  exact LinearMap.ker_comp g (g ^ k)

/-- Generic constant-propagation lemma: if a sequence `a` satisfies the recurrence
`a (j+1) = F (a j)` and is constant from step `k` to `k+1`, then it is constant for
all later steps. -/
theorem compFrom_const {α : Type*} (F : α → α) (a : ℕ → α) (k : ℕ)
    (hstep : ∀ j, a (j + 1) = F (a j)) (hconst : a (k + 1) = a k) :
    ∀ m, a (k + m) = a k := by
  intro m
  induction m with
  | zero => simp
  | succ n ih =>
    rw [show k + (n + 1) = (k + n) + 1 by ring, hstep (k + n), ih, ← hstep k, hconst]

/-- Plateau propagation: once the kernel stabilizes at step `k`, it stays constant
for all later steps. -/
theorem ker_pow_stable (g : V →ₗ[K] V) (k : ℕ)
    (h : ker (g ^ (k + 1)) = ker (g ^ k)) (m : ℕ) :
    ker (g ^ (k + m)) = ker (g ^ k) :=
  compFrom_const (Submodule.comap g) (fun n => ker (g ^ n)) k
    (fun j => ker_pow_succ_eq_comap g j) h m

/-- Pigeonhole: a kernel plateau occurs at some index `k ≤ finrank K V`.

If no plateau occurred among the first `finrank K V` steps, each step would be a
strict inclusion, forcing the dimension of `ker (g ^ (finrank K V + 1))` to exceed
`finrank K V`, which is impossible. -/
theorem exists_ker_pow_plateau_le_finrank [FiniteDimensional K V] (g : V →ₗ[K] V) :
    ∃ k ≤ finrank K V, ker (g ^ (k + 1)) = ker (g ^ k) := by
  by_contra h
  push_neg at h
  -- Without a plateau, the dimension grows by at least one at each step.
  have key : ∀ k, k ≤ finrank K V + 1 → k ≤ finrank K (ker (g ^ k)) := by
    intro k
    induction k with
    | zero => intro _; exact Nat.zero_le _
    | succ j ih =>
      intro hj
      have hjn : j ≤ finrank K V := by omega
      have hlt : ker (g ^ j) < ker (g ^ (j + 1)) :=
        lt_of_le_of_ne (ker_pow_le_succ g j) (fun e => h j hjn e.symm)
      have hstrict : finrank K (ker (g ^ j)) < finrank K (ker (g ^ (j + 1))) :=
        Submodule.finrank_lt_finrank_of_lt hlt
      have := ih (by omega)
      omega
  have h1 : finrank K V + 1 ≤ finrank K (ker (g ^ (finrank K V + 1))) := key _ le_rfl
  have h2 : finrank K (ker (g ^ (finrank K V + 1))) ≤ finrank K V := Submodule.finrank_le _
  omega

/-- Stabilization: for every `m ≥ finrank K V` the kernel of `g ^ m` equals the
kernel of `g ^ (finrank K V)`. -/
theorem ker_pow_eq_of_ge_finrank [FiniteDimensional K V] (g : V →ₗ[K] V) {m : ℕ}
    (hm : finrank K V ≤ m) :
    ker (g ^ m) = ker (g ^ (finrank K V)) := by
  obtain ⟨k, hk, hplateau⟩ := exists_ker_pow_plateau_le_finrank g
  have e1 : ker (g ^ m) = ker (g ^ k) := by
    have := ker_pow_stable g k hplateau (m - k)
    rwa [Nat.add_sub_cancel' (le_trans hk hm)] at this
  have e2 : ker (g ^ (finrank K V)) = ker (g ^ k) := by
    have := ker_pow_stable g k hplateau (finrank K V - k)
    rwa [Nat.add_sub_cancel' hk] at this
  rw [e1, e2]

end Catalog.Algebra.FittingKernelBound