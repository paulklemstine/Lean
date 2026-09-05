import Mathlib
import Shared.ECMStage1SmoothPart

/-!
# The ECM "self-destruction wall" is an accounting artifact, not a method failure

Paper 159 records a *self-destruction wall* for the elliptic-curve method (ECM):

> when `B1 ≳ min(p,q)`, every Hasse-window order divides `lcm(1..B1)`, all curves
> degenerate simultaneously, uncapped `E[T]` infinite,

with an alleged validity edge `B1 ≲ min(p,q)/2`.  Experiment 568 (600 trials, bit
length 26, grid `B1/p ∈ {0.125, 0.25, 0.5, 0.9, 1.05}` × arms `B2/B1 ∈ {1,4,16}`)
re-ran that boundary under **outcome-separated** accounting
`{found_p, found_q, dead, nothing}` and observed **zero** `dead` outcomes anywhere,
success `1.000` in every cell with `B1/p ≥ 0.25`, and in particular `6/6` cells at
`1.000` at `B1/p = 0.9` and `1.05` — exactly where the wall is recorded.

This file proves the mechanism behind that observation, building on the stage-1
order-completion theory of `Catalog.Shared.ECMStage1OrderCompletion` /
`…FiringRate` / `…SmoothPart` (`stage1Scalar`, `Powersmooth`, `firingSet`).

Main results.

* `fires_of_le` / `powersmooth_of_le`: an order that is *at most* the bound is
  automatically powersmooth, hence divides the stage-1 scalar.  Size alone suffices.
* `hasseWindow_le_hasseCeil`, `wall_forces_firing`: the Hasse window `n ≤ p+1+2√p`
  is contained in `[1, hasseCeil p]` with `hasseCeil p = p + 3 + 2⌊√p⌋` a purely
  arithmetic ceiling, so `B ≥ hasseCeil p` forces **every** Hasse-window order to
  divide `stage1Scalar B`.
* `every_point_fires_of_card_le`, `every_point_fires_at_wall`,
  `firingSet_eq_range`, `success_rate_eq_one_at_wall`: at the wall the firing set
  is the whole group and the stage-1 success rate is exactly `1`.
* `stage1Scalar_dvd_of_le`, `firing_count_mono`, `no_destruction_wall`: the firing
  count is **monotone** in `B`.  A wall — success collapsing above a threshold —
  is therefore impossible in the order-completion ledger, at any scale.
* `wall_yields_foundP`, `wall_not_dead`, `revealed_gcd_eq_p`: with the outcomes
  separated, universal degeneracy mod `p` together with a single prime factor of
  the mod-`q` order exceeding `B` gives `found_p`, and the revealed gcd is exactly
  the prime `p` — a *guaranteed success*, never `dead`.
* `dead_rate_eq_inv`: quantitatively, the mod-`q` firing (i.e. `dead`) rate is
  exactly `1/m` when every prime factor of the mod-`q` order exceeds `B`; with
  `m ≈ 2^26` and 600 trials the observed count `0` is what the theory predicts.
* `expectedCurves_at_wall`: the geometric expected number of curves at success
  rate `1` is `1`, not `∞`; the recorded "uncapped `E[T]` infinite" is false at
  exactly the place it was recorded.
* `collision_baseline_below_observed`: the folklore collision baseline
  `1 - exp(-1.44·B/p)` at `B/p = 1/8` is at most `0.18`, well below the observed
  `0.68` found-`p` share — the low-edge cells are not collision luck either.
-/

namespace ECMWall

open ECMStage1 Finset

/-! ## Size implies powersmoothness: the wall hypothesis is a firing hypothesis -/

/-- An order not exceeding the smoothness bound is automatically `B`-powersmooth:
every prime power exactly dividing it divides it, hence is at most `B`. -/
theorem powersmooth_of_le {B n : ℕ} (hn : n ≠ 0) (h : n ≤ B) : Powersmooth B n := by
  intro q hq
  have hdvd : q ^ n.factorization q ∣ n := Nat.ordProj_dvd n q
  exact le_trans (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hdvd) h

/-- **Size alone fires stage 1.**  If the order is at most the smoothness bound then
it divides the stage-1 scalar `k(B) = lcm-type product of prime powers ≤ B`. -/
theorem fires_of_le {B n : ℕ} (hn : n ≠ 0) (h : n ≤ B) : n ∣ stage1Scalar B := by
  have hB : B ≠ 0 := by omega
  exact (dvd_stage1Scalar_iff hn hB).mpr (powersmooth_of_le hn h)

/-! ## The Hasse window and its arithmetic ceiling -/

/-- A purely arithmetic upper ceiling for the Hasse window `p + 1 + 2√p`. -/
def hasseCeil (p : ℕ) : ℕ := p + 3 + 2 * Nat.sqrt p

/-- The real Hasse bound is dominated by `hasseCeil`. -/
theorem hasseWindow_le_hasseCeil {p n : ℕ}
    (h : (n : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p) : n ≤ hasseCeil p := by
  have hs : Real.sqrt p < (Nat.sqrt p : ℝ) + 1 := by
    have hp : (p : ℝ) < ((Nat.sqrt p : ℝ) + 1) ^ 2 := by
      exact_mod_cast Nat.lt_succ_sqrt' p
    have hpos : (0 : ℝ) < (Nat.sqrt p : ℝ) + 1 := by positivity
    exact (Real.sqrt_lt' hpos).mpr hp
  have hlt : (n : ℝ) < ((hasseCeil p : ℕ) : ℝ) := by
    have : (n : ℝ) < (p : ℝ) + 3 + 2 * (Nat.sqrt p : ℝ) := by nlinarith [hs]
    simpa [hasseCeil] using this
  exact_mod_cast le_of_lt (by exact_mod_cast hlt : (n : ℝ) < (hasseCeil p : ℝ))

/-- **The wall forces firing, not death.**  If the smoothness bound reaches the top
of the Hasse window, then *every* possible curve order over `𝔽_p` divides the
stage-1 scalar: `[k(B)]P = O mod p` on every curve. -/
theorem wall_forces_firing {p B n : ℕ} (hB : hasseCeil p ≤ B) (hn : n ≠ 0)
    (hHasse : (n : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p) : n ∣ stage1Scalar B :=
  fires_of_le hn (le_trans (hasseWindow_le_hasseCeil hHasse) hB)

/-! ## Group form: at the wall every point fires -/

variable {G : Type*} [Group G]

/-- Every element of a finite group of order at most `B` is killed by the stage-1
scalar. -/
theorem every_point_fires_of_card_le [Finite G] {B : ℕ} (h : Nat.card G ≤ B) (g : G) :
    g ^ stage1Scalar B = 1 := by
  have hcard : 0 < Nat.card G := Nat.card_pos
  have hord : orderOf g ∣ Nat.card G := orderOf_dvd_natCard g
  have hle : orderOf g ≤ Nat.card G := Nat.le_of_dvd hcard hord
  have hne : orderOf g ≠ 0 := by
    have : 0 < orderOf g := orderOf_pos_iff.mpr (isOfFinOrder_of_finite g)
    omega
  exact orderOf_dvd_iff_pow_eq_one.mp (fires_of_le hne (le_trans hle h))

/-- **Universal degeneracy at the wall is universal success.**  For a group of
points whose order lies in the Hasse window of `p` and a bound past the top of that
window, every point is killed by stage 1. -/
theorem every_point_fires_at_wall [Finite G] {p B : ℕ} (hB : hasseCeil p ≤ B)
    (hHasse : (Nat.card G : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p) (g : G) :
    g ^ stage1Scalar B = 1 :=
  every_point_fires_of_card_le (le_trans (hasseWindow_le_hasseCeil hHasse) hB) g

/-- In the cyclic model the firing set is the whole group at the wall. -/
theorem firingSet_eq_range {m B : ℕ} (hm : 0 < m) (h : m ≤ B) :
    firingSet m (stage1Scalar B) = Finset.range m := by
  ext a
  simp only [firingSet, Finset.mem_filter, Finset.mem_range, and_iff_left_iff_imp]
  intro ha
  exact Dvd.dvd.mul_right (fires_of_le hm.ne' h) a

/-- The exact success rate at the wall is `1`: `gcd(m, k(B)) = m`. -/
theorem gcd_eq_self_at_wall {m B : ℕ} (hm : 0 < m) (h : m ≤ B) :
    Nat.gcd m (stage1Scalar B) = m :=
  Nat.gcd_eq_left (fires_of_le hm.ne' h)

/-- Stage-1 success rate at the wall, as a rate. -/
theorem success_rate_eq_one_at_wall {m B : ℕ} (hm : 0 < m) (h : m ≤ B) :
    ((firingSet m (stage1Scalar B)).card : ℝ) / m = 1 := by
  rw [card_firingSet _ _ hm, gcd_eq_self_at_wall hm h]
  field_simp

/-! ## No wall can exist: the firing count is monotone in the bound -/

/-- Powersmoothness is monotone in the bound. -/
theorem powersmooth_mono {B B' n : ℕ} (h : B ≤ B') (hs : Powersmooth B n) :
    Powersmooth B' n := fun q hq => le_trans (hs q hq) h

theorem stage1Scalar_zero : stage1Scalar 0 = 1 := by decide

/-- The stage-1 scalars form a divisibility chain in the bound. -/
theorem stage1Scalar_dvd_of_le {B B' : ℕ} (h : B ≤ B') :
    stage1Scalar B ∣ stage1Scalar B' := by
  rcases Nat.eq_zero_or_pos B with rfl | hBpos
  · rw [stage1Scalar_zero]; exact one_dvd _
  have hB : B ≠ 0 := hBpos.ne'
  have hB' : B' ≠ 0 := by omega
  have hself : Powersmooth B (stage1Scalar B) :=
    (dvd_stage1Scalar_iff (stage1Scalar_ne_zero B) hB).mp dvd_rfl
  exact (dvd_stage1Scalar_iff (stage1Scalar_ne_zero B) hB').mpr (powersmooth_mono h hself)

/-- Once an order fires, it fires at every larger bound: firing is monotone. -/
theorem fires_mono {n B B' : ℕ} (h : B ≤ B') (hfire : n ∣ stage1Scalar B) :
    n ∣ stage1Scalar B' := hfire.trans (stage1Scalar_dvd_of_le h)

/-- The firing count is monotone in the bound (divisibility form). -/
theorem firing_count_dvd_mono {m B B' : ℕ} (h : B ≤ B') :
    Nat.gcd m (stage1Scalar B) ∣ Nat.gcd m (stage1Scalar B') :=
  Nat.dvd_gcd (Nat.gcd_dvd_left _ _)
    ((Nat.gcd_dvd_right _ _).trans (stage1Scalar_dvd_of_le h))

theorem firing_count_mono {m B B' : ℕ} (hm : 0 < m) (h : B ≤ B') :
    Nat.gcd m (stage1Scalar B) ≤ Nat.gcd m (stage1Scalar B') :=
  Nat.le_of_dvd (Nat.gcd_pos_of_pos_left _ hm) (firing_count_dvd_mono h)

/-- **No destruction wall.**  In the order-completion ledger the number of firing
points never decreases when the smoothness bound grows.  A "wall" — a bound past
which success collapses — cannot exist, at any scale, for any order. -/
theorem no_destruction_wall {m : ℕ} (hm : 0 < m) :
    ¬ ∃ B B' : ℕ, B ≤ B' ∧
      (firingSet m (stage1Scalar B')).card < (firingSet m (stage1Scalar B)).card := by
  rintro ⟨B, B', hBB, hlt⟩
  rw [card_firingSet _ _ hm, card_firingSet _ _ hm] at hlt
  exact absurd (firing_count_mono hm hBB) (by omega)

/-! ## Outcome-separated accounting -/

/-- The four separated outcomes of one ECM trial on `N = p·q`. -/
inductive Outcome
  | foundP
  | foundQ
  | dead
  | nothing
  deriving DecidableEq, Repr

open Classical in
/-- The outcome as a function of the two independent firing events (`fires mod p`,
`fires mod q`).  This is precisely the separation that experiment 568 added and
that a conflated ledger lacks. -/
noncomputable def outcomeOf (fp fq : Prop) : Outcome :=
  if fp then (if fq then Outcome.dead else Outcome.foundP)
  else (if fq then Outcome.foundQ else Outcome.nothing)

theorem outcomeOf_foundP {fp fq : Prop} (h1 : fp) (h2 : ¬ fq) :
    outcomeOf fp fq = Outcome.foundP := by
  simp [outcomeOf, h1, h2]

/-- `dead` happens **iff** both residues fire simultaneously. -/
theorem outcomeOf_eq_dead_iff {fp fq : Prop} :
    outcomeOf fp fq = Outcome.dead ↔ (fp ∧ fq) := by
  by_cases h1 : fp <;> by_cases h2 : fq <;> simp [outcomeOf, h1, h2]

/-- A divisor of `p·q` that is divisible by `p` but not by `q` is exactly `p`:
the guarded inversion reveals the prime `p`, not the modulus. -/
theorem gcd_eq_p_of_dvd_not_dvd {p q d : ℕ} (hq : q.Prime)
    (hpd : p ∣ d) (hqd : ¬ q ∣ d) : Nat.gcd d (p * q) = p := by
  have hdvd : Nat.gcd d (p * q) ∣ p * q := Nat.gcd_dvd_right _ _
  have hcop : Nat.Coprime (Nat.gcd d (p * q)) q := by
    refine (Nat.Prime.coprime_iff_not_dvd hq).mpr ?_ |>.symm
    intro hcon
    exact hqd (hcon.trans (Nat.gcd_dvd_left _ _))
  have h1 : Nat.gcd d (p * q) ∣ p := hcop.dvd_of_dvd_mul_right hdvd
  have h2 : p ∣ Nat.gcd d (p * q) := Nat.dvd_gcd hpd (Dvd.intro q rfl)
  exact Nat.dvd_antisymm h1 h2

/-- **The wall outcome is `found_p`.**  If the bound covers the whole Hasse window
of `p` (so every point degenerates mod `p`) while some prime factor of the mod-`q`
order exceeds the bound (so nothing degenerates mod `q`), the separated outcome is
`found_p`: guaranteed success. -/
theorem wall_yields_foundP {Gp Gq : Type*} [Group Gp] [Group Gq] [Finite Gp] [Finite Gq]
    {p B r : ℕ} (hB : hasseCeil p ≤ B) (hBne : B ≠ 0)
    (hcard : (Nat.card Gp : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p)
    (gp : Gp) (gq : Gq) (hr : r ∈ (orderOf gq).primeFactors) (hrB : B < r) :
    outcomeOf (gp ^ stage1Scalar B = 1) (gq ^ stage1Scalar B = 1) = Outcome.foundP := by
  have hfp : gp ^ stage1Scalar B = 1 := every_point_fires_at_wall hB hcard gp
  have hqpos : 0 < orderOf gq := orderOf_pos_iff.mpr (isOfFinOrder_of_finite gq)
  have hfq : gq ^ stage1Scalar B ≠ 1 :=
    no_orderCompletion_of_large_prime_factor hqpos hBne hr hrB
  exact outcomeOf_foundP hfp hfq

/-- **No `dead` outcome at the wall** — the recorded destruction event cannot occur
under separated accounting. -/
theorem wall_not_dead {Gp Gq : Type*} [Group Gp] [Group Gq] [Finite Gp] [Finite Gq]
    {p B r : ℕ} (hB : hasseCeil p ≤ B) (hBne : B ≠ 0)
    (hcard : (Nat.card Gp : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p)
    (gp : Gp) (gq : Gq) (hr : r ∈ (orderOf gq).primeFactors) (hrB : B < r) :
    outcomeOf (gp ^ stage1Scalar B = 1) (gq ^ stage1Scalar B = 1) ≠ Outcome.dead := by
  rw [wall_yields_foundP hB hBne hcard gp gq hr hrB]
  decide

/-- The revealed gcd at the wall is the prime `p` itself: a proper nontrivial
factor of `N = p·q`, i.e. a genuine factorization, not a degenerate `gcd = N`. -/
theorem revealed_gcd_eq_p {p q d : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpd : p ∣ d) (hqd : ¬ q ∣ d) :
    Nat.gcd d (p * q) = p ∧ 1 < Nat.gcd d (p * q) ∧ Nat.gcd d (p * q) < p * q := by
  have h := gcd_eq_p_of_dvd_not_dvd hq hpd hqd
  refine ⟨h, by rw [h]; exact hp.one_lt, ?_⟩
  rw [h]
  have h1 := hp.pos
  have h2 := hq.one_lt
  nlinarith

/-- **The `dead` rate is exactly `1/m`.**  If every prime factor of the mod-`q`
order exceeds the bound, exactly one residue (the identity) fires there, so the
simultaneous-degeneracy rate is `1/m`.  At bit length 26 and 600 trials the
expected number of `dead` events is `< 10⁻⁴`: observing zero is the prediction. -/
theorem dead_rate_eq_inv {m B : ℕ} (hm : 0 < m) (hB : B ≠ 0)
    (hlarge : ∀ q ∈ m.primeFactors, B < q) :
    ((firingSet m (stage1Scalar B)).card : ℝ) / m = 1 / m := by
  rw [firingSet_card_eq_one_of_all_prime_factors_gt hm hB hlarge]
  norm_num

/-! ## The expected number of curves is finite exactly where it was recorded infinite -/

/-- Geometric expected number of curves at per-curve success rate `s`. -/
noncomputable def expectedCurves (s : ℝ) : ℝ := ∑' n : ℕ, (1 - s) ^ n

theorem expectedCurves_eq_inv {s : ℝ} (hs : 0 < s) (hs1 : s ≤ 1) :
    expectedCurves s = 1 / s := by
  have h1 : (0 : ℝ) ≤ 1 - s := by linarith
  have h2 : (1 : ℝ) - s < 1 := by linarith
  rw [expectedCurves, tsum_geometric_of_lt_one h1 h2, sub_sub_cancel, one_div]

/-- **`E[T]` is `1`, not `∞`, at the wall.**  At per-curve success rate `1` the
expected number of curves needed is exactly one. -/
theorem expectedCurves_one : expectedCurves 1 = 1 := by
  rw [expectedCurves_eq_inv (by norm_num) le_rfl]; norm_num

/-- The wall statement "uncapped `E[T]` infinite" is false where it was recorded:
for an order at most the bound the success rate is `1` and `E[T] = 1`. -/
theorem expectedCurves_at_wall {m B : ℕ} (hm : 0 < m) (h : m ≤ B) :
    expectedCurves (((firingSet m (stage1Scalar B)).card : ℝ) / m) = 1 := by
  rw [success_rate_eq_one_at_wall hm h, expectedCurves_one]

/-- The stage-1 expected number of curves at bound `B` in the cyclic model of order
`m` is exactly `m / gcd(m, k(B))`. -/
theorem expectedCurves_rate_eq {m B : ℕ} (hm : 0 < m) :
    expectedCurves (((firingSet m (stage1Scalar B)).card : ℝ) / m)
      = (m : ℝ) / Nat.gcd m (stage1Scalar B) := by
  have hg : 0 < Nat.gcd m (stage1Scalar B) := Nat.gcd_pos_of_pos_left _ hm
  have hg' : (0 : ℝ) < Nat.gcd m (stage1Scalar B) := by exact_mod_cast hg
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  have hle : Nat.gcd m (stage1Scalar B) ≤ m := Nat.le_of_dvd hm (Nat.gcd_dvd_left _ _)
  have hle' : (Nat.gcd m (stage1Scalar B) : ℝ) ≤ m := by exact_mod_cast hle
  rw [card_firingSet _ _ hm, expectedCurves_eq_inv (by positivity) (by
    rw [div_le_one hm']; exact hle')]
  field_simp

/-- **`E[T]` is never infinite.**  Whatever the bound, the expected number of curves
in the order-completion ledger is at most `m`: the recorded "uncapped `E[T]`
infinite" has no regime at all, not merely none at the wall. -/
theorem expectedCurves_le_card {m B : ℕ} (hm : 0 < m) :
    expectedCurves (((firingSet m (stage1Scalar B)).card : ℝ) / m) ≤ m := by
  have hg : 1 ≤ Nat.gcd m (stage1Scalar B) := Nat.gcd_pos_of_pos_left _ hm
  have hg' : (1 : ℝ) ≤ Nat.gcd m (stage1Scalar B) := by exact_mod_cast hg
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  rw [expectedCurves_rate_eq hm]
  rw [div_le_iff₀ (by linarith)]
  nlinarith

/-- **`E[T]` is antitone in the bound.**  Raising `B1` can only decrease the expected
number of curves; there is no bound past which the cost blows up. -/
theorem expectedCurves_antitone {m B B' : ℕ} (hm : 0 < m) (h : B ≤ B') :
    expectedCurves (((firingSet m (stage1Scalar B')).card : ℝ) / m)
      ≤ expectedCurves (((firingSet m (stage1Scalar B)).card : ℝ) / m) := by
  rw [expectedCurves_rate_eq hm, expectedCurves_rate_eq hm]
  have hg : (0 : ℝ) < Nat.gcd m (stage1Scalar B) := by
    exact_mod_cast Nat.gcd_pos_of_pos_left _ hm
  have hmono : (Nat.gcd m (stage1Scalar B) : ℝ) ≤ Nat.gcd m (stage1Scalar B') := by
    exact_mod_cast firing_count_mono hm h
  have hm' : (0 : ℝ) ≤ m := by positivity
  gcongr

/-! ## The low-edge cells are not collision luck either -/

/-- The folklore collision baseline never exceeds its linear proxy. -/
theorem collision_baseline_le_linear (x : ℝ) : 1 - Real.exp (-x) ≤ x := by
  have := Real.add_one_le_exp (-x)
  linarith

/-- At `B1/p = 1/8` the collision baseline `1 - exp(-1.44·B1/p)` is at most `0.18`,
strictly below the observed `0.68` found-`p` share in the low-edge cells of
experiment 568: chance gcds cannot account for the observed successes. -/
theorem collision_baseline_below_observed :
    1 - Real.exp (-(1.44 * (1 / 8 : ℝ))) < 0.68 := by
  have h := collision_baseline_le_linear (1.44 * (1 / 8 : ℝ))
  linarith

/-! ## Numeric witnesses -/

theorem stage1Scalar_seven : stage1Scalar 7 = 420 := by decide

/-- **Above the alleged validity edge, firing already happens.**  Paper 159 puts the
validity edge at `B1 ≲ p/2`.  For `p = 13` and `B1 = 7 > 13/2`, the Hasse-window
order `12` of a curve over `𝔽₁₃` already divides the stage-1 scalar: the run
succeeds rather than dies. -/
theorem fires_at_half_p : (12 : ℕ) ∣ stage1Scalar 7 := by
  rw [stage1Scalar_seven]; norm_num

/-- At `p = 13` the arithmetic Hasse ceiling is `22`, and every Hasse-window order
divides the stage-1 scalar at `B = 22`. -/
theorem hasseCeil_thirteen : hasseCeil 13 = 22 := by norm_num [hasseCeil]

theorem all_hasse_orders_fire_thirteen (n : ℕ) (hn : 0 < n) (h : n ≤ 22) :
    n ∣ stage1Scalar 22 := fires_of_le hn.ne' h

end ECMWall