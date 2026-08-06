/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Computation.WallpaperRhythm.OrbitCounting

/-!
# Entropy, strict capacity monotonicity, and toroidal descent

This file continues the orbit-counting analysis of symmetry-invariant rhythmic
patterns begun in `Computation.WallpaperRhythm.OrbitCounting`, and settles three
of the questions left open there.

## Main results

### Entropy beyond support size

`OrbitCounting.logb_card_groupInvariantPattern` computes the *uniform* capacity
of the space of `G`-invariant patterns: `#orbits` bits.  Here we equip that
space with an arbitrary probability distribution and prove the corresponding
probabilistic statement.

* `entropyBits` — Shannon entropy, in bits, of a distribution on a finite type.
* `entropyBits_le_logb_card` — the maximum-entropy bound `H(P) ≤ log₂ |β|`.
* `entropyBits_eq_logb_card_iff` — equality holds **iff** `P` is uniform.
* `entropyBits_le_card_orbits` and `entropyBits_eq_card_orbits_iff` — for
  distributions on `GroupInvariantPattern G α`, the entropy is at most the
  number of orbits (in bits), with equality exactly for the uniform pattern
  distribution.

### Strict antitonicity of capacity

`OrbitCounting.card_pattern_antitone` shows `H ≤ K → capacity K ≤ capacity H`.

* `card_orbitQuotient_lt` and `card_pattern_antitone_strict` — the inequality is
  *strict* as soon as `K` merges two cells that `H` keeps apart; conversely
  `card_pattern_eq_of_orbits_eq` shows that without such a merge the capacities
  coincide, so this is exactly the right condition.

### Canons as a falsifiable musical predicate

* `IsCanonAt` — a pattern reproduced by a time shift of `g`.
* `card_dvd_card_invariant_set` — a finite group acting freely on a finite type
  has order dividing the size of every invariant subset.
* `addOrderOf_dvd_onsetCount` — a canon at time distance `g` must have onset
  count divisible by the additive order of `g`.  This turns the informal label
  "canon" into a numerically refutable claim.

### Descent of the quarter turn to a torus

* `quarterTurn_mapsTo_torusLattice_iff` — the planar quarter turn
  `(t, n) ↦ (-n, t)` preserves the sublattice `pℤ × qℤ` (equivalently, descends
  to the `p × q` torus) **iff** `p = q`.
* `quarterTurnZMod_iterate_two`, `quarterTurnZMod_iterate_four` — on a square
  torus the quarter turn has order dividing four and its square is exactly the
  retrograde–inversion of `OrbitCounting`.
-/

namespace WallpaperRhythm
namespace OrbitEntropy

open MulAction Finset OrbitCounting

/-! ## Shannon entropy of a distribution on a finite type -/

/-- The Shannon entropy, measured in bits, of a real-valued weighting `P` of a
finite type.  For a probability distribution this is `∑ b, -P b * log₂ (P b)`. -/
noncomputable def entropyBits {β : Type*} [Fintype β] (P : β → ℝ) : ℝ :=
  (∑ b, Real.negMulLog (P b)) / Real.log 2

theorem entropyBits_def {β : Type*} [Fintype β] (P : β → ℝ) :
    entropyBits P = (∑ b, Real.negMulLog (P b)) / Real.log 2 := rfl

/-- **Maximum-entropy bound, natural-logarithm form.**  A probability
distribution on a finite type has `∑ -pᵢ log pᵢ ≤ log n`. -/
theorem sum_negMulLog_le_log_card {β : Type*} [Fintype β] [Nonempty β] (P : β → ℝ)
    (hP : ∀ b, 0 ≤ P b) (hsum : ∑ b, P b = 1) :
    ∑ b, Real.negMulLog (P b) ≤ Real.log (Fintype.card β) := by
  classical
  set n : ℕ := Fintype.card β with hn
  have hn0 : 0 < (n : ℝ) := by
    have : 0 < n := Fintype.card_pos
    exact_mod_cast this
  have key := Real.concaveOn_negMulLog.le_map_sum (t := (univ : Finset β))
    (w := fun _ => (n : ℝ)⁻¹) (p := P)
    (fun i _ => by positivity) (by simp [hn]) (fun i _ => hP i)
  simp only [smul_eq_mul] at key
  rw [← Finset.mul_sum, ← Finset.mul_sum, hsum, mul_one] at key
  have h2 : Real.negMulLog ((n : ℝ)⁻¹) = (n : ℝ)⁻¹ * Real.log n := by
    rw [Real.negMulLog, Real.log_inv]; ring
  rw [h2] at key
  have h3 := mul_le_mul_of_nonneg_left key (le_of_lt hn0)
  rwa [← mul_assoc, ← mul_assoc, mul_inv_cancel₀ (ne_of_gt hn0), one_mul, one_mul] at h3

/-- **Equality case of the maximum-entropy bound.**  A probability distribution
on a finite type attains `∑ -pᵢ log pᵢ = log n` exactly when it is uniform. -/
theorem sum_negMulLog_eq_log_card_iff {β : Type*} [Fintype β] [Nonempty β] (P : β → ℝ)
    (hP : ∀ b, 0 ≤ P b) (hsum : ∑ b, P b = 1) :
    ∑ b, Real.negMulLog (P b) = Real.log (Fintype.card β) ↔
      ∀ b, P b = ((Fintype.card β : ℝ))⁻¹ := by
  classical
  set n : ℕ := Fintype.card β with hn
  have hn0 : 0 < (n : ℝ) := by
    have : 0 < n := Fintype.card_pos
    exact_mod_cast this
  have hw1 : ∑ _i : β, (n : ℝ)⁻¹ = 1 := by simp [hn]
  have key := Real.strictConcaveOn_negMulLog.map_sum_eq_iff (t := (univ : Finset β))
    (w := fun _ => (n : ℝ)⁻¹) (p := P)
    (fun i _ => by positivity) hw1 (fun i _ => hP i)
  simp only [smul_eq_mul, ← Finset.mul_sum, hsum, mul_one] at key
  have h2 : Real.negMulLog ((n : ℝ)⁻¹) = (n : ℝ)⁻¹ * Real.log n := by
    rw [Real.negMulLog, Real.log_inv]; ring
  rw [h2] at key
  rw [show (∀ b, P b = ((n : ℝ))⁻¹) ↔ (∀ b ∈ (univ : Finset β), P b = ((n : ℝ))⁻¹) by simp,
    ← key]
  constructor
  · intro h; rw [h]
  · intro h
    exact (mul_left_cancel₀ (inv_ne_zero (ne_of_gt hn0)) h).symm

/-- **Maximum-entropy bound in bits.** -/
theorem entropyBits_le_logb_card {β : Type*} [Fintype β] [Nonempty β] (P : β → ℝ)
    (hP : ∀ b, 0 ≤ P b) (hsum : ∑ b, P b = 1) :
    entropyBits P ≤ Real.logb 2 (Fintype.card β) := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [entropyBits_def, Real.logb, div_le_div_iff_of_pos_right hlog2]
  exact sum_negMulLog_le_log_card P hP hsum

/-- **Equality case in bits:** the entropy of a distribution equals the
log-cardinality exactly for the uniform distribution. -/
theorem entropyBits_eq_logb_card_iff {β : Type*} [Fintype β] [Nonempty β] (P : β → ℝ)
    (hP : ∀ b, 0 ≤ P b) (hsum : ∑ b, P b = 1) :
    entropyBits P = Real.logb 2 (Fintype.card β) ↔ ∀ b, P b = ((Fintype.card β : ℝ))⁻¹ := by
  have hlog2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  rw [entropyBits_def, Real.logb, div_left_inj' hlog2]
  exact sum_negMulLog_eq_log_card_iff P hP hsum

/-- The uniform distribution on a finite type has entropy exactly `log₂ n` bits. -/
theorem entropyBits_uniform {β : Type*} [Fintype β] [Nonempty β] :
    entropyBits (fun _ : β => ((Fintype.card β : ℝ))⁻¹) = Real.logb 2 (Fintype.card β) := by
  have hne : (0 : ℝ) < Fintype.card β := by
    exact_mod_cast Fintype.card_pos (α := β)
  refine (entropyBits_eq_logb_card_iff _ (fun _ => by positivity) ?_).2 (fun _ => rfl)
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-! ## Entropy of a distribution on the space of invariant patterns -/

variable {G : Type*} [Group G] {α : Type*} [MulAction G α]

noncomputable instance groupInvariantPatternFintype [Fintype α] :
    Fintype (GroupInvariantPattern G α) :=
  inferInstanceAs (Fintype (InvariantPattern α (orbitSetoid G α)))

instance groupInvariantPatternNonempty : Nonempty (GroupInvariantPattern G α) :=
  ⟨⟨fun _ => false, fun _ _ _ => rfl⟩⟩

theorem card_groupInvariantPattern_fintype [Fintype α] :
    (Fintype.card (GroupInvariantPattern G α) : ℝ) = 2 ^ Nat.card (orbitRel.Quotient G α) := by
  have h : Nat.card (GroupInvariantPattern G α) = 2 ^ Nat.card (orbitRel.Quotient G α) :=
    card_groupInvariantPattern
  rw [Nat.card_eq_fintype_card] at h
  exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) h

/-- **Entropy bound for invariant patterns.**  Any probability distribution on the
space of `G`-invariant binary patterns has Shannon entropy at most the number of
`G`-orbits of cells, in bits.  This upgrades the uniform capacity computation
`logb_card_groupInvariantPattern` to a genuinely probabilistic statement. -/
theorem entropyBits_le_card_orbits [Fintype α] (P : GroupInvariantPattern G α → ℝ)
    (hP : ∀ f, 0 ≤ P f) (hsum : ∑ f, P f = 1) :
    entropyBits P ≤ (Nat.card (orbitRel.Quotient G α) : ℝ) := by
  refine (entropyBits_le_logb_card P hP hsum).trans_eq ?_
  rw [card_groupInvariantPattern_fintype (G := G) (α := α), Real.logb_pow,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
  ring

/-- **Equality case.**  The orbit count is attained exactly by the uniform
distribution on invariant patterns; every other distribution is strictly less
informative. -/
theorem entropyBits_eq_card_orbits_iff [Fintype α] (P : GroupInvariantPattern G α → ℝ)
    (hP : ∀ f, 0 ≤ P f) (hsum : ∑ f, P f = 1) :
    entropyBits P = (Nat.card (orbitRel.Quotient G α) : ℝ) ↔
      ∀ f, P f = ((Fintype.card (GroupInvariantPattern G α) : ℝ))⁻¹ := by
  have hval : Real.logb 2 (Fintype.card (GroupInvariantPattern G α)) =
      (Nat.card (orbitRel.Quotient G α) : ℝ) := by
    rw [card_groupInvariantPattern_fintype (G := G) (α := α), Real.logb_pow,
      Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
    ring
  rw [← hval]
  exact entropyBits_eq_logb_card_iff P hP hsum

/-! ## Strict antitonicity of capacity -/

/-- A surjection between finite types that is not injective strictly decreases
cardinality. -/
theorem nat_card_lt_of_surjective_not_injective {A B : Type*} [Finite A] (f : A → B)
    (hs : Function.Surjective f) (hi : ¬ Function.Injective f) :
    Nat.card B < Nat.card A := by
  haveI : Finite B := Finite.of_surjective f hs
  rcases lt_or_ge (Nat.card B) (Nat.card A) with h | h
  · exact h
  · exact absurd
      (((Nat.bijective_iff_surjective_and_card f).2
        ⟨hs, le_antisymm (Nat.card_le_card_of_surjective f hs) h |>.symm⟩).1) hi

/-- If the larger group `K` merges two cells that the smaller group `H` keeps in
different orbits, then `K` has strictly fewer orbits. -/
theorem card_orbitQuotient_lt {H K : Subgroup G} (hHK : H ≤ K) [Finite α] {a b : α}
    (hK : ∃ k : K, k • a = b) (hH : ¬ ∃ h : H, h • a = b) :
    Nat.card (orbitRel.Quotient K α) < Nat.card (orbitRel.Quotient H α) := by
  refine nat_card_lt_of_surjective_not_injective _ (orbitQuotientMap_surjective (α := α) hHK) ?_
  intro hinj
  apply hH
  have hb : (orbitQuotientMap (α := α) hHK) (Quotient.mk'' b) =
      (orbitQuotientMap (α := α) hHK) (Quotient.mk'' a) := by
    obtain ⟨k, hk⟩ := hK
    exact Quotient.sound' ⟨k, hk⟩
  have := hinj hb
  have hrel : (orbitRel H α).r b a := Quotient.exact' this
  obtain ⟨h, hh⟩ := hrel
  exact ⟨h, hh⟩

/-- **Capacity is strictly antitone under a genuine gain of symmetry.**  If `H ≤ K`
and `K` identifies two cells that `H` separates, then strictly fewer patterns are
`K`-invariant than `H`-invariant. -/
theorem card_pattern_antitone_strict {H K : Subgroup G} (hHK : H ≤ K) [Finite α] {a b : α}
    (hK : ∃ k : K, k • a = b) (hH : ¬ ∃ h : H, h • a = b) :
    Nat.card (GroupInvariantPattern K α) < Nat.card (GroupInvariantPattern H α) := by
  rw [card_groupInvariantPattern, card_groupInvariantPattern]
  exact Nat.pow_lt_pow_right (by norm_num) (card_orbitQuotient_lt hHK hK hH)

/-- The converse bookkeeping: if the orbit maps agree on all pairs then the
capacities agree.  Together with `card_pattern_antitone_strict` this pins down
exactly when extra symmetry costs capacity. -/
theorem card_pattern_eq_of_orbits_eq {H K : Subgroup G} (hHK : H ≤ K) [Finite α]
    (hsame : ∀ a b : α, (∃ k : K, k • a = b) → (∃ h : H, h • a = b)) :
    Nat.card (GroupInvariantPattern K α) = Nat.card (GroupInvariantPattern H α) := by
  rw [card_groupInvariantPattern, card_groupInvariantPattern]
  congr 1
  refine (Nat.card_eq_of_bijective (orbitQuotientMap (α := α) hHK)
    ⟨?_, orbitQuotientMap_surjective hHK⟩).symm
  intro x y hxy
  induction x using Quotient.inductionOn' with
  | _ a =>
    induction y using Quotient.inductionOn' with
    | _ b =>
      have hrel : (orbitRel K α).r a b := Quotient.exact' hxy
      obtain ⟨k, hk⟩ := hrel
      obtain ⟨h, hh⟩ := hsame b a ⟨k, hk⟩
      exact Quotient.sound' ⟨h, hh⟩

/-- A concrete strict drop: on the four-beat single-pitch grid, requiring
invariance under the full shift group leaves strictly fewer patterns than
requiring nothing. -/
theorem card_pattern_shift_lt_card_pattern_bot :
    Nat.card (GroupInvariantPattern (⊤ : Subgroup (Multiplicative (ZMod 4))) (ZMod 4 × ZMod 1)) <
      Nat.card (GroupInvariantPattern (⊥ : Subgroup (Multiplicative (ZMod 4)))
        (ZMod 4 × ZMod 1)) := by
  refine card_pattern_antitone_strict (a := (0, 0)) (b := (1, 0)) le_top
    ⟨⟨Multiplicative.ofAdd 1, trivial⟩, by decide⟩ ?_
  rintro ⟨⟨h, hh⟩, hgh⟩
  rw [Subgroup.mem_bot] at hh
  subst hh
  have h1 : (⟨1, hh⟩ : (⊥ : Subgroup (Multiplicative (ZMod 4)))) = 1 := rfl
  rw [h1, one_smul] at hgh
  exact absurd hgh (by decide)

/-! ## Canons: a falsifiable predicate for a named musical structure -/

/-- The number of onsets of a binary pattern. -/
noncomputable def onsetCount {β : Type*} (f : β → Bool) : ℕ := Nat.card {a : β // f a = true}

/-- **A free action divides an invariant set.**  If a finite group acts freely on a
finite type, then its order divides the cardinality of every invariant subset. -/
theorem card_dvd_card_invariant_set {G : Type*} [Group G] [Finite G] {α : Type*} [Finite α]
    [MulAction G α] (hfree : ∀ (g : G) (a : α), g • a = a → g = 1)
    (S : Set α) (hS : ∀ (g : G) (a : α), a ∈ S → g • a ∈ S) :
    Nat.card G ∣ Nat.card S := by
  classical
  letI : MulAction G S :=
    { smul := fun g a => ⟨g • (a : α), hS g a a.2⟩
      one_smul := fun a => Subtype.ext (one_smul G (a : α))
      mul_smul := fun g h a => Subtype.ext (mul_smul g h (a : α)) }
  have hsm : ∀ (g : G) (a : S), ((g • a : S) : α) = g • (a : α) := fun _ _ => rfl
  have hst : ∀ b : S, stabilizer G b = ⊥ := by
    intro b
    ext g
    simp only [mem_stabilizer_iff, Subgroup.mem_bot]
    constructor
    · intro h
      exact hfree g (b : α) (by rw [← hsm g b, h])
    · rintro rfl; simp
  have hcard := Nat.card_congr (MulAction.selfEquivOrbitsQuotientProd (α := G) (β := S) hst)
  rw [Nat.card_prod] at hcard
  exact ⟨_, by rw [hcard]; ring⟩

/-- **A canon.**  A time–pitch pattern on the `p × q` torus is a canon at time
distance `g` when shifting every voice forward by `g` reproduces the pattern.
This is a formal, falsifiable rendering of the informal musical word: it is a
property a given pattern either has or does not have. -/
def IsCanonAt {p q : ℕ} (f : ZMod p × ZMod q → Bool) (g : ZMod p) : Prop :=
  ∀ v : ZMod p × ZMod q, f (v.1 + g, v.2) = f v

theorem isCanonAt_iff_mem_symmetryGroup {p q : ℕ} (f : ZMod p × ZMod q → Bool) (g : ZMod p) :
    IsCanonAt f g ↔ Multiplicative.ofAdd g ∈ symmetryGroup (Multiplicative (ZMod p)) f :=
  Iff.rfl

/-- **Canon divisibility.**  If a pattern is a canon at time distance `g`, then its
number of onsets is a multiple of the additive order of `g`.  In particular a
nontrivial canon constrains the onset count, so the musical label is refutable by
counting onsets. -/
theorem addOrderOf_dvd_onsetCount {p q : ℕ} [NeZero p] [NeZero q]
    (f : ZMod p × ZMod q → Bool) (g : ZMod p) (hcanon : IsCanonAt f g) :
    addOrderOf g ∣ onsetCount f := by
  classical
  set G := Multiplicative (ZMod p)
  set x : G := Multiplicative.ofAdd g with hx
  set H := Subgroup.zpowers x with hH
  have hle : H ≤ symmetryGroup G f :=
    Subgroup.zpowers_le.2 ((isCanonAt_iff_mem_symmetryGroup f g).1 hcanon)
  have hfree : ∀ (h : H) (a : ZMod p × ZMod q), h • a = a → h = 1 := by
    intro h a ha
    have ha' : ((h : G)) • a = a := ha
    have h1 : (h : G) = 1 := by
      by_contra hne
      have := fixedBy_timeShift_eq_empty p q (h : G) hne
      have hmem : a ∈ fixedBy (ZMod p × ZMod q) (h : G) := ha'
      rw [this] at hmem
      exact hmem
    exact Subtype.ext h1
  have hS : ∀ (h : H) (a : ZMod p × ZMod q), a ∈ {v | f v = true} → h • a ∈ {v | f v = true} := by
    intro h a ha
    have hinv := hle h.2 a
    show f ((h : G) • a) = true
    rw [hinv]
    exact ha
  have hdvd := card_dvd_card_invariant_set hfree {v | f v = true} hS
  rwa [hH, Nat.card_zpowers, hx, orderOf_ofAdd_eq_addOrderOf] at hdvd

/-- A canon at a generating time distance on a `p`-beat cycle forces the onset
count to be a multiple of `p`. -/
theorem card_dvd_onsetCount_of_generator {p q : ℕ} [NeZero p] [NeZero q]
    (f : ZMod p × ZMod q → Bool) (g : ZMod p) (hgen : addOrderOf g = p)
    (hcanon : IsCanonAt f g) : p ∣ onsetCount f := by
  have hdvd := addOrderOf_dvd_onsetCount f g hcanon
  rwa [hgen] at hdvd

/-- The backbeat is a canon at the half-bar distance `2`, and indeed its onset
count `2` is a multiple of the order of `2` in `ZMod 4`. -/
theorem isCanonAt_backbeat : IsCanonAt backbeat 2 := by
  intro v
  revert v
  decide

theorem onsetCount_backbeat : onsetCount backbeat = 2 := by
  rw [onsetCount, Nat.card_eq_fintype_card]
  decide

/-- The divisibility constraint is visible in the worked example: the backbeat is
a canon at distance `2`, and its two onsets are indeed a multiple of
`addOrderOf (2 : ZMod 4) = 2`. -/
theorem addOrderOf_two_dvd_onsetCount_backbeat :
    addOrderOf (2 : ZMod 4) ∣ onsetCount backbeat :=
  addOrderOf_dvd_onsetCount backbeat 2 isCanonAt_backbeat

/-! ## Descent of the planar quarter turn to a torus

A time–pitch grid of period `p` in time and `q` in pitch is the quotient of the
plane lattice `ℤ × ℤ` by the sublattice `pℤ × qℤ`.  A planar symmetry descends to
the torus exactly when it preserves that sublattice.  We settle this for the
quarter turn. -/

/-- The planar quarter turn `(t, n) ↦ (-n, t)` on the integer time–pitch lattice. -/
def quarterTurn (v : ℤ × ℤ) : ℤ × ℤ := (-v.2, v.1)

/-- The sublattice `pℤ × qℤ` whose quotient is the `p × q` torus. -/
def torusLattice (p q : ℕ) : Set (ℤ × ℤ) := {v | (p : ℤ) ∣ v.1 ∧ (q : ℤ) ∣ v.2}

/-- **Quarter-turn descent criterion.**  The quarter turn preserves the sublattice
`pℤ × qℤ` — equivalently, it descends to a well-defined map of the `p × q`
time–pitch torus — if and only if the two periods agree. -/
theorem quarterTurn_mapsTo_torusLattice_iff (p q : ℕ) :
    (∀ v ∈ torusLattice p q, quarterTurn v ∈ torusLattice p q) ↔ p = q := by
  constructor
  · intro h
    have h1 := h ((p : ℤ), 0) ⟨dvd_refl _, dvd_zero _⟩
    have h2 := h (0, (q : ℤ)) ⟨dvd_zero _, dvd_refl _⟩
    have hqp : (q : ℤ) ∣ (p : ℤ) := h1.2
    have hpq : (p : ℤ) ∣ (q : ℤ) := by
      have := h2.1
      exact (dvd_neg.mp this)
    exact Nat.dvd_antisymm (Int.natCast_dvd_natCast.mp hpq) (Int.natCast_dvd_natCast.mp hqp)
  · rintro rfl v ⟨hv1, hv2⟩
    exact ⟨(dvd_neg).mpr hv2, hv1⟩

/-- The quarter turn on a square torus. -/
def quarterTurnZMod (p : ℕ) (v : ZMod p × ZMod p) : ZMod p × ZMod p := (-v.2, v.1)

/-- The quarter turn is compatible with reduction of the plane lattice modulo the
square sublattice: it really is the descended map. -/
theorem quarterTurnZMod_comp_reduce (p : ℕ) (v : ℤ × ℤ) :
    quarterTurnZMod p (((v.1 : ZMod p)), ((v.2 : ZMod p))) =
      ((((quarterTurn v).1 : ℤ) : ZMod p), (((quarterTurn v).2 : ℤ) : ZMod p)) := by
  simp [quarterTurnZMod, quarterTurn]

/-- The square of the quarter turn is the retrograde–inversion `(t, n) ↦ (-t, -n)`
studied in `OrbitCounting`. -/
theorem quarterTurnZMod_iterate_two (p : ℕ) (v : ZMod p × ZMod p) :
    (quarterTurnZMod p)^[2] v = -v := by
  simp [quarterTurnZMod, Function.iterate_succ_apply, Prod.ext_iff]

/-- The quarter turn has order dividing four. -/
theorem quarterTurnZMod_iterate_four (p : ℕ) (v : ZMod p × ZMod p) :
    (quarterTurnZMod p)^[4] v = v := by
  simp [quarterTurnZMod, Function.iterate_succ_apply]

end OrbitEntropy
end WallpaperRhythm