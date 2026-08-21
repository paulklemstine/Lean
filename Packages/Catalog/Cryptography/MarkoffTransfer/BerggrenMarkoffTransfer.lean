import Cryptography.BerggrenTrees.BerggrenFreeMonoid
import Cryptography.MarkoffTransfer.MarkoffFreeBinary

/-!
# Berggren ⟷ Markoff: What Transfers and What Does Not

The research hypothesis under test is that the Berggren ternary tree of primitive
Pythagorean triples and the Markoff tree are **isomorphic** as trees, so that the
Berggren machinery (free monoid, groupoid action, hyperbolic geometry, growth theory)
transfers wholesale to the Markoff side.

This file settles the isomorphism question **negatively** and, in the same breath,
isolates exactly the part of the machinery that *does* transfer.

## Negative half — the branching obstruction

* `bLevel_card` — depth `n` of the Berggren tree carries exactly `3 ^ n` nodes
  (built on `actGen_unique_parent` from the catalog's Berggren free monoid file).
* `MarkoffTransfer.mLevel_card` — depth `n` of the Markoff tree carries exactly `2 ^ n`.
* `berggren_level_card_gt_markoff` — hence the two levels have different sizes for `n ≥ 1`.
* `no_injective_level_map` — no injection of Berggren level `n` into Markoff level `n`.
* `no_local_tree_iso` — **no branching-compatible injection exists at all**: any injective
  map sending Berggren children to Markoff children collapses two of the three Berggren
  children of the root.  This is the precise failure point of the conjectured transfer:
  the ternary Berggren branching cannot be matched by the binary Vieta branching.

## Positive half — the freeness transfer

* `transferWord_injective`, `berggren_transfer_injective`, `markoff_embeds_in_berggren` —
  the Markoff tree embeds injectively and depth-preservingly into the Berggren tree, as
  the sub-tree spanned by two of the three Berggren generators.  So the *free monoid*
  half of the Berggren machinery does transfer — as a rank-`2` sub-structure, never as
  an isomorphism.
-/

namespace MarkoffTransfer

open Finset

/-! ## Berggren levels -/

/-- Level `n` of the Berggren tree, in the `(m, n)` pair model of the catalog. -/
def bLevel : ℕ → Finset (ℤ × ℤ)
  | 0 => {rootPair}
  | n + 1 =>
      (bLevel n).image (actGen .A) ∪ (bLevel n).image (actGen .B) ∪
        (bLevel n).image (actGen .C)

theorem bLevel_valid : ∀ (n : ℕ), ∀ p ∈ bLevel n, ValidPair p := by
  intro n
  induction n with
  | zero =>
      intro p hp
      simp only [bLevel, Finset.mem_singleton] at hp
      subst hp; exact rootPair_valid
  | succ n ih =>
      intro p hp
      simp only [bLevel, Finset.mem_union, Finset.mem_image] at hp
      rcases hp with (⟨s, hs, rfl⟩ | ⟨s, hs, rfl⟩) | ⟨s, hs, rfl⟩ <;>
        exact actGen_preserves_valid _ (ih s hs)

theorem bLevel_image_disjoint {n : ℕ} {g₁ g₂ : BergGen} (hg : g₁ ≠ g₂) :
    Disjoint ((bLevel n).image (actGen g₁)) ((bLevel n).image (actGen g₂)) := by
  rw [Finset.disjoint_left]
  rintro p hp hp'
  simp only [Finset.mem_image] at hp hp'
  obtain ⟨s, hs, rfl⟩ := hp
  obtain ⟨t, ht, hteq⟩ := hp'
  exact hg (actGen_generator_determined (bLevel_valid n s hs) (bLevel_valid n t ht) hteq.symm)

theorem bLevel_image_card {n : ℕ} (g : BergGen) :
    ((bLevel n).image (actGen g)).card = (bLevel n).card :=
  Finset.card_image_of_injective _ (actGen_injective g)

/-- **The Berggren tree has exactly `3 ^ n` nodes at depth `n`.** -/
theorem bLevel_card : ∀ n : ℕ, (bLevel n).card = 3 ^ n := by
  intro n
  induction n with
  | zero => simp [bLevel]
  | succ n ih =>
      have hdisjAB : Disjoint ((bLevel n).image (actGen .A)) ((bLevel n).image (actGen .B)) :=
        bLevel_image_disjoint (by decide)
      have hdisjC :
          Disjoint ((bLevel n).image (actGen .A) ∪ (bLevel n).image (actGen .B))
            ((bLevel n).image (actGen .C)) := by
        rw [Finset.disjoint_union_left]
        exact ⟨bLevel_image_disjoint (by decide), bLevel_image_disjoint (by decide)⟩
      simp only [bLevel]
      rw [Finset.card_union_of_disjoint hdisjC, Finset.card_union_of_disjoint hdisjAB,
        bLevel_image_card, bLevel_image_card, bLevel_image_card, ih]
      ring

/-! ## The branching obstruction -/

/-- The Berggren level is strictly larger than the Markoff level from depth `1` on. -/
theorem berggren_level_card_gt_markoff {n : ℕ} (hn : 1 ≤ n) :
    (mLevel n).card < (bLevel n).card := by
  rw [mLevel_card, bLevel_card]
  exact Nat.pow_lt_pow_left (by norm_num) (by omega)

/-- **No level-preserving injection.**  For `n ≥ 1` there is no injection of the Berggren
level `n` into the Markoff level `n`; in particular no tree isomorphism exists. -/
theorem no_injective_level_map {n : ℕ} (hn : 1 ≤ n) (f : ℤ × ℤ → ℤ × ℤ × ℤ)
    (hmaps : ∀ p ∈ bLevel n, f p ∈ mLevel n) (hinj : Set.InjOn f (bLevel n)) : False := by
  have hcard : (bLevel n).card ≤ (mLevel n).card :=
    Finset.card_le_card_of_injOn f hmaps hinj
  exact absurd hcard (Nat.not_le.mpr (berggren_level_card_gt_markoff hn))

/-- The three Berggren children of the root are pairwise distinct. -/
theorem berggren_root_children_distinct :
    actGen .A rootPair ≠ actGen .B rootPair ∧ actGen .A rootPair ≠ actGen .C rootPair ∧
      actGen .B rootPair ≠ actGen .C rootPair := by
  refine ⟨?_, ?_, ?_⟩ <;> simp [actGen, rootPair, Prod.ext_iff]

/-- **The precise failure point of the conjectured transfer.**

There is no injective map from the Berggren tree to the Markoff tree that carries
Berggren children to Markoff children: the root already has three distinct Berggren
children but only two Markoff children are available, so two must collide.  Note that no
compatibility with the roots is even needed: the obstruction is purely local. -/
theorem no_local_tree_iso (f : ℤ × ℤ → ℤ × ℤ × ℤ)
    (hinj : Function.Injective f)
    (hchild : ∀ g : BergGen, ∃ b : Bool, f (actGen g rootPair) = child b (f rootPair)) :
    False := by
  obtain ⟨bA, hA⟩ := hchild .A
  obtain ⟨bB, hB⟩ := hchild .B
  obtain ⟨bC, hC⟩ := hchild .C
  obtain ⟨hAB, hAC, hBC⟩ := berggren_root_children_distinct
  -- three bits, two values: two of them agree
  have hpair : bA = bB ∨ bA = bC ∨ bB = bC := by
    cases bA <;> cases bB <;> cases bC <;> simp
  rcases hpair with h | h | h
  · exact hAB (hinj (by rw [hA, hB, h]))
  · exact hAC (hinj (by rw [hA, hC, h]))
  · exact hBC (hinj (by rw [hB, hC, h]))

/-! ## The freeness transfer: the Markoff tree as a Berggren sub-tree -/

/-- The transfer of a Markoff binary word to a Berggren word, using two of the three
Berggren generators. -/
def transferWord : List Bool → BergWord :=
  List.map (fun b => if b then BergGen.B else BergGen.A)

@[simp] theorem transferWord_length (w : List Bool) : (transferWord w).length = w.length := by
  simp [transferWord]

theorem transferWord_injective : Function.Injective transferWord := by
  intro u v h
  have : ∀ b₁ b₂ : Bool,
      (if b₁ then BergGen.B else BergGen.A) = (if b₂ then BergGen.B else BergGen.A) → b₁ = b₂ := by
    intro b₁ b₂ hb; cases b₁ <;> cases b₂ <;> simp_all
  exact List.map_injective_iff.mpr (fun a b hab => this a b hab) h

/-- The transferred words evaluate injectively in the Berggren tree: the Markoff binary
tree sits inside the Berggren ternary tree as a free rank-`2` sub-tree. -/
theorem berggren_transfer_injective : Function.Injective (fun w => evalPair (transferWord w)) :=
  fun _ _ h => transferWord_injective (evalPair_injective h)

/-- **Positive transfer theorem.**  There is a depth-preserving injection of the Markoff
tree into the Berggren tree.  Freeness — the one piece of the Berggren machinery that is
purely combinatorial — does transfer; it simply lands in a rank-`2` sub-monoid. -/
theorem markoff_embeds_in_berggren :
    ∃ Φ : (ℤ × ℤ × ℤ) → ℤ × ℤ,
      (∀ w : List Bool, Φ (mEval w) = evalPair (transferWord w)) ∧
        Function.Injective (fun w : List Bool => Φ (mEval w)) := by
  refine ⟨fun t => evalPair (transferWord (Function.invFun mEval t)), ?_, ?_⟩
  · intro w
    show evalPair (transferWord (Function.invFun mEval (mEval w))) = evalPair (transferWord w)
    rw [Function.leftInverse_invFun mEval_injective w]
  · intro u v h
    dsimp only at h
    rw [Function.leftInverse_invFun mEval_injective u,
      Function.leftInverse_invFun mEval_injective v] at h
    exact transferWord_injective (evalPair_injective h)

/-- The embedding is depth preserving: a Markoff word of length `n` lands in Berggren
level `n`. -/
theorem transfer_mem_bLevel : ∀ (w : List Bool), evalPair (transferWord w) ∈ bLevel w.length := by
  intro w
  induction w with
  | nil => simp [bLevel, transferWord, evalPair]
  | cons b rest ih =>
      cases b <;>
        simp only [transferWord, List.map_cons, evalPair, List.length_cons, bLevel,
          Finset.mem_union, Finset.mem_image] <;>
        [ exact Or.inl (Or.inl ⟨_, ih, rfl⟩) ; exact Or.inl (Or.inr ⟨_, ih, rfl⟩) ]

end MarkoffTransfer