import Shared.SidonSetsRigidity
import Shared.SidonSetsCyclic

/-!
# Sidon sets IV: the symmetry group, and a negative result

Fourth cycle.  Cycles 1–3 produced constructions and bounds; this cycle asks the two
questions a critic would ask next.  *Which transformations preserve Sidon-ness?* and
*is the construction of cycle 3 actually optimal in its own group?*  The answers are a
symmetry group (translations and unit dilations) and a clean **negative** result: the
Erdős–Turán set, despite being Sidon in `ZMod (2p²)`, is never a perfect difference set
there.

## Main results

* `isSidon_image_add_right` — **translation invariance**: `IsSidon (A + t) ↔ IsSidon A`
  in any additive cancellative commutative monoid.
* `isSidon_image_unit_mul` — **dilation invariance**: for a unit `u` of a commutative
  ring, `IsSidon (u · A) ↔ IsSidon A`.  Together these give an affine group acting on
  the collection of Sidon sets of `ZMod N`, of order `N · φ(N)`.
* `etSetZMod_not_perfect` — **negative result**: for every odd prime `p` the reduction of
  the Erdős–Turán set modulo `2p²` is *not* a perfect difference set.  It realises
  `p² - p` of the `2p² - 1` nonzero differences, so the cyclic sandwich of cycle 3 has a
  genuine gap that no reindexing of this construction can close.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (T1) Sidon-ness should be an affine-invariant notion, not an
  artefact of the chosen coordinates.  (T2) The cyclic sandwich of cycle 3 leaves a
  factor `√2`; the optimistic reading is that the Erdős–Turán set is already perfect in
  `ZMod (2p²)` and the *upper* bound is what should improve.
Experiment (Experimenter): (T1) was proved in both a monoid form (translations, using
  `add_right_cancel`) and a ring form (unit dilations, using multiplication by `u⁻¹`).
  (T2) was **refuted**: `IsSidon.perfect_iff` of cycle 2 reduces perfection to the
  cardinality equation `#A² - #A = |G| - 1`, i.e. `p² - p = 2p² - 1`, which fails for
  every `p ≥ 1` since `p² + p = 1` has no solution.  So the optimistic reading is false
  and the gap in cycle 3 is on the *construction* side.
Analysis (Analyst): this is exactly the payoff of having proved a rigidity theorem: a
  question about the geometry of a specific set ("does it hit every difference?") was
  decided by a one-line arithmetic identity.  The refutation also localises the next
  target — a perfect difference set must live in a group of order `k² - k + 1`, which
  `2p²` never is, so a genuinely different construction (Singer's) is required.
Critique (Critic): `etSetZMod_not_perfect` is a negative statement and therefore cannot
  be vacuous; it is proved by deriving a false numeric identity, not by exploiting a
  contradictory hypothesis.  The two invariance theorems are stated as `↔`, so neither
  direction is assumed.  The dilation theorem needs `u` to be a unit — for a non-unit the
  image can collapse and the statement is false.
Synthesis (PI): Sidon-ness is affine-invariant; the Erdős–Turán construction is
  provably not extremal in its own cyclic group; perfection requires order `k² - k + 1`.
-/

open Finset


section Symmetry
variable {M : Type*} [AddCancelCommMonoid M] [DecidableEq M]

/-- **Translation invariance.**  Sidon-ness is unchanged by translating the set. -/
theorem isSidon_image_add_right (A : Finset M) (t : M) :
    IsSidon (A.image (· + t)) ↔ IsSidon A := by
  constructor
  · intro h a ha b hb c hc d hd hsum
    have hmem : ∀ {x : M}, x ∈ A → x + t ∈ A.image (· + t) := fun hx =>
      Finset.mem_image.mpr ⟨_, hx, rfl⟩
    have hsum' : (a + t) + (b + t) = (c + t) + (d + t) := by
      rw [show (a + t) + (b + t) = (a + b) + (t + t) by abel,
        show (c + t) + (d + t) = (c + d) + (t + t) by abel, hsum]
    rcases h _ (hmem ha) _ (hmem hb) _ (hmem hc) _ (hmem hd) hsum' with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨add_right_cancel h1, add_right_cancel h2⟩
    · exact Or.inr ⟨add_right_cancel h1, add_right_cancel h2⟩
  · intro h a ha b hb c hc d hd hsum
    simp only [Finset.mem_image] at ha hb hc hd
    obtain ⟨a', ha', rfl⟩ := ha
    obtain ⟨b', hb', rfl⟩ := hb
    obtain ⟨c', hc', rfl⟩ := hc
    obtain ⟨d', hd', rfl⟩ := hd
    have hsum' : a' + b' = c' + d' := by
      have : (a' + b') + (t + t) = (c' + d') + (t + t) := by
        rw [show (a' + b') + (t + t) = (a' + t) + (b' + t) by abel,
          show (c' + d') + (t + t) = (c' + t) + (d' + t) by abel]
        exact hsum
      exact add_right_cancel this
    rcases h a' ha' b' hb' c' hc' d' hd' hsum' with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨by rw [h1], by rw [h2]⟩
    · exact Or.inr ⟨by rw [h1], by rw [h2]⟩

end Symmetry

section Dilation
variable {R : Type*} [CommRing R] [DecidableEq R]

/-- **Dilation invariance.**  Sidon-ness is unchanged by multiplying the set by a unit. -/
theorem isSidon_image_unit_mul (A : Finset R) (u : Rˣ) :
    IsSidon (A.image (fun a => (u : R) * a)) ↔ IsSidon A := by
  have hcancel : ∀ x y : R, (u : R) * x = (u : R) * y → x = y := by
    intro x y h
    have := congrArg (fun z => (↑u⁻¹ : R) * z) h
    simpa [← mul_assoc] using this
  constructor
  · intro h a ha b hb c hc d hd hsum
    have hmem : ∀ {x : R}, x ∈ A → (u : R) * x ∈ A.image (fun a => (u : R) * a) := fun hx =>
      Finset.mem_image.mpr ⟨_, hx, rfl⟩
    have hsum' : (u : R) * a + (u : R) * b = (u : R) * c + (u : R) * d := by
      rw [← mul_add, ← mul_add, hsum]
    rcases h _ (hmem ha) _ (hmem hb) _ (hmem hc) _ (hmem hd) hsum' with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨hcancel _ _ h1, hcancel _ _ h2⟩
    · exact Or.inr ⟨hcancel _ _ h1, hcancel _ _ h2⟩
  · intro h a ha b hb c hc d hd hsum
    simp only [Finset.mem_image] at ha hb hc hd
    obtain ⟨a', ha', rfl⟩ := ha
    obtain ⟨b', hb', rfl⟩ := hb
    obtain ⟨c', hc', rfl⟩ := hc
    obtain ⟨d', hd', rfl⟩ := hd
    have hsum' : a' + b' = c' + d' := by
      refine hcancel _ _ ?_
      rw [mul_add, mul_add]
      exact hsum
    rcases h a' ha' b' hb' c' hc' d' hd' hsum' with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨by rw [h1], by rw [h2]⟩
    · exact Or.inr ⟨by rw [h1], by rw [h2]⟩

end Dilation

/-- **The Erdős–Turán set is never a perfect difference set.**  Its `p² - p` differences
fall short of the `2p² - 1` nonzero elements of `ZMod (2p²)`, so by the rigidity theorem
`IsSidon.perfect_iff` it never attains the Sidon bound in its own cyclic group. -/
theorem etSetZMod_not_perfect {p : ℕ} (hp : p.Prime) (hodd : p ≠ 2) :
    haveI : NeZero (2 * p ^ 2) := ⟨by have := hp.pos; positivity⟩
    diffSet (ErdosTuran.etSetZMod p) ≠ Finset.univ.erase 0 := by
  have hp0 : 0 < p := hp.pos
  haveI : NeZero (2 * p ^ 2) := ⟨by positivity⟩
  intro hperf
  have hA : IsSidon (ErdosTuran.etSetZMod p) := ErdosTuran.etSetZMod_isSidon hp hodd
  have hcard : #(ErdosTuran.etSetZMod p) = p := ErdosTuran.etSetZMod_card hp0
  have h := hA.perfect_iff.mp hperf
  rw [hcard, ZMod.card] at h
  have hp3 : 3 ≤ p := by have := hp.two_le; omega
  rw [sq] at h
  have hple : p ≤ p * p := Nat.le_mul_of_pos_left p hp0
  obtain ⟨q, hq⟩ : ∃ q, p * p = q := ⟨_, rfl⟩
  rw [hq] at h hple
  omega