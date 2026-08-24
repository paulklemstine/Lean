import Cryptography.BerggrenTrees.BerggrenFreeMonoid
import Cryptography.Price2Adic.Letters

/-!
# Contrast: the Berggren alphabet is 2-adically invisible

`Letters.lean` proved that the *Price* alphabet is read, two letters deep, by the residue
`N mod 8` of the odd leg.  Here we prove the complementary negative statement for the
*Berggren* tree, whose generators are the ones already formalised in
`Cryptography.BerggrenTrees.BerggrenFreeMonoid` (`actGen`):

  `A : (m,n) ↦ (2m-n, m)`,  `B : (m,n) ↦ (2m+n, m)`,  `C : (m,n) ↦ (m+2n, n)`.

* `berg_children_diff` — the `A`- and `B`-children of a node have triples differing by
  `8mn`, `4mn`, `8mn`; so they are congruent modulo `4mn`.
* `berg_twoAdic_blind` — for every `k` there is a primitive node whose `A`- and
  `B`-children are distinct primitive triples that agree modulo `2^k` in all three
  entries.  Hence **no** function of the 2-adic residues of a triple can recover the last
  Berggren letter, at any depth of the 2-adic filtration.

Together with `Price2Adic.letter_pos0_iff` (`A` iff `N ≡ 1 mod 4`, a perfect classifier)
this makes the placement precise: the two trees are sealed at different adic places, and
the halving alphabet of Price is exactly the one that the 2-adic filtration can read.

## Lab notes (round 70, exp 548)

The reported best Berggren-letter `z`-score at modulus `2^j` (worst `z = +4.57`) failed
replication under three fresh seeds; the theorem below shows why any such signal must be
a sampling artefact: the separating statistic does not exist.
-/

namespace Price2Adic

/-- Euclid's triple map on integer parameter pairs. -/
def tripleZ (p : ℤ × ℤ) : ℤ × ℤ × ℤ := (p.1 ^ 2 - p.2 ^ 2, 2 * p.1 * p.2, p.1 ^ 2 + p.2 ^ 2)

/-- Primitive Euclid parameter pairs, over `ℤ` (the coefficient ring of `actGen`). -/
def ValidZ (p : ℤ × ℤ) : Prop :=
  0 < p.2 ∧ p.2 < p.1 ∧ IsCoprime p.1 p.2 ∧ (p.1 + p.2) % 2 = 1

theorem ValidZ.toValidPair {p : ℤ × ℤ} (h : ValidZ p) : ValidPair p := ⟨h.1, h.2.1⟩

/-- The two Berggren children `A` and `B` of a node differ by multiples of `4mn` in each
entry of the triple. -/
theorem berg_children_diff (p : ℤ × ℤ) :
    (tripleZ (actGen .B p)).1 = (tripleZ (actGen .A p)).1 + 8 * p.1 * p.2 ∧
    (tripleZ (actGen .B p)).2.1 = (tripleZ (actGen .A p)).2.1 + 4 * p.1 * p.2 ∧
    (tripleZ (actGen .B p)).2.2 = (tripleZ (actGen .A p)).2.2 + 8 * p.1 * p.2 := by
  obtain ⟨m, n⟩ := p
  refine ⟨?_, ?_, ?_⟩ <;> simp only [tripleZ, actGen] <;> ring

/-- **The Berggren letter is 2-adically invisible.**  For every `k` there are two distinct
primitive triples, the `A`- and the `B`-child of one and the same primitive node, whose
three entries agree modulo `2^k`. -/
theorem berg_twoAdic_blind (k : ℕ) (hk : 1 ≤ k) :
    ∃ r : ℤ × ℤ, ValidZ r ∧ ValidZ (actGen .A r) ∧ ValidZ (actGen .B r) ∧
      (2 : ℤ) ^ k ∣ (tripleZ (actGen .B r)).1 - (tripleZ (actGen .A r)).1 ∧
      (2 : ℤ) ^ k ∣ (tripleZ (actGen .B r)).2.1 - (tripleZ (actGen .A r)).2.1 ∧
      (2 : ℤ) ^ k ∣ (tripleZ (actGen .B r)).2.2 - (tripleZ (actGen .A r)).2.2 ∧
      tripleZ (actGen .A r) ≠ tripleZ (actGen .B r) := by
  obtain ⟨t, ht⟩ : ∃ t : ℤ, (2 : ℤ) ^ k = 2 * t := ⟨2 ^ (k - 1), by
    rw [← pow_succ']
    congr 1
    omega⟩
  have htpos : 0 < t := by
    have : (0 : ℤ) < 2 ^ k := by positivity
    omega
  refine ⟨(2 ^ k + 1, 2 ^ k), ⟨by omega, by omega, ⟨1, -1, by ring⟩, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact ⟨by simp only [actGen]; omega, by simp only [actGen]; omega,
      ⟨1, -1, by simp only [actGen]; ring⟩, by simp only [actGen]; omega⟩
  · exact ⟨by simp only [actGen]; omega, by simp only [actGen]; omega,
      ⟨-1, 3, by simp only [actGen]; ring⟩, by simp only [actGen]; omega⟩
  · rw [(berg_children_diff (2 ^ k + 1, 2 ^ k)).1]
    exact ⟨8 * (2 ^ k + 1), by ring⟩
  · rw [(berg_children_diff (2 ^ k + 1, 2 ^ k)).2.1]
    exact ⟨4 * (2 ^ k + 1), by ring⟩
  · rw [(berg_children_diff (2 ^ k + 1, 2 ^ k)).2.2]
    exact ⟨8 * (2 ^ k + 1), by ring⟩
  · intro hc
    have h := congrArg (fun x => x.2.1) hc
    simp only [tripleZ, actGen] at h
    nlinarith [h]

end Price2Adic