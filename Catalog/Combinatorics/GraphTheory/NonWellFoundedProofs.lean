import Mathlib

/-!
# Non-well-founded proof graphs: a guarded negative result

This file separates three notions often conflated in discussions of circular proofs:
finite observations of a possibly infinite tree, cyclic proof graphs, and ordinary
hypothetical derivations.  Finite observations form a dcpo under inclusion.  In
contrast, requiring every dependency to have strictly smaller ordinal rank excludes
all cycles, so it cannot validate a genuinely self-referential proof.  Finally,
`P → P` has the usual finite assumption proof; circularity is unnecessary.
-/

namespace NonWellFoundedProofs

/-- A tiny implicational language. -/
inductive Formula (Atom : Type) where
  | atom : Atom → Formula Atom
  | imp : Formula Atom → Formula Atom → Formula Atom
  deriving DecidableEq, Repr

infixr:55 " ⟹ " => Formula.imp

/-- Sequents carry a finite list of open assumptions. -/
structure Sequent (Atom : Type) where
  context : List (Formula Atom)
  conclusion : Formula Atom
  deriving DecidableEq, Repr

/-- Ordinary finite natural-deduction proofs for implication. -/
inductive Derivation {Atom : Type} : Sequent Atom → Type
  | hyp {Γ A} (h : A ∈ Γ) : Derivation ⟨Γ, A⟩
  | impIntro {Γ A B} (d : Derivation ⟨A :: Γ, B⟩) :
      Derivation ⟨Γ, A ⟹ B⟩

/-- The canonical proof of `P → P`: introduce `P`, then use that assumption. -/
def identityDerivation {Atom : Type} (P : Formula Atom) :
    Derivation ⟨[], P ⟹ P⟩ :=
  .impIntro (.hyp (by simp))

/-- Height counts inference edges; an assumption leaf has height zero. -/
def Derivation.height {Atom : Type} {s : Sequent Atom} : Derivation s → ℕ
  | .hyp _ => 0
  | .impIntro d => d.height + 1

/-- The assumption proof of `P → P` has exactly height one. -/
theorem identityDerivation_height {Atom : Type} (P : Formula Atom) :
    (identityDerivation P).height = 1 := by
  simp [identityDerivation, Derivation.height]

/-- A potentially non-well-founded tree, represented extensionally by its finite
observations at addresses.  This is a final-coalgebra style encoding: no recursive
Lean value needs to contain itself, but labels may occur at every finite depth. -/
abbrev ProofTree (Label : Type) := List ℕ → Option Label

/-- A finite-depth approximation reveals nodes only through depth `n`. -/
def truncate {Label : Type} (n : ℕ) (t : ProofTree Label) : ProofTree Label :=
  fun p => if p.length ≤ n then t p else none

/-
Truncations agree with the original tree at every address eventually.
-/
theorem truncate_eventually {Label : Type} (t : ProofTree Label) (p : List ℕ) :
    truncate p.length t p = t p := by
  exact if_pos le_rfl

/-- The one-node cyclic graph unravels to a genuine infinite unary tree. -/
def selfUnravelling (Label : Type) (label : Label) : ProofTree Label :=
  fun p => if ∀ i ∈ p, i = 0 then some label else none

/-
Every address on the unary spine occurs in the cyclic graph's unravelling.
-/
theorem selfUnravelling_spine (Label : Type) (label : Label) (n : ℕ) :
    selfUnravelling Label label (List.replicate n 0) = some label := by
  unfold selfUnravelling; aesop;

/-
Therefore the unravelling has nodes at arbitrarily large finite depths.
-/
theorem selfUnravelling_unbounded (Label : Type) (label : Label) (n : ℕ) :
    ∃ p : List ℕ, p.length = n ∧ selfUnravelling Label label p = some label := by
  exact ⟨List.replicate n 0, by simp, selfUnravelling_spine _ _ _⟩

/-- A finite observation is a set of labelled addresses in a proof tree.  Taking all
such sets also includes partial and inconsistent observations; consistency can be
imposed as a Scott-closed predicate separately. -/
abbrev Observation (Label : Type) := Set (List ℕ × Label)

/-- The limit of an increasing sequence of finite observations is their union. -/
def chainLimit {Label : Type} (c : ℕ → Observation Label) : Observation Label :=
  ⋃ n, c n

/-- Union is an upper bound of every stage. -/
theorem chain_le_limit {Label : Type} (c : ℕ → Observation Label) (n : ℕ) :
    c n ⊆ chainLimit c := by
  intro x hx
  exact Set.mem_iUnion.2 ⟨n, hx⟩

/-- Union is the least upper bound.  Thus observations, ordered by information
inclusion, are an ω-complete partial order (indeed a complete lattice). -/
theorem chainLimit_least {Label : Type} (c : ℕ → Observation Label)
    (u : Observation Label) (hu : ∀ n, c n ⊆ u) : chainLimit c ⊆ u := by
  intro x hx
  rcases Set.mem_iUnion.1 hx with ⟨n, hn⟩
  exact hu n hn

/-- A monotone sequence of observations. -/
def Increasing {Label : Type} (c : ℕ → Observation Label) : Prop :=
  ∀ n, c n ⊆ c (n + 1)

/-
Every finite stage of an increasing chain embeds into every later stage.
-/
theorem increasing_mono {Label : Type} {c : ℕ → Observation Label}
    (hc : Increasing c) {m n : ℕ} (hmn : m ≤ n) : c m ⊆ c n := by
  exact monotone_nat_of_le_succ hc hmn

/-- A finite proof graph: `depends i j` says node `i` uses node `j` as a premise
or back-reference. -/
structure RankedGraph (Node : Type) where
  depends : Node → Node → Prop
  rank : Node → Ordinal
  decreases : ∀ {i j}, depends i j → rank j < rank i

/-
Strictly rank-decreasing dependencies cannot contain a self-reference.
-/
theorem no_self_reference {Node : Type} (G : RankedGraph Node) (i : Node) :
    ¬ G.depends i i := by
  exact fun h => G.decreases h |> lt_irrefl _

/-
Nor can a strictly decreasing dependency graph contain a finite directed cycle.
This directly disproves the proposed criterion "self-reference converges when it
occurs at a strictly smaller ordinal": returning to the same proof node forces its
ordinal to be strictly below itself.
-/
theorem no_ranked_cycle {Node : Type} (G : RankedGraph Node) (n : ℕ)
    (v : Fin (n + 1) → Node)
    (hedge : ∀ k : Fin n, G.depends (v k.castSucc) (v k.succ)) :
    ¬ G.depends (v (Fin.last n)) (v 0) := by
  have h_ind : ∀ k : Fin n, G.rank (v (Fin.succ k)) < G.rank (v (Fin.castSucc k)) := by
    exact fun k => G.decreases ( hedge k );
  have h_induction : ∀ k : Fin (n + 1), G.rank (v k) ≤ G.rank (v 0) := by
    intro k; induction' k using Fin.inductionOn with i IH; aesop; exact le_trans ( le_of_lt ( h_ind _ ) ) IH;
  exact fun h => not_lt_of_ge ( h_induction _ ) ( G.decreases h )

/-
A direct self-loop, the simplest purported circular proof, admits no decreasing
ordinal ranking.
-/
theorem self_loop_has_no_ranking (Node : Type) (i : Node)
    (depends : Node → Node → Prop) (hloop : depends i i) :
    ¬ ∃ rank : Node → Ordinal, ∀ {x y}, depends x y → rank y < rank x := by
  exact fun ⟨ rank, hr ⟩ => lt_irrefl _ ( hr hloop )

/-
Abstract liar data: `L` says exactly that it is not provable, while provability
is extensionally equivalent to truth for `L`.  These two demanded fixed-point laws
are inconsistent.  This is the precise obstruction; it is not an "undefined
ordinal height" computation.
-/
theorem liar_fixed_point_impossible (Prov L : Prop)
    (reflection : Prov ↔ L) (liar : L ↔ ¬ Prov) : False := by
  grind

/-
Consequently no propositions can realize both liar self-reference and exact
reflection.
-/
theorem no_liar_model :
    ¬ ∃ Prov L : Prop, (Prov ↔ L) ∧ (L ↔ ¬ Prov) := by
  grind

end NonWellFoundedProofs