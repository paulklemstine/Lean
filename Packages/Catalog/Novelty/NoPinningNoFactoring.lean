/-
# From no-pinning to no-factoring

Fourth companion to `Novelty/NoPinningLemma.lean`.  The no-pinning lemma is a
statement about candidates; here we convert it into an *unconditional
impossibility statement about algorithms*: no map whose input is the readout of
a modulus-`L` battery can output a nontrivial factor of every semiprime, for
**any** modulus `L` whatsoever — not merely for `poly(log N)`-sized moduli.

The mechanism is the compensating-partner lemma applied twice: a single residue
class contains two *coprime* semiprimes `p₁q₁` and `p₂q₂`, so a nontrivial
divisor computed from the class alone would have to divide two coprime numbers.

## Main results

* `exists_two_coprime_semiprimes_same_class` — every modulus `L` admits two
  coprime semiprimes with the same residue mod `L` (built from four distinct
  primes coprime to `L`).
* `no_congruence_factoring` — **main theorem**: for any modulus `L` with
  `2 ∣ L`, any observable `f` of modulus `L` and any decoding map `A`, the pair
  `(f, A)` fails to produce a nontrivial divisor for some semiprime coprime to
  `L`.
* `no_residue_factoring` — the special case `f = (· % L)`, i.e. the strongest
  possible congruence battery.
-/

import Mathlib
import Novelty.NoPinningLemma
import Novelty.NoPinningSealing

namespace Novelty.NoPinning

/-- Four distinct primes coprime to `L` producing two coprime semiprimes in the
same class mod `L`.  The two semiprimes are indistinguishable for every
modulus-`L` observable, yet share no factor. -/
theorem exists_two_coprime_semiprimes_same_class (L : ℕ) [NeZero L] :
    ∃ p₁ q₁ p₂ q₂ : ℕ, p₁.Prime ∧ q₁.Prime ∧ p₂.Prime ∧ q₂.Prime ∧
      Nat.Coprime (p₁ * q₁) L ∧ Nat.Coprime (p₂ * q₂) L ∧
      Nat.Coprime (p₁ * q₁) (p₂ * q₂) ∧
      p₁ * q₁ ≡ p₂ * q₂ [MOD L] := by
  have hL : L ≠ 0 := NeZero.ne L
  have hS := unpinnedPrimes_infinite L hL
  -- pick `p₁`
  obtain ⟨p₁, ⟨hp₁, hp₁L⟩, -⟩ := hS.exists_gt 0
  have hcop₁ : Nat.Coprime p₁ L := (Nat.Prime.coprime_iff_not_dvd hp₁).2 hp₁L
  -- pick `q₁ > p₁`
  obtain ⟨q₁, ⟨hq₁, hq₁L⟩, hq₁gt⟩ := hS.exists_gt p₁
  have hcopq₁ : Nat.Coprime q₁ L := (Nat.Prime.coprime_iff_not_dvd hq₁).2 hq₁L
  -- pick `p₂ > q₁`
  obtain ⟨p₂, ⟨hp₂, hp₂L⟩, hp₂gt⟩ := hS.exists_gt q₁
  have hcop₂ : Nat.Coprime p₂ L := (Nat.Prime.coprime_iff_not_dvd hp₂).2 hp₂L
  have hN₀ : Nat.Coprime (p₁ * q₁) L := Nat.Coprime.mul_left hcop₁ hcopq₁
  -- pick a compensating prime `q₂ > p₂`
  obtain ⟨q₂, ⟨hq₂, hcopq₂, hmod⟩, hq₂gt⟩ :=
    (infinite_compensating_primes L hN₀ hcop₂).exists_gt p₂
  refine ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, hN₀,
    Nat.Coprime.mul_left hcop₂ hcopq₂, ?_, hmod.symm⟩
  have hne : ∀ {a b : ℕ}, a.Prime → b.Prime → a ≠ b → Nat.Coprime a b :=
    fun ha hb hab => (Nat.coprime_primes ha hb).2 hab
  have h₁₂ : p₁ ≠ p₂ := by omega
  have h₁₃ : p₁ ≠ q₂ := by omega
  have h₂₂ : q₁ ≠ p₂ := by omega
  have h₂₃ : q₁ ≠ q₂ := by omega
  exact Nat.Coprime.mul_left (Nat.Coprime.mul_right (hne hp₁ hp₂ h₁₂) (hne hp₁ hq₂ h₁₃))
    (Nat.Coprime.mul_right (hne hq₁ hp₂ h₂₂) (hne hq₁ hq₂ h₂₃))

/-- **No factoring from congruence data.**  Fix any modulus `L` with `2 ∣ L`,
any observable `f` of modulus `L` (all residues, Jacobi symbols and gcds of the
poly(log N) battery are of this form) and any decoding map `A` from readouts to
naturals.  Then `A ∘ f` cannot return a nontrivial divisor of every semiprime
coprime to `L`: some semiprime `p·q` has `A (f (p*q))` either failing to divide
`p*q`, or equal to `1` or less.

This is the unconditional "poly-computable ⇒ no-pinning ⇒ cannot factor" half of
the barrier programme, and it holds for arbitrarily large moduli `L`. -/
theorem no_congruence_factoring (L : ℕ) [NeZero L] (h2 : 2 ∣ L)
    {β : Type} (f : ℕ → β) (hf : IsModObs L f) (A : β → ℕ) :
    ¬ (∀ p q : ℕ, p.Prime → q.Prime → Nat.Coprime (p * q) L →
        A (f (p * q)) ∣ p * q ∧ 1 < A (f (p * q))) := by
  intro hA
  obtain ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, hc₁, hc₂, hcop, hmod⟩ :=
    exists_two_coprime_semiprimes_same_class L
  have hodd₁ : Odd (p₁ * q₁) := odd_of_coprime_of_two_dvd h2 hc₁
  have hodd₂ : Odd (p₂ * q₂) := odd_of_coprime_of_two_dvd h2 hc₂
  have hsame : f (p₁ * q₁) = f (p₂ * q₂) := hf hodd₁ hodd₂ hmod
  obtain ⟨hdvd₁, hgt₁⟩ := hA p₁ q₁ hp₁ hq₁ hc₁
  obtain ⟨hdvd₂, -⟩ := hA p₂ q₂ hp₂ hq₂ hc₂
  rw [hsame] at hdvd₁ hgt₁
  have : A (f (p₂ * q₂)) ∣ Nat.gcd (p₁ * q₁) (p₂ * q₂) := Nat.dvd_gcd hdvd₁ hdvd₂
  rw [hcop] at this
  have := Nat.dvd_one.mp this
  omega

/-- The maximal congruence battery: even the full residue `N mod L` — from which
every modulus-`L` observable is computable — yields no factoring rule. -/
theorem no_residue_factoring (L : ℕ) [NeZero L] (h2 : 2 ∣ L) (A : ℕ → ℕ) :
    ¬ (∀ p q : ℕ, p.Prime → q.Prime → Nat.Coprime (p * q) L →
        A ((p * q) % L) ∣ p * q ∧ 1 < A ((p * q) % L)) :=
  no_congruence_factoring L h2 (fun N => N % L) (isModObs_residue_self L) A

/-- Battery form: no decoding of a finite battery of modulus-`L` observables
factors semiprimes. -/
theorem no_battery_factoring (L : ℕ) [NeZero L] (h2 : 2 ∣ L)
    (Bat : List (ℕ → ℤ)) (hBat : ∀ g ∈ Bat, IsModObs L g) (A : List ℤ → ℕ) :
    ¬ (∀ p q : ℕ, p.Prime → q.Prime → Nat.Coprime (p * q) L →
        A (batteryValue Bat (p * q)) ∣ p * q ∧ 1 < A (batteryValue Bat (p * q))) := by
  refine no_congruence_factoring L h2 (batteryValue Bat) ?_ A
  intro m n hm hn hmn
  exact List.map_congr_left fun g hg => hBat g hg hm hn hmn

end Novelty.NoPinning