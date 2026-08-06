import Mathlib

/-!
# Neural Coding: the Exact Capacity Function of Noise-Tolerant Populations

A **neural code** on `N` neurons is a binary activity pattern
`NeuralCode N = Fin N → Bool`.  A population that must still tell two concepts
apart after `d - 1` of its neurons misfire may only use a set of patterns that
is **`d`-separated**: any two distinct patterns differ on at least `d` neurons.
The central quantity is therefore the *robust capacity*

`maxCodeSize N d = A(N, d) :=` the largest size of a `d`-separated codebook.

The raw capacity theorem `A(N,1) = 2 ^ N` says `N` binary neurons represent at
most (and exactly) `2 ^ N` concepts.  This file determines how that number
degrades as noise tolerance grows, by proving matching lower and upper bounds
for `A(N,d)` and computing it exactly at the ends of the range.

## Main results

* `card_ball` — a Hamming ball of radius `r` contains `ballVolume N r =
  ∑_{k ≤ r} C(N,k)` patterns, independently of its centre.
* `gilbert_varshamov` — **existence**: `2 ^ N ≤ A(N,d) * ballVolume N (d-1)`.
  Robust codebooks of guaranteed size exist; the proof is a greedy/maximality
  argument.
* `hamming_bound_maxCodeSize` — **sphere packing**: `A(N,2t+1) * ballVolume N t
  ≤ 2 ^ N`.
* `singleton_bound_maxCodeSize` — **projection**: `A(N,d) ≤ 2 ^ (N + 1 - d)`.
* `plotkin_double_count` and `plotkin_bound` — **Plotkin**: for a `d`-separated
  codebook with `N < 2d`, `|C| * (2d - N) ≤ 2d`.  Beyond half the population,
  robustness collapses capacity to a constant.
* `capacity_sandwich` — the two-sided bound
  `2 ^ N ≤ A(N,2t+1) * ballVolume N (2t)` and `A(N,2t+1) * ballVolume N t ≤ 2^N`.
* `maxCodeSize_parity_extension` — **parity-extension identity**:
  `A(N+1, 2t+2) = A(N, 2t+1)`.  A neuron devoted to parity buys one further unit
  of error *detection* but not one extra concept.
* Exact values: `maxCodeSize_one` (`A(N,1) = 2^N`), `maxCodeSize_two`
  (`A(N+1,2) = 2^N`), `maxCodeSize_self` (`A(N,N) = 2` for `N ≥ 1`),
  `maxCodeSize_succ_self` (`A(N,N+1) = 1`), and `maxCodeSize_antitone`.

* `ballVolume_mul_le_one` and `log_ballVolume_le` — the entropy estimate
  `log (ballVolume N r) ≤ N * H(r/N)` for `r/N ≤ 1/2`.
* `gilbert_varshamov_rate` and `gilbert_varshamov_rate_bits` — the asymptotic
  **rate theorem**: the best `d`-separated neural code has rate at least
  `1 - H₂(δ)` bits per neuron, `δ = (d-1)/N`.

All statements are about the exact combinatorial quantity `A(N,d)`; the small
values they predict (`A(5,3) = 4`, `A(6,4) = 4`, `A(N,2) = 2^(N-1)`, …) agree
with the exhaustive search recorded in `ComputationalEvidence.md`.
-/

namespace NeuralCodeCapacity

open Finset

/-- A **neural code** on `N` neurons: a binary activity pattern, `true` meaning
the neuron is spiking. -/
abbrev NeuralCode (N : ℕ) : Type := Fin N → Bool

/-- The **weight** (metabolic cost) of a pattern: the number of active neurons. -/
def wt {N : ℕ} (c : NeuralCode N) : ℕ := ∑ i, (if c i = true then 1 else 0)

/-- The Hamming distance as a sum of disagreement indicators. -/
lemma hammingDist_eq_sum {N : ℕ} (x y : NeuralCode N) :
    hammingDist x y = ∑ i, (if x i = y i then 0 else 1) := by
  rw [hammingDist, Finset.card_filter]
  exact Finset.sum_congr rfl (fun i _ => by by_cases h : x i = y i <;> simp [h])

/-- The weight counts the active neurons. -/
lemma wt_eq_card {N : ℕ} (c : NeuralCode N) :
    wt c = (Finset.univ.filter (fun i => c i = true)).card := by
  rw [wt, Finset.card_filter]

/-- **Parity of the Hamming distance.**  Two patterns are at even distance
exactly when their weights have the same parity. -/
lemma parity_wt_dist {N : ℕ} (x y : NeuralCode N) :
    (wt x + wt y) % 2 = hammingDist x y % 2 := by
  rw [hammingDist_eq_sum, wt, wt, ← Finset.sum_add_distrib]
  rw [Finset.sum_nat_mod, Finset.sum_nat_mod (f := fun i => if x i = y i then 0 else 1)]
  congr 1
  exact Finset.sum_congr rfl (fun i _ => by cases x i <;> cases y i <;> simp)

/-! ## Hamming balls and their volume -/

/-- The **Hamming ball** of radius `r` around a pattern: all patterns reachable
by flipping at most `r` neurons. -/
def ball {N : ℕ} (c : NeuralCode N) (r : ℕ) : Finset (NeuralCode N) :=
  Finset.univ.filter (fun x => hammingDist c x ≤ r)

/-- The **volume** of a Hamming ball of radius `r` on `N` neurons. -/
def ballVolume (N r : ℕ) : ℕ := ∑ k ∈ Finset.range (r + 1), N.choose k

/-- The distance from `c` is the weight of the neuron-wise XOR with `c`. -/
lemma dist_eq_wt_xor {N : ℕ} (c x : NeuralCode N) :
    hammingDist c x = wt (fun i => xor (c i) (x i)) := by
  rw [hammingDist_eq_sum, wt]
  exact Finset.sum_congr rfl (fun i _ => by cases c i <;> cases x i <;> simp)

private lemma xor_cancel {N : ℕ} (c z : NeuralCode N) :
    (fun i => xor (c i) (xor (c i) (z i))) = z := by
  funext i; cases c i <;> cases z i <;> simp

/-- **Balls are homogeneous**: XOR-translation identifies the ball around `c`
with the set of patterns of weight at most `r`. -/
lemma card_ball_eq_card_wt_le {N : ℕ} (c : NeuralCode N) (r : ℕ) :
    (ball c r).card = (Finset.univ.filter (fun z : NeuralCode N => wt z ≤ r)).card := by
  apply Finset.card_bij (fun x _ => (fun i => xor (c i) (x i)))
  · intro x hx
    simp only [ball, mem_filter, mem_univ, true_and] at hx ⊢
    rwa [← dist_eq_wt_xor]
  · intro a _ b _ hab
    funext i
    have := congrFun hab i
    cases c i <;> cases ha' : a i <;> cases hb' : b i <;> simp_all
  · intro z hz
    simp only [mem_filter, mem_univ, true_and] at hz
    refine ⟨(fun i => xor (c i) (z i)), ?_, xor_cancel c z⟩
    simp only [ball, mem_filter, mem_univ, true_and]
    rw [dist_eq_wt_xor, xor_cancel]
    exact hz

/-- **Sparse counts.**  Exactly `C(N,k)` patterns have weight `k`. -/
lemma card_wt_eq (N k : ℕ) :
    (Finset.univ.filter (fun c : NeuralCode N => wt c = k)).card = N.choose k := by
  have hpc : ((Finset.univ : Finset (Fin N)).powersetCard k).card = N.choose k := by
    rw [Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]
  rw [← hpc]
  apply Finset.card_bij (fun c _ => Finset.univ.filter (fun i => c i = true))
  · intro c hc
    simp only [mem_filter, mem_univ, true_and] at hc
    simp only [mem_powersetCard]
    exact ⟨Finset.filter_subset _ _, by rw [← wt_eq_card]; exact hc⟩
  · intro a _ b _ hab
    funext i
    have hiff : (i ∈ Finset.univ.filter (fun i => a i = true))
        ↔ (i ∈ Finset.univ.filter (fun i => b i = true)) := by rw [hab]
    simp only [mem_filter, mem_univ, true_and] at hiff
    cases hai : a i <;> cases hbi : b i <;> simp_all
  · intro s hs
    simp only [mem_powersetCard] at hs
    refine ⟨fun i => decide (i ∈ s), ?_, by ext i; simp⟩
    simp only [mem_filter, mem_univ, true_and]
    rw [wt_eq_card]
    convert hs.2 using 2
    ext i; simp

private lemma card_wt_le (N r : ℕ) :
    (Finset.univ.filter (fun z : NeuralCode N => wt z ≤ r)).card
      = ∑ k ∈ Finset.range (r + 1),
          (Finset.univ.filter (fun z : NeuralCode N => wt z = k)).card := by
  rw [← Finset.card_biUnion]
  · congr 1
    ext z; simp only [mem_filter, mem_univ, true_and, mem_biUnion, mem_range]
    exact ⟨fun h => ⟨wt z, by omega, rfl⟩, fun ⟨k, hk, hz⟩ => by omega⟩
  · intro i _ j _ hij
    simp only [Finset.disjoint_left, mem_filter]
    rintro z ⟨_, hz⟩ ⟨_, hz'⟩; exact hij (hz ▸ hz')

/-- **Volume of a Hamming ball.**  A ball of radius `r` on `N` neurons contains
exactly `∑_{k ≤ r} C(N,k)` patterns, whatever its centre. -/
theorem card_ball {N : ℕ} (c : NeuralCode N) (r : ℕ) :
    (ball c r).card = ballVolume N r := by
  rw [card_ball_eq_card_wt_le, card_wt_le, ballVolume]
  exact Finset.sum_congr rfl (fun k _ => card_wt_eq N k)

/-- The total number of patterns is `2 ^ N`: the raw capacity of `N` neurons. -/
theorem card_neuralCode (N : ℕ) :
    (Finset.univ : Finset (NeuralCode N)).card = 2 ^ N := by
  simp

/-! ## Separated codebooks and the capacity function `A(N,d)` -/

/-- A codebook `C` is **`d`-separated** when distinct codewords disagree on at
least `d` neurons: the population still distinguishes the concepts after `d - 1`
neurons misfire. -/
def Separated {N : ℕ} (d : ℕ) (C : Finset (NeuralCode N)) : Prop :=
  ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hammingDist x y

lemma separated_empty {N d : ℕ} : Separated d (∅ : Finset (NeuralCode N)) := by
  intro x hx; simp at hx

lemma separated_mono {N : ℕ} {d d' : ℕ} (h : d ≤ d') {C : Finset (NeuralCode N)}
    (hC : Separated d' C) : Separated d C :=
  fun x hx y hy hxy => le_trans h (hC x hx y hy hxy)

lemma separated_subset {N d : ℕ} {C D : Finset (NeuralCode N)} (hCD : C ⊆ D)
    (hD : Separated d D) : Separated d C :=
  fun x hx y hy hxy => hD x (hCD hx) y (hCD hy) hxy

open Classical in
/-- **Robust capacity** `A(N,d)`: the largest number of concepts a population of
`N` neurons can encode while keeping distinct patterns `d` neurons apart. -/
noncomputable def maxCodeSize (N d : ℕ) : ℕ :=
  ((Finset.univ : Finset (Finset (NeuralCode N))).filter
    (fun C : Finset (NeuralCode N) => Separated d C)).sup Finset.card

/-- Every `d`-separated codebook is at most as large as `A(N,d)`. -/
theorem card_le_maxCodeSize {N d : ℕ} {C : Finset (NeuralCode N)} (h : Separated d C) :
    C.card ≤ maxCodeSize N d := by
  classical
  exact Finset.le_sup (f := Finset.card) (Finset.mem_filter.mpr ⟨Finset.mem_univ _, h⟩)

/-- The capacity `A(N,d)` is attained by an optimal codebook. -/
theorem exists_maxCodeSize (N d : ℕ) :
    ∃ C : Finset (NeuralCode N), Separated d C ∧ C.card = maxCodeSize N d := by
  classical
  have hne : (((Finset.univ : Finset (Finset (NeuralCode N))).filter
      (fun C : Finset (NeuralCode N) => Separated d C))).Nonempty :=
    ⟨∅, Finset.mem_filter.mpr ⟨Finset.mem_univ _, separated_empty⟩⟩
  obtain ⟨C, hC, hsup⟩ := Finset.exists_mem_eq_sup _ hne Finset.card
  exact ⟨C, (Finset.mem_filter.mp hC).2, hsup.symm⟩

/-- **More noise tolerance never increases capacity.** -/
theorem maxCodeSize_antitone {N : ℕ} {d d' : ℕ} (h : d ≤ d') :
    maxCodeSize N d' ≤ maxCodeSize N d := by
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize N d'
  exact hcard ▸ card_le_maxCodeSize (separated_mono h hC)

/-- Capacity never exceeds the raw capacity `2 ^ N`. -/
theorem maxCodeSize_le_pow (N d : ℕ) : maxCodeSize N d ≤ 2 ^ N := by
  obtain ⟨C, _, hcard⟩ := exists_maxCodeSize N d
  rw [← hcard, ← card_neuralCode N]
  exact Finset.card_le_card (Finset.subset_univ C)

/-- At least one concept can always be encoded. -/
theorem one_le_maxCodeSize (N d : ℕ) : 1 ≤ maxCodeSize N d := by
  have h : Separated d ({fun _ => false} : Finset (NeuralCode N)) := by
    intro x hx y hy hxy
    simp only [Finset.mem_singleton] at hx hy
    exact absurd (hx.trans hy.symm) hxy
  simpa using card_le_maxCodeSize h

/-! ## The Gilbert–Varshamov existence bound -/

/-- **Gilbert–Varshamov bound.**  A maximal `d`-separated codebook has its
radius-`(d-1)` balls covering every pattern, hence

`2 ^ N ≤ A(N,d) * ballVolume N (d-1)`.

Robust codebooks of guaranteed size exist: capacity cannot fall below
`2 ^ N / ∑_{k ≤ d-1} C(N,k)`. -/
theorem gilbert_varshamov (N : ℕ) {d : ℕ} (hd : 1 ≤ d) :
    2 ^ N ≤ maxCodeSize N d * ballVolume N (d - 1) := by
  classical
  obtain ⟨C, hCsep, hCcard⟩ := exists_maxCodeSize N d
  -- maximality: every pattern lies within distance `d - 1` of a codeword
  have hcover : ∀ x : NeuralCode N, ∃ c ∈ C, hammingDist c x ≤ d - 1 := by
    intro x
    by_contra hx
    push_neg at hx
    have hxC : x ∉ C := by
      intro hmem
      have := hx x hmem
      simp [hammingDist_self] at this
    have hsep : Separated d (insert x C) := by
      intro a ha b hb hab
      simp only [Finset.mem_insert] at ha hb
      rcases ha with ha | ha <;> rcases hb with hb | hb
      · exact absurd (ha.trans hb.symm) hab
      · subst ha
        have := hx b hb
        rw [hammingDist_comm]
        omega
      · subst hb
        have := hx a ha
        omega
      · exact hCsep a ha b hb hab
    have hcard : (insert x C).card = C.card + 1 := Finset.card_insert_of_notMem hxC
    have := card_le_maxCodeSize hsep
    omega
  have hsub : (Finset.univ : Finset (NeuralCode N)) ⊆ C.biUnion (fun c => ball c (d - 1)) := by
    intro x _
    obtain ⟨c, hc, hcx⟩ := hcover x
    exact Finset.mem_biUnion.mpr ⟨c, hc, by simp [ball, hcx]⟩
  calc 2 ^ N = (Finset.univ : Finset (NeuralCode N)).card := (card_neuralCode N).symm
    _ ≤ (C.biUnion (fun c => ball c (d - 1))).card := Finset.card_le_card hsub
    _ ≤ ∑ c ∈ C, (ball c (d - 1)).card := Finset.card_biUnion_le
    _ = C.card * ballVolume N (d - 1) := by
        rw [Finset.sum_congr rfl (fun c _ => card_ball c (d - 1))]
        simp [mul_comm]
    _ = maxCodeSize N d * ballVolume N (d - 1) := by rw [hCcard]

/-! ## The sphere-packing (Hamming) upper bound -/

private lemma balls_disjoint {N t : ℕ} {C : Finset (NeuralCode N)}
    (hC : Separated (2 * t + 1) C) :
    (C : Set (NeuralCode N)).PairwiseDisjoint (fun c => ball c t) := by
  intro x hx y hy hxy
  simp only [Function.onFun, Finset.disjoint_left]
  intro z hz hz'
  simp only [ball, mem_filter, mem_univ, true_and] at hz hz'
  have htri : hammingDist x y ≤ hammingDist x z + hammingDist y z := by
    simpa [hammingDist_comm] using hammingDist_triangle x z y
  have := hC x hx y hy hxy
  omega

/-- **Sphere-packing (Hamming) bound.**  A `t`-error-correcting codebook (any two
codewords at distance `≥ 2t+1`) owns disjoint balls of radius `t`, so

`|C| * ballVolume N t ≤ 2 ^ N`. -/
theorem hamming_bound {N t : ℕ} {C : Finset (NeuralCode N)}
    (hC : Separated (2 * t + 1) C) : C.card * ballVolume N t ≤ 2 ^ N := by
  classical
  have hdisj := balls_disjoint hC
  have hcard : (C.biUnion (fun c => ball c t)).card = ∑ c ∈ C, (ball c t).card :=
    Finset.card_biUnion (fun x hx y hy hxy => hdisj hx hy hxy)
  have hle : (C.biUnion (fun c => ball c t)).card ≤ 2 ^ N := by
    rw [← card_neuralCode N]
    exact Finset.card_le_card (Finset.subset_univ _)
  rw [hcard, Finset.sum_congr rfl (fun c _ => card_ball c t)] at hle
  simpa [mul_comm] using hle

/-- The sphere-packing bound at the level of the capacity function. -/
theorem hamming_bound_maxCodeSize (N t : ℕ) :
    maxCodeSize N (2 * t + 1) * ballVolume N t ≤ 2 ^ N := by
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize N (2 * t + 1)
  rw [← hcard]
  exact hamming_bound hC

/-! ## The Singleton (projection) upper bound -/

/-- If two patterns agree outside a set `S` of neurons they are at distance at
most `|S|`. -/
lemma hamming_le_of_agree {N : ℕ} (S : Finset (Fin N)) (x y : NeuralCode N)
    (h : ∀ i ∈ Sᶜ, x i = y i) : hammingDist x y ≤ S.card := by
  rw [hammingDist]
  apply Finset.card_le_card
  intro i hi
  simp only [mem_filter, mem_univ, true_and] at hi
  by_contra hiS
  exact hi (h i (by simp [mem_compl, hiS]))

/-- **Singleton bound.**  Puncturing `d - 1` neurons is injective on a
`d`-separated codebook, so it has at most `2 ^ (N + 1 - d)` codewords. -/
theorem singleton_bound {N d : ℕ} (hd : 1 ≤ d) (hdN : d ≤ N + 1)
    {C : Finset (NeuralCode N)} (hC : Separated d C) : C.card ≤ 2 ^ (N + 1 - d) := by
  classical
  obtain ⟨S, -, hScard⟩ := Finset.exists_subset_card_eq
    (show d - 1 ≤ (univ : Finset (Fin N)).card by rw [card_univ, Fintype.card_fin]; omega)
  set f : NeuralCode N → ({i // i ∈ Sᶜ} → Bool) := fun c j => c j.1 with hf
  have hinj : Set.InjOn f C := by
    intro x hx y hy hxy
    by_contra hne
    have hagree : ∀ i ∈ Sᶜ, x i = y i := by
      intro i hi
      simpa [hf] using congrFun hxy ⟨i, hi⟩
    have h1 : d ≤ hammingDist x y := hC x hx y hy hne
    have h2 : hammingDist x y ≤ S.card := hamming_le_of_agree S x y hagree
    omega
  have hcard : C.card ≤ (univ : Finset ({i // i ∈ Sᶜ} → Bool)).card :=
    Finset.card_le_card_of_injOn f (fun a _ => mem_univ _) hinj
  rw [card_univ] at hcard
  have hcard2 : Fintype.card ({i // i ∈ Sᶜ} → Bool) = 2 ^ (N + 1 - d) := by
    rw [Fintype.card_fun, Fintype.card_coe, Fintype.card_bool]
    congr 1
    rw [Finset.card_compl, Fintype.card_fin, hScard]
    omega
  rw [hcard2] at hcard
  exact hcard

/-- The Singleton bound at the level of the capacity function. -/
theorem singleton_bound_maxCodeSize {N d : ℕ} (hd : 1 ≤ d) (hdN : d ≤ N + 1) :
    maxCodeSize N d ≤ 2 ^ (N + 1 - d) := by
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize N d
  exact hcard ▸ singleton_bound hd hdN hC

/-! ## The Plotkin bound: robustness beyond half the population -/

private lemma sum_pairs_coord {N : ℕ} (C : Finset (NeuralCode N)) (i : Fin N) :
    ∑ x ∈ C, ∑ y ∈ C, (if x i = y i then 0 else 1)
      = 2 * ((C.filter (fun x => x i = true)).card
              * (C.filter (fun x => x i = false)).card) := by
  classical
  have hinner : ∀ x ∈ C, ∑ y ∈ C, (if x i = y i then 0 else 1)
      = if x i = true then (C.filter (fun y => y i = false)).card
        else (C.filter (fun y => y i = true)).card := by
    intro x _
    by_cases hx : x i = true
    · rw [if_pos hx, Finset.card_filter]
      exact Finset.sum_congr rfl (fun y _ => by cases hy : y i <;> simp [hx])
    · rw [if_neg hx, Finset.card_filter]
      have hx' : x i = false := by cases hxv : x i <;> simp_all
      exact Finset.sum_congr rfl (fun y _ => by cases hy : y i <;> simp [hx'])
  rw [Finset.sum_congr rfl hinner]
  rw [← Finset.sum_filter_add_sum_filter_not C (fun x => x i = true)]
  have h1 : ∑ x ∈ C.filter (fun x => x i = true),
      (if x i = true then (C.filter (fun y => y i = false)).card
        else (C.filter (fun y => y i = true)).card)
      = (C.filter (fun x => x i = true)).card * (C.filter (fun y => y i = false)).card := by
    rw [Finset.sum_congr rfl (fun x hx => by
      simp only [Finset.mem_filter] at hx
      rw [if_pos hx.2])]
    simp
  have hnot : C.filter (fun x => ¬ (x i = true)) = C.filter (fun x => x i = false) := by
    apply Finset.filter_congr
    intro x _; cases hx : x i <;> simp
  have h2 : ∑ x ∈ C.filter (fun x => ¬ (x i = true)),
      (if x i = true then (C.filter (fun y => y i = false)).card
        else (C.filter (fun y => y i = true)).card)
      = (C.filter (fun x => x i = false)).card * (C.filter (fun y => y i = true)).card := by
    rw [hnot, Finset.sum_congr rfl (fun x hx => by
      simp only [Finset.mem_filter] at hx
      rw [if_neg (by simp [hx.2])])]
    simp
  rw [h1, h2]
  ring

private lemma sum_pairs_dist_le {N : ℕ} (C : Finset (NeuralCode N)) :
    2 * (∑ x ∈ C, ∑ y ∈ C, hammingDist x y) ≤ N * (C.card * C.card) := by
  classical
  have hswap : ∑ x ∈ C, ∑ y ∈ C, hammingDist x y
      = ∑ i : Fin N, ∑ x ∈ C, ∑ y ∈ C, (if x i = y i then 0 else 1) :=
    calc ∑ x ∈ C, ∑ y ∈ C, hammingDist x y
        = ∑ x ∈ C, ∑ y ∈ C, ∑ i : Fin N, (if x i = y i then 0 else 1) := by
          simp only [hammingDist_eq_sum]
      _ = ∑ x ∈ C, ∑ i : Fin N, ∑ y ∈ C, (if x i = y i then 0 else 1) :=
          Finset.sum_congr rfl (fun _ _ => Finset.sum_comm)
      _ = ∑ i : Fin N, ∑ x ∈ C, ∑ y ∈ C, (if x i = y i then 0 else 1) := Finset.sum_comm
  rw [hswap, Finset.mul_sum]
  calc ∑ i : Fin N, 2 * ∑ x ∈ C, ∑ y ∈ C, (if x i = y i then 0 else 1)
      ≤ ∑ _i : Fin N, C.card * C.card := by
        apply Finset.sum_le_sum
        intro i _
        rw [sum_pairs_coord C i]
        set a := (C.filter (fun x => x i = true)).card with ha
        set b := (C.filter (fun x => x i = false)).card with hb
        have hab : a + b = C.card := by
          rw [ha, hb]
          have hnot : C.filter (fun x => x i = false) = C.filter (fun x => ¬ (x i = true)) := by
            apply Finset.filter_congr; intro x _; cases hx : x i <;> simp
          rw [hnot, Finset.card_filter_add_card_filter_not]
        have key : 4 * (a * b) ≤ (a + b) * (a + b) := by
          zify
          nlinarith [sq_nonneg ((a : ℤ) - b)]
        calc 2 * (2 * (a * b)) = 4 * (a * b) := by ring
          _ ≤ (a + b) * (a + b) := key
          _ = C.card * C.card := by rw [hab]
    _ = N * (C.card * C.card) := by simp [Finset.sum_const]

private lemma sum_pairs_dist_ge {N d : ℕ} {C : Finset (NeuralCode N)} (hC : Separated d C) :
    C.card * (C.card - 1) * d ≤ ∑ x ∈ C, ∑ y ∈ C, hammingDist x y := by
  classical
  have hinner : ∀ x ∈ C, (C.card - 1) * d ≤ ∑ y ∈ C, hammingDist x y := by
    intro x hx
    have herase : ∑ y ∈ C.erase x, hammingDist x y ≤ ∑ y ∈ C, hammingDist x y :=
      Finset.sum_le_sum_of_subset (Finset.erase_subset _ _)
    have hlow : (C.card - 1) * d ≤ ∑ y ∈ C.erase x, hammingDist x y := by
      have : ∀ y ∈ C.erase x, d ≤ hammingDist x y := by
        intro y hy
        exact hC x hx y (Finset.mem_of_mem_erase hy)
          (fun h => (Finset.ne_of_mem_erase hy) h.symm)
      calc (C.card - 1) * d = (C.erase x).card * d := by
            rw [Finset.card_erase_of_mem hx]
        _ = ∑ _y ∈ C.erase x, d := by simp [mul_comm]
        _ ≤ ∑ y ∈ C.erase x, hammingDist x y := Finset.sum_le_sum this
    omega
  calc C.card * (C.card - 1) * d = ∑ _x ∈ C, (C.card - 1) * d := by
        rw [Finset.sum_const, smul_eq_mul]; ring
    _ ≤ ∑ x ∈ C, ∑ y ∈ C, hammingDist x y := Finset.sum_le_sum hinner

/-- **Plotkin's double count.**  For a `d`-separated codebook `C` on `N` neurons,
`2 |C| (|C| - 1) d ≤ N |C|²`: summing the pairwise distances coordinate by
coordinate bounds them by `N |C|² / 2`, while separation bounds them below. -/
theorem plotkin_double_count {N d : ℕ} {C : Finset (NeuralCode N)} (hC : Separated d C) :
    2 * (C.card * (C.card - 1) * d) ≤ N * (C.card * C.card) :=
  le_trans (Nat.mul_le_mul_left 2 (sum_pairs_dist_ge hC)) (sum_pairs_dist_le C)

/-- **Plotkin bound.**  If the required separation exceeds half the population
(`N < 2d`), a `d`-separated codebook has at most `2d / (2d - N)` codewords:
robustness beyond half the population collapses capacity to a constant. -/
theorem plotkin_bound {N d : ℕ} (hNd : N < 2 * d) {C : Finset (NeuralCode N)}
    (hC : Separated d C) : C.card * (2 * d - N) ≤ 2 * d := by
  rcases Nat.eq_zero_or_pos C.card with h0 | hpos
  · simp [h0]
  have hdc := plotkin_double_count hC
  obtain ⟨m, hm⟩ : ∃ m, C.card = m + 1 := ⟨C.card - 1, by omega⟩
  rw [hm] at hdc ⊢
  simp only [Nat.add_sub_cancel] at hdc
  -- `2 * ((m+1) * m * d) ≤ N * ((m+1) * (m+1))` ⇒ `m * (2d - N) ≤ N + (2d - N)`
  have hkey : 2 * (m * d) ≤ N * (m + 1) := by nlinarith
  have he : 2 * d - N + N = 2 * d := by omega
  nlinarith [hkey, he]

/-- The Plotkin bound at the level of the capacity function. -/
theorem plotkin_bound_maxCodeSize {N d : ℕ} (hNd : N < 2 * d) :
    maxCodeSize N d * (2 * d - N) ≤ 2 * d := by
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize N d
  exact hcard ▸ plotkin_bound hNd hC

/-! ## Exact values of the capacity function -/

/-- **Raw capacity.**  With no noise tolerance the capacity is `2 ^ N`: `N`
binary neurons represent exactly `2 ^ N` concepts. -/
theorem maxCodeSize_one (N : ℕ) : maxCodeSize N 1 = 2 ^ N := by
  refine le_antisymm (maxCodeSize_le_pow N 1) ?_
  have huniv : Separated 1 (Finset.univ : Finset (NeuralCode N)) := by
    intro x _ y _ hxy
    have : hammingDist x y ≠ 0 := by simp [hammingDist_eq_zero, hxy]
    omega
  simpa [card_neuralCode] using card_le_maxCodeSize huniv

/-- The two-word **repetition code**: all neurons silent, or all firing. -/
def repetitionCode (N : ℕ) : Finset (NeuralCode N) :=
  {(fun _ => false), (fun _ => true)}

lemma card_repetitionCode {N : ℕ} (hN : 1 ≤ N) : (repetitionCode N).card = 2 := by
  rw [repetitionCode, Finset.card_insert_of_notMem, Finset.card_singleton]
  intro h
  simp only [Finset.mem_singleton] at h
  have := congrFun h ⟨0, by omega⟩
  simp at this

lemma separated_repetitionCode (N : ℕ) : Separated N (repetitionCode N) := by
  intro x hx y hy hxy
  simp only [repetitionCode, Finset.mem_insert, Finset.mem_singleton] at hx hy
  have key : hammingDist (fun _ => false : NeuralCode N) (fun _ => true) = N := by
    rw [hammingDist]; simp
  rcases hx with hx | hx <;> rcases hy with hy | hy <;> subst hx <;> subst hy
  · exact absurd rfl hxy
  · rw [key]
  · rw [hammingDist_comm, key]
  · exact absurd rfl hxy

/-- **Maximal robustness leaves only the repetition code.**  For `N ≥ 1`,
`A(N,N) = 2`: demanding that concepts differ on *every* neuron allows exactly
two concepts.  The upper bound is Plotkin's, the lower bound the repetition
code. -/
theorem maxCodeSize_self {N : ℕ} (hN : 1 ≤ N) : maxCodeSize N N = 2 := by
  refine le_antisymm ?_ ?_
  · have h := plotkin_bound_maxCodeSize (N := N) (d := N) (by omega)
    have he : 2 * N - N = N := by omega
    rw [he] at h
    exact Nat.le_of_mul_le_mul_right h (by omega : 0 < N)
  · have h := card_le_maxCodeSize (separated_repetitionCode N)
    rwa [card_repetitionCode hN] at h

/-- **Beyond maximal robustness capacity collapses to one concept.**
`A(N, N+1) = 1`: no two distinct patterns can differ on more than `N` neurons. -/
theorem maxCodeSize_succ_self (N : ℕ) : maxCodeSize N (N + 1) = 1 := by
  refine le_antisymm ?_ (one_le_maxCodeSize N (N + 1))
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize N (N + 1)
  rw [← hcard]
  by_contra hlt
  push_neg at hlt
  obtain ⟨x, hx, y, hy, hxy⟩ := Finset.one_lt_card.mp hlt
  have h1 := hC x hx y hy hxy
  have h2 : hammingDist x y ≤ N := by
    rw [hammingDist]
    simpa using Finset.card_filter_le (Finset.univ : Finset (Fin N)) _
  omega

/-! ## The two-sided capacity estimate -/

/-- **Capacity sandwich.**  The capacity of a `t`-error-correcting neural code is
squeezed between the Gilbert–Varshamov and sphere-packing estimates:

`2 ^ N / ballVolume N (2t) ≤ A(N, 2t+1) ≤ 2 ^ N / ballVolume N t`,

stated multiplicatively to stay in `ℕ`. -/
theorem capacity_sandwich (N t : ℕ) :
    2 ^ N ≤ maxCodeSize N (2 * t + 1) * ballVolume N (2 * t) ∧
      maxCodeSize N (2 * t + 1) * ballVolume N t ≤ 2 ^ N := by
  refine ⟨?_, hamming_bound_maxCodeSize N t⟩
  have h := gilbert_varshamov N (d := 2 * t + 1) (by omega)
  simpa using h

/-- **The price of single-error correction.**  A neural population that can
correct any single misfiring neuron encodes at least `2 ^ N / (1 + N + N(N-1)/2)`
and at most `2 ^ N / (N + 1)` concepts. -/
theorem single_error_capacity (N : ℕ) :
    2 ^ N ≤ maxCodeSize N 3 * ballVolume N 2 ∧
      maxCodeSize N 3 * (N + 1) ≤ 2 ^ N := by
  obtain ⟨h1, h2⟩ := capacity_sandwich N 1
  refine ⟨by simpa using h1, ?_⟩
  have hb : ballVolume N 1 = N + 1 := by
    simp [ballVolume, Finset.sum_range_succ]
    omega
  rw [hb] at h2
  simpa using h2

/-! ## The parity-extension identity `A(N+1, 2t+2) = A(N, 2t+1)`

Adding a single **parity neuron** — one that fires exactly when an odd number of
the other neurons fire — converts a code correcting `t` errors into one of even
minimum distance `2t+2` on one more neuron, and every even-distance code arises
this way.  So an extra neuron buys *detection* of one further error but no extra
concepts. -/

/-- **Puncturing**: forget the last neuron. -/
def punct {N : ℕ} (x : NeuralCode (N + 1)) : NeuralCode N := fun i => x i.castSucc

/-- **Parity extension**: append a neuron firing iff the pattern has odd weight. -/
def extend {N : ℕ} (x : NeuralCode N) : NeuralCode (N + 1) :=
  Fin.snoc x (decide (wt x % 2 = 1))

lemma wt_snoc {N : ℕ} (x : NeuralCode N) (a : Bool) :
    wt (Fin.snoc x a : NeuralCode (N + 1)) = wt x + (if a = true then 1 else 0) := by
  rw [wt, wt, Fin.sum_univ_castSucc]; simp

lemma dist_snoc {N : ℕ} (x y : NeuralCode N) (a b : Bool) :
    hammingDist (Fin.snoc x a : NeuralCode (N + 1)) (Fin.snoc y b)
      = hammingDist x y + (if a = b then 0 else 1) := by
  rw [hammingDist_eq_sum, hammingDist_eq_sum, Fin.sum_univ_castSucc]; simp

/-- Puncturing changes the distance by at most the last neuron. -/
lemma dist_punct {N : ℕ} (x y : NeuralCode (N + 1)) :
    hammingDist x y = hammingDist (punct x) (punct y)
      + (if x (Fin.last N) = y (Fin.last N) then 0 else 1) := by
  rw [hammingDist_eq_sum, hammingDist_eq_sum, Fin.sum_univ_castSucc]; rfl

/-- The parity extension always has even weight. -/
lemma wt_extend_even {N : ℕ} (x : NeuralCode N) : wt (extend x) % 2 = 0 := by
  rw [extend, wt_snoc]
  by_cases h : wt x % 2 = 1 <;> simp [h] <;> omega

lemma punct_extend {N : ℕ} (x : NeuralCode N) : punct (extend x) = x := by
  funext i; simp [punct, extend]

lemma extend_injective {N : ℕ} : Function.Injective (extend (N := N)) :=
  Function.LeftInverse.injective punct_extend

lemma dist_extend_ge {N : ℕ} (x y : NeuralCode N) :
    hammingDist x y ≤ hammingDist (extend x) (extend y) := by
  rw [extend, extend, dist_snoc]; omega

/-- Parity-extended patterns are always at **even** distance. -/
lemma dist_extend_even {N : ℕ} (x y : NeuralCode N) :
    hammingDist (extend x) (extend y) % 2 = 0 := by
  have h := parity_wt_dist (extend x) (extend y)
  have hx := wt_extend_even x
  have hy := wt_extend_even y
  omega

/-- **The parity neuron upgrades `2t+1` to `2t+2`.** -/
theorem separated_image_extend {N t : ℕ} {C : Finset (NeuralCode N)}
    (hC : Separated (2 * t + 1) C) :
    Separated (2 * t + 2) (C.image extend) := by
  intro u hu v hv huv
  simp only [Finset.mem_image] at hu hv
  obtain ⟨x, hx, rfl⟩ := hu
  obtain ⟨y, hy, rfl⟩ := hv
  have hxy : x ≠ y := fun h => huv (by rw [h])
  have h1 : 2 * t + 1 ≤ hammingDist (extend x) (extend y) :=
    le_trans (hC x hx y hy hxy) (dist_extend_ge x y)
  have h2 := dist_extend_even x y
  omega

/-- Extending a codebook by a parity neuron keeps all its concepts distinct. -/
theorem card_image_extend {N : ℕ} (C : Finset (NeuralCode N)) :
    (C.image extend).card = C.card :=
  Finset.card_image_of_injective C extend_injective

/-- One extra (parity) neuron converts `t`-error correction into minimum distance
`2t+2` without losing concepts. -/
theorem maxCodeSize_le_extend (N t : ℕ) :
    maxCodeSize N (2 * t + 1) ≤ maxCodeSize (N + 1) (2 * t + 2) := by
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize N (2 * t + 1)
  have := card_le_maxCodeSize (separated_image_extend hC)
  rwa [card_image_extend, hcard] at this

/-- Conversely, puncturing an even-distance codebook loses no concepts. -/
theorem maxCodeSize_punct_le (N t : ℕ) :
    maxCodeSize (N + 1) (2 * t + 2) ≤ maxCodeSize N (2 * t + 1) := by
  classical
  obtain ⟨C, hC, hcard⟩ := exists_maxCodeSize (N + 1) (2 * t + 2)
  have hinj : Set.InjOn (punct (N := N)) (C : Set (NeuralCode (N + 1))) := by
    intro x hx y hy hxy
    by_contra hne
    have h1 := hC x (Finset.mem_coe.mp hx) y (Finset.mem_coe.mp hy) hne
    have h2 := dist_punct x y
    rw [hxy, hammingDist_self] at h2
    split_ifs at h2 <;> omega
  have hsep : Separated (2 * t + 1) (C.image punct) := by
    intro u hu v hv huv
    simp only [Finset.mem_image] at hu hv
    obtain ⟨x, hx, rfl⟩ := hu
    obtain ⟨y, hy, rfl⟩ := hv
    have hxy : x ≠ y := fun h => huv (by rw [h])
    have h1 := hC x hx y hy hxy
    have h2 := dist_punct x y
    split_ifs at h2 <;> omega
  have := card_le_maxCodeSize hsep
  rwa [Finset.card_image_of_injOn hinj, hcard] at this

/-- **Parity-extension identity.**  `A(N+1, 2t+2) = A(N, 2t+1)`: an extra neuron
devoted to parity buys one more unit of error *detection* but not a single extra
concept.  Odd and even minimum distances therefore carry the same information. -/
theorem maxCodeSize_parity_extension (N t : ℕ) :
    maxCodeSize (N + 1) (2 * t + 2) = maxCodeSize N (2 * t + 1) :=
  le_antisymm (maxCodeSize_punct_le N t) (maxCodeSize_le_extend N t)

/-- **One parity check halves capacity.**  `A(N+1, 2) = 2 ^ N`: requiring that
two concepts never differ in a single neuron costs exactly one bit. -/
theorem maxCodeSize_two (N : ℕ) : maxCodeSize (N + 1) 2 = 2 ^ N := by
  have h := maxCodeSize_parity_extension N 0
  simpa [maxCodeSize_one] using h

/-- **Even-distance capacity bounds.**  Transporting the Gilbert–Varshamov and
sphere-packing estimates across the parity-extension identity bounds the capacity
of even-distance neural codes on `N + 1` neurons by ball volumes on `N`
neurons. -/
theorem even_distance_capacity_sandwich (N t : ℕ) :
    2 ^ N ≤ maxCodeSize (N + 1) (2 * t + 2) * ballVolume N (2 * t) ∧
      maxCodeSize (N + 1) (2 * t + 2) * ballVolume N t ≤ 2 ^ N := by
  rw [maxCodeSize_parity_extension]
  exact capacity_sandwich N t

/-! ## Asymptotics: the entropy bound on ball volume and the GV rate theorem

Writing `δ = r / N` for the relative radius, the volume of a Hamming ball obeys
`ballVolume N r ≤ exp (N * H(δ))` with `H` the binary entropy (in nats).
Feeding this into Gilbert–Varshamov gives the classical **rate bound**: a
population of `N` neurons supports codebooks of rate at least `1 - H₂(δ)` bits
per neuron while tolerating `δ N` misfiring neurons. -/

lemma ballVolume_pos (N r : ℕ) : 0 < ballVolume N r := by
  rw [ballVolume]
  exact Finset.sum_pos' (fun i _ => Nat.zero_le _) ⟨0, by simp, by simp⟩

/-- Bernoulli weights decrease with the number of successes when `p ≤ 1/2`. -/
private lemma bernoulli_term_anti {N k r : ℕ} (hkr : k ≤ r) (hrN : r ≤ N) {p : ℝ}
    (hp0 : 0 ≤ p) (hp : p ≤ 1 - p) :
    p ^ r * (1 - p) ^ (N - r) ≤ p ^ k * (1 - p) ^ (N - k) := by
  have h1p : (0:ℝ) ≤ 1 - p := le_trans hp0 hp
  obtain ⟨j, rfl⟩ := Nat.exists_eq_add_of_le hkr
  have hNk : N - k = (N - (k + j)) + j := by omega
  rw [hNk, pow_add, pow_add]
  have hpj : p ^ j ≤ (1 - p) ^ j := pow_le_pow_left₀ hp0 hp j
  calc p ^ k * p ^ j * (1 - p) ^ (N - (k + j))
      ≤ p ^ k * (1 - p) ^ j * (1 - p) ^ (N - (k + j)) := by
        refine mul_le_mul_of_nonneg_right ?_ (by positivity)
        exact mul_le_mul_of_nonneg_left hpj (by positivity)
    _ = p ^ k * ((1 - p) ^ (N - (k + j)) * (1 - p) ^ j) := by ring

/-- **Chernoff-style volume estimate.**  For any `p ≤ 1/2`, the Bernoulli
probability of the radius-`r` ball is at most one, which pins the volume:
`ballVolume N r * p ^ r * (1-p) ^ (N-r) ≤ 1`. -/
theorem ballVolume_mul_le_one (N r : ℕ) (hr : r ≤ N) {p : ℝ} (hp0 : 0 ≤ p) (hp : p ≤ 1 - p) :
    (ballVolume N r : ℝ) * (p ^ r * (1 - p) ^ (N - r)) ≤ 1 := by
  have h1p : (0:ℝ) ≤ 1 - p := le_trans hp0 hp
  have hsub : Finset.range (r + 1) ⊆ Finset.range (N + 1) := by
    intro k hk; simp only [Finset.mem_range] at *; omega
  have hbinom : ∑ k ∈ Finset.range (N + 1), (N.choose k : ℝ) * (p ^ k * (1 - p) ^ (N - k)) = 1 := by
    have h := add_pow p (1 - p) N
    simp only [add_sub_cancel, one_pow] at h
    conv_rhs => rw [h]
    exact Finset.sum_congr rfl (fun k _ => by ring)
  calc (ballVolume N r : ℝ) * (p ^ r * (1 - p) ^ (N - r))
      = ∑ k ∈ Finset.range (r + 1), (N.choose k : ℝ) * (p ^ r * (1 - p) ^ (N - r)) := by
        rw [ballVolume]; push_cast; rw [Finset.sum_mul]
    _ ≤ ∑ k ∈ Finset.range (r + 1), (N.choose k : ℝ) * (p ^ k * (1 - p) ^ (N - k)) := by
        refine Finset.sum_le_sum (fun k hk => ?_)
        simp only [Finset.mem_range] at hk
        exact mul_le_mul_of_nonneg_left (bernoulli_term_anti (by omega) hr hp0 hp) (by positivity)
    _ ≤ ∑ k ∈ Finset.range (N + 1), (N.choose k : ℝ) * (p ^ k * (1 - p) ^ (N - k)) :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub (fun k _ _ => by positivity)
    _ = 1 := hbinom

/-- **Entropy bound on ball volume.**  For a relative radius `δ = r/N ≤ 1/2`,
`log (ballVolume N r) ≤ N * H(δ)` where `H` is the binary entropy in nats:
a Hamming ball of relative radius `δ` occupies at most an `exp(-N(log 2 - H(δ)))`
fraction of the `2 ^ N` patterns. -/
theorem log_ballVolume_le (N r : ℕ) (hr0 : 0 < r) (hr : 2 * r ≤ N) :
    Real.log (ballVolume N r) ≤ N * Real.binEntropy ((r : ℝ) / N) := by
  have hrN : r ≤ N := by omega
  have hN0 : (0:ℝ) < N := by exact_mod_cast (by omega : 0 < N)
  set p : ℝ := (r : ℝ) / N with hpdef
  have hr0' : (0:ℝ) < r := by exact_mod_cast hr0
  have hp0 : 0 < p := div_pos hr0' hN0
  have hNp : (N : ℝ) * p = r := by rw [hpdef]; field_simp
  have hple : p ≤ 1 - p := by
    rw [le_sub_iff_add_le, hpdef, ← add_div, div_le_one hN0]
    have : (2 : ℝ) * r ≤ N := by exact_mod_cast hr
    linarith
  have h1p : (0:ℝ) < 1 - p := lt_of_lt_of_le hp0 hple
  have hV := ballVolume_mul_le_one N r hrN hp0.le hple
  have hVpos : (0:ℝ) < (ballVolume N r : ℝ) := by exact_mod_cast ballVolume_pos N r
  have hlog := Real.log_le_log (by positivity) hV
  rw [Real.log_one, Real.log_mul (ne_of_gt hVpos) (by positivity),
    Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow] at hlog
  have hcast : ((N - r : ℕ) : ℝ) = (N : ℝ) - r := by push_cast [hrN]; ring
  rw [hcast] at hlog
  have h2 : (N : ℝ) * (1 - p) = (N : ℝ) - r := by rw [mul_sub, mul_one, hNp]
  have hent : (N : ℝ) * Real.binEntropy p
      = -((r : ℝ) * Real.log p) - ((N : ℝ) - r) * Real.log (1 - p) := by
    rw [Real.binEntropy, Real.log_inv, Real.log_inv]
    calc (N:ℝ) * (p * -Real.log p + (1 - p) * -Real.log (1 - p))
        = -(((N:ℝ) * p) * Real.log p) - (((N:ℝ) * (1 - p)) * Real.log (1 - p)) := by ring
      _ = -((r : ℝ) * Real.log p) - ((N : ℝ) - r) * Real.log (1 - p) := by rw [hNp, h2]
  rw [hent]
  linarith

/-- **Gilbert–Varshamov rate theorem (nats).**  With relative distance
`δ = (d-1)/N ≤ 1/2`,

`log A(N,d) ≥ N (log 2 - H(δ))`.

A neural population tolerating `d - 1` misfiring neurons still encodes
exponentially many concepts, at an explicit exponent. -/
theorem gilbert_varshamov_rate (N d : ℕ) (hd : 2 ≤ d) (hdN : 2 * (d - 1) ≤ N) :
    (N : ℝ) * Real.log 2 - N * Real.binEntropy (((d - 1 : ℕ) : ℝ) / N)
      ≤ Real.log (maxCodeSize N d) := by
  have hgv := gilbert_varshamov N (show 1 ≤ d by omega)
  have hApos : (0:ℝ) < (maxCodeSize N d : ℝ) := by
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one (one_le_maxCodeSize N d)
  have hVpos : (0:ℝ) < (ballVolume N (d - 1) : ℝ) := by
    exact_mod_cast ballVolume_pos N (d - 1)
  have hcast : ((2:ℝ) ^ N) ≤ (maxCodeSize N d : ℝ) * (ballVolume N (d - 1) : ℝ) := by
    exact_mod_cast hgv
  have hlog := Real.log_le_log (by positivity) hcast
  rw [Real.log_pow, Real.log_mul (ne_of_gt hApos) (ne_of_gt hVpos)] at hlog
  have hVol := log_ballVolume_le N (d - 1) (by omega) hdN
  linarith

/-- **Gilbert–Varshamov rate theorem (bits per neuron).**  The information rate
`log₂ A(N,d) / N` of the best `d`-separated neural code is at least
`1 - H₂(δ)` with `δ = (d-1)/N` the relative noise tolerance and `H₂` the binary
entropy in bits. -/
theorem gilbert_varshamov_rate_bits (N d : ℕ) (hd : 2 ≤ d) (hdN : 2 * (d - 1) ≤ N) :
    1 - Real.binEntropy (((d - 1 : ℕ) : ℝ) / N) / Real.log 2
      ≤ Real.logb 2 (maxCodeSize N d) / N := by
  have hN0 : (0:ℝ) < N := by exact_mod_cast (by omega : 0 < N)
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h := gilbert_varshamov_rate N d hd hdN
  rw [Real.logb, div_div, le_div_iff₀ (by positivity)]
  have hexp : (1 - Real.binEntropy (((d - 1 : ℕ) : ℝ) / N) / Real.log 2) * (Real.log 2 * N)
      = (N : ℝ) * Real.log 2 - N * Real.binEntropy (((d - 1 : ℕ) : ℝ) / N) := by
    field_simp
  rw [hexp]
  exact h

end NeuralCodeCapacity