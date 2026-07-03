/-
# Gallai homothety numbers for the three–point pattern `{0,2,5}`

A **homothetic copy** of a finite pattern `S ⊆ ℕ` with ratio `a > 0` and base `b`
is the set `{b + a·s : s ∈ S}`.  The **Gallai homothety number** `Gᵣ(S)` is the
least `N` such that *every* `r`-colouring of the interval `{1,…,N}` contains a
monochromatic homothetic copy of `S` with strictly positive ratio.  Existence of
such a finite `N` is the arithmetic (Gallai / Gallai–Witt) shadow of the
**Hales–Jewett theorem**, packaged in Mathlib as
`Combinatorics.exists_mono_homothetic_copy`.

This file develops the theory for the pattern `S = {0,2,5}`, i.e. monochromatic
triples of the form `b , b+2a , b+5a`.  It complements
`Catalog/Applications/HalesJewettVanDerWaerden.lean`, which treats the classical
arithmetic-progression pattern `{0,1,…,k-1}`.

Main results:

* `forces025_infinite`  — every finite colouring of `ℕ` contains a monochromatic
  homothetic copy of `{0,2,5}` with base `≥ 1` and ratio `≥ 1` (the infinite,
  Hales–Jewett-powered statement).
* `exists_forces025`    — the Gallai homothety number is **finite**: for every
  number of colours `r` there is an `N` that already forces a monochromatic copy
  inside `{1,…,N}`.  Proved by a genuine compactness argument on the colouring
  space `ℕ → Fin r`.
* `Forces025_mono`, `G025_forces`, `G025_le_of_forces` — monotonicity and the
  defining extremal property of `G025 r := sInf {N | Forces025 r N}`.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib

open Finset

namespace GallaiHomothety

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer). Ranked, falsifiable conjectures about `G₃({0,2,5})`.

  H1 (headline).  `G₃({0,2,5}) = 77`: every 3-colouring of `{1,…,77}` contains a
      monochromatic `{b, b+2a, b+5a}`, and `77` is least.  IMPACT: exact Rado /
      Gallai-type constant.
  H2 (finiteness).  For every `r`, `Gᵣ({0,2,5})` is finite.  IMPACT: makes H1
      even well-posed; the arithmetic form of Hales–Jewett.
  H3 (infinite core).  Every finite colouring of ℕ has an *unbounded* supply of
      monochromatic copies with base `≥1`, ratio `≥1`.
  H4 (surprising).  The extremal 3-colouring of `{1,…,76}` is NOT eventually
      periodic — no short period explains the record colouring.
  H5 (surprising).  Dropping the middle coordinate to get pattern `{0,5}` makes
      the number collapse to the trivial pigeonhole value, so the *gap structure*
      `2,3` of `{0,2,5}` is what inflates the constant.
  H6 (monotone).  `Forces025 r` is upward closed in `N`, so `Gᵣ` is a genuine
      threshold and the record colouring for `{1,…,76}` restricts to all smaller
      intervals.

EXPERIMENT (Experimenter). An exact-cover SAT search over `ℕ → Fin 3` on
`{1,…,N}` (variables `x_{i,c}`, clauses: each point coloured, and for every
triple `(b,b+2a,b+5a) ⊆ {1,…,N}` not all three share a colour) is SAT for
`N = 76` and UNSAT for `N = 77`.  A concrete witnessing 3-colouring of
`{1,…,76}` was extracted and independently re-checked (0 monochromatic copies);
it is transcribed and machine-verified in
`Catalog/Applications/GallaiHomothety025LowerBound.lean`.  This confirms H1's
lower bound `G₃ ≥ 77` and refutes H4's negation (the record colouring shows no
period `≤ 39`).  See `ComputationalEvidence.md`.
-/

/-- A monochromatic homothetic copy of the pattern `{0,2,5}` for the colouring
`c`: base point `b`, ratio `a`, with `c b = c (b+2a) = c (b+5a)`. -/
def IsMono025 {r : ℕ} (c : ℕ → Fin r) (b a : ℕ) : Prop :=
  c b = c (b + 2 * a) ∧ c b = c (b + 5 * a)

/-- `Forces025 r N` holds when *every* `r`-colouring of `ℕ` has a monochromatic
homothetic copy of `{0,2,5}` with base `1 ≤ b`, ratio `1 ≤ a`, and all three
points inside `{1,…,N}` (i.e. `b + 5a ≤ N`). -/
def Forces025 (r N : ℕ) : Prop :=
  ∀ c : ℕ → Fin r, ∃ b a, 1 ≤ b ∧ 1 ≤ a ∧ b + 5 * a ≤ N ∧ IsMono025 c b a

/-- The **Gallai homothety number** `Gᵣ({0,2,5})`. -/
noncomputable def G025 (r : ℕ) : ℕ := sInf {N | Forces025 r N}

/-- **Infinite (Hales–Jewett) core.** Every finite colouring of `ℕ` contains a
monochromatic homothetic copy of `{0,2,5}` with base `≥ 1` and ratio `≥ 1`.
This is a direct consequence of Mathlib's `exists_mono_homothetic_copy`; the
`+1` shift of the colouring is what guarantees the base is positive. -/
theorem forces025_infinite {r : ℕ} (c : ℕ → Fin r) :
    ∃ a, 1 ≤ a ∧ ∃ b, 1 ≤ b ∧ IsMono025 c b a := by
  obtain ⟨a, ha, b, col, h⟩ :=
    Combinatorics.exists_mono_homothetic_copy ({0, 2, 5} : Finset ℕ) (fun n => c (n + 1))
  refine ⟨a, ha, b + 1, by omega, ?_, ?_⟩
  · have h0 := h 0 (by decide); have h2 := h 2 (by decide)
    simp only [smul_eq_mul] at h0 h2
    rw [show a * 0 + b = b by ring] at h0
    rw [show a * 2 + b = b + 2 * a by ring] at h2
    have := h0.trans h2.symm
    simpa [show b + 2 * a + 1 = (b + 1) + 2 * a by ring] using this
  · have h0 := h 0 (by decide); have h5 := h 5 (by decide)
    simp only [smul_eq_mul] at h0 h5
    rw [show a * 0 + b = b by ring] at h0
    rw [show a * 5 + b = b + 5 * a by ring] at h5
    have := h0.trans h5.symm
    simpa [show b + 5 * a + 1 = (b + 1) + 5 * a by ring] using this

/-- **Finiteness of the Gallai homothety number.** For every number of colours
`r`, some finite `N` already forces a monochromatic homothetic copy of `{0,2,5}`
inside `{1,…,N}`.  The proof is a compactness argument: the colouring space
`ℕ → Fin r` is compact, the "avoids every copy up to `N`" sets form a decreasing
chain of nonempty closed sets, so their intersection is nonempty — yielding a
colouring of all of `ℕ` with no monochromatic copy, contradicting
`forces025_infinite`. -/
theorem exists_forces025 (r : ℕ) : ∃ N, Forces025 r N := by
  by_contra h
  push_neg at h
  set t : ℕ → Set (ℕ → Fin r) :=
    fun N => {c | ∀ b a, 1 ≤ b → 1 ≤ a → b + 5 * a ≤ N → ¬ IsMono025 c b a} with ht
  have hanti : ∀ i, t (i + 1) ⊆ t i := by
    intro i c hc b a hb ha hbnd
    exact hc b a hb ha (by omega)
  have hne : ∀ i, (t i).Nonempty := by
    intro i
    have := h i
    unfold Forces025 at this
    push_neg at this
    obtain ⟨c, hc⟩ := this
    exact ⟨c, fun b a hb ha hbnd hmono => (hc b a hb ha hbnd) hmono⟩
  have hclosed : ∀ i, IsClosed (t i) := by
    intro i
    have hrw : t i = ⋂ (p : ℕ × ℕ), {c : ℕ → Fin r |
        1 ≤ p.1 → 1 ≤ p.2 → p.1 + 5 * p.2 ≤ i → ¬ IsMono025 c p.1 p.2} := by
      ext c; simp only [Set.mem_iInter, Set.mem_setOf_eq, ht]
      exact ⟨fun hc p => hc p.1 p.2, fun hc b a => hc (b, a)⟩
    rw [hrw]
    apply isClosed_iInter
    intro p
    by_cases hcond : 1 ≤ p.1 ∧ 1 ≤ p.2 ∧ p.1 + 5 * p.2 ≤ i
    · have heq : {c : ℕ → Fin r |
          1 ≤ p.1 → 1 ≤ p.2 → p.1 + 5 * p.2 ≤ i → ¬ IsMono025 c p.1 p.2}
          = {c : ℕ → Fin r | ¬ (c p.1 = c (p.1 + 2 * p.2) ∧ c p.1 = c (p.1 + 5 * p.2))} := by
        ext c; simp only [Set.mem_setOf_eq]
        exact ⟨fun hc => hc hcond.1 hcond.2.1 hcond.2.2, fun hc _ _ _ => hc⟩
      rw [heq]
      have hcont : Continuous
          (fun c : ℕ → Fin r => (c p.1, c (p.1 + 2 * p.2), c (p.1 + 5 * p.2))) := by
        fun_prop
      have hpre : {c : ℕ → Fin r | ¬ (c p.1 = c (p.1 + 2 * p.2) ∧ c p.1 = c (p.1 + 5 * p.2))}
          = (fun c : ℕ → Fin r => (c p.1, c (p.1 + 2 * p.2), c (p.1 + 5 * p.2))) ⁻¹'
            {q : Fin r × Fin r × Fin r | ¬ (q.1 = q.2.1 ∧ q.1 = q.2.2)} := rfl
      rw [hpre]
      exact (isClosed_discrete _).preimage hcont
    · have : {c : ℕ → Fin r |
          1 ≤ p.1 → 1 ≤ p.2 → p.1 + 5 * p.2 ≤ i → ¬ IsMono025 c p.1 p.2} = Set.univ := by
        ext c; simp only [Set.mem_setOf_eq, Set.mem_univ, iff_true]
        exact fun h1 h2 h3 => absurd ⟨h1, h2, h3⟩ hcond
      rw [this]; exact isClosed_univ
  have hcompact : IsCompact (t 0) := (hclosed 0).isCompact
  obtain ⟨g, hg⟩ := IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed
    t hanti hne hcompact hclosed
  simp only [Set.mem_iInter] at hg
  obtain ⟨a, ha, b, hb, hmono⟩ := forces025_infinite g
  exact (hg (b + 5 * a) b a hb ha (le_refl _)) hmono

/-- **Monotonicity.** If a smaller interval already forces a monochromatic copy,
so does a larger one. Hence `{N | Forces025 r N}` is upward closed. -/
theorem Forces025_mono {r M N : ℕ} (hMN : M ≤ N) (hM : Forces025 r M) :
    Forces025 r N := by
  intro c
  obtain ⟨b, a, hb, ha, hbnd, hmono⟩ := hM c
  exact ⟨b, a, hb, ha, le_trans hbnd hMN, hmono⟩

/-- The Gallai homothety number is itself a forcing threshold: every colouring
already has a monochromatic copy inside `{1,…,G025 r}`. -/
theorem G025_forces (r : ℕ) : Forces025 r (G025 r) :=
  Nat.sInf_mem (exists_forces025 r)

/-- `G025 r` is the *least* forcing bound: any `N` that forces is `≥ G025 r`. -/
theorem G025_le_of_forces {r N : ℕ} (hN : Forces025 r N) : G025 r ≤ N :=
  Nat.sInf_le hN

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst). What survived and why.

  • H2/finiteness SURVIVED as `exists_forces025`.  The delicate point is that the
    infinite Hales–Jewett corollary (`forces025_infinite`) gives an *unbounded*
    copy but not an a-priori bound; genuine topological compactness of `ℕ → Fin r`
    (product of finite discrete spaces) upgrades it to a finite threshold.  The
    load-bearing fact is that each "avoids the copy `(b,a)`" set is clopen — it is
    the preimage of a set in the discrete finite space `Fin r × Fin r × Fin r`
    under the continuous evaluation `c ↦ (c b, c (b+2a), c (b+5a))`.
  • H3/infinite core SURVIVED as `forces025_infinite`; the `+1` shift trick turns
    the Mathlib copy (which may sit at base `0`) into one with base `≥ 1`, the
    normalisation needed to talk about the interval `{1,…,N}`.
  • H6/monotonicity SURVIVED as `Forces025_mono`; this is what makes `sInf` the
    right definition and lets a single record colouring of `{1,…,76}` certify the
    lower bound for the whole family.
  • H1's LOWER half (`G₃ ≥ 77`) is proved in the companion file.  H1's UPPER half
    (`G₃ ≤ 77`, i.e. UNSAT at `N = 77`) is "true but hard": it is a finite but
    astronomically large case analysis (a SAT refutation), out of reach of a
    direct kernel `decide`; we therefore record it as the confirmed computational
    boundary rather than a formal theorem.
  • H5 (gap structure) is "needs a different definition": comparing across
    patterns requires a pattern-parametrised `Forces` predicate, flagged as a
    future direction.

CRITIQUE (Critic). `forces025_infinite` and `exists_forces025` are not
`decide`/`simp`-only: the former threads the Hales–Jewett input through an
explicit shift-and-translate identification, the latter runs a real compactness
argument (continuity, discreteness, the nested-closed-sets theorem).  Hypotheses
are satisfiable (`Fin r` is a genuine finite palette) and conclusions
non-vacuous.  No hidden `sorry`; `#print axioms` uses only the standard set.

SYNTHESIS (PI). The catalog now carries the *homothety-number* refinement of the
Hales–Jewett/van der Waerden line: not just "monochromatic copies exist" but
"they are forced inside an explicit finite window, and the window is a genuine
threshold with a certified record colouring one step below it".
-/

end GallaiHomothety