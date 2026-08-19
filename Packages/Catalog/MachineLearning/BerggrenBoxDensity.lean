import MachineLearning.BerggrenEuclidParam
import MachineLearning.BerggrenCoprimeSieve

/-!
# How many triples in a box are Berggren-generated?

Fix a height `H` and consider the cube `box H = {(a,b,c) : 0 < a,b,c ≤ H}`, which contains
`H³` triples.  This file answers two counting questions about the Berggren tree inside it.

## Main results

* `boxNode_card_le` : `#(boxNode H) ≤ H` — an unconditional linear upper bound, obtained
  from the Euclid parametrisation (`m ≤ √H`, `n < m`).
* `boxNode_card_ge` : `H ≤ 128 * #(boxNode H)` for `H ≥ 32` — a matching linear lower
  bound, obtained from the sieve of `MachineLearning.BerggrenCoprimeSieve`.
* `boxNode_card_theta` : the two together, i.e. `#(boxNode H) = Θ(H)`.
* `boxNode_density_zero` : `#(boxNode H)/H³ → 0`; Berggren-generated triples are a
  vanishing fraction of the cube.
* `boxBerggren_eq_boxPPT` : the union of the two Berggren trees (seeds `(3,4,5)` and
  `(4,3,5)`) meets the cube in **exactly** the set of primitive Pythagorean triples,
  so the `(1 - o(1))` of the mission statement is in fact an exact `1`.
* `boxNode_card_eq_half` : with the **single** seed `(3,4,5)` the ratio is exactly `1/2`,
  not `1 - o(1)` — the mission statement needs both seeds.  This is the sharp boundary of
  the claim.
-/

namespace BerggrenStars

open Finset

/-! ### The box and its Berggren subsets -/

/-- The cube `{(a,b,c) : 1 ≤ a,b,c ≤ H}` of integer triples. -/
def box (H : ℕ) : Finset Vec :=
  Finset.Icc (1 : ℤ) (H : ℤ) ×ˢ Finset.Icc (1 : ℤ) (H : ℤ) ×ˢ Finset.Icc (1 : ℤ) (H : ℤ)

theorem mem_box {H : ℕ} {v : Vec} :
    v ∈ box H ↔ (1 ≤ v.1 ∧ v.1 ≤ H) ∧ (1 ≤ v.2.1 ∧ v.2.1 ≤ H) ∧ (1 ≤ v.2.2 ∧ v.2.2 ≤ H) := by
  simp only [box, Finset.mem_product, Finset.mem_Icc]

theorem card_box (H : ℕ) : (box H).card = H ^ 3 := by
  simp only [box, Finset.card_product]
  simp [pow_succ, Nat.mul_comm]

/-- The Berggren-generated triples in the box (seed `(3,4,5)`), described by the decidable
arithmetic characterisation proved in `BerggrenEuclidParam`. -/
def boxNode (H : ℕ) : Finset Vec :=
  (box H).filter fun v => 0 < v.1 ∧ 0 < v.2.1 ∧ 0 < v.2.2 ∧
    v.1 ^ 2 + v.2.1 ^ 2 = v.2.2 ^ 2 ∧ Int.gcd v.1 v.2.1 = 1 ∧ v.1 % 2 = 1

/-- The mirrored tree (seed `(4,3,5)`) inside the box. -/
def boxNodeSwap (H : ℕ) : Finset Vec :=
  (box H).filter fun v => 0 < v.1 ∧ 0 < v.2.1 ∧ 0 < v.2.2 ∧
    v.1 ^ 2 + v.2.1 ^ 2 = v.2.2 ^ 2 ∧ Int.gcd v.1 v.2.1 = 1 ∧ v.2.1 % 2 = 1

/-- All primitive Pythagorean triples in the box. -/
def boxPPT (H : ℕ) : Finset Vec :=
  (box H).filter fun v => 0 < v.1 ∧ 0 < v.2.1 ∧ 0 < v.2.2 ∧
    v.1 ^ 2 + v.2.1 ^ 2 = v.2.2 ^ 2 ∧ Int.gcd v.1 v.2.1 = 1

theorem mem_boxNode {H : ℕ} {v : Vec} : v ∈ boxNode H ↔ v ∈ box H ∧ IsNode v := by
  obtain ⟨a, b, c⟩ := v
  simp only [boxNode, Finset.mem_filter, isNode_iff]
  constructor
  · rintro ⟨h, h1, h2, h3, h4, h5, h6⟩
    exact ⟨h, h1, h2, h3, h4, h5, Int.odd_iff.mpr h6⟩
  · rintro ⟨h, h1, h2, h3, h4, h5, h6⟩
    exact ⟨h, h1, h2, h3, h4, h5, Int.odd_iff.mp h6⟩

theorem mem_boxNodeSwap {H : ℕ} {v : Vec} : v ∈ boxNodeSwap H ↔ v ∈ box H ∧ IsNodeSwap v := by
  obtain ⟨a, b, c⟩ := v
  simp only [boxNodeSwap, Finset.mem_filter, isNodeSwap_iff]
  constructor
  · rintro ⟨h, h1, h2, h3, h4, h5, h6⟩
    exact ⟨h, h1, h2, h3, h4, h5, Int.odd_iff.mpr h6⟩
  · rintro ⟨h, h1, h2, h3, h4, h5, h6⟩
    exact ⟨h, h1, h2, h3, h4, h5, Int.odd_iff.mp h6⟩

theorem mem_boxPPT {H : ℕ} {v : Vec} : v ∈ boxPPT H ↔ v ∈ box H ∧ IsPPT v.1 v.2.1 v.2.2 := by
  simp only [boxPPT, Finset.mem_filter, IsPPT]

/-! ### The linear upper bound -/

/-- The Euclid parameter `m` read off from a node. -/
private def paramM (v : Vec) : ℕ := Nat.sqrt ((v.1 + v.2.2) / 2).toNat

/-- The Euclid parameter `n` read off from a node. -/
private def paramN (v : Vec) : ℕ := Nat.sqrt ((v.2.2 - v.1) / 2).toNat

private theorem param_of_euclid {m n : ℤ} (hm : 0 < m) (hn : 0 < n) :
    paramM (euclidTriple m n) = m.toNat ∧ paramN (euclidTriple m n) = n.toNat := by
  have h1 : ((euclidTriple m n).1 + (euclidTriple m n).2.2) / 2 = m ^ 2 := by
    simp only [euclidTriple]
    omega
  have h2 : ((euclidTriple m n).2.2 - (euclidTriple m n).1) / 2 = n ^ 2 := by
    simp only [euclidTriple]
    omega
  have hmt : ((m.toNat : ℤ)) = m := Int.toNat_of_nonneg hm.le
  have hnt : ((n.toNat : ℤ)) = n := Int.toNat_of_nonneg hn.le
  constructor
  · simp only [paramM, h1]
    have hsq : (m ^ 2).toNat = m.toNat * m.toNat := by
      have : m ^ 2 = ((m.toNat * m.toNat : ℕ) : ℤ) := by push_cast [hmt]; ring
      rw [this, Int.toNat_natCast]
    rw [hsq, Nat.sqrt_eq]
  · simp only [paramN, h2]
    have hsq : (n ^ 2).toNat = n.toNat * n.toNat := by
      have : n ^ 2 = ((n.toNat * n.toNat : ℕ) : ℤ) := by push_cast [hnt]; ring
      rw [this, Int.toNat_natCast]
    rw [hsq, Nat.sqrt_eq]

/-- **Linear upper bound.**  At most `H` triples of the cube are Berggren-generated. -/
theorem boxNode_card_le (H : ℕ) : (boxNode H).card ≤ H := by
  have hcard : (Finset.Icc 1 (Nat.sqrt H) ×ˢ Finset.Icc 1 (Nat.sqrt H)).card ≤ H := by
    rw [Finset.card_product, Nat.card_Icc]
    simpa using Nat.sqrt_le H
  refine le_trans ?_ hcard
  refine Finset.card_le_card_of_injOn (fun v => (paramM v, paramN v)) ?_ ?_
  · intro v hv
    obtain ⟨hbox, hnode⟩ := mem_boxNode.mp hv
    obtain ⟨m, n, hpar, rfl⟩ := isNode_param hnode
    obtain ⟨e1, e2⟩ := param_of_euclid hpar.mpos hpar.npos
    have hcle : (euclidTriple m n).2.2 ≤ (H : ℤ) := (mem_box.mp hbox).2.2.2
    have hm2 : m ^ 2 ≤ (H : ℤ) := by
      simp only [euclidTriple] at hcle
      nlinarith [hpar.npos]
    have hmH : m.toNat * m.toNat ≤ H := by
      have hmt : ((m.toNat : ℤ)) = m := Int.toNat_of_nonneg hpar.mpos.le
      have hcast : ((m.toNat * m.toNat : ℕ) : ℤ) = m ^ 2 := by push_cast [hmt]; ring
      have : ((m.toNat * m.toNat : ℕ) : ℤ) ≤ (H : ℤ) := by rw [hcast]; exact hm2
      exact_mod_cast this
    have hnm : n.toNat ≤ m.toNat := by
      have := hpar.lt
      omega
    simp only [Finset.mem_coe, Finset.mem_product, Finset.mem_Icc, e1, e2]
    refine ⟨⟨by have := hpar.mpos; omega, Nat.le_sqrt.mpr hmH⟩,
      ⟨by have := hpar.npos; omega, le_trans hnm (Nat.le_sqrt.mpr hmH)⟩⟩
  · intro v hv w hw hvw
    simp only [Finset.mem_coe] at hv hw
    obtain ⟨-, hnv⟩ := mem_boxNode.mp hv
    obtain ⟨-, hnw⟩ := mem_boxNode.mp hw
    obtain ⟨m, n, hpar, rfl⟩ := isNode_param hnv
    obtain ⟨m', n', hpar', rfl⟩ := isNode_param hnw
    obtain ⟨e1, e2⟩ := param_of_euclid hpar.mpos hpar.npos
    obtain ⟨e1', e2'⟩ := param_of_euclid hpar'.mpos hpar'.npos
    have f1 : m.toNat = m'.toNat := by
      have := congrArg Prod.fst hvw; simpa [e1, e1'] using this
    have f2 : n.toNat = n'.toNat := by
      have := congrArg Prod.snd hvw; simpa [e2, e2'] using this
    have hm : m = m' := by
      have := hpar.mpos; have := hpar'.mpos; omega
    have hn : n = n' := by
      have := hpar.npos; have := hpar'.npos; omega
    rw [hm, hn]

/-! ### The linear lower bound -/

/-- **Linear lower bound.**  For `H ≥ 32` at least `H/128` triples of the cube are
Berggren-generated. -/
theorem boxNode_card_ge (H : ℕ) (hH : 32 ≤ H) : H ≤ 128 * (boxNode H).card := by
  set N := Nat.sqrt (H / 2) with hN
  have hN4 : 4 ≤ N := by
    rw [hN]
    have : 16 ≤ H / 2 := by omega
    calc 4 = Nat.sqrt 16 := by norm_num
    _ ≤ Nat.sqrt (H / 2) := Nat.sqrt_le_sqrt this
  have hNsq : N * N ≤ H / 2 := Nat.sqrt_le (H / 2)
  have hNsq2 : 2 * (N * N) ≤ H := by omega
  have hHN : H ≤ 8 * (N * N) := by
    have h1 : H / 2 < (N + 1) * (N + 1) := Nat.lt_succ_sqrt (H / 2)
    have h2 : (N + 1) * (N + 1) ≤ 4 * (N * N) := by nlinarith
    omega
  -- the injection from coprime Euclid pairs into the box
  have hinj : (BerggrenSieve.coprimePairs N).card ≤ (boxNode H).card := by
    refine Finset.card_le_card_of_injOn
      (fun p => euclidTriple (p.1 : ℤ) (p.2 : ℤ)) ?_ ?_
    · intro p hp
      simp only [Finset.mem_coe] at hp
      obtain ⟨h1, h2, h3, h4, h5⟩ := BerggrenSieve.mem_coprimePairs.mp hp
      have hm : (0 : ℤ) < (p.1 : ℤ) := by exact_mod_cast Nat.lt_of_lt_of_le h1 (le_of_lt h2)
      have hn : (0 : ℤ) < (p.2 : ℤ) := by exact_mod_cast h1
      have hnm : (p.2 : ℤ) < (p.1 : ℤ) := by exact_mod_cast h2
      have hpar : IsParam (p.1 : ℤ) (p.2 : ℤ) := by
        refine ⟨hn, hnm, ?_, ?_⟩
        · simpa using h5
        · rw [Int.odd_iff]
          omega
      have hbound : (p.1 : ℤ) ^ 2 + (p.2 : ℤ) ^ 2 ≤ (H : ℤ) := by
        have hp1 : p.1 * p.1 ≤ N * N := Nat.mul_le_mul h3 h3
        have hp2 : p.2 * p.2 ≤ N * N := Nat.mul_le_mul (le_of_lt (lt_of_lt_of_le h2 h3))
          (le_of_lt (lt_of_lt_of_le h2 h3))
        have : p.1 * p.1 + p.2 * p.2 ≤ H := by omega
        have hc : ((p.1 * p.1 + p.2 * p.2 : ℕ) : ℤ) ≤ (H : ℤ) := by exact_mod_cast this
        push_cast at hc
        nlinarith [hc]
      rw [Finset.mem_coe, mem_boxNode]
      refine ⟨?_, param_isNode hpar⟩
      rw [mem_box]
      simp only [euclidTriple]
      refine ⟨⟨by nlinarith, by nlinarith⟩, ⟨by nlinarith, by nlinarith⟩,
        ⟨by nlinarith, by nlinarith⟩⟩
    · intro p hp q hq hpq
      simp only [Finset.mem_coe] at hp hq
      obtain ⟨h1, h2, -, -, -⟩ := BerggrenSieve.mem_coprimePairs.mp hp
      obtain ⟨g1, g2, -, -, -⟩ := BerggrenSieve.mem_coprimePairs.mp hq
      have hm : (0 : ℤ) < (p.1 : ℤ) := by exact_mod_cast Nat.lt_of_lt_of_le h1 (le_of_lt h2)
      have hn : (0 : ℤ) < (p.2 : ℤ) := by exact_mod_cast h1
      have hm' : (0 : ℤ) < (q.1 : ℤ) := by exact_mod_cast Nat.lt_of_lt_of_le g1 (le_of_lt g2)
      have hn' : (0 : ℤ) < (q.2 : ℤ) := by exact_mod_cast g1
      obtain ⟨e1, e2⟩ := euclidTriple_injective hm hn hm' hn' hpq
      exact Prod.ext (by exact_mod_cast e1) (by exact_mod_cast e2)
  have hsieve : N ^ 2 ≤ 16 * (BerggrenSieve.coprimePairs N).card :=
    BerggrenSieve.card_coprimePairs_lower N hN4
  have : N ^ 2 = N * N := sq N
  omega

/-- **`Θ(H)`.**  The number of Berggren-generated triples in the cube `[1,H]³` is
between `H/128` and `H`. -/
theorem boxNode_card_theta (H : ℕ) (hH : 32 ≤ H) :
    H ≤ 128 * (boxNode H).card ∧ (boxNode H).card ≤ H :=
  ⟨boxNode_card_ge H hH, boxNode_card_le H⟩

/-! ### Vanishing density in the cube -/

open Filter Topology in
/-- **Berggren-generated triples are a vanishing fraction of the cube.** -/
theorem boxNode_density_zero :
    Tendsto (fun H : ℕ => ((boxNode H).card : ℝ) / (H : ℝ) ^ 3) atTop (𝓝 0) := by
  apply squeeze_zero' (g := fun H : ℕ => 1 / (H : ℝ))
  · filter_upwards with H
    positivity
  · filter_upwards [eventually_ge_atTop 1] with H hH
    have hH0 : (1 : ℝ) ≤ (H : ℝ) := by exact_mod_cast hH
    have hcard : ((boxNode H).card : ℝ) ≤ (H : ℝ) := by exact_mod_cast boxNode_card_le H
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hcard, hH0, sq_nonneg ((H : ℝ) - 1)]
  · exact tendsto_one_div_atTop_nhds_zero_nat

/-! ### Both seeds: an exact identity, not just `1 - o(1)` -/

/-- The two Berggren trees together fill out the primitive Pythagorean triples of the
cube **exactly**. -/
theorem boxBerggren_eq_boxPPT (H : ℕ) : boxNode H ∪ boxNodeSwap H = boxPPT H := by
  ext v
  rw [Finset.mem_union, mem_boxNode, mem_boxNodeSwap, mem_boxPPT]
  constructor
  · rintro (⟨hb, hn⟩ | ⟨hb, hn⟩)
    · exact ⟨hb, (isPPT_iff_node_or_swap v.1 v.2.1 v.2.2).mpr (Or.inl hn)⟩
    · exact ⟨hb, (isPPT_iff_node_or_swap v.1 v.2.1 v.2.2).mpr (Or.inr hn)⟩
  · rintro ⟨hb, hp⟩
    rcases (isPPT_iff_node_or_swap v.1 v.2.1 v.2.2).mp hp with h | h
    · exact Or.inl ⟨hb, h⟩
    · exact Or.inr ⟨hb, h⟩

theorem boxNode_disjoint_boxNodeSwap (H : ℕ) : Disjoint (boxNode H) (boxNodeSwap H) := by
  rw [Finset.disjoint_left]
  intro v hv hv'
  obtain ⟨-, h1⟩ := mem_boxNode.mp hv
  obtain ⟨-, h2⟩ := mem_boxNodeSwap.mp hv'
  exact not_isNode_and_isNodeSwap v.1 v.2.1 v.2.2 ⟨h1, h2⟩

/-- The leg swap is a bijection between the two trees inside the (symmetric) cube. -/
theorem card_boxNodeSwap (H : ℕ) : (boxNodeSwap H).card = (boxNode H).card := by
  refine Finset.card_bij' (fun v _ => swapVec v) (fun v _ => swapVec v) ?_ ?_ ?_ ?_
  · intro v hv
    obtain ⟨hb, hn⟩ := mem_boxNodeSwap.mp hv
    rw [mem_boxNode]
    refine ⟨?_, isNodeSwap_iff_isNode.mp hn⟩
    rw [mem_box] at hb ⊢
    exact ⟨hb.2.1, hb.1, hb.2.2⟩
  · intro v hv
    obtain ⟨hb, hn⟩ := mem_boxNode.mp hv
    rw [mem_boxNodeSwap]
    refine ⟨?_, isNodeSwap_iff_isNode.mpr (by rwa [swapVec_swapVec])⟩
    rw [mem_box] at hb ⊢
    exact ⟨hb.2.1, hb.1, hb.2.2⟩
  · intro v _
    exact swapVec_swapVec v
  · intro v _
    exact swapVec_swapVec v

/-- **The count with both seeds is exactly the number of primitive Pythagorean triples
in the box** — the `(1 - o(1))` of the informal statement is an exact `1`. -/
theorem card_boxBerggren_eq_card_boxPPT (H : ℕ) :
    (boxNode H ∪ boxNodeSwap H).card = (boxPPT H).card := by
  rw [boxBerggren_eq_boxPPT]

/-- **The sharp boundary of the claim.**  With the *single* seed `(3,4,5)` the ratio is
exactly `1/2` for every `H`, so the `(1 - o(1))` statement is false for one seed and true
(indeed exact) for two. -/
theorem card_boxPPT_eq_two_mul (H : ℕ) : (boxPPT H).card = 2 * (boxNode H).card := by
  rw [← boxBerggren_eq_boxPPT, Finset.card_union_of_disjoint (boxNode_disjoint_boxNodeSwap H),
    card_boxNodeSwap]
  ring

end BerggrenStars