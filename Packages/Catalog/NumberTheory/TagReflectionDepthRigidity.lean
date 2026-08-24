import NumberTheory.TagFrameSemantics

/-!
# Per-tag reflection depths are *not* freely realizable by tag-truncated models

The conjecture under test.  Let `N : ℕ` and let `d, r : ℕ → ℕ` be a height vector and a
reflection-depth vector with `r i ≤ min N (d i)` for every tag `i`.  Is there a
consistent GL theory `S` — *the common refinement of `capC` and `valSys`*, i.e. the
theory of the tag-truncated frame `satC c` equipped with an arbitrary valuation `V` —
such that for every tag `i`

* `Provable S (□_i^k ⊥) ↔ min N (d i) < k`, and
* `DepthReflection r' i S ↔ r' ≤ r i`?

The conjectured mechanism was that the reflection depth measures the distance from the
top of the model to the point where the *valuation* stops being constant, while the
inconsistency depth measures the distance from the top to the point where the *tag's
accessibility* stops.

**The answer is no, and the reason is structural.**  This file first constructs the
common refinement `satCV c V = satF (capRel c) V` and computes its inconsistency
spectrum (`provable_cvSys_boxPow_bot_iff` — as expected, `min N (c i) < k`, independent
of the valuation).  Then it proves the obstruction:

* `provable_cvSys_box_iff` — in the refinement, `□_i a` is provable iff `a` holds at all
  worlds `n < min N (c i)`.  The *only* datum of the tag that enters is its truncated
  height;
* `cvSys_depthReflection_congr_of_min_eq` (**rigidity**) — two tags with the same
  truncated height satisfy *literally the same* depth-restricted reflection rules,
  whatever the valuation.  So the reflection-depth vector is a function of the height
  vector, not an independent parameter;
* `cvSys_depthReflection_mono` (**monotonicity**) — and that function is monotone.

Consequently the conjecture is false: `reflection_depth_conjecture_false` exhibits a
pair `(d, r)` with `r i ≤ min N (d i)` that no theory in the class realizes.  The
falsifying "second inequality between the two vectors" predicted by the mission
statement is in fact an *equality* between reflection depths at equal heights.

The failure is, however, an artefact of the *shape* of the accessibility relations in
`capC`, not of GL: §6 introduces **window frames** `winRel b H` (tag `i` sees `n < m`
iff `m ≤ H i` and `b i ≤ n`), which are transitive and hence GL, and builds the
parametric family `famSys h` of theories on the worlds `0, …, h + 1` in which the tags
`0` and `1` have **equal** inconsistency heights `h` but reflection depths `1` and `0`
(`famSys_depthReflection_iff`, `glRealizes_fam`).  So the very pair `(d, r)` that the
refinement cannot realize *is* realized by a consistent GL theory
(`glRealizes_exD_exR`), and the conjecture is repaired by enlarging the class:
the second cut point must be made per-tag, and a global valuation cannot do that.

§7 isolates the abstract mechanism.  The reflection rules of a tag depend on the tag
only through the **image** of its accessibility relation, and they are monotone under
inclusion of images (`depthReflection_frameSys_of_image_subset`); consequently two tags
of different reflection depth must have *incomparable* images
(`frameImage_not_subset_of_depthReflection_ne`).  The refinement produces only the
initial segments `[0, min N (c i))` (`frameImage_capRel_iff`), which are totally
ordered — hence the rigidity — while window frames produce intervals
`[b i, min N (H i))` (`frameImage_winRel_iff`), and those of `famSys h` are indeed
incomparable (`famSys_images_incomparable`).

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): heights and reflection depths are independent coordinates of the
  refinement `capC ⊓ valSys`, freely realizable subject to `r i ≤ min N (d i)`.
Experiment (Stage 2): exhaustive machine search over all truncation vectors `c` and all
  valuations on models with `≤ 4` worlds and two live tags (see
  `ComputationalEvidence.md`): of the `36` conjecturally realizable pairs at `N = 2`
  only `22` occur, and every missing one has two tags of equal height and different
  depth — or violates monotonicity.
Analysis (Stage 3): the reason is visible in `provable_cvSys_box_iff`: the *image* of
  the accessibility relation of tag `i` in `capC` is the initial segment
  `[0, min N (c i))`, so tags of equal height are literally interchangeable.  The
  conjecture is "true but for the wrong class"; the second cut point has to be a
  property of the tag, not of the valuation.
Experiment (Stage 2', general frames): the same search over arbitrary transitive
  tag-indexed frames finds *all* `36` pairs; the smallest decoupling witness has four
  worlds and is generalised here to the parametric family `famSys h`.
Critique (Stage 4): `famSys h` is verified end to end — its two live tags have exactly
  equal inconsistency spectra (`famSys_provable_boxPow_bot_live`), and both reflection
  depths are computed exactly (`famSys_depthReflection_iff`), the positive halves
  through the bounded-bisimulation lemma of `NumberTheory.TagFrameSemantics` and the
  negative halves through explicit separating formulas of the correct box depth.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open ReflectionSpectrum
open Form

/-! ## §1. The common refinement of `capC` and `valSys` -/

/-- The tag-truncated accessibility relation of `capC`, as a tag-indexed frame: tag `i`
sees the worlds below `m` exactly while `m ≤ c i`. -/
def capRel (c : ℕ → ℕ) : ℕ → ℕ → ℕ → Bool := fun i m _ => decide (m ≤ c i)

/-- **The common refinement**: the tag-sensitive semantics `satC c` with the atoms
interpreted by an arbitrary valuation `V`. -/
def satCV (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) : ℕ → Form → Bool := satF (capRel c) V

/-- The refinement of `capC c N` and `valSys V N`: the theory of all formulas true at
the worlds `0, …, N` of the tag-truncated model with valuation `V`. -/
def cvSys (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N : ℕ) : ProofSys Form :=
  frameSys (capRel c) V N

theorem frameTrans_capRel (c : ℕ → ℕ) (i : ℕ) : FrameTrans (capRel c) i := by
  intro m n k _ _ hmn _
  simpa [capRel] using hmn

theorem provable_cvSys (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N : ℕ) (a : Form) :
    Provable (cvSys c V N) a ↔ ∀ m ≤ N, satCV c V m a = true :=
  provable_frameSys N a

theorem consistent_cvSys (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N : ℕ) :
    Consistent (cvSys c V N) :=
  consistent_frameSys N

theorem isGL_cvSys (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N i : ℕ) :
    IsGLTheory i (cvSys c V N) :=
  isGL_frameSys N i (frameTrans_capRel c i)

theorem satCV_imp (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (m : ℕ) (a b : Form) :
    satCV c V m (imp a b) = true ↔ (satCV c V m a = true → satCV c V m b = true) :=
  satF_imp m a b

/-- Satisfaction of a box in the refinement: below the tag's height it quantifies over
the strictly smaller worlds, above the height it is vacuously true. -/
theorem satCV_box (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (m i : ℕ) (a : Form) :
    satCV c V m (box i a) = true ↔ (m ≤ c i → ∀ n, n < m → satCV c V n a = true) := by
  rw [satCV, satF_box]
  constructor
  · intro h hle n hn
    exact h n hn (by simpa [capRel] using hle)
  · intro h n hn hR
    exact h (by simpa [capRel] using hR) n hn

/-- With every atom true, the refinement is the catalog's tag-sensitive semantics
`satC`. -/
theorem satCV_true_eq_satC (c : ℕ → ℕ) :
    ∀ (a : Form) (m : ℕ), satCV c (fun _ _ => true) m a = satC c m a := by
  intro a
  induction a with
  | bot => intro m; rfl
  | atom p => intro m; rfl
  | imp a b iha ihb =>
      intro m
      simp only [satCV] at iha ihb ⊢
      simp only [satF, satC, iha m, ihb m]
  | box i a ih =>
      intro m
      rw [Bool.eq_iff_iff, satCV_box, satC_box]
      constructor
      · intro h hle n hn; rw [← ih n]; exact h hle n hn
      · intro h hle n hn; rw [ih n]; exact h hle n hn

/-- With all truncation heights above the horizon, the refinement is the catalog's
valuated semantics `satV`. -/
theorem satCV_eq_satV_of_le {c : ℕ → ℕ} {N : ℕ} (V : ℕ → ℕ → Bool) (hc : ∀ i, N ≤ c i) :
    ∀ (a : Form) (m : ℕ), m ≤ N → satCV c V m a = satV V m a := by
  intro a
  induction a with
  | bot => intro m _; rfl
  | atom p => intro m _; rfl
  | imp a b iha ihb =>
      intro m hm
      simp only [satCV] at iha ihb ⊢
      simp only [satF, satV, iha m hm, ihb m hm]
  | box i a ih =>
      intro m hm
      rw [Bool.eq_iff_iff, satCV_box, satV_box]
      constructor
      · intro h n hn
        rw [← ih n (by omega)]
        exact h (le_trans hm (hc i)) n hn
      · intro h _ n hn
        rw [ih n (by omega)]
        exact h n hn

/-! ## §2. The inconsistency spectrum and the provable boxes -/

/-- The iterated boxed falsum in the refinement: as in `capC`, the valuation is
invisible to it, and it is true exactly below the iteration count or above the tag's
height. -/
theorem satCV_boxPow_bot (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (i : ℕ) :
    ∀ (k m : ℕ), satCV c V m (boxPow i k bot) = true ↔ (1 ≤ k ∧ (m < k ∨ c i < m)) := by
  intro k
  induction k with
  | zero => intro m; simp [boxPow, satCV]
  | succ k ih =>
      intro m
      rw [boxPow, satCV_box]
      by_cases hle : m ≤ c i
      · constructor
        · intro h
          refine ⟨by omega, ?_⟩
          left
          by_contra hm
          have hk : k < m := by omega
          have := (ih k).1 (h hle k hk)
          omega
        · rintro ⟨-, hm⟩ - n hn
          rw [ih n]
          omega
      · exact ⟨fun _ => ⟨by omega, by omega⟩, fun _ hle' => absurd hle' hle⟩

/-- **The inconsistency spectrum of the refinement.**  Exactly as for `capC`, the
theory proves `□_i^k ⊥` iff `k` exceeds the truncated height `min N (c i)`; the
valuation contributes nothing. -/
theorem provable_cvSys_boxPow_bot_iff (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N i k : ℕ) :
    Provable (cvSys c V N) (boxPow i k bot) ↔ min N (c i) < k := by
  rw [provable_cvSys]
  constructor
  · intro h
    have h0 := (satCV_boxPow_bot c V i k 0).1 (h 0 (Nat.zero_le N))
    have hm := (satCV_boxPow_bot c V i k (min N (c i))).1 (h (min N (c i)) (by omega))
    omega
  · intro hlt m hm
    rw [satCV_boxPow_bot]
    omega

/-- **What a provable box knows about a tag.**  In the refinement, `□_i a` is provable
exactly when `a` holds at every world below the truncated height of the tag: the image
of the accessibility relation of tag `i` is the initial segment `[0, min N (c i))`. -/
theorem provable_cvSys_box_iff (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N i : ℕ) (a : Form) :
    Provable (cvSys c V N) (box i a) ↔ ∀ n, n < min N (c i) → satCV c V n a = true := by
  rw [provable_cvSys]
  constructor
  · intro h n hn
    have := (satCV_box c V (min N (c i)) i a).1 (h (min N (c i)) (by omega)) (by omega)
    exact this n hn
  · intro h m hm
    rw [satCV_box]
    intro hle n hn
    exact h n (by omega)

/-- **The image of a tag in the refinement** is the initial segment `[0, min N (c i))`:
the truncated height is the *only* datum of the tag that the frame retains. -/
theorem frameImage_capRel_iff (c : ℕ → ℕ) (N i n : ℕ) :
    FrameImage (capRel c) N i n ↔ n < min N (c i) := by
  constructor
  · rintro ⟨m, hm, hnm, hR⟩
    simp only [capRel, decide_eq_true_eq] at hR
    omega
  · intro h
    exact ⟨n + 1, by omega, by omega, by simp only [capRel, decide_eq_true_eq]; omega⟩

/-! ## §3. Rigidity: the reflection depth is a function of the height -/

/-- Depth-restricted reflection only depends on the provability predicate. -/
theorem depthReflection_congr {S S' : ProofSys Form} (h : ∀ a, Provable S a ↔ Provable S' a)
    (d i : ℕ) : DepthReflection d i S ↔ DepthReflection d i S' := by
  constructor <;> intro hd a ha hbox
  · exact (h a).1 (hd a ha ((h (box i a)).2 hbox))
  · exact (h a).2 (hd a ha ((h (box i a)).1 hbox))

/-- **Monotonicity of the reflection rules in the truncated height.**  A tag of larger
truncated height satisfies all the depth-restricted reflection rules of a tag of
smaller truncated height: the hypothesis `⊢ □_i a` of the rule becomes stronger as the
tag sees more worlds. -/
theorem cvSys_depthReflection_mono {c : ℕ → ℕ} {V : ℕ → ℕ → Bool} {N i j : ℕ}
    (hij : min N (c i) ≤ min N (c j)) (d : ℕ) (h : DepthReflection d i (cvSys c V N)) :
    DepthReflection d j (cvSys c V N) := by
  refine depthReflection_frameSys_of_image_subset (R := capRel c) (V := V) ?_ h
  intro n hn
  rw [frameImage_capRel_iff] at hn ⊢
  omega

/-- **Rigidity.**  In the common refinement of `capC` and `valSys`, two tags with the
same truncated height satisfy exactly the same depth-restricted reflection rules — for
*every* valuation.  The reflection depth is therefore not an independent parameter but
a function of the truncated height. -/
theorem cvSys_depthReflection_congr_of_min_eq {c : ℕ → ℕ} {V : ℕ → ℕ → Bool} {N i j : ℕ}
    (hij : min N (c i) = min N (c j)) (d : ℕ) :
    DepthReflection d i (cvSys c V N) ↔ DepthReflection d j (cvSys c V N) :=
  ⟨cvSys_depthReflection_mono (le_of_eq hij) d,
    cvSys_depthReflection_mono (le_of_eq hij.symm) d⟩

/-! ## §3'. The height-gap inequality: a second constraint between the two vectors -/

/-- The box depth of an iterated box is the iteration count plus the depth of the
body. -/
theorem boxDepth_boxPow (i s : ℕ) (a : Form) : boxDepth (boxPow i s a) = s + boxDepth a := by
  induction s with
  | zero => simp [boxPow]
  | succ s ih => rw [boxPow, boxDepth_box, ih]; omega

/-- The **gap probe** of the pair of tags `(i, j)` at distance `s`: the formula
`□_i^s (□_j ⊥ → □_i ⊥)`, of box depth `s + 1`. -/
def gapProbe (i j s : ℕ) : Form := boxPow i s (imp (box j bot) (box i bot))

@[simp] theorem boxDepth_gapProbe (i j s : ℕ) : boxDepth (gapProbe i j s) = s + 1 := by
  rw [gapProbe, boxDepth_boxPow]
  simp [boxDepth]

/-- **The truth table of the gap probe.**  In the refinement, `□_i^s (□_j ⊥ → □_i ⊥)` is
true at the world `m` exactly when `m` is above the height of `i` — where all of its
boxes are vacuous — or within `s` steps of the height of `j`.  So the probe separates
the worlds `≤ c j + s` from the world `c j + s + 1` using only box depth `s + 1`. -/
theorem satCV_gapProbe (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (i j : ℕ) :
    ∀ (s m : ℕ), satCV c V m (gapProbe i j s) = true ↔ (c i < m ∨ m ≤ c j + s) := by
  intro s
  induction s with
  | zero =>
      intro m
      rw [gapProbe, boxPow, satCV_imp]
      have hj : satCV c V m (box j bot) = true ↔ (m = 0 ∨ c j < m) := by
        rw [satCV_box]
        constructor
        · intro h
          by_cases hle : m ≤ c j
          · left
            by_contra hm
            have := h hle 0 (by omega)
            simp [satCV, satF] at this
          · right; omega
        · rintro (rfl | hlt) hle n hn
          · omega
          · omega
      have hi : satCV c V m (box i bot) = true ↔ (m = 0 ∨ c i < m) := by
        rw [satCV_box]
        constructor
        · intro h
          by_cases hle : m ≤ c i
          · left
            by_contra hm
            have := h hle 0 (by omega)
            simp [satCV, satF] at this
          · right; omega
        · rintro (rfl | hlt) hle n hn
          · omega
          · omega
      rw [hj, hi]
      omega
  | succ s ih =>
      intro m
      rw [gapProbe, boxPow, satCV_box]
      constructor
      · intro h
        by_cases hle : m ≤ c i
        · right
          by_contra hm
          have hn : c j + s < m := by omega
          have := (ih (c j + s + 1)).1 (h hle (c j + s + 1) (by omega))
          omega
        · left; omega
      · intro h hle n hn
        rw [show boxPow i s (imp (box j bot) (box i bot)) = gapProbe i j s from rfl, ih n]
        omega

/-- **The height-gap inequality.**  In the common refinement, a tag `i` whose truncated
height strictly exceeds the truncated height of some other tag `j` cannot reflect
deeper than the gap `min N (c i) - min N (c j)`: the gap probe
`□_i^{gap-1}(□_j ⊥ → □_i ⊥)` has box depth exactly the gap, is provably provable, and is
not provable.  Together with rigidity this pins the reflection-depth vector between the
tags. -/
theorem cvSys_not_depthReflection_gap {c : ℕ → ℕ} {V : ℕ → ℕ → Bool} {N i j : ℕ}
    (hji : min N (c j) < min N (c i)) :
    ¬ DepthReflection (min N (c i) - min N (c j) + 1) i (cvSys c V N) := by
  intro h
  set hi := min N (c i) with hidef
  set hj := min N (c j) with hjdef
  have hcj : c j = hj := by omega
  have hci : hi ≤ c i := by omega
  have hiN : hi ≤ N := by omega
  have hprov : Provable (cvSys c V N) (box i (gapProbe i j (hi - hj - 1))) := by
    rw [provable_cvSys_box_iff]
    intro n hn
    rw [satCV_gapProbe]
    omega
  have hrefl := h (gapProbe i j (hi - hj - 1)) (by rw [boxDepth_gapProbe]; omega) hprov
  rw [provable_cvSys] at hrefl
  have := (satCV_gapProbe c V i j (hi - hj - 1) hi).1 (hrefl hi hiN)
  omega

/-- **The low tag collapses.**  Dually to the gap inequality: a tag `j` that is
strictly *below* some other tag `i` cannot reflect beyond depth `1` at all.  The
witness is the gap probe at distance `0`, i.e. the box-depth-`1` formula
`□_j ⊥ → □_i ⊥`, which holds at every world seen by `j` and fails at the world
`min N (c j) + 1`. -/
theorem cvSys_not_depthReflection_two_of_lt {c : ℕ → ℕ} {V : ℕ → ℕ → Bool} {N i j : ℕ}
    (hji : min N (c j) < min N (c i)) : ¬ DepthReflection 2 j (cvSys c V N) := by
  intro h
  set hi := min N (c i) with hidef
  set hj := min N (c j) with hjdef
  have hcj : c j = hj := by omega
  have hci : hi ≤ c i := by omega
  have hprov : Provable (cvSys c V N) (box j (gapProbe i j 0)) := by
    rw [provable_cvSys_box_iff]
    intro n hn
    rw [satCV_gapProbe]
    omega
  have hrefl := h (gapProbe i j 0) (by rw [boxDepth_gapProbe]; omega) hprov
  rw [provable_cvSys] at hrefl
  have := (satCV_gapProbe c V i j 0 (hj + 1)).1 (hrefl (hj + 1) (by omega))
  omega

/-! ## §4. The conjecture, and its refutation for the refinement -/

/-- The conjecture's realizability predicate for the class considered in it: the
common refinement of `capC` and `valSys`. -/
def ClassRealizes (N : ℕ) (d r : ℕ → ℕ) : Prop :=
  ∃ (c : ℕ → ℕ) (V : ℕ → ℕ → Bool),
    (∀ i k, Provable (cvSys c V N) (boxPow i k bot) ↔ min N (d i) < k) ∧
    (∀ i r', DepthReflection r' i (cvSys c V N) ↔ r' ≤ r i)

/-- The same realizability predicate for *arbitrary* consistent GL theories. -/
def GLRealizes (N : ℕ) (d r : ℕ → ℕ) : Prop :=
  ∃ S : ProofSys.{0, 0} Form, Consistent S ∧ (∀ i, IsGLTheory i S) ∧
    (∀ i k, Provable S (boxPow i k bot) ↔ min N (d i) < k) ∧
    (∀ i r', DepthReflection r' i S ↔ r' ≤ r i)

/-- **The obstruction.**  If the refinement realizes the pair `(d, r)`, then `r` is
constant on the level sets of `i ↦ min N (d i)`: equal heights force equal reflection
depths. -/
theorem classRealizes_levelwise_constant {N : ℕ} {d r : ℕ → ℕ} (h : ClassRealizes N d r)
    {i j : ℕ} (hij : min N (d i) = min N (d j)) : r i = r j := by
  obtain ⟨c, V, hheight, hdepth⟩ := h
  have hc : ∀ i, min N (c i) = min N (d i) := by
    intro i
    have h1 := hheight i (min N (c i) + 1)
    have h2 := hheight i (min N (d i) + 1)
    rw [provable_cvSys_boxPow_bot_iff] at h1 h2
    omega
  have hcij : min N (c i) = min N (c j) := by rw [hc i, hc j, hij]
  have hi : DepthReflection (r i) i (cvSys c V N) := (hdepth i (r i)).2 le_rfl
  have hj : DepthReflection (r j) j (cvSys c V N) := (hdepth j (r j)).2 le_rfl
  have h1 : r i ≤ r j :=
    (hdepth j (r i)).1 ((cvSys_depthReflection_congr_of_min_eq hcij (r i)).1 hi)
  have h2 : r j ≤ r i :=
    (hdepth i (r j)).1 ((cvSys_depthReflection_congr_of_min_eq hcij.symm (r j)).1 hj)
  omega

/-- **The height-gap inequality, in terms of the two vectors.**  If the refinement
realizes the pair `(d, r)` and some tag `j` is strictly lower than the tag `i`, then the
reflection depth of `i` is at most the height gap.  This is the "second inequality"
between the two vectors that the conjecture did not anticipate: besides
`r i ≤ min N (d i)`, the whole height vector constrains each single reflection
depth. -/
theorem classRealizes_gap_bound {N : ℕ} {d r : ℕ → ℕ} (h : ClassRealizes N d r) {i j : ℕ}
    (hji : min N (d j) < min N (d i)) : r i ≤ min N (d i) - min N (d j) := by
  obtain ⟨c, V, hheight, hdepth⟩ := h
  have hc : ∀ i, min N (c i) = min N (d i) := by
    intro i
    have h1 := hheight i (min N (c i) + 1)
    have h2 := hheight i (min N (d i) + 1)
    rw [provable_cvSys_boxPow_bot_iff] at h1 h2
    omega
  by_contra hr
  have hlt : min N (c j) < min N (c i) := by rw [hc i, hc j]; exact hji
  refine cvSys_not_depthReflection_gap (V := V) hlt ?_
  refine depthReflection_mono ?_ ((hdepth i (r i)).2 le_rfl)
  rw [hc i, hc j]
  omega

/-- **Only the highest tags can reflect deeply.**  If the refinement realizes `(d, r)`
and some tag is strictly higher than `j`, then `r j ≤ 1`. -/
theorem classRealizes_low_tag_le_one {N : ℕ} {d r : ℕ → ℕ} (h : ClassRealizes N d r)
    {i j : ℕ} (hji : min N (d j) < min N (d i)) : r j ≤ 1 := by
  obtain ⟨c, V, hheight, hdepth⟩ := h
  have hc : ∀ i, min N (c i) = min N (d i) := by
    intro i
    have h1 := hheight i (min N (c i) + 1)
    have h2 := hheight i (min N (d i) + 1)
    rw [provable_cvSys_boxPow_bot_iff] at h1 h2
    omega
  by_contra hr
  have hlt : min N (c j) < min N (c i) := by rw [hc i, hc j]; exact hji
  exact cvSys_not_depthReflection_two_of_lt (V := V) hlt
    (depthReflection_mono (by omega) ((hdepth j (r j)).2 le_rfl))

/-- **Deep reflection forces equal heights.**  In the refinement, any two tags of
reflection depth `≥ 2` have the same truncated height: the reflection-depth vector can
be non-trivial only on the top level set of the height vector. -/
theorem classRealizes_deep_tags_have_equal_heights {N : ℕ} {d r : ℕ → ℕ}
    (h : ClassRealizes N d r) {i j : ℕ} (hi : 2 ≤ r i) (hj : 2 ≤ r j) :
    min N (d i) = min N (d j) := by
  rcases Nat.lt_trichotomy (min N (d i)) (min N (d j)) with hlt | heq | hgt
  · have := classRealizes_low_tag_le_one h (i := j) (j := i) hlt; omega
  · exact heq
  · have := classRealizes_low_tag_le_one h (i := i) (j := j) hgt; omega

/-- The falsifying height vector: the tags `0` and `1` are alive up to height `2`, all
other tags are dead. -/
def exD : ℕ → ℕ := fun i => if i ≤ 1 then 2 else 0

/-- The falsifying reflection-depth vector: tag `0` reflects one level, every other tag
none.  Note `exR i ≤ min 2 (exD i)` for every tag. -/
def exR : ℕ → ℕ := fun i => if i = 0 then 1 else 0

@[simp] theorem exD_zero : exD 0 = 2 := rfl
@[simp] theorem exD_one : exD 1 = 2 := rfl

theorem exD_of_two_le {i : ℕ} (hi : 2 ≤ i) : exD i = 0 := by
  simp only [exD, if_neg (by omega : ¬ i ≤ 1)]

@[simp] theorem exR_zero : exR 0 = 1 := rfl

theorem exR_of_ne {i : ℕ} (hi : i ≠ 0) : exR i = 0 := by
  simp only [exR, if_neg hi]

/-- The falsifying pair obeys the conjecture's hypothesis `r i ≤ min N (d i)`. -/
theorem exR_le_exD (i : ℕ) : exR i ≤ min 2 (exD i) := by
  rcases Nat.eq_or_lt_of_le (Nat.zero_le i) with h | h
  · simp [← h]
  · rw [exR_of_ne (by omega)]
    exact Nat.zero_le _

/-- **The refinement cannot realize the pair `(exD, exR)`.**  The tags `0` and `1` have
the same truncated height `2` but are asked for different reflection depths. -/
theorem not_classRealizes_exD_exR : ¬ ClassRealizes 2 exD exR := by
  intro h
  have := classRealizes_levelwise_constant (i := 0) (j := 1) h (by simp)
  rw [exR_zero, exR_of_ne (by omega)] at this
  omega

/-- **The conjecture is false.**  There is a pair `(d, r)` of a height vector and a
reflection-depth vector satisfying `r i ≤ min N (d i)` for every tag which no
tag-truncated model with a valuation realizes. -/
theorem reflection_depth_conjecture_false :
    ¬ ∀ (N : ℕ) (d r : ℕ → ℕ), (∀ i, r i ≤ min N (d i)) → ClassRealizes N d r :=
  fun h => not_classRealizes_exD_exR (h 2 exD exR exR_le_exD)

/-! ## §5. What the refinement *does* realize: the uniform diagonal -/

/-- **The uniform case is realizable.**  If all tags are asked for the same height `N`
and the same reflection depth `rho ≤ N`, the refinement realizes the pair: take all
truncation heights equal to `N` and the block valuation with shift point `N - rho`,
which turns the refinement into the catalog's block theory `spectrumSys N (N - rho)`. -/
theorem classRealizes_constant {N rho : ℕ} (h : rho ≤ N) :
    ClassRealizes N (fun _ => N) (fun _ => rho) := by
  refine ⟨fun _ => N, blockVal (N - rho), fun i k => ?_, fun i r' => ?_⟩
  · rw [provable_cvSys_boxPow_bot_iff]
  · have hprov : ∀ a : Form,
        Provable (cvSys (fun _ => N) (blockVal (N - rho)) N) a ↔
          Provable (spectrumSys N (N - rho)) a := by
      intro a
      rw [provable_cvSys, spectrumSys, provable_valSys]
      constructor <;> intro hp m hm
      · rw [← satCV_eq_satV_of_le (c := fun _ => N) _ (fun _ => le_rfl) a m hm]
        exact hp m hm
      · rw [satCV_eq_satV_of_le (c := fun _ => N) _ (fun _ => le_rfl) a m hm]
        exact hp m hm
    rw [depthReflection_congr hprov r' i, spectrumSys_depthReflection_iff (by omega) r' i]
    show r' ≤ N - (N - rho) ↔ r' ≤ rho
    omega

/-! ## §6. Window frames: decoupling beyond the refinement -/

/-- A **window frame**: tag `i` sees the worlds `n < m` with `b i ≤ n`, and only from
the worlds `m ≤ H i`.  Truncating from *below* as well as from above is exactly what
the accessibility relations of `capC` cannot do, and it is what makes the image of a
tag depend on more than its height. -/
def winRel (b H : ℕ → ℕ) : ℕ → ℕ → ℕ → Bool := fun i m n => decide (m ≤ H i ∧ b i ≤ n)

/-- Window frames are transitive, hence GL. -/
theorem frameTrans_winRel (b H : ℕ → ℕ) (i : ℕ) : FrameTrans (winRel b H) i := by
  intro m n k _ _ hmn hnk
  simp only [winRel, decide_eq_true_eq] at hmn hnk ⊢
  exact ⟨hmn.1, hnk.2⟩

/-- Satisfaction of a box in a window frame. -/
theorem satF_winRel_box (b H : ℕ → ℕ) (V : ℕ → ℕ → Bool) (i m : ℕ) (a : Form) :
    satF (winRel b H) V m (box i a) = true ↔
      (m ≤ H i → ∀ n, b i ≤ n → n < m → satF (winRel b H) V n a = true) := by
  rw [satF_box]
  constructor
  · intro h hm n hbn hnm
    exact h n hnm (by simp only [winRel, decide_eq_true_eq]; exact ⟨hm, hbn⟩)
  · intro h n hn hR
    simp only [winRel, decide_eq_true_eq] at hR
    exact h hR.1 n hR.2 hn

/-- **The iterated boxed falsum in a window frame.**  A world `m` inside the window of
tag `i` carries an `R i`-chain of length `m - b i`, so `□_i^k ⊥` is true at `m` exactly
when `k` is positive and either `m` is above the window or `m` is within `k - 1` steps
of its bottom. -/
theorem satF_winRel_boxPow_bot (b H : ℕ → ℕ) (V : ℕ → ℕ → Bool) (i : ℕ) :
    ∀ (k m : ℕ), satF (winRel b H) V m (boxPow i k bot) = true ↔
      (1 ≤ k ∧ (H i < m ∨ m + 1 ≤ b i + k)) := by
  intro k
  induction k with
  | zero => intro m; simp [boxPow]
  | succ k ih =>
      intro m
      rw [boxPow, satF_winRel_box]
      by_cases hm : m ≤ H i
      · constructor
        · intro h
          refine ⟨by omega, Or.inr ?_⟩
          by_contra hc
          have := (ih (b i + k)).1 (h hm (b i + k) (by omega) (by omega))
          omega
        · rintro ⟨-, hor⟩ - n hbn hnm
          rw [ih n]
          omega
      · exact ⟨fun _ => ⟨by omega, Or.inl (by omega)⟩, fun _ hle => absurd hle hm⟩

/-- **The inconsistency height of a tag in a window frame** is the length of the window
below the truncation bound. -/
theorem provable_winSys_boxPow_bot_iff (b H : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N i k : ℕ) :
    Provable (frameSys (winRel b H) V N) (boxPow i k bot) ↔ min N (H i) - b i < k := by
  rw [provable_frameSys]
  constructor
  · intro h
    have h0 := (satF_winRel_boxPow_bot b H V i k 0).1 (h 0 (Nat.zero_le N))
    have hm := (satF_winRel_boxPow_bot b H V i k (min N (H i))).1 (h (min N (H i)) (by omega))
    omega
  · intro hlt m hm
    rw [satF_winRel_boxPow_bot]
    omega

/-- **What a provable box knows about a tag in a window frame**: the image of the
accessibility relation of tag `i` is the *interval* `[b i, min N (H i))`, not an initial
segment.  This is the extra freedom that the refinement of `capC` and `valSys` lacks. -/
theorem provable_winSys_box_iff (b H : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N i : ℕ) (a : Form) :
    Provable (frameSys (winRel b H) V N) (box i a) ↔
      ∀ n, b i ≤ n → n < min N (H i) → satF (winRel b H) V n a = true := by
  rw [provable_frameSys_box_iff]
  constructor
  · intro h n hbn hn
    refine h n ⟨min N (H i), by omega, by omega, ?_⟩
    simp only [winRel, decide_eq_true_eq]
    exact ⟨by omega, hbn⟩
  · rintro h n ⟨m, hm, hnm, hR⟩
    simp only [winRel, decide_eq_true_eq] at hR
    exact h n hR.2 (by omega)

/-! ### The decoupling family -/

/-- The bottom cuts of the decoupling family: tag `1` cannot see the root world. -/
def famB : ℕ → ℕ := fun i => if i = 1 then 1 else 0

/-- The top cuts of the decoupling family: tag `0` looks down only from the worlds
`≤ h`, tag `1` from the worlds `≤ h + 1`, every other tag is dead. -/
def famH (h : ℕ) : ℕ → ℕ := fun i => if i = 0 then h else if i = 1 then h + 1 else 0

/-- **The decoupling theory of height `h`**: the worlds `0, …, h + 1`, the window frame
above (tag `0` a *lower* window, tag `1` the same window shifted up by one) and the
valuation making the atoms true exactly at the root.  Both live tags have inconsistency
height `h`, but the image of tag `0` contains the root and the image of tag `1` does
not. -/
def famSys (h : ℕ) : ProofSys Form := frameSys (winRel famB (famH h)) (blockVal 1) (h + 1)

theorem consistent_famSys (h : ℕ) : Consistent (famSys h) := consistent_frameSys (h + 1)

theorem isGL_famSys (h i : ℕ) : IsGLTheory i (famSys h) :=
  isGL_frameSys (h + 1) i (frameTrans_winRel famB (famH h) i)

@[simp] theorem famB_zero : famB 0 = 0 := rfl
@[simp] theorem famB_one : famB 1 = 1 := rfl
@[simp] theorem famH_zero (h : ℕ) : famH h 0 = h := rfl
@[simp] theorem famH_one (h : ℕ) : famH h 1 = h + 1 := rfl

theorem famB_of_ne {i : ℕ} (hi : i ≠ 1) : famB i = 0 := if_neg hi

theorem famH_dead {h i : ℕ} (hi : 2 ≤ i) : famH h i = 0 := by
  simp only [famH, if_neg (by omega : ¬ i = 0), if_neg (by omega : ¬ i = 1)]

/-- **Both live tags have inconsistency height `h`.** -/
theorem famSys_provable_boxPow_bot_live {h i k : ℕ} (hi : i = 0 ∨ i = 1) :
    Provable (famSys h) (boxPow i k bot) ↔ h < k := by
  rw [famSys, provable_winSys_boxPow_bot_iff]
  rcases hi with rfl | rfl
  · simp only [famH_zero, famB_zero]
    omega
  · simp only [famH_one, famB_one]
    omega

/-- Every other tag is dead: it proves `□_i ⊥`. -/
theorem famSys_provable_boxPow_bot_dead {h i : ℕ} (hi : 2 ≤ i) (k : ℕ) :
    Provable (famSys h) (boxPow i k bot) ↔ 0 < k := by
  rw [famSys, provable_winSys_boxPow_bot_iff, famH_dead hi, famB_of_ne (by omega)]
  omega

/-- The negation of an atom is true exactly where the atom is false. -/
theorem satF_neg_atom (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (m p : ℕ) :
    satF R V m (neg (atom p)) = true ↔ V m p = false := by
  rw [neg, satF_imp]
  cases hp : V m p <;> simp [satF_atom, hp]

/-- **Tag `1` has reflection depth `0`.**  The box-free formula `¬p` holds at every
world seen by tag `1` — all of them are above the block of the valuation — but fails at
the root, which tag `1` cannot see. -/
theorem famSys_not_depthReflection_one_one {h : ℕ} (hh : 1 ≤ h) :
    ¬ DepthReflection 1 1 (famSys h) := by
  intro hd
  have hbox : Provable (famSys h) (box 1 (neg (atom 0))) := by
    rw [famSys, provable_winSys_box_iff]
    intro n hn _
    rw [satF_neg_atom]
    simp only [famB_one] at hn
    simp only [blockVal, decide_eq_false_iff_not]
    omega
  have hprov := hd (neg (atom 0)) (by simp [neg, boxDepth]) hbox
  rw [famSys, provable_frameSys] at hprov
  have h0 := hprov 0 (by omega)
  rw [satF_neg_atom] at h0
  simp [blockVal] at h0

/-- **Tag `0` has reflection depth at least `1`.**  Its image `[0, h)` contains the root
and a world above the block, hence a representative of every atom pattern of the model,
so every box-free formula provably provable at tag `0` is provable. -/
theorem famSys_depthReflection_one_zero {h : ℕ} (hh : 2 ≤ h) :
    DepthReflection 1 0 (famSys h) := by
  intro a ha hbox
  have hdep : boxDepth a = 0 := by omega
  rw [famSys, provable_winSys_box_iff] at hbox
  have h0 : satF (winRel famB (famH h)) (blockVal 1) 0 a = true := by
    refine hbox 0 (by simp) ?_
    simp only [famH_zero]
    omega
  have h1 : satF (winRel famB (famH h)) (blockVal 1) 1 a = true := by
    refine hbox 1 (by simp) ?_
    simp only [famH_zero]
    omega
  rw [famSys, provable_frameSys]
  intro m hm
  rcases Nat.eq_zero_or_pos m with rfl | hpos
  · exact h0
  · have hV : ∀ p, blockVal 1 1 p = blockVal 1 m p := by
      intro p
      simp only [blockVal, decide_eq_decide]
      omega
    rw [← satF_congr_of_boxDepth_zero (R := winRel famB (famH h)) hV a hdep]
    exact h1

/-- **Tag `0` has reflection depth at most `1`.**  The formula `□_0 ⊥ → □_1 ⊥`, of box
depth `1`, holds at every world seen by tag `0` but fails at the top world `h + 1`,
where tag `0` is already exhausted while tag `1` is not. -/
theorem famSys_not_depthReflection_two_zero {h : ℕ} (hh : 1 ≤ h) :
    ¬ DepthReflection 2 0 (famSys h) := by
  intro hd
  have hbox0 : ∀ m, satF (winRel famB (famH h)) (blockVal 1) m (box 0 bot) = true ↔
      (h < m ∨ m ≤ 0) := by
    intro m
    have := satF_winRel_boxPow_bot famB (famH h) (blockVal 1) 0 1 m
    rw [show boxPow 0 1 bot = box 0 bot from rfl] at this
    rw [this]
    simp only [famH_zero, famB_zero]
    omega
  have hbox1 : ∀ m, satF (winRel famB (famH h)) (blockVal 1) m (box 1 bot) = true ↔
      (h + 1 < m ∨ m ≤ 1) := by
    intro m
    have := satF_winRel_boxPow_bot famB (famH h) (blockVal 1) 1 1 m
    rw [show boxPow 1 1 bot = box 1 bot from rfl] at this
    rw [this]
    simp only [famH_one, famB_one]
    omega
  have hbox : Provable (famSys h) (box 0 (imp (box 0 bot) (box 1 bot))) := by
    rw [famSys, provable_winSys_box_iff]
    intro n _ hn
    simp only [famH_zero] at hn
    rw [satF_imp, hbox0 n, hbox1 n]
    omega
  have hprov := hd (imp (box 0 bot) (box 1 bot)) (by simp [boxDepth]) hbox
  rw [famSys, provable_frameSys] at hprov
  have htop := hprov (h + 1) (by omega)
  rw [satF_imp, hbox0 (h + 1), hbox1 (h + 1)] at htop
  have := htop (by omega)
  omega

/-- Every dead tag has reflection depth `0`. -/
theorem famSys_not_depthReflection_one_dead {h i : ℕ} (hi : 2 ≤ i) :
    ¬ DepthReflection 1 i (famSys h) := by
  intro hd
  have hbox : Provable (famSys h) (box i bot) := by
    have := (famSys_provable_boxPow_bot_dead (h := h) hi 1).2 (by omega)
    rwa [show boxPow i 1 bot = box i bot from rfl] at this
  exact consistent_famSys h (hd bot (by simp) hbox)

/-- **The exact reflection spectrum of the decoupling theory.**  Tag `0` reflects to
depth `1`, every other tag to depth `0` — although the tags `0` and `1` have the same
inconsistency height `h`. -/
theorem famSys_depthReflection_iff {h : ℕ} (hh : 2 ≤ h) (i r' : ℕ) :
    DepthReflection r' i (famSys h) ↔ r' ≤ exR i := by
  have hzero : ∀ j, ¬ DepthReflection 1 j (famSys h) → (DepthReflection r' j (famSys h) ↔ r' ≤ 0) := by
    intro j hj
    constructor
    · intro hdr
      by_contra hr
      exact hj (depthReflection_mono (by omega) hdr)
    · intro hr
      have : r' = 0 := by omega
      subst this
      intro a ha _
      omega
  rcases Nat.lt_or_ge i 2 with hi | hi
  · interval_cases i
    · rw [exR_zero]
      constructor
      · intro hdr
        by_contra hr
        exact famSys_not_depthReflection_two_zero (by omega) (depthReflection_mono (by omega) hdr)
      · intro hr
        exact depthReflection_mono hr (famSys_depthReflection_one_zero hh)
    · rw [exR_of_ne (by omega)]
      exact hzero 1 (famSys_not_depthReflection_one_one (by omega))
  · rw [exR_of_ne (by omega)]
    exact hzero i (famSys_not_depthReflection_one_dead hi)

/-- The height vector realized by the decoupling family: both live tags at height `h`,
all other tags dead. -/
def famD (h : ℕ) : ℕ → ℕ := fun i => if i ≤ 1 then h else 0

theorem famD_le_one {h i : ℕ} (hi : i ≤ 1) : famD h i = h := if_pos hi

theorem famD_of_two_le {h i : ℕ} (hi : 2 ≤ i) : famD h i = 0 :=
  if_neg (by omega)

/-- **An infinite family of decoupled GL theories.**  For every `h ≥ 2` there is a
consistent GL theory whose tags `0` and `1` have *equal* inconsistency spectra (both of
height `h`) and *different* reflection depths (`1` and `0`).  By rigidity, no
tag-truncated model with a valuation can do this at any `h`. -/
theorem glRealizes_fam {h : ℕ} (hh : 2 ≤ h) : GLRealizes h (famD h) exR := by
  refine ⟨famSys h, consistent_famSys h, isGL_famSys h, fun i k => ?_,
    fun i r' => famSys_depthReflection_iff hh i r'⟩
  rcases Nat.lt_or_ge i 2 with hi | hi
  · rw [famSys_provable_boxPow_bot_live (by omega), famD_le_one (by omega)]
    omega
  · rw [famSys_provable_boxPow_bot_dead hi, famD_of_two_le hi]
    omega

/-- **The pair the refinement cannot realize is realized by a consistent GL theory.**
The theory `famSys 2` has inconsistency height `2` at both live tags — so their
inconsistency spectra are literally equal — while their reflection depths are `1` and
`0`.  Hence the conjecture holds for the class of *all* consistent GL theories at this
pair, and fails only for the tag-truncated models with a valuation. -/
theorem glRealizes_exD_exR : GLRealizes 2 exD exR := by
  have h := glRealizes_fam (h := 2) (by omega)
  have hd : famD 2 = exD := by
    funext i
    by_cases hi : i ≤ 1 <;> simp [famD, exD, hi]
  rwa [hd] at h


/-! ### A second, independent falsification: the height gap -/

/-- A second falsifying height vector: tag `0` has height `2`, every other tag height
`1`. -/
def exD2 : ℕ → ℕ := fun i => if i = 0 then 2 else 1

/-- The matching reflection-depth vector, maximal at every tag. -/
def exR2 : ℕ → ℕ := fun i => if i = 0 then 2 else 1

theorem exR2_le_exD2 (i : ℕ) : exR2 i ≤ min 2 (exD2 i) := by
  by_cases hi : i = 0 <;> simp [exR2, exD2, hi]

/-- **The maximal reflection depths are not jointly realizable when the heights
differ.**  Even though each tag separately could reflect up to its own height, tag `0`
is blocked at the gap `2 - 1 = 1` by the presence of the lower tag `1`. -/
theorem not_classRealizes_exD2_exR2 : ¬ ClassRealizes 2 exD2 exR2 := by
  intro h
  have := classRealizes_gap_bound h (i := 0) (j := 1) (by simp [exD2])
  simp [exR2, exD2] at this

/-- **The conjecture fails for a second, independent reason.**  There is a pair
`(d, r)` with `r i ≤ min N (d i)` at which the refinement fails the *height-gap*
inequality, not the rigidity constraint. -/
theorem reflection_depth_conjecture_false_gap :
    ¬ ∀ (N : ℕ) (d r : ℕ → ℕ), (∀ i, r i ≤ min N (d i)) → ClassRealizes N d r :=
  fun h => not_classRealizes_exD2_exR2 (h 2 exD2 exR2 exR2_le_exD2)

/-! ## §7. The general principle: incomparable images are necessary and sufficient -/

/-- **The image of a tag in a window frame** is the interval `[b i, min N (H i))`.
Unlike the initial segments produced by `capC`, such intervals can be *incomparable*. -/
theorem frameImage_winRel_iff (b H : ℕ → ℕ) (N i n : ℕ) :
    FrameImage (winRel b H) N i n ↔ (b i ≤ n ∧ n < min N (H i)) := by
  constructor
  · rintro ⟨m, hm, hnm, hR⟩
    simp only [winRel, decide_eq_true_eq] at hR
    omega
  · rintro ⟨h1, h2⟩
    exact ⟨n + 1, by omega, by omega, by simp only [winRel, decide_eq_true_eq]; omega⟩

/-- **The decoupling family has incomparable tag images.**  In `famSys h` the world `0`
is seen by tag `0` but not by tag `1`, and the world `h` is seen by tag `1` but not by
tag `0`.  By `frameImage_not_subset_of_depthReflection_ne` this is *forced*: no frame
with nested tag images can separate the reflection depths of two tags.  So the failure
of the conjecture in the refinement class and its repair on window frames are two sides
of one statement — the refinement can only produce nested images. -/
theorem famSys_images_incomparable {h : ℕ} (hh : 1 ≤ h) :
    (FrameImage (winRel famB (famH h)) (h + 1) 0 0 ∧
        ¬ FrameImage (winRel famB (famH h)) (h + 1) 1 0) ∧
      (FrameImage (winRel famB (famH h)) (h + 1) 1 h ∧
        ¬ FrameImage (winRel famB (famH h)) (h + 1) 0 h) := by
  have hb0 : famB 0 = 0 := famB_of_ne (by omega)
  have hb1 : famB 1 = 1 := if_pos rfl
  have hH0 : famH h 0 = h := if_pos rfl
  have hH1 : famH h 1 = h + 1 := by simp [famH]
  refine ⟨⟨?_, ?_⟩, ?_, ?_⟩ <;>
    simp only [frameImage_winRel_iff, hb0, hb1, hH0, hH1] <;> omega

/-- **Summary of the cycle.**  The conjecture, taken literally, is refuted: the class of
tag-truncated models with a valuation is *rigid* — equal truncated heights force equal
reflection depths — and the explicit pair `(exD, exR)` witnesses the failure.  The same
pair is realized by a consistent GL theory built on a window frame, so the obstruction
lies in the shape of the accessibility relations of `capC`, not in GL: the second cut
point must be tag-local, and a global valuation cannot make it so. -/
theorem per_tag_reflection_depth_summary :
    (∀ (c : ℕ → ℕ) (V : ℕ → ℕ → Bool) (N i j d : ℕ), min N (c i) = min N (c j) →
        (DepthReflection d i (cvSys c V N) ↔ DepthReflection d j (cvSys c V N))) ∧
      (∀ i, exR i ≤ min 2 (exD i)) ∧
      (∀ (N : ℕ) (d r : ℕ → ℕ), ClassRealizes N d r → ∀ i j, min N (d j) < min N (d i) →
        r i ≤ min N (d i) - min N (d j)) ∧
      (∀ (N : ℕ) (d r : ℕ → ℕ), ClassRealizes N d r → ∀ i j, 2 ≤ r i → 2 ≤ r j →
        min N (d i) = min N (d j)) ∧
      ¬ ClassRealizes 2 exD exR ∧
      ¬ ClassRealizes 2 exD2 exR2 ∧
      GLRealizes 2 exD exR ∧
      (∀ N rho : ℕ, rho ≤ N → ClassRealizes N (fun _ => N) (fun _ => rho)) :=
  ⟨fun _ _ _ _ _ d h => cvSys_depthReflection_congr_of_min_eq h d, exR_le_exD,
    fun _ _ _ h _ _ hij => classRealizes_gap_bound h hij,
    fun _ _ _ h _ _ hi hj => classRealizes_deep_tags_have_equal_heights h hi hj,
    not_classRealizes_exD_exR, not_classRealizes_exD2_exR2, glRealizes_exD_exR,
    fun _ _ h => classRealizes_constant h⟩

end PhysicsConsistency