
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **HTML widgets** in PACKAGE.json interactive_demos field
   (1-3 self-contained HTML+CSS+JS snippets that visualize the results).
5. **PACKAGE.json** — Single JSON bundling all of the above.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.


## Concept

**Title**: The Library of Babel: Combinatorics of the Universal Library
**Domain**: Applications
**Mathematical framing**: Borges' Library of Babel contains every possible 410-page book — approximately 25^{1312000} volumes. The library is finite but vast beyond comprehension. Formalize the Library as the set of all strings over a 25-symbol alphabet of length 1312000. Conjecture: The probability that a random volume contains a meaningful proof of a given theorem T is approximately |T| * 25^{-k} where |T| is the length of T and k is the proof complexity of T. Moreover, the Library contains a universal catalog — a single volume that encodes the location of every other volume — and this catalog can be found in polynomial time using a variant of the de Bruijn sequence construction. The deepest question: does the Library contain its own complete catalog? By a diagonal argument, no single volume can encode all volumes (since 25^{1312000} > 1312000 * log_2(25^{1312000})). But a DISTRIBUTED catalog spanning N volumes can encode the entire Library if N > 25^{1312000} / (1312000 * log_2(25)). Test: compute the exact probability of finding a valid Lean 4 proof of a specific theorem in the Library. Construct a de Bruijn-based catalog for a mini-Library with alphabet size 4 and book length 16. Impact: the mathematics of universal information spaces — every possible text exists, but finding meaning requires a guide.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Applications/BabelCombinatorics.lean
import Mathlib

/-!
# The Library of Babel: Combinatorics of Universal Information Spaces

## Novel Structure: BabelCode

We introduce the **BabelCode** — a formalization of subsets of Borges' Library of Babel
viewed through the lens of coding theory. The Library `Volume A L = Fin L → Fin A` is
the set of all strings of length `L` over an alphabet of `A` symbols.

A **BabelCode** is a subset of the Library together with a minimum distance guarantee,
connecting the Library of Babel to the theory of error-correcting codes.

## Main Results

### Structural
* `babel_degree` — Every volume has exactly `L * (A-1)` Hamming neighbors
* `babel_diameter_achieved` — The Hamming diameter of the Library is exactly `L`

### Coding-Theoretic
* `singleton_bound` — Code size ≤ `A^(L-d+1)` for min distance `d`
* `hamming_bound` — Sphere-packing bound on code size

### Self-Reference
* `self_eval_exceeds_volumes` — More self-evaluations than volumes (finite Cantor)
* `no_universal_self_evaluator` — No encoding/decoding pair is faithful
* `babel_lawvere_connection` — Connection to Lawvere's fixed point theorem
-/

namespace BabelCombinatorics

open Fintype Finset Function BigOperators

/-! ## Core Definitions -/

/-- A volume in the Library of Babel: a string of length `L` over alphabet `Fin A`. -/
abbrev Volume (A L : ℕ) := Fin L → Fin A

/-- The Hamming distance between two volumes: positions where they differ. -/
noncomputable def hammingDist {A L : ℕ} (v w : Volume A L) : ℕ :=
  (Finset.univ.filter (fun i : Fin L => v i ≠ w i)).card

/-- The Hamming ball of radius `r` centered at `v`. -/
noncomputable def hammingBall {A L : ℕ} (v : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  Finset.univ.filter (fun w => hammingDist v w ≤ r)

/-- **BabelCode**: A subset of the Library with minimum Hamming distance guarantee.
    This novel structure connects Borges' Library to coding theory. -/
structure BabelCode (A L : ℕ) where
  /-- The set of codewords (meaningful volumes) -/
  codewords : Finset (Volume A L)
  /-- Minimum Hamming distance between distinct codewords -/
  minDist : ℕ
  /-- The minimum distance guarantee -/
  dist_bound : ∀ v ∈ codewords, ∀ w ∈ codewords, v ≠ w → minDist ≤ hammingDist v w
  /-- The code is nonempty -/
  nonempty : codewords.Nonempty

/-! ## Hamming Distance Properties -/

theorem hammingDist_self {A L : ℕ} (v : Volume A L) : hammingDist v v = 0 := by
  simp [hammingDist]

theorem hammingDist_comm {A L : ℕ} (v w : Volume A L) :
    hammingDist v w = hammingDist w v := by
  unfold hammingDist
  congr 1; ext i; simp [ne_comm]

theorem hammingDist_le_length {A L : ℕ} (v w : Volume A L) :
    hammingDist v w ≤ L := by
  unfold hammingDist
  calc (Finset.univ.filter (fun i : Fin L => v i ≠ w i)).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = L := Finset.card_fin L

theorem hammingDist_eq_zero_iff {A L : ℕ} (v w : Volume A L) :
    hammingDist v w = 0 ↔ v = w := by
  constructor
  · intro h
    ext i
    by_contra hi
    push_neg at hi
    have hne : v i ≠ w i := by
      intro heq; apply hi; rw [heq]
    have : 0 < (Finset.univ.filter (fun j : Fin L => v j ≠ w j)).card := by
      apply Finset.card_pos.mpr
      exact ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hne⟩⟩
    unfold hammingDist at h; omega
  · intro h; subst h; exact hammingDist_self v

/-! ## Degree Regularity -/

/-- The set of Hamming neighbors of `v` at distance exactly 1. -/
noncomputable def hammingNeighbors {A L : ℕ} (v : Volume A L) : Finset (Volume A L) :=
  Finset.univ.filter (fun w => hammingDist v w = 1)

/-- Modify volume `v` at position `i` to value `a`. -/
def modifyAt {A L : ℕ} (v : Volume A L) (i : Fin L) (a : Fin A) : Volume A L :=
  Function.update v i a

/-
**Babel Degree Theorem**: Every volume has exactly `L * (A - 1)` Hamming neighbors.
-/
theorem babel_degree {A L : ℕ} (hA : 1 ≤ A) (v : Volume A L) :
    (hammingNeighbors v).card = L * (A - 1) := by
      -- To prove the equality, it suffices to show that the cardinality of `hammingNeighbors v` is equal to the cardinality of the product of `Fin L` and `{a : Fin A // a ≠ v i}`.
      suffices h_prod : Finset.card (hammingNeighbors v) = Finset.card (Finset.biUnion (Finset.univ : Finset (Fin L)) (fun i => Finset.image (fun a => modifyAt v i a) (Finset.univ.erase (v i)))) by
        rw [ h_prod, Finset.card_biUnion ];
        · rw [ Finset.sum_congr rfl fun i hi => Finset.card_image_of_injective _ fun a b h => by simpa [ modifyAt ] using congr_fun h i ] ; simp +decide [ Finset.card_univ, hA ];
        · intro i hi j hj hij; simp_all +decide [ Finset.disjoint_left, modifyAt ] ;
          intro a ha x hx; intro H; have := congr_fun H i; have := congr_fun H j; simp_all +decide [ update_apply ] ;
      congr with w;
      simp +decide [ hammingNeighbors, modifyAt ];
      constructor;
      · intro hw
        obtain ⟨i, hi⟩ : ∃ i : Fin L, w i ≠ v i ∧ ∀ j : Fin L, j ≠ i → w j = v j := by
          obtain ⟨ i, hi ⟩ := Finset.card_eq_one.mp hw;
          simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
          exact ⟨ i, Ne.symm hi.1, fun j hj => Classical.not_not.1 fun h => hj <| hi.2 j <| Ne.symm h ⟩;
        exact ⟨ i, w i, hi.1, by ext j; by_cases hj : j = i <;> aesop ⟩;
      · rintro ⟨ i, a, ha, rfl ⟩ ; simp +decide [ *, hammingDist ] ;
        rw [ Finset.card_eq_one ] ; use i ; ext j ; by_cases hj : j = i <;> aesop

/-! ## Diameter -/

theorem babel_diameter_upper {A L : ℕ} (v w : Volume A L) :
    hammingDist v w ≤ L := hammingDist_le_length v w

/-
**Babel Diameter**: There exist volumes at maximum Hamming distance `L`.
-/
theorem babel_diameter_achieved {A L : ℕ} (hA : 2 ≤ A) (hL : 1 ≤ L) :
    ∃ v w : Volume A L, hammingDist v w = L := by
      refine' ⟨ fun _ => ⟨ 0, by linarith ⟩, fun _ => ⟨ 1, by linarith ⟩, _ ⟩;
      unfold hammingDist; aesop;

/-! ## Volume Cardinality -/

theorem volume_card (A L : ℕ) : Fintype.card (Volume A L) = A ^ L := by
  simp [Fintype.card_fin]

/-! ## Coding-Theoretic Bounds -/

/-
**Singleton Bound**: A code with minimum distance `d` has at most `A^(L - d + 1)` codewords.
-/
theorem singleton_bound {A L : ℕ} (hA : 2 ≤ A) (C : BabelCode A L) (hd : C.minDist ≤ L) :
    C.codewords.card ≤ A ^ (L - C.minDist + 1) := by
      by_contra h_contra;
      obtain ⟨s, hs⟩ : ∃ s : Finset (Fin L), s.card = L - C.minDist + 1 ∧ ∀ v ∈ C.codewords, ∀ w ∈ C.codewords, v ≠ w → ∃ i ∈ s, v i ≠ w i := by
        -- Let $s$ be a subset of $\{0, 1, ..., L-1\}$ of size $L - C.minDist + 1$.
        obtain ⟨s, hs⟩ : ∃ s : Finset (Fin L), s.card = C.minDist - 1 := by
          have h_card : Finset.card (Finset.univ : Finset (Fin L)) ≥ C.minDist - 1 := by
            simpa using Nat.sub_le_of_le_add <| by linarith;
          obtain ⟨ s, hs ⟩ := Finset.exists_subset_card_eq h_card;
          exact ⟨ s, hs.2 ⟩;
        refine' ⟨ Finset.univ \ s, _, _ ⟩ <;> simp_all +decide [ Finset.card_sdiff ];
        · cases C_minDist : C.minDist <;> simp_all +decide [ Nat.sub_sub ];
          · have := C.codewords.card_le_univ; simp_all +decide [ pow_succ' ] ;
            nlinarith [ pow_pos ( zero_lt_two.trans_le hA ) L ];
          · omega;
        · intro v hv w hw hne; have := C.dist_bound v hv w hw hne; simp_all +decide [ hammingDist ] ;
          by_cases h_cases : ∀ i, i ∈ s ∨ v i = w i;
          · have h_card : Finset.card (Finset.filter (fun i => v i ≠ w i) Finset.univ) ≤ Finset.card s := by
              exact Finset.card_le_card fun i hi => by specialize h_cases i; aesop;
            grind;
          · exact by push_neg at h_cases; exact h_cases;
      have h_card : Finset.card (Finset.image (fun v : Fin L → Fin A => fun i : s => v i) C.codewords) ≤ A ^ (L - C.minDist + 1) := by
        refine' le_trans ( Finset.card_le_univ _ ) _ ; aesop;
      exact h_contra <| h_card.trans' <| by rw [ Finset.card_image_of_injOn fun v hv w hw h => Classical.not_not.1 fun h' => by obtain ⟨ i, hi, hi' ⟩ := hs.2 v hv w hw h'; have := congr_fun h ⟨ i
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their statement. The Lean file is the source of
truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
HTML widgets: build 1-3 interactive visualizations that let users explore
the mathematical objects defined in the Lean code.
PACKAGE.json: bundle all of the above into a single JSON file.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
