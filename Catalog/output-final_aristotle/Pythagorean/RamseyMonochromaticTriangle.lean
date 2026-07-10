import Mathlib

/-!
# The Ramsey threshold `R(3,3) ≤ 6` and its genetic-code reading

Ramsey's classical theorem asserts that any red/blue colouring of the edges of the
complete graph on six vertices contains a monochromatic triangle.  In the language
of genetic codes, if six loci are pairwise compared under a binary similarity
relation ("same class" vs. "different class"), then three of the loci are forced to
be mutually consistent — a *forced motif* that no arrangement can avoid.

We model a symmetric two-colouring by a function `c : Fin 6 → Fin 6 → Bool` with
`c i j = c j i`.  The theorem produces three distinct vertices whose three
connecting edges all carry the same colour.

## Main results

* `three_same_color_among_five` — the local pigeonhole step: among five edges
  coloured with two colours, three share a colour.
* `ramsey_R33` — every symmetric two-colouring of `K₆` has a monochromatic
  triangle.
-/

namespace DNARamsey

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  Binary pairwise comparison of six objects cannot avoid a
monochromatic triangle; this is the smallest genuinely forced Ramsey motif and it
should follow from two nested pigeonhole steps.

**Experiment.**  Fix a vertex `v`.  It has five incident edges coloured by two
colours, so (pigeonhole) three of them, to neighbours `a b d`, share a colour `x`.
If any edge among `a b d` is also coloured `x`, that edge closes an `x`-triangle
with `v`; otherwise all three edges among `a b d` carry the opposite colour and
`{a,b,d}` is itself a monochromatic triangle.

**Analysis.**  The proof is a clean two-level pigeonhole and needs no case explosion
beyond the boolean dichotomy on the inner triangle.  It is the exact combinatorial
core of `R(3,3) = 6`.

**Critique.**  The statement quantifies over *all* symmetric colourings (a space of
size `2^15`), so it is a real universal theorem rather than a single finite check;
the proof is structural pigeonhole, not brute enumeration.

**Synthesis.**  Combined with the block-repetition thresholds in
`SubsequenceMerAvoidance`, this gives a two-sided picture of forced structure in
symbolic sequences: repeats are forced along a line (pigeonhole on windows) and
monochromatic motifs are forced in pairwise comparison (Ramsey).
-/

/-
**Local pigeonhole.**  Among the five edge-colours `f : Fin 5 → Bool` there is a
colour `x` and three distinct indices all coloured `x`.
-/
theorem three_same_color_among_five (f : Fin 5 → Bool) :
    ∃ (x : Bool) (a b d : Fin 5), a ≠ b ∧ a ≠ d ∧ b ≠ d ∧
      f a = x ∧ f b = x ∧ f d = x := by
  revert f; decide

/--
**Ramsey's theorem `R(3,3) ≤ 6`.**  Any symmetric two-colouring of the complete
graph on six vertices contains a monochromatic triangle: three distinct vertices
whose three connecting edges share a colour.
-/
theorem ramsey_R33 (c : Fin 6 → Fin 6 → Bool) (hsymm : ∀ i j, c i j = c j i) :
    ∃ a b d : Fin 6, a ≠ b ∧ a ≠ d ∧ b ≠ d ∧
      c a b = c a d ∧ c a d = c b d := by
  by_contra! h_contra;
  obtain ⟨x, hx⟩ : ∃ x : Bool, ∃ a b d : Fin 5, a ≠ b ∧ a ≠ d ∧ b ≠ d ∧ c 0 (Fin.succ a) = x ∧ c 0 (Fin.succ b) = x ∧ c 0 (Fin.succ d) = x := by
    have := three_same_color_among_five ( fun k => c 0 ( Fin.succ k ) ) ; aesop;
  obtain ⟨ a, b, d, hab, had, hbd, ha, hb, hd ⟩ := hx;
  cases h : c ( Fin.succ a ) ( Fin.succ b ) <;> cases h' : c ( Fin.succ a ) ( Fin.succ d ) <;> cases h'' : c ( Fin.succ b ) ( Fin.succ d ) <;> simp_all +decide only;
  all_goals have := h_contra ( Fin.succ a ) ( Fin.succ b ) ( Fin.succ d ) ; simp_all +decide ;
  all_goals have := h_contra ( Fin.succ a ) ( Fin.succ b ) 0; have := h_contra ( Fin.succ a ) ( Fin.succ d ) 0; have := h_contra ( Fin.succ b ) ( Fin.succ d ) 0; simp_all +decide ;

end DNARamsey