/-
# Rotated Laplacians, periodicity ratios and nearly-periodic structure in digraphs

Self-contained formalization of core structural facts underlying the theory of
*rotated Laplacian matrices* (Lange-Liu-Peyerimhoff-Post) and the *periodicity
ratio* of a weighted digraph / Markov chain, in the spirit of the paper
"Finding Nearly-Periodic Components in Digraphs and Markov Chains from the
Spectrum of Rotated Laplacian Matrices".

For a nonnegatively weighted digraph `w : V → V → ℝ` and a unimodular rotation
`om : ℂ` (typically a primitive `p`-th root of unity `rotWeight p`) the rotated
Laplacian quadratic form is

  `rotEnergy w om x = ∑ u, ∑ v, w u v * ‖x v - om * x u‖ ^ 2`,

which is the Hermitian form `x* (D - A_om) x` of the rotated Laplacian.  The
*periodicity ratio* is the infimum of `rotEnergy w om x / vol w x` over
unimodular-or-zero "phase" vectors `x`.
-/
import Mathlib

namespace RotatedLaplacian

open Finset Complex

variable {V : Type*} [Fintype V]

/-! ## Definitions -/

/-- The rotated Laplacian quadratic form of the weighted digraph `w` with
rotation `om`, evaluated at `x`. -/
noncomputable def rotEnergy (w : V → V → ℝ) (om : ℂ) (x : V → ℂ) : ℝ :=
  ∑ u, ∑ v, w u v * ‖x v - om * x u‖ ^ 2

/-- Total (in + out) degree of a vertex. -/
def deg (w : V → V → ℝ) (v : V) : ℝ := ∑ u, (w v u + w u v)

/-- The volume of a vector, i.e. the denominator `x* D x` of the Rayleigh
quotient of the rotated Laplacian. -/
noncomputable def vol (w : V → V → ℝ) (x : V → ℂ) : ℝ := ∑ v, deg w v * ‖x v‖ ^ 2

/-- The Rayleigh quotient of the rotated Laplacian. -/
noncomputable def rotRayleigh (w : V → V → ℝ) (om : ℂ) (x : V → ℂ) : ℝ :=
  rotEnergy w om x / vol w x

/-- A *phase vector*: every coordinate is either `0` or a power of the rotation
`om`.  These are the test vectors defining the periodicity ratio; they generalize
the `±1/0` vectors of Trevisan's bipartiteness ratio. -/
def IsPhase (om : ℂ) (x : V → ℂ) : Prop := ∀ v, x v = 0 ∨ ∃ k : ℕ, x v = om ^ k

/-- The set of Rayleigh quotients achieved by nonzero phase vectors. -/
def phaseRatios (w : V → V → ℝ) (om : ℂ) : Set ℝ :=
  {r | ∃ x : V → ℂ, IsPhase om x ∧ x ≠ 0 ∧ r = rotRayleigh w om x}

/-- The periodicity ratio: the infimum of the Rayleigh quotient of the rotated
Laplacian over nonzero phase vectors. -/
noncomputable def periodicityRatio (w : V → V → ℝ) (om : ℂ) : ℝ :=
  sInf (phaseRatios w om)

/-- The canonical primitive `p`-th root of unity used as rotation. -/
noncomputable def rotWeight (p : ℕ) : ℂ := Complex.exp (2 * Real.pi * Complex.I / p)

/-- The reversal of a digraph. -/
def reverse (w : V → V → ℝ) : V → V → ℝ := fun u v => w v u

/-- `Reach w u v n` : there is a directed walk of length `n` from `u` to `v`
using only arcs of nonzero weight. -/
inductive Reach (w : V → V → ℝ) : V → V → ℕ → Prop
  | refl (v : V) : Reach w v v 0
  | step {u v z : V} {n : ℕ} : Reach w u v n → w v z ≠ 0 → Reach w u z (n + 1)

/-! ## Basic properties of the rotation weight -/

theorem rotWeight_isPrimitiveRoot {p : ℕ} (hp : p ≠ 0) :
    IsPrimitiveRoot (rotWeight p) p :=
  Complex.isPrimitiveRoot_exp p hp

theorem norm_rotWeight {p : ℕ} (hp : p ≠ 0) : ‖rotWeight p‖ = 1 :=
  (rotWeight_isPrimitiveRoot hp).norm'_eq_one hp

theorem rotWeight_pow_eq_one_iff {p : ℕ} (hp : p ≠ 0) (n : ℕ) :
    rotWeight p ^ n = 1 ↔ p ∣ n :=
  (rotWeight_isPrimitiveRoot hp).pow_eq_one_iff_dvd n

/-! ## Positivity and the zero-energy characterization -/

theorem rotEnergy_nonneg {w : V → V → ℝ} (hw : ∀ u v, 0 ≤ w u v) (om : ℂ)
    (x : V → ℂ) : 0 ≤ rotEnergy w om x :=
  Finset.sum_nonneg fun u _ => Finset.sum_nonneg fun v _ =>
    mul_nonneg (hw u v) (by positivity)

/-- If every arc "rotates correctly" then the rotated energy vanishes.  (No
sign condition on the weights is needed for this direction.) -/
theorem rotEnergy_eq_zero_of_edges {w : V → V → ℝ} {om : ℂ} {x : V → ℂ}
    (h : ∀ u v, w u v ≠ 0 → x v = om * x u) : rotEnergy w om x = 0 := by
  refine Finset.sum_eq_zero fun u _ => Finset.sum_eq_zero fun v _ => ?_
  by_cases hne : w u v = 0
  · simp [hne]
  · rw [h u v hne]; simp

/-- Zero rotated energy is exactly the statement that every arc of the digraph
"rotates correctly": `x v = om * x u` along each arc. -/
theorem rotEnergy_eq_zero_iff {w : V → V → ℝ} (hw : ∀ u v, 0 ≤ w u v) (om : ℂ)
    (x : V → ℂ) :
    rotEnergy w om x = 0 ↔ ∀ u v, w u v ≠ 0 → x v = om * x u := by
  rw [rotEnergy, Finset.sum_eq_zero_iff_of_nonneg]
  · constructor
    · intro h u v hne
      have h1 := h u (Finset.mem_univ u)
      rw [Finset.sum_eq_zero_iff_of_nonneg] at h1
      · have h2 := h1 v (Finset.mem_univ v)
        rcases mul_eq_zero.1 h2 with h3 | h3
        · exact absurd h3 hne
        · exact sub_eq_zero.1 (norm_eq_zero.1 (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h3))
      · exact fun v _ => mul_nonneg (hw u v) (by positivity)
    · intro h u _
      exact Finset.sum_eq_zero fun v _ => by
        by_cases hne : w u v = 0
        · simp [hne]
        · rw [h u v hne]; simp
  · exact fun u _ => Finset.sum_nonneg fun v _ => mul_nonneg (hw u v) (by positivity)

/-- **A universal upper bound.**  The Rayleigh quotient of the rotated Laplacian
never exceeds `2`; equivalently the periodicity ratio of any digraph is at most
`2`.  (This is the rotated analogue of `λ ≤ 2` for normalized Laplacians.) -/
theorem rotEnergy_le_two_mul_vol {w : V → V → ℝ} (hw : ∀ u v, 0 ≤ w u v) {om : ℂ}
    (hom : ‖om‖ = 1) (x : V → ℂ) : rotEnergy w om x ≤ 2 * vol w x := by
  have hterm : ∀ u v, w u v * ‖x v - om * x u‖ ^ 2
      ≤ w u v * (2 * ‖x v‖ ^ 2 + 2 * ‖x u‖ ^ 2) := by
    intro u v
    refine mul_le_mul_of_nonneg_left ?_ (hw u v)
    have h1 : ‖x v - om * x u‖ ≤ ‖x v‖ + ‖om * x u‖ := norm_sub_le _ _
    rw [norm_mul, hom, one_mul] at h1
    nlinarith [norm_nonneg (x v), norm_nonneg (x u), norm_nonneg (x v - om * x u),
      sq_nonneg (‖x v‖ - ‖x u‖)]
  have A : ∑ u, ∑ v, w u v * (2 * ‖x v‖ ^ 2 + 2 * ‖x u‖ ^ 2)
      = 2 * ∑ u, ∑ v, w u v * ‖x v‖ ^ 2 + 2 * ∑ u, ∑ v, w u v * ‖x u‖ ^ 2 := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun u _ => ?_
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun v _ => by ring
  have B : 2 * vol w x
      = 2 * ∑ v, ∑ u, w u v * ‖x v‖ ^ 2 + 2 * ∑ v, ∑ u, w v u * ‖x v‖ ^ 2 := by
    rw [vol, Finset.mul_sum, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun v _ => ?_
    rw [deg, Finset.sum_mul, Finset.mul_sum, Finset.mul_sum, Finset.mul_sum,
      ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun u _ => by ring
  calc rotEnergy w om x ≤ ∑ u, ∑ v, w u v * (2 * ‖x v‖ ^ 2 + 2 * ‖x u‖ ^ 2) :=
        Finset.sum_le_sum fun u _ => Finset.sum_le_sum fun v _ => hterm u v
    _ = 2 * vol w x := by rw [A, B, Finset.sum_comm (f := fun u v => w u v * ‖x v‖ ^ 2)]

/-- Consequently every achievable phase ratio is at most `2` (when the volume is
positive). -/
theorem rotRayleigh_le_two {w : V → V → ℝ} (hw : ∀ u v, 0 ≤ w u v) {om : ℂ}
    (hom : ‖om‖ = 1) {x : V → ℂ} (hvol : 0 < vol w x) : rotRayleigh w om x ≤ 2 := by
  rw [rotRayleigh, div_le_iff₀ hvol]
  linarith [rotEnergy_le_two_mul_vol hw hom x]

/-! ## Invariance under reversal of the digraph -/

omit [Fintype V] in
theorem reverse_reverse (w : V → V → ℝ) : reverse (reverse w) = w := rfl

theorem deg_reverse (w : V → V → ℝ) (v : V) : deg (reverse w) v = deg w v := by
  simp [deg, reverse, add_comm]

theorem vol_reverse (w : V → V → ℝ) (x : V → ℂ) :
    vol (reverse w) (fun v => starRingEnd ℂ (x v)) = vol w x := by
  simp [vol, deg_reverse]

/-- The complex conjugate of a unimodular number is a power of it, when it is a
root of unity. -/
theorem conj_eq_pow {om : ℂ} {N : ℕ} (hN : N ≠ 0) (hom : om ^ N = 1) :
    (starRingEnd ℂ) om = om ^ (N - 1) := by
  have h1 : ‖om‖ = 1 := Complex.norm_eq_one_of_pow_eq_one hom hN
  have hs : N - 1 + 1 = N := Nat.succ_pred_eq_of_pos (Nat.pos_of_ne_zero hN)
  have h3 : om * om ^ (N - 1) = 1 := by rw [← pow_succ', hs, hom]
  have h4 : (starRingEnd ℂ) om * om = 1 := by
    have h := Complex.mul_conj om
    rw [Complex.normSq_eq_norm_sq, h1] at h
    rw [mul_comm, h]; norm_num
  calc (starRingEnd ℂ) om = (starRingEnd ℂ) om * (om * om ^ (N - 1)) := by rw [h3, mul_one]
    _ = ((starRingEnd ℂ) om * om) * om ^ (N - 1) := by ring
    _ = om ^ (N - 1) := by rw [h4, one_mul]

omit [Fintype V] in
theorem isPhase_conj {om : ℂ} {N : ℕ} (hN : N ≠ 0) (hom : om ^ N = 1) {x : V → ℂ}
    (hx : IsPhase om x) : IsPhase om (fun v => starRingEnd ℂ (x v)) := by
  intro v
  rcases hx v with h | ⟨k, hk⟩
  · left; simp [h]
  · exact Or.inr ⟨(N - 1) * k, by simp [hk, map_pow, conj_eq_pow hN hom, ← pow_mul]⟩

/-- The rotated energy is invariant under reversing all arcs, provided the
vector is replaced by its complex conjugate. -/
theorem rotEnergy_reverse {om : ℂ} (hom : ‖om‖ = 1) (w : V → V → ℝ) (x : V → ℂ) :
    rotEnergy (reverse w) om (fun v => starRingEnd ℂ (x v)) = rotEnergy w om x := by
  have hconj : (starRingEnd ℂ) om * om = 1 := by
    have h := Complex.mul_conj om
    rw [Complex.normSq_eq_norm_sq, hom] at h
    rw [mul_comm, h]; norm_num
  rw [rotEnergy, rotEnergy, Finset.sum_comm]
  refine Finset.sum_congr rfl fun u _ => Finset.sum_congr rfl fun v _ => ?_
  show w u v * ‖(starRingEnd ℂ) (x u) - om * (starRingEnd ℂ) (x v)‖ ^ 2
      = w u v * ‖x v - om * x u‖ ^ 2
  congr 2
  have h1 : (starRingEnd ℂ) (x u) - om * (starRingEnd ℂ) (x v)
      = (starRingEnd ℂ) (x u - (starRingEnd ℂ) om * x v) := by
    simp [map_sub, map_mul]
  have h2 : x u - (starRingEnd ℂ) om * x v = -((starRingEnd ℂ) om) * (x v - om * x u) := by
    have h3 : (starRingEnd ℂ) om * (om * x u) = x u := by rw [← mul_assoc, hconj, one_mul]
    rw [neg_mul, mul_sub, h3]; ring
  rw [h1, RCLike.norm_conj, h2, norm_mul, norm_neg, RCLike.norm_conj, hom, one_mul]

theorem phaseRatios_reverse {om : ℂ} {N : ℕ} (hN : N ≠ 0) (hom : om ^ N = 1)
    (w : V → V → ℝ) : phaseRatios (reverse w) om = phaseRatios w om := by
  have hnorm : ‖om‖ = 1 := Complex.norm_eq_one_of_pow_eq_one hom hN
  have key : ∀ w : V → V → ℝ, phaseRatios (reverse w) om ⊆ phaseRatios w om := by
    rintro w r ⟨x, hx, hx0, hr⟩
    refine ⟨fun v => starRingEnd ℂ (x v), isPhase_conj hN hom hx, ?_, ?_⟩
    · intro h
      apply hx0
      funext v
      have := congrFun h v
      simpa using congrArg (starRingEnd ℂ) this
    · have hE : rotEnergy w om (fun v => starRingEnd ℂ (x v)) = rotEnergy (reverse w) om x :=
        rotEnergy_reverse hnorm (reverse w) x
      have hV : vol w (fun v => starRingEnd ℂ (x v)) = vol (reverse w) x :=
        vol_reverse (reverse w) x
      rw [hr, rotRayleigh, rotRayleigh, hE, hV]
  exact le_antisymm (key w) fun r hr => key (reverse w) hr

/-- **The periodicity ratio of a digraph equals that of its reversal.** -/
theorem periodicityRatio_reverse {om : ℂ} {N : ℕ} (hN : N ≠ 0) (hom : om ^ N = 1)
    (w : V → V → ℝ) : periodicityRatio (reverse w) om = periodicityRatio w om := by
  rw [periodicityRatio, periodicityRatio, phaseRatios_reverse hN hom]

/-! ## Zero energy and periodicity of closed walks -/

omit [Fintype V] in
theorem Reach.trans {w : V → V → ℝ} {u v z : V} {m n : ℕ}
    (h1 : Reach w u v m) (h2 : Reach w v z n) : Reach w u z (m + n) := by
  induction h2 with
  | refl => simpa using h1
  | step _ he ih => exact Reach.step ih he

omit [Fintype V] in
/-- Along a walk, a zero-energy vector picks up one factor of `om` per step. -/
theorem phase_along_walk {w : V → V → ℝ} {om : ℂ} {x : V → ℂ}
    (h : ∀ u v, w u v ≠ 0 → x v = om * x u) {u v : V} {n : ℕ}
    (hR : Reach w u v n) : x v = om ^ n * x u := by
  induction hR with
  | refl => simp
  | @step b c _ _ he ih => rw [h b c he, ih]; ring

omit [Fintype V] in
/-- In a strongly connected digraph a zero-energy vector that is nonzero
somewhere is nonzero everywhere. -/
theorem ne_zero_of_reach {w : V → V → ℝ} {om : ℂ} (hom : om ≠ 0) {x : V → ℂ}
    (h : ∀ u v, w u v ≠ 0 → x v = om * x u) {u v : V} {n : ℕ}
    (hR : Reach w u v n) (hu : x u ≠ 0) : x v ≠ 0 := by
  rw [phase_along_walk h hR]
  exact mul_ne_zero (pow_ne_zero _ hom) hu

/-- **Zero periodicity energy certifies periodicity**: if some vector that is
nonzero at `v` has zero rotated energy for the `p`-th root of unity, then every
closed walk through `v` has length divisible by `p`. -/
theorem dvd_of_rotEnergy_eq_zero {w : V → V → ℝ} (hw : ∀ u v, 0 ≤ w u v) {p : ℕ}
    (hp : p ≠ 0) {x : V → ℂ} {v : V} (hx : x v ≠ 0)
    (h0 : rotEnergy w (rotWeight p) x = 0) {n : ℕ} (hR : Reach w v v n) :
    p ∣ n := by
  have hedge := (rotEnergy_eq_zero_iff hw _ x).1 h0
  have h := phase_along_walk hedge hR
  have : rotWeight p ^ n = 1 := by
    have h1 : rotWeight p ^ n * x v - x v = 0 := sub_eq_zero.2 h.symm
    have h2 : (rotWeight p ^ n - 1) * x v = 0 := by linear_combination h1
    rcases mul_eq_zero.1 h2 with h3 | h3
    · exact sub_eq_zero.1 h3
    · exact absurd h3 hx
  exact (rotWeight_pow_eq_one_iff hp n).1 this

/-- **Converse construction**: a strongly connected digraph all of whose closed
walks have length divisible by `p` admits a unimodular phase vector of zero
rotated energy. -/
theorem exists_phase_of_dvd_closed_walks [Nonempty V] {w : V → V → ℝ} {p : ℕ}
    (hp : p ≠ 0) (hconn : ∀ u v : V, ∃ n, Reach w u v n)
    (hcyc : ∀ (v : V) (n : ℕ), Reach w v v n → p ∣ n) :
    ∃ x : V → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight p) x ∧
      rotEnergy w (rotWeight p) x = 0 := by
  classical
  obtain ⟨r⟩ := ‹Nonempty V›
  set N : V → ℕ := fun v => (hconn r v).choose with hN
  have hNspec : ∀ v, Reach w r v (N v) := fun v => (hconn r v).choose_spec
  set om := rotWeight p with hom
  have hnorm : ‖om‖ = 1 := norm_rotWeight hp
  refine ⟨fun v => om ^ N v, fun v => by rw [norm_pow, hnorm, one_pow],
    fun v => Or.inr ⟨N v, rfl⟩, ?_⟩
  refine rotEnergy_eq_zero_of_edges ?_
  · intro u v hne
    obtain ⟨k, hk⟩ := hconn v r
    have hv : Reach w r r (N v + k) := Reach.trans (hNspec v) hk
    have hu : Reach w r r (N u + 1 + k) :=
      Reach.trans (Reach.step (hNspec u) hne) hk
    have d1 : p ∣ N v + k := hcyc r _ hv
    have d2 : p ∣ N u + 1 + k := hcyc r _ hu
    have e1 : om ^ (N v + k) = 1 := (rotWeight_pow_eq_one_iff hp _).2 d1
    have e2 : om ^ (N u + 1 + k) = 1 := (rotWeight_pow_eq_one_iff hp _).2 d2
    have hk0 : om ^ k ≠ 0 := pow_ne_zero _ (by
      intro h; rw [h] at hnorm; simp at hnorm)
    have : om ^ N v * om ^ k = om ^ (N u + 1) * om ^ k := by
      rw [← pow_add, ← pow_add, e1, e2]
    have := mul_right_cancel₀ hk0 this
    rw [this, pow_succ]
    ring

/-- **Main characterization.**  For a strongly connected nonnegatively weighted
digraph, the `p`-periodicity ratio vanishes (i.e. some unimodular phase vector
has zero rotated energy) if and only if `p` divides the length of every closed
walk, i.e. `p` divides the period of the digraph. -/
theorem exists_zero_energy_phase_iff [Nonempty V] {w : V → V → ℝ}
    (hw : ∀ u v, 0 ≤ w u v) {p : ℕ} (hp : p ≠ 0) (hconn : ∀ u v : V, ∃ n, Reach w u v n) :
    (∃ x : V → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight p) x ∧
        rotEnergy w (rotWeight p) x = 0)
      ↔ ∀ (v : V) (n : ℕ), Reach w v v n → p ∣ n := by
  constructor
  · rintro ⟨x, hx, -, h0⟩ v n hR
    refine dvd_of_rotEnergy_eq_zero hw hp ?_ h0 hR
    intro hxv
    have hv1 := hx v
    rw [hxv] at hv1
    simp at hv1
  · intro hcyc
    exact exists_phase_of_dvd_closed_walks hp hconn hcyc

/-- The set of `p` with vanishing periodicity ratio is closed under taking
divisors: near-periodicity structure at `p` implies it at every divisor of `p`. -/
theorem exists_zero_energy_phase_of_dvd [Nonempty V] {w : V → V → ℝ}
    (hw : ∀ u v, 0 ≤ w u v) {p q : ℕ} (hp : p ≠ 0) (hq : q ≠ 0) (hqp : q ∣ p)
    (hconn : ∀ u v : V, ∃ n, Reach w u v n)
    (h : ∃ x : V → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight p) x ∧
      rotEnergy w (rotWeight p) x = 0) :
    ∃ x : V → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight q) x ∧
      rotEnergy w (rotWeight q) x = 0 :=
  (exists_zero_energy_phase_iff hw hq hconn).2 fun v n hR =>
    hqp.trans ((exists_zero_energy_phase_iff hw hp hconn).1 h v n hR)

/-- The set of `p` with vanishing periodicity ratio is closed under least common
multiples.  Together with `exists_zero_energy_phase_of_dvd` this shows that this
set is exactly the set of divisors of the period of the digraph. -/
theorem exists_zero_energy_phase_lcm [Nonempty V] {w : V → V → ℝ}
    (hw : ∀ u v, 0 ≤ w u v) {p q : ℕ} (hp : p ≠ 0) (hq : q ≠ 0)
    (hconn : ∀ u v : V, ∃ n, Reach w u v n)
    (hP : ∃ x : V → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight p) x ∧
      rotEnergy w (rotWeight p) x = 0)
    (hQ : ∃ x : V → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight q) x ∧
      rotEnergy w (rotWeight q) x = 0) :
    ∃ x : V → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight (Nat.lcm p q)) x ∧
      rotEnergy w (rotWeight (Nat.lcm p q)) x = 0 :=
  (exists_zero_energy_phase_iff hw (Nat.lcm_ne_zero hp hq) hconn).2 fun v n hR =>
    Nat.lcm_dvd ((exists_zero_energy_phase_iff hw hp hconn).1 hP v n hR)
      ((exists_zero_energy_phase_iff hw hq hconn).1 hQ v n hR)

/-! ## Markov chains: unimodular eigenvalues have zero rotated energy -/

/-- The variance identity `E‖Z - E Z‖² = E‖Z‖² - ‖E Z‖²` for a probability
vector `P u ·`. -/
theorem row_energy_eq {P : V → V → ℝ} {u : V} (hrow : ∑ v, P u v = 1)
    (x : V → ℂ) {c : ℂ} (hc : ∑ v, (P u v : ℂ) * x v = c) :
    ∑ v, P u v * ‖x v - c‖ ^ 2 = (∑ v, P u v * ‖x v‖ ^ 2) - ‖c‖ ^ 2 := by
  have key : ∀ v, P u v * ‖x v - c‖ ^ 2
      = P u v * ‖x v‖ ^ 2 + P u v * ‖c‖ ^ 2
        - 2 * (((P u v : ℂ) * x v) * (starRingEnd ℂ) c).re := by
    intro v
    have h := Complex.normSq_sub (x v) c
    simp only [← Complex.normSq_eq_norm_sq]
    rw [h]
    simp [Complex.mul_re]
    ring
  have hcc : ∑ v, (2:ℝ) * (((P u v : ℂ) * x v) * (starRingEnd ℂ) c).re = 2 * ‖c‖ ^ 2 := by
    rw [← Finset.mul_sum, ← Complex.re_sum, ← Finset.sum_mul, hc, Complex.mul_conj,
      Complex.normSq_eq_norm_sq]
    simp [-Complex.ofReal_pow]
  rw [Finset.sum_congr rfl (fun v _ => key v), Finset.sum_sub_distrib, Finset.sum_add_distrib,
    ← Finset.sum_mul, hrow, hcc]
  ring

/-- **Unimodular eigenvalues of a Markov chain give exactly periodic
structure.**  If `x` is a right eigenvector of the transition matrix `P` with
unimodular eigenvalue `om`, then the rotated energy of `x` for the weighting
`w u v = π u * P u v` induced by any stationary distribution `π` vanishes. -/
theorem rotEnergy_eq_zero_of_eigenvector {P : V → V → ℝ} (hrow : ∀ u, ∑ v, P u v = 1)
    {pi : V → ℝ} (hstat : ∀ v, ∑ u, pi u * P u v = pi v)
    {om : ℂ} (hom : ‖om‖ = 1) {x : V → ℂ} (hx : ∀ u, ∑ v, (P u v : ℂ) * x v = om * x u) :
    rotEnergy (fun u v => pi u * P u v) om x = 0 := by
  have step : ∀ u, ∑ v, pi u * P u v * ‖x v - om * x u‖ ^ 2
      = pi u * (∑ v, P u v * ‖x v‖ ^ 2) - pi u * ‖x u‖ ^ 2 := by
    intro u
    have h := row_energy_eq (hrow u) x (hx u)
    calc ∑ v, pi u * P u v * ‖x v - om * x u‖ ^ 2
        = pi u * ∑ v, P u v * ‖x v - om * x u‖ ^ 2 := by
          rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun v _ => by ring
      _ = pi u * ((∑ v, P u v * ‖x v‖ ^ 2) - ‖om * x u‖ ^ 2) := by rw [h]
      _ = pi u * (∑ v, P u v * ‖x v‖ ^ 2) - pi u * ‖x u‖ ^ 2 := by
          rw [norm_mul, hom, one_mul]; ring
  rw [rotEnergy, Finset.sum_congr rfl (fun u _ => step u), Finset.sum_sub_distrib]
  have hsum : ∑ u, pi u * (∑ v, P u v * ‖x v‖ ^ 2) = ∑ v, pi v * ‖x v‖ ^ 2 := by
    have h1 : ∀ u, pi u * (∑ v, P u v * ‖x v‖ ^ 2) = ∑ v, (pi u * P u v) * ‖x v‖ ^ 2 := by
      intro u; rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun v _ => by ring
    rw [Finset.sum_congr rfl (fun u _ => h1 u), Finset.sum_comm]
    exact Finset.sum_congr rfl fun v _ => by rw [← Finset.sum_mul, hstat v]
  rw [hsum, sub_self]

/-- **Unimodular eigenvalues certify exact periodicity.**  If the transition
matrix `P` of a Markov chain with stationary distribution `pi` has the primitive
`p`-th root of unity as an eigenvalue, then every closed walk of the digraph of
the chain (weighted by `pi u * P u v`) has length divisible by `p`. -/
theorem dvd_of_eigenvalue_rotWeight {P : V → V → ℝ} (hP : ∀ u v, 0 ≤ P u v)
    (hrow : ∀ u, ∑ v, P u v = 1) {pi : V → ℝ} (hpi : ∀ v, 0 ≤ pi v)
    (hstat : ∀ v, ∑ u, pi u * P u v = pi v) {p : ℕ} (hp : p ≠ 0) {x : V → ℂ}
    (hx : ∀ u, ∑ v, (P u v : ℂ) * x v = rotWeight p * x u) {v : V} (hxv : x v ≠ 0)
    {n : ℕ} (hR : Reach (fun u v => pi u * P u v) v v n) : p ∣ n :=
  dvd_of_rotEnergy_eq_zero (fun u v => mul_nonneg (hpi u) (hP u v)) hp hxv
    (rotEnergy_eq_zero_of_eigenvector hrow hstat (norm_rotWeight hp) hx) hR

/-- **Converse of the eigenvalue theorem.**  If the chain-weighted digraph
`w u v = pi u * P u v` has a zero-energy vector and `pi` is everywhere positive,
then that vector is an eigenvector of `P` with eigenvalue `om`.  Combined with
`rotEnergy_eq_zero_of_eigenvector` this shows that, for an everywhere positive
stationary distribution, vanishing rotated energy and unimodular eigenvalues of
the chain are the same phenomenon. -/
theorem eigenvector_of_rotEnergy_eq_zero {P : V → V → ℝ} (hP : ∀ u v, 0 ≤ P u v)
    (hrow : ∀ u, ∑ v, P u v = 1) {pi : V → ℝ} (hpi : ∀ v, 0 < pi v) {om : ℂ} {x : V → ℂ}
    (h0 : rotEnergy (fun u v => pi u * P u v) om x = 0) :
    ∀ u, ∑ v, (P u v : ℂ) * x v = om * x u := by
  have hedge := (rotEnergy_eq_zero_iff
    (fun u v => mul_nonneg (hpi u).le (hP u v)) om x).1 h0
  intro u
  have h : ∀ v, ((P u v : ℝ) : ℂ) * x v = ((P u v : ℝ) : ℂ) * (om * x u) := by
    intro v
    by_cases hz : P u v = 0
    · simp [hz]
    · rw [hedge u v (mul_ne_zero (ne_of_gt (hpi u)) hz)]
  rw [Finset.sum_congr rfl fun v _ => h v, ← Finset.sum_mul]
  have hs : ∑ v, ((P u v : ℝ) : ℂ) = 1 := by rw [← Complex.ofReal_sum, hrow u]; norm_num
  rw [hs, one_mul]

/-! ## A disproof: zero `p`-periodicity ratio does not pin down the period -/

/-- The directed `4`-cycle on `ZMod 4`. -/
def C4 : ZMod 4 → ZMod 4 → ℝ := fun u v => if v = u + 1 then 1 else 0

theorem C4_nonneg (u v : ZMod 4) : 0 ≤ C4 u v := by
  unfold C4; split_ifs <;> norm_num

theorem C4_reach_add {u v : ZMod 4} {n : ℕ} (h : Reach C4 u v n) : v = u + n := by
  induction h with
  | refl => simp
  | @step b c _ _ he ih =>
      by_cases hb : c = b + 1
      · rw [hb, ih]; push_cast; ring
      · simp [C4, hb] at he

theorem C4_reach_step (u : ZMod 4) (k : ℕ) : Reach C4 u (u + k) k := by
  induction k with
  | zero => simpa using Reach.refl u
  | succ n ih =>
      have he : C4 (u + n) (u + ((n : ZMod 4) + 1)) ≠ 0 := by simp [C4]; ring
      have h2 := Reach.step ih he
      have h3 : (u + ((n : ZMod 4) + 1)) = u + ((n + 1 : ℕ) : ZMod 4) := by push_cast; ring
      rwa [h3] at h2

theorem C4_strongly_connected (u v : ZMod 4) : ∃ n, Reach C4 u v n := by
  refine ⟨(v - u).val, ?_⟩
  have h := C4_reach_step u (v - u).val
  rwa [ZMod.natCast_val, ZMod.cast_id, add_sub_cancel] at h

/-- Every closed walk of the directed `4`-cycle has length divisible by `4`:
its period is `4`. -/
theorem C4_closed_walks (v : ZMod 4) (n : ℕ) (h : Reach C4 v v n) : 4 ∣ n := by
  have h1 := C4_reach_add h
  exact (ZMod.natCast_eq_zero_iff n 4).mp (add_eq_left.mp h1.symm)

theorem rotWeight_two : rotWeight 2 = -1 := by
  rw [rotWeight]
  have h : (2 * (Real.pi : ℂ) * Complex.I / ((2 : ℕ) : ℂ)) = Real.pi * Complex.I := by
    push_cast; ring
  rw [h, Complex.exp_pi_mul_I]

/-- The directed `4`-cycle has a zero-energy unimodular phase vector for `p = 2`. -/
theorem C4_zero_energy_two :
    ∃ x : ZMod 4 → ℂ, (∀ v, ‖x v‖ = 1) ∧ IsPhase (rotWeight 2) x ∧
      rotEnergy C4 (rotWeight 2) x = 0 := by
  refine ⟨fun v => (-1 : ℂ) ^ (ZMod.val v), fun v => by simp,
    fun v => Or.inr ⟨ZMod.val v, by rw [rotWeight_two]⟩, ?_⟩
  refine rotEnergy_eq_zero_of_edges ?_
  intro u v hne
  have hv : v = u + 1 := by by_contra h; simp [C4, h] at hne
  subst hv
  rw [rotWeight_two]
  fin_cases u <;> simp +decide

/-- **Disproof of the bold converse.**  There is a strongly connected digraph
with a unimodular zero-energy phase vector for `p = 2` in which *no* closed walk
has length `2` — indeed all closed walks have length divisible by `4`.  So a
vanishing `2`-periodicity ratio does not imply that the period is `2`; it only
implies that `2` divides the period. -/
theorem not_period_eq_of_zero_energy :
    ¬ ∀ (w : ZMod 4 → ZMod 4 → ℝ), (∀ u v, 0 ≤ w u v) →
      (∀ u v : ZMod 4, ∃ n, Reach w u v n) →
      (∃ x : ZMod 4 → ℂ, (∀ v, ‖x v‖ = 1) ∧ rotEnergy w (rotWeight 2) x = 0) →
      ∃ v : ZMod 4, Reach w v v 2 := by
  intro h
  obtain ⟨x, hx, -, h0⟩ := C4_zero_energy_two
  obtain ⟨v, hR⟩ := h C4 C4_nonneg C4_strongly_connected ((⟨x, hx, h0⟩ :
    ∃ x : ZMod 4 → ℂ, (∀ v, ‖x v‖ = 1) ∧ rotEnergy C4 (rotWeight 2) x = 0))
  have := C4_closed_walks v 2 hR
  norm_num at this

end RotatedLaplacian