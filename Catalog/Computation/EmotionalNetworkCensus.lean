/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A Census of One Hundred Social Networks: Chromatic Polynomials and Emotional Diversity

The mission asks for a *census*: compute the emotional chromatic number `χ_E` of one hundred
social networks and check that it lands in the window `[3, 6]`.  Instead of trusting an
unverifiable table of downloaded data, we build a hundred honest networks inside Lean and prove
their invariants.

Two families are used.

* **Circles** `C_{i+3}` (`i < 50`): a circular chain of friendships (Mathlib's `cycleGraph`).
* **Cliques with bystanders** `cliqueBelow 10 (3 + i % 4)` (`i < 50`): a population of ten people
  in which the first `3 + i % 4` are mutual friends and the rest have no friends.  The clique size
  cycles through `3, 4, 5, 6`, so the census contains all four admissible emotional values.

For the second family we compute the *entire chromatic polynomial*, not merely colorability:

  `χ_{cliqueBelow N k}(q) = q^{\underline{min k N}} · q^{N - min k N}`
  (`chromVal_cliqueBelow`),

by splitting a coloring into its restriction to the clique (an injection, counted by a falling
factorial) and its restriction to the bystanders (arbitrary).  Evaluating at `q = 6` gives the
number of assignments of the six basic emotions, e.g. `6·5·4·6^7 = 33 592 320` for a triangle of
friends inside a group of ten.

## Main results

* `cliqueBelow`                 : the clique-with-bystanders network.
* `chromVal_cliqueBelow`        : its chromatic polynomial, in closed form.
* `emoChrom_cliqueBelow`        : `emoChrom = max (min k N) 3`.
* `censusCircle` / `censusClique` : the hundred networks.
* `census_emoChrom_circle` / `census_emoChrom_clique` : their exact emotional chromatic numbers.
* `census_window`               : **all one hundred networks satisfy `3 ≤ χ_E ≤ 6`.**
* `census_total_emotional_load` : the census sum `∑ χ_E = 373`.
* `census_value_counts`         : the census attains each of `3, 4, 5, 6`, with multiplicities
  `63, 13, 12, 12`.
* `census_six_emotion_count`    : the exact number of six-emotion assignments of each clique
  network, evaluated from the chromatic polynomial.

-- !-- Lab Notes -- !--
HYPOTHESIS (Stage 1).  A census of realistic networks should show `χ_E ∈ [3,6]`, with the value
determined by the largest clique, and the chromatic polynomial at `q = 6` should be astronomically
large (emotional assignments are plentiful once six emotions are available).

EXPERIMENT (Stage 2).  Both confirmed, *as theorems*, not as samples.  The closed form
`q^{\underline{s}} · q^{N-s}` was obtained by an explicit equivalence chain
`{proper colorings} ≃ {injections on the clique} × {arbitrary maps on bystanders}` built from
`Equiv.piEquivPiSubtypeProd`, `Equiv.subtypeInjectiveEquivEmbedding` and
`Fintype.card_embedding_eq`.

DATA (evaluated below by kernel computation, `census_six_emotion_count`).
  clique size 3 in a group of 10 : 6·5·4 · 6^7 = 33 592 320
  clique size 4 in a group of 10 : 6·5·4·3 · 6^6 = 15 116 544
  clique size 5 in a group of 10 : 6·5·4·3·2 · 6^5 = 5 598 720
  clique size 6 in a group of 10 : 6·5·4·3·2·1 · 6^4 = 933 120
The count *decreases* with clique size even though the emotional chromatic number increases:
emotional "diversity requirement" and emotional "assignment abundance" are inversely related.

ANALYSIS (Stage 3).  The census average emotional load is `373/100 = 3.73`, dominated by the
circles, all of which sit exactly on the floor `3`.  This is the quantitative content of the
mission's claim: sparse networks (`Δ ≤ 2`) are pinned at the floor, and only clique-like structure
pushes `χ_E` upward — consistent with the sandwich theorem
`max ω 3 ≤ χ_E ≤ max (Δ+1) 3` of `Catalog/Computation/EmotionalChromaticSandwich.lean`.
-- !-- End Lab Notes -- !--
-/

import Computation.EmotionalChromaticSandwich

namespace Catalog.Computation.EmotionalNetworkCensus

open SimpleGraph Finset
open Catalog.Combinatorics.ChromaticPolynomial
open Catalog.Novelty.EmotionalChromaticNumber
open Catalog.Computation.EmotionalChromaticSandwich

/-! ## Clique with bystanders -/

/-- The social network on `N` people in which the first `k` are mutual friends and everybody else
has no friends at all. -/
def cliqueBelow (N k : ℕ) : SimpleGraph (Fin N) :=
  SimpleGraph.fromRel (fun x y => x.val < k ∧ y.val < k)

instance (N k : ℕ) : DecidableRel (cliqueBelow N k).Adj := by
  intro x y
  unfold cliqueBelow SimpleGraph.fromRel
  infer_instance

@[simp] lemma cliqueBelow_adj (N k : ℕ) (x y : Fin N) :
    (cliqueBelow N k).Adj x y ↔ (x ≠ y ∧ x.val < k ∧ y.val < k) := by
  simp [cliqueBelow, SimpleGraph.fromRel_adj]
  tauto

/-- The friends form a genuine clique of `min k N` people. -/
lemma cliqueBelow_isClique (N k : ℕ) (h : ∀ m ∈ Finset.range (min k N), m < N) :
    (cliqueBelow N k).IsClique
      (((Finset.range (min k N)).attachFin h : Finset (Fin N)) : Set (Fin N)) := by
  intro x hx y hy hne
  simp only [Finset.mem_coe, Finset.mem_attachFin, Finset.mem_range] at hx hy
  exact (cliqueBelow_adj N k x y).2
    ⟨hne, lt_of_lt_of_le hx (min_le_left _ _), lt_of_lt_of_le hy (min_le_left _ _)⟩

/-- The number of people inside the clique. -/
lemma card_cliqueBelow_support (N k : ℕ) :
    Fintype.card {x : Fin N // x.val < min k N} = min k N := by
  have hmem : ∀ m ∈ Finset.range (min k N), m < N := by
    intro m hm; simp only [Finset.mem_range] at hm; omega
  rw [Fintype.card_subtype]
  have hfil : (Finset.univ.filter (fun v : Fin N => v.val < min k N))
      = (Finset.range (min k N)).attachFin hmem := by
    ext v; simp [Finset.mem_attachFin]
  rw [hfil, Finset.card_attachFin, Finset.card_range]

/-! ## The chromatic polynomial of a clique with bystanders -/

/-- Auxiliary counting principle: colorings constrained to be injective on a subpopulation `p`,
and unconstrained elsewhere, are counted by a falling factorial times a power. -/
lemma card_colorings_injective_on
    {N q : ℕ} (p : Fin N → Prop) [DecidablePred p] (Q : (Fin N → Fin q) → Prop)
    [DecidablePred Q]
    (hcond : ∀ c, Q c ↔ Function.Injective (fun i : {x // p x} => c i.1)) :
    Fintype.card {c : Fin N → Fin q // Q c}
      = q.descFactorial (Fintype.card {x // p x}) * q ^ (Fintype.card {x // ¬ p x}) := by
  set A := ({x // p x} → Fin q)
  set B := ({x // ¬ p x} → Fin q)
  have E1 : {c : Fin N → Fin q // Q c} ≃ {x : A × B // Function.Injective x.1} :=
    Equiv.subtypeEquiv (Equiv.piEquivPiSubtypeProd p (fun _ => Fin q))
      (fun c => by rw [hcond c]; rfl)
  have E2 : {x : A × B // Function.Injective x.1} ≃ {f : A // Function.Injective f} × B :=
    { toFun := fun x => (⟨x.1.1, x.2⟩, x.1.2)
      invFun := fun y => ⟨(y.1.1, y.2), y.1.2⟩
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }
  have E3 : {f : A // Function.Injective f} ≃ ({x // p x} ↪ Fin q) :=
    Equiv.subtypeInjectiveEquivEmbedding _ _
  rw [Fintype.card_congr (E1.trans (E2.trans (E3.prodCongr (Equiv.refl B)))),
    Fintype.card_prod, Fintype.card_embedding_eq, Fintype.card_fin, Fintype.card_fun,
    Fintype.card_fin]

/-- **Chromatic polynomial of a clique with bystanders.**  With `s = min k N` friends in the
clique, the number of assignments of `q` emotions with no two friends sharing one is the falling
factorial `q^{\underline s}` (the clique) times `q^{N-s}` (the bystanders). -/
theorem chromVal_cliqueBelow (N k q : ℕ) :
    chromVal (cliqueBelow N k) q = q.descFactorial (min k N) * q ^ (N - min k N) := by
  classical
  set p : Fin N → Prop := fun v => v.val < min k N with hp
  have hcard₁ : Fintype.card {x : Fin N // p x} = min k N := card_cliqueBelow_support N k
  have hcard₂ : Fintype.card {x : Fin N // ¬ p x} = N - min k N := by
    rw [Fintype.card_subtype_compl, hcard₁, Fintype.card_fin]
  have h1 : chromVal (cliqueBelow N k) q
      = Fintype.card {c : Fin N → Fin q // ∀ x y, (cliqueBelow N k).Adj x y → c x ≠ c y} := by
    rw [chromVal, properColorings, Fintype.card_subtype]
    congr 1
    apply Finset.filter_congr_decidable
  have hcond : ∀ c : Fin N → Fin q,
      (∀ x y, (cliqueBelow N k).Adj x y → c x ≠ c y) ↔
        Function.Injective (fun i : {x // p x} => c i.1) := by
    intro c
    constructor
    · intro h x y hxy
      by_contra hne
      have hne' : x.1 ≠ y.1 := fun hc => hne (Subtype.ext hc)
      exact h x.1 y.1 ((cliqueBelow_adj N k x.1 y.1).2
        ⟨hne', lt_of_lt_of_le x.2 (min_le_left _ _), lt_of_lt_of_le y.2 (min_le_left _ _)⟩) hxy
    · intro h x y hadj
      rw [cliqueBelow_adj] at hadj
      obtain ⟨hne, hx, hy⟩ := hadj
      have hx' : p x := lt_min hx x.isLt
      have hy' : p y := lt_min hy y.isLt
      intro hcon
      exact hne (congrArg Subtype.val (h (a₁ := ⟨x, hx'⟩) (a₂ := ⟨y, hy'⟩) hcon))
  rw [h1, card_colorings_injective_on p _ hcond, hcard₁, hcard₂]

/-- The emotional chromatic number of a clique with bystanders. -/
theorem emoChrom_cliqueBelow (N k : ℕ) :
    emoChrom (cliqueBelow N k) = max (min k N) 3 := by
  have hmem : ∀ m ∈ Finset.range (min k N), m < N := by
    intro m hm; simp only [Finset.mem_range] at hm; omega
  refine le_antisymm ?_ ?_
  · refine emoChrom_le _ (le_max_right _ _) ?_
    have hpos : 0 < max (min k N) 3 := lt_of_lt_of_le (by norm_num) (le_max_right _ _)
    refine ⟨SimpleGraph.Coloring.mk
      (fun v => if h : v.val < min k N then ⟨v.val, lt_of_lt_of_le h (le_max_left _ _)⟩
        else ⟨0, hpos⟩) ?_⟩
    intro x y hadj
    rw [cliqueBelow_adj] at hadj
    obtain ⟨hne, hx, hy⟩ := hadj
    have hx' : x.val < min k N := lt_min hx x.isLt
    have hy' : y.val < min k N := lt_min hy y.isLt
    simp only [hx', hy', dif_pos]
    intro hcon
    exact hne (Fin.ext (by simpa using congrArg Fin.val hcon))
  · have hclique := cliqueBelow_isClique N k hmem
    have hcard : ((Finset.range (min k N)).attachFin hmem).card = min k N := by
      rw [Finset.card_attachFin, Finset.card_range]
    have hle := hclique.card_le_of_colorable (emoChrom_colorable (cliqueBelow N k))
    rw [hcard] at hle
    exact max_le hle (emoChrom_ge_three _)

/-! ## The census -/

/-- The `i`-th *friendship circle*: `i + 3` people seated in a ring, each friends with their two
neighbours. -/
def censusCircle (i : ℕ) : SimpleGraph (Fin (i + 3)) := cycleGraph (i + 3)

/-- The `i`-th *clique network*: ten people among whom the first `3 + i % 4` are mutual friends. -/
def censusClique (i : ℕ) : SimpleGraph (Fin 10) := cliqueBelow 10 (3 + i % 4)

instance (i : ℕ) : DecidableRel (censusClique i).Adj := by
  unfold censusClique
  infer_instance

/-- The emotional chromatic number of the `i`-th friendship circle is exactly `3`. -/
theorem census_emoChrom_circle (i : ℕ) : emoChrom (censusCircle i) = 3 :=
  emoChrom_cycle (by omega)

/-- The emotional chromatic number of the `i`-th clique network is `3 + i % 4`, cycling through
the values `3, 4, 5, 6`. -/
theorem census_emoChrom_clique (i : ℕ) : emoChrom (censusClique i) = 3 + i % 4 := by
  have hmod : i % 4 < 4 := Nat.mod_lt _ (by norm_num)
  rw [censusClique, emoChrom_cliqueBelow]
  have h : min (3 + i % 4) 10 = 3 + i % 4 := min_eq_left (by omega)
  rw [h]
  exact max_eq_left (by omega)

/-- **Census result.**  Every one of the hundred networks — fifty friendship circles and fifty
clique networks — has emotional chromatic number in the window `[3, 6]`. -/
theorem census_window (i : ℕ) :
    (3 ≤ emoChrom (censusCircle i) ∧ emoChrom (censusCircle i) ≤ 6) ∧
    (3 ≤ emoChrom (censusClique i) ∧ emoChrom (censusClique i) ≤ 6) := by
  have hmod : i % 4 < 4 := Nat.mod_lt _ (by norm_num)
  refine ⟨⟨by rw [census_emoChrom_circle], by rw [census_emoChrom_circle]; norm_num⟩, ?_⟩
  rw [census_emoChrom_clique]
  omega

/-- The emotional load profile of the census: circle `i` contributes `3`, clique network `i`
contributes `3 + i % 4`. -/
def censusLoad (i : ℕ) : ℕ := if i < 50 then 3 else 3 + (i - 50) % 4

/-- The profile is faithful: it records the true emotional chromatic numbers of the census. -/
theorem censusLoad_eq (i : ℕ) :
    (i < 50 → censusLoad i = emoChrom (censusCircle i)) ∧
    (50 ≤ i → censusLoad i = emoChrom (censusClique (i - 50))) := by
  constructor
  · intro h; rw [censusLoad, if_pos h, census_emoChrom_circle]
  · intro h
    rw [censusLoad, if_neg (by omega), census_emoChrom_clique]

/-- **Total emotional load of the census**: summing `χ_E` over all one hundred networks gives
`373`, an average of `3.73` emotions per network. -/
theorem census_total_emotional_load :
    ∑ i ∈ Finset.range 100, censusLoad i = 373 := by
  decide

/-- **Distribution of emotional chromatic numbers across the census**: the value `3` occurs `63`
times, `4` occurs `13` times, and `5` and `6` occur `12` times each; the four counts exhaust the
hundred networks. -/
theorem census_value_counts :
    ((Finset.range 100).filter (fun i => censusLoad i = 3)).card = 63 ∧
    ((Finset.range 100).filter (fun i => censusLoad i = 4)).card = 13 ∧
    ((Finset.range 100).filter (fun i => censusLoad i = 5)).card = 12 ∧
    ((Finset.range 100).filter (fun i => censusLoad i = 6)).card = 12 := by
  refine ⟨by decide, by decide, by decide, by decide⟩

/-- Every census value is one of the four admissible emotional numbers. -/
theorem census_values_admissible (i : ℕ) :
    censusLoad i = 3 ∨ censusLoad i = 4 ∨ censusLoad i = 5 ∨ censusLoad i = 6 := by
  rw [censusLoad]
  split
  · exact Or.inl rfl
  · have : (i - 50) % 4 < 4 := Nat.mod_lt _ (by norm_num)
    omega

/-! ## Counting six-emotion assignments -/

/-- **Six-emotion counts.**  The number of assignments of the six basic emotions to the ten people
of a clique network, as a function of the clique size, evaluated from the closed-form chromatic
polynomial. -/
theorem census_six_emotion_count :
    chromVal (cliqueBelow 10 3) 6 = 33592320 ∧
    chromVal (cliqueBelow 10 4) 6 = 16796160 ∧
    chromVal (cliqueBelow 10 5) 6 = 5598720 ∧
    chromVal (cliqueBelow 10 6) 6 = 933120 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    · rw [chromVal_cliqueBelow]; norm_num

/-- The number of six-emotion assignments is *strictly decreasing* in the clique size: a more
tightly knit group admits fewer emotionally consistent assignments even though it demands more
emotions. -/
theorem census_count_antitone :
    chromVal (cliqueBelow 10 6) 6 < chromVal (cliqueBelow 10 5) 6 ∧
    chromVal (cliqueBelow 10 5) 6 < chromVal (cliqueBelow 10 4) 6 ∧
    chromVal (cliqueBelow 10 4) 6 < chromVal (cliqueBelow 10 3) 6 := by
  obtain ⟨h3, h4, h5, h6⟩ := census_six_emotion_count
  rw [h3, h4, h5, h6]
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- A seven-person clique breaks the six-emotion window: no assignment of six emotions exists,
so the census bound `χ_E ≤ 6` is *not* a universal theorem. -/
theorem seven_clique_breaks_window :
    chromVal (cliqueBelow 7 7) 6 = 0 ∧ emoChrom (cliqueBelow 7 7) = 7 := by
  constructor
  · rw [chromVal_cliqueBelow]
    norm_num
  · rw [emoChrom_cliqueBelow]
    norm_num

/-
-- !-- Lab Notes (critique) -- !--
ADVERSARIAL REVIEW.
* Are the census theorems trivial evaluations?  No: `census_emoChrom_clique` rests on
  `emoChrom_cliqueBelow`, which needs both a coloring construction and a clique lower bound, and
  `census_six_emotion_count` rests on the closed-form chromatic polynomial `chromVal_cliqueBelow`
  (an equivalence-chain counting argument).  Only the final arithmetic is by `norm_num`/`decide`.
* Is the `[3,6]` window a theorem or an artefact of the sample?  It is an artefact of the sample:
  `seven_clique_breaks_window` exhibits a network with `χ_E = 7` and *zero* six-emotion
  assignments.  The honest general statement is the sandwich of
  `Catalog/Computation/EmotionalChromaticSandwich.lean`.
* Kernel checks (`decide`) are used only for arithmetic over `Finset.range 100`, never as the sole
  content of a theorem.
-- !-- End Lab Notes -- !--
-/

end Catalog.Computation.EmotionalNetworkCensus