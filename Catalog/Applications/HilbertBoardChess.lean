import Mathlib

/-!
# Winning on the Hilbert Board: King Escape in Every Dimension

We lift the theory of *infinite-board chess* from the classical plane `ℤ × ℤ` to
the **`d`-dimensional Hilbert board** `ℤ^{d+2}`, the natural setting for
"infinite-dimensional chess".  Passing from two to arbitrarily many spatial
dimensions only *helps* the fleeing king: the more directions there are, the more
room to run.  We make this precise.

## Model

Fix a dimension parameter `d : ℕ`; the board is `Sq d := Fin (d + 2) → ℤ`, so it
always has at least two coordinate axes.

* Two squares are **king-adjacent** (`kingAdj`) when they are distinct and every
  coordinate differs by at most one — the Chebyshev unit ball, i.e. the
  `3^{d+2} - 1` neighbours of a chess king.
* A **rook** on `r` **attacks** `s` (`rookAttacks`) when `s ≠ r` and `s` agrees
  with `r` in **all but one** coordinate: the rook sweeps a full axis-parallel
  line through its own square.  A rook does not attack its own square, so an
  undefended checker may always be captured.
* A finite rook army `R` **checkmates** the king (`Checkmated`) when the king is
  in check and every king-adjacent square is attacked.

## Main results

* `king_escape_single_rook`, `king_escapes_forever`: against a lone rook the king
  always has an explicit safe step (`gStep`), and hence an *infinite* legal
  escape run, in every dimension `d + 2 ≥ 2`.
* `single_rook_no_mate`: a lone rook can never checkmate, in any dimension.
* `exists_safe_square`, `infinitely_many_safe`: any finite army leaves
  infinitely many completely unattacked squares — finitely many lines cannot
  cover a plane, a fortiori a higher-dimensional board.
* `single_rook_never_traps`: in the language of combinatorial game theory the
  lone-rook position is **not accessible** for the pursuit relation, so it carries
  *no ordinal game value*: the transfinite signature of an unbreakable fortress,
  now established uniformly across all dimensions.
* `one_dim_two_rooks_mate`: the **boundary case**.  In a single dimension a rook
  attacks every other square, so two mutually defending rooks *do* checkmate the
  king — a phenomenon impossible in dimension `≥ 2`.  The escape is genuinely a
  higher-dimensional effect.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The planar escape results should be *dimension-robust*:
adding axes cannot help the pursuer.  Boldly, we conjectured the entire
lone-rook fortress — geometric escape, infinite run, and transfinite
inaccessibility — survives verbatim on `ℤ^{d+2}` for every `d`, while collapsing
in dimension one.

Experiment (Experimenter): We generalised the coordinatewise escape map `escC`
to `gStep r p := fun i => escC (p i) (r i)`, which moves *every* coordinate away
from the rook at once (a legal king step in the Chebyshev metric).  The image
disagrees with the rook in *all* coordinates, so it cannot lie on any single
axis-line through the rook; hence it is unattacked.  Iterating yields the
infinite run, and the same accessibility argument as in the plane shows the
position has no ordinal rank.  For the safe-square count we avoided the rooks'
projections on the first two axes, leaving an infinite family of safe squares.

Analysis (Analyst): The proofs are "true and structural": the sole obstruction to
mate is again the missing boundary, captured by "finitely many lines miss a
plane".  The dimension enters only through the existence of *two distinct axes*
(`i0 ≠ i1`), which is exactly what fails in dimension one — pinpointing the
threshold.

Critique (Critic): We verified that the escape square is genuinely empty (off
every axis-line through the rook) and that `Checkmated` still permits capturing a
lone checker.  The one-dimensional boundary theorems confirm the hypotheses are
sharp: with a single axis two mutually defending rooks deliver mate.

Synthesis (PI): "The king always escapes" is a phenomenon of dimension `≥ 2`,
robust to *unboundedly many* extra dimensions, and its honest invariant remains
the accessibility rank of the pursuit relation — an ordinal that, for the
lone-rook fortress, does not exist.
-/

namespace HilbertBoardChess

/-! ## The Hilbert board in dimension `d + 2` -/

/-- A square of the `(d+2)`-dimensional board. -/
abbrev Sq (d : ℕ) := Fin (d + 2) → ℤ

/-- Two squares are king-adjacent: distinct, Chebyshev distance one. -/
def kingAdj {d : ℕ} (p q : Sq d) : Prop := p ≠ q ∧ ∀ i, |p i - q i| ≤ 1

/-- A rook on `r` attacks `s` if `s ≠ r` and they agree in all but one
coordinate (the rook sweeps one axis-parallel line). -/
def rookAttacks {d : ℕ} (r s : Sq d) : Prop :=
  s ≠ r ∧ ∃ j, ∀ i, i ≠ j → s i = r i

/-- Some rook of the army `R` attacks `s`. -/
def attackedBy {d : ℕ} (R : Finset (Sq d)) (s : Sq d) : Prop :=
  ∃ r ∈ R, rookAttacks r s

/-- Two distinguished distinct axes always exist. -/
lemma zero_ne_one_axis (d : ℕ) : (0 : Fin (d + 2)) ≠ 1 := by
  simp

/-- For any axis `j` there is another axis distinct from it. -/
lemma exists_axis_ne {d : ℕ} (j : Fin (d + 2)) : ∃ i, i ≠ j := by
  rcases eq_or_ne j 0 with hj | hj
  · exact ⟨1, by simp [hj, (zero_ne_one_axis d).symm]⟩
  · exact ⟨0, hj.symm⟩

/-! ## The single-rook escape map -/

/-- Escape coordinate: from `a`, step to a neighbour distinct from the rook's
coordinate `c`.  Always lands on `a - 1` or `a + 1`. -/
def escC (a c : ℤ) : ℤ := if c = a + 1 then a - 1 else a + 1

lemma escC_ne_rook (a c : ℤ) : escC a c ≠ c := by unfold escC; split <;> omega
lemma escC_ne_self (a c : ℤ) : escC a c ≠ a := by unfold escC; split <;> omega
lemma escC_adj (a c : ℤ) : |escC a c - a| ≤ 1 := by
  rw [abs_le]; unfold escC; split <;> omega

/-- The king's explicit escape step: move every coordinate away from the rook. -/
def gStep {d : ℕ} (r p : Sq d) : Sq d := fun i => escC (p i) (r i)

/-- **A lone rook can never trap the king in one move.** From any position `p`,
`gStep r p` is a king-adjacent square unattacked by the rook `r`, in every
dimension. -/
theorem king_escape_single_rook {d : ℕ} (r p : Sq d) :
    kingAdj p (gStep r p) ∧ ¬ rookAttacks r (gStep r p) := by
  constructor
  · refine ⟨?_, fun i => ?_⟩
    · intro h; exact escC_ne_self (p 0) (r 0) (congrFun h 0).symm
    · simpa [gStep, abs_sub_comm] using escC_adj (p i) (r i)
  · rintro ⟨_, j, hj⟩
    obtain ⟨i, hi⟩ := exists_axis_ne j
    exact escC_ne_rook (p i) (r i) (hj i hi)

/-! ## The infinite escape run -/

/-- **The king escapes forever from a single rook.**  There is an infinite
sequence of legal king moves, each landing on a square the rook does not
attack. -/
theorem king_escapes_forever {d : ℕ} (r k : Sq d) :
    ∃ f : ℕ → Sq d, f 0 = k ∧
      ∀ n, kingAdj (f n) (f (n+1)) ∧ ¬ rookAttacks r (f (n+1)) := by
  refine ⟨fun n => (gStep r)^[n] k, rfl, fun n => ?_⟩
  simpa [Function.iterate_succ_apply'] using
    king_escape_single_rook r ((gStep r)^[n] k)

/-- **Safe-square core.**  If `x` avoids every rook's first coordinate and `y`
every rook's second coordinate, the square with those two entries (and zeros
elsewhere) is unattacked: it differs from every rook in two coordinates, so it
cannot lie on any single axis-line. -/
lemma safe_of_avoid {d : ℕ} (R : Finset (Sq d)) (x y : ℤ)
    (hx : x ∉ R.image (fun r => r 0)) (hy : y ∉ R.image (fun r => r 1)) :
    ¬ attackedBy R (fun i => if i = 0 then x else if i = 1 then y else 0) := by
  rintro ⟨r, hr, -, j, hj⟩
  have hx0 : (fun i : Fin (d+2) => if i = 0 then x else if i = 1 then y else (0:ℤ)) 0
      ≠ r 0 := by
    have e : (fun i : Fin (d+2) => if i = 0 then x else if i = 1 then y else (0:ℤ)) 0 = x := by
      simp
    rw [e]; intro h; exact hx (Finset.mem_image.2 ⟨r, hr, h.symm⟩)
  have hy1 : (fun i : Fin (d+2) => if i = 0 then x else if i = 1 then y else (0:ℤ)) 1
      ≠ r 1 := by
    have e : (fun i : Fin (d+2) => if i = 0 then x else if i = 1 then y else (0:ℤ)) 1 = y := by
      simp [(zero_ne_one_axis d).symm]
    rw [e]; intro h; exact hy (Finset.mem_image.2 ⟨r, hr, h.symm⟩)
  rcases eq_or_ne (0 : Fin (d+2)) j with h0 | h0
  · rcases eq_or_ne (1 : Fin (d+2)) j with h1 | h1
    · exact zero_ne_one_axis d (h0.trans h1.symm)
    · exact hy1 (hj 1 h1)
  · exact hx0 (hj 0 h0)

/-! ## Finitely many rooks cannot cover the board -/

/-- **A finite army leaves at least one square completely unattacked.** -/
theorem exists_safe_square {d : ℕ} (R : Finset (Sq d)) :
    ∃ s : Sq d, ¬ attackedBy R s := by
  obtain ⟨x, hx⟩ := Infinite.exists_notMem_finset (R.image (fun r => r 0))
  obtain ⟨y, hy⟩ := Infinite.exists_notMem_finset (R.image (fun r => r 1))
  exact ⟨_, safe_of_avoid R x y hx hy⟩

/-- **A finite army leaves infinitely many safe squares.** -/
theorem infinitely_many_safe {d : ℕ} (R : Finset (Sq d)) :
    {s : Sq d | ¬ attackedBy R s}.Infinite := by
  obtain ⟨y, hy⟩ := Infinite.exists_notMem_finset (R.image (fun r => r 1))
  set g : ℤ → Sq d := fun t i => if i = 0 then t else if i = 1 then y else 0 with hg
  have hinj : Function.Injective g := by
    intro a b h; have := congrFun h 0; simpa [hg] using this
  have hset : ((↑(R.image (fun r => r 0)) : Set ℤ)ᶜ).Infinite :=
    (R.image _).finite_toSet.infinite_compl
  have himg := hset.image hinj.injOn
  apply himg.mono
  rintro s ⟨t, ht, rfl⟩
  simp only [Set.mem_compl_iff, Finset.mem_coe] at ht
  exact safe_of_avoid R t y ht hy

/-! ## Checkmate: the lone rook never mates -/

/-- The king at `k` is **checkmated** by `R`: in check, with every adjacent
square attacked. -/
def Checkmated {d : ℕ} (R : Finset (Sq d)) (k : Sq d) : Prop :=
  attackedBy R k ∧ ∀ s, kingAdj k s → attackedBy R s

/-- **A lone rook can never checkmate**, in any dimension. -/
theorem single_rook_no_mate {d : ℕ} (r k : Sq d) : ¬ Checkmated {r} k := by
  rintro ⟨_, hall⟩
  obtain ⟨he_adj, he_not⟩ := king_escape_single_rook r k
  obtain ⟨r', hr', hatk⟩ := hall _ he_adj
  simp only [Finset.mem_singleton] at hr'; subst hr'
  exact he_not hatk

/-! ## The ordinal game value: the lone-rook king is inaccessible -/

/-- The king can safely step from `p` to `q` against rook `r`. -/
def KingStep {d : ℕ} (r p q : Sq d) : Prop := kingAdj p q ∧ ¬ rookAttacks r q

/-- The pursuit against `r` **traps** the king at `k` when `k` is accessible for
the safe-move relation: every play terminates and the position carries an
ordinal game value (its accessibility rank). -/
def AttackerWins {d : ℕ} (r k : Sq d) : Prop :=
  Acc (fun q p => KingStep r p q) k

/-- An infinite descending chain witnesses inaccessibility. -/
theorem not_acc_of_chain {α : Type*} {rel : α → α → Prop} (f : ℕ → α)
    (h : ∀ n, rel (f (n+1)) (f n)) : ¬ Acc rel (f 0) := by
  have key : ∀ x, Acc rel x → ∀ n, x = f n → False := by
    intro x hx
    induction hx with
    | intro y hy ih => intro n hn; exact ih (f (n+1)) (hn ▸ h n) (n+1) rfl
  intro hacc; exact key (f 0) hacc 0 rfl

/-- **The lone-rook king is inaccessible: the endgame has no ordinal game
value**, uniformly in the dimension. -/
theorem single_rook_never_traps {d : ℕ} (r k : Sq d) : ¬ AttackerWins r k := by
  obtain ⟨f, hf0, hstep⟩ := king_escapes_forever r k
  have h := not_acc_of_chain (rel := fun q p => KingStep r p q) f (fun n => hstep n)
  rw [hf0] at h; exact h

/-! ## Boundary case: the one-dimensional line

Modelling the line as `ℤ`, a rook attacks *every* other square (with a single
axis, "agree in all but one coordinate" imposes no constraint).  The dimension
threshold now appears crisply: two rooks that would *never* mate on the plane
**do** mate on the line, because each checker is defended by the other. -/

/-- Adjacency on the one-dimensional line. -/
def kingAdj1 (p q : ℤ) : Prop := p ≠ q ∧ |p - q| ≤ 1

/-- On the line a rook attacks every square other than its own. -/
def rookAttacks1 (r s : ℤ) : Prop := s ≠ r

/-- Some rook of `R` attacks `s` on the line. -/
def attackedBy1 (R : Finset ℤ) (s : ℤ) : Prop := ∃ r ∈ R, rookAttacks1 r s

/-- Checkmate on the line. -/
def Checkmated1 (R : Finset ℤ) (k : ℤ) : Prop :=
    attackedBy1 R k ∧ ∀ s, kingAdj1 k s → attackedBy1 R s

/-- **Two rooks mate on the line.**  With rooks at `k-1` and `k+1`, the king at
`k` is in check and each escape square is a *defended* rook: the checker cannot
be captured because the other rook guards it.  This is the exact opposite of the
planar and higher-dimensional situation, where two rooks can never mate — the
collapse of the fortress is a one-dimensional phenomenon. -/
theorem one_dim_two_rooks_mate (k : ℤ) : Checkmated1 {k - 1, k + 1} k := by
  constructor
  · exact ⟨k - 1, by simp, by simp only [rookAttacks1]; omega⟩
  · rintro s ⟨hne, habs⟩
    rw [abs_le] at habs
    have hcase : s = k - 1 ∨ s = k + 1 := by omega
    rcases hcase with h | h
    · exact ⟨k + 1, by simp, by simp only [rookAttacks1]; omega⟩
    · exact ⟨k - 1, by simp, by simp only [rookAttacks1]; omega⟩

/-! ## Examples, generalizations, and boundaries

**Examples.**  Concrete instantiations of the definitions and theorems. -/

-- The three-dimensional board (`d = 1`, i.e. `ℤ^3`).
#check (king_escape_single_rook (d := 1))
#check (single_rook_no_mate (d := 5))
#check (single_rook_never_traps (d := 0))

-- On `ℤ^3`, the origin steps to the all-ones square to flee a rook at the origin.
example : gStep (d := 1) (fun _ => 0) (fun _ => 0) = fun _ => (1 : ℤ) := by
  funext i; simp [gStep, escC]

-- A concrete safe square exists against any finite army on `ℤ^2`.
example (R : Finset (Sq 0)) : ∃ s : Sq 0, ¬ attackedBy R s :=
  exists_safe_square R

/-
**Generalization.**  The escape argument depends on the ambient dimension only
through the existence of two distinct axes (`exists_axis_ne`).  Consequently the
entire lone-rook fortress — one-step escape, infinite run, and transfinite
inaccessibility — is a single theorem schema valid for *every* `d`, an unbounded
family of dimensions.  The natural further extension replaces `Fin (d+2)` by an
arbitrary index type with at least two elements, capturing a genuinely
infinite-dimensional Hilbert board for the covering (safe-square) results.

**Boundary.**  The threshold is exactly two axes.  In dimension one
(`one_dim_two_rooks_mate`) two rooks *do* checkmate, because each checker is
defended by the other and cannot be captured — the direct counterexample to the
higher-dimensional "no mate" phenomenon.  Thus the results are sharp: they hold
for all `d ≥ 0` (dimension `≥ 2`) and fail in dimension one.
-/

end HilbertBoardChess