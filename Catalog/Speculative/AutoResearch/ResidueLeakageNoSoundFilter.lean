/-
# No sound residue filter can exclude a candidate (conjecture C6)

Eleventh file of the residue-leakage thread.

`dirichlet_no_pruning` says that the *particular* sieve "keep only the primes
`p` for which a compensating `q` exists" is useless.  Conjecture C6 of
`FUTURE_DIRECTIONS.md` asks for the stronger, sieve-independent statement: that
**no** candidate filter whatsoever can be built from the observation `F_A(N)`.

That is what is proved here.  Model an arbitrary residue-based sieve as a
predicate `P : List ℤ → ℕ → Prop`, where `P v p` means "on observing the
fingerprint `v` the algorithm keeps `p` as a possible prime factor".  The only
constraint on a usable sieve is **soundness**: it must never discard a genuine
factor, i.e. `P (F_A(p·q)) p` must hold for every odd semiprime `p·q` built
from probe-free primes.  `no_sound_residue_filter` then shows that any such `P`
accepts *every* admissible candidate for *every* observation, so its accepted
set is the whole candidate set and the sieve performs no pruning at all.

`sound_filter_accepts_all` restates this as a set equality, and
`no_strictly_pruning_filter` states the contrapositive that is the actual
content for cryptanalysis: a residue filter that rejects even one admissible
candidate is necessarily unsound — it discards true factorisations.

This upgrades every "no pruning" statement of the thread from "this sieve
fails" to "no sieve of this shape can exist".  No `sorry`, no `axiom`,
no `native_decide`.
-/

import Mathlib
import Bridges.ResidueLeakageDirichletNoPruning

namespace Bridges.ResidueLeakage

/-- Admissible candidate for a probe list `A`: an odd prime that is not one of
the probe primes (probe-sized factors are found by trial division, and are the
one case where the channel does prune — see `probe_divisor_forces_factor`). -/
def AdmissibleCandidate (A : List ℕ) (p : ℕ) : Prop :=
  p.Prime ∧ Odd p ∧ p ∉ A

/-- Every observation admits a compensating *admissible* partner: given an
observation `F_A(N₀)` and an admissible candidate `p`, there is an admissible
prime `q ≠ p` with `F_A(p·q) = F_A(N₀)`.  This is `dirichlet_no_pruning` with
the finitely many degenerate partners (`2`, `p`, and the probes) removed. -/
theorem exists_admissible_compensator {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    {N₀ p : ℕ} (hN₀ : Odd N₀) (hpadm : AdmissibleCandidate A p)
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) (hpA : ∀ a ∈ A, a ≠ p) :
    ∃ q : ℕ, AdmissibleCandidate A q ∧ q ≠ p ∧
      qrFingerprint A (p * q) = qrFingerprint A N₀ := by
  obtain ⟨hp, hpodd, _⟩ := hpadm
  have hinf := dirichlet_no_pruning hA hN₀ hp hpodd hNA hpA
  have hfin : ({2, p} ∪ {x : ℕ | x ∈ A}).Finite :=
    ((Set.finite_singleton p).insert 2).union A.finite_toSet
  obtain ⟨q, ⟨⟨hq, hqfp⟩, hqnot⟩⟩ := (hinf.diff hfin).nonempty
  have hq2 : q ≠ 2 := fun h => hqnot (Or.inl (by simp [h]))
  have hqp : q ≠ p := fun h => hqnot (Or.inl (by simp [h]))
  have hqA : q ∉ A := fun h => hqnot (Or.inr h)
  exact ⟨q, ⟨hq, hq.odd_of_ne_two hq2, hqA⟩, hqp, hqfp⟩

/-- **No sound residue filter prunes anything** (conjecture C6).  Let
`P v p` be any predicate meaning "the sieve keeps candidate `p` after observing
the fingerprint `v`".  If `P` is *sound* — it keeps the true factors of every
admissible semiprime — then `P` keeps **every** admissible candidate for every
admissible observation.  No filter computed from the QR fingerprint can shrink
the candidate set. -/
theorem no_sound_residue_filter {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (P : List ℤ → ℕ → Prop)
    (hsound : ∀ x y : ℕ, AdmissibleCandidate A x → AdmissibleCandidate A y →
      x ≠ y → P (qrFingerprint A (x * y)) x)
    {N₀ p : ℕ} (hN₀ : Odd N₀) (hpadm : AdmissibleCandidate A p)
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) (hpA : ∀ a ∈ A, a ≠ p) :
    P (qrFingerprint A N₀) p := by
  obtain ⟨q, hqadm, hqp, hfp⟩ :=
    exists_admissible_compensator hA hN₀ hpadm hNA hpA
  have := hsound p q hpadm hqadm (Ne.symm hqp)
  rwa [hfp] at this

/-- Set form: the candidates a sound filter keeps are exactly all admissible
candidates — the filter's output carries no information about the factors. -/
theorem sound_filter_accepts_all {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (P : List ℤ → ℕ → Prop)
    (hsound : ∀ x y : ℕ, AdmissibleCandidate A x → AdmissibleCandidate A y →
      x ≠ y → P (qrFingerprint A (x * y)) x)
    {N₀ : ℕ} (hN₀ : Odd N₀) (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) :
    {p : ℕ | AdmissibleCandidate A p ∧ P (qrFingerprint A N₀) p}
      = {p : ℕ | AdmissibleCandidate A p} := by
  ext p
  simp only [Set.mem_setOf_eq, and_iff_left_iff_imp]
  intro hpadm
  refine no_sound_residue_filter hA P hsound hN₀ hpadm hNA ?_
  intro a ha hap
  exact hpadm.2.2 (hap ▸ ha)

/-- Contrapositive, the cryptanalytically meaningful form: a residue filter
that rejects even a single admissible candidate for a single admissible
observation must be **unsound**, i.e. it throws away a genuine factorisation. -/
theorem no_strictly_pruning_filter {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (P : List ℤ → ℕ → Prop) {N₀ p : ℕ} (hN₀ : Odd N₀)
    (hpadm : AdmissibleCandidate A p) (hNA : ∀ a ∈ A, Nat.Coprime N₀ a)
    (hpA : ∀ a ∈ A, a ≠ p) (hreject : ¬ P (qrFingerprint A N₀) p) :
    ∃ x y : ℕ, AdmissibleCandidate A x ∧ AdmissibleCandidate A y ∧ x ≠ y ∧
      ¬ P (qrFingerprint A (x * y)) x := by
  by_contra hcon
  push_neg at hcon
  exact hreject (no_sound_residue_filter hA P
    (fun x y hx hy hxy => hcon x y hx hy hxy) hN₀ hpadm hNA hpA)

end Bridges.ResidueLeakage