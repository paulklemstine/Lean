import Mathlib
import Catalog.NumberTheory.BerggrenBoxCounting

/-!
# The Berggren box count is a visible-lattice-point count

`Catalog.NumberTheory.BerggrenBoxCounting` proves that the number of Berggren-generated
triples in the box `[1,H]³` is `Θ(H)`.  The present file identifies that count *exactly*
with a lattice point count in a quarter disc:

> `#(bergBox H) = #{(n,m) : 1 ≤ n < m, gcd(n,m) = 1, n + m odd, m² + n² ≤ H}`.

The bijection is Euclid's parametrisation `(n,m) ↦ (m² − n², 2mn, m² + n²)`; injectivity is
elementary and surjectivity is the primitive classification of Pythagorean triples together
with Berggren's completeness theorem (`BerggrenTree.reach_iff_valid`).

This is the structural bridge to the sharp asymptotic constant: the right-hand side is the
number of *visible* (i.e. primitive) lattice points of opposite parity in a quarter disc of
radius `√H`, whose density is `1/(2π)` per unit area after the parity and coprimality
corrections.  All the analytic content of the `Θ(H)` statement is therefore concentrated in
one classical lattice point count.
-/

namespace BerggrenBoxCounting

open BerggrenTree

/-- The Euclid parameters attached to the box `[1,H]³`: pairs `1 ≤ n < m` that are coprime,
of opposite parity, and satisfy `m² + n² ≤ H`. -/
def pairBox (H : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.Icc 1 H ×ˢ Finset.Icc 1 H).filter
    (fun p => p.1 < p.2 ∧ Nat.gcd p.1 p.2 = 1 ∧ (p.1 + p.2) % 2 = 1 ∧ p.2 ^ 2 + p.1 ^ 2 ≤ H)

lemma mem_pairBox {H : ℕ} {p : ℕ × ℕ} :
    p ∈ pairBox H ↔ 1 ≤ p.1 ∧ p.1 < p.2 ∧ Nat.gcd p.1 p.2 = 1 ∧
      (p.1 + p.2) % 2 = 1 ∧ p.2 ^ 2 + p.1 ^ 2 ≤ H := by
  simp only [pairBox, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · rintro ⟨⟨⟨h1, -⟩, -⟩, h2, h3, h4, h5⟩
    exact ⟨h1, h2, h3, h4, h5⟩
  · rintro ⟨h1, h2, h3, h4, h5⟩
    have hsq : p.2 ≤ p.2 ^ 2 := Nat.le_self_pow (by norm_num) _
    exact ⟨⟨⟨h1, by omega⟩, ⟨by omega, by omega⟩⟩, h2, h3, h4, h5⟩

/-- Euclid's parametrisation of a primitive Pythagorean triple. -/
def euclid (p : ℕ × ℕ) : Tri :=
  ((p.2 : ℤ) ^ 2 - (p.1 : ℤ) ^ 2, 2 * (p.2 : ℤ) * (p.1 : ℤ), (p.2 : ℤ) ^ 2 + (p.1 : ℤ) ^ 2)

lemma euclid_mem {H : ℕ} {p : ℕ × ℕ} (hp : p ∈ pairBox H) : euclid p ∈ bergBox H := by
  obtain ⟨hn1, hnm, hg, hpar, hsize⟩ := mem_pairBox.mp hp
  have hval := pair_valid hn1 hnm hg hpar
  have hsizeZ : ((p.2 : ℤ)) ^ 2 + ((p.1 : ℤ)) ^ 2 ≤ (H : ℤ) := by exact_mod_cast hsize
  have hn0 : (0 : ℤ) < (p.1 : ℤ) := by exact_mod_cast hn1
  have hnm' : ((p.1 : ℤ)) < (p.2 : ℤ) := by exact_mod_cast hnm
  refine mem_bergBox.mpr ⟨(reach_iff_valid _).mpr hval, ?_, ?_, ?_⟩
  · simp only [euclid]; nlinarith
  · simp only [euclid]; nlinarith
  · simpa [euclid] using hsizeZ

lemma euclid_injOn {H : ℕ} : ∀ p ∈ pairBox H, ∀ q ∈ pairBox H, euclid p = euclid q → p = q := by
  rintro ⟨n, m⟩ - ⟨n', m'⟩ - heq
  simp only [euclid, Prod.mk.injEq] at heq
  obtain ⟨e1, -, e3⟩ := heq
  have hm : ((m : ℤ)) ^ 2 = ((m' : ℤ)) ^ 2 := by linarith
  have hn : ((n : ℤ)) ^ 2 = ((n' : ℤ)) ^ 2 := by linarith
  have hmn : m ^ 2 = m' ^ 2 := by exact_mod_cast hm
  have hnn : n ^ 2 = n' ^ 2 := by exact_mod_cast hn
  have hm' : m = m' := Nat.pow_left_injective (by norm_num) hmn
  have hn' : n = n' := Nat.pow_left_injective (by norm_num) hnn
  simp [hm', hn']

/-- Every Berggren-generated triple of the box is `euclid` of a pair of the parameter box.
This is where the primitive classification of Pythagorean triples enters. -/
lemma euclid_surjOn {H : ℕ} {t : Tri} (ht : t ∈ bergBox H) :
    ∃ p ∈ pairBox H, euclid p = t := by
  obtain ⟨hr, -, -, h3⟩ := mem_bergBox.mp ht
  obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := reach_valid hr
  obtain ⟨a, b, c⟩ := t
  simp only at ha hb hc hpy hgcd hodd h3
  have hpt : PythagoreanTriple a b c := by
    unfold PythagoreanTriple
    nlinarith [hpy]
  obtain ⟨m, n, hx, hy, hz, hco, hpar, hm0⟩ := hpt.coprime_classification' hgcd hodd hc
  -- both parameters are positive
  have hmpos : 0 < m := by
    rcases lt_or_eq_of_le hm0 with h | h
    · exact h
    · exfalso; rw [← h] at hy; simp at hy; omega
  have hnpos : 0 < n := by nlinarith [hb, hy, hmpos]
  have hnm : n < m := by nlinarith [ha, hx]
  set M : ℕ := m.natAbs with hM
  set N : ℕ := n.natAbs with hN
  have hMz : (M : ℤ) = m := Int.natAbs_of_nonneg (le_of_lt hmpos)
  have hNz : (N : ℤ) = n := Int.natAbs_of_nonneg (le_of_lt hnpos)
  have hgMN : Nat.gcd N M = 1 := by
    rw [Nat.gcd_comm]
    exact hco
  refine ⟨(N, M), mem_pairBox.mpr ⟨?_, ?_, hgMN, ?_, ?_⟩, ?_⟩
  · omega
  · omega
  · omega
  · have : ((M : ℤ)) ^ 2 + ((N : ℤ)) ^ 2 ≤ (H : ℤ) := by rw [hMz, hNz]; omega
    exact_mod_cast this
  · simp only [euclid, Prod.mk.injEq, hMz, hNz]
    exact ⟨hx.symm, hy.symm, hz.symm⟩

/-- **The Berggren box count is exactly a count of coprime opposite-parity lattice points in
the quarter disc of radius `√H`.** -/
theorem card_bergBox_eq_card_pairBox (H : ℕ) : (bergBox H).card = (pairBox H).card := by
  classical
  refine (Finset.card_bij (fun p _ => euclid p) (fun p hp => euclid_mem hp)
    (fun p hp q hq h => euclid_injOn p hp q hq h) ?_).symm
  intro t ht
  obtain ⟨p, hp, hpt⟩ := euclid_surjOn ht
  exact ⟨p, hp, hpt⟩

/-- The ordered primitive Pythagorean triples of the box are counted with multiplicity two by
the Euclid parameters. -/
theorem card_ppBox_eq_two_mul_card_pairBox (H : ℕ) :
    (ppBox H).card = 2 * (pairBox H).card := by
  rw [card_ppBox_eq_two_mul_card_bergBox, card_bergBox_eq_card_pairBox]

/-- Transporting the effective `Θ(H)` bounds through the bijection: the number of coprime
opposite-parity lattice points in the quarter disc of radius `√H` is `Θ(H)`. -/
theorem pairBox_theta (H : ℕ) (hH : 5 ≤ H) :
    H ≤ 100 * (pairBox H).card ∧ (pairBox H).card ≤ (Nat.sqrt H + 1) ^ 2 := by
  rw [← card_bergBox_eq_card_pairBox]
  exact ⟨bergBox_card_ge H hH, bergBox_card_le_sq_succ_sqrt H⟩

end BerggrenBoxCounting