import Mathlib

/-!
# Error-Correcting Neural Codes: the Sphere-Packing (Hamming) Bound

This file deepens the neural-coding theory of `Catalog/Novelty/NeuralCoding.lean`.
There we counted the *raw capacity* of `N` binary neurons (`2 ^ N` distinct
patterns).  Here we ask a finer question: how many patterns can a population use
if it wants to be **robust to noise**?  If two used patterns are too close in
Hamming distance, a single misfiring neuron can be mistaken for the other, so a
noise-tolerant "codebook" must keep its patterns spread apart.

## Model

A **neural code** on `N` neurons is again a binary pattern `NeuralCode N =
Fin N → Bool`.  The **Hamming distance** between two patterns is the number of
neurons on which they disagree (`hammingDist`, from Mathlib), i.e. the number of
neurons that must misfire to confuse one for the other.  A **codebook** is a
`Finset` of patterns; it **corrects `t` errors** when any two distinct codewords
are at distance `≥ 2t + 1`, so that decoding to the nearest codeword recovers the
intended pattern after up to `t` neuron flips.

## Results (the chain)

1. `hammingDist_false_eq_weight` — the Hamming distance from the silent pattern
   is the **weight** (number of active neurons).
2. `card_weight_eq` — there are exactly `N.choose k` patterns of weight `k`.
3. `card_neuralCode` / `sum_choose_weight` — there are `2 ^ N` patterns in all,
   equivalently `∑_{k} C(N,k) = 2^N` (partition by weight).
4. `ball` and `hammingDist_xor` / `ball_card_center_indep` — the number of
   patterns within distance `r` of a codeword does not depend on the codeword
   (Hamming balls are **translation invariant** under neuron-wise XOR).
5. `ball_card` — the **volume** of a Hamming ball of radius `r` is
   `∑_{k=0}^{r} C(N,k)` (uses 2 and 4).
6. `balls_pairwiseDisjoint` — the radius-`t` balls around the codewords of a
   `t`-error-correcting codebook are pairwise disjoint (triangle inequality).
7. `hamming_bound` — **the sphere-packing / Hamming bound**: a `t`-error-
   correcting codebook `C` on `N` neurons satisfies
   `|C| · (∑_{k=0}^{t} C(N,k)) ≤ 2^N` (uses 5 and 6).
8. `hamming_bound_capacity` — with `t = 0` this recovers the raw capacity bound
   `|C| ≤ 2^N`, and `singleton_error_correct_card` gives the concrete
   noise-tolerance price: a `1`-error-correcting code uses at most
   `2^N / (N+1)` of the `2^N` patterns.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): robustness costs capacity, and the exact exchange rate
is geometric — each codeword must "own" a Hamming ball of radius `t`, and these
balls tile disjointly inside the `2^N` pattern cube.

Experiment (Experimenter): we identified the pattern space with `Fin N → Bool`,
used Mathlib's `hammingDist`, proved Hamming balls are translation invariant under
neuron-wise XOR (so all balls have the same volume `∑_{k≤t} C(N,k)`), showed the
balls around distinct codewords are disjoint via the triangle inequality, and
summed with `Finset.card_biUnion`.

Analysis (Analyst): the bound is tight enough to recover the raw capacity `2^N`
at `t = 0` and yields the concrete `2^N/(N+1)` ceiling for single-error
correction; richer noise models only shrink the codebook further.
-/

namespace NeuralErrorCorrection

open Finset

/-- A **neural code** on `N` neurons: a binary activity pattern. -/
abbrev NeuralCode (N : ℕ) : Type := Fin N → Bool

/-- The **silent** pattern (all neurons off). -/
def silent (N : ℕ) : NeuralCode N := fun _ => false

/-- The **weight** of a pattern: the number of active neurons. -/
def weight {N : ℕ} (c : NeuralCode N) : ℕ :=
  (Finset.univ.filter (fun i => c i = true)).card

/-! ## 1–3. Weight, sparse counts, and total capacity -/

/-
The Hamming distance from the silent pattern is the weight.
-/
theorem hammingDist_false_eq_weight {N : ℕ} (c : NeuralCode N) :
    hammingDist (silent N) c = weight c := by
  unfold hammingDist weight silent; aesop;

/-
**Sparse count.** There are exactly `N.choose k` patterns of weight `k`.
-/
theorem card_weight_eq (N k : ℕ) :
    (Finset.univ.filter (fun c : NeuralCode N => weight c = k)).card = N.choose k := by
  -- We_count the number of binary patterns with exactly $k$ ones by choosing $k$ positions out of $N$ to be ones.
  have h_choose : Finset.card (Finset.filter (fun c : Fin N → Bool => Finset.card (Finset.filter (fun i => c i = true) Finset.univ) = k) (Finset.univ : Finset (Fin N → Bool))) = Finset.card (Finset.powersetCard k (Finset.univ : Finset (Fin N))) := by
    refine' Finset.card_bij ( fun c hc => Finset.univ.filter ( fun i => c i = true ) ) _ _ _ <;> simp +decide;
    · intro a₁ ha₁ a₂ ha₂ h; ext i; replace h := Finset.ext_iff.mp h i; aesop;
    · exact fun b hb => ⟨ fun i => if i ∈ b then Bool.true else Bool.false, by simpa [ Finset.filter_mem_eq_inter, Finset.filter_not ] using hb ⟩;
  aesop

/-- **Coding capacity.** There are exactly `2 ^ N` distinct neural codes. -/
theorem card_neuralCode (N : ℕ) : Fintype.card (NeuralCode N) = 2 ^ N := by
  simp

/-- **Partition by weight.** Summing the sparse counts over all weights recovers
the total capacity: `∑_{k=0}^{N} C(N,k) = 2^N`. -/
theorem sum_choose_weight (N : ℕ) :
    ∑ k ∈ range (N + 1), N.choose k = 2 ^ N :=
  Nat.sum_range_choose N

/-! ## 4–5. Hamming balls and their volume -/

/-- The **Hamming ball** of radius `r` around a pattern `c`: all patterns within
distance `r` (correctable to `c` after at most `r` neuron flips). -/
def ball {N : ℕ} (c : NeuralCode N) (r : ℕ) : Finset (NeuralCode N) :=
  Finset.univ.filter (fun x => hammingDist c x ≤ r)

/-
Neuron-wise XOR with a fixed pattern preserves Hamming distance from that
pattern: `hammingDist c x = hammingDist (silent) (fun i => c i != x i)`.
-/
theorem hammingDist_xor {N : ℕ} (c x : NeuralCode N) :
    hammingDist c x = hammingDist (silent N) (fun i => (c i != x i)) := by
  unfold hammingDist silent;
  grind

/-
**Balls are translation invariant.** The number of patterns within distance
`r` of a codeword does not depend on the codeword.
-/
theorem ball_card_center_indep {N : ℕ} (c : NeuralCode N) (r : ℕ) :
    (ball c r).card = (ball (silent N) r).card := by
  refine' Finset.card_bij ( fun x _ => fun i => ( c i != x i ) ) _ _ _;
  · simp +decide [ *, ball ];
    exact fun x hx => hammingDist_xor c x ▸ hx;
  · simp +contextual [ funext_iff ];
  · intro b hb; use fun i => ( c i != b i ) ; simp_all +decide [ ball ] ;
    convert hb using 1;
    convert hammingDist_xor c ( fun i => c i != b i ) using 1;
    exact congr_arg _ ( funext fun i => by cases c i <;> cases b i <;> rfl )

/-
**Ball volume around the silent pattern.**
-/
theorem ball_silent_card (N r : ℕ) :
    (ball (silent N) r).card = ∑ k ∈ range (r + 1), N.choose k := by
  rw [ show ball ( silent N ) r = Finset.biUnion ( Finset.range ( r + 1 ) ) ( fun k => Finset.filter ( fun c : NeuralCode N => weight c = k ) Finset.univ ) from ?_ ];
  · rw [ Finset.card_biUnion ];
    · exact Finset.sum_congr rfl fun _ _ => card_weight_eq _ _;
    · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by aesop;
  · ext c; simp [ball, hammingDist_false_eq_weight]

/-- **Volume of a Hamming ball.** A ball of radius `r` on `N` neurons contains
exactly `∑_{k=0}^{r} C(N,k)` patterns, independently of its center. -/
theorem ball_card {N : ℕ} (c : NeuralCode N) (r : ℕ) :
    (ball c r).card = ∑ k ∈ range (r + 1), N.choose k := by
  rw [ball_card_center_indep, ball_silent_card]

/-! ## 6–7. Disjoint balls and the sphere-packing bound -/

/-
**Balls around codewords of a `t`-error-correcting code are disjoint.** If
any two distinct codewords are at distance `≥ 2t+1`, then their radius-`t` balls
do not overlap.
-/
theorem balls_pairwiseDisjoint {N t : ℕ} (C : Finset (NeuralCode N))
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    (C : Set (NeuralCode N)).PairwiseDisjoint (fun c => ball c t) := by
  intro x hx y hy hxy; simp_all +decide [ Ne, Finset.disjoint_left ] ;
  intro z hz₁ hz₂; exact absurd ( hmin x hx y hy hxy ) ( by linarith [ Finset.mem_filter.mp hz₁, Finset.mem_filter.mp hz₂, show hammingDist x y ≤ hammingDist x z + hammingDist y z from by simpa [ hammingDist_comm ] using hammingDist_triangle x z y ] ) ;

/-
**Sphere-packing (Hamming) bound.** A codebook `C` on `N` neurons that
corrects `t` errors (any two distinct codewords at Hamming distance `≥ 2t+1`)
satisfies `|C| · (∑_{k=0}^{t} C(N,k)) ≤ 2^N`: noise tolerance costs capacity,
each codeword claiming a disjoint Hamming ball of volume `∑_{k≤t} C(N,k)`.
-/
theorem hamming_bound {N t : ℕ} (C : Finset (NeuralCode N))
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    C.card * (∑ k ∈ range (t + 1), N.choose k) ≤ 2 ^ N := by
  have h_sphere_packing : (Finset.biUnion C (fun c => ball c t)).card ≤ 2 ^ N := by
    exact le_trans ( Finset.card_le_univ _ ) ( by norm_num [ card_neuralCode ] );
  rw [ Finset.card_biUnion ] at h_sphere_packing;
  · convert h_sphere_packing using 1 ; rw [ Finset.sum_congr rfl fun x hx => ball_card x t ] ; simp +decide [ mul_comm ];
  · exact balls_pairwiseDisjoint C hmin

/-! ## 8. Consequences -/

/-
**Zero-error special case recovers raw capacity.** With `t = 0` the Hamming
bound is exactly `|C| ≤ 2^N`.
-/
theorem hamming_bound_capacity {N : ℕ} (C : Finset (NeuralCode N)) :
    C.card ≤ 2 ^ N := by
  exact le_trans ( Finset.card_le_univ _ ) ( by norm_num [ card_neuralCode ] )

/-
**The price of single-error correction.** A codebook on `N` neurons in which
distinct codewords differ in at least `3` neurons (so any single misfire is
correctable) uses at most a `1/(N+1)` fraction of all patterns:
`|C| · (N + 1) ≤ 2^N`.
-/
theorem singleton_error_correct_card {N : ℕ} (C : Finset (NeuralCode N))
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 3 ≤ hammingDist x y) :
    C.card * (N + 1) ≤ 2 ^ N := by
  convert hamming_bound C _ using 2;
  rotate_left;
  exacts [ 1, fun x hx y hy hxy => hmin x hx y hy hxy, by simp +arith +decide [ Finset.sum_range_succ' ] ]

end NeuralErrorCorrection