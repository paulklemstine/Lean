/-
# Adversarial review: where the no-pruning theorem stops, and why

Fourth file of the residue-leakage thread.  Stage-4 critique of
`dirichlet_no_pruning`: its hypotheses are not decoration.

* `qrFingerprint_mul_sq` — the fingerprint is a *square-class* invariant:
  `F(m·s²) = F(m)`.  So `F_A` can never determine `N`; it only sees the class of
  `N` in `(ℤ/4∏A)ˣ / squares`.  This is the structural reason the "collision-free
  hash" reading of the experiment is false.
* `probe_divisor_forces_factor` — the sharp boundary of no-pruning: if some probe
  prime `a` *divides* the target `N₀`, then the fingerprint prunes completely —
  the only consistent second factor is `q = a`.  Hence the coprimality
  hypothesis in `dirichlet_no_pruning` is necessary, and the only pruning power
  the residue channel ever has is the trivial detection of a tiny prime factor,
  which trial division finds anyway.
* `qrFingerprint_eq_of_dvd_probe` — in that degenerate case the fingerprint has a
  `0` entry, i.e. the leak is visible directly in the data.
-/

import Mathlib
import Bridges.ResidueLeakageDirichletNoPruning

namespace Bridges.ResidueLeakage

/-- **Square-class invariance.**  Multiplying by a square coprime to the probe
primes does not change the fingerprint.  Consequently the fingerprint is an
invariant of the square class of `N` modulo `4∏A` and cannot identify `N`. -/
theorem qrFingerprint_mul_sq {A : List ℕ} (hA : ∀ a ∈ A, a.Prime) {m s : ℕ}
    (hm : m ≠ 0) (hs : s ≠ 0) (hcop : ∀ a ∈ A, ¬ a ∣ s) :
    qrFingerprint A (m * s ^ 2) = qrFingerprint A m := by
  haveI : NeZero m := ⟨hm⟩
  haveI : NeZero s := ⟨hs⟩
  refine qrFingerprint_congr fun a ha => ?_
  have hcopa : Int.gcd (a : ℤ) (s : ℕ) = 1 := by
    have : Nat.Coprime a s := (Nat.Prime.coprime_iff_not_dvd (hA a ha)).2 (hcop a ha)
    simpa [Int.gcd_natCast_natCast] using this
  have hsq : jacobiSym (a : ℤ) s * jacobiSym (a : ℤ) s = 1 := by
    rcases jacobiSym.eq_one_or_neg_one hcopa with h | h <;> rw [h] <;> norm_num
  calc jacobiSym (a : ℤ) (m * s ^ 2)
      = jacobiSym (a : ℤ) (m * (s * s)) := by rw [sq]
    _ = jacobiSym (a : ℤ) m * (jacobiSym (a : ℤ) s * jacobiSym (a : ℤ) s) := by
        rw [jacobiSym.mul_right (a : ℤ) m (s * s), jacobiSym.mul_right (a : ℤ) s s]
    _ = jacobiSym (a : ℤ) m := by rw [hsq, mul_one]

/-- If a probe prime divides `N₀`, the corresponding fingerprint entry is `0`:
the degenerate case is visible in the data. -/
theorem qrFingerprint_eq_of_dvd_probe {N₀ a : ℕ}
    (hdvd : a ∣ N₀) (hN₀ : N₀ ≠ 0) (ha1 : 1 < a) :
    jacobiSym (a : ℤ) N₀ = 0 := by
  rw [jacobiSym.eq_zero_iff]
  refine ⟨hN₀, ?_⟩
  have : Nat.gcd a N₀ = a := Nat.gcd_eq_left hdvd
  simp [Int.gcd_natCast_natCast, this]
  omega

/-- **Sharp boundary of no-pruning.**  If some probe prime `a` divides the
target `N₀`, then the residue data *does* prune: for any candidate prime `p ≠ a`
the only prime `q` with `F_A(p·q) = F_A(N₀)` is `q = a`.  So the coprimality
hypothesis of `dirichlet_no_pruning` cannot be dropped — and the only pruning
the channel ever achieves is the trivial discovery of a probe-size factor. -/
theorem probe_divisor_forces_factor {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    {N₀ p q a : ℕ} (ha : a ∈ A) (hdvd : a ∣ N₀) (hN₀ : N₀ ≠ 0)
    (hp : p.Prime) (hq : q.Prime) (hap : a ≠ p)
    (hcons : qrFingerprint A (p * q) = qrFingerprint A N₀) : q = a := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  haveI : NeZero q := ⟨hq.ne_zero⟩
  have hprime : a.Prime := hA a ha
  have hzero : jacobiSym (a : ℤ) N₀ = 0 :=
    qrFingerprint_eq_of_dvd_probe hdvd hN₀ hprime.one_lt
  have hentry : jacobiSym (a : ℤ) (p * q) = jacobiSym (a : ℤ) N₀ :=
    List.map_inj_left.1 hcons a ha
  have hmul : jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) q = 0 := by
    rw [← jacobiSym.mul_right (a : ℤ) p q, hentry, hzero]
  have hpne : jacobiSym (a : ℤ) p ≠ 0 := by
    have hcop : Int.gcd (a : ℤ) (p : ℕ) = 1 := by
      simpa [Int.gcd_natCast_natCast] using (Nat.coprime_primes hprime hp).2 hap
    rcases jacobiSym.eq_one_or_neg_one hcop with h | h <;> rw [h] <;> norm_num
  have hqzero : jacobiSym (a : ℤ) q = 0 := by
    rcases mul_eq_zero.1 hmul with h | h
    · exact absurd h hpne
    · exact h
  have hnc : ¬ Int.gcd (a : ℤ) (q : ℕ) = 1 := (jacobiSym.eq_zero_iff.1 hqzero).2
  by_contra hne
  exact hnc (by
    simpa [Int.gcd_natCast_natCast] using
      (Nat.coprime_primes hprime hq).2 (fun h => hne h.symm))

end Bridges.ResidueLeakage