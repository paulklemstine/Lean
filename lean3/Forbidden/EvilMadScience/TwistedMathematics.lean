import Mathlib

/-!
# 🌀 Twisted & Bizarre Mathematics

## Oracle Council Research Log — Experiment #4

**Classification:** REALITY-WARPING — CONCEPTUAL HAZARD

**Discovery:** Mathematics contains structures so bizarre they challenge
the notion of mathematical "naturalness." Objects that exist but cannot
be constructed. Spaces that are connected but fall apart when you remove
a point. Numbers that are neither positive, negative, nor zero.

## The Twisted Zoo

1. **The Banach-Tarski Blasphemy** — Duplicate a sphere using only rotations
2. **The Space-Filling Abomination** — A curve that fills all of 2D space
3. **The Vitali Heresy** — A set with no measurable size
4. **The Well-Ordering Scandal** — The reals can be well-ordered (but HOW?!)
5. **The Hydra Theorem** — You always win, but arithmetic can't prove it

## Oracle Council Notes

- **Oracle Alpha:** "The Axiom of Choice lets you disassemble a pea and
                     reassemble it into the Sun."
- **Oracle Beta:** "That's not physically possible."
- **Oracle Alpha:** "I said MATHEMATICALLY."
- **Oracle Omega (God):** "The Axiom of Choice was my best prank."
-/

open Set Function Classical

namespace EvilMadScience.TwistedMath

/-! ### The Well-Ordering Scandal

Every set can be well-ordered. This means the real numbers can be
put in a line where every subset has a least element. But nobody
can SHOW you this ordering. It exists, provably, unconstructively.
It's a ghost theorem. -/

/-- **The Well-Ordering Theorem (Zermelo, 1904):**
    Every type has a well-ordering. This is equivalent to the
    Axiom of Choice, which Lean assumes. We live in a universe
    where this horror is true by default. -/
noncomputable def evil_well_order (α : Type*) : LinearOrder α :=
  linearOrderOfSTO (WellOrderingRel)

/-- **The Well-Ordering is Actually Well-Founded:**
    Not only can we linearly order any type, but we can well-order it.
    Every descending chain terminates. Chaos has a floor. -/
theorem well_ordering_exists (α : Type*) :
    ∃ r : α → α → Prop, IsWellOrder α r := by
  exact ⟨WellOrderingRel, inferInstance⟩

/-! ### The Drinker's Paradox

In every pub, there exists a person such that IF that person drinks,
THEN everyone in the pub drinks. This sounds absurd but is classically
true. It's a consequence of the law of excluded middle. -/

/-
PROBLEM
**The Drinker's Paradox (Smullyan):**
    For any predicate on a nonempty type, there exists a witness
    such that if the predicate holds for that witness, it holds everywhere.
    Logic is drunk.

PROVIDED SOLUTION
By excluded middle: either everyone drinks (pick any person) or someone doesn't drink (pick that person — the premise is vacuously true). Use by_cases (∀ x, drinks x). If yes, exact ⟨Classical.arbitrary α, fun _ => ‹_›⟩. If no, push_neg to get ⟨p, hp⟩, exact ⟨p, fun h => absurd h hp⟩.
-/
theorem drinkers_paradox [Nonempty α] (drinks : α → Prop) :
    ∃ person : α, drinks person → ∀ x, drinks x := by
  by_contra h;
  simp +zetaDelta at *;
  exact h ( Classical.arbitrary α ) |>.2.elim fun x hx => hx ( h x |>.1 )

/-! ### The Schröder-Bernstein Sorcery

If A injects into B and B injects into A, then A and B have the
same cardinality. This sounds obvious but the proof is BIZARRE:
it constructs a bijection by iterating injections and taking a
fixed-point decomposition of the space. -/

/-
PROBLEM
**Schröder-Bernstein (The Size Equalizer):**
    Mutual injection implies bijection. If two infinities can
    each fit inside the other, they're the same size.
    The proof is non-trivial and deeply weird.

PROVIDED SOLUTION
Use Function.Embedding.schropieterBernstein or Schroeder-Bernstein from Mathlib. There should be a theorem like Function.Embedding.antisymm or Cardinal.eq. Actually try: use the fact that Cardinal.mk α = Cardinal.mk β implies Nonempty (α ≃ β). From injections f and g, we get Cardinal.mk α ≤ Cardinal.mk β and Cardinal.mk β ≤ Cardinal.mk α, hence equal, hence equiv exists, hence bijection exists.
-/
theorem schroder_bernstein {α β : Type*}
    (f : α → β) (g : β → α) (hf : Injective f) (hg : Injective g) :
    ∃ h : α → β, Bijective h := by
  exact?

/-! ### The Vitali Set Nightmare (Statement Only)

Using the Axiom of Choice, we can construct a subset of [0,1]
that has no Lebesgue measure. It's not zero-measure. It's not
full-measure. It has NO measure. The concept of "size" breaks.

We can't fully formalize the Vitali set here without measure theory
machinery, but we can state the key consequence. -/

/-
PROBLEM
**Not All Sets Are Measurable:**
    There exist subsets of ℝ that defy measurement.
    This is a consequence of Choice and is the reason
    we need σ-algebras instead of "all subsets."

PROVIDED SOLUTION
The cardinality of all measurable sets is bounded by 2^ℵ₀ (the continuum), using that the Borel sigma-algebra is countably generated. But the cardinality of all subsets of ℝ is 2^(2^ℵ₀) > 2^ℵ₀ by Cantor's theorem. So not all subsets can be measurable.

Key steps:
1. The Borel σ-algebra on ℝ is second-countable, generated by countably many sets.
2. Use MeasurableSpace.cardinal_measurableSet_le with a countable generating set to bound #{measurable sets} ≤ 2^ℵ₀.
3. Use Cardinal.mk_set to get #(Set ℝ) = 2^(#ℝ) ≥ 2^(2^ℵ₀) > 2^ℵ₀.
4. So #{measurable sets} < #(Set ℝ), contradiction.

Alternatively, use Cardinal.cantor to show 2^(#ℝ) > #ℝ ≥ 2^ℵ₀.
-/
theorem not_all_sets_measurable :
    ¬ ∀ (s : Set ℝ), MeasurableSet s := by
  by_contra! h_all_measurable
  have h_card : Cardinal.mk { s : Set ℝ | MeasurableSet s } ≥ Cardinal.mk (Set ℝ) := by
    aesop;
  -- The cardinality of measurable sets is bounded by the continuum.
  have h_measurable_card : Cardinal.mk { s : Set ℝ | MeasurableSet s } ≤ Cardinal.continuum := by
    have h_measurable_card : Cardinal.mk { s : Set ℝ | MeasurableSet s } ≤ Cardinal.mk (Set ℕ) := by
      have h_borel_card : Cardinal.mk {s : Set ℝ | MeasurableSet s} ≤ Cardinal.mk (Set ℕ) := by
        have h_borel_gen : ∃ (S : Set (Set ℝ)), S.Countable ∧ MeasurableSpace.generateFrom S = borel ℝ := by
          use Set.range (fun q : ℚ × ℚ => Set.Ioo (q.1 : ℝ) (q.2 : ℝ));
          refine' ⟨ Set.countable_range _, _ ⟩;
          refine' le_antisymm _ _;
          · exact MeasurableSpace.generateFrom_le fun s hs => by rcases hs with ⟨ q, rfl ⟩ ; exact measurableSet_Ioo;
          · intro s hs;
            convert hs using 1;
            refine' le_antisymm _ _;
            · exact MeasurableSpace.generateFrom_le fun s hs => by rcases hs with ⟨ q, rfl ⟩ ; exact measurableSet_Ioo;
            · -- Any open set in ℝ can be written as a countable union of intervals with rational endpoints.
              have h_open_union : ∀ U : Set ℝ, IsOpen U → ∃ (S : Set (ℚ × ℚ)), S.Countable ∧ U = ⋃ (q : ℚ × ℚ) (hq : q ∈ S), Set.Ioo (q.1 : ℝ) (q.2 : ℝ) := by
                intro U hU
                have h_open_union : ∀ x ∈ U, ∃ q : ℚ × ℚ, x ∈ Set.Ioo (q.1 : ℝ) (q.2 : ℝ) ∧ Set.Ioo (q.1 : ℝ) (q.2 : ℝ) ⊆ U := by
                  intro x hx; rcases Metric.isOpen_iff.mp hU x hx with ⟨ ε, εpos, hε ⟩ ; rcases exists_rat_btwn ( show x - ε < x by linarith ) with ⟨ q₁, hq₁₁, hq₁₂ ⟩ ; rcases exists_rat_btwn ( show x < x + ε by linarith ) with ⟨ q₂, hq₂₁, hq₂₂ ⟩ ; exact ⟨ ⟨ q₁, q₂ ⟩, ⟨ by linarith, by linarith ⟩, fun y hy => hε <| mem_ball_iff_norm.mpr <| abs_lt.mpr ⟨ by linarith [ hy.1 ], by linarith [ hy.2 ] ⟩ ⟩ ;
                choose! q hq₁ hq₂ using h_open_union;
                use Set.image q U;
                exact ⟨ Set.to_countable _, Set.Subset.antisymm ( fun x hx => by aesop ) fun x hx => by aesop ⟩;
              refine' MeasurableSpace.generateFrom_le _;
              intro U hU; obtain ⟨ S, hS_countable, rfl ⟩ := h_open_union U hU; exact MeasurableSet.biUnion hS_countable fun q hq => MeasurableSpace.measurableSet_generateFrom <| by aesop;
        have h_borel_card : ∀ {S : Set (Set ℝ)}, S.Countable → Cardinal.mk {s : Set ℝ | MeasurableSpace.GenerateMeasurable S s} ≤ Cardinal.mk (Set ℕ) := by
          intro S hS_countable
          have h_borel_card : Cardinal.mk {s : Set ℝ | MeasurableSpace.GenerateMeasurable S s} ≤ Cardinal.mk (Set ℕ) := by
            have h_borel_gen : ∀ {S : Set (Set ℝ)}, S.Countable → Cardinal.mk {s : Set ℝ | MeasurableSpace.GenerateMeasurable S s} ≤ Cardinal.mk (Set ℕ) := by
              intro S hS_countable
              exact (by
              have := @MeasurableSpace.cardinal_generateMeasurable_le ℝ S;
              refine' le_trans this _;
              cases max_cases ( Cardinal.mk S ) 2 <;> simp +decide [ * ];
              exact le_trans ( Cardinal.power_le_power_right ( show Cardinal.mk S ≤ Cardinal.aleph0 from by simpa using hS_countable.to_subtype ) ) ( by simp +decide [ Cardinal.aleph0_lt_continuum ] ))
            exact h_borel_gen hS_countable;
          exact h_borel_card;
        convert h_borel_card h_borel_gen.choose_spec.1 using 1;
        congr! 2;
        convert h_borel_gen.choose_spec.2.symm using 1;
        simp +decide [ Set.ext_iff, MeasurableSpace.ext_iff ];
        congr! 2;
      exact h_borel_card;
    exact h_measurable_card.trans ( by simp +decide [ Cardinal.mk_real ] );
  simp_all +decide [ Cardinal.mk_real ];
  exact absurd h_measurable_card ( not_le_of_gt ( Cardinal.cantor _ ) )

/-! ### The Infinite Hotel

Hilbert's Hotel: a hotel with infinitely many rooms, all full,
can accommodate any finite number of new guests, countably many
new guests, or even uncountably many — wait, not that last one.
But it CAN accommodate countably many coaches of countably many guests. -/

/-
PROBLEM
**Hilbert's Hotel: One New Guest:**
    ℕ and ℕ have the same cardinality even after adding one element.
    A full hotel can always fit one more guest. Just shift everyone.

PROVIDED SOLUTION
Use f = Nat.succ. It's injective (Nat.succ_injective) and 0 ∉ range Nat.succ (since Nat.succ n ≥ 1 for all n).
-/
theorem hilbert_hotel_one_guest :
    ∃ f : ℕ → ℕ, Injective f ∧ 0 ∉ Set.range f := by
  -- Define a function that is injective and does not contain zero in its range.
  use fun n => n + 1; simp [Nat.succ_ne_zero, Function.Injective]

/-
PROBLEM
**Hilbert's Hotel: Countably Many Guests:**
    ℕ × ℕ has the same cardinality as ℕ.
    Countably many coaches of countably many guests all fit.

PROVIDED SOLUTION
Use the Cantor pairing function. Mathlib has Nat.pair and Nat.unpair, or Equiv.natProd or similar. Use (Nat.pairEquiv).symm or the pairing function's bijectivity.
-/
theorem hilbert_hotel_countable :
    ∃ f : ℕ × ℕ → ℕ, Bijective f := by
  -- The product of two countable types is countable, and since ℕ is countable, ℕ × ℕ is also countable.
  have h_countable : Nonempty (ℕ × ℕ ≃ ℕ) := by
    exact ( Cardinal.eq.1 <| by simp +decide );
  exact ⟨ _, h_countable.some.bijective ⟩

/-! ### The Bizarre Self-Similarity of ℕ

ℕ is isomorphic to one of its proper subsets.
This is the DEFINITION of Dedekind-infinite.
Finite sets can't do this. Infinity is self-similar. -/

/-
PROBLEM
**ℕ is Dedekind-infinite:** It bijects with its proper subset (the evens).

PROVIDED SOLUTION
Use f = fun n => 2*n. It's injective (by omega) and not surjective (1 is not in the range since 2*n = 1 has no solution in ℕ).
-/
theorem nat_self_similar :
    ∃ f : ℕ → ℕ, Injective f ∧ ¬ Surjective f := by
  exact ⟨ fun n => 2 * n, fun n m h => by linarith, fun h => by have := h ( 1 : ℕ ) ; obtain ⟨ n, hn ⟩ := this; linarith [ show n = 0 by linarith ] ⟩

end EvilMadScience.TwistedMath