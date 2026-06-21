/-
  Hash Collisions from Algebraic Hardness
  =======================================

  We connect the abstract Merkle–Damgård collision theory
  (`Cryptography.MerkleDamgard`) to the algebraic *product-collision* theory of
  `Cryptography.ProductCollisions`. The bridge is the multiplicative compression
  function `mulCompress s b = s * b`, whose iterate is exactly the list product.

  This realizes, in a verifiable special case, the slogan "collision-resistant
  hashing rests on a hard problem": breaking the multiplicative hash is exactly
  exhibiting non-unique factorization (a product collision), and any such
  algebraic collision is transported, constructively, into a compression
  collision and then into a full Merkle–Damgård hash collision.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): The `HasProductCollision` obstruction of the
  catalog should coincide with a one-step `HasCompressionCollision` of the
  multiplication map, and equal-length factorization ambiguity should lift to a
  genuine MD hash collision.

  EXPERIMENT (Experimenter): `productCollision_to_compression` is immediate —
  a product collision `a*b = c*d` with `{a,b} ≠ {c,d}` forces `(a,b) ≠ (c,d)`
  (else the multisets agree), giving `mulCompress a b = mulCompress c d`.
  `mdHash_mul_eq_prod` identifies the multiplicative MD iterate with `List.prod`.

  ANALYSIS (Analyst): The catalog set `{6,10,21,35}` (with `6*35 = 10*21 = 210`)
  gives a concrete equal-length MD collision, exercising `md_collision_extract`
  end-to-end. The length-2 lists `[6,35]` and `[10,21]` differ, have equal
  product, hence collide; extraction returns a multiplication collision.

  CRITIQUE (Critic): The multiset-inequality ⇒ pair-inequality step is the only
  delicate point; verified that `({a,b} : Multiset) = {c,d}` would follow from
  `(a,b) = (c,d)`, so the contrapositive is sound. No vacuity: the catalog
  witness makes every hypothesis satisfiable.

  SYNTHESIS (PI): Catalog hardness (non-unique factorization) ⇒ compression
  collision ⇒ Merkle–Damgård hash collision, all constructive and `sorry`-free.
-/
import Mathlib
import Cryptography.ProductCollisions
import Cryptography.MerkleDamgard

namespace Cryptography.HashFromHardness

open Cryptography.MerkleDamgard

/-- The multiplicative compression function `s ↦ b ↦ s * b` on `ℕ`. -/
def mulCompress : ℕ → ℕ → ℕ := fun s b => s * b

/-- A product collision in any set `S` (two distinct factor pairs with equal
    product) is, verbatim, a compression collision of multiplication. This is
    the algebraic "hard problem" feeding the hash. -/
theorem productCollision_to_compression (S : Set ℕ)
    (h : HasProductCollision S) : HasCompressionCollision mulCompress := by
  obtain ⟨a, b, c, d, _, _, _, _, _, _, _, _, hprod, hms⟩ := h
  refine ⟨a, b, c, d, ?_, hprod⟩
  intro hpair
  apply hms
  obtain ⟨rfl, rfl⟩ := Prod.mk.injEq .. ▸ hpair
  rfl

/-- The multiplicative Merkle–Damgård iterate, started from `1`, is exactly the
    product of the message blocks. -/
theorem mdHash_mul_eq_prod (l : List ℕ) :
    mdHash mulCompress 1 l = l.prod := by
  unfold mdHash mulCompress
  rw [List.prod_eq_foldl]

/-- **Algebraic hardness ⇒ Merkle–Damgård collision.**
    Two distinct, equal-length block lists with equal product yield a collision
    of the iterated multiplicative hash, and hence (by extraction) a collision
    of the compression function. -/
theorem md_collision_from_equal_product (m₁ m₂ : List ℕ)
    (hlen : m₁.length = m₂.length) (hne : m₁ ≠ m₂)
    (hprod : m₁.prod = m₂.prod) :
    HasCompressionCollision mulCompress := by
  apply md_collision_extract mulCompress 1 m₁ m₂ hlen hne
  rw [mdHash_mul_eq_prod, mdHash_mul_eq_prod, hprod]

/-- **End-to-end concrete instance.**
    The catalog witness `6 · 35 = 10 · 21 = 210` gives an explicit equal-length
    Merkle–Damgård hash collision, demonstrating the full pipeline. -/
theorem concrete_md_collision :
    HasCompressionCollision mulCompress := by
  apply md_collision_from_equal_product [6, 35] [10, 21] (by rfl) (by decide)
  decide

end Cryptography.HashFromHardness