import Pythagorean.UnionBoundConverse.UniversalCollision

/-!
# Strong `2`-universality, and an arithmetic constraint on universal families

This second cycle sharpens the picture of `UniversalCollision.lean`.

* `PairwiseIndependent` — *strong* `2`-universality: the pair of hash values of
  two distinct keys is uniform on `V × V`.
* `PairwiseIndependent.exactly2Universal` — strong `2`-universality implies the
  exact pair-collision probability `1/m`, hence (by the converse endpoint) a
  collision probability of at least `1/m` for *every* pairwise independent
  family.  The proof is finite additivity along the diagonal of `V × V`.
* `affine_pairwiseIndependent` — the affine family over `ZMod p` is pairwise
  independent, so the extremal family attaining `1/p` is not a pathological
  object but the standard Carter–Wegman construction.
* `card_dvd_card_of_uniform_exactly2Universal` — an arithmetic obstruction:
  a *uniformly weighted* exactly `2`-universal family must have size divisible
  by the number of buckets `m`.  In particular no uniform family of size
  coprime to `m` can be exactly `2`-universal, whatever its structure; the
  affine family, of size `p²`, is the minimal-in-spirit example.
* `strongly2Universal_collision_lower` — the headline consequence: pairwise
  independence alone forces collisions with probability at least `1/m`.
-/

namespace UnionBoundConverse

open Finset

variable {Ω K V : Type*} [Fintype Ω] [Fintype V] [DecidableEq K] [DecidableEq V]

/-- **Strong `2`-universality** (pairwise independence): for distinct keys the
pair of hash values is uniformly distributed on `V × V`. -/
def PairwiseIndependent (L : FinLaw Ω) (h : Ω → K → V) (S : Finset K) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, x ≠ y → ∀ u v : V,
    L.prob (fun o => h o x = u ∧ h o y = v) = 1 / ((Fintype.card V : ℝ) * Fintype.card V)

omit [DecidableEq K] [DecidableEq V] in
/-- Strong `2`-universality implies exact `2`-universality: summing the uniform
pair distribution along the diagonal of `V × V` gives `m · (1/m²) = 1/m`. -/
theorem PairwiseIndependent.exactly2Universal {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hp : PairwiseIndependent L h S) : Exactly2Universal L h S := by
  intro x hx y hy hne
  have hV : Nonempty V := by
    obtain ⟨o⟩ := L.nonempty
    exact ⟨h o x⟩
  have hm : (0 : ℝ) < Fintype.card V := by exact_mod_cast Fintype.card_pos
  have hsplit : L.prob (fun o => h o x = h o y)
      = L.prob (fun o => ∃ u : V, h o x = u ∧ h o y = u) :=
    FinLaw.prob_congr fun o => ⟨fun heq => ⟨h o x, rfl, heq.symm⟩,
      fun ⟨u, h1, h2⟩ => h1.trans h2.symm⟩
  rw [hsplit, FinLaw.prob_exists_eq_sum_of_disjoint
    (A := fun u o => h o x = u ∧ h o y = u)
    (fun o i j hi hj => hi.1.symm.trans hj.1)]
  have hterm : ∀ u : V, L.prob (fun o => h o x = u ∧ h o y = u)
      = 1 / ((Fintype.card V : ℝ) * Fintype.card V) := fun u => hp x hx y hy hne u u
  rw [Finset.sum_congr rfl (fun u _ => hterm u), Finset.sum_const, nsmul_eq_mul,
    Finset.card_univ]
  field_simp

omit [DecidableEq K] in
/-- **Pairwise independence forces collisions.**  Every strongly `2`-universal
family collides on at least two keys with probability at least `1/m`. -/
theorem strongly2Universal_collision_lower {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hS : 2 ≤ S.card) (hp : PairwiseIndependent L h S) :
    1 / (Fintype.card V : ℝ) ≤ L.prob (Collides h S) :=
  inv_card_le_collisionProb hS hp.exactly2Universal

/-! ### An arithmetic obstruction for uniformly weighted families -/

omit [DecidableEq K] in
/-- **Divisibility constraint.**  If a family of hash functions indexed by a
finite set `Ω` with the *uniform* law is exactly `2`-universal on two or more
keys, then the number of buckets divides the size of the family.  Combined with
the extremal theorem this says that the exactly `2`-universal uniform families
form an arithmetically constrained set: the affine family over `ZMod p` has
size `p²`, the smallest square multiple of `p`. -/
theorem card_dvd_card_of_uniform_exactly2Universal [Nonempty Ω] {h : Ω → K → V} {S : Finset K}
    (hS : 2 ≤ S.card) (hu : Exactly2Universal (FinLaw.uniform Ω) h S) :
    Fintype.card V ∣ Fintype.card Ω := by
  classical
  obtain ⟨x, hx, y, hy, hne⟩ := Finset.one_lt_card.mp (by omega : 1 < S.card)
  have hV : Nonempty V := ⟨h (Classical.arbitrary Ω) x⟩
  have hmR : (0 : ℝ) < Fintype.card V := by exact_mod_cast Fintype.card_pos
  have hNR : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast Fintype.card_pos
  have heq := hu x hx y hy hne
  rw [FinLaw.uniform_prob] at heq
  set c := (Finset.univ.filter (fun o => h o x = h o y)).card with hc
  have hreal : (c : ℝ) * (Fintype.card V : ℝ) = (Fintype.card Ω : ℝ) := by
    field_simp at heq
    linarith [heq]
  have hnat : c * Fintype.card V = Fintype.card Ω := by exact_mod_cast hreal
  exact ⟨c, by rw [← hnat]; ring⟩

/-! ### The affine family is strongly `2`-universal -/

section Affine

variable (p : ℕ) [Fact p.Prime]

/-- For distinct keys `x ≠ y` and prescribed values `u, v`, exactly one affine
map `z ↦ a z + b` over `ZMod p` sends `x ↦ u` and `y ↦ v`: the Vandermonde
system is invertible.  Hence the affine family is pairwise independent. -/
theorem affine_pairwiseIndependent (S : Finset (ZMod p)) :
    PairwiseIndependent (affineLaw p) (affineHash p) S := by
  classical
  intro x _ y _ hne u v
  have hxy : x - y ≠ 0 := sub_ne_zero.mpr hne
  set a₀ : ZMod p := (u - v) / (x - y) with ha₀
  set b₀ : ZMod p := u - a₀ * x with hb₀
  have key : a₀ * (x - y) = u - v := by
    rw [ha₀]; field_simp
  have hfilter : (Finset.univ.filter (fun ab : ZMod p × ZMod p =>
      affineHash p ab x = u ∧ affineHash p ab y = v)) = {(a₀, b₀)} := by
    ext ab
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton, affineHash]
    constructor
    · rintro ⟨h1, h2⟩
      have hstep : ab.1 * (x - y) = u - v := by linear_combination h1 - h2
      have ha : ab.1 = a₀ := by
        have hfac : (ab.1 - a₀) * (x - y) = 0 := by linear_combination hstep - key
        rcases mul_eq_zero.mp hfac with h0 | h0
        · exact sub_eq_zero.mp h0
        · exact absurd h0 hxy
      have hb : ab.2 = b₀ := by rw [hb₀, ← ha]; linear_combination h1
      exact Prod.ext ha hb
    · rintro rfl
      refine ⟨by rw [hb₀]; ring, ?_⟩
      show a₀ * y + b₀ = v
      rw [hb₀]; linear_combination -key
  have hcardV : (Fintype.card (ZMod p) : ℝ) = p := by simp [ZMod.card]
  have hp0 : (0 : ℝ) < p := by
    have := (Fact.out : p.Prime).pos
    exact_mod_cast this
  rw [affineLaw, FinLaw.uniform_prob, hfilter, hcardV, card_zmod_prod, Finset.card_singleton]
  push_cast
  field_simp

/-- The extremal family attaining the converse bound `1/p` is strongly
`2`-universal, so the extremal value `1/p` is attained already inside the
smaller class of pairwise independent families. -/
theorem isLeast_collisionProb_strong {S : Finset (ZMod p)} (hS : 2 ≤ S.card) :
    PairwiseIndependent (affineLaw p) (affineHash p) S ∧
      (affineLaw p).prob (Collides (affineHash p) S) = 1 / p ∧
      ∀ c ∈ achievableCollisionProbs p S, 1 / (p : ℝ) ≤ c :=
  ⟨affine_pairwiseIndependent p S, affine_collisionProb p hS,
    (isLeast_collisionProb p hS).2⟩

end Affine

end UnionBoundConverse