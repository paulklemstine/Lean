import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry

/-!
# The cycle count is an average of Pollard gcds

The stratification law (`Physics.PermutationReadoutCore`) computes the cycle
structure of `x ↦ a·x` on `ZMod N` from the individual orders `ord_{N/d}(a)`.
This file identifies *what information that structure actually carries*, by an
orbit-counting (Burnside-type) argument:

  `ord_N(a) · #cycles(σ_a) = ∑_{k < ord_N(a)} gcd(N, a^k − 1)`.

Each summand `gcd(N, a^k − 1)` is precisely the quantity computed by one step of
Pollard's `p − 1` method.  So the cycle count of the permutation readout is
nothing but the *average of the classical `p − 1` probes* over one period of
`a`; the `k = 0` term contributes the trivial value `N`.  In particular the
readout beats the trivial count `N / ord_N(a) + …` exactly when some probe
`gcd(N, a^k − 1)` is already nontrivial — that is, exactly when the classical
method has already succeeded (`cycleCount_minimal_iff_no_pollard_hit`).

## Main results

* `Physics.PermReadout.card_fixedPoints_eq_gcd` — the permutation `x ↦ a^k·x`
  of `ZMod N` has exactly `gcd(N, a^k − 1)` fixed points.
* `Physics.PermReadout.orderOf_mul_cycleCount_eq_sum_gcd` — the Burnside-type
  identity above.
* `Physics.PermReadout.cycleCount_minimal_iff_no_pollard_hit` — the cycle count
  attains its minimum `N + (L − 1)` (after scaling by `L`) iff every Pollard
  probe `gcd(N, a^k − 1)`, `1 ≤ k < L`, is trivial.
-/

namespace Physics.PermReadout

open Finset

/-! ## Two counting lemmas -/

/-- The multiples of `d` below `L` number `L / d`. -/
theorem card_filter_dvd_range {L d : ℕ} (hd : 0 < d) (hdvd : d ∣ L) :
    ((Finset.range L).filter (fun k => d ∣ k)).card = L / d := by
  have hset : (Finset.range L).filter (fun k => d ∣ k)
      = (Finset.range (L / d)).image (fun j => d * j) := by
    ext k
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_image]
    constructor
    · rintro ⟨hk, c, rfl⟩
      refine ⟨c, ?_, rfl⟩
      have := Nat.div_lt_div_of_lt_of_dvd hdvd hk
      rwa [Nat.mul_div_cancel_left _ hd] at this
    · rintro ⟨j, hj, rfl⟩
      refine ⟨?_, ⟨j, rfl⟩⟩
      calc d * j < d * (L / d) := (Nat.mul_lt_mul_left hd).mpr hj
        _ = L := Nat.mul_div_cancel' hdvd
  rw [hset, Finset.card_image_of_injective _ (fun x y h => Nat.eq_of_mul_eq_mul_left hd h),
    Finset.card_range]

/-- The elements of `ZMod N` whose representative is divisible by `d` number `N / d`. -/
theorem card_filter_dvd_val {N : ℕ} [NeZero N] {d : ℕ} (hd : 0 < d) (hdvd : d ∣ N) :
    (Finset.univ.filter (fun x : ZMod N => d ∣ x.val)).card = N / d := by
  rw [← card_filter_dvd_range hd hdvd]
  refine Finset.card_bij (fun x _ => x.val) ?_ ?_ ?_
  · intro x hx
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
    exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (ZMod.val_lt x), hx⟩
  · intro x _ y _ h
    exact ZMod.val_injective N h
  · intro b hb
    rw [Finset.mem_filter, Finset.mem_range] at hb
    refine ⟨(b : ZMod N), ?_, ZMod.val_natCast_of_lt hb.1⟩
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, ZMod.val_natCast_of_lt hb.1]
    exact hb.2

/-! ## Fixed points are Pollard gcds -/

/-- **The fixed-point count of `x ↦ a^k·x` is the Pollard gcd.**  The permutation
`a^k` fixes exactly `gcd(N, a^k − 1)` points of `ZMod N`. -/
theorem card_fixedPoints_eq_gcd {N a : ℕ} [NeZero N] (ha : 0 < a) (k : ℕ) :
    (Finset.univ.filter (fun x : ZMod N => (a : ZMod N) ^ k * x = x)).card
      = Nat.gcd N (a ^ k - 1) := by
  have hN : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
  set g := Nat.gcd N (a ^ k - 1) with hg
  have hgN : g ∣ N := Nat.gcd_dvd_left _ _
  have hg0 : 0 < g := Nat.gcd_pos_of_pos_left _ hN
  have hm0 : 0 < N / g := Nat.div_pos (Nat.le_of_dvd hN hgN) hg0
  have hmN : (N / g) ∣ N := Nat.div_dvd_of_dvd hgN
  have hcond : ∀ x : ZMod N, ((a : ZMod N) ^ k * x = x ↔ (N / g) ∣ x.val) := by
    intro x
    have h1 : 1 ≤ a ^ k := Nat.one_le_pow _ _ ha
    have hxle : x.val ≤ a ^ k * x.val := Nat.le_mul_of_pos_left _ (by omega)
    rw [pow_mul_eq_self_iff_modEq, Nat.ModEq.comm, Nat.modEq_iff_dvd' hxle, ← Nat.sub_one_mul,
      mul_comm, dvd_mul_gcd_iff hN]
  have : (Finset.univ.filter (fun x : ZMod N => (a : ZMod N) ^ k * x = x))
      = Finset.univ.filter (fun x : ZMod N => (N / g) ∣ x.val) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact hcond x
  rw [this, card_filter_dvd_val hm0 hmN, Nat.div_div_self hgN hN.ne']

/-! ## The Burnside-type identity -/

section Burnside

variable {N a : ℕ} [NeZero N]

/-- The fibre of the orbit map over a cycle is that cycle. -/
theorem univ_fiber_eq_orb (hcop : Nat.Coprime a N) (x : ZMod N) :
    Finset.univ.filter (fun y : ZMod N => orb N a y = orb N a x) = orb N a x := by
  ext z
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro hz
    rw [← hz]
    exact self_mem_orb hcop z
  · intro hz
    exact orb_eq_of_mem hcop hz

/-- Summing a function that is constant on cycles: `∑_x L/period(x) = L·#cycles`. -/
theorem sum_div_period (hcop : Nat.Coprime a N) :
    ∑ x : ZMod N, orderOf ((a : ZMod N)) / period N a x.val
      = orderOf ((a : ZMod N)) * cycleCount N a := by
  classical
  set L := orderOf ((a : ZMod N)) with hL
  have hmaps : ∀ x ∈ (Finset.univ : Finset (ZMod N)), orb N a x ∈
      Finset.univ.image (fun y : ZMod N => orb N a y) := by
    intro x _
    exact Finset.mem_image_of_mem _ (Finset.mem_univ x)
  rw [← Finset.sum_fiberwise_of_maps_to hmaps (fun x => L / period N a x.val)]
  rw [Finset.sum_congr rfl (g := fun _ => L) ?_, Finset.sum_const, smul_eq_mul,
    cycleCount, mul_comm]
  intro o ho
  obtain ⟨x, -, rfl⟩ := Finset.mem_image.mp ho
  have hfib := univ_fiber_eq_orb hcop x
  rw [hfib]
  have hconst : ∀ y ∈ orb N a x, L / period N a y.val = L / period N a x.val := by
    intro y hy
    rw [period_eq_of_strat_eq (strat_of_mem_orb hcop hy)]
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, smul_eq_mul, card_orb hcop,
    Nat.mul_div_cancel' (period_dvd_orderOf x.val)]

/-- **Orbit counting: the cycle count is the average Pollard gcd.**
`ord_N(a) · #cycles = ∑_{k < ord_N(a)} gcd(N, a^k − 1)`. -/
theorem orderOf_mul_cycleCount_eq_sum_gcd (ha : 0 < a) (hcop : Nat.Coprime a N) :
    orderOf ((a : ZMod N)) * cycleCount N a
      = ∑ k ∈ Finset.range (orderOf ((a : ZMod N))), Nat.gcd N (a ^ k - 1) := by
  classical
  set L := orderOf ((a : ZMod N)) with hL
  have hL0 : 0 < L := by
    obtain ⟨u, hu⟩ := (ZMod.isUnit_iff_coprime a N).mpr hcop
    rw [hL, ← hu, orderOf_units]
    exact (isOfFinOrder_of_finite u).orderOf_pos
  have hstep : ∀ k, Nat.gcd N (a ^ k - 1)
      = ∑ x : ZMod N, (if (a : ZMod N) ^ k * x = x then 1 else 0) := by
    intro k
    rw [← card_fixedPoints_eq_gcd ha k, Finset.card_filter]
  rw [Finset.sum_congr rfl (fun k _ => hstep k), Finset.sum_comm]
  rw [← sum_div_period hcop]
  refine Finset.sum_congr rfl (fun x _ => ?_)
  have hper : period N a x.val ∣ L := period_dvd_orderOf x.val
  have hper0 : 0 < period N a x.val :=
    period_pos (Nat.pos_of_ne_zero (NeZero.ne N)) hcop x.val
  rw [← card_filter_dvd_range hper0 hper, Finset.card_filter]
  refine Finset.sum_congr rfl (fun k _ => ?_)
  by_cases h : period N a x.val ∣ k
  · rw [if_pos ((pow_mul_eq_self_iff hcop x k).mpr h), if_pos h]
  · rw [if_neg (fun hh => h ((pow_mul_eq_self_iff hcop x k).mp hh)), if_neg h]

/-- **The readout is exactly as strong as the classical `p−1` probes.**  The
Burnside identity attains its minimal value `N + (L − 1)` — i.e. the permutation
has no more cycles than the trivial stratification forces — precisely when every
Pollard probe `gcd(N, a^k − 1)` with `1 ≤ k < ord_N(a)` is trivial. -/
theorem cycleCount_minimal_iff_no_pollard_hit (ha : 0 < a) (hcop : Nat.Coprime a N) :
    orderOf ((a : ZMod N)) * cycleCount N a = N + (orderOf ((a : ZMod N)) - 1)
      ↔ ∀ k ∈ Finset.Ico 1 (orderOf ((a : ZMod N))), Nat.gcd N (a ^ k - 1) = 1 := by
  classical
  set L := orderOf ((a : ZMod N)) with hL
  have hL0 : 0 < L := by
    obtain ⟨u, hu⟩ := (ZMod.isUnit_iff_coprime a N).mpr hcop
    rw [hL, ← hu, orderOf_units]
    exact (isOfFinOrder_of_finite u).orderOf_pos
  have hsplit : ∑ k ∈ Finset.range L, Nat.gcd N (a ^ k - 1)
      = N + ∑ k ∈ Finset.Ico 1 L, Nat.gcd N (a ^ k - 1) := by
    rw [Finset.range_eq_Ico, ← Finset.sum_Ico_consecutive _ (Nat.zero_le 1) hL0]
    simp
  have hone : ∀ k ∈ Finset.Ico 1 L, 1 ≤ Nat.gcd N (a ^ k - 1) :=
    fun k _ => Nat.gcd_pos_of_pos_left _ (Nat.pos_of_ne_zero (NeZero.ne N))
  rw [orderOf_mul_cycleCount_eq_sum_gcd ha hcop, hsplit]
  constructor
  · intro h
    have hcard : (Finset.Ico 1 L).card = L - 1 := by simp
    have hsum : ∑ k ∈ Finset.Ico 1 L, Nat.gcd N (a ^ k - 1) = (Finset.Ico 1 L).card := by
      rw [hcard]
      omega
    intro k hk
    by_contra hne
    have hlt : ∑ k ∈ Finset.Ico 1 L, 1 < ∑ k ∈ Finset.Ico 1 L, Nat.gcd N (a ^ k - 1) :=
      Finset.sum_lt_sum hone ⟨k, hk, lt_of_le_of_ne (hone k hk) (Ne.symm hne)⟩
    simp only [Finset.sum_const, smul_eq_mul, mul_one] at hlt
    omega
  · intro h
    rw [Finset.sum_congr rfl h, Finset.sum_const, smul_eq_mul, mul_one, Nat.card_Ico]

end Burnside

end Physics.PermReadout