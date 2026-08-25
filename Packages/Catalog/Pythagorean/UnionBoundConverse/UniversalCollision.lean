import Pythagorean.UnionBoundConverse.FiniteLaw

/-!
# The extremal collision probability of a `2`-universal family

Let `h : Ω → K → V` be a family of hash functions indexed by a finite
probability space `(Ω, L)`, with `|V| = m` buckets, and let `S` be a finite set
of `n ≥ 2` keys.  Write

`Coll = { o : some two distinct keys of S collide under h o }`.

Two classical hypotheses are considered:

* `Sub2Universal` (Carter–Wegman `2`-universality): `P(h x = h y) ≤ 1/m` for
  distinct `x, y ∈ S`;
* `Exactly2Universal`: `P(h x = h y) = 1/m` for distinct `x, y ∈ S`
  (satisfied by every pairwise independent family).

The **union bound** gives the upper endpoint `P(Coll) ≤ C(n,2)/m`
(`collisionProb_le_choose_div`).  The main theorem of this file is the
**matching lower endpoint**, a converse to the union bound valid for *every*
exactly `2`-universal family:

`inv_card_le_collisionProb : 1/m ≤ P(Coll)`.

Its proof is a reverse Markov inequality applied to the *number* of colliding
ordered pairs: that count has expectation exactly `n(n-1)/m` and is bounded by
`n(n-1)`, so it must be positive with probability at least `1/m`.

The constant `1/m` cannot be improved: `affine_collisionProb` shows that the
Carter–Wegman affine family `x ↦ a x + b` over `ZMod p` is exactly
`2`-universal with collision probability *equal* to `1/p` for every key set,
however large.  Consequently

`isLeast_collisionProb : IsLeast (achievableCollisionProbs p S) (1/p)`,

an exact determination of the extremal value: over all `2`-universal families
the collision probability can be pushed down to `1/m`, but never below.  Two
further refinements are proved: a second-moment (Chung–Erdős) lower bound, and
the pigeonhole degeneration `P(Coll) = 1` when `n > m`.
-/

namespace UnionBoundConverse

open Finset

variable {Ω K V : Type*} [Fintype Ω] [Fintype V] [DecidableEq K] [DecidableEq V]

/-- A probability law lives on a nonempty type. -/
theorem FinLaw.nonempty (L : FinLaw Ω) : Nonempty Ω := by
  by_contra hc
  have hzero : ∑ o : Ω, L.w o = 0 :=
    Finset.sum_eq_zero fun o _ => absurd ⟨o⟩ hc
  rw [L.w_total] at hzero
  exact one_ne_zero hzero

/-- The event that the hash function indexed by `o` fails to be injective on the
key set `S`. -/
def Collides (h : Ω → K → V) (S : Finset K) (o : Ω) : Prop :=
  ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧ h o x = h o y

/-- The number of *ordered* pairs of distinct keys of `S` that collide. -/
noncomputable def collisionCount (h : Ω → K → V) (S : Finset K) (o : Ω) : ℝ :=
  ((S.offDiag.filter (fun q => h o q.1 = h o q.2)).card : ℝ)

/-- Carter–Wegman `2`-universality on the key set `S`. -/
def Sub2Universal (L : FinLaw Ω) (h : Ω → K → V) (S : Finset K) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, x ≠ y → L.prob (fun o => h o x = h o y) ≤ 1 / (Fintype.card V : ℝ)

/-- Exact `2`-universality on the key set `S`: every pair of distinct keys
collides with probability exactly `1/m`.  Every pairwise independent
(*strongly* `2`-universal) family has this property. -/
def Exactly2Universal (L : FinLaw Ω) (h : Ω → K → V) (S : Finset K) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, x ≠ y → L.prob (fun o => h o x = h o y) = 1 / (Fintype.card V : ℝ)

omit [DecidableEq K] [DecidableEq V] in
theorem Exactly2Universal.sub {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hu : Exactly2Universal L h S) : Sub2Universal L h S :=
  fun x hx y hy hne => (hu x hx y hy hne).le

/-! ### The collision counter -/

omit [Fintype Ω] [Fintype V] [DecidableEq K] in
theorem collisionCount_eq_sum (h : Ω → K → V) (S : Finset K) (o : Ω) :
    collisionCount h S o = ∑ q ∈ S.offDiag, ind (h o q.1 = h o q.2) := by
  rw [collisionCount, Finset.card_filter]
  push_cast
  exact Finset.sum_congr rfl fun q _ => by by_cases hq : h o q.1 = h o q.2 <;> simp [hq]

omit [Fintype Ω] [Fintype V] [DecidableEq K] in
theorem collisionCount_nonneg (h : Ω → K → V) (S : Finset K) (o : Ω) :
    0 ≤ collisionCount h S o := Nat.cast_nonneg _

omit [Fintype Ω] [Fintype V] [DecidableEq K] in
theorem collisionCount_le (h : Ω → K → V) (S : Finset K) (o : Ω) :
    collisionCount h S o ≤ (S.offDiag.card : ℝ) := by
  rw [collisionCount]
  exact_mod_cast Finset.card_filter_le _ _

omit [Fintype Ω] [Fintype V] [DecidableEq K] in
theorem collisionCount_pos_iff (h : Ω → K → V) (S : Finset K) (o : Ω) :
    0 < collisionCount h S o ↔ Collides h S o := by
  rw [collisionCount]
  constructor
  · intro hpos
    have : (S.offDiag.filter (fun q => h o q.1 = h o q.2)).Nonempty := by
      rw [← Finset.card_pos]; exact_mod_cast hpos
    obtain ⟨q, hq⟩ := this
    rw [Finset.mem_filter, Finset.mem_offDiag] at hq
    exact ⟨q.1, hq.1.1, q.2, hq.1.2.1, hq.1.2.2, hq.2⟩
  · rintro ⟨x, hx, y, hy, hne, heq⟩
    have hmem : (x, y) ∈ S.offDiag.filter (fun q => h o q.1 = h o q.2) :=
      Finset.mem_filter.mpr ⟨Finset.mem_offDiag.mpr ⟨hx, hy, hne⟩, heq⟩
    have : 0 < (S.offDiag.filter (fun q => h o q.1 = h o q.2)).card :=
      Finset.card_pos.mpr ⟨_, hmem⟩
    exact_mod_cast this

omit [Fintype V] [DecidableEq K] in
/-- The expectation of the collision counter is the sum, over ordered pairs of
distinct keys, of the pair collision probabilities: linearity of expectation. -/
theorem exp_collisionCount_eq_sum (L : FinLaw Ω) (h : Ω → K → V) (S : Finset K) :
    L.exp (collisionCount h S)
      = ∑ q ∈ S.offDiag, L.prob (fun o => h o q.1 = h o q.2) := by
  have hrw : L.exp (collisionCount h S)
      = L.exp (fun o => ∑ q ∈ S.offDiag, ind (h o q.1 = h o q.2)) :=
    FinLaw.exp_congr fun o => collisionCount_eq_sum h S o
  rw [hrw, FinLaw.exp_sum]
  rfl

omit [DecidableEq K] in
/-- The expected number of colliding ordered pairs of an exactly `2`-universal
family is `n(n-1)/m`. -/
theorem exp_collisionCount {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hu : Exactly2Universal L h S) :
    L.exp (collisionCount h S) = (S.offDiag.card : ℝ) / (Fintype.card V : ℝ) := by
  rw [exp_collisionCount_eq_sum]
  have : ∀ q ∈ S.offDiag, L.prob (fun o => h o q.1 = h o q.2)
      = 1 / (Fintype.card V : ℝ) := by
    intro q hq
    rw [Finset.mem_offDiag] at hq
    exact hu q.1 hq.1 q.2 hq.2.1 hq.2.2
  rw [Finset.sum_congr rfl this, Finset.sum_const, nsmul_eq_mul]
  ring

/-! ### The two endpoints -/

omit [DecidableEq V] in
/-- **Union bound endpoint.**  For a Carter–Wegman `2`-universal family the
probability of a collision among `n` keys is at most `C(n,2)/m`. -/
theorem collisionProb_le_choose_div {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hu : Sub2Universal L h S) :
    L.prob (Collides h S) ≤ (S.card.choose 2 : ℝ) / (Fintype.card V : ℝ) := by
  classical
  set A : Finset K → Ω → Prop := fun T o => ∃ x ∈ T, ∃ y ∈ T, x ≠ y ∧ h o x = h o y with hA
  have hstep : L.prob (Collides h S) ≤ L.prob (fun o => ∃ T ∈ S.powersetCard 2, A T o) := by
    refine FinLaw.prob_mono fun o hcol => ?_
    obtain ⟨x, hx, y, hy, hne, heq⟩ := hcol
    refine ⟨{x, y}, Finset.mem_powersetCard.mpr ⟨?_, ?_⟩, ?_⟩
    · intro z hz
      rcases Finset.mem_insert.mp hz with rfl | hz'
      · exact hx
      · rw [Finset.mem_singleton] at hz'; exact hz' ▸ hy
    · rw [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]
    · exact ⟨x, by simp, y, by simp, hne, heq⟩
  refine hstep.trans ((FinLaw.prob_exists_le_sum _ _).trans ?_)
  have hterm : ∀ T ∈ S.powersetCard 2, L.prob (A T) ≤ 1 / (Fintype.card V : ℝ) := by
    intro T hT
    rw [Finset.mem_powersetCard] at hT
    obtain ⟨x, y, hxy, rfl⟩ := Finset.card_eq_two.mp hT.2
    have hx : x ∈ S := hT.1 (by simp)
    have hy : y ∈ S := hT.1 (by simp)
    have hcongr : L.prob (A {x, y}) = L.prob (fun o => h o x = h o y) := by
      refine FinLaw.prob_congr fun o => ⟨?_, ?_⟩
      · rintro ⟨u, hu, v, hv, hne, heq⟩
        have hu' : u = x ∨ u = y := by simpa using hu
        have hv' : v = x ∨ v = y := by simpa using hv
        rcases hu' with rfl | rfl <;> rcases hv' with rfl | rfl
        · exact absurd rfl hne
        · exact heq
        · exact heq.symm
        · exact absurd rfl hne
      · intro heq; exact ⟨x, by simp, y, by simp, hxy, heq⟩
    rw [hcongr]
    exact hu x hx y hy hxy
  calc ∑ T ∈ S.powersetCard 2, L.prob (A T)
      ≤ ∑ _T ∈ S.powersetCard 2, 1 / (Fintype.card V : ℝ) := Finset.sum_le_sum hterm
    _ = (S.card.choose 2 : ℝ) / (Fintype.card V : ℝ) := by
        rw [Finset.sum_const, nsmul_eq_mul, Finset.card_powersetCard]
        ring

omit [DecidableEq K] in
/-- The off-diagonal of a set with at least two elements is nonempty. -/
theorem offDiag_card_pos {S : Finset K} (hS : 2 ≤ S.card) : 0 < (S.offDiag.card : ℝ) := by
  have hnat : 0 < S.offDiag.card := by
    rw [Finset.offDiag_card]
    nlinarith [Nat.sub_pos_of_lt (show S.card < S.card * S.card by nlinarith)]
  exact_mod_cast hnat

omit [Fintype V] [DecidableEq K] in
/-- **The general converse bound.**  If every pair of distinct keys of `S`
collides with probability at least `δ`, then a collision occurs somewhere in `S`
with probability at least `δ` — however many keys there are.  This is a genuine
converse to the union bound: the union of many rare events cannot be *less*
likely than a single one of them, and for the collision structure no dilution
beyond the single-pair probability is possible. -/
theorem collisionProb_ge_of_pairwise_lower {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    {δ : ℝ} (hS : 2 ≤ S.card)
    (hlow : ∀ x ∈ S, ∀ y ∈ S, x ≠ y → δ ≤ L.prob (fun o => h o x = h o y)) :
    δ ≤ L.prob (Collides h S) := by
  have hDpos : 0 < (S.offDiag.card : ℝ) := offDiag_card_pos hS
  have hE : (S.offDiag.card : ℝ) * δ ≤ L.exp (collisionCount h S) := by
    rw [exp_collisionCount_eq_sum]
    have hterm : ∀ q ∈ S.offDiag, δ ≤ L.prob (fun o => h o q.1 = h o q.2) := by
      intro q hq
      rw [Finset.mem_offDiag] at hq
      exact hlow q.1 hq.1 q.2 hq.2.1 hq.2.2
    calc (S.offDiag.card : ℝ) * δ = ∑ _q ∈ S.offDiag, δ := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ _ := Finset.sum_le_sum hterm
  have hmarkov := FinLaw.prob_pos_ge_of_bounded (L := L) (f := collisionCount h S)
      hDpos (collisionCount_nonneg h S) (collisionCount_le h S)
  have hcongr : L.prob (fun o => 0 < collisionCount h S o) = L.prob (Collides h S) :=
    FinLaw.prob_congr fun o => collisionCount_pos_iff h S o
  rw [hcongr] at hmarkov
  refine le_trans ?_ hmarkov
  rw [le_div_iff₀ hDpos]
  linarith [hE]

omit [DecidableEq K] in
/-- **Converse endpoint: the main theorem.**  Every exactly `2`-universal family
collides on any `n ≥ 2` keys with probability at least `1/m`, no matter how
large the bucket space or how few the keys.  The union bound cannot be pushed
below this. -/
theorem inv_card_le_collisionProb {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hS : 2 ≤ S.card) (hu : Exactly2Universal L h S) :
    1 / (Fintype.card V : ℝ) ≤ L.prob (Collides h S) :=
  collisionProb_ge_of_pairwise_lower hS
    fun x hx y hy hne => (hu x hx y hy hne).ge

/-- **The birthday sandwich.**  For an exactly `2`-universal family the
collision probability is pinned between `1/m` and `C(n,2)/m`. -/
theorem collisionProb_sandwich {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hS : 2 ≤ S.card) (hu : Exactly2Universal L h S) :
    1 / (Fintype.card V : ℝ) ≤ L.prob (Collides h S) ∧
      L.prob (Collides h S) ≤ (S.card.choose 2 : ℝ) / (Fintype.card V : ℝ) :=
  ⟨inv_card_le_collisionProb hS hu, collisionProb_le_choose_div hu.sub⟩

omit [DecidableEq K] [DecidableEq V] in
/-- **Pigeonhole degeneration.**  With more keys than buckets every hash
function collides, so the collision probability is `1` for *any* family. -/
theorem collisionProb_eq_one_of_card_lt (L : FinLaw Ω) (h : Ω → K → V) {S : Finset K}
    (hlt : Fintype.card V < S.card) : L.prob (Collides h S) = 1 := by
  refine FinLaw.prob_eq_one_of_forall fun o => ?_
  have hcard : (Finset.univ : Finset V).card < S.card := by simpa using hlt
  obtain ⟨x, hx, y, hy, hne, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard (fun a _ => Finset.mem_univ (h o a))
  exact ⟨x, hx, y, hy, hne, heq⟩

omit [DecidableEq K] in
/-- **Second-moment (Chung–Erdős) refinement.**  The collision probability is at
least `E[X]² / E[X²]` where `X` counts colliding ordered pairs.  Whenever the
second moment of the collision counter is smaller than `n(n-1)·E[X]`, this
improves on the universal bound `1/m`. -/
theorem collisionProb_ge_second_moment {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hu : Exactly2Universal L h S) (hpos : 0 < L.exp (fun o => collisionCount h S o ^ 2)) :
    ((S.offDiag.card : ℝ) / (Fintype.card V : ℝ)) ^ 2 /
        L.exp (fun o => collisionCount h S o ^ 2) ≤ L.prob (Collides h S) := by
  have hCS := FinLaw.sq_exp_le_exp_sq_mul_prob_pos (L := L) (f := collisionCount h S)
    (collisionCount_nonneg h S)
  rw [exp_collisionCount hu] at hCS
  have hcongr : L.prob (fun o => 0 < collisionCount h S o) = L.prob (Collides h S) :=
    FinLaw.prob_congr fun o => collisionCount_pos_iff h S o
  rw [hcongr] at hCS
  rw [div_le_iff₀ hpos]
  linarith [hCS]

/-! ### Sharpness: the Carter–Wegman affine family over `ZMod p` -/

section Affine

variable (p : ℕ) [Fact p.Prime]

/-- The Carter–Wegman affine hash family `x ↦ a x + b` over `ZMod p`, indexed by
the pair `(a, b)`. -/
def affineHash : ZMod p × ZMod p → ZMod p → ZMod p := fun ab x => ab.1 * x + ab.2

/-- The uniform law on the index set of the affine family. -/
noncomputable def affineLaw : FinLaw (ZMod p × ZMod p) := FinLaw.uniform _

theorem card_zmod_prod : Fintype.card (ZMod p × ZMod p) = p * p := by
  simp [Fintype.card_prod, ZMod.card]

/-- Two distinct keys collide under the affine family exactly on the `p` indices
with `a = 0`; hence the family is exactly `2`-universal. -/
theorem affine_exactly2Universal (S : Finset (ZMod p)) :
    Exactly2Universal (affineLaw p) (affineHash p) S := by
  classical
  intro x _ y _ hne
  have hfilter : (Finset.univ.filter
      (fun ab : ZMod p × ZMod p => affineHash p ab x = affineHash p ab y))
      = ({0} : Finset (ZMod p)) ×ˢ (Finset.univ : Finset (ZMod p)) := by
    ext ab
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_product,
      Finset.mem_singleton, and_true, affineHash]
    constructor
    · intro heq
      have : ab.1 * (x - y) = 0 := by ring_nf; linear_combination heq
      rcases mul_eq_zero.mp this with h0 | h0
      · exact h0
      · exact absurd (sub_eq_zero.mp h0) hne
    · intro h0; rw [h0]; ring
  have hcard : (Fintype.card (ZMod p) : ℝ) = p := by simp [ZMod.card]
  have hp : (0 : ℝ) < p := by
    have := (Fact.out : p.Prime).pos
    exact_mod_cast this
  rw [affineLaw, FinLaw.uniform_prob, hfilter, hcard, card_zmod_prod]
  rw [Finset.card_product, Finset.card_singleton, Finset.card_univ, ZMod.card]
  push_cast
  field_simp

/-- The affine family collides on a set of at least two keys exactly when
`a = 0`, an event of probability `1/p` — independently of the number of keys.
This is the sharpness witness for the converse bound. -/
theorem affine_collisionProb {S : Finset (ZMod p)} (hS : 2 ≤ S.card) :
    (affineLaw p).prob (Collides (affineHash p) S) = 1 / p := by
  classical
  obtain ⟨x, hx, y, hy, hne⟩ := Finset.one_lt_card.mp (by omega : 1 < S.card)
  have hiff : ∀ ab : ZMod p × ZMod p, Collides (affineHash p) S ab ↔ ab.1 = 0 := by
    intro ab
    constructor
    · rintro ⟨u, _, v, _, hnuv, heq⟩
      simp only [affineHash] at heq
      have : ab.1 * (u - v) = 0 := by ring_nf; linear_combination heq
      rcases mul_eq_zero.mp this with h0 | h0
      · exact h0
      · exact absurd (sub_eq_zero.mp h0) hnuv
    · intro h0
      exact ⟨x, hx, y, hy, hne, by simp [affineHash, h0]⟩
  have hfilter : (Finset.univ.filter (fun ab : ZMod p × ZMod p => Collides (affineHash p) S ab))
      = ({0} : Finset (ZMod p)) ×ˢ (Finset.univ : Finset (ZMod p)) := by
    ext ab
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_product,
      Finset.mem_singleton, and_true]
    exact hiff ab
  have hp : (0 : ℝ) < p := by
    have := (Fact.out : p.Prime).pos
    exact_mod_cast this
  rw [affineLaw, FinLaw.uniform_prob, hfilter, card_zmod_prod, Finset.card_product,
    Finset.card_singleton, Finset.card_univ, ZMod.card]
  push_cast
  field_simp

/-- The set of collision probabilities realised by exactly `2`-universal
families of hash functions `ZMod p → ZMod p` on the key set `S`. -/
def achievableCollisionProbs (S : Finset (ZMod p)) : Set ℝ :=
  {c | ∃ (Ω : Type) (_ : Fintype Ω) (L : FinLaw Ω) (h : Ω → ZMod p → ZMod p),
      Exactly2Universal L h S ∧ c = L.prob (Collides h S)}

/-- **Exact extremal value.**  Over *all* exactly `2`-universal families of hash
functions into `p` buckets, the least achievable probability of a collision on
a fixed set of at least two keys is exactly `1/p`.  The lower bound is the
converse to the union bound; the attainment is the affine family. -/
theorem isLeast_collisionProb {S : Finset (ZMod p)} (hS : 2 ≤ S.card) :
    IsLeast (achievableCollisionProbs p S) (1 / p) := by
  constructor
  · exact ⟨ZMod p × ZMod p, inferInstance, affineLaw p, affineHash p,
      affine_exactly2Universal p S, (affine_collisionProb p hS).symm⟩
  · rintro c ⟨Ω, instΩ, L, h, hu, rfl⟩
    have := inv_card_le_collisionProb (L := L) (h := h) hS hu
    rwa [ZMod.card] at this

end Affine

end UnionBoundConverse