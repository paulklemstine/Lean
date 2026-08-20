import Catalog.Shared.ImmuneBounded

/-!
# Algorithmic Immune System, Part IX: monitoring frequency and periodic self-healing

Part IV assumed the monitor verifies attestation after *every* mutation step.
Real immune systems sample: they verify every `k` steps.  This part determines
exactly what is lost.

`traceK S b adv k` is the guarded run in which quarantine is applied only at
times divisible by `k`.  We prove:

* `traceK_one` — with `k = 1` sampled monitoring *is* the continuous monitoring of
  Part IV, so containment and neutralization hold verbatim;
* `periodic_healing` — for any `k` and any adversary the system is sanctioned at
  every checkpoint: damage is always repaired within one period (self-healing);
* `sampling_gap` — but for `k ≥ 2` there is an adversary and a time at which the
  forbidden action *is* executed: no relaxation of the sampling rate is safe;
* `attack_window` — worse, the adversary keeps the system compromised at every
  non-checkpoint time, so the fraction of compromised steps is `(k-1)/k`;
* `monitoring_frequency_dichotomy` — continuous monitoring is therefore both
  necessary and sufficient for total containment.
-/

namespace ImmuneSystem
namespace PAst

/-- The sampled guarded run: the adversary mutates at every step, the monitor
verifies and rolls back only at times divisible by `k`. -/
def traceK (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (k : ℕ) : ℕ → PAst
  | 0 => b
  | n + 1 =>
      if (n + 1) % k = 0 then quarantine S b (adv n (traceK S b adv k n))
      else adv n (traceK S b adv k n)

@[simp] theorem traceK_zero (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (k : ℕ) :
    traceK S b adv k 0 = b := rfl

theorem traceK_succ (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (k n : ℕ) :
    traceK S b adv k (n + 1) =
      if (n + 1) % k = 0 then quarantine S b (adv n (traceK S b adv k n))
      else adv n (traceK S b adv k n) := rfl

/-- Continuous monitoring: sampling with period `1` is exactly the guarded run of
Part IV. -/
theorem traceK_one (S : Finset PAst) (b : PAst) (adv : ℕ → PAst → PAst) (n : ℕ) :
    traceK S b adv 1 n = trace S b adv n := by
  induction n with
  | zero => rfl
  | succ n ih => rw [traceK_succ, trace_succ, ih]; simp [Nat.mod_one]

/-- **Periodic self-healing.**  Whatever the adversary does, at every checkpoint
(and at time `0`) the running program is sanctioned again: any compromise is
repaired within one monitoring period. -/
theorem periodic_healing {S : Finset PAst} {b : PAst} (hb : b ∈ S) (adv : ℕ → PAst → PAst)
    {k n : ℕ} (hdvd : k ∣ n) : traceK S b adv k n ∈ S := by
  cases n with
  | zero => simpa using hb
  | succ m =>
      have hmod : (m + 1) % k = 0 := Nat.dvd_iff_mod_eq_zero.1 hdvd
      rw [traceK_succ, if_pos hmod]
      exact quarantine_mem hb _

/-- **The sampling gap.**  For every period `k ≥ 2` there is an adversary that
gets the forbidden action executed: sampled monitoring is never safe. -/
theorem sampling_gap {S : Finset PAst} (b : PAst) {k : ℕ} (hk : 2 ≤ k) :
    ∃ (adv : ℕ → PAst → PAst) (n : ℕ), malicious (traceK S b adv k n) := by
  refine ⟨fun _ _ => attack, 1, ?_⟩
  have h1 : (0 + 1) % k = 1 := Nat.mod_eq_of_lt (by omega)
  rw [traceK_succ, if_neg (by rw [h1]; omega)]
  exact malicious_attack

/-- **The attack window.**  With period `k ≥ 2` the adversary keeps the system
compromised at *every* non-checkpoint time: a `(k-1)/k` fraction of the run is
spent executing the forbidden action, and only the checkpoints are clean. -/
theorem attack_window {S : Finset PAst} (b : PAst) {k n : ℕ}
    (hn : (n + 1) % k ≠ 0) :
    malicious (traceK S b (fun _ _ => attack) k (n + 1)) := by
  rw [traceK_succ, if_neg hn]
  exact malicious_attack

/-- **Continuous monitoring is necessary and sufficient.**  With period `1` the
immune system contains every adversary; with any larger period some adversary
succeeds. -/
theorem monitoring_frequency_dichotomy {S : Finset PAst} {b : PAst} (hb : b ∈ S)
    (hsafe : ∀ t ∈ S, ¬ malicious t) :
    (∀ (adv : ℕ → PAst → PAst) (n : ℕ), ¬ malicious (traceK S b adv 1 n)) ∧
      (∀ k : ℕ, 2 ≤ k → ∃ (adv : ℕ → PAst → PAst) (n : ℕ),
        malicious (traceK S b adv k n)) := by
  constructor
  · intro adv n
    rw [traceK_one]
    exact neutralization hb hsafe adv n
  · intro k hk
    exact sampling_gap b hk

end PAst
end ImmuneSystem