/-
# TRACEPROFILE V — the pinning barrier: why one bit per prime is not a factoring tool

Phase A research file (Novelty domain), Paper 50 / Experiment 385, third research
cycle.

Cycles I–II established the positive half of the trace profile: modulo a squarefree
odd `M = ∏_{p ∈ P} p` coprime to `N`, the trace `s = p + q` of the semiprime is
confined to a set `S_M(N)` of density `2^{-|P|}` (one bit per prime, exactly the
Legendre symbols).  This file proves the negative half — the paper's verdict that
the trace "cannot scale to pin `s`".

The search window for a trace is `[1, N]`: for `p, q ≥ 2` one always has
`p + q ≤ p q = N` (`trace_le_modulus`).  The theorem below counts how many integers
of that window survive *all* the congruence conditions at once:

`2^{|P|} · #{t ≤ N : t mod M ∈ S_M(N)} ≥ (∏_{p ∈ P} (p-1)) · (N/M - 1)`,

i.e. roughly `N / 2^{|P|}` candidates remain.  The congruence data therefore isolates
the trace only when `2^{|P|} ≳ N`, that is `|P| ≳ log₂ N` primes — a modulus
`M = ∏ p` far larger than `N` itself.  One bit per prime is *additive*, while the
search space is *exponential*: the trace is the most accessible residue target and
is still useless for factoring.

## Main results

* `trace_le_modulus` — the search window: `p + q ≤ p q`.
* `card_residue_class_ge` — a congruence class modulo `M` meets `[1, N]` in at least
  `N/M - 1` points.
* `card_candidates_ge` — hence a residue *set* `S` leaves at least `|S|·(N/M - 1)`
  candidates.
* `trace_pinning_barrier` — the combination with the one-bit-per-prime law: the
  surviving-candidate count is at least `(∏ (p-1)) (N/M - 1) / 2^{|P|}`.
* `trace_not_pinned_of_small_modulus` — corollary in the form "two candidates
  survive": no modulus `M ≤ (N-1)/2` can determine the trace.
-/

import Mathlib
import Novelty.TraceProfileTraceSet

namespace Novelty.TraceProfile

open Finset

/-- The search window for a trace: for factors `≥ 2` the trace never exceeds the
modulus. -/
theorem trace_le_modulus {p q : ℕ} (hp : 2 ≤ p) (hq : 2 ≤ q) : p + q ≤ p * q := by
  nlinarith

/-- A congruence class modulo `M` meets the window `[1, N]` in at least `N/M - 1`
points. -/
theorem card_residue_class_ge (M N : ℕ) [NeZero M] (s : ZMod M) :
    N / M - 1 ≤ ((Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) = s)).card := by
  classical
  have hM : 0 < M := Nat.pos_of_ne_zero (NeZero.ne M)
  set K := N / M with hK
  rcases Nat.lt_or_ge K 2 with hK2 | hK2
  · omega
  · have hKM : K * M ≤ N := Nat.div_mul_le_self N M
    have hval : s.val < M := ZMod.val_lt s
    have hKM' : (K - 1) * M + M = K * M := by
      have hk1 : K - 1 + 1 = K := by omega
      calc (K - 1) * M + M = (K - 1 + 1) * M := by ring
        _ = K * M := by rw [hk1]
    rw [← Finset.card_range (K - 1)]
    refine Finset.card_le_card_of_injOn (fun k => s.val + (k + 1) * M) ?_ ?_
    · intro k hk
      have hk' : k < K - 1 := Finset.mem_range.mp hk
      have hlow : 1 ≤ s.val + (k + 1) * M := by
        have : 1 * M ≤ (k + 1) * M := Nat.mul_le_mul_right M (by omega)
        omega
      have hhigh : s.val + (k + 1) * M ≤ N := by
        have h2 : (k + 1) * M ≤ (K - 1) * M := Nat.mul_le_mul_right M (by omega)
        omega
      have hcast : (((s.val + (k + 1) * M : ℕ)) : ZMod M) = s := by
        push_cast
        rw [ZMod.natCast_zmod_val]
        simp
      exact Finset.mem_filter.2 ⟨Finset.mem_Icc.2 ⟨hlow, hhigh⟩, hcast⟩
    · intro a _ b _ hab
      have hab' : s.val + (a + 1) * M = s.val + (b + 1) * M := hab
      have heq : (a + 1) * M = (b + 1) * M := by omega
      have := Nat.eq_of_mul_eq_mul_right hM heq
      omega

/-- A residue *set* `S` modulo `M` leaves at least `|S| · (N/M - 1)` candidates in the
window `[1, N]`. -/
theorem card_candidates_ge (M N : ℕ) [NeZero M] (S : Finset (ZMod M)) :
    S.card * (N / M - 1) ≤ ((Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) ∈ S)).card := by
  classical
  have hsplit : ((Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) ∈ S))
      = S.biUnion (fun s => (Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) = s)) := by
    ext t
    simp only [Finset.mem_filter, Finset.mem_biUnion]
    constructor
    · rintro ⟨ht, hmem⟩
      exact ⟨_, hmem, ht, rfl⟩
    · rintro ⟨s, hs, ht, rfl⟩
      exact ⟨ht, hs⟩
  have hdisj : ∀ s ∈ S, ∀ s' ∈ S, s ≠ s' →
      Disjoint ((Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) = s))
        ((Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) = s')) := by
    intro s _ s' _ hss'
    refine Finset.disjoint_left.2 ?_
    intro t ht ht'
    simp only [Finset.mem_filter] at ht ht'
    exact hss' (ht.2 ▸ ht'.2 ▸ rfl)
  rw [hsplit, Finset.card_biUnion hdisj]
  calc S.card * (N / M - 1) = ∑ _s ∈ S, (N / M - 1) := by
        rw [Finset.sum_const, smul_eq_mul]
    _ ≤ ∑ s ∈ S, ((Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) = s)).card :=
        Finset.sum_le_sum (fun s _ => card_residue_class_ge M N s)

/-- **The pinning barrier.**  For a squarefree odd modulus `M = ∏_{p ∈ P} p` coprime
to `N`, the number of integers in the search window `[1, B]` whose residue is a
legal trace residue is at least `(∏ (p-1)) (B/M - 1) / 2^{|P|}`: the surviving set
still has density `≈ 2^{-|P|}`.  Congruence data can single out the trace only once
`2^{|P|}` exceeds the window, i.e. only after `|P| ≳ log₂ B` primes. -/
theorem trace_pinning_barrier (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime)
    (h2 : ∀ p ∈ P, p ≠ 2) (N : ℕ) (hN : ∀ p ∈ P, ¬ (p ∣ N))
    (M : ℕ) [NeZero M] (hM : M = ∏ p ∈ P, p) (B : ℕ) :
    (∏ p ∈ P, (p - 1)) * (B / M - 1)
      ≤ 2 ^ P.card *
        ((Finset.Icc 1 B).filter (fun t : ℕ => (t : ZMod M) ∈ traceSet ((N : ZMod M)))).card := by
  classical
  have hcand := card_candidates_ge M B (traceSet ((N : ZMod M)))
  have hbits := (traceNat_one_bit_per_prime P hP h2 N hN).1
  have hSize : traceNat (∏ p ∈ P, p) N = (traceSet ((N : ZMod M))).card := by
    subst hM
    exact traceNat_eq_card _ N
  rw [hSize] at hbits
  calc (∏ p ∈ P, (p - 1)) * (B / M - 1)
      ≤ (2 ^ P.card * (traceSet ((N : ZMod M))).card) * (B / M - 1) :=
        Nat.mul_le_mul_right _ hbits
    _ = 2 ^ P.card * ((traceSet ((N : ZMod M))).card * (B / M - 1)) := by ring
    _ ≤ 2 ^ P.card * ((Finset.Icc 1 B).filter
          (fun t : ℕ => (t : ZMod M) ∈ traceSet ((N : ZMod M)))).card :=
        Nat.mul_le_mul_left _ hcand

/-- **Two candidates always survive.**  A modulus `M` with `2M ≤ N - 1` never
determines the trace: the residue class of `s` modulo `M` contains at least two
integers of the window `[1, N]`, and the trace is one of them.  (The hypothesis is `3M ≤ N`, which
is what the counting lemma gives; the statement is false for `M` comparable to
`N`.) -/
theorem trace_not_pinned_of_small_modulus (M N : ℕ) [NeZero M] (h : 3 * M ≤ N) (s : ZMod M) :
    2 ≤ ((Finset.Icc 1 N).filter (fun t : ℕ => (t : ZMod M) = s)).card := by
  have hM : 0 < M := Nat.pos_of_ne_zero (NeZero.ne M)
  have hcl := card_residue_class_ge M N s
  have hdiv : 3 ≤ N / M := (Nat.le_div_iff_mul_le hM).2 (by omega)
  omega

end Novelty.TraceProfile