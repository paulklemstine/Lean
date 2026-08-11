import Mathlib
import Novelty.NeuralCodeCapacityBounds

/-!
# Neural Coding: tightness of the Plotkin bound (Hadamard populations)

`Catalog/Novelty/NeuralCodeCapacityBounds.lean` proves the Plotkin bound: a
`d`-separated codebook on `N` neurons with `N < 2d` satisfies
`|C| * (2d - N) ≤ 2d`.  At the boundary `N = 2d` that inequality degenerates,
and the correct statement `A(2d, d) ≤ 4d` needs a *shortening* argument.  This
file proves that bound and shows it is **attained** whenever `2d` is a power of
two, by the affine (first-order Reed–Muller / Hadamard) neural code.

## Main results

* `maxCodeSize_shorten` — shortening on one neuron: `A(N+1, d) ≤ 2 * A(N, d)`.
* `plotkin_boundary` — the boundary Plotkin bound `A(2d, d) ≤ 4d`.
* `affineCode_separated`, `card_affineCode` — the affine code on `2 ^ (m+1)`
  neurons has `2 ^ (m+2)` codewords, pairwise at Hamming distance at least
  `2 ^ m`.
* `hadamard_capacity` — **Plotkin is tight**: `A(2 ^ (m+1), 2 ^ m) = 2 ^ (m+2)`.
  A population of `N = 2 ^ (m+1)` neurons that must tolerate `2 ^ m - 1`
  misfirings represents exactly `2N` concepts, realised by the affine code.
* `hadamard_capacity_half` — the same statement written as
  `A(N, N/2) = 2N` for `N` a power of two.
* `hadamard_capacity_rate` — the corresponding rate statement.

The smallest instances agree with the exhaustive search recorded in
`ComputationalEvidence.md`: `A(2,1) = 4` and `A(4,2) = 8`.
-/

namespace NeuralCodePlotkinTightness

open Finset NeuralCodeCapacity

/-! ## Shortening: `A(N+1, d) ≤ 2 * A(N, d)` -/

/-- Codewords of a `d`-separated codebook that agree on the last neuron stay
`d`-separated, and remain distinct, after that neuron is deleted. -/
theorem card_filter_last_le {N d : ℕ} {C : Finset (NeuralCode (N + 1))}
    (hC : Separated d C) (b : Bool) (hd : 1 ≤ d) :
    (C.filter fun x => x (Fin.last N) = b).card ≤ maxCodeSize N d := by
  classical
  set D := C.filter fun x => x (Fin.last N) = b with hD
  have hlast : ∀ x ∈ D, x (Fin.last N) = b := by
    intro x hx; exact (Finset.mem_filter.mp hx).2
  have hmem : ∀ x ∈ D, x ∈ C := fun x hx => (Finset.mem_filter.mp hx).1
  have hdist : ∀ x ∈ D, ∀ y ∈ D, x ≠ y → d ≤ hammingDist (punct x) (punct y) := by
    intro x hx y hy hxy
    have h1 := hC x (hmem x hx) y (hmem y hy) hxy
    have h2 := dist_punct x y
    rw [hlast x hx, hlast y hy] at h2
    simp at h2
    omega
  have hinj : Set.InjOn (punct (N := N)) (D : Set (NeuralCode (N + 1))) := by
    intro x hx y hy hxy
    by_contra hne
    have := hdist x (Finset.mem_coe.mp hx) y (Finset.mem_coe.mp hy) hne
    rw [hxy, hammingDist_self] at this
    omega
  have hsep : Separated d (D.image punct) := by
    intro u hu v hv huv
    simp only [Finset.mem_image] at hu hv
    obtain ⟨x, hx, rfl⟩ := hu
    obtain ⟨y, hy, rfl⟩ := hv
    exact hdist x hx y hy (fun h => huv (by rw [h]))
  have := card_le_maxCodeSize hsep
  rwa [Finset.card_image_of_injOn hinj] at this

/-- **Shortening bound.**  Deleting one neuron at most halves the number of
concepts: `A(N+1, d) ≤ 2 * A(N, d)`. -/
theorem maxCodeSize_shorten (N d : ℕ) (hd : 1 ≤ d) :
    maxCodeSize (N + 1) d ≤ 2 * maxCodeSize N d := by
  classical
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize (N + 1) d
  have hfalse : (C.filter fun x => ¬ (x (Fin.last N) = true))
      = (C.filter fun x => x (Fin.last N) = false) := by
    apply Finset.filter_congr
    intro x _
    simp
  have hsplit :
      (C.filter fun x => x (Fin.last N) = true).card
        + (C.filter fun x => x (Fin.last N) = false).card = C.card := by
    rw [← hfalse]
    exact Finset.card_filter_add_card_filter_not _
  have h1 := card_filter_last_le hC true hd
  have h0 := card_filter_last_le hC false hd
  omega

/-- **Plotkin bound at the boundary.**  A population of `2d` neurons whose
concepts must differ on at least `d` neurons represents at most `4d` concepts.
(The plain Plotkin inequality degenerates at `N = 2d`; shortening on one neuron
recovers the bound.) -/
theorem plotkin_boundary (d : ℕ) (hd : 1 ≤ d) : maxCodeSize (2 * d) d ≤ 4 * d := by
  obtain ⟨m, rfl⟩ : ∃ m, d = m + 1 := ⟨d - 1, by omega⟩
  have hshort : maxCodeSize (2 * (m + 1)) (m + 1) ≤ 2 * maxCodeSize (2 * m + 1) (m + 1) := by
    rw [show 2 * (m + 1) = (2 * m + 1) + 1 by ring]
    exact maxCodeSize_shorten _ _ (by omega)
  have hplot := plotkin_bound_maxCodeSize (N := 2 * m + 1) (d := m + 1) (by omega)
  have he : 2 * (m + 1) - (2 * m + 1) = 1 := by omega
  rw [he, Nat.mul_one] at hplot
  omega

/-! ## The affine (Hadamard) neural code

Neurons are indexed by the `2 ^ k` binary strings of length `k`; a concept is a
pair `(a, b)` with `a` a string of length `k` and `b` a bit, and the pattern it
evokes fires neuron `x` exactly when the affine form `⟨a, x⟩ + b` is odd. -/

/-- A bit read as an element of `ℤ/2`. -/
def bit (b : Bool) : ZMod 2 := if b then 1 else 0

lemma bit_xor (b b' : Bool) : bit (xor b b') = bit b + bit b' := by
  cases b <;> cases b' <;> decide

lemma bit_not (b : Bool) : bit (!b) = bit b + 1 := by cases b <;> decide

/-- The `ℤ/2`-valued inner product of two binary strings. -/
def ip {k : ℕ} (a x : Fin k → Bool) : ZMod 2 := ∑ i, bit (a i) * bit (x i)

/-- The zero string is orthogonal to everything. -/
lemma ip_zero {k : ℕ} (x : Fin k → Bool) : ip (fun _ => false) x = 0 := by
  simp [ip, bit]

/-- Additivity of the inner product in its first argument. -/
lemma ip_add {k : ℕ} (a a' x : Fin k → Bool) :
    ip a x + ip a' x = ip (fun i => xor (a i) (a' i)) x := by
  unfold ip
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [bit_xor]
  ring

/-- Flipping the `j`-th bit of `x` changes `⟨a, x⟩` exactly when `a j` is set. -/
lemma ip_update {k : ℕ} (a x : Fin k → Bool) (j : Fin k) (ha : a j = true) :
    ip a (Function.update x j (!x j)) = ip a x + 1 := by
  classical
  unfold ip
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j),
      ← Finset.add_sum_erase Finset.univ (fun i => bit (a i) * bit (x i))
        (Finset.mem_univ j)]
  have hrest : ∀ i ∈ (Finset.univ : Finset (Fin k)).erase j,
      bit (a i) * bit (Function.update x j (!x j) i) = bit (a i) * bit (x i) := by
    intro i hi
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hi)]
  rw [Finset.sum_congr rfl hrest, Function.update_self, ha, bit_not]
  simp only [bit, if_true]
  ring

/-- **Half of all strings are orthogonal.**  For a nonzero string `u` and either
value `c`, exactly `2 ^ k / 2` strings `x` satisfy `⟨u, x⟩ = c`. -/
theorem card_ip_eq {k : ℕ} {u : Fin k → Bool} (hu : ∃ j, u j = true) (c : ZMod 2) :
    ((Finset.univ : Finset (Fin k → Bool)).filter fun x => ip u x = c).card
      = 2 ^ k / 2 := by
  classical
  obtain ⟨j, hj⟩ := hu
  -- flipping the `j`-th bit is a bijection between the two level sets
  have hbij : ∀ c : ZMod 2,
      ((Finset.univ : Finset (Fin k → Bool)).filter fun x => ip u x = c).card
        = ((Finset.univ : Finset (Fin k → Bool)).filter fun x => ip u x = c + 1).card := by
    intro c
    refine Finset.card_nbij' (fun x => Function.update x j (!x j))
      (fun x => Function.update x j (!x j)) ?_ ?_ ?_ ?_
    · intro x hx
      simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
      rw [ip_update u x j hj, hx]
    · intro x hx
      simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
      rw [ip_update u x j hj, hx]
      generalize c = z
      revert z
      decide
    · intro x _
      funext i
      by_cases h : i = j
      · subst h; simp
      · simp [Function.update_of_ne h]
    · intro x _
      funext i
      by_cases h : i = j
      · subst h; simp
      · simp [Function.update_of_ne h]
  -- the two level sets partition all strings
  have hsplit :
      ((Finset.univ : Finset (Fin k → Bool)).filter fun x => ip u x = 0).card
        + ((Finset.univ : Finset (Fin k → Bool)).filter fun x => ip u x = 1).card
        = 2 ^ k := by
    have hcompl : ((Finset.univ : Finset (Fin k → Bool)).filter fun x => ip u x = 1)
        = ((Finset.univ : Finset (Fin k → Bool)).filter fun x => ¬ (ip u x = 0)) := by
      refine Finset.filter_congr fun x _ => ?_
      generalize ip u x = z
      revert z
      decide
    rw [hcompl, Finset.card_filter_add_card_filter_not]
    simp
  have h01 := hbij 0
  have h0 : (0 : ZMod 2) + 1 = 1 := by decide
  rw [h0] at h01
  have hc : c = 0 ∨ c = 1 := by revert c; decide
  rcases hc with rfl | rfl <;> omega

/-- The codeword of the concept `(a, b)`: neuron `x` fires iff `⟨a,x⟩ + b` is
odd. -/
def affineWord {k : ℕ} (a : Fin k → Bool) (b : Bool) (x : Fin k → Bool) : Bool :=
  decide (ip a x + bit b = 1)

/-- Two affine codewords disagree at `x` exactly on a level set of the
difference of their linear parts. -/
lemma affineWord_ne_iff {k : ℕ} (a a' x : Fin k → Bool) (b b' : Bool) :
    (affineWord a b x ≠ affineWord a' b' x)
      ↔ ip (fun i => xor (a i) (a' i)) x = bit b + bit b' + 1 := by
  unfold affineWord
  rw [← ip_add]
  generalize ip a x = z
  generalize ip a' x = w
  cases b <;> cases b' <;> revert z w <;> decide

/-- Two distinct concepts of the affine code evoke patterns differing on at
least half the neurons. -/
theorem affineWord_dist {k : ℕ} (a a' : Fin k → Bool) (b b' : Bool)
    (h : (a, b) ≠ (a', b')) :
    2 ^ k / 2 ≤ hammingDist (affineWord a b) (affineWord a' b') := by
  classical
  by_cases haa : a = a'
  · -- same linear part, different constant: the patterns are complementary
    subst haa
    have hbb : b ≠ b' := fun hb => h (by rw [hb])
    have hzero : (fun i => xor (a i) (a i)) = fun _ => false := by
      funext i; cases a i <;> rfl
    have hall : ∀ x : Fin k → Bool, affineWord a b x ≠ affineWord a b' x := by
      intro x
      rw [affineWord_ne_iff, hzero, ip_zero]
      cases b <;> cases b' <;> first | exact absurd rfl hbb | decide
    have hdist : hammingDist (affineWord a b) (affineWord a b') = 2 ^ k := by
      rw [hammingDist, Finset.filter_true_of_mem (fun x _ => hall x)]
      simp
    rw [hdist]
    exact Nat.div_le_self _ _
  · -- different linear parts: exactly half the neurons differ
    have hu : ∃ j, (fun i => xor (a i) (a' i)) j = true := by
      obtain ⟨j, hj⟩ := Function.ne_iff.mp haa
      exact ⟨j, by cases hh : a j <;> cases hh' : a' j <;> simp_all⟩
    have hset : (Finset.univ.filter fun x => affineWord a b x ≠ affineWord a' b' x)
        = (Finset.univ.filter fun x => ip (fun i => xor (a i) (a' i)) x
            = bit b + bit b' + 1) :=
      Finset.filter_congr fun x _ => affineWord_ne_iff a a' x b b'
    rw [hammingDist, hset, card_ip_eq hu _]

/-- A relabelling of the `2 ^ k` neurons by the binary strings of length `k`. -/
noncomputable def strEquiv (k : ℕ) : (Fin k → Bool) ≃ Fin (2 ^ k) :=
  Fintype.equivFinOfCardEq (by simp)

/-- Hamming distance is invariant under a relabelling of the neurons. -/
lemma hammingDist_comp_equiv {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β]
    [DecidableEq β] (e : α ≃ β) (f g : β → Bool) :
    hammingDist (f ∘ e) (g ∘ e) = hammingDist f g := by
  classical
  rw [hammingDist, hammingDist]
  refine Finset.card_nbij' (fun a => e a) (fun b => e.symm b) ?_ ?_ ?_ ?_ <;>
    intro x hx <;> simp_all

/-- The **affine neural code**: the codebook of all affine forms, transported to
a population of `2 ^ k` neurons. -/
noncomputable def affineCode (k : ℕ) : Finset (NeuralCode (2 ^ k)) :=
  Finset.image (fun p : (Fin k → Bool) × Bool =>
    (affineWord p.1 p.2 ∘ (strEquiv k).symm : NeuralCode (2 ^ k))) Finset.univ

/-- The affine code is `2 ^ k / 2`-separated: its concepts survive
`2 ^ k / 2 - 1` misfirings. -/
theorem affineCode_separated (k : ℕ) : Separated (2 ^ k / 2) (affineCode k) := by
  classical
  intro y hy z hz hyz
  simp only [affineCode, Finset.mem_image, Finset.mem_univ, true_and] at hy hz
  obtain ⟨⟨a, b⟩, rfl⟩ := hy
  obtain ⟨⟨a', b'⟩, rfl⟩ := hz
  have hne : ((a, b) : (Fin k → Bool) × Bool) ≠ (a', b') := fun hcon => hyz (by rw [hcon])
  rw [hammingDist_comp_equiv (strEquiv k).symm (affineWord a b) (affineWord a' b')]
  exact affineWord_dist a a' b b' hne

/-- The affine code has `2 ^ (k+1)` codewords: `2 ^ k` linear forms, each with
two possible thresholds. -/
theorem card_affineCode (k : ℕ) (hk : 1 ≤ k) : (affineCode k).card = 2 ^ (k + 1) := by
  classical
  have hpos : 0 < 2 ^ k / 2 := by
    obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
    rw [show (2 : ℕ) ^ (m + 1) = 2 ^ m * 2 by ring, Nat.mul_div_cancel _ (by norm_num)]
    positivity
  have hinj : Function.Injective (fun p : (Fin k → Bool) × Bool =>
      (affineWord p.1 p.2 ∘ (strEquiv k).symm : NeuralCode (2 ^ k))) := by
    intro p q hpq
    by_contra hne
    have hd := affineWord_dist p.1 q.1 p.2 q.2 (fun hcon => hne
      (Prod.ext (congrArg Prod.fst hcon) (congrArg Prod.snd hcon)))
    rw [← hammingDist_comp_equiv (strEquiv k).symm (affineWord p.1 p.2) (affineWord q.1 q.2),
      show (affineWord p.1 p.2 ∘ (strEquiv k).symm) = (affineWord q.1 q.2 ∘ (strEquiv k).symm)
        from hpq, hammingDist_self] at hd
    omega
  rw [affineCode, Finset.card_image_of_injective _ hinj]
  simp [pow_succ]

/-! ## Tightness -/

/-- **The Plotkin bound is attained.**  On `N = 2 ^ (m+1)` neurons, the largest
codebook whose concepts differ on at least `2 ^ m` neurons has exactly
`2 ^ (m+2) = 2N` words: the affine (first-order Reed–Muller / Hadamard) neural
code is optimal.  Halving the population's noise tolerance therefore leaves only
linearly many concepts — the exponential capacity `2 ^ N` collapses to `2N`. -/
theorem hadamard_capacity (m : ℕ) :
    maxCodeSize (2 ^ (m + 1)) (2 ^ m) = 2 ^ (m + 2) := by
  have hN : (2 : ℕ) ^ (m + 1) = 2 * 2 ^ m := by ring
  refine le_antisymm ?_ ?_
  · have := plotkin_boundary (2 ^ m) (Nat.one_le_two_pow)
    rw [← hN] at this
    calc maxCodeSize (2 ^ (m + 1)) (2 ^ m) ≤ 4 * 2 ^ m := this
      _ = 2 ^ (m + 2) := by ring
  · have hhalf : 2 ^ (m + 1) / 2 = 2 ^ m := by
      rw [hN, Nat.mul_div_cancel_left _ (by norm_num)]
    have hsep := affineCode_separated (m + 1)
    rw [hhalf] at hsep
    have := card_le_maxCodeSize hsep
    rw [card_affineCode (m + 1) (by omega)] at this
    calc (2 : ℕ) ^ (m + 2) = 2 ^ (m + 1 + 1) := by ring_nf
      _ ≤ maxCodeSize (2 ^ (m + 1)) (2 ^ m) := this

/-- **Half-distance capacity of a power-of-two population.**  Restated in terms
of the population size `N = 2 ^ (m+1)`: a population whose concepts must differ
on at least half of its neurons represents exactly `2N` concepts. -/
theorem hadamard_capacity_half (m : ℕ) :
    maxCodeSize (2 ^ (m + 1)) (2 ^ (m + 1) / 2) = 2 * 2 ^ (m + 1) := by
  have hhalf : 2 ^ (m + 1) / 2 = 2 ^ m := by
    rw [show (2 : ℕ) ^ (m + 1) = 2 * 2 ^ m by ring, Nat.mul_div_cancel_left _ (by norm_num)]
  rw [hhalf, hadamard_capacity m]
  ring

/-- **Rate of an optimal half-distance population.**  With `N = 2 ^ (m+1)`
neurons and relative distance `1/2`, the capacity is `2N`, so the rate
`log₂ A / N` tends to `0`: half-distance robustness destroys all rate. -/
theorem hadamard_capacity_rate (m : ℕ) :
    Real.logb 2 (maxCodeSize (2 ^ (m + 1)) (2 ^ m)) / (2 ^ (m + 1) : ℝ)
      = (m + 2) / (2 ^ (m + 1) : ℝ) := by
  rw [hadamard_capacity m]
  congr 1
  rw [show ((2 ^ (m + 2) : ℕ) : ℝ) = (2 : ℝ) ^ (m + 2) by push_cast; ring,
    Real.logb_pow]
  simp

end NeuralCodePlotkinTightness