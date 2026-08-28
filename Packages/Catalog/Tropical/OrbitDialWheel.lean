import Mathlib
import Tropical.OrbitDialCapLaw

/-!
# Wheel dials: structural exclusions are sound, blind, and *unbounded*

Cycle 2 of the ORBIT-DIAL-CAP-TEST.  The parity skip of
`Tropical.OrbitDialInvariants` is the `M = 2` member of a whole family of
*structural* dials: fix a squarefree modulus `M` coprime to the target `N` (a condition
checkable blind, by a single gcd) and keep only the candidate divisors coprime to `M`.

Such a wheel dial

* is **sound**: every divisor of `N` is coprime to `M` (`wheel_dial_sound`), so `s = 1`;
* has retention `φ(M)/M` (`wheel_retention_count`), hence idealised speedup `M/φ(M)`
  (`wheel_speedup_eq`);
* carries **no per-`N` information**: its kept set is the same table for every `N`
  in the coprimality class (`wheelKept_const`).

The main result is that this family is *unbounded*:

`wheel_speedup_unbounded : ∀ B, ∃ M, Squarefree M ∧ B < wheelSpeedup M`

proved from the divergence of `∑ 1/p` over primes through the Weierstrass bound
`∏ (1 + xᵢ) ≥ 1 + ∑ xᵢ`.  So the `4/3` cap of `Tropical.OrbitDialCapLaw` is *not* a
bound on speedups per se: it is a bound on *information-bearing* dials only.  Structural
exclusions carry zero bits and are worth arbitrarily large constants — which is exactly
why the ORBIT arm's `2.0000` read is not a barrier event.

(The accounting here is the idealised one: it charges nothing for applying the wheel.
The experiment's NET-loaded arms, all `< 1`, are the reminder that the overhead of a
large wheel eventually eats the constant.)
-/

namespace OrbitDialCap
namespace Wheel

open Finset

/-- The idealised speedup of the wheel dial of modulus `M`: the reciprocal of the
retained fraction `φ(M)/M`. -/
noncomputable def wheelSpeedup (M : ℕ) : ℝ := (M : ℝ) / (Nat.totient M : ℝ)

/-- **Soundness.**  If the target `N` is coprime to the wheel modulus `M`, then no
divisor of `N` is ever excluded: the dial has soundness `s = 1`. -/
theorem wheel_dial_sound {N M p : ℕ} (hNM : Nat.Coprime N M) (hp : p ∣ N) :
    Nat.Coprime p M :=
  Nat.Coprime.coprime_dvd_left hp hNM

/-- **Retention.**  Exactly `φ(M)` of the `M` residues mod `M` are kept, so the retained
fraction is `φ(M)/M`. -/
theorem wheel_retention_count (M : ℕ) :
    ((Finset.range M).filter (fun a => Nat.Coprime M a)).card = Nat.totient M := rfl

/-- The wheel dial's kept set does not depend on the target: one universal table. -/
def wheelKept (M : ℕ) : ℕ → Set ℕ := fun _ => {p | Nat.Coprime p M}

theorem wheelKept_const (M N N' : ℕ) : wheelKept M N = wheelKept M N' := rfl

/-- The wheel dial is a sound, deterministic dial, so the general cost model of
`OrbitDialCap.dialCost` gives it speedup `M / φ(M)`. -/
theorem wheel_speedup_eq (M : ℕ) :
    OrbitDialCap.dialSpeedup 1 ((Nat.totient M : ℝ) / (M : ℝ)) = wheelSpeedup M := by
  rw [OrbitDialCap.deterministic_speedup, wheelSpeedup, inv_div]

/-- Wheel modulus attached to a finite set of primes. -/
def wheelModulus (s : Finset ℕ) : ℕ := ∏ p ∈ s, p

/-- The totient of a squarefree wheel modulus factors as `∏ (p - 1)`. -/
theorem totient_wheelModulus {s : Finset ℕ} (hs : ∀ p ∈ s, p.Prime) :
    Nat.totient (wheelModulus s) = ∏ p ∈ s, (p - 1) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [wheelModulus]
  | insert a s ha ih =>
      have hap : a.Prime := hs a (Finset.mem_insert_self a s)
      have hrest : ∀ p ∈ s, p.Prime := fun p hp => hs p (Finset.mem_insert_of_mem hp)
      have hcop : Nat.Coprime a (wheelModulus s) := by
        refine Nat.Coprime.prod_right ?_
        intro q hq
        have hqp : q.Prime := hrest q hq
        have hne : a ≠ q := by rintro rfl; exact ha hq
        exact (Nat.coprime_primes hap hqp).mpr hne
      rw [wheelModulus, Finset.prod_insert ha, ← wheelModulus,
        Nat.totient_mul hcop, Nat.totient_prime hap, ih hrest,
        Finset.prod_insert ha]

/-- The wheel modulus of a set of primes is positive. -/
theorem wheelModulus_pos {s : Finset ℕ} (hs : ∀ p ∈ s, p.Prime) : 0 < wheelModulus s :=
  Finset.prod_pos fun p hp => (hs p hp).pos

/-- Weierstrass product bound: `∏ (1 + xᵢ) ≥ 1 + ∑ xᵢ` for nonnegative `xᵢ`. -/
theorem one_add_sum_le_prod_one_add {ι : Type*} (s : Finset ι) (f : ι → ℝ)
    (hf : ∀ i ∈ s, 0 ≤ f i) : 1 + ∑ i ∈ s, f i ≤ ∏ i ∈ s, (1 + f i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | insert a s ha ih =>
      have hfa : 0 ≤ f a := hf a (Finset.mem_insert_self a s)
      have hrest : ∀ i ∈ s, 0 ≤ f i := fun i hi => hf i (Finset.mem_insert_of_mem hi)
      have hsum : 0 ≤ ∑ i ∈ s, f i := Finset.sum_nonneg hrest
      have hstep := ih hrest
      rw [Finset.prod_insert ha, Finset.sum_insert ha]
      nlinarith [hstep, hfa, hsum]

/-- For a prime `p`, `p / (p - 1) ≥ 1 + 1/p`. -/
theorem prime_ratio_ge {p : ℕ} (hp : p.Prime) :
    1 + 1 / (p : ℝ) ≤ (p : ℝ) / ((p : ℝ) - 1) := by
  have hp2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp.two_le
  have hp0 : (0 : ℝ) < p := by linarith
  have hp1 : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  rw [le_div_iff₀ hp1]
  have hkey : (1 + 1 / (p : ℝ)) * ((p : ℝ) - 1) = (p : ℝ) - 1 / (p : ℝ) := by
    field_simp
    ring
  rw [hkey]
  have : 0 < 1 / (p : ℝ) := by positivity
  linarith

/-- The wheel speedup of a squarefree modulus is the Euler product `∏ p/(p-1)`. -/
theorem wheelSpeedup_prod {s : Finset ℕ} (hs : ∀ p ∈ s, p.Prime) :
    wheelSpeedup (wheelModulus s) = ∏ p ∈ s, ((p : ℝ) / ((p : ℝ) - 1)) := by
  have hpos : 0 < wheelModulus s := wheelModulus_pos hs
  have hnum : ((wheelModulus s : ℕ) : ℝ) = ∏ p ∈ s, (p : ℝ) := by
    rw [wheelModulus]; push_cast; ring
  have hden : ((Nat.totient (wheelModulus s) : ℕ) : ℝ) = ∏ p ∈ s, ((p : ℝ) - 1) := by
    rw [totient_wheelModulus hs]
    push_cast [Nat.cast_prod]
    refine Finset.prod_congr rfl fun p hp => ?_
    have h1 : 1 ≤ p := (hs p hp).one_lt.le.trans' (by norm_num)
    push_cast [Nat.cast_sub h1]
    ring
  rw [wheelSpeedup, hnum, hden, ← Finset.prod_div_distrib]

/-- **Structural dials are unbounded.**  For every bound `B` there is a squarefree wheel
modulus whose (idealised, information-free) speedup exceeds `B`.  The `4/3` cap
therefore constrains information-bearing dials only. -/
theorem wheel_speedup_unbounded (B : ℝ) :
    ∃ s : Finset ℕ, (∀ p ∈ s, p.Prime) ∧ B < wheelSpeedup (wheelModulus s) := by
  classical
  -- pick a finite set of primes whose reciprocals sum past `B`
  have hns : ¬ Summable (fun p : Nat.Primes => (1 / p : ℝ)) := Nat.Primes.not_summable_one_div
  have hex : ∃ u : Finset Nat.Primes, ¬ (∑ p ∈ u, (1 / (p : ℕ) : ℝ)) ≤ B := by
    by_contra hcon
    push_neg at hcon
    exact hns (summable_of_sum_le (c := B) (fun p => by positivity) fun u => hcon u)
  obtain ⟨u, hu⟩ := hex
  push_neg at hu
  refine ⟨u.image (fun p : Nat.Primes => (p : ℕ)), ?_, ?_⟩
  · intro p hp
    obtain ⟨q, _, rfl⟩ := Finset.mem_image.mp hp
    exact q.2
  · have hinj : Set.InjOn (fun p : Nat.Primes => (p : ℕ)) u := by
      intro a _ b _ hab
      exact Subtype.ext hab
    have hs : ∀ p ∈ u.image (fun p : Nat.Primes => (p : ℕ)), p.Prime := by
      intro p hp
      obtain ⟨q, _, rfl⟩ := Finset.mem_image.mp hp
      exact q.2
    rw [wheelSpeedup_prod hs]
    have hstep : 1 + ∑ p ∈ u.image (fun p : Nat.Primes => (p : ℕ)), (1 / (p : ℝ))
        ≤ ∏ p ∈ u.image (fun p : Nat.Primes => (p : ℕ)), ((p : ℝ) / ((p : ℝ) - 1)) := by
      refine le_trans (one_add_sum_le_prod_one_add _ _ (fun p _ => by positivity)) ?_
      refine Finset.prod_le_prod (fun p hp => by positivity) (fun p hp => prime_ratio_ge (hs p hp))
    have hsum : ∑ p ∈ u.image (fun p : Nat.Primes => (p : ℕ)), (1 / (p : ℝ))
        = ∑ p ∈ u, (1 / ((p : ℕ) : ℝ)) := Finset.sum_image (fun a ha b hb h => hinj ha hb h)
    rw [hsum] at hstep
    linarith [hu, hstep]

/-- Concrete wheels: the parity skip `M = 2` reads `2`, the `{2,3}` wheel reads `3`, and
the `{2,3,5}` wheel reads `15/4` — all with zero bits of per-`N` information. -/
theorem wheel_small_values :
    wheelSpeedup 2 = 2 ∧ wheelSpeedup 6 = 3 ∧ wheelSpeedup 30 = 15 / 4 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    · rw [wheelSpeedup]
      norm_num [show Nat.totient 2 = 1 from rfl, show Nat.totient 6 = 2 from rfl,
        show Nat.totient 30 = 8 from rfl]

/-- All three concrete wheels already exceed the exchangeable cap. -/
theorem wheels_beat_cap :
    4 / 3 < wheelSpeedup 2 ∧ 4 / 3 < wheelSpeedup 6 ∧ 4 / 3 < wheelSpeedup 30 := by
  obtain ⟨h2, h6, h30⟩ := wheel_small_values
  refine ⟨by rw [h2]; norm_num, by rw [h6]; norm_num, by rw [h30]; norm_num⟩

end Wheel
end OrbitDialCap