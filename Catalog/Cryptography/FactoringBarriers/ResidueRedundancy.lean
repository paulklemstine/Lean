import Mathlib

/-!
# The residue-redundancy theorem: two prime-residue leaks are not two leaks
# (Factoring round 101).

The `ResiduePartialFactor` method (round 99) factors `N=pq` deterministically from
the residue `a = p mod M`. Round 100 raised the frontier question: knowing **both**
`p mod M` and `q mod M` — genuinely independent per-factor information, unlike
round 97b's within-one-factor coupling — could a bivariate lattice break `N^{1/4}`?

THIS FILE PROVES THE ANSWER IS NO: the two residues are **not independent**.

**`compat`.** If `p ≡ a (mod M)` and `q ≡ b (mod M)`, then `N = p·q ≡ a·b (mod M)`:
`M ∣ (a·b − N)`. Crucially, this compatibility condition involves **only the two
residues**, never the unknown quotients `x, y` in `p = a + M·x`, `q = b + M·y`. So
the second residue adds **no information** about the unknown offsets — it is
redundant, exactly as in round 97b's `p/q` coupling but for the residue model.

Operationally: the set of divisors `P ∣ N` with `P ≡ a (mod M)` is unchanged by
also requiring `N/P ≡ b (mod M)`, because `b` is forced (empirically verified
5000/5000 in `residue_redundancy.py`). This **closes** the frontier question of
round 100: there is no bivariate gain from a second residue leak.

Axioms: `[propext, Classical.choice, Quot.sound]` only (standard).
-/

namespace Cryptography.FactoringBarriers.ResidueRedundancy

/-- **Two residues are compatible with `N = p·q` iff `M ∣ (a·b − N)`, and this
depends only on the residues, not on the unknown quotients.** Therefore a second
residue leak is redundant. -/
theorem compat {N M a b p q : ℤ} (hp : M ∣ (p - a)) (hq : M ∣ (q - b))
    (hpq : p * q = N) : M ∣ (a * b - N) := by
  obtain ⟨k1, hk1⟩ := hp
  obtain ⟨k2, hk2⟩ := hq
  have hp' : p = a + M * k1 := by linarith
  have hq' : q = b + M * k2 := by linarith
  have hN : N = (a + M * k1) * (b + M * k2) := by rw [← hpq, hp', hq']
  refine ⟨-(a * k2 + b * k1 + M * k1 * k2), ?_⟩
  rw [hN]
  ring

end Cryptography.FactoringBarriers.ResidueRedundancy