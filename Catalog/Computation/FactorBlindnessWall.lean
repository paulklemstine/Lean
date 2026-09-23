/-
# The factor-blindness wall: a symmetric battery leaks exactly zero which-factor bits

The experimental thread this file formalises reported a *joint which-factor reading* of
`0.0469` bits for a four-field CRT-chained battery code, and then found that a 200-shuffle
permutation null had mean `0.0469` as well (`z = +0.05`): the entire reading was
**sparse plug-in bias**, and the battery's factor-blindness survived.

This file turns that empirical verdict into theorems.  Two independent statements are proved,
and together they say precisely what the experiment could only estimate.

## 1. The wall is exact, not small

`galoisBlind_zero_leakage` — let `S` be any finite population of ordered pairs which is
*swap-closed* (`(p,q) ∈ S → (q,p) ∈ S`) and *off-diagonal* (`p ≠ q`), and let `c` be any
readout that is **symmetric** (`c (q,p) = c (p,q)`).  Then the empirical joint law of
(which-factor label, readout) on `S` is a *product* law, so its mutual information is
`0` **exactly**.  No sampling, no null, no sensitivity floor.

The CRT-chained battery is such a readout, because it is routed through the *traces*
`p + q` and `p·q` only — i.e. through the coefficients of `X² − (p+q)X + pq`, which is the
Galois-invariant part of the pair.  `batteryCode_of_trace_eq` proves the readout factors
through `(p+q, p·q)`; `batteryCode_swap` is the corollary; `battery4_zero_leakage` is the
flagship instance for the four-field battery `[3,5,7,11]`.

## 2. The reading really was bias

`plugInMI_nonneg` (in `Computation.FactorBlindnessInformation`) says the plug-in functional is
one-sided: noise can only push a reading up.  Here we exhibit the cleanest possible exact
instance of the phenomenon:

* `uniformSquare_mutualInfo` — a population with *exactly zero* dependence;
* `permMatrix_mutualInfo` — **every** two-sample drawn from it, and every one of its
  label-permuted surrogates, reads a full `1` bit;
* `wall_was_bias` — hence observed reading = permutation-null mean = `1` bit, while the truth
  is `0`; the z-score numerator vanishes identically.  A positive plug-in reading with a
  matching null is *exactly* the signature of bias, and nothing else.

## 3. Capacity is capped by the alphabet, not by the leakage

`batteryCode_lt` bounds the chained code by `∏ mᵢ²`, and `battery4_capacity_ceiling` converts
that into the entropy ceiling `H ≤ log₂ 1334025 ≈ 20.35` bits for the `[3,5,7,11]` battery.
Capacity and leakage are therefore logically independent: the battery may carry many bits of
symmetric trace-routed content while carrying zero bits about *which* factor is which.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the flagged `0.0469`-bit wall is not a small real leak but an exactly
  zero leak seen through a biased estimator.
Experiment (Stage 2, `ComputationalEvidence.md`): 3995 ordered prime pairs from the primes in
  (50, 2000), four-field code `[3,5,7,11]`; observed plug-in reading `0.8985` bits,
  200-shuffle null mean `0.8996`, sd `0.0046`, `z = −0.23` — the same signature as the
  reported experiment, only louder because the sample is sparser (3597 distinct codes among
  3995 samples).  The *exact* population reading over all 3540 ordered pairs of the first 60
  such primes is `0.000000000000`.
Analysis (Stage 3): the exact zero is forced by an involution, not by cancellation of many
  small terms.  Prod.swap is a fixed-point-free involution of the population that preserves
  every code fiber and flips the label, so each fiber is *exactly* half-and-half; the joint
  table is a product table cell by cell.  The estimator's bias is the complementary fact:
  the plug-in functional is a nonnegative function of the table that vanishes only on product
  tables, and sparse tables are never product tables.
Critique (Stage 4): off-diagonality is load-bearing — a population containing `(p,p)` has a
  swap-fixed point and the halving fails; swap-closure is load-bearing — an arbitrary
  population is not exchangeable.  Both are hypotheses, not accidents, and both hold for the
  factoring battery, whose population of ordered factorisations is swap-closed by
  construction and off-diagonal whenever the modulus is squarefree.  The bias theorem is
  stated for an explicit two-sample where the null has *zero* variance, so no probabilistic
  hedging is needed.
Synthesis (Stage 5): factor-blindness is a Galois statement (`the readout is invariant under
  the nontrivial element of the symmetry group of the unordered pair`), leakage is a
  representation-theoretic obstruction (`no invariant function separates an orbit`), and the
  observed wall is an estimator artefact.
-/
import Mathlib
import Computation.FactorBlindnessInformation

namespace Computation.FactorBlindness

open Finset

/-! ## Part 1. The CRT-chained battery code and its trace routing -/

/-- One accumulation step of the battery: absorb the two symmetric trace readouts
`(p+q) mod m` and `(p·q) mod m` of the field of modulus `m` into a CRT-style chain. -/
def chainStep (m : ℕ) (x : ℕ × ℕ) (acc : ℕ) : ℕ :=
  (acc * m + (x.1 + x.2) % m) * m + (x.1 * x.2) % m

/-- The battery chain with an explicit accumulator. -/
def batteryAux (x : ℕ × ℕ) : List ℕ → ℕ → ℕ
  | [], acc => acc
  | m :: ms, acc => batteryAux x ms (chainStep m x acc)

/-- **The battery code**: the CRT-chained readout of the fields with moduli `ms`. -/
def batteryCode (ms : List ℕ) (x : ℕ × ℕ) : ℕ := batteryAux x ms 0

/-- **Trace routing.**  The battery code depends on the pair only through the two elementary
symmetric functions `p + q` and `p · q` — that is, only through the coefficients of the
monic quadratic `X² − (p+q)X + pq`.  Everything the battery can see is Galois-invariant. -/
theorem batteryAux_of_trace_eq {x y : ℕ × ℕ} (hs : x.1 + x.2 = y.1 + y.2)
    (hp : x.1 * x.2 = y.1 * y.2) : ∀ (ms : List ℕ) (acc : ℕ),
    batteryAux x ms acc = batteryAux y ms acc := by
  intro ms
  induction ms with
  | nil => intro acc; rfl
  | cons m ms ih =>
    intro acc
    simp only [batteryAux, chainStep, hs, hp]
    exact ih _

/-- The battery code is a function of the traces alone. -/
theorem batteryCode_of_trace_eq {x y : ℕ × ℕ} (hs : x.1 + x.2 = y.1 + y.2)
    (hp : x.1 * x.2 = y.1 * y.2) (ms : List ℕ) : batteryCode ms x = batteryCode ms y :=
  batteryAux_of_trace_eq hs hp ms 0

/-- **Swap symmetry** of the battery code: the corollary of trace routing that drives the
factor-blindness theorem. -/
theorem batteryCode_swap (ms : List ℕ) (x : ℕ × ℕ) :
    batteryCode ms x.swap = batteryCode ms x :=
  batteryCode_of_trace_eq (by simp [Prod.fst_swap, Prod.snd_swap, Nat.add_comm])
    (by simp [Prod.fst_swap, Prod.snd_swap, Nat.mul_comm]) ms

/-- The chained code never exceeds the product of the squared moduli: each field contributes
two residues, hence a factor `m²` of alphabet. -/
theorem batteryAux_lt (x : ℕ × ℕ) : ∀ (ms : List ℕ) (acc A : ℕ),
    (∀ m ∈ ms, 0 < m) → acc < A → batteryAux x ms acc < A * (ms.map (fun m => m ^ 2)).prod := by
  intro ms
  induction ms with
  | nil => intro acc A _ h; simpa using h
  | cons m ms ih =>
    intro acc A hpos hacc
    have hm : 0 < m := hpos m (by simp)
    have hstep : chainStep m x acc < A * m ^ 2 := by
      have h1 : (x.1 + x.2) % m < m := Nat.mod_lt _ hm
      have h2 : (x.1 * x.2) % m < m := Nat.mod_lt _ hm
      have h3 : acc + 1 ≤ A := hacc
      have hres : (x.1 + x.2) % m * m + (x.1 * x.2) % m < m ^ 2 :=
        calc (x.1 + x.2) % m * m + (x.1 * x.2) % m < (x.1 + x.2) % m * m + m := by omega
          _ = ((x.1 + x.2) % m + 1) * m := by ring
          _ ≤ m * m := Nat.mul_le_mul_right m h1
          _ = m ^ 2 := (sq m).symm
      calc chainStep m x acc
          = acc * m ^ 2 + ((x.1 + x.2) % m * m + (x.1 * x.2) % m) := by
            simp only [chainStep]; ring
        _ < acc * m ^ 2 + m ^ 2 := by omega
        _ = (acc + 1) * m ^ 2 := by ring
        _ ≤ A * m ^ 2 := Nat.mul_le_mul_right _ h3
    have := ih (chainStep m x acc) (A * m ^ 2) (fun k hk => hpos k (by simp [hk])) hstep
    simpa [batteryAux, List.map, List.prod_cons, mul_assoc] using this

/-- Alphabet bound for the battery code. -/
theorem batteryCode_lt (ms : List ℕ) (hpos : ∀ m ∈ ms, 0 < m) (x : ℕ × ℕ) :
    batteryCode ms ((x.1, x.2)) < (ms.map (fun m => m ^ 2)).prod := by
  have := batteryAux_lt x ms 0 1 hpos (by norm_num)
  simpa [batteryCode] using this

/-! ### The four-field battery `[3,5,7,11]` -/

/-- The alphabet size of the four-field battery: `(3·5·7·11)² = 1334025`. -/
theorem battery4_lt (x : ℕ × ℕ) : batteryCode [3, 5, 7, 11] x < 1334025 := by
  have := batteryCode_lt [3, 5, 7, 11] (by decide) x
  norm_num at this
  simpa using this

/-- The four-field CRT-chained battery code, as a readout into a finite alphabet. -/
def battery4 (x : ℕ × ℕ) : Fin 1334025 := ⟨batteryCode [3, 5, 7, 11] x, battery4_lt x⟩

theorem battery4_swap (x : ℕ × ℕ) : battery4 x.swap = battery4 x := by
  apply Fin.ext
  simpa [battery4] using batteryCode_swap [3, 5, 7, 11] x

/-! ## Part 2. Exact factor blindness of any symmetric readout -/

section Blindness

variable {K : Type*} [DecidableEq K] [Fintype K]

/-- The which-factor label: `true` when the *second* coordinate is the bigger factor. -/
def biggerLabel (x : ℕ × ℕ) : Bool := decide (x.1 < x.2)

/-- The cell of the contingency table: population members with readout `k` and label `b`. -/
def codeCell (S : Finset (ℕ × ℕ)) (c : ℕ × ℕ → K) (b : Bool) (k : K) : Finset (ℕ × ℕ) :=
  S.filter (fun x => c x = k ∧ biggerLabel x = b)

/-- The readout fiber: population members with readout `k`, both labels together. -/
def codeFiber (S : Finset (ℕ × ℕ)) (c : ℕ × ℕ → K) (k : K) : Finset (ℕ × ℕ) :=
  S.filter (fun x => c x = k)

/-- The empirical joint law of (label, readout) on the population `S`. -/
noncomputable def jointDist (S : Finset (ℕ × ℕ)) (c : ℕ × ℕ → K) (b : Bool) (k : K) : ℝ :=
  ((codeCell S c b k).card : ℝ) / S.card

variable {S : Finset (ℕ × ℕ)} {c : ℕ × ℕ → K}

omit [Fintype K] in
/-- **The halving lemma.**  On a swap-closed, off-diagonal population, `Prod.swap` is a
fixed-point-free involution that preserves every readout fiber of a symmetric readout and
flips the which-factor label.  Hence every fiber splits exactly in half. -/
theorem codeCell_card_eq (hswap : ∀ x ∈ S, x.swap ∈ S) (hoff : ∀ x ∈ S, x.1 ≠ x.2)
    (hc : ∀ x, c x.swap = c x) (k : K) :
    (codeCell S c true k).card = (codeCell S c false k).card := by
  refine Finset.card_bij' (fun x _ => x.swap) (fun x _ => x.swap) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [codeCell, mem_filter] at ha ⊢
    obtain ⟨haS, hak, hab⟩ := ha
    refine ⟨hswap a haS, by rw [hc]; exact hak, ?_⟩
    have : a.1 < a.2 := by simpa [biggerLabel] using hab
    simp [biggerLabel, Prod.fst_swap, Prod.snd_swap]
    omega
  · intro a ha
    simp only [codeCell, mem_filter] at ha ⊢
    obtain ⟨haS, hak, hab⟩ := ha
    have hne : a.1 ≠ a.2 := hoff a haS
    have : ¬ a.1 < a.2 := by simpa [biggerLabel] using hab
    refine ⟨hswap a haS, by rw [hc]; exact hak, ?_⟩
    simp [biggerLabel, Prod.fst_swap, Prod.snd_swap]
    omega
  · intro a _; simp
  · intro a _; simp

omit [Fintype K] in
/-- The two label cells of a readout fiber exhaust it. -/
theorem codeCell_card_add (k : K) :
    (codeCell S c true k).card + (codeCell S c false k).card = (codeFiber S c k).card := by
  have h1 : codeCell S c true k = (codeFiber S c k).filter (fun x => biggerLabel x = true) := by
    simp [codeCell, codeFiber, Finset.filter_filter]
  have h2 : codeCell S c false k
      = (codeFiber S c k).filter (fun x => ¬ biggerLabel x = true) := by
    simp only [codeCell, codeFiber, Finset.filter_filter]
    apply Finset.filter_congr
    intro x _
    cases hb : biggerLabel x <;> simp
  rw [h1, h2]
  exact Finset.card_filter_add_card_filter_not _

/-- The readout fibers partition the population. -/
theorem sum_codeFiber_card : ∑ k, (codeFiber S c k).card = S.card := by
  rw [eq_comm]
  exact Finset.card_eq_sum_card_fiberwise (fun x _ => mem_univ (c x))

omit [Fintype K] in
/-- The `K`-marginal of the empirical joint law is the fiber frequency. -/
theorem margK_jointDist (k : K) :
    margK (jointDist S c) k = ((codeFiber S c k).card : ℝ) / S.card := by
  have : margK (jointDist S c) k
      = ((codeCell S c true k).card + (codeCell S c false k).card : ℝ) / S.card := by
    simp [margK, jointDist, add_div, add_comm]
  rw [this, ← Nat.cast_add, codeCell_card_add]

/-- The label marginal: on a swap-closed off-diagonal population, each label has mass
exactly `1/2` (and mass `0` on the empty population). -/
theorem margL_jointDist (hswap : ∀ x ∈ S, x.swap ∈ S) (hoff : ∀ x ∈ S, x.1 ≠ x.2)
    (hc : ∀ x, c x.swap = c x) (b : Bool) (hS : S.Nonempty) :
    margL (jointDist S c) b = 1 / 2 := by
  have hcard : (0:ℝ) < S.card := by
    have : 0 < S.card := Finset.card_pos.2 hS
    exact_mod_cast this
  have hcell : ∀ k : K, 2 * (codeCell S c b k).card = (codeFiber S c k).card := by
    intro k
    cases b with
    | false => rw [← codeCell_card_add (S := S) (c := c) k, codeCell_card_eq hswap hoff hc k]; ring
    | true => rw [← codeCell_card_add (S := S) (c := c) k, codeCell_card_eq hswap hoff hc k]; ring
  have hsum : 2 * ∑ k, (codeCell S c b k).card = S.card := by
    rw [Finset.mul_sum, Finset.sum_congr rfl (fun k _ => hcell k)]
    exact sum_codeFiber_card
  have : margL (jointDist S c) b = (∑ k, ((codeCell S c b k).card : ℝ)) / S.card := by
    simp [margL, jointDist, Finset.sum_div]
  rw [this]
  have hsumR : (2:ℝ) * ∑ k, ((codeCell S c b k).card : ℝ) = (S.card : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hsum
  field_simp
  linarith

/-- **The contingency table of a symmetric readout is a product table.** -/
theorem jointDist_product (hswap : ∀ x ∈ S, x.swap ∈ S) (hoff : ∀ x ∈ S, x.1 ≠ x.2)
    (hc : ∀ x, c x.swap = c x) (b : Bool) (k : K) :
    jointDist S c b k = margL (jointDist S c) b * margK (jointDist S c) k := by
  rcases S.eq_empty_or_nonempty with hS | hS
  · subst hS
    simp [jointDist, margL, margK, codeCell]
  have hcard : (0:ℝ) < S.card := by
    have : 0 < S.card := Finset.card_pos.2 hS
    exact_mod_cast this
  have hcell : 2 * (codeCell S c b k).card = (codeFiber S c k).card := by
    cases b with
    | false => rw [← codeCell_card_add (S := S) (c := c) k, codeCell_card_eq hswap hoff hc k]; ring
    | true => rw [← codeCell_card_add (S := S) (c := c) k, codeCell_card_eq hswap hoff hc k]; ring
  have hcellR : (2:ℝ) * ((codeCell S c b k).card : ℝ) = ((codeFiber S c k).card : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hcell
  rw [margL_jointDist hswap hoff hc b hS, margK_jointDist]
  unfold jointDist
  field_simp
  linarith

/-- **Exact factor blindness.**  On any swap-closed, off-diagonal population, a symmetric
readout carries *exactly zero* bits about which factor is the bigger one.  The wall is not a
small number: it is `0`. -/
theorem galoisBlind_zero_leakage (hswap : ∀ x ∈ S, x.swap ∈ S) (hoff : ∀ x ∈ S, x.1 ≠ x.2)
    (hc : ∀ x, c x.swap = c x) : mutualInfo (jointDist S c) = 0 :=
  mutualInfo_eq_zero_of_product (jointDist_product hswap hoff hc)

end Blindness

/-- **Flagship instance.**  The four-field CRT-chained battery `[3,5,7,11]` has exactly zero
which-factor leakage on every swap-closed, off-diagonal population. -/
theorem battery4_zero_leakage {S : Finset (ℕ × ℕ)} (hswap : ∀ x ∈ S, x.swap ∈ S)
    (hoff : ∀ x ∈ S, x.1 ≠ x.2) : mutualInfo (jointDist S battery4) = 0 :=
  galoisBlind_zero_leakage hswap hoff battery4_swap

/-- **Capacity ceiling.**  Whatever the battery's readout distribution, its entropy is capped
by the alphabet: `log₂ 1334025 ≈ 20.35` bits for the four-field battery.  Capacity and
leakage are logically independent quantities. -/
theorem battery4_capacity_ceiling {r : Fin 1334025 → ℝ} (hr : ∀ k, 0 ≤ r k)
    (htot : ∑ k, r k = 1) : entropy r ≤ Real.logb 2 1334025 := by
  have h := entropy_le_logb_card hr htot
  simpa using h

/-- **Nonvacuity.**  The hypotheses of `battery4_zero_leakage` are satisfiable by a nonempty
population on which the battery readout is *not* constant: the battery genuinely carries
symmetric content (at least one bit of readout entropy) while leaking exactly zero bits about
which factor is bigger. -/
theorem battery4_zero_leakage_nonvacuous :
    ∃ S : Finset (ℕ × ℕ), S.Nonempty ∧ (∀ x ∈ S, x.swap ∈ S) ∧ (∀ x ∈ S, x.1 ≠ x.2) ∧
      (∃ x ∈ S, ∃ y ∈ S, battery4 x ≠ battery4 y) ∧
      mutualInfo (jointDist S battery4) = 0 := by
  refine ⟨{(3, 5), (5, 3), (7, 11), (11, 7)}, ⟨(3, 5), by decide⟩, by decide, by decide, ?_, ?_⟩
  · exact ⟨(3, 5), by decide, (7, 11), by decide, by decide⟩
  · exact battery4_zero_leakage (by decide) (by decide)

/-! ## Part 3. The wall was bias: an exact zero-variance instance -/

/-- A population with *exactly zero* dependence between label and readout. -/
noncomputable def uniformSquare : Fin 2 → Fin 2 → ℝ := fun _ _ => 1 / 4

/-- The empirical table of a two-sample whose labels are attached by the permutation `σ`:
sample `i` carries readout `i` and label `σ i`. -/
noncomputable def permTable (σ : Equiv.Perm (Fin 2)) : Fin 2 → Fin 2 → ℝ :=
  fun l k => if σ k = l then 1 / 2 else 0

/-- The population is genuinely independent: its exact reading is `0` bits. -/
theorem uniformSquare_mutualInfo : mutualInfo uniformSquare = 0 := by
  apply mutualInfo_eq_zero_of_product
  intro l k
  simp [uniformSquare, margL, margK]
  norm_num

/-- **Every** label-permuted surrogate of the two-sample reads a full bit. -/
theorem permMatrix_mutualInfo (σ : Equiv.Perm (Fin 2)) : mutualInfo (permTable σ) = 1 := by
  have hσ : ∀ τ : Equiv.Perm (Fin 2), τ = 1 ∨ τ = Equiv.swap 0 1 := by decide
  rcases hσ σ with h | h <;> subst h
  all_goals
    simp [mutualInfo, permTable, margL, margK, Fin.sum_univ_two, Equiv.swap_apply_def]
  norm_num

/-- **THE WALL WAS BIAS.**  For the two-sample drawn from the exactly-independent population
`uniformSquare`, the observed plug-in reading is `1` bit, the permutation null mean is `1`
bit, the null has zero spread, and the truth is `0` bits.  The z-score numerator vanishes
identically: a positive reading that matches its own null is an estimator artefact, not a
leak. -/
theorem wall_was_bias :
    mutualInfo uniformSquare = 0 ∧
    mutualInfo (permTable 1) = 1 ∧
    (∀ σ : Equiv.Perm (Fin 2), mutualInfo (permTable σ) = mutualInfo (permTable 1)) ∧
    mutualInfo (permTable 1)
      - (∑ σ : Equiv.Perm (Fin 2), mutualInfo (permTable σ))
          / (Fintype.card (Equiv.Perm (Fin 2))) = 0 := by
  refine ⟨uniformSquare_mutualInfo, permMatrix_mutualInfo 1, fun σ => ?_, ?_⟩
  · rw [permMatrix_mutualInfo σ, permMatrix_mutualInfo 1]
  · rw [Finset.sum_congr rfl (fun σ _ => permMatrix_mutualInfo σ)]
    rw [permMatrix_mutualInfo 1]
    simp [Finset.sum_const, Finset.card_univ]

/-- The bias is not a sign error: the reading is positive while the truth is zero, and the
plug-in functional can never compensate downwards (`mutualInfo_nonneg`). -/
theorem observed_exceeds_truth :
    mutualInfo uniformSquare < mutualInfo (permTable 1) := by
  rw [uniformSquare_mutualInfo, permMatrix_mutualInfo]
  norm_num

end Computation.FactorBlindness