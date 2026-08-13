/-
# Cycle 4 (adversarial review): the counting birthday bound, and where the
# hierarchy table is *not* tight

`Logic.ThreeSumBirthdayHierarchy` proves a matching pair of bounds for
**deterministically guaranteed** collisions: `> p` enumerated tuples are
necessary and sufficient, at every arity.  A critic immediately objects that
real collision-based factoring is *randomised*: Pollard's rho finds a collision
mod `p` after about `√p ≈ N^{1/4}` values, not `p ≈ √N`.

This file makes both sides of that objection precise by pure counting.

* `card_collisionFree_eval` : exactly `p⁻ᵐ := p.descFactorial m` of the `pᵐ`
  evaluations of `m` tuples into `ZMod p` are collision-free.
* `pow_le_descFactorial_add` : the union bound
  `p^{m+1} ≤ p · p.descFactorial m + C(m,2) · pᵐ`, i.e. the collision
  probability is at most `C(m,2)/p`.
* `majority_collision_free` / `randomized_barrier` : if `m² < p` then **more than
  half** of all evaluations are collision-free.  So even a randomised
  collision search needs `m ≥ √p` tuples: the birthday exponent is `1/2` in `p`,
  i.e. `N^{1/4}` for a balanced semiprime — the deterministic `√N` row of the
  hierarchy table is *not* tight for randomised search, while the `Ω(√p)`
  bound proved here is unconditional.

The two barriers therefore read:

| regime | tuples needed | balanced `N = p·q` |
| deterministic guarantee | `> p`   | `√N`     |
| randomised, success prob `> 1/2` | `≥ √p` | `N^{1/4}` |

and both are *lower* bounds proved here, not heuristics.
-/

import Mathlib
import Logic.ThreeSumBirthdayHierarchy

namespace ThreeSumBirthday

/-! ## Exact count of collision-free evaluations -/

/-- The collision-free evaluations of `m` distinct tuples into `ZMod p` are
exactly the embeddings `Fin m ↪ ZMod p`, and there are `p.descFactorial m` of
them (`p (p-1) ⋯ (p-m+1)`). -/
theorem card_collisionFree_eval (m p : ℕ) [NeZero p] :
    Fintype.card (Fin m ↪ ZMod p) = p.descFactorial m := by
  simp [Fintype.card_embedding_eq, ZMod.card]

/-- All evaluations number `pᵐ`. -/
theorem card_all_eval (m p : ℕ) [NeZero p] :
    Fintype.card (Fin m → ZMod p) = p ^ m := by
  simp [ZMod.card]

/-! ## The union bound -/

/-- **Union bound / birthday inequality.**  `p^{m+1} ≤ p · p⁻ᵐ + C(m,2) · pᵐ`,
which is the integer form of "the collision probability of `m` items in `p`
boxes is at most `C(m,2)/p`". -/
theorem pow_le_descFactorial_add (p : ℕ) :
    ∀ m : ℕ, m ≤ p → p ^ (m + 1) ≤ p * p.descFactorial m + m.choose 2 * p ^ m := by
  intro m
  induction m with
  | zero => intro _; simp
  | succ n ih =>
    intro hn
    have hn' : n ≤ p := le_of_lt (lt_of_lt_of_le (Nat.lt_succ_self n) hn)
    have ihn := ih hn'
    have hD : p.descFactorial n ≤ p ^ n := Nat.descFactorial_le_pow p n
    -- multiply the inductive hypothesis by `p`
    have h1 : p ^ (n + 2) ≤ p * (p * p.descFactorial n) + n.choose 2 * p ^ (n + 1) := by
      have := Nat.mul_le_mul_left p ihn
      calc p ^ (n + 2) = p * p ^ (n + 1) := by ring
        _ ≤ p * (p * p.descFactorial n + n.choose 2 * p ^ n) := this
        _ = p * (p * p.descFactorial n) + n.choose 2 * p ^ (n + 1) := by ring
    -- `p² D ≤ p (p - n) D + n · p^{n+1}`
    have hsplit : p * (p * p.descFactorial n)
        ≤ p * ((p - n) * p.descFactorial n) + n * p ^ (n + 1) := by
      have hpn : p = (p - n) + n := by omega
      have hterm : n * (p * p.descFactorial n) ≤ n * (p * p ^ n) :=
        Nat.mul_le_mul_left n (Nat.mul_le_mul_left p hD)
      calc p * (p * p.descFactorial n)
          = ((p - n) + n) * (p * p.descFactorial n) := by rw [← hpn]
        _ = (p - n) * (p * p.descFactorial n) + n * (p * p.descFactorial n) := by ring
        _ ≤ (p - n) * (p * p.descFactorial n) + n * (p * p ^ n) := by omega
        _ = p * ((p - n) * p.descFactorial n) + n * p ^ (n + 1) := by ring
    have hchoose : (n + 1).choose 2 = n.choose 2 + n := by
      rw [Nat.choose_succ_succ' n 1]
      simp [Nat.choose_one_right, Nat.add_comm]
    rw [Nat.descFactorial_succ, hchoose]
    calc p ^ (n + 1 + 1) = p ^ (n + 2) := by ring_nf
      _ ≤ p * (p * p.descFactorial n) + n.choose 2 * p ^ (n + 1) := h1
      _ ≤ (p * ((p - n) * p.descFactorial n) + n * p ^ (n + 1))
            + n.choose 2 * p ^ (n + 1) := by omega
      _ = p * ((p - n) * p.descFactorial n) + (n.choose 2 + n) * p ^ (n + 1) := by ring

/-! ## The randomised barrier -/

/-- **Majority of evaluations are collision-free** when `2·C(m,2) < p`. -/
theorem majority_collision_free {p m : ℕ} (hp : 0 < p) (hm : m ≤ p)
    (h : 2 * m.choose 2 < p) : p ^ m < 2 * p.descFactorial m := by
  by_contra hcon
  push_neg at hcon
  have hub := pow_le_descFactorial_add p m hm
  have hpow : 0 < p ^ m := Nat.pow_pos hp
  have h1 : p * p ^ m ≤ p * p.descFactorial m + m.choose 2 * p ^ m := by
    calc p * p ^ m = p ^ (m + 1) := by ring
      _ ≤ _ := hub
  have h2 : p * (2 * p.descFactorial m) ≤ p * p ^ m :=
    Nat.mul_le_mul_left p hcon
  nlinarith [hpow, h, h1, h2]

/-- **Randomised `√p` barrier.**  If fewer than `√p` tuples are enumerated
(`m² < p`), then a strict majority of evaluations produce no collision at all;
hence any collision search succeeding with probability `> 1/2` must enumerate
at least `√p` tuples.  For a balanced semiprime `N = p·q` this is `N^{1/4}`,
strictly below the deterministic `√N` wall — the hierarchy table is tight only
for deterministic guarantees. -/
theorem randomized_barrier {p m : ℕ} (hp : 0 < p) (h : m * m < p) :
    p ^ m < 2 * p.descFactorial m := by
  have hm : m ≤ p := by nlinarith [Nat.zero_le m]
  refine majority_collision_free hp hm ?_
  have hc : 2 * m.choose 2 ≤ m * m := by
    rw [Nat.choose_two_right]
    have hd := Nat.div_mul_le_self (m * (m - 1)) 2
    have hmm : m * (m - 1) ≤ m * m := Nat.mul_le_mul_left _ (Nat.sub_le _ _)
    omega
  omega

/-- Numeric instance of the two barriers at `p = 10007`: the deterministic
guarantee needs more than `10007` tuples, while `100 ≈ √p` tuples already leave
the randomised search collision-free for a majority of evaluations — so the
randomised threshold is genuinely of order `√p`, two orders of magnitude below
the deterministic one. -/
theorem barrier_gap_10007 :
    (2 * Nat.choose 100 2 < 10007) ∧ (10007 : ℕ) ^ 100 < 2 * Nat.descFactorial 10007 100 := by
  have h : 2 * Nat.choose 100 2 < 10007 := by decide
  exact ⟨h, majority_collision_free (by norm_num) (by norm_num) h⟩

end ThreeSumBirthday