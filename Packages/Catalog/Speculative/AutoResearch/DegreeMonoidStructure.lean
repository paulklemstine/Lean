/-
# Structure theory of degree monoids: period, gaps and the Frobenius obstruction

`Computation.DegreeMonoidRealisation` shows that the degree monoid
`degreeMonoid R a ≤ ℕ` of a state of a transition system is a complete invariant for the
lattice of additive submonoids of `ℕ`: *every* submonoid is realised by the chain machine
`chainRel M`.  Completeness of a realisation problem is only half the story — the other
half is the *structure* of the realised objects.  This file supplies it:

* `degPeriod R a` — the period of a state, the gcd of all its closed-computation lengths;
* `degPeriod_dvd_mem` and `exists_ge_mem_degreeMonoid` — the **structure theorem**: every
  closed computation has length divisible by the period, and conversely *every*
  sufficiently large multiple of the period is a closed-computation length.  So the degree
  monoid is an eventually complete arithmetic progression;
* `degreeMonoid_gaps_finite` — a state has only finitely many *gaps* (multiples of the
  period which are not computation lengths);
* `degPeriod_eq_zero_iff` — the sharp dichotomy: period `0` exactly for the dead state
  (`degreeMonoid = ⊥`);
* `degPeriod_prodRel` — the **synchronisation law**: the period of a synchronous product of
  two live machines is the *least common multiple* of the two periods;
* `frobenius_gap_of_chainRel` — a number-theoretic bridge: for coprime `p, q > 1` the chain
  machine of `⟨p, q⟩` has largest gap exactly `p*q - p - q` (Chicken McNugget/Frobenius),
  and `frobenius_gap_two_three` specialises this to the certified sample value `⟨2,3⟩`,
  whose unique gap is the length `1`.

All results are proved with no `sorry`.
-/
import Mathlib
import Computation.DegreeMonoidRealisation

namespace Computation
namespace DegreeMonoid

variable {α β : Type*}

/-! ## The period of a state -/

/-- The **period** of a state: the gcd of the lengths of all its closed computations
(`0` exactly when the only closed computation is the empty one). -/
noncomputable def degPeriod (R : α → α → Prop) (a : α) : ℕ :=
  Nat.setGcd (degreeMonoid R a : Set ℕ)

/-- Every closed computation length is a multiple of the period. -/
theorem degPeriod_dvd_mem {R : α → α → Prop} {a : α} {n : ℕ} (hn : n ∈ degreeMonoid R a) :
    degPeriod R a ∣ n :=
  Nat.setGcd_dvd_of_mem (by exact hn)

/-- **Structure theorem.**  All sufficiently large multiples of the period are lengths of
closed computations. -/
theorem exists_ge_mem_degreeMonoid (R : α → α → Prop) (a : α) :
    ∃ N : ℕ, ∀ m ≥ N, degPeriod R a ∣ m → m ∈ degreeMonoid R a := by
  obtain ⟨N, hN⟩ := Nat.exists_mem_closure_of_ge (degreeMonoid R a : Set ℕ)
  refine ⟨N, fun m hm hdvd => ?_⟩
  have := hN m hm hdvd
  rwa [AddSubmonoid.closure_eq] at this

/-- The period vanishes exactly for a state with no nonempty closed computation. -/
theorem degPeriod_eq_zero_iff (R : α → α → Prop) (a : α) :
    degPeriod R a = 0 ↔ degreeMonoid R a = ⊥ := by
  rw [degPeriod, Nat.setGcd_eq_zero_iff]
  constructor
  · intro h
    ext n
    constructor
    · intro hn
      have : n ∈ ({0} : Set ℕ) := h hn
      simpa using this
    · intro hn
      have : n = 0 := by simpa using hn
      exact this ▸ zero_mem _
  · intro h n hn
    rw [h] at hn
    simpa using hn

/-- A live state (one with a nonempty closed computation) has positive period. -/
theorem degPeriod_pos {R : α → α → Prop} {a : α} {n : ℕ} (hn : n ∈ degreeMonoid R a)
    (hn0 : n ≠ 0) : 0 < degPeriod R a := by
  rcases Nat.eq_zero_or_pos (degPeriod R a) with h | h
  · rw [degPeriod_eq_zero_iff] at h
    rw [h] at hn
    exact absurd (by simpa using hn) hn0
  · exact h

/-- **Finiteness of the gap set.**  Only finitely many multiples of the period fail to be
closed-computation lengths. -/
theorem degreeMonoid_gaps_finite (R : α → α → Prop) (a : α) :
    {n : ℕ | degPeriod R a ∣ n ∧ n ∉ degreeMonoid R a}.Finite := by
  obtain ⟨N, hN⟩ := exists_ge_mem_degreeMonoid R a
  refine (Set.finite_Iio N).subset ?_
  intro n hn
  simp only [Set.mem_setOf_eq] at hn
  by_contra hlt
  exact hn.2 (hN n (le_of_not_gt (by simpa using hlt)) hn.1)

/-- **Classification of degree monoids.**  Either a state is dead (only the empty closed
computation) or it has a positive period `d`, all its computation lengths are multiples of
`d`, and all sufficiently large multiples of `d` occur. -/
theorem degreeMonoid_classification (R : α → α → Prop) (a : α) :
    degreeMonoid R a = ⊥ ∨
      (0 < degPeriod R a ∧ (∀ n ∈ degreeMonoid R a, degPeriod R a ∣ n) ∧
        ∃ N : ℕ, ∀ m ≥ N, degPeriod R a ∣ m → m ∈ degreeMonoid R a) := by
  rcases Nat.eq_zero_or_pos (degPeriod R a) with h | h
  · exact Or.inl ((degPeriod_eq_zero_iff R a).1 h)
  · exact Or.inr ⟨h, fun _ hn => degPeriod_dvd_mem hn, exists_ge_mem_degreeMonoid R a⟩

/-! ## Synchronisation: periods multiply to their lcm under products -/

/-- **Synchronisation law.**  Running two live machines in lockstep produces a machine
whose period is the least common multiple of the two periods. -/
theorem degPeriod_prodRel {R : α → α → Prop} {S : β → β → Prop} {a : α} {b : β}
    (ha : ∃ n ∈ degreeMonoid R a, n ≠ 0) (hb : ∃ n ∈ degreeMonoid S b, n ≠ 0) :
    degPeriod (prodRel R S) (a, b) = Nat.lcm (degPeriod R a) (degPeriod S b) := by
  obtain ⟨n1, hn1, hn1'⟩ := ha
  obtain ⟨n2, hn2, hn2'⟩ := hb
  have hp1 : 0 < degPeriod R a := degPeriod_pos hn1 hn1'
  have hp2 : 0 < degPeriod S b := degPeriod_pos hn2 hn2'
  set d1 := degPeriod R a
  set d2 := degPeriod S b
  set L := Nat.lcm d1 d2 with hL
  have hLpos : 0 < L := Nat.pos_of_ne_zero (by
    simp only [hL, Ne, Nat.lcm_eq_zero_iff]
    omega)
  have hmem : ∀ n : ℕ, n ∈ degreeMonoid (prodRel R S) (a, b) ↔
      n ∈ degreeMonoid R a ∧ n ∈ degreeMonoid S b := by
    intro n
    rw [degreeMonoid_prodRel]
    simp
  -- The lcm divides every element of the product's degree monoid.
  have hdvd1 : L ∣ degPeriod (prodRel R S) (a, b) := by
    rw [degPeriod, Nat.dvd_setGcd_iff]
    intro m hm
    have hm' := (hmem m).1 (by exact hm)
    exact Nat.lcm_dvd (degPeriod_dvd_mem hm'.1) (degPeriod_dvd_mem hm'.2)
  -- Conversely, two consecutive large multiples of the lcm are both realised.
  obtain ⟨N1, hN1⟩ := exists_ge_mem_degreeMonoid R a
  obtain ⟨N2, hN2⟩ := exists_ge_mem_degreeMonoid S b
  set K := max N1 N2 + 1 with hK
  have hbig : ∀ k : ℕ, K ≤ k → L * k ∈ degreeMonoid (prodRel R S) (a, b) := by
    intro k hk
    have hge : max N1 N2 ≤ L * k := by
      calc max N1 N2 ≤ k := by omega
        _ ≤ L * k := Nat.le_mul_of_pos_left k hLpos
    refine (hmem (L * k)).2 ⟨hN1 _ (le_trans (le_max_left _ _) hge) ?_,
      hN2 _ (le_trans (le_max_right _ _) hge) ?_⟩
    · exact Dvd.dvd.mul_right (Nat.dvd_lcm_left d1 d2) k
    · exact Dvd.dvd.mul_right (Nat.dvd_lcm_right d1 d2) k
  have h1 : degPeriod (prodRel R S) (a, b) ∣ L * K := degPeriod_dvd_mem (hbig K le_rfl)
  have h2 : degPeriod (prodRel R S) (a, b) ∣ L * (K + 1) :=
    degPeriod_dvd_mem (hbig (K + 1) (by omega))
  have hdvd2 : degPeriod (prodRel R S) (a, b) ∣ L := by
    have := Nat.dvd_sub h2 h1
    simpa [Nat.mul_succ] using this
  exact Nat.dvd_antisymm hdvd2 hdvd1

/-- **Chinese-remainder corollary.**  Two single-loop machines of lengths `m` and `n` run in
lockstep return to their common start exactly at the multiples of `lcm m n`. -/
theorem degreeMonoid_prod_cycles (m n k : ℕ) :
    k ∈ degreeMonoid (prodRel (chainRel ({m} : Set ℕ)) (chainRel ({n} : Set ℕ))) (0, 0) ↔
      Nat.lcm m n ∣ k := by
  rw [degreeMonoid_prodRel]
  simp only [AddSubmonoid.mem_inf, degreeMonoid_multiples]
  exact ⟨fun h => Nat.lcm_dvd h.1 h.2,
    fun h => ⟨dvd_trans (Nat.dvd_lcm_left m n) h, dvd_trans (Nat.dvd_lcm_right m n) h⟩⟩

/-! ## The Frobenius obstruction of a two-loop machine -/

/-- For coprime `p, q > 1`, the chain machine of the numerical semigroup `⟨p, q⟩` is a
concrete machine whose **largest gap** — the largest length that is not the length of any
closed computation — is exactly `p * q - p - q`. -/
theorem frobenius_gap_of_chainRel {p q : ℕ} (cop : Nat.Coprime p q) (hp : 1 < p) (hq : 1 < q) :
    IsGreatest {k : ℕ | k ∉ degreeMonoid (chainRel ({p, q} : Set ℕ)) 0}
      (p * q - p - q) := by
  have h := frobeniusNumber_pair cop hp hq
  have hEq : degreeMonoid (chainRel ({p, q} : Set ℕ)) 0
      = AddSubmonoid.closure ({p, q} : Set ℕ) := degreeMonoid_chainRel _
  simpa [FrobeniusNumber, hEq] using h

/-- The period of the two-loop machine of coprime `p, q` is `1`: it is *aperiodic*, and by
`frobenius_gap_of_chainRel` its finitely many gaps stop exactly at `p * q - p - q`.
(Coprimality alone suffices here; the bounds `1 < p`, `1 < q` are not needed.) -/
theorem degPeriod_chainRel_coprime {p q : ℕ} (cop : Nat.Coprime p q) :
    degPeriod (chainRel ({p, q} : Set ℕ)) 0 = 1 := by
  have hEq : degreeMonoid (chainRel ({p, q} : Set ℕ)) 0
      = AddSubmonoid.closure ({p, q} : Set ℕ) := degreeMonoid_chainRel _
  have hpmem : p ∈ degreeMonoid (chainRel ({p, q} : Set ℕ)) 0 := by
    rw [hEq]; exact AddSubmonoid.subset_closure (by simp)
  have hqmem : q ∈ degreeMonoid (chainRel ({p, q} : Set ℕ)) 0 := by
    rw [hEq]; exact AddSubmonoid.subset_closure (by simp)
  have h1 : degPeriod (chainRel ({p, q} : Set ℕ)) 0 ∣ p :=
    degPeriod_dvd_mem hpmem
  have h2 : degPeriod (chainRel ({p, q} : Set ℕ)) 0 ∣ q :=
    degPeriod_dvd_mem hqmem
  exact Nat.eq_one_of_dvd_coprimes cop h1 h2

/-- Specialisation to the certified sample value `⟨2,3⟩`: the unique gap of that machine is
the length `1`. -/
theorem frobenius_gap_two_three :
    IsGreatest {k : ℕ | k ∉ degreeMonoid (chainRel ({2, 3} : Set ℕ)) 0}
      1 := by
  have := frobenius_gap_of_chainRel (p := 2) (q := 3) (by decide) (by norm_num) (by norm_num)
  simpa using this

end DegreeMonoid
end Computation