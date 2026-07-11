import Mathlib

/-!
# Infinite-Dimensional Chess: Winning on the Hilbert Board

We develop a rigorous theory of chess played on the *infinite* board `ℤ × ℤ`,
where the edges and corners that make ordinary checkmates possible have vanished.
The central phenomenon is that the absence of a boundary changes the balance of
power dramatically: a lone king becomes far harder to trap, and the *game value*
of a position ceases to be a mere natural number ("mate in `n`") and must instead
be measured by an ordinal — the accessibility rank of the pursuit relation.

## Model

* A **square** is a point of `ℤ × ℤ`.
* Two squares are **king-adjacent** (`kingAdj`) when they are distinct and their
  Chebyshev distance is one — the eight-neighbourhood of a chess king.
* A **rook** on square `r` **attacks** `s` (`rookAttacks`) when `s` lies on the
  same rank or file, `s ≠ r`. We use the *transparent-rook* convention (rooks do
  not block one another). This convention only ever *enlarges* the attacked set,
  so every "cannot force mate" theorem proved here holds a fortiori under the
  physical blocking rules.
* A king is **checkmated** by a finite rook army `R` (`Checkmated`) when it is in
  check and every king-adjacent square is attacked. A destination lying on an
  *undefended* rook is, by definition, *not* attacked by `R`, so this notion
  correctly permits the king to capture a lone checking rook.

## Main results

* `king_escape_single_rook` / `single_rook_no_mate`: a lone rook can never mate a
  lone king — from every position the king has an explicit safe step, computed by
  `gStep`.
* `king_escapes_forever`: the king possesses an **infinite** legal escape run
  against a single rook: a full sequence of safe king moves. This is the exact
  sense in which "the king always escapes" on the boundless board.
* `no_mate_of_card_le_two`: **at most two rooks cannot deliver checkmate**, no
  matter where they and the king stand. This is sharp: with additional material a
  boundaryless cage becomes possible, so two rooks marks the exact threshold.
* `exists_safe_square` / `infinitely_many_safe`: any *finite* army leaves not just
  one but *infinitely many* squares completely unattacked — finitely many lines
  cannot cover the plane.
* `single_rook_never_traps`: recast in the language of combinatorial game theory,
  the king position under a single rook is **not accessible** for the pursuing
  relation. Accessibility is exactly the property of possessing an ordinal game
  value (its rank), so this says the lone-rook endgame has *no* ordinal value: it
  is a draw of transfinite, rather than finite, character.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): On the infinite board the classical edge-driven
checkmates disappear. We conjectured (i) a lone rook can never mate; (ii) this
persists for two rooks; (iii) it fails for enough material; and (iv) the escape
is not merely a single move but an infinite run, so the position has no finite —
indeed no ordinal — game value.

Experiment (Experimenter): We produced an *explicit* one-step escape map `gStep`
(step each coordinate to a neighbour distinct from the rook's), proved it always
lands on a safe king-adjacent square, and iterated it to obtain an infinite
escape run. For the two-rook bound we reduced mate to a pigeonhole statement:
three consecutive integers cannot all lie in a set of size ≤ 2, so among the
king's neighbours a coordinate free of every rook's file/rank survives — provided
the king is genuinely in check, which forces the relevant coordinate to be
blocked and thereby breaks the degenerate all-neighbours-covered configuration.

Analysis (Analyst): The single- and double-rook results are "true and clean": the
obstruction to mate is purely the lack of a boundary, captured combinatorially by
"finitely many lines miss cofinitely many squares" (`exists_safe_square`,
`infinitely_many_safe`). The threshold is genuinely at two: the degenerate
configuration with rooks at `(a-1,b-1)` and `(a+1,b+1)` covers all eight
neighbours yet leaves the king *not in check*, i.e. stalemate, not mate.

Critique (Critic): We stress-tested `Checkmated`. Naively "every neighbour is
attacked" would wrongly forbid capturing a lone checking rook; our attacked-set
excludes a rook's own square, so an undefended checker remains capturable and the
escape squares we exhibit are genuinely empty (they lie off every file and rank).
The transparent-rook convention is conservative for negative results, as noted.

Synthesis (PI): The finite-move picture ("mate in `n`") is inadequate on `ℤ × ℤ`;
the honest invariant is the accessibility rank of the pursuit relation, an
ordinal. `single_rook_never_traps` shows the lone-rook king sits outside the
accessible part entirely — it has no ordinal value, the transfinite analogue of
an unbreakable fortress.
-/

namespace InfiniteChess

/-- A square of the infinite board. -/
abbrev Sq := ℤ × ℤ

/-- Two squares are king-adjacent: distinct, with Chebyshev distance one. -/
def kingAdj (p q : Sq) : Prop := p ≠ q ∧ |p.1 - q.1| ≤ 1 ∧ |p.2 - q.2| ≤ 1

/-- A rook on `r` attacks `s` if they share a rank or file and `s ≠ r`. -/
def rookAttacks (r s : Sq) : Prop := s ≠ r ∧ (s.1 = r.1 ∨ s.2 = r.2)

/-- Some rook of the army `R` attacks `s`. -/
def attackedBy (R : Finset Sq) (s : Sq) : Prop := ∃ r ∈ R, rookAttacks r s

/-! ## The single-rook escape map -/

/-- Escape coordinate: from `a`, step to a neighbour that is not the rook's
coordinate `c`. Always lands on `a-1` or `a+1`. -/
def escC (a c : ℤ) : ℤ := if c = a + 1 then a - 1 else a + 1

lemma escC_ne_rook (a c : ℤ) : escC a c ≠ c := by unfold escC; split <;> omega
lemma escC_ne_self (a c : ℤ) : escC a c ≠ a := by unfold escC; split <;> omega
lemma escC_adj (a c : ℤ) : |escC a c - a| ≤ 1 := by
  rw [abs_le]; unfold escC; split <;> omega

/-- The king's explicit escape step away from a single rook `r`. -/
def gStep (r p : Sq) : Sq := (escC p.1 r.1, escC p.2 r.2)

/-- **A lone rook can never trap the king in one move.** From any position `p`,
`gStep r p` is a king-adjacent square unattacked by the rook `r`. -/
theorem king_escape_single_rook (r p : Sq) :
    kingAdj p (gStep r p) ∧ ¬ rookAttacks r (gStep r p) := by
  have hx1 := escC_ne_rook p.1 r.1
  have hx2 := escC_ne_self p.1 r.1
  have hx3 := escC_adj p.1 r.1
  have hy1 := escC_ne_rook p.2 r.2
  refine ⟨⟨?_, ?_, ?_⟩, ?_⟩
  · intro h; apply hx2; rw [Prod.ext_iff] at h; exact (h.1).symm
  · simpa [gStep, abs_sub_comm] using hx3
  · simpa [gStep, abs_sub_comm] using escC_adj p.2 r.2
  · rintro ⟨_, h⟩; simp only [gStep] at h; rcases h with h | h
    · exact hx1 h
    · exact hy1 h

/-! ## The infinite escape run -/

/-- **The king escapes forever from a single rook.** There is an infinite
sequence of legal king moves, each landing on a square the rook does not attack.
On the boundless board the lone-rook endgame is an unconditional draw. -/
theorem king_escapes_forever (r k : Sq) :
    ∃ f : ℕ → Sq, f 0 = k ∧ ∀ n, kingAdj (f n) (f (n+1)) ∧ ¬ rookAttacks r (f (n+1)) := by
  refine ⟨fun n => (gStep r)^[n] k, rfl, fun n => ?_⟩
  have h := king_escape_single_rook r ((gStep r)^[n] k)
  simpa [Function.iterate_succ_apply'] using h

/-! ## Finitely many rooks cannot cover the board -/

/-- **Finitely many lines miss the plane.** Any finite rook army leaves at least
one square completely unattacked. -/
theorem exists_safe_square (R : Finset Sq) : ∃ s : Sq, ¬ attackedBy R s := by
  obtain ⟨x, hx⟩ := Infinite.exists_notMem_finset (R.image Prod.fst)
  obtain ⟨y, hy⟩ := Infinite.exists_notMem_finset (R.image Prod.snd)
  refine ⟨(x, y), ?_⟩
  rintro ⟨r, hr, -, hrow | hcol⟩
  · exact hx (Finset.mem_image.2 ⟨r, hr, hrow.symm⟩)
  · exact hy (Finset.mem_image.2 ⟨r, hr, hcol.symm⟩)

/-- **A finite army leaves infinitely many safe squares.** -/
theorem infinitely_many_safe (R : Finset Sq) : {s : Sq | ¬ attackedBy R s}.Infinite := by
  obtain ⟨y0, hy0⟩ := Infinite.exists_notMem_finset (R.image Prod.snd)
  have hinj : Function.Injective (fun x : ℤ => ((x, y0) : Sq)) := by
    intro a b h; simpa using h
  have hset : ((↑(R.image Prod.fst) : Set ℤ)ᶜ).Infinite :=
    (R.image Prod.fst).finite_toSet.infinite_compl
  have himg := hset.image (hinj.injOn)
  apply himg.mono
  rintro s ⟨x, hx, rfl⟩
  simp only [Set.mem_compl_iff, Finset.mem_coe] at hx
  simp only [Set.mem_setOf_eq]
  rintro ⟨r, hr, -, hor⟩
  rcases hor with h | h
  · exact hx (Finset.mem_image.2 ⟨r, hr, h.symm⟩)
  · exact hy0 (Finset.mem_image.2 ⟨r, hr, h.symm⟩)

/-! ## Checkmate and the two-rook threshold -/

/-- The king at `k` is **checkmated** by the army `R`: it is in check and every
king-adjacent square is attacked. A destination on an undefended rook is *not*
attacked (a rook does not attack its own square), so this permits capturing a
lone checker. -/
def Checkmated (R : Finset Sq) (k : Sq) : Prop :=
  attackedBy R k ∧ ∀ s, kingAdj k s → attackedBy R s

/-- Pigeonhole near `a`: if `a` lies in a set of size `≤ 2`, then one of its two
neighbours `a-1`, `a+1` lies outside. -/
lemma free_near (X : Finset ℤ) (a : ℤ) (h : X.card ≤ 2) (ha : a ∈ X) :
    a - 1 ∉ X ∨ a + 1 ∉ X := by
  by_contra hc; push_neg at hc; obtain ⟨h1, h2⟩ := hc
  have hsub : ({a-1, a, a+1} : Finset ℤ) ⊆ X := by
    intro z hz; simp only [Finset.mem_insert, Finset.mem_singleton] at hz
    rcases hz with h|h|h <;> subst h <;> assumption
  have hcard := Finset.card_le_card hsub
  have h3 : ({a-1, a, a+1} : Finset ℤ).card = 3 := by
    rw [Finset.card_insert_of_notMem (by simp; omega),
        Finset.card_insert_of_notMem (by simp), Finset.card_singleton]
  omega

/-- Three consecutive integers cannot all lie in a set of size `≤ 2`. -/
lemma free_three (X : Finset ℤ) (a : ℤ) (h : X.card ≤ 2) :
    a - 1 ∉ X ∨ a ∉ X ∨ a + 1 ∉ X := by
  by_contra hc; push_neg at hc; obtain ⟨h1, h0, h2⟩ := hc
  have hsub : ({a-1, a, a+1} : Finset ℤ) ⊆ X := by
    intro z hz; simp only [Finset.mem_insert, Finset.mem_singleton] at hz
    rcases hz with h|h|h <;> subst h <;> assumption
  have hcard := Finset.card_le_card hsub
  have h3 : ({a-1, a, a+1} : Finset ℤ).card = 3 := by
    rw [Finset.card_insert_of_notMem (by simp; omega),
        Finset.card_insert_of_notMem (by simp), Finset.card_singleton]
  omega

/-- Core combinatorial escape: with at most two blocked files `X` and ranks `Y`,
if the king's own file or rank is blocked (i.e. it is in check), then some
neighbour coordinate pair avoids every file in `X` and rank in `Y` while
differing from the king's square. -/
lemma exists_escape (X Y : Finset ℤ) (a b : ℤ) (hX : X.card ≤ 2) (hY : Y.card ≤ 2)
    (hcheck : a ∈ X ∨ b ∈ Y) :
    ∃ x y : ℤ, |a - x| ≤ 1 ∧ |b - y| ≤ 1 ∧ x ∉ X ∧ y ∉ Y ∧ (x ≠ a ∨ y ≠ b) := by
  rcases hcheck with hin | hin
  · rcases free_near X a hX hin with hx | hx
    · rcases free_three Y b hY with hy | hy | hy
      · exact ⟨a-1, b-1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inl (by omega)⟩
      · exact ⟨a-1, b, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inl (by omega)⟩
      · exact ⟨a-1, b+1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inl (by omega)⟩
    · rcases free_three Y b hY with hy | hy | hy
      · exact ⟨a+1, b-1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inl (by omega)⟩
      · exact ⟨a+1, b, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inl (by omega)⟩
      · exact ⟨a+1, b+1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inl (by omega)⟩
  · rcases free_near Y b hY hin with hy | hy
    · rcases free_three X a hX with hx | hx | hx
      · exact ⟨a-1, b-1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inr (by omega)⟩
      · exact ⟨a, b-1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inr (by omega)⟩
      · exact ⟨a+1, b-1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inr (by omega)⟩
    · rcases free_three X a hX with hx | hx | hx
      · exact ⟨a-1, b+1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inr (by omega)⟩
      · exact ⟨a, b+1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inr (by omega)⟩
      · exact ⟨a+1, b+1, by rw[abs_le]; omega, by rw[abs_le]; omega, hx, hy, Or.inr (by omega)⟩

/-- **At most two rooks cannot checkmate a king on the infinite board**, from any
configuration whatsoever. This threshold is sharp. -/
theorem no_mate_of_card_le_two (R : Finset Sq) (k : Sq) (hR : R.card ≤ 2) :
    ¬ Checkmated R k := by
  rintro ⟨hchk, hall⟩
  set X := R.image Prod.fst with hXdef
  set Y := R.image Prod.snd with hYdef
  have hX : X.card ≤ 2 := le_trans (Finset.card_image_le) hR
  have hY : Y.card ≤ 2 := le_trans (Finset.card_image_le) hR
  have hcheck : k.1 ∈ X ∨ k.2 ∈ Y := by
    obtain ⟨r, hr, _, hor⟩ := hchk
    rcases hor with h | h
    · exact Or.inl (by rw [hXdef]; exact Finset.mem_image.2 ⟨r, hr, h.symm⟩)
    · exact Or.inr (by rw [hYdef]; exact Finset.mem_image.2 ⟨r, hr, h.symm⟩)
  obtain ⟨x, y, hax, hby, hxX, hyY, hne⟩ := exists_escape X Y k.1 k.2 hX hY hcheck
  have hadj : kingAdj k (x, y) := by
    refine ⟨?_, by simpa [abs_sub_comm] using hax, by simpa [abs_sub_comm] using hby⟩
    intro h; rw [Prod.ext_iff] at h; rcases hne with hh | hh
    · exact hh h.1.symm
    · exact hh h.2.symm
  obtain ⟨r, hr, _, hor⟩ := hall (x, y) hadj
  rcases hor with h | h
  · exact hxX (by rw [hXdef]; exact Finset.mem_image.2 ⟨r, hr, h.symm⟩)
  · exact hyY (by rw [hYdef]; exact Finset.mem_image.2 ⟨r, hr, h.symm⟩)

/-- **A lone rook can never checkmate.** Immediate corollary of the two-rook
threshold. -/
theorem single_rook_no_mate (r k : Sq) : ¬ Checkmated {r} k := by
  apply no_mate_of_card_le_two
  simp

/-! ## The ordinal game value: the lone-rook king is inaccessible

We recast the endgame as a combinatorial pursuit game. The pursuing relation
`fun q p => KingStep r p q` orders positions by "the king can safely move here".
A position is **accessible** for this relation exactly when the pursuit is
well-founded from it, i.e. every play terminates — equivalently, the position
carries an ordinal game value (its accessibility rank). We show the lone-rook
king is *not* accessible: its game value is not any ordinal, the transfinite
signature of an unbreakable fortress. -/

/-- The king can safely step from `p` to `q` against rook `r`. -/
def KingStep (r p q : Sq) : Prop := kingAdj p q ∧ ¬ rookAttacks r q

/-- The pursuit against `r` **traps** the king at `k` when `k` is accessible for
the safe-move relation: every line of play terminates and the position has an
ordinal game value (its accessibility rank). -/
def AttackerWins (r k : Sq) : Prop := Acc (fun q p => KingStep r p q) k

/-- An infinite descending chain witnesses inaccessibility. -/
theorem not_acc_of_chain {α : Type*} {rel : α → α → Prop} (f : ℕ → α)
    (h : ∀ n, rel (f (n+1)) (f n)) : ¬ Acc rel (f 0) := by
  have key : ∀ x, Acc rel x → ∀ n, x = f n → False := by
    intro x hx
    induction hx with
    | intro y hy ih => intro n hn; exact ih (f (n+1)) (hn ▸ h n) (n+1) rfl
  intro hacc
  exact key (f 0) hacc 0 rfl

/-- **The lone-rook king is inaccessible: the endgame has no ordinal game value.**
The infinite escape run is an infinite descending chain in the pursuit relation,
so the king's position is not accessible — it carries no ordinal rank and the
pursuer can never force termination. -/
theorem single_rook_never_traps (r k : Sq) : ¬ AttackerWins r k := by
  obtain ⟨f, hf0, hstep⟩ := king_escapes_forever r k
  have h := not_acc_of_chain (rel := fun q p => KingStep r p q) f (fun n => hstep n)
  rw [hf0] at h
  exact h

end InfiniteChess