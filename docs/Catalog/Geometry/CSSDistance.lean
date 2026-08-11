import Geometry.CSSDictionary

/-!
# CSS distance: Hamming weight, logical operators, and `min(systole, cosystole)`

This file carries out **future target 3** of the research thread.  The previous
cycle computed the *girth* of the hypercube graph and warned that girth is not
the quantum distance; but no notion of CSS distance existed in the catalog, so
the warning could not be made precise.  Here we define it.

For a commuting pair of binary parity-check matrices `H_X, H_Z` on `N` physical
qubits (see `Catalog/Geometry/CSSDictionary.lean`):

* `wt a` — Hamming weight of a binary cochain, `wtPair p` — weight of a Pauli
  operator `p = (a, b)` (the size of the union of the two supports);
* `XLogical`/`ZLogical` — the *nontrivial undetectable* single-type errors, i.e.
  representatives of nonzero homology (resp. cohomology) classes;
* `dX`/`dZ` — the primal and dual logical distances (systole and cosystole);
* `Undetectable` — errors commuting with every stabilizer, and `cssDistance` —
  the minimum weight of an undetectable error outside the stabilizer group.

The main theorem `cssDistance_eq_min` is the standard
`d = min(systole, cosystole)` statement, proved under explicit nondegeneracy
hypotheses (`hX`, `hZ`: both logical sets are nonempty, i.e. the code really has
`X`- and `Z`-logicals).  Its proof needs the structural lemma
`stab_eq_prod`: the stabilizer group is the *product* `rowSpace H_X × rowSpace H_Z`
of the two trivial-operator subspaces.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  A general undetectable Pauli error mixes `X` and `Z`
parts, so a priori the code distance could be *strictly smaller* than both
single-type distances.  We conjecture it cannot: the weight of a mixed error
dominates the weight of each of its parts, and nontriviality of the pair forces
nontriviality of at least one part.

EXPERIMENT (Experimenter).  Formalised with `Nat.sInf` over weight sets.  The
key step is `stab_eq_prod`, proved by writing `Hᵀ *ᵥ y` as the row combination
`∑ i, y i • H i` and using `Submodule.sum_mem` in both directions.

ANALYSIS (Analyst).  The two nondegeneracy hypotheses are genuinely needed:
`Nat.sInf ∅ = 0`, so without them the theorem would silently degenerate.  With
them the infimum is attained (`Nat.sInf_mem`), which is what makes the `≥`
direction work.

CRITIQUE (Critic).  `cssDistance` is defined by an operational condition
("undetectable but not a stabilizer"), *not* as `min dX dZ`; the theorem is
therefore not definitional.  A mixed error is allowed in the competition, and
the proof must genuinely rule out that it beats both single-type distances.
-/

namespace HQECC
namespace CSSDistance

open Matrix Module CSSDictionary

variable {mx mz N : Type*} [Fintype mx] [Fintype mz] [Fintype N] [DecidableEq N]

/-! ## Hamming weight -/

/-- The Hamming weight of a binary cochain. -/
def wt (a : N → ZMod 2) : ℕ := (Finset.univ.filter (fun i => a i ≠ 0)).card

/-- The weight of a phase-free Pauli operator `p = (a, b)`: the number of
qubits on which it acts nontrivially. -/
def wtPair (p : (N → ZMod 2) × (N → ZMod 2)) : ℕ :=
  ((Finset.univ.filter (fun i => p.1 i ≠ 0)) ∪
    (Finset.univ.filter (fun i => p.2 i ≠ 0))).card

lemma wt_le_wtPair_left (p : (N → ZMod 2) × (N → ZMod 2)) : wt p.1 ≤ wtPair p :=
  Finset.card_le_card Finset.subset_union_left

lemma wt_le_wtPair_right (p : (N → ZMod 2) × (N → ZMod 2)) : wt p.2 ≤ wtPair p :=
  Finset.card_le_card Finset.subset_union_right

@[simp] lemma wtPair_left (a : N → ZMod 2) : wtPair (a, 0) = wt a := by
  simp [wtPair, wt]

@[simp] lemma wtPair_right (b : N → ZMod 2) : wtPair (0, b) = wt b := by
  simp [wtPair, wt]

omit [DecidableEq N] in
lemma wt_eq_zero_iff {a : N → ZMod 2} : wt a = 0 ↔ a = 0 := by
  constructor
  · intro h
    have hempty := Finset.card_eq_zero.1 h
    ext i
    by_contra hi
    have : i ∈ Finset.univ.filter (fun i => a i ≠ 0) :=
      Finset.mem_filter.2 ⟨Finset.mem_univ i, by simpa using hi⟩
    rw [hempty] at this
    exact absurd this (Finset.notMem_empty i)
  · rintro rfl; simp [wt]

lemma wtPair_pos {p : (N → ZMod 2) × (N → ZMod 2)} (hp : p ≠ 0) : 0 < wtPair p := by
  rcases Nat.eq_zero_or_pos (wtPair p) with h | h
  · exfalso
    have h1 : wt p.1 = 0 := Nat.le_zero.1 (h ▸ wt_le_wtPair_left p)
    have h2 : wt p.2 = 0 := Nat.le_zero.1 (h ▸ wt_le_wtPair_right p)
    exact hp (Prod.ext (wt_eq_zero_iff.1 h1) (wt_eq_zero_iff.1 h2))
  · exact h

/-! ## Logical operators -/

variable (Hx : Matrix mx N (ZMod 2)) (Hz : Matrix mz N (ZMod 2))

/-- A nontrivial undetectable `X`-type error: it commutes with all `Z`-checks
(`H_Z a = 0`) but is not a product of `X`-stabilizers. -/
def XLogical (a : N → ZMod 2) : Prop := Hz *ᵥ a = 0 ∧ a ∉ rowSpace Hx

/-- A nontrivial undetectable `Z`-type error. -/
def ZLogical (b : N → ZMod 2) : Prop := Hx *ᵥ b = 0 ∧ b ∉ rowSpace Hz

/-- The **primal distance** (systole): least weight of a nontrivial
undetectable `X`-error. -/
noncomputable def dX : ℕ := sInf {w | ∃ a, XLogical Hx Hz a ∧ wt a = w}

/-- The **dual distance** (cosystole): least weight of a nontrivial
undetectable `Z`-error. -/
noncomputable def dZ : ℕ := sInf {w | ∃ b, ZLogical Hx Hz b ∧ wt b = w}

/-- A Pauli error is **undetectable** when it commutes with every stabilizer
generator: its `X`-part passes the `Z`-checks and its `Z`-part the `X`-checks. -/
def Undetectable (p : (N → ZMod 2) × (N → ZMod 2)) : Prop :=
  Hz *ᵥ p.1 = 0 ∧ Hx *ᵥ p.2 = 0

/-- The **CSS distance**: least weight of an undetectable error that is not a
stabilizer.  This is the operational quantity; it is *not* defined as a minimum
of the two single-type distances. -/
noncomputable def cssDistance : ℕ :=
  sInf {w | ∃ p, Undetectable Hx Hz p ∧ p ∉ stab Hx Hz ∧ wtPair p = w}

/-! ## The stabilizer group is a product of row spaces -/

omit [Fintype N] [DecidableEq N] in
/-- `Hᵀ *ᵥ y` is the row combination `∑ i, y i • H i`. -/
lemma transpose_mulVec_eq_sum (H : Matrix mx N (ZMod 2)) (y : mx → ZMod 2) :
    Hᵀ *ᵥ y = ∑ i, y i • H i := by
  funext j
  simp [Matrix.mulVec, dotProduct, Finset.sum_apply, mul_comm]

omit [Fintype N] [DecidableEq N] in
/-- **The stabilizer group is `rowSpace H_X × rowSpace H_Z`.**  Consequently an
error `(a, b)` is a *nontrivial* logical operator exactly when `a` fails to be a
product of `X`-stabilizers or `b` fails to be a product of `Z`-stabilizers. -/
theorem stab_eq_prod :
    stab Hx Hz = (rowSpace Hx).prod (rowSpace Hz) := by
  classical
  apply le_antisymm
  · rw [stab, Submodule.span_le]
    rintro p (⟨i, rfl⟩ | ⟨j, rfl⟩)
    · refine ⟨?_, Submodule.zero_mem _⟩
      refine ⟨Pi.single i 1, ?_⟩
      rw [Matrix.mulVecLin_apply, transpose_mulVec_eq_sum]
      simp [Pi.single_apply, Finset.sum_ite_eq']
    · refine ⟨Submodule.zero_mem _, ?_⟩
      refine ⟨Pi.single j 1, ?_⟩
      rw [Matrix.mulVecLin_apply, transpose_mulVec_eq_sum]
      simp [Pi.single_apply, Finset.sum_ite_eq']
  · rintro ⟨a, b⟩ ⟨⟨y, hy⟩, ⟨z, hz⟩⟩
    have ha : ((a, (0 : N → ZMod 2)) : (N → ZMod 2) × (N → ZMod 2)) ∈ stab Hx Hz := by
      rw [Matrix.mulVecLin_apply, transpose_mulVec_eq_sum] at hy
      subst hy
      have : ((∑ i, y i • Hx i, (0 : N → ZMod 2)) : (N → ZMod 2) × (N → ZMod 2)) =
          ∑ i, y i • ((Hx i, (0 : N → ZMod 2)) : (N → ZMod 2) × (N → ZMod 2)) := by
        simp [Prod.ext_iff, Prod.fst_sum, Prod.snd_sum]
      rw [this]
      exact Submodule.sum_mem _ (fun i _ =>
        Submodule.smul_mem _ _ (Submodule.subset_span (Or.inl ⟨i, rfl⟩)))
    have hb : (((0 : N → ZMod 2), b) : (N → ZMod 2) × (N → ZMod 2)) ∈ stab Hx Hz := by
      rw [Matrix.mulVecLin_apply, transpose_mulVec_eq_sum] at hz
      subst hz
      have : (((0 : N → ZMod 2), ∑ j, z j • Hz j) : (N → ZMod 2) × (N → ZMod 2)) =
          ∑ j, z j • (((0 : N → ZMod 2), Hz j) : (N → ZMod 2) × (N → ZMod 2)) := by
        simp [Prod.ext_iff, Prod.fst_sum, Prod.snd_sum]
      rw [this]
      exact Submodule.sum_mem _ (fun j _ =>
        Submodule.smul_mem _ _ (Submodule.subset_span (Or.inr ⟨j, rfl⟩)))
    have := Submodule.add_mem _ ha hb
    simpa using this

omit [Fintype N] [DecidableEq N] in
/-- Membership in the stabilizer group is componentwise. -/
lemma mem_stab_iff {p : (N → ZMod 2) × (N → ZMod 2)} :
    p ∈ stab Hx Hz ↔ p.1 ∈ rowSpace Hx ∧ p.2 ∈ rowSpace Hz := by
  rw [stab_eq_prod]
  exact Submodule.mem_prod

/-! ## `d = min(systole, cosystole)` -/

/-- A minimal-weight `X`-logical, paired with the identity `Z`-part, is an
undetectable nonstabilizer error of weight `dX`. -/
lemma cssDistance_le_dX (hX : {w | ∃ a, XLogical Hx Hz a ∧ wt a = w}.Nonempty) :
    cssDistance Hx Hz ≤ dX Hx Hz := by
  obtain ⟨a, ha, hwa⟩ := Nat.sInf_mem hX
  refine Nat.sInf_le ⟨(a, 0), ⟨ha.1, by simp⟩, ?_, by simpa using hwa⟩
  rw [mem_stab_iff]
  rintro ⟨h1, -⟩
  exact ha.2 h1

/-- Dual version of `cssDistance_le_dX`. -/
lemma cssDistance_le_dZ (hZ : {w | ∃ b, ZLogical Hx Hz b ∧ wt b = w}.Nonempty) :
    cssDistance Hx Hz ≤ dZ Hx Hz := by
  obtain ⟨b, hb, hwb⟩ := Nat.sInf_mem hZ
  refine Nat.sInf_le ⟨(0, b), ⟨by simp, hb.1⟩, ?_, by simpa using hwb⟩
  rw [mem_stab_iff]
  rintro ⟨-, h2⟩
  exact hb.2 h2

/-- **The CSS distance theorem.**  Under the nondegeneracy hypotheses that both
kinds of logical operator exist, the operational distance of the code equals
`min(systole, cosystole)`.  In particular the primal quantity alone (for a graph
code: the girth) is *not* the distance. -/
theorem cssDistance_eq_min
    (hX : {w | ∃ a, XLogical Hx Hz a ∧ wt a = w}.Nonempty)
    (hZ : {w | ∃ b, ZLogical Hx Hz b ∧ wt b = w}.Nonempty) :
    cssDistance Hx Hz = min (dX Hx Hz) (dZ Hx Hz) := by
  apply le_antisymm
  · exact le_min (cssDistance_le_dX Hx Hz hX) (cssDistance_le_dZ Hx Hz hZ)
  · have hne : {w | ∃ p, Undetectable Hx Hz p ∧ p ∉ stab Hx Hz ∧ wtPair p = w}.Nonempty := by
      obtain ⟨a, ha, hwa⟩ := Nat.sInf_mem hX
      refine ⟨wt a, (a, 0), ⟨ha.1, by simp⟩, ?_, by simp⟩
      rw [mem_stab_iff]
      rintro ⟨h1, -⟩
      exact ha.2 h1
    obtain ⟨p, hund, hstab, hwp⟩ := Nat.sInf_mem hne
    rw [mem_stab_iff] at hstab
    rw [not_and_or] at hstab
    rcases hstab with h1 | h2
    · have hXlog : XLogical Hx Hz p.1 := ⟨hund.1, h1⟩
      have : dX Hx Hz ≤ wt p.1 := Nat.sInf_le ⟨p.1, hXlog, rfl⟩
      calc min (dX Hx Hz) (dZ Hx Hz) ≤ dX Hx Hz := min_le_left _ _
        _ ≤ wt p.1 := this
        _ ≤ wtPair p := wt_le_wtPair_left p
        _ = cssDistance Hx Hz := hwp
    · have hZlog : ZLogical Hx Hz p.2 := ⟨hund.2, h2⟩
      have : dZ Hx Hz ≤ wt p.2 := Nat.sInf_le ⟨p.2, hZlog, rfl⟩
      calc min (dX Hx Hz) (dZ Hx Hz) ≤ dZ Hx Hz := min_le_right _ _
        _ ≤ wt p.2 := this
        _ ≤ wtPair p := wt_le_wtPair_right p
        _ = cssDistance Hx Hz := hwp

omit [Fintype mx] [Fintype mz] in
/-- The distance is at least `1` whenever some undetectable nonstabilizer error
exists: a weight-`0` error is the identity, which is a stabilizer. -/
theorem one_le_cssDistance
    (hne : {w | ∃ p, Undetectable Hx Hz p ∧ p ∉ stab Hx Hz ∧ wtPair p = w}.Nonempty) :
    1 ≤ cssDistance Hx Hz := by
  obtain ⟨p, -, hstab, hwp⟩ := Nat.sInf_mem hne
  have hp : p ≠ 0 := by
    rintro rfl
    exact hstab (Submodule.zero_mem _)
  exact le_of_le_of_eq (wtPair_pos hp) hwp

end CSSDistance
end HQECC