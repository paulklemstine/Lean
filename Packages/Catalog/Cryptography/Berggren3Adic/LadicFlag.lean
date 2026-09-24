import Mathlib.Data.Int.ModEq
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Lean.Elab.Tactic.Omega

/-!
# The ℓ = 2 skeleton flag, and the generalisation of "the skeleton is a function of `N mod ℓ^k`"

`Skeleton.lean` machine-checks, for **ℓ = 3**, that the skeleton of a Fermat pair is
*exactly* the residue `N mod 3` — the channel `pair ↦ skeleton` carries no information
beyond one residue class. This file does two things.

## 1. The ℓ = 2 flag, machine-checked

For odd `p q` the Fermat pair is `(m,n) = ((q+p)/2, (q−p)/2)` and `N = m² − n² = pq`.
The ℓ = 2 skeleton flag ("which coordinate is even") is **exactly** the residue `N mod 4`:

- `n` even  ⟺  `q ≡ p (mod 4)`  ⟺  `pq ≡ 1 (mod 4)`
- `m` even  ⟺  `q ≡ −p (mod 4)` ⟺  `pq ≡ 3 (mod 4)`

stated below as `four_dvd_pq_sub_one_iff_four_dvd_q_sub_p`. This is the ℓ = 2
generalisation of `Skeleton.skeleton`, and it is the theorem that **kills the "2-adic
close-prime detector"**: the only sealed 2-adic fact is a parity bit already visible in
`N mod 4`, carrying **zero** size information.

## 2. Why ℓ = 3 and ℓ = 2 are the *only* sealed cases — and the honest limit

The flag is residue-determined for **ℓ = 3** (from `N mod 3`, by `Skeleton.lean`) and for
**ℓ = 2** (from `N mod 4`, by this file). For **every prime ℓ ≥ 5 the flag is unsealed**:
two coprime Fermat pairs with equal `N mod ℓ^k` can have different skeletons, at every
depth `k` tested. The reason is elementary — over `F_ℓ` with `ℓ ≥ 5` a difference of two
nonzero squares is unconstrained, whereas over `F_3` the only nonzero square is `1`, which
forces `3 ∣ N`. The same parity obstruction explains ℓ = 2, where `−1` is a nonresidue.

**This unsealed-ness is stated here as a documented empirical finding, not a theorem.**
Proving it would require exhibiting, for each `ℓ ≥ 5`, an explicit pair of counterexamples
at each depth; no such uniform construction is formalised, and none should be inferred
from this file. What *is* proved is the positive direction only: the ℓ = 2 flag theorem
below, and by `Skeleton.lean` the ℓ = 3 one.

**Scope discipline.** The kill of the 2-adic detector does **not** rest on the absence of
further 2-adic information — it rests on the *direction* of what `v₂` measures. Since
`2^{v₂(gap)} ∣ gap` forces `gap ≥ 2^{v₂(gap)}`, a large 2-adic level certifies a **large**
gap, so the level is monotonically **anti-correlated** with closeness. No residue, and no
level, points the right way.

Narrow imports only, per the file-level discipline of this project.
-/

namespace Berggren3Adic.LadicFlag

/-- Odd `p` means `p = 2k+1` for some `k`. -/
theorem odd_eq_two_mul_add_one {p : ℤ} (hp : p % 2 = 1) : ∃ k : ℤ, p = 2 * k + 1 := by
  obtain ⟨k, hk⟩ : ∃ k : ℤ, p = 2 * k + p % 2 := ⟨(p - 1) / 2, by omega⟩
  refine ⟨k, ?_⟩
  rw [hk, hp]

/-- For odd `p`, `4 ∣ p² − 1`. -/
theorem four_dvd_sq_sub_one {p : ℤ} (hp : p % 2 = 1) : (4 : ℤ) ∣ p ^ 2 - 1 := by
  obtain ⟨k, hk⟩ := odd_eq_two_mul_add_one hp
  refine ⟨k * (k + 1), ?_⟩
  rw [hk]
  ring

/-- **The ℓ = 2 flag.**  For odd `p`: `p q ≡ 1 (mod 4)` iff `q ≡ p (mod 4)`, i.e. iff the
Fermat gap `q − p` is a multiple of `4`, i.e. iff `n = (q−p)/2` is even.  Equivalently
`4 ∣ (p*q − 1) ↔ 4 ∣ (q − p)`.

This is the machine-checked kill of the "2-adic close-prime detector" (Q4): the ℓ = 2
skeleton flag is a **sealed congruence carrying no size information**, already visible in
`N mod 4`, so the flag cannot serve as a proximity detector for close primes. -/
theorem four_dvd_pq_sub_one_iff_four_dvd_q_sub_p {p q : ℤ} (hp : p % 2 = 1) :
    (4 : ℤ) ∣ (p * q - 1) ↔ (4 : ℤ) ∣ (q - p) := by
  constructor
  · intro h
    obtain ⟨a, ha⟩ := h
    have hpq1 : p * q - 1 = 4 * a := ha
    obtain ⟨b, hb⟩ := four_dvd_sq_sub_one hp
    have hp2m1 : p ^ 2 - 1 = 4 * b := hb
    -- 4 ∣ (p²q − p), since p²q − p = p(pq − 1)
    have hA : (4 : ℤ) ∣ (p ^ 2 * q - p) := by
      refine ⟨p * a, ?_⟩
      have h : p ^ 2 * q - p = p * (p * q - 1) := by ring
      rw [h, hpq1]
      ring
    -- 4 ∣ (p²q − q), since p²q − q = q(p² − 1)
    have hB : (4 : ℤ) ∣ (p ^ 2 * q - q) := by
      refine ⟨q * b, ?_⟩
      have h : p ^ 2 * q - q = q * (p ^ 2 - 1) := by ring
      rw [h, hp2m1]
      ring
    -- subtract: (p²q − p) − (p²q − q) = q − p
    refine ⟨(p * a) - (q * b), ?_⟩
    have e1 : 4 * (p * a) = p ^ 2 * q - p := by
      have h : 4 * (p * a) = p * (p * q - 1) := by rw [hpq1]; ring
      rw [h]
      ring
    have e2 : 4 * (q * b) = p ^ 2 * q - q := by
      have h : 4 * (q * b) = q * (p ^ 2 - 1) := by rw [hp2m1]; ring
      rw [h]
      ring
    have e3 : 4 * (p * a) - 4 * (q * b) = q - p := by rw [e1, e2]; ring
    rw [← e3]
    ring
  · intro h
    obtain ⟨c, hc⟩ := h
    have hqc : q - p = 4 * c := hc
    obtain ⟨b, hb⟩ := four_dvd_sq_sub_one hp
    have hp2m1 : p ^ 2 - 1 = 4 * b := hb
    refine ⟨p * c + b, ?_⟩
    have h : p * q - 1 = p * (q - p) + (p ^ 2 - 1) := by ring
    rw [h, hqc, hp2m1]
    ring

/-- **The direction of the 2-adic level — why the detector points the WRONG WAY.**

`v₂(gap) = j` means `2^j ∣ gap`, so `|gap| ≥ 2^j`. Hence a *higher* 2-adic level forces a
*larger* gap: the level is monotonically **anti-correlated with closeness**. This is the
real kill of Q4 and it is independent of any residue-class question — no amount of sealed
2-adic congruence fixes a level that measures distance backwards.

Stated over `ℕ` because that is the type of the quantity being compared: the gap `g = q − p`
and the level `j = v₂(gap)` are both natural numbers, since `q > p` forces the Fermat gap
positive.  (`(2 : ℕ) ^ j` is then a plain `Monoid.npow`; over `ℤ` it would need a `zpow`
instance that is not built in this environment.) -/
theorem two_pow_dvd_gap_implies_gap_ge {g j : ℕ} (hg : 0 < g)
    (h : (2 : ℕ) ^ j ∣ g) : (2 : ℕ) ^ j ≤ g := by
  obtain ⟨c, hc⟩ := h
  rcases Nat.eq_zero_or_pos c with hc0 | hcpos
  · exfalso
    have : g = 0 := by rw [hc, hc0]; simp
    omega
  · have h2 : (2 : ℕ) ^ j * 1 ≤ (2 : ℕ) ^ j * c := Nat.mul_le_mul_left _ hcpos
    have h3 : (2 : ℕ) ^ j * c ≤ g := by rw [hc]
    simpa using h2.trans h3

end Berggren3Adic.LadicFlag
