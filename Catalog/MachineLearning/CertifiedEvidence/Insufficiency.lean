/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The exact logical strength of a finite certificate

`CertifiedEvidence.Core` gives a checker whose success on `[1, N]` is *equivalent*
to the bounded statement `∀ k ∈ [1,N], p k`.  This file measures how far that is
from the universal statement `∀ k ≥ 1, p k`, and the answer is: infinitely far,
uniformly in `N`, for a reason that is exactly the learning-theoretic one.

## Main results

* `truncate_agrees` / `truncate_fails` — the truncation operator produces, from
  any checker, a checker with the *same* evidence on `[1,N]` and an explicit
  counterexample at `N+1`.
* `finite_check_not_sound` — for every bound `N` there is a predicate passing
  the `N`-certificate and failing universally: no finite bound is a proof.
* `no_uniform_bound` — the diagonal form: there is no bound `N` that works for
  all predicates simultaneously.
* `versionSpace_infinite`, `continuum_le_versionSpace` — the *version space*
  (the set of hypotheses consistent with the evidence) after any finite amount
  of evidence still has the cardinality of the continuum.  Finite evidence
  removes no positive fraction of the hypothesis space.
* `no_finite_sample_determines` — no finite sample pins down a hypothesis: the
  class `ℕ → Bool` shatters every finite set, i.e. it has infinite VC dimension.
  This is the learning-theoretic reading of the previous item.
* `evidence_monotone_but_never_sufficient` — the two facts combined: evidence
  is monotone in `N` (more computation never hurts) yet its limit is not the
  universal statement for any single `N`.
-/

import Mathlib
import MachineLearning.CertifiedEvidence.Core

namespace CertifiedEvidence

/-! ## §1. Truncation: evidence-preserving sabotage -/

/-- `truncate p N` agrees with `p` on `[0, N]` and is `false` afterwards. -/
def truncate (p : ℕ → Bool) (N : ℕ) : ℕ → Bool := fun k => p k && decide (k ≤ N)

theorem truncate_apply_of_le {p : ℕ → Bool} {N k : ℕ} (h : k ≤ N) :
    truncate p N k = p k := by
  simp [truncate, h]

theorem truncate_apply_of_gt {p : ℕ → Bool} {N k : ℕ} (h : N < k) :
    truncate p N k = false := by
  simp [truncate, Nat.not_le.mpr h]

/-- The truncated checker passes exactly the same finite certificate. -/
theorem truncate_agrees (p : ℕ → Bool) (N lo : ℕ) :
    checkRange (truncate p N) lo N = checkRange p lo N := by
  by_cases h : checkRange p lo N = true
  · rw [h]
    refine checkRange_of _ lo N fun k hk hk' => ?_
    rw [truncate_apply_of_le hk']
    exact of_checkRange h hk hk'
  · rw [Bool.not_eq_true] at h
    rw [h, Bool.eq_false_iff]
    intro hc
    obtain ⟨k, hk1, hk2, hk3⟩ := exists_counterexample_of_checkRange_false h
    have := of_checkRange hc hk1 hk2
    rw [truncate_apply_of_le hk2, hk3] at this
    exact Bool.noConfusion this

/-- …but it is false immediately outside the certified window. -/
theorem truncate_fails (p : ℕ → Bool) (N : ℕ) : truncate p N (N + 1) = false :=
  truncate_apply_of_gt (Nat.lt_succ_self N)

/-! ## §2. No finite bound is a proof -/

/-- **Finite certificates are not sound for the universal statement.** For every
bound `N` there is a predicate whose `[1,N]`-certificate is verified and which
nevertheless fails. The witness is explicit: truncate the constant-`true`
predicate at `N`. -/
theorem finite_check_not_sound (N : ℕ) :
    ∃ p : ℕ → Bool, checkRange p 1 N = true ∧ ¬ (∀ k, 1 ≤ k → p k = true) := by
  refine ⟨truncate (fun _ => true) N, ?_, ?_⟩
  · rw [truncate_agrees]
    exact checkRange_of _ 1 N fun _ _ _ => rfl
  · intro h
    have := h (N + 1) (by omega)
    rw [truncate_fails] at this
    exact Bool.noConfusion this

/-- The diagonal form: no single bound certifies all predicates. -/
theorem no_uniform_bound :
    ¬ ∃ N : ℕ, ∀ p : ℕ → Bool, checkRange p 1 N = true → ∀ k, 1 ≤ k → p k = true := by
  rintro ⟨N, hN⟩
  obtain ⟨p, hp, hp'⟩ := finite_check_not_sound N
  exact hp' (hN p hp)

/-- Sharper: even a predicate that has *already* been certified on `[1,N]` can be
modified beyond `N` without disturbing the evidence.  Certification therefore
carries no information about inputs it did not touch. -/
theorem certificate_carries_no_information (p : ℕ → Bool) (N : ℕ) :
    ∃ q : ℕ → Bool, (∀ k, k ≤ N → q k = p k) ∧ q (N + 1) = false ∧ q (N + 2) = true := by
  refine ⟨fun k => if k ≤ N then p k else decide (k ≠ N + 1), fun k hk => by simp [hk], ?_, ?_⟩
  · simp
  · simp

/-! ## §3. The version space after finite evidence -/

/-- The set of hypotheses consistent with the evidence collected on `[1,N]`. -/
def versionSpace (p : ℕ → Bool) (N : ℕ) : Set (ℕ → Bool) :=
  {q | ∀ k, 1 ≤ k → k ≤ N → q k = p k}

/-- The canonical way to build a consistent hypothesis out of arbitrary behaviour
beyond the evidence window. -/
def extendBeyond (p : ℕ → Bool) (N : ℕ) (f : ℕ → Bool) : ℕ → Bool :=
  fun k => if k ≤ N then p k else f (k - (N + 1))

theorem extendBeyond_mem (p : ℕ → Bool) (N : ℕ) (f : ℕ → Bool) :
    extendBeyond p N f ∈ versionSpace p N := by
  intro k _ hk
  simp [extendBeyond, hk]

theorem extendBeyond_injective (p : ℕ → Bool) (N : ℕ) :
    Function.Injective (extendBeyond p N) := by
  intro f g h
  funext m
  have := congrFun h (m + N + 1)
  simpa [extendBeyond, Nat.not_le.mpr (show N < m + N + 1 by omega),
    show m + N + 1 - (N + 1) = m by omega] using this

/-- Every certificate leaves infinitely many hypotheses standing. -/
theorem versionSpace_infinite (p : ℕ → Bool) (N : ℕ) : (versionSpace p N).Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (f := fun i : ℕ => extendBeyond p N (fun m => decide (m = i))) ?_ ?_
  · intro i j hij
    have := extendBeyond_injective p N hij
    have h := congrFun this i
    simpa using h.symm
  · intro i
    exact extendBeyond_mem p N _

/-- Quantitatively: the version space still has the cardinality of the continuum.
Finite evidence eliminates none of the hypothesis space in the sense of
cardinality. -/
theorem continuum_le_versionSpace (p : ℕ → Bool) (N : ℕ) :
    Cardinal.continuum ≤ Cardinal.mk (versionSpace p N) := by
  have hinj : Function.Injective
      (fun f : ℕ → Bool => (⟨extendBeyond p N f, extendBeyond_mem p N f⟩ :
        versionSpace p N)) := by
    intro f g h
    exact extendBeyond_injective p N (congrArg Subtype.val h)
  have h1 : Cardinal.mk (ℕ → Bool) ≤ Cardinal.mk (versionSpace p N) :=
    Cardinal.mk_le_of_injective hinj
  have h2 : Cardinal.mk (ℕ → Bool) = Cardinal.continuum := by
    rw [Cardinal.mk_arrow]
    simp [Cardinal.two_power_aleph0]
  rwa [h2] at h1

/-! ## §4. The learning-theoretic reading: infinite VC dimension -/

/-- **No finite sample determines a hypothesis.** For every finite sample `S`
and every hypothesis `p` there is a *different* hypothesis agreeing with `p` on
all of `S`. Equivalently the class `ℕ → Bool` shatters every finite set, so its
VC dimension is infinite and no finite sample complexity exists. -/
theorem no_finite_sample_determines (S : Finset ℕ) (p : ℕ → Bool) :
    ∃ q : ℕ → Bool, (∀ k ∈ S, q k = p k) ∧ q ≠ p := by
  classical
  obtain ⟨m, hm⟩ : ∃ m, m ∉ S := by
    refine ⟨(S.sup id) + 1, fun hmem => ?_⟩
    have : (S.sup id) + 1 ≤ S.sup id := Finset.le_sup (f := id) hmem
    omega
  refine ⟨fun k => if k = m then !p k else p k, ?_, ?_⟩
  · intro k hk
    have : k ≠ m := fun h => hm (h ▸ hk)
    simp [this]
  · intro hcontra
    have := congrFun hcontra m
    simp at this

/-- **Summary of the negative side.** Evidence is monotone in the bound — a
certificate at `M` contains the certificate at any `N ≤ M` — yet for no bound is
the certificate equivalent to the universal statement. -/
theorem evidence_monotone_but_never_sufficient :
    (∀ (p : ℕ → Bool) (N M : ℕ), N ≤ M → checkRange p 1 M = true → checkRange p 1 N = true) ∧
      (∀ N : ℕ, ∃ p : ℕ → Bool, checkRange p 1 N = true ∧ ¬ (∀ k, 1 ≤ k → p k = true)) :=
  ⟨fun _ _ _ hNM hM => checkRange_mono hM le_rfl hNM, finite_check_not_sound⟩

end CertifiedEvidence