import Mathlib
import Geometry.ECMLiteBirthdayScaling

/-!
# Why sequential multiples waste their operations: the addition-chain barrier

Cycle two of the ECM-lite investigation.  `Geometry.ECMLiteBirthdayScaling`
established that the sequential run `P, 2P, …, B·P` detects **exactly** the base
points of order `≤ 2B - 1`.  Here we ask the sharper question: *per point
operation*, how large a window can any stage-one ladder possibly reach?

The answer is an exponential gap.  A stage-one computation is an addition chain:
each new multiple is a sum of two already computed ones.  After `t` operations
the largest reachable multiple is at most `2^t` (`addChain_le_two_pow`), and the
doubling ladder attains this bound.  The sequential run attains only `t + 1`.
Consequently the lite arm's detection window is *linear* in the number of
operations while the optimal ladder's is *exponential*
(`ladder_beats_sequential`).

The second half of the file converts a measured scaling slope into a statement
about the *effective* stage-one bound.  If a campaign's curve budget behaves
like `p^{1-α}` then the effective visible mass per curve is `p^α`, so the
effective window bound is `B_eff = p^{α/2}` (`window_exponent_from_slope`).  For
the reported slope `0.48` this reads `α = 0.52`, `B_eff ≈ p^{0.26}`: at
`k = 16 … 20` that is `2^{4.2} … 2^{5.2}`, numerically indistinguishable from the
fixed `B₁ = 50 = 2^{5.6}` actually used.  The fixed window *masquerades* as a
growing one over a four-bit range; the masquerade is what
`fixed_bound_refutes_sqrt_scaling` forbids asymptotically.

## Main results

* `addChain_le_two_pow` — the universal per-operation barrier `m_t ≤ 2^t`.
* `doublingChain_eq`, `sequentialChain_eq` — the two extreme chains.
* `detected_order_le_two_mul_max` — a run whose multiples are bounded by `M`
  detects only orders `≤ 2M`, whatever the multiples are.
* `ladder_beats_sequential` — for `t ≥ 3` the doubling ladder annihilates a
  point of order `2^t` that the sequential run of the same length cannot even
  see: exponential versus linear windows at equal cost.
* `budget_exponent_identity`, `window_exponent_from_slope` — the exponent
  bookkeeping that turns a measured slope into a prediction for the effective
  stage-one bound.
* `xCollision_on_iff_detectsOrder` — detection by an arbitrary visiting set of
  multiples is exactly a divisibility condition on its difference and sum sets.
* `geometric_set_beats_sequential`, `order_twelve_seen_only_by_geometric_set` —
  at equal cost (three additions) the geometric set `{1,2,4,8}` detects the
  orders `9, 10, 12` that the sequential set `{1,2,3,4}` misses: the sequential
  choice maximises the contiguous window but minimises the reach.
-/

namespace ECMLite

open Finset

/-! ## Addition chains and the per-operation barrier -/

/-- A stage-one computation: a sequence of multiples starting at `1` in which
every new entry is the sum of two previously computed entries.  This is exactly
what a chain of elliptic-curve additions can produce. -/
structure AddChain where
  /-- the multiple computed at step `t` -/
  seq : ℕ → ℕ
  /-- the chain starts at the base point -/
  head : seq 0 = 1
  /-- every step is an addition of two earlier entries -/
  step : ∀ t, ∃ i ≤ t, ∃ j ≤ t, seq (t + 1) = seq i + seq j

/-- **Per-operation barrier.**  After `t` additions no multiple larger than
`2^t` can have been computed. -/
theorem addChain_le_two_pow (c : AddChain) : ∀ t, c.seq t ≤ 2 ^ t := by
  intro t
  induction t using Nat.strong_induction_on with
  | _ t ih =>
    match t with
    | 0 => simp [c.head]
    | (n + 1) =>
      obtain ⟨i, hi, j, hj, hij⟩ := c.step n
      have h1 : c.seq i ≤ 2 ^ n :=
        le_trans (ih i (by omega)) (Nat.pow_le_pow_right (by norm_num) hi)
      have h2 : c.seq j ≤ 2 ^ n :=
        le_trans (ih j (by omega)) (Nat.pow_le_pow_right (by norm_num) hj)
      calc c.seq (n + 1) = c.seq i + c.seq j := hij
        _ ≤ 2 ^ n + 2 ^ n := Nat.add_le_add h1 h2
        _ = 2 ^ (n + 1) := by ring

/-- The sequential ladder of ECM-lite: `1, 2, 3, …`. -/
def sequentialChain : AddChain where
  seq := fun t => t + 1
  head := rfl
  step := fun t => ⟨t, le_rfl, 0, Nat.zero_le t, by omega⟩

/-- The doubling ladder: `1, 2, 4, 8, …`. -/
def doublingChain : AddChain where
  seq := fun t => 2 ^ t
  head := rfl
  step := fun t => ⟨t, le_rfl, t, le_rfl, by ring⟩

@[simp] theorem sequentialChain_eq (t : ℕ) : sequentialChain.seq t = t + 1 := rfl

@[simp] theorem doublingChain_eq (t : ℕ) : doublingChain.seq t = 2 ^ t := rfl

/-- The doubling ladder attains the barrier, so `2^t` is exactly the optimum. -/
theorem doubling_attains_barrier (t : ℕ) :
    doublingChain.seq t = 2 ^ t ∧ ∀ c : AddChain, c.seq t ≤ doublingChain.seq t :=
  ⟨rfl, fun c => addChain_le_two_pow c t⟩

/-- Arithmetic: past `t = 3` the linear window `2t + 1` of the sequential run is
strictly below the exponential reach `2^t` of an optimal ladder. -/
theorem two_mul_add_one_lt_two_pow {t : ℕ} (ht : 3 ≤ t) : 2 * t + 1 < 2 ^ t := by
  induction t, ht using Nat.le_induction with
  | base => norm_num
  | succ n hn ih =>
    have h2 : 2 ^ (n + 1) = 2 * 2 ^ n := by ring
    omega

/-- The sequential ladder is exponentially far from the barrier. -/
theorem sequential_far_from_barrier {t : ℕ} (ht : 3 ≤ t) :
    sequentialChain.seq t < doublingChain.seq t := by
  have h := two_mul_add_one_lt_two_pow ht
  simp only [sequentialChain_eq, doublingChain_eq]
  omega

variable {G : Type*} [AddGroup G]

/-- **Bounded multiples give bounded detection.**  If the run only ever forms
multiples `≤ M`, then every order it can detect through an `x`-coordinate
coincidence is `≤ 2M` — no matter how the multiples are chosen. -/
theorem detected_order_le_two_mul_max {P : G} {i j M : ℕ}
    (hi : i ≤ M) (hj : j ≤ M) (hij : i < j) (hx : XEq (i • P) (j • P)) :
    addOrderOf P ≤ 2 * M := by
  rcases (xEq_iff_dvd (le_of_lt hij)).mp hx with h | h
  · have := Nat.le_of_dvd (show 0 < j - i by omega) h
    omega
  · rcases Nat.eq_zero_or_pos i with hi0 | hi0
    · subst hi0
      have := Nat.le_of_dvd (show 0 < 0 + j by omega) h
      omega
    · have := Nat.le_of_dvd (show 0 < i + j by omega) h
      omega

/-- **Exponential versus linear windows at equal cost.**  With `t ≥ 3` point
operations the doubling ladder annihilates the generator of `ℤ/2^t`, whose order
`2^t` lies far outside the window `[1, 2(t+1) - 1]` of the sequential run of the
same length.  The lite arm therefore does not merely lose the smoothness of true
ECM: it loses an exponential factor in raw reach per operation. -/
theorem ladder_beats_sequential {t : ℕ} (ht : 3 ≤ t) :
    (doublingChain.seq t) • (1 : ZMod (2 ^ t)) = 0 ∧
      ¬ XCollision (1 : ZMod (2 ^ t)) (sequentialChain.seq t) := by
  have hpos : 0 < 2 ^ t := pow_pos (by norm_num) t
  have hord : addOrderOf (1 : ZMod (2 ^ t)) = 2 ^ t := ZMod.addOrderOf_one _
  refine ⟨?_, ?_⟩
  · rw [doublingChain_eq]
    simp
  · rw [sequentialChain_eq]
    intro hcol
    have hordpos : 0 < addOrderOf (1 : ZMod (2 ^ t)) := by rw [hord]; exact hpos
    have hle := (xCollision_iff_addOrderOf_le (by omega) hordpos).mp hcol
    rw [hord] at hle
    have hgrow := two_mul_add_one_lt_two_pow ht
    omega

/-! ## Turning a measured slope into an effective window -/

/-- Budget bookkeeping: a visible mass `p^α` per curve costs `p^{1-α}` curves. -/
theorem budget_exponent_identity {p : ℝ} (hp : 0 < p) (α : ℝ) :
    p / p ^ α = p ^ (1 - α) := by
  rw [Real.rpow_sub hp, Real.rpow_one]

/-- **Effective stage-one bound implied by a measured slope.**  A campaign whose
per-curve visible mass is `B²` and whose measured budget exponent is `1 - α`
must have an effective bound `B = p^{α/2}`.  For the reported slope `0.48`
(`α = 0.52`) this predicts `B_eff ≈ p^{0.26}` — a *growing* window, which a
fixed `B₁ = 50` can only imitate over a bounded range of `p`. -/
theorem window_exponent_from_slope {p B α : ℝ} (hp : 0 < p) (hB : 0 < B) :
    B ^ 2 = p ^ α ↔ B = p ^ (α / 2) := by
  constructor
  · intro h
    have hb : B = Real.sqrt (B ^ 2) := (Real.sqrt_sq hB.le).symm
    rw [hb, h, Real.sqrt_eq_rpow, ← Real.rpow_mul hp.le,
      show α * (1 / 2) = α / 2 from by ring]
  · intro h
    rw [h, ← Real.rpow_natCast (p ^ (α / 2)) 2, ← Real.rpow_mul hp.le]
    norm_num

/-! ## Cycle three: which *visiting sets* detect which orders -/

/-- The order-detection predicate of an arbitrary visiting set `J` of multiples:
the run over `J` reveals a base point of order `d` exactly when some pair in `J`
has difference or sum divisible by `d` (difference = repetition, sum = elliptic
involution). -/
def DetectsOrder (J : Finset ℕ) (d : ℕ) : Prop :=
  ∃ i ∈ J, ∃ j ∈ J, i < j ∧ (d ∣ j - i ∨ d ∣ i + j)

instance (J : Finset ℕ) (d : ℕ) : Decidable (DetectsOrder J d) := by
  unfold DetectsOrder; infer_instance

/-- **Visiting sets detect by divisibility.**  For any finite set `J` of visited
multiples, the run over `J` has an `x`-coordinate coincidence iff `J` detects the
order of the base point. -/
theorem xCollision_on_iff_detectsOrder {P : G} (J : Finset ℕ) :
    (∃ i ∈ J, ∃ j ∈ J, i < j ∧ XEq (i • P) (j • P)) ↔ DetectsOrder J (addOrderOf P) := by
  constructor
  · rintro ⟨i, hi, j, hj, hij, hx⟩
    exact ⟨i, hi, j, hj, hij, (xEq_iff_dvd (le_of_lt hij)).mp hx⟩
  · rintro ⟨i, hi, j, hj, hij, hd⟩
    exact ⟨i, hi, j, hj, hij, (xEq_iff_dvd (le_of_lt hij)).mpr hd⟩

/-- The sequential run is the special case `J = {1, …, B}`. -/
theorem xCollision_iff_detectsOrder {P : G} (B : ℕ) :
    XCollision P B ↔ DetectsOrder (Finset.Icc 1 B) (addOrderOf P) :=
  xCollision_on_iff_detectsOrder (Finset.Icc 1 B)

/-- **The sequential run is not optimal.**  Four visited multiples cost three
additions either way, but the geometric set `{1,2,4,8}` detects the orders
`9, 10, 12` while the sequential set `{1,2,3,4}` detects none of them; the
sequential set detects exactly `1, …, 7`.  So even at equal operation count the
choice of visiting set matters, and the sequential choice is the one that
maximises the *contiguous* window while minimising the *reach*. -/
theorem geometric_set_beats_sequential :
    (∀ d ∈ Finset.Icc 1 7, DetectsOrder {1, 2, 3, 4} d) ∧
      (∀ d ∈ ({9, 10, 12} : Finset ℕ),
        DetectsOrder {1, 2, 4, 8} d ∧ ¬ DetectsOrder {1, 2, 3, 4} d) := by
  constructor
  · decide
  · decide

/-- Group-level form of the previous statement: a base point of order `12` is
found by the run over `{1,2,4,8}` and missed by the sequential run over
`{1,2,3,4}`, at the same cost of three curve additions. -/
theorem order_twelve_seen_only_by_geometric_set {P : G} (hP : addOrderOf P = 12) :
    (∃ i ∈ ({1, 2, 4, 8} : Finset ℕ), ∃ j ∈ ({1, 2, 4, 8} : Finset ℕ),
        i < j ∧ XEq (i • P) (j • P)) ∧
      ¬ (∃ i ∈ ({1, 2, 3, 4} : Finset ℕ), ∃ j ∈ ({1, 2, 3, 4} : Finset ℕ),
        i < j ∧ XEq (i • P) (j • P)) := by
  rw [xCollision_on_iff_detectsOrder, xCollision_on_iff_detectsOrder, hP]
  exact ⟨by decide, by decide⟩

end ECMLite