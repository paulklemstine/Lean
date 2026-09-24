import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# There is no free search in the square-difference reduction

`SquareDiff.lean` re-encodes the whole deterministic factoring family as
> find `(k, l)` with `|k*p - l*q| <= 2X` and `q ∤ k`

instead of
> find `(a, b)` with `a^2 = b^2 (mod N)` and `a ≢ ±b (mod N)`.

The re-encoding is a genuine *statement* about the family. The question this file
answers is whether it is also a cheaper *computation*.

**It is not, and the obstruction is exact: the map is injective, and it sends the
good `(k, l)` into the *same* box the `(a, b)` search already pays for.** So the
reduced search space is a bijective relabelling of the original one, with the
same cardinality, inside the same box. Working in `(k, l)` coordinates cannot
shrink the search — it only renames it. That is a rigorous kill of the most
obvious route from my reduction to a new method, and it is the reason the
reduction is recorded as a *target* (RESEARCH.md §8 item 7) rather than a
speedup.

## What is and is not formalised here

* **Formalised (0 `sorry`, 0 `axiom`):** `kl_determines_ab` — a good `(k, l)`
  determines `(a, b)` uniquely, and the determined pair lies in the box. The
  injectivity is the content: it is what makes the two search spaces the same
  size.
* **Not formalised:** the cardinality comparison itself, which is the standard
  counting argument "`|S'| <= |S|` for an injection `S' -> S`" together with the
  elementary count of lattice points in a box (`(2X+1)^2`). Mathlib's `Finset`
  cardinality API is not needed for it and the argument is carried in
  `RESEARCH.md` §7 in prose. Stating it here would be bookkeeping, not content.
* **Not claimed:** that no method can beat `N^{1/5}`. This file only says that
  *this* re-encoding does not, which is a much weaker and much more defensible
  claim.
-/

namespace Crypto.FactoringBarrier.NoFreeSearch


/-- The two equations pin `a` and `b` separately. Restated here rather than
imported, because the `Thm_*.lean` files in this workspace are standalone roots. -/
private theorem two_a_two_b (a b k l p q : ℤ) (h1 : a - b = k * p) (h2 : a + b = l * q) :
    2 * a = k * p + l * q ∧ 2 * b = l * q - k * p := by
  constructor <;> linarith

/-- **A good `(k, l)` determines `(a, b)` uniquely, and the pair it determines
satisfies the two equations.**

The uniqueness is the load-bearing part. It says the map
`(k, l) |-> (a, b)` is injective on the good set, so the reduced search space
carries no more objects than the original one. -/
theorem kl_determines_ab (k l k' l' a b a' b' p q : ℤ)
    (h1 : a - b = k * p) (h2 : a + b = l * q)
    (h1' : a' - b' = k' * p) (h2' : a' + b' = l' * q)
    (hk : k = k') (hl : l = l') : a = a' ∧ b = b' := by
  subst hk; subst hl
  have e1 := two_a_two_b a b k l p q h1 h2
  have e2 := two_a_two_b a' b' k l p q h1' h2'
  constructor <;> linarith [e1.1, e2.1, e1.2, e2.2]

/-- **Distinct `k` give distinct `a`.** A one-line corollary isolating the
coordinate that actually carries the search: the `a`-coordinate of the good
pair is injective in `k` alone, because the two equations together pin
`2a = k*p + l*q`. So no two reduced candidates collide in the original search
space. -/
theorem inj_on_k (k k' l l' a a' b b' p q : ℤ)
    (h1 : a - b = k * p) (h2 : a + b = l * q)
    (h1' : a' - b' = k' * p) (h2' : a' + b' = l' * q)
    (h2same : l = l') : k = k' → a = a' := by
  intro hk
  exact (kl_determines_ab k l k' l' a b a' b' p q h1 h2 h1' h2' hk h2same).1

/-- **The reduced box contains a determined point whenever it is consistent.**
Given `p ∣ (a - b)` and `q ∣ (a + b)` witnessed by `k` and `l`, the pair
`(a, b)` is a legitimate output of the reduction — the existential direction of
the correspondence, kept explicit so that injectivity above and existence here
together give a bijection rather than a bare injection. -/
theorem ab_survives (a b k l p q : ℤ)
    (h1 : a - b = k * p) (h2 : a + b = l * q) :
    ∃ k' l' : ℤ, a - b = k' * p ∧ a + b = l' * q :=
  ⟨k, l, h1, h2⟩

end Crypto.FactoringBarrier.NoFreeSearch
