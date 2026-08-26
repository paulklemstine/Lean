import Pythagorean.UnionBoundConverse.FirstMomentOptimality

/-!
# The complete extremal value function

Fourth cycle.  Combining the converse endpoint, the affine sharpness witness
and the pigeonhole degeneration, the extremal problem

> over all exactly `2`-universal families of hash functions from `n` keys into
> `p` buckets, how small can the probability of a collision be?

is solved *completely* for prime `p`:

`extremal_collision_value` :
  the least achievable value is `1/p` for `2 ≤ n ≤ p`,
  and every achievable value equals `1` for `n > p`.

The lower half is the converse to the union bound proved in
`UniversalCollision.lean`; the attainment is the affine family transported
along an injection of the key set into `ZMod p`
(`affineVia_collisionProb`).  Note that the extremal value does **not** depend
on the number of keys `n` in the whole range `2 ≤ n ≤ p`, in sharp contrast
with the union bound `C(n,2)/p`, which grows quadratically and becomes vacuous
once `n ≳ √p`.
-/

namespace UnionBoundConverse

open Finset

section AffineVia

variable {K : Type*} [Fintype K] [DecidableEq K] (p : ℕ) [Fact p.Prime] (ι : K → ZMod p)

/-- The affine family transported along a key encoding `ι : K → ZMod p`. -/
def affineHashVia : ZMod p × ZMod p → K → ZMod p := fun ab k => affineHash p ab (ι k)

omit [Fintype K] [DecidableEq K] in
/-- Transporting along an injective encoding preserves exact `2`-universality. -/
theorem affineVia_exactly2Universal {S : Finset K} (hinj : Set.InjOn ι S) :
    Exactly2Universal (affineLaw p) (affineHashVia p ι) S := by
  intro x hx y hy hne
  have hne' : ι x ≠ ι y := fun he => hne (hinj hx hy he)
  simpa [affineHashVia] using
    affine_exactly2Universal p (Finset.univ : Finset (ZMod p)) (ι x) (Finset.mem_univ _)
      (ι y) (Finset.mem_univ _) hne'

omit [Fintype K] [DecidableEq K] in
/-- The transported affine family collides exactly on the `p` indices with
`a = 0`, so its collision probability is `1/p` for every key set of size at
least two on which the encoding is injective. -/
theorem affineVia_collisionProb {S : Finset K} (hS : 2 ≤ S.card) (hinj : Set.InjOn ι S) :
    (affineLaw p).prob (Collides (affineHashVia p ι) S) = 1 / p := by
  classical
  obtain ⟨x, hx, y, hy, hne⟩ := Finset.one_lt_card.mp (by omega : 1 < S.card)
  have hne' : ι x ≠ ι y := fun he => hne (hinj hx hy he)
  have hiff : ∀ ab : ZMod p × ZMod p, Collides (affineHashVia p ι) S ab ↔ ab.1 = 0 := by
    intro ab
    constructor
    · rintro ⟨u, hu, v, hv, hnuv, heq⟩
      have hnuv' : ι u ≠ ι v := fun he => hnuv (hinj hu hv he)
      simp only [affineHashVia, affineHash] at heq
      have hfac : ab.1 * (ι u - ι v) = 0 := by linear_combination heq
      rcases mul_eq_zero.mp hfac with h0 | h0
      · exact h0
      · exact absurd (sub_eq_zero.mp h0) hnuv'
    · intro h0
      exact ⟨x, hx, y, hy, hne, by simp [affineHashVia, affineHash, h0]⟩
  have hfilter : (Finset.univ.filter
      (fun ab : ZMod p × ZMod p => Collides (affineHashVia p ι) S ab))
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

end AffineVia

/-! ### The value function -/

variable (p n : ℕ) [Fact p.Prime]

/-- The set of collision probabilities realised by exactly `2`-universal
families of hash functions from `n` keys into `p` buckets. -/
def achievableFin : Set ℝ :=
  {c | ∃ (Ω : Type) (_ : Fintype Ω) (L : FinLaw Ω) (h : Ω → Fin n → ZMod p),
      Exactly2Universal L h (Finset.univ : Finset (Fin n)) ∧
        c = L.prob (Collides h (Finset.univ : Finset (Fin n)))}

/-- The standard encoding `Fin n → ZMod p` is injective when `n ≤ p`. -/
theorem finEncoding_injOn (hnp : n ≤ p) :
    Set.InjOn (fun i : Fin n => ((i : ℕ) : ZMod p)) (Finset.univ : Finset (Fin n)) := by
  intro i _ j _ he
  have hi : (i : ℕ) < p := lt_of_lt_of_le i.isLt hnp
  have hj : (j : ℕ) < p := lt_of_lt_of_le j.isLt hnp
  have hev : ((i : ℕ) : ZMod p) = ((j : ℕ) : ZMod p) := he
  have : ((i : ℕ) : ZMod p).val = ((j : ℕ) : ZMod p).val := by rw [hev]
  rw [ZMod.val_natCast_of_lt hi, ZMod.val_natCast_of_lt hj] at this
  exact Fin.ext this

/-- **The extremal value function.**  For `2 ≤ n ≤ p` the least achievable
collision probability of an exactly `2`-universal family on `n` keys and `p`
buckets is exactly `1/p`, independent of `n`; for `n > p` every exactly
`2`-universal family collides with probability `1`.  This settles the extremal
problem in both regimes. -/
theorem extremal_collision_value (hn : 2 ≤ n) :
    (n ≤ p → IsLeast (achievableFin p n) (1 / p)) ∧
      (p < n → ∀ c ∈ achievableFin p n, c = 1) := by
  have hcard : (Finset.univ : Finset (Fin n)).card = n := by simp
  constructor
  · intro hnp
    constructor
    · refine ⟨ZMod p × ZMod p, inferInstance, affineLaw p,
        affineHashVia p (fun i : Fin n => ((i : ℕ) : ZMod p)), ?_, ?_⟩
      · exact affineVia_exactly2Universal p _ (finEncoding_injOn p n hnp)
      · exact (affineVia_collisionProb p _ (by rw [hcard]; exact hn)
          (finEncoding_injOn p n hnp)).symm
    · rintro c ⟨Ω, instΩ, L, h, hu, rfl⟩
      have := inv_card_le_collisionProb (L := L) (h := h) (by rw [hcard]; exact hn) hu
      rwa [ZMod.card] at this
  · rintro hpn c ⟨Ω, instΩ, L, h, hu, rfl⟩
    refine collisionProb_eq_one_of_card_lt L h ?_
    rw [ZMod.card, hcard]
    exact hpn

/-- The extremal value is completely insensitive to the number of keys in the
nondegenerate range, while the union bound grows quadratically: for
`2 ≤ n ≤ p` the least achievable probability is `1/p` for every `n`. -/
theorem extremal_value_independent_of_n {n₁ n₂ : ℕ} (h₁ : 2 ≤ n₁) (h₂ : 2 ≤ n₂)
    (hp₁ : n₁ ≤ p) (hp₂ : n₂ ≤ p) :
    IsLeast (achievableFin p n₁) (1 / p) ∧ IsLeast (achievableFin p n₂) (1 / p) :=
  ⟨(extremal_collision_value p n₁ h₁).1 hp₁, (extremal_collision_value p n₂ h₂).1 hp₂⟩

end UnionBoundConverse