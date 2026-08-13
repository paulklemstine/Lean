import Computation.Factoring.DensSub

/-!
# The free-witness meta-theorem

The round-3 paper's central meta-lesson is that six structurally different
settings (norm counts, group-order counts, quadratic-form counts, group-class
counts, modular indices, and now Reed–Solomon code distances) all produce the
same object: a scalar invariant of `N` that *is* the factorization, and which
is therefore "not `N`-only".

This file makes "not `N`-only" precise and proves it once for the whole family.
A *congruence-determined* invariant is one that depends on `N` only through
`N mod m` (any finite conjunction of congruence conditions is of this form,
with `m` the lcm of the moduli).  We prove:

* `FreeWitness.not_revealsFactor_of_congruenceDetermined` — no
  congruence-determined invariant reveals a nontrivial divisor of every large
  semiprime;
* `FreeWitness.max_factor_not_congruenceDetermined` — in particular the RS-MIND
  witness `N - d(C₂(N)) = max(p,q)` is not congruence-determined;
* `FreeWitness.minFac_not_congruenceDetermined` — nor is the CONG-DIV
  equilibrium bid `minFac N`.

The proofs rest on `DensSub.exists_coprime_semiprimes_in_same_class`, i.e. on
Dirichlet's theorem: every residue class contains *coprime* semiprimes, so no
class-level datum can name a factor.
-/

namespace FreeWitness

/-- `I` is determined by `N mod m`. -/
def CongruenceDetermined (m : ℕ) (I : ℕ → ℕ) : Prop :=
  ∀ N N' : ℕ, N % m = N' % m → I N = I N'

/-- `I` names a nontrivial factor of every semiprime `p·r` (`p < r`) beyond
`B`. -/
def RevealsFactor (I : ℕ → ℕ) (B : ℕ) : Prop :=
  ∀ p r : ℕ, p.Prime → r.Prime → p < r → B < p * r →
    I (p * r) ∣ p * r ∧ 1 < I (p * r) ∧ I (p * r) < p * r

/-- The property `RevealsFactor` is *not* vacuous: the least-prime-factor map
satisfies it.  So the meta-theorem below really is an obstruction on the
*congruence* side, not on the factor-revealing side. -/
theorem revealsFactor_minFac : RevealsFactor Nat.minFac 0 := by
  intro p r hp hr hlt _
  rw [DensSub.minFac_mul_primes hp hr hlt.le]
  exact ⟨dvd_mul_right _ _, hp.one_lt, by nlinarith [hp.two_le, hr.two_le]⟩

/-- **The free-witness meta-theorem.**  A factor-revealing invariant is never
congruence-determined: for every modulus `m > 1` and every bound `B`, an
invariant depending only on `N mod m` fails to name a factor of some semiprime
`N > B`. -/
theorem not_revealsFactor_of_congruenceDetermined {m : ℕ} (hm : 1 < m) {I : ℕ → ℕ}
    (hI : CongruenceDetermined m I) (B : ℕ) : ¬ RevealsFactor I B := by
  intro hrev
  obtain ⟨p₁, r₁, p₂, r₂, hp₁, hr₁, hp₂, hr₂, hlt₁, hlt₂, hB₁, hB₂, hcl,
    hne₁, hne₂, hne₃, hne₄⟩ := DensSub.exists_coprime_semiprimes_in_same_class hm B
  obtain ⟨hd₁, hgt₁, hlt₁'⟩ := hrev p₁ r₁ hp₁ hr₁ hlt₁ hB₁
  obtain ⟨hd₂, hgt₂, hlt₂'⟩ := hrev p₂ r₂ hp₂ hr₂ hlt₂ hB₂
  have hmod : (p₁ * r₁) % m = (p₂ * r₂) % m :=
    (ZMod.natCast_eq_natCast_iff _ _ _).mp hcl
  have hIeq : I (p₁ * r₁) = I (p₂ * r₂) := hI _ _ hmod
  rw [hIeq] at hd₁ hgt₁ hlt₁'
  set d := I (p₂ * r₂) with hd
  have hc₁ : d = p₁ ∨ d = r₁ := by
    rcases Semiprime.dvd_cases hp₁ hr₁ hd₁ with h | h | h | h
    · omega
    · exact Or.inl h
    · exact Or.inr h
    · omega
  have hc₂ : d = p₂ ∨ d = r₂ := by
    rcases Semiprime.dvd_cases hp₂ hr₂ hd₂ with h | h | h | h
    · omega
    · exact Or.inl h
    · exact Or.inr h
    · omega
  rcases hc₁ with h₁ | h₁ <;> rcases hc₂ with h₂ | h₂ <;> omega

/-- The RS-MIND witness `max(p,q) = N - d(C₂(N))` is not congruence-determined:
the code's minimum distance cannot be read off from residue data. -/
theorem max_factor_not_congruenceDetermined {m : ℕ} (hm : 1 < m) {I : ℕ → ℕ}
    (hI : CongruenceDetermined m I) (B : ℕ) :
    ¬ (∀ p r : ℕ, p.Prime → r.Prime → p < r → B < p * r → I (p * r) = r) := by
  intro hmax
  refine not_revealsFactor_of_congruenceDetermined hm hI B ?_
  intro p r hp hr hlt hB
  rw [hmax p r hp hr hlt hB]
  exact ⟨dvd_mul_left _ _, hr.one_lt, by nlinarith [hp.two_le, hr.two_le]⟩

/-- The CONG-DIV equilibrium bid `minFac N` is not congruence-determined. -/
theorem minFac_not_congruenceDetermined {m : ℕ} (hm : 1 < m) {I : ℕ → ℕ}
    (hI : CongruenceDetermined m I) (B : ℕ) :
    ¬ (∀ p r : ℕ, p.Prime → r.Prime → p < r → B < p * r → I (p * r) = (p * r).minFac) := by
  intro hmf
  refine not_revealsFactor_of_congruenceDetermined hm hI B ?_
  intro p r hp hr hlt hB
  rw [hmf p r hp hr hlt hB, DensSub.minFac_mul_primes hp hr hlt.le]
  exact ⟨dvd_mul_right _ _, hp.one_lt, by nlinarith [hp.two_le, hr.two_le]⟩

end FreeWitness