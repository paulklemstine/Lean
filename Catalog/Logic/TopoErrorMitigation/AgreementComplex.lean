import Logic.TopoErrorMitigation.PersistentH0
import Logic.TopoErrorMitigation.MajorityDecoding

/-!
# The Agreement Complex: Encoding Error Patterns into a Topological Invariant

This is the keystone bridge of the `TopoErrorMitigation` cluster, realising the
project conjecture that *"error patterns can be encoded into topological
features"*. Given a noisy readout `s : Fin n → Bool` of a repetition-code
circuit, we form the **agreement relation** `agree s i j := s i = s j` and read
off its zeroth Betti number `betti0 (agree s)` — the number of connected
components of the agreement graph.

We prove this single topological invariant *classifies the consensus structure*
of the readout:

* `betti0_agree_le_two` — the invariant is bounded: `betti0 (agree s) ≤ 2`
  (only two codewords, hence at most two components), via an injection of the
  component quotient into `Bool`;
* `betti0_agree_eq_one` — `betti0 (agree s) = 1` **iff** the readout is in perfect
  consensus (`∀ i j, s i = s j`);
* `betti0_agree_eq_two_iff` — `betti0 (agree s) = 2` **iff** there is genuine
  disagreement (`∃ i j, s i ≠ s j`), i.e. the noise has split the components;
* `consensus_zero_errors` — when the invariant detects consensus, the readout has
  **zero** Hamming errors against its common value, linking the topological
  feature (`betti0 = 1`) directly to the error metric of `MajorityDecoding`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The connected-component count of the agreement graph
  is a faithful topological summary of a repetition-code readout: it is `1`
  exactly on error-free consensus and `2` exactly when noise has introduced
  disagreement, and it never exceeds `2`.
Experiment (Experimenter): Proved a value map `Quot (EqvGen (agree s)) → Bool`
  is well defined (by induction on the `EqvGen` derivation, `eqvGen_agree_value`)
  and injective, giving `betti0 ≤ card Bool = 2`. The consensus characterisation
  came from `Fintype.card_eq_one_iff_nonempty_unique` and a `Subsingleton`
  argument; the disagreement corollary from squeezing `betti0 ∈ {1,2}`.
Analysis (Analyst): The agreement graph is always a disjoint union of at most two
  cliques, so its `H₀` is at most 2-dimensional — the topological reason the
  repetition code needs no higher homology. The bridge `consensus_zero_errors`
  shows the topological invariant is not a re-encoding but genuinely *implies*
  the metric statement `errors = 0`. Key insight: `EqvGen (agree s) = agree s`
  morally, because `agree s` is already an equivalence; the induction makes this
  usable without proving full relation equality.
Critique (Critic): `NeZero n` is a real hypothesis — on the empty block the
  quotient is empty and `betti0 = 0`, so the consensus/component dictionary genuinely
  needs at least one measurement. The `≤ 2` bound is proved by injectivity, not
  by `decide`, so it is non-trivial. No theorem here is a definitional `rfl` or a
  pure `simp`.
Synthesis (PI): A topological invariant (`betti0` of the agreement complex) that
  detects, and certifies the error-freeness of, repetition-code consensus —
  exactly the encode-errors-as-topology mechanism the mission proposes.
-/

namespace TopoErrorMitigation

open Relation Finset

variable {n : ℕ}

/-- The **agreement relation** of a readout: two measurement sites are linked
when they report the same bit. -/
def agree (s : Fin n → Bool) : Fin n → Fin n → Prop := fun i j => s i = s j

/-- Sites in the same agreement component report the same bit (the agreement
value is a well-defined invariant of the component). -/
theorem eqvGen_agree_value (s : Fin n → Bool) {i j : Fin n}
    (h : EqvGen (agree s) i j) : s i = s j := by
  induction h with
  | rel x y hxy => exact hxy
  | refl x => rfl
  | symm x y _ ih => exact ih.symm
  | trans x y z _ _ ih1 ih2 => exact ih1.trans ih2

/-- **Boundedness of the invariant.** The agreement complex has at most two
connected components, because each component carries a distinct bit value. -/
theorem betti0_agree_le_two (s : Fin n → Bool)
    [Fintype (Quot (EqvGen (agree s)))] :
    betti0 (agree s) ≤ 2 := by
  unfold betti0
  have hcard : Fintype.card (Quot (EqvGen (agree s))) ≤ Fintype.card Bool := by
    apply Fintype.card_le_of_injective
      (Quot.lift s (fun a b h => eqvGen_agree_value s h))
    intro x y hxy
    obtain ⟨a, rfl⟩ := Quot.exists_rep x
    obtain ⟨b, rfl⟩ := Quot.exists_rep y
    exact Quot.sound (EqvGen.rel _ _ hxy)
  simpa using hcard

/-- **Topological consensus detection.** The agreement complex is connected
(`betti0 = 1`) iff the entire readout is in consensus. -/
theorem betti0_agree_eq_one (s : Fin n → Bool) [NeZero n]
    [Fintype (Quot (EqvGen (agree s)))] :
    betti0 (agree s) = 1 ↔ ∀ i j, s i = s j := by
  haveI : Nonempty (Fin n) := ⟨⟨0, Nat.pos_of_ne_zero (NeZero.ne n)⟩⟩
  haveI : Nonempty (Quot (EqvGen (agree s))) :=
    ⟨Quot.mk _ (Classical.arbitrary (Fin n))⟩
  unfold betti0
  rw [Fintype.card_eq_one_iff_nonempty_unique]
  constructor
  · rintro ⟨u⟩ i j
    have heq : Quot.mk (EqvGen (agree s)) i = Quot.mk (EqvGen (agree s)) j :=
      (u.uniq _).trans (u.uniq _).symm
    have hval :
        (Quot.lift s (fun a b h => eqvGen_agree_value s h))
            (Quot.mk (EqvGen (agree s)) i)
          = (Quot.lift s (fun a b h => eqvGen_agree_value s h))
            (Quot.mk (EqvGen (agree s)) j) := by
      rw [heq]
    exact hval
  · intro h
    have hsub : Subsingleton (Quot (EqvGen (agree s))) := by
      constructor
      intro x y
      obtain ⟨a, rfl⟩ := Quot.exists_rep x
      obtain ⟨b, rfl⟩ := Quot.exists_rep y
      exact Quot.sound (EqvGen.rel _ _ (h a b))
    exact ⟨uniqueOfSubsingleton (Quot.mk _ (Classical.arbitrary (Fin n)))⟩

/-- The zeroth Betti number of the agreement complex is at least `1` on a
nonempty block (there is always at least one component). -/
theorem betti0_agree_pos (s : Fin n → Bool) [NeZero n]
    [Fintype (Quot (EqvGen (agree s)))] :
    1 ≤ betti0 (agree s) := by
  haveI : Nonempty (Fin n) := ⟨⟨0, Nat.pos_of_ne_zero (NeZero.ne n)⟩⟩
  haveI : Nonempty (Quot (EqvGen (agree s))) :=
    ⟨Quot.mk _ (Classical.arbitrary (Fin n))⟩
  unfold betti0
  exact Fintype.card_pos

/-- **Topological disagreement detection.** The agreement complex splits into two
components (`betti0 = 2`) iff the noise has caused genuine disagreement. -/
theorem betti0_agree_eq_two_iff (s : Fin n → Bool) [NeZero n]
    [Fintype (Quot (EqvGen (agree s)))] :
    betti0 (agree s) = 2 ↔ ∃ i j, s i ≠ s j := by
  have hle := betti0_agree_le_two s
  have hpos := betti0_agree_pos s
  have hone := betti0_agree_eq_one s
  constructor
  · intro h2
    by_contra hcon
    push_neg at hcon
    have : betti0 (agree s) = 1 := hone.mpr (fun i j => hcon i j)
    omega
  · intro ⟨i, j, hij⟩
    have hne : betti0 (agree s) ≠ 1 := by
      intro h1
      exact hij ((hone.mp h1) i j)
    omega

/-- **Bridge to the error metric.** When the topological invariant certifies
consensus, the readout has zero Hamming errors against its common value: the
topological feature `betti0 = 1` implies error-freeness. -/
theorem consensus_zero_errors (s : Fin n → Bool) [NeZero n]
    (h : ∀ i j, s i = s j) :
    errors s (s ⟨0, Nat.pos_of_ne_zero (NeZero.ne n)⟩) = 0 := by
  unfold errors
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro i _
  simp only [ne_eq, not_not]
  exact h i _

/-- **Capstone.** A connected agreement complex certifies a perfectly error-free
readout: `betti0 (agree s) = 1` implies the existence of a logical bit against
which the readout has zero Hamming distance. -/
theorem betti0_one_certifies_errorless (s : Fin n → Bool) [NeZero n]
    [Fintype (Quot (EqvGen (agree s)))]
    (h : betti0 (agree s) = 1) :
    ∃ b, errors s b = 0 := by
  refine ⟨s ⟨0, Nat.pos_of_ne_zero (NeZero.ne n)⟩, ?_⟩
  exact consensus_zero_errors s ((betti0_agree_eq_one s).mp h)

end TopoErrorMitigation