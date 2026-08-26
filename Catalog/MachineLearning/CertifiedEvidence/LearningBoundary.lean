/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Where the boundary of finite evidence actually lies

`CertifiedEvidence.Insufficiency` shows the version space after finite evidence
has the cardinality of the continuum — but that is a statement about the
*unrestricted* hypothesis class `ℕ → Bool`.  This file proves the matching
positive statement: restrict the class and the very same evidence becomes
conclusive, with an exactly determined sample complexity.

## Main results

* `periodic_ext` — two `T`-periodic predicates that agree on `[1,T]` agree
  everywhere above `0`.
* `periodic_versionSpace_subsingleton` — inside the class of `T`-periodic
  predicates, the version space after the `T` samples `1,…,T` is a singleton:
  finite evidence *does* identify the hypothesis.
* `periodic_sample_complexity_sharp` — and `T` samples are necessary: for every
  `T ≥ 2` two distinct `T`-periodic predicates agree on `[1,T-1]`.
* `learning_dichotomy` — the two regimes side by side: continuum-sized version
  space for the unrestricted class, singleton for the periodic class, at the
  same sample size.
* `certifiable_iff_descent` — the computational counterpart, transported from
  `CertifiedEvidence.Sufficiency`: a universal statement is provable from a
  finite window precisely when a descent structure exists.
-/

import Mathlib
import MachineLearning.CertifiedEvidence.Insufficiency
import MachineLearning.CertifiedEvidence.Sufficiency

namespace CertifiedEvidence

/-- The hypothesis class of predicates with period `T`. -/
def PeriodicClass (T : ℕ) : Set (ℕ → Bool) := {p | ∀ n, p (n + T) = p n}

/-- A `T`-periodic predicate is determined above `0` by its values on `[1,T]`. -/
theorem periodic_ext {T : ℕ} (hT : 0 < T) {p q : ℕ → Bool}
    (hp : p ∈ PeriodicClass T) (hq : q ∈ PeriodicClass T)
    (hagree : ∀ k, 1 ≤ k → k ≤ T → p k = q k) :
    ∀ n, 1 ≤ n → p n = q n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      intro hn
      by_cases h : n ≤ T
      · exact hagree n hn h
      · push_neg at h
        have hback : n - T + T = n := by omega
        have h1 : p n = p (n - T) := by
          have hpp := hp (n - T); rwa [hback] at hpp
        have h2 : q n = q (n - T) := by
          have hqq := hq (n - T); rwa [hback] at hqq
        rw [h1, h2]
        exact ih (n - T) (by omega) (by omega)

/-- **Finite evidence identifies a periodic hypothesis.** Within the period-`T`
class, the version space after the samples `1,…,T` contains a single behaviour
on the positive integers — in sharp contrast with `continuum_le_versionSpace`
for the unrestricted class. -/
theorem periodic_versionSpace_subsingleton {T : ℕ} (hT : 0 < T) (p : ℕ → Bool)
    {q₁ q₂ : ℕ → Bool} (h₁ : q₁ ∈ PeriodicClass T ∩ versionSpace p T)
    (h₂ : q₂ ∈ PeriodicClass T ∩ versionSpace p T) :
    ∀ n, 1 ≤ n → q₁ n = q₂ n := by
  refine periodic_ext hT h₁.1 h₂.1 fun k hk hk' => ?_
  rw [h₁.2 k hk hk', h₂.2 k hk hk']

/-- **The sample complexity is exactly `T`.** One sample fewer is not enough:
two distinct `T`-periodic predicates agree on `[1,T-1]`. -/
theorem periodic_sample_complexity_sharp {T : ℕ} (hT : 2 ≤ T) :
    ∃ p q : ℕ → Bool, p ∈ PeriodicClass T ∧ q ∈ PeriodicClass T ∧
      (∀ k, 1 ≤ k → k ≤ T - 1 → p k = q k) ∧ p T ≠ q T := by
  refine ⟨fun _ => true, fun k => decide (k % T ≠ 0), fun _ => rfl, fun n => ?_, ?_, ?_⟩
  · simp [Nat.add_mod_right]
  · intro k _ hk
    have hk0 : k % T ≠ 0 := by
      have : k % T = k := Nat.mod_eq_of_lt (by omega)
      omega
    simp [hk0]
  · simp [Nat.mod_self]

/-- **The dichotomy.** At the same amount of evidence — the values on `[1,T]` —
the unrestricted class retains a continuum of hypotheses while the periodic
class retains exactly one. Finite evidence is worthless or conclusive depending
entirely on the class, never on the amount of computation. -/
theorem learning_dichotomy {T : ℕ} (hT : 0 < T) (p : ℕ → Bool) :
    Cardinal.continuum ≤ Cardinal.mk (versionSpace p T) ∧
      (∀ q₁ ∈ PeriodicClass T ∩ versionSpace p T, ∀ q₂ ∈ PeriodicClass T ∩ versionSpace p T,
        ∀ n, 1 ≤ n → q₁ n = q₂ n) :=
  ⟨continuum_le_versionSpace p T,
    fun _ h₁ _ h₂ => periodic_versionSpace_subsingleton hT p h₁ h₂⟩

/-- The computational face of the same dichotomy: a universal statement follows
from a finite window exactly when the predicate carries a descent structure.
Both directions matter — the forward one is the proof principle, the backward
one says nothing weaker than a descent structure is being assumed. -/
theorem certifiable_iff_descent (p : ℕ → Bool) :
    (∀ n, 1 ≤ n → p n = true) ↔ Nonempty (DescentCertificate p) :=
  (descentCertificate_nonempty_iff p).symm

/-- Periodicity is one such descent structure, so the periodic class is
certifiable in the strong computational sense as well. -/
theorem periodic_certificate_exists {T : ℕ} (hT : 0 < T) {p : ℕ → Bool}
    (hp : p ∈ PeriodicClass T) (hbase : checkRange p 1 T = true) :
    Nonempty (DescentCertificate p) :=
  (certifiable_iff_descent p).mp (periodic_certifies hT hp hbase)

end CertifiedEvidence