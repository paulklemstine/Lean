import Mathlib
import Shared.Ispythquadruple.IsPythQuadruple
import Shared.HigherPythagorean.QuadrupleTree
import Shared.HigherPythagorean.HarmonicLaw
import Physics.HigherPythagoreanTrees.MirrorFixedNodes

/-!
# The divisor law for mirror nodes

The Berggren theory has arithmetic "counting laws" attached to the tree.  Its
dimension-three analogue turns out to be a **divisor law** for the mirror (neutral) nodes
studied in `Catalog.Physics.HigherPythagoreanTrees.MirrorFixedNodes`.

A node `(a,b,c,d)` is a mirror node for the generator `R₍₋,₊,₊₎` when `−a + b + c = d`.  We
show that mirror nodes with first coordinate `a` are in explicit bijection with the
factorisations `a² = p·q`:

`(a, b, c, d) = (a, a+p, a+q, a+p+q)`.

Consequently the number of mirror nodes with first coordinate `a` is exactly the number of
divisors `τ(a²) = d(a²)` — the dimension-three replacement of the arithmetic ("totient")
laws of the planar Berggren theory.

Main results.

* `mirror_of_factorization` : every factorisation `p·q = a²` produces a Pythagorean quadruple
  which is fixed by the generator `R₍₋,₊,₊₎`.
* `factorization_of_mirror` : conversely every mirror node arises this way.
* `mirror_pairs_card` : the number of such nodes with first coordinate `a` is `τ(a²)`.
* `mirror_count_examples` : `τ(4) = 3`, `τ(9) = 3`, `τ(36) = 9` — matching the mirror nodes
  `(2,3,6,7)`, `(2,4,4,6)`, `(2,6,3,7)` for `a = 2`.
-/

namespace HigherPythagoreanDivisor

open Matrix Finset HigherPythagorean HigherPythagoreanSigned

/-! ## The arithmetic bijection -/

/-- **Factorisations give mirror nodes.**  If `p q = a²` then `(a, a+p, a+q, a+p+q)` is a
Pythagorean quadruple, and it is height-neutral for the first sign flip. -/
theorem mirror_of_factorization {a p q : ℤ} (h : p * q = a ^ 2) :
    IsPythQuadruple a (a + p) (a + q) (a + p + q) ∧
      (-1) * a + (a + p) + (a + q) = a + p + q := by
  constructor
  · unfold IsPythQuadruple
    nlinarith [h]
  · ring

/-- The corresponding node is fixed by the generator `R₍₋,₊,₊₎`.  Note that the fixed-point
property is unconditional; it is the Pythagorean relation that forces `p q = a²`. -/
theorem mirror_of_factorization_fixed (a p q : ℤ) :
    signedRefl (-1) 1 1 *ᵥ ![a, a + p, a + q, a + p + q] = ![a, a + p, a + q, a + p + q] := by
  rw [HigherPythagoreanMirror.fixed_iff_neutral (by simp [IsSign]) (by simp [IsSign])
    (by simp [IsSign])]
  ring

/-- **Mirror nodes are factorisations.**  A Pythagorean quadruple with positive coordinates
that is height-neutral for the first sign flip has `(b−a)(c−a) = a²`, with both factors
positive, and height `a + (b−a) + (c−a)`. -/
theorem factorization_of_mirror {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : IsPythQuadruple a b c d) (hneutral : -a + b + c = d) :
    0 < b - a ∧ 0 < c - a ∧ (b - a) * (c - a) = a ^ 2 ∧ d = a + (b - a) + (c - a) := by
  unfold IsPythQuadruple at h
  have hharm : b * c = a * (b + c) := by nlinarith
  have hba : 0 < b - a := by nlinarith
  have hca : 0 < c - a := by nlinarith
  refine ⟨hba, hca, by nlinarith, by linarith⟩

/-! ## The counting law -/

/-- The mirror nodes with first coordinate `a`, recorded by their two middle coordinates. -/
def mirrorPairs (a : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.Icc 1 (a + a ^ 2)) ×ˢ (Finset.Icc 1 (a + a ^ 2))).filter
    fun bc : ℕ × ℕ => a < bc.1 ∧ a < bc.2 ∧ (bc.1 - a) * (bc.2 - a) = a ^ 2

/-- **The divisor law.**  The number of mirror nodes with first coordinate `a` equals the
number of divisors of `a²`. -/
theorem mirror_pairs_card (a : ℕ) (ha : 0 < a) :
    (mirrorPairs a).card = (a ^ 2).divisors.card := by
  have hsq : 0 < a ^ 2 := by positivity
  refine Finset.card_bij (fun (bc : ℕ × ℕ) _ => bc.1 - a) ?_ ?_ ?_
  · -- the map lands in the divisors of `a²`
    intro bc hbc
    rw [mirrorPairs, Finset.mem_filter] at hbc
    obtain ⟨-, h1, h2, h3⟩ := hbc
    exact Nat.mem_divisors.mpr ⟨⟨bc.2 - a, h3.symm⟩, by omega⟩
  · -- injectivity
    intro bc hbc bc' hbc' heq
    dsimp only at heq
    rw [mirrorPairs, Finset.mem_filter] at hbc hbc'
    obtain ⟨-, h1, h2, h3⟩ := hbc
    obtain ⟨-, h1', h2', h3'⟩ := hbc'
    have hfst : bc.1 = bc'.1 := by omega
    have hpos : 0 < bc.1 - a := by omega
    have : bc.2 - a = bc'.2 - a := by
      have := h3.trans h3'.symm
      rw [hfst] at this
      exact Nat.eq_of_mul_eq_mul_left (by omega) this
    exact Prod.ext hfst (by omega)
  · -- surjectivity
    intro p hp
    rw [Nat.mem_divisors] at hp
    obtain ⟨⟨k, hk⟩, -⟩ := hp
    have hppos : 0 < p := by
      rcases Nat.eq_zero_or_pos p with rfl | h
      · simp at hk; omega
      · exact h
    have hkpos : 0 < k := by
      rcases Nat.eq_zero_or_pos k with rfl | h
      · simp at hk; omega
      · exact h
    have hple : p ≤ a ^ 2 := by
      calc p = p * 1 := (Nat.mul_one p).symm
        _ ≤ p * k := Nat.mul_le_mul_left p hkpos
        _ = a ^ 2 := hk.symm
    have hkle : k ≤ a ^ 2 := by
      calc k = 1 * k := (Nat.one_mul k).symm
        _ ≤ p * k := Nat.mul_le_mul_right k hppos
        _ = a ^ 2 := hk.symm
    refine ⟨(a + p, a + k), ?_, by dsimp only; omega⟩
    rw [mirrorPairs, Finset.mem_filter]
    refine ⟨Finset.mem_product.mpr ⟨?_, ?_⟩, by omega, by omega, ?_⟩
    · exact Finset.mem_Icc.mpr ⟨by omega, by omega⟩
    · exact Finset.mem_Icc.mpr ⟨by omega, by omega⟩
    · simpa using hk.symm

/-- Small cases of the divisor law: `a = 2` has `τ(4) = 3` mirror nodes and `a = 6` has
`τ(36) = 9`. -/
theorem mirror_count_examples :
    (mirrorPairs 2).card = 3 ∧ (mirrorPairs 6).card = 9 := by
  constructor
  · rw [mirror_pairs_card 2 (by norm_num)]
    decide
  · rw [mirror_pairs_card 6 (by norm_num)]
    rfl

/-- The three mirror nodes above `a = 2` are `(2,3,6,7)`, `(2,4,4,6)` and `(2,6,3,7)`; the
first is a primitive Pythagorean quadruple fixed by `R₍₋,₊,₊₎`. -/
theorem mirror_two_three_six_seven :
    IsPrimQuad 2 3 6 7 ∧ signedRefl (-1) 1 1 *ᵥ ![2, 3, 6, 7] = ![2, 3, 6, 7] := by
  refine ⟨⟨by unfold IsPythQuadruple; norm_num, by decide⟩, ?_⟩
  have h := mirror_of_factorization_fixed 2 1 4
  norm_num at h
  exact h

end HigherPythagoreanDivisor